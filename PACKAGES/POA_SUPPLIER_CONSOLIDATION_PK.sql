--------------------------------------------------------
--  DDL for Package POA_SUPPLIER_CONSOLIDATION_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_SUPPLIER_CONSOLIDATION_PK" AUTHID CURRENT_USER AS
/* $Header: poaspcos.pls 115.3 2002/12/27 21:29:47 iali ship $ */


PROCEDURE calculate_savings
 		(p_item_id		IN  NUMBER,
		  p_pref_supplier_id	IN  NUMBER,
		  p_cons_supplier_id	IN  NUMBER,
		  p_defect_cost		IN  NUMBER,
		  p_del_excp_cost	IN  NUMBER,
		  p_currency_code	IN  VARCHAR2,
		  p_start_date		IN  DATE,
		  p_end_date		IN  DATE,
		  p_user_id		IN  NUMBER,
		  p_bucket_type		IN  NUMBER,
		 p_price_savings	OUT NOCOPY NUMBER,
		 p_quality_savings	OUT NOCOPY NUMBER,
		 p_delivery_savings	OUT NOCOPY NUMBER,
		 p_total_savings	OUT NOCOPY NUMBER);

END poa_supplier_consolidation_pk;

 

/
