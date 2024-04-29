--------------------------------------------------------
--  DDL for Package Body PA_HR_ORG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_HR_ORG_UTILS" AS
-- $Header: PAORUTLB.pls 120.1 2005/08/19 16:37:15 mwasowic noship $

--
--  PROCEDURE
--              Check_OrgHierName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Org Hierarchy name is passed converts it to the id
--		If Org Hierachy Id is passed,
--		based on the check_id_flag validates it
--  HISTORY
--   23-JUN-2000      R. Krishnamurthy       Created
--   31-AUG-2000      R. Krishnamurthy       Added error handling for the
--                                           procedures
procedure Check_OrgHierName_Or_Id
				( p_org_hierarchy_version_id    IN NUMBER
				 ,p_org_hierarchy_name  IN VARCHAR2
				 ,p_check_id_flag IN VARCHAR2
				 ,x_org_hierarchy_version_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
				 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				 ,x_error_msg_code OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
BEGIN
    pa_debug.init_err_stack ('pa_hr_org_utils.Check_OrgHierName_Or_Id');
    IF ((p_org_hierarchy_version_id IS NOT NULL) and
        ( p_org_hierarchy_version_id <> FND_API.G_MISS_NUM)) THEN
      IF (p_check_id_flag = 'Y') THEN
        SELECT POSV1.org_structure_version_id
        INTO x_org_hierarchy_version_id
        FROM per_org_structure_versions POSV1
        WHERE POSV1.org_structure_version_id
	     = p_org_hierarchy_version_id;
      ELSE
	x_org_hierarchy_version_id := p_org_hierarchy_version_id;
      END IF;
    ELSE
      SELECT POSV1.org_structure_version_id
        INTO x_org_hierarchy_version_id
        FROM per_organization_structures POS,
	     per_org_structure_versions POSV1
        WHERE POS.name = p_org_hierarchy_name
	AND   POS.organization_structure_id =
	      POSV1.organization_structure_id;
    END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
        pa_debug.reset_err_stack;
    EXCEPTION
      WHEN no_data_found THEN
        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_error_msg_code:= 'PA_ORG_HIER_INVALID_AMBIGOUS';
      WHEN too_many_rows THEN
        x_return_status:= FND_API.G_RET_STS_ERROR;
        x_error_msg_code:= 'PA_ORG_HIER_INVALID_AMBIGOUS';
       WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg
          (p_pkg_name => 'PA_HR_ORG_UTILS',
           p_procedure_name => pa_debug.g_err_stack );
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         RAISE;
END Check_OrgHierName_Or_id;

PROCEDURE Check_OrgName_Or_Id
                                ( p_organization_id    IN NUMBER
                                 ,p_organization_name  IN VARCHAR2
                                 ,p_check_id_flag IN VARCHAR2
                                 ,x_organization_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ,x_error_msg_code OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';


   CURSOR c_ids IS
	  SELECT organization_id
          FROM hr_organization_units
          WHERE name  = p_organization_name;
BEGIN
      IF ((p_organization_id <> FND_API.G_MISS_NUM) AND (p_organization_id IS NOT NULL)) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT organization_id
          INTO x_organization_id
          FROM hr_all_organization_units -- Bug 4358448 perf change
          WHERE organization_id = p_organization_id;

        ELSIF (p_check_id_flag='N') THEN
            x_organization_id := p_organization_id;

        ELSIF (p_check_id_flag = 'A') THEN
             IF (p_organization_name IS NULL) THEN
                 -- Return a null ID since the name is null.
                   x_organization_id := NULL;
             ELSE

                 -- Find the ID which matches the Name passed
                 OPEN c_ids;
                    LOOP
                    	FETCH c_ids INTO l_current_id;
                    	EXIT WHEN c_ids%NOTFOUND;
                    	IF (l_current_id = p_organization_id) THEN
                         	l_id_found_flag := 'Y';
                        	x_organization_id := p_organization_id;
                    	END IF;
                    END LOOP;
                    l_num_ids := c_ids%ROWCOUNT;
                 CLOSE c_ids;

                 IF (l_num_ids = 0) THEN
                     -- No IDs for name
                     RAISE NO_DATA_FOUND;
                 ELSIF (l_num_ids = 1) THEN
                     -- Since there is only one ID for the name use it.
                     x_organization_id := l_current_id;
                 ELSIF (l_id_found_flag = 'N') THEN
                     -- More than one ID for the name and none of the IDs matched
                     -- the ID passed in.
                        RAISE TOO_MANY_ROWS;
                 END IF;
             END IF;

        ELSE
            x_organization_id := NULL;
        END IF;


      ELSE
        IF (p_organization_name IS NOT NULL) THEN
          SELECT organization_id
          INTO x_organization_id
          FROM hr_organization_units
          WHERE name  = p_organization_name;
        ELSE
	  x_organization_id := NULL;
        END IF;
      END IF;
        x_return_status:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
       WHEN no_data_found THEN
         x_organization_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_INVALID_ORG';
       WHEN too_many_rows THEN
         x_organization_id := NULL;
         x_return_status:= FND_API.G_RET_STS_ERROR;
         x_error_msg_code:= 'PA_ORG_NOT_UNIQUE';
       WHEN OTHERS THEN
         x_organization_id := NULL;
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.add_exc_msg(p_pkg_name => 'pa_projects_maint_utils', p_procedure_name  => 'Check_org_name_Or_Id');
         RAISE;
END Check_OrgName_Or_Id;

END pa_hr_org_utils ;

/
