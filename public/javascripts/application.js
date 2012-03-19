jQuery(function(){
  $(".new-form-button").click(function(){
    var url = $(this).data("url");

    $("#new-form").attr("action", url);
    $("#new-form").submit();
  });
});
