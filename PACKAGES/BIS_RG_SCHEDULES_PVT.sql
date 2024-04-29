--------------------------------------------------------
--  DDL for Package BIS_RG_SCHEDULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RG_SCHEDULES_PVT" AUTHID CURRENT_USER as
/* $Header: BISVSCHS.pls 120.0.12000000.3 2007/02/06 07:46:49 akoduri ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.24=120.0.12000000.3):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_SCHEDULE_PVT
--                                                                        --
--  DESCRIPTION:  Private package to create records in BIS_SCHEDULER
--
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  02-25-00   amkulkar   Initial creation                                --
--  07-03-01   mdamle	  Scheduling Enhancements			  --
--  09/04/01   mdamle     Scheduling Enhancements - Phase II - Multiple   --
--	                  Preferences per schedule			  --
--  09/19/01   mdamle	  Trap File_ID creation error			  --
--  12/12/01   mdamle     Changes for Live Portlet			  --
--  12/27/01   mdamle     Added updateTitleInPortal			  --
--  01/16/02   mdamle     Added updateExternalSource			  --
--  12/10/02   nkishore   Added creating_schedule, updating_schedule      --
--  01/25/07   akoduri    Bug#5752469  Issue with Cancel & Apply buttons  --
--                        in portal                                       --
--  02/06/07   akoduri    GSCC Error while building R12 ARU               --
----------------------------------------------------------------------------
PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER   DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 DEFAULT NULL
,p_graph_type   		IN      NUMBER   DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER   DEFAULT NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT 	NOCOPY NUMBER
,p_Request_Type			IN	VARCHAR2  DEFAULT NULL
,x_Schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2  DEFAULT 'N'
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL

);

/* serao, 06/03, This creates a schedule for the create schedule call with the same signature but does not do a commit.
   Called by Related Links Functionality
   */
PROCEDURE  CREATE_SCHEDULE_NO_COMMIT
(p_plug_id 			IN	NUMBER   DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 DEFAULT NULL
,p_graph_type   		IN      NUMBER   DEFAULT NULL
,p_request_type			IN	VARCHAR2 DEFAULT NULL
,x_schedule_id                  OUT     NOCOPY NUMBER
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,x_file_id			OUT	NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2 DEFAULT 'N'
);

PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER   DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2 DEFAULT NULL
,p_graph_type   		IN      NUMBER   DEFAULT NULL
,p_Request_Type			IN	VARCHAR2  DEFAULT NULL
,x_Schedule_id   		OUT  	NOCOPY NUMBER
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,x_file_id			OUT	NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2 DEFAULT 'N'
);
PROCEDURE  CREATE_SCHEDULE
(p_plug_id 			IN	NUMBER    DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2  DEFAULT NULL
,p_graph_type   		IN      NUMBER    DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER    DEFAULT NULL
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT  NOCOPY NUMBER
,p_session_id			IN      VARCHAR2  DEFAULT NULL
,p_report_region_code           IN 	VARCHAR2  DEFAULT NULL
,p_Request_Type			IN	VARCHAR2  DEFAULT NULL
,x_Schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
-- mdamle 12/12/01 - Changes for Live Portlet
,p_live_portlet			IN	VARCHAR2  DEFAULT 'N'
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL
);

--nkishore Customize UI Enhancement Creating Schedule
PROCEDURE  CREATING_SCHEDULE
(p_plug_id 			IN	NUMBER    DEFAULT NULL
,p_user_id      		IN      VARCHAR2
,p_function_name		IN      VARCHAR2
,p_responsibility_id            IN      VARCHAR2
,p_title        		IN      VARCHAR2  DEFAULT NULL
,p_graph_type   		IN      NUMBER    DEFAULT NULL
,p_concurrent_request_id   	IN   	NUMBER    DEFAULT NULL
  -- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,p_file_id      		IN OUT  NOCOPY NUMBER
,p_session_id			IN      VARCHAR2  DEFAULT NULL
,p_report_region_code           IN 	VARCHAR2  DEFAULT NULL
,p_Request_Type			IN	VARCHAR2  DEFAULT NULL
,x_Schedule_id                  OUT     NOCOPY NUMBER
,x_return_Status 		OUT     NOCOPY VARCHAR2
,x_msg_Data    			OUT     NOCOPY VARCHAR2
,x_msg_count    		OUT     NOCOPY NUMBER
--jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters
,p_context_values  	        IN	VARCHAR2  DEFAULT NULL
);

PROCEDURE UPDATE_SCHEUDLE
(p_schedule_id                 IN       NUMBER
,p_user_id                     IN       VARCHAR2  DEFAULT NULL
,p_function_name               IN       VARCHAR2  DEFAULT NULL
,p_title                       IN       VARCHAR2  DEFAULT NULL
,p_graph_type                  IN       NUMBER    DEFAULT NULL
,p_concurrent_Request_id       IN       NUMBER    DEFAULT NULL
,p_file_id                     IN       NUMBER    DEFAULT NULL
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
-- mdamle 07/03/01 - Scheduling Enhancements
,p_parameters		       IN	VARCHAR2 default null
);

--nkishore Customize UI Enhancement Updating Schedule
PROCEDURE UPDATING_SCHEDULE
(p_schedule_id                 IN       NUMBER
,p_user_id                     IN       VARCHAR2
,p_function_name               IN       VARCHAR2
,p_session_id                  IN       VARCHAR2
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
);

PROCEDURE UPDATE_SCHEDULE
(p_schedule_id                 IN       NUMBER
,p_concurrent_Request_id       IN       NUMBER
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_Data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
-- mdamle 07/03/01 - Scheduling Enhancements
,p_parameters		       IN	VARCHAR2 default null
,p_commit		       IN       VARCHAR2 DEFAULT 'Y'
);

FUNCTION GET_FILE_ID
(p_request_Type in VARCHAR2)
RETURN NUMBER;
PROCEDURE IS_SCHEDULED
(p_user_id			IN	VARCHAR2
,p_function_name		IN	VARCHAR2
,p_report_region_code		IN	VARCHAR2  DEFAULT NULL
,p_session_id			IN	VARCHAR2  DEFAULT NULL
,p_parameter1			IN	VARCHAR2  DEFAULT NULL
,p_parameter2			IN	VARCHAR2  DEFAULT NULL
,p_parameter3			IN	VARCHAR2  DEFAULT NULL
,p_parameter4			IN	VARCHAR2  DEFAULT NULL
,p_parameter5			IN	VARCHAR2  DEFAULT NULL
,p_parameter6			IN	VARCHAR2  DEFAULT NULL
,p_parameter7			IN	VARCHAR2  DEFAULT NULL
,p_parameter8			IN	VARCHAR2  DEFAULT NULL
,p_parameter9			IN	VARCHAR2  DEFAULT NULL
,p_parameter10			IN	VARCHAR2  DEFAULT NULL
,p_parameter11			IN	VARCHAR2  DEFAULT NULL
,p_parameter12			IN	VARCHAR2  DEFAULT NULL
,p_parameter13			IN	VARCHAR2  DEFAULT NULL
,p_parameter14			IN	VARCHAR2  DEFAULT NULL
,p_parameter15			IN	VARCHAR2  DEFAULT NULL
,p_timetoparameter		IN	VARCHAR2  DEFAULT NULL
,p_timefromparameter		IN	VARCHAR2  DEFAULT NULL
,p_viewby			IN	VARCHAR2  DEFAULT NULL
,x_Scheduled			OUT	NOCOPY VARCHAR2
);
PROCEDURE SAVE_COMPONENT
(p_file_id			IN	NUMBER
,p_Request_Type			IN	VARCHAR2
);

PROCEDURE UPDATE_LAST_UPDATE
(p_schedule_id                 IN       NUMBER
,x_return_Status               OUT      NOCOPY VARCHAR2
,x_msg_Data                    OUT      NOCOPY VARCHAR2
,x_msg_count                   OUT      NOCOPY NUMBER
);

-- mdamle 07/03/2001 - Scheduling Enhancements
FUNCTION getUserType
return varchar2;

-- mdamle 07/03/2001 - Scheduling Enhancements
FUNCTION getDefaultSchedule
(pRegionCode			IN 	VARCHAR2
,pViewBy			IN 	VARCHAR2 DEFAULT NULL
) return varchar2;

-- mdamle 07/03/2001 - Scheduling Enhancements
PROCEDURE showDefaultSchedulePage
(pRegionCode			IN 	VARCHAR2
,pFunctionName			IN	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pViewBy			IN 	VARCHAR2
,pReportTitle			IN	VARCHAR2 default NULL
,pRequestType			IN	VARCHAR2 default NULL
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pGraphType			IN	VARCHAR2 default NULL
);

-- mdamle 07/03/01 - Scheduling Enhancements
FUNCTION getDuplicateSchedule
(pFunctionName			IN	VARCHAR2
,pParameters			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pPlugId			IN	VARCHAR2 default NULL
) return number;

-- mdamle 07/03/01 - Scheduling Enhancements
PROCEDURE subscribeToReport
(pRegionCode			IN	VARCHAR2
,pFunctionName			IN	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pRequestType			IN	VARCHAR2
,pReportTitle			IN	VARCHAR2
,pPlugId			IN	VARCHAR2 default NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,pGraphType			IN	VARCHAR2
);

-- mdamle 07/03/01 - Scheduling Enhancements
FUNCTION getParameterString
(pFunctionName 				IN	VARCHAR2
,pUserId				IN	VARCHAR2
,pSessionId				IN	VARCHAR2
) return varchar2;

-- mdamle 07/03/01 - Scheduling Enhancements
PROCEDURE unSubscribeFromReport
(pScheduleID 			IN 		number
,pPlugId			IN		number    default NULL
);

-- mdamle 07/03/01 - Scheduling Enhancements
PROCEDURE scheduleFunction
(pRegionCode			IN	VARCHAR2
,pFunctionName			IN	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pSchedule			IN	VARCHAR2
,pRequestType			IN	VARCHAR2
,pReportTitle			IN	VARCHAR2
,pMode				IN	VARCHAR2 default 'UPDATE'
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pSubscribedSchedule            IN      VARCHAR2 default NULL
-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
,pGraphType			IN	VARCHAR2 default NULL);



-- mdamle 08/20/01 - Scheduling Enhancements
procedure addUserToRole(
		 pUserId  	IN number
		,pRole		IN varchar2);

-- aleung 08/21/01 - autoincrement feature
procedure updateIncrementDate(p_concurrent_Request_id       IN       NUMBER);

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge
procedure delete_schedule(pScheduleId		IN 	NUMBER);

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge
procedure delete_old_schedule(pScheduleId		IN 	NUMBER);

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
procedure delete_portlet(
		 pPlugId	IN 	NUMBER
		,pUserId	IN 	NUMBER
		 -- jprabhud 09/24/02 - Enh 2470068 Storing of Graphs to FND_LOBS -- added xGraphFileId
                ,xGraphFileId OUT NOCOPY VARCHAR2);

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
procedure delete_old_portlet(
		 pPlugId	IN 	NUMBER
		,pUserId	IN 	NUMBER
		,pKeepLatest	IN 	BOOLEAN default false);

-- mdamle 09/04/01 Scheduling Enhancements - Phase II - Purge Portlet Data
procedure delete_Notification_Data;

-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
PROCEDURE create_schedule_preferences(
	 p_schedule_id	IN	NUMBER
	,p_user_id	IN 	VARCHAR2
	,p_plug_id	IN	NUMBER
	,p_title	IN	VARCHAR2
	,p_graph_type	IN	VARCHAR2
	,p_request_type IN	VARCHAR2
	,p_file_id	IN OUT  NOCOPY NUMBER
	-- mdamle 12/12/01 - Changes for Live Portlet
	,p_live_portlet	IN	VARCHAR2 DEFAULT 'N'
	 -- jprabhud 09/24/02 - Enh. 2470068 DB Graph HTML - Reusing file Ids to store graphs - added function name
        ,p_function_name IN VARCHAR2 DEFAULT NULL
        --jprabhud - 12/20/02 - NLS Bug 2320171 Graph Fonts and Mutli-Byte characters - passed in p_context_values
        ,p_context_values IN	VARCHAR2 DEFAULT NULL
);

-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
PROCEDURE delete_schedule_preferences
(	 pScheduleId	IN 	number
	,pUserId	IN	number default NULL
	,pPlugId	IN	number default NULL
);

-- mdamle 09/04/01 - Scheduling Enhancements - Phase II - Multiple Preferences per schedule
PROCEDURE cancelRequest(pRequestId	IN 	NUMBER);

-- mdamle 09/19/01 - Trap File_ID creation error
procedure fndLobsError(	 pResponsibilityId	IN	number
			,pSessionId		IN	number
			,pReportName		IN	varchar2);

-- mdamle 12/27/01
procedure updateTitleInPortal(	p_schedule_id IN NUMBER,
				p_plug_id IN NUMBER,
				p_title IN VARCHAR2);

procedure savePortletSettings(	p_schedule_id in varchar2,
				p_request_type in varchar2,
				p_graph_type in varchar2,
				p_title in varchar2,
				p_user_id in varchar2,
				p_plug_id in varchar2);


-- mdamle 01/16/2002
procedure updateExternalSource(	p_schedule_id in varchar2,
				p_file_id  in varchar2,
				p_external_source_id in varchar2);

-- serao -1/17/2002
procedure expireExistingFile(
         p_schedule_id in varchar2,
         p_file_id  in varchar2,
        o_external_source_id OUT NOCOPY VARCHAR2
);

PROCEDURE getSchedulePageDetails
(pRegionCode			IN 	VARCHAR2
,pFunctionName			IN 	VARCHAR2
,pResponsibilityId		IN	VARCHAR2
,pApplicationId			IN	VARCHAR2
,pSessionId			IN	VARCHAR2
,pUserId			IN	VARCHAR2
,pViewBy			IN 	VARCHAR2
,pReportTitle			IN	VARCHAR2 default NULL
,pRequestType			IN	VARCHAR2 default NULL
,pPlugId			IN	VARCHAR2 default NULL
,pParmPrint			IN	VARCHAR2 default NULL
,pGraphType			IN	VARCHAR2 default NULL
,xPageFunctionId 		OUT     NOCOPY NUMBER
,xSessionId                     OUT     NOCOPY NUMBER
,xRespId                        OUT     NOCOPY VARCHAR2
,xApplicationId                 OUT     NOCOPY VARCHAR2
,xParams                        OUT     NOCOPY VARCHAR2
,xsecurityGroupId               OUT     NOCOPY NUMBER
,xWebHtmlCall                   OUT     NOCOPY VARCHAR2
);


END BIS_RG_SCHEDULES_PVT;

 

/
