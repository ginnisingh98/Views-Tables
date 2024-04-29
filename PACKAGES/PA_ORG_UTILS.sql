--------------------------------------------------------
--  DDL for Package PA_ORG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ORG_UTILS" AUTHID CURRENT_USER as
/* $Header: PAXORUTS.pls 120.3 2007/10/29 10:11:25 jjgeorge ship $ */

FUNCTION get_org_version_id(x_usage in varchar2) RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_org_version_id, WNDS, WNPS );

/* 1333116 Added this function to return the org hierarchy version
and to handle burdening hierarchy */
FUNCTION get_org_version_id2(x_usage in varchar2) RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_org_version_id, WNDS, WNPS );

FUNCTION get_start_org_id(x_usage in varchar2) RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_start_org_id, WNDS, WNPS );

/* 1333116 Added this function to return the org hierarchy
start organization and to handle burdening hierarchy */
FUNCTION get_start_org_id2(x_usage in varchar2) RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_start_org_id, WNDS, WNPS );

-- Start CC Change
FUNCTION get_org_level(
                        p_org_version_id in number,
                        p_child_parent_org_id in number,
                        p_start_org_id in number
                      )
RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_org_level, WNDS, WNPS );

FUNCTION get_start_org_id_sch(
                            p_org_version_id in number
                           )
RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_start_org_id, WNDS, WNPS );

FUNCTION get_max_org_level(
                            p_org_version_id in number,
                            p_start_org_id in number
                           )
RETURN NUMBER;
pragma RESTRICT_REFERENCES  ( get_max_org_level, WNDS, WNPS );

-- End   CC Change


-- Start CC Change

PROCEDURE Create_org_hier_denorm_levels(p_parent_organization_id  in number,
                                      p_child_organization_id   in number,
                                      p_org_hierarchy_version_id in number,
                                      p_pa_org_use_type  in varchar2,
                                      p_parent_level in number,
                                      p_child_level in number,
                                      x_err_code         in out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage        in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack        in out NOCOPY varchar2); --File.Sql.39 bug 4440895


Procedure populate_hier_denorm_sch ( p_org_version_id in number,
                                     x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                                     x_err_stage in out NOCOPY varchar2,  --File.Sql.39 bug 4440895
                                     x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

-- End   CC Change

Procedure maintain_org_hist_imp(x_org_id in number,
                               x_old_proj_org_version_id in number,
                               x_new_proj_org_version_id in number,
                               x_old_exp_org_version_id in number,
                               x_new_exp_org_version_id in number,
                               x_old_org_structure_version_id  in number,
                               x_new_org_structure_version_id  in number,
                               x_old_proj_start_org_id in number,
                               x_new_proj_start_org_id in number,
                               x_old_exp_start_org_id in number,
                               x_new_exp_start_org_id in number,
                               x_old_start_organization_id  in number,
                               x_new_start_organization_id  in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2); --File.Sql.39 bug 4440895

Procedure maintain_org_hist_bri(x_org_version_id in number,
                               x_organization_id_child in number,
                               x_organization_id_parent in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2) ; --File.Sql.39 bug 4440895

Procedure maintain_org_hist_brd(x_org_version_id in number,
                               x_organization_id_child in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2) ; --File.Sql.39 bug 4440895

Procedure Start_Org_Changed   (x_old_org_version_id in number,
                               x_new_org_version_id in number,
			       x_old_start_org_id in number,
                               x_new_start_org_id in number,
                               x_org_use_type in varchar2,
                               x_org_id in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2) ; --File.Sql.39 bug 4440895
procedure maintain_org_info_hist_bri
		   	      (x_organization_id           in  	number  ,
                	       x_org_information1          in  	varchar2,
                               x_org_information_context   in  	varchar2,
                               x_org_information2          in  	varchar2,
   		               x_err_code		in out  NOCOPY number, --File.Sql.39 bug 4440895
                	       x_err_stage 		in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
		    	       x_err_stack 		in out  NOCOPY varchar2 ); --File.Sql.39 bug 4440895

PROCEDURE Create_org_hierarchy_denorm(p_parent_organization_id  in number,
                                      p_child_organization_id   in number,
                                      p_org_hierarchy_version_id in number,
                                      p_pa_org_use_type  in varchar2,
                                      x_err_code         in out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage        in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack        in out NOCOPY varchar2); --File.Sql.39 bug 4440895

--
-- Procedure
-- Create by Ranga Iyengar
-- Dated : 02-NOV-2000
-- This procedure populates data in pa_org_hierarchy_denorm
-- for reporting type of organizations and stores
-- parent level and child levels
--
--
PROCEDURE populate_hierarchy_denorm
                             ( p_org_version_id         IN NUMBER
                               ,p_organization_id_parent IN  NUMBER
                               ,p_organization_id_child  IN NUMBER
                               ,x_err_code               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                               ,x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               ,x_err_stack              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             );

PROCEDURE populate_hierarchy_denorm2
                             ( p_org_version_id         IN NUMBER
                               ,p_organization_id_parent IN  NUMBER
                               ,p_organization_id_child  IN NUMBER
                               ,p_org_id                 IN NUMBER
                               ,x_err_code               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                               ,x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               ,x_err_stack              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             );
PROCEDURE Check_Org_In_OrgHierarchy
        (
         p_organization_id  IN PA_ORG_HIERARCHY_DENORM.parent_organization_id%TYPE,
         p_org_structure_version_id IN PA_ORG_HIERARCHY_DENORM.org_hierarchy_version_id%TYPE,
         p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
         x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
         x_error_message_code   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
	);

PROCEDURE Check_OrgHierarchy_Type(
                p_org_structure_version_id IN PA_ORG_HIERARCHY_DENORM.org_hierarchy_version_id%TYPE,
                p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
                x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        );

PROCEDURE Check_Org_Type(
                p_organization_id  IN PA_ORG_HIERARCHY_DENORM.parent_organization_id%TYPE,
                p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
                x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        );

--
-- Procedure : Populate_Org_Hier_Denorm
-- This procedure populates data in pa_org_hierarchy_denorm
-- for reporting type of organizations and stores
-- parent level and child levels
-- This procedure is called by the concurrent process
-- "Maintain Project Resources"
PROCEDURE Populate_Org_Hier_Denorm(
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_data       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Bug#2643047 - This procedure is added so as to populate organizations for REPORTING pa_org_use_type
when a new organization is added in the hierarchy. That is added in per_org_structure_elements table.
The call to this procedure will be made from maintain_org_hist_bri
The newly added organization is x_organiation_id_child which is added under x_organization_id_parent*/

Procedure populate_reporting_orgs(
                               x_org_version_id in number,
                               x_organization_id_child in number,
                               x_organization_id_parent in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2 --File.Sql.39 bug 4440895
			        );
/* Bug#2643047 - This procedure is added to restructure the levels in the table
pa_og_hierarchy_denorm for REPORTING pa_org_use_type when a organization is deleted from the hierarchy.
The call to this procedure will be made from maintain_org_hist_brd.
The deleted organization is x_organiation_id_child  */

procedure restructure_rpt_orgs_denorm(
                               x_org_version_id in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2 --File.Sql.39 bug 4440895
			               );

/* Bug 3649799 Procedure for update of denorm table, called in the update trigger */

procedure maintain_org_hist_update(x_err_code                   in out  NOCOPY number, --File.Sql.39 bug 4440895
                                   x_err_stage                  in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                   x_err_stack                  in out  NOCOPY varchar2); --File.Sql.39 bug 4440895

/* Bug 3649799 - added rowid plsql table for storing the rowids of records updated*/

type ridArray is table of rowid index by binary_integer;

newRows ridArray;
empty ridArray;

procedure maintain_projexp_org_update(p_version_id in number,
                                      p_org_use_type in varchar2,
				      x_err_code                   in out  NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage                  in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack                  in out  NOCOPY varchar2); --File.Sql.39 bug 4440895


/* Added for  bug 5633304*/
Procedure maintain_pa_all_org(x_org_version_id in number,
                               x_err_code in out  NOCOPY number,
                               x_err_stage in out NOCOPY varchar2,
                               x_err_stack in out NOCOPY varchar2);


END pa_org_utils;

/
