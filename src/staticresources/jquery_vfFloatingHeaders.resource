/*Visualforce Floating Headers 1.0
  Create floating/sticky headers for any visualforce pageblocktable
  Author: Daniel Llewellyn (@Kenji776)
  Date: 3/05/2013
*/

(function( $ ){

  $.fn.vfFloatingHeaders = function( options ) {  

	return this.each(function() { 
		try
		{            
			/* Floating table header code */
			//give each table header an ID, since you cant do it in the visualforce code itself, do it via some JS
			$(this).find('.rich-table-thead').each(function(index,value){
				var theadId = Math.floor(Math.random()*10001) + '-' + Math.floor(Math.random()*10001) + '-'+Math.floor(Math.random()*10001);
				$(this).attr('randId',theadId);
				$(this).attr('id',theadId);
			});
			
			//add the floating style to the elements
			if($.browser.mozilla) 
			{
				//table row doeant float in firefox, div floats 
				$(".rich-table-thead" + " tr th div") .addClass("floatingStyle"); 
			}   
			else
			{ 
				//table row can float in IE and Chrome 
				$(".rich-table-thead"+ " tr th").addClass("floatingStyle"); 
			}
			
			$(this).parent().scroll(function(){
				$.fn.vfFloatingHeaders.changeFloatingHeaderPosition(this, $($(this).find('.rich-table-thead')[0]).attr('id'));
			});
		}
		catch(ex)
		{
			console.log('Error setting up floating header: ' + ex.message);     
		}   
	});

  };
})( jQuery );


$.fn.vfFloatingHeaders.changeFloatingHeaderPosition = function(container, headerId) 
{ 
	if($.browser.webkit) //chrome rendering bug fix 
	{
		$("#"+headerId + " tr th").css("visibility", "hidden"); 
	}
	if($.browser.mozilla) 
	{
		$("#"+headerId + " tr th div").css("top", container.scrollTop-1); 
	}
	else
	{
		$("#"+headerId + " tr th") .css("top", container.scrollTop-1); 
	}
	
	if($.browser.webkit) //chrome rendering bug fix 
	{
		$("#"+headerId + " tr th").css("visibility", "visible");
	}           
}  
