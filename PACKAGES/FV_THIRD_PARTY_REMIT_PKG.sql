--------------------------------------------------------
--  DDL for Package FV_THIRD_PARTY_REMIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_THIRD_PARTY_REMIT_PKG" AUTHID CURRENT_USER AS
/* $Header: FVTPREMS.pls 120.0 2003/09/15 21:37:40 snama noship $ */

PROCEDURE MAIN (x_errbuf        OUT NOCOPY VARCHAR2,
	        x_retcode       OUT NOCOPY NUMBER,
		p_pay_date_from		   VARCHAR2,
		p_pay_date_to		   VARCHAR2,
	        p_checkrun_name            VARCHAR2,
		p_from_supp_id		   NUMBER,
		p_from_supp_site_id	   NUMBER,
		p_to_supp_id		   NUMBER,
		p_to_supp_site_id	   NUMBER,
		p_sort_by		   VARCHAR2);

END FV_THIRD_PARTY_REMIT_PKG;

 

/
