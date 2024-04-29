--------------------------------------------------------
--  DDL for Package CE_BAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BAL_UTIL" AUTHID CURRENT_USER AS
/*$Header: cebaluts.pls 120.2 2005/10/07 18:42:52 xxwang noship $ */

  TYPE t_date_table IS TABLE OF ce_t_date;

  TYPE t_balance_table IS TABLE OF ce_t_balance;


   TYPE acct_id_refcursor IS REF CURSOR RETURN ce_cashpool_sub_accts%ROWTYPE;

   /*=======================================================================+
   | PUBLIC FUNCTION get_date_range                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   A pipelined function to return all the days between a date range.   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_start_date               Start Date.                            |
   |     p_end_date                 End Date.                              |
   |   OUT:                                                                |
   |                                                                       |
   | RETURN                                                                |
   |   A table of days within the range.                                   |
   | MODIFICATION HISTORY                                                  |
   |   03-FEB-2004    Xin Wang           Created.                          |
   +=======================================================================*/

   FUNCTION get_date_range(p_start 	IN  DATE,
                           p_end 	IN  DATE)  RETURN t_date_table PIPELINED;


   FUNCTION get_balance(p_date		IN  DATE,
		        p_accts		IN  acct_id_refcursor) RETURN t_balance_table PIPELINED;


   FUNCTION get_pool_balance (p_cashpool_id      IN  NUMBER,
                              p_balance_date     IN  DATE)  RETURN NUMBER;

END ce_bal_util;

 

/
