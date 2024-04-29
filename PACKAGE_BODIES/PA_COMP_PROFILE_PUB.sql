--------------------------------------------------------
--  DDL for Package Body PA_COMP_PROFILE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COMP_PROFILE_PUB" AS
-- $Header: PARPRFPB.pls 120.4 2005/11/29 00:41:23 avaithia noship $

-- Forward declaration of validate_attributes procedure
PROCEDURE validate_attributes
(
p_element_id       IN NUMBER := null,
p_person_id        IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id	   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id  IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value  IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_effective_date_from IN DATE := FND_API.G_MISS_DATE,
p_operation           IN  VARCHAR2,
x_return_status	      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_competence_id       OUT NOCOPY per_competences.competence_id%TYPE, --File.Sql.39 bug 4440895
x_rating_level_id     OUT NOCOPY per_competence_elements.rating_level_id%TYPE, --File.Sql.39 bug 4440895
x_effective_date_from OUT NOCOPY DATE); --File.Sql.39 bug 4440895

/* --------------------------------------------------------------------
PROCEDURE Add_Competence_Element
PURPOSE   This procedure inserts a competence element for a person
 -------------------------------------------------------------------- */

PROCEDURE Add_competence_element
(
p_person_id	    IN per_competence_elements.person_id%TYPE,
p_competence_id	    IN per_competences.competence_id%TYPE,
p_competence_alias  IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name   IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id   IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_effective_date_from IN DATE := FND_API.G_MISS_DATE,
p_init_msg_list	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_commit	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only	    IN VARCHAR2 := FND_API.G_MISS_CHAR,
x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data	    OUT NOCOPY VARCHAR2)  IS --File.Sql.39 bug 4440895

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
l_effective_date_from DATE;
l_file_val           VARCHAR2(100);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN

  IF l_enable_log = 'Y' THEN
  pa_debug.init_err_stack ('PA_COMP_PROFILE_PUB.add_competence_element');
  END IF;

  SAVEPOINT COMPETENCE_PUB_ADD_COMP_ELE;


--  dbms_output.put_line('Person ID : ' ||  p_person_id);
--  dbms_output.put_line('Date : ' ||  p_effective_date_from);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the PL/SQL message stack
  PA_COMP_PROFILE_PVT.g_noof_errors  := 0;

  IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
  END IF;

  -- Do the standard public api checks
  validate_attributes
           (p_person_id	          => p_person_id,
            p_competence_id       => p_competence_id,
            p_competence_alias    => p_competence_alias,
            p_competence_name     => p_competence_name,
            p_rating_level_id     => p_rating_level_id,
            p_rating_level_value  => p_rating_level_value,
            p_effective_date_from => p_effective_date_from,
            p_operation           => 'INSERT',
            x_return_status       => l_return_status,
            x_competence_id       => l_competence_id,
            x_rating_level_id     => l_rating_level_id,
            x_effective_date_from => l_effective_date_from);

--  dbms_output.put_line('Date 1: ' ||  l_effective_date_from);
  -- If there are errors at this stage, there is no point
  -- in proceeding further since the competence id or rating level
  -- values are invalid

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
       IF PA_COMP_PROFILE_PVT.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := PA_COMP_PROFILE_PVT.g_noof_errors;
        ELSE
            x_msg_count := PA_COMP_PROFILE_PVT.g_noof_errors;
        END IF;

        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;

        RETURN;
  END IF;

  PA_COMP_PROFILE_PVT.Add_competence_element
      ( p_person_id	       => p_person_id,
        p_competence_id	       => l_competence_id,
        p_rating_level_id      => l_rating_level_id,
        p_effective_date_from  => l_effective_date_from,
        p_commit	       => p_commit,
        p_validate_only	       => p_validate_only,
        x_return_status	       => l_return_status );


   x_msg_count := pa_comp_profile_pvt.g_noof_errors;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
       IF pa_comp_profile_pvt.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := pa_comp_profile_pvt.g_noof_errors;
        ELSE
            x_msg_count := pa_comp_profile_pvt.g_noof_errors;
        END IF;

        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
   ELSE
       x_return_status:= FND_API.G_RET_STS_SUCCESS;
   END IF;

   IF p_commit = FND_API.G_TRUE THEN
      COMMIT;
   END IF;

   IF l_enable_log = 'Y' THEN
   pa_debug.reset_err_stack;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
     IF p_commit = FND_API.G_TRUE THEN
	   ROLLBACK TO COMPETENCE_PUB_ADD_COMP_ELE;
     END IF;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMP_PROFILE_PUB',
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

END Add_Competence_Element;

/* --------------------------------------------------------------------
PROCEDURE Update_competence_element
PURPOSE   This procedure updates the competence elements for a person
 -------------------------------------------------------------------- */

PROCEDURE Update_competence_element
(
p_person_id        IN per_competence_elements.person_id%TYPE     := FND_API.G_MISS_NUM,
p_competence_id    IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_element_id	   IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_rating_level_id IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE := FND_API.G_MISS_NUM,
p_effective_date_from IN DATE := FND_API.G_MISS_DATE,
p_init_msg_list    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_commit	   IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_validate_only    IN VARCHAR2 := FND_API.G_MISS_CHAR,
p_object_version_number IN NUMBER,
x_object_version_number OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
x_msg_data        OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

l_data	             VARCHAR2(500);
l_msg_data           VARCHAR2(500);
l_msg_index_out      NUMBER := 0;
l_return_status      VARCHAR2(30);
l_error_message_code VARCHAR2(30);
l_competence_id      NUMBER := 0;
l_rating_level_id    NUMBER := 0;
l_mandatory_flag     VARCHAR2(1);
l_err	             VARCHAR2(2000);
l_effective_date_from DATE;
l_file_val           VARCHAR2(100);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

--  dbms_output.put_line('Person ID : ' ||  p_person_id);
--  dbms_output.put_line('Entering PUB Update_competence_element');
--  dbms_output.put_line('Effective Date From ' || p_effective_date_from);

  IF l_enable_log = 'Y' THEN
  pa_debug.init_err_stack ('PA_COMP_PROFILE_PUB.update_competence_element');
  END IF;

  SAVEPOINT COMPETENCE_PUB_UPD_COMP_ELE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the PL/SQL message stack

  PA_COMP_PROFILE_PVT.g_noof_errors  := 0;

  IF p_init_msg_list = FND_API.G_TRUE  THEN
	fnd_msg_pub.initialize;
  END IF;

  -- Validate the atttributes

--  dbms_output.put_line('Calling Validate Attributes');

  validate_attributes
           (p_element_id          => p_element_id,
            p_person_id           => p_person_id,
            p_competence_id       => p_competence_id,
            p_competence_alias    => p_competence_alias,
            p_competence_name     => p_competence_name,
            p_rating_level_id     => p_rating_level_id,
            p_rating_level_value  => p_rating_level_value,
            p_effective_date_from => p_effective_date_from,
            p_operation           => 'UPDATE',
            x_return_status       => l_return_status,
            x_competence_id       => l_competence_id,
            x_rating_level_id     => l_rating_level_id,
            x_effective_date_from => l_effective_date_from);


--  dbms_output.put_line('After Calling Validate Attributes');
  IF l_return_status = FND_API.G_RET_STS_ERROR THEN

--    dbms_output.put_line('Error in  Validate Attributes');
    x_return_status:= FND_API.G_RET_STS_ERROR;
    IF PA_COMP_PROFILE_PVT.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := PA_COMP_PROFILE_PVT.g_noof_errors;
    ELSE
            x_msg_count := PA_COMP_PROFILE_PVT.g_noof_errors;
    END IF;
    IF l_enable_log = 'Y' THEN
    pa_debug.reset_err_stack;
    END IF;
    RETURN;
  END IF;

  PA_COMP_PROFILE_PVT.update_competence_element
          ( p_person_id	      => p_person_id
           ,p_competence_id   => l_competence_id
           ,p_element_id      => p_element_id
           ,p_rating_level_id => l_rating_level_id
           ,p_effective_date_from => l_effective_date_from
           ,p_commit	      => p_commit
           ,p_validate_only   => p_validate_only
           ,p_object_version_number => p_object_version_number
           ,x_object_version_number => x_object_version_number
           ,x_return_status    => l_return_status );

  x_return_status := l_return_status;

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
       IF pa_comp_profile_pvt.g_noof_errors = 1 THEN
	    pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_TRUE,
 		 p_msg_index      => 1,
                 p_msg_count      => x_msg_count ,
                 p_msg_data       => l_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
            x_msg_data := l_data;
            x_msg_count := pa_comp_profile_pvt.g_noof_errors;
        ELSE
            x_msg_count := pa_comp_profile_pvt.g_noof_errors;
        END IF;

        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
  ELSE
       x_return_status:= FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     COMMIT;
  END IF;

  IF l_enable_log = 'Y' THEN
  pa_debug.reset_err_stack;
  END IF;

EXCEPTION
   WHEN OTHERS THEN

     l_err := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
	   ROLLBACK TO COMPETENCE_PUB_UPD_COMP_ELE;
     END IF;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMP_PROFILE_PUB',
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

END update_competence_element ;

PROCEDURE delete_competence_element
(p_person_id      IN per_competence_elements.person_id%TYPE  := FND_API.G_MISS_NUM,
 p_competence_id  IN per_competence_elements.competence_id%TYPE := FND_API.G_MISS_NUM,
 p_element_id     IN per_competence_elements.competence_element_id%TYPE := FND_API.G_MISS_NUM,
 p_init_msg_list         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_commit                IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_validate_only         IN VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_version_number IN NUMBER,
 x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_err	        VARCHAR2(2000);
l_data	        VARCHAR2(500);
l_msg_data      VARCHAR2(500);
l_msg_count     NUMBER;
l_msg_index_out NUMBER := 0;
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  PA_COMP_PROFILE_PVT.delete_competence_element
          ( p_person_id             => p_person_id,
            p_competence_id         => p_competence_id,
            p_element_id            => p_element_id,
            p_object_version_number => p_object_version_number,
            p_commit	            => p_commit,
            x_return_status         => l_return_status );
	x_return_status := l_return_status ; -- 4537865
EXCEPTION
   WHEN OTHERS THEN

     l_err := SQLERRM;

     fnd_msg_pub.add_exc_msg
      (p_pkg_name => 'PA_COMP_PROFILE_PUB',
       p_procedure_name => 'delete_competence_element');

     x_msg_count := 1;

     IF x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => l_msg_count ,
             p_msg_data       => l_msg_data ,
             p_data           => l_data,
             p_msg_index_out  => l_msg_index_out );

             x_msg_data := l_data;
     END IF;

     x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
END;

/* --------------------------------------------------------------------
PROCEDURE validate_attributes
PURPOSE   This procedure validates the change
          Validates :
            Rating Level and Level Id: It returns back the rating level
            id if rating level value is passed.

            Competence name and Id: It returns back the Competence_Id
            if Competence Name is passed.

            If the operation is update, you are not allowed to
            update the competence_id on the record.

            Effective Date From: If returns back the sysdate is the date
            is null or missing. Validates that the effective date is
            in the within limits of the dates the competence itself is
            valid
 -------------------------------------------------------------------- */
PROCEDURE validate_attributes
(
p_element_id       IN NUMBER := null,
p_person_id        IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_id	   IN per_competences.competence_id%TYPE := FND_API.G_MISS_NUM,
p_competence_alias IN per_competences.competence_alias%TYPE  := FND_API.G_MISS_CHAR,
p_competence_name  IN per_competences.name%TYPE  := FND_API.G_MISS_CHAR,
p_rating_level_id  IN per_competence_elements.rating_level_id%TYPE := FND_API.G_MISS_NUM,
p_rating_level_value IN per_rating_levels.step_value%TYPE  := FND_API.G_MISS_NUM,
p_effective_date_from  IN DATE := FND_API.G_MISS_DATE,
p_operation            IN VARCHAR2,
x_return_status	      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_competence_id       OUT NOCOPY per_competences.competence_id%TYPE, --File.Sql.39 bug 4440895
x_rating_level_id     OUT NOCOPY per_competence_elements.rating_level_id%TYPE, --File.Sql.39 bug 4440895
x_effective_date_from OUT NOCOPY DATE) --File.Sql.39 bug 4440895
IS
l_return_status         VARCHAR2(30);
l_error_message_code    VARCHAR2(30);
l_in_competence_id      NUMBER := 0;

-- angie changed back to original to fix bug 1569499
l_in_rating_level_id    NUMBER := 0;

l_in_competence_alias   VARCHAR2(30);
l_in_competence_name    VARCHAR2(240);
l_in_rating_level_value NUMBER := 0;
l_competence_id         NUMBER := 0;
l_rating_level_id       NUMBER := 0;
l_valid                 VARCHAR2(1);
l_old_competence_id     NUMBER;
l_old_comp_name         VARCHAR2(240);
l_old_comp_alias        VARCHAR2(30);
l_exists                VARCHAR2(1);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN

   IF l_enable_log = 'Y' THEN
   pa_debug.init_err_stack ('PA_COMP_PROFILE_PUB.standard_pub_checks');
   END IF;
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

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
            PA_COMP_PROFILE_PVT.Check_Error
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
            PA_COMP_PROFILE_PVT.Check_Error
                   (p_return_status => l_return_status,
                    p_error_message_code => 'PA_PRM_CANNOT_UPD_COMP');
         END IF;
      END IF;
   END IF;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
   END IF;

--   dbms_output.put_line('Calling Check_CompName_Or_Id');

   pa_hr_competence_utils.Check_CompName_Or_Id
          ( p_competence_id      => l_in_competence_id
           ,p_competence_alias   => l_in_competence_alias
           ,p_competence_name    => l_in_competence_name
           ,p_check_id_flag      => pa_startup.g_check_id_flag
           ,x_competence_id      => l_competence_id
           ,x_return_status      => l_return_status
           ,x_error_msg_code     => l_error_message_code);


--   dbms_output.put_line('After Calling Check_CompName_Or_Id: ' || l_return_status);
   PA_COMP_PROFILE_PVT.Check_Error
                   (p_return_status => l_return_status,
		    p_error_message_code => l_error_message_code );

   --If the return status is invalid, we cannot proceed further
   -- All further validations require a competency id to be present

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
       x_return_status:= FND_API.G_RET_STS_ERROR;
        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
   END IF;

   -- Check to see if the operation is UPDATE and the user is trying to
   -- update the competency. You are not allowed to update the competency

   IF p_operation = 'UPDATE' THEN
      IF p_element_id is not null THEN
         BEGIN
            SELECT competence_id
            INTO l_old_competence_id
            FROM per_competence_elements
            WHERE competence_element_id = p_element_id;

            IF l_old_competence_id <> l_competence_id THEN
               PA_COMP_PROFILE_PVT.Check_Error
                   (p_return_status      => FND_API.G_RET_STS_ERROR,
                    p_error_message_code => 'PA_PRM_CANNOT_UPD_COMP');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
              null;
         END;
      END IF;
   END IF;

   x_competence_id := l_competence_id;

   IF p_effective_date_from is null OR
      p_effective_date_from = FND_API.G_MISS_DATE THEN
      x_effective_date_from := trunc(sysdate);
   ELSE
      x_effective_date_from := p_effective_date_from;
   END IF;

   -- Verify if the x_effective_date_from is within the date limits
   -- of the competences itself.
--   dbms_output.put_line('Effective Date: ' || x_effective_date_from);
--   dbms_output.put_line('Co Id         : ' || x_competence_id);

   BEGIN
     SELECT 'Y'
     INTO l_valid
     FROM per_competences
     WHERE x_effective_date_from BETWEEN date_from AND NVL(date_to,x_effective_date_from)
     AND competence_id=x_competence_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          PA_COMP_PROFILE_PVT.Check_Error
                   (p_return_status      => l_return_status,
                    p_error_message_code => 'PA_PRM_INVALID_DATE');
   END;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status:= FND_API.G_RET_STS_ERROR;
        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
   END IF;

   -- Check whether rating level or value is passed and call competence utils
   -- to validate . Do this only if either rating level id or rating level
   -- value is passed. In certain cases (like in a public delete api)
   -- these values will not be passed , hence do not validate if both the
   -- values are not passed

   IF (l_in_rating_level_id IS NULL AND l_in_rating_level_value
	 IS NULL ) THEN
        IF l_enable_log = 'Y' THEN
        pa_debug.reset_err_stack;
        END IF;
        RETURN;
   END IF;

--   dbms_output.put_line('Calling Check_Rating_Level_Or_Id');

   pa_hr_competence_utils.Check_Rating_Level_Or_Id
         ( p_competence_id    =>  l_competence_id
          ,p_rating_level_id   => l_in_rating_level_id
          ,p_rating_level      => l_in_rating_level_value
          ,p_check_id_flag     => pa_startup.g_check_id_flag
          ,x_rating_level_id   => l_rating_level_id
          ,x_return_status     => l_return_status
          ,x_error_msg_code    => l_error_message_code) ;

--   dbms_output.put_line('After Calling Check_Rating_Level_Or_Id: ' || l_return_status);

   PA_COMP_PROFILE_PVT.Check_Error
                   (p_return_status => l_return_status,
		    p_error_message_code => l_error_message_code );

   IF PA_COMP_PROFILE_PVT.g_noof_errors > 0 THEN
          x_return_status:= FND_API.G_RET_STS_ERROR;
   ELSE
          x_return_status:= FND_API.G_RET_STS_SUCCESS;
   END IF;
   IF l_enable_log = 'Y' THEN
   pa_debug.reset_err_stack;
   END IF;
   x_rating_level_id := l_rating_level_id;


EXCEPTION
 WHEN OTHERS THEN
  -- 4537865 : RESET Other OUT params too.
  x_rating_level_id := NULL ;
  x_effective_date_from := NULL ;
  x_competence_id := NULL ;

  x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  RAISE;
END validate_attributes;

Procedure Start_Approval_Process
(x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data          OUT NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
BEGIN
/* --this API has been stubbed out for Bug:4665696
  PA_COMP_PROFILE_PVT.Start_Approval_Process
  (x_return_status => x_return_status,
   x_msg_count     => x_msg_count,
   x_msg_data      => x_msg_data);
   --this API has been stubbed out for Bug:4665696
*/
null; --added for bug:4665696
END;

PROCEDURE Update_HR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2) --File.Sql.39 bug 4440895
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    PA_COMP_PROFILE_PVT.Update_HR
       (p_profile_id    => to_number(itemkey),
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data);

--    dbms_output.put_line('After PA_COMP_PROFILE_PVT.Update_H');
    resultout := 'COMPLETE';
    return;

  END IF;

  IF (funcmode = 'CANCEL') THEN
    null;
    return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
--    dbms_output.put_line('Exception Raised');
    wf_core.context('PA_COMP_PROFILE_PUB', 'Update_HR',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END Update_HR;

PROCEDURE Clear_Temp_Table(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2) --File.Sql.39 bug 4440895
IS
l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_enable_log varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
BEGIN
  --
  -- RUN mode - normal process execution
  --


  IF (funcmode = 'RUN') THEN

    PA_COMP_PROFILE_PVT.Clear_Temp_Table
       (p_profile_id    => to_number(itemkey),
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data);

--    dbms_output.put_line('After PA_COMP_PROFILE_PVT.Update_H');
    resultout := 'COMPLETE';
    return;

  END IF;

  IF (funcmode = 'CANCEL') THEN
    null;
    return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
--    dbms_output.put_line('Exception Raised');
    wf_core.context('PA_COMP_PROFILE_PUB', 'Update_HR',
		    itemtype, itemkey, to_char(actid), funcmode);
    raise;
END;

procedure approval_message_body (
document_id in varchar2,
display_type in varchar2,
document in out NOCOPY varchar2,  --File.Sql.39 bug 4440895
document_type in out NOCOPY varchar2)  --File.Sql.39 bug 4440895
IS
BEGIN
  PA_COMP_PROFILE_PVT.approval_message_body
       (document_id   => document_id,
        display_type  => display_type,
        document      => document,
        document_type => document_type);
END;

Procedure Set_Person(p_person_id IN NUMBER)
IS
BEGIN
  g_assignment_id := 0;
  g_person_id := p_person_id;
END;

Procedure Set_Assignment(p_assignment_id IN NUMBER)
IS
BEGIN
  g_person_id := 0;
  g_assignment_id := p_assignment_id;
END;

/* --------------------------------------------------------------------
FUNCTION  Get_Select_Flag
PURPOSE   This function is called from the view PA_ALL_COMPETENCES_LOV_V.
          It returns 'Y' for the global person (g_person_id) or
          assignment (g_assignment_id) if a competence
          exists for it. Returns 'N' if it does not.
 -------------------------------------------------------------------- */

Function Get_Select_Flag(p_competence_id IN NUMBER)
RETURN VARCHAR2
IS
l_exists  VARCHAR2(1) := 'N';
BEGIN
 IF (g_person_id = 0 or g_person_id is null) AND
    (g_assignment_id = 0 or g_assignment_id is null) THEN
    RETURN l_exists;
 END IF;

 IF g_person_id > 0 THEN

    SELECT 'Y'
    INTO l_exists
    FROM per_competence_elements
    WHERE person_id = g_person_id
    AND competence_id = p_competence_id;

 ELSIF g_assignment_id > 0 THEN

    SELECT 'Y'
    INTO l_exists
    FROM per_competence_elements
    WHERE object_id = g_assignment_id
    AND competence_id = p_competence_id
    and OBJECT_NAME = 'OPEN_ASSIGNMENT' ; -- Included for 4765876

 END IF;

 RETURN l_exists;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
    RETURN l_exists;

 WHEN OTHERS THEN
    RETURN l_exists;
END;

Procedure Get_User_Info(p_user_id        IN  VARCHAR2,
			x_Person_id      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_Resource_id    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_resource_name  OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
	 l_employee_id  VARCHAR2(30);
	 l_resource_id  VARCHAR2(30);
	 l_resource_name VARCHAR(240);

BEGIN
	 SELECT employee_id
		 INTO l_employee_id
		 from fnd_user
		 where user_id=to_number(p_user_id);
	 x_Person_id :=  l_employee_id;

         BEGIN
   	   SELECT resource_id
		 INTO l_resource_id
		 FROM pa_resource_txn_attributes
		 WHERE person_id=l_employee_id;
	    x_Resource_id := l_resource_id;
	 EXCEPTION
	    WHEN NO_DATA_FOUND THEN
              x_resource_id   := '';
         END;

	 SELECT full_name
		 INTO l_resource_name
		 FROM per_all_people_f
		 WHERE person_id = l_employee_id
                 and  trunc(sysdate) between trunc(effective_start_date)
                                     and trunc(effective_end_date);
	 x_resource_name := l_resource_name;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_Person_id     := '';
		 x_resource_id   := '';
		 x_resource_name := '';
	 WHEN OTHERS THEN
		 x_Person_id     := '';
		 x_resource_id   := '';
		 x_resource_name := '';
END;

Procedure Get_User_Info(p_user_id        IN  VARCHAR2,
			x_Person_id      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			x_Resource_id    OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
	 l_employee_id  VARCHAR2(30);
	 l_resource_id  VARCHAR2(30);
BEGIN
	 SELECT employee_id
		 INTO l_employee_id
		 from fnd_user
		 where user_id=to_number(p_user_id);
	 x_Person_id :=  l_employee_id;

	 SELECT resource_id
		 INTO l_resource_id
		 FROM pa_resource_txn_attributes
		 WHERE person_id=l_employee_id;
	 x_Resource_id := l_resource_id;
EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_Person_id     := '';
		 x_resource_id   := '';
	 WHEN OTHERS THEN
		 x_Person_id     := '';
		 x_resource_id   := '';
END;


FUNCTION Get_person_business_group
(P_Person_id   IN NUMBER
)
RETURN NUMBER
IS
l_bg_id NUMBER := 0;
BEGIN

  SELECT BUSINESS_GROUP_ID
  into l_bg_id
  FROM PER_PEOPLE_X
  WHERE person_id=P_Person_id;

  RETURN l_bg_id;
EXCEPTION
   WHEN OTHERS THEN
     RETURN -999;
END;

end PA_COMP_PROFILE_PUB;

/
