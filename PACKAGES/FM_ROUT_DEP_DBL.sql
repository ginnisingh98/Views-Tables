--------------------------------------------------------
--  DDL for Package FM_ROUT_DEP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FM_ROUT_DEP_DBL" AUTHID CURRENT_USER AS
/* $Header: GMDPRDDS.pls 115.1 2002/11/08 23:04:31 txdaniel noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMDPRDDS.pls
 |
 |   DESCRIPTION
 |      Spec of package fm_rout_dep_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   20-MAR-01	Thomas Daniel 	Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/


  FUNCTION insert_row
  (p_out_dep IN  FM_ROUT_DEP%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION fetch_row
  (p_out_dep IN  FM_ROUT_DEP%ROWTYPE
  ,x_out_dep OUT NOCOPY FM_ROUT_DEP%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION delete_row
  (p_out_dep IN FM_ROUT_DEP%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION update_row
  (p_out_dep IN FM_ROUT_DEP%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION lock_row
  (p_out_dep IN FM_ROUT_DEP%ROWTYPE)
  RETURN BOOLEAN;

END FM_ROUT_DEP_DBL;

 

/
