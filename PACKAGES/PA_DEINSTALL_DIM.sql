--------------------------------------------------------
--  DDL for Package PA_DEINSTALL_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DEINSTALL_DIM" AUTHID CURRENT_USER AS
/* $Header: PAADWDDS.pls 115.0 99/07/16 13:22:16 porting ship $ */

--- This is a dummy procedure to be installed in the project database so that the form
--- PAADWDIM.fmb can be compile dwithout OADW

procedure  deinstall_dimension(x_task_proj_flag       Varchar2,
                               x_dimension_id         Varchar2,
                               x_freeze_flag   IN OUT Varchar2,
                               x_err_stage     IN OUT varchar2,
                               x_err_stack     IN OUT varchar2,
                               x_err_code      IN OUT number) ;

end ;




 

/
