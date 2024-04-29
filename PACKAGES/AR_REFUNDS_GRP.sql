--------------------------------------------------------
--  DDL for Package AR_REFUNDS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_REFUNDS_GRP" AUTHID CURRENT_USER AS
/* $Header: ARXGREFS.pls 120.0 2006/01/10 21:25:31 jbeckett noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
  G_PKG_NAME           CONSTANT VARCHAR2(30):= 'AR_REFUNDS_GRP';

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE subscribeto_invoice_event
 |
 | DESCRIPTION
 |      ----------------------------------------
 |      This procedure calls activity_unapplication for receipt or credit memo
 |      - for use by AP when a payment request is cancelled outside AR
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date        Author   Description of Changes
 | 06-JAN-2006 JBECKETT Created
 |
 *=======================================================================*/
PROCEDURE subscribeto_invoice_event(
		 p_event_type			IN  VARCHAR2
		,p_invoice_id			IN  NUMBER
		,p_return_status		OUT NOCOPY VARCHAR2
		,p_msg_count			OUT NOCOPY NUMBER
		,p_msg_data			OUT NOCOPY VARCHAR2);

END AR_REFUNDS_GRP;

 

/
