--------------------------------------------------------
--  DDL for Package ARW_CMREQ_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARW_CMREQ_COVER" AUTHID CURRENT_USER AS
/* $Header: ARWCMRQS.pls 120.6.12010000.3 2009/06/25 06:16:52 npanchak ship $ */


/*4556000*/
TYPE pq_attribute_rec_type IS RECORD(
                        attribute_category    VARCHAR2(30) DEFAULT NULL,
                        attribute1            VARCHAR2(150) DEFAULT NULL,
       					attribute2            VARCHAR2(150) DEFAULT NULL,
        				attribute3            VARCHAR2(150) DEFAULT NULL,
        				attribute4            VARCHAR2(150) DEFAULT NULL,
       					attribute5            VARCHAR2(150) DEFAULT NULL,
        				attribute6            VARCHAR2(150) DEFAULT NULL,
        				attribute7            VARCHAR2(150) DEFAULT NULL,
        				attribute8            VARCHAR2(150) DEFAULT NULL,
        				attribute9            VARCHAR2(150) DEFAULT NULL,
        				attribute10           VARCHAR2(150) DEFAULT NULL,
        				attribute11           VARCHAR2(150) DEFAULT NULL,
        				attribute12           VARCHAR2(150) DEFAULT NULL,
        				attribute13           VARCHAR2(150) DEFAULT NULL,
        				attribute14           VARCHAR2(150) DEFAULT NULL,
        				attribute15           VARCHAR2(150) DEFAULT NULL);

TYPE pq_interface_rec_type IS RECORD(
                        interface_header_context           VARCHAR2(30) DEFAULT NULL,
                        interface_header_attribute1            VARCHAR2(30) DEFAULT NULL,
       		        interface_header_attribute2            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute3            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute4            VARCHAR2(30) DEFAULT NULL,
       			interface_header_attribute5            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute6            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute7            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute8            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute9            VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute10           VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute11           VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute12           VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute13           VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute14           VARCHAR2(30) DEFAULT NULL,
        		interface_header_attribute15           VARCHAR2(30) DEFAULT NULL);

TYPE pq_global_attribute_rec_type IS RECORD(
        global_attribute_category     VARCHAR2(30) default null,
        global_attribute1             VARCHAR2(150) default NULL,
        global_attribute2             VARCHAR2(150) DEFAULT NULL,
        global_attribute3             VARCHAR2(150) DEFAULT NULL,
        global_attribute4             VARCHAR2(150) DEFAULT NULL,
        global_attribute5             VARCHAR2(150) DEFAULT NULL,
        global_attribute6             VARCHAR2(150) DEFAULT NULL,
        global_attribute7             VARCHAR2(150) DEFAULT NULL,
        global_attribute8             VARCHAR2(150) DEFAULT NULL,
        global_attribute9             VARCHAR2(150) DEFAULT NULL,
        global_attribute10            VARCHAR2(150) DEFAULT NULL,
        global_attribute11            VARCHAR2(150) DEFAULT NULL,
        global_attribute12            VARCHAR2(150) DEFAULT NULL,
        global_attribute13            VARCHAR2(150) DEFAULT NULL,
        global_attribute14            VARCHAR2(150) DEFAULT NULL,
        global_attribute15            VARCHAR2(150) DEFAULT NULL,
        global_attribute16            VARCHAR2(150) DEFAULT NULL,
        global_attribute17            VARCHAR2(150) DEFAULT NULL,
        global_attribute18            VARCHAR2(150) DEFAULT NULL,
        global_attribute19            VARCHAR2(150) DEFAULT NULL,
        global_attribute20            VARCHAR2(150) DEFAULT NULL,
        global_attribute21            VARCHAR2(150) DEFAULT NULL,
        global_attribute22            VARCHAR2(150) DEFAULT NULL,
        global_attribute23            VARCHAR2(150) DEFAULT NULL,
        global_attribute24            VARCHAR2(150) DEFAULT NULL,
        global_attribute25            VARCHAR2(150) DEFAULT NULL,
        global_attribute26            VARCHAR2(150) DEFAULT NULL,
        global_attribute27            VARCHAR2(150) DEFAULT NULL,
        global_attribute28            VARCHAR2(150) DEFAULT NULL,
        global_attribute29            VARCHAR2(150) DEFAULT NULL,
        global_attribute30            VARCHAR2(150) DEFAULT NULL);

pq_attribute_rec_const  pq_attribute_rec_type;
pq_interface_rec_const pq_interface_rec_type;
pq_global_attribute_const pq_global_attribute_rec_type;

/*4556000 additional columns added*/
TYPE Cm_Line_Rec_Type_Cover IS RECORD
  (customer_trx_line_id ra_customer_trx_lines.Customer_trx_line_id%type,
   extended_amount ra_customer_trx_lines.Extended_amount%type,
   quantity_credited	NUMBER,
   price		NUMBER,
   ATTRIBUTE_CATEGORY	            VARCHAR2(30)	  DEFAULT NULL,
   ATTRIBUTE1	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE2	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE3	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE4	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE5	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE6	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE7	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE8	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE9	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE10	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE11	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE12	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE13	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE14	                    VARCHAR2(150)	  DEFAULT NULL,
   ATTRIBUTE15	                    VARCHAR2(150)	  DEFAULT NULL,
   INTERFACE_LINE_CONTEXT	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE1	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE2	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE3	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE4	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE5	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE6	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE7	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE8	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE9	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE10	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE11	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE12	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE13	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE14	    VARCHAR2(30)	  DEFAULT NULL,
   INTERFACE_LINE_ATTRIBUTE15	    VARCHAR2(30)	  DEFAULT NULL,
   GLOBAL_ATTRIBUTE1	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE2	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE3	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE4	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE5	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE6	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE7	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE8	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE9	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE10	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE11	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE12	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE13	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE14	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE15	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE16	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE17	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE18	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE19	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE20	            VARCHAR2(150)	   DEFAULT NULL,
   GLOBAL_ATTRIBUTE_CATEGORY	    VARCHAR2(30)	   DEFAULT NULL);

TYPE Cm_Line_Tbl_Type_Cover  IS TABLE OF Cm_Line_Rec_Type_Cover
                             INDEX BY BINARY_INTEGER;

FUNCTION ar_request_cm(
     p_customer_trx_id      IN  ra_customer_trx.customer_trx_id%type,
     p_line_credits_flag    IN  ra_cm_requests.line_credits_flag%type,
     p_line_amount          IN  number,
     p_tax_amount           IN  number,
     p_freight_amount       IN  number,
     p_cm_lines_tbl         IN  Cm_Line_Tbl_Type_Cover,
     p_cm_reason_code       IN  varchar2,
     p_comments             IN  varchar2,
     p_url		    IN  ra_cm_requests.url%TYPE 	default null,
     p_transaction_url      IN  ra_cm_requests.transaction_url%TYPE 	default null,
     p_trans_act_url        IN  ra_cm_requests.activities_url%TYPE 	default null,
     p_orig_trx_number	    IN  varchar2 	default null,
     p_tax_ex_cert_num      IN  varchar2 	default null,
     p_skip_workflow_flag   IN VARCHAR2     	DEFAULT 'N',
     p_trx_number           IN ra_customer_trx.trx_number%type   DEFAULT NULL,
     p_credit_method_installments IN VARCHAR2 	DEFAULT NULL,
     p_credit_method_rules  IN VARCHAR2     	DEFAULT NULL,
     p_batch_source_name    IN VARCHAR2     	DEFAULT NULL,
     /*4556000*/
     pq_attribute_rec           IN pq_attribute_rec_type DEFAULT pq_attribute_rec_const,
     pq_interface_attribute_rec IN pq_interface_rec_type DEFAULT pq_interface_rec_const,
     pq_global_attribute_rec    IN pq_global_attribute_rec_type DEFAULT
					pq_global_attribute_const,
     p_dispute_date		IN DATE DEFAULT NULL, -- Bug 6358930
     p_internal_comment IN VARCHAR2 DEFAULT NULL  /*7367350 New parameter for handling insertion internal comment*/
      ) RETURN varchar2;

PROCEDURE ar_autocreate_cm(
     p_request_id          IN  ra_cm_requests.request_id%type,
     p_batch_source_name   IN  ra_batch_sources.name%type,
     p_credit_method_rules IN  varchar2,
     p_credit_method_installments  IN  varchar2,
     p_trx_number           IN ra_customer_trx.trx_number%type   DEFAULT NULL,
     p_error_tab           OUT NOCOPY arp_trx_validate.Message_Tbl_Type,
     p_status              OUT NOCOPY VARCHAR2);

FUNCTION cancel_cm_request
( p_subscription_guid In RAW
, p_event IN OUT NOCOPY WF_EVENT_T
)
RETURN VARCHAR2;

END arw_cmreq_cover;

/
