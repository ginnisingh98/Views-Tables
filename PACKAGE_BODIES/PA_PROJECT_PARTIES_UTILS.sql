--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_PARTIES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_PARTIES_UTILS" AS
/* $Header: PARPPU2B.pls 120.7 2006/03/28 00:24:38 sunkalya noship $ */

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION VALIDATE_DELETE_PARTY_OK (p_project_id  IN NUMBER,
                                   p_project_party_id IN NUMBER) RETURN VARCHAR2 IS

BEGIN

  RETURN 'Y';

END VALIDATE_DELETE_PARTY_OK;

FUNCTION ACTIVE_PARTY (	p_start_date_active IN DATE,
			p_end_date_active IN DATE) RETURN VARCHAR2 IS

BEGIN
	IF(	(SYSDATE BETWEEN p_start_date_active AND p_end_date_active) OR
		(p_start_date_active <= SYSDATE AND p_end_date_active IS NULL)) THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;
END ACTIVE_PARTY;


PROCEDURE GET_PROJECT_DATES (p_project_id IN NUMBER,
                             x_project_start_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_project_end_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_return_status  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

 /* Bug 2636791 - changes begin */
 /* Commenting this query and  selecting start date from PA_PROJECT_DATES_UTILS.GET_PROJECT_START_DATE */
 /*  select start_date, completion_date
     into x_project_start_date, x_project_end_date
     from pa_projects_all
    where project_id = p_project_id;  */

    SELECT PA_PROJECT_DATES_UTILS.GET_PROJECT_START_DATE(p_project_id), completion_date
     INTO x_project_start_date, x_project_end_date
     FROM pa_projects_all
    WHERE project_id = p_project_id;

  /* Bug 2636791 - changes end */

EXCEPTION WHEN OTHERS THEN
 fnd_message.set_name('PA','PA_NO_PROJECT_ID');
      fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
      fnd_message.set_token('PROCEDURE_NAME','GET_PROJECT_DATES');
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
END;


PROCEDURE VALIDATE_PROJECT_PARTY( p_validation_level      IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
                                p_debug_mode            IN VARCHAR2 DEFAULT 'N',
                                p_object_id             IN NUMBER,
                                p_OBJECT_TYPE           IN VARCHAR2,
                                p_project_role_id       IN NUMBER,
                                p_resource_type_id      IN NUMBER DEFAULT 101,
                                p_resource_source_id    IN NUMBER,
                                p_start_date_active     IN DATE,
                                p_scheduled_flag        IN VARCHAR2,
                                p_record_version_number IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                p_calling_module        IN VARCHAR2,
                                p_action                IN VARCHAR2,
                                p_project_id            IN NUMBER,
                                p_project_end_date      IN DATE,
                                p_end_date_active       IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                p_project_party_id      IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_call_overlap          IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_assignment_action     IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status         OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_error_occured         VARCHAR2(1) := 'N';
   l_project_party_id      NUMBER;
   l_record_version_number NUMBER;
   l_end_date_active       DATE; --Bug 4565156 NOCOPY changes

   CURSOR c_duplicate_customer_org IS
   SELECT 'Y'
   FROM pa_project_parties ppp,
        pa_project_role_types_b r1,
        pa_project_role_types_b r2
   WHERE r1.project_role_id = p_project_role_id
   AND r1.role_party_class = 'CUSTOMER'
   AND ppp.object_id = p_object_id
   AND ppp.object_type = p_object_type
   AND ppp.resource_type_id = 112
   AND ppp.resource_source_id = p_resource_source_id
   AND r2.project_role_id = ppp.project_role_id
   AND r2.role_party_class = 'CUSTOMER'
   AND ROWNUM=1;

   l_dummy VARCHAR2(1);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   pa_debug.set_err_stack('Validate_project_party');

   l_end_date_active := p_end_date_active; --Bug 4565156 NOCOPY changes

   --MT OrgRole changes: ext people are not schedulable
   IF p_resource_type_id = 112 AND p_scheduled_flag = 'Y' THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('PA','PA_NO_SCHEDULE_HZ_PARTY');
     fnd_msg_pub.ADD;
     RETURN;
   END IF;
   --/MT

/*Code Addition for bug 2983546 -- Ext people are not allowed as project Managers */

  IF  p_resource_type_id = 112 AND p_project_role_id=1 THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('PA','PA_NO_EXT_MANAGER');
     fnd_msg_pub.ADD;
     RETURN;
   END IF;

/*Code Addition ends - 2983546*/


   --- call to check all mandatory fields are given
            IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Calling check_mandatory_fields.');
         END IF;
   pa_project_parties_utils.check_mandatory_fields(p_project_role_id => p_project_role_id,
                                                   p_resource_type_id => p_resource_type_id,
                                                   p_resource_source_id => p_resource_source_id,
                                                   p_start_date_active => p_start_date_active,
                                                   p_end_date_active => p_end_date_active,
                                                   p_project_end_date => p_project_end_date,
                                                   p_scheduled_flag => p_scheduled_flag,
                                                   x_error_occured => l_error_occured);
  IF (l_error_occured = 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --dbms_output.put_line('After checking the mandatory errors'||x_return_status);

  -- Bug 2671210. Check to validate role-party combination.
  --- call to validate role party combination
  IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Validate_role_party: Calling Validate_role_party.');
  END IF;

  pa_project_parties_utils.Validate_role_party(p_project_role_id => p_project_role_id,
                                               p_resource_type_id => p_resource_type_id,
                                               p_resource_source_id => p_resource_source_id,
                                               x_error_occured => l_error_occured);

  IF (l_error_occured = 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
  -- bug2671210 ended.

   --- call to validate the start and end dates for the person
         IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Calling validate_dates.');
         END IF;
   pa_project_parties_utils.validate_dates(p_start_date_active => p_start_date_active,
                                           p_end_date_active  => p_end_date_active,
                                           x_error_occured => l_error_occured);

  IF (l_error_occured = 'Y') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

/* Start of Bug 3096700 */
/* Adding a validation for checking if the project role start date lies between specified start active and end active date */
    l_dummy := 'N';
    BEGIN
        SELECT 'Y'
        INTO l_dummy
        FROM pa_project_role_types_b
        WHERE project_role_id = p_project_role_id
        AND  p_start_date_active BETWEEN start_date_active AND NVL(end_date_active,p_start_date_active)
        AND (p_end_date_active IS NULL
             OR p_end_date_active BETWEEN start_date_active AND NVL(end_date_active,p_end_date_active));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            fnd_message.set_name('PA','PA_ROLE_INACTIVE');
            fnd_msg_pub.ADD;
    END;
/* End of 3096700 */
   --dbms_output.put_line('after validating dates'||x_return_status);
  x_assignment_action := 'NOACTION';

  IF (p_calling_module NOT IN ('EXCHANGE','FORM')) THEN

     IF (p_action = 'INSERT' OR pa_project_parties_utils.get_scheduled_flag(p_project_party_id, p_record_version_number) <> p_scheduled_flag) THEN

     IF p_resource_type_id = 112 THEN
       IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Looking for customer org duplicate.');
       END IF;

       OPEN c_duplicate_customer_org;
       FETCH c_duplicate_customer_org INTO l_dummy;
       IF c_duplicate_customer_org%FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_message.set_name('PA','PA_DUPLICATE_CUSTOMER_ORG');
         fnd_msg_pub.ADD;
         CLOSE c_duplicate_customer_org;
         RETURN;
       END IF;
       CLOSE c_duplicate_customer_org;
     END IF;


     IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Checking for schedule flag.');
     END IF;

     IF p_scheduled_flag = 'Y' THEN
         IF VALIDATE_SCHEDULE_ALLOWED(p_project_role_id) = 'Y' THEN
             --dbms_output.put_line('schedule is allowed for this role');
             x_assignment_action := 'CREATE';
         ELSE
             --dbms_output.put_line('schedule is not allowed for this role');
             x_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('PA','PA_NO_SCHEDULE_ALLOWED');
             --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
             --fnd_message.set_token('PROCEDURE_NAME','VALIDATE_PROJECT_PARTY');
             fnd_msg_pub.ADD;
         END IF;
     ELSE
         IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: No schedule required.');
         END IF;

         --dbms_output.put_line('no assignment required');
         x_assignment_action := 'NOACTION';
     END IF;

     IF p_scheduled_flag = 'N' AND p_action = 'UPDATE' THEN
         IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Need to delete schedule.');
         END IF;

           --dbms_output.put_line('need to delete assignment');
         x_assignment_action := 'DELETE';
     END IF;
   END IF;

   IF x_assignment_action = 'CREATE' OR (p_action = 'INSERT' AND p_calling_module <> 'PROJECT_MEMBER') THEN
       --dbms_output.put_line('trying to get person id');
       IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Getting the project party id.');
       END IF;
       pa_project_parties_utils.get_person_party_id(p_object_type => p_object_type,
                                                    p_object_id => p_object_id,
                                                    p_project_role_id => p_project_role_id,
                                                    p_resource_type_id => p_resource_type_id,
                                                    p_resource_source_id => p_resource_source_id,
                                                    p_start_date_active => p_start_date_active,
                                                    p_end_date_active => p_end_date_active,
                                                    x_project_party_id => l_project_party_id,
                                                    x_record_version_number => l_record_version_number);

       --dbms_output.put_line('person id'||to_char(l_project_party_id));
       IF l_project_party_id <> -999 THEN
           x_call_overlap := 'N';
           IF pa_project_parties_utils.get_scheduled_flag(l_project_party_id, l_record_version_number) <> 'Y' THEN
               p_project_party_id := l_project_party_id;
               p_record_version_number := l_record_version_number;
           ELSE
              --dbms_output.put_line('cannot create duplicate record');
              x_return_status := FND_API.G_RET_STS_ERROR;
              fnd_message.set_name('PA','PA_XC_TOO_MANY_OMGRS');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','VALIDATE_PROJECT_PARTY');
              fnd_msg_pub.ADD;
           END IF;
      END IF;
  END IF;

  END IF;

  IF x_call_overlap = 'Y' OR p_action = 'UPDATE' OR p_calling_module = 'EXCHANGE' THEN

   IF p_project_role_id = 1 THEN  -- hard coded for Project Manager
      IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Calling validate_no_overlap_manager.');
      END IF;
      pa_project_parties_utils.validate_no_overlap_manager(p_object_type => p_object_type,
                                                    p_object_id => p_object_id,
                                                    p_project_role_id => p_project_role_id,
                                                    p_project_party_id => p_project_party_id,
                                                    p_start_date_active => p_start_date_active,
                                                    p_end_date_active => p_end_date_active,
                                                    x_error_occured => l_error_occured);
       IF (l_error_occured = 'Y') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     --dbms_output.put_line('validating manager');
   ELSE
      IF (p_debug_mode = 'Y') THEN
              pa_debug.debug('Validate_project_party: Calling validate_person_not_overlapped.');
      END IF;
      pa_project_parties_utils.validate_person_not_overlapped(p_object_type => p_object_type,
                                                    p_object_id => p_object_id,
                                                    p_project_role_id => p_project_role_id,
                                                    p_project_party_id => p_project_party_id,
                                                    p_resource_type_id => p_resource_type_id,
                                                    p_resource_source_id => p_resource_source_id,
                                                    p_start_date_active => p_start_date_active,
                                                    p_end_date_active => p_end_date_active,
                                                    x_error_occured => l_error_occured);
       IF (l_error_occured = 'Y') THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     --dbms_output.put_line('validating overlap');
   END IF;
 END IF;

EXCEPTION WHEN OTHERS THEN
    p_end_date_active := l_end_date_active; --Bug 4565156 NOCOPY changes
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => 'VALIDATE_PROJECT_PARTY',
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;

END VALIDATE_PROJECT_PARTY;


FUNCTION GET_SCHEDULED_FLAG(p_project_party_id  IN NUMBER,
                            p_record_version_number  IN NUMBER) RETURN VARCHAR2 IS
  l_scheduled_flag  VARCHAR2(1);
BEGIN
   pa_debug.set_err_stack('Get_scheduled_flag');
  SELECT scheduled_flag INTO l_scheduled_flag
    FROM pa_project_parties
   WHERE project_party_id = NVL(p_project_party_id,-999)
     AND record_version_number = NVL(p_record_version_number,record_version_number);

   pa_debug.reset_err_stack;
  RETURN l_scheduled_flag;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('PA','PA_NO_SCHEDULE_ALLOWED');
      --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
      --fnd_message.set_token('FUNCTION_NAME','GET_SCHEDULED_FLAG');
      fnd_msg_pub.ADD;
      RETURN 'X';
    WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
END GET_SCHEDULED_FLAG;


FUNCTION VALIDATE_SCHEDULE_ALLOWED(p_project_role_id  IN NUMBER) RETURN VARCHAR2 IS
     x_sch_flag  VARCHAR2(1) := 'N';
BEGIN

   pa_debug.set_err_stack('Validate_scheduled_allowed');
   x_sch_flag := pa_role_utils.get_schedulable_flag(p_role_id => p_project_role_id);

   pa_debug.reset_err_stack;

   RETURN x_sch_flag;

EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
     RAISE;
END VALIDATE_SCHEDULE_ALLOWED;


PROCEDURE GET_PERSON_PARTY_ID(p_object_type        IN VARCHAR2,
                              p_object_id          IN NUMBER,
                              p_project_role_id     IN NUMBER,
                              p_resource_type_id      IN NUMBER DEFAULT 101,
                              p_resource_source_id  IN NUMBER,
                              p_start_date_active   IN DATE,
                              p_end_date_active     IN DATE,
                              x_project_party_id    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_record_version_number OUT NOCOPY NUMBER) IS --File.Sql.39 bug 4440895
BEGIN
   pa_debug.set_err_stack('Get_person_party_id');
  x_project_party_id := -999;

  SELECT project_party_id, record_version_number INTO x_project_party_id, x_record_version_number
    FROM pa_project_parties
   WHERE object_type = p_object_type
     AND object_id = p_object_id
     AND project_role_id = p_project_role_id
     AND resource_type_id = p_resource_type_id
     AND resource_source_id = p_resource_source_id
     AND start_date_active = TRUNC(p_start_date_active)
     AND end_date_active = TRUNC(p_end_date_active);

   pa_debug.reset_err_stack;

EXCEPTION WHEN NO_DATA_FOUND THEN
    x_project_party_id := -999;
    WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;
END GET_PERSON_PARTY_ID;


PROCEDURE CHECK_MANDATORY_FIELDS(p_project_Role_id        IN NUMBER,
                                 p_resource_type_id       IN NUMBER DEFAULT 101,
                                 p_resource_source_id     IN NUMBER,
                                 p_start_date_active      IN DATE,
                                 p_end_date_active        IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                 p_project_end_date       IN DATE,
                                 p_scheduled_flag         IN VARCHAR2,
                                 x_error_occured          OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN
   pa_debug.set_err_stack('Check_mandatory_fields');
    IF p_project_Role_id IS NULL THEN
              fnd_message.set_name('PA','PA_XC_NO_ROLE_TYPE');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','CHECK_MANDATORY_FIELDS');
              fnd_msg_pub.ADD;
          --dbms_output.put_line('PA_XC_NO_ROLE_TYPE');
              x_error_occured := 'Y';
    END IF;

    IF p_resource_source_id IS NULL THEN
              fnd_message.set_name('PA','PA_XC_NO_PERSON_ID');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','CHECK_MANDATORY_FIELDS');
              fnd_msg_pub.ADD;
          --dbms_output.put_line('PA_XC_NO_PERSON_ID');
              x_error_occured := 'Y';
    END IF;

    IF p_start_date_active IS NULL THEN
              fnd_message.set_name('PA','PA_START_DATE_IS_MISSING');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','CHECK_MANDATORY_FIELDS');
              fnd_msg_pub.ADD;
          --dbms_output.put_line('PA_START_DATE_IS_MISSING');
       x_error_occured := 'Y';
    END IF;

    IF p_end_date_active IS NULL THEN
        IF (p_scheduled_flag = 'Y' AND pa_project_parties_utils.validate_schedule_allowed(p_project_role_id)='Y') THEN
            IF p_project_end_date IS NULL OR p_project_end_date < p_start_date_active THEN
              fnd_message.set_name('PA','PA_END_DATE_IS_MISSING');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','CHECK_MANDATORY_FIELDS');
              fnd_msg_pub.ADD;
                 x_error_occured := 'Y';
          --dbms_output.put_line('PA_END_DATE_IS_MISSING');
            ELSE
                 p_end_date_active := p_project_end_date;
            END IF;

        END IF;

    END IF;
   pa_debug.reset_err_stack;

END CHECK_MANDATORY_FIELDS;


PROCEDURE VALIDATE_DATES( p_start_date_active   IN DATE,
                          p_end_date_active     IN DATE,
                          x_error_occured       OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN

   pa_debug.set_err_stack('Validate_dates');
  IF p_end_date_active IS NOT NULL  THEN
   IF (p_end_date_active < p_start_date_active) THEN
              fnd_message.set_name('PA','PA_SU_INVALID_DATES');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME',pa_debug.g_err_stack);
              fnd_msg_pub.ADD;
       x_error_occured := 'Y';
   END IF;
  END IF;
  pa_debug.reset_err_stack;

END VALIDATE_DATES;


PROCEDURE VALIDATE_NO_OVERLAP_MANAGER( p_object_type       IN VARCHAR2,
                                       p_object_id         IN NUMBER,
                                       p_project_role_id    IN NUMBER,
                                       p_project_party_id   IN NUMBER,
                                       p_start_date_active  IN DATE,
                                       p_end_date_active    IN DATE,
                                       x_error_occured      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
   l_error_occured  VARCHAR2(1);
BEGIN
   pa_debug.set_err_stack('Validate_no_overlap_manager');

   SELECT 'Y' INTO l_error_occured
     FROM pa_project_parties
    WHERE object_type = p_object_type
      AND object_id = p_object_id
      AND project_role_id = p_project_role_id
      AND project_party_id <> NVL(p_project_party_id,-999)
      AND (p_start_date_active BETWEEN start_date_active AND NVL(end_date_active,start_date_active)
       OR NVL(p_end_date_active, p_start_date_active) BETWEEN start_date_active AND NVL(end_date_active,start_date_active)
       OR start_date_active BETWEEN p_start_date_active AND NVL(p_end_date_active,start_date_active+1)
       OR NVL(end_Date_active,start_date_active) BETWEEN p_start_date_active AND NVL(p_end_date_active,start_date_active+1)
       OR (p_start_date_active > start_date_active AND end_date_active IS NULL));

              x_error_occured := l_error_occured;
              fnd_message.set_name('PA','PA_PR_TOO_MANY_MGRS');
              --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
              --fnd_message.set_token('PROCEDURE_NAME','VALIDATE_NO_OVERLAP_MANAGER');
              fnd_msg_pub.ADD;
   --dbms_output.put_line('here');
   pa_debug.reset_err_stack;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    x_error_occured := 'N';
    WHEN TOO_MANY_ROWS THEN
    fnd_message.set_name('PA','PA_PR_TOO_MANY_MGRS');
    fnd_msg_pub.ADD;
    x_error_occured := 'Y';
    WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;
END VALIDATE_NO_OVERLAP_MANAGER;


PROCEDURE VALIDATE_PERSON_NOT_OVERLAPPED( p_object_type       IN VARCHAR2,
                                       p_object_id         IN NUMBER,
                                       p_project_role_id    IN NUMBER,
                                       p_project_party_id   IN NUMBER,
                                       p_resource_type_id      IN NUMBER DEFAULT 101,
                                       p_resource_source_id IN NUMBER,
                                       p_start_date_active  IN DATE,
                                       p_end_date_active    IN DATE,
                                       x_error_occured      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
  l_error_occured  VARCHAR2(1);
BEGIN
   pa_debug.set_err_stack('Validate_person_not_overlapped');

   SELECT 'Y' INTO l_error_occured
     FROM pa_project_parties
    WHERE object_type = p_object_type
      AND object_id = p_object_id
      AND project_role_id = p_project_role_id
      AND resource_type_id = p_resource_type_id
      AND resource_source_id = p_resource_source_id
      AND project_party_id <> NVL(p_project_party_id,-999)
      AND (p_start_date_active BETWEEN start_date_active AND NVL(end_date_active,start_date_active)
       OR NVL(p_end_date_active, p_start_date_active) BETWEEN start_date_active AND NVL(end_date_active,start_date_active)
       OR start_date_active BETWEEN p_start_date_active AND NVL(p_end_date_active,start_date_active+1)
       OR NVL(end_date_active,start_date_active) BETWEEN p_start_date_active AND NVL(p_end_date_active,start_date_active+1)
       OR (p_start_date_active > start_date_active AND  end_date_active IS NULL));

     x_error_occured := l_error_occured;
     --dbms_output.put_line(l_error_occured);
     fnd_message.set_name('PA','PA_XC_TOO_MANY_OMGRS');
     --fnd_message.set_token('PKG_NAME',to_char(p_project_role_id));
     --fnd_message.set_token('PROCEDURE_NAME',to_char(p_resource_source_id));
     fnd_msg_pub.ADD;
   pa_debug.reset_err_stack;
EXCEPTION WHEN NO_DATA_FOUND THEN
    x_error_occured := 'N';
WHEN TOO_MANY_ROWS THEN
    fnd_message.set_name('PA','PA_XC_TOO_MANY_OMGRS');
    fnd_msg_pub.ADD;
    x_error_occured := 'Y';
WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;

END VALIDATE_PERSON_NOT_OVERLAPPED;


FUNCTION get_project_role_id(p_project_role_type IN VARCHAR2,
                             p_calling_module    IN VARCHAR2) RETURN NUMBER IS
  l_project_role_id    NUMBER;
BEGIN
    IF p_project_role_type IS NOT NULL THEN
      BEGIN
       SELECT project_role_id INTO l_project_role_id
         FROM pa_project_role_types_vl
        WHERE (meaning = p_project_role_type AND p_calling_module <> 'FORM')
           OR (project_role_type = p_project_role_type AND p_calling_module = 'FORM');
       RETURN l_project_role_id;
       EXCEPTION WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('PA','PA_XC_NO_ROLE_TYPE');
          --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
          --fnd_message.set_token('PROCEDURE_NAME','GET_PROJECT_ROLE_ID');
          fnd_msg_pub.ADD;
          RETURN -999;
       END;
     ELSE
        fnd_message.set_name('PA','PA_XC_NO_ROLE_TYPE');
        --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
        --fnd_message.set_token('PROCEDURE_NAME','GET_PROJECT_ROLE_ID');
        fnd_msg_pub.ADD;
        RETURN -999;
     END IF;
END;

FUNCTION get_resource_source_id(p_resource_name IN VARCHAR2) RETURN NUMBER IS
  l_resource_id NUMBER;
BEGIN
  IF p_resource_name IS NOT NULL THEN
  BEGIN
  SELECT person_id INTO l_resource_id
    FROM pa_employees
   WHERE full_name = p_resource_name
     AND active = '*';
  RETURN l_resource_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('PA','PA_XC_NO_PERSON_ID');
      --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
      --fnd_message.set_token('PROCEDURE_NAME','GET_RESOURCE_SOURCE_ID');
      fnd_msg_pub.ADD;
      RETURN -999;
    WHEN TOO_MANY_ROWS THEN
      fnd_message.set_name('PA','PA_TOO_MANY_PERSONS');
      --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
      --fnd_message.set_token('PROCEDURE_NAME','GET_RESOURCE_SOURCE_ID');
      fnd_msg_pub.ADD;
      RETURN -999;
   END;
   ELSE
      fnd_message.set_name('PA','PA_XC_NO_PERSON_ID');
      --fnd_message.set_token('PKG_NAME','PA_PROJECT_PARTIES_UTILS');
      --fnd_message.set_token('PROCEDURE_NAME','GET_RESOURCE_SOURCE_ID');
      fnd_msg_pub.ADD;
      RETURN -999;
   END IF;
END;
-------------
FUNCTION ENABLE_EDIT_LINK(p_project_id        IN NUMBER,
                          p_scheduled_flag    IN VARCHAR2,
                          p_assignment_id     IN NUMBER) RETURN VARCHAR2 IS

BEGIN
    IF p_scheduled_flag = 'Y' THEN
      RETURN 'S';
    ELSE
      RETURN 'T';
    END IF;
END;

FUNCTION get_grant_id(p_project_party_id   IN NUMBER) RETURN RAW IS
l_grant_id   RAW(16);

BEGIN
pa_debug.set_err_stack('get_grant_id');
SELECT grant_id INTO l_grant_id
  FROM pa_project_parties
 WHERE project_party_id = p_project_party_id;
pa_debug.reset_err_stack;

RETURN l_grant_id;

EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;
END;

PROCEDURE GET_CURR_PROJ_MGR_DETAILS(p_project_id        IN NUMBER,
                                              x_manager_person_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                              x_manager_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                              x_project_party_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                              x_project_role_id   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                              x_project_role_name OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                              x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                              x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  pa_debug.set_err_stack('get_current_project_manager_details');

  BEGIN
  SELECT ppp.resource_source_id,
         ppp.project_party_id,
         ppp.project_role_id,
         pprt.meaning,
         pe.full_name
    INTO x_manager_person_id,
         x_project_party_id,
         x_project_role_id,
         x_project_role_name,
         x_manager_name
    FROM pa_project_parties  ppp,
         pa_project_role_types pprt,
         per_all_people_f pe
   WHERE ppp.project_id = p_project_id
     AND ppp.project_role_id = 1
     AND ppp.project_role_id = pprt.project_role_id
     AND ppp.resource_type_id = 101
     AND ppp.resource_source_id = pe.person_id
     AND TRUNC(SYSDATE) BETWEEN pe.effective_start_date
     AND pe.effective_end_date
     AND ppp.object_type = 'PA_PROJECTS'
     AND TRUNC(SYSDATE) BETWEEN ppp.start_date_active AND NVL(ppp.end_date_active,TRUNC(SYSDATE)+1);

     EXCEPTION WHEN NO_DATA_FOUND THEN
    SELECT ppp.resource_source_id,
         ppp.project_party_id,
         ppp.project_role_id,
         pprt.meaning,
         pe.full_name
    INTO x_manager_person_id,
         x_project_party_id,
         x_project_role_id,
         x_project_role_name,
         x_manager_name
    FROM pa_project_parties  ppp,
         pa_project_role_types pprt,
         per_all_people_f pe
   WHERE ppp.project_id = p_project_id
     AND ppp.project_role_id = 1
     AND ppp.project_role_id = pprt.project_role_id
     AND ppp.resource_type_id = 101
     AND ppp.resource_source_id = pe.person_id
     AND TRUNC(SYSDATE) BETWEEN pe.effective_start_date
     AND pe.effective_end_date
     AND ppp.object_type = 'PA_PROJECTS'
     AND ppp.start_date_active > TRUNC(SYSDATE)
     AND ppp.start_date_active = (SELECT MIN(ppp1.start_date_active)
                                    FROM pa_project_parties ppp1
                                   WHERE ppp1.project_id = p_project_id
                                     AND ppp1.project_role_id = 1
                                     AND ppp1.start_date_active > TRUNC(SYSDATE));
  END;

pa_debug.reset_err_stack;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_error_message_code := 'PA_NO_PROJ_MGR_EXISTS';
   WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;
END GET_CURR_PROJ_MGR_DETAILS;


FUNCTION get_customer_project_party_id (
  p_project_id IN NUMBER,
  p_customer_id IN NUMBER) RETURN NUMBER

IS
  ret NUMBER;
BEGIN
  SELECT project_party_id
  INTO ret
  FROM pa_project_parties p,
       pa_project_role_types_b r,
       pa_customers_v c
  WHERE r.role_party_class = 'CUSTOMER'
    AND p.project_role_id = r.project_role_id
    AND p.project_id = p_project_id
    AND p.resource_type_id = 112
    AND c.party_id = p.resource_source_id

    AND c.customer_id = p_customer_id;

  RETURN ret;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END get_customer_project_party_id;

PROCEDURE VALIDATE_ROLE_PARTY( p_project_role_id    IN NUMBER,
                               p_resource_type_id   IN NUMBER DEFAULT 101,
                               p_resource_source_id IN NUMBER,
                               x_error_occured      OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

  l_party_type VARCHAR2(30) := 'PERSON';
  l_role_party_class  pa_project_role_types_b.role_party_class%TYPE;
BEGIN
  pa_debug.set_err_stack('Validate_role_party');

-- Check if the resource is a Person/Organization.
  IF p_resource_type_id = 112 THEN
    SELECT party_type
    INTO l_party_type
    FROM hz_parties
    WHERE  party_id = p_resource_source_id;
  END IF;

  -- Check if the role is for Person/Organization.
  SELECT role_party_class
  INTO l_role_party_class
  FROM pa_project_role_types_b
  WHERE project_role_id = p_project_role_id;

  x_error_occured := 'N';

  IF (l_role_party_class = 'PERSON' AND l_party_type <> 'PERSON') OR
     (l_role_party_class <> 'PERSON' AND l_party_type = 'PERSON') THEN
    fnd_message.set_name('PA','PA_XC_NO_ROLE_TYPE');
    fnd_msg_pub.ADD;
    x_error_occured := 'Y';
  END IF;

  pa_debug.reset_err_stack;
EXCEPTION
  WHEN OTHERS THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_PROJECT_PARTIES_UTILS',
                            p_procedure_name => pa_debug.g_err_stack,
                            p_error_text => SUBSTRB(SQLERRM,1,240));
    RAISE;
END VALIDATE_ROLE_PARTY;


FUNCTION GET_PROJECT_MANAGER( p_project_id  IN NUMBER)
RETURN NUMBER
IS

CURSOR C1 (c_as_of_date DATE) IS
Select PPP.RESOURCE_SOURCE_ID
FROM PA_PROJECT_PARTIES         PPP  ,
     --PA_PROJECT_ROLE_TYPES      PPRT --bug 4004821
     PA_PROJECT_ROLE_TYPES_B      PPRT
WHERE
    PPP.PROJECT_ID                      = p_project_id
AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
AND ppp.resource_type_id 		= 101             --Added this condition to improve performance. Bug:4752054
AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
AND trunc(c_as_of_date)  between trunc(PPP.start_date_active)
AND                         NVL(trunc(PPP.end_date_active),c_as_of_date);

l_return_value    NUMBER(10);
l_project_finish_date  DATE;
l_project_start_date DATE;

BEGIN

  PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID := null;

  l_project_finish_date := PA_PROJECT_DATES_UTILS.Get_Project_Finish_Date(p_project_id);

  -- return project manager as of project finish date for past projects
  IF l_project_finish_date < sysdate THEN
    OPEN C1 (l_project_finish_date);
    FETCH C1 INTO l_return_value;
    CLOSE C1;
  ELSE
    -- Bug 4361712
    l_project_start_date := PA_PROJECT_DATES_UTILS.Get_Project_Start_Date(p_project_id);

    -- return project manager as of project start date for future projects
    IF l_project_start_date > sysdate THEN
      OPEN C1 (l_project_start_date);
      FETCH C1 INTO l_return_value;
      CLOSE C1;
    -- return project manager as of today for current projects
    ELSE
      OPEN C1 (sysdate);
      FETCH C1 INTO l_return_value;
      CLOSE C1;
    END IF;

  END IF;

  PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID := l_return_value;
  RETURN l_return_value;

END;

FUNCTION GET_PROJECT_MANAGER_NAME
RETURN VARCHAR2
IS

CURSOR C1(c_person_id NUMBER)
IS
Select full_name
FROM per_all_people_f
WHERE PERSON_ID = c_person_id
AND trunc(SYSDATE) between trunc(effective_start_date) and trunc(effective_end_date);  -- Bug 3283351

l_return_value  VARCHAR2(250);
BEGIN

  IF PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID is not null THEN

    OPEN C1(PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID);
    FETCH C1 INTO l_return_value;
    CLOSE C1;
  END IF;

 RETURN l_return_value;
END;

FUNCTION GET_PROJECT_MANAGER_NAME( p_project_id  IN NUMBER)
RETURN VARCHAR2
IS

CURSOR C1 (c_as_of_date DATE) IS
Select ppf.full_name
FROM PA_PROJECT_PARTIES         PPP,
     --PA_PROJECT_ROLE_TYPES      PPRT, --bug 4004821
     PA_PROJECT_ROLE_TYPES_B      PPRT,
     per_all_people_f           PPF
WHERE
    PPP.PROJECT_ID                      = p_project_id
AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
AND ppp.resource_type_id                = 101             --Added this condition to improve performance. Bug:4752054
AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
AND trunc(c_as_of_date)  between trunc(PPP.start_date_active)
AND                         NVL(trunc(PPP.end_date_active),c_as_of_date)
AND ppf.person_id = ppp.resource_source_id
AND trunc(c_as_of_date) between trunc(PPF.effective_start_date) AND trunc(PPF.effective_end_date); -- Added for bug 3283351

l_return_value  VARCHAR2(250);
l_project_finish_date  DATE;
l_project_start_date DATE;

BEGIN

  l_project_finish_date := PA_PROJECT_DATES_UTILS.Get_Project_Finish_Date(p_project_id);

  -- return project manager as of project finish date for past projects
  IF l_project_finish_date < sysdate THEN
    OPEN C1 (l_project_finish_date);
    FETCH C1 INTO l_return_value;
    CLOSE C1;
  ELSE

    -- 4361712
    l_project_start_date := PA_PROJECT_DATES_UTILS.Get_Project_Start_Date(p_project_id);

    -- return project manager as of project start date for future projects
    IF l_project_start_date > sysdate THEN
      OPEN C1 (l_project_start_date);
      FETCH C1 INTO l_return_value;
      CLOSE C1;
    -- return project manager as of today for current projects
    ELSE
      OPEN C1 (sysdate);
      FETCH C1 INTO l_return_value;
      CLOSE C1;
    END IF;

  END IF;

  RETURN l_return_value;
END;

/* Added the following API for bug #2111806.
   This API will check if a Project Manager is available for the entire
   duration of a Project.
*/

PROCEDURE VALIDATE_MANAGER_DATE_RANGE( p_mode               IN VARCHAR2,
                                       p_project_id         IN NUMBER,
			       	       x_start_no_mgr_date OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                           	       x_end_no_mgr_date   OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                       x_error_occured     OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
l_error_occured        VARCHAR2(50);
l_proj_status		pa_projects_all.project_status_code%TYPE;
l_proj_type_class       pa_project_types_all.project_type_class_code%TYPE;
l_proj_type             pa_project_types_all.project_type%TYPE; -- Added for bug#5098966
l_proj_start_date	pa_projects_all.start_date%TYPE;
l_proj_end_date         pa_projects_all.completion_date%TYPE;
l_person_id		pa_project_players.person_id%TYPE;
l_party_id              pa_project_parties.project_party_id%TYPE;
l_start_date		pa_project_players.start_date_active%TYPE;
l_end_date		pa_project_players.end_date_active%TYPE;
l_end_date_old          pa_project_players.end_date_active%TYPE;

/* Changing the query to base table to improve performance instead of pa_projects_v view. Bug no. 4940945*/
CURSOR c_prj IS
select ps.project_system_status_code
      ,type.project_type_class_code
      ,proj.project_type  -- Added for bug#5098966
      ,proj.start_date
      ,proj.completion_date
 from pa_projects_all proj
     ,pa_project_statuses ps
     ,pa_project_types type
where proj.project_status_code = ps.project_status_code
  and proj.project_type = type.project_type
  and proj.project_id = p_project_id
  and ps.STATUS_TYPE = 'PROJECT';

/* changes end for Bug 4940945 */

/* commented by sunkalya for fix bug#4636169
CURSOR c_project_players IS
select person_id
      ,start_date_active
      ,end_date_active
  from pa_project_players
 where project_id = p_project_id
   and project_role_type='PROJECT MANAGER'
order by start_date_active;

CURSOR c_project_parties IS
select project_party_id
      ,start_date_active
      ,end_date_active
 from pa_project_parties
where project_id = p_project_id
  and project_role_id = 1
order by start_date_active;
*/ --End of commenting by sunkalya for bug#4636169

BEGIN

  pa_debug.set_err_stack('Validate Manager Date Range');

  IF p_project_id IS NOT NULL THEN
     OPEN c_prj;
     -- Added l_proj_type for bug#5098966
     FETCH c_prj INTO l_proj_status, l_proj_type_class, l_proj_type, l_proj_start_date, l_proj_end_date;
     CLOSE c_prj;
  END IF;

-- begin changes for bug 4636169 by sunkalya
DECLARE
		CURSOR c_project_players IS
		select person_id
		      ,start_date_active
		      ,end_date_active
		  from pa_project_players
		 where project_id = p_project_id
		   and project_role_type='PROJECT MANAGER'
		   AND NOT (
		   exists(
		   SELECT 'y' FROM dual WHERE start_date_active > l_proj_end_date
		   )
		   OR
		   exists(
		   SELECT 'y' FROM dual WHERE end_date_active < l_proj_start_date
		   )
		   )
		order by start_date_active;

		CURSOR c_project_parties IS
		select project_party_id
		      ,start_date_active
		      ,end_date_active
		 from pa_project_parties
		where project_id = p_project_id
		  and project_role_id = 1
		  AND NOT (
		  exists(
		   SELECT 'y' FROM dual WHERE start_date_active > l_proj_end_date
		   )
		   OR
		   exists(
		   SELECT 'y' FROM dual WHERE end_date_active < l_proj_start_date
		   )
		   )
		order by start_date_active;

BEGIN  --This begin added for Bug#4636169 by sunkalya

  /* Do the checking for the Manager date only for an Approved Contract Type project. */
  IF (nvl(l_proj_type_class,'NONE') = 'CONTRACT' AND
      nvl(l_proj_status,'UNAPPROVED') = 'APPROVED') AND
      nvl(l_proj_type, 'AWARD_PROJECT') <> 'AWARD_PROJECT' THEN -- Added for bug#5098966


         OPEN c_project_players;
	 OPEN c_project_parties;
	 LOOP
		 IF p_mode = 'AMG' THEN
		     IF P_DEBUG_MODE = 'Y' THEN
			 pa_debug.write('VALIDATE_MANAGER_DATE_RANGE: ','Mode is AMG',3 );
	             END IF;
		     FETCH c_project_players INTO l_person_id,l_start_date,l_end_date;
		 ELSIF p_mode = 'SS' THEN
		     IF P_DEBUG_MODE = 'Y' THEN
			 pa_debug.write('VALIDATE_MANAGER_DATE_RANGE: ','Mode is SS',3 );
	             END IF;
		     FETCH c_project_parties INTO l_party_id,l_start_date,l_end_date;
		 END IF;

		  IF (l_proj_end_date is null) THEN

		     IF (( p_mode = 'AMG' and c_project_players%NOTFOUND and l_end_date_old is not null) OR
		        ( p_mode = 'SS' and c_project_parties%NOTFOUND and l_end_date_old is not null))THEN
			   x_start_no_mgr_date := l_end_date_old+1;
			   x_end_no_mgr_date   := l_proj_end_date;
			   l_error_occured := 'PA_PR_NO_MGR_DATE_RANGE';
		       EXIT;
		     END IF;
		     IF (l_start_date > l_proj_start_date) THEN
			  x_start_no_mgr_date := l_proj_start_date;
			  x_end_no_mgr_date   := l_start_date-1;
			  l_error_occured := 'PA_PR_NO_MGR_DATE_RANGE';
		       EXIT;
		     ELSE
			IF (l_end_date is null) THEN
			    EXIT ;
			ELSE
			    l_proj_start_date :=l_end_date + 1;
			    l_end_date_old :=l_end_date;
			END IF;
		     END IF;
		  END IF;

		  IF (l_proj_end_date is not null) THEN
		    IF (( p_mode = 'AMG' and c_project_players%NOTFOUND and l_end_date_old <> l_proj_end_date) OR
		        ( p_mode = 'SS' and c_project_parties%NOTFOUND and l_end_date_old <> l_proj_end_date)) THEN
		      x_start_no_mgr_date := l_end_date_old+1;
		      x_end_no_mgr_date   := l_proj_end_date;
		      l_error_occured := 'PA_PR_NO_MGR_DATE_RANGE';
		       EXIT;
		    END IF;
		    IF (l_start_date > l_proj_start_date) THEN
		      x_start_no_mgr_date := l_proj_start_date;
		      x_end_no_mgr_date   := l_start_date-1;
		      l_error_occured := 'PA_PR_NO_MGR_DATE_RANGE';
		      EXIT;
		    ELSE
		       IF (l_end_date is null or l_end_date >=l_proj_end_date) THEN
			 EXIT ;
		       ELSE
			 IF (l_end_date <l_proj_end_date) THEN
			   l_proj_start_date :=l_end_date + 1;
			   l_end_date_old := l_end_date;
			 END IF;
		       END IF;
		    END IF;
		  END IF;
	  END LOOP;

	  CLOSE c_project_players;
          CLOSE c_project_parties;
  END IF;

  IF P_DEBUG_MODE = 'Y' THEN
     pa_debug.write('VALIDATE_MANAGER_DATE_RANGE: ','l_error_occured - '||l_error_occured,3 );
  END IF;
  x_error_occured := l_error_occured;
  pa_debug.reset_err_stack;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    x_error_occured := 'N';
WHEN OTHERS THEN
    x_error_occured := 'Y';
        IF c_project_players%ISOPEN THEN
           CLOSE c_project_players;
        END IF;
        IF c_project_parties%ISOPEN THEN
           CLOSE c_project_parties;
        END IF;
        fnd_msg_pub.add_exc_msg(p_pkg_name => 'VALIDATE_MANAGER_DATE_RANGE',
                          p_procedure_name => pa_debug.g_err_stack,
                          p_error_text     => SUBSTRB(SQLERRM,1,240));
    RAISE;

    END; --This END is for the BEGIN added by sunkalya for Bug#4636169
END VALIDATE_MANAGER_DATE_RANGE;


/* Added the following API for bug #2111806.
   This API will check if atleast one Project Manager exists
   for the Project if it is an Approved Contract Project.
*/

PROCEDURE VALIDATE_ONE_MANAGER_EXISTS( p_project_id         IN NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                       x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                       x_msg_data          OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
/* Changing the query to base tables instaed of pa_projects_v view to improve perfromance. Bug 4940945 */
  CURSOR c_prj IS
  select ps.project_system_status_code
        ,type.project_type_class_code
    from pa_projects_all proj
        ,pa_project_statuses ps
        ,pa_project_types type
where proj.project_status_code = ps.project_status_code
  and proj.project_type=type.project_type
  and proj.project_id = p_project_id
  and ps.STATUS_TYPE ='PROJECT';
 /* changes end for Bug 4940945 */

  CURSOR c_prj_count IS
  select count(*)
    from pa_project_parties
   where project_id = p_project_id
     and project_role_id = 1;

  l_proj_status		  pa_projects_all.project_status_code%TYPE;
  l_proj_type_class       pa_project_types_all.project_type_class_code%TYPE;
  l_prj_mgr_count         NUMBER := 0;
  l_start_no_mgr_date     DATE;
  l_end_no_mgr_date       DATE;


BEGIN

  pa_debug.set_err_stack('VALIDATE_ONE_MANAGER_EXISTS');
  x_msg_count := 0;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Do the checking for the Manager date only for an Approved Contract Type project. */
  IF p_project_id IS NOT NULL THEN
  OPEN  c_prj;
  FETCH c_prj INTO l_proj_status, l_proj_type_class;
  CLOSE c_prj;
  END IF;

  /* The check has to be done only for an Approved Contract Type project. */
  IF (nvl(l_proj_type_class,'NONE') = 'CONTRACT' AND
      nvl(l_proj_status,'UNAPPROVED') = 'APPROVED') THEN
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write('VALIDATE_ONE_MANAGER_EXISTS: ','This is an Approved Contract Project',3 );
      END IF;
     OPEN c_prj_count;
    FETCH c_prj_count INTO l_prj_mgr_count;
    CLOSE c_prj_count;
       IF l_prj_mgr_count = 0 THEN
    	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     pa_utils.add_message
	      ( p_app_short_name   => 'PA'
	       ,p_msg_name         => 'PA_PR_INSUF_PROJ_MGR'
	      );
	     x_return_status := FND_API.G_RET_STS_ERROR;
	     x_msg_count     := 1;
	     x_msg_data      := 'PA_PR_INSUF_PROJ_MGR';
	  END IF;
       END IF;
  END IF;
  pa_debug.reset_err_stack;

EXCEPTION

WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
         ( p_pkg_name       => 'PA_PROJECT_PARTIES_UTILS.VALIDATE_ONE_MANAGER_EXISTS'
          ,p_procedure_name => pa_debug.G_Err_Stack );
      IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write('VALIDATE_ONE_MANAGER_EXISTS: ', SQLERRM, 3);
         pa_debug.write('VALIDATE_ONE_MANAGER_EXISTS: ', pa_debug.G_Err_Stack, 3);
      END IF;
      pa_debug.reset_err_stack;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END VALIDATE_ONE_MANAGER_EXISTS;

--  API name             : get_current_project_manager
--  Type                 : Public
--  Pre-reqs             : None.
--  Parameters           :
--  p_project_id         IN NUMBER
--  Return               : NUMBER
--  Details: This function is created so as to return the project manager who is
--  active on the project as on the sysdate.
--  History
--
--   23-May-2005        adarora      - Created
--
FUNCTION GET_CURRENT_PROJECT_MANAGER  ( p_project_id  IN NUMBER)
RETURN NUMBER
IS

CURSOR C1 (c_as_of_date DATE) IS
Select PPP.RESOURCE_SOURCE_ID
FROM PA_PROJECT_PARTIES         PPP  ,
     --PA_PROJECT_ROLE_TYPES      PPRT --bug 4004821
     PA_PROJECT_ROLE_TYPES_B      PPRT
WHERE
    PPP.PROJECT_ID                      = p_project_id
AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
AND ppp.resource_type_id                = 101             --Added this condition to improve performance. Bug:4752054
AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
AND trunc(c_as_of_date)  between trunc(PPP.start_date_active)
AND                         NVL(trunc(PPP.end_date_active),c_as_of_date);

l_return_value    NUMBER(10);
BEGIN

  PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID := null;

    OPEN C1 (sysdate);
    FETCH C1 INTO l_return_value;
    CLOSE C1;


  PA_PROJECT_PARTIES_UTILS.G_PROJECT_MANAGER_ID := l_return_value;
  RETURN l_return_value;

END GET_CURRENT_PROJECT_MANAGER;

-- API name             : GET_CURRENT_PROJ_MANAGER_NAME
-- Type                 : Public
-- Pre-reqs             : None.
-- Parameters           :
--  p_project_id         IN NUMBER
--  Return               : VARCHAR2
--  Details: This function is created so as to return the project manager name who is
--  active on the project as on the sysdate.
--  History
--
--   23-May-2005        adarora      - Created
--

FUNCTION GET_CURRENT_PROJ_MANAGER_NAME( p_project_id  IN NUMBER)
RETURN VARCHAR2
IS

CURSOR C1 (c_as_of_date DATE) IS
Select ppf.full_name
FROM PA_PROJECT_PARTIES         PPP,
     --PA_PROJECT_ROLE_TYPES      PPRT, --bug 4004821
     PA_PROJECT_ROLE_TYPES_B      PPRT,
     per_all_people_f           PPF
WHERE
    PPP.PROJECT_ID                      = p_project_id
AND PPP.PROJECT_ROLE_ID                 = PPRT.PROJECT_ROLE_ID
AND ppp.resource_type_id                = 101             --Added this condition to improve performance. Bug:4752054
AND PPRT.PROJECT_ROLE_TYPE              ='PROJECT MANAGER'
AND trunc(c_as_of_date)  between trunc(PPP.start_date_active)
AND                         NVL(trunc(PPP.end_date_active),c_as_of_date)
AND ppf.person_id = ppp.resource_source_id
AND trunc(c_as_of_date) between trunc(PPF.effective_start_date) AND trunc(PPF.effective_end_date); -- Added for bug 3283351

l_return_value  VARCHAR2(250);

BEGIN



    OPEN C1 (sysdate);
    FETCH C1 INTO l_return_value;
    CLOSE C1;

  RETURN l_return_value;
END GET_CURRENT_PROJ_MANAGER_NAME;

END PA_PROJECT_PARTIES_UTILS;


/

  GRANT EXECUTE ON "APPS"."PA_PROJECT_PARTIES_UTILS" TO "EBSBI";
