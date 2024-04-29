--------------------------------------------------------
--  DDL for Package GME_CLOSE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CLOSE_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCLBS.pls 120.1 2005/06/03 13:44:24 appldev  $ */
   TYPE step_details_tab IS TABLE OF gme_batch_steps%ROWTYPE
      INDEX BY BINARY_INTEGER;

   PROCEDURE close_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   FUNCTION create_history (p_batch_header_rec IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION check_close_date (p_batch_header_rec IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN;

   PROCEDURE fetch_batch_steps (
      p_batch_id        IN              NUMBER
     ,p_batchstep_id    IN              NUMBER
     ,x_step_tbl        OUT NOCOPY      step_details_tab
     ,x_return_status   OUT NOCOPY      VARCHAR2);
END gme_close_batch_pvt;

 

/
