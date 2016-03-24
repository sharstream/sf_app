/************************************************************
* @author       :   David Perez(kitsunebrave)
* Related Task  :   Ticket-00382254
* Purpose       :   insert a modal div in the standard page
************************************************************/
/*@description: This script will insert a modal div in the standard page.
                the modal will contain a VF page. This file should be located in static resource.*/
var j$ = jQuery.noConflict();
var currentUrl = window.location.href;
var hostIndex = currentUrl.indexOf(window.location.host+'/')+(window.location.host+'/').length;
var OpportunityId = currentUrl.substring(hostIndex,hostIndex+15); 
j$(document).ready(function(){
    /*Insert the jQuery style sheets in the Head.*/
    /*Insert the Modal dialog along with the VF as an iframe inside the div.*/
    j$("head").after(
        j$("<link>",{rel:"stylesheet",
                    href:"https://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css"}));
    j$("body").after(
        j$("<div>",{id:"modalDiv",
                    style:"display:none;"
           }).append(
            j$("<iframe>",{id:"vfFrame",
                         src:"/apex/VRSP_SupportOrderMerge_VP?id="+Support_Order__c+"&scontrolCaching=1",
                         height:200,
                         width:550,
                         frameBorder:0})
           ));
    /*Initialize the Dialog window.*/
    j$("#modalDiv").dialog({
        autoOpen: false,
        height: 210,
        width: 605,
        modal:true
    });
});