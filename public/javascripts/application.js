jQuery(function(){
  $(".form-action").click(function(){
    var url = $(this).data("url");

    $("#new-form").attr("action", url);
    $("#new-form").submit();
  });

  $(".preview-toggle").click(function(){
    $.post("/preview", $("#new-form").serialize(), function(data) {
      $("#preview").html(data);
    });
  });

  $(".compose-toggle").click(function(){
    $("#preview").html("<img src='/images/rendering.gif' alt='rendering'/>");
  });

  $("[data-confirm]").click(function(){
    if (!confirm($(this).data("confirm"))) {
      return false;
    }
  });
});
