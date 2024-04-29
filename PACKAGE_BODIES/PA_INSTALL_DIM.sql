--------------------------------------------------------
--  DDL for Package Body PA_INSTALL_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_INSTALL_DIM" AS
/* $Header: PAADWIDB.pls 115.0 99/07/16 13:22:20 porting ship $ */

PROCEDURE install_dimension(x_task_proj_flag  varchar2,
                            x_dimension_name  varchar2,
                            x_freeze_flag    IN OUT varchar2,
                            x_err_stage      IN OUT varchar2,
                            x_err_stack      IN OUT varchar2,
                            x_err_code       IN OUT number)
IS
BEGIN
  null;
END;

END PA_INSTALL_DIM;

/
