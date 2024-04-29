--------------------------------------------------------
--  DDL for Package AR_BPA_PRINT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_PRINT_CONC" AUTHID CURRENT_USER AS
/* $Header: ARBPPRIS.pls 120.7 2006/08/18 22:51:33 lishao noship $ */

FUNCTION PRINT_MLS_FUNCTION  RETURN varchar2 ;

FUNCTION GENXSL_MLS_FUNCTION RETURN VARCHAR2;

PROCEDURE PRINT_INVOICES(
       errbuf                         IN OUT NOCOPY VARCHAR2,
       retcode                        IN OUT NOCOPY VARCHAR2,
       p_org_id                       IN NUMBER,
       p_job_size                     IN NUMBER,
       p_choice                       IN VARCHAR2,
       p_order_by                     IN VARCHAR2,
       p_batch_id                     IN NUMBER,
       p_cust_trx_class               IN VARCHAR2,
       p_trx_type_id                  IN NUMBER,
       p_customer_class_code          IN VARCHAR2,
       p_customer_name_low            IN VARCHAR2,
       p_customer_name_high           IN VARCHAR2,
       p_customer_no_low              IN VARCHAR2,
       p_customer_no_high             IN VARCHAR2,
       p_trx_number_low               IN VARCHAR2,
       p_trx_number_high              IN VARCHAR2,
       p_installment_no               IN NUMBER,
       p_print_date_low_in            IN VARCHAR2,
       p_print_date_high_in           IN VARCHAR2,
       p_open_invoice_flag            IN VARCHAR2,
       p_invoice_list_string          IN VARCHAR2,
       p_template_id                  IN NUMBER,
       p_child_template_id            IN NUMBER,
       p_locale                       IN VARCHAR2,
       p_index_flag                   IN VARCHAR2
      );

PROCEDURE process_print_request(p_id_list       IN  VARCHAR2,
                                x_req_id_list 	OUT NOCOPY    VARCHAR2 ,
                                p_list_type     IN  VARCHAR2  DEFAULT  NULL,
                                p_description   IN  VARCHAR2  DEFAULT  NULL,
                                p_template_id   IN  NUMBER    DEFAULT  NULL,
                                p_stamp_flag    IN  VARCHAR2  DEFAULT  'Y',
                                p_child_template_id   IN  NUMBER    DEFAULT  NULL
                                ) ;

PROCEDURE process_multi_print(  p_id_list 	IN  VARCHAR2,
				x_request_id 	OUT NOCOPY    NUMBER ,
                               	x_out_status 	OUT NOCOPY    VARCHAR2,
                                p_list_type     IN  VARCHAR2  DEFAULT  NULL) ;
END AR_BPA_PRINT_CONC;


 

/
