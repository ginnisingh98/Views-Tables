--------------------------------------------------------
--  DDL for Package BIS_PMV_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PARAMETERS_PUB" AUTHID CURRENT_USER as
/* $Header: BISPPARS.pls 120.3 2006/05/11 10:05:07 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.6=120.3):~PROD:~PATH:~FILE

SQL_STRING VARCHAR2(200) := 'SQL';
VIEW_BY_VALUE VARCHAR2(200) := 'VIEW_BY_VALUE';
INTEGER_BIND    NUMBER := 1;
VARCHAR2_BIND   NUMBER := 2;
DATE_BIND       NUMBER := 3;
NUMERIC_BIND    NUMBER := 4;
CHARACTER_BIND  NUMBER := 5;
MESSAGE_BIND    NUMBER := 6;

BIND_TYPE            NUMBER :=1;
SQL_STRING_TYPE      NUMBER :=2;
VIEW_BY_TYPE         NUMBER :=3;

TYPE page_session_rec_type IS RECORD
(user_id                VARCHAR2(32000)
,page_id                VARCHAR2(32000)
,session_id             VARCHAR2(32000)
,responsibility_id      VARCHAR2(32000)
);

TYPE parameter_rec_type IS RECORD
(parameter_name	        VARCHAR2(32000)
,parameter_label        VARCHAR2(32000)
,parameter_value        VARCHAR2(32000)
,parameter_description  VARCHAR2(32000)
,operator               VARCHAR2(32000)
,dimension              VARCHAR2(32000)
,period_date            DATE
,required_flag          VARCHAR2(1)
,default_flag           VARCHAR2(1)
,hierarchy_flag         VARCHAR2(1)
);
TYPE parameter_tbl_type IS TABLE OF parameter_rec_type INDEX BY
BINARY_INTEGER;

PROCEDURE RETRIEVE_PAGE_PARAMETER
(p_page_session_rec     IN  BIS_PMV_PARAMETERS_PUB.page_session_rec_type
,p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PUB.parameter_rec_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PAGE_PARAMETERS
(p_page_session_rec     IN  BIS_PMV_PARAMETERS_PUB.page_session_rec_type
,x_page_param_tbl	OUT NOCOPY BIS_PMV_PARAMETERS_PUB.parameter_tbl_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data		OUT NOCOPY VARCHAR2
);
FUNCTION INITIALIZE_QUERY_TYPE

RETURN BIS_QUERY_ATTRIBUTES;

/* nbarik - 05/11/06 - Bug Fix 4881596
--
-- This is a public API which will be called by product teams to clear
-- user level personalization
--
*/
PROCEDURE CLEAR_USER_PERSONALIZATION (
	p_function_name			IN  VARCHAR2
,	p_region_code           IN  VARCHAR2
, 	p_region_application_id IN 	NUMBER
,	x_return_status	    	OUT NOCOPY VARCHAR2
,	x_msg_count		    	OUT NOCOPY NUMBER
,	x_msg_data	        	OUT NOCOPY VARCHAR2
);

FUNCTION INITIALIZE_BIS_BUCKET_REC RETURN BIS_BUCKET_REC;
END BIS_PMV_PARAMETERS_PUB;

 

/
