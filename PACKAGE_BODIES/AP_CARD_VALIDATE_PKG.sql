--------------------------------------------------------
--  DDL for Package Body AP_CARD_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CARD_VALIDATE_PKG" AS
/* $Header: apwcvalb.pls 120.9.12010000.4 2010/04/19 11:25:55 syeluri ship $ */

---------------------------------------------------------------------------
--
-- Procedure VALIDATE
--
-- Populates foreign keys and validates user-provided FKs.
-- Determines exceptions, populates REJECT_CODE
--  o CARD_ID - FK to AP_CARDS.  Match on CARD_NUMBER
--  o CODE_ID - FK to AP_CARD_CODES.
--    Match on CODE_VALUE for CARD_CODE_SET defined for this card program
--    (CARD_PROGRAM_ID)
--  o EMPLOYEE_ID - denormalized from AP_CARDS.
--  o Validates Currency Codes, CARD_PROGRAM_ID
--  o Insures no duplicate reference numbers for this card program
--  o Exception raised if card profile is such that account is built from
--    code (BAFCF=Y) and distributions are created from line (CDF=Y) and
--    CODE_ID cannot be determined from CODE_VALUE.
--  o Exception raised if card profile is such that verification is
--    required (EVM=Y) but it is not specified that distributions be created
--    from lines (CDF=N or null).
--
-- Where
--  o EVM denotes AP_CARD_PROFILES.EMP_NOTIFICATION_LOOKUP_CODE
--  o MAM denotes AP_CARD_PROFILES.MGR_APPROVAL_LOOKUP_CODE
--  o CDF denotes AP_EXPENSE_FEED_LINES.CREATE_DISTRIBUTION_FLAG
--  o BAFCF denotes AP_CARD_PROFILES.BUILD_ACCT_FROM_CODE_FLAG
--    (AP_CARD_PROFILES is parent of AP_CARDS).
--
--
-- Assigned Exceptions.  Exception code stored in
-- AP_EXPENSE_FEED_LINES.REJECT_CODE
--
-- AP_LOOKUP_CODES.LOOKUP_TYPE='CARD EXCEPTION'
--
-- Lookup Code          Displayed Field        Description
-- ==================== ====================== =============================
-- INVALID CARD NUM     Invalid Card Number    The Credit Card Number
--                                             does not match a defined
--                                             credit card
-- DUPLICATE REFERENCE  Duplicate Reference    Another transaction exists
--                                             with this reference number
-- INVALID POST CURR    Invalid Post Currency  The Posting Currency is not
--                                             recognized
-- INVALID TRX CURR     Invalid Currency       The Transaction Currency is
--                                             not recognized
-- INVALID CARD CODE    Invalid Card Code      The merchant category code is
--                                             not recognized for this card
--                                             program
-- DIST REQUIRED        Distribution Required  A distribution must be created
--                                             because employee or manager
--                                             audit is required
-- INVALID ACCOUNT      Cannot determine       An account cannot be
--                      account                determined.
--
---------------------------------------------------------------------------
PROCEDURE VALIDATE(
      P_CARD_PROGRAM_ID IN NUMBER,
      P_START_DATE      IN DATE DEFAULT NULL,
      P_END_DATE        IN DATE DEFAULT NULL) IS
  l_debug_info                  VARCHAR2(100);
  x_return_status VARCHAR2(4000);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(4000);
  p_card_instrument APPS.IBY_FNDCPT_SETUP_PUB.CREDITCARD_REC_TYPE;
  x_instr_id NUMBER;
  l_card number;
  x_response APPS.IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
  l_card_id NUMBER;
  l_card_reference_id ap_cards_all.card_reference_id%type ;
BEGIN

  --------------------------------------------------------------------
  l_debug_info :=
       'Set REJECT_CODE to UNTESTED for those lines we will be validating.';
  --------------------------------------------------------------------
  --
  -- No need to validate lines for which distributions have already
  -- been created
  --
  update ap_expense_feed_lines efl
  set    reject_code = 'UNTESTED'
  where  card_program_id = P_CARD_PROGRAM_ID
  and    posted_date between nvl(P_START_DATE, posted_date - 1) and
                             nvl(P_END_DATE, posted_date + 1)
  and    not exists
    (select 'A distribution exists for this expense feed line'
     from   ap_expense_feed_dists efd
     where  efd.feed_line_id = efl.feed_line_id);

  --------------------------------------------------------------------
  l_debug_info := 'Find the matching card number in AP_CARDS';
  --------------------------------------------------------------------
/*  update ap_expense_feed_lines efl
  set    card_id =
    (select c.card_id
     from   ap_cards c
     where  c.card_number = efl.card_number)
  where  card_id is null
  and    reject_code = 'UNTESTED';*/

/*-------------------------------------------------------------------------------------------------------*/
--Changes done for PCARD project to reflect the new IBY Cards Model
/*We would allow the user to enter the card number from the control file(sql loader) and then
  store it in ap_expense_feed_lines.Now while validation we would check if the card number
  exists which would return instrument id if it exists and this with card-program-id would
  be used to get the card_id which would be populated eventually*/
/*-------------------------------------------------------------------------------------------------------*/
     for i in (select card_number,card_id,feed_line_id
	       from ap_expense_feed_lines where reject_code='UNTESTED'
              )
     loop
     --8726861
       BEGIN

         select aca.card_reference_id
	   into l_card_reference_id
           from ap_cards aca
	  where aca.card_id = i.card_id
	    and aca.card_reference_id is not null ;


       EXCEPTION
          WHEN NO_DATA_FOUND THEN
	    update ap_expense_feed_lines efl
	       set reject_code = 'INVALID CARD ID'
             where feed_line_id = i.feed_line_id ;
       END ;

      /* iby_fndcpt_setup_pub.card_exists(1.0,NULL,
           x_return_status, x_msg_count, x_msg_data,
           null ,trim(i.card_number), -- party id is null as we reference cards through ap_cards_all.employee_id
           p_card_instrument, x_response);

      if (x_return_status = 'S') then
           x_instr_id := p_card_instrument.card_id;

           if (x_instr_id is null) then
		  --------------------------------------------------------------------
		  l_debug_info := 'Reject Line if invalid card';
		  --------------------------------------------------------------------
		  update ap_expense_feed_lines efl
		  set    reject_code = 'INVALID CARD NUM'
		  where  feed_line_id=i.feed_line_id;
	   else
	     begin
	       select card_id into l_card from
   	       ap_cards where card_reference_id=x_instr_id and rownum=1;
               update ap_expense_feed_lines
	       set
	       card_id=l_card
	       where
               feed_line_id=i.feed_line_id;
	     exception
		when NO_DATA_FOUND then
		  --------------------------------------------------------------------
		  l_debug_info := 'Reject Line if invalid card';
		  --------------------------------------------------------------------
		  update ap_expense_feed_lines efl
		  set    reject_code = 'INVALID CARD NUM'
		  where  feed_line_id=i.feed_line_id;
	     end;
           end if;
        else -- Bug 5586412
                  --------------------------------------------------------------------
                  l_debug_info := 'Reject Line if invalid card';
                  --------------------------------------------------------------------
                  update ap_expense_feed_lines efl
                  set    reject_code = 'INVALID CARD NUM'
                  where  feed_line_id=i.feed_line_id;
      end if; */
      --8726861
    end loop;
    update ap_expense_feed_lines
    set
    card_number=-1
    where
    card_id is not null and reject_code='UNTESTED';

  --------------------------------------------------------------------
  l_debug_info := 'Update employee_id on line ';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    employee_id =
    (select c.employee_id
     from   ap_cards c
     where  c.card_id = efl.card_id)
  where  card_id is not null
  and    reject_code = 'UNTESTED';


  --------------------------------------------------------------------
  l_debug_info := 'Check for duplicate reference number.  ';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    reject_code = 'DUPLICATE REFERENCE'
  where  exists
    (select 'A corresponding line already exists with this reference number'
     from   ap_expense_feed_lines efl2
     where  efl.reference_number = efl2.reference_number
     and    efl.feed_line_id <> efl2.feed_line_id
     and    efl2.card_program_id = P_CARD_PROGRAM_ID)
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info := 'Check for invalid Posted Currency Code';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    reject_code = 'INVALID POST CURR'
  where  posted_currency_code is not null
  and    not exists
    (select 'A corresponding currency exists in FND_CURRENCIES'
     from   fnd_currencies_vl fndcvl
     where  fndcvl.enabled_flag = 'Y'
     and    fndcvl.currency_flag = 'Y'
     and    trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
     and    trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate)
     and    fndcvl.currency_code = efl.posted_currency_code)
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info :=
    'If a posted currency has not been specified, default from card program';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    posted_currency_code =
    (select cp.card_program_currency_code
     from   ap_card_programs cp
     where  cp.card_program_id = efl.card_program_id)
  where  posted_currency_code is null
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info := 'Check for invalid Transaction Currency Code';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    reject_code = 'INVALID TRX CURR'
  where  not exists
    (select 'A corresponding currency exists in FND_CURRENCIES'
     from   fnd_currencies_vl fndcvl
     where  fndcvl.enabled_flag = 'Y'
     and    fndcvl.currency_flag = 'Y'
     and    trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
     and    trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate)
     and    fndcvl.currency_code = efl.posted_currency_code)
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info := 'Check for invalid Card Code';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    reject_code = 'INVALID CARD CODE'
  where  not exists
    (select 'A corresponding card code exists in AP_CARD_CODES'
     from   ap_card_codes cc,
            ap_card_programs cp
     where  cc.code_value = efl.card_code_value
     and    cc.code_set_id = cp.card_code_set_id
     and    cp.card_program_id = P_CARD_PROGRAM_ID)
  and    nvl(create_distribution_flag,'N') = 'Y'
  and    exists
    (select 'Profile mandates building account from card code'
     from   ap_card_profiles cp,
            ap_cards c
     where  cp.profile_id = c.profile_id
     and    c.card_id = efl.card_id
     and    nvl(cp.build_acct_from_code_flag,'N') = 'Y')
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info := 'Check for Distribution Required';
  --------------------------------------------------------------------
  update ap_expense_feed_lines efl
  set    reject_code = 'DIST REQUIRED'
  where  exists
    (select 'Employee verification or manager approval required'
     from   ap_card_profiles cp,
            ap_cards c
     where  cp.profile_id = c.profile_id
     and    c.card_id = efl.card_id
     and    (cp.emp_notification_lookup_code = 'Y' OR
             cp.mgr_approval_lookup_code = 'Y'))
  and    nvl(create_distribution_flag,'N') <> 'Y'
  and    reject_code = 'UNTESTED';

  --------------------------------------------------------------------
  l_debug_info :=
     'Set REJECT_CODE to null for those lines which remain UNTESTED.';
  --------------------------------------------------------------------
  --
  -- These are valid lines
  --
  update ap_expense_feed_lines
  set    reject_code = ''
  where  card_program_id = P_CARD_PROGRAM_ID
  and    posted_date between nvl(P_START_DATE, posted_date - 1) and
                             nvl(P_END_DATE, posted_date + 1)
  and    reject_code = 'UNTESTED';

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'VALIDATE');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

---------------------------------------------------------------------------
--
-- Procedure CREATE_DISTRIBUTIONS
--
-- Creates records in AP_EXPENSE_FEED_DISTS where CDF=Y.
-- CCID determined by looking at the BAFCF.
--  o If BAFCF=Y then use overlay account defined by CODE_ID on
--    top of DEFAULT_ACCT_TEMPLATE.  Overlay resulting segments on
--    top of Employee Acct CCID (from HR_EMPLOYEES_CURRENT_V).
--  o If BAFCF=N overlay account segments defined in
--    DEFAULT_ACCT_TEMPLATE on top of Employee Acct CCID (from
--    HR_EMPLOYEES_CURRENT_V).
--  o If error results from operations above, use
--    AP_CARD_PROFILES.EXCEPTION_CLEARING_CCID.  If CCID not defined at
--    profile, use AP_CARD_PROGRAMS.EXCEPTION_CLEARING_CCID.
--  o If CCID still cannot be determined, populate REJECT_CODE to flag
--    as invalid account exception.
--
-- Where
--  o EVM denotes AP_CARD_PROFILES.EMP_NOTIFICATION_LOOKUP_CODE
--  o MAM denotes AP_CARD_PROFILES.MGR_APPROVAL_LOOKUP_CODE
--  o CDF denotes AP_EXPENSE_FEED_LINES.CREATE_DISTRIBUTION_FLAG
--  o BAFCF denotes AP_CARD_PROFILES.BUILD_ACCT_FROM_CODE_FLAG
--    (AP_CARD_PROFILES is parent of AP_CARDS).
--
---------------------------------------------------------------------------
PROCEDURE CREATE_DISTRIBUTIONS(
      P_CARD_PROGRAM_ID        IN NUMBER,
      P_START_DATE             IN DATE DEFAULT NULL,
      P_END_DATE               IN DATE DEFAULT NULL,
      P_RETURN_ERROR_MESSAGE   IN OUT NOCOPY VARCHAR2,
      P_REQUEST_ID  IN NUMBER) IS
  l_default_emp_ccid   HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE;
  l_default_emp_segments     FND_FLEX_EXT.SEGMENTARRAY;
  l_final_segments           FND_FLEX_EXT.SEGMENTARRAY;
  l_def_acct_template_array  FND_FLEX_EXT.SEGMENTARRAY;
  l_exp_line_acct_segs_array FND_FLEX_EXT.SEGMENTARRAY;
  l_exp_line_ccid            NUMBER;
  l_cant_flexbuild_reason    VARCHAR2(2000);
  l_cant_flexbuild_flag      BOOLEAN := FALSE;
  l_num_segments             NUMBER;
  l_flex_segment_number      NUMBER;
  l_cc_flex_segment_number   NUMBER;
  l_flex_segment_delimiter   VARCHAR2(1);
  l_employee_ccid            NUMBER(15);
  l_employee_id              NUMBER(15);
  INVALID_ACCT_EXCEPTION     EXCEPTION;
  l_chart_of_accounts_id     GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
  l_debug_info               VARCHAR2(100);
  l_feed_line_id             NUMBER;
  l_amount                   NUMBER;
  l_card_code_value          AP_EXPENSE_FEED_LINES.card_code_value%TYPE;
  l_exception_clearing_ccid  NUMBER;
  l_build_acct_from_code_flag AP_CARD_PROFILES.build_acct_from_code_flag%TYPE;
  l_default_acct_template    AP_CARD_PROFILES.default_acct_template%TYPE;
  l_distribution_status      AP_EXPENSE_FEED_DISTS.status_lookup_code%TYPE;
  l_cost_center              AP_EXPENSE_FEED_DISTS.cost_center%TYPE;
  l_account_segment_value    AP_EXPENSE_FEED_DISTS.account_segment_value%TYPE;
  l_card_code_set_id         NUMBER;
  l_org_id                   NUMBER;
  l_description              VARCHAR2(240);     -- Bug 977059

  --
  -- Cursor that loops through lines for which distributions should be created.
  --
  -- Legend to AP_CARD_PROFILES lookup codes
  --   emp_notification_lookup_code = Employee Verification Method
  --      Y = Verification Required
  --      I = Notification Only
  --      N = None
  --
  --   mgr_approval_lookup_code = Manager Approval Method
  --      Y = Approval Required
  --      I = Notification Only
  --      N = None
  --
  cursor lines_cursor is
    select efl.feed_line_id,
           efl.amount,
           efl.card_code_value,
           nvl(cpr.exception_clearing_ccid,cpg.exception_clearing_ccid),
           nvl(cpr.build_acct_from_code_flag,'N'),
           cpr.default_acct_template,
           hremp.default_code_combination_id,
           cpg.card_code_set_id,
           decode(cpr.mgr_approval_lookup_code,
                    'Y',decode(cpr.emp_notification_lookup_code,
                                 'Y','VALIDATED',
                                 'I','VALIDATED',
                                     'VERIFIED'),
                    'I',decode(cpr.emp_notification_lookup_code,
                                 'Y','VALIDATED',
                                 'I','VALIDATED',
                                     'VERIFIED'),
                        decode(cpr.emp_notification_lookup_code,
                                 'Y','VALIDATED',
                                 'I','VALIDATED',
                                     'APPROVED')),
           efl.description
    from   ap_expense_feed_lines efl,
           ap_card_programs cpg,
           ap_card_profiles cpr,
           ap_cards c,
           hr_employees_current_v hremp,
           IBY_FNDCPT_PAYER_ALL_INSTRS_V IBY
    where  efl.card_id = c.card_id
    and    c.card_reference_id=IBY.instrument_id
    and    c.profile_id = cpr.profile_id
    and    cpr.card_program_id = cpg.card_program_id
    and    efl.employee_id = hremp.employee_id
    and    efl.create_distribution_flag = 'Y'
    and    posted_date between nvl(P_START_DATE, posted_date - 1) and
                               nvl(P_END_DATE, posted_date + 1)
    and    reject_code is NULL
    AND    iby.instrument_type='CREDITCARD' -- veramach added for bug 7196074
    and    not exists
      (select 'A distribution exists for this expense feed line'
       from   ap_expense_feed_dists efd
       where  efd.feed_line_id = efl.feed_line_id)
    and    efl.card_program_id = P_CARD_PROGRAM_ID;

BEGIN
  ----------------------------------------
  l_debug_info := 'Get Chart of Accounts ID';
  ----------------------------------------
  select  GS.chart_of_accounts_id
  into    l_chart_of_accounts_id
  from    ap_system_parameters S,
          gl_sets_of_books GS
  where   GS.set_of_books_id = S.set_of_books_id;
  ----------------------------------------
  l_debug_info := 'Get Segment Delimiter';
  ----------------------------------------
  l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id);

  IF (l_flex_segment_delimiter IS NULL) THEN
    p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
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
    p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
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
    p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
    return;
  END IF;

  OPEN lines_cursor;

  LOOP

    FETCH lines_cursor INTO  l_feed_line_id,
                             l_amount,
                             l_card_code_value,
                             l_exception_clearing_ccid,
                             l_build_acct_from_code_flag,
                             l_default_acct_template,
                             l_default_emp_ccid,
                             l_card_code_set_id,
                             l_distribution_status,
                             l_description;

    EXIT WHEN lines_cursor%NOTFOUND;

    BEGIN

    -----------------------------------------------
    l_debug_info := 'Resolve the account from card code';
    -----------------------------------------------

    if (l_build_acct_from_code_flag='Y') then

      BEGIN
        select account_segment_value
        into   l_account_segment_value
        from   ap_card_codes
        where  code_set_id = l_card_code_set_id
        and    code_value = l_card_code_value;
      EXCEPTION
        when NO_DATA_FOUND then
          null;
      END;

    end if;

    -----------------------------------------------------------------
    l_debug_info := 'Get employee default ccid account segments';
    -----------------------------------------------------------------

    if (nvl(l_default_emp_ccid,-1) <> -1) then

      IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                  'SQLGL',
                                  'GL#',
                                  l_chart_of_accounts_id,
                                  l_default_emp_ccid,
                                  l_num_segments,
                                  l_default_emp_segments)) THEN

        p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
        raise INVALID_ACCT_EXCEPTION;
      END IF;

    else --9553865 added else clause
        p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
        raise INVALID_ACCT_EXCEPTION;

    end if;

   if (l_default_acct_template is not null) then

     l_num_segments := FND_FLEX_EXT.Breakup_Segments(l_default_acct_template,
                                                     l_flex_segment_delimiter,
                                                     l_def_acct_template_array);
    end if ;

    -- 9553865 added above if clause so that l_num_segments is not overriden



    FOR i IN 1..l_num_segments LOOP

      IF (l_default_acct_template IS NOT NULL AND  -- 9553865 added l_default_acct_template
          l_def_acct_template_array(i) IS NOT NULL) THEN

        l_exp_line_acct_segs_array(i) := l_def_acct_template_array(i);

      ELSE

        l_exp_line_acct_segs_array(i) :=l_default_emp_segments(i);

      END IF;


    END LOOP;

    ---------------------------------------------------
    l_debug_info := 'Overlay the account segment';
    ---------------------------------------------------

   if (l_build_acct_from_code_flag='Y'
        and l_account_segment_value is not null) then
      l_exp_line_acct_segs_array(l_flex_segment_number) :=
                                             l_account_segment_value;
    end if;

    --------------------------------------------------------------
    l_debug_info := 'Retrieve new ccid with overlaid account';
    --------------------------------------------------------------

    IF (NOT FND_FLEX_EXT.GET_COMBINATION_ID(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                SYSDATE,
                                l_num_segments,
                                l_exp_line_acct_segs_array,
                                l_exp_line_ccid)) THEN

      p_return_error_message := l_debug_info||': '||FND_MESSAGE.GET;
      raise INVALID_ACCT_EXCEPTION;
    END IF;

  EXCEPTION
    WHEN INVALID_ACCT_EXCEPTION THEN
      l_cant_flexbuild_flag := TRUE;

  END;

  if (l_cant_flexbuild_flag and
      nvl(l_exception_clearing_ccid,-1) = -1) then
    --
    -- Acct build resulted in an error and cannot use exception clearing CCID
    --
    --------------------------------------------------------------
    l_debug_info := 'Update the REJECT_CODE for INVALID ACCOUNT';
    --------------------------------------------------------------

    update ap_expense_feed_lines
    set    reject_code = 'INVALID ACCOUNT'
    where  feed_line_id = l_feed_line_id;
  else
    if (l_cant_flexbuild_flag) then
      --
      -- Acct build resulted in an error; use exception clearing CCID
      --
      l_exp_line_ccid := l_exception_clearing_ccid;
    end if;

    -----------------------------------------------------------------
    l_debug_info := 'Get final ccid account segments';
    -----------------------------------------------------------------

    IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                l_exp_line_ccid,
                                l_num_segments,
                                l_final_segments)) THEN

        p_return_error_message  := l_debug_info||': '||FND_MESSAGE.GET;
      return;
    END IF;

    --
    -- Extract account segment and cost center values from final flex
    --
    l_account_segment_value := l_final_segments(l_flex_segment_number);
    l_cost_center := l_final_segments(l_cc_flex_segment_number);

    --
    -- Insert record into AP_EXPENSE_FEED_DISTS
    --
    select org_id into l_org_id
    from
    ap_expense_feed_lines
    where
    feed_line_id=l_feed_line_id;
    Mo_Global.set_policy_context('S',l_org_id);
    insert into AP_EXPENSE_FEED_DISTS_ALL
      (FEED_LINE_ID,
       FEED_DISTRIBUTION_ID,
       AMOUNT,
       DIST_CODE_COMBINATION_ID,
       STATUS_CHANGE_DATE,
       STATUS_LOOKUP_CODE,
       ACCOUNT_SEGMENT_VALUE,
       ACCOUNT_SEGMENT_VALUE_DEFAULT,
       COST_CENTER,
       DESCRIPTION,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       CREATION_DATE,
       CREATED_BY,ORG_ID,
	CONC_REQUEST_ID) VALUES
      (l_feed_line_id,
       ap_expense_feed_dists_s.nextval,
       l_amount,
       l_exp_line_ccid,
       sysdate,
       l_distribution_status,
       l_account_segment_value,
       l_account_segment_value,
       l_cost_center,
       l_description,
       sysdate,
       -1,
       -1,
       sysdate,
       -1,l_org_id,P_REQUEST_ID);

  end if;

  l_cant_flexbuild_flag := FALSE;
  l_account_segment_value := '';
  l_cost_center := '';

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CREATE_DISTRIBUTIONS');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

---------------------------------------------------------------------------
--
-- Procedure CREATE_INTERFACE_RECORDS
--
-- Creates Invoice in new AP Interface table for Credit Card Transactions
--
-- Temporary stub that calls AP_CARD_INVOICE_PKG.CREATE_INVOICE
--
---------------------------------------------------------------------------
PROCEDURE CREATE_INTERFACE_RECORDS(
      P_CARD_PROGRAM_ID IN NUMBER,
      P_INVOICE_ID      IN OUT NOCOPY NUMBER,
      P_START_DATE      IN DATE DEFAULT NULL,
      P_END_DATE        IN DATE DEFAULT NULL,
      P_ROLLUP_FLAG     IN VARCHAR2 DEFAULT 'Y') IS

  l_debug_info                  VARCHAR2(100);
BEGIN
  --
  -- Call implementation AP_CARD_INVOICE_PKG.CREATE_INVOICE
  --
  AP_CARD_INVOICE_PKG.CREATE_INVOICE(
      P_CARD_PROGRAM_ID,
      P_INVOICE_ID,
      P_START_DATE,
      P_END_DATE,
      P_ROLLUP_FLAG);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'CREATE_INTERFACE_RECORDS');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;

END;

END AP_CARD_VALIDATE_PKG;

/
