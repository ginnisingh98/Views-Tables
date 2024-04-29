--------------------------------------------------------
--  DDL for Package Body PN_SOI_VOL_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_SOI_VOL_IMPORT" AS
/* $Header: PNSOIMPB.pls 120.12 2007/05/04 10:48:21 sraaj ship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : IMPORT_VOL_HIST
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 14-JUL-05  Hrodda o Bug 4284035 - Replaced pn_var_rents,pn_leases with _ALL
-- 25-NOV-05  pikhar o in cursor c_var_rent replaced var_rent_id with
--                     rents.var_rent_id in where clause
-- 22-MAR-06  Hareesha  o Bug 4731212 Modified import_vol_hist  to get
--                        reporttype and insert into pn_var_vol_hist_all
-- 15-JAN-07  Prabhakar o Modified the import_vol_hist procedure to update the
--                        records in the pn_var_vol_hist_all and pn_var_deductions_all.
--                        Before updating, the old records will be inserted into
--                        pn_var_vol_arch_all and pn_var_deduct_arch_all.
-- 12-mar-07  Shabda    o After we have updated volume history. We set the
--                        pn_var_lines_all.sales-Vol_update_flag to Y for
--                        all lines which might have been updated. Bug 5915771
-------------------------------------------------------------------------------

 --g_org_id  NUMBER;

 TYPE NUM_T IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

 PROCEDURE import_vol_hist(
                        errbuf       OUT NOCOPY        VARCHAR2,
                        retcode      OUT NOCOPY        VARCHAR2,
                        p_batch_id   IN                NUMBER
                          ) IS
CURSOR c_batch_line IS
       SELECT line.rowid,
              line.batch_id,
              line.var_rent_id,
              line.line_item_id,
              line.rep_str_DATE,
              line.rep_end_DATE,
              line.amount,
              line.status,
              line.deduction_type_code,
              batch.Volume_type,
              line.report_type_code,
              line.vol_hist_status_code,
              line.reporting_date,
	      line.certified_by,
              line.vol_deduct_id
        FROM pn_vol_hist_batch_itf batch,
             pn_vol_hist_lines_itf line
        WHERE batch.batch_id = line.batch_id
              AND batch.batch_id = p_batch_id
              AND batch.status <>'I'
              AND line.status <> 'I'
              AND line.amount is not null;

CURSOR c_var_rent(p_rent_id NUMBER) IS
        SELECT rents.var_rent_id,
               rents.rent_num,
               lease.name,
               rents.org_id
        FROM pn_var_rents_all rents,
             pn_leases_all lease
        WHERE  rents.var_rent_id = p_rent_id
            AND rents.lease_id = lease.lease_id;

CURSOR c_line_item(p_line_item_id NUMBER) IS
        SELECT lines.line_item_id ,
               lines.period_id    ,
               l_channel.meaning ,
               l_category.meaning
        FROM   pn_var_lines_all lines,
               fnd_lookups l_channel,
               fnd_lookups l_category
        WHERE  lines.line_item_id = p_line_item_id
              AND l_channel.lookup_code(+) = lines.SALES_TYPE_CODE
              AND l_channel.lookup_type (+) ='PN_SALES_CHANNEL'
              AND l_category.lookup_code(+) = lines.ITEM_CATEGORY_CODE
              AND l_category.lookup_type(+) ='PN_ITEM_CATEGORY';


CURSOR c_group_DATE (p_var_rent_id NUMBER,
                     p_period_id NUMBER,
                     p_start_DATE DATE,
                     p_end_DATE DATE) IS
           SELECT GRP_DATE_ID,
                  GROUP_DATE,
                  REPTG_DUE_DATE,
                  INVOICE_DATE
      FROM   pn_var_grp_DATEs_all
      WHERE  var_rent_id    = p_var_rent_id
      AND    period_id      = p_period_id
      AND    grp_start_DATE <= p_end_DATE
      AND    grp_end_DATE   >= p_start_DATE;

CURSOR c_all_lines_imprtd IS
   SELECT 'Y'
   FROM   DUAL
   WHERE NOT EXISTS (SELECT NULL
                     FROM   pn_vol_hist_lines_itf
                     WHERE  status in ('E','P')
                     AND    batch_id = p_batch_id)
   AND EXISTS (SELECT NULL
               FROM   pn_vol_hist_batch_itf
               WHERE  status = 'E'
               AND    batch_id = p_batch_id);

--added the cusror 08/07/2003
CURSOR c_vol_line_exist(p_line_item_id NUMBER,
                        p_period_id NUMBER,
                        p_group_DATE_id NUMBER,
                        p_start_DATE DATE,
                        p_end_DATE DATE )
IS
SELECT actual_amount,
      forecasted_amount ,
      actual_exp_code,
      forecasted_exp_code
FROM
pn_var_vol_hist_all
WHERE
      LINE_ITEM_ID  = p_line_item_id
      AND  PERIOD_ID = p_period_id
      AND GRP_DATE_ID = p_group_DATE_id
      AND START_DATE = p_start_DATE
      AND END_DATE  =p_end_DATE;


-- Added on 15/jan/2007.
CURSOR c_vol_hist_data(p_vol_hist_id NUMBER) IS
SELECT LINE_ITEM_ID,
       START_DATE,
       END_DATE,
       ACTUAL_AMOUNT,
       VOL_HIST_STATUS_CODE,
       FORECASTED_AMOUNT,
       REPORT_TYPE_CODE,
       REPORTING_DATE
FROM pn_var_vol_hist_all
WHERE vol_hist_id = p_vol_hist_id;

CURSOR c_ded_hist_data(p_deduction_id NUMBER) IS
SELECT LINE_ITEM_ID,
       START_DATE,
       END_DATE,
       DEDUCTION_TYPE_CODE,
       DEDUCTION_AMOUNT
FROM PN_VAR_DEDUCTIONS_ALL
WHERE deduction_id = p_deduction_id;

-- Get the details of lines updated.
CURSOR get_vr_lines_c(ip_batch_id NUMBER
          ) IS
  SELECT distinct(line.line_item_id)
       FROM pn_vol_hist_batch_itf batch,
            pn_vol_hist_lines_itf line
       WHERE batch.batch_id = line.batch_id
       AND batch.batch_id = ip_batch_id;

  l_error_message               VARCHAR2(2000);
  INVALID_RECORD                EXCEPTION;
  v_batch_id                    NUMBER := -9999;
  v_var_rent_id                 NUMBER;
  v_line_item_id                NUMBER;
  v_period_id                   NUMBER;
  v_group_DATE_id               NUMBER;
  v_group_DATE                  DATE;
  v_reptg_due_DATE              DATE;
  v_invoice_DATE                DATE;
  l_fail                        NUMBER := 0 ;
  l_total                       NUMBER :=0 ;
  v_vol_hist_num                NUMBER;
  v_act_amount                  NUMBER;
  v_frc_amount                  NUMBER;
  v_status_code                 VARCHAR2(1);
  v_ded_amount                  NUMBER;
  v_ded_num                     NUMBER;
  l_imp_flag                    VARCHAR2(1);

--08/07/2003
  v_actual_amt_exist            NUMBER := null;
  v_forecasted_amt_exist        NUMBER := null;
  l_period_token                VARCHAR2(100);
  l_line_item_token             VARCHAR2(100);
  l_group_DATE_id_token         VARCHAR2(100);
  l_start_DATE_token            VARCHAR2(100);
  l_end_DATE_token              VARCHAR2(100);
  v_lease_name                  VARCHAR2(50);
  v_var_rent_NUMBER             VARCHAR2(30);
  v_sales_channel               VARCHAR2(80);
  v_item_category               VARCHAR2(80);
  v_actual_exp_code_exist       VARCHAR2(1);
  v_forecasted_exp_code_exist   VARCHAR2(1);
  l_success                     NUMBER := 0;
  l_org_id                      NUMBER;

  -- added on 15/jan/2007.
  l_line_item_id                NUMBER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_actual_amount               NUMBER;
  l_forecasted_amount           NUMBER;
  l_vol_hist_status_code        VARCHAR2(30);
  l_report_type_code            VARCHAR2(30);
  l_reporting_date              DATE;
  l_deduction_type_code         VARCHAR2(30);
  l_deduction_amount            NUMBER;

  lines_t NUM_T;

BEGIN

   pnp_debug_pkg.debug ('PN_SOI_VOL_IMPORT .IMPORT_VOL_HIST(+)');
   fnd_message.set_name ('PN','PN_SOI_PBATCH');
   fnd_message.set_token ('ID', p_batch_id);
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   l_imp_flag := 'N';

   OPEN  c_all_lines_imprtd;
   FETCH c_all_lines_imprtd INTO l_imp_flag;
   CLOSE c_all_lines_imprtd;

   IF l_imp_flag = 'Y' THEN

      UPDATE pn_vol_hist_batch_itf
      SET    status = 'I'
      WHERE  batch_id = p_batch_id;

   ELSE

        DELETE FROM pn_vol_hist_lines_itf line
            WHERE line.batch_id  = p_batch_id
                  AND line.status <>'I'
                  AND line.amount is null;

      FOR v_Lines IN c_batch_line LOOP

         l_total := l_total + 1;

         BEGIN

            pnp_debug_pkg.log('open cursor c_var_rent');

            OPEN c_var_rent(v_lines.var_rent_id);
            FETCH c_var_rent into v_var_rent_id,v_var_rent_NUMBER,v_lease_name, l_org_id;

            IF  c_var_rent%NOTFOUND THEN
                fnd_message.set_name('PN', 'PN_SOI_VAR_RENT_INVALID');
                l_error_message := fnd_message.get;
                CLOSE c_var_rent;
                RAISE INVALID_RECORD;
            END IF;
            CLOSE c_var_rent;

            pnp_debug_pkg.put_log_msg('-------------------------------------------------------');
            fnd_message.set_name ('PN','PN_SOI_REP_DT_LOW');
            fnd_message.set_token ('DATE', TO_CHAR(v_Lines.rep_str_DATE,'MM/DD/YYYY'));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_SOI_REP_DT_HIGH');
            fnd_message.set_token ('DATE', TO_CHAR(v_Lines.rep_end_DATE,'MM/DD/YYYY'));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            pnp_debug_pkg.log('Variable Rent Id                 = '|| v_var_rent_id );
            pnp_debug_pkg.log('open cursor c_line_item');

            OPEN c_line_item(v_lines.line_item_id);
            FETCH c_line_item into v_line_item_id, v_period_id,
                                   v_sales_channel,v_item_category;

            IF  c_line_item%NOTFOUND THEN
                fnd_message.set_name('PN', 'PN_SOI_LINE_ITEM_INVALID');
                l_error_message := fnd_message.get;
                CLOSE c_line_item;
                RAISE INVALID_RECORD;
            END IF;
            CLOSE c_line_item;

           fnd_message.set_name ('PN','PN_SOI_SALES_CH');
           fnd_message.set_token ('CH',v_sales_channel);
           pnp_debug_pkg.put_log_msg(fnd_message.get);

           fnd_message.set_name ('PN','PN_SOI_ITM_CATG');
           fnd_message.set_token ('CAT',v_item_category);
           pnp_debug_pkg.put_log_msg(fnd_message.get);

            pnp_debug_pkg.log( 'Line Item Id                    = '|| v_line_item_id );
            pnp_debug_pkg.log( 'Period Id                       = '|| v_period_id );
            pnp_debug_pkg.log('open cursor c_group_DATE');

            OPEN c_group_DATE(v_var_rent_id,v_period_id,
                              v_lines.rep_str_DATE,
                              v_lines.rep_end_DATE);
            FETCH c_group_DATE into v_group_DATE_id,
                                    v_group_DATE,
                                    v_reptg_due_DATE,
                                    v_invoice_DATE;

            IF c_group_DATE%NOTFOUND THEN
               fnd_message.set_name('PN','PN_SOI_VAR_CHECK_DATES');
               l_error_message := fnd_message.get;
               CLOSE c_group_DATE;
               RAISE INVALID_RECORD;

            ELSIF c_group_DATE%ROWCOUNT > 2 THEN
               fnd_message.set_name('PN','PN_VAR_MULTIPLE_GROUP_DATES');
               l_error_message := fnd_message.get;
               CLOSE c_group_DATE;
               RAISE INVALID_RECORD;
            END IF;
            CLOSE c_group_DATE;

       fnd_message.set_name ('PN','PN_SOI_GRP_DT');
       fnd_message.set_token ('DATE',v_group_DATE);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       fnd_message.set_name ('PN','PN_AMOUNT');
       fnd_message.set_token ('AMT',v_lines.amount);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       fnd_message.set_name ('PN','PN_LEASE_NAME');
       fnd_message.set_token ('NAME',v_lease_name);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

       fnd_message.set_name ('PN','PN_SOI_VRN');
       fnd_message.set_token ('NUM',v_var_rent_NUMBER);
       pnp_debug_pkg.put_log_msg(fnd_message.get);

            IF v_lines.volume_type = 'ACTUAL'  THEN
               v_act_amount := v_lines.amount;

            ELSIF v_lines.volume_type = 'FORECASTED' THEN
               v_frc_amount := v_lines.amount;

            ELSIF v_lines.volume_type ='DEDUCTION' THEN
                v_ded_amount := v_lines.amount;

            ELSE fnd_message.set_name('PN','PN_INVALID_VOLUME_TYPE');
                 l_error_message := fnd_message.get;
                 RAISE INVALID_RECORD;
            END IF;

            pnp_debug_pkg.log( 'Volume Type  = '|| v_lines.volume_type );
            pnp_debug_pkg.log('before insert in the table pn_var_vol_hist');


      IF v_lines.volume_type IN ('ACTUAL','FORECASTED') THEN

         IF v_lines.vol_deduct_id IS NULL THEN
            OPEN c_vol_line_exist(v_lines.line_item_id,v_period_id, v_group_DATE_id,
                                  v_lines.rep_str_DATE,v_lines.rep_end_DATE);

            FETCH c_vol_line_exist into v_actual_amt_exist,
                                        v_forecasted_amt_exist,
                                        v_actual_exp_code_exist,
                                        v_forecasted_exp_code_exist;


            IF c_vol_line_exist%NOTFOUND THEN
               SELECT NVL(MAX(vol_hist_num), 0)+1 INTO v_vol_hist_num
               FROM   pn_var_vol_hist_all
               WHERE  line_item_id = v_lines.line_item_id;

               INSERT INTO pn_var_vol_hist_all (VOL_HIST_ID
                                           ,VOL_HIST_NUM
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,LINE_ITEM_ID
                                           ,PERIOD_ID
                                           ,START_DATE
                                           ,END_DATE
                                           ,GRP_DATE_ID
                                           ,GROUP_DATE
                                           ,DUE_DATE
                                           ,INVOICING_DATE
                                           ,ACTUAL_AMOUNT
                                           ,VOL_HIST_STATUS_CODE
                                           ,CERTIFIED_BY
                                           ,ACTUAL_EXP_CODE
                                           ,FORECASTED_AMOUNT
                                           ,FORECASTED_EXP_CODE
                                           ,VARIANCE_EXP_CODE
                                           ,ORG_ID
                                           ,REPORT_TYPE_CODE
					   ,REPORTING_DATE)
                                    VALUES (PN_VAR_VOL_HIST_S.NEXTVAL
                                           ,v_vol_hist_num
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,v_lines.line_item_id
                                           ,v_period_id
                                           ,v_lines.rep_str_DATE
                                           ,v_lines.rep_end_DATE
                                           ,v_group_DATE_id
                                           ,v_group_DATE
                                           ,v_reptg_due_DATE
                                           ,v_invoice_DATE
                                           ,v_act_amount
                                           ,v_lines.vol_hist_status_code
                                           ,v_lines.certified_by
                                           ,'N'
                                           ,v_frc_amount
                                           ,'N'
                                           ,'N'
                                           ,l_org_id
                                           ,v_lines.report_type_code
					   ,v_lines.reporting_date);


            ELSIF  v_lines.volume_type  = 'ACTUAL' THEN
                 IF ( NVL(v_actual_amt_exist,0) = v_act_amount) THEN

                      fnd_message.set_name('PN','PN_VAR_ACTUAL_AMT_EXIST');
                      l_period_token := ':'||TO_CHAR(v_period_id) ;
                      l_line_item_token := ':'||TO_CHAR(v_lines.line_item_id) ;
                      l_group_DATE_id_token := ':'||TO_CHAR(v_group_DATE_id);
                      l_start_DATE_token := ':'||TO_CHAR(v_lines.rep_str_DATE,'MM/DD/YYYY');
                      l_end_DATE_token   := ':'||TO_CHAR(v_lines.rep_end_DATE,'MM/DD/YYYY');
                      fnd_message.set_token('PERIOD_ID',l_period_token);
                      fnd_message.set_token('LINE_ITEM_ID',l_line_item_token);
                      fnd_message.set_token('GROUP_DATE_ID',l_group_DATE_id_token);
                      fnd_message.set_token('START_DATE',l_start_DATE_token);
                      fnd_message.set_token('END_DATE',l_end_DATE_token);

                      l_error_message := fnd_message.get;
                      CLOSE c_vol_line_exist;
                      RAISE INVALID_RECORD;

                ELSIF (NVL(v_actual_amt_exist,0) <> 0) THEN

                      SELECT NVL(MAX(vol_hist_num), 0)+1 INTO v_vol_hist_num
                      FROM   pn_var_vol_hist_all
                      WHERE  line_item_id = v_lines.line_item_id;

                      INSERT INTO pn_var_vol_hist_all (VOL_HIST_ID
                                           ,VOL_HIST_NUM
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,LINE_ITEM_ID
                                           ,PERIOD_ID
                                           ,START_DATE
                                           ,END_DATE
                                           ,GRP_DATE_ID
                                           ,GROUP_DATE
                                           ,DUE_DATE
                                           ,INVOICING_DATE
                                           ,ACTUAL_AMOUNT
                                           ,VOL_HIST_STATUS_CODE
                                           ,CERTIFIED_BY
                                           ,ACTUAL_EXP_CODE
                                           ,FORECASTED_AMOUNT
                                           ,FORECASTED_EXP_CODE
                                           ,VARIANCE_EXP_CODE
                                           ,org_id
                                           ,REPORT_TYPE_CODE
					   ,REPORTING_DATE)
                                    VALUES (PN_VAR_VOL_HIST_S.NEXTVAL
                                           ,v_vol_hist_num
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,v_lines.line_item_id
                                           ,v_period_id
                                           ,v_lines.rep_str_DATE
                                           ,v_lines.rep_end_DATE
                                           ,v_group_DATE_id
                                           ,v_group_DATE
                                           ,v_reptg_due_DATE
                                           ,v_invoice_DATE
                                           ,NVL(v_act_amount,0)
                                           ,v_lines.vol_hist_status_code
                                           ,v_lines.certified_by
                                           ,'N'
                                           ,v_frc_amount
                                           ,'N'
                                           ,'N'
                                           ,l_org_id
                                           ,v_lines.report_type_code
					   ,v_lines.reporting_date);

                ELSIF (NVL(v_actual_amt_exist,0) = 0) THEN

                   IF v_actual_exp_code_exist ='N' THEN

                     UPDATE PN_VAR_VOL_HIST_ALL
                     SET ACTUAL_AMOUNT = v_act_amount
                        ,LAST_UPDATE_DATE =sysDATE
                        ,LAST_UPDATED_BY  =  NVL(fnd_profile.value('USER_ID'), 0)
                        ,LAST_UPDATE_LOGIN =NVL(fnd_profile.value('USER_ID'), 0)
                     WHERE  LINE_ITEM_ID  = v_lines.line_item_id
                     AND    PERIOD_ID = v_period_id
                     AND    GRP_DATE_ID = v_group_DATE_id
                     AND    START_DATE = v_lines.rep_str_DATE
                     AND    END_DATE  =v_lines.rep_end_DATE
                     AND    actual_exp_code ='N';



                   ELSIF (v_actual_exp_code_exist ='Y') THEN

                     SELECT NVL(MAX(vol_hist_num), 0)+1 INTO v_vol_hist_num
                     FROM   pn_var_vol_hist_all
                     WHERE  line_item_id = v_lines.line_item_id;

                         INSERT INTO pn_var_vol_hist_all (VOL_HIST_ID
                                           ,VOL_HIST_NUM
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,LINE_ITEM_ID
                                           ,PERIOD_ID
                                           ,START_DATE
                                           ,END_DATE
                                           ,GRP_DATE_ID
                                           ,GROUP_DATE
                                           ,DUE_DATE
                                           ,INVOICING_DATE
                                           ,ACTUAL_AMOUNT
                                           ,VOL_HIST_STATUS_CODE
                                           ,CERTIFIED_BY
                                           ,ACTUAL_EXP_CODE
                                           ,FORECASTED_AMOUNT
                                           ,FORECASTED_EXP_CODE
                                           ,VARIANCE_EXP_CODE
                                           ,org_id
                                           ,REPORT_TYPE_CODE
					   ,REPORTING_DATE)
                                    VALUES (PN_VAR_VOL_HIST_S.NEXTVAL
                                           ,v_vol_hist_num
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,v_lines.line_item_id
                                           ,v_period_id
                                           ,v_lines.rep_str_DATE
                                           ,v_lines.rep_end_DATE
                                           ,v_group_DATE_id
                                           ,v_group_DATE
                                           ,v_reptg_due_DATE
                                           ,v_invoice_DATE
                                           ,NVL(v_act_amount,0)
                                           ,v_lines.vol_hist_status_code
                                           ,v_lines.certified_by
                                           ,'N'
                                           ,v_frc_amount
                                           ,'N'
                                           ,'N'
                                           ,l_org_id
                                           ,v_lines.report_type_code
					   ,v_lines.reporting_date);
                   END IF;

                END IF;


           ELSIF  v_lines.volume_type  = 'FORECASTED' THEN
              IF (NVL(v_forecasted_amt_exist,0) = v_frc_amount) THEN

                      fnd_message.set_name('PN','PN_VAR_FORECASTED_AMT_EXIST');
                      l_period_token := ':'||TO_CHAR(v_period_id) ;
                      l_line_item_token := ':'||TO_CHAR(v_lines.line_item_id) ;
                      l_group_DATE_id_token := ':'||TO_CHAR(v_group_DATE_id);
                      l_start_DATE_token := ':'||TO_CHAR(v_lines.rep_str_DATE,'MM/DD/YYYY');
                      l_end_DATE_token   := ':'||TO_CHAR(v_lines.rep_end_DATE,'MM/DD/YYYY');
                      fnd_message.set_token('PERIOD_ID',l_period_token);
                      fnd_message.set_token('LINE_ITEM_ID',l_line_item_token);
                      fnd_message.set_token('GROUP_DATE_ID',l_group_DATE_id_token);
                      fnd_message.set_token('START_DATE',l_start_DATE_token);
                      fnd_message.set_token('END_DATE',l_end_DATE_token);

                      l_error_message := fnd_message.get;
                      CLOSE c_vol_line_exist;
                      RAISE INVALID_RECORD;

              ELSIF  NVL(v_forecasted_amt_exist,0) <> 0 THEN

                      SELECT NVL(MAX(vol_hist_num), 0)+1 INTO v_vol_hist_num
                      FROM   pn_var_vol_hist_all
                      WHERE  line_item_id = v_lines.line_item_id;

                         INSERT INTO pn_var_vol_hist_all (VOL_HIST_ID
                                           ,VOL_HIST_NUM
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,LINE_ITEM_ID
                                           ,PERIOD_ID
                                           ,START_DATE
                                           ,END_DATE
                                           ,GRP_DATE_ID
                                           ,GROUP_DATE
                                           ,DUE_DATE
                                           ,INVOICING_DATE
                                           ,ACTUAL_AMOUNT
                                           ,VOL_HIST_STATUS_CODE
                                           ,CERTIFIED_BY
                                           ,ACTUAL_EXP_CODE
                                           ,FORECASTED_AMOUNT
                                           ,FORECASTED_EXP_CODE
                                           ,VARIANCE_EXP_CODE
                                           ,org_id
                                           ,REPORT_TYPE_CODE
					   ,REPORTING_DATE)
                                    VALUES (PN_VAR_VOL_HIST_S.NEXTVAL
                                           ,v_vol_hist_num
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,v_lines.line_item_id
                                           ,v_period_id
                                           ,v_lines.rep_str_DATE
                                           ,v_lines.rep_end_DATE
                                           ,v_group_DATE_id
                                           ,v_group_DATE
                                           ,v_reptg_due_DATE
                                           ,v_invoice_DATE
                                           ,v_act_amount
                                           ,v_lines.vol_hist_status_code
                                           ,v_lines.certified_by
                                           ,'N'
                                           ,NVL(v_frc_amount,0)
                                           ,'N'
                                           ,'N'
                                           ,l_org_id
                                           ,v_lines.report_type_code
					   ,v_lines.reporting_date);

              ELSIF (NVL(v_forecasted_amt_exist,0) = 0) THEN

                   IF v_forecasted_exp_code_exist ='N' THEN

                     UPDATE PN_VAR_VOL_HIST_ALl
                     SET FORECASTED_AMOUNT = v_frc_amount
                        ,LAST_UPDATE_DATE =sysDATE
                        ,LAST_UPDATED_BY  =  NVL(fnd_profile.value('USER_ID'), 0)
                        ,LAST_UPDATE_LOGIN =NVL(fnd_profile.value('USER_ID'), 0)
                     WHERE  LINE_ITEM_ID  = v_lines.line_item_id
                     AND    PERIOD_ID = v_period_id
                     AND    GRP_DATE_ID = v_group_DATE_id
                     AND    START_DATE = v_lines.rep_str_DATE
                     AND    END_DATE  =v_lines.rep_end_DATE
                     AND    forecasted_exp_code = 'N';


                   ELSIF (v_forecasted_exp_code_exist ='Y') THEN

                     SELECT NVL(MAX(vol_hist_num), 0)+1 INTO v_vol_hist_num
                     FROM   pn_var_vol_hist_all
                     WHERE  line_item_id = v_lines.line_item_id;

                        INSERT INTO pn_var_vol_hist_all (VOL_HIST_ID
                                           ,VOL_HIST_NUM
                                           ,LAST_UPDATE_DATE
                                           ,LAST_UPDATED_BY
                                           ,CREATION_DATE
                                           ,CREATED_BY
                                           ,LAST_UPDATE_LOGIN
                                           ,LINE_ITEM_ID
                                           ,PERIOD_ID
                                           ,START_DATE
                                           ,END_DATE
                                           ,GRP_DATE_ID
                                           ,GROUP_DATE
                                           ,DUE_DATE
                                           ,INVOICING_DATE
                                           ,ACTUAL_AMOUNT
                                           ,VOL_HIST_STATUS_CODE
                                           ,CERTIFIED_BY
                                           ,ACTUAL_EXP_CODE
                                           ,FORECASTED_AMOUNT
                                           ,FORECASTED_EXP_CODE
                                           ,VARIANCE_EXP_CODE
                                           ,org_id
                                           ,REPORT_TYPE_CODE
					   ,REPORTING_DATE)
                                    VALUES (PN_VAR_VOL_HIST_S.NEXTVAL
                                           ,v_vol_hist_num
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,sysDATE
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,NVL(fnd_profile.value('USER_ID'), 0)
                                           ,v_lines.line_item_id
                                           ,v_period_id
                                           ,v_lines.rep_str_DATE
                                           ,v_lines.rep_end_DATE
                                           ,v_group_DATE_id
                                           ,v_group_DATE
                                           ,v_reptg_due_DATE
                                           ,v_invoice_DATE
                                           ,v_act_amount
                                           ,v_lines.vol_hist_status_code
                                           ,v_lines.certified_by
                                           ,'N'
                                           ,NVL(v_frc_amount,0)
                                           ,'N'
                                           ,'N'
                                           ,l_org_id
                                           ,v_lines.report_type_code
					   ,v_lines.reporting_date);

                   END IF;

              END IF;

           END IF;

           CLOSE c_vol_line_exist;

         ELSE    /* Vol Hist Id is NOT NULL */

                         OPEN c_vol_hist_data(v_lines.vol_deduct_id);

                         FETCH c_vol_hist_data INTO l_line_item_id,
                                                    l_start_date,
                                                    l_end_date,
                                                    l_actual_amount,
                                                    l_vol_hist_status_code,
                                                    l_forecasted_amount,
                                                    l_report_type_code,
						    l_reporting_date;

                      IF    l_line_item_id          <>      v_lines.line_item_id           OR
                            l_start_date            <>      v_lines.rep_str_DATE           OR
                            l_end_date              <>      v_lines.rep_end_DATE           OR
                            l_actual_amount         <>      NVL(v_act_amount,0)            OR
                            l_vol_hist_status_code  <>      v_lines.vol_hist_status_code   OR
                            l_forecasted_amount     <>      NVL(v_frc_amount,0)            OR
                            l_report_type_code      <>      v_lines.report_type_code       OR
			    l_reporting_date        <>      v_lines.reporting_date         THEN


                         PN_SOI_VOL_IMPORT.g_org_id := l_org_id;
                         INSERT INTO PN_VAR_VOL_ARCH_ALL(
                                  VOL_ARCH_ID
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,CREATION_DATE
                                 ,CREATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,ORG_ID
                                 ,VOL_HIST_ID
                                 ,VOL_HIST_NUM
                                 ,HIST_LAST_UPDATE_DATE
                                 ,HIST_LAST_UPDATED_BY
                                 ,HIST_CREATION_DATE
                                 ,HIST_CREATED_BY
                                 ,HIST_LAST_UPDATE_LOGIN
                                 ,LINE_ITEM_ID
                                 ,PERIOD_ID
                                 ,START_DATE
                                 ,END_DATE
                                 ,GRP_DATE_ID
                                 ,GROUP_DATE
                                 ,REPORTING_DATE
                                 ,DUE_DATE
                                 ,INVOICING_DATE
                                 ,ACTUAL_GL_ACCOUNT_ID
                                 ,ACTUAL_AMOUNT
                                 ,VOL_HIST_STATUS_CODE
                                 ,REPORT_TYPE_CODE
                                 ,CERTIFIED_BY
                                 ,ACTUAL_EXP_CODE
                                 ,FOR_GL_ACCOUNT_ID
                                 ,FORECASTED_AMOUNT
                                 ,FORECASTED_EXP_CODE
                                 ,VARIANCE_EXP_CODE
                                 ,COMMENTS
                                 ,ATTRIBUTE_CATEGORY
                                 ,ATTRIBUTE1
                                 ,ATTRIBUTE2
                                 ,ATTRIBUTE3
                                 ,ATTRIBUTE4
                                 ,ATTRIBUTE5
                                 ,ATTRIBUTE6
                                 ,ATTRIBUTE7
                                 ,ATTRIBUTE8
                                 ,ATTRIBUTE9
                                 ,ATTRIBUTE10
                                 ,ATTRIBUTE11
                                 ,ATTRIBUTE12
                                 ,ATTRIBUTE13
                                 ,ATTRIBUTE14
                                 ,ATTRIBUTE15
                                 ,HIST_ORG_ID
                                 ,DAILY_ACTUAL_AMOUNT
                                 )
                           SELECT
                                  PN_VAR_VOL_ARCH_S.nextval
                                 ,sysDATE
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,sysDATE
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,PN_SOI_VOL_IMPORT.g_org_id
                                 ,VOL_HIST_ID
                                 ,VOL_HIST_NUM
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,CREATION_DATE
                                 ,CREATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,LINE_ITEM_ID
                                 ,PERIOD_ID
                                 ,START_DATE
                                 ,END_DATE
                                 ,GRP_DATE_ID
                                 ,GROUP_DATE
                                 ,REPORTING_DATE
                                 ,DUE_DATE
                                 ,INVOICING_DATE
                                 ,ACTUAL_GL_ACCOUNT_ID
                                 ,ACTUAL_AMOUNT
                                 ,VOL_HIST_STATUS_CODE
                                 ,REPORT_TYPE_CODE
                                 ,CERTIFIED_BY
                                 ,ACTUAL_EXP_CODE
                                 ,FOR_GL_ACCOUNT_ID
                                 ,FORECASTED_AMOUNT
                                 ,FORECASTED_EXP_CODE
                                 ,VARIANCE_EXP_CODE
                                 ,COMMENTS
                                 ,ATTRIBUTE_CATEGORY
                                 ,ATTRIBUTE1
                                 ,ATTRIBUTE2
                                 ,ATTRIBUTE3
                                 ,ATTRIBUTE4
                                 ,ATTRIBUTE5
                                 ,ATTRIBUTE6
                                 ,ATTRIBUTE7
                                 ,ATTRIBUTE8
                                 ,ATTRIBUTE9
                                 ,ATTRIBUTE10
                                 ,ATTRIBUTE11
                                 ,ATTRIBUTE12
                                 ,ATTRIBUTE13
                                 ,ATTRIBUTE14
                                 ,ATTRIBUTE15
                                 ,ORG_ID
                                 ,DAILY_ACTUAL_AMOUNT
                           FROM  PN_VAR_VOL_HIST_ALL
                           WHERE VOL_HIST_ID = v_lines.vol_deduct_id;

                          UPDATE PN_VAR_VOL_HIST_ALL
                          SET  LAST_UPDATE_DATE         =        sysDATE
                              ,LAST_UPDATED_BY          =        NVL(fnd_profile.value('USER_ID'), 0)
                              ,LAST_UPDATE_LOGIN        =        NVL(fnd_profile.value('USER_ID'), 0)
                              ,LINE_ITEM_ID             =        v_lines.line_item_id
                              ,START_DATE               =        v_lines.rep_str_DATE
                              ,END_DATE                 =        v_lines.rep_end_DATE
                              ,VOL_HIST_STATUS_CODE     =        v_lines.vol_hist_status_code
                              ,ORG_ID                   =        l_org_id
                              ,REPORT_TYPE_CODE         =        v_lines.report_type_code
			      ,REPORTING_DATE           =        v_lines.reporting_date
                          WHERE vol_hist_id = v_lines.vol_deduct_id;

			  IF v_lines.volume_type = 'ACTUAL' THEN

			     UPDATE PN_VAR_VOL_HIST_ALL
			     SET ACTUAL_AMOUNT  = NVL(v_act_amount,0)
			     WHERE vol_hist_id = v_lines.vol_deduct_id;

			  ELSIF v_lines.volume_type = 'FORECASTED' THEN

			     UPDATE PN_VAR_VOL_HIST_ALL
			     SET FORECASTED_AMOUNT  = NVL(v_frc_amount,0)
			     WHERE vol_hist_id = v_lines.vol_deduct_id;

			  END IF;

                      END IF;
                      CLOSE c_vol_hist_data;
         END IF;

      ELSIF v_lines.volume_type ='DEDUCTION' THEN

               SELECT NVL(MAX(deduction_num), 0)+1 INTO v_ded_num
               FROM   pn_var_deductions_all
               WHERE  line_item_id = v_lines.line_item_id;

               IF v_lines.vol_deduct_id IS NULL THEN
                   INSERT INTO pn_var_deductions_all (DEDUCTION_ID
                                             ,DEDUCTION_NUM
                                             ,LAST_UPDATE_DATE
                                             ,LAST_UPDATED_BY
                                             ,CREATION_DATE
                                             ,CREATED_BY
                                             ,LAST_UPDATE_LOGIN
                                             ,LINE_ITEM_ID
                                             ,PERIOD_ID
                                             ,START_DATE
                                             ,END_DATE
                                             ,GRP_DATE_ID
                                             ,GROUP_DATE
                                             ,INVOICING_DATE
                                             ,DEDUCTION_AMOUNT
                                             ,EXPORTED_CODE
                                             ,DEDUCTION_TYPE_CODE
                                             ,org_id)
                                      VALUES (PN_VAR_DEDUCTIONS_S.NEXTVAL
                                             ,v_ded_num
                                             ,sysDATE
                                             ,NVL(fnd_profile.value('USER_ID'), 0)
                                             ,sysDATE
                                             ,NVL(fnd_profile.value('USER_ID'), 0)
                                             ,NVL(fnd_profile.value('USER_ID'), 0)
                                             ,v_lines.line_item_id
                                             ,v_period_id
                                             ,v_lines.rep_str_DATE
                                             ,v_lines.rep_end_DATE
                                             ,v_group_DATE_id
                                             ,v_group_DATE
                                             ,v_invoice_DATE
                                             ,NVL(v_ded_amount,0)
                                             ,'N'
                                             ,v_lines.deduction_type_code
                                             ,l_org_id);
               ELSE

                         OPEN c_ded_hist_data(v_lines.vol_deduct_id);

                         FETCH c_ded_hist_data INTO l_line_item_id,
                                                    l_start_date,
                                                    l_end_date,
                                                    l_deduction_type_code,
                                                    l_deduction_amount;

                        IF   l_line_item_id          <>    v_lines.line_item_id         OR
                             l_start_date            <>    v_lines.rep_str_DATE         OR
                             l_end_date              <>    v_lines.rep_end_DATE         OR
                             l_deduction_type_code   <>    v_lines.deduction_type_code  OR
                             l_deduction_amount      <>    NVL(v_ded_amount,0)          THEN

                         PN_SOI_VOL_IMPORT.g_org_id := l_org_id;
                         INSERT INTO PN_VAR_DEDUCT_ARCH_ALL(
                                  DEDUCT_ARCH_ID
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,CREATION_DATE
                                 ,CREATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,ORG_ID
                                 ,DEDUCTION_ID
                                 ,DEDUCTION_NUM
                                 ,HIST_LAST_UPDATE_DATE
                                 ,HIST_LAST_UPDATED_BY
                                 ,HIST_CREATION_DATE
                                 ,HIST_CREATED_BY
                                 ,HIST_LAST_UPDATE_LOGIN
                                 ,LINE_ITEM_ID
                                 ,PERIOD_ID
                                 ,START_DATE
                                 ,END_DATE
                                 ,GRP_DATE_ID
                                 ,GROUP_DATE
                                 ,INVOICING_DATE
                                 ,GL_ACCOUNT_ID
                                 ,DEDUCTION_TYPE_CODE
                                 ,DEDUCTION_AMOUNT
                                 ,EXPORTED_CODE
                                 ,COMMENTS
                                 ,ATTRIBUTE_CATEGORY
                                 ,ATTRIBUTE1
                                 ,ATTRIBUTE2
                                 ,ATTRIBUTE3
                                 ,ATTRIBUTE4
                                 ,ATTRIBUTE5
                                 ,ATTRIBUTE6
                                 ,ATTRIBUTE7
                                 ,ATTRIBUTE8
                                 ,ATTRIBUTE9
                                 ,ATTRIBUTE10
                                 ,ATTRIBUTE11
                                 ,ATTRIBUTE12
                                 ,ATTRIBUTE13
                                 ,ATTRIBUTE14
                                 ,ATTRIBUTE15
                                 ,HIST_ORG_ID
                                 )
                           SELECT
                                  PN_VAR_DEDUCT_ARCH_S.nextval
                                 ,sysDATE
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,sysDATE
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,NVL(fnd_profile.value('USER_ID'), 0)
                                 ,PN_SOI_VOL_IMPORT.g_org_id
                                 ,DEDUCTION_ID
                                 ,DEDUCTION_NUM
                                 ,LAST_UPDATE_DATE
                                 ,LAST_UPDATED_BY
                                 ,CREATION_DATE
                                 ,CREATED_BY
                                 ,LAST_UPDATE_LOGIN
                                 ,LINE_ITEM_ID
                                 ,PERIOD_ID
                                 ,START_DATE
                                 ,END_DATE
                                 ,GRP_DATE_ID
                                 ,GROUP_DATE
                                 ,INVOICING_DATE
                                 ,GL_ACCOUNT_ID
                                 ,DEDUCTION_TYPE_CODE
                                 ,DEDUCTION_AMOUNT
                                 ,EXPORTED_CODE
                                 ,COMMENTS
                                 ,ATTRIBUTE_CATEGORY
                                 ,ATTRIBUTE1
                                 ,ATTRIBUTE2
                                 ,ATTRIBUTE3
                                 ,ATTRIBUTE4
                                 ,ATTRIBUTE5
                                 ,ATTRIBUTE6
                                 ,ATTRIBUTE7
                                 ,ATTRIBUTE8
                                 ,ATTRIBUTE9
                                 ,ATTRIBUTE10
                                 ,ATTRIBUTE11
                                 ,ATTRIBUTE12
                                 ,ATTRIBUTE13
                                 ,ATTRIBUTE14
                                 ,ATTRIBUTE15
                                 ,ORG_ID
                           FROM  PN_VAR_DEDUCTIONS_ALL
                           WHERE DEDUCTION_ID = v_lines.vol_deduct_id;

                         UPDATE PN_VAR_DEDUCTIONS_ALL
                         SET   LAST_UPDATE_DATE       =     sysDATE
                              ,LAST_UPDATED_BY        =     NVL(fnd_profile.value('USER_ID'), 0)
                              ,LAST_UPDATE_LOGIN      =     NVL(fnd_profile.value('USER_ID'), 0)
                              ,LINE_ITEM_ID           =     v_lines.line_item_id
                              ,START_DATE             =     v_lines.rep_str_DATE
                              ,END_DATE               =     v_lines.rep_end_DATE
                              ,DEDUCTION_TYPE_CODE    =     v_lines.deduction_type_code
                              ,DEDUCTION_AMOUNT       =     NVL(v_ded_amount,0)
                         WHERE DEDUCTION_ID = v_lines.vol_deduct_id;

                         END IF;
                         CLOSE c_ded_hist_data;
               END IF;

            END IF;

            pnp_debug_pkg.log('before upDATE of table pn_vol_hist_lines_itf');

            UPDATE pn_vol_hist_lines_itf
            SET    status    = 'I',
                   error_log = NULL,
                   group_DATE = v_group_DATE
            WHERE  rowid     = v_lines.rowid;

            EXCEPTION

               WHEN INVALID_RECORD THEN

                  l_fail := l_fail + 1;
                   -- UpDATE ERROR_MESSAGE
                  UPDATE pn_vol_hist_lines_itf
                  SET    error_log = SUBSTR(l_error_message, 1, 240),
                         status ='E'
                  WHERE  rowid = v_lines.rowid;

                  fnd_message.set_name ('PN','PN_SOI_PBATCH');
                  fnd_message.set_token ('ID', p_batch_id);
                  pnp_debug_pkg.put_log_msg(fnd_message.get||'-'||l_error_message);

                  pnp_debug_pkg.log('Row Id :'||v_lines.rowid ||'-'||l_error_message);

         END;
      END LOOP;
   END IF;

   IF (l_total = 0) THEN
      fnd_message.set_name ('PN', 'PN_SOI_BATCH_REC_NOT_FOUND');
      l_error_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_error_message);
   ELSE
      IF l_fail = 0 THEN
         v_status_code := 'I';

      ELSE
         v_status_code := 'E';
      END IF;

      UPDATE pn_vol_hist_batch_itf
      SET    status = v_status_code
      WHERE  batch_id = p_batch_id;





      pnp_debug_pkg.put_log_msg('------------------------------------------------');

      l_success  := l_total- l_fail;
      fnd_message.set_name('PN', 'PN_SOI_PROC');
      fnd_message.set_token('NUM', TO_CHAR(l_success));
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      fnd_message.set_name('PN', 'PN_SOI_FAILURE');
      fnd_message.set_token('FAILURE', l_fail);
      l_error_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_error_message);

   END IF;

   COMMIT;

   OPEN get_vr_lines_c(p_batch_id);
   FETCH get_vr_lines_c BULK COLLECT INTO lines_t;
   CLOSE get_vr_lines_c;

    FORALL line_id IN 1..lines_t.COUNT
    UPDATE
    pn_var_lines_all
    SET
    sales_vol_update_flag = 'Y'
    WHERE
    line_item_id = lines_t(line_id);

   pnp_debug_pkg.debug ('PN_VAR_RENTS_PKG.IMPORT_VOL_HIST (-)');

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pnp_debug_pkg.log('EXCEPTION: NO_DATA_FOUND');
         fnd_message.set_name ('PN', 'PN_SOI_BATCH_REC_NOT_FOUND');
         l_error_message := fnd_message.get;
         errbuf  := l_error_message;
         retcode := '2';
         pnp_debug_pkg.put_log_msg(errbuf);
         RAISE;

      WHEN OTHERS THEN
         pnp_debug_pkg.log('EXCEPTION: OTHERS');
         retcode := '2';
         pnp_debug_pkg.put_log_msg(errbuf);
         RAISE;

END import_vol_hist;

-------------------------------------
--Variable Rent Gateway Purge Program.
-------------------------------------
PROCEDURE delete_vol_hist(errbuf       OUT  NOCOPY VARCHAR2,
                          retcode      OUT  NOCOPY VARCHAR2,
                          p_batch_id   IN          NUMBER,
                      p_start_DATE IN        VARCHAR2,
                      p_end_DATE   IN        VARCHAR2) IS
CURSOR c_batch IS
   SELECT batch_id,
          batch_name,
          status
   FROM   pn_vol_hist_batch_itf
   WHERE  ((p_batch_id IS NOT NULL AND batch_id = p_batch_id) OR (p_batch_id IS NULL))
   AND    ((fnd_DATE.canonical_to_DATE(p_start_DATE) IS NOT NULL
           AND min_rep_DATE >= fnd_DATE.canonical_to_DATE(p_start_DATE))
           OR (p_start_DATE IS NULL))
   AND    ((fnd_DATE.canonical_to_DATE(p_end_DATE) IS NOT NULL
           AND max_rep_DATE <= fnd_DATE.canonical_to_DATE(p_end_DATE))
           OR (p_end_DATE IS NULL))
   AND    status  IN ('I','E');

   l_total                               NUMBER := 0 ;
   l_total_batch_deleted                 NUMBER := 0 ;
   l_total_lines_deleted                 NUMBER := 0 ;
   l_error_message                       VARCHAR2(2000);

BEGIN
   PNP_DEBUG_PKG.debug ('PN_SOI_VOL_IMPORT .DELETE_VOL_HIST(+)');

   fnd_message.set_name ('PN','PN_SOI_PBATCH');
   fnd_message.set_token ('ID', p_batch_id);
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name ('PN','PN_SOI_REP_DT_LOW');
   fnd_message.set_token ('DATE', p_start_DATE);
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name ('PN','PN_SOI_REP_DT_HIGH');
   fnd_message.set_token ('DATE',p_start_DATE);
   pnp_debug_pkg.put_log_msg(fnd_message.get);


   FOR v_batch IN c_batch LOOP

      l_total := l_total + 1;

      IF (v_batch.status = 'I') THEN

         pnp_debug_pkg.log ('Deleting Lines with status as I  for batch Id:'||v_batch.batch_id);

         DELETE FROM pn_vol_hist_lines_itf
         WHERE  batch_id = v_batch.batch_id;

         l_total_lines_deleted := l_total_lines_deleted + SQL%ROWCOUNT ;

         pnp_debug_pkg.log ('Deleting batch with status as I for Batch Id:'||v_batch.batch_id);

         DELETE FROM pn_vol_hist_batch_itf
         WHERE  batch_id = v_batch.batch_id;

        l_total_batch_deleted := l_total_batch_deleted + 1;

      ELSIF (v_batch.status = 'E') THEN

         pnp_debug_pkg.log ('Deleting Lines with status as I  for batch Id of status E:'||v_batch.batch_id);
         DELETE FROM pn_vol_hist_lines_itf
         WHERE  batch_id = v_batch.batch_id
         AND status = 'I';

         l_total_lines_deleted := l_total_lines_deleted + SQL%ROWCOUNT ;
      END IF;
   END LOOP;

   IF (l_total = 0) THEN
      fnd_message.set_name ('PN', 'PN_SOI_NO_BATCH_FOUND');
      l_error_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_error_message);

   ELSE
      fnd_message.set_name('PN', 'PN_SOI_BATCH_TOTAL_DELETED');
      fnd_message.set_token('BATCH_TOTAL', l_total_batch_deleted);
      l_error_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_error_message);

      fnd_message.set_name('PN', 'PN_SOI_LINES_TOTAL_DELETED');
      fnd_message.set_token('LINES_TOTAL', l_total_lines_deleted);
      l_error_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_error_message);
   END IF;

   COMMIT;

   pnp_debug_pkg.debug ('PN_VAR_RENTS_PKG.DELETE_VOL_HIST (-)');

END delete_vol_hist;

END pn_soi_vol_import;

/
