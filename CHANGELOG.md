# Changelog

## [2.0.1](https://github.com/Brsalcedom/homelab-iac/compare/v2.0.0...v2.0.1) (2026-02-22)


### Bug Fixes

* working directory in lxc workflow & github runner docs ([#86](https://github.com/Brsalcedom/homelab-iac/issues/86)) ([89708e1](https://github.com/Brsalcedom/homelab-iac/commit/89708e14c0ee6427bbe5e4bfae36492dd51b4964))

## [2.0.0](https://github.com/Brsalcedom/homelab-iac/compare/v1.0.0...v2.0.0) (2026-02-22)


### ⚠ BREAKING CHANGES

* **github-action:** Update action actions/checkout to v6 ([#80](https://github.com/Brsalcedom/homelab-iac/issues/80))

### Features

* **deps:** update terraform cloudflare to v5.17.0 ([#79](https://github.com/Brsalcedom/homelab-iac/issues/79)) ([c8f148b](https://github.com/Brsalcedom/homelab-iac/commit/c8f148bd62ca1e899e714ad8a0d96a194965a429))
* **deps:** update terraform proxmox to v0.96.0 ([#78](https://github.com/Brsalcedom/homelab-iac/issues/78)) ([3faba54](https://github.com/Brsalcedom/homelab-iac/commit/3faba546fd82b9f59453cc836410262927f666fe))


### Continuous Integration

* **github-action:** Update action actions/checkout to v6 ([#80](https://github.com/Brsalcedom/homelab-iac/issues/80)) ([2b1d531](https://github.com/Brsalcedom/homelab-iac/commit/2b1d531745b1bd8eaa4d8aeca93394524d8e2956))

## [1.0.0](https://github.com/Brsalcedom/homelab-iac/compare/v0.1.0...v1.0.0) (2026-02-22)


### ⚠ BREAKING CHANGES

* **github-action:** Update action actions/labeler to v6 ([#73](https://github.com/Brsalcedom/homelab-iac/issues/73))
* **deps:** Update Terraform cloudflare to v5 ([#49](https://github.com/Brsalcedom/homelab-iac/issues/49))

### Features

* add cloudnative-pg ([904c56c](https://github.com/Brsalcedom/homelab-iac/commit/904c56ca1adf6e40dcdeeab7cd413d7e824996cd))
* add go task ([#76](https://github.com/Brsalcedom/homelab-iac/issues/76)) ([24a5c5b](https://github.com/Brsalcedom/homelab-iac/commit/24a5c5b5009025e6efe41b21bb69f8ebda26311a))
* add kyverno policies ([#70](https://github.com/Brsalcedom/homelab-iac/issues/70)) ([b9873a2](https://github.com/Brsalcedom/homelab-iac/commit/b9873a2d70761aa8f32a2d6559c3544a63983fa4))
* add labels to renovate ([#46](https://github.com/Brsalcedom/homelab-iac/issues/46)) ([6928f6e](https://github.com/Brsalcedom/homelab-iac/commit/6928f6e27bd636dbe61110bd8123e15ceab2e36d))
* add manifest source ([cc72b74](https://github.com/Brsalcedom/homelab-iac/commit/cc72b74d37f4d72adc6bffa413e9fb4bcf1b949d))
* add new source in app ([bd5c104](https://github.com/Brsalcedom/homelab-iac/commit/bd5c104014298fa09c86691ae422e96d9e14d55e))
* add swarm tf code ([#31](https://github.com/Brsalcedom/homelab-iac/issues/31)) ([c709d79](https://github.com/Brsalcedom/homelab-iac/commit/c709d79a9a5c9b8d703d023c17eab90bb3ed4bc6))
* add tf lxc workflow ([#32](https://github.com/Brsalcedom/homelab-iac/issues/32)) ([c884084](https://github.com/Brsalcedom/homelab-iac/commit/c8840844aa7b92433e901af7c3f444d282854c6a))
* **container:** update image brsalcedom/homelab-ci to v2.1.0 ([#58](https://github.com/Brsalcedom/homelab-iac/issues/58)) ([d8b143c](https://github.com/Brsalcedom/homelab-iac/commit/d8b143c4a99a8dc647b4340d7a1383aa7ca28ceb))
* **container:** update image brsalcedom/homelab-ci to v2.2.0 ([#75](https://github.com/Brsalcedom/homelab-iac/issues/75)) ([4d35caf](https://github.com/Brsalcedom/homelab-iac/commit/4d35cafd8bb0e68998c7b6320c72ec01f7b70416))
* create secret for netbird ([7f58a53](https://github.com/Brsalcedom/homelab-iac/commit/7f58a535d9e265acecdd94018d2f0ca0451a5d46))
* custom docker image for jobs ([#52](https://github.com/Brsalcedom/homelab-iac/issues/52)) ([0376eaf](https://github.com/Brsalcedom/homelab-iac/commit/0376eaffa068896bac1549314f86d65de4fda40e))
* **deps:** Update Terraform cloudflare to v5 ([#49](https://github.com/Brsalcedom/homelab-iac/issues/49)) ([ec925bf](https://github.com/Brsalcedom/homelab-iac/commit/ec925bff30ec612fa57ef96ade0bdb742cc3a967))
* **deps:** update terraform cloudflare to v5.9.0 ([#71](https://github.com/Brsalcedom/homelab-iac/issues/71)) ([e20e559](https://github.com/Brsalcedom/homelab-iac/commit/e20e55939d116665ba8a2c15c4b266fa9b58ddd8))
* **deps:** update terraform proxmox to v0.82.0 ([#54](https://github.com/Brsalcedom/homelab-iac/issues/54)) ([00bc538](https://github.com/Brsalcedom/homelab-iac/commit/00bc5380efdb3306f05a502dac0ea977bc48cfa4))
* **deps:** update terraform proxmox to v0.83.0 ([#72](https://github.com/Brsalcedom/homelab-iac/issues/72)) ([f9caa10](https://github.com/Brsalcedom/homelab-iac/commit/f9caa10dd4d2014102bfd42431af00294c7f1df6))
* enable infisical & add cluster pg ([5dbb270](https://github.com/Brsalcedom/homelab-iac/commit/5dbb2708d501af6068162c7bc9e67e9b3bba3f82))
* **github:** auto-assign PR author and improve PR template validation ([#17](https://github.com/Brsalcedom/homelab-iac/issues/17)) ([b977be1](https://github.com/Brsalcedom/homelab-iac/commit/b977be1320b3d84f1925d4e34f892f6d9619c3ed))
* go-task ([#77](https://github.com/Brsalcedom/homelab-iac/issues/77)) ([f00b832](https://github.com/Brsalcedom/homelab-iac/commit/f00b832d6cdc55573bf1942ad1b28765fdc625a0))
* k8s hyperion infra ([#55](https://github.com/Brsalcedom/homelab-iac/issues/55)) ([512748c](https://github.com/Brsalcedom/homelab-iac/commit/512748cafd7ede8f9e689f2ddd453248fde82fda))
* **k8s:** add httproute to infisical ([6805efe](https://github.com/Brsalcedom/homelab-iac/commit/6805efe12c6d46819ac3353069dbcbbbcc46ad98))
* **k8s:** add infisical as secret manager ([7c70c3d](https://github.com/Brsalcedom/homelab-iac/commit/7c70c3d6c8c1ee50b8d174d2e8908078a861e6d2))
* **k8s:** add netbird secrets ([d7511fc](https://github.com/Brsalcedom/homelab-iac/commit/d7511fc91496256115f7fee437a776485cef59dd))
* **labeler:** update labeler to match new version format ([#15](https://github.com/Brsalcedom/homelab-iac/issues/15)) ([eba4132](https://github.com/Brsalcedom/homelab-iac/commit/eba4132f1daefa7edd481d3f72cb50591cef8519))
* refactor & add release please ([#82](https://github.com/Brsalcedom/homelab-iac/issues/82)) ([a3a5f25](https://github.com/Brsalcedom/homelab-iac/commit/a3a5f255921a09bf98cc7ac64a281f6a33ecfbdf))
* switch to infisical operator ([2930994](https://github.com/Brsalcedom/homelab-iac/commit/293099444059401df35201a6c97e017dbdda91f9))
* update apps ([#67](https://github.com/Brsalcedom/homelab-iac/issues/67)) ([065b83a](https://github.com/Brsalcedom/homelab-iac/commit/065b83ad8f434b4ac2d8bbc730eaa26f1dc95267))
* update secret manager ([2e97888](https://github.com/Brsalcedom/homelab-iac/commit/2e978887a4e4b6ab637a414fb4ee5d8f89b4f4e2))
* upgrade swarm lxc os-template ([93b6290](https://github.com/Brsalcedom/homelab-iac/commit/93b6290964cfd179ecc862d0575ad1089a9a05ca))


### Bug Fixes

* add secrets.yaml to kustomize ([816c340](https://github.com/Brsalcedom/homelab-iac/commit/816c340baf7eb468437b93939d6852849229f5c1))
* application template ([99aeade](https://github.com/Brsalcedom/homelab-iac/commit/99aeade493b648870e356284f7da15ee29bbc988))
* **argocd:** correct argocd path in applications ([#19](https://github.com/Brsalcedom/homelab-iac/issues/19)) ([9d23d39](https://github.com/Brsalcedom/homelab-iac/commit/9d23d39a245dafa3b33c863d07c438bcbff52316))
* **argocd:** repo url corrected ([#18](https://github.com/Brsalcedom/homelab-iac/issues/18)) ([ce7433e](https://github.com/Brsalcedom/homelab-iac/commit/ce7433ea06bdb46b84a965d112040cd9f47125e8))
* explicit ns in eso configuration ([e50379d](https://github.com/Brsalcedom/homelab-iac/commit/e50379db1e3c85373946065a518d669a7cecc93e))
* hyperion workflow envs ([#61](https://github.com/Brsalcedom/homelab-iac/issues/61)) ([9f6c4f3](https://github.com/Brsalcedom/homelab-iac/commit/9f6c4f3f20699c477f5feb49e4ff590f7e5c0994))
* improve vars management ([#38](https://github.com/Brsalcedom/homelab-iac/issues/38)) ([c8b2b12](https://github.com/Brsalcedom/homelab-iac/commit/c8b2b121f05fbd351f04882524f119d39a772a5e))
* install certificates ([#42](https://github.com/Brsalcedom/homelab-iac/issues/42)) ([da98ffa](https://github.com/Brsalcedom/homelab-iac/commit/da98ffa24d50980aa889e12a424dd8c2a22b896a))
* **k8s:** envFrom netbird deployment ([9d9c355](https://github.com/Brsalcedom/homelab-iac/commit/9d9c355b5aa5eb074c16517121d0fa7224f7e7fa))
* **k8s:** update api and identity url ([a5ad8f0](https://github.com/Brsalcedom/homelab-iac/commit/a5ad8f09384f57f7f2641d6aa503bcb385caacda))
* **labeler:** correct filename extensions ([#16](https://github.com/Brsalcedom/homelab-iac/issues/16)) ([943ed06](https://github.com/Brsalcedom/homelab-iac/commit/943ed06d1e6b1917d1f6fb5d56b4983192626fdc))
* minor adjustments ([69c73ca](https://github.com/Brsalcedom/homelab-iac/commit/69c73ca3b2965a91e834615548aa23f217da7800))
* namespace ([4b713dc](https://github.com/Brsalcedom/homelab-iac/commit/4b713dc59e3ab522593fd3c046eb4ffeb1bc5eea))
* remove additional source ([181a3bc](https://github.com/Brsalcedom/homelab-iac/commit/181a3bcfe5e90ac5807da38c1f594f451e496cd4))
* remove install crds on helm ([#66](https://github.com/Brsalcedom/homelab-iac/issues/66)) ([33404c6](https://github.com/Brsalcedom/homelab-iac/commit/33404c6456f0c6317dcb65c2e3149f625fcf7134))
* remove kyverno policies ([241deb3](https://github.com/Brsalcedom/homelab-iac/commit/241deb3cde869bd9dedc600c45af9dc957142f7d))
* remove labels in crds ([#64](https://github.com/Brsalcedom/homelab-iac/issues/64)) ([a79d73c](https://github.com/Brsalcedom/homelab-iac/commit/a79d73cca1c96bb1f662014d6d19f8c970ed53c9))
* self hosted container workflow ([#43](https://github.com/Brsalcedom/homelab-iac/issues/43)) ([c467ff8](https://github.com/Brsalcedom/homelab-iac/commit/c467ff843c3eb8241c89172337e37d0df5f67b79))
* self hosted container workflow ([#44](https://github.com/Brsalcedom/homelab-iac/issues/44)) ([131f3d6](https://github.com/Brsalcedom/homelab-iac/commit/131f3d6bd6256d82094e3c6beee91c71369932fc))
* self hosted container workflow ([#45](https://github.com/Brsalcedom/homelab-iac/issues/45)) ([b4157e3](https://github.com/Brsalcedom/homelab-iac/commit/b4157e30a47eb8d3bb5752219a87275cff213353))
* update helm values ([be66431](https://github.com/Brsalcedom/homelab-iac/commit/be6643169e6bad4e282fe81988b39038d501f478))
* update kustomization.yaml ([#65](https://github.com/Brsalcedom/homelab-iac/issues/65)) ([13aead3](https://github.com/Brsalcedom/homelab-iac/commit/13aead388038937386ee895fd5f197267d5ad717))
* update kustomize files ([ff75eb3](https://github.com/Brsalcedom/homelab-iac/commit/ff75eb30cad5a8888b74f284f2ce790504b203fb))
* update tofu lxc workflow ([#37](https://github.com/Brsalcedom/homelab-iac/issues/37)) ([8c755bd](https://github.com/Brsalcedom/homelab-iac/commit/8c755bd039a46db3052cfc45319f1f57f775bde0))
* Update tofu-k8s-hyperion.yaml ([#63](https://github.com/Brsalcedom/homelab-iac/issues/63)) ([3ca53b1](https://github.com/Brsalcedom/homelab-iac/commit/3ca53b1f9c18b7fc06385bdd67b956fa7d30778b))
* use ServerSideApply ([5e732e7](https://github.com/Brsalcedom/homelab-iac/commit/5e732e7cd967f2d42951ebdb4efbb6146d7b5b7a))
* values file ([7fb3520](https://github.com/Brsalcedom/homelab-iac/commit/7fb35202375ee51b2f5cb8708a2912c3a9bbb877))


### Continuous Integration

* **github-action:** Update action actions/labeler to v6 ([#73](https://github.com/Brsalcedom/homelab-iac/issues/73)) ([adc1ffc](https://github.com/Brsalcedom/homelab-iac/commit/adc1ffcf5ab6055eeb2a0d40ec336d77824e6b36))
