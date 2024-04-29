--------------------------------------------------------
--  DDL for Package Body XNP_WSGJSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WSGJSL" as
/* $Header: XNPWSJSB.pls 120.0 2005/05/30 11:46:54 appldev noship $ */


---------------------
   function OpenScript return varchar2 is
   begin
      return '<SCRIPT>
<!-- Hide from old browsers';
   end;
---------------------
   function CloseScript return varchar2 is
   begin
      return '//-->
</SCRIPT>';
   end;
---------------------
   function OpenEvent(p_alias in varchar2, p_event in varchar2) return varchar2 is
   begin
      return 'function '||p_alias||'_'||p_event||'(ctl) {';
   end;
---------------------
   function CloseEvent return varchar2 is
   begin
      return '   return true;
}';
   end;
---------------------
   function CallEvent(p_alias in varchar2, p_event in varchar2) return varchar2 is
   begin
      return '   if (!'||p_alias||'_'||p_event||'(document.forms[0].P_'||p_alias||')) { return false; }';
   end;
---------------------
   function CallValidate(p_alias in varchar2) return varchar2 is
   begin
      return '   if (!'||p_alias||'_Validate()) { return false; }';
   end;
---------------------
   function RtnNotNull return varchar2 is
   begin
      return 'function JSLNotNull(pctl, pmsg){
   if (pctl.value == "") { alert(pmsg); pctl.focus(); return false; }
   return true;
}';
   end;
---------------------
   function RtnCheckRange return varchar2 is
   begin
      return 'function JSLCheckRange(pctl, pval, pstyle, plowval, phival, pmsg) {
   var lval = "" + pval;
   if (lval <> "") {
     var ctlval = parseInt(lval);
     if (pstyle == 1) { // full range
       if ( (ctlval < plowval) || (ctlval > phival)) { alert(pmsg); pctl.focus(); return false; }
     }
     if (pstyle == 2) { // check low value
       if (ctlval < plowval) { alert(pmsg); pctl.focus(); return false; }
     }
     if (pstyle == 3) { // check high value
       if (ctlval > phival) { alert(pmsg); pctl.focus(); return false; }
     }
   }
   return true;
}';
   end;
---------------------
   function RtnChkMaxLength return varchar2 is
   begin
      return 'function JSLChkMaxLength(pctl, plen, pmsg) {
   if (pctl.value.length > plen) {
     alert(pmsg);
     pctl.focus();
     return false;
   }
     return true;
}';
   end;
---------------------
   function RtnChkNumScale return varchar2 is
   begin
      return 'function JSLChkNumScale (pctl, pval, pscale, pmsg) {
  if (pval <> "") {
    var PointPos = pval.indexOf(".");
    if (PointPos <> -1) {
      var Scale = pval.length - PointPos - 1;
      if (Scale > pscale) {
        alert(pmsg);
        pctl.focus();
        return false;
      }
    }
  }
  return true;
}';
   end;
---------------------
   function RtnChkNumPrecision return varchar2 is
   begin
      return 'function JSLChkNumPrecision(pctl, pval, pprecision, pmsg) {
  if (pval <> "") {
    var Prec = 0;
    var PointPos = pval.indexOf(".");
    // If a decimal point was not found
    // validate the number of digits in the whole string
    if (PointPos == -1) {
      Prec = pval.length;
    }
    else {  // Validate the number of digits before the decimal point
      Prec = PointPos;
    }

    if (Prec > pprecision) { alert(pmsg); pctl.focus(); return false; }
  }
   return true;
}';
   end;
---------------------
   function RtnStripMask return varchar2 is

      L_DECIMAL varchar2(10) := substr(to_char(1.0, '9D9'), 3, 1);
      L_GROUP_SEP varchar2(10) := substr(to_char(1000, '9G999'), 3, 1);
      L_ISO_CURR varchar2(10) := rtrim(ltrim(to_char(1, 'C9999')),'1');
      L_LOCAL_CURR varchar2(10) := rtrim(ltrim(to_char(1, 'L9999')),'1');
      L_RETURN_STRING varchar2(2000) := null;

   begin

      if L_DECIMAL = '\' then
         L_DECIMAL := '\\';
      end if;
      if L_GROUP_SEP = '\' then
         L_GROUP_SEP := '\\';
      end if;
      if L_ISO_CURR = '\' then
         L_ISO_CURR := '\\';
      end if;
      if L_LOCAL_CURR = '\' then
         L_LOCAL_CURR := '\\';
      end if;

      L_RETURN_STRING := 'function JSLStripMask(p_val) {
  if (p_val == "") { return ""; }
  var str = p_val;
  str = JSLReplace(str, " ");';

      if L_GROUP_SEP <> ',' then
         L_RETURN_STRING := L_RETURN_STRING || '
  str = JSLReplace(str, "'||L_GROUP_SEP||'");';
      end if;

       if L_LOCAL_CURR <> '$' then
         L_RETURN_STRING := L_RETURN_STRING || '
  str = JSLReplace(str, "'||L_LOCAL_CURR||'");';
      end if;

  -- BUG 566078 9-JAN-98 Moved Decimal handling to after group separator and currency handling

      if L_DECIMAL <> '.' then
         L_RETURN_STRING := L_RETURN_STRING || '
  str = JSLReplace(str, "'||L_DECIMAL||'", ".");';
      end if;

  -- end BUG 566078 9-JAN-98

      L_RETURN_STRING := L_RETURN_STRING || '
  str = JSLReplace(str, ",");
  str = JSLReplace(str, "$");
  str = JSLReplace(str, "'||L_ISO_CURR||'");

  if ((str.substring(0, 1) == "<") && (str.substring(str.length -1, str.length) == ">")) {
      str = "-" + str.substring(1, str.length - 1);
  }
  if (str.substring(str.length -1, str.length) == "-") {
    str = "-" + str.substring(0, str.length - 1);
  }
  if (str.substring(str.length -1, str.length) == "+") {
    str = str.substring(0, str.length - 1);
  }
  return str;
}';

      return L_RETURN_STRING;

   end;
---------------------
   function RtnToNumber return varchar2 is
   begin
      return 'function JSLToNumber(p_val) {
   var lval = JSLStripMask(p_val);
   if (lval == "") { return ""; }
   else { return parseFloat(lval); }
}';
   end;
---------------------
   function RtnMakeUpper return varchar2 is
   begin
      return 'function JSLMakeUpper(pctl) {
   pctl.value = pctl.value.toUpperCase();
}';
   end;
---------------------
   function RtnChkConstraint return varchar2 is
   begin
      return 'function JSLChkConstraint(pconstraint, pmsg) {
   if (!(pconstraint)) { alert(pmsg); return false; }
     return true;
}';
   end;
---------------------
   function RtnRadioValue return varchar2 is
   begin
      return 'function JSLRadioValue(pctl) {
   var i;
   for (i=0;i<pctl.length;i++) {
      if (pctl[i].checked) {
         return pctl[i].value;
      }
   }
   return "";
}';
   end;
---------------------
   function RtnGetValue return varchar2 is
   begin
      return 'function JSLGetValue(pctl, ptype, pfalse) {
   var i = 0;
   if (ptype == null) { return pctl.value; }
   if (ptype == "CHECK") {
      if (pctl.checked) { return pctl.value; }
      else { return pfalse; }
   }
   if (ptype == "RADIO") {
      for (i=0;i<pctl.length;i++) {
         if (pctl[i].checked) { return pctl[i].value; }
      }
      return "";
   }
   if (ptype == "LIST") {
      if (pctl.selectedIndex >= 0) {
         if (pctl.options[pctl.selectedIndex].value <> "") {
            return pctl.options[pctl.selectedIndex].value;
         }
         else { return pctl.options[pctl.selectedIndex].text; }
      }
      else { return ""; }
   }
}';
   end;
---------------------
   function RtnConcat return varchar2 is
   begin
      return 'function JSLConcat(pstr1, pstr2) {
   if (pstr1 == null) { return ""; }
   if (pstr2 == null) { return pstr1; }
   return (pstr1 + pstr2);
}';
   end;
---------------------
   function RtnInitCap return varchar2 is
   begin
      return 'function JSLInitCap(pstr) {
   if (pstr == null) {
     return "";
   }
   var count = 0;
   var str = "";
   var prevchar = "";
   var curchar = "";
   while (count < pstr.length) {
     curchar = pstr.substring(count, count + 1);
     if (count == 0 || prevchar == " ") {
       curchar = curchar.toUpperCase();
     }
     str = str + curchar;
     prevchar = curchar;
     count++;
   }
   return str;
}';
   end;
---------------------
   function RtnInstr return varchar2 is
   begin
      return 'function JSLInstr(pstr, pfind, pstart, pnth) {
   if (pstr == null || pfind == "") { return null; }
   if (pstart <> null) {
     var index = 0;
     var count = 0;
     var start = pstart - 1;
     if (pnth <> null) {
       while (index <> -1) {
         index = pstr.indexOf(pfind, start);
         if (index == "") { return 0; }
         start = index + 1;
         count++;
         if (count == pnth) {
           return (index + 1);
         }
       }
     }
     else {
       index = pstr.indexOf(pfind, start);
       if (index == "") { return 0; }
     }
     return (index + 1);
   }
   else {
     return (pstr.indexOf(pfind) + 1);
   }
   return 0;
}';
   end;
---------------------
   function RtnLength return varchar2 is
   begin
      return 'function JSLLength(pstr) {
   return pstr.length;
}';
   end;
---------------------
   function RtnLower return varchar2 is
   begin
      return 'function JSLLower(pstr) {
   return pstr.toLowerCase();
}';
   end;
---------------------
   function RtnLPad return varchar2 is
   begin
      return 'function JSLLPad(pstr1, pLen, pstr2) {
   var str = "";
   var pos = 0;
   if (pstr1 == null || pLen == null) { return ""; }
   var count = pLen - pstr1.length;
   if (count > 0) {
     while (count > 0) {
       if (pstr2 <> null) {
         if (pos == pstr2.length) {
           pos = 0;
         }
         str = str + pstr2.substring(pos, pos + 1);
         pos++;
       }
       else {
         str = str + " ";
       }
       count--;
     }
     str = str + pstr1;
   }
   else {
     str = pstr1.substring(0, pLen);
   }
   return str;
}';
   end;
---------------------
   function RtnLTrim return varchar2 is
   begin
      return 'function JSLLTrim(pstr1, pstr2) {
   var str = "";
   var curchar = "";
   var pos = 0;
   var len = pstr1.length;
   while (pos < len) {
     curchar = pstr1.substring(pos, pos + 1);
     if (pstr2 <> null) {
       if (pstr2.indexOf(curchar) == -1) {
         return (pstr1.substring(pos, pstr1.length - pos));
       }
     }
     else {
       if (curchar <> " ") {
         return (pstr1.substring(pos, pstr1.length - pos));
       }
     }
     pos++;
   }
   return "";
}';
   end;
---------------------
   function RtnNVL1 return varchar2 is
   begin
      return 'function JSLNVLStr(pval1, pval2) {
   if (pval1 + "" == "") { return pval2; } else { return pval1; }
}';
   end;
---------------------
   function RtnNVL2 return varchar2 is
   begin
      return 'function JSLNVLNum(pval1, pval2) {
   if (pval1 + "" == "") { return parseFloat(pval2); } else { return parseFloat(pval1); }
}';
   end;
---------------------
   function RtnReplace return varchar2 is
   begin
      return 'function JSLReplace(pstr1, pstr2, pstr3) {
   if (pstr1 <> "") {
     var rtnstr = "";
     var searchstr = pstr1;
     var addlen = pstr2.length;
     var index = pstr1.indexOf(pstr2);
     while ((index <> -1) && (searchstr <> "")) {
       rtnstr = rtnstr + searchstr.substring(0, index);
       if (pstr3 <> null) {
         rtnstr = rtnstr + pstr3;
       }
       searchstr = searchstr.substring(index + addlen, searchstr.length);
       if (searchstr <> "") {
          index = searchstr.indexOf(pstr2);
       }
       else { index = -1; }
     }
     return (rtnstr + searchstr);
   }
   else {
     return "";
   }
}';
   end;
---------------------
   function RtnRound return varchar2 is
   begin
      return 'function JSLRound(pval1, pval2) {
   return Math.round(pval1);
}';
   end;
---------------------
   function RtnRPad return varchar2 is
   begin
      return 'function JSLRPad(pstr1, plen, pstr2) {
   if (pstr1 == null || plen == null) {
     return "";
   }
   var str = "";
   var pos = 0;
   var count = plen - pstr1.length;
   if (count > 0) {
     str = pstr1;
     if (pstr2 <> null) {
       while (count > 0) {
         if (pos == pstr2.length) {
           pos = 0;
         }
         str = str + pstr2.substring(pos, pos + 1);
         pos++;
         count--;
       }
     }
     else {
       while (count < plen) {
         str = str + " ";
         count++;
       }
     }
   }
   else {
     str = pstr1.substring(0, plen);
   }
   return str;
}';
   end;
---------------------
   function RtnRTrim return varchar2 is
   begin
      return 'function JSLRTrim(pstr1, pstr2) {
   var str = "";
   var curchar = "";
   var len = pstr1.length;
   var pos = len - 1;
   while (pos >= 0) {
     curchar = pstr1.substring(pos, pos + 1);
     if (pstr2 <> null) {
       if (pstr2.indexOf(curchar) == -1) {
         return (pstr1.substring(0, pos + 1));
       }
     }
     else {
       if (curchar <> " ") {
         return (pstr1.substring(0, pos + 1));
       }
     }
     pos--;
   }
   return "";
}';
   end;
---------------------
   function RtnSign return varchar2 is
   begin
      return 'function JSLSign(pval) {
   if (pval > 0) {
     return 1;
   }
   else if (pval < 0) {
     return -1;
   }
   return pval;
}';
   end;
---------------------
   function RtnSubstr return varchar2 is
   begin
      return 'function JSLSubstr(pstr, pstart, plen) {
   if (plen <> null) {
     if (Math.round(plen) < 1) {
       return null;
     }
     return (pstr.substring(Math.round(pstart) - 1, Math.round(plen) + pstart - 1));
   }
   else {
     return (pstr.substring(Math.round(pstart) - 1, pstr.length));
   }
}';
   end;
---------------------
   function RtnTrunc return varchar2 is
   begin
      return 'function JSLTrunc(pstr, pdigits) {
   var str = "" + pstr;
   var idigits = 0;
   var retval = 0.0;
   var scale = 0;
   if (str == "") {
      return "";
   }
   else {
      if (pdigits <> null) {
        idigits = parseInt(pdigits,10);
      }
      retval = parseFloat(pstr);
      scale = Math.pow(10,idigits);
      retval = Math.floor(retval*scale)/scale;
      return "" + retval;
   }
}';
   end;
---------------------
   function RtnUpper return varchar2 is
   begin
      return 'function JSLUpper(pstr) {
   return pstr.toUpperCase();
}';
   end;
---------------------
   function CallCheckRange(p_ctl in varchar2, p_val in varchar2, p_lowval in number, p_hival in number, p_msg in varchar2) return varchar2 is
   begin
      if p_lowval is null then
         return '   if (!JSLCheckRange('||p_ctl||', '||p_val||', 3, 0, '||to_char(p_hival)||', "'||p_msg||'")) { return false }';
      elsif p_hival is null then
         return '   if (!JSLCheckRange('||p_ctl||', '||p_val||', 2, '||to_char(p_lowval)||', 0, "'||p_msg||'")) { return false }';
      else
         return '   if (!JSLCheckRange('||p_ctl||', '||p_val||', 1, '||to_char(p_lowval)||', '||to_char(p_hival)||', "'||p_msg||'")) { return false }';
      end if;
   end;
---------------------
   function CallChkMaxLength(p_ctl in varchar2, p_length in number, p_msg in varchar2) return varchar2 is
   begin
      return '   if (!JSLChkMaxLength('||p_ctl||', '||to_char(p_length)||', "'||p_msg||'")) { return false }';
   end;
---------------------
   function CallChkNumPrecision(p_ctl in varchar2, p_val in varchar2, p_precision in number, p_msg in varchar2) return varchar2 is
   begin
      return '   if (!JSLChkNumPrecision('||p_ctl||', '||p_val||', '||to_char(p_precision)||', "'||p_msg||'")) { return false }';
   end;
---------------------
   function CallChkNumScale(p_ctl in varchar2, p_val in varchar2, p_scale in number, p_msg in varchar2) return varchar2 is
   begin
      return '   if (!JSLChkNumScale('||p_ctl||', '||p_val||', '||to_char(p_scale)||', "'||p_msg||'")) { return false }';
   end;
---------------------
   function CallChkConstraint(p_constraint in varchar, p_msg in varchar, p_indent in boolean) return varchar2 is
   begin
      if p_indent then
        return '     if (!JSLChkConstraint('||p_constraint||', "'||p_msg||'")) { return false }';
      else
        return '   if (!JSLChkConstraint('||p_constraint||', "'||p_msg||'")) { return false }';
      end if;
   end;
---------------------
   function CallMakeUpper(p_ctl in varchar2) return varchar2 is
   begin
      return '   JSLMakeUpper('||p_ctl||');';
   end;
---------------------
   function CallNotNull(p_ctl in varchar2, p_msg in varchar2) return varchar2 is
   begin
      return '   if (!JSLNotNull('||p_ctl||', "'||p_msg||'")) { return false }';
   end;
---------------------
   function StandardSubmit (set_Z_ACTION boolean default true) return varchar2 is
   begin

      if set_Z_ACTION
      then

        return '   document.forms[0].Z_ACTION.value = ctl.value; document.forms[0].submit();';

      else

        return '   document.forms[0].submit();';

      end if;

   end;
---------------------
   function VerifyDelete(p_msg in varchar2) return varchar2 is
   begin
      return '   if (!confirm("'||p_msg||'")) { return false }
   document.forms[0].Z_ACTION.value = "VerifiedDelete";
   document.forms[0].submit();';
   end;
---------------------
   function DerivationField(p_name in varchar2,
                            p_size in varchar2,
                            p_value in varchar2) return varchar2 is
   begin
      return '
<SCRIPT><!--
//--> '||p_value||' <!--
document.write(''<input type=text name="'||p_name||'" value="'||p_value||'" size="'||p_size||'" onFocus="this.blur()">'')
//-->
</SCRIPT>
';
   end;
---------------------
   function AddCode(p_expr in varchar2) return varchar2 is
   begin
      return p_expr;
   end;
---------------------
   function LOVButton(p_alias in varchar2, p_lovbut in varchar2) return varchar2 is
   begin
      return '
' || OpenScript || '
document.write(''<a href="javascript:'||p_alias||'_LOV(document.forms[0].P_'||p_alias||')">'||p_lovbut||'</a>'');
'|| CloseScript;
   end;
end;

/
