--------------------------------------------------------
--  DDL for Package Body AP_WEB_DISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DISC_PKG" AS
/* $Header: apwdiscb.pls 120.25.12010000.2 2008/08/06 10:15:06 rveliche ship $ */
--
-- Data section
--

-- This is to store information for a segment
TYPE segmentPrompt IS RECORD
  (
--chiho:1305717:change the data type:
   exptype        AP_WEB_DB_EXPLINE_PKG.expLines_expendType,

   segment_num    number,
   default_value  fnd_descr_flex_col_usage_vl.default_value%TYPE,

--chiho:1305717:change the data type:
   prompt         fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE,

   found          BOOLEAN,
   webEnabled     BOOLEAN
  );

TYPE segmentPrompt_table IS TABLE OF segmentPrompt
INDEX BY BINARY_INTEGER;

TYPE expIndex_table IS TABLE OF number
INDEX BY BINARY_INTEGER;


C_Grp_Size CONSTANT INTEGER := 80;
C_Just_Size CONSTANT INTEGER := 240;
C_Purpose_Size CONSTANT INTEGER := 240;
C_CostCenter_Size CONSTANT INTEGER := 30;
C_XTemplate_Size CONSTANT INTEGER := 25;
C_Approver_Size CONSTANT INTEGER := 240;
C_MiniString_Size CONSTANT INTEGER := 80;

/* The prompt index are relative to AP_WEB_EXP_VIEW_REC */
C_Date1_Prompt CONSTANT  varchar2(3) := '6';
C_Date2_Prompt CONSTANT  varchar2(3) := '7';
C_Days_Prompt  CONSTANT  varchar2(3) := '8';
C_DAmount_Prompt CONSTANT varchar2(3) := '9';
C_Amount_Prompt CONSTANT  varchar2(3) := '23';
C_Exptype_Prompt CONSTANT varchar2(3) := '11';
C_Just_Prompt  CONSTANT  varchar2(3) := '12';
C_Grp_Prompt CONSTANT varchar2(3) := '24';
C_Missing_Prompt CONSTANT varchar2(3) := '15';
C_RecAmt_Prompt CONSTANT varchar2(3) := '10';
C_Rate_Prompt CONSTANT varchar2(3) := '22';
C_RecCurr_Prompt CONSTANT varchar2(3) := '21';
C_GLOBAL CONSTANT varchar2(6):='GLOBAL';

-- Constants passed as P_GenErrorOrWarning argument to GenReceiptErrorTable
C_GenErrorOnly         CONSTANT NUMBER := 1;
C_GenWarningOnly       CONSTANT NUMBER := 2;

procedure GetTill(p_exp in out nocopy long,
		  p_item out nocopy long,
		  p_sep in varchar2);

PROCEDURE GetLine(p_exp in out nocopy long,
		  p_line out nocopy long,
		  p_max in number default 2000);

PROCEDURE GetField(p_line in out nocopy long,
		   p_field out nocopy long,
		   p_max in number default 300);

PROCEDURE GetNonEmptyFld(p_line in out nocopy long,
			 p_field out nocopy long,
			 p_max in number default 300);

function SwapPrompts(p_table in out nocopy disc_prompts_table,
		      p_from in number,
		      P_to in number) return boolean;

function ReportTotal(Amount_Array in AP_WEB_PARENT_PKG.MiniString_Array)
	return number;

function ReportTotal2(ExpLine_Array in AP_WEB_DFLEX_PKG.ExpReportLines_A)
	return number;

function isValidCurrency (p_currency_code IN AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode)
        return boolean;


procedure getFlexFieldGlobalSegments(p_user_id in NUMBER, -- Bug 2242176
                                     p_segments in out nocopy FND_DFLEX.SEGMENTS_DR);

procedure getAllSegmentPrompts(p_user_id in NUMBER, -- Bug 2242176
                               p_report_header_info in AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
                               p_segmentPromptTable in out nocopy segmentPrompt_table);

procedure checkValidFlexFieldPrompt(p_fld in varchar2,
                                    p_segmentPromptTable in segmentPrompt_table,
                                    p_expIndexTable in expIndex_table,
                                    p_number in out nocopy number);

procedure initIndexAndDflexTable(p_segmentPromptTable in segmentPrompt_table ,
                                  p_dflexTable in out nocopy AP_WEB_DFLEX_PKG.CustomFields_A,
                                  p_expIndexTable in out nocopy expIndex_table);

procedure setupIndexAndDflexTable(p_expType in varchar2,
                                  p_segmentPromptTable in segmentPrompt_table ,
                                  p_dflexTable in out nocopy AP_WEB_DFLEX_PKG.CustomFields_A,
                                  p_expIndexTable in out nocopy expIndex_table);

--------------------------------
/* Fills the disc_prompts_table with the prompts retrieved from p_reg_code
region. The prompt_text field in the zeroth element contains the element count. */

PROCEDURE Disc_GetPrompts(
	p_reg_code 	in 	AK_REGION_ITEMS_VL.region_code%TYPE,
	p_table 	in out nocopy 	DISC_PROMPTS_TABLE
) IS
---------------------------------
l_count         number;
l_error		varchar2(500) := '';
l_prompt_cursor	 PromptsCursor;

BEGIN

l_count := 1;

IF ( GetAKRegionPromptsCursor(p_reg_code,
			      l_prompt_cursor) = TRUE ) THEN
	loop
  		fetch l_prompt_cursor into
			p_table(l_count).prompt_text,
		   	p_table(l_count).prompt_code;

  		exit when l_prompt_cursor%NOTFOUND;

  		l_count := l_count + 1;

	end loop;

	close l_prompt_cursor;
END IF;

EXCEPTION
  when OTHERS then
   begin
    l_count := p_table.COUNT;
    LOOP
      l_error := p_table(l_count).prompt_code || ' ' || l_error;
      if (l_count = 1) then
        exit;
      end if;
      l_count := l_count - 1;
    END LOOP;
    l_error := p_table.COUNT || '#' || l_error;

     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'Disc_GetPrompts');
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO','');
     FND_MESSAGE.SET_TOKEN('PARAMETERS', l_error);
     APP_EXCEPTION.RAISE_EXCEPTION;
   end; /* when OTHERS */

END Disc_GetPrompts;

-----------------------------------
Function Disc_GetPrompt(p_prompt_text in varchar2,
			p_table in disc_prompts_table) return varchar2 IS
-----------------------------------

l_count number := 1;

BEGIN

  if (p_table.COUNT = 0) then
    return null;
  end if;
  loop
    if (p_table(l_count).prompt_text = p_prompt_text) then
      return(p_table(l_count).prompt_code);
    end if;
    if (l_count = p_table.COUNT) then
      return null;
    end if;
    l_count := l_count + 1;
  end loop;

END Disc_GetPrompt;

------------------------------------
Function Disc_GetPromptIndex(p_prompt_text in varchar2,
			     p_table in disc_prompts_table) return number IS
------------------------------------

l_count number := 1;

BEGIN

  if (p_table.COUNT = 0) then
    return 0;
  end if;
  loop
    if (p_table(l_count).prompt_text = p_prompt_text) then
      return(l_count);
    end if;
    if (l_count = p_table.COUNT) then
      return 0;
    end if;
    l_count := l_count + 1;
  end loop;

END Disc_GetPromptIndex;


/* Call disc_getprompts to populate p_table with prompt_text and
prompt_code from AP_WEB_DISC_EXP region. Then fill in the proper
value for required and duplicate flags in p_table.
Possible value for the required flag:
'H' - required in the Header,
'R' - required in the receipts section,
'NH' - in header, but not required,
'NR' - in receipts, but not required,
'F' - found.
A note on 'amount' fields: initially only recamt is set to 'R' as required in
receipts section.  Later on after parsing the header columns, if recamt is
not found, but dailyamt is there, that's ok.
Quan: Add the flexfield global prompts to p_table.
*/

PROCEDURE AP_WEB_INIT_PROMPTS_ARRAY(p_user_id in number, -- bug 2242176
                                    p_table in out nocopy DISC_PROMPTS_TABLE,
				    p_format_errors in out nocopy setup_error_stack)
IS

l_region_code varchar2(100) := 'AP_WEB_DISC_EXP';
l_count number := 1;
l_prompt_code varchar2(200) := '';
l_AllowOverriderFlag varchar2(1) := 'N';
l_ApprReqCC varchar2(1) := 'N';
l_OverriderReq varchar2(1) := 'N';
zero_prompts_found varchar2(200) := 'No prompts found';
l_segments  FND_DFLEX.SEGMENTS_DR;  -- For Flexfield global segments

BEGIN

  Disc_GetPrompts(l_region_code, p_table);
  if (p_table.COUNT = 0) then
  /* Maybe the region doesn't even exist, or it's empty. Can't continue ... */
    p_format_errors(p_format_errors.COUNT+1) := zero_prompts_found;
    return;
  end if;

  -- Use VALUE_SPECIFIC instead of GET - bug 2242176
  l_AllowOverriderFlag := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_ALLOW_OVERRIDE_APPROVER',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);

  -- Overrider required if costcenter is different from your own?
  l_ApprReqCC := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_APPROVER_REQ_CC',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);

  -- Override Approver is required?
  l_OverriderReq := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_OVERRIDE_APPR_REQ',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);

  LOOP
    if (l_count = p_table.COUNT+1) then
      exit;
    end if;
    p_table(l_count).global_flag := false;
    l_prompt_code := p_table(l_count).prompt_code;

    if ((l_prompt_code = 'AP_WEB_COSTCTR') OR
	(l_prompt_code = 'AP_WEB_PURPOSE') OR
	(l_prompt_code = 'AP_WEB_EXP_TEMP')) then
      p_table(l_count).required := 'H';
    elsif (l_prompt_code = 'AP_WEB_OVERRIDE_APPROVER') then
      if ((l_AllowOverriderFlag = 'Y') AND ((l_ApprReqCC = 'Y')
		OR (l_OverriderReq = 'Y'))) then
        p_table(l_count).required := 'H';
      else
	p_table(l_count).required := 'NH';
      end if;
    elsif ((l_prompt_code = 'AP_WEB_LINE') OR
	   (l_prompt_code = 'AP_WEB_STARTDATE') OR
	   (l_prompt_code = 'AP_WEB_RECPT_MISSING') OR
	   (l_prompt_code = 'AP_WEB_JUST')) then
      p_table(l_count).required := 'R';
    else
      p_table(l_count).required := 'NR';
    end if;
    l_count := l_count + 1;
  END LOOP;

  -- Add the flexfield global prompts to p_table
    getFlexFieldGlobalSegments(p_user_id,  -- Bug 2242176 employee fnd user id
                               l_segments);


    FOR i in 1..l_segments.nsegments LOOP
     if (l_segments.is_enabled(i)) then
        p_table(l_count).prompt_code := l_segments.segment_name(i);
        p_table(l_count).prompt_text := l_segments.row_prompt(i);
        p_table(l_count).required := 'NR';
        p_table(l_count).duplicate := 'N';
        p_table(l_count).global_flag := true;
        l_count := l_count+1;
      end if;
    END LOOP;

END AP_WEB_INIT_PROMPTS_ARRAY;

--
-- Purpose: To identify zero, regardless of the number format
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  -------------------------------------------
-- kwidjaja    4/26/02 Bug 2228748

FUNCTION      isAllZeroes
  ( p_numString IN varchar2)
  RETURN  boolean IS

   v_length    binary_integer;
   v_index     binary_integer;
   v_currChar  VARCHAR2(1);
   v_return    boolean := true;

BEGIN
  v_length := length(p_numString);

  FOR v_index in 1..v_length LOOP
    v_currChar := substr(p_numString, v_index, 1);
    IF v_currChar not in ('0', ',', '.') THEN
      v_return := false;
      EXIT;
    END IF;
  END LOOP;

  RETURN v_return;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END isAllZeroes; -- Function ISALLZEROES

PROCEDURE parseExpReportHeader
	       (p_user_id               IN NUMBER, -- Bug 2242176, fnd user id
                p_text 			IN OUT NOCOPY LONG,
		p_table 		IN OUT NOCOPY disc_prompts_table,
		p_def_costcenter 	IN VARCHAR2,
		p_header		IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
		p_errors 	 OUT NOCOPY AP_WEB_UTILITIES_PKG.expError) IS
l_label_text 		VARCHAR2(300) := '';
l_label_code 		VARCHAR2(100) := '';
l_label_index 		NUMBER;
l_value 		VARCHAR2(300) := ''; -- even purpose only takes 240 chars.
l_line 			VARCHAR2(2000) := '';
l_appr 			VARCHAR2(240);
l_apprid 		NUMBER;
pp_required 		VARCHAR2(1) := 'N';
l_cost_center_result 	VARCHAR2(50) := '';
l_allow_overrider 	VARCHAR2(1) := 'N';
l_require_overrider 	VARCHAR2(1) := 'N';
l_overrider_CC 		VARCHAR2(1) := 'N';
l_unexp_err 		LONG := '';
format_error 		VARCHAR2(200) := 'Spreadsheet Format Error.';
overrider_required 	VARCHAR2(200):= 'Override approver required.';
overrider_required_cc 	VARCHAR2(200) := 'You have changed cost center.  Override approver required.';
line_not_found 		VARCHAR2(200) := 'Header Line is not found';
purpose_too_long 	VARCHAR2(200) := 'Purpose too long. Truncate to 240 character.';
costcenter_invalid 	VARCHAR2(255) := '';
l_xtemplate_id		AP_WEB_DB_EXPTEMPLATE_PKG.expTypes_reportID;

debug_info 		VARCHAR2(100) := '';
purpose_prompt 		VARCHAR2(50);
template_prompt 	VARCHAR2(50);
approver_prompt 	VARCHAR2(50);

l_employee_num        HR_EMPLOYEES.employee_num%TYPE := 100;
l_employee_name       HR_EMPLOYEES.full_name%TYPE := '';
l_cost_center         VARCHAR2(150);
l_OverriderReq        VARCHAR2(10);
l_approver_id        HR_EMPLOYEES.employee_num%TYPE := 100;
l_approver_name       HR_EMPLOYEES.full_name%TYPE := '';


BEGIN

 -- Changed all occurances of FND_MESSAGE.get() with FND_MESSAGE.get_encoded()  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DISC_PKG', 'start parseExpReportHeader');

  fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_EMPTY_REPORT');
  if (p_text is null) then
    p_errors(1).text := FND_MESSAGE.Get_encoded();
    p_errors(1).type := AP_WEB_UTILITIES_PKG.C_WarningMessageType;
    return;
  end if;

  FND_MESSAGE.SET_NAME('SQLAP','AP_WEB_COST_CENTER_INVALID');
  costcenter_invalid := FND_MESSAGE.Get;

  debug_info := 'Getting Header fields';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  LOOP
   BEGIN
    debug_info := 'Get Line';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    BEGIN
      GetLine(p_text, l_line);
      EXCEPTION
	when VALUE_ERROR then
	  debug_info := 'Get Line: truncate to max length';
  	  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    END;

    /* Here we are assuming one line per field/value pair.  And they don't span
    over multiple cells */
    debug_info := 'Get Non Empty Field - label';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    BEGIN
      GetNonEmptyFld(l_line, l_label_text);
      l_label_text := rtrim(l_label_text);
      EXCEPTION
        when VALUE_ERROR then
 	  debug_info := 'Get Non Empty Field - label: truncate';
          AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    END;
    l_label_index := Disc_GetPromptIndex(l_label_text, p_table);

    /* Ignore if l_label_index = 0 -- we don't recognize this prompt. */
    if (l_label_index <> 0) then
      l_label_code := p_table(l_label_index).prompt_code;

      /* If it's 'Line' field, then we've reached the receipts section.
      Put the line back into p_text since we don't want to process it here. */
      if (l_label_code = 'AP_WEB_LINE') then
        p_text := l_label_text || fnd_global.local_chr(9) || l_line || fnd_global.local_chr(13) || '
' || p_text;
        exit;
      end if;

      if ((p_table(l_label_index).required='H') OR
	  (p_table(l_label_index).required='NH')) then
        p_table(l_label_index).required := 'F';
      elsif (p_table(l_label_index).required = 'F') then
        p_table(l_label_index).duplicate := 'Y';
      end if;

      -- Get the value
      debug_info := 'Get Non Empty Field - value';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
      BEGIN
        GetNonEmptyFld(l_line,l_value);
        l_value := rtrim(l_value);
        EXCEPTION
          when VALUE_ERROR then
	    debug_info := 'Get Non Empty Field - value: truncate';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
      END;
      if (l_label_code = 'AP_WEB_COSTCTR') then
        if (length(l_value) > C_CostCenter_Size) then
	  p_header.cost_center := substr(l_value, 1, C_CostCenter_Size);
   	else
          p_header.cost_center := l_value;
	end if;
--chiho:1310737:change the label code:
      elsif (l_label_code = 'AP_WEB_REIMBCURR') then
          p_header.reimbursement_currency_code := l_value;
          -- Check whether the reimbursement currency is valid: bug 1871756
          if (p_header.reimbursement_currency_code IS NOT NULL) then
            if (NOT isValidCurrency (p_header.reimbursement_currency_code)) then
 	      fnd_message.set_name('SQLAP','AP_WEB_DISCON_INVALID_CURR');
 	      fnd_message.set_token('curr', p_header.reimbursement_currency_code);

	      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
            end if;
          end if;

      elsif (l_label_code = 'AP_WEB_PURPOSE') then
	if (length(l_value) > C_Purpose_Size) then
	  fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
          fnd_message.set_token('MAXLEN', to_char(C_Purpose_Size));
	  AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
    	  p_header.purpose := substr(l_value, 1, C_Purpose_Size);
	else
          p_header.purpose := l_value;
	end if;
	purpose_prompt := l_label_text;
      elsif (l_label_code = 'AP_WEB_EXP_TEMP') then
        BEGIN
          p_header.template_name := l_value;
	  EXCEPTION
   	    WHEN VALUE_ERROR then
	      p_header.template_name := substr(l_value, 1, C_Xtemplate_Size);
	      fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
              fnd_message.set_token('MAXLEN', to_char(C_Xtemplate_Size));
	      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
				       'TEMPLATE');
	END;
	template_prompt := l_label_text;
      elsif (l_label_code = 'AP_WEB_OVERRIDE_APPROVER') then
	BEGIN
          l_appr := l_value;
	  EXCEPTION
	    when VALUE_ERROR then
	      l_appr := substr(l_value, 1, C_Approver_Size);
	      fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
              fnd_message.set_token('MAXLEN', to_char(C_Approver_Size));
	      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
	 END;
         approver_prompt := l_label_text;
	 p_header.override_approver_name := l_appr;

      end if;
    end if; /* l_label_index <> 0 */
    if (p_text is null) then
      fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_LINE_NOT_FOUND');
      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
      exit;
    end if;
    EXCEPTION
      when OTHERS then
       begin
        --JMARY Calling the AP_DEBUG error message instead of the concatenated string that was passed.

         FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
         FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
         FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',format_error);
         FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
         FND_MESSAGE.SET_TOKEN('PARAMETERS','');

         AP_WEB_UTILITIES_PKG.AddExpError(p_errors,fnd_message.get_encoded(),
                                       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
       end;
   END;
  END LOOP;

  debug_info := 'Validate Cost Center';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  IF (p_header.cost_center IS NULL) THEN
  /* default to the employee's own cost center */
    AP_WEB_UTILITIES_PKG.GetEmployeeInfo(l_employee_name,
                      l_employee_num,
                      l_cost_center,
                      p_header.employee_id);

  /* Bug Fix 1903969. Removed the to_number function when setting the below values
     for p_header.cost_center. All variables concerned are varchar2, and having a
     to_number around either the p_def_costcenter or l_cost_center results in
     ORA-20001: ORA-06502: PL/SQL: numeric or value error: character to number
     conversion, when the cost center is alpha-numeric.
  */

    if l_cost_center is null then
       p_header.cost_center := p_def_costcenter;
    else
       p_header.cost_center := l_cost_center;
    end if;
  END IF;

  debug_info := 'Validate Purpose';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  pp_required := AP_WEB_UTILITIES_PKG.value_specific(
				p_name    => 'AP_WEB_PURPOSE_REQUIRED',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);
  if (pp_required = 'Y') then
    if (p_header.purpose is null) then
      -- 4087170 : msg for purpose req is shown twice, each is different
      fnd_message.set_name('SQLAP', 'AP_WEB_PURPOSE_REQUIRED');
--      fnd_message.set_name('SQLAP', 'AP_WEB_SEL_BLANK_WRN');
--      fnd_message.set_token('FIELD_NAME', purpose_prompt);
      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
				       fnd_message.get_encoded(),
			 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
    end if;
  end if;

  --Bug 3786831: Validating approver, and set the approver name, when profile option,
  --IE:Approver Required = "Yes with Default" and approver name is not provided
  --in the upload SpreadSheet data.
  debug_info := 'Validate Approver';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);

  l_OverriderReq := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
				p_name    => 'AP_WEB_OVERRIDE_APPR_REQ',
				p_user_id => p_user_id,
				p_resp_id => null,
				p_apps_id => null);


  IF p_header.override_approver_name is NULL AND l_OverriderReq = 'D' THEN

     AP_WEB_UTILITIES_PKG.GetOverrideApproverDetail(p_header.employee_id,l_OverriderReq, l_approver_id, l_approver_name);

     --Don't set the approver id here, set only the approver's name
     p_header.override_approver_name := l_approver_name;


  END IF; --p_header.override_approver_name is NULL


EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
	FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
	FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
	FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','parseExpReportHeader');
	FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	FND_MESSAGE.SET_TOKEN('PARAMETERS', '');
	APP_EXCEPTION.RAISE_EXCEPTION;
      ELSE
        -- Do not need to set the token since it has been done in the
        -- child process
        RAISE;
      END IF;

END parseExpReportHeader;


PROCEDURE AP_WEB_DISC_GetExpType(
	p_table 	in out nocopy 	disc_prompts_table,
	xtypecomp_array out nocopy 	AP_WEB_PARENT_PKG.MiniString_Array,
	p_xtemplateid 	in 	AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_reportID
) IS
/* xtypecomp_array is used later for populating xtypeindex_array. */
l_count number;
l_icount number := 1;
l_exp_type_cursor	AP_WEB_DB_EXPTEMPLATE_PKG.ExpTypesOfTemplateCursor;

BEGIN

  IF ( AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypesOfTemplateCursor(
					p_xtemplateid,
					l_exp_type_cursor ) = TRUE ) THEN
  	l_count := p_table.COUNT+1;

  	LOOP
    		fetch l_exp_type_cursor into
			p_table(l_count).prompt_text,
			p_table(l_count).prompt_code;

    		exit when l_exp_type_cursor%NOTFOUND;

    		p_table(l_count).required := 'NR';
    		xtypecomp_array(l_icount) := p_table(l_count).prompt_code;
    		l_count := l_count + 1;
    		l_icount := l_icount + 1;
  	END LOOP;
  	Close l_exp_type_cursor;
  END IF;

END AP_WEB_DISC_GetExpType;

----------------------------------------
-- Validate receipt headers
----------------------------------------
PROCEDURE AP_WEB_DISC_Val_Rec_Headers(p_exp in out nocopy long,
				p_table in out nocopy disc_prompts_table,
				p_format_errors in out nocopy setup_error_stack)
IS

  l_line VARCHAR2(2000) := '';
  l_fld VARCHAR2(300) := '';
  l_count2 number; /* format error count */
  l_index number; /* index of the label in the prompts table */
  l_code VARCHAR2(50);
  l_pos number := 1; /* current cell position on the spreadsheet */
  line_too_long VARCHAR2(300) := 'Header line > 2000 characters';
  fld_too_long VARCHAR2(300) := 'Field > 300 characters';
  debug_info VARCHAR2(300) := '';
  current_calling_sequence VARCHAR2(255) := 'AP_WEB_DISC_Val_Rec_Headers';
BEGIN

  debug_info := 'Get Line';
  BEGIN
    GetLine(p_exp, l_line);
    Exception
      when VALUE_ERROR then
	debug_info := 'Get Line: truncated';
  END;

  debug_info := 'Get Field';
  LOOP
    BEGIN
      GetField(l_line, l_fld);
      l_fld := rtrim(ltrim(l_fld));
      Exception
        when VALUE_ERROR then
	  debug_info := 'Get Field: truncated';
    END;
    l_index := Disc_GetPromptIndex(l_fld, p_table);
    if (l_index <> 0) then
      l_code := p_table(l_index).prompt_code;
      --
      -- If the prompt hasn't been found, and set the status to 'F' means
      -- found.
      --
      if ((p_table(l_index).required = 'R') OR
	  (p_table(l_index).required = 'NR')) then
        p_table(l_index).required := 'F';
	--
	-- Match the position of the prompt in the prompt_table with its
	-- actual position on the spreadsheet.  This is just a simple trick
 	-- for ease of matching up the receipt columns with the header when
 	-- processing the receipts later.
	--
        if (not SwapPrompts(p_table, l_index, l_pos)) then
          exit; -- really shouldn't happen
        end if;
      elsif (p_table(l_index).required = 'F') then
	-- Prompt is already found, so it's a duplicate.
	-- I don't distinguish where it is found. So if a label appeared in
	-- header before, and then in receipts section again, I count it as
	-- duplicate. Can make it more fine-grain if there is demand.
        p_table(l_index).duplicate := 'Y';
      end if;
    else
      if (l_pos > p_table.COUNT) then
        p_table(l_pos).prompt_code := '';
      end if;
    end if;
    if (l_line is null) then
      exit;
    end if;
    l_pos := l_pos + 1;
  END LOOP;

  EXCEPTION
    when OTHERS then
       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
       FND_MESSAGE.SET_TOKEN('PARAMETERS',
                'l_line = ' || l_line);
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
       APP_EXCEPTION.RAISE_EXCEPTION;
      -- AP_WEB_DISC_UNEXP_ERR(SQLCODE || '@@' || l_line);

END AP_WEB_DISC_Val_Rec_Headers;

PROCEDURE AP_WEB_DISC_DISPLAY_FORMAT_ERR
		(p_format_errors in out nocopy setup_error_stack) IS

i number;
l_title VARCHAR2(200) := 'Format Errors';


BEGIN
   htp.p('<BASE HREF="'||FND_WEB_CONFIG.WEB_SERVER||'">');
   htp.p('<HTML DIR= "'|| AP_WEB_INFRASTRUCTURE_PKG.GetDirectionAttribute || '">');
   htp.headOpen;
   fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_FORMAT_ERR');
   htp.title(fnd_message.get);

   icx_util.copyright;
   js.scriptOpen;

   AP_WEB_UTILITIES_PKG.CancelExpenseReport;
   AP_WEB_UTILITIES_PKG.GoBack;

   js.scriptClose;
   htp.headClose;
   htp.p('
	<style>
	<!--
	FONT.PROMPTBLACK
                   {FONT-FAMILY: ARIAL, SANS-SERIF;
                    COLOR: BLACK;
                    FONT-SIZE: 10PT;}
	FONT.DATABLACK
               {FONT-FAMILY: ARIAL, SANS-SERIF;
                COLOR: BLACK;
                    FONT-WEIGHT: BOLD;
                FONT-SIZE: 10PT;}
	FONT.BUTTON
                   {FONT-FAMILY: ARIAL, SANS-SERIF;
                    COLOR: BLACK;
                    TEXT-DECORATION: NONE;
                    FONT-SIZE: 10PT;}
	-->
	</style>
	');

   htp.p('<BODY bgcolor=#cccccc>');
   fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_CANNOT_READ');
   htp.p('<basefont size=+1><B><FONT class=promptblack>' || fnd_message.get ||'</FONT></B></basefont><br>');
   htp.ulistOpen;
   for i in 1 .. p_format_errors.COUNT loop
     htp.p('<FONT class=promptblack>');
     htp.listItem(p_format_errors(i));
     htp.p('</FONT>');
   end loop;
   htp.ulistClose;

   htp.bodyClose;
   htp.htmlClose;

END ap_web_disc_display_format_err;

---------------------------------
/* Identify the rest of the format errors by going through the
prompt_table. */

PROCEDURE AP_WEB_DISC_FORMAT_ERROR(p_format_errors in out nocopy setup_error_stack,
				  p_table in out nocopy disc_prompts_table,
		                  p_errors IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError)
IS

i number := 1;
j number; /* p_format_errors count */
l_exptype number;
l_title varchar2(200) := 'Expense Template Format Errors';

exptype_found boolean := false; /* at least one exp type found, or Expense
				   Type column found. */
amt_found boolean := false; /* either daily amt or receipt amt is found */
recCurr_found boolean := false;
rate_found boolean := false;
rate_index number;

required_fld_missing varchar2(300) := 'Required field missing';
dup_fld_found varchar2(300) := 'Duplicate label found';
no_exptype_found varchar2(300) := 'At least one expense type required';
no_amt_found varchar2(300) := 'At least one amount field is required';
l_unexp_error varchar2(300) := '';
l_encd_mesg varchar2(1000); -- Used in the new tech stack for error messages

BEGIN
  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DISC_PKG', 'start ap_web_disc_format_error');
  FOR i in 1 .. p_table.COUNT LOOP
    --
    -- Either Daily Amount or Receipt Amount field found is ok
    --
    if ((p_table(i).required='F') AND
	(p_table(i).prompt_code = 'AP_WEB_RECAMT')) then
      amt_found := true;
    elsif ((p_table(i).required='F') AND
	   (p_table(i).prompt_code = 'AP_WEB_DAILYAMT')) then
      amt_found := true;
    --
    -- If currency is found, then rate has to exist.
    --
    elsif ((p_table(i).required='F') AND
	   (p_table(i).prompt_code = 'AP_WEB_RECCURR')) then
      recCurr_found := true;
    elsif ((p_table(i).required='F') AND
	   (p_table(i).prompt_code = 'AP_WEB_CONVRATE')) then
      rate_found := true;
      rate_index := i;
    --
    -- Expense Type as header found. This is newer than the flattened out
    -- expense types implementation, but I want to keep it backward compatible.
    --
    elsif ((p_table(i).required='F') AND
	   (p_table(i).prompt_code = 'AP_WEB_EXPTYPE')) then
      exptype_found := true;
    --
    -- Required field but not found
    --
    elsif ((p_table(i).required = 'H') OR (p_table(i).required = 'R')) then
      j := p_format_errors.COUNT+1;
      fnd_message.set_name('SQLAP', 'AP_WEB_SEL_BLANK_WRN');
      fnd_message.set_token('FIELD_NAME',p_table(i).prompt_text);
      l_encd_mesg := fnd_message.get_encoded();
      fnd_message.set_encoded(l_encd_mesg);
      p_format_errors(j) := fnd_message.get;
      fnd_message.set_encoded(l_encd_mesg);
      fnd_msg_pub.add();
      -- Added for bug 2132994
      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
			       l_encd_mesg,
		 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
      /* p_format_errors(j) := p_table(i).prompt_code || ':'
			|| required_fld_missing; */
    --
    -- Duplicate field
    --
    elsif (p_table(i).duplicate = 'Y') then
      j := p_format_errors.COUNT+1;
      fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_DUP_FLD');
      fnd_message.set_token('FIELD_NAME', p_table(i).prompt_text);
      l_encd_mesg := fnd_message.get_encoded();
      fnd_message.set_encoded(l_encd_mesg);
      p_format_errors(j) := fnd_message.get;
      fnd_message.set_encoded(l_encd_mesg);
      fnd_msg_pub.add();
      -- Added for bug 2132994
      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
			       l_encd_mesg,
		 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
      /*p_format_errors(j) := p_table(i).prompt_code || ':'
			|| dup_fld_found;*/
    else /* is it an expense type? */
      begin
        l_exptype := to_number(p_table(i).prompt_code);
        if (l_exptype >= 0) then
          if (p_table(i).required = 'F') then
            exptype_found := true;
   	  end if;
	end if;
  	exception
	  when OTHERS then
            l_exptype := 0; /* not doing anything */
      end;
    end if;
   END LOOP;

   --
   -- Special cases:
   -- Expense type
   --
   if (exptype_found = false) then
     j:=p_format_errors.COUNT+1;
     fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_XTYPE_NOT_FOUND');
     l_encd_mesg := fnd_message.get_encoded();
     fnd_message.set_encoded(l_encd_mesg);
     p_format_errors(j) := fnd_message.get;
     fnd_message.set_encoded(l_encd_mesg);
     fnd_msg_pub.add();
     -- Added for bug 2132994
     AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
			       l_encd_mesg,
		 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
     -- p_format_errors(j) := no_exptype_found;
   -- RecAmount or DailyAmount
   elsif (amt_found = false) then
     j:=p_format_errors.COUNT+1;
     fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_AMT_NOT_FOUND');
     l_encd_mesg := fnd_message.get_encoded();
     fnd_message.set_encoded(l_encd_mesg);
     p_format_errors(j) := fnd_message.get;
     fnd_message.set_encoded(l_encd_mesg);
     fnd_msg_pub.add();
     -- Added for bug 2132994
     AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
			       l_encd_mesg,
		 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
     -- p_format_errors(j) := no_amt_found;
   -- Currency and Rate
   elsif ((recCurr_found = true) AND (rate_found = false)) then
     j:=p_format_errors.COUNT+1;
     fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_RATE_NOT_FOUND');
     l_encd_mesg := fnd_message.get_encoded();
     fnd_message.set_encoded(l_encd_mesg);
     p_format_errors(j) := fnd_message.get;
     fnd_message.set_encoded(l_encd_mesg);
     fnd_msg_pub.add();
     -- Added for bug 2132994
     AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
			       l_encd_mesg,
		 	       AP_WEB_UTILITIES_PKG.C_ErrorMessageType);
   -- If only rate is found, but not currency, set the status to 'NR' so it
   -- will be ignored later.
   elsif ((recCurr_found = false) AND (rate_found = true)) then
     p_table(rate_index).required := 'NR';
   end if;
   AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DISC_PKG', 'end ap_web_disc_format_error');

   EXCEPTION
     WHEN OTHERS THEN
       --JMARY Replaced AP_WEB_DISC_UNEXP_ERR with APP_EXCEPTION.RAISE_EXCEPTION
       --      Using the AP_DEBUG instaed of the error concatenation.

       FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
       FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
       FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ap_web_disc_format_error');
       FND_MESSAGE.SET_TOKEN('DEBUG_INFO','');
       FND_MESSAGE.SET_TOKEN('PARAMETERS','');
       APP_EXCEPTION.RAISE_EXCEPTION;

END ap_web_disc_format_error;

PROCEDURE InitMiniStringArray(p_array OUT NOCOPY AP_WEB_PARENT_PKG.MiniString_Array,
			      p_size  IN number,
			      p_val   IN varchar2 default '') IS

i number;

BEGIN

  for i in 1 .. p_size loop
    p_array(i) := p_val;
  end loop;

END InitMiniStringArray;

PROCEDURE InitMedStringArray(p_array OUT NOCOPY AP_WEB_PARENT_PKG.MedString_Array,
			      p_size  IN number,
			      p_val   IN varchar2 default '') IS

i number;

BEGIN

  for i in 1 .. p_size loop
    p_array(i) := p_val;
  end loop;

END InitMedStringArray;


Function CheckPosNum(p_num in number,
		      p_receipt_errors in out nocopy AP_WEB_UTILITIES_PKG.receipt_error_stack,
		      p_index in number,
		      p_prompt in varchar2) Return Boolean IS
BEGIN
       if (p_num < 0) then
	  fnd_message.set_name('SQLAP', 'AP_WEB_NOT_POS_NUM');
          fnd_message.set_token('VALUE', to_char(p_num));
          AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                       P_index,
                                       AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                       fnd_message.get_encoded(),
                                       p_prompt);
	  return false;
	end if; /* p_num < 0 */
	return true;
END CheckPosNum;


PROCEDURE CheckStringSize(p_fld in out nocopy varchar2,
			  p_size in number,
			  p_receipt_errors in out nocopy AP_WEB_UTILITIES_PKG.receipt_error_stack,
			  p_rec_count in number,
			  p_prompt_index in varchar2) IS
BEGIN

	if (length(p_fld) > p_size) then
	      /* The text is truncated and an error is entered. This should
		really be a warning but now we don't distinguish between
		errors and warnings.  This is going to be displayed once in
		the error table to alert the user. Since the text is already
		truncated, and the client-size Javascript also guarantee the
		size of the string, user should never see it the 2nd time.
	      */
	      p_fld := substr(p_fld, 1, p_size);
	      fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
    	      fnd_message.set_token('MAXLEN',to_char(p_size));
              AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                       p_rec_count,
                                       AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                       fnd_message.get_encoded(),
                                       p_prompt_index);

	 end if;

END CheckStringSize;


PROCEDURE PopulateXtypeIndex(xtypecomp_Array in AP_WEB_PARENT_PKG.MiniString_Array,
			     xtype_array  in AP_WEB_PARENT_PKG.MiniString_Array,
			     xtypeindex_array out nocopy AP_WEB_PARENT_PKG.MiniString_Array) IS
i number;
V_ReceiptCount number;

BEGIN

   for V_ReceiptCount in 1 .. xtype_array.COUNT LOOP
     if (xtype_array(V_ReceiptCount) is not null) then
	 i := 1;
         LOOP
	   if (xtype_array(V_ReceiptCount) = xtypecomp_Array(i)) then
	     xtypeindex_Array(V_ReceiptCount) := to_char(i);
	     exit;
 	   end if;
	   if (i = xtypecomp_Array.COUNT) then
	     exit;
	   end if;
	   i := i + 1;
    	 END LOOP;
      else
        xtypeindex_array(V_ReceiptCount) := '';
      end if;
    end loop;

END PopulateXtypeIndex;

---------------------------------------------------
PROCEDURE SerializeHeader(
		    p_header	      in 	AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
		    p_index	      in	varchar2,
		    p_xtype	      in	varchar2,
		    p_recCurr	      in	varchar2,
		    p_rate	      in	varchar2,
		    p_trans	      in	varchar2,
		    p_multiCurr	      in	varchar2,
		    p_amtDueEmployee  in	number,
		    p_amtDueccCompany in	number,
		    ReportLine        out nocopy       long) IS
l_delim varchar2(6) := '@att@';

l_delim_line varchar2(6) := '@line@';
BEGIN
  ReportLine :=
	to_char(p_header.report_header_id) || l_delim
	|| nvl(p_header.summary_start_date,'') || l_delim
        || p_header.override_approver_id || l_delim
        || p_header.override_approver_name || l_delim
        || p_header.cost_center || l_delim
        || p_header.employee_id || l_delim
        || p_header.template_id || l_delim
        || p_header.template_name || l_delim
        || nvl(p_header.last_receipt_date,'') || l_delim
        || p_header.reimbursement_currency_code || l_delim
        || p_header.reimbursement_currency_name || l_delim
        || p_multiCurr || l_delim
        || p_header.purpose || l_delim
        || to_char(p_header.number_Max_FlexField) || l_delim
	|| to_char(p_amtDueEmployee) || l_delim
	|| to_char(p_amtDueccCompany) || l_delim
	|| l_delim_line;
END SerializeHeader;

------------------------------------------
PROCEDURE parseExpReportReceipts(p_user_id      IN NUMBER, -- Bug 2242176, fnd user id
                        p_exp 		IN OUT NOCOPY LONG,
			p_table 		IN disc_prompts_table,
                        P_IsSessionProjectEnabled IN VARCHAR2,
                        p_report_header_info 	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
			p_receipts	 OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
                        Custom1_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom2_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom3_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom4_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom5_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom6_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom7_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom8_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom9_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom10_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom11_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom12_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom13_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom14_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
                        Custom15_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
			p_receipt_errors OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
			p_errors 	 OUT NOCOPY AP_WEB_UTILITIES_PKG.expError, /*Bug No: 3075093*/
                        p_error_type            IN OUT NOCOPY VARCHAR2) IS
i 		NUMBER;
j 		NUMBER;
k		NUMBER;
l_line 		VARCHAR2(2000);
l_fld 		VARCHAR2(300);
l_prompt_code 	VARCHAR2(100);
l_prompt_text   fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE :='';
pos 		NUMBER; /* current position in the row */
rec_count 	NUMBER := 1; /* receipt count */
debug_info 	VARCHAR2(400) := ''; /* Bug 2530727 - Increased the length */
current_calling_sequence VARCHAR2(255) := 'parseExpReportReceipts';
l_number 	NUMBER; /* a temp holder for a number */
l_date_str 	date; /* sysdate, used for comparison */
l_date_str_var 	varchar2(100);
multi_exptype_error 	VARCHAR2(200) := 'More than one expense type chosen';

/* just be there since ValidateReportLines is generic. */
l_date_temp   	VARCHAR2(30) := '';

-- store justif flag fetched from just_required
l_justreq_array AP_WEB_PARENT_PKG.Number_Array;

-- store currency code fetched from Currencies
l_base_curr 	AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode;
curr_found 	BOOLEAN := false;

l_xtype_text 	VARCHAR2(80) := '';
l_xtype_code 	VARCHAR2(25) := '';

l_count 		NUMBER := 0;
l_binNumber 		BINARY_INTEGER;
l_dflex_enabled  	BOOLEAN;
l_tempChar       	VARCHAR2(1);
l_tempDate		Date;
l_project_name		PA_PROJECTS_EXPEND_V.project_name%TYPE;
l_task_name		PA_TASKS_EXPEND_V.task_name%TYPE;
l_segmentPromptTable 	segmentPrompt_table; /*to keep segment data for ALL segments*/
l_expIndexTable    	expIndex_table;      /*index to l_segmentPromptTable for a given Expense type*/

/*to store FlexField data for a receipt by the 'correct order'*/
l_dflexTable AP_WEB_DFLEX_PKG.CustomFields_A;
  ---
  --- Used to determine if the receipt currency user provided is a recognized
  --- one.  Took away the where clause since receipt can be in any currency,
  --- whereas reimbursement currency should be restricted.
  ---
l_curr_code_cursor	AP_WEB_DB_COUNTRY_PKG.CurrencyCodeCursor;

l_prompt  varchar2(40);  --Bug 2758267

l_label_code 		VARCHAR2(100) := '';/*Bug No: 3075093 - prompt code*/
l_label_index 		NUMBER;/*Bug No: 3075093 - index of prompt in prompt table*/
l_multiple_copy_check	BOOLEAN := false;/*Bug No: 3075093 - set to true when import is successful*/

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DISC_PKG', 'start parseExpReportReceipts');
  -- check whether descriptive flexfield is enabled under profile option
  debug_info := 'Check profile option: descriptive flexfield';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  FND_PROFILE.GET('AP_WEB_DESC_FLEX_NAME', l_tempChar);
  -- Bug 3985122 Y-Lines Only, B - Both Header and Lines
  --l_dflex_enabled := (NVL(l_tempChar, 'N') = 'Y');
  l_dflex_enabled := ((NVL(l_tempChar, 'N') = 'Y') OR (NVL(l_tempChar, 'N') = 'B'));

  -- Get today date
  IF ( AP_WEB_DB_UTIL_PKG.GetFormattedSysDate(
				AP_WEB_INFRASTRUCTURE_PKG.getDateFormat,
				l_date_str_var ) <> TRUE ) THEN
	l_date_str := NULL;
  ELSE
	l_date_str := to_date(l_date_str_var,AP_WEB_INFRASTRUCTURE_PKG.getDateFormat);
  END IF;

  -- Get base currency code
  IF ( AP_WEB_DB_AP_INT_PKG.GetBaseCurrInfo( l_base_curr ) <> TRUE ) THEN
	l_base_curr := NULL;
  END IF;

  -- Set up the l_segmentPromptTable array
     if (l_dflex_enabled) then
         getAllSegmentPrompts(p_user_id, p_report_header_info, l_segmentPromptTable);
     end if;

  --
  -- Looping through spreadsheet lines
  --
  LOOP
    -- Check if reached the end of input.
    if (p_exp is null) then
      exit;
    end if;
    /*Bug No: 3075093 - Check if spreadsheet data pasted multiple times */
    if (l_multiple_copy_check = true) then
      p_error_type := C_setupError;
      fnd_message.set_name('SQLAP','OIE_DISC_MULTIPLE_COPY');
      AP_WEB_UTILITIES_PKG.AddExpError(p_errors,
					fnd_message.get_encoded(),
					AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
					null,
                                        0,
                                        AP_WEB_UTILITIES_PKG.C_OtherMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
      exit;
    end if;

    --
    -- Initialize receipt error stack
    --
    p_receipt_errors(rec_count).error_text := '';

    --
    -- Get line.  If length of line > 2000, exception and warning.
    --
    BEGIN
      debug_info :='Get receipt line';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
      GetLine(p_exp, l_line);
      EXCEPTION
	when VALUE_ERROR then
	  fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
	  fnd_message.set_token('MAXLEN','2000');
          AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_RecCurr_Prompt);

    END;
    --
    -- initialize position pointer, arrays
    --
    debug_info := 'Initializing arrays';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    pos := 1;
    p_receipts(rec_count).parameter_id := '';
    p_receipts(rec_count).expense_type := '';
    p_receipts(rec_count).amount := '';
    p_receipts(rec_count).daily_amount := '';
    p_receipts(rec_count).start_date:= null;
    p_receipts(rec_count).end_date :=  null;
    p_receipts(rec_count).days := '';
    p_receipts(rec_count).justification := '';
    -- New for multi-curr support
    p_receipts(rec_count).receipt_amount := '';
    p_receipts(rec_count).currency_code := '';
    p_receipts(rec_count).rate := '';

    -- Project Accounting support
    p_receipts(rec_count).project_number := '';
    p_receipts(rec_count).project_id := '';
    p_receipts(rec_count).task_number := '';
    p_receipts(rec_count).task_id := '';
    p_receipts(rec_count).expenditure_type := '';
    -- Grants Integration
    p_receipts(rec_count).award_number := '';
    p_receipts(rec_count).award_id := '';

    -- Initialize the l_dflexTable and l_expIndexTable arrays
    initIndexAndDflexTable(l_segmentPromptTable, l_dflexTable, l_expIndexTable);

    -- initialize found field to false
       FOR i in 1..l_segmentPromptTable.count LOOP
           l_segmentPromptTable(i).found := false;
       END LOOP;
    --
    -- Loop through items in this line
    --
    LOOP
      debug_info := 'Get receipt item';
      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
      -- If field length > 300, exception and warning
      BEGIN
        GetField(l_line, l_fld);
	l_fld := rtrim(l_fld);
	EXCEPTION
  	  when VALUE_ERROR then
	    fnd_message.set_name('SQLAP', 'AP_WEB_MAXLEN_WARNING');
	    fnd_message.set_token('MAXLEN','300');
            AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                   rec_count,
                                   AP_WEB_UTILITIES_PKG.C_WarningMessageType,
                                   fnd_message.get_encoded());
      END;
      --
      -- pos 1 (Line column) has to be a number and can't be NULL.
      --
      if (pos = 1) then
        /* Bug No: 3075093 - Check whether Import Successfull prompt is reached*/
	l_label_index := Disc_GetPromptIndex(l_fld, p_table);
	if (l_label_index <> 0) then
           l_label_code := p_table(l_label_index).prompt_code;
           if( l_label_code = 'AP_WEB_UPLOAD_SUCC') THEN
	       l_multiple_copy_check := true;
           end if;
        end if;

 	if (l_fld IS NULL) then
	  exit; /* not counting this line */
	else
	  begin
            l_number := to_number(l_fld);
      	    exception
	      when OTHERS then
	        exit; /* not counting this line */
	  end;
	end if;
      else
        begin
   	  --
	  -- See if the current column is an identified column
 	  -- If not, ignore the column
 	  --
	  if (p_table(pos).required = 'F') then
	    l_prompt_code := p_table(pos).prompt_code;
  	  else
	    l_prompt_code := '';
	  end if;

   	  IF (l_prompt_code = 'AP_WEB_STARTDATE' OR l_prompt_code = 'AP_WEB_ENDDATE') THEN
	    --FlexDate
	    debug_info := 'Assigning start date';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    l_date_temp := substr( l_fld, 1, C_MiniString_Size );
            l_prompt_text := p_table(pos).prompt_text;
            BEGIN
	    	debug_info := 'converting to date';
    		AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
		BEGIN
                        /* Bug No # 4315875 : Replaced AP_WEB_INFRASTRUCTURE_PKG.getDateFormat with icx_sec.g_date_format
                           so that preference changes made by user would be reflected without logging out
                        */
               		l_tempDate := to_date( l_date_temp,nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT')) );
		EXCEPTION
			WHEN OTHERS THEN
-- chiho: handle the date value not in default date format:
				IF ( SQLCODE = -1843 ) THEN
					l_tempDate := to_date( l_date_temp, 'mm/dd/yyyy' );
				ELSE
					RAISE;
				END IF;
		END;

		IF ( l_prompt_code = 'AP_WEB_STARTDATE' ) THEN
               	  /*p_receipts(rec_count).start_date := to_char( l_tempDate,
                                                      nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'))); */
                    --Bug 5029676
                    p_receipts(rec_count).start_date := l_tempDate;

		ELSIF ( l_prompt_code = 'AP_WEB_ENDDATE' ) THEN
		  /*p_receipts(rec_count).end_date := to_char( l_tempDate,
                                                    nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT')));*/
                    --Bug 5029676
                    p_receipts(rec_count).end_date := l_tempDate;
		END IF;

            EXCEPTION
            	WHEN OTHERS THEN
            		IF ( SQLCODE = -1841 ) THEN
                		fnd_message.set_name( 'SQLAP', 'AP_WEB_DISCON_INVALID_FULLYEAR');
                                fnd_message.set_token ( 'DATE', l_prompt_text);
			ELSE
				fnd_message.set_name('SQLAP','AP_WEB_INVALID_DATE');
                                fnd_message.set_token( 'format', nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT')));
			END IF;

			IF ( l_prompt_code = 'AP_WEB_START_DATE' ) THEN
                		AP_WEB_UTILITIES_PKG.AddMessage(
                                          P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Date1_Prompt);
			ELSE
                		AP_WEB_UTILITIES_PKG.AddMessage(
                                          P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Date2_Prompt);
			END IF;

	    END;

	  elsif (l_prompt_code = 'AP_WEB_DAYS') then
	    debug_info := 'Filling Days_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).days := substr(l_fld, 1, C_MiniString_Size);
	  elsif (l_prompt_code = 'AP_WEB_DAILYAMT') then
	    debug_info := 'Filling DAmount_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).daily_amount := substr(l_fld, 1, C_MiniString_Size);
	  elsif (l_prompt_code = 'AP_WEB_RECAMT') then
	    debug_info := 'Filling RecAmount_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).receipt_amount := substr(l_fld, 1, C_MiniString_Size);
	  elsif (l_prompt_code = 'AP_WEB_GRP') then
	    debug_info := 'Filling Group_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    CheckStringSize(l_fld, C_Grp_Size, p_receipt_errors,rec_count,
			C_Grp_Prompt);
	    p_receipts(rec_count).group_value := l_fld;
	  elsif (l_prompt_code = 'AP_WEB_JUST') then
	    debug_info := 'Filling Justification_Array - pre-CheckStringSize';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    CheckStringSize(l_fld, C_Just_Size, p_receipt_errors,rec_count,
			C_Just_Prompt);
	    debug_info := 'Filling Justification_Array: ' || l_fld;
	    p_receipts(rec_count).justification := l_fld;
	    debug_info := 'After Filling Justification_Array';
  	  elsif (l_prompt_code = 'AP_WEB_RECPT_MISSING') then
	    debug_info := 'Filling Receipt_Missing_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
            if (l_fld is not null) then
  	      p_receipts(rec_count).receipt_missing_flag := 'Y';
	    else
  	      p_receipts(rec_count).receipt_missing_flag := '';
	    end if;
	  elsif (l_prompt_code = 'AP_WEB_RECCURR') then
	    debug_info := 'Filling Currency_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).currency_code := substr(l_fld, 1, C_MiniString_Size);
	    --
	    -- I only want to check the currency once, when I know that currency
	    -- field exists.
	    --
	    -- Check if the currency entered is a valid one.
	    -- Do this here because in non-discon case, this check is done
	    -- on client-side by Javascript, so don't want to put it in
	    -- generic validation routine.
	    --
	    if (p_receipts(rec_count).currency_code is not NULL) then
	      curr_found := isValidCurrency (p_receipts(rec_count).currency_code);
	      if (p_receipts(rec_count).currency_code = 'OTHER') then
		curr_found := true;
	      end if;
	      -- Currency not valid
	      if (NOT curr_found) then
 	 	fnd_message.set_name('SQLAP','AP_WEB_DISCON_INVALID_CURR');
 		fnd_message.set_token('curr', p_receipts(rec_count).currency_code);

                AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_RecCurr_Prompt);
                p_error_type := C_setupError;
	      end if;
	    else
	      -- Currency is empty.  Set to base currency.
	      p_receipts(rec_count).currency_code := l_base_curr;
	    end if;
	  elsif (l_prompt_code = 'AP_WEB_CONVRATE') then
	    debug_info := 'Filling Rate_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).rate := substr(l_fld, 1, C_MiniString_Size);

 	    -- MS Excel passes 0 as .
	    -- We need to convert it to 0 or TO_NUMBER will choke.
	    if (p_receipts(rec_count).rate = '.') then
	      p_receipts(rec_count).rate := '0';
	    end if;
	  elsif (l_prompt_code = 'AP_WEB_AMT') then
	    debug_info := 'Filling Amount_Array';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).amount := substr(l_fld, 1, C_MiniString_Size);
  	  elsif (l_prompt_code = 'AP_WEB_EXPTYPE') then
	    --------------------------------------------
	    -- The pop list style of expense type entry.
	    --------------------------------------------
	    debug_info := 'Filling Exptype array ' || l_fld;
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    l_xtype_text := substr(l_fld, 1, C_MiniString_Size);
	    if (l_xtype_text is not null) then
	      ------------------------------------------
	      -- Get parameter id from prompt tabel
	      ------------------------------------------
	      l_xtype_code := Disc_GetPrompt(l_xtype_text, p_table);
	      if (p_receipts(rec_count).parameter_id is not null) then
	        ------------------------------------------
		-- Exptype is already selected.
		-- But don't want to complain if they just entered the same
	        -- thing twice.
		------------------------------------------
		if (p_receipts(rec_count).parameter_id <> l_xtype_code) then
		 ------------------------------------------
		 -- Record multiple exptype error.
		 ------------------------------------------
		 debug_info := 'reporting multi expense type error';
    	    	 AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
                 fnd_message.set_name('SQLAP','AP_WEB_DISCON_MULTI_EXPTYPE');
                 fnd_message.set_token('exptype', l_xtype_text);
                 AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Exptype_Prompt);
                 p_error_type := C_setupError;

	        end if;
	      else  -- (p_receipts(rec_count).parameter_id is not null)
		------------------------------------------
		-- Try to assign parameter id to xtype_array.
		------------------------------------------
	 	debug_info := 'Get expense type id';
    	        AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	        if (l_xtype_code is null) then
	          -- This will make to_number to fail, so one exception handles
	          -- both null and non-null cases.
	          l_xtype_code := 'not a number';
	        end if; /* l_xtype_code is null */
	        BEGIN
	          l_number := to_number(l_xtype_code);
	          p_receipts(rec_count).parameter_id := l_xtype_code;
	          p_receipts(rec_count).expense_type := l_xtype_text;
                  if (l_dflex_enabled) then
                  -- Set up l_expIndexTable and dflexTable

/*Bug 2758267:Passed correct prompt instead of Web Friendly Prompt
	      to function so that correct DFF values will be retreived.
*/

	IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypePrompt(
                to_number(p_receipts(rec_count).parameter_id), l_prompt)) THEN
		            p_receipts(rec_count).expense_type := l_prompt;
	END IF;

	                 setupIndexAndDflexTable(p_receipts(rec_count).expense_type,
					 l_segmentPromptTable,
                                         l_dflexTable, l_expIndexTable);
                  end if;
	        EXCEPTION
	       	  WHEN OTHERS THEN
		    p_receipts(rec_count).parameter_id := null;
		    fnd_message.set_name('SQLAP','AP_WEB_DISCON_INVALID_EXPTYPE');
                    fnd_message.set_token('exptype', l_xtype_text);
                    AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Exptype_Prompt);
                    p_error_type := C_setupError;

	        END;
	      end if;  -- (p_receipts(rec_count).parameter_id is not null)
	    end if;

	  elsif (l_prompt_code = 'AP_WEB_PA_TASK_NUMBER') then

	    debug_info := 'Filling in PA Task Name';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
            -- Fill in PA info only if enabled, calculation of ID done later
            -- Requires ProjectID
            p_receipts(rec_count).task_number :=
              substr(l_fld, 1, C_MiniString_Size);

	  elsif (l_prompt_code = 'AP_WEB_PA_PROJECT_NUMBER') then

	    debug_info := 'Filling in PA Project Name';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
            -- Fill in PA info only if enabled, calculation of ID done later
            p_receipts(rec_count).project_number :=
              substr(l_fld, 1, C_MiniString_Size);

	  elsif (l_prompt_code = 'OIEAWARDNUM') then

	    debug_info := 'Filling in Award Number';
    	    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	    p_receipts(rec_count).award_number :=
	      substr(l_fld, 1, C_MiniString_Size);

          elsif (p_table(pos).global_flag) then  -- Global FlexField as a column
            -- Put the value to the correct position in dflextable
               checkValidFlexFieldPrompt(p_table(pos).prompt_text, l_segmentPromptTable, l_expIndexTable, l_number);
               if (l_number > 0) then  /* valid prompt*/
                   if (l_segmentPromptTable(l_expIndexTable(l_number)).webEnabled) then
                       l_dflexTable(l_number).value := l_fld;
                       l_segmentPromptTable(l_expIndexTable(l_number)).found := true;
                    else  -- use default value
                       l_dflexTable(l_number).value := l_segmentPromptTable(l_expIndexTable(l_number)).default_value;
                    end if;
               else  -- ignore it
                   null;
               end if;
          elsif (l_prompt_code = 'AP_WEB_ADDITIONAL_INFO') then -- Quan: for Descriptive FlexField info
             if ( p_receipts(rec_count).parameter_id is not null) then /*make sure that expense type is valid*/
                 -- Read all the flexfield information
                 WHILE (l_line is not null) LOOP
                     /* Check if prompt is valid, if so return the 'correct position'*/
                     if (l_dflex_enabled) then
                         checkValidFlexFieldPrompt(l_fld, l_segmentPromptTable, l_expIndexTable, l_number);
                     else
                         l_number := -1; -- make it invalid
                     end if;
                     if (l_number > 0) then  /* valid prompt*/
                         if (NOT l_segmentPromptTable(l_expIndexTable(l_number)).found) then
                             l_segmentPromptTable(l_expIndexTable(l_number)).found := true;
                             l_dflexTable(l_number).user_prompt := l_fld;
                             if (l_line is not null) then
                                 GetField(l_line, l_fld);  /* get the value */
                                 -- check if this segment is web-enabled
                                 if (l_segmentPromptTable(l_expIndexTable(l_number)).webEnabled) then
                                     l_fld := rtrim(l_fld);
                                     l_dflexTable(l_number).value := l_fld;
                                 else  -- use default value
                                     l_dflexTable(l_number).value := l_segmentPromptTable(l_expIndexTable(l_number)).default_value;
                                 end if;
                             else  -- done with this receipt
                                 null;
                             end if;
                         else  -- duplicate prompt
 		             fnd_message.set_name('SQLAP','AP_WEB_DISCON_DUP_FLD');
		             fnd_message.set_token('Field_name', l_fld);
                             AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Exptype_Prompt);
                             p_error_type := C_setupError;
                             if (l_line is not null) then
                                 GetField(l_line, l_fld);  /* get the value  and ignore it*/
                             end if;
                         end if;
                     else -- invalid prompt
                         if (l_line is not null) then
                             GetField(l_line, l_fld);  /* get the value  and ignore it*/
                         end if;
                     end if;

                     if (l_line is not null) then  /* get the next prompt */
                         GetField(l_line, l_fld);
                         l_fld := rtrim(l_fld);
                     else
                         l_fld := null; -- finish the loop, done with this receipt.
                     end if;

                 END LOOP;
             end if;
	  else
	    begin
	      -------------------------------------------------------------
	      -- Non-VB style Exptype: expense type prompts at table header
	      -------------------------------------------------------------
	      debug_info := 'Filling Exptype -- the old way';
    	      AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	      /* See if it is expense type. This should always be at the
		end. */
	     if (p_table(pos).required = 'F') then
	      l_number := to_number(l_prompt_code);
	      if (l_fld is not null) then
	       if ((p_receipts(rec_count).parameter_id is not null) AND
		   (p_receipts(rec_count).parameter_id <> l_prompt_code)) then
 		 fnd_message.set_name('SQLAP','AP_WEB_DISCON_MULTI_EXPTYPE');
		 fnd_message.set_token('exptype', p_table(pos).prompt_text);
                 AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Exptype_Prompt);
                 p_error_type := C_setupError;
	       else
		  p_receipts(rec_count).parameter_id := l_prompt_code;
		  p_receipts(rec_count).expense_type := p_table(pos).prompt_text;
	       end if;
	      end if; /* l_fld is not null? */
             end if; /* required = 'F'? */
	     exception
		when OTHERS then
		  NULL;
	     end;
	   end if;
	 end;
       end if;
       pos := pos + 1;
       if (l_line is null) then
	 exit;
       end if;
     END LOOP;

        -------------------------------------------------------
	-- if receipt curr is not given, set it to base currency.
        -------------------------------------------------------
        debug_info := 'Set receipt currency';
    	AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
	if (p_receipts(rec_count).currency_code is null) then
	  p_receipts(rec_count).currency_code := l_base_curr;
        end if;

       -------------------------------------------------------
       -- Validate the Project and Task Name fields and fill in
       -- Project and Task ID and Expenditure Type fields
       -------------------------------------------------------
       debug_info := 'Derive PA information';
       AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
       AP_WEB_PROJECT_PKG.DerivePAInfoFromUserInput(
         P_IsSessionProjectEnabled,
         p_receipts(rec_count).project_number,
         p_receipts(rec_count).project_id,
	 l_project_name,
         p_receipts(rec_count).task_number,
         p_receipts(rec_count).task_id,
	 l_task_name,
         p_receipts(rec_count).expenditure_type,
         p_receipts(rec_count).parameter_id);

       --------------------------------
       --- Bug: 6978992
       --- Derive Award Id
       --------------------------------
       BEGIN
	IF (p_receipts(rec_count).award_number is not null) THEN
  	 SELECT award_id
 	 INTO p_receipts(rec_count).award_id
 	 FROM GMS_AWARDS
 	 WHERE award_number = p_receipts(rec_count).award_number;
 	END IF;
       EXCEPTION
	WHEN OTHERS THEN
 		p_receipts(rec_count).award_id := null;
       END;
       -------------------------------------------------------
       -- determine if this receipt is worth keeping
       -------------------------------------------------------
       debug_info := 'Determine if this receipt is worth keeping';
       AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
       BEGIN
         if (((to_date(p_receipts(rec_count).start_date,
		AP_WEB_INFRASTRUCTURE_PKG.getDateFormat) = l_date_str) OR
	      (p_receipts(rec_count).start_date is null))
             AND
	     (p_receipts(rec_count).end_date is null)
             AND
	     ((p_receipts(rec_count).days = '0') OR
	      (p_receipts(rec_count).days is null))
             AND
	     ((p_receipts(rec_count).daily_amount is null) OR
	       (isAllZeroes(p_receipts(rec_count).daily_amount)))
             AND
	      ((p_receipts(rec_count).amount is null) OR
	       (isAllZeroes(p_receipts(rec_count).amount)))
             ) then
	   /* It's an empty receipt.  Rewind. */
	   /* Xtype is the only one in which whether or not there is value
	      matters */
	   p_receipts(rec_count).parameter_id := '';
	   rec_count := rec_count - 1;
         else -- the receipt is good
              -- copy dflfexTable to the customfield array
              l_binNumber := rec_count; -- since Propogate... take BINARY_INTEGER
              AP_WEB_DFLEX_PKG.propogateReceiptCustFldsInfo(l_dflexTable,
                                l_binNumber,
                                Custom1_Array,
                                Custom2_Array,
                                Custom3_Array,
                                Custom4_Array,
                                Custom5_Array,
                                Custom6_Array,
                                Custom7_Array,
                                Custom8_Array,
                                Custom9_Array,
                                Custom10_Array,
                                Custom11_Array,
                                Custom12_Array,
                                Custom13_Array,
                                Custom14_Array,
                                Custom15_Array);

	     -- check if expense type is provided. The reason that we don't do this right after
             -- processing expense type is not efficient since all the blank lines would be processed!
             -- The best way is to rewrite this module!(Quan 1/26/99)
             if (l_xtype_text is null) then
                    fnd_message.set_name('SQLAP', 'AP_WEB_EXPENSE_TYPE_REQUIRED');
                    AP_WEB_UTILITIES_PKG.AddMessage(P_Receipt_Errors,
                                          rec_count,
                                          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
                                          fnd_message.get_encoded(),
                                          C_Exptype_Prompt);
             end if;
	 end if;
	 exception
	   when OTHERS then
	     /* the field that should have number doesn't. Not declaring error
		now, but don't count it as empty receipt either.  Let
		validation procedure report error later. */
	     NULL;
       END;

       rec_count := rec_count + 1;

     END LOOP;

     p_report_header_info.receipt_count :=  TO_CHAR(rec_count - 1);

     j := 0;
     FOR i IN 1..to_number(p_report_header_info.receipt_count) LOOP
	if (p_receipts(i).group_value IS NOT NULL) THEN
	   return;
        end if;
        j := j + 1;
     END LOOP;

     if (j = to_number(p_report_header_info.receipt_count)) then
       FOR i IN 1..to_number(p_report_header_info.receipt_count) LOOP
	  p_receipts(i).group_value := '';
       END LOOP;
     end if;

EXCEPTION
       WHEN OTHERS THEN
	 BEGIN
           -- JMARY Added a check for -20001

           IF (SQLCODE <> -20001) THEN
             FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
             FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
             FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     current_calling_sequence);
             FND_MESSAGE.SET_TOKEN('PARAMETERS',
		'l_line = ' || l_line);
	     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
	     APP_EXCEPTION.RAISE_EXCEPTION;
           ELSE
             -- Do not need to set the token since it has been done in the
             -- child process
             RAISE;
           END IF;
	 END;

END parseExpReportReceipts;


PROCEDURE discValidateExpLines(
        p_report_header_info  IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_custom1_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom2_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom3_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom4_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom5_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom6_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom7_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom8_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom9_array       IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom10_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom11_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom12_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom13_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom14_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_custom15_array      IN OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        p_has_core_field_errors     OUT NOCOPY BOOLEAN,
        p_has_custom_field_errors     OUT NOCOPY BOOLEAN,
	p_receipts_errors     	 OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipts_with_errors_count   OUT NOCOPY BINARY_INTEGER,
        p_IsSessionProjectEnabled  	IN VARCHAR2,
        p_calculate_receipt_index      	IN BINARY_INTEGER DEFAULT NULL,
        p_DataDefaultedUpdateable	IN OUT NOCOPY BOOLEAN)
IS
  l_receipts_with_errors_core   BINARY_INTEGER;
  l_receipts_with_errors_custom BINARY_INTEGER;
  l_errors                       AP_WEB_UTILITIES_PKG.expError;
  l_errors_custom		AP_WEB_UTILITIES_PKG.expError;

  V_IsSessionTaxEnabled		VARCHAR2(1);

  l_unexp_err		       VARCHAR2(2000);
  l_debug_info		       VARCHAR2(2000);

  l_receipt_count		NUMBER;
l_title         		AK_REGIONS_VL.NAME%TYPE;
l_prompts       		AP_WEB_UTILITIES_PKG.prompts_table;
l_recCount			INTEGER;

l_allow_credit_lines_profile 	VARCHAR2(1) := 'N';
l_allow_credit_lines 		BOOLEAN;

l_just_required_cursor 		AP_WEB_DB_EXPTEMPLATE_PKG.JustificationExpTypeCursor;

l_curr_precision_cursor 	AP_WEB_DB_COUNTRY_PKG.CurrencyPrecisionCursor;
l_justreq_array 		AP_WEB_PARENT_PKG.Number_Array;
l_reimbcurr_precision   	AP_WEB_DB_COUNTRY_PKG.curr_precision;

  V_SysInfoRec		       AP_WEB_DB_AP_INT_PKG.APSysInfoRec;   -- For PATC: Exchange rate type in AP and  Functional currency
  V_EndExpenseDate             DATE;           -- For PATC: Latest receipt date
  V_DefaultExchangeRate        NUMBER;         -- For PATC: Exchange rate for func->reimb
                                               -- on latest receipt date
  V_DateTemp                   DATE;           -- For PATC: Scratch variable
  V_DateFormat                 VARCHAR2(30);

  I				INTEGER;
 l_report_line_rec      AP_WEB_DFLEX_PKG.ExpReportLineRec;
 l_temp_array           OIE_PDM_NUMBER_T; -- bug 5358186
BEGIN

  -- Convert number of maximum number of flexfield segments used
  l_receipt_count := TO_NUMBER(p_report_header_info.receipt_count);

  AP_WEB_DFLEX_PKG.IsSessionTaxEnabled(
    V_IsSessionTaxEnabled);


  -- For core case, do NOT assume that the error table is empty.  Certain
  -- errors are checked while processing the uploaded report in the discon.
  -- case.

  -- Whatever in p_receipts_errors should belong to core error stack.
  -- The only time it could be populated is during disconnected processing.
  -- Other times it should be given null since it'll be called after
  -- String2*.  If not so, make sure to initialize it before calling this
  -- procedure.
  --

  -- Clear p_receipts_errors_custom and p_receipts_errors
  AP_WEB_UTILITIES_PKG.InitMessages(l_receipt_count, p_receipts_errors);

--  htp.p('p_receipts_errors size = ' || to_char(p_receipts_errors.count));
  --AP_WEB_UTILITIES_PKG.CopyMessages(p_receipts_errors,
  --  p_receipts_errors_core);
  --AP_WEB_UTILITIES_PKG.ClearMessages(p_receipts_errors);

  -- validate core lines fields
  l_debug_info := 'ValidateExpLinesCoreFields';
  getPrompts(601,'AP_WEB_EXP_VIEW_REC',l_title,l_prompts);

  FND_PROFILE.GET('AP_WEB_ALLOW_CREDIT_LINES', l_allow_credit_lines_profile);
  if (l_allow_credit_lines_profile = 'Y') then
    l_allow_credit_lines := TRUE;
  else
    l_allow_credit_lines := FALSE;
  end if;

  l_debug_info := 'Fill justification required array';
  IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetJustifReqdExpTypesCursor(l_just_required_cursor)) THEN
    i := 1;
    LOOP
      FETCH l_just_required_cursor INTO l_justreq_array(i);
      EXIT when l_just_required_cursor%NOTFOUND;
      i := i + 1;
    END LOOP;
  END IF;

  CLOSE l_just_required_cursor;

  l_reimbcurr_precision := AP_WEB_DB_COUNTRY_PKG.GetCurrencyPrecision(
	p_report_header_info.reimbursement_currency_code);

  For l_recCount IN 1..l_receipt_count LOOP
    l_report_line_rec := p_report_lines_info(l_recCount);
    AP_WEB_VALIDATE_UTIL.ValidateExpLineCoreFields(
                             null, -- Bug 2242176, use preparer in blue gray
			     p_report_header_info,
                             l_report_line_rec,
                             l_recCount,
			     l_allow_credit_lines,
			     l_justreq_array,
			     l_reimbcurr_precision,
			     p_calculate_receipt_index,
			     l_errors);

    p_report_lines_info(l_recCount):= l_report_line_rec ;
  end loop;
 l_receipts_with_errors_core := l_errors.COUNT;

/*  p_report_header_info.summary_start_date := l_sdate;
  p_report_header_info.summary_end_date := nvl(l_edate, l_sdate);
*/

  -- validate flexfields
  l_debug_info := 'ValidateExpLinesCustomFields';
  l_receipts_with_errors_custom := 0;

  -- The following calcuations marked with "For PATC" were
  -- added for the R11i support for multicurrency in PA.
  -- We need to retrieve currency and exchange rate information
  -- before calling PATC.

  -- For PATC: Used when doing projects verification
  V_DateFormat := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));

  -- For PATC: Determine the time-wise last receipt to use as the
  -- exchange rate date
  -- Assumes has at least one receipt
  l_debug_info := 'Getting latest date in report'||V_DateFormat;
  V_EndExpenseDate := to_date(p_report_lines_info(1).start_date, V_DateFormat);
  FOR i IN 1 .. l_Receipt_Count LOOP
    V_DateTemp := to_date(p_report_lines_info(i).start_date, V_DateFormat);
    if (V_EndExpenseDate < V_DateTemp) then
      V_EndExpenseDate := V_DateTemp;
    end if;

    if (p_report_lines_info(i).end_date IS NOT NULL) then
      l_debug_info := 'Getting end_date';
      V_DateTemp := to_date(p_report_lines_info(i).end_date, V_DateFormat);
      if (V_EndExpenseDate < V_DateTemp) then
        V_EndExpenseDate := V_DateTemp;
      end if;
    end if;

  END LOOP;

  -- For PATC: Get information about functional currency and exchange
  -- rate for the last receipt date.  The last receipt date will be
  -- equal to sysdate.
  l_debug_info := 'Getting functional currency and exchange rate info';

  IF (NOT AP_WEB_DB_AP_INT_PKG.GetAPSysCurrencySetupInfo(V_SysInfoRec)) THEN
	NULL;
  END IF;

  -- For PATC: Get the default exchange rate for the V_EndExpenseDate
  -- reimbursement currency/functional currency
  -- We are only calling this once for all receipts
     V_DefaultExchangeRate := AP_UTILITIES_PKG.get_exchange_rate(
      V_SysInfoRec.base_currency,
      p_report_header_info.reimbursement_currency_code,
      V_SysInfoRec.default_exchange_rate_type,
      V_EndExpenseDate,
     'ValidatePATransaction');

  l_receipts_with_errors_custom := 0;
  FOR l_recCount IN 1..l_receipt_count LOOP
     l_report_line_rec := p_report_lines_info(l_recCount);
     AP_WEB_VALIDATE_UTIL.ValidateExpLineCustomFields(
                               null,
			       p_report_header_info,
                               l_report_line_rec,
			       l_recCount,
			       V_SysInfoRec,
			       V_DefaultExchangeRate,
			       V_EndExpenseDate,
			       V_DateFormat,
                               p_custom1_array,
                               p_custom2_array,
                               p_custom3_array,
                               p_custom4_array,
                               p_custom5_array,
                               p_custom6_array,
                               p_custom7_array,
                               p_custom8_array,
                               p_custom9_array,
                               p_custom10_array,
                               p_custom11_array,
                               p_custom12_array,
                               p_custom13_array,
                               p_custom14_array,
                               p_custom15_array,
                               V_IsSessionTaxEnabled,
                               p_IsSessionProjectEnabled,
			       p_receipts_errors,
                               p_calculate_receipt_index,
                               l_errors_custom,
                               l_receipts_with_errors_custom,
			       p_DataDefaultedUpdateable,
			       TRUE, -- Calling from disconnected
                               p_cust_meals_amount => l_temp_array,
                               p_cust_accommodation_amount => l_temp_array,
                               p_cust_night_rate_amount => l_temp_array,
                               p_cust_pdm_rate => l_temp_array);

     -- delete reference to temp array as this is used for per diem only
     -- disconnected solution currently does not support per diem
     -- deleting prevents inadvertent data corruption
     l_temp_array.delete; -- bug 5358186
     p_report_lines_info(l_recCount):= l_report_line_rec ;

  END LOOP;

  -- determine whether there were errors in the custom field
  p_has_core_field_errors := (l_receipts_with_errors_core > 0);
  p_has_custom_field_errors := (l_receipts_with_errors_custom > 0);

  l_debug_info := 'merge error stacks';
    AP_WEB_UTILITIES_PKG.MergeExpErrors(l_errors,
					l_errors_custom);
    AP_WEB_UTILITIES_PKG.MergeErrors(l_errors,
				     p_receipts_errors);

   p_receipts_with_errors_count :=
     AP_WEB_UTILITIES_PKG.NumOfReceiptWithError(p_receipts_errors);

EXCEPTION
  WHEN OTHERS THEN
     --       Using the AP_EBUG instead of the concatenated error text

     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'DiscValidateExpLines');
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO','');
     FND_MESSAGE.SET_TOKEN('PARAMETERS','');
     APP_EXCEPTION.RAISE_EXCEPTION;
END discValidateExpLines;

PROCEDURE Serialize(P_IsSessionProjectEnabled      IN VARCHAR2,
                    Custom1_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom2_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom3_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom4_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom5_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom6_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom7_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom8_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom9_Array         IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom10_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom11_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom12_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom13_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom14_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
                    Custom15_Array        IN AP_WEB_DFLEX_PKG.CustomFields_A,
		    ReportHdrInfo	  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
                    ExpReportLineInfo     IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
		    ReportLine	          OUT NOCOPY  LONG,
                    p_receipt_errors 	  IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

l_index 	VARCHAR2(3) := '1';
l_xtype 	VARCHAR2(1) := '';
l_recCurr 	VARCHAR2(1) := '';
l_rate 		VARCHAR2(1) := '';
l_trans 	VARCHAR2(20) := 'multi';
l_multiCurr 	VARCHAR2(1) := 'N';
l_invRate 	VARCHAR2(1) := 'N';
i 		NUMBER;
j		NUMBER;

l_num		NUMBER;

l_line 		LONG := '';
l_delim 	VARCHAR2(6) := '@att@';
debug_info 	VARCHAR2(200) := '';
current_calling_sequence 	VARCHAR2(100) := 'Serialize';
l_unexp_err 			LONG := '';
l_amtDueEmployee 		NUMBER := 0;

V_ErrorText  	LONG; -- Stores stringify version of error text
V_ErrorField 	VARCHAR2(1000); -- Stores stringify version of error field

l_recCount	NUMBER := 0;
BEGIN

  FND_PROFILE.GET('DISPLAY_INVERSE_RATE', l_invRate);
  debug_info := 'Header info';

  l_amtDueEmployee := 0;
  l_recCount := to_number(ReportHdrInfo.receipt_count);

  l_amtDueEmployee := ReportTotal2(ExpReportLineInfo);

  SerializeHeader
		(ReportHdrInfo,
		 l_index,
		 l_xtype,
		 l_recCurr,
		 l_rate,
		 l_trans,
		 l_multiCurr,
		 l_amtDueEmployee,  -- p_amtDueEmployee
		 0, -- p_amtDueccCompany
	  	 l_line);

  debug_info := 'Receipts';
  for i in 1 .. l_recCount loop
    l_line := l_line ||
              to_char(ExpReportLineInfo(i).start_date,nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'))) ||
	      l_delim;
    if (ExpReportLineInfo(i).end_date IS NULL) then
      l_line := l_line || l_delim;
    else
      l_line := l_line ||
                to_char(ExpReportLineInfo(i).end_date, nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'))) ||
		l_delim;
    end if;
    l_line := l_line || ExpReportLineInfo(i).days || l_delim;
    if (ExpReportLineInfo(i).daily_amount IS NULL) then
      l_line := l_line || l_delim;
    else
      l_line := l_line || ExpReportLineInfo(i).daily_amount || l_delim;
    end if;

    -- 5/29/97,jmiao, take away equation
    -- multi-curr support
    l_line := l_line || ExpReportLineInfo(i).receipt_amount || l_delim;
    l_line := l_line || ExpReportLineInfo(i).rate || l_delim;
    l_line := l_line || ExpReportLineInfo(i).amount || l_delim;

    if (ExpReportLineInfo(i).group_value IS NULL) then
      l_line := l_line || l_delim;
    else
      l_line := l_line || ExpReportLineInfo(i).group_value || l_delim;
    end if;

    debug_info := 'Justification';
    l_line := l_line || ExpReportLineInfo(i).justification || l_delim;

--chiho:1295832:"IS NULL" -> "IS NOT NULL":
    if (ExpReportLineInfo(i).receipt_missing_flag IS NOT NULL) then
      l_line := l_line || ExpReportLineInfo(i).receipt_missing_flag || l_delim;
    else
      l_line := l_line || l_delim;
    end if;

    debug_info := 'Expense type';
    l_line := l_line || ExpReportLineInfo(i).parameter_id || l_delim;
    -- multi-curr support
    l_line := l_line || ExpReportLineInfo(i).currency_code || l_delim;

    debug_info := 'ItemizeId';
    l_line := l_line || l_delim;

    debug_info := 'cCardTrxnId';
    l_line := l_line || l_delim;

    debug_info := 'merchant';
    l_line := l_line || l_delim;

    debug_info := 'merchDocNum';
    l_line := l_line || l_delim;

    debug_info := 'TaxRef';
    l_line := l_line || l_delim;

    debug_info := 'TaxRegNum';
    l_line := l_line || l_delim;

    debug_info := 'TaxPayerID';
    l_line := l_line || l_delim;

    debug_info := 'SupCountry';
    l_line := l_line || l_delim;

    debug_info := 'TaxCodeID';
    l_line := l_line || ExpReportLineInfo(i).taxId || l_delim;

    debug_info := 'OverrideFlag';
    l_line := l_line || l_delim;

    debug_info := 'AmountIncludeTax';
    l_line := l_line || ExpReportLineInfo(i).amount_includes_tax || l_delim;

    debug_info := 'TaxCode';
    l_line := l_line || l_delim;

    -- Get flexfield info
    debug_info := 'Dflex Arrays NumMaxFlexField = ' || ReportHdrInfo.number_max_flexfield;
    IF (ReportHdrInfo.number_max_flexfield >= 1) THEN
      debug_info := 'Dflex Array 1 at receipt' || i;
 	IF ( Custom1_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom1_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 2) THEN
 	IF ( Custom2_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom2_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 3) THEN
 	IF ( Custom3_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom3_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 4) THEN
 	IF ( Custom4_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom4_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 5) THEN
 	IF ( Custom5_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom5_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 6) THEN
 	IF ( Custom6_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom6_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 7) THEN
 	IF ( Custom7_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom7_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 8) THEN
 	IF ( Custom8_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom8_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 9) THEN
 	IF ( Custom9_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom9_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;
    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 10) THEN
 	IF ( Custom10_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom10_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;
    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 11) THEN
 	IF ( Custom11_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom11_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 12) THEN
 	IF ( Custom12_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom12_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 13) THEN
 	IF ( Custom13_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom13_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;

    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 14) THEN
 	IF ( Custom14_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom14_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;
    END IF;

    IF (ReportHdrInfo.number_max_flexfield >= 15) THEN
 	IF ( Custom15_Array.COUNT > 0 ) THEN
      		l_line := l_line || Custom15_Array(i).value || l_delim;
	ELSE
		l_line := l_line || l_delim;
	END IF;
    END IF;


    debug_info := 'Project Enabled';
    IF (P_IsSessionProjectEnabled = 'Y') THEN
      l_line := l_line || ExpReportLineInfo(I).project_number || l_delim;
      l_line := l_line || ExpReportLineInfo(I).task_number || l_delim;
    END IF;

    -- for receipt visited flag, will validate if set to 'Y'
    l_line := l_line || 'Y' || l_delim;

    -- for receipt errors
    debug_info := 'Receipt errors';

--chiho:1330572:
    IF (p_receipt_errors.EXISTS( i )) THEN
      l_line := l_line || p_receipt_errors(i).Error_Text || l_delim
		     || p_receipt_errors(i).Error_Fields || l_delim
                     || p_receipt_errors(i).Warning_Text || l_delim
		     || p_receipt_errors(i).Warning_Fields || l_delim;
    ELSE
      l_line := l_line || l_delim
		     || l_delim
                     || l_delim
		     || l_delim;
    END IF;

    l_line := l_line || '@line@';
  end loop;

  ReportLine := l_line;

  exception
    when OTHERS then
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
             'l_line = ' || l_line);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;

END Serialize;



------------------------------------------
-- Returns the sum of Amount_Array content.
-- Raise INVALID_NUMBER exception if a value is not
-- a number.
------------------------------------------
Function ReportTotal(Amount_Array in AP_WEB_PARENT_PKG.MiniString_Array)
	Return NUMBER IS
i NUMBER;
l_total NUMBER := 0;
l_num NUMBER;

BEGIN
  for i in 1 .. Amount_Array.COUNT loop
    begin
      l_num := to_number(Amount_Array(i));
      if (l_num is not null) then
        l_total := l_total + l_num;
      end if;
      exception
	when OTHERS then
          l_num:=0;
    end;
  end loop;
  return l_total;
END ReportTotal;


------------------------------------------
-- Returns the sum of ExpLines content.
-- Raise INVALID_NUMBER exception if a value is not
-- a number.
------------------------------------------
Function ReportTotal2(ExpLine_Array in AP_WEB_DFLEX_PKG.ExpReportLines_A)
	Return NUMBER IS
i NUMBER;
l_total NUMBER := 0;
l_num NUMBER;

BEGIN
  for i in 1 .. ExpLine_Array.COUNT loop
    begin
      l_num := to_number(ExpLine_Array(i).amount);
      l_total := l_total + nvl(l_num,0);
      exception
	when OTHERS then
          l_num:=0;
    end;
  end loop;
  return l_total;
END ReportTotal2;


------------------------------------------
-- Checks whether the given currency code
-- is valid or not.
------------------------------------------
function isValidCurrency (p_currency_code IN AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode)
        return boolean IS
  ---
  --- Used to determine if the receipt currency user provided is a recognized
  --- one.  Took away the where clause since receipt can be in any currency,
  --- whereas reimbursement currency should be restricted.
  ---
l_curr_code_cursor      AP_WEB_DB_COUNTRY_PKG.CurrencyCodeCursor;

l_currency_array AP_WEB_PARENT_PKG.MiniString_Array;
l_count NUMBER;
l_curr_found BOOLEAN := false;
j BINARY_INTEGER;

BEGIN
  IF ( AP_WEB_DB_COUNTRY_PKG.GetCurrCodeCursor(l_curr_code_cursor) ) THEN

    l_count := 1;
    LOOP
            FETCH l_curr_code_cursor INTO l_currency_array(l_count);
            EXIT WHEN l_curr_code_cursor%NOTFOUND;
            l_count := l_count + 1;
    END LOOP;
    CLOSE l_curr_code_cursor;
  END IF;

  --
  -- Check if the currency entered is a valid one.
  -- Do this here because in non-discon case, this check is done
  -- on client-side by Javascript, so don't want to put it in
  -- generic validation routine.
  --
  IF (p_currency_code is not NULL) THEN
    FOR j in 1 .. l_currency_array.COUNT LOOP
      IF (p_currency_code = l_currency_array(j)) THEN
        l_curr_found := true;
        EXIT;
      END IF;
    END LOOP;
  END IF;
  RETURN l_curr_found;
END isValidCurrency;

PROCEDURE ParseExpReport(
        p_user_id       IN NUMBER, -- Bug 2242176, fnd user id
	p_exp 		in LONG,
	p_table		IN OUT NOCOPY disc_prompts_table,
	p_costcenter 	in VARCHAR2,
        P_IsSessionProjectEnabled IN VARCHAR2,
        p_report_header_info 	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
	p_report_lines_info OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A,
        Custom1_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom2_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom3_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom4_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom5_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom6_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom7_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom8_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom9_Array  	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom10_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom11_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom12_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom13_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom14_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
        Custom15_Array 	 OUT NOCOPY AP_WEB_DFLEX_PKG.CustomFields_A,
  	P_DataDefaultedUpdateable   OUT NOCOPY BOOLEAN,
	p_errors 	 OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
	p_receipt_errors OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
        p_error_type            OUT NOCOPY VARCHAR2,                   -- Setup/data/no errors encountered
        p_techstack             IN  VARCHAR2 DEFAULT C_OldStack -- Old or new tech stack
) IS
  l_exp			LONG := p_exp;
  l_temp_errors		Setup_error_stack;

l_receipt_count		INTEGER;

l_currencyCode		AP_WEB_DB_AP_INT_PKG.apSetUp_baseCurrencyCode;
l_currencyName      	AP_WEB_DB_COUNTRY_PKG.curr_name;

l_dflex_enabled       	BOOLEAN;
l_tax_enabled           VARCHAR2(1);
l_tempChar            	VARCHAR2(1);

V_NumMaxPseudoFlexField   	NUMBER;

debug_info		VARCHAR2(2000);

  l_apsys_info_rec	AP_WEB_DB_AP_INT_PKG.APSysInfoRec;
l_curr_format 		VARCHAR2(80); /* reimbCurr format */
  l_terror_exists 	BOOLEAN;
EndDate			date;

  l_template_id		AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_reportID;
  l_xtypecomp_array	AP_WEB_PARENT_PKG.MiniString_Array;
  l_last_receipt_date   varchar2(25);
  l_dateformat          varchar2(100);

BEGIN

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DISC_PKG', 'start ParseExpReport');

  -- check whether descriptive flexfield is enabled under profile option
  debug_info := 'Check profile option: descriptive flexfield';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  FND_PROFILE.GET('AP_WEB_DESC_FLEX_NAME', l_tempChar);
  -- Bug 3985122 Y-Lines Only, B - Both Header and Lines
  --l_dflex_enabled := (NVL(l_tempChar, 'N') = 'Y');
  l_dflex_enabled := ((NVL(l_tempChar, 'N') = 'Y') OR (NVL(l_tempChar, 'N') = 'B'));

  -- Compute maximum number of flexfield segments
  p_report_header_info.number_max_flexfield := AP_WEB_DFLEX_PKG.GetMaxNumSegmentsUsed;
  V_NumMaxPseudoFlexField := AP_WEB_DFLEX_PKG.GetMaxNumPseudoSegmentsUsed(
    P_IsSessionProjectEnabled);

  -------------------------------------------------------
  debug_info := 'parse exp report header';
  -------------------------------------------------------
  parseExpReportHeader(p_user_id,
                       l_exp,
		       p_table,
		       p_costcenter,
		       p_report_header_info,
		       p_errors);

  -------------------------------------------------------
  debug_info := 'validate the exp report header';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  -------------------------------------------------------

  --JMARY : Replaced the call to ValidateReportHeader with ValidateHeaderNoValidSession
  --        ValidateHeaderNoValidSession does not have a call to the validatesession().

    AP_WEB_VALIDATE_UTIL.ValidateHeaderNoValidSession(
                        p_user_id 	    => p_user_id,
                        ExpReportHeaderInfo => p_report_header_info,
                        p_error 	    => p_errors,
			p_bFull_Approver_Validation => TRUE);

  --
  -- Reach the end of the report already.  Display error if any and exit.
  -- Checking for newtechstack and oldtechstack to reuse the same code for both the techstacks.
  --
  if (l_exp is null) then
    -- most likely no Line field found
    ap_web_disc_format_error(l_temp_errors, p_table, p_errors);
    if (l_temp_errors.COUNT > 0) then
      p_error_type := C_setupError;
    end if;
    if (p_techstack = C_oldstack) then
      ap_web_disc_display_format_err(l_temp_errors);
    end if;
    return;
  end if;

  debug_info := 'Check reimbursement currency';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);

--chiho:1310737:initialize the l_currencyCode:
  l_currencyCode := p_report_header_info.reimbursement_currency_code;

  begin
      if (l_currencyCode is null) then
         debug_info := 'Get base currency';

	 IF ( AP_WEB_DB_AP_INT_PKG.GetAPSysCurrencySetupInfo(l_apsys_info_rec) = TRUE ) THEN
		l_currencyCode := l_apsys_info_rec.base_currency;
	 	l_currencyName := l_apsys_info_rec.base_curr_name;
	 END IF;

      else
	 IF ( AP_WEB_DB_AP_INT_PKG.GetCurrNameForCurrCode(l_currencyCode,
					l_currencyName) <> TRUE ) THEN
		l_currencyName := NULL;
	 END IF;
      end if;
  exception
      When OTHERS then
          RAISE NO_DATA_FOUND;
  end;

  l_curr_format := FND_CURRENCY.get_format_mask(l_currencyCode, 30);

  --
  -- Can't get expense type info if template is invalid, so consider it a
  -- format error.
  --
  l_terror_exists := FALSE;
  FOR i in 1..p_errors.COUNT LOOP
    IF (p_errors(i).field = 'TEMPLATE') then
       l_terror_exists := TRUE;
    END IF;
  END LOOP;

 /*Bug 1842255 : Return if the template itself is invalid. */
  IF (l_terror_exists = TRUE) then
       p_error_type := C_setupError;
      if (p_techstack = C_oldstack) then
	fnd_message.set_name('SQLAP', 'AP_WEB_DISCON_TEMP_INVALID');
         AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      end if;
      return;
  ELSE
    debug_info := 'get expense type';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    l_template_id := to_number(p_report_header_info.template_id);

    ap_web_disc_GetExpType(p_table, l_xtypecomp_array,
			l_template_id);
  END IF;

  -----------------------------------------------------
  debug_info := 'validate receipt headers';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  -----------------------------------------------------
  ap_web_disc_val_rec_headers(l_exp, p_table, l_temp_errors);

  ------------------------------------------------------
  debug_info := 'check format error';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  ------------------------------------------------------
  ap_web_disc_format_error(l_temp_errors, p_table, p_errors);

  ----------------------------------------------------
  debug_info := 'Display format error if any';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  -- Introduced a check to differentiate between oldUI and newUI
  -- Introduced p_errors.count <> 0 to set error types -bug 6988475

  if (l_temp_errors.COUNT <> 0 OR p_errors.COUNT <> 0) then
    p_error_type := C_setupError;
    if (p_techstack = C_oldstack) then
      ap_web_disc_display_format_err(l_temp_errors);
    end if;
    return;
  end if;

  --Populate the header record
  debug_info := 'Initialize the record used in flexfield validation';
  AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
  p_report_header_info.receipt_count := '0';
  p_report_header_info.transaction_currency_type := 'multi';
  p_report_header_info.reimbursement_currency_code := l_currencyCode;
  p_report_header_info.reimbursement_currency_name := l_currencyName;
  p_report_header_info.multi_currency_flag := 'N';
  p_report_header_info.inverse_rate_flag := 'N';
  p_report_header_info.last_receipt_date := EndDate;

  ---------------------------------------------------
  debug_info := 'process receipts';
  ---------------------------------------------------
  ParseExpReportReceipts(p_user_id,
                         l_exp,
			 p_table,
                         P_IsSessionProjectEnabled,
                         p_report_header_info,
			 p_report_lines_info,
                         Custom1_Array,
                         Custom2_Array,
                         Custom3_Array,
                         Custom4_Array,
                         Custom5_Array,
                         Custom6_Array,
                         Custom7_Array,
                         Custom8_Array,
                         Custom9_Array,
                         Custom10_Array,
                         Custom11_Array,
                         Custom12_Array,
                         Custom13_Array,
                         Custom14_Array,
                         Custom15_Array,
			 p_receipt_errors,
			 p_errors, /*Bug No: 3075093*/
                         p_error_type);

   -- Introduced this check for the NewUI
   -- Removed check. This is now done in parseExpReportReceipts. Bug 1871544.
   -- Bug No: 3075093 - Included p_errors to add Header level errors in ParseExpReportReceipts

  IF (p_techstack = C_Newstack) AND (p_error_type = C_SetupError) THEN
    RETURN;
  END IF;


  l_receipt_count :=  TO_NUMBER(p_report_header_info.receipt_count);
  IF (l_receipt_count > 0) THEN
    l_last_receipt_date := to_char(p_report_lines_info(1).start_date, nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT')));
    l_dateformat := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));
    debug_info := 'Populate core fields and empty custom fields';
    AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
    FOR I IN 1..l_receipt_count LOOP

       p_report_lines_info(I).receipt_index := I;
       p_report_lines_info(I).validation_required := 'Y';
       p_report_lines_info(I).calculate_flag := NULL;
       p_report_lines_info(I).calculated_amount := NULL;
       p_report_lines_info(I).copy_calc_amt_into_receipt_amt := NULL;
       p_report_lines_info(I).amount_includes_tax  := NULL;
       p_report_lines_info(I).Tax_Code  := NULL;
       p_report_lines_info(I).TaxOverrideFlag:= 'N';
       p_report_lines_info(I).TaxId	 := NULL;

       IF (to_date(l_last_receipt_date, l_dateformat) <
           to_date(p_report_lines_info(I).start_date,l_dateformat)) THEN
          l_last_receipt_date := p_report_lines_info(I).start_date;
       END IF;

/*
       AP_WEB_DFLEX_PKG.SetExpReportLineInfo(p_report_lines_info(I),
                                            I,
                                            Xdate1_Array(I),
                                            Xdate2_Array(I),
                                            Days_Array(I),
                                            DAmount_Array(I),
                                            RecAmount_Array(I),
                                            Rate_Array(I),
                                            Amount_Array(I),
                                            xtype_Array(I),
                                            XTypeName_Array(I),
                                            RecCurr_Array(I),
                                            Group_Array(I),
                                            Justif_Array(I),
                                            receipt_missing_Array(I),
                                            'Y',
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
				            'N',
					    NULL,
                                            PAProjectID_Array(I),
                                            PAProjectNumber_Array(I),
                                            PATaskID_Array(I),
                                            PATaskNumber_Array(I),
                                            PAExpenditureType_Array(I));
*/
         debug_info := 'Populate Custom dflex array';
  	 AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
         if (not(l_dflex_enabled)) then -- get default values for custom fields
              Custom1_Array(I).value := null;
              Custom2_Array(I).value := null;
              Custom3_Array(I).value := null;
              Custom4_Array(I).value := null;
              Custom5_Array(I).value := null;
              Custom6_Array(I).value := null;
              Custom7_Array(I).value := null;
              Custom8_Array(I).value := null;
              Custom9_Array(I).value := null;
              Custom10_Array(I).value := null;
              Custom11_Array(I).value := null;
              Custom12_Array(I).value := null;
              Custom13_Array(I).value := null;
              Custom14_Array(I).value := null;
              Custom15_Array(I).value := null;

         end if;
    END LOOP;

    p_report_header_info.last_receipt_date := l_last_receipt_date;

    if (not(l_dflex_enabled)) then -- get default values for custom fields
        debug_info := 'Populate Custom values with defaults';
  	AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
        AP_WEB_DFLEX_PKG.PopulateCustomDefaultValues( p_user_id,
                                                      p_report_header_info,
                                                      p_report_lines_info,
                                                      l_receipt_count,
			                              Custom1_Array,
  			                              Custom2_Array,
  					              Custom3_Array,
  			                              Custom4_Array,
  			                              Custom5_Array,
  			                              Custom6_Array,
   				                      Custom7_Array,
  			                              Custom8_Array,
   			                              Custom9_Array,
   			                              Custom10_Array,
   			                              Custom11_Array,
   			                              Custom12_Array,
    			                              Custom13_Array,
   			                              Custom14_Array,
 			                              Custom15_Array,
                                                      p_report_header_info.number_max_FlexField,
                                                      P_DataDefaultedUpdateable);

    end if;

    -- Bug 2242176, passing fnd user id
    -- Bug 2812175, always default tax, regardless of AP_WEB_TAX_ENABLE
    -- profile option.
    -- AP_WEB_DFLEX_PKG.IsSessionTaxEnabled(l_tax_enabled, p_user_id);
    --if (l_tax_enabled = 'Y') then -- get default values for tax fields
        debug_info := 'Populate Pseudo values with defaults';
  	AP_WEB_UTILITIES_PKG.logStatement('AP_WEB_DISC_PKG', debug_info);
        AP_WEB_DFLEX_PKG.PopulatePseudoDefaultValues( p_report_header_info,
                                                      p_report_lines_info,
                                                      l_receipt_count,
                                                      P_DataDefaultedUpdateable);

    --end if;

  end if;

EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        -- JMARY Added the -20001 check
        --       Check for teckstack to support both the UI's

        IF (SQLCODE <> -20001) THEN
          FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
          FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
          FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     'ParseExpReport');
          FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'None passed.');
          FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
        END IF;
        IF (p_techstack = C_oldstack) THEN
          AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
        ELSE
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END;
END ParseExpReport;


procedure GetTill(p_exp in out nocopy long,
		  p_item out nocopy long,
		  p_sep in varchar2) IS
  pos number;

BEGIN

  if (p_exp is null) then
      p_item := null;
      return;
    end if;
    pos := instr(p_exp, p_sep);
    if ((pos is null) OR (pos = 0)) then
      p_item := p_exp;
      p_exp := null;
      return;
    end if;
    p_item := substr(p_exp, 1, pos-1);
    p_exp := substr(p_exp, pos+length(p_sep));

END GetTill;


PROCEDURE GetLine(p_exp in out nocopy long,
		  p_line out nocopy long,
		  p_max in number default 2000) IS
  sep varchar2(2) := /*fnd_global.local_chr(13)||*/'
'; -- Removed fnd_global.local_chr(13) for R12, bug 5140868
  -- pos number;
  -- l_exp long := p_exp;
  l_line long := '';

BEGIN

    GetTill(p_exp, l_line, sep);
    if (length(l_line) >= p_max) then
      p_line := substr(l_line, 1, p_max) || fnd_global.local_chr(9);
      raise VALUE_ERROR;
    else
      p_line := l_line || fnd_global.local_chr(9);
    end if;

END GetLine;

PROCEDURE GetField(p_line in out nocopy long,
		   p_field out nocopy long,
		   p_max in number default 300) IS

  sep varchar2(1) := fnd_global.local_chr(9);
  l_fld long := '';

BEGIN

  GetTill(p_line, l_fld, sep);
  if (length(l_fld) > p_max) then
    p_field := substr(l_fld, 1, p_max-1);
    raise VALUE_ERROR;
  else
    p_field := l_fld;
  end if;

END GetField;

PROCEDURE GetNonEmptyFld(p_line in out nocopy long,
			 p_field out nocopy long,
			 p_max in number default 300) IS

  l_fld varchar2(1000) := '';

BEGIN

  LOOP
    if (p_line is null) then
      p_field := null;
      return;
    end if;
    GetField(p_line, l_fld, p_max);
    if (l_fld is not null) then
      p_field := l_fld;
      return;
    end if;
  END LOOP;
  EXCEPTION
    when VALUE_ERROR then
      p_field := l_fld;
      raise VALUE_ERROR;
END GetNonEmptyFld;

PROCEDURE GetRestFldsConcat(p_line in out nocopy long,
			    p_field out nocopy varchar2) IS

  l_fld varchar2(300) := '';
  l_fldc varchar2(2000):='';

BEGIN

  LOOP
    if (p_line is null) then
      p_field := l_fldc;
      return;
    end if;
    GetField(p_line, l_fld);
    l_fldc := l_fldc || ' ' ||l_fld;
  END LOOP;

END GetRestFldsConcat;

function SwapPrompts(p_table in out nocopy disc_prompts_table,
		      p_from in number,
		      p_to in number) return boolean is
l_temp PROMPT_REC;
i number;

BEGIN

  if ((p_from <= 0) OR (p_to <= 0)) then
    return false;
  elsif (p_from = p_to) then
    return true;
  else
    l_temp := p_table(p_from);
    if (p_to <= p_table.COUNT) then
      p_table(p_from) := p_table(p_to);
    else
      for i in p_table.COUNT+1 .. (p_to - 1) loop
        p_table(i).prompt_code := '';
      end loop;
      p_table(p_from).prompt_code := '';
    end if;
    p_table(p_to) := l_temp;
  end if;
  return true;

end SwapPrompts;


/*
Written by:
  Quan Le
Purpose:
  To get the FlexField global segments.
Input:
  None
Output:
  None
Input Output:
  l_segments  (FND_DFLEX.SEGMENTS_DR): Segments data for the global flexfield
Assumption:
  The application is WEB
  The flexfield is EXPENSE AP_EXPENSE_REPORT_LINES
Date:
  11/25/98
*/
procedure getFlexFieldGlobalSegments(p_user_id in NUMBER, -- 2242176
                                     p_segments in out nocopy FND_DFLEX.SEGMENTS_DR) is
  l_DFlexField           FND_DFLEX.DFLEX_R;
  l_DFlexInfo            FND_DFLEX.DFLEX_DR;
  l_Contexts             FND_DFLEX.CONTEXTS_DR;
  l_Context              FND_DFLEX.CONTEXT_R;
  l_IsFlexFieldUsed      BOOLEAN;
  l_DebugInfo            VARCHAR2(100);

begin
   p_segments.nsegments := 0;
   AP_WEB_DFLEX_PKG.GetExpenseLineDFlexInfo(p_user_id, -- 2242176
                            l_DFlexField,
                            l_DFlexInfo,
                            l_Contexts,
                            l_IsFlexFieldUsed);

    if (l_IsFlexFieldUsed) then
       -- Get information about the global context
       l_DebugInfo := 'Get information about the global context';
       l_Context.flexfield := l_DFlexField;
       l_Context.context_code :=  l_Contexts.context_code(l_Contexts.global_context);
       FND_DFLEX.Get_Segments(l_Context, p_segments, TRUE);
    end if;

end getFlexFieldGlobalSegments;

/*
Written by:
  Quan Le
Purpose:
  To get all FlexField segment prompts. The order of the table is:
  1. All the global segments ordered by sequence number.
  2. All the context segments for context1 order by sequence number.
  3. All the context segments for context2 order by sequence number.
  4. ...(repeated for the rest of the contexts)
Input:
  p_report_header_info : Header record information
Output:
  None
Input Output:
  p_segmentPromptTable  (segmentPrompt_table): Segments data for the flexfield
Assumption:
  The application is WEB.
  The flexfield is EXPENSE AP_EXPENSE_REPORT_LINES.
Date:
  11/25/98
*/
procedure getAllSegmentPrompts(p_user_id in NUMBER,
                               p_report_header_info in AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
                               p_segmentPromptTable in out nocopy segmentPrompt_table) is
  l_DFlexField           FND_DFLEX.DFLEX_R;
  l_DFlexInfo            FND_DFLEX.DFLEX_DR;
  l_Contexts             FND_DFLEX.CONTEXTS_DR;
  l_Context              FND_DFLEX.CONTEXT_R;
  l_IsFlexFieldUsed      BOOLEAN;
  l_DebugInfo            VARCHAR2(100);

  l_segments  FND_DFLEX.SEGMENTS_DR;  -- For Flexfield global segments
  l_count number:=1;
begin
   AP_WEB_DFLEX_PKG.GetExpenseLineDFlexInfo(p_user_id, l_DFlexField,
                            l_DFlexInfo,
                            l_Contexts,
                            l_IsFlexFieldUsed);

    if (l_IsFlexFieldUsed) then
      -- Get the flexfield global prompts first
       l_DebugInfo := 'Get information about the global context';
       l_Context.flexfield := l_DFlexField;
       l_Context.context_code :=  l_Contexts.context_code(l_Contexts.global_context);
       FND_DFLEX.Get_Segments(l_Context, l_segments, TRUE);


       FOR i in 1..l_segments.nsegments LOOP
          if (l_segments.is_enabled(i)) then
             p_segmentPromptTable(l_count).exptype := C_GLOBAL;
             p_segmentPromptTable(l_count).segment_num := l_segments.sequence(i);
             p_segmentPromptTable(l_count).prompt := l_segments.row_prompt(i);
             p_segmentPromptTable(l_count).default_value := AP_WEB_DFLEX_PKG.getSegmentDefault(
                                                                         l_Context.context_code,
                                                                         l_segments, i);
             p_segmentPromptTable(l_count).found := false;
             p_segmentPromptTable(l_count).webEnabled := AP_WEB_DFLEX_PKG.isSegmentWebEnabled(l_segments, i);
             l_count := l_count+1;
          end if;
       END LOOP;

    -- Get the rest(context) segments
       FOR i in 1..l_contexts.ncontexts LOOP
           if (i <> l_Contexts.global_context AND l_Contexts.is_enabled(i)) then
              l_Context.context_code :=  l_Contexts.context_code(i);
              FND_DFLEX.Get_Segments(l_Context, l_segments, TRUE);
              FOR j in 1..l_segments.nsegments LOOP
                p_segmentPromptTable(l_count).exptype := l_Contexts.context_code(i);/*context_name?*/
                p_segmentPromptTable(l_count).segment_num := l_segments.sequence(j);
                p_segmentPromptTable(l_count).prompt := l_segments.row_prompt(j);
                p_segmentPromptTable(l_count).default_value := AP_WEB_DFLEX_PKG.getSegmentDefault(
                                                                         l_Context.context_code,
                                                                         l_segments, j);

                p_segmentPromptTable(l_count).found := false;
                p_segmentPromptTable(l_count).webEnabled := AP_WEB_DFLEX_PKG.isSegmentWebEnabled(l_segments, j);
                l_count := l_count+1;
              END LOOP;
           end if;
       END LOOP;
    end if;
end getAllSegmentPrompts;

/*
Written by:
  Quan Le
Purpose:
  To check the validity of a FlexField segment prompt. if the prompt is valid the position
  (which determines the customfield array to be used to store the segment data)
  of the segment is returned
Input:
  p_fld : segment prompt to be checked.
  p_segmentPromptTable : Array of ALL the segments for a given Flexfield.
  p_expIndexTable: Array of indices to p_segmentPromptTable for a given expense type .
Output:
  None
Input Output:
  p_number: The position of the segment in the customfield array if the prompt is valid.
            Otherwise, it is set to 0.
Assumption:
  The application is WEB.
  The flexfield is EXPENSE AP_EXPENSE_REPORT_LINES.
  p_segmentPromptTable, and p_expIndexTable are set up properly.
Date:
  12/02/98
*/
procedure checkValidFlexFieldPrompt(p_fld in varchar2,
                                    p_segmentPromptTable in segmentPrompt_table,
                                    p_expIndexTable in expIndex_table,
                                    p_number in out nocopy number) IS
BEGIN
    FOR i in 1..p_expIndexTable.count LOOP
        if (p_expIndexTable(i)>0 AND p_fld = p_segmentPromptTable(p_expIndexTable(i)).prompt) then
            p_number := i;
            return;
        end if;
    END LOOP;
    -- Invalid prompt
    p_number := 0;
END  checkValidFlexFieldPrompt;


/*
Written by:
  Quan Le
Purpose:
  To set up p_dflexTable and p_expIndextable arrays for a given expense type.
Input:
  p_expType : Expense Type
  p_segmentPromptTable : Array of ALL the segments for a given Flexfield
Output:
  None
Input Output:
  p_dflexTable : Array of ALL the segments for a given expense type
  p_expIndexTable: Array of indices to p_segmentPromptTable for a given expense type
Assumption:
  p_dflexTable was initialized by initDflexTable procedure. Therefore, this procedure
  takes care the context sensitive segments only.
  The application is WEB .
  The flexfield is EXPENSE AP_EXPENSE_REPORT_LINES.
  p_segmentPromptTable is set up properly by the following order:
  1. Globals segments ordered by segment_number.
  2. Context segments for each expense type by the order of segment_number(sequence)
Date:
  12/02/98
*/
procedure setupIndexAndDflexTable(p_expType in varchar2,
                                  p_segmentPromptTable in segmentPrompt_table ,
                                  p_dflexTable in out nocopy AP_WEB_DFLEX_PKG.CustomFields_A,
                                  p_expIndexTable in out nocopy expIndex_table) IS
l_count number;
l_start number;
BEGIN
   IF (p_segmentPromptTable is null OR p_segmentPromptTable.count = 0) THEN
       return;
   END IF;

   l_count := 1;
-- chiho:bug#825307:propagate the fix made on 11.0:
   WHILE ((l_count <= p_segmentPromptTable.count)
	AND (p_segmentPromptTable(l_count).exptype = C_GLOBAL)) LOOP
     l_count := l_count + 1;
   END LOOP;

   /*Set up the context sensitive segments */
   l_start := l_count;
   FOR i in l_start.. p_segmentPromptTable.count LOOP
       if (p_segmentPromptTable(i).exptype = p_expType) then
           p_dflexTable(l_count).prompt := p_segmentPromptTable(i).prompt;
           p_dflexTable(l_count).value := p_segmentPromptTable(i).default_value;
           p_expIndexTable(l_count) := i;
           l_count := l_count + 1;
       end if;
   END LOOP;
END;


/*
Written by:
  Quan Le
Purpose:
  To initialize p_dflexTable array with the default values for global segments. Also
  initialize p_expIndexTable to index to p_segmentPromptTable.
Input:
  p_segmentPromptTable : Array of ALL the segments for a given Flexfield.
Output:
  None
Input Output:
  p_dflexTable : Array of ALL the segments for a given expense type
  p_expIndexTable: Array of indexes to p_segmentPromptTable
Assumption:
  The application is WEB.
  The flexfield is EXPENSE AP_EXPENSE_REPORT_LINES.
  p_segmentPromptTable is set up properly by the following order:
  1. Globals segments ordered by segment_number.
  2. Context segments for each expense type by the order of segment_number(sequence)
Date:
  12/02/98
*/
procedure initIndexAndDflexTable(p_segmentPromptTable in segmentPrompt_table ,
                                  p_dflexTable in out nocopy AP_WEB_DFLEX_PKG.CustomFields_A,
                                  p_expIndexTable in out nocopy expIndex_table) IS
l_count number;
l_debug_info VARCHAR2(2000);
BEGIN
   /* Initialize first */
   l_debug_info := 'Initialize dflex table';

   FOR i in 1..AP_WEB_DFLEX_PKG.C_AbsoluteMaxFlexField LOOP
       p_dflexTable(i).prompt := null;
       p_dflexTable(i).user_prompt := null;
       p_dflexTable(i).value := null;
       p_expIndexTable(i) := 0;
   END LOOP;
   IF (p_segmentPromptTable is null OR p_segmentPromptTable.count = 0) THEN
       return;
   END IF;

   /* Put the global segments in */
   l_debug_info := 'Put global segments in';

   l_count := 1;

-- chiho:bug#825307:propagate the fix on 11.0:
   WHILE ((l_count <= p_segmentPromptTable.count)
	AND (p_segmentPromptTable(l_count).exptype = C_GLOBAL)) LOOP
      p_dflexTable(l_count).prompt := p_segmentPromptTable(l_count).prompt;
      p_dflexTable(l_count).value := p_segmentPromptTable(l_count).default_value;
      p_expIndexTable(l_count) := l_count;
      l_count := l_count + 1;
   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
   -- JMARY Replaced AP_WEB_UTILITIES_PKG.DisplayException with APP_EXCEPTION.RAISE_EXCPETION
   IF (SQLCODE <> -20001) THEN
     FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
     FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
     FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
     FND_MESSAGE.SET_TOKEN('PARAMETERS','');
     APP_EXCEPTION.RAISE_EXCEPTION;
   ELSE
     -- Do not need to set the token since it has been done in the
     -- child process
     RAISE;
   END IF;

END  initIndexAndDflexTable;


/*
Written by:
  Kristian Widjaja
Purpose:
  To inverse the rates if the profile option is set up to do so.
Input:
  None
Output:
  None
Input Output:
  p_receipts: array of expense receipts with modified rates (if any)
Assumption:
  The application is WEB.
  Rates have already passed validation, in which case they should
  contain a valid number or the number '1'.
Date:
  24-Aug-2001
*/
PROCEDURE InverseRates(p_receipts IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLines_A) IS

l_inverse_rate_profile	VARCHAR2(1);

temp_rate 	NUMBER;  /* This holds temporary rate info. */
rec_count 	NUMBER := 1; /* receipt count */

BEGIN
  --
  -- Get inverse rate profile option.
  --
  FND_PROFILE.GET('DISPLAY_INVERSE_RATE', l_inverse_rate_profile);

  -- if inverse rate profile option is set to yes, we need to
  -- convert the rate to 1/rate.
  IF (l_inverse_rate_profile = 'Y') THEN

    -- Loop through all receipts
    FOR rec_count IN p_receipts.FIRST..p_receipts.LAST LOOP
      temp_rate := TO_NUMBER(p_receipts(rec_count).rate);

      -- if user enters 0 as rate, it will cause 1/temp_rate
      -- to fail. 0 is always invalid.
      IF (temp_rate <> 0) THEN
        p_receipts(rec_count).rate :=  SUBSTR(TO_CHAR(1/TEMP_RATE),1,25);
      END IF; /* if (temp_rate <> 0) */
    END LOOP;
  END IF; /* l_inverse_rate_profile = 'Y' */
END InverseRates;


/*
Written by:
  Kristian Widjaja
Purpose:
  To check whether foreign currencies have an exchange rate of 1 or null.
  Fix for bug 1966365
Input:
  p_report_header_info: Expense Report Header Information
  p_report_lines_info:  Expense Report Lines Information
Output:
  None
Input Output:
  p_receipts_errors: Receipt error stack
Assumption:
  The application is WEB.
  Rates have already passed validation, in which case they should
  contain a valid number, null, or the number '1'.
Date:
  30-Aug-2001
*/
PROCEDURE ValidateForeignCurrencies(
        p_report_header_info  IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
        p_report_lines_info   IN AP_WEB_DFLEX_PKG.ExpReportLines_A,
        p_receipts_errors      IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack) IS

l_reimbursement_currency_code AP_WEB_DFLEX_PKG.expLines_currCode;
l_errors AP_WEB_UTILITIES_PKG.expError;
l_receipt_count BINARY_INTEGER;
rec_count 	NUMBER := 1; /* receipt count */
l_date_format   VARCHAR2(30);
l_start_date    DATE;
l_is_fixed_rate VARCHAR2(1);

--Bug 3068461
l_bUserPrefResult              BOOLEAN;
l_userPrefs                    AP_WEB_DB_USER_PREF_PKG.UserPrefsInfoRec;
l_policyRateOptions            AP_WEB_OA_DISC_PKG.PolicyRateOptionsRec;

BEGIN
  -- Get reimbursement currency
  l_reimbursement_currency_code := p_report_header_info.reimbursement_currency_code;
  l_receipt_count := TO_NUMBER(p_report_header_info.receipt_count);
  l_date_format := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));

  --Bug 3068461
  -- Get policy rate options
  AP_WEB_OA_DISC_PKG.GetPolicyRateOptions(l_policyRateOptions);

  -- Get user preferences
  l_bUserPrefResult := AP_WEB_DB_USER_PREF_PKG.GetUserPrefs(p_report_header_info.employee_id, l_userPrefs);

  -- Check if exchange rate is 1 or NULL for different currencies
  -- Loop through all receipts
  FOR rec_count IN 1..l_receipt_count LOOP
    -- Check if currency codes are different
    IF (l_reimbursement_currency_code <>
        p_report_lines_info(rec_count).currency_code) THEN

      -- Check whether value of rate is 1 or NULL
      IF (TO_NUMBER(p_report_lines_info(rec_count).rate)=1) THEN

        -- Check if it is a fixed rate - bug 2004968
        -- Workaround NULL value for start date. GL' is_fixed_rate API
        -- does not handle NULL start dates well.
        l_start_date := to_date(p_report_lines_info(rec_count).start_date, l_date_format);
        IF ((l_start_date IS NULL) OR (p_report_lines_info(rec_count).currency_code = 'OTHER')) THEN
          l_is_fixed_rate := 'N';
        ELSE
          l_is_fixed_rate :=
             GL_CURRENCY_API.is_fixed_rate(p_report_lines_info(rec_count).currency_code, l_reimbursement_currency_code, l_start_date);
        END IF;

        -- Output error message if it is not a fixed rate
        IF (l_is_fixed_rate = 'N') THEN
          fnd_message.set_name('SQLAP', 'OIE_FOREIGN_EXCH_RATE_ONE');
          AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
            fnd_message.get_encoded(),
            AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
            C_Rate_Prompt,
            rec_count);
        END IF;
      -- Bug 3068461 : Don't raise an error if in setup the exchange rate is
      -- either Yes or if its User Definable and exchange rate in Expenses
      -- preferences is Yes
      ELSIF ( p_report_lines_info(rec_count).rate IS NULL AND
              ((l_policyRateOptions.default_exchange_rates = 'N') OR
               (l_policyRateOptions.default_exchange_rates = 'U' AND
                l_userPrefs.default_exchange_rate_flag = 'N')) ) THEN

        -- Output error message
        fnd_message.set_name('SQLAP', 'OIE_NEED_EXCH_RATE');
        AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
          fnd_message.get_encoded(),
          AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
          C_Rate_Prompt,
          rec_count);
      END IF; -- rate
    END IF; -- reimbursement currency <> receipt currency
  END LOOP;

  -- Merge errors with receipt error stack
  AP_WEB_UTILITIES_PKG.MergeErrors(l_errors, p_receipts_errors);

END ValidateForeignCurrencies;

------------------------------------------------------------------------------------------------
FUNCTION GetAKRegionPromptsCursor(p_reg_code 		IN  AK_REGION_ITEMS_VL.region_code%TYPE,
				  p_prompts_cursor  OUT NOCOPY PromptsCursor)
RETURN  BOOLEAN IS
-----------------------------------------------------------------------------------------------
l_error			varchar2(500) := '';
BEGIN
OPEN p_prompts_cursor FOR
        select  ATTRIBUTE_LABEL_LONG,ATTRIBUTE_CODE
        from    AK_REGION_ITEMS_VL
        where   REGION_CODE = p_reg_code
        order by DISPLAY_SEQUENCE;

return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
     AP_WEB_DB_UTIL_PKG.RaiseException('GetAkRegionPromptsCursor');
     APP_EXCEPTION.RAISE_EXCEPTION;
     return FALSE;
END GetAKRegionPromptsCursor;

PROCEDURE getPrompts( c_region_application_id in number,
                      c_region_code in varchar2,
                      c_title out nocopy AK_REGIONS_VL.NAME%TYPE,
                      c_prompts out nocopy AP_WEB_UTILITIES_PKG.prompts_table)
IS
  l_title         AK_REGIONS_VL.NAME%TYPE;
  l_prompts       icx_util.g_prompts_table;
  i               number;
BEGIN
  --
  -- Populate Prompt tables for translation
  --
  icx_util.getPrompts(c_region_application_id,
                      c_region_code,
                      l_title,
                      l_prompts);

  c_prompts(0) := l_prompts(0);

  FOR i in 1 .. to_number(l_prompts(0))
    LOOP
      c_prompts(i) := l_prompts(i);
    END LOOP;

END getPrompts;

END AP_WEB_DISC_PKG;

/
