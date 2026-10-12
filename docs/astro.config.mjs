// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightLlmsTxt from 'starlight-llms-txt';

// The same dist/ is published to docs.cervant.net (Cloudflare) and
// docs.home.cervant.net (Hyperion). `site` is the public URL, used for
// canonical links, the sitemap and the absolute URLs in llms.txt.
export default defineConfig({
  site: 'https://docs.cervant.net',
  integrations: [
    starlight({
      title: 'homelab-iac',
      description: 'Wiki for the homelab-iac repository: Proxmox, K3s (Hyperion), GitOps and Cloudflare.',
      favicon: '/favicon.svg',
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/Brsalcedom/homelab-iac' },
      ],
      editLink: {
        baseUrl: 'https://github.com/Brsalcedom/homelab-iac/edit/main/docs/',
      },
      lastUpdated: true,
      plugins: [
        starlightLlmsTxt({
          projectName: 'homelab-iac',
          description:
            'Infrastructure as Code for a personal homelab: Proxmox VMs and LXC containers with OpenTofu, a K3s cluster (Hyperion) with Cilium, Gateway API, cert-manager and ArgoCD, and Cloudflare R2 for state.',
        }),
      ],
      sidebar: [
        { label: 'Tutorials', items: [{ autogenerate: { directory: 'tutorials' } }] },
        { label: 'How-to guides', items: [{ autogenerate: { directory: 'how-to' } }] },
        { label: 'Reference', items: [{ autogenerate: { directory: 'reference' } }] },
        { label: 'Explanation', items: [{ autogenerate: { directory: 'explanation' } }] },
      ],
    }),
  ],
});
