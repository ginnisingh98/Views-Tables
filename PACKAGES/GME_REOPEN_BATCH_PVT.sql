--------------------------------------------------------
--  DDL for Package GME_REOPEN_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_REOPEN_BATCH_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVROBS.pls 120.2 2006/01/16 15:44:13 pxkumar noship $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVROBS.pls
REM * PURPOSE: Package Specification for the GME batch reopen api
REM * AUTHOR:  Olivier DABOVAL, OPM Development
REM * DATE:    31th May 2001
REM *
REM * PROCEDURE reopen_batch
REM * FUNCTION  is_batch_posted
REM * FUNCTION  is_period_open
REM * FUNCTION  create_history
REM *
REM *
REM * HISTORY:
REM * ========
REM * 31-May-2001   Olivier DABOVAL
REM *          Created
REM * 06AUG01  Thomas Daniel                                             *
REM *          Made changes for phantom implementation.                  *
REM **********************************************************************
*/
   TYPE material_details_tab IS TABLE OF gme_material_details%ROWTYPE
      INDEX BY BINARY_INTEGER;

   PROCEDURE reopen_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,p_reopen_steps       IN              VARCHAR2 := 'F'
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   FUNCTION is_batch_posted (
      p_batch_id             IN   NUMBER DEFAULT NULL
     ,p_material_detail_id   IN   NUMBER DEFAULT NULL)
      RETURN BOOLEAN;

   FUNCTION is_period_open (p_batch_id IN NUMBER)
      RETURN BOOLEAN;

  /* FUNCTION create_history (p_batch_header_rec IN gme_batch_header%ROWTYPE)
      RETURN BOOLEAN; */
END gme_reopen_batch_pvt;

 

/
