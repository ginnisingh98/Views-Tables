--------------------------------------------------------
--  DDL for Package PA_PROJ_OPP_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_OPP_ATTRS_PKG" AUTHID CURRENT_USER as
/* $Header: PAYOPKGS.pls 120.1 2005/08/19 17:23:43 mwasowic noship $ */

--
-- Procedure     : Insert_row
-- Purpose       : Create a Row in PA_PROJECT_OPP_ATTRS.
--
--
PROCEDURE insert_row
      ( p_project_id                       IN NUMBER,
        p_opportunity_value                IN NUMBER,
        p_opp_value_currency_code          IN VARCHAR2,
        p_projfunc_opp_value               IN NUMBER,
        p_projfunc_opp_rate_type           IN VARCHAR2,
        p_projfunc_opp_rate_date           IN DATE,
        p_project_opp_value                IN NUMBER,
        p_project_opp_rate_type            IN VARCHAR2,
        p_project_opp_rate_date            IN DATE,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : delete_row
-- Purpose              : Delete a row in pa_project_opp_attrs.
--
--
PROCEDURE delete_row
	    ( p_project_id                 IN NUMBER                        ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : update_row
-- Purpose              : Update a row in pa_project_opp_attrs.
--
--
PROCEDURE update_row
	    ( p_project_id                 IN NUMBER                        ,
        p_opportunity_value          IN NUMBER,
        p_opp_value_currency_code    IN VARCHAR2,
        p_projfunc_opp_value         IN NUMBER,
        p_projfunc_opp_rate_type     IN VARCHAR2,
        p_projfunc_opp_rate_date     IN DATE,
        p_project_opp_value          IN NUMBER,
        p_project_opp_rate_type      IN VARCHAR2,
        p_project_opp_rate_date      IN DATE,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


END PA_PROJ_OPP_ATTRS_PKG;

 

/
