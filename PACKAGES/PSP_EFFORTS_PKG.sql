--------------------------------------------------------
--  DDL for Package PSP_EFFORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFFORTS_PKG" AUTHID CURRENT_USER AS
-- $Header: PSPEREFS.pls 115.8 2002/11/18 12:30:46 lveerubh ship $
/***********************************************************************************
**     NAME: psp_efforts_pkg
** CONTENTS: Package Spec And Body  for psp_efforts_pkg
**  PURPOSE: This Package contains two procedures .
**           1. PROCEDURE crt
**              This procedure takes in as input the various input criteria
**              entered by the user during Effort Report Creation. The input
**              criteria are then matched with the actual disbursements of labor
**              charges from the Distribution Lines and the actual efforts based
**              on a person , against all his assignments, for a period range, is
**              summarized and added to Effort Report Tables. The procedure
**              also does lot of bookkeeping like updating Distribution Lines,
**              retrieving GL and POETA values from appropriate tables, checking
**              active element types and so on. This procedure also populates an
**              Error Table for Effort Report Already processed. This procedure
**              is run by Concurrent Manager.
**
**           2. PROCEDURE INIT_WORKFLOW
**              This procedure is to initiate workflow process. This procedure fetches
**              all Report Ids for a given template id and Initiates workflow process
**              for each report id
**
**    NOTES:  Workflow : Added by Venkat.
**    AUTHOR: Abhijit Prasad
**
************************************************************************************
***********************************************************************************/
/*   Variables starting with a_ are input parameter arguments to main FUNCTIONs/PROCEDUREs
**   Function OR variables starting with p_ are PRIVATE Functions OR variables
**   Function OR variables starting with g_ are GLOBAL Functions OR variables
**   Function OR variables starting with t_ are LOCAL Functions OR variables
*/
   ---
   CURSOR g_ssdseo IS
      SELECT schedule_line_id,          --- N(9)
             ---summary_line_id,        --- N(10)
             default_org_account_id,    --- N(9)
             suspense_org_account_id,   --- N(9)
             element_account_id,        --- N(9)
             org_schedule_id            --- N(9)
      FROM psp_distribution_lines;
   g_ssdseo_row  g_ssdseo%ROWTYPE;
   ---
   CURSOR g_gl_poeta IS
      SELECT gl_code_combination_id,
             project_id,
             expenditure_organization_id,
             expenditure_type,
             task_id,
             award_id
      FROM psp_organization_accounts;
   g_poeta_row   g_gl_poeta%ROWTYPE;
   ---
   g_template_row  PSP_EFFORT_REPORT_TEMPLATES%ROWTYPE;
   g_details_row   PSP_EFFORT_REPORT_DETAILS%ROWTYPE;
   g_element_flag  VARCHAR2(1) := 'N';
   g_dist_flag     VARCHAR2(1) := 'N';
   ---
   PROCEDURE crt(errbuf OUT NOCOPY VARCHAR2,
		 retcode OUT NOCOPY NUMBER,
		 a_template_id IN NUMBER,
		 p_business_group_id IN varchar2,
		 p_set_of_books_id IN varchar2);
   ---
   FUNCTION INIT_WORKFLOW(a_template_id IN NUMBER) RETURN NUMBER;
   ---
   PROCEDURE log_errors(template_id1 IN NUMBER,person_id1 IN NUMBER,errmsg VARCHAR2,
                          effort_report_id1 IN NUMBER, version_num1 IN NUMBER);

   ---
   FUNCTION get_gl_description(a_code_combination_id IN NUMBER) RETURN VARCHAR2;
--   PRAGMA RESTRICT_REFERENCES(get_gl_description,WNDS);
   ---

END;

 

/
