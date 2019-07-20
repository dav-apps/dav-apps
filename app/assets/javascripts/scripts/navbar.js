$(function(){
   // Collapse now if page is not at top
	navbarCollapse();
	onSizeChange();
   // Collapse the navbar when page is scrolled
   $(window).scroll(navbarCollapse);
	$(window).on('resize', onSizeChange);
});

function navbarCollapse(){
   if ($("#mainNav").offset().top > 100) {
      $("#mainNav").addClass("acrylic light shadow");
   } else {
      $("#mainNav").removeClass("acrylic light shadow");
   }
};

function onSizeChange(){
	$('.navbar-collapse').collapse('hide');
	
	if(window.innerWidth > 575){
		// Remove classes from navbar list to remove the acrylic
		$("#navbar-list").removeClass("acrylic light shadow");
	}else{
		// Add classes to navbar list to make it acrylic
		$("#navbar-list").addClass("acrylic light shadow");
	}
}