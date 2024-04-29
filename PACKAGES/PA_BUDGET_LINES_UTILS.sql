--------------------------------------------------------
--  DDL for Package PA_BUDGET_LINES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_LINES_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPBLUS.pls 120.2 2007/02/06 09:44:54 dthakker noship $
   Start of Comments
   Package name     : PA_BUDGET_LINES_UTILS
   Purpose          : utility API's for Budget Lines table
   NOTE             :
   End of Comments
*/

procedure Populate_Display_Qty
    (p_budget_version_id           IN  NUMBER,
     p_context                     IN  VARCHAR2,
     p_use_temp_table_flag         IN  VARCHAR2 DEFAULT 'N',
     p_resource_assignment_id_tab  IN  SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.pa_num_tbl_type(),
     p_set_disp_qty_null_for_nrbf  IN  VARCHAR2 DEFAULT 'N',
     x_return_status               OUT NOCOPY VARCHAR2);

END pa_budget_lines_utils;



/
