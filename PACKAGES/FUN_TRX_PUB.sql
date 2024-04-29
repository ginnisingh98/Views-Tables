--------------------------------------------------------
--  DDL for Package FUN_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRX_PUB" AUTHID CURRENT_USER AS
/* $Header: funtrxvalinss.pls 120.10.12010000.3 2009/11/06 09:40:51 makansal ship $ */
/*#
 * This API validates the intercompany transactions and inserts the validated batch into the FUN transaction tables.
 * @rep:scope public
 * @rep:product FUN
 * @rep:lifecycle active
 * @rep:displayname Intercompany Batch Creation API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY FUN_INTERCOMPANY_BATCH
 * @rep:businessevent oracle.apps.fun.manualtrx.batch.send
 */

        TYPE Full_Batch_Rec_Type IS RECORD
        (  batch_id                     NUMBER(15),
           batch_number             	VARCHAR2(20),
           initiator_id                 NUMBER(15),
           from_le_id                  	NUMBER(15),
           from_ledger_id               NUMBER(15),
           control_total                NUMBER,
           running_total_cr         	NUMBER,
           running_total_dr         	NUMBER,
           currency_code            	VARCHAR2(15),
           exchange_rate_type   	VARCHAR2(30),
           status             		VARCHAR2(30),-- changed
           description        		VARCHAR2(240),
	   note                         VARCHAR2(240),
           trx_type_id        		NUMBER(15),
           trx_type_code    	 	VARCHAR2(15),
           gl_date           		DATE,
           batch_date 			DATE,
           reject_allow_flag     	VARCHAR2(1), -- changed
	   original_batch_id        	NUMBER(15),
	   reversed_batch_id        	NUMBER(15),
           from_recurring_batch_id 	NUMBER(15),
	   attribute1                   VARCHAR2(150),
	   attribute2                   VARCHAR2(150),
	   attribute3                   VARCHAR2(150),
	   attribute4                   VARCHAR2(150),
	   attribute5                   VARCHAR2(150),
	   attribute6                   VARCHAR2(150),
	   attribute7                   VARCHAR2(150),
	   attribute8                   VARCHAR2(150),
	   attribute9                   VARCHAR2(150),
	   attribute10                  VARCHAR2(150),
	   attribute11                  VARCHAR2(150),
	   attribute12                  VARCHAR2(150),
	   attribute13                  VARCHAR2(150),
	   attribute14                  VARCHAR2(150),
	   attribute15                  VARCHAR2(150),
	   attribute_category           VARCHAR2(150)
	);


        TYPE Full_Trx_Rec_Type IS RECORD
        (   trx_id              	NUMBER(15),
            trx_number      		VARCHAR2(15),
            initiator_id        	NUMBER(15),
            recipient_id       		NUMBER(15),
            to_le_id            	NUMBER(15),
            to_ledger_id     		NUMBER(15),
            batch_id            	NUMBER(15),
            status              	VARCHAR2(30), -- changed
            init_amount_cr      	NUMBER,
            init_amount_dr      	NUMBER,
            reci_amount_cr      	NUMBER,
            reci_amount_dr      	NUMBER,
            ar_invoice_number   	VARCHAR2(50),
            invoice_flag     		VARCHAR2(1), -- changed
            approver_id        		NUMBER(15),
            approval_date      		DATE,
            original_trx_id    		NUMBER(15),
            reversed_trx_id    		NUMBER(15),
            from_recurring_trx_id 	NUMBER(15),
            initiator_instance_flag 	VARCHAR2(1), -- changed
            recipient_instance_flag 	VARCHAR2(1), -- changed
	    reject_reason               VARCHAR2(240),
	    description                 VARCHAR2(240),
	    init_wf_key                 VARCHAR2(240),
	    reci_wf_key                 VARCHAR2(240),
	    attribute1                  VARCHAR2(150),
	    attribute2                  VARCHAR2(150),
	    attribute3                  VARCHAR2(150),
	    attribute4                  VARCHAR2(150),
	    attribute5                  VARCHAR2(150),
	    attribute6                  VARCHAR2(150),
	    attribute7                  VARCHAR2(150),
	    attribute8                  VARCHAR2(150),
	    attribute9                  VARCHAR2(150),
	    attribute10                 VARCHAR2(150),
	    attribute11                 VARCHAR2(150),
	    attribute12                 VARCHAR2(150),
	    attribute13                 VARCHAR2(150),
	    attribute14                 VARCHAR2(150),
	    attribute15                 VARCHAR2(150),
	    attribute_category          VARCHAR2(150)
	);


        TYPE Full_Init_Dist_Rec_Type IS RECORD
        (  batch_dist_id        	NUMBER(15),
           line_number          	NUMBER(15),
           batch_id            		NUMBER(15),
           ccid                		NUMBER(15),
           amount_cr   			NUMBER,
           amount_dr   			NUMBER,
	   description                  VARCHAR2(240),
           attribute1                   VARCHAR2(150),
	   attribute2                   VARCHAR2(150),
	   attribute3                   VARCHAR2(150),
	   attribute4                   VARCHAR2(150),
	   attribute5                   VARCHAR2(150),
	   attribute6                   VARCHAR2(150),
	   attribute7                   VARCHAR2(150),
	   attribute8                   VARCHAR2(150),
	   attribute9                   VARCHAR2(150),
	   attribute10                  VARCHAR2(150),
	   attribute11                  VARCHAR2(150),
	   attribute12                  VARCHAR2(150),
	   attribute13                  VARCHAR2(150),
	   attribute14                  VARCHAR2(150),
	   attribute15                  VARCHAR2(150),
	   attribute_category           VARCHAR2(150)
	);


        TYPE Full_Dist_Line_Rec_Type IS RECORD
        (  trx_id			NUMBER(15),
           dist_id      		NUMBER(15),
           line_id     			NUMBER(15),
           dist_number     		NUMBER(15),
           party_id    			NUMBER(15),
           party_type_flag  		VARCHAR2(1), -- changed
           dist_type_flag   		VARCHAR2(1), -- changed
           batch_dist_id 		NUMBER(15),
           amount_cr   			NUMBER,
           amount_dr   			NUMBER,
           ccid        			NUMBER(15),
	   description         		VARCHAR2(250),
	   auto_generate_flag   	VARCHAR2(1),
	   attribute1                   VARCHAR2(150),
	   attribute2                   VARCHAR2(150),
	   attribute3                   VARCHAR2(150),
	   attribute4                   VARCHAR2(150),
	   attribute5                   VARCHAR2(150),
	   attribute6                   VARCHAR2(150),
	   attribute7                   VARCHAR2(150),
	   attribute8                   VARCHAR2(150),
	   attribute9                   VARCHAR2(150),
	   attribute10                  VARCHAR2(150),
	   attribute11                  VARCHAR2(150),
	   attribute12                  VARCHAR2(150),
	   attribute13                  VARCHAR2(150),
	   attribute14                  VARCHAR2(150),
	   attribute15                  VARCHAR2(150),
	   attribute_category           VARCHAR2(150)
	);


        TYPE Full_Trx_Tbl_Type IS TABLE OF Full_Trx_Rec_Type INDEX BY BINARY_INTEGER;

        TYPE Full_Init_Dist_Tbl_Type IS TABLE OF Full_Init_Dist_Rec_Type INDEX BY BINARY_INTEGER;

        TYPE Full_Dist_Line_Tbl_Type IS TABLE OF Full_Dist_Line_Rec_Type INDEX BY BINARY_INTEGER;




/***********************************************
* Procedure CREATE_BATCH:				              *
*                        This Procedure Validates Intercompany Transactions and then                  *
*		Inserts Validated Batch into FUN Transaction Tables			*
 * @param p_api_version API Version
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list TRUE should be passed if the Message List is to be
 * initialized
 * @param p_commit If it is set to TRUE it commits work
 * @param p_validation_level To determine which validation steps should be executed
 * and which steps should be skipped. Defaults to FULL Validation
 * @param p_sent Sent flag, Workflow event is raised if p_sent='Y'
 * @rep:paraminfo {@rep:required}
 * @param p_calling_sequence Initializes the Stack of the Validation API's when calling_sequence is Intercompany Import Programs
 * @rep:paraminfo {@rep:required}
 * @param p_insert Insertion flag, Inserts in transaction batch table if set to TRUE or null.
 * @param p_batch_rec Transaction batch record
 * @rep:paraminfo {@rep:required}
 * @param p_trx_tbl Transaction header table
 * @rep:paraminfo {@rep:required}
 * @param p_init_dist_tbl Initiator side distributions table
 * @rep:paraminfo {@rep:required}
 * @param p_dist_lines_tbl Distribution lines table
 * @rep:paraminfo {@rep:required}
 * @return x_return_status Reports the API overall return status as Success, Error or
 * Unexpected
 * @return x_msg_count Number of messages in the API message list
 * @return x_msg_data The message in an encoded format
 * @rep:scope public
 * @rep:product FUN
 * @rep:lifecycle active
 * @rep:displayname Intercompany Batch Creation Procedure
 * @rep:businessevent oracle.apps.fun.manualtrx.batch.send
 * @rep:compatability S
										*
***************************************************/


   Procedure CREATE_BATCH(
	p_api_version 		IN NUMBER,
	p_init_msg_list 	IN VARCHAR2 default null,
	p_commit	    	IN VARCHAR2 default null,
	p_validation_level      IN NUMBER  default null,
	p_debug			IN VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count 		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	p_sent			IN VARCHAR2,
	p_calling_sequence	IN VARCHAR2,
	p_insert		IN VARCHAR2 default null,
	p_batch_rec		IN OUT NOCOPY	FULL_BATCH_REC_TYPE,
	p_trx_tbl		IN OUT NOCOPY	FULL_TRX_TBL_TYPE,
	p_init_dist_tbl		IN OUT NOCOPY	FULL_INIT_DIST_TBL_TYPE,
	p_dist_lines_tbl	IN OUT NOCOPY	FULL_DIST_LINE_TBL_TYPE
  );




END FUN_TRX_PUB;

/
