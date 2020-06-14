// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$('a[data-remote=true]').livequery('click', function() {
    $.ajax({ 
      url: this.href, 
      dataType: "script"
    }); 
    return false; 
});

$('form[data-remote=true]').livequery('submit', function() {
  return request({ url : this.action, type : this.method, data : $(this).serialize() });
});

$(function() {
  $(".alert").click(function() {
    alert(this.getAttribute("data-confirm"));
    return false;
  })
})

//styling edit fields
function inputFocus(i){
    if(i.value==i.defaultValue){ i.value=""; i.style.color="#000"; }
}
function inputFocusNoClear(i){
    if(i.value==i.defaultValue){ i.style.color="#000"; }
}
function inputFocusPassword(i){
    if(i.value==i.defaultValue){ i.type="password"; i.value=""; i.style.color="#000"; }
}
function inputBlur(i){
    if(i.value==""){ i.type="text"; i.value=i.defaultValue; i.style.color="#888"; }
}
function inputMouseOver(i){
    if(i.value==i.defaultValue){ i.style.color="#666"; }
}
function inputMouseOut(i){
    if(i.value==i.defaultValue){ i.style.color="#888"; }
}

