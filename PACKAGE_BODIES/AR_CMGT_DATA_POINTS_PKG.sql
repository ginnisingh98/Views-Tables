--------------------------------------------------------
--  DDL for Package Body AR_CMGT_DATA_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_DATA_POINTS_PKG" AS
/* $Header: ARCMGDPB.pls 120.31.12010000.10 2010/02/24 19:57:42 mraymond ship $ */

pg_wf_debug VARCHAR2(1) := ar_cmgt_util.get_wf_debug_flag;

PROCEDURE build_case_folder_details(
        p_case_folder_id            IN      NUMBER,
        p_data_point_id             IN      NUMBER,
        p_data_point_value          IN      VARCHAR2 default NULL,
        p_mode                      IN      VARCHAR2 default 'CREATE',
        p_error_msg                 OUT nocopy     VARCHAR2,
        p_resultout                 OUT nocopy     VARCHAR2) AS

l_included_in_check_list                VARCHAR2(1) := 'N';
l_cnt                                   NUMBER;
l_errmsg                                VARCHAR2(4000);
l_resultout                             VARCHAR2(1);
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
    --   ar_cmgt_util.wf_debug(p_case_folder_id,
    --          'ar_cmgt_data_points_pkg.build_case_folder_details()+');
         ar_cmgt_util.wf_debug(p_case_folder_id,
            'DP:' || p_data_point_id || ' = ' || p_data_point_value);
    END IF;

    p_resultout := 0;

       -- this will generate case folder details of type 'CASE'
       IF p_mode = 'CREATE'
       THEN
            AR_CMGT_CONTROLS.populate_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  p_data_point_id,
                p_data_point_value          =>  p_data_point_value,
                p_included_in_check_list    =>  l_included_in_check_list,
                p_errmsg                    =>  l_errmsg,
                p_resultout                 =>  l_resultout);

            -- this will generate case folder details of type 'DATA'
            IF g_data_case_folder_exists = 'Y'
            THEN
                AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS (
                    p_case_folder_id        =>  g_data_case_folder_id,
                    p_data_point_id         =>  p_data_point_id,
                    p_data_point_value      =>  p_data_point_value,
                    p_score                 =>  NULL,
                    p_errmsg                =>  l_errmsg,
                    p_resultout             =>  l_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                AR_CMGT_CONTROLS.populate_case_folder_details(
                    p_case_folder_id            =>  g_data_case_folder_id,
                    p_data_point_id             =>  p_data_point_id,
                    p_data_point_value          =>  p_data_point_value,
                    p_included_in_check_list    =>  l_included_in_check_list,
                    p_errmsg                    =>  l_errmsg,
                    p_resultout                 =>  l_resultout);
            END IF;
        ELSIF p_mode = 'REFRESH'
        THEN
                AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS (
                    p_case_folder_id        =>  p_case_folder_id,
                    p_data_point_id         =>  p_data_point_id,
                    p_data_point_value      =>  p_data_point_value,
                    p_score                 =>  NULL,
                    p_errmsg                =>  l_errmsg,
                    p_resultout             =>  l_resultout);
        END IF;

--   IF pg_wf_debug = 'Y'
--   THEN
--     ar_cmgt_util.wf_debug(p_case_folder_id,
--             'ar_cmgt_data_points_pkg.build_case_folder_details()-');
--   END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_resultout := 1;
            p_error_msg := 'Unable to create/Update records in AR_CMGT_CF_DTLS for Data Point Id: '||p_data_point_id;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
END build_case_folder_details;

PROCEDURE build_case_folder_adp_details(
        p_case_folder_detail_id     IN          NUMBER,
        p_case_folder_id            IN          NUMBER,
        p_data_point_id             IN          NUMBER,
        p_sequence_number           IN          NUMBER,
        p_parent_data_point_id      IN          NUMBER,
        p_parent_cf_detail_id       IN          NUMBER,
        p_data_point_value          IN          VARCHAR2 default NULL,
        p_mode                      IN          VARCHAR2 default 'CREATE',
        x_error_msg                 OUT nocopy  VARCHAR2,
        x_resultout                 OUT nocopy  VARCHAR2)
AS
   l_included_in_check_list                VARCHAR2(1) := 'N';
   l_cnt                                   NUMBER;
   l_errmsg                                VARCHAR2(4000);
   l_resultout                             VARCHAR2(1);
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_case_folder_adp_details()+');
    -- ar_cmgt_util.wf_debug(p_case_folder_id,
    --        p_data_point_id || '=' || p_data_point_value);
    END IF;

   x_resultout := 0;

    -- this will generate case folder details of type 'CASE'
   IF p_mode = 'CREATE'
   THEN
      AR_CMGT_CONTROLS.populate_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  p_data_point_id,
                p_data_point_value          =>  p_data_point_value,
                p_included_in_check_list    =>  l_included_in_check_list,
                p_errmsg                    =>  x_error_msg,
                p_resultout                 =>  x_resultout);

            -- this will generate case folder details of type 'DATA'
      IF g_data_case_folder_exists = 'Y'
      THEN
         AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS (
                    p_case_folder_id        =>  g_data_case_folder_id,
                    p_data_point_id         =>  p_data_point_id,
                    p_data_point_value      =>  p_data_point_value,
                    p_score                 =>  NULL,
                    p_errmsg                =>  x_error_msg,
                    p_resultout             =>  x_resultout);
      ELSIF g_data_case_folder_exists = 'N'
      THEN
         AR_CMGT_CONTROLS.populate_case_folder_details(
                    p_case_folder_id            =>  g_data_case_folder_id,
                    p_data_point_id             =>  p_data_point_id,
                    p_data_point_value          =>  p_data_point_value,
                    p_included_in_check_list    =>  l_included_in_check_list,
                    p_errmsg                    =>  x_error_msg,
                    p_resultout                 =>  x_resultout);
      END IF;
   ELSIF p_mode = 'REFRESH'
   THEN
      AR_CMGT_CONTROLS.UPDATE_CASE_FOLDER_DETAILS (
                    p_case_folder_id        =>  p_case_folder_id,
                    p_data_point_id         =>  p_data_point_id,
                    p_data_point_value      =>  p_data_point_value,
                    p_score                 =>  NULL,
                    p_errmsg                =>  x_error_msg,
                    p_resultout             =>  x_resultout);
   END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_case_folder_adp_details()-');
    -- ar_cmgt_util.wf_debug(p_case_folder_id,
    --        p_data_point_id || '=' || p_data_point_value);
    END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_resultout := 1;
      x_error_msg := 'Unable to create/Update records in AR_CMGT_CF_DTLS for Data Point Id: '||p_data_point_id;
      ar_cmgt_util.wf_debug(p_case_folder_id, x_error_msg);
END build_case_folder_adp_details;

PROCEDURE GetDeductionDataPoints ( -- bug 3691676
            p_credit_request_id         IN          NUMBER,
            p_case_folder_id            IN          NUMBER,
            p_period                    IN          NUMBER,
            p_party_id                  IN          NUMBER,
            p_cust_account_id           IN          NUMBER,
            p_site_use_id               IN          NUMBER,
            p_analysis_level            IN          VARCHAR2,
            p_org_id                    IN          NUMBER,
            p_mode                      IN          VARCHAR2 default 'CREATE',
            p_limit_currency            IN          VARCHAR2,
            p_exchange_rate_type        IN          VARCHAR2,
            p_global_exposure_flag      IN          VARCHAR2,
            p_error_msg                 OUT NOCOPY  VARCHAR2,
            p_resultout                 OUT NOCOPY  VARCHAR2 ) IS

            l_deduction_amount          NUMBER;
            l_deduction_count           NUMBER;
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.get_deduction_data_points()+');
    END IF;
        -- first get the deduction amount
        p_resultout := 0;
        IF p_analysis_level = 'P'
        THEN
            BEGIN
                SELECT sum(amount_settled), sum(ded_count)
                INTO   l_deduction_amount, l_deduction_count
                FROM (
                    SELECT round(gl_currency_api.convert_amount(currency_code,
                            p_limit_currency, sysdate,
                            p_exchange_rate_type,
                            sum(amount_settled)),2) amount_settled,
                            count(*) ded_count
                    FROM   ozf_claims_all
                    WHERE  status_code = 'CLOSED'
                    AND    claim_class = 'DEDUCTION'
                    AND    settled_date  >= ADD_MONTHS(sysdate,(-p_period))
                    AND    cust_account_id IN (
                            select cust_account_id
                            FROM   hz_cust_accounts
                            WHERE  party_id in
                                  ( SELECT child_id
                                    from hz_hierarchy_nodes
                                    where parent_object_type = 'ORGANIZATION'
                                    and parent_table_name = 'HZ_PARTIES'
                                    and child_object_type = 'ORGANIZATION'
                                    and parent_id = p_party_id
                                    and effective_start_date <= sysdate
                                    and effective_end_date >= sysdate
                                    and  hierarchy_type =
                                          FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                    and  g_source_name <> 'LNS'
                                    UNION
                    select p_party_id from dual
                                    UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                                        ))
                    AND   currency_code IN ( SELECT CURRENCY FROM
                                         ar_cmgt_curr_usage_gt
                                         WHERE nvl(credit_request_id,p_credit_request_id)
                                                           = p_credit_request_id)
                    group by currency_code);
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_deduction_amount := null;
                    l_deduction_count := null;
                WHEN OTHERS THEN
                    p_error_msg := 'Error While getting Deduction for Party, SqlError: '||sqlerrm;
                    p_resultout := 1;
                    ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
                    return;
            END;
        ELSIF p_analysis_level = 'A'
        THEN
          BEGIN
            SELECT sum(amount_settled), sum(ded_count)
                INTO   l_deduction_amount, l_deduction_count
                FROM (
                    SELECT round(gl_currency_api.convert_amount(currency_code,
                            p_limit_currency, sysdate,
                            p_exchange_rate_type,
                            sum(amount_settled)),2) amount_settled,
                            count(*) ded_count
                    FROM   ozf_claims_all
                    WHERE  status_code = 'CLOSED'
                    AND    claim_class = 'DEDUCTION'
                    AND    cust_account_id = p_cust_account_id
                    AND    org_id = decode(p_global_exposure_flag,'Y', org_id, 'N',
                                    decode(p_org_id,null, org_id, p_org_id), null,
                                    decode(p_org_id,null, org_id, p_org_id))
                    AND    currency_code IN ( SELECT CURRENCY FROM
                                         ar_cmgt_curr_usage_gt
                                         WHERE nvl(credit_request_id,p_credit_request_id)
                                                           = p_credit_request_id)
                    AND    settled_date  >= ADD_MONTHS(sysdate,(-p_period))
                    group by currency_code );
          EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_deduction_amount := null;
                    l_deduction_count := null;
                WHEN OTHERS THEN
                    p_error_msg := 'Error While getting Deduction for Account, SqlError: '||sqlerrm;
                    p_resultout := 1;
                    ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
                    return;
          END;
        ELSIF p_analysis_level = 'S'
        THEN
            BEGIN
                SELECT sum(amount_settled), sum(ded_count)
                INTO   l_deduction_amount, l_deduction_count
                FROM (
                    SELECT round(gl_currency_api.convert_amount(currency_code,
                            p_limit_currency, sysdate,
                            p_exchange_rate_type,
                            sum(amount_settled)),2) amount_settled,
                            count(*) ded_count
                    FROM   ozf_claims_all
                    WHERE  status_code = 'CLOSED'
                    AND    claim_class = 'DEDUCTION'
                    AND    settled_date  >= ADD_MONTHS(sysdate,(-p_period))
                    AND    cust_account_id = p_cust_account_id
                    AND    cust_billto_acct_site_id = p_site_use_id
                    AND    currency_code IN ( SELECT CURRENCY FROM
                                         ar_cmgt_curr_usage_gt
                                         WHERE nvl(credit_request_id,p_credit_request_id)
                                                           = p_credit_request_id)
                    group by currency_code );
            EXCEPTION
                WHEN NO_DATA_FOUND
                THEN
                    l_deduction_amount := null;
                    l_deduction_count := null;
                WHEN OTHERS THEN
                    p_error_msg := 'Error While getting Deduction for Site, SqlError: '||sqlerrm;
                    p_resultout := 1;
                    ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
                    return;
            END;
        END IF;
        -- Now call build case folder to insert into case folder details
        build_case_folder_details(
            p_case_folder_id        => p_case_folder_id,
            p_data_point_id         => 211, -- deduction amount
            p_data_point_value      => fnd_number.number_to_canonical(l_deduction_amount),
            p_mode                  => p_mode,
            p_error_msg             => p_error_msg,
            p_resultout             => p_resultout);
        IF p_resultout <> 0
        THEN
            return;
        END IF;
        build_case_folder_details(
            p_case_folder_id        => p_case_folder_id,
            p_data_point_id         => 212, -- deduction count
            p_data_point_value      => l_deduction_count,
            p_mode                  => p_mode,
            p_error_msg             => p_error_msg,
            p_resultout             => p_resultout);
        IF p_resultout <> 0
        THEN
            return;
        END IF;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.get_deduction_data_points()-');
    END IF;

END;


PROCEDURE GetManualDataPoints(
            p_credit_request_id         IN          NUMBER,
            p_case_folder_id            IN          NUMBER,
            p_check_list_id             IN          NUMBER,
            p_mode                      IN          VARCHAR2 default 'CREATE',
            x_error_msg                 OUT NOCOPY  VARCHAR2,
            x_resultout                 OUT NOCOPY  VARCHAR2) IS


BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getmanualdatapoints()+');
    END IF;

   x_resultout := 0;
   ocm_add_data_points.getadditionalDataPoints (
    p_credit_request_id   =>  p_credit_request_id,
    p_case_folder_id    =>  p_case_folder_id,
    p_mode          =>  p_mode,
    p_error_msg       =>  x_error_msg,
    p_resultout       =>  x_resultout );

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getmanualdatapoints()-');
    END IF;
END GetManualDataPoints;


PROCEDURE GetAnalyticalData (
            p_credit_request_id        IN   NUMBER,
            p_party_id                 IN   NUMBER,
            p_cust_account_id          IN   NUMBER,
            p_site_use_id              IN   NUMBER,
            p_case_folder_id           IN   NUMBER,
            p_analysis_level           IN   VARCHAR2,
            p_org_id                   IN   NUMBER,
            p_period                   IN   NUMBER,
            p_global_exposure_flag     IN   VARCHAR2,
            p_limit_currency           IN   VARCHAR2,
            p_exchange_rate_type       IN   VARCHAR2,
            p_mode                     IN   VARCHAR2 default 'CREATE',
            p_errormsg                 out nocopy  VARCHAR2,
            p_resultout                out nocopy  VARCHAR2) IS

CURSOR c_currency IS
    SELECT currency from ar_cmgt_curr_usage_gt;

l_largest_inv_date                      ar_trx_summary.largest_inv_date%type;
l_largest_inv_amount                    ar_trx_summary.largest_inv_amount%type;
l_final_inv_amount                      ar_trx_summary.largest_inv_amount%type;
l_final_inv_date                        ar_trx_summary.largest_inv_date%type;
l_high_watermark_date                   ar_trx_summary.op_bal_high_watermark_date%type;
l_high_watermark                        ar_trx_summary.op_bal_high_watermark%type;
l_final_high_watermark                  ar_trx_summary.op_bal_high_watermark%type;
l_final_high_watermark_date             ar_trx_summary.as_of_date%type;
l_last_payment_amount                   ar_trx_bal_summary.last_payment_amount%type;
l_last_payment_date                     ar_trx_bal_summary.last_payment_date%type;
l_last_payment_number                   ar_trx_bal_summary.last_payment_number%type;
l_last_payment_currency                 ar_trx_bal_summary.currency%type;
l_last_payment_amount_conv              ar_trx_bal_summary.last_payment_amount%type;

l_result          VARCHAR2(150); -- 6513911

l_party_sql       VARCHAR2(4000) :='select LARGEST_INV_DATE,
                                           largest_inv_amount
                                     from ( select as_of_date LARGEST_INV_DATE,
                                            gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            largest_inv_amount)largest_inv_amount,
                                     RANK() OVER (PARTITION BY currency
                                     ORDER BY largest_inv_amount desc,
                                     largest_inv_cust_trx_id desc) rank_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id in (
                                               select cust_account_id
                                                FROM   hz_cust_accounts
                                                WHERE  party_id in
                                                ( SELECT child_id
                                                  from hz_hierarchy_nodes
                                                  where parent_object_type = ''ORGANIZATION''
                                                  and parent_table_name = ''HZ_PARTIES''
                                                  and child_object_type = ''ORGANIZATION''
                                                  and parent_id = :3
                                                  and effective_start_date <= sysdate
                                                  and effective_end_date >= sysdate
                                                  and  hierarchy_type =
                                                    FND_PROFILE.VALUE(''AR_CMGT_HIERARCHY_TYPE'')
                                                   and  :4 <> ''LNS''
                                                union select :5 from dual
                                                union
                                                select hz_party_id
                        from LNS_LOAN_PARTICIPANTS_V
                        where loan_id = :6
                        and   participant_type_code = ''COBORROWER''
                        and   :7 = ''LNS''
                        and (end_date_active is null OR
                              (sysdate between start_date_active and end_date_active)
                            )
                                          ))
                                     and currency = :8
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:9)) )
                                     Where rank_amount = 1 ';

l_account_sql       VARCHAR2(4000) :='select LARGEST_INV_DATE,
                                             largest_inv_amount
                                     from ( select as_of_date LARGEST_INV_DATE,
                                            gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            largest_inv_amount)largest_inv_amount,
                                     RANK() OVER (PARTITION BY cust_account_id,currency
                                     ORDER BY largest_inv_amount desc,
                                     largest_inv_cust_trx_id desc) rank_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id = :3
                                     and   org_id = decode(:4,''Y'', org_id, ''N'',
                                                    decode(:5,null, org_id, :6), null,
                                                    decode(:7,null, org_id, :8))
                                     and currency = :9
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:10)) )
                                     Where rank_amount = 1';

l_site_sql       VARCHAR2(4000) :='select LARGEST_INV_DATE,
                                        largest_inv_amount
                                     from ( select as_of_date LARGEST_INV_DATE,
                                            gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            largest_inv_amount)largest_inv_amount,
                                     RANK() OVER (PARTITION BY cust_account_id, site_use_id,currency
                                     ORDER BY largest_inv_amount desc,
                                     largest_inv_cust_trx_id desc) rank_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id = :3
                                     and   site_use_id = :4
                                     and currency = :5
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:6))  )
                                     Where rank_amount = 1 ';

/*  Not using Analytical function to derive high credit amount as
    part of bug fix 3557539
l_high_credit_party_sql  VARCHAR2(4000) :='select op_bal_high_watermark_date,
                                                  op_bal_high_watermark
                                     from ( select as_of_date op_bal_high_watermark_date,
                                          gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            op_bal_high_watermark)op_bal_high_watermark,
                                     RANK() OVER (PARTITION BY currency
                                     ORDER BY op_bal_high_watermark desc,
                                     largest_inv_cust_trx_id desc) high_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id in (
                                               select cust_account_id
                                                FROM   hz_cust_accounts
                                                WHERE  party_id in
                                                ( SELECT child_id
                                                  from hz_hierarchy_nodes
                                                  where parent_object_type = ''ORGANIZATION''
                                                  and parent_table_name = ''HZ_PARTIES''
                                                  and child_object_type = ''ORGANIZATION''
                                                  and parent_id = :3
                                                  and effective_start_date <= sysdate
                                                  and effective_end_date >= sysdate
                                                  and  hierarchy_type =
                                                    FND_PROFILE.VALUE(''AR_CMGT_HIERARCHY_TYPE'')
                                                union select :4 from dual
                                          ))
                                     and currency = :5
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:6)) )
                                     Where  high_amount = 1';

l_high_credit_account_sql  VARCHAR2(4000) :='select op_bal_high_watermark_date,
                                                    op_bal_high_watermark
                                     from ( select as_of_date op_bal_high_watermark_date,
                                            gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            op_bal_high_watermark)op_bal_high_watermark,
                                     RANK() OVER (PARTITION BY cust_account_id,currency,org_id
                                     ORDER BY op_bal_high_watermark desc,
                                     largest_inv_cust_trx_id desc) high_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id = :3
                                     and   org_id = decode(:4,''Y'', org_id, ''N'',
                                                    decode(:5,null, org_id, :6), null,
                                                    decode(:7,null, org_id, :8))
                                     and currency = :9
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:10)) )
                                     Where high_amount = 1';

l_high_credit_site_sql     VARCHAR2(4000) :='select op_bal_high_watermark_date,
                                                    op_bal_high_watermark
                                     from ( select as_of_date op_bal_high_watermark_date,
                                          gl_currency_api.convert_amount(currency,
                                            :1,sysdate,
                                            :2,
                                            op_bal_high_watermark)op_bal_high_watermark,
                                     RANK() OVER (PARTITION BY cust_account_id, site_use_id,currency
                                     ORDER BY op_bal_high_watermark desc,
                                     largest_inv_cust_trx_id desc) high_amount
                                     FROM AR_TRX_SUMMARY
                                     where cust_account_id = :3
                                     and   site_use_id = :4
                                     and currency = :5
                                     and largest_inv_cust_trx_id is not null
                                     and    as_of_date  >= ADD_MONTHS(sysdate,(-:6))  )
                                     Where  high_amount = 1';

************************************************************************************/

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getanalyticaldata()+');
    END IF;

       p_resultout := 0;
       -- get largest in amount
       FOR c_currency_rec IN c_currency
       LOOP
        BEGIN
           IF p_analysis_level = 'P'
           THEN
             EXECUTE IMMEDIATE l_party_sql INTO
                     l_largest_inv_date,
                     l_largest_inv_amount
             USING p_limit_currency,p_exchange_rate_type,
                   p_party_id, g_source_name, p_party_id, g_source_id,
           g_source_name, c_currency_rec.currency, p_period;

           ELSIF p_analysis_level = 'A'
           THEN
                EXECUTE IMMEDIATE l_account_sql INTO
                        l_largest_inv_date,
                        l_largest_inv_amount
                USING p_limit_currency,p_exchange_rate_type,
                      p_cust_account_id,p_global_exposure_flag,p_org_id,
                      p_org_id, p_org_id, p_org_id,
                      c_currency_rec.currency, p_period;
           ELSIF p_analysis_level = 'S'
           THEN
                EXECUTE IMMEDIATE l_site_sql INTO
                        l_largest_inv_date,
                        l_largest_inv_amount
                USING p_limit_currency,p_exchange_rate_type,
                      p_cust_account_id,p_site_use_id,
                      c_currency_rec.currency, p_period;
           END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_largest_inv_date := null;
                l_largest_inv_amount := null;

        END;
           IF l_largest_inv_date IS NOT NULL AND l_largest_inv_amount IS NOT NULL
             THEN
                    IF nvl(l_final_inv_amount,0) <  l_largest_inv_amount
                    THEN
                        l_final_inv_amount := l_largest_inv_amount;
                        l_final_inv_date := l_largest_inv_date;
                    END IF;
             END IF;

       END LOOP;

       /*-- repaet the same process for High water mark
       FOR c_currency_rec IN c_currency
       LOOP
        BEGIN
           IF p_analysis_level = 'P'
           THEN

             EXECUTE IMMEDIATE l_high_credit_party_sql INTO
                     l_high_watermark_date,
                     l_high_watermark
             USING p_limit_currency,p_exchange_rate_type,
                   p_party_id, p_party_id,c_currency_rec.currency, p_period;

           ELSIF p_analysis_level = 'A'
           THEN
                EXECUTE IMMEDIATE l_high_credit_account_sql INTO
                        l_high_watermark_date,
                        l_high_watermark
                USING p_limit_currency,p_exchange_rate_type,
                      p_cust_account_id,p_global_exposure_flag,p_org_id,
                      p_org_id, p_org_id, p_org_id,
                      c_currency_rec.currency, p_period;

           ELSIF p_analysis_level = 'S'
           THEN
                EXECUTE IMMEDIATE l_high_credit_site_sql INTO
                        l_high_watermark_date,
                        l_high_watermark
                USING p_limit_currency,p_exchange_rate_type,
                      p_cust_account_id,p_site_use_id,
                      c_currency_rec.currency, p_period;
           END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_high_watermark_date := null;
                l_high_watermark := null;

        END;
           IF l_high_watermark_date IS NOT NULL AND l_high_watermark IS NOT NULL
             THEN
                    IF l_final_high_watermark <  l_high_watermark
                    THEN
                        l_final_high_watermark  := l_high_watermark;
                        l_final_high_watermark_date := l_high_watermark_date;
                    END IF;
             END IF;

       END LOOP;  */
       -- Get the High Watermark and date (Bug fix 3557539)
       -- Not using the above analytical select statement
       IF p_analysis_level = 'P'
       THEN
            BEGIN

                /* 6513911 - revised sql to not require all currencies
                     This code now selects the converted amount and date
                     (max) at one time, then substr them out to individual
                     fields for the datapoint(s).  Incidentally, the original
                     logic returned the raw amount (in AR_TRX_SUMMARY currency)
                     rather than the converted amount -- I considered this a bug
                     and now return the converted amount (to CF currency) */
                SELECT max(ltrim(
                    to_char( gl_currency_api.convert_amount(currency,
                                            p_limit_currency,sysdate,
                                            p_exchange_rate_type,
                                            NVL(op_bal_high_watermark,0)),
                                            '0999999999999999999D00')) || '~' ||
                                 to_char(as_of_date, 'YYYYMMDD'))
                INTO   l_result
                FROM   ar_trx_summary
                WHERE  op_bal_high_watermark IS NOT NULL
                AND    as_of_date  >= ADD_MONTHS(sysdate,(-p_period))
                AND    cust_account_id IN (
                            SELECT cust_account_id
                            FROM   hz_cust_accounts
                            WHERE  party_id in
                                  ( SELECT child_id
                                    FROM   hz_hierarchy_nodes
                                    WHERE  parent_object_type = 'ORGANIZATION'
                                    AND parent_table_name = 'HZ_PARTIES'
                                    AND child_object_type = 'ORGANIZATION'
                                    AND parent_id = p_party_id
                                    AND effective_start_date <= sysdate
                                    AND effective_end_date >= sysdate
                                    AND hierarchy_type =
                                           FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                    AND  g_source_name <> 'LNS'
                                    UNION
                                    SELECT p_party_id FROM DUAL
                                    UNION
                                    SELECT hz_party_id
                                    FROM   LNS_LOAN_PARTICIPANTS_V
                                    WHERE  loan_id = g_source_id
                                    AND    participant_type_code = 'COBORROWER'
                                    AND    g_source_name = 'LNS'
                                    AND    (end_date_active is null OR
                                         (sysdate between start_date_active
                                                       and end_date_active))))
                AND   currency IN ( SELECT CURRENCY
                                    FROM   ar_cmgt_curr_usage_gt
                                    WHERE nvl(credit_request_id,p_credit_request_id)
                                                        = p_credit_request_id);

                /* Now extract results, '~' is separator */
                l_final_high_watermark := to_number(substr(l_result,0,instr(l_result,'~')-1));
                l_final_high_watermark_date := to_date(substr(l_result,instr(l_result,'~')+1),'YYYYMMDD');

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        l_final_high_watermark := NULL;
                        l_final_high_watermark_date := NULL;
                    when others THEN
                      p_errormsg := 'Error While getting High Credit Amount for Party, SqlError: <'||l_result||'>'|| sqlerrm;
                      p_resultout := 1;
                      ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
                      return;

            END;
       ELSE -- p_analysis_level A or S (both)
            BEGIN
                SELECT max(ltrim(
                    to_char( gl_currency_api.convert_amount(currency,
                                            p_limit_currency,sysdate,
                                            p_exchange_rate_type,
                                            NVL(op_bal_high_watermark,0)),
                                            '0999999999999999999D00')) || '~' ||
                                 to_char(as_of_date, 'YYYYMMDD'))
                INTO   l_result
                FROM   ar_trx_summary
                WHERE  op_bal_high_watermark IS NOT NULL
                AND    as_of_date  >= ADD_MONTHS(sysdate,(-p_period))
                AND    cust_account_id = p_cust_account_id
                AND    site_use_id = DECODE(p_analysis_level, 'S', p_site_use_id,
                                              site_use_id)
                AND    org_id = decode(p_global_exposure_flag,'Y', org_id, 'N',
                                  decode(p_org_id,null, org_id, p_org_id), null,
                                  decode(p_org_id,null, org_id, p_org_id))
                AND    currency IN ( SELECT CURRENCY
                                     FROM   ar_cmgt_curr_usage_gt
                                     WHERE nvl(credit_request_id,p_credit_request_id)
                                                        = p_credit_request_id);

                /* Now extract results, '~' is separator */
                l_final_high_watermark := to_number(substr(l_result,0,instr(l_result,'~')-1));
                l_final_high_watermark_date := to_date(substr(l_result,instr(l_result,'~')+1),'YYYYMMDD');

            EXCEPTION
                WHEN no_data_found then
                    l_final_high_watermark := NULL;
                    l_final_high_watermark_date := NULL;
                when others then
                    p_errormsg := 'Error While getting High Credit Amount for Account/Site, SqlError: <'||l_result||'>'|| sqlerrm;
                    p_resultout := 1;
                    ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
                    return;


            END;
       END IF;

       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  19,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_final_inv_amount),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  20,
                p_data_point_value          =>  l_final_inv_date,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  6,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_final_high_watermark),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  7,
                p_data_point_value          =>  l_final_high_watermark_date,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
      -- Get the last payment Info.
      BEGIN
           IF p_analysis_level = 'P'
           THEN
                SELECT last_payment_amount, last_payment_date,
                       last_payment_number, currency
                INTO   l_last_payment_amount, l_last_payment_date,
                       l_last_payment_number, l_last_payment_currency
                FROM AR_TRX_BAL_SUMMARY
                WHERE cust_account_id  in (select cust_account_id
                                    FROM   hz_cust_accounts
                                    WHERE  party_id in
                                    ( SELECT child_id
                                        from hz_hierarchy_nodes
                                        where parent_object_type = 'ORGANIZATION'
                                        and parent_table_name = 'HZ_PARTIES'
                                        and child_object_type = 'ORGANIZATION'
                                        and parent_id = p_party_id
                                        and effective_start_date <= sysdate
                                        and effective_end_date >= sysdate
                                        and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                        and  g_source_name <> 'LNS'
                                    union select p_party_id from dual
                                    UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                               ))
                and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id)
                                                = p_credit_request_id)
                and    last_payment_number IS NOT NULL
                and    last_payment_date IS NOT NULL
                and    last_payment_date = ( select max(last_payment_date) from
                                             ar_trx_bal_summary
                                             where  cust_account_id  in
                                                    (select cust_account_id
                                                     FROM   hz_cust_accounts
                                                     WHERE  party_id in
                                                        ( SELECT child_id
                                                          from hz_hierarchy_nodes
                                                          where parent_object_type = 'ORGANIZATION'
                                                          and parent_table_name = 'HZ_PARTIES'
                                                          and child_object_type = 'ORGANIZATION'
                                                          and parent_id = p_party_id
                                                          and effective_start_date <= sysdate
                                                          and effective_end_date >= sysdate
                                                          and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                                          and  g_source_name <> 'LNS'
                                                     union select p_party_id from dual
                           UNION
                            select hz_party_id
                            from LNS_LOAN_PARTICIPANTS_V
                            where loan_id = g_source_id
                            and   participant_type_code = 'COBORROWER'
                            and   g_source_name = 'LNS'
                            and (end_date_active is null OR
                                  (sysdate between start_date_active and end_date_active)
                                )
                           ))
                                              and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                                                ar_cmgt_curr_usage_gt
                                                                WHERE nvl(credit_request_id,p_credit_request_id) =
                                                                p_credit_request_id)
                                              and    last_payment_date is not null
                                              and    last_payment_number is not null)
                and   rownum = 1;
           ELSIF p_analysis_level = 'A'
           THEN
                SELECT last_payment_amount, last_payment_date,
                       last_payment_number, currency
                INTO   l_last_payment_amount, l_last_payment_date,
                       l_last_payment_number, l_last_payment_currency
                FROM AR_TRX_BAL_SUMMARY
                where cust_account_id = p_cust_account_id
                and   last_payment_date IS NOT NULL
                and   last_payment_number IS NOT NULL
                and   org_id = decode(p_global_exposure_flag,'Y', org_id, 'N',
                               decode(p_org_id,null, p_org_id, p_org_id), null,
                               decode(p_org_id,null, org_id, p_org_id))
                and   currency in  ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
                and   last_payment_date = (  select max(last_payment_date) from
                                             ar_trx_bal_summary
                                             where  cust_account_id = p_cust_account_id
                                             and    last_payment_date IS NOT NULL
                                             and    last_payment_number IS NOT NULL
                                             and    currency in ( SELECT CURRENCY FROM
                                                        ar_cmgt_curr_usage_gt
                                                        WHERE nvl(credit_request_id,p_credit_request_id) =
                                                          p_credit_request_id))
                and    rownum = 1;
           ELSIF p_analysis_level = 'S'
           THEN
                SELECT last_payment_amount, last_payment_date,
                       last_payment_number, currency
                INTO   l_last_payment_amount, l_last_payment_date,
                       l_last_payment_number, l_last_payment_currency
                FROM AR_TRX_BAL_SUMMARY
                where cust_account_id = p_cust_account_id
                and   site_use_id     = p_site_use_id
                and   last_payment_date IS NOT NULL
                and   last_payment_number IS NOT NULL
                and   currency in  ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
                and   last_payment_date = (  select max(last_payment_date) from
                                             ar_trx_bal_summary
                                             where  cust_account_id = p_cust_account_id
                                             and    site_use_id     = p_site_use_id
                                             and    last_payment_date IS NOT NULL
                                             and    last_payment_number IS NOT NULL
                                             and    currency in ( SELECT CURRENCY FROM
                                                        ar_cmgt_curr_usage_gt
                                                        WHERE nvl(credit_request_id,p_credit_request_id) =
                                                          p_credit_request_id))
                and   rownum = 1;
           END IF;

           EXCEPTION
                WHEN no_data_found then
                     l_last_payment_number := null;
                     l_last_payment_date := null;
                     l_last_payment_amount := null;
                when others then
                      p_errormsg := 'Error While getting Last payment info., SqlError: '||sqlerrm;
                      p_resultout := 1;
                      ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
                      return;
      END;
      BEGIN
      -- if everything is ok then create record in case folder tables
           -- convert last payment amount to  limit currency amount
          IF l_last_payment_currency IS NOT NULL THEN
             l_last_payment_amount_conv := gl_currency_api.convert_amount
                            (l_last_payment_currency,
                             p_limit_currency,sysdate,
                             p_exchange_rate_type,
                             l_last_payment_amount);
          END IF;
           build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  11,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_last_payment_amount_conv),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
           build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  207,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_last_payment_amount),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
           build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  12,
                p_data_point_value          =>  l_last_payment_date,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
           build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  205,
                p_data_point_value          =>  l_last_payment_number,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
           build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  206,
                p_data_point_value          =>  l_last_payment_currency,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
      EXCEPTION
            when others then
                p_errormsg := 'Error While inserting Last payment info., SqlError: '||sqlerrm;
                p_resultout := 1;
                ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
                return;
      END;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getanalyticaldata()-');
    END IF;

      EXCEPTION
        WHEN OTHERS THEN
            p_errormsg := 'Error While getting Largest Invvoice and High Credit Amount, SqlError: '||sqlerrm;
            p_resultout := 1;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
END;


PROCEDURE GetDunning(
            p_credit_request_id        IN   NUMBER,
            p_party_id                 IN   NUMBER,
            p_cust_account_id          IN   NUMBER,
            p_site_use_id              IN   NUMBER,
            p_org_id                   IN   NUMBER,
            p_case_folder_id           IN   NUMBER,
            p_period                   IN   NUMBER,
            p_analysis_level           IN   VARCHAR2,
            p_global_exposure_flag     IN   VARCHAR2,
            p_mode                     IN   VARCHAR2 default 'CREATE',
            p_errormsg                 OUT  nocopy VARCHAR2,
            p_resultout                out nocopy  VARCHAR2) IS

  l_correspondence_date             ar_correspondences_all.correspondence_date%type;
  l_dunning_count                   NUMBER;
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getdunning()+');
    END IF;

    p_resultout := 0;
    IF p_analysis_level = 'A'
    THEN
        BEGIN
            SELECT max(correspondence_date), count(*)
            INTO   l_correspondence_date, l_dunning_count
            FROM  ar_correspondences_all
            WHERE correspondence_type = 'DUNNING'
            AND   customer_id = p_cust_account_id
            AND   org_id      = decode(p_global_exposure_flag,'Y', org_id, 'N',
                                     decode(p_org_id,null, org_id, p_org_id), null,
                                     decode(p_org_id,null, org_id, p_org_id))
            AND   correspondence_date >= ADD_MONTHS(sysdate,(-p_period));
        END;
    ELSIF p_analysis_level = 'S'
    THEN
        BEGIN
            SELECT max(correspondence_date), count(*)
            INTO   l_correspondence_date, l_dunning_count
            FROM  ar_correspondences_all
            WHERE correspondence_type = 'DUNNING'
            AND   customer_id = p_cust_account_id
            AND   site_use_id     = p_site_use_id
            AND   correspondence_date >= ADD_MONTHS(sysdate,(-p_period));
        END;
    ELSIF p_analysis_level = 'P'
    THEN
       BEGIN
            SELECT max(correspondence_date), count(*)
            INTO   l_correspondence_date, l_dunning_count
            FROM  ar_correspondences_all
            WHERE correspondence_type = 'DUNNING'
            AND   customer_id in  (
                                  select cust_account_id
                                  FROM   hz_cust_accounts
                                  WHERE  party_id in
                                        ( SELECT child_id
                                          from hz_hierarchy_nodes
                                          where parent_object_type = 'ORGANIZATION'
                                            and parent_table_name = 'HZ_PARTIES'
                                            and child_object_type = 'ORGANIZATION'
                                            and parent_id = p_party_id
                                            and effective_start_date <= sysdate
                                            and effective_end_date >= sysdate
                                            and  hierarchy_type =
                                             FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                             and  g_source_name <> 'LNS'
                                            union select p_party_id from dual
                                            UNION
                        select hz_party_id
                        from LNS_LOAN_PARTICIPANTS_V
                        where loan_id = g_source_id
                        and   participant_type_code = 'COBORROWER'
                        and   g_source_name = 'LNS'
                        and (end_date_active is null OR
                              (sysdate between start_date_active and end_date_active)
                              )
                                          ))
            AND   correspondence_date >= ADD_MONTHS(sysdate,(-p_period));
        END;
    END IF;
    build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  57,
                p_data_point_value          =>  to_char(l_correspondence_date),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
    IF p_resultout <> 0
    THEN
        return;
    END IF;
    build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  59,
                p_data_point_value          =>  l_dunning_count,
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errormsg ,
                p_resultout                 =>  p_resultout);
    IF p_resultout <> 0
    THEN
        return;
    END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getdunning()-');
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_resultout := 1;
            p_errormsg := 'Error While getting Dunning Letter Count, Sql Error:'||sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
END;


PROCEDURE GetOMDataPoints(
            p_credit_request_id        IN   NUMBER,
            p_party_id                 IN   NUMBER,
            p_cust_account_id          IN   NUMBER,
            p_site_use_id              IN   NUMBER,
            p_case_folder_id           IN   NUMBER,
            p_analysis_level           IN   VARCHAR2,
            p_limit_currency_code      IN   VARCHAR2,
            p_mode                     IN   VARCHAR2 default 'CREATE',
            p_errormsg                 OUT nocopy  VARCHAR2,
            p_resultout                OUT nocopy  VARCHAR2) IS

l_status                    varchar2(1) ;
l_industry                  VARCHAR2(1) ;
l_return                    BOOLEAN ;
l_application_id            NUMBER;
l_credit_check_rule_id      NUMBER;
l_total_exposure            NUMBER;
l_order_hold_amount         NUMBER;
l_order_amount              NUMBER;
l_ar_cmount                 NUMBER;
l_external_amount           NUMBER;
l_return_status             VARCHAR2(1);
l_errmsg                    VARCHAR2(2000);
l_resultout                 VARCHAR2(1);
l_om_installed_flag         VARCHAR2(1) := 'Y';
l_om_exposure               NUMBER;
l_credit_exposure           NUMBER;
l_rec_bal                   NUMBER;

CURSOR RecBalC IS
    SELECT data_point_value
    FROM   ar_cmgt_cf_dtls
    WHERE  case_folder_id = p_case_folder_id
    AND    data_point_id = 34; -- receivable balance
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getomdatapoints()+');
    END IF;

    -- first check if OM is installed, if OM is installed then get oM data points
    p_resultout := 0;

    BEGIN
        select  application_id
        into    l_application_id
        from    fnd_application
        where application_short_name = 'ONT' ;

        IF fnd_installation.get(l_application_id,l_application_id
                            ,l_status,l_industry) then

            IF l_status NOT IN ('I','S')
            THEN
                l_om_installed_flag := 'N';
            END IF;

        ELSE
            l_om_installed_flag := 'N';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_om_installed_flag := 'N';
        WHEN OTHERS THEN
            p_resultout := 1;
            p_errormsg := 'Error While Checking if ONT is installed or not, Sqlerror '||sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
            return;
    END;
    BEGIN
        --  Now if OM is installed get credit_check_rule_id
        SELECT credit_check_rule_id
        INTO   l_credit_check_rule_id
        FROM   ar_cmgt_credit_requests
        WHERE  credit_request_id = p_credit_request_id;

        IF l_credit_check_rule_id IS NULL
        THEN
            l_credit_check_rule_id := -999; -- use seeded credit check rule id
        END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_om_installed_flag := 'N';
            WHEN OTHERS THEN
                p_resultout := 1;
                p_errormsg := 'Error While getting Credit Check rule Id, Sqlerror '||sqlerrm;
                ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
                return;
    END;
    IF l_om_installed_flag = 'N'
    THEN
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  15,
                p_data_point_value          =>  null,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);

        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  26,
                p_mode                      =>  p_mode,
                p_data_point_value          =>  null,
                p_error_msg                    =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       return; -- no need to continue if OM is not installed
    END IF;
    -- check what is the analysis level
    IF p_analysis_level in ('P')
    THEN
        OE_Credit_Exposure_PUB.Get_customer_exposure
            ( p_party_id                => p_party_id,
              p_customer_id             => NULL,
              p_site_id                 => NULL,
              p_limit_curr_code         => p_limit_currency_code,
              p_credit_check_rule_id    => l_credit_check_rule_id,
              x_total_exposure          => l_total_exposure,
              x_order_hold_amount       => l_order_hold_amount,
              x_order_amount            => l_order_amount,
              x_ar_amount               => l_ar_cmount,
              x_external_amount         => l_external_amount,
              x_return_status           => l_return_status);
    ELSIF p_analysis_level in ('A')
    THEN
        OE_Credit_Exposure_PUB.Get_customer_exposure
            ( p_party_id                => p_party_id,
              p_customer_id             => p_cust_account_id,
              p_site_id                 => NULL,
              p_limit_curr_code         => p_limit_currency_code,
              p_credit_check_rule_id    => l_credit_check_rule_id,
              x_total_exposure          => l_total_exposure,
              x_order_hold_amount       => l_order_hold_amount,
              x_order_amount            => l_order_amount,
              x_ar_amount               => l_ar_cmount,
              x_external_amount         => l_external_amount,
              x_return_status           => l_return_status);

    ELSIF p_analysis_level = 'S'
    THEN
        OE_Credit_Exposure_PUB.Get_customer_exposure
            ( p_party_id                => p_party_id,
              p_customer_id             => p_cust_account_id,
              p_site_id                 => p_site_use_id,
              p_limit_curr_code         => p_limit_currency_code,
              p_credit_check_rule_id    => l_credit_check_rule_id,
              x_total_exposure          => l_total_exposure,
              x_order_hold_amount       => l_order_hold_amount,
              x_order_amount            => l_order_amount,
              x_ar_amount               => l_ar_cmount,
              x_external_amount         => l_external_amount,
              x_return_status           => l_return_status);


    END IF;
    IF l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
            build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  15,
                p_data_point_value          =>  fnd_number.number_to_canonical((l_total_exposure - l_ar_cmount)),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);

            build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  26,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_order_hold_amount),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);

            -- Now Populate Credit exposure
            FOR RecBalRec IN RecBalC
            LOOP
                 l_Rec_Bal := fnd_number.canonical_to_number(RecBalRec.data_point_value);
            END LOOP;
            l_credit_exposure :=
                nvl(l_Rec_bal,0) + (nvl(l_total_exposure,0) - nvl(l_ar_cmount,0)) +
                nvl(l_order_hold_amount,0);

            build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  213,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_credit_exposure),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
    ELSE
           p_resultout := 1;
           p_errormsg := 'Error While getting OM Exposure, Sqlerror '||sqlerrm;
           ar_cmgt_util.wf_debug(p_case_folder_id, p_errormsg);
           return;
    END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getomdatapoints()-');
    END IF;

END;

/* 6335440 - this procedure did not work prior to this bug.
   The reason was that the financial data (ar_cmgt_financial_data)
   had cust_acct_site_id in the site_use_id field.  Additionally,
   prior to this bug, the procedure relied on completely un-indexed
   joins and multiple reads of the ar_cmgt_financial_data table
   which (for production data) would bave performed awful.

   To correct these issues, we did the following:

     o revised initial select to fetch cust_acct_site_id
        instead of site_use_id.  This is used to correctly
        join to the errant ar_cmgt_financial_data table.

     o revised second select to only join to
        ar_cmgt_financial_data once (was joining twice)

     o Added index ar_cmgt_financial_data_n2 that contains following:
         1) party_id
         2) reporting_currency
         3) cust_account_id
         4) site_use_id

       The reason the index is in this particular order is that party_id
       and currency are guaranteed.  cust and/or site are optional and
       may be provided as cust or cust + site.

*/

PROCEDURE GetFinancialData (
        p_credit_request_id         IN            NUMBER,
        p_case_folder_id            IN            NUMBER,
        p_mode                      IN            VARCHAR2,
        p_resultout                 OUT NOCOPY    VARCHAR2,
        p_errmsg                  OUT NOCOPY    VARCHAR2) IS

        l_reporting_currency        ar_cmgt_financial_data.reporting_currency%type;
        l_monetary_unit             ar_cmgt_financial_data.monetary_unit%type;
        l_curr_fin_st_date          ar_cmgt_financial_data.curr_fin_st_date%type;
        l_reporting_period          ar_cmgt_financial_data.reporting_period%type;
        l_cash                      ar_cmgt_financial_data.cash%type;
        l_net_receivables           ar_cmgt_financial_data.net_receivables%type;
        l_inventories               ar_cmgt_financial_data.inventories%type;
        l_other_cur_assets          ar_cmgt_financial_data.other_cur_assets%type;
        l_total_cur_assets          ar_cmgt_financial_data.total_cur_assets%type;
        l_net_fixed_assets          ar_cmgt_financial_data.net_fixed_assets%type;
        l_other_non_cur_assets      ar_cmgt_financial_data.net_fixed_assets%type;
        l_total_assets              ar_cmgt_financial_data.total_assets%type;
        l_accounts_payable          ar_cmgt_financial_data.accounts_payable%type;
        l_short_term_debt           ar_cmgt_financial_data.short_term_debt%type;
        l_other_cur_liabilities     ar_cmgt_financial_data.other_cur_liabilities%type;
        l_total_cur_liabilities     ar_cmgt_financial_data.total_cur_liabilities%type;
        l_long_term_debt            ar_cmgt_financial_data.long_term_debt%type;
        l_other_non_cur_liabilities ar_cmgt_financial_data.other_non_cur_liabilities%type;
        l_total_liabilities         ar_cmgt_financial_data.total_liabilities%type;
        l_stockholder_equity        ar_cmgt_financial_data.stockholder_equity%type;
        l_total_liabilities_equity  ar_cmgt_financial_data.total_liabilities_equity%type;
        l_revenue                   ar_cmgt_financial_data.revenue%type;
        l_cost_of_goods_sold        ar_cmgt_financial_data.cost_of_goods_sold%type;
        l_sga_expenses              ar_cmgt_financial_data.sga_expenses%type;
        l_operating_income          ar_cmgt_financial_data.operating_income%type;
        l_operating_margin          ar_cmgt_financial_data.operating_margin%type;
        l_non_operating_income      ar_cmgt_financial_data.non_operating_income%type;
        l_non_operating_expenses    ar_cmgt_financial_data.non_operating_expenses%type;
        l_pre_tax_net_income        ar_cmgt_financial_data.pre_tax_net_income%type;
        l_income_taxes              ar_cmgt_financial_data.income_taxes%type;
        l_net_income                ar_cmgt_financial_data.net_income%type;
        l_earnings_per_share        ar_cmgt_financial_data.earnings_per_share%type;
        l_financial_data_id         ar_cmgt_financial_data.financial_data_id%type;
        l_party_id                  ar_cmgt_case_folders.party_id%type;
        l_cust_account_id           ar_cmgt_case_folders.cust_account_id%type;
        l_site_use_id               ar_cmgt_case_folders.site_use_id%type;
        l_limit_currency            ar_cmgt_case_folders.limit_currency%type;

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getfinancialdata()+');
    END IF;

    p_resultout := 0;
    BEGIN
        BEGIN
          -- first get the maximum data for a party
          /* 6335440 - modified to fetch correct site for fin data */
          SELECT cmcf.party_id,
                 cmcf.cust_account_id,
                 nvl(hzs.cust_acct_site_id,cmcf.site_use_id),
                 cmcf.limit_currency
          INTO   l_party_id, l_cust_account_id, l_site_use_id, l_limit_currency
          FROM   ar_cmgt_case_folders      cmcf,
                 hz_cust_site_uses_all     hzs
          WHERE  cmcf.case_folder_id = p_case_folder_id
          AND    cmcf.site_use_id = hzs.site_use_id (+);

        EXCEPTION
            WHEN OTHERS THEN
                      p_resultout := 1;
                      p_errmsg := 'Error while getting party  information from ar_cmgt_case_folders'||
                          ' SqlError '|| sqlerrm;
                      ar_cmgt_util.wf_debug(p_case_folder_id, p_errmsg);
                      return;
        END;


        BEGIN
          /* 6335440 - restructured this sql to use a trick
             that ultimately distills down to the maximum
             financial_data_id on the maximum date that matches
             the parameters (currency,party,customer,site).

             This sql has same result as predecessor only it
             reduces the number of reads on ar_cmgt_financial_data
             to a single read */

          SELECT to_number(
                     substr(
                       max(to_char(curr_fin_st_date, 'YYYYMMDD') ||
                       ltrim(to_char(financial_data_id,
                              '0999999999999999999999')))
                            ,9))
          INTO   l_financial_data_id
          FROM   ar_cmgt_financial_data
          WHERE  reporting_currency = l_limit_currency
          AND    party_id           = l_party_id
          AND    cust_account_id    = l_cust_account_id
          AND    site_use_id        = l_site_use_id;

          EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    NULL;
                  WHEN TOO_MANY_ROWS THEN
                    NULL;
                  WHEN OTHERS THEN
                      p_resultout := 1;
                      p_errmsg := 'Error while getting max data from ar_cmgt_financial_data '||
                          ' SqlError '|| sqlerrm;
                      ar_cmgt_util.wf_debug(p_case_folder_id, p_errmsg);
                      return;

        END;

        SELECT reporting_currency,
               monetary_unit,
               curr_fin_st_date,
               reporting_period,
               cash,
               net_receivables,
               inventories,
               other_cur_assets,
               total_cur_assets,
               net_fixed_assets,
               other_non_cur_assets,
               total_assets,
               accounts_payable,
               short_term_debt,
               other_cur_liabilities,
               total_cur_liabilities,
               long_term_debt,
               other_non_cur_liabilities,
               total_liabilities,
               stockholder_equity,
               total_liabilities_equity,
               revenue,
               cost_of_goods_sold,
               sga_expenses,
               operating_income,
               operating_margin,
               non_operating_income,
               non_operating_expenses,
               pre_tax_net_income,
               income_taxes,
               net_income,
               earnings_per_share
           INTO
                l_reporting_currency,
                l_monetary_unit     ,
                l_curr_fin_st_date  ,
                l_reporting_period  ,
                l_cash              ,
                l_net_receivables   ,
                l_inventories       ,
                l_other_cur_assets  ,
                l_total_cur_assets,
                l_net_fixed_assets,
                l_other_non_cur_assets,
                l_total_assets      ,
                l_accounts_payable  ,
                l_short_term_debt   ,
                l_other_cur_liabilities,
                l_total_cur_liabilities ,
                l_long_term_debt        ,
                l_other_non_cur_liabilities,
                l_total_liabilities        ,
                l_stockholder_equity       ,
                l_total_liabilities_equity ,
                l_revenue                  ,
                l_cost_of_goods_sold       ,
                l_sga_expenses             ,
                l_operating_income         ,
                l_operating_margin         ,
                l_non_operating_income     ,
                l_non_operating_expenses   ,
                l_pre_tax_net_income       ,
                l_income_taxes             ,
                l_net_income               ,
                l_earnings_per_share
           FROM ar_cmgt_financial_data
           WHERE financial_data_id = l_financial_data_id;

   EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN TOO_MANY_ROWS THEN
            NULL;
        WHEN OTHERS THEN
            p_resultout := 1;
            p_errmsg := 'Error while getting records from ar_cmgt_financial_data '||
                          ' SqlError '|| sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_errmsg);
            return;

    END;
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  111,
                p_data_point_value          =>  l_curr_fin_st_date,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  110,
                p_data_point_value          =>  l_monetary_unit,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  109,
                p_data_point_value          =>  l_reporting_currency,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  112,
                p_data_point_value          =>  l_reporting_period,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  113,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_cash),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  114,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_net_receivables),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  115,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_inventories),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  116,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_other_cur_assets),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  117,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_total_cur_assets),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  118,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_net_fixed_assets),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  119,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_other_non_cur_assets),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  120,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_total_assets),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  121,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_accounts_payable),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  122,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_short_term_debt),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  123,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_other_cur_liabilities),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  124,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_total_cur_liabilities),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  125,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_long_term_debt),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  126,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_other_non_cur_liabilities),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  127,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_total_liabilities),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  128,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_stockholder_equity),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  129,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_total_liabilities_equity),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  130,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_revenue),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  131,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_cost_of_goods_sold),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  132,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_sga_expenses),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  133,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_operating_income),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  134,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_operating_margin),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  135,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_non_operating_income),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  136,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_non_operating_expenses),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  137,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_pre_tax_net_income),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  138,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_income_taxes),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  139,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_net_income),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  140,
                p_data_point_value          =>  fnd_number.number_to_canonical(l_earnings_per_share),
                p_mode                      => p_mode,
                p_error_msg                 =>  p_errmsg,
                p_resultout                 =>  p_resultout);
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getfinancialdata()-');
    END IF;

END;



PROCEDURE GetOtherDataPoints (
        p_credit_request_id         IN      NUMBER,
        p_party_id                  IN      NUMBER,
        p_cust_account_id           IN      NUMBER,
        p_site_use_id               IN      NUMBER,
        p_cust_acct_profile_amt_id  IN      NUMBER,
        p_case_folder_id            IN      NUMBER ,
        p_mode                      IN      VARCHAR2 default 'CREATE') IS

    l_case_folder_id            NUMBER;
    l_errmsg                    VARCHAR2(2000);
    l_resultout                 VARCHAR2(1);

    CURSOR c_hz_cust_prof_amts IS
        SELECT trx_credit_limit, overall_credit_limit
        FROM hz_cust_profile_amts
        WHERE cust_acct_profile_amt_id = p_cust_acct_profile_amt_id;

    CURSOR c_hz_parties IS
        SELECT tax_name, year_established,
               sic_code, -- industrial code
               sic_code_type, -- industrial code type
               url,
               employees_total,
               duns_number
        FROM hz_parties
        WHERE party_id = p_party_id;


    CURSOR c_credit_requests IS
        SELECT bond_rating,
               pending_litigations,
               entity_type,
               stock_exchange,
               current_stock_price,
               market_capitalization,
               nvl(limit_amount, trx_amount) requested_amount,
               market_cap_monetary_unit,
               legal_entity_name
        FROM   ar_cmgt_credit_requests
        WHERE  credit_request_id = p_credit_request_id;

    CURSOR c_case_folder IS
        SELECT last_updated, -- last_credit_review_date
               case_folder_number,
               status,
               check_list_id
        FROM   ar_cmgt_case_folders
        WHERE  party_id = p_party_id
        AND    cust_account_id = p_cust_account_id
        AND    site_use_id = p_site_use_id
        AND    type = 'DATA';

    CURSOR c_case_folder_score IS
        SELECT SUM(b.score) score
        FROM   ar_cmgt_case_folders a, ar_cmgt_cf_dtls b
        WHERE  a.party_id = p_party_id
        AND    a.cust_account_id = p_cust_account_id
        AND    a.site_use_id = p_site_use_id
        AND    a.type = 'DATA'
        AND    a.case_folder_id = b.case_folder_id;


BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getotherdatapoints()+');
    END IF;

    FOR c_hz_cust_prof_amts_rec IN c_hz_cust_prof_amts
    LOOP
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  95,
                p_data_point_value          =>  fnd_number.number_to_canonical(c_hz_cust_prof_amts_rec.trx_credit_limit),
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);

       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  96,
                p_data_point_value          =>  fnd_number.number_to_canonical(c_hz_cust_prof_amts_rec.overall_credit_limit),
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       exit;
    END LOOP;

    FOR c_hz_parties_rec IN c_hz_parties
    LOOP

        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  89,
                p_data_point_value          =>  c_hz_parties_rec.tax_name,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);

       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  93,
                p_data_point_value          =>  c_hz_parties_rec.sic_code_type,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  92,
                p_data_point_value          =>  c_hz_parties_rec.sic_code,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  100,
                p_data_point_value          =>  c_hz_parties_rec.url,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  101,
                p_data_point_value          =>  c_hz_parties_rec.employees_total,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  183,
                p_data_point_value          =>  c_hz_parties_rec.duns_number,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
       exit;
    END LOOP;

    FOR c_credit_requests_rec IN c_credit_requests
    LOOP
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  103,
                p_data_point_value          =>  c_credit_requests_rec.bond_rating,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  94,
                p_data_point_value          =>  c_credit_requests_rec.pending_litigations,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  90,
                p_data_point_value          =>  c_credit_requests_rec.entity_type,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  155,
                p_data_point_value          =>  c_credit_requests_rec.stock_exchange,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  98,
                p_data_point_value          =>  fnd_number.number_to_canonical(c_credit_requests_rec.current_stock_price),
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  99,
                p_data_point_value          =>  fnd_number.number_to_canonical(c_credit_requests_rec.market_capitalization),
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  108,
                p_data_point_value          =>  fnd_number.number_to_canonical(c_credit_requests_rec.requested_amount),
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  208,
                p_data_point_value          =>  c_credit_requests_rec.legal_entity_name,
                p_mode                      => p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        exit;
    END LOOP;


    FOR c_case_folder_rec IN c_case_folder
    LOOP
         build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  105, -- last credit review date
                p_data_point_value          =>  c_case_folder_rec.last_updated,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  106, -- last check list used
                p_data_point_value          =>  c_case_folder_rec.check_list_id,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  107, -- last case folder
                p_data_point_value          =>  c_case_folder_rec.case_folder_number,
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        exit;
   END LOOP;
    FOR c_case_folder_score_rec IN c_case_folder_score
    LOOP
         build_case_folder_details(
                p_case_folder_id            =>  p_case_folder_id,
                p_data_point_id             =>  30, -- last calculated credit score
                p_data_point_value          =>  fnd_number.number_to_canonical(c_case_folder_score_rec.score),
                p_mode                      =>  p_mode,
                p_error_msg                 =>  l_errmsg,
                p_resultout                 =>  l_resultout);
        exit;
    END LOOP;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.getotherdatapoints()-');
    END IF;
END;


PROCEDURE populate_aging_data
        (p_case_folder_id       IN          NUMBER,
         p_mode                 IN          VARCHAR2 default 'CREATE',
         p_error_msg            OUT NOCOPY  VARCHAR2,
         p_resultout            OUT NOCOPY  VARCHAR2) IS

CURSOR aging_cur  IS
  SELECT age.aging_bucket_id,age.aging_bucket_line_id
  FROM   AR_CMGT_SETUP_OPTIONS sys,
         ar_aging_bucket_lines age
  WHERE  sys.aging_bucket_id = age.aging_bucket_id;

  l_outstanding_balance NUMBER;
  l_dispute_amount   NUMBER;
  l_customer_id number;
  l_party_id number;
  l_cust_account_id number;
  l_customer_site_use_id number;
  l_as_of_date date;
  l_currency_code fnd_currencies.currency_code%TYPE;
  l_format_currency varchar2(15);
  l_credit_option varchar2(16);
  l_invoice_type_low ra_cust_trx_types.name%TYPE;
  l_invoice_type_high ra_cust_trx_types.name%TYPE;
  l_bucket_name ar_aging_buckets.bucket_name%TYPE;
  l_bucket_titletop_0 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_0 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_0 number;
  l_bucket_titletop_1 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_1 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_1 number;
  l_bucket_titletop_2 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_2 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_2 number;
  l_bucket_titletop_3 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_3 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_3 number;
  l_bucket_titletop_4 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_4 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_4 number;
  l_bucket_titletop_5 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_5 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_5 number;
  l_bucket_titletop_6 ar_aging_bucket_lines.report_heading1%TYPE;
  l_bucket_titlebottom_6 ar_aging_bucket_lines.report_heading2%TYPE;
  l_bucket_amount_6 number;
  l_outstanding_amount number;

  l_check_flag VARCHAR2(1);
  l_counter  NUMBER;

  l_credit_request_id  NUMBER;
  l_exchange_rate_type VARCHAR2(50);

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.populate_aging_data()+');
    END IF;

  l_check_flag := 'Y';

  BEGIN
    SELECT DECODE(party_id,-99,NULL,party_id),
           DECODE(cust_account_id,-99,NULL,cust_account_id),
           DECODE(site_use_id,-99,NULL,site_use_id),
           limit_currency,
           credit_request_id
    INTO   l_party_id,
           l_cust_account_id,
           l_customer_site_use_id,
           l_currency_code,
           l_credit_request_id
    FROM   ar_cmgt_case_folders
  WHERE  case_folder_id = p_case_folder_id;
   EXCEPTION
     WHEN others THEN
     l_check_flag := 'N';
  END;

  BEGIN
      SELECT age.bucket_name,
             default_exchange_rate_type
      INTO   l_bucket_name,
             l_exchange_rate_type
      FROM   AR_CMGT_SETUP_OPTIONS sys,
             ar_aging_buckets age
      WHERE  sys.aging_bucket_id = age.aging_bucket_id;
   EXCEPTION
   WHEN others THEN
     l_check_flag := 'N';
  END;

  IF l_check_flag = 'Y' THEN
      AR_CMGT_AGING.calc_aging_buckets (
        p_party_id              => l_party_id,
        p_customer_id           => l_cust_account_id,
        p_site_use_id           => l_customer_site_use_id,
        p_currency_code         => l_currency_code,
        p_credit_option         => 'AGE',
        p_bucket_name           => l_bucket_name,
        p_org_id                => NULL,
        p_exchange_rate_type    => l_exchange_rate_type,
        p_outstanding_balance   => l_outstanding_balance,
        p_bucket_titletop_0     => l_bucket_titletop_0,
        p_bucket_titlebottom_0  => l_bucket_titlebottom_0,
        p_bucket_amount_0       => l_bucket_amount_0,
        p_bucket_titletop_1     => l_bucket_titletop_1,
        p_bucket_titlebottom_1  => l_bucket_titlebottom_1,
        p_bucket_amount_1       => l_bucket_amount_1,
        p_bucket_titletop_2     => l_bucket_titletop_2,
        p_bucket_titlebottom_2  => l_bucket_titlebottom_2,
        p_bucket_amount_2       => l_bucket_amount_2,
        p_bucket_titletop_3     => l_bucket_titletop_3,
        p_bucket_titlebottom_3  => l_bucket_titlebottom_3,
        p_bucket_amount_3       => l_bucket_amount_3,
        p_bucket_titletop_4     => l_bucket_titletop_4,
        p_bucket_titlebottom_4  => l_bucket_titlebottom_4,
        p_bucket_amount_4       => l_bucket_amount_4,
        p_bucket_titletop_5     => l_bucket_titletop_5,
        p_bucket_titlebottom_5  => l_bucket_titlebottom_5,
        p_bucket_amount_5       => l_bucket_amount_5,
        p_bucket_titletop_6     => l_bucket_titletop_6,
        p_bucket_titlebottom_6  => l_bucket_titlebottom_6,
        p_bucket_amount_6       => l_bucket_amount_6
       );
      l_counter := 0;

      FOR aging_rec IN aging_cur LOOP

        IF l_counter = 0  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_0,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_0,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_0,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_0,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 1  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_1,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_1,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_1,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_1,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 2  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_2,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_2,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_2,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_2,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 3  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_3,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_3,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_3,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_3,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 4  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_4,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_4,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_4,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_4,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 5  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_5,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_5,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_5,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_5,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        IF l_counter = 6  THEN
         IF p_mode = 'CREATE'
         THEN
            ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => p_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_6,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            IF p_resultout <> 0
            THEN
                return;
            END IF;
            IF g_data_case_folder_exists = 'Y' -- for data record
            THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_6,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            ELSIF g_data_case_folder_exists = 'N'
            THEN
                ar_cmgt_controls.populate_aging_dtls
                (p_case_folder_id   => g_data_case_folder_id,
                 p_aging_bucket_id  => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount              =>  l_bucket_amount_6,
                 p_error_msg           => p_error_msg,
                 p_resultout           => p_resultout);
            END IF;
            IF p_resultout <> 0
            THEN
                return;
            END IF;
         ELSIF p_mode = 'REFRESH'
         THEN
                ar_cmgt_controls.update_aging_dtls
                (p_case_folder_id       => p_case_folder_id,
                 p_aging_bucket_id      => aging_rec.aging_bucket_id,
                 p_aging_bucket_line_id => aging_rec.aging_bucket_line_id,
                 p_amount               =>  l_bucket_amount_6,
                 p_error_msg            => p_error_msg,
                 p_resultout            => p_resultout);

                IF p_resultout <> 0
                THEN
                    return;
                END IF;

         END IF; -- end of p_mode if
        END IF;
        l_counter := l_counter + 1;
      END LOOP;
     END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.populate_aging_data()-');
    END IF;
end populate_aging_data;


PROCEDURE populate_dnb_data(
            p_case_folder_id            IN      NUMBER,
            p_source_table_name         IN      VARCHAR2,
            p_source_key                IN      VARCHAR2,
            p_source_key_column_name    IN      VARCHAR2,
            p_mode                      IN      VARCHAR2 default 'CREATE',
            p_source_key_type           IN      VARCHAR2 default NULL,
            p_source_key_column_type    IN      VARCHAR2 default NULL) IS

l_errmsg        VARCHAR2(4000);
l_resultout     VARCHAR2(1);

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.populate_dnb_data()+');
    END IF;

    -- call table handler to insert into ar_cmgt_cf_dnb_dtls.
    IF p_mode = 'CREATE'
    THEN
          AR_CMGT_CONTROLS.populate_dnb_data(
                  p_case_folder_id          => p_case_folder_id,
                  p_source_table_name       => p_source_table_name,
                  p_source_key              => p_source_key,
                  p_source_key_type         => p_source_key_type,
                  p_source_key_column_name  => p_source_key_column_name,
                  p_source_key_column_type  => p_source_key_column_type,
                  p_errmsg                  => l_errmsg,
                  p_resultout               => l_resultout);

    ELSIF p_mode = 'REFRESH'
    THEN
            UPDATE ar_cmgt_cf_dnb_dtls
                SET  source_key  =  p_source_key,
                     last_updated_by = fnd_global.user_id,
                     last_update_date = sysdate,
                     last_update_login = fnd_global.login_id
            WHERE case_folder_id = p_case_folder_id
            AND   source_table_name = p_source_table_name
            AND   nvl(source_key,'X')        = nvl(p_source_key,'X')
            AND   nvl(source_key_type,'X') = nvl(p_source_key_type,'X')
            AND   nvl(source_key_column_name,'X') = nvl(p_source_key_column_name,'X')
            AND   nvl(source_key_column_type_name,'X') = nvl(p_source_key_column_type,'X');
            -- Bug fix for 3566584
            -- Dnb data won't be updated if it was not created
            -- as part of case folder generation. So if user
            -- purchased dnb data leter on then it will not be updated.
            IF ( SQL%NOTFOUND )
            THEN
                AR_CMGT_CONTROLS.populate_dnb_data(
                    p_case_folder_id          => p_case_folder_id,
                    p_source_table_name       => p_source_table_name,
                    p_source_key              => p_source_key,
                    p_source_key_type         => p_source_key_type,
                    p_source_key_column_name  => p_source_key_column_name,
                    p_source_key_column_type  => p_source_key_column_type,
                    p_errmsg                  => l_errmsg,
                    p_resultout               => l_resultout);
            END IF;


    END IF;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.populate_dnb_data()-');
    END IF;
END;


PROCEDURE  build_case_folder
            (p_party_id                 IN      NUMBER,
             p_cust_account_id          IN      NUMBER,
             p_cust_acct_site_id        IN      NUMBER,
             p_limit_currency           IN      VARCHAR2,
             p_exchange_rate_type       IN      VARCHAR2,
             p_check_list_id            IN      NUMBER default NULL,
             p_credit_request_id        IN      NUMBER default NULL,
             p_score_model_id           IN      NUMBER default NULL,
             p_credit_classification    IN      VARCHAR2 default NULL,
             p_review_type              IN      VARCHAR2 default NULL,
             p_case_folder_number       IN      VARCHAR2 default NULL,
             p_case_folder_id           OUT nocopy     NUMBER,
             p_error_msg                OUT nocopy     VARCHAR2,
             p_resultout                OUT nocopy     VARCHAR2) AS

l_case_folder_number            ar_cmgt_case_folders.case_folder_number%TYPE;
l_case_folder_id                ar_cmgt_case_folders.case_folder_id%TYPE;
BEGIN
        p_resultout := 0;
        g_data_case_folder_exists := 'N';
        -- Get id from sequence
        SELECT  ar_cmgt_case_folders_s.nextval
        INTO    p_case_folder_id
        FROM    dual;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_case_folder()+');
    END IF;

        -- check if case folder number is passed by calling program
        IF p_case_folder_number IS NULL
        THEN
             SELECT  ar_cmgt_case_folder_number_s.nextval
             INTO    l_case_folder_number
             FROM    dual;
        ELSE
            l_case_folder_number := p_case_folder_number;
        END IF;
        -- insert into case_folder table
        AR_CMGT_CONTROLS.populate_case_folder (
                   p_case_folder_id         =>  p_case_folder_id,
                   p_case_folder_number     =>  l_case_folder_number,
                   p_credit_request_id      =>  p_credit_request_id,
                   p_check_list_id          =>  p_check_list_id,
                   p_status                 =>  'O',
                   p_cust_account_id        =>  nvl(p_cust_account_id,-99),
                   p_party_id               =>  p_party_id,
                   p_cust_acct_site_id      =>  nvl(p_cust_acct_site_id,-99),
                   p_score_model_id         =>  p_score_model_id,
                   p_credit_classification  =>  p_credit_classification,
                   p_review_type            =>  p_review_type,
                   p_limit_currency         =>  p_limit_currency,
                   p_exchange_rate_type     =>  p_exchange_rate_type,
                   p_type                   =>  'CASE',
                   p_errmsg                 =>   p_error_msg,
                   p_resultout              =>   p_resultout);
        IF p_resultout <> 0
        THEN
            return;
        END IF;
        -- check whether there are any 'DATA' records for the party,account and site
        -- combination. If not exist insert a new record.

        BEGIN
            SELECT  case_folder_id
            INTO    g_data_case_folder_id
            FROM    ar_cmgt_case_folders
            WHERE   party_id = p_party_id
            AND     cust_account_id = p_cust_account_id
            AND     site_use_id     = p_cust_acct_site_id
            -- AND     limit_currency  = p_limit_currency
            AND     type            = 'DATA';

            g_data_case_folder_exists := 'Y';
        -- update case folder number in case data exists

           UPDATE   ar_cmgt_case_folders
               set  case_folder_number = l_case_folder_number,
                    check_list_id = p_check_list_id,
                    score_model_id = p_score_model_id,
                    limit_currency = p_limit_currency,
                    exchange_rate_type = p_exchange_rate_type,
                    credit_classification = p_credit_classification,
                    last_update_date = SYSDATE,
                    last_updated_by = fnd_global.user_id,
                    last_update_login = fnd_global.login_id,
                    last_updated = sysdate,
                    credit_request_id = p_credit_request_id
            WHERE   party_id = p_party_id
            AND     cust_account_id = p_cust_account_id
            AND     site_use_id     = p_cust_acct_site_id
            AND     type            = 'DATA';

            g_data_case_folder_exists := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
               BEGIN
                    SELECT  ar_cmgt_case_folders_s.nextval
                    INTO    g_data_case_folder_id
                    FROM    dual;
                    g_data_case_folder_exists := 'N';
                AR_CMGT_CONTROLS.populate_case_folder (
                     p_case_folder_id       => g_data_case_folder_id,
                     p_case_folder_number   => l_case_folder_number,
                     p_credit_request_id    =>  p_credit_request_id,
                     p_check_list_id          =>  p_check_list_id,
                     p_party_id             => p_party_id,
                     p_cust_account_id      => p_cust_account_id,
                     p_cust_acct_site_id    => p_cust_acct_site_id,
                     p_score_model_id         =>  p_score_model_id,
                     p_credit_classification => p_credit_classification,
                     p_type                 => 'DATA',
                     p_limit_currency       =>  p_limit_currency,
                     p_exchange_rate_type   =>  p_exchange_rate_type,
                     p_errmsg               => p_error_msg,
                     p_resultout            => p_resultout);


                    IF p_resultout <> 0
                    THEN
                        return;
                    END IF;
               END;
            WHEN OTHERS THEN
                 p_error_msg := 'Unable to create case folder DATA records for' ||
                                'party id '|| to_char(p_party_id) ||' Cust Account Id '||
                                to_char(p_cust_account_id)||' Cust Account Site Use Id '||
                                to_char(p_cust_acct_site_id) ||'Sql Error '||sqlerrm;
                 p_resultout := '1';
                 ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
        END;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
                      'CR:' || p_credit_request_id || ' => CF:' ||
                            p_case_folder_id);
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_case_folder()-');
    END IF;

END build_case_folder;

PROCEDURE BUILD_DNB_SCORABLE_FIN_DATA (
  p_case_folder_id      IN    NUMBER,
  p_mode            IN    VARCHAR2 default 'CREATE',
  p_financial_report_id   IN    NUMBER,
  p_financial_report_type   IN    VARCHAR2,
  p_error_msg             OUT nocopy     VARCHAR2,
  p_resultout             OUT nocopy     VARCHAR2)  IS

  CURSOR cFinancialReports IS
        SELECT  ESTIMATED_IND,
          CONSOLIDATED_IND,
          REPORT_START_DATE,
          REPORT_END_DATE,
        DATE_REPORT_ISSUED,
        AUDIT_IND,
        FORECAST_IND,
        FISCAL_IND,
        FINAL_IND,
        SIGNED_BY_PRINCIPALS_IND,
        RESTATED_IND,
        UNBALANCED_IND,
        QUALIFIED_IND,
        OPENING_IND,
        PROFORMA_IND,
        TRIAL_BALANCE_IND
    FROM hz_financial_reports
    WHERE  financial_report_id = p_financial_report_id;

  l_ESTIMATED_IND     hz_financial_reports.ESTIMATED_IND%type;
  l_CONSOLIDATED_IND    hz_financial_reports.CONSOLIDATED_IND%type;
  l_REPORT_START_DATE   hz_financial_reports.REPORT_START_DATE%type;
  l_REPORT_END_DATE     hz_financial_reports.REPORT_END_DATE%type;
  l_DATE_REPORT_ISSUED    hz_financial_reports.DATE_REPORT_ISSUED%type;
  l_AUDIT_IND       hz_financial_reports.AUDIT_IND%type;
  l_FORECAST_IND      hz_financial_reports.FORECAST_IND%type;
  l_FISCAL_IND        hz_financial_reports.FISCAL_IND%type;
  l_FINAL_IND       hz_financial_reports.FINAL_IND%type;
  l_SIGNED_BY_PRINCIPALS_IND  hz_financial_reports.SIGNED_BY_PRINCIPALS_IND%type;
  l_RESTATED_IND      hz_financial_reports.RESTATED_IND%type;
  l_UNBALANCED_IND      hz_financial_reports.UNBALANCED_IND%type;
  l_QUALIFIED_IND     hz_financial_reports.QUALIFIED_IND%type;
  l_OPENING_IND       hz_financial_reports.OPENING_IND%type;
  l_PROFORMA_IND      hz_financial_reports.PROFORMA_IND%type;
  l_TRIAL_BALANCE_IND   hz_financial_reports.TRIAL_BALANCE_IND%type;

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_scorable_fin_data()+');
    END IF;

    FOR cFinancialReportsRec IN cFinancialReports
    LOOP
      l_ESTIMATED_IND     := cFinancialReportsRec.ESTIMATED_IND;
      l_CONSOLIDATED_IND    := cFinancialReportsRec.CONSOLIDATED_IND;
      l_REPORT_START_DATE   := cFinancialReportsRec.REPORT_START_DATE;
      l_REPORT_END_DATE     := cFinancialReportsRec.REPORT_END_DATE;
      l_DATE_REPORT_ISSUED    := cFinancialReportsRec.DATE_REPORT_ISSUED;
      l_AUDIT_IND       := cFinancialReportsRec.AUDIT_IND;
      l_FORECAST_IND      := cFinancialReportsRec.FORECAST_IND;
      l_FISCAL_IND        := cFinancialReportsRec.FISCAL_IND;
      l_FINAL_IND       := cFinancialReportsRec.FINAL_IND;
      l_SIGNED_BY_PRINCIPALS_IND  := cFinancialReportsRec.SIGNED_BY_PRINCIPALS_IND;
      l_RESTATED_IND      := cFinancialReportsRec.RESTATED_IND;
      l_UNBALANCED_IND      := cFinancialReportsRec.UNBALANCED_IND;
      l_QUALIFIED_IND     := cFinancialReportsRec.QUALIFIED_IND;
      l_OPENING_IND       := cFinancialReportsRec.OPENING_IND;
      l_PROFORMA_IND      := cFinancialReportsRec.PROFORMA_IND;
      l_TRIAL_BALANCE_IND   := cFinancialReportsRec.TRIAL_BALANCE_IND;
    END LOOP;

    IF p_financial_report_type = 'BALANCE_SHEET'
    THEN
      build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11099,
            p_data_point_value => l_AUDIT_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

      build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11100,
            p_data_point_value => l_CONSOLIDATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11101,
            p_data_point_value => l_ESTIMATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11103,
            p_data_point_value => l_FISCAL_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

      build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11102,
            p_data_point_value => l_FORECAST_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11109,
            p_data_point_value => l_OPENING_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11110,
            p_data_point_value => l_PROFORMA_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11108,
            p_data_point_value => l_QUALIFIED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

      build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11106,
            p_data_point_value => l_RESTATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11105,
            p_data_point_value => l_SIGNED_BY_PRINCIPALS_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11111,
            p_data_point_value => l_TRIAL_BALANCE_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

          build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11107,
            p_data_point_value => l_UNBALANCED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);
        ELSIF p_financial_report_type = 'INCOME'
        THEN
            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11096,
            p_data_point_value => l_DATE_REPORT_ISSUED,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11094,
            p_data_point_value => l_REPORT_START_DATE,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11095,
            p_data_point_value => l_REPORT_END_DATE,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);
        ELSIF p_financial_report_type = 'ANNUAL_SALES'
        THEN
            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11087,
            p_data_point_value => l_CONSOLIDATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11086,
            p_data_point_value => l_ESTIMATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

    ELSIF p_financial_report_type = 'TANGIBLE'
        THEN
            build_case_folder_details(
            p_case_folder_id  => p_case_folder_id,
            p_data_point_id   => 11080,
            p_data_point_value => l_ESTIMATED_IND,
            p_mode             => p_mode,
            p_error_msg   => p_error_msg,
            p_resultout   => p_resultout);

    END IF;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_scorable_fin_data()-');
    END IF;
END;

PROCEDURE BUILD_DNB_SCOREABLE_DATA (
    p_case_folder_id    IN      NUMBER,
    p_mode              IN      VARCHAR2 default 'CREATE',
    p_org_profile_id    IN      NUMBER,
    p_credit_rating_id  IN      NUMBER,
    p_location_id   IN    NUMBER,
    p_balance_sheet_id  IN      NUMBER,
    p_income_statement_id IN    NUMBER,
    p_tangible_net_worth_id IN  NUMBER,
    p_annual_sales_volume_id  IN    NUMBER,
    p_resultout         OUT nocopy     VARCHAR2,
    p_error_msg         OUT nocopy     VARCHAR2) IS

    l_control_yr            hz_organization_profiles.control_yr%type;
    l_incorp_year           hz_organization_profiles.incorp_year%type;
    l_year_established      hz_organization_profiles.year_established%type;
    l_employees_total       hz_organization_profiles.employees_total%type;
    l_total_payments        hz_organization_profiles.total_payments%type;
    l_maximum_credit_reco   hz_organization_profiles.maximum_credit_recommendation%type;
    l_oob_ind               hz_organization_profiles.oob_ind%type;
    l_TOTAL_EMPLOYEES_IND hz_organization_profiles.TOTAL_EMPLOYEES_IND%type;
        l_SIC_CODE        hz_organization_profiles.SIC_CODE%type;
        l_RENT_OWN_IND      hz_organization_profiles.RENT_OWN_IND%type;
        l_REGISTRATION_TYPE   hz_organization_profiles.REGISTRATION_TYPE%type;
        l_LEGAL_STATUS      hz_organization_profiles.LEGAL_STATUS%type;
        l_HQ_BRANCH_IND     hz_organization_profiles.HQ_BRANCH_IND%type;
        l_BRANCH_FLAG     hz_organization_profiles.BRANCH_FLAG%type;
        l_LOCAL_ACTIVITY_CODE_TYPE  hz_organization_profiles.LOCAL_ACTIVITY_CODE_TYPE%type;
        l_LOCAL_ACTIVITY_CODE hz_organization_profiles.LOCAL_ACTIVITY_CODE%type;
        l_SIC_CODE_TYPE     hz_organization_profiles.SIC_CODE_TYPE%type;
        l_GLOBAL_FAILURE_SCORE  hz_organization_profiles.GLOBAL_FAILURE_SCORE%type;
        l_IMPORT_IND      hz_organization_profiles.IMPORT_IND%type;
        l_DUNS_NUMBER_C     hz_organization_profiles.DUNS_NUMBER_C%type;
        l_PARENT_SUB_IND    hz_organization_profiles.PARENT_SUB_IND%type;
        l_FAILURE_SCORE     hz_organization_profiles.FAILURE_SCORE%type;
        l_FAILURE_SCORE_COMMENTARY  hz_organization_profiles.FAILURE_SCORE_COMMENTARY%type;
        l_TOTAL_EMP_EST_IND   hz_organization_profiles.TOTAL_EMP_EST_IND%type;

    l_PAYDEX_SCORE                      Number;
    l_PAYDEX_THREE_MONTHS_AGO           Number;
    l_AVG_HIGH_CREDIT                   HZ_CREDIT_RATINGS.AVG_HIGH_CREDIT%type;
    l_HIGH_CREDIT                       HZ_CREDIT_RATINGS.HIGH_CREDIT%type;
    l_CREDIT_SCORE_CLASS                HZ_CREDIT_RATINGS.CREDIT_SCORE_CLASS%type;
    l_CREDIT_SCORE_NATL_PERCENTILE      HZ_CREDIT_RATINGS.CREDIT_SCORE_NATL_PERCENTILE%type;
    l_CREDIT_SCORE_INCD_DEFAULT         HZ_CREDIT_RATINGS.CREDIT_SCORE_INCD_DEFAULT%type;
    l_CREDIT_SCORE_AGE                  HZ_CREDIT_RATINGS.CREDIT_SCORE_AGE%type;
    l_FAILURE_SCORE_CLASS               HZ_CREDIT_RATINGS.FAILURE_SCORE_CLASS%type;
    l_FAILURE_SCORE_NATNL_PERCENT       HZ_CREDIT_RATINGS.FAILURE_SCORE_NATNL_PERCENTILE%type;
    l_FAILURE_SCORE_INCD_DEFAULT        HZ_CREDIT_RATINGS.FAILURE_SCORE_INCD_DEFAULT%type;
    l_FAILURE_SCORE_AGE                 HZ_CREDIT_RATINGS.FAILURE_SCORE_AGE%type;
    l_LOW_RNG_DELQ_SCR                  HZ_CREDIT_RATINGS.LOW_RNG_DELQ_SCR%type;
    l_HIGH_RNG_DELQ_SCR                 HZ_CREDIT_RATINGS.HIGH_RNG_DELQ_SCR%type;
    l_DELQ_PMT_RNG_PRCNT                HZ_CREDIT_RATINGS.DELQ_PMT_RNG_PRCNT%type;
    l_DELQ_PMT_PCTG_FOR_ALL_FIRMS       HZ_CREDIT_RATINGS.DELQ_PMT_PCTG_FOR_ALL_FIRMS%type;
    l_NUM_TRADE_EXPERIENCES             HZ_CREDIT_RATINGS.NUM_TRADE_EXPERIENCES%type;
    l_DEBARMENTS_COUNT                  HZ_CREDIT_RATINGS.NUM_SPCL_EVENT%type;
    l_BANKRUPTCY_IND                    HZ_CREDIT_RATINGS.BANKRUPTCY_IND%type;
    l_DEBARMENT_IND                     HZ_CREDIT_RATINGS.DEBARMENT_IND%type;
    l_BUSINESS_DISCONTINUED       HZ_CREDIT_RATINGS.BUSINESS_DISCONTINUED%type;
  l_NUM_SPCL_EVENT          HZ_CREDIT_RATINGS.NUM_SPCL_EVENT%type;
  l_MAXIMUM_CREDIT_CURRENCY_CODE    HZ_CREDIT_RATINGS.MAXIMUM_CREDIT_CURRENCY_CODE%type;
  l_CREDIT_SCORE            HZ_CREDIT_RATINGS.CREDIT_SCORE%type;
  l_CREDIT_SCORE_OVERRIDE_CODE    HZ_CREDIT_RATINGS.CREDIT_SCORE_OVERRIDE_CODE%type;
  l_PRNT_BKCY_CHAPTER_CONV      HZ_CREDIT_RATINGS.PRNT_BKCY_CHAPTER_CONV%type;
  l_NUM_PRNT_BKCY_CONVS       HZ_CREDIT_RATINGS.NUM_PRNT_BKCY_CONVS%type;
  l_PRNT_BKCY_FILG_CHAPTER      HZ_CREDIT_RATINGS.PRNT_BKCY_FILG_CHAPTER%type;
  l_PRNT_BKCY_FILG_TYPE       HZ_CREDIT_RATINGS.PRNT_BKCY_FILG_TYPE%type;
  l_NUM_PRNT_BKCY_FILING        HZ_CREDIT_RATINGS.NUM_PRNT_BKCY_FILING%type;
  l_NO_TRADE_IND            HZ_CREDIT_RATINGS.NO_TRADE_IND%type;
  l_JUDGEMENT_IND           HZ_CREDIT_RATINGS.JUDGEMENT_IND%type;
  l_LIEN_IND              HZ_CREDIT_RATINGS.LIEN_IND%type;
  l_SUIT_IND              HZ_CREDIT_RATINGS.SUIT_IND%type;
  l_PAYDEX_INDUSTRY_DAYS        HZ_CREDIT_RATINGS.PAYDEX_INDUSTRY_DAYS%type;
  l_FINCL_LGL_EVENT_IND       HZ_CREDIT_RATINGS.FINCL_LGL_EVENT_IND%type;
  l_DISASTER_IND            HZ_CREDIT_RATINGS.DISASTER_IND%type;
  l_CRIMINAL_PROCEEDING_IND     HZ_CREDIT_RATINGS.CRIMINAL_PROCEEDING_IND%type;
  l_FINCL_EMBT_IND          HZ_CREDIT_RATINGS.FINCL_EMBT_IND%type;
  l_PAYDEX_NORM           HZ_CREDIT_RATINGS.PAYDEX_NORM%type;
  l_RATING              HZ_CREDIT_RATINGS.RATING%type;
  l_SECURED_FLNG_IND          HZ_CREDIT_RATINGS.SECURED_FLNG_IND%type;
  l_CLAIMS_IND            HZ_CREDIT_RATINGS.CLAIMS_IND%type;
  l_SUIT_JUDGE_IND          HZ_CREDIT_RATINGS.SUIT_JUDGE_IND%type;
  l_DET_HISTORY_IND         HZ_CREDIT_RATINGS.DET_HISTORY_IND%type;
  l_OTHER_SPEC_EVNT_IND       HZ_CREDIT_RATINGS.OTHER_SPEC_EVNT_IND%type;
  l_OPRG_SPEC_EVNT_IND        HZ_CREDIT_RATINGS.OPRG_SPEC_EVNT_IND%type;
  l_CREDIT_SCORE_COMMENTARY     HZ_CREDIT_RATINGS.CREDIT_SCORE_COMMENTARY%type;
  l_country             hz_locations.country%type;


    l_cash_liqu_asset                   NUMBER;
    l_ar                                NUMBER;
    l_ap                                NUMBER;
    l_an_sales_vol                      NUMBER;
    l_auth_cap                          NUMBER;
    l_cost_of_sales                     NUMBER;
    l_current_ratio                     NUMBER;
    l_dividends                         NUMBER;
    l_fixed_assets                      NUMBER;
    l_gross_inc                         NUMBER;
    l_intg_asset                        NUMBER;
    l_inventory                         NUMBER;
    l_iss_capital                       NUMBER;
    l_long_debt                         NUMBER;
    l_net_income                        NUMBER;
    l_net_worth                         NUMBER;
    l_nom_capital                       NUMBER;
    l_paid_in_capital                   NUMBER;
    l_prev_sales                        NUMBER;
    l_prev_net_worth                    NUMBER;
    l_prev_work_cap                     NUMBER;
    l_profit_bef_tax                    NUMBER;
    l_quick_ratio                       NUMBER;
    l_ret_earnings                      NUMBER;
    l_sales                             NUMBER;
    l_tang_net_worth                    NUMBER;
    l_tot_assets                        NUmBER;
    l_tot_curr_assets                   NUMBER;
    l_tot_curr_liab                     NUMBER;
    l_tot_liab                          NUMBER;
    l_tot_liab_equ                      NUMBER;
    l_tot_long_liab                     NUMBER;


    CURSOR cDNBSore IS
        SELECT data_element_id, source_table_name, source_column_name
        FROM ar_cmgt_dnb_elements_vl
        WHERE scorable_flag = 'Y';

    CURSOR cOrgProf IS
        SELECT control_yr,
               incorp_year,
               year_established,
               employees_total,
               total_payments,
               maximum_credit_recommendation,
               oob_ind,
               TOTAL_EMP_EST_IND
               TOTAL_EMPLOYEES_IND,
               SIC_CODE,
               RENT_OWN_IND,
               REGISTRATION_TYPE,
               LEGAL_STATUS,
               HQ_BRANCH_IND,
               BRANCH_FLAG,
               LOCAL_ACTIVITY_CODE_TYPE,
               LOCAL_ACTIVITY_CODE,
               SIC_CODE_TYPE,
               GLOBAL_FAILURE_SCORE,
               IMPORT_IND,
               DUNS_NUMBER_C,
               TOTAL_EMP_EST_IND,
               PARENT_SUB_IND,
               FAILURE_SCORE,
               FAILURE_SCORE_COMMENTARY

        FROM   hz_organization_profiles
        WHERE  organization_profile_id = p_org_profile_id;

    CURSOR cCrRatings IS
        SELECT  decode(PAYDEX_SCORE,'UN', null, paydex_score ) paydex_score,
                decode(paydex_three_months_ago, 'UN', null, paydex_three_months_ago ) paydex_three_months_ago,
                AVG_HIGH_CREDIT,
                HIGH_CREDIT,
                CREDIT_SCORE_NATL_PERCENTILE,
                CREDIT_SCORE_INCD_DEFAULT,
                CREDIT_SCORE_AGE,
                FAILURE_SCORE_CLASS,
                FAILURE_SCORE_NATNL_PERCENTILE,
                FAILURE_SCORE_INCD_DEFAULT,
                FAILURE_SCORE_AGE,
                LOW_RNG_DELQ_SCR,
                HIGH_RNG_DELQ_SCR,
                DELQ_PMT_RNG_PRCNT,
                DELQ_PMT_PCTG_FOR_ALL_FIRMS,
                NUM_TRADE_EXPERIENCES,
                DEBARMENTS_COUNT,
                BANKRUPTCY_IND,
                DEBARMENT_IND,
                BUSINESS_DISCONTINUED,
        NUM_SPCL_EVENT,
        MAXIMUM_CREDIT_CURRENCY_CODE,
        CREDIT_SCORE,
        CREDIT_SCORE_CLASS,
        CREDIT_SCORE_OVERRIDE_CODE,
        PRNT_BKCY_CHAPTER_CONV,
        NUM_PRNT_BKCY_CONVS,
        PRNT_BKCY_FILG_CHAPTER,
        PRNT_BKCY_FILG_TYPE,
        NUM_PRNT_BKCY_FILING,
        NO_TRADE_IND,
        JUDGEMENT_IND,
        LIEN_IND,
        SUIT_IND,
        PAYDEX_INDUSTRY_DAYS,
        FINCL_LGL_EVENT_IND,
        DISASTER_IND,
        CRIMINAL_PROCEEDING_IND,
        FINCL_EMBT_IND,
        PAYDEX_NORM,
        RATING,
        SECURED_FLNG_IND,
        CLAIMS_IND,
        SUIT_JUDGE_IND,
        DET_HISTORY_IND,
        OTHER_SPEC_EVNT_IND,
        OPRG_SPEC_EVNT_IND,
        CREDIT_SCORE_COMMENTARY
        FROM HZ_CREDIT_RATINGS
        WHERE  credit_rating_id = p_credit_rating_id;

    CURSOR cFinNum  IS
        SELECT FINANCIAL_number, financial_number_name
        FROM   hz_financial_numbers
        WHERE  financial_report_id in ( SELECT source_key
                            from ar_cmgt_cf_dnb_dtls
                            WHERE  source_table_name = 'HZ_FINANCIAL_REPORTS'
                            and    case_folder_id = p_case_folder_id);

    CURSOR cGetLocation IS
      SELECT COUNTRY
      FROM   hz_locations
      where  location_id = p_location_id;

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_scorable_data()+');
    END IF;

   FOR cOrgProfRec IN cOrgProf
   LOOP
        l_control_yr            := cOrgProfRec.control_yr;
        l_incorp_year           := cOrgProfRec.incorp_year;
        l_year_established      := cOrgProfRec.year_established;
        l_employees_total       := cOrgProfRec.employees_total;
        l_total_payments        := cOrgProfRec.total_payments;
        l_maximum_credit_reco   := cOrgProfRec.maximum_credit_recommendation;
        l_oob_ind               := cOrgProfRec.oob_ind;


        l_TOTAL_EMPLOYEES_IND := cOrgProfRec.TOTAL_EMPLOYEES_IND;
        l_SIC_CODE        := cOrgProfRec.SIC_CODE;
        l_RENT_OWN_IND      := cOrgProfRec.RENT_OWN_IND;
        l_REGISTRATION_TYPE   := cOrgProfRec.REGISTRATION_TYPE;
        l_LEGAL_STATUS      := cOrgProfRec.LEGAL_STATUS;
        l_HQ_BRANCH_IND     := cOrgProfRec.HQ_BRANCH_IND;
        l_BRANCH_FLAG     := cOrgProfRec.BRANCH_FLAG;
        l_LOCAL_ACTIVITY_CODE_TYPE  := cOrgProfRec.LOCAL_ACTIVITY_CODE_TYPE;
        l_LOCAL_ACTIVITY_CODE := cOrgProfRec.LOCAL_ACTIVITY_CODE;
        l_SIC_CODE_TYPE     := cOrgProfRec.SIC_CODE_TYPE;
        l_GLOBAL_FAILURE_SCORE  := cOrgProfRec.GLOBAL_FAILURE_SCORE;
        l_IMPORT_IND      := cOrgProfRec.IMPORT_IND;
        l_DUNS_NUMBER_C     := cOrgProfRec.DUNS_NUMBER_C;
        l_PARENT_SUB_IND    := cOrgProfRec.PARENT_SUB_IND;
        l_FAILURE_SCORE     := cOrgProfRec.FAILURE_SCORE;
        l_FAILURE_SCORE_COMMENTARY  := cOrgProfRec.FAILURE_SCORE_COMMENTARY;
        l_TOTAL_EMP_EST_IND   := cOrgProfRec.TOTAL_EMP_EST_IND;

   END LOOP;

    build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11022,
          p_data_point_value => l_TOTAL_EMPLOYEES_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

      build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11029,
          p_data_point_value => l_SIC_CODE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11038,
          p_data_point_value => l_RENT_OWN_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11037,
          p_data_point_value => l_REGISTRATION_TYPE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11036,
          p_data_point_value => l_LEGAL_STATUS,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11035,
          p_data_point_value => l_HQ_BRANCH_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11034,
          p_data_point_value => l_BRANCH_FLAG,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11032,
          p_data_point_value => l_LOCAL_ACTIVITY_CODE_TYPE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11031,
          p_data_point_value => l_LOCAL_ACTIVITY_CODE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11030,
          p_data_point_value => l_SIC_CODE_TYPE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11117,
          p_data_point_value => l_GLOBAL_FAILURE_SCORE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11114,
          p_data_point_value => l_IMPORT_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11001,
          p_data_point_value => l_DUNS_NUMBER_C,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11131,
          p_data_point_value => l_PARENT_SUB_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11152,
          p_data_point_value => l_FAILURE_SCORE,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11153,
          p_data_point_value => l_FAILURE_SCORE_COMMENTARY,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

        build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11023,
          p_data_point_value => l_TOTAL_EMP_EST_IND,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

   /* Noticed this weird logic.  probably a bug
      if there are multiple countries */
   FOR cGetLocationRec in cGetLocation
   LOOP
      l_country := cGetLocationRec.country;

   END LOOP;
      build_case_folder_details(
          p_case_folder_id  => p_case_folder_id,
          p_data_point_id   => 11010,
          p_data_point_value => l_country,
          p_mode             => p_mode,
          p_error_msg   => p_error_msg,
          p_resultout   => p_resultout);

   FOR cCrRatingsRec IN cCrRatings
   LOOP
        l_PAYDEX_SCORE              := cCrRatingsRec.PAYDEX_SCORE;
        l_PAYDEX_THREE_MONTHS_AGO   := cCrRatingsRec.PAYDEX_THREE_MONTHS_AGO;
        l_AVG_HIGH_CREDIT           := cCrRatingsRec.AVG_HIGH_CREDIT;
        l_HIGH_CREDIT               := cCrRatingsRec.HIGH_CREDIT;
        l_CREDIT_SCORE_CLASS        := cCrRatingsRec.CREDIT_SCORE_CLASS;
        l_CREDIT_SCORE_NATL_PERCENTILE := cCrRatingsRec.CREDIT_SCORE_NATL_PERCENTILE;
        l_CREDIT_SCORE_INCD_DEFAULT := cCrRatingsRec.CREDIT_SCORE_INCD_DEFAULT;
        l_CREDIT_SCORE_AGE          := cCrRatingsRec.CREDIT_SCORE_AGE;
        l_FAILURE_SCORE_CLASS       := cCrRatingsRec.FAILURE_SCORE_CLASS;
        l_FAILURE_SCORE_NATNL_PERCENT  := cCrRatingsRec.FAILURE_SCORE_NATNL_PERCENTILE;
        l_FAILURE_SCORE_INCD_DEFAULT := cCrRatingsRec.FAILURE_SCORE_INCD_DEFAULT;
        l_FAILURE_SCORE_AGE         := cCrRatingsRec.FAILURE_SCORE_AGE;
        l_LOW_RNG_DELQ_SCR          := cCrRatingsRec.LOW_RNG_DELQ_SCR;
        l_HIGH_RNG_DELQ_SCR         := cCrRatingsRec.HIGH_RNG_DELQ_SCR;
        l_DELQ_PMT_RNG_PRCNT        := cCrRatingsRec.DELQ_PMT_RNG_PRCNT;
        l_DELQ_PMT_PCTG_FOR_ALL_FIRMS   := cCrRatingsRec.DELQ_PMT_PCTG_FOR_ALL_FIRMS;
        l_NUM_TRADE_EXPERIENCES         := cCrRatingsRec.NUM_TRADE_EXPERIENCES;
        l_NUM_PRNT_BKCY_FILING          := cCrRatingsRec.NUM_PRNT_BKCY_FILING;
        l_DEBARMENTS_COUNT              := cCrRatingsRec.DEBARMENTS_COUNT;
        l_BANKRUPTCY_IND                := cCrRatingsRec.BANKRUPTCY_IND;
        l_DEBARMENT_IND                 := cCrRatingsRec.DEBARMENT_IND;
      l_BUSINESS_DISCONTINUED     := cCrRatingsRec.BUSINESS_DISCONTINUED;
    l_NUM_SPCL_EVENT        := cCrRatingsRec.NUM_SPCL_EVENT;
    l_MAXIMUM_CREDIT_CURRENCY_CODE  := cCrRatingsRec.MAXIMUM_CREDIT_CURRENCY_CODE;
    l_CREDIT_SCORE          := cCrRatingsRec.CREDIT_SCORE;
    l_CREDIT_SCORE_OVERRIDE_CODE  := cCrRatingsRec.CREDIT_SCORE_OVERRIDE_CODE;
    l_PRNT_BKCY_CHAPTER_CONV    := cCrRatingsRec.PRNT_BKCY_CHAPTER_CONV;
    l_NUM_PRNT_BKCY_CONVS     := cCrRatingsRec.NUM_PRNT_BKCY_CONVS;
    l_PRNT_BKCY_FILG_CHAPTER    := cCrRatingsRec.PRNT_BKCY_FILG_CHAPTER;
    l_PRNT_BKCY_FILG_TYPE     := cCrRatingsRec.PRNT_BKCY_FILG_TYPE;
    l_NO_TRADE_IND          := cCrRatingsRec.NO_TRADE_IND;
    l_JUDGEMENT_IND         := cCrRatingsRec.JUDGEMENT_IND;
    l_LIEN_IND            := cCrRatingsRec.LIEN_IND;
    l_SUIT_IND            := cCrRatingsRec.SUIT_IND;
    l_PAYDEX_INDUSTRY_DAYS      := cCrRatingsRec.PAYDEX_INDUSTRY_DAYS;
    l_FINCL_LGL_EVENT_IND     := cCrRatingsRec.FINCL_LGL_EVENT_IND;
    l_DISASTER_IND          := cCrRatingsRec.DISASTER_IND;
    l_CRIMINAL_PROCEEDING_IND   := cCrRatingsRec.CRIMINAL_PROCEEDING_IND;
    l_FINCL_EMBT_IND        := cCrRatingsRec.FINCL_EMBT_IND;
    l_PAYDEX_NORM         := cCrRatingsRec.PAYDEX_NORM;
    l_RATING            := cCrRatingsRec.RATING;
    l_SECURED_FLNG_IND        := cCrRatingsRec.SECURED_FLNG_IND;
    l_CLAIMS_IND          := cCrRatingsRec.CLAIMS_IND;
    l_SUIT_JUDGE_IND        := cCrRatingsRec.SUIT_JUDGE_IND;
    l_DET_HISTORY_IND       := cCrRatingsRec.DET_HISTORY_IND;
    l_OTHER_SPEC_EVNT_IND     := cCrRatingsRec.OTHER_SPEC_EVNT_IND;
    l_OPRG_SPEC_EVNT_IND      := cCrRatingsRec.OPRG_SPEC_EVNT_IND;
    l_CREDIT_SCORE_COMMENTARY   := cCrRatingsRec.CREDIT_SCORE_COMMENTARY;

   END LOOP;

   -- Now populate the case folder
   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11017,
       p_data_point_value => l_control_yr,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11018,
       p_data_point_value => l_incorp_year,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11019,
       p_data_point_value => l_year_established,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11020,
       p_data_point_value => l_employees_total ,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11048,
       p_data_point_value => l_total_payments,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11118,
       p_data_point_value => l_maximum_credit_reco,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11043,
       p_data_point_value => l_PAYDEX_SCORE,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11044,
       p_data_point_value => l_PAYDEX_THREE_MONTHS_AGO,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11046,
       p_data_point_value => l_AVG_HIGH_CREDIT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11047,
       p_data_point_value => l_HIGH_CREDIT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11143,
       p_data_point_value => l_CREDIT_SCORE_CLASS,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11144,
       p_data_point_value => l_CREDIT_SCORE_NATL_PERCENTILE,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11145,
       p_data_point_value => l_CREDIT_SCORE_INCD_DEFAULT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);
    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11146,
       p_data_point_value => l_CREDIT_SCORE_AGE,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11154,
       p_data_point_value => l_FAILURE_SCORE_CLASS,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11155,
       p_data_point_value => l_FAILURE_SCORE_NATNL_PERCENT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11156,
       p_data_point_value => l_FAILURE_SCORE_INCD_DEFAULT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11157,
       p_data_point_value => l_FAILURE_SCORE_AGE,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11162,
       p_data_point_value => l_LOW_RNG_DELQ_SCR,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11163,
       p_data_point_value => l_HIGH_RNG_DELQ_SCR ,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

     build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11164,
       p_data_point_value => l_DELQ_PMT_RNG_PRCNT ,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

     build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11165,
       p_data_point_value => l_DELQ_PMT_PCTG_FOR_ALL_FIRMS ,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

     build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11166,
       p_data_point_value => l_NUM_TRADE_EXPERIENCES ,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);


    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11195,
       p_data_point_value => l_DEBARMENTS_COUNT,
       p_mode             => p_mode,
       p_error_msg   => p_error_msg,
       p_resultout   => p_resultout);

   build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11175,
       p_data_point_value => l_BANKRUPTCY_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11194,
       p_data_point_value => l_DEBARMENT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11050,
       p_data_point_value => l_oob_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);
       ------------------------
    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11188,
       p_data_point_value => l_BUSINESS_DISCONTINUED,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

  build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11190,
       p_data_point_value => l_NUM_SPCL_EVENT,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11119,
       p_data_point_value => l_MAXIMUM_CREDIT_CURRENCY_CODE,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11141,
       p_data_point_value => l_CREDIT_SCORE,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);


    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11160,
       p_data_point_value => l_CREDIT_SCORE_OVERRIDE_CODE,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11184,
       p_data_point_value => l_PRNT_BKCY_CHAPTER_CONV,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11182,
       p_data_point_value => l_NUM_PRNT_BKCY_CONVS,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11180,
       p_data_point_value => l_PRNT_BKCY_FILG_CHAPTER,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11179,
       p_data_point_value => l_PRNT_BKCY_FILG_TYPE,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11178,
       p_data_point_value => l_NUM_PRNT_BKCY_FILING,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11176,
       p_data_point_value => l_NO_TRADE_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11174,
       p_data_point_value => l_JUDGEMENT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11173,
       p_data_point_value => l_LIEN_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11172,
       p_data_point_value => l_SUIT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11169,
       p_data_point_value => l_PAYDEX_INDUSTRY_DAYS,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11054,
       p_data_point_value => l_FINCL_LGL_EVENT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11052,
       p_data_point_value => l_DISASTER_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11051,
       p_data_point_value => l_CRIMINAL_PROCEEDING_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11049,
       p_data_point_value => l_FINCL_EMBT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11045,
       p_data_point_value => l_PAYDEX_NORM,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11116,
       p_data_point_value => l_RATING,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11060,
       p_data_point_value => l_SECURED_FLNG_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11059,
       p_data_point_value => l_CLAIMS_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11058,
       p_data_point_value => l_SUIT_JUDGE_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11057,
       p_data_point_value => l_DET_HISTORY_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11056,
       p_data_point_value => l_OTHER_SPEC_EVNT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

    build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11055,
       p_data_point_value => l_OPRG_SPEC_EVNT_IND,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);

  build_case_folder_details(
       p_case_folder_id  => p_case_folder_id,
       p_data_point_id   => 11142,
       p_data_point_value => l_CREDIT_SCORE_COMMENTARY,
       p_mode             => p_mode,
       p_error_msg      => p_error_msg,
       p_resultout   => p_resultout);


    FOR cFinNumRec IN cFinNum
    LOOP
        IF cFinNumRec.financial_number_name = 'CASH_LIQ_ASSETS'
        THEN
            l_cash_liqu_asset := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'ACCOUNTS_RECEIVABLE'
        THEN
            l_ar := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'ACCOUNTS_PAYABLE'
        THEN
            l_ap := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'ANNUAL_SALES_VOLUME'
        THEN
            l_an_sales_vol := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'AUTHORIZED_CAPITAL'
        THEN
            l_auth_cap := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'COST_OF_SALES'
        THEN
            l_cost_of_sales := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'CURRENT_RATIO'
        THEN
            l_current_ratio := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'DIVIDENDS'
        THEN
            l_dividends := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'FIXED_ASSETS'
        THEN
            l_fixed_assets := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'GROSS_INCOME'
        THEN
            l_gross_inc := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'INTANGIBLE_ASSETS'
        THEN
            l_intg_asset := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'INVENTORY'
        THEN
            l_inventory := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'ISSUED_CAPITAL'
        THEN
            l_iss_capital := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'LONG_TERM_DEBT'
        THEN
            l_long_debt := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'NET_INCOME'
        THEN
            l_net_income := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'NET_WORTH'
        THEN
            l_net_worth := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'NOMINAL_CAPITAL'
        THEN
            l_nom_capital := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'PAID_IN_CAPITAL'
        THEN
            l_paid_in_capital := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'PREVIOUS_SALES'
        THEN
            l_prev_sales := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'PREV_NET_WORTH'
        THEN
            l_prev_net_worth := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'PREV_WORKING_CAPITAL'
        THEN
            l_prev_work_cap := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'PROFIT_BEFORE_TAX'
        THEN
            l_profit_bef_tax := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'QUICK_RATIO'
        THEN
            l_quick_ratio := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'RETAINED_EARNINGS'
        THEN
            l_ret_earnings := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'SALES'
        THEN
            l_sales := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TANGIBLE_NET_WORTH'
        THEN
            l_tang_net_worth := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOTAL_ASSETS'
        THEN
            l_tot_assets := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOTAL_CURRENT_ASSETS'
        THEN
            l_tot_curr_assets := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOTAL_CURR_LIABILITIES'
        THEN
            l_tot_curr_liab := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOTAL_LIABILITIES'
        THEN
            l_tot_liab := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOTAL_LIAB_EQUITY'
        THEN
            l_tot_liab_equ := cFinNumRec.financial_number;
        ELSIF cFinNumRec.financial_number_name = 'TOT_LONG_TERM_LIAB'
        THEN
            l_tot_long_liab := cFinNumRec.financial_number;
        END IF;
    END LOOP;
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11061,
                p_data_point_value => l_cash_liqu_asset,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11062,
                p_data_point_value => l_ar,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11063,
                p_data_point_value => l_ap,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11067,
                p_data_point_value => l_inventory,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11068,
                p_data_point_value => l_fixed_assets,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11069,
                p_data_point_value => l_tot_curr_assets,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11070,
                p_data_point_value => l_tot_curr_liab,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11071,
                p_data_point_value => l_tot_assets,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11072,
                p_data_point_value => l_intg_asset,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11073,
                p_data_point_value => l_long_debt,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11074,
                p_data_point_value => l_tot_long_liab,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11075,
                p_data_point_value => l_tot_liab,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11076,
                p_data_point_value => l_ret_earnings,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11077,
                p_data_point_value => l_dividends,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11078,
                p_data_point_value => l_net_worth,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11079,
                p_data_point_value => l_tang_net_worth,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11082,
                p_data_point_value =>l_prev_net_worth ,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11083,
                p_data_point_value => l_tot_liab_equ,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11084,
                p_data_point_value => l_sales,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11085,
                p_data_point_value => l_an_sales_vol,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11089,
                p_data_point_value => l_prev_sales,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11090,
                p_data_point_value => l_cost_of_sales,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11091,
                p_data_point_value => l_gross_inc,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11092,
                p_data_point_value => l_net_income,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11112,
                p_data_point_value => l_current_ratio,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
    build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => 11113,
                p_data_point_value => l_quick_ratio,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);

  -- populate all financial report releated data
  BUILD_DNB_SCORABLE_FIN_DATA (
      p_case_folder_id    => p_case_folder_id,
      p_mode          => p_mode,
      p_financial_report_id   => p_balance_sheet_id,
      p_financial_report_type => 'BALANCE_SHEET' ,
      p_error_msg       => p_error_msg,
      p_resultout     => p_resultout);

  BUILD_DNB_SCORABLE_FIN_DATA (
      p_case_folder_id    => p_case_folder_id,
      p_mode          => p_mode,
      p_financial_report_id   => p_income_statement_id,
      p_financial_report_type => 'INCOME' ,
      p_error_msg       => p_error_msg,
      p_resultout     => p_resultout);

  BUILD_DNB_SCORABLE_FIN_DATA (
      p_case_folder_id    => p_case_folder_id,
      p_mode          => p_mode,
      p_financial_report_id   => p_tangible_net_worth_id,
      p_financial_report_type => 'TANGIBLE' ,
      p_error_msg       => p_error_msg,
      p_resultout     => p_resultout);

  BUILD_DNB_SCORABLE_FIN_DATA (
      p_case_folder_id    => p_case_folder_id,
      p_mode          => p_mode,
      p_financial_report_id   => p_annual_sales_volume_id,
      p_financial_report_type => 'ANNUAL_SALES' ,
      p_error_msg       => p_error_msg,
      p_resultout     => p_resultout);

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_scorable_data()-');
    END IF;
END BUILD_DNB_SCOREABLE_DATA;


PROCEDURE BUILD_DNB_CASE_FOLDER(
        p_party_id          IN      NUMBER,
        p_check_list_id     IN      NUMBER,
        p_case_folder_id    IN      NUMBER,
        p_mode              IN      VARCHAR2 default 'CREATE',
        p_resultout         OUT nocopy     VARCHAR2,
        p_error_msg         OUT nocopy     VARCHAR2) IS

l_organization_profile_id           hz_organization_profiles.organization_profile_id%TYPE;
l_location_id                       hz_locations.location_id%TYPE;
l_contact_point_id                  hz_contact_points.contact_point_id%TYPE;
l_relationship_id                   hz_relationships.relationship_id%TYPE;
l_report_type                       hz_financial_reports.type_of_financial_report%TYPE := 'BALANCE_SHEET';
l_credit_rating_id                  NUMBER;
l_financial_report_id               NUMBER;
l_hq_branch_ind                     hz_parties.hq_branch_ind%type;
l_balance_sheet_id                  NUMBER;
l_income_statement_id               NUMBER;
l_tangible_net_worth_id             NUMBER;
l_annual_sales_volume_id            NUMBER;

CURSOR c_relationships IS
       SELECT  rel.relationship_id, rel.relationship_code
        FROM    hz_relationships rel
        WHERE   rel.object_id = p_party_id
         AND    rel.relationship_code in ('HEADQUARTERS_OF','PARENT_OF',
                                          'DOMESTIC_ULTIMATE_OF','GLOBAL_ULTIMATE_OF')
         AND    rel.actual_content_source = 'DNB'
         AND    rel.start_date <= sysdate
         AND    NVL(rel.end_date, to_date('12/31/4712','MM/DD/YYYY')) > sysdate
         AND    rel.subject_table_name = 'HZ_PARTIES'
         AND    rel.object_table_name = 'HZ_PARTIES';

CURSOR c_contact_point IS
    SELECT  contact_point_id, phone_line_type
    FROM    hz_contact_points
    WHERE   owner_table_name = 'HZ_PARTIES'
    AND     owner_table_id   = p_party_id
    AND     contact_point_type = 'PHONE'
    AND     actual_content_source = 'DNB'
    AND     phone_line_type in ('FAX','GEN')
    AND     status = 'A';

CURSOR c_dnb_data_point IS
    SELECT data_point_id
    FROM   ar_cmgt_data_points_vl
    WHERE  data_point_category = 'DNB';



BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_case_folder()+');
    END IF;
    p_resultout := 0;
    -- build the case folder details table for DNB data. In case of
    -- dnb data datpoint value will be null.
    FOR c_dnb_data_point_rec IN c_dnb_data_point
    LOOP
        build_case_folder_details(
                p_case_folder_id  => p_case_folder_id,
                p_data_point_id   => c_dnb_data_point_rec.data_point_id,
                p_data_point_value => NULL,
                p_mode             => p_mode,
                p_error_msg   => p_error_msg,
                p_resultout   => p_resultout);
        IF p_resultout <> 0
        THEN
            p_error_msg := 'Error while populating DNB data, Data Points Id: '||
                            c_dnb_data_point_rec.data_point_id;
            return;
        END IF;

    END LOOP;

    -- disable the policy function in hz tables
    -- so that Enable the visibility of DNB data
    hz_common_pub.disable_cont_source_security;
    -- Get all primary keys from HZ table for DNB reports

    -- Get information from hz_party
    BEGIN
        SELECT hq_branch_ind
        INTO   l_hq_branch_ind
        FROM   hz_parties
        WHERE  party_id = p_party_id;

        populate_dnb_data(
            p_case_folder_id        =>      p_case_folder_id,
            p_source_table_name     =>      'HZ_PARTIES',
            p_source_key            =>      p_party_id,
            p_source_key_column_name =>     'PARTY_ID',
            p_mode                   =>     p_mode);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            p_resultout := 1;
            p_error_msg := 'SqlError While retrieving Data from HZ_PARTIES '||sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
            return;
    END;

    -- Get organization profile ID

    BEGIN
        SELECT  ORGANIZATION_PROFILE_ID
        INTO    l_organization_profile_id
        FROM    HZ_ORGANIZATION_PROFILES
        WHERE   party_id = p_party_id
        AND     effective_end_date IS NULL
        AND     ACTUAL_CONTENT_SOURCE = 'DNB';

        populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_ORGANIZATION_PROFILES',
                p_source_key                =>  l_organization_profile_id,
                p_source_key_column_name    =>  'ORGANIZATION_PROFILE_ID',
                p_mode                      =>  p_mode);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            p_resultout := 1;
            p_error_msg := 'SqlError While retrieving Data from HZ_ORGANIZATION_PROFILES '||sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
            return;
    END;
    -- Get location id
    l_location_id := hz_dnbui_pvt.get_location_id(p_party_id, 'DNB');
    IF ( l_location_id IS NOT NULL )
    THEN

        populate_dnb_data(
                p_case_folder_id        =>  p_case_folder_id,
                p_source_table_name     =>  'HZ_LOCATIONS',
                p_source_key            =>  l_location_id,
                p_source_key_column_name => 'LOCATION_ID',
                p_mode                  =>  p_mode);
    END IF;

    -- Get contact point id for phone line type 'GEN'

    FOR c_contact_point_rec IN c_contact_point
    LOOP

        populate_dnb_data(
             p_case_folder_id           =>  p_case_folder_id,
             p_source_table_name        =>  'HZ_CONTACT_POINTS',
             p_source_key               =>  c_contact_point_rec.contact_point_id,
             p_source_key_column_name   =>  'CONTACT_POINT_ID',
             p_mode                     =>  p_mode,
             p_source_key_type          =>  c_contact_point_rec.phone_line_type,
             p_source_key_column_type   =>  'CONTACT_POINT_TYPE');
    END LOOP;

    -- get credit ratings
    l_credit_rating_id := hz_dnbui_pvt.get_max_credit_rating_id(p_party_id, 'DNB');

    IF l_credit_rating_id IS NOT NULL
    THEN
        populate_dnb_data(
            p_case_folder_id        =>  p_case_folder_id,
            p_source_table_name     =>  'HZ_CREDIT_RATINGS',
            p_source_key            =>  l_credit_rating_id,
            p_source_key_column_name => 'CREDIT_RATING_ID',
            p_mode                  =>  p_mode
            );
    END IF;
    -- get financial report id for Balance Sheet
    l_financial_report_id :=
            hz_dnbui_pvt.get_max_financial_report_id(p_party_id,'BALANCE_SHEET','DNB');
    l_balance_sheet_id := l_financial_report_id;
    IF l_financial_report_id IS NOT NULL
    THEN
            populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_FINANCIAL_REPORTS',
                p_source_key                =>  l_financial_report_id,
                p_source_key_column_name    =>  'FINANCIAL_REPORT_ID',
                p_mode                      =>  p_mode,
                p_source_key_type           =>  'BALANCE_SHEET',
                p_source_key_column_type    =>  'TYPE_OF_FINANCIAL_REPORT');

    END IF;

    l_financial_report_id :=
            hz_dnbui_pvt.get_max_financial_report_id(p_party_id,'INCOME_STATEMENT','DNB');
    l_income_statement_id := l_financial_report_id;
    IF l_financial_report_id IS NOT NULL
    THEN
            populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_FINANCIAL_REPORTS',
                p_source_key                =>  l_financial_report_id,
                p_source_key_column_name    =>  'FINANCIAL_REPORT_ID',
                p_mode                      =>  p_mode,
                p_source_key_type           =>  'INCOME_STATEMENT',
                p_source_key_column_type    =>  'TYPE_OF_FINANCIAL_REPORT');

    END IF;

    l_financial_report_id :=
            hz_dnbui_pvt.get_max_financial_report_id(p_party_id,'TANGIBLE_NET_WORTH','DNB');
    l_tangible_net_worth_id := l_financial_report_id;

    IF l_financial_report_id IS NOT NULL
    THEN
            populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_FINANCIAL_REPORTS',
                p_source_key                =>  l_financial_report_id,
                p_source_key_column_name    =>  'FINANCIAL_REPORT_ID',
                p_mode                      =>  p_mode,
                p_source_key_type           =>  'TANGIBLE_NET_WORTH',
                p_source_key_column_type    =>  'TYPE_OF_FINANCIAL_REPORT');

    END IF;

    -- Build all the scorable data points which is releated to Tangible_net_worth


    l_financial_report_id :=
            hz_dnbui_pvt.get_max_financial_report_id(p_party_id,'ANNUAL_SALES_VOLUME','DNB');
    l_annual_sales_volume_id := l_financial_report_id;
    IF l_financial_report_id IS NOT NULL
    THEN
            populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_FINANCIAL_REPORTS',
                p_source_key                =>  l_financial_report_id,
                p_source_key_column_name    =>  'FINANCIAL_REPORT_ID',
                p_mode                      =>  p_mode,
                p_source_key_type           =>  'ANNUAL_SALES_VOLUME',
                p_source_key_column_type    =>  'TYPE_OF_FINANCIAL_REPORT');

    END IF;


   /* -- populate relationship model
    FOR c_relationship_rec IN c_relationships
    LOOP
            populate_dnb_data(
                p_case_folder_id            =>  p_case_folder_id,
                p_source_table_name         =>  'HZ_RELATIONSHIPS',
                p_source_key                =>  c_relationship_rec.relationship_id,
                p_source_key_column_name    =>  'RELATIONSHIP_ID',
                p_mode                      =>  p_mode,
                p_source_key_type           =>  c_relationship_rec.relationship_code,
                p_source_key_column_type    =>  'RELATIONSHIP_CODE'
                );
    END LOOP;
    */
    -- Now create the scorable data into case folder table

    BUILD_DNB_SCOREABLE_DATA
            (p_case_folder_id   => p_case_folder_id,
             p_mode             => p_mode,
             p_org_profile_id   => l_organization_profile_id,
             p_credit_rating_id => l_credit_rating_id,
             p_location_id    => l_location_id,
             p_balance_sheet_id => l_balance_sheet_id,
             p_income_statement_id   => l_income_statement_id,
             p_tangible_net_worth_id   => l_tangible_net_worth_id,
             p_annual_sales_volume_id  => l_annual_sales_volume_id,
             p_resultout        =>  p_resultout,
             p_error_msg        =>  p_error_msg );

    -- disable the visibility of DNB data
    hz_common_pub.enable_cont_source_security;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(p_case_folder_id,
              'ar_cmgt_data_points_pkg.build_dnb_case_folder()-');
    END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_resultout := 1;
            p_error_msg := 'Error while populating DNB data '||sqlerrm;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
END;


FUNCTION get_conversion_type( p_credit_request_id IN NUMBER)
    return VARCHAR2 IS

    CURSOR getCreditRequestDetails (p_cr_req_id IN NUMBER)
    IS
        select credit_check_rule_id,
        source_name
        from   ar_cmgt_credit_requests
        where  credit_request_id = p_cr_req_id;


    CURSOR getRateTYpeFromCreditChkRule(p_cr_chk_rule_id IN NUMBER) IS
        select conversion_type
        from  oe_credit_check_rules
        where credit_check_rule_id = p_cr_chk_rule_id;

    CURSOR getRateTypeFromSetup
    IS
        SELECT default_exchange_rate_type
        FROM ar_cmgt_setup_options;

    l_rule_id               NUMBER;
    l_source_name           VARCHAR2(50);
    l_exchange_rate_type    VARCHAR2(50);

begin

    IF (p_credit_request_id IS NOT NULL )
    THEN

        OPEN getCreditRequestDetails(p_credit_request_id );

        FETCH getCreditRequestDetails  INTO l_rule_id, l_source_name;
        IF NVL(l_source_name,'X') = 'OM' AND
                (l_rule_id IS NOT NULL) THEN

            OPEN getRateTYpeFromCreditChkRule(l_rule_id);
                FETCH getRateTYpeFromCreditChkRule INTO l_exchange_rate_type;
            CLOSE getRateTYpeFromCreditChkRule;
        END IF;

        IF l_exchange_rate_type IS NULL  THEN

            OPEN getRateTypeFromSetup;
            FETCH getRateTypeFromSetup INTO l_exchange_rate_type;

            CLOSE getRateTypeFromSetup;
        END IF;

    END IF;

    RETURN l_exchange_rate_type;

END;
/* kosrinv ..Changing The procedure to store the data point values in a proper format ..
             bug 5525814     ...............*/
PROCEDURE GATHER_DATA_POINTS(
            p_party_id              IN   NUMBER,
            p_cust_account_id       IN   NUMBER,
            p_cust_acct_site_id     IN   NUMBER,
            p_trx_currency          IN   VARCHAR2,
            p_org_id                IN   NUMBER,
            p_check_list_id         IN   NUMBER,
            p_credit_request_id     IN   NUMBER,
            p_score_model_id        IN   NUMBER,
            p_credit_classification IN   VARCHAR2,
            p_review_type           IN   VARCHAR2,
            p_case_folder_number    IN   VARCHAR2,
            p_mode                  IN   VARCHAR2,
            p_limit_currency        OUT nocopy  VARCHAR2,
            p_case_folder_id        IN OUT nocopy  NUMBER,
            p_error_msg             OUT nocopy  VARCHAR2,
            p_resultout             OUT nocopy  VARCHAR2) IS



l_curr_array_list               curr_array_type;
l_check_list_id                 ar_cmgt_check_lists.check_list_id%type;
summary_rec_str                 VARCHAR2(4000);
l_certified_dso_days            ar_cmgt_setup_options.cer_dso_days%type;
l_data_point_id                 NUMBER;
l_data_point_name               ar_cmgt_data_points_vl.data_point_name%type;
l_case_folder_id                NUMBER;
l_error_msg                     VARCHAR2(4000);
l_resultout                     VARCHAR2(2000);
l_period                        ar_cmgt_setup_options.period%type;
l_data_point_value              ar_cmgt_cf_dtls.data_point_value%type;
l_start_pos                     NUMBER;
l_end_pos                       NUMBER;
l_combo_string                  VARCHAR2(100);
l_data_point_id_end_pos         NUMBER;
l_global_exposure_flag          hz_credit_usage_rule_sets_b.global_exposure_flag%type;
l_analysis_level                VARCHAR2(1);
l_trx_limit                     NUMBER;
l_limit_currency                VARCHAR2(30);
l_include_all_flag              VARCHAR2(1);
l_curr_tbl                      HZ_CREDIT_USAGES_PKG.curr_tbl_type;
l_excl_curr_list                VARCHAR2(2000);
l_exchange_rate_type            ar_cmgt_setup_options.default_exchange_rate_type%type;
l_overall_limit                 NUMBER;
l_cust_acct_profile_amt_id      NUMBER;
l_case_folder_id_1              number;
l_dso                           number;
l_ddso                          number;
l_deno_dso                      number := 1;
l_deno_ddso                     number := 1;
l_numerator_dso                 number;
l_numerator_ddso                number;
l_party_number                  hz_parties.party_number%type;
l_score                         number;



-- No. of coulmns in each cursor. if select columns in any of the cursor we need to
-- change these numberes.
summary_rec_col_count           NUMBER := 30;
bal_summary_rec_col_count       NUMBER := 23;


/*********** CAUTIONS **********************************************
-- if you are adding/removing  an column in this cursor please
-- update the summary_rec_col_count varibale with proper number.
-- case receipts amount (156) is stored in summary tables as -ve
-- So we are multiplying to -1 to show the opposite value as part of
-- bug fixes 2824382.
********************************************************************/
CURSOR c_party_summary IS
    SELECT
           '8'||'^'||fnd_number.number_to_canonical(SUM(days_credit_granted)) days_credit_granted,
           '13'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_count)) nsf_payment_count,
           '14'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_amount)) nsf_payment_amount,
           '17'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_value)) credit_memo_value,
           '18'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_count)) credit_memo_count,
           '21'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid)-
                                SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_promptly,
           '22'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_late,
           '23'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_disc_inv_inst)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_with_discount,
           '41'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_amount)) inv_paid_amount,
           '42'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_count)) inv_paid_count,
           '43'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_value)) earned_disc_value,
           '44'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_count)) earned_disc_count,
           '45'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_value)) unearned_disc_value,
           '46'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_count)) unearned_disc_count,
           '156'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_value)) total_cash_receipts_value,
           '157'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_count)) total_cash_receipts_count,
           '158'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_value)) total_invoices_value,
           '159'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_count)) total_invoices_count,
           '160'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_value)) total_bills_receivables_value,
           '161'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_count)) total_bills_receivables_count,
           '162'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_value)) total_debit_memos_value,
           '163'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_count)) total_debit_memos_count,
           '164'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_value)) total_chargeback_value,
           '165'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_count)) total_chargeback_count,
           '166'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_value)) total_adjustments_value,
           '167'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_count)) total_adjustments_count,
           '168'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_value)) total_deposits_value,
           '169'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_count)) total_deposits_count
      FROM ( SELECT
            round(SUM(NVL(DAYS_CREDIT_GRANTED_SUM,0))/
                 decode(SUM(NVL(TOTAL_INVOICES_VALUE,0)),0,1,
                        SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) days_credit_granted, -- days credit granted
            SUM(NVL(NSF_STOP_PAYMENT_COUNT,0)) nsf_payment_count, -- NSF/Stop Payment Count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(NSF_STOP_PAYMENT_AMOUNT,0))),2) nsf_payment_amount, -- NSF/Stop Payment Amount
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CREDIT_MEMOS_VALUE,0))),2) credit_memo_value, -- Credit memos value
            SUM(NVL(TOTAL_CREDIT_MEMOS_COUNT,0)) credit_memo_count, -- Credit memos count
           /* 8692948 - sum the counts (by currency) here but do the math
              up above */
            SUM(NVL(count_of_tot_inv_inst_paid,0))  x_tot_inv_inst_paid,
            SUM(NVL(count_of_inv_inst_paid_late,0)) x_tot_inv_inst_paid_late,
            SUM(NVL(count_of_disc_inv_inst,0))      x_tot_disc_inv_inst,
           /* End 8692948 */
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(INV_PAID_AMOUNT,0))),2) inv_paid_amount, -- invoices paid amount
            SUM(NVL(count_of_tot_inv_inst_paid,0)) inv_paid_count, -- invoices paid count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_EARNED_DISC_VALUE,0))),2) earned_disc_value, -- Earned Dscount Value
            SUM(NVL(TOTAL_EARNED_DISC_COUNT,0)) earned_disc_count, -- Earned Dscount count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_UNEARNED_DISC_VALUE,0))),2) unearned_disc_value, -- UnEarned Dscount Value
            SUM(NVL(TOTAL_UNEARNED_DISC_COUNT,0)) unearned_disc_count, -- UnEarned Dscount count
            (round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CASH_RECEIPTS_VALUE,0))),2) * -1) total_cash_receipts_value, -- see the comment above
            SUM(NVL(TOTAL_CASH_RECEIPTS_COUNT,0)) total_cash_receipts_count,
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) total_invoices_value,
             SUM(TOTAL_INVOICES_COUNT) total_invoices_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_BILLS_RECEIVABLES_VALUE,0))),2) total_bills_receivables_value,
             SUM(NVL(TOTAL_BILLS_RECEIVABLES_COUNT,0)) TOTAL_BILLS_RECEIVABLES_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEBIT_MEMOS_VALUE,0))),2) total_debit_memos_value,
             SUM(NVL(TOTAL_DEBIT_MEMOS_COUNT,0)) TOTAL_debit_memos_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CHARGEBACK_VALUE,0))),2) total_chargeback_value,
             SUM(NVL(TOTAL_chargeback_COUNT,0)) TOTAL_chargeback_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_ADJUSTMENTS_VALUE,0))),2) total_adjustments_value,
             SUM(NVL(TOTAL_adjustments_COUNT,0)) TOTAL_adjustments_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEPOSITS_VALUE,0))),2) total_deposits_value,
             SUM(NVL(TOTAL_deposits_COUNT,0)) TOTAL_deposits_count
             FROM   AR_TRX_SUMMARY
             WHERE  CUST_ACCOUNT_ID in (select cust_account_id
                               FROM   hz_cust_accounts
                               WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= sysdate
                                  and effective_end_date >= sysdate
                                  and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  g_source_name <> 'LNS'
                                  union select p_party_id from dual
                                  UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                             ))
              and   CURRENCY     IN  ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
                 /*( SELECT * FROM
                                      TABLE(CAST(l_curr_array_list AS curr_array_type))) */
             and    as_of_date  >= ADD_MONTHS(sysdate,(-l_period))
             group by currency );


CURSOR c_account_summary IS
    SELECT
           '8'||'^'||fnd_number.number_to_canonical(SUM(days_credit_granted)) days_credit_granted,
           '13'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_count)) nsf_payment_count,
           '14'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_amount)) nsf_payment_amount,
           '17'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_value)) credit_memo_value,
           '18'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_count)) credit_memo_count,
           '21'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid)-
                                SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_promptly,
           '22'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_late,
           '23'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_disc_inv_inst)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_with_discount,
           '41'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_amount)) inv_paid_amount,
           '42'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_count)) inv_paid_count,
           '43'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_value)) earned_disc_value,
           '44'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_count)) earned_disc_count,
           '45'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_value)) unearned_disc_value,
           '46'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_count)) unearned_disc_count,
           '156'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_value)) total_cash_receipts_value,
           '157'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_count)) total_cash_receipts_count,
           '158'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_value)) total_invoices_value,
           '159'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_count)) total_invoices_count,
           '160'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_value)) total_bills_receivables_value,
           '161'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_count)) total_bills_receivables_count,
           '162'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_value)) total_debit_memos_value,
           '163'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_count)) total_debit_memos_count,
           '164'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_value)) total_chargeback_value,
           '165'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_count)) total_chargeback_count,
           '166'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_value)) total_adjustments_value,
           '167'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_count)) total_adjustments_count,
           '168'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_value)) total_deposits_value,
           '169'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_count)) total_deposits_count
      FROM ( SELECT
            round(SUM(NVL(DAYS_CREDIT_GRANTED_SUM,0))/
                 decode(SUM(NVL(TOTAL_INVOICES_VALUE,0)),0,1,
                        SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) days_credit_granted, -- days credit granted
            SUM(NVL(NSF_STOP_PAYMENT_COUNT,0)) nsf_payment_count, -- NSF/Stop Payment Count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(NSF_STOP_PAYMENT_AMOUNT,0))),2) nsf_payment_amount, -- NSF/Stop Payment Amount
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CREDIT_MEMOS_VALUE,0))),2) credit_memo_value, -- Credit memos value
            SUM(NVL(TOTAL_CREDIT_MEMOS_COUNT,0)) credit_memo_count, -- Credit memos count
           /* 8692948 - sum the counts (by currency) here but do the math
              up above */
            SUM(NVL(count_of_tot_inv_inst_paid,0))  x_tot_inv_inst_paid,
            SUM(NVL(count_of_inv_inst_paid_late,0)) x_tot_inv_inst_paid_late,
            SUM(NVL(count_of_disc_inv_inst,0))      x_tot_disc_inv_inst,
           /* End 8692948 */
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(INV_PAID_AMOUNT,0))),2) inv_paid_amount, -- invoices paid amount
            SUM(NVL(count_of_tot_inv_inst_paid,0)) inv_paid_count, -- invoices paid count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_EARNED_DISC_VALUE,0))),2) earned_disc_value, -- Earned Dscount Value
            SUM(NVL(TOTAL_EARNED_DISC_COUNT,0)) earned_disc_count, -- Earned Dscount count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_UNEARNED_DISC_VALUE,0))),2) unearned_disc_value, -- UnEarned Dscount Value
            SUM(NVL(TOTAL_UNEARNED_DISC_COUNT,0)) unearned_disc_count, -- UnEarned Dscount count
            (round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CASH_RECEIPTS_VALUE,0))),2) * -1) total_cash_receipts_value, -- see the comments above
            SUM(NVL(TOTAL_CASH_RECEIPTS_COUNT,0)) total_cash_receipts_count,
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) total_invoices_value,
             SUM(NVL(TOTAL_INVOICES_COUNT,0)) total_invoices_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_BILLS_RECEIVABLES_VALUE,0))),2) total_bills_receivables_value,
             SUM(NVL(TOTAL_BILLS_RECEIVABLES_COUNT,0)) TOTAL_BILLS_RECEIVABLES_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEBIT_MEMOS_VALUE,0))),2) total_debit_memos_value,
             SUM(NVL(TOTAL_DEBIT_MEMOS_COUNT,0)) TOTAL_debit_memos_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CHARGEBACK_VALUE,0))),2) total_chargeback_value,
             SUM(NVL(TOTAL_chargeback_COUNT,0)) TOTAL_chargeback_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_ADJUSTMENTS_VALUE,0))),2) total_adjustments_value,
             SUM(NVL(TOTAL_adjustments_COUNT,0)) TOTAL_adjustments_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEPOSITS_VALUE,0))),2) total_deposits_value,
             SUM(NVL(TOTAL_deposits_COUNT,0)) TOTAL_deposits_count
             FROM   AR_TRX_SUMMARY
             WHERE  org_id          = decode(l_global_exposure_flag,'Y', org_id, 'N',
                                     decode(p_org_id,null, org_id, p_org_id), null,
                                     decode(p_org_id,null, org_id, p_org_id))
             and    CUST_ACCOUNT_ID = p_cust_account_id
              and   CURRENCY     IN  ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
             and    as_of_date  >= ADD_MONTHS(sysdate,(-l_period))
             group by currency );

CURSOR c_site_summary IS
    SELECT
           '8'||'^'||fnd_number.number_to_canonical(SUM(days_credit_granted)) days_credit_granted,
           '13'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_count)) nsf_payment_count,
           '14'||'^'||fnd_number.number_to_canonical(SUM(nsf_payment_amount)) nsf_payment_amount,
           '17'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_value)) credit_memo_value,
           '18'||'^'||fnd_number.number_to_canonical(SUM(credit_memo_count)) credit_memo_count,
           '21'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid)-
                                SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_promptly,
           '22'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_inv_inst_paid_late)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_paid_late,
           '23'||'^'||fnd_number.number_to_canonical(
                         ROUND((SUM(x_tot_disc_inv_inst)) * 100 /
                         DECODE(SUM(x_tot_inv_inst_paid),0,1,SUM(x_tot_inv_inst_paid)),2)
                      ) per_inv_with_discount,
           '41'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_amount)) inv_paid_amount,
           '42'||'^'||fnd_number.number_to_canonical(SUM(inv_paid_count)) inv_paid_count,
           '43'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_value)) earned_disc_value,
           '44'||'^'||fnd_number.number_to_canonical(SUM(earned_disc_count)) earned_disc_count,
           '45'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_value)) unearned_disc_value,
           '46'||'^'||fnd_number.number_to_canonical(SUM(unearned_disc_count)) unearned_disc_count,
           '156'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_value)) total_cash_receipts_value,
           '157'||'^'||fnd_number.number_to_canonical(SUM(total_cash_receipts_count)) total_cash_receipts_count,
           '158'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_value)) total_invoices_value,
           '159'||'^'||fnd_number.number_to_canonical(SUM(total_invoices_count)) total_invoices_count,
           '160'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_value)) total_bills_receivables_value,
           '161'||'^'||fnd_number.number_to_canonical(SUM(total_bills_receivables_count)) total_bills_receivables_count,
           '162'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_value)) total_debit_memos_value,
           '163'||'^'||fnd_number.number_to_canonical(SUM(total_debit_memos_count)) total_debit_memos_count,
           '164'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_value)) total_chargeback_value,
           '165'||'^'||fnd_number.number_to_canonical(SUM(total_chargeback_count)) total_chargeback_count,
           '166'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_value)) total_adjustments_value,
           '167'||'^'||fnd_number.number_to_canonical(SUM(total_adjustments_count)) total_adjustments_count,
           '168'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_value)) total_deposits_value,
           '169'||'^'||fnd_number.number_to_canonical(SUM(total_deposits_count)) total_deposits_count
      FROM ( SELECT
            round(SUM(NVL(DAYS_CREDIT_GRANTED_SUM,0))/
                 decode(SUM(NVL(TOTAL_INVOICES_VALUE,0)),0,1,
                        SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) days_credit_granted, -- days credit granted
            SUM(NVL(NSF_STOP_PAYMENT_COUNT,0)) nsf_payment_count, -- NSF/Stop Payment Count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(NSF_STOP_PAYMENT_AMOUNT,0))),2) nsf_payment_amount, -- NSF/Stop Payment Amount
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CREDIT_MEMOS_VALUE,0))),2) credit_memo_value, -- Credit memos value
            SUM(NVL(TOTAL_CREDIT_MEMOS_COUNT,0)) credit_memo_count, -- Credit memos count
           /* 8692948 - sum the counts (by currency) here but do the math
              up above */
            SUM(NVL(count_of_tot_inv_inst_paid,0))  x_tot_inv_inst_paid,
            SUM(NVL(count_of_inv_inst_paid_late,0)) x_tot_inv_inst_paid_late,
            SUM(NVL(count_of_disc_inv_inst,0))      x_tot_disc_inv_inst,
           /* End 8692948 */
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(INV_PAID_AMOUNT,0))),2) inv_paid_amount, -- invoices paid amount
            SUM(NVL(count_of_tot_inv_inst_paid,0)) inv_paid_count, -- invoices paid count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_EARNED_DISC_VALUE,0))),2) earned_disc_value, -- Earned Dscount Value
            SUM(NVL(TOTAL_EARNED_DISC_COUNT,0)) earned_disc_count, -- Earned Dscount count
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_UNEARNED_DISC_VALUE,0))),2) unearned_disc_value, -- UnEarned Dscount Value
            SUM(NVL(TOTAL_UNEARNED_DISC_COUNT,0)) unearned_disc_count, -- UnEarned Dscount count
            (round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CASH_RECEIPTS_VALUE,0))),2) * -1) total_cash_receipts_value, -- see the comments above
            SUM(TOTAL_CASH_RECEIPTS_COUNT) total_cash_receipts_count,
            round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_INVOICES_VALUE,0))),2) total_invoices_value,
             SUM(NVL(TOTAL_INVOICES_COUNT,0)) total_invoices_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_BILLS_RECEIVABLES_VALUE,0))),2) total_bills_receivables_value,
             SUM(NVL(TOTAL_BILLS_RECEIVABLES_COUNT,0)) TOTAL_BILLS_RECEIVABLES_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEBIT_MEMOS_VALUE,0))),2) total_debit_memos_value,
             SUM(NVL(TOTAL_DEBIT_MEMOS_COUNT,0)) TOTAL_debit_memos_count,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_CHARGEBACK_VALUE,0))),2) total_chargeback_value,
             SUM(TOTAL_chargeback_COUNT) TOTAL_chargeback_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_ADJUSTMENTS_VALUE,0))),2) total_adjustments_value,
             SUM(NVL(TOTAL_adjustments_COUNT,0)) TOTAL_adjustments_count ,
             round(gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(TOTAL_DEPOSITS_VALUE,0))),2) total_deposits_value,
             SUM(NVL(TOTAL_deposits_COUNT,0)) TOTAL_deposits_count
             FROM   AR_TRX_SUMMARY
             WHERE  CUST_ACCOUNT_ID = p_cust_account_id
              and   CURRENCY     IN  ( SELECT a.CURRENCY FROM
                                       ar_cmgt_curr_usage_gt a
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
             and    as_of_date  >= ADD_MONTHS(sysdate,(-l_period))
             and    site_use_id  = p_cust_acct_site_id
             group by currency );




/*********** CAUTIONS **********************************************
-- if you are adding/removing  an column in this cursor please
-- update the bal_summary_rec_col_count varibale with proper number.
********************************************************************/
CURSOR c_party_bal_summary IS
    SELECT '34'||'^'||fnd_number.number_to_canonical(SUM(current_receivable_balance)) current_receivable_balance,
           '9'||'^'|| fnd_number.number_to_canonical(SUM(unapplied_cash_amount)) unapplied_cash_amount, -- unapplied case amount
           '10'||'^'||fnd_number.number_to_canonical(SUM(unapplied_cash_count)) unapplied_cash_count, -- unapplied cash count
           '48'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_value)) past_due_inv_value,
           '49'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_inst_count)) past_due_inv_inst_count,
           '50'||'^'||fnd_number.number_to_canonical(SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
           '51'||'^'||fnd_number.number_to_canonical(SUM(disputed_inv_count)) disputed_inv_count,
           '56'||'^'||fnd_number.number_to_canonical(SUM(pending_adj_value)) pending_adj_value,
           '58'||'^'||fnd_number.number_to_canonical(SUM(total_receipts_at_risk_value)) total_receipts_at_risk_value,
           '170'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_value)) op_invoices_value,
           '171'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_count)) op_invoices_count,
           '172'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_value)) op_debit_memos_value,
           '173'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_count)) op_debit_memos_count,
           '174'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_value)) op_deposits_value,
           '175'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_count)) op_deposits_count,
           '176'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_value)) op_bills_receivables_value,
           '177'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_count)) op_bills_receivables_count,
           '178'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_value)) op_chargeback_value,
           '179'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_count)) op_chargeback_count,
           '180'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_value)) op_credit_memos_value,
           '181'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_count)) op_credit_memos_count,
           '209'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_value)) current_invoice_value,
           '210'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_count)) current_invoice_count
    FROM (
         SELECT
           gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM((nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0) +
                   nvl(UNRESOLVED_CASH_VALUE,0) ))) current_receivable_balance,  -- Current Receivables Balance (Opening balance)
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(UNRESOLVED_CASH_VALUE,0))) unapplied_cash_amount, -- unapplied case amount
          SUM(UNRESOLVED_CASH_COUNT) unapplied_cash_count, -- unapplied cash count
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(past_due_inv_value)) past_due_inv_value,
          SUM(past_due_inv_inst_count) past_due_inv_inst_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
          SUM(disputed_inv_count) disputed_inv_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(pending_adj_value)) pending_adj_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(receipts_at_risk_value)) total_receipts_at_risk_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_invoices_value)) op_invoices_value,
          SUM(op_invoices_count) op_invoices_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_debit_memos_value)) op_debit_memos_value,
          SUM(op_debit_memos_count) op_debit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_deposits_value)) op_deposits_value,
          SUM(op_deposits_count) op_deposits_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_bills_receivables_value)) op_bills_receivables_value,
          SUM(op_bills_receivables_count) op_bills_receivables_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_chargeback_value)) op_chargeback_value,
          SUM(op_chargeback_count) op_chargeback_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_credit_memos_value)) op_credit_memos_value,
          SUM(op_credit_memos_count) op_credit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(nvl(op_invoices_value,0) - nvl(past_due_inv_value,0))) current_invoice_value,
          SUM(nvl(op_invoices_count,0) - nvl(past_due_inv_inst_count,0)) current_invoice_count
          FROM AR_TRX_BAL_SUMMARY
          WHERE cust_account_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= sysdate
                                  and effective_end_date >= sysdate
                                  and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                   and  g_source_name <> 'LNS'
                                  union select p_party_id from dual
                                  UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                            ))
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
          group by currency);


CURSOR c_account_bal_summary IS
    SELECT '34'||'^'||fnd_number.number_to_canonical(SUM(current_receivable_balance)) current_receivable_balance,
           '9'||'^'|| fnd_number.number_to_canonical(SUM(unapplied_cash_amount)) unapplied_cash_amount, -- unapplied case amount
           '10'||'^'||fnd_number.number_to_canonical(SUM(unapplied_cash_count)) unapplied_cash_count, -- unapplied cash count
           '48'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_value)) past_due_inv_value,
           '49'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_inst_count)) past_due_inv_inst_count,
           '50'||'^'||fnd_number.number_to_canonical(SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
           '51'||'^'||fnd_number.number_to_canonical(SUM(disputed_inv_count)) disputed_inv_count,
           '56'||'^'||fnd_number.number_to_canonical(SUM(pending_adj_value)) pending_adj_value,
           '58'||'^'||fnd_number.number_to_canonical(SUM(total_receipts_at_risk_value)) total_receipts_at_risk_value,
           '170'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_value)) op_invoices_value,
           '171'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_count)) op_invoices_count,
           '172'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_value)) op_debit_memos_value,
           '173'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_count)) op_debit_memos_count,
           '174'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_value)) op_deposits_value,
           '175'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_count)) op_deposits_count,
           '176'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_value)) op_bills_receivables_value,
           '177'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_count)) op_bills_receivables_count,
           '178'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_value)) op_chargeback_value,
           '179'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_count)) op_chargeback_count,
           '180'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_value)) op_credit_memos_value,
           '181'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_count)) op_credit_memos_count,
           '209'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_value)) current_invoice_value,
           '210'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_count)) current_invoice_count
    FROM (
         SELECT
           gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM((nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0) +
                   nvl(UNRESOLVED_CASH_VALUE,0) ))) current_receivable_balance,  -- Current Receivables Balance (Opening balance)
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(UNRESOLVED_CASH_VALUE,0))) unapplied_cash_amount, -- unapplied case amount
          SUM(UNRESOLVED_CASH_COUNT) unapplied_cash_count, -- unapplied cash count
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(past_due_inv_value)) past_due_inv_value,
          SUM(past_due_inv_inst_count) past_due_inv_inst_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
          SUM(disputed_inv_count) disputed_inv_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(pending_adj_value)) pending_adj_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(receipts_at_risk_value)) total_receipts_at_risk_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_invoices_value)) op_invoices_value,
          SUM(op_invoices_count) op_invoices_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_debit_memos_value)) op_debit_memos_value,
          SUM(op_debit_memos_count) op_debit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_deposits_value)) op_deposits_value,
          SUM(op_deposits_count) op_deposits_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_bills_receivables_value)) op_bills_receivables_value,
          SUM(op_bills_receivables_count) op_bills_receivables_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_chargeback_value)) op_chargeback_value,
          SUM(op_chargeback_count) op_chargeback_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_credit_memos_value)) op_credit_memos_value,
          SUM(op_credit_memos_count) op_credit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(nvl(op_invoices_value,0) - nvl(past_due_inv_value,0))) current_invoice_value,
          SUM(nvl(op_invoices_count,0) - nvl(past_due_inv_inst_count,0)) current_invoice_count
          FROM AR_TRX_BAL_SUMMARY
          WHERE  org_id          = decode(l_global_exposure_flag,'Y', org_id, 'N',
                                     decode(p_org_id,null, org_id, p_org_id), null,
                                     decode(p_org_id,null, org_id, p_org_id))
          and    cust_account_id = p_cust_account_id
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
            /* ( SELECT * FROM
                                 TABLE(CAST(l_curr_array_list AS curr_array_type))) */
          --and    site_use_id  = decode(l_analysis_level,'S',p_cust_acct_site_id,site_use_id)
          group by currency);

CURSOR c_site_bal_summary IS
    SELECT '34'||'^'||fnd_number.number_to_canonical(SUM(current_receivable_balance)) current_receivable_balance,
           '9'||'^'|| fnd_number.number_to_canonical(SUM(unapplied_cash_amount)) unapplied_cash_amount, -- unapplied case amount
           '10'||'^'||fnd_number.number_to_canonical(SUM(unapplied_cash_count)) unapplied_cash_count, -- unapplied cash count
           '48'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_value)) past_due_inv_value,
           '49'||'^'||fnd_number.number_to_canonical(SUM(past_due_inv_inst_count)) past_due_inv_inst_count,
           '50'||'^'||fnd_number.number_to_canonical(SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
           '51'||'^'||fnd_number.number_to_canonical(SUM(disputed_inv_count)) disputed_inv_count,
           '56'||'^'||fnd_number.number_to_canonical(SUM(pending_adj_value)) pending_adj_value,
           '58'||'^'||fnd_number.number_to_canonical(SUM(total_receipts_at_risk_value)) total_receipts_at_risk_value,
           '170'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_value)) op_invoices_value,
           '171'||'^'||fnd_number.number_to_canonical(SUM(op_invoices_count)) op_invoices_count,
           '172'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_value)) op_debit_memos_value,
           '173'||'^'||fnd_number.number_to_canonical(SUM(op_debit_memos_count)) op_debit_memos_count,
           '174'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_value)) op_deposits_value,
           '175'||'^'||fnd_number.number_to_canonical(SUM(op_deposits_count)) op_deposits_count,
           '176'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_value)) op_bills_receivables_value,
           '177'||'^'||fnd_number.number_to_canonical(SUM(op_bills_receivables_count)) op_bills_receivables_count,
           '178'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_value)) op_chargeback_value,
           '179'||'^'||fnd_number.number_to_canonical(SUM(op_chargeback_count)) op_chargeback_count,
           '180'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_value)) op_credit_memos_value,
           '181'||'^'||fnd_number.number_to_canonical(SUM(op_credit_memos_count)) op_credit_memos_count,
           '209'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_value)) current_invoice_value,
           '210'||'^'||fnd_number.number_to_canonical(SUM(current_invoice_count)) current_invoice_count
    FROM (
         SELECT
           gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM((nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0) +
                   nvl(UNRESOLVED_CASH_VALUE,0) ))) current_receivable_balance,  -- Current Receivables Balance (Opening balance)
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(NVL(UNRESOLVED_CASH_VALUE,0))) unapplied_cash_amount, -- unapplied case amount
          SUM(UNRESOLVED_CASH_COUNT) unapplied_cash_count, -- unapplied cash count
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(past_due_inv_value)) past_due_inv_value,
          SUM(past_due_inv_inst_count) past_due_inv_inst_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(inv_amt_in_dispute)) inv_amt_in_dispute,
          SUM(disputed_inv_count) disputed_inv_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(pending_adj_value)) pending_adj_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(receipts_at_risk_value)) total_receipts_at_risk_value,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_invoices_value)) op_invoices_value,
          SUM(op_invoices_count) op_invoices_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_debit_memos_value)) op_debit_memos_value,
          SUM(op_debit_memos_count) op_debit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_deposits_value)) op_deposits_value,
          SUM(op_deposits_count) op_deposits_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_bills_receivables_value)) op_bills_receivables_value,
          SUM(op_bills_receivables_count) op_bills_receivables_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_chargeback_value)) op_chargeback_value,
          SUM(op_chargeback_count) op_chargeback_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(op_credit_memos_value)) op_credit_memos_value,
          SUM(op_credit_memos_count) op_credit_memos_count,
          gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                SUM(nvl(op_invoices_value,0) - nvl(past_due_inv_value,0))) current_invoice_value,
          SUM(nvl(op_invoices_count,0) - nvl(past_due_inv_inst_count,0)) current_invoice_count
          FROM AR_TRX_BAL_SUMMARY
          WHERE  cust_account_id = p_cust_account_id
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
            /* ( SELECT * FROM
                                 TABLE(CAST(l_curr_array_list AS curr_array_type))) */
          and    site_use_id  = p_cust_acct_site_id
          group by currency);

CURSOR c_party_numerator_dso IS
    SELECT  SUM(dso) dso,
            SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0)
                    )*l_certified_dso_days)) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0)
                    - nvl(BEST_CURRENT_RECEIVABLES,0))*l_certified_dso_days)) delinquent_dso
         FROM   ar_trx_bal_summary
         WHERE  cust_account_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= sysdate
                                  and effective_end_date >= sysdate
                                  and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  g_source_name <> 'LNS'
                                  union select p_party_id from dual
                                  UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                            ))
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
          group by currency);

CURSOR c_account_numerator_dso IS
    SELECT SUM(dso) dso,
           SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount (currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0)
                    )*l_certified_dso_days)) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0)
                    - nvl(BEST_CURRENT_RECEIVABLES,0))*l_certified_dso_days)) delinquent_dso
         FROM   ar_trx_bal_summary
         WHERE  cust_account_id  = p_cust_account_id
         and    org_id          = decode(l_global_exposure_flag,'Y', org_id, 'N',
                                     decode(p_org_id,null, org_id, p_org_id), null,
                                     decode(p_org_id,null, org_id, p_org_id))
         and   CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
         group by currency);

CURSOR c_site_numerator_dso IS
    SELECT SUM(dso) dso,
           SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0) +
                   nvl(UNRESOLVED_CASH_VALUE,0) )*l_certified_dso_days)) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   (SUM(nvl(OP_INVOICES_VALUE,0) + nvl(OP_DEBIT_MEMOS_VALUE,0) +
                   nvl(OP_DEPOSITS_VALUE,0) + nvl(OP_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(OP_CHARGEBACK_VALUE,0) + nvl(OP_CREDIT_MEMOS_VALUE,0)
                    - nvl(BEST_CURRENT_RECEIVABLES,0))*l_certified_dso_days)) delinquent_dso
         FROM   ar_trx_bal_summary
         WHERE  cust_account_id  = p_cust_account_id
         and    site_use_id  = p_cust_acct_site_id
         and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
         group by currency);

CURSOR c_party_deno_dso IS
    SELECT SUM(dso) dso,
           SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0))
                   )) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   ((SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0)
                   )))) delinquent_dso
         FROM   ar_trx_summary
         WHERE  cust_account_id  in (select cust_account_id
                                FROM   hz_cust_accounts
                                WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= sysdate
                                  and effective_end_date >= sysdate
                                  and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  g_source_name <> 'LNS'
                                  union select p_party_id from dual
                                  UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                            ))
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
          and    as_of_date  >= (sysdate -l_certified_dso_days)
          group by currency);

CURSOR c_account_deno_dso IS
    SELECT SUM(dso) dso,
           SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0))
                   )) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   (SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0)
                   ))) delinquent_dso
         FROM   ar_trx_summary
         WHERE  cust_account_id = p_cust_account_id
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
          and    org_id          = decode(l_global_exposure_flag,'Y', org_id, 'N',
                                     decode(p_org_id,null, org_id, p_org_id), null,
                                     decode(p_org_id,null, org_id, p_org_id))
          and    as_of_date  >= (sysdate -l_certified_dso_days)
          group by currency);

CURSOR c_site_deno_dso IS
    SELECT SUM(dso) dso,
           SUM(delinquent_dso) delinquent_dso
    FROM (
        SELECT gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                (SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0))
                   )) dso,
                gl_currency_api.convert_amount(currency,
                l_limit_currency,sysdate,
                l_exchange_rate_type,
                   (SUM(nvl(TOTAL_INVOICES_VALUE,0) + nvl(TOTAL_DEBIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_DEPOSITS_VALUE,0) + nvl(TOTAL_BILLS_RECEIVABLES_VALUE,0) +
                   nvl(TOTAL_CHARGEBACK_VALUE,0) + nvl(TOTAL_CREDIT_MEMOS_VALUE,0) +
                   nvl(TOTAL_ADJUSTMENTS_VALUE,0)
                   ))) delinquent_dso
         FROM   ar_trx_summary
         WHERE  cust_account_id = p_cust_account_id
          and    CURRENCY   IN   ( SELECT CURRENCY FROM
                                       ar_cmgt_curr_usage_gt
                                       WHERE nvl(credit_request_id,p_credit_request_id) = p_credit_request_id)
          and    site_use_id = p_cust_acct_site_id
          and    as_of_date  >= (sysdate -l_certified_dso_days)
          group by currency);

   l_tag VARCHAR2(50);
   l_orig_limit_currency  ar_cmgt_credit_requests.limit_currency%type;
   l_wadpl NUMBER;
   l_apd   NUMBER;

   -- Added by rravikir (Bug 8581475)
   CURSOR c_party_currencies IS
   SELECT distinct currency
   FROM ar_trx_bal_summary
   WHERE cust_account_id IN (SELECT cust_account_id
                             FROM hz_cust_accounts_all
                             WHERE party_id = p_party_id
                             AND status = 'A');

   CURSOR c_checklist_currency_def IS
   SELECT include_all_currencies
   FROM ar_cmgt_check_lists
   WHERE check_list_id = p_check_list_id;

   l_checklist_currency_def VARCHAR2(1);
   -- End (Bug 8581475)


BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       IF p_case_folder_id IS NULL
       THEN
          l_tag := 'CR:' || p_credit_request_id;
       ELSE
          l_tag := 'CF:' || p_case_folder_id;
       END IF;
       ar_cmgt_util.wf_debug(l_tag,
              'ar_cmgt_data_points_pkg.gather_data_points()+');
       ar_cmgt_util.wf_debug(l_tag,
              '  p_mode = ' || p_mode);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_party_id = ' || p_party_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_cust_account_id = ' || p_cust_account_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_cust_acct_site_id = ' || p_cust_acct_site_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_trx_currency = ' || p_trx_currency);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_org_id = ' || p_org_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_check_list_id = ' || p_check_list_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_credit_request_id = ' || p_credit_request_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_score_model_id = ' || p_score_model_id);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_credit_classification = ' || p_credit_classification);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_review_type = ' || p_review_type);
       ar_cmgt_util.wf_debug(l_tag,
              '  p_case_folder_number = ' || p_case_folder_number);
    END IF;

    -- dbms_session.set_sql_trace(true);
    p_resultout := 0;


    -- p_case_folder_is is required in case of mode = 'REFRESH'

    IF p_mode = 'REFRESH' and p_case_folder_id IS NULL
    THEN
        p_resultout := 1;
        p_error_msg := 'Case Folder Id is required for Refresh Operation';
        return;
    END IF;

    -- Get values from system parameters
    BEGIN
        SELECT period, cer_dso_days
        INTO   l_period, l_certified_dso_days
        FROM   ar_cmgt_setup_options;

        EXCEPTION
            WHEN OTHERS
            THEN
                p_resultout := 2;
                p_error_msg := 'Please go to the System Options Page and setup system parameters '||sqlerrm;
                ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
                return;

    END;
    BEGIN
    -- Get source_information
      SELECT nvl(source_name, 'OCM'), nvl(source_column1, -99), limit_currency
      INTO   g_source_name, g_source_id, l_orig_limit_currency
      FROM   ar_cmgt_credit_requests
      WHERE  credit_request_id = p_credit_request_id;

      EXCEPTION
        WHEN OTHERS THEN
        p_resultout := 2;
                p_error_msg := 'Unable to get the credit request record '||sqlerrm;
                ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg);
                return;
    END;

    -- check which level we need to do analysis
    l_analysis_level := AR_CMGT_UTIL.find_analysis_level(p_party_id, p_cust_account_id, p_cust_acct_site_id);

    AR_CMGT_UTIL.get_limit_currency(
                p_party_id              =>  p_party_id,
                p_cust_account_id       =>  p_cust_account_id,
                p_cust_acct_site_id     =>  p_cust_acct_site_id,
                p_trx_currency_code     =>  p_trx_currency,
                p_limit_curr_code       =>  l_limit_currency,
                p_trx_limit             =>  l_trx_limit,
                p_overall_limit         =>  l_overall_limit,
                p_cust_acct_profile_amt_id => l_cust_acct_profile_amt_id,
                p_global_exposure_flag  =>  l_global_exposure_flag,
                p_include_all_flag      =>  l_include_all_flag,
                p_usage_curr_tbl        =>  l_curr_tbl,
                p_excl_curr_list        =>  l_excl_curr_list);

    -- get the conversion type
    l_exchange_rate_type := get_conversion_type( p_credit_request_id);

    IF l_exchange_rate_type IS NULL
    THEN
        p_resultout := 2;
        p_error_msg := 'Please define an exchange rate before processing this application.';
        return;
    END IF;


    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(l_tag,
              '  l_include_all_flag = ' || l_include_all_flag);
       ar_cmgt_util.wf_debug(l_tag,
              '  l_global_exposure_flag = ' || l_global_exposure_flag);
       ar_cmgt_util.wf_debug(l_tag,
              '  l_analysis_level = ' || l_analysis_level);
       ar_cmgt_util.wf_debug(l_tag,
              '  l_orig_limit_currency = ' || l_orig_limit_currency);
       ar_cmgt_util.wf_debug(l_tag,
              '  l_limit_currency = ' || l_limit_currency);
       ar_cmgt_util.wf_debug(l_tag,
              '  l_exchange_rate_type = ' || l_exchange_rate_type);
       ar_cmgt_util.wf_debug(l_tag,
              '     included currencies:');
    END IF;

    -- Added by rravikir (Bug 8581475)
    OPEN c_checklist_currency_def;
    FETCH c_checklist_currency_def INTO l_checklist_currency_def;
    CLOSE c_checklist_currency_def;

    -- If the 'Include All Currencies' is set to 'Y' in Checklist, the
    -- value at usage rule level is overridden, though its value is 'N'
    IF ( nvl(l_checklist_currency_def,'N') = 'Y' ) THEN
      l_include_all_flag := 'Y';
    END IF;
    -- End (Bug 8581475)

    IF ( nvl(l_include_all_flag,'N') = 'N' )
    THEN
        for  i in 1..l_curr_tbl.COUNT
        LOOP
           IF pg_wf_debug = 'Y'
           THEN
               IF gl_currency_api.rate_exists(
                        l_limit_currency,
                        l_curr_tbl(i).usage_curr_code,
                        sysdate,
                        l_exchange_rate_type) = 'Y'
               THEN
                  ar_cmgt_util.wf_debug(l_tag,
                      l_curr_tbl(i).usage_curr_code);
               ELSE
                  ar_cmgt_util.wf_debug(l_tag,
                      l_curr_tbl(i).usage_curr_code || ' MISSING RATE');
               END IF;
           END IF;

            INSERT INTO ar_cmgt_curr_usage_gt ( credit_request_id, currency) values
                ( p_credit_request_id, l_curr_tbl(i).usage_curr_code);
        END LOOP;
    ELSE
      -- Populate the GT table with the currencies of the Party active
      -- accounts
      -- Added by rravikir (Bug 8581475)
      FOR c_party_currencies_rec IN c_party_currencies
      LOOP
        INSERT INTO ar_cmgt_curr_usage_gt(credit_request_id, currency) VALUES
              (p_credit_request_id, c_party_currencies_rec.currency);
      END LOOP;
      -- End (Bug 8581475)

      IF pg_wf_debug = 'Y'
      THEN
          ar_cmgt_util.wf_debug(l_tag,
              '    ALL currencies from ar_trx_bal_summary');
      END IF;
    END IF;

    /* 7032417 - set outbound limit currency */
    IF g_source_name = 'OKL'
    THEN
       l_limit_currency := nvl(l_orig_limit_currency, l_limit_currency);
    END IF;

    p_limit_currency := l_limit_currency;
    IF  l_limit_currency IS NULL
    THEN
       IF pg_wf_debug = 'Y'
       THEN
          ar_cmgt_util.wf_debug(l_tag,
              'Credit Usage Rule has not been setup');
       END IF;

        p_resultout := 2;
        p_error_msg := 'Credit Usage Rule has not been setup';
        return;
    END IF;

    IF l_analysis_level in ( 'P','A')
    THEN
        IF nvl(l_global_exposure_flag,'N') = 'N'
        THEN
            p_resultout := 2;
            p_error_msg := 'Global Exposure Flag must be set to Y for Party and Account Level Analysis';
            return;
        END IF;
    END IF;

    -- update credit request with the limit currency
    update ar_cmgt_credit_requests
        set  limit_currency = l_limit_currency,
             LAST_UPDATE_DATE  = sysdate,
             LAST_UPDATED_BY   = FND_GLOBAL.user_id,
             LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
    WHERE  credit_request_id = p_credit_request_id;
    --AND    limit_currency IS NULL;


    IF p_mode = 'CREATE'
    THEN
            build_case_folder(p_party_id,
                      p_cust_account_id,
                      p_cust_acct_site_id,
                      p_limit_currency,
                      l_exchange_rate_type,
                      p_check_list_id,
                      p_credit_request_id,
                      p_score_model_id,
                      p_credit_classification,
                      p_review_type,
                      p_case_folder_number,
                      p_case_folder_id,
                      l_error_msg,
                      l_resultout);

            IF l_resultout <> 0
            THEN
                    p_resultout := l_resultout;
                    p_error_msg := l_error_msg;
                    return;
            END IF;
    ELSIF p_mode = 'REFRESH'
    THEN
            -- Referesh case
            UPDATE ar_cmgt_case_folders
               set  last_updated = SYSDATE,
                    last_update_date = SYSDATE,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
           WHERE   case_folder_id = p_case_folder_id;
    END IF;




    BEGIN
      IF l_analysis_level = 'P'
      THEN
        FOR c_summary_rec IN c_party_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_summary_rec.days_credit_granted||'{'||
                            c_summary_rec.nsf_payment_count||'{'||
                            c_summary_rec.nsf_payment_amount||'{'||
                            c_summary_rec.credit_memo_value||'{'||
                            c_summary_rec.credit_memo_count||'{'||
                            c_summary_rec.per_inv_paid_promptly||'{'||
                            c_summary_rec.per_inv_paid_late||'{'||
                            c_summary_rec.per_inv_with_discount||'{'||
                            c_summary_rec.inv_paid_amount||'{'||
                            c_summary_rec.inv_paid_count||'{'||
                            c_summary_rec.earned_disc_value||'{'||
                            c_summary_rec.earned_disc_count||'{'||
                            c_summary_rec.unearned_disc_value||'{'||
                            c_summary_rec.unearned_disc_count||'{'||
                            c_summary_rec.total_cash_receipts_value||'{'||
                            c_summary_rec.total_cash_receipts_count||'{'||
                            c_summary_rec.total_invoices_value||'{'||
                            c_summary_rec.total_invoices_count||'{'||
                            c_summary_rec.total_bills_receivables_value||'{'||
                            c_summary_rec.total_bills_receivables_count||'{'||
                            c_summary_rec.total_debit_memos_value||'{'||
                            c_summary_rec.total_debit_memos_count||'{'||
                            c_summary_rec.total_chargeback_value||'{'||
                            c_summary_rec.total_chargeback_count||'{'||
                            c_summary_rec.total_adjustments_value||'{'||
                            c_summary_rec.total_adjustments_count||'{'||
                            c_summary_rec.total_deposits_value||'{'||
                            c_summary_rec.total_deposits_count;

        END LOOP;
      ELSIF l_analysis_level = 'A'
      THEN
        FOR c_summary_rec IN c_account_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_summary_rec.days_credit_granted||'{'||
                            c_summary_rec.nsf_payment_count||'{'||
                            c_summary_rec.nsf_payment_amount||'{'||
                            c_summary_rec.credit_memo_value||'{'||
                            c_summary_rec.credit_memo_count||'{'||
                            c_summary_rec.per_inv_paid_promptly||'{'||
                            c_summary_rec.per_inv_paid_late||'{'||
                            c_summary_rec.per_inv_with_discount||'{'||
                            c_summary_rec.inv_paid_amount||'{'||
                            c_summary_rec.inv_paid_count||'{'||
                            c_summary_rec.earned_disc_value||'{'||
                            c_summary_rec.earned_disc_count||'{'||
                            c_summary_rec.unearned_disc_value||'{'||
                            c_summary_rec.unearned_disc_count||'{'||
                            c_summary_rec.total_cash_receipts_value||'{'||
                            c_summary_rec.total_cash_receipts_count||'{'||
                            c_summary_rec.total_invoices_value||'{'||
                            c_summary_rec.total_invoices_count||'{'||
                            c_summary_rec.total_bills_receivables_value||'{'||
                            c_summary_rec.total_bills_receivables_count||'{'||
                            c_summary_rec.total_debit_memos_value||'{'||
                            c_summary_rec.total_debit_memos_count||'{'||
                            c_summary_rec.total_chargeback_value||'{'||
                            c_summary_rec.total_chargeback_count||'{'||
                            c_summary_rec.total_adjustments_value||'{'||
                            c_summary_rec.total_adjustments_count||'{'||
                            c_summary_rec.total_deposits_value||'{'||
                            c_summary_rec.total_deposits_count;

        END LOOP;
      ELSIF l_analysis_level = 'S'
      THEN
        FOR c_summary_rec IN c_site_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_summary_rec.days_credit_granted||'{'||
                            c_summary_rec.nsf_payment_count||'{'||
                            c_summary_rec.nsf_payment_amount||'{'||
                            c_summary_rec.credit_memo_value||'{'||
                            c_summary_rec.credit_memo_count||'{'||
                            c_summary_rec.per_inv_paid_promptly||'{'||
                            c_summary_rec.per_inv_paid_late||'{'||
                            c_summary_rec.per_inv_with_discount||'{'||
                            c_summary_rec.inv_paid_amount||'{'||
                            c_summary_rec.inv_paid_count||'{'||
                            c_summary_rec.earned_disc_value||'{'||
                            c_summary_rec.earned_disc_count||'{'||
                            c_summary_rec.unearned_disc_value||'{'||
                            c_summary_rec.unearned_disc_count||'{'||
                            c_summary_rec.total_cash_receipts_value||'{'||
                            c_summary_rec.total_cash_receipts_count||'{'||
                            c_summary_rec.total_invoices_value||'{'||
                            c_summary_rec.total_invoices_count||'{'||
                            c_summary_rec.total_bills_receivables_value||'{'||
                            c_summary_rec.total_bills_receivables_count||'{'||
                            c_summary_rec.total_debit_memos_value||'{'||
                            c_summary_rec.total_debit_memos_count||'{'||
                            c_summary_rec.total_chargeback_value||'{'||
                            c_summary_rec.total_chargeback_count||'{'||
                            c_summary_rec.total_adjustments_value||'{'||
                            c_summary_rec.total_adjustments_count||'{'||
                            c_summary_rec.total_deposits_value||'{'||
                            c_summary_rec.total_deposits_count;

        END LOOP;
      END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_error_msg := 'Error While Getting Data from AR_TRX_SUMMARY, Probably exchange rate'||
                                 ' is not set correctly '||'Sql Error:'||sqlerrm;
            p_resultout := 1;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg || '1');
            return;
    END;
    summary_rec_str := summary_rec_str||'{'; -- adding for instrb call to make life easier
    -- Assign the number of columns fetched in the cursor

    for i IN 1..summary_rec_col_count
    LOOP
        l_start_pos := instrb(summary_rec_str,'{',1,i);
        l_end_pos   := instrb(summary_rec_str,'{',1,i+1);
        l_combo_string := substrb(summary_rec_str,l_start_pos+1,
                                l_end_pos-(l_start_pos+1));
        l_data_point_id_end_pos := instrb(l_combo_string,'^',1,1);

        l_data_point_id := substrb(l_combo_string,1,l_data_point_id_end_pos-1);
        l_data_point_value := substrb(l_combo_string,l_data_point_id_end_pos+1,20);


        build_case_folder_details(
                    p_case_folder_id,
                    l_data_point_id,
                    l_data_point_value,
                    p_mode,
                    p_error_msg,
                    p_resultout);
        IF p_resultout <> 0
        THEN
            return;
        END IF;
     END LOOP;
     summary_rec_str := NULL;
    BEGIN
      IF l_analysis_level = 'P'
      THEN
        FOR c_bal_summary_rec IN c_party_bal_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_bal_summary_rec.current_receivable_balance||'{'||
                            c_bal_summary_rec.unapplied_cash_amount||'{'||
                            c_bal_summary_rec.unapplied_cash_count||'{'||
                            c_bal_summary_rec.past_due_inv_value||'{'||
                            c_bal_summary_rec.past_due_inv_inst_count||'{'||
                            c_bal_summary_rec.inv_amt_in_dispute||'{'||
                            c_bal_summary_rec.disputed_inv_count||'{'||
                            c_bal_summary_rec.pending_adj_value||'{'||
                            c_bal_summary_rec.total_receipts_at_risk_value||'{'||
                            c_bal_summary_rec.op_invoices_value||'{'||
                            c_bal_summary_rec.op_invoices_count||'{'||
                            c_bal_summary_rec.op_debit_memos_value||'{'||
                            c_bal_summary_rec.op_debit_memos_count||'{'||
                            c_bal_summary_rec.op_deposits_value||'{'||
                            c_bal_summary_rec.op_deposits_count||'{'||
                            c_bal_summary_rec.op_bills_receivables_value||'{'||
                            c_bal_summary_rec.op_bills_receivables_count||'{'||
                            c_bal_summary_rec.op_chargeback_value||'{'||
                            c_bal_summary_rec.op_chargeback_count||'{'||
                            c_bal_summary_rec.op_credit_memos_value||'{'||
                            c_bal_summary_rec.op_credit_memos_count||'{'||
                            c_bal_summary_rec.current_invoice_value||'{'||
                            c_bal_summary_rec.current_invoice_count;
        END LOOP;
      ELSIF l_analysis_level = 'A'
      THEN
        FOR c_bal_summary_rec IN c_account_bal_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_bal_summary_rec.current_receivable_balance||'{'||
                            c_bal_summary_rec.unapplied_cash_amount||'{'||
                            c_bal_summary_rec.unapplied_cash_count||'{'||
                            c_bal_summary_rec.past_due_inv_value||'{'||
                            c_bal_summary_rec.past_due_inv_inst_count||'{'||
                            c_bal_summary_rec.inv_amt_in_dispute||'{'||
                            c_bal_summary_rec.disputed_inv_count||'{'||
                            c_bal_summary_rec.pending_adj_value||'{'||
                            c_bal_summary_rec.total_receipts_at_risk_value||'{'||
                            c_bal_summary_rec.op_invoices_value||'{'||
                            c_bal_summary_rec.op_invoices_count||'{'||
                            c_bal_summary_rec.op_debit_memos_value||'{'||
                            c_bal_summary_rec.op_debit_memos_count||'{'||
                            c_bal_summary_rec.op_deposits_value||'{'||
                            c_bal_summary_rec.op_deposits_count||'{'||
                            c_bal_summary_rec.op_bills_receivables_value||'{'||
                            c_bal_summary_rec.op_bills_receivables_count||'{'||
                            c_bal_summary_rec.op_chargeback_value||'{'||
                            c_bal_summary_rec.op_chargeback_count||'{'||
                            c_bal_summary_rec.op_credit_memos_value||'{'||
                            c_bal_summary_rec.op_credit_memos_count||'{'||
                            c_bal_summary_rec.current_invoice_value||'{'||
                            c_bal_summary_rec.current_invoice_count;
        END LOOP;
      ELSIF l_analysis_level = 'S'
      THEN
        FOR c_bal_summary_rec IN c_site_bal_summary
        LOOP
            summary_rec_str := summary_rec_str||'{'||
                            c_bal_summary_rec.current_receivable_balance||'{'||
                            c_bal_summary_rec.unapplied_cash_amount||'{'||
                            c_bal_summary_rec.unapplied_cash_count||'{'||
                            c_bal_summary_rec.past_due_inv_value||'{'||
                            c_bal_summary_rec.past_due_inv_inst_count||'{'||
                            c_bal_summary_rec.inv_amt_in_dispute||'{'||
                            c_bal_summary_rec.disputed_inv_count||'{'||
                            c_bal_summary_rec.pending_adj_value||'{'||
                            c_bal_summary_rec.total_receipts_at_risk_value||'{'||
                            c_bal_summary_rec.op_invoices_value||'{'||
                            c_bal_summary_rec.op_invoices_count||'{'||
                            c_bal_summary_rec.op_debit_memos_value||'{'||
                            c_bal_summary_rec.op_debit_memos_count||'{'||
                            c_bal_summary_rec.op_deposits_value||'{'||
                            c_bal_summary_rec.op_deposits_count||'{'||
                            c_bal_summary_rec.op_bills_receivables_value||'{'||
                            c_bal_summary_rec.op_bills_receivables_count||'{'||
                            c_bal_summary_rec.op_chargeback_value||'{'||
                            c_bal_summary_rec.op_chargeback_count||'{'||
                            c_bal_summary_rec.op_credit_memos_value||'{'||
                            c_bal_summary_rec.op_credit_memos_count||'{'||
                            c_bal_summary_rec.current_invoice_value||'{'||
                            c_bal_summary_rec.current_invoice_count;
        END LOOP;
      END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_error_msg := 'Error While Getting Data from AR_TRX_BAL_SUMMARY, Probably exchange rate '
                           ||'is not set correctly '||'Sql Error:'||sqlerrm;
            p_resultout := 1;
            ar_cmgt_util.wf_debug(p_case_folder_id, p_error_msg || '2');
            return;
    END;
    summary_rec_str := summary_rec_str||'{'; -- adding for instrb call to make life easier

    -- Assign the number of columns fetched in the cursor
    for i IN 1..bal_summary_rec_col_count
    LOOP
        l_start_pos := instrb(summary_rec_str,'{',1,i);
        l_end_pos   := instrb(summary_rec_str,'{',1,i+1);
        l_combo_string := substrb(summary_rec_str,l_start_pos+1,
                                l_end_pos-(l_start_pos+1));
        l_data_point_id_end_pos := instrb(l_combo_string,'^',1,1);

        l_data_point_id := substrb(l_combo_string,1,l_data_point_id_end_pos-1);
        l_data_point_value := substrb(l_combo_string,l_data_point_id_end_pos+1,20);

        build_case_folder_details(
                    p_case_folder_id,
                    l_data_point_id,
                    l_data_point_value,
                    p_mode,
                    p_error_msg,
                    p_resultout);
        IF p_resultout <> 0
        THEN
            return;
        END IF;
    END LOOP;
    summary_rec_str := NULL;
    -- Calculate DSO, WADPL (5), and average_payment_days (4)
    IF l_analysis_level = 'P'
    THEN
        -- the cursor will always return one row
        FOR c_party_numerator_dso_rec IN c_party_numerator_dso
        LOOP
            l_numerator_dso := c_party_numerator_dso_rec.dso;
            l_numerator_ddso := c_party_numerator_dso_rec.delinquent_dso;
        END LOOP;
        FOR c_party_deno_dso_rec IN c_party_deno_dso
        LOOP
            l_deno_dso := c_party_deno_dso_rec.dso;
            l_deno_ddso := c_party_deno_dso_rec.delinquent_dso;
        END LOOP;

        /* 8661054 - DSO and DDSO should return null if there is no
           activity within the specified number of days */

        -- Weighted average days paid late (5) and average payment days (4)
        SELECT Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(SUM_APP_AMT_DAYS_LATE,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_days_paid_late,
               Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(INV_INST_PMT_DAYS_SUM,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_pmt_days
        INTO   l_wadpl,
               l_apd
        FROM   ar_trx_summary
        WHERE  CUST_ACCOUNT_ID in (select cust_account_id
                               FROM   hz_cust_accounts
                               WHERE  party_id in
                                ( SELECT child_id
                                  from hz_hierarchy_nodes
                                  where parent_object_type = 'ORGANIZATION'
                                  and parent_table_name = 'HZ_PARTIES'
                                  and child_object_type = 'ORGANIZATION'
                                  and parent_id = p_party_id
                                  and effective_start_date <= sysdate
                                  and effective_end_date >= sysdate
                                  and  hierarchy_type = FND_PROFILE.VALUE('AR_CMGT_HIERARCHY_TYPE')
                                  and  g_source_name <> 'LNS'
                                  union select p_party_id from dual
                                  UNION
                    select hz_party_id
                    from LNS_LOAN_PARTICIPANTS_V
                    where loan_id = g_source_id
                    and   participant_type_code = 'COBORROWER'
                    and   g_source_name = 'LNS'
                    and (end_date_active is null OR
                          (sysdate between start_date_active and end_date_active)
                          )
                             ))
        AND    CURRENCY     IN  ( SELECT CURRENCY
                                  FROM   ar_cmgt_curr_usage_gt
                                  WHERE  nvl(credit_request_id,p_credit_request_id) =
                                         p_credit_request_id)
        AND    AS_OF_DATE  >= ADD_MONTHS(sysdate,(-l_period));

    ELSIF l_analysis_level = 'A'
    THEN
        -- the cursor will always return one row
        FOR c_account_numerator_dso_rec IN c_account_numerator_dso
        LOOP
            l_numerator_dso := c_account_numerator_dso_rec.dso;
            l_numerator_ddso := c_account_numerator_dso_rec.delinquent_dso;
        END LOOP;

        FOR c_account_deno_dso_rec IN c_account_deno_dso
        LOOP
            l_deno_dso := c_account_deno_dso_rec.dso;
            l_deno_ddso := c_account_deno_dso_rec.delinquent_dso;
        END LOOP;

        /* 8661054 - DSO and DDSO should return null if there is no
           activity within the specified number of days */

        -- Weighted average days paid late (5) and average payment days (4)
        SELECT Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(SUM_APP_AMT_DAYS_LATE,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_days_paid_late,
               Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(INV_INST_PMT_DAYS_SUM,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_pmt_days
        INTO   l_wadpl,
               l_apd
        FROM   ar_trx_summary
        WHERE  ORG_ID       = decode(l_global_exposure_flag,'Y', org_id, 'N',
                                decode(p_org_id,null, org_id, p_org_id), null,
                                  decode(p_org_id,null, org_id, p_org_id))
        AND    CUST_ACCOUNT_ID = p_cust_account_id
        AND    CURRENCY     IN  ( SELECT CURRENCY
                                  FROM   ar_cmgt_curr_usage_gt
                                  WHERE nvl(credit_request_id,p_credit_request_id) =
                                          p_credit_request_id)
        AND    AS_OF_DATE  >= ADD_MONTHS(sysdate,(-l_period));

    ELSIF l_analysis_level = 'S'
    THEN
        -- the cursor will always return one row
        FOR c_site_numerator_dso_rec IN c_site_numerator_dso
        LOOP
            l_numerator_dso := c_site_numerator_dso_rec.dso;
            l_numerator_ddso := c_site_numerator_dso_rec.delinquent_dso;
        END LOOP;
        FOR c_site_deno_dso_rec IN c_site_deno_dso
        LOOP
            l_deno_dso := c_site_deno_dso_rec.dso;
            l_deno_ddso := c_site_deno_dso_rec.delinquent_dso;
        END LOOP;

        /* 8661054 - DSO and DDSO should return null if there is no
           activity within the specified number of days */

        -- Weighted average days paid late (5) and average payment days (4)
        SELECT Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(SUM_APP_AMT_DAYS_LATE,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_days_paid_late,
               Round(
             SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                SYSDATE, l_exchange_rate_type,
                (NVL(INV_INST_PMT_DAYS_SUM,0)))) /
                   Decode(SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                         (NVL(SUM_APP_AMT,0)))),0,1,
                          SUM(gl_currency_api.convert_amount(currency,l_limit_currency,
                                                             SYSDATE,l_exchange_rate_type,
                             (NVL(SUM_APP_AMT,0))))),2) wt_average_pmt_days
        INTO   l_wadpl,
               l_apd
        FROM   ar_trx_summary
        WHERE  CUST_ACCOUNT_ID = p_cust_account_id
        AND    CURRENCY     IN  ( SELECT a.CURRENCY
                                  FROM   ar_cmgt_curr_usage_gt a
                                  WHERE  nvl(credit_request_id,p_credit_request_id) =
                                         p_credit_request_id)
        AND    AS_OF_DATE  >= ADD_MONTHS(sysdate,(-l_period))
        AND    SITE_USE_ID  = p_cust_acct_site_id;

    END IF;

        /* 8661054 - Moved dso and ddso calcs to after IF,
            corrected misuse of l_deno_dso in ddso calc */
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(l_tag,
          'DSO:  numerator = ' || l_numerator_dso || '  denom = ' ||
                     l_deno_dso);
       ar_cmgt_util.wf_debug(l_tag,
           'DDSO:  numerator = ' || l_numerator_ddso || '  denom = ' ||
                     l_deno_ddso);
    END IF;

    /* 8661054 - DSO and DDSO should return null if there is no
       activity within the specified number of days */
    IF l_deno_dso is NOT NULL AND l_deno_dso <> 0
    THEN
       l_dso := round((l_numerator_dso/l_deno_dso),2);
    ELSE
       l_dso := NULL;
    END IF;
    IF l_deno_ddso IS NOT NULL AND l_deno_ddso <> 0
    THEN
       l_ddso := round((l_numerator_ddso/l_deno_ddso),2);
    ELSE
       l_ddso := NULL;
    END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(l_tag,
              'DSO (2)  = ' || l_dso);
       ar_cmgt_util.wf_debug(l_tag,
              'DDSO (3) = ' || l_ddso);
       ar_cmgt_util.wf_debug(l_tag,
              'APD (4)  = ' || l_apd);
       ar_cmgt_util.wf_debug(l_tag,
              'WADPL (5) = ' || l_wadpl);

    END IF;

        build_case_folder_details(
                    p_case_folder_id,
                    2, --dso
                    fnd_number.number_to_canonical(l_dso),
                    p_mode,
                    p_error_msg,
                    p_resultout);

        IF p_resultout <> 0
        THEN
            return;
        END IF;

        build_case_folder_details(
                    p_case_folder_id,
                    3, -- deliquent dso
                    fnd_number.number_to_canonical(l_ddso),
                    p_mode,
                    p_error_msg,
                    p_resultout);

        IF p_resultout <> 0
        THEN
            return;
        END IF;

        build_case_folder_details(
                    p_case_folder_id,
                    4,
                    fnd_number.number_to_canonical(l_apd),
                    p_mode,
                    p_error_msg,
                    p_resultout);

        IF p_resultout <> 0
        THEN
            return;
        END IF;

        build_case_folder_details(
                    p_case_folder_id,
                    5,
                    fnd_number.number_to_canonical(l_wadpl),
                    p_mode,
                    p_error_msg,
                    p_resultout);

        IF p_resultout <> 0
        THEN
            return;
        END IF;

    --kosriniv number format needs to be handled in GetAnalytical Data for invoice Amounts..
    -- get analytic data
    GetAnalyticalData (
            p_credit_request_id        => p_credit_request_id,
            p_party_id                 => p_party_id,
            p_cust_account_id          => p_cust_account_id,
            p_site_use_id              => p_cust_acct_site_id,
            p_case_folder_id           => p_case_folder_id,
            p_analysis_level           => l_analysis_level,
            p_org_id                   => p_org_id,
            p_period                   => l_period,
            p_global_exposure_flag     => l_global_exposure_flag,
            p_limit_currency           => l_limit_currency,
            p_exchange_rate_type       => l_exchange_rate_type,
            p_mode                     => p_mode,
            p_errormsg                 => p_error_msg,
            p_resultout                => p_resultout);
    IF ( p_resultout <> 0 )
    THEN
        return;
    END IF;
    -- kosriniv ... Dunning only includes the dunning count and last dunning date.
    GetDunning(
            p_credit_request_id        => p_credit_request_id,
            p_party_id                 => p_party_id,
            p_cust_account_id          => p_cust_account_id,
            p_site_use_id              => p_cust_acct_site_id,
            p_org_id                   => p_org_id,
            p_case_folder_id           => p_case_folder_id,
            p_period                   => l_period,
            p_analysis_level           => l_analysis_level,
            p_global_exposure_flag     => l_global_exposure_flag,
            p_mode                     => p_mode,
            p_errormsg                 => p_error_msg,
            p_resultout                => p_resultout);
    IF p_resultout <> 0
    THEN
        return;
    END IF;
    -- kosriniv...Change the Number format of 95,96,98,99,108,30.
    -- this procedure will populate all data points which is not in summary tables.
    GetOtherDataPoints (
            p_credit_request_id         => p_credit_request_id,
            p_party_id                  => p_party_id,
            p_cust_account_id           => p_cust_account_id,
            p_site_use_id               => p_cust_acct_site_id,
            p_cust_acct_profile_amt_id  => l_cust_acct_profile_amt_id,
            p_case_folder_id            => p_case_folder_id,
            p_mode                      => p_mode);
    -- kosriniv .. Change the Number format of 15,26,213
    GetOMDataPoints(
            p_credit_request_id         => p_credit_request_id,
            p_party_id                  => p_party_id,
            p_cust_account_id           => p_cust_account_id,
            p_site_use_id               => p_cust_acct_site_id,
            p_case_folder_id            => p_case_folder_id,
            p_analysis_level            => l_analysis_level,
            p_limit_currency_code       => p_limit_currency,
            p_mode                      => p_mode,
            p_errormsg                  => p_error_msg,
            p_resultout                 => p_resultout);
    IF (p_resultout <> 0)
    THEN
        return;
    END IF;
    -- ko   Need to Look into this further...
    BUILD_DNB_CASE_FOLDER(
            p_party_id,
            p_check_list_id,
            p_case_folder_id,
            p_mode,
            l_error_msg,
            l_resultout);



     --kosriniv .. No need of changing the Number format.. The stored data type Number only.
      populate_aging_data(
                p_case_folder_id    => p_case_folder_id,
                p_mode              => p_mode,
                p_error_msg         => p_error_msg,
                p_resultout         => p_resultout);
      IF ( p_resultout <> 0 )
      THEN
        return;
      END IF;

     -- ko   Need to Look into this further...
     GetManualDataPoints(
            p_credit_request_id        => p_credit_request_id,
            p_case_folder_id        => p_case_folder_id,
            p_check_list_id         => p_check_list_id,
            p_mode                  => p_mode,
            x_error_msg             => p_error_msg,
            x_resultout             => p_resultout);
     IF p_resultout <> 0
     THEN
        return;
     END IF;

      -- kosriniv .. Change Number format of data points ..113 ..140.
     GetFinancialData (
        p_credit_request_id         => p_credit_request_id,
        p_case_folder_id            => p_case_folder_id,
        p_mode                      => p_mode,
        p_resultout                 => p_resultout,
        p_errmsg                    => p_error_msg);
     IF p_resultout <> 0
     THEN
        return;
     END IF;

     -- kosriniv .. Change Numebr For Data points 211.
     -- call deduction procedure to populate deduction data points
     GetDeductionDataPoints ( -- bug 3691676
            p_credit_request_id         => p_credit_request_id,
            p_case_folder_id            => p_case_folder_id,
            p_period                    => l_period,
            p_party_id                  => p_party_id,
            p_cust_account_id           => p_cust_account_id,
            p_site_use_id               => p_cust_acct_site_id,
            p_analysis_level            => l_analysis_level,
            p_org_id                    => p_org_id,
            p_mode                      => p_mode,
            p_limit_currency            => l_limit_currency,
            p_exchange_rate_type        => l_exchange_rate_type,
            p_global_exposure_flag      => l_global_exposure_flag,
            p_error_msg                 => p_error_msg,
            p_resultout                 => p_resultout );

     IF p_resultout <> 0
     THEN
        return;
     END IF;
     -- in case of Refresh update the status back to save in case folder.
     IF p_mode = 'REFRESH'
     THEN
           -- since case folder got refreshed, need to refresh the score too
           -- call scoring engine
           ar_cmgt_scoring_engine.generate_score(
                    p_case_folder_id    =>  p_case_folder_id,
                    p_score             =>  l_score,
                    p_error_msg         =>  p_error_msg,
                    p_resultout         =>  p_resultout);
           IF p_resultout <> 0
           THEN
      -- error in generating the score, so update the score to null
    p_resultout := 0;
    UPDATE  ar_cmgt_cf_dtls
        SET     score = null,
                last_updated_by = fnd_global.user_id,
                last_update_date = sysdate,
                last_update_login = fnd_global.login_id
        WHERE   case_folder_id = p_case_folder_id;
           END IF;
           UPDATE ar_cmgt_case_folders
           SET  status   = 'SAVED',
                    last_updated = SYSDATE,
                    last_update_date = SYSDATE,
                    last_updated_by  = fnd_global.user_id,
                    last_update_login = fnd_global.login_id
           WHERE   case_folder_id = p_case_folder_id
           AND     type  = 'CASE';


    END IF;

    -- update all data points value in case folder details which is included in
    -- checklist for type 'CASE'.
    IF ( p_check_list_id IS NOT NULL )
    THEN
        UPDATE ar_cmgt_cf_dtls
            set included_in_checklist = 'Y'
        WHERE  case_folder_id = p_case_folder_id
        AND    data_point_id in (
                SELECT data_point_id
                    FROM ar_cmgt_check_list_dtls
                WHERE check_list_id = p_check_list_id);
    END IF;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(l_tag,
              'ar_cmgt_data_points_pkg.gather_data_points()-');
    END IF;
END GATHER_DATA_POINTS;


END AR_CMGT_DATA_POINTS_PKG;

/
