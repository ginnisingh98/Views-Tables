--------------------------------------------------------
--  DDL for Package GME_ERES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_ERES_UTILS" AUTHID CURRENT_USER AS
/*  $Header: GMEERESS.pls 120.2 2005/07/17 21:31:55 jsrivast noship $ */
/*
REM **********************************************************************
REM *                                                                    *
REM * FILE:    GMEERESS.pls                                              *
REM * PURPOSE: Package specification for the GME ERES_UTILS routines     *
REM *          It contens all the routines to support the ERES output    *
REM *          during XML mapping, used by gateway product.              *
REM * AUTHOR:  Shrikant Nene, OPM Development                            *
REM * DATE:    August 18th 2002                                          *
REM * HISTORY:                                                           *
REM * ========                                                           *
REM *********************************************************************
* This file contains the procedure for create batch steps in Oracle      *
* Process Manufacturing (OPM). Each procedure has a common set of        *
* parameters to which API-specific parameters are appended.              *
*************************************************************************/
   PROCEDURE get_batch_number (
      p_batch_id       IN       NUMBER,
      x_batch_number   OUT  NOCOPY    VARCHAR2
   );

   PROCEDURE get_phantom_or_not (p_batch_id       IN       NUMBER,
                                 x_phantom        OUT  NOCOPY    VARCHAR2);

END GME_ERES_UTILS; -- Package Specification GME_ERES_UTILS

 

/
