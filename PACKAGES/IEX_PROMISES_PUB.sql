--------------------------------------------------------
--  DDL for Package IEX_PROMISES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PROMISES_PUB" AUTHID CURRENT_USER as
/* $Header: iexpyprs.pls 120.8.12010000.3 2010/02/05 12:37:36 gnramasa ship $ */
/*#
   Creates a promise.
 * @rep:scope public
 * @rep:product IEX
 * @rep:lifecycle active
 * @rep:displayname IEX Promises API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_PROMISES
 */

TYPE ATTRIBUTE_REC_TYPE IS RECORD
(
    ATTRIBUTE_CATEGORY    VARCHAR2(30) DEFAULT NULL,
    ATTRIBUTE1            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE2            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE3            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE4            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE5            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE6            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE7            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE8            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE9            VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE10           VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE11           VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE12           VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE13           VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE14           VARCHAR2(150) DEFAULT NULL,
    ATTRIBUTE15           VARCHAR2(150) DEFAULT NULL
);

/* Insert promise record */
TYPE PRO_INSRT_REC_TYPE IS RECORD
(
    PROMISE_AMOUNT			NUMBER,				/* required; should be greater than 0 */
    CURRENCY_CODE			VARCHAR2(15),			/* required; should be the same as promise object original currency */
    PROMISE_DATE			DATE,				/* required; should be unique for the promise object */
    PROMISE_PAYMENT_METHOD		VARCHAR2(30),			/* optional; valid values from iex_lookups_v, lookup_type: IEX_PAYMENT_TYPES */
    ACCOUNT				VARCHAR2(240),			/* optional */
    PROMISE_ITEM_NUMBER			VARCHAR2(240),			/* optional */
    PROMISE_TARGET			VARCHAR2(30),			/* required; valid values: ACCOUNTS, INVOICES, CNSLD, CONTRACTS */
    CUST_ACCOUNT_ID			NUMBER,				/* required for all promise targets */
    DELINQUENCY_ID			NUMBER, 			/* required only for promises on INVOICES */
    CNSLD_INVOICE_ID			NUMBER, 			/* required only for promises on CNSLD */
    CONTRACT_ID				NUMBER, 			/* required only for promises on CONTRACTS */
    CAMPAIGN_SCHED_ID			NUMBER,				/* optional */
    TAKEN_BY_RESOURCE_ID		NUMBER,				/* required */
    PROMISED_BY_PARTY_REL_ID		NUMBER,				/* optional; valid combinations for all 3 parties: 1) all 3 parties are not null and valid */
    PROMISED_BY_PARTY_ORG_ID		NUMBER,				/*	2) PARTY_ORG_ID is not null, other 2 are null */
    PROMISED_BY_PARTY_PER_ID		NUMBER,				/*	3) PARTY_PER_ID is not null, other 2 are null */
    NOTE				VARCHAR2(2000),			/* optional */
    ATTRIBUTES				ATTRIBUTE_REC_TYPE		/* optional */
);

/* Update promise record */
TYPE PRO_UPDT_REC_TYPE IS RECORD
(
    PROMISE_ID				NUMBER,				/* required */
    PROMISE_AMOUNT			NUMBER,				/* required */
    PROMISE_DATE			DATE,				/* required */
    PROMISE_PAYMENT_METHOD		VARCHAR2(30),			/* optional */
    ACCOUNT				VARCHAR2(240),			/* optional */
    PROMISE_ITEM_NUMBER			VARCHAR2(240),			/* optional */
    CAMPAIGN_SCHED_ID			NUMBER,				/* optional */
    TAKEN_BY_RESOURCE_ID		NUMBER,				/* required */
    PROMISED_BY_PARTY_REL_ID		NUMBER,				/* optional; valid combinations for all 3 parties: 1) all 3 parties are not null and valid */
    PROMISED_BY_PARTY_ORG_ID		NUMBER,				/*	2) PARTY_ORG_ID is not null, other 2 are null */
    PROMISED_BY_PARTY_PER_ID		NUMBER,				/*	3) PARTY_PER_ID is not null, other 2 are null */
    NOTE				VARCHAR2(2000),			/* optional */
    ATTRIBUTES				ATTRIBUTE_REC_TYPE		/* optional */
);

/* Cancel promise record */
TYPE PRO_CNCL_REC_TYPE IS RECORD
(
    PROMISE_ID				NUMBER,				/* required */
    TAKEN_BY_RESOURCE_ID		NUMBER,				/* required */
    PROMISED_BY_PARTY_REL_ID		NUMBER,				/* optional; valid combinations for all 3 parties: 1) all 3 parties are not null and valid */
    PROMISED_BY_PARTY_ORG_ID		NUMBER,				/*	2) PARTY_ORG_ID is not null, other 2 are null */
    PROMISED_BY_PARTY_PER_ID		NUMBER,				/*	3) PARTY_PER_ID is not null, other 2 are null */
    NOTE				VARCHAR2(2000)			/* optional */
);

/* Promise response record for INSERT_PROMISE, UPDATE_PROMISE and CANCEL_PROMISE APIs */
TYPE PRO_RESP_REC_TYPE IS RECORD
(
    PROMISE_ID              		NUMBER,
    NOTE_ID                 		NUMBER,
    STATUS				VARCHAR2(30),
    STATE				VARCHAR2(30)
);

/* Mass promise common record */
TYPE PRO_MASS_REC_TYPE IS RECORD
(
    PROMISE_DATE			DATE,				/* required */
    PROMISE_PAYMENT_METHOD		VARCHAR2(30),			/* optional */
    ACCOUNT				VARCHAR2(240),			/* optional */
    PROMISE_ITEM_NUMBER			VARCHAR2(240),			/* optional */
    CAMPAIGN_SCHED_ID			NUMBER,				/* optional */
    TAKEN_BY_RESOURCE_ID		NUMBER,				/* required */
    PROMISED_BY_PARTY_REL_ID		NUMBER,				/* optional; valid combinations for all 3 parties: 1) all 3 parties are not null and valid */
    PROMISED_BY_PARTY_ORG_ID		NUMBER,				/*	2) PARTY_ORG_ID is not null, other 2 are null */
    PROMISED_BY_PARTY_PER_ID		NUMBER,				/*	3) PARTY_PER_ID is not null, other 2 are null */
    NOTE				VARCHAR2(2000),			/* optional */
    ATTRIBUTES				ATTRIBUTE_REC_TYPE		/* optional */
);

/* Mass promise response record */
TYPE PRO_MASS_RESP_REC_TYPE IS RECORD
(
    PROMISE_ID              		NUMBER,				/* promise_id */
    PROMISE_AMOUNT			NUMBER,				/* promise amount */
    CURRENCY_CODE			VARCHAR2(15),			/* promise original currency */
    CUST_ACCOUNT_ID			NUMBER,				/* promise cust_account_id */
    CUST_SITE_USE_ID			NUMBER,				/* promise cust_site_use_id */
    DELINQUENCY_ID			NUMBER, 			/* promise delinquency_id */
    STATUS				VARCHAR2(30),			/* promise status */
    STATE				VARCHAR2(30),			/* promise state */
    COLLECTABLE_AMOUNT			NUMBER,				/* promise remaining amount */
    NOTE_ID                 		NUMBER				/* note_id */
);

/* Mass promise response table */
TYPE PRO_MASS_RESP_TBL IS TABLE OF PRO_MASS_RESP_REC_TYPE INDEX BY BINARY_INTEGER;

/*#
 * Use this procedure to creates a new promise for a payment schedule or lease contract.
 *
 * @param  p_api_version        Standard Parameter
 * @param  p_init_msg_list      Standard parameter
 * @param  p_commit             Standard parameter for commiting the data
 * @param  p_validation_level   Standard parameter
 * @param  x_return_status      Standard parameter
 * @param  x_msg_count          Standard parameter
 * @param  x_msg_data           Standard parameter
 * @param  P_PROMISE_REC        PL/SQL record containing promise details
 *      Record(s) Structure
 *      ~~~~~~~~~~~~~~~~~~~
 *      PROMISE_AMOUNT          Promise Amount
 *      Currency Code           Currency Code
 *      PROMISE_DATE            Promise Date
 *      PROMISE_PAYMENT_METHOD  Promise Payment Method
 *      ACCOUNT                 Payment Account (Optional)
 *      PROMISE_ITEM_NUMBER     Promise Item Number (Optional)
 *      PROMISE_TARGET          Promise Target. valid values: ACCOUNTS, INVOICES, CNSLD, CONTRACTS
 *                              (ACCOUNTS and CNSLD are no longer Used)
 *      CUST_ACCOUNT_ID         Customer Account Identifier
 *      DELINQUENCY_ID          Delinquency Identifier
 *      CONSLD_INVOICE_ID       Consolidated Invoice Identifier (Not Used)
 *      CONTRACT_ID             Contract Identifier (Applicable for Lease)
 *      CAMPAIGH_SCHED_ID       Campaigh Schedule Identifier
 *      TAKEN_BY_RESOURCE_ID    Resource Identifier of the resource who created the promise.
 *      PROMISED_BY_PARTY_REL_ID        Relationship Party Identifier
 *      PROMISED_BY_PARTY_ORG_ID        Organization Party Identifier
 *      PROMISED_BY_PARTY_PER_ID        Person Party Identifier
 *      NOTE                    Promise Note
 *      ATTRIBUTES              PL/SQL Table of Descriptive Flexfield Attributes.
 *
 * @param  X_PRORESP_REC        PL/SQL record returning the details of the created Promise.
 *      Record Structure
 *      ~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier of the created Promise
 *      NOTE_ID                 Note Identifier associated with the created Promise
 *      STATUS                  Status of the created Promise
 *      STATE                   State  of the created Promise
 *
 * return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Insert Promise
 * @rep:compatibility S
 * @rep:businessevent PROMISE
 */

PROCEDURE INSERT_PROMISE(
    P_API_VERSION		IN      NUMBER,
    P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_COMMIT                    IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL	    	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    P_PROMISE_REC               IN	IEX_PROMISES_PUB.PRO_INSRT_REC_TYPE,
    X_PRORESP_REC		OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE);

/*#
 * Use this procedure to update an existing promise for a payment schedule or a lease contract.
 *
 * @param  p_api_version        Standard Parameter
 * @param  p_init_msg_list      Standard parameter
 * @param  p_commit             Standard parameter for commiting the data
 * @param  p_validation_level   Standard parameter
 * @param  x_return_status      Standard parameter
 * @param  x_msg_count          Standard parameter
 * @param  x_msg_data           Standard parameter
 * @param  P_PROMISE_REC        PL/SQL record containing promise details
 *      Record(s) Structure
 *      ~~~~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier that needs to be updated.
 *      PROMISE_AMOUNT          Promise Amount
 *      PROMISE_DATE            Promise Date
 *      PROMISE_PAYMENT_METHOD  Promise Payment Method
 *      ACCOUNT                 Payment Account (Optional)
 *      PROMISE_ITEM_NUMBER     Promise Item Number (Optional)
 *      CAMPAIGH_SCHED_ID       Campaigh Schedule Identifier
 *      TAKEN_BY_RESOURCE_ID    Resource Identifier of the resource who created the promise.
 *      PROMISED_BY_PARTY_REL_ID        Relationship Party Identifier
 *      PROMISED_BY_PARTY_ORG_ID        Organization Party Identifier
 *      PROMISED_BY_PARTY_PER_ID        Person Party Identifier
 *      NOTE                    Promise Note
 *      ATTRIBUTES              PL/SQL Table of Descriptive Flexfield Attributes.
 *
 * @param  X_PRORESP_REC        PL/SQL record returning the details of the created Promise.
 *      Record Structure
 *      ~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier of the created Promise
 *      NOTE_ID                 Note Identifier associated with the created Promise
 *      STATUS                  Status of the created Promise
 *      STATE                   State  of the created Promise
 *
 * return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Update Promise
 * @rep:compatibility S
 * @rep:businessevent PROMISE
 */

PROCEDURE UPDATE_PROMISE(
    P_API_VERSION		IN      NUMBER,
    P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_COMMIT                    IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL	    	IN      NUMBER, --  DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    P_PROMISE_REC               IN	IEX_PROMISES_PUB.PRO_UPDT_REC_TYPE,
    X_PRORESP_REC		OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE);

/*#
 * Use this procedure to cancel a  promise.
 *
 * @param  p_api_version        Standard Parameter
 * @param  p_init_msg_list      Standard parameter
 * @param  p_commit             Standard parameter for commiting the data
 * @param  p_validation_level   Standard parameter
 * @param  x_return_status      Standard parameter
 * @param  x_msg_count          Standard parameter
 * @param  x_msg_data           Standard parameter
 * @param  P_PROMISE_REC        PL/SQL record containing promise details
 *      Record Structure
 *      ~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier that needs to be updated.
 *      TAKEN_BY_RESOURCE_ID    Resource Identifier of the resource who created the promise.
 *      PROMISED_BY_PARTY_REL_ID        Relationship Party Identifier
 *      PROMISED_BY_PARTY_ORG_ID        Organization Party Identifier
 *      PROMISED_BY_PARTY_PER_ID        Person Party Identifier
 *      NOTE                    Promise Note
 *
 * @param  X_PRORESP_REC        PL/SQL record returning the details of the created Promise.
 *      Record(s) Structure
 *      ~~~~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier of the created Promise
 *      NOTE_ID                 Note Identifier associated with the created Promise
 *      STATUS                  Status of the created Promise
 *      STATE                   State  of the created Promise
 *
 * return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Cancel Promise
 * @rep:compatibility S
 * @rep:businessevent PROMISE
 */

PROCEDURE CANCEL_PROMISE(
    P_API_VERSION		IN      NUMBER,
    P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_COMMIT                    IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL	    	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    P_PROMISE_REC               IN	IEX_PROMISES_PUB.PRO_CNCL_REC_TYPE,
    X_PRORESP_REC		OUT NOCOPY	IEX_PROMISES_PUB.PRO_RESP_REC_TYPE);


/*#
 * Use this procedure to create a mass promise for a list of payment schedules.
 * It creates a promise for the amount due for each payment schedule.
 *
 * @param  p_api_version        Standard Parameter
 * @param  p_init_msg_list      Standard parameter
 * @param  p_commit             Standard parameter for commiting the data
 * @param  p_validation_level   Standard parameter
 * @param  x_return_status      Standard parameter
 * @param  x_msg_count          Standard parameter
 * @param  x_msg_data           Standard parameter
 * @param  P_MASS_IDS_TBL       PL/SQL table of records containing Mass promise IDs
 * @param  P_MASS_PROMISE_REC   PL/SQL table of records containing Mass promise details
 *      Record(s) Structure
 *      ~~~~~~~~~~~~~~~~~~~
 *      PROMISE_DATE            Promise Date
 *      PROMISE_PAYMENT_METHOD  Promise Payment Method
 *      ACCOUNT                 Payment Account (Optional)
 *      PROMISE_ITEM_NUMBER     Promise Item Number (Optional)
 *      CAMPAIGH_SCHED_ID       Campaigh Schedule Identifier
 *      TAKEN_BY_RESOURCE_ID    Resource Identifier of the resource who created the promise.
 *      PROMISED_BY_PARTY_REL_ID        Relationship Party Identifier
 *      PROMISED_BY_PARTY_ORG_ID        Organization Party Identifier
 *      PROMISED_BY_PARTY_PER_ID        Person Party Identifier
 *      NOTE                    Promise Note
 *      ATTRIBUTES              PL/SQL Table of Descriptive Flexfield Attributes.
 *
 * @param  X_MASS_PRORESP_TBL   PL/SQL table of records containing the details of the Promises
 *                              created by the mass Promise.
 *      Record(s) Structure
 *      ~~~~~~~~~~~~~~~~~~~
 *      PROMISE_ID              Promise Identifier of the created Promise
 *      PROMISE_AMOUNT          Promise Amount
 *      CURRENCY_CODE           Currency Code
 *      CUST_ACCOUNT_ID         Customer Account Identifier
 *      CUST_SITE_USE_ID        Custome Site Use Identifier (Bill To)
 *      DELINQUENCY_ID          Delinquency Identifier
 *      STATUS                  Status of the created Promise
 *      STATE                   State  of the created Promise
 *      COLLECTABLE_AMOUNT      Collectable Amount for the Payment Schedule
 *      NOTE_ID                 Note Identifier associated with the created Promise
 *
 *  return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Mass Promise
 * @rep:compatibility S
 * @rep:businessevent PROMISE
 */

PROCEDURE MASS_PROMISE(
    P_API_VERSION		IN      NUMBER,
    P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_COMMIT                    IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    P_VALIDATION_LEVEL	    	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    X_MSG_COUNT                 OUT NOCOPY     NUMBER,
    X_MSG_DATA	    	    	OUT NOCOPY     VARCHAR2,
    P_MASS_IDS_TBL		IN	DBMS_SQL.NUMBER_TABLE,
    P_MASS_PROMISE_REC          IN	IEX_PROMISES_PUB.PRO_MASS_REC_TYPE,
    X_MASS_PRORESP_TBL		OUT NOCOPY	IEX_PROMISES_PUB.PRO_MASS_RESP_TBL);

/*#
 * Use this procedure to set the strategy for a specified delinquency associated with a promise.
 * @param  p_promise_id        Promise Identifier
 * @param  p_status            Promise Status
 *  return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Strategy
 * @rep:compatibility S
 * @rep:businessevent STRATEGY
 */

PROCEDURE SET_STRATEGY(P_PROMISE_ID IN NUMBER,
		       P_STATUS IN VARCHAR2);

/*#
 * Use this procedure to set the status for a promise in Universal Work Queue to
 * Active, Pending or Complete.
 * @param  p_api_version        Standard Parameter
 * @param  p_init_msg_list      Standard parameter
 * @param  p_commit             Standard parameter for commiting the data
 * @param  p_validation_level   Standard parameter
 * @param  x_return_status      Standard parameter
 * @param  x_msg_count          Standard parameter
 * @param  x_msg_data           Standard parameter
 * @param  p_promise_tbl        PL/SQL Table of Promise Identifiers whose UWQ status
 *                              is changed.
 * @param  p_status             UWQ Status
 * @param  p_days               Number of days the promise is pending in UWQ
 *  return N/A
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Show in UWQ
 * @rep:compatibility S
 * @rep:businessevent UWQ
 */

PROCEDURE SHOW_IN_UWQ(
    	P_API_VERSION		IN      NUMBER,
    	P_INIT_MSG_LIST		IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_COMMIT                IN      VARCHAR2, -- DEFAULT FND_API.G_FALSE,
    	P_VALIDATION_LEVEL	IN      NUMBER, -- DEFAULT FND_API.G_VALID_LEVEL_FULL,
    	X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
    	X_MSG_COUNT             OUT NOCOPY     NUMBER,
    	X_MSG_DATA	    	OUT NOCOPY     VARCHAR2,
	P_PROMISE_TBL 		IN 	DBMS_SQL.NUMBER_TABLE,
	P_STATUS 		IN 	VARCHAR2,
	P_DAYS 			IN 	NUMBER DEFAULT NULL);

Procedure update_del_stage_level (
		p_promise_id		IN		NUMBER,
		X_RETURN_STATUS		OUT NOCOPY     VARCHAR2,
		X_MSG_COUNT             OUT NOCOPY     NUMBER,
		X_MSG_DATA	    	OUT NOCOPY     VARCHAR2);

END;


/
