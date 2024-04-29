--------------------------------------------------------
--  DDL for Package AR_CREDIT_MEMO_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CREDIT_MEMO_API_PUB" AUTHID CURRENT_USER AS
/* $Header: ARWCMAPS.pls 120.6.12010000.4 2009/07/03 06:08:26 npanchak ship $ */
 /*#
 * Credit Memo Approval and Creation API lets you initiate the creation
 * of a credit memo against a specified transaction either with or
 * without an approval process.
 * @rep:scope public
 * @rep:metalink 236938.1 See OracleMetaLink note 236938.1
 * @rep:product AR
 * @rep:lifecycle active
 * @rep:displayname Credit Memo Approval and Creation
 * @rep:category BUSINESS_ENTITY AR_CREDIT_MEMO
 */

--Start of comments
--API name : ReceiptsAPI
--Type     : Public.
--Function : Create_request, Request_status
--Pre-reqs :
--

/*4556000-4606558*/
attribute_rec_const  arw_cmreq_cover.pq_attribute_rec_type;
interface_rec_const arw_cmreq_cover.pq_interface_rec_type;
global_attribute_rec_const arw_cmreq_cover.pq_global_attribute_rec_type;

TYPE interface_line_rec_type IS RECORD(
    interface_line_context        VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute1     VARCHAR2(30) DEFAULT NULL,
        interface_line_attribute2              VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute3            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute4            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute5            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute6            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute7            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute8            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute9            VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute10           VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute11           VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute12           VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute13           VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute14           VARCHAR2(30) DEFAULT NULL,
    interface_line_attribute15           VARCHAR2(30) DEFAULT NULL);

cm_line_tbl_type_cover arw_cmreq_cover.Cm_Line_Tbl_Type_Cover;


TYPE cm_notes_rec_type_cover IS RECORD
   (notes ar_notes.text%type);


TYPE cm_notes_tbl_type_cover IS TABLE of cm_notes_rec_type_cover
		       INDEX BY BINARY_INTEGER;


x_cm_notes_tbl cm_notes_tbl_type_cover;


TYPE CM_ACTIVITY_REC_TYPE_COVER is RECORD
     (begin_date               DATE,
      activity_name            VARCHAR2(80),
      status                   wf_item_activity_statuses.activity_status%type,
      result_code	       wf_item_activity_statuses.activity_result_code%type,
      user                     wf_item_activity_statuses.assigned_user%type);


TYPE CM_ACTIVITY_TBL_TYPE_COVER
     IS TABLE OF
     CM_ACTIVITY_REC_TYPE_COVER
     INDEX BY BINARY_INTEGER;


x_cm_activity_tbl CM_ACTIVITY_TBL_TYPE_COVER;

 /*#
 * Creates the Credit Memo Request workflow process
 * request.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Request
 */

PROCEDURE create_request (
      -- standard API parameters
                 p_api_version          IN  NUMBER,
                 p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
                 p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level     IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 x_return_status        OUT NOCOPY VARCHAR2,
                 x_msg_count            OUT NOCOPY NUMBER,
                 x_msg_data             OUT NOCOPY VARCHAR2,
                 -- CREDIT MEMO REQUEST PARAMETERS
                 p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%type,
                 p_line_credit_flag     IN  ra_cm_requests.line_credits_flag%type,
                 p_line_amount          IN  NUMBER 	:= 0,
                 p_tax_amount           IN  NUMBER	:= 0,
                 p_freight_amount       IN  NUMBER	:= 0,
                 p_cm_reason_code       IN  VARCHAR2,
                 p_comments             IN  VARCHAR2    DEFAULT NULL	,
                 p_orig_trx_number      IN  VARCHAR2    DEFAULT NULL,
      	  	 p_tax_ex_cert_num	IN  VARCHAR2    DEFAULT NULL,
 		 p_request_url          IN  VARCHAR2    := 'AR_CREDIT_MEMO_API_PUB.print_default_page',
                 p_transaction_url      IN  VARCHAR2    := 'AR_CREDIT_MEMO_API_PUB.print_default_page',
                 p_trans_act_url        IN  VARCHAR2    := 'AR_CREDIT_MEMO_API_PUB.print_default_page',
                 p_cm_line_tbl          IN  Cm_Line_Tbl_Type_Cover%type := cm_line_tbl_type_cover ,
-- The following parameters are used if the CM needs to be created directly and not through WF
                 p_skip_workflow_flag   IN VARCHAR2     DEFAULT 'N',
                 p_credit_method_installments IN VARCHAR2 DEFAULT NULL,
                 p_credit_method_rules  IN VARCHAR2     DEFAULT NULL,
                 p_batch_source_name    IN VARCHAR2     DEFAULT NULL,
                 p_org_id               IN NUMBER       DEFAULT NULL,
                 x_request_id           OUT NOCOPY VARCHAR2,
		 /*4606558*/
		 p_attribute_rec           IN  arw_cmreq_cover.pq_attribute_rec_type DEFAULT
                                                attribute_rec_const,
                 p_interface_attribute_rec IN  arw_cmreq_cover.pq_interface_rec_type DEFAULT
                                                        interface_rec_const,
                 p_global_attribute_rec    IN  arw_cmreq_cover.pq_global_attribute_rec_type DEFAULT
                                                        global_attribute_rec_const,
		 p_dispute_date		IN DATE	DEFAULT NULL	,-- Bug 6358930
		 p_internal_comment IN VARCHAR2 DEFAULT NULL	,/*7367350 for handling internal comment insertion*/
		 p_trx_number           IN  ra_customer_trx.trx_number%type    DEFAULT NULL
                        );

/*#
 * Use this procedure to validate request parameters
 * passed into the API.
 * request status.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Request Parameter
 */

PROCEDURE validate_request_parameters (
                 p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%type,
                 p_line_credit_flag     IN  VARCHAR2,
                 p_line_amount          IN  NUMBER,
                 p_tax_amount           IN  NUMBER,
                 p_freight_amount       IN  NUMBER,
                 p_cm_reason_code       IN  VARCHAR2,
                 p_comments             IN  VARCHAR2,
                 p_request_url          IN  VARCHAR2,
                 p_transaction_url      IN  VARCHAR2,
                 p_trans_act_url        IN  VARCHAR2,
                 p_cm_line_tbl          IN  Cm_Line_Tbl_Type_Cover%type ,
                 p_org_id               IN NUMBER       DEFAULT NULL,
                 l_val_return_status    OUT NOCOPY VARCHAR2,
		 p_dispute_date		IN DATE	DEFAULT NULL	-- Bug 6358930
			        );

/*4606558*/
PROCEDURE validate_request_parameters (
                 p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%type,
                 p_line_credit_flag     IN  VARCHAR2,
                 p_line_amount          IN  NUMBER,
                 p_tax_amount           IN  NUMBER,
                 p_freight_amount       IN  NUMBER,
                 p_cm_reason_code       IN  VARCHAR2,
                 p_comments             IN  VARCHAR2,
                 p_request_url          IN  VARCHAR2,
                 p_transaction_url      IN  VARCHAR2,
                 p_trans_act_url        IN  VARCHAR2,
                 p_cm_line_tbl          IN OUT NOCOPY Cm_Line_Tbl_Type_Cover%type ,
                 p_org_id               IN NUMBER       DEFAULT NULL,
                 l_val_return_status    OUT NOCOPY VARCHAR2,
                 /*4606558*/
                 p_skip_workflow_flag  IN VARCHAR2,
                 p_batch_source_name    IN VARCHAR2,
                 p_trx_number           IN ra_customer_trx.trx_number%type    DEFAULT NULL,
                 p_attribute_rec           IN OUT NOCOPY arw_cmreq_cover.pq_attribute_rec_type,
                 p_interface_attribute_rec IN OUT NOCOPY arw_cmreq_cover.pq_interface_rec_type,
                 p_global_attribute_rec    IN OUT NOCOPY arw_cmreq_cover.pq_global_attribute_rec_type,
		 p_dispute_date		IN DATE	DEFAULT NULL	-- Bug 6358930
                                );

 /*#
 * Use this procedure to view the Credit Memo Request workflow process.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname View Request Status
 */

PROCEDURE get_request_status
               ( -- standard API parameters
                 p_api_version          IN  NUMBER,
                 p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
                 x_msg_count            OUT NOCOPY NUMBER,
                 x_msg_data             OUT NOCOPY VARCHAR2,
		 x_return_status 	OUT NOCOPY VARCHAR2,
                 -- CREDIT MEMO REQUEST PARAMETERS
                 p_request_id  		IN  VARCHAR2,
		 x_status_meaning	OUT NOCOPY VARCHAR2,
		 x_reason_meaning	OUT NOCOPY VARCHAR2,
		 x_customer_trx_id	OUT NOCOPY ra_customer_trx.customer_trx_id%type,
		 x_cm_customer_trx_id   OUT NOCOPY ra_customer_trx.customer_trx_id%type,
		 x_line_amount		OUT NOCOPY ra_cm_requests.line_amount%type,
		 x_tax_amount		OUT NOCOPY ra_cm_requests.tax_amount%type,
		 x_freight_amount	OUT NOCOPY ra_cm_requests.freight_amount%type,
		 x_line_credits_flag	OUT NOCOPY VARCHAR2,
		 x_created_by		OUT NOCOPY wf_users.display_name%type,
		 x_creation_date	OUT NOCOPY DATE,
		 x_approval_date 	OUT NOCOPY DATE,
		 x_comments	        OUT NOCOPY ra_cm_requests.comments%type,
		 x_cm_line_tbl		OUT NOCOPY Cm_Line_Tbl_Type_Cover%type,
		 x_cm_activity_tbl	OUT NOCOPY x_cm_activity_tbl%type,
		 x_cm_notes_tbl		OUT NOCOPY x_cm_notes_tbl%type
	                                      );

PROCEDURE print_default_page;
/*4606558*/
PROCEDURE Validate_Line_Int_Flex(
    p_desc_flex_rec         IN OUT NOCOPY  interface_line_rec_type,
    p_desc_flex_name        IN VARCHAR2,
    p_return_status         IN OUT NOCOPY  varchar2
                         );

PROCEDURE Validate_Int_Desc_Flex(
    p_desc_flex_rec       IN OUT NOCOPY  arw_cmreq_cover.pq_interface_rec_type,
    p_desc_flex_name      IN VARCHAR2,
    p_return_status       IN OUT NOCOPY  varchar2
                         );

END AR_CREDIT_MEMO_API_PUB;

/
