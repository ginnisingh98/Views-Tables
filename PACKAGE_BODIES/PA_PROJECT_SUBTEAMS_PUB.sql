--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAMS_PUB" AS
--$Header: PARTSTPB.pls 120.1 2005/09/28 04:53:18 sunkalya noship $

PROCEDURE Create_Subteam
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_validation_level            IN     NUMBER   := FND_API.g_valid_level_full,
 p_calling_module              IN     VARCHAR2 := 'SELF_SERVICE',
 p_debug_mode                  IN     VARCHAR2 := 'N',
 p_max_msg_count               IN     NUMBER   := FND_API.g_miss_num,
 p_subteam_name                IN     pa_project_subteams.name%TYPE        := FND_API.g_miss_char,
 p_object_type                 IN     pa_project_subteams.object_type%TYPE := FND_API.g_miss_char,
 p_object_id                   IN     pa_project_subteams.object_id%TYPE   := FND_API.g_miss_num,
 --p_project_number            IN     VARCHAR2   := FND_API.g_miss_char,
 p_object_name                 IN     VARCHAR2   := FND_API.g_miss_char,
 p_description                 IN     pa_project_subteams.description%TYPE := FND_API.g_miss_char,
 p_record_version_number       IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,
 p_attribute_category          IN     pa_project_subteams.attribute_category%TYPE    := FND_API.g_miss_char,
 p_attribute1                  IN pa_project_subteams.attribute1%TYPE      := FND_API.G_MISS_CHAR,
 p_attribute2                  IN pa_project_subteams.attribute2%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute3                  IN pa_project_subteams.attribute3%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute4                  IN pa_project_subteams.attribute4%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute5                  IN pa_project_subteams.attribute5%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute6                  IN pa_project_subteams.attribute6%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute7                  IN pa_project_subteams.attribute7%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute8                  IN pa_project_subteams.attribute8%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute9                  IN pa_project_subteams.attribute9%TYPE   := FND_API.G_MISS_CHAR,
 p_attribute10                 IN pa_project_subteams.attribute10%TYPE := FND_API.G_MISS_CHAR,
 p_attribute11                 IN pa_project_subteams.attribute11%TYPE := FND_API.G_MISS_CHAR,
 p_attribute12                 IN pa_project_subteams.attribute12%TYPE := FND_API.G_MISS_CHAR,
 p_attribute13                 IN pa_project_subteams.attribute13%TYPE := FND_API.G_MISS_CHAR,
 p_attribute14                 IN pa_project_subteams.attribute14%TYPE := FND_API.G_MISS_CHAR,
 p_attribute15                 IN pa_project_subteams.attribute15%TYPE := FND_API.G_MISS_CHAR,
--Bug: 4537865
 x_new_subteam_id              OUT NOCOPY    pa_project_subteams.project_subteam_id%TYPE,
 x_subteam_row_id              OUT NOCOPY   ROWID,
 x_return_status               OUT NOCOPY   VARCHAR2,
 x_msg_count                   OUT NOCOPY   NUMBER,
 x_msg_data                    OUT NOCOPY   VARCHAR2
--Bug: 4537865
)
IS

 l_object_id                  number      := FND_API.g_miss_num;
 l_msg_index_out              NUMBER;
 l_error_message_code         varchar2(30);
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PUB.Create_Subteam');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
     --DBMS_OUTPUT.Put_Line('Commit is set to '||FND_API.G_TRUE);
     SAVEPOINT   SBT_PUB_CREATE_SUBTEAM;
  END IF;

  -- Do all Value to ID conversions and validations
  IF ((p_object_id IS NULL OR p_object_id = FND_API.G_MISS_NUM)
     AND (p_object_name IS NOT NULL AND p_object_name <> FND_API.G_MISS_CHAR)) THEN
     pa_project_subteam_utils.get_object_id(p_object_type => p_object_type
					   ,p_object_id   => l_object_id
					   ,p_object_name => p_object_name
					   ,x_return_status => x_return_status
					   ,x_error_message_code => l_error_message_code);
     if(x_return_status = FND_API.G_RET_STS_ERROR) then
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => l_error_message_code);
       PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
       return;
     end if;
    /****
     l_project_id := PA_UTILS.GetProjId (x_project_num => p_project_number);
    ELSIF (p_project_id IS NULL OR p_project_id = FND_API.G_MISS_NUM)
     AND p_project_name IS NOT NULL THEN

     SELECT project_id
     INTO l_project_id
     FROM pa_projects_all
     WHERE name = p_project_name;
    *****/
  ELSE
     l_object_id := p_object_id;
  END IF;


  -- Call the private package
  PA_PROJECT_SUBTEAMS_PVT.Create_Subteam
  (
   p_api_version                   => p_api_version
   ,p_init_msg_list                => p_init_msg_list
   ,p_commit                       => p_commit
   ,p_validate_only                => p_validate_only
   ,p_validation_level               => p_validation_level
   ,p_calling_module               => p_calling_module
   ,p_debug_mode                   => p_debug_mode
   ,p_max_msg_count                => p_max_msg_count
   ,p_subteam_name                 => p_subteam_name
   ,p_object_type                  => p_object_type
   ,p_object_id                   => l_object_id
   ,p_description                  => p_description
   ,p_record_version_number        => p_record_version_number
   ,p_attribute_category           => p_attribute_category
   ,p_attribute1                   => p_attribute1
   ,p_attribute2                   => p_attribute2
   ,p_attribute3                   => p_attribute3
   ,p_attribute4                   => p_attribute4
   ,p_attribute5                   => p_attribute5
   ,p_attribute6                   => p_attribute6
   ,p_attribute7                   => p_attribute7
   ,p_attribute8                   => p_attribute8
   ,p_attribute9                   => p_attribute9
   ,p_attribute10                  => p_attribute10
   ,p_attribute11                  => p_attribute11
   ,p_attribute12                  => p_attribute12
   ,p_attribute13                  => p_attribute13
   ,p_attribute14                  => p_attribute14
   ,p_attribute15                  => p_attribute15
   ,x_new_subteam_id               => x_new_subteam_id
   ,x_subteam_row_id               => x_subteam_row_id
   ,x_return_status                => x_return_status
   ,x_msg_count                    => x_msg_count
   ,x_msg_data                     => x_msg_data
 );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO SBT_PUB_CREATE_SUBTEAM;
        END IF;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAMS_PUB.Create_Subteam'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END Create_Subteam;


PROCEDURE Update_Subteam
(
 p_api_version           IN     NUMBER :=  1.0,
 p_init_msg_list         IN     VARCHAR2 			:= fnd_api.g_true,
 p_commit                IN     VARCHAR2                        := FND_API.g_false,
 p_validate_only         IN     VARCHAR2                        := FND_API.g_true,
 p_validation_level      IN     NUMBER                          := FND_API.g_valid_level_full,
 p_calling_module        IN     VARCHAR2 			:= 'SELF_SERVICE',
 p_debug_mode            IN     VARCHAR2 			:= 'N',
 p_max_msg_count         IN     NUMBER 				:= FND_API.g_miss_num,
 p_subteam_row_id        IN     ROWID 				:= NULL,
 p_subteam_id            IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,
 p_subteam_name          IN     pa_project_subteams.name%TYPE   := FND_API.g_miss_char,
 p_object_type           IN     pa_project_subteams.object_type%TYPE   := FND_API.g_miss_char,
 p_object_id             IN     pa_project_subteams.object_id%TYPE  := FND_API.g_miss_num,
 p_object_name           IN     VARCHAR2                        := FND_API.g_miss_char,
 p_description           IN     pa_project_subteams.description%TYPE  := FND_API.g_miss_char,
 p_record_version_number IN     pa_project_subteams.record_version_number%TYPE := FND_API.g_miss_num,
 p_attribute_category    IN     pa_project_subteams.attribute_category%TYPE    := FND_API.g_miss_char,
 p_attribute1            IN     pa_project_subteams.attribute1%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute2            IN     pa_project_subteams.attribute2%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute3            IN     pa_project_subteams.attribute3%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute4            IN     pa_project_subteams.attribute4%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute5            IN     pa_project_subteams.attribute5%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute6            IN     pa_project_subteams.attribute6%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute7            IN     pa_project_subteams.attribute7%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute8            IN     pa_project_subteams.attribute8%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute9            IN     pa_project_subteams.attribute9%TYPE                := FND_API.G_MISS_CHAR,
 p_attribute10           IN     pa_project_subteams.attribute10%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute11           IN     pa_project_subteams.attribute11%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute12           IN     pa_project_subteams.attribute12%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute13           IN     pa_project_subteams.attribute13%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute14           IN     pa_project_subteams.attribute14%TYPE               := FND_API.G_MISS_CHAR,
 p_attribute15           IN     pa_project_subteams.attribute15%TYPE               := FND_API.G_MISS_CHAR,
 --Bug: 4537865
 x_return_status         OUT 		NOCOPY    	VARCHAR2,
 x_msg_count             OUT 		NOCOPY    	NUMBER,
 --x_record_version_number      OUT 	NOCOPY   	NUMBER,
 x_msg_data              OUT  		NOCOPY  	VARCHAR2
 --Bug: 4537865
)
IS

CURSOR check_record_version IS
SELECT ROWID
FROM   pa_project_subteams
WHERE  (project_subteam_id = p_subteam_id
	OR ROWID = p_subteam_row_id)
	AND    record_version_number = p_record_version_number;

l_subteam_row_id ROWID := NULL;
l_object_id     number                   := FND_API.g_miss_num;
l_msg_index_out number;
 l_error_message_code         varchar2(30);
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PUB.Update_Subteam');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   SBT_PUB_UPDATE_SUBTEAM;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN check_record_version;

  FETCH check_record_version INTO l_subteam_row_id;

  IF check_record_version%NOTFOUND THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
     PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
  ELSE
     -- Do all Value to ID conversions and validations
     IF (p_object_id IS NULL OR p_object_id = FND_API.G_MISS_NUM)
       AND (p_object_name IS NOT NULL AND p_object_name <> FND_API.G_MISS_CHAR) THEN
       pa_project_subteam_utils.get_object_id(p_object_type => p_object_type
                                           ,p_object_id   => l_object_id
                                           ,p_object_name => p_object_name
                                           ,x_return_status => x_return_status
                                           ,x_error_message_code => l_error_message_code);
       if(x_return_status = FND_API.G_RET_STS_ERROR) then
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>l_error_message_code );
          PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;
          return;
       end if;
    	--l_project_id := PA_UTILS.GetProjId (x_project_num => p_project_number);
     ELSE
        l_object_id := p_object_id;
     END IF;


    -- Call the private package
     PA_PROJECT_SUBTEAMS_PVT.Update_Subteam
       (
	p_api_version                   => p_api_version
	,p_init_msg_list                => p_init_msg_list
	,p_commit                       => p_commit
	,p_validate_only                => p_validate_only
	,p_validation_level             => p_validation_level
	,p_calling_module               => p_calling_module
	,p_debug_mode                   => p_debug_mode
	,p_max_msg_count                => p_max_msg_count

	,p_subteam_row_id               => l_subteam_row_id
        ,p_subteam_id                   => p_subteam_id
	,p_subteam_name                 => p_subteam_name
	,p_object_type                 => p_object_type
	,p_object_id                   => l_object_id
	,p_description                  => p_description
	,p_record_version_number        => p_record_version_number
	,p_attribute_category           => p_attribute_category
	,p_attribute1                   => p_attribute1
	,p_attribute2                   => p_attribute2
	,p_attribute3                   => p_attribute3
	,p_attribute4                   => p_attribute4
	,p_attribute5                   => p_attribute5
       ,p_attribute6                   => p_attribute6
       ,p_attribute7                   => p_attribute7
       ,p_attribute8                   => p_attribute8
       ,p_attribute9                   => p_attribute9
       ,p_attribute10                  => p_attribute10
       ,p_attribute11                  => p_attribute11
       ,p_attribute12                  => p_attribute12
       ,p_attribute13                  => p_attribute13
       ,p_attribute14                  => p_attribute14
       ,p_attribute15                  => p_attribute15
       ,x_return_status                => x_return_status
       ,x_msg_count                    => x_msg_count
     --  ,x_record_version_number        => x_record_version_number
       ,x_msg_data                     => x_msg_data
	);

  END IF;

  CLOSE check_record_version;
  --
  -- IF the number of messaages is 1 then fetch the message code from the
  -- stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    /***
     SELECT record_version_number
     into  x_record_version_number
     FROM pa_project_subteams
     WHERE project_subteam_id = p_subteam_id;

  ELSE
        x_record_version_number := p_record_version_number + 1;
   **/
  END IF;

  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO  SBT_PUB_UPDATE_SUBTEAM;
        END IF;

      -- Set the exception Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_PROJECT_SUBTEAMS_PUB.Update_Subteam'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --
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

 p_subteam_row_id           IN     ROWID                                           := NULL,

 p_subteam_id               IN     pa_project_subteams.project_subteam_id%TYPE       := FND_API.G_MISS_NUM,

 p_object_type             IN pa_project_subteams.object_type%TYPE := fnd_api.g_miss_char,
 p_object_id                  IN     pa_project_subteams.object_id%TYPE                   := FND_API.g_miss_num,

 p_subteam_name             IN pa_project_subteams.name%TYPE := fnd_api.g_miss_char,

 p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM ,

--Bug: 4537865
 x_return_status               OUT NOCOPY   VARCHAR2,

 x_msg_count                   OUT NOCOPY   NUMBER,

 x_msg_data                    OUT NOCOPY   VARCHAR2
 --Bug: 4537865
) IS

 l_subteam_row_id              ROWID;
 l_msg_index_out               NUMBER;

CURSOR check_subteam IS
SELECT ROWID
FROM   pa_project_subteams
WHERE  (project_subteam_id = p_subteam_id AND p_subteam_id IS NOT NULL)
  OR (name = p_subteam_name
      AND p_subteam_name IS NOT NULL
      AND object_type = p_object_type
      AND object_id   = p_object_id
      AND p_object_id IS NOT null)
  OR ROWID = p_subteam_row_id ;


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PUB.Delete_Subteam');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   SBT_PUB_DELETE_SUBTEAM;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN check_subteam;

  FETCH check_subteam INTO l_subteam_row_id;

  IF check_subteam%NOTFOUND THEN

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
      PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;

   ELSE

     -- Call the private API
     PA_PROJECT_SUBTEAMS_PVT.Delete_Subteam
     (
      p_api_version      => p_api_version
      ,p_init_msg_list   => p_init_msg_list
      ,p_commit                => p_commit
      ,p_validate_only         => p_validate_only
      ,p_validation_level         => p_validation_level
      ,p_calling_module        => p_calling_module
      ,p_debug_mode        => p_debug_mode
      ,p_max_msg_count     => p_max_msg_count
      ,p_subteam_row_id     => l_subteam_row_id
      ,p_subteam_id         => p_subteam_id
      ,p_record_version_number  => p_record_version_number
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      );


  END IF;

  CLOSE check_subteam;
  --
  -- IF the number of messages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


   -- Put any message text from message stack into the Message ARRAY
   --
   EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO SBT_PUB_DELETE_SUBTEAM;
         END IF;
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_SUBTEAMS_PUB.Delete_Subteam'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs
--
END Delete_Subteam;

PROCEDURE Delete_Subteam_By_Obj
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

 p_object_type             IN pa_project_subteams.object_type%TYPE := fnd_api.g_miss_char,
 p_object_id                  IN     pa_project_subteams.object_id%TYPE                   := FND_API.g_miss_num,

 --Bug: 4537865
 x_return_status               OUT NOCOPY    VARCHAR2,

 x_msg_count                   OUT NOCOPY   NUMBER,

 x_msg_data                    OUT NOCOPY   VARCHAR2
 --Bug: 4537865
) IS

 l_subteam_row_id              ROWID;
 l_msg_index_out               NUMBER;

CURSOR check_subteam IS
SELECT ROWID
FROM   pa_project_subteams
WHERE
      object_type = p_object_type
      AND object_id   = p_object_id ;


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAMS_PUB.Delete_Subteam_By_Obj');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_FALSE;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   SBT_PUB_DELETE_SUBTEAM_BY_OBJ;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN check_subteam;

  LOOP
     FETCH check_subteam INTO l_subteam_row_id;
     EXIT WHEN check_subteam%notfound;

     --IF check_subteam%NOTFOUND THEN

	--PA_UTILS.Add_Message( p_app_short_name => 'PA'
--                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
	--PA_PROJECT_SUBTEAMS_PUB.g_error_exists := FND_API.G_TRUE;

      --ELSE

	-- Call the private API
	PA_PROJECT_SUBTEAMS_PVT.Delete_Subteam
	(
	 p_api_version      => p_api_version
	 ,p_init_msg_list   => p_init_msg_list
	 ,p_commit                => p_commit
	 ,p_validate_only         => p_validate_only
	 ,p_validation_level         => p_validation_level
	 ,p_calling_module        => p_calling_module
	 ,p_debug_mode        => p_debug_mode
	 ,p_max_msg_count     => p_max_msg_count
	 ,p_subteam_row_id     => l_subteam_row_id
	 --,p_subteam_id         => p_subteam_id
	 --,p_record_version_number  => p_record_version_number
	 ,x_return_status         => x_return_status
	 ,x_msg_count             => x_msg_count
	 ,x_msg_data              => x_msg_data
	 );
  END LOOP;

  CLOSE check_subteam;

  --
  -- IF the number of messages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_PROJECT_SUBTEAMS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


   -- Put any message text from message stack into the Message ARRAY
   --
   EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO SBT_PUB_DELETE_SUBTEAM_BY_OBJ;
         END IF;
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_SUBTEAMS_PUB.Delete_Subteam_By_Obj'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs
--
END Delete_Subteam_By_Obj;

--
--
END pa_project_subteams_pub;
--

/
