--------------------------------------------------------
--  DDL for Package Body PMI_BUILD_ONHANDSALE_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_BUILD_ONHANDSALE_SUM" AS
--  $Header: PMIOHDSB.pls 115.35 2002/12/05 17:06:21 skarimis ship $

  PROCEDURE populate_summary(p_last_run_date date,p_log_end_date date) IS
  -- Cursor Declarations
    CURSOR check_cldr_for_perd_bal IS
      select gpm.co_code co_code,
        c.period_start_date period_start_date,
        c.period_end_date period_end_date,
        c.period_num period_num,
        c.quarter_num quarter_num,
        c.period_year period_year,
        c.period_name period_name,
        c.quarter_name quarter_name,
        c.year_name year_name  ,
        c.period_set_name period_set_name,
        d.last_start_date last_start_date,
        d.last_end_date last_end_date
      FROM
        (  select a.set_of_books_name  set_of_books_name ,
            a.period_num period_num,
            a.period_start_date cur_start_date,
            a.period_end_Date cur_end_Date,
            b.period_start_date last_start_date,
            b.period_end_Date last_end_date
          from PMI_GL_TIME_V a,PMI_GL_TIME_V b
          where a.set_of_books_name = b.set_of_books_name and
            sysdate between a.period_start_date and a.period_end_Date AND
            p_last_run_date  between b.period_start_date and b.period_end_Date
             ) d,
       PMI_GL_TIME_V c,
       GL_PLCY_MST gpm
     where c.set_of_books_name = d.set_of_books_name
       and gpm.set_of_books_name  = c.set_of_books_name
       and  c.period_start_date >= d.last_start_date
       and  c.period_start_date <= sysdate
     order by gpm.co_code,c.period_start_date desc;
   -- Row Type Variables
     cldr_rec check_cldr_for_perd_bal%ROWTYPE;
   -- Local Variables
     l_prev_co_code  sy_orgn_mst.co_code%TYPE;
   BEGIN
     OPEN check_cldr_for_perd_bal;
     LOOP
       FETCH check_cldr_for_perd_bal INTO cldr_rec;
       EXIT WHEN check_cldr_for_perd_bal%NOTFOUND;
       /* Insert new period marker rows using ic_loct_inv for the current period and
          create previous period rows using current period rows
          E.g.
             we need to populate data for period 1 to period 3.
             current period : 3
               populate period 3 rows using IC_LOCT_INV and Transaction tables (IC_TRAN_PND and IC_TRAN_CMP) this is
               required because user might have run the purge 0 -zero balance rows
             For period 2 use period 3 rows and Trnasaction tables
             For period 1 use period 2 rows and Trnasaction tables
       */
       DELETE  PMI_ONHAND_SALE_SUM_TEMP;

       IF l_prev_co_code IS NULL OR l_prev_co_code <> cldr_rec.co_code  THEN
         INSERT INTO PMI_ONHAND_SALE_SUM_TEMP(FISCAL_YEAR
                                          ,CO_CODE
                                          ,ORGN_CODE
                                          ,WHSE_CODE
                                          ,PERIOD_ID
                                          ,QUARTER
                                          ,PERIOD
                                          ,CONVERTIBLE_UOM
                                          ,ITEM_ID
                                          ,ITEM_NO
                                          ,ITEM_UM
                                          ,WHSE_ONHAND_QTY
                                          ,WHSE_ONHAND_CONV
                                          ,WHSE_ONHAND_VALUE
                                          ,WHSE_SALE_QTY
                                          ,WHSE_SALE_CONV
                                          ,WHSE_SALE_VALUE
                                          ,WHSE_RTRN_QTY
                                          ,WHSE_RTRN_CONV
                                          ,WHSE_RTRN_VALUE
                                          ,LOG_END_DATE
                                          ,PERIOD_IND
                                          ,WHSE_NAME
                                          ,ORGN_NAME
                                          ,PERIOD_NAME
                                          ,QUARTER_NAME
                                          ,PERIOD_SET_NAME
                                          ,GL_PERIOD_YEAR
                                          ,GL_FISCAL_YEAR_NAME
                                          ,GL_PERIOD_END_DATE
                                          ,GL_PERIOD_START_DATE
                                          ,MISS_CONV_FACT_CNT)
                            (SELECT cldr_rec.period_year FISCAL_YEAR
                                          ,cldr_rec.co_code CO_CODE
                                          ,org.ORGN_CODE
                                          ,whs.WHSE_CODE
                                          ,cldr_rec.period_num PERIOD_ID
                                          ,cldr_rec.quarter_num QUARTER
                                          ,cldr_rec.period_num PERIOD
                                          ,PV_conv_uom CONVERTIBLE_UOM
                                          ,iim.ITEM_ID
                                          ,iim.ITEM_NO
                                          ,iim.ITEM_UM
                                          ,loct.LOCT_ONHAND    WHSE_ONHAND_QTY
                                          ,0 WHSE_ONHAND_CONV
                                          ,0 WHSE_ONHAND_VALUE
                                          ,0 WHSE_SALE_QTY
                                          ,0 WHSE_SALE_CONV
                                          ,0 WHSE_SALE_VALUE
                                          ,0 WHSE_RTRN_QTY
                                          ,0 WHSE_RTRN_CONV
                                          ,0 WHSE_RTRN_VALUE
                                          ,p_log_end_date LOG_END_DATE
                                          ,0 PERIOD_IND
                                          ,whs.WHSE_NAME
                                          ,org.ORGN_NAME
                                          ,cldr_rec.period_name PERIOD_NAME
                                          ,cldr_rec.quarter_name QUARTER_NAME
                                          ,cldr_rec.period_set_name PERIOD_SET_NAME
                                          ,cldr_rec.period_year GL_PERIOD_YEAR
                                          ,cldr_rec.year_name GL_FISCAL_YEAR_NAME
                                          ,cldr_rec.period_end_date GL_PERIOD_END_DATE
                                          ,cldr_rec.period_start_date GL_PERIOD_START_DATE
                                          ,0 MISS_CONV_FACT_CNT
                        FROM (SELECT whse_code,item_id,sum(LOCT_ONHAND) loct_onhand
                              from IC_LOCT_INV
                              group by whse_code,item_id) loct,
                             IC_WHSE_MST whs,
                             SY_ORGN_MST org,
                             IC_ITEM_MST iim
                        WHERE org.co_code  = cldr_rec.co_code
                          AND loct.item_id = iim.item_id
                          AND loct.whse_code = whs.whse_code
                          AND whs.orgn_code  = org.orgn_code   );
             l_prev_co_code := cldr_rec.co_code;
       ELSE
         INSERT INTO PMI_ONHAND_SALE_SUM_TEMP(FISCAL_YEAR
                                          ,CO_CODE
                                          ,ORGN_CODE
                                          ,WHSE_CODE
                                          ,PERIOD_ID
                                          ,QUARTER
                                          ,PERIOD
                                          ,CONVERTIBLE_UOM
                                          ,ITEM_ID
                                          ,ITEM_NO
                                          ,ITEM_UM
                                          ,WHSE_ONHAND_QTY
                                          ,WHSE_ONHAND_CONV
                                          ,WHSE_ONHAND_VALUE
                                          ,WHSE_SALE_QTY
                                          ,WHSE_SALE_CONV
                                          ,WHSE_SALE_VALUE
                                          ,WHSE_RTRN_QTY
                                          ,WHSE_RTRN_CONV
                                          ,WHSE_RTRN_VALUE
                                          ,LOG_END_DATE
                                          ,PERIOD_IND
                                          ,WHSE_NAME
                                          ,ORGN_NAME
                                          ,PERIOD_NAME
                                          ,QUARTER_NAME
                                          ,PERIOD_SET_NAME
                                          ,GL_PERIOD_YEAR
                                          ,GL_FISCAL_YEAR_NAME
                                          ,GL_PERIOD_END_DATE
                                          ,GL_PERIOD_START_DATE
                                          ,MISS_CONV_FACT_CNT)
                                   SELECT cldr_rec.period_year FISCAL_YEAR
                                          ,cldr_rec.co_code CO_CODE
                                          ,next_prd.ORGN_CODE
                                          ,next_prd.WHSE_CODE
                                          ,cldr_rec.period_num PERIOD_ID
                                          ,cldr_rec.quarter_num QUARTER
                                          ,cldr_rec.period_num PERIOD
                                          ,next_prd.CONVERTIBLE_UOM
                                          ,next_prd.ITEM_ID
                                          ,next_prd.ITEM_NO
                                          ,next_prd.ITEM_UM
                                          ,nvl(next_prd.WHSE_ONHAND_QTY,0) - nvl(prd_tr_sum.perd_trans_qty,0)
                                          ,0 WHSE_ONHAND_CONV
                                          ,0 WHSE_ONHAND_VALUE
                                          ,0 WHSE_SALE_QTY
                                          ,0 WHSE_SALE_CONV
                                          ,0 WHSE_SALE_VALUE
                                          ,0 WHSE_RTRN_QTY
                                          ,0 WHSE_RTRN_CONV
                                          ,0 WHSE_RTRN_VALUE
                                          ,p_log_end_date LOG_END_DATE
                                          ,0 PERIOD_IND
                                          ,next_prd.WHSE_NAME
                                          ,next_prd.ORGN_NAME
                                          ,cldr_rec.period_name PERIOD_NAME
                                          ,cldr_rec.quarter_name QUARTER_NAME
                                          ,cldr_rec.period_set_name PERIOD_SET_NAME
                                          ,cldr_rec.period_year GL_PERIOD_YEAR
                                          ,cldr_rec.year_name GL_FISCAL_YEAR_NAME
                                          ,cldr_rec.period_end_date GL_PERIOD_END_DATE
                                          ,cldr_rec.period_start_date GL_PERIOD_START_DATE
                                          ,0 MISS_CONV_FACT_CNT
                      FROM PMI_ONHAND_SALE_SUM_CUR_TEMP next_prd,
                           PMI_PERD_TRANS_SUM_TEMP prd_tr_sum
                      WHERE next_prd.whse_code = prd_tr_sum.whse_code (+)
                        AND next_prd.item_id   = prd_tr_sum.item_id (+);
       END IF;

       /* Summarize Transactions at period level this table is used for
          populating sales data for current period and to calculate period end balance
          for the previous period. */

       delete PMI_PERD_TRANS_SUM_TEMP ;

       INSERT INTO PMI_PERD_TRANS_SUM_TEMP (WHSE_CODE,
                                     ITEM_ID,
                                     PERD_TRANS_QTY,
                                     PERD_SALES_QTY)
                                 (
                                    SELECT whse_code,item_id,sum(trans_qty),sum(sales_qty)
                                    FROM (SELECT WHSE_CODE,ITEM_ID,TRANS_QTY,
                                          DECODE(DOC_TYPE,'OPSO',trans_qty,'OMSO',trans_qty,0) sales_qty
                                          FROM IC_TRAN_PND
                                          WHERE trunc(trans_date) between cldr_rec.period_start_date AND
                                                                      cldr_rec.period_end_date
                                            AND doc_type NOT IN ('STSI', 'GRDI','STSR', 'GRDR')
                                            AND completed_ind = 1 and delete_mark = 0
                                         UNION ALL
                                          SELECT WHSE_CODE,ITEM_ID,TRANS_QTY,
                                          DECODE(DOC_TYPE,'OPSO',trans_qty,'OMSO',trans_qty,0) sales_qty
                                          FROM IC_TRAN_CMP
                                          WHERE trunc(trans_date) between cldr_rec.period_start_date AND
                                                                      cldr_rec.period_end_date
                                            AND doc_type NOT IN ('STSI', 'GRDI','STSR', 'GRDR'))
                                     group by whse_code,item_id);

/*
      Following statement inserts 0-Zero balance rows if purge 0-zero
      balance rows routine purges 0 balance rows from ic_LOCT_INV   */


       INSERT INTO PMI_ONHAND_SALE_SUM_TEMP(FISCAL_YEAR
                                          ,CO_CODE
                                          ,ORGN_CODE
                                          ,WHSE_CODE
                                          ,PERIOD_ID
                                          ,QUARTER
                                          ,PERIOD
                                          ,CONVERTIBLE_UOM
                                          ,ITEM_ID
                                          ,ITEM_NO
                                          ,ITEM_UM
                                          ,WHSE_ONHAND_QTY
                                          ,WHSE_ONHAND_CONV
                                          ,WHSE_ONHAND_VALUE
                                          ,WHSE_SALE_QTY
                                          ,WHSE_SALE_CONV
                                          ,WHSE_SALE_VALUE
                                          ,WHSE_RTRN_QTY
                                          ,WHSE_RTRN_CONV
                                          ,WHSE_RTRN_VALUE
                                          ,LOG_END_DATE
                                          ,PERIOD_IND
                                          ,WHSE_NAME
                                          ,ORGN_NAME
                                          ,PERIOD_NAME
                                          ,QUARTER_NAME
                                          ,PERIOD_SET_NAME
                                          ,GL_PERIOD_YEAR
                                          ,GL_FISCAL_YEAR_NAME
                                          ,GL_PERIOD_END_DATE
                                          ,GL_PERIOD_START_DATE
                                          ,MISS_CONV_FACT_CNT)
                            (SELECT cldr_rec.period_year FISCAL_YEAR
                                          ,cldr_rec.co_code CO_CODE
                                          ,org.ORGN_CODE
                                          ,whs.WHSE_CODE
                                          ,cldr_rec.period_num PERIOD_ID
                                          ,cldr_rec.quarter_num QUARTER
                                          ,cldr_rec.period_num PERIOD
                                          ,PV_conv_uom CONVERTIBLE_UOM
                                          ,iim.ITEM_ID
                                          ,iim.ITEM_NO
                                          ,iim.ITEM_UM
                                          ,0 WHSE_ONHAND_QTY
                                          ,0 WHSE_ONHAND_CONV
                                          ,0 WHSE_ONHAND_VALUE
                                          ,0 WHSE_SALE_QTY
                                          ,0 WHSE_SALE_CONV
                                          ,0 WHSE_SALE_VALUE
                                          ,0 WHSE_RTRN_QTY
                                          ,0 WHSE_RTRN_CONV
                                          ,0 WHSE_RTRN_VALUE
                                          ,null LOG_END_DATE
                                          ,0 PERIOD_IND
                                          ,whs.WHSE_NAME
                                          ,org.ORGN_NAME
                                          ,cldr_rec.period_name PERIOD_NAME
                                          ,cldr_rec.quarter_name QUARTER_NAME
                                          ,cldr_rec.period_set_name PERIOD_SET_NAME
                                          ,cldr_rec.period_year GL_PERIOD_YEAR
                                          ,cldr_rec.year_name GL_FISCAL_YEAR_NAME
                                          ,cldr_rec.period_end_date GL_PERIOD_END_DATE
                                          ,cldr_rec.period_start_date GL_PERIOD_START_DATE
                                          ,0 MISS_CONV_FACT_CNT
                        FROM (SELECT whse_code,item_id
                              FROM PMI_PERD_TRANS_SUM_TEMP
                              MINUS
                              SELECT WHSE_CODE,ITEM_ID
                              FROM PMI_ONHAND_SALE_SUM_TEMP)  prd_sum,
                             IC_WHSE_MST whs,
                             SY_ORGN_MST org,
                             IC_ITEM_MST iim
                        WHERE co_code  = cldr_rec.co_code
                          AND prd_sum.item_id = iim.item_id
                          AND prd_sum.whse_code = whs.whse_code
                          AND whs.orgn_code  = org.orgn_code   );

       delete PMI_ONHAND_SALE_SUM_CUR_TEMP ;

       INSERT INTO PMI_ONHAND_SALE_SUM_CUR_TEMP(FISCAL_YEAR
                                          ,CO_CODE
                                          ,ORGN_CODE
                                          ,WHSE_CODE
                                          ,PERIOD_ID
                                          ,QUARTER
                                          ,PERIOD
                                          ,CONVERTIBLE_UOM
                                          ,ITEM_ID
                                          ,ITEM_NO
                                          ,ITEM_UM
                                          ,WHSE_ONHAND_QTY
                                          ,WHSE_ONHAND_CONV
                                          ,WHSE_ONHAND_VALUE
                                          ,WHSE_SALE_QTY
                                          ,WHSE_SALE_CONV
                                          ,WHSE_SALE_VALUE
                                          ,WHSE_RTRN_QTY
                                          ,WHSE_RTRN_CONV
                                          ,WHSE_RTRN_VALUE
                                          ,LOG_END_DATE
                                          ,PERIOD_IND
                                          ,WHSE_NAME
                                          ,ORGN_NAME
                                          ,PERIOD_NAME
                                          ,QUARTER_NAME
                                          ,PERIOD_SET_NAME
                                          ,GL_PERIOD_YEAR
                                          ,GL_FISCAL_YEAR_NAME
                                          ,GL_PERIOD_END_DATE
                                          ,GL_PERIOD_START_DATE
                                          ,MISS_CONV_FACT_CNT)
                                   SELECT psum_tmp.FISCAL_YEAR
                                          ,psum_tmp.CO_CODE
                                          ,psum_tmp.ORGN_CODE
                                          ,psum_tmp.WHSE_CODE
                                          ,psum_tmp.PERIOD_ID
                                          ,psum_tmp.QUARTER
                                          ,psum_tmp.PERIOD
                                          ,psum_tmp.CONVERTIBLE_UOM
                                          ,psum_tmp.ITEM_ID
                                          ,psum_tmp.ITEM_NO
                                          ,psum_tmp.ITEM_UM
                                          ,psum_tmp.WHSE_ONHAND_QTY
                                          ,psum_tmp.WHSE_ONHAND_CONV
                                          ,psum_tmp.WHSE_ONHAND_VALUE
                                          ,prd_tr_sum.PERD_SALES_QTY  WHSE_SALE_QTY
                                          ,psum_tmp.WHSE_SALE_CONV
                                          ,psum_tmp.WHSE_SALE_VALUE
                                          ,psum_tmp.WHSE_RTRN_QTY
                                          ,psum_tmp.WHSE_RTRN_CONV
                                          ,psum_tmp.WHSE_RTRN_VALUE
                                          ,psum_tmp.LOG_END_DATE
                                          ,psum_tmp.PERIOD_IND
                                          ,psum_tmp.WHSE_NAME
                                          ,psum_tmp.ORGN_NAME
                                          ,psum_tmp.PERIOD_NAME
                                          ,psum_tmp.QUARTER_NAME
                                          ,psum_tmp.PERIOD_SET_NAME
                                          ,psum_tmp.GL_PERIOD_YEAR
                                          ,psum_tmp.GL_FISCAL_YEAR_NAME
                                          ,psum_tmp.GL_PERIOD_END_DATE
                                          ,psum_tmp.GL_PERIOD_START_DATE
                                          ,psum_tmp.MISS_CONV_FACT_CNT
                      FROM PMI_ONHAND_SALE_SUM_TEMP psum_tmp,
                           PMI_PERD_TRANS_SUM_TEMP prd_tr_sum
                      WHERE psum_tmp.whse_code = prd_tr_sum.whse_code (+)
                        AND psum_tmp.item_id   = prd_tr_sum.item_id (+);


/*  Delete data from Summary table for currently processed data
    we will replace this rows using next insert statement */

              DELETE  PMI_ONHAND_SALE_SUM
              WHERE co_Code         = cldr_rec.co_code
                AND period_set_name = cldr_rec.period_Set_name
                AND period_name     = cldr_rec.period_name;


       INSERT INTO PMI_ONHAND_SALE_SUM(FISCAL_YEAR
                                       ,CO_CODE
                                       ,ORGN_CODE
                                       ,WHSE_CODE
                                       ,PERIOD_ID
                                       ,QUARTER
                                       ,PERIOD
                                       ,CONVERTIBLE_UOM
                                       ,ITEM_ID
                                       ,ITEM_NO
                                       ,ITEM_UM
                                       ,WHSE_ONHAND_QTY
                                       ,WHSE_ONHAND_CONV
                                       ,WHSE_ONHAND_VALUE
                                       ,WHSE_SALE_QTY
                                       ,WHSE_SALE_CONV
                                       ,WHSE_SALE_VALUE
                                       ,WHSE_RTRN_QTY
                                       ,WHSE_RTRN_CONV
                                       ,WHSE_RTRN_VALUE
                                       ,LOG_END_DATE
                                       ,PERIOD_IND
                                       ,WHSE_NAME
                                       ,ORGN_NAME
                                       ,PERIOD_NAME
                                       ,QUARTER_NAME
                                       ,PERIOD_SET_NAME
                                       ,GL_PERIOD_YEAR
                                       ,GL_FISCAL_YEAR_NAME
                                       ,GL_PERIOD_END_DATE
                                       ,GL_PERIOD_START_DATE
                                       ,MISS_CONV_FACT_CNT)
                         SELECT FISCAL_YEAR
                               ,CO_CODE
                               ,ORGN_CODE
                               ,WHSE_CODE
                               ,PERIOD_ID
                               ,QUARTER
                               ,PERIOD
                               ,CONVERTIBLE_UOM
                               ,ITEM_ID
                               ,ITEM_NO
                               ,ITEM_UM
                               ,WHSE_ONHAND_QTY
                               ,decode(PV_conv_uom,item_um,WHSE_ONHAND_QTY,
                                  gmicuom.i2uom_cv(item_id,0,item_um,WHSE_ONHAND_QTY,PV_conv_uom)) WHSE_ONHAND_CONV
                               ,WHSE_ONHAND_QTY *
                                  pmi_common_pkg.PMICO_GET_COST(item_id,whse_code,null,GL_PERIOD_START_DATE) WHSE_ONHAND_VALUE
                               ,WHSE_SALE_QTY
                               ,decode(PV_conv_uom,item_um,WHSE_SALE_QTY,
                                  gmicuom.i2uom_cv(item_id,0,item_um,WHSE_SALE_QTY,PV_conv_uom)) WHSE_SALE_CONV
                               ,WHSE_SALE_QTY *
                                  pmi_common_pkg.PMICO_GET_COST(item_id,whse_code,null,GL_PERIOD_START_DATE) WHSE_SALE_VALUE
                               ,WHSE_RTRN_QTY
                               ,WHSE_RTRN_CONV
                               ,WHSE_RTRN_VALUE
                               ,LOG_END_DATE
                               ,PERIOD_IND
                               ,WHSE_NAME
                               ,ORGN_NAME
                               ,PERIOD_NAME
                               ,QUARTER_NAME
                               ,PERIOD_SET_NAME
                               ,GL_PERIOD_YEAR
                               ,GL_FISCAL_YEAR_NAME
                               ,GL_PERIOD_END_DATE
                               ,GL_PERIOD_START_DATE
                               ,MISS_CONV_FACT_CNT
                      FROM PMI_ONHAND_SALE_SUM_CUR_TEMP;
       commit;
     END LOOP;
     CLOSE check_cldr_for_perd_bal;
   END populate_summary;

  PROCEDURE BUILD_SUMMARY(errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2) IS
    -- Local Variables
    e_buff                  VARCHAR2(2000);
    l_last_run_date         DATE;
    l_log_end_date          DATE := trunc(SYSDATE);
    l_last_trns_eff_date    DATE;
    l_start_population_date DATE;
    buff32k                 VARCHAR2(32767);
    l_mesg                  VARCHAR2(2000);
    l_conv_uom              pmi_onhand_sale_sum.convertible_uom%TYPE;
    l_conv_uom1             pmi_onhand_sale_sum.convertible_uom%TYPE;
    l_table_owner           VARCHAR2(40);
    -- Cursors and cursor row type variables
    CURSOR cur_bisopm_onhand IS
      SELECT LAST_RUN_DATE,ATTR1
      FROM PMI_SUMMARY_LOG_TABLE
      WHERE summary_table = 'PMI_ONHAND_SALE_SUM';
    CURSOR cur_last_trans_eff_date IS
      SELECT min(trans_date)
      from (Select (min(trans_date)) trans_date
            from IC_TRAN_PND
            WHERE (l_last_run_date IS NULL OR
                  (l_last_run_date IS NOT NULL AND last_update_date >= l_last_run_date))
            UNION ALL
            (Select (min(trans_date)) trans_date
            from IC_TRAN_CMP
            WHERE (l_last_run_date IS NULL OR
                  (l_last_run_date IS NOT NULL AND last_update_date >= l_last_run_date))));
    rows_exists number := null;
  BEGIN
    /* Checking Existancy of data in BIS Summary Table and get the populated UOM and last rundate */
    OPEN cur_bisopm_onhand;
    FETCH cur_bisopm_onhand INTO l_last_run_date,l_conv_uom;
    IF cur_bisopm_onhand%NOTFOUND THEN
      CLOSE cur_bisopm_onhand;
      BEGIN
        SELECT 1 into rows_exists
        FROM PMI_ONHAND_SALE_SUM
        WHERE ROWNUM = 1;
        errbuf := FND_MESSAGE.get_string('PMI','PMI_SUMM_POPULATION_ERR');
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf );
        retcode:= '2';
        APP_EXCEPTION.Raise_exception;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    ELSE
        CLOSE cur_bisopm_onhand;
    END IF;

    /* Check for Conversion UOM is defined or not  */
    IF fnd_profile.defined('PMI$CONV_UOM') THEN
      l_conv_uom1 := fnd_profile.value('PMI$CONV_UOM');
      IF l_conv_uom1 IS NULL THEN
        errbuf := FND_MESSAGE.get_string('PMI','PMI_SET_CONV_UOM');
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf );
        retcode:= '2';
        APP_EXCEPTION.Raise_exception;
      END IF;
      PV_conv_uom := l_conv_uom1;
      IF ((l_last_run_date IS NOT NULL)  AND
         (l_conv_uom1 <> l_conv_uom)) THEN
        /* Delete data from summary table. now we need to populate using new conversion UOM */
        buff32k := FND_MESSAGE.get_number('PMI','PMI_CONV_UOM_VAL_CHG') ||'-'||
                   FND_MESSAGE.get_string('PMI','PMI_CONV_UOM_VAL_CHG');
        FND_FILE.PUT_LINE(FND_FILE.LOG, buff32k );
        DELETE pmi_onhand_sale_sum;
        COMMIT;
        l_last_run_date := NULL;
      END IF;
      OPEN cur_last_trans_eff_date;
      FETCH cur_last_trans_eff_date INTO l_last_trns_eff_date;
      CLOSE cur_last_trans_eff_date;
      l_start_population_date := least(nvl(trunc(l_last_run_date),trunc(SYSDATE)),trunc(l_last_trns_eff_date));
      populate_summary(l_start_population_date,l_log_end_date);
      BEGIN
        UPDATE PMI_SUMMARY_LOG_TABLE
        SET LAST_RUN_DATE  = l_log_end_date,
            ATTR1          = PV_conv_uom
        WHERE summary_table = 'PMI_ONHAND_SALE_SUM';
        IF SQL%ROWCOUNT = 0 THEN
          INSERT INTO PMI_SUMMARY_LOG_TABLE (SUMMARY_TABLE,LAST_RUN_DATE,ATTR1,ATTR2,ATTR3,ATTR4,ATTR5,ATTR6)
                 VALUES ('PMI_ONHAND_SALE_SUM',l_log_end_date,PV_conv_uom,null,null,null,null,null);
        END IF;
      END;
        SELECT TABLE_OWNER INTO l_table_owner
        FROM USER_SYNONYMS
        WHERE SYNONYM_NAME = 'PMI_ONHAND_SALE_SUM';
        FND_STATS.GATHER_TABLE_STATS(l_table_owner, 'PMI_ONHAND_SALE_SUM');
    ELSE
      buff32k := FND_MESSAGE.get_number('PMI','PMI_CONV_UOM_PROF_MISS') ||'-'||
                 FND_MESSAGE.get_string('PMI','PMI_CONV_UOM_PROF_MISS');
      FND_FILE.PUT_LINE(FND_FILE.LOG, buff32k );
      retcode:= '2';
      APP_EXCEPTION.Raise_exception;
    END IF;
  EXCEPTION
    WHEN FND_FILE.UTL_FILE_ERROR then
    errbuf  := substr(fnd_message.get, 1, 254);
    retcode := 2;
  END  BUILD_SUMMARY;
END PMI_BUILD_ONHANDSALE_SUM;

/
