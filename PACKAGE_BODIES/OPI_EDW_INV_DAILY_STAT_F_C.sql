--------------------------------------------------------
--  DDL for Package Body OPI_EDW_INV_DAILY_STAT_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_INV_DAILY_STAT_F_C" AS
/* $Header: OPIMIDSB.pls 120.1 2005/06/07 03:28:17 appldev  $ */
 g_push_from_date          Date:=Null;
 g_push_to_date            Date:=Null;

-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
PROCEDURE  Push(Errbuf      in OUT NOCOPY  Varchar2,
                Retcode     in OUT NOCOPY  Varchar2,
                p_from_date  IN   varchar2,
                p_to_date    IN   varchar2,
		p_org_code   IN	  varchar2 DEFAULT Null) IS

  l_fact_name       VARCHAR2(30) ;
  l_staging_table   VARCHAR2(30) ;
  l_exception_msg   VARCHAR2(2000);
  l_last_push_end_date   date;
  l_sysdate              date;
  l_row_count            number;
  l_row_pushed           number;

  l_from_date       DATE ;
  l_to_date         DATE ;

  l_global_currency_code VARCHAR2(30);
  l_rate_type            VARCHAR2(30);
  l_prev_org_id          NUMBER;
  l_conv_rate            NUMBER;
  l_base_currency_code   VARCHAR2(40);
  l_trx_date             DATE;
  l_org_conv_rate_flag   BOOLEAN ;
  l_global_conv_rate_flag BOOLEAN ;

  CURSOR l_org_date_csr IS
     SELECT organization_id, trx_date
       FROM opi_ids_push_log
       WHERE push_flag = 1
       GROUP BY organization_id, trx_date;

  currency_not_exist   EXCEPTION;
  currency_conv_rate_not_exist  EXCEPTION;

  CURSOR get_uom_data_cursor IS
   select BASE_UOM, INVENTORY_ITEM_ID,
          EDW_UTIL.get_edw_base_uom(BASE_UOM,INVENTORY_ITEM_ID) EDW_BASE_UOM,
          EDW_UTIL.get_uom_conv_rate(BASE_UOM,INVENTORY_ITEM_ID) EDW_Uom_Conv_Rate
   from
         opi_ids_push_log
   where
         base_uom is not null and
         push_flag = 1
   group by
         BASE_UOM,INVENTORY_ITEM_ID;

BEGIN
   --dbms_output.put_line('start of push ' || to_char(Sysdate, 'hh24:mi:ss') );
  l_fact_name         :='OPI_EDW_INV_DAILY_STAT_F';
  l_staging_table   :='OPI_EDW_INV_DAILY_STAT_FSTG';
  l_exception_msg   :=Null;
  l_row_count            := 0;
  l_row_pushed       := 0;
  l_from_date       := NULL;
  l_to_date         := NULL;
  l_org_conv_rate_flag    := TRUE;
  l_global_conv_rate_flag  := TRUE;
   Errbuf :=NULL;
   Retcode:=0;

   edw_log.put_line(' ');
   edw_log.put_line('call EDW_COLLECTION_UTIL ');
   --dbms_output.put_line(p_from_date);
   --dbms_output.put_line(p_to_date);
   -- -------------------------------------------
   -- call edw_collection_util.setup
   -- -------------------------------------------
   IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name,
                                     l_staging_table,
                                     l_staging_table,
                                     l_exception_msg)) THEN
     errbuf := fnd_message.get;
     Return;
   END IF;

   -- -----------------------------------------------------
   -- figure out the process start/end date
   -- Append 23:59:59 to the to_date incase it's passed
   -- -----------------------------------------------------
   l_from_date  := To_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
   l_to_date    := To_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');

   /*
   IF l_to_date IS NOT NULL THEN
      l_to_date := to_date(p_to_date||' 23:59:59','YYYY/MM/DD HH24:MI:SS');
   END IF;
   */


--  Start of code change for bug fix 2140267.
  -- --------------------------------------------
  -- Taking care of cases where the input from/to
  -- date is NULL.
  -- --------------------------------------------

   l_from_date := nvl(l_from_date,
          EDW_COLLECTION_UTIL.G_local_last_push_start_date -
          EDW_COLLECTION_UTIL.g_offset);
   l_to_date := nvl(l_to_date,
          EDW_COLLECTION_UTIL.G_local_curr_push_start_date);


  --  End of code change for bug fix 2140267.







   --  --------------------------------------------------------
   --  call opi_extract_ids: This program will process the WIP and INV
   --  Transactions by organization. It will then insert/update the records
   --  in the opi_ids_push_log.
   --
   --  --------------------------------------------------------
   --dbms_output.put_line(' ');
   --dbms_output.put_line('call opi_extract_ids ');


   edw_log.put_line(' ');
   edw_log.put_line('call opi_extract_ids ');

   OPIMPXWI.opi_extract_ids(l_from_date,l_to_date,p_org_code);


   --dbms_output.put_line('after extract ids ' || to_char(Sysdate, 'hh24:mi:ss') );
   select sum(1) INTO l_row_pushed
     from opi_ids_push_log
    where push_flag=1
      and rownum < 2;

   BEGIN
      SELECT warehouse_currency_code, rate_type
	INTO l_global_currency_code, l_rate_type
	FROM EDW_LOCAL_SYSTEM_PARAMETERS;
   EXCEPTION
      WHEN OTHERS THEN
	 RAISE currency_not_exist;
   END;


   if (l_row_pushed > 0) THEN
   --  --------------------------------------------------------
   --  populate opi_ids_push_log.edw_base_uom, edw_conv_rate
   --  --------------------------------------------------------
      FOR l_org_date IN l_org_date_csr LOOP



	 IF l_org_date_csr%rowcount = 1 THEN
	    SELECT edw_util.get_base_currency(l_org_date.organization_id)
	      INTO l_base_currency_code
	      FROM dual;

	    l_prev_org_id := l_org_date.organization_id;

	    --dbms_output.put_line(' in l_org_date, ' || l_org_date.organization_id || l_org_date.trx_date );
	 END IF;

	 IF l_prev_org_id <> l_org_date.organization_id THEN
	    SELECT edw_util.get_base_currency(l_org_date.organization_id)
	      INTO l_base_currency_code
	      FROM dual;

	    l_prev_org_id := l_org_date.organization_id;
	    l_org_conv_rate_flag := TRUE;

	    -- dbms_output.put_line(' in l_org_date, ' || l_org_date.organization_id || l_org_date.trx_date );
	 END IF;

	 BEGIN
	    SELECT
	      GL_CURRENCY_API.get_closest_rate(l_base_currency_code,
					       l_global_currency_code,
					       l_org_date.trx_date,
					       l_rate_type,
					       1000 )
	      INTO l_conv_rate
	      FROM dual;
	 EXCEPTION
	    WHEN OTHERS THEN
	       l_trx_date := l_org_date.trx_date;

	       edw_log.put_line ('No conversion rate existed for conversion from '
				 || l_base_currency_code || ' to ' ||
				 l_global_currency_code || ' in organization_id ' ||
				 l_prev_org_id || ' on ' || To_char( l_trx_date, 'dd/mm/yyyy') );

	       l_org_conv_rate_flag := FALSE;
	       l_global_conv_rate_flag := FALSE;
	       --     dbms_output.put_line('No conversion rate existed for conversion from '
	       --	 || l_base_currency_code || ' to ' ||
	       --        l_global_currency_code || ' in organization_id ' ||
	       --        l_prev_org_id || ' on ' || To_char( l_trx_date, 'dd/mm/yyyy') );
	 END;

	 IF l_org_conv_rate_flag THEN
	    UPDATE opi_ids_push_log
	      SET base_currency_code = l_base_currency_code,
	      edw_conv_rate = l_conv_rate
	      WHERE organization_id = l_org_date.organization_id
	      AND trx_date = l_org_date.trx_date
	      AND push_flag = 1;
--dbms_output.put_line('after update count is ' || SQL%rowcount );

	 END IF;

      END LOOP;
--dbms_output.put_line('after edw_conv_rate ' || to_char(Sysdate, 'hh24:mi:ss'));
   -- ---------------------------------------------------------
   -- Get UOMs and Conversion Rates
   -- ---------------------------------------------------------

      FOR each_uom_data_record IN get_uom_data_cursor LOOP
	 Update opi_ids_push_log
	   SET
           EDW_Base_UOM = each_uom_data_record.EDW_Base_UOM,
           EDW_uom_Conv_Rate = each_uom_data_record.EDW_uom_Conv_Rate
	   where
           push_flag = 1 and
           BASE_UOM = each_uom_data_record.BASE_UOM and
           INVENTORY_ITEM_ID = each_uom_data_record.INVENTORY_ITEM_ID;
      END LOOP;

--dbms_output.put_line('after uom conv ' || to_char(Sysdate, 'hh24:mi:ss'));

      COMMIT;
   --  --------------------------------------------------------
   --  Insert into the local staging table
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Insert into the local staging table');

     INSERT INTO opi_edw_inv_daily_stat_fstg(
      AVG_INT_QTY
     ,AVG_INT_VAL_B
     ,AVG_INT_VAL_G
     ,AVG_ONH_QTY
     ,AVG_ONH_VAL_B
     ,AVG_ONH_VAL_G
     ,AVG_WIP_QTY
     ,AVG_WIP_VAL_B
     ,AVG_WIP_VAL_G
     ,BASE_CURRENCY_FK
     ,BASE_UOM_FK
     ,BEG_INT_QTY
     ,BEG_INT_VAL_B
     ,BEG_INT_VAL_G
     ,BEG_ONH_QTY
     ,BEG_ONH_VAL_B
     ,BEG_ONH_VAL_G
     ,BEG_WIP_QTY
     ,BEG_WIP_VAL_B
     ,BEG_WIP_VAL_G
     ,COMMODITY_CODE
     ,COST_GROUP
     ,CREATION_DATE
     ,END_INT_QTY
     ,END_INT_VAL_B
     ,END_INT_VAL_G
     ,END_ONH_QTY
     ,END_ONH_VAL_B
     ,END_ONH_VAL_G
     ,END_WIP_QTY
     ,END_WIP_VAL_B
     ,END_WIP_VAL_G
     ,FROM_ORG_QTY
     ,FROM_ORG_VAL_B
     ,FROM_ORG_VAL_G
     ,INSTANCE_FK
     ,INV_ADJ_QTY
     ,INV_ADJ_VAL_B
     ,INV_ADJ_VAL_G
     ,INV_DAILY_STATUS_PK
     ,INV_ORG_FK
     ,ITEM_ORG_FK
     ,ITEM_STATUS
     ,ITEM_TYPE
     ,LAST_UPDATE_DATE
     ,LOCATOR_FK
     ,LOT_FK
     ,NETTABLE_FLAG
     ,PO_DEL_QTY
     ,PO_DEL_VAL_B
     ,PO_DEL_VAL_G
     ,PRD_DATE_FK
     ,TOTAL_REC_QTY
     ,TOTAL_REC_VAL_B
     ,TOTAL_REC_VAL_G
     ,TOT_CUST_SHIP_QTY
     ,TOT_CUST_SHIP_VAL_B
     ,TOT_CUST_SHIP_VAL_G
     ,TOT_ISSUES_QTY
     ,TOT_ISSUES_VAL_B
     ,TOT_ISSUES_VAL_G
     ,TO_ORG_QTY
     ,TO_ORG_VAL_B
     ,TO_ORG_VAL_G
     ,TRX_DATE_FK
     ,USER_ATTRIBUTE1
     ,USER_ATTRIBUTE10
     ,USER_ATTRIBUTE11
     ,USER_ATTRIBUTE12
     ,USER_ATTRIBUTE13
     ,USER_ATTRIBUTE14
     ,USER_ATTRIBUTE15
     ,USER_ATTRIBUTE2
     ,USER_ATTRIBUTE3
     ,USER_ATTRIBUTE4
     ,USER_ATTRIBUTE5
     ,USER_ATTRIBUTE6
     ,USER_ATTRIBUTE7
     ,USER_ATTRIBUTE8
     ,USER_ATTRIBUTE9
     ,USER_FK1
     ,USER_FK2
     ,USER_FK3
     ,USER_FK4
     ,USER_FK5
     ,USER_MEASURE1
     ,USER_MEASURE2
     ,USER_MEASURE3
     ,USER_MEASURE4
     ,USER_MEASURE5
     ,WIP_ASSY_QTY
     ,WIP_ASSY_VAL_B
     ,WIP_ASSY_VAL_G
     ,WIP_COMP_QTY
     ,WIP_COMP_VAL_B
     ,WIP_COMP_VAL_G
     ,WIP_ISSUE_QTY
     ,WIP_ISSUE_VAL_B
     ,WIP_ISSUE_VAL_G
     ,TRX_DATE
     ,PERIOD_FLAG
     ,OPERATION_CODE
     ,COLLECTION_STATUS)
  select
      AVG_INT_QTY
     ,AVG_INT_VAL_B
     ,AVG_INT_VAL_G
     ,AVG_ONH_QTY
     ,AVG_ONH_VAL_B
     ,AVG_ONH_VAL_G
     ,AVG_WIP_QTY
     ,AVG_WIP_VAL_B
     ,AVG_WIP_VAL_G
     ,BASE_CURRENCY_FK
     ,BASE_UOM_FK
     ,BEG_INT_QTY
     ,BEG_INT_VAL_B
     ,BEG_INT_VAL_G
     ,BEG_ONH_QTY
     ,BEG_ONH_VAL_B
     ,BEG_ONH_VAL_G
     ,BEG_WIP_QTY
     ,BEG_WIP_VAL_B
     ,BEG_WIP_VAL_G
     ,COMMODITY_CODE
     ,NVL(COST_GROUP,'NO COST GROUP')
     ,CREATION_DATE
     ,END_INT_QTY
     ,END_INT_VAL_B
     ,END_INT_VAL_G
     ,END_ONH_QTY
     ,END_ONH_VAL_B
     ,END_ONH_VAL_G
     ,END_WIP_QTY
     ,END_WIP_VAL_B
     ,END_WIP_VAL_G
     ,FROM_ORG_QTY
     ,FROM_ORG_VAL_B
     ,FROM_ORG_VAL_G
     ,INSTANCE_FK
     ,INV_ADJ_QTY
     ,INV_ADJ_VAL_B
     ,INV_ADJ_VAL_G
     ,INV_DAILY_STATUS_PK
     ,INV_ORG_FK
     ,ITEM_ORG_FK
     ,ITEM_STATUS
     ,ITEM_TYPE
     ,LAST_UPDATE_DATE
     ,LOCATOR_FK
     ,LOT_FK
     ,NETTABLE_FLAG
     ,PO_DEL_QTY
     ,PO_DEL_VAL_B
     ,PO_DEL_VAL_G
     ,PRD_DATE_FK
     ,TOTAL_REC_QTY
     ,TOTAL_REC_VAL_B
     ,TOTAL_REC_VAL_G
     ,TOT_CUST_SHIP_QTY
     ,TOT_CUST_SHIP_VAL_B
     ,TOT_CUST_SHIP_VAL_G
     ,TOT_ISSUES_QTY
     ,TOT_ISSUES_VAL_B
     ,TOT_ISSUES_VAL_G
     ,TO_ORG_QTY
     ,TO_ORG_VAL_B
     ,TO_ORG_VAL_G
     ,TRX_DATE_FK
     ,USER_ATTRIBUTE1
     ,USER_ATTRIBUTE10
     ,USER_ATTRIBUTE11
     ,USER_ATTRIBUTE12
     ,USER_ATTRIBUTE13
     ,USER_ATTRIBUTE14
     ,USER_ATTRIBUTE15
     ,USER_ATTRIBUTE2
     ,USER_ATTRIBUTE3
     ,USER_ATTRIBUTE4
     ,USER_ATTRIBUTE5
     ,USER_ATTRIBUTE6
     ,USER_ATTRIBUTE7
     ,USER_ATTRIBUTE8
     ,USER_ATTRIBUTE9
     ,USER_FK1
     ,USER_FK2
     ,USER_FK3
     ,USER_FK4
     ,USER_FK5
     ,USER_MEASURE1
     ,USER_MEASURE2
     ,USER_MEASURE3
     ,USER_MEASURE4
     ,USER_MEASURE5
     ,WIP_ASSY_QTY
     ,WIP_ASSY_VAL_B
     ,WIP_ASSY_VAL_G
     ,WIP_COMP_QTY
     ,WIP_COMP_VAL_B
     ,WIP_COMP_VAL_G
     ,WIP_ISSUE_QTY
     ,WIP_ISSUE_VAL_B
     ,WIP_ISSUE_VAL_G
     ,TRX_DATE
     ,PERIOD_FLAG
     ,NULL       -- OPERATION_CODE
     ,'LOCAL READY'
     from opi_edw_opiinv_daily_stat_fcv
       where push_flag=1
       AND edw_conv_rate IS NOT NULL;

   l_row_count := sql%rowcount;

--dbms_output.put_line('after insert into fstg ' || to_char(Sysdate, 'hh24:mi:ss'));


 end if;  -- row_pushed record
   -- --------------------------------------------
   -- No exception raised so far. Call wrapup to transport
   -- data to target database, and insert messages into logs
   -- -----------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Inserted '||nvl(l_row_count,0)||
                    ' rows into the staging table');
   edw_log.put_line(' Calling EDW_COLLECTION_UTIL.wrapup');

   EDW_COLLECTION_UTIL.wrapup(TRUE,
                              l_row_count,
                              l_exception_msg,
                              l_from_date,
                              l_to_date);

   edw_log.put_line(' Calling UPDATE opi_ids_push_log');
--dbms_output.put_line('after wrapup ' || to_char(Sysdate, 'hh24:mi:ss'));
   UPDATE opi_ids_push_log
     SET push_flag=0,
     last_update_date=sysdate
     WHERE push_flag=1
     AND edw_conv_rate IS NOT NULL;

     COMMIT;

     IF NOT l_global_conv_rate_flag THEN
	RAISE currency_conv_rate_not_exist;
     END IF;

--dbms_output.put_line('after push flag = 0 ' || to_char(Sysdate, 'hh24:mi:ss'));
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
     IF opimpxwi.g_org_error THEN
	Errbuf:= 'Please check log file for details.';

	Retcode:= 1; -- completed with warning
     END IF;

EXCEPTION
   WHEN currency_conv_rate_not_exist THEN
      Errbuf:= 'No conversion rate existed. Please check log file for details.';

      Retcode:= 1; -- completed with warning
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line( l_exception_msg);
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 l_from_date, l_to_date);
--dbms_output.put_line('currency_conv_rate_not_exist ' || l_exception_msg);
      --raise;

   WHEN currency_not_exist THEN
      Errbuf:= 'No or too many rows existed in EDW_LOCAL_SYSTEM_PARAMETERS table';

      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line( l_exception_msg);
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 l_from_date, l_to_date);
--dbms_output.put_line('no or too many ' || l_exception_msg);
      raise;
   WHEN OTHERS THEN
      Errbuf:= Sqlerrm;
      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      edw_log.put_line('Other errors');
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
                                 l_from_date, l_to_date);
      raise;


END push;

End OPI_EDW_INV_DAILY_STAT_F_C ;

/
