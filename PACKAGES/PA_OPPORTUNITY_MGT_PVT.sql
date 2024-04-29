--------------------------------------------------------
--  DDL for Package PA_OPPORTUNITY_MGT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_OPPORTUNITY_MGT_PVT" AUTHID CURRENT_USER as
/* $Header: PAYOPVTS.pls 120.1 2005/08/19 17:23:53 mwasowic noship $ */

--
-- Procedure     : debug
-- Purpose       :
--
--
PROCEDURE debug(p_msg IN VARCHAR2);

--
-- Procedure     : modify_project_attributes
-- Purpose       :
--
--
PROCEDURE modify_project_attributes
(       p_project_id                 IN   NUMBER   ,
        p_opportunity_value          IN   NUMBER   ,
        p_opp_value_currency_code    IN   VARCHAR2 ,
        p_expected_approval_date     IN   DATE     ,
        p_update_project             IN   VARCHAR2 := 'N',
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : copy_project_attributes
-- Purpose       :
--
--
PROCEDURE copy_project_attributes
(       p_source_project_id          IN   NUMBER   ,
        p_dest_project_id            IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : create_project_attributes
-- Purpose       :
--
--
PROCEDURE create_project_attributes
(       p_project_id                 IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : delete_project_attributes
-- Purpose       :
--
--
PROCEDURE delete_project_attributes
(       p_project_id                 IN   NUMBER   ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : validate_value_fields
-- Purpose       :
--
--
PROCEDURE validate_value_fields
(       p_opportunity_value          IN   NUMBER   := NULL,
        p_opp_value_currency_code    IN   VARCHAR2 := NULL,
        p_projfunc_currency_code     IN   VARCHAR2 ,
        p_project_currency_code      IN   VARCHAR2 ,
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : get_opp_multi_currency_setup
-- Purpose       :
--
--
PROCEDURE get_opp_multi_currency_setup
(       x_default_rate_type          OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : get_opp_multi_currency_setup (overloaded)
-- Purpose       :
--
--
PROCEDURE get_opp_multi_currency_setup
(       p_org_id                     IN   NUMBER   ,
        x_default_rate_type          OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER   , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Function      : is_opp_multi_currency_setup
-- Purpose       :
--
--
FUNCTION is_opp_multi_currency_setup RETURN VARCHAR2;


--
-- Function      : is_opp_multi_currency_setup (overloaded)
-- Purpose       :
--
--
FUNCTION is_opp_multi_currency_setup (p_org_id IN NUMBER) RETURN VARCHAR2;


--
-- Function      : is_proj_opp_associated
-- Purpose       : Check whether a project has association with an opportunity.
--
--
FUNCTION is_proj_opp_associated(p_project_id   IN   NUMBER) RETURN VARCHAR2;


END PA_OPPORTUNITY_MGT_PVT;

 

/
