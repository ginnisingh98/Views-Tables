--------------------------------------------------------
--  DDL for Package Body ARP_CORRECT_CCID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CORRECT_CCID" AS
/* $Header: ARCCCIDB.pls 120.2 2005/07/22 00:45:12 hyu noship $ */

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

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
 | Date                 Author            	Description of Changes
 | 10-Nov-2003		Debbie Sue Jancis	Created
 *=======================================================================*/
PROCEDURE Correct_Lines_CCID (   p_distribution_id   IN  NUMBER,
                                 p_old_ccid          IN  NUMBER,
                                 p_new_ccid          IN  NUMBER,
                                 p_category_type     IN  VARCHAR2,
                                 p_dist_type         IN VARCHAR2,
                                 p_parent_id         IN NUMBER,
                                 p_source_table      IN VARCHAR2   ) IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_CORRECT_CCID.Correct_Lines_CCID()+');
      arp_standard.debug(' p_distribution_id :' || to_char(p_distribution_id));
      arp_standard.debug(' p_old_ccid :' || to_char(p_old_ccid));
      arp_standard.debug(' p_new_ccid :' || to_char(p_new_ccid));
      arp_standard.debug(' p_category_type :' || p_category_type);
      arp_standard.debug(' p_dist_type:' || p_dist_type);
      arp_standard.debug(' p_parent_id:' || to_char(p_parent_id));
      arp_standard.debug(' p_source_table: ' || p_source_table);
   END IF;

   /* should we initialize arp_global before use?? */
--   arp_global.init;

  /* based upon parameters coming in, we have to update specific tables
     to correct the CCID.   The tables will be determined by several
     Columns */

     /* if we are dealing with GL DIST Records */
     IF (p_source_table = 'GLD') THEN

        /* update the distribution record */
        UPDATE  RA_CUST_TRX_LINE_GL_DIST
           SET code_combination_id = nvl(p_new_ccid, code_combination_id),
               last_update_date = SYSDATE,
               last_updated_by = arp_global.last_updated_by,
               last_update_login = arp_global.last_update_login
         WHERE
               cust_trx_line_gl_dist_id = p_distribution_id
           AND code_combination_id = p_old_ccid;


      ELSE

        /* we need to update ar_distributions */

        update AR_DISTRIBUTIONS
           SET code_combination_id = NVL( p_new_ccid, code_combination_id),
               last_update_date = sysdate,
               last_updated_by = arp_global.last_updated_by,
               last_update_login = arp_global.last_update_login
         WHERE code_combination_id = p_old_ccid
               and line_id = p_distribution_id;

        IF ( p_source_table = 'ADJ' and p_dist_type = 'ADJ' ) THEN
            /* We need to update the parent record if the distribution
               type is ADJ  */

           update AR_ADJUSTMENTS
              SET code_combination_id = NVL(p_new_ccid, code_combination_id),
                  last_update_date = sysdate,
                  last_updated_by = arp_global.last_updated_by,
                  last_update_login = arp_global.last_update_login
            WHERE adjustment_id = p_parent_id
            AND code_combination_id = p_old_ccid;
        END IF;

        IF (p_source_table = 'MCD' and p_dist_type = 'MISCCASH')  then
           UPDATE AR_MISC_CASH_DISTRIBUTIONS
           SET  code_combination_id = NVL(p_new_ccid, code_combination_id),
                last_update_date = SYSDATE,
                last_updated_by = arp_global.last_updated_by,
                last_update_login = arp_global.last_update_login
           where misc_cash_distribution_id = p_parent_id
             and code_combination_id = p_old_ccid;
        END IF;

       IF (p_source_table = 'CRH' and p_dist_type ='CASH') THEN
          UPDATE AR_CASH_RECEIPT_HISTORY
             SET  account_code_combination_id = NVL(p_new_ccid,
                                                account_code_combination_id),
                  last_update_date = SYSDATE,
                  last_updated_by = arp_global.last_updated_by,
                  last_update_login = arp_global.last_update_login
           WHERE  account_code_combination_id = p_old_ccid
             AND  cash_Receipt_history_id = p_parent_id
             AND  current_record_flag = 'Y';
       END IF;
    END IF;

    /* delete from the interim table */
    DELETE FROM AR_CCID_CORRECTIONS
    WHERE code_combination_id = p_old_ccid
      AND distribution_type = p_dist_type
      AND category_type = p_category_type
      AND distribution_id = p_distribution_id
      AND source_table = p_source_table
      AND submission_id IS NULL;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_CORRECT_CCID.Correct_Lines_CCID()-');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_CORRECT_CCID.Correct_Lines_CCID()');
     END IF;
     RAISE;

END Correct_Lines_CCID;

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
 |
 | KNOWN ISSUES
 |      none
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
                            p_dist_type      IN VARCHAR2,
                            p_seq_id         IN NUMBER) IS

  l_status_code  CONSTANT VARCHAR2(20) := 'IN_PROGRESS';

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' ARP_CORRECT_CCID.lock_and_update()+');
      arp_standard.debug(' p_old_ccid :' || to_char(p_old_ccid));
      arp_standard.debug(' p_new_ccid :' || to_char(p_new_ccid));
      arp_standard.debug(' p_category_type :' || p_category_type);
      arp_standard.debug(' p_dist_type:' || p_dist_type);
   END IF;

 /*---------------------------------------------------------------------+
  | Undate rows with the new CCID based on the old ccid, trx code and   |
  | distribution code.                                                  |
  +---------------------------------------------------------------------*/

   Update AR_CCID_CORRECTIONS
     set NEW_CODE_COMBINATION_ID = p_new_ccid,
         submission_id = p_seq_id
   WHERE
        code_combination_id = p_old_ccid and
        distribution_type = p_dist_type and
        category_type = p_category_type;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' ARP_CORRECT_CCID.lock_and_update()-');
   END IF;

EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_CORRECT_CCID.lock_and_update()');
     END IF;
     RAISE;

END lock_and_update;


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
 |      p_submission_id   IN   Unique identifier for all rows in
 |                             this particular submission
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
 | 10-Nov-2003 		 Debbie Sue Jancis Created
 *=======================================================================*/
PROCEDURE Correct_All_Invalid_CCID(p_errbuff OUT NOCOPY varchar2,
                                   p_retcode OUT NOCOPY number,
                                   p_submission_id IN NUMBER) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' ARP_CORRECT_CCID.Correct_All_Invalid_CCID()+');
      arp_standard.debug(' p_submission_id :' || p_submission_id);
   END IF;

   /* Correct GL_DIST ccids */
   UPDATE RA_CUST_TRX_LINE_GL_DIST gld
   SET last_update_date = SYSDATE,
       last_updated_by = arp_global.last_updated_by,
       last_update_login = arp_global.last_update_login,
       code_combination_id = (
     SELECT nvl(new_code_combination_id, code_combination_id)
     FROM   ar_ccid_corrections acc
     WHERE  acc.submission_id = p_submission_id
     AND    acc.source_table = 'GLD'
     AND    acc.distribution_type = gld.account_class
     AND    acc.distribution_id   = gld.cust_trx_line_gl_dist_id)
   WHERE  gld.cust_trx_line_gl_dist_id in (
     SELECT distribution_id
     FROM   ar_ccid_corrections
     WHERE  submission_id = p_submission_id
     AND    source_table = 'GLD');

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' ra_cust_trx_line_gl_dist rows updated: ' ||
              SQL%ROWCOUNT);
   END IF;

   /* Correct AR_DISTRIBUTION ccids */
   UPDATE AR_DISTRIBUTIONS ard
   SET  last_update_date = SYSDATE,
        last_updated_by = arp_global.last_updated_by,
        last_update_login = arp_global.last_update_login,
        code_combination_id = (
     SELECT nvl(new_code_combination_id, code_combination_id)
     FROM   ar_ccid_corrections acc
     WHERE  acc.submission_id = p_submission_id
     AND    acc.distribution_id = ard.line_id
     AND    acc.source_table = ard.source_table
     AND    acc.distribution_type = ard.source_type)
   WHERE  ard.line_id in (
     SELECT distribution_id
     FROM   ar_ccid_corrections
     WHERE  submission_id = p_submission_id
     AND    source_table IN ('ADJ','CRH','RA','MCD','TH'));

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' ar_distribution rows updated: ' ||
              SQL%ROWCOUNT);
   END IF;

   /* correct parent ADJ records */
   UPDATE AR_ADJUSTMENTS adj
   SET      last_update_date = SYSDATE,
            last_updated_by = arp_global.last_updated_by,
            last_update_login = arp_global.last_update_login,
            code_combination_id = (
     SELECT nvl(new_code_combination_id, code_combination_id)
     FROM   ar_ccid_corrections acc
     WHERE  acc.submission_id = p_submission_id
     AND    acc.source_table = 'ADJ'
     AND    acc.distribution_type = 'ADJ'
     AND    acc.parent_id = adj.adjustment_id)
   WHERE adj.adjustment_id in (
     SELECT parent_id
     FROM   ar_ccid_corrections
     WHERE  submission_id = p_submission_id
     AND    source_table = 'ADJ'
     AND    distribution_type = 'ADJ');

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('   ar_adjustments rows updated: ' ||
              SQL%ROWCOUNT);
   END IF;

   /* correct parent CRH records */
   UPDATE AR_CASH_RECEIPT_HISTORY crh
   SET      last_update_date = SYSDATE,
            last_updated_by = arp_global.last_updated_by,
            last_update_login = arp_global.last_update_login,
            account_code_combination_id = (
     SELECT nvl(new_code_combination_id, account_code_combination_id)
     FROM   ar_ccid_corrections acc
     WHERE  acc.submission_id = p_submission_id
     AND    acc.source_table = 'CRH'
     AND    acc.distribution_type = 'CASH'
     AND    acc.parent_id = crh.cash_receipt_history_id)
   WHERE crh.cash_receipt_history_id in (
     SELECT parent_id
     FROM   ar_ccid_corrections
     WHERE  submission_id = p_submission_id
     AND    source_table = 'CRH'
     AND    distribution_type = 'CASH');

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('   ar_cash_receipt_history rows updated: ' ||
              SQL%ROWCOUNT);
   END IF;

   /* correct parent MCD records */
   UPDATE AR_MISC_CASH_DISTRIBUTIONS mcd
   SET      last_update_date = SYSDATE,
            last_updated_by = arp_global.last_updated_by,
            last_update_login = arp_global.last_update_login,
            code_combination_id = (
     SELECT nvl(new_code_combination_id, code_combination_id)
     FROM   ar_ccid_corrections acc
     WHERE  acc.submission_id = p_submission_id
     AND    acc.source_table = 'MCD'
     AND    acc.distribution_type = 'MISCCASH'
     AND    acc.parent_id = mcd.misc_cash_distribution_id)
   WHERE misc_cash_distribution_id in (
     SELECT parent_id
     FROM   ar_ccid_corrections
     WHERE  submission_id = p_submission_id
     AND    source_table = 'MCD'
     AND    distribution_type = 'MISCCASH');

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('   ar_misc_cash_distributions rows updated: ' ||
              SQL%ROWCOUNT);
      arp_standard.debug(' ARP_CORRECT_CCID.Correct_All_Invalid_CCID()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_CORRECT_CCID.Correct_All_Invalid_CCID()');
     END IF;

END Correct_All_Invalid_CCID;


END ARP_CORRECT_CCID;

/
