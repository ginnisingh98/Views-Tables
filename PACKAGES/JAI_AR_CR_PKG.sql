--------------------------------------------------------
--  DDL for Package JAI_AR_CR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AR_CR_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_ar_cr_pkg.pls 120.1.12000000.1 2007/07/24 06:55:23 rallamse noship $ */
	PROCEDURE process_cm_dm(p_event		IN		VARCHAR2,
				p_new		IN		ar_cash_receipts_all%ROWTYPE,
				p_old		IN		ar_cash_receipts_all%ROWTYPE,
				p_process_flag	OUT NOCOPY	VARCHAR2,
				p_process_message OUT NOCOPY	VARCHAR2);
END;
 

/
