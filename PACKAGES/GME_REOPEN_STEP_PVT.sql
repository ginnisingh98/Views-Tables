--------------------------------------------------------
--  DDL for Package GME_REOPEN_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_REOPEN_STEP_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVROSS.pls 120.1 2005/06/03 13:48:59 appldev  $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVROSS.pls
REM * PURPOSE: Package Specification for the GME batch reopen api
REM * AUTHOR:  Olivier DABOVAL, OPM Development
REM * DATE:    31th May 2001
REM * HISTORY:
REM * ========
REM * 31-May-2001   Olivier DABOVAL
REM *          Created
REM * 06AUG01  Thomas Daniel                                             *
REM *          Made changes for phantom implementation.                  *
REM **********************************************************************
*/
   PROCEDURE reopen_all_steps (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE reopen_step (
      p_batch_step_rec   IN              gme_batch_steps%ROWTYPE
     ,x_batch_step_rec   OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status    OUT NOCOPY      VARCHAR2);
END gme_reopen_step_pvt;

 

/
