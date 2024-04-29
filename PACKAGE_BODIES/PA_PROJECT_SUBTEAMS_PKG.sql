--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAMS_PKG" AS
--$Header: PARTSTHB.pls 120.1 2005/08/19 17:01:53 mwasowic noship $

PROCEDURE Insert_Row
(

 p_subteam_name           IN   pa_project_subteams.name%TYPE := FND_API.g_miss_char ,
 p_object_type            IN   pa_project_subteams.object_type%TYPE := FND_API.g_miss_char,
 p_object_id             IN   pa_project_subteams.object_id%TYPE := FND_API.g_miss_num,
 p_description            IN   pa_project_subteams.description%TYPE        := FND_API.g_miss_char ,
 p_attribute_category     IN   pa_project_subteams.attribute_category%TYPE                 := FND_API.g_miss_char ,
 p_attribute1             IN   pa_project_subteams.attribute1%TYPE                  := FND_API.g_miss_char ,
 p_attribute2             IN   pa_project_subteams.attribute2%TYPE                  := FND_API.g_miss_char ,
 p_attribute3             IN   pa_project_subteams.attribute3%TYPE                  := FND_API.g_miss_char ,
 p_attribute4             IN   pa_project_subteams.attribute4%TYPE                  := FND_API.g_miss_char ,
 p_attribute5             IN   pa_project_subteams.attribute5%TYPE                  := FND_API.g_miss_char ,
 p_attribute6             IN   pa_project_subteams.attribute6%TYPE                  := FND_API.g_miss_char ,
 p_attribute7             IN   pa_project_subteams.attribute7%TYPE                  := FND_API.g_miss_char ,
 p_attribute8             IN   pa_project_subteams.attribute8%TYPE                  := FND_API.g_miss_char ,
 p_attribute9             IN   pa_project_subteams.attribute9%TYPE                  := FND_API.g_miss_char ,
 p_attribute10           IN   pa_project_subteams.attribute10%TYPE                  := FND_API.g_miss_char ,
 p_attribute11           IN   pa_project_subteams.attribute11%TYPE                  := FND_API.g_miss_char ,
 p_attribute12           IN   pa_project_subteams.attribute12%TYPE                  := FND_API.g_miss_char ,
 p_attribute13           IN   pa_project_subteams.attribute13%TYPE                  := FND_API.g_miss_char ,
 p_attribute14           IN   pa_project_subteams.attribute14%TYPE                  := FND_API.g_miss_char ,
 p_attribute15           IN   pa_project_subteams.attribute15%TYPE                  := FND_API.g_miss_char ,
 x_subteam_row_id         OUT  NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_new_subteam_id         OUT  NOCOPY pa_project_subteams.project_subteam_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_subteam_id         NUMBER;
 l_record_version_number NUMBER := 1;

 CURSOR  c1 IS
  SELECT rowid
  FROM   pa_project_subteams
  WHERE  project_subteam_id = l_subteam_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Fetch the next sequence number for subteam
  --SELECT pa_project_subteams_s.NEXTVAL
  --INTO   l_subteam_id
  --FROM   dual;


  INSERT INTO pa_project_subteams
       (project_subteam_id,
        name,
        object_type,
        object_id,
        description,
    	record_version_number,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login )
 VALUES
    (
        pa_project_subteams_s.NEXTVAL,
        DECODE(p_subteam_name, FND_API.G_MISS_CHAR, NULL, p_subteam_name),
        DECODE(p_object_type, FND_API.G_MISS_CHAR, NULL, p_object_type),
        DECODE(p_object_id, FND_API.G_MISS_NUM, NULL, p_object_id),
        DECODE(p_description, FND_API.G_MISS_CHAR, NULL, p_description),
	l_record_version_number,
        DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
        DECODE(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
        DECODE(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
        DECODE(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
        DECODE(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
        DECODE(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
        DECODE(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
        DECODE(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
        DECODE(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
        DECODE(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
        DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
        DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
        DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
        DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
        DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
        DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id
   ) RETURNING project_subteam_id INTO l_subteam_id;

  x_new_subteam_id := l_subteam_id;

  OPEN c1;
  FETCH c1 INTO x_subteam_row_id;
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

 p_subteam_row_id           IN   ROWID :=NULL,

 p_subteam_id               IN   pa_project_subteams.project_subteam_id%TYPE,

 p_record_version_number       IN   NUMBER   := NULL,

 p_subteam_name             IN   pa_project_subteams.name%TYPE:= FND_API.g_miss_char,

 p_object_type              IN   pa_project_subteams.object_type%TYPE                 := FND_API.g_miss_char,
 p_object_id               IN   pa_project_subteams.object_id%TYPE                  := FND_API.g_miss_num,

 p_description              IN   pa_project_subteams.description%TYPE                 := FND_API.g_miss_char,

 p_attribute_category     IN   pa_project_subteams.attribute_category%TYPE                 := FND_API.g_miss_char ,

 p_attribute1             IN   pa_project_subteams.attribute1%TYPE                  := FND_API.g_miss_char ,

 p_attribute2             IN   pa_project_subteams.attribute2%TYPE                  := FND_API.g_miss_char ,

 p_attribute3             IN   pa_project_subteams.attribute3%TYPE                  := FND_API.g_miss_char ,

 p_attribute4             IN   pa_project_subteams.attribute4%TYPE                  := FND_API.g_miss_char ,

 p_attribute5             IN   pa_project_subteams.attribute5%TYPE                  := FND_API.g_miss_char ,

 p_attribute6             IN   pa_project_subteams.attribute6%TYPE                  := FND_API.g_miss_char ,

 p_attribute7             IN   pa_project_subteams.attribute7%TYPE                  := FND_API.g_miss_char ,

 p_attribute8             IN   pa_project_subteams.attribute8%TYPE                  := FND_API.g_miss_char ,

 p_attribute9             IN   pa_project_subteams.attribute9%TYPE                  := FND_API.g_miss_char ,

 p_attribute10             IN   pa_project_subteams.attribute10%TYPE                  := FND_API.g_miss_char ,

 p_attribute11             IN   pa_project_subteams.attribute11%TYPE                  := FND_API.g_miss_char ,

 p_attribute12             IN   pa_project_subteams.attribute12%TYPE                  := FND_API.g_miss_char ,

 p_attribute13             IN   pa_project_subteams.attribute13%TYPE                  := FND_API.g_miss_char ,

 p_attribute14             IN   pa_project_subteams.attribute14%TYPE                  := FND_API.g_miss_char ,

 p_attribute15            IN   pa_project_subteams.attribute15%TYPE                  := FND_API.g_miss_char ,

 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_row_id  ROWID := p_subteam_row_id;
 l_record_version_number  NUMBER;

CURSOR get_row_id IS
SELECT rowid
FROM   pa_project_subteams
WHERE  project_subteam_id = p_subteam_id;


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

/* ??????
  -- Lock the row first
  SELECT rowid  INTO l_row_id
  FROM pa_project_subteams
  WHERE project_subteam_id = p_subteam_id
  OR    rowid = p_subteam_row_id
  FOR  UPDATE NOWAIT;
*/


--get the ROWID for the row to be updated if
--p_subteam_row_id is not passed to the API.

 IF l_row_id IS NULL THEN

    OPEN get_row_id;

    FETCH get_row_id INTO l_row_id;

    CLOSE get_row_id;

 END IF;

  -- Increment the record version number by 1
  l_record_version_number :=  p_record_version_number +1;

  UPDATE pa_project_subteams
  SET name             = DECODE(p_subteam_name, FND_API.G_MISS_CHAR, name, p_subteam_name),

      record_version_number       = DECODE(p_record_version_number, NULL, record_version_number, l_record_version_number),

      object_type                 = DECODE(p_object_type, FND_API.G_MISS_CHAR, object_type, p_object_type),
      object_id                  = DECODE(p_object_id, FND_API.G_MISS_NUM, object_id, p_object_id),

      description                 = DECODE(p_description, FND_API.G_MISS_CHAR, description, p_description),

      attribute_category          = DECODE(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category),
      attribute1                  = DECODE(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1),
      attribute2                  = DECODE(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2),
      attribute3                  = DECODE(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3),
      attribute4                  = DECODE(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4),
      attribute5                  = DECODE(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5),
      attribute6                  = DECODE(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6),
      attribute7                  = DECODE(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7),
      attribute8                  = DECODE(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8),
      attribute9                  = DECODE(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9),
      attribute10                 = DECODE(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
      attribute11                 = DECODE(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11),
      attribute12                 = DECODE(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12),
      attribute13                 = DECODE(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13),
      attribute14                 = DECODE(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14),
      attribute15                 = DECODE(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15),
      last_update_date            = sysdate,
      last_updated_by             = fnd_global.user_id,
      last_update_login           = fnd_global.login_id
      WHERE  rowid = l_row_id
      AND    nvl(p_record_version_number, record_version_number) = record_version_number;
  --

  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Update_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
  --
END Update_Row;

PROCEDURE Delete_Row
( p_subteam_row_id           IN   ROWID
 ,p_subteam_id               IN   pa_project_subteams.project_subteam_id%TYPE
 ,p_record_version_number       IN   NUMBER  := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_row_id  ROWID;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;


/*
  -- Lock  the Subteam;
  SELECT rowid  INTO l_row_id
  FROM pa_project_subteams
  WHERE project_subteam_id = p_subteam_id
  FOR  UPDATE NOWAIT;
*/

  DELETE FROM  pa_project_subteams
  WHERE  project_subteam_id  = p_subteam_id
  OR     rowid = p_subteam_row_id;
  --AND    nvl(p_record_version_number, record_version_number) = record_version_number;

  --
  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA', p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_PROJECT_SUBTEAMS_PKG.Delete_Row');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;

--
--
END PA_PROJECT_SUBTEAMS_pkg;

/
