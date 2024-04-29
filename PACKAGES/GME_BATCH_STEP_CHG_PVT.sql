--------------------------------------------------------
--  DDL for Package GME_BATCH_STEP_CHG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_BATCH_STEP_CHG_PVT" AUTHID CURRENT_USER AS
/*$Header: GMEVCHGS.pls 120.1 2005/06/03 13:44:02 appldev  $ */

   /*
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVCHGS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_batch_Step_chg_pvt                             |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  10-MAY-2004 Rishi Varma bug  3307549              |
 |     Created                                                   |
 |                                                                         |
 |             - insert_row                                                |
 |             - fetch_row                                                 |
 |             - delete_row                                                |
 |                                                                         |
 |                            |
 ===========================================================================
*/
   TYPE gme_batch_ids_tab IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE gme_batchstep_ids_tab IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   PROCEDURE set_activity_sequence_num (pbatch_id IN NUMBER);

   PROCEDURE set_all_batch_activities;

   PROCEDURE set_sequence_dependent_id (pbatch_id IN NUMBER);

   PROCEDURE set_all_batch_sequences;

   PROCEDURE clear_charge_dates (
      p_batch_id        IN              NUMBER
     ,p_batchstep_id    IN              NUMBER DEFAULT NULL
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   PROCEDURE clear_charges (
      p_batch_id        IN              NUMBER
     ,p_batchstep_id    IN              NUMBER DEFAULT NULL
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   --Rishi Varma B3718176 14-07-2004
   /*Added new procedure to calcualate the activity_sequence_number
   of gme_batch_step_charges table*/
   PROCEDURE calc_activity_sequence_number (
      p_batchstep_id    IN              gme_batch_steps.batchstep_id%TYPE
     ,p_resources       IN              gme_batch_step_resources.resources%TYPE
     ,x_act_seq_num     OUT NOCOPY      NUMBER
     ,x_return_status   OUT NOCOPY      VARCHAR2);

   --Rishi Varma B3718176 22-07-2004
   /*Added new procedure to populate the gme_batch_step_charges table.*/
   PROCEDURE populate_charges_table (
      p_batchstep_charges_in   IN              gme_batch_step_charges%ROWTYPE
     ,p_no_of_charges          IN              NUMBER
     ,p_remaining_quantity     IN              NUMBER
     ,x_return_status          OUT NOCOPY      VARCHAR2);
END;

 

/
