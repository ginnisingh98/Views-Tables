--------------------------------------------------------
--  DDL for Package PJM_PROJECT_LOCATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJECT_LOCATOR" AUTHID CURRENT_USER AS
/* $Header: PJMPLOCS.pls 120.1 2005/06/16 10:38:30 appldev  $ */
--
--  Name          : Check_Project_References
--  Pre-reqs      : None.
--  Function      : This function checks whether a given locator has
--                  appropriate project and task references based on the
--                  current organization.  Also if the validation mode is
--                  specific, the function checks whether the parameters
--                  project_id and task_id have appropriate values.
--
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_locator_id              IN       NUMBER
--                : p_validation_mode         IN       VARCHAR2
--                : p_required_flag           IN       VARCHAR2
--                : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--
--  Returns       : TRUE  if locator passes the validation for the
--                           specific mode
--                  FALSE if locator fails the validation for the
--                           specific mode
--
FUNCTION Check_Project_References(
          p_organization_id  IN NUMBER,
          p_locator_id       IN NUMBER,
          p_validation_mode  IN VARCHAR2,
          p_required_flag    IN VARCHAR2,
          p_project_id       IN NUMBER DEFAULT NULL,
          p_task_id          IN NUMBER DEFAULT NULL
) RETURN BOOLEAN;
FUNCTION Check_Project_References(
          p_organization_id  IN NUMBER,
          p_locator_id       IN NUMBER,
          p_validation_mode  IN VARCHAR2,
          p_required_flag    IN VARCHAR2,
          p_project_id       IN NUMBER DEFAULT NULL,
          p_task_id          IN NUMBER DEFAULT NULL,
          p_item_id          IN NUMBER
) RETURN BOOLEAN;


--  Name          : Check_ItemLocatorControl
--  Pre-reqs      : None.
--  Function      : This function checks the locator control
--                  at three different levels: Org, Sub, Item.
--                  If parameter p_hardpeg_only is 1, it also
--                  checks if it is a hard-peg item.
--                  If the item has a restricted list of subinventory
--                  or locators, this function also checks if
--                  the parameter p_sub, p_loc are within its list.
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_sub                     IN       VARCHAR2
--                : p_loc                     IN       NUMBER
--                : p_item_id                 IN       NUMBER
--                : p_hardpeg_only            IN       NUMBER
--
--  Returns       : True if all test are passed, else return False
--
--  Version       : 1.0                 10/02/97  W. Pacifia Chiang
--  Notes         :
--
FUNCTION Check_ItemLocatorControl (
          p_organization_id   IN     NUMBER,
          p_sub               IN     VARCHAR2,
          p_loc               IN     NUMBER,
          p_item_id           IN     NUMBER,
          p_hardpeg_only      IN     NUMBER
) RETURN BOOLEAN;


--  Name          : Get_DefaultProjectLocator
--  Pre-reqs      : None.
--  Function      : This procedure matches a project locator based on
--                  the parameters organization_id, locator_id, project_id
--                  and task_id.  If no locator is found, a new locator is
--                  created with project reference in segment19 and
--                  task reference in segment20 into mtl_item_locations
--                  using same physical attributes (from segment1 upto
--                  segment18 depending locator flexfield setup).
--
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_locator_id              IN       NUMBER
--                : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--                : p_project_locator_id      IN OUT   NUMBER
--
--  RETURNS       : N/A
--
PROCEDURE Get_DefaultProjectLocator(
	  p_organization_id    IN     NUMBER,
	  p_locator_id         IN     NUMBER,
	  p_project_id         IN     NUMBER,
	  p_task_id            IN     NUMBER,
	  p_project_locator_id IN OUT NOCOPY NUMBER
);


--  Name          : Get_Job_ProjectSupply
--  Pre-reqs      : None.
--  Function      : This procedure gets supply locators
--                  for materials that are backflushed
--                  for project jobs.
--
--                  The assumption for this procedure is that
--                  the supply subinventory/locator value of those
--                  wip_requirement_operations should be common locators.
--
--  Parameters    :
--  IN            : p_organization_id IN       NUMBER
--                : p_wip_entity_id   IN       NUMBER
--                : p_project_id      IN       NUMBER
--                : p_task_id         IN       NUMBER
--                : p_success         OUT      NUMBER
--
--  RETURNS       : N/A
--
PROCEDURE Get_Job_ProjectSupply (
          p_organization_id   IN  NUMBER,
          p_wip_entity_id     IN  NUMBER,
          p_project_id        IN  NUMBER,
          p_task_id           IN  NUMBER,
          p_success           OUT NOCOPY NUMBER
);


--  Function name : Get_Flow_ProjectSupply
--  Pre-reqs      : None.
--  Function      : This procedure gets supply locators
--                  for materials that are backflushed
--                  for project related flow schedules.
--
--                  The assumption for this procedure is that
--                  the supply subinventory/locator value of those
--                  in mtl_transactions_interface should be common
--                  locators.
--
--  Parameters    :
--  IN            : p_organization_id IN       NUMBER
--                : p_wip_entity_id   IN       NUMBER
--                : p_project_id      IN       NUMBER
--                : p_task_id         IN       NUMBER
--                : p_success         OUT      NUMBER
--
--  Returns       : N/A
--
PROCEDURE Get_Flow_ProjectSupply (
          p_organization_id   IN  NUMBER,
          p_wip_entity_id     IN  NUMBER,
          p_project_id        IN  NUMBER,
          p_task_id           IN  NUMBER,
          p_parent_id         IN  NUMBER,
          p_success           OUT NOCOPY NUMBER
);


--  Name          : Get_Component_ProjectSupply
--  Pre-reqs      : None.
--  Function      :
--
--
--  Parameters    :
--  IN            : p_organization_id         IN       NUMBER
--                : p_project_id              IN       NUMBER
--                : p_task_id                 IN       NUMBER
--                : p_wip_entity_id           IN       NUMBER
--                : p_supply_sub              IN       NUMBER
--                : p_supply_loc_id           IN OUT   NUMBER
--                : p_item_id                 IN       NUMBER
--                : p_org_loc_control         IN       NUMBER
--
--  Returns       : BOOLEAN
--                  The output of p_supply_loc_id will be the
--                  proper locator with project and task
--                  references based on the pegging attribute
--                  of the component.
--
--  Version       : 1.0                 8/22/97  D Soosai
--  Notes         :
--
FUNCTION Get_Component_ProjectSupply (
          p_organization_id   IN     NUMBER,
          p_project_id        IN     NUMBER,
          p_task_id           IN     NUMBER,
          p_wip_entity_id     IN     NUMBER,
          p_supply_sub        IN     VARCHAR2,
          p_supply_loc_id     IN OUT NOCOPY NUMBER,
          p_item_id           IN     NUMBER,
          p_org_loc_control   IN     NUMBER
) RETURN BOOLEAN;


--  Name          : Get_Physical_Location
--  Pre-reqs      : None.
--  Function      : This function resolves the physical locator
--                  for any given locator
--
--
--  Parameters    :
--  IN            : X_organization_id         IN       NUMBER
--                : X_locator_id              IN       NUMBER
--
--  Returns       : TRUE is successful, FALSE otherwise
--
--  Version       : 1.0                12/22/97 A Law
--  Notes         :
--
FUNCTION get_physical_location ( X_organization_id IN NUMBER
                               , X_locator_id      IN NUMBER )
RETURN BOOLEAN;


PROCEDURE Set_Segment_Default (
          p_project_id        IN  NUMBER,
          p_task_id           IN  NUMBER
);

PROCEDURE Put_OrgProfile(name in varchar2, val in varchar2);
PROCEDURE Get_OrgProfile(name in varchar2, val out nocopy varchar2);

FUNCTION Proj_Seg_Default return VARCHAR2;
FUNCTION Task_Seg_Default return VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Proj_Seg_Default, WNDS, WNPS);
PRAGMA RESTRICT_REFERENCES (Task_Seg_Default, WNDS, WNPS);
END;

 

/
