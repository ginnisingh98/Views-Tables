--------------------------------------------------------
--  DDL for Package JAI_AR_CR_TRIGGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_CR_TRIGGER_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_arcr_trg_pkg.pls 120.0.12000000.1 2007/07/24 06:55:38 rallamse noship $ */

	t_rec	ar_cash_receipts_all%ROWTYPE;
	PROCEDURE ARI_T1 			 (pr_old		IN	t_rec%type ,
						  pr_new		IN	t_rec%type ,
						  pv_action		IN	VARCHAR2 ,
						  pv_return_code	OUT	NOCOPY VARCHAR2 ,
						  pv_return_message	OUT	NOCOPY VARCHAR2 );

	PROCEDURE ARU_T1 			 (pr_old		IN	t_rec%type ,
						  pr_new 		IN	t_rec%type ,
						  pv_action 		IN	VARCHAR2 ,
						  pv_return_code 	OUT NOCOPY VARCHAR2 ,
						  pv_return_message 	OUT NOCOPY VARCHAR2 );

	PROCEDURE ARD_T1 			 (pr_old 		IN	t_rec%type ,
						  pr_new 		IN	t_rec%type ,
						  pv_action 		IN	VARCHAR2 ,
						  pv_return_code 	OUT NOCOPY VARCHAR2 ,
						  pv_return_message 	OUT NOCOPY VARCHAR2 );

END;
 

/
