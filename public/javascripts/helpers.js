function submitResource(path, data, grid) {
$.ajax({
  type: "POST",
  url: path,
	data: data,
  contentType: 'application/json', // format of request payload
  dataType: 'json', // format of the response
	success: function (request, status, error) {
		if(jQuery.parseJSON(error.responseText)[1]!='ok') {
			$.prompt("<div class=\"errornotice\">Warning<\/div>"+jQuery.parseJSON(error.responseText)[1]);
		}
		if(grid!=0) { $(grid).trigger("reloadGrid"); }
	},
  });
};

function editProfile() {
$.ajax({
  type: "POST",
  url: "helpers/post_data",
	data: "{'oper':'get_time_zones'}",
  contentType: 'application/json', // format of request payload
  dataType: 'json', // format of the response
	success: function (request, status, error) {

		var tz = jQuery.parseJSON(error.responseText)[1];
		var txt = "<table><tr><td>Time Zone<\/td><\/tr><tr><td>"+tz+"<\/td><\/tr><\/table>";

		function mycallbackform(v,m,f){
			if(v == 'Submit')
			submitResource("helpers/post_data", "{'time_zone':'" + f.usrTimeZone + "','oper':'edit_profile'}", 0);
		}

		function mysubmitfunc(v,m,f){
			if(f.usrTimeZone == "" && v == "Submit"){
				document.getElementById("usrTimeZone").style.border = "solid #ff0000 2px";
				return false;
			}
			return true;
		}

		$.prompt(txt,{
			submit: mysubmitfunc,
			callback: mycallbackform,
			buttons: { Submit: 'Submit', Cancel: 'Cancel' }
		});

	},
  });
};

function editProfileAsCompAdmin() {
$.ajax({
  type: "POST",
  url: "helpers/post_data",
	data: "{'oper':'get_data'}",
  contentType: 'application/json', // format of request payload
  dataType: 'json', // format of the response
	success: function (request, status, error) {

		var tz = jQuery.parseJSON(error.responseText)[1].split(",")[0];
    var compName = jQuery.parseJSON(error.responseText)[1].split(",")[1];
		var txt = "<table><tr><td>Time Zone<\/td><\/tr><tr><td>"+tz+"<\/td><\/tr><tr><td>Company Name<\/td><\/tr><tr><td><input type=\"text\" id=\"compName\" name=\"compName\" value=\"" + compName + "\" \/><\/td><\/tr><\/table>";

		function mycallbackform(v,m,f){
			if(v == 'Submit')
			submitResource("helpers/post_data", "{'time_zone':'" + f.usrTimeZone + "','comp_name':'" + f.compName + "','oper':'edit_profile_as_comp_admin'}", 0);
		}

		function mysubmitfunc(v,m,f){
			if(f.usrTimeZone == "" && v == "Submit"){
				document.getElementById("usrTimeZone").style.border = "solid #ff0000 2px";
				return false;
			}
      if(f.compName == "" && v == "Submit"){
				document.getElementById("compName").style.border = "solid #ff0000 2px";
				return false;
			}
      document.getElementById("headerCompname").innerHTML=document.getElementById("compName").value
			return true;
		}

		$.prompt(txt,{
			submit: mysubmitfunc,
			callback: mycallbackform,
			buttons: { Submit: 'Submit', Cancel: 'Cancel' }
		});

	},
  });
};
