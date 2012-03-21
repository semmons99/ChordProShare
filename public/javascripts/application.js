jQuery(function(){
  $(".new-form-button").click(function(){
    var url = $(this).data("url");

    $("#new-form").attr("action", url);
    $("#new-form").submit();
  });

  $("#rename-show").click(function(){
    $("#rename-div").show();
    $("#rename-show").hide();
    $("#rename-hide").show();
  });

  $("#rename-hide").click(function(){
    $("#rename-div").hide();
    $("#rename-show").show();
    $("#rename-hide").hide();
  });
});
