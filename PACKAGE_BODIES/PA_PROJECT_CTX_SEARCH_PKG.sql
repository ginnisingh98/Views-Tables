--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CTX_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CTX_SEARCH_PKG" 
-- $Header: PAXPCXTB.pls 120.1 2005/08/19 17:16:25 mwasowic noship $
AS
PROCEDURE INSERT_ROW(p_project_id            in NUMBER,
                     p_ctx_description       in VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN

  INSERT INTO PA_PROJECT_CTX_SEARCH
       (PROJECT_ID,
        CTX_DESCRIPTION,
        PROGRAM_REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
   VALUES
       (p_project_id,
        p_ctx_description,
        null,
        null,
        null,
        null,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.login_id);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name     => 'PA_PROJECT_CTX_SEARCH_PKG',
                                 p_procedure_name => 'INSERT_ROW' );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END INSERT_ROW;

PROCEDURE UPDATE_ROW(p_project_id            IN  NUMBER,
                     p_ctx_description       IN  VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     )

IS
BEGIN

  UPDATE PA_PROJECT_CTX_SEARCH
  SET CTX_DESCRIPTION     = p_ctx_description,
      LAST_UPDATE_DATE    = sysdate,
      LAST_UPDATED_BY     = fnd_global.user_id,
      LAST_UPDATE_LOGIN   = fnd_global.login_id
  WHERE project_id = p_project_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name     => 'PA_PROJECT_CTX_SEARCH_PKG',
                                 p_procedure_name => 'UPDATE_ROW' );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END UPDATE_ROW;

PROCEDURE DELETE_ROW(p_project_id       IN NUMBER,
                     x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS
BEGIN

  DELETE FROM pa_project_ctx_search
  WHERE project_id = p_project_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name     => 'PA_PROJECT_CTX_SEARCH_PKG',
                                 p_procedure_name => 'DELETE_ROW' );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END DELETE_ROW;

END PA_PROJECT_CTX_SEARCH_PKG;

/
