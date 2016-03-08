// jQuery expression for case-insensitive filter
$.extend($.expr[":"], {
    "contains-ci": function (elem, i, match, array) {
        return (elem.textContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
    }
});

console.log("JS here!");

var perform = function(){

  var txtVal = $(this).val();
  console.log(txtVal);
  if (txtVal != "") {
      $(".countryrow").show();
      $(".message").remove();
      $.each($('.countryrow'), function (i, o) {
          var match = $("td:contains-ci('" + txtVal + "')", this);
          if (match.length > 0) $(match).parent("tr").show();
          else $(this).hide();
      });
  } else {
      // When there is no input or clean again, show everything back
      $("tbody > tr", this).show();
  }
  if($('.countryrow:visible').length == 0)
  {
      $('#search').after('<p class="message">No locations with that name..</p>');
  }

};

$("#search").keyup(function () {
  perform();
});
