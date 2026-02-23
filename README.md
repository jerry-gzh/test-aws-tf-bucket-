# Terraform AWS S3 Lab (Dev)

Repositorio de infraestructura como codigo con Terraform para crear y administrar un bucket S3 en AWS, usando backend remoto en S3, locking con DynamoDB y despliegue CI/CD con GitHub Actions + OIDC.

## Objetivo

- Crear y administrar un bucket S3 de laboratorio en `dev`.
- Guardar el estado de Terraform en backend remoto seguro.
- Ejecutar `plan` y `apply` desde GitHub Actions sin access keys estaticas.

## Arquitectura del Proyecto

- Terraform root:
  - `versions.tf`
  - `providers.tf`
  - `variables.tf`
- Entorno dev:
  - `environments/dev/main.tf`
  - `environments/dev/backend.tf`
- CI/CD:
  - `.github/workflows/terraform-dev.yml`
- Politica IAM de ejemplo del rol CI:
  - `tf-lab-s3-dev.json`

## Prerrequisitos

- Cuenta AWS con permisos para IAM, S3 y DynamoDB.
- Repositorio en GitHub.
- Terraform `>= 1.7.0`.
- AWS CLI configurado localmente (solo para pruebas locales).

## Setup Inicial en Windows (Desde Cero)

Antes de trabajar con Terraform en este repositorio, instala estas herramientas base en tu equipo Windows.

### 1. Instalar Chocolatey

Abrir **PowerShell como Administrador** y ejecutar:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Validar instalacion:

```powershell
choco -v
```

### 2. Instalar Terraform

En PowerShell (idealmente como Administrador), ejecutar:

```powershell
choco install terraform -y
```

Validar instalacion:

```powershell
terraform -version
```

### 3. Validar setup inicial

Ejecuta estos comandos para confirmar que el entorno local quedo listo:

```powershell
choco -v
terraform -version
aws --version
```
## Paso a Paso

### 1. Clonar repositorio e instalar herramientas

```bash
git clone <tu-repo>
cd test-aws-tf-bucket-
terraform -version
aws --version
```

### 2. Configurar provider y version de Terraform

El proyecto ya define:

- Terraform `>= 1.7.0` en `versions.tf`.
- Provider AWS `hashicorp/aws ~> 5.0` en `versions.tf`.
- Region por variable `aws_region` en `variables.tf` y `providers.tf`.

### 3. Definir recurso de infraestructura (dev)

En `environments/dev/main.tf` se crea el bucket S3:

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "jerry-gzh-repo-a-dev-example-839406385516"
}
```

### 4. Configurar backend remoto de Terraform

En `environments/dev/backend.tf`:

- Bucket de state: `jerry-infra-tfstates-dev`
- Key: `test-aws-tf-bucket/dev/terraform.tfstate`
- Region: `us-east-1`
- Tabla lock: `terraform-locks`
- Encrypt: `true`

Crear previamente en AWS:

- Bucket S3 para state con versioning y bloqueo publico.
- Tabla DynamoDB `terraform-locks` con partition key `LockID` (String).

### 5. Configurar IAM OIDC para GitHub Actions

1. Crear Identity Provider en IAM:
- Provider: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

2. Crear rol IAM para GitHub Actions:
- Nombre usado en este proyecto: `gh-actions-terraform-test-aws-tf-bucket-dev`

3. Configurar trust policy del rol para tu repo (`sub`):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<OWNER>/<REPO>:*"
        }
      }
    }
  ]
}
```

### 6. Adjuntar politica IAM al rol de CI

Adjuntar una policy como base la de `tf-lab-s3-dev.json`, cubriendo:

- Operaciones sobre buckets de laboratorio `jerry-gzh-*`.
- Acceso al backend state en `jerry-infra-tfstates-dev/test-aws-tf-bucket/dev/*`.
- Locking DynamoDB en `terraform-locks`.

Nota: Terraform puede requerir acciones de lectura adicionales de S3 durante el `refresh` (por ejemplo `GetBucketPolicy`, `GetBucketRequestPayment`, `GetBucketObjectLockConfiguration`).

### 7. Configurar workflow GitHub Actions

El workflow `.github/workflows/terraform-dev.yml` ya implementa:

- Trigger en `pull_request` y en `push` a `main`.
- Job `plan` para validar y planear cambios.
- Job `apply` solo en `main`.
- Autenticacion AWS por OIDC (`id-token: write`).

### 8. Flujo de ejecucion recomendado

1. Crear rama y cambios Terraform.
2. Abrir Pull Request.
3. Revisar resultado de `terraform plan` en Actions.
4. Hacer merge a `main`.
5. Validar `terraform apply` en Actions.

## Ejecucion Local (Opcional / Recomendado)

Desde `environments/dev`:

```bash
terraform fmt -check -recursive
terraform init -input=false
terraform validate
terraform plan -input=false
```

## Buenas Practicas

- No commitear archivos `.tfstate` ni `.tfstate.backup`.
- Mantener permisos IAM en minimo privilegio.
- Restringir el `sub` del trust policy al repo correcto.
- Usar nombres predecibles por ambiente (`dev`, `qas`, `prd`).
- Revisar siempre el `plan` antes de aplicar.

## Troubleshooting Rapido

- Error `AccessDenied` en `GetBucket*` durante plan:
  - Falta accion IAM de lectura S3 en el rol de GitHub Actions.
- Error en backend S3/DynamoDB:
  - Verifica permisos del bucket de state y la tabla `terraform-locks`.
- El workflow no corre:
  - Verifica rutas en `paths` dentro de `.github/workflows/terraform-dev.yml`.

