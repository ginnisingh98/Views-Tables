--------------------------------------------------------
--  DDL for Package GME_CANCEL_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CANCEL_STEP_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVCCSS.pls 120.1 2005/06/03 12:26:07 appldev  $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVCCSS.pls
REM * PURPOSE: Package Specification for the GME batch step cancel api
REM * AUTHOR:  Olivier Daboval, OPM Development
REM * DATE:    08 May 2001
REM * HISTORY:
REM * ========
REM * 08-May-2001   Olivier Daboval
REM *          Created
REM *
REM **********************************************************************
*/
   PROCEDURE cancel_step (
      p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,p_update_inventory_ind   IN              VARCHAR2
     ,x_batch_step_rec         OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2);
END gme_cancel_step_pvt;

 

/
