resource "aws_codebuild_project" "tf-plan" {
  name          = "tf-plan"
  description   = "Plan stage"
    service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.dockerhub_creds
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}  

resource "aws_codebuild_project" "tf-apply" {
  name          = "tf-apply"
  description   = "Apply stage"
    service_role  = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential = var.dockerhub_creds
      credential_provider = "SECRETS_MANAGER"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}  

resource "aws_codepipeline" "cicd_pipeline" {
  name          = "tf-cicd-apply"
  role_arn  = aws_iam_role.tf-codebuild-role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
          name = "Source"
          action{
              name = "Source"
              category = "Source"
              owner = "AWS"
              provider = "CodeStarSourceConnection"
              version = "1"
              output_artifacts = ["tf-code"]
              configuration = {
                  FullRepositoryId = "BooShenWaa/aws-cicd"
                  BranchName   = "master"
                  ConnectionArn = var.condestart_connector_creds
                  OutputArtifactFormat = "CODE_ZIP"
              }
          }
      }

  stage {
        name ="Plan"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-plan"
            }
        }
    }

    stage {
        name ="Deploy"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["tf-code"]
            configuration = {
                ProjectName = "tf-apply"
            }
        }
    }  
}