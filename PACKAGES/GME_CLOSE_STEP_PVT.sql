--------------------------------------------------------
--  DDL for Package GME_CLOSE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CLOSE_STEP_PVT" AUTHID CURRENT_USER AS
/* $Header: GMEVCLSS.pls 120.2 2005/09/15 15:48:03 snene noship $ */
   PROCEDURE close_step (
      p_batch_step_rec   IN              gme_batch_steps%ROWTYPE
     ,p_delete_pending   IN              VARCHAR2 DEFAULT fnd_api.g_false
     ,x_batch_step_rec   OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2);
END gme_close_step_pvt;

 

/
