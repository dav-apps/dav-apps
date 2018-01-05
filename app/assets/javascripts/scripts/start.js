$(function(){
   arrangeElements();

	$(window).resize(function() {
      arrangeElements();
   });
});

function arrangeElements(){
   // Set the height of the first image
   var height = $(window).height();
   var width = $(window).width();

   $("#start-section-1").height(height);
}