--------------------------------------------------------
--  DDL for Package AR_BPA_BFPRI_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BPA_BFPRI_CONC" AUTHID CURRENT_USER AS
/* $Header: ARBPBFBS.pls 120.2 2006/08/18 22:52:30 lishao noship $ */

FUNCTION PRINT_MLS_FUNCTION  RETURN varchar2 ;

PROCEDURE PRINT_BILLS(
								 errbuf     IN OUT NOCOPY VARCHAR2,
                 retcode    IN OUT NOCOPY VARCHAR2,
       			 p_org_id  			IN NUMBER,
                 p_job_size         IN NUMBER,
                 p_cust_num_low     IN VARCHAR2,
                 p_cust_num_high    IN VARCHAR2,
                 p_bill_site_low    IN NUMBER,
                 p_bill_site_high   IN NUMBER,
                 p_bill_date_low_in IN VARCHAR2,
                 p_bill_date_high_in IN VARCHAR2,
                 p_bill_num_low   	IN VARCHAR2,
                 p_bill_num_high  	IN VARCHAR2,
                 p_request_id       IN NUMBER,
       					 p_template_id      IN NUMBER
                 );

PROCEDURE process_print_request(p_id_list       IN  VARCHAR2,
                                x_req_id_list 	OUT NOCOPY    VARCHAR2 ,
                                p_description   IN  VARCHAR2  DEFAULT  NULL,
                                p_template_id   IN  NUMBER    DEFAULT  NULL,
                                p_stamp_flag    IN  VARCHAR2  DEFAULT  'Y'
                                ) ;

END AR_BPA_BFPRI_CONC;


 

/
