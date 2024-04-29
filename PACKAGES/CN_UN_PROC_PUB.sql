--------------------------------------------------------
--  DDL for Package CN_UN_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_UN_PROC_PUB" AUTHID CURRENT_USER AS
-- $Header: cnunpros.pls 115.7 2002/11/21 21:11:21 hlchen ship $

TYPE unproc_rec_type IS RECORD(
   invoice_number  	cn_comm_lines_api.invoice_number%TYPE,
   invoice_date         cn_comm_lines_api.invoice_date%TYPE,
   order_number         cn_comm_lines_api.order_number%TYPE,
   order_date           cn_comm_lines_api.booked_date%TYPE,
   creation_date        cn_comm_lines_api.creation_date%TYPE,
   processed_date       cn_comm_lines_api.processed_date%TYPE,
   trx_type_disp        cn_lookups.meaning%TYPE ,
   adjust_status_disp   cn_lookups.meaning%TYPE ,
   adjusted_by          cn_comm_lines_api.adjusted_by%TYPE,
   load_status	        cn_comm_lines_api.load_status%TYPE,
   calc_status_disp     cn_lookups.meaning%TYPE ,
   sales_credit         cn_comm_lines_api.transaction_amount%TYPE,
   commission           cn_comm_lines_api.commission_amount%TYPE,
   adjust_date		cn_comm_lines_api.adjust_date%TYPE,
   attribute1 		cn_comm_lines_api.attribute1%TYPE,
   attribute2 		cn_comm_lines_api.attribute2%TYPE,
   attribute3 		cn_comm_lines_api.attribute3%TYPE,
   attribute4 		cn_comm_lines_api.attribute4%TYPE,
   attribute5 		cn_comm_lines_api.attribute5%TYPE,
   attribute6 		cn_comm_lines_api.attribute6%TYPE,
   attribute7 		cn_comm_lines_api.attribute7%TYPE,
   attribute8 		cn_comm_lines_api.attribute8%TYPE,
   attribute9 		cn_comm_lines_api.attribute9%TYPE,
   attribute10		cn_comm_lines_api.attribute10%TYPE,
   attribute11		cn_comm_lines_api.attribute11%TYPE,
   attribute12		cn_comm_lines_api.attribute12%TYPE,
   attribute13		cn_comm_lines_api.attribute13%TYPE,
   attribute14		cn_comm_lines_api.attribute14%TYPE,
   attribute15		cn_comm_lines_api.attribute15%TYPE,
   attribute16		cn_comm_lines_api.attribute16%TYPE,
   attribute17		cn_comm_lines_api.attribute17%TYPE,
   attribute18		cn_comm_lines_api.attribute18%TYPE,
   attribute19		cn_comm_lines_api.attribute19%TYPE,
   attribute20		cn_comm_lines_api.attribute20%TYPE,
   attribute21		cn_comm_lines_api.attribute21%TYPE,
   attribute22		cn_comm_lines_api.attribute22%TYPE,
   attribute23		cn_comm_lines_api.attribute23%TYPE,
   attribute24		cn_comm_lines_api.attribute24%TYPE,
   attribute25		cn_comm_lines_api.attribute25%TYPE,
   attribute26		cn_comm_lines_api.attribute26%TYPE,
   attribute27		cn_comm_lines_api.attribute27%TYPE,
   attribute28		cn_comm_lines_api.attribute28%TYPE,
   attribute29		cn_comm_lines_api.attribute29%TYPE,
   attribute30		cn_comm_lines_api.attribute30%TYPE,
   attribute31		cn_comm_lines_api.attribute31%TYPE,
   attribute32		cn_comm_lines_api.attribute32%TYPE,
   attribute33		cn_comm_lines_api.attribute33%TYPE,
   attribute34		cn_comm_lines_api.attribute34%TYPE,
   attribute35		cn_comm_lines_api.attribute35%TYPE,
   attribute36		cn_comm_lines_api.attribute36%TYPE,
   attribute37		cn_comm_lines_api.attribute37%TYPE,
   attribute38		cn_comm_lines_api.attribute38%TYPE,
   attribute39		cn_comm_lines_api.attribute39%TYPE,
   attribute40	       	cn_comm_lines_api.attribute40%TYPE,
   attribute41	       	cn_comm_lines_api.attribute41%TYPE,
   attribute42	       	cn_comm_lines_api.attribute42%TYPE,
   attribute43	       	cn_comm_lines_api.attribute43%TYPE,
   attribute44	       	cn_comm_lines_api.attribute44%TYPE,
   attribute45	       	cn_comm_lines_api.attribute45%TYPE,
   attribute46          cn_comm_lines_api.attribute46%TYPE,
   attribute47 		cn_comm_lines_api.attribute47%TYPE,
   attribute48 		cn_comm_lines_api.attribute48%TYPE,
   attribute49 		cn_comm_lines_api.attribute49%TYPE,
   attribute50 		cn_comm_lines_api.attribute50%TYPE,
   attribute51 		cn_comm_lines_api.attribute51%TYPE,
   attribute52 		cn_comm_lines_api.attribute52%TYPE,
   attribute53 		cn_comm_lines_api.attribute53%TYPE,
   attribute54 		cn_comm_lines_api.attribute54%TYPE,
   attribute55 		cn_comm_lines_api.attribute55%TYPE,
   attribute56 		cn_comm_lines_api.attribute56%TYPE,
   attribute57 		cn_comm_lines_api.attribute57%TYPE,
   attribute58 		cn_comm_lines_api.attribute58%TYPE,
   attribute59 		cn_comm_lines_api.attribute59%TYPE,
   attribute60 		cn_comm_lines_api.attribute60%TYPE,
   attribute61 		cn_comm_lines_api.attribute61%TYPE,
   attribute62 		cn_comm_lines_api.attribute62%TYPE,
   attribute63 		cn_comm_lines_api.attribute63%TYPE,
   attribute64 		cn_comm_lines_api.attribute64%TYPE,
   attribute65 		cn_comm_lines_api.attribute65%TYPE,
   attribute66 		cn_comm_lines_api.attribute66%TYPE,
   attribute67 		cn_comm_lines_api.attribute67%TYPE,
   attribute68 		cn_comm_lines_api.attribute68%TYPE,
   attribute69 		cn_comm_lines_api.attribute69%TYPE,
   attribute70 		cn_comm_lines_api.attribute70%TYPE,
   attribute71 		cn_comm_lines_api.attribute71%TYPE,
   attribute72 		cn_comm_lines_api.attribute72%TYPE,
   attribute73 		cn_comm_lines_api.attribute73%TYPE,
   attribute74 		cn_comm_lines_api.attribute74%TYPE,
   attribute75 		cn_comm_lines_api.attribute75%TYPE,
   attribute76 		cn_comm_lines_api.attribute76%TYPE,
   attribute77 		cn_comm_lines_api.attribute77%TYPE,
   attribute78 		cn_comm_lines_api.attribute78%TYPE,
   attribute79 		cn_comm_lines_api.attribute79%TYPE,
   attribute80 		cn_comm_lines_api.attribute80%TYPE,
   attribute81 		cn_comm_lines_api.attribute81%TYPE,
   attribute82 		cn_comm_lines_api.attribute82%TYPE,
   attribute83 		cn_comm_lines_api.attribute83%TYPE,
   attribute84 		cn_comm_lines_api.attribute84%TYPE,
   attribute85 		cn_comm_lines_api.attribute85%TYPE,
   attribute86 		cn_comm_lines_api.attribute86%TYPE,
   attribute87 		cn_comm_lines_api.attribute87%TYPE,
   attribute88 		cn_comm_lines_api.attribute88%TYPE,
   attribute89 		cn_comm_lines_api.attribute89%TYPE,
   attribute90 		cn_comm_lines_api.attribute90%TYPE,
   attribute91          cn_comm_lines_api.attribute91%TYPE,
   attribute92 		cn_comm_lines_api.attribute92%TYPE,
   attribute93 		cn_comm_lines_api.attribute93%TYPE,
   attribute94 		cn_comm_lines_api.attribute94%TYPE,
   attribute95 		cn_comm_lines_api.attribute95%TYPE,
   attribute96 		cn_comm_lines_api.attribute96%TYPE,
   attribute97 		cn_comm_lines_api.attribute97%TYPE,
   attribute98 		cn_comm_lines_api.attribute98%TYPE,
   attribute99 		cn_comm_lines_api.attribute99%TYPE,
   attribute100		cn_comm_lines_api.attribute100%TYPE);

   TYPE adj_tbl_type IS TABLE OF  unproc_rec_type
   INDEX BY BINARY_INTEGER;


  -- API name 	: Get_adj
  -- Type	: Public.
  -- Pre-reqs	:
  -- Usage	:
  --
  -- Desc 	:  Get the Unprocessed Processed Tx details
  --
  --
  --
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
  --   IN	: p_load_status		  Load Type		: VARCHAR2
  --   IN       : p_date_pattern          Default date, Cant seem to pass an aribtrary
  --                                      number as a date from the front end. This date
  --                                      pattern is taken as the null(all) date.
  --                                      Pass a dummy date like 11/11/1111 and hope no one
  --                                      made etransactions on that date :)     : DATE
  --   IN       : p_start_record          For page scrolling, the first record :  NUMBER
  --   IN       : p_increment_count       The number of records per page :  NUMBER

  --   OUT      : x_adj_tbl              The output table           : adj_tbl_type
  --   OUT      : x_adj_count            Total records in the query : NUMBER
  --   OUT      : x_total_transaction_amount                            : NUMBER
  --   OUT      : x_total_commission_amount                             : NUMBER
  --
  --
  --
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	: This API is used to get the unprocessed tx details information.
  --              The data come from CN_COMM_LINES_API and CN_COMMISSION_HEADERS.
  --
  -- End of comments

  PROCEDURE get_adj (
     p_api_version            IN        NUMBER,
     p_init_msg_list          IN        VARCHAR2 := FND_API.G_FALSE,
     p_validation_level       IN        VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     x_return_status          OUT NOCOPY       VARCHAR2,
     x_msg_count              OUT NOCOPY       NUMBER,
     x_msg_data               OUT NOCOPY       VARCHAR2,
     x_loading_status         OUT NOCOPY       VARCHAR2,
     p_salesrep_id            IN        NUMBER,
     p_pr_date_from           IN        DATE,
     p_pr_date_to             IN        DATE,
     p_invoice_num            IN        VARCHAR2,
     p_order_num              IN        NUMBER,
     p_adjust_status          IN        VARCHAR2,
     p_adjust_date            IN        DATE,
     p_trx_type               IN        VARCHAR2,
     p_calc_status            IN        VARCHAR2,
     p_load_status            IN        VARCHAR2,
     p_date_pattern           IN        DATE,
     p_start_record           IN        NUMBER := 1,
     p_increment_count        IN        NUMBER,
     x_adj_tbl                OUT NOCOPY       adj_tbl_type,
     x_adj_count              OUT NOCOPY       NUMBER,
     x_total_sales_credit     OUT NOCOPY       NUMBER,
     x_total_commission       OUT NOCOPY       NUMBER);

END cn_un_proc_pub ;

 

/
