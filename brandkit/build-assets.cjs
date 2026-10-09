// Regenerate vector and raster assets: NODE_PATH=/path/to/node_modules node build-assets.cjs
const fs=require('fs'),path=require('path');
const {GlobalFonts,convertSVGTextToPath}=require('@napi-rs/canvas');
const sharp=require('sharp');
for(const w of [400,500,600,700]) GlobalFonts.registerFromPath(path.join(__dirname,`fonts/Manrope-${w}.ttf`),`Manrope${w}`);
const C={teal:'#176B62',deep:'#104C46',ink:'#173C38',muted:'#526B65',mint:'#DFF0E8',paper:'#F7F9F5',white:'#FFFFFF',apricot:'#F4C7A5',lilac:'#EBE8F4',line:'#D7E2DC'};
const mark=(x=0,y=0,s=1,a=C.teal,b='#75B8A4')=>`<g transform="translate(${x} ${y}) scale(${s})" fill="none" stroke-width="11" stroke-linecap="round"><path d="M39 12H29a17 17 0 0 0 0 34h6" stroke="${a}"/><path d="M29 52h10a17 17 0 0 0 0-34h-6" stroke="${b}"/></g>`;
const t=(x,y,size,text,fill=C.ink,weight=500)=>`<text x="${x}" y="${y}" font-family="Manrope${weight>=650?700:weight>=550?600:weight>=450?500:400}" font-size="${size}" fill="${fill}">${text}</text>`;
const rect=(x,y,w,h,fill,r=0,stroke='none')=>`<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${r}" fill="${fill}" stroke="${stroke}"/>`;
const logo=(x,y,s=1,color=C.ink,a=C.teal,b='#75B8A4')=>`<g transform="translate(${x} ${y}) scale(${s})">${mark(0,0,.75,a,b)}${t(62,38,36,'CareShare',color,750)}</g>`;
const wrap=(w,h,body,label)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" role="img" aria-label="${label}"><title>${label}</title>${body}</svg>`;
async function save(name,w,h,body,label,scale=1){let svg=wrap(w,h,body,label);svg=convertSVGTextToPath(svg);fs.writeFileSync(path.join(__dirname,'assets',name+'.svg'),svg);await sharp(svg,{density:72*scale}).png().toFile(path.join(__dirname,'assets',name+'.png'));}
(async()=>{
await save('careshare-logo',304,64,logo(10,8), 'CareShare primary logo',3);
await save('careshare-logo-mono',304,64,logo(10,8,1,C.ink,C.ink,C.ink),'CareShare monochrome logo',3);
await save('careshare-logo-reversed',304,64,logo(10,8,1,C.white,C.white,'#B6DECB'),'CareShare reversed logo for dark backgrounds',3);
await save('careshare-symbol',80,80,mark(8,8),'CareShare shared-loop symbol',4);
await save('careshare-app-icon',512,512,rect(0,0,512,512,C.teal,112)+mark(64,64,6,C.white,'#B6DECB'),'CareShare app icon');
await sharp(path.join(__dirname,'assets/careshare-app-icon.png')).resize(32,32).png().toFile(path.join(__dirname,'assets/favicon-32.png'));
const art=()=>`<g transform="translate(1015 80)"><circle cx="170" cy="220" r="190" fill="${C.mint}"/><path d="M170 78H112a103 103 0 0 0 0 206h40" stroke="${C.teal}" stroke-width="62" stroke-linecap="round" fill="none"/><path d="M158 370h58a103 103 0 0 0 0-206h-40" stroke="#A4D0BC" stroke-width="62" stroke-linecap="round" fill="none"/><circle cx="315" cy="42" r="28" fill="${C.apricot}"/></g>`;
await save('careshare-banner',1600,600,rect(0,0,1600,600,C.paper)+logo(84,52,1.12)+t(88,216,17,'THE FIRST 72 HOURS. SHARED.',C.teal,700)+t(84,300,64,'A little support.',C.ink,600)+t(84,375,64,'A lot less to carry.',C.ink,600)+t(88,452,23,'Meals, rides, and everyday help after a hospital stay.',C.muted)+art()+t(88,548,16,'Care, made easier together.',C.teal,650),'CareShare banner: A little support. A lot less to carry.');
await save('careshare-social',1200,630,rect(0,0,1200,630,C.mint)+logo(64,48,1.05)+t(64,236,66,'Care, made easier',C.ink,600)+t(64,318,66,'together.',C.ink,600)+t(68,392,23,'Support for the first 72 hours after a hospital stay.',C.muted)+mark(915,415,3.1)+rect(66,476,408,62,C.white,31)+t(94,516,20,'Meals. Rides. A shared plan.',C.teal,650),'CareShare social sharing card');
let b=rect(0,0,1600,1130,'#F0F4EF')+logo(60,34,1.0)+t(1256,68,15,'BRAND SYSTEM / 01',C.muted,650);
b+=rect(48,120,968,418,C.paper,28)+t(80,170,14,'CARESHARE • EVERYDAY SUPPORT',C.teal,700)+t(78,257,66,'A little support.',C.ink,600)+t(78,335,66,'A lot less to carry.',C.ink,600)+t(82,390,21,'A calmer start to the first 72 hours.',C.muted)+rect(82,441,206,56,C.teal,28)+t(106,477,17,'Build a support plan',C.white,650)+mark(790,180,2.3)+`<circle cx="923" cy="402" r="30" fill="${C.apricot}"/>`;
b+=rect(1040,120,512,682,C.mint,28)+t(1072,166,14,'THE BRAND IN YOUR HAND',C.teal,700)+rect(1107,198,378,566,C.white,34)+logo(1133,224,.66)+t(1135,317,28,'One step at a time.',C.ink,650)+t(1135,349,15,'Your first 72 hours, in one place.',C.muted)+rect(1135,378,320,47,C.paper,14)+rect(1139,382,105,39,C.teal,11)+t(1162,407,14,'Today',C.white,650)+t(1264,407,14,'Tomorrow',C.muted)+t(1382,407,14,'Day 3',C.muted);
b+=rect(1135,447,320,117,C.white,18,C.line)+t(1154,477,12,'MEALS • TODAY, 6–7 PM',C.muted,700)+t(1154,510,20,'Dinner, taken care of.',C.ink,650)+rect(1153,524,102,26,C.mint,13)+t(1164,542,12,'Confirmed',C.deep,650)+t(1330,542,13,'You pay $12',C.ink,650);
b+=rect(1135,580,320,88,C.lilac,18)+t(1154,611,13,'TOMORROW’S RIDE',C.muted,650)+t(1154,642,18,'Waiting for a reply',C.ink,650)+rect(1135,690,320,46,C.teal,23)+t(1212,720,15,'Review your plan',C.white,650)+t(1138,751,10,'ILLUSTRATIVE DEMO • SERVICES &amp; FUNDING SIMULATED',C.muted);
b+=rect(48,562,470,240,C.white,24)+t(78,605,14,'01 / COLOR, WITH ROOM TO BREATHE',C.muted,700);
[[C.teal,'Teal'],[C.mint,'Mint'],[C.paper,'Cloud'],[C.apricot,'Apricot'],[C.ink,'Ink']].forEach(([c,n],i)=>{b+=rect(78+i*84,628,72,91,c,14)+t(78+i*84,747,12,n,C.ink,600)+t(78+i*84,768,11,c,C.muted)});
b+=rect(542,562,474,240,C.white,24)+t(572,605,14,'02 / A HUMAN, MODERN VOICE',C.muted,700)+t(570,696,76,'Aa',C.teal,550)+t(727,660,23,'Manrope',C.ink,650)+t(727,691,15,'Clear. Warm. Reassuring.',C.muted)+t(574,763,18,'Care, made easier together.',C.ink,600);
b+=rect(48,826,708,252,C.white,24)+t(78,870,14,'03 / SMALL DETAILS. LESS EFFORT.',C.muted,700)+rect(78,895,185,50,C.teal,25)+t(108,927,16,'Continue  →',C.white,650)+rect(280,895,184,50,C.white,25,C.teal)+t(303,927,16,'View options',C.teal,650)+rect(78,974,137,34,C.mint,17)+t(95,997,14,'Confirmed',C.deep,650)+rect(229,974,132,34,'#FFF0D9',17)+t(247,997,14,'Requested','#80500E',650)+rect(375,974,141,34,C.lilac,17)+t(393,997,14,'Completed','#55487D',650)+t(80,1051,13,'Generous targets. Explicit states. One clear next step.',C.muted);
b+=rect(780,826,772,252,C.teal,24)+logo(816,855,.86,C.white,C.white,'#B6DECB')+t(818,978,33,'Good care is a shared effort.',C.white,550)+t(818,1022,16,'Light by default. Thoughtful at every step.','#DFF0E8')+mark(1374,869,2,C.white,'#B6DECB');
await save('careshare-brand-board',1600,1130,b,'CareShare brand board with palette, logo, typography and app components');
console.log('Created CareShare SVG and PNG assets.');
})();
