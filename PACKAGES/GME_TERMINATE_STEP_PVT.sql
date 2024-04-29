--------------------------------------------------------
--  DDL for Package GME_TERMINATE_STEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_TERMINATE_STEP_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVTRSS.pls 120.1 2005/06/03 12:25:06 appldev  $    */
/*
REM *********************************************************************
REM *
REM * FILE:    GMEVTRSS.pls
REM * PURPOSE: Package Spec for the GME step terminate api
REM * AUTHOR:  Pawan Kumar
REM * DATE:    2 May 2005
REM * HISTORY:
REM * ========
REM *
REM * A. Newbury Bug -- B3184949 Create package
REM **********************************************************************
*/
   PROCEDURE terminate_step (
      p_batch_step_rec         IN              gme_batch_steps%ROWTYPE
     ,p_update_inventory_ind   IN              VARCHAR2
     ,p_actual_cmplt_date      IN              DATE
     ,x_batch_step_rec         OUT NOCOPY      gme_batch_steps%ROWTYPE
     ,x_return_status          OUT NOCOPY      VARCHAR2);
END gme_terminate_step_pvt;

 

/
