--------------------------------------------------------
--  DDL for Package FA_C_INSURE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_C_INSURE" AUTHID CURRENT_USER as
/* $Header: faxinsus.pls 120.2.12010000.2 2009/07/19 10:29:42 glchen ship $ */


PROCEDURE insurance      (   Errbuf                    OUT NOCOPY VARCHAR2,
                        Retcode                   OUT NOCOPY NUMBER,
			P_Asset_book		  VARCHAR2,
			P_Year			  VARCHAR2,
			P_Ins_company_id	  NUMBER,
			P_Asset_start		  VARCHAR2,
			P_Asset_end		  VARCHAR2);
END FA_C_INSURE;

/
