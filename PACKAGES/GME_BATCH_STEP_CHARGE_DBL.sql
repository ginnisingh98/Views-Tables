--------------------------------------------------------
--  DDL for Package GME_BATCH_STEP_CHARGE_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_STEP_CHARGE_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGSCS.pls 120.1 2005/06/03 13:46:47 appldev  $ */

   /*
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGSCS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_batch_step_charges_dbl                         |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  04-MAY-2004 Rishi Varma bug  3307549              |
 |     Created                                                   |
 |                                                                         |
 |             - insert_row                                                |
 |             - fetch_row                                                 |
 |             - delete_row                                                |
 |             - Update_row
 |                                                                         |
 |                            |
 ===========================================================================
*/
   FUNCTION insert_row (
      p_batch_step_charges_in   IN              gme_batch_step_charges%ROWTYPE
     ,x_batch_step_charges      IN OUT NOCOPY   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION fetch_row (
      p_batch_step_charges_in   IN              gme_batch_step_charges%ROWTYPE
     ,x_batch_step_charges      IN OUT NOCOPY   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_row (
      p_batch_step_charges_in   IN   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION update_row (
      p_batch_step_charges_in   IN   gme_batch_step_charges%ROWTYPE)
      RETURN BOOLEAN;
END;

 

/
