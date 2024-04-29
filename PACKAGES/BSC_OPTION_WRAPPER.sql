--------------------------------------------------------
--  DDL for Package BSC_OPTION_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_OPTION_WRAPPER" AUTHID CURRENT_USER as
/* $Header: BSCAOWRS.pls 115.5 2003/01/10 23:37:00 meastmon ship $ */


procedure Update_Option_Name(
  p_old_option_name	IN	varchar2
 ,p_new_option_name	IN	varchar2
 ,p_option_dim_levels	IN	varchar2
 ,p_option_description	IN	varchar2
);

end BSC_OPTION_WRAPPER;

 

/
