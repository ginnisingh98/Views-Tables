--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_SET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_SET_UTILS" AS
/*$Header: PAPPSUTB.pls 120.2.12000000.2 2007/10/09 13:09:21 kmaddi ship $*/

--+

/*------------------------------------------------
  Procedure: getPartyIdName
  Description: Returns the party_id and
               party_name of the passed in user id
  ------------------------------------------------*/
PROCEDURE getPartyIdName (p_user_id      IN NUMBER
                         ,x_party_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                         ,x_party_name  OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
)
IS
    l_employee_id  fnd_user.employee_id%type;
    l_customer_id  fnd_user.person_party_id%type; -- 4586987 changed from customer_id to person_party_id
    l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
      -- 4586987 changed customer_id to person_party_id
      /*
      SELECT employee_id, customer_id
      INTO l_employee_id, l_customer_id
      FROM fnd_user
      WHERE user_id = p_user_id;
      */

      SELECT employee_id,person_party_id -- selecting person_party_id instead of customer_id
      INTO l_employee_id,l_customer_id
      from fnd_user
      WHERE user_id = p_user_id;

      -- 4586987 end

      IF l_employee_id IS NOT NULL THEN
         SELECT hp.party_id, hp.party_name
         INTO x_party_id, x_party_name
         FROM per_all_people_f pap, hz_parties hp
         WHERE pap.person_id = l_employee_id
           AND pap.party_id  = hp.party_id
           AND rownum        = 1;

      ELSIF l_customer_id IS NOT NULL THEN
         SELECT party_id, party_name
         INTO x_party_id, x_party_name
         FROM hz_parties
         WHERE party_type   = 'PERSON'
           AND party_id     = l_customer_id
           AND rownum       = 1;

      END IF;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         x_party_id := NULL;
         x_party_name := NULL;
END getPartyIdName;


FUNCTION get_project_set_lines(p_project_set_id     IN NUMBER)
   RETURN project_set_lines_tbl_type
IS

   l_project_set_lines_tbl   pa_project_set_utils.project_set_lines_tbl_type;

   TYPE number_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   l_project_set_id_tbl        number_tbl_type;
   l_project_id_tbl            number_tbl_type;

BEGIN

      SELECT project_set_id,
             project_id
      BULK COLLECT INTO
             l_project_set_id_tbl,
             l_project_id_tbl
      FROM pa_project_set_lines
      WHERE project_set_id = p_project_set_id;

   IF l_project_set_id_tbl.COUNT > 0 THEN

     FOR i IN l_project_set_id_tbl.FIRST .. l_project_set_id_tbl.LAST LOOP

        l_project_set_lines_tbl(i).project_set_id := l_project_set_id_tbl(i);
        l_project_set_lines_tbl(i).project_id     := l_project_id_tbl(i);

     END LOOP;

   END IF;

   RETURN l_project_set_lines_tbl;

END get_project_set_lines;


FUNCTION do_lines_exist(p_project_set_id  IN  NUMBER)
  RETURN VARCHAR2
IS
   l_lines_exist   VARCHAR2(1);

   CURSOR do_lines_exist IS
   SELECT 'Y'
   FROM pa_project_set_lines
   WHERE project_set_id = p_project_set_id;
BEGIN

  OPEN do_lines_exist;
  FETCH do_lines_exist into l_lines_exist;

  IF do_lines_exist%NOTFOUND THEN
     l_lines_exist := 'N';
  END IF;

  CLOSE do_lines_exist;

  return l_lines_exist;

EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END do_lines_exist;


FUNCTION check_projects_in_set(p_project_set_id  IN NUMBER
                              ,p_project_id      IN NUMBER)
RETURN VARCHAR2
IS
     l_exists   VARCHAR2(1);
BEGIN

     SELECT 'Y' INTO l_exists
     FROM pa_project_set_lines
     WHERE project_set_id = p_project_set_id
       AND project_id     = p_project_id;

     RETURN l_exists;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 'N';

END check_projects_in_set;


FUNCTION check_security_on_set(p_party_id IN NUMBER,
                               p_user_id NUMBER,
                               p_resp_id NUMBER)
RETURN VARCHAR2
IS
   l_update_sup_user  VARCHAR2(1);
   l_party_id         HZ_PARTIES.party_id%TYPE;
   l_party_name       HZ_PARTIES.party_name%TYPE;
BEGIN

   l_update_sup_user := PA_SECURITY_PVT.check_user_privilege(
                          p_privilege    => 'PA_PROJ_SET_UPDATE'
                         ,p_object_name  => null
                         ,p_object_key   => null);

   IF l_update_sup_user = 'T' THEN
         RETURN 'T';
   ELSE
         getPartyIdName ( p_user_id    => p_user_id
                         ,x_party_id   => l_party_id
                         ,x_party_name => l_party_name);

         IF p_party_id = l_party_id THEN
            RETURN 'T';
         ELSE
            RETURN 'F';
         END IF;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
END check_security_on_set;


FUNCTION is_name_unique(p_project_set_name  IN  VARCHAR2
                       ,p_project_set_id    IN  NUMBER := NULL)
  RETURN VARCHAR2
IS
   l_unique VARCHAR2(1);

   CURSOR check_name_unique IS
   SELECT 'N'
   FROM pa_project_sets_tl
   WHERE name = p_project_set_name
     AND language = userenv('lang')
     AND ((project_set_id <> p_project_set_id AND p_project_set_id IS NOT NULL)
           OR p_project_set_id IS NULL);

BEGIN

  OPEN check_name_unique;
  FETCH check_name_unique into l_unique;

  IF check_name_unique%NOTFOUND THEN
     l_unique := 'Y';
  END IF;

  CLOSE check_name_unique;

  return l_unique;

EXCEPTION
  WHEN OTHERS THEN
      RAISE;
END is_name_unique;


FUNCTION get_proj_set_name (p_project_set_id    IN  NUMBER)
  RETURN VARCHAR2
IS
   l_project_set_name  pa_project_sets_tl.name%type;

BEGIN

  SELECT name
  INTO l_project_set_name
  FROM pa_project_sets_tl
  WHERE project_set_id = p_project_set_id
  AND userenv('lang')  = language(+);  --Bug 6208018

  return l_project_set_name;

EXCEPTION
  WHEN OTHERS THEN
     RETURN NULL;
END get_proj_set_name;


PROCEDURE add_projects_to_proj_set
( p_project_set_id           IN  pa_project_sets_b.project_set_id%TYPE
 ,p_project_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_init_msg_list            IN  VARCHAR2  := FND_API.G_FALSE
 ,p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
 ,p_validate_only            IN  VARCHAR2  := FND_API.G_TRUE
 ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_project_list            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_project_set_name        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_msg_index_out      NUMBER;
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_project_id_tbl     SYSTEM.pa_num_tbl_type := p_project_id_tbl;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_exists             VARCHAR2(4);
  l_proj_set_name      pa_project_sets_tl.name%TYPE;
  l_project_list       VARCHAR2(2000) := '';
  l_project_name       pa_projects_all.name%TYPE;
  l_project_number     pa_projects_all.segment1%TYPE;
  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  CURSOR get_proj_name_number(l_project_id IN NUMBER)
  IS
     SELECT name, segment1
     FROM pa_projects_all
     WHERE project_id = l_project_id;

BEGIN

  -- initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_init_msg_list = FND_API.G_TRUE THEN
     fnd_msg_pub.initialize;
  END IF;

  -- get the project set name to be displayed in the informational msg if necessary
  l_proj_set_name := get_proj_set_name(p_project_set_id);

  -- loop through all project ids table to insert each project id
  -- into the Project Set.
  IF l_project_id_tbl.count > 0 THEN

     FOR I IN 1..l_project_id_tbl.count LOOP

        l_exists := check_projects_in_set(p_project_set_id, l_project_id_tbl(I));

        IF l_exists = 'N' THEN
           -- add the project to the project set, if it does not yet exist
           PA_PROJECT_SETS_PUB.create_project_set_line
              ( p_project_set_id  => p_project_set_id
               ,p_project_id      => l_project_id_tbl(I)
               ,x_return_status   => l_return_status
               ,x_msg_count       => l_msg_count
               ,x_msg_data        => l_msg_data
              );
           --dbms_output.put_line ('Successfully inserted ProjectId ###' || l_project_id_tbl(I) || '### into Project Set');

        ELSE
           -- The project already exists in the set. Add the project name, project number
           -- to the project list message to be later displayed on the project list page
           OPEN get_proj_name_number(l_project_id_tbl(I));
           FETCH get_proj_name_number INTO l_project_name, l_project_number;
           CLOSE get_proj_name_number;

           l_project_list := l_project_list || l_project_name || '(' || l_project_number || '), ';
           --dbms_output.put_line ('Project already exists. Add name, number to list');

        END IF;

     END LOOP;

  END IF;

  --dbms_output.put_line ('All concatenated project list is ' || l_project_list);

  x_project_list := l_project_list;
  x_project_set_name := l_proj_set_name;


EXCEPTION
  WHEN OTHERS THEN
     x_project_list     := '';
     x_project_set_name := '';
     x_return_status    := FND_API.G_RET_STS_ERROR;

END add_projects_to_proj_set;


PROCEDURE Check_PartyName_Or_Id(
        p_party_id           IN     NUMBER,
        p_party_name           IN     VARCHAR2,
        p_check_id_flag      IN     VARCHAR2,
        x_party_id           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status      OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_error_msg_code     OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

   -- Initialize the Error Stack
   IF l_enable_log = 'Y' THEN
   PA_DEBUG.init_err_stack('PA_PROJECT_SET_UTILS.Check_PartyName_Or_Id');
   END IF;

   -- Initialize the return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_party_id IS NOT NULL THEN
     IF p_check_id_flag = 'Y' THEN
       SELECT party_id
       INTO   x_party_id
       FROM   hz_parties
       WHERE  party_id = p_party_id;
     ELSE
       x_party_id := p_party_id;
     END IF;
   ELSE
     SELECT party_id
     INTO x_party_id
     FROM hz_parties
     WHERE party_name = p_party_name;
   END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_party_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_PARTY_INVALID';
    WHEN TOO_MANY_ROWS then
      x_party_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_MULTIPLE_PARTY';
    WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_PROJECT_SET_UTILS.Check_PartyName_Or_Id'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RAISE;
END Check_PartyName_Or_Id;


PROCEDURE Check_ProjectSetName_Or_Id(
        p_project_set_id         IN     NUMBER
       ,p_project_set_name   IN     VARCHAR2
       ,p_check_id_flag          IN     VARCHAR2
       ,x_project_set_id        OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_return_status         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_msg_code    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   l_current_id     NUMBER     := NULL;
   l_num_ids        NUMBER     := 0;
   l_id_found_flag  VARCHAR(1) := 'N';
   l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   CURSOR p_ids IS
      SELECT project_set_id
      FROM pa_project_sets_vl
      WHERE upper(name) = upper(p_project_set_name);
BEGIN

   if (p_project_set_id = FND_API.G_MISS_NUM) OR (p_project_set_id is NULL) then
      if (p_project_set_name is not NULL) then
      SELECT project_set_id
          INTO x_project_set_id
          FROM pa_project_sets_vl
          WHERE upper(name) = upper(p_project_set_name);
      else
      x_project_set_id := NULL;
      end if;

   else
      IF p_check_id_flag = 'Y' THEN
         SELECT project_set_id
         INTO x_project_set_id
         FROM pa_project_sets_vl
         WHERE project_set_id = p_project_set_id;

      ELSIF (p_check_id_flag='N') THEN
          x_project_set_id := p_project_set_id;

      ELSIF (p_check_id_flag = 'A') THEN
          IF (p_project_set_name IS NULL) THEN
              -- Return a null ID since the name is null.
              x_project_set_id := NULL;
          ELSE

              -- Find the ID which matches the Name passed
              OPEN p_ids;
              LOOP
                FETCH p_ids INTO l_current_id;
                EXIT WHEN p_ids%NOTFOUND;
                IF (l_current_id =  p_project_set_id) THEN
                      l_id_found_flag := 'Y';
                      x_project_set_id := p_project_set_id;
                END IF;
              END LOOP;
              l_num_ids := p_ids%ROWCOUNT;
              CLOSE p_ids;

              IF (l_num_ids = 0) THEN
                  -- No IDs for name
                  RAISE NO_DATA_FOUND;
              ELSIF (l_num_ids = 1) THEN
                  -- Since there is only one ID for the name use it.
                  x_project_set_id := l_current_id;
              ELSIF (l_id_found_flag = 'N') THEN
                  -- More than one ID for the name and none of the IDs matched
                  -- the ID passed in.
                  RAISE TOO_MANY_ROWS;
              END IF;
          END IF;

      ELSE
         x_project_set_id := NULL;
      END IF;

   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   when NO_DATA_FOUND then
      x_project_set_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_PROJECT_SET_INVALID';
   when TOO_MANY_ROWS then
      x_project_set_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_PROJECT_SET_INVALID';
   when OTHERS then
      x_project_set_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_PROJECT_SETS_UTILS', p_procedure_name  => 'CHECK_PROJECTSETNAME_OR_ID');
      raise;

END Check_ProjectSetName_Or_Id;

FUNCTION is_party_internal (p_party_id  IN NUMBER) RETURN VARCHAR2
IS
  CURSOR c1 IS
    SELECT orig_system_reference
    FROM hz_parties
    WHERE party_id = p_party_id;
  v_c1 c1%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;

  IF SUBSTR(v_c1.orig_system_reference, 1, 4) = 'PER:' THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END is_party_internal;

END PA_PROJECT_SET_UTILS;

/
