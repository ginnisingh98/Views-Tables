--------------------------------------------------------
--  DDL for Package BSC_CALCULATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CALCULATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVCLCS.pls 120.0.12000000.1 2007/07/17 07:44:34 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCLCS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      December 28, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Kishore Somesula                                        |
 |                                                                                      |
 | Description:                                                                         |
 |                      Private Specs version.                                           |
 |      This package handles calculations                                               |
 |                                                                                      |
 +======================================================================================+
*/

PROCEDURE delete_objective_calculation (
  p_indicator            IN    bsc_kpi_calculations.indicator%TYPE,
  p_calculation_id       IN    bsc_kpi_calculations.calculation_id%TYPE,
  x_return_status      OUT   NOCOPY   VARCHAR2,
  x_msg_count          OUT   NOCOPY   NUMBER,
  x_msg_data           OUT   NOCOPY   VARCHAR2
);

PROCEDURE insert_objective_calculation (
  p_indicator            IN    bsc_kpi_calculations.indicator%TYPE,
  p_calculation_id       IN    bsc_kpi_calculations.calculation_id%TYPE,
  p_user_level0          IN    bsc_kpi_calculations.user_level0%TYPE,
  p_user_level1          IN    bsc_kpi_calculations.user_level1%TYPE,
  p_user_level1_default  IN    bsc_kpi_calculations.user_level1_default%TYPE,
  p_user_level2          IN    bsc_kpi_calculations.user_level2%TYPE,
  p_user_level2_default  IN    bsc_kpi_calculations.user_level2_default%TYPE,
  p_default_value        IN    bsc_kpi_calculations.default_value%TYPE,
  x_return_status      OUT   NOCOPY   VARCHAR2,
  x_msg_count          OUT   NOCOPY   NUMBER,
  x_msg_data           OUT   NOCOPY   VARCHAR2
);


END BSC_CALCULATIONS_PVT;

 

/
