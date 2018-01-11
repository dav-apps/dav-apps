$(function(){
   var plan = $("#plan").val();

   $('#toggle-button').sidr();
   setMenuVisibility();
   setupPlanModal(plan);

   $("#select-plan").on('change', function (e) {
      var valueSelected = this.value;
      console.log(valueSelected);
      
      if(valueSelected == "Plus"){
         if(plan == 0){    // User is on free plan and selected Plus
            // Show playment form
            $("#payment-form").show();
         }else{   // If user is on plus plan and selected Plus
            // Hide payment form
            $("#payment-form").hide();
         }

         if(plan == 0){
            $("#update-button").removeClass("disabled");
         }else{
            $("#update-button").addClass("disabled");
         }
      }else if(valueSelected == "Free"){
         // Hide payment form
         $("#payment-form").hide();

         if(plan == 1){
            $("#update-button").removeClass("disabled");
         }else{
            $("#update-button").addClass("disabled");
         }
      }
   });

   $(window).bind('hashchange', function() {
      setMenuVisibility();
   });

   $(window).resize(function() {
      arrangeSidebar();
   });
});

function setupPlanModal(plan){
   if(plan == 0){
      // Select free plan in select and hide payment form
      $("#select-plan").val("Free");
   }else{
      // Select plus plan in select and hide payment form
      $("#select-plan").val("Plus");
   }
   $("#payment-form").hide();
}

function setMenuVisibility(){
   var type = window.location.hash.substr(1);
   if(type == "plans"){
      // Hide main div and show plan div
      $("#main-menu").hide();
      $("#plans-menu").show();
      $("#apps-menu").hide();

      $("#plans-sidebar-entry").addClass("active");
   }else if(type == "apps"){
      $("#main-menu").hide();
      $("#plans-menu").hide();
      $("#apps-menu").show();

      $("#apps-sidebar-entry").addClass("active");
   }else{
      // Show main menu
      $("#main-menu").show();
      $("#plans-menu").hide();
      $("#apps-menu").hide();

      $("#main-sidebar-entry").addClass("active");
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