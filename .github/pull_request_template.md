## 🧩 PR Type

Select the appropriate type:

- [ ] Feature → Develop
- [ ] Develop → Main (Release)

---

## 🚀 Description

<!-- Briefly describe what this PR does and why it's needed -->

---

## 📁 Affected Areas

Check all relevant areas:

- [ ] cloudflare
- [ ] proxmox
- [ ] k8s-infraestructure
- [ ] k8s-applications
- [ ] argocd
- [ ] fluxcd
- [ ] GitHub workflows/config
- [ ] Other: __________

---

## ✅ Checklist

- [ ] `terraform validate` passed
- [ ] `terraform plan` was reviewed and verified
- [ ] `terraform fmt` was applied
- [ ] Secret scan passed (automated check)
- [ ] All CI workflows passed

---

## 📦 Release Checklist (only for Develop → Main)

- [ ] Manual review of final `terraform plan`
- [ ] Reviewed and approved by maintainer or CI
- [ ] Ready for safe `terraform apply` in production

---

## 📸 Evidence / Output

```bash
# Example: terraform plan output or screenshots
```