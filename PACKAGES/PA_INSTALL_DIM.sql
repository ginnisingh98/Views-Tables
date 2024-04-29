--------------------------------------------------------
--  DDL for Package PA_INSTALL_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_INSTALL_DIM" AUTHID CURRENT_USER AS
/* $Header: PAADWIDS.pls 115.0 99/07/16 13:22:25 porting ship $ */

--- This is a dummy procedure to be installed in the projects database when oadw is not installed
--  to get the form paadwdim.fmb compiled

procedure  install_dimension(x_task_proj_flag        varchar2,
                             x_dimension_name        varchar2,
                             x_freeze_flag    IN OUT varchar2,
                             x_err_stage      IN OUT varchar2,
                             x_err_stack      IN OUT varchar2,
                             x_err_code       IN OUT number) ;


end ;




 

/
