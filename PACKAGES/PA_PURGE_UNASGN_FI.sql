--------------------------------------------------------
--  DDL for Package PA_PURGE_UNASGN_FI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_UNASGN_FI" AUTHID CURRENT_USER AS
/* $Header: PAXUSGNS.pls 120.1.12000000.2 2007/03/06 14:01:39 rthumma ship $ */

-- Start of comments
-- API name         : PA_FORECASTITEM
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Procedure for Purging records related to unassigned time forecast_items for resources
-- Parameters       :
--                     p_archive_flag    -> This flag will indicate if the
--                                          records need to be archived
--                                          before they are purged.
--                     p_txn_to_date     -> Date through which the transactions
--                                          need to be purged. This value will
--                                          be NULL if the purge batch is for
--                                          active projects.
-- End of comments

Procedure  PA_FORECASTITEM (
			    errbuf                       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            retcode                      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			    p_txn_to_date                in  VARCHAR2,
                            p_archive_flag               in  varchar2);


-- Start of comments
-- API name         : DELETE_FI
-- Type             : Public
-- Pre-reqs         : None
-- Function         : Archive/purge records for pa_forecast_items, pa_forecast_items_details and pa_fi_amount_details table.
-- Parameters       :
--                                              records need to be archived
--                     p_forecast_item_id_id_tab   -> forecast items tab
-- End of comments

Procedure Delete_FI (p_forecast_item_id_tab           in PA_PLSQL_DATATYPES.IdTabTyp,
                     p_project_id_tab                      in PA_PLSQL_DATATYPES.IdTabTyp, --Added for bug 5870223
		     p_archive_flag                   in VARCHAR2,
		     p_purge_batch_id                 in NUMBER,
                     x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_err_code                       in OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895

PROCEDURE arpr_log ( p_message IN VARCHAR2 );

PROCEDURE arpr_out ( p_txn_to_date                    in VARCHAR2,
	             p_archive_flag                   in varchar2,
                     p_purge_batch_id                 in number);


END PA_PURGE_UNASGN_FI;

 

/
