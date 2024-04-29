--------------------------------------------------------
--  DDL for Package Body PA_COMP_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COMP_PROFILE_PVT" AS
-- $Header: PARPRFVB.pls 120.5 2005/11/20 20:29:10 sunkalya ship $

g_profile_id                     NUMBER := 0;
g_person_id                      NUMBER := 0;

PROCEDURE Validate_Competency
(p_person_id           IN NUMBER,
 p_competence_id       IN NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2, -- 4537865 Added the nocopy hint
 x_error_message_code OUT NOCOPY VARCHAR2); -- 4537865 Added the nocopy hint

FUNCTION Awaiting_Approval
( p_person_id     IN NUMBER,
  p_competence_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION Awaiting_Approval
( p_element_id     IN NUMBER)
RETURN VARCHAR2;

FUNCTION check_competence_exists
     ( p_person_id     IN NUMBER,
       p_competence_id IN NUMBER)
RETURN VARCHAR2;

Procedure create_competence_element
( p_profile_id                   IN NUMBER,
  p_person_id                    IN NUMBER,
  p_competence_id                IN NUMBER,
  p_object_version_number        IN NUMBER,
  p_business_group_id            IN NUMBER,
  p_proficiency_level_id         IN NUMBER,
  p_effective_date_from          IN DATE
  );

Procedure Update_competence_element
(p_profile_id             IN NUMBER,
p_person_id               IN NUMBER,
p_competence_id           IN NUMBER,
p_competence_element_id   IN NUMBER,
p_object_version_number   IN NUMBER,
p_rating_level_id         IN NUMBER,
p_effective_date_from     IN DATE);

PROCEDURE Add_Competence_Element
( p_person_id       IN per_competence_elements.person_id%TYPE,
p_competence_id     IN per_competences.competence_id%TYPE,
p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_effective_date_from  IN DATE,
p_commit        IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only     IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
x_return_status     OUT NOCOPY VARCHAR2 ) IS -- 4537865 Added the nocopy hint

l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
l_data         VARCHAR2(500);
l_msg_data     VARCHAR2(500);
l_msg_index_out NUMBER := 0;
l_project_id    NUMBER := 0;
l_return_status  VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_bg_id         NUMBER := 0;
l_element_id    NUMBER := 0;
l_role_id         NUMBER := 0;
l_object_version_number NUMBER := 0;
CURSOR l_bg_csr IS
SELECT business_group_id
FROM   per_competences
WHERE competence_id = p_competence_id;

BEGIN
  IF l_enable_log = 'Y' THEN
  pa_debug.set_err_stack ('PA_COMP_PROFILE_PVT.add_competence_element');
  END IF;

  SAVEPOINT COMPETENCE_PVT_ADD_COMP_ELE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the message stack if necessary
  IF p_init_msg_list = FND_API.G_TRUE  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Check where the competency can be asssigned to the person
  Validate_Competency
        (p_person_id      => p_person_id
         ,p_competence_id => p_competence_id
         ,x_return_status => l_return_status
         ,x_error_message_code => l_error_message_code );

  Check_Error(p_return_status => l_return_status,
              p_error_message_code => l_error_message_code );

  -- Check whether the competency already exists for the person
  IF check_competence_exists(p_person_id,p_competence_id) = 'Y' THEN
        Check_Error ( p_return_status => FND_API.G_RET_STS_ERROR
                     ,p_error_message_code => 'PA_PRM_COMP_PROFILE_EXISTS');
  END IF;

  -- Check whether the competency already exists but is waiting for approval
  IF Awaiting_Approval(p_person_id,p_competence_id) = 'Y' THEN
        Check_Error ( p_return_status => FND_API.G_RET_STS_ERROR
                     ,p_error_message_code => 'PA_PRM_COMP_AWAITING_APPROVAL');
  END IF;

  -- If there are errors, do not proceed to insert the data
  IF g_noof_errors > 0 THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
        END IF;
        RETURN;
  END IF;

  -- If validate only = 'Y' then return at this point.
  IF p_validate_only = 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
        END IF;
        RETURN;
  END IF;

  --  If no errors and validate only = 'N' then
  --  call the table handler to create the competency in the temporary
  --  table

  -- We need the business group id of the competency
  -- Hence fetch the same from the competences table

  OPEN l_bg_csr;
  FETCH l_bg_csr INTO l_bg_id;
  CLOSE l_bg_csr;

  IF g_profile_id = 0 THEN
     SELECT pa_competence_profiles_s.nextval
     INTO g_profile_id
     FROM dual;
  END IF;

  IF g_person_id = 0 THEN
     g_person_id := p_person_id;
  END IF;

  -- Now create the competency in the temporary table
  create_competence_element
  (
  p_profile_id                   => g_profile_id,
  p_person_id                    => p_person_id,
  p_competence_id                => p_competence_id,
  p_object_version_number        => l_object_version_number,
  p_business_group_id            => l_bg_id,
  p_proficiency_level_id         => p_rating_level_id,
  p_effective_date_from          => p_effective_date_from
  ) ;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF l_enable_log = 'Y' THEN
  pa_debug.reset_err_stack;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF p_commit = FND_API.G_TRUE THEN
     ROLLBACK TO COMPETENCE_PVT_ADD_COMP_ELE;
  END IF;
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Add_Competence_Element ;

PROCEDURE Update_competence_element
(p_person_id       IN per_competence_elements.person_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_id      IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_effective_date_from  IN DATE,
 p_commit      IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER , -- 4537865 Added the nocopy hint
 x_return_status   OUT NOCOPY VARCHAR2 ) IS -- 4537865 Added the nocopy hint

l_effective_date_from   DATE;
l_return_status         VARCHAR2(30);
l_object_version_number NUMBER ;
l_error_message_code    VARCHAR2(30);
l_approval_required     BOOLEAN := TRUE;
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
--     dbms_output.put_line('Entering Update_competence_element');
--     dbms_output.put_line('Effective Date From ' || p_effective_date_from);
     IF l_enable_log = 'Y' THEN
     pa_debug.set_err_stack ('PA_COMP_PROFILE_PVT.update_competence_element');
     END IF;
     SAVEPOINT COMPETENCE_PVT_UPD_COMP_ELE;

     -- Initialize the message stack if necessary
     IF p_init_msg_list = FND_API.G_TRUE  THEN
    fnd_msg_pub.initialize;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- If there are errors, do not proceed to update the data
     -- Check whether the object version number is correct

     Check_Object_version_number
          (p_element_id            => p_element_id,
           p_object_version_number => p_object_version_number,
           x_return_status         => l_return_status,
           x_error_message_code    => l_error_message_code );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         Check_Error (p_return_status      => l_return_status
                     ,p_error_message_code => l_error_message_code );
      END IF;

     -- Check to see if the user is trying to update something which
     -- is yet not approved.
     IF p_element_id is not null THEN
        IF Awaiting_Approval(p_element_id) = 'Y' THEN
           Check_Error ( p_return_status      => FND_API.G_RET_STS_ERROR
                        ,p_error_message_code => 'PA_PRM_CANNOT_UPDATE');
        END IF;
     ELSE
        IF Awaiting_Approval(p_person_id,p_competence_id) = 'Y' THEN
           Check_Error ( p_return_status      => FND_API.G_RET_STS_ERROR
                        ,p_error_message_code => 'PA_PRM_CANNOT_UPDATE');
        END IF;
     END IF;

      IF g_noof_errors > 0 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_enable_log = 'Y' THEN
     pa_debug.reset_err_stack;
         END IF;
         RETURN;
      END IF;

     -- If validate only = 'Y' then return at this point.
     IF p_validate_only = 'Y' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
        END IF;
        RETURN;
     END IF;

     IF g_profile_id = 0 THEN
        SELECT pa_competence_profiles_s.nextval
        INTO g_profile_id
        FROM dual;
     END IF;

     IF g_person_id = 0 THEN
        g_person_id := p_person_id;
     END IF;


     update_competence_element
     (p_profile_id                   => g_profile_id,
      p_person_id                    => p_person_id,
      p_competence_id                => p_competence_id,
      p_competence_element_id        => p_element_id,
      p_object_version_number        => p_object_version_number,
      p_rating_level_id              => p_rating_level_id,
      p_effective_date_from          => p_effective_date_from);

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     IF l_enable_log = 'Y' THEN
     pa_debug.reset_err_stack;
     END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF p_commit = FND_API.G_TRUE THEN
     ROLLBACK TO COMPETENCE_PVT_UPD_COMP_ELE;
  END IF;

   -- 4537865
   x_object_version_number := NULL ;
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Update_Competence_element;

Procedure delete_competence_element
          ( p_person_id             IN NUMBER,
            p_competence_id         IN NUMBER,
            p_element_id            IN NUMBER,
            p_object_version_number IN NUMBER,
            p_commit                IN VARCHAR2 := FND_API.G_MISS_CHAR,
            x_return_status         OUT NOCOPY VARCHAR2)  -- 4537865 Added the nocopy hint
IS
l_competence_alias     VARCHAR2(30);
l_competence_name      VARCHAR2(240);
l_bg_id                NUMBER;
BEGIN

  -- Check to see if the user is trying to update something which
  -- is yet not approved.
  IF p_element_id is not null THEN
        IF Awaiting_Approval(p_element_id) = 'Y' THEN
           Check_Error ( p_return_status      => FND_API.G_RET_STS_ERROR
                        ,p_error_message_code => 'PA_PRM_CANNOT_DELETE');
        END IF;
  ELSE
        IF Awaiting_Approval(p_person_id,p_competence_id) = 'Y' THEN
           Check_Error ( p_return_status      => FND_API.G_RET_STS_ERROR
                        ,p_error_message_code => 'PA_PRM_CANNOT_DELETE');
        END IF;
  END IF;

  hr_competence_element_api.delete_competence_element
         (p_competence_element_id  => p_element_id,
          p_object_version_number  => p_object_version_number);
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	        fnd_msg_pub.add_exc_msg
     		 (p_pkg_name => 'PA_COMP_PROFILE_PVT',
    		   p_procedure_name => 'delete_competence_element');
		-- RAISE is not included as the caller of this API doesnt RAISE

END delete_competence_element;

PROCEDURE Check_Element_id
(p_object_name   IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
p_object_id  IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_element_id     IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
x_effective_date_from OUT NOCOPY per_competence_elements.effective_date_from%TYPE , -- 4537865 Added the nocopy hint
x_return_status  OUT NOCOPY VARCHAR2, -- 4537865 Added the nocopy hint
x_error_message_code OUT NOCOPY VARCHAR2) IS -- 4537865 Added the nocopy hint

l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

CURSOR l_check_element_csr IS
SELECT object_name,
       object_id,
       competence_id,
       effective_date_from
FROM per_competence_elements
WHERE competence_element_id = p_element_id;
l_check_element_rec l_check_element_csr%ROWTYPE;
BEGIN
      IF l_enable_log = 'Y' THEN
      pa_debug.set_err_stack ('PA_COMP_PROFILE_PVT.check_element_id');
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN l_check_element_csr;
      FETCH l_check_element_csr INTO l_check_element_rec;
      IF l_check_element_csr%NOTFOUND
      OR (l_check_element_rec.competence_id <> p_competence_id
       OR
          l_check_element_rec.object_id <> p_object_id
           OR
          l_check_element_rec.object_name <> p_object_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_error_message_code := 'PA_INVALID_ELEMENT_ID';
       x_effective_date_from := NULL;
      END IF;
      CLOSE l_check_element_csr;
      x_effective_date_from := l_check_element_rec.effective_date_from;
      IF l_enable_log = 'Y' THEN
      pa_debug.reset_err_stack;
      END IF;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

  -- Start : 4537865
  x_effective_date_from := NULL ;
  x_error_message_code := SQLERRM;
  -- ENd : 4537865

  RAISE;
END Check_Element_id ;

PROCEDURE Check_Error (p_return_status  IN VARCHAR2,
                   p_error_message_code IN VARCHAR2) IS
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
    IF l_enable_log = 'Y' THEN
    pa_debug.set_err_stack ('PA_COMP_PROFILE_PVT.check_error');
    END IF;
    IF p_return_status = FND_API.G_RET_STS_ERROR THEN
       g_noof_errors := g_noof_errors + 1;
       pa_utils.add_message (p_app_short_name  => 'PA',
                         p_msg_name    => p_error_message_code);
    END IF;
    IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
    END IF;
EXCEPTION
 WHEN OTHERS THEN
  RAISE;
END check_error;

PROCEDURE Check_Object_version_number
   (p_element_id  IN per_competence_elements.competence_element_id%TYPE,
    p_object_version_number IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, -- 4537865 Added the nocopy hint
    x_error_message_code OUT NOCOPY VARCHAR2) IS -- 4537865 Added the nocopy hint

l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

CURSOR l_get_obj_vers_csr IS
SELECT object_version_number
FROM per_competence_elements
WHERE competence_element_id = p_element_id;
l_obj_version_number NUMBER := 0;

BEGIN
   IF l_enable_log = 'Y' THEN
   pa_debug.set_err_stack ('PA_COMP_PROFILE_PVT.check_object_version_number');
   END IF;
   OPEN l_get_obj_vers_csr;
   FETCH l_get_obj_vers_csr INTO l_obj_version_number;
--   dbms_output.put_line (' l obj is '||l_obj_version_number ||
--                         ' p obj is '||p_object_version_number );
   IF l_obj_version_number <> p_object_version_number THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_COMP_OBJ_VERSION_INVALID';
   END IF;
   CLOSE l_get_obj_vers_csr;
   IF l_enable_log = 'Y' THEN
   pa_debug.reset_err_stack;
   END IF;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

  -- 4537865 : Start
  x_error_message_code := SQLERRM;
  -- 4537865 : End

  RAISE;
END Check_Object_Version_Number ;

Procedure create_competence_element
( p_profile_id                   IN NUMBER,
  p_person_id                    IN NUMBER,
  p_competence_id                IN NUMBER,
  p_object_version_number        IN NUMBER,
  p_business_group_id            IN NUMBER,
  p_proficiency_level_id         IN NUMBER,
  p_effective_date_from          IN DATE
  )
IS
l_competence_alias     VARCHAR2(30);
l_competence_name      VARCHAR2(240);
l_rating_level_value   NUMBER;
BEGIN

  IF p_competence_id is not null THEN
     BEGIN
       SELECT name,competence_alias
       INTO l_competence_name,l_competence_alias
       FROM per_competences
       WHERE competence_id = p_competence_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_competence_name  := null;
           l_competence_alias := null;
     END;
  END IF;

  IF p_proficiency_level_id is not null THEN
     BEGIN
       SELECT step_value
       INTO l_rating_level_value
       FROM per_rating_levels
       WHERE rating_level_id = p_proficiency_level_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_rating_level_value  := null;
     END;
  END IF;

  INSERT INTO PA_COMPETENCE_PROFILES
  (PROFILE_ID,
   PERSON_ID,
   OBJECT_VERSION_NUMBER,
   BUSINESS_GROUP_ID,
   COMPETENCE_ID,
   COMPETENCE_ELEMENT_ID,
   EFFECTIVE_DATE_FROM,
   COMPETENCE_ALIAS,
   COMPETENCE_NAME,
   DESCRIPTION,
   RATING_LEVEL_ID,
   RATING_LEVEL_VALUE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   CREATED_BY,
   CREATION_DATE,
   OPERATION)
   VALUES
   (p_profile_id,
    p_person_id,
    p_object_version_number,
    p_business_group_id,
    p_competence_id,
    null,
    p_effective_date_from,
    l_competence_alias,
    l_competence_name,
    null,
    p_proficiency_level_id,
    l_rating_level_value,
    null,
    null,
    null,
    null,
    'INSERT');


EXCEPTION
  WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end create_competence_element;

Procedure Update_competence_element
(p_profile_id             IN NUMBER,
p_person_id               IN NUMBER,
p_competence_id           IN NUMBER,
p_competence_element_id   IN NUMBER,
p_object_version_number   IN NUMBER,
p_rating_level_id         IN NUMBER,
p_effective_date_from     IN DATE)
IS
l_competence_alias        VARCHAR2(30);
l_competence_name         VARCHAR2(240);
l_rating_level_value      NUMBER;
l_bg_id                   NUMBER;
l_old_rating_level_id     NUMBER;
l_old_rating_level_value  NUMBER;
l_old_effective_date_from DATE;
BEGIN

  IF p_competence_id is not null THEN
     BEGIN
       SELECT name,competence_alias,business_group_id
       INTO l_competence_name,l_competence_alias,l_bg_id
       FROM per_competences
       WHERE competence_id = p_competence_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_competence_name  := null;
           l_competence_alias := null;
           l_bg_id            := null;
     END;
  END IF;

  IF p_competence_element_id is not null THEN
     BEGIN
       SELECT proficiency_level_id,effective_date_from
       INTO l_old_rating_level_id,l_old_effective_date_from
       FROM per_competence_elements
       WHERE competence_element_id = p_competence_element_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_old_rating_level_id     := null;
           l_old_effective_date_from := null;
     END;
  END IF;

  IF l_old_rating_level_id is not null THEN
     BEGIN
       SELECT step_value
       INTO l_old_rating_level_value
       FROM per_rating_levels
       WHERE rating_level_id = l_old_rating_level_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_old_rating_level_value  := null;
     END;
  END IF;

  IF p_rating_level_id is not null THEN
     BEGIN
       SELECT step_value
       INTO l_rating_level_value
       FROM per_rating_levels
       WHERE rating_level_id = p_rating_level_id;
     EXCEPTION
       WHEN OTHERS THEN
           l_rating_level_value  := null;
     END;
  END IF;

  INSERT INTO PA_COMPETENCE_PROFILES
  (PROFILE_ID,
   PERSON_ID,
   OBJECT_VERSION_NUMBER,
   BUSINESS_GROUP_ID,
   COMPETENCE_ID,
   COMPETENCE_ELEMENT_ID,
   EFFECTIVE_DATE_FROM,
   RATING_LEVEL_ID,
   RATING_LEVEL_VALUE,
   OLD_RATING_LEVEL_ID,
   OLD_RATING_LEVEL_VALUE,
   OLD_EFFECTIVE_DATE_FROM,
   COMPETENCE_ALIAS,
   COMPETENCE_NAME,
   DESCRIPTION,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   CREATED_BY,
   CREATION_DATE,
   OPERATION)
   VALUES
   (p_profile_id,
    p_person_id,
    p_object_version_number,
    l_bg_id,
    p_competence_id,
    p_competence_element_id,
    p_effective_date_from,
    p_rating_level_id,
    l_rating_level_value,
    l_old_rating_level_id,
    l_old_rating_level_value,
    l_old_effective_date_from,
    l_competence_alias,
    l_competence_name,
    null,
    null,
    null,
    null,
    null,
    'UPDATE');
END;

Procedure Start_Approval_Process
(x_return_status OUT NOCOPY VARCHAR2, -- 4537865 Added the nocopy hint
 x_msg_count     OUT NOCOPY NUMBER, -- 4537865 Added the nocopy hint
 x_msg_data      OUT NOCOPY VARCHAR2)  -- 4537865 Added the nocopy hint
IS


/* Bug 2697431 - Increased the length of variables l_manager_name, l_manager_display_name,
l_employee_name, l_employee_display_name to 360 from 30 */

l_manager_name          VARCHAR2(360);
l_manager_display_name  VARCHAR2(360);
l_manager_id            NUMBER;

l_employee_name            VARCHAR2(360) := '';
l_employee_display_name    VARCHAR2(360) := '';
l_employee_id              NUMBER;
l_message_url              VARCHAR2(200);

/* Bug 2697431 - Increased length of l_data, l_msg_data to 2000 from 500 */

l_data                     VARCHAR2(2000);
l_msg_data                 VARCHAR2(2000);
l_msg_index_out            NUMBER := 0;
l_return_status            VARCHAR2(30);

CURSOR c_manager IS
  SELECT hremp.supervisor_id
  FROM   hr_employees_current_v hremp
  WHERE  hremp.employee_id = g_person_id;

BEGIN

--The API Start_Approval_Process has been stubbed out for Bug:4665696 as the workflow "PA Competence Profile Approval Workflow" is to be absoleted.

/*
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := g_profile_id;
  x_msg_data      := null;

--  dbms_output.put_line('g_profile_id: ' || g_profile_id);
  IF g_profile_id = 0 THEN
     RETURN;
  END IF;


  WF_DIRECTORY.GetUserName('PER',
                          g_person_id,
                          l_employee_name,
                          l_employee_display_name);
  BEGIN

    OPEN c_manager;

    FETCH c_manager INTO l_manager_id;

    CLOSE c_manager;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        null;
  END;

  WF_DIRECTORY.GetUserName('PER',
                          l_manager_id,
                          l_manager_name,
                          l_manager_display_name);

  IF l_manager_name is null THEN

     pa_utils.add_message (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_PRM_NO_MANAGER');

     RAISE FND_API.G_EXC_ERROR;
  END IF;

  WF_ENGINE.CreateProcess('PACOPR',
                           to_char(g_profile_id),
                           'PRO_PROFILE_APPROVAL_FLOW');

  wf_engine.SetItemAttrText( 'PACOPR'
                              , g_profile_id
                              , 'MANAGER_NAME'
                              , l_manager_name
                              );

  wf_engine.SetItemAttrNumber( 'PACOPR'
                              , g_profile_id
                              , 'MANAGER_ID'
                              , l_manager_id
                              );

  wf_engine.SetItemAttrText( 'PACOPR'
                              , g_profile_id
                              , 'MANAGER_DISP_NAME'
                              , l_manager_display_name
                              );

  wf_engine.SetItemAttrText( 'PACOPR'
                              , g_profile_id
                              , 'EMPLOYEE_NAME'
                              , l_employee_name
                              );

  wf_engine.SetItemAttrNumber( 'PACOPR'
                              , g_profile_id
                              , 'EMPLOYEE_ID'
                              , g_person_id
                              );

  wf_engine.SetItemAttrText( 'PACOPR'
                              , g_profile_id
                              , 'EMPLOYEE_DISP_NAME'
                              , l_employee_display_name
                              );

  l_message_url := 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_MSG_LAYOUT&paProfileId=' || g_profile_id || '&retainAM=Y';

  wf_engine.SetItemAttrText( 'PACOPR'
                              , g_profile_id
                              , 'ATTR_APPROVAL_MESSAGE_URL'
                              , l_message_url
                              );

  WF_ENGINE.StartProcess('PACOPR', g_profile_id);

  -- Set g_profile_id and g_person_id back to 0 .
  g_profile_id := 0;
  g_person_id  := 0;

  commit;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

    pa_interface_utils_pub.get_messages
        (p_encoded        => FND_API.G_TRUE,
         p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );

         x_msg_data  := l_data;
         x_msg_count := 1;
         IF g_profile_id > 0 THEN
           BEGIN
            DELETE from pa_competence_profiles
            where profile_id=g_profile_id;
           EXCEPTION
            WHEN OTHERS THEN NULL;
           END;
         END IF;
         -- Set g_profile_id and g_person_id back to 0 .
         g_profile_id := 0;
         g_person_id  := 0;

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	 -- 4537865 : Start
	 x_msg_count := 1 ;
	 -- 4537865 : End

    -- Bug 2697431 - Added debug to write proper error message
        pa_debug.write('PA_COMP_PROFILE_PVT.Start_Approval_Process',SUBSTRB( SQLERRM,1,1900),3);  -- 4537865 Replaced substr with substrb
    x_msg_data:=SUBSTRB( SQLERRM,1,1900);  -- 4537865 Replaced substr with substrb

    IF g_profile_id > 0 THEN
           BEGIN
            DELETE from pa_competence_profiles
            where profile_id=g_profile_id;
           EXCEPTION
            WHEN OTHERS THEN NULL;
           END;
        END IF;
        -- Set g_profile_id and g_person_id back to 0 .
         g_profile_id := 0;
         g_person_id  := 0;
        -- Set g_profile_id and g_person_id back to 0 .
        g_profile_id := 0;
        g_person_id  := 0;
--The API Start_Approval_Process has been stubbed out for Bug:4665696 as the workflow "PA Competence Profile Approval Workflow" is to be absoleted.

*/
null;   -- added for Bug:4665696

END Start_Approval_Process;

PROCEDURE Update_HR
(p_profile_id    IN  NUMBER,
 x_return_status OUT NOCOPY VARCHAR2, -- 4537865 Added the nocopy hint
 x_msg_count     OUT NOCOPY NUMBER,  -- 4537865 Added the nocopy hint
 x_msg_data      OUT NOCOPY VARCHAR2)  -- 4537865 Added the nocopy hint
IS
l_file_val           VARCHAR2(100);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

cursor insert_profile IS
   SELECT PERSON_ID,
          OBJECT_VERSION_NUMBER,
          BUSINESS_GROUP_ID,
          COMPETENCE_ID ,
          EFFECTIVE_DATE_FROM,
          RATING_LEVEL_ID,
          CREATED_BY,
          CREATION_DATE
   FROM PA_COMPETENCE_PROFILES
   WHERE profile_id = p_profile_id
   AND operation = 'INSERT';

cursor update_profile IS
   SELECT OBJECT_VERSION_NUMBER,
          COMPETENCE_ELEMENT_ID,
          EFFECTIVE_DATE_FROM,
          RATING_LEVEL_ID,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE
   FROM PA_COMPETENCE_PROFILES
   WHERE profile_id = p_profile_id
   AND operation = 'UPDATE';

cursor delete_profile IS
   SELECT COMPETENCE_ELEMENT_ID,
          OBJECT_VERSION_NUMBER
   FROM PA_COMPETENCE_PROFILES
   WHERE profile_id = p_profile_id
   AND operation = 'DELETE';

l_object_version_number NUMBER := 0;
l_bg_id                 NUMBER := 0;
l_version_number        NUMBER := 0;
l_element_id            NUMBER;
l_date                  DATE;
l_competence_element_id  NUMBER;
l_effective_date_from    DATE;
l_rating_level_id        NUMBER;
l_last_updated_by        NUMBER(15);
l_last_update_date       DATE;
BEGIN

--   dbms_output.put_line('profile_id : ' || p_profile_id);

   FOR c1 in insert_profile LOOP
       l_element_id := NULL;
       l_object_version_number := c1.object_version_number;

       -- If the business group id for the competence is null,
       -- get the business group id for the person. We cannot
       -- create a competence element for a person without the
       -- business group id

       l_bg_id := c1.business_group_id;

       IF c1.business_group_id is null THEN
          BEGIN
            select business_group_id
            into l_bg_id
            from per_people_x
            where person_id=c1.person_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_bg_id := null;
          END;
       END IF;

       hr_competence_element_api.create_competence_element
           (
            p_competence_element_id        => l_element_id,
            p_object_version_number        => l_object_version_number,
            p_type                         => 'PERSONAL',
            p_business_group_id            => l_bg_id,
            p_enterprise_id                => null,
            p_competence_id                => c1.competence_id,
            p_proficiency_level_id         => c1.rating_level_id,
            p_high_proficiency_level_id    => null,
            p_weighting_level_id           => null,
            p_rating_level_id              => null,
            p_person_id                    => c1.person_id,
            p_job_id                       => null,
            p_valid_grade_id               => null,
            p_position_id                  => null,
            p_organization_id              => null,
            p_parent_competence_element_id => null,
            p_activity_version_id          => null,
            p_assessment_id                => null,
            p_assessment_type_id           => null,
            p_mandatory                    => null,
            p_effective_date_from          => c1.effective_date_from,
            p_effective_date_to            => null,
            p_group_competence_type        => null,
            p_competence_type              => null,
            p_normal_elapse_duration       => null,
            p_normal_elapse_duration_unit  => null,
            p_sequence_number              => null,
            p_source_of_proficiency_level  => null,
            p_line_score                   => null,
            p_certification_date           => null,
            p_certification_method         => null,
            p_next_certification_date      => null,
            p_comments                     => null,
            p_attribute_category           => null,
            p_attribute1                   => null,
            p_attribute2                   => null,
            p_attribute3                   => null,
            p_attribute4                   => null,
            p_attribute5                   => null,
            p_attribute6                   => null,
            p_attribute7                   => null,
            p_attribute8                   => null,
            p_attribute9                   => null,
            p_attribute10                  => null,
            p_attribute11                  => null,
            p_attribute12                  => null,
            p_attribute13                  => null,
            p_attribute14                  => null,
            p_attribute15                  => null,
            p_attribute16                  => null,
            p_attribute17                  => null,
            p_attribute18                  => null,
            p_attribute19                  => null,
            p_attribute20                  => null,
            p_effective_date               => trunc(sysdate),
            p_object_id                    => null,
            p_object_name                  => null
            ) ;
   END LOOP;

--   dbms_output.put_line('Opening update_profile');

   for c2 in update_profile LOOP

--       dbms_output.put_line('In Update');
--       dbms_output.put_line('Element Id          :' || c2.competence_element_id);
--       dbms_output.put_line('Version             :' || c2.object_version_number);
--       dbms_output.put_line('effective_date_from :' || c2.effective_date_from);
--       dbms_output.put_line('rating_level_id     :' || c2.rating_level_id);

--       dbms_output.put_line('Calling update_competence_element');
       hr_competence_element_api.update_competence_element
         (p_competence_element_id  => c2.competence_element_id,
          p_object_version_number  => c2.object_version_number,
          p_proficiency_level_id   => c2.rating_level_id,
          p_effective_date_from    => c2.effective_date_from,
          p_effective_date         => c2.effective_date_from);
--       dbms_output.put_line('After Calling update_competence_element');

   END LOOP;

/*
  -- We do not need the code below since we have decided not to start
  -- the approval process for deletes

   FOR c3 in delete_profile LOOP
        hr_competence_element_api.delete_competence_element
         (p_competence_element_id  => c3.competence_element_id,
          p_object_version_number  => c3.object_version_number );
   END LOOP;
*/

   -- We should delete the rows from pa_competence_profile table since
   -- the HR tables have been updated with this information.

   BEGIN
     DELETE from pa_competence_profiles
     where profile_id=p_profile_id;
   EXCEPTION
     WHEN OTHERS THEN
         RAISE;
   END;

EXCEPTION
   WHEN OTHERS THEN

     -- 4537865
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_COMP_PROFILE_PVT'
                    , p_procedure_name  => 'Validate_Competency'
                    , p_error_text      => x_msg_data);
     -- End : 4537865

     RAISE;
END Update_HR;

PROCEDURE Validate_Competency
(p_person_id           IN NUMBER,
 p_competence_id       IN NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2, -- Added the nocopy hint for 4537865
 x_error_message_code OUT NOCOPY VARCHAR2) IS  -- Added the nocopy hint for 4537865
l_comp_bg_id    NUMBER := null;
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  BEGIN
    SELECT business_group_id
    INTO l_comp_bg_id
    FROM per_competences
    WHERE  competence_id = p_competence_id;
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_COMPETENCY_INVALID_AMBIGOUS';
  END;

  IF (l_comp_bg_id IS NOT NULL
      AND l_comp_bg_id <> pa_utils.business_group_id)
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_PRM_BG_COMP_INVALID';
    IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
    END IF;
    RETURN;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
--4537865
EXCEPTION
	WHEN OTHERS THEN
	        x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
		x_error_message_code := SQLERRM;

		fnd_msg_pub.add_exc_msg
		(p_pkg_name => 'PA_COMP_PROFILE_PVT',
		  p_procedure_name => 'Validate_Competency',
		   p_error_text      => SUBSTRB(SQLERRM,1,240));

		RAISE ; -- Included RAISE because Caller of this API needs RAISE
END Validate_Competency;

/*----------------------------------------------------------------------
FUNCTION:    Awaiting_Approval
DESCRIPTION: Checks whether there is already an existing competence
             for the person waiting for approval.
----------------------------------------------------------------------*/
FUNCTION Awaiting_Approval
( p_person_id     IN NUMBER,
  p_competence_id IN NUMBER)
 RETURN VARCHAR2
IS
l_dummy VARCHAR2(1);
BEGIN

 SELECT 'x' INTO l_dummy
 FROM pa_competence_profiles
 WHERE person_id = p_person_id
 AND   competence_id = p_competence_id ;

 RETURN 'Y';

EXCEPTION
 WHEN no_data_found THEN
     RETURN 'N';
 -- Too many rows should not occur in normal cases; Still
 -- we will return 'Y' if that happens
 WHEN too_many_rows THEN
     RETURN 'Y';
 WHEN OTHERS THEN
     RAISE;
END Awaiting_Approval;

/*----------------------------------------------------------------------
FUNCTION:    Awaiting_Approval
DESCRIPTION: This is an overloaded function. Checks whether a particular
             competence element is waiting for approval.
----------------------------------------------------------------------*/
FUNCTION Awaiting_Approval
( p_element_id     IN NUMBER)
 RETURN VARCHAR2
IS
l_dummy VARCHAR2(1);
BEGIN

 SELECT 'x' INTO l_dummy
 FROM pa_competence_profiles
 WHERE competence_element_id = p_element_id;

 RETURN 'Y';

EXCEPTION
 WHEN no_data_found THEN
     RETURN 'N';
 -- Too many rows should not occur in normal cases; Still
 -- we will return 'Y' if that happens
 WHEN too_many_rows THEN
     RETURN 'Y';
 WHEN OTHERS THEN
     RAISE;
END Awaiting_Approval;

FUNCTION Check_Competence_Exists
( p_person_id     IN NUMBER,
  p_competence_id IN NUMBER)
 RETURN VARCHAR2
IS
l_dummy VARCHAR2(1);
BEGIN
 SELECT 'x' INTO l_dummy
 FROM per_competence_elements
 WHERE person_id = p_person_id
 AND   competence_id = p_competence_id ;

 RETURN 'Y';

EXCEPTION
 WHEN no_data_found THEN
     RETURN 'N';
 -- Too many rows should not occur in normal cases; Still
 -- we will return 'Y' if that happens
 WHEN too_many_rows THEN
     RETURN 'Y';
 WHEN OTHERS THEN
     RAISE;
END Check_Competence_Exists;

Procedure Approval_Message_Body
(document_id   in varchar2,
display_type   in varchar2,
document       in out nocopy varchar2, --4537865 Added the nocopy hint
document_type  in out nocopy varchar2)  --4537865 Added the nocopy hint
IS
l_profile_id         NUMBER;

/* Bug 2697431 Increased lenght of variables l_employee_disp_name and l_manager_disp_name to 360 from 80 */

l_employee_disp_name VARCHAR2(360);
l_manager_disp_name  VARCHAR2(360);
l_count                NUMBER;

cursor insert_profile
IS
SELECT PERSON_ID,
          OBJECT_VERSION_NUMBER,
          BUSINESS_GROUP_ID,
          COMPETENCE_NAME,
          EFFECTIVE_DATE_FROM,
          RATING_LEVEL_ID,
          RATING_LEVEL_VALUE
FROM PA_COMPETENCE_PROFILES
WHERE profile_id = l_profile_id
AND operation = 'INSERT';

cursor update_profile
IS
SELECT PERSON_ID,
          OBJECT_VERSION_NUMBER,
          BUSINESS_GROUP_ID,
          COMPETENCE_NAME,
          EFFECTIVE_DATE_FROM,
          RATING_LEVEL_ID,
          RATING_LEVEL_VALUE
FROM PA_COMPETENCE_PROFILES
WHERE profile_id = l_profile_id
AND operation = 'UPDATE';

cursor delete_profile
IS
SELECT PERSON_ID,
          OBJECT_VERSION_NUMBER,
          BUSINESS_GROUP_ID,
          COMPETENCE_NAME,
          EFFECTIVE_DATE_FROM,
          RATING_LEVEL_ID,
          RATING_LEVEL_VALUE
FROM PA_COMPETENCE_PROFILES
WHERE profile_id = l_profile_id
AND operation = 'DELETE';

BEGIN
  BEGIN
   -- if viewing method is through URL
   SELECT item_key
   INTO l_profile_id
   FROM wf_item_activity_statuses
   where notification_id = to_number(document_id);
  EXCEPTION
   WHEN NO_DATA_FOUND THEN
        -- if viewing method is email
     l_profile_id := to_number(wf_engine.setctx_itemkey);
  END;

  l_employee_disp_name := wf_engine.GetItemAttrText('PACOPR',
                                                    to_char(l_profile_id),
                                                    'EMPLOYEE_DISP_NAME');

  l_manager_disp_name   := wf_engine.GetItemAttrText( 'PACOPR'
                                                  , l_profile_id
                                                  , 'MANAGER_DISP_NAME'
                                                  );

  document := '<html>';
  document := document || '<body>';
  document := document || '<p> ' || l_manager_disp_name || ', </p>';
  document := document || '<p> These changes to competency profile requires your approval. Review the changes and select the action for these changes. </p>';

  document := document || '<p> Employee Name: ' ||
                           l_employee_disp_name || ' </p>';

  l_count := 0;
  FOR c1 in insert_profile LOOP
     l_count := l_count + 1;
     IF l_count = 1 THEN
         document := document ||  ' <p> <b> New Competencies : </b>  </p>';
     END IF;
     document := document ||  ' <p> Competence Name:  ' || c1.competence_name;
     document := document ||  ' Start Date:  ' ||
                                c1.effective_date_from;
     document := document ||  ' Rating Level:  ' ||
                                c1.rating_level_value || ' </p>';
  END LOOP;

  l_count := 0;
  FOR c2 in update_profile LOOP
     l_count := l_count + 1;
     IF l_count = 1 THEN
         document := document ||  ' <p> <b> Updated Competencies : </b> </p>';
     END IF;
     document := document ||  ' <p> Competence Name:  ' || c2.competence_name;
     document := document ||  ' Start Date:  ' ||
                                c2.effective_date_from;
     document := document ||  ' Rating Level:  ' ||
                                c2.rating_level_value || ' </p>';
  END LOOP;

/*
  -- We do not need the code below since we have decided not to start
  -- the approval process for deletes

  l_count := 0;
  FOR c3 in delete_profile LOOP
     l_count := l_count + 1;
     IF l_count = 1 THEN
         document := document ||  ' <p> <b> Deleted Competencies : </b> </p>';
     END IF;
     document := document ||  ' <p> Competence Name:  ' || c3.competence_name;
     document := document ||  ' Start Date:  ' ||
                                c3.effective_date_from;
     document := document ||  ' Rating Level:  ' ||
                                c3.rating_level_value || ' </p>';
  END LOOP;

  document := document || ' </body> ' || ' </html> ';
  document_type := 'text/html';
*/
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
	document_type := 'text/html';
	document :=' <html> <body> An Unexpected error has occured ' || SUBSTRB(SQLERRM ,1,240) || ' </body>  </html> ';
        -- Havent included RAISE because ,this is a message which will be sent as Email .
	-- Let the Unexpected Error be notified .
END;

Procedure Clear_Temp_Table
(p_profile_id    IN NUMBER,
x_return_status OUT NOCOPY  VARCHAR2, -- 4537865 Added the nocopy hint
x_msg_count     OUT NOCOPY NUMBER,   -- 4537865 Added the nocopy hint
x_msg_data      OUT NOCOPY VARCHAR2) -- 4537865 Added the nocopy hint
IS
BEGIN
  DELETE FROM pa_competence_profiles
  WHERE profile_id=p_profile_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := null;

EXCEPTION
  WHEN OTHERS THEN
       null;
END Clear_Temp_Table;

end PA_COMP_PROFILE_PVT ;

/
