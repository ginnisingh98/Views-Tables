--------------------------------------------------------
--  DDL for Package PA_MC_BORRLENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_BORRLENT" AUTHID CURRENT_USER AS
/* $Header: PAMRCBLS.pls 120.0 2005/05/29 22:14:56 appldev noship $ */

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_mc_borrlent.bl_mc_delete
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package during mass delete of cross charge
--                distributions. .
--
--                The procedure deletes the corresponding MRC records
--                of all the dist_line_ids passed in
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------


PROCEDURE bl_mc_delete
	(
	 p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_debug_mode                   IN  boolean
        );

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_mc_borrlent.bl_mc_update
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package during mass update of cross charge
--                distributions.
--
--                The procedure updates the corresponding MRC records
--                of all the dist_line_ids passed in by computing the
--                corresponding amounts for each reporting set of
--                books passed in.  It calls get_mrc_values which
--                does all the calculations
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE bl_mc_update
       (
	 p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
	,p_prvdr_org_id                 IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_rsob_id                      IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_rcurrency_code               IN  PA_PLSQL_DATATYPES.Char15TabTyp
	,p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_line_type                    IN  PA_PLSQL_DATATYPES.Char2TabTyp
	,p_upd_type                     IN  PA_PLSQL_DATATYPES.Char1TabTyp
	,p_expenditure_item_date        IN  PA_PLSQL_DATATYPES.DateTabTyp
	,p_expenditure_item_id          IN  PA_PLSQL_DATATYPES.IDTabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
        ,p_denom_currency_code          IN  PA_PLSQL_DATATYPES.Char15TabTyp
	,p_acct_tp_rate_type            IN  PA_PLSQL_DATATYPES.Char30TabTyp
	,p_acct_tp_exchange_rate        IN  PA_PLSQL_DATATYPES.NumTabTyp
	,p_denom_transfer_price         IN  PA_PLSQL_DATATYPES.NumTabTyp
	,p_cdl_line_num                 IN  PA_PLSQL_DATATYPES.NumTabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
	,p_prvdr_cost_reclass_code      IN  PA_PLSQL_DATATYPES.Char240TabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
	,p_login_id                     IN  NUMBER
	,p_program_id                   IN  NUMBER
	,p_program_application_id       IN  NUMBER
	,p_request_id                   IN  NUMBER
	,p_debug_mode                   IN  boolean
        );

----------------------------------------------------------------------------------
-- Start of comments
--
-- API Name     : pa_mc_borrlent.bl_mc_insert
--
-- Type         : Public
--
-- Pre-reqs     : None
--
-- Function     : This procedure is called from the Distribute Borrowed and Lent
--                Amounts package during mass update of cross charge
--                distributions AND during the MRC upgrade (when a new
--                reporting set of books is added)
--
--                The procedure insrts the corresponding MRC records
--                of all the dist_line_ids passed in by computing the
--                corresponding amounts for each reporting set of
--                books passed in.  It calls get_mrc_values which
--                does all the calculations
--
-- Parameters   : Please see specification below
--
-- Version      : Initial version
--
-- End of comments
----------------------------------------------------------------------------------

PROCEDURE bl_mc_insert
       (
	 p_primary_sob_id               IN  gl_sets_of_books.set_of_books_id%TYPE
	,p_prvdr_org_id                 IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_rsob_id                      IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_rcurrency_code               IN  PA_PLSQL_DATATYPES.Char15TabTyp
	,p_cc_dist_line_id              IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_line_type                    IN  PA_PLSQL_DATATYPES.Char2TabTyp
	,p_expenditure_item_id          IN  PA_PLSQL_DATATYPES.IDTabTyp
	,p_line_num                     IN  PA_PLSQL_DATATYPES.IDTabTyp
        ,p_denom_currency_code          IN  PA_PLSQL_DATATYPES.Char15TabTyp
	,p_acct_tp_rate_type            IN  PA_PLSQL_DATATYPES.Char30TabTyp
	,p_expenditure_item_date        IN  PA_PLSQL_DATATYPES.DateTabTyp
	,p_acct_tp_exchange_rate        IN  PA_PLSQL_DATATYPES.NumTabTyp
	,p_denom_transfer_price         IN  PA_PLSQL_DATATYPES.NumTabTyp
	,p_dist_line_id_reversed        IN  PA_PLSQL_DATATYPES.IDTabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyIDTab
	,p_cdl_line_num                 IN  PA_PLSQL_DATATYPES.NumTabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyNumTab
	,p_prvdr_cost_reclass_code      IN  PA_PLSQL_DATATYPES.Char240TabTyp
			       DEFAULT PA_PLSQL_DATATYPES.EmptyChar240Tab
	,p_login_id                     IN  NUMBER
	,p_program_id                   IN  NUMBER
	,p_program_application_id       IN  NUMBER
	,p_request_id                   IN  NUMBER
	,p_debug_mode                   IN  BOOLEAN
       );

END PA_MC_BORRLENT;

/
