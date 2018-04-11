function stickHeader(tableId, headerClass) {
  var stickyHeaderTop = jQuery('table[id$='+ tableId + '] > thead').offset().top;
  var tableBottomPosition = jQuery('table[id$='+ tableId + ']').offset().top + jQuery('table[id$='+ tableId + ']').outerHeight(true) - jQuery('table[id$='+ tableId + '] > thead').height();
  window.addEventListener("scroll", function(){
    if(jQuery(window).scrollTop() > stickyHeaderTop && jQuery(window).scrollTop() < tableBottomPosition) {
      setColumnWidthEqualToDisplayed(headerClass);
      var headerRowWidth = jQuery('table[id$='+ tableId + '] > thead').width();
      jQuery('table[id$='+ tableId + '] > thead').css({position: 'fixed', top: '0px', width: '100%'});
    } else {
      jQuery('table[id$='+ tableId + '] > thead ').css({position: 'static', top: '0px'});
    }
  });
}

function setColumnWidthEqualToDisplayed(headerClass) {
  jQuery('.' + headerClass).each(function( index ) {
     var columnWidth = jQuery(this).width();
     jQuery(this).css({width : columnWidth});
  });
}