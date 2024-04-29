--------------------------------------------------------
--  DDL for Package BSC_CALCULATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CALCULATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCLCS.pls 120.1.12000000.1 2007/07/17 07:43:46 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCLCS.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      December 28, 2006                                               |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Kishore Somesula                                        |
 |                                                                                      |
 | Description:                                                                         |
 |                      Public Specs version.                                           |
 |      This package handles calculations                                               |
 |                                                                                      |
 +======================================================================================+
*/

PROCEDURE save_obj_calculations(
  p_obj_id         IN             NUMBER
, p_params         IN             VARCHAR2
, p_ytd_as_default IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
);

PROCEDURE save_ytd_as_default_calc(
  p_obj_id         IN             NUMBER
, p_ytd_as_default IN             VARCHAR2
, p_commit         IN             VARCHAR2 := FND_API.G_FALSE
, x_return_status  OUT   NOCOPY   VARCHAR2
, x_msg_count      OUT   NOCOPY   NUMBER
, x_msg_data       OUT   NOCOPY   VARCHAR2
);


PROCEDURE save_user_wizard_calculations
(p_tab_id                 IN                 NUMBER
,p_obj_id                 IN                 NUMBER
,p_calcs_list             IN                 VARCHAR2
,p_commit                 IN                 VARCHAR2 := FND_API.G_FALSE
,x_return_status          OUT     NOCOPY     VARCHAR2
,x_msg_count              OUT     NOCOPY     NUMBER
,x_msg_data               OUT     NOCOPY     VARCHAR2
);

FUNCTION is_balance_measure(
  p_kpi_measure_id           IN    NUMBER
) RETURN VARCHAR2 ;

FUNCTION is_YTD_enabled_in_def_measure(
  p_obj_id           IN    NUMBER
) RETURN VARCHAR2;

FUNCTION is_calculation_default(
  p_obj_id           IN    NUMBER
 ,p_cal_id           IN    NUMBER
) RETURN VARCHAR2;

FUNCTION Is_Dataset_Balance_Type(
  p_dataset_id           IN    NUMBER
) RETURN VARCHAR2;

FUNCTION Is_Calculation_Enabled(
  p_dataset_id     IN NUMBER
 ,p_calculation_id IN NUMBER
) RETURN VARCHAR2  ;

END BSC_CALCULATIONS_PUB;

 

/
