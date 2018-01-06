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
	$("#image-apps").height($("#start-section-3").height/2)

	if(width < 500){	// Phone Portrait Mode
		$("#start-section-2").height(height/1.8);
		$("#start-section-2").css("padding", "50px");
		$("#start-description-1").css("margin-top", "50px");

		$("#image-apps").css("margin-top", "50px");
		$("#start-section-3").height(height/1.7);
	}else if(width < 755){	// Phone, Tablet (xs, sm)
		$("#start-section-2").height(height/2.3);
		$("#start-section-2").css("padding", "50px");
		$("#start-description-1").css("margin-top", "50px");

		$("#image-apps").css("margin-top", "50px");
		$("#start-section-3").height(height/2.5);
	}else{	// Laptop, Desktop (md, lg, xl)
		$("#start-section-2").height(height/7);
		$("#start-section-2").css("padding", "75px");
		$("#start-description-1").css("margin-top", "0px");

		$("#image-apps").css("margin-top", "0px");
		$("#start-section-3").height(height/8);
	}
}