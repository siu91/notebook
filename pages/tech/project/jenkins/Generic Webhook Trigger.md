```groovy
pipeline {
    agent any
    triggers {
        GenericTrigger(
                genericVariables: [
                        [key: 'job_id', value: '$.job_id'],
                        [key: 'ci_env', value: '$.ci_env'],
                        [key: 'ci_task_name', value: '$.ci_task_name'],
                        [key: 'ci_task_build_id', value: '$.ci_task_build_id']
                ],



                token: 'abc234',
                tokenCredentialId: '',

                printContributedVariables: true,
                printPostContent: true,

                silentResponse: false,

        )
    }
    stages {
        stage('Some step') {
            steps {
                sh "echo $job_id"
                sh "echo $ci_env"
                sh "echo $ci_task_name"
                sh "echo $ci_task_build_id"
            }
        }
    }
}
```


# POST http://192.168.5.149:49000/generic-webhook-trigger/invoke

Authorization: Bearer abc123
```json
{
    "ci_task_name": "uac",
    "ci_task_build_id": 123,
    "ci_env": "test",
    "job_id": "0ef18a0b-6ba0-4d5c-bc3f-ed2f324b1cd0"
}
```