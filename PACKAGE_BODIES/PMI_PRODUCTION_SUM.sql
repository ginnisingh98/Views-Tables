--------------------------------------------------------
--  DDL for Package Body PMI_PRODUCTION_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMI_PRODUCTION_SUM" AS
/* $Header: PMIPRDAB.pls 115.11 2003/06/03 03:05:30 srpuri ship $ */
  PROCEDURE POPULATE_BATCH_STATUS_SUM (errbuf OUT NOCOPY varchar2,retcode OUT NOCOPY VARCHAR2) IS
l_buffer   varchar2(40);
l_count    number :=0;
    l_table_owner           VARCHAR2(40);

  BEGIN

        delete from pmi_batch_status;
commit;

/* Insert records for Plan Start */
        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '1',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.PLAN_START_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '1',
                        sysdate;

/*Insert records for Plan Complete */
        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '3',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.PLAN_CMPLT_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '3',
                        sysdate;

/* Insert records for Actual Start */

        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '2',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   bh.batch_status > 1
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.ACTUAL_START_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '2',
                        sysdate;

/* Insert records for Actual Complete */
        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '4',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   bh.batch_status > 2
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.ACTUAL_CMPLT_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '4',
                        sysdate;

/* Insert records for Closed */
        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '5',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   bh.batch_status = 4
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.BATCH_CLOSE_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '5',
                        sysdate;


/* Insert records for Cancelled */
        Insert into pmi_batch_status (CO_CODE,
                                      PLANT_CODE,
                                      WHSE_CODE,
                                      FISCAL_YEAR,
                                      PERIOD_NUM,
                                      PERIOD_NAME,
                                      ITEM_ID,
                                      BATCH_STATUS_CODE,
                                      BATCH_COUNT,
                                      LAST_UPDATE_DATE)
               select og.co_code,
                      bh.plant_code,
                      bh.wip_whse_code,
                      cl.period_year,
                      cl.period_num,
                      cl.period_name,
                      bd.item_id,
                      '6',
                      count(*),
                      sysdate
               from gme_batch_header bh, gme_material_details bd, pmi_gl_calendar_v cl,sy_orgn_mst og
               where bh.batch_id = bd.batch_id
               and   bh.batch_status = -1
               and   line_type = 1
               and   bh.plant_CODE    = og.ORGN_CODE
               and   og.CO_CODE    = cl.CO_CODE
               AND trunc(bh.LAST_UPDATE_DATE) between
                         CL.start_date and CL.end_date
               group by og.co_code,
                        bh.plant_code,
                        bh.wip_whse_code,
                        cl.period_year,
                        cl.period_num,
                        cl.period_name,
                        bd.item_id,
                        '6',
                        sysdate;

Commit;
        SELECT TABLE_OWNER INTO l_table_owner
        FROM USER_SYNONYMS
        WHERE SYNONYM_NAME = 'PMI_BATCH_STATUS';
        FND_STATS.GATHER_TABLE_STATS(l_table_owner, 'PMI_BATCH_STATUS');

        exception when others then
          l_buffer :='Summary table Population Failed'||l_count;
            FND_FILE.PUT_LINE(FND_FILE.LOG,l_buffer);

  END POPULATE_BATCH_STATUS_SUM;

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

                select count(*) into NO_OF_SAMPLES_v from GMD_SAMPLES
                where batch_id = BATCH_ID_VI;

                PKG_VAR_BATCH_ID_V1 := BATCH_ID_vi;
                PKG_VAR_NO_OF_SAMPLES_V := NO_OF_SAMPLES_v;

                return NO_OF_SAMPLES_V;
     end NO_OF_SAMPLES_TAKEN;

 FUNCTION NO_OF_SAMPLES_COMPLET(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	Complet_SAMPLES_V	INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V4 then
                   return PKG_VAR_NO_OF_SMPL_CMPLT_V;
                end if;
                Select count(*) into COMPLET_SAMPLES_v
                from GMD_SAMPLES Smp,
                     GMD_EVENT_SPEC_DISP EVT_SPEC_DISP,
                     GMD_SAMPLE_SPEC_DISP SMP_SPEC_DISP
                WHERE SMP.SAMPLING_EVENT_ID = EVT_SPEC_DISP.SAMPLING_EVENT_ID
                  AND EVT_SPEC_DISP.EVENT_SPEC_DISP_ID =  SMP_SPEC_DISP.EVENT_SPEC_DISP_ID
                  AND EVT_SPEC_DISP.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y'
                  AND SMP_SPEC_DISP.DISPOSITION IN ('4A','5AV','6RJ')
                  AND SMP.BATCH_ID = BATCH_ID_VI;

                PKG_VAR_BATCH_ID_V4 := BATCH_ID_vi;
                PKG_VAR_NO_OF_SMPL_CMPLT_V := COMPLET_SAMPLES_v;

                return COMPLET_SAMPLES_V;
     end NO_OF_SAMPLES_COMPLET;

   FUNCTION NO_OF_SAMPLES_PASSED(BATCH_ID_VI IN INTEGER) RETURN INTEGER
     is
         	PASSED_SAMPLES_V  INTEGER := 0;

     Begin
                if BATCH_ID_vi = PKG_VAR_BATCH_ID_V2 then
                   return PKG_VAR_PASSED_SAMPLES_V;
                end if;
                Select count(*) into PASSED_SAMPLES_V
                from GMD_SAMPLES Smp,
                     GMD_EVENT_SPEC_DISP EVT_SPEC_DISP,
                     GMD_SAMPLE_SPEC_DISP SMP_SPEC_DISP
                WHERE SMP.SAMPLING_EVENT_ID = EVT_SPEC_DISP.SAMPLING_EVENT_ID
                  AND EVT_SPEC_DISP.EVENT_SPEC_DISP_ID =  SMP_SPEC_DISP.EVENT_SPEC_DISP_ID
                  AND EVT_SPEC_DISP.SPEC_USED_FOR_LOT_ATTRIB_IND = 'Y'
                  AND SMP_SPEC_DISP.DISPOSITION IN ('4A','5AV')
                  AND SMP.BATCH_ID = BATCH_ID_VI;

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

    FUNCTION SCHD_WORK_HOUR(BATCH_ID_VI IN INTEGER, SCHEDULE_VI IN ps_schd_hdr.schedule%type)
    RETURN NUMBER
     is
         	ACTUAL_START_DATE_V	GME_BATCH_HEADER.ACTUAL_START_DATE%type;
                ACTUAL_CMPLT_DATE_V	GME_BATCH_HEADER.ACTUAL_CMPLT_DATE%type;
                NO_DAYS_V               INTEGER := 0;
                Count1_V                INTEGER := 0;
                Count2_V                INTEGER := 0;
                batch_time_v            INTEGER := 0;
                PLANT_CODE_V1           GME_BATCH_HEADER.PLANT_CODE%type;

                SHIFT_START_V           INTEGER := 0;
                SHIFT_END_V             INTEGER := 0;
                SHIFT_DURATION_V        INTEGER;
                start_sec               INTEGER;
                end_sec                 INTEGER;
                prev_end_sec            INTEGER := 0;
                batch_hrs_v             NUMBER;
                Batch_day_V1		DATE;

                CURSOR shop_cal_CUR(
			SCHEDULE_V		PS_SCHD_HDR.SCHEDULE%TYPE,
                        PLANT_CODE_V            GME_BATCH_HEADER.PLANT_CODE%type,
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
                SELECT PLANT_CODE,ACTUAL_START_DATE,ACTUAL_CMPLT_DATE
                       into PLANT_CODE_V1,ACTUAL_START_DATE_V, ACTUAL_CMPLT_DATE_V
                from gme_batch_header
                where  batch_id = batch_id_vi;

                select count(*) into count2_v
                from   ps_schd_dtl sd, ps_schd_hdr sh
                where  sd.schedule_id = sh.schedule_id
                and    sh.schedule    = SCHEDULE_VI
                AND    sd.orgn_code   = PLANT_CODE_V1;

                if count2_v = 0 then  /* No Calendar Found */
                   Batch_hrs_v := 24*(ACTUAL_CMPLT_DATE_V - ACTUAL_START_DATE_V);
                   return Batch_hrs_v;
                end if;

                no_days_v := trunc(ACTUAL_CMPLT_DATE_V) - trunc(ACTUAL_START_DATE_V);
                start_sec := 3600*to_char(ACTUAL_START_DATE_V,'hh24') +
                             60*to_char(ACTUAL_START_DATE_V,'mi') +
                             to_char(ACTUAL_START_DATE_V,'ss');
                End_sec   := 3600*to_char(ACTUAL_CMPLT_DATE_V,'hh24') +
                             60*to_char(ACTUAL_CMPLT_DATE_V,'mi') +
                             to_char(ACTUAL_CMPLT_DATE_V,'ss');

                LOOP
                     batch_day_v1 := ACTUAL_START_DATE_V + count1_v;

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
                Batch_hrs_v := Batch_time_v / 3600;
                return Batch_hrs_v;
     end SCHD_WORK_HOUR;

FUNCTION PLAN_ING_VALUE(BATCH_ID_VI IN INTEGER) RETURN NUMBER
     is
         	PLAN_ING_VALUE_V	NUMBER := 0;
     Begin
          SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.PLAN_QTY,ItemMst.ITEM_UM)*pmi_common_pkg.PMICO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,BtchHdr.ACTUAL_CMPLT_DATE))
          into    PLAN_ING_VALUE_V
          FROM
                  GME_BATCH_HEADER  BtchHdr,
                  GME_MATERIAL_DETAILS  BtchDtl,
    	          IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          AND BtchDtl.LINE_TYPE=-1;

          return PLAN_ING_VALUE_V;
    end PLAN_ING_VALUE;

FUNCTION ACTUAL_ING_VALUE(BATCH_ID_VI IN INTEGER) RETURN NUMBER
     is
         	ACTUAL_ING_VALUE_V	NUMBER := 0;
     Begin
          SELECT sum(gmicuom.i2uom_cv(BtchDtl.ITEM_ID,0,BtchDtl.ITEM_UM,
                  BtchDtl.ACTUAL_QTY,ItemMst.ITEM_UM)*pmi_common_pkg.PMICO_GET_COST(
                  BtchDtl.ITEM_ID,BtchHdr.WIP_WHSE_CODE,NULL,BtchHdr.ACTUAL_CMPLT_DATE))
          into    ACTUAL_ING_VALUE_V
          FROM
                  GME_BATCH_HEADER  BtchHdr,
                  GME_MATERIAL_DETAILS  BtchDtl,
    	          IC_ITEM_MST  ItemMst
          WHERE BtchHdr.BATCH_ID = BATCH_ID_VI
          AND BtchHdr.BATCH_ID   = BtchDtl.BATCH_ID
          AND BtchDtl.ITEM_ID    = ItemMst.ITEM_ID
          AND BtchDtl.LINE_TYPE=-1;

          return ACTUAL_ING_VALUE_V;
    end ACTUAL_ING_VALUE;

END PMI_PRODUCTION_SUM;

/
