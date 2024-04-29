--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAM_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAM_PARTIES_PKG" AS
--$Header: PARTSPHB.pls 120.1 2005/08/19 17:01:37 mwasowic noship $

PROCEDURE Insert_Row
(
 p_project_subteam_id     IN pa_project_subteams.Project_subteam_id%TYPE := FND_API.g_miss_num,

 p_object_type            IN pa_project_subteam_parties.object_type%TYPE := FND_API.g_miss_char,

 p_object_id              IN pa_project_subteam_parties.object_id%TYPE := fnd_api.g_miss_num,

 p_primary_subteam_flag           IN pa_project_subteam_parties.primary_subteam_flag%TYPE := 'Y',

 x_project_subteam_party_row_id   OUT  NOCOPY ROWID, --File.Sql.39 bug 4440895

 x_project_subteam_party_id       OUT  NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE, --File.Sql.39 bug 4440895

 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

 x_msg_count              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895

 x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_subteam_party_id      NUMBER;
 l_record_version_number NUMBER := 1;
 l_primary_subteam_flag   pa_project_subteam_parties.primary_subteam_flag%TYPE;

 CURSOR  c1 IS
  SELECT rowid
  FROM   pa_project_subteam_parties
  WHERE  project_subteam_party_id = l_subteam_party_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Fetch the next sequence number for subteam
  --SELECT pa_project_subteams_s.NEXTVAL
  --INTO   l_subteam_party_id
  --FROM   dual;

  if p_primary_subteam_flag is NULL or p_primary_subteam_flag = FND_API.g_miss_char then
      l_primary_subteam_flag := 'Y';
  else
      l_primary_subteam_flag := p_primary_subteam_flag;
  end if;

  INSERT INTO pa_project_subteam_parties
       (project_subteam_party_id,
        project_subteam_id,
    	record_version_number,
        object_type,
    	object_id,
        primary_subteam_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login )
 VALUES
    (
        --l_subteam_party_id,
        pa_project_subteams_s.NEXTVAL,
        DECODE(p_project_subteam_id, FND_API.G_MISS_NUM, NULL, p_project_subteam_id),
    	1,
        DECODE(p_object_type, FND_API.G_MISS_CHAR, NULL, p_object_type),
        DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
        DECODE(l_primary_subteam_flag, FND_API.G_MISS_CHAR, NULL, l_primary_subteam_flag),
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
   )  RETURNING project_subteam_party_id INTO l_subteam_party_id;


  x_project_subteam_party_id := l_subteam_party_id;

  OPEN c1;
  FETCH c1 INTO x_project_subteam_party_row_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c1;
  --
  --
  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Insert_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Insert_Row;

PROCEDURE Update_Row
(
 p_project_subteam_party_row_id   IN   ROWID :=NULL,

 p_project_subteam_party_id       IN   pa_project_subteam_parties.project_subteam_party_id%TYPE,

 p_project_subteam_id     IN   pa_project_subteams.project_subteam_id%TYPE,

-- p_object_type            IN varchar2,

-- p_object_id              IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag            IN  pa_project_subteam_parties.primary_subteam_flag%TYPE := 'Y',

 p_record_version_number  IN NUMBER   := NULL,

 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895

 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895

 x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_primary_subteam_flag pa_project_subteam_parties.primary_subteam_flag%TYPE;
 l_row_id  ROWID := p_project_subteam_party_row_id;
 l_record_version_number  NUMBER;

CURSOR get_row_id IS
SELECT rowid
FROM   pa_project_subteam_parties
WHERE  project_subteam_party_id = p_project_subteam_party_id;


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 if p_primary_subteam_flag is NULL or p_primary_subteam_flag = FND_API.g_miss_char then
      l_primary_subteam_flag := 'Y';
 else
      l_primary_subteam_flag := p_primary_subteam_flag;
 end if;


--get the ROWID for the row to be updated if
--p_subteam_row_id is not passed to the API.

 IF l_row_id IS NULL THEN

    OPEN get_row_id;

    FETCH get_row_id INTO l_row_id;

    CLOSE get_row_id;

 END IF;

  -- Increment the record version number by 1
  IF p_record_version_number IS NOT NULL then
     l_record_version_number :=  p_record_version_number +1;
  END IF;

  UPDATE pa_project_subteam_parties
  SET

    project_subteam_id = Decode (p_project_subteam_id,fnd_api.g_miss_num,project_subteam_id, p_project_subteam_id),

    record_version_number   = DECODE(p_record_version_number, NULL, record_version_number + 1, l_record_version_number),

    primary_subteam_flag           = Decode(l_primary_subteam_flag, fnd_api.g_miss_char, primary_subteam_flag, l_primary_subteam_flag),

    last_update_date            = sysdate,

    last_updated_by             = fnd_global.user_id,

    last_update_login           = fnd_global.login_id

    WHERE  rowid = l_row_id
    AND    nvl(p_record_version_number, record_version_number) = record_version_number;

  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Update_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Update_Row;

PROCEDURE Delete_Row
(
  p_project_subteam_party_row_id       IN   ROWID
 ,p_project_subteam_party_id            IN   pa_project_subteam_parties.project_subteam_party_id%TYPE
 ,p_record_version_number       IN   NUMBER  := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_row_id  ROWID;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  pa_project_subteam_parties
  WHERE  project_subteam_party_id  = p_project_subteam_party_id
  OR     rowid = p_project_subteam_party_row_id
  AND    nvl(p_record_version_number, record_version_number) = record_version_number;

  --
  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA', p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;

--
--
END PA_PROJECT_SUBTEAM_PARTIES_PKG;

/
