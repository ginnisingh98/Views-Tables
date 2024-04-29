--------------------------------------------------------
--  DDL for Package EDR_ERES_EVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ERES_EVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVEVTS.pls 120.0.12000000.1 2007/01/18 05:56:13 appldev ship $*/

/* Global Constants */
G_PKG_NAME            CONSTANT            varchar2(30) := 'EDR_ERES_EVENT_PVT';

-- Start of comments
-- API name             : RAISE_EVENT
-- Type                 : Private.
-- Function             : Raise an Event and return its status and erecord id
--                        back
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_validation_level     IN NUMBER       Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                       p_mode                 IN VARCHAR2(20) Optional
--                                        Default NULL
--                        The mode of validation. This can have two possible
--                        values 'STRICT' or null. This parameter is used
--                        only if the payload contains the parameters for
--                        interevent processing. In that case STRICT is used
--                        in the case where PARENT_ERECORD_ID NEEDS to be
--                        passed
--
--                      p_parameter_list       IN FND_WF_EVENT.PARAM_TABLE OPTIONAL
--                      If this variable is set then the parameters set on the x_event
--                      variable is ignored and the this list is used instead while raising the event.
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--                       x_event           	IN OUT ERES_EVENT_REC_TYPE
--                       Eres event structure with event name, event key
--                       and payload supplied by the caller. At end the
--                       erecord id and status would be populated
--                       Status can be: ERROR, PENDING, NOACTION
--                       x_is_child_event       OUT BOOLEAN
--                       Set to true if this event is a child event in the
--                       context of an inter event transaction
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :Can be used to raise an ERES event.
--
-- End of comments

PROCEDURE RAISE_EVENT
( p_api_version         IN		NUMBER,
  p_init_msg_list	      IN		VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_validation_level	  IN		NUMBER	default FND_API.G_VALID_LEVEL_FULL,
  x_return_status	      OUT 	NOCOPY 	VARCHAR2,
  x_msg_count		        OUT 	NOCOPY 	NUMBER,
  x_msg_data  	        OUT 	NOCOPY 	VARCHAR2,
  p_mode  		          IN 		VARCHAR2 DEFAULT NULL,
  x_event 		        IN OUT 	NOCOPY 	EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE,
  x_is_child_event 	    OUT 	NOCOPY 	BOOLEAN,
  --Bug 4122622: Start
  p_parameter_list      IN    FND_WF_EVENT.PARAM_TABLE default EDR_CONSTANTS_GRP.G_EMPTY_PARAM_LIST
  --Bug 4122622: End
);

/** Use to get the GUID of the subscription of a business event
 ** returns the guid or null depending on whether the event is
 ** valid or not
 ** added following comments as part of bug fix 3355468
 ** This function returns valid Subscription GUID for following cases
 ** 1. only one ERES subscription present
 ** 2. Only one ERES subscription is enabled when multiple
 **    ERES subscriptions are present for the event
 **
 ** in all other cases it will return "Null"
 **
 **/

FUNCTION GET_SUBSCRIPTION_GUID
( p_event_name 		IN 	VARCHAR2)
RETURN RAW;

PROCEDURE CREATE_PAYLOAD
( p_event 		IN      EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE        ,
  p_starting_position   IN      NUMBER     DEFAULT 1                          ,
  x_payload 	        OUT 	NOCOPY 	FND_WF_EVENT.PARAM_TABLE
);

-- Start of comments
-- API name             : GET_EVENT_APPROVERS
-- Type                 : Private.
-- Function             : Get the fnd user name and the role name (from wf directory
--                        services) of the users who are defined as potential approvers
--                        of the eres event in AME
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_event_name           IN VARCHAR2     Required
--                       The name of the ERES event for which we need to fetch approvers
--                       p_event_key            IN VARCHAR2     Required
--                       The event key for the event. This would also be the transaction
--                       ID in the AME
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--                       x_approver_count       OUT NUMBER
--                       The number of approvers, defaulted to 0.
--                       x_approvers_name       OUT FND_TABLE_OF_VARCHAR2_255
--                       A table of varchar2 that would store the approver's fnd user name
--                       x_approvers_role_name  OUT FND_TABLE_OF_VARCHAR2_255
--                       A table of varchar2 that would store the approver's wf role name
--                       x_overriding_details   OUT FND_TABLE_OF_VARCHAR2_255
--                       A table of varchar2 containing the details of routing rules used
--                       by the user currently (if any)
--
--                       x_approvers_sequence   OUT FND_TABLE_OF_VARCHAR2_255
--                       A table of varchar2 that out store the approver
--                       sequence number as returned from AME
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :The event should have subscription parameter EDR_AME_TRANSACTION_TYPE
--                       defined in the BES system according to ERES Cookbook otherwise the
--                       event name is defaulted as the ame txn name when getting approvers
--                       from AME
-- End of comments

-- Bug 2674799: start

PROCEDURE GET_EVENT_APPROVERS
( p_api_version         IN		NUMBER				      ,
  p_init_msg_list	IN		VARCHAR2 DEFAULT FND_API.G_FALSE      ,
  x_return_status	OUT 	NOCOPY 	VARCHAR2		  	      ,
  x_msg_count		OUT 	NOCOPY 	NUMBER				      ,
  x_msg_data		OUT 	NOCOPY 	VARCHAR2			      ,
  p_event_name 		IN 		VARCHAR2                              ,
  p_event_key           IN              VARCHAR2                              ,
  x_approver_count      OUT     NOCOPY  NUMBER                                ,
  x_approvers_name      OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_approvers_role_name OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_overriding_details  OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255             ,
  x_approvers_sequence  OUT     NOCOPY  FND_TABLE_OF_VARCHAR2_255
);
-- Bug 2674799: end

--Bug 3667036: Start

-- Start of comments
-- API name             : CREATE_MANAGER_PROCESS
-- Type                 : Private
-- Function             : Insert a row into the EDR_ERESMANAGER_T table
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_RETURN_URL         IN  VARCHAR2  - The URL of the product teams page
--                      :P_OVERALL_STATUS     IN  VARCHAR2  - The overall status of the erecords
--							      to which this manager refers to
--                      :P_CREATION_DATE      IN  DATE
--			:P_CREATED_BY         IN  NUMBER
--			:P_LAST_UPDATE_DATE   IN  DATE
--			:P_LAST_UPDATED_BY    IN  NUMBER
--			:P_LAST_UPDATE_LOGIN  IN  NUMBER  ---- WHO COLUMNS
--
-- OUT                  :X_PROCESS_ID VARCHAR2 - The unique process ID that identifies this ERES MANAGER
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
--
-- End of comments

PROCEDURE CREATE_MANAGER_PROCESS(P_RETURN_URL        IN           VARCHAR2,
                                 P_RETURN_FUNCTION   IN           VARCHAR2,
                        				 P_OVERALL_STATUS    IN	          VARCHAR2,
                        				 P_CREATION_DATE     IN           DATE,
                            		 P_CREATED_BY        IN           NUMBER,
                        				 P_LAST_UPDATE_DATE  IN           DATE,
                        				 P_LAST_UPDATED_BY   IN           NUMBER,
                        				 P_LAST_UPDATE_LOGIN IN           NUMBER,
                        				 X_ERES_PROCESS_ID   OUT NOCOPY   NUMBER);


-- Start of comments
-- API name             : DELETE_ERECORDS
-- Type                 : Private.
-- Function             : DELETE the rows from EDR_ERESMANAGER_T and EDR_PROCESS_ERECORDS_T
--                        for the given eres_process_id or if the process_id is not provided
--                        delete all the e-records which are x days old. x is based on the profile
--                        option EDR_TEMP_DATA_LIFE
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERES_PROCESSID  VARCHAR2  IN - The process_id of the eres manager
--                                                         and erecords to be delete.
--
-- OUT                  : NONE
--
-- Version              : Current version        1.0
--                        Initial version        1.0
--
-- Notes                :If p_eres_process_id is null then a profile value indicating
--			 the maximum age of a temporary erecord viz. EDR_TEMP_DATA_LIFE is read.
--			 All those rows whose age are this value are deleted.
-- End of comments

PROCEDURE DELETE_ERECORDS(P_ERES_PROCESS_ID	IN	NUMBER DEFAULT NULL);
--Bug 3667036: End



--Bug 3207385: Start
PROCEDURE RAISE_TABLE (P_EVENT_NAME     IN              VARCHAR2,
                       P_EVENT_KEY      IN              VARCHAR2,
                       P_EVENT_DATA     IN              CLOB      DEFAULT NULL,
                       P_PARAM_TABLE    IN  OUT NOCOPY  FND_WF_EVENT.PARAM_TABLE,
                       P_NUMBER_PARAMS  IN              NUMBER,
                       P_SEND_DATE      IN              DATE      DEFAULT NULL);
--Bug 3207385: End


--Bug 4122622: Start
-- Start of comments
-- API name             : GET_EVENT_DETAILS
-- Type                 : Private.
-- Function             : Returns the event name and event key for the specified e-record ID.
--
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : P_ERECORD_ID  NUMBER    IN  - The e-record ID of the e-record whose event details
--                                                     are to be fetched.
--
-- OUT                  : X_EVENT_NAME  VARCHAR2  OUT - The corresponding event name.
--                        X_EVENT_KEY   VARCHAR2  OUT - The corresponding event key.
--
-- Version              : Current version        1.0
--                        Initial version        1.0
--
-- End of comments

PROCEDURE GET_EVENT_DETAILS(P_ERECORD_ID IN NUMBER,
                            X_EVENT_NAME OUT NOCOPY VARCHAR2,
			    X_EVENT_KEY  OUT NOCOPY VARCHAR2);
--Bug 4122622: End

end EDR_ERES_EVENT_PVT;

 

/
