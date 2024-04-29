--------------------------------------------------------
--  DDL for Package BOMPCEXP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPCEXP" AUTHID CURRENT_USER as
/* $Header: BOMCEXPS.pls 120.1 2005/06/21 12:06:07 rfarook noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCEXPS.pls                                               |
| Description  : This is the costing exploder.  This exploder needs	    |
|		 to join to cst_default_cost_view to get the costing 	    |
|		 attributes.						    |
| Parameters:	org_id		organization_id				    |
|		grp_id		unique value to identify current explosion  |
|				use value from sequence bom_explosion_temp_s|
|		cst_type_id	cost type id				    |
|		err_msg		error message out buffer		    |
|		error_code	error code out.  returns sql error code     |
| History:								    |
|	01-FEB-93  Shreyas Shah  Initial coding				    |
|	06-JUN-93  Shreyas Shah  Scrapped the costing exploder that joined  |
|				 to CST_DEFAULT_COST_VIEW since it was	    |
|				 very  slow.  Now just calling bom exploder |
|				 and doing a post explosion update	    |
|       23-JUN-93  Evelyn Tran   Add checking of COMPONENT_YIELD_FLAG when  |
|                                computing extended quantity		    |
|                                                                           |
+==========================================================================*/

PROCEDURE cst_exploder(
	grp_id			IN NUMBER,
	org_id 			IN NUMBER,
	cst_type_id 		IN NUMBER,
	inq_flag		IN NUMBER := 2,
	err_msg			IN OUT NOCOPY VARCHAR2,
	error_code		IN OUT NOCOPY NUMBER
);
END BOMPCEXP;

 

/
