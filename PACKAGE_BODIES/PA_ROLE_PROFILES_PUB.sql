--------------------------------------------------------
--  DDL for Package Body PA_ROLE_PROFILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_PROFILES_PUB" AS
-- $Header: PARPRPPB.pls 120.1 2005/08/19 16:59:18 mwasowic noship $
--
--  PROCEDURE
--              Add_Default_Profile
--  PURPOSE
--              This procedure adds new default profile.

PROCEDURE Add_Default_Profile
( p_business_group_id      IN  NUMBER DEFAULT NULL,
  p_business_group_name    IN  VARCHAR2 DEFAULT NULL,
  p_organization_id        IN  NUMBER DEFAULT NULL,
  p_organization_name      IN  VARCHAR2 DEFAULT NULL,
  p_job_id                 IN  NUMBER DEFAULT NULL,
  p_job_name               IN  VARCHAR2 DEFAULT NULL,
  p_position_id            IN  NUMBER DEFAULT NULL,
  p_position_name          IN  VARCHAR2 DEFAULT NULL,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE DEFAULT NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_business_group_id      NUMBER;
  l_organization_id        NUMBER;
  l_job_id                 NUMBER;
  l_position_id            NUMBER;
  l_profile_id             NUMBER;
  l_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
  l_exists                 VARCHAR2(1) := 'N';
  l_error_msg_code         VARCHAR2(500);
  l_return_status          VARCHAR2(1);
  l_prev_profile_id        NUMBER := NULL;
  l_msg_index_out          NUMBER := 0;
  l_end_date               DATE := NULL;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
   IF l_enable_log = 'Y' THEN
   PA_DEBUG.init_err_stack('PA_ROLE_PROFILES_PUB.Add_Default_Profile');
   END IF;

   -- Clear the global PL/SQL message table
   FND_MSG_PUB.initialize;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_effective_end_date IS NOT NULL THEN
      IF p_effective_start_date > p_effective_end_date THEN
         pa_utils.add_message (p_app_short_name  => 'PA',
                               p_msg_name        => 'PA_INVALID_ASGMT_DATES');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   PA_ROLE_PROFILES_UTILS.Check_Business_Level_Attrs
         ( p_business_group_id       =>  p_business_group_id,
           p_business_group_name     =>  p_business_group_name,
           p_organization_id         =>  p_organization_id,
           p_organization_name       =>  p_organization_name,
           p_job_id                  =>  p_job_id,
           p_job_name                =>  p_job_name,
           p_position_id             =>  p_position_id,
           p_position_name           =>  p_position_name,
           x_business_group_id       =>  l_business_group_id,
           x_organization_id         =>  l_organization_id,
           x_job_id                  =>  l_job_id,
           x_position_id             =>  l_position_id,
           x_return_status           =>  l_return_status,
           x_msg_count               =>  x_msg_count,
           x_msg_data                =>  x_msg_data ) ;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Next, validate profile lines

   PA_ROLE_PROFILES_UTILS.Validate_Profile_Lines
         ( p_role_id_tbl             =>  p_role_id_tbl,
           p_role_name_tbl           =>  p_role_name_tbl,
           p_weighting_tbl           =>  p_weighting_tbl,
           x_role_id_tbl             =>  l_role_id_tbl,
           x_return_status           =>  l_return_status,
           x_msg_count               =>  x_msg_count,
           x_msg_data                =>  x_msg_data );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --dbms_output.put_line ('l_business_group_id ' || l_business_group_id);
   --dbms_output.put_line ('l_org_id ' || l_organization_id);
   --dbms_output.put_line ('l_pos_id ' || l_position_id);
   --dbms_output.put_line ('l_jobid ' || l_job_id);
   --dbms_output.put_line ('p_effective_start_date ' || p_effective_start_date);
   --dbms_output.put_line ('effective_end_date ' || p_effective_end_date);

   BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   pa_role_profiles
      WHERE  resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1)
             AND TRUNC(effective_start_date) BETWEEN TRUNC(p_effective_start_date)
                 AND NVL(TRUNC(p_effective_end_date), TRUNC(effective_start_date))
             AND rownum = 1;

      pa_utils.add_message (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_PROFILE_DATE_CONFLICT');
      RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             null;
   END;

   BEGIN
   --Check if p_start_date is in between any start_date, end_date combination
      SELECT 'Y'
      INTO   l_exists
      FROM   pa_role_profiles
      WHERE  resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1)
             AND TRUNC(p_effective_start_date) BETWEEN TRUNC(effective_start_date)
                 AND NVL(TRUNC(effective_end_date), TRUNC(effective_start_date));

      pa_utils.add_message (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_PROFILE_DATE_CONFLICT');
      RAISE FND_API.G_EXC_ERROR;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              --dbms_output.put_line ('1.0');
              null;
   END;


   --dbms_output.put_line ('3.1');
   -- Check if the previous profile is en-dated

   BEGIN
      SELECT profile_id,
             effective_end_date
      INTO   l_prev_profile_id,
             l_end_date
      FROM   pa_role_profiles
      WHERE  effective_start_date = (SELECT max(effective_start_date)
                                     FROM   pa_role_profiles
                                     WHERE  resource_id IS NULL
                                            AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
                                            AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
                                            AND NVL(job_id, -1) = NVL(l_job_id, -1)
                                            AND NVL(position_id, -1) = NVL(l_position_id, -1)
                                            AND TRUNC(effective_start_date) < TRUNC(p_effective_start_date)
                                            AND effective_end_date IS NULL)
             AND resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1);

      --dbms_output.put_line ('l_prev_profile_id ' || l_prev_profile_id);
      -- End-date previous profile as its end date is null
      UPDATE pa_role_profiles
      SET    effective_end_date = p_effective_start_date - 1
      WHERE  profile_id = l_prev_profile_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              null;
   END;

   --dbms_output.put_line ('4');

   PA_ROLE_PROFILES_PKG.Insert_Row1
         ( p_profile_name            =>  p_profile_name,
           p_description             =>  p_description,
           p_effective_start_date    =>  p_effective_start_date,
           p_effective_end_date      =>  p_effective_end_date,
           p_profile_type_code       =>  'ACTUAL',
           p_business_group_id       =>  l_business_group_id,
           p_organization_id         =>  l_organization_id,
           p_job_id                  =>  l_job_id,
           p_position_id             =>  l_position_id,
           x_profile_id              =>  l_profile_id,
           x_return_status           =>  l_return_status);

   FOR i IN 1..l_role_id_tbl.count LOOP
       PA_ROLE_PROFILES_PKG.Insert_Row2
         ( p_profile_id              =>  l_profile_id,
           p_project_role_id         =>  l_role_id_tbl(i),
           p_role_weighting          =>  p_weighting_tbl(i),
           x_return_status           =>  l_return_status);
   END LOOP;

   -- pa_role_profile_lines table does not need sequence

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
        RAISE;
END Add_Default_Profile;

--
--  PROCEDURE
--              Update_Default_Profile
--  PURPOSE
--              This procedure updates an existing default profile.

PROCEDURE Update_Default_Profile
( p_profile_id             IN  NUMBER,
  p_business_group_id      IN  NUMBER DEFAULT NULL,
  p_business_group_name    IN  VARCHAR2 DEFAULT NULL,
  p_organization_id        IN  NUMBER DEFAULT NULL,
  p_organization_name      IN  VARCHAR2 DEFAULT NULL,
  p_job_id                 IN  NUMBER DEFAULT NULL,
  p_job_name               IN  VARCHAR2 DEFAULT NULL,
  p_position_id            IN  NUMBER DEFAULT NULL,
  p_position_name          IN  VARCHAR2 DEFAULT NULL,
  p_profile_name           IN  VARCHAR2,
  p_description            IN  VARCHAR2,
  p_effective_start_date   IN  DATE,
  p_effective_end_date     IN  DATE DEFAULT NULL,
  p_role_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE,
  p_role_name_tbl          IN  SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
  p_weighting_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_business_group_id      NUMBER;
  l_organization_id        NUMBER;
  l_job_id                 NUMBER;
  l_position_id            NUMBER;
  l_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE;
  l_exists                 VARCHAR2(1) := 'N';
  l_error_msg_code         VARCHAR2(500);
  l_return_status          VARCHAR2(1);
  l_prev_profile_id        NUMBER := NULL;
  l_msg_index_out          NUMBER := 0;
  l_end_date               DATE := NULL;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
   IF l_enable_log = 'Y' THEN
   PA_DEBUG.init_err_stack('PA_ROLE_PROFILES_PUB.Update_Default_Profile');
   END IF;

   -- Clear the global PL/SQL message table
   FND_MSG_PUB.initialize;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_effective_end_date IS NOT NULL THEN
      IF p_effective_start_date > p_effective_end_date THEN
         pa_utils.add_message (p_app_short_name  => 'PA',
                               p_msg_name        => 'PA_INVALID_ASGMT_DATES');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   PA_ROLE_PROFILES_UTILS.Check_Business_Level_Attrs
         ( p_business_group_id       =>  p_business_group_id,
           p_business_group_name     =>  p_business_group_name,
           p_organization_id         =>  p_organization_id,
           p_organization_name       =>  p_organization_name,
           p_job_id                  =>  p_job_id,
           p_job_name                =>  p_job_name,
           p_position_id             =>  p_position_id,
           p_position_name           =>  p_position_name,
           x_business_group_id       =>  l_business_group_id,
           x_organization_id         =>  l_organization_id,
           x_job_id                  =>  l_job_id,
           x_position_id             =>  l_position_id,
           x_return_status           =>  l_return_status,
           x_msg_count               =>  x_msg_count,
           x_msg_data                =>  x_msg_data ) ;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Next, validate profile lines

   PA_ROLE_PROFILES_UTILS.Validate_Profile_Lines
         ( p_role_id_tbl             =>  p_role_id_tbl,
           p_role_name_tbl           =>  p_role_name_tbl,
           p_weighting_tbl           =>  p_weighting_tbl,
           x_role_id_tbl             =>  l_role_id_tbl,
           x_return_status           =>  l_return_status,
           x_msg_count               =>  x_msg_count,
           x_msg_data                =>  x_msg_data );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --dbms_output.put_line ('l_business_group_id ' || l_business_group_id);
   --dbms_output.put_line ('l_org_id ' || l_organization_id);
   --dbms_output.put_line ('l_pos_id ' || l_position_id);
   --dbms_output.put_line ('l_jobid ' || l_job_id);
   --dbms_output.put_line ('p_effective_start_date ' || p_effective_start_date);
   --dbms_output.put_line ('effective_end_date ' || p_effective_end_date);

   BEGIN
      SELECT 'Y'
      INTO   l_exists
      FROM   pa_role_profiles
      WHERE  resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1)
             AND TRUNC(effective_start_date) BETWEEN TRUNC(p_effective_start_date)
                 AND NVL(TRUNC(p_effective_end_date), TRUNC(effective_start_date))
             AND profile_id <> p_profile_id
             AND rownum = 1;

      pa_utils.add_message (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_PROFILE_DATE_CONFLICT');
      RAISE FND_API.G_EXC_ERROR;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
             null;
   END;

   BEGIN
   --Check if p_start_date is in between any start_date, end_date combination
      SELECT 'Y'
      INTO   l_exists
      FROM   pa_role_profiles
      WHERE  resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1)
             AND TRUNC(p_effective_start_date) BETWEEN TRUNC(effective_start_date)
                 AND NVL(TRUNC(effective_end_date), TRUNC(effective_start_date))
             AND profile_id <> p_profile_id;

      pa_utils.add_message (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_PROFILE_DATE_CONFLICT');
      RAISE FND_API.G_EXC_ERROR;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              --dbms_output.put_line ('1.0');
              null;
   END;

   --dbms_output.put_line ('3.1');
   -- Check if the previous profile is en-dated

   BEGIN
      SELECT profile_id,
             effective_end_date
      INTO   l_prev_profile_id,
             l_end_date
      FROM   pa_role_profiles
      WHERE  effective_start_date = (SELECT max(effective_start_date)
                                     FROM   pa_role_profiles
                                     WHERE  resource_id IS NULL
                                            AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
                                            AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
                                            AND NVL(job_id, -1) = NVL(l_job_id, -1)
                                            AND NVL(position_id, -1) = NVL(l_position_id, -1)
                                            AND TRUNC(effective_start_date) < TRUNC(p_effective_start_date)
                                            AND effective_end_date IS NULL
                                            AND profile_id <> p_profile_id)
             AND resource_id IS NULL
             AND NVL(business_group_id, -1) = NVL(l_business_group_id, -1)
             AND NVL(organization_id, -1) = NVL(l_organization_id, -1)
             AND NVL(job_id, -1) = NVL(l_job_id, -1)
             AND NVL(position_id, -1) = NVL(l_position_id, -1)
             AND profile_id <> p_profile_id;

      --dbms_output.put_line ('l_prev_profile_id ' || l_prev_profile_id);
      -- End-date previous profile as its end date is null
      UPDATE pa_role_profiles
      SET    effective_end_date = p_effective_start_date - 1
      WHERE  profile_id = l_prev_profile_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              null;
   END;

   --dbms_output.put_line ('4');

   -- Update current profile
   PA_ROLE_PROFILES_PKG.Update_Row
     ( p_profile_id              =>  p_profile_id,
       p_profile_name            =>  p_profile_name,
       p_description             =>  p_description,
       p_effective_start_date    =>  p_effective_start_date,
       p_effective_end_date      =>  p_effective_end_date,
       p_business_group_id       =>  l_business_group_id,
       p_organization_id         =>  l_organization_id,
       p_job_id                  =>  l_job_id,
       p_position_id             =>  l_position_id,
       x_return_status           =>  l_return_status);

   -- Delete all roles in the pa_role_profile_lines table
   DELETE FROM pa_role_profile_lines
   WHERE profile_id = p_profile_id;

   -- Insert roles into the pa_role_profile_lines table
   FOR i IN 1..l_role_id_tbl.count LOOP
       PA_ROLE_PROFILES_PKG.Insert_Row2
         ( p_profile_id              =>  p_profile_id,
           p_project_role_id         =>  l_role_id_tbl(i),
           p_role_weighting          =>  p_weighting_tbl(i),
           x_return_status           =>  l_return_status);
   END LOOP;

   -- pa_role_profile_lines table does not need sequence

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
        RAISE;
END Update_Default_Profile;

PROCEDURE Delete_Profile
( p_profile_id             IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895

  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;

  DELETE FROM pa_role_profiles
  WHERE profile_id = p_profile_id;

  DELETE FROM pa_role_profile_lines
  WHERE profile_id = p_profile_id;
EXCEPTION
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
End Delete_Profile;

PROCEDURE Create_Profile_for_Resource
( p_resource_id            IN  NUMBER,
  p_resource_start_date    IN  DATE,
  p_resource_end_date      IN  DATE,
  p_business_group_id      IN  NUMBER,
  p_organization_id        IN  NUMBER,
  p_job_id                 IN  NUMBER,
  p_position_id            IN  NUMBER,
  x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_profile_id NUMBER        := -1;
  l_res_profile_id NUMBER;
  l_max_weight NUMBER        := 0;
  l_business_group_id NUMBER := NVL(p_business_group_id, -1);
  l_organization_id NUMBER   := NVL(p_organization_id, -1);
  l_job_id NUMBER            := NVL(p_job_id, -1);
  l_position_id NUMBER       := NVL(p_position_id, -1);
  l_profile_name VARCHAR2(80);
  l_description  VARCHAR2(250);
  l_profile_type_code VARCHAR2(30);
  l_profile_start_date DATE;
  l_profile_end_date DATE;
  l_end_date DATE := p_resource_end_date;
  l_return_status VARCHAR2(1);
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  TYPE number_tbl IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  l_role_id_tbl number_tbl;
  l_weighting_tbl number_tbl;

  CURSOR cur IS
      SELECT (decode(position_id, null, 0, 4)
             + decode(job_id, null, 0, 3)
             + decode(organization_id, null, 0, 2)
             + decode(business_group_id, null, 0, 1)) AS weight,
             profile_id
      FROM   pa_role_profiles
      WHERE  resource_id IS NULL
      AND    NVL(position_id,l_position_id)             = l_position_id
      AND    NVL(job_id, l_job_id)                      = l_job_id
      AND    NVL(organization_id,l_organization_id)     = l_organization_id
      AND    NVL(business_group_id,l_business_group_id) = l_business_group_id
      AND    TRUNC(p_resource_start_date) BETWEEN TRUNC(effective_start_date)
             AND NVL(TRUNC(effective_end_date), TRUNC(p_resource_start_date));

  c1  cur%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR c1 in cur LOOP
      --dbms_output.put_line ('profile_id: ' || c1.profile_id);
      --dbms_output.put_line ('profile_weighting: ' || c1.weight);

      IF l_max_weight < c1.weight THEN
         l_max_weight := c1.weight;
         l_profile_id := c1.profile_id;
      END IF;
  END LOOP;

  --dbms_output.put_line ('l_profile_id: ' || l_profile_id);

  IF l_profile_id <> -1 THEN
     SELECT profile_name,
            description,
            effective_start_date,
            effective_end_date,
            profile_type_code
     INTO   l_profile_name,
            l_description,
            l_profile_start_date,
            l_profile_end_date,
            l_profile_type_code
     FROM   pa_role_profiles
     WHERE  profile_id = l_profile_id;

     -- resource_start_date will always be prior to profile_start_date
     -- Need to check end_date of the new resource profile

     IF l_profile_end_date IS NULL THEN
        l_end_date := p_resource_end_date;
     ELSIF l_profile_end_date < p_resource_end_date THEN
          l_end_date := l_profile_end_date;
     END IF;

     --dbms_output.put_line ('l_end_date: ' || l_end_date);

     PA_ROLE_PROFILES_PKG.Insert_Row1
           ( p_profile_name            =>  l_profile_name,
             p_description             =>  l_description,
             p_effective_start_date    =>  p_resource_start_date,
             p_effective_end_date      =>  l_end_date,
             p_profile_type_code       =>  'ACTUAL',
             p_approval_status_code    =>  PA_ASSIGNMENT_APPROVAL_PUB.g_approved,
             p_resource_id             =>  p_resource_id,
             x_profile_id              =>  l_res_profile_id,
             x_return_status           =>  l_return_status);

     SELECT project_role_id,
            role_weighting
     BULK COLLECT INTO l_role_id_tbl,
                       l_weighting_tbl
     FROM   pa_role_profile_lines
     WHERE  profile_id = l_profile_id;

     FOR i IN 1..l_role_id_tbl.count LOOP
         PA_ROLE_PROFILES_PKG.Insert_Row2
           ( p_profile_id              =>  l_res_profile_id,
             p_project_role_id         =>  l_role_id_tbl(i),
             p_role_weighting          =>  l_weighting_tbl(i),
             x_return_status           =>  l_return_status);
     END LOOP;
  END IF;

END Create_Profile_for_Resource;

END PA_ROLE_PROFILES_PUB;

/
