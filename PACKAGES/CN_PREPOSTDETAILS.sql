--------------------------------------------------------
--  DDL for Package CN_PREPOSTDETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PREPOSTDETAILS" AUTHID CURRENT_USER AS
-- $Header: cntpdets.pls 115.7 2002/01/28 20:05:03 pkm ship    $ --+

TYPE posting_detail_rec_type IS RECORD
  (posting_detail_id        cn_posting_details.posting_detail_id%TYPE,
   posting_batch_id         cn_posting_details.posting_batch_id%TYPE,
   posting_type             cn_posting_details.posting_type%TYPE,
   trx_type                 cn_posting_details.trx_type%TYPE,
   payee_salesrep_id        cn_posting_details.payee_salesrep_id%TYPE,
   role_id                  cn_posting_details.role_id%TYPE,
   incentive_type_code      cn_posting_details.incentive_type_code%TYPE,
   credit_type_id           cn_posting_details.credit_type_id%TYPE,
   pay_period_id            cn_posting_details.pay_period_id%TYPE,
   amount                   cn_posting_details.amount%TYPE := 0,
   commission_header_id	    cn_posting_details.commission_header_id%TYPE,
   commission_line_id	    cn_posting_details.commission_line_id%TYPE,
   srp_plan_assign_id	    cn_posting_details.srp_plan_assign_id%TYPE,
   quota_id                 cn_posting_details.quota_id%TYPE,
   status		    cn_posting_details.status%TYPE
                            := FND_API.G_MISS_CHAR,
   loaded_date              cn_posting_details.loaded_date%TYPE
        		    := FND_API.G_MISS_DATE,
   processed_date	    cn_posting_details.processed_date%TYPE,
   credited_salesrep_id	    cn_posting_details.credited_salesrep_id%TYPE,
   processed_period_id	    cn_posting_details.processed_period_id%TYPE,
   quota_rule_id	    cn_posting_details.quota_rule_id%TYPE,
   event_factor		    cn_posting_details.event_factor%TYPE,
   payment_factor	    cn_posting_details.payment_factor%TYPE,
   quota_factor		    cn_posting_details.quota_factor%TYPE,
   pending_status	    cn_posting_details.pending_status%TYPE,
   input_achieved	    cn_posting_details.input_achieved%TYPE,
   rate_tier_id		    cn_posting_details.rate_tier_id%TYPE,
   payee_line_id	    cn_posting_details.payee_line_id%TYPE,
   cl_status		    cn_posting_details.cl_status%TYPE,
   created_during	    cn_posting_details.created_during%TYPE,
   commission_rate	    cn_posting_details.commission_rate%TYPE := 0,
   hold_flag                cn_posting_details.hold_flag%TYPE
                            := FND_API.G_MISS_CHAR,
   paid_flag                cn_posting_details.paid_flag%TYPE
                            := FND_API.G_MISS_CHAR,
   payment_amount           cn_posting_details.payment_amount%TYPE
                            := FND_API.G_MISS_NUM,
   attribute_category	    cn_posting_details.attribute_category%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute1		    cn_posting_details.attribute1%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute2		    cn_posting_details.attribute2%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute3		    cn_posting_details.attribute3%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute4		    cn_posting_details.attribute4%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute5		    cn_posting_details.attribute5%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute6		    cn_posting_details.attribute6%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute7		    cn_posting_details.attribute7%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute8		    cn_posting_details.attribute8%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute9		    cn_posting_details.attribute9%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute10		    cn_posting_details.attribute10%TYPE
			    := FND_API.G_MISS_CHAR,
   attribute11		    cn_posting_details.attribute11%TYPE
  			    := FND_API.G_MISS_CHAR,
   attribute12		    cn_posting_details.attribute12%TYPE
  			    := FND_API.G_MISS_CHAR,
   attribute13		    cn_posting_details.attribute13%TYPE
  			    := FND_API.G_MISS_CHAR,
   attribute14		    cn_posting_details.attribute14%TYPE
  			    := FND_API.G_MISS_CHAR,
   attribute15		    cn_posting_details.attribute15%TYPE
  			    := FND_API.G_MISS_CHAR,
   created_by		    cn_posting_details.created_by%TYPE,
   creation_date            cn_posting_details.creation_date%TYPE,
   last_update_login        cn_posting_details.last_update_login%TYPE,
   last_update_date         cn_posting_details.last_update_date%TYPE,
   last_updated_by          cn_posting_details.last_updated_by%TYPE);

TYPE posting_detail_rec_tbl_type IS TABLE OF posting_detail_rec_type
  INDEX BY BINARY_INTEGER;

PROCEDURE Begin_Record
  (x_operation              IN       VARCHAR2,
   x_rowid                  IN OUT   VARCHAR2,
   x_posting_detail_rec     IN OUT   posting_detail_rec_type,
   x_program_type           IN       VARCHAR2);
END CN_PREPOSTDETAILS;

 

/
