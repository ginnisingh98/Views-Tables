--------------------------------------------------------
--  DDL for Package IEX_AGING_BUCKETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_AGING_BUCKETS_PKG" AUTHID CURRENT_USER AS
/* $Header: iexpagbs.pls 120.2 2004/12/06 15:38:13 jypark ship $ */
	TYPE Aging_Summary_Rec is RECORD(
        aging_bucket_id         Number(15),
        aging_bucket_name       varchar2(20),
        aging_bucket_line_id    Number  ,
        bucket_sequence_num     Number  ,
	  Bucket_line_desc	  Varchar2(35),
	  Amount		 	  Number	,
        collectible_amount      Number  ,
	  Currency			  Varchar2(25),
	  Invoice_Count  		  Number	,
        Invoice_amount          Number,
        DM_COUNT                Number,
        dm_AMOUNT               Number,
        cb_count                Number,
        cb_amount               Number,
	  Disputed_Transactions	  Number,
        Disputed_amount         Number   ) ;

	TYPE Aging_Summary_Select_Rec is RECORD(
        aging_bucket_id         Number(15),
        aging_bucket_name       varchar2(20),
        aging_bucket_line_id    Number  ,
        bucket_sequence_num     Number  ,
	  Bucket_line_desc	  Varchar2(35),
	  Amount		 	  Number	) ;

	TYPE bucket_lines_Rec is RECORD(
        outstanding_balance     Number      ,
	  Bucket_line	 	  Varchar2(35),
	  Amount		 	  Number	    ,
	  Currency			  Varchar2(25),
	  bucket_line_id	        Number	    ,
	  bucket_seq_num	        Number      ,
        collectible_amount      Number  ,
	  consolidated_invoices	  Number,
	  Invoice_Count  		  Number	,
        Invoice_amount          Number,
        DM_COUNT                Number,
        dm_AMOUNT               Number,
        cb_count                Number,
        cb_amount               Number,
	  Disputed_Tran_count  	  Number,
        Disputed_tran_amount    Number     ) ;

	-- Aging Summary data pl/sql Table that is passed back to the form
	TYPE Aging_Summary_Tbl is TABLE of Aging_Summary_Rec
		Index By Binary_Integer ;

	TYPE bucket_lines_Tbl is TABLE of bucket_lines_Rec
		Index By Binary_Integer ;

	-- Ref cursors to select the History and Activity Data
	TYPE PROFILE_CUR	IS	REF CURSOR	;


    PROCEDURE calc_aging_buckets (
        p_customer_id           IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_credit_option         IN VARCHAR2,
        p_invoice_type_low      IN VARCHAR2,
        p_invoice_type_high     IN VARCHAR2,
        p_ps_max_id             IN NUMBER DEFAULT 0,
        p_app_max_id            IN NUMBER DEFAULT 0,
        p_bucket_id             IN Number,
	    p_outstanding_balance	IN OUT NOCOPY NUMBER,
        p_bucket_line_id_0      OUT NOCOPY NUMBER,
        p_bucket_seq_num_0	    OUT NOCOPY NUMBER,
        p_bucket_titletop_0     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_0  OUT NOCOPY VARCHAR2,
        p_bucket_amount_0       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_1      OUT NOCOPY NUMBER,
        p_bucket_seq_num_1	    OUT NOCOPY NUMBER,
        p_bucket_titletop_1     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_1  OUT NOCOPY VARCHAR2,
        p_bucket_amount_1       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_2      OUT NOCOPY NUMBER,
        p_bucket_seq_num_2	    OUT NOCOPY NUMBER,
        p_bucket_titletop_2     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_2  OUT NOCOPY VARCHAR2,
        p_bucket_amount_2       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_3      OUT NOCOPY NUMBER,
        p_bucket_seq_num_3	    OUT NOCOPY NUMBER,
        p_bucket_titletop_3     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_3  OUT NOCOPY VARCHAR2,
        p_bucket_amount_3       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_4      OUT NOCOPY NUMBER,
        p_bucket_seq_num_4	    OUT NOCOPY NUMBER,
        p_bucket_titletop_4     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_4  OUT NOCOPY VARCHAR2,
        p_bucket_amount_4       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_5      OUT NOCOPY NUMBER,
        p_bucket_seq_num_5	    OUT NOCOPY NUMBER,
        p_bucket_titletop_5     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_5  OUT NOCOPY VARCHAR2,
        p_bucket_amount_5       IN OUT NOCOPY NUMBER,
        p_bucket_line_id_6      OUT NOCOPY NUMBER,
        p_bucket_seq_num_6	    OUT NOCOPY NUMBER,
        p_bucket_titletop_6     OUT NOCOPY VARCHAR2,
        p_bucket_titlebottom_6  OUT NOCOPY VARCHAR2,
        p_bucket_amount_6       IN OUT NOCOPY NUMBER);
--
    PROCEDURE calc_credits (
        p_filter_mode           IN VARCHAR2,
        p_filter_id        	    IN NUMBER,
        p_customer_site_use_id 	IN NUMBER,
        p_as_of_date         	IN DATE,
        p_currency_code      	IN VARCHAR2,
	    p_ps_max_id		        IN NUMBER DEFAULT 0,
        p_using_paying_rel      IN VARCHAR2,
	    p_credits	     	    OUT NOCOPY NUMBER) ;
--

    PROCEDURE calc_receipts (
        p_filter_mode           IN  VARCHAR2,
        p_filter_id        	    IN  NUMBER,
        p_customer_site_use_id  IN  NUMBER,
        p_as_of_date         	IN  DATE,
        p_currency_code      	IN  VARCHAR2,
	    p_app_max_id		    IN  NUMBER DEFAULT 0,
        p_using_paying_rel      IN VARCHAR2,
        p_unapplied_cash     	OUT NOCOPY NUMBER,
	    p_onacct_cash	     	OUT NOCOPY NUMBER,
	    p_cash_claims	     	OUT NOCOPY NUMBER,
	    p_prepayments	     	OUT NOCOPY NUMBER) ;

--
    PROCEDURE calc_risk_receipts (
        p_filter_mode           IN Varchar2,
        p_filter_id             IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER,
        p_using_paying_rel      IN VARCHAR2,
        p_risk_receipts         OUT NOCOPY NUMBER
);
--
    PROCEDURE calc_dispute (
        p_filter_mode           IN VARCHAR2,
        p_filter_id             IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER,
        p_using_paying_rel      IN VARCHAR2,
        p_dispute               OUT NOCOPY NUMBER
);
--
    PROCEDURE calc_adj_fin_charges(
        p_filter_mode           IN Varchar2,
        p_filter_id             IN NUMBER,
        p_customer_site_use_id  IN NUMBER,
        p_as_of_date            IN DATE,
        p_currency_code         IN VARCHAR2,
        p_ps_max_id             IN NUMBER,
        p_using_paying_rel      IN VARCHAR2,
        p_adj                   OUT NOCOPY NUMBER,
        p_pending_adj           OUT NOCOPY NUMBER,
        p_fin_charges           OUT NOCOPY NUMBER
);


	PROCEDURE QUERY_AGING_LINES
       	    (p_api_version      IN      NUMBER := 1.0,
            p_init_msg_list    IN       VARCHAR2,
            p_commit           IN       VARCHAR2,
            p_validation_level IN       NUMBER,
            x_return_status    IN OUT NOCOPY   VARCHAR2,
            x_msg_count        IN OUT NOCOPY   NUMBER,
            x_msg_data         IN OUT NOCOPY   VARCHAR2,
            p_filter_mode      IN       Varchar2,
	        p_filter_id        IN       Number	,
            p_customer_site_use_id IN   Number, --added by ehuh for 11591
            p_bucket_id        IN       Number,
            p_credit_option    IN       Varchar2,
        p_using_paying_rel      IN VARCHAR2,
            x_bucket_lines_tbl  IN OUT NOCOPY   bucket_lines_tbl	) ;

    PROCEDURE GET_BKT_INVOICE_CLASS_INFO
       (p_api_version      IN   NUMBER := 1.0,
        p_init_msg_list    IN   VARCHAR2,
        p_commit           IN   VARCHAR2,
        p_validation_level IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2,
        p_filter_mode	   IN   Varchar2,
	    p_bucket_line_id   IN   AR_AGING_BUCKET_LINES_B.Aging_Bucket_Line_Id%TYPE,
	    p_filter_id 	   IN   Number,
        p_customer_site_use_id IN Number,    -- added by ehuh for bill-to
        p_class            IN   varchar2,
        p_using_paying_rel      IN VARCHAR2,
        x_class_count      OUT NOCOPY  Number,
	    x_class_amount     OUT NOCOPY  NUMBER)	;



    -- Added as a part of OKL changes
    PROCEDURE GET_CNSLD_INVOICE_COUNT
       (p_api_version      IN   NUMBER := 1.0,
        p_init_msg_list    IN   VARCHAR2,
        p_commit           IN   VARCHAR2,
        p_validation_level IN   NUMBER,
        x_return_status    OUT NOCOPY  VARCHAR2,
        x_msg_count        OUT NOCOPY  NUMBER,
        x_msg_data         OUT NOCOPY  VARCHAR2,
        p_filter_mode	   IN   Varchar2,
	    p_bucket_line_id   IN   AR_AGING_BUCKET_LINES_B.Aging_Bucket_Line_Id%TYPE,
	    p_filter_id 	   IN   Number,
        p_customer_site_use_id IN Number,
        p_using_paying_rel      IN VARCHAR2,
        x_count           OUT NOCOPY  Number,
	    x_amount          OUT NOCOPY  NUMBER)	;



END iex_aging_buckets_pkg ;

 

/
