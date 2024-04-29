--------------------------------------------------------
--  DDL for Package Body PJM_PROJECT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJECT_EXT" as
/* $Header: PJMPRJXB.pls 115.3 2003/07/24 18:14:55 alaw noship $ */

function validate_proj_references
( X_inventory_org_id    in            number
, X_operating_unit      in            number
, X_project_id          in            number
, X_task_id             in            number
, X_date1               in            date
, X_date2               in            date
, X_calling_function    in            varchar2
, X_error_code          in out nocopy varchar2
) return varchar2 is

begin
/*
  You can add additional validations fo project references in this
  package.  This function will be executed after the standard
  validations.

  This function should return the following values:

  Successful validation - PJM_PROJECT.G_VALIDATE_SUCCESS
  Error conditions      - PJM_PROJECT.G_VALIDATE_FAILURE
  Warning conditions    - PJM_PROJECT.G_VALIDATE_WARNING


*/
  return ( PJM_PROJECT.G_VALIDATE_SUCCESS );

end validate_proj_references;

end PJM_PROJECT_EXT;

/
