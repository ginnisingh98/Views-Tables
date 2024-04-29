--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SEARCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SEARCH_UTILS" AS
/*$Header: PAPRSUTB.pls 120.2 2006/02/28 05:07:45 dthakker noship $*/

------------------------------------------------------------
-- Procedure: Check_Customer_Name_Or_Id
-- Copied From: PA_CUSTOMERS_CONTACTS_UTILS package
-- Description:
--              Modify the logic to return at least one id
--              if more than one is found for Project Lists
--              search enhancement name to id conversion
--              Only retain code that's using name to get Id
------------------------------------------------------------

PROCEDURE Check_Customer_Name_Or_Id
(  p_customer_id                   IN NUMBER
  ,p_customer_name                 IN VARCHAR2
  ,x_customer_id                   OUT NOCOPY NUMBER
  ,x_return_status                 OUT NOCOPY VARCHAR2
  ,x_error_msg_code                OUT NOCOPY VARCHAR2
)
IS
   l_current_id         NUMBER     := NULL;
   l_num_ids            NUMBER     := 0;

   CURSOR c_ids IS
      SELECT customer_id
      FROM pa_customers_v
      WHERE upper(customer_name) = upper(p_customer_name) and status = 'A';

BEGIN

   if (p_customer_id = FND_API.G_MISS_NUM) OR (p_customer_id is NULL) then
      if (p_customer_name is not NULL) then

          OPEN c_ids;
            LOOP
              FETCH c_ids INTO l_current_id;
              EXIT WHEN c_ids%NOTFOUND;
              x_customer_id := l_current_id;
            END LOOP;
            l_num_ids := c_ids%ROWCOUNT;
          CLOSE c_ids;

          IF (l_num_ids = 0) THEN
             -- No IDs for name
             RAISE NO_DATA_FOUND;
          END IF;
      else
          x_customer_id := NULL;
      end if;

   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when NO_DATA_FOUND then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_CUSTOMER_ID_INVALID';

   when OTHERS then
      x_customer_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_SEARCH_UTILS', p_procedure_name  => 'CHECK_CUSTOMER_NAME_OR_ID');
      raise;

END Check_Customer_Name_Or_Id;


------------------------------------------------------------
-- Procedure: Check_PersonName_Or_Id
-- Referred From: PA_RESOURCE_UTILS package
-- Description:
--              Using the passed resource name, this API
--              will return the Id based on cursor using
--              PER table and HZ tables as the resource can
--              be an internal or external person.
--              The logic is that we will return at least
--              one Id if more than one is found.
--              This API will return the login user Id if
--              no matching Id is found.
------------------------------------------------------------
PROCEDURE Check_PersonName_Or_Id(
       p_resource_id             IN     NUMBER
      ,p_resource_name           IN     VARCHAR2
      ,x_resource_id            OUT NOCOPY    NUMBER
      ,x_resource_type_id       OUT NOCOPY    NUMBER
      ,x_return_status          OUT NOCOPY    VARCHAR2
      ,x_error_msg_code         OUT NOCOPY    VARCHAR2
)
IS
   l_current_id         NUMBER     := NULL;
   l_num_ids            NUMBER     := 0;

   CURSOR r_ids IS
       SELECT person_id
       FROM per_all_people_f
       WHERE full_name = p_resource_name
       AND trunc(sysdate) between trunc(effective_start_date) and trunc(effective_end_date);

   CURSOR p_ids IS
       SELECT party_id
       FROM pa_party_resource_details_v
       WHERE party_name = p_resource_name
       AND party_type = 'PERSON'   -- Added for Bug 4745885
       AND trunc(sysdate) between trunc(start_date)
       and trunc(nvl(end_date, to_date('31-12-4712', 'DD-MM-YYYY')));

   CURSOR login_id IS
       SELECT employee_id
       FROM fnd_user
       WHERE user_id = FND_GLOBAL.user_id;

BEGIN

   IF (p_resource_id IS NULL) OR (p_resource_id = FND_API.G_MISS_NUM) THEN

      if (p_resource_name IS NOT NULL) then

          OPEN r_ids;
            LOOP
              FETCH r_ids INTO l_current_id;
              EXIT WHEN r_ids%NOTFOUND;
              x_resource_id := l_current_id;
              x_resource_type_id := 101;
            END LOOP;
            l_num_ids := r_ids%ROWCOUNT;
          CLOSE r_ids;

          IF (l_num_ids = 0) THEN
             -- No IDs for name when checking HR employee name
             -- Now try to find external person name
                OPEN p_ids;
                  LOOP
                    FETCH p_ids INTO l_current_id;
                    EXIT WHEN p_ids%NOTFOUND;
                    x_resource_id := l_current_id;
                    x_resource_type_id := 112;
                  END LOOP;
                  l_num_ids := p_ids%ROWCOUNT;
                CLOSE p_ids;
          END IF;

          -- login specific to Project List Search
          -- returns the Id of the login user
          IF (l_num_ids = 0) THEN
            -- if internal
            OPEN login_id;
             FETCH login_id INTO l_current_id;
             x_resource_id := l_current_id;
             x_resource_type_id := 101;
            CLOSE login_id;

            IF l_current_id is null THEN
              -- if external
              x_resource_id := PA_UTILS.get_party_id(FND_GLOBAL.user_id);
              x_resource_type_id := 112;
            END IF;
          END IF;

      else
          x_resource_id := NULL;
          x_resource_type_id := NULL;
      end if;

   END IF;

EXCEPTION
   when NO_DATA_FOUND then
      x_resource_id := NULL;
      x_resource_type_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_RESOURCE_INVALID_AMBIGUOUS';

   when OTHERS then
      x_resource_id := NULL;
      x_resource_type_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_SEARCH_UTILS', p_procedure_name  => 'Check_PersonName_Or_Id');
      raise;

END Check_PersonName_Or_Id;


------------------------------------------------------------
-- Procedure: Check_ResourceName_Or_Id
-- Description:
--              Using the passed person name, this API
--              will return the Id based on cursor based on
--              all past, current and future resource.
--              The logic is that we will return at least
--              one Id if more than one is found.
--              This API will return the login user Id if
--              no matching Id is found.
------------------------------------------------------------
PROCEDURE Check_ResourceName_Or_Id(
       p_person_id             IN     NUMBER
      ,p_person_name           IN     VARCHAR2
      ,x_person_id              OUT NOCOPY    NUMBER
      ,x_return_status          OUT NOCOPY    VARCHAR2
      ,x_error_msg_code         OUT NOCOPY    VARCHAR2
)
IS
   l_current_id         NUMBER     := NULL;
   l_num_ids            NUMBER     := NULL;

   CURSOR r_ids IS
       SELECT person_id
       FROM per_all_people_f
       WHERE full_name = p_person_name;

   CURSOR login_id IS
       SELECT employee_id
       FROM fnd_user
       WHERE user_id = FND_GLOBAL.user_id;

BEGIN

   IF (p_person_id IS NULL) OR (p_person_id = FND_API.G_MISS_NUM) THEN

      if (p_person_name IS NOT NULL) then

          OPEN r_ids;
            LOOP
              FETCH r_ids INTO l_current_id;
              EXIT WHEN r_ids%NOTFOUND;
              x_person_id := l_current_id;
            END LOOP;
            l_num_ids := r_ids%ROWCOUNT;
          CLOSE r_ids;

          -- login specific to Search
          -- returns the Id of the login user
          IF (l_num_ids = 0) THEN

            OPEN login_id;
             FETCH login_id INTO l_current_id;
             x_person_id := l_current_id;
            CLOSE login_id;

          END IF;

      else
          x_person_id := NULL;
      end if;

   END IF;

EXCEPTION
   when NO_DATA_FOUND then
      x_person_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_RESOURCE_INVALID_AMBIGUOUS';

   when OTHERS then
      x_person_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_SEARCH_UTILS', p_procedure_name  => 'Check_PersonName_Or_Id');
      raise;

END Check_ResourceName_Or_Id;


------------------------------------------------------------
-- Procedure: CONVERT_NAMETOID
-- Description:
--             Convert a list of parameter names into
--             the corresponding Ids. Used by Project Lists
--             Search.
------------------------------------------------------------
PROCEDURE Convert_NameToId
( p_param_type_tbl           IN  SYSTEM.pa_varchar2_30_tbl_type
 ,p_param_value_tbl          IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_param_value2_tbl         IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_init_msg_list            IN  VARCHAR2
 ,x_param_id_tbl            OUT  NOCOPY SYSTEM.pa_num_tbl_type
 ,x_return_status           OUT  NOCOPY VARCHAR2
 ,x_msg_count               OUT  NOCOPY NUMBER
 ,x_msg_data                OUT  NOCOPY VARCHAR2
)
IS

  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_param_type_tbl     SYSTEM.pa_varchar2_30_tbl_type  := p_param_type_tbl;
  l_param_value_tbl    SYSTEM.pa_varchar2_240_tbl_type := p_param_value_tbl;
  l_param_value2_tbl   SYSTEM.pa_varchar2_240_tbl_type := p_param_value2_tbl;
  l_id                 NUMBER      := null;
  l_type_id            NUMBER      := null;

BEGIN

  -- initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_init_msg_list = FND_API.G_TRUE THEN
     fnd_msg_pub.initialize;
  END IF;

  -- if there is at least one item in the array, process the name to id
  -- conversion

  IF l_param_type_tbl.EXISTS(1) THEN

    FOR i IN l_param_type_tbl.FIRST..l_param_type_tbl.LAST LOOP

       IF l_param_type_tbl(i) = 'PROJECTSET' THEN

          -- call API to validate project set name
          PA_PROJECT_SET_UTILS.Check_ProjectSetName_Or_Id(
               p_project_set_id     => null
              ,p_project_set_name   => l_param_value_tbl(i)
              ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
              ,x_project_set_id     => l_id
              ,x_return_status      => l_return_status
              ,x_error_msg_code     => l_msg_data );

       ELSIF l_param_type_tbl(i) = 'ROLE' THEN

          -- call API to validate role name
          PA_ROLE_UTILS.Check_Role_Name_Or_Id(
               p_role_id            => null
              ,p_role_name          => l_param_value_tbl(i)
              ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
              ,x_role_id            => l_id
              ,x_return_status      => l_return_status
              ,x_error_message_code => l_msg_data);

       ELSIF l_param_type_tbl(i) = 'CUSTOMER' THEN

          -- call API to validate customer name
          PA_PROJECT_SEARCH_UTILS.CHECK_CUSTOMER_NAME_OR_ID(
               p_customer_id        => null
              ,p_customer_name      => l_param_value_tbl(i)
              ,x_customer_id        => l_id
              ,x_return_status      => l_return_status
              ,x_error_msg_code     => l_msg_data);

       ELSIF l_param_type_tbl(i) = 'PERSON' OR l_param_type_tbl(i) = 'MANAGER' THEN
          -- call API to validate person or manager name
          PA_PROJECT_SEARCH_UTILS.Check_PersonName_Or_Id(
               p_resource_id        => null
              ,p_resource_name      => l_param_value_tbl(i)
              ,x_resource_id        => l_id
              ,x_resource_type_id   => l_type_id
              ,x_return_status      => l_return_status
              ,x_error_msg_code     => l_msg_data);

       ELSIF l_param_type_tbl(i) = 'CLASSCODE' THEN

          -- call API to validate class category and code
          PA_PROJECTS_MAINT_UTILS.Check_ClassCode_Name_Or_Id(
               p_classcode_id       => null
              ,p_classcode_name     => l_param_value_tbl(i)
              ,p_classcategory      => l_param_value2_tbl(i)
              ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
              ,x_classcode_id       => l_id
              ,x_return_status      => l_return_status
              ,x_error_message_code => l_msg_data);

       ELSE
          -- no param type or invalid param type - set Id to null
          x_param_id_tbl(i) := null;

       END IF;


       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_param_id_tbl(i) := -999;
          -- also add message to error stack
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_msg_data);
       ELSE
          -- store value in the out parameter Id table
          x_param_id_tbl(i) := l_id;
       END IF;


    END LOOP; --end of loop for all the parameter types

  END IF;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
     RAISE;

END Convert_NameToId;

------------------------------------------------------------
-- Procedure: Get_Perf_Measures
-- Description:
--             Wrapper API for Project Performances
------------------------------------------------------------
PROCEDURE Get_Perf_Measures
(
   p_source_api                  IN         VARCHAR2,
   p_project_id                  IN         NUMBER,
   p_measure_codes_tbl           IN         SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
   p_measure_set_codes_tbl       IN         SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   p_timeslices_tbl              IN         SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   p_measure_id_tbl              IN         SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL, -- added for bug4361663
   x_measure_values_tbl          OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE,
   x_exception_indicator_tbl     OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
--   x_exception_labels_tbl        OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
   x_sec_ret_code                OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
   l_sec_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_sec_msg_count     NUMBER      := 0;
   l_sec_msg_data      VARCHAR2(1) := NULL;

BEGIN

   x_sec_ret_code := 'F';

   PA_SECURITY_PVT.check_user_privilege
   (
      p_privilege     => 'PA_MY_PROJ_MAIN_TAB_PSI_COL',
      p_object_name   => 'PA_PROJECTS',
      p_object_key    => p_project_id,
      x_ret_code      => x_sec_ret_code,
      x_return_status => l_sec_return_status,
      x_msg_count     => l_sec_msg_count,
      x_msg_data      => l_sec_msg_data
   );

   IF (x_sec_ret_code = 'T')
   THEN
      IF (p_source_api = 'FM')
      THEN
         PJI_REP_MEASURE_UTIL.Get_Financial_Measures
         (
            p_project_id                  => p_project_id,
            p_measure_codes_tbl           => p_measure_codes_tbl,
            p_measure_set_codes_tbl       => p_measure_set_codes_tbl, -- Added for bug4361663
            p_timeslices_tbl              => p_timeslices_tbl, -- Added for bug4361663
            p_measure_id_tbl              => p_measure_id_tbl, -- Added for bug4361663
            x_measure_values_tbl          => x_measure_values_tbl,
            x_exception_indicator_tbl     => x_exception_indicator_tbl,
--            x_exception_labels_tbl        => x_exception_labels_tbl,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
         );
      ELSIF (p_source_api = 'AC')
      THEN
         PJI_REP_MEASURE_UTIL.Get_Activity_Measures
         (
            p_project_id                  => p_project_id,
            p_measure_codes_tbl           => p_measure_codes_tbl,
            p_measure_set_codes_tbl       => p_measure_set_codes_tbl, -- Added for bug4361663
            p_timeslices_tbl              => p_timeslices_tbl, -- Added for bug4361663
            p_measure_id_tbl              => p_measure_id_tbl, -- Added for bug4361663
            x_measure_values_tbl          => x_measure_values_tbl,
            x_exception_indicator_tbl     => x_exception_indicator_tbl,
--            x_exception_labels_tbl        => x_exception_labels_tbl,
            x_return_status               => x_return_status,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
         );
      END IF;
   END IF;

EXCEPTION
   when OTHERS then
      raise;

END Get_Perf_Measures;

END PA_PROJECT_SEARCH_UTILS;

/
