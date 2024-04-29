--------------------------------------------------------
--  DDL for Package Body IEX_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_PROFILE" AS
/* $Header: iexrcntb.pls 120.16.12010000.6 2009/08/19 11:01:38 barathsr ship $ */
G_PKG_NAME   CONSTANT VARCHAR2(30)  := 'IEX_PROFILE';
G_FILE_NAME    CONSTANT VARCHAR2(12) := 'iexrcntb.pls';
PG_DEBUG NUMBER;
g_line          varchar2(100);
TYPE curr_rec_type IS RECORD (
     set_of_books_id   ar_system_parameters.set_of_books_id%TYPE           ,
     base_currency     gl_sets_of_books.currency_code%TYPE                 ,
     past_year_from    DATE,
     past_year_to      DATE
  );

g_curr_rec curr_rec_type;
---------------------------------------------------------------------
-- Get_past_year_inv_info
--------------------------------------------------------------------
-- Queries Past year installment information. Called from
-- get_profile_info provedure.
---------------------------------------------------------------------
PROCEDURE Get_past_year_inv_info
  (p_filter_mode       IN  Varchar2,
   p_filter_id         IN  Number,
   p_using_paying_rel  IN VARCHAR2,
   p_total_inv         OUT NOCOPY Number,
   p_unpaid_inv        OUT NOCOPY Number,
   p_ontime_inv        OUT NOCOPY Number,
   p_late_inv          OUT NOCOPY Number,
   p_error_msg         OUT NOCOPY Varchar2)
IS
BEGIN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(g_line) ;
    IEX_DEBUG_PUB.LogMessage('GET_PAST_YEAR_INV_INFO --->>  Start <<--- ') ;
    IEX_DEBUG_PUB.LogMessage(g_line) ;
  END IF;

  --------------------------------------------------------------
  --  Past Year Unpaid Installments
  --------------------------------------------------------------
  if p_filter_mode = 'PARTY' then
    BEGIN
      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
        SELECT  SUM(DECODE(aps.status, 'OP', 1, 0)), -- Unpaid Installments
                SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 0, 1), 0)), -- On time Installments
                SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 1, 0), 0)) -- Late Installements
        INTO    p_unpaid_inv,
                p_ontime_inv,
                p_late_inv
        from    ar_payment_schedules aps,
                hz_cust_accounts     hzca
        where  aps.customer_id = hzca.cust_account_id
        and    aps.class IN ('INV', 'DM', 'CB')
        and    aps.due_date between g_curr_rec.past_year_from and g_curr_rec.past_year_to
        and    hzca.party_id IN
                            (SELECT p_filter_id FROM dual
                              UNION
                             SELECT ar.related_party_id
                               FROM ar_paying_relationships_v ar
                              WHERE ar.party_id = p_filter_id
                                AND TRUNC(sysdate) BETWEEN
                                    TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                    TRUNC(NVL(ar.effective_end_date,sysdate))  );
      ELSE
        SELECT  SUM(DECODE(aps.status, 'OP', 1, 0)), -- Unpaid Installments
                SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 0, 1), 0)), -- On time Installments
                SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 1, 0), 0)) -- Late Installements
        INTO    p_unpaid_inv,
                p_ontime_inv,
                p_late_inv
        from    ar_payment_schedules aps,
                hz_cust_accounts     hzca
        where  aps.customer_id = hzca.cust_account_id
        and    aps.class IN ('INV', 'DM', 'CB')
        and    aps.due_date between g_curr_rec.past_year_from and g_curr_rec.past_year_to
        and    hzca.party_id = p_filter_id ;

      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_msg :=
          'Get Past Year Invoice Info >> Party >> Unpaid Installments'
                                    || SQLCODE || ' << ' || SQLERRM ;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.logMessage(p_error_msg) ;
        END IF;
    End ;
  ELSIF p_filter_mode = 'CUST' then
    BEGIN
      SELECT  SUM(DECODE(aps.status, 'OP', 1, 0)), -- Unpaid Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 0, 1), 0)), -- On time Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 1, 0), 0)) -- Late Installements
      INTO    p_unpaid_inv,
              p_ontime_inv,
              p_late_inv
      from    ar_payment_schedules aps,
              hz_cust_accounts     hzca
      where   aps.customer_id = hzca.cust_account_id
      and     aps.class IN ('INV', 'DM', 'CB')
      and     aps.due_date between g_curr_rec.past_year_from and g_curr_rec.past_year_to
      and     hzca.cust_account_id = p_filter_id  ;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_msg :=
         'Get Past Year Invoice Info >> Cust >> Unpaid Installments'
                                    || SQLCODE || ' << ' || SQLERRM ;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage(p_error_msg) ;
        END IF;
    End ;

  ELSIF p_filter_mode = 'DEL' then  -- added by jypark
    BEGIN
      SELECT  SUM(DECODE(aps.status, 'OP', 1, 0)), -- Unpaid Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 0, 1), 0)), -- On time Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 1, 0), 0)) -- Late Installements
      INTO    p_unpaid_inv,
              p_ontime_inv,
              p_late_inv
      from    ar_payment_schedules aps,
              iex_delinquencies del
      where   aps.class IN ('INV', 'DM', 'CB')
      and     aps.due_date between g_curr_rec.past_year_from and g_curr_rec.past_year_to
      and     del.payment_schedule_id = aps.payment_schedule_id
      and     del.delinquency_id = p_filter_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_msg :=
         'Get Past Year Invoice Info >> Del >> Unpaid Installments'
                                    || SQLCODE || ' << ' || SQLERRM ;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage(p_error_msg) ;
        END IF;
    End ;
  ELSIF p_filter_mode = 'BILL_TO' then  -- added by jypark
    BEGIN
      SELECT  SUM(DECODE(aps.status, 'OP', 1, 0)), -- Unpaid Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 0, 1), 0)), -- On time Installments
              SUM(DECODE(aps.status, 'CL', DECODE(SIGN(aps.actual_date_closed - aps.due_date), 1, 1, 0), 0)) -- Late Installements
      INTO    p_unpaid_inv,
              p_ontime_inv,
              p_late_inv
      from    ar_payment_schedules aps
      where   aps.class IN ('INV', 'DM', 'CB')
      and     aps.due_date between g_curr_rec.past_year_from and g_curr_rec.past_year_to
      and     aps.customer_site_use_id = p_filter_id;
    EXCEPTION
      WHEN OTHERS THEN
        p_error_msg :=
          'Get Past Year Invoice Info >> Del >> Unpaid Installments'
                                    || SQLCODE || ' << ' || SQLERRM ;
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
          iex_debug_pub.logMessage(p_error_msg) ;
        END IF;
    End ;

  End If ;

  -- Calculating Total Transactions (Sum of Unpaid, Late and Ontime)
  p_total_inv := p_unpaid_inv + p_late_inv + p_ontime_inv ;
  p_error_msg := null ;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage(g_line) ;
    IEX_DEBUG_PUB.LogMessage('GET_PAST_YEAR_INV_INFO --->>  End <<--- ') ;
    IEX_DEBUG_PUB.LogMessage(g_line) ;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_error_msg := 'Get Past Year Invoice Info >> ' || SQLCODE || ' << ' || SQLERRM ;
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logMessage(p_error_msg) ;
    END IF;
End Get_past_year_inv_info;

------------------------------------------------------------------------------
--   PROCEDURE GET_PROFILE_INFO
------------------------------------------------------------------------------
-- IEX/AST 1) Total Promises, Broken Promises, Open Promises
--      2) Credit Limit, Credit Rating, Credit Status, Collector Name
--       3) Outcome, Last Contact Date, Contacted By, Result
--
------------------------------------------------------------------------------
PROCEDURE GET_PROFILE_INFO
  (p_api_version      IN  NUMBER,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_calling_app    IN  VARCHAR2,
   p_filter_mode      IN   VARCHAR2  ,
   p_Party_id      IN  Number,
   p_cust_account_id  IN  Number,
   p_delinquency_id   IN  Number,  -- added by jypark
   p_customer_site_use_id IN Number,  -- added by jypark for Bill-to
   p_using_paying_rel IN VARCHAR2,
   x_profile_rec    OUT NOCOPY Profile_Rec)
IS
  l_api_version     CONSTANT   NUMBER :=  1.0;
  l_api_name        CONSTANT   VARCHAR2(30) :=  'GET_PROFILE_INFO';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(32767);
  l_Profile_rec Profile_rec ;

  v_msg_data  Varchar2(100)  ;
  v_return_status Varchar2(100)  ;
  v_msg_count  Number  ;

  v_profile_sql   Varchar2(5000) ;
  v_profile_sql2   Varchar2(5000) ;
  v_profile_sql_late Varchar2(5000) ;
  v_profile_where   Varchar2(200) ;
  v_profile_filter_id Number  ;
  v_apply_date_filter varchar2(200) ;

  l_filter_id         Number ;
  l_error_msg         varchar2(2000)  ;

  l_today             date;
  start_date_time_val date;--Added for Bug 8200476 16-Jul-2009 barathsr


-- START BUG 5187355 scherkas 07/27/2006
-- START BUG 6529958 gnramasa 7th mar 2008
  CURSOR PARTY_INT_CUR(p_party_id Number)
  IS
--  SELECT JIOV.short_description outcome,
--   jii.start_date_time s_date,
--   JRREV.resource_Name res_name,
--   JIRV.short_description result
--  FROM   JTF_IH_INTERACTIONS JII,
--         JTF_RS_RESOURCE_EXTNS_VL JRREV,
--         JTF_IH_OUTCOMES_VL JIOV,
--         JTF_IH_RESULTS_VL JIRV
--  WHERE   JII.resource_id    = JRREV.resource_id
--  AND JIOV.Outcome_id    = JII.outcome_id
--  AND     JIRV.Result_id(+)  = JII.result_id
--  AND     JII.Party_Id     = p_Party_id
--  AND     JII.start_date_time =  (select Max(i.start_date_time)
--                                  from   jtf_ih_interactions i
--                                  where  i.party_id = jii.party_id) ;

  SELECT JIOV.short_description outcome,
   jii.start_date_time s_date,
   JRREV.resource_Name res_name,
   JIRV.short_description result
  FROM   JTF_IH_INTERACTIONS JII,
         JTF_RS_RESOURCE_EXTNS_TL JRREV,
         JTF_IH_OUTCOMES_TL JIOV,
         JTF_IH_RESULTS_TL JIRV
  WHERE   JII.resource_id    = JRREV.resource_id
  AND JRREV.LANGUAGE (+)= USERENV('LANG')
  AND JIOV.Outcome_id    = JII.outcome_id
  AND JIOV.LANGUAGE (+)= USERENV('LANG')
  AND     JIRV.Result_id(+)  = JII.result_id
  AND     JIRV.LANGUAGE (+)= USERENV('LANG')
  AND     JII.Party_Id     = p_party_id
  AND     JII.start_date_time =  (select Max(i.start_date_time)
                                  from   jtf_ih_interactions i
                                  where  i.party_id = jii.party_id) ;
-- END BUG 5187355 scherkas 07/27/2006


--Begin Bug 8200476 16-Jul-2009 barathsr

 cursor cust_int_get_dt30_cur(cust_acct_id number)
 is
 SELECT
         /*+ leading(a) index(A JTF_IH_ACTIVITIES_N3) index(I JTF_IH_INTERACTIONS_CUS01)*/
         MAX(i.start_date_time)
         FROM    jtf_ih_interactions i,
                 jtf_ih_activities a
         WHERE  a.cust_account_id = cust_acct_id
 AND a.interaction_id  = i.interaction_id
 and i.start_date_time between (trunc(sysdate)-30) and sysdate;

 cursor cust_int_get_dt365_cur(cust_acct_id number)
 is
 SELECT
         /*+ leading(a) index(A JTF_IH_ACTIVITIES_N3) index(I JTF_IH_INTERACTIONS_CUS01)*/
         MAX(i.start_date_time)
         FROM    jtf_ih_interactions i,
                 jtf_ih_activities a
         WHERE  a.cust_account_id = cust_acct_id
 AND a.interaction_id  = i.interaction_id
 and i.start_date_time between (trunc(sysdate)-365) and sysdate;

 cursor cust_int_get_dt_cur(cust_acct_id number)
 is
 SELECT
         /*+ leading(a) index(A JTF_IH_ACTIVITIES_N3) index(I JTF_IH_INTERACTIONS_CUS01)*/
         MAX(i.start_date_time)
         FROM    jtf_ih_interactions i,
                 jtf_ih_activities a
         WHERE  a.cust_account_id = cust_acct_id
 AND a.interaction_id  = i.interaction_id;

   --End Bug 8200476 16-Jul-2009 barathsr

   CURSOR CUST_INT_CUR(cust_acct_id Number,date_time date) --Added for Bug 8200476 16-Jul-2009 barathsr
  IS
    SELECT
    /*+ index (jia JTF_IH_ACTIVITIES_N4) index(JII JTF_IH_INTERACTIONS_N6)*/   --Added for Bug 8200476 16-Jul-2009 barathsr
    DISTINCT JIOVT.short_description outcome,
                jii.start_date_time s_date     ,
                JRRES.source_Name res_name     ,
                JIRV.short_description result
 FROM            JTF_IH_INTERACTIONS JII    ,
                jtf_rs_resource_extns JRRES,
                JTF_IH_OUTCOMES_tl JIOVT   ,
                jtf_ih_outcomes_b jiovb    ,
                JTF_IH_RESULTS_tl JIRV     ,
                JTF_IH_ACTIVITIES JIA
 WHERE           JII.resource_id     = JRRES.resource_id
            AND jii.interaction_id  = jia.interaction_id
            AND jiovt.outcome_id    = jiovb.outcome_id
            AND JIOVB.Outcome_id(+) = JII.outcome_id
            AND JIRV.Result_id(+)   = JII.result_id
            AND jia.cust_account_id = cust_acct_id
            AND jiovt.language      = userenv('LANG')
            AND JII.start_date_time = date_time; --Added for Bug 8200476 16-Jul-2009 barathsr
              --Start of comment for Bug 8200476 16-Jul-2009 barathsr
	       -- (SELECT
             --           /*+ index(I JTF_IH_ACTIVITIES_N3)*/
            /*             MAX(i.start_date_time)
                FROM    jtf_ih_interactions i,
                        jtf_ih_activities a
                WHERE  a.cust_account_id = cust_acct_id
 AND a.interaction_id  = i.interaction_id);
 --End bug 7572544 16-Jan-2009 barathsr*/


 -- CURSOR CUST_INT_CUR(cust_acct_id Number)
 -- IS
-- START BUG 5187355 scherkas 07/27/2006

--  SELECT  DISTINCT JIOV.short_description outcome,
--    jii.start_date_time s_date,
--   JRREV.resource_Name res_name,
--   JIRV.short_description result
--  FROM   JTF_IH_INTERACTIONS JII,
--   JTF_RS_RESOURCE_EXTNS_VL JRREV,
--   JTF_IH_OUTCOMES_VL JIOV,
--START BUG 4930386 jsanju 01/10/06
   --JTF_IH_RESULTS_VL JIRV,
--   JTF_IH_RESULTS_B JIRB,
--   JTF_IH_RESULTS_TL JIRV,
--END BUG 4930386 jsanju 01/10/06
--   JTF_IH_ACTIVITIES_VL JIA
--  WHERE   JII.resource_id    = JRREV.resource_id
--  AND     jii.interaction_id = jia.interaction_id
--  AND JIOV.Outcome_id    = JII.outcome_id

--START BUG 4930386 jsanju 01/10/06
  --AND     JIRV.Result_id(+)  = JII.result_id
--  AND     JIRB.Result_id(+)  = JII.result_id
--  AND     JIRV.Result_id(+)    =JIRB.Result_id
--  AND     JIRV.LANGUAGE (+)= USERENV('LANG')
--END BUG 4930386 jsanju 01/10/06
--  AND     jia.cust_account_id = cust_acct_id
--  AND     JII.start_date_time =
--     (select Max(i.start_date_time)
--     from    jtf_ih_interactions i,
--      jtf_ih_activities a
--     where   a.cust_account_id = cust_acct_id
--     AND     a.interaction_id = i.interaction_id) ;

/*SELECT  DISTINCT JIOV.short_description outcome,
    jii.start_date_time s_date,
   JRREV.resource_Name res_name,
   JIRV.short_description result
  FROM   JTF_IH_INTERACTIONS JII,
   JTF_RS_RESOURCE_EXTNS_TL JRREV,
   JTF_IH_OUTCOMES_TL JIOV,
   JTF_IH_RESULTS_B JIRB,
   JTF_IH_RESULTS_TL JIRV,
   JTF_IH_ACTIVITIES JIA
  WHERE   JII.resource_id    = JRREV.resource_id
  AND JRREV.LANGUAGE (+)= USERENV('LANG')
  AND     jii.interaction_id = jia.interaction_id
  AND JIOV.Outcome_id    = JII.outcome_id
  AND JIOV.LANGUAGE (+)= USERENV('LANG')
  AND     JIRB.Result_id(+)  = JII.result_id
  AND     JIRV.Result_id(+)    =JIRB.Result_id
  AND     JIRV.LANGUAGE (+)= USERENV('LANG')
  AND     jia.cust_account_id = cust_acct_id
  AND     JII.start_date_time =
     (select Max(i.start_date_time)
     from    jtf_ih_interactions i,
      jtf_ih_activities a
     where   a.cust_account_id = cust_acct_id
     AND     a.interaction_id = i.interaction_id);*/
-- END BUG 5187355 scherkas 07/27/2006
--End of comment for Bug 8200476 16-Jul-2009 barathsr


  CURSOR PARTY_INT_PAYING_CUR(p_party_id Number)
  IS
-- START BUG 5187355 scherkas 07/27/2006
--  SELECT JIOV.short_description outcome,
--          jii.start_date_time s_date,
--          JRREV.resource_Name res_name,
--          JIRV.short_description result
--  FROM    JTF_IH_INTERACTIONS JII,
--          JTF_RS_RESOURCE_EXTNS_VL JRREV,
--          JTF_IH_OUTCOMES_VL JIOV,
--          JTF_IH_RESULTS_VL JIRV
--  WHERE   JII.resource_id    = JRREV.resource_id
--  AND     JIOV.Outcome_id    = JII.outcome_id
--  AND     JIRV.Result_id(+)  = JII.result_id
--  AND     JII.Party_Id       IN
--                      (SELECT p_party_id FROM dual
--                        UNION
--                       SELECT ar.related_party_id
--                         FROM ar_paying_relationships_v ar
--                        WHERE ar.party_id = p_party_id
--                          AND TRUNC(sysdate) BETWEEN
--                              TRUNC(NVL(ar.effective_start_date,sysdate)) AND
--                              TRUNC(NVL(ar.effective_end_date,sysdate))  )
--  AND     JII.start_date_time =  (select Max(i.start_date_time)
--                                  from   jtf_ih_interactions i
--                                  where  i.party_id = jii.party_id) ;

  SELECT JIOV.short_description outcome,
          jii.start_date_time s_date,
          JRREV.resource_Name res_name,
          JIRV.short_description result
  FROM    JTF_IH_INTERACTIONS JII,
          JTF_RS_RESOURCE_EXTNS_TL JRREV,
          JTF_IH_OUTCOMES_TL JIOV,
          JTF_IH_RESULTS_TL JIRV
  WHERE   JII.resource_id    = JRREV.resource_id
  AND     JRREV.LANGUAGE (+)= USERENV('LANG')
  AND     JIOV.Outcome_id    = JII.outcome_id
  AND     JIOV.LANGUAGE (+)= USERENV('LANG')
  AND     JIRV.Result_id(+)  = JII.result_id
  AND     JIRV.LANGUAGE (+)= USERENV('LANG')
  AND     JII.Party_Id       IN
                      (SELECT p_party_id FROM dual
                        UNION
                       SELECT ar.related_party_id
                         FROM ar_paying_relationships_v ar
                        WHERE ar.party_id = p_party_id
                          AND TRUNC(sysdate) BETWEEN
                              TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                              TRUNC(NVL(ar.effective_end_date,sysdate))  )
  AND     JII.start_date_time =  (select Max(i.start_date_time)
                                  from   jtf_ih_interactions i
                                  where  i.party_id = jii.party_id) ;
-- END BUG 5187355 scherkas 07/27/2006
-- END BUG 6529958 gnramasa 7th mar 2008


  CURSOR PARTY_CUSTOMER_PROFILE_CUR(p_party_id NUMBER)
  IS
  SELECT coll.name,
         arpt_sql_func_util.get_lookup_meaning('CREDIT_RATING', cust_prof.credit_rating)
  FROM hz_customer_profiles cust_prof, ar_collectors coll
  WHERE cust_prof.party_id = p_party_id
  AND coll.collector_id(+) = cust_prof.collector_id
  AND cust_prof.cust_account_id = -1;

  CURSOR CUST_CUSTOMER_PROFILE_CUR(p_cust_account_id NUMBER)
  IS
  SELECT coll.name,
         arpt_sql_func_util.get_lookup_meaning('CREDIT_RATING', cust_prof.credit_rating)
  FROM hz_customer_profiles cust_prof, ar_collectors coll
  WHERE cust_prof.cust_account_id = p_cust_account_id
  AND coll.collector_id(+) = cust_prof.collector_id
  AND cust_prof.site_use_id IS NULL;

  CURSOR SITE_CUSTOMER_PROFILE_CUR(p_customer_site_use_id NUMBER)
  IS
  SELECT coll.name,
         arpt_sql_func_util.get_lookup_meaning('CREDIT_RATING', cust_prof.credit_rating)
  FROM hz_customer_profiles cust_prof, ar_collectors coll
  WHERE cust_prof.site_use_id = p_customer_site_use_id
  AND coll.collector_id(+) = cust_prof.collector_id;

  CURSOR C_DEL(p_delinquency_id NUMBER)
  IS
  SELECT cust_account_id, customer_site_use_id
  FROM iex_delinquencies
  WHERE delinquency_id = p_delinquency_id;

  CURSOR C_SITE(p_customer_site_use_id NUMBER)
  IS
  SELECT cust_account_id
  FROM hz_cust_site_uses site_use, hz_cust_acct_sites acct_site
  WHERE site_use.site_use_id = p_customer_site_use_id
  AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id;

  l_cust_account_id NUMBER;
  l_customer_site_use_id NUMBER;
  l_credit_limit_amt_func NUMBER;
  -- Start for the bug 8630157 by PNAVEENK
  l_conversion_type VARCHAR(30);

  CURSOR C_PARTY_CREDIT(p_party_id NUMBER , p_conversion_type varchar2)
  IS
    -- Begin fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
          --  sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit))),
	      sysdate, p_conversion_type, prof_amt.overall_credit_limit))),
           DECODE(MAX(DECODE(prof.credit_hold, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           DECODE(MAX(DECODE(prof.dunning_letters, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           g_curr_rec.base_currency
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
       --  ar_cmgt_setup_options cm_opt
     WHERE prof.party_id = p_party_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       -- Begin fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist
       -- AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       -- AND prof_amt.cust_account_id = prof.cust_account_id
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id(+)
       AND prof_amt.cust_account_id(+) = prof.cust_account_id
       -- End fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist
       AND prof_amt.site_use_id IS NULL
       --Begin-fix bug#4610424-JYPARK-09/16/2005-exclude credir limit for account
       AND prof.cust_account_id = -1;
       --End-fix bug#4610424-JYPARK-09/16/2005-exclude credir limit for account

  CURSOR C_CUST_CREDIT(p_cust_account_id NUMBER , p_conversion_type varchar2)
  IS
    -- Begin fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
           --   sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit))),
                sysdate, p_conversion_type, prof_amt.overall_credit_limit))),
	   DECODE(MAX(DECODE(prof.credit_hold, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           DECODE(MAX(DECODE(prof.dunning_letters, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           g_curr_rec.base_currency
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
       --    ar_cmgt_setup_options cm_opt
     WHERE prof.cust_account_id = p_cust_account_id
       AND prof.site_use_id IS NULL
       AND prof.status = 'A'
       -- Begin fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist
       -- AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       -- AND prof_amt.cust_account_id = p_cust_account_id
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id(+)
       AND prof_amt.cust_account_id(+) = p_cust_account_id
       -- End fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist
       AND prof_amt.site_use_id IS NULL;

  CURSOR C_SITE_CREDIT(p_customer_site_use_id NUMBER , p_conversion_type varchar2)
  IS
    -- Begin fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
    --SELECT SUM(gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    SELECT SUM(DECODE(prof_amt.overall_credit_limit, NULL, NULL, gl_currency_api.convert_amount_sql(prof_amt.currency_code, g_curr_rec.base_currency,
    -- End fix bug #5685635-12/08/2006-return null when credit limits value is null instead of -2
          --    sysdate, cm_opt.default_exchange_rate_type, prof_amt.overall_credit_limit))),
                sysdate, p_conversion_type, prof_amt.overall_credit_limit))),
	   DECODE(MAX(DECODE(prof.credit_hold, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           DECODE(MAX(DECODE(prof.dunning_letters, 'Y', 1, 0)), 1, ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'Y'),  ARPT_SQL_FUNC_UTIL.GET_LOOKUP_MEANING('YES/NO', 'N')),
           g_curr_rec.base_currency
      FROM hz_customer_profiles prof, hz_cust_profile_amts prof_amt
        --  ar_cmgt_setup_options cm_opt
     WHERE prof.site_use_id = p_customer_site_use_id
       AND prof.status = 'A'
       -- Begin fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist
       -- AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id
       -- AND prof_amt.site_use_id = p_customer_site_use_id;
       AND prof.cust_account_profile_id = prof_amt.cust_account_profile_id(+)
       AND prof_amt.site_use_id(+) = p_customer_site_use_id;
       -- End fix bug #5194537-JYPARK-05/03/2006-add outer join when credit limit not exist


  l_credit_status NUMBER;
BEGIN
  l_conversion_type := NVL(FND_PROFILE.VALUE('IEX_EXCHANGE_RATE_TYPE'), 'Corporate');
  l_today             := TRUNC(sysdate) ;
  IF p_filter_mode = 'DEL' then
      l_filter_id := p_delinquency_id ;
  elsIF p_filter_mode = 'CUST' then
      l_filter_id := p_cust_account_id ;
  elsIF p_filter_mode = 'PARTY' then
      l_filter_id := p_party_id ;
  elsIF p_filter_mode = 'BILL_TO' then
      l_filter_id := p_customer_site_use_id ;
  END IF ;


  SAVEPOINT Get_Profile_Info_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Check p_init_msg_list
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --Bug4562698. Moved the Constructor to GET_PROFILE_INFO. Begin.
  Begin
  SELECT distinct sob.currency_code
    INTO   g_curr_rec.base_currency
    FROM   ar_system_parameters   sysp,
           gl_sets_of_books     sob
   WHERE  sob.set_of_books_id = sysp.set_of_books_id;
  Exception when others then
   g_curr_rec.base_currency := NULL;
  End;

  -- Past Year From and To
  SELECT  TRUNC(add_months(sysdate, - 12)) pastYearFrom ,
          TRUNC(sysdate) pastYearTo
    INTO  g_curr_rec.past_year_from,
          g_curr_rec.past_year_to
    FROM  dual;

  --Bug4562698. Moved the Constructor to GET_PROFILE_INFO. End.


  Get_past_year_inv_info(
      p_filter_mode   =>  p_filter_mode,
      p_filter_id     =>  l_filter_id,
      p_using_paying_rel => p_using_paying_rel,
      p_total_inv     =>  l_profile_rec.Installments_due,
      p_unpaid_inv    =>  l_profile_rec.Unpaid_Installments,
      p_ontime_inv    =>  l_profile_rec.Ontime_Installments,
      p_late_inv      =>  l_profile_rec.late_Installments,
      p_error_msg     =>  l_error_msg) ;

  BEGIN
     --------------------------------------------------------------
     --  Past Year Total Promises
     --------------------------------------------------------------
    IF p_filter_mode = 'PARTY' then
      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
        SELECT  COUNT(1),
           SUM(DECODE(IPD.STATE, 'BROKEN_PROMISE', 1, 0)),
           SUM(DECODE(IPD.STATUS, 'COLLECTABLE', 1, 'PENDING', 1, 'FULLFILLED', 1, 'IN_QUESTION', 1, 'OPEN', 1, 0))
        Into     l_profile_rec.Total_Promises,
                  l_profile_rec.Broken_Promises,
                  l_profile_rec.Open_Promises
        FROM     IEX_PROMISE_DETAILS  IPD,
                  HZ_CUST_ACCOUNTS   HZCA,
		  IEX_DELINQUENCIES  DEL -- Moac Change Added Delinquency
        WHERE    IPD.cust_account_id = HZCA.cust_Account_id
	AND      IPD.DELINQUENCY_ID = DEL.DELINQUENCY_ID
        AND      trunc(IPD.CREATION_DATE) BETWEEN g_curr_rec.past_year_from AND g_curr_rec.past_year_to
        AND      HZCA.Party_id IN
                           (SELECT p_party_id FROM dual
                             UNION
                            SELECT ar.related_party_id
                              FROM ar_paying_relationships_v ar
                             WHERE ar.party_id = p_party_id
                               AND TRUNC(sysdate) BETWEEN
                                   TRUNC(NVL(ar.effective_start_date,sysdate)) AND
                                   TRUNC(NVL(ar.effective_end_date,sysdate))  );
      ELSE
        SELECT  COUNT(1),
           SUM(DECODE(IPD.STATE, 'BROKEN_PROMISE', 1, 0)),
           SUM(DECODE(IPD.STATUS, 'COLLECTABLE', 1, 'PENDING', 1, 'FULLFILLED', 1, 'IN_QUESTION', 1, 'OPEN', 1, 0))
        Into     l_profile_rec.Total_Promises,
                  l_profile_rec.Broken_Promises,
                  l_profile_rec.Open_Promises
        FROM     IEX_PROMISE_DETAILS  IPD,
                  HZ_CUST_ACCOUNTS   HZCA,
  		  IEX_DELINQUENCIES  DEL
        WHERE    IPD.cust_account_id = HZCA.cust_Account_id
	AND      IPD.DELINQUENCY_ID = DEL.DELINQUENCY_ID
        AND      trunc(IPD.CREATION_DATE) BETWEEN g_curr_rec.past_year_from AND g_curr_rec.past_year_to
        AND      HZCA.Party_id = p_party_id ;
      END IF;

    ELSIF p_filter_mode = 'CUST' then
      SELECT  COUNT(1),
           SUM(DECODE(IPD.STATE, 'BROKEN_PROMISE', 1, 0)),
           SUM(DECODE(IPD.STATUS, 'COLLECTABLE', 1, 'PENDING', 1, 'FULLFILLED', 1, 'IN_QUESTION', 1, 'OPEN', 1, 0))
      Into     l_profile_rec.Total_Promises,
               l_profile_rec.Broken_Promises,
               l_profile_rec.Open_Promises
      FROM     IEX_PROMISE_DETAILS  IPD,
               HZ_CUST_ACCOUNTS   HZCA,
    	       IEX_DELINQUENCIES  DEL -- Moac Change Added Delinquency
      WHERE    IPD.cust_account_id = HZCA.cust_Account_id
      AND      IPD.DELINQUENCY_ID = DEL.DELINQUENCY_ID
      AND      trunc(IPD.CREATION_DATE) BETWEEN g_curr_rec.past_year_from AND g_curr_rec.past_year_to
      AND      HZCA.cust_account_id = p_cust_account_id ;

    ELSIF p_filter_mode = 'DEL' then   -- added by jypark
      SELECT  COUNT(1),
           SUM(DECODE(IPD.STATE, 'BROKEN_PROMISE', 1, 0)),
           SUM(DECODE(IPD.STATUS, 'COLLECTABLE', 1, 'PENDING', 1, 'FULLFILLED', 1, 'IN_QUESTION', 1, 'OPEN', 1, 0))
      Into     l_profile_rec.Total_Promises,
               l_profile_rec.Broken_Promises,
               l_profile_rec.Open_Promises
      FROM     IEX_PROMISE_DETAILS  IPD
      WHERE    trunc(IPD.CREATION_DATE) BETWEEN g_curr_rec.past_year_from AND g_curr_rec.past_year_to
        AND IPD.delinquency_id = p_delinquency_id;

    ELSIF p_filter_mode = 'BILL_TO' then   -- added by jypark
      SELECT  COUNT(1),
           SUM(DECODE(IPD.STATE, 'BROKEN_PROMISE', 1, 0)),
           SUM(DECODE(IPD.STATUS, 'COLLECTABLE', 1, 'PENDING', 1, 'FULLFILLED', 1, 'IN_QUESTION', 1, 'OPEN', 1, 0))
      Into     l_profile_rec.Total_Promises,
               l_profile_rec.Broken_Promises,
               l_profile_rec.Open_Promises
      FROM     IEX_PROMISE_DETAILS        IPD,
               IEX_DELINQUENCIES DEL
      WHERE    trunc(IPD.CREATION_DATE) BETWEEN g_curr_rec.past_year_from AND g_curr_rec.past_year_to
      AND IPD.delinquency_id = DEL.delinquency_id
      AND DEL.customer_site_use_id = p_customer_site_use_id;

    END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('Unexpected Error:C_CUSTOMER_PROFILE_CUR - ' || SQLCODE || ' Mesg - ' || SQLERRM) ;
      END IF;
      ROLLBACK TO Get_Profile_Info_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END ;

  BEGIN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Filter Mode = ' || p_Filter_mode || ' party_id = ' || to_char(p_party_id) || ' cust_account_id =  ' || to_char(p_cust_account_id) );
      IEX_DEBUG_PUB.LogMessage(' delinquency_id = ' || to_char(p_delinquency_id) || ' customer_site_use_id= ' || to_char(p_customer_site_use_id)) ;
    END IF;

    IF p_filter_mode = 'PARTY' then
      IF NVL(p_using_paying_rel, 'N') = 'Y' THEN
        OPEN PARTY_INT_PAYING_CUR(p_party_id) ;
        FETCH PARTY_INT_PAYING_CUR INTO
          l_profile_rec.Last_Outcome  ,
          l_profile_rec.last_contact_date ,
          l_profile_rec.Last_Contacted_By ,
          l_profile_rec.Last_Result  ;
        CLOSE PARTY_INT_PAYING_CUR ;

      ELSE
        OPEN PARTY_INT_CUR(p_party_id) ;
        FETCH PARTY_INT_CUR INTO
          l_profile_rec.Last_Outcome  ,
          l_profile_rec.last_contact_date ,
          l_profile_rec.Last_Contacted_By ,
          l_profile_rec.Last_Result  ;
        CLOSE PARTY_INT_CUR ;
      END IF;
    ELSIF p_filter_mode = 'CUST' then
    --Begin Bug 8200476 16-Jul-2009 barathsr
    --Added Begin-End block for Bug 8811872 19-Aug-2009 barathsr
    begin
    open cust_int_get_dt30_cur(p_cust_account_id);
    fetch cust_int_get_dt30_cur into
          start_date_time_val;
      if (cust_int_get_dt30_cur%notfound or start_date_time_val is null) then
        open cust_int_get_dt365_cur(p_cust_account_id);
	fetch cust_int_get_dt365_cur into
              start_date_time_val;
          if (cust_int_get_dt365_cur%notfound or start_date_time_val is null) then
            open cust_int_get_dt_cur(p_cust_account_id);
	    fetch cust_int_get_dt_cur into
                 start_date_time_val;
              if (cust_int_get_dt_cur%notfound or start_date_time_val is null) then
	      IEX_DEBUG_PUB.LogMessage('no values to fetch');
                 IEX_DEBUG_PUB.LogMessage('error in fetching values in date_time_cursor');
              end if;
            close cust_int_get_dt_cur;
         end if;
       close cust_int_get_dt365_cur;
      end if;
    close cust_int_get_dt30_cur;
    --End Bug 8200476 16-Jul-2009 barathsr

      OPEN CUST_INT_CUR(p_cust_Account_id,start_date_time_val);--Added for Bug 8200476 16-Jul-2009 barathsr
      FETCH CUST_INT_CUR INTO
        l_profile_rec.Last_Outcome  ,
        l_profile_rec.last_contact_date ,
        l_profile_rec.Last_Contacted_By ,
        l_profile_rec.Last_Result;
      CLOSE CUST_INT_CUR  ;
      exception
      when others then
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('Unexpected Error:CUST_INT_CUR - ' || SQLCODE || ' Mesg - ' || SQLERRM) ;
      END IF;
      end;

    ELSIF p_filter_mode = 'DEL' then
      OPEN C_DEL(p_delinquency_id);
      FETCH C_DEL INTO l_cust_account_id, l_customer_site_use_id;
      CLOSE C_DEL;

      OPEN CUST_INT_CUR(l_cust_account_id,start_date_time_val);--Added for Bug 8200476 16-Jul-2009 barathsr      -- added by jypark but no delinquency dependency
      FETCH CUST_INT_CUR INTO
        l_profile_rec.Last_Outcome  ,
        l_profile_rec.last_contact_date ,
        l_profile_rec.Last_Contacted_By ,
        l_profile_rec.Last_Result  ;
    ELSIF p_filter_mode = 'BILL_TO' then
      OPEN C_SITE(p_customer_site_use_id);
      FETCH C_SITE INTO l_cust_account_id;
      CLOSE C_SITE;

      OPEN CUST_INT_CUR(l_cust_account_id,start_date_time_val);--Added for Bug 8200476 16-Jul-2009 barathsr     -- added by jypark but no delinquency dependency
      FETCH CUST_INT_CUR INTO
        l_profile_rec.Last_Outcome          ,
        l_profile_rec.last_contact_date     ,
        l_profile_rec.Last_Contacted_By     ,
        l_profile_rec.Last_Result     ;
      CLOSE CUST_INT_CUR;
    END IF ;
     IEX_DEBUG_PUB.LogMessage ( ' Entered in profile check block');
    IF p_filter_mode = 'PARTY' then
      IEX_DEBUG_PUB.LogMessage ( 'Entered in PARTY_CUSTOMER_PROFILE_CUR');
      OPEN PARTY_CUSTOMER_PROFILE_CUR(p_party_id);
      FETCH PARTY_CUSTOMER_PROFILE_CUR INTO l_profile_rec.collector_name, l_profile_rec.credit_rating;
      CLOSE PARTY_CUSTOMER_PROFILE_CUR;
    ELSIF p_filter_mode = 'CUST' then
      IEX_DEBUG_PUB.LogMessage ( 'Entered in CUST_CUSTOMER_PROFILE_CUR');
      OPEN CUST_CUSTOMER_PROFILE_CUR(p_cust_account_id);
      FETCH CUST_CUSTOMER_PROFILE_CUR INTO l_profile_rec.collector_name, l_profile_rec.credit_rating;
      CLOSE CUST_CUSTOMER_PROFILE_CUR;
    ELSIF p_filter_mode = 'BILL_TO' then
      IEX_DEBUG_PUB.LogMessage ( 'Entered in SITE_CUSTOMER_PROFILE_CUR');
      OPEN SITE_CUSTOMER_PROFILE_CUR(p_customer_site_use_id);
      FETCH SITE_CUSTOMER_PROFILE_CUR INTO l_profile_rec.collector_name, l_profile_rec.credit_rating;
      CLOSE SITE_CUSTOMER_PROFILE_CUR;
    ELSIF p_filter_mode= 'DEL' then
      IF l_customer_site_use_id IS NOT NULL THEN
        IEX_DEBUG_PUB.LogMessage ( 'Entered in SITE_CUSTOMER_PROFILE_CUR');
        OPEN SITE_CUSTOMER_PROFILE_CUR(l_customer_site_use_id);
        FETCH SITE_CUSTOMER_PROFILE_CUR INTO l_profile_rec.collector_name, l_profile_rec.credit_rating;
        CLOSE SITE_CUSTOMER_PROFILE_CUR;
      END IF;
    END IF ;


  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('Unexpected Error:C_CUSTOMER_PROFILE_CUR - ' || SQLCODE || ' Mesg - ' || SQLERRM) ;
      END IF;
      ROLLBACK TO Get_Profile_Info_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END ;

  BEGIN

-- Begin -- bug#4300281 - 15/4/2005 - vaijayanthi - Calculate 'Include Dunning' value based on Filter Mode
  IEX_DEBUG_PUB.LogMessage ( ' Enterd in credit limit calculation block');

IF p_filter_mode='PARTY' THEN  -- Party Level
  IEX_DEBUG_PUB.LogMessage ( 'Entered in c_party_credit');
OPEN c_party_credit(p_party_id , l_conversion_type);
    FETCH c_party_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_party_credit;
ELSIF p_filter_mode='CUST' THEN  -- Account Level
 IEX_DEBUG_PUB.LogMessage ( 'Entered in c_cust_credit');
  OPEN c_cust_credit(p_cust_account_id , l_conversion_type);
    FETCH c_cust_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_cust_credit;
ELSIF p_filter_mode='BILL_TO' THEN  -- Bill to Level
    OPEN c_site_credit(p_customer_site_use_id , l_conversion_type);
    FETCH c_site_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_site_credit;
END IF;


IEX_DEBUG_PUB.LogMessage('Credit limit amount of cust_account_id =  ' || to_char(p_cust_account_id) || 'is ' || l_profile_rec.credit_limit_amt);
IEX_DEBUG_PUB.LogMessage('Credit Status of cust_account_id =  ' || to_char(p_cust_account_id) || 'is ' || l_profile_rec.credit_status);
IEX_DEBUG_PUB.LogMessage('Include dunning of cust_account_id =  ' || to_char(p_cust_account_id) || 'is ' || l_profile_rec.include_dunning);
IEX_DEBUG_PUB.LogMessage('Credit amount currency of cust_account_id =  ' || to_char(p_cust_account_id) || 'is ' || l_profile_rec.credit_limit_amt_curr);

-- End for the bug 8630157 by PNAVEENK
--Bug4562698. Null out the Amount if the currency code is null. Start
IF g_curr_rec.base_currency IS NULL THEN
   l_profile_rec.credit_limit_amt := NULL;
END IF;
--Bug4562698. Null out the Amount if the currency code is null. End.

/* -- Old Code
  IF p_party_id IS NOT NULL THEN
    OPEN c_party_credit(p_party_id);
    FETCH c_party_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_party_credit;
  ELSIF p_cust_account_id IS NOT NULL THEN
    OPEN c_cust_credit(p_cust_account_id);
    FETCH c_cust_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_cust_credit;
  ELSIF p_customer_site_use_id IS NOT NULL THEN
    OPEN c_site_credit(p_customer_site_use_id);
    FETCH c_site_credit
      INTO l_profile_rec.credit_limit_amt, l_profile_rec.credit_status, l_profile_rec.include_dunning, l_profile_rec.credit_limit_amt_curr;
    CLOSE c_site_credit;
  END IF; */

-- end -- bug#4300281 - 15/4/2005 - vaijayanthi - Calculate 'Include Dunning' value based on Filter Mode

  EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        IEX_DEBUG_PUB.LogMessage('Unexpected Error:C_CREDIT - ' || SQLCODE || ' Mesg - ' || SQLERRM) ;

      END IF;
      ROLLBACK TO Get_Profile_Info_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  END;

  x_profile_rec := l_profile_rec ;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count AND IF count is 1, get message info
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_Profile_Info_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_Profile_Info_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Get_Profile_Info_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END GET_PROFILE_INFO;

BEGIN
  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_line := '-----------------------------------------' ;
--Bug4562698. Moved the Constructor to GET_PROFILE_INFO. Begin
/*  SELECT sob.currency_code
    INTO   g_curr_rec.base_currency
    FROM   ar_system_parameters   sysp,
           gl_sets_of_books     sob
   WHERE  sob.set_of_books_id = sysp.set_of_books_id;

  -- Past Year From and To
  SELECT  TRUNC(add_months(sysdate, - 12)) pastYearFrom ,
          TRUNC(sysdate) pastYearTo
    INTO  g_curr_rec.past_year_from,
          g_curr_rec.past_year_to
    FROM  dual; */
 --Bug4562698. Moved the Constructor to GET_PROFILE_INFO. Begin

END IEX_PROFILE;

/
