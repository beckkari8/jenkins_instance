def k8slabel = "jenkins-pipeline-${UUID.randomUUID().toString()}"
def slavePodTemplate = """
      metadata:
        labels:
          k8s-label: ${k8slabel}
        annotations:
          jenkinsjoblabel: ${env.JOB_NAME}-${env.BUILD_NUMBER}
      spec:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: component
                  operator: In
                  values:
                  - jenkins-jenkins-master
              topologyKey: "kubernetes.io/hostname"
        containers:
        - name: buildtools
          image: fuchicorp/buildtools
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        - name: docker
          image: docker:latest
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        serviceAccountName: default
        securityContext:
          runAsUser: 0
          fsGroup: 0
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
    """
    properties([
        parameters([
            booleanParam(defaultValue: false, description: 'Please select to apply the changes ', name: 'terraformApply'),
            booleanParam(defaultValue: false, description: 'Please select to destroy all ', name: 'terraformDestroy'), 
            string(defaultValue: '', description: 'Please add an ami_id:', name: 'AMI_ID', trim: false),
             booleanParam(defaultValue: false, description: 'Please select to run in debugMode ', name: 'DEBUG'),
            choice(choices: ['us-east-1', 'us-west-2', 'us-west-1', 'us-east-2', 'eu-west-1'], description: 'Please select the region', name: 'aws_region'),
            choice(choices: ['dev', 'qa', 'stage', 'prod'], description: 'Please select the environment to deploy.', name: 'environment')
        ])
    ])

    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {
      node(k8slabel) {
        stage("Pull SCM") {
            git 'https://github.com/beckkari8/jenkins_instance.git'
        }
        stage("Generate Variables") {
          dir('deployments/terraform') {
            println("Generate Variables")
            def deployment_configuration_tfvars = """
            environment = "${environment}"
            AMI_ID = "${AMI_ID}"
            """.stripIndent()
            writeFile file: 'deployment_configuration.tfvars', text: "${deployment_configuration_tfvars}"
            sh 'cat deployment_configuration.tfvars >> dev.tfvars'
           }   
        }
        container("buildtools") {
            dir('deployments/terraform') {
                withCredentials([usernamePassword(credentialsId: "aws-access-${environment}", 
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    println("Selected cred is: aws-access-${environment}")
                    stage("Terraform Apply/plan") {
                        if (!params.terraformDestroy) {
                          if(params.terraformApply && params.DEBUG){
                            println("Applying changes with debugMode")
                            sh """
                             #!/bin/bash
                             export AWS_DEFAULT_REGION=${aws_region}
                             export TF_LOG=DEBUG
                             source ./setenv.sh dev.tfvars
                             terraform apply -auto-approve -var-file \$DATAFILE
                             """
                          } 
                          else if (params.terraformApply) {
                                println("Applying the changes")
                                sh """
                                 #!/bin/bash
                                export AWS_DEFAULT_REGION=${aws_region}
                                source ./setenv.sh dev.tfvars
                                terraform apply -auto-approve -var-file \$DATAFILE
                                """
                  
                            } else {
                                if(params.DEBUG){
                                  println("Planning the changes with debugMode")
                                  sh """
                                  #!/bin/bash
                                  set +ex
                                  ls -l
                                  export TF_LOG=DEBUG
                                  source ./setenv.sh dev.tfvars
                                  terraform plan -var-file \$DATAFILE
                                  """
                                }
                                else{
                                  println("Planing the changes")
                                  sh """
                                  #!/bin/bash
                                  set +ex
                                  ls -l
                                  source ./setenv.sh dev.tfvars
                                  terraform plan -var-file \$DATAFILE
                                  """
                                }
                            }
                        }
                    }
                    stage("Terraform Destroy") {
                      if(params.terraformDestroy && params.DEBUG){
                        println("Destroying with debugMode")
                            sh """
                            #!/bin/bash
                            source ./setenv.sh dev.tfvars
                            export TF_LOG=DEBUG
                            terraform destroy -auto-approve -var-file \$DATAFILE
                            """
                      }
                      else if (params.terraformDestroy) {
                            println("Destroying the all")
                            sh """
                            #!/bin/bash
                            source ./setenv.sh dev.tfvars
                            terraform destroy -auto-approve -var-file \$DATAFILE
                            """
                        } else {
                            println("Skiping the destroy")
                        }
                    }
                }
            }
        }
      }
    }