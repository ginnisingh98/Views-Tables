--------------------------------------------------------
--  DDL for Package PJM_PROJECT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_PROJECT_EXT" AUTHID CURRENT_USER as
/* $Header: PJMPRJXS.pls 115.2 2003/07/24 18:14:42 alaw noship $ */

function validate_proj_references
( X_inventory_org_id    in            number
, X_operating_unit      in            number
, X_project_id          in            number
, X_task_id             in            number
, X_date1               in            date     default null
, X_date2               in            date     default null
, X_calling_function    in            varchar2
, X_error_code          in out nocopy varchar2
) return varchar2;

end PJM_PROJECT_EXT;

 

/
