--------------------------------------------------------
--  DDL for Package Body JG_ZZ_TURNOVER_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_TURNOVER_AR_PKG" 
-- $Header: jgzzturnoverarb.pls 120.13.12010000.4 2010/06/03 09:24:14 pakumare ship $
-- +===================================================================+
-- |                   Oracle Solution Services (India)                |
-- |                         Bangalore, India                          |
-- +===================================================================+
-- |Name:        JGZZTURNOVERARB.pls                                   |
-- |Description: EMEA VAT TURNOVER_AR package creation script          |
-- |                                                                   |
-- |                                                                   |
-- |                                                                   |
-- |Change Record:                                                     |
-- |===============                                                    |
-- |Version   Date        Author             Remarks                   |
-- |=======   ==========  ===============    ==========================|
-- |DRAFT1A   24-JAN-2006 Manish Upadhyay    Initial version           |
-- |DRAFT1B   22-FEB-2006 Balachander G      Changes after IDC Review  |
-- |          23-Mar-2006 Ramananda          Modified the cursor lcu_be_annual_decl to incorporate the revised approach
-- |          21-Apr-2006 Ramananda          Modified the cursor lcu_be_annual_decl
-- |                                         RCT.interface_header_context  <> 'CONTRA' changed to  RCT.interface_header_context  <> 'Contra'
-- |          26-Apr-2006 Ramananda          Modified the cursor lcu_be_annual_decl
-- |                      5189030            Removed unnecessary filter JZVTD.extract_source_ledger = 'AR.
-- |                                         Removed duplicate join RTT.cust_trx_type_id = JZVTD.trx_type_id
-- |          28-Apr-2006 Ramananda Pokkula  Dummy assignments are removed
-- |          29-Jun-2006 Ramananda Pokkula  Bug # 5223170
-- |          08-Aug-2006 Kasbalas           Bug # 5194991
-- |          27-Oct-2006 rjreddy            Bug 5616757: In beforereport procedure, changed the condition while raising NO_TRANS_RECORDS exception
-- |	      21-Nov-2006 spasupun	     BUG 5658632 and 5658620
-- |					     Fixed the issues reported in the bugs : 5658632 and
-- |						 5658620
-- |					     5658620 :- 1. In JEBEVADC header section
-- |						tax_registration _num is not correct. In the header
-- |						section for both the columns jg_info_v2
-- |						and jg_info_v3,we are inserting taxpayer_id only.
-- |						Changed the jg_info_v2 column source to
-- |						l_tax_registration_num.
-- |						2. JEBEVADC report showing the data for each customer
-- |						instead of showing summary of all customers. Made the
-- |						changes in xml file.
-- |			 		     5658632 :  1. Added header and footer information to
-- |							 report JEBEVA24.
-- |					     2. Implemented the amount formatting logic by using
-- |						 precision and	currency factor for report JEBEVA24.
-- |          21-Nov-2006 spasupun           Modified the Having clause of cursor lcu_be_annual_decl.
-- |          01-Jul-2008 rsaini             Modified function Before report to return FALSE on exception
-- +=====================================================================================================+
AS

gn_request_id            NUMBER        := FND_GLOBAL.CONC_REQUEST_ID;

  PROCEDURE message(p_message IN VARCHAR2)
  AS
  BEGIN
    fnd_file.put_line(fnd_file.log,p_message);
  END message;

  FUNCTION beforeReport RETURN BOOLEAN
  -- +======================================================================+
  -- | Name :              beforeReport                                     |
  -- | Description :       This procedure processes the data before the     |
  -- |                     execution of report.                             |
  -- |                                                                      |
  -- +======================================================================+
  IS
/* Bug#5223170. Added hz_cust_acct_sites, hz_party_sites and join conditions */


      l_precision             NUMBER := 0;
      l_curr_factor           NUMBER := 1;

    CURSOR lcu_be_annual_decl
    IS
      SELECT
         MIN(JZVTD.billing_trading_partner_id )  CUSTOMER_ID
        ,MIN(JZVTD.billing_tp_name)              CUSTOMER_NAME
        ,MIN(HZL.address1)                       STREET_NAME
        ,MIN(HZL.postal_code)                    POSTAL_CODE
        ,MIN(HZL.city)                           TOWN
        ,JZVTD.billing_tp_site_tax_reg_num       VAT_NUMBER
	,DECODE(P_REPORT_NAME,
			'JEBEVA24',SUM(ROUND(NVL(JZVTD.taxable_amt_funcl_curr,0),l_precision)*l_curr_factor)
			,SUM(ROUND(NVL(JZVTD.taxable_amt_funcl_curr,0),l_precision))) AMOUNT
        ,DECODE(P_REPORT_NAME,
			'JEBEVA24',SUM(ROUND(NVL(JZVTD.tax_amt_funcl_curr,0),l_precision)*l_curr_factor)
			,SUM(ROUND(NVL(JZVTD.tax_amt_funcl_curr,0),l_precision))) TAX_AMOUNT
      FROM   jg_zz_vat_trx_details   JZVTD
            ,jg_zz_vat_rep_status    JZVRS
            ,ra_cust_trx_types       RTT
            ,ra_customer_trx         RCT
            ,hz_cust_acct_sites      HZCAS
            ,hz_party_sites          HPS
            ,hz_locations            HZL
      WHERE  JZVRS.vat_reporting_entity_id                =  P_VAT_REP_ENTITY_ID
      AND    JZVTD.reporting_status_id                    =  JZVRS.reporting_status_id
      AND    RTT.cust_trx_type_id                         =  JZVTD.trx_type_id
      AND    RTT.type                                     IN ('INV','CM','DM')
      AND    JZVRS.tax_calendar_year                      =  P_PERIOD
      AND    JZVRS.source                                 =  'AR'
    --AND    JZVTD.billing_tp_address_id                  =  HZL.location_id
      AND    JZVTD.billing_tp_address_id                  =  HZCAS.cust_acct_site_id
      AND    HZCAS.party_site_id                          =  HPS.party_site_id
      AND    HPS.location_id                              =  HZL.location_id
      AND    SUBSTR(JZVTD.billing_tp_site_tax_reg_num,1,2)=  'BE'
      AND    RCT.customer_trx_id                          =  JZVTD.trx_id
      AND    JZVTD.application_id                         =  222
      AND    JZVTD.entity_code                            =  'TRANSACTIONS'
      AND    NVL(RCT.interface_header_context,'X')        <> 'Contra'
      GROUP BY JZVTD.billing_tp_site_tax_reg_num
      HAVING   SUM(ROUND(NVL(JZVTD.taxable_amt_funcl_curr,0),l_precision))     >= P_MIN_AMOUNT
      ORDER BY JZVTD.billing_tp_site_tax_reg_num;

      l_address_line_1                VARCHAR2 (240);
      l_address_line_2                VARCHAR2 (240);
      l_address_line_3                VARCHAR2 (240);
      l_address_line_4                VARCHAR2 (240);
      l_city                          VARCHAR2 (60);
      l_company_name                  VARCHAR2 (240);
      l_contact_name                  VARCHAR2 (360);
      l_country                       VARCHAR2 (60);
      l_func_curr                     VARCHAR2 (30);
      l_legal_entity_id               NUMBER;
      l_legal_entity_name             VARCHAR2 (240);
      l_period_end_date               DATE;
      l_period_start_date             DATE;
      l_phone_number                  VARCHAR2 (40);
      l_postal_code                   VARCHAR2 (60);
      l_registration_num              VARCHAR2 (30);
      l_reporting_status              VARCHAR2 (60);
      l_tax_payer_id                  VARCHAR2 (60);
      l_tax_registration_num          VARCHAR2 (240);
      l_tax_regime                    VARCHAR2(240);
      l_activity_code                 VARCHAR2(240);
      cnt                     NUMBER:=0;
      t_customer_name         VARCHAR2(240);
      t_street                VARCHAR2(240);
      t_postal_code           VARCHAR2(240);
      t_town                  VARCHAR2(240);
      t_VAT_number            VARCHAR2(240);
      t_amount                NUMBER := 0;
      t_loop_amount           NUMBER := 0;
      t_tax_amount            NUMBER := 0;
      t_loop_tax              NUMBER := 0;
      t_file_totals           VARCHAR2(32);
      t_value                 NUMBER := 9999999999;
      t_tax_value             NUMBER := 9999999999;
      t_total_amount          NUMBER := 0;
      t_total_tax_amount      NUMBER := 0;
      t_customer_id           NUMBER;
      l_error_pos             NUMBER := 0;
      l_vat_count             NUMBER := 0;
    -- Added for Glob-006 ER
      l_province                      VARCHAR2(120);
      l_comm_num                      VARCHAR2(30);
      l_vat_reg_num                   VARCHAR2(50);


      REPORT_LIMIT_REACHED    EXCEPTION;
      AMOUNT_LIMIT_REACHED    EXCEPTION;
      NO_TRANS_RECORDS        EXCEPTION;
  BEGIN
    -- Call to Common Package
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_turnover_ar_pkg.before_report');
      fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.funct_curr_legal');
    END IF;
    BEGIN
      jg_zz_common_pkg.funct_curr_legal(x_func_curr_code      => l_func_curr
                                    ,x_rep_entity_name      => l_legal_entity_name
                                    ,x_legal_entity_id      => l_legal_entity_id
                                    ,x_taxpayer_id          => l_tax_payer_id
                                    ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                    ,pn_period_year         => p_period);
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.funct_curr_legal failed with Error: '||SUBSTR(SQLERRM,1,200));
    END;
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.tax_registration');
    END IF;
    BEGIN
      jg_zz_common_pkg.tax_registration(x_tax_registration     => l_tax_registration_num
                                       ,x_period_start_date    => l_period_start_date
                                       ,x_period_end_date      => l_period_end_date
                                       ,x_status               => l_reporting_status
                                       ,pn_vat_rep_entity_id   => p_vat_rep_entity_id
                                       ,pv_period_name         => NULL
                                       ,pn_period_year         => p_period  /*5223170*/
                                       ,pv_source              => 'ALL');
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.tax_registration failed with Error: '||SUBSTR(SQLERRM,1,200));
    END;


     IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling jg_zz_vat_rep_utlity.get_report_status');
    END IF;
    BEGIN
       l_reporting_status := jg_zz_vat_rep_utility.get_period_status
                          (
                           pn_vat_reporting_entity_id  =>  p_vat_rep_entity_id,
                           pv_tax_calendar_period      =>  NULL,
                           pv_tax_calendar_year        =>  p_period,
                           pv_source                   =>  NULL,
                           pv_report_name              =>  P_REPORT_NAME
                          );
    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_vat_rep_utility.get_report_status failed with Error: '||SUBSTR(SQLERRM,1,200));
    END;

    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Calling jg_zz_common_pkg.company_detail');
    END IF;
    BEGIN
      jg_zz_common_pkg.company_detail(x_company_name            => l_company_name
                                  ,x_registration_number    => l_registration_num
                                  ,x_country                => l_country
                                  ,x_address1               => l_address_line_1
                                  ,x_address2               => l_address_line_2
                                  ,x_address3               => l_address_line_3
                                  ,x_address4               => l_address_line_4
                                  ,x_city                   => l_city
                                  ,x_postal_code            => l_postal_code
                                  ,x_contact                => l_contact_name
                                  ,x_phone_number           => l_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => l_legal_entity_id
                                  ,p_vat_reporting_entity_id => p_vat_rep_entity_id);

    EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Executing jg_zz_common_pkg.company_detail failed with Error: '||SUBSTR(SQLERRM,1,200));
    END;
    BEGIN
      SELECT activity_code
      INTO   l_activity_code
      FROM   xle_entity_profiles
      WHERE  legal_entity_id = l_legal_entity_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(fnd_file.log,'Cannot find Activity Code (Standard Inductry Classification Code for Legal Entity:'||l_legal_entity_id);
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'Error While retrieving Activity Code for Legal Entity:'||l_legal_entity_id);
      fnd_file.put_line(fnd_file.log,'Error Message :'||SUBSTR(SQLERRM,1,200));
    END;


    INSERT INTO jg_zz_vat_trx_gt
    (
      jg_info_n1
     ,jg_info_v1
     ,jg_info_v2
     ,jg_info_v3
     ,jg_info_v4
     ,jg_info_v5
     ,jg_info_v6
     ,jg_info_v7
     ,jg_info_v8
     ,jg_info_v9
     ,jg_info_v10
     ,jg_info_v11
     ,jg_info_v12
     ,jg_info_v13
     ,jg_info_v14
     ,jg_info_v15
     ,jg_info_v16
     ,jg_info_v17
     ,jg_info_d1
     ,jg_info_d2
     ,jg_info_v30
    )
    VALUES
    (
       l_legal_entity_id
      ,l_company_name       -- l_legal_entity_name
      ,l_tax_registration_num
      ,l_registration_num   -- l_tax_payer_id
      ,l_contact_name
      ,l_address_line_1
      ,l_address_line_2
      ,l_address_line_3
      ,l_address_line_4
      ,l_city
      ,l_country
      ,l_phone_number
      ,l_postal_code
      ,l_func_curr
      ,l_reporting_status
      ,l_tax_regime
      ,l_activity_code
      ,l_tax_registration_num
      ,l_period_end_date
      ,l_period_start_date
      ,'H'
    );
    IF p_debug_flag = 'Y' THEN
      fnd_file.put_line(fnd_file.log,'Legal Entity ID     =>' || l_legal_entity_id);
      fnd_file.put_line(fnd_file.log,'Company Name        =>' || l_company_name);
      fnd_file.put_line(fnd_file.log,'Legal Entity Name   =>' || l_company_name);
      fnd_file.put_line(fnd_file.log,'Regiatration Number =>' || l_registration_num);
      fnd_file.put_line(fnd_file.log,'Taxpayer ID         =>' || l_registration_num);
      fnd_file.put_line(fnd_file.log,'Contact Name        =>' || l_contact_name);
      fnd_file.put_line(fnd_file.log,'Address Line 1      =>' || l_address_line_1);
      fnd_file.put_line(fnd_file.log,'             2      =>' || l_address_line_2);
      fnd_file.put_line(fnd_file.log,'             3      =>' || l_address_line_3);
      fnd_file.put_line(fnd_file.log,'             4      =>' || l_address_line_4);
      fnd_file.put_line(fnd_file.log,'City                =>' || l_city);
      fnd_file.put_line(fnd_file.log,'Country             =>' || l_country);
      fnd_file.put_line(fnd_file.log,'Telephone Number    =>' || l_phone_number);
      fnd_file.put_line(fnd_file.log,'Postal Code         =>' || l_postal_code);
      fnd_file.put_line(fnd_file.log,'Currency Code       =>' || l_func_curr);
      fnd_file.put_line(fnd_file.log,'Reporting Status    =>' || l_reporting_status);
      fnd_file.put_line(fnd_file.log,'Period Start Date   =>' || l_period_start_date);
      fnd_file.put_line(fnd_file.log,'       End Date     =>' || l_period_end_date);
    END IF;
      IF P_REPORT_NAME = 'JEBEVADC' OR P_REPORT_NAME = 'JEBEVA24' THEN

	BEGIN
             select precision
		into  l_precision
	    from   fnd_currencies_vl
	    where  currency_code = l_func_curr;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
         fnd_file.put_line(fnd_file.log,'No data found while retrieving precision. Check the currency code.');
        WHEN OTHERS THEN
          fnd_file.put_line(fnd_file.log,'Error While retrieving precision');
          fnd_file.put_line(fnd_file.log,'Error Message :'||SUBSTR(SQLERRM,1,200));
        END;

      IF P_REPORT_NAME = 'JEBEVA24' THEN
	  if l_func_curr = gl_currency_api.get_euro_code()  then
		l_curr_factor := 100;
	  end if;
       END IF;

        OPEN lcu_be_annual_decl ;
        LOOP
          cnt := cnt+1;
         l_error_pos := 5;
          FETCH lcu_be_annual_decl INTO t_customer_id
                                      , t_customer_name
                                      , t_street
                                      , t_postal_code
                                      , t_town
                                      , t_vat_number
                                      , t_amount
                                      , t_tax_amount ;

          EXIT WHEN lcu_be_annual_decl%NOTFOUND;
          IF p_debug_flag = 'Y' THEN
            message( 'Customer ID '||t_customer_id||' VAT Number '||t_vat_number);
          END IF;

          -- Raise error if count reaches 999999
         l_error_pos := 6;
          IF cnt  >= 999999 THEN
            RAISE REPORT_LIMIT_REACHED;
          END IF;
          --  If amount is over field limit of 10 then do
          -- splitting routine otherwise insert amounts
          IF t_amount >= 0 and t_tax_amount >= 0 THEN

            t_loop_amount := t_amount;
            t_loop_tax := t_tax_amount;

	    LOOP
              IF t_loop_amount <= t_value THEN
                IF t_loop_tax <= t_tax_value THEN
                 l_error_pos := 7;
                  INSERT INTO jg_zz_vat_trx_gt
                                 ( jg_info_n1
                                 , jg_info_n2
                                 , jg_info_v1
                                 , jg_info_v2
                                 , jg_info_v3
                                 , jg_info_v4
                                 , jg_info_v5
                                 , jg_info_n3
                                 , jg_info_n4
                                 , jg_info_v6
                                 )
                  VALUES
                                 (cnt
                                 , t_customer_id
                                 , t_customer_name
                                 , t_street
                                 , t_postal_code
                                 , t_town
                                 , t_VAT_number
                                 , t_loop_amount
                                 , t_loop_tax
                                 , l_func_curr);
                  EXIT;
                ELSE
                 l_error_pos := 8;
                  INSERT INTO jg_zz_vat_trx_gt
                                 ( jg_info_n1
                                 , jg_info_n2
                                 , jg_info_v1
                                 , jg_info_v2
                                 , jg_info_v3
                                 , jg_info_v4
                                 , jg_info_v5
                                 , jg_info_n3
                                 , jg_info_n4
                                 , jg_info_v6
                                 )
                  VALUES
                                 (cnt
                                 , t_customer_id
                                 , t_customer_name
                                 , t_street
                                 , t_postal_code
                                 , t_town
                                 , t_VAT_number
                                 , t_loop_amount
                                 , t_tax_value
                                 , l_func_curr);
                  cnt := cnt+1;
                  t_loop_tax := t_loop_tax - t_tax_value;
                  t_tax_value := t_tax_value - 1;
                    t_loop_amount := 0;
                END IF;
              ELSE
                IF t_loop_tax <= t_tax_value THEN
                 l_error_pos := 9;
                  INSERT INTO jg_zz_vat_trx_gt
                                 ( jg_info_n1
                                 , jg_info_n2
                                 , jg_info_v1
                                 , jg_info_v2
                                 , jg_info_v3
                                 , jg_info_v4
                                 , jg_info_v5
                                 , jg_info_n3
                                 , jg_info_n4
                                 , jg_info_v6
                                 )
                  VALUES
                                 (cnt
                                 , t_customer_id
                                 , t_customer_name
                                 , t_street
                                 , t_postal_code
                                 , t_town
                                 , t_VAT_number
                                 , t_value
                                 , t_loop_tax
                                 , l_func_curr);
                  t_loop_tax := 0;
                ELSE
                 l_error_pos := 10;
                  INSERT INTO jg_zz_vat_trx_gt
                                 ( jg_info_n1
                                 , jg_info_n2
                                 , jg_info_v1
                                 , jg_info_v2
                                 , jg_info_v3
                                 , jg_info_v4
                                 , jg_info_v5
                                 , jg_info_n3
                                 , jg_info_n4
                                 , jg_info_v6
                                 )
                  VALUES
                                 (cnt
                                 , t_customer_id
                                 , t_customer_name
                                 , t_street
                                 , t_postal_code
                                 , t_town
                                 , t_VAT_number
                                 , t_value
                                 , t_tax_value
                                 , l_func_curr);
                  t_loop_tax := t_loop_tax - t_tax_value;
                  t_tax_value := t_tax_value - 1;
                END IF;
                t_loop_amount := t_loop_amount - t_value;
                t_value := t_value - 1;
              cnt := cnt+1;
              END IF;
            END LOOP;
          END IF;

          -- Insert into JE_BE_ANNUAL_VAT amounts fetched for amounts or tax with less than 0 */
          IF t_amount < 0 or t_tax_amount < 0 THEN
            INSERT INTO jg_zz_vat_trx_gt
                           ( jg_info_n1
                           , jg_info_n2
                           , jg_info_v1
                           , jg_info_v2
                           , jg_info_v3
                           , jg_info_v4
                           , jg_info_v5
                           , jg_info_n3
                           , jg_info_n4
                           , jg_info_v6)
            VALUES
                           (cnt
                           , t_customer_id
                           , t_customer_name
                           , t_street
                           , t_postal_code
                           , t_town
                           , t_VAT_number
                           , t_amount
                           , t_tax_amount
                           , l_func_curr);
           l_error_pos := 11;
          END IF;
          t_total_amount     := t_total_amount+t_amount;
          t_total_tax_amount := t_total_tax_amount+t_tax_amount;
        END LOOP;
      CLOSE lcu_be_annual_decl ;

      --Over flowing amount error check
     l_error_pos := 12;
      IF t_total_amount >= 9999999999999999 OR t_total_tax_amount >= 9999999999999999 THEN
        RAISE AMOUNT_LIMIT_REACHED;
      END IF;



	/* Format reports totals for column2 then insert trailing record */
	  IF t_total_amount >= 0 and t_total_tax_amount >= 0 THEN
	     t_file_totals :=
	      lpad(t_total_amount,16,'0')||lpad(t_total_tax_amount,16,'0');
	  ELSIF t_total_amount >= 0 and t_total_tax_amount < 0 THEN
	     t_file_totals :=
	      lpad(t_total_amount,16,'0')||'-'||lpad(abs(t_total_tax_amount),15,'0');
	  ELSIF t_total_amount < 0 and t_total_tax_amount >= 0 THEN
	     t_file_totals :=
	      '-'||lpad(abs(t_total_amount),15,'0')||lpad(t_total_tax_amount,16,'0');
	  ELSE
	     t_file_totals :=
	      lpad(t_total_amount,16,'0')||lpad(t_total_tax_amount,16,'0');
	  END IF;

     l_error_pos := 13;

     -- Trailer information for JEBEVA24

      INSERT INTO jg_zz_vat_trx_gt
                     ( jg_info_n1
		     , jg_info_v1
                     , jg_info_v2
                     , jg_info_v30
                     )
      VALUES
                     ( 999999
		      ,t_file_totals
                      ,l_tax_registration_num
                      ,'JEBEV24-T');

      -- Header information for JEBEVA24

      INSERT INTO jg_zz_vat_trx_gt
                     ( jg_info_n1
                     , jg_info_v1
                     , jg_info_v2
                     , jg_info_v3
                     , jg_info_v4
		     , jg_info_v5
		     , jg_info_v6
		     , jg_info_n2
		     , jg_info_n3
		     , jg_info_v30
                     )
      VALUES
                     ( 000000
                     , l_company_name
                     , l_address_line_1
                     , l_postal_code
                     , l_city
		     , l_tax_registration_num
		     , l_func_curr
		     , p_period
		     , 000
		     , 'JEBEV24-H');


    END IF;

    SELECT count(1)
    INTO   l_vat_count
    FROM   jg_zz_vat_trx_gt
    WHERE  jg_info_v30 IS NULL;

    fnd_file.put_line(fnd_file.log,'Number of records inserted into jg_zz_vat_trx_gt: ' || l_vat_count);

    IF l_vat_count = 0 THEN
       RAISE NO_TRANS_RECORDS;
    END IF;
    p_err_code := 0;
    RETURN (TRUE);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    message( 'Error position: ' || to_char(l_error_pos) || ': No records found.');
    p_err_code := 99;
    IF l_error_pos = 15 THEN
      message('VAT number ('||t_vat_number||') and customer site use are inconsistent.' );
    END IF;
    RETURN(TRUE);
  WHEN REPORT_LIMIT_REACHED THEN
    message('Error position: ' || to_char(l_error_pos) || ': Number of records exceeded the report limit.');
    p_err_code := 10;
    RETURN(FALSE);
  WHEN AMOUNT_LIMIT_REACHED THEN
    message( 'Error position: ' || to_char(l_error_pos) || ': Amount Overflow, total amount or tax has exceeded the limit.');
    p_err_code := 20;
    RETURN(FALSE);
  WHEN NO_TRANS_RECORDS THEN
    message('Error position: ' || to_char(l_error_pos) || ': There are no transactions that meet the criteria.');
    p_err_code := 30;
    RETURN(TRUE);
  WHEN OTHERS THEN
    message('Error in Before Report Trigger' || SUBSTR(SQLERRM,1,200));
    RETURN (FALSE);
  END beforeReport;

  FUNCTION get_error_code RETURN NUMBER
  IS BEGIN
    RETURN p_err_code;
  END;

END jg_zz_turnover_ar_pkg;

/
