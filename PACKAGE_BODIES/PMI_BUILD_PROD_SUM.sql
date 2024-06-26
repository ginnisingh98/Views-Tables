--------------------------------------------------------
--  DDL for Package Body PMI_BUILD_PROD_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_BUILD_PROD_SUM" AS
/* $Header: PMIPRODB.pls 120.0 2005/05/24 16:57:25 appldev noship $ */

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
   BEGIN
     OPEN check_cldr_for_perd_bal;
     LOOP
       FETCH check_cldr_for_perd_bal INTO cldr_rec;
       EXIT WHEN check_cldr_for_perd_bal%NOTFOUND;
       /* Delete data for the current processing period from summary table and insert summary data
          into summary table using transaction tables.
       */
              DELETE  PMI_PROD_SUM
              WHERE co_Code         = cldr_rec.co_code
                AND period_set_name = cldr_rec.period_Set_name
                AND period_name     = cldr_rec.period_name;


         INSERT INTO PMI_PROD_SUM(FISCAL_YEAR
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
                                 ,WHSE_USAGE_QTY
                                 ,WHSE_USAGE_CONV
                                 ,WHSE_USAGE_VALUE
                                 ,WHSE_YIELD_QTY
                                 ,WHSE_YIELD_CONV
                                 ,WHSE_YIELD_VALUE
                                 ,LOG_END_DATE
                                 ,PERIOD_IND
                                 ,WHSE_NAME
                                 ,ORGN_NAME
                                 ,PERIOD_NAME
                                 ,QUARTER_NAME
                                 ,PERIOD_SET_NAME
                                 ,GL_PERIOD_YEAR
                                 ,GL_FISCAL_YEAR_NAME
                                 ,GL_PERIOD_START_DATE
                                 ,GL_PERIOD_END_DATE
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
                              ,prod_tr.usage_qty   WHSE_USAGE_QTY
                              ,decode(PV_conv_uom,iim.item_um,prod_tr.usage_qty   ,
                                  gmicuom.i2uom_cv(iim.item_id,0,iim.item_um,prod_tr.usage_qty ,PV_conv_uom))  WHSE_USAGE_CONV
                              ,prod_tr.usage_qty *
                                 pmi_common_pkg.PMICO_GET_COST(iim.item_id,whs.whse_code,null,cldr_rec.period_start_date) WHSE_USAGE_VALUE
                              ,prod_tr.yield_qty WHSE_YIELD_QTY
                              ,decode(PV_conv_uom,iim.item_um,prod_tr.yield_qty   ,
                                  gmicuom.i2uom_cv(iim.item_id,0,iim.item_um,prod_tr.yield_qty ,PV_conv_uom))  WHSE_YIELD_CONV
                              ,prod_tr.yield_qty *
                                   pmi_common_pkg.PMICO_GET_COST(iim.item_id,whs.whse_code,null,cldr_rec.period_start_date) WHSE_YIELD_VALUE
                              ,p_log_end_date LOG_END_DATE
                              ,0 PERIOD_IND
                              ,whs.WHSE_NAME
                              ,org.ORGN_NAME
                              ,cldr_rec.period_name PERIOD_NAME
                              ,cldr_rec.quarter_name QUARTER_NAME
                              ,cldr_rec.period_set_name PERIOD_SET_NAME
                              ,cldr_rec.period_year GL_PERIOD_YEAR
                              ,cldr_rec.year_name GL_FISCAL_YEAR_NAME
                              ,cldr_rec.period_start_date GL_PERIOD_START_DATE
                              ,cldr_rec.period_end_date GL_PERIOD_END_DATE
                              ,0 MISS_CONV_FACT_CNT
                        FROM (SELECT orgn_code,whse_code,item_id,sum(yield_qty) yield_qty,sum(usage_qty) usage_qty
                                    FROM (SELECT ORGN_CODE,WHSE_CODE,ITEM_ID,decode(line_type,1,trans_qty,0) yield_qty,
                                          DECODE(line_type,-1,trans_qty,0) usage_qty
                                          FROM IC_TRAN_PND
                                          WHERE trunc(trans_date) between cldr_rec.period_start_date AND
                                                                      cldr_rec.period_end_date
                                            AND doc_type ='PROD'
                                            AND completed_ind = 1 and delete_mark = 0
                                         UNION ALL
                                          SELECT ORGN_CODE,WHSE_CODE,ITEM_ID,decode(line_type,1,trans_qty,0) yield_qty,
                                                  DECODE(line_type,-1,trans_qty,0) usage_qty                                          FROM IC_TRAN_CMP
                                          WHERE trunc(trans_date) between cldr_rec.period_start_date AND
                                                                      cldr_rec.period_end_date
                                            AND doc_type = 'PROD')
                                 group by orgn_code,whse_code,item_id) prod_tr,
                             IC_WHSE_MST whs,
                             SY_ORGN_MST org,
                             IC_ITEM_MST iim
                        WHERE org.co_code  = cldr_rec.co_code
                          AND prod_tr.item_id = iim.item_id
                          AND prod_tr.whse_code = whs.whse_code
                          AND prod_tr.orgn_code  = org.orgn_code   );

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
    CURSOR cur_bisopm_prod IS
      SELECT LAST_RUN_DATE,ATTR1
      FROM PMI_SUMMARY_LOG_TABLE
      WHERE summary_table = 'PMI_PROD_SUM';
    CURSOR cur_last_trans_eff_date IS
      SELECT min(trans_date)
      from (Select (min(trans_date)) trans_date
            from IC_TRAN_PND
            WHERE doc_type = 'PROD' AND (l_last_run_date IS NULL OR
                  (l_last_run_date IS NOT NULL AND last_update_date >= l_last_run_date))
            UNION ALL
            (Select (min(trans_date)) trans_date
            from IC_TRAN_CMP
            WHERE DOC_TYPE = 'PROD' AND (l_last_run_date IS NULL OR
                  (l_last_run_date IS NOT NULL AND last_update_date >= l_last_run_date))));
    rows_exists number := null;
  BEGIN
    /* Checking Existancy of data in BIS Summary Table and get the populated UOM and last rundate */
    OPEN cur_bisopm_prod;
    FETCH cur_bisopm_prod INTO l_last_run_date,l_conv_uom;
    IF cur_bisopm_prod%NOTFOUND THEN
      CLOSE cur_bisopm_prod;
      BEGIN
        SELECT 1 into rows_exists
        FROM PMI_PROD_SUM
        WHERE ROWNUM = 1;
        errbuf := FND_MESSAGE.get_string('PMI','PMI_SUMM_POPULATION_ERR');
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf );
        retcode:= '2';
        APP_EXCEPTION.Raise_exception;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;
    ELSE
        CLOSE cur_bisopm_prod;
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
        DELETE pmi_prod_sum;
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
        WHERE summary_table = 'PMI_PROD_SUM';
        IF SQL%ROWCOUNT = 0 THEN
          INSERT INTO PMI_SUMMARY_LOG_TABLE (SUMMARY_TABLE,LAST_RUN_DATE,ATTR1,ATTR2,ATTR3,ATTR4,ATTR5,ATTR6)
                 VALUES ('PMI_PROD_SUM',l_log_end_date,PV_conv_uom,null,null,null,null,null);
        END IF;
      END;

        SELECT TABLE_OWNER INTO l_table_owner
        FROM USER_SYNONYMS
        WHERE SYNONYM_NAME = 'PMI_PROD_SUM';
        FND_STATS.GATHER_TABLE_STATS(l_table_owner, 'PMI_PROD_SUM');


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
END PMI_BUILD_PROD_SUM;

/
