--------------------------------------------------------
--  DDL for Package GME_PHANTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PHANTOM_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEVPHBS.pls 120.3.12010000.1 2008/07/25 10:31:18 appldev ship $    */
/*
REM **********************************************************************
REM *                                                                    *
REM * FILE:    GMEVPHBS.pls                                              *
REM * PURPOSE: Package Spec for the GME PHANTOM API         routines     *
REM * AUTHOR:  Thomas Daniel, OPM Development                            *
REM * DATE:    July 10th 2001                                            *
REM * HISTORY:                                                           *
REM * ========                                                           *
REM *  Swapna K Bug#6738476 11-JAN-2008
REM *   Added the variable, p_batch_header_rec to the procedure, create_phantom *
REM **********************************************************************/

   /*************************************************************************
* This file contains procedures for the Phantom Batch APIs for GME in    *
* Oracle Process Manufacturing (OPM). Each procedure has a common set of *
* parameters to which API-specific parameters are appended.              *
*************************************************************************/
   PROCEDURE create_phantom (
      p_material_detail_rec      IN              gme_material_details%ROWTYPE
     ,p_batch_header_rec         IN              gme_batch_header%ROWTYPE --swapna
     ,p_batch_no                 IN              VARCHAR2 DEFAULT NULL
     ,x_material_detail_rec      OUT NOCOPY      gme_material_details%ROWTYPE
     ,p_validity_rule_id         IN              NUMBER
     ,p_use_workday_cal          IN              VARCHAR2
     ,p_contiguity_override      IN              VARCHAR2
     ,p_use_least_cost_validity_rule     IN      VARCHAR2 := fnd_api.g_false
     ,x_exception_material_tbl   OUT NOCOPY      gme_common_pvt.exceptions_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   FUNCTION is_phantom (
      p_batch_header    IN              gme_batch_header%ROWTYPE
     ,x_return_status   OUT NOCOPY      VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE fetch_step_phantoms (
      p_batch_id                 IN              NUMBER
     ,p_batchstep_id             IN              NUMBER
     ,p_all_release_type_assoc   IN              NUMBER DEFAULT 0
     ,x_phantom_ids              OUT NOCOPY      gme_common_pvt.number_tab
     ,x_return_status            OUT NOCOPY      VARCHAR2);

   PROCEDURE fetch_line_phantoms (
      p_batch_id        IN              NUMBER
     ,p_include_step    IN              BOOLEAN DEFAULT TRUE
     ,x_phantom_ids     OUT NOCOPY      gme_common_pvt.number_tab
     ,x_return_status   OUT NOCOPY      VARCHAR2);
END gme_phantom_pvt;

/
