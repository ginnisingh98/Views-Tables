--------------------------------------------------------
--  DDL for Package Body PA_COMPETENCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COMPETENCE_PVT" AS
-- $Header: PACOMPVB.pls 120.1 2005/08/19 16:20:26 mwasowic noship $

--
--  PROCEDURE
--              Add_Competence_Element
--  PURPOSE
--              This procedure creates the competence elements for
--		a project role or an open assignment
--  HISTORY
--   24-JUL-2000      R. Krishnamurthy       Created
--
PROCEDURE Add_competence_element
	( p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
	p_object_id	    IN PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
	p_project_id        IN pa_project_assignments.project_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_id	    IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
	p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
	p_mandatory_flag    IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
	p_commit            IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_init_msg_list	    IN VARCHAR2 := FND_API.G_FALSE,
	x_element_rowid	    OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
	x_element_id        OUT NOCOPY per_competence_elements.competence_element_id%TYPE, --File.Sql.39 bug 4440895
	x_return_status	    OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

	 l_data	                 VARCHAR2(500);
	 l_msg_data              VARCHAR2(500);
	 l_msg_index_out         NUMBER := 0;
	 l_project_id            NUMBER := 0;
	 l_return_status         VARCHAR2(30);
	 l_error_message_code    VARCHAR2(30);
	 l_mandatory_flag        VARCHAR2(1);
	 l_bg_id                 NUMBER := 0;
	 l_element_id            NUMBER := 0;
	 l_role_id               NUMBER := 0;
	 l_object_version_number NUMBER := 0;
	 l_object_id_index       binary_integer;
	 l_first_assignment_id   NUMBER;

	 CURSOR l_bg_csr IS
		 SELECT business_group_id
			 FROM   per_competences
			 WHERE competence_id = p_competence_id;

	 CURSOR l_rowid_csr IS
	 	 SELECT rowid
	 		 FROM per_competence_elements
	 		 WHERE competence_element_id = l_element_id;

BEGIN
	 pa_debug.set_err_stack ('pa_competence_pvt.add_competence_element');
	 SAVEPOINT COMPETENCE_PVT_ADD_COMP_ELE;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Initialize the message stack if necessary
	 IF p_init_msg_list = FND_API.G_TRUE  THEN
			fnd_msg_pub.initialize;
	 END IF;

         -- Angie modified this to fix bug 1676891
	 -- get first index of p_object_id
 	 l_object_id_index := p_object_id.first;

	 IF p_object_name = 'PROJECT_ROLE'   THEN
  		        -- Check whether the competency can be assigned to the role
			pa_role_utils.validate_role_competency
				(p_competence_id => p_competence_id
				,x_return_status => l_return_status
				,x_error_message_code => l_error_message_code );

			Check_Error (p_return_status => l_return_status,
				p_error_message_code => l_error_message_code );
	 END IF;

	 -- If object = ASGMT call asgmt validations
	 IF p_object_name = 'OPEN_ASSIGNMENT'  THEN

			-- if p_project_id has not been passed, get project_id value
			IF p_project_id = NULL OR p_project_id = FND_API.G_MISS_NUM THEN
				 -- Get the assignment details
				 --dbms_output.put_line('p_project_id = NULL in PUB, first_index: '|| l_object_id_index);

				 l_first_assignment_id := p_object_id(l_object_id_index).assignment_id;
		     --dbms_output.put_line('p_project_id = NULL in PUB, l_first_assignment_id: '|| l_first_assignment_id);
				 BEGIN
						SELECT project_id
							INTO l_project_id
							FROM   pa_project_assignments
							WHERE  assignment_id = l_first_assignment_id;
				 EXCEPTION
						WHEN NO_DATA_FOUND THEN
							Check_Error (p_return_status => FND_API.G_RET_STS_ERROR
							 ,p_error_message_code => 'PA_INVALID_ASGMT_ID');
				 END;

			-- if p_project_id has been passed
			ELSE
				 l_project_id := p_project_id;
			END IF;

			-- dbms_output.put_line('before  calling pa_assignment_utils.validate_asgmt_competency');
/* The IF condition is added for bug 2361959 */

                   IF l_project_id IS NOT NULL THEN

			pa_assignment_utils.validate_asgmt_competency
				(p_project_id => l_project_id
				,p_assignment_id => l_first_assignment_id
				,p_competence_id => p_competence_id
				,x_return_status => l_return_status
				,x_error_message_code => l_error_message_code );
			-- dbms_output.put_line('after calling pa_assignment_utils.validate_asgmt_competency');

                      Check_Error (p_return_status => l_return_status,
				p_error_message_code => l_error_message_code );

                 END IF;   /*Project ID NULL */
	 END IF;

	 IF pa_hr_competence_utils.check_competence_exists
		 (p_object_name, l_first_assignment_id, p_competence_id) = 'Y' THEN
			Check_Error ( p_return_status => FND_API.G_RET_STS_ERROR
				,p_error_message_code => 'PA_COMPETENCE_ELEMENT_EXISTS');
	 END IF;
	 --dbms_output.put_line('after calling pa_hr_competence_utils.check_competence_exists');

	 -- If there are errors, do not proceed to insert the data
	 IF g_noof_errors > 0 THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			pa_debug.reset_err_stack;
			RETURN;
	 END IF;

	 -- If validate only = 'Y' then return at this point.
	 IF p_validate_only = 'Y' THEN
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			pa_debug.reset_err_stack;
			RETURN;
	 END IF;

	 -- Decode default values to null
	 l_mandatory_flag := p_mandatory_flag;
	 IF (p_mandatory_flag IS NULL or
		 p_mandatory_flag = FND_API.G_MISS_CHAR)  THEN
			l_mandatory_flag := 'N' ;
	 END IF;

	 --  If no errors and validate only = 'N' then
	 --  call the table handler to create the competency
	 --  and pass only relevant values
	 -- We need the business group id of the competency
	 -- Hence fetch the same from the competences table
	 OPEN l_bg_csr;
	 FETCH l_bg_csr INTO l_bg_id;
	 CLOSE l_bg_csr;

	 -- loop for all the object_id to create competence_element
         FOR I in 1..p_object_id.count LOOP
			-- Now create the competency
			l_element_id := NULL;

			hr_competence_element_api.create_competence_element
				(
				p_competence_element_id        => l_element_id,
				p_object_version_number        => l_object_version_number,
				p_type                         => p_object_name,
				p_business_group_id            => l_bg_id,
				p_enterprise_id                => Null,
				p_competence_id                => p_competence_id,
			 	p_proficiency_level_id         => p_rating_level_id,
			 	p_high_proficiency_level_id    => null,
			 	p_weighting_level_id           => null,
			 	p_rating_level_id              => null,
				p_person_id                    => null,
			 	p_job_id                       => null,
			 	p_valid_grade_id               => null,
			 	p_position_id                  => null,
			 	p_organization_id              => null,
			 	p_parent_competence_element_id => null,
			 	p_activity_version_id          => null,
			 	p_assessment_id                => null,
			 	p_assessment_type_id           => null,
			 	p_mandatory                    => l_mandatory_flag,
			 	p_effective_date_from          => trunc(sysdate),
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
			 	p_object_id                    => p_object_id(l_object_id_index).assignment_id,
				p_object_name                  => p_object_name
				);

				-- get next object_id_index
				l_object_id_index := p_object_id.next(l_object_id_index);

	 END LOOP;

	 IF l_element_id IS NOT NULL THEN
			OPEN  l_rowid_csr;
			FETCH l_rowid_csr INTO x_element_rowid;
			CLOSE l_rowid_csr;
	 END IF;
	 x_element_id := l_element_id; /* added for bug 2084645 */
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 pa_debug.reset_err_stack;

EXCEPTION
	 WHEN OTHERS THEN
		 IF p_commit = FND_API.G_TRUE THEN
		 ROLLBACK TO COMPETENCE_PVT_ADD_COMP_ELE;
		 END IF;
		 x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
		 RAISE;
END Add_Competence_Element ;


PROCEDURE Update_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_mandatory_flag  IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
 x_return_status   OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_effective_date_from DATE;
l_return_status       VARCHAR2(30);
l_object_version_number NUMBER ;
l_error_message_code  VARCHAR2(30);
l_mandatory_flag      VARCHAR2(1);

BEGIN
     pa_debug.set_err_stack ('pa_competence_pvt.update_competence_element');
     SAVEPOINT COMPETENCE_PVT_UPD_COMP_ELE;
    -- Initialize the message stack if necessary
     IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check if the combination exists. If it does not, then
    -- should not proceed with the update
     IF pa_hr_competence_utils.check_competence_exists
	(p_object_name,p_object_id,p_competence_id) = 'N' THEN
       Check_Error (p_return_status => FND_API.G_RET_STS_ERROR
                   ,p_error_message_code =>'PA_COMPETENCE_ELE_NOT_EXISTS');
     END IF;
      -- Validate that the competence element id pertains to the
      -- given object name , id and competence id combination
      -- This is to ensure that we are updating the right record
      -- Call the check element id api
       Check_Element_id
        (p_object_name   => p_object_name,
         p_object_id	 => p_object_id,
         p_competence_id => p_competence_id,
         p_element_id	 => p_element_id,
         x_effective_date_from => l_effective_date_from,
         x_return_status  => l_return_status ,
	 x_error_message_code => l_error_message_code );
         IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            Check_Error (p_return_status => l_return_status
                        ,p_error_message_code => l_error_message_code );
         END IF;
     -- If there are errors, do not proceed to update the data
       -- Check whether the object version number is correct
	Check_Object_version_number
                      (p_element_id => p_element_id,
		       p_object_version_number => p_object_version_number,
		       x_return_status => l_return_status,
		       x_error_message_code => l_error_message_code );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         Check_Error (p_return_status => l_return_status
                     ,p_error_message_code => l_error_message_code );
      END IF;

      IF g_noof_errors > 0 THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 pa_debug.reset_err_stack;
         RETURN;
      END IF;
     -- If validate only = 'Y' then return at this point.
     IF p_validate_only = 'Y' THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	pa_debug.reset_err_stack;
        RETURN;
     END IF;
      -- Decode default values to null
     l_mandatory_flag := p_mandatory_flag;
     IF (p_mandatory_flag IS NULL or
        p_mandatory_flag = FND_API.G_MISS_CHAR)  THEN
	l_mandatory_flag := 'N' ;
     END IF;

  --  If no errors and validate only = 'N' then
  --  call the table handler to update the competency
  --  and pass only relevant values
      l_object_version_number := p_object_version_number ;
  --  The HR api expects the effective_date as an input
  --  Since we do not have a need to update the effective date
  --  we will use the effective date fetched earlier for this purpose

hr_competence_element_api.update_competence_element
  (
  p_competence_element_id        => p_element_id,
  p_object_version_number        => l_object_version_number,
  p_proficiency_level_id         => p_rating_level_id,
  p_mandatory           	 => l_mandatory_flag,
  p_effective_date		 => l_effective_date_from );

  x_object_version_number := l_object_version_number;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_debug.reset_err_stack;
EXCEPTION
 WHEN OTHERS THEN
  IF p_commit = FND_API.G_TRUE THEN
     ROLLBACK TO COMPETENCE_PVT_UPD_COMP_ELE;
  END IF;
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Update_Competence_element;

PROCEDURE delete_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_FALSE,
 p_object_version_number IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

l_return_status       VARCHAR2(30);
l_effective_date_from DATE;
l_object_version_number NUMBER ;
l_error_message_code  VARCHAR2(30);

BEGIN
     pa_debug.set_err_stack ('pa_competence_pvt.delete_competence_element');
     SAVEPOINT COMPETENCE_PVT_DEL_COMP_ELE;
    -- Initialize the message stack if necessary
     IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
     END IF;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check if the combination exists. If it does not, then
    -- should not proceed with the delete
     IF pa_hr_competence_utils.check_competence_exists
	(p_object_name,p_object_id,p_competence_id) = 'N' THEN
       Check_Error (p_return_status => FND_API.G_RET_STS_ERROR
                   ,p_error_message_code =>'PA_COMPETENCE_ELE_NOT_EXISTS');
     END IF;
      -- Validate that the competence element id pertains to the
      -- given object name , id and competence id combination
      -- This is to ensure that we are deleting the right record
     Check_Element_id
        (p_object_name   => p_object_name,
         p_object_id	 => p_object_id,
         p_competence_id => p_competence_id,
         p_element_id	 => p_element_id,
         x_effective_date_from => l_effective_date_from,
         x_return_status  => l_return_status ,
	 x_error_message_code => l_error_message_code);
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           Check_Error (p_return_status => l_return_status
                       ,p_error_message_code => l_error_message_code );
     END IF;

       -- Check whether the object version number is correct
      Check_Object_version_number
                      (p_element_id => p_element_id,
		       p_object_version_number => p_object_version_number,
		       x_return_status => l_return_status,
		       x_error_message_code => l_error_message_code );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         Check_Error (p_return_status => l_return_status
                     ,p_error_message_code => l_error_message_code );
      END IF;

     -- If there are errors, do not proceed to delete the data
     IF g_noof_errors > 0 THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	pa_debug.reset_err_stack;
        RETURN;
     END IF;
     -- If validate only = 'Y' then return at this point.
     IF p_validate_only = 'Y' THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	pa_debug.reset_err_stack;
        RETURN;
     END IF;
     hr_competence_element_api.delete_competence_element
    (p_competence_element_id  => p_element_id,
     p_object_version_number  => p_object_version_number );

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      pa_debug.reset_err_stack;

EXCEPTION
 WHEN OTHERS THEN
  IF p_commit = FND_API.G_TRUE THEN
     ROLLBACK TO COMPETENCE_PVT_DEL_COMP_ELE;
  END IF;
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Delete_Competence_element;

PROCEDURE Check_Element_id
(p_object_name   IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
p_object_id	 IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_element_id	 IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
x_effective_date_from OUT NOCOPY per_competence_elements.effective_date_from%TYPE , --File.Sql.39 bug 4440895
x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

CURSOR l_check_element_csr IS
SELECT object_name,
       object_id,
       competence_id,
       effective_date_from
FROM per_competence_elements
WHERE competence_element_id = p_element_id;
l_check_element_rec l_check_element_csr%ROWTYPE;
BEGIN
      pa_debug.set_err_stack ('pa_competence_pvt.check_element_id');
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
      x_effective_date_from := l_check_element_rec.effective_date_from;
      CLOSE l_check_element_csr;
      pa_debug.reset_err_stack;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Check_Element_id ;

PROCEDURE Check_Error (p_return_status  IN VARCHAR2,
	               p_error_message_code IN VARCHAR2) IS
BEGIN
    pa_debug.set_err_stack ('pa_competence_pvt.check_error');
    IF p_return_status = FND_API.G_RET_STS_ERROR THEN
       g_noof_errors := g_noof_errors + 1;
       pa_utils.add_message (p_app_short_name  => 'PA',
       		             p_msg_name	   => p_error_message_code);
    END IF;
    pa_debug.reset_err_stack;
EXCEPTION
 WHEN OTHERS THEN
  RAISE;
END check_error;

PROCEDURE Check_Object_version_number
   (p_element_id  IN per_competence_elements.competence_element_id%TYPE,
    p_object_version_number IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_error_message_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

CURSOR l_get_obj_vers_csr IS
SELECT object_version_number
FROM per_competence_elements
WHERE competence_element_id = p_element_id;
l_obj_version_number NUMBER := 0;

BEGIN
   pa_debug.set_err_stack ('pa_competence_pvt.check_object_version_number');
   OPEN l_get_obj_vers_csr;
   FETCH l_get_obj_vers_csr INTO l_obj_version_number;
   IF l_obj_version_number <> p_object_version_number THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_COMP_OBJ_VERSION_INVALID';
   END IF;
   CLOSE l_get_obj_vers_csr;
   pa_debug.reset_err_stack;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END Check_Object_Version_Number ;

end pa_competence_pvt ;

/
