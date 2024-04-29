--------------------------------------------------------
--  DDL for Package ARP_CORRECT_CCID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_CORRECT_CCID" AUTHID CURRENT_USER AS
/* $Header: ARCCCIDS.pls 120.1 2004/12/03 01:17:07 orashid noship $ */

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE Correct_Lines_CCID
 |
 | DESCRIPTION
 |     This procedure will correct all the specific lines that have been
 |     choosen for correction.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and cuntions which
 |      this package calls.
 |
 | PARAMETERS
 |      p_distribution_id  IN      This will be the primary key of
 |                                 the table we will be updating.
 |      p_old_ccid         IN      This is the CCID which is invalid and
 |                                 must be replaced.
 |      p_new_ccid         IN      This is the CCID that the user has
 |                                 choosen to replace the invalid CCID
 |      p_category_type    IN      Type of trx we are processing
 |      p_dist_type        IN      Distribution Type
 |      p_parent_id        IN      primary key of parent table
 |      p_source_table     IN      Code for parent id source table.
 |
 | KNOWN ISSUES
 |      Enter business functionality which was de-scoped as part of the
 |      implementation. Ideally this should never be used.
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                 Author                  Description of Changes
 | 10-Nov-2003          Debbie Sue Jancis       Created
 *=======================================================================*/
PROCEDURE Correct_Lines_CCID (   p_distribution_id   IN  NUMBER,
                                 p_old_ccid          IN  NUMBER,
                                 p_new_ccid          IN  NUMBER,
                                 p_category_type     IN  VARCHAR2,
                                 p_dist_type         IN VARCHAR2,
                                 p_parent_id         IN NUMBER,
                                 p_source_table   IN VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDURE lock_and_update
 |
 | DESCRIPTION
 |      This procedure will take an invalid CCID and lock and update all
 |      rows in the ar_ccid_corrections table.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      This is called from the form ARXGLCOR.fmb
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_old_ccid      IN  OLD CCID
 |      p_new_ccid_id   IN  NEW CCID to be replaced.
 |      p_category_type IN  Transaction Code
 |      p_dist_type     IN  Distribution code
 |      p_seq_id        IN  Submission id generated from sequence
 |
 | KNOWN ISSUES
 |      none
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 17-Nov-2003           Debbie Sue Jancis Created
 *=======================================================================*/
PROCEDURE lock_and_update ( p_old_ccid       IN  NUMBER,
                            p_new_ccid       IN  NUMBER,
                            p_category_type  IN  VARCHAR2,
                            p_dist_type      IN  VARCHAR2,
                            p_seq_id         IN  NUMBER);

/*========================================================================
 | PUBLIC PROCEDURE Correct_All_Invalid_CCID
 |
 | DESCRIPTION
 |      This procedure will take an invalid CCID and do a global replacement
 |      in all tables, with a new Valid CCID in order to enable records
 |      to post.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |      Enter a list of all local procedures and functions which
 |      are call this package.
 |
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |      p_parameter1    IN      Description of usage
 |
 | KNOWN ISSUES
 |      Enter business functionality which was de-scoped as part of the
 |      implementation. Ideally this should never be used.
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 10-Nov-2003           Debbie Sue Jancis Created
 *=======================================================================*/
PROCEDURE Correct_All_Invalid_CCID(p_errbuff OUT NOCOPY VARCHAR2,
                                   p_retcode OUT NOCOPY NUMBER,
                                   p_submission_id IN number);

END ARP_CORRECT_CCID;

 

/
