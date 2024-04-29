--------------------------------------------------------
--  DDL for Package Body OPI_EDW_OPM_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_OPM_PRD_PKG" AS
/* $Header: OPIEPRDB.pls 115.3 2002/05/07 13:29:02 pkm ship      $ */

  FUNCTION FIND_PROD_GRADE(TRANS_ID_VI IN INTEGER,ITEM_ID_VI IN INTEGER,LOT_ID_VI IN INTEGER)
           RETURN VARCHAR2
	IS
                TRANS_ID_V		ic_TRAN_CMP.TRANS_id%TYPE := NULL;
                QC_GRADE_V		ic_TRAN_CMP.QC_GRADE%TYPE := NULL;

		CURSOR GRADE_CHANGE_TRAN_CUR(
			ITEM_ID_V		ic_item_mst.item_id%TYPE,
		        LOT_ID_V		ic_lots_mst.lot_id%TYPE )
		IS
			SELECT nvl(max(trans_id),0) from ic_tran_cmp_vw1
			where item_id = item_id_v
                        and   lot_id  = lot_id_v
                        and   doc_type = 'GRDI'
                        and   reason_code = fnd_profile.value('PMI$REASON_CODE');
         begin
                if (item_id_vi = PKG_VAR_ITEM_ID_V AND
                    LOT_ID_VI = PKG_VAR_LOT_ID_V) then
                    return PKG_VAR_QC_GRADE_V;
                end if;

                IF NOT GRADE_CHANGE_TRAN_CUR%ISOPEN THEN
			OPEN GRADE_CHANGE_TRAN_CUR(ITEM_ID_VI,LOT_ID_VI);
		END IF;

		FETCH GRADE_CHANGE_TRAN_CUR INTO trans_id_v;
		IF trans_id_v = 0 THEN
                   SELECT QC_GRADE into qc_grade_v
                   from ic_tran_cmp_vw1 where trans_id = trans_id_vi;
                else
                    SELECT QC_GRADE into qc_grade_v
                    from ic_tran_cmp_vw1 where trans_id = trans_id_v;
		end if;

                    PKG_VAR_ITEM_ID_V := item_id_vi;
                    PKG_VAR_LOT_ID_V := lot_id_vi;
                    PKG_VAR_qc_grade_v := qc_grade_v;
                return qc_grade_v;

        end FIND_PROD_GRADE;

    FUNCTION NO_OF_SAMPLES_TAKEN(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	NO_OF_SAMPLES_V	INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V1 then
                   return PKG_VAR_NO_OF_SAMPLES_V;
                end if;

                select count(*) into NO_OF_SAMPLES_v from qc_smpl_mst
                where batch_id = BATCH_ID_VI;

                PKG_VAR_BATCH_ID_V1 := BATCH_ID_vi;
                PKG_VAR_NO_OF_SAMPLES_V := NO_OF_SAMPLES_v;

                return NO_OF_SAMPLES_V;
     end NO_OF_SAMPLES_TAKEN;

 FUNCTION NO_OF_SAMPLES_COMPLETE(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	Complet_SAMPLES_V	INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V4 then
                   return PKG_VAR_NO_OF_SMPL_CMPLT_V;
                end if;

                select count(*) into COMPLET_SAMPLES_v from qc_smpl_mst
                where batch_id = BATCH_ID_VI
                and sample_status in ('ACCEPT','REJECT');

                PKG_VAR_BATCH_ID_V4 := BATCH_ID_vi;
                PKG_VAR_NO_OF_SMPL_CMPLT_V := COMPLET_SAMPLES_v;

                return COMPLET_SAMPLES_V;
     end NO_OF_SAMPLES_COMPLETE;

   FUNCTION NO_OF_SAMPLES_PASSED(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	PASSED_SAMPLES_V  INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V2 then
                   return PKG_VAR_PASSED_SAMPLES_V;
                end if;

                select count(*) into PASSED_SAMPLES_V from qc_smpl_mst
                where batch_id = BATCH_ID_VI
                and sample_status = 'ACCEPT';

                PKG_VAR_BATCH_ID_V2 := BATCH_ID_vi;
                PKG_VAR_PASSED_SAMPLES_V := PASSED_SAMPLES_v;

                return PASSED_SAMPLES_V;
     end NO_OF_SAMPLES_PASSED;

    FUNCTION NO_OF_TIMES_ADJUSTED(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	ADJUST_BATCH_V	INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V3 then
                   return PKG_VAR_ADJUST_BATCH_V;
                end if;

                select count(distinct to_char(item_id)||to_char(TRANS_DATE,'dd/mm/yy hh24:mi:ss'))
                       into ADJUST_BATCH_V
                from ic_tran_cmp_vw1
                where doc_id = BATCH_ID_VI
                and doc_type = 'PROD'
                and   reason_code = fnd_profile.value('PMI$REASON_CODE_BTCH_ADJ');

                PKG_VAR_BATCH_ID_V3 := BATCH_ID_vi;
                PKG_VAR_ADJUST_BATCH_V := ADJUST_BATCH_v;

                return ADJUST_BATCH_v;
     end NO_OF_TIMES_ADJUSTED;


FUNCTION INGREDIENT_VALUE(BATCH_ID_VI IN INTEGER , ITEM_ID_VI INTEGER, LINE_NO_VI INTEGER,SOURCE IN VARCHAR2) RETURN NUMBER
     is
            INGREDIENT_VALUE_V	NUMBER := 0;
     L_ITEM_VALUE NUMBER:=0;
     L_TOTAL_BATCH_OUT_VALUE NUMBER:=0;
     Begin
     IF SOURCE = 'ACTUAL' THEN
         /* Calculate Totla Ingredient Usage Value */
          SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.ACTUAL_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,
                  BtchHdr.ACTUAL_CMPLT_DATE))
          into    INGREDIENT_VALUE_V
          FROM
                  PM_BTCH_HDR  BtchHdr,
                  PM_MATL_DTL  BtchDtl,
    	            IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          AND BtchDtl.LINE_TYPE=-1;

          /* Calculate Item Output Value */
          SELECT  gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.ACTUAL_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,BtchHdr.ACTUAL_CMPLT_DATE)
          into    L_ITEM_VALUE
          FROM
                  PM_BTCH_HDR  BtchHdr,
                  PM_MATL_DTL  BtchDtl,
    	            IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = Itemmst.ITEM_ID
          AND BtchDtl.LINE_TYPE=1
          AND BtchDtl.ITEM_ID=ITEM_ID_VI
          AND BtchDtl.LINE_NO=LINE_NO_VI;

          /*Calculate Total Batch Out Put Value */
          SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.ACTUAL_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,
                  DECODE(BtchHdr.BATCH_STATUS,3,BtchHdr.ACTUAL_CMPLT_DATE,
                                              4,BtchHdr.ACTUAL_CMPLT_DATE,
                                                BtchHdr.EXPCT_CMPLT_DATE)))
          into    L_TOTAL_BATCH_OUT_VALUE
          FROM
                  PM_BTCH_HDR  BtchHdr,
                  PM_MATL_DTL  BtchDtl,
    	          IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          AND BtchDtl.LINE_TYPE=1;
          IF L_TOTAL_BATCH_OUT_VALUE = 0 THEN
             INGREDIENT_VALUE_V:=0;
          ELSE
             INGREDIENT_VALUE_V:=INGREDIENT_VALUE_V*(l_ITEM_VALUE/L_TOTAL_BATCH_OUT_VALUE);
          END IF;
     ELSIF SOURCE='PLAN' THEN
      SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.PLAN_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,
                  DECODE(BtchHdr.BATCH_STATUS,3,BtchHdr.ACTUAL_CMPLT_DATE,
                                              4,BtchHdr.ACTUAL_CMPLT_DATE,
                                                BtchHdr.EXPCT_CMPLT_DATE)))
          into    INGREDIENT_VALUE_V
          FROM
                  PM_BTCH_HDR  BtchHdr,
                  PM_MATL_DTL  BtchDtl,
    	          IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          AND BtchDtl.LINE_TYPE=-1;
      END IF;
          return INGREDIENT_VALUE_V;
    end INGREDIENT_VALUE;

FUNCTION BYPRODUCT_VALUE(BATCH_ID_VI IN INTEGER, SOURCE IN VARCHAR2) RETURN NUMBER
     is
         	BYPRODUCT_VALUE_V	NUMBER := 0;
     Begin
         IF SOURCE = 'ACTUAL' THEN
          	SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
            	      BtchDtl.ACTUAL_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  	BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,BtchHdr.ACTUAL_CMPLT_DATE))
          		into  BYPRODUCT_VALUE_V
          	FROM
                  	PM_BTCH_HDR  BtchHdr,
                  	PM_MATL_DTL  BtchDtl,
    	       	   	IC_ITEM_MST  ItemMst
          	WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          	AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          	AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          	AND BtchDtl.LINE_TYPE=2;
         ELSIF SOURCE = 'PLAN' THEN
 		SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
            	      BtchDtl.PLAN_QTY,ItemMst.ITEM_UM)*OPI_OPM_COMMON_PKG.OPMCO_GET_COST(
                  	BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,
                        DECODE(BtchHdr.BATCH_STATUS,3,BtchHdr.ACTUAL_CMPLT_DATE,
                                              4,BtchHdr.ACTUAL_CMPLT_DATE,
                                                BtchHdr.EXPCT_CMPLT_DATE)))
          		into  BYPRODUCT_VALUE_V
          	FROM
                  	PM_BTCH_HDR  BtchHdr,
                  	PM_MATL_DTL  BtchDtl,
    	       	   	IC_ITEM_MST  ItemMst
          	WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          	AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          	AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          	AND BtchDtl.LINE_TYPE=2;
         END IF;

          return BYPRODUCT_VALUE_V;
    end BYPRODUCT_VALUE;


 FUNCTION SCHD_WORK_DAYS(BATCH_ID_VI IN INTEGER , START_DATE IN DATE, CMPLT_DATE IN DATE) RETURN NUMBER
     is
         	START_DATE_V	PM_BTCH_HDR.ACTUAL_START_DATE%type;
                CMPLT_DATE_V	PM_BTCH_HDR.ACTUAL_CMPLT_DATE%type;
                NO_DAYS_V               INTEGER := 0;
                Count1_V                INTEGER := 0;
                Count2_V                INTEGER := 0;
                batch_time_v            INTEGER := 0;
                PLANT_CODE_V1           PM_BTCH_HDR.PLANT_CODE%type;
                SCHEDULE_VI             ps_schd_hdr.schedule%type;
                SHIFT_START_V           INTEGER := 0;
                SHIFT_END_V             INTEGER := 0;
                SHIFT_DURATION_V        INTEGER;
                start_sec               INTEGER;
                end_sec                 INTEGER;
                prev_end_sec            INTEGER := 0;
                batch_hrs_v             NUMBER;
                batch_days_v            NUMBER;
                Batch_day_V1		DATE;

                CURSOR shop_cal_CUR(
			      SCHEDULE_V		PS_SCHD_HDR.SCHEDULE%TYPE,
                        PLANT_CODE_V      PM_BTCH_HDR.PLANT_CODE%type,
		            Batch_day_V		DATE )
		IS
			SELECT shift_start,shift_duration
                        FROM   ps_schd_dtl sd, ps_schd_hdr sh,
                               mr_shcl_dtl sc, mr_shdy_dtl sl
                        WHERE  sd.schedule_id = sh.schedule_id
                        AND    sd.Calendar_id = sc.Calendar_id
                        AND    sc.shopday_no  = sl.shopday_no
                        AND    sh.schedule    = SCHEDULE_V
                        AND    sd.orgn_code   = PLANT_CODE_V
                        AND    trunc(sc.calendar_date) = trunc(batch_day_V)
                        order by shift_start;

     Begin
                SELECT PLANT_CODE
                       into PLANT_CODE_V1
                from pm_btch_hdr
                where  batch_id = batch_id_vi;
                /* Assign the Parameters */
                START_DATE_V:=START_DATE;
                CMPLT_DATE_V:=CMPLT_DATE;
                SCHEDULE_VI := fnd_profile.value('GEMMS_DEFAULT_SCHEDULE');

                select count(*) into count2_v
                from   ps_schd_dtl sd, ps_schd_hdr sh
                where  sd.schedule_id = sh.schedule_id
                and    sh.schedule    = SCHEDULE_VI
                AND    sd.orgn_code   = PLANT_CODE_V1;

                if count2_v = 0 then  /* No Calendar Found */
                   Batch_days_v := (CMPLT_DATE_V - START_DATE_V);
                   return Batch_days_v;
                end if;

                no_days_v := trunc(CMPLT_DATE_V) - trunc(START_DATE_V);
                start_sec := 3600*to_char(START_DATE_V,'hh24') +
                             60*to_char(START_DATE_V,'mi') +
                             to_char(START_DATE_V,'ss');
                End_sec   := 3600*to_char(CMPLT_DATE_V,'hh24') +
                             60*to_char(CMPLT_DATE_V,'mi') +
                             to_char(CMPLT_DATE_V,'ss');

                LOOP
                     batch_day_v1 := START_DATE_V + count1_v;

                     IF shop_cal_CUR%ISOPEN THEN
                        CLOSE shop_cal_CUR;
                     end if;

			OPEN shop_cal_CUR(SCHEDULE_VI,PLANT_CODE_V1,batch_day_v1);

                     LOOP
		        FETCH shop_cal_CUR INTO SHIFT_START_V,SHIFT_DURATION_V;

                        if shop_cal_CUR%NOTFOUND then
                           if (prev_end_sec <=  start_sec and start_sec < 86400) then
                               if (prev_end_sec <=  end_sec and end_sec < 86400) then
                                  if no_days_v = 0 then
                                      Batch_time_v := (end_sec - start_sec);
                                      EXIT;
                                  else
                                     if count1_v = 0 then
                                       Batch_time_v := batch_time_v +(86400 - start_sec);
                                     else
                                         if count1_v = no_days_v then
                                            Batch_time_v := batch_time_v +(end_sec - prev_end_sec);
                                         end if;
                                     end if;
                                  end if;
                               else
                                   if count1_v = 0 then
                                      Batch_time_v := batch_time_v +(86400 - start_sec);
                                   end if;
                               end if;
                            else
                                 if (prev_end_sec <=  end_sec and end_sec < 86400) then
                                     if no_days_v = count1_v then
                                        Batch_time_v := batch_time_v +(end_sec - prev_end_sec);
                                     end if;
                                 end if;
                            end if;
                            EXIT;
                          end if;

                          if (prev_end_sec <=  start_sec and start_sec < SHIFT_START_V) then
                               if (prev_end_sec <= end_sec and end_sec < SHIFT_START_V) then
                                  if no_days_v = 0 then
                                      Batch_time_v := (end_sec - start_sec);

                                      EXIT;
                                  else
                                     if count1_v = 0 then
                                       Batch_time_v := batch_time_v +(SHIFT_START_V - start_sec);
                                     else
                                         if count1_v = no_days_v then
                                           Batch_time_v := batch_time_v +(end_sec - prev_end_sec);
                                         end if;
                                     end if;
                                  end if;
                               else
                                   if count1_v = 0 then
                                      Batch_time_v := batch_time_v +(SHIFT_START_V - start_sec);
                                   end if;
                               end if;
                            else
                                 if (prev_end_sec <=  end_sec and end_sec < SHIFT_START_V) then
                                     if no_days_v = count1_v then
                                        Batch_time_v := batch_time_v +(end_sec - prev_end_sec);
                                     end if;
                                 end if;
                            end if;

                        shift_end_v := SHIFT_START_V + SHIFT_DURATION_V;

                        if (count1_v = 0 and start_sec > SHIFT_START_V) then
                           if start_sec < shift_end_v then
                              Batch_time_v := batch_time_v + (SHIFT_START_V - start_sec);
                           else
                              Batch_time_v := batch_time_v - SHIFT_DURATION_V;
                           end if;
                        end if;

                        if no_days_v = count1_v then    /* Last Day */
                           if End_sec >= shift_end_v then
                                 Batch_time_v := batch_time_v + SHIFT_DURATION_V;
                           else if end_sec > SHIFT_START_V then
                                 Batch_time_v := batch_time_v + SHIFT_DURATION_V -
                                 (shift_end_v - End_sec);
                                end if;
                           end if;
                         else             /* Days in the Middle */
                           Batch_time_v := batch_time_v + SHIFT_DURATION_V;
                         end if;

                           prev_end_sec := shift_end_v;
                       END LOOP;

                       prev_end_sec := 0;
                       count1_v := count1_v + 1;
                       EXIT WHEN count1_v > no_days_v;
                    END LOOP;
                Batch_days_v := Batch_time_v / 3600;
                return Batch_days_v;
     end SCHD_WORK_DAYS;
END OPI_EDW_OPM_PRD_PKG;

/
