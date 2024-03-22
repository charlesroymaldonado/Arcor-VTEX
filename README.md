# Proyecto Terraform Arcor MVP

Terraform project esta compuesto por un modulo principal y submodulos
 - Modulo arcor_common. Este modulo crea los recursos que son comunes a todos los submodulos
 - Modulo arcor_orders_iac. Crea los recursos relacionados a la ingesta de la orden
 - Modulo arcor_md_iac. Crea los recursos para la ingesta de datos maestros como por ejemplo clientes

## Ambientes 
Se debera crear un archivo .tfvars por cada ambiente que se van a deployar los recursos. Por ejemplo:dev.tfvars contiene las variables personalizadas para el ambiente de desarrollo 


```
$ terraform init - Inicializa el proyecto terraform
```

```
$ terraform plan -var-file=<achivo tfvars> - Realiza el plan de ejecucion de terraform tomando las variables definidas en el archivo .tfvars
```

```
$ terraform apply -var-file=<achivo tfvars> - Ejecuta el plan de terraform tomando las variables definidas en el archivo .tfvars
```
