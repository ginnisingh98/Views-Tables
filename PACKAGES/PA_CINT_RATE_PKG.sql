--------------------------------------------------------
--  DDL for Package PA_CINT_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CINT_RATE_PKG" AUTHID CURRENT_USER AS
--$Header: PACINTRS.pls 115.1 2003/04/29 00:19:52 riyengar noship $
PROCEDURE insert_row_exp_excl (
        x_rowid                        in out NOCOPY VARCHAR2
        ,p_exp_type                    IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_CREATED_BY                  IN   NUMBER
        ,p_CREATION_DATE               IN   DATE
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );

 PROCEDURE update_row_exp_excl
        (p_rowid                       IN   VARCHAR2
        ,p_exp_type                    IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );
 PROCEDURE  delete_row_exp_excl (p_ind_cost_code in VARCHAR2
                                ,p_exp_type     IN VARCHAR2
                                ,p_org_id       IN NUMBER);

 PROCEDURE delete_row_exp_excl (x_rowid      in VARCHAR2);

PROCEDURE insert_row_rate_info (
        x_rowid                        in out NOCOPY VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
 	,p_EXP_ORG_SOURCE              IN  VARCHAR2
 	,p_PROJ_AMT_THRESHOLD         IN  NUMBER
 	,p_TASK_AMT_THRESHOLD         IN  NUMBER
 	,p_PROJ_DURATION_THRESHOLD    IN  NUMBER
 	,p_TASK_DURATION_THRESHOLD    IN  NUMBER
 	,p_CURR_PERIOD_CONVENTION      IN  VARCHAR2
 	,p_INTEREST_CALCULATION_METHOD   IN  VARCHAR2
	,p_THRESHOLD_AMT_TYPE          IN VARCHAR2
        ,p_BUDGET_TYPE_CODE            IN VARCHAR2
        ,p_PERIOD_RATE_CODE            IN VARCHAR2
        ,p_CREATED_BY                  IN   NUMBER
        ,p_CREATION_DATE               IN   DATE
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );

 PROCEDURE update_row_rate_info
        (p_rowid                       IN   VARCHAR2
        ,p_org_id                      IN   NUMBER
        ,p_ind_cost_code               IN   VARCHAR2
        ,p_EXP_ORG_SOURCE              IN  VARCHAR2
        ,p_PROJ_AMT_THRESHOLD         IN  NUMBER
        ,p_TASK_AMT_THRESHOLD         IN  NUMBER
        ,p_PROJ_DURATION_THRESHOLD    IN  NUMBER
        ,p_TASK_DURATION_THRESHOLD    IN  NUMBER
        ,p_CURR_PERIOD_CONVENTION      IN  VARCHAR2
        ,p_INTEREST_CALCULATION_METHOD   IN  VARCHAR2
        ,p_THRESHOLD_AMT_TYPE          IN VARCHAR2
        ,p_BUDGET_TYPE_CODE            IN VARCHAR2
        ,p_PERIOD_RATE_CODE            IN VARCHAR2
        ,p_LAST_UPDATED_BY             IN   NUMBER
        ,p_LAST_UPDATE_DATE            IN   DATE
        ,p_LAST_UPDATE_LOGIN           IN   NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2
        ,x_error_msg_code              OUT NOCOPY  VARCHAR2
                      );
 PROCEDURE  delete_row_rate_info (p_ind_cost_code in VARCHAR2
                                 ,p_org_id       IN NUMBER
				 );
END PA_CINT_RATE_PKG;

 

/
