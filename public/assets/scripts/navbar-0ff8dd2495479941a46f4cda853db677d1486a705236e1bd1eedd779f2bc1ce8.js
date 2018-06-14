$(function(){
   // Collapse now if page is not at top
   navbarCollapse();
   // Collapse the navbar when page is scrolled
   $(window).scroll(navbarCollapse);
   $(window).on('resize', onSizeChange);
});

function navbarCollapse(){
   if ($("#mainNav").offset().top > 100) {
      $("#mainNav").css("background-color", "rgba(255, 255, 255, 0.87)");
   } else {
      $("#mainNav").css("background-color", "transparent");
   }
};

function onSizeChange(){
   $('.navbar-collapse').collapse('hide');
}
;
