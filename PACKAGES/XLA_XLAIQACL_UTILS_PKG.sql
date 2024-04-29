--------------------------------------------------------
--  DDL for Package XLA_XLAIQACL_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_XLAIQACL_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlafuacl.pkh 120.1 2004/02/13 22:51:40 weshen noship $ */

-- ************************************************************************
-- PUBLIC VARIABLES/TYPES
-- ************************************************************************

--
-- Accounting Methods record type
--
TYPE acct_method_info_rec IS RECORD (
                accounting_method 	VARCHAR2(30),
		sob_id            	NUMBER(15),
                sob_curr     		VARCHAR2(15),
                sob_type          	VARCHAR2(1),
                sob_name          	VARCHAR2(30),
                sob_short_name          VARCHAR2(20),
                accounting_method_name  VARCHAR2(80));

TYPE acct_method_info_tbl IS TABLE OF acct_method_info_rec
            INDEX BY BINARY_INTEGER;


-- ************************************************************************
-- PUBLIC PROCEDURES
-- ************************************************************************
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calc_sums                                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Calculates dr and cr totals either for given transaction or for the     |
 |   passed where clause for given application. The function totals the lines|
 |   from the view name passed in. 					     |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    none                                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id      -- E.g 222 for Receivables        |
 |                   p_trx_hdr_table       -- Transaction header table       |
 |		     p_trx_hdr_id          -- Transaction header id          |
 |		     p_cost_type_id        -- Cost Type Id (Mfg PAC trx)     |
 |                   p_ovr_where_clause    -- Overriding where clause        |
 |                   p_view_name    	   -- View Name                      |
 |                   p_add_col_name_1      -- Additional Column 1            |
 |                   p_add_col_value_1     -- Value of Additional Column 1   |
 |                   p_add_col_name_2      -- Additional Column 2            |
 |                   p_add_col_value_2     -- Value of Additional Column 2   |
 |              OUT: x_total_entered_dr                                      |
 |                   x_total_entered_cr                                      |
 |		     x_total_accounted_dr                                    |
 |		     x_total_accounted_cr                                    |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-Nov-98  Heli Lankinen       Created                                |
 |     04-Aug-99  Mahesh Sabapthy       Added parameter cost_type_id to      |
 |                                      support Mfg. PAC transactions.       |
 |                                                                           |
 +===========================================================================*/

PROCEDURE CALC_SUMS (
        p_application_id        IN      NUMBER,
        p_set_of_books_id       IN      NUMBER,
        p_trx_hdr_table         IN      VARCHAR2,
        p_trx_hdr_id            IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_ovr_where_clause      IN      VARCHAR2,
        p_view_name             IN      VARCHAR2,
        p_add_col_name_1        IN      VARCHAR2,
        p_add_col_value_1       IN      VARCHAR2,
        p_add_col_name_2        IN      VARCHAR2,
        p_add_col_value_2       IN      VARCHAR2,
        x_total_entered_dr      OUT NOCOPY     NUMBER,
        x_total_entered_cr      OUT NOCOPY     NUMBER,
        x_total_accounted_dr    OUT NOCOPY     NUMBER,
        x_total_accounted_cr    OUT NOCOPY     NUMBER );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_acct_method_info                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets the accounting methods and set of books info associated with the   |
 |   accounting method for a given application.                              |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    none                                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id      -- E.g 200 for Payables           |
 |              OUT: x_acct_method_info                                      |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Apr-99  Mahesh Sabapathy    Created                                |
 +===========================================================================*/
PROCEDURE get_acct_method_info (
        p_application_id        IN      NUMBER,
	x_acct_method_info	OUT NOCOPY	acct_method_info_tbl );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_acct_method_info_scalar                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets the accounting methods and set of books info associated with the   |
 |   accounting method for a given application.                              |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                    |
 |    none                                                                   |
 |                                                                           |
 | ARGUMENTS  : IN:  p_application_id      -- E.g 200 for Payables           |
 |              OUT:                                                         |
 |                   acct_method_n                                           |
 |                   sob_id_n                                                |
 |                   sob_curr_n                                              |
 |                   sob_type_n                                              |
 |                   sob_name_n                                              |
 |                   sob_short_name_n                                        |
                     acct_method_name_n
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-Apr-99  Mahesh Sabapathy    Created                                |
 +===========================================================================*/
PROCEDURE get_acct_method_info_scalar (
        p_application_id        IN      NUMBER,
 	x_acct_method_1    	OUT NOCOPY	VARCHAR2,
 	x_sob_id_1        	OUT NOCOPY	NUMBER,
 	x_sob_curr_1     	OUT NOCOPY	VARCHAR2,
 	x_sob_type_1    	OUT NOCOPY	VARCHAR2,
 	x_sob_name_1   		OUT NOCOPY	VARCHAR2,
 	x_sob_short_name_1 	OUT NOCOPY	VARCHAR2,
 	x_acct_method_name_1	OUT NOCOPY	VARCHAR2,
 	x_acct_method_2    	OUT NOCOPY	VARCHAR2,
 	x_sob_id_2        	OUT NOCOPY	NUMBER,
 	x_sob_curr_2     	OUT NOCOPY	VARCHAR2,
 	x_sob_type_2    	OUT NOCOPY	VARCHAR2,
 	x_sob_name_2   		OUT NOCOPY	VARCHAR2,
 	x_sob_short_name_2 	OUT NOCOPY	VARCHAR2,
 	x_acct_method_name_2	OUT NOCOPY	VARCHAR2);

END XLA_XLAIQACL_UTILS_PKG;

 

/
