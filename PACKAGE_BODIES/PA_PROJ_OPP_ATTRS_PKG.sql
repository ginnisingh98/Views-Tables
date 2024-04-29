--------------------------------------------------------
--  DDL for Package Body PA_PROJ_OPP_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_OPP_ATTRS_PKG" as
/* $Header: PAYOPKGB.pls 120.1 2005/08/19 17:23:36 mwasowic noship $ */

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
        p_project_opp_value               IN NUMBER,
        p_project_opp_rate_type           IN VARCHAR2,
        p_project_opp_rate_date           IN DATE,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO pa_project_opp_attrs
  (    project_id               ,
       opportunity_value        ,
       opp_value_currency_code  ,
       projfunc_opp_value       ,
       projfunc_opp_rate_type   ,
       projfunc_opp_rate_date   ,
       project_opp_value        ,
       project_opp_rate_type    ,
       project_opp_rate_date    ,
       creation_date            ,
       created_by               ,
       last_update_date         ,
       last_updated_by          ,
       last_update_login       )
  VALUES
  (    p_project_id               ,
       p_opportunity_value        ,
       p_opp_value_currency_code  ,
       p_projfunc_opp_value       ,
       p_projfunc_opp_rate_type   ,
       p_projfunc_opp_rate_date   ,
       p_project_opp_value        ,
       p_project_opp_rate_type    ,
       p_project_opp_rate_date    ,
       sysdate                      ,
       fnd_global.user_id           ,
       sysdate                      ,
       fnd_global.user_id           ,
       fnd_global.login_id          );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJ_OPP_ATTRS_PKG',
                          p_procedure_name   => 'insert_row');
  raise;

END insert_row;


--
-- Procedure            : delete_row
-- Purpose              : Delete a row in pa_project_opp_attrs.
--
--
PROCEDURE delete_row
	    ( p_project_id                 IN NUMBER                        ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM pa_project_opp_attrs
  WHERE project_id = p_project_id;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJ_OPP_ATTRS_PKG',
                          p_procedure_name   => 'delete_row');
  raise;

END delete_row;


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
        x_return_status              OUT  NOCOPY VARCHAR2                    , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                      , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE pa_project_opp_attrs
    SET
        opportunity_value          =  p_opportunity_value,
        opp_value_currency_code    =  p_opp_value_currency_code,
        projfunc_opp_value         =  p_projfunc_opp_value,
        projfunc_opp_rate_type     =  p_projfunc_opp_rate_type,
        projfunc_opp_rate_date     =  p_projfunc_opp_rate_date,
        project_opp_value          =  p_project_opp_value,
        project_opp_rate_type      =  p_project_opp_rate_type,
        project_opp_rate_date      =  p_project_opp_rate_date
    WHERE
        project_id = p_project_id;

  -- Update pa_projects_all.project_value = p_projfunc_opp_value.
  UPDATE PA_PROJECTS_ALL
   SET project_value = p_projfunc_opp_value
   WHERE project_id = p_project_id;

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJ_OPP_ATTRS_PKG',
                          p_procedure_name   => 'update_row');
  raise;

END update_row;


END PA_PROJ_OPP_ATTRS_PKG;

/
