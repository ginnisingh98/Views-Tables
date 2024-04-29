--------------------------------------------------------
--  DDL for Package BIS_PMV_SCHED_PARAMETERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_SCHED_PARAMETERS_PVT" AUTHID CURRENT_USER as
/* $Header: BISVSCPS.pls 120.1 2005/06/08 08:28:50 ashgarg noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.2=120.1):~PROD:~PATH:~FILE
G_ALL varchar2(3) := 'All';

procedure saveParameters
(pRegionCode       in varchar2,
 pFunctionName     in varchar2,
 pPageId           in Varchar2 default null,
 pSessionId        in Varchar2 default null,
 pUserId           in Varchar2 default null,
 pResponsibilityId in Varchar2 default null,
 pOrgParam         in number   default 0,
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
 pAsOfDateValue        in varchar2 default null,
 pAsOfDateMode         in varchar2 default null,
 pSaveByIds            in varchar2 default 'N',
 pScheduleId       in varchar2 default null,
 x_return_status    out NOCOPY VARCHAR2,
 x_msg_count	    out NOCOPY NUMBER,
 x_msg_data         OUT NOCOPY VARCHAR2
);
PROCEDURE CREATE_SCHEDULE_PARAMETERS
(p_user_param_tbl       IN      BIS_PMV_PARAMETERS_PVT.parameter_tbl_type
,p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,x_return_status        OUT  NOCOPY   VARCHAR2
,x_msg_count            OUT  NOCOPY   NUMBER
,x_msg_data             OUT  NOCOPY   VARCHAR2
);
PROCEDURE VALIDATE_AND_SAVE
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec        IN      OUT  NOCOPY BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status        OUT  NOCOPY   VARCHAR2
,x_msg_count            OUT  NOCOPY   NUMBER
,x_msg_data             OUT  NOCOPY   VARCHAR2
);
PROCEDURE CREATE_PARAMETER
(p_user_session_rec     IN      BIS_PMV_SESSION_PVT.session_rec_type
,p_parameter_rec        IN      BIS_PMV_PARAMETERS_PVT.parameter_rec_type
,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY  NUMBER
,x_msg_Data         OUT NOCOPY VARCHAR2
);
end;

 

/
