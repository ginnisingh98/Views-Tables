--------------------------------------------------------
--  DDL for Package GMD_PROC_PARAMS_MIGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_PROC_PARAMS_MIGR" AUTHID CURRENT_USER as
/* $Header: GMDPROCS.pls 115.1 2002/09/13 16:41:59 rajreddy noship $ */

PROCEDURE check_process_parameter;

PROCEDURE oprn_process_parameter;

PROCEDURE recipe_process_parameter;

PROCEDURE batch_process_parameter;

PROCEDURE get_override;

PROCEDURE run;

END GMD_PROC_PARAMS_MIGR;

 

/
