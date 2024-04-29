--------------------------------------------------------
--  DDL for Package EGO_VALID_INSTANCE_SET_GRANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_VALID_INSTANCE_SET_GRANTS" AUTHID CURRENT_USER as
/* $Header: EGOISGRS.pls 115.1 2003/03/31 12:45:12 djebar noship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOISGRS.pls
--
--  DESCRIPTION
--
--      Spec of package EGO_VALID_INSTANCE_SET_GRANTS
--
--  NOTES
--
--  HISTORY
--
--  31-MAR-03 Deepak Jebar      Initial Creation
--
**************************************************************************/

PROCEDURE GET_VALID_INSTANCE_SETS(p_obj_name IN VARCHAR2,
				  p_grantee_type IN VARCHAR2,
				  p_parent_obj_sql IN VARCHAR2,
				  p_bind1 IN VARCHAR2,
				  p_bind2 IN VARCHAR2,
				  p_bind3 IN VARCHAR2,
				  p_bind4 IN VARCHAR2,
				  p_bind5 IN VARCHAR2,
				  p_obj_ids IN VARCHAR2,
				  x_inst_set_ids OUT NOCOPY VARCHAR2);
END;

 

/
