--------------------------------------------------------
--  DDL for Package Body PA_ROLE_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_PROFILES_PKG" AS
-- $Header: PARPRPKB.pls 120.1 2005/08/19 16:59:10 mwasowic noship $
--
--  PROCEDURE
--              Insert_Row1
--  PURPOSE
--              This procedure inserts a row into the pa_role_profiles
--              table.

PROCEDURE Insert_Row1
( p_profile_name            IN  VARCHAR,
  p_description             IN  VARCHAR2,
  p_effective_start_date    IN  DATE,
  p_effective_end_date      IN  DATE DEFAULT NULL,
  p_profile_type_code       IN  VARCHAR2 DEFAULT NULL,
  p_approval_status_code    IN  VARCHAR2 DEFAULT NULL,
  p_business_group_id       IN  NUMBER DEFAULT NULL,
  p_organization_id         IN  NUMBER DEFAULT NULL,
  p_job_id                  IN  NUMBER DEFAULT NULL,
  p_position_id             IN  NUMBER DEFAULT NULL,
  p_resource_id             IN  NUMBER DEFAULT NULL,
  x_profile_id              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status           OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO pa_role_profiles
          (profile_id,
           profile_name,
           description,
           effective_start_date,
           effective_end_date,
           profile_type_code,
           approval_status_code,
           business_group_id,
           organization_id,
           job_id,
           position_id,
           resource_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by)
   VALUES
          (PA_ROLE_PROFILES_S.nextval,
           p_profile_name,
           p_description,
           p_effective_start_date,
           p_effective_end_date,
           p_profile_type_code,
           p_approval_status_code,
           p_business_group_id,
           p_organization_id,
           p_job_id,
           p_position_id,
           p_resource_id,
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID)
   RETURNING
      profile_id INTO x_profile_id;

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ROLE_PROFILES_PKG.Insert_Row1'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Insert_Row1;


--
--  PROCEDURE
--              Insert_Row2
--  PURPOSE
--              This procedure inserts a row into the pa_role_profile_lines
--              table.

PROCEDURE Insert_Row2
( p_profile_id              IN  NUMBER,
  p_project_role_id         IN  NUMBER,
  p_role_weighting          IN  NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO pa_role_profile_lines
         (profile_id,
          project_role_id,
          role_weighting,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by)
       VALUES
         (p_profile_id,
          p_project_role_id,
          p_role_weighting,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID);

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ROLE_PROFILES_PKG.Insert_Row2'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Insert_Row2;


--
--  PROCEDURE
--              Update_Row
--  PURPOSE
--              This procedure updates a row in the pa_role_profiles
--              table.

PROCEDURE Update_Row
( p_profile_id              IN  NUMBER,
  p_profile_name            IN  VARCHAR,
  p_description             IN  VARCHAR2,
  p_effective_start_date    IN  DATE,
  p_effective_end_date      IN  DATE DEFAULT NULL,
--  p_profile_type_code       IN  VARCHAR2 DEFAULT NULL,
  p_approval_status_code    IN  VARCHAR2 DEFAULT NULL,
  p_business_group_id       IN  NUMBER DEFAULT NULL,
  p_organization_id         IN  NUMBER DEFAULT NULL,
  p_job_id                  IN  NUMBER DEFAULT NULL,
  p_position_id             IN  NUMBER DEFAULT NULL,
  p_resource_id             IN  NUMBER DEFAULT NULL,
  x_return_status           OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE pa_role_profiles SET
         profile_name         = p_profile_name,
         description          = p_description,
         effective_start_date = p_effective_start_date,
         effective_end_date   = p_effective_end_date,
         approval_status_code = p_approval_status_code,
         business_group_id    = p_business_group_id,
         organization_id      = p_organization_id,
         job_id               = p_job_id,
         position_id          = p_position_id,
         resource_id          = p_resource_id,
         last_update_date     = SYSDATE,
         last_updated_by      = FND_GLOBAL.USER_ID
  WHERE  profile_id = p_profile_id;

  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ROLE_PROFILES_PKG.Update_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Update_Row;



/*******************************************************************************
 Beginning of Angie's code, need to change later
******************************************************************************/

/**********************************************************************
 * This procedure will launch workflow to add a new Resource Role Profile
 * and Role Profile Lines to PA_ROLE_PROFILES and PA_ROLE_PROFILE_LINES
 * after proper validation.
 * This will be called from 'Add Resource Role Profile' page of PJR.
 **********************************************************************/
/*
PROCEDURE Add_Res_Profiles
( p_resource_id            IN  NUMBER,
  p_profile_name           IN  VARCHAR2,
  p_profile_type_code      IN  VARCHAR2,
  p_description            IN  VARCHAR2         := NULL,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE             := NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_commit                 IN  VARCHAR2          := FND_API.G_FALSE,
  x_return_status          OUT VARCHAR2,
  x_msg_count              OUT NUMBER,
  x_msg_data               OUT VARCHAR2)
IS
  CURSOR is_conflict_profile_csr IS
      SELECT 'Y'
      FROM   pa_role_profiles
      WHERE  resource_id = p_resource_id
        AND  profile_type_code = p_profile_type_code
        AND  (TRUNC(effective_start_date) BETWEEN TRUNC(p_effective_start_date)
              AND NVL(TRUNC(p_effective_end_date), TRUNC(effective_start_date))
              OR
              TRUNC(p_effective_start_date) BETWEEN TRUNC(effective_start_date)
              AND NVL(TRUNC(effective_end_date), TRUNC(effective_start_date)) )
        AND rownum = 1;

  l_profile_id             NUMBER;
  l_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
  l_exists                 VARCHAR2(1);
  l_return_status          VARCHAR2(1);
  l_msg_index_out          NUMBER := 0;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  -------------------------------------------------------------------
  -- Initial Setup
  -------------------------------------------------------------------
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_ROLE_PROFILES_PUB.Add_Res_Profile');
  END IF;
  dbms_output.put_line('started');

  -- Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  -- Issue API savepoint if the transaction is to be committed
  IF (p_commit = FND_API.G_TRUE) THEN
    SAVEPOINT ROLE_PUB_ADD_RES_PRF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -------------------------------------------------------------------
  -- Validate Resource Profile (any conflicting profile?)
  -------------------------------------------------------------------
  OPEN is_conflict_profile_csr;
  FETCH is_conflict_profile_csr INTO l_exists;
  dbms_output.put_line('after cursor');

  IF is_conflict_profile_csr%FOUND THEN
     dbms_output.put_line('corsor found');
     pa_utils.add_message (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_DATE_CONFLICT');
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE is_conflict_profile_csr;

  dbms_output.put_line('corsor found passed');

  -------------------------------------------------------------------
  -- Validate Resource Profile Lines (role_id/name, total weighting)
  -------------------------------------------------------------------
  Validate_Profile_Lines
         ( p_role_id_tbl             =>  p_role_id_tbl,
           p_role_name_tbl           =>  p_role_name_tbl,
           p_weighting_tbl           =>  p_weighting_tbl,
           x_role_id_tbl             =>  l_role_id_tbl,
           x_return_status           =>  l_return_status);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  dbms_output.put_line('Validate_Profile_Lines passed');

  -------------------------------------------------------------------
  -- Start Workflow  : workflow api should be called instead below
  -------------------------------------------------------------------

  -------------------------------------------------------------------
  -- Insert Resource Profile to 'PA_ROLE_PROFILES'
  -------------------------------------------------------------------
  INSERT INTO pa_role_profiles
          (profile_id,
           profile_name,
           profile_type_code,
           resource_id,
           description,
           effective_start_date,
           effective_end_date,
           approval_status_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by)
  VALUES
          (PA_ROLE_PROFILES_S.nextval,
           p_profile_name,
           p_profile_type_code,
           p_resource_id,
           p_description,
           p_effective_start_date,
           p_effective_end_date,
           'ASGMT_APPRVL_APPROVED', -- should be changed
           SYSDATE,
           FND_GLOBAL.USER_ID,
           SYSDATE,
           FND_GLOBAL.USER_ID)
  RETURNING
     profile_id INTO l_profile_id;
  dbms_output.put_line('after inserting pa_role_profiles, l_profile_id:'||l_profile_id);

  -------------------------------------------------------------------
  -- Insert Resource Profile Lines to 'PA_ROLE_PROFILE_LINES'
  -------------------------------------------------------------------
  FOR i IN 1..l_role_id_tbl.count LOOP
     INSERT INTO pa_role_profile_lines
              (profile_id,
               project_role_id,
               role_weighting,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
     VALUES
              (l_profile_id,
               l_role_id_tbl(i),
               p_weighting_tbl(i),
               SYSDATE,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID);
  END LOOP;

  -------------------------------------------------------------------
  -- Exceptions
  -------------------------------------------------------------------
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages (p_encoded        => FND_API.G_TRUE,
                                                p_msg_index      => 1,
                                                p_data           => x_msg_data,
                                                p_msg_index_out  => l_msg_index_out );
        END IF;
     WHEN OTHERS THEN
        dbms_output.put_line('other error');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data      := SQLERRM;
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ROLE_PUB_ADD_RES_PRF;
        END IF;

        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_ROLE_PROFILES_PUB.Add_Res_Profiles'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        RAISE;  -- This is optional depending on the needs

END Add_Res_Profiles;
*/

/**********************************************************************
 * This procedure will launch workflow to update the Resource Role Profile
 * and Role Profile Lines in PA_ROLE_PROFILES and PA_ROLE_PROFILE_LINES
 * after proper validation.
 * This will be called from 'Update Resource Role Profile' page of PJR.
 **********************************************************************/
/*
PROCEDURE Update_Res_Profiles
( p_profile_id             IN  NUMBER,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2         := NULL,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE             := NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_commit                 IN  VARCHAR2         := FND_API.G_FALSE,
  x_return_status          OUT VARCHAR2,
  x_msg_count              OUT NUMBER,
  x_msg_data               OUT VARCHAR2)
IS
  CURSOR is_conflict_profile_csr IS
      SELECT 'Y'
      FROM   pa_role_profiles pf1,
             pa_role_profiles pf2
      WHERE  pf2.profile_id = p_profile_id
        AND  pf1.resource_id = pf2.resource_id
        AND  pf1.profile_type_code = pf2.profile_type_code
        AND  pf1.profile_id <> p_profile_id
        AND  (TRUNC(pf1.effective_start_date) BETWEEN TRUNC(p_effective_start_date)
              AND NVL(TRUNC(p_effective_end_date), TRUNC(pf1.effective_start_date))
              OR
              TRUNC(p_effective_start_date) BETWEEN TRUNC(pf1.effective_start_date)
              AND NVL(TRUNC(pf1.effective_end_date), TRUNC(pf1.effective_start_date)))
        AND rownum = 1;

  l_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
  l_exists                 VARCHAR2(1) := 'N';
  l_return_status          VARCHAR2(1);
  l_msg_index_out          NUMBER := 0;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  -------------------------------------------------------------------
  -- Initial Setup
  -------------------------------------------------------------------
  IF l_enable_log = 'Y' THEN
  PA_DEBUG.init_err_stack('PA_ROLE_PROFILES_PUB.Update_Res_Profile');
  END IF;

  -- Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  -- Issue API savepoint if the transaction is to be committed
  IF (p_commit = FND_API.G_TRUE) THEN
    SAVEPOINT ROLE_PUB_UPD_RES_PRF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -------------------------------------------------------------------
  -- Validate Resource Profile (start_date, end_date)
  -------------------------------------------------------------------
  -- Check if there is any conflicting profile of this resource and profile_type
  OPEN is_conflict_profile_csr;
  FETCH is_conflict_profile_csr INTO l_exists;

  IF is_conflict_profile_csr%FOUND THEN
     pa_utils.add_message (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_DATE_CONFLICT');
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE is_conflict_profile_csr;

  -------------------------------------------------------------------
  -- Validate Resource Profile Lines (role_id/name, total weighting)
  -------------------------------------------------------------------
  Validate_Profile_Lines
         ( p_role_id_tbl             =>  p_role_id_tbl,
           p_role_name_tbl           =>  p_role_name_tbl,
           p_weighting_tbl           =>  p_weighting_tbl,
           x_role_id_tbl             =>  l_role_id_tbl,
           x_return_status           =>  l_return_status);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -------------------------------------------------------------------
  -- Start Workflow
  -------------------------------------------------------------------

  -------------------------------------------------------------------
  -- Update Resource Profile to 'PA_ROLE_PROFILES'
  -------------------------------------------------------------------
  UPDATE pa_role_profiles
  SET    profile_name         = p_profile_name,
         description          = p_description,
         effective_start_date = p_effective_start_date,
         effective_end_date   = p_effective_end_date,
         approval_status_code = 'ASGMT_APPRVL_APPROVED', -- should be changed
         last_update_date     = SYSDATE,
         last_updated_by      = FND_GLOBAL.USER_ID
  WHERE  profile_id = p_profile_id;

  -------------------------------------------------------------------
  -- Insert Resource Profile Lines to 'PA_ROLE_PROFILE_LINES'
  -------------------------------------------------------------------
  -- Delete all roles in the pa_role_profile_lines table before insertion.
  DELETE FROM pa_role_profile_lines
  WHERE profile_id = p_profile_id;

  FOR i IN 1..l_role_id_tbl.count LOOP
     INSERT INTO pa_role_profile_lines
              (profile_id,
               project_role_id,
               role_weighting,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by)
     VALUES
              (p_profile_id,
               l_role_id_tbl(i),
               p_weighting_tbl(i),
               SYSDATE,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID);
  END LOOP;

  -------------------------------------------------------------------
  -- Exceptions
  -------------------------------------------------------------------
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;
        IF x_msg_count = 1 THEN
           pa_interface_utils_pub.get_messages (p_encoded        => FND_API.G_TRUE,
                                                p_msg_index      => 1,
                                                p_data           => x_msg_data,
                                                p_msg_index_out  => l_msg_index_out );
        END IF;
     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data      := SQLERRM;
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ROLE_PUB_UPD_RES_PRF;
        END IF;

        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_ROLE_PROFILES_PUB.Update_Res_Profiles'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        RAISE;  -- This is optional depending on the needs

END Update_Res_Profiles;

 *****************   end of Angie's temporary saving code, need to change later*****/

END PA_ROLE_PROFILES_PKG;

/
