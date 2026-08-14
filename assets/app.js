// Get-IT shared client-side helpers. Loaded after the supabase-js CDN script,
// before any page-specific inline <script>. Plain script (no modules) so
// everything here is page-global, matching the site's no-build convention.

const SUPABASE_URL = 'https://kpqzclezbehygltnqfat.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtwcXpjbGV6YmVoeWdsdG5xZmF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzU3MDcsImV4cCI6MjEwMjExMTcwN30.aHSEUkOQBfKEaf0ZqgRKZii7FSB-IgVYtOCkbQk3GRA';
const sb = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

function escapeHtml(s){ return (s||'').replace(/[&<>]/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c])); }
function fmtDate(d){ return new Date(d+'T00:00:00').toLocaleDateString('en-GB', {day:'2-digit', month:'short', year:'numeric'}); }
function ticketNo(n){ return '#' + String(n).padStart(4,'0'); }
function catClass(c){ return 'cat-' + (c||'').toLowerCase().replace(/[^a-z]/g,''); }

function slugify(s){
  return (s||'').toLowerCase().trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function storageUrl(path){
  if(!path) return '';
  return sb.storage.from('case-studies').getPublicUrl(path).data.publicUrl;
}

const CATEGORIES = ['Inspection', 'Repair', 'Workstation Evaluation', 'Enterprise', 'Maintenance'];
const CLIENT_TYPES = ['Student', 'Architect', 'Interior Designer', 'Small Business', 'Individual'];

const VOCAB_DOMAINS = {
  'Hardware': ['cpu','gpu','ray_tracing','ram','storage','battery','thermals','display','ports','bios','motherboard','power'],
  'Operating Systems': ['windows','linux','dual_boot','drivers','updates','licensing'],
  'Networking': ['networking','wifi','switching','routing','firewall','vpn','internet'],
  'Microsoft 365': ['microsoft365','entra','exchange','sharepoint','onedrive','teams','intune','licensing365'],
  'Cybersecurity': ['security','identity','authentication','mfa','backup','recovery','encryption','endpoint'],
  'Infrastructure': ['servers','virtualization','cloud','storage_infrastructure','monitoring'],
  'Maintenance': ['preventive_maintenance','cleaning','diagnostics','performance','upgrades','repair'],
  'Business Systems': ['odoo','erp','automation','inventory','point_of_sale'],
  'Consulting': ['assessment','planning','procurement','recommendation','compliance','documentation']
};

const VOCAB_LABELS = {
  cpu:'CPU', gpu:'GPU', ray_tracing:'Ray Tracing', ram:'RAM', bios:'BIOS',
  vpn:'VPN', mfa:'MFA', microsoft365:'Microsoft 365', licensing365:'Licensing (M365)',
  erp:'ERP', odoo:'Odoo', dual_boot:'Dual Boot', onedrive:'OneDrive', sharepoint:'SharePoint',
  entra:'Entra ID', intune:'Intune', point_of_sale:'Point of Sale',
  storage_infrastructure:'Storage Infrastructure', preventive_maintenance:'Preventive Maintenance'
};
function vocabLabel(key){
  return VOCAB_LABELS[key] || key.replace(/_/g,' ').replace(/\b\w/g, c => c.toUpperCase());
}

// Public-facing case study card, linking to the detail page. Used on the
// homepage (featured), the archive, similar-case-study lists, and
// framework module "related case studies" lists.
function ticketCardHtml(e, i){
  return `
    <a class="ticket ${catClass(e.category)}" style="--i:${i||0}" href="case-study.html?slug=${encodeURIComponent(e.slug)}">
      ${e.featured_image ? `<img class="ticket-image" src="${storageUrl(e.featured_image)}" alt="">` : ''}
      <div class="ticket-head">
        <span class="no">${ticketNo(e.ticket_no)}</span>
        <span>${fmtDate(e.date)}</span>
      </div>
      <div class="ticket-body">
        <span class="cat-badge ${catClass(e.category)}">${escapeHtml(e.category)}</span>
        <h3 style="margin-top:8px;">${escapeHtml(e.title)}</h3>
        ${e.problem ? `<p>${escapeHtml(e.problem)}</p>` : ''}
        ${e.outcome ? `<div class="outcome"><b>Outcome</b>${escapeHtml(e.outcome)}</div>` : ''}
        ${(e.tags && e.tags.length) ? `<div class="tags">${e.tags.map(t=>`<span class="tag">${escapeHtml(t)}</span>`).join('')}</div>` : ''}
      </div>
    </a>`;
}

// Groups a flat checklist/framework_topics array back into its VOCAB_DOMAINS
// structure, keeping only domains with at least one selected item.
function groupChecklistByDomain(keys){
  keys = keys || [];
  return Object.entries(VOCAB_DOMAINS)
    .map(([domain, domainKeys]) => ({ domain, items: domainKeys.filter(k => keys.includes(k)) }))
    .filter(g => g.items.length > 0);
}

// Scores candidate case studies against the current one: +1 for a matching
// category, +1 per overlapping framework_topics tag. Returns the top `limit`.
function scoreSimilar(current, candidates, limit){
  limit = limit || 3;
  const topics = current.framework_topics || [];
  return candidates
    .filter(c => c.id !== current.id)
    .map(c => {
      let score = (c.category === current.category) ? 1 : 0;
      score += (c.framework_topics || []).filter(t => topics.includes(t)).length;
      return { entry: c, score };
    })
    .filter(x => x.score > 0)
    .sort((a, b) => b.score - a.score || new Date(b.entry.date) - new Date(a.entry.date))
    .slice(0, limit)
    .map(x => x.entry);
}

function waLink(digits, message){
  return `https://wa.me/${digits}?text=${encodeURIComponent(message)}`;
}
