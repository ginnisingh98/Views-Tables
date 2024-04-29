--------------------------------------------------------
--  DDL for Package Body PA_COMPETENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COMPETENCE_PUB" AS
-- $Header: PACOMPPB.pls 120.4 2005/08/23 04:31:18 sunkalya noship $

--
--  PROCEDURE
--              Add_Competence_Element
--  PURPOSE
--              This procedure creates the competence elements for
--		a project role or an open assignment
--  HISTORY
--   11-JUL-2000      R. Krishnamurthy       Created
--

PROCEDURE Add_competence_element
	( p_object_name      IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
	p_object_id	         IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_id	     IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
	p_competence_alias   IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
	p_competence_name    IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
	p_rating_level_id    IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
	p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
	p_mandatory_flag     IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
	p_init_msg_list	     IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_commit	           IN VARCHAR2 := FND_API.G_MISS_CHAR,
	p_validate_only	     IN VARCHAR2 := FND_API.G_MISS_CHAR,
	x_element_rowid	     OUT NOCOPY ROWID, --File.Sql.39 bug 4440895
	x_element_id	       OUT NOCOPY per_competence_elements.competence_element_id%TYPE, --File.Sql.39 bug 4440895
	x_return_status	     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count	         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data	         OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

	 l_data	       VARCHAR2(500);
	 l_msg_data     VARCHAR2(500);
	 l_msg_index_out NUMBER := 0;
	 l_return_status  VARCHAR2(30);
	 l_error_message_code VARCHAR2(30);
	 l_competence_id NUMBER := 0;
	 l_rating_level_id NUMBER := 0;
	 l_mandatory_flag VARCHAR2(1);
	 l_project_id    NUMBER := 0;
	 l_role_id         NUMBER := 0;
	 l_object_id   PA_ASSIGNMENTS_PUB.assignment_id_tbl_type;

BEGIN
	 pa_debug.init_err_stack ('pa_competence_pub.add_competence_element');
	 SAVEPOINT COMPETENCE_PUB_ADD_COMP_ELE;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Initialize the PL/SQL message stack
	 pa_competence_pvt.g_noof_errors  := 0;
	 IF p_init_msg_list = FND_API.G_TRUE  THEN
			fnd_msg_pub.initialize;
	 END IF;

	 -- Do the standard public api checks
	 standard_pub_checks
		 (p_object_name     => p_object_name,
		 p_object_id	      => p_object_id,
		 p_competence_id   => p_competence_id,
		 p_competence_alias => p_competence_alias,
		 p_competence_name  => p_competence_name,
		 p_rating_level_id  => p_rating_level_id,
		 p_rating_level_value  => p_rating_level_value,
		 p_operation        => 'INSERT',
		 x_return_status    => l_return_status,
		 x_competence_id    => l_competence_id,
		 x_rating_level_id  => l_rating_level_id );
	 -- If there are errors at this stage, there is no point
	 -- in proceeding further since the competence id or rating level
	 -- values are invalid

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			x_return_status:= FND_API.G_RET_STS_ERROR;
			IF pa_competence_pvt.g_noof_errors = 1 THEN
				 pa_interface_utils_pub.get_messages
					 (p_encoded        => FND_API.G_TRUE,
					 p_msg_index      => 1,
					 p_msg_count      => x_msg_count ,
					 p_msg_data       => l_msg_data ,
					 p_data           => l_data,
					 p_msg_index_out  => l_msg_index_out );
				 x_msg_data := l_data;
				 x_msg_count := pa_competence_pvt.g_noof_errors;
			ELSE
				 x_msg_count := pa_competence_pvt.g_noof_errors;
			END IF;
			pa_debug.reset_err_stack;
			RETURN;
	 END IF;

	 IF p_object_name = 'PROJECT_ROLE'   THEN
			-- Check  whether it is a valid role
			pa_role_utils.Check_Role_Name_Or_Id
				( p_role_id       => p_object_id
				,p_role_name     => NULL
				,p_check_id_flag => pa_startup.g_check_id_flag
				,x_role_id       => l_role_id
				,x_return_status => l_return_status
				,x_error_message_code => l_error_message_code );

			pa_competence_pvt.Check_Error
				(p_return_status => l_return_status,
				p_error_message_code => l_error_message_code );
	 END IF;

	 l_object_id(1).assignment_id := p_object_id;

	 pa_competence_pvt.Add_competence_element
		 ( p_object_name         => p_object_name,
		 p_object_id             => l_object_id,
		 p_competence_id         => l_competence_id,
		 p_rating_level_id       => l_rating_level_id,
		 p_mandatory_flag        => p_mandatory_flag,
		 p_commit                => p_commit,
		 p_validate_only         => p_validate_only,
		 x_element_rowid         => x_element_rowid,
		 x_element_id            => x_element_id,
		 x_return_status         => l_return_status );

	 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
			x_return_status:= FND_API.G_RET_STS_ERROR;

			IF pa_competence_pvt.g_noof_errors = 1 THEN
				 pa_interface_utils_pub.get_messages
					 (p_encoded        => FND_API.G_TRUE,
					 p_msg_index      => 1,
					 p_msg_count      => x_msg_count ,
					 p_msg_data       => l_msg_data ,
					 p_data           => l_data,
					 p_msg_index_out  => l_msg_index_out );
				 x_msg_data := l_data;
				 x_msg_count := pa_competence_pvt.g_noof_errors;
			ELSE
				 x_msg_count := pa_competence_pvt.g_noof_errors;
			END IF;

			pa_debug.reset_err_stack;
			RETURN;
	 ELSE
			x_return_status:= FND_API.G_RET_STS_SUCCESS;
	 END IF;

	 IF p_commit = FND_API.G_TRUE THEN
			COMMIT;
	 END IF;

EXCEPTION
	 WHEN OTHERS THEN

		 IF p_commit = FND_API.G_TRUE THEN
		 ROLLBACK TO COMPETENCE_PUB_ADD_COMP_ELE;
		 END IF;

		 fnd_msg_pub.add_exc_msg
			 (p_pkg_name => 'PA_COMPETENCE_PUB',
			 p_procedure_name => pa_debug.g_err_stack );

		 x_msg_count := 1;

		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => l_msg_data ,
					p_data           => l_data,
					p_msg_index_out  => l_msg_index_out );

				x_msg_data := l_data;
		 END IF;

		 x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

		 -- RESET the other OUT PARAMS also : 4537865

		 x_element_rowid := NULL ;
		 x_element_id := NULL ;

END Add_Competence_Element;


PROCEDURE Update_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_value IN per_rating_levels.step_value%TYPE := FND_API.G_MISS_NUM,
 p_mandatory_flag  IN per_competence_elements.mandatory%TYPE := FND_API.G_MISS_CHAR,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_object_version_number OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count	   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data	   OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

l_data	       VARCHAR2(500);
l_msg_data     VARCHAR2(500);
l_msg_index_out NUMBER := 0;
l_return_status  VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_competence_id NUMBER := 0;
l_rating_level_id NUMBER := 0;
l_mandatory_flag VARCHAR2(1);
l_err	VARCHAR2(2000);
l_element_id    NUMBER := null;
BEGIN
     pa_debug.init_err_stack ('pa_competence_pub.update_competence_element');
     SAVEPOINT COMPETENCE_PUB_UPD_COMP_ELE;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize the PL/SQL message stack
      pa_competence_pvt.g_noof_errors  := 0;
     IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
     END IF;

    IF p_element_id = FND_API.G_MISS_NUM THEN
       l_element_id := null;
    ELSE
       l_element_id := p_element_id;
    END IF;

    -- Do the standard public api checks
     standard_pub_checks
           (p_element_id      => l_element_id,
            p_object_name     => p_object_name,
            p_object_id	      => p_object_id,
            p_competence_id   => p_competence_id,
            p_competence_alias => p_competence_alias,
            p_competence_name  => p_competence_name,
            p_rating_level_id  => p_rating_level_id,
            p_rating_level_value  => p_rating_level_value,
            p_operation        => 'UPDATE',
            x_return_status    => l_return_status,
            x_competence_id    => l_competence_id,
            x_rating_level_id  => l_rating_level_id );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         IF pa_competence_pvt.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := pa_competence_pvt.g_noof_errors;
          ELSE
            x_msg_count := pa_competence_pvt.g_noof_errors;
          END IF;
          pa_debug.reset_err_stack;
          RETURN;
			END IF;

      pa_competence_pvt.update_competence_element
          ( p_object_name     => p_object_name
           ,p_object_id	      => p_object_id
           ,p_competence_id   => l_competence_id
           ,p_element_rowid   => p_element_rowid
           ,p_element_id      => p_element_id
           ,p_rating_level_id => l_rating_level_id
           ,p_mandatory_flag  => p_mandatory_flag
           ,p_commit	      => p_commit
           ,p_validate_only   => p_validate_only
           ,p_object_version_number => p_object_version_number
           ,x_object_version_number => x_object_version_number
           ,x_return_status    => l_return_status );

        x_return_status := l_return_status;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           x_return_status:= FND_API.G_RET_STS_ERROR;
           IF pa_competence_pvt.g_noof_errors = 1 THEN
                 pa_interface_utils_pub.get_messages
                        (p_encoded       => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => x_msg_count ,
                        p_msg_data       => l_msg_data ,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out );

                 x_msg_data := l_data;
                 x_msg_count := pa_competence_pvt.g_noof_errors;
           ELSE
                 x_msg_count := pa_competence_pvt.g_noof_errors;
           END IF;
           pa_debug.reset_err_stack;
           RETURN;
        ELSE
           x_return_status:= FND_API.G_RET_STS_SUCCESS;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
	   COMMIT;
        END IF;
        pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN

     l_err := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
	ROLLBACK TO COMPETENCE_PUB_UPD_COMP_ELE;
     END IF;

     fnd_msg_pub.add_exc_msg
        (p_pkg_name       => 'PA_COMPETENCE_PUB',
         p_procedure_name => pa_debug.g_err_stack );

     x_msg_count := 1;

     IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count ,
             p_msg_data       => l_msg_data ,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out );

             x_msg_data := l_data;
     END IF;

     x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

      -- RESET the other OUT PARAMS also : 4537865
     x_object_version_number := NULL ;

END update_competence_element ;

PROCEDURE delete_competence_element
(p_object_name     IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
 p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_id   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_competence_alias IN per_competences.competence_alias%TYPE := FND_API.G_MISS_CHAR,
 p_competence_name IN per_competences.name%TYPE := chr(0),
 p_element_rowid   IN ROWID := FND_API.G_MISS_CHAR,
 p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_init_msg_list   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only   IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count	  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data	  OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_data	       VARCHAR2(500);
l_msg_data     VARCHAR2(500);
l_msg_index_out NUMBER := 0;
l_return_status  VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_competence_id NUMBER := 0;
l_rating_level_id NUMBER := 0;
BEGIN
     pa_debug.init_err_stack ('pa_competence_pub.delete_competence_element');
     SAVEPOINT COMPETENCE_PUB_DEL_COMP_ELE;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize the PL/SQL message stack
      pa_competence_pvt.g_noof_errors  := 0;
     IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
     END IF;

    -- Do the standard public api checks
     standard_pub_checks
           (p_object_name     => p_object_name,
            p_object_id	      => p_object_id,
            p_competence_id   => p_competence_id,
            p_competence_alias => p_competence_alias,
            p_competence_name  => p_competence_name,
            p_operation        => 'DELETE',
            x_return_status    => l_return_status,
            x_competence_id    => l_competence_id,
            x_rating_level_id  => l_rating_level_id );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         IF pa_competence_pvt.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := pa_competence_pvt.g_noof_errors;
          ELSE
            x_msg_count := pa_competence_pvt.g_noof_errors;
          END IF;
          pa_debug.reset_err_stack;
          RETURN;
      END IF;
        -- Call the pvt delete competence element api now
          pa_competence_pvt.delete_competence_element
            (p_object_name     => p_object_name,
             p_object_id       => p_object_id,
             p_competence_id   => l_competence_id,
             p_element_rowid   => p_element_rowid,
             p_element_id      => p_element_id,
             p_commit	       => p_commit,
             p_validate_only   => p_validate_only,
             p_object_version_number => p_object_version_number,
             x_return_status   => l_return_status );
           x_return_status := l_return_status;

           IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF pa_competence_pvt.g_noof_errors = 1 THEN
                   pa_interface_utils_pub.get_messages
                       (p_encoded        => FND_API.G_TRUE,
                        p_msg_index      => 1,
                        p_msg_count      => x_msg_count ,
                        p_msg_data       => l_msg_data ,
                        p_data           => l_data,
                        p_msg_index_out  => l_msg_index_out );

                   x_msg_data := l_data;
                   x_msg_count := pa_competence_pvt.g_noof_errors;
             ELSE
                   x_msg_count := pa_competence_pvt.g_noof_errors;
             END IF;
             pa_debug.reset_err_stack;
             RETURN;
           ELSE
             x_return_status:= FND_API.G_RET_STS_SUCCESS;
           END IF;

           IF p_commit = FND_API.G_TRUE THEN
	      COMMIT;
           END IF;
           pa_debug.reset_err_stack;

EXCEPTION
   WHEN OTHERS THEN

     IF p_commit = FND_API.G_TRUE THEN
	   ROLLBACK TO COMPETENCE_PUB_DEL_COMP_ELE;
     END IF;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMPETENCE_PUB',
       p_procedure_name => pa_debug.g_err_stack );

      x_msg_count := 1;

      IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count ,
             p_msg_data       => l_msg_data ,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out );

             x_msg_data := l_data;
      END IF;

      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END delete_competence_element;

PROCEDURE standard_pub_checks
(
p_element_id       IN NUMBER := null,
p_object_name      IN per_competence_elements.object_name%TYPE := FND_API.G_MISS_CHAR,
p_object_id	   IN per_competence_elements.object_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id	   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id  IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_operation         IN  VARCHAR2,
x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_competence_id     OUT NOCOPY per_competences.competence_id%TYPE, --File.Sql.39 bug 4440895
x_rating_level_id   OUT NOCOPY per_competence_elements.rating_level_id%TYPE ) IS --File.Sql.39 bug 4440895

l_return_status  VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_in_competence_id NUMBER := 0;
-- angie changed back to original to fix bug 1569499
l_in_rating_level_id NUMBER := 0;
l_in_competence_alias VARCHAR2(30);
l_in_competence_name  VARCHAR2(240);
l_in_rating_level_value NUMBER := 0;
l_competence_id NUMBER := 0;
l_rating_level_id NUMBER := 0;
l_old_competence_id     NUMBER;
l_old_comp_name         VARCHAR2(240);
l_old_comp_alias        VARCHAR2(30);
l_exists                VARCHAR2(1);
BEGIN
   pa_debug.init_err_stack ('pa_competence_pub.standard_pub_checks');
   x_return_status:= FND_API.G_RET_STS_SUCCESS;
  -- Check whether the object name is one of the supported names
   IF (p_object_name = FND_API.G_MISS_CHAR) OR
      (p_object_name IS NULL) OR
      (p_object_name NOT IN ('PROJECT_ROLE','OPEN_ASSIGNMENT')) THEN
       pa_competence_pvt.Check_Error
                    (p_return_status => FND_API.G_RET_STS_ERROR,
		    p_error_message_code => 'PA_INVALID_COMP_OBJECT_NAME');
   END IF;

  -- Check whether competence alias or id is passed and call competence utils
  -- to validate
  l_in_competence_id := p_competence_id;
  IF l_in_competence_id = FND_API.G_MISS_NUM THEN
     l_in_competence_id := NULL;
	END IF;

  -- angie had commented out following three lines to fix bug 1569499 which was not
  -- correct. So uncommented out again.
  l_in_rating_level_id := p_rating_level_id;
  IF l_in_rating_level_id = FND_API.G_MISS_NUM THEN
     l_in_rating_level_id := NULL;
  END IF;

	l_in_competence_alias := p_competence_alias;
  IF l_in_competence_alias = FND_API.G_MISS_CHAR THEN
     l_in_competence_alias := NULL;
  END IF;
  l_in_competence_name := p_competence_name;
  IF l_in_competence_name = FND_API.G_MISS_CHAR THEN
     l_in_competence_name := NULL;
  END IF;
  l_in_rating_level_value := p_rating_level_value;
  IF l_in_rating_level_value = FND_API.G_MISS_NUM THEN
     l_in_rating_level_value := NULL;
  END IF;

  IF p_operation = 'INSERT' THEN
     IF l_in_competence_name is not null AND
        l_in_competence_alias is not null THEN
        BEGIN
          SELECT 'Y'
          INTO l_exists
          FROM per_competences
          WHERE name = l_in_competence_name
          AND competence_alias = l_in_competence_alias;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            pa_competence_pvt.Check_Error
                   (p_return_status => l_return_status,
                    p_error_message_code => 'PA_PRM_INVALID_ALIAS');

        END;
     END IF;
  END IF;

  IF p_operation = 'UPDATE' THEN
      IF p_element_id is not null THEN
         SELECT comp_ele.competence_id,
                comp.name,
                comp.competence_alias
         INTO l_old_competence_id,
              l_old_comp_name,
              l_old_comp_alias
         FROM per_competence_elements comp_ele,
              per_competences comp
         WHERE COMPETENCE_ELEMENT_ID = p_element_id
         AND comp.competence_id = comp_ele.competence_id;

         IF (nvl(l_in_competence_name,l_old_comp_name) <> l_old_comp_name) OR
            (nvl(l_in_competence_alias,l_old_comp_alias) <> l_old_comp_alias) OR
            (nvl(l_in_competence_id,l_old_competence_id) <> l_old_competence_id)
         THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            pa_competence_pvt.Check_Error
                   (p_return_status => l_return_status,
                    p_error_message_code => 'PA_PRM_CANNOT_UPD_COMP');
         END IF;
      END IF;
  END IF;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RETURN;
  END IF;

  pa_hr_competence_utils.Check_CompName_Or_Id
          ( p_competence_id      => l_in_competence_id
           ,p_competence_alias   => l_in_competence_alias
           ,p_competence_name    => l_in_competence_name
           ,p_check_id_flag      => pa_startup.g_check_id_flag
           ,x_competence_id      => l_competence_id
           ,x_return_status      => l_return_status
           ,x_error_msg_code     => l_error_message_code);

  pa_competence_pvt.Check_Error
                   (p_return_status => l_return_status,
		    p_error_message_code => l_error_message_code );

     --If the return status is invalid, we cannot proceed further
     -- All further validations require a competency id to be present

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.reset_err_stack;
        RETURN;
     END IF;

       x_competence_id := l_competence_id;

  -- Check whether rating level or value is passed and call competence utils
  -- to validate . Do this only if either rating level id or rating level
  -- value is passed. In certain cases (like in a public delete api)
  -- these values will not be passed , hence do not validate if both the
  -- values are not passed
      IF (l_in_rating_level_id IS NULL AND l_in_rating_level_value
	 IS NULL ) THEN
        pa_debug.reset_err_stack;
        RETURN;
			END IF;

      pa_hr_competence_utils.Check_Rating_Level_Or_Id
         ( p_competence_id    =>  l_competence_id
          ,p_rating_level_id   => l_in_rating_level_id
          ,p_rating_level      => l_in_rating_level_value
          ,p_check_id_flag     => pa_startup.g_check_id_flag
          ,x_rating_level_id   => l_rating_level_id
          ,x_return_status     => l_return_status
          ,x_error_msg_code    => l_error_message_code) ;
       pa_competence_pvt.Check_Error
                   (p_return_status => l_return_status,
		    p_error_message_code => l_error_message_code );
       IF pa_competence_pvt.g_noof_errors > 0 THEN
          x_return_status:= FND_API.G_RET_STS_ERROR;
       ELSE
          x_return_status:= FND_API.G_RET_STS_SUCCESS;
       END IF;
       pa_debug.reset_err_stack;
       x_rating_level_id := l_rating_level_id;
EXCEPTION
 WHEN OTHERS THEN
  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

  -- RESET the other OUT PARAMS also : 4537865
  x_competence_id := NULL  ;
  x_rating_level_id := NULL ;

  FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_COMPETENCE_PUB',
			   p_procedure_name  => 'standard_pub_checks',
			   P_ERROR_TEXT => SUBSTRB(SQLERRM,1,240));
  -- 4537865 : End
  RAISE;
END standard_pub_checks;

/* --------------------------------------------------------------------
PROCEDURE: Mass_Exec_Process_Competences
PURPOSE  : This API is called from the client side when competences
           are added in Mass Mode for requirements. It validates
           the competences and calles the Mass Transaction API to start
           the Mass Transaction Workflow.
 -------------------------------------------------------------------- */
PROCEDURE Mass_Exec_Process_Competences
( p_asgn_update_mode            IN  VARCHAR2 := FND_API.G_MISS_CHAR
 ,p_project_id                  IN  pa_project_assignments.project_id%TYPE
 ,p_assignment_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_competence_id_tbl           IN  SYSTEM.pa_num_tbl_type
 ,p_competence_name_tbl         IN  SYSTEM.pa_varchar2_240_tbl_type
 ,p_competence_alias_tbl        IN  SYSTEM.pa_varchar2_30_tbl_type
 ,p_rating_level_id_tbl         IN  SYSTEM.pa_num_tbl_type
 ,p_rating_level_value_tbl      IN  SYSTEM.pa_num_tbl_type
 ,p_mandatory_flag_tbl          IN  SYSTEM.pa_varchar2_1_tbl_type
 ,p_init_msg_list               IN  VARCHAR2  := FND_API.G_FALSE
 ,p_commit                      IN  VARCHAR2  := FND_API.G_FALSE
 ,p_validate_only               IN  VARCHAR2  := FND_API.G_TRUE
 ,p_max_msg_count               IN  NUMBER    := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)

IS

l_wf_mode              VARCHAR2(200);
l_validate_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_element_id           NUMBER;
l_competence_id        NUMBER;
l_rating_level_id      NUMBER;
l_msg_index_out        NUMBER;
l_return_status        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_rating_level_id_tbl  SYSTEM.pa_num_tbl_type := p_rating_level_id_tbl;
l_rating_level_value_tbl  SYSTEM.pa_num_tbl_type := p_rating_level_value_tbl;
l_competence_id_tbl    SYSTEM.pa_num_tbl_type := p_competence_id_tbl;

BEGIN

  --This API is only called to do standard validations

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the PL/SQL message stack
  pa_competence_pvt.g_noof_errors  := 0;

  IF p_init_msg_list = FND_API.G_TRUE  THEN
     fnd_msg_pub.initialize;
  END IF;

  IF l_rating_level_id_tbl.count > 0 THEN
     FOR i in 1..l_rating_level_id_tbl.count LOOP
         IF l_rating_level_id_tbl(i) = 0 THEN
            l_rating_level_id_tbl(i) := NULL;
         END IF;
         IF l_competence_id_tbl(i) = 0 THEN
            l_competence_id_tbl(i) := NULL;
         END IF;
         IF l_rating_level_value_tbl(i) = 0 THEN
            l_rating_level_value_tbl(i) := NULL;
         END IF;
     END LOOP;
  END IF;

  IF p_competence_id_tbl.count > 0 THEN
     FOR j in 1..p_assignment_id_tbl.count LOOP
         FOR i in 1..p_competence_id_tbl.count LOOP
             standard_pub_checks
                (p_element_id          => l_element_id,
                 p_object_name         => 'OPEN_ASSIGNMENT',
                 p_object_id	       => p_assignment_id_tbl(J),
                 p_competence_id       => l_competence_id_tbl(I),
                 p_competence_alias    => p_competence_alias_tbl(I),
                 p_competence_name     => p_competence_name_tbl(I),
                 p_rating_level_id     => l_rating_level_id_tbl(I),
                 p_rating_level_value  => l_rating_level_value_tbl(I),
                 p_operation           => 'UPDATE',
                 x_return_status       => l_return_status,
                 x_competence_id       => l_competence_id,
                 x_rating_level_id     => l_rating_level_id_tbl(I));
          END LOOP;
     END LOOP;
  END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- if p_validate_only=false and there are no errors then start the
  -- workflow process.

  IF p_validate_only = FND_API.G_FALSE AND
     l_validate_status = FND_API.G_RET_STS_SUCCESS
  THEN

    l_wf_mode := PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES;

     --start the mass WF
     PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
        p_mode                        => l_wf_mode
       ,p_project_id                  => p_project_id
       ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
       ,p_assignment_id_tbl           => p_assignment_id_tbl
       ,p_competence_id_tbl           => l_competence_id_tbl
       ,p_competence_name_tbl         => p_competence_name_tbl
       ,p_competence_alias_tbl        => p_competence_alias_tbl
       ,p_rating_level_id_tbl         => l_rating_level_id_tbl
       ,p_mandatory_flag_tbl          => p_mandatory_flag_tbl
       ,x_return_status               => x_return_status
    );


  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;

       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
                        (p_encoded       => FND_API.G_TRUE,
                         p_msg_index      => 1,
                         p_data           => x_msg_data,
                         p_msg_index_out  => l_msg_index_out );
       END IF;
 -- 4537865 : WHEN OTHERS Block Included.
  WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	x_msg_count := 1;
	x_msg_data := SUBSTRB(SQLERRM,1,240);

	Fnd_Msg_Pub.add_exc_msg(p_pkg_name        => 'PA_COMPETENCE_PUB',
				p_procedure_name  => 'Mass_Exec_Process_Competences',
				p_error_text	  => x_msg_data);
	RAISE ;

END Mass_Exec_Process_Competences;

/* --------------------------------------------------------------------
PROCEDURE: Mass_Process_Competences
PURPOSE  : This API is called from the Mass Transaction Workflow to
           process the competences. It passes to the API the table
           of assignments and the list of competences to be processed.
           The list of competences will be process for each and every
           assignment. If the competence exists for the assignment
           then the Update API is called to update the HR Competence
           Element record. If the competence does not exist, the
           INSERT API is called to create the new competence element.
           If even one competence processing errors out for a given
           assignment, then all the competence changes are rolled back
           for that assignment.
 -------------------------------------------------------------------- */

PROCEDURE Mass_Process_Competences
  ( p_project_id                 IN  pa_project_assignments.project_id%TYPE,
  p_assignment_tbl               IN  SYSTEM.pa_num_tbl_type,
  p_competence_id_tbl            IN  SYSTEM.pa_num_tbl_type,
  p_competence_name_tbl          IN  SYSTEM.pa_varchar2_240_tbl_type,
  p_competence_alias_tbl         IN  SYSTEM.pa_varchar2_30_tbl_type,
  p_rating_level_id_tbl          IN  SYSTEM.pa_num_tbl_type,
  p_mandatory_flag_tbl           IN  SYSTEM.pa_varchar2_1_tbl_type,
  p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE,
  p_validate_only                IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                       IN  VARCHAR2 := FND_API.G_FALSE,
  x_success_assignment_id_tbl    OUT NOCOPY SYSTEM.pa_num_tbl_type,  /* Added NOCOPY for bug#2674619 */
  x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_element_rowid            ROWID;
l_element_id               NUMBER;
l_assignment_id            NUMBER := -1;
l_assignment_return_status VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
l_msg_data                 VARCHAR2(500);
l_msg_count                NUMBER := 0;
l_return_status            VARCHAR2(30);
l_object_version_number    NUMBER;
--added for bug: 4537865
l_new_object_version_number NUMBER;
--added for bug: 4537865
l_competence_element_id    NUMBER;
l_mode                     VARCHAR2(30);
BEGIN

  x_success_assignment_id_tbl := p_assignment_tbl;
  x_return_status             := FND_API.G_RET_STS_SUCCESS;

  IF p_assignment_tbl.count > 0 THEN
     FOR I in 1..p_assignment_tbl.count LOOP

         IF p_assignment_tbl(I) <> l_assignment_id THEN
            -- Assignment Id has changed.
            -- Create a new savepoint. Save the new assigment_id

            IF l_assignment_return_status <> FND_API.G_RET_STS_SUCCESS
            THEN
               ROLLBACK TO PROCESS_COMPETENCE_ELEMENTS;
               PA_MESSAGE_UTILS.save_messages
                   (p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                    p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                    p_source_type2       =>  PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES,
                    p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                    p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                    p_context1           =>  p_project_id,
                    p_context2           =>  p_assignment_tbl(I-1),
                    p_context3           =>  NULL,
                    p_commit             =>  FND_API.G_TRUE,
                    x_return_status      =>  l_return_status);
               l_assignment_return_status := FND_API.G_RET_STS_SUCCESS;
               x_success_assignment_id_tbl(I-1) := null;

            ELSE
               --  Assignment Status is success. Commit the assignment
               --  changes.

               IF p_commit = FND_API.G_TRUE THEN
                    COMMIT;
               END IF;
            END IF;

            l_assignment_id := p_assignment_tbl(I);

            SAVEPOINT PROCESS_COMPETENCE_ELEMENTS;

         END IF;
         IF p_competence_id_tbl.count > 0 THEN
           FOR J in 1..p_competence_id_tbl.count LOOP
             BEGIN
                    SELECT object_version_number,
                           competence_element_id
                    INTO l_object_version_number,
                         l_competence_element_id
                    FROM per_competence_elements
                    WHERE object_id     = p_assignment_tbl(I)
                    AND   object_name   = 'OPEN_ASSIGNMENT'
                    AND   competence_id = p_competence_id_tbl(J);
                    l_mode := 'UPDATE';
             EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                         l_mode := 'INSERT';
             END;
             IF (l_mode = 'UPDATE')
             THEN

                  Update_competence_element
                     (p_element_id            => l_competence_element_id,
                      p_object_name           => 'OPEN_ASSIGNMENT',
                      p_object_id             => p_assignment_tbl(I),
                      p_competence_id         => p_competence_id_tbl(J),
                      p_competence_alias      => p_competence_alias_tbl(J),
                      p_rating_level_id       => p_rating_level_id_tbl(J),
                      p_mandatory_flag        => p_mandatory_flag_tbl(J),
                      p_object_version_number => l_object_version_number,
           --         x_object_version_number => l_object_version_number,       * commented for bug: 4537865
		      x_object_version_number => l_new_object_version_number,   -- added for bug: 4537865
                      x_return_status         => l_return_status,
                      x_msg_count             => l_msg_count,
                      x_msg_data              => l_msg_data);

             --added for bug:  4537865
             IF l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
             l_object_version_number := l_new_object_version_number;
	     END IF;
	     --added for bug:  4537865

             ELSE
                  Add_competence_element
                    (p_object_name      => 'OPEN_ASSIGNMENT',
                     p_object_id        => p_assignment_tbl(I),
                     p_competence_id    => p_competence_id_tbl(J),
                     p_competence_alias => p_competence_alias_tbl(J),
                     p_rating_level_id  => p_rating_level_id_tbl(J),
                     p_mandatory_flag   => p_mandatory_flag_tbl(J),
                     p_init_msg_list    => FND_API.G_FALSE,
                     p_commit           => FND_API.G_FALSE,
                     p_validate_only    => 'N',
                     x_element_rowid    => l_element_rowid,
                     x_element_id       => l_element_id,
                     x_return_status    => l_return_status,
                     x_msg_count        => l_msg_count,
                     x_msg_data         => l_msg_data);
             END IF;

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_return_status := l_return_status;
             END IF;

           END LOOP;
         END IF;

     END LOOP;

     -- Check if the last assignment got updated
     IF l_assignment_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        ROLLBACK TO PROCESS_COMPETENCE_ELEMENTS;
        PA_MESSAGE_UTILS.save_messages
               (p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                p_source_type2       =>  PA_MASS_ASGMT_TRX.G_MASS_UPDATE_COMPETENCIES,
                p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                p_context1           =>  p_project_id,
                p_context2           =>  p_assignment_tbl(p_assignment_tbl.count),
                p_context3           =>  NULL,
                p_commit             =>  FND_API.G_TRUE,
                x_return_status      =>  l_return_status);
           x_success_assignment_id_tbl(p_assignment_tbl.count) := null;

     ELSE
         -- Assignment Status is success. Commit the assignment
         -- changes.
        IF p_commit = FND_API.G_TRUE THEN
           COMMIT;
        END IF;
     END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
       -- 4537865 : RESET OUT PARAMS
       x_success_assignment_id_tbl := NULL ;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_msg_data := SUBSTRB(SQLERRM ,1,240);
       x_msg_count := 1;

        Fnd_Msg_Pub.add_exc_msg(p_pkg_name        => 'PA_COMPETENCE_PUB',
                                p_procedure_name  => 'Mass_Process_Competences',
                                p_error_text      => x_msg_data);
       -- ENd : 4537865
       RAISE;
END;
end pa_competence_pub ;

/
