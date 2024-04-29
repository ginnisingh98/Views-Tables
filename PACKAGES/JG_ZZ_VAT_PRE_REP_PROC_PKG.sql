--------------------------------------------------------
--  DDL for Package JG_ZZ_VAT_PRE_REP_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_VAT_PRE_REP_PROC_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzprps.pls 120.0.12010000.1 2008/11/14 13:01:41 spasupun noship $ */

-----------------------------------------
--Public Methods Declarations
-----------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Main                                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This is the main procedure of the JG_ZZ_VAT_SELECTION_PKG, which       |
 |    populates tax data into JG_ZZ_TRX_DETAILS tables                       |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 +===========================================================================*/

 PROCEDURE main( errbuf                       OUT NOCOPY VARCHAR2,
                 retcode                      OUT NOCOPY NUMBER,
		 p_reporting_level            IN jg_zz_vat_rep_entities.entity_level_code%TYPE,
		 p_vat_reporting_entity_id    IN jg_zz_vat_rep_entities.vat_reporting_entity_id%TYPE,
                 p_chart_of_account_id        IN NUMBER,
                 p_bsv                        IN jg_zz_vat_rep_entities.balancing_segment_value%TYPE,
		 p_period                     IN jg_zz_vat_rep_status.tax_calendar_period%TYPE
                 );




FUNCTION GET_BSV(p_ccid number,p_chart_of_accounts_id number,p_ledger_id number) RETURN VARCHAR2;

END JG_ZZ_VAT_PRE_REP_PROC_PKG;

/
