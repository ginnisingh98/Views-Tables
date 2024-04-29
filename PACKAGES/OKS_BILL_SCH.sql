--------------------------------------------------------
--  DDL for Package OKS_BILL_SCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILL_SCH" AUTHID CURRENT_USER AS
/* $Header: OKSBLSHS.pls 120.2 2005/09/18 22:09:34 mchoudha noship $ */

  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_BILL_SCH';
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------


  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------------------------
  G_TRUE                       CONSTANT VARCHAR2(1)   :=  OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		       CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'SQLcode';
  G_REQUIRED_VALUE      CONSTANT VARCHAR2(30):=OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN      CONSTANT VARCHAR2(30):=OKC_API.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------------------------
  -- Constants used for Message Logging
  G_LEVEL_UNEXPECTED CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  G_LEVEL_CURRENT    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_MODULE_CURRENT   CONSTANT VARCHAR2(255) := 'oks.plsql.oks_bill_sch';
  --------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;


TYPE Line_Type IS RECORD
(   start_dt        Date,
    end_dt          Date,
    amount          Number,
    currency_code   varchar2(15)
);

/* added for bug#3307323*/

TYPE StreamHdr_Type Is Record
(
     Chr_Id                     Number,
     Cle_Id                     Number,
     Rule_Information1          Varchar2 (450),
     Rule_Information2          Varchar2 (450),
     Rule_Information3          Varchar2 (450),
     Rule_Information4          Varchar2 (450),
     Rule_Information5          Varchar2 (450),
     Rule_Information6          Varchar2 (450),
     Rule_Information7          Varchar2 (450),
     Rule_Information8          Varchar2 (450),
     Rule_Information9          Varchar2 (450),
     Rule_Information10         Varchar2 (450),
     Rule_Information11         Varchar2 (450),
     Rule_Information12         Varchar2 (450),
     Rule_Information13         Varchar2 (450),
     Rule_Information14         Varchar2 (450),
     Rule_Information15         Varchar2 (450),
     Rule_Information_Category  Varchar2 (90),
     Object1_Id1                Varchar2 (40),
     Object1_Id2                Varchar2 (200),
     Object2_Id1                Varchar2 (40),
     Object2_Id2                Varchar2 (200),
     Object3_Id1                Varchar2 (40),
     Object3_Id2                Varchar2 (200),
     Jtot_Object1_Code          Varchar2 (30),
     Jtot_Object2_Code          Varchar2 (30),
     Jtot_Object3_Code          Varchar2 (30)
);


TYPE Subline_id_Type Is Record
(
    id          number);

Type Subline_id_tbl is TABLE of Subline_id_type index by binary_integer;


TYPE StreamLvl_Type Is Record
(
    id                  	   number,
    CHR_ID	                   Number,
    CLE_ID	                   Number,
    DNZ_CHR_ID	                   Number,
    Sequence_no	        	   Number,
    uom_code	                   Varchar2 (3),
    start_date	                   Date,
    end_date                       date,
    level_periods	           Number,
    uom_per_period	           Number,
    advance_periods	           Number,
    level_amount	           Number,
    invoice_offset_days	           Number,
    interface_offset_days	   Number,
    comments	                   Varchar2 (240),
    due_ARR_YN	                   Varchar2 (1),
    AMOUNT	                   Number,
    LINES_DETAILED_YN	           Varchar2 (1),
    Rule_Information1              Varchar2 (450),
    Rule_Information2              Varchar2 (450),
    Rule_Information3              Varchar2 (450),
    Rule_Information4              Varchar2 (450),
    Rule_Information_Category      Varchar2 (90),
    Object1_Id1                    Varchar2 (40)
);

Type StreamLvl_tbl is TABLE of StreamLvl_type index by binary_integer;





TYPE ItemBillSch_Type Is Record
(
     Chr_Id                     Number,
     Cle_Id                     Number,
     Strm_Lvl_Seq_Num           NUMBER,
     Lvl_Element_Seq_Num        Varchar2 (240),
     Tx_Date                    Date,
     Bill_From_Date             Date,
     Bill_To_Date               Date,
     Interface_Date             Date,
     Date_Completed             Date,
     Amount                     Number,
     Rule_Id                    Number
);

Type ItemBillSch_tbl is TABLE of ItemBillSch_Type index by binary_integer;


/* overloaded procedure just for OKL bug# 3307323*/
Procedure Create_Bill_Sch_Rules
(
      p_slh_rec		     IN	   StreamHdr_Type
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl	     OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
);



Procedure Create_Bill_Sch_Rules
(
      p_billing_type         IN    Varchar2
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl	     OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
);

Procedure Create_Header_Bill_Sch
(
      p_billing_type         IN    Varchar2
,     p_sll_tbl              IN    StreamLvl_tbl
,     p_invoice_rule_id      IN    Number
,     x_bil_sch_out_tbl	     OUT   NOCOPY ItemBillSch_tbl
,     x_return_status        OUT   NOCOPY Varchar2
);

PROCEDURE Copy_Bill_Sch
(
           p_chr_id         IN    Number,
           p_cle_id         IN    Number,
           x_copy_bill_sch  OUT   NOCOPY ItemBillSch_tbl,
           x_return_status  OUT   NOCOPY Varchar2
);

Procedure Update_Sll_Amount
(
          p_line_id         IN    NUMBER,
          x_return_status   OUT   NOCOPY Varchar2
);

Procedure Cal_hdr_Sll_Amount
(
          p_hdr_id              IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2
);


---top line id is passed.
Procedure Cascade_Dates_SLL
(
          p_top_line_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);


Procedure Create_Bill_Sch_CP
(
          p_top_line_id         IN    NUMBER,
          p_cp_line_id          IN    NUMBER,
          p_cp_new              IN    Varchar2,   ---('Y'if cp new else 'N')
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);

Function Cal_Sllid_amount
(
          p_Sll_id              IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count           OUT   NOCOPY NUMBER,
	  x_msg_data            OUT   NOCOPY VARCHAR2
)RETURN NUMBER;


---only be called for OM contracts (one time billing) to update SLL dates of existing SLL
--and creating level elements.

Procedure Update_OM_SLL_Date
(
          p_top_line_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);


---delete all sll,lvlelements of top and sublines

PROCEDURE Del_rul_elements(p_top_line_id            IN  NUMBER,
                             x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count	    OUT NOCOPY  NUMBER,
	                     x_msg_data	            OUT NOCOPY VARCHAR2);




---delete  sll of subline and refresh the lvl amt of top line for 'Top Level' billing
PROCEDURE Del_subline_lvl_rule(p_top_line_id        IN  NUMBER,
                               p_sub_line_id        IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_msg_count	    OUT NOCOPY NUMBER,
	                       x_msg_data	    OUT NOCOPY VARCHAR2);


PROCEDURE update_bs_interface_date(p_top_line_id         IN    NUMBER,
                                   p_invoice_rule_id     IN    Number,
                                   x_return_status       OUT   NOCOPY VARCHAR2,
                                   x_msg_count	         OUT   NOCOPY NUMBER,
	                           x_msg_data	         OUT   NOCOPY VARCHAR2);
---contract id passed
Procedure Cascade_Dt_lines_SLL
(
          p_contract_id         IN    NUMBER,
          p_line_id             IN    NUMBER,
          x_return_status       OUT   NOCOPY Varchar2);

Procedure Create_Subcription_bs
(
          p_top_line_id         IN    NUMBER,
          p_full_credit         IN    VARCHAR2,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);

Procedure Terminate_bill_sch(
          p_top_line_id         IN    NUMBER,
          p_sub_line_id         IN    NUMBER,
          p_term_dt             IN    DATE,
          x_return_status       OUT   NOCOPY Varchar2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);


----the procedure will create level elements only
---for the contract,it will be called from copy and renewal.

Procedure Create_hdr_schedule
(
          p_contract_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY VARCHAR2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);

----the procedure will delete all the sll and level elements for the whole contract
---(i.e header,line,subline)

Procedure Delete_contract_bs_sll
(
          p_contract_id         IN    NUMBER,
          x_return_status       OUT   NOCOPY VARCHAR2,
          x_msg_count	        OUT   NOCOPY NUMBER,
	  x_msg_data	        OUT   NOCOPY VARCHAR2);



----the procedure will update end date of sll and level elements for migrated contracts.

Procedure UPDATE_BS_ENDDATE(p_line_id         IN   NUMBER,
                            p_chr_id          IN   NUMBER,
                            x_return_status   OUT NOCOPY VARCHAR2);


Procedure Preview_Subscription_Bs(p_sll_tbl              IN    StreamLvl_tbl,
                                  p_invoice_rule_id      IN    Number,
                                  p_line_detail          IN    LINE_TYPE,
                                  x_bil_sch_out_tbl	 OUT   NOCOPY ItemBillSch_tbl,
                                  x_return_status        OUT   NOCOPY Varchar2);


PROCEDURE ADJUST_REPLACE_PRODUCT_BS(p_old_cp_id      IN    NUMBER,
                                    p_new_cp_id      IN    NUMBER,
                                    x_return_status  OUT   NOCOPY VARCHAR2,
                                    x_msg_count	     OUT   NOCOPY NUMBER,
	                            x_msg_data	     OUT   NOCOPY VARCHAR2);


Procedure ADJUST_SPLIT_BILL_SCH(p_old_cp_id      IN    NUMBER,
                                p_new_cp_tbl     IN    OKS_BILL_SCH.SUBLINE_ID_TBL,
                                x_return_status  OUT   NOCOPY VARCHAR2,
                                x_msg_count	 OUT   NOCOPY NUMBER,
	                        x_msg_data	 OUT   NOCOPY VARCHAR2);


--[llc] Sts_change_subline_lvl_rule

/* This procedure updates the amount on the top line when the status of sub-line is
   changed from 'Entered' to 'Cancelled' or 'Cancelled' to 'Entered'.
*/


PROCEDURE Sts_change_subline_lvl_rule(
			       p_cle_id            IN  NUMBER,
                               p_from_ste_code          IN VARCHAR2,
                               p_to_ste_code           IN VARCHAR2,
                               x_return_status          OUT NOCOPY VARCHAR2,
                               x_msg_count              OUT NOCOPY NUMBER,
                               x_msg_data               OUT NOCOPY VARCHAR2);


--ppc R12
FUNCTION Get_Converted_price (
                              p_price_uom        IN VARCHAR2,
                              p_pl_uom           IN VARCHAR2,
                              p_period_start     IN VARCHAR2,
                              p_period_type      IN VARCHAR2,
                              p_price_negotiated IN NUMBER,
                              p_unit_price       IN NUMBER,
                              p_start_date       IN DATE,
                              p_end_date         IN DATE

)RETURN NUMBER;



END OKS_BILL_SCH;

 

/
