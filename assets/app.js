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
