--------------------------------------------------------
--  DDL for Package EDR_TRANS_ACKN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_TRANS_ACKN_PVT" AUTHID CURRENT_USER as
/* $Header: EDRVACKS.pls 120.0.12000000.1 2007/01/18 05:56:00 appldev ship $ */

/* Global Constants */
G_PKG_NAME		CONSTANT	varchar2(30) := 'EDR_TRANS_ACKN_PVT';
G_INSERT_MODE   	CONSTANT        varchar2(30) := 'INSERT';
G_UPDATE_MODE   	CONSTANT        varchar2(30) := 'UPDATE';

G_VALIDATE_DUP_ACK	CONSTANT	NUMBER 	     := 10;
G_VALIDATE_ERECORD	CONSTANT	NUMBER 	     := 20;
G_VALIDATE_STATUS	CONSTANT	NUMBER 	     := 30;

-- Start of comments
--	API name 	: IS_STATUS_VALID
--	Type		: Private Utility (Nat an API)
--	Function	: Validate if the transaction ack status is valid in
--                        a given scenario
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_status             IN VARCHAR2(30)  Required
--			: p_mode               IN VARCHAR2(30)  Required
--                         Two possible values INSERT, UPDATE based on whether an
--                         acknowledgement row is being inserted or updated
--
--	OUT		: Function returns BOOLEAN TRUE or FALSE
--
--	Notes		:
--
-- End of comments

function IS_STATUS_VALID
( p_status               IN             VARCHAR2			   ,
  p_mode                 IN             VARCHAR2
)
RETURN BOOLEAN;

-- Start of comments
--	API name 	: INSERT_ROW
--	Type		: Private.
--	Function	: Creates a row in the EDR_TRANS_ACKN table to
--                        create an acknowledgement row for an eRecord.
--                        Returns the primary key of the new row.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_api_version        IN NUMBER 	Required
--			  p_init_msg_list      IN VARCHAR2      Optional
--			  	Default = FND_API.G_FALSE
--                        p_validation_level   IN NUMBER   	Optional
--				Default = FND_API.G_VALID_LEVEL_FULL
--                         Possible values
--                         1. FND_API.G_VALID_LEVEL_FULL: Full Validation
--                         2. FND_API.G_VALID_LEVEL_NONE: No Validation
--                         3. G_VALIDATE_DUP_ACK: Validated dup ack
--                         4. G_VALIDATE_ERECORD: 3 + validate erecord
--                         5. G_VALIDATE_STATUS: 3+4+ validate status
--
--                        p_erecord_id         IN NUMBER	Required
--                          The erecord id for which ackn is being recorded
--                        p_trans_status       IN VARCHAR2(30)	Required
--                          The status of the transaction for which ack is
--                          being created. There is a limited set of possible
--                          values: NOTACKNOWLEDGED, NOTCOLLECTED
--                        p_ackn_by            IN VARCHAR2(200)	Optional
--                              Default NULL
--                          The source of the acknowledgement e.g a pgm name
--                        p_ackn_note          IN VARCHAR2(2000) Optional
--                              Default NULL
--                          Additional information/comments about the ackn
--
--	OUT		: x_return_status      OUT VARCHAR2
--			  x_msg_count	       OUT NUMBER
--			  x_msg_data	       OUT VARCHAR2
--                        x_ackn_id            OUT NUMBER
--                          Primary key of the new row
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		: This API doesnt commit or rollback because its
--                        called from an autonomous context from the rule
--                        function
--
-- End of comments

procedure INSERT_ROW
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 default FND_API.G_FALSE   ,
  p_validation_level	 IN  		NUMBER   default
						FND_API.G_VALID_LEVEL_FULL ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2 default NULL              ,
  p_ackn_note	         IN		VARCHAR2 default NULL		   ,
  x_ackn_id              OUT NOCOPY     NUMBER
);

-- Start of comments
--	API name 	: SEND_ACKN_AUTO
--	Type		: Private
--	Function	: Creates an acknowledgement for an erecord in the
--                        evidence store. This acknowledgement would say whether
--                        the business transaction for which the erecord was
--                        created, completed successfully or not. This API
--                        does an autonomous commit.
--	Pre-reqs	: The ERES event should have been raised and its erecord
--                        id obtained before this api can be called
--	Parameters	:
--	IN		: p_api_version        IN NUMBER 	Required
--			  p_init_msg_list      IN VARCHAR2      Optional
--			  	Default = FND_API.G_FALSE
--                        p_event_name         IN VARCHAR2(80)  Required
--                          The event name for which acknowledgement is sent
--                        p_event_name         IN VARCHAR2(240)  Required
--                          The event key for which acknowledgement is sent
--                        p_erecord_id         IN NUMBER	Required
--                          The erecord id for which ackn is being sent
--                        p_trans_status       IN VARCHAR2(30)	Required
--                          The status of the transaction for which ack is
--                          being created. There is a limited set of possible
--                          values: SUCCESS, ERROR.
--                        p_ackn_by            IN VARCHAR2(200)	Optional
--                              Default NULL
--                          The source of the acknowledgement e.g a pgm name
--                        p_ackn_note          IN VARCHAR2(2000) Optional
--                              Default NULL
--                          Additional information/comments about the ackn
--
--	OUT		: x_return_status      OUT VARCHAR2
--			  x_msg_count	       OUT NUMBER
--			  x_msg_data	       OUT VARCHAR2
--
--	Version		: Current version       1.0
--			  Initial version 	1.0
--
--	Notes		: This API doesn an autonomous commit and is called
--                        from a public API when a commit for the ack is required.
--
-- End of comments

procedure SEND_ACKN_AUTO
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 default FND_API.G_FALSE   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2 default NULL              ,
  p_ackn_note	         IN		VARCHAR2 default NULL
);

end EDR_TRANS_ACKN_PVT;

 

/
