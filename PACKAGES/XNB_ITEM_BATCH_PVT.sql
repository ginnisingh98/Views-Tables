--------------------------------------------------------
--  DDL for Package XNB_ITEM_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNB_ITEM_BATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: XNBVICPS.pls 120.2 2005/09/20 01:52:10 ksrikant noship $ */

FUNCTION gen_item_batch_file (          ERRBUF          OUT NOCOPY VARCHAR2,
                        			    RETCODE          OUT NOCOPY NUMBER,
                                        p_bill_app_code  IN	VARCHAR2,
                                        p_org_id		 IN	NUMBER,
			                            p_cat_set_id	 IN	NUMBER,
			                            p_cat_id		 IN	NUMBER,
			                            p_from_date	     IN	VARCHAR2,
			                            p_output_format	 IN	VARCHAR2)
				RETURN NUMBER;



PROCEDURE create_cln_items (p_bill_app_code IN VARCHAR2,
				i IN NUMBER,
				cln_result OUT NOCOPY NUMBER);


PROCEDURE construct_sql (
				x_sql_string	IN	OUT NOCOPY VARCHAR2,
				p_cat_set_id	IN	NUMBER,
				p_cat_id	IN	NUMBER,
				p_from_date	IN	VARCHAR2);

PROCEDURE publish_item_xml(p_item_id IN NUMBER,
                           p_org_id IN NUMBER,
                           p_bill_app_code IN VARCHAR2,
                           p_rec_cnt IN NUMBER,
                           xml_result IN OUT NOCOPY NUMBER);

PROCEDURE check_invoiceable_item_flag
(
		 		 itemtype  	IN VARCHAR2,
				 itemkey 	IN VARCHAR2,
				 actid 		IN NUMBER,
				 funcmode 	IN VARCHAR2,
				 resultout 	OUT NOCOPY VARCHAR2
);





PROCEDURE publish_item (ERRBUF		OUT	NOCOPY VARCHAR2,
				RETCODE		OUT	NOCOPY NUMBER,
				p_bill_app_code		IN	VARCHAR2,
				p_org_id	IN	NUMBER,
				p_cat_set_id	IN	NUMBER,
				p_cat_id	IN	NUMBER,
				p_from_date	IN	VARCHAR2);


END xnb_item_batch_pvt;

 

/
