import fs from 'node:fs';
import vm from 'node:vm';
import assert from 'node:assert/strict';
const elements=new Map();const get=s=>{if(!elements.has(s))elements.set(s,{insertAdjacentHTML(){},innerHTML:'',textContent:'',style:{},classList:{add(){},remove(){}},click(){},setAttribute(){},removeAttribute(){}});return elements.get(s);};
const store=new Map();
const context=vm.createContext({window:{addEventListener(){},scrollTo(){}},document:{querySelector:get,querySelectorAll:()=>[],createElement:()=>get('a')},localStorage:{getItem:k=>store.get(k)||null,setItem:(k,v)=>store.set(k,v)},location:{hash:''},navigator:{},setInterval(){},setTimeout(){},Blob,URL,confirm:()=>true,console});
vm.runInContext(fs.readFileSync('dist/data.js','utf8'),context);
vm.runInContext(fs.readFileSync('dist/app.js','utf8'),context);
const run=s=>vm.runInContext(s,context);
assert.equal(run('C.labs.length'),20);assert.equal(run('C.questions.length'),40);assert.equal(run('C.scenarios.length'),10);
for(let i=1;i<=20;i++){assert.ok(run(`labDetail(${i})`).includes('Checkpoint'));}
for(const g of run('C.groups.map(g=>g.id)'))assert.ok(run(`mapId='${g}';mapView()`).includes('mindmap'));
assert.ok(run('markdown('+JSON.stringify('```bash\necho hi\n```')+')').includes('echo hi'));
assert.ok(!run("markdown('<script>alert(1)</script>')").includes('<script>'));
assert.ok(!run("markdown('[bad](javascript:alert)')").includes('href='));
run("startQuiz('exam'); C.questions.forEach(q=>quiz.answers[q.id]=q.answer); finish()");
assert.equal(run('quiz.correct'),40);assert.equal(run('state.attempts[0].score'),100);
run("startQuiz('practice'); C.questions.forEach(q=>quiz.answers[q.id]=(q.answer+1)%4);finish()");
assert.equal(run('quiz.correct'),0);
run("state.labs[1]='done';save()");assert.equal(run('done()'),1);assert.ok(store.has('az401-atlas-v1'));
for(let i=0;i<10;i++){assert.ok(run(`scenario=${i};reveal=true;scenariosView()`).includes('Suggested answer'));assert.ok(run(`C.scenarios[${i}].answer.length`)>30);}
run("search='OIDC';domain='all';statusFilter='all';filterLabs()");assert.ok(get('#labresults').innerHTML.includes('Abrir laboratório'));
console.log('PASS: content counts; 20 lab renders; 5 map domains; 10 scenario answers; markdown escaping; quiz 100%/0%; persistence; search. DOM stubs only: browser layout remains unverified.');

