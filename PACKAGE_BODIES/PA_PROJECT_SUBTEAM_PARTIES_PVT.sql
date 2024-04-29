--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SUBTEAM_PARTIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SUBTEAM_PARTIES_PVT" AS
--$Header: PARTSPVB.pls 120.1 2005/08/19 17:01:44 mwasowic noship $

PROCEDURE Create_Subteam_Party
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

 p_project_subteam_id          IN     pa_project_subteams.Project_subteam_id%TYPE := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                 IN VARCHAR2 := 'Y',

 x_project_subteam_party_row_id  OUT    NOCOPY ROWID, --File.Sql.39 bug 4440895
 x_project_subteam_party_id      OUT    NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_name_count              NUMBER;
 l_msg_index_out           NUMBER;
 l_row_id                  ROWID;

 CURSOR check_primary_flag is
 select rowid
   from pa_project_subteam_parties
   where primary_subteam_flag = 'Y' and object_id = p_object_id
   and object_type = p_object_type;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SUBTEAM_PARTIES_PVT.Create_Subteam_Party');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_FALSE;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT STP_PVT_CREATE_STP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  --
  -- Check that mandatory project subteam id exists
  --
  IF p_project_subteam_id IS NULL
     OR p_project_subteam_id = FND_API.G_MISS_NUM THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_SBT_INV');
    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
  --ELSE
    --  SELECT  COUNT(*)
    --  INTO l_name_count
    --  FROM pa_project_subteams
    --  WHERE project_subteam_id = p_project_subteam_id;

    --  IF l_name_count < 1 then
    --    PA_UTILS.Add_Message( p_app_short_name => 'PA'
    --                     ,p_msg_name       => 'PA_SBP_ID_INV');
    --    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
    --  END IF;
  END IF;

  --
  -- Check that mandatory object_type is passed in
  --
  IF p_object_type IS NULL OR
     p_object_type = FND_API.G_MISS_CHAR OR
     (p_object_type <> 'PA_PROJECT_ASSIGNMENTS' and p_object_type <> 'PA_PROJECT_PARTIES') THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_OBJTYPE_INV');
    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
  ELSE
      --
      -- Check that mandatory object_id is passed in
      --
      IF p_object_id IS NULL OR
         p_object_id = FND_API.G_MISS_NUM THEN
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_OBJID_INV');
        PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
      --ELSE
        --if p_object_type = 'PA_PROJECT_ASSIGNMENTS' then
            --select count(*)
            --into l_name_count
            --from PA_PROJECT_ASSIGNMENTS
            --where assignment_id = p_object_id;

            --if l_name_count < 1 then
            --    PA_UTILS.Add_Message( p_app_short_name => 'PA'
            --             ,p_msg_name       => 'PA_SBP_OBJID_INV');
            --    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
            --end if;
        --elsif p_object_type = 'PA_PROJECT_PARTIES' then
            --select count(*)
            --into l_name_count
            --from PA_PROJECT_PARTIES
            --where project_party_id = p_object_id;

            --if l_name_count < 1 then
            --    PA_UTILS.Add_Message( p_app_short_name => 'PA'
            --             ,p_msg_name       => 'PA_SBP_OBJID_INV');
            --    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
            --end if;
        --end if;

      END IF;
  END IF;

  -- Check that for a given object_type and object_id,
  -- there is only one primary subteam
  if PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE
    and p_primary_subteam_flag = 'Y' then

     OPEN check_primary_flag;
     FETCH check_primary_flag INTO l_row_id;

     IF check_primary_flag%found THEN
	PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_PRIMARY_FLAG_INV');
	PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
     end if;
     CLOSE check_primary_flag;

  end if;


  -- Create the record if there is no error

  IF (p_validate_only <> FND_API.G_TRUE AND PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE) THEN
    PA_PROJECT_SUBTEAM_PARTIES_PKG.Insert_Row
    (
	 p_project_subteam_id           => p_project_subteam_id
	 ,p_object_type                 => p_object_type
	 ,p_object_id                   => p_object_id
	 ,p_primary_subteam_flag                => p_primary_subteam_flag
	 ,x_project_subteam_party_row_id        => x_project_subteam_party_row_id
	 ,x_project_subteam_party_id            => x_project_subteam_party_id
	 ,x_return_status               => x_return_status
	 ,x_msg_count                   => x_msg_count
	 ,x_msg_data                    => x_msg_data
  );

  END IF;
  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE THEN
    COMMIT;
  END IF;

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

  IF PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;



  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO STP_PVT_CREATE_STP;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAM_PARTIES_PVT.Create_Subteam_Party'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Create_Subteam_Party;


PROCEDURE Update_Subteam_Party
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

 p_project_subteam_party_row_id        IN     ROWID := null,

 p_project_subteam_party_id            IN     pa_project_subteam_parties.project_subteam_party_id%TYPE := FND_API.g_miss_num,

 p_project_subteam_id          IN     pa_project_subteam_parties.project_subteam_id%TYPE              := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                IN     VARCHAR2 := fnd_api.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := fnd_api.g_miss_num,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_record_version_number       OUT    NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

   l_count number;
   l_old_subteam_name pa_project_subteams.name%TYPE := FND_API.g_miss_char;
   l_name_count NUMBER;
   l_msg_index_out NUMBER;
   l_delete_flag NUMBER := 0;
   l_record_version_number NUMBER;
   l_row_id ROWID;

   CURSOR check_primary_key IS
       select rowid
	 from pa_project_subteam_parties
	 where primary_subteam_flag = 'Y' and object_id = p_object_id
	 and object_type = p_object_type AND
	 project_subteam_party_id <> p_project_subteam_party_id;


BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAM_PARTIES_PVT.Update_Subteam_Party');


  -- Initialize the error flag
  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT STP_PVT_UPDATE_STP;
  END IF;

  -- Check project_subteam_party_id IS NOT NULL
  IF p_project_subteam_party_id IS NULL OR p_project_subteam_party_id = fnd_api.g_miss_num THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_ID_INV');
    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
  END IF;

  -- Check project_subteam_id IS NOT NULL and exists
  IF p_project_subteam_id IS NULL OR p_project_subteam_id = fnd_api.g_miss_num THEN
     -- We need to call delete_subteam here
     l_delete_flag := 1;
  --ELSE
     --SELECT  COUNT(*)
     --INTO l_name_count
     --FROM pa_project_subteams
     --WHERE project_subteam_id =p_project_subteam_id;

     --IF l_name_count < 1 then
     --   PA_UTILS.Add_Message( p_app_short_name => 'PA'
--			      ,p_msg_name       => 'PA_SBP_SBT_INV');
	--PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
     --END IF;
  END IF;

  --
  -- Check that mandatory object_type is passed in
  --
  IF p_object_type IS NULL OR
     p_object_type = FND_API.G_MISS_CHAR OR
     (p_object_type <> 'PA_PROJECT_ASSIGNMENTS' and p_object_type <> 'PA_PROJECT_PARTIES') THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_OBJTYPE_INV');
    PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
  ELSE
      --
      -- Check that mandatory object_id is passed in
      --
      IF p_object_id IS NULL OR
         p_object_id = FND_API.G_MISS_NUM THEN
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_OBJID_INV');
        PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
      --ELSE
        --if p_object_type = 'PA_PROJECT_ASSIGNMENTS' then
        --    select count(*)
        --    into l_name_count
        --    from PA_PROJECT_ASSIGNMENTS
        --    where assignment_id = p_object_id;

        --    if l_name_count < 1 then
        --        PA_UTILS.Add_Message( p_app_short_name => 'PA'
        --                 ,p_msg_name       => 'PA_SBP_OBJID_INV');
        --       PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
	--    end if;
        --elsif p_object_type = 'PA_PROJECT_PARTIES' then
        --    select count(*)
        --    into l_name_count
        --    from PA_PROJECT_PARTIES
        --    where project_party_id = p_object_id;

        --    if l_name_count < 1 then
        --        PA_UTILS.Add_Message( p_app_short_name => 'PA'
        --                 ,p_msg_name       => 'PA_SBP_OBJID_INV');
        --        PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
        --    end if;
        --end if;

      END IF;
  END IF;

  -- Check that for a given object_type and object_id,
  -- there is only one primary subteam
  if PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE
    and p_primary_subteam_flag = 'Y' then

     OPEN check_primary_key;
     FETCH check_primary_key INTO l_row_id;

     IF check_primary_key%found THEN

                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_SBP_PRIMARY_FLAG_INV');
                PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
     end if;
     CLOSE check_primary_key;

  end if;


  if p_record_version_number = FND_API.G_MISS_NUM then
        l_record_version_number := NULL;
  else
        l_record_version_number := p_record_version_number;
  end if;

  IF (p_validate_only <> FND_API.G_TRUE AND l_delete_flag = 1) THEN
    PA_PROJECT_SUBTEAM_PARTIES_PKG.Delete_Row
    (
     p_project_subteam_party_row_id         => p_project_subteam_party_row_id
     ,p_project_subteam_party_id            => p_project_subteam_party_id
     ,p_record_version_number       => l_record_version_number
     ,x_return_status               => x_return_status
     ,x_msg_count                   => l_name_count
     ,x_msg_data                    => x_msg_data
     );
  ELSIF (p_validate_only <> FND_API.G_TRUE AND PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE) THEN

    PA_PROJECT_SUBTEAM_PARTIES_PKG.Update_Row
    (
     p_project_subteam_party_row_id         => p_project_subteam_party_row_id
     ,p_project_subteam_party_id            => p_project_subteam_party_id
     ,p_project_subteam_id                  => p_project_subteam_id
     ,p_primary_subteam_flag                => p_primary_subteam_flag
     ,p_record_version_number       => l_record_version_number
     ,x_return_status               => x_return_status
     ,x_msg_count                   => l_name_count
     ,x_msg_data                    => x_msg_data
  );
  END IF;
  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE THEN
    COMMIT;
  END IF;

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

  IF PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists = FND_API.G_TRUE  THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     SELECT record_version_number
     into  x_record_version_number
     FROM pa_project_subteam_parties
     WHERE project_subteam_party_id = p_project_subteam_party_id;

       --
     IF (SQL%NOTFOUND) THEN
       PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_TRUE;
     END IF;

  ELSE
     SELECT record_version_number
     into  x_record_version_number
     FROM pa_project_subteam_parties
     WHERE project_subteam_party_id = p_project_subteam_party_id;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO STP_PVT_UPDATE_STP;
        END IF;
        --
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_SUBTEAM_PARTIES_PVT.Update_Subteam'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Update_Subteam_Party;

PROCEDURE Update_SPT_Assgn
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

 p_project_subteam_party_row_id        IN     ROWID := null,

 p_project_subteam_party_id            IN     pa_project_subteam_parties.project_subteam_party_id%TYPE := NULL,

 p_project_subteam_id          IN     pa_project_subteam_parties.project_subteam_id%TYPE              := NULL,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,

 p_primary_subteam_flag                IN     VARCHAR2 := fnd_api.g_miss_char,

 p_record_version_number         IN     pa_project_subteams.record_version_number%TYPE := FND_API.G_MISS_NUM,

 p_get_subteam_party_id_flag     IN VARCHAR2 := 'N',

 x_project_subteam_party_id      OUT    NOCOPY pa_project_subteam_parties.project_subteam_party_id%TYPE,   --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_record_version_number       OUT    NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS
   l_project_subteam_party_row_id ROWID;
   l_record_version_number NUMBER;
   --l_project_subteam_party_id pa_project_subteam_parties.project_subteam_party_id%TYPE;
   --l_project_subteam_id pa_project_subteam_parties.project_subteam_id%TYPE;

   l_project_subteam_party_id number;
   l_project_subteam_id number;

   CURSOR get_subteam_party_id IS
      SELECT project_subteam_party_id
	From pa_project_subteam_parties
	WHERE object_id = p_object_id
	AND object_type = 'PA_PROJECT_ASSIGNMENTS'
	AND primary_subteam_flag = 'Y';

BEGIN

   if p_record_version_number = FND_API.G_MISS_NUM then
        l_record_version_number := NULL;
    else
        l_record_version_number := p_record_version_number;
   end if;

   IF p_project_subteam_party_id = fnd_api.g_miss_num then
      l_project_subteam_party_id := NULL;
   ELSE
      l_project_subteam_party_id := p_project_subteam_party_id;
   END IF;


   IF p_project_subteam_id = fnd_api.g_miss_num then
      l_project_subteam_id := NULL;
   ELSE
      l_project_subteam_id := p_project_subteam_id;
   END IF;


   IF (p_get_subteam_party_id_flag = 'Y') THEN
      -- select the subteam_party_id from the subteam_party table
      OPEN get_subteam_party_id;
      FETCH get_subteam_party_id INTO l_project_subteam_party_id;
      CLOSE get_subteam_party_id ;
   END IF;


   IF (l_project_subteam_party_id IS NULL  AND
       l_project_subteam_id IS NOT NULL) then
      -- insert subteam_party

	 pa_project_subteam_parties_pvt.create_subteam_party(

	      p_api_version => p_api_version,

	      p_init_msg_list => p_init_msg_list,

	      p_commit =>p_commit,


	      p_validate_only => p_validate_only,


	      p_validation_level => p_validation_level,

	      p_calling_module => p_calling_module,

              p_debug_mode => p_debug_mode,

	      p_max_msg_count => p_max_msg_count,

              p_project_subteam_id  => l_project_subteam_id,

	      p_object_type => p_object_type,
	      p_object_id => p_object_id,

	      p_primary_subteam_flag => p_primary_subteam_flag,

	      x_project_subteam_party_row_id => l_project_subteam_party_row_id,

	      x_project_subteam_party_id => x_project_subteam_party_id,
              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data	);
   ELSIF (l_project_subteam_party_id IS NOT NULL AND
	  l_project_subteam_id IS NOT NULL) then
      -- update subteam_party
	      pa_project_subteam_parties_pvt.update_subteam_party(

	      p_api_version => p_api_version,

	      p_init_msg_list => p_init_msg_list,

	      p_commit =>p_commit,

	      p_validate_only => p_validate_only,

	      p_validation_level => p_validation_level,

	      p_calling_module => p_calling_module,

              p_debug_mode => p_debug_mode,

	      p_max_msg_count => p_max_msg_count,

              p_project_subteam_party_row_id  => p_project_subteam_party_row_id,

              p_project_subteam_party_id => l_project_subteam_party_id,

	      p_project_subteam_id => l_project_subteam_id,

	      p_object_type => p_object_type,

	      p_object_id => p_object_id,

	      p_primary_subteam_flag => p_primary_subteam_flag,

              p_record_version_number  => l_record_version_number,

	      x_return_status  => x_return_status,
	      x_record_version_number => x_record_version_number,

              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data	);
   ELSIF (l_project_subteam_party_id IS NOT NULL AND
	  l_project_subteam_id IS NULL) then
      -- delete subteam_party
	    pa_project_subteam_parties_pvt.delete_subteam_party(

	      p_api_version => p_api_version,

	      p_init_msg_list => p_init_msg_list,

	      p_commit =>p_commit,


	      p_validate_only => p_validate_only,


	      p_validation_level => p_validation_level,

	      p_calling_module => p_calling_module,

              p_debug_mode => p_debug_mode,

	      p_max_msg_count => p_max_msg_count,

              p_project_subteam_party_row_id  => p_project_subteam_party_row_id,

              p_project_subteam_party_id => l_project_subteam_party_id,

              p_record_version_number  => l_record_version_number,

              x_return_status  => x_return_status,
              x_msg_count      => x_msg_count,
              x_msg_data       => x_msg_data	);
   END IF;

END Update_SPT_Assgn;


PROCEDURE Delete_Subteam_Party
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

 p_project_subteam_party_row_id              IN     ROWID := NULL,

 p_project_subteam_party_id                  IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,

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
 l_msg_index_out  NUMBER;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAM_PARTIES_PVT.Delete_Subteam_Party');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT STP_PVT_DELETE_STP;
  END IF;

  IF (p_validate_only <> FND_API.G_TRUE AND PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE) THEN

    if p_record_version_number = FND_API.G_MISS_NUM then
        l_record_version_number := NULL;
    else
        l_record_version_number := p_record_version_number;
    end if;


    -- Delete the master record
    PA_PROJECT_SUBTEAM_PARTIES_PKG.Delete_Row
      ( p_project_subteam_party_row_id     => p_project_subteam_party_row_id
	,p_project_subteam_party_id         => p_project_subteam_party_id
	,p_record_version_number => l_record_version_number
	,x_return_status => x_return_status
	,x_msg_count     => x_msg_count
	,x_msg_data      => x_msg_data
	);

    -- Commit if the flag is set and there is no error
    IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE THEN
       COMMIT;
    END IF;


  END IF;

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

  IF PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO STP_PVT_DELETE_STP;
        END IF;
        --
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAM_PARTIES_PVT.Delete_Subteam_Party'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Delete_Subteam_Party;


PROCEDURE Delete_SubteamParty_By_Obj
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2                                        := FND_API.g_false,

 p_validate_only               IN     VARCHAR2                                        := FND_API.g_true,

 p_validation_level            IN     NUMBER                                        := FND_API.g_valid_level_full,

 p_calling_module              IN     VARCHAR2
     := NULL,

 p_debug_mode                  IN     VARCHAR2 := 'N',

 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_object_type                 IN varchar2,

 p_object_id                   IN NUMBER := fnd_api.g_miss_num,


-- p_project_subteam_party_row_id              IN     ROWID := NULL,

-- p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM,

-- p_project_subteam_party_id                  IN     pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) IS


   CURSOR get_id IS
      SELECT project_subteam_party_id
	FROM   pa_project_subteam_parties
	WHERE  object_id = p_object_id
	AND object_type = p_object_type;

   --l_subteam_party_id                   pa_project_subteams.project_subteam_id%TYPE := fnd_api.g_miss_num;

   l_subteam_party_id                   NUMBER := fnd_api.g_miss_num;

   l_row_id ROWID;
   l_number NUMBER;
   l_msg_index_out NUMBER;

BEGIN

     -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROJECT_SUBTEAM_PARTIES_PVT.Delete_Subteam_Party');

  -- Initialize the error flag
  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists := FND_API.G_FALSE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT STP_PVT_DELETE_STP;
  END IF;

  IF (p_validate_only <> FND_API.G_TRUE ) THEN

     FOR subteam_p_id IN get_id LOOP

	 PA_PROJECT_SUBTEAM_PARTIES_PKG.Delete_Row
	     ( p_project_subteam_party_row_id     => l_row_id
	       ,p_project_subteam_party_id         =>  subteam_p_id.project_subteam_party_id
	       ,p_record_version_number => NULL
	       ,x_return_status => x_return_status
	       ,x_msg_count     => x_msg_count
	       ,x_msg_data      => x_msg_data
	       );
     END LOOP;

  END IF;

  -- Commit if the flag is set and there is no error
  IF p_commit = FND_API.G_TRUE AND  PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists <> FND_API.G_TRUE THEN
       COMMIT;
  END IF;

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

  IF PA_PROJECT_SUBTEAM_PARTIES_PVT.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO STP_PVT_DELETE_STP;
        END IF;
        --
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROJECT_SUBTEAM_PARTIES_PVT.Delete_Subteam_Party'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END;

--
--
END PA_PROJECT_SUBTEAM_PARTIES_PVT;

/
