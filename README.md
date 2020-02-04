# Vegeta k8s

This is a quick wrapper of [vegeta load tester](https://github.com/tsenart/vegeta) on a kubernetes job that can run parallel. Once the jobs are done, the result will be sent into a S3 bucket. The [runner script](./attack.sh) is prepared to sent partial results if process is terminated via `SIGINT` or `SIGTERM` but kubernetes seems to delete jobs much more forcibly and reports won't be sent to S3 in that case. At least, we have a kill switch for the tests.

In order to run the tests, a helm v3 [chart](./helm/vegeta-k8s) has been provided. In order to deploy it:
```
helm install <release name> helm/vegeta-k8s [options]
```
If you don't want to use helm, you can use `helm template` to render the templates and install it via standard `kubectl`.

See [values.yaml](helm/vegeta-k8s/values.yaml) of the helm chart in order to see the options available

## TODO

* Support for command files in vegeta
