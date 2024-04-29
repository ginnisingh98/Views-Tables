--------------------------------------------------------
--  DDL for Package CE_BANK_GROUPINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BANK_GROUPINGS" AUTHID CURRENT_USER AS
/*$Header: cebugrps.pls 120.1 2005/02/02 23:05:49 eliu noship $

  /*========================================================================+
   | PUBLIC PROCEDURE                                                       |
   |   grouping                                                     	    |
   |                                                                        |
   | DESCRIPTION                                                            |
   |   Main procedure of the bank grouping program.  This program can group |
   |   bank data for BANK, BRANCH, or ACCOUNT level as requested.           |
   |                                                                        |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                 |
   |                                                                        |
   | ARGUMENTS                                                              |
   |   IN:                                                                  |
   |     p_bank_entity_type    Bank entity type for this program run.       |
   |     p_display_debug       Debug message flag (Y/N)                     |
   |     p_debug_path          Debug path name if specified                 |
   |     p_debug_file          Debug file name if specified                 |
   +========================================================================*/
   PROCEDURE grouping (errbuf        OUT NOCOPY     VARCHAR2,
                       retcode       OUT NOCOPY     NUMBER,
                       p_bank_entity_type           VARCHAR2,
                       p_display_debug              VARCHAR2,
                       p_debug_path                 VARCHAR2,
                       p_debug_file                 VARCHAR2);

END CE_BANK_GROUPINGS;

 

/
