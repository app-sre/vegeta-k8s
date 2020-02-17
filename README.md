# Vegeta k8s

This is a quick wrapper of [vegeta load tester](https://github.com/tsenart/vegeta) on a kubernetes job that can run in parallel. Once the jobs are done, the results will be sent into a S3 bucket but vegeta can consume multiple result files to create a single report or a single plot. The [runner script](./attack.sh) is prepared to sent partial results if process is terminated via `SIGINT` or `SIGTERM` but kubernetes seems to delete jobs forcibly and reports won't be sent to S3 in that case. At least, we have a kill switch for the tests.

In order to run the tests, a helm v3 [chart](./helm/vegeta-k8s) has been provided. In order to deploy it:
```
helm install <release name> helm/vegeta-k8s [options]
```
If you don't want to use helm, you can use `helm template` to render the templates and install it via standard `kubectl`.

## Helm chart configuration values

|Parameter|Description|
|---|---|
|**Attack options**|
|`app.s3BucketName`|S3 bucket name to copy vegeta result bin file|
|`app.awsAccessKeyId`|AWS Access Key Id|
|`app.awsSecretAccessKey`|AWS Secret Access KeyId|
|`app.awsDefaultRegion`|AWS Region|
|`app.duration`|vegeta attack `-duration` argument|
|`app.rate`|vegeta attack `-rate` argument|
|`app.keepalive`|vegeta attack `-keepalive` argument|
|`app.maxWorkers`|vegeta attack `-maxworkers` argument|
|`app.maxConnections`|vegeta attack `-maxconnections` argument|
|`app.connections`|vegeta attack `-connections` argument|
|`app.timeout`|vegeta attack `-timeout` argument|
|`app.httpTargets`|List containing the targets to pass to vegeta|

`app.httpTargets` should be a list of methods and targets in vegeta format, e.g.
```yaml
app:
  httpTargets:
    - GET https://www.google.com
    - GET https://www.redhat.com
```

For a complete description of `vegeta attack` arguments, see https://github.com/tsenart/vegeta#attack-command

See [values.yaml](helm/vegeta-k8s/values.yaml) of the helm chart in order to find a complete list of the options available
