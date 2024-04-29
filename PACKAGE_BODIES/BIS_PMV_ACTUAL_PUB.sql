--------------------------------------------------------
--  DDL for Package Body BIS_PMV_ACTUAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_ACTUAL_PUB" as
/* $Header: BISPACLB.pls 115.14 2003/12/31 10:13:17 ksadagop noship $ */

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
) IS
BEGIN

BIS_PMV_ACTUAL_PVT.GET_ACTUAL_VALUE
(p_region_code => p_region_code
,p_function_name => p_function_name
,p_user_id => p_user_id
,p_responsibility_id => p_responsibility_id
,p_time_parameter => p_time_parameter
,p_parameters => p_parameters
,p_param_ids => p_param_ids
,p_actual_attribute_code => p_actual_attribute_code
,p_compareto_attribute_code => p_compareto_attribute_code
,x_actual_value => x_actual_value
,x_compareto_value => x_compareto_value
,x_return_status => x_return_status
,x_msg_count => x_msg_count
,x_msg_data => x_msg_data
);

END GET_ACTUAL_VALUE;
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
)
IS
  l_msg_data   varchar2(32767);
BEGIN
  --IF (fnd_profile.value('BIS_SQL_TRACE') = 'Y') then
     x_msg_data := 'Invoking Get Actual method.. *';
  --END IF;
  BIS_PMV_ACTUAL_PVT.GET_ACTUAL_VALUE
  (p_region_code => p_region_code
  ,p_function_name => p_function_name
  ,p_user_id => p_user_id
  ,p_page_id => p_page_id
  ,p_responsibility_id => p_responsibility_id
  ,p_time_parameter => p_time_parameter
  ,p_parameters => p_parameters
  ,p_param_ids => p_param_ids
  ,p_actual_attribute_code => p_actual_attribute_code
  ,p_compareto_attribute_code => p_compareto_attribute_code
  ,p_ranking_level => p_ranking_level
  ,x_actual_value => x_actual_value
  ,x_return_status => x_return_status
  ,x_msg_count => x_msg_count
  ,x_msg_data => l_msg_data
  );
  x_msg_data := x_msg_data || l_msg_data;
END;

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
) IS
BEGIN
  BIS_PMV_ACTUAL_PVT.GET_ACTUAL_VALUE
  (p_region_code => p_region_code
  ,p_function_name => p_function_name
  ,p_user_id => p_user_id
  ,p_page_id => p_page_id
  ,p_responsibility_id => p_responsibility_id
  ,p_time_parameter => p_time_parameter
  ,p_parameters => p_parameters
  ,p_param_ids => p_param_ids
  ,p_measure_attribute_codes => p_measure_attribute_codes
  ,p_ranking_level => p_ranking_level
  ,x_measure_tbl => x_measure_tbl
  ,x_return_status => x_return_status
  ,x_msg_count => x_msg_count
  ,x_msg_data => x_msg_data
  );
END;

END BIS_PMV_ACTUAL_PUB;

/
