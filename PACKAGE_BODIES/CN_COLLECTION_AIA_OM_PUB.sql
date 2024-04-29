--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_AIA_OM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_AIA_OM_PUB" AS
  /* $Header: CNPCLTROMB.pls 120.0.12010000.8 2009/09/18 10:13:08 rajukum noship $*/

  g_pkg_name constant VARCHAR2(30) := 'CN_COLLECTION_AIA_OM_PUB';
  g_file_name constant VARCHAR2(15) := 'CNPCLTROMB.pls';
  g_cn_debug VARCHAR2(1) := fnd_profile.VALUE('CN_DEBUG');

  PROCEDURE debugmsg(msg VARCHAR2) IS
  BEGIN

    IF g_cn_debug = 'Y' THEN
      cn_message_pkg.debug(SUBSTR(msg,   1,   254));
      --fnd_file.PUT_LINE(fnd_file.LOG,   msg);
      if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cn.plsql.CN_COLLECTION_AIA_OM_PUB', msg);
      end if;
    END IF;

    -- comment out dbms_output before checking in file
    -- dbms_output.put_line(substr(msg,1,254));
  END debugmsg;

  -- Function name  : get_employee_number
  -- Type : Public.
  -- Pre-reqs :

  FUNCTION get_employee_number(p_salesrep_id IN cn_aia_order_capture.salesrep_id%TYPE,
            p_org_id cn_aia_order_capture.org_id%TYPE) RETURN cn_aia_order_capture.employee_number%TYPE IS

   cursor get_emp_num_cur IS
      SELECT salesrep_number
      FROM jtf_rs_salesreps
      WHERE salesrep_id = p_salesrep_id
       AND org_id = p_org_id;

   l_empnum_cr get_emp_num_cur%ROWTYPE;
   l_employee_num cn_aia_order_capture.employee_number%TYPE;
  BEGIN
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_employee_number: p_salesrep_id, org_id: ' || p_salesrep_id || ' , ' || p_org_id);
    l_employee_num := '-1';

    if(p_salesrep_id is not null) Then
      FOR l_empnum_cr IN get_emp_num_cur
      LOOP
        l_employee_num := l_empnum_cr.salesrep_number;
      END LOOP;
    END If;

    RETURN l_employee_num;

    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_employee_number: l_employee_num: ' || l_employee_num);

  EXCEPTION
  WHEN others THEN
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_employee_number: exception others: ' || sqlerrm(SQLCODE()));
    RETURN l_employee_num;
  END;

  -- Function name  : get_exchange_rate
  -- Type : Public.
  -- Pre-reqs :
  FUNCTION get_exchange_rate(p_from_currency IN cn_aia_order_capture.amt_curcy_cd%TYPE,
            p_conversion_date IN cn_aia_order_capture.processed_date%TYPE,
            p_org_id IN cn_aia_order_capture.org_id%TYPE) RETURN cn_aia_order_capture.exchange_rate%TYPE IS

      CURSOR c1(l_to_currency varchar2,l_conversion_type varchar2) IS
         SELECT conversion_date
           FROM gl_daily_rates
          WHERE from_currency 	= p_from_currency
            AND to_currency	= l_to_currency
            AND conversion_type	= l_conversion_type
            AND conversion_date	= p_conversion_date
            AND rownum		< 2
          ORDER BY conversion_date DESC;

      CURSOR c2(l_to_currency varchar2,l_conversion_type varchar2) IS
         SELECT MAX(conversion_date) conversion_date
           FROM gl_daily_rates
          WHERE from_currency 	= p_from_currency
            AND to_currency	= l_to_currency
            AND conversion_type	= l_conversion_type
            AND conversion_date	< p_conversion_date;

      l_exchange_rate cn_aia_order_capture.exchange_rate%TYPE;
      l_to_currency cn_aia_order_capture.amt_curcy_cd%TYPE;
      l_conversion_date		DATE;
      l_conversion_type         VARCHAR2(30);
      l_check_max		CHAR(1) := 'Y';

  BEGIN
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: p_curr_code, org_id: ' || p_from_currency || ' , ' || p_org_id);
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate:p_conversion_date: ' || p_conversion_date);
    --
    l_to_currency := cn_global_var.get_currency_code(p_org_id);
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: l_to_currency: ' || l_to_currency);
    --
    if( p_from_currency = l_to_currency) Then
      return 1;
    end if;

    l_conversion_type := nvl(CN_SYSTEM_PARAMETERS.VALUE('CN_CONVERSION_TYPE', p_org_id), 'Corporate');
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: l_conversion_type: ' || l_conversion_type);
     --
    FOR rec IN c1(l_to_currency,l_conversion_type)
     LOOP
        l_conversion_date := rec.conversion_date;
        l_check_max := 'N';
     END LOOP;
     --
     IF (l_check_max = 'Y') THEN
        FOR rec IN c2(l_to_currency,l_conversion_type)
        LOOP
           IF (rec.conversion_date IS NOT NULL) THEN
              l_conversion_date := rec.conversion_date;
              l_check_max := 'N';
  	 END IF;
        END LOOP;
     END IF;
     --
     IF (l_check_max = 'Y') THEN
        RETURN l_exchange_rate;
     ELSE
         debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: l_conversion_date: ' || l_conversion_date);
        l_exchange_rate := gl_currency_api.get_rate(p_from_currency,
                                                    l_to_currency,
                                                    l_conversion_date,
                                                    l_conversion_type);
     END IF;

     --
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: l_exchange_rate: ' || l_exchange_rate);

    RETURN l_exchange_rate;

  EXCEPTION
  WHEN others THEN
    debugmsg('CN_COLLECTION_AIA_OM_PUB.get_exchange_rate: exception others: ' || sqlerrm(SQLCODE()));
    RETURN l_exchange_rate;
  END;

  -- API name  : oic_pre_load_data_process
  -- Type : Public.
  -- Pre-reqs :

  PROCEDURE oic_pre_load_data_process(errbuf OUT NOCOPY  VARCHAR2,
                                      retcode OUT NOCOPY NUMBER,
                                      p_org_id IN NUMBER,
                                      x_return_status OUT nocopy VARCHAR2) IS

  CURSOR fetch_aia_salesreps_cur IS
    SELECT DISTINCT salesrep_id,
         amt_curcy_cd,processed_date, revenue_type
    FROM cn_aia_order_capture
    WHERE
       preprocess_flag = fnd_api.g_false AND
       org_id = p_org_id
       AND update_flag = 'N';

  type salesreps_tbl_type IS TABLE OF fetch_aia_salesreps_cur % rowtype INDEX BY pls_integer;
  salesreps_tbl salesreps_tbl_type;
  l_employee_num VARCHAR2(30) := '-1';
  l_exchange_rate NUMBER := 0;
  l_revenue_type VARCHAR2(30) := 'REVENUE';

  BEGIN
    debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: start: ');
    debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: p_org_id : ' || p_org_id);
    SAVEPOINT oic_pre_load;
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN fetch_aia_salesreps_cur;
    debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: inside fetch_aia_salesreps_cur: ');
    LOOP
      FETCH fetch_aia_salesreps_cur bulk collect
      INTO salesreps_tbl limit 1000;

      FOR indx IN 1 .. salesreps_tbl.COUNT
      LOOP
        l_employee_num := get_employee_number(salesreps_tbl(indx).salesrep_id,p_org_id);
        l_exchange_rate := get_exchange_rate(salesreps_tbl(indx).amt_curcy_cd,salesreps_tbl(indx).processed_date,p_org_id);
        l_revenue_type :=  nvl(salesreps_tbl(indx).revenue_type, 'REVENUE');

        debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: l_employee_num : ' || l_employee_num);
        debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: l_exchange_rate : ' || l_exchange_rate);
        debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: l_revenue_type : ' || l_revenue_type);


        UPDATE cn_aia_order_capture
        SET employee_number = l_employee_num,
            exchange_rate = l_exchange_rate,
            revenue_type = l_revenue_type,
            adjust_status = 'MANUAL',
            --preprocess_flag = fnd_api.g_false,
            update_flag = 'Y'
        WHERE (salesrep_id = salesreps_tbl(indx).salesrep_id)
         AND amt_curcy_cd = salesreps_tbl(indx).amt_curcy_cd
         AND processed_date = salesreps_tbl(indx).processed_date
         AND nvl(revenue_type, 'REVENUE') =   nvl(salesreps_tbl(indx).revenue_type, 'REVENUE')
         AND update_flag = 'N'
         AND preprocess_flag = fnd_api.g_false
         AND org_id = p_org_id;

      END LOOP;

      EXIT
    WHEN fetch_aia_salesreps_cur % NOTFOUND;
  END LOOP;

  CLOSE fetch_aia_salesreps_cur;

  debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: after fetch_aia_salesreps_cur close statement: ');
  debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: end: ');

  COMMIT;

EXCEPTION
WHEN others THEN
  x_return_status := 'F';
  retcode := 2;
  errbuf          := SQLERRM(SQLCODE());
  debugmsg('CN_COLLECTION_AIA_OM_PUB.oic_pre_load_data_process: exception others: ' || errbuf);
  ROLLBACK TO oic_pre_load;

END oic_pre_load_data_process;

-- API name  : pre_aia_om_load_process
-- Type : Public.
-- Pre-reqs :
-- Usage :
--+
-- Desc  :
--
--

PROCEDURE pre_aia_om_load_process(errbuf OUT NOCOPY  VARCHAR2,
                                  retcode OUT NOCOPY NUMBER,
                                  p_org_id IN NUMBER
                                  ) IS

 x_return_status VARCHAR2(1);

BEGIN
  debugmsg('CN_COLLECTION_AIA_OM_PUB.pre_aia_om_load_process: start: ');
  x_return_status := fnd_api.g_ret_sts_success;
  retcode := 0;
  errbuf := '';

  cn_cust_aia_ord_proc_pub.ct_aia_om_pre_processing(x_return_status => x_return_status);

  debugmsg('CN_COLLECTION_AIA_OM_PUB.pre_aia_om_load_process: after cn_cust_aia_ord_proc_pub.ct_aia_om_pre_processing call: ');
  debugmsg('CN_COLLECTION_AIA_OM_PUB.pre_aia_om_load_process: x_return_status: ' || x_return_status);

  IF(x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  oic_pre_load_data_process(errbuf => errbuf,
                            retcode => retcode,
                            p_org_id => p_org_id,
                            x_return_status => x_return_status);

  debugmsg('CN_COLLECTION_AIA_OM_PUB.pre_aia_om_load_process: after oic_pre_load_data_process call: ');
  debugmsg('CN_COLLECTION_AIA_OM_PUB.pre_aia_om_load_process: x_return_status: ' || x_return_status);

  IF(x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
WHEN others THEN
  x_return_status := 'F';
  retcode := 2;
  errbuf          := errbuf || ' :  ' || SQLERRM(SQLCODE());
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:exception others: ' ||  errbuf);
  --RAISE	FND_API.G_EXC_ERROR;
  raise_application_error (-20002,errbuf);

END pre_aia_om_load_process;

-- API name  : post_aia_om_load_process
-- Type : Public.
-- Pre-reqs :
-- Usage :
--+
-- Desc  :
--
--
PROCEDURE post_aia_om_load_process(x_return_status OUT nocopy VARCHAR2) IS

BEGIN

  x_return_status := fnd_api.g_ret_sts_success;

END post_aia_om_load_process;

END CN_COLLECTION_AIA_OM_PUB;

/
