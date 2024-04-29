--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_EMB_EQTY_ANAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_EMB_EQTY_ANAL" AS
/* $Header: hrioembeanl.pkb 120.3.12000000.2 2007/04/16 06:27:48 vjaganat noship $ */


g_schema              VARCHAR2(50) := 'APPS';

g_rtn                VARCHAR2(30) := '
';
g_curr_conv_rate_type VARCHAR2(20) := 'Corporate';
g_return_success      VARCHAR2(1000)
:= 'SUCCESS:'||'DATA_LAST_UPDATE_DATE='
 || get_last_updated_date_msg(get_mv_last_refresh_date('HRI_MDP_SUP_WRKFC_JX_MV'));

g_your_org_msg_lbl    VARCHAR2(100)
    := REPLACE(fnd_message.get_string('HRI','HRI_407307_YOUR_ORGANIZATION'),'''','''''');
g_company_msg_lbl     VARCHAR2(100)
    := REPLACE(fnd_message.get_string('HRI','HRI_407312_COMPANY'),'''','''''');
g_mgrs_org_msg_lbl VARCHAR2(100)
    := REPLACE(fnd_message.get_string('HRI','HRI_407317_MANAGERS_ORG'),'''','''''');

g_sal_amount_fmt      VARCHAR2(100) := 'FM999,999,999,999';


/*
** Returns the data a single materialized view was last refreshed
**/
FUNCTION get_mv_last_refresh_date (p_mv_name IN VARCHAR2) RETURN DATE
IS

l_mv_last_refresh_date DATE:= SYSDATE;

CURSOR cur_mv_refresh_date IS
SELECT last_refresh_date
FROM dba_mviews
WHERE mview_name = p_mv_name
AND owner = g_schema ;


BEGIN

    OPEN cur_mv_refresh_date;
    FETCH cur_mv_refresh_date INTO l_mv_last_refresh_date;
    CLOSE cur_mv_refresh_date;

    RETURN l_mv_last_refresh_date;

EXCEPTION WHEN OTHERS THEN
    IF cur_mv_refresh_date%ISOPEN THEN
       CLOSE cur_mv_refresh_date;
    END IF;
    RETURN SYSDATE;

END get_mv_last_refresh_date;

/* returns a translated string of the form:
** "Data Last Updated: DD-MON-YYYY"
**/
FUNCTION get_last_updated_date_msg (p_date_token DATE) RETURN VARCHAR2
IS
BEGIN
    fnd_message.set_name('BIS', 'BIS_PMV_LAST_UPDATE_DATE');
    fnd_message.set_token('LAST_UPD_DATE', fnd_date.date_to_chardate(p_date_token));

    RETURN fnd_message.get;
END get_last_updated_date_msg;


FUNCTION check_mgr_is_above_in_hrchy(p_top_mgr_person_id    IN NUMBER
                                    ,p_lower_mgr_person_id  IN NUMBER
                                    ,p_effective_date       IN DATE)
RETURN BOOLEAN
IS

CURSOR cur_sup_chk IS
SELECT 1
FROM hri_cs_suph suph
WHERE trunc(p_effective_date) BETWEEN suph.effective_start_date AND effective_end_date
AND suph.sup_person_id = p_top_mgr_person_id
AND suph.sub_person_id = p_lower_mgr_person_id
AND suph.sub_invalid_flag_code = 'N';

l_sup_chk NUMBER;

BEGIN

    IF (p_top_mgr_person_id = p_lower_mgr_person_id) THEN
       RETURN TRUE;
    END IF;

    IF (   p_top_mgr_person_id IS NULL
        OR p_lower_mgr_person_id IS NULL
        OR p_effective_date IS NULL) THEN
      RETURN FALSE;
    END IF;

    OPEN cur_sup_chk;
    FETCH cur_sup_chk INTO l_sup_chk;

    IF cur_sup_chk%FOUND THEN
      IF cur_sup_chk%ISOPEN THEN
         CLOSE cur_sup_chk;
      END IF;
      RETURN TRUE;

    ELSE
      IF cur_sup_chk%ISOPEN THEN
         CLOSE cur_sup_chk;
      END IF;
      RETURN FALSE;

    END IF;

EXCEPTION WHEN OTHERS THEN
    IF cur_sup_chk%ISOPEN THEN
       CLOSE cur_sup_chk;
    END IF;
    RETURN FALSE;

END check_mgr_is_above_in_hrchy;


/* Return, based on the parameter context, the summary table/MV name
**
** Hardcoded to a new MV in first version
**
*/
PROCEDURE get_wrkfc_fact_table(
           p_parameter_rec  IN HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE
          ,o_sql_string     OUT NOCOPY VARCHAR2
          ,o_return_status  OUT NOCOPY VARCHAR2)
IS

BEGIN

    o_sql_string := 'HRI_MDP_SUP_WRKFC_JX_MV';
    o_return_status := g_return_success;

EXCEPTION WHEN OTHERS THEN
    o_return_status := 'EXCEPTION: ' || SUBSTRB(SQLERRM,50);
END get_wrkfc_fact_table; -- procedure

/* function call to get_wrkfc_fact_table procedure */
FUNCTION get_wrkfc_fact_table(p_parameter_rec  IN HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE)
RETURN VARCHAR2
IS

l_return_status VARCHAR2(1000);
l_table_name    VARCHAR2(32);

BEGIN
    GET_WRKFC_FACT_TABLE(
           p_parameter_rec  => p_parameter_rec
          ,o_sql_string     => l_table_name
          ,o_return_status  => l_return_status);

    IF l_return_status = g_return_success THEN
        RETURN l_table_name;
    ELSE
        RETURN 'unknown_fact_table';
    END IF;

EXCEPTION WHEN OTHERS THEN
   RETURN 'unknown_fact_table';

END get_wrkfc_fact_table; -- function



PROCEDURE get_wrkfc_fact_sql(
           p_parameter_rec  IN HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE
          ,o_sql_string     OUT NOCOPY VARCHAR2
          ,o_return_status  OUT NOCOPY VARCHAR2)
IS

l_sql_statement VARCHAR2(32000);

l_wrkfc_fact_table VARCHAR2(32);

BEGIN

    /* generate the list of fact columns and measures */
    l_sql_statement :=
    'SELECT' || g_rtn ||
    'SUPERVISOR_PERSON_ID' || '   SUPERVISOR_PERSON_ID' ||  g_rtn ||
    ',JOB_ID'              || '   JOB_ID'   || g_rtn ||
    ',''' || p_parameter_rec.currency_code_to || '''' || '   SAL_CURRENCY_CODE'|| g_rtn ||
    ',SUM(fact.total_headcount)   TOTAL_HEADCOUNT' || g_rtn ||
    ',MIN(hri_oltp_view_currency.convert_currency_amount(
            fact.anl_slry_currency,
            ''' || p_parameter_rec.currency_code_to || ''',
            to_date(''' || p_parameter_rec.effective_date || ''',''MM/DD/YYYY''),
            fact.min_anl_slry,
            '''||g_curr_conv_rate_type||'''))  MIN_ANL_SLRY'|| g_rtn ||
    ',MAX(hri_oltp_view_currency.convert_currency_amount(
            fact.anl_slry_currency,
            ''' || p_parameter_rec.currency_code_to || ''',
            to_date(''' || p_parameter_rec.effective_date || ''',''MM/DD/YYYY''),
            fact.max_anl_slry,
            '''||g_curr_conv_rate_type||'''))  MAX_ANL_SLRY'|| g_rtn ||
    ',SUM(hri_oltp_view_currency.convert_currency_amount(
            fact.anl_slry_currency,
            ''' || p_parameter_rec.currency_code_to || ''',
            to_date(''' || p_parameter_rec.effective_date || ''',''MM/DD/YYYY''),
            fact.total_anl_slry,
            '''||g_curr_conv_rate_type||'''))  TOTAL_ANL_SLRY' || g_rtn ||
    -- bug 4888622 - check for invalid currency conversions
    ',SUM(CASE WHEN(hri_oltp_view_currency.convert_currency_amount(
            fact.anl_slry_currency,
            ''' || p_parameter_rec.currency_code_to || ''',
            to_date(''' || p_parameter_rec.effective_date || ''',''MM/DD/YYYY''),
            fact.total_anl_slry,
            '''||g_curr_conv_rate_type||''') = -1)
                THEN 1 END) INVALID_CURR_CONV_IND';

    /* determine which summary to use */
    l_wrkfc_fact_table := get_wrkfc_fact_table(p_parameter_rec=>p_parameter_rec);

    /* apply parameter context filters to the fact query */
    l_sql_statement := l_sql_statement || g_rtn ||
    'FROM '|| l_wrkfc_fact_table|| ' fact' || g_rtn ||
    'WHERE 1=1' || g_rtn ||
    'AND to_date(''' || p_parameter_rec.effective_date || ''',''MM/DD/YYYY'')' || g_rtn ||
    '    BETWEEN fact.effective_start_date AND fact.effective_end_date'|| g_rtn ||
    'AND fact.supervisor_person_id = ' || p_parameter_rec.supervisor_person_id || g_rtn ||
    'AND fact.job_id = ' || p_parameter_rec.job_id;

    /* add group by */
    l_sql_statement := l_sql_statement || g_rtn ||
    'GROUP BY' || g_rtn ||
    ' fact.supervisor_person_id' || g_rtn ||
    ',fact.job_id'|| g_rtn ||
    ',''' || p_parameter_rec.currency_code_to || '''';

    o_sql_string := l_sql_statement;
    o_return_status := g_return_success;

EXCEPTION WHEN OTHERS THEN
    o_return_status := 'EXCEPTION: ' || SUBSTRB(SQLERRM,50);

END get_wrkfc_fact_sql;


/* Returns a person_id from a DBI CHO profile option */
FUNCTION get_level_1_sup_id RETURN NUMBER
IS
BEGIN
    RETURN NVL(fnd_profile.value('HRI_DBI_CHO_NMD_USR') ,-1);
END get_level_1_sup_id;


/*
**
** Returns a CEO level (using person_id from a profile option) fact SQL query
**
** This version is using a HRI_MDP_SUP% materialized view, however this
** may be enhanced in a future version to use a 'CEO' level MV.
**
**/
PROCEDURE get_wrkfc_fact_ceo_sql(
           p_parameter_rec  IN  HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE
          ,o_sql_string     OUT NOCOPY VARCHAR2
          ,o_return_status  OUT NOCOPY VARCHAR2)
IS

l_sql_statement VARCHAR2(32000);
l_parameter_rec HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE;

BEGIN

    l_parameter_rec := p_parameter_rec;

    /* override the supervisor_person_id with the CEO person id */
    l_parameter_rec.supervisor_person_id := GET_LEVEL_1_SUP_ID;

    /* call the wrkfc fact generation */
    GET_WRKFC_FACT_SQL(p_parameter_rec => l_parameter_rec
                      ,o_sql_string    => l_sql_statement
                      ,o_return_status => o_return_status);

    o_sql_string := l_sql_statement;
    o_return_status := g_return_success;

EXCEPTION WHEN OTHERS THEN
    o_return_status := 'EXCEPTION: ' || SUBSTRB(SQLERRM,50);


END get_wrkfc_fact_ceo_sql;

/*
** Formats the report U.I. outer columns
**/
PROCEDURE get_outer_columns(
           p_parameter_rec  IN HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE
          ,o_sql_string     OUT NOCOPY VARCHAR2
          ,o_return_status  OUT NOCOPY VARCHAR2)
IS

l_sql_statement VARCHAR2(1000);

l_decode_label  VARCHAR2(500);

BEGIN

    IF (     p_parameter_rec.logged_in_person_id <> -1
        AND  p_parameter_rec.logged_in_person_id IS NOT NULL
        AND (p_parameter_rec.logged_in_person_id <> p_parameter_rec.supervisor_person_id)
       ) THEN
       -- change the label logic
        l_decode_label :=
        'DECODE(supervisor_person_id
            ,'|| p_parameter_rec.supervisor_person_id || ',' ||'''' ||g_mgrs_org_msg_lbl ||'''
            ,'|| p_parameter_rec.logged_in_person_id || ',' ||'''' ||g_your_org_msg_lbl ||'''
            ,'|| '''' ||g_company_msg_lbl ||''')    VIEWBY' || g_rtn;

    ELSE
        l_decode_label :=
        'DECODE(supervisor_person_id
            ,'|| p_parameter_rec.supervisor_person_id || ',' ||'''' ||g_your_org_msg_lbl ||'''
            ,'|| '''' ||g_company_msg_lbl ||''')    VIEWBY' || g_rtn;

    END IF;


    l_sql_statement :=
'SELECT ' || g_rtn ||
 l_decode_label ||
',qry.supervisor_person_id    SUPERVISOR_PERSON_ID
,qry.job_id                   JOB_ID' || g_rtn ||
',''' || p_parameter_rec.currency_code_to || '''' || '   SAL_CURRENCY_CODE'|| g_rtn ||
',TO_CHAR(qry.total_headcount) TOTAL_HEADCOUNT
,TO_CHAR(DECODE(qry.INVALID_CURR_CONV_IND, 1, -1,qry.max_anl_slry),'''||g_sal_amount_fmt||''') MAX_ANL_SLRY
,TO_CHAR(DECODE(qry.INVALID_CURR_CONV_IND, 1, -1,qry.min_anl_slry),'''||g_sal_amount_fmt||''') MIN_ANL_SLRY
,TO_CHAR(DECODE(qry.INVALID_CURR_CONV_IND, 1, -1,qry.total_anl_slry),'''||g_sal_amount_fmt||''') TOTAL_ANL_SLRY
,TO_CHAR(DECODE(qry.INVALID_CURR_CONV_IND, 1, -1,
               DECODE(qry.total_headcount, 0, 0
                  ,(qry.total_anl_slry/qry.total_headcount))
                  ),'''||g_sal_amount_fmt||''') WEIGHTED_AVG_SAL' || g_rtn ||
'FROM' || g_rtn;

    o_sql_string := l_sql_statement;
    o_return_status := g_return_success;

EXCEPTION WHEN OTHERS THEN
    o_return_status := 'EXCEPTION: ' || SUBSTRB(SQLERRM,50);

END get_outer_columns;


PROCEDURE get_sql( p_effective_date         IN VARCHAR2
                  ,p_job_id                 IN NUMBER
                  ,p_supervisor_person_id   IN NUMBER
                  ,p_logged_in_person_id    IN NUMBER DEFAULT FND_GLOBAL.EMPLOYEE_ID
                  ,p_conv_to_currency_code  IN VARCHAR2
                  ,p_sal_amount_fmt         IN VARCHAR2 DEFAULT 'FM999,999,999,999'
                  ,p_ceo_row                IN VARCHAR2 DEFAULT 'N'
                  ,o_sql_string             OUT NOCOPY VARCHAR2
                  ,o_return_status          OUT NOCOPY VARCHAR2)
IS

  -- local variables for dynamic SQL
  l_sql_statement       VARCHAR2(32000);

  l_wrkfc_sup_sql       VARCHAR2(32000);
  l_wrkfc_sup_ceo_sql   VARCHAR2(32000);
  l_wrkfc_sup_login_sql   VARCHAR2(32000);

  l_eqty_outer_columns1 VARCHAR2(1000);
  l_eqty_outer_columns2 VARCHAR2(1000);

  -- parameter structure
  l_parameter_rec    HRI_OLTP_EMB_EQTY_ANAL.HRI_EMB_PARAM_REC_TYPE;

  -- fixed GSCC hardcoded schema issue
  l_dummy1        VARCHAR2(2000);
  l_dummy2        VARCHAR2(2000);


BEGIN

    /* check required parameters are passed in */
    IF (
         p_effective_date IS NULL
      OR p_job_id IS NULL
      OR p_supervisor_person_id IS NULL
      OR p_conv_to_currency_code IS NULL) THEN

      o_return_status := 'INVALID PARAMETER CONTEXT';
    ELSE

        /* process parameters into common parameter structure type */
        l_parameter_rec.effective_date := p_effective_date;
        l_parameter_rec.job_id := p_job_id;
        l_parameter_rec.supervisor_person_id := p_supervisor_person_id;

        l_parameter_rec.logged_in_person_id := p_logged_in_person_id;

        l_parameter_rec.currency_code_to := p_conv_to_currency_code;
        g_sal_amount_fmt := p_sal_amount_fmt;


        /* add another report row for the manager's manager */
        IF (    p_logged_in_person_id <> -1
            AND p_logged_in_person_id IS NOT NULL
            AND p_logged_in_person_id <> p_supervisor_person_id) THEN

            /* check if the p_logged_in_person_id is above hiring managers hrcy  */
            IF (check_mgr_is_above_in_hrchy(p_top_mgr_person_id   => p_logged_in_person_id
                                           ,p_lower_mgr_person_id => p_supervisor_person_id
                                           ,p_effective_date      => to_date(p_effective_date,'MM/DD/YYYY')
                                           )
            ) THEN

                /* combine the fact SQL to create the report UI */
                get_outer_columns(p_parameter_rec => l_parameter_rec
                                 ,o_sql_string    => l_eqty_outer_columns2
                                 ,o_return_status => o_return_status);

                -- Temporarily override the supervisor_id to logged in person_id
                l_parameter_rec.supervisor_person_id := p_logged_in_person_id;

                /* call the wrkfc fact generation for the Mgrs Mgr data*/
                GET_WRKFC_FACT_SQL(p_parameter_rec => l_parameter_rec
                                      ,o_sql_string    => l_wrkfc_sup_login_sql
                                      ,o_return_status => o_return_status);

                -- reset the overriden the supervisor_id back to supervisor_id
                l_parameter_rec.supervisor_person_id := p_supervisor_person_id;

                l_sql_statement  := l_sql_statement || g_rtn ||
                l_eqty_outer_columns2 || g_rtn ||
                '('|| l_wrkfc_sup_login_sql ||') qry';

            END IF;

        END IF;

        /* call the wrkfc fact generation */
        GET_WRKFC_FACT_SQL(p_parameter_rec => l_parameter_rec
                          ,o_sql_string    => l_wrkfc_sup_sql
                          ,o_return_status => o_return_status);

        /* combine the fact SQL to create the report UI */
        get_outer_columns(p_parameter_rec => l_parameter_rec
                         ,o_sql_string    => l_eqty_outer_columns1
                         ,o_return_status => o_return_status);

        IF l_sql_statement IS NULL THEN
            l_sql_statement := l_eqty_outer_columns1 || g_rtn ||
            '('|| l_wrkfc_sup_sql ||') qry';
        ELSE
            l_sql_statement  := l_sql_statement || g_rtn ||
            'UNION ALL' || g_rtn ||
            l_eqty_outer_columns1 || g_rtn ||
            '('|| l_wrkfc_sup_sql ||') qry';
        END IF;


        /* add another report row for the CEO/Company data */
         IF (   p_ceo_row = 'Y'
            AND (NVL(fnd_profile.value('HRI_DBI_CHO_NMD_USR'),-1) <> -1)
            )
             THEN
            /* combine the fact SQL to create the report UI */
            get_outer_columns(p_parameter_rec => l_parameter_rec
                             ,o_sql_string    => l_eqty_outer_columns2
                             ,o_return_status => o_return_status);

            /* call the wrkfc fact generation for the CEO data*/
            GET_WRKFC_FACT_CEO_SQL(p_parameter_rec => l_parameter_rec
                                  ,o_sql_string    => l_wrkfc_sup_ceo_sql
                                  ,o_return_status => o_return_status);

            l_sql_statement  := l_sql_statement || g_rtn ||
            'UNION ALL' || g_rtn ||
            l_eqty_outer_columns2 || g_rtn ||
            '('|| l_wrkfc_sup_ceo_sql ||') qry';

         END IF;

        /* return the fully formatted report SQL */
        o_sql_string := l_sql_statement;

        IF o_return_status IS NULL THEN
            o_return_status := g_return_success;
        END IF;

    END IF;

EXCEPTION WHEN OTHERS THEN
    o_return_status := 'EXCEPTION: ' || SUBSTRB(SQLERRM,50);

END get_sql;


END HRI_OLTP_EMB_EQTY_ANAL;

/
