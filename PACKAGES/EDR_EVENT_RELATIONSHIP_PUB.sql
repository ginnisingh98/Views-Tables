--------------------------------------------------------
--  DDL for Package EDR_EVENT_RELATIONSHIP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_EVENT_RELATIONSHIP_PUB" AUTHID CURRENT_USER as
/* $Header: EDRPRELS.pls 120.0.12000000.1 2007/01/18 05:54:41 appldev ship $ */
/*#
 * These APIs establish relationship between e-records.
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname E-records Evidence Store APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_EVIDENCE_STORE
 */

/* Global Types */

-- Record type for a relationship record to establish parent child relationship
-- between two erecords

Type INTER_EVENT_REC_TYPE IS RECORD
( parent_event_name 		VARCHAR2(80)		,
  parent_event_key 		VARCHAR2(240)		,
  parent_erecord_id 		NUMBER			,
  child_event_name 		VARCHAR2(80)		,
  child_event_key 		VARCHAR2(240)		,
  child_erecord_id 		NUMBER
);

-- Table of relationship records

TYPE INTER_EVENT_TBL_TYPE IS TABLE OF INTER_EVENT_REC_TYPE INDEX BY BINARY_INTEGER;

/* Global Constants */
G_PKG_NAME	CONSTANT	varchar2(30) := 'EDR_EVENT_RELATIONSHIP_PUB';

-- Start of comments
--	API name 	: CREATE_RELATIONSHIP
--	Type		: Public.
--	Function	: Creates a row in the EDR_EVENT_RELATIONSHIP table to
--                        establish a parent-event relationship between two event
--                        erecords.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version        IN NUMBER 	Required
--			  p_init_msg_list      IN VARCHAR2      Optional
--			  	Default = FND_API.G_FALSE
--			  p_commit	       IN VARCHAR2 	Optional
--				Default = FND_API.G_FALSE
--                        p_validation_level   IN NUMBER   	Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                        p_parent_erecord_id  IN NUMBER	Required
--                        p_parent_event_name  IN VARCHAR2(80)	Optional
--                              Default NULL
--                        p_parent_event_key   IN VARCHAR2(240)	Optional
--                              Default NULL
--                        p_child_erecord_id   IN NUMBER        Required
--                        p_child_event_name   IN VARCHAR2(80)	Optional
--                              Default NULL
--                        p_child_event_key    IN VARCHAR2(240)	Optional
--                              Default NULL
--
--	OUT		: x_return_status      OUT VARCHAR2
--			  x_msg_count	       OUT NUMBER
--			  x_msg_data	       OUT VARCHAR2
--			  x_relationship_id    OUT NUMBER
--                        PK of the new row or null if there is an error
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		: The event names and event keys are optional but if provided,
--                        would be validated to be matching those in the evidence store
--                        for the given erecord id. This API would insert a row in the
--                        relationship table and return the primary key of the new row
--                        in parameter x_relationship_id
--
-- End of comments
/*#
 * This API establishes a related event relationship between two events in evidence store.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Establish relationships between e-records
 */

procedure CREATE_RELATIONSHIP
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 default NULL   ,
  p_commit	    	 IN  		VARCHAR2 default NULL   ,
  p_validation_level	 IN  		NUMBER   default NULL 	,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  P_PARENT_ERECORD_ID    IN         NUMBER				   ,
  P_PARENT_EVENT_NAME    IN         VARCHAR2 default NULL		   ,
  P_PARENT_EVENT_KEY	 IN         VARCHAR2 default NULL		   ,
  P_CHILD_ERECORD_ID     IN         NUMBER				   ,
  P_CHILD_EVENT_NAME     IN         VARCHAR2 default NULL		   ,
  P_CHILD_EVENT_KEY      IN         VARCHAR2 default NULL		   ,
  X_RELATIONSHIP_ID      OUT NOCOPY NUMBER
);

-- Start of comments
--	API name 	: VALIDATE_RELATIONSHIP
--	Type		: Public.
--	Function	: Validates that the given parameters would create a
--                        row in edr_event_relationship table
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version        IN NUMBER 	Required
--			  p_init_msg_list      IN VARCHAR2      Optional
--			  	Default = FND_API.G_FALSE
--                        p_parent_erecord_id  IN NUMBER	Required
--                        p_parent_event_name  IN VARCHAR2(80)	Optional
--                              Default NULL
--                        p_parent_event_key   IN VARCHAR2(240)	Optional
--                              Default NULL
--                        p_child_erecord_id   IN NUMBER        Required
--                        p_child_event_name   IN VARCHAR2(80)	Optional
--                              Default NULL
--                        p_child_event_key    IN VARCHAR2(240)	Optional
--                              Default NULL
--
--	OUT		: x_return_status      OUT VARCHAR2
--                        'E' means that the validation has failed. 'S' means
--                         its successful
--			  x_msg_count	       OUT NUMBER
--			  x_msg_data	       OUT VARCHAR2
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		: First checks to see if the erecord ids are valid or not
--                        If the erecord ids are valid then it validates that
--                        the event name and event key are valid for the given
--                        erecord id
--                        The outcome of validation is provided in x_return_status
--
-- End of comments

PROCEDURE VALIDATE_RELATIONSHIP
( p_api_version          IN		NUMBER			,
  p_init_msg_list	 IN		VARCHAR2 default NULL   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		,
  x_msg_count		 OUT NOCOPY NUMBER			,
  x_msg_data		 OUT NOCOPY	VARCHAR2		,
  P_PARENT_ERECORD_ID    IN         NUMBER			,
  P_PARENT_EVENT_NAME    IN         VARCHAR2 default NULL	,
  P_PARENT_EVENT_KEY	 IN         VARCHAR2 default NULL	,
  P_CHILD_ERECORD_ID     IN         NUMBER			,
  P_CHILD_EVENT_NAME     IN         VARCHAR2 default NULL	,
  P_CHILD_EVENT_KEY      IN         VARCHAR2 default NULL
);

end EDR_EVENT_RELATIONSHIP_PUB;

 

/
