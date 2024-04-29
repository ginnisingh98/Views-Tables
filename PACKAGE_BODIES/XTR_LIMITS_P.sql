--------------------------------------------------------
--  DDL for Package Body XTR_LIMITS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_LIMITS_P" as
/* $Header: xtrlmtsb.pls 120.6.12010000.2 2008/08/06 10:43:30 srsampat ship $ */
--
-- Global Variables/Exceptions
--
ex_no_limit_exists       exception;
ex_auth_not_y            exception;
--
------------------------------------------------------------------------------------------------------------------------------------
FUNCTION WEIGHTED_USAGE(p_deal_type    VARCHAR2,
                        p_deal_subtype VARCHAR2,
                        p_amount_date  DATE,
                        p_hce_amount   NUMBER)
RETURN NUMBER is
  --
  -- Calculate amount utilised for this limit code, by this deal type/subtype and date combination.
  --
  cursor c_get_weighting (pc_deal_type    VARCHAR2,
                          pc_deal_subtype VARCHAR2,
                          pc_amount_date  date) is
   select nvl(c.LIMIT_WEIGHTING / 100,1)
    from XTR_FX_PERIOD_WEIGHTINGS c
    where c.DEAL_TYPE = pc_deal_type
    and c.DEAL_SUBTYPE = pc_deal_subtype
    and c.NOS_MONTHS =
            (select max(d.NOS_MONTHS)
              from XTR_FX_PERIOD_WEIGHTINGS d
              where d.DEAL_TYPE = c.DEAL_TYPE
              and d.DEAL_SUBTYPE = c.DEAL_SUBTYPE
              and d.NOS_MONTHS <= decode(sign(months_between(trunc(pc_amount_date),trunc(sysdate)))
                                    ,-1,0
                                    ,months_between(trunc(pc_amount_date),trunc(sysdate))));
--
  v_weight NUMBER;
--
begin
 open c_get_weighting (p_deal_type,p_deal_subtype,p_amount_date);
  fetch c_get_weighting into v_weight;
 if c_get_weighting%NOTFOUND then
  -- Default to 100%
  v_weight := 1;
 end if;
 close c_get_weighting;
 --
 return(nvl(round(nvl(p_hce_amount,0) * v_weight,0),0));
end;
------------------------------------------------------------------------------------------------------------------------------------
FUNCTION CONVERT_TO_HCE_AMOUNT(p_amount_to_convert NUMBER,
                               p_currency          VARCHAR2,
                               p_company_code      VARCHAR2)
RETURN NUMBER is
--
-- Calculate home-currency-equivalent for p_amount_to_convert
-- (the home country will that stored for p_company_code in PARTIES).
--
  --
  cursor HC_RATE (pc2_amount number, pc2_currency VARCHAR2) is
   select round((pc2_amount / nvl(s.HCE_RATE ,1)),nvl(s.ROUNDING_FACTOR,2))
    from XTR_MASTER_CURRENCIES_V s
    where s.currency = pc2_currency;
  --
  v_home_currency    VARCHAR2(15);
  v_hce_utilised_amt NUMBER;
--
begin
   open hc_rate( p_amount_to_convert,p_currency);
    fetch hc_rate into v_hce_utilised_amt;
   close hc_rate;
  return(v_hce_utilised_amt);
end;
------------------------------------------------------------------------------------------------------------------------------------
FUNCTION GET_HCE_AMOUNT(p_amount_to_convert NUMBER,
                        p_currency          VARCHAR2)
RETURN NUMBER is
--
-- Calculate home-currency-equivalent for p_amount_to_convert
--
  cursor HC_RATE (pc2_amount number, pc2_currency VARCHAR2) is
   select round((pc2_amount / nvl(s.HCE_RATE ,1)),nvl(s.ROUNDING_FACTOR,2))
    from XTR_MASTER_CURRENCIES_V s
    where s.currency = pc2_currency;
--
  v_hce_utilised_amt       NUMBER;
--
begin
 open hc_rate( p_amount_to_convert,p_currency);
  fetch hc_rate into v_hce_utilised_amt;
 close hc_rate;
 return( v_hce_utilised_amt );
end;
------------------------------------------------------------------------------------------------------------------------------------
--
-- Returns the number of limit checks that have been logged
-- If the system parameter, 'DISPLAY_LIMIT_WARNING' is set to 'N', then
--   it will return 0 even if logs have been made.
--
FUNCTION LOG_FULL_LIMITS_CHECK (
                         p_DEAL_NUMBER        NUMBER,
                         p_TRANSACTION_NUMBER NUMBER,
                         p_COMPANY_CODE       VARCHAR2,
                         p_DEAL_TYPE          VARCHAR2,
                         p_DEAL_SUBTYPE       VARCHAR2,
                         p_CPARTY_CODE        VARCHAR2,
                         p_PRODUCT_TYPE       VARCHAR2,
                         p_LIMIT_CODE         VARCHAR2,
                         p_LIMIT_PARTY        VARCHAR2,
                         p_AMOUNT_DATE        DATE,
                         p_AMOUNT             NUMBER,
                         p_DEALER_CODE        VARCHAR2,
                         p_CURRENCY           VARCHAR2,
                         p_CURRENCY_SECOND    VARCHAR2) return number is
  -- Second currency and amount added for Limit check in FX deals. bug 1289530
  --
  -- Do ALL the "limits" checks and log any errors to the log table.
  --
  cursor c_get_country_group (pc_party_code VARCHAR2) is
   select upper(country_code),upper(nvl(cross_ref_to_other_party,pc_party_code))
    from XTR_PARTY_INFO
    where party_code = pc_party_code;
  --
  cursor c_get_limit_type (pc_limit_code VARCHAR2,pc_comp_code VARCHAR2) is
   select upper(limit_type)
    from XTR_COMPANY_LIMITS
    where limit_code = pc_limit_code
    and company_code = pc_comp_code;
  --
  cursor get_home_ccy is
    select param_value
     from XTR_PRO_PARAM
     where param_name = 'SYSTEM_FUNCTIONAL_CCY';
  --
  -- Old utilised will only be picked up if all the variables have remained the same
  -- ie only amount has been altered
  cursor get_old_utilised (pc_deal_number NUMBER) is
   select sum(nvl(hce_utilised_amount,0))
    from XTR_MIRROR_DDA_LIMIT_ROW
    where deal_number = pc_deal_number
    and limit_code = p_limit_code
    and limit_party = p_cparty_code
    and currency = p_currency
    and company_code = p_company_code;
  --
  --  bug 1687715 new cursor for ONC deals
  cursor get_old_utilised_onc (pc_deal_number NUMBER, pc_trans_number NUMBER) is
   select sum(nvl(hce_utilised_amount,0))
    from XTR_MIRROR_DDA_LIMIT_ROW
    where deal_number = pc_deal_number
    and transaction_number = pc_trans_number
    and limit_code = p_limit_code
    and limit_party = p_cparty_code
    and currency = p_currency
    and company_code = p_company_code;
  --  end bug 1687715
  --
  cursor c_get_seq is
   select XTR_LIMITS_EXCESS_LOG_S.nextval
    from  DUAL;
  --
  cursor c_ok_limit_chk (pc3_param_name VARCHAR2) is
    select param_value
    from  XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  cursor c_date_restr is
   select range
    from XTR_TIME_RESTRICTIONS
    where deal_type = p_deal_type
    and (cparty_code like p_cparty_code or cparty_code is null)
    and (deal_subtype like p_deal_subtype or deal_subtype is null)
    and (security_name like p_product_type or security_name is null)
    order by cparty_code,security_name,deal_subtype;
  --
  CURSOR c_limit_control IS
   SELECT substr(param_name,13) limit_check
   FROM xtr_pro_param_v
   WHERE param_name in ('LIMIT_CHECK_CPARTY','LIMIT_CHECK_GROUP','LIMIT_CHECK_SOVRN')
   AND nvl(param_value,'N') = 'Y';
--
  v_limit_check_type       VARCHAR2(8);

  v_limit_type             VARCHAR2(2);
  v_home_ccy               VARCHAR2(15);
  v_company_code           VARCHAR2(7);
  v_limit_amt              NUMBER;
  v_util_amt               NUMBER;
  v_err_code               VARCHAR2(8);
  v_country_code           XTR_PARTY_INFO.country_code%TYPE;
  v_group_party            VARCHAR2(7);
  v_time_limit             NUMBER;
  --
  v_hce_amount             NUMBER;
  v_new_hce_util           NUMBER;
  --
  v_logged_yn              BOOLEAN := FALSE;
  v_unique_num             NUMBER;
  v_time_chk_reqd          VARCHAR2(1);
  v_settle_warn            VARCHAR2(8);
  v_old_utilised           NUMBER := 0;
  v_gross_amt              NUMBER := 0;
  v_dummy                  NUMBER := 0;
--
begin
 IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
  xtr_debug_pkg.debug('Before LOG_FULL_LIMITS_CHK on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
 END IF;
 -- Get a unique ID
 open  c_get_seq;
  fetch c_get_seq into v_unique_num;
 close c_get_seq;
 --
 if substr(p_company_code,1,1) = '@' then
  -- indicates that limit check is being called from 0007 (comp is passed in with
  -- @ preceeding(saves adding another parameter), therefore settle limit check should
  -- be for actual settlements not those that may be settled
  v_company_code := substr(p_company_code,2);
  v_settle_warn := 'EXCEEDED';
  -- note we will only check for actual settlement limit when calling from this form
 else
  v_company_code := p_company_code;
  v_settle_warn := 'WARNING';
 end if;
 --

/* Move to concurrent processing
 -- Check limits have been refreshed for today
 CALC_ALL_MIRROR_DDA_LIMIT_ROW('N');
*/
 --
 -- Compute usage for this new (as yet uncommitted) record,
 -- first calculate home-currency-equivalent for p_amount...
 v_hce_amount := xtr_limits_p.CONVERT_TO_HCE_AMOUNT(abs(p_amount),
                                                   p_CURRENCY,
                                                   v_company_code);
 --
 v_new_hce_util := xtr_limits_p.WEIGHTED_USAGE(p_deal_type,p_deal_subtype,
                                              p_amount_date,v_hce_amount);
 --
 --bug 1687715 ONC deals has deal number while insert the check should be done for trans no
 if p_deal_number is NOT NULL and p_deal_type <> 'ONC' then
  -- this is being called from an update of a deal therefore we need to
  -- take out the old utilised (offset) against the new utilised
  open get_old_utilised(p_deal_number);
   fetch get_old_utilised into v_old_utilised;
  close get_old_utilised;
 elsif p_transaction_number is NOT NULL and p_deal_type = 'ONC' then
  -- this is being called from an update of a deal therefore we need to
  -- take out the old utilised (offset) against the new utilised
  open get_old_utilised_onc(p_deal_number, p_transaction_number);
   fetch get_old_utilised_onc into v_old_utilised;
  close get_old_utilised_onc;
 -- end bug 1687715
 else
  v_old_utilised := 0;
 end if;
 -- Substract old utilised from new utilised so we don't double up
 v_new_hce_util := nvl(v_new_hce_util,0) - nvl(v_old_utilised,0);
 v_gross_amt := v_hce_amount;
 --
 --
 if v_new_hce_util > 0 then
  open c_get_country_group(p_limit_party);
   fetch c_get_country_group into v_country_code,v_group_party;
  if c_get_country_group%NOTFOUND then
   v_country_code := null;
   v_group_party  := p_limit_party;
  end if;
  close c_get_country_group;


  ---
  -- ** Check if limit code is required (Refer to bug 917778)
  --
--  if p_limit_code is NULL then  /* RV BUG # 1605612 */


    if (p_limit_code is NULL) AND (v_settle_warn = 'WARNING')then
    open c_limit_control;
    loop
    fetch c_limit_control into v_limit_check_type;
     exit when c_limit_control%NOTFOUND;
      v_err_code :='NO_LIMIT';
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,nvl(v_hce_amount,0),NULL,
       NULL, NULL, p_dealer_code,
       v_limit_check_type,v_err_code,sysdate);
      v_logged_yn := TRUE;
   end loop;
   close c_limit_control;
  end if;


  -- *** NOW DO EACH LIMIT CHECK ***
  --
  -- ********** 1. check global limits
  --
  if v_company_code is NOT null and p_limit_code is NOT null and v_settle_warn = 'WARNING'
   then
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('Before Get_lim_global on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
    XTR_LIMITS_P.GET_LIM_GLOBAL (p_DEAL_NUMBER,v_company_code,p_limit_code,
                                v_limit_amt,v_util_amt,v_err_code);
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After Get_lim_global on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
    if v_err_code is null then
      v_util_amt := v_util_amt + v_new_hce_util;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'GLOBAL','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'GLOBAL',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
  end if;
  --
  -- ********** 2. check sovereign limits
  --
  --
  if v_company_code is NOT null and v_country_code is NOT null and v_settle_warn = 'WARNING'
   then
   XTR_LIMITS_P.GET_LIM_SOVEREIGN(p_DEAL_NUMBER,v_company_code,upper(v_country_code),
                                 v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_new_hce_util;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'SOVRN','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'SOVRN',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('After sovereign limits on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
   END IF;
  end if;
  --
  -- ********** 3. check dealer-deal limits
  --
  if p_dealer_code is NOT null and p_deal_type is NOT null and p_product_type is NOT null
   and v_settle_warn = 'WARNING' then
    XTR_LIMITS_P.GET_LIM_DEALER_DEAL ( p_DEAL_NUMBER,p_dealer_code,p_deal_type,p_product_type,
                                      v_limit_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_hce_amount;
      if v_gross_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_gross_amt,v_limit_amt,
           v_gross_amt - v_limit_amt, NULL, p_dealer_code,
           'DLR_DEAL','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    elsif v_err_code = 'NO_LIMIT' then
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_gross_amt,NULL,
       NULL, NULL, p_dealer_code,
       'DLR_DEAL',v_err_code,sysdate);
      v_logged_yn := TRUE;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_gross_amt,v_limit_amt,
       v_gross_amt - v_limit_amt, NULL, p_dealer_code,
       'DLR_DEAL',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After dealer_deal limits on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  --
  -- ********** 4. check cparty limits
  --
  if v_company_code is NOT null and p_cparty_code is NOT null and p_limit_code is NOT null
   and v_settle_warn = 'WARNING' then
    XTR_LIMITS_P.GET_LIM_CPARTY( p_DEAL_NUMBER,v_company_code,p_cparty_code,p_limit_code,
                                v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_new_hce_util;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'CPARTY','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'CPARTY',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After cparty limits on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  --
  -- ********** 5. check settle limits
  --
  -- bug 2428516
  v_dummy:=0;
  if (p_amount<0) then --payment
    SELECT COUNT(*)
    INTO v_dummy
    FROM XTR_PRO_PARAM
    WHERE PARAM_NAME='LIMIT_INCLUDE_PAYMENTS'
    AND PARAM_VALUE='N';
  end if;
  if v_company_code is NOT null and p_limit_party is NOT null and p_amount_date is NOT null and v_dummy=0 then
  -- end bug 2428516
    if v_settle_warn = 'WARNING' then
     -- call normal settlement check - ie reflects excess if all settlements occur on amount date (warning only)
     XTR_LIMITS_P.GET_LIM_SETTLE( p_DEAL_NUMBER,v_company_code,p_limit_party,p_amount_date,
                                 v_limit_amt,v_util_amt,v_err_code);
    else
     -- excess only for authorised settlements - ie actual excess as settlements are authorised in pro0007
     -- ie this is an actal excess as the settlements have been authorised
     XTR_LIMITS_P.GET_ACTUAL_SETTLE_EXCESS( p_DEAL_NUMBER,v_company_code,p_limit_party,p_amount_date,
                                           v_limit_amt,v_util_amt,v_err_code);
    end if;
    if v_err_code is null then
      v_util_amt := v_util_amt + v_hce_amount;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'SETTLE',v_settle_warn,sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'SETTLE',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After settle limits on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  --
  -- ********** 6.1. Check Currency Limits for first currency
  --
/*  open get_home_ccy;
   fetch get_home_ccy into v_home_ccy;
  close get_home_ccy;  */
  --
  -- bug 1289530 currency limit check should be done for home ccy
  --  if p_currency is NOT null and p_currency <> v_home_ccy and v_settle_warn = 'WARNING' then
  if p_currency is NOT null and v_settle_warn = 'WARNING' then
    -- end bug 1289530
    -- Only check currency limits for non domestic currencies
    XTR_LIMITS_P.GET_LIM_CCY(p_DEAL_NUMBER,p_currency,v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_hce_amount;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE, CURRENCY)  -- bug 1289530
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'CCY','EXCEEDED',sysdate, p_currency);  -- bug 1289530
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE, CURRENCY)  -- bug 1289530
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'CCY',v_err_code,sysdate, p_currency);  -- bug 1289530
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After currency limits for first ccy on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  --
  -- bug 1289530 currency limit check for second currency
  -- ********** 6.2. Check Currency Limits for second currency
  --
  if p_currency_second is NOT null and v_settle_warn = 'WARNING' then
    XTR_LIMITS_P.GET_LIM_CCY(p_DEAL_NUMBER,p_currency_second,v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_hce_amount;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE, CURRENCY)  -- bug 1289530
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'CCY','EXCEEDED',sysdate, p_currency_second);  -- bug 1289530
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE, CURRENCY)  -- bug 1289530
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'CCY',v_err_code,sysdate, p_currency_second);  -- bug 1289530
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After currency limits for second ccy on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  -- end bug 1289530
  --
  -- ********** 7. check group limits
  --
  if v_company_code is NOT null and v_group_party is NOT null and p_limit_code is NOT null
   and v_settle_warn = 'WARNING' then
    open c_get_limit_type(p_limit_code,v_company_code);
     fetch c_get_limit_type into v_limit_type;
    close c_get_limit_type;
    --
    XTR_LIMITS_P.GET_LIM_GROUP(p_DEAL_NUMBER,v_company_code,v_limit_type,v_group_party,
                              v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_new_hce_util;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           v_group_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'GROUP','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       v_group_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'GROUP',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('After group limits on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
  end if;
  --
  -- ********** 8. Time Restrictions
  --
  open c_ok_limit_chk('LIMIT_CHECK_TIME');
   fetch c_ok_limit_chk into v_time_chk_reqd;
  if c_ok_limit_chk%NOTFOUND then
   v_time_chk_reqd := 'Y';
  end if;
  close c_ok_limit_chk;
  --
  if nvl(v_time_chk_reqd,'Y') = 'Y' and v_settle_warn = 'WARNING' then
   -- bug 1207970 time limit does not depend on counterparty
   -- if p_deal_type is NOT null and p_cparty_code is NOT null and p_amount_date is NOT null then
   if p_deal_type is NOT null and p_amount_date is NOT null then
   -- end bug 1207970
    open c_date_restr;
     fetch c_date_restr into v_time_limit;
    if c_date_restr%FOUND then
      if (trunc(p_amount_date) - trunc(sysdate)) > v_time_limit then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code,null,p_cparty_code,p_amount_date,0,null,
           ((trunc(p_amount_date) - trunc(sysdate)) - v_time_limit),
           null,p_dealer_code,'TIME','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    end if;
    close c_date_restr;
   end if;
   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug('After time limits on '||to_char(sysdate,'MM:DD:HH24:MI:SS'));
   END IF;
  end if;
  --
  --
  --
  /*
  -- ********** check intra-day limits (NOT REQD AT THIS STAGE)
  --
  if p_dealer_code is NOT null and p_deal_type is NOT null then
    XTR_LIMITS_P.GET_LIM_INTRA_DAY ( p_DEAL_NUMBER,p_dealer_code,p_deal_type,
                                    v_limit_amt,v_util_amt,v_err_code);
    if v_err_code is null then
      v_util_amt := v_util_amt + v_hce_amount;
      if v_util_amt > v_limit_amt then
        INSERT into XTR_limit_excess_log
          (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
           COMPANY_CODE,LIMIT_CODE,
           LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
           EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
           LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
        VALUES
          (v_unique_num,-1,null,
           v_company_code, p_limit_code,
           p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
           v_util_amt - v_limit_amt, NULL, p_dealer_code,
           'INTRA_DY','EXCEEDED',sysdate);
        v_logged_yn := TRUE;
      end if;
    else
      INSERT into XTR_limit_excess_log
      (LOG_ID,DEAL_NUMBER,TRANSACTION_NUMBER,
       COMPANY_CODE,LIMIT_CODE,
       LIMIT_PARTY,AMOUNT_DATE,HCE_AMOUNT,LIMITING_AMOUNT,
       EXCEEDED_BY_AMOUNT,AUTHORISED_BY,DEALER_CODE,
       LIMIT_CHECK_TYPE,EXCEPTION_TYPE,EXCEEDED_ON_DATE)
      VALUES
      (v_unique_num,-1,null,
       v_company_code, p_limit_code,
       p_limit_party, p_amount_date,v_hce_amount,v_limit_amt,
       v_util_amt - v_limit_amt, NULL, p_dealer_code,
       'INTRA_DY',v_err_code,sysdate);
      v_logged_yn := TRUE;
    end if;
  end if;
  --
 */
 --
end if;
IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
  xtr_debug_pkg.debug('After LOG_FULL_LIMITS_CHK on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
END IF;
if v_logged_yn then
--- commit;
 return(v_unique_num);
else
 return(0); -- Tell calling form that there were no excesses logged.
end if;
end;
---------------------------------------------------------------




PROCEDURE UPDATE_LIMIT_EXCESS_LOG(p_deal_no   IN  NUMBER,
                                  p_trans_no  IN  NUMBER,
                                  p_user      IN  VARCHAR2,
                                  p_log_id    IN  NUMBER) is

BEGIN

   update XTR_LIMIT_EXCESS_LOG_V
   set   deal_number        = p_deal_no,
         transaction_number = p_trans_no,
         authorised_by      = p_user
   where log_id             = p_log_id;

END UPDATE_LIMIT_EXCESS_LOG;

---------------------------------------------------------------
PROCEDURE CALC_ALL_MIRROR_DDA_LIMIT_ROW(p_auto_recalc VARCHAR2) is
  --
  -- Completely repopulate the dda mirror table, also recalculating HCE amounts.
  -- if not alreay done once for today
  --
  cursor CHK_UPDATE is
   select 1
    from XTR_PRO_PARAM
    where PARAM_NAME = 'LAST_LIMIT_RECALC'
    and to_date(nvl(PARAM_VALUE,'01/01/1990'),'DD/MM/YYYY') < trunc(sysdate);
  --
  cursor c_dda_row is
   select COMPANY_CODE,CPARTY_CODE,LIMIT_CODE,LIMIT_PARTY,AMOUNT_DATE,AMOUNT,
          HCE_AMOUNT,DEALER_CODE,DEAL_NUMBER,DEAL_TYPE,
          TRANSACTION_NUMBER,DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,
          PRODUCT_TYPE,CURRENCY
    from XTR_DEAL_DATE_AMOUNTS
    where LIMIT_CODE is NOT NULL
    and STATUS_CODE  = 'CURRENT'
    and ((AMOUNT_DATE >= trunc(sysdate) and DEAL_TYPE NOT IN('ONC','CMF')) or
         (AMOUNT_DATE >= trunc(sysdate) and DEAL_TYPE IN('ONC','CMF')
          and PRODUCT_TYPE = 'FIXED') or
          (DEAL_TYPE IN('ONC','CMF') and PRODUCT_TYPE <> 'FIXED'));
  --
  cursor c_get_country (pc_party_code VARCHAR2) is
    select country_code
    from XTR_PARTY_INFO
    where party_code = pc_party_code;
  --
  cursor HCE is
   select amount,rowid row_id,DEAL_TYPE,DEAL_SUBTYPE,AMOUNT_DATE,COMPANY_CODE,CURRENCY
    from XTR_MIRROR_DDA_LIMIT_ROW
    for update of amount;
  --
  -- ER 6449996 Start
  cursor GET_LIMIT_RELEASE_TYPE IS
 select param_value from  xtr_pro_param where
param_name = 'RELEASE_LIMIT_UTIL';
-- ER 6449996 End
--
  l_new_utilamt        NUMBER;
  l_new_hce_utilamt    NUMBER;
  l_new_hce_amt        NUMBER;
  l_dummy              NUMBER;
  l_dummy_char         VARCHAR2(100);
  v_country_code       VARCHAR2(50);
  v_utilised_amt       NUMBER;
  v_hce_utilised_amt   NUMBER;
  v_limit_party        VARCHAR2(7);
   -- ER 6449996 Start
  L_RELEASE_TYPE     XTR_PRO_PARAM.PARAM_VALUE%TYPE;
   -- ER 6449996 End
  L_SYS_DATE DATE;
--
begin
 -- ER 6449996 Start
open GET_LIMIT_RELEASE_TYPE ;
 fetch GET_LIMIT_RELEASE_TYPE into L_RELEASE_TYPE ;
 close GET_LIMIT_RELEASE_TYPE;
 if L_RELEASE_TYPE = 'ON_MATURITY' then
 L_SYS_DATE :=trunc(sysdate)+1;
 else
 L_SYS_DATE :=trunc(sysdate);
 end if;
  -- ER 6449996 End
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('Before CALC_ALL_MIRROR_DDA_LIMIT_ROW  on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
  END IF;
  open CHK_UPDATE;
   fetch CHK_UPDATE INTO l_dummy;
  if CHK_UPDATE%FOUND or p_auto_recalc = 'Y' then
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
    xtr_debug_pkg.debug('Before delete xtr_mirror_dda_limit_row  on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
  END IF;
   delete from XTR_mirror_dda_limit_row
    where amount_date < L_SYS_DATE
    and deal_type not in('ONC','CA','IG', 'STOCK');
   ---
   IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug('After delete xtr_mirror_dda_limit_row('||to_char(sql%rowcount)||')  on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
   END IF;
   FOR c in HCE LOOP
      -- Calculate weighted usage for this data.
     l_new_utilamt := XTR_LIMITS_P.WEIGHTED_USAGE(c.deal_type,c.deal_subtype,
                                               c.amount_date,c.amount);

     l_new_hce_utilamt  := XTR_LIMITS_P.CONVERT_TO_HCE_AMOUNT( l_new_utilamt,
                                                              c.currency,
                                                              c.company_code);
     l_new_hce_amt  := XTR_LIMITS_P.CONVERT_TO_HCE_AMOUNT(c.amount,
                                                         c.currency,
                                                         c.company_code);
   update XTR_mirror_dda_limit_row
     set hce_amount = l_new_hce_amt,
         hce_utilised_amount = l_new_hce_utilamt,
         utilised_amount = l_new_utilamt
    where rowid = c.row_id;
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
      xtr_debug_pkg.debug('After update xtr_mirror_dda_limit_row('||c.row_id||')  on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
    END IF;
   END LOOP;
   --
   update XTR_PRO_PARAM
    set PARAM_VALUE = to_char(sysdate,'DD/MM/YYYY')
    where PARAM_NAME = 'LAST_LIMIT_RECALC';
 ---  commit;
  end if;
  --
  IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
     xtr_debug_pkg.debug('After CALC_ALL_MIRROR_DDA_LIMIT_ROW  on:'||to_char(sysdate,'MM:DD:HH24:MI:SS'));
  END IF;
  close CHK_UPDATE;
end;
---------------------------------------------------------------
--
-- Cover routine so CALC_ALL_MIRROR_DDA_LIMIT_ROW can be called as a concurrent
--   program.
--
PROCEDURE update_weightings(
	errbuf                  OUT NOCOPY VARCHAR2,
	retcode                 OUT NOCOPY NUMBER) IS
BEGIN
  -- Pass as 'Y' to force the update to occur
  calc_all_mirror_dda_limit_row('Y');
END update_weightings;
---------------------------------------------------------------
-- Note: this procedure assumes there will be only one record in DDA for each deal_no/
-- transaction_number combination WHICH HAS a non-null limit_code.
--
procedure MIRROR_DDA_LIMIT_ROW_PROC (
            p_action                   VARCHAR2,
            p_old_LIMIT_CODE           VARCHAR2,
            p_old_DEAL_NUMBER          NUMBER,
            p_old_TRANSACTION_NUMBER   NUMBER,
            p_new_product_type         VARCHAR2,
            p_new_COMPANY_CODE         VARCHAR2,
            p_new_LIMIT_PARTY          VARCHAR2,
            p_new_LIMIT_CODE           VARCHAR2,
            p_new_AMOUNT_DATE          DATE,
            p_new_AMOUNT               NUMBER,
            p_new_HCE_AMOUNT           NUMBER,
            p_new_DEALER_CODE          VARCHAR2,
            p_new_DEAL_NUMBER          NUMBER,
            p_new_DEAL_TYPE            VARCHAR2,
            p_new_TRANSACTION_NUMBER   NUMBER,
            p_new_DEAL_SUBTYPE         VARCHAR2,
            p_new_PORTFOLIO_CODE       VARCHAR2,
            p_new_STATUS_CODE          VARCHAR2,
            p_new_currency             VARCHAR2,
	   	p_amount_type		   VARCHAR2,
     	   	p_transaction_rate	   NUMBER,
	    	p_currency_combination     VARCHAR2,
	    	p_account_no	         VARCHAR2,
            p_commence_date            DATE ) is
--
-- This procedure is called by a DB trigger on table DDA whenever a DDA record is
-- UPDATED/DELETED/INSERTED. This procedure has two purposes:
-- 1) maintain a mirror of the non-null-limit-code DDA records in table mirror_dda_limit_row.
-- 2) calculate and store the current limit usage amount for each mirror record whenever a
--    mirror row is inserted/updated.
--
  cursor c_get_type is
   select limit_type
    from XTR_company_limits
    where company_code = p_new_company_code
    and limit_code = p_new_limit_code;
  --
  cursor c_get_country (pc_party_code VARCHAR2) is
   select country_code,nvl(cross_ref_to_other_party,pc_party_code)
    from XTR_PARTY_INFO
    where party_code = pc_party_code;
  --
  v_country_code        XTR_PARTY_INFO.country_code%TYPE;
  v_utilised_amount     NUMBER;
  v_hce_utilised_amt    NUMBER;
  v_hce_amt             NUMBER;
  v_limit_party         VARCHAR2(7);
  v_limit_type          VARCHAR2(7);
  --
  v_amount_indic		NUMBER := 1;
  v_contra_ccy		VARCHAR2(15) :=NULL;
  v_group_party         VARCHAR2(20);
  --
  l_commence_date       date;

begin
    -- Note: this procedure MUST only be called (from a DB trigger) when at least
    -- one of :old.limit_code and :new.limit_code is NOT null. Otherwise the
    -- following if p_old_limit_code ... then ... elsif ... will work incorrectly.
    --
    open c_get_country( p_new_LIMIT_PARTY );
     fetch c_get_country into v_country_code,v_group_party;
    close c_get_country;
    --
    open c_get_type;
     fetch c_get_type into v_limit_type;
    close c_get_type;
    --
    if p_new_deal_type IN ('FX','FXO') then
      if p_new_currency =substr(p_currency_combination,1,3) then
         v_contra_ccy :=substr(p_currency_combination,5,7);
      else
         v_contra_ccy :=substr(p_currency_combination,1,3);
      end if;
      if p_amount_type IN('SELL','FXOSELL') then
         v_amount_indic :=-1;
      else
         v_amount_indic :=1;
      end if;
    end if;
    ----
    l_commence_date :=nvl(p_commence_date,p_new_AMOUNT_DATE);

    if p_action <> 'DELETE' and (p_new_status_code = 'CURRENT'
				OR (p_old_limit_code is not null and p_new_limit_code is not null and p_new_status_code IN ('EXERCISED','SETTLED','CANCELLED'))) then
      -- Calculate weighted usage for this data.
      v_utilised_amount := XTR_LIMITS_P.WEIGHTED_USAGE(p_new_deal_type,
                                                      p_new_deal_subtype,
                                                      p_new_amount_date,
                                                      p_new_amount);
      -- Now calculate home-currency-equivalent for v_utilised_amt...
      v_hce_utilised_amt := XTR_LIMITS_P.CONVERT_TO_HCE_AMOUNT(v_utilised_amount,
                                                              p_new_currency,
                                                              p_new_company_code);
      v_hce_amt := XTR_LIMITS_P.CONVERT_TO_HCE_AMOUNT(p_new_amount,
                                                     p_new_currency,
                                                     p_new_company_code);
    else
      v_utilised_amount := 0;
      v_hce_utilised_amt := 0;
      v_hce_amt := 0;
    end if;
    ----------------------------------------------
    if p_action = 'UPDATE' then
      -- old lim code | new lim code  | action
      -- ++++++++++++++++++++++++++++++++++++++
      --     null     |    null       | does not reach here
      --     null     |     X         | INSERT
      --      X       |    null       | DELETE (status = 'CLOSED') (no reverse cof)
      --      X       |     Y         | UPDATE
      --
      -- Remember: to get this far, at least one of old/new limit code is NOT null.
      if p_old_limit_code is null then
        update XTR_mirror_dda_limit_row
        set PRODUCT_TYPE =p_new_product_type,
            COMPANY_CODE = p_new_COMPANY_CODE,
            LIMIT_CODE =p_new_LIMIT_CODE,
            LIMIT_PARTY =p_new_LIMIT_PARTY,
            AMOUNT_DATE =p_new_AMOUNT_DATE,
            AMOUNT =p_new_AMOUNT,
            HCE_AMOUNT =v_hce_amt,
            DEALER_CODE =p_new_DEALER_CODE,
            COUNTRY_CODE =v_country_code,
            DEAL_TYPE =p_new_DEAL_TYPE,
            DEAL_SUBTYPE =p_new_DEAL_SUBTYPE,
            PORTFOLIO_CODE =p_new_PORTFOLIO_CODE,
            STATUS_CODE =p_new_STATUS_CODE,
            UTILISED_AMOUNT = v_utilised_amount,
            DATE_LAST_SET = sysdate,
            HCE_UTILISED_AMOUNT = v_hce_utilised_amt,
            CURRENCY = p_new_currency,
            AMOUNT_INDIC = v_amount_indic,
            TRANSACTION_RATE = p_transaction_rate,
            CONTRA_CCY = v_contra_ccy,
            CURRENCY_COMBINATION = p_currency_combination,
            COMMENCE_DATE = l_commence_date,
            ACCOUNT_NO = p_account_no,
            CROSS_REF_TO_OTHER_PARTY = v_group_party,
            LIMIT_TYPE = v_limit_type
        where deal_number = p_new_deal_number
        and  transaction_number = p_new_transaction_number ;
        --
       if SQL%NOTFOUND then -- No row was updated.
        insert into XTR_mirror_dda_limit_row
        (COMPANY_CODE,LIMIT_CODE,LIMIT_PARTY,AMOUNT_DATE,AMOUNT,
         HCE_AMOUNT,DEALER_CODE,COUNTRY_CODE,DEAL_NUMBER,DEAL_TYPE,
         TRANSACTION_NUMBER,DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,
         UTILISED_AMOUNT,PRODUCT_TYPE,DATE_LAST_SET,HCE_UTILISED_AMOUNT,CURRENCY,
         AMOUNT_INDIC,TRANSACTION_RATE,CONTRA_CCY,CURRENCY_COMBINATION,ACCOUNT_NO,
         COMMENCE_DATE,CROSS_REF_TO_OTHER_PARTY,LIMIT_TYPE)
        values
        (p_new_COMPANY_CODE,p_new_LIMIT_CODE,p_new_LIMIT_PARTY,p_new_AMOUNT_DATE,p_new_AMOUNT,
	   v_hce_amt,p_new_DEALER_CODE,v_country_code,p_new_DEAL_NUMBER,p_new_DEAL_TYPE,
         p_new_TRANSACTION_NUMBER,p_new_DEAL_SUBTYPE,p_new_PORTFOLIO_CODE,p_new_STATUS_CODE,
         v_utilised_amount,p_new_product_type,sysdate,v_hce_utilised_amt,p_new_currency,
         v_amount_indic,p_transaction_rate,v_contra_ccy,p_currency_combination,p_account_no,
         l_commence_date,v_group_party,v_limit_type);
        end if;
      elsif p_new_limit_code is null then
        delete from XTR_mirror_dda_limit_row
        where deal_number = p_old_deal_number
        and   transaction_number = p_old_transaction_NUMBER;
      else -- same as: elsif p_old_limit_code is NOT null and p_new_limit_code is NOT null then
        update XTR_mirror_dda_limit_row
        set PRODUCT_TYPE =p_new_product_type,
            COMPANY_CODE = p_new_COMPANY_CODE,
            LIMIT_CODE =p_new_LIMIT_CODE,
            LIMIT_PARTY =p_new_LIMIT_PARTY,
            AMOUNT_DATE =p_new_AMOUNT_DATE,
            AMOUNT =p_new_AMOUNT,
            HCE_AMOUNT =v_hce_amt,
            DEALER_CODE =p_new_DEALER_CODE,
            COUNTRY_CODE =v_country_code,
            DEAL_TYPE =p_new_DEAL_TYPE,
            DEAL_SUBTYPE =p_new_DEAL_SUBTYPE,
            PORTFOLIO_CODE =p_new_PORTFOLIO_CODE,
            STATUS_CODE =p_new_STATUS_CODE,
            UTILISED_AMOUNT = v_utilised_amount,
            DATE_LAST_SET = sysdate,
            HCE_UTILISED_AMOUNT = v_hce_utilised_amt,
            CURRENCY = p_new_currency,
            AMOUNT_INDIC = v_amount_indic,
            TRANSACTION_RATE = p_transaction_rate,
		CONTRA_CCY = v_contra_ccy,
		CURRENCY_COMBINATION = p_currency_combination,
            COMMENCE_DATE = l_commence_date,
            ACCOUNT_NO = p_account_no,
            CROSS_REF_TO_OTHER_PARTY = v_group_party,
            LIMIT_TYPE = v_limit_type
        where deal_number = p_new_deal_number
        and  transaction_number = p_new_transaction_number ;
        --
        if SQL%NOTFOUND then -- No row was updated.
          insert into XTR_mirror_dda_limit_row
          (COMPANY_CODE,LIMIT_CODE,LIMIT_PARTY,AMOUNT_DATE,AMOUNT,
           HCE_AMOUNT,DEALER_CODE,COUNTRY_CODE,DEAL_NUMBER,DEAL_TYPE,
           TRANSACTION_NUMBER,DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,
           UTILISED_AMOUNT,PRODUCT_TYPE,DATE_LAST_SET,HCE_UTILISED_AMOUNT,CURRENCY,
           AMOUNT_INDIC,TRANSACTION_RATE,CONTRA_CCY,CURRENCY_COMBINATION,ACCOUNT_NO,
           COMMENCE_DATE,CROSS_REF_TO_OTHER_PARTY,LIMIT_TYPE)
          values
          (p_new_COMPANY_CODE,p_new_LIMIT_CODE,p_new_LIMIT_PARTY,p_new_AMOUNT_DATE,p_new_AMOUNT,
           v_hce_amt,p_new_DEALER_CODE,v_country_code,p_new_DEAL_NUMBER,p_new_DEAL_TYPE,
           p_new_TRANSACTION_NUMBER,p_new_DEAL_SUBTYPE,p_new_PORTFOLIO_CODE,p_new_STATUS_CODE,
           v_utilised_amount,p_new_product_type,sysdate,v_hce_utilised_amt,p_new_currency,
           v_amount_indic,p_transaction_rate,v_contra_ccy,p_currency_combination,p_account_no,
           l_commence_date,v_group_party,v_limit_type);
        end if;
      end if;
    ----------------------------------------------
    elsif p_action = 'INSERT' then

      insert into XTR_mirror_dda_limit_row
      (COMPANY_CODE,LIMIT_CODE,LIMIT_PARTY,AMOUNT_DATE,AMOUNT,
       HCE_AMOUNT,DEALER_CODE,COUNTRY_CODE,DEAL_NUMBER,DEAL_TYPE,
       TRANSACTION_NUMBER,DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,
       UTILISED_AMOUNT,PRODUCT_TYPE,DATE_LAST_SET,HCE_UTILISED_AMOUNT,CURRENCY,
       AMOUNT_INDIC,TRANSACTION_RATE,CONTRA_CCY,CURRENCY_COMBINATION,ACCOUNT_NO,
       COMMENCE_DATE,CROSS_REF_TO_OTHER_PARTY,LIMIT_TYPE)
      values
      (p_new_COMPANY_CODE,p_new_LIMIT_CODE,p_new_LIMIT_PARTY,p_new_AMOUNT_DATE,p_new_AMOUNT,
       v_hce_amt,p_new_DEALER_CODE,v_country_code,p_new_DEAL_NUMBER,p_new_DEAL_TYPE,
       p_new_TRANSACTION_NUMBER,p_new_DEAL_SUBTYPE,p_new_PORTFOLIO_CODE,p_new_STATUS_CODE,
       v_utilised_amount,p_new_product_type,sysdate,v_hce_utilised_amt,p_new_currency,
       v_amount_indic,p_transaction_rate,v_contra_ccy,p_currency_combination,p_account_no,
       l_commence_date,v_group_party,v_limit_type);
    -----------------------------------------------------------------------------------------
    elsif p_action = 'DELETE' then
     delete from XTR_mirror_dda_limit_row
      where deal_number = p_old_deal_number
      and transaction_number = p_old_transaction_number ;
    end if;
end;
------------------------------------------------------------------------------------------------------------------------------
PROCEDURE GET_LIM_GLOBAL ( p_deal_no      NUMBER,
                           p_company_code VARCHAR2,
                           p_limit_code   VARCHAR2,
                           p_limit_amt    OUT NOCOPY number,
                           p_util_amt     OUT NOCOPY number,
                           p_err_code     OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util(pc1_company_code VARCHAR2,pc1_limit_code VARCHAR2) is
   SELECT nvl(limit_amount,0), nvl(utilised_amount,0)
   FROM xtr_company_limits
   WHERE company_code = pc1_company_code
   AND limit_code = pc1_limit_code
   AND (limit_amount <> 0 OR utilised_amount <> 0);
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
--
begin

  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_GLOBAL');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_util(p_company_code,p_limit_code);
    fetch c_get_util into v_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND then
    close c_get_util;
    p_limit_amt := 0;
    p_util_amt := 0;
    raise ex_no_limit_exists;
   end if;
   close c_get_util;
   p_limit_amt := v_limit_amt;
   p_util_amt := v_used_amt;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE GET_LIM_GROUP  ( p_deal_no      NUMBER,
                           p_company_code VARCHAR2,
                           p_limit_type   VARCHAR2,
                           p_group_party  VARCHAR2,
                           p_limit_amt    OUT NOCOPY number,
                           p_util_amt     OUT NOCOPY number,
                           p_err_code     OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util(pc1_company_code VARCHAR2,pc1_limit_type VARCHAR2,
                    pc1_limit_party VARCHAR2) is
   SELECT nvl(limit_amount,0), nvl(utilised_amount,0)
   FROM xtr_group_limits
   WHERE company_code = pc1_company_code
   AND cparty_code = pc1_limit_party
   AND ((limit_type = pc1_limit_type and limit_type <>'XI')
      or (limit_type='XI' and pc1_limit_type in('X','I')))
   AND (limit_amount <> 0 OR utilised_amount <> 0);
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
    select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
--
 cursor GET_FX_INVEST_FUND_TYPE is
  select fx_invest_fund_type
   from XTR_LIMIT_TYPES
    where limit_type=p_limit_type;

 l_limit_type varchar2(2);

begin
  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_GROUP');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then

-- bug 2990074

/*
   open GET_FX_INVEST_FUND_TYPE;
    fetch GET_FX_INVEST_FUND_TYPE into l_limit_type;
   close GET_FX_INVEST_FUND_TYPE;
*/

   open c_get_util(p_company_code,p_limit_type,p_group_party);
    fetch c_get_util into v_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND then
    close c_get_util;
    p_limit_amt := 0;
    p_util_amt := 0;
    raise ex_no_limit_exists;
   end if;
   close c_get_util;
   p_limit_amt := v_limit_amt;
   p_util_amt := v_used_amt;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE GET_LIM_SOVEREIGN ( p_deal_no      NUMBER,
                              p_company_code VARCHAR2,
                              p_country_code VARCHAR2,
                              p_limit_amt    OUT NOCOPY number,
                              p_util_amt     OUT NOCOPY number,
                              p_err_code     OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util (pc1_company_code VARCHAR2,pc1_country_code VARCHAR2) is
   SELECT nvl(limit_amount,0), nvl(utilised_amount,0)
   FROM xtr_country_company_limits
   WHERE company_code = pc1_company_code
   AND country_code = pc1_country_code
   AND (limit_amount <> 0 OR utilised_amount <> 0);
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
--
begin

  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_SOVRN');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_util(p_company_code,p_country_code );
    fetch c_get_util into v_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND then
    close c_get_util;
    p_util_amt := 0;
    p_limit_amt := 0;
    raise ex_no_limit_exists;
   end if;
   p_limit_amt := v_limit_amt;
   p_util_amt := v_used_amt;
   close c_get_util;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE GET_LIM_DEALER_DEAL ( p_deal_no      NUMBER,
                             -- deal_no not actually used at present.
                                p_dealer_code  VARCHAR2,
                                p_deal_type    VARCHAR2,
                                p_product_type VARCHAR2,
                                p_limit_amt    OUT NOCOPY number,
                                p_err_code     OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_limit (pc2_dealer_code VARCHAR2,pc2_deal_type VARCHAR2,
                      pc2_product_type VARCHAR2) is
   select single_deal_limit_amount,authorised
    from XTR_DEALER_LIMITS
    where dealer_code = pc2_dealer_code
    and deal_type = pc2_deal_type
    and (product_type = pc2_product_type or product_type is NULL)
    order by product_type;
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  v_limit_amt NUMBER;
  v_ok_to_do  VARCHAR2(2);
  v_auth      VARCHAR2(1);
--
begin

  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_DLR_DEAL');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_limit( p_dealer_code, p_deal_type, p_product_type );
    fetch c_get_limit into v_limit_amt,v_auth;
   if c_get_limit%NOTFOUND then
    close c_get_limit;
    p_limit_amt := 0;
    raise ex_no_limit_exists;
   end if;
   if nvl(v_auth,'N') <> 'Y' then
    close c_get_limit;
    p_limit_amt := 0;
    raise ex_auth_not_y;
   end if;
   close c_get_limit;
   p_limit_amt := v_limit_amt;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE GET_LIM_INTRA_DAY ( p_deal_no      NUMBER,
                              p_dealer_code  VARCHAR2,
                              p_deal_type    VARCHAR2,
                              p_limit_amt    OUT NOCOPY number,
                              p_util_amt     OUT NOCOPY number,
                              p_err_code     OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util (pc1_dealer_code VARCHAR2, pc1_deal_type VARCHAR2) is
   select nvl(sum(decode(deal_subtype,'BUY',HCE_AMOUNT,'SELL',-HCE_AMOUNT,0)),0)
    from XTR_mirror_dda_limit_row
    where dealer_code  = pc1_dealer_code
    and   deal_type    = pc1_deal_type;
  --
  cursor c_get_limit (pc2_dealer_code VARCHAR2, pc2_deal_type VARCHAR2) is
    select limit_amount, authorised
    from XTR_intra_day_limits
    where dealer_code = pc2_dealer_code
    and   deal_type   = pc2_deal_type;
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
    select nvl(param_value,'Y')
    from XTR_pro_param
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth            XTR_DEALER_LIMITS.authorised%TYPE;
  v_used_amt        XTR_MIRROR_DDA_LIMIT_ROW.utilised_amount%TYPE;
begin
 -- this is not called at this stage
 null;
/*
  p_err_code := null;
  open c_ok_to_do( 'LIMIT_CHECK_INTRA_DY');
  fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then v_ok_to_do := 'Y'; end if;
  close c_ok_to_do;
  if v_ok_to_do = 'N' then return; end if;
  --
  open c_get_util(p_dealer_code,p_deal_type );
  fetch c_get_util into v_used_amt;
  if c_get_util%NOTFOUND then p_util_amt := 0; end if;
  close c_get_util;
  p_util_amt := v_used_amt;
  --
  open c_get_limit( p_dealer_code,p_deal_type );
  fetch c_get_limit into p_limit_amt, v_auth;
  if c_get_limit%NOTFOUND then
    close c_get_limit;
    raise ex_no_limit_exists;
  end if;
  if nvl(v_auth,'N') <> 'Y' then
    close c_get_limit;
    raise ex_auth_not_y;
  end if;
  close c_get_limit;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
*/
end;
---------------------------------------------------------------
PROCEDURE GET_LIM_CPARTY ( p_deal_no       NUMBER,
                           p_company_code  VARCHAR2,
                           p_cparty_code   VARCHAR2,
                           p_limit_code    VARCHAR2,
                           p_limit_amt     OUT NOCOPY number,
                           p_util_amt      OUT NOCOPY number,
                           p_err_code      OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util (pc1_company_code VARCHAR2,pc1_cparty_code VARCHAR2,
                     pc1_limit_code VARCHAR2) is
   SELECT nvl(cl.limit_amount,0), nvl(cl.utilised_amount,0)
   FROM xtr_counterparty_limits cl, xtr_parties_v p
   WHERE cl.company_code = pc1_company_code
   AND cl.cparty_code = pc1_cparty_code
   AND cl.limit_code = pc1_limit_code
   AND cl.limit_code <> 'SETTLE'
   AND cl.cparty_code = p.party_code||''
   AND (cl.limit_amount <> 0 OR cl.utilised_amount <> 0);
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_pro_param
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
--
begin

  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_CPARTY');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_util(p_company_code,p_cparty_code,p_limit_code );
    fetch c_get_util into v_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND then
    close c_get_util;
    p_util_amt := 0;
    p_limit_amt := 0;
    raise ex_no_limit_exists;
   end if;
   p_limit_amt := v_limit_amt;
   p_util_amt  := v_used_amt;
   close c_get_util;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE GET_ACTUAL_SETTLE_EXCESS ( p_deal_no       NUMBER,
                                     p_company_code  VARCHAR2,
                                     p_limit_party   VARCHAR2,
                                     p_amount_date   DATE,
                                     p_limit_amt     OUT NOCOPY number,
                                     p_util_amt      OUT NOCOPY number,
                                     p_err_code      OUT NOCOPY VARCHAR2) is
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
  v_include_payments VARCHAR2(1);
  --
  cursor c_get_util(pc1_company_code VARCHAR2,pc1_limit_party VARCHAR2,
                    pc1_amount_date date) is
   select nvl(max(B.LIMIT_AMOUNT),0) LIMIT_AMT,
          nvl(sum(round(abs(A.CASHFLOW_AMOUNT) / M.HCE_RATE,0)),0) UTILISED
    from XTR_DEAL_DATE_AMOUNTS A,
         XTR_COUNTERPARTY_LIMITS B,
         XTR_MASTER_CURRENCIES M
    where A.ACTUAL_SETTLEMENT_DATE = pc1_amount_date
    and A.SETTLE = 'Y'
    and A.COMPANY_CODE = pc1_company_code
    and A.AMOUNT_TYPE NOT IN ('FXOBUY','FXOSELL')
    and A.EXP_SETTLE_REQD = 'Y'
    and NVL(A.MULTIPLE_SETTLEMENTS,'N') = 'N'
    and A.DEAL_SUBTYPE <> 'INDIC'
    and nvl(A.BENEFICIARY_PARTY,A.CPARTY_CODE) = pc1_limit_party
    and B.CPARTY_CODE = A.CPARTY_CODE
    and B.COMPANY_CODE = A.COMPANY_CODE
    and B.LIMIT_CODE = 'SETTLE'
    and M.CURRENCY = A.CURRENCY
    and (
         (v_include_payments='N' and A.CASHFLOW_AMOUNT>0)
         or
         (v_include_payments='Y')
        );
  --
  cursor c_ok_to_do(pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  cursor c_get_limit_amt(pc1_company_code VARCHAR2,pc1_limit_party VARCHAR2) is
   select nvl(limit_amount,0)
    from XTR_COUNTERPARTY_LIMITS
    where cparty_code = pc1_limit_party
    and company_code = pc1_company_code
    and limit_code = 'SETTLE';
  --
--
begin
  p_err_code := null;
  --
  open c_ok_to_do('LIMIT_CHECK_SETTLE');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  -- bug 2428516
  open c_ok_to_do('LIMIT_INCLUDE_PAYMENTS');
   fetch c_ok_to_do into v_include_payments;
  if c_ok_to_do%NOTFOUND then
   v_include_payments := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_util(p_company_code,p_limit_party,p_amount_date);
    fetch c_get_util into v_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND or nvl(v_limit_amt,0) = 0 then
    v_used_amt := 0;
    v_limit_amt := 0;
    -- need to get limit amount separately as no settle rows
    -- exist therefore the join won't pick up the limit amount
    open c_get_limit_amt(p_company_code,p_limit_party);
     fetch c_get_limit_amt into v_limit_amt;
    if c_get_limit_amt%NOTFOUND then
     close c_get_limit_amt;
     p_limit_amt := 0;
     raise ex_no_limit_exists;
    end if;
    close c_get_limit_amt;
   end if;
   close c_get_util;
   p_limit_amt := v_limit_amt;
   p_util_amt  := v_used_amt;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
--------------------------------------------------------------------------------
PROCEDURE GET_LIM_SETTLE ( p_deal_no       NUMBER,
                           p_company_code  VARCHAR2,
                           p_limit_party   VARCHAR2,
                           p_amount_date   DATE,
                           p_limit_amt     OUT NOCOPY number,
                           p_util_amt      OUT NOCOPY number,
                           p_err_code      OUT NOCOPY VARCHAR2) is
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
  v_limit_amt    NUMBER;
  v_include_payments VARCHAR2(1);
  -- This cursor only applies when p_amount_date is greater than sysdate
  cursor c_get_util_future(pc1_company_code VARCHAR2,pc1_limit_party VARCHAR2,
                    pc1_amount_date date) is
   SELECT nvl(max(cl.limit_amount),0),
	nvl(sum(round(abs(s.cashflow_amount)/mc.hce_rate,0)),0)
   FROM xtr_settlements_v s,
	xtr_counterparty_limits cl,
	xtr_master_currencies mc
   WHERE s.amount_date > trunc(sysdate)
   AND cl.cparty_code = s.cparty
   AND cl.company_code = s.company
   AND cl.limit_code = 'SETTLE'
   AND mc.currency = s.currency
   AND s.amount_date = pc1_amount_date
   AND s.cparty = pc1_limit_party
   AND s.company = pc1_company_code
   AND (
        (v_include_payments='N' and S.CASHFLOW_AMOUNT>0)
        OR
        (v_include_payments='Y')
       )
   GROUP BY s.cparty, s.company, s.amount_date;
  -- This cursor only applies when p_amount_date is sysdate
  cursor c_get_util_today(pc1_company_code VARCHAR2,pc1_limit_party VARCHAR2,
                    pc1_amount_date date) is
   SELECT nvl(max(cl.limit_amount),0),
	nvl(sum(sru.utilised_amount),0)
   FROM (
           SELECT nvl(SUM(ROUND(ABS(a.CASHFLOW_AMOUNT) / m.HCE_RATE,0)),0) UTILISED_AMOUNT,
                  a.CPARTY CPARTY_CODE,
                  a.COMPANY COMPANY_CODE,
                  nvl(a.AMOUNT_DATE,TRUNC(SYSDATE)) EFFECTIVE_DATE
           FROM XTR_SETTLEMENTS_V a, XTR_MASTER_CURRENCIES m
           WHERE a.AMOUNT_DATE = trunc(SYSDATE)
           AND a.CASHFLOW_AMOUNT <> 0
           AND m.CURRENCY = a.CURRENCY
           AND (
                (v_include_payments='N' and A.CASHFLOW_AMOUNT>0)
               OR
                (v_include_payments='Y')
               )
           GROUP by a.CPARTY,a.COMPANY,nvl(a.AMOUNT_DATE,trunc(SYSDATE))
        ) sru,
	xtr_counterparty_limits cl
   WHERE cl.cparty_code = sru.cparty_code(+)
   AND cl.company_code = sru.company_code(+)
   AND cl.limit_code = 'SETTLE'
   AND nvl(sru.effective_date,trunc(sysdate)) = pc1_amount_date
   AND cl.cparty_code = pc1_limit_party
   AND cl.company_code = pc1_company_code
   GROUP BY cl.cparty_code, cl.company_code, sru.effective_date;
  --
  cursor c_param_val(pc3_param_name VARCHAR2) is
   select param_value
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  cursor c_get_limit_amt(pc1_company_code VARCHAR2,pc1_limit_party VARCHAR2) is
   select nvl(limit_amount,0)
    from XTR_COUNTERPARTY_LIMITS
    where cparty_code = pc1_limit_party
    and company_code = pc1_company_code
    and limit_code = 'SETTLE'
    and limit_amount <> 0;
  --
--
begin
  p_err_code := null;
  --
  open c_param_val('LIMIT_CHECK_SETTLE');
   fetch c_param_val into v_ok_to_do;
  if c_param_val%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_param_val;
  --
  -- bug 2428516
  open c_param_val('LIMIT_INCLUDE_PAYMENTS');
   fetch c_param_val into v_include_payments;
  if c_param_val%NOTFOUND then
   v_include_payments := 'Y';
  end if;
  close c_param_val;
  --
  if nvl(v_ok_to_do,'Y') = 'Y' then
   v_limit_amt := Null;
   IF trunc(p_amount_date) = trunc(sysdate) THEN
    open c_get_util_today(p_company_code,p_limit_party,p_amount_date);
    fetch c_get_util_today into v_limit_amt,v_used_amt;
   ELSE
    open c_get_util_future(p_company_code,p_limit_party,p_amount_date);
    fetch c_get_util_future into v_limit_amt,v_used_amt;
   END IF;
   if nvl(v_limit_amt,0) = 0 then
    v_used_amt := 0;
    v_limit_amt := 0;
    open c_get_limit_amt(p_company_code,p_limit_party);
     fetch c_get_limit_amt into v_limit_amt;
    if c_get_limit_amt%NOTFOUND then
     close c_get_limit_amt;
     p_limit_amt := 0;
     raise ex_no_limit_exists;
    end if;
    close c_get_limit_amt;
   end if;
   IF trunc(p_amount_date) = trunc(sysdate) THEN
    close c_get_util_today;
   ELSE
    close c_get_util_future;
   END IF;
   p_limit_amt := v_limit_amt;
   p_util_amt  := v_used_amt;
  end if;
EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
--------------------------------------------------------------------------------
PROCEDURE GET_LIM_CCY ( p_deal_no     NUMBER,
                        p_currency    VARCHAR2,
                        p_limit_amt   OUT NOCOPY number,
                        p_util_amt    OUT NOCOPY number,
                        p_err_code    OUT NOCOPY VARCHAR2) is
  --
  cursor c_get_util(pc1_currency  VARCHAR2) is
   SELECT nvl(mc.net_fx_exposure,0), nvl(mc.utilised_amount,0)
   FROM xtr_master_currencies mc
   WHERE mc.authorised = 'Y'
   AND (mc.net_fx_exposure <> 0 OR mc.utilised_amount <> 0)
/* bug 1289530 limit check should be done for home ccy
   AND mc.currency <> (SELECT max(param_value)
			FROM xtr_pro_param p
			WHERE p.param_name='SYSTEM_FUNCTIONAL_CCY')
   bug 1289530 */
   AND mc.currency = p_currency;
  --
  cursor c_ok_to_do (pc3_param_name VARCHAR2) is
   select nvl(param_value,'Y')
    from XTR_PRO_PARAM
    where param_name = pc3_param_name;
  --
  v_ok_to_do     VARCHAR2(2);
  v_auth         VARCHAR2(1);
  v_used_amt     NUMBER;
--
begin
  p_err_code := null;
  open c_ok_to_do('LIMIT_CHECK_CCY');
   fetch c_ok_to_do into v_ok_to_do;
  if c_ok_to_do%NOTFOUND then
   v_ok_to_do := 'Y';
  end if;
  close c_ok_to_do;
  --
  if v_ok_to_do = 'Y' then
   open c_get_util(p_currency);
    fetch c_get_util into p_limit_amt,v_used_amt;
   if c_get_util%NOTFOUND then
    close c_get_util;
    p_util_amt := 0;
    raise ex_auth_not_y;
   end if;
   close c_get_util;
   p_util_amt := v_used_amt;
  end if;
 EXCEPTION
  WHEN ex_no_limit_exists then p_err_code := 'NO_LIMIT';
  WHEN ex_auth_not_y      then p_err_code := 'NO_AUTHO';
end;
---------------------------------------------------------------
PROCEDURE MAINTAIN_EXCESS_LOG( p_log_id  NUMBER,
                               p_action  VARCHAR2,
                               p_user    VARCHAR2 ) is
--
begin
if p_action = 'D' then
 delete from XTR_LIMIT_EXCESS_LOG
  where LOG_ID = p_log_id;
elsif p_action = 'A' then
 update XTR_LIMIT_EXCESS_LOG
  set AUTHORISED_BY = p_user
  where LOG_ID = p_log_id;
end if;
---commit;
end;
---------------------------------------------------------------
-- Procedure to update all limits table with the most up-to-date information
--   from XTR_MIRROR_DDA_LIMIT_ROW_V
PROCEDURE reinitialize_limits (
	errbuf                  OUT NOCOPY VARCHAR2,
	retcode                 OUT NOCOPY NUMBER)  IS
BEGIN
  delete from xtr_MIRROR_DDA_LIM_ROW_TMP_V;
  --
  update xtr_COMPANY_LIMITS_V
   set UTILISED_AMOUNT = 0;
  update xtr_COUNTERPARTY_LIMITS_V
   set UTILISED_AMOUNT = 0;
  update xtr_MASTER_CURRENCIES_V
   set UTILISED_AMOUNT = 0;
  update xtr_COUNTRY_COMPANY_LIMITS_V
   set UTILISED_AMOUNT = 0;
  update xtr_GROUP_LIMITS_V
   set UTILISED_AMOUNT = 0;
  --
  -- Insert Trigger on MIRROR_DDA_LIMIT_ROW_TEMP will initialize all
  -- limits in above tables
  insert into xtr_MIRROR_DDA_LIM_ROW_TMP_V (
    DEAL_NUMBER,DEAL_TYPE,TRANSACTION_NUMBER,LIMIT_CODE,
    AMOUNT,HCE_AMOUNT,DATE_LAST_SET,PRODUCT_TYPE,COMPANY_CODE,
    LIMIT_PARTY,AMOUNT_DATE,DEALER_CODE,COUNTRY_CODE,
    DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,CURRENCY,
    UTILISED_AMOUNT,HCE_UTILISED_AMOUNT,CROSS_REF_TO_OTHER_PARTY,
    LIMIT_TYPE,COMMENCE_DATE,CURRENCY_COMBINATION,CONTRA_CCY,
    TRANSACTION_RATE,AMOUNT_INDIC,ACCOUNT_NO)
   select
    DEAL_NUMBER,DEAL_TYPE,TRANSACTION_NUMBER,LIMIT_CODE,
    AMOUNT,HCE_AMOUNT,DATE_LAST_SET,PRODUCT_TYPE,COMPANY_CODE,
    LIMIT_PARTY,AMOUNT_DATE,DEALER_CODE,COUNTRY_CODE,
    DEAL_SUBTYPE,PORTFOLIO_CODE,STATUS_CODE,CURRENCY,
    UTILISED_AMOUNT,HCE_UTILISED_AMOUNT,CROSS_REF_TO_OTHER_PARTY,
    LIMIT_TYPE,COMMENCE_DATE,CURRENCY_COMBINATION,CONTRA_CCY,
    TRANSACTION_RATE,AMOUNT_INDIC,ACCOUNT_NO
    from xtr_MIRROR_DDA_LIMIT_ROW_V;
  --
  delete from xtr_MIRROR_DDA_LIM_ROW_TMP_V;
END reinitialize_limits;
---------------------------------------------------------------
end XTR_LIMITS_P;

/
