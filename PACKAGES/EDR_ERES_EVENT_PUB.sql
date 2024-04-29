--------------------------------------------------------
--  DDL for Package EDR_ERES_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ERES_EVENT_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRPEVTS.pls 120.1.12000000.1 2007/01/18 05:54:33 appldev ship $*/
/*#
 * These APIs raise an e-signature event or related events in deferred mode.
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname E-records Evidence Store APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_EVIDENCE_STORE
 */

/* Global Constants */
G_PKG_NAME            CONSTANT            varchar2(30) := 'EDR_ERES_EVENT_PUB';

/* Global Types */

-- Table of erecord ids
TYPE ERECORD_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Record type to represent an ERES event

--Bug 3136403: Start
--Change the definition of the record type to denormalize the payload parameters
/*
TYPE ERES_EVENT_REC_TYPE IS RECORD
( EVENT_NAME                              VARCHAR2(80)                       ,
  EVENT_KEY                               VARCHAR2(240)                      ,
  PAYLOAD                                 FND_WF_EVENT.PARAM_TABLE           ,
  ERECORD_ID                              NUMBER                             ,
  EVENT_STATUS                            VARCHAR2(20)
);
*/
TYPE ERES_EVENT_REC_TYPE IS RECORD
( EVENT_NAME                              VARCHAR2(80)                       ,
  EVENT_KEY                               VARCHAR2(240)                      ,
  ERECORD_ID                              NUMBER                             ,
  EVENT_STATUS                            VARCHAR2(20)    DEFAULT NULL       ,
  --Bug 3893101: Start
  --Include the EVENT XML as part of the record type
  EVENT_XML                               CLOB            DEFAULT NULL       ,
  --Bug 3893101: End
  PARAM_NAME_1                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_1                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_2                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_2                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_3                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_3                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_4                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_4                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_5                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_5                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_6                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_6                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_7                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_7                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_8                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_8                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_9                            VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_9                           VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_10                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_10                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_11                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_11                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_12                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_12                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_13                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_13                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_14                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_14                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_15                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_15                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_16                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_16                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_17                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_17                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_18                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_18                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_19                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_19                          VARCHAR2(2000)  DEFAULT NULL       ,
  PARAM_NAME_20                           VARCHAR2(30)    DEFAULT NULL       ,
  PARAM_VALUE_20                          VARCHAR2(2000)  DEFAULT NULL
);
--Bug 3136403: End

-- A table of ERES Events

TYPE ERES_EVENT_TBL_TYPE IS TABLE OF ERES_EVENT_REC_TYPE INDEX BY BINARY_INTEGER;

-- Start of comments
-- API name             : VALIDATE_ERECORD
-- Type                 : Public.
-- Function             : Determine if the erecord with the given id exists in
--                        the evidence store or not
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_erecord_id           IN NUMBER       Required
--                       The erecord id to be validated
--
-- OUT                  :x_return_status        OUT VARCHAR2(1)
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2(2000)
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :Checks the validity of the erecord id i.e. if it exists
--                       in the evidence store or not. A message is written in the
--                       message stack only in the case of an UNEXPECTED error.
--                       If the erecord id is valid or not no message is written in
--                       the stack only the return status would indicate the result.
--
-- End of comments

PROCEDURE VALIDATE_ERECORD
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2 DEFAULT NULL ,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_erecord_id          IN                NUMBER
);

-- Start of comments
-- API name             : VALIDATE_PAYLOAD
-- Type                 : Public
-- Function             : Determine if the payload of parameters to be passed
--                        to raise an ERES event is valid or not
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_event_name           IN VARCHAR2(80)	Optional
--                        The event name for which the payload has to be validated
--                       p_event_key           IN VARCHAR2(240)	Optional
--                        The event key for which the payload has to be validated
--                       p_payload              IN fnd_wf_event.param_table Required
--                        The name-value pair of parameters to be validated
--                       p_mode                 IN VARCHAR2(20) Optional
--                        The mode of validation. This can have two possible
--                        values 'STRICT' or null. This parameter is used
--                        only if the payload contains the parameters for
--                        interevent processing. In that case STRICT is used
--                        in the case where PARENT_ERECORD_ID NEEDS to be
--                        passed
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                        The return status S means the validation is OK
--                        E means validation failed
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :If you use this API to test the payload, you should
--                        not require validation while raising the event
--
-- End of comments

PROCEDURE VALIDATE_PAYLOAD
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2 default NULL ,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_event_name		IN		  VARCHAR2 default NULL		  ,
  p_event_key		IN		  VARCHAR2 default NULL		  ,
  p_payload             IN                fnd_wf_event.param_table        ,
  p_mode                IN                VARCHAR2 default NULL
);

-- Start of comments
-- API name             : VALIDATE_PAYLOAD_FORMS
-- Type                 : Public
-- Function             : Determine if the payload of parameters to be passed
--                        to raise an ERES event is valid or not. This API is used
--                        from FORMS.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                    p_event_name           IN VARCHAR2(80)	Optional
--                        The event name for which the payload has to be validated
--                       p_event_key           IN VARCHAR2(240)	Optional
--                        The event key for which the payload has to be validated
--                       p_payload              IN fnd_wf_event.param_table Required
--                        The name-value pair of parameters to be validated
--
-- RETURN               :Boolean
--                       If the payload is valid it would return TRUE else it would
--                       raise an APPS_EXCEPTION, that should be handled in the
--                       calling code
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                 :If you use this API to test the payload, you should
--                        not require validation while raising the event
--
-- End of comments

FUNCTION VALIDATE_PAYLOAD_FORMS
( p_event_name		IN 		VARCHAR2			,
  p_event_key		IN 		VARCHAR2			,
  p_payload 		IN 		fnd_wf_event.param_table
)
RETURN BOOLEAN;

-- Start of comments
-- API name             : GET_EVENT_DETAILS
-- Type                 : Public.
-- Function             : Get the event name and event key from the evidence
--                        store for a given erecord id
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_erecord_id           IN NUMBER       Required
--                       The erecord id for which the event details are
--                       to be obtained
--
-- OUT                  :x_return_status        OUT VARCHAR2
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--                       x_event_name           OUT VARCHAR2(80)
--                       Event name if erecord id valid, else null
--                       x_event_key            OUT VARCHAR2(240)
--                       Event keyif erecord id valid, else null
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :Gets the event name and event key for a given
--                       erecord id from the evidence store. A message is written
--                       in the message stack only in the case of an UNEXPECTED error.
--                       If the erecord id is valid or not no message is written in
--                       the stack only the return status would indicate the result
--                       along with null return values.
--
-- End of comments
/*#
 * This API is used to obtain the event name and event key from the evidence store for
 * an e-record ID.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get event details
 */

PROCEDURE GET_EVENT_DETAILS
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2 default NULL ,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_erecord_id          IN                NUMBER                          ,
  x_event_name          OUT NOCOPY        VARCHAR2                        ,
  x_event_key           OUT NOCOPY        VARCHAR2
);

-- Start of comments
-- API name             : RAISE_ERES_EVENT
-- Type                 : Public
-- Function             : Raise an ERES event and get the status and erecord id back.
--                        This API can be used to raise 'normal' as well as 'inter
--                        event' ERES events.
--                        In case of normal event the p_child_erecords should be left
--                        null and payload should conform to guidelines set in the
--                        ERES cookbook.
--                        In case of 'inter event' context if the parent already exists
--                        then payload should contain additional parameters to set
--                        parent child relationship (look at cookbook)
--                        In case of 'inter event' context if the children already
--                        exists the p_child_erecords should contain the erecord
--                        ids of these children
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_validation_level     IN NUMBER       Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                       p_child_erecords       IN ERECORD_ID_TBL_TYPE Required
--                        In case of inter-event when the children exists and
--                        parent is being raised this parameter contains the
--                        list of erecord ids of the children to establish
--                        parent child relationship
--
-- OUT                  :x_return_status        OUT VARCHAR2(1)
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2(2000)
--                       x_event           	IN OUT ERES_EVENT_REC_TYPE
--                       Eres event structure with event name, event key
--                       and payload supplied by the caller. At end the
--                       erecord id and status would be populated
--                       Status can be: ERROR, PENDING, NOACTION
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :Can be used to raise normal and inter-event ERES events.
--                       Please look at the ERES Cookbook for more details of
--                       the valid payload required to raise ERES Events from
--                       database.
--                       It is the responsibility of the calling code to commit
--                       or rollback according to the status of the API and/or
--                       the ERES event. The eRecords are created autonomously
--                       in the evidence store but thier relationships have to be
--                       committed and can also be rolledback
--
-- Additional Imp Note:   This API doesnt accept a p_commit status becuase a savepoint
--                        cannot be set inside due to the fact that the erecords are
--                        created in an autonomous manner. So if the API returns a status
--                        error or the overall status is error it is the responsibility
--                        of the product team to rollback the changes, it would rollback
--                        and 'partial' data inserted in the relationship table
--                        As a part of the transaction acknowledgement procedure
--                        the product teams can then send an ERROR acknowledgement
--                        to mark these erecords also as ERROR
-- End of comments
/*#
 * This API raises normal as well as related events. For normal events, the
 * p_child_erecords must be left null and the payload must conform to guidelines set in
 * the Oracle E-Records Developer's Guide.  For a related event, if the parent already
 * exists, then payload must contain additional parameters to set the parent-child
 * relationship. Also, if the children already exist, then the p_child_erecords must
 * contain the e-record IDs for the children.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Raise e-signature events
 */

PROCEDURE RAISE_ERES_EVENT
( p_api_version         IN                NUMBER                          ,
  p_init_msg_list       IN                VARCHAR2 default NULL ,
  p_validation_level    IN                NUMBER   default NULL    ,
  x_return_status       OUT NOCOPY        VARCHAR2                        ,
  x_msg_count           OUT NOCOPY        NUMBER                          ,
  x_msg_data            OUT NOCOPY        VARCHAR2                        ,
  p_child_erecords      IN                ERECORD_ID_TBL_TYPE             ,
  x_event               IN OUT NOCOPY     ERES_EVENT_REC_TYPE
);

-- Start of comments
-- API name             : RAISE_INTER_EVENT
-- Type                 : Public
-- Function             : Used to raise a number of ERES events at one time
--                        in the inter event context. It is expected that while
--                        using this API atleast one parent event would be raised
--                        along with one or more of its child events.
--                        A parent event is a 'normal' ERES event. And a child
--                        event is the one containing additional parameters in the
--                        payload. Please look at the ERES cookbook for more
--                        information on the payload structure.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   : p_api_version          IN NUMBER       Required
--                        p_init_msg_list        IN VARCHAR2     Optional
--                                         Default = FND_API.G_FALSE
--                        p_validation_level     IN NUMBER       Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--
-- OUT                  : x_return_status        OUT VARCHAR2
--                        x_msg_count            OUT NUMBER
--                        x_msg_data             OUT VARCHAR2
--                        x_events           	 IN OUT ERES_EVENT_TBL_TYPE
--                        Table of Eres event structure with event name,
--                        event key and payload supplied by the caller. At end
--                        the erecord id and status would be populated
--                        Status can be: ERROR, PENDING, NOACTION
--                        x_overall_status       OUT VARCHAR2(20)
--                        Overall status of the ERES processing. This can be used
--                        by the calling code in conjunction with the stndard
--                        x_return status parameter or by itself. The possible values
--                        are:
--                        ERROR: The process errored out (look at messages in stack)
--                        COMPLETE: All processing finished successfully and
--                                  the erecords were created in the case of
--                                  signatures not being required
--                        PENDING: All the erecords required signatures and offline
--                                 notifications have been sent out for them
--                        INDETERMINED: Some events required signatures for which
--                                      notifications have been sent out and some
--                                      of them required only erecords and they have
--                                      been completed. The calling code would have
--                                      look at individual event status' in the table
--                                      to figure out individual statues.
--
-- Version              : Current version        1.0
--                        Initial version        1.0
--
-- Notes                : Whenever an error occurs in one event at the time of
--                        validation the process is aborted. Whenever an error
--                        occurs at the time of raising an event, the process is
--                        aborted with the events in the list ahead of the 'error'
--                        event would have an erecord id generated for them.
--                        Whenever an error occurs during posting of relationship
--                        information in the database the process would abort
--                        and it would be upto the calling code to rollback
--                        uncommited relationship records, the erecords would have
--                        been commited autonomously by that time.
--                        The overall status along with the API return status can
--                        be used to fugure out further processing by the calling
--                        code.
--
-- Additional Imp Note:   This API doesnt accept a p_commit status becuase a savepoint
--                        cannot be set inside due to the fact that the erecords are
--                        created in an autonomous manner. So if the API returns a status
--                        error or the overall status is error it is the responsibility
--                        of the product team to rollback the changes, it would rollback
--                        and 'partial' data inserted in the relationship table
--                        As a part of the transaction acknowledgement procedure
--                        the product teams can then send an ERROR acknowledgement
--                        to mark these erecords also as ERROR
-- End of comments

/*#
 * This API raises a number of e-signature related events at one time.
 * It is expected that while using this API at least one parent event
 * is raised along with one or more of the child events.
 * payload must conform to guidelines set in the Oracle E-Records Developer's Guide
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Raise related e-signature events
 */

PROCEDURE RAISE_INTER_EVENT
( p_api_version          IN               NUMBER                          ,
  p_init_msg_list        IN               VARCHAR2 default NULL ,
  p_validation_level     IN               NUMBER   default NULL    ,
  x_return_status        OUT NOCOPY       VARCHAR2                        ,
  x_msg_count            OUT NOCOPY       NUMBER                          ,
  x_msg_data             OUT NOCOPY       VARCHAR2                        ,
  x_events               IN OUT NOCOPY    ERES_EVENT_TBL_TYPE             ,
  x_overall_status 	 OUT NOCOPY       VARCHAR2
);

-- Start of comments
-- API name             : GET_ERECORD_ID
-- Type                 : Public.
-- Function             : Get the erecord id for a combination of the event
--                        name and event key from a table of ERES events.
--                        This would return the 'latest' erecord id for
--                        and event name and key combination.
-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :p_api_version          IN NUMBER       Required
--                       p_init_msg_list        IN VARCHAR2     Optional
--                                        Default = FND_API.G_FALSE
--                       p_events               IN ERES_EVENT_TBL_TYPE Required
--                       Table of ERES events
--                       p_event_name           IN VARCHAR2(80) Required
--                       ERES Business Event Name
--                       p_event_key            IN VARCHAR2(240) Required
--                       Event Key for the ERES event
-- OUT                  :x_return_status        OUT VARCHAR2
--                       'S' in case of a hit and 'E' in case of a miss
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2
--                       x_erecord_id           OUT NUMBER
--                       eRecord id for the input event name and event key.
--                       This would the latest entry in the table for
--                       the event name and key combination.
--                       If not found it would be null.
--
-- Version              :Current version        1.0
--                       Initial version        1.0
--
-- Notes                :This API can be used by the calling code to find out
--                       individual errecord ids instead of going through
--                       the table
--
-- End of comments
/*#
 * This API obtains the e-record ID for an event name and event key combination
 * from a table of ERES events. The updated e-record ID for the combination is
 * returned. Use this API in conjunction with 'Raise related e-signature events' API only.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get e-record ID
 */

PROCEDURE GET_ERECORD_ID
( p_api_version          IN               NUMBER                          ,
  p_init_msg_list        IN               VARCHAR2 default NULL ,
  x_return_status        OUT NOCOPY       VARCHAR2                        ,
  x_msg_count            OUT NOCOPY       NUMBER                          ,
  x_msg_data             OUT NOCOPY       VARCHAR2                        ,
  p_events               IN               ERES_EVENT_TBL_TYPE             ,
  p_event_name           IN               VARCHAR2                        ,
  p_event_key            IN               VARCHAR2                        ,
  x_erecord_id           OUT NOCOPY       NUMBER
);

end EDR_ERES_EVENT_PUB;

 

/
