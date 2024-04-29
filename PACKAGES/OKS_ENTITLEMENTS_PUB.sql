--------------------------------------------------------
--  DDL for Package OKS_ENTITLEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ENTITLEMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPENTS.pls 120.2.12010000.3 2010/05/04 10:44:58 vgujarat ship $ */
/*#
 * Package of procedures and functions for retrieving contract information and
 * coverage information, namely Coverage Reaction and Resolution Times.
 * This package also provides procedures for returning billing related information and information
 * which determines what products are covered under warranties (also known as entitlement information).
 * Finally, this package provides a procedure for qualifying a contract as valid.
 * @rep:scope public
 * @rep:product OKS
 * @rep:lifecycle active
 * @rep:displayname OKS Entitlements
 * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
 * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
 */
-- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_ENTITLEMENTS_PUB';
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------


  TYPE apl_rec_type IS RECORD(
			charges_line_number	Number,
			contract_line_id		Number,
			coverage_id			Number,
			txn_group_id		Number,
			billing_type_id		Number,
			charge_amount		Number,
			discounted_amount		Number);
  TYPE apl_tbl_type IS TABLE of apl_rec_type INDEX BY BINARY_INTEGER;


  G_BEST                       CONSTANT VARCHAR2(10):= 'BEST';
  G_FIRST                      CONSTANT VARCHAR2(10):= 'FIRST';
  G_REACTION                   CONSTANT VARCHAR2(90):= 'RCN';
  G_RESOLUTION                 CONSTANT VARCHAR2(90):= 'RSN';
  G_REACT_RESOLVE              CONSTANT VARCHAR2(90):= 'RCN_RSN';

  G_REACTION_TIME              CONSTANT VARCHAR2(10):= 'RCN';
  G_RESOLUTION_TIME            CONSTANT VARCHAR2(10):= 'RSN';
  G_COVERAGE_TYPE_IMP_LEVEL    CONSTANT VARCHAR2(10):= 'COVTYP_IMP';
  G_NO_SORT_KEY                CONSTANT VARCHAR2(10):= 'NO_KEY';

  --PROCEDURES and FUNCTIONS

--    Procedure Specification:
--
--        PROCEDURE get_all_contracts
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_inp_rec              IN inp_rec_type
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_all_contracts        OUT NOCOPY hdr_tbl_type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec               inp_rec_type        Yes             See Below the Data Structure Specification:
--                                                                        inp_rec_type.
--
--        Input Record Specification: inp_rec_type
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_id             NUMBER              No              Contract Header ID.
--        contract_status_code    VARCHAR2            No              Contract Status Code.
--        contract_type_code      VARCHAR2            No              Contract Type Code.Only Value is 'CYA'.
--        end_date_active         DATE                No              End Date Active.
--        party_id                NUMBER              No              Customer Party ID.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_all_contracts         hdr_tbl_type        Contract header information.
--                                                        See the Data Structure Specification: hdr_tbl_type.
--
--        Output Record Specification: hdr_tbl_type:
--
--        Parameter               Data Type           Description
--
--        org_id                  NUMBER              Authoring Org ID.
--        contract_id             NUMBER              Contract Header ID.
--        contract_number         VARCHAR2            Contract Number.
--        short_description       VARCHAR2            Short Description.
--        contract_amount         NUMBER              Contract Amount.
--        contract_status_code    VARCHAR2            Contract Status Code.
--        contract_type           VARCHAR2            Contract Type.
--        party_id                NUMBER              Customer Party ID.
--        template_yn             VARCHAR2            'Y' if it is a template contract else, 'N'.
--        template_used           VARCHAR2            Contract Template Name used to create the contract.
--        duration                NUMBER              Contract Duration.
--        period_code             NUMBER              Period Code(Unit of measure for Contract duration).
--        start_date_active       DATE                Contract effective Start Date.
--        end_date_active         DATE                Contract effective End Date.
--        bill_to_site_use_id     NUMBER              Contract header Bill To Site Use ID.
--        ship_to_site_use_id     NUMBER              Contract header Ship To Site Use ID.
--        agreement_id            NUMBER              Agreement ID.
--        price_list_id           NUMBER              Price List ID for contract billing.
--        modifier                NUMBER              Contract Number Modifier.
--        currency_code           VARCHAR2            Currency Code.
--        accounting_rule_id      NUMBER              Accounting Rule ID
--        invoicing_rule_id       NUMBER              Invoicing Rule ID
--        terms_id                NUMBER              Terms ID
--        po_number               VARCHAR2            Purchase Order Number. This is different to service PO Number.
--        billing_profile_id      NUMBER              Billing Profile ID.
--        billing_frequency       VARCHAR2            Billing Frequency. obsolete.
--        billing_method          VARCHAR2            Billing Method. obsolete.
--        regular_offset_days     NUMBER              Regular Offset Days. obsolete.
--        first_bill_to           DATE                First Bill To Date. obsolete.
--        first_bill_on           DATE                First Bill On Date. obsolete.
--        auto_renew_before_days  NUMBER              Auto Renew Before Days.
--        qa_check_list_id        NUMBER              QA Check List ID.
--        renewal_note            CLOB                Renewal Note. obsolete.
--        termination_note        CLOB                Termination Note. obsolete.
--        tax_exemption           VARCHAR2            Tax Exemption.
--        tax_status              VARCHAR2            Tax Status.
--        conversion_type         VARCHAR2            Conversion Type. Currency conversion type.
--
--
--    Procedure Description:
--
--        This API returns the contract header information for any combination of input
--        parameter as explained in API Signature section.

 TYPE inp_rec_type IS RECORD
    (contract_id		      NUMBER
	,contract_status_code	  VARCHAR2(30)
	,contract_type_code	      VARCHAR2(30)
	,end_date_active		  DATE
	,party_id			      NUMBER);

 TYPE hdr_rec_type IS RECORD
     (
	 ORG_ID			             OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE
	,CONTRACT_ID		         OKC_K_HEADERS_B.ID%TYPE
	,CONTRACT_NUMBER		     OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier    OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
    ,SHORT_DESCRIPTION           OKC_K_HEADERS_TL.SHORT_DESCRIPTION%TYPE
	,CONTRACT_AMOUNT		     Number(18,2)
	,CONTRACT_STATUS_CODE        OKC_K_HEADERS_B.STS_CODE%TYPE
	,CONTRACT_TYPE               OKC_K_HEADERS_B.CHR_TYPE%TYPE
	,PARTY_ID			         Number
	,TEMPLATE_YN                 OKC_K_HEADERS_B.TEMPLATE_YN%TYPE
	,TEMPLATE_USED               OKC_K_HEADERS_B.TEMPLATE_USED%TYPE
	,DURATION                    Number
	,PERIOD_CODE                 Varchar2(25)
	,START_DATE_ACTIVE           OKC_K_HEADERS_B.START_DATE%TYPE
	,END_DATE_ACTIVE             OKC_K_HEADERS_B.END_DATE%TYPE
	,BILL_TO_SITE_USE_ID         Number
	,SHIP_TO_SITE_USE_ID         Number
	,AGREEMENT_ID                OKC_K_HEADERS_B.CHR_ID_AWARD%TYPE
	,PRICE_LIST_ID               Number
	,MODIFIER                    Number
	,CURRENCY_CODE               Varchar2(25)
	,ACCOUNTING_RULE_ID          Number
	,INVOICING_RULE_ID           Number
	,TERMS_ID			         Number
	,PO_NUMBER                   OKC_K_HEADERS_B.CUST_PO_NUMBER%TYPE
	,BILLING_PROFILE_ID          Number
	,BILLING_FREQUENCY           Varchar2(25)
	,BILLING_METHOD              Varchar2(3)
	,REGULAR_OFFSET_DAYS         Number
	,FIRST_BILL_TO               Date
	,FIRST_BILL_ON               Date
	,AUTO_RENEW_BEFORE_DAYS      OKC_K_HEADERS_B.AUTO_RENEW_DAYS%TYPE
	,QA_CHECK_LIST_ID            OKC_K_HEADERS_B.QCL_ID%TYPE
	,RENEWAL_NOTE                CLOB
	,TERMINATION_NOTE            CLOB
    ,TAX_EXEMPTION               Varchar2(450)
    ,TAX_STATUS                  Varchar2(450)
    ,CONVERSION_TYPE             Varchar2(450));

  TYPE hdr_tbl_type IS TABLE OF hdr_rec_type INDEX BY BINARY_INTEGER;
 /*#
  * Returns records from the table OKS_K_HEADERS_B.  The input record accepts
  * values for CONTRACT_ID, CONTRACT_STATUS_CODE, CONTRACT_TYPE_CODE,
  * END_DATE_ACTIVE, and PARTY_ID.  The more input parameters listed, the
  * higher the selectivity of the resulting list.
  * @param p_api_version Version numbers of incoming calls must match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API the message list is initialized.
  * @param p_inp_rec Input record used in search criteria.
  * @param x_return_status Return status. Possible returns are 'S'uccess, 'E'rror, or 'U'nexpected error.
  * @param x_msg_count Message Count.  Returns number of messages in the API message list.
  * @param x_msg_data Message Data.  If x_msg_count is 1 then the message data is encoded.
  * @param x_all_contracts Returning list of contracts.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get All Contracts
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_all_contracts
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_inp_rec			       IN  inp_rec_type
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_all_contracts 		   out nocopy hdr_tbl_type);

--    Procedure Specification:
--
--        PROCEDURE get_contract_details
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_contract_line_id     IN Number
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_all_lines            OUT NOCOPY line_tbl_type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_line_id      NUMBER              Yes             Contract Line ID for Service/Warranty/Ext. Warranty.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_all_lines             line_tbl_type       Contract line information.
--                                                        See the Data Structure Specification: line_tbl_type.
--
--        Output Record Specification: line_tbl_type:
--
--        Parameter               Data Type           Description
--
--        contract_line_id        NUMBER              Contract Line ID
--        contract_parent_line_id NUMBER              Contract Parent Line ID
--        contract_id             NUMBER              Contract Header ID
--        line_status_code        VARCHAR2            Line Status Code
--        duration                NUMBER              Duration
--        period_code             VARCHAR2            Period Code
--        start_date_active       DATE                Start Date Active
--        end_date_active         DATE                End Date Active
--        line_name               VARCHAR2            Line Name
--        bill_to_site_use_id     NUMBER              Bill To Site Use Id
--        ship_to_site_use_id     NUMBER              Ship To Site Use Id
--        agreement_id            NUMBER              Agreement Id
--        modifier                NUMBER              Modifier
--        price_list_id           NUMBER              Price List Id
--        price_negotiated        NUMBER              Price Negotiated
--        billing_profile_id      NUMBER              Billing Profile Id
--        billing_frequency       VARCHAR2            Billing Frequency
--        billing_method          VARCHAR2            Billing Method
--        regular_offset_days     NUMBER              Regular Offset Days
--        first_bill_to           DATE                First Bill To
--        first_bill_on           DATE                First Bill On
--        termination_date        DATE                Termination Date
--
--    Procedure Description:
--
--        This API returns the contract line information for an input of contract line id.

  TYPE line_rec_type IS RECORD
     (
	 CONTRACT_LINE_ID		   OKC_K_LINES_B.ID%TYPE
	,COnTRACT_PARENT_LINE_ID   OKC_K_LINES_B.CLE_ID%TYPE
	,CONTRACT_ID		       OKC_K_LINES_B.CHR_ID%TYPE
	,LINE_STATUS_CODE   	   OKC_K_LINES_B.STS_CODE%TYPE
	,DURATION                  Number
	,PERIOD_CODE               Varchar2(25)
	,START_DATE_ACTIVE         OKC_K_HEADERS_B.START_DATE%TYPE
	,END_DATE_ACTIVE           OKC_K_HEADERS_B.END_DATE%TYPE
	,LINE_NAME			       Varchar2(150)
	,BILL_TO_SITE_USE_ID       Number
	,SHIP_TO_SITE_USE_ID       Number
	,AGREEMENT_ID              OKC_K_HEADERS_B.CHR_ID_AWARD%TYPE
	,MODIFIER                  Number
	,PRICE_LIST_ID             Number
	,PRICE_NEGOTIATED		   OKC_K_LINES_B.PRICE_NEGOTIATED%TYPE
	,BILLING_PROFILE_ID        Number
	,BILLING_FREQUENCY         Varchar2(25)
	,BILLING_METHOD            Varchar2(3)
	,REGULAR_OFFSET_DAYS       Number
	,FIRST_BILL_TO             Date
	,FIRST_BILL_ON             Date
	,TERMINATION_DATE          Date
     );

  TYPE line_tbl_type IS TABLE OF line_rec_type INDEX BY BINARY_INTEGER;

 /*#
  * Returns Billing, Duration, Shipping, Pricing and general Contract information
  * for a given Contract Line Id (CLE_ID). For a specific list of return parameters
  * please see the Metalink note.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_line_id Contract Line ID for Service/Warranty/Extended Warranty.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_all_lines Contract line information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contract Details
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_contract_details
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_contract_line_id	       IN  Number
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_all_lines		       out nocopy line_tbl_type);

--    Procedure Specification:
--
--        PROCEDURE get_coverage_levels
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_contract_line_id     IN Number
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_covered_levels       OUT NOCOPY clvl_tbl_type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_line_id      NUMBER              Yes             Line ID of Service,Extended Warranty or
--                                                                        Warranty.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_covered_levels        clvl_tbl_type       Coverage Level information.
--                                                        See the Data Structure Specification clvl_tbl_type.
--
--        Output Data Structure Description: clvl_tbl_type:
--
--        Parameter                   Data Type           Description
--
--        row_id                      ROWID               Row Id.
--        line_id                     NUMBER              Covered level Line Id.
--        header_id                   NUMBER              Contract Header Id.
--        parent_line_id              NUMBER              Parent Line Id.
--        line_level                  VARCHAR2            Covered Level. (Line style id; 7,8,9,10,11,18,25,35)
--        cp_id                       NUMBER              Covered Product Id.
--        cp_name                     VARCHAR2            Covered Product Name.
--        inv_item_id                 NUMBER              Covered Item Id.
--        item_name                   VARCHAR2            Covered Item Name.
--        site_id                     NUMBER              Covered Site Id.
--        site_name                   VARCHAR2            Covered Site Name.
--        system_id                   NUMBER              Covered System Id.
--        system_name                 VARCHAR2            Covered System Name.
--        customer_id                 NUMBER              Covered Customer Id.
--        customer_name               VARCHAR2            Covered Customer Name.
--        party_id                    NUMBER              Covered Party Id.
--        party_name                  VARCHAR2            Covered Party Name.
--        quantity                    NUMBER              Quantity Covered.
--        list_price                  NUMBER              List Price.
--        price_negotiated            NUMBER              Price Negotiated.
--        line_name                   VARCHAR2            Covered level Line Name.
--        default_amcv_flag           VARCHAR2            Default Amcv Flag.Obsoleted.
--        default_qty                 NUMBER              Default Quantity.Obsoleted.
--        default_uom                 VARCHAR2            Default UOM.Obsoleted.
--        default_duration            NUMBER              Default Duration.Obsoleted.
--        default_period              VARCHAR2            Default Period.Obsoleted.
--        minimum_qty                 NUMBER              Minimum Quantity.Obsoleted.
--        minimum_uom                 VARCHAR2            Minimum UOM.Obsoleted.
--        minimum_duration            NUMBER              Minimum Duration.Obsoleted.
--        minimum_period              VARCHAR2            Minimum Period.Obsoleted.
--        fixed_qty                   NUMBER              Fixed Quantity.Obsoleted.
--        fixed_uom                   VARCHAR2            Fixed UOM.Obsoleted.
--        fixed_duration              NUMBER              Fixed Duration.Obsoleted.
--        fixed_period                VARCHAR2            Fixed Period.Obsoleted.
--        level_flag                  VARCHAR2            Level Flag.Obsoleted.
--
--
--    Procedure Description:
--
--        This API returns the Covered Level Information such as Party, Customer, Site, System, Item and
--        Product information.

  TYPE clvl_rec_type IS RECORD
     (
	 ROW_ID			ROWID
	,LINE_ID			OKC_K_LINES_B.ID%TYPE
	,HEADER_ID			OKC_K_LINES_B.CHR_ID%TYPE
	,PARENT_LINE_ID		OKC_K_LINES_B.CLE_ID%TYPE
	,LINE_LEVEL			Varchar2(150)
	,CP_ID			Number
      ,CP_NAME                Varchar2(240)
	,INV_ITEM_ID		Number
	,ITEM_NAME			Varchar2(240)
	,SITE_ID			Number
	,SITE_NAME			Varchar2(240)
	,SYSTEM_ID			Number
	,SYSTEM_NAME		Varchar2(240)
	,CUSTOMER_ID		Number
	,CUSTOMER_NAME		Varchar2(240)
	,PARTY_ID	            Number
	,PARTY_NAME	            Varchar2(500)
	,QUANTITY			Number
	,LIST_PRICE			Number
	,PRICE_NEGOTIATED		OKC_K_LINES_B.PRICE_NEGOTIATED%TYPE
	,LINE_NAME			Varchar2(150)
	,DEFAULT_AMCV_FLAG	Varchar2(1)
	,DEFAULT_QTY		Number
	,DEFAULT_UOM		Varchar2(25)
	,DEFAULT_DURATION		Number
	,DEFAULT_PERIOD		Varchar2(25)
	,MINIMUM_QTY		Number
	,MINIMUM_UOM		Varchar2(25)
	,MINIMUM_DURATION		Number
	,MINIMUM_PERIOD		Varchar2(25)
	,FIXED_QTY			Number
	,FIXED_UOM			Varchar2(25)
	,FIXED_DURATION		Number
	,FIXED_PERIOD		Varchar2(25)
	,LEVEL_FLAG			Varchar2(1)
     );

 TYPE clvl_tbl_type IS TABLE OF clvl_rec_type INDEX BY BINARY_INTEGER;

 /*#
  * Returns the Party, Customer, Site, System, Item and Product coverage
  * level information for a given Contract Line Id (CLE_ID).
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_line_id Line ID of Service, Extended Warranty or Warranty.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_covered_levels The returning Coverage Level information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Coverage Levels
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_coverage_levels
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_contract_line_id	       IN  Number
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_covered_levels 	       out nocopy clvl_tbl_type);

--    Procedure Specification:
--
--        PROCEDURE get_contracts
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_inp_rec              IN inp_cont_rec
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_ent_contracts        OUT NOCOPY ent_cont_tbl);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec               inp_cont_rec        Yes             See Below the Data Structure Specification:
--                                                                        inp_cont_rec.
--
--        Input Record Specification: inp_cont_rec
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_number         VARCHAR2            No              Contract Number.
--        contract_number_modifier VARCHAR2           No              Contract Number Modifier.
--                                                                        This input is required if input
--                                                                        contract_number is also passed.
--        coverage_level_line_id  NUMBER              No              Covered Level Line Id.
--        party_id                NUMBER              No              Party Id.
--        site_id                 NUMBER              No              Party Site Id.
--        cust_acct_id            NUMBER              No              Customer Account Id
--        system_id               NUMBER              No              Installed base System Id.
--        item_id                 NUMBER              No              Inventory Item Id.
--        product_id              NUMBER              No              Product Id. Installed Base Instance Id.
--        request_date            DATE                No              Request Date. The Default is sysdate.
--        validate_flag           VARCHAR2            No              Validate Flag. Valid values are 'Y' or, 'N'.
--                                                                        Default is 'N'. If 'Y' is passed as
--                                                                        input, only Valid records are returned.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_ent_contracts         ent_cont_tbl        Contract information.
--                                                        See the Data Structure Specification: ent_cont_tbl.
--
--        Output Data Structure Description: ent_cont_tbl :
--
--        Parameter                   Data Type           Description
--
--        contract_id                 NUMBER              Contract Id.
--        contract_number             VARCHAR2            Contract Number.
--        contract_number_modifier    VARCHAR2            Contract Number Modifier.
--        service_line_id             NUMBER              Service Line Id.
--        service_name                VARCHAR2            Service Name.
--        service_description         VARCHAR2            Service Description.
--        coverage_term_line_id       NUMBER              Coverage Line Id.
--        Coverage_term_name          VARCHAR2            Coverage Name.
--        coverage_term_description   VARCHAR2            Coverage Description.
--        coverage_type_code          VARCHAR2            Coverage Type.
--        coverage_type_meaning       VARCHAR2            Coverage Type Meaning.
--        coverage_type_imp_level     NUMBER              Coverage Importance level.
--        coverage_level_line_id      NUMBER              Covered Level Line Id.
--        coverage_level              VARCHAR2            Covered Level.
--        coverage_level_code         VARCHAR2            Covered Level Code.
--        coverage_level_start_date   DATE                Covered Level Line Start Date.
--        coverage_level_End_date     DATE                Covered Level Line End Date.
--        coverage_level_id           NUMBER              Covered Level Id.
--        warranty_flag               VARCHAR2            Warranty Flag.
--        eligible_for_entitlement    VARCHAR2            Eligible For Entitlement.
--                                                            returns 'T', if the service line id is entitled.
--                                                            returns 'F', if the service line id is not entitled.
--
--    Procedure Description:
--
--        This is an over loaded API which returns contract information for different
--        Coverage Levels such as Party, Customer, Site, System, Item, and Product. If the
--        input parameter validate_flag is set to 'Y', request date is checked against the Date
--        Effectivity and only those contract covered level lines eligible for entitlements are
--        returned. This API also returns the coverage type and associated importance level
--        information.
--
--        This Procedure get_contracts returns a table of records of type ent_cont_tbl which contain
--        covered level line records with coresponding contract/service/coverage information.
--        The API accepts inputs as per record structure inp_cont_rec. Accepted inputs are
--        covered_level_line_id(coverage_level_line_id),party_id,site_id,cust_acct_id,system_id,
--        item_id,product_id, request_date,validate_flag.
--
--        For input validate_flag = 'Y', only those covered level records are returned
--        which passes effectivity check at covered level,service line and coverage line
--        based on request date passed and also passes the entitlement check for the corresponding
--        service line.
--
--        For input validate_flag = 'N', all covered level records are returned.
--        no filtration is done on the basis of effectivity or entitlement, but entitlement check
--        is done for corresponding service line and entitlement status is just passed
--        as an output for the corresponding covered level record

 TYPE inp_cont_rec IS RECORD
	(contract_number		   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
	,coverage_level_line_id    Number
	,party_id			       Number
	,site_id			       Number
	,cust_acct_id		       Number
	,system_id			       Number
	,item_id			       Number
	,product_id			       Number
    ,request_date              Date
    ,validate_flag             Varchar2(1));

  TYPE ent_cont_rec IS RECORD
	(contract_id               Number
	,contract_number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
    ,service_line_id           Number
	,service_name              VARCHAR2(300)    --OKC_K_LINES_V.NAME%TYPE
	,service_description       VARCHAR2(300)    --OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
	,coverage_term_line_id     Number
	,Coverage_term_name        OKC_K_LINES_V.NAME%TYPE
    ,coverage_term_description OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
    ,coverage_type_code        Oks_Cov_Types_B.Code%TYPE
    ,coverage_type_meaning     Oks_Cov_Types_TL.Meaning%TYPE
    ,coverage_type_imp_level   Oks_Cov_Types_B.Importance_Level%TYPE
    ,coverage_level_line_id    Number
	,coverage_level            OKC_LINE_STYLES_TL.NAME%TYPE
	,coverage_level_code       OKC_LINE_STYLES_B.LTY_CODE%TYPE
	,coverage_level_start_date Date
	,coverage_level_End_date   Date
	,coverage_level_id         Number
	,warranty_flag             Varchar2(1)
	,eligible_for_entitlement  Varchar2(1)
	);

  TYPE ent_cont_tbl IS TABLE OF ent_cont_rec INDEX BY BINARY_INTEGER;

 /*#
  * Returns contract information for Coverage Levels: If VALIDATE_FLAG = 'Y',
  * REQUEST_DATE is checked against the START_DATE, END_DATE and DATE_TERMINATED
  * ranges, only those Contract Covered Level Lines eligible for entitlements
  * are returned.  If VALIDATE_FLAG = 'N', all Covered Level Lines are returned.
  * No filtration is performed on the basis of effectivity or entitlement,
  * however, an entitlement check is done for Service Line.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_inp_rec Qualifying contract information which is used a query criteria.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_ent_contracts The returning contract information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contracts (inp_cont_rec)
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_contracts
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_inp_rec			       IN  inp_cont_rec
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_ent_contracts		   out nocopy ent_cont_tbl);

--    Procedure Specification:
--
--        PROCEDURE get_contracts
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_inp_rec              IN get_contin_rec
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_ent_contracts        OUT NOCOPY get_contop_tbl);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec               get_contin_rec      Yes             See Below the Data Structure Specification:
--                                                                        get_contin_rec.
--
--        Input Record Specification: get_contin_rec
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_number         VARCHAR2            No              Contract Number.
--        contract_number_modifier VARCHAR2           No              Contract Number Modifier.
--                                                                        This input is required if input
--                                                                        contract_number is also passed.
--        service_line_id         NUMBER              No              Service/Warranty/Ext. Warranty Line Id.
--        party_id                NUMBER              No              Party Id.
--        site_id                 NUMBER              No              Site Id.
--        cust_acct_id            NUMBER              No              Customer Account Id.
--        system_id               NUMBER              No              System Id.
--        item_id                 NUMBER              No              Item Id.
--        product_id              NUMBER              No              Product Id.
--        request_date            DATE                No              Request Date.
--        business_process_id     NUMBER              No              Business Process Id
--                                                                        - Required if also input calc_resptime_flag is 'Y'.
--        severity_id             NUMBER              No              Severity Id
--                                                                        - Required if calc_resptime_flag is Y.
--        time_zone_id            NUMBER              No              Time Zone Id
--                                                                        - Required if calc_resptime_flag is Y.
--        calc_resptime_flag      VARCHAR2            No              Whether Calculate Reaction and Resolution Time.
--                                                                        Valid values are 'Y' or, 'N'.
--        validate_flag           VARCHAR2            No              Whether the API should return only Valid records.
--                                                                        Valid values are 'Y' or, 'N'. Default value is 'N'.
--        Sort_key                VARCHAR2            No              The Sort key used to sort the table of records
--                                                                        returned by the API. This input is optional.
--                                                                        The default sort_key used is 'RCN' for
--                                                                        sorting based on resolution time.
--                                                                        Sort_key accepts values 'RCN', 'RSN', or
--                                                                        'COVTYP_IMP' for sorting the output result
--                                                                        based on reaction time,resolution time,
--                                                                        or coverage importance level respectively.
--
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_ent_contracts         get_contop_tbl      Contract information.
--                                                        See the Data Structure Specification: get_contop_tbl.
--
--        Output Data Structure Description: get_contop_tbl :
--
--        Parameter                   Data Type           Description
--
--        contract_id                 NUMBER              Contract Id.
--        contract_number             VARCHAR2            Contract Number.
--        contract_number_modifier    VARCHAR2            Contract Number Modifier.
--        sts_code                    VARCHAR2            Contract Status Code.
--        service_line_id             NUMBER              Service/Warranty/Ext. Warranty Line Id.
--        service_name                VARCHAR2            Service/Warranty/Ext. Warranty Name.
--        service_description         VARCHAR2            Service/Warranty/Ext. Warranty Description.
--        coverage_term_line_id       NUMBER              Coverage Line Id.
--        coverage_term_name          VARCHAR2            Coverage Name.
--        coverage_term_description   VARCHAR2            Coverage Description.
--        coverage_type_code          VARCHAR2            Coverage Type.
--        coverage_type_meaning       VARCHAR2            Coverage Type Meaning.
--        coverage_type_imp_level     NUMBER              Coverage Importance level.
--        service_start_date          NUMBER              Service/Warranty/Ext. Warranty Line Start Date.
--        service_end_date            NUMBER              Service/Warranty/Ext. Warranty Line End Date.
--        warranty_flag               VARCHAR2            Warranty Flag. If 'Y', means the
--                                                            Service/Warranty/Ext. Warranty Line is Warranty.
--        eligible_for_entitlement    VARCHAR2            Represents if Service/Warranty/Ext. Warranty Line is Eligible For Entitlement.
--                                                            Returns 'T'(for entitled) or, 'F' (for not entitled)
--        exp_reaction_time           DATE                Expected React by  Date and Time.
--        exp_resolution_time         DATE                Expected Resolve by Date and Time.
--        status_code                 VARCHAR2            Status Code after returning reaction
--                                                        and/or resolution time.
--                                                            S - Success,E - Error,U - Unexpected Error.
--        status_text                 VARCHAR2            Status Text for the Status Code.
--        date_terminated             DATE                The date terminated of the covered level line.
--        PM_Program ID               NUMBER              Preventive Maintenance (PM) program ID.
--        PM_Schedule_Exists          VARCHAR2            Schedule Exists flag for the PM Program ID.
--        HD_Currency_Code            VARCHAR2            Contract Header currency code.
--        Service_PO_Number           VARCHAR2            Service PO number.
--        Service_PO_Required_Flag    VARCHAR2            Flag indicates if Service PO required.
--
--    Procedure Description:
--
--        This is an over loaded API which returns contract information for different
--        combination of Service, Extended Warranty or Warranty, Covered Levels such as
--        Party, Customer, Site, System, Item or Product and Business Processes. If the input
--        parameter validate_flag is 'Y', request date is checked against Date Effectivity and
--        only those contract service lines eligible for entitlements are returned. The output
--        table will be sorted in the order of ascending resolution time. The Sort_key accepts
--        values 'RCN', 'RSN', or 'COVTYP_IMP' for sorting the output result based on
--        reaction time, resolution time, or coverage importance level respectively.
--
--        Procedure get_contracts -- input as get_contin_rec returns a table of records of type
--        get_contop_tbl which contain service line records with coresponding contract/service/coverage
--        information. The API accepts inputs as per record structure get_contin_rec. Accepted inputs
--        are contract_number,contract_number_modifier,service_line_id,party_id,site_id,cust_acct_id,system_id,
--        item_id,product_id,request_date,business_process_id,severity_id,time_zone_id,calc_resptime_flag
--        validate_flag,sort_key.
--
--        inputs business_process_id,severity_id,time_zone_id must be passed if calc_resptime_flag = 'Y'
--        calc_resptime_flag = 'Y' means reaction datetime and resolution datetime would be returned.
--
--        irrespective of input validate_flag ,only those service line records are returned
--        which passes effectivity check at corresponding covered level lines,service line itself and
--        associated coverage lines based on request date passed. So, effecitivity check is ALWAYS done.
--        This is in contrast to its other overloaded counterpart with input as input_rec_ib,
--        where effectivity check is NEVER done.
--
--        For input validate_flag = 'Y', also filters service line records based on the entitlement check,
--        as per status and operations setup.
--
--        For input validate_flag = 'N', no filtration is done on the basis of  entitlement,
--        but entitlement check is done for service line record and entitlement status is just passed
--        as an output for the corresponding service line record.

    /*vgujarat - modified for access hour ER 9675504*/
  TYPE get_contin_rec IS RECORD
	(contract_number		   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
	,service_line_id           Number
	,party_id			   Number
	,site_id			   Number
	,cust_acct_id		   Number
	,system_id			   Number
	,item_id			   Number
	,product_id			   Number
      ,request_date              Date
      ,incident_date             Date           -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,business_process_id       Number
      ,severity_id               Number
      ,time_zone_id              Number
      ,dates_in_input_TZ         VARCHAR2(1)    -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,calc_resptime_flag        Varchar2(1)
      ,validate_flag             Varchar2(1)
      ,sort_key                  VARCHAR2(10)
      ,cust_id                   NUMBER  DEFAULT NULL   --access hour
      ,cust_site_id              NUMBER  DEFAULT NULL   --access hour
      ,cust_loc_id               NUMBER  DEFAULT NULL); --access hour

  TYPE get_contop_rec IS RECORD
    (contract_id               Number
	,contract_number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
	,sts_code                  OKC_K_HEADERS_B.STS_CODE%TYPE
    ,service_line_id           Number
	,service_name              VARCHAR2(300)  --OKX_SYSTEM_ITEMS_V.NAME%TYPE
	,service_description       VARCHAR2(300)  --OKX_SYSTEM_ITEMS_V.DESCRIPTION%TYPE
    ,coverage_term_line_id     Number
	,coverage_term_name        OKC_K_LINES_V.NAME%TYPE
	,coverage_term_description OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
    ,coverage_type_code        Oks_Cov_Types_B.Code%TYPE
    ,coverage_type_meaning     Oks_Cov_Types_TL.Meaning%TYPE
    ,coverage_type_imp_level   Oks_Cov_Types_B.Importance_Level%TYPE
    ,service_start_date        Date
    ,service_end_date          Date
    ,warranty_flag             Varchar2(1)
	,eligible_for_entitlement  Varchar2(1)
    ,exp_reaction_time         Date
    ,exp_resolution_time       Date
    ,status_code               Varchar2(1)
    ,status_text               Varchar2(1995)
    ,date_terminated		   Date
    ,PM_Program_Id             VARCHAR2(40)
    ,PM_Schedule_Exists        VARCHAR2(450)
    ,HD_Currency_code          Varchar2(15)
    ,Service_PO_Number         VARCHAR2(450) -- added for 11.5.9 (patchset I) enhancement # 2290763
    ,Service_PO_Required_flag  VARCHAR2(1)   -- added for 11.5.9 (patchset I) enhancement # 2290763
    ,CovLvl_Line_Id            NUMBER        -- Added for 12.0 ENT-TZ project (JVARGHES)
    );

  TYPE get_contop_tbl IS TABLE OF get_contop_rec INDEX BY BINARY_INTEGER;


 /*#
  * Returns contract information:
  * Irrespective of VALIDATE_FLAG setting, the REQUEST_DATE is NEVER checked
  * against the START_DATE, END_DATE and DATE_TERMINATED ranges.
  * If VALIDATE_FLAG = 'Y', Service Line records
  * are returned based on the 'Eligible for Entitlement' flag in the Status
  * and Operations Form.
  * The output table will default to being sorted in the order of ascending
  * Resolution Time, however, the sort order can be changed through values
  * assigned to the SORT_KEY.  For a list of values accepted by the SORT_KEY
  * please see the Metalink note.  Inputs BUSINESS_PROCESS_ID, SEVERITY_ID,
  * and TIME_ZONE_ID must be passed if CALC_RESPTIME_FLAG = 'Y'.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_inp_rec Qualifying contract information which is used a query criteria.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_ent_contracts The returning contract information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contracts (get_contin_rec)
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_contracts
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_inp_rec			       IN  get_contin_rec
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_ent_contracts		   out nocopy get_contop_tbl);

--    Procedure Specification:
--
--        PROCEDURE get_contracts
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_inp_rec              IN input_rec_ib
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_ent_contracts        OUT NOCOPY output_tbl_ib);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec               input_rec_ib        Yes             See Below the Data Structure Specification:
--                                                                        input_rec_ib.
--
--        Input Record Specification: input_rec_ib
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_number         VARCHAR2            No              Contract Number.
--        contract_number_modifier VARCHAR2           No              Contract Number Modifier.
--                                                                        This input is required if input
--                                                                        contract_number is also passed.
--        service_line_id         NUMBER              No              Service/Warranty/Ext. Warranty Line Id.
--        party_id                NUMBER              No              Party Id.
--        site_id                 NUMBER              No              Site Id.
--        cust_acct_id            NUMBER              No              Customer Account Id.
--        system_id               NUMBER              No              System Id.
--        item_id                 NUMBER              No              Item Id.
--        product_id              NUMBER              No              Product Id.
--        request_date            DATE                No              Request Date.
--        business_process_id     NUMBER              No              Business Process Id
--                                                                        - Required if also input calc_resptime_flag is 'Y'.
--        severity_id             NUMBER              No              Severity Id
--                                                                        - Required if calc_resptime_flag is Y.
--        time_zone_id            NUMBER              No              Time Zone Id
--                                                                        - Required if calc_resptime_flag is Y.
--        calc_resptime_flag      VARCHAR2            No              Whether Calculate Reaction and Resolution Time.
--                                                                        Valid values are 'Y' or, 'N'.
--        validate_flag           VARCHAR2            No              Whether the API should return only Valid records.
--                                                                        Valid values are 'Y' or, 'N'. Default value is 'N'.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_ent_contracts         output_tbl_ib       Contract information.
--                                                        See the Data Structure Specification: output_tbl_ib.
--
--        Output Data Structure Description: output_tbl_ib :
--
--        Parameter                   Data Type           Description
--
--        contract_id                 NUMBER              Contract Id.
--        contract_number             VARCHAR2            Contract Number.
--        contract_number_modifier    VARCHAR2            Contract Number Modifier.
--        sts_code                    VARCHAR2            Contract Status Code.
--        service_line_id             NUMBER              Service/Warranty/Ext. Warranty Line Id.
--        service_name                VARCHAR2            Service/Warranty/Ext. Warranty Name.
--        service_description         VARCHAR2            Service/Warranty/Ext. Warranty Description.
--        coverage_term_line_id       NUMBER              Coverage Line Id.
--        coverage_term_name          VARCHAR2            Coverage Name.
--        coverage_term_description   VARCHAR2            Coverage Description.
--        Coverage_type_code          VARCHAR2            Coverage Type Code.
--        Coverage_type_imp_level     NUMBER              Coverage type importance level.
--        service_start_date          NUMBER              Service/Warranty/Ext. Warranty Line Start Date.
--        service_end_date            NUMBER              Service/Warranty/Ext. Warranty Line End Date.
--        warranty_flag               VARCHAR2            Warranty Flag. If 'Y', means the
--                                                            Service/Warranty/Ext. Warranty Line is Warranty.
--        eligible_for_entitlement    VARCHAR2            Represents if Service/Warranty/Ext. Warranty Line is Eligible For Entitlement.
--                                                            Returns 'T'(for entitled) or, 'F' (for not entitled)
--        exp_reaction_time           DATE                Expected React by  Date and Time.
--        exp_resolution_time         DATE                Expected Resolve by Date and Time.
--        status_code                 VARCHAR2            Status Code after returning reaction
--                                                        and/or resolution time.
--                                                            S - Success,E - Error,U - Unexpected Error.
--        status_text                 VARCHAR2            Status Text for the Status Code.
--        date_terminated             DATE                The date terminated of the covered level line.
--
--
--    Procedure Description:
--
--        This is an over loaded API which returns contract information for different
--        combination of Service, Extended Warranty or Warranty, Coverage Levels such as
--        Party, Customer, Site, System, Item or Product and Business Processes. If the input
--        parameter validate_flag is 'Y', only those contract service lines eligible for
--        entitlements are returned.
--
--        This Procedure takes input as input_rec_ib returns a table of records of type
--        get_contop_tbl which contain service line records with coresponding contract/service/coverage
--        information. The API accepts inputs as per record structure input_rec_ib. Accepted inputs are
--        contract_number,contract_number_modifier,service_line_id,party_id,site_id,cust_acct_id,system_id,
--        item_id,product_id,request_date,business_process_id,severity_id,time_zone_id,calc_resptime_flag
--        validate_flag,sort_key
--
--        inputs business_process_id,severity_id,time_zone_id must be passed if calc_resptime_flag = 'Y'
--        calc_resptime_flag = 'Y' means reaction datetime and resolution datetime would be returned
--
--        irrespective of input validate_flag ,effectivity check is NEVER done. This is in contrast to
--        its other overloaded counterpart with input as get_contin_rec, where effectivity check is
--        always done.
--
--        For input validate_flag = 'Y', only those contract line records are returned
--        which passes entitlement check for the corresponding service line.
--
--        For input validate_flag = 'N', all contract line records are returned,but entitlement check
--        is done for corresponding service line and entitlement status is just passed
--        as an output for the corresponding service line record.

 TYPE input_rec_ib IS RECORD
	(contract_number		   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,service_line_id           Number
	,party_id			   Number
	,site_id			   Number
	,cust_acct_id		   Number
	,system_id			   Number
	,item_id			   Number
	,product_id			   Number
      ,business_process_id       Number
      ,severity_id               Number
      ,time_zone_id              Number
      ,dates_in_input_TZ         Varchar2(1)  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,calc_resptime_flag        Varchar2(1)
      ,validate_flag             Varchar2(1));

  TYPE output_rec_ib IS RECORD
	(contract_id               Number
	,contract_number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
	,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
	,sts_code                  OKC_K_HEADERS_B.STS_CODE%TYPE
    ,service_line_id           Number
    ,service_name              VARCHAR2(300)   --OKX_SYSTEM_ITEMS_V.NAME%TYPE
	,service_description       VARCHAR2(300)   --OKX_SYSTEM_ITEMS_V.DESCRIPTION%TYPE
    ,coverage_term_line_id     Number
	,coverage_term_name        OKC_K_LINES_V.NAME%TYPE
	,coverage_term_description OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
    ,coverage_type_code        OKS_Cov_TYPES_B.Code%Type
    ,coverage_type_imp_level   OKS_Cov_TYPES_B.Importance_Level%Type
    ,service_start_date        Date
    ,service_end_date          Date
	,warranty_flag             Varchar2(1)
	,eligible_for_entitlement  Varchar2(1)
    ,exp_reaction_time         Date
    ,exp_resolution_time       Date
    ,status_code               Varchar2(1)
    ,status_text               Varchar2(1995)
    ,Date_terminated           Date
    ,CovLvl_Line_Id            NUMBER        -- Added for 12.0 ENT-TZ project (JVARGHES)
	);

  TYPE output_tbl_ib IS TABLE OF  output_rec_ib INDEX BY BINARY_INTEGER;

 /*#
  * Returns contract information:
  * Irrespective of VALIDATE_FLAG setting, the REQUEST_DATE is NEVER checked
  * against the START_DATE, END_DATE and DATE_TERMINATED ranges.
  * If VALIDATE_FLAG = 'Y', Service Line
  * records are returned based on the 'Eligible for Entitlement' flag
  * in the Status and Operations Form; if VALIDATE_FLAG = 'N', all Contract
  * Line records are returned, but the Entitlement check is performed for
  * corresponding Service Lines.
  * The output table will be sorted in the order of ascending
  * Resolution Time.  Inputs BUSINESS_PROCESS_ID, SEVERITY_ID, and TIME_ZONE_ID
  * must be passed if CALC_RESPTIME_FLAG = 'Y'.
  *
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_inp_rec Qualifying contract information which is used a query criteria.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_ent_contracts The returning contract information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contracts (input_rec_ib)
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_contracts
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_inp_rec			       IN  input_rec_ib
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_ent_contracts		   out nocopy output_tbl_ib);

--   Procedure get_contracts with input input_rec_entfrm
--   For Entitlement UI, which was never made public and
--   there are no consumers.
--
--   The API search_contract_lines is developed and
--   introduced in 11.5.9 , for which Entitlement search UI
--   is also introduced.

  TYPE input_rec_entfrm IS RECORD
    (contract_number		     OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier    OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_customer_id        NUMBER
    ,contract_service_item_id    NUMBER
    ,covlvl_party_id		     NUMBER
    ,covlvl_site_id		         NUMBER
    ,covlvl_cust_acct_id	     NUMBER
    ,covlvl_system_id		     NUMBER
    ,covlvl_item_id		         NUMBER
    ,covlvl_product_id		     NUMBER
    ,request_date                DATE
    ,validate_effectivity        VARCHAR2(1));

  TYPE output_rec_entfrm IS RECORD
    (contract_id                  NUMBER
    ,contract_number              OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
    ,contract_known_as            OKC_K_HEADERS_TL.COGNOMEN%TYPE
    ,contract_short_description   OKC_K_HEADERS_TL.SHORT_DESCRIPTION%TYPE
    ,contract_status_code         OKC_K_HEADERS_B.STS_CODE%TYPE
    ,contract_start_date          DATE
    ,contract_end_date            DATE
    ,contract_terminated_date     DATE);

  TYPE output_tbl_entfrm IS TABLE OF output_rec_entfrm INDEX BY BINARY_INTEGER;

  PROCEDURE get_contracts
    (P_API_Version		          IN  NUMBER
    ,P_Init_Msg_List		      IN  VARCHAR2
    ,P_Inp_Rec			          IN  Input_Rec_EntFrm
    ,X_Return_Status 		      out nocopy VARCHAR2
    ,X_Msg_Count		          out nocopy NUMBER
    ,X_Msg_Data			          out nocopy VARCHAR2
    ,X_Ent_Contracts		      out nocopy output_Tbl_EntFrm);

--    Procedure Specification:
--
--        PROCEDURE VALIDATE_CONTRACT_LINE
--        (p_api_version          IN NUMBER
--        ,p_init_msg_list        IN VARCHAR2
--        ,p_contract_line_id     IN NUMBER
--        ,p_busiproc_id          IN NUMBER
--        ,p_request_date         IN DATE
--        ,p_covlevel_tbl_in      IN covlevel_tbl_type
--        ,p_verify_combination   IN VARCHAR2
--        ,x_return_status        out nocopy Varchar2
--        ,x_msg_count            out nocopy Number
--        ,x_msg_data             out nocopy Varchar2
--        ,x_covlevel_tbl_out     OUT NOCOPY covlevel_tbl_type
--        ,x_combination_valid    OUT NOCOPY VARCHAR2);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_line_id      NUMBER              Yes             Contract line Id.
--        P_busiproc_id           NUMBER              No              Business process ID.
--        P_request_date          DATE                No              Request date.Default is sysdate.
--        P_covlevel_tbl_in       Covlevel_tbl_type   Yes             Covered level code and id.
--                                                                        See the Data Structure Specification:
--                                                                            covlevel_tbl_type.
--        P_verify_combination    VARCHAR2            No              Default is 'N'. If 'Y', then the
--                                                                        procedure checks if all the covered level
--                                                                        records passed as input in p_covlevel_tbl_in
--                                                                        and p_busiproc_id is valid for the
--                                                                        p_contract_line_id.
--
--
--        Input Record Specification: Covlevel_tbl_type
--
--        Parameter               Data Type           Required        Description and Validations
--
--        Covlevel_code           VARCHAR2            Yes.            Covered level code.
--                                                                        The covered level codes are:
--                                                                        For install base customer product; 'OKX_CUSTPROD',
--                                                                        for inventory item; 'OKX_COVITEM',
--                                                                        for install base system;'OKX_COVSYST',
--                                                                        for customer account;'OKX_CUSTACCT',
--                                                                        for customer party site;'OKX_PARTYSITE',
--                                                                        for customer party;'OKX_PARTY'
--        Covlevel_id             NUMBER              Yes             Covered level Id corresponding to covlevel code.
--                                                                        For example, The covered level id
--                                                                        would be an install base item instance id,
--                                                                        if covered_level_code = 'OKX_CUSTPROD'
--        Inv_org_id              NUMBER              Yes             Inventory_organization_id. This Input is
--                                                                    required if input covlevel_code is passed as
--                                                                    'OKX_COVITEM'.
--        Covered_yn              VARCHAR2            No              Not Used in the input record.
--                                                                        This is used while returning the output.
--                                                                        Same data structure is used both for input
--                                                                        and output.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_covlevel_tbl_out      Covlevel_tbl_type   Covered level code and id passed as input is returned
--                                                        with covered_yn information.
--                                                        See the Data Structure Specification:covlevel_tbl_type
--        X_combination_valid     VARCHAR2            Returns 'Y' or, 'N'. If 'Y', means all of the
--                                                        records in the input p_covlvl_tbl_in and the
--                                                        p_busiproc_id is valid.
--
--        Output Data Structure Description: covlevel_tbl_type :
--
--        Parameter                   Data Type           Description
--
--        Covlevel_code               VARCHAR2            Covered level code. Input is returned as it is.
--        Covlevel_id                 NUMBER              Covered level Id corresponding to covlevel code.
--                                                            Input is returned as it is.
--        Inv_org_id                  NUMBER              Inventory_organization_id for covlevel_code = 'OKX_COVITEM'.
--                                                            Input is returned as it is.
--        Covered_yn                  VARCHAR2            returns 'Y' or, 'N'. 'Y' means for the given
--                                                            contract_line_id this particular covered level record
--                                                            is valid.
--
--    Procedure Description:
--
--        This API returns if the contract line id is valid for the given input of covered level
--        table of records and the business process id.
--
--        This PROCEDURE returns whether a contract line which was valid is still valid or not.
--        It accepts contract_line_id,business process id, request date(typically , sysdate), p_verify_combination
--        and a table of records of type covlevel_tbl_type which contains covlevel_code,covlevel_id,inv_org_id,covered_yn .
--
--        Valid values for covlevel_code are OKX_CUSTPROD(for installed base item instance), OKX_COVITEM(for inventory item)
--        ,OKX_COVSYST(for installed base system),OKX_CUSTACCT(for customer account),OKX_PARTYSITE(for party site),
--        OKX_PARTY(for party).
--        Valid values for covlevel_id are the corresponding id for the entity covered , for example,
--        if covlevel_code are OKX_CUSTPROD, then covlevel_id is csi_item_instances.instance_id.
--        Also, if the covlevel_code is OKX_COVITEM, then inv_org_id is required. inv_org_id is the inventory organization id
--
--        the same input table of records p_covlevel_tbl_in is returned as output table of records x_covlevel_tbl_out
--        with covered_yn populated.
--
--        if input business process id is NOT VALID for the contract line id, then x_covlevel_tbl_out is returned
--        with all the records populated as covered_yn as 'N',and also if input p_verify_combination is 'Y' is passed, then
--        x_combination_valid is returned as 'N'.
--
--        if input business process id is VALID for the contract line id, and also input p_verify_combination = 'N' is passed,
--        then for each record of x_covlevel_tbl_out returned covered_yn would be assigned 'Y' or, 'N' depending
--        on the covered level for the input record p_covlevel_tbl_in is still covered directly or indirectly by the
--        contract line id.
--
--        if input business process id is VALID for the contract line id, and also input p_verify_combination = 'Y' is passed,
--        then if any one record in input p_covlevel_tbl_in  is still covered directly or indirectly by the contract line id
--        ,all the records in output table x_covlevel_tbl_out will have covered_yn assigned 'N' and also
--        x_combination_valid is returned as 'N'.

  TYPE COVLEVEL_REC IS RECORD
    (covlevel_code                VARCHAR2(50),
     covlevel_id                  NUMBER,
     inv_org_id                   NUMBER,       -- Required if the covlevel_code is OKX_COVITEM
     covered_yn                   VARCHAR2(1)); -- Returns Y or N

  TYPE covlevel_tbl_type IS TABLE OF COVLEVEL_REC INDEX BY BINARY_INTEGER ;

 /*#
  * Returns 'Y' if a Contract Line is valid for a given
  * CONTRACT_LINE_ID, BUSINESS_PROCESS_ID, P_VERIFY_COMBINATION and set of
  * COVLEVEL_CODEs (Coverage Level Codes). See the Metalink note for details
  * on how to set the input parameters to obtain different levels of validation.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_line_id Contract line Id.
  * @param p_busiproc_id Business process ID.
  * @param p_request_date Request date.  Default is sysdate.
  * @param p_covlevel_tbl_in Covered level code and id.
  * @param p_verify_combination Default is 'N'. If 'Y', checks if all the covered level records passed as input are valid for the p_contract_line_id.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_covlevel_tbl_out Covered level code and id passed as input is returned with covered_yn information.
  * @param x_combination_valid Returns 'Y', if all of the records in the input p_covlvl_tbl_in and the p_busiproc_id are valid.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Validate Contract Line
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE validate_contract_line
    (p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2
    ,p_contract_line_id           IN  NUMBER  -- Mandatory
    ,p_busiproc_id                IN  NUMBER  -- optional. If exist, will be validated for the p_request_date
    ,p_request_date               IN  DATE -- optional. DEFAULT is SYSDATE
    ,p_covlevel_tbl_in            IN  covlevel_tbl_type
    ,p_verify_combination         IN  VARCHAR2  -- optional. If it is passed, API will validate the for the combination of covered levels
    ,x_return_status              out nocopy Varchar2
    ,x_msg_count                  out nocopy Number
    ,x_msg_data                   out nocopy Varchar2
    ,x_covlevel_tbl_out           OUT NOCOPY  covlevel_tbl_type
    ,x_combination_valid          OUT NOCOPY VARCHAR2); -- returns Y or N based on the combination

--    Procedure Specification:
--
--  	PROCEDURE Search_Contracts
--    	(p_api_version                IN  Number
--    	,p_init_msg_list              IN  Varchar2
--    	,p_contract_rec               IN  inp_cont_rec_type
--    	,p_clvl_id_tbl                IN  covlvl_id_tbl
--    	,x_return_status              out nocopy Varchar2
--    	,x_msg_count                  out nocopy Number
--    	,x_msg_data                   out nocopy Varchar2
--    	,x_contract_tbl               out nocopy output_tbl_contract);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_rec          inp_cont_rec_type   Yes               See the Data Structure Specification:
--                                                                            inp_cont_rec_type.
--        P_clvl_id_tbl           Clvl_id_tbl         No             Covered level code and id.
--                                                                        See the Data Structure Specification:
--                                                                            clvl_id_tbl.
--
--        Input Record Specification: inp_cont_rec_type
--
--        Parameter               	Data Type           Required        Description and Validations
--
--        Contract_number         	VARCHAR2            No              Input criteria as Contract number.
--        Contract_number_modifier    VARCHAR2            No              Input critera as Contract number modifier.
--													This is must if contract number is
--													passed.
--	  contract_status_code		VARCHAR2            No			Input criteria as contract header status code.
--        start_date_from             DATE			  No              Input criteria as contract header
--													start date range from.
--        start_date_to               DATE			  No 			Input criteria as contract header
--													start date range to.
--        end_date_from               DATE			  No              Input criteria as contract header
--													end date range from.
--        end_date_to                 DATE			  No 			Input criteria as contract header
--													end date range to.
--        date_terminated_from        DATE			  No              Input criteria as contract header
--												      date terminated range from.
--        date_terminated_to          DATE			  No 			Input criteria as contract header
--													date terminated range to.
--        contract_party_id           NUMBER              No              Input criteria as contract header
--													customer party role id.
--        request_date                DATE                No              The date the search carried out.
--												If not passed, defaults sysdate.
--        entitlement_check_YN        VARCHAR2            Yes             valid values are 'Y', or, 'N'.
--												 If passed 'Y', then input P_clvl_id_tbl
--												 should have atleast one record. See below
--												  for details.
--
--        Input Record Specification: Clvl_id_tbl
--
--        Parameter               Data Type           Required        Description and Validations
--
--        Covlvl_code             VARCHAR2            Yes.            Covered level code.
--                                                                        The covered level codes are:
--                                                                        For install base customer product; 'OKX_CUSTPROD',
--                                                                        for inventory item; 'OKX_COVITEM',
--                                                                        for install base system;'OKX_COVSYST',
--                                                                        for customer account;'OKX_CUSTACCT',
--                                                                        for customer party site;'OKX_PARTYSITE',
--                                                                        for customer party;'OKX_PARTY'
--        Covlvl_id               NUMBER              Yes             Covered level Id corresponding to covlvl code.
--                                                                        For example, The covered level id
--                                                                        would be an install base item instance id,
--                                                                        if covered_level_code = 'OKX_CUSTPROD'
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_contract_tbl          output_tbl_contract Output table of records containing the resultset of search
--									See the Data Structure Specification:output_tbl_contract
--
--        Output Data Structure Description: output_tbl_contract :
--
--        Parameter                   Data Type           Description
--
--        Contract_number             VARCHAR2            Contract number.
--        Contract_number_modifier    NUMBER              Contract number modifier.
--        contract_category           VARCHAR2		  Category of service contract.
--        contract_status_code        VARCHAR2            Code representing user defined contract status.
--        known_as                    VARCHAR2            Contract header "known as" value.
--        short_description           VARCHAR2            Contract header description.
--        start_date                  DATE                Contract header start date.
--        end_date                    DATE                Contract header end date.
--        date_terminated             DATE                Contract header date terminated value.
--        contract_amount             NUMBER              contract header estimated amount.
--        currency_code               VARCHAR2            contract header currency code.
--        HD_sts_meaning              VARCHAR2            contract header status code.
--        HD_cat_meaning              VARCHAR2            contract header category meaning.
--
--
--    Procedure Description:
--
--        This API is used by iSupport Advanced search for service contracts.
--
--        This PROCEDURE returns only contract header level information.
--
--        This API can be used both for entitled contract search or, ordinary search.
--
--	  If it is a entitled contract search, then input p_contract_rec.entitlement_check_YN is passed 'Y'
--        and also, a table of records of covered level codes and ids in input p_clvl_id_tbl(REQUIRED,enforced at UI level).
--        Thereafter, only those contracts are returned which are effective at line,subline and coverage line
--        w.r.t sysdate,lines are entitled as per status and operations setup and lines cover the covered
--        levels passed as input both explicitly or, implicitly(as per IB and TCA hierarchy). Also the
--        other input criteria passed in as p_contract_rec are also used to further filter the resultset.
--
--	  If it is not a entitled contract search, then input p_contract_rec.entitlement_check_YN is passed 'N'
--        and also, a table of records of covered level codes and ids in input p_clvl_id_tbl may be passed(OPTIONAL).
--        Thereafter, only  those contracts are returned which have lines that cover the covered
--        levels passed as input both explicitly or, implicitly(as per IB and TCA hierarchy). Also the
--        other input criteria passed in as p_contract_rec are also used to further filter the resultset.

  TYPE covlvl_id_rec IS RECORD
    (covlvl_id                    NUMBER
    ,covlvl_code                  VARCHAR2(30));

  TYPE covlvl_id_tbl IS TABLE OF covlvl_id_rec INDEX BY BINARY_INTEGER;

  TYPE inp_cont_rec_type IS RECORD
    (contract_number        OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_status_code         VARCHAR2(30)
    ,start_date_from              DATE
    ,start_date_to                DATE
    ,end_date_from                DATE
    ,end_date_to                  DATE
    ,date_terminated_from         DATE
    ,date_terminated_to           DATE
    ,contract_party_id            NUMBER
    ,request_date                 DATE
    ,entitlement_check_YN         VARCHAR2(1));


  TYPE output_rec_contract IS RECORD
    (contract_number              OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_category            VARCHAR2(30)
    ,contract_status_code         VARCHAR2(30)
    ,known_as                     VARCHAR2(300)
    ,short_description            VARCHAR2(1995)
    ,start_date                   DATE
    ,end_date                     DATE
    ,date_terminated              DATE
    ,contract_amount              NUMBER
    ,currency_code                VARCHAR2(15)
    ,HD_sts_meaning               VARCHAR2(90)
    ,HD_cat_meaning               VARCHAR2(90));

  TYPE output_tbl_contract IS TABLE OF output_rec_contract INDEX BY BINARY_INTEGER;

  PROCEDURE Search_Contracts
    (p_api_version                IN  Number
    ,p_init_msg_list              IN  Varchar2
    ,p_contract_rec               IN  inp_cont_rec_type
    ,p_clvl_id_tbl                IN  covlvl_id_tbl
    ,x_return_status              out nocopy Varchar2
    ,x_msg_count                  out nocopy Number
    ,x_msg_data                   out nocopy Varchar2
    ,x_contract_tbl               out nocopy output_tbl_contract);

--    Procedure Specification:
--
--        PROCEDURE get_react_resolve_by_time
--        (p_api_version          in number
--        ,p_init_msg_list        in varchar2
--        ,p_inp_rec              in grt_inp_rec_type
--        ,x_return_status        out nocopy varchar2
--        ,x_msg_count            out nocopy number
--        ,x_msg_data             out nocopy varchar2
--        ,x_react_rec            out rcn_rsn_rec_type
--        ,x_resolve_rec          out rcn_rsn_rec_type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec               grt_inp_rec_type    Yes             See Below the Data Structure Specification: grt_inp_rec_type.
--
--
--        Input Record Specification: grt_inp_rec_type
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_line_id        NUMBER              Yes             Service/Warranty/Ext. Warranty Line ID
--        business_process_id     NUMBER              Yes             Business Process ID.
--        severity_id             NUMBER              Yes             Severity ID. service request severity id.
--        request_date            DATE                No              Request Date. The default is system date.
--        time_zone_id            NUMBER              Yes             Request Time Zone ID.
--        category_rcn_rsn        VARCHAR2            Yes             OKS_ENTITLEMENTS_PUB.G_REACTION -
--                                                                        Returns reaction time information.
--                                                                    OKS_ENTITLEMENTS_PUB.G_RESOLUTION -
--                                                                        Returns resolution time information.
--                                                                    OKS_ENTITLEMENTS_PUB.G_REACT_RESOLVE -
--                                                                        Returns reaction and resolution time information.
--        compute_option          VARCHAR2            Yes             OKS_ENTITLEMENTS_PUB.G_BEST -
--                                                                        Returns the best of calculated reaction
--                                                                        and/or resolution time information.
--                                                                    OKS_ENTITLEMENTS_PUB.G_FIRST -
--                                                                        Returns the first calculated reaction
--                                                                        and/or resolution time information.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_react_rec             rcn_rsn_rec_type    Reaction Time information.
--                                                        See the Data Structure Specification: rcn_rsn_rec_type
--        x_resolve_rec           rcn_rsn_rec_type    Resolution Time information.
--                                                        See the Data Structure Specification: rcn_rsn_rec_type.
--
--        Output Record Specification: rcn_rsn_rec_type:
--
--        Parameter               Data Type           Description
--
--        duration                NUMBER              Reaction or Resolution Time.
--        uom                     VARCHAR2            Unit of Measure for Reaction or Resolution Time.
--        by_date_start           DATE                Date and Time by which the Reaction
--                                                        or Resolution has begun for a Service Request.
--        by_date_end             DATE                Date and Time by which the Reaction
--                                                        or Resolution has to be completed for a Service Request.
--
--    Procedure Description:
--
--        This API returns react by start and end times as x_react_rec
--        and resolve by start and end times as x_resolv_rec for the given inputs.
--
--        The API accepts input as a record type grt_inp_rec_type.
--
--        The inputs accepted are
--        contract_line_id,business_process_id,severity_id,request_date,time_zone_id,
--        category_rcn_rsn,compute_option.

    /*vgujarat - modified for access hour ER 9675504*/
  TYPE grt_inp_rec_type IS RECORD
    (contract_line_id             number
    ,business_process_id          number --okx_bus_processes_v.id1%type
    ,severity_id                  number --okx_incident_severits_v.id1%type
    ,request_date                 date
    ,time_zone_id                 number --okx_timezones_v.timezone_id%type
    ,Dates_In_Input_TZ            VARCHAR2(1)  -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,category_rcn_rsn             VARCHAR2(90) --okc_rules_b.rule_information_category%type
    ,compute_option               varchar2(10)
    ,template_yn                  varchar2(1) -- for default coverage enhancement
    ,cust_id                   NUMBER  DEFAULT NULL  --access hour
    ,cust_site_id              NUMBER  DEFAULT NULL  --access hour
    ,cust_loc_id               NUMBER  DEFAULT null);--access hour

  TYPE rcn_rsn_rec_type IS RECORD
    (duration                     number(15,2) --okc_react_intervals.duration%type
    ,uom                          varchar2(3) --okc_react_intervals.uom_code%type
    ,by_date_start                date
    ,by_date_end                  date);

 /*#
  * Returns Reaction times and Resolution times for a given CONTRACT_LINE_ID,
  * BUSINESS_PROCESS_ID, SEVERITY_ID, and TIME_ZONE_ID.  CATEGORY_RCN_RSN can be
  * set to return either Reaction or Resolution time or both.  COMPUTE_OPTION
  * can be set to return the best  calculated Reaction or Resolution time, or
  * the first Reaction or Resolution time.  For details on what value are accepted
  * by the input parameters please refer to the Metalink note.
  *
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_inp_rec The input record search criteria.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_react_rec Reaction Time information.
  * @param x_resolve_rec Resolution Time information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Reaction Resolve By Time
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
/*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE get_react_resolve_by_time
    (p_api_version   in  number
    ,p_init_msg_list in  varchar2
    ,p_inp_rec       in  grt_inp_rec_type
    ,x_return_status out nocopy varchar2
    ,x_msg_count     out nocopy number
    ,x_msg_data	     out nocopy varchar2
    ,x_react_rec     out nocopy rcn_rsn_rec_type
    ,x_resolve_rec   out nocopy rcn_rsn_rec_type);


--    Procedure Specification:
--
--        PROCEDURE Get_Coverage_Type
--        (P_API_Version          IN NUMBER
--        ,P_Init_Msg_List        IN VARCHAR2
--        ,P_Contract_Line_Id     IN NUMBER
--        ,X_Return_Status        out nocopy VARCHAR2
--        ,X_Msg_Count            out nocopy NUMBER
--        ,X_Msg_Data             out nocopy VARCHAR2
--        ,X_Coverage_Type        out nocopy CovType_Rec_Type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_line_id      NUMBER              Yes             Contract Line ID of Service, Extended Warranty
--                                                                        or Warranty.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_coverage_type         Covtype_rec_type    Coverage type information.
--                                                        See the Data Structure Specification: covtype_rec_type.
--
--        Output Data Structure Description: covtype_rec_type :
--
--        Parameter                   Data Type           Description
--
--        Code                        VARCHAR2            Coverage Type Code.
--        Meaning                     VARCHAR2            Coverage Type Meaning.
--        Importance_level            NUMBER              Coverage type Importance Level.
--
--    Procedure Description:
--
--        This API returns the coverage type and importance level information for a contract
--        line id.
--
--        This PROCEDURE accepts contract_line_id as an input and returns a record of
--        coverage_type_code , its meaning and the importance level associated to the coverage type.

  TYPE CovType_Rec_Type IS RECORD
    (Code                Oks_Cov_Types_B.Code%TYPE
    ,Meaning             Oks_Cov_Types_TL.Meaning%TYPE
    ,Importance_Level    Oks_Cov_Types_B.Importance_Level%TYPE);

 /*#
  * Returns CODE, MEANING, DESCRIPTION, and IMPORTANCE_LEVEL from
  * OKS_COV_TYPES_V for a given Contract Line Id (CLE_ID).
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_line_id Contract Line ID (CLE_ID)
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_coverage_type Returning Coverage Type information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Coverage Type
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE Get_Coverage_Type
    (P_API_Version		          IN  NUMBER
    ,P_Init_Msg_List		      IN  VARCHAR2
    ,P_Contract_Line_Id	          IN  NUMBER
    ,X_Return_Status 		      out nocopy VARCHAR2
    ,X_Msg_Count 	              out nocopy NUMBER
    ,X_Msg_Data		              out nocopy VARCHAR2
    ,X_Coverage_Type		      out nocopy CovType_Rec_Type);

--    Procedure Specification:
--
--	PROCEDURE Get_HighImp_CP_Contract
--    	(P_API_Version		          IN  NUMBER
--    	,P_Init_Msg_List		      IN  VARCHAR2
--    	,P_Customer_product_Id	      IN  NUMBER
--    	,X_Return_Status 		      out nocopy VARCHAR2
--    	,X_Msg_Count 	              out nocopy NUMBER
--    	,X_Msg_Data		              out nocopy VARCHAR2
--    	,X_Importance_Lvl		      out nocopy High_Imp_level_K_rec);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_customer_product_ID   NUMBER              Yes             Customer product ID(Item isntance) of installed base.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           	Description
--
--        x_return_status         VARCHAR2            	Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              	Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            	Standard OUT Parameter. Error message.
--        x_importance_level      High_Imp_level_K_rec  Contract and Coverage type importance level information.
--                                                        See the Data Structure Specification: High_Imp_level_K_rec.
--
--        Output Data Structure Description: High_Imp_level_K_rec :
--
--        Parameter                   Data Type           Description
--
--        contract_number             VARCHAR2            Contract number.
--        contract_number_modifier    VARCHAR2            Coverage number modifier.
--        contract_status_code        VARCHAR2            Contract header status code.
--        contract_start_date         VARCHAR2            Contract header start date.
--        contract_end_date           VARCHAR2            contract header end date.
--        contract_amount             VARCHAR2            contract header estimated amount.
--        coverage_type               VARCHAR2            meaning of coverage type associated to contract coverage line.
--        coverage_imp_level          NUMBER              importance level associated to coverage type
--
--
--    Procedure Description:
--
--        This API returns contract header and coverage information based on following conditions:
--
--         1.Only the Covered level of 'Covered Product' would be considered
--           No implicit search based on IB or TCA hierarchy .
--         2.Always return only one row, based on the highest importance level (1 being
--           the highest).
--         3.Returns only one row- system picked, even if there are multiple rows selected
--           for the criteria.

  TYPE High_Imp_level_K_rec IS RECORD
    (contract_number              OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
    ,contract_status_code         OKC_K_HEADERS_B.STS_CODE%TYPE
    ,contract_start_date          OKC_K_HEADERS_B.start_date%TYPE
    ,contract_end_date            OKC_K_HEADERS_B.end_date%TYPE
    ,contract_amount              OKC_K_HEADERS_B.ESTIMATED_AMOUNT%TYPE
    ,coverage_type                OKS_COV_TYPES_TL.MEANING%TYPE
    ,coverage_imp_level           OKS_COV_TYPES_B.IMPORTANCE_LEVEL%TYPE);


  PROCEDURE Get_HighImp_CP_Contract
    (P_API_Version		          IN  NUMBER
    ,P_Init_Msg_List		      IN  VARCHAR2
    ,P_Customer_product_Id	      IN  NUMBER
    ,X_Return_Status 		      out nocopy VARCHAR2
    ,X_Msg_Count 	              out nocopy NUMBER
    ,X_Msg_Data		              out nocopy VARCHAR2
    ,X_Importance_Lvl		      out nocopy High_Imp_level_K_rec);

--    Procedure Specification:
--
--        PROCEDURE Get_Contracts_Expiration
--        (p_api_version                  IN Number
--        ,p_init_msg_list                IN Varchar2
--        ,p_contract_id                  IN Number
--        ,x_return_status                out nocopy Varchar2
--        ,x_msg_count                    out nocopy Number
--        ,x_msg_data                     out nocopy Varchar2
--        ,x_contract_end_date            out nocopy date
--        ,x_Contract_Grace_Duration      out nocopy number
--        ,x_Contract_Grace_Period        out nocopy VARCHAR2);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_id           NUMBER              Yes             Contract Id.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_contract_end_date     DATE                Contract End date.
--        x_contract_grace_duration NUMBER            Contract grace duration.
--        x_contract_grace_period VARCHAR2            Contract grace period.
--
--
--    Procedure Description:
--
--        This API returns the expiration details, that is, contract end date, contract grace
--        period and duration, for a given contract id.
--
--        This PROCEDURE returns the contract end date and the grace details for a given contract id.

 /*#
  * Returns the CONTRACT_END_DATE, CONTRACT_GRACE_PERIOD and CONTRACT_GRACE_DURATION
  * at the Contract Header level, for a given CONTRACT_HEADER_ID (CHR_ID).
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_id Contract Id
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_contract_end_date Contract End date.
  * @param x_Contract_Grace_Duration Contract grace duration.
  * @param x_Contract_Grace_Period Contract grace period.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contracts Expiration
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE Get_Contracts_Expiration
    (p_api_version                IN  Number
    ,p_init_msg_list              IN  Varchar2
    ,p_contract_id                IN  Number
    ,x_return_status              out nocopy Varchar2
    ,x_msg_count                  out nocopy Number
    ,x_msg_data                   out nocopy Varchar2
    ,x_contract_end_date          out nocopy date
    ,x_Contract_Grace_Duration    out nocopy number
    ,x_Contract_Grace_Period      out nocopy VARCHAR2);

--    Procedure Specification:
--
--        PROCEDURE check_coverage_times
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_business_process_id  IN Number
--        ,p_request_date         IN Date
--        ,p_time_zone_id         IN Number
--        ,p_contract_line_id     IN Number
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_covered_yn           OUT NOCOPY Varchar2);
--
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_business_process_id   NUMBER              Yes             Business Process ID.
--        p_request_date          DATE                Yes             Request Date and Time.
--        p_time_zone_id          NUMBER              Yes             Request Time Zone ID.
--        p_contract_line_id      NUMBER              Yes             Line ID of Service,Extended Warranty or Warranty
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_covered_yn            VARCHAR2            'Y'(Coverage time exist) or, 'N'(Coverage time does not exist)
--
--    Procedure Description:
--
--        Procedure check_coverage_times checks if there exists a Coverage Time  for given inputs
--        of request date , Contract line id, business process id, time zone id.

 /*#
  * Return 'Y' if a Coverage Time exists for given contract REQUEST_DATE,
  * CONTRACT_LINE_ID, BUSINESS_PROCESS_ID, and TIME_ZONE_ID, otherwise returns 'N'.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_business_process_id Business Process ID.
  * @param p_request_date Request Date and Time.
  * @param p_time_zone_id Request Time Zone ID.
  * @param p_contract_line_id Line ID of Service, Extended Warranty or Warranty
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_covered_yn 'Y'(Coverage time exist) or, 'N'(Coverage time does not exist)
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Check Coverage Times
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE check_coverage_times
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_business_process_id	   IN  Number
	,p_request_date		       IN  Date
	,p_time_zone_id		       IN  Number
      ,p_Dates_In_Input_TZ           IN  VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
	,p_contract_line_id	       IN  Number
	,x_return_status 	       out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_covered_yn		       out nocopy Varchar2);

--    Procedure Specification:
--
--        PROCEDURE check_reaction_times
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_business_process_id  IN Number
--        ,p_request_date         IN Date
--        ,p_sr_severity          IN Number
--        ,p_time_zone_id         IN Number
--        ,p_contract_line_id     IN Number
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_react_within         OUT NOCOPY Number
--        ,x_react_tuom           OUT NOCOPY Varchar2
--        ,x_react_by_date        OUT NOCOPY Date);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_business_process_id   NUMBER              Yes             Business Process ID.
--        p_request_date          DATE                Yes             Request Date and Time.
--        p_sr_severity           NUMBER              Yes             Severity ID. Service Request Severity ID.
--        p_time_zone_id          NUMBER              Yes             Request Time Zone ID.
--        p_contract_line_id      NUMBER              Yes             Line ID of Service,Extended Warranty or Warranty
--
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_react_within          NUMBER              Reaction Time.
--        x_react_tuom            VARCHAR2            Unit of Measure for Reaction Time.
--        x_react_by_date         DATE                Date and Time by which the reaction or response has to be made for a Service Request.
--
--    Procedure Description:
--
--        Procedure check_reaction_times calculates react by date and time for given inputs of
--        request date , Contract line id, business process id, time zone id, severity id.

 /*#
  * Calculates and returns REACT_BY_DATE and time for given contract
  * REQUEST_DATE, CONTRACT_LINE_ID, BUSINESS_PROCESS_ID, TIME_ZONE_ID, and SEVERITY_ID.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_business_process_id Business Process ID.
  * @param p_request_date Request Date and Time.
  * @param p_sr_severity Severity ID. Service Request Severity ID.
  * @param p_time_zone_id Request Time Zone ID.
  * @param p_contract_line_id Line ID of Service, Extended Warranty or Warranty
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_react_within Reaction Time.
  * @param x_react_tuom Unit of Measure for Reaction Time.
  * @param x_react_by_date Date and Time by which the reaction or response has to be made for a Service Request.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Check Reaction Times
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE check_reaction_times
	(p_api_version		       IN  Number
	,p_init_msg_list		   IN  Varchar2
	,p_business_process_id	   IN  Number
	,p_request_date		       IN  Date
	,p_sr_severity		       IN  Number
	,p_time_zone_id		       IN  Number
      ,p_Dates_In_Input_TZ           IN  VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
	,p_contract_line_id	       IN  Number
	,x_return_status 		   out nocopy Varchar2
	,x_msg_count		       out nocopy Number
	,x_msg_data			       out nocopy Varchar2
	,x_react_within		       out nocopy Number
	,x_react_tuom		       out nocopy Varchar2
	,x_react_by_date		   out nocopy Date
        ,P_cust_id                  IN NUMBER DEFAULT NULL
        ,P_cust_site_id             IN NUMBER DEFAULT NULL
        ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

--    Procedure Specification:
--
--        PROCEDURE get_contacts
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_contract_id          IN Number
--        ,p_contract_line_id     IN Number
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_ent_contacts         OUT NOCOPY ent_contact_tbl);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_id           NUMBER              No              Contract Header ID.
--                                                                        Either p_contract_id, or p_contract_line_id is required.
--        p_contract_line_id      NUMBER              No              Contract Line ID of Service, Extended Warranty
--                                                                        or Warranty. Either p_contract_id, or
--                                                                        p_contract_line_id is required.
--
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_ent_contacts          ent_contact_tbl     Contact information.
--                                                        See the Data Structure Specification ent_contact_tbl.
--
--        Output Data Structure Description: ent_contact_tbl :
--
--        Parameter                   Data Type           Description
--
--        contract_id                 NUMBER              Contract Id.
--        contract_line_id            NUMBER              Contract Line Id.
--        contact_id                  NUMBER              Contact Id.
--        contact_name                VARCHAR2            Contact Name.
--        contact_role_id             NUMBER              Contact Role Id.
--        contact_role_code           VARCHAR2            Contact Role Code.
--        contact_role_name           VARCHAR2            Contact Role Name.
--
--    Procedure Description:
--
--        This API returns the Contact information for a contract or a line.
--
--        This Procedure Returns contact information at contract and all the line levels
--        if only input contract id is passed. if in addition the contract line id is also
--        passed as input, then the contacts for that contract line are only returned.

  TYPE ent_contact_rec IS RECORD
	(contract_id		          Number,
	 contract_line_id		      Number,
	 contact_id			          Number,
	 contact_name		          Varchar2(50),
	 contact_role_id		      Number,
	 contact_role_code	          Varchar2(30),
	 contact_role_name	          Varchar2(80));

  TYPE ent_contact_tbl IS TABLE OF ent_contact_rec INDEX BY BINARY_INTEGER;

 /*#
  * Returns the contacts in a Contract. If CONTRACT_ID is passed as the only parameter,
  * all contacts for a Contract at all the line levels are returned.
  * If the CONTRACT_LINE_ID is also passed, only the contacts for
  * that contract line are returned.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_id Contract Header Id
  * @param p_contract_line_id Contract Line ID  Either p_contract_id, or p_contract_line_id is required.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_ent_contacts The returning contact information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Contacts
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_contacts
	(p_api_version		          IN  Number
	,p_init_msg_list		      IN  Varchar2
	,p_contract_id		          IN  Number
	,p_contract_line_id	          IN  Number
	,x_return_status 		      out nocopy Varchar2
	,x_msg_count		          out nocopy Number
	,x_msg_data			          out nocopy Varchar2
	,x_ent_contacts		          out nocopy ent_contact_tbl);

--    Procedure Specification:
--
--        PROCEDURE get_preferred_engineers
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_contract_line_id     IN Number
--        ,P_business_process_id  IN NUMBER default NULL
--        ,P_request_date         IN DATE default sysdate
--        ,x_return_status        OUT NOCOPY Varchar2
--        ,x_msg_count            OUT NOCOPY Number
--        ,x_msg_data             OUT NOCOPY Varchar2
--        ,x_prf_engineers        OUT NOCOPY prfeng_tbl_type);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_contract_line_id      NUMBER              Yes             Contract Line ID of Service, Extended Warranty
--                                                                        or Warranty.
--        P_business_process_id   NUMBER              No              Business Process ID.
--        P_request_date          DATE                No              Request date. The default is sysdate.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_prf_engineers         prfeng_tbl_type     Contact information.
--                                                        See the Data Structure Specification prfeng_tbl_type.
--
--        Output Data Structure Description: prfeng_tbl_type :
--
--        Parameter                   Data Type           Description
--
--        Business_process_id         NUMBER              Business process id.
--        engineer_id                 NUMBER              Engineer Id.(Also means resource Id/resource group Id)
--        resource_type               VARCHAR2            Resource Type.
--        Primary_flag                VARCHAR2            Primary Flag.
--        Resource_class              VARCHAR2            Resource class. The values are:
--                                                               'P' : Primary
--										                       'R' : Preferred
--										                       'E' : Excluded
--
--    Procedure Description:
--
--        This API returns the details of Preferred Engineers for a Service, Extended Warranty
--        or Warranty.
--
--        This Procedure returns preferred resources information based on a given contract_line_id,
--        request_date and business_process_id.
--
--        If only contract_line_id is passed as an input,
--        preferred resources for all effective business process lines would be returned .
--
--        If contract_line_id,business_process_id and request_date are passed as inputs,
--        preferred resources for the effective business process lines associated to the
--        given business process id would be returned.


  TYPE prfeng_rec_type IS RECORD(
      Business_process_id		NUMBER, -- added for 11.5.9 (patchset I) enhancement # 2467065
      engineer_id       Number,
      resource_type     Varchar2(30),
      Primary_flag		VARCHAR2(1),     -- added for 11.5.9 (patchset I) enhancement # 2467065 --no more used.
      Resource_class  VARCHAR2(30) ); -- Added for  Enhancement of excluded resource.


  TYPE prfeng_tbl_type IS TABLE OF prfeng_rec_type INDEX BY BINARY_INTEGER;

 /*#
  * Returns preferred resources information based on a given CONTRACT_LINE_ID,
  * REQUEST_DATE and BUSINESS_PROCESS_ID.  If CONTRACT_LINE_ID is passed as the only
  * input parameter, preferred resources for all effective Business Process Lines are
  * returned.  If CONTRACT_LINE_ID, BUSINESS_PROCESS_ID and REQUEST_DATE are
  * passed, preferred resources for the effective Business Process Lines
  * associated to the given BUSINESS_PROCESS_ID are returned.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_contract_line_id Contract Line ID of Service, Extended Warranty or Warranty.
  * @param p_business_process_id Business Process ID.
  * @param p_request_date Request date. The default is sysdate.
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_prf_engineers The returning list of preferred engineers.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Preferred Engineers
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE get_preferred_engineers
	(p_api_version				  IN  Number
	,p_init_msg_list			  IN  Varchar2
	,p_contract_line_id	       	  IN  Number
    ,P_business_process_id		  IN  NUMBER default NULL		-- added for 11.5.9 (patchset I) enhancement # 2467065
	,P_request_date		      	  IN  DATE   -- added for 11.5.9 (patchset I) enhancement # 2467065
	,x_return_status 			  OUT nocopy Varchar2
	,x_msg_count				  OUT nocopy Number
	,x_msg_data					  OUT nocopy Varchar2
	,x_prf_engineers			  OUT nocopy prfeng_tbl_type);


--    Procedure Specification:
--
--     PROCEDURE Oks_Validate_System
--   	(P_API_Version		          IN  NUMBER
--    	,P_Init_Msg_List		      IN  VARCHAR2
--      ,P_System_Id	              IN  NUMBER
--      ,P_Request_Date               IN  DATE default sysdate
--      ,P_Update_Only_Check          IN  VARCHAR2
--      ,X_Return_Status 		      out nocopy VARCHAR2
--      ,X_Msg_Count 	              out nocopy NUMBER
--      ,X_Msg_Data		              out nocopy VARCHAR2
--      ,X_System_Valid		          out nocopy VARCHAR2);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_system_id             NUMBER              Yes             Installed base System Id.
--        P_request_date          DATE                No              Request date. The default is sysdate.
--        p_update_only_check     VARCHAR2            Yes             Valid inputs are 'Y' or, 'N'.
--												If 'Y', then does an additional
--												validation check if the business process
--												is atleast allowed for service request,
--                                                                        depot repair or, field service.
--
--
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_system_valid          VARCHAR2            Returns 'Y' if the system is valid else, returns 'N'.
--
--    Procedure Description:
--
--        This API returns if the Installed base(IB) system is valid as per a preset business rule.
--
--        The business rule followed is the API gets all the contract lines which cover the IB system explicity or,
--        implicitly (that is, as per , IB and TCA hieararchy). If there exists such a contract line
--        and if input p_update_only_check is passed 'N', then return with x_system_valid as 'Y' but,
--        If input p_update_only_check is passed 'Y', then check for all contract lines if any of those
--        have associated business process allowed for any of service request, depot repair or,
--        field service and if such a contract line exists return with x_system_valid as 'Y'.
--
--        If the above processing does not a get a valid contract line then,
--        carry the above steps in a loop for each of the IB item instances belonging to
--        the input IB system. If a match exists, exit the loop and API immediately,  returning
--        with x_system_valid as 'Y'.
--
--        If in either of the above processing does not return a valid contract line API returns
--        with x_system_valid as 'N'.
--
--        Refer to ER#2279900 for details.

  PROCEDURE OKS_VALIDATE_SYSTEM
    (P_API_Version		          IN  NUMBER
    ,P_Init_Msg_List		      IN  VARCHAR2
    ,P_System_Id	              IN  NUMBER
    ,P_Request_Date               IN  DATE
    ,P_Update_Only_Check          IN  VARCHAR2
    ,X_Return_Status 		      out nocopy VARCHAR2
    ,X_Msg_Count 	              out nocopy NUMBER
    ,X_Msg_Data		              out nocopy VARCHAR2
    ,X_System_Valid		          out nocopy VARCHAR2);

--    Procedure Specification:
--
--    PROCEDURE Default_Contline_System
--    (P_API_Version		          IN  NUMBER
--    ,P_Init_Msg_List		      IN  VARCHAR2
--    ,P_System_Id	              IN  NUMBER
--    ,P_Request_Date               IN  DATE default sysdate
--    ,X_Return_Status 		      out nocopy VARCHAR2
--    ,X_Msg_Count 	              out nocopy NUMBER
--    ,X_Msg_Data		              out nocopy VARCHAR2
--    ,X_Ent_Contracts		      out nocopy Default_Contline_System_Rec);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_system_id             NUMBER              Yes             Installed base System Id.
--        P_request_date          DATE                No              Request date. The default is sysdate.
--
--
--
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           		Description
--
--        x_return_status         VARCHAR2            		Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              		Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            		Standard OUT Parameter. Error message.
--        X_Ent_Contracts         Default_Contline_System_Rec Returns the valid contract line details.
--										See Datastructure specification: get_contop_rec for further
--										details in one of the get_contracts overloaded API,
--										which accepts record type get_contin_rec as input.
--
--    Procedure Description:
--
--        This API accepts Installed base(IB) system , passed as input and returns the contract line
--        and associated information as per a preset business rule.
--
--        The business rule followed is the API gets all the contract lines which cover the IB system explicity or,
--        implicitly (that is, as per , IB and TCA hieararchy). If there exists only one contract line,
--        that is returned as the default contract line.If there exists only more than
--        one contract line,those contract lines are sorted with highest importance level and then returns contract line
--        with highest importance level as the default contract line. If there exists more than one
--        contract line with same highest importance level, then those contract lines are again filtered
--        and those selected having Preferred Resource Group(okc_contacts.jtot_object1_code = OKS_RSCGROUP).
--        If there exists only one contract line with Preferred Resource Group, then returns that contract line as the
--        default contract line. If there exists more than one contract line with Preferred Resource Group
--        then, the these contract lines are further filtered for latest end date. If there exists one
--        contract line with latest end date, then that is returned as the default contract line.If there exists
--        more than one contract line with the latest end date, then the the first record is picked randomly.
--
--        If the above processing does not a get a default contract line then,
--        carry the above steps in a loop for each of the IB item instances belonging to
--        the input IB system. If a match exists, exit the loop and API immediately,  returning
--        with the default contract line as the output else, no default contract line is returned.
--
--
--        Refer to ER#2279911 for details.


  SUBTYPE Default_Contline_System_Rec  IS  get_contop_rec;

  PROCEDURE Default_Contline_System
    (P_API_Version		          IN  NUMBER
    ,P_Init_Msg_List		      IN  VARCHAR2
    ,P_System_Id	              IN  NUMBER
    ,P_Request_Date               IN  DATE
    ,X_Return_Status 		      out nocopy VARCHAR2
    ,X_Msg_Count 	              out nocopy NUMBER
    ,X_Msg_Data		              out nocopy VARCHAR2
    ,X_Ent_Contracts		      out nocopy Default_Contline_System_Rec);

--    Procedure Specification:
--
--        PROCEDURE Get_cov_txn_groups
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_inp_rec_bp           IN inp_rec_bp
--        ,x_return_status        out nocopy Varchar2
--        ,x_msg_count            out nocopy Number
--        ,x_msg_data             out nocopy Varchar2
--        ,x_cov_txn_grp_linesout nocopy output_tbl_bp);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_inp_rec_bp            Inp_rec_bp          Yes             Contract line information.
--                                                                        See the Data Structure Specification: inp_rec_bp
--
--        Input Record Specification: inp_rec_bp
--
--        Parameter               Data Type           Required        Description and Validations
--
--        contract_line_id        NUMBER              Yes             Contract line id.
--        Check_bp_def            VARCHAR2            No              Check Business process definition.
--        Sr_enabled              VARCHAR2            No              Flag to check if
--                                                                        business process is setup for service request.
--        Dr_enabled              VARCHAR2            No              Flag to check if
--                                                                        business process is setup for depot repair.
--        Fs_enabled              VARCHAR2            No              Flag to check if
--                                                                        business process is setup for field service.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_cov_txn_grp_lines     Output_tbl_bp       Coverage Business process line level information.
--                                                         See the Data Structure Specification: output_tbl_bp.
--
--        Output Data Structure Description: output_tbl_bp :
--
--        Parameter                   Data Type           Description
--
--        Cov_txn_group_line_id       NUMBER              Business process line id in the coverage
--        Bp_id                       NUMBER              Business process id.
--        Start_date                  DATE                Business process line start date.
--        End date                    DATE                Business process line end date.
--
--    Procedure Description:
--
--        This API returns the business process line level information in the coverage based
--        on the business process setup done for a given input of contract line id.
--
--        This PROCEDURE returns a table of records of type output_tbl_bp which contains
--        coverage transaction group line id(business process line),business process id,
--        transaction group line start date and end date for a contract line id .
--
--        if check_bp_def = 'Y', then only those business process lines for the given contract line id
--        are returned whose associated business process id passes the business process Setup check of
--        service request enabled flag (if SR_enabled = 'Y'), depot repair enabled flag(if DR_enabled is 'Y')and
--        field service enabled flag(if FS_enabled is 'Y').
--
--        if check_bp_def = 'N', then all the business process lines for the given contract line id
--        are returned.

  TYPE inp_rec_bp IS RECORD
    (contract_line_id             NUMBER
    ,check_bp_def	              VARCHAR2(1)
    ,sr_enabled	                  VARCHAR2(1)
    ,dr_enabled	                  VARCHAR2(1)
    ,fs_enabled	                  VARCHAR2(1));

  TYPE output_rec_bp  IS RECORD
    (cov_txn_grp_line_id          NUMBER
    ,bp_id                        number
    ,start_date                   date
    ,end_date                     date);

  TYPE output_tbl_bp IS TABLE OF output_rec_bp INDEX BY BINARY_INTEGER;

 /*#
  * Returns the all Business Process Ids, along with their Start and End
  * dates for a given Service Contract Line Id.  The result set may be
  * configured to selectively filter Business Process Ids.  By setting
  * CHECK_BP_DEF = 'Y', the filtering mechanism will be activated.
  * Furthermore, by setting SR_Enabled, DR_Enabled, and/or FS_Enabled to 'Y',
  * only Business Process Ids will be returned for Service Requests, Depot Repair
  * and/or Field Service respectively.  If CHECK_BP_DEF = 'N', then all the
  * Business Process Lines for the given Contract Line Id are returned.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_inp_rec_bp Contract Line Information
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_cov_txn_grp_lines Coverage Business process line level information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Coverage Transaction Groups
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE Get_cov_txn_groups
	(p_api_version		          IN  Number
	,p_init_msg_list		      IN  Varchar2
	,p_inp_rec_bp		          IN  inp_rec_bp
    ,x_return_status 		      out nocopy Varchar2
	,x_msg_count		          out nocopy Number
	,x_msg_data			          out nocopy Varchar2
	,x_cov_txn_grp_lines		  out nocopy output_tbl_bp);

--    Procedure Specification:
--
--        PROCEDURE Get_txn_billing_types
--        (p_api_version          IN Number
--        ,p_init_msg_list        IN Varchar2
--        ,p_cov_txngrp_line_id   IN Number
--        ,p_return_bill_rates_YN IN Varchar2
--        ,x_return_status        out nocopy Varchar2
--        ,x_msg_count            out nocopy Number
--        ,x_msg_data             out nocopy Varchar2
--        ,x_txn_bill_types       out nocopy output_tbl_bt
--        ,x_txn_bill_rates       out nocopy output_tbl_br);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           Required        Description and
--                                                                    Validations
--
--        p_api_version           NUMBER              Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            Yes             Standard IN Parameter.Initializes message list.
--        p_cov_txngrp_line_id    NUMBER              Yes             Coverage transaction group line id.
--        P_return_bill_rates_yn  VARCHAR2            Yes             Flag to indicate if labor bill rates
--                                                                        to be returned as output.
--                                                                        Valid values are 'Y' or, 'N'.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           Description
--
--        x_return_status         VARCHAR2            Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            Standard OUT Parameter. Error message.
--        x_txn_bill_types        Output_tbl_bt       Coverage service activity billing type line level information.
--                                                        See the Data Structure Specification: output_tbl_bt.
--        X_txn_bill_rates        Output_tbl_br       Coverage labor bill rate line level information.
--                                                        See the Data Structure Specification: output_tbl_br.
--
--        Output Data Structure Description: Output_tbl_bt :
--
--        Parameter                   Data Type           Description
--
--        txn_bt_line_id              NUMBER              Coverage Service activity billing type line id.
--        Txn_bill_type_id            NUMBER              Service activity billing type id.
--        Covered_upto_amount         NUMBER              The amount covered by the Coverage
--                                                            Service activity billing type line id.
--        Percent_covered             NUMBER              The percent covered by the Coverage
--                                                            Service activity billing type line id.
--
--        Output Data Structure Description: Output_tbl_br :
--
--        Parameter                   Data Type           Description
--
--        Cov_txn_group_line_id       NUMBER              Business process line id in the coverage
--        Bp_id                       NUMBER              Business process id.
--        Start_date                  DATE                Business process line start date.
--        End date                    DATE                Business process line end date.
--
--        bt_line_id                  NUMBER              Coverage Service activity billing type line id.
--        Br_line_id                  NUMBER              Coverage labor bill rate line id.
--        Br_schedule_id              NUMBER              Coverage labor bill rate schedule id.
--        Bill_rate                   VARCHAR2            Labor bill rate code.
--        Flat rate                   NUMBER              Flat rate for labor bill rate code.
--        UOM                         VARCHAR2            UOM.
--        Percent_over_list_price     NUMBER              Percent over list price.
--        Start_hour                  NUMBER              Labor bill rate schedule start hour.
--        Start_minute                NUMBER              Labor bill rate schedule start minute.
--        End_hour                    NUMBER              Labor bill rate schedule end hour.
--        End_minute                  NUMBER              Labor bill rate schedule end minute.
--        Monday_flag                 VARCHAR2            Flag indicating if Labor bill rate schedule is for Monday.
--        Tuesday_flag                VARCHAR2            Flag indicating if Labor bill rate schedule is for Tuesday.
--        Wednesday_flag              VARCHAR2            Flag indicating if Labor bill rate schedule is for Wednesday.
--        Thursday_flag               VARCHAR2            Flag indicating if Labor bill rate schedule is for Thursday.
--        Friday_flag                 VARCHAR2            Flag indicating if Labor bill rate schedule is for Friday.
--        Saturday_flag               VARCHAR2            Flag indicating if Labor bill rate schedule is for Saturday.
--        Sunday_flag                 VARCHAR2            Flag indicating if Labor bill rate schedule is for Sunday.
--        Labor_item_org_id           NUMBER              Inventory Labor item organization id for the
--                                                            Labor bill rate schedule.
--        Labor_item_id               NUMBER              Inventory Labor item id for the Labor bill rate schedule.
--        Holiday_YN                  VARCHAR2            Flag indicating if Labor bill rate schedule is for holiday.
--
--
--    Procedure Description:
--
--        This API returns the service activity billing type line level information and labor bill
--        rate level information in the coverage based on the coverage business process line id
--        (transaction group line id).
--
--        This PROCEDURE returns a table of records of type output_tbl_bt which contains
--        service activity billing type information for the given p_cov_txngrp_line_id(business process line id)
--        and also returns a table of records of type output_tbl_br which contains labor bill rate information
--        for service activity billing type line if it is of billing_category = 'LABOR'.
--
--        labor bill rate information are returned only if input p_return_bill_rates_YN = 'Y'.

  TYPE output_rec_bt IS RECORD
    (Txn_BT_line_id               NUMBER
    ,txn_bill_type_id             Number
    ,Covered_upto_amount          Number
    ,percent_covered              Number);

  TYPE output_tbl_bt IS TABLE OF output_rec_bt INDEX BY BINARY_INTEGER;

  TYPE output_rec_br IS RECORD
    (BT_line_id                   NUMBER
    ,Br_line_id                   NUMBER
    ,Br_schedule_id               NUMBER
    ,bill_rate                    VARCHAR2(30)
    ,flat_rate                    NUMBER
    ,uom                          VARCHAR2(30)
    ,percent_over_list_price      NUMBER
    ,start_hour                   NUMBER
    ,start_minute                 NUMBER
    ,end_hour                     NUMBER
    ,end_minute                   NUMBER
    ,monday_flag                  VARCHAR2(1)
    ,tuesday_flag                 VARCHAR2(1)
    ,wednesday_flag               VARCHAR2(1)
    ,thursday_flag               VARCHAR2(1)
    ,friday_flag                  VARCHAR2(1)
    ,saturday_flag                VARCHAR2(1)
    ,sunday_flag                  VARCHAR2(1)
    ,labor_item_org_id            number
    ,labor_item_id                number
    ,holiday_yn                   VARCHAR2(1)
    );

  TYPE output_tbl_br IS TABLE OF output_rec_br INDEX BY BINARY_INTEGER;


 /*#
  * Returns the Billing Types, and Labor Bill Rates for a Business Process Id.
  * Labor bill rate information is returned only if input p_return_bill_rates_YN = 'Y'.
  * @param p_api_version Version numbers of incoming calls much match this number.
  * @param p_init_msg_list FND_API.G_TRUE or FND_API.G_FALSE indicates if the API message list is initialized.
  * @param p_cov_txngrp_line_id Coverage transaction group line id.
  * @param p_return_bill_rates_YN Flag to indicate if labor bill rates
  * @param x_return_status Possible status return values are 'S'uccess, 'E'rror or 'U'nexpected error.
  * @param x_msg_count Returns number of messages in the API message list.
  * @param x_msg_data If x_msg_count is '1' then the message data is encoded.
  * @param x_txn_bill_types Coverage service activity billing type line level information.
  * @param x_txn_bill_rates Coverage labor bill rate line level information.
  * @rep:scope public
  * @rep:lifecycle active
  * @rep:displayname Get Transaction Billing Types
  * @rep:category BUSINESS_ENTITY OKS_ENTITLEMENT
  * @rep:metalink 284732.1 See Oracle Metalink Bulletin 284732.1
  */
  PROCEDURE Get_txn_billing_types
	(p_api_version		          IN  Number
	,p_init_msg_list	          IN  Varchar2
	,p_cov_txngrp_line_id	      IN  Number
    ,p_return_bill_rates_YN       IN  Varchar2
	,x_return_status 	          out nocopy Varchar2
	,x_msg_count		          out nocopy Number
	,x_msg_data		              out nocopy Varchar2
	,x_txn_bill_types		      out nocopy output_tbl_bt
    ,x_txn_bill_rates             out nocopy output_tbl_br);


--    Procedure Specification:
--
--  	PROCEDURE Search_Contract_Lines
--    	(p_api_version         		IN  Number
--    	,p_init_msg_list       		IN  Varchar2
--    	,p_contract_rec        		IN  srchline_inpcontrec_type
--    	,p_contract_line_rec          IN  srchline_inpcontlinerec_type
--    	,p_clvl_id_tbl         		IN  srchline_covlvl_id_tbl
--    	,x_return_status       		out nocopy Varchar2
--    	,x_msg_count           		out nocopy Number
--    	,x_msg_data            		out nocopy Varchar2
--    	,x_contract_tbl        		out nocopy output_tbl_contractline);
--
--    Current Version:
--        1.0
--
--    Parameter Descriptions:
--
--        The following table describes the IN parameters associated with this API.
--
--        Parameter               Data Type           			Required        Description and
--                                                            		        Validations
--
--        p_api_version           NUMBER              			Yes             Standard IN Parameter.Represents API version.
--        p_init_msg_list         VARCHAR2            			Yes             Standard IN Parameter.Initializes message list.
--        p_contract_rec          srchline_inpcontrec_type   		Yes             Contract header level input criteria.
--														See the Data Structure Specification:
--                                                                        	    	srchline_inpcontrec_type.
--        p_contract_line_rec     srchline_inpcontlinerec_type	No              Contract line level input criteria.
--														See the Data Structure Specification:
--                                                                            		srchline_inpcontlinerec_type.
--        P_clvl_id_tbl           srchline_covlvl_id_tbl            No              Covered line level input critria.
--                                                                   		     See the Data Structure Specification:
--                                                                            		srchline_covlvl_id_tbl.
--
--        Input Record Specification: srchline_inpcontrec_type
--
--        Parameter               	Data Type           Required        Description and Validations
--
--	  Contract_Id             	NUMBER              No              Input criteria as Contract Id.
--        Contract_number         	VARCHAR2            No              Input criteria as Contract number.
--        Contract_number_modifier    VARCHAR2            No              Input critera as Contract number modifier.
--													This is must if contract number is
--													passed.
--	  contract_status_code		VARCHAR2            No			Input criteria as contract header status code.
--        start_date_from             DATE			  No              Input criteria as contract header
--													start date range from.
--        start_date_to               DATE			  No 			Input criteria as contract header
--													start date range to.
--        end_date_from               DATE			  No              Input criteria as contract header
--													end date range from.
--        end_date_to                 DATE			  No 			Input criteria as contract header
--													end date range to.
--        date_terminated_from        DATE			  No              Input criteria as contract header
--												      date terminated range from.
--        date_terminated_to          DATE			  No 			Input criteria as contract header
--													date terminated range to.
--        contract_party_id           NUMBER              No              Input criteria as contract header
--													customer party role id.
--        contract_renewal_type_code  VARCHAR2            No              Input criteria as contract header
--													renewal type code.
--        request_date                DATE                No              The date the search carried out.
--												If not passed, defaults sysdate.
--        entitlement_check_YN        VARCHAR2            Yes             valid values are 'Y', or, 'N'.
--												 If passed 'Y', then input P_clvl_id_tbl
--												 should have atleast one record. See below
--												  for details.
--        authoring_org_id            NUMBER              No              Input criteria as contract authoring org id.
--													introduced for multi org security check.
--        contract_group_id           NUMBER              No              Input criteria as contract group id.
--
--
--
--        Input Record Specification: srchline_inpcontlinerec_type
--
--        Parameter               	Data Type           Required        Description and Validations
--
--	  service_item_id            	NUMBER              No              Input criteria as Service item id as defined
--												  Inventory.
--	  contract_line_status_code	VARCHAR2            No			Input criteria as contract line status code.
--	  coverage_type_code     	VARCHAR2            No			Input criteria as coverage type code.
--        start_date_from             DATE			  No              Input criteria as contract line
--													start date range from.
--        start_date_to               DATE			  No 			Input criteria as contract line
--													start date range to.
--        end_date_from               DATE			  No              Input criteria as contract line
--													end date range from.
--        end_date_to                 DATE			  No 			Input criteria as contract line
--													end date range to.
--        line_bill_to_site_id        NUMBER              No              Input criteria as contract line
--													customer account bill to site id.
--        line_ship_to_site_id        NUMBER              No              Input criteria as contract line
--													customer account ship to site id.
--        line_renewal_type_code      VARCHAR2            No              Input criteria as contract line
--													renewal type code.
--
--
--        Input Record Specification: srchline_covlvl_id_tbl
--
--        Parameter               Data Type           Required        Description and Validations
--
--        Covlvl_code             VARCHAR2            Yes.            Covered level code.
--                                                                        The covered level codes are:
--                                                                        For install base customer product; 'OKX_CUSTPROD',
--                                                                        for inventory item; 'OKX_COVITEM',
--                                                                        for install base system;'OKX_COVSYST',
--                                                                        for customer account;'OKX_CUSTACCT',
--                                                                        for customer party site;'OKX_PARTYSITE',
--                                                                        for customer party;'OKX_PARTY'
--        Covlvl_id1               NUMBER              Yes             Covered level Id corresponding to covlvl code.
--                                                                        For example, The covered level id
--                                                                        would be an install base item instance id,
--                                                                        if covered_level_code = 'OKX_CUSTPROD'
--        Covlvl_id2               NUMBER              Yes             This is to be passed as inventory_organization_id
--									                                    only if covlvl_code = 'OKX_COVITEM'.
--
--        The following table describes the OUT parameters associated with this API:
--
--        Parameter               Data Type           		Description
--
--        x_return_status         VARCHAR2            		Standard OUT Parameter.API return stautus.'S'(Success),'U'(Unexpected Error),'E'(Error)
--        x_msg_count             NUMBER              		Standard OUT Parameter.Error message count.
--        x_msg_data              VARCHAR2            		Standard OUT Parameter. Error message.
--        x_contract_tbl          output_tbl_contractline 	Output table of records containing the resultset of search
--											See the Data Structure Specification:
--												output_tbl_contractline
--
--        Output Data Structure Description: output_tbl_contractline :
--
--        Parameter                   Data Type           Description
--
--        Contract_number             VARCHAR2            Contract number.
--        Contract_number_modifier    NUMBER              Contract number modifier.
--        contract_line_number        VARCHAR2            line number of contract lines.
--        contract_line_type          VARCHAR2            line type of contract line.
--        service_name                VARCHAR2            name of service item.
--        contract_description        VARCHAR2		  Description at contract header.
--        line_start_date			DATE			  contract line start date.
--        line_end_date               DATE                contract line end date.
--        contract_line_status_code   VARCHAR2            Code representing user defined contract status for contract line.
--        coverage_name               VARCHAR2            name of the coverage associated to the contract line.
--        service_id                  NUMBER              contract line id.
--        service_lse_id              NUMBER              line style for the contract line id.
--        contract_id                 NUMBER              contract id.
--        coverage_line_id            NUMBER              coverage line id.
--        scs_code                    VARCHAR2            contract category of the contract line.
--
--    Procedure Description:
--
--        This API is used by entitlements search UI.
--
--        This API can be used both for entitlement based search or, ordinary search .
--
--	  If it is a entitled contract search, then input p_contract_rec.entitlement_check_YN is passed 'Y'
--        and also, a table of records of covered level codes and ids in input p_clvl_id_tbl(REQUIRED,enforced at UI level).
--        Thereafter, only those contracts are returned which are effective at line,subline and coverage line
--        w.r.t sysdate,lines are entitled as per status and operations setup and lines cover the covered
--        levels passed as input both explicitly or, implicitly(as per IB and TCA hierarchy). Also the
--        other header input criteria passed in as p_contract_rec and line input criteria passed in as
--        p_contract_line_rec are also used to further filter the resultset.
--
--	  If it is not a entitled contract search, then input p_contract_rec.entitlement_check_YN is passed 'N'
--        and also, a table of records of covered level codes and ids in input p_clvl_id_tbl may be passed(OPTIONAL).
--        Thereafter, only  those contracts are returned which have lines that cover the covered
--        levels passed as input both explicitly or, implicitly(as per IB and TCA hierarchy). Also the
--        other header input criteria passed in as p_contract_rec and line input criteria passed in as
--        p_contract_line_rec are also used to further filter the resultset.

   TYPE srchline_inpcontrec_type IS RECORD
    (contract_id                    number
    ,contract_number        	    OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier     	OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_status_code         	VARCHAR2(30)
    ,start_date_from              	DATE
    ,start_date_to                	DATE
    ,end_date_from                	DATE
    ,end_date_to                  	DATE
    ,date_terminated_from         	DATE
    ,date_terminated_to          	DATE
    ,contract_party_id            	NUMBER
    ,contract_renewal_type_code     VARCHAR2(30)
    ,request_date                 	DATE
    ,entitlement_check_YN           VARCHAR2(1)
    ,authoring_org_id               number -- introduced for multi org security check filteration
    ,contract_group_id              number -- additional contract header level search criteria
    );


  TYPE srchline_inpcontlinerec_type IS RECORD
    (service_item_id         	number
    ,contract_line_status_code   	VARCHAR2(30)
    ,coverage_type_code         	VARCHAR2(30)
    ,start_date_from              	DATE
    ,start_date_to                	DATE
    ,end_date_from                	DATE
    ,end_date_to                  	DATE
    ,line_bill_to_site_id                  number
    ,line_ship_to_site_id                number
    ,line_renewal_type_code         varchar2(30));

  TYPE srchline_inpcontlinerec_tbl  IS TABLE OF srchline_inpcontlinerec_type INDEX BY BINARY_INTEGER;

  TYPE srchline_covlvl_id_rec IS RECORD
    (covlvl_id1              		NUMBER
    ,covlvl_id2              		NUMBER
    ,covlvl_code      		VARCHAR2(30));

  TYPE srchline_covlvl_id_tbl  IS TABLE OF srchline_covlvl_id_rec INDEX BY BINARY_INTEGER;

  TYPE output_rec_contractline IS RECORD
    (contract_number              	OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,contract_number_modifier      OKC_K_HEADERS_B.contract_number_modifier%TYPE
    ,contract_line_number           OKC_K_LINES_B.LINE_NUMBER%TYPE
    ,contract_line_type             OKC_LINE_STYLES_TL.NAME%TYPE  --  VARCHAR2(80) BUG# 4198718
    ,Service_name                     	VARCHAR2(1995)
    ,contract_description            	VARCHAR2(1995)
    ,line_start_date                   	DATE
    ,line_end_date                     	DATE
    ,contract_line_status_code    	OKC_STATUSES_TL.MEANING%TYPE  --VARCHAR2(30) BUG# 4198718
    ,Coverage_Name                  OKC_K_LINES_TL.Name%TYPE
    ,Service_Id                     NUMBER --OKC_K_LINES_B.Id%TYPE
    ,Service_Lse_ID                 OKC_K_LINES_B.Lse_Id%TYPE
    ,CovLevel_Lse_ID                OKC_K_LINES_B.Lse_Id%TYPE
    ,contract_id                    number
    ,coverage_line_id               number
    ,scs_code                       OKC_STATUSES_B.CODE%TYPE  --VARCHAR2(30) BUG# 4198718
    ,OPERATING_UNIT                 NUMBER             -- Modified for 12.0 MOAC project (JVARGHES)
    ,OPERATING_UNIT_NAME            VARCHAR2(300));    -- Modified for 12.0 MOAC project (JVARGHES)

  TYPE output_tbl_contractline IS TABLE OF output_rec_contractline INDEX BY BINARY_INTEGER;

  PROCEDURE Search_Contract_lines
    (p_api_version         		IN  Number
    ,p_init_msg_list       		IN  Varchar2
    ,p_contract_rec        		IN  srchline_inpcontrec_type
    ,p_contract_line_rec        IN  srchline_inpcontlinerec_type
    ,p_clvl_id_tbl         		IN  srchline_covlvl_id_tbl
    ,x_return_status       		out nocopy Varchar2
    ,x_msg_count           		out nocopy Number
    ,x_msg_data            		out nocopy Varchar2
    ,x_contract_tbl        		out nocopy output_tbl_contractline);

END OKS_ENTITLEMENTS_PUB;

/
