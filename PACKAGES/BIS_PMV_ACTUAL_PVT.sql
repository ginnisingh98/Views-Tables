--------------------------------------------------------
--  DDL for Package BIS_PMV_ACTUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_ACTUAL_PVT" AUTHID CURRENT_USER as
/* $Header: BISVACLS.pls 115.14 2002/11/18 19:21:39 kiprabha noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

TYPE MEASURE_ATTR_CODES_TYPE IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

TYPE TIME_PARAMETER_REC_TYPE IS RECORD
(time_parameter_name    VARCHAR2(32000)
,time_from_id           VARCHAR2(32000)
,time_from_value        VARCHAR2(32000)
,time_to_id             VARCHAR2(32000)
,time_to_value          VARCHAR2(32000)
);

TYPE PARAMETER_REC_TYPE IS RECORD
(parameter_name		VARCHAR2(32000)
,parameter_id           VARCHAR2(32000)
,parameter_value        VARCHAR2(32000)
);

TYPE ACTUAL_VALUE_REC_TYPE IS RECORD
(view_by_value         VARCHAR2(32000)
,view_by_id            VARCHAR2(32000)
,measure_attribute_code VARCHAR2(32000)
,actual_value          NUMBER
,compare_to_value      NUMBER
,actual_grandtotal_value  NUMBER
,compareto_grandtotal_value NUMBER
);

TYPE ACTUAL_VALUE_TBL_TYPE IS TABLE OF ACTUAL_VALUE_REC_TYPE INDEX BY BINARY_INTEGER;

TYPE PARAMETER_TBL_TYPE IS TABLE OF PARAMETER_REC_TYPE INDEX BY BINARY_INTEGER;

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

PROCEDURE GET_ACTUAL_VALUE_PLSQL
(p_region_code     IN VARCHAR2
,p_function_name   IN VARCHAR2
,p_user_id         IN VARCHAR2
,p_responsibility_id IN VARCHAR2
,p_session_id        IN VARCHAR2
,p_actual_attribute_code IN VARCHAR2
,p_compare_to_attribute_code IN VARCHAR2
,x_actual_value             OUT NOCOPY VARCHAR2
,x_compareto_value           OUT NOCOPY VARCHAR2
,x_return_Status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY VARCHAR2
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

PROCEDURE STORE_PARAMETERS
(p_region_code              IN  VARCHAR2
,p_function_name            IN  VARCHAR2 DEFAULT NULL
,p_session_id               IN  VARCHAR2 DEFAULT NULL
,p_user_id                  IN  VARCHAR2 DEFAULT NULL
,p_responsibility_id        IN  VARCHAR2 DEFAULT NULL
,p_time_parameter           IN  BIS_PMV_ACTUAL_PVT.TIME_PARAMETER_REC_TYPE
,p_parameters               IN  BIS_PMV_ACTUAL_PVT.PARAMETER_TBL_TYPE
,p_param_ids                IN  VARCHAR2 DEFAULT 'N'
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE SETUP_BIND_VARIABLES
(p_bind_variables in varchar2
,x_bind_var_tbl  out NOCOPY BISVIEWER.t_char
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
,p_measure_attribute_codes  IN  BIS_PMV_ACTUAL_PVT.MEASURE_ATTR_CODES_TYPE
,p_ranking_level            IN  VARCHAR2
,x_measure_tbl              OUT NOCOPY BIS_PMV_ACTUAL_PVT.ACTUAL_VALUE_TBL_TYPE
,x_return_status            OUT NOCOPY VARCHAR2
,x_msg_count                OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE GET_CALCULATED_VALUE
(p_formula in varchar2
,p_measure_base_columns in BISVIEWER.t_char
,p_measure_values in BISVIEWER.t_char
,x_calculated_value out NOCOPY number
);

PROCEDURE SORTBY_BASE_COLUMN_LENGTH
(p_table1    in OUT    NOCOPY BISVIEWER.t_char
,p_table2    in OUT    NOCOPY BISVIEWER.t_char
,p_table3    in OUT    NOCOPY BISVIEWER.t_num
,x_return_status        OUT       NOCOPY VARCHAR2
,x_msg_count            OUT       NOCOPY NUMBER
,x_msg_data             OUT       NOCOPY VARCHAR2
);

END BIS_PMV_ACTUAL_PVT;

 

/
