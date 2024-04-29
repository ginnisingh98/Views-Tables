--------------------------------------------------------
--  DDL for Package ARP_PROCESS_PAYINFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_PAYINFO" AUTHID CURRENT_USER AS
/*$Header: ARPPYMTSS.pls 120.0 2005/09/02 19:33:06 ralat noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/


/*========================================================================
 | Procedure ai_batch()
 |
 | DESCRIPTION
 |      Process Payment information of Invoices from AutoInvoice batch
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 25-AUG-2005           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE copy_payment_ext_id;

/*========================================================================
 | Procedure default_payment_attributes()
 |
 | DESCRIPTION
 |      This procedure deaults the payment_attributes for transaction
 |      grouping
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 28-Aug-2005           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE default_payment_attributes;

/*========================================================================
 | Procedure validate_payment_ext_id()
 |
 | DESCRIPTION
 |      This procedure validate ext id
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |
 | RETURNS
 |      nothing
 |
 | KNOWN ISSUES
 |
 |
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author           Description of Changes
 | 28-Aug-2005           Ramakant Alat    Created
 |
 *=======================================================================*/
PROCEDURE validate_payment_ext_id;

END ARP_PROCESS_PAYINFO;

 

/
