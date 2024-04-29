--------------------------------------------------------
--  DDL for Package XXAH_TASK_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XXAH_TASK_NOTIFY_PKG" AS

PROCEDURE debug_print(
   p_print_flag  IN  VARCHAR2
  ,p_debug_mesg  IN  VARCHAR2
);

PROCEDURE notify_all
(
    x_retbuf            OUT   VARCHAR2
  , x_retcode           OUT   NUMBER
)
;

END xxah_task_notify_pkg;
 

/
