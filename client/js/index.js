$(function () {
  
function request () {

  $.get(path, function(result) {
    var i;
    path = result.newPath;
    if (result.datas) {
      for (i = 0; i < result.datas.length; i++) {
        render(result.datas[i].data)
      }
    }
    request ()
  });

}

request();

//scrollDown();

var render = function (obj) {
  var toggle, item;
  toggle = $('<div>').text(obj.item.cwbopendata.identifier[0] + ' (' + obj.name + ')');
  item = $('<pre>').text(JSON.stringify(obj, null, 2));
  toggle.on('click', function () {
    item.slideToggle();
  });
  item.hide();
  $('body').append(toggle).append(item);
}

datas.forEach(function (i) {
  render(i);
});

});