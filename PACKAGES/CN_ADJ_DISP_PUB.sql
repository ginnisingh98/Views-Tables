--------------------------------------------------------
--  DDL for Package CN_ADJ_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ADJ_DISP_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpadjs.pls 120.0 2005/09/16 02:29:35 chanthon noship $

      TYPE adj_rec_type IS RECORD
	(
         invoice_number         VARCHAR2(20),
         invoice_date           DATE,
         order_number           NUMBER,
         order_date             DATE,
	 creation_date          DATE,
         processed_date         DATE,
         trx_type_disp          VARCHAR2(80),
         adjust_status_disp     VARCHAR2(80),
         adjusted_by            VARCHAR2(100),
	 adjust_date            DATE,
         calc_status_disp       VARCHAR2(80),
         currency_code          VARCHAR2(3),
         sales_credit           NUMBER,
         commission             NUMBER,
         attribute1 		VARCHAR2(240),
	 attribute2 		VARCHAR2(240),
	 attribute3 		VARCHAR2(240),
	 attribute4 		VARCHAR2(240),
	 attribute5 		VARCHAR2(240),
	 attribute6 		VARCHAR2(240),
	 attribute7 		VARCHAR2(240),
	 attribute8 		VARCHAR2(240),
	 attribute9 		VARCHAR2(240),
	 attribute10		VARCHAR2(240),
	 attribute11		VARCHAR2(240),
	 attribute12		VARCHAR2(240),
	 attribute13		VARCHAR2(240),
	 attribute14		VARCHAR2(240),
	 attribute15		VARCHAR2(240),
	 attribute16		VARCHAR2(240),
	 attribute17		VARCHAR2(240),
	 attribute18		VARCHAR2(240),
	 attribute19		VARCHAR2(240),
	 attribute20		VARCHAR2(240),
	 attribute21		VARCHAR2(240),
	 attribute22		VARCHAR2(240),
	 attribute23		VARCHAR2(240),
	 attribute24		VARCHAR2(240),
	 attribute25		VARCHAR2(240),
	 attribute26		VARCHAR2(240),
	 attribute27		VARCHAR2(240),
	 attribute28		VARCHAR2(240),
	 attribute29		VARCHAR2(240),
	 attribute30		VARCHAR2(240),
	 attribute31		VARCHAR2(240),
	 attribute32		VARCHAR2(240),
	 attribute33		VARCHAR2(240),
	 attribute34		VARCHAR2(240),
	 attribute35		VARCHAR2(240),
	 attribute36		VARCHAR2(240),
	 attribute37		VARCHAR2(240),
	 attribute38		VARCHAR2(240),
	 attribute39		VARCHAR2(240),
	 attribute40	        VARCHAR2(240),
	 attribute41	        VARCHAR2(240),
	 attribute42	        VARCHAR2(240),
	 attribute43	        VARCHAR2(240),
	 attribute44	        VARCHAR2(240),
	 attribute45	        VARCHAR2(240),
         attribute46            VARCHAR2(240),
	 attribute47 		VARCHAR2(240),
	 attribute48 		VARCHAR2(240),
	 attribute49 		VARCHAR2(240),
	 attribute50 		VARCHAR2(240),
	 attribute51 		VARCHAR2(240),
	 attribute52 		VARCHAR2(240),
	 attribute53 		VARCHAR2(240),
	 attribute54 		VARCHAR2(240),
	 attribute55 		VARCHAR2(240),
	 attribute56 		VARCHAR2(240),
	 attribute57 		VARCHAR2(240),
	 attribute58 		VARCHAR2(240),
	 attribute59 		VARCHAR2(240),
	 attribute60 		VARCHAR2(240),
	 attribute61 		VARCHAR2(240),
	 attribute62 		VARCHAR2(240),
	 attribute63 		VARCHAR2(240),
	 attribute64 		VARCHAR2(240),
	 attribute65 		VARCHAR2(240),
	 attribute66 		VARCHAR2(240),
	 attribute67 		VARCHAR2(240),
	 attribute68 		VARCHAR2(240),
	 attribute69 		VARCHAR2(240),
	 attribute70 		VARCHAR2(240),
	 attribute71 		VARCHAR2(240),
	 attribute72 		VARCHAR2(240),
	 attribute73 		VARCHAR2(240),
	 attribute74 		VARCHAR2(240),
	 attribute75 		VARCHAR2(240),
	 attribute76 		VARCHAR2(240),
	 attribute77 		VARCHAR2(240),
	 attribute78 		VARCHAR2(240),
	 attribute79 		VARCHAR2(240),
	 attribute80 		VARCHAR2(240),
	 attribute81 		VARCHAR2(240),
	 attribute82 		VARCHAR2(240),
	 attribute83 		VARCHAR2(240),
	 attribute84 		VARCHAR2(240),
	 attribute85 		VARCHAR2(240),
	 attribute86 		VARCHAR2(240),
	 attribute87 		VARCHAR2(240),
	 attribute88 		VARCHAR2(240),
	 attribute89 		VARCHAR2(240),
	 attribute90 		VARCHAR2(240),
	 attribute91            VARCHAR2(240),
	 attribute92 		VARCHAR2(240),
	 attribute93 		VARCHAR2(240),
	 attribute94 		VARCHAR2(240),
	 attribute95 		VARCHAR2(240),
	 attribute96 		VARCHAR2(240),
	 attribute97 		VARCHAR2(240),
	 attribute98 		VARCHAR2(240),
	 attribute99 		VARCHAR2(240),
	 attribute100		VARCHAR2(240),
	customer_id		NUMBER(15),
	customer_name           VARCHAR2(50),
	customer_number         VARCHAR2(30),
	bill_to_address_id     NUMBER,
	ship_to_address_id     NUMBER,
	bill_to_contact_id     NUMBER,
	ship_to_contact_id     NUMBER,
	rollup_date            DATE,
	comments               VARCHAR2(1800),
	reason_code            VARCHAR2(30),
	reason                 VARCHAR2(80),
	quota_id               NUMBER(15),
	quota_name             VARCHAR2(80),
	revenue_class_id       NUMBER(15),
	revenue_class_name     VARCHAR2(30)
	);

      TYPE adj_tbl_type IS TABLE OF  adj_rec_type
	INDEX BY BINARY_INTEGER;


  -- API name 	: Get_adj
  -- Type	: Public.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:  Get the transaction details
  -- Parameters	:
  --   IN       : p_salesrep_id           Id of salesrep. Should not be null : NUMBER
  --   IN       : p_pr_date_from          Processed date from.  : DATE
  --   IN       : p_pr_date_to            Processed date to.    : DATE
  --   IN       : p_invoice_num           Invoice number        : VARCHAR2
  --   IN       : p_order_num             Order number          : NUMBER
  --   IN       : p_calc_status           Calculation Status    : VARCHAR2
  --   IN       : p_adjust_status         Adjustment Status     : VARCHAR2
  --   IN       : p_adjust_date           Adjustment Date       : DATE
  --   IN       : p_trx_type              Transaction Type      : VARCHAR2
  --   IN       : p_date_pattern          Default date, Cant seem to pass an aribtrary
  --                                      number as a date from the front end. This date
  --                                      pattern is taken as the null(all) date.
  --                                      Pass a dummy date like 11/11/1111 and hope no one
  --                                      made etransactions on that date :)     : DATE
  --   IN       : p_start_record          For page scrolling, the first record :  NUMBER
  --   IN       : p_increment_count       The number of records per page :  NUMBER

  --   IN       : p_curr_code             Currency code to convert to
  --   OUT      : x_adj_tbl              The output table           : adj_tbl_type
  --   OUT      : x_adj_count            Total records in the query : NUMBER
  --   OUT      : x_total_transaction_amount                            : NUMBER
  --   OUT      : x_total_commission_amount                             : NUMBER
  --   OUT      : x_conv_status          Currency conversion status
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  -- Notes	: This API is used to get the transaction detail information. The data come
  --              from CN_COMMISSION_LINES and CN_COMMISSION_HEADERS. This API will not
  --              get the transaction information from CN_COMM_LINES_API.
  -- End of comments

  PROCEDURE get_adj
    (
     p_api_version           IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_loading_status         OUT NOCOPY VARCHAR2,
     p_salesrep_id            IN NUMBER ,
     p_pr_date_from           IN DATE ,
     p_pr_date_to             IN DATE ,
     p_invoice_num            IN VARCHAR2,
     p_order_num              IN NUMBER,
     p_calc_status            IN VARCHAR2,
     p_adjust_status          IN VARCHAR2,
     p_adjust_date            IN DATE,
     p_trx_type               IN VARCHAR2,
     p_date_pattern           IN DATE,
     p_start_record           IN  NUMBER := 1,
     p_increment_count        IN  NUMBER,
     p_curr_code              IN  VARCHAR2,
     x_adj_tbl                OUT NOCOPY  adj_tbl_type,
     x_adj_count              OUT NOCOPY NUMBER,
     x_total_sales_credit     OUT NOCOPY NUMBER,
     x_total_commission       OUT NOCOPY NUMBER,
     x_conv_status            OUT NOCOPY VARCHAR2
    );

END cn_adj_disp_pub ;


 

/
