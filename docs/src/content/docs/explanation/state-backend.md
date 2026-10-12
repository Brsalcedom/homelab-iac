---
title: Remote state on Cloudflare R2
description: Why Terraform state lives in an R2 bucket and how the S3 backend is configured for it.
sidebar:
  order: 3
---

Every configuration under `terraform/` stores its state in the `homelab-tfstate` bucket on Cloudflare R2, each under its own key.

## Why remote state

The same configuration is applied from a workstation and from CI on the self-hosted runner. Local state would mean the two disagree about what exists. A shared bucket gives one source of truth and keeps state (which can include secrets) out of the repository.

## Why R2

R2 is S3-compatible, so OpenTofu's built-in `s3` backend works with it. It has no egress fees, and it sits with the rest of the Cloudflare setup (DNS, certificates, these docs). It also lives outside the homelab, so the state survives if the Proxmox host is lost.

## How the S3 backend is configured

R2 is not AWS, so the backend turns off the checks that only make sense against AWS:

```hcl
terraform {
  backend "s3" {
    endpoint                    = "https://<account-id>.r2.cloudflarestorage.com"
    bucket                      = "homelab-tfstate"
    key                         = "proxmox/vm/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
```

Credentials come from `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, set to an R2 API token's key pair.

## The bucket itself

The bucket is created by the `cloudflare/` configuration. That configuration can't store its state in the bucket it creates, so it keeps local state.

## Locking

The backend has no locking configured. Concurrent applies against the same key are avoided by running applies through CI, one workflow per configuration.
