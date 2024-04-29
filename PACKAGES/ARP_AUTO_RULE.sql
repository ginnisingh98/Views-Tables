--------------------------------------------------------
--  DDL for Package ARP_AUTO_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AUTO_RULE" AUTHID CURRENT_USER AS
/* $Header: ARPLARLS.pls 120.2.12010000.2 2008/11/13 20:11:20 mraymond ship $ */

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |                                                                         |
 |    create_distributions                                                 |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This function will generate General Ledger distributions for all     |
 |    transaction lines that have model accounts and have incomplete       |
 |    autorule expansions against them.                                    |
 |                                                                         |
 | REQUIRES                                                                |
 |    user_id           AOL who information                                |
 |    request_id                                                           |
 |    program_application_id                                               |
 |    program_id                                                           |
 |                                                                         |
 | RETURNS                                                                 |
 |    n      Count of number of rows inserted                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-Jan-93  Nigel Smith        Created.                               |
 |    21-Feb-93  Nigel Smith        Updated to interface with PL/SQL 1     |
 |    15-MAY-02  Michael Raymond    Bug 2150541 - added p_suppress_round
 |                                  to create_distributions for diagnostic
 |                                  purposes.  During normal execution, this
 |                                  parameter will always be null.
 |    08-JUL-02  Michael Raymond    Bug 2399504 - Added p_continue_on_error
 |                                  parameter to create_distributions for
 |                                  diagnostic purposes.  During normal
 |                                  execution, this parameter will always
 |                                  be null.  When this parameter is not
 |                                  null, Revenue Recognition will rollback
 |                                  each bad transaction - but it will
 |                                  process all good ones to completion.
 +-------------------------------------------------------------------------*/


FUNCTION create_distributions(p_commit IN VARCHAR2,
                              p_debug  IN VARCHAR2,
                              p_trx_id IN NUMBER DEFAULT NULL,
                              p_suppress_round IN VARCHAR2 DEFAULT NULL,
                              p_continue_on_error IN VARCHAR2 DEFAULT NULL)
	 RETURN NUMBER;

PROCEDURE refresh (Errbuf  OUT NOCOPY VARCHAR2,
                   Retcode OUT NOCOPY VARCHAR2);

FUNCTION assign_gl_date(p_gl_date IN DATE)

	 RETURN DATE;


FUNCTION assign_gl_rec(p_gl_date IN DATE)

         RETURN DATE;

/* 7131147 - needed in AREBTSRB.pls */
FUNCTION create_other_tax(p_trx_id IN NUMBER,
                          p_base_precision IN NUMBER,
                          p_bmau IN NUMBER,
                          p_ignore_rule_flag IN VARCHAR2 DEFAULT NULL)
         RETURN NUMBER;

END ARP_AUTO_RULE;

/
