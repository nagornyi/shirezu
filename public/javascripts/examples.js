<span id="email" style="display:none;"><%="#{current_user.email}"%></span>

<span id="timezones" style="display:none;"><%=select_tag('usrTimeZone', options_for_select(TZInfo::Timezone.all, Profile.find(@current_user.profile_id).read_attribute(:time_zone)))%></span>

<% ff.time_zone_select(:time_zone, TZInfo::Timezone.all_identifiers, :default => "UTC", :model => TZInfo::Timezone) %>

<%= button_to 'New User', {:controller => :users, :action => :new}, :class => 'ui-state-default like_button' %>

function checkPswChanged(){
	if ($('#user_password').val() == "Password"){
		alert("asd");
	} else {
		alert($('#user_password').val());
	}
}

when 'get_time_zone'
	message << (Profile.find(@current_user.profile_id).read_attribute(:time_zone))

function getTimezones() {
	var h = document.getElementById("timezones");
	return h.innerHTML;
};

function editProfile1() {
		var tz = getTimezones();
		var txt = "<table><tr><td>Time Zone<\/td><\/tr><tr><td>"+tz+"<\/td><\/tr><\/table>";

		function mycallbackform(v,m,f){
			if(v == 'Submit')
			submitResource("{'time_zone':'" + f.usrTimeZone + "','oper':'edit_profile'}");
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
};

