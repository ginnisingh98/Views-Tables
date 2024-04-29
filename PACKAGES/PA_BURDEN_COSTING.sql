--------------------------------------------------------
--  DDL for Package PA_BURDEN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BURDEN_COSTING" AUTHID CURRENT_USER as
-- /* $Header: PAXCBCAS.pls 120.1.12000000.3 2007/05/07 07:43:13 byeturi ship $ */


TYPE typ_tbl_eiid IS TABLE OF pa_expenditure_items_all.expenditure_item_id%TYPE INDEX BY BINARY_INTEGER;--Bug #5743708
TYPE typ_tbl_cdlln IS TABLE OF pa_cost_distribution_lines_all.line_num%TYPE INDEX BY BINARY_INTEGER;--Bug #5743708

-- Package holds all the burden cost accounting functions and procedures
   -- Procedure to update the current pronect_id in package variable
   PROCEDURE set_current_project_id(x_project_id in number);
   --PRAGMA RESTRICT_REFERENCES(set_current_project_id, WNDS);

   -- function to retrive the current project id
   FUNCTION get_current_project_id RETURN NUMBER;
   --PRAGMA RESTRICT_REFERENCES(get_current_project_id, WNDS, WNPS);
   PROCEDURE set_current_run_id(x_run_id in number);        /*Bug# 2255068*/

   FUNCTION get_current_run_id RETURN pa_cost_distribution_lines_all.burden_sum_source_run_id%TYPE; /*2255068*/
   --PRAGMA RESTRICT_REFERENCES(get_current_run_id, WNDS, WNPS);

   -- bug : 3699045
   -- function to retrive the set sponsored flag for a project id
   PROCEDURE set_current_sponsored_flag(x_project_id in number);
   -- bug : 3699045
   -- function to retrive the current sponsored flag
   FUNCTION get_current_sponsored_flag RETURN varchar2;

   -- Procedure to summarize and create burden expenditure items
   -- Bug# 1171986 Passing end date parameterto create burden
   -- expenditure item

   PROCEDURE create_burden_expenditure_item( p_start_project_number in pa_projects_all.segment1%TYPE,/*2255068*/
                                             p_end_project_number in pa_projects_all.segment1%TYPE, /*2255068*/
                                             x_request_id in number,                               /*2255068*/
                                             x_end_date in varchar2,
                                             status in out NOCOPY number,
                                             stage  in out NOCOPY number,
                                             x_run_id in out NOCOPY number);

   procedure  create_burden_cmt_transaction( status   in out NOCOPY number,
                                              stage    in out NOCOPY number,
                                              x_run_id in out NOCOPY number,
				              x_project_id in number default null); /* bug#2791563 added x_project_id */

   resource_busy exception;
   --pragma exception_init(resource_busy, -00054);

     /*2933915*/
    PROCEDURE  InsBurdenAudit( p_project_id         IN pa_cost_distribution_lines_all.project_id%TYPE,
                               p_request_id         IN  NUMBER ,
                               p_user_id            IN  NUMBER,
                               x_status          IN OUT NOCOPY NUMBER);
    /*2933915*/


PROCEDURE populate_gtemp(p_current_run_id NUMBER, p_project_id NUMBER, x_end_date varchar2);--Bug #5743708

PROCEDURE update_gtemp(l_request_id number); /*added for the bug#5949107*/--Bug #5743708

end PA_BURDEN_COSTING;

 

/
