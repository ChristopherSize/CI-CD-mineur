const express = require('express'); 
const app = express();
app.get('/', (req,res)=> res.send('App déployée via CI/CD et Kubernetes')); 
app.listen(3000, ()=> console.log("Running on 3000"));