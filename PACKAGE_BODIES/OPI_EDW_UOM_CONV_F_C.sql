--------------------------------------------------------
--  DDL for Package Body OPI_EDW_UOM_CONV_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_UOM_CONV_F_C" AS
/* $Header: OPIUOMCB.pls 120.1 2005/06/07 02:54:59 appldev  $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 Procedure Push(Errbuf       out  NOCOPY Varchar2,
                Retcode      out  NOCOPY Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_fact_name   Varchar2(30) :='OPI_EDW_UOM_CONV_FSTG'  ;
 l_date1                Date:=Null;
 l_date2                Date:=Null;
 l_temp_date                Date:=Null;
 l_temp_date_char	Varchar2(2000) := Null ;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
  errbuf := fnd_message.get;
    Return;
  END IF;
/*
  g_push_date_range1 := nvl(p_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  g_push_date_range2 := nvl(p_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
*/
IF (p_from_date IS NULL) THEN
                OPI_EDW_UOM_CONV_F_C.g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
                EDW_COLLECTION_UTIL.g_offset;
  ELSE
        OPI_EDW_UOM_CONV_F_C.g_push_date_range1 := to_date(p_from_date,
'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
                OPI_EDW_UOM_CONV_F_C.g_push_date_range2 :=
			EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
    IF to_char(to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD') =
			to_char(sysdate,'YYYY/MM/DD') THEN
       OPI_EDW_UOM_CONV_F_C.g_push_date_range2 := to_date(to_char(sysdate,
'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD HH24:MI:SS');
    ELSE
       l_temp_date_char := to_char(to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS'),
	'YYYY/MM/DD');
       OPI_EDW_UOM_CONV_F_C.g_push_date_range2 := to_date(l_temp_date_char||
' 23:59:59', 'YYYY/MM/DD HH24:MI:SS');
    END IF;
END IF ;



l_date1 := g_push_date_range1;
l_date2 := g_push_date_range2;
   edw_log.put_line( 'The collection range is from '||
        to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;
   Insert Into OPI_EDW_UOM_CONV_FSTG@EDW_APPS_TO_WH(
     BASE_UOM,
     CONVERSION_RATE,
     EDW_BASE_UOM_FK,
     EDW_CONVERSION_RATE,
     EDW_UOM_FK,
     INSTANCE_FK,
     INVENTORY_ITEM_ID,
     UOM,
     UOM_CONV_PK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CLASS_CONVERSION_FLAG)
   select
     BASE_UOM,
     CONVERSION_RATE,
     NVL(EDW_BASE_UOM_FK,'NA_EDW'),
     EDW_CONVERSION_RATE,
     NVL(EDW_UOM_FK,'NA_EDW'),
     NVL(INSTANCE_FK,'NA_EDW'),
     INVENTORY_ITEM_ID,
     UOM,
     UOM_CONV_PK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE11,
     USER_ATTRIBUTE12,
     USER_ATTRIBUTE13,
     USER_ATTRIBUTE14,
     USER_ATTRIBUTE15,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     NULL, -- OPERATION_CODE
     'NOT-COLLECTIBLE',
     CLASS_CONVERSION_FLAG
   from OPI_EDW_UOM_CONV_FCV@apps_to_apps
   where last_update_date between l_date1 and l_date2;
   l_rows_inserted := sql%rowcount;
   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Inserted'||to_char(nvl(sql%rowcount,0))||
         ' rows into the staging table');
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, l_exception_msg,
			      OPI_EDW_UOM_CONV_F_C.g_push_date_range1,
			      OPI_EDW_UOM_CONV_F_C.g_push_date_range2);

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,
			      OPI_EDW_UOM_CONV_F_C.g_push_date_range1,
			      OPI_EDW_UOM_CONV_F_C.g_push_date_range2);
    raise;

End;
End OPI_EDW_UOM_CONV_F_C;

/
