--------------------------------------------------------
--  DDL for Package Body BSC_CALCULATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CALCULATIONS_PVT" AS
/* $Header: BSCVCLCB.pls 120.0.12000000.1 2007/07/17 07:44:32 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCVCLCB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      December 28, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Kishore Somesula                                        |
 |                                                                                      |
 | Description:                                                                         |
 |                      PRIVATE version.                                           |
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
)
IS

BEGIN
  IF (p_indicator IS NOT NULL AND p_calculation_id IS NOT NULL) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE bsc_kpi_calculations
    WHERE indicator = p_indicator
      AND calculation_id = p_calculation_id;

  END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE;
END delete_objective_calculation;




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
)
IS

BEGIN
  IF (p_indicator IS NOT NULL AND p_calculation_id IS NOT NULL) THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    INSERT
    INTO bsc_kpi_calculations(INDICATOR,
                              CALCULATION_ID,
                              USER_LEVEL0,
                              USER_LEVEL1,
                              USER_LEVEL1_DEFAULT,
                              USER_LEVEL2,
                              USER_LEVEL2_DEFAULT,
                              DEFAULT_VALUE)
    VALUES(p_indicator,
           p_calculation_id,
           p_user_level0,
           p_user_level1,
           p_user_level1_default,
           p_user_level2,
           p_user_level2_default,
           p_default_value
           );
  END IF;

EXCEPTION
    WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE;
END insert_objective_calculation;


END BSC_CALCULATIONS_PVT;

/
