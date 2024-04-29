--------------------------------------------------------
--  DDL for Package Body BIL_TX_UTIL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_UTIL_RPT_PKG" AS
/* $Header: biltxutb.pls 120.22.12010000.3 2010/02/16 06:26:45 annsrini ship $ */


g_pkg VARCHAR2(500);

/*************************************************************************
* get_page_params procedure is created to retrieve paraemeters from PMV
* Parameter Table
*************************************************************************/


PROCEDURE GET_PAGE_PARAMS (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id               IN     VARCHAR2,
                           x_period_type             OUT NOCOPY VARCHAR2,
                           x_to_currency             OUT NOCOPY VARCHAR2,
                           x_to_period_name          OUT NOCOPY VARCHAR2,
                           x_sg_id                   OUT NOCOPY VARCHAR2,
                           x_resource_id             OUT NOCOPY VARCHAR2,
                           x_frcst_owner             OUT NOCOPY VARCHAR2,
                           x_prodcat_id              OUT NOCOPY VARCHAR2,
                           x_item_id                 OUT NOCOPY VARCHAR2,
                           x_parameter_valid         OUT NOCOPY BOOLEAN,
                           x_viewby                  OUT NOCOPY VARCHAR2,
                           x_order                   OUT NOCOPY VARCHAR2, -- Column on which data is sorted
                           x_rptby                   OUT NOCOPY VARCHAR2,
                           x_sls_chnl                OUT NOCOPY VARCHAR2,
                           x_sls_stge                OUT NOCOPY VARCHAR2,
                           x_opp_status              OUT NOCOPY VARCHAR2,
                           x_source                  OUT NOCOPY VARCHAR2,
                           x_sls_methodology         OUT NOCOPY VARCHAR2,
                           x_win_probability         OUT NOCOPY VARCHAR2,
                           x_win_probability_opr     OUT NOCOPY VARCHAR2,
                           x_close_reason            OUT NOCOPY VARCHAR2,
                           x_competitor              OUT NOCOPY VARCHAR2,
                           x_opty_number             OUT NOCOPY VARCHAR2,
                           x_total_opp_amount        OUT NOCOPY VARCHAR2,
                           x_total_opp_amt_opr       OUT NOCOPY VARCHAR2,
                           x_opty_name               OUT NOCOPY VARCHAR2,
                           x_customer                OUT NOCOPY VARCHAR2,
                           x_partner                 OUT NOCOPY VARCHAR2,
                           x_from_date               OUT NOCOPY DATE,
                           x_to_date                 OUT NOCOPY DATE)
                          IS


  l_currency             VARCHAR2(2000);
  l_salesgroup_id        VARCHAR2(5000);
  l_salesgroup_flag      VARCHAR2(1);
  l_period_id            VARCHAR2(200);
  l_primary_currency     VARCHAR2(30);
  l_parameter_valid      BOOLEAN;
  l_err_msg              VARCHAR2(320);
  l_err_desc             VARCHAR2(4000);
  l_err_msg1             VARCHAR2(320);
  l_err_desc1            VARCHAR2(4000);
  l_proc                 VARCHAR2(20);
  l_log_str              VARCHAR2(3000);
  l_resource_id          VARCHAR2(5000);
  l_resource_id_flag     VARCHAR2(1);
  l_from_period_name     VARCHAR2(1000);
  l_to_period_name       VARCHAR2(1000);
  l_from_date		         DATE;
  l_to_date		           DATE;
  l_from_cal_date        VARCHAR2(100);
  l_to_cal_date          VARCHAR2(100);

  l_sls_stge             VARCHAR2(5000);

  l_page_period_type     Varchar2(100);
  l_sls_methodology      VARCHAR2(4000);
  l_win_probability      VARCHAR2(100);
  l_win_probability_opr  VARCHAR2(100);
  l_customer             VARCHAR2(5000);
  l_customer_flag        VARCHAR2(1);
  l_source               VARCHAR2(5000);
  l_source_flag          VARCHAR2(1);
  l_frcst_owner          VARCHAR2(100);
  l_oppty_name           VARCHAR2(500);
  l_partner_name         VARCHAR2(5000);
  l_competitor           VARCHAR2(100);
  l_creation_date        VARCHAR2(100);
  l_opty_number          VARCHAR2(100);
  l_partner_level        VARCHAR2(100);
  l_partner_rou_status   VARCHAR2(100);
  l_partner_type         VARCHAR2(100);
  l_total_opp_amount     VARCHAR2(100);
  l_total_opp_amt_opr    VARCHAR2(100);
  l_update_date          VARCHAR2(100);
  l_prodcat_id           VARCHAR2(4000);
  l_item_id              VARCHAR2(4000);
  l_rptby                VARCHAR2(10);
  l_is_number            BOOLEAN;


BEGIN
g_pkg  			:= 'bil.patch.115.sql.BIL_TX_UTIL_RPT_PKG';
l_err_desc              := 'Please run with a valid ';
l_parameter_valid       := True;
l_proc                  := 'GET_PAGE_PARAMS ';
l_is_number             := TRUE;

    IF chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
	     writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
 	              p_module 	  => g_pkg || l_proc || 'begin',
	              p_msg 	  => 'Start of Procedure '||l_proc);
	  END IF;

    x_parameter_valid := l_parameter_valid;

-- Start retrieving page parameters

 IF p_page_parameter_tbl IS NOT NULL AND p_page_parameter_tbl.count > 0 THEN
    IF p_page_parameter_tbl.count > 0 THEN
        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

         --     insert into ZZ  values('parameterName '||p_page_parameter_tbl(i).parameter_name||'value'||p_page_parameter_tbl(i).parameter_value||'parameter_id '||p_page_parameter_tbl(i).parameter_id||'Operator = '||p_page_parameter_tbl(i).operator);
         --     commit;

            -- Getting Viewby value. If NULL, set it to some thing as PMV expects something
            IF p_page_parameter_tbl(i).parameter_name ='VIEW_BY' THEN
                x_viewby := p_page_parameter_tbl(i).parameter_value;
                IF x_viewby IS NULL THEN
                x_viewby := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
                END IF;
            End IF;

            -- Period_Type value. SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'PRD_TYPE+TYPE' THEN
                l_page_period_type := p_page_parameter_tbl(i).parameter_value;
             END IF;

             IF l_page_period_type IS NOT NULL  THEN
		            x_period_type := l_page_period_type;
	           END IF;


             --  pass date for both to and from
             -- From date SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='FROM_PRD+FROM' THEN
                l_from_period_name := p_page_parameter_tbl(i).parameter_value;
                 IF  l_from_period_name IS NOT NULL THEN
                     l_from_date := GET_FROM_DATE(p_from_period_name => l_from_period_name);
                 END IF;
                x_from_date := NVL(l_from_date, sysdate);
             END IF;

             -- Day level From date
             IF p_page_parameter_tbl(i).parameter_name ='BIL_TX_FROM_DATE' THEN
                 l_from_cal_date := p_page_parameter_tbl(i).parameter_value;
                 IF l_from_cal_date  <> 'All' THEN
                    l_from_cal_date := REPLACE(l_from_cal_date , '''');
                    x_from_date :=  l_from_cal_date;
                 ELSE
                    x_from_date := SYSDATE;
                 END IF;
            END IF;


            -- To date SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='TO_PRD+TO' THEN
                 l_to_period_name := p_page_parameter_tbl(i).parameter_value;
                 x_to_period_name := l_to_period_name;

                 IF l_to_period_name IS NOT NULL THEN
                    l_to_date := GET_TO_DATE (p_to_period_name => l_to_period_name);
                 END IF;
                 x_to_date := NVL(l_to_date, sysdate);
            END IF;

            -- TO Day level date
            IF p_page_parameter_tbl(i).parameter_name ='BIL_TX_TO_DATE' THEN
                l_to_cal_date := p_page_parameter_tbl(i).parameter_value;
                IF l_to_cal_date <> 'All' then
                   l_to_cal_date := REPLACE(l_to_cal_date , '''');
                   x_to_date :=  l_to_cal_date;
                ELSE
                   x_to_date := SYSDATE;
                END IF;
            END IF;



            -- Forecast Owner SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='FRCST_ONER+ONER' THEN
                l_frcst_owner := p_page_parameter_tbl(i).parameter_id;
                x_frcst_owner := l_frcst_owner;
            END IF;


/*
            --  Sales Group IDs. MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='SLS_GRP+GRP' THEN
                l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;
                 x_sg_id := l_salesgroup_id;
            END IF;

*/

            --  Sales Group IDs. MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
                l_salesgroup_id := p_page_parameter_tbl(i).parameter_id;
                 x_sg_id := l_salesgroup_id;
            END IF;




            -- Sales Rep MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='SLS_PRSON+PERSON' THEN
               l_resource_id := p_page_parameter_tbl(i).parameter_id;
               x_resource_id := l_resource_id;
            END IF;



            -- If it is  a text input box we should use attribute name not measure+level
            -- Opportunity Name
            IF p_page_parameter_tbl(i).parameter_name ='BIL_TX_OPTY_NAME' THEN
               l_oppty_name := p_page_parameter_tbl(i).parameter_id;
               IF l_oppty_name IS NOT NULL OR l_oppty_name <> 'All' THEN
                  l_oppty_name := REPLACE(l_oppty_name , '''');
                  x_opty_name := ''''||l_oppty_name||'%'||'''';
               ELSE
                  x_opty_name := '';
               END IF;

            END IF;


            -- Customer  --  MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'CUSTOMER+CUST' THEN
               l_customer := p_page_parameter_tbl(i).parameter_id;
               x_customer := l_customer;
            END IF;

            -- Lead / Opportunity Source  SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'SOURCE+SOUR' THEN
               l_source := p_page_parameter_tbl(i).parameter_id;
               x_source := TO_NUMBER(REPLACE(l_source , ''''));
            END IF;

             -- Opportunity Status MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'OPP_STATUS+STAT' THEN
               x_opp_status := p_page_parameter_tbl(i).parameter_id;
            END IF;

             -- Win Probability  SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'BIL_TX_WIN_PROB' THEN
               l_win_probability := p_page_parameter_tbl(i).parameter_id;
               l_win_probability_opr := p_page_parameter_tbl(i).operator;

               IF l_win_probability_opr = 1 THEN
                  l_win_probability_opr := '>=' ;
               ELSIF l_win_probability_opr = 2 THEN
                  l_win_probability_opr := '>' ;
               ELSIF l_win_probability_opr = 3 THEN
                  l_win_probability_opr := '<' ;
               ELSIF l_win_probability_opr = 4 THEN
                  l_win_probability_opr := '<=' ;
               ELSE
                  l_win_probability_opr := '=' ;
               END IF;


               IF l_win_probability IS NOT NULL THEN
	       	l_is_number := BIL_TX_UTIL_RPT_PKG.WP_IS_NUMBER(l_win_probability);
	       END IF;

	       	IF l_is_number THEN
               		x_win_probability := REPLACE(l_win_probability , '''');
               		x_win_probability_opr := REPLACE(l_win_probability_opr, '''');
			       l_parameter_valid := TRUE;
                	x_parameter_valid := l_parameter_valid;
	       	ELSE
			       l_parameter_valid := FALSE;
                        x_win_probability_opr := NULL;
                        l_win_probability := NULL;
                	x_parameter_valid := l_parameter_valid;
	       	END IF;


            END IF;

            -- Sales Channel ID  MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'SLS_CHNL+CHNL' THEN
               x_sls_chnl := p_page_parameter_tbl(i).parameter_id;
             END IF;

            -- Getting the Product Category ID. MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='PROD_CAT+CAT' THEN
                  l_prodcat_id := p_page_parameter_tbl(i).parameter_id;

                  -- MAKE A CALL PIECE PRODUCTS


                  PARSE_PRODCAT_ITEM_ID(p_prodcat_id => l_prodcat_id,
                                        p_item_id   => l_item_id);

                  x_prodcat_id := l_prodcat_id;
                  x_item_id := l_item_id;

            END IF;



            -- Partner Name  MULTIPLE SELECT
            IF p_page_parameter_tbl(i).parameter_name ='PARTNER+NAME' THEN
		           x_partner :=  p_page_parameter_tbl(i).parameter_id;
            END IF;


            -- Currency value.  SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+CURR' THEN
               l_currency := p_page_parameter_tbl(i).parameter_id;
                IF l_currency IS NOT NULL THEN
                    x_to_currency := NVL(l_currency, 'USD');
                 END IF;
            END IF;

            -- Close Reason SINGLE SELECT  -- DONE
            IF p_page_parameter_tbl(i).parameter_name = 'CLOSE+REASON' THEN
                  x_close_reason := p_page_parameter_tbl(i).parameter_id;
            END IF;

            -- Competitor SINGLE SELECT -- done
            IF p_page_parameter_tbl(i).parameter_name = 'COMPTETOR+COMP' THEN
                  l_competitor := p_page_parameter_tbl(i).parameter_id;
                  x_competitor := TO_NUMBER(REPLACE(l_competitor , ''''));
            END IF;


           -- Opportunity Number INSERT  -- DONE
           IF p_page_parameter_tbl(i).parameter_name = 'BIL_TX_OPP_NUMBER' THEN
                  l_opty_number := p_page_parameter_tbl(i).parameter_id;
                  IF l_opty_number IS NOT NULL OR l_opty_number <> 'All' THEN
                     l_opty_number := REPLACE(l_opty_number , '''');
                     x_opty_number := ''''||l_opty_number||'%'||'''';
                  ELSE
                     x_opty_number := '';
                  END IF;
           END IF;

           --  Partner Level  SINGLE SELECT
           IF p_page_parameter_tbl(i).parameter_name = 'PART_LEVEL+LEVEL' THEN
              l_partner_level := p_page_parameter_tbl(i).parameter_id;
           END IF;

           -- Partner Routing Status  SINGLE SELECT
           IF p_page_parameter_tbl(i).parameter_name = 'PART_ROU_STAT+ROU' THEN
              l_partner_rou_status := p_page_parameter_tbl(i).parameter_id;
           END IF;

           -- Partner Type  SINGLE SELECT
           IF p_page_parameter_tbl(i).parameter_name = 'PART_TYPE+PART' THEN
              l_partner_type := p_page_parameter_tbl(i).parameter_id;
           END IF;

           -- Sales Stage ID  SINGLE SELECT  (Depends on sales methodology)
           IF p_page_parameter_tbl(i).parameter_name = 'SLS_STAGE+STAGE' THEN
                  l_sls_stge := p_page_parameter_tbl(i).parameter_id;
                  IF l_sls_stge IS NOT NULL OR l_sls_stge <> 'All' THEN
                     x_sls_stge := TO_NUMBER(REPLACE(l_sls_stge , ''''));
                  ELSE
                     x_sls_stge := '';
                  END IF;
            END IF;


            -- Sales Methodology  SINGLE SELECT
            IF p_page_parameter_tbl(i).parameter_name = 'METHODOLOGY+METH' THEN
                     l_sls_methodology := p_page_parameter_tbl(i).parameter_id;
                  IF l_sls_methodology IS NOT NULL OR l_sls_methodology <> 'All' THEN
                     x_sls_methodology := TO_NUMBER(REPLACE(l_sls_methodology , ''''));
                  ELSE
                     x_sls_methodology := '';
                 END IF;
            END IF;

            -- Total Opportunity Amount  INSERT

            IF p_page_parameter_tbl(i).parameter_name = 'BIL_TX_TOT_OPP_AMT' THEN
                  l_total_opp_amount := p_page_parameter_tbl(i).parameter_id;
                  l_total_opp_amt_opr := p_page_parameter_tbl(i).operator;
                  IF l_total_opp_amount IS NOT NULL OR l_total_opp_amount <> 'All' THEN
		                 l_is_number := BIL_TX_UTIL_RPT_PKG.IS_NUMBER(l_total_opp_amount);
		                 IF l_is_number THEN
                     	  x_total_opp_amount := REPLACE(l_total_opp_amount , '''');
                     	  x_total_opp_amt_opr := REPLACE(l_total_opp_amt_opr, '''');
			                  l_parameter_valid := TRUE;
			                  x_parameter_valid := l_parameter_valid;

		                 ELSE
			                  l_parameter_valid := FALSE;
			                  x_parameter_valid := l_parameter_valid;
		                 END IF;
                  ELSE
                     x_total_opp_amount := '';
                     x_total_opp_amt_opr := '';
                  END IF;
            END IF;


           -- Getting Report By  SINGLE SELECT
           IF p_page_parameter_tbl(i).parameter_name = 'REPORT_BY+RPT' THEN
              l_rptby := p_page_parameter_tbl(i).parameter_id;
              x_rptby := TO_NUMBER(REPLACE(l_rptby , ''''));

           END IF;

          -- Getting Order By  Parameter -- The column on which the data is sorted  -- Added by Kedukull
           IF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
             x_order := TRIM(p_page_parameter_tbl(i).parameter_value);

           END IF;

       END LOOP;
    END IF;
 END IF;

  IF l_page_period_type IS NULL  THEN
                l_parameter_valid := FALSE;
                x_parameter_valid := l_parameter_valid;
                l_err_msg         := 'Null Period Type ';
                l_err_desc        := l_err_desc || ' ,PERIOD_TYPE';
 END IF;

  IF l_salesgroup_id IS NULL  THEN
                l_parameter_valid := FALSE;
                x_parameter_valid := l_parameter_valid;
                l_err_msg         := 'Null Period Type ';
                l_err_desc        := l_err_desc || ' ,SALESGROUP_ID';
 END IF;


 IF l_currency IS NULL THEN
     l_parameter_valid := FALSE;
     x_parameter_valid := l_parameter_valid;
     l_err_msg         := 'Null parameter(s)';
     l_err_desc        := l_err_desc ||  ' ,CURRENCY';
 END IF;


   -- Update error message and error description in the caes of null parameters
   IF x_parameter_valid = TRUE THEN
       IF chkLogLevel(fnd_log.LEVEL_STATEMENT)  THEN
	        l_log_str := 'View by : '||x_viewby||
                       'l_page_period_type : '||l_page_period_type||
                       'l_currency : '||l_currency||
                       'x_sg_id : '||x_sg_id||
                       'x_total_opp_amount : '||x_total_opp_amount||
                       'x_win_probability : '||x_win_probability||
                       'x_prodcat_id : '||x_prodcat_id;

               -- Need to modify above to capture all IDs
               writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
								        p_module 	=> g_pkg || l_proc || 'Params',
								        p_msg 	    => l_log_str);
	     END IF;
    ELSE
       IF chkLogLevel(fnd_log.LEVEL_STATEMENT)  THEN
              writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
		        	          p_module 	  => g_pkg || l_proc || l_err_msg,
						           p_msg 	  => l_err_desc );
	      END IF;
    END IF;


END GET_PAGE_PARAMS;


PROCEDURE GET_DETAIL_PAGE_PARAMS
                          (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                           p_region_id               IN     VARCHAR2,
                           x_parameter_valid         OUT NOCOPY BOOLEAN,
                           x_viewby                  OUT NOCOPY VARCHAR2,
                           x_lead_id                 OUT NOCOPY VARCHAR2,
                           x_cust_id                 OUT NOCOPY VARCHAR2,
                           x_credit_type_id          OUT NOCOPY VARCHAR2
                           ) IS

  l_parameter_valid      BOOLEAN;
  l_err_msg              VARCHAR2(320);
  l_err_desc             VARCHAR2(4000);
  l_proc                 VARCHAR2(200);
  l_log_str              VARCHAR2(3000);
  l_lead_id              VARCHAR2(100);
  l_cust_id              VARCHAR2(100);
  l_credit_type_id       VARCHAR2(100);


BEGIN
g_pkg  			:= 'bil.patch.115.sql.BIL_TX_UTIL_RPT_PKG';
l_err_desc              := 'Please run with a valid ';
l_parameter_valid       := True;
l_proc                  := 'GET_DETAIL_PAGE_PARAMS';

    IF chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
	     writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
 	              p_module 	  => g_pkg || l_proc || 'begin',
	              p_msg 	  => 'Start of Procedure '||l_proc);
	  END IF;

    x_parameter_valid := l_parameter_valid;

-- Start retrieving page parameters
 IF p_page_parameter_tbl IS NOT NULL AND p_page_parameter_tbl.count > 0 THEN
    IF p_page_parameter_tbl.count > 0 THEN
        FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP


            -- Getting Viewby value. If NULL, set it to some thing as PMV expects something
             IF p_page_parameter_tbl(i).parameter_name ='VIEW_BY' THEN
                x_viewby := p_page_parameter_tbl(i).parameter_value;
                IF x_viewby IS NULL THEN
                x_viewby := 'ORGANIZATION+JTF_ORG_SALES_GROUP';
                END IF;
            End IF;
            -- Getting leadids
             IF p_page_parameter_tbl(i).parameter_name ='leadid' THEN
                l_lead_id := p_page_parameter_tbl(i).parameter_value;
                x_lead_id := l_lead_id;
             End IF;

            -- Getting Customer ids
             IF p_page_parameter_tbl(i).parameter_name ='custid' THEN
                l_cust_id := p_page_parameter_tbl(i).parameter_value;
                x_cust_id := l_cust_id;
            End IF;


            IF p_page_parameter_tbl(i).parameter_name = 'CrdType' THEN
               l_credit_type_id := p_page_parameter_tbl(i).parameter_value;
               x_credit_type_id := l_credit_type_id ;
            END IF;

       END LOOP;
    END IF;
 END IF;
   -- Update error message and error description in the caes of null parameters
   IF x_parameter_valid = TRUE THEN
       IF chkLogLevel(fnd_log.LEVEL_STATEMENT)  THEN
	        l_log_str := 'View by : '||x_viewby;

               -- Need to modify above to capture all IDs
               writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
								        p_module 	=> g_pkg || l_proc || 'Params',
								        p_msg 	    => l_log_str);
	     END IF;
    ELSE
       IF chkLogLevel(fnd_log.LEVEL_STATEMENT)  THEN
              writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
		        	          p_module 	  => g_pkg || l_proc || l_err_msg,
						           p_msg 	  => l_err_desc );
	      END IF;
    END IF;


END GET_DETAIL_PAGE_PARAMS;




/*************************************************************************
* get_sales_group_id function is created to retrieve
* the default value of the sales_group_id
************************************** ***********************************/
FUNCTION get_sales_group_id RETURN NUMBER IS

l_sg_id             NUMBER;
l_resource_id       NUMBER;
BEGIN
g_pkg  := 'bil.patch.115.sql.BIL_TX_UTIL_RPT_PKG';
 BEGIN

    -- since SG and Sales Person are multi select we need to work
    -- on it differently than summary report.
     SELECT RESOURCE_ID
       INTO  l_resource_id
       FROM JTF_RS_RESOURCE_EXTNS
       WHERE user_id = fnd_global.user_id ;

      IF SQL%NOTFOUND THEN
          BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.get_sales_group_id',
		 						    p_msg 	  => 'Sales Group ID NOT FUND' );

  	   END IF;

  -- performance tuning

      SELECT  jrgm.group_id  into l_sg_id
       FROM   jtf_rs_group_members jrgm,
              jtf_rs_group_usages jrup
      WHERE   jrgm.RESOURCE_ID = l_resource_id
        AND   jrgm.delete_flag = 'N'
        AND   jrup.group_id=jrgm.group_id
        AND   jrup.usage='SALES'
        and rownum < 2  ;


     EXCEPTION
        WHEN OTHERS THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	            fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	            fnd_message.set_token('Error is : ' ,SQLCODE);
 	            fnd_message.set_token('Reason is : ', SQLERRM);
		          BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.get_sales_group_id',
		 						    p_msg 	  => fnd_message.get );
  	        END IF;
  	         l_sg_id := -1;
     END;

RETURN l_sg_id;

END get_sales_group_id;




/*************************************************************************
* get_product_id function is created to retrieve
* the default value of the product_id
************************************** ***********************************/
FUNCTION get_prod_cat_id RETURN NUMBER IS

l_prod_cat_id             VARCHAR2(1000);
BEGIN
g_pkg  := 'bil.patch.115.sql.BIL_TX_UTIL_RPT_PKG';
 BEGIN

  -- performance Tuning

     SELECT  to_char(a.category_id) ||'.'|| '001'
       INTO l_prod_cat_id
       FROM ENI_DENORM_HRCHY_PARENTS a
      WHERE a.OBJECT_TYPE = 'CATEGORY_SET'
        AND a.LANGUAGE = USERENV('LANG')
        AND ROWNUM < 2;


     EXCEPTION
        WHEN OTHERS THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
                    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                    fnd_message.set_token('Error is : ' ,SQLCODE);
                    fnd_message.set_token('Reason is : ', SQLERRM);
                          BIL_TX_UTIL_RPT_PKG.writeLog(
                                                          p_log_level => fnd_log.LEVEL_UNEXPECTED,
                                                                    p_module      => g_pkg || '.get_sales_group_id',
                                                                    p_msg         => fnd_message.get );
           END IF;
           l_prod_cat_id := -1;
END;

RETURN l_prod_cat_id;

END get_prod_cat_id;



/*************************************************************************
*-- Name: GET_DEFAULT_QUERY
*-- Desc: Returns default blank query to be used by individual report procedure
*-- Output: Default sql statement
*************************************************************************/
/*
-- Removed , not used in ASN reports. Caused SQL Repository Shared Memory issues.
/*
PROCEDURE GET_DEFAULT_QUERY(
                          p_RegionName        IN  VARCHAR2,
                          x_SqlStr            OUT NOCOPY VARCHAR2
                          ) IS

CURSOR cAkRegionItem (pRegionName IN VARCHAR2)
IS
    SELECT attribute_code FROM AK_REGION_ITEMS
    WHERE REGION_CODE = pRegionName
    AND (ATTRIBUTE3 LIKE 'SI_MEASURE%' OR ATTRIBUTE1 ='GRAND_TOTAL' or ATTRIBUTE1 = 'DRILL ACROSS URL')
    AND NVL(ATTRIBUTE3, 'NV') NOT LIKE '"%"'
    ORDER BY DISPLAY_SEQUENCE;
temp_sql VARCHAR2(5000);
BEGIN
    temp_sql:= 'SELECT null viewby';
    -- Open a FOR Loop to access every individual region items
    FOR ITEM_REC IN cAkRegionItem(p_RegionName)
        LOOP
        BEGIN
            temp_sql:= temp_sql ||',null '||ITEM_REC.attribute_code;
        END;
    END LOOP;
   temp_sql:= temp_sql ||' FROM DUAL WHERE 1=2 and rownum<0';
   x_SqlStr:= temp_sql;
END;
*/
--
PROCEDURE GET_OTHER_PROFILES(
                          x_DebugMode            OUT NOCOPY VARCHAR2
                          ) IS

BEGIN
    x_DebugMode := FND_PROFILE.Value('BIS_PMF_DEBUG');

END;


--  **********************************************************************
--	FUNCTION chkLogLevel
--
--	Purpose
--	To check if log is Enabled for Messages
--      This function is a wrapper on FND APIs for OA Common Error
--       logging framework
--
--        p_log_level = Severity; valid values are -
--			1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--			2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--			3. Event Level (FND_LOG.LEVEL_EVENT)
--			4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--			5. Error Level (FND_LOG.LEVEL_ERROR)
--			6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--
--	Output values:-
--                       = TRUE if FND Log is Enabled
--	                    = FALSE if FND Log is DISABLED
--
--  **********************************************************************

FUNCTION chkLogLevel (p_log_level IN NUMBER) RETURN BOOLEAN IS
BEGIN
      IF (p_log_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
        RETURN TRUE; -- FND log is enabled
      END IF;
        RETURN FALSE;
        EXCEPTION
        WHEN OTHERS THEN
           NULL;
END chkLogLevel;


--  **********************************************************************
--	PROCEDURE writeLog
--
--	Purpose:
--	To log Messages
--      This procedure is a wrapper on FND APIs for OA Common Error
--       logging framework for Severity = Statement(1), Procedure(2)
--       , Event(3), Expected (4) and Error (5)
--
--      Input Variables :-
--        p_log_level = Severity; valid values are -
--			1. Statement Level (FND_LOG.LEVEL_STATEMENT)
--			2. Procedure Level (FND_LOG.LEVEL_PROCEDURE)
--			3. Event Level (FND_LOG.LEVEL_EVENT)
--			4. Exception Level (FND_LOG.LEVEL_EXCEPTION)
--			5. Error Level (FND_LOG.LEVEL_ERROR)
--			6. Unexpected Level (FND_LOG.LEVEL_UNEXPECTED)
--        p_module = Module Source Details
--        p_msg    = Message String
--
--  **********************************************************************
PROCEDURE writeLog (p_log_level IN NUMBER,
	                  p_module IN VARCHAR2,
	                  p_msg IN VARCHAR2)
IS
BEGIN
   IF ( p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     fnd_log.string(p_log_level, p_module, p_msg);
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
      NULL;
END writeLog;


PROCEDURE writeQuery (p_pkg         IN VARCHAR2,
	                  p_proc        IN VARCHAR2,
	                  p_query       IN VARCHAR2)

IS
  ind       NUMBER;
BEGIN
   ind       :=1;
  WHILE ind <= length(p_query) LOOP
     writeLog(
             p_log_level => fnd_log.LEVEL_STATEMENT,
             p_module => p_pkg || p_proc || ' statement ',
             p_msg => substr(p_query, ind, 4000));
     ind := ind + 4000;
  END LOOP;
  EXCEPTION
     WHEN OTHERS THEN
     NULL;
END writeQuery;


FUNCTION GET_DEF_PRD_TYPE RETURN VARCHAR2 IS
-- Brings default period type
l_period_type VARCHAR2(100);

BEGIN

   l_period_type := NVL(FND_PROFILE.VALUE('ASN_FRCST_DEFAULT_PERIOD_TYPE'), 'Month');

   IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.GET_DEF_PRD_TYPE',
		 						    p_msg 	  => fnd_message.get );
	  END IF;

RETURN l_period_type;

END GET_DEF_PRD_TYPE;


FUNCTION GET_DEFAULT_PERIOD RETURN VARCHAR2 IS

  l_period_name VARCHAR2(100);
  l_period_id VARCHAR2(10) ;

BEGIN

  SELECT period_name INTO l_period_name
 		FROM gl_periods
 		WHERE period_type = FND_PROFILE.VALUE('ASN_FRCST_DEFAULT_PERIOD_TYPE')
 		AND period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
 		AND trunc(sysdate) >= start_date and trunc(sysdate) <=  end_date;

 RETURN l_period_name;

 EXCEPTION
  WHEN OTHERS THEN

    IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.GET_DEFAULT_PERIOD',
		 						    p_msg 	  => fnd_message.get );
	  END IF;

END GET_DEFAULT_PERIOD;



FUNCTION GET_DEFAULT_CURRENCY RETURN VARCHAR2 IS

   l_currency_code VARCHAR2(100);

BEGIN

  l_currency_code := NVL(fnd_profile.value('ICX_PREFERRED_CURRENCY'),'USD');

  RETURN l_currency_code;

  IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.GET_DEFAULT_CURRENCY',
		 						    p_msg 	  => fnd_message.get );
	END IF;


END GET_DEFAULT_CURRENCY;

PROCEDURE PARSE_PRODCAT_ITEM_ID(
        p_prodcat_id IN OUT  NOCOPY VARCHAR2,
        p_item_id       OUT NOCOPY VARCHAR2) IS

   l_prodcat_id      VARCHAR2(4000);
   l_item_id         VARCHAR2(4000);

BEGIN

   IF(INSTR(p_prodcat_id, '.') > 0) then
      l_item_id := replace(SUBSTR(p_prodcat_id,instr(p_prodcat_id,'.') + 1),'''') ;
	    l_prodcat_id := replace(SUBSTR(p_prodcat_id,1,instr(p_prodcat_id,'.') - 1),'''');
	    l_prodcat_id := replace(l_prodcat_id,'''','');
   ELSE
      l_prodcat_id := p_prodcat_id;
   END IF;

   p_prodcat_id := l_prodcat_id;

   IF l_item_id = 001 THEN
      l_item_id := '';
   ELSE
      l_item_id := l_item_id;
   END IF;

   p_item_id:= l_item_id;


  EXCEPTION
  WHEN OTHERS THEN

    IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						  p_module 	  => g_pkg || '.PARSE_PRODCAT_ITEM_ID',
		 						  p_msg 	  => fnd_message.get
 								 );
	  END IF;

END PARSE_PRODCAT_ITEM_ID;


FUNCTION GET_DEFAULT_RPT_BY RETURN NUMBER IS
   BEGIN
      RETURN 1; --Default to Close Date in the dropdown

  EXCEPTION
  WHEN OTHERS THEN

    IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.GET_DEFAULT_RPT_BY',
		 						    p_msg 	  => fnd_message.get );
	  END IF;

END GET_DEFAULT_RPT_BY;

-- Here logic is if record exists in gl_periods then pass date otherwise
-- we have to see how to make it work(for day)i.e.,
-- if it is not a week, month, quarter, year. not records does not exist in gl_periods

FUNCTION GET_FROM_DATE (p_from_period_name IN VARCHAR2) RETURN DATE IS
   l_from_date DATE;
   BEGIN



	SELECT start_date
	INTO l_from_date
	FROM gl_periods
	WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
	AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
	AND ADD_MONTHS(end_date, 6)
	AND ADJUSTMENT_PERIOD_FLAG = 'N'
	AND period_name = p_from_period_name;

/*
     SELECT start_date into l_from_date
       FROM BIL_TX_PERIOD_NAME_V
       WHERE value  =  p_from_period_name;
*/

     IF SQL%NOTFOUND THEN
        l_from_date := sysdate;
     END IF;

    RETURN  l_from_date;

    EXCEPTION

    WHEN OTHERS THEN

       IF bil_tx_util_rpt_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	        fnd_message.set_token('Error is : ' ,SQLCODE);
 	        fnd_message.set_token('Reason is : ', SQLERRM);
		      bil_tx_util_rpt_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 			      p_module    =>  '.GET_FROM_DATE',
		 			      p_msg 	  => fnd_message.get );
		 			l_from_date := sysdate;

	     END IF;

	   RETURN  l_from_date;



END  GET_FROM_DATE;

FUNCTION GET_TO_DATE (p_to_period_name IN VARCHAR2) RETURN DATE IS
   l_to_date DATE;
   BEGIN

/*
     SELECT end_date
     INTO l_to_date
     FROM BIL_TX_PERIOD_NAME_V
     WHERE value  =  p_to_period_name;
*/
        SELECT end_date
        INTO l_to_date
        FROM gl_periods
        WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
        AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
        AND ADD_MONTHS(end_date, 6)
        AND ADJUSTMENT_PERIOD_FLAG = 'N'
        AND period_name = p_to_period_name;

    IF SQL%NOTFOUND THEN
         l_to_date := sysdate;
     END IF;


   RETURN  l_to_date;

    EXCEPTION

    WHEN OTHERS THEN

       IF bil_tx_util_rpt_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	        fnd_message.set_token('Error is : ' ,SQLCODE);
 	        fnd_message.set_token('Reason is : ', SQLERRM);
		      bil_tx_util_rpt_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 			      p_module    =>  '.GET_TO_DATE',
		 			      p_msg 	  => fnd_message.get );

		 		 l_to_date := sysdate;
	     END IF;

   RETURN  l_to_date;

END  GET_TO_DATE;

PROCEDURE PARSE_MULTI_SELECT(p_multi_select_string IN OUT NOCOPY VARCHAR,
                             p_single_select_flag     OUT NOCOPY VARCHAR)
IS

BEGIN
	 p_multi_select_string :=  REPLACE (p_multi_select_string, '''','');

   IF INSTR(p_multi_select_string,',') > 0  THEN
	    p_single_select_flag := 'M';
	   -- p_multi_select_string :=  '( '||p_multi_select_string || ' )';
	   p_multi_select_string :=  p_multi_select_string;
   ELSE
	    p_single_select_flag := 'S';
	    p_multi_select_string := p_multi_select_string;
	END IF;


END PARSE_MULTI_SELECT;

-- Kiran's work
FUNCTION GET_RESOURCE_ID RETURN NUMBER IS
   l_resource_id number;
BEGIN
   select RESOURCE_ID
     into l_resource_id  from JTF_RS_RESOURCE_EXTNS
     where user_id = fnd_global.user_id ;

   RETURN l_resource_id;
   EXCEPTION
       when others then
       return -1 ;
END GET_RESOURCE_ID;

PROCEDURE days_in_status (p_param   IN  BIS_PMV_PAGE_PARAMETER_TBL,
                          asn_Table OUT NOCOPY BIS_MAP_TBL) IS
l_bid_tbl_rec BIS_MAP_REC := BIS_MAP_REC(null, null);
l_status varchar2(1000);
type t_stats_c is ref cursor; -- ref cursor
l_status_c  t_stats_c; -- ref cursor type
des varchar2(100);
single_status  varchar2(100);
l_schema        varchar2(80);
CNT NUMBER;
l_dummy varchar2(1);

BEGIN
  CNT := 1;
  l_schema           := 'BIL';
  asn_Table := BIS_MAP_TBL();
  -- asn_Table := BIS_MAP_TBL(null, null);
  l_status := NULL;

FOR i IN p_param.first..p_param.last LOOP
        IF p_param(i).parameter_name = 'OPP_STATUS+STAT' THEN
                l_status    := p_param(i).parameter_id;
        END IF;
END LOOP;

EXECUTE IMMEDIATE  'TRUNCATE TABLE'||' '||l_schema||'.'||'BIL_TX_PROD_TMP ';

IF (l_status IS NOT NULL) AND (NVL(UPPER(l_status),'ALL') <> 'ALL') THEN
         l_status := REPLACE(l_status,'''',null);

         IF INSTR(l_status,',') = 0 THEN
                 	INSERT INTO BIL_TX_PROD_TMP(ATTR4) VALUES (l_status);
         ELSE
	 	WHILE  (INSTR(l_status,',') > 0)  LOOP
        	 	single_status := SUBSTR(l_status,1,  INSTR(l_status,',') -1);
		 	INSERT INTO  BIL_TX_PROD_TMP(ATTR4) VALUES (single_status);
        	 	l_status := SUBSTR(l_status,INSTR(l_status,',')+1 );
	 	END LOOP;
         	INSERT INTO  BIL_TX_PROD_TMP(ATTR4) VALUES (l_status);
	END IF;



          OPEN l_status_c  FOR 'SELECT ast.meaning
                                FROM as_statuses_b asb, as_statuses_tl ast, BIL_TX_PROD_TMP B
                                WHERE asb.status_code = B.ATTR4
                                AND  asb.status_code = ast.status_code
                                AND ast.language= userenv(''LANG'')
                                AND asb.enabled_flag = ''Y''
                                AND asb.opp_flag = ''Y''
                                ORDER BY ast.meaning ' ;
        LOOP
                FETCH  l_status_c   INTO des;
                EXIT WHEN l_status_c%NOTFOUND;
                l_bid_tbl_rec.key := 'BUCKET'||CNT||'_NAME';
                l_bid_tbl_rec.value := des;
                asn_Table.EXTEND;
                asn_Table(CNT) := l_bid_tbl_rec;
 		-- insert into x1 values ('asn_Table(CNT).key = '|| asn_Table(CNT).key||' '||'asn_Table(CNT).value ='||asn_Table(CNT).value,sysdate); commit;
		CNT := CNT + 1;
        END LOOP;
        CLOSE l_status_c;
ELSE
        OPEN l_status_c  FOR 'SELECT ast.meaning
                              FROM as_statuses_b asb, as_statuses_tl ast
                              WHERE asb.status_code = ast.status_code
                              AND ast.language= userenv(''LANG'')
                              AND asb.enabled_flag = ''Y''
                              AND asb.opp_flag = ''Y''
                              ORDER BY  ast.meaning ' ;
        LOOP
                FETCH  l_status_c   INTO des;
                EXIT WHEN l_status_c%NOTFOUND;
                l_bid_tbl_rec.key := 'BUCKET'||CNT||'_NAME';
                l_bid_tbl_rec.value := des;
                asn_Table.EXTEND;
                asn_Table(CNT) := l_bid_tbl_rec;
 		-- insert into x1 values ('asn_Table(CNT).key = '|| asn_Table(CNT).key||' '||'asn_Table(CNT).value ='||asn_Table(CNT).value,sysdate); commit;
		CNT := CNT + 1;
        END LOOP;
	Close l_status_c;
END IF;

END days_in_status;

PROCEDURE days_in_status_code (p_param   IN  BIS_PMV_PAGE_PARAMETER_TBL,
                               asn_Table_code OUT NOCOPY BIS_MAP_TBL) IS

l_bid_tbl_rec_code BIS_MAP_REC := BIS_MAP_REC(null, null);

l_status varchar2(1000);
type t_stats_c is ref cursor; -- ref cursor
l_status_c  t_stats_c; -- ref cursor type
code VARCHAR2(100);
single_status  varchar2(100);
l_schema        varchar2(80);
CNT NUMBER;
l_dummy varchar2(1);

BEGIN
  CNT := 1;
  l_schema           := 'BIL';
  asn_Table_code := BIS_MAP_TBL();

  l_status := NULL;

FOR i IN p_param.first..p_param.last LOOP
        IF p_param(i).parameter_name = 'OPP_STATUS+STAT' THEN
                l_status    := p_param(i).parameter_id;
	END IF;
END LOOP;

EXECUTE IMMEDIATE  'TRUNCATE TABLE'||' '||l_schema||'.'||'BIL_TX_PROD_TMP ';

IF (l_status IS NOT NULL) AND (NVL(UPPER(l_status),'ALL') <> 'ALL') THEN
         l_status := REPLACE(l_status,'''',null);

         IF INSTR(l_status,',') = 0 THEN
	                INSERT INTO BIL_TX_PROD_TMP(ATTR4) VALUES (l_status);
         ELSE
	 	WHILE  (INSTR(l_status,',') > 0)  LOOP
        	 	single_status := SUBSTR(l_status,1,  INSTR(l_status,',') -1);
		 	INSERT INTO  BIL_TX_PROD_TMP(ATTR4) VALUES (single_status);
        	 	l_status := SUBSTR(l_status,INSTR(l_status,',')+1 );
	 	END LOOP;
		INSERT INTO  BIL_TX_PROD_TMP(ATTR4) VALUES (l_status);
	END IF;


          OPEN l_status_c  FOR 'SELECT ast.status_code
                                FROM as_statuses_b asb, as_statuses_tl ast, BIL_TX_PROD_TMP B
                                WHERE asb.status_code = B.ATTR4
                                AND  asb.status_code = ast.status_code
                                AND ast.language= userenv(''LANG'')
                                AND asb.enabled_flag = ''Y''
                                AND asb.opp_flag = ''Y''
                                ORDER BY ast.meaning ' ;
        LOOP
                FETCH  l_status_c   INTO code;
		EXIT WHEN l_status_c%NOTFOUND;

		l_bid_tbl_rec_code.key := 'BUCKET'||CNT||'_NAME';
                l_bid_tbl_rec_code.value := code;

		asn_Table_code.EXTEND;
                asn_Table_code(CNT) := l_bid_tbl_rec_code;

 		 --insert into x1 values (31, 'asn_Table(CNT).key = '|| asn_Table(CNT).key||' '||'asn_Table(CNT).value ='||asn_Table(CNT).value,sysdate);
		CNT := CNT + 1;
        END LOOP;
        CLOSE l_status_c;
ELSE

        OPEN l_status_c  FOR 'SELECT ast.status_code
                              FROM as_statuses_b asb, as_statuses_tl ast
                              WHERE asb.status_code = ast.status_code
                              AND ast.language= userenv(''LANG'')
                              AND asb.enabled_flag = ''Y''
                              AND asb.opp_flag = ''Y''
                              ORDER BY  ast.meaning ' ;
        LOOP
                FETCH  l_status_c   INTO code;
		EXIT WHEN l_status_c%NOTFOUND;

		l_bid_tbl_rec_code.key := 'BUCKET'||CNT||'_NAME';
                l_bid_tbl_rec_code.value := code;

		asn_Table_code.EXTEND;
                asn_Table_code(CNT) := l_bid_tbl_rec_code;

 		 --insert into x1 values (32, 'asn_Table(CNT).key = '|| asn_Table(CNT).key||' '||'asn_Table(CNT).value ='||asn_Table(CNT).value,sysdate);
		CNT := CNT + 1;
        END LOOP;
	Close l_status_c;
END IF;

END days_in_status_code;

FUNCTION DEF_STRT_PRD RETURN NUMBER IS
l_default_period VARCHAR2(30);
l_start_date DATE;
l_default_start_period_id NUMBER;

BEGIN
l_default_period :=  NVL(FND_PROFILE.VALUE('ASN_FRCST_DEFAULT_PERIOD_TYPE'), 'Month');

/*
	SELECT start_Date
	INTO l_start_date
	FROM BIL_TX_PERIOD_NAME_V
	WHERE pTYPE=  l_default_period
	AND  trunc(sysdate) BETWEEN start_date and end_date;
*/


	SELECT start_date
	INTO l_start_date
	FROM gl_periods
	WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
	AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
	AND ADD_MONTHS(end_date, 6)
	AND ADJUSTMENT_PERIOD_FLAG = 'N'
	AND period_type =  l_default_period
	AND  trunc(sysdate) BETWEEN start_date and end_date;



	BEGIN
/*
	SELECT id
	INTO l_default_start_period_id
	FROM BIL_TX_PERIOD_NAME_V
	WHERE pTYPE= l_default_period
	AND start_date = l_start_date;
*/

	SELECT PERIOD_YEAR||DECODE(LENGTH(QUARTER_NUM), 1, 0||QUARTER_NUM, QUARTER_NUM)||
              DECODE(LENGTH(PERIOD_NUM), 1, 0||PERIOD_NUM, PERIOD_NUM)
        INTO l_default_start_period_id
	FROM gl_periods
	WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
	AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
	AND ADD_MONTHS(end_date, 6)
	AND ADJUSTMENT_PERIOD_FLAG = 'N'
	AND period_type = l_default_period
	AND start_date =  l_start_date;

	RETURN l_default_start_period_id;

	EXCEPTION
	WHEN NO_DATA_FOUND THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
                    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                    fnd_message.set_token('Error is : ' ,SQLCODE);
                    fnd_message.set_token('Reason is : ', SQLERRM);
                          BIL_TX_UTIL_RPT_PKG.writeLog(
                                                          p_log_level => fnd_log.LEVEL_UNEXPECTED,
                                                                    p_module      => g_pkg || '.DEF_STRT_PRD',
                                                                    p_msg         => fnd_message.get );
                END IF;
                 l_default_start_period_id := -1;
		RETURN l_default_start_period_id;
        WHEN OTHERS THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
                    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                    fnd_message.set_token('Error is : ' ,SQLCODE);
                    fnd_message.set_token('Reason is : ', SQLERRM);
                          BIL_TX_UTIL_RPT_PKG.writeLog(
                                                          p_log_level => fnd_log.LEVEL_UNEXPECTED,
                                                                    p_module      => g_pkg || '.DEF_STRT_PRD',
                                                                    p_msg         => fnd_message.get );
                END IF;
                 l_default_start_period_id := -1;
		RETURN l_default_start_period_id;
     END;


END DEF_STRT_PRD;

FUNCTION DEF_END_PRD RETURN NUMBER IS
l_default_period VARCHAR2(30);
l_end_date DATE;
l_default_end_period_id NUMBER;

BEGIN
l_default_period :=  NVL(FND_PROFILE.VALUE('ASN_FRCST_DEFAULT_PERIOD_TYPE'), 'Month');

/*
        SELECT end_Date
        INTO l_end_date
        FROM BIL_TX_PERIOD_NAME_V
        WHERE pTYPE=  l_default_period
        AND trunc(sysdate) BETWEEN start_date and end_date;
*/

	SELECT end_date
	INTO l_end_date
	FROM gl_periods
	WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
	AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
	AND ADD_MONTHS(end_date, 6)
	AND ADJUSTMENT_PERIOD_FLAG = 'N'
	AND period_type = l_default_period
	AND trunc(sysdate) BETWEEN start_date and end_date;

        BEGIN
/*
        SELECT id
        INTO l_default_end_period_id
        FROM BIL_TX_PERIOD_NAME_V
        WHERE pTYPE= l_default_period
        AND end_date = l_end_date;
*/

	SELECT PERIOD_YEAR||DECODE(LENGTH(QUARTER_NUM), 1, 0||QUARTER_NUM, QUARTER_NUM)||
                 DECODE(LENGTH(PERIOD_NUM), 1, 0||PERIOD_NUM, PERIOD_NUM)
	INTO l_default_end_period_id
	FROM gl_periods
	WHERE period_set_name = FND_PROFILE.VALUE('ASN_FRCST_FORECAST_CALENDAR')
	AND sysdate BETWEEN ADD_MONTHS(start_date, -6)
	AND ADD_MONTHS(end_date, 6)
	AND ADJUSTMENT_PERIOD_FLAG = 'N'
	AND period_type = l_default_period
	AND end_date = l_end_date;

        RETURN l_default_end_period_id;

       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
                    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                    fnd_message.set_token('Error is : ' ,SQLCODE);
                    fnd_message.set_token('Reason is : ', SQLERRM);
                          BIL_TX_UTIL_RPT_PKG.writeLog(
                                                          p_log_level => fnd_log.LEVEL_UNEXPECTED,
                                                                    p_module      => g_pkg || '.DEF_END_PRD',
                                                                    p_msg         => fnd_message.get );
                END IF;
                 l_default_end_period_id := -1;
                RETURN l_default_end_period_id;
        WHEN OTHERS THEN
            IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
                    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
                    fnd_message.set_token('Error is : ' ,SQLCODE);
                    fnd_message.set_token('Reason is : ', SQLERRM);
                          BIL_TX_UTIL_RPT_PKG.writeLog(
                                                          p_log_level => fnd_log.LEVEL_UNEXPECTED,
                                                                    p_module      => g_pkg || '.DEF_END_PRD',
                                                                    p_msg         => fnd_message.get );
                END IF;
                 l_default_end_period_id := -1;
                RETURN l_default_end_period_id;
     END;


END DEF_END_PRD;

FUNCTION GET_DEF_FORCST_TYPE RETURN NUMBER IS
   l_credit_type_id   NUMBER;
BEGIN

/*
   SELECT FND_PROFILE.VALUE('ASN_FRCST_CREDIT_TYPE_ID')
       INTO l_credit_type_id
       FROM DUAL;
   IF SQL%NOTFOUND THEN
      l_credit_type_id := 1;
   END IF;
*/

  l_credit_type_id := NVL(FND_PROFILE.VALUE('ASN_FRCST_CREDIT_TYPE_ID'),1);


  RETURN l_credit_type_id; --Default to Close Date in the dropdown

  EXCEPTION
  WHEN OTHERS THEN
    IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     						  p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 						    p_module 	  => g_pkg || '.GET_DEF_FORCST_TYPE',
		 						    p_msg 	  => fnd_message.get );

		   l_credit_type_id := 1;
	  END IF;

  RETURN l_credit_type_id;

END GET_DEF_FORCST_TYPE;

FUNCTION  GET_STATS_CODS_OPTY_FLGS(p_flgs IN VARCHAR2) RETURN VARCHAR2
IS
 l_stats_cods  VARCHAR2(1000);
 l_cnt  number := 0;
 CURSOR  status_cur(l_flgs VARCHAR2)  IS
        SELECT   asb.status_code
          FROM     as_statuses_b  asb
         WHERE   asb.enabled_flag = 'Y'
           AND     asb.opp_flag = 'Y'
	   AND win_loss_indicator||opp_open_status_flag||forecast_rollup_flag LIKE l_flgs;

BEGIN
FOR i IN status_cur(p_flgs)
       LOOP
         BEGIN
           IF  l_cnt = 0  THEN
               l_stats_cods := l_stats_cods ||''''''||i.status_code ||'''''';
               l_cnt:= l_cnt +1 ;
          ELSE
              l_stats_cods := l_stats_cods ||','||''''''||i.status_code ||'''''';
         END IF;
         END;
       END LOOP;
RETURN l_stats_cods;

EXCEPTION
  WHEN OTHERS THEN

    IF BIL_TX_UTIL_RPT_PKG.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
 	     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
 	     fnd_message.set_token('Error is : ' ,SQLCODE);
 	     fnd_message.set_token('Reason is : ', SQLERRM);
		   BIL_TX_UTIL_RPT_PKG.writeLog(
 	     				p_log_level => fnd_log.LEVEL_UNEXPECTED,
 		 			p_module 	  => g_pkg || '.GET_STATS_CODS_OPTY_FLGS',
		 			p_msg 	  => fnd_message.get );
   END IF;
END GET_STATS_CODS_OPTY_FLGS;

FUNCTION GET_WIN_PROB RETURN VARCHAR2
IS
l_win_prob VARCHAR2(100);

BEGIN

l_win_prob :=  FND_PROFILE.Value('ASN_OPP_WIN_PROBABILITY');

RETURN NVL(l_win_prob,0);

END GET_WIN_PROB;

FUNCTION IS_NUMBER (p_param_in IN VARCHAR2) RETURN BOOLEAN
IS
l_param_in NUMBER;
BEGIN
l_param_in :=NULL;

	BEGIN
        /*
	SELECT TO_NUMBER(REPLACE(p_param_in,',',NULL))
	INTO l_param_in
	FROM DUAL;
        */
        l_param_in := TO_NUMBER(REPLACE(p_param_in,',',NULL));

	EXCEPTION
	WHEN OTHERS THEN
		NULL;
	END;

IF l_param_in IS NULL    THEN
	RETURN FALSE;
ELSE
	RETURN TRUE;
END IF;
END IS_NUMBER;

FUNCTION WP_IS_NUMBER (p_param_in IN VARCHAR2) RETURN BOOLEAN
IS
l_param_in NUMBER;
BEGIN
l_param_in :=NULL;



   IF INSTR(p_param_in,'-') > 0 THEN
        BEGIN
        /*
        SELECT TO_NUMBER(
              substr (REPLACE(p_param_in,',',NULL),1,instr(REPLACE(p_param_in,',',NULL),'-')-1)
               )
        INTO l_param_in
        FROM DUAL;
        */
        l_param_in :=  TO_NUMBER(
              substr (REPLACE(p_param_in,',',NULL),1,instr(REPLACE(p_param_in,',',NULL),'-')-1));

        EXCEPTION
        WHEN OTHERS THEN
                NULL;
        END;
   ELSE
       BEGIN
       /*
        SELECT TO_NUMBER(REPLACE(p_param_in,',',NULL))
        INTO l_param_in
        FROM DUAL;
       */
       l_param_in :=  TO_NUMBER(REPLACE(p_param_in,',',NULL));

        EXCEPTION
        WHEN OTHERS THEN
                NULL;
        END;
  END IF;


IF l_param_in IS NULL    THEN
        RETURN FALSE;
ELSE
        RETURN TRUE;
END IF;
END WP_IS_NUMBER;


FUNCTION GET_OPTY_SMRY_INF_TIP RETURN VARCHAR2
IS
l_tip_inf varchar2(1000);
BEGIN
  l_tip_inf :=  FND_MESSAGE.GET_STRING('BIL','BIL_TX_OPTY_SMRY_INF_TIP');

RETURN l_tip_inf;

EXCEPTION
    WHEN OTHERS THEN
    NULL;
END  GET_OPTY_SMRY_INF_TIP;

PROCEDURE hide_parameter(p_param in bis_pmv_page_parameter_tbl,
                         hideParameter OUT NOCOPY VARCHAR2)
IS
 l_flag varchar2(1);
 l_calling_param varchar2(1000);
 pname         VARCHAR2(2000);
 pvalue        VARCHAR2(2000);
 pid           VARCHAR2(2000);
 caller           VARCHAR2(2000);
 dayVal           VARCHAR2(2000);
BEGIN

l_flag := 'N';

FOR i IN p_param.first..p_param.last LOOP
  pname  := p_param(i).parameter_name;
   pvalue := p_param(i).parameter_value;
   pid :=  p_param(i).parameter_id;

   if (pname = 'PRD_TYPE+TYPE') then
     dayVal := pid;
   end if;

IF (p_param(i).parameter_name =  'BIS_CALLING_PARAMETER') then
  caller := pid;
end if;

END LOOP;

   if(caller IN ('FROM_PRD+FROM', 'TO_PRD+TO') ) then
     if(instr(dayVal,'Day') > 0) then
       l_flag := 'Y';
     end if;
   end if;


   if(caller IN ('BIL_TX_FROM_DATE','BIL_TX_TO_DATE') ) then
     if(instr(dayVal,'Day') = 0) then
       l_flag := 'Y';
     end if;
   end if;


hideParameter := l_flag;

END hide_parameter;


END BIL_TX_UTIL_RPT_PKG;

/
