--------------------------------------------------------
--  DDL for Package Body JS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JS" as
/* $Header: ICXJAVAB.pls 120.1 2005/10/07 13:25:12 gjimenez noship $ */


procedure numeric_characters is

l_decimal varchar2(30);
l_group varchar2(30);

begin

l_decimal := substrb(icx_sec.g_numeric_characters,1,1);
l_group := substrb(icx_sec.g_numeric_characters,2,1);

htp.p('var g_group = new Array();');
htp.p('var g_integer = new Boolean(true)');

htp.p('function con(x) {
           var y = "";
           var decimal = x.length;
           var group = 0;

           for (var i = x.length; i >= 0; i--)
               if (x.charAt(i) == '''||l_decimal||''') {
                 y = "." + y;
                 decimal = i;
                 g_integer = false;
                 }
               else
                 if (x.charAt(i) != '''||l_group||''')
                   y = x.charAt(i) + y;
                 else
                   if (group++ == g_group.length)
                     g_group[group-1] = decimal - i;
           return y;
        }');

htp.p('function decon(x) {
           var y = "";
           var decimal = 0;
           var group = 0;
           var count = x.length;

           if (g_integer)
             decimal = x.length;

           for (var i = x.length; i >= 0; i--) {
               if (x.charAt(i) == ''.'') {
                 y = "'||l_decimal||'" + y;
                 decimal = i;
                 }
               else {
                 if (count == decimal - g_group[group]) {
                   y = "'||l_group||'" + y;
                   group++;
                   count--;
                   }
                 y = x.charAt(i) + y;
                 };
               count--;
               };
           g_integer = true;

           return y;
        }');
end;

/*************function scriptOpen*****************************************/
  function scriptOpen return varchar2 is

     begin
	return ('<SCRIPT LANGUAGE="JavaScript">

<!-- hide the script''s contents from feeble browsers');

     end;

/*************procedure start_script*****************************************/
  procedure scriptOpen is
      begin
	htp.p(js.scriptOpen);
      end;

/*************function end_script   *****************************************/
  function scriptClose return varchar2 is
      begin
	return ('<!-- done hiding from old browsers -->

</SCRIPT>');
      end;

/*************procedure end_script   *****************************************/
  procedure scriptClose is
      begin
	htp.p(js.scriptClose);
      end;

/*************function formOpen      *****************************************/
  function formOpen return varchar2 is
     begin
	return('<FORM>');
     end;

/*************procedure formOpen     *****************************************/
  procedure formOpen is
     begin
	htp.p(js.formOpen);
     end;

/*************procedure dynamicButton     ************************************/
  procedure dynamicButton is

  l_DisabledColor varchar2(7) := '#999999';
  c_browser varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');

  PROCEDURE doc (P_text varchar2) IS
  BEGIN
      htp.p('document.write('||P_text||');');
  END;

BEGIN

htp.p('function dynamicButton(p_text,p_alt,p_over,p_language,p_image,p_url,p_flag) {');

  htp.p('var l_image_path = "/OA_MEDIA/" ');

  doc('"<table border=0 cellpadding=0 cellspacing=0 valign=TOP align=left>"');

  htp.p('if (p_text != "") {');
  doc('"<tr><td height=28 width=29 rowspan=5>"');
  htp.p('} else {');
  doc('"<tr><td height=28 width=5>"');
  htp.p('}');

  htp.p('if (p_url != "") {');
  doc('"<a href=" + p_url + " onMouseOver=\"window.status=''" + p_over + "''; return true\">"');
  doc('"<img src=" + l_image_path + p_image + " align=CENTER height=28 width=29 border=0 alt=" + p_alt + "></a></td>"');
  htp.p('} else {');
  doc('"<img src=" + l_image_path + p_image + " align=CENTER height=28 width=29 border=0 alt=" + p_alt + "></td>"');
  htp.p('}');

  htp.p('if (p_text != "") {');
  doc('"<td height=1 bgcolor=#CCCCCC><img height=1 width=1 src=" + l_image_path + "FNDDBPXC.gif alt=" + p_alt + "></td>"');
  doc('"<td height=28 width=29 rowspan=5>"');
  htp.p('} else {');
  doc('"<td height=28 width=5>"');
  htp.p('}');

  htp.p('if (p_url != "") {');
  doc('"<a href=" + p_url + " onMouseOver=\"window.status=''" + p_over + "''; return true\">"');
  doc('"<img src=" + l_image_path + "FNDDBEND.gif border=0 height=28 width=7 align=CENTER alt=" + p_alt + "></a></td></tr>"');
  htp.p('} else {');
  doc('"<img src=" + l_image_path + "FNDDBEND.gif border=0 height=28 width=7 align=CENTER alt=" + p_alt + "></td></tr>"');
  htp.p('}');

  htp.p('if (p_text != "") {');
  doc('"<tr><td height=1 bgcolor=#FFFFFF>"');
  doc('"<img src=" + l_image_path + "FNDDBPXW.gif width=1 height=1 alt=" + p_alt + "></td></tr>"');
  doc('"<tr align=CENTER valign=MIDDLE><td height=24 valign=MIDDLE bgcolor=#cccccc nowrap>"');
    htp.p('if (p_url != "") {');
        doc('"<a href=" + p_url + " valign=MIDDLE onMouseOver=\"window.status=''" + p_over + "''; return true\">"');
    htp.p('}');

    htp.p('if (p_flag == "TRUE") {');
        doc('"<font color='||l_DisabledColor||'>" + p_text + "</font>"');
        htp.p('if (p_url != "") {');
            doc('"</a></td></tr>"');
        htp.p('} else {');
            doc('"</td></tr>"');
        htp.p('}');
    htp.p('} else {');
        doc('"<font color=#000000>" + p_text + "</font>"');
        htp.p('if (p_url != "") {');
            doc('"</a></td></tr>"');
        htp.p('} else {');
            doc('"</td></tr>"');
        htp.p('}');
    htp.p('}');

    doc('"<tr><td height=1 bgcolor=#999999>"');
    doc('"<img src=" + l_image_path + "FNDDBPX9.gif width=1 height=1 alt=" + p_alt + "></td></tr>"');
    doc('"<tr><td height=1 bgcolor=#000000>"');
    doc('"<img src=" + l_image_path + "FNDDBPXB.gif width=1 height=1 alt=" + p_alt + "></td></tr>"');
  htp.p('}');

  doc('"</table>"');

htp.p('}');

END;

/*************procedure money_decimal*****************************************/
  procedure money_decimal(precision number) is
      begin
	htp.p('function AddDecimal(number) {
  var withdecimal = "";
  var expp = Math.pow(10, ' || precision || ');
  var num = "" + Math.round(number*expp);
  if (num.length == 0) {
    withdecimal += "0";
    if (' || precision || ' > 0) {
       withdecimal += ".";
       for (var i=0; i < ' || precision || '; i++) {
           withdecimal += "0";
       }
    }
  } else if (num.length <= ' || precision || ') {
    withdecimal += "0.";
    for (var k = 0; k < (' || precision || ' - num.length); k++) {
	withdecimal += "0";
    }
    withdecimal += num;
  } else {
    if (' || precision || ' > 0) {
       withdecimal += num.substring(0, num.length - ' || precision || ');
       withdecimal += "."
       withdecimal += num.substring(num.length - ' || precision ||
	    	 ', num.length);
    } else {
      withdecimal += "num";
    }
  }

  return withdecimal;
}
');

     end;


/*************function button      *****************************************/

function button (name varchar2, value varchar2, onClick varchar2)
	return varchar2 is

  begin
     if onClick is not null then
        return('<INPUT TYPE="button" VALUE="' || value || '" NAME="' ||
	        name || '" onClick="' || '">');
     else
        return('<INPUT TYPE="button" VALUE="' || value || '" NAME="' ||
	        name || '">');
     end if;
  end;

/*************procedure  button      *****************************************/
procedure button (name varchar2, value varchar2, onClick varchar2) is

  begin
    htp.p(js.button(name, value, onClick));
  end;

/*************function checkbox     *****************************************/
  function checkbox (name varchar2, value varchar2, onClick varchar2,
                     checked boolean) return varchar2 is

   ccheck varchar2(10);

   begin
     if checked then
	ccheck := ' CHECKED ';
     else
	ccheck := null;
     end if;
     if onClick is not null then
        return('<INPUT TYPE="checkbox" VALUE="' || value || '" NAME="' ||
                name || '" onClick="' || '"' || ccheck || '>');
     else
        return('<INPUT TYPE="checkbox" VALUE="' || value || '" NAME="' ||
                name || '"' || ccheck || '>');
     end if;
   end;


/*************procedure checkbox     *****************************************/
  procedure checkbox (name varchar2, value varchar2, onClick varchar2,
                     checked boolean)  is

  begin
    htp.p(js.checkbox(name, value, onClick, checked));
  end;

/*************function text         *****************************************/
  function text (name varchar2, value varchar2,
                 sizze integer, onBlur varchar2, onChange varchar2,
                 onFocus varchar2, onSelect varchar2) return varchar2 is

    def_val    varchar2(100);
    V_onBlur   varchar2(300);
    V_onChange varchar2(300);
    V_onFocus  varchar2(300);
    V_onSelect varchar2(300);

  begin

    if value is not null then
       def_val := ' VALUE="' || value || '" ';
    else
       def_val := null;
    end if;

    if onBlur is not null then
       V_onBlur := ' onBlur = "' || onBlur || '" ';
    else
       V_onBlur := null;
    end if;

    if onChange is not null then
       V_onChange := ' onChange = "' || onChange || '" ';
    else
       V_onChange := null;
    end if;

    if onFocus is not null then
       V_onFocus := ' onFocus = "' ||  onFocus || '" ';
    else
       V_onFocus := null;
    end if;

    if onSelect is not null then
       V_onSelect := ' onSelect = "' ||  onSelect || '" ';
    else
       V_onSelect := null;
    end if;

    return('<INPUT TYPE="text" NAME="' || name || '" SIZE="' || sizze ||
           '"' || def_val || V_onBlur || V_onChange || V_onFocus ||
	   V_onSelect || '>');
   end;

/************procedure text         ******************************************/

  procedure text (name varchar2, value varchar2,
                 sizze integer, onBlur varchar2, onChange varchar2,
                 onFocus varchar2, onSelect varchar2) is

  begin
    htp.p(js.text(name, value, sizze, onBlur, onChange, onFocus, onSelect));
  end;

/*************procedure arrayCreate  *****************************************/
  procedure arrayCreate is

  begin
    htp.p('function MakeArray(n) {
   this.length = n;
   for (var i = 1; i <= n; i++)
     this[i] = 0;
   return this;
}
');

  end;

/*************procedure checkNumber  *****************************************/

  procedure checkNumber is

  begin
  fnd_message.set_name('ICX','ICX_NOT_NUMBER');
    htp.p('function checkNumber(input) {
  var msg = input.value + " '||icx_util.replace_quotes(fnd_message.get)||'";

  var str = input.value;
  for (var i = 0; i < str.length; i++) {
      var ch = str.substring(i, i + 1);
      if ((ch < "0" || "9" < ch) && ch != ".") {
	 alert(msg);
	 return false;
      }
   }
   return true;
}
');

  end;

/*************procedure replaceDbQuote**************************************/

  procedure replaceDbQuote is

  begin
    htp.p('function replaceDbQuote(input) {
    var quote = "\"";
    var srt = input.value;
    var retStr = "";

    for (var i = 0; i < str.length; i++) {
        var ch = str.substring(i, i + 1);
	if (ch == quote) {
	   retStr += quote + ch;
	} else {
	   retStr += ch;
	}
    }
    return retStr;
}
');

  end;
/*************procedure checkValue *****************************************/

  procedure checkValue is

  begin
    fnd_message.set_name('ICX','ICX_NOT_NUMBER');
    htp.p('function checkValue(input) {
  var msg = input + " '||icx_util.replace_quotes(fnd_message.get)||'";
  var str = input;
  var space = true;
  var x = 0;
  for (var i = 0; i < str.length; i++) {
      var ch = str.substring(i, i + 1);
      if ((ch != " ") && (space = true)) {
	  space = false;
	  x = 1;
	  }
      if ((x = 1) && (space = false)) {
          if (((ch < "0") || ("9" < ch)) && (ch != ".") && (ch != "-")) {
              alert(msg);
              return false;
              }
          else {
	      x = 2;
	      }
          }
      if ((x != 1) && (space = false)) {
          if (((ch < "0") || ("9" < ch)) && (ch != ".")) {
              alert(msg);
              return false;
          }
       }
   }
   return true;
   }');

  end;


/*************procedure checkValue *****************************************/
  procedure checkValuePos is

  begin
    fnd_message.set_name('ICX','ICX_NOT_NUMBER');
    htp.p('function checkValue(input) {
  var msg = input + " '||icx_util.replace_quotes(fnd_message.get)||'";

  var str = input;
  for (var i = 0; i < str.length; i++) {
      var ch = str.substring(i, i + 1);
          if (((ch < "0") || ("9" < ch)) && (ch != ".")) {
              alert(msg);
              return false;
          }
   }
   return true;
}
');

end;



/*********************** procedure null_alert *****************/
/* This is a generic procedure that displays a javascript alert
   and returns true if the value parameter is null, otherwise it
   returns false                                              */

procedure null_alert is

begin
    htp.p('function null_alert(value,alert_text) {
        if (value == "")
            {
                alert(alert_text)
                return true
            } else
                return false
          }');
end;



/*********************** procedure spaces_alert *****************/
/* This is a generic procedure that displays a javascript alert
   and returns true if the value parameter contains spaces,
   otherwise it returns false                                    */

procedure spaces_alert is

begin
    htp.p('function spaces_alert(value,alert_text) {
        for (var i=0;i < value.length; i++) {
        var ch = value.substring(i, i+1)
          if (ch == " ")
              {
                  alert(alert_text)
                  return true
              }
        }
        return false
        }');
end;


/*********************** procedure equal_alert *****************/
-- equal_alert place a javascript function in the html header
-- This is a generic function that accepts three parameters
-- The function will display a javascript alert and return true
-- if the first two parameters are equal
procedure equal_alert is

begin
    htp.p('function equal_alert(value,value2,alert_text) {
	if (value == value2) {
            alert(alert_text)
            return true
	  }
        }');
end;






/*********************** procedure format number*****************/
/* This procedure should be used when displaying numbers.  All number
   columns should be read in AMERICAN territory (So we get periods
   instead of commas.  Then on display call this function.      */

 procedure format_number is
   cursor getDivider is
	SELECT substr(VALUE, 1, 1) from v$nls_parameters where value like '%.%';

   v_divider varchar2(10);

begin

  open getDivider;
  fetch getDivider into v_divider;
  close getDivider;

  htp.p('function formatNumber(input) {');
  if v_divider = '.' then
	htp.p('return input;
}');
  else
        htp.p(' var str = input;
  var retStr = "";
  for (var i = 0; i < str.length; i++) {
      if (ch == ".") {
	 retStr += "' || v_divider || '";
      } else {
	 retStr += ch;
      }
  }
  return retStr;
}
');
  end if;
end;



end js;

/
