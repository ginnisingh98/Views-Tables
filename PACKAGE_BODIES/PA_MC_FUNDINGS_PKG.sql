--------------------------------------------------------
--  DDL for Package Body PA_MC_FUNDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_FUNDINGS_PKG" as
/* $Header: PAMRCFPB.pls 120.3 2005/08/23 16:37:06 hsiu noship $ */
-- This function returns the sum of RDL and ERDL for project, agreement, task
-- and set of books id in reporting.
-- parameters
-- Input parameters
-- Parameters                    Type           Required      Description
-- p_project_id                  NUMBER          YES          Project Id
-- p_draft_revenue_num           NUMBER          YES          Draft revenue number
-- p_draft_revenue_item_line_num NUMBER          YES          Draft revenue line number
-- p_set_of_books_id             NUMBER          YES          Reporting set of books id
-- Out parameters
--

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION sum_mc_sob_cust_rdl_erdl(
                               p_project_id                   IN   NUMBER,
                               p_draft_revenue_num            IN   NUMBER,
                               p_draft_revenue_item_line_num  IN   NUMBER,
                               p_set_of_books_id              IN   NUMBER
 ) RETURN NUMBER

IS
BEGIN
   RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
   PA_DEBUG.Reset_Curr_Function;
   RAISE;

END sum_mc_sob_cust_rdl_erdl;



-- This function will check that MRC is installed or not if installed it will return true otherwise false.
-- Input parameters
-- Parameters                    Type           Required      Description
-- Out parameters
-- x_error_code                    VARCHAR2        YES          It stores error message code if current
--                                                              operating unit does not have MRC enabled
--                                                              for Oracle Projects
--

FUNCTION check_mrc_install(x_error_code OUT NOCOPY VARCHAR2/*file.sql.39*/)
RETURN BOOLEAN
IS
BEGIN
    RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    PA_DEBUG.Reset_Curr_Function;
    RAISE;
END check_mrc_install;



-- This procedure will populate the mrc funding lines table and mrc summary table
-- after converting all the records from primary. This procedure is being called
-- from concurrent process.
-- Input parameters
-- Parameters                    Type           Required      Description
-- p_upgrade_from_date           DATE           YES           The date from which user wants to upgrade its data.
-- Out parameters
-- x_return_status               VARCHAR2       YES            Return status
-- x_msg_data                    VARCHAR2       YES            stores error's text
-- x_msg_count                   NUMBER         YES            Stores number of errors
--

PROCEDURE upgrade_fundings_mrc(
          p_upgrade_from_date    IN       DATE,
          x_return_status        OUT      NOCOPY VARCHAR2,/*File.sql.39*/
          x_msg_data             OUT      NOCOPY VARCHAR2,/*File.sql.39*/
          x_msg_count            OUT      NOCOPY NUMBER /*File.sql.39*/
          )

IS
BEGIN

  NULL;

END upgrade_fundings_mrc;


END PA_MC_FUNDINGS_PKG;


/
