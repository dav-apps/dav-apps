$(function(){
   var loggedIn = ($("#logged-in").text() == 'true');
   if(!loggedIn){
      $("#login-implicit-form").removeClass("hidden");
   }

   $("#log-in-user").click(function(){
      $("#logged-in-user-list").addClass("hidden");
      $("#login-implicit-form").removeClass("hidden");
   });
});