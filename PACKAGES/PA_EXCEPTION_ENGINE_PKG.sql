--------------------------------------------------------
--  DDL for Package PA_EXCEPTION_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXCEPTION_ENGINE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAPEXENS.pls 120.1 2005/08/19 16:40:23 mwasowic noship $ */

TYPE
  summary_record IS record
    (kpa_code VARCHAR2(30),
     indicator_code VARCHAR2(30),
     score NUMBER,
     thres_from NUMBER,
     thres_to NUMBER);

  TYPE summary_table IS TABLE OF summary_record INDEX BY binary_integer;


-- Procedure    PAPFEXCP
-- Purpose      This procedure will call logic to generate exception
--               transaction, KPA Scoring or Notification based on the
--               input parameters.

PROCEDURE PAPFEXCP      (  x_errbuf                OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                           x_retcode               OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           p_project_ou            IN      NUMBER   DEFAULT NULL,
                           p_project_org           IN      NUMBER   DEFAULT NULL,
                           p_project_type          IN      VARCHAR2 DEFAULT NULL,
                           p_project_manager       IN      NUMBER   DEFAULT NULL,
                           p_project_from          IN      NUMBER   DEFAULT NULL,
                           p_project_to            IN      NUMBER   DEFAULT NULL,
                           p_generate_exceptions   IN      VARCHAR2 DEFAULT 'N',
                           p_generate_scoring      IN      VARCHAR2 DEFAULT 'N',
                           p_generate_notification IN      VARCHAR2 DEFAULT 'N',
                           p_purge                 IN      VARCHAR2 DEFAULT 'N',
                           p_daysold               IN      NUMBER   DEFAULT NULL,
                           p_bz_event_code         IN      VARCHAR2 DEFAULT 'N',
                           p_perf_txn_set_id       IN      VARCHAR2 DEFAULT 'N');

-- Procedure	generate_exception
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the performance transactions

PROCEDURE generate_exception(	p_project_list		IN	PA_PLSQL_DATATYPES.IdTabTyp,
				p_business_event_code 	IN	VARCHAR2,
				x_errbuf		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_retcode               OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Procedure	generate_notification
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the workflow notification for each.

PROCEDURE generate_notification(p_project_list        IN      PA_PLSQL_DATATYPES.IdTabTyp,
                                x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_retcode               OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Procedure	purge_performance
-- Purpose      This procedure will call logic to cleanup data in the
--               PA_PERF_TRANSACTIONS table.

PROCEDURE purge_transaction(	p_project_list		IN	PA_PLSQL_DATATYPES.IdTabTyp,
				p_days_old              IN NUMBER,
                                x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_retcode               OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Procedure    get_thresholds_info
-- Purpose      This procedure will return information from PA_PERF_THRESHOLDS table

PROCEDURE get_threshold     (
				p_rule_id		IN	NUMBER,
				p_rule_type             IN      VARCHAR2,
				p_cur_value		IN	NUMBER,
				x_threshold_id          out     NOCOPY NUMBER, --File.Sql.39 bug 4440895
				x_indicator_code	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				x_exception_flag	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
				x_weighting		OUT 	NOCOPY NUMBER, --File.Sql.39 bug 4440895
				x_from_value		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
				x_to_value		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_retcode               OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


-- Procedure	get_kpa_score
-- Purpose      This procedure will be called by concurrent program.
--               Once running, it will generate the Project KPA Summary.

PROCEDURE get_kpa_score     (   p_project_list          IN      PA_PLSQL_DATATYPES.IdTabTyp,
                   		x_errbuf                OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                   		x_retcode               OUT     NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

END pa_exception_engine_pkg;

 

/
