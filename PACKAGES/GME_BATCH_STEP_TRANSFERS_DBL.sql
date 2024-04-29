--------------------------------------------------------
--  DDL for Package GME_BATCH_STEP_TRANSFERS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_STEP_TRANSFERS_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGSTS.pls 120.0 2005/05/26 14:48:02 appldev noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGSTS.pls
 |
 |   DESCRIPTION
 |      Spec of package gme_batch_step_transfers_dbl
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
  (p_batch_step_transfers IN            GME_BATCH_STEP_TRANSFERS%ROWTYPE
  ,x_batch_step_transfers IN OUT NOCOPY GME_BATCH_STEP_TRANSFERS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION fetch_row
  (p_batch_step_transfers IN            GME_BATCH_STEP_TRANSFERS%ROWTYPE
  ,x_batch_step_transfers IN OUT NOCOPY GME_BATCH_STEP_TRANSFERS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION delete_row
  (p_batch_step_transfers IN GME_BATCH_STEP_TRANSFERS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION update_row
  (p_batch_step_transfers IN GME_BATCH_STEP_TRANSFERS%ROWTYPE)
  RETURN BOOLEAN;

  FUNCTION lock_row
  (p_batch_step_transfers IN GME_BATCH_STEP_TRANSFERS%ROWTYPE)
  RETURN BOOLEAN;

END GME_BATCH_STEP_TRANSFERS_DBL;

 

/
