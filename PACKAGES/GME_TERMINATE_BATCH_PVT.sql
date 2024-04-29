--------------------------------------------------------
--  DDL for Package GME_TERMINATE_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TERMINATE_BATCH_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVTRBS.pls 120.1 2005/06/03 12:24:34 appldev  $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVTRBS.pls
REM * PURPOSE: Package Specification for the GME batch terminate api
REM * AUTHOR:  Pawan Kumar
REM * DATE:    2 May 2005
REM * HISTORY:
REM * ========
REM **********************************************************************
*/
   PROCEDURE terminate_batch (
      p_batch_header_rec   IN              gme_batch_header%ROWTYPE
     ,x_batch_header_rec   OUT NOCOPY      gme_batch_header%ROWTYPE
     ,x_return_status      OUT NOCOPY      VARCHAR2);

   PROCEDURE abort_wf (p_type IN VARCHAR2, p_item_id IN NUMBER);
END gme_terminate_batch_pvt;

 

/
