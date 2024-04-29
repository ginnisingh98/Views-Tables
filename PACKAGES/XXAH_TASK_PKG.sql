--------------------------------------------------------
--  DDL for Package XXAH_TASK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_TASK_PKG" AS

PROCEDURE debug_print(
   p_print_flag  IN  VARCHAR2
  ,p_debug_mesg  IN  VARCHAR2
);


PROCEDURE assign_managers(
    p_project_id pa_projects_all.project_id%TYPE
  , p_user_id                   fnd_user.user_id%TYPE
  , p_responsibility_id         fnd_responsibility.responsibility_id%TYPE
  , p_application_short_name    fnd_application.application_short_name%TYPE
);

END xxah_task_pkg;
 

/
