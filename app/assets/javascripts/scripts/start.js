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
   $("#start-text-1").css("margin-top", height/3.5);
	$("#image-zeichnung").height($("#start-section-2").height/2);

	if(width < 500){	// Phone Portrait Mode
		$("#start-description-1").css("margin-top", "50px");
	}else if(width < 755){	// Phone, Tablet (xs, sm)
		$("#start-description-1").css("margin-top", "50px");
	}else{	// Laptop, Desktop (md, lg, xl)
		$("#start-description-1").css("margin-top", "0px");
	}
}