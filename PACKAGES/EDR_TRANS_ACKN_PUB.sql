--------------------------------------------------------
--  DDL for Package EDR_TRANS_ACKN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_TRANS_ACKN_PUB" AUTHID CURRENT_USER as
/* $Header: EDRPACKS.pls 120.0.12000000.1 2007/01/18 05:54:19 appldev ship $ */
/*#
 * This API is used to sends appropriate acknowledgement to evidence store
 * for an e-record based on the status of the business transaction.
 * You can call this API multiple times for a given e-record to acknowledge
 * @rep:scope public
 * @rep:metalink 268669.1 Oracle E-Records API User's Guide
 * @rep:product EDR
 * @rep:displayname E-records Evidence Store APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EDR_EVIDENCE_STORE
 */

/* Global Constants */
G_PKG_NAME	CONSTANT	varchar2(30) := 'EDR_TRANS_ACKN_PUB';

-- Start of comments
--	API name 	: SEND_ACKN
--	Type		: Public
--	Function	: Creates an acknowledgement for an erecord in the
--                        evidence store. This acknowledgement would say whether
--                        the business transaction for which the erecord was
--                        created, completed successfully or not.
--	Pre-reqs	: The ERES event should have been raised and its erecord
--                        id obtained before this api can be called
--	Parameters	:
--	IN		: p_api_version        IN NUMBER 	Required
--			  p_init_msg_list      IN VARCHAR2      Optional
--			  	Default = FND_API.G_FALSE
--			  p_autonomous_commit  IN VARCHAR2 	Optional
--				Default = FND_API.G_FALSE
--                          This tells the API to commit its changes autonomously
--                          or not. This flag is different from the p_coomit flag
--                          in standard APIs. It would do only autonomous commit
--                          in the case this flag's value = Y
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
--	Notes		: Typically the product teams would follow this sequence
--                        in the case of a single ERES event.
--                        1. raise the event
--                        2. get the status back
--                        3. get the erecord id back
--                        4. if the status <> ERROR either commit or rollback the
--                           business txn based on whether is approved or
--                           rejected
--                        5. send out an ack status of SUCCESS
--                        6. if status = ERROR in step 3 above send out ack status
--                           of ERROR
--
-- End of comments
/*#
 * This API sends appropriate acknowledgement for an e-record based on the status of the
 * business transaction.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname E-record acknowledgement
 */

procedure SEND_ACKN
( p_api_version          IN		NUMBER				   ,
  p_init_msg_list	 IN		VARCHAR2 default NULL   ,
  x_return_status	 OUT NOCOPY	VARCHAR2		  	   ,
  x_msg_count		 OUT NOCOPY 	NUMBER				   ,
  x_msg_data		 OUT NOCOPY	VARCHAR2			   ,
  p_event_name           IN            	VARCHAR2  			   ,
  p_event_key            IN            	VARCHAR2  			   ,
  p_erecord_id	         IN		NUMBER			  	   ,
  p_trans_status	 IN		VARCHAR2			   ,
  p_ackn_by              IN             VARCHAR2 default NULL              ,
  p_ackn_note	         IN		VARCHAR2 default NULL		   ,
  p_autonomous_commit	 IN  		VARCHAR2 default NULL
);

end EDR_TRANS_ACKN_PUB;

 

/
