--------------------------------------------------------
--  DDL for Package Body AML_PURGE_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_PURGE_IMPORT_INTERFACE" as
/* $Header: amlsprgb.pls 115.7 2004/03/04 13:02:03 bmuthukr noship $ */
-- Start of Comments
-- Package name     : AML_PURGE_IMPORT_INTERFACE
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--      08/19/2003   BMUTHUKR   Created
--      14/11/2003   BMUTHUKR   Modified. Now using bulk delete to improve the performance.
--      01/20/2004   BMUTHUKR   Implemented the requirements given in bug # 3354412.
--                              Instead of No of days, records are deleted based on the date
--                              range given.
--      04/04/2004   BMUTHUKR   Commented out the statement for deleting the PV_ENTITY_RULES_APPLIED table
--                              As per bug 3481717.
-- END of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'AML_PURGE_IMPORT_INTERFACE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amlsprgb.pls';
G_DEBUG_MODE          VARCHAR2(1) := 'Y';
TYPE del_count IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
RECS_DELETED del_count;

PROCEDURE write_log(p_flag in number default 2,P_mesg in Varchar2)
IS
BEGIN
   if nvl(g_debug_mode,'N') = 'Y' and p_flag = 2 then
      fnd_file.put(1, substr(p_mesg,1,255));
      fnd_file.new_line(1,1);
   elsif p_flag = 1 then
      fnd_file.put(1, substr(p_mesg,1,255));
      fnd_file.new_line(1,1);
   end if;
END write_log;

PROCEDURE initialize_count IS
BEGIN
   Recs_deleted(1)  := 0;
   Recs_deleted(2)  := 0;
   Recs_deleted(3)  := 0;
   Recs_deleted(4)  := 0;
   Recs_deleted(5)  := 0;
   Recs_deleted(6)  := 0;
  -- Recs_deleted(7)  := 0;
   Recs_deleted(8)  := 0;
END initialize_count;

PROCEDURE write_count IS
l_no_of_rows_deleted  CONSTANT varchar2(100) := ' rows deleted from the table ';
BEGIN
   write_log(1,Recs_deleted(1)||l_no_of_rows_deleted||'AS_LEAD_IMPORT_ERRORS');
   write_log(1,Recs_deleted(2)||l_no_of_rows_deleted||'AS_IMP_SL_FLEX');
   write_log(1,Recs_deleted(3)||l_no_of_rows_deleted||'AS_IMP_CNT_ROL_INTERFACE');
   write_log(1,Recs_deleted(4)||l_no_of_rows_deleted||'AS_IMP_CNT_PNT_INTERFACE');
   write_log(1,Recs_deleted(5)||l_no_of_rows_deleted||'AS_IMP_LINES_INTERFACE');
   write_log(1,Recs_deleted(6)||l_no_of_rows_deleted||'AML_INTERACTION_LEADS');
--   write_log(1,Recs_deleted(7)||l_no_of_rows_deleted||'PV_ENTITY_RULES_APPLIED');
   write_log(1,Recs_deleted(8)||l_no_of_rows_deleted||'AS_IMPORT_INTERFACE');
END write_count;

PROCEDURE Delete_Identified_Leads(P_Id_Tab IN AML_PURGE_IMPORT_INTERFACE.Import_Interface_Id_Tab) IS
BEGIN

   -- Lead Import Error table
   FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
      DELETE
	FROM AS_LEAD_IMPORT_ERRORS
       WHERE import_interface_id = P_Id_Tab(I);
      Recs_deleted(1) := Recs_deleted(1) + SQL%ROWCOUNT;

    -- Lead Import Flex table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_IMP_SL_FLEX
        WHERE import_interface_id = P_Id_Tab(I);
       Recs_deleted(2) := Recs_deleted(2) + SQL%ROWCOUNT;

    -- Lead Import Contact Role table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_IMP_CNT_ROL_INTERFACE
        WHERE import_interface_id = P_Id_Tab(I);
      Recs_deleted(3) := Recs_deleted(3) + SQL%ROWCOUNT;

    -- Lead Import Contact Point table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_IMP_CNT_PNT_INTERFACE
        WHERE import_interface_id = P_Id_Tab(I);
       Recs_deleted(4) := Recs_deleted(4) + SQL%ROWCOUNT;

    -- Lead Import Lines table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_IMP_LINES_INTERFACE
        WHERE import_interface_id = P_Id_Tab(I);
       Recs_deleted(5) := Recs_deleted(5) + SQL%ROWCOUNT;

    -- Interaction table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AML_INTERACTION_LEADS
        WHERE import_interface_id = P_Id_Tab(I);
       Recs_deleted(6) := Recs_deleted(6) + SQL%ROWCOUNT;

/*    --PV Entity rules applied
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM PV_ENTITY_RULES_APPLIED
        WHERE entity_id = P_Id_Tab(I)
   	  AND entity = 'RESPONSE';
       Recs_deleted(7) := Recs_deleted(7) + SQL%ROWCOUNT; */

    -- Lead Import Base table
    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_IMPORT_INTERFACE
        WHERE import_interface_id = P_Id_Tab(I);
       Recs_deleted(8) := Recs_deleted(8) + SQL%ROWCOUNT;

END Delete_Identified_Leads;

PROCEDURE Purge_Import_Interface(
    ERRBUF         OUT  NOCOPY VARCHAR2,
    RETCODE        OUT  NOCOPY VARCHAR2,
    P_START_DATE   IN   VARCHAR2,
    P_END_DATE     IN   VARCHAR2,
    P_STATUS       IN   VARCHAR2,
    P_DEBUG_MODE   IN   VARCHAR2 DEFAULT 'N',
    P_TRACE_MODE   IN   VARCHAR2 DEFAULT 'N'
    )
IS
l_wrong_days          CONSTANT varchar2(100) := 'ERROR: Could not purge. Number of days entered is not greater than zero';
l_no_of_rows_deleted  CONSTANT varchar2(100) := ' rows deleted from the table ';
l_status              boolean;
Id_Tab                AML_PURGE_IMPORT_INTERFACE.Import_Interface_Id_Tab;
l_start_date          date;
l_end_date            date;

CURSOR Collect_Imp_Interface_Ids(l_start_date in date,l_end_date in date,p_status in varchar2) IS
   SELECT import_interface_id
     FROM AS_IMPORT_INTERFACE
    WHERE TRUNC(creation_date) BETWEEN TRUNC(l_start_date) AND TRUNC(l_end_date)
      AND load_status = P_STATUS;

BEGIN

   l_start_date          := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
   l_end_date            := to_date(p_end_date,  'YYYY/MM/DD HH24:MI:SS');

   IF p_trace_mode = 'Y' THEN
      dbms_session.set_sql_trace(TRUE);
   ELSE
      dbms_session.set_sql_trace(FALSE);
   END IF;
   G_DEBUG_MODE := P_DEBUG_MODE;

   write_log(2,'Purging import interface starts');

   initialize_count;
   --Since the no of records deleted will be large, bulk delete is used here.
   --Initially the import interface ids of the records that are to be deleted
   --are taken first. These are taken in batches of 10000. These ids are passed
   --to a procedure that deletes the records in import interface and its child
   --tables.
   OPEN Collect_Imp_Interface_Ids(l_start_date,l_end_date, P_status);
   write_log(2,'Fetching data');
   LOOP
      IF Id_Tab.FIRST IS NOT NULL THEN
         Id_Tab.DELETE;
      END IF;
      FETCH Collect_Imp_Interface_Ids BULK COLLECT INTO Id_Tab LIMIT 10000;
      EXIT WHEN Collect_Imp_Interface_Ids%NOTFOUND; --If   < 10000 records are remaining.
      Delete_Identified_Leads(Id_Tab); --Pass the lead nos to the Purge_Qualified_Leads procedure to delete them.
   END LOOP;
   CLOSE Collect_Imp_Interface_Ids;

   --The remaining records to be deleted.
   SELECT import_interface_id BULK COLLECT
     INTO Id_Tab
     FROM AS_IMPORT_INTERFACE
    WHERE TRUNC(creation_date) BETWEEN TRUNC(l_start_date) AND TRUNC(l_end_date)
      AND load_status = P_STATUS;

   IF Id_Tab.FIRST IS NOT NULL THEN --This should be executed only if atleast there is one record.
      Delete_Identified_Leads(Id_Tab);
   END IF;
   COMMIT;
   write_count;
   write_log(2,'Purging import interface completed successfully');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      write_log(2,'Expected error');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      write_log(2,'Unexpected error');

   WHEN others THEN
      write_log(2,'SQLCODE ' || to_char(SQLCODE) ||
                  ' SQLERRM ' || substr(SQLERRM, 1, 100));

      errbuf := SQLERRM;
      retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
END Purge_Import_Interface;

END AML_PURGE_IMPORT_INTERFACE;

/
