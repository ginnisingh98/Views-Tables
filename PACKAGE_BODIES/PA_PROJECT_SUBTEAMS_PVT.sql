--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAMS_PVT" AS
 /*$Header: PARTSTVB.pls 120.2 2005/08/19 17:02:09 mwasowic ship $*/

PROCEDURE Create_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2  := FND_API.g_false,
 p_validate_only               IN     VARCHAR2  := FND_API.g_true,
 p_validation_level            IN     NUMBER    := FND_API.g_valid_level_full,
 p_calling_module              IN     VARCHAR2 := 'SELF_SERVICE',
 p_debug_mode                  IN     VARCHAR2 := 'N',
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
 p_subteam_name                IN     pa_project_subteams.name%TYPE    := FND_API.g_miss_char,
 p_object_type                 IN     pa_project_subteams.object_type%TYPE  := FND_API.g_miss_char,
 p_object_id                   IN     pa_project_subteams.object_id%TYPE     := FND_API.g_miss_num,
 p_description                 IN     pa_project_subteams.description%TYPE  := FND_API.g_miss_char,
 p_record_version_number       IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,
 p_attribute_category          IN     pa_project_subteams.attribute_category%TYPE    := FND_API.g_miss_char,
 p_attribute1                  IN pa_project_subteams.attribute1%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute2                  IN pa_project_subteams.attribute2%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute3                  IN pa_project_subteams.attribute3%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute4                  IN pa_project_subteams.attribute4%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute5                  IN pa_project_subteams.attribute5%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute6                  IN pa_project_subteams.attribute6%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute7                  IN pa_project_subteams.attribute7%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute8                  IN pa_project_subteams.attribute8%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute9                  IN pa_project_subteams.attribute9%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute10                 IN pa_project_subteams.attribute10%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute11                 IN pa_project_subteams.attribute11%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute12                 IN pa_project_subteams.attribute12%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute13                 IN pa_project_subteams.attribute13%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute14                 IN pa_project_subteams.attribute14%TYPE  := FND_API.G_MISS_CHAR,
 p_attribute15                 IN pa_project_subteams.attribute15%TYPE  := FND_API.G_MISS_CHAR,
 x_subteam_row_id              OUT    NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_new_subteam_id              OUT    NOCOPY pa_project_subteams.project_subteam_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 --l_name_count              NUMBER;

 l_rowid ROWID;

 CURSOR get_project is
   SELECT  rowid
   FROM pa_projects_all
   WHERE project_id =p_object_id;

 CURSOR get_project_subteam is
  SELECT  rowid
  FROM pa_project_subteams
  WHERE name =p_subteam_name
  AND object_type = p_object_type
  AND object_id = p_object_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PVT.Create_Subteam');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT SBT_PVT_CREATE_SBT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Project name to id is already done in the public API
  --

  --
  --
  -- Check that mandatory project id exists
  --
  IF ( (p_object_type is null OR p_object_type = FND_API.G_MISS_CHAR)
       OR (p_object_id IS NULL OR p_object_id = FND_API.G_MISS_NUM)) THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_PRJID_INV');
    PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

 If(p_object_type = 'PA_PROJECTS') then

    OPEN get_project;
    FETCH get_project INTO l_rowid;
    IF get_project%notfound THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_PRJID_INV');
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

    CLOSE get_project;

    --SELECT  COUNT(*)
    --  INTO l_name_count
    --  FROM pa_projects_all
    --  WHERE project_id =p_object_id;

 end if;
  --IF l_name_count < 1 then
  --  PA_UTILS.Add_Message( p_app_short_name => 'PA'
  --                       ,p_msg_name       => 'PA_SBT_PRJID_INV');
  --  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
 --END IF;


  --
  -- Check that mandatory subteam name is passed in
  --
  IF p_subteam_name IS NULL OR
     p_subteam_name = FND_API.G_MISS_CHAR THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_NAME_INV');
    PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  -- Check that subteam name is not used by existing record with the same
  -- project ID
  --

  OPEN get_project_subteam;
  FETCH get_project_subteam INTO l_rowid;

  IF get_project_subteam%found THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_NAME_INV');
     PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;
  CLOSE get_project_subteam;


  --SELECT  COUNT(*)
  --INTO l_name_count
  --FROM pa_project_subteams
  --WHERE name =p_subteam_name
  --AND object_type = 'PA_PROJECTS'
  --AND object_id = p_object_id;

  --IF l_name_count > 0 THEN
  --   PA_UTILS.Add_Message( p_app_short_name => 'PA'
  --                       ,p_msg_name       => 'PA_SBT_NAME_INV');
  --   PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  --END IF;


--dbms_output.put_line(l_assignment_rec.project_id);
--dbms_output.put_line('proj party return status is '||x_return_status);


  -- Create the record if there is no error

  IF (p_validate_only <> FND_API.G_TRUE AND PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE) THEN
    PA_PROJECT_SUBTEAMS_PKG.Insert_Row
    (p_subteam_name                => p_subteam_name
    ,p_object_type                 => p_object_type
    ,p_object_id                   => p_object_id
    ,p_description                 => p_description
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,x_subteam_row_id              => x_subteam_row_id
    ,x_new_subteam_id              => x_new_subteam_id
    ,x_return_status               => x_return_status
    ,x_msg_count                   => x_msg_count
    ,x_msg_data                    => x_msg_data
  );

  END IF;
  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;



  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO SBT_PVT_CREATE_SBT;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAMS_PVT.Create_Subteam'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Create_Subteam;


PROCEDURE Update_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_validation_level            IN     NUMBER   := FND_API.g_valid_level_full,
 p_calling_module              IN     VARCHAR2 := 'SELF_SERVICE',
 p_debug_mode                  IN     VARCHAR2 := 'N',
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,
 p_subteam_row_id              IN     ROWID := null,
 p_subteam_id                  IN     pa_project_subteams.project_subteam_id%TYPE := FND_API.g_miss_num,
 p_subteam_name                IN     pa_project_subteams.name%TYPE              := FND_API.g_miss_char,
 p_object_type                 IN     pa_project_subteams.object_type%TYPE       := FND_API.g_miss_char,
 p_object_id                   IN     pa_project_subteams.object_id%TYPE        := FND_API.g_miss_num,
 p_description                 IN     pa_project_subteams.description%TYPE       := FND_API.g_miss_char,
 p_record_version_number       IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,
 p_attribute_category          IN     pa_project_subteams.attribute_category%TYPE    := FND_API.g_miss_char,
 p_attribute1                  IN pa_project_subteams.attribute1%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute2                  IN pa_project_subteams.attribute2%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute3                  IN pa_project_subteams.attribute3%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute4                  IN pa_project_subteams.attribute4%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute5                  IN pa_project_subteams.attribute5%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute6                  IN pa_project_subteams.attribute6%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute7                  IN pa_project_subteams.attribute7%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute8                  IN pa_project_subteams.attribute8%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute9                  IN pa_project_subteams.attribute9%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute10                 IN pa_project_subteams.attribute10%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute11                 IN pa_project_subteams.attribute11%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute12                 IN pa_project_subteams.attribute12%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute13                 IN pa_project_subteams.attribute13%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute14                 IN pa_project_subteams.attribute14%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute15                 IN pa_project_subteams.attribute15%TYPE               := FND_API.G_MISS_CHAR,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 --x_record_version_number     OUT    NUMBER ,
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_count number;
   l_old_subteam_name pa_project_subteams.name%TYPE := FND_API.g_miss_char;
   --l_name_count NUMBER;
   l_rowid ROWID;

   CURSOR get_project is
     SELECT  rowid
     FROM pa_projects_all
     WHERE project_id =p_object_id;

   CURSOR get_project_subteam IS
      SELECT  rowid
    FROM pa_project_subteams
    WHERE name = p_subteam_name
    AND object_type = p_object_type
    AND object_id = p_object_id
    AND project_subteam_id <> p_subteam_id;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PVT.Update_Subteam');


  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT SBT_PVT_UPDATE_SBT;
  END IF;


  -- Check project_subteam_id IS NOT NULL
  IF p_subteam_id IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_ID_INV');
    PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  -- Check that mandatory subteam name is not null
  --
  IF p_subteam_name IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_SBT_NAME_INV');
    PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  -- Check that mandatory project id exists
  --
  IF ((p_object_type is null OR p_object_type=FND_API.g_miss_char)
     OR (p_object_id IS NULL OR p_object_id=FND_API.g_miss_num))   THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_PRJID_INV');
    PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.g_true;
  ELSE
     IF (p_object_type='PA_PROJECTS'
        AND p_object_id is not null
        AND p_object_id <> FND_API.g_miss_num )THEN

    OPEN get_project;
    FETCH get_project INTO l_rowid;
    IF get_project%notfound THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_PRJID_INV');
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

    CLOSE get_project;
      --SELECT  COUNT(*)
      --INTO l_name_count
      --FROM pa_projects_all
      --WHERE project_id =p_object_id;


    --  IF l_name_count < 1 then
      --   PA_UTILS.Add_Message( p_app_short_name => 'PA'
              --           ,p_msg_name       => 'PA_SBT_PRJID_INV');
        -- PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
      --END IF;
     END IF;
  END IF;

  --
  -- Check that the subteam name is not duplicated for the same object ID
  --
 -- SELECT name
 -- INTO l_old_subteam_name
 -- FROM pa_project_subteams
 -- WHERE project_subteam_id = p_subteam_id;

  --IF l_old_subteam_name <> p_subteam_name THEN

  -- p_subteam_name is a new name to be associated with subteam ID


  OPEN get_project_subteam;
  FETCH get_project_subteam INTO l_rowid;

  IF get_project_subteam%found THEN
     -- if the name is already taken by another subteam
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBT_NAME_INV');
     PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  CLOSE get_project_subteam;

  --SELECT COUNT(*)
  --INTO l_count
  --FROM pa_project_subteams
  --WHERE name = p_subteam_name
  --AND object_type = p_object_type
  --AND object_id = p_object_id
  --AND project_subteam_id <> p_subteam_id;

--  IF l_count > 0 THEN
      -- if the name is already taken by another subteam
    --     PA_UTILS.Add_Message( p_app_short_name => 'PA'
          --               ,p_msg_name       => 'PA_SBT_NAME_INV');
        -- PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  --END IF;
  --END IF;

  IF (p_validate_only = FND_API.G_FALSE AND PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE) THEN

    --dbms_output.put_line('Call table handler');

    PA_PROJECT_SUBTEAMS_PKG.Update_Row
    (p_subteam_row_id              => p_subteam_row_id
    ,p_subteam_id                  => p_subteam_id
    ,p_record_version_number       => p_record_version_number
    ,p_subteam_name                => p_subteam_name
    ,p_object_type                 => p_object_type
    ,p_object_id                   => p_object_id
    ,p_description                 => p_description
    ,p_attribute_category          => p_attribute_category
    ,p_attribute1                  => p_attribute1
    ,p_attribute2                  => p_attribute2
    ,p_attribute3                  => p_attribute3
    ,p_attribute4                  => p_attribute4
    ,p_attribute5                  => p_attribute5
    ,p_attribute6                  => p_attribute6
    ,p_attribute7                  => p_attribute7
    ,p_attribute8                  => p_attribute8
    ,p_attribute9                  => p_attribute9
    ,p_attribute10                 => p_attribute10
    ,p_attribute11                 => p_attribute11
    ,p_attribute12                 => p_attribute12
    ,p_attribute13                 => p_attribute13
    ,p_attribute14                 => p_attribute14
    ,p_attribute15                 => p_attribute15
    ,x_return_status               => x_return_status
    ,x_msg_count                   => x_msg_count
    ,x_msg_data                    => x_msg_data
  );
  END IF;
  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO SBT_PVT_UPDATE_SBT;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAMS_PVT.Update_Subteam'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Update_Subteam;


PROCEDURE Delete_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := 'SELF_SERVICE',

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_subteam_row_id              IN     ROWID := NULL,

 p_subteam_id                  IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,

 p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) IS

 l_count          NUMBER;
 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);
 l_record_version_number NUMBER;

 l_rowid ROWID;

 CURSOR get_project_subteam IS
    SELECT ROWID
      FROM pa_project_subteam_parties
      WHERE project_subteam_id = p_subteam_id ;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PVT.Delete_Subteam');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT SBT_PVT_DELETE_SBT;
  END IF;

  -- If the subteam belongs to any subteam_party table, we can not delete it
  l_count := 0;

  OPEN get_project_subteam;
  FETCH get_project_subteam INTO l_rowid;
  IF get_project_subteam%found THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
               ,p_msg_name       => 'PA_SBT_ID_INUSE');
     PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.g_true;
  END IF;

  CLOSE get_project_subteam;


  --BEGIN
  --SELECT 1
  --INTO l_count
  --FROM dual
  --WHERE exists(
    --SELECT project_subteam_id
    --FROM pa_project_subteam_parties
        --WHERE project_subteam_id = p_subteam_id );
  --exception when no_data_found then
   --             null;
  --END;

  --IF l_count >0  THEN
  --  PA_UTILS.Add_Message( p_app_short_name => 'PA'
  --                       ,p_msg_name       => 'PA_SBT_ID_INUSE');
  --  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  --END IF;


  IF (p_validate_only = FND_API.G_FALSE AND PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE) THEN

    if p_record_version_number = FND_API.G_MISS_NUM then
        l_record_version_number := NULL;
    else
        l_record_version_number := p_record_version_number;
    end if;

    -- Delete the master record
    PA_PROJECT_SUBTEAMS_PKG.Delete_Row
    ( p_subteam_row_id     => p_subteam_row_id
     ,p_subteam_id         => p_subteam_id
     ,p_record_version_number => l_record_version_number
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
    );

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAMS_PUB.g_error_exists <> FND_API.G_TRUE THEN
    COMMIT;
  END IF;


  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO SBT_PVT_DELETE_SBT;
        END IF;
        --
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAMS_PVT.Delete_Subteam'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Delete_Subteam;


PROCEDURE Get_Subteam_Id
(
 p_subteam_name    IN     pa_project_subteams.name%TYPE := fnd_api.g_miss_char,
 p_object_type     IN     pa_project_subteams.object_type%TYPE := fnd_api.g_miss_char,
 p_object_id       IN     pa_project_subteams.object_id%TYPE := fnd_api.g_miss_num,
 x_subteam_id                  OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) IS

  l_subteam_id NUMBER := NULL;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT project_subteam_id
   INTO l_subteam_id
   FROM pa_project_subteams
   WHERE name = p_subteam_name
   AND object_type=p_object_type
   AND object_id = p_object_id;

   x_subteam_id := l_subteam_id;

   EXCEPTION
    WHEN OTHERS THEN
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Get_Subteam_Id;

--
--
END PA_PROJECT_SUBTEAMS_PVT;

/
