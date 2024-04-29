--------------------------------------------------------
--  DDL for Package IEX_DISPUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DISPUTE_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpdiss.pls 120.16.12010000.3 2008/09/22 12:13:31 pnaveenk ship $ */
/*#
  Creates a dispute.
  @rep:scope public
  @rep:product IEX
  @rep:displayname Create Dispute
  @rep:category BUSINESS_ENTITY IEX_COLLECTION_DISPUTE
 */

TYPE DISP_HEADER_REC IS RECORD(
     CUST_TRX_ID         NUMBER
    ,LINE_CREDIT_FLAG    VARCHAR2(10)
    ,LINE_AMT            NUMBER
    ,TAX_AMT             NUMBER
    ,FREIGHT_AMT         NUMBER
    ,CM_REASON_CODE      VARCHAR2(100)
    ,COMMENTS            VARCHAR2(2000)
    ,INTERNAL_COMMENT    varchar2(2000)    --Added for bug#7376422 by PNAVEENK on 9-sep-2008
    ,ORIG_TRX_NUMBER     VARCHAR2(100)
    ,TAX_EX_CERT_NUM     VARCHAR2(100)
    ,REQUEST_URL         VARCHAR2(1000)
    ,TRANSACTION_URL     VARCHAR2(1000)
    ,TRANS_ACT_URL       VARCHAR2(1000)
    ,DELINQUENCY_ID      NUMBER
    ,DISPUTE_SECTION     VARCHAR2(25)
    ,ATTRIBUTE_CATEGORY  VARCHAR2(30)
    ,ATTRIBUTE1          VARCHAR2(150)
    ,ATTRIBUTE2          VARCHAR2(150)
    ,ATTRIBUTE3          VARCHAR2(150)
    ,ATTRIBUTE4          VARCHAR2(150)
    ,ATTRIBUTE5          VARCHAR2(150)
    ,ATTRIBUTE6          VARCHAR2(150)
    ,ATTRIBUTE7          VARCHAR2(150)
    ,ATTRIBUTE8          VARCHAR2(150)
    ,ATTRIBUTE9          VARCHAR2(150)
    ,ATTRIBUTE10         VARCHAR2(150)
    ,ATTRIBUTE11         VARCHAR2(150)
    ,ATTRIBUTE12         VARCHAR2(150)
    ,ATTRIBUTE13         VARCHAR2(150)
    ,ATTRIBUTE14         VARCHAR2(150)
    ,ATTRIBUTE15         VARCHAR2(150));

TYPE DISPUTE_LINE_REC IS RECORD
(customer_trx_line_id   ra_customer_trx_lines.Customer_trx_line_id%type,
 extended_amount        ra_customer_trx_lines.Extended_amount%type,
 quantity_credited      NUMBER);

TYPE DISPUTE_LINE_TBL IS TABLE OF DISPUTE_LINE_REC INDEX BY binary_integer;

G_MISS_DISP_HEADER_REC  IEX_DISPUTE_PUB.DISP_HEADER_REC ;
G_MISS_DIPSUTE_LINE_TBL IEX_DISPUTE_PUB.DISPUTE_LINE_TBL ;

/*#
 Enters a header level dispute.
 @rep:scope public
 @rep:displayname Create Header Dispute Record
 @rep:category BUSINESS_ENTITY IEX_COLLECTION_DISPUTE
*/
FUNCTION init_disp_rec RETURN DISP_HEADER_REC;

/*#
 Enters a line level dispute.
 @rep:scope public
 @rep:displayname Create Line Level Dispute
 @rep:category BUSINESS_ENTITY  IEX_COLLECTION_DISPUTE
*/
FUNCTION init_disp_line_tbl RETURN DISPUTE_LINE_TBL;

/*#
 * Use this procedure to creates a new dispute.
 *
 * @param p_api_version   API version number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param  x_request_id   request identifier
 * @param  p_disp_header_rec        PL/SQL record containing promise details
 * @param  p_disp_line_tbl        PL/SQL record returning the line details for the dispute.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Dispute
 * @rep:compatibility S
 * @rep:businessevent DISPUTE
 * @rep:category BUSINESS_ENTITY  IEX_COLLECTION_DISPUTE
 */
  PROCEDURE Create_Dispute(p_api_version     IN NUMBER,
                          p_init_msg_list   IN VARCHAR2,
                          p_commit          IN VARCHAR2,
                          p_disp_header_rec IN IEX_DISPUTE_PUB.DISP_HEADER_REC ,
                          p_disp_line_tbl   IN IEX_DISPUTE_PUB.DISPUTE_LINE_TBL,
			  x_request_id      OUT NOCOPY NUMBER,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
			  p_skip_workflow_flag   IN VARCHAR2    DEFAULT 'N',
			  p_batch_source_name    IN VARCHAR2    DEFAULT NULL,
			  p_dispute_date	IN DATE	DEFAULT NULL);

/*#
 * Use this procedure to check if a delinquency is already disputed.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param  p_delinquency_id     Delinquency Identifier
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Dispute
 * @rep:compatibility S
 */
PROCEDURE is_delinquency_dispute(p_api_version         IN  NUMBER ,
                                 p_init_msg_list       IN  VARCHAR2,
                                 p_delinquency_id      IN  NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2);

--Start bug 6856035 gnramasa 28th May 08
PROCEDURE CANCEL_DISPUTE (p_api_version     IN NUMBER,
                          p_commit          IN VARCHAR2,
			  p_dispute_id      IN NUMBER,
			  p_cancel_comments IN VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2);
--End bug 6856035 gnramasa 28th May 08

END IEX_DISPUTE_PUB ;

/
