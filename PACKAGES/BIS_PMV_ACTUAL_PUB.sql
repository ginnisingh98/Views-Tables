--------------------------------------------------------
--  DDL for Package BIS_PMV_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_ACTUAL_PUB" AUTHID CURRENT_USER as
/* $Header: BISPACLS.pls 115.12 2002/11/20 18:51:18 kiprabha noship $ */

PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_actual_attribute_code    IN  VARCHAR2
,p_compareto_attribute_code IN  VARCHAR2 DEFAULT NULL
,x_actual_value             OUT NOCOPY VARCHAR2
,x_compareto_value          OUT NOCOPY VARCHAR2
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);
PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_page_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_actual_attribute_code    IN  VARCHAR2
,p_compareto_attribute_code IN  VARCHAR2 DEFAULT NULL
,p_ranking_level            IN  VARCHAR2
,x_actual_value             OUT NOCOPY BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);
PROCEDURE GET_ACTUAL_VALUE
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_page_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,p_measure_attribute_codes  IN BIS_PMV_ACTUAL_PVT.MEASURE_ATTR_CODES_TYPE
,p_ranking_level            IN  VARCHAR2
,x_measure_tbl              OUT NOCOPY BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);

END BIS_PMV_ACTUAL_PUB;

 

/
