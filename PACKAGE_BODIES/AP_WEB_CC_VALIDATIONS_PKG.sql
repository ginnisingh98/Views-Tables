--------------------------------------------------------
--  DDL for Package Body AP_WEB_CC_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CC_VALIDATIONS_PKG" as
/* $Header: apwccvlb.pls 120.16.12010000.9 2010/04/07 12:25:37 meesubra ship $ */

type t_gen_cur is ref cursor;

--
-- Globals
-- These will all get initialized in one of the "set" routines.
--
g_where_clause_type varchar2(30);
g_where_clause varchar2(1000);
g_trx_id number;
g_request_id number;
g_card_program_id number;
g_start_date date;
g_end_date date;
g_validate_code varchar2(25);

--
-- Package private functions/procedures
--
function set_row_set_internal return number;
-- procedure validate_internal;
function execute_update(p_stmt_str in varchar2, p_valid_only in boolean) return number;
procedure execute_select(c in out nocopy t_gen_cur,
                         p_stmt_str in out nocopy varchar2,
                         p_valid_only in boolean);


  ------------------------------------------------------------------------------
  --------------------------------- (1) ----------------------------------------
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Sets the context to all credit card transactions.
  -- (This should probably used sparingly since it really chooses everything
  --  - even across orgs)
function set_all_row_set return number is
begin
  g_where_clause_type := 'ALL';

  return set_row_set_internal;
end set_all_row_set;

  ------------------------------------------------------------------------------
  -- Sets the context to the following criteria
  -- (start/end dates are on the transaction date)
function set_row_set(p_request_id in number,
                     p_card_program_id in number,
                     p_start_date in date,
                     p_end_date in date) return number is
begin
  g_where_clause_type := 'CARD_PROGRAM_ID';
  g_request_id := p_request_id;
  g_card_program_id := p_card_program_id;
  g_start_date := p_start_date;
  g_end_date := p_end_date;

  if p_request_id is not null then
    g_where_clause := ' AND CC.REQUEST_ID = :reqId ';
  else
    g_where_clause := ' AND :reqId IS NULL ';
  end if;

  if p_card_program_id is not null then
    g_where_clause := g_where_clause || ' AND CC.CARD_PROGRAM_ID = :B_CARD_PROGRAM_ID ';
  else
    g_where_clause := g_where_clause || ' AND :B_CARD_PROGRAM_ID IS NULL ';
  end if;

  if p_start_date is not null and p_end_date is not null then
    g_where_clause := g_where_clause || ' AND (CC.TRANSACTION_DATE BETWEEN :B_START_DATE AND :B_END_DATE OR CC.TRANSACTION_DATE IS NULL) ';
  elsif p_start_date is not null then
    g_where_clause := g_where_clause || ' AND (CC.TRANSACTION_DATE >= :B_START_DATE OR CC.TRANSACTION_DATE IS NULL) ';
    g_where_clause := g_where_clause || ' AND :B_END_DATE IS NULL ';
  elsif p_end_date is not null then
    g_where_clause := g_where_clause || ' AND :B_START_DATE IS NULL ';
    g_where_clause := g_where_clause || ' AND (CC.TRANSACTION_DATE <= :B_END_DATE OR CC.TRANSACTION_DATE IS NULL) ';
  else
    g_where_clause := g_where_clause || ' AND :B_START_DATE IS NULL ';
    g_where_clause := g_where_clause || ' AND :B_END_DATE IS NULL ';
  end if;


  return set_row_set_internal;
end set_row_set;

  ------------------------------------------------------------------------------
  -- Sets the context to one specific transaction
function set_row_set(p_trx_id in number) return number is
begin
  g_where_clause_type := 'TRX_ID';
  g_trx_id := p_trx_id;

  if p_trx_id is not null then
    g_where_clause := ' AND CC.TRX_ID = :trxId ';
  else
    g_where_clause := ' AND :trxId IS NULL ';
  end if;

  return set_row_set_internal;
end set_row_set;

  ------------------------------------------------------------------------------
  --------------------------------- (2) ----------------------------------------
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Default org_id - based on card program
function default_org_id(p_valid_only in boolean) return number is
begin
  return execute_update( 'update ap_credit_card_trxns_all cc '||
                         'set org_id = (select org_id from ap_card_programs_all apcp where apcp.card_program_id = cc.card_program_id) '||
                         'where cc.org_id is null' , p_valid_only );
end default_org_id;

  -- Set request_id only if the request_id is null, we do not want to update the request_id that is
  -- populated during the creation or validation of cc transaction
function set_request_id(p_request_id in number) return number is
 l_valid_only boolean;
begin
  l_valid_only := true;
  return execute_update( 'update ap_credit_card_trxns_all cc '||
                         'set request_id = ' || to_char(p_request_id) ||
                         'where cc.request_id is null' , l_valid_only );
end set_request_id;

function set_validate_request_id(p_request_id in number) return number is
 l_valid_only boolean;
begin
  l_valid_only := true;
  return execute_update( 'update ap_credit_card_trxns_all cc '||
                         'set validate_request_id = ' || to_char(p_request_id) ||
                         'Where 1=1', l_valid_only );
end set_validate_request_id;

  ------------------------------------------------------------------------------
  -- Default folio type using folio type mapping rules
function default_folio_type(p_valid_only in boolean) return number
is
  c t_gen_cur;
  stmt varchar2(2000);

  l_validate_where varchar2(50) := null;
  l_stmt varchar2(2000);

  l_card_program_id number;
  l_map_type_code varchar2(30);
  l_column_name varchar2(30);

  l_count number := 0;
begin
  stmt := 'select distinct cp.card_program_id, cp.card_exp_type_map_type_code, cp.card_exp_type_source_col '||
          'from ap_credit_card_trxns_all cc, ap_card_programs_all cp '||
          'where cc.card_program_id = cp.card_program_id ';

  if p_valid_only then
    l_validate_where := ' AND CC.VALIDATE_CODE = ''UNTESTED''';
  end if;

  execute_select(c, stmt, p_valid_only);
  loop
    fetch c into l_card_program_id, l_map_type_code, l_column_name;
    exit when c%notfound;

    if l_map_type_code is not null and l_column_name is not null then
      l_stmt := 'update ap_credit_card_trxns_all cc '||
                'set folio_type =  ap_map_types_pkg.get_map_to_code(:r0, cc.'||l_column_name||') '||
                'where cc.card_program_id = :r1';

      if g_where_clause_type = 'ALL' then
        execute immediate l_stmt || l_validate_where using l_map_type_code, l_card_program_id;
      elsif g_where_clause_type = 'TRX_ID' then
        execute immediate l_stmt || g_where_clause || l_validate_where using l_map_type_code, l_card_program_id, g_trx_id;
      elsif g_where_clause_type = 'CARD_PROGRAM_ID' then
        execute immediate l_stmt || g_where_clause || l_validate_where using l_map_type_code, l_card_program_id, g_request_id, g_card_program_id, g_start_date, g_end_date;
      end if;

      l_count := l_count + SQL%ROWCOUNT;
    end if;
  end loop;
  close c;

  return l_count;
end default_folio_type;

  ------------------------------------------------------------------------------
  -- Default eLocation country code using elocation mapping rules
function default_country_code(p_valid_only in boolean) return number
is
  l_count number;
begin
  --
  -- If a null merchant country was passed in,
  -- default it based on various information of the card program.
  l_count := execute_update('update ap_credit_card_trxns_all cc '||
                            'set merchant_country = nvl(merchant_country, ap_web_locations_pkg.default_country(card_program_id)) '||
                            'where merchant_country is null ', p_valid_only);

  --
  -- Default merchant country code
  -- based on mapping rules
  l_count := execute_update( 'update ap_credit_card_trxns_all cc '||
                             'set merchant_country_code = ' ||
                               '(select ap_map_types_pkg.get_map_to_code(c.country_map_type_code, cc.merchant_country) '||
                               ' from ap_card_programs_all c '||
                               ' where c.card_program_id = cc.card_program_id) '||
                             'where 1=1', p_valid_only );

  return l_count;
end default_country_code;



  ------------------------------------------------------------------------------
  -- Assign payment flags (based on card specific info)
function default_payment_flag(p_valid_only in boolean) return number is
  num_rows number;
begin
 --------------------------------------------------------------------
  -- Set Payment Flag
  --
  -- To distinguish payment transactions from debit/credit transactions
  -- American Express (mis_industry_code = PA)
  -- Diner's Club (transaction_type = PAYMENTS)
  -- MasterCard (merchant_activity = A and transaction_amount < 0)
  -- Visa (transaction_type = 0108)-- MC?
  -- Bug 5976422  Description stores adjustment description and is specific for mastercard.
  --    In case other loader program start storing description, code needs to be modified.
  --------------------------------------------------------------------
  -- OPEN ISSUE:
  --   The following is straight out of APXCCVAL.rdf
  --   The criteria for MasterCard IS incorrect.
  --        1) transaction_amount may be zero while billed_amount is negative
  --        2) may include refunds - not just payments
  num_rows := execute_update(
  ' update ap_credit_card_trxns_all cc
    set    payment_flag = ''Y''
    where  (mis_industry_code = ''PA''
    or      transaction_type = ''PAYMENTS''
    or     (card_program_id in (select card_program_id from ap_card_programs_all where card_brand_lookup_code = ''MasterCard'') and
            upper(description)  like ''%PAYMENT%'' and
           (upper(description) not like ''%FEE%''
           and  upper(description) not like ''%REVERSAL%''
           and upper(description) not like ''%ADJUSTMENT%''
           and upper(description) not like ''%CREDIT%''
           and upper(description) not like ''%DEBIT%''))
    or     transaction_type in (''0108'',''0440'')) ', p_valid_only);

  return num_rows;
end default_payment_flag;


  ------------------------------------------------------------------------------
  -- Convert numeric currency codes into FND currency codes
function convert_currency_code(p_valid_only in boolean) return number is
  num_rows number;
begin
  num_rows := execute_update(
  'update ap_credit_card_trxns_all cc
  set    cc.billed_currency_code =
    (select currency_code
     from ap_card_currencies
     where numeric_currency_code = cc.billed_currency_code)
  where  cc.billed_currency_code is not null
  and    cc.billed_currency_code not in
    (select fndcvl.currency_code
     from   fnd_currencies_vl fndcvl
     where  fndcvl.enabled_flag = ''Y''
     and    fndcvl.currency_flag = ''Y''
     and    trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
     and    trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate))
  and exists
    (select currency_code
     from ap_card_currencies
     where numeric_currency_code = cc.billed_currency_code)', p_valid_only
  );


  --------------------------------------------------------------------
  -- Convert null billed currency codes
  --------------------------------------------------------------------
  num_rows := num_rows + execute_update(
  'update ap_credit_card_trxns_all cc
  set    cc.billed_currency_code =
    (select cp.card_program_currency_code
     from ap_card_programs_all cp
     where cp.card_program_id = cc.card_program_id)
  where billed_currency_code is null', p_valid_only
  );

  --------------------------------------------------------------------
  -- Convert posted currency codes
  --------------------------------------------------------------------
  num_rows := num_rows + execute_update(
  'update ap_credit_card_trxns_all cc
  set    cc.posted_currency_code =
    (select currency_code
     from ap_card_currencies
     where numeric_currency_code = cc.posted_currency_code)
  where  cc.posted_currency_code is not null
  and exists
    (select currency_code
     from ap_card_currencies
     where numeric_currency_code = cc.posted_currency_code)', p_valid_only
  );

  --------------------------------------------------------------------
  -- Convert null posted currency codes
  --------------------------------------------------------------------
  num_rows := num_rows + execute_update(
  'update ap_credit_card_trxns_all cc
  set    cc.posted_currency_code =
    (select cp.card_program_currency_code
     from ap_card_programs_all cp
     where cp.card_program_id = cc.card_program_id)
  where posted_currency_code is null', p_valid_only
  );

  return num_rows;
end convert_currency_code;


  ------------------------------------------------------------------------------
  -- eLocation integration
function get_locations(p_valid_only in boolean) return number is
  stmt varchar2(2000);

  l_loc_cur t_gen_cur;
  l_cc_trx ap_credit_card_trxns_all%rowtype;

  l_return_status varchar2(30);
  l_msg_count number;
  l_msg_data varchar2(2000);

  num_rows number := 0;
begin
  stmt := 'select *
     from ap_credit_card_trxns_all cc
     where location_id is null '||g_where_clause
     || ' for update of location_id nowait';
  execute_select(l_loc_cur, stmt, p_valid_only);
  loop
    fetch l_loc_cur into l_cc_trx;
    exit when l_loc_cur%notfound;

    num_rows := num_rows + 1;
    ap_web_locations_pkg.get_location(l_cc_trx, l_return_status, l_msg_count, l_msg_data);

    update ap_credit_card_trxns_all set location_id = l_cc_trx.location_id
    where trx_id = l_cc_trx.trx_id;
  end loop;
  close l_loc_cur;

  return num_rows;
end get_locations;

  ------------------------------------------------------------------------------
  -- Stamp CC Transactions with Payment Scenario of Card Program
function set_payment_scenario(p_valid_only in boolean) return number is
begin
  return execute_update(
  ' update ap_credit_card_trxns_all cc
    set payment_due_from_code = (select payment_due_from_code
                                 from ap_card_programs_all cp
                                 where cp.card_program_id = cc.card_program_id)
    where payment_due_from_code is null ', p_valid_only);
end set_payment_scenario;


  ------------------------------------------------------------------------------
  --------------------------------- (3) ----------------------------------------
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Check for duplication transactions (card program, card number, reference number)
function duplicate_trx(p_valid_only in boolean) return number is
begin
  --------------------------------------------------------------------
  -- Duplicate transaction
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''DUPLICATE_TRANSACTION''
  where  exists
    (select ''A corresponding transaction exists with this reference number''
     from   ap_credit_card_trxns_all cc2
     where  cc.reference_number = cc2.reference_number
     and    cc.trx_id <> cc2.trx_id
     and    cc.card_id = cc2.card_id
     and    cc.card_program_id = cc2.card_program_id)', p_valid_only
  );
end duplicate_trx;

  ------------------------------------------------------------------------------
  -- Check for non-zero, non-null billed amount
function invalid_billed_amount(p_valid_only in boolean) return number is
BEGIN
  --------------------------------------------------------------------
  -- Invalid billed amount
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_BILL_AMOUNT''
  where  (billed_amount is null
  or      billed_amount = 0)', p_valid_only
  );
end invalid_billed_amount;

  -- Check for valid billed currency code
function invalid_billed_currency_code(p_valid_only in boolean) return number is
begin
  --------------------------------------------------------------------
  -- Invalid billed currency code
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_BILL_CURR_CODE''
  where  billed_currency_code is not null
  and    not exists
    (select ''A corresponding currency exists in FND_CURRENCIES''
     from   fnd_currencies_vl fndcvl
     where  fndcvl.enabled_flag = ''Y''
     and    fndcvl.currency_flag = ''Y''
     and    trunc(nvl(fndcvl.start_date_active, sysdate)) <= trunc(sysdate)
     and    trunc(nvl(fndcvl.end_date_active, sysdate)) >= trunc(sysdate)
     and    fndcvl.currency_code = cc.billed_currency_code)', p_valid_only
  );
end invalid_billed_currency_code;

  ------------------------------------------------------------------------------
  -- Check for non-null billed date
function invalid_billed_date(p_valid_only in boolean) return number is
begin
  --------------------------------------------------------------------
  -- Invalid billed date
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_BILL_DATE''
  where  billed_date is null', p_valid_only
  );
end invalid_billed_date;


  ------------------------------------------------------------------------------
  -- Check for inactive card number
function inactive_card_number(p_valid_only in boolean) return number is
  num_rows number;
begin
  --------------------------------------------------------------------
  -- Inactive card number
  --------------------------------------------------------------------
  num_rows := execute_update(
  'update ap_credit_card_trxns_all cc
   set validate_code = ''INACTIVE_CARD_NUMBER''
   where cc.transaction_date >=
        (select max(nvl(apc.inactive_date,cc.transaction_date+1))
         from  ap_cards_all apc
         where apc.card_program_id = cc.card_program_id
         and   apc.card_id     = cc.card_id)', p_valid_only
  );
  return num_rows;
end inactive_card_number;

  ------------------------------------------------------------------------------
  -- Check for existing card number
function invalid_card_number(p_valid_only in boolean) return number is
  num_rows number;
begin
  --------------------------------------------------------------------
  -- Invalid card number
  --------------------------------------------------------------------
  num_rows := execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_CARD_NUMBER''
  where  card_id not in
        (select apc.card_id from ap_cards_all apc
         where apc.card_program_id = cc.card_program_id
         and   apc.card_id     = cc.card_id)', p_valid_only
  );
  return num_rows;
end invalid_card_number;

  ------------------------------------------------------------------------------
  -- Check for non-null merchant name
function invalid_merchant_name(p_valid_only in boolean) return number is
BEGIN
  --------------------------------------------------------------------
  -- Invalid merchant name
  --------------------------------------------------------------------
  --4730543 : skip validation for AME mis_industry_code 'SP' - Stop Payment
  --and Transaction Type '05'
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_MERCH_NAME''
  where  (merchant_name1 is null
  and     merchant_name2 is null)
  and    ( (transaction_type in (''11'',''20'',''22'',''80'')
            and    sic_code <> ''6012''
            and    (card_program_id in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code = ''Visa'')))
           or
           (merchant_activity <> ''A''
            and    (card_program_id in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code = ''MasterCard'')))
           or
           (mis_industry_code <> ''SP''
            and transaction_type <> ''05''
            and card_program_id in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code = ''American Express''))
           or
            card_program_id not in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code in (''American Express'',''Visa'',''MasterCard''))
                           )
', p_valid_only
  );
end invalid_merchant_name;


  ------------------------------------------------------------------------------
  -- Check for valid posted currency code
function invalid_posted_currency_code(p_valid_only in boolean) return number is
begin
  --------------------------------------------------------------------
  -- Invalid posted currency code
  --------------------------------------------------------------------
   return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_POST_CURR_CODE''
  where  posted_currency_code is not null
  and posted_currency_code not in (select currency_code from ap_card_currencies) ', p_valid_only
  );
end invalid_posted_currency_code;

  ------------------------------------------------------------------------------
  -- Check for non-zero, non-null transaction amount
function invalid_trx_amount(p_valid_only in boolean) return number is
BEGIN
  --------------------------------------------------------------------
  -- Invalid transaction amount
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_TRX_AMOUNT''
  where  (transaction_amount is null
  or      transaction_amount = 0)', p_valid_only
  );
end invalid_trx_amount;

  ------------------------------------------------------------------------------
  -- Check for non-null transaction date
function invalid_trx_date(p_valid_only in boolean) return number is
BEGIN
  --------------------------------------------------------------------
  -- Invalid transaction date
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_TRX_DATE''
  where  transaction_date is null
  and    ((mis_industry_code <> ''PA''
  and      card_program_id in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code = ''American Express''))
                           or
           card_program_id not in (select card_program_id
                           from ap_card_programs_all
                           where card_brand_lookup_code = ''American Express'')
                           )
  ', p_valid_only
  );
end invalid_trx_date;

  ------------------------------------------------------------------------------
  -- Marks the rows that are still valid as valid, and returns the number of
  -- rows that are still valid
function valid_trx return number is
begin
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''Y''
  where  validate_code = ''UNTESTED''', true);
end valid_trx;


  -- sic_code is required if transaction_type code is 10,11,20,22,80
  -- sic_code Must be equal to 6010, 6011, 6012, 6050 or 6051 if the
  -- transaction type code is 20,22,80
  -- The validation is required for Visa VCF 4.0 Format
function invalid_sic_code(p_valid_only in boolean) return number is
BEGIN
  --------------------------------------------------------------------
  -- Invalid mis_industry_code
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''INVALID_SIC_CODE''
  where  card_program_id in (select card_program_id
                             from ap_card_programs_all
                             where card_brand_lookup_code = ''Visa'')
  and    ((sic_code is null
           and  transaction_type in (''10'',''11'',''20'',''22'',''80''))
         or
          (transaction_type in (''20'',''22'',''80'')
          and sic_code not in (''6010'', ''6011'', ''6012'', ''6050'', ''6051''))
  )', p_valid_only
  );
end invalid_sic_code;
  ------------------------------------------------------------------------------
  --------------------------------- (4) ----------------------------------------
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Returns the lesser of date1 and date2. Null values are considered to
  -- be a date in the infinite future.
function get_min_date(date1 in date, date2 in date) return date is
begin
  if date1 is null and date2 is null then
    return null;
   elsif date1 is null then
    return date2;
   elsif date2 is null then
    return date1;
   elsif date1 < date2 then
    return date1;
   else
    return date2;
  end if;
end get_min_date;


  ------------------------------------------------------------------------------
  -- Assign the employee to the card and activate it.
procedure assign_employee(p_card_id in number, p_employee_id in number) is
  l_full_name VARCHAR2(80);
begin
  select full_name into l_full_name from ap_card_details where card_id = p_card_id;
  if (l_full_name is null) then
    select substrb(full_name, 1, 80) into l_full_name
    from per_employees_x pap, financials_system_parameters fsp
    where pap.business_group_id = fsp.business_group_id
    and pap.employee_id = p_employee_id;
  end if;

  assign_employee(p_card_id, p_employee_id, l_full_name);
  delete from ap_card_details where card_id = p_card_id;
  -- commented as this is a duplicate statement in code flow.
--  delete from ap_card_emp_candidates where card_id = p_card_id;
end;

--
-- This version should only be called by the web interface
-- This version does not delete the AP_CARD_DETAILS record
-- and assumes that the web version will take care of that.
-- (Kind of a workaround)
procedure assign_employee(p_card_id in number, p_employee_id in number, p_full_name in varchar2)
is

  x_return_status VARCHAR2(4000);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(4000);
  p_card_instrument APPS.IBY_FNDCPT_SETUP_PUB.CREDITCARD_REC_TYPE;
  l_instrid NUMBER;
  l_party_id NUMBER;
  x_response APPS.IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
  l_bool boolean := true;

begin
  update ap_cards_all
  set employee_id = p_employee_id,
      cardmember_name = null,
      physical_card_flag = 'Y',
      paper_statement_req_flag = 'N'
  where card_id = p_card_id
  and employee_id is null;-- bug 5224047

  -- 8799736 - PADSS- Setting card_member_name to IBY tables
  p_card_instrument.Card_Holder_Name := p_full_name;

  -- this part of code keeps iby in synch with party assignments for a card
  -- note that source of truth is oie (ap_cards_all.employee_id)
  -- and not iby for assignments check.
 begin
      select card_reference_id into l_instrid
      from ap_cards_all
      where card_id = p_card_id;
      p_card_instrument.card_id := l_instrid;
  exception when others then
     p_card_instrument.card_id := null;
     l_bool := false;
  end;
  if (l_bool) then
      begin
          select party_id into l_party_id
          from  per_people_f ppf
          where ppf.person_id = p_employee_id
          and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
          and rownum = 1;
          p_card_instrument.Owner_Id := l_party_id;
      exception when others then
         p_card_instrument.Owner_Id := null;
      end;
      iby_fndcpt_setup_pub.update_card(1.0,NULL,'F',x_return_status,x_msg_count,x_msg_data,
                         p_card_instrument, x_response);
   end if;

  delete from ap_card_emp_candidates where card_id = p_card_id;
end assign_employee;


  ------------------------------------------------------------------------------
  ------------------------------ (PRIVATE) -------------------------------------
  ------------------------------------------------------------------------------

------------------------------------------------------------------------------
--
-- Update VALIDATE_CODE columns to UNTESTED for the selected rows.
function set_row_set_internal
return number is
  num_rows number;
begin
  return execute_update( 'update ap_credit_card_trxns_all cc '||
                         'set validate_code = ''UNTESTED'' '||
                         'where validate_code <> ''Y'' ' ||
                         'and nvl(category,''BUSINESS'')  <> ''DEACTIVATED'' ', false );
end set_row_set_internal;

------------------------------------------------------------------------------
--
-- Execute an update statement on the set of transactions
-- (Builds SQL statement dynamically)
function execute_update(p_stmt_str in varchar2, p_valid_only in boolean) return number is
  l_validate_where varchar2(50) := null;
begin

  if p_valid_only then
    l_validate_where := ' AND CC.VALIDATE_CODE = ''UNTESTED''';
  end if;

  if g_where_clause_type = 'ALL' then
      execute immediate p_stmt_str || l_validate_where;
  elsif g_where_clause_type = 'TRX_ID' then
      execute immediate p_stmt_str || g_where_clause || l_validate_where using g_trx_id;
  elsif g_where_clause_type = 'CARD_PROGRAM_ID' then
      execute immediate p_stmt_str || g_where_clause || l_validate_where
        using g_request_id, g_card_program_id, g_start_date, g_end_date;
  end if;

  return SQL%ROWCOUNT;

exception
  when others then
    declare
      module varchar2(50) := 'ap.oie_cc_validations_pkg.execute_update';
    begin
      if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, module, sqlerrm);
      end if;
      if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, module, 'stmt  = '||p_stmt_str);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, module, 'where = '||g_where_clause);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, module, 'valid = '||l_validate_where);
      end if;
    end;
    raise;
end execute_update;

------------------------------------------------------------------------------
--
-- Execute a select statement on the set of transactions
-- (Builds SQL statement dynamically)
procedure execute_select(c in out nocopy t_gen_cur,
                         p_stmt_str in out nocopy varchar2,
                         p_valid_only in boolean) is
  l_validate_where varchar2(50) := null;
begin

  if p_valid_only is not null then
    l_validate_where := ' AND CC.VALIDATE_CODE = ''UNTESTED''';
  end if;

  if g_where_clause_type = 'ALL' then
    open c for p_stmt_str || l_validate_where;
  elsif g_where_clause_type = 'TRX_ID' then
    open c for p_stmt_str || g_where_clause || l_validate_where using g_trx_id;
  elsif g_where_clause_type = 'CARD_PROGRAM_ID' then
    open c for p_stmt_str || g_where_clause || l_validate_where using g_request_id, g_card_program_id, g_start_date, g_end_date;
  end if;
end execute_select;

------------------------------------------------------------------------------
--
-- check_employee_termination
-- Author: Kristian Widjaja
-- Purpose: To set transaction category to personal of those transactions
--          that belong to terminated employees' credit cards and
--          have a transaction date greater than the employee's termination date.
-- Bug 3243527: Inactive Employees and Contingent Workers project
--
-- Input: p_valid_only - update valid transactions only or not
--
-- Output: the number of updated lines.
--

function check_employee_termination(p_valid_only in boolean) return number is
BEGIN
  return execute_update(
  -- Bug 3313557: Replaced TRXN alias with CC, so that it is compatible
  --              with the rest of the dynamic SQL.
     'UPDATE AP_CREDIT_CARD_TRXNS_ALL CC
      SET CATEGORY = ''PERSONAL''
      WHERE CATEGORY <> ''PERSONAL''
        AND EXISTS (SELECT 1
                    FROM AP_CARDS_ALL CARD,
                         PER_EMPLOYEES_X P
                    WHERE AP_WEB_DB_HR_INT_PKG.IsPersonTerminated(CARD.employee_id)=''Y''
                    AND CARD.employee_id=P.employee_id
                    AND P.inactive_date < CC.transaction_date
                    AND CARD.card_program_id=CC.card_program_id
                    AND CARD.card_id=CC.card_id)', p_valid_only --
  );
END check_employee_termination;

function validate_trx_detail_amount return number is
begin
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set trxn_detail_flag = NULL
  where trxn_detail_flag = ''Y''
  and abs(transaction_amount) <
          (select abs(sum(transaction_amount))
           from ap_cc_trx_details c
           where c.trx_id = cc.trx_id)', true);
end validate_trx_detail_amount;

  ------------------------------------------------------------------------------
  --------------------------------- (2) ----------------------------------------
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Default merchant name for AMEX for trxn types 01,02,03,06,09,10,11,12
  -- based on card program
  -- Bug 5516466 / 5526525  Also for Transaction Type 08
  -- Bug 6743651 For adjustment transactions for MasterCard

function default_merchant_name(p_valid_only in boolean) return number is
begin
  return execute_update( 'update ap_credit_card_trxns_all cc ' ||
                         'set merchant_name1 = (' ||
                                  'select card_program_name ' ||
                                    'from ap_card_programs_all apcp ' ||
                                   'where apcp.card_program_id = cc.card_program_id and rownum = 1) ' ||
                         'where merchant_name1 is null ' ||
                         'and   merchant_name2 is null ' ||
                         'and  ( '||
                                '(transaction_type in (''01'',''02'',''03'',''06'',''08'',''09'',''10'',''11'',''12'') '||
                                'and (card_program_id in (select card_program_id '||
                                        'from ap_card_programs_all where card_brand_lookup_code = ''American Express''))) '||
                                'or '||
                                '(merchant_activity = ''A'' '||
                                 'and (card_program_id in (select card_program_id '||
                                        'from ap_card_programs_all where card_brand_lookup_code = ''MasterCard'')))'||
                              ') ',
                              p_valid_only );
end default_merchant_name;


-- delete invalid records.
function delete_invalid_rows(p_valid_only in boolean, card_program_id in number ) return number is
       num_rows number;
       card_prog_where varchar2(80) := '';
begin

  -- Bug 6616092
  IF card_program_id is not null THEN
   card_prog_where := ' and cc.card_program_id = ' || card_program_id ;
  END IF;


  --------------------------------------------------------------------
  -- Delete invalid records
  --------------------------------------------------------------------
 IF(IBY_FNDCPT_SETUP_PUB.Get_Encryption_Patch_Level = 'PADSS') THEN
 num_rows := execute_update('delete ap_credit_card_trxns_all cc where card_id in
      (select card_id
        from ap_cards_all apc, iby_creditcard icc
        where apc.card_program_id = cc.card_program_id and
         apc.card_id = cc.card_id and
         icc.instrid = apc.card_reference_id and
         icc.invalid_flag = ''Y'')
         and cc.card_number is null
         and cc.validate_code != ''Y''' || card_prog_where, p_valid_only);
 ELSE
 num_rows := execute_update('delete ap_credit_card_trxns_all cc where card_id not in
      (select card_id
        from ap_cards_all apc
        where apc.card_program_id = cc.card_program_id and
         apc.card_id     = cc.card_id)
         and cc.card_number is null
         and cc.validate_code != ''Y''' || card_prog_where, p_valid_only);
 END IF;
  return num_rows;
end delete_invalid_rows;

-- Check for duplication transactions (reference number)
function duplicate_global_trx(p_valid_only in boolean) return number is
begin
  --------------------------------------------------------------------
  -- Duplicate transaction
  --------------------------------------------------------------------
  return execute_update(
  'update ap_credit_card_trxns_all cc
  set    validate_code = ''DUPLICATE_TRANSACTION''
  where
    cc.card_program_id in
     (select acp.card_program_id from ap_card_programs_all acp where gl_program_name =
     (select gl_program_name from ap_card_programs_all where card_program_id = cc.card_program_id))
    and exists
     (select ''A corresponding transaction exists with this reference number''
     from   ap_credit_card_trxns_all cc2
     where  cc.reference_number = cc2.reference_number
     and    cc.trx_id <> cc2.trx_id)', p_valid_only
  );
end duplicate_global_trx;

function default_detail_folio_type(p_valid_only in boolean) return number
is
  c t_gen_cur;
  stmt varchar2(2000);

  l_validate_where varchar2(50) := null;
  l_stmt varchar2(2000);

  l_card_program_id number;
  l_map_type_code varchar2(30);

  l_count number := 0;
begin
  stmt := 'select distinct cp.card_program_id, cp.card_exp_type_detail_map_code '||
          'from ap_credit_card_trxns_all cc, ap_card_programs_all cp '||
          'where cc.card_program_id = cp.card_program_id ';

  if p_valid_only then
    l_validate_where := ' AND CC.VALIDATE_CODE = ''UNTESTED''';
  end if;

  execute_select(c, stmt, p_valid_only);
  loop
    fetch c into l_card_program_id, l_map_type_code;
    exit when c%notfound;

    if l_map_type_code is not null then
      l_stmt := 'update ap_cc_trx_details ac '||
                'set folio_type =  ap_map_types_pkg.get_map_to_code(:r0, ac.ext_folio_type) '||
                'where trx_id in (select trx_id from ap_credit_card_trxns_all cc where cc.card_program_id = :r1';

      if g_where_clause_type = 'ALL' THEN
        l_stmt := l_stmt || l_validate_where || ')';
        execute immediate l_stmt using l_map_type_code, l_card_program_id;
      elsif g_where_clause_type = 'TRX_ID' THEN
        l_stmt := l_stmt || g_where_clause || l_validate_where || ')';
        execute immediate l_stmt using l_map_type_code, l_card_program_id, g_trx_id;
      elsif g_where_clause_type = 'CARD_PROGRAM_ID' THEN
        l_stmt := l_stmt || g_where_clause || l_validate_where || ')';
        execute immediate l_stmt using l_map_type_code, l_card_program_id, g_request_id, g_card_program_id, g_start_date, g_end_date;
      end if;

      l_count := l_count + SQL%ROWCOUNT;
    end if;
  end loop;
  close c;

  return l_count;
end default_detail_folio_type;



end ap_web_cc_validations_pkg;

/
