--------------------------------------------------------
--  DDL for Package GME_CANCEL_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_CANCEL_BATCH_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVCCBS.pls 120.1.12010000.2 2009/03/23 13:37:46 gmurator ship $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVCCBS.pls
REM * PURPOSE: Package Specification for the GME batch cancel api
REM * AUTHOR:  Pawan Kumar, OPM Development
REM * DATE:    28th April 2001
REM * HISTORY:
REM * ========
REM *
REM * G. Muratore   22-MAR-09  Bug 8312658
REM *    New parameter p_recursive added. 'R' value will initiate recursive logic.
REM *    PROCEDURE:   purge_batch_exceptions
REM **********************************************************************
*/
   PROCEDURE cancel_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE purge_batch_exceptions (
      p_batch_header_rec      IN              gme_batch_header%ROWTYPE
     ,p_delete_invis_mo       IN              VARCHAR2 := 'F'
     ,p_delete_reservations   IN              VARCHAR2 := 'F'
     ,p_delete_trans_pairs    IN              VARCHAR2 := 'F'
     ,p_recursive             IN              VARCHAR2 := 'N'
     ,x_return_status         OUT NOCOPY      VARCHAR2);

   PROCEDURE delete_pending_lots (
      p_batch_id             IN              NUMBER
     ,p_material_detail_id   IN              NUMBER DEFAULT NULL
     ,x_return_status        OUT NOCOPY      VARCHAR2);
END gme_cancel_batch_pvt;

/
