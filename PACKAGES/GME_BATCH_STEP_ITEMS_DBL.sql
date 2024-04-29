--------------------------------------------------------
--  DDL for Package GME_BATCH_STEP_ITEMS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_STEP_ITEMS_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGSIS.pls 120.0 2005/05/26 14:47:37 appldev noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |
 |
 |   DESCRIPTION
 |      Spec of package gme_batch_step_items_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01	Thomas Daniel 	Created
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
  (p_batch_step_items IN            GME_BATCH_STEP_ITEMS%ROWTYPE
  ,x_batch_step_items IN OUT NOCOPY GME_BATCH_STEP_ITEMS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION fetch_row
  (p_batch_step_items IN            GME_BATCH_STEP_ITEMS%ROWTYPE
  ,x_batch_step_items IN OUT NOCOPY GME_BATCH_STEP_ITEMS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION delete_row
  (p_batch_step_items IN GME_BATCH_STEP_ITEMS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION update_row
  (p_batch_step_items IN GME_BATCH_STEP_ITEMS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION lock_row
  (p_batch_step_items IN GME_BATCH_STEP_ITEMS%ROWTYPE)
  RETURN BOOLEAN;

END GME_BATCH_STEP_ITEMS_DBL;

 

/
