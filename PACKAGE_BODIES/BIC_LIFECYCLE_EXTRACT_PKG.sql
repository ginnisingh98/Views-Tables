--------------------------------------------------------
--  DDL for Package Body BIC_LIFECYCLE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIC_LIFECYCLE_EXTRACT_PKG" AS
/* $Header: biclcexb.pls 120.4 2005/12/27 10:32:17 vsegu ship $ */

  -- Global variables for who columns
  g_last_updated_by          NUMBER;
  g_created_by               NUMBER;
  g_last_update_login        NUMBER;
  g_request_id               NUMBER;
  g_program_application_id   NUMBER;
  g_program_id               NUMBER;

  g_lc_comparison_type    VARCHAR2(15);
  g_measure_for_lc_stage  VARCHAR2(30);
  g_lc_granularity_level  VARCHAR2(15);
  g_lc_starting_period    DATE;
  g_lc_new_cust_period    NUMBER;
  g_lc_insig_level        NUMBER;

  g_lc_measure_id         NUMBER;
--start month and end month for which LC stages being calculated

  g_lc_st_month   DATE ;
  g_lc_end_month  DATE ;
  -- user defined exceptions
   NO_LC_SETUP_DATA   EXCEPTION;
 NO_LC_PROFILE_DATA EXCEPTION;
 NO_LC_MEASURE_ID   EXCEPTION;

-----------------------------

PROCEDURE Initialize ;

FUNCTION Common_Select RETURN VARCHAR2 ;
--PROCEDURE get_lc_months ;
PROCEDURE Insert_New_Cust ;
PROCEDURE Insert_Insig_Cust(p_select VARCHAR2) ;
PROCEDURE Month_Range ( p_lc_comp_type  VARCHAR2,
                        p_lc_gran_level VARCHAR2,
                        p_n1            OUT NOCOPY NUMBER,
                        p_n2            OUT NOCOPY NUMBER,
                        p_n3            OUT NOCOPY NUMBER ) ;
PROCEDURE Insert_Record (p_org_id       NUMBER,
                         p_measure_id   NUMBER,
                         p_start_date   DATE,
                         p_cust_id      NUMBER,
                         p_value        NUMBER) ;

PROCEDURE Insert_Others(p_select      VARCHAR2) ;

FUNCTION Find_Stage (p_op1       VARCHAR2,
                     p_op2       VARCHAR2,
                     p_growth    NUMBER,
                     p_lcf       NUMBER,
                     p_vlu1      NUMBER,
                     p_vlu2      NUMBER) RETURN NUMBER;

PROCEDURE write_log (p_msg VARCHAR2, p_proc_name VARCHAR2) ;

TYPE curTyp IS REF CURSOR ;

g_growing_vlu1   number ;
g_growing_vlu2   number ;
g_defected_vlu1  number ;
g_defected_vlu2  number ;
g_declining_vlu1 number ;
g_declining_vlu2 number ;

g_op_growing1    varchar(2) ;
g_op_growing2    varchar(2) ;
g_op_defected1   varchar(2) ;
g_op_defected2   varchar(2) ;
g_op_declining1  varchar(2) ;
g_op_declining2  varchar(2) ;
-------------------------------------------------------------------------
-------------------------------------------------------------------------
PROCEDURE  extract_lifecycle_data (
    p_start_date   DATE,
    p_end_date     DATE,
    p_delete_flag  varchar2,
    p_org_id       NUMBER
    )  IS
 x_c_select        VARCHAR2(2000) ;
 rec_count	   number;
 x_mult_factor    bic_measure_attribs.mult_factor    % TYPE;
 x_operation_type bic_measure_attribs.operation_type % TYPE;
 x_sttmnt         varchar2(2000);
BEGIN
  rec_count      := 0;
  g_lc_st_month  := p_start_date;
  g_lc_end_month := p_end_date  ;
    bic_consolidate_cust_data_pkg.purge_party_summary_data;
    bic_consolidate_cust_data_pkg.purge_customer_summary_data;
    Initialize ;
    bic_summary_extract_pkg.debug(' entered extract_lifecycle_data + : ');
  IF p_delete_flag = 'N' THEN
    bic_summary_extract_pkg.extract_periods (
  				add_months(p_start_date ,g_lc_new_cust_period*- 1),
				p_end_date,
				'LIFE_CYCLE',
				'N',
				p_delete_flag,
				p_org_id);
   ELSE
    bic_summary_extract_pkg.extract_all_periods(
                add_months(p_start_date ,g_lc_new_cust_period*- 1),
				p_end_date);

   END IF;
  SELECT count(*) INTO rec_count
  FROM	 bic_temp_periods;
  IF rec_count = 0 THEN
    write_log('LIFE_CYCLE data  already extracted',
			  'bic_lifecycle_extract_pkg.extract_lifecycle_data');
  	RETURN;
  END IF;
--  write_log('Value of g_lc_comparision type ' || g_lc_comparison_type,
	--		  'bic_lifecycle_extract_pkg.extract_lifecycle_data');
--  write_log('Value of g_lc_granularity_level  ' || g_lc_granularity_level,
	--		  'bic_lifecycle_extract_pkg.extract_lifecycle_data');

  IF g_lc_granularity_level = 'Year' THEN
        bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-23);
  END IF;
  IF g_lc_comparison_type = 'POP' THEN
        IF g_lc_granularity_level = 'Month' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-1);
        ELSIF g_lc_granularity_level = 'Quarter' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-5);
        ELSIF g_lc_granularity_level = 'Half Year' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-11);
        END IF;
  ELSIF g_lc_comparison_type = 'YOY' THEN
        IF g_lc_granularity_level = 'Month' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-12);
        ELSIF g_lc_granularity_level = 'Quarter' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-14);
        ELSIF g_lc_granularity_level = 'Half Year' THEN
            bic_summary_extract_pkg.g_period_start_date := ADD_MONTHS(p_start_date,-17);
        END IF;
  END IF;
  bic_summary_extract_pkg.extract_all_periods( bic_summary_extract_pkg.g_period_start_date,p_end_date);
  IF g_measure_for_lc_stage = 'ORDER_NUM' OR g_measure_for_lc_stage = 'ORDER_QTY' THEN
     bic_summary_extract_pkg.get_sql_sttmnt(g_measure_for_lc_stage ,x_sttmnt ,
                                            x_operation_type,x_mult_factor);
     bic_summary_extract_pkg.run_sql(x_sttmnt);
  ELSIF g_measure_for_lc_stage = 'SALES' THEN
     bic_summary_extract_pkg.extract_sales(bic_summary_extract_pkg.g_period_start_date,p_end_date,NULL,'Y');
  END IF;
  write_log('Before Inserting New Customers for Life Cycle ....',
			  'bic_lifecycle_extract_pkg.extract_lifecycle_data');
  IF p_delete_flag = 'N' THEN
    bic_summary_extract_pkg.extract_periods (
  				add_months(p_start_date ,g_lc_new_cust_period*- 1),
				p_end_date,
				'LIFE_CYCLE',
				'N',
				p_delete_flag,
				p_org_id);
  ELSE
    bic_summary_extract_pkg.extract_all_periods(
                add_months(p_start_date ,g_lc_new_cust_period*- 1),
				p_end_date);
  END IF;
    x_c_select := Common_Select ;
    -- write_log(' the lc **select ***query is ' || x_c_select , 'lifecycle' );
    Insert_New_Cust ;
    write_log('Before Inserting Insignificant Customers for Life Cycle ....',
			'bic_lifecycle_extract_pkg.extract_lifecycle_data');
    insert_Insig_Cust(x_c_select) ;
    write_log('Before Inserting Stable, Defected, Growing and Declining
			 Customers for Life Cycle ....',
               'bic_lifecycle_extract_pkg.extract_lifecycle_data');
    Insert_Others(x_c_select) ;
    bic_consolidate_cust_data_pkg.populate_status_data(p_start_date, p_end_date, 'LIFE_CYCLE' );
    bic_consolidate_cust_data_pkg.purge_party_summary_data;
    bic_consolidate_cust_data_pkg.purge_customer_summary_data;
    bic_summary_extract_pkg.debug(' exited extract_lifecycle_data - : ');
    -- bic_summary_extract_pkg.g_period_start_date := p_start_date;
    COMMIT;
EXCEPTION
    WHEN NO_LC_SETUP_DATA THEN
        write_log(' LIFECYCLE data is not extracted due to exception : '||SQLERRM,
        'bic_lifecycle_extract_pkg.extract_lifecycle_data');
        bic_summary_extract_pkg.generate_error(bic_summary_extract_pkg.g_measure_code,
        'No records in BIC_LC_SETUP_ALL');
        ROLLBACK;
    WHEN NO_LC_PROFILE_DATA THEN
        write_log(' LIFECYCLE data is not extracted due to exception : '||SQLERRM,
        'bic_lifecycle_extract_pkg.extract_lifecycle_data');
        bic_summary_extract_pkg.generate_error(bic_summary_extract_pkg.g_measure_code,
        'No records in BIC_PROFILE_VALUES_ALL');
        ROLLBACK;
    WHEN NO_LC_MEASURE_ID THEN
        write_log(' LIFECYCLE data is not extracted due to exception : '||SQLERRM,
        'bic_lifecycle_extract_pkg.extract_lifecycle_data');
        bic_summary_extract_pkg.generate_error(bic_summary_extract_pkg.g_measure_code,
        'Measure_id not found for LIFE_CYCLE in the table BIC_MEASURES_ALL');
        ROLLBACK;
	WHEN OTHERS THEN
	    write_log(' LIFECYCLE data is not extracted due to exception : '||SQLERRM,
        'bic_lifecycle_extract_pkg.extract_lifecycle_data');
        bic_summary_extract_pkg.generate_error(bic_summary_extract_pkg.g_measure_code,'LIFECYCLE data is not extracted : '||SQLERRM);
        bic_summary_extract_pkg.g_period_start_date := p_start_date;
        ROLLBACK;
END extract_lifecycle_data ;
----------------------------
PROCEDURE Insert_New_Cust IS

  CURSOR party_cur IS
    SELECT party_id, MIN(NVL(account_established_date,creation_date))
	 FROM hz_cust_accounts
     GROUP BY party_id
	HAVING MIN(NVL(account_established_date,creation_date)) >=
		   ADD_MONTHS(g_lc_st_month,g_lc_new_cust_period*-1 +1 );
  x_party_id                 hz_cust_accounts.party_id                 % TYPE;
  x_account_established_date hz_cust_accounts.account_established_date % TYPE;
BEGIN
    bic_summary_extract_pkg.debug(' entered Insert_New_Cust + : ');
 OPEN party_cur;
  LOOP
    FETCH party_cur INTO x_party_id, x_account_established_date;
    IF party_cur % NOTFOUND THEN
	  EXIT;
    END IF;
    INSERT INTO bic_party_summary (
       measure_code
      ,measure_id
      ,party_id --,customer_id
      ,period_start_date
      ,VALUE
      ,bucket_id
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,last_update_login
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,score)
    SELECT
	 'LIFE_CYCLE'
      ,g_lc_measure_id
      ,x_party_id
      ,bdt.act_period_start_date
      ,1
      ,NULL
      ,SYSDATE
      ,g_last_updated_by
      ,SYSDATE
      ,g_created_by
      ,g_last_update_login
      ,g_request_id
      ,g_program_application_id
      ,g_program_id
      ,SYSDATE
      ,NULL
    FROM
       bic_temp_periods          bdt
    WHERE
       bdt.start_date BETWEEN g_lc_st_month AND g_lc_end_month
    AND x_account_established_date BETWEEN
		  ADD_MONTHS(bdt.act_period_end_date,g_lc_new_cust_period *-1)+1
	    AND bdt.act_period_end_date ;
   END LOOP;

  CLOSE party_cur;

   bic_summary_extract_pkg.debug(' exited Insert_New_Cust + : ');

  /*
 EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
	    -- most of the times, New customwers will be insignificant category.
        write_log('dup value for ' || x_party_id , ' knk lc' );
	    null;

   WHEN OTHERS THEN
	   write_log('Error:' || sqlerrm, 'bic_lifecycle_extract_pkg.Insert_New_Cust') ; */

END Insert_New_Cust ;

---------------------------------------------------------------------------------------

FUNCTION Common_Select  RETURN VARCHAR2 IS
 x_n1  NUMBER ;
 x_n2  NUMBER ;
 x_n3  NUMBER ;
 x_s   VARCHAR2(1100) ;
 x_s1  VARCHAR2(200) ;
 x_s2  VARCHAR2(40) ;
 x_s3  VARCHAR2(20) ;
 x_s4  VARCHAR2(40) ;
 x_s5  VARCHAR2(50) ;

 x_sc1  VARCHAR2(60) ;
 x_sc2  VARCHAR2(600) ;
 x_sc3  VARCHAR2(60) ;

 BEGIN


   Month_Range ( g_lc_comparison_type, g_lc_granularity_level, x_n1, x_n2, x_n3) ;

   x_s1  := 'SELECT start_date, customer_id , sum(p1_value) value_p1, sum(p2_value) value_p2
FROM (' ;

   x_sc1 := 'SELECT start_date, customer_id , ' ;
   x_s2  := 'sum(c.value) p1_value, 0 p2_value ' ;
   x_sc2 := 'FROM
             bic_customer_summary_all c, bic_measures_all m, bic_temp_periods d
             WHERE c.measure_id = m.measure_id
			AND m.measure_code = ''' || g_measure_for_lc_stage || '''
			AND d.start_date BETWEEN ''' || g_lc_st_month || '''
			AND ''' || g_lc_end_month  || '''
			AND c.period_start_date BETWEEN add_months(d.start_date,' ;

   x_s3  :=  TO_CHAR(x_n1) || ') AND start_date ' ;
   x_sc3 := '
     GROUP BY start_date, customer_id' ;
   x_s4  := ' 0 p1_value, sum(value) p2_value ' ;
   x_s5  :=  TO_CHAR(x_n2) || ') AND ADD_MONTHS(start_date,' || TO_CHAR(x_n3) || ') ' ;

   x_s   := x_s1 || x_sc1 || x_s2 || x_sc2 || x_s3 || x_sc3 || ' UNION ' ||
           x_sc1 || x_s4 || x_sc2 || x_s5 || x_sc3 || ')' || x_sc3 || ')
   WHERE value_p1 ';

   RETURN x_s ;

END Common_Select ;
-------------------------------------------------------

PROCEDURE Month_Range ( p_lc_comp_type  VARCHAR2,
                        p_lc_gran_level VARCHAR2,
                        p_n1            OUT NOCOPY NUMBER,
                        p_n2            OUT NOCOPY NUMBER,
                        p_n3            OUT NOCOPY NUMBER ) IS
 BEGIN

   IF p_lc_gran_level = 'Year' THEN
      p_n1 := -11 ;
      p_n2 := -23 ;
      p_n3 := -12 ;
   END IF ;

     IF p_lc_comp_type = 'POP' THEN
       IF p_lc_gran_level = 'Month' THEN
         p_n1 := 0 ;
         p_n2 := -1 ;
         p_n3 := -1 ;
       ELSIF p_lc_gran_level = 'Quarter' THEN
         p_n1  := -2 ;
         p_n2 := -5 ;
         p_n3 := -3 ;
       ELSIF p_lc_gran_level = 'Half Year' THEN
         p_n1 := -5 ;
         p_n2 := -11 ;
         p_n3 := -6 ;
       END IF;
     ELSE   --YOY
       IF p_lc_gran_level = 'Month' THEN
         p_n1 := 0 ;
         p_n2 := -12 ;
         p_n3 := -12 ;
       ELSIF p_lc_gran_level = 'Quarter' THEN
         p_n1  := -2 ;
         p_n2 := -14 ;
         p_n3 := -12 ;
       ELSIF p_lc_gran_level = 'Half Year' THEN
         p_n1  := -5 ;
         p_n2 := -17 ;
         p_n3 := -12 ;
       END IF;
     END IF;
END Month_Range ;

--------------------------------------------------------

PROCEDURE Insert_Insig_Cust(p_select VARCHAR2) IS

 x_s    VARCHAR2(40) ;
 x_s1   VARCHAR2(60) ;

 x_cust_cur curTyp;
 i NUMBER := 1;
 TYPE t_start_date  IS TABLE OF DATE    INDEX BY BINARY_INTEGER ;
 TYPE t_cust_id     IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER ;
 x_start_date         t_start_date ;
 x_cust_id            t_cust_id    ;

 BEGIN

     bic_summary_extract_pkg.debug(' entered Insert_Insig_Cust + : ');
  x_s1 := 'SELECT start_date, customer_id  FROM (' ;
  x_s  := ' < ' || TO_CHAR(g_lc_insig_level) || ' AND value_p2 < '
             || TO_CHAR(g_lc_insig_level) ;

  --insert into am_tmp values('Insig_Cust -' ,x_s1 || p_select || x_s) ;

  --write_log(x_s1||p_select||x_s,'insert_insig');


  OPEN x_cust_cur FOR x_s1 || p_select || x_s  ;
  i:=1;
  LOOP
    FETCH x_cust_cur INTO x_start_date(i), x_cust_id(i) ;
    EXIT WHEN x_cust_cur%NOTFOUND ;
    i:=i+1 ;
  END LOOP ;

  CLOSE x_cust_cur;

  i := 1 ;

  FOR i IN 1..x_cust_id.count LOOP
    Insert_Record (NULL, g_lc_measure_id, x_start_date(i), x_cust_id(i), 6) ;
    ----value = 6 for insignificant customer
  END LOOP ;

     bic_summary_extract_pkg.debug(' exited Insert_Insig_Cust + : ');

  /*
  EXCEPTION
    WHEN OTHERS THEN
	 write_log('Error:' || sqlerrm || 'for party ' || x_cust_id(i), 'bic_lifecycle_extract_pkg.Insert_Insig_Cust');
     */


END Insert_Insig_Cust ;

------------------------------

PROCEDURE Insert_Others(p_select      VARCHAR2) IS
 x_s      VARCHAR2(40) ;
 x_s1     VARCHAR2(80) ;
 x_growth NUMBER ;
 x_lcf    NUMBER ;
 x_value  NUMBER ;
 x_cur    curTyp;

 i NUMBER := 1;
 TYPE t_start_date  IS TABLE OF DATE    INDEX BY BINARY_INTEGER ;
 TYPE t_cust_id     IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER ;
 TYPE t_value_p1    IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER ;
 TYPE t_value_p2    IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER ;

 x_start_date   t_start_date ;
 x_cust_id      t_cust_id    ;
 x_value_p1     t_value_p1 ;
 x_value_p2     t_value_p2 ;
 BEGIN
     bic_summary_extract_pkg.debug(' entered Insert_Others + : ');

  x_s1 := 'SELECT start_date, customer_id, value_p1, value_p2  FROM (' ;
  x_s  := ' > ' || TO_CHAR(g_lc_insig_level) || ' OR value_p2 > '
             || TO_CHAR(g_lc_insig_level) ;
  --insert into am_tmp values('Other_Cust -' ,x_s1 || p_select || x_s) ;

  i:=1;


  --write_log(x_s1||p_select||x_s,'insert_others');

  OPEN x_cur FOR x_s1 || p_select || x_s ;

  LOOP
    FETCH x_cur INTO x_start_date(i), x_cust_id(i), x_value_p1(i), x_value_p2(i) ;
    EXIT WHEN x_cur%NOTFOUND ;

    IF x_value_p2(i) > 0 THEN
      x_growth := (x_value_p1(i) - x_value_p2(i))*100 / x_value_p2(i) ;
      x_lcf    := ABS(x_value_p1(i) - x_value_p2(i)) * x_growth / 100 ;
      --dbms_output.put_line('LCF    :- ' || TO_CHAR(x_lcf)) ;
      --dbms_output.put_line('GROWTH :- ' || TO_CHAR(x_growth)) ;

      IF Find_Stage(g_op_growing1, g_op_growing2, x_growth,
                    x_lcf, g_growing_vlu1, g_growing_vlu2) = 1 THEN
        x_value := 2 ;
      ELSIF Find_Stage(g_op_declining1, g_op_declining2, x_growth,
                    x_lcf, g_declining_vlu1, g_declining_vlu2) = 1 THEN
        x_value := 4 ;
      ELSIF Find_Stage(g_op_defected1, g_op_defected2, x_growth,
                    x_lcf, g_defected_vlu1, g_defected_vlu2) = 1 THEN
        x_value := 5 ;
      ELSE
        x_value := 3 ;
      END IF ;

      Insert_Record (NULL, g_lc_measure_id, x_start_date(i), x_cust_id(i), x_value) ;
    END IF ;
    i:=i+1 ;

  END LOOP ;

     bic_summary_extract_pkg.debug(' exited Insert_Others + : ');

  CLOSE x_cur;

  /*
   EXCEPTION
     WHEN OTHERS THEN
	   write_log('Error:' || sqlerrm || ' for party ' || x_cust_id(i), 'bic_lifecycle_extract_pkg.Insert_Others'); */


END Insert_Others ;


--------------------------------------------------------------
PROCEDURE Insert_Record (p_org_id       NUMBER,
                         p_measure_id   NUMBER,
                         p_start_date   DATE,
                         p_cust_id      NUMBER,
                         p_value        NUMBER) IS
 BEGIN


     INSERT INTO bic_party_summary
            (measure_code,   measure_id,             period_start_date,      VALUE,
             party_id,       last_update_date,       last_updated_by,
             creation_date,  created_by,             last_update_login,
             request_id,     program_application_id, program_id,
             program_update_date)
     VALUES ('LIFE_CYCLE',  p_measure_id,   p_start_date,             p_value,
             p_cust_id,     SYSDATE,        g_last_updated_by,
             SYSDATE,       g_created_by,   g_last_update_login,
             g_request_id,  g_program_application_id,   g_program_id,
             SYSDATE) ;

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        write_log('LifeCycle Step-up resulted: Error inside insert_record :' || SQLERRM || ' for customer ' || p_cust_id ||
        ' period ' || p_start_date, 'bic_lifecycle_extract_pkg.Insert_Record');
  --     NULL;
       -- if setup data is not right and some new customer may fall in
	  -- these categories too.

 --   WHEN OTHERS THEN
	--   write_log('Error:' || sqlerrm, 'bic_lifecycle_extract_pkg.Insert_Record');


END Insert_Record ;

----------------------------------------------------------------------
FUNCTION Find_Stage  (p_op1       VARCHAR2,
                      p_op2       VARCHAR2,
                      p_growth    NUMBER,
                      p_lcf       NUMBER,
                      p_vlu1      NUMBER,
                      p_vlu2      NUMBER) RETURN NUMBER IS
 x_stg1  NUMBER ;
 x_stg2  NUMBER ;

 BEGIN

 x_stg1 := 0 ;
 x_stg2 := 0 ;

  IF p_op1 = '>=' THEN
    IF p_growth >= p_vlu1 THEN
       x_stg1 := 1 ;
    END IF ;
  END IF ;
  IF p_op1 = '<=' THEN
    IF p_growth <= p_vlu1 THEN
       x_stg1 := 1 ;
    END IF ;
  END IF ;

  IF p_op2 = '>=' THEN
    IF p_lcf >= p_vlu2 THEN
       x_stg2 := 1 ;
    END IF ;
  END IF ;
  IF p_op2 = '<=' THEN
    IF p_lcf <= p_vlu2 THEN
       x_stg2 := 1 ;
    END IF ;
  END IF ;

  RETURN x_stg1 * x_stg2 ;

END Find_Stage ;

----------------------------------------------

PROCEDURE Initialize IS

BEGIN


  g_last_updated_by        := fnd_global.user_id        ;
  g_created_by             := fnd_global.user_id        ;
  g_last_update_login      := fnd_global.login_id       ;
  g_request_id             := fnd_global.conc_request_id;
  g_program_application_id := fnd_global.prog_appl_id   ;
  g_program_id             := fnd_global.conc_program_id;
--bic_core_pkg.rp_report_id   := 'BICCSUMM'; 4911126

   SELECT  measure_value1, measure_value2, measure_value1_op, measure_value2_op
   INTO    g_growing_vlu1, g_growing_vlu2, g_op_growing1, g_op_growing2
   FROM    bic_lc_setup_all
   WHERE   stage_code = 'GROWING';



   SELECT  measure_value1, measure_value2, measure_value1_op, measure_value2_op
   INTO    g_defected_vlu1, g_defected_vlu2, g_op_defected1, g_op_defected2
   FROM    bic_lc_setup_all
   WHERE   stage_code = 'DEFECTED';



/*
   dbms_output.put_line('g_defected_vlu1 :- ' || TO_CHAR(g_defected_vlu1)) ;
   dbms_output.put_line('g_defected_vlu2 :- ' || TO_CHAR(g_defected_vlu2)) ;
   dbms_output.put_line('g_op_defected1  :- ' || g_op_defected1) ;
   dbms_output.put_line('g_op_defected2  :- ' || g_op_defected2) ;
*/
   SELECT  measure_value1, measure_value2, measure_value1_op, measure_value2_op
   INTO    g_declining_vlu1, g_declining_vlu2, g_op_declining1, g_op_declining2
   FROM    bic_lc_setup_all
   WHERE   stage_code = 'DECLINING';




   SELECT  lc_comparison_type,    lc_measure_code,
           lc_granularity_level,  lc_starting_period,
           lc_new_cust_period,    lc_insig_level
   INTO     g_lc_comparison_type,  g_measure_for_lc_stage,
            g_lc_granularity_level,g_lc_starting_period,
            g_lc_new_cust_period,  g_lc_insig_level
   FROM   bic_profile_values_all
   WHERE  org_id IS NULL ;



   SELECT measure_id INTO g_lc_measure_id
   FROM   bic_measures_all
   WHERE  measure_code = 'LIFE_CYCLE' AND org_id IS NULL ;



   EXCEPTION
	 WHEN OTHERS THEN
	   write_log('Error:' || SQLERRM, 'bic_lifecycle_extract_pkg.Initialize');
       IF  g_growing_vlu1 IS NULL OR g_growing_vlu2 IS NULL OR
        g_op_growing1 IS NULL OR g_op_growing2 IS NULL THEN
        RAISE NO_LC_SETUP_DATA ;
        END IF;

       IF  g_declining_vlu1 IS NULL OR g_declining_vlu2 IS NULL OR
        g_op_declining1 IS NULL OR g_op_declining2 IS NULL THEN
        RAISE NO_LC_SETUP_DATA ;
        END IF;

        IF  g_defected_vlu1 IS NULL OR g_defected_vlu2 IS NULL OR
        g_op_defected1 IS NULL OR g_op_defected2 IS NULL THEN
        RAISE NO_LC_SETUP_DATA ;
        END IF;

          IF  g_lc_comparison_type IS NULL OR g_measure_for_lc_stage IS NULL OR
        g_lc_granularity_level IS NULL OR g_lc_starting_period IS NULL OR
        g_lc_new_cust_period IS NULL OR  g_lc_insig_level IS NULL THEN
        RAISE NO_LC_PROFILE_DATA ;
        END IF;

          IF  g_lc_measure_id IS NULL THEN
            RAISE  NO_LC_MEASURE_ID;
          END IF;



END Initialize ;


PROCEDURE write_log (p_msg VARCHAR2, p_proc_name VARCHAR2) IS
BEGIN

   FND_FILE.PUT_LINE(fnd_file.log,SUBSTR('Life Cycle Log - ' || p_msg ||
				 ': ' || p_proc_name,1,2500));
   -- bic_core_pkg.debug(p_msg);

END write_log;


END bic_lifecycle_extract_pkg ;

/
