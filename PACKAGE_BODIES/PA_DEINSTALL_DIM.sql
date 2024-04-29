--------------------------------------------------------
--  DDL for Package Body PA_DEINSTALL_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DEINSTALL_DIM" AS
/* $Header: PAADWDDB.pls 115.0 99/07/16 13:22:11 porting ship $ */

--- This procedure deinstalls Dimensions(dummy procedure for compiling paadwdim.fmb form
--- when oadw is not installed)

PROCEDURE deinstall_dimension(x_task_proj_flag       Varchar2,
                              x_dimension_id         Varchar2,
                              x_freeze_flag   IN OUT Varchar2,
                              x_err_stage     IN OUT varchar2,
                              x_err_stack     IN OUT varchar2,
                              x_err_code      IN OUT number)

IS
BEGIN
  null;
EXCEPTION
  WHEN OTHERS THEN
  x_err_code := SQLCODE ;
  RAISE ;
END;

END PA_DEINSTALL_DIM;

/
