--------------------------------------------------------
--  DDL for Package Body FII_PA_UOM_CONV_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PA_UOM_CONV_F_C" AS
/* $Header: FIIPA12B.pls 120.1 2002/11/22 20:22:25 svermett ship $ */

 g_debug_flag  VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         	    Number:=0;
 g_exception_msg     	    varchar2(2000):=Null;

 Procedure Push(Errbuf       in out nocopy  Varchar2,
                Retcode      in out nocopy  Varchar2,
                p_from_date  IN      Varchar2,
                p_to_date    IN      Varchar2) IS

 l_fact_name   		Varchar2(30) :='OPI_EDW_UOM_CONV_FSTG';
 l_date1                Date:=Null;
 l_date2                Date:=Null;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------

 l_instance_code	edw_local_instance.instance_code%type :=
				edw_instance.get_code;
 l_from_date		date;
 l_to_date		date;

Begin

  Errbuf :=NULL;
  Retcode:=0;

  IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
    errbuf := fnd_message.get;
    raise_application_error(-20000,'Error in SETUP: ' || errbuf);
  END IF;

-- Date processing

  l_from_date := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  l_to_date := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');

  g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);

  g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);

  l_date1 := g_push_date_range1;
  l_date2 := g_push_date_range2;

  if g_debug_flag = 'Y' then
    edw_log.put_line( 'The collection range is from '||
          to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
          to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
    edw_log.put_line(' ');
  end if;

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

  if g_debug_flag = 'Y' then
     edw_log.put_line(' ');
     edw_log.put_line('Pushing data');
  end if;

  l_temp_date := sysdate;

Insert Into OPI_EDW_UOM_CONV_FSTG@EDW_APPS_TO_WH
(
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
  CLASS_CONVERSION_FLAG
)
select
  'PA-' || lookup_code,                  -- BASE_UOM,
  1,                                     -- CONVERSION_RATE,
  null,                                  -- EDW_BASE_UOM_FK,
  null,                                  -- EDW_CONVERSION_RATE,
  null,                                  -- EDW_UOM_FK,
  NVL(l_instance_code,'NA_EDW'),         -- INSTANCE_FK,
  0,                                     -- INVENTORY_ITEM_ID,
  'PA-' || lookup_code,                  -- UOM,
  'STANDARD-PA-' || lookup_code || '-' ||
     l_instance_code,			 -- UOM_CONV_PK,
  null, null, null, null, null, null, null,
  null, null, null, null, null, null, null, null,
  'NA_EDW',
  'NA_EDW',
  'NA_EDW',
  'NA_EDW',
  'NA_EDW',
  null, null, null, null, null,
  NULL,
  'NOT-COLLECTIBLE',
  'N'
from PA_LOOKUPS@APPS_TO_APPS
where lookup_type = 'UNIT'
and   last_update_date between l_date1 and l_date2;

  l_rows_inserted := nvl(sql%rowcount,0);
  l_duration := sysdate - l_temp_date;

  if g_debug_flag = 'Y' then
     edw_log.put_line('Inserted ' || to_char(l_rows_inserted) ||
           ' rows into the staging table');
     edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
     edw_log.put_line(' ');
  end if;

-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

  EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2);

Exception When others then

   Errbuf:=sqlerrm;
   Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg, g_push_date_range1, g_push_date_range2);
   raise;
End;

End FII_PA_UOM_CONV_F_C;

/
