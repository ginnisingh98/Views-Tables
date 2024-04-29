--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_TYPE_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_TYPE_M_C" AS
/* $Header: FIIAP03B.pls 120.4 2004/10/05 19:23:23 phu ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_collect_er        varchar2(1);   --Added for Merrill Lynch, 03-DEC-02


 Procedure Push(Errbuf       in out NOCOPY  Varchar2,
                Retcode      in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_dimension_name   Varchar2(30) :='EDW_INV_TYPE_M'  ;
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  IF (Not EDW_COLLECTION_UTIL.setup(l_dimension_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
  END IF;
  FII_AP_INV_TYPE_M_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AP_INV_TYPE_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
   edw_log.put_line( 'The collection range is from '||
        to_char(FII_AP_INV_TYPE_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(FII_AP_INV_TYPE_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------
-- Read in profile option value     --**Added for Merrill Lynch, 03-DEC-02
-- -----------------------------
g_collect_er := NVL(FND_PROFILE.value('FII_COLLECT_ER'),'N');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');

   l_temp_date := sysdate;


        Push_EDW_IVTY_INV_LSTG(FII_AP_INV_TYPE_M_C.g_push_date_range1, FII_AP_INV_TYPE_M_C.g_push_date_range2);
        Push_EDW_IVTY_INV_TYPE_LSTG(FII_AP_INV_TYPE_M_C.g_push_date_range1, FII_AP_INV_TYPE_M_C.g_push_date_range2);


   l_duration := sysdate - l_temp_date;

   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');
-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,null,g_push_date_range1, g_push_date_range2);
commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   FII_AP_INV_TYPE_M_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, FII_AP_INV_TYPE_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

commit;
End;


Procedure Push_EDW_IVTY_INV_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;

    l_stmt VARCHAR2(5000);             -- Added for Merrill Lynch,04-DEC-02
    l_er_stmt varchar2(100) :=NULL;    -- Added for Merrill Lynch,04-DEC-02

BEGIN
   edw_log.put_line('Starting Push_EDW_IVTY_INV_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;

IF (g_collect_er <> 'Y') THEN
     l_er_stmt := ' AND inv_type_fk <> ''EXPENSE REPORT''';   -- Added for Merrill Lynch,04-DEC-02
END IF;

--**  Modified for Merrill Lynch,04-DEC-02
l_stmt := 'Insert Into
    EDW_IVTY_INV_LSTG(
    CANCELLED_DATE,
    CREATION_DATE,
    INSTANCE,
    INV_DP,
    INV_ID,
    INV_NAME,
    INV_PK,
    INV_SOURCE,
    INV_TYPE_FK,
    LAST_UPDATE_DATE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select CANCELLED_DATE,
CREATION_DATE,
substrb(INSTANCE, 1, 40),
substrb(INV_DP, 1, 160),
INV_ID,
substrb(INV_NAME, 1, 30),
substrb(INV_PK, 1, 120),
substrb(INV_SOURCE, 1, 20),
substrb(NVL(INV_TYPE_FK, ''NA_EDW''), 1, 120),
LAST_UPDATE_DATE,
substrb(NAME, 1, 50),
substrb(USER_ATTRIBUTE1, 1, 240),
substrb(USER_ATTRIBUTE2, 1, 240),
substrb(USER_ATTRIBUTE3, 1, 240),
substrb(USER_ATTRIBUTE4, 1, 240),
substrb(USER_ATTRIBUTE5, 1, 240),
    NULL,   /* OPERATION_CODE */
    ''READY''
   from FII_AP_IVTY_INV_LCV
   where last_update_date between :l_date1 and :l_date2'||l_er_stmt;
   --**

   --**  Added for Merrill Lynch,04-DEC-02
   edw_log.debug_line('');
   edw_log.debug_line(l_stmt);
   execute immediate l_stmt using l_date1,l_date2;
   --**

   l_rows_inserted := sql%rowcount;

   edw_log.debug_line('Inserted '|| l_rows_inserted ||' rows into EDW_IVTY_INV_LSTG table');    -- Added for Merrill Lynch,04-DEC-02

   g_row_count := g_row_count + l_rows_inserted ;
   edw_log.put_line('Commiting records for EDW_IVTY_INV_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_IVTY_INV_LSTG');
 Exception When others then
   raise;
commit;
END;


Procedure Push_EDW_IVTY_INV_TYPE_LSTG(p_from_date IN date, p_to_date IN DATE) IS
    l_date1 DATE;
    l_date2 DATE;
    l_rows_inserted NUMBER :=0;

    l_stmt VARCHAR2(5000);                 -- Added for Merrill Lynch,04-DEC-02
    l_er_stmt VARCHAR2(100) := NULL;       -- Added for Merrill Lynch,04-DEC-02

BEGIN
   edw_log.put_line('Starting Push_EDW_IVTY_INV_TYPE_LSTG');
l_date1 := p_from_date;
l_date2 := p_to_date;

IF (g_collect_er <> 'Y') THEN               -- Added for Merrill Lynch,04-DEC-02
    l_er_stmt := ' WHERE inv_type_pk <> ''EXPENSE REPORT''';
END IF;

--**  Modified for Merrill Lynch,04-DEC-02
l_stmt := ' Insert Into
    EDW_IVTY_INV_TYPE_LSTG(
    ALL_FK,
    CREATION_DATE,
    DESCRIPTION,
    INSTANCE,
    INV_TYPE,
    INV_TYPE_DP,
    INV_TYPE_PK,
    LAST_UPDATE_DATE,
    NAME,
    USER_ATTRIBUTE1,
    USER_ATTRIBUTE2,
    USER_ATTRIBUTE3,
    USER_ATTRIBUTE4,
    USER_ATTRIBUTE5,
    OPERATION_CODE,
    COLLECTION_STATUS)
   select     NVL(ALL_FK, ''NA_EDW''),
CREATION_DATE,
substrb(DESCRIPTION, 1, 50),
substrb(INSTANCE, 1, 40),
substrb(INV_TYPE, 1, 80),
substrb(INV_TYPE_DP, 1, 160),
substrb(INV_TYPE_PK, 1, 120),
LAST_UPDATE_DATE,
substrb(NAME, 1, 50),
substrb(USER_ATTRIBUTE1, 1, 240),
substrb(USER_ATTRIBUTE2, 1, 240),
substrb(USER_ATTRIBUTE3, 1, 240),
substrb(USER_ATTRIBUTE4, 1, 240),
substrb(USER_ATTRIBUTE5, 1, 240),
    NULL,   /* OPERATION_CODE */
    ''READY''
   from FII_AP_IVTY_INV_TYPE_LCV'||l_er_stmt;
   --**

   --**  Added for Merrill Lynch,04-DEC-02
   edw_log.debug_line('');
   edw_log.debug_line(l_stmt);
   execute immediate l_stmt;

   edw_log.debug_line('Inserted '||sql%rowcount||' rows into EDW_IVTY_INV_TYPE_LSTG table');
   --**

   edw_log.put_line('Commiting records for EDW_IVTY_INV_TYPE_LSTG');
commit;

   edw_log.put_line('Completed Push_EDW_IVTY_INV_TYPE_LSTG');
 Exception When others then
   raise;
commit;
END;
End FII_AP_INV_TYPE_M_C;

/
