--------------------------------------------------------
--  DDL for Package PA_HR_ORG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_HR_ORG_UTILS" AUTHID CURRENT_USER AS
-- $Header: PAORUTLS.pls 120.1 2005/08/19 16:37:20 mwasowic noship $

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
--
procedure Check_OrgHierName_Or_Id
                               ( p_org_hierarchy_version_id    IN NUMBER
                                ,p_org_hierarchy_name  IN VARCHAR2
                                ,p_check_id_flag IN VARCHAR2
                                ,x_org_hierarchy_version_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                ,x_error_msg_code OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895
PROCEDURE Check_OrgName_Or_Id
                                ( p_organization_id    IN NUMBER
                                 ,p_organization_name  IN VARCHAR2
                                 ,p_check_id_flag IN VARCHAR2
                                 ,x_organization_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                 ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                 ,x_error_msg_code OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895
end pa_hr_org_utils ;
 

/
