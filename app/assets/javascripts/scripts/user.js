$(function(){
   $('#toggle-button').sidr();
   setMenuVisibility();

   $(window).bind('hashchange', function() {
      setMenuVisibility();
   });

   $(window).resize(function() {
      arrangeSidebar();
   });
});

function setMenuVisibility(){
   var type = window.location.hash.substr(1);
   if(type == "plans"){
      // Hide main div and show plan div
      $("#main-menu").hide();
      $("#plans-menu").show();
      $("#apps-menu").hide();
   }else if(type == "apps"){
      $("#main-menu").hide();
      $("#plans-menu").hide();
      $("#apps-menu").show();
   }else{
      // Show main menu
      $("#main-menu").show();
      $("#plans-menu").hide();
      $("#apps-menu").hide();
   }

   arrangeSidebar();
}

function arrangeSidebar(){
   var width = $(window).width();

   if(width < 992){
      // Hide all menus
      $("#sidebar-content").hide();
      $("#toggle-button").show();
   }else{
      $("#sidebar-content").show();
      $("#toggle-button").hide();
      $.sidr('close', 'sidr');
   }
}