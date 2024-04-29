--------------------------------------------------------
--  DDL for Package GME_BATCH_HISTORY_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_HISTORY_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGHSS.pls 120.1 2005/06/03 13:45:23 appldev  $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |       GMEVGHSS.pls
 |
 |   DESCRIPTION
 |      Spec of package gme_batch_history_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01 Thomas Daniel  Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/
   FUNCTION insert_row (
      p_batch_history   IN              gme_batch_history%ROWTYPE
     ,x_batch_history   IN OUT NOCOPY   gme_batch_history%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION fetch_row (
      p_batch_history   IN              gme_batch_history%ROWTYPE
     ,x_batch_history   IN OUT NOCOPY   gme_batch_history%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION update_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION lock_row (p_batch_history IN gme_batch_history%ROWTYPE)
      RETURN BOOLEAN;
END gme_batch_history_dbl;

 

/
