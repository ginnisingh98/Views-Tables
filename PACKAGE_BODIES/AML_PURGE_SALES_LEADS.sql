--------------------------------------------------------
--  DDL for Package Body AML_PURGE_SALES_LEADS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_PURGE_SALES_LEADS" AS
/* $Header: amlslprgb.pls 115.5 2004/02/09 12:13:42 bmuthukr noship $ */
-- Start of Comments
-- Package name     : AML_PURGE_SALES_LEADS
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--   10/17/2003   BMUTHUKR   Created
--   Purpose : For purging the unqualified leads.
--
--   11/24/2003   BMUTHUKR   Modified
--   This program should delete only the unqualifed leads that are not converted to opportunity.
--   Hence adding additional condition in the where clause.
--
--   12/10/2003   BMUTHUKR Modified
--   Added TRUNC in the SELECT statement in the purge_unqualified_leads procedure body to resolve bug 3307084.
--   It is already there in the cursor.
--
--   01/20/2004   BMUTHUKR Modified
--   Included the profile AS_DEFAULT_LEAD_STATUS in the where clause. Rrefer bug 3376658.
--
-- END of Comments


TYPE del_count IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'AML_PURGE_SALES_LEADS';
G_FILE_NAME  CONSTANT VARCHAR2(15) := 'amlslprgb.pls';
G_DEBUG_MODE VARCHAR2(1) := 'Y';
RECS_DELETED del_count;

PROCEDURE AML_Debug(p_flag in number default 2, p_mesg in Varchar2)
IS
BEGIN

   if nvl(g_debug_mode,'N') = 'Y' and p_flag = 2 then
      fnd_file.put(1, substr(p_mesg,1,255));
      fnd_file.new_line(1,1);
   elsif p_flag = 1 then
      fnd_file.put(1, substr(p_mesg,1,255));
      fnd_file.new_line(1,1);
   end if;

END AML_Debug;


PROCEDURE initialize_count IS
BEGIN
   Recs_deleted(1)  := 0;
   Recs_deleted(2)  := 0;
   Recs_deleted(3)  := 0;
   Recs_deleted(4)  := 0;
   Recs_deleted(5)  := 0;
   Recs_deleted(6)  := 0;
--   Recs_deleted(7)  := 0;
   Recs_deleted(8)  := 0;
   Recs_deleted(9)  := 0;
   Recs_deleted(10) := 0;
   Recs_deleted(11) := 0;
END initialize_count;

PROCEDURE write_count IS
l_no_of_rows_deleted  CONSTANT varchar2(100) := ' rows deleted from the table ';
BEGIN
   aml_Debug(1,Recs_deleted(1)||l_no_of_rows_deleted||'AS_ACCESSES_ALL');
   aml_debug(1,Recs_deleted(2)||l_no_of_rows_deleted||'AS_CHANGED_ACCOUNTS_ALL');
   aml_debug(1,Recs_deleted(3)||l_no_of_rows_deleted||'AML_INTERACTION_LEADS');
   aml_debug(1,Recs_deleted(4)||l_no_of_rows_deleted||'AS_SALES_LEADS_LOG');
   aml_debug(1,Recs_deleted(5)||l_no_of_rows_deleted||'AS_SALES_LEAD_CONTACTS');
   aml_debug(1,Recs_deleted(6)||l_no_of_rows_deleted||'AS_SALES_LEAD_LINES');
--   aml_debug(1,Recs_deleted(7)||l_no_of_rows_deleted||'AS_SALES_LEAD_OPPORTUNITY');
   aml_debug(1,Recs_deleted(8)||l_no_of_rows_deleted||'AML_MONITOR_LOG');
   aml_debug(1,Recs_deleted(9)||l_no_of_rows_deleted||'PV_ENTITY_RULES_APPLIED');
   aml_debug(1,Recs_deleted(10)||l_no_of_rows_deleted||'AS_TERRITORY_ACCESSES');
   aml_debug(1,Recs_deleted(11)||l_no_of_rows_deleted||'AS_SALES_LEADS');
END write_count;


PROCEDURE Delete_Unqualified_Leads(P_Id_Tab IN AML_PURGE_SALES_LEADS.Sales_Lead_Id_Tab) IS
BEGIN

   FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
      DELETE
	FROM AS_ACCESSES_ALL
       WHERE Sales_Lead_Id = P_Id_Tab(I);
      Recs_deleted(1) := Recs_deleted(1) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_CHANGED_ACCOUNTS_ALL
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(2) := Recs_deleted(2) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AML_INTERACTION_LEADS
	WHERE Sales_Lead_Id = P_Id_Tab(I);
      Recs_deleted(3) := Recs_deleted(3) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_SALES_LEADS_LOG
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(4) := Recs_deleted(4) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_SALES_LEAD_CONTACTS
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(5) := Recs_deleted(5) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_SALES_LEAD_LINES
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(6) := Recs_deleted(6) + SQL%ROWCOUNT;

    /*FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_SALES_LEAD_OPPORTUNITY
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(7) := Recs_deleted(7) + SQL%ROWCOUNT;*/

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AML_MONITOR_LOG
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(8) := Recs_deleted(8) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM PV_ENTITY_RULES_APPLIED
	WHERE Entity_Id = P_Id_Tab(I);
       Recs_deleted(9) := Recs_deleted(9) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_TERRITORY_ACCESSES
	WHERE Access_Id = P_Id_Tab(I);
       Recs_deleted(10) := Recs_deleted(10) + SQL%ROWCOUNT;

    FORALL I IN P_Id_Tab.FIRST..P_Id_Tab.LAST
       DELETE
	 FROM AS_SALES_LEADS
	WHERE Sales_Lead_Id = P_Id_Tab(I);
       Recs_deleted(11) := Recs_deleted(11) + SQL%ROWCOUNT;

END Delete_Unqualified_Leads;


/*-------------------------------------------------------------------------*
 | PUBLIC ROUTINE
 |  Purge_Unqualified_Leads
 |
 | PURPOSE
 |  The main program to find the unqualified leads and then passes to the
 | private procedure Purge_Unqualified_Leads in the form of Pl/Sql tables.
 |  Concurrent program will call this procedure.
 |
 *-------------------------------------------------------------------------*/
PROCEDURE Purge_Unqualified_Leads(
    errbuf             OUT NOCOPY VARCHAR2,
    retcode            OUT NOCOPY VARCHAR2,
    p_start_date       IN  VARCHAR2,
    p_end_date         IN  VARCHAR2,
    p_debug_mode       IN  VARCHAR2 DEFAULT 'N',
    p_trace_mode       IN  VARCHAR2 DEFAULT 'N') IS

Id_Tab                AML_PURGE_SALES_LEADS.Sales_Lead_Id_Tab;
l_status              boolean;
l_start_date          date;
l_end_date            date;

CURSOR Collect_Sales_Lead_Ids(l_start_date IN date, l_end_date IN date) IS
SELECT Sales_Lead_Id
  FROM As_sales_leads
 WHERE Qualified_Flag = 'N'
   AND TRUNC(Creation_Date) BETWEEN TRUNC(l_start_date) AND TRUNC(l_end_date)
   AND status_code <> fnd_profile.value('AS_LEAD_LINK_STATUS')
   AND status_code = fnd_profile.value('AS_DEFAULT_LEAD_STATUS');

BEGIN
   l_start_date          := to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS');
   l_end_date            := to_date(p_end_date,  'YYYY/MM/DD HH24:MI:SS');
   IF p_trace_mode = 'Y' THEN
      dbms_session.set_sql_trace(TRUE);
   ELSE
      dbms_session.set_sql_trace(FALSE);
   END IF;
   initialize_count;
   G_DEBUG_MODE := P_DEBUG_MODE;

   aml_debug(2,'Purge Sales Leads starts');

   /* First, unqualified the leads that needs to be purged are identified and the sales lead id is taken. This is stored in
      a Pl/Sql  table. Then all the records in child tables like AS_ACCESSES_ALL, AS_SALES_LEAD_LINES and the main
      table AS_SALES_LEADS are deleted. Since the number of records to be purged will be high this is done in batch
      of 10000 records. The Sales Lead Ids which are stored in a Pl/Sql table are then passed to the local procedure
      Delete_Unqualified_Leads. Since this procedure takes sales lead ids in batches of 10000,
      for the remaining records it has be done with a simple select statement.

      For example, if there are 102300 unqualified leads, then this loop will be executed 10 times. There will be
      2300 pending unqualified leads which will be processed in the simple SELECT that immediately follows this cursor.*/

   OPEN Collect_Sales_Lead_Ids(l_start_date, l_end_date);
   aml_debug(2,'Fetching data');
   LOOP

      IF Id_Tab.FIRST IS NOT NULL THEN
	 Id_Tab.DELETE;
      END IF;

      --Records are taken in multiples of 10000.
      FETCH Collect_Sales_Lead_Ids BULK COLLECT INTO Id_Tab LIMIT 10000;

      EXIT WHEN Collect_Sales_Lead_Ids%NOTFOUND; --If   < 10000 records are remaining.
      Delete_Unqualified_Leads(Id_Tab); --Pass the lead nos to the Purge_Qualified_Leads procedure to delete them.

   END LOOP;
   CLOSE Collect_Sales_Lead_Ids;

   --Remaining records to be deleted. So pick sales lead ids for all the remaining records and put it in
   --a Pl/Sql table.
   SELECT Sales_Lead_Id BULK COLLECT
     INTO Id_Tab
     FROM AS_SALES_LEADS
    WHERE Qualified_Flag = 'N'
      AND TRUNC(Creation_Date) BETWEEN TRUNC(l_start_date) AND TRUNC(l_end_date)
      AND status_code <> fnd_profile.value('AS_LEAD_LINK_STATUS')
      AND status_code = fnd_profile.value('AS_DEFAULT_LEAD_STATUS');

   IF Id_Tab.FIRST IS NOT NULL THEN --This should be executed only if atleast there is one record.
      Delete_Unqualified_Leads(Id_Tab);
   END IF;

   COMMIT;
   write_count;
   aml_debug(2,'Purging sales leads completed successfully');

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      aml_debug(2,'Expected error');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      aml_debug(2,'Unexpected error');

   WHEN others THEN
      aml_debug(2,'SQLCODE ' || to_char(SQLCODE) ||
                  ' SQLERRM ' || substr(SQLERRM, 1, 100));

      errbuf := SQLERRM;
      retcode := FND_API.G_RET_STS_UNEXP_ERROR;
      l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);

END Purge_Unqualified_Leads;

END AML_PURGE_SALES_LEADS;

/
