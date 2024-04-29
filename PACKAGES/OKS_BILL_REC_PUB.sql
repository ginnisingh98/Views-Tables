--------------------------------------------------------
--  DDL for Package OKS_BILL_REC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILL_REC_PUB" AUTHID CURRENT_USER AS
 /* $Header: OKSPBRCS.pls 120.5 2006/09/19 18:59:16 hvaladip noship $*/
--------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
  G_FND_APP                     CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC  CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED         CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED         CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED    CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE                       CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN          CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN           CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
---------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ---------------------------------------------------------------------------
 G_EXCEPTION_HALT_VALIDATION    EXCEPTION;
 G_EXCEPTION_ROLLBACK EXCEPTION;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT VARCHAR2(200) := 'OKS_BILL_REC';
  G_APP_NAME                    CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_NUM_DAYS_WEEK                       CONSTANT NUMBER := 7;
  G_QUATERLY                  CONSTANT NUMBER := 3;
  G_HALFYEARLY                CONSTANT NUMBER := 6;
  G_YEARLY                    CONSTANT NUMBER := 12;
  G_SERVICE_LINE_STYLE        CONSTANT NUMBER := 1;
  G_COVERAGE_LEVEL_STYLE        CONSTANT NUMBER := 2;
  G_USAGE_LINE_STYLE            CONSTANT NUMBER := 3;
  G_INSTALLED_ITEM_STYLE        CONSTANT NUMBER := 4;
  G_REGULAR                   CONSTANT NUMBER := 1;
  G_NONREGULAR                CONSTANT NUMBER := 2;
  G_STAT_REG_INV_TO_AR        CONSTANT NUMBER := 1;
  G_STAT_TER_CR_INV_TO_AR     CONSTANT NUMBER :=2;
  G_BILLACTION_TR             CONSTANT VARCHAR2(9) := 'TR';
  G_BILLACTION_RI             CONSTANT VARCHAR2(9) := 'RI';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
TYPE Covered_rec IS RECORD(
   id                   NUMBER,
   cle_id               NUMBER,
   start_reading        NUMBER,
   end_reading          NUMBER,
   base_reading         NUMBER,
   ccr_id               NUMBER,
   cgr_id               NUMBER,
   bcl_id               NUMBER,
   date_billed_from     DATE,
   date_billed_to       DATE,
   amount               NUMBER,
   average              NUMBER,
   unit_of_measure      VARCHAR2(30),
   fixed                NUMBER,
   actual               NUMBER,
   default_default      NUMBER,
   amcv_yn              VARCHAR2(3),
   adjustment_level     NUMBER,
   adjustment_minimum   NUMBER,
   result               NUMBER,
   bsl_id_averaged      NUMBER,
   bsd_id               NUMBER,
   bsd_id_applied       NUMBER,
   bcl_amount           NUMBER,
   date_to_interface    DATE,
   flag                 VARCHAR2(20),
   x_stat               VARCHAR2(20),
   sign                 NUMBER,
   estimated_quantity   NUMBER
 );

Type COVERED_TBL is TABLE of Covered_rec index by binary_integer;

Type TERMINATE_REC is RECORD
(
 p_id                           NUMBER,
 p_termination_date             DATE,
 p_termination_amount           NUMBER ,-- user input for termination
 p_con_termination_amount       NUMBER ,-- actual value to be terminated
 --p_existing_credit              NUMBER ,
 p_reason_code                  VARCHAR2(50) ,
 p_flag                         NUMBER ,
 p_termination_flag             NUMBER,
 p_suppress_credit              Varchar2(2) ,
 p_full_credit                  Varchar2(2),
 P_Term_Date_flag               Varchar2(2),
 P_Term_Cancel_source           Varchar2(50)
);

Type TERMINATE_TBL is TABLE of TERMINATE_REC index by binary_integer;

TYPE L_CCR_REC_TYPE IS RECORD
(
 chr_id                     NUMBER,
 cle_id                     NUMBER,
 rule_information1          VARCHAR2(450),
 rule_information2          VARCHAR2(450),
 rule_information3          VARCHAR2(450),
 rule_information4          VARCHAR2(450),
 operation_flag             VARCHAR2(2)
);

l_ccr_rec           l_ccr_rec_type;

Type l_calc_rec_type is Record
(
l_calc_sdate Date,
l_calc_edate Date,
l_bill_stdt  date,
l_bill_eddt  Date,
l_bcl_id     Number,
l_stat       Varchar2(3)
);

l_calc_rec l_calc_rec_type;

 Type line_report_rec_type IS RECORD (
         Dnz_chr_id                    OKC_K_HEADERS_B.ID%Type
        ,Contract_number              OKC_K_HEADERS_B.CONTRACT_NUMBER%Type
        ,Contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%Type
        ,Currency_code                OKC_K_HEADERS_B.CURRENCY_CODE%Type
        ,Organization_id              OKC_K_HEADERS_B.INV_ORGANIZATION_ID%Type
        ,Line_id                      OKC_K_LINES_B.ID%Type
        ,Line_Number                  OKC_K_LINES_B.LINE_NUMBER%Type
        ,Cle_id                       OKC_K_LINES_B.CLE_ID%Type
        ,Lse_Id                       OKC_K_LINES_B.LSE_ID%Type
        ,Sub_line_id                  OKC_K_LINES_B.ID%Type
        ,Sub_Line_Number              OKC_K_LINES_B.LINE_NUMBER%Type
        ,Pty_object1_id1              OKX_PARTIES_V.ID1%Type
        ,Pty_object1_id2              OKX_PARTIES_V.ID2%Type
        ,Bill_Amount                  Number(15,3)
        ,Billed_YN                    Varchar2(1)
        ,Error_Message                Varchar2(2000)
        ,record_type                  Varchar2(10)
        ,Line_Type                    Varchar2(30)
        ,Summary_bill_YN       Varchar2(1)
        ) ;

 Type line_report_tbl_type IS TABLE OF line_report_rec_type INDEX BY BINARY_INTEGER ;

 --Start mchoudha Bug#3537100 17-APR-04
 --For Billing Report

 Type  Bill_report_rec_type IS RECORD (
         Currency_code                 OKC_K_HEADERS_B.CURRENCY_CODE%Type
        ,Successful_Lines             NUMBER
        ,Rejected_Lines               NUMBER
        ,Successful_SubLines          NUMBER
        ,Rejected_SubLines            NUMBER
        ,Successful_Lines_Value       NUMBER
        ,Rejected_Lines_Value         NUMBER
        ,Successful_SubLines_Value    NUMBER
        ,Rejected_SubLines_Value      NUMBER
        ) ;

 Type bill_report_tbl_type IS TABLE OF Bill_report_rec_type INDEX BY BINARY_INTEGER ;

 Type Error_report_rec_type IS RECORD (
         Top_Line_id                  OKC_K_LINES_B.ID%Type
        ,Lse_Id                       OKC_K_LINES_B.LSE_ID%Type
        ,Sub_line_id                  OKC_K_LINES_B.ID%Type
        ,Error_Message                Varchar2(2000)
        ) ;

 Type  billrep_error_tbl_type IS TABLE OF Error_report_rec_type INDEX BY BINARY_INTEGER ;



 --End mchoudha Bug#3537100


Type l_true_val_rec is record (
   p_termination_level varchar2(10),
   p_cp_line_id number ,
   p_top_line_id  number ,
   p_hdr_id number ,
   p_termination_date date ,
   p_terminate_reason varchar2(100) ,
   p_override_amount number ,
   p_con_terminate_amount number ,
   p_termination_amount number ,
   p_suppress_credit varchar2(2) ,
   p_full_credit varchar2(2),
   P_Term_Date_flag               Varchar2(2),
   P_Term_Cancel_source           Varchar2(50));

Type l_true_val_tbl is table of l_true_val_rec index by BINARY_INTEGER ;

Procedure True_Value
 ( p_true_value_tbl IN          L_TRUE_VAL_TBL ,
   x_return_status  OUT  NOCOPY VARCHAR2 ) ;

FUNCTION get_seq_id RETURN NUMBER;

PROCEDURE get_message (
  l_msg_cnt  IN             NUMBER,
  l_msg_data IN OUT NOCOPY  VARCHAR);

/*
PROCEDURE cre_upd_ccr_rule(
  P_CALLEDFROM                   IN         NUMBER DEFAULT NULL,
  p_ccr_rec                      IN         L_CCR_REC_TYPE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  x_rule_id                      OUT NOCOPY NUMBER
);
*/


 PROCEDURE Set_top_line(
   P_PROCESSED_LINES_TBL       IN OUT NOCOPY    LINE_REPORT_TBL_TYPE,
   P_PROCESSED_SUB_LINES_TBL   IN OUT NOCOPY    LINE_REPORT_TBL_TYPE,
   P_ERROR_MESSAGE             IN               VARCHAR2,
   P_TOP_LINE                  IN               NUMBER) ;

 PROCEDURE Set_sub_line(
  P_PROCESSED_LINES_TBL      IN OUT   NOCOPY  LINE_REPORT_TBL_TYPE,
  P_PROCESSED_SUB_LINES_TBL  IN OUT   NOCOPY  LINE_REPORT_TBL_TYPE,
  P_ERROR_MESSAGE            IN               VARCHAR2,
  P_TOP_LINE                 IN               NUMBER) ;


 Procedure Counter_Values
 (
  P_calledfrom       IN          NUMBER DEFAULT NULL,
  P_start_date       IN          DATE,
  P_end_date         IN          DATE,
  P_cle_id           IN          NUMBER,
  P_Usage_type       IN          VARCHAR2,
  X_Value            OUT NOCOPY  NUMBER,
  X_Counter_Value    OUT NOCOPY  NUMBER,
  X_Counter_Date     OUT NOCOPY  DATE,
  X_Uom_Code         OUT NOCOPY  VARCHAR2,
  X_end_reading      OUT NOCOPY  NUMBER,
  X_start_reading    OUT NOCOPY  NUMBER,
  X_base_reading     OUT NOCOPY  NUMBER,
  X_counter_value_id OUT NOCOPY  NUMBER,
  X_counter_group_id OUT NOCOPY  NUMBER,
  X_counter_id       OUT NOCOPY  NUMBER,
  X_return_status    OUT NOCOPY  VARCHAR2
 );



  PROCEDURE pre_terminate
  (P_CALLEDFROM                   IN         NUMBER DEFAULT Null,
   x_return_status                OUT NOCOPY VARCHAR2,
   p_terminate_tbl                IN         TERMINATE_TBL
   );

 PROCEDURE pre_terminate
(P_CALLEDFROM                   IN         NUMBER   DEFAULT Null,
 x_return_status                OUT NOCOPY VARCHAR2,
 p_id                           IN         NUMBER,
 p_termination_date             IN         DATE,
 p_termination_amount           IN         NUMBER   DEFAULT NULL, -- user input for termination
 p_con_termination_amount       IN         NUMBER   DEFAULT NULL,-- actual value to be terminated
 --p_existing_credit              IN         NUMBER   DEFAULT NULL,
 p_reason_code                  IN         VARCHAR2 DEFAULT NULL,
 p_flag                         IN         NUMBER   DEFAULT NULL,
 p_termination_flag             IN         NUMBER   DEFAULT 1,
 p_suppress_credit              IN         VARCHAR2 DEFAULT 'N',
 p_full_credit                  IN         varchar2, --(Y/N -for full credit)
 P_Term_Date_flag              IN          VARCHAR2 DEFAULT 'N',
 P_Term_Cancel_source          IN          VARCHAR2 DEFAULT NULL
 );

 PROCEDURE terminate_subscribtion_line
  (
    P_CALLEDFROM                   IN         NUMBER   DEFAULT NULL,
    p_api_version                  IN         NUMBER,
    p_init_msg_list                IN         VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_line_id                      IN         NUMBER,
    p_termination_date             IN         DATE,
    p_termination_amount           IN         NUMBER   DEFAULT NULL,
    p_con_termination_amount       IN         NUMBER   DEFAULT NULL,
    p_billed_amount                IN         NUMBER,
    p_shipped_amount               IN         NUMBER,
    p_next_ship_date               IN         DATE,
    --p_existing_credit              IN         NUMBER  ,
    p_suppress_credit              IN         VARCHAR2 DEFAULT 'N' ,
    p_tang                         IN         BOOLEAN,
    p_full_credit                  IN         varchar2
  );


 PROCEDURE pre_terminate_service
  (
    P_CALLEDFROM                   IN           NUMBER DEFAULT NULL,
    p_api_version                  IN           NUMBER,
    p_init_msg_list                IN           VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY   VARCHAR2,
    x_msg_count                    OUT NOCOPY   NUMBER,
    x_msg_data                     OUT NOCOPY   VARCHAR2,
    p_k_line_id                    IN           NUMBER,
    p_termination_date             IN           DATE,
    p_termination_amount           IN           NUMBER DEFAULT NULL,
    p_con_termination_amount       IN           NUMBER DEFAULT NULL,
    --p_existing_credit              IN           NUMBER DEFAULT NULL,
    p_termination_flag             IN           NUMBER DEFAULT NULL, -- 1 - regular, 2- simulation
    p_suppress_credit              IN           VARCHAR2 DEFAULT 'N',
    p_full_credit                  IN         varchar2 ,
    x_amount                      OUT  NOCOPY   NUMBER
  );


 procedure get_bill_amount_period (
    P_CALLEDFROM                   IN         NUMBER,
    p_con_start_date               IN         DATE,
    p_con_end_date                 IN         DATE,
    p_bill_calc_period             IN         VARCHAR2,
    p_con_amount                   IN         NUMBER,
    p_bill_start_date              IN         DATE,
    p_bill_end_date                IN         DATE,
    p_stat                         IN         NUMBER,
    x_amount                       OUT NOCOPY NUMBER
  );


/****
  Procedure create_bank_Account(
     p_dnz_chr_id      IN                NUMBER,
     p_bill_start_date IN                DATE,
     p_currency_code   IN                VARCHAR2,
     x_status         OUT        NOCOPY  VARCHAR2,
     l_msg_count       IN OUT    NOCOPY  NUMBER,
     l_msg_data        IN OUT    NOCOPY  VARCHAR2);
****/




PROCEDURE insert_bcl
(
 P_CALLEDFROM          IN                NUMBER,
 X_RETURN_STAT         OUT       NOCOPY  VARCHAR2,
 p_CLE_ID              IN                NUMBER,
 p_DATE_BILLED_FROM    IN                DATE,
 P_DATE_BILLED_TO      IN                DATE,
 P_DATE_NEXT_INVOICE   IN                DATE,
 P_BILL_ACTION         IN                VARCHAR2,
 P_OKL_FLAG            IN                NUMBER,
 P_PRV                 IN                NUMBER,
 P_MSG_COUNT           IN OUT    NOCOPY  NUMBER,
 P_MSG_DATA            IN OUT    NOCOPY  VARCHAR2,
 X_BCL_ID              IN OUT    NOCOPY  NUMBER
 );

PROCEDURE get_bcl_id
(
 P_CALLEDFROM          IN          NUMBER,
 x_return_stat        OUT  NOCOPY  VARCHAR2,
 p_CLE_ID              IN          NUMBER,
 p_DATE_BILLED_FROM    IN          DATE,
 P_DATE_BILLED_TO      IN          DATE,
 P_BILL_ACTION         IN          VARCHAR2,
 x_bcl_id             OUT  NOCOPY  NUMBER,
 x_bcl_amount         OUT  NOCOPY  NUMBER,
 p_prv                 IN          NUMBER
 );

PROCEDURE insert_all_subline
(
 P_CALLEDFROM        IN               NUMBER,
 X_RETURN_STAT       OUT      NOCOPY  VARCHAR2,
 P_COVERED_TBL       IN OUT   NOCOPY  COVERED_TBL,
 P_CURRENCY_CODE     IN               VARCHAR2,
 P_DNZ_CHR_ID        IN               NUMBER,
 P_PRV               IN               NUMBER,
 P_MSG_COUNT         IN OUT   NOCOPY  NUMBER,
 P_MSG_DATA          IN OUT   NOCOPY  VARCHAR2
 );

PROCEDURE update_bsl
(
   x_ret_stat      OUT  NOCOPY  VARCHAR2,
   p_dnz_chr_id     IN          NUMBER,
   p_bsl_id         IN          NUMBER,
   p_bcl_id         IN          NUMBER,
   P_AMOUNT         IN          NUMBER,
   P_CURRENCY_CODE  IN          VARCHAR2,
   P_PRV            IN          NUMBER
   );

PROCEDURE update_bcl
(
   P_CALLEDFROM     IN          NUMBER,
   x_ret_stat      OUT  NOCOPY  VARCHAR2,
   p_bcl_id         IN          NUMBER,
   P_SENT_YN        IN          VARCHAR2,
   P_BILL_ACTION    IN          VARCHAR2,
   P_AMOUNT         IN          NUMBER,
   P_CURRENCY_CODE  IN          VARCHAR2,
   P_PRV            IN          NUMBER
   );


PROCEDURE Get_Bill_profile
(
 p_dnz_chr_id    IN        NUMBER,
 x_bill_profile OUT NOCOPY VARCHAR2
 );


PROCEDURE Adjust_Negotiated_Price
(
        p_calledfrom    IN              NUMBER,
        p_contract_id   IN              NUMBER,
        x_msg_count     OUT     NOCOPY  NUMBER,
        x_msg_data      OUT     NOCOPY  VARCHAR2,
        x_return_status OUT     NOCOPY  VARCHAR2
);

 PROCEDURE pre_terminate_amount
  (
    P_CALLEDFROM                   IN        NUMBER DEFAULT Null,
    p_id                           IN        NUMBER,
    p_terminate_date               IN        DATE,
    p_flag                         IN        NUMBER,
    X_Amount                      OUT NOCOPY NUMBER,
    --X_manual_credit               OUT NOCOPY NUMBER,
    X_return_status               OUT NOCOPY VARCHAR2);


 PROCEDURE get_subscr_terminate_amount
  (
    P_CALLEDFROM                   IN         NUMBER DEFAULT Null,
    p_line_id                      IN         NUMBER,
    p_terminate_date               IN         DATE,
    p_billed_amount                IN         NUMBER,
    p_shipped_amount               IN         NUMBER,
    p_max_bill_date                IN         DATE,
    p_max_ship_date                IN         DATE,
    X_amount                      OUT NOCOPY  NUMBER,
    X_return_status               OUT NOCOPY  VARCHAR2
  );

-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- Added additional period_type,period_start parameter
-------------------------------------------------------------------------
 PROCEDURE get_terminate_amount
  (
    P_CALLEDFROM                   IN          NUMBER DEFAULT Null,
    p_line_id                      IN          NUMBER,
    p_cov_line                     IN          VARCHAR2,
    p_terminate_date               IN          DATE,
    p_period_start                 IN          VARCHAR2 DEFAULT NULL,
    p_period_type                  IN          VARCHAR2 DEFAULT NULL,
    X_amount                      OUT  NOCOPY  NUMBER,
    X_return_status               OUT  NOCOPY  VARCHAR2
  );


 PROCEDURE pre_terminate_cp
  (
    P_CALLEDFROM                  IN            NUMBER DEFAULT Null,
    --p_chr_id                    IN            NUMBER,
    p_cle_id                      IN            NUMBER,
    p_termination_date            IN            DATE,
    p_terminate_reason            IN            VARCHAR2,
    p_override_amount             IN            NUMBER,
    p_con_terminate_amount        IN            NUMBER,
    --p_existing_credit             IN                  NUMBER,
    p_termination_amount          IN            NUMBER,
    p_suppress_credit             IN            VARCHAR2,
    p_full_credit                 IN            VARCHAR2,
    P_Term_Date_flag              IN          VARCHAR2 DEFAULT 'N',
    P_Term_Cancel_source          IN            VARCHAR2 DEFAULT NULL,
    X_return_status               OUT NOCOPY   VARCHAR2
  );

PROCEDURE Terminate_cp
  (
    P_CALLEDFROM                  IN         NUMBER DEFAULT NUll,
    p_top_line_id                 IN         NUMBER,
    p_cp_line_id                  IN         NUMBER,
    p_termination_date            IN         DATE,
    p_terminate_reason            IN         VARCHAR2,
    p_override_amount             IN         NUMBER,
    p_con_terminate_amount        IN         NUMBER,
    --p_existing_credit             IN         NUMBER,
    p_termination_amount          IN         NUMBER,
    p_suppress_credit             IN         VARCHAR2,
    p_full_credit                 IN         VARCHAR2,
    p_term_method                 IN         VARCHAR2,
    p_usage_type                  IN         VARCHAR2,
    p_usage_period                IN         VARCHAR2,
    P_Term_Cancel_source          IN          VARCHAR2,
    X_return_status               OUT NOCOPY VARCHAR2
  );


-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- Added additional period_type parameter
-------------------------------------------------------------------------
PROCEDURE Usage_qty_to_bill
(
  P_calledfrom            IN                NUMBER DEFAULT NULL,
  P_cle_id                IN                NUMBER,
  P_Usage_type            IN                VARCHAR2,
  P_estimation_flag       IN                VARCHAR2,
  P_estimation_method     IN                VARCHAR2,
  p_default_qty           IN                NUMBER,
  P_cov_start_date        IN                DATE,
  P_cov_end_date          IN                DATE,
  P_cov_prd_start_date    IN                DATE,
  P_cov_prd_end_date      IN                DATE,
  p_usage_period          IN                VARCHAR2,
  p_time_uom_code         IN                VARCHAR2,
  p_settle_interval       IN                VARCHAR2,
  p_minimum_quantity      IN                NUMBER,
  p_usg_est_start_date    IN                DATE,
  p_period_type           IN                VARCHAR2, -- period type
  p_period_start          IN                VARCHAR2, -- period start
  X_qty                   OUT        NOCOPY NUMBER,
  X_Uom_Code              OUT        NOCOPY VARCHAR2,
  X_flag                  OUT        NOCOPY VARCHAR2,
  X_end_reading           OUT        NOCOPY NUMBER,
  X_start_reading         OUT        NOCOPY NUMBER,
  X_base_reading          OUT        NOCOPY NUMBER,
  X_estimated_qty         OUT        NOCOPY NUMBER,
  X_actual_qty            OUT        NOCOPY NUMBER,
  X_counter_value_id      OUT        NOCOPY NUMBER,
  X_counter_group_id      OUT        NOCOPY NUMBER,
  X_return_status         OUT        NOCOPY VARCHAR2
);


-------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 11-JUN-2005
-- Added period start and period type parameters
-------------------------------------------------------------------------
PROCEDURE  Create_trx_records(
              p_called_from           IN             NUMBER   DEFAULT Null ,
              p_top_line_id           IN             NUMBER,
              p_cov_line_id           IN             NUMBER,
              p_date_from             IN             DATE,
              p_date_to               IN             DATE,
              p_amount                IN             NUMBER,
              p_override_amount       IN             NUMBER,
              p_suppress_credit       IN             VARCHAR2,
              p_con_terminate_amount  IN             NUMBER,
              --p_existing_credit       IN             NUMBER,
              p_bill_action           IN             VARCHAR2,
              p_period_start          IN             VARCHAR2 DEFAULT NULL,
              p_period_type           IN             VARCHAR2 DEFAULT NULL,
              x_return_status         OUT NOCOPY     VARCHAR2
              );

Procedure get_termination_details ( p_level IN VARCHAR2 ,
                                    p_id IN NUMBER ,
                                    x_unbilled OUT NOCOPY NUMBER ,
                                    x_credited OUT NOCOPY NUMBER ,
                                    x_suppressed OUT NOCOPY NUMBER ,
                                    x_overridden OUT NOCOPY NUMBER ,
                                    x_billed OUT NOCOPY NUMBER ,
                                    x_return_status OUT NOCOPY VARCHAR2 );

Procedure prorate_price_breaks (P_BSL_ID        IN         NUMBER,
                                  P_BREAK_AMOUNT  IN         NUMBER,
                                  P_TOT_AMOUNT    IN         NUMBER,
                                  X_RETURN_STATUS OUT NOCOPY VARCHAR2 ) ;


------------------------------------------------------------------------
-- Begin partial period computation logic
-- Developer Mani Choudhary
-- Date 27-MAY-2005
-- DESCRIPTION:
-- This function will be called for Usage Line Types of Fixed and to
-- compute Minimum and Default for Actual per Period and Actual by Quantity.
---------------------------------------------------------------------------
Function Get_Prorated_Usage_Qty
                       (
                       p_start_date  IN DATE,
                       p_end_date    IN DATE,
                       p_qty         IN NUMBER,
                       p_usage_uom   IN VARCHAR2,
                       p_billing_uom IN VARCHAR2,
                       p_period_type IN VARCHAR2
                       )
RETURN NUMBER;

END OKS_BILL_REC_PUB;


 

/
