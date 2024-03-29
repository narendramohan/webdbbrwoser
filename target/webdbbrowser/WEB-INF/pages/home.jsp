<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html xmlns="http://www.w3.org/1999/xhtml">

<head>

	<title>Web DB Browser</title>

	<link type="text/css" rel="stylesheet" href="<c:url value="/resources/core/layout-default-latest.css" />" />

	<style type="text/css">

	p {
		font-size:		1em;
		margin:			1ex 0;
	}
	p.buttons {
		text-align:		center;
		line-height:	2.5em;
	}
	button {
		line-height:	normal;
	}
	.hidden {
		display:		none;
	}

	/*
	 *	Rules for simulated drop-down/pop-up lists
	 */
	ul {
		/* rules common to BOTH inner and outer UL */
		z-index:	100000;
		margin:		1ex 0;
		padding:	0;
		list-style:	none;
		cursor:		pointer;
		border:		1px solid Black;
		/* rules for outer UL only */
		width:		15ex;
		position:	relative;
	}
	ul li {
		background-color: #EEE;
		padding: 0.15em 1em 0.3em 5px;
	}
	ul ul {
		display:	none;
		position:	absolute;
		width:		100%;
		left:		-1px;
		/* Pop-Up */
		bottom:		0;
		margin:		0;
		margin-bottom: 1.55em;
	}
	.ui-layout-north ul ul {
		/* Drop-Down */
		bottom:		auto;
		margin:		0;
		margin-top:	1.45em;
	}
	ul ul li		{ padding: 3px 1em 3px 5px; }
	ul ul li:hover	{ background-color: #FF9; }
	ul li:hover ul	{ display:	block; background-color: #EEE; }

	</style>

	<!-- LAYOUT v 1.3.0 -->
	<script type="text/javascript" src="<c:url value="/resources/core/jquery-1.11.1.js" />"></script>
	<script type="text/javascript" src="<c:url value="/resources/core/jquery-ui.js" />"></script>
	<script type="text/javascript" src="<c:url value="/resources/core/jquery.layout-1.3.0.rc30.80.js" />"></script>

	<script type="text/javascript" src="<c:url value="/resources/core/debug.js" />"></script>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

	<script type="text/javascript">

	function toggleLiveResizing () {
		$.each( $.layout.config.borderPanes, function (i, pane) {
			var o = myLayout.options[ pane ];
			o.livePaneResizing = !o.livePaneResizing;
		});
	};
	
	function toggleStateManagement ( skipAlert, mode ) {
		if (!$.layout.plugins.stateManagement) return;

		var options	= myLayout.options.stateManagement
		,	enabled	= options.enabled // current setting
		;
		if ($.type( mode ) === "boolean") {
			if (enabled === mode) return; // already correct
			enabled	= options.enabled = mode
		}
		else
			enabled	= options.enabled = !enabled; // toggle option

		if (!enabled) { // if disabling state management...
			myLayout.deleteCookie(); // ...clear cookie so will NOT be found on next refresh
			if (!skipAlert)
				alert( 'This layout will reload as the options specify \nwhen the page is refreshed.' );
		}
		else if (!skipAlert)
			alert( 'This layout will save & restore its last state \nwhen the page is refreshed.' );

		// update text on button
		var $Btn = $('#btnToggleState'), text = $Btn.html();
		if (enabled)
			$Btn.html( text.replace(/Enable/i, "Disable") );
		else
			$Btn.html( text.replace(/Disable/i, "Enable") );
	};

	// set EVERY 'state' here so will undo ALL layout changes
	// used by the 'Reset State' button: myLayout.loadState( stateResetSettings )
	var stateResetSettings = {
		north__size:		"auto"
	,	north__initClosed:	false
	,	north__initHidden:	false
	,	south__size:		"auto"
	,	south__initClosed:	false
	,	south__initHidden:	false
	,	west__size:			200
	,	west__initClosed:	false
	,	west__initHidden:	false
	,	east__size:			300
	,	east__initClosed:	false
	,	east__initHidden:	false
	};

	var myLayout;

	$(document).ready(function () {

		// this layout could be created with NO OPTIONS - but showing some here just as a sample...
		// myLayout = $('body').layout(); -- syntax with No Options

		myLayout = $('body').layout({

		//	reference only - these options are NOT required because 'true' is the default
			closable:					true	// pane can open & close
		,	resizable:					true	// when open, pane can be resized 
		,	slidable:					true	// when closed, pane can 'slide' open over other panes - closes on mouse-out
		,	livePaneResizing:			true

		//	some resizing/toggling settings
		,	north__slidable:			false	// OVERRIDE the pane-default of 'slidable=true'
		,	north__togglerLength_closed: '100%'	// toggle-button is full-width of resizer-bar
		,	north__spacing_closed:		20		// big resizer-bar when open (zero height)
		,	south__resizable:			false	// OVERRIDE the pane-default of 'resizable=true'
		,	south__spacing_open:		0		// no resizer-bar when open (zero height)
		,	south__spacing_closed:		20		// big resizer-bar when open (zero height)

		//	some pane-size settings
		,	west__minSize:				100
		,	east__size:					300
		,	east__minSize:				200
		,	east__maxSize:				.5 // 50% of layout width
		,	center__minWidth:			100

		//	some pane animation settings
		,	west__animatePaneSizing:	false
		,	west__fxSpeed_size:			"fast"	// 'fast' animation when resizing west-pane
		,	west__fxSpeed_open:			1000	// 1-second animation when opening west-pane
		,	west__fxSettings_open:		{ easing: "easeOutBounce" } // 'bounce' effect when opening
		,	west__fxName_close:			"none"	// NO animation when closing west-pane

		//	enable showOverflow on west-pane so CSS popups will overlap north pane
		,	west__showOverflowOnHover:	true

		//	enable state management
		,	stateManagement__enabled:	true // automatic cookie load & save enabled by default

		,	showDebugMessages:			true // log and/or display messages from debugging & testing code
		});

		// if there is no state-cookie, then DISABLE state management initially
		var cookieExists = !$.isEmptyObject( myLayout.readCookie() );
		if (!cookieExists) toggleStateManagement( true, false );

		myLayout
			// add event to the 'Close' button in the East pane dynamically...
			.bindButton('#btnCloseEast', 'close', 'east')
	
			// add event to the 'Toggle South' buttons in Center AND South panes dynamically...
			.bindButton('.south-toggler', 'toggle', 'south')
			
			// add MULTIPLE events to the 'Open All Panes' button in the Center pane dynamically...
			.bindButton('#openAllPanes', 'open', 'north')
			.bindButton('#openAllPanes', 'open', 'south')
			.bindButton('#openAllPanes', 'open', 'west')
			.bindButton('#openAllPanes', 'open', 'east')

			// add MULTIPLE events to the 'Close All Panes' button in the Center pane dynamically...
			.bindButton('#closeAllPanes', 'close', 'north')
			.bindButton('#closeAllPanes', 'close', 'south')
			.bindButton('#closeAllPanes', 'close', 'west')
			.bindButton('#closeAllPanes', 'close', 'east')

			// add MULTIPLE events to the 'Toggle All Panes' button in the Center pane dynamically...
			.bindButton('#toggleAllPanes', 'toggle', 'north')
			.bindButton('#toggleAllPanes', 'toggle', 'south')
			.bindButton('#toggleAllPanes', 'toggle', 'west')
			.bindButton('#toggleAllPanes', 'toggle', 'east')
		;


		/*
		 *	DISABLE TEXT-SELECTION WHEN DRAGGING (or even _trying_ to drag!)
		 *	this functionality will be included in RC30.80
		 */
		$.layout.disableTextSelection = function(){
			var $d	= $(document)
			,	s	= 'textSelectionDisabled'
			,	x	= 'textSelectionInitialized'
			;
			if ($.fn.disableSelection) {
				if (!$d.data(x)) // document hasn't been initialized yet
					$d.on('mouseup', $.layout.enableTextSelection ).data(x, true);
				if (!$d.data(s))
					$d.disableSelection().data(s, true);
			}
			//console.log('$.layout.disableTextSelection');
		};
		$.layout.enableTextSelection = function(){
			var $d	= $(document)
			,	s	= 'textSelectionDisabled';
			if ($.fn.enableSelection && $d.data(s))
				$d.enableSelection().data(s, false);
			//console.log('$.layout.enableTextSelection');
		};
		$(".ui-layout-resizer")
			.disableSelection() // affects only the resizer element
			.on('mousedown', $.layout.disableTextSelection ); // affects entire document

		 $("#newconnection").click(function(){
			    $("#div1").toggle();
			  });
 	});
	</script>


</head>
<body>

<!-- manually attach allowOverflow method to pane -->
<div class="ui-layout-north" onmouseover="myLayout.allowOverflow('north')" onmouseout="myLayout.resetOverflow(this)">
	This is the north pane, closable, slidable and resizable

	<ul>
		<li>
			<ul>
				<li>one</li>
				<li>two</li>
				<li>three</li>
				<li>four</li>
				<li>five</li>
			</ul>
			Drop-Down <!-- put this below so IE and FF render the same! -->
		</li>
	</ul>

</div>

<!-- allowOverflow auto-attached by option: west__showOverflowOnHover = true -->
<div class="ui-layout-west">
	This is the west pane, closable, slidable and resizable
<button onclick="debugData(myLayout.options.west)">West Options</button>
<button id="newconnection"><b>+</b></button>
<div id="newConnection">
	<table>
	<tr><td>User Name</td><td><input type="text" name="userName"></td>	</tr>
	<tr><td>User Password</td><td><input type="text" name="Password"></td>	</tr>
	<tr><td>db URL</td><td><input type="text" name="dbURL"></td>	</tr>
	<tr><td colspan="2"><button id="newconSubmit">Submit</button></td>	</tr>
	</table>
</div>
	<ul>
		<li>
			<ul>
				<li>one</li>
				<li>two</li>
				<li>three</li>
				<li>four</li>
				<li>five</li>
			</ul>
			Pop-Up <!-- put this below so IE and FF render the same! -->
		</li>
	</ul>

	<p><button onclick="myLayout.close('west')">Close Me</button></p>

</div>

<div class="ui-layout-south">
	This is the south pane, closable, slidable and resizable &nbsp;

	<!-- this button has its event added dynamically in document.ready -->
	<button class="south-toggler">Toggle This Pane</button>
</div>

<div class="ui-layout-east">
	This is the east pane, closable, slidable and resizable

	<!-- attach allowOverflow method to this specific element -->
	<ul onmouseover="myLayout.allowOverflow(this)" onmouseout="myLayout.resetOverflow('east')">
		<li>
			<ul>
				<li>one</li>
				<li>two</li>
				<li>three</li>
				<li>four</li>
				<li>five</li>
			</ul>
			Pop-Up <!-- put this below so IE and FF render the same! -->
		</li>
	</ul>

	<!-- this button has its event added dynamically in document.ready -->
	<p><button id="btnCloseEast">Close Me</button></p>

	<p><select>
		<option value="19">Picklist Test</option>
		<option value="17">tropical storm</option>
		<option value="18">hurricane</option>
		<option value="19">severe thunderstorms</option>
		<option value="20">thunderstorms</option>
		<option value="21">mixed rain and snow</option>
		<option value="22">mixed rain and sleet</option>
		<option value="23">mixed snow and sleet</option>
		<option value="24">freezing drizzle</option>
		<option value="25">drizzle</option>
		<option value="26">freezing rain</option>
		<option value="27">showers</option>
		<option value="28">showers</option>
		<option value="29">snow flurries</option>
		<option value="30">light snow showers</option>
		<option value="31">blowing snow</option>
		<option value="32">snow</option>
		<option value="33">hail</option>
		<option value="34">sleet</option>
		<option value="35">dust</option>
		<option value="36">foggy</option>
		<option value="37">haze</option>
		<option value="38">smoky</option>
		<option value="39">blustery</option>
		<option value="40">windy</option>
		<option value="41">cold</option>
		<option value="42">cloudy</option>
		<option value="43">mostly cloudy (night)</option>
		<option value="44">mostly cloudy (day)</option>
		<option value="45">partly cloudy (night)</option>
		<option value="46">partly cloudy (day)</option>
		<option value="47">clear (night)</option>
		<option value="48">sunny</option>
		<option value="49">fair (night)</option>
		<option value="50">fair (day)</option>
		<option value="51">mixed rain and hail</option>
		<option value="52">hot</option>
		<option value="53">isolated thunderstorms</option>
		<option value="54">scattered thunderstorms</option>
		<option value="55">scattered thunderstorms</option>
		<option value="56">scattered showers</option>
		<option value="57">heavy snow</option>
		<option value="58">scattered snow showers</option>
		<option value="59">heavy snow</option>
		<option value="60">partly cloudy</option>
		<option value="61">thundershowers</option>
		<option value="62">snow showers</option>
		<option value="63">isolated thundershowers</option>
	</select></p>

	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
</div>

<div class="ui-layout-center">
	This CENTER pane auto-sizes to fit the space <i>between</i> the 'border-panes'
	<p>This layout was created with only <b>default options</b> - no customization</p>
	<p>Only the <b>applyDefaultStyles</b> option was enabled for <i>basic</i> formatting</p>
	<p>The Close buttons in East/West panes and the buttons below are examples of <b>custom buttons</b></p>

	<p><a href="http://layout.jquery-dev.com/demos.html"><b>Go to the Demos page</b></a></p>

	<p class="buttons">
		<!-- these buttons have event added dynamically in document.ready -->
		<button id="openAllPanes">Open All Panes</button>
		&nbsp;
		<button id="closeAllPanes">Close All Panes</button>
		&nbsp;
		<button id="toggleAllPanes">Toggle All Panes</button>
	</p>

	<p class="buttons">
		<button onclick="myLayout.toggle('north')">Toggle North Pane</button>
		&nbsp;
		<!-- this button has its event added dynamically in document.ready -->
		<button class="south-toggler">Toggle South Pane</button>
	</p>

	<p class="buttons">
		<button onclick="myLayout.hide('east')">Hide East Pane</button>
		&nbsp;
		<button onclick="myLayout.show('east', false)">Unhide East (Closed)</button>
		&nbsp;
		<button onclick="myLayout.show('east')">Unhide East (Open)</button>
	</p>

	<p class="buttons">
		<button onclick="toggleLiveResizing()">Toggle Live-Resizing (all panes)</button>
		&nbsp;
		<button id="btnToggleState" onclick="toggleStateManagement()">Disable State Cookie</button>
		&nbsp;
		<button id="btnReset" onclick="myLayout.loadState(stateResetSettings, true)">Reset State</button>
	</p>

	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
	<p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p><p>...</p>
</div>

</body>
</html>