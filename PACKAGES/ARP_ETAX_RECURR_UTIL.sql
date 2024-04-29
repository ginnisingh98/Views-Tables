--------------------------------------------------------
--  DDL for Package ARP_ETAX_RECURR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_ETAX_RECURR_UTIL" AUTHID CURRENT_USER AS
/* $Header: AREBTICS.pls 120.0.12010000.2 2008/11/14 09:10:46 amitshuk ship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/
--    temp_variable1 VARCHAR2(10);

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/
--    temp_exception EXCEPTION;

/*========================================================================
 | PUBLIC PROCEDURE populate_ebt_gt
 |
 | DESCRIPTION
 |    This procedure populates the ebt GT tables that are used by
 |    autoinvoice for tax calculations.  The procedure will be called
 |    twice - once for INV and a second time for CM (regular) data.
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_request_id    IN      Request_id of import job
 |      p_phase         IN      Indicates 'INV' or 'CM' phase
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-FEB-2005           MRAYMOND          Created
 |
 *=======================================================================*/
PROCEDURE calculate_tax(
                p_request_id  IN  NUMBER,
                p_error_count IN OUT NOCOPY NUMBER,
                p_return_status OUT NOCOPY NUMBER);


PROCEDURE insert_tax_lines(p_original_line_id     IN NUMBER,
                           p_new_customer_trx_id  IN NUMBER,
                           p_new_line_id          IN NUMBER,
                           p_request_id           IN NUMBER);


PROCEDURE insert_header(p_customer_trx_id         IN NUMBER);

PROCEDURE insert_line(p_orig_line_id              IN NUMBER,
                      p_new_line_id               IN NUMBER);

END ARP_ETAX_RECURR_UTIL;


/
