--------------------------------------------------------
--  DDL for Package IBY_PAYMENT_ADAPTER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYMENT_ADAPTER_PUB" AUTHID CURRENT_USER AS
/* $Header: ibyppads.pls 120.22.12010000.9 2009/10/07 11:47:38 sgogula ship $ */
/*#
 * The IBY_PAYMENT_ADAPTER_PUB package provides payment processing APIs.
 * These include all standard payment APIs as well as query and batch APIs.
 *
 * @rep:scope public
 * @rep:product IBY
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Processing
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 * @rep:doccd iby120ig.pdf Implementing APIs, Oracle iPayment Implementation Guide
 */

-- module name used for the application debugging framework
--
G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_PAYMENT_ADAPTER_PUB';

-- results interface code
--
G_INTERFACE_CODE CONSTANT VARCHAR2(30) := 'PMT_ADAPTER';

-- constant for org_type default value
C_ORG_TYPE_OPERATING_UNIT CONSTANT VARCHAR2(30) := 'OPERATING_UNIT';


-------------------------------------------------------------------------
	--**Defining all DataStructures required by the APIs**--
--  The following input and output PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the EC-App PL/SQL APIs.
-------------------------------------------------------------------------
--INPUT DataStructures
  --1. Payments Related Generic Record Types

TYPE Payee_rec_type IS RECORD (
        Payee_ID        VARCHAR2(80)
        );

TYPE Payer_rec_type IS RECORD (
        party_id        NUMBER(15)
        );
--
-- Dual Payment Instrument Record type
--
TYPE DualPaymentInstr_rec_type IS RECORD (
        PmtInstr_ID        NUMBER,
        PmtInstr_ShortName VARCHAR2(80),
        BnfPmtInstr_ID        NUMBER,
        BnfPmtInstr_ShortName VARCHAR2(80)
        );

TYPE PmtInstr_rec_type IS RECORD (
        PmtInstr_ID        NUMBER,
        PmtInstr_Type      VARCHAR2(30),
        PmtInstr_ShortName VARCHAR2(80),
	DualPaymentInstr DualPaymentInstr_rec_type,
        PmtInstr_Assignment_ID  NUMBER
        );

TYPE Tangible_rec_type IS RECORD (
	Tangible_ID     VARCHAR2(80),
        Tangible_Amount NUMBER,
        Currency_Code   VARCHAR2(80),
        RefInfo         VARCHAR2(80),
        Memo            VARCHAR2(80),
        Acct_Num        VARCHAR2(80),
        OrderMedium     VARCHAR2(30),
        EFTAuthMethod   VARCHAR2(30)
        );

G_AUTHTYPE_AUTHONLY CONSTANT VARCHAR2(30) := 'AUTHONLY';
G_AUTHTYPE_VERIFY CONSTANT VARCHAR2(30) := 'VERIFY';

   --2. Payment Transactions Related Record Types
   /* PmtMode(On-line = 'ONLINE', Off-line = 'OFFLINE') */
   --Added New field Retry_Flag (12/16/99)
   --Added 4 new fields for PCard support (06/13/00)
   --Added the flag AnalyzeRisk (06/29/00)
   -- Added Receipt_Method_Id for Bug# 7707005.PAYEE ROUTING RULES ON RECEIPT METHOD QUALIFIER ARE NOT WORKING.

TYPE PmtReqTrxn_rec_type IS RECORD (
        Trxn_Extension_Id           NUMBER,
        PmtMode   	    	    VARCHAR2(30) := 'ONLINE',
        CVV2	             	    VARCHAR2(10) := NULL,
	CVV2_Segment_id             NUMBER,
	CVV2_Length                 NUMBER,
        Settlement_Date             DATE,
        Auth_Type                   VARCHAR2(80),
        Check_Flag                  VARCHAR2(30),
        Retry_Flag                  VARCHAR2(30),
        Org_ID                      NUMBER,
        org_type                    VARCHAR2(30) := C_ORG_TYPE_OPERATING_UNIT,
        NLS_LANG                    VARCHAR2(80),
	PONum        		    NUMBER,
	TaxAmount        	    NUMBER,
	ShipFromZip        	    VARCHAR2(80),
	ShipToZip        	    VARCHAR2(80),
	AnalyzeRisk        	    VARCHAR2(80),
	AuthCode                    VARCHAR2(255),
	VoiceAuthFlag               VARCHAR2(30),
        TrxnRef                     VARCHAR2(240),
        DateOfVoiceAuthorization    DATE,
        Payment_Factor_Flag         VARCHAR2(1),
        payment_channel_code        VARCHAR2(30),
	Receipt_Method_Id           NUMBER,
	Int_Bank_Country_Code       VARCHAR2(30)
        );

TYPE ModTrxn_rec_type IS RECORD (
        Trxn_ID         NUMBER,
        PmtMode         VARCHAR2(30),
        Settlement_Date DATE,
        Check_Flag      VARCHAR2(30),
        Auth_Type       VARCHAR2(80),
	PONum		NUMBER,
	TaxAmount	NUMBER,
	ShipFromZip	VARCHAR2(80),
	ShipToZip	VARCHAR2(80)
        );

TYPE CaptureTrxn_rec_type IS RECORD (
	Trxn_ID         NUMBER,
        PmtMode         VARCHAR2(30),
        Settlement_Date DATE,
        Currency        VARCHAR2(80),
        Price           NUMBER,
        TrxnRef         VARCHAR2(240),
        NLS_LANG        VARCHAR2(80)
        );

TYPE CaptureTrxn_tbl IS TABLE of CaptureTrxn_rec_type INDEX BY BINARY_INTEGER;

C_MAX_CC_BATCH_SIZE  CONSTANT  INTEGER := 100;


TYPE ReturnTrxn_rec_type IS RECORD (
        Trxn_ID         NUMBER,
        PmtMode         VARCHAR2(30),
        Settlement_Date DATE,
        Currency        VARCHAR2(80),
        Price           NUMBER,
        TrxnRef         VARCHAR2(240),
        NLS_LANG        VARCHAR2(80)
        );

TYPE CancelTrxn_rec_type IS RECORD (
        Trxn_ID         NUMBER,
        Req_Type        VARCHAR2(80),
        NLS_LANG        VARCHAR2(80)
        );

TYPE QueryTrxn_rec_type IS RECORD (
        Trxn_ID         NUMBER,
	History_Flag    VARCHAR2(30),
        NLS_LANG        VARCHAR2(80)
        );

TYPE VoidTrxn_rec_type IS RECORD (
        Trxn_ID         NUMBER,
        PmtMode         VARCHAR2(30),
        Settlement_Date DATE,
        Trxn_Type       NUMBER,
        TrxnRef         VARCHAR2(240),
        NLS_LANG        VARCHAR2(80)
        );

TYPE CreditTrxn_rec_type IS RECORD (
        PmtMode         VARCHAR2(30),
        Settlement_Date DATE,
        Retry_Flag      VARCHAR2(30),
        Payer_Party_ID  NUMBER,
        Org_ID          NUMBER,
        org_type        VARCHAR2(30)  := C_ORG_TYPE_OPERATING_UNIT,
        TrxnRef         VARCHAR2(240),
        NLS_LANG        VARCHAR2(80),
        payment_channel_code        VARCHAR2(30)
        );

--NOTE: PmtType optional field is newly added to be
--used only for closebatch operation.
TYPE BatchTrxn_rec_type IS RECORD (
        PmtMode         VARCHAR2(30),
        PmtType         VARCHAR2(30),
        PmtInstrType    VARCHAR2(30),
        Settlement_Date DATE,
        Payee_ID        VARCHAR2(80),
	BEP_Suffix	VARCHAR2(80),
	BEP_Account	VARCHAR2(80),
	MerchBatch_ID   VARCHAR2(80),
        NLS_LANG        VARCHAR2(80),
        Account_Profile VARCHAR2(30)
        );

--3. iPayment 11i Risk Management Record Types

TYPE RiskInfo_rec_type IS RECORD (
        Formula_Name         VARCHAR2(80)  := FND_API.G_MISS_CHAR,
        ShipToBillTo_Flag    VARCHAR2(255) := FND_API.G_MISS_CHAR,
        Time_Of_Purchase     VARCHAR2(80)  := FND_API.G_MISS_CHAR,
        Customer_Acct_Num    VARCHAR2(30)  := FND_API.G_MISS_CHAR
        -- ,
        -- Org_ID               NUMBER        := FND_API.G_MISS_NUM
        );

TYPE PaymentRiskInfo_rec_type IS RECORD (
        Formula_Name         VARCHAR2(80)  ,
        Payee_ID             VARCHAR2(80)  ,
        Amount               NUMBER        ,
        Party_Id             NUMBER(15)    ,
        PmtInstr             PmtInstr_rec_type,
        ShipToBillTo_Flag    VARCHAR2(255) ,
        Time_Of_Purchase     VARCHAR2(80)  ,
        Customer_Acct_Num    VARCHAR2(30)  ,
        AVSCode              VARCHAR2(80)  ,
        Currency_Code        VARCHAR2(80)

        -- ,
        -- Org_ID               NUMBER        := FND_API.G_MISS_NUM
        );

TYPE AVSRiskInfo_rec_type IS RECORD (
        Formula_Name         VARCHAR2(80)  ,
        Payee_ID             VARCHAR2(80)  ,
        Previous_Risk_Score  NUMBER        ,
        AVSCode              VARCHAR2(80)
        );


G_MISS_RISKINFO_REC RiskInfo_rec_type;

FUNCTION Is_RiskInfo_rec_Missing (
                                  RiskInfo_rec in RiskInfo_rec_type
                                  ) RETURN BOOLEAN;

-- OUTPUT value constants
--

C_TRXN_STATUS_SUCCESS CONSTANT INTEGER := 0;
C_TRXN_STATUS_INFO CONSTANT INTEGER := 1;
C_TRXN_STATUS_WARNING CONSTANT INTEGER := 2;
C_TRXN_STATUS_ERROR CONSTANT INTEGER := 3;


--OUTPUT DataStructures
--1. iPayment Response Record Types
TYPE Response_rec_type IS RECORD (
        Status          NUMBER,
        ErrCode         VARCHAR2(80),
        ErrMessage      VARCHAR2(255),
        NLS_LANG        VARCHAR2(80)
        );

--2. OffLine Mode Response Record Types
TYPE OffLineResp_rec_type IS RECORD (
        EarliestSettlement_Date   DATE,
        Scheduled_Date            DATE
        );

--3. Risk Response Record Types
TYPE RiskResp_rec_type IS RECORD (
        Status                NUMBER,
        ErrCode               VARCHAR2(80),
        ErrMessage            VARCHAR2(255),
        Additional_ErrMessage VARCHAR2(255),
        Risk_Score            NUMBER,
        Risk_Threshold_Val    NUMBER,
        Risky_Flag            VARCHAR2(30),
	AVSCode_Flag	      VARCHAR2(30)
        );

--4. Payment Transactions Response Record Types
	-- Note: Need to add EarliestSettlementDate,
	-- ScheduleDate later, based on BEPs.
	-- Note: RiskRespIncluded is a flag that tells the ECAPP that the
	--       RiskResonse Record has some valid Risk related Response info.

TYPE ReqResp_rec_type IS RECORD (
        Response          Response_rec_type,
        OffLineResp       OffLineResp_rec_type,
        RiskRespIncluded  VARCHAR2(30),
        RiskResponse      RiskResp_rec_type,
	Trxn_ID           NUMBER,
        Trxn_Type         NUMBER,
        Trxn_Date         DATE,
        Authcode          VARCHAR2(80),
        RefCode           VARCHAR2(80),
        AVSCode           VARCHAR2(80),
        CVV2Result	  VARCHAR2(5),
        PmtInstr_Type     VARCHAR2(80),
        Acquirer          VARCHAR2(80),
        VpsBatch_ID       VARCHAR2(80),
        AuxMsg            VARCHAR2(255),
        ErrorLocation     NUMBER,
        BEPErrCode        VARCHAR2(80),
        BEPErrMessage     VARCHAR2(255)
        );

TYPE ModResp_rec_type IS RECORD (
        Response        Response_rec_type,
        OffLineResp     OffLineResp_rec_type,
        Trxn_ID         NUMBER
        );

TYPE VoidResp_rec_type IS RECORD (
        Response        Response_rec_type,
        OffLineResp     OffLineResp_rec_type,
        Trxn_ID         NUMBER,
	Trxn_Type       NUMBER,
	Trxn_Date       DATE,
        RefCode         VARCHAR2(80),
        PmtInstr_Type   VARCHAR2(80),
	ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE CancelResp_rec_type IS RECORD (
        Response        Response_rec_type,
        Trxn_ID         NUMBER,
	ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE CaptureResp_rec_type IS RECORD (
        Response        Response_rec_type,
        OffLineResp     OffLineResp_rec_type,
        Trxn_ID         NUMBER,
	Trxn_Type       NUMBER,
	Trxn_Date       DATE,
        PmtInstr_Type   VARCHAR2(80),
        RefCode         VARCHAR2(80),
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE CaptureRespAll_rec_type IS RECORD (
        --Response_rec_type--
        Status                   NUMBER,
        ErrCode                  VARCHAR2(80),
        ErrMessage               VARCHAR2(255),
        NLS_LANG                 VARCHAR2(80),
        --OffLineResp_rec_type--
        EarliestSettlement_Date  DATE,
        Scheduled_Date           DATE,

        Trxn_ID                  NUMBER,
        Trxn_Type                NUMBER,
        Trxn_Date                DATE,
        PmtInstr_Type            VARCHAR2(80),
        RefCode                  VARCHAR2(80),
        ErrorLocation            NUMBER,
        BEPErrCode               VARCHAR2(80),
        BEPErrMessage            VARCHAR2(255)
        );
TYPE CaptureResp_tbl IS TABLE of CaptureRespAll_rec_type INDEX BY BINARY_INTEGER;


TYPE ReturnResp_rec_type IS RECORD (
        Response        Response_rec_type,
        OffLineResp     OffLineResp_rec_type,
        Trxn_ID         NUMBER,
        Trxn_Type       NUMBER,
        Trxn_Date       DATE,
	PmtInstr_Type   VARCHAR2(80),
        RefCode         VARCHAR2(80),
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE CreditResp_rec_type IS RECORD (
        Response        Response_rec_type,
        OffLineResp     OffLineResp_rec_type,
        Trxn_ID         NUMBER,
        Trxn_Type       NUMBER,
        Trxn_Date       DATE,
        PmtInstr_Type   VARCHAR2(80),
        RefCode         VARCHAR2(80),
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE InqResp_rec_type IS RECORD (
        Response        Response_rec_type,
        Payer           Payer_rec_type,
        Payee           Payee_rec_type,
        Tangible        Tangible_rec_type,
        PmtInstr        PmtInstr_rec_type
        );

TYPE QryTrxnRespSum_rec_type IS RECORD (
        Response        Response_rec_type,
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE QryTrxnRespDet_rec_type IS RECORD (
        Status          NUMBER,
        StatusMsg       VARCHAR2(255),
        Trxn_ID         NUMBER,
        Trxn_Type       NUMBER,
        Trxn_Date       DATE,
        PmtInstr_Type   VARCHAR2(80),
        Currency        VARCHAR2(80),
	Price           NUMBER,
        RefCode         VARCHAR2(80),
        AuthCode        VARCHAR2(80),
        AVSCode         VARCHAR2(80),
        Acquirer        VARCHAR2(80),
        VpsBatch_ID     VARCHAR2(80),
        AuxMsg          VARCHAR2(255),
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255)
        );

TYPE QryTrxnRespDet_tbl_type IS TABLE OF QryTrxnRespDet_rec_type
        INDEX BY BINARY_INTEGER;


--5. Batch Payment Transactions Response Record Types

TYPE BatchRespSum_rec_type IS RECORD (
        Response         Response_rec_type,
        OffLineResp      OffLineResp_rec_type,
        NumTrxns         NUMBER,
        MerchBatch_ID    VARCHAR2(80),
        BatchState       NUMBER,
        BatchDate        DATE,
        Credit_Amount    NUMBER,
        Sales_Amount     NUMBER,
        Batch_Total      NUMBER,
        Payee_ID         VARCHAR2(80),
        VpsBatch_ID      VARCHAR2(80),
        GWBatch_ID       VARCHAR2(80),
	Currency         VARCHAR2(80),
        ErrorLocation    NUMBER,
        BEPErrCode       VARCHAR2(80),
        BEPErrMessage    VARCHAR2(255)
        );

TYPE BatchRespDet_rec_type IS RECORD (
        Trxn_ID         NUMBER,
        Trxn_Type       NUMBER,
        Trxn_Date       DATE,
        Status          NUMBER,
        ErrorLocation   NUMBER,
        BEPErrCode      VARCHAR2(80),
        BEPErrMessage   VARCHAR2(255),
        NLS_LANG        VARCHAR2(80)
        );

TYPE SecureCVVResp_rec_type IS RECORD (
        Response        Response_rec_type,
        Segment_ID      NUMBER
	);


TYPE BatchRespDet_tbl_type IS TABLE OF BatchRespDet_rec_type
        INDEX BY BINARY_INTEGER;

--6. Utility Table Type
/* Note: This is a utility table to be used for storing names,
   values of name-value pairs. */
TYPE v240_tbl_type IS TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;

-- Misc. constants
--

C_ECAPP_URL_PROP_NAME CONSTANT VARCHAR2(50) := 'IBY_ECAPP_URL';


---------------------------------------------------------------
                      -- API Signatures--
---------------------------------------------------------------
/*#
 * The OraPmtReq API Submits a credit card/purchase card authorization request.
 * This API can also be used to transfer funds from a bank account,
 * such as ACH payment requests and to verify the bank account information.
 *
 * This API is available in overloaded form without risk-related
 * input parameters.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard; use FND_API.G_FALSE by
 *     default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id product identifier of the calling application
 * @param p_payee_rec entity that stores the attributes of the payee
 * @param p_payer_rec entity that stores the attributes of the payer
 * @param p_pmtinstr_rec entity that stores the attributes of the payment
 * instrument. A payment instrument can be a credit card, purchase card, debit
 * card  or bank account. Instrument registration is required before
 * calling this API.
 * @param p_tangible_rec entity that stores the attributes of an order or bill.
 *     The tangible identifier is used to identify a transaction, so it must be unique
 *     for a given payee.
 * @param p_pmtreqtrxn_rec entity that stores the attributes of the
 *     authorization request. This entity is used in specifying whether
 *     authorization is online or offline, the type of the authorization
 *     (authonly, authcapture, or verify for ACH), etc...
 * @param p_riskinfo_rec entity that stores the risk management attributes
 * @param x_return_status indicates the return status of the procedure -
 *     'S' indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_reqresp_rec entity that stores the attrbutes of the authorization
 *     response
 * @rep:scope public
 * @rep:displayname Perform Credit Card Authorization or ACH Transfer
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--1. OraPmtReq
  PROCEDURE OraPmtReq (	p_api_version		IN	NUMBER,
			p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
			p_commit		IN	VARCHAR2  := FND_API.G_FALSE,
			p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			p_ecapp_id 		IN 	NUMBER,
			p_payee_rec 		IN	Payee_rec_type,
			p_payer_rec  	        IN	Payer_rec_type,
			p_pmtinstr_rec 	        IN	PmtInstr_rec_type,
			p_tangible_rec	 	IN	Tangible_rec_type,
			p_pmtreqtrxn_rec 	IN	PmtReqTrxn_rec_type,
			p_riskinfo_rec		IN	RiskInfo_rec_type
							:= IBY_PAYMENT_ADAPTER_PUB.G_MISS_RISKINFO_REC,
			x_return_status		OUT NOCOPY VARCHAR2,
			x_msg_count		OUT NOCOPY NUMBER,
			x_msg_data		OUT NOCOPY VARCHAR2,
			x_reqresp_rec		OUT NOCOPY ReqResp_rec_type
			);

/*#
 * The OraPmtMod API Modifies an existing, deferred, scheduled payment request.
 * Payment requests can only be modified before requests are sent to the payment system.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_payee_rec record that stores the attributes of the payee
 * @param p_payer_rec record that stores the attributes of the payer
 * @param p_pmtinstr_rec record that stores the attributes of the payment instrument. A payment instrument can be a credit card, purchase card or bank account
 * @param p_tangible_rec record that stores the attributes of an order or bill. The tangible identifier is used to identify a transaction, so it must be unique for a given payee.
 * @param p_ModTrxn_rec record that specifies the request to modify, as well as containing request attributes, which over-write those originally submitted
 * @param x_return_status indicates the return status of the procedure 'S' indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_modresp_rec record that stores the attributes of the modification response
 *  The result of the modification request is returned in parameter x_modresp_rec
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Modification
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--2. OraPmtMod
  PROCEDURE OraPmtMod ( p_api_version		IN	NUMBER,
			p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
			p_commit		IN	VARCHAR2  := FND_API.G_FALSE,
			p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			p_ecapp_id 		IN 	NUMBER,
			p_payee_rec 		IN	Payee_rec_type,
			p_payer_rec 		IN	Payer_rec_type,
			p_pmtinstr_rec 	        IN	PmtInstr_rec_type,
			p_tangible_rec 		IN	Tangible_rec_type,
			p_ModTrxn_rec 	        IN	ModTrxn_rec_type,
			x_return_status		OUT NOCOPY VARCHAR2,
			x_msg_count		OUT NOCOPY NUMBER,
			x_msg_data		OUT NOCOPY VARCHAR2,
			x_modresp_rec		OUT NOCOPY ModResp_rec_type
			);

/*#
 * The OraPmtCanc API Cancels an existing, deferred, scheduled payment
 * request while the request is still in Pending status.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_canctrxn_rec record which identifies the request to cancel
 * @param x_return_status indicates the return status of the procedure; 'S' indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_cancresp_rec record that stores the attributes of the cancellation response
 *  The result of the cancellation request is returned in parameter x_modresp_rec
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Cancellation
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--3. OraPmtCanc
  PROCEDURE OraPmtCanc ( p_api_version		IN	NUMBER,
			 p_init_msg_list	IN	VARCHAR2  := FND_API.G_FALSE,
			 p_commit		IN	VARCHAR2  := FND_API.G_FALSE,
			 p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			 p_ecapp_id		IN	NUMBER,
			 p_canctrxn_rec		IN	CancelTrxn_rec_type,
			 x_return_status	OUT NOCOPY VARCHAR2,
			 x_msg_count		OUT NOCOPY NUMBER,
			 x_msg_data		OUT NOCOPY VARCHAR2,
			 x_cancresp_rec		OUT NOCOPY CancelResp_rec_type
			 );

/*#
 * The OraPmtQryTrxn API Queries the status of a payment request that was submitted to
 * a payment system. The payment system is contacted by a call to this API, and the
 * data that the API returns is stored in the Oracle Payments schema.  This API
 * synchronizes Oracle Payments' data with the payment system.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_querytrxn_rec record which identifies the request to query
 * @param x_return_status indicates the return status of the procedure 'S' indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_qrytrxnrespsum_rec record which stores a query result summary
 * @param x_qrytrxnrespdet_tbl record that stores a collection of query result details; multiple details will be returned if the history flag is turned on, one for every distinct request type associated with the given transaction identifier
 *  The result of the query request is returned in the two query response parameters
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Query
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--4. OraPmtQryTrxn
  PROCEDURE OraPmtQryTrxn ( p_api_version	   IN	NUMBER,
			    p_init_msg_list	   IN	VARCHAR2  := FND_API.G_FALSE,
			    p_commit		   IN	VARCHAR2  := FND_API.G_FALSE,
			    p_validation_level	   IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			    p_ecapp_id		   IN 	NUMBER,
			    p_querytrxn_rec 	   IN	QueryTrxn_rec_type,
			    x_return_status	   OUT NOCOPY VARCHAR2,
			    x_msg_count	           OUT NOCOPY NUMBER,
			    x_msg_data		   OUT NOCOPY VARCHAR2,
			    x_qrytrxnrespsum_rec   OUT NOCOPY QryTrxnRespSum_rec_type,
			    x_qrytrxnrespdet_tbl   OUT NOCOPY QryTrxnRespDet_tbl_type
			    );

/*#
 * The OraPmtCapture API Submits a credit card/purchase card capture request.
 * A previously authorized payment request is a prerequisite for a capture.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard; use FND_API.G_FALSE by
 *     default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_capturetrxn_rec entity that stores the attributes of the capture
 *     request
 * @param x_return_status indicates the return status of the procedure; 'S'
 *     indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_capresp_rec entity that stores the attributes of the capture
 *     response
 * @rep:scope public
 * @rep:displayname Perform Credit Card Capture
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--5. OraPmtCapture
  PROCEDURE OraPmtCapture ( p_api_version	IN	NUMBER,
			    p_init_msg_list	IN	VARCHAR2  := FND_API.G_FALSE,
			    p_commit		IN	VARCHAR2  := FND_API.G_FALSE,
			    p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			    p_ecapp_id 		IN	NUMBER,
			    p_capturetrxn_rec 	IN	CaptureTrxn_rec_type,
			    x_return_status	OUT NOCOPY VARCHAR2,
			    x_msg_count		OUT NOCOPY NUMBER,
			    x_msg_data		OUT NOCOPY VARCHAR2,
			    x_capresp_rec	OUT NOCOPY CaptureResp_rec_type
			    );

/*#
 * The OraPmtReturn API Submits a credit card/purchase card return funds
 * (refund) request. This transaction moves money from the merchant's account
 * to the customer's account. As the refund is made against a previously
 * submitted capture, you must submit the tangible identifier of the previous capture
 * in this request.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard; use FND_API.G_FALSE by
 *     default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id the product id of the calling application
 * @param p_returntrxn_rec entity that stores the attributes of the return
 *     request
 * @param x_return_status indicates the return status of the procedure; 'S'
 *     indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_retresp_rec entity that stores the attributes of the return response
 * @rep:scope public
 * @rep:displayname Perform Credit Card Return
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */

--6. OraPmtReturn
  PROCEDURE OraPmtReturn ( p_api_version	IN	NUMBER,
			   p_init_msg_list	IN	VARCHAR2  := FND_API.G_FALSE,
			   p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
			   p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			   p_ecapp_id 		IN	NUMBER,
			   p_returntrxn_rec 	IN	ReturnTrxn_rec_type,
			   x_return_status	OUT NOCOPY VARCHAR2,
			   x_msg_count		OUT NOCOPY NUMBER,
			   x_msg_data		OUT NOCOPY VARCHAR2,
			   x_retresp_rec	OUT NOCOPY ReturnResp_rec_type
			   );

/*#
 * The oraPmtVoid API Voids a previously submitted capture request. Only
 * those captures that are pending in Oracle iPayment can be voided. Captures
 * that were already submitted to a credit card processor/gateway cannot be
 * voided.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard;use FND_API.G_FALSE by
 *     default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_voidtrxn_rec entity that stores the attributes of the void request
 * @param x_return_status indicates the return status of the procedure; 'S'
 *     indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_voidresp_rec entity that stores the attributes of the void response
 * @rep:scope public
 * @rep:displayname Perform Credit Card Void
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */

--7. OraPmtVoid
  PROCEDURE OraPmtVoid ( p_api_version		IN	NUMBER,
			 p_init_msg_list	IN	VARCHAR2  := FND_API.G_FALSE,
			 p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
			 p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			 p_ecapp_id		IN	NUMBER,
			 p_voidtrxn_rec 	IN	VoidTrxn_rec_type,
			 x_return_status	OUT NOCOPY VARCHAR2,
			 x_msg_count		OUT NOCOPY NUMBER,
			 x_msg_data		OUT NOCOPY VARCHAR2,
			 x_voidresp_rec	        OUT NOCOPY VoidResp_rec_type
			 );

/*#
 * The oraPmtCredit API Submits a credit card/purchase card refund request.
 * This transaction moves funds from the merchant's account to the customer's
 * account. A credit transaction can be made without reference to any previous
 * capture transaction.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard; use FND_API.G_FALSE
 *     by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_payee_rec entity that stores the attributes of the payee
 * @param p_pmtinstr_rec entity that stores the attributes of the payment
 *     instrument
 * @param p_tangible_rec entity that stores the attributes of an order or bill.
 *     The tangible id is used to identify a transaction, so it must be unique
 *     for a given payee.
 * @param p_credittrxn_rec entity that stores the attributes of the credit
 *     request
 * @param x_return_status indicates the return status of the procedure; 'S'
 *     indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_creditresp_rec entity that stores the attributes of the credit
 *     response
 * @rep:scope public
 * @rep:displayname Perform a Credit Card Refund
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */

--8. OraPmtCredit
  PROCEDURE OraPmtCredit ( p_api_version	IN	NUMBER,
			   p_init_msg_list	IN	VARCHAR2  := FND_API.G_FALSE,
			   p_commit		IN	VARCHAR2 := FND_API.G_FALSE,
			   p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			   p_ecapp_id 		IN	NUMBER,
			   p_payee_rec 		IN	Payee_rec_type,
			   p_pmtinstr_rec 	IN	PmtInstr_rec_type,
			   p_tangible_rec	IN	Tangible_rec_type,
			   p_credittrxn_rec 	IN	CreditTrxn_rec_type,
			   x_return_status	OUT NOCOPY VARCHAR2,
			   x_msg_count		OUT NOCOPY NUMBER,
			   x_msg_data		OUT NOCOPY VARCHAR2,
			   x_creditresp_rec	OUT NOCOPY CreditResp_rec_type
			   );

/*#
 * The OraPmtInq API Queries the details of a payment transaction. The results  returned
 * are payment transactions that are currently stored in the product schema.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id the product id of the calling application
 * @param p_tid transaction identifier of the transaction to query
 * @param x_return_status indicates the return status of the procedure 'S' indicates a success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_inqresp_rec record which stores the inquiry result
 *  The result of the query request is returned in the two query response parameters
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Inquiry
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--9. OraPmtInq
  PROCEDURE OraPmtInq ( p_api_version		IN	NUMBER,
			p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
			p_commit	        IN	VARCHAR2 := FND_API.G_FALSE,
			p_validation_level	IN	NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			p_ecapp_id		IN	NUMBER,
			p_tid			IN	NUMBER,
			x_return_status		OUT NOCOPY VARCHAR2,
			x_msg_count		OUT NOCOPY NUMBER,
			x_msg_data		OUT NOCOPY VARCHAR2,
			x_inqresp_rec		OUT NOCOPY InqResp_rec_type
			);

/*#
 * The OraPmtCloseBatch API Closes a batch of transactions, which might be a mandatory
 * step for final settlement of funds, depending on the payment system.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id product identifier of the calling application
 * @param p_batchtrxn_rec record that defines the batch, particularly its name and its owning payee
 * @param x_return_status indicates the return status of the procedure; 'S' indicates success, 'U' an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_closebatchrespsum_rec record that stores the batch close result summary
 * @param x_closebatchrespdet_tbl record that stores a collection of batch close result details, with one detail for every payment transaction within the batch
 *  The result of the batch close request is returned in the two batch close response parameters
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Batch Close
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--10. OraPmtCloseBatch
  PROCEDURE OraPmtCloseBatch ( p_api_version	       IN	NUMBER,
		   	       p_init_msg_list	       IN	VARCHAR2  := FND_API.G_FALSE,
			       p_commit		       IN	VARCHAR2  := FND_API.G_FALSE,
			       p_validation_level      IN       NUMBER  := FND_API.G_VALID_LEVEL_FULL,
			       p_ecapp_id	       IN	NUMBER,
			       p_batchtrxn_rec	       IN	BatchTrxn_rec_type,
			       x_return_status	       OUT NOCOPY VARCHAR2,
			       x_msg_count	       OUT NOCOPY NUMBER,
			       x_msg_data	       OUT NOCOPY VARCHAR2,
			       x_closebatchrespsum_rec OUT NOCOPY BatchRespSum_rec_type,
			       x_closebatchrespdet_tbl OUT NOCOPY BatchRespDet_tbl_type
			   );

/*#
 * The OraPmtQueryBatch API Queries a previously closed batch of transactions, which
 * may be required for the transactions to achieve a Final status.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL by default
 * @param p_ecapp_id the product identifier of the calling application
 * @param p_batchtrxn_rec record that identifies the batch to query
 * @param x_return_status indicates the return status of the procedure; 'S' indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_qrybatchrespsum_rec record that stores the batch query summary
 * @param x_qrybatchrespdet_tbl record that stores a collection of transaction details, with one for every payment transaction within the batch
 *  The result of the batch query request is returned in the two batch query response parameters
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Credit Card Payment Batch Query
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */
--11. OraPmtQueryBatch
  PROCEDURE OraPmtQueryBatch ( p_api_version	     IN	  NUMBER,
		   	       p_init_msg_list	     IN	  VARCHAR2  := FND_API.G_FALSE,
			       p_commit		     IN	  VARCHAR2  := FND_API.G_FALSE,
			       p_validation_level    IN	  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   			       p_ecapp_id	     IN	  NUMBER,
			       p_batchtrxn_rec	     IN	  BatchTrxn_rec_type,
			       x_return_status	     OUT NOCOPY VARCHAR2,
			       x_msg_count	     OUT NOCOPY NUMBER,
			       x_msg_data	     OUT NOCOPY VARCHAR2,
			       x_qrybatchrespsum_rec OUT NOCOPY BatchRespSum_rec_type,
			       x_qrybatchrespdet_tbl OUT NOCOPY BatchRespDet_tbl_type
			    );

/*#
 * Submits a credit card/purchase card authorization request. This API can
 * also be used to transfer funds from a bank account (ACH payment requests).
 *
 * This API is available in overloaded form with risk related input parameters.
 *
 * @param p_api_version version of the API; use 1.0 by default
 * @param p_init_msg_list required by API standard; use FND_API.G_FALSE by
 *     default
 * @param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 *     by default
 * @param p_validation_level validation level; use FND_API.G_VALID_LEVEL_FULL
 *     by default
 * @param p_ecapp_id the product id of the calling application
 * @param p_payee_rec entity that stores the attributes of the payee
 * @param p_payer_rec entity that stores the attributes of the payer
 * @param p_pmtinstr_rec entity that stores the attributes of the payment
 *     instrument. A payment instrument can be a credit card, purchase card
 *     or bank account
 * @param p_tangible_rec entity that stores the attributes of an order or bill.
 *     The tangible identifier is used to identify a transaction, so it must be unique
 *     for a given payee.
 * @param p_pmtreqtrxn_rec entity that stores the attributes of the
 *     authorization request. This entity is used in specifying whether
 *     authorization is online or offline, the type of the authorization
 *     (authonly or authcapture), etc...
 * @param x_return_status indicates the return status of the procedure; 'S'
 *     indicates success, 'U' indicates an error
 * @param x_msg_count holds the number of error messages in the message list
 * @param x_msg_data contains the error messages
 * @param x_reqresp_rec entity that stores the attrbutes of the authorization
 *     response
 * @rep:scope public
 * @rep:displayname Perform Credit Card Authorization or ACH Transfer
 * @rep:category BUSINESS_ENTITY IBY_FUNDSCAPTURE_ORDER
 */

--12. OraPmtReq (Overloaded: NO RISK PARAMETER)
  PROCEDURE OraPmtReq ( p_api_version           IN      NUMBER,
                        p_init_msg_list         IN      VARCHAR2  := FND_API.G_FALSE,
                        p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
                        p_validation_level      IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                        p_ecapp_id              IN      NUMBER,
                        p_payee_rec             IN      Payee_rec_type,
                        p_payer_rec             IN      Payer_rec_type,
                        p_pmtinstr_rec          IN      PmtInstr_rec_type,
                        p_tangible_rec          IN      Tangible_rec_type,
                        p_pmtreqtrxn_rec        IN      PmtReqTrxn_rec_type,
                        x_return_status         OUT NOCOPY VARCHAR2,
                        x_msg_count             OUT NOCOPY NUMBER,
                        x_msg_data              OUT NOCOPY VARCHAR2,
                        x_reqresp_rec           OUT NOCOPY ReqResp_rec_type
                        );
--13. OraRiskEval ( PaymentRiskInfo ) With No AVS

  PROCEDURE OraRiskEval (  p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2  := FND_API.G_FALSE,
                           p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
                           p_validation_level      IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                           p_ecapp_id              IN      NUMBER,
                           p_payment_risk_info     IN      PaymentRiskInfo_rec_type,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           x_msg_count             OUT NOCOPY NUMBER,
                           x_msg_data              OUT NOCOPY VARCHAR2,
                           x_risk_resp             OUT NOCOPY RiskResp_rec_type
                        );

--14. OraRiskEval ( AVSRiskInfo ) With AVS; overloaded

  PROCEDURE OraRiskEval (  p_api_version           IN      NUMBER,
                           p_init_msg_list         IN      VARCHAR2  := FND_API.G_FALSE,
                           p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
                           p_validation_level      IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                           p_ecapp_id              IN      NUMBER,
                           p_avs_risk_info         IN      AVSRiskInfo_rec_type,
                           x_return_status         OUT NOCOPY VARCHAR2,
                           x_msg_count             OUT NOCOPY NUMBER,
                           x_msg_data              OUT NOCOPY VARCHAR2,
                           x_risk_resp             OUT NOCOPY RiskResp_rec_type
                        );
--15. OraCCBatchCapture
  PROCEDURE OraCCBatchCapture (  p_api_version           IN       NUMBER,
                                 p_init_msg_list         IN       VARCHAR2  := FND_API.G_FALSE,
                                 p_commit                IN       VARCHAR2  := FND_API.G_FALSE,
                                 p_validation_level      IN       NUMBER  := FND_API.G_VALID_LEVEL_FULL,
                                 p_ecapp_id              IN       NUMBER,
                                 p_capturetrxn_rec_tbl   IN       CaptureTrxn_tbl,
                                 x_return_status         OUT NOCOPY VARCHAR2,
                                 x_msg_count             OUT NOCOPY NUMBER,
                                 x_msg_data              OUT NOCOPY VARCHAR2,
                                 x_capresp_rec_tbl       OUT NOCOPY CaptureResp_tbl
  );


 -- Secures a CVV value and returns the segment_ID.
 -- param p_commit commit not implemented in these APIs; use FND_API.G_FALSE
 --        by default
 -- param x_return_status indicates the return status of the procedure; 'S'
 --        indicates success, 'U' indicates an error
 -- param x_msg_count holds the number of error messages in the message list
 -- param x_msg_data contains the error messages
 -- param x_resp_rec entity that stores the attrbutes of the
 --        response
 -- scope: private

--16. OraSecureExtension
  PROCEDURE OraSecureExtension (p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
                                p_cvv                   IN  VARCHAR2,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2,
                                x_resp_rec              OUT NOCOPY SecureCVVResp_rec_type
                               );

END IBY_PAYMENT_ADAPTER_PUB;

/
