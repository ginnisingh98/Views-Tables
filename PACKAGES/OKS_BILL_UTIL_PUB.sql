--------------------------------------------------------
--  DDL for Package OKS_BILL_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_BILL_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: OKSBUTLS.pls 120.3 2006/09/19 21:39:02 abkumar noship $ */


  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';

  ------------------------------------------------------------------------------------

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
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_BILL_UTIL_PUB';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  'OKS';
  ---------------------------------------------------------------------------



/***bill rec type for usage billing***/

l_line_rec              OKS_QP_PKG.Input_details ;
l_price_rec             OKS_QP_PKG.Price_Details ;
l_modifier_details      qp_preq_grp.line_detail_tbl_type;
l_price_break_details   oks_qp_pkg.g_price_break_tbl_type;



TYPE Bill_Rec_Type IS RECORD (
    Counter_id            NUMBER,
    Reading_date          DATE,
    Meter_reading         NUMBER,
    Last_Meter_reading    NUMBER,
    Net_reading           NUMBER,
    Level_reading        NUMBER,
    Bill_amount           NUMBER);

Type Bill_tbl_type is TABLE of Bill_Rec_Type index by binary_integer;


Type sll_prorated_rec_type IS RECORD
( sll_seq_num		Number,
  sll_start_date	DATE,
  sll_end_date		DATE,
  sll_tuom		VARCHAR2(40),
  sll_amount		Number
);

Type bill_det_inp_rec IS RECORD
(line_start_date   	DATE,
 line_end_date     	DATE,
 cycle_start_date  	DATE,
 tuom_per_period 	Number,
 tuom    		Varchar2(3),
 total_amount 	  	Number,
 invoice_offset_days	Number,
 interface_offset_days 	Number,
 bill_type              VARCHAR2(1),             ----values may be E,T,P
 uom_per_period 	Number  --mchoudha added this parameter
);

Type bill_sch_rec IS RECORD
(
 next_cycle_date   	  DATE,
 cycle_amount   	  Number,
 date_transaction   	  DATE,
 date_revenue_rule_start  DATE,
 date_recievable_gl  	  DATE,
 date_due   		  DATE,
 date_print    		  DATE,
 date_to_interface  	  DATE,
 date_completed   	  DATE
);

Type next_level_element_type IS RECORD
(
 id		 	 NUMBER,
 sequence_number 	 NUMBER,
 bill_from_date 	 DATE,
 bill_to_date  		 DATE,
 bill_amount   		 Number,
 date_to_interface  	 DATE,
 date_receivable_gl 	 DATE,
 date_revenue_rule_start DATE,
 date_transaction 	 DATE,
 date_due		 DATE,
 date_print		 DATE,
 date_completed		 DATE,
 rule_id		 NUMBER
);

Type level_element_tab is Table of next_level_element_type index by
binary_integer;

Type sll_prorated_tab_type is Table of sll_prorated_rec_type index by binary_integer;

PROCEDURE get_seeded_timeunit (  p_timeunit in varchar2,
			         x_return_status out NOCOPY varchar2,
			         x_quantity out NOCOPY number,
				 x_timeunit out NOCOPY varchar2) ;

PROCEDURE Get_sll_amount ( p_api_version    IN 		NUMBER,
	 		   p_total_amount   IN 		NUMBER,
			   p_init_msg_list  IN   	VARCHAR2 DEFAULT OKC_API.G_FALSE,
			   x_return_status  OUT  	NOCOPY VARCHAR2,
			   x_msg_count	    OUT  	NOCOPY NUMBER,
			   x_msg_data	    OUT  	NOCOPY VARCHAR2,
                           p_currency_code  IN 		VARCHAR2,
		           p_sll_prorated_tab IN OUT     NOCOPY sll_prorated_tab_type );


PROCEDURE pre_del_level_elements(
    p_api_version       IN NUMBER,
    p_terminated_date   IN  DATE,
    p_id                IN NUMBER ,
    p_flag              IN NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2
);


PROCEDURE delete_level_elements(
    p_api_version       IN NUMBER,
    p_terminated_date   IN  DATE,
    p_chr_id            IN NUMBER,
    p_cle_id            IN NUMBER ,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
);


Procedure Get_prorate_amount
 ( p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_invoicing_rule_id	          IN  Number,
   p_bill_sch_detail_rec          IN  bill_det_inp_rec,
   x_bill_sch_detail_rec          OUT NOCOPY bill_sch_rec
 );


 -------------------------------------------------------------------------
 -- Begin partial period computation logic
 -- Developer Mani Choudhary
 -- Date 09-MAY-2005
 -- 1) Added two new parameters P_period_start,P_period_type in procedure
 --    Get_next_bill_sch
 -- 2) Added function get_enddate_cal
 -- 3) Added function get_periods
 -------------------------------------------------------------------------
 Procedure Get_next_bill_sch
 ( p_api_version                  IN NUMBER,
   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   p_invoicing_rule_id		    IN  Number,
   p_bill_sch_detail_rec          IN  bill_det_inp_rec,
   x_bill_sch_detail_rec          OUT NOCOPY bill_sch_rec,
   P_period_start                 IN VARCHAR2,
   P_period_type                  IN VARCHAR2,
-- Start - Added by PMALLARA - Bug #3992530
   Strm_Start_Date		  IN DATE
-- End - Added by PMALLARA - Bug #3992530
 );

 --This new function will determine the end date of the
 --SLL in case of "Calendar month" period start.
 FUNCTION get_enddate_cal(p_start_date    IN DATE,
                         p_uom_code      IN VARCHAR2,
                         p_duration      IN NUMBER,
                         p_level_periods IN NUMBER
                         )
 RETURN DATE;

 --This new function will determine numbr of periods of SLL given
 --the start date, end date,uom_per_period and uom of the SLL.
 FUNCTION get_periods    (p_start_date    IN DATE,
                         p_end_date      IN DATE,
                         p_uom_code      IN VARCHAR2,
                         p_period_start  IN VARCHAR2
                         )
 RETURN NUMBER;

 -------------------------------------------------------------------------
 -- End partial period computation logic
 -- Date 09-MAY-2005
 -------------------------------------------------------------------------

/*** Takes input cp_id and p_Date, returns level_element table ****/
Procedure Get_next_level_element
(  p_api_version                  IN NUMBER,
   p_id     		   	  IN NUMBER,
   p_covd_flag                    IN Varchar2,
   p_date        		  IN DATE,
   p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2,
   x_next_level_element      OUT NOCOPY level_element_tab
);

/** Function will return total invoices billed, for given rule id ****/

Function Get_total_inv_billed (p_api_version	 IN  Varchar2,
				 p_rule_id 		 IN  Number,
				 p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
				 x_return_status   OUT NOCOPY VARCHAR2,
				 x_msg_count       OUT NOCOPY NUMBER,
			       x_msg_data        OUT NOCOPY VARCHAR2)
return Number;


/** Procedure to delete rows from Oks_level_elements, for a given rule_id  **/

Procedure Delete_level_elements( p_api_version   IN  NUMBER,
					   p_rule_id 	 IN Number,
					   p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	  			         x_msg_count     OUT NOCOPY NUMBER,
					   x_msg_data      OUT NOCOPY VARCHAR2,
			 		   x_return_status OUT NOCOPY Varchar2 );

PROCEDURE delete_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_chr_id                       IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);

PROCEDURE delete_slh_rule(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_cle_id                       IN NUMBER,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2);


/*Procedure Create_covlv_billsch
(
 p_cp_id  NUMBER DEFAULT NULL,
 p_cle_id NUMBER,
 p_hdr_id NUMBER,
 p_srv_id NUMBER,
 p_organization_id NUMBER,
 x_return_status out NOCOPY VARCHAR2,
 x_msg_data out NOCOPY VARCHAR2,
 x_msg_count out NOCOPY NUMBER
);*/

/** Procedure for copying/splitting service lines **/
TYPE copy_source_rec is RECORD
    (cle_id  NUMBER,
     item_id VARCHAR2(40),
     amount  NUMBER);
TYPE copy_target_rec is RECORD
    (cle_id  NUMBER,
     item_id VARCHAR2(40),
     amount  NUMBER,
     percentage NUMBER);
TYPE copy_target_tbl is table of copy_target_rec INDEX BY BINARY_INTEGER;
PROCEDURE copy_service( p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2,
                        p_source_rec    IN  copy_source_rec,
                        p_target_tbl    IN OUT NOCOPY copy_target_tbl,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2
                      );

/**Procedure for usage billing*/


Procedure Calculate_Bill_Amount (
    p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_bill_tbl           IN OUT  NOCOPY Bill_tbl_type,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2);


Function Get_Credit_Amount (p_api_version	 IN  Varchar2,
			    p_cp_line_id 	 IN  Number,
			    p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
			    x_return_status      OUT NOCOPY VARCHAR2,
			    x_msg_count          OUT NOCOPY NUMBER,
			    x_msg_data           OUT NOCOPY VARCHAR2)
RETURN NUMBER;

Function Get_frequency
(p_tce_code  IN VARCHAR2,
 p_fr_start_date  IN DATE,
 p_fr_end_date    IN DATE,
 p_uom_quantity   IN Number,
 x_return_status  OUT NOCOPY VARCHAR2
)  Return NUMBER ;


/* Procedure to create billing report */

Procedure Create_Report (
                        p_billrep_table      IN  OKS_BILL_REC_PUB.bill_report_tbl_type
		       ,p_billrep_err_tbl    IN OKS_BILL_REC_PUB.billrep_error_tbl_type
               	       ,p_line_from          IN NUMBER
                       ,p_line_to            IN NUMBER
                       ,x_return_status      OUT NOCOPY Varchar2
                       )  ;


/* Procedure to update the OKS_LEVEL_ELEMENST */
  PROCEDURE UPDATE_OKS_LEVEL_ELEMENTS
    ( p_line_id IN number ,
      x_return_status OUT NOCOPY varchar2 ) ;



--This is to insert BCL for contracts orginated from Order management.
PROCEDURE  CREATE_BCL_FOR_OM ( P_LINE_ID  IN  NUMBER ,
                               X_RETURN_STATUS  OUT NOCOPY VARCHAR2 );

--This is to insert BSL for contracts orginated from Order management.
PROCEDURE CREATE_BSL_FOR_OM ( P_LINE_ID  IN NUMBER ,
                              P_BCL_ID   IN NUMBER ,
                              X_RETURN_STATUS OUT NOCOPY VARCHAR2 ,
                              X_SUB_LINES_INSERTED OUT NOCOPY NUMBER ,
                              X_TOTAL_AMOUNT  OUT NOCOPY NUMBER ) ;


---This will give the billed qty for subcription line

Function Get_Billed_Qty (p_line_id 		 IN  Number,
         		 x_return_status   OUT NOCOPY VARCHAR2) return Number;

Function Get_Billed_Upto ( p_id     IN Number,
                           p_level  IN Varchar2 -- 'H'eader, 'T'opline, 'S'ubline
                         ) Return Date;

FUNCTION Is_Sc_Allowed (p_org_id IN Number) RETURN BOOLEAN;

Function IS_Contract_billed (p_header_id 	   IN  Number,
         		     x_return_status   OUT NOCOPY VARCHAR2) return Boolean;


PROCEDURE ADJUST_SPLIT_BILL_REC(p_old_cp_id        IN  NUMBER,
                                p_new_cp_id        IN  NUMBER,
                                p_rgp_id           IN  NUMBER,
                                p_currency_code    IN  VARCHAR2,
                                p_old_cp_lvl_tbl   IN  oks_bill_level_elements_pvt.letv_tbl_type,
                                p_new_cp_lvl_tbl   IN  oks_bill_level_elements_pvt.letv_tbl_type,
                                x_return_status    OUT   NOCOPY VARCHAR2,
                                x_msg_count	   OUT   NOCOPY NUMBER,
	                          x_msg_data	   OUT   NOCOPY VARCHAR2);

Procedure Adjust_line_price(p_top_line_id      IN  NUMBER,
                            p_sub_line_id      IN  NUMBER,
                            p_end_date         IN  DATE,
                            p_amount           IN  NUMBER,
                            p_dnz_chr_id       IN  NUMBER,
                            x_amount           OUT NOCOPY NUMBER,
                            x_return_status    OUT NOCOPY VARCHAR2);

End oks_bill_util_pub;


 

/
