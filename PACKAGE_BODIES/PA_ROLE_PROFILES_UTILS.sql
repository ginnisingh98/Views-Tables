--------------------------------------------------------
--  DDL for Package Body PA_ROLE_PROFILES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_PROFILES_UTILS" AS
-- $Header: PARPRPUB.pls 120.1 2005/08/19 16:59:25 mwasowic noship $
--
--  PROCEDURE
--              Check_BusGroup_Name_Or_Id
--  PURPOSE
--              This procedure checks if the busiess group id
--              and name combination is valid. If id does not
--              match with name, retrieve and return the right id.

PROCEDURE Check_BusGroup_Name_Or_Id
( p_business_group_id      IN  NUMBER,
  p_business_group_name    IN  VARCHAR2,
  p_check_id_flag          IN  VARCHAR2 DEFAULT NULL,
  x_business_group_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_current_id NUMBER := NULL;
  l_num_ids NUMBER := 0;
  l_id_found_flag VARCHAR(1) := 'N';
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  CURSOR c_ids IS
      SELECT business_group_id
      FROM per_business_groups
      WHERE name = p_business_group_name;
BEGIN
  IF l_enable_log = 'Y' THEN
  pa_debug.init_err_stack ('pa_role_profiles_utils.Check_BusGroup_Name_Or_Id');
  END IF;

  IF p_business_group_id IS NOT NULL THEN
     IF p_business_group_name IS NOT NULL THEN
        OPEN c_ids;
        LOOP
           FETCH c_ids INTO l_current_id;
           EXIT WHEN c_ids%NOTFOUND;
              IF l_current_id = p_business_group_id THEN
                 l_id_found_flag := 'Y';
                 x_business_group_id := p_business_group_id;
              END IF;
        END LOOP;
        l_num_ids := c_ids%ROWCOUNT;
        CLOSE c_ids;

        IF l_num_ids = 0 THEN
           RAISE NO_DATA_FOUND;
        ELSIF l_num_ids = 1 THEN
           x_business_group_id := l_current_id;
        ELSIF l_id_found_flag = 'N' THEN
           RAISE TOO_MANY_ROWS;
        END IF;
     END IF;
  ELSE
     IF p_business_group_name IS NOT NULL THEN
        SELECT business_group_id
        INTO x_business_group_id
        FROM per_business_groups
        WHERE name = p_business_group_name;
     ELSE x_business_group_id := NULL;
     END IF;
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;
  x_error_msg_code := NULL;
  IF l_enable_log = 'Y' THEN
  pa_debug.reset_err_stack;
  END IF;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
         --dbms_output.put_line ('No data exists');
         x_business_group_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_BUS_GROUP_INVALID';
       WHEN TOO_MANY_ROWS THEN
         --dbms_output.put_line ('Too Many Rows');
         x_business_group_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_BUS_GROUP_NOT_UNIQUE';
       WHEN OTHERS THEN
         x_business_group_id := NULL;
         fnd_msg_pub.add_exc_msg
          (p_pkg_name => 'PA_ROLE_PROFILES_UTILS',
           p_procedure_name => pa_debug.g_err_stack );
           x_error_msg_code:= FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;

END Check_BusGroup_Name_Or_Id;

--
--  PROCEDURE
--              Check_Position_Name_Or_Id
--  PURPOSE
--              This procedure checks if the position id
--              and name combination is valid. If id does not
--              match with the name, retrieve and return the right id.

PROCEDURE Check_Position_Name_Or_Id
( p_position_id                 IN  NUMBER,
  p_position_name               IN  VARCHAR2,
  p_check_id_flag               IN  VARCHAR2 DEFAULT NULL,
  x_position_id                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_msg_code              OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_current_id NUMBER := NULL;
  l_num_ids NUMBER := 0;
  l_id_found_flag VARCHAR(1) := 'N';
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  CURSOR c_ids IS
      SELECT position_id
      FROM per_positions
      WHERE name = p_position_name;
BEGIN
  IF l_enable_log = 'Y' THEN
  pa_debug.init_err_stack ('pa_role_profiles_utils.Check_Position_Name_Or_Id');
  END IF;

  IF p_position_id IS NOT NULL THEN
     IF p_position_name IS NOT NULL THEN
        OPEN c_ids;
        LOOP
           FETCH c_ids INTO l_current_id;
           EXIT WHEN c_ids%NOTFOUND;
              IF l_current_id = p_position_id THEN
                 l_id_found_flag := 'Y';
                 x_position_id := p_position_id;
              END IF;
        END LOOP;
        l_num_ids := c_ids%ROWCOUNT;
        CLOSE c_ids;

        IF l_num_ids = 0 THEN
           RAISE NO_DATA_FOUND;
        ELSIF l_num_ids = 1 THEN
           x_position_id := l_current_id;
        ELSIF l_id_found_flag = 'N' THEN
           RAISE TOO_MANY_ROWS;
        END IF;
     END IF;
  ELSE
     IF p_position_name IS NOT NULL THEN
        SELECT position_id
        INTO x_position_id
        FROM per_positions
        WHERE name = p_position_name;
     ELSE x_position_id := NULL;
     END IF;
  END IF;

  x_return_status:= FND_API.G_RET_STS_SUCCESS;
  x_error_msg_code := NULL;
  IF l_enable_log = 'Y' THEN
  pa_debug.reset_err_stack;
  END IF;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_position_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_POSITION_INVALID';
       WHEN TOO_MANY_ROWS THEN
         x_position_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_POSITION_NOT_UNIQUE';
       WHEN OTHERS THEN
         x_position_id := NULL;
         fnd_msg_pub.add_exc_msg
          (p_pkg_name => 'PA_ROLE_PROFILES_UTILS',
           p_procedure_name => pa_debug.g_err_stack );
           x_error_msg_code:= FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;

END Check_Position_Name_Or_Id;

--
--  PROCEDURE
--              Check_Business_Level_Attrs
--  PURPOSE
--              This procedure checks each business attributes
--              name/id combination. It also validates
--              organization against business group,
--              job against business group,
--              position against business group/organization/job.

PROCEDURE Check_Business_Level_Attrs
( p_business_group_id      IN  NUMBER,
  p_business_group_name    IN  VARCHAR2,
  p_organization_id        IN  NUMBER,
  p_organization_name      IN  VARCHAR2,
  p_job_id                 IN  NUMBER,
  p_job_name               IN  VARCHAR2,
  p_position_id            IN  NUMBER,
  p_position_name          IN  VARCHAR2,
  x_business_group_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_organization_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_job_id                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_position_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

  l_return_status          VARCHAR2(1);
  l_error_msg_code         VARCHAR2(500);
  l_exists                 VARCHAR(1);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --FND_MSG_PUB.initialize;

  IF p_business_group_name IS NULL
     AND p_organization_name IS NULL
     AND p_job_name IS NULL
     AND p_position_name IS NULL THEN
     PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                            p_msg_name       => 'PA_PROFILE_BUS_LEVEL_MISSING' );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_business_group_name IS NOT NULL THEN
     Check_BusGroup_Name_Or_Id
           ( p_business_group_id      =>  p_business_group_id,
             p_business_group_name    =>  p_business_group_name,
             x_business_group_id      =>  x_business_group_id,
             x_return_status          =>  l_return_status,
             x_error_msg_code         =>  l_error_msg_code );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name       => l_error_msg_code );
     END IF;
  END IF;

  IF p_organization_name IS NOT NULL THEN
     pa_hr_org_utils.Check_OrgName_Or_Id
            ( p_organization_id        =>  p_organization_id,
              p_organization_name      =>  p_organization_name,
              p_check_id_flag          =>  'A',
              x_organization_id        =>  x_organization_id,
              x_return_status          =>  l_return_status,
              x_error_msg_code         =>  l_error_msg_code );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name       => l_error_msg_code );
     END IF;
  END IF;

  IF p_job_name IS NOT NULL THEN
     pa_job_utils.Check_JobName_Or_Id
            ( p_job_id                 =>  p_job_id,
              p_job_name               =>  p_job_name,
              p_check_id_flag          =>  'A',
              x_job_id                 =>  x_job_id,
              x_return_status          =>  l_return_status,
              x_error_message_code     =>  l_error_msg_code );

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name       => l_error_msg_code );
     END IF;
  END IF;

  --dbms_output.put_line('job_id ' || x_job_id);

  IF p_position_name IS NOT NULL THEN
     Check_Position_Name_Or_Id
            ( p_position_id            =>  p_position_id,
              p_position_name          =>  p_position_name,
              x_position_id            =>  x_position_id,
              x_return_status          =>  l_return_status,
              x_error_msg_code         =>  l_error_msg_code );
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA',
                               p_msg_name       => l_error_msg_code );
     END IF;
  END IF;

  --dbms_output.put_line ('no of errors in the stack ' || FND_MSG_PUB.Count_Msg);

  IF FND_MSG_PUB.Count_Msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --The following code checks if organization, job, position belong to the business group
  --and also if position belongs to the organization and job.
  IF x_organization_id IS NOT NULL THEN
     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM HR_ORGANIZATION_UNITS
        WHERE organization_id = x_organization_id
        AND   business_group_id = NVL(x_business_group_id, business_group_id);

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                pa_utils.add_message (p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_ORG_NOT_QUALIFIED');
     END;
  END IF;

  IF x_job_id IS NOT NULL THEN
     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM PER_JOBS
        WHERE job_id = x_job_id
        AND   business_group_id = NVL(x_business_group_id, business_group_id);

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                pa_utils.add_message (p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_JOB_NOT_QUALIFIED');
     END;
  END IF;

  IF x_position_id IS NOT NULL THEN
     BEGIN
        SELECT 'Y'
        INTO l_exists
        FROM PER_POSITIONS
        WHERE business_group_id = NVL(x_business_group_id, business_group_id)
        AND   organization_id = NVL(x_organization_id, organization_id)
        AND   job_id = NVL(x_job_id, job_id)
        AND   position_id = x_position_id;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                pa_utils.add_message (p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_POSITION_NOT_QUALIFIED');
     END;
  END IF;

  IF FND_MSG_PUB.Count_Msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;
    WHEN OTHERS THEN
       RAISE;
END Check_Business_Level_Attrs;

--
--  PROCEDURE
--              Validate_Profile_Lines
--  PURPOSE
--              This procedure checks the roles and their weightings.
--

PROCEDURE Validate_Profile_Lines
( p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_role_id_tbl            OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE := p_role_id_tbl;
  l_return_status          VARCHAR2(1);
  l_error_msg_code         VARCHAR2(500);
  l_sum                    NUMBER := 0;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_role_id_tbl.count <= 0 THEN
     PA_UTILS.Add_Message (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_PROFILE_NUM_ROLES_ZERO');
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     FOR i IN 1..l_role_id_tbl.count LOOP
         IF l_role_id_tbl(i) = 0 THEN
            l_role_id_tbl(i) := NULL;
         END IF;

         IF p_weighting_tbl(i) <= 0 THEN
            PA_UTILS.Add_Message (p_app_short_name => 'PA',
                                  p_msg_name       => 'PA_WEIGHTING_NOT_POSITIVE');
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         pa_role_utils.Check_Role_Name_Or_Id
                (p_role_id            => l_role_id_tbl(i),
                 p_role_name          => p_role_name_tbl(i),
                 p_check_id_flag      => 'A',
                 x_role_id            => l_role_id_tbl(i),
                 x_return_status      => l_return_status,
                 x_error_message_code => l_error_msg_code);

         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message (p_app_short_name => 'PA',
                                  p_msg_name       => l_error_msg_code);
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_sum := l_sum + p_weighting_tbl(i);
     END LOOP;
  END IF;

  IF l_sum <> 100 THEN
     PA_UTILS.Add_Message (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_INCORRECT_SUM');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_MSG_PUB.Count_Msg > 0 THEN -- One or more roles are invalid
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN 1..l_role_id_tbl.count LOOP
      FOR j IN i+1..l_role_id_tbl.count LOOP
          IF l_role_id_tbl(i) = l_role_id_tbl(j) THEN
             PA_UTILS.Add_Message (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_DUPLICATE_ROLES');
             RAISE FND_API.G_EXC_ERROR;
          END IF;
      END LOOP;
  END LOOP;

  x_role_id_tbl := l_role_id_tbl;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := FND_MSG_PUB.Count_Msg;
  WHEN OTHERS THEN
     RAISE;
END Validate_Profile_Lines;

END PA_ROLE_PROFILES_UTILS;

/
