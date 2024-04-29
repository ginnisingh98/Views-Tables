--------------------------------------------------------
--  DDL for Package Body AP_WEB_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_UTILITIES_PKG" AS
/* $Header: apwxutlb.pls 120.22.12010000.11 2010/06/26 16:30:48 rveliche ship $ */

  -- Error field and message delimiters
  C_OpenDelimit          CONSTANT VARCHAR2(1) := '{';
  C_CloseDelimit         CONSTANT VARCHAR2(1) := '}';

  -- Number of minimum days (must be a multiple of 7) displayed in
  -- enter receipts calendar
  C_NumOfMinDaysInCal         CONSTANT NUMBER := 35;

  -- Prefix to desc flex and pseudo desc flex variables
  C_InputObjectPrefix     CONSTANT VARCHAR2(10) := 'FLEX';
  C_InputPseudoObjectPrefix
                        CONSTANT VARCHAR2(10) := 'PFLEX';


GIsMobileApp BOOLEAN := null;
---------------------------------------------------------------------
-- DESCRIPTION:
--   Since BOOLEAN is not a valid SQL Type, this used to return a NUMBER
--   This is called by oracle.apps.ap.oie.utility.OIEUtil
---------------------------------------------------------------------
FUNCTION GetIsMobileApp RETURN NUMBER
IS
BEGIN
  if (IsMobileApp) then
    return 1;
  else
    return 0;
  end if;
END;

FUNCTION IsMobileApp RETURN BOOLEAN
IS
  l_version varchar2(1);
BEGIN

  if (GIsMobileApp is null) then
    begin
      select nvl(version, C_WebApplicationVersion)
      into l_version
      from fnd_responsibility
      where application_id = fnd_global.resp_appl_id() and responsibility_id = fnd_global.resp_id();
    exception
      when no_data_found then
        null;
    end;

    if (l_version = C_MobileApplicationVersion) then
      GIsMobileApp := true;
    else
      GIsMobileApp := false;
    end if;
  end if;

  return GIsMobileApp;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'IsMobileApp');
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;
END;

function isCreditCardEnabled(p_employeeId in AP_WEB_DB_CCARD_PKG.cards_employeeID) return boolean
IS
  l_has			VARCHAR2(1);
  l_cCardEnabled        VARCHAR2(1);
  l_FNDUserID           AP_WEB_DB_HR_INT_PKG.fndUser_userID;
  l_userIdCursor	AP_WEB_DB_HR_INT_PKG.UserIdRefCursor;

BEGIN
   -- get Credit Card enable option
   IF ( AP_WEB_DB_HR_INT_PKG.GetUserIdForEmpCursor(
				p_employeeId,
				l_userIdCursor) = TRUE ) THEN
      LOOP
        FETCH l_userIdCursor INTO l_FNDUserID;
        l_cCardEnabled := VALUE_SPECIFIC(
                              p_name              => 'SSE_ENABLE_CREDIT_CARD',
                              p_user_id           => l_FNDUserID,
                              p_resp_id		  => FND_PROFILE.VALUE('RESP_ID'),
                              p_apps_id           => FND_PROFILE.VALUE('RESP_APPL_ID') );
        EXIT WHEN (l_userIdCursor%NOTFOUND) OR (nvl(l_cCardEnabled,'N') = 'Y');
      END LOOP;
      CLOSE l_userIdCursor;
   ELSE
      FND_PROFILE.GET('SSE_ENABLE_CREDIT_CARD', l_cCardEnabled);
   END IF;

   return (AP_WEB_DB_CCARD_PKG.UserHasCreditCard(p_employeeId, l_has) AND
	   l_has = 'Y' AND l_cCardEnabled = 'Y');
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'isCreditCardEnabled');
        DisplayException(fnd_message.get);
      END;
END isCreditCardEnabled;


PROCEDURE InitDayOfWeekArray(p_day_of_week_array  IN OUT NOCOPY  Number_Array);


------------------------------------------------------------------------
-- DisplayException displays web server exception
------------------------------------------------------------------------
PROCEDURE DisplayException (P_ErrorText Long) IS
BEGIN
  htp.htmlOpen;
  FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_GO_BACK');
  htp.p('<BODY BGCOLOR="#F8F8F8">');
  htp.p(replace(P_ErrorText,'
',' '));
  htp.p('<p><a href="javascript:history.back()">');
  htp.p('<IMG SRC="'||AP_WEB_INFRASTRUCTURE_PKG.getImagePath||
        'APWBKFR.gif" BORDER=0 HEIGHT=30 WIDTH=30>');
  htp.p(fnd_message.get||'</a>');
  htp.p('</BODY>');
  htp.htmlClose;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DisplayException' || P_ErrorText);
        APP_EXCEPTION.RAISE_EXCEPTION;
      END;

END;


PROCEDURE GetUserAgent(p_user_agent IN OUT NOCOPY VARCHAR2) IS
  l_user_agent VARCHAR2(100) := OWA_UTIL.get_cgi_env('HTTP_USER_AGENT');
BEGIN
  -- dtong added NS45
  IF (instrb(l_user_agent, 'MSIE') <> 0) THEN
    p_user_agent := 'IE30';
  ELSIF ((instrb(l_user_agent, '3.0') = 0) AND
	 (instrb(l_user_agent, '4.') = 0)) THEN
    p_user_agent := 'NS20';
  ELSIF (instrb(l_user_agent, '4.0') > 0) then
    p_user_agent := 'NS40';
  ELSIF (instrb(l_user_agent, '4.5') >0) then
    p_user_agent := 'NS45';
  ELSE
  p_user_agent := 'NS30';
  END IF;


EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetUserAgent');
        DisplayException(fnd_message.get);
      END;

END GetUserAgent;

-----------------------------------
PROCEDURE PopulateCurrencyArray IS
-----------------------------------
  l_curr_code		 AP_WEB_DB_COUNTRY_PKG.curr_currCode;
  l_curr_name            AP_WEB_DB_COUNTRY_PKG.curr_name;
  l_precision		 AP_WEB_DB_COUNTRY_PKG.curr_precision;
  l_minimum_acct_unit    AP_WEB_DB_COUNTRY_PKG.curr_minAcctUnit;
  l_derive_factor	 AP_WEB_DB_COUNTRY_PKG.curr_deriveFactor;
  l_derive_effective 	 AP_WEB_DB_COUNTRY_PKG.curr_deriveEffective;
  l_curr_count		 NUMBER := 0;
  l_date_format		 VARCHAR2(20);

  l_curr_cursor		 AP_WEB_DB_COUNTRY_PKG.CurrencyInfoCursor;

BEGIN

	 l_date_format := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
	 htp.p('var gC=g_arrCurrency;');
         IF (AP_WEB_DB_COUNTRY_PKG.GetCurrencyInfoCursor(l_curr_cursor)) THEN
           LOOP
           FETCH l_curr_cursor INTO l_curr_code,
         			    l_curr_name,
				    l_precision,
				    l_minimum_acct_unit,
				    l_derive_factor,
				    l_derive_effective;
           EXIT WHEN l_curr_cursor%NOTFOUND;
           -- g_arrCurrency is zero-based
           htp.p('gC[' || to_char(l_curr_count) ||
		  ']=new top.objCurrencyInfo("' || l_curr_code || '","'
		  || l_curr_name || '",'|| to_char(l_precision) || ','
		  || nvl(to_char(l_minimum_acct_unit),'""') || ','
		  || nvl(to_char(l_derive_factor), '0') || ','
		  || '"'
		  || nvl(to_char(l_derive_effective, l_date_format), '')
		  || '"'
		  || ');');

           l_curr_count := l_curr_count + 1;

           END LOOP;
           htp.p('gC['||to_char(l_curr_count) || ']=new top.objCurrencyInfo("OTHER","OTHER",2,"",0,"");');

           -- total number of entries in currencyArray
	   htp.p('g_arrCurrency.len = '|| to_char(l_curr_count+1) || ';
	 	  top.objExpenseReport.header.setReimbursCurr(top.g_arrCurrency[0].currency);
	   ');
	 END IF;
         CLOSE l_curr_cursor;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'PopulateCurrencyArray');
        DisplayException(fnd_message.get);
      END;

END PopulateCurrencyArray;

----------------------
PROCEDURE MakeArray IS
----------------------
BEGIN
htp.p(' function MakeArray (n)
{
  this.len = n;
  for (var i=1; i<=n; i++)
    this[i] = 0;
}');
END MakeArray;


------------------------------------------------------------------
PROCEDURE GetEmployeeInfo(p_employee_name	IN OUT NOCOPY VARCHAR2,
			  p_employee_num	IN OUT NOCOPY VARCHAR2,
			  p_cost_center		IN OUT NOCOPY  VARCHAR2,
			  p_employee_id		IN	NUMBER) IS
-------------------------------------------------------------------
  l_EmpInfoRec			AP_WEB_DB_HR_INT_PKG.EmployeeInfoRec;
BEGIN

  IF (AP_WEB_DB_HR_INT_PKG.GetEmployeeInfo(p_employee_id,
					l_EmpInfoRec)) THEN
	p_employee_name := l_EmpInfoRec.employee_name;
	p_employee_num := l_EmpInfoRec.employee_num;
  END IF;

  AP_WEB_ACCTG_PKG.GetEmployeeCostCenter(
        p_employee_id => p_employee_id,
        p_emp_ccid => l_EmpInfoRec.emp_ccid,
        p_cost_center => p_cost_center);

EXCEPTION
  WHEN OTHERS THEN
    p_employee_name := NULL;
    p_employee_num := NULL;
    p_cost_center := NULL;
END GetEmployeeInfo;

----------------------------------------------------------
PROCEDURE ExitExpenseReport IS
----------------------------------------------------------

BEGIN

  htp.p('
  if (top.opener)
    parent.window.close();
  else{
     if (g_dcdName.charAt(g_dcdName.length-1) == "/") l_dcdName = g_dcdName.substring(0,g_dcdName.length-1);
     else l_dcdName = g_dcdName;
     location = l_dcdName+"/OracleApps.DMM";
  }
');
END;

----------------------------------------------------------
PROCEDURE CancelExpenseReport IS
----------------------------------------------------------

BEGIN

  htp.p('
function CancelExpenseReport() {
');

  FND_MESSAGE.SET_NAME('SQLAP', 'AP_WEB_CANCEL_REPORT');

htp.p('
  if (!confirm("'||AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get, TRUE)||'"))
    return;
');
  ExitExpenseReport;
  htp.p('
}
');
END;

PROCEDURE GoBack IS
BEGIN
  htp.p('function goBack(){
    history.back();
  }');
END GoBack;


-----------------------------------------------------
PROCEDURE SetReceiptWarningErrorMessage
-----------------------------------------------------
IS
BEGIN

  -- determine receipt offset on client
  htp.p('function SetReceiptWarningError(index, w_message, w_field, e_message, e_field) {
           for(var i=1;i<=parent.ArrayCount;i++) {
             if (top.receipt[i].ReceiptNumber == index) {
               top.receipt[i].warning_message = w_message;
               top.receipt[i].warning_field = w_field;
               top.receipt[i].error_message = e_message;
               top.receipt[i].error_field = e_field;
               return;
             }
           }
         }');

END SetReceiptWarningErrorMessage;


---------------------------------------------------------------------------
PROCEDURE InitDayOfWeekArray (p_day_of_week_array  IN OUT NOCOPY  Number_Array) IS
---------------------------------------------------------------------------
BEGIN

  p_day_of_week_array(1) := 1;
  p_day_of_week_array(2) := 2;
  p_day_of_week_array(3) := 3;
  p_day_of_week_array(4) := 4;
  p_day_of_week_array(5) := 5;
  p_day_of_week_array(6) := 6;
  p_day_of_week_array(7) := 7;
  p_day_of_week_array(8) := 1;
  p_day_of_week_array(9) := 2;
  p_day_of_week_array(10) := 3;
  p_day_of_week_array(11) := 4;
  p_day_of_week_array(12) := 5;
  p_day_of_week_array(13) := 6;
  p_day_of_week_array(14) := 7;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'InitDayOFWeekArray');
        DisplayException(fnd_message.get);
      END;

END InitDayOFWeekArray;

------------------------------------------------------
FUNCTION NDaysInCalendar(p_cal_end_date	IN DATE,
                         p_start_dow	IN NUMBER) RETURN NUMBER
IS
------------------------------------------------------
  l_dow_cal_end_date     NUMBER;
  l_day_of_week_num      NUMBER;

BEGIN
  --------------------------------------------------------------------
  -- Calculate day_of_week value of the calendar_end_date, depending on
  -- what the start_day of the week is (What cell does the last day land
  -- on in the last row)
  --------------------------------------------------------------------

  l_dow_cal_end_date := p_cal_end_date - trunc(p_cal_end_date, 'DAY') + 1;
  l_day_of_week_num := mod(7 + l_dow_cal_end_date - p_start_dow - 1, 7) + 1;
  RETURN (C_NumOfMinDaysInCal + l_day_of_week_num);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'NDaysInCalendar');
        DisplayException(fnd_message.get);
      END;

END;




------------------------------------------------------------------
PROCEDURE PopulateEquation (p_multicurr_flag IN VARCHAR2,
			    p_inv_rate_flag  IN VARCHAR2,
	                    p_reimbCurr	     IN VARCHAR2,
			    p_receiptCurr    IN VARCHAR2,
			    p_rate	     IN VARCHAR2,
			    p_equation	     IN OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------
BEGIN

  IF (p_multicurr_flag = 'Y') THEN

    IF (p_inv_rate_flag = 'Y') THEN

      p_equation := '1 ' || p_reimbCurr || '=' || substrb(to_char(1/to_number(p_rate)),1,18) || ' ' || p_receiptCurr;
    ELSE
      p_equation := '1 ' || p_receiptCurr || '=' || p_rate || ' ' || p_reimbCurr;
    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'PopulateEquation');
        DisplayException(fnd_message.get);
      END;

END PopulateEquation;



-------------------------------
PROCEDURE JustifFlagElement IS
-------------------------------
BEGIN
htp.p(' function justifFlagElement(exp_parameter_id, exp_parameter_name, justif_req_flag)
{
  this.parameter_id = exp_parameter_id;
  this.parameter_name = exp_parameter_name;
  this.justif_req_flag = justif_req_flag;
}');
END JustifFlagElement;

-------------------------------
PROCEDURE RetrieveJustifFlag IS
-------------------------------
BEGIN
htp.p('function retrieveJustifFlag(parameterId)
{
  for (var i=0; i < top.justifFlagArray.len; i++){

    if (top.justifFlagArray[i].parameter_id == parameterId)
      return(top.justifFlagArray[i].justif_req_flag);
  }

  return ("");
}');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'RetrieveJustifFlag');
        DisplayException(fnd_message.get);
      END;

END RetrieveJustifFlag;

------------------------------------
PROCEDURE RetrieveJustifFlagIndex IS
------------------------------------
BEGIN
htp.p('function retrieveJustifFlagIndex(parameterId)
{
  for (var i=0; i < top.justifFlagArray.len; i++){

    if (top.justifFlagArray[i].parameter_id == parameterId)
      return(i);
  }

  return ("");
}');
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'RetrieveJustifFlagIndex');
        DisplayException(fnd_message.get);
      END;

END RetrieveJustifFlagIndex;

--------------------------
PROCEDURE CurrencyInfo IS
--------------------------
BEGIN
htp.p(' function currencyInfo(currency, name, precision,
				minimum_acct_unit,
				euro_rate, effective_date)
{
  this.currency = currency;
  this.name = name;
  this.precision = precision;
  this.minimum_acct_unit = minimum_acct_unit;
  this.euro_rate = euro_rate;
  this.effective_date = effective_date;

}
');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CurrencyInfo');
        DisplayException(fnd_message.get);
      END;

END CurrencyInfo;

-----------------------------------
PROCEDURE RetrieveCurrencyIndex IS
-----------------------------------
BEGIN
htp.p(' function retrieveCurrencyIndex(currency)
{
  var high = top.currencyArray.len - 1;
  var low = 0;
  var mid;

  while (low <= high) {
    mid = Math.floor((high + low)/2);
    if (top.currencyArray[mid].currency < currency) {
	low = mid + 1;
    } else if (top.currencyArray[mid].currency > currency) {
	high = mid - 1;
    } else {
	return mid;
    }
  }
  return -1;

}');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'RetrieveCurrencyIndex');
        DisplayException(fnd_message.get);
      END;

END RetrieveCurrencyIndex;

-------------------------
PROCEDURE MoneyFormat IS
-------------------------
l_credit_line_profile_option varchar2(1) := 'N';
l_allow_credit_lines Boolean := FALSE;
BEGIN
    FND_PROFILE.GET('AP_WEB_ALLOW_CREDIT_LINES',
		     l_credit_line_profile_option);

    if (l_credit_line_profile_option = 'Y') then
      l_allow_credit_lines := TRUE;
    else
      l_allow_credit_lines := FALSE;
    end if;

if (l_allow_credit_lines) then
 htp.p('



function moneyFormat(input, currency) {

 var index = top.retrieveCurrencyIndex(currency);
 var minimum_acct_unit = top.currencyArray[index].minimum_acct_unit;
 var precision = top.currencyArray[index].precision;

 var V_input = input + "";

 if (V_input == "")
   return("");

 if ((eval(V_input) == 0) || (eval(V_input) == 0.0) || (eval(V_input) == 0.00)){
  if (precision <= 0)
    return("0");
  else if (precision == 1)
    return("0.0");
  else if (precision == 2)
    return("0.00");
  else if (precision == 3)
    return("0.000");

 }
 var prefix;
 if ((eval(input) < 0) && (eval(input) > -1)) {
   prefix = "-";
 } else {
   prefix = "";
 }

 if (minimum_acct_unit != ""){
   var amount = fMultiply( Math.round(V_input/minimum_acct_unit), minimum_acct_unit );
   return (amount);
 } else {
   if (precision == 0) {
     return Math.round(input);
   }
   var dollars;
   var tmp;
   var multiplier;

   if (eval(V_input) >= 0) {
       dollars = Math.floor(V_input);
   } else {
       dollars = Math.ceil(V_input);
   }
 }
   tmp = V_input + "0";
   multiplier = 10;

   for (var decimalAt = 0; decimalAt < tmp.length; decimalAt++) {
      if (tmp.charAt(decimalAt)==".") break
   }
   for (var i= 0; i < precision-1; i++){
     multiplier = fMultiply( 10, multiplier );
   }
   var cents  = "" + Math.floor(fMultiply( Math.abs(V_input), multiplier ))
   cents = cents.substring(cents.length-precision, cents.length)
   if ((eval(V_input) < 1) && (eval(V_input) > -1)){
     cents = "" + eval(cents) / multiplier;
     if (cents.charAt(0)=="0")
       cents = cents.substring(2,cents.length);
     else
       cents = cents.substring(1,cents.length);
   }
   dollars += ((tmp.charAt(decimalAt+precision)=="9")&&(cents=="00"))? 1 : 0;

   return prefix + dollars + "." + cents

}
');
else
 htp.p('function moneyFormat(input, currency) {

 var index = top.retrieveCurrencyIndex(currency);
 var minimum_acct_unit = top.currencyArray[index].minimum_acct_unit;
 var precision = top.currencyArray[index].precision;

 var V_input = input + "";

 if (V_input == "")
   return("");

 if ((eval(V_input) == 0) || (eval(V_input) == 0.0) || (eval(V_input) == 0.00)){
  if (precision <= 0)
    return("0");
  else if (precision == 1)
    return("0.0");
  else if (precision == 2)
    return("0.00");
  else if (precision == 3)
    return("0.000");

 }

 if (minimum_acct_unit != ""){
   var amount = fMultiply( Math.round(V_input/minimum_acct_unit), minimum_acct_unit );
   return (amount);
 }else{
    if (precision == 0) {
     return Math.round(input);
   }
   var dollars = Math.floor(V_input)
   var tmp = V_input + "0"
   var multiplier = 10;

   for (var decimalAt = 0; decimalAt < tmp.length; decimalAt++) {
      if (tmp.charAt(decimalAt)==".") break
   }
   for (var i= 0; i < precision-1; i++){
     multiplier = fMultiply( 10, multiplier );
   }
   var cents  = "" + Math.round(fMultiply( V_input, multiplier ))
   cents = cents.substring(cents.length-precision, cents.length)
   if (eval(V_input) < 1) {
     cents = "" + eval(cents) / multiplier;
     if (cents.charAt(0)=="0")
       cents = cents.substring(2,cents.length);
     else
       cents = cents.substring(1,cents.length);
   }
   dollars += ((tmp.charAt(decimalAt+precision)=="9")&&(cents=="00"))? 1 : 0;
   if (precision == 0)
     return Math.round(input);
   else
     if ((eval(dollars)==0) && ((eval(cents)==0)||(cents==""))){
       // for bug 1032095
       // 0.0 or 0.  case
       if (precision <= 0)
    	return("0");
 	 else if (precision == 1)
    	return("0.0");
 	 else if (precision == 2)
   	 return("0.00");
  	else if (precision == 3)
    	return("0.000");
     }
   else
     return dollars + "." + cents

 }
}
');
end if;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MoneyFormat');
        DisplayException(fnd_message.get);
      END;

END MoneyFormat;


-- This procedure is introduced to get around a Javascript eval function
-- bug. When eval a string like "00%99", eval erros out. This new function
-- is used only in moneyFormat2.
-- If the string passed is all 0, return T else return F.

-------------------------
PROCEDURE MoneyFormat2 IS
-------------------------
-- Used for formatting the currency exchange rate.
l_user_agent varchar2(100);

BEGIN
htp.p('function moneyFormat2(input) {

 var V_input = input + "";
 var tmp_input = eval(V_input); ');

 GetUserAgent(l_user_agent);

 -- MSIE starts to use scientific notation when the number is less than .00001.
 IF (l_user_agent = 'IE30') THEN
   htp.p('if (tmp_input <= 0.00001)
   return V_input; ');
 END IF;

 htp.p('if (V_input == "")
   return("");

 if (tmp_input >= 100)
   precision = 2;
 else if (tmp_input >= 10)
   precision = 3;
 else if (tmp_input >= 1)
   precision = 4;
 else {
   var mult = 10;
   precision = 4;
   for (var i = 1; i < 5; i++) {
     if (fMultiply(tmp_input, mult) >= 1)
       break;
     else {
       mult = fMultiply( mult, 10 );
       precision++;
     }
   }
 }


 /* if ((eval(V_input) == 0) || (eval(V_input) == 0.0) || (eval(V_input) == 0.00)){
  if (precision <= 0)
    return("0");
  else if (precision == 1)
    return("0.0");
  else if (precision == 2)
    return("0.00");
  else if (precision == 3)
    return("0.000");
 } */

   var dollars = Math.floor(V_input)
   var tmp = V_input + "0"
   var multiplier = 10;

   for (var decimalAt = 0; decimalAt < tmp.length; decimalAt++) {
      if (tmp.charAt(decimalAt)==".") break
   }
   for (var i= 0; i < precision-1; i++){
     multiplier = fMultiply( 10, multiplier );
   }
   var cents  = "" + Math.round(fMultiply(V_input, multiplier))
   cents = cents.substring(cents.length-precision, cents.length)
   if (eval(V_input) < 1) {
     cents = "" + eval(cents) / multiplier;
     if (cents.charAt(0)=="0")
       cents = cents.substring(2,cents.length);
     else
       cents = cents.substring(1,cents.length);
   }
   dollars += ((tmp.charAt(decimalAt+precision)=="9")&&(top.allZeroString(cents)=="T")) ? 1 : 0;
   if (precision == 0)
     return Math.round(input);;
   else
     return dollars + "." + cents;
 }
');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MoneyFormat2');
        DisplayException(fnd_message.get);
      END;

END MoneyFormat2;


----------------------
PROCEDURE DisplayHelp(v_defHlp	IN VARCHAR2) IS
------------------------

BEGIN

  AP_WEB_WRAPPER_PKG.ICXAdminSig_helpWinScript(v_defHlp);


EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DisplayHelp');
        DisplayException(fnd_message.get);
      END;

END DisplayHelp;

--------------------------------
PROCEDURE OverrideRequired(p_apprReqCC  IN  varchar2,
			   p_overrideReq  IN  varchar2) IS
--------------------------------

BEGIN

  htp.p('function overrideRequired() { ');
  IF (p_overrideReq = 'Y') THEN
    htp.p('return true;');
  ELSIF (p_apprReqCC = 'Y') THEN
    htp.p('if ((top.ccChanged) || (top.ccOrig != top.tabs.document.startReportForm.CostCenter.value))
    return true;
    else return false; ');
  ELSE
    htp.p('return false;');
  END IF;
  htp.p('}');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'OverrideRequired');
        DisplayException(fnd_message.get);
      END;

END OverrideRequired;



--------------------------------------
--- Prepare arguments to be passed when calling a function from
--- html.  Examples: when fin_parent.splits out the frames, the src
--- tag calls a plsql stored procedure with arguments.  These args need to
--- be "preparg"ed.
--------------------------------------
PROCEDURE PrepArg(p_arg in out nocopy long) IS
BEGIN
  p_arg := replace(p_arg, '%', '%25');
  p_arg := replace(p_arg, '&', '%26');
  p_arg := replace(p_arg, '+', '%2B');
  p_arg := replace(p_arg, '=', '%3D');
  p_arg := replace(p_arg, '"', '%22');
  p_arg := replace(p_arg, '?', '%3F');
  p_arg := replace(p_arg, '/', '%2F');
  p_arg := replace(p_arg, ';', '%3B');

  p_arg := replace(p_arg, ' ', '+');
  p_arg := replace(p_arg, '<', '%3C');
  p_arg := replace(p_arg, '>', '%3E');
  p_arg := replace(p_arg, '#', '%23');
  p_arg := replace(p_arg, '@', '%40');
  p_arg := replace(p_arg, ':', '%3A');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'PrepArg');
        DisplayException(fnd_message.get);
      END;

END PrepArg;



PROCEDURE DownloadHTML(P_FileName IN VARCHAR2)
IS
  V_FuncCode VARCHAR2(20) := 'AP_WEB_DOWNLOAD';
  V_FileName VARCHAR2(100);
BEGIN

  IF (AP_WEB_INFRASTRUCTURE_PKG.ValidateSession(V_FuncCode)) THEN

     V_FileName := ICX_CALL.decrypt2(P_FileName);

     -- Bug 899146:
     -- To avoid using http directy, we need to call the
     -- FND_WEB_CONFIG library to be sure we use the right protocol.
     OWA_UTIL.Redirect_URL( FND_WEB_CONFIG.WEB_SERVER ||
			   substrb(AP_WEB_INFRASTRUCTURE_PKG.getCSSPath, 2) ||
                           V_FileName);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DownloadHTML');
        DisplayException(fnd_message.get);
      END;

END DownloadHTML;

PROCEDURE GetNextDelimited(
  P_InputStr IN VARCHAR2,
  P_StrOffset IN OUT NOCOPY INTEGER,
  P_DelimitedStr OUT NOCOPY VARCHAR2,
  P_FoundDelimited OUT NOCOPY BOOLEAN)
IS
--
-- Find the next string delimited in InputStr and write it to DelimitedStr.
-- Increments StrOffset set to the offset of the character after the closing
-- delimiter.
-- If delimiters are not found, then DelimitedStr := NULL and the StrOffset
-- is set to length(InputStr)+1 to indicate the string has been processed.
-- Does not handle nested delimiters.
--
  OpenDelimitOffset     INTEGER;
  CloseDelimitOffset    INTEGER;
BEGIN
  -- Find opening and closing delimiters
  OpenDelimitOffset := instrb(P_InputStr,C_OpenDelimit,P_StrOffset);
  CloseDelimitOffset := instrb(P_InputStr,C_CloseDelimit,P_StrOffset);

  -- Check if valid
  IF (OpenDelimitOffset = 0) OR
    (CloseDelimitOffset = 0) OR
    (OpenDelimitOffset >= CloseDelimitOffset) THEN
    P_DelimitedStr := NULL;
    P_FoundDelimited := FALSE;
    RETURN;
  END IF;

  -- Extract substring
  P_DelimitedStr := substrb(P_InputStr,P_StrOffset+1,
    CloseDelimitOffset-OpenDelimitOffset-1);

  -- Update offset
  P_StrOffset := P_StrOffset + CloseDelimitOffset - OpenDelimitOffset + 1;

  P_FoundDelimited := TRUE;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetNextDelimited');
        DisplayException(fnd_message.get);
      END;

END GetNextDelimited;

FUNCTION ContainsError(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN

  -- Sets P_ReceiptContainsError to 'Y' if P_ReceiptNumber has an error
  -- otherwise returns 'N'.  Assumes that messages are in order of receipt
  -- number

IS
  V_NumOfMessages INTEGER;
  V_ContainsError VARCHAR2(1);
BEGIN

  -- Assume there are no errors
  V_ContainsError := 'N';

  -- Set which receipts have errors
  V_NumOfMessages := P_MessageArray.count;
  for I in 1..V_NumOfMessages loop

    -- Check for empty messages
    if NOT (P_MessageArray(I).error_text IS NULL) then
      V_ContainsError := 'Y';
    end if;

  end loop;

  return V_ContainsError = 'Y';

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ContainsError');
        DisplayException(fnd_message.get);
      END;


END ContainsError;

FUNCTION ContainsWarning(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN

  -- Sets P_ReceiptContainsError to 'Y' if P_ReceiptNumber has an error
  -- otherwise returns 'N'.  Assumes that messages are in order of receipt
  -- number

IS
  V_NumOfMessages   INTEGER;
  V_ContainsWarning VARCHAR2(1);
BEGIN

  -- Assume there are no errors
  V_ContainsWarning := 'N';

  -- Set which receipts have errors
  V_NumOfMessages := P_MessageArray.count;
  for I in 1..V_NumOfMessages loop

    -- Check for empty messages
    if NOT (P_MessageArray(I).warning_text IS NULL) then
      V_ContainsWarning := 'Y';
    end if;

  end loop;

  return V_ContainsWarning = 'Y';

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ContainsWarning');
        DisplayException(fnd_message.get);
      END;

END ContainsWarning;

FUNCTION ContainsErrorOrWarning(
  P_MessageArray          IN receipt_error_stack)
  RETURN BOOLEAN

  -- Sets P_ReceiptContainsError to 'Y' if P_ReceiptNumber has an error
  -- otherwise returns 'N'.  Assumes that messages are in order of receipt
  -- number

IS
  I          BINARY_INTEGER;

BEGIN
--chiho:1330572:
  IF ( P_MessageArray.COUNT > 0 ) THEN
  	I := P_MessageArray.FIRST;
	LOOP
    		IF ((P_MessageArray(I).warning_text IS NOT NULL) OR
      			(P_MessageArray(I).error_text IS NOT NULL)) THEN
      			RETURN TRUE;
		END IF;

		EXIT WHEN I = P_MessageArray.LAST;

		I := P_MessageArray.NEXT( I );

	END LOOP;
  END IF;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ContainsErrorOrWarning');
        DisplayException(fnd_message.get);
      END;

END ContainsErrorOrWarning;

FUNCTION ReceiptContainsError(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER)
  RETURN BOOLEAN

  -- Returns TRUE if P_ReceiptNumber has an error
  -- otherwise returns FALSE.  Assumes that messages are in order of receipt
  -- number

IS
BEGIN

--  htp.p('receipt contains error ' || p_receiptnumber || ', ' || p_messagearray.count
--        || ', ' || p_messagearray(p_receiptnumber).error_text || '<BR>');
--chiho:1330572:
  IF ( P_MessageArray.EXISTS(P_ReceiptNumber) ) THEN

    -- Set which receipts have errors
    return (P_MessageArray(P_ReceiptNumber).error_text IS NOT NULL);

  ELSE
    return FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ReceiptContainsError');
        DisplayException(fnd_message.get);
      END;

END ReceiptContainsError;

FUNCTION ReceiptContainsWarning(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER)
  RETURN BOOLEAN

  -- Returns TRUE if P_ReceiptNumber has an error
  -- otherwise returns FALSE.  Assumes that messages are in order of receipt
  -- number

IS
BEGIN

-- chiho:1330572:
  IF (P_MessageArray.EXISTS(P_ReceiptNumber)) THEN
    -- Set which receipts have errors
    RETURN ( P_MessageArray(P_ReceiptNumber).warning_text IS NOT NULL);
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ReceiptContainsWarning');
        DisplayException(fnd_message.get);
      END;

END ReceiptContainsWarning;

FUNCTION FieldContainsError(
  P_MessageArray          IN receipt_error_stack,
  P_ReceiptNumber         IN INTEGER,
  P_FieldNumber           IN VARCHAR2)
  RETURN BOOLEAN

  -- Returns TRUE if P_ReceiptNumber has an error
  -- otherwise returns FALSE.  Assumes that messages are in order of receipt
  -- number

IS
  V_NumOfMessages      INTEGER;
  V_FieldContainsError VARCHAR2(1);
BEGIN

  -- Assume there are no errors
  V_FieldContainsError := 'N';

  -- Set which receipts have errors
  if (instrb(P_MessageArray(P_ReceiptNumber).error_fields, P_FieldNumber) > 0) then
    V_FieldContainsError := 'Y';
  end if;

  return V_FieldContainsError = 'Y';
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'FieldContainsError');
        DisplayException(fnd_message.get);
      END;

END FieldContainsError;

FUNCTION NumOfReceiptWithError(
  P_MessageArray          IN receipt_error_stack)
  RETURN NUMBER
IS
  V_NumOfReceiptWithError INTEGER;
  V_NumOfMessages         INTEGER;
  V_NumOfReceipts         INTEGER;
  V_MaxReceiptNum         INTEGER;
  V_TempArray             Number_Array;
  I                       BINARY_INTEGER;
BEGIN

  V_NumOfReceiptWithError := 0;

  -- Get max number of receipts
  V_NumOfMessages := P_MessageArray.count;
  V_MaxReceiptNum := 0;
  V_NumOfReceiptWithError := 0;

--chiho:1330572:
  IF ( P_MessageArray.COUNT > 0 ) THEN
	I := P_MessageArray.FIRST;

	LOOP
    -- check for empty receipts
    		IF (ReceiptContainsError(P_MessageArray, I)) THEN
      			V_NumOfReceiptWithError := V_NumOfReceiptWithError + 1;
    		END IF;
    		EXIT WHEN I = P_MessageArray.LAST;
    		I := P_MessageArray.NEXT( I );

    	END LOOP;
  END IF;

  RETURN V_NumOfReceiptWithError;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'NumOfReceiptWithError');
        DisplayException(fnd_message.get);
      END;

END NumOfReceiptWithError;

FUNCTION NumOfReceiptWithWarning(
  P_MessageArray IN receipt_error_stack)
  RETURN NUMBER
IS
  V_NumOfMessages INTEGER;
  V_NumOfReceiptWithWarning INTEGER;
  I                         INTEGER;
BEGIN

  V_NumOfReceiptWithWarning := 0;

  -- Get max number of receipts
  V_NumOfMessages := P_MessageArray.count;
  for I in 1..V_NumOfMessages loop
    -- check for empty receipts
    if (ReceiptContainsWarning(P_MessageArray, I)) then
      V_NumOfReceiptWithWarning := V_NumOfReceiptWithWarning + 1;
    end if;
  end loop;

  return V_NumOfReceiptWithWarning;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'NumOfReceiptWithWarning' );
        DisplayException(fnd_message.get);
      END;

END NumOfReceiptWithWarning;

FUNCTION NumOfValidReceipt(
  P_MessageArray          IN receipt_error_stack)
  RETURN NUMBER
IS
  V_NumOfValidReceipt     INTEGER;
  V_NumOfMessages         INTEGER;
  V_NumOfReceipts         INTEGER;
  V_MaxReceiptNum         INTEGER;
  V_TempArray             Number_Array;
  I                       INTEGER;
BEGIN

  V_NumOfValidReceipt := 0;

  -- Get max number of receipts
  V_NumOfMessages := P_MessageArray.count;
  for I in 1..V_NumOfMessages loop
    -- check for empty receipts

    if ((not ReceiptContainsError(P_MessageArray, I)) and
      (not ReceiptContainsWarning(P_MessageArray, I))) then
      V_NumOfValidReceipt := V_NumOfValidReceipt + 1;
    end if;
  end loop;

  return V_NumOfValidReceipt;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'NumOfValidReceipt');
        DisplayException(fnd_message.get);
      END;

END NumOfValidReceipt;

PROCEDURE AddMessage(
  P_MessageArray  IN OUT NOCOPY receipt_error_stack,
  P_ReceiptNum    IN INTEGER,
  P_MessageType   IN VARCHAR2,
  P_MessageText   IN VARCHAR2,
  P_Field1        IN VARCHAR2,
  P_Field2        IN VARCHAR2,
  P_Field3        IN VARCHAR2,
  P_Field4        IN VARCHAR2,
  P_Field5        IN VARCHAR2)

  -- Inserts a message into P_MessageArray so that messages are in the
  -- order of receipt number

IS
  V_MessageFields        VARCHAR2(100);
  V_MessageText          VARCHAR2(2000);   -- New variable for NewUI
BEGIN

  --  Added for NewUI
  -- Replaced P_MessageText with V_MessageText


  fnd_message.set_encoded(P_MessageText);
  V_MessageText := fnd_message.get();
  fnd_message.set_encoded(P_MessageText);
  fnd_msg_pub.add();


  -- Append message fields
  if NOT P_Field1 IS NULL then
    V_MessageFields := V_MessageFields ||
      C_OpenDelimit || P_Field1 || C_CloseDelimit;
  end if;
  if NOT P_Field2 IS NULL then
    V_MessageFields := V_MessageFields ||
      C_OpenDelimit || P_Field2 || C_CloseDelimit;
  end if;
  if NOT P_Field3 IS NULL then
    V_MessageFields := V_MessageFields ||
      C_OpenDelimit || P_Field3 || C_CloseDelimit;
  end if;
  if NOT P_Field4 IS NULL then
    V_MessageFields := V_MessageFields ||
      C_OpenDelimit || P_Field4 || C_CloseDelimit;
  end if;
  if NOT P_Field5 IS NULL then
    V_MessageFields := V_MessageFields ||
      C_OpenDelimit || P_Field5 || C_CloseDelimit;
  end if;

  if P_MessageType = C_ErrorMessageType then
-- chiho:1203036:get the sub-string up to the maxima length:
    -- Append message text
	IF ( LENGTH(P_MessageArray(P_ReceiptNum).error_text ||
      		C_OpenDelimit || V_MessageText || C_CloseDelimit) <= C_MSG_TEXT_LEN ) THEN
		P_MessageArray(P_ReceiptNum).error_text := P_MessageArray(P_ReceiptNum).error_text ||
      		C_OpenDelimit || V_MessageText || C_CloseDelimit;
	END IF;
    -- Append message fields
	IF (  LENGTH(P_MessageArray(P_ReceiptNum).error_fields || C_OpenDelimit || V_MessageFields || C_CloseDelimit) <= C_MSG_FIELD_LEN ) THEN
    		P_MessageArray(P_ReceiptNum).error_fields :=
      			P_MessageArray(P_ReceiptNum).error_fields ||
      				C_OpenDelimit || V_MessageFields || C_CloseDelimit;
	END IF;

  elsif  P_MessageType = C_WarningMessageType then

    -- Append message text
	IF (  LENGTH(P_MessageArray(P_ReceiptNum).warning_text ||
      C_OpenDelimit || V_MessageText || C_CloseDelimit) <= C_MSG_TEXT_LEN ) THEN
    		P_MessageArray(P_ReceiptNum).warning_text :=
      			P_MessageArray(P_ReceiptNum).warning_text ||
      				C_OpenDelimit || V_MessageText || C_CloseDelimit;
  	END IF;

    -- Append message fields
	IF ( LENGTH(P_MessageArray(P_ReceiptNum).warning_fields ||
      		C_OpenDelimit || V_MessageFields || C_CloseDelimit) <= C_MSG_FIELD_LEN ) THEN
		P_MessageArray(P_ReceiptNum).warning_fields :=
      			P_MessageArray(P_ReceiptNum).warning_fields || C_OpenDelimit || V_MessageFields || C_CloseDelimit;
	END IF;
  end if;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'AddMessage');
        DisplayException(fnd_message.get);
      END;

END AddMessage;


------------------------------------------------------------------------
-- rlangi: Diagnostic Logging wrappers
------------------------------------------------------------------------
PROCEDURE LogException(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2) IS
BEGIN
  if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, p_pkgname, p_message);
  end if;
END LogException;

PROCEDURE LogEvent    (p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2) IS
BEGIN
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT, p_pkgname, p_message);
  end if;
END LogEvent;

PROCEDURE LogProcedure(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2) IS
BEGIN
  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, p_pkgname, p_message);
  end if;
END LogProcedure;

PROCEDURE LogStatement(p_pkgname IN VARCHAR2,
                       p_message IN VARCHAR2) IS
BEGIN
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, p_pkgname, p_message);
  end if;
END LogStatement;


------------------------------------------------------------------------
-- Add an expError Record type
------------------------------------------------------------------------
PROCEDURE AddExpError(p_errors  IN OUT NOCOPY expError,
		p_text		IN VARCHAR2,
		p_type		IN VARCHAR2,
		p_field		IN VARCHAR2,
		p_index		IN BINARY_INTEGER,
                p_MessageCategory IN VARCHAR2,
                p_IsMobileApp   IN BOOLEAN) IS
l_count 	INTEGER := 1;
-- for bug 1827501
l_text          varchar2(2000);
BEGIN

  l_text := p_text;

  -- Introduced the set_encoded() and fnd_msg_pub.add() for the newUI

  l_count := p_errors.COUNT + 1;
  fnd_message.set_encoded(l_text);

  if (p_IsMobileApp = true AND p_MessageCategory <> C_OtherMessageCategory) then
    if (p_MessageCategory = C_PAMessageCategory) then
      fnd_message.set_name('SQLAP', 'AP_OME_PA_ERROR');
      p_errors(l_count).text := fnd_message.get_encoded();
      l_text := p_errors(l_count).text;
    elsif (p_MessageCategory = C_PATCMessageCategory) then
      fnd_message.set_name('SQLAP', 'AP_OME_PATC_ERROR');
      p_errors(l_count).text := fnd_message.get_encoded();
      l_text := p_errors(l_count).text;
    elsif (p_MessageCategory = C_TaxMessageCategory) then
      fnd_message.set_name('SQLAP', 'AP_OME_TAX_ERROR');
      p_errors(l_count).text := fnd_message.get_encoded();
      l_text := p_errors(l_count).text;
    elsif (p_MessageCategory = C_ItemizationMessageCategory) then
      fnd_message.set_name('SQLAP', 'AP_OME_ITEMIZATION_ERROR');
      p_errors(l_count).text := fnd_message.get_encoded();
      l_text := p_errors(l_count).text;
    elsif (p_MessageCategory = C_DFFMessageCategory) then
      fnd_message.set_name('SQLAP', 'AP_OME_DFF_ERROR');
      p_errors(l_count).text := fnd_message.get_encoded();
      l_text := p_errors(l_count).text;
    end if;
  else
    if (p_MessageCategory = C_PATCMessageCategory) then
      fnd_message.set_name('SQLAP', 'OIE_PATC_MSG');
      fnd_message.set_token('MESSAGE', p_text);
      l_text := fnd_message.get_encoded();
      p_errors(l_count).text := AP_WEB_DB_UTIL_PKG.jsPrepString(p_text);
    elsif (p_MessageCategory = C_GMSMessageCategory) then
      fnd_message.set_name('SQLAP', 'OIE_GMS_MSG');
      fnd_message.set_token('MESSAGE', p_text);
      l_text := fnd_message.get_encoded();
      p_errors(l_count).text := AP_WEB_DB_UTIL_PKG.jsPrepString(p_text);
    else
      p_errors(l_count).text := AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get());
    end if;
  end if;

  p_errors(l_count).type := p_type;
  p_errors(l_count).field := p_field;
  p_errors(l_count).ind := p_index;
  fnd_message.set_encoded(l_text);
  fnd_msg_pub.add();

END AddExpError;


------------------------------------------------------------------------
-- Add an expError Record type with an unencoded/hardcoded message
------------------------------------------------------------------------
PROCEDURE AddExpErrorNotEncoded(p_errors  IN OUT NOCOPY expError,
		p_text		IN VARCHAR2,
		p_type		IN VARCHAR2,
		p_field		IN VARCHAR2,
		p_index		IN BINARY_INTEGER,
                p_MessageCategory IN VARCHAR2)
IS

l_count 	INTEGER := 1;
l_IsMobileApp   BOOLEAN;

BEGIN

  l_IsMobileApp := IsMobileApp;
  fnd_message.set_name('SQLAP', 'OIE_NOT_ENCODED_MSG');
  fnd_message.set_token('MESSAGE', p_text);
  AddExpError(p_errors,
	      fnd_message.get_encoded(),
	      p_type,
	      p_field,
	      p_index,
	      p_MessageCategory,
	      l_IsMobileApp);

END AddExpErrorNotEncoded;


PROCEDURE PrintMessages(P_SrcReceiptStack IN
                             receipt_error_stack)
IS
  I INTEGER;
BEGIN
  FOR I IN 1..P_SrcReceiptStack.count LOOP

    htp.p(
    to_char(I) || ', ' ||
    P_SrcReceiptStack(I).error_text || ', ' ||
    P_SrcReceiptStack(I).error_fields || '. ' ||
    P_SrcReceiptStack(I).warning_text || ', ' ||
    P_SrcReceiptStack(I).warning_fields || '.<BR>');

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'PrintMessage');
        DisplayException(fnd_message.get);
      END;

END PrintMessages;

PROCEDURE InitMessages(P_NumOfReceipts IN INTEGER,
                       P_SrcReceiptStack OUT
                             receipt_error_stack)
IS
  I INTEGER;
BEGIN
  FOR I IN 1..P_NumOfReceipts LOOP
    P_SrcReceiptStack(I) := NULL;
  END LOOP;
END InitMessages;

PROCEDURE MergeErrorStacks(P_ReceiptNum IN INTEGER,
                           P_Src1ReceiptStack IN
                             receipt_error_stack,
                           P_Src2ReceiptStack IN
                             receipt_error_stack,
                           P_TargetReceiptStack IN OUT
                             receipt_error_stack)
IS
  I               INTEGER;
BEGIN

  FOR I IN 1..P_ReceiptNum LOOP

    -- Append message text
    IF ( LENGTH(P_Src1ReceiptStack(I).error_text ||
      P_Src2ReceiptStack(I).error_text ) < C_MSG_TEXT_LEN ) THEN
    	P_TargetReceiptStack(I).error_text :=
      P_Src1ReceiptStack(I).error_text ||
      P_Src2ReceiptStack(I).error_text;
    END IF;

    -- Append message fields
    IF ( LENGTH( P_Src1ReceiptStack(I).error_fields ||
      P_Src2ReceiptStack(I).error_fields ) < C_MSG_FIELD_LEN ) THEN
	P_TargetReceiptStack(I).error_fields :=
      P_Src1ReceiptStack(I).error_fields ||
      P_Src2ReceiptStack(I).error_fields;
    END IF;

    -- Append message text
    IF ( LENGTH(P_Src1ReceiptStack(I).warning_text ||
      P_Src2ReceiptStack(I).warning_text) < C_MSG_TEXT_LEN ) THEN
    	P_TargetReceiptStack(I).warning_text :=
      P_Src1ReceiptStack(I).warning_text ||
      P_Src2ReceiptStack(I).warning_text;
    END IF;

    -- Append message fields
    IF ( LENGTH(P_Src1ReceiptStack(I).warning_fields ||
      P_Src2ReceiptStack(I).warning_fields) < C_MSG_FIELD_LEN ) THEN
    	P_TargetReceiptStack(I).warning_fields :=
      P_Src1ReceiptStack(I).warning_fields ||
      P_Src2ReceiptStack(I).warning_fields;
    END IF;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MergeErrorStacks');
        DisplayException(fnd_message.get);
      END;

END MergeErrorStacks;

PROCEDURE MergeErrors(P_ExpErrors 		IN expError,
                      P_TargetReceiptStack 	IN OUT NOCOPY receipt_error_stack)
IS
  I               INTEGER;
  J		  INTEGER := 0;
BEGIN

  FOR I IN 1..P_ExpErrors.COUNT LOOP
    J := P_ExpErrors(I).ind;

    IF (J IS NULL OR NOT (J> 0)) THEN
       J := P_TargetReceiptStack.COUNT + 1;
    END IF;

    BEGIN
      IF (P_ExpErrors(I).type = C_ErrorMessageType) THEN
    	    -- Append message text
    	    P_TargetReceiptStack(J).error_text :=
    	      P_TargetReceiptStack(J).error_text || C_openDelimit ||
    	      P_ExpErrors(I).text || C_closeDelimit;

    	    -- Append message fields
    	    P_TargetReceiptStack(J).error_fields :=
    	      P_TargetReceiptStack(J).error_fields || C_openDelimit ||
    	      P_ExpErrors(I).field || C_closeDelimit;
      ELSE  --if noi type then assume that expError is a warning
      -- Append message text
    	   P_TargetReceiptStack(J).warning_text :=
    	     P_TargetReceiptStack(J).warning_text || C_openDelimit ||
    	     P_ExpErrors(I).text || C_closeDelimit;

    	   -- Append message fields
    	   P_TargetReceiptStack(J).warning_fields :=
    	     P_TargetReceiptStack(J).warning_fields || C_openDelimit ||
    	     P_ExpErrors(I).field || C_closeDelimit;
      END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
	NULL;  --leave the target receipt stack as is
    END;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MergeErrors');
        DisplayException(fnd_message.get);
      END;

END MergeErrors;

PROCEDURE MergeExpErrors(P_Src1 	IN  OUT NOCOPY expError,
                         P_Src2 	IN  expError)
IS
  I               INTEGER;
  J               INTEGER;
  L_ReceiptNum	  INTEGER := 0;
  L_Src1Count	  INTEGER := 0;
BEGIN

  L_Src1Count := P_Src1.Count;
  L_ReceiptNum := P_Src1.Count + P_Src2.Count;
  J := 1;

  FOR I IN (L_Src1Count+1)..L_ReceiptNum LOOP
    -- Append message text
    P_Src1(I).text := P_Src2(J).text;
    -- Append message fields
    P_Src1(I).field := P_Src2(J).field;
    -- Append message type
    P_Src1(I).type := P_Src2(J).type;
    -- Append message index
    P_Src1(I).ind := P_Src2(J).ind;

    J := J + 1;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'MergeExpErrors');
        DisplayException(fnd_message.get);
      END;

END MergeExpErrors;


PROCEDURE ClearMessages(
            P_TargetReceiptStack OUT NOCOPY receipt_error_stack)
IS
  V_NumMessages INTEGER;
  I             INTEGER;
BEGIN

  -- Copy each receipt
  V_NumMessages := P_TargetReceiptStack.count;
  FOR I IN 1..V_NumMessages LOOP

    P_TargetReceiptStack(I).error_text := NULL;
    P_TargetReceiptStack(I).error_fields := NULL;
    P_TargetReceiptStack(I).warning_text := NULL;
    P_TargetReceiptStack(I).warning_fields := NULL;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ClearMessages');
        DisplayException(fnd_message.get);
      END;

END ClearMessages;

PROCEDURE CopyMessages(
            P_SrcReceiptStack IN receipt_error_stack,
            P_TargetReceiptStack IN OUT NOCOPY receipt_error_stack)
IS
  V_NumMessages       INTEGER;
  V_NumMessagesCopied INTEGER;
  I                   INTEGER;
BEGIN

  -- Clear out the target
  ClearMessages(P_TargetReceiptStack);

  -- Copy each receipt
  V_NumMessages := P_SrcReceiptStack.count;
  FOR I IN 1..V_NumMessages LOOP

    P_TargetReceiptStack(I).error_text :=
      P_SrcReceiptStack(I).error_text;
    P_TargetReceiptStack(I).error_fields :=
      P_SrcReceiptStack(I).error_fields;

    P_TargetReceiptStack(I).warning_text :=
      P_SrcReceiptStack(I).warning_text;
    P_TargetReceiptStack(I).warning_fields :=
      P_SrcReceiptStack(I).warning_fields;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CopyMessages');
        DisplayException(fnd_message.get);
      END;

END CopyMessages;

PROCEDURE ArrayifyFields(P_ErrorField        IN VARCHAR2,
                         P_ErrorFieldArray   OUT NOCOPY Number_Array)
IS

  I                   INTEGER;
  V_ErrorOffset   INTEGER;     -- Offset into P_ErrorField.error_fields
                                   -- which keeps track of portion processed.
  V_ErrorLength   INTEGER;     -- Length of P_ErrorField.error_fields
  V_ErrorFieldNum     VARCHAR2(10);-- Field wth error.

  V_MessageCount INTEGER;
  V_MessageNum   INTEGER;
  V_FoundDelimited BOOLEAN;
  V_MaxNumOfErrorField INTEGER := 5;
BEGIN

  -- Parse P_ErrorField and set error fields to TRUE
  V_ErrorOffset := 1;
  V_ErrorLength := Length(P_ErrorField);
  V_MessageNum := 1;

  I := 1;
  WHILE (V_ErrorOffset <= V_ErrorLength) LOOP

    -- Remove grouping open delimiter
    IF (substrb(P_ErrorField, 1, 1) = C_OpenDelimit) THEN
      V_ErrorOffset := V_ErrorOffset + 1;
    ELSE
      EXIT; -- break if error
    END IF;

    -- Parse fields for message
    V_FoundDelimited := TRUE;
    WHILE (V_ErrorOffset <= V_ErrorLength) AND V_FoundDelimited LOOP

      --- Get next error field and check whether error occurred during parsing
      GetNextDelimited(P_ErrorField, V_ErrorOffset, V_ErrorFieldNum,
        V_FoundDelimited);

      IF NOT V_FoundDelimited THEN
        EXIT;
      END IF;

      P_ErrorFieldArray(I) := TO_NUMBER(V_ErrorFieldNum);
      I := I+1;

    END LOOP;

    -- Remove grouping close delimiter
    IF (substrb(P_ErrorField, v_erroroffset, 1) = C_CloseDelimit) THEN
      V_ErrorOffset := V_ErrorOffset + 1;
    ELSE
      EXIT; -- break if error
    END IF;

  END LOOP;

EXCEPTION
  WHEN VALUE_ERROR THEN
    -- If cannot convert ErrorFieldNum to a number then
    -- do not specify that field as highlighted.  Ignore the
    -- rest of the string;
    RETURN;

END ArrayifyFields;

PROCEDURE ArrayifyErrorFields(P_ReceiptErrors     IN receipt_error_stack,
                              P_ReceiptNum        IN INTEGER,
                              P_ErrorFieldArray   OUT NOCOPY Number_Array)
IS
BEGIN
  ArrayifyFields(P_ReceiptErrors(P_ReceiptNum).error_fields,
                 P_ErrorFieldArray);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ArrayifErrorFields');
        DisplayException(fnd_message.get);
      END;

END ArrayifyErrorFields;

PROCEDURE ArrayifyWarningFields(P_ReceiptErrors  IN receipt_error_stack,
                              P_ReceiptNum     IN INTEGER,
                              P_ErrorFieldArray OUT NOCOPY Number_Array)
IS
BEGIN
  ArrayifyFields(P_ReceiptErrors(P_ReceiptNum).warning_fields,
                 P_ErrorFieldArray);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ArrayifWarningFields');
        DisplayException(fnd_message.get);
      END;

END ArrayifyWarningFields;

PROCEDURE ArrayifyText(P_ErrorText  IN LONG,
                       P_ErrorTextArray OUT NOCOPY LongString_Array)
IS

  I                   INTEGER;
  V_ErrorOffset   INTEGER;     -- Offset into P_ErrorField.error_fields
                                   -- which keeps track of portion processed.
  V_ErrorLength   INTEGER;     -- Length of P_ErrorField.error_fields
  V_ErrorFieldNum     VARCHAR2(10);-- Field wth error.

  V_MessageCount INTEGER;
  V_MessageNum   INTEGER;
  V_FoundDelimited BOOLEAN;
  V_MaxNumOfErrorField INTEGER := 5;
  V_NewMessageIndex NUMBER;
  V_NewMessageCount NUMBER;

  V_ErrorText       LONG;
BEGIN

  -- Parse error message text first
  V_ErrorOffset := 1;
  V_ErrorLength := Length(P_ErrorText);

  -- Loop through error message
  V_FoundDelimited := TRUE;
  V_NewMessageCount := 1;
  WHILE (V_ErrorOffset <= V_ErrorLength) AND V_FoundDelimited LOOP

    --- Get next error field and check whether error occurred during parsing
    GetNextDelimited(P_ErrorText, V_ErrorOffset, V_ErrorText, V_FoundDelimited);

    -- Set field values in structure
    P_ErrorTextArray(V_NewMessageCount) := substrb(V_ErrorText,1,1000);
    V_NewMessageCount := V_NewMessageCount + 1;
  END LOOP;

EXCEPTION
  WHEN VALUE_ERROR THEN
    -- If cannot convert ErrorFieldNum to a number then
    -- do not specify that field as highlighted.  Ignore the
    -- rest of the string;
    RETURN;

END ArrayifyText;

PROCEDURE ArrayifyErrorText(P_ReceiptErrors     IN receipt_error_stack,
                            P_ReceiptNum        IN INTEGER,
                            P_ErrorTextArray    OUT NOCOPY LongString_Array)
IS
BEGIN
  ArrayifyText(P_ReceiptErrors(P_ReceiptNum).error_text, P_ErrorTextArray);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ArrayifErrorText');
        DisplayException(fnd_message.get);
      END;

END ArrayifyErrorText;

PROCEDURE ArrayifyWarningText(P_ReceiptErrors  IN receipt_error_stack,
                            P_ReceiptNum     IN INTEGER,
                            P_ErrorTextArray OUT NOCOPY LongString_Array)
IS
BEGIN
  ArrayifyText(P_ReceiptErrors(P_ReceiptNum).warning_text, P_ErrorTextArray);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ArrayifWarningText');
        DisplayException(fnd_message.get);
      END;

END ArrayifyWarningText;




PROCEDURE ConvertDate IS

l_jan VARCHAR2(12);
l_feb VARCHAR2(12);
l_mar VARCHAR2(12);
l_apr VARCHAR2(12);
l_may VARCHAR2(12);
l_jun VARCHAR2(12);
l_jul VARCHAR2(12);
l_aug VARCHAR2(12);
l_sep VARCHAR2(12);
l_oct VARCHAR2(12);
l_nov VARCHAR2(12);
l_dec VARCHAR2(12);

l_index_d1 NUMBER := 0;  -- Day
l_index_d2 NUMBER := 0;
l_index_m1 NUMBER := 0;  -- Month
l_index_m2 NUMBER := 0;
l_index_y1 NUMBER := 0;  -- Year
l_index_y2 NUMBER := 0;
l_index_del1 NUMBER := 0; -- delimeter 1.
l_index_del2 NUMBER := 0; -- delimeter 2.
l_mon_format Boolean := FALSE;

l_delimeter  VARCHAR2(1) := NULL ; -- delimeter.
l_date_format VARCHAR2(20);
l_invalid_date_msg VARCHAR2(2000);
l_date_not_allowed_msg VARCHAR2(2000);
debug_info		VARCHAR2(100);

BEGIN

-- chiho:1283146:get the icx info directly rather through any package routines
-- which seems to have some problems...
  debug_info := 'Getting Date Format';
  l_date_format := icx_sec.getID( icx_sec.PV_DATE_FORMAT );

  -- l_date_format := AP_WEB_INFRASTRUCTURE_PKG.getDateFormat;
  debug_info := 'Getting FND Message';
  FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_INVALID_DATE');
  debug_info := 'Setting FND Token';
  FND_MESSAGE.SET_TOKEN('format', l_date_format);
  debug_info := 'invalid date msg';
  l_invalid_date_msg :=
	AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get, TRUE);
  debug_info := 'date not allowed';
  FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_DATE_NOT_ALLOWED');
  debug_info := 'date not allowed msg';
  l_date_not_allowed_msg :=
	AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get, TRUE);
  -- Get year string. RRRR
  -- dtong added UPPER to ignore year's case
  l_index_y1 := instrb(UPPER(l_date_format), 'RRRR');
  if (l_index_y1 = 0) then
	l_index_y1 := instrb(UPPER(l_date_format),'YYYY');
     	if (l_index_y1 <> 0) then
		l_index_y2 := l_index_y1 +3;
     	else l_index_y2 := l_index_y1 + 1;
     	end if;
  else l_index_y2 := l_index_y1 + 3;
  end if;

  -- Get Day string DD
  l_index_d1 := instrb(l_date_format, 'DD');
  l_index_d2 := l_index_d1 + 1;

  -- Get Month String either MM or MON
  l_index_m1 := instrb(l_date_format, 'MON');
  if (l_index_m1 <> 0) then
    l_mon_format := TRUE;
    l_index_m2 := l_index_m1 + 2;
  else
    l_index_m1 := instrb(l_date_format, 'Mon');
    if (l_index_m1 <> 0) then
	l_index_m2 := l_index_m1 + 2;
    else
	l_index_m1 := instrb(l_date_format, 'mon');
	if (l_index_m1 <> 0) then
	  l_index_m2 := l_index_m1 + 2;
	else
          l_index_m1 := instrb(l_date_format, 'MM');
          l_index_m2 := l_index_m1 + 1;
	end if;
    end if;
  end if;

  -- get delimeter of the date format string.
  -- can be either - or . or /
  l_index_del1 := instrb(l_date_format, '-', 1, 1);
  IF (l_index_del1 <> 0) THEN   /* delimeter - */
    l_delimeter := '-';
  ELSE
    l_index_del1 := instrb(l_date_format, '.', 1,1);
    IF (l_index_del1 <> 0) THEN  /* delimeter . */
	l_delimeter := '.';
    ELSE
	l_index_del1 :=  instrb(l_date_format, '/', 1,1);
	IF (l_index_del1 <> 0) THEN
	  l_delimeter := '/';
	END IF;
    END IF; -- IF (l_index_del1 <> 0)

  END IF; -- IF (l_index_del1 <> 0)

  IF (l_delimeter is NOT NULL) THEN
    l_index_del2 := instrb(l_date_format, l_delimeter, 1,2);

  END IF; /* IF (l_delimeter is NOT NULL) */
  IF (l_mon_format) THEN
    l_jan :=   substrb(TO_CHAR(TO_DATE('01/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_feb :=   substrb(TO_CHAR(TO_DATE('02/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_mar :=   substrb(TO_CHAR(TO_DATE('03/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_apr :=   substrb(TO_CHAR(TO_DATE('04/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_may :=   substrb(TO_CHAR(TO_DATE('05/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_jun :=   substrb(TO_CHAR(TO_DATE('06/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_jul :=   substrb(TO_CHAR(TO_DATE('07/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_aug :=   substrb(TO_CHAR(TO_DATE('08/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_sep :=   substrb(TO_CHAR(TO_DATE('09/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_oct :=   substrb(TO_CHAR(TO_DATE('10/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_nov :=   substrb(TO_CHAR(TO_DATE('11/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);
    l_dec :=   substrb(TO_CHAR(TO_DATE('12/01/1998', 'MM/DD/RRRR'), l_date_format), l_index_m1, 3);


  END IF; /* IF (l_mon_format) */

  htp.p('function fStringToDateCheckNull(date_string, error_msg) {
  if (date_string == "") {
    alert("' || l_invalid_date_msg || '");
    return null;
  }
  return(top.fStringToDate(date_string, error_msg));
  }');

  -- stringToDate Javascript Function.

  htp.p('function fStringToDate(date_string, error_msg) {
  if (date_string == "") {
    return null;
  }
  var day     = null;
  var tmp_day = null;
  var month   = null;
  var tmp_month = null;
  var year    = null;
  var del1    = null;
  var del2    =  null;
  tmp_day       = date_string.substring(' || TO_CHAR(l_index_d1-1) || ','
				   || TO_CHAR(l_index_d2) || ');

  tmp_month = date_string.substring(' || TO_CHAR(l_index_m1-1) || ','
				   || TO_CHAR(l_index_m2) || ');

  year      = date_string.substring(' || TO_CHAR(l_index_y1-1) || ','
				   || TO_CHAR(l_index_y2) || ');

  del1      = date_string.substring(' || TO_CHAR(l_index_del1-1) || ','
				   || TO_CHAR(l_index_del1) || ');

  del2      = date_string.substring(' || TO_CHAR(l_index_del2-1) || ','
				   || TO_CHAR(l_index_del2) || ');

  var year_1 = date_string.substring(' || TO_CHAR(l_index_y1-1) || ','
				   || TO_CHAR(l_index_y2+1) || ');

  if (((del1 >= "0") && (del1 <= "9")) || ((del1 >= "A") && (del1 <= "z")) ||
      ((del2 >= "0") && (del2 <= "9")) || ((del2 >= "A") && (del2 <= "z"))) {
	if (error_msg)
          alert("' || l_invalid_date_msg || '");
	return null;
  }

  // should not allow user to enter year more than 4 digits when year format is
  // set to YYYY. should not allow user to enter more than 2 digits when year
  // format is set to YY ');
  if ((l_index_y1-1) <> 0) then
    htp.p('
    if (year != fRtrim(year_1)) {
          alert("' || l_invalid_date_msg || '");
	return null;
    } ');
  end if;
  htp.p('

  if (!((year.length == 2) || (year.length == 4))) {
            alert("' || l_invalid_date_msg || '");
	return null;
  }

');

  IF (l_mon_format) THEN
    htp.p('if (tmp_month.toUpperCase() == "' || l_jan || '") {
		month = "1";
	   } else if (tmp_month.toUpperCase()  == "' || l_feb || '") {
		month = "2";
	   } else if (tmp_month.toUpperCase()  == "' || l_mar || '") {
		month = "3";
	   } else if (tmp_month.toUpperCase()  == "' || l_apr || '") {
		month = "4";
	   } else if (tmp_month.toUpperCase()  == "' || l_may || '") {
		month = "5";
	   } else if (tmp_month.toUpperCase()  == "' || l_jun || '") {
		month = "6";
	   } else if (tmp_month.toUpperCase()  == "' || l_jul || '") {
		month = "7";
	   } else if (tmp_month.toUpperCase()  == "' || l_aug || '") {
		month = "8";
	   } else if (tmp_month.toUpperCase()  == "' || l_sep || '") {
		month = "9";
	   } else if (tmp_month.toUpperCase()  == "' || l_oct || '") {
		month = "10";
	   } else if (tmp_month.toUpperCase()  == "' || l_nov || '") {
		month = "11";
	   } else if (tmp_month.toUpperCase()  == "' || l_dec || '") {
		month = "12";
	   } else {
		if (error_msg)
		  alert("' || l_date_not_allowed_msg || '");
		return null;
           }');

  ELSE
    htp.p('
if ((tmp_month.length == 2) && (tmp_month.charAt(0) == "0")) {
   month = tmp_month.substring(1,2);
} else {
   month = tmp_month;
}');

  END IF;

  htp.p('

 if ((tmp_day.length == 2) && (tmp_day.charAt(0) == "0")) {
    day = tmp_day.substring(1,2);

 } else {
    day = tmp_day;
 }

 if ((!top.fIsInt(day)) ||
      (!top.fIsInt(month)) ||
      (!top.fIsInt(year))) {
	if (error_msg)
	  alert("' || l_invalid_date_msg || '");
	return null;
  }


  if ((month < 1) || (month > 12)) {
	if (error_msg)
	  alert("' || l_date_not_allowed_msg || '");
	return null;
  }
  if (day < 1) {
	if (error_msg)
	  alert("' || l_date_not_allowed_msg || '");
	return null;
  }
  if ((month == 1) || (month == 3) || (month == 5) ||
    (month == 7) || (month == 8) || (month == 10) ||
    (month == 12)) {
	if (day > 31) {
		if (error_msg)
		  alert("' || l_date_not_allowed_msg || '");
		return null;
	}
  } else if (month == 2) {
	if ((year % 4) == 0) {
		if (day > 29) {
			if (error_msg)
			  alert("' || l_date_not_allowed_msg || '");
			return null;
		}
	} else {
		if (day > 28) {
			if (error_msg)
			  alert("' || l_date_not_allowed_msg || '");
			return null;
		}
	}

  } else {

	if (day > 30) {
		if (error_msg)
		  alert("' || l_date_not_allowed_msg || '");
		return null;
	}
  }

  var objDate = new Date(year, month-1, day, 00, 00, 00);
  return objDate;

}

');

 -- stringToDate_DDMMRRRR Javascript Function.
  htp.p('function fStringToDate_DDMMRRRR(date_string) {

  if (date_string == "") {
    return null;
  }
  var day     = null;
  var tmp_day = null;
  var month   = null;
  var tmp_month = null;
  var year    = null;
  var del1    = null;
  var del2    =  null;
  tmp_day = date_string.substring(0,2);
  month = date_string.substring(3,5);
  year = date_string.substring(6,10);
  del1 = date_string.substring(2,3);
  del2 = date_string.substring(5,6);
  if (((del1 >= "0") && (del1 <= "9")) || ((del1 >= "A") && (del1 <= "z")) ||
      ((del2 >= "0") && (del2 <= "9")) || ((del2 >= "A") && (del2 <= "z"))) {
        return null;
  }

');


htp.p('
 if ((month.length == 2) && (month.charAt(0) == "0")) {
    month = month.substring(1,2);

 }

 if ((tmp_day.length == 2) && (tmp_day.charAt(0) == "0")) {
    day = tmp_day.substring(1,2);

 } else {
    day = tmp_day;
 }
 if ((!top.fIsInt(day)) ||
      (!top.fIsInt(month)) ||
      (!top.fIsInt(year))) {
        return null;
  }

  if ((month < 1) || (month > 12))
        return null;

  if (day < 1)
        return null;
  if ((month == 1) || (month == 3) || (month == 5) ||
    (month == 7) || (month == 8) || (month == 10) ||
    (month == 12)) {
        if (day > 31)
                return null;
  } else if (month == 2) {
        if ((year % 4) == 0) {
                if (day > 29)
                        return null;

        } else {
                if (day > 28)
                        return null;
        }

  } else {

        if (day > 30)
                return null;
  }

  var objDate = new Date(year, month-1, day, 00, 00, 00);
  return objDate;

}
');


  -- dateToString Javascript function.
  htp.p('function fDateToString(dateobj) {
  if (!dateobj) return;
  var date = dateobj.getDate();
  var month;
  var tmp_month = dateobj.getMonth();
  tmp_month++;
  var year = dateobj.getFullYear();
');
  IF (l_mon_format) THEN
    htp.p('
  if (tmp_month == 1) {
	month = "' || l_jan || '";
  } else if (tmp_month == 2) {
	month = "' || l_feb || '";
  } else if (tmp_month == 3) {
	month =  "' || l_mar || '";
  } else if (tmp_month == 4) {
	month =  "' || l_apr || '";
  } else if (tmp_month == 5) {
	month =  "' || l_may || '";
  } else if (tmp_month == 6) {
	month =  "' || l_jun || '";
  } else if (tmp_month == 7) {
	month =  "' || l_jul || '";
  } else if (tmp_month == 8) {
	month =  "' || l_aug || '";
  } else if (tmp_month == 9) {
	month =  "' || l_sep || '";
  } else if (tmp_month == 10) {
	month =  "' || l_oct || '";
  } else if (tmp_month == 11) {
	month =  "' || l_nov || '";
  } else if (tmp_month == 12) {
	month =  "' || l_dec || '";
  }');

  ELSE  -- Not Mon format.

    -- fix month string.
    htp.p('if (tmp_month <= 9) {
  		month = "0" + tmp_month;
	   } else {
    		month = tmp_month;
	   }
    ');
  END IF;

    -- fix date string
    htp.p('if (date <= 9) {
   		 date = "0" + date;
  	   }
    ');
    htp.p('var result;');

  -- d m y
  IF ((l_index_d1 < l_index_m1) AND (l_index_m1 < l_index_y1)) THEN
    htp.p('result = date + "' || l_delimeter || '" + month + "' || l_delimeter || '" + year;');

  -- m d y
  ELSIF ((l_index_m1 < l_index_d1) AND (l_index_d1 < l_index_y1)) THEN
    htp.p('result = month + "' || l_delimeter || '" + date + "' || l_delimeter || '" + year;');
  -- y m d
  ELSIF ((l_index_y1 < l_index_m1) AND (l_index_m1 < l_index_d1)) THEN
    htp.p('result = year + "' || l_delimeter || '" + month + "' || l_delimeter || '" + date;');
  -- y d m
  ELSIF ((l_index_y1 < l_index_d1) AND (l_index_d1 < l_index_m1)) THEN
    htp.p('result = year + "' || l_delimeter || '" + date + "' || l_delimeter || '" + month;');
  -- m y d  Not likely, but...
  ELSIF ((l_index_m1 < l_index_y1) AND (l_index_y1 < l_index_d1)) THEN
    htp.p('result = month + "' || l_delimeter || '" + year + "' || l_delimeter || '" + date;');
  -- d y m  Not likely, but....
  ELSIF ((l_index_d1 < l_index_y1) AND (l_index_y1 < l_index_m1)) THEN
    htp.p('result = date + "' || l_delimeter || '" + year + "' || l_delimeter || '" + month;');
  END IF;
htp.p('
  return result;
}
');

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'convertDate');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	DisplayException(fnd_message.get);
      END;

END convertDate;



PROCEDURE DetermineConversion IS

  l_euro_code AP_WEB_DB_COUNTRY_PKG.curr_currCode;

BEGIN
  l_euro_code :=  getEuroCode;

  htp.p('function determineConversion(recCurr, reimbCurr) {

  if (recCurr == reimbCurr) {
    return 0;
  }

  var compare_date;
  if ((top.objDate1 != null) && (top.objDate2 != null)) {
    compare_date = top.objDate2;
  } else if ((top.objDate1 != null) && (top.objDate2 == null)){
    compare_date = top.objDate1;
  } else if ((top.objDate1 == null) && (top.objDate2 == null)) {
    return 0;
  } else {
    return -1;
  }
  if (recCurr == "' || l_euro_code || '") {
    if (getFixedRate(reimbCurr) > 0) {
	if (compareDate(compare_date, getEffectiveDate(reimbCurr)) >= 0)
	  return 2;
	else
	  return 0;
    } else {
	return 0;
    }

  } else if (reimbCurr == "' || l_euro_code || '") {
    if (getFixedRate(recCurr) > 0) {
	if (compareDate(compare_date, getEffectiveDate(recCurr)) >= 0)
	  return 1;
	else
	  return 0;
    } else {
	return 0;
    }
  } else {
	if ((getFixedRate(reimbCurr) > 0) ' || '&' || '&' || '
	    (getFixedRate(recCurr) > 0)) {
	  if ((compareDate(compare_date, getEffectiveDate(reimbCurr)) >= 0)
	       ' || '&' || '&' || '
	      (compareDate(compare_date, getEffectiveDate(recCurr)) >= 0)) {
		if (top.g_bEuroCodeDefined == false) {
        	  alert("top.g_objMessages.mstrGetMesg(\"AP_WEB_EURO_SETUP_INVALID\")");
		      top.euro_code_invalid = true;
		      form.currency.focus();
		      return;
	        }
	        else
		return 3;
	  } else {
		return 0;
	  }
	} else {
	  return 0;
	}
  }


}');
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DetermineConversion');
        DisplayException(fnd_message.get);
      END;

END DetermineConversion;


-----------------------------
FUNCTION getMinipackVersion RETURN VARCHAR2 IS
-----------------------------
BEGIN
  return    'R12.OIE.A';
END;

-----------------------------
FUNCTION getEuroCode RETURN VARCHAR2 IS
-----------------------------
  l_euro_code	AP_WEB_DB_COUNTRY_PKG.curr_currCode;
BEGIN
  l_euro_code :=  GL_CURRENCY_API.get_euro_code();
  htp.p('top.g_bEuroCodeDefined = true');
  return    l_euro_code;

EXCEPTION
  WHEN OTHERS THEN
    htp.p('top.g_bEuroCodeDefined = false');
    return  NULL;
END;


/*------------------------------------------------------------+
   Fix 1435885 : To prevent pcard packages from getting
   Invalid. These functions are not used by SSE.
   Functions include IsNum, DisplayHelp, GenericButton,
   GenToolBarScript, GenToolBar, GenButton, StyleSheet
+-------------------------------------------------------------*/
------------------
PROCEDURE IsNum IS
------------------
l_message       VARCHAR2(2000);
BEGIN

    fnd_message.set_name('SQLAP', 'AP_WEB_NUMBER_REQUIRED');
    l_message := AP_WEB_DB_UTIL_PKG.jsPrepString(fnd_message.get, TRUE);

htp.p('function isNum(str, showalert){
  var ch=str.substring(0,1);

  if((ch<"0" || "9"<ch) ' || '&' || '&' || ' (ch != ".") && (ch != "-")) {
   if (showalert)
    alert("' || l_message || '");
    return false;
  }
  for(var i=1; i<str.length; i++){
    var ch=str.substring(i,i+1)
    if((ch<"0" || "9"<ch) ' || '&' || '&' || ' ch != "."){
     if (showalert)
      alert("' || l_message || '");
/*      alert("You must enter a number");*/
      return false;
    }
  }
  // xx.xx.xx and xx. case
  if ((str.indexOf(".") != str.lastIndexOf(".")) || (str.lastIndexOf(".") == (str.length - 1))) {
   if (showalert)
    alert("' || l_message || '");
    return false;
  }
  // -. case
  if (str == "-.") {
   if (showalert)
    alert("' || l_message || '");
    return false;
  }
  // 00xx case
  if ((str.length > 1) && (str.substring(0,1) == "0") && (str.indexOf(".") == -1)) {
   if (showalert)
    alert("' || l_message || '");
    return false;
  }

  return true;
}
');
END IsNum;

----------------------
PROCEDURE DisplayHelp IS
------------------------
  v_lang        varchar2(5);

BEGIN
  v_lang := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  htp.p('function displayHelp(i) {
    var helpurl = "";
    var baseurl = self.location.protocol + "//" + self.location.host + "/OA_HTML/' || v_lang || '";
    if (i == 1)
      helpurl = baseurl + "/APWHLEX1.htm";
    else if (i == 2)
      helpurl = baseurl + "/APWHLEX2.htm";
    else if (i == 2.1)
      helpurl = baseurl + "/APWHLEX2.htm#Restoring Reports";
    else if (i == 2.2)
      helpurl = baseurl + "/APWHLEX6.htm#cctrans";
    else if (i == 3)
      helpurl = baseurl + "/APWHLEX3.htm";
    else if (i == 4)
      helpurl = baseurl + "/APWHLEX4.htm";
    else if (i == 4.1)
      helpurl = baseurl + "/APWHLEX4.htm#Reviewing Upload";
    else if (i == 5)
      helpurl = baseurl + "/APWHLEX5.htm";
    else if (i == 6)
      helpurl = baseurl + "/APWHLCC1.htm";

    // open(helpurl, "Expense_Report_Help");
    open(helpurl, "Expense_Report_Help", "scrollbars=yes,resizable=yes,menubar=no,location=no,width=800,height=600");
  }');

END DisplayHelp;


PROCEDURE DynamicButtonJS(P_ButtonText      varchar2,
                          P_ImageFileName   varchar2,
                          P_OnMouseOverText varchar2,
                          P_HyperTextCall   varchar2,
                          P_LanguageCode    varchar2,
                          P_JavaScriptFlag  boolean) IS
BEGIN
     htp.p('top.DynamicButton("'||AP_WEB_DB_UTIL_PKG.jsPrepString(P_ButtonText)||'",
                   "'||P_ImageFileName||'",
                   "'||AP_WEB_DB_UTIL_PKG.jsPrepString(P_OnMouseOverText, FALSE, TRUE)||'",
                   "'||P_HyperTextCall||'",
                   "'||P_LanguageCode||'",
                   false,
                   false,self);');

END;



---------------------------------------------------------------------
-- PROCEDURE GenToolbarScript
--
-- Generates javascript for the Toolbar functionalities.
----------------------------------------------------------------------
PROCEDURE GenToolbarScript IS
BEGIN
   js.scriptOpen;
   htp.p('
        img_dir = "' || C_IMG_DIR || '";
        bName = navigator.appName;
        bVer = parseInt(navigator.appVersion);
        if (bVer >= 3)
          {
                save1 = new Image;
                save1.src =  img_dir +"FNDIWSA1.gif";
                save2 = new Image;
                save2.src =  img_dir +"FNDIWSAV.gif";
                save3 = new Image;
                save3.src =  img_dir +"FNDIWSAD.gif";
                print1 = new Image;
                print1.src =  img_dir +"FNDIWPR1.gif";
                refresh1 = new Image;
                refresh1.src =  img_dir +"FNDIWRL1.gif";
                help1 = new Image;
                help1.src =  img_dir +"FNDIWHL1.gif";
                home1 = new Image;
                home1.src =  img_dir +"FNDIWHO1.gif";

            }');

   htp.p('
        var Restorable = false
        var Nav4 = ((navigator.appName == "Netscape") && (parseInt(navigator.appVersion) == 4))
        var Win32
        if (Nav4) {
                Win32 = ((navigator.userAgent.indexOf("Win") != -1) && (navigator.userAgent.indexOf("Win16") == -1))
        } else {
         Win32 = ((navigator.userAgent.indexOf("Windows") != -1) && (navigator.userAgent.indexOf("Windows 3.1") == -1))
        }
      function fprintFrame(wind) {
        // no single frame printing available for Mac
        if (Win32) {
                if (Nav4) {
                        window.print()
                } else {
                        // traps all script error messages hereafter until pagereload
                        window.onerror = fprintErr
                        // make sure desired frame has focus
                        wind.focus()
                        // change second parameter to 2 if you do not want the
                        // print dialog to appear
                        IEControl.ExecWB(6, 1)
                }
        } else {
                alert("Sorry. Printing is available only from Windows 95/98/NT.")
        }
      }

      function fprintErr() {
        return true
      }

    ');

   js.scriptClose;
END GenToolbarScript;

----------------------------------------------------------------------------
-- PROCEDURE GenToolbar
--
-- Generates the Toolbar
--  Written by: Shuh
--  Args:
--      p_title                 Title of the Toolbar
--      p_print_frame           Frame to print for the Print button
--      p_save_flag             true if save button should be on the toolbar
--      p_save_disabled_flag    true if save button is disabled
--      p_save_call             Function called when save button is pressed, i.e.
--                              'javascript:fSaveFunction()'
----------------------------------------------------------------------
PROCEDURE GenToolbar(p_title              VARCHAR2,
                     p_print_frame        VARCHAR2,
                     p_save_flag          BOOLEAN,
                     p_save_disabled_flag BOOLEAN,
                     p_save_call          VARCHAR2)
IS
BEGIN
    htp.p('<TABLE width=100% Cellpadding=0 Cellspacing=0 border=0>
        <TR>
        <TD width=10></TD>   <TD>
        <TABLE Cellpadding=0 Cellspacing=0 Border=0>');

    htp.p('<TD rowspan=3><img src="' || C_IMG_DIR || 'FNDGTBL.gif"></TD>
          <TD class=white height=1 colspan=3><img src="' || C_IMG_DIR || 'FNDPX6.gif"></TD>
          <TD rowspan=3><img src="' || C_IMG_DIR || 'FNDGTBR.gif"></TD>
        </TR>
        <TR>
          <TD class=ltgrey nowrap height=30 align=middle>
          <A href="javascript:parent.window.close();  parent.window.opener.focus(); target=_top;"
                 onmouseover="document.tbhome.src=home1.src; window.status=' || '&' || 'quot; Go to Main Menu' || '&' || 'quot;  ; return true;"
                 onmouseout="document.tbhome.src=' || '&' || 'quot;' || C_IMG_DIR || 'FNDIWHOM.gif' || '&' || 'quot;">
          <IMG name=tbhome src="' || C_IMG_DIR || 'FNDIWHOM.gif" align=middle border=0></A>
          <img src="' || C_IMG_DIR || 'FNDIWDVD.gif" align=absmiddle>
          </TD>
          <TD class=ltgrey nowrap height=30 align=middle>');

      htp.p('<FONT class=dropdownmenu>' || p_title || '</FONT>
          </TD>
          <TD class=toolbar nowrap height=30 align=middle><img src="' || C_IMG_DIR || 'FNDIWDVD.gif" align=absmiddle>');

  if (p_save_flag = TRUE) THEN --print the save button
      htp.p('   <A href="' || p_save_call || ';" onmouseover="document.tbsave.src=save1.src" onmouseout=' || '&' || 'quot;"document.tbsave.src=' || C_IMG_DIR || 'US/FNDIWSAV.gif' || '&' || 'quot;">
                <IMG name=tbsave src="' || C_IMG_DIR || 'FNDIWSAV.gif" align=absmiddle border=0></A>');
  elsif (p_save_disabled_flag = TRUE) THEN  --save button is disabled
      htp.p('<IMG src="' || C_IMG_DIR || 'FNDWPMNU.gif" align=absmiddle>');
  end if;

  htp.p('<A href="javascript:void fprintFrame(' || p_print_frame || ')" onmouseover="document.tbprint.src=print1.src; window.status=' || '&' || 'quot;Print' || '&' || 'quot; ;return true;"
            onmouseout="document.tbprint.src=' || '&' || 'quot;' || C_IMG_DIR || 'FNDIWPRT.gif' || '&' || 'quot;">
          <IMG name=tbprint src="' || C_IMG_DIR || 'FNDIWPRT.gif" align=absmiddle border=0></A>
          <img src="' || C_IMG_DIR || 'FNDIWDVD.gif" align=absmiddle>
          <A href="javascript:location.reload()" onmouseover="document.tbrefresh.src=refresh1.src; window.status=' || '&' || 'quot;Reload' || '&' || 'quot; ;return true;"
             onmouseout="document.tbrefresh.src=' || '&' || 'quot;' || C_IMG_DIR || 'FNDIWRLD.gif' || '&' || 'quot;">
          <IMG name=tbrefresh src="' || C_IMG_DIR || 'FNDIWRLD.gif" align=absmiddle border=0></A>
          <img src="' || C_IMG_DIR || 'FNDIWDVD.gif" align=absmiddle>
          <A href="javascript:top.help_window()" onmouseover="document.tbhelp.src=help1.src;window.status=' || '&' || 'quot;Help' || '&' || 'quot; ;return true;"
             onmouseout="document.tbhelp.src=' || '&' || 'quot;' || C_IMG_DIR || 'FNDIWHLP.gif' || '&' || 'quot;">
          <IMG name=tbhelp src="' || C_IMG_DIR || 'FNDIWHLP.gif" align=absmiddleborder=0></A>
        </TR>
        <TR>
          <TD class=canvas height=1 colspan=3><img src="' || C_IMG_DIR || 'FNDPX3.gif"></TD>
        </TR>
        </TABLE>
      </TD>
      <TD rowspan=5 width=100% align=right valign=top><img src="' || C_IMG_DIR || 'FNDLWAPP.gif"></TD>
     </TR>
     <TR><TD height=10></TD></TR>
     </TABLE>');

END GenToolbar;


---------------------------------------------------------------------
-- DESCRIPTION:
--   Having problems displaying buttons with the GenericButton and
--   DynamicButton procedures.  This is a simpler version of
--   DynamicButton.
--   bug 6045969 : stub the procedure as modplsql is obsolete in R12.
---------------------------------------------------------------------
PROCEDURE GenButton(P_Button_Text varchar2,
                    P_OnMouseOverText varchar2,
                    P_HyperTextCall varchar2) IS
BEGIN
  null;
End GenButton;

------------------------------------------------------------------------
-- PROCEDURE StyleSheet
--
-- Defines the class styles and colors in the cascading style
-- sheet format.
-- Written By: Shuh
-- This will be replaced by Dave's definitions in another file
------------------------------------------------------------------------
PROCEDURE StyleSheet IS
BEGIN
    --Cascading style sheet for the colors
    htp.p('<STYLE type="text/css">
        <!--
        .TOOLBAR     {BACKGROUND-COLOR: #cccccc}
        .BUTTON      {font-family: Arial, sans-serif; text-decoration:none; color:black; font-size:10pt}
        .DROPDOWNMENU {font-family: Arial, sans-serif; color: #003366;FONT-WEIGHT: BOLD;font-size: 14pt;}
        .CANVAS     {background-color: #336699;}
        .white      {background-color: #ffffff}
        .babyblue   {background-color: #99ccff}
        .ltblue     {background-color: #6699cc}
        .blue       {background-color: #336699}
        .dkblue     {background-color: #003366}
        .black      {background-color: #000000}
        .ltgrey     {background-color: #cccccc}
        .grey       {background-color: #999999}
        .dkgrey     {background-color: #666666}
        .ltblack    {background-color: #333333}
        -->
        </STYLE>');

END StyleSheet;

------------------------------------------------------------------------
-- FUNCTION RtrimMultiByteSpaces
-- Bug Fix : 2051803 - To remove all single and multibyte space
-- at the end of input string.
------------------------------------------------------------------------
FUNCTION RtrimMultiByteSpaces(p_input_string IN varchar2) RETURN VARCHAR2 IS
  l_temp AP_EXPENSE_REPORT_LINES.justification%type;
BEGIN
    l_temp := rtrim(rtrim(rtrim(rtrim(p_input_string),to_multi_byte(' '))),to_multi_byte(' '));
    IF ((l_temp <> '') AND
        ((substr(l_temp,length(l_temp)) = ' ') OR
         (substr(l_temp,length(l_temp)) = to_multi_byte(' ')))) THEN
           l_temp := RtrimMultiByteSpaces(l_temp);
    END IF;
    return(l_temp);
EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'RtrimMultiByteSpaces');
        DisplayException(fnd_message.get);
      END;
END;

------------------------------------------------------------------------
-- FUNCTION get_distance_display_value
-- Returns distance assuming that the original value is given in
-- kilometers
-- 5/30/2002 - Kristian Widjaja
------------------------------------------------------------------------
FUNCTION GetDistanceDisplayValue(p_value IN NUMBER,
         p_format IN VARCHAR2) RETURN NUMBER IS

  v_return NUMBER;
BEGIN
  if p_format = 'KM' then
    v_return := p_value;
  elsif p_format = 'MILES' then
    v_return := p_value * 100000/(2.54*12*5280);
  elsif p_format = 'SWMILES' then
    v_return := p_value / 10.0;
  end if;

  RETURN v_return;
END;

FUNCTION VALUE_SPECIFIC(p_name IN VARCHAR2,
         		p_user_id IN NUMBER default null,
			p_resp_id IN NUMBER default null,
			p_apps_id IN NUMBER default null)
RETURN VARCHAR2 IS
  l_web_user_id		Number := FND_PROFILE.VALUE('USER_ID');

BEGIN
  IF (l_web_user_id = p_user_id) THEN
    return FND_PROFILE.VALUE(NAME => p_name);
  ELSE
    return FND_PROFILE.VALUE_SPECIFIC(NAME            	 => p_name,
			       	      USER_ID		 => p_user_id,
			              RESPONSIBILITY_ID  => p_resp_id,
			              APPLICATION_ID     => p_apps_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('VALUE_SPECIFIC');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return null;
END VALUE_SPECIFIC;


/*
Written by:
  Maulik Vadera
Purpose:
  To get the override approver name, when profile option,
  IE:Approver Required = "Yes with Default" and approver name is not provided
  in the upload SpreadSheet data.
  Fix for bug 3786831
Input:
  p_EmpId: Employee Id of the employee
Output:
  Override approver Id for that Employee Id
  Override approver name for that Employee Id
Date:
  21-Mar-2005
*/


PROCEDURE GetOverrideApproverDetail(p_EmpId IN NUMBER,
                                      p_appreq IN VARCHAR2,
                                      p_ApproverId OUT NOCOPY HR_EMPLOYEES.employee_num%TYPE,
                                      p_OverrideApproverName OUT NOCOPY HR_EMPLOYEES.full_name%TYPE) IS


  l_DefaultCostCenter          VARCHAR2(80);
  l_EmployeeNum                HR_EMPLOYEES.employee_num%TYPE := 100;
  l_DefaultSource              VARCHAR2(30) := NULL;
  l_TempBoolean                BOOLEAN;
  l_ManagerOrgId               NUMBER;

  BEGIN

   SELECT DEFAULT_APPROVER_ID, DEFAULT_SOURCE into p_ApproverId, l_DefaultSource
   FROM AP_WEB_PREFERENCES
   WHERE EMPLOYEE_ID = p_EmpId;

   IF l_DefaultSource = 'PRIORREPORT' THEN

   --If preferences's default source is Prior Report

        SELECT OVERRIDE_APPROVER_ID into p_ApproverId
        FROM
        (    SELECT OVERRIDE_APPROVER_ID
             FROM AP_EXPENSE_REPORT_HEADERS_ALL
             WHERE EMPLOYEE_ID = p_EmpId AND BOTHPAY_PARENT_ID IS  NULL
             ORDER BY report_header_id DESC
        ) WHERE ROWNUM=1;

     IF AP_WEB_DB_HR_INT_PKG.IsPersonActive(p_ApproverId) = 'Y'
        AND AP_WEB_DB_HR_INT_PKG.HasValidFndUserAndWfAccount(p_ApproverId)= 'Y' THEN

     --if approver is an active user of the system, return the approver's name

             GetEmployeeInfo(
                                          p_OverrideApproverName,
                                          l_EmployeeNum,
                                          l_DefaultCostCenter,
                                          p_ApproverId);

     ELSE

     --if approver is not an active user of the system, return null

             p_ApproverId := NULL;
             p_OverrideApproverName := NULL;

     END IF;

   ELSIF l_DefaultSource = 'PREFERENCES' AND p_ApproverId IS NOT NULL THEN

   --If preferences's default source is Preferences and Approver's name is  provided by user

      IF AP_WEB_DB_HR_INT_PKG.IsPersonActive(p_ApproverId) = 'Y'
         AND AP_WEB_DB_HR_INT_PKG.HasValidFndUserAndWfAccount(p_ApproverId)= 'Y' THEN

      --if approver is an active user of the system

           GetEmployeeInfo(
                                  p_OverrideApproverName,
                                  l_EmployeeNum,
                                  l_DefaultCostCenter,
                                  p_ApproverId);
      ELSE
       IF p_appreq='D' THEN

      --if approver is not an active user of the system, default approver from the HRMS

            l_TempBoolean := AP_WEB_DB_HR_INT_PKG.GetSupervisorInfo(p_EmpId,
                                                                    p_ApproverId,
                                                                    p_OverrideApproverName,
                                                                     l_ManagerOrgId);
        ELSE
         p_ApproverId := NULL;
         p_OverrideApproverName := NULL;

        END IF;

     END IF;


   ELSE

   --In case employee hasn't provided approver's name in preferences

     IF p_appreq='D' THEN

        l_TempBoolean := AP_WEB_DB_HR_INT_PKG.GetSupervisorInfo(p_EmpId,
                                                             p_ApproverId,
                                                             p_OverrideApproverName,
                                                             l_ManagerOrgId);
     ELSE

         p_ApproverId := NULL;
         p_OverrideApproverName := NULL;

    END IF;


   END IF;

   RETURN;

  EXCEPTION
    WHEN no_data_found  THEN

     --If there is no data in the AP_WEB_PREFERENCES
     --then default approver from the HRMS
      IF l_DefaultSource IS NULL THEN
          IF p_appreq='D' THEN
               l_TempBoolean := AP_WEB_DB_HR_INT_PKG.GetSupervisorInfo(p_EmpId,
                                                                 p_ApproverId,
                                                                 p_OverrideApproverName,
                                                                 l_ManagerOrgId);
          ELSE
              p_ApproverId := NULL;
              p_OverrideApproverName := NULL;
          END IF;
     ELSE

          p_ApproverId := NULL;
          p_OverrideApproverName := NULL;

     END IF;

    WHEN OTHERS THEN
          raise;

  END GetOverrideApproverDetail;

/*=======================================================================
 | PUBLIC FUNCITON: OrgSecurity
 |
 | DESCRIPTION: This function will return the security predicate
 |              for  expense report templates and expense types table.
 |              It ensures that the seeded template and expense types
 |              with org_id = -99 are also picked up when querying
 |              the secured synonym
 |
 | PARAMETERS
 |      obj_schema       IN VARCHAR2  Object Schema
 |      obj_name         IN VARCHAR2  Object Name
 |
 | RETURNS
 |      Where clause to be appended to the object.
 *=======================================================================*/
FUNCTION OrgSecurity ( obj_schema VARCHAR2,
                        obj_name   VARCHAR2) RETURN VARCHAR2
IS
   l_access_mode VARCHAR2(10);
BEGIN
   -- Get the current access mode
   l_access_mode := MO_GLOBAL.get_access_mode();

   --
   --  Returns different predicates based on the access_mode
   --  The codes for access_mode are
   --  M - Multiple OU Access
   --  A - All OU Access
   --  S - Single OU Access
   --  Null - Backward Compatibility - CLIENT_INFO case  --
   IF l_access_mode IS NOT NULL THEN
      IF l_access_mode = 'M' THEN
         RETURN 'EXISTS (SELECT 1
                         FROM mo_glob_org_access_tmp oa
                         WHERE oa.organization_id = org_id
                        )
                 OR    org_id = -99';
      ELSIF l_access_mode = 'S' THEN
         RETURN 'org_id IN ( sys_context(''multi_org2'',''current_org_id''), -99)';
      ELSIF l_access_mode = 'A' THEN -- for future use
         RETURN NULL;
      END IF;
   ELSE
      RETURN 'org_id IN ( substrb(userenv(''CLIENT_INFO''),1,10), -99 )';
   END IF;

 END OrgSecurity;

 PROCEDURE ExpenseSetOrgContext(p_report_header_id	IN NUMBER) IS
l_org_id	NUMBER;
BEGIN

	IF (AP_WEB_DB_EXPRPT_PKG.GetOrgIdByReportHeaderId(
				p_report_header_id,
				l_org_id) <> TRUE ) THEN
		l_org_id := NULL;
	END IF;

    IF (l_org_id IS NOT NULL) THEN
 	fnd_client_info.set_org_context( l_org_id );
    END IF;
END ExpenseSetOrgContext;

-- Bug: 6220330, added a new parameter so that the trigger on ap_invoices_all can use this.
PROCEDURE UpdateExpenseStatusCode(
        p_invoice_id AP_INVOICES_ALL.invoice_id%TYPE,
 	p_pay_status_flag       AP_INVOICES_ALL.payment_status_flag%TYPE DEFAULT NULL
) IS

  t_paid_status                 CONSTANT VARCHAR2(10) := 'PAID';
  t_partially_paid_status       CONSTANT VARCHAR2(10) := 'PARPAID';
  t_invoiced_status             CONSTANT VARCHAR2(10) := 'INVOICED';

  l_expenses_to_update          ExpensesToUpdate;

  l_parent_report_header_id AP_EXPENSE_REPORT_HEADERS_ALL.report_header_id%TYPE;
  l_parent_invoice_status varchar2(100);
  l_main_report_header_id AP_EXPENSE_REPORT_HEADERS_ALL.report_header_id%TYPE;
  l_main_invoice_status varchar2(100);
  l_child_report_header_id AP_EXPENSE_REPORT_HEADERS_ALL.report_header_id%TYPE;
  l_child_invoice_status varchar2(100);

  l_parent_report_status VARCHAR2(100);
  l_main_report_status VARCHAR2(100);

  l_payment_status              AP_INVOICES_ALL.payment_status_flag%TYPE;

  l_report_header_id    AP_EXPENSE_REPORT_HEADERS_ALL.report_header_id%TYPE;
  l_invoice_status      VARCHAR2(100);
  l_identifier          VARCHAR2(100);
  -- Bug: 9158198
  l_web_user_id         Number := FND_PROFILE.VALUE('USER_ID');

BEGIN


   --
   -- initialize the status variables
   --
   l_parent_report_status := NULL; l_main_report_status := NULL;

  --
  -- open the cursor and populate the variables
  --
  -- Bug: 6220330, Get the appropriate Cursor
  AP_WEB_UTILITIES_PKG.GetExpensesToUpdate(p_invoice_id, p_pay_status_flag, l_expenses_to_update);

  LOOP
    FETCH l_expenses_to_update
    INTO  l_identifier, l_report_header_id, l_invoice_status;

    EXIT WHEN l_expenses_to_update%NOTFOUND;

     IF ( l_identifier = 'PARENT' )
     THEN
        l_parent_report_header_id := l_report_header_id;
        l_parent_invoice_status := l_invoice_status;
     ELSIF (l_identifier = 'MAIN')
     THEN
        l_main_report_header_id := l_report_header_id;
        l_main_invoice_status := l_invoice_status;
     ELSE
        l_child_report_header_id := l_report_header_id;
        l_child_invoice_status := l_invoice_status;
     END IF;

  END LOOP;

  --
  -- handle separately if the current invoice has parent reports / child reports
  -- or it is a single cash based report
  --

  IF ( l_parent_report_header_id IS NOT NULL )
  THEN

    --
    -- So the current invoice has a parent which means the current invoice is of Credit Card
    -- in which case, the parent report status should change in the following manner
    --         PARENT STATUS                         PARENT NEW STATUS
    --              Invoiced               -->        Partially Paid
    --                Paid                 -->        < main invoice status >
    --             Partially Paid          -->        Partially Paid ( no update )
    --             <any other status>      -->        ( no update )
    --

    l_main_report_status := l_main_invoice_status;

    IF (( l_parent_invoice_status = t_invoiced_status ) AND ( l_main_invoice_status = t_invoiced_status ))
    THEN
      l_parent_report_status := t_invoiced_status;
    ELSIF ( l_parent_invoice_status = t_partially_paid_status ) OR (l_main_invoice_status = t_partially_paid_status)
            OR
          (( l_parent_invoice_status = t_invoiced_status ) AND (l_main_invoice_status = t_paid_status))
    THEN
      l_parent_report_status := t_partially_paid_status;
    ELSIF ( l_parent_invoice_status = t_paid_status )
    THEN
      l_parent_report_status := l_main_invoice_status;
    END IF;
  ELSIF ( l_child_report_header_id IS NOT NULL )
  THEN
    --
    -- So the current invoice is the parent, so the child status should also be considered before updating
    -- in which case, the report status should change in the following manner
    --            CHILD STATUS                      MAIN NEW STATUS
    --          Invoiced/Partially Paid    -->        Partially Paid
    --                Paid                 -->        < main invoice status >
    --             <any other status>      -->        ( no update )
    --

      IF ( ( l_child_invoice_status = t_invoiced_status ) AND ( l_main_invoice_status = t_invoiced_status ) )
      THEN
        l_main_report_status := t_invoiced_status;
      ELSIF ( l_child_invoice_status = t_partially_paid_status ) OR ( l_child_invoice_status = t_invoiced_status ) OR
      (l_main_invoice_status = t_partially_paid_status)
            OR
            (( l_child_invoice_status = t_paid_status ) AND (l_main_invoice_status = t_invoiced_status))
      THEN
        l_main_report_status := t_partially_paid_status;
      ELSIF ( l_child_invoice_status = t_paid_status )
      THEN
        l_main_report_status := l_main_invoice_status;
      END IF;

  ELSE

    --
    -- A simple cash based report that does not have parent or child reports to it
    -- So just update this expense's status
    --

    l_main_report_status := l_main_invoice_status;

  END IF;

  IF ( l_parent_report_status IS NOT NULL )
  THEN

    -- Bug: 9158198, WHO Columns not updated.
    UPDATE ap_expense_report_headers_all
    SET    expense_status_code = l_parent_report_status,
 	   last_update_date = sysdate,
 	   last_updated_by = nvl(l_web_user_id, last_updated_by)
    WHERE report_header_id = l_parent_report_header_id;
  END IF;

  IF (  l_main_report_status IS NOT NULL )
  THEN

    -- Bug: 9158198, WHO Columns not updated.
    UPDATE ap_expense_report_headers_all
    SET    expense_status_code = l_main_report_status,
 	   last_update_date = sysdate,
 	   last_updated_by = nvl(l_web_user_id, last_updated_by)
    WHERE report_header_id = l_main_report_header_id;

  END IF;

END UpdateExpenseStatusCode;

--------------------------------------------------------------
-- Returns True if the input contains a character
--------------------------------------------------------------
FUNCTION ContainsChars(p_element IN VARCHAR2) RETURN BOOLEAN IS
l_return_value BOOLEAN := FALSE;
l_value NUMBER := 0;

BEGIN
    IF( INSTR(UPPER(p_element),'E') > 0 OR INSTR(p_element,'.') > 0 ) THEN
        l_return_value := TRUE;
    ELSE
        l_value := TO_NUMBER(p_element);
        l_return_value := FALSE;
    END IF;

    RETURN l_return_value;

EXCEPTION WHEN VALUE_ERROR THEN
    RETURN TRUE;

END ContainsChars;

-- Bug: 6220330, Expenses are updated from two triggers, one on AP_INVOICES_ALL and
-- one on AP_INVOICE_PAYMENTS_ALL. If p_pay_status_flag is null, the trigger is
-- on AP_INVOICE_PAYMENTS_ALL, and on AP_INVOICES_ALL other wise.

 PROCEDURE GetExpensesToUpdate(p_invoice_id         IN    AP_INVOICES_ALL.invoice_id%TYPE,
			       p_pay_status_flag    IN    AP_INVOICES_ALL.payment_status_flag%TYPE,
			       p_expenses_to_update OUT NOCOPY ExpensesToUpdate) IS
 BEGIN
  IF (p_pay_status_flag IS NULL) THEN
   -- For the trigger on AP_INVOICE_PAYMENTS_ALL
   OPEN p_expenses_to_update FOR
    -- cc in bp
    SELECT 'PARENT' Identifier,
	   parent_aerh.report_header_id report_header_id,
	   DECODE(parent_APS.GROSS_AMOUNT ,0,'PAID',
				   DECODE(parent_AI.Payment_status_flag,
					    'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
    FROM ap_expense_report_headers_all parent_aerh,
	 ap_expense_report_headers_all main_aerh,
	 ap_invoices_all parent_ai,
	 ap_payment_schedules_all parent_aps
 WHERE
	  main_aerh.bothpay_parent_id = parent_aerh.report_header_id (+) and
	  parent_aerh.vouchno = parent_ai.invoice_id and
	  parent_ai.invoice_id = parent_aps.invoice_id and
	  main_aerh.vouchno = p_invoice_id
    UNION
    -- main/actual cash or cc
    SELECT 'MAIN' Identifier,
	   main_aerh.report_header_id report_header_id,
	   DECODE(main_APS.GROSS_AMOUNT ,0,'PAID',
				   DECODE(main_AI.Payment_status_flag,
					    'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
    FROM
	 ap_expense_report_headers_all main_aerh,
	 ap_invoices_all main_ai,
	 ap_payment_schedules_all main_aps
    WHERE
	 main_aerh.vouchno = main_ai.invoice_id and
	 main_ai.invoice_id = main_aps.invoice_id and
	 main_aerh.vouchno = p_invoice_id
    UNION
    -- cash in bp
    SELECT 'CHILD' Identifier,
	   child_aerh.report_header_id report_header_id,
	   DECODE(child_APS.GROSS_AMOUNT ,0,'PAID',
				   DECODE(child_AI.Payment_status_flag,
					    'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
    FROM
	 ap_expense_report_headers_all child_aerh,
	 ap_expense_report_headers_all main_aerh,
	 ap_invoices_all child_ai,
	 ap_payment_schedules_all child_aps
    WHERE child_aerh.bothpay_parent_id (+) = main_aerh.report_header_id and
	 child_aerh.vouchno = child_ai.invoice_id and
	 child_ai.invoice_id = child_aps.invoice_id and
	 main_aerh.vouchno = p_invoice_id;
 ELSE
    OPEN p_expenses_to_update FOR
     -- For the trigger on AP_INVOICES_ALL
     -- cc in bp
     SELECT 'PARENT' Identifier,
	    parent_aerh.report_header_id report_header_id,
	    DECODE(parent_APS.GROSS_AMOUNT ,0,'PAID',
				   DECODE(p_pay_status_flag,
					    'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
     FROM ap_expense_report_headers_all parent_aerh,
	  ap_expense_report_headers_all main_aerh,
	  ap_payment_schedules_all parent_aps
     WHERE
	  main_aerh.bothpay_parent_id = parent_aerh.report_header_id (+) and
	  parent_aerh.vouchno = parent_aps.invoice_id and
	  main_aerh.vouchno = p_invoice_id
     UNION
     -- main/actual cash or cc
     SELECT 'MAIN' Identifier,
	    main_aerh.report_header_id report_header_id,
	    DECODE(main_APS.GROSS_AMOUNT ,0,'PAID',
				   DECODE(p_pay_status_flag,
					    'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
     FROM
	  ap_expense_report_headers_all main_aerh,
	  ap_payment_schedules_all main_aps
     WHERE
	  main_aerh.vouchno =  main_aps.invoice_id and
	  main_aerh.vouchno = p_invoice_id
     UNION
     -- cash in bp
     SELECT 'CHILD' Identifier,
	  child_aerh.report_header_id report_header_id,
	  DECODE(child_APS.GROSS_AMOUNT ,0,'PAID',
				 DECODE(p_pay_status_flag,
					  'Y','PAID','N','INVOICED','P','PARPAID',NULL) ) invoice_status
     FROM
	 ap_expense_report_headers_all child_aerh,
	 ap_expense_report_headers_all main_aerh,
	 ap_payment_schedules_all child_aps
     WHERE child_aerh.bothpay_parent_id (+) = main_aerh.report_header_id and
	   child_aerh.vouchno = child_aps.invoice_id and
	   main_aerh.vouchno = p_invoice_id;

  END IF;
  EXCEPTION WHEN OTHERS THEN
   RAISE;
 END GetExpensesToUpdate;

------------------------------------------------------------------------
-- FUNCTION Oie_Round_Currency
-- Bug 6136103
-- Returns Amount in the Rounded format per spec in fnd_currencies
-- Introduced as aputilsb.ap_round_currency errors out due to Caching.
------------------------------------------------------------------------
FUNCTION Oie_Round_Currency
                         (P_Amount         IN number
                         ,P_Currency_Code  IN varchar2)
RETURN number is
  l_rounded_amount  number;
BEGIN
                                                                         --
  select  decode(FC.minimum_accountable_unit,
            null, decode(FC.precision, null, null, round(P_Amount,FC.precision)),
                  round(P_Amount/FC.minimum_accountable_unit) *
                               FC.minimum_accountable_unit)
  into    l_rounded_amount
  from    fnd_currencies FC
  where   FC.currency_code = P_Currency_Code;
                                                                         --
  return(l_rounded_amount);
                                                                         --
EXCEPTION

  WHEN NO_DATA_FOUND THEN
	return (null);
                                                                         --
END Oie_Round_Currency;

PROCEDURE UpdateImageReceiptStatus(p_report_header_id IN NUMBER) IS
l_mgr_appr_flag	VARCHAR2(10);
l_stage_code	VARCHAR2(30);
BEGIN

  AP_WEB_EXPENSE_WF.CompleteReceiptsBlock(to_char(p_report_header_id));

  SELECT nvl(workflow_approved_flag,'X') into l_mgr_appr_flag FROM AP_EXPENSE_REPORT_HEADERS_ALL
  WHERE report_header_id = p_report_header_id;

  UPDATE ap_expense_report_headers_all SET image_receipts_status = 'RECEIVED',
	image_receipts_received_date = sysdate,
	last_update_date = sysdate,
        last_updated_by = Decode(Nvl(fnd_global.user_id,-1),-1,last_updated_by,fnd_global.user_id)
	WHERE report_header_id = to_number(p_report_header_id);

  AP_WEB_RECEIPTS_WF.RaiseReceivedEvent(p_report_header_id);
  AP_WEB_UTILITIES_PKG.AddReportToAuditQueue(p_report_header_id);
/*
  select nvl(rs.recpt_assign_stage_code,'X') into l_stage_code
    from   ap_expense_report_headers_all aerh,
           ap_aud_rule_sets rs,
           ap_aud_rule_assignments_all rsa
    where aerh.report_header_id = p_report_header_id
    and   aerh.org_id = rsa.org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'RULE'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  IF (l_stage_code = 'RECPT_RECVD' OR (l_stage_code = 'MGR_APPR_IMG' AND l_mgr_appr_flag = 'M')) THEN
	AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(p_report_header_id);
  END IF;
*/
END UpdateImageReceiptStatus;

PROCEDURE AddReportToAuditQueue(p_report_header_id IN NUMBER) IS
l_mgr_appr_flag VARCHAR2(10);
l_stage_code    VARCHAR2(30);
BEGIN
select nvl(rs.recpt_assign_stage_code,'X') into l_stage_code
    from   ap_expense_report_headers_all aerh,
           ap_aud_rule_sets rs,
           ap_aud_rule_assignments_all rsa
    where aerh.report_header_id = p_report_header_id
    and   aerh.org_id = rsa.org_id
    and   rsa.rule_set_id = rs.rule_set_id
    and   rs.rule_set_type = 'RULE'
    and   TRUNC(SYSDATE)
            BETWEEN TRUNC(NVL(rsa.START_DATE,SYSDATE))
            AND     TRUNC(NVL(rsa.END_DATE,SYSDATE));

  IF (l_stage_code = 'RECPT_RECVD' OR (l_stage_code = 'MGR_APPR_IMG' AND l_mgr_appr_flag = 'M')) THEN
        AP_WEB_AUDIT_QUEUE_UTILS.enqueue_for_audit(p_report_header_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   NULL;
END AddReportToAuditQueue;

FUNCTION GetImageAttachmentStatus(p_report_header_id IN NUMBER) RETURN VARCHAR2 IS

CURSOR line_cursor IS select report_line_id, NVL(image_receipt_required_flag,'N') image_receipt_required_flag
FROM ap_expense_report_lines_all where report_header_id = p_report_header_id
AND (itemization_parent_id is null or itemization_parent_id = -1);

line_rec		line_cursor%ROWTYPE;
l_header_attach		VARCHAR2(2);
l_line_attach		VARCHAR2(2);
l_rcpt_req_flag		BOOLEAN := FALSE;
l_rcpt_notreq_flag	BOOLEAN := FALSE;
l_count			NUMBER := 0;
BEGIN

--l_header_attach := fnd_attachment_util_pkg.get_atchmt_exists('OIE_HEADER_ATTACHMENTS', to_char(p_report_header_id));
l_header_attach := GetAttachmentExists('OIE_HEADER_ATTACHMENTS', to_char(p_report_header_id));

IF (l_header_attach = 'Y') THEN
	RETURN 'RECEIVED';
END IF;
OPEN line_cursor;
LOOP
  FETCH  line_cursor INTO line_rec;
	l_rcpt_notreq_flag := FALSE;
	IF (line_rec.image_receipt_required_flag = 'Y') THEN
		l_count := l_count + 1;
		--l_line_attach := fnd_attachment_util_pkg.get_atchmt_exists('OIE_LINE_ATTACHMENTS', to_char(line_rec.report_line_id));
		l_line_attach := GetAttachmentExists('OIE_LINE_ATTACHMENTS', to_char(line_rec.report_line_id));
		IF (l_line_attach = 'N') THEN
			l_rcpt_req_flag := TRUE;
		END IF;
	ELSIF (NOT l_rcpt_req_flag AND l_count = 0 AND line_rec.image_receipt_required_flag = 'N') THEN
		l_rcpt_notreq_flag := TRUE;
	END IF;
  EXIT WHEN line_cursor%NOTFOUND;
END LOOP;
CLOSE line_cursor;

IF l_rcpt_req_flag THEN
	RETURN 'REQUIRED';
ELSIF l_rcpt_notreq_flag THEN
	RETURN 'NOT_REQUIRED';
ELSE
	RETURN 'RECEIVED';
END IF;

EXCEPTION
	WHEN OTHERS THEN
	RETURN 'REQUIRED';
END GetImageAttachmentStatus;

FUNCTION GetAttachmentExists(p_entity_name IN VARCHAR2, p_value IN VARCHAR2) RETURN VARCHAR2 IS

  CURSOR attach_cur IS
  SELECT 1 FROM FND_ATTACHED_DOCUMENTS
  WHERE entity_name = p_entity_name AND pk1_value = p_value AND ROWNUM = 1;

  attach_rec	attach_cur%ROWTYPE;

BEGIN

  OPEN attach_cur;
  FETCH attach_cur INTO attach_rec;
  IF attach_cur%FOUND THEN
     CLOSE attach_cur;
     RETURN 'Y';
  ELSE
     CLOSE attach_cur;
     RETURN 'N';
  END IF;

END GetAttachmentExists;

FUNCTION GetShortPaidReportMsg(p_report_header_id in NUMBER) RETURN VARCHAR2 IS
  CURSOR shortpay_reports IS
  SELECT invoice_num FROM AP_EXPENSE_REPORT_HEADERS_ALL
  WHERE shortpay_parent_id = p_report_header_id
  AND receipts_status = 'IN_PARENT_PACKET';

  l_invoice_num		AP_EXPENSE_REPORT_HEADERS_ALL.INVOICE_NUM%TYPE;
  l_concat		VARCHAR2(2000) := '';
BEGIN
  OPEN shortpay_reports;
  LOOP
   FETCH shortpay_reports INTO l_invoice_num;
   EXIT WHEN shortpay_reports%NOTFOUND;
   IF (l_concat <> '') THEN
     l_concat := l_concat || ',';
   END IF;
   l_concat := l_concat || l_invoice_num;
  END LOOP;
  RETURN l_concat;
EXCEPTION
  WHEN OTHERS THEN
    RETURN '';
END GetShortPaidReportMsg;

END AP_WEB_UTILITIES_PKG;

/
