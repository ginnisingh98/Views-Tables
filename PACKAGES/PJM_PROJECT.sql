--------------------------------------------------------
--  DDL for Package PJM_PROJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJECT" AUTHID CURRENT_USER as
/* $Header: PJMPROJS.pls 120.1 2006/03/15 15:28:13 yliou noship $ */

FUNCTION Proj_Or_Seiban
( X_project_id  IN NUMBER
) return varchar2;


FUNCTION Is_Exp_Proj
( X_project_id  IN NUMBER ,
  X_org_id      IN NUMBER
) return varchar2;

--
-- Resolve project number from project ID against all projects
--
function all_proj_idtonum
( X_project_id          in number
) return varchar2;


--
-- Resolve project name from project ID against all projects
--
function all_proj_idtoname
( X_project_id          in number
) return varchar2;


--
-- Resolve project number from project ID against current valid projects only
--
-- X_organization_id is optional; if given, the function further narrows the
-- list of valid projects to those with project parameter defined in the
-- given organization
--
function val_proj_idtonum
( X_project_id          in number
, X_organization_id     in number default null
) return varchar2;


--
-- Resolve project name from project ID against current valid projects only
--
-- X_organization_id is optional; if given, the function further narrows the
-- list of valid projects to those with project parameter defined in the
-- given organization
--
function val_proj_idtoname
( X_project_id          in number
, X_organization_id     in number default null
) return varchar2;


--
-- Resolve project ID from project number against current valid projects only
--
-- X_organization_id is optional; if given, the function further narrows the
-- list of valid projects to those with project parameter defined in the
-- given organization
--
function val_proj_numtoid
( X_project_num         in varchar2
, X_organization_id     in number default null
) return number;


--
-- Resolve project ID from project name against current valid projects only
--
-- X_organization_id is optional; if given, the function further narrows the
-- list of valid projects to those with project parameter defined in the
-- given organization
--
function val_proj_nametoid
( X_project_name        in varchar2
, X_organization_id     in number default null
) return number;


--
-- Resolve task number from task ID against all tasks
--
function all_task_idtonum
( X_task_id             in number
) return varchar2;


--
-- Resolve task name from task ID against all tasks
--
function all_task_idtoname
( X_task_id             in number
) return varchar2;


--
-- Resolve task number from project ID and task ID against current valid
-- projects and tasks only
--
function val_task_idtonum
( X_project_id          in number
, X_task_id             in number
) return varchar2;


--
-- Resolve task name from project ID and task ID against current valid
-- projects and tasks only
--
function val_task_idtoname
( X_project_id          in number
, X_task_id             in number
) return varchar2;


--
-- Resolve task ID from project number and task number against current valid
-- projects and tasks only
--
function val_task_numtoid
( X_project_num         in varchar2
, X_task_num            in varchar2
) return number;


--
-- Resolve task ID from project name and task name against current valid
-- projects and tasks only
--
function val_task_nametoid
( X_project_name        in varchar2
, X_task_name           in varchar2
) return number;

--
-- Validate project references for a particular calling function
--
G_VALIDATE_SUCCESS      constant varchar2(1) := 'S';
G_VALIDATE_WARNING      constant varchar2(1) := 'W';
G_VALIDATE_FAILURE      constant varchar2(1) := 'E';

--
-- Old version kept for backward compatibility
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return boolean;

--
-- This variant does not include the error code out parameter
-- and can be used in SQL
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date     default null
, X_date2               in         date     default null
, X_calling_function    in         varchar2
) return varchar2;

--
-- This variant uses the current operating unit as the default
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date     default null
, X_date2               in         date     default null
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return varchar2;

--
-- This is the main definition of the function
--
function validate_proj_references
( X_inventory_org_id    in         number
, X_operating_unit      in         number
, X_project_id          in         number
, X_task_id             in         number
, X_date1               in         date     default null
, X_date2               in         date     default null
, X_calling_function    in         varchar2
, X_error_code          out nocopy varchar2
) return varchar2;

end PJM_PROJECT;

 

/
