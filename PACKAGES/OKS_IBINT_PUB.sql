--------------------------------------------------------
--  DDL for Package OKS_IBINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IBINT_PUB" AUTHID CURRENT_USER As
/* $Header: OKSPIBIS.pls 120.8.12000000.1 2007/01/16 22:06:40 appldev ship $ */

 ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKSOMINT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKS';
  G_FND_LOG_OPTION              CONSTANT VARCHAR2(30)  := NVL(Fnd_Profile.Value('OKS_DEBUG'),'N');
  ---------------------------------------------------------------------------

  Type Instance_rec_type Is Record
 (     old_customer_product_id  Number
       ,old_quantity            Number
       ,Bom_explosion_flag      Varchar2(1)
       ,Old_Unit_of_measure	Varchar2(3)
       ,Old_Inventory_item_id   Number
       ,Old_Customer_acct_id    Number
       ,Organization_id         Number
       ,Bill_to_site_use_id     Number
       ,Ship_to_site_use_id     Number
       ,Org_id	                Number
       ,Order_line_id           Number
       ,Shipped_date            Date
       ,Installation_date       Date
       ,transaction_date        Date

);

Type l_instance_tbl is table of instance_Rec_type index by binary_integer;
instance_tbl l_instance_tbl;
Type txn_instance_rec is record
(

Old_Customer_product_id	NUMBER,
Old_Quantity	NUMBER,
Old_Unit_of_measure	VARCHAR2 (3),
Old_Inventory_item_id	NUMBER,
Old_Customer_acct_id	NUMBER,
New_Customer_product_id	NUMBER,
New_Quantity	NUMBER,
New_Customer_acct_id	NUMBER,
New_inventory_item_id	NUMBER,
New_Unit_of_measure	VARCHAR2(3),
Org_id	NUMBER,
Order_line_id	NUMBER,
Shipped_date	DATE,
Installation_date	DATE,
Bill_to_site_use_id	NUMBER,
Ship_to_site_use_id	NUMBER,
Organization_id	NUMBER,
System_id	NUMBER,
Bom_explosion_flag	VARCHAR2 (1),
Return_reason_code	VARCHAR2 (240),
Raise_credit	VARCHAR2 (50),
Transaction_date	Date,
Transfer_date	Date,
Termination_date	Date,
TRM	VARCHAR2(1),
TRF	VARCHAR2(1),
RET	VARCHAR2(1),
RPL	VARCHAR2(1),
IDC	VARCHAR2(1),
UPD	VARCHAR2(1),
SPL	VARCHAR2(1),
NEW	VARCHAR2(1),
RIN	VARCHAR2(1)
);
Type txn_instance_tbl is table of txn_instance_rec index by binary_integer;
/*
This api is an interface api, called by IB when any instance operation is performed.
For Mass Instance Updates, batch_id and batch_type along with the list of instances
is passed to identify the Mass update operation.
For Instance transfers, instance terminations and instance installation date change, parent instance as well as the components affected by the transaction are passed
*/
Procedure IB_interface(
P_Api_Version	NUMBER,
P_init_msg_list	VARCHAR2,
P_single_txn_date_flag	VARCHAR2,
P_Batch_type	VARCHAR2,
P_Batch_ID	NUMBER,
P_OKS_Txn_Inst_tbl	TXN_INSTANCE_tbl,
x_return_status	OUT NOCOPY VARCHAR2,
x_msg_count	OUT NOCOPY NUMBER,
x_msg_data	OUT NOCOPY VARCHAR2
);


 l_Header_rec       OKS_EXTWAR_UTIL_PVT.Header_Rec_Type;
  l_line_rec         OKS_EXTWAR_UTIL_PVT.Line_Rec_Type;
  War_tbl 	     OKS_EXTWAR_UTIL_PVT.War_tbl;
  l_Service_tbl      OKS_EXTWAR_UTIL_PVT.Service_tbl;
  l_extwar_rec       OKS_EXTWARPRGM_PVT .extwar_rec_Type;

  p_contact_tbl      OKS_EXTWARPRGM_PVT .contact_tbl;
  l_codv_tbl_in      OKS_COD_PVT.codv_tbl_type;
  l_codv_tbl_out     OKS_COD_PVT.codv_tbl_type;
  l_SalesCredit_tbl  OKS_EXTWARPRGM_PVT.SalesCredit_tbl;
  l_SalesCredit_tbl_hdr  OKS_EXTWARPRGM_PVT.SalesCredit_tbl; --mmadhavi bug 4174921
  l_pricing_attributes_in     OKS_EXTWARPRGM_PVT.Pricing_attributes_Type;

  TYPE CP_REC_TYPE Is RECORD
  (
   org_id		Number
  ,customer_product_id  Number
  ,order_line_id        Number
  ,SHipped_date         Date
  ,Installation_date    Date
  ,Bill_to_site_use_id  Number
  ,Ship_to_site_use_id  Number
  ,Quantity             Number
  ,Unit_of_measure      Varchar2(3)
  ,Inventory_item_id    Number
  ,Customer_acct_id     Number
  ,organization_id      Number
  ,System_id            Number
  ,bom_explosion_flag   Varchar2(1)
  ,return_reason_code   Varchar2(240)
  ,raise_credit         Varchar2(50)
   );


 Type Cp_tbl_type is TABLE of cp_rec_type INDEX BY BINARY_INTEGER;

Type Renewal_rec_type Is Record
(
 Chr_id                 Number
,Renewal_type           Varchar2(10)
,po_required_yn         Varchar2(1)
,Renewal_pricing_type   Varchar2(3)
,Markup_percent         Number
,Price_list_id1         Varchar2(40)
,link_chr_id            Number
,contact_id             Number
,email_id               Number
,phone_id               Number
,fax_id                 Number
,site_id                Number
,cod_type               Varchar2(3)
,billing_profile_id     Number   -- new parameter added -vigandhi
,line_renewal_type      Varchar2(3)

);
l_renewal_rec renewal_rec_type;
-- Procedure to delete a batch
-- This procedure is called by IB when aInstance Mass update batch is deleted.
-- This api deletes the batch rules stored in OKS_BATCH_RULES table for the batch_id.
procedure delete_batch
(
 P_Api_Version           IN             NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2);

-- Procedure to create batch rules. This api is invoked from Instance Mass Update(Form based UI)
-- The transfer options as defined in the profile options,
-- are stored in OKS_BATCH_RULES_TABLE and are applied to contracts when the batch is submitted for processing.
procedure create_batch_rules
(
 P_Api_Version           IN              NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 p_batch_type            IN             VARCHAR2,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2);

 TYPE txn_tbl_type is TABLE of VARCHAR2(3) INDEX BY BINARY_INTEGER;
 TYPE NUM_TBL_TYPE is TABLE of NUMBER INDEX BY BINARY_INTEGER;
 TYPE VAR120_TBL_TYPE is TABLE of VARCHAR2(120) INDEX BY BINARY_INTEGER;
 TYPE VAR150_TBL_TYPE is TABLE of VARCHAR2(150) INDEX BY BINARY_INTEGER;
 TYPE VAR300_TBL_TYPE is TABLE of VARCHAR2(300) INDEX BY BINARY_INTEGER;
 TYPE VAR90_TBL_TYPE is TABLE of VARCHAR2(90) INDEX BY BINARY_INTEGER;
 TYPE DATE_TBL_TYPE is TABLE of DATE INDEX BY BINARY_INTEGER;

 TYPE instance_rec is RECORD
  (      INSTANCE_ID                     NUMBER,
         INSTANCE_NUMBER                 VARCHAR2(30),
         EXTERNAL_REFERENCE              VARCHAR2(30),
         INVENTORY_ITEM_ID               NUMBER,
         VLD_ORGANIZATION_ID             NUMBER,
         INVENTORY_REVISION              VARCHAR2(3),
         SERIAL_NUMBER                   VARCHAR2(30),
         LOT_NUMBER                      VARCHAR2(30),
         QUANTITY                        NUMBER,
         UNIT_OF_MEASURE                 VARCHAR2(3),
         ACTIVE_START_DATE               DATE,
         INSTALL_DATE                    DATE,
         LOCATION_TYPE_CODE              VARCHAR2(30),
         LOCATION_ID                     NUMBER,
         CONTEXT                         VARCHAR2(30),
         ATTRIBUTE1                      VARCHAR2(240),
         ATTRIBUTE2                      VARCHAR2(240),
         ATTRIBUTE3                      VARCHAR2(240),
         ATTRIBUTE4                      VARCHAR2(240),
         ATTRIBUTE5                      VARCHAR2(240),
         ATTRIBUTE6                      VARCHAR2(240),
         ATTRIBUTE7                      VARCHAR2(240),
         ATTRIBUTE8                      VARCHAR2(240),
         ATTRIBUTE9                      VARCHAR2(240),
         ATTRIBUTE10                     VARCHAR2(240),
         ATTRIBUTE11                     VARCHAR2(240),
         ATTRIBUTE12                     VARCHAR2(240),
         ATTRIBUTE13                     VARCHAR2(240),
         ATTRIBUTE14                     VARCHAR2(240),
         ATTRIBUTE15                     VARCHAR2(240),
         INSTALL_LOCATION_TYPE_CODE      VARCHAR2(30),
         INSTALL_LOCATION_ID             NUMBER,
         CALL_CONTRACTS                  VARCHAR2(1),
         Party_Id                        NUMBER,
         ACCOUNT_ID                      NUMBER
  );

 FUNCTION CHECK_SUBSCR_INSTANCE( p_instance_id NUMBER)
 RETURN VARCHAR2 ;

 PROCEDURE POPULATE_CHILD_INSTANCES (p_api_version         IN          Number,
                                    p_init_msg_list       IN          Varchar2 Default OKC_API.G_FALSE,
                                    p_instance_id         IN          NUMBER,
                                    p_transaction_type    IN          VARCHAR2,
                                    x_msg_Count           OUT NOCOPY  Number,
                                    x_msg_Data            OUT NOCOPY  Varchar2,
                                    x_return_status       OUT NOCOPY  Varchar2);

 PROCEDURE CHECK_CONTRACTS_IMPACTED(
    P_Api_Version        IN              NUMBER,
    P_init_msg_list      IN              VARCHAR2 Default OKC_API.G_FALSE,
    P_instance_id        IN              NUMBER,
    p_parent_instance_yn IN              VARCHAR2,
    p_transaction_date   IN              DATE,
    p_new_install_date   IN              DATE,
    P_txn_tbl            IN              txn_tbl_type,
    x_contract_exists_yn OUT NOCOPY      VARCHAR2,
    X_msg_Count          OUT NOCOPY      Number,
    X_msg_Data           OUT NOCOPY      Varchar2,
    x_return_status      OUT NOCOPY      Varchar2);

 PROCEDURE GET_CONTRACTS(p_api_version         IN  Number,
                            p_init_msg_list       IN  Varchar2 Default OKC_API.G_FALSE,
                            p_instance_id         IN  NUMBER,
                            p_validate_yn         IN  VARCHAR2,
                            x_msg_Count           OUT NOCOPY  Number,
                            x_msg_Data            OUT NOCOPY  Varchar2,
                            x_return_status       OUT NOCOPY  Varchar2);

 PROCEDURE CREATE_ITEM_INSTANCE
 (
    p_api_version           IN     NUMBER,
    p_commit                IN     VARCHAR2,
    p_init_msg_list         IN     VARCHAR2,
    p_validation_level      IN     NUMBER,
    p_instance_rec          IN OUT NOCOPY instance_rec,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
 );

-- Procedure to validate batch rules before submitting
-- the batch for processing.
-- In the case where the new owner account is changed
-- either in the Forms Mass Edit batch or OA mass edit
-- batch without visiting contracts page, the api throws
-- an error forcing the user to visit the contracts page
-- and change the options.

procedure Validate_new_owner
(
 P_Api_Version           IN             NUMBER,
 P_init_msg_list         IN             VARCHAR2,
 P_Batch_ID              IN             NUMBER,
 P_new_owner_id          IN             NUMBER,
 x_return_status         OUT NOCOPY     VARCHAR2,
 x_msg_count             OUT NOCOPY     NUMBER,
 x_msg_data	         OUT NOCOPY     VARCHAR2);


  End OKS_IBINT_PUB;

 

/
