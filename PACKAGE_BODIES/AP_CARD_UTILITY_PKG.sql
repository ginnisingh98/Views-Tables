--------------------------------------------------------
--  DDL for Package Body AP_CARD_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CARD_UTILITY_PKG" AS
/* $Header: apwpcutb.pls 120.8.12010000.3 2010/04/06 09:37:33 vbondada ship $ */

-- Constants
c_strImagePath CONSTANT varchar2(100) :=  '/OA_MEDIA/';



PROCEDURE WF_UTILS(
	      p_desc in VARCHAR,p_out out NOCOPY VARCHAR)
IS
l_desc varchar2(240):='SUperb';
BEGIN
p_out:=RTRIM(wf_notification.SubstituteSpecialChars(p_desc));
END;


--------------------------------------------------------------------------
-- Function BUILD_ACCOUNT
--
-- Returns code_combination_id (number) after overlaying segment values
-- qualified as cost center (FA_COST_CTR) and account (GL_ACCOUNT) on the
-- segments identified by P_CODE_COMBINATION_ID.
--
-- Cost center and account are validated independently before overlaying
-- is attempted.  Errors resulting from independent segment validation are
-- returned as P_ERROR_MESSAGE and the operation is aborted.
--
-- If new combination results in an error, the flex API error will be
-- returned as P_ERROR_MESSAGE and the value -1 will be returned.
--
--------------------------------------------------------------------------
PROCEDURE BUILD_ACCOUNT(
              P_CODE_COMBINATION_ID     IN NUMBER,
              P_COST_CENTER             IN VARCHAR2,
              P_ACCOUNT_SEGMENT_VALUE   IN VARCHAR2,
              P_ERROR_MESSAGE           IN VARCHAR2,
              P_CALLING_SEQUENCE        IN VARCHAR2,
              P_EMPLOYEE_ID             IN NUMBER,
	      P_CCID OUT NOCOPY VARCHAR )
IS
  l_segments     FND_FLEX_EXT.SEGMENTARRAY;
  l_code_combination_id            NUMBER;
  l_num_segments             NUMBER;
  l_flex_segment_number      NUMBER;
  l_cc_flex_segment_number   NUMBER;
  l_chart_of_accounts_id     NUMBER;
  l_concatenated_segments    VARCHAR2(2000);
  l_flex_segment_delimiter	VARCHAR2(1);
  l_debug_info               VARCHAR2(100);
  l_current_calling_sequence VARCHAR2(2000);
  L_ERROR_MESSAGE varchar2(1000);
BEGIN

l_current_calling_sequence := 'AP_CARD_VERIFY_PKG.BUILD_ACCOUNT';
  --
  -- Return P_CODE_COMBINATION_ID is P_COST_CENTER and
  -- P_ACCOUNT_SEGMENT_VALUE are null
  --
  if (P_COST_CENTER is null and
      P_ACCOUNT_SEGMENT_VALUE='-1') then
    P_CCID:=''||P_CODE_COMBINATION_ID||'';
    return;
  end if;

  --
  -- Validate Cost Center if passed to API.
  --

  if (P_COST_CENTER is not null) then
    l_debug_info := 'Validating Cost Center';

    ValidateCostCenter(
                           P_COST_CENTER,
                           L_ERROR_MESSAGE,
                           P_EMPLOYEE_ID);  --2664451

   /* if (L_ERROR_MESSAGE is not null) then
      --2484206
     --the validate cost center returns an encoded message for versions
     --of apwvutlb.pls 115.56 and higher.  The unique thing about an encoded
     --message is that it will have a chr(0) in it.  This seperates the
     --application from the message name.  So if we receive an encoded message
     --we will get the message string.  The reason I am doing this this way
     --is to avoid a dependency between pcards and OIE.

        if instrb(l_error_message,chr(0)) <> 0 then
           fnd_message.set_encoded(p_error_message);
           l_error_message := fnd_message.get();
        end if;
        P_CCID:=''||'-1'||'';
        return;
    end if; */
   end if;

 /* FND_GLOBAL.Apps_Initialize(FND_GLOBAL.USER_ID,
                             FND_GLOBAL.RESP_ID,
                             FND_GLOBAL.RESP_APPL_ID);*/


  ----------------------------------------
  l_debug_info := 'Get Chart of Accounts ID';
  ----------------------------------------

  IF (NOT GetCOAofSOB(l_chart_of_accounts_id)) THEN
	NULL;
  END IF;

  ----------------------------------------
  l_debug_info := 'Get Segment Delimiter';
  ----------------------------------------

  l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id);

  IF (l_flex_segment_delimiter IS NULL) THEN

    --l_error_message := l_debug_info||': '||FND_MESSAGE.GET;
      P_CCID:=''||'-1'||'';
      return;
  END IF;

  -----------------------------------------------
 l_debug_info := 'Get Cost Center Qualifier Segment Number';
  -----------------------------------------------

  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cc_flex_segment_number)) THEN
       --l_error_message := FND_MESSAGE.GET;
       P_CCID:=''||'-1'||'';
       return;
  END IF;

  -----------------------------------------------
  l_debug_info := 'Get Account Qualifier Segment Number';
  -----------------------------------------------
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'GL_ACCOUNT',
                                l_flex_segment_number)) THEN
       --l_error_message := FND_MESSAGE.GET;
       P_CCID:=''||'-1'||'';
       return;
  END IF;

  -----------------------------------------------------------------
  l_debug_info := 'Get ccid account segments';
  -----------------------------------------------------------------
  if (nvl(P_CODE_COMBINATION_ID,-1) <> -1) then

    IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                P_CODE_COMBINATION_ID,
                                l_num_segments,
                                l_segments)) THEN

        --l_error_message := FND_MESSAGE.GET;
        P_CCID:=''||'-1'||'';
        return;
   END IF;
  end if;

  -------------------------------------------------
  l_debug_info := 'Overlay the cost center segment';
  ---------------------------------------------------
  if (P_COST_CENTER is not null) then

    l_segments(l_cc_flex_segment_number) := P_COST_CENTER;
  end if;

  ---------------------------------------------------
  l_debug_info := 'Overlay the account segment';
  ---------------------------------------------------
  if (P_ACCOUNT_SEGMENT_VALUE is not null) then

    l_segments(l_flex_segment_number) := P_ACCOUNT_SEGMENT_VALUE;
  end if;

  --------------------------------------------------------------
  l_debug_info := 'Retrieve new ccid with overlaid segments';

   l_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_num_segments,
				l_segments,
				l_flex_segment_delimiter);

  IF (NOT AP_CARD_UTILITY_PKG.GET_COMBINATION_ID(
				'SQLGL',
				'GL#',
				l_chart_of_accounts_id,
				SYSDATE,
				l_num_segments,
				l_segments,
                                l_concatenated_segments,
				l_code_combination_id,
                                l_error_message)) THEN
       P_CCID:=''||'-1'||'';
       return;
  END IF;
P_CCID:=''||l_code_combination_id||'';
EXCEPTION
  WHEN OTHERS THEN
    P_CCID:=''||'-1'||'';
    return;
END;



-------------------------------------------------------------------------------
FUNCTION get_combination_id(p_application_short_name 	IN  VARCHAR2,
			    p_key_flex_code	IN  VARCHAR2,
			    p_structure_number	IN  NUMBER,
			    p_validation_date	IN  DATE,
			    p_n_segments	IN  NUMBER,
			    p_segments		IN  fnd_flex_ext.SegmentArray,
                            p_concatSegments    IN  VARCHAR2,
			    p_combination_id OUT NOCOPY NUMBER,
                            p_return_error_message IN  OUT NOCOPY VARCHAR2)  RETURN BOOLEAN IS
-------------------------------------------------------------------------------

BEGIN

    IF (FND_FLEX_KEYVAL.validate_segs('CREATE_COMB_NO_AT',
		                      p_application_short_name,
		                      p_key_flex_code,
		                      p_structure_number,
		                      p_concatSegments)) THEN
           p_combination_id := FND_FLEX_KEYVAL.combination_id;
           return TRUE;
    ELSE
      	   p_return_error_message := FND_FLEX_KEYVAL.error_message;
      	   return FALSE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       null;
END get_combination_id;



-------------------------------------------------------------------------------
FUNCTION validateSession(p_func in varchar2 default null,
			 p_commit in boolean default TRUE,
			 p_update in boolean default TRUE) return boolean is
-------------------------------------------------------------------------------
begin

  return icx_sec.VALIDATESESSION(P_FUNC, '', P_COMMIT, P_UPDATE);

  -- RETURN TRUE;

END;

-------------------------------------------------------------------------------
PROCEDURE JUMPINTOFUNCTION(P_ID			IN NUMBER,
             		   P_MODE		IN VARCHAR2,
                           P_URL	 OUT NOCOPY VARCHAR2) IS
-------------------------------------------------------------------------------
L_ORG_ID	AP_EXPENSE_FEED_LINES_ALL.ORG_ID%TYPE;
L_FUNCTION_CODE VARCHAR2(30);
L_DEBUG_INFO	VARCHAR2(200);

BEGIN

  ---------------------------------
  L_DEBUG_INFO := 'GETTING ORG ID';
  ---------------------------------

  IF (P_MODE = 'PCARD EMP VERI') THEN
-- CHIHO:P-CARD RELATED, IGNORED:
    SELECT DISTINCT(NVL(FL.ORG_ID,FD.ORG_ID))
    INTO   L_ORG_ID
    FROM   AP_EXPENSE_FEED_LINES_ALL FL,
	   AP_EXPENSE_FEED_DISTS_ALL FD
    WHERE  FL.EMPLOYEE_VERIFICATION_ID = P_ID
    OR     (FD.FEED_LINE_ID = FL.FEED_LINE_ID AND
	   FD.EMPLOYEE_VERIFICATION_ID = P_ID);

    L_FUNCTION_CODE := 'ICX_AP_WEB_OPEN_PCARD_TRANS';

  ELSIF (P_MODE = 'PCARD MANAGER APPR') THEN
-- CHIHO:P-CARD RELATED, IGNORED:
    SELECT DISTINCT(ORG_ID)
    INTO   L_ORG_ID
    FROM   AP_EXPENSE_FEED_DISTS_ALL
    WHERE  MANAGER_APPROVAL_ID = P_ID;

    L_FUNCTION_CODE := 'ICX_AP_WEB_OPEN_PCARD_TRANS';

  END IF;

    -----------------------------------------------
    L_DEBUG_INFO := 'CALLING ICX JUMPINTOFUNCTION';
    -----------------------------------------------
    P_URL := ICX_SEC.JUMPINTOFUNCTION(
		 	P_APPLICATION_ID     => 200,
			P_FUNCTION_CODE	     => L_FUNCTION_CODE,
			P_PARAMETER1	     => TO_CHAR(P_ID),
			P_PARAMETER2	     => P_MODE,
                        P_PARAMETER11        => TO_CHAR(L_ORG_ID));
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('AP_CARD_UTILITY_PKG', 'JUMPINTOFUNCTION',
                     'APEXP', TO_CHAR(P_ID), TO_CHAR(0), L_DEBUG_INFO);
    RAISE;
END JUMPINTOFUNCTION;

-------------------------------------------------------------------------------
PROCEDURE ICXSETORGCONTEXT(P_SESSION_ID	IN VARCHAR2,
			   P_ORG_ID	IN VARCHAR2) IS
-------------------------------------------------------------------------------
L_DEBUG_INFO 	VARCHAR2(200);
BEGIN

  ----------------------------------------------
  L_DEBUG_INFO := 'CALLING ICX SET_ORG_CONTEXT';
  ----------------------------------------------
  ICX_SEC.SET_ORG_CONTEXT(P_SESSION_ID, ICX_CALL.DECRYPT(P_ORG_ID));

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.CONTEXT('AP_CARD_UTILITY_PKG', 'ICXGETORGCONTEXT',
                     'APEXP', NULL , TO_CHAR(0), L_DEBUG_INFO);
    RAISE;
END ICXSETORGCONTEXT;

/*The procedures below have been just copied from i-expenses
  packages to AP package.This is being done to remove any sort
  of dependency on OIE for PCARDS*/

FUNCTION IsPersonCwk (p_person_id IN NUMBER) return VARCHAR2
IS
  v_numRows NUMBER := 0;
BEGIN
  -- This query returns rows if there exist an active employee or cwk
  -- record for the given person ID.
  SELECT 1
   INTO v_numRows
  FROM DUAL
  WHERE EXISTS
  (SELECT 1
   FROM
     per_cont_workers_current_x p
   WHERE
     p.person_id = p_person_id);

  -- Return true if there were rows, return false otherwise
  IF v_numRows = 1 THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
 WHEN no_data_found  THEN
  return('N');
 WHEN OTHERS THEN
  raise;
END IsPersonCwk;

FUNCTION GetCOAofSOB(
	p_chart_of_accounts OUT NOCOPY NUMBER
) RETURN BOOLEAN IS
BEGIN
  select  GS.chart_of_accounts_id
  into    p_chart_of_accounts
  from    ap_system_parameters S,
          gl_sets_of_books GS
  where   GS.set_of_books_id = S.set_of_books_id;

  return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN FALSE;

	WHEN OTHERS THEN
		RETURN FALSE;

END GetCOAofSOB;

FUNCTION GetDependentSegment(
        p_value_set_name        IN     fnd_flex_value_sets.flex_value_set_name%type,
        p_chart_of_accounts_id  IN NUMBER,
        p_dependent_seg_num     OUT NOCOPY  NUMBER)
RETURN BOOLEAN IS
        l_parent_flex_value_set_id fnd_flex_value_sets.parent_flex_value_set_id%type;
BEGIN
          select PARENT_FLEX_VALUE_SET_ID into l_parent_flex_value_set_id
          from fnd_flex_value_sets
          where flex_value_set_name like p_value_set_name
          and PARENT_FLEX_VALUE_SET_ID is not null;

        IF (l_parent_flex_value_set_id IS NOT NULL) THEN

          SELECT s.segment_num into p_dependent_seg_num
          FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
          fnd_segment_attribute_types sat
            WHERE s.application_id = 101
            AND s.id_flex_code = 'GL#'
            AND s.id_flex_num = p_chart_of_accounts_id
            AND s.enabled_flag = 'Y'
            AND s.application_column_name = sav.application_column_name
            AND sav.application_id = 101
            AND sav.id_flex_code = 'GL#'
            AND sav.id_flex_num = p_chart_of_accounts_id
            AND sav.attribute_value = 'Y'
            AND sav.segment_attribute_type = sat.segment_attribute_type
            AND sat.application_id = 101
            AND sat.id_flex_code = 'GL#'
            AND sat.unique_flag = 'Y'
            AND s.FLEX_VALUE_SET_ID=l_parent_flex_value_set_id
            AND rownum =1;
   END IF;
        return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    return FALSE;
END GetDependentSegment;

FUNCTION COSTCENTERVALID(
	P_COST_CENTER		IN  EXPFEEDDISTS_COSTCENTER,
	P_VALID		 OUT NOCOPY BOOLEAN,
        P_EMPLOYEE_ID           IN  NUMBER
) RETURN BOOLEAN IS
L_VALID	VARCHAR2(1) := 'N';

L_EMPLOYEE_ID             NUMBER;
L_CHART_OF_ACCOUNTS_ID    NUMBER;
L_DEFAULT_EMP_CCID        NUMBER;
L_FLEX_SEGMENT_DELIMITER  VARCHAR2(1);
L_FLEX_SEGMENT_NUMBER     NUMBER;
L_NUM_SEGMENTS            NUMBER;
L_DEFAULT_EMP_SEGMENTS    FND_FLEX_EXT.SEGMENTARRAY;
L_CONCATENATED_SEGMENTS   VARCHAR2(2000);
L_APPCOL_NAME               FND_ID_FLEX_SEGMENTS_VL.APPLICATION_COLUMN_NAME%TYPE;
L_SEG_NAME                  FND_ID_FLEX_SEGMENTS_VL.SEGMENT_NAME%TYPE;
L_PROMPT                    FND_ID_FLEX_SEGMENTS_VL.FORM_LEFT_PROMPT%TYPE;
L_VALUE_SET_NAME            FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE;
L_PARENT_FLEX_VALUE_SET_ID  FND_FLEX_VALUE_SETS.PARENT_FLEX_VALUE_SET_ID%TYPE;
L_DEPENDENT_SEG_NUM         NUMBER := 0;

L_EMP_SET_OF_BOOKS_ID       NUMBER;
l_ou_chart_of_accounts_id   NUMBER;
l_emp_chart_of_accounts_id  NUMBER;

BEGIN

   l_employee_id := p_employee_id;
    --bug5058949
    --Performance fix
   if not (ispersoncwk(l_employee_id)='Y') then
     SELECT emp.set_of_books_id, emp.default_code_combination_id
     INTO l_emp_set_of_books_id, l_default_emp_ccid
     FROM  per_employees_x emp
     WHERE  emp.employee_id = l_employee_id;
   else
     SELECT emp.set_of_books_id, emp.default_code_combination_id
     INTO l_emp_set_of_books_id, l_default_emp_ccid
     FROM  per_cont_workers_current_x emp
     WHERE  emp.person_id = l_employee_id;
   end if;
   -- Get the chart_of_account_id from system parameters
   IF (NOT GetCOAofSOB(l_ou_chart_of_accounts_id)) THEN
      l_ou_chart_of_accounts_id := null;
   END IF;

   IF (l_emp_set_of_books_id is not null) THEN
      SELECT GS.chart_of_accounts_id
      INTO   l_emp_chart_of_accounts_id
      FROM   gl_sets_of_books GS
      WHERE  GS.set_of_books_id = l_emp_set_of_books_id;

      IF (l_emp_chart_of_accounts_id <> l_ou_chart_of_accounts_id) THEN
        p_valid := FALSE;
        return FALSE;
      END IF;
   END IF;

   l_chart_of_accounts_id := l_ou_chart_of_accounts_id;

   -- Get the character used as the segment delimiter. This would be
   -- used to prepare the concatenated segment from segment array to a string.
   l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id);

   -- Get the segment number corresponding to the costcenter qualifier.
   -- This is used to overlay the costcenter segment
   if (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_flex_segment_number)) then
        p_valid := FALSE;
        return FALSE;
   end if;

   -- Get the segment array and number of segments for the employee
   -- code combination id.
   if (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                l_default_emp_ccid,
                                l_num_segments,
                                l_default_emp_segments)) then
        p_valid := FALSE;
        return FALSE;
    end if;

    /*Bug 2690715 : Called function to get the dependent segment
                of cost center segment and then do the validation.
    */

    IF (FND_FLEX_APIS.GET_SEGMENT_INFO(
                                    101,
                                    'GL#',
                                    l_chart_of_accounts_id,
                                    l_flex_segment_number,
                                    l_appcol_name,
                                    l_seg_name,
                                    l_prompt,
                                    l_value_set_name)) then

        IF (GetDependentSegment(l_value_set_name,
                            l_chart_of_accounts_id,
                            l_dependent_seg_num)) THEN
                NULL;
        END IF;

    END IF;

/*Bug 2690715 : Dont set the segment to NULL , if dependent valueset
                of cost center segment exists.
*/
   IF (l_dependent_seg_num IS NULL) THEN
    FOR i in 1 .. l_num_segments LOOP
       l_default_emp_segments(i) := '';
    END LOOP;
   END IF;

    -- Overlay the costcenter segment with the costcenter entered in the
    -- expense report
    l_default_emp_segments(l_flex_segment_number) := p_cost_center;

    -- Get the concatenated segments with all segments set to null, except the
    -- costcenter, Concatenates segments from segment array
    -- (l_default_emp_segments) to a string(l_concatenated_segments).
    l_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_num_segments,
                                l_default_emp_segments,
                                l_flex_segment_delimiter);

    /* -----------------------------------------------------------------------+
    + Validate only the costcenter segment, since we are passing other        +
    + segments as null we need to set allow_nulls to true                     +
    + Allow_nulls will allow required segments that are NULL to be valid      +
    + allow_orphans will validate dependent segment values without associated +
    + parent values, allowing ANY possible dependent value, regardless        +
    + of what the parent value would be,  to be considered valid.             +
    +------------------------------------------------------------------------*/
/*Bug 2706584: Passed VRULE as a parameter to Validate_Segs so that
	       it does not pass the cost center for which
	       Posting Allowed is  Unchecked.
*/

/*Bug 2690715:Validate using only segment of COST CENTER if
              No Dependent Segment is present.Else validate
              using Combination,Flex Field does not support
              partial combination validation. i.e Like 01-520----
             can not be successfully validated.
*/
IF (l_dependent_seg_num IS NULL) THEN
    if ( fnd_flex_keyval.validate_segs(operation=>'CHECK_SEGMENTS',
               appl_short_name=>'SQLGL',
               key_flex_code=>'GL#',
               structure_number=>l_chart_of_accounts_id,
               concat_segments=>l_concatenated_segments,
	       VRULE=>'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=AP_ALL_POSTING_NA\nY\0\nSUMMARY_FLAG\nI\nNAME=Flex-Parent not allowed\nN',
               allow_nulls=>TRUE,
               allow_orphans=>TRUE ) ) then
        p_valid := TRUE;
    else
        p_valid := FALSE;
    end if;
ELSE
    if ( fnd_flex_keyval.validate_segs(operation=>'CHECK_COMBINATION',
               appl_short_name=>'SQLGL',
               key_flex_code=>'GL#',
               structure_number=>l_chart_of_accounts_id,
               concat_segments=>l_concatenated_segments,
               VRULE=>'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=AP_ALL_POSTING_NA\nY\0\nSUMMARY_FLAG\nI\nNAME=Flex-Parent not allowed\nN',
               allow_nulls=>TRUE,
               allow_orphans=>TRUE ) ) then
        p_valid := TRUE;
    else
        p_valid := FALSE;
    end if;
END IF;

    return TRUE;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		p_valid := FALSE;
		RETURN FALSE;

	WHEN OTHERS THEN
    		return FALSE;

END CostCenterValid;

PROCEDURE ValidateCostCenter(p_costcenter IN  varchar2,
			     p_cs_error     OUT NOCOPY varchar2,
        		     p_employee_id  IN  NUMBER) IS
p_CostCenterValid       boolean;
l_customError           varchar2(2000);

l_CostCenterValid	BOOLEAN := FALSE;
INVALID_COST_CENTER exception;

BEGIN


  FND_MSG_PUB.initialize;
  --
  -- Call custom cost center validation API
  --
  if (CustomValidateCostCenter(
         l_customError,
         p_costcenter,
         p_CostCenterValid,
         p_employee_id)) then
    --
    -- Custom validation API returned TRUE; therefore custom validation
    -- is used in lieu of native cost center validation
    --
    if (p_CostCenterValid) then
      --
      -- If custom validation succeeds, clear the error text
      --
      p_cs_error := null;
    else
      --
      -- Custom validation failed; supply standard failure message if
      -- custom error message is null
      --
      if (l_customError is null) then
          FND_MESSAGE.SET_NAME('SQLAP','AP_COST_CENTER_INVALID');
          FND_MSG_PUB.add;
          raise INVALID_COST_CENTER;
      else
        p_cs_error := l_customError;
        raise INVALID_COST_CENTER;
      end if;

    end if;
  else
    --
    -- Custom validation API returned FALSE; therefore we validate using
    -- the cursor declared above.
    --
    IF (NOT CostCenterValid(p_costCenter,
		l_CostCenterValid,
                p_employee_id)) THEN
	NULL;
    END IF;
    if (NOT l_CostCenterValid) then
      --
      -- Failed; set standard failure message.
      --
        FND_MESSAGE.SET_NAME('SQLAP','AP_COST_CENTER_INVALID');
        FND_MSG_PUB.add;
        raise INVALID_COST_CENTER;
    end if;
  end if;
 EXCEPTION
  WHEN INVALID_COST_CENTER THEN
     RAISE;
END ValidateCostCenter;

----------------------------------------------------------------------------
-- CUSTOMVALIDATECOSTCENTER:
--    Called by ValidateCostCenter();
-- API provides a means of bypassing native cost center segment validation
-- and using custom code to validate cost center value.
--
--    Function returns TRUE if custom cost center segment validation is
-- enabled, or FALSE if native validation should be used.  By default,
-- we assume that native validation is used.
--
-- PARAMETERS:
--
--    p_cs_error        - Set this variable with your custom error message.
--                        If left blank, standard error message will be used.
--    p_CostCenterValue - The cost center entered by the user
--    p_CostCenterValid - TRUE if cost center is valid, otherwise FALSE;
--
----------------------------------------------------------------------------
FUNCTION CustomValidateCostCenter(
        p_cs_error              OUT NOCOPY VARCHAR2,
        p_CostCenterValue       IN VARCHAR2,
        p_CostCenterValid       IN OUT NOCOPY BOOLEAN,
        p_employee_id           IN NUMBER) return BOOLEAN IS
----------------------------------------------------------------------------
BEGIN
  --
  -- Assume cost center is valid
  --
  p_CostCenterValid := TRUE;

  return(FALSE); -- return TRUE if using this extension to perform validation

  -- Note: If any error occurred and p_cs_error needs to be set by getting
  --       a FND message, make sure to use the following syntax:
  --
  -- p_CostCenterValid := FALSE;
  --
  -- FND_MESSAGE.SET_NAME('SQLAP', '<MESSAGE NAME>');
  -- p_cs_error :=  FND_MESSAGE.GET_ENCODED();
  --
  -- return(TRUE);

END CustomValidateCostCenter;


END AP_CARD_UTILITY_PKG;

/
