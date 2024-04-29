--------------------------------------------------------
--  DDL for Package PA_NL_INSTALLED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_NL_INSTALLED" AUTHID CURRENT_USER AS
/* $Header: PAXNLINS.pls 120.3 2006/04/10 16:22:14 dlanka ship $ */

/* Commenting out the global variable as it is not required any more.
 * For Bug 3441696
   g_nl_installed VARCHAR2(1) := 'X' ;
*/

  FUNCTION is_nl_installed RETURN VARCHAR2;
/* Commented the pragma for  3441696
PRAGMA RESTRICT_REFERENCES(is_nl_installed, WNDS);
*/
 PROCEDURE reverse_eib_ei(
    x_exp_item_id          IN  number,
    x_expenditure_id       IN  number,
    x_transfer_status_code IN  varchar2,
    x_status               OUT nocopy number);

END pa_nl_installed;

 

/
