--------------------------------------------------------
--  DDL for Package OKS_IB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_IB_UTIL_PVT" AUTHID CURRENT_USER As
/* $Header: OKSRIBUS.pls 120.17.12000000.1 2007/01/16 22:10:55 appldev ship $ */

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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_IB_UTIL_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   := 'OKS';
  G_FND_LOG_OPTION              CONSTANT VARCHAR2(30)  := NVL(Fnd_Profile.Value('OKS_DEBUG'),'N');
  ---------------------------------------------------------------------------
   g_num_days_week           CONSTANT NUMBER         := 7;
   g_quaterly                CONSTANT NUMBER         := 3;
   g_halfyearly              CONSTANT NUMBER         := 6;
   g_yearly                  CONSTANT NUMBER         := 12;
   g_service_line_style      CONSTANT NUMBER         := 1;
   g_coverage_level_style    CONSTANT NUMBER         := 2;
   g_usage_line_style        CONSTANT NUMBER         := 3;
   g_installed_item_style    CONSTANT NUMBER         := 4;
   g_regular                 CONSTANT NUMBER         := 1;
   g_nonregular              CONSTANT NUMBER         := 2;
   g_stat_reg_inv_to_ar      CONSTANT NUMBER         := 1;
   g_stat_ter_cr_inv_to_ar   CONSTANT NUMBER         := 2;
   g_billaction_tr           CONSTANT VARCHAR2 (9)   := 'TR';
   g_billaction_ri           CONSTANT VARCHAR2 (9)   := 'RI';
   v_billsch_type            CONSTANT VARCHAR2( 10 )  := 'T';



  -- Billing rec
  TYPE billing_rec_type IS RECORD (
    start_date                      DATE
   ,end_date                        DATE
   ,inv_rule_id                     NUMBER
   ,schedule_type                   VARCHAR2(1)
   ,billing_type                    VARCHAR2(10)
   ,freq_period                     VARCHAR2(10)
   ,invoice_offset                  NUMBER
   ,interface_offset                NUMBER
   ,amount                           NUMBER
   ,currency_code                   VARCHAR2(10));


   FUNCTION check_partial_flag (p_id IN NUMBER, p_flag IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION get_terminate_amount (
      p_line_id          IN   NUMBER,
      p_termination_date   IN   DATE

   )
      RETURN NUMBER;

   FUNCTION get_billed_amount (
            p_line_id      IN   NUMBER
   )
      RETURN NUMBER;

FUNCTION get_transferred_amount (
   p_line_id         IN   NUMBER,
   p_transfer_date   IN   DATE
) return Number;

Procedure CheckMultipleOU(P_Batch_ID Number, p_new_account_id Number, x_party_id Out NOCOPY Number, x_org_id Out NOCOPY Number);

FUNCTION checkaccount (p_batch_id NUMBER, p_new_account_id NUMBER)
      RETURN Varchar2;
Procedure Get_prod_name(P_line_id  Number, x_prod_name Out NoCopy Varchar2, X_system_name Out NoCopy Varchar2) ;


Procedure GetBillToShipTo(P_New_account_id Number,
P_BillTo_account_Id Number default Null,
P_BillTo_Address_Id Number default Null,
P_ShipTo_account_Id Number default Null,
P_ShipTo_Address_Id Number default Null,
P_Operating_unit Number default Null,
X_BillTo_account_Number Out NOCOPY VARCHAR2,
X_BillTo_account_Id Out NOCOPY  Number,
X_BillTo_Party Out NOCOPY Varchar2,
X_BillTo_PartyId Out NOCOPY  Number,
X_BillTo_Address_Id Out NOCOPY Number,
X_BillTo_Address Out NOCOPY Varchar2,
X_ShipTo_account_Number Out NOCOPY VARCHAR2,
X_ShipTo_account_Id Out NOCOPY Number,
X_ShipTo_Party Out NOCOPY Varchar2,
X_ShipTo_PartyId Out NOCOPY Number,
X_ShipTo_Address_Id Out NOCOPY Number,
X_ShipTo_Address Out NOCOPY Varchar2,
X_Contract_status_Code Out NOCOPY Varchar2,
X_Contract_status Out NOCOPY Varchar2,
X_Party_ID OUT NOCOPY Number,
X_Credit_option OUT NOCOPY Varchar2,
P_Transaction_date Date default sysdate


) ;

PROCEDURE populate_globaltemp (
      p_batch_id           NUMBER,
      p_batch_type         VARCHAR2,
      p_transaction_date   Date default sysdate,
      P_new_account_id Number Default null
   );
Function Coverage_term_full_amount
(P_line_id Number
,P_transfer_option Varchar2
, p_new_account_id Number
, p_transfer_date Date
, p_instance_id Number
, p_line_end_date  Date
) return varchar2;

Function Coverage_transfer_amount
(P_line_id  Number,
  P_transfer_option Varchar2
, p_new_account_id Number
, p_transfer_date Date
, p_instance_id Number) return number ;
--Pragma Restrict_References (Coverage_transfer_amount, WNDS);

Function Get_actual_creditamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number ;
Function Get_actual_transferamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number ;

Function Get_actual_billedamount(p_line_id Number, P_batch_id Number, P_line_type Varchar2) return Number ;


Function Coverage_terminate_amount
(P_line_id  Number,
  P_transfer_option Varchar2
, p_new_account_id Number
, p_transfer_date Date
, p_instance_id Number) return number ;

FUNCTION get_invoice_text (
      p_product_item   IN   NUMBER,
      p_start_date     IN   DATE,
      p_end_date       IN   DATE
   )RETURN VARCHAR2 ;

Function get_full_terminate_amount
(P_line_id IN Number,
 P_transaction_date IN Date
, p_line_end_date  Date

) return Number;


Procedure Check_termcancel_lines
     (
        p_line_id Number      -- TOp line id or Header Id
      , p_line_type Varchar2  -- 'TL' or 'SL'
      , P_txn_type Varchar2   --'T' for termination, 'C' for cancel
      , X_date     OUT NOCOPY Date
      )  ;

      Function get_BillContact_name(P_Contract_Id Number) return Varchar2;
      Function get_salesrep_name(P_Contract_Id Number) return Varchar2;
Function Credit_option return Varchar2;




   FUNCTION party_contact_info(
    p_object1_code  IN VARCHAR2,
    p_object1_id1     IN VARCHAR2,
    p_object1_id2     IN VARCHAR2,
    p_org_id     IN NUMBER,
    p_info_req   IN VARCHAR2 --possible values are 'NAME ,PHONE, EMAIL'
  )
  RETURN VARCHAR2;


   FUNCTION get_credit_option (
      p_Party_id               IN             NUMBER,
      p_org_id                IN             NUMBER ,
      P_transaction_date      IN             Date
   )
      RETURN VARCHAR2;

   FUNCTION get_credit_amount_trm (
     p_line_id                    IN       NUMBER,
     p_termination_date           IN       DATE DEFAULT NULL )
   RETURN NUMBER ;


   Function get_credit_amount_trf(
     P_line_id                     IN       Number,
     p_new_account_id              IN       Number,
     p_transfer_date               IN       Date)
   RETURN NUMBER;


 Function Check_renewed_Sublines
     (
        p_line_id Number

      ) return Date;


 Function Check_renewed_lines
     (
        p_line_id Number

      ) return Date;


     Function Check_Termination_date
     (
        p_line_id Number      -- TOp line id or Header Id
      , P_Line_type Varchar2   --'T' for TopLine, 'H' for Header
     )  Return Date ;


Function Get_date_terminated
        ( P_sts_code  varchar2,
          P_Transaction_date  Date,
          P_Start_date  Date,
          P_End_date  Date)
Return Date ;
Procedure get_srv_name(P_line_id  Number, x_service_name Out NoCopy  Varchar2, x_service_description Out NoCopy varchar2);
Function Get_address(P_site_use_id Number) return varchar2 ;

FUNCTION get_covlvl_name
(
p_jtot_code     VARCHAR2,
p_object1_id1  VARCHAR2,
p_object1_id2   VARCHAR2
)
RETURN VARCHAR2;

  End OKS_IB_UTIL_PVT;




 

/
