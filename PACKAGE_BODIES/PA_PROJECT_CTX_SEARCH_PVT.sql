--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_CTX_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_CTX_SEARCH_PVT" 
-- $Header: PAXPCXVB.pls 120.2 2005/08/29 04:38:51 avaithia noship $
AS
PROCEDURE INSERT_ROW(p_project_id            IN  NUMBER,
                     p_template_flag         IN  VARCHAR2,
                     p_project_name          IN  VARCHAR2,
                     p_project_number        IN  VARCHAR2,
                     p_project_long_name     IN  VARCHAR2 default null,
                     p_project_description   IN  VARCHAR2 default null,
                     x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_project_long_name    PA_PROJECTS_ALL.long_name%TYPE;
  l_project_description  PA_PROJECTS_ALL.description%TYPE;
  l_exists               VARCHAR2(1);
  l_ctx_description      PA_PROJECT_CTX_SEARCH.ctx_description%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are not maintaining templates in PA_PROJECT_CTX_SEARCH table.
  IF p_template_flag = 'Y'
  THEN
     RETURN;
  END IF;

  -- Check if record exists in PA_PROJECT_CTX_SEARCH for the p_project_Id
  -- If it does, just return
  l_exists := 'N';
  BEGIN

     SELECT 'Y' into l_exists
     FROM PA_PROJECT_CTX_SEARCH
     WHERE project_id = p_project_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_exists := 'N';
  END;

  IF l_exists = 'N' THEN

     IF p_project_long_name = FND_API.G_MISS_CHAR THEN
        l_project_long_name := null;
     ELSE
        l_project_long_name := p_project_long_name;
     END IF;

     IF p_project_description = FND_API.G_MISS_CHAR THEN
        l_project_description := null;
     ELSE
        l_project_description := p_project_description;
     END IF;

     l_ctx_description := p_project_name || ' ' || p_project_number;

     IF l_project_long_name is not null THEN
        l_ctx_description := l_ctx_description || ' ' || l_project_long_name;
     END IF;

     IF l_project_description is not null THEN
        l_ctx_description := l_ctx_description || ' ' || l_project_description;
     END IF;

     PA_PROJECT_CTX_SEARCH_PKG.INSERT_ROW
            (p_project_id      => p_project_id,
             p_ctx_description => l_ctx_description,
             x_return_status   => x_return_status);
  END IF;
-- 4537865 : Included Exception Block
EXCEPTION
	WHEN OTHERS THEN
	x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        Fnd_Msg_Pub.add_exc_msg
       (  p_pkg_name        => 'PA_PROJECT_CTX_SEARCH_PVT'
        , p_procedure_name  => 'INSERT_ROW'
        , p_error_text      => SUBSTRB(SQLERRM,1,240));
       -- Not included RAISE according to caller API reqmt.

END INSERT_ROW;

PROCEDURE UPDATE_ROW(p_project_id            IN  NUMBER,
                     p_template_flag         IN  VARCHAR2,
                     p_project_name          IN  VARCHAR2,
                     p_project_number        IN  VARCHAR2,
                     p_project_long_name     IN  VARCHAR2 default null,
                     p_project_description   IN  VARCHAR2 default null,
                     x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_project_long_name    PA_PROJECTS_ALL.long_name%TYPE;
  l_project_description  PA_PROJECTS_ALL.description%TYPE;
  l_exists               VARCHAR2(1);
  l_ctx_description      PA_PROJECT_CTX_SEARCH.ctx_description%TYPE;
  l_old_ctx_description  PA_PROJECT_CTX_SEARCH.ctx_description%TYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are not maintaining templates in PA_PROJECT_CTX_SEARCH table.
  IF p_template_flag = 'Y'
  THEN
     RETURN;
  END IF;

  -- Check if record exists for p_project_id. If not, call insert_row.
  l_exists := 'N';
  BEGIN

     SELECT 'Y',ctx_description INTO l_exists,l_old_ctx_description
     FROM PA_PROJECT_CTX_SEARCH
     WHERE project_id = p_project_id;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_exists := 'N';
  END;

  IF l_exists = 'N' THEN
     INSERT_ROW(p_project_id            => p_project_id,
                p_template_flag         => p_template_flag,
                p_project_name          => p_project_name,
                p_project_number        => p_project_number,
                p_project_long_name     => p_project_long_name,
                p_project_description   => p_project_description,
                x_return_status         => x_return_status);
  ELSE
     IF p_project_long_name = FND_API.G_MISS_CHAR THEN
        l_project_long_name := null;
     ELSE
        l_project_long_name := p_project_long_name;
     END IF;

     IF p_project_description = FND_API.G_MISS_CHAR THEN
        l_project_description := null;
     ELSE
       l_project_description := p_project_description;
     END IF;

     l_ctx_description := p_project_name || ' ' || p_project_number;

     IF l_project_long_name is not null THEN
        l_ctx_description := l_ctx_description || ' ' || l_project_long_name;
     END IF;

     IF l_project_description is not null THEN
        l_ctx_description := l_ctx_description || ' ' || l_project_description;
     END IF;

     -- Check if the CTX description has changed. If yes, update it.
     IF l_old_ctx_description = l_ctx_description THEN
        RETURN;
     ELSE
        PA_PROJECT_CTX_SEARCH_PKG.UPDATE_ROW
            (p_project_id      => p_project_id,
             p_ctx_description => l_ctx_description,
             x_return_status   => x_return_status);
     END IF;
  END IF;

-- 4537865 : Included Exception Block
EXCEPTION
        WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        Fnd_Msg_Pub.add_exc_msg
       (  p_pkg_name        => 'PA_PROJECT_CTX_SEARCH_PVT'
        , p_procedure_name  => 'UPDATE_ROW'
        , p_error_text      => SUBSTRB(SQLERRM,1,240));
       -- Not included RAISE according to caller API reqmt.

END UPDATE_ROW;

PROCEDURE DELETE_ROW(p_project_id            IN  VARCHAR2,
                     p_template_flag         IN  VARCHAR2,
                     x_return_status         OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- We are not maintaining templates in PA_PROJECT_CTX_SEARCH table.
  IF p_template_flag = 'Y'
  THEN
     RETURN;
  END IF;

  PA_PROJECT_CTX_SEARCH_PKG.DELETE_ROW
      (p_project_id      => p_project_id,
       x_return_status   => x_return_status);
-- 4537865 : Included Exception Block
EXCEPTION
        WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
        Fnd_Msg_Pub.add_exc_msg
       (  p_pkg_name        => 'PA_PROJECT_CTX_SEARCH_PVT'
        , p_procedure_name  => 'DELETE_ROW'
        , p_error_text      => SUBSTRB(SQLERRM,1,240));
       -- Not included RAISE according to caller API reqmt.
END DELETE_ROW;

END PA_PROJECT_CTX_SEARCH_PVT;

/
