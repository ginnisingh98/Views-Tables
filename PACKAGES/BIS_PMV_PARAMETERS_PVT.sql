--------------------------------------------------------
--  DDL for Package BIS_PMV_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_PARAMETERS_PVT" AUTHID CURRENT_USER as
/* $Header: BISVPARS.pls 120.2 2006/03/27 12:53:21 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.49=120.2):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVPARS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Parameters Pkg. for PMV.				    |
REM |                                                                       |
REM | HISTORY                                                               |
REM | aleung, 09/21/2001, Initial Creation				    |
REM | nkishore, 12/10/2002, Added copy_ses_to_def_parameters	    	    |
REM | nkishore, 19/08/2003, BugFix 3099789 copy_time_params	    	    |
REM | nbarik    10/21/03    Bug Fix 3201277                                 |
REM | nbarik    02/19/04    Bug Fix 3441967                                 |
REM +=======================================================================+
*/

G_ALL varchar2(3) := 'All';
ROLLING_DIMENSION_DESCRIPTION VARCHAR2(18):= '~ROLLING_DIMENSION';

TYPE time_parameter_rec_type IS RECORD
(parameter_name		VARCHAR2(32000)
,parameter_label        VARCHAR2(32000)
,from_value 	        VARCHAR2(32000)
,to_value 	        VARCHAR2(32000)
,from_description       VARCHAR2(32000)
,to_description         VARCHAR2(32000)
,dimension              VARCHAR2(32000)
,from_period            DATE
,to_period              DATE
,org_name               VARCHAR2(32000)
,org_value              VARCHAR2(32000)
,required_flag          VARCHAR2(1)
,default_flag           VARCHAR2(1)
,id_flag		VARCHAR2(1)
);
TYPE time_parameter_tbl_type IS TABLE OF time_parameter_rec_type INDEX BY BINARY_INTEGER;

TYPE parameter_rec_type IS RECORD
(parameter_name		    VARCHAR2(32000)
,parameter_label        VARCHAR2(32000)
,parameter_value 	    VARCHAR2(32000)
,parameter_description  VARCHAR2(32000)
,operator               VARCHAR2(32000)
,dimension              VARCHAR2(32000)
,lov_where              VARCHAR2(2000)
,period_date            DATE
,required_flag          VARCHAR2(1)
,default_flag           VARCHAR2(1)
,hierarchy_flag         VARCHAR2(1)
,id_flag		VARCHAR2(1)
);
TYPE parameter_tbl_type IS TABLE OF parameter_rec_type INDEX BY BINARY_INTEGER;

TYPE parameter_group_rec_type IS RECORD
(
 parameter_number NUMBER
, dimension VARCHAR2(80)
, attribute_name VARCHAR2(80)
-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
, lov_where VARCHAR2(150)
);
TYPE parameter_group_tbl_type IS TABLE OF parameter_group_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE COPY_REMAINING_DEF_PARAMETERS
(pFunctionName      IN	VARCHAR2
,pUserId            IN	VARCHAR2
,pSessionId         IN  VARCHAR2
,x_return_status    OUT	NOCOPY VARCHAR2
,x_msg_count	    OUT	NOCOPY NUMBER
,x_msg_data	    OUT	NOCOPY VARCHAR2
) ;

--nkishore Customize UI Copy to Default Parameters
PROCEDURE COPY_SES_TO_DEF_PARAMETERS
(pFunctionName      IN	VARCHAR2
,pUserId         	IN	VARCHAR2
,pSessionId         IN  VARCHAR2
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_AND_SAVE
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_AND_SAVE_TIME
(p_user_session_rec	  IN  BIS_PMV_SESSION_PVT.session_rec_type
,p_time_parameter_rec IN OUT NOCOPY BIS_PMV_PARAMETERS_PVT.time_parameter_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_NONTIME_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_valid		    OUT	NOCOPY VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_TIME_PARAMETER
(p_user_session_rec	    IN  BIS_PMV_SESSION_PVT.session_rec_type
,p_time_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.time_parameter_rec_type
,x_valid		        OUT NOCOPY VARCHAR2
,x_return_status	    OUT NOCOPY VARCHAR2
,x_msg_count		    OUT NOCOPY NUMBER
,x_msg_data		        OUT NOCOPY VARCHAR2
);

PROCEDURE DECODE_ID_VALUE
(p_code   IN VARCHAR2
,p_index  IN NUMBER
,x_id    OUT NOCOPY VARCHAR2
,x_value OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec	IN	BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_Data         OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PARAMETER
(p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);


PROCEDURE RETRIEVE_PAGE_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_schedule_id          IN  NUMBER
,p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_page_dims            IN  BISVIEWER.t_char
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_KPI_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_user_session_rec	IN  BIS_PMV_SESSION_PVT.Session_rec_type
,p_user_dims        IN  BISVIEWER.t_char
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
) ;

PROCEDURE RETRIEVE_SCHEDULE_PARAMETER
(p_parameter_rec	IN  OUT NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,p_schedule_id      IN  NUMBER
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);

PROCEDURE DELETE_PARAMETER
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_name	IN	VARCHAR2
,p_schedule_option  IN  VARCHAR2
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
);

PROCEDURE DELETE_SCHEDULE_PARAMETER
(p_parameter_name	IN	VARCHAR2
,p_schedule_id      IN  NUMBER
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);

PROCEDURE CREATE_SESSION_PARAMETERS
(p_user_param_tbl	IN	BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PAGE_PARAMETERS
(p_schedule_id	    IN	NUMBER
,p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_KPI_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_PARAMLVL_PARAMETERS
(p_user_session_Rec             IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_paramportlet_param_tbl       OUT     NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_Type
,x_return_status                OUT     NOCOPY VARCHAR2
,x_msg_count                    OUT     NOCOPY NUMBER
,x_msg_data                     OUT     NOCOPY VARCHAR2
);
PROCEDURE RETRIEVE_SCHEDULE_PARAMETERS
(p_schedule_id	        IN	NUMBER
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_SESSION_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE RETRIEVE_DEFAULT_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_user_param_tbl	OUT	NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE DELETE_SESSION_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,p_schedule_option      IN      VARCHAR2
,x_return_Status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
);

PROCEDURE DELETE_PAGE_PARAMETERS
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT     NOCOPY VARCHAR2
,x_msg_count            OUT     NOCOPY NUMBER
,x_msg_data             OUT     NOCOPY VARCHAR2
);

PROCEDURE DELETE_DEFAULT_PARAMETERS
(p_user_session_rec	IN	BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		OUT	NOCOPY VARCHAR2
);

PROCEDURE DELETE_SCHEDULE_PARAMETERS
(p_schedule_id      IN  NUMBER
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data	        OUT NOCOPY VARCHAR2
);

PROCEDURE GET_NONTIME_VALIDATED_ID
(p_parameter_name         in  varchar2
,p_parameter_value        in  varchar2
,p_lov_where              in  varchar2 default null
,p_region_code            in  varchar2
,p_responsibility_id      in  varchar2
,x_parameter_description  out NOCOPY varchar2
,x_return_status	  OUT NOCOPY VARCHAR2
,x_msg_count		  OUT NOCOPY NUMBER
,x_msg_data	          OUT NOCOPY VARCHAR2
);

PROCEDURE GET_NONTIME_VALIDATED_VALUE
(p_parameter_name         in varchar2
,p_parameter_description  in varchar2
,p_lov_where              in  varchar2 default null
,p_region_code            in varchar2
,p_responsibility_id      in varchar2
,x_parameter_value       out NOCOPY varchar2
,x_return_status	 OUT NOCOPY VARCHAR2
,x_msg_count		 OUT NOCOPY NUMBER
,x_msg_data	         OUT NOCOPY VARCHAR2
);

PROCEDURE GET_TIME_VALIDATED_ID
(p_parameter_name        IN  VARCHAR2
,p_parameter_value       in  varchar2
,p_region_code           in  varchar2
,p_org_name              in  varchar2
,p_org_value             in  varchar2
,p_responsibility_id     in  varchar2
,x_parameter_description out NOCOPY varchar2
,x_start_date            out NOCOPY date
,x_end_date              out NOCOPY date
,x_return_status	 OUT NOCOPY VARCHAR2
,x_msg_count		 OUT NOCOPY NUMBER
,x_msg_data	         OUT NOCOPY VARCHAR2
);

PROCEDURE GET_TIME_VALIDATED_VALUE
(p_parameter_name         IN  VARCHAR2
,p_parameter_description  in  varchar2
,p_region_code            in  varchar2
,p_org_name               in  varchar2
,p_org_value              in  varchar2
,p_responsibility_id      in  varchar2
,x_parameter_value        out NOCOPY varchar2
,x_start_date             out NOCOPY date
,x_end_date               out NOCOPY date
,x_return_status          OUT NOCOPY VARCHAR2
,x_msg_count		  OUT NOCOPY NUMBER
,x_msg_data	          OUT NOCOPY VARCHAR2
);

PROCEDURE GET_TIME_INFO
(p_region_code            in  varchar2
,p_responsibility_id      in  varchar2
,p_parameter_name         in  varchar2
,p_mode                   in  varchar2
,p_date                   in  varchar2
,x_time_description       out NOCOPY varchar2
,x_time_id                out NOCOPY varchar2
,x_start_date             out NOCOPY date
,x_end_date               out NOCOPY date
,x_return_status          OUT NOCOPY VARCHAR2
,x_msg_count              OUT NOCOPY NUMBER
,x_msg_data               OUT NOCOPY VARCHAR2
);

PROCEDURE getLOVSQL
(p_parameter_name  in varchar2
,p_parameter_description       in varchar2
,p_sql_type               in varchar2 default null
,p_region_code            in varchar2
,p_responsibility_id        in varchar2
,x_sql_statement         out NOCOPY varchar2
,x_bind_sql              out NOCOPY varchar2
,x_bind_variables        out NOCOPY varchar2
,x_bind_count            out NOCOPY number
,x_return_status	OUT	NOCOPY VARCHAR2
,x_msg_count		OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE getTimeLovSql
(p_parameter_name in varchar2
,p_parameter_description in varchar2
,p_sql_type              in varchar2 default null
,p_date                  in varchar2 default null
,p_region_code           in varchar2
,p_responsibility_id     in varchar2
,p_org_name              in varchar2
,p_org_value             in varchar2
,x_sql_statement         out NOCOPY varchar2
,x_bind_sql              out NOCOPY varchar2
,x_bind_variables        out NOCOPY varchar2
,x_bind_count            out NOCOPY number
,x_return_status	OUT NOCOPY VARCHAR2
,x_msg_count		OUT NOCOPY NUMBER
,x_msg_data		OUT NOCOPY VARCHAR2
);

procedure saveParameters
(pRegionCode       in varchar2,
 pFunctionName     in varchar2,
 pPageId           in Varchar2 default null,
 pSessionId        in Varchar2 default null,
 pUserId           in Varchar2 default null,
 pResponsibilityId in Varchar2 default null,
 pApplicationId	   in Varchar2 default null,
 pOrgParam         in number   default 0,
 pHierarchy1 in varchar2 default null,
 pHierarchy2 in varchar2 default null,
 pHierarchy3 in varchar2 default null,
 pHierarchy4 in varchar2 default null,
 pHierarchy5 in varchar2 default null,
 pHierarchy6 in varchar2 default null,
 pHierarchy7 in varchar2 default null,
 pHierarchy8 in varchar2 default null,
 pHierarchy9 in varchar2 default null,
 pHierarchy10 in varchar2 default null,
 pHierarchy11 in varchar2 default null,
 pHierarchy12 in varchar2 default null,
 pHierarchy13 in varchar2 default null,
 pHierarchy14 in varchar2 default null,
 pHierarchy15 in varchar2 default null,
 pParameter1       in varchar2 default null,
 pParameterValue1  in varchar2 default null,
 pParameter2       in varchar2 default null,
 pParameterValue2  in varchar2 default null,
 pParameter3       in varchar2 default null,
 pParameterValue3  in varchar2 default null,
 pParameter4       in varchar2 default null,
 pParameterValue4  in varchar2 default null,
 pParameter5       in varchar2 default null,
 pParameterValue5  in varchar2 default null,
 pParameter6       in varchar2 default null,
 pParameterValue6  in varchar2 default null,
 pParameter7       in varchar2 default null,
 pParameterValue7  in varchar2 default null,
 pParameter8       in varchar2 default null,
 pParameterValue8  in varchar2 default null,
 pParameter9       in varchar2 default null,
 pParameterValue9  in varchar2 default null,
 pParameter10      in varchar2 default null,
 pParameterValue10 in varchar2 default null,
 pParameter11      in varchar2 default null,
 pParameterValue11 in varchar2 default null,
 pParameter12      in varchar2 default null,
 pParameterValue12 in varchar2 default null,
 pParameter13      in varchar2 default null,
 pParameterValue13 in varchar2 default null,
 pParameter14      in varchar2 default null,
 pParameterValue14 in varchar2 default null,
 pParameter15      in varchar2 default null,
 pParameterValue15 in varchar2 default null,
 pTimeParameter    in varchar2 default null,
 pTimeFromParameter in varchar2 default null,
 pTimeToParameter  in varchar2 default null,
 pViewByValue	   in varchar2 default null,
 pAddToDefault     in varchar2 default null,
 pParameter1Name   in varchar2 default null,
 pParameter2Name   in varchar2 default null,
 pParameter3Name   in varchar2 default null,
 pParameter4Name   in varchar2 default null,
 pParameter5Name   in varchar2 default null,
 pParameter6Name   in varchar2 default null,
 pParameter7Name   in varchar2 default null,
 pParameter8Name   in varchar2 default null,
 pParameter9Name   in varchar2 default null,
 pParameter10Name   in varchar2 default null,
 pParameter11Name   in varchar2 default null,
 pParameter12Name   in varchar2 default null,
 pParameter13Name   in varchar2 default null,
 pParameter14Name   in varchar2 default null,
 pParameter15Name   in varchar2 default null,
 pTimeParamName      in varchar2 default null,
 pParameterOperator1   in varchar2 default null,
 pParameterOperator2   in varchar2 default null,
 pParameterOperator3   in varchar2 default null,
 pParameterOperator4   in varchar2 default null,
 pParameterOperator5   in varchar2 default null,
 pParameterOperator6   in varchar2 default null,
 pParameterOperator7   in varchar2 default null,
 pParameterOperator8   in varchar2 default null,
 pParameterOperator9   in varchar2 default null,
 pParameterOperator10  in varchar2 default null,
 pParameterOperator11  in varchar2 default null,
 pParameterOperator12  in varchar2 default null,
 pParameterOperator13  in varchar2 default null,
 pParameterOperator14  in varchar2 default null,
 pParameterOperator15  in varchar2 default null,
 pRequired1 	       in varchar2 default null,
 pRequired2 	       in varchar2 default null,
 pRequired3 	       in varchar2 default null,
 pRequired4 	       in varchar2 default null,
 pRequired5 	       in varchar2 default null,
 pRequired6 	       in varchar2 default null,
 pRequired7 	       in varchar2 default null,
 pRequired8 	       in varchar2 default null,
 pRequired9 	       in varchar2 default null,
 pRequired10	       in varchar2 default null,
 pRequired11	       in varchar2 default null,
 pRequired12	       in varchar2 default null,
 pRequired13	       in varchar2 default null,
 pRequired14	       in varchar2 default null,
 pRequired15	       in varchar2 default null,
 pTimeRequired	       in varchar2 default null,
 pLovWhere1            in varchar2 default null,
 pLovWhere2            in varchar2 default null,
 pLovWhere3            in varchar2 default null,
 pLovWhere4            in varchar2 default null,
 pLovWhere5            in varchar2 default null,
 pLovWhere6            in varchar2 default null,
 pLovWhere7            in varchar2 default null,
 pLovWhere8            in varchar2 default null,
 pLovWhere9            in varchar2 default null,
 pLovWhere10           in varchar2 default null,
 pLovWhere11           in varchar2 default null,
 pLovWhere12           in varchar2 default null,
 pLovWhere13           in varchar2 default null,
 pLovWhere14           in varchar2 default null,
 pLovWhere15           in varchar2 default null,
 pAsOfDateValue        in varchar2 default null,
 pAsOfDateMode         in varchar2 default null,
 pSaveByIds            in varchar2 default 'N',
 x_return_status    out NOCOPY VARCHAR2,
 x_msg_count	    out NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE getParameterGroupsForRegion(
  pRegionCode IN VARCHAR2,
  xParameterGroup OUT NOCOPY parameter_group_tbl_type,
  xTCTExists OUT NOCOPY BOOLEAN,
  xNestedRegion OUT NOCOPY VARCHAR2,
  xAsofDateExists OUT NOCOPY BOOLEAN
) ;

PROCEDURE getAttrNamesInSameGroup (
 pAttributeName IN VARCHAR2,
 pDimension IN VARCHAR2,
 pParameterGroup IN parameter_group_tbl_type,
 xAttNameList OUT NOCOPY BISVIEWER.t_char
) ;

PROCEDURE deletePageForGroup(
 pUserId             in varchar2,
 pFunctionName       in varchar2,
 pPageId             in varchar2,
 pAttrNameList IN BISVIEWER.t_char,
 pDimension IN VARCHAR2
) ;

PROCEDURE deleteSessionForGroup(
 pSessionId          in varchar2,
 pUserId             in varchar2,
 pFunctionName       in varchar2,
 pAttrNameList IN BISVIEWER.t_char,
 pDimension IN VARCHAR2
) ;

PROCEDURE overRideFromSchedule(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pScheduleId         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) ;
-- nbarik - 02/19/04 - BugFix 3441967 - Added x_IsPreFuncTCTExists and x_IsPreFuncCalcDatesExists
PROCEDURE overRideFromPreFunction(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pPreFunctionName         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type,
                          pTCTExists      in boolean default false
                         , x_IsPreFuncTCTExists OUT NOCOPY BOOLEAN
                         , x_IsPreFuncCalcDatesExists OUT NOCOPY BOOLEAN
) ;

PROCEDURE overRideFromPage(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pPageId         in varchar2 default null,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) ;

PROCEDURE overRideFromSavedDefault(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                          pRespId         in  varchar2 default null,
                          pParameterGroup IN parameter_group_tbl_type
) ;

PROCEDURE COPY_FORM_FUNCTION_PARAMETERS
(pRegionCode       IN VARCHAR2
,pFunctionName      IN	VARCHAR2
,pUserId           IN	VARCHAR2
,pSessionId        IN  VARCHAR2
,pResponsibilityId in varchar2 default NULL
,pNestedRegionCode in varchar2 default NULL
,pAsofdateExists   in boolean default NULL
,x_return_status   OUT	NOCOPY VARCHAR2
,x_msg_count	     OUT	NOCOPY NUMBER
,x_msg_data	       OUT	NOCOPY VARCHAR2
) ;

 -- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added xGraphFileId
PROCEDURE RETRIEVE_GRAPH_FILEID(p_user_id in varchar2,
                                p_schedule_id in varchar2,
                                p_attribute_name in varchar2,
                                p_function_name in varchar2,
                                x_graph_file_id out NOCOPY varchar2);

 -- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added xGraphFileId
PROCEDURE SAVE_GRAPH_FILEID(p_user_id in varchar2,
                            p_schedule_id in varchar2,
                            p_attribute_name in varchar2,
                            p_function_name in varchar2,
                            p_graph_file_id in varchar2);

-- jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
PROCEDURE RETRIEVE_CONTEXT_VALUES(p_user_id in varchar2,
                                  p_schedule_id in varchar2,
                                  p_attribute_name in varchar2,
                                  p_function_name in varchar2,
                                  x_context_values out NOCOPY varchar2);

-- jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
PROCEDURE SAVE_CONTEXT_VALUES(p_user_id in varchar2,
                              p_schedule_id in varchar2,
                              p_attribute_name in varchar2,
                              p_function_name in varchar2,
                              p_context_values in varchar2);

function GET_LOV_WHERE(p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                       p_where_clause in VARCHAR2,
                       p_user_session_rec IN BIS_PMV_SESSION_PVT.session_rec_type) return varchar2;


PROCEDURE copyParamtersBetweenPages(
  pSessionId IN VARCHAR2,
  pFromPageId IN VARCHAR2,
  pToPageId IN VARCHAR2,
  pUserId IN VARCHAR2,
  xParamRegionCode OUT NOCOPY VARCHAR2,
  xParamFunctionName OUT NOCOPY VARCHAR2,
  xParamGroup  OUT NOCOPY parameter_group_tbl_type,
  -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
  x_DrillDefaultParameters OUT NOCOPY VARCHAR2,
  x_return_status    OUT	NOCOPY VARCHAR2,
  x_msg_count	    OUT	NOCOPY NUMBER,
  x_msg_data	    OUT	NOCOPY VARCHAR2
);


procedure executeLovBindSQL
(p_bind_sql  in varchar2
,p_bind_variables in varchar2
,p_time_flag      in varchar2
,x_parameter_id             out NOCOPY varchar2
,x_parameter_value          out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status            OUT     NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data                 OUT NOCOPY VARCHAR2
);

procedure executeLovDynamicSQL
(p_bind_sql  in varchar2
,p_bind_values in BISVIEWER.t_char
,p_time_flag      in varchar2
,x_parameter_id             out NOCOPY varchar2
,x_parameter_value          out NOCOPY varchar2
,x_start_date               out NOCOPY date
,x_end_date                 out NOCOPY date
,x_return_status	    OUT     NOCOPY VARCHAR2
,x_msg_count	    OUT	NOCOPY NUMBER
,x_msg_data		    OUT	NOCOPY VARCHAR2
);

PROCEDURE copyParamsFromReportToPage(
  pFunctionName IN VARCHAR2,
  pSessionId IN VARCHAR2,
  pUserId IN VARCHAR2,
  pToPageId IN VARCHAR2,
  xParamRegionCode OUT NOCOPY VARCHAR2,
  xParamFunctionName OUT NOCOPY VARCHAR2,
  xParamGroup OUT NOCOPY parameter_group_tbl_type,
  -- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
  x_DrillDefaultParameters OUT NOCOPY VARCHAR2,
  x_return_status    OUT	NOCOPY VARCHAR2,
  x_msg_count	    OUT	NOCOPY NUMBER,
  x_msg_data	    OUT	NOCOPY VARCHAR2
) ;

PROCEDURE COMPUTE_AND_SAVE_DATES(
    pTimeAttribute IN VARCHAR2,
    pTimeComparisonType IN VARCHAR2,
    p_user_Session_rec	BIS_PMV_SESSION_PVT.session_rec_type,
    x_time_level_id OUT NOCOPY VARCHAR2,
    x_time_level_value OUT NOCOPY VARCHAR2
);

--BugFix 3099789
--nbarik - 10/21/03 - Bug Fix 3201277 - Added x_time_attribute
-- nbarik - 02/19/04 - BugFix 3441967 - Added p_IsPreFuncTCTExists, p_IsPreFuncCalcDatesExists
PROCEDURE COPY_TIME_PARAMS(pSessionId          in varchar2,
                           pUserId             in varchar2,
                           pFunctionName       in varchar2,
                           pRegionCode         in varchar2,
                           pRespId         in  varchar2 default null,
                           pParameterGroup IN parameter_group_tbl_type,
                           pTCTExists      in boolean default false,
                           p_IsPreFuncTCTExists IN BOOLEAN DEFAULT TRUE,
                           p_IsPreFuncCalcDatesExists IN BOOLEAN DEFAULT TRUE,
                           x_time_attribute OUT NOCOPY VARCHAR2
);
--Pass as of date as Date--3094234
PROCEDURE UPDATE_COMPUTED_DATES(
            p_user_id                             IN NUMBER,
            p_page_id                            IN NUMBER,
	p_function_name                  IN VARCHAR2,
	p_time_comparison_type       IN VARCHAR2,
	p_asof_date                         IN DATE,
	p_time_level                         IN VARCHAR2,
	x_prev_asof_Date                 OUT NOCOPY DATE,
	x_curr_report_Start_date       OUT NOCOPY DATE,
	x_prev_report_Start_date       OUT NOCOPY DATE,
	x_curr_effective_start_date    OUT NOCOPY DATE,
	x_curr_effective_end_date      OUT NOCOPY DATE,
	x_time_level_id                     OUT NOCOPY VARCHAR2,
	x_time_level_value                OUT NOCOPY VARCHAR2,
            x_prev_effective_start_date    OUT NOCOPY DATE,
            x_prev_effective_end_date     OUT NOCOPY DATE,
            x_prev_time_level_id             OUT NOCOPY VARCHAR2,
            x_prev_time_level_value        OUT NOCOPY VARCHAR2,
	x_prev_asof_Date_char                 OUT NOCOPY VARCHAR2,
	x_curr_report_Start_date_char       OUT NOCOPY VARCHAR2,
	x_prev_report_Start_date_char       OUT NOCOPY VARCHAR2,
	x_curr_eff_start_date_char    OUT NOCOPY VARCHAR2,
	x_curr_eff_end_date_char      OUT NOCOPY VARCHAR2,
            x_prev_eff_start_date_char    OUT NOCOPY VARCHAR2,
            x_prev_eff_end_date_char     OUT NOCOPY VARCHAR2,
	x_return_status                   OUT NOCOPY VARCHAR2,
        p_plug_id                             IN NUMBER DEFAULT 0
	);


--nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
FUNCTION GET_DELEGATION_VALIDATED_VALUE(
  pDelegationParam IN VARCHAR2
, pRegionCode      IN VARCHAR2
) RETURN VARCHAR2;

END BIS_PMV_PARAMETERS_PVT;

 

/
