/*****************************
*
* CSS Style Sheet for Release Notes Web Page
* Author: David Perez
* Date: 1/5/2017
*
******************************/
p{
  color:#9a8478;
}
h1{
  font-size: 30px;
  text-transform: uppercase;
  font-weight: 300;
  text-align: center;
  margin-bottom: 15px;
  color:#9a8478;
}
.tbl-header{
  background-color: rgba(255,255,255,0.3);
 }
 .tbl-content{
  height:300px;
  overflow-x:auto;
  margin-top: 0px;
  border: 1px solid rgba(255,255,255,0.3);
}
a{
  color:#000000;
  font-size:10px;
}
a:hover{
  color:#000000;
}
div{
  border-style:solid;
  border-color:#FFF;
}
th{
  padding: 20px 15px;
  text-align: left;
  font-weight: 500;
  font-size: 12px;
  color: #FFF;
  text-transform: uppercase;
}
td{
  padding: 15px;
  text-align: left;
  vertical-align:middle;
  font-weight: 300;
  font-size: 12px;
  color: #FFF;
  border-bottom: solid 1px rgba(255,255,255,0.1);
}
.clear { /* generic container (i.e. div) for floating buttons */
  overflow: hidden;
  width: 100%;
}
a.button {
  background: transparent url('/resource/1483548245000/ButtonBg') no-repeat scroll top right;
  color: #444;
  display: block;
  float: left;
  font: normal 12px arial, sans-serif;
  height: 24px;
  margin-right: 6px;
  padding-right: 18px; /* sliding doors padding */
  text-decoration: none;
}
a.button span {
  background: transparent url('/resource/1483548245000/ButtonBgSpan') no-repeat;
  display: block;
  line-height: 14px;
  padding: 5px 0 5px 18px;
}
a.button:active {
  background-position: bottom right;
  color: #000;
  outline: none; /* hide dotted outline in Firefox */
}
a.button:active span {
  background-position: bottom left;
  padding: 6px 0 4px 18px; /* push text down 1px */
}
table{
  width:100%;
  table-layout: fixed;
}

.responstable {
  margin: 1em 0;
  width: 100%;
  overflow: hidden;
  background: #FFF;
  color: #024457;
  border-radius: 10px;
  border: 1px solid #167F92;
}
.responstable tr {
  border: 1px solid #D9E4E6;
}

/* demo styles */

@import url(http://fonts.googleapis.com/css?family=Roboto:400,500,300,700);
/*body{
  background: #E0EAFC;
  background: -webkit-linear-gradient(to left, #E0EAFC , #CFDEF3); 
  background: linear-gradient(to left, #E0EAFC , #CFDEF3); 
  font-family: 'Roboto', sans-serif;
}*/
body{
  background:linear-gradient(#E5F2F6,#CDE8F0);
  -moz-box-shadow:0 3px 10px hsla(100,0%,0%,.3);
}

/* follow me template */
.made-with-love {
  margin-top: 40px;
  padding: 10px;
  clear: left;
  text-align: center;
  font-size: 10px;
  font-family: arial;
  color: #000000;
}
.made-with-love i {
  font-style: normal;
  color: #F50057;
  font-size: 14px;
  position: relative;
  top: 2px;
}
.made-with-love a {
  color: #000000;
  text-decoration: none;
}
.made-with-love a:hover {
  text-decoration: underline;
}