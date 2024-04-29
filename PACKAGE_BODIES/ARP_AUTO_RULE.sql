--------------------------------------------------------
--  DDL for Package Body ARP_AUTO_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_AUTO_RULE" AS
/* $Header: ARPLARLB.pls 120.45.12010000.8 2010/04/26 20:27:06 mraymond ship $  */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

  cr    CONSTANT char(1) := '
';

/* GLOBAL declarations */

    /* 8206609 - Determines if the call is from an autoinvoice. */
    g_autoinv             BOOLEAN;
    g_autoinv_request_id  NUMBER;

TYPE gl_start_table_type IS TABLE OF
        gl_period_statuses.start_date%TYPE
     INDEX BY BINARY_INTEGER;

gl_start_t gl_start_table_type;

TYPE gl_end_table_type IS TABLE OF
        gl_period_statuses.end_date%TYPE
     INDEX BY BINARY_INTEGER;

gl_end_t gl_end_table_type;

TYPE gl_status_table_type IS TABLE OF
        gl_period_statuses.closing_status%TYPE
     INDEX BY BINARY_INTEGER;

gl_status_t gl_status_table_type;

TYPE gl_bump_table_type IS TABLE OF
        gl_period_statuses.start_date%TYPE
     INDEX BY BINARY_INTEGER;

gl_bump_t gl_bump_table_type;

g_rows          NUMBER;
glp_index_start NUMBER := 1;
glp_index_end   NUMBER;
glp_index_rec   NUMBER;

min_gl_date     DATE;
max_gl_date     DATE;
rec_gl_date     DATE;

org_id          NUMBER;
sob_id          NUMBER;
g_rev_mgt_installed  VARCHAR2(1); -- Bug 2560048
g_last_valid_date   DATE;         -- Bug 3879222
g_valid_start_index NUMBER;       -- Bug 3879222
g_use_inv_acctg     VARCHAR2(1);  -- 5598773

/* bug 4284925 : introduce a variable string which will hold various
   account_class values : REC, TAX, ROUND, FREIGHT which is used in multiple
   selects to avoid re-parsing similar statements
*/
acct_class      RA_CUST_TRX_LINE_GL_DIST.ACCOUNT_CLASS%TYPE;

/*-------------------------------------------------------------------------+
 | PRIVATE PROCEDURE                                                       |
 |   assign_glp_index                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Assigns the start and end indexes in the glp table for the least and  |
 |   greatest GL dates for the transaction. This will speed up the search  |
 |   for assigning the GL date for each revenue distribution.              |
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |   None.                                                                 |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 |   assign_glp_index;                                                     |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    26-AUG-98  Srini Jandyala     created.                               |
 +-------------------------------------------------------------------------*/

FUNCTION assign_glp_index RETURN NUMBER IS
 error_message FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE; -- bug 4194220
BEGIN
        arp_standard.debug('arp_auto_rule.assign_glp_index()+ ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));

        /* Set glp_index_start to the period having MIN GL date for the trx. */

        FOR i IN 1..g_rows
        LOOP

            IF ( min_gl_date >= gl_start_t(i) AND min_gl_date <= gl_end_t(i) )
            THEN
                glp_index_start := i;
                EXIT;
            END IF;

        END LOOP;

        /* Set glp_index_end to the period having MAX GL date for the trx. */

        FOR i IN glp_index_start..g_rows
        LOOP

            IF ( max_gl_date >= gl_start_t(i) AND max_gl_date <= gl_end_t(i) )
            THEN
                glp_index_end := i;
		EXIT;
            END IF;

        END LOOP;

        IF (glp_index_end IS NULL)
        THEN
            glp_index_end := g_rows;
        END IF;

        arp_standard.debug('glp table index start = '||glp_index_start||', end = '||glp_index_end);

	/* bug 3477990 */
	FOR i IN glp_index_start..glp_index_end
	LOOP
           IF gl_bump_t(i) IS NOT NULL
	   THEN
	      IF gl_bump_t.EXISTS(i-1)
	         AND
		 gl_bump_t(i-1) IS NULL
	      THEN
	         error_message := FND_MESSAGE.GET_STRING('AR','AR_RAXTRX-1783');
	         arp_standard.debug('Cannot process this transaction...');
	         arp_standard.debug('Closed or closed pending period exists at ' || i || 'with start date ' ||
			TO_CHAR( gl_start_t( i) , 'DD-MON-YY HH:MI:SS'));
	         arp_standard.debug(error_message);

	         RETURN -1;
	      END IF;
           END IF;
        END LOOP;

	RETURN 0;
        arp_standard.debug('arp_auto_rule.assign_glp_index()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));

END assign_glp_index;

/*-------------------------------------------------------------------------+
 | PRIVATE PROCEDURE                                                       |
 |   assign_glp_rec                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Assigns the index for the latest_rec_flag record                      |
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 | RETURNS                                                                 |
 |   None.                                                                 |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 |   assign_glp_rec;                                                       |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    10-FEB-99 Victoria Smith  Created                                    |
 +-------------------------------------------------------------------------*/
PROCEDURE assign_glp_rec IS

BEGIN
        arp_standard.debug('arp_auto_rule.assign_glp_rec()+ ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));

        /* Set glp_index_rec to the period having REC record's gl date */

        FOR i IN 1..g_rows
        LOOP

            IF ( rec_gl_date >= gl_start_t(i) AND rec_gl_date <= gl_end_t(i) )
            THEN
                glp_index_rec := i;
                EXIT;
            END IF;

        END LOOP;

        arp_standard.debug('glp table index rec = '||glp_index_rec);

        arp_standard.debug('arp_auto_rule.assign_glp_rec()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));

END assign_glp_rec;

/*-------------------------------------------------------------------------+
 | PRIVATE PROCEDURE                                                       |
 |   populate_glp_table                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Builds the GL periods table (PL/SQL).                                 |
 |                                                                         |
 |   The table has the following columns:                                  |
 |   start_date, end_date, closing_status, bump_date.                      |
 |                                                                         |
 |   This procedure is called by main

function create_distributions().     |
 |                                                                         |
 | PARAMETERS                                                              |
 |      p_sob     IN NUMBER,  - set_of_books_id                            |
 |      p_appl_id IN NUMBER   - application_id                             |
 |                                                                         |
 | RETURNS                                                                 |
 |      None.                                                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |   populate_glp_table(2, 222);                                           |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    20-MAR-98  Srinivasan Jandyala    Created.                           |
 |    03-DEC-01  M Raymond  - Bug 2133254 - rewrote logic to execute this
 |                            routine only the first time in.
 |                            Also eliminated
 |                            the inner SELECT with a pair of nested for
 |                            loops and some simple PLSQL code.
 |                            Finally, replaced FOR-SELECT structure with
 |                            modern CURSOR LOOP to reduce parsing.
 |    17-SEP-04  M Raymond  - Bug 3879222 - Moved call-once logic inside
 |                            this procedure to make it more useful to
 |                            external applications.
 +-------------------------------------------------------------------------*/

PROCEDURE populate_glp_table(
		p_sob     IN NUMBER,
		p_appl_id IN NUMBER) IS

   CURSOR c_gl_period_rec(v_sob NUMBER, v_appl_id NUMBER) IS
            SELECT
                   start_date,
                   end_date,
                   closing_status
            FROM
                   gl_period_statuses
            WHERE
                   application_id         = v_appl_id
            AND    set_of_books_id        = v_sob
            AND    adjustment_period_flag = 'N'
            ORDER BY
                   period_year,
                   period_num,
                   start_date,
                   end_date;

   last_good_date DATE;

BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('arp_auto_rule.populate_glp_table()+ ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  	   arp_standard.debug('Populating gl_period_statuses table.');
  	END IF;

   /* Bug 2133254 - only call this the first time in for a given SOB */
   /* Bug 3879222 - moved this logic inside the procedure */
   /* NOTE: sob_id is a global that gets set the first time it executes */
   IF (sob_id is null OR
       sob_id <> arp_standard.sysparm.set_of_books_id)
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'glp tables need to be built' ||
                           '   sob_id: ' || sob_id);
        END IF;

        sob_id := arp_standard.sysparm.set_of_books_id;

        /* Original logic starts here */
        g_rows := 0;

        FOR gl_period_rec IN c_gl_period_rec(p_sob, p_appl_id) LOOP

            g_rows              := g_rows + 1;
            gl_start_t(g_rows)  := gl_period_rec.start_date;
            gl_end_t(g_rows)    := gl_period_rec.end_date;
            gl_status_t(g_rows) := gl_period_rec.closing_status;
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Row ['|| g_rows ||']: Start Dt <'  ||
               gl_period_rec.start_date || '> End Date <' ||  gl_period_rec.end_date
               || '> Status <' || gl_period_rec.closing_status || '>');
            END IF;

        END LOOP;

        /* Determine bump dates for closed periods */
        FOR bump_pos IN REVERSE 1 .. g_rows LOOP

           IF    gl_status_t(bump_pos) = 'F' OR
                 gl_status_t(bump_pos) = 'O' OR
                 gl_status_t(bump_pos) = 'N'
           THEN
                 last_good_date := gl_start_t(bump_pos);
                 gl_bump_t(bump_pos) := null;
           ELSIF gl_status_t(bump_pos) = 'C' OR
                 gl_status_t(bump_pos) = 'W'
           THEN
                 gl_bump_t(bump_pos) := last_good_date;
           END IF;

        END LOOP;
        /* Original logic ends here */

   END IF; /* end of call-once case */

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('arp_auto_rule.populate_glp_table()- ');
        END IF;

END populate_glp_table;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   refresh                                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Updates ar_periods and ar_period_types tables with latest changes in  |
 |   gl_periods table.                                                     |
 |                                                                         |
 | PARAMETERS                                                              |
 |   INPUT                                                                 |
 |      None.                                                              |
 |                                                                         |
 |   OUTPUT                                                                |
 |      Errbuf                  VARCHAR2 -- Conc Pgm Error mesgs.          |
 |      RetCode                 VARCHAR2 -- Conc Pgm Error Code.           |
 |                                          0 - Success, 2 - Failure.      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |   refresh;                                                              |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   28-JUL-97  Srinivasan Jandyala    Created.                            |
 +-------------------------------------------------------------------------*/

PROCEDURE refresh (Errbuf  OUT NOCOPY VARCHAR2,
                   Retcode OUT NOCOPY VARCHAR2) IS
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(  'arp_auto_rule.refresh()+ ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  SAVEPOINT AR_PERIODS_1;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Updating ar_period_types: ');
  END IF;

  UPDATE  ar_period_types apt
  SET
          max_regular_period_length =
          (
           SELECT MAX(g.end_date - g.start_date) + 1
           FROM   gl_periods g
           WHERE  g.period_type            = apt.period_type
           AND    g.adjustment_period_flag = 'N'
          )
  WHERE
          max_regular_period_length <>
          (
           SELECT MAX(g.end_date - g.start_date) + 1
           FROM   gl_periods g
           WHERE  g.period_type            = apt.period_type
           AND    g.adjustment_period_flag = 'N'
          );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) updated: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug('Inserting into ar_period_types: ');
  END IF;

  INSERT
  INTO     ar_period_types
  ( period_type, max_regular_period_length )
  (
   SELECT
           g.period_type,
           MAX(g.end_date - g.start_date) + 1 max_regular_period_length
   FROM
           gl_periods g
   WHERE
           g.adjustment_period_flag = 'N'
   AND     NOT EXISTS
           (
            SELECT NULL
            FROM   ar_period_types apt
            WHERE  apt.period_type  = g.period_type
           )
   GROUP BY period_type
  );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) updated: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug('Deleting redundent ar_periods: ');
  END IF;

  DELETE
  FROM    ar_periods ap
  WHERE
          NOT EXISTS
          (
           SELECT NULL
           FROM   gl_periods gp
           WHERE  gp.period_name            = ap.period_name
           AND    gp.period_set_name        = ap.period_set_name
           AND    gp.adjustment_period_flag = 'N'
          );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) deleted: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug('Updating start, end dates in ar_periods: ');
  END IF;

  UPDATE  ar_periods ap
  SET
          (period_type, start_date, end_date) =
          (
           SELECT period_type, start_date, end_date
           FROM   gl_periods gp
           WHERE  gp.period_name      = ap.period_name
           AND    gp.period_set_name  = ap.period_set_name
          )
  WHERE
          EXISTS
          (
           SELECT NULL
           FROM   gl_periods gp
           WHERE
                  gp.period_name      = ap.period_name
           AND    gp.period_set_name  = ap.period_set_name
           AND    NOT (gp.period_type = ap.period_type AND
                       gp.start_date  = ap.start_date  AND
                       gp.end_date    = ap.end_date
		      )
          );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) updated: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug('Inserting into ar_periods: ');
  END IF;

  INSERT
  INTO    ar_periods
  (period_set_name , period_type, start_date, end_date,
   new_period_num, period_name
  )
  (SELECT
          period_set_name, period_type, start_date, end_date,
          9999 + ROWNUM new_period_num,
          period_name
   FROM
          gl_periods gp
   WHERE
          gp.adjustment_period_flag = 'N'
   AND    NOT EXISTS
          (
           SELECT NULL
           FROM   ar_periods ap
           WHERE  gp.period_name     = ap.period_name
           AND    gp.period_set_name = ap.period_set_name
          )
  );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) inserted: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug('Updating period sequence number in ar_periods: ');
  END IF;

  UPDATE  ar_periods p1
  SET
          new_period_num =
          (
           SELECT COUNT(*)
           FROM   ar_periods p2
           WHERE  p1.period_type     =  p2.period_type
           AND    p1.period_set_name =  p2.period_set_name
           AND    p1.start_date      >= p2.start_date
          )
  WHERE
          new_period_num <>
          (
           SELECT COUNT(*)
           FROM   AR_PERIODS p2
           WHERE  p1.period_type     =  p2.period_type
           AND    p1.period_set_name =  p2.period_set_name
           AND    p1.start_date      >= p2.start_date
          );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('row(s) updated: ' || TO_CHAR(sql%rowcount));
     arp_standard.debug(  'arp_auto_rule.refresh()- ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Exception occured in: arp_auto_rule.refresh()');
        END IF;

        ROLLBACK TO SAVEPOINT AR_PERIODS_1;
        RAISE;

END refresh;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   assign_gl_date                                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Check if GL date of a distribution is in a OPEN or FUTURE or          |
 |   NOT OPEN period.                                                      |
 |   If it is, then we shouldn't bump it. If the GL date is in a 'Closed'  |
 |   or 'Closed Pending' period, bump it to the next Open/Future/Not Open  |
 |   period.                                                               |
 |                                                                         |
 | PARAMETERS                                                              |
 |   p_gl_date  IN DATE,  - Rev distribution GL date                       |
 |                                                                         |
 | RETURNS                                                                 |
 |   p_gl_date, if GL date is in Open/Future/Not Open period               |
 |   bump_date, if GL date is in Closed/Close Pending period               |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |   assign_gl_date(to_date('01-JAN-1998', 'DD-MON-YYYY');                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   03-MAR-98  Srini Jandyala     Created.                                |
 |   28-FEB-03  M Raymond        Bug 2810336 - added debug messages to
 |                                 catch and document calendar gaps.
 |   17-SEP-04  M Raymond        Bug 3879222 - added call to
 |                                 populate_glp_table to allow this
 |                                 to be used outside of this package.
 +-------------------------------------------------------------------------*/

FUNCTION assign_gl_date(p_gl_date IN DATE)

         RETURN DATE IS

i  NUMBER;
l_temp_index NUMBER;

BEGIN
   /* Populate the GL periods PL/SQL table. */
   populate_glp_table(arp_standard.sysparm.set_of_books_id,
                      arp_standard.application_id);

   /* 3879222 - Added NVLs to accomodate external
       calls to this routine.  Also attempt to set
       a start index for subsequent calls */

   IF p_gl_date = g_last_valid_date
   THEN
      RETURN(p_gl_date);
   ELSIF p_gl_date > g_last_valid_date
   THEN
      /* Set a temp start index to bypass all the old periods */
      l_temp_index := g_valid_start_index;
   ELSE
      /* Set temp index to 1 (start from beginning of table) */
      l_temp_index := 1;
   END IF;

   FOR i IN NVL(glp_index_start,l_temp_index)..NVL(glp_index_end, g_rows)
   LOOP

      IF ( p_gl_date >= gl_start_t(i) AND p_gl_date <= gl_end_t(i) )
      THEN
	   IF (gl_status_t(i) IN ('O', 'F', 'N') )
           THEN
                /* Store starting points for subsequent calls */
                g_last_valid_date   := p_gl_date;
                g_valid_start_index := i;
                RETURN( p_gl_date );
           ELSE
                RETURN( gl_bump_t(i) );
           END IF;
      END IF;

   END LOOP;

   /* NOTE:  This only executes if the loop falls through without
      finding a period for the passed date.  It is a soft error
      condition */
   arp_standard.debug('ERROR: Unable to find period for ' || p_gl_date);

      FOR i IN 1..g_rows LOOP

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug(
              'index = '||i||', '||
              TO_CHAR(gl_start_t(i), 'DD-MON-RRRR')||', '||
              TO_CHAR(gl_end_t(i), 'DD-MON-RRRR')||', '||
              gl_status_t(i)||', '||
              TO_CHAR(gl_bump_t(i), 'DD-MON-RRRR') );
          END IF;

      END LOOP;

END assign_gl_date;

/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   assign_gl_rec                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Check if GL date of REC distribution is in a OPEN or FUTURE or        |
 |   NOT OPEN period.                                                      |
 |   If it is, then we shouldn't bump it. If the GL date is in a 'Closed'  |
 |   or 'Closed Pending' period, bump it to the next Open/Future/Not Open  |
 |   period.                                                               |
 |                                                                         |
 | PARAMETERS                                                              |
 |   p_gl_date  IN DATE,  - REC distribution GL date                       |
 |                                                                         |
 | RETURNS                                                                 |
 |   p_gl_date, if GL date is in Open/Future/Not Open period               |
 |   bump_date, if GL date is in Closed/Close Pending period               |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |   assign_gl_rec(to_date('01-JAN-1998', 'DD-MON-YYYY'));                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   10-FEB-99 Victoria Smith   Created
 |   17-SEP-04 M Raymond        Bug 3879222 - added populate_glp_table
 |                              to make this work when called from other
 |                              packages.                                  |
 +-------------------------------------------------------------------------*/

FUNCTION assign_gl_rec(p_gl_date IN DATE)

         RETURN DATE IS

BEGIN

   /* Populate the GL periods PL/SQL table. */
   populate_glp_table(arp_standard.sysparm.set_of_books_id,
                      arp_standard.application_id);

   IF (gl_status_t(glp_index_rec) IN ('O', 'F', 'N') )
   THEN
      RETURN( p_gl_date );
   ELSE
      RETURN( gl_bump_t(glp_index_rec) );
   END IF;

END assign_gl_rec;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_assignments                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   Create revenue assignments in ra_cust_trx_line_gl_dist from any       |
 |   un-expanded model accounts within the specified date range            |
 |                                                                         |
 | PARAMETERS                                                              |
 |   p_trx_id          IN NUMBER,                                          |
 |   p_period_set_name IN VARCHAR,                                         |
 |   p_base_precision  IN NUMBER,                                          |
 |   p_bmau            IN NUMBER                                           |
 |                                                                         |
 | RETURNS                                                                 |
 |   row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to create        |
 |                                  revenue account assignments by trx_id  |
 |    04-OCT-00  Jon Beckett        Assignments not created if revenue     |
 |                                  deferred(bug 1551488 Rev Mgmt phase II)|
 |    10-DEC-01  M Raymond          Added ORDERED hint to gl_date sql      |
 |                                  that uses ar_revenue_assignments view. |
 |                                  See bug 2143064 for details.           |
 |    13-Aug-02  Debbie Jancis      Modified for MRC Trigger replacement   |
 |     				    added calls for                        |
 |				    ra_cust_trx_line_gl_dist processing    |
 |    31-JAN-03  M Raymond          Modified MRC cursor to include UNEARN
 |                                  rows where rec_offset_flag is null.
 |    02-MAY-03  M Raymond          Modified REV insert to include an
 |                                  outer join to ra_cust_trx_line_salesreps
 |                                  so we can assign proper salesrep id
 |                                  on CM distributions.
 +-------------------------------------------------------------------------*/

FUNCTION create_assignments(
                p_trx_id          IN NUMBER,
                p_period_set_name IN VARCHAR,
                p_base_precision  IN NUMBER,
                p_bmau            IN NUMBER)

         RETURN NUMBER IS

  /*  added for MRC Trigger Replacement */
  l_rows  NUMBER;
  l_rows1 NUMBER;
  l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

  /* bug 3477990 */
  l_return_status NUMBER;

  /* 9560174 */
  l_standard_rules NUMBER;
  l_pprr_rules     NUMBER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'arp_auto_rule.create_assignments()+ ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   SELECT
          gl_date
   INTO
          rec_gl_date
   FROM
          ra_cust_trx_line_gl_dist
   WHERE
          account_class = 'REC'
   AND    account_set_flag = 'Y'
   AND    customer_trx_id = p_trx_id ;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('rec date: ' ||
                      TO_CHAR(rec_gl_date));
   END IF;

   /* Bug 2143064 - Added ORDERED hint */
   SELECT /*+ ORDERED */
          MIN(gl_date),
          MAX(gl_date)
   INTO
          min_gl_date,
          max_gl_date
   FROM
          ar_revenue_assignments
   WHERE
          customer_trx_id = p_trx_id
   AND    period_set_name = p_period_set_name ;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('min date: ' ||
                      TO_CHAR(min_gl_date) || ', max date: '||
                      TO_CHAR(max_gl_date));
   END IF;

   IF ( min_gl_date IS NULL OR max_gl_date IS NULL )
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Min/Max gl_dates are NULL!!. Check trx..');
        END IF;
        RETURN ( -2 );
   END IF;

   /* Set the start and end indexes in glp table for faster search. */

   l_return_status := assign_glp_index;
   IF l_return_status = -1 THEN
      RETURN l_return_status;
   END IF;

   assign_glp_rec;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('before insert....');
      arp_standard.debug('g_rev_mgt_installed : ' ||g_rev_mgt_installed);
   END IF;

   /* 9560174 - determine if A/ACC_DUR and/or PPRR rules exist and
      execute the correct insert(s) accordingly. */
   BEGIN
      SELECT sum(decode(substr(rl.type,1,1),'A',1,0)),
             sum(decode(substr(rl.type,1,1),'P',1,0))
      INTO   l_standard_rules, l_pprr_rules
      FROM   ra_customer_trx_lines tl,
             ra_rules rl
      WHERE  tl.customer_trx_id = p_trx_id
      AND    tl.accounting_rule_id = rl.rule_id
      GROUP BY tl.customer_trx_id;
   EXCEPTION
     WHEN OTHERS THEN
        arp_standard.debug('EXCEPTION:  detection of standard/pprr rules failed.');
        /* insure that both versions of the insert fire */
        l_standard_rules := 1;
        l_pprr_rules := 1;
   END;

   /* if A/ACC_DUR rules */
   IF l_standard_rules > 0
   THEN

      INSERT INTO ra_cust_trx_line_gl_dist		/* REV lines */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            org_id
          ) /* Bug 2118867 - added ORDERED hint */
      SELECT /*+ ORDERED */
            ass.customer_trx_line_id,               /* customer_trx_line_id */
            lines.customer_trx_id,                  /* customer_trx_id */
            dist.code_combination_id,               /* code_combination_id */
            arp_standard.sysparm.set_of_books_id,   /* set_of_books_id */
            ass.account_class,                      /* account_class */
            'N',                                    /* account_set_flag */
            ROUND(
                  (DECODE(fc.minimum_accountable_unit,
                          NULL, ROUND( (dist.percent/100) *
                                        DECODE(ass.amount, 0,
                                               DECODE(ass.account_class,
                                                      'REV', DECODE( lines.previous_customer_trx_id,
                                                                     NULL, 1, -1
                                                                   ),
                                                      DECODE( lines.previous_customer_trx_id,
                                                              NULL, -1, 1
                                                            )
                                                     ),
                                               ass.amount
                                              ), fc.precision),
                          ROUND( ((dist.percent/100) *
                                  DECODE(ass.amount,
                                         0, DECODE(ass.account_class,
                                                   'REV', DECODE( lines.previous_customer_trx_id,
                                                                  NULL, 1, -1),
                                                   DECODE( lines.previous_customer_trx_id,
                                                           NULL, -1, 1)
                                                  ),
                                         ass.amount) ) /
                                       fc.minimum_accountable_unit) *
                                fc.minimum_accountable_unit) /
                   DECODE(lines.extended_amount,
                          0,1,
                          lines.extended_amount)) * decode(ass.amount, 0, 0, 100), /* Bug 944929 */
                  4),                               /* percent */
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( (dist.percent/100) * ass.amount, fc.precision),
                   ROUND( ((dist.percent/100) * ass.amount) /
                                fc.minimum_accountable_unit) *
                         fc.minimum_accountable_unit), /* amount */
            DECODE(p_bmau,
                   NULL, ROUND(
                                 NVL(header.exchange_rate, 1) *
                                 DECODE(fc.minimum_accountable_unit,
                                        NULL, ROUND( (dist.percent/100)
                                                     * ass.amount,
                                                     fc.precision),
                                        ROUND( ((dist.percent/100) *
                                                 ass.amount) /
                                               fc.minimum_accountable_unit) *
                                        fc.minimum_accountable_unit
                                       ),
                                 p_base_precision),
                   ROUND(
                         ( NVL(header.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( (dist.percent/100) * ass.amount,
                                               fc.precision),
                                  ROUND( ( (dist.percent/100) * ass.amount) /
                                                fc.minimum_accountable_unit) *
                                         fc.minimum_accountable_unit
                                 )
                         ) / p_bmau) * p_bmau
                  ),                            /* acctd_amount */
      /*
         Use the bump GL date if the actual Rev distribution GL date is in a
         'Closed' OR 'Closed Pending' period.

         Insert a NULL GL date if the transaction is post to GL = No.
      */
            DECODE(rec.gl_date,
                   NULL, NULL,
		   assign_gl_date(ass.gl_date)
                  ),				/* derived gl_date */
            DECODE(dist.customer_trx_id, header.customer_trx_id,
                      dist.cust_trx_line_salesrep_id,
                      cmsrep.cust_trx_line_salesrep_id), /* cust_trx_line_salesrep_id  */
            arp_standard.profile.request_id,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            -3,
            ass.gl_date,                         /* original_gl_date */
            ra_cust_trx_line_gl_dist_s.NEXTVAL, /* cust_trx_line_gl_dist_id */
            header.org_id
      FROM
            ra_customer_trx header,
            fnd_currencies fc,
            ra_customer_trx_lines lines,
            ra_rules acc_rule,
            ra_cust_trx_line_gl_dist rec,
            ra_cust_trx_line_gl_dist dist,
            ra_cust_trx_line_salesreps cmsrep,
            ar_rev_assign_for_std_v ass   -- 9560174 only regular rules
      WHERE
            header.customer_trx_id       = p_trx_id
      AND   ass.customer_trx_id = p_trx_id /* 5752668 */
      AND   header.complete_flag         = 'Y'
      AND   fc.currency_code             = header.invoice_currency_code
       /* only lines that are not comlpete with respect to autorule */
       /* get accounting from view for line */
      AND   lines.customer_trx_id        = header.customer_trx_id
      AND   lines.autorule_complete_flag||'' = 'N'
      AND   ass.customer_trx_line_id     = lines.customer_trx_line_id
      AND   ass.period_set_name          = p_period_set_name
      AND   acc_rule.rule_id             = lines.accounting_rule_id
      AND   acc_rule.type                IN ('A','ACC_DUR')
       /* Bug 2560048/2639395 RAM-C - call collectivity engine to determine
          if revenue should be deferred for INV or CM */
       /* 6060283 - changed credits from cash_based to line_collectible
          so they honor deferrals other than cash-based ones */
      AND   decode(header.invoicing_rule_id, -3, ar_revenue_management_pvt.collect,
           decode(nvl(acc_rule.deferred_revenue_flag, 'N'),
              'Y', ar_revenue_management_pvt.defer,
            decode(g_rev_mgt_installed, 'N', ar_revenue_management_pvt.collect,
              decode(header.previous_customer_trx_id, NULL,
             ar_revenue_management_pvt.line_collectibility(p_trx_id, lines.customer_trx_line_id),
             ar_revenue_management_pvt.line_collectible(
                   lines.previous_customer_trx_id,
                   lines.previous_customer_trx_line_id)))))
                <> ar_revenue_management_pvt.defer
      AND   rec.customer_trx_id          = header.customer_trx_id
      AND   rec.account_class            = 'REC'
      AND   rec.latest_rec_flag          = 'Y'
       /* join account set distribution to the transaction with the
          account set. */
      AND   dist.customer_trx_line_id    =
            (SELECT
                    DECODE(COUNT(cust_trx_line_gl_dist_id),
                           0, NVL(lines.previous_customer_trx_line_id,
                                  lines.customer_trx_line_id),
                           lines.customer_trx_line_id)
             FROM
                    ra_cust_trx_line_gl_dist subdist2
             WHERE
                    subdist2.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist2.account_set_flag     = 'Y'
             AND    subdist2.gl_date              IS NULL
             AND    ROWNUM                        < 2
            )
      AND   dist.account_class           = ass.account_class
            /* only pick up account set accounts  */
      AND   dist.account_set_flag        = 'Y' /* model accounts */
            /* Bug 2899714 */
      AND   dist.cust_trx_line_salesrep_id = cmsrep.prev_cust_trx_line_salesrep_id (+)
      AND   p_trx_id                       = cmsrep.customer_trx_id (+)
            /* don't recreate those that already exist */
      AND   NOT EXISTS
            (
             SELECT
                    'distribution exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    subdist.customer_trx_line_id = ass.customer_trx_line_id
             AND    subdist.customer_trx_id + 0  = lines.customer_trx_id
             AND    subdist.account_set_flag     = 'N'
             AND    subdist.account_class        = ass.account_class
             AND    subdist.original_gl_date     = ass.gl_date
            );

      l_rows := sql%rowcount;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Revenue lines inserted (A/ACC_DUR rules): ' ||
                     l_rows);
      END IF;
   END IF; /* end of A/ACC_DUR rules */

   IF l_pprr_rules > 0
   THEN

      INSERT INTO ra_cust_trx_line_gl_dist         /* REV lines */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            org_id
          ) /* Bug 2118867 - added ORDERED hint */
      SELECT /*+ ORDERED */
            ass.customer_trx_line_id,               /* customer_trx_line_id */
            lines.customer_trx_id,                  /* customer_trx_id */
            dist.code_combination_id,               /* code_combination_id */
            arp_standard.sysparm.set_of_books_id,   /* set_of_books_id */
            ass.account_class,                      /* account_class */
            'N',                                    /* account_set_flag */
            ROUND(
                  (DECODE(fc.minimum_accountable_unit,
                          NULL, ROUND( (dist.percent/100) *
                                        DECODE(ass.amount, 0,
                                               DECODE(ass.account_class,
                                                      'REV', DECODE( lines.previous_customer_trx_id,
                                                                     NULL, 1, -1
                                                                   ),
                                                      DECODE( lines.previous_customer_trx_id,
                                                              NULL, -1, 1
                                                            )
                                                     ),
                                               ass.amount
                                              ), fc.precision),
                          ROUND( ((dist.percent/100) *
                                  DECODE(ass.amount,
                                         0, DECODE(ass.account_class,
                                                   'REV', DECODE( lines.previous_customer_trx_id,
                                                                  NULL, 1, -1),
                                                   DECODE( lines.previous_customer_trx_id,
                                                           NULL, -1, 1)
                                                  ),
                                         ass.amount) ) /
                                       fc.minimum_accountable_unit) *
                                fc.minimum_accountable_unit) /
                   DECODE(lines.extended_amount,
                          0,1,
                          lines.extended_amount)) * decode(ass.amount, 0, 0, 100), /* Bug 944929 */
                  4),                               /* percent */
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( (dist.percent/100) * ass.amount, fc.precision),
                   ROUND( ((dist.percent/100) * ass.amount) /
                                fc.minimum_accountable_unit) *
                         fc.minimum_accountable_unit), /* amount */
            DECODE(p_bmau,
                   NULL, ROUND(
                                 NVL(header.exchange_rate, 1) *
                                 DECODE(fc.minimum_accountable_unit,
                                        NULL, ROUND( (dist.percent/100)
                                                     * ass.amount,
                                                     fc.precision),
                                        ROUND( ((dist.percent/100) *
                                                 ass.amount) /
                                               fc.minimum_accountable_unit) *
                                        fc.minimum_accountable_unit
                                       ),
                                 p_base_precision),
                   ROUND(
                         ( NVL(header.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( (dist.percent/100) * ass.amount,
                                               fc.precision),
                                  ROUND( ( (dist.percent/100) * ass.amount) /
                                                fc.minimum_accountable_unit) *
                                         fc.minimum_accountable_unit
                                 )
                         ) / p_bmau) * p_bmau
                  ),                            /* acctd_amount */
      /*
         Use the bump GL date if the actual Rev distribution GL date is in a
         'Closed' OR 'Closed Pending' period.

         Insert a NULL GL date if the transaction is post to GL = No.
      */
            DECODE(rec.gl_date,
                   NULL, NULL,
                   assign_gl_date(ass.gl_date)
                  ),                            /* derived gl_date */
            DECODE(dist.customer_trx_id, header.customer_trx_id,
                      dist.cust_trx_line_salesrep_id,
                      cmsrep.cust_trx_line_salesrep_id), /* cust_trx_line_salesrep_id  */
            arp_standard.profile.request_id,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            -3,
            ass.gl_date,                         /* original_gl_date */
            ra_cust_trx_line_gl_dist_s.NEXTVAL, /* cust_trx_line_gl_dist_id */
            header.org_id
      FROM
            ra_customer_trx header,
            fnd_currencies fc,
            ra_customer_trx_lines lines,
            ra_rules acc_rule,
            ra_cust_trx_line_gl_dist rec,
            ra_cust_trx_line_gl_dist dist,
            ra_cust_trx_line_salesreps cmsrep,
            ar_rev_assign_for_pprr_v ass  -- 9560174 PPRR rules only.
      WHERE
            header.customer_trx_id       = p_trx_id
      AND   ass.customer_trx_id = p_trx_id /* 5752668 */
      AND   header.complete_flag         = 'Y'
      AND   fc.currency_code             = header.invoice_currency_code
       /* only lines that are not comlpete with respect to autorule */
       /* get accounting from view for line */
      AND   lines.customer_trx_id        = header.customer_trx_id
      AND   lines.autorule_complete_flag||'' = 'N'
      AND   ass.customer_trx_line_id     = lines.customer_trx_line_id
      AND   ass.period_set_name          = p_period_set_name
      AND   acc_rule.rule_id             = lines.accounting_rule_id
      AND   acc_rule.type                IN ('PP_DR_ALL','PP_DR_PP')
       /* Bug 2560048/2639395 RAM-C - call collectivity engine to determine
          if revenue should be deferred for INV or CM */
       /* 6060283 - changed credits from cash_based to line_collectible
          so they honor deferrals other than cash-based ones */
      AND   decode(header.invoicing_rule_id, -3, ar_revenue_management_pvt.collect,
           decode(nvl(acc_rule.deferred_revenue_flag, 'N'),
              'Y', ar_revenue_management_pvt.defer,
            decode(g_rev_mgt_installed, 'N', ar_revenue_management_pvt.collect,
              decode(header.previous_customer_trx_id, NULL,
             ar_revenue_management_pvt.line_collectibility(p_trx_id, lines.customer_trx_line_id),
             ar_revenue_management_pvt.line_collectible(
                   lines.previous_customer_trx_id,
                   lines.previous_customer_trx_line_id)))))
                <> ar_revenue_management_pvt.defer
      AND   rec.customer_trx_id          = header.customer_trx_id
      AND   rec.account_class            = 'REC'
      AND   rec.latest_rec_flag          = 'Y'
       /* join account set distribution to the transaction with the
          account set. */
      AND   dist.customer_trx_line_id    =
            (SELECT
                    DECODE(COUNT(cust_trx_line_gl_dist_id),
                           0, NVL(lines.previous_customer_trx_line_id,
                                  lines.customer_trx_line_id),
                           lines.customer_trx_line_id)
             FROM
                    ra_cust_trx_line_gl_dist subdist2
             WHERE
                    subdist2.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist2.account_set_flag     = 'Y'
             AND    subdist2.gl_date              IS NULL
             AND    ROWNUM                        < 2
            )
      AND   dist.account_class           = ass.account_class
            /* only pick up account set accounts  */
      AND   dist.account_set_flag        = 'Y' /* model accounts */
            /* Bug 2899714 */
      AND   dist.cust_trx_line_salesrep_id = cmsrep.prev_cust_trx_line_salesrep_id (+)
      AND   p_trx_id                       = cmsrep.customer_trx_id (+)
            /* don't recreate those that already exist */
      AND   NOT EXISTS
            (
             SELECT
                    'distribution exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    subdist.customer_trx_line_id = ass.customer_trx_line_id
             AND    subdist.customer_trx_id + 0  = lines.customer_trx_id
             AND    subdist.account_set_flag     = 'N'
             AND    subdist.account_class        = ass.account_class
             AND    subdist.original_gl_date     = ass.gl_date
            );


      /* need to process mrc data as well.   Need to save the row count for
         final return */
      l_rows1 := sql%rowcount;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Revenue lines inserted for PPRR rules: ' ||
                     l_rows1);
      END IF;

   END IF; /* end PPRR rules */

   l_rows := nvl(l_rows,0) + nvl(l_rows1,0);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Revenue lines inserted total: ' ||
                     l_rows);
      arp_standard.debug('arp_auto_rule.create_assignments()- ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   RETURN( l_rows);

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_auto_rule.create_assignments()');
           arp_standard.debug(SQLERRM);
           arp_standard.debug(  'arp_auto_rule.create_assignments()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_assignments;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_other_receivable                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |   Create real receivable record if it doesn't already exist.            |
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 |   p_trx_id         IN NUMBER,                                           |
 |   p_base_precision IN NUMBER,                                           |
 |   p_bmau           IN NUMBER                                            |
 |                                                                         |
 | RETURNS                                                                 |
 |   Row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        Created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to create        |
 |                                  revenue account assignments by trx_id  |
 +-------------------------------------------------------------------------*/

FUNCTION create_other_receivable(
                p_trx_id         IN NUMBER,
                p_base_precision IN NUMBER,
                p_bmau           IN NUMBER)

         RETURN NUMBER IS

 /*  added for MRC Trigger Replacement */
  l_rows  NUMBER;
 l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;   /* mrc */

 /* bug 1947192 */
 cursor c_update_ps( l_trx_id NUMBER)  is
               SELECT ps.payment_schedule_id ps_id,
                      gld.gl_date gl_date
               FROM   ar_payment_schedules ps,
                      ra_cust_trx_line_gl_dist gld
               WHERE  gld.customer_trx_id = l_trx_id
                 AND  gld.account_class = 'REC'
                 AND  gld.account_set_flag = 'N'
                 AND  gld.customer_trx_id = ps.customer_trx_id
                 AND  gld.gl_date <> ps.gl_date;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'arp_auto_rule.create_other_receivable()+ ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;

     INSERT INTO ra_cust_trx_line_gl_dist	/* REC line */
           (
             customer_trx_id,
             code_combination_id,
             set_of_books_id,
             account_class,
             account_set_flag,
             latest_rec_flag,
             percent,
             amount,
             acctd_amount,
             gl_date,
             request_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             program_application_id,
             program_id,
             program_update_date,
             posting_control_id,
             original_gl_date,
             cust_trx_line_gl_dist_id,
             org_id
           ) /* Bug 1544343 - added RULE hint, bug 2110069 - removed
                  RULE hint and changed subquery join (below) */
     SELECT
             rec.customer_trx_id,
             rec.code_combination_id,
             arp_standard.sysparm.set_of_books_id,
             rec.account_class,
             'N',                                  /* account_set_flag */
             'Y',                                  /* latest_rec_flag */
             rec.percent,
             rec.amount,
             rec.acctd_amount,
             DECODE(rec.gl_date,
                   NULL, NULL,
                   assign_gl_rec(rec.gl_date)
                  ),                            /* derived gl_date */
             arp_standard.profile.request_id,
             arp_standard.profile.user_id,
             sysdate,
             arp_standard.profile.user_id,
             sysdate,
             arp_standard.application_id,
             arp_standard.profile.program_id,
             sysdate,
             -3,                              /* posting_control_id */
             NVL(NVL(rec.original_gl_date, rec.gl_date), header.trx_date),
             ra_cust_trx_line_gl_dist_s.NEXTVAL,
             header.org_id
       FROM
             ra_cust_trx_line_gl_dist rec,
             ra_customer_trx header
       WHERE
             header.customer_trx_id = p_trx_id
       AND   header.complete_flag   = 'Y'
       AND   rec.customer_trx_id    = header.customer_trx_id
       AND   rec.account_class      = 'REC'
       AND   rec.latest_rec_flag    = 'Y'
       AND   rec.account_set_flag   = 'Y'
          /* ensure that the receivable doesn't already exist */
       AND   NOT EXISTS
            (
              SELECT
                     'exist'
              FROM
                     ra_cust_trx_line_gl_dist real_rec
              WHERE
                     real_rec.customer_trx_id  = rec.customer_trx_id
              AND    real_rec.account_class    = 'REC'
              AND    real_rec.account_set_flag = 'N'
            );
      l_rows := sql%rowcount;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('REC lines inserted: ' ||
                       l_rows);
    END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'create_other_receivable(-)');
 END IF;


     /* Erase the latest_rec_flag of the receivable account set
        records for the transactions whose actual receivable records
        have just been created.                                     */

       /* no mrc columns affected so no update to mrc table needed */

       /* Bug 3416070 - Removed request_id from where clause */

       UPDATE ra_cust_trx_line_gl_dist
       SET
              latest_rec_flag  = 'N',
              last_updated_by  = arp_standard.profile.user_id,
              last_update_date = sysdate
       WHERE
              account_set_flag = 'Y'
       AND    account_class    = 'REC'
       AND    latest_rec_flag  = 'Y'
       AND    customer_trx_id  IN
              (
                SELECT
                       customer_trx_id
                FROM
                       ra_cust_trx_line_gl_dist
                WHERE
                       customer_trx_id  = p_trx_id
                AND    account_class    = 'REC'
                AND    account_set_flag = 'N'
              );

      l_rows := sql%rowcount;


    /* bug 1947192 */
    FOR i IN c_update_ps(p_trx_id)  LOOP
       IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('arp_auto_rule.create_other_receivable(): Change Payment Schedule Gl Date');
       END IF;
       UPDATE ar_payment_schedules
       SET    gl_date = i.gl_date ,
              last_updated_by  = arp_standard.profile.user_id,
              last_update_date = sysdate
       WHERE  payment_schedule_id = i.ps_id;
    END LOOP;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(   'arp_auto_rule.create_other_receivable()- ' ||
                       TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;

    RETURN( l_rows );

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_other_receivable()');
           arp_standard.debug( SQLERRM);
           arp_standard.debug(   'arp_auto_rule.create_other_receivable()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_other_receivable;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_round                                                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 |   Create real round record if it doesn't already exist.                 |
 |                                                                         |
 | PARAMETERS                                                              |
 |                                                                         |
 |   p_trx_id         IN NUMBER,                                           |
 |   p_base_precision IN NUMBER,                                           |
 |   p_bmau           IN NUMBER                                            |
 |                                                                         |
 | RETURNS                                                                 |
 |   Row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    11-Sep-98  Ramakant Alat      Added call to create_round and changed |
 |    17-JAN-02  M Raymond          If original gl_date is in closed period,
 |                                  REC row was getting bumped to next open,
 |                                  but ROUND was getting created in closed
 |                                  period.  Now, ROUND gets bumped to same
 |                                  date as REC.
 |                                  See bug 2172061 for details.
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION create_round(
                p_trx_id         IN NUMBER,
                p_base_precision IN NUMBER,
                p_bmau           IN NUMBER)

         RETURN NUMBER IS

  /* added for mrc */
  l_rows  NUMBER;
  l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(   'arp_auto_rule.create_round()+ ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;


     INSERT INTO ra_cust_trx_line_gl_dist	/* ROUND line */
           (  					/* drive from gl_dist */
             customer_trx_id,
             code_combination_id,
             set_of_books_id,
             account_class,
             account_set_flag,
             latest_rec_flag,
             percent,
             amount,
             acctd_amount,
             gl_date,
             request_id,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             program_application_id,
             program_id,
             program_update_date,
             posting_control_id,
             original_gl_date,
             cust_trx_line_gl_dist_id,
             org_id
           )
     SELECT
             rec.customer_trx_id,
             rec.code_combination_id,
             arp_standard.sysparm.set_of_books_id,
             rec.account_class,
             'N',                                  /* account_set_flag */
             null,                                  /* latest_rec_flag */
             rec.percent,
             rec.amount,
             rec.acctd_amount,
             rrec.gl_date, /* 2172061 - now fetches date from REC row */
             arp_standard.profile.request_id,
             arp_standard.profile.user_id,
             sysdate,
             arp_standard.profile.user_id,
             sysdate,
             arp_standard.application_id,
             arp_standard.profile.program_id,
             sysdate,
             -3,                              /* posting_control_id */
             NVL(NVL(rec.original_gl_date, rec.gl_date), header.trx_date),
             ra_cust_trx_line_gl_dist_s.nextval,
             header.org_id
       FROM
             ra_customer_trx header,
             ra_cust_trx_line_gl_dist rec, /* ROUND row */
             ra_cust_trx_line_gl_dist rrec /* REC row */
       WHERE
             header.customer_trx_id = p_trx_id
       AND   header.complete_flag         = 'Y'
       AND   header.customer_trx_id       = rec.customer_trx_id
       AND   rec.account_class            = 'ROUND'
       AND   rec.account_set_flag         = 'Y'
       AND   header.customer_trx_id       = rrec.customer_trx_id
       AND   rrec.account_class           = 'REC'
       AND   rrec.latest_rec_flag         = 'Y'
         /* ensure that the round record doesn't already exist */
       AND   NOT EXISTS
            (
              SELECT 'exist'
              FROM
                     ra_cust_trx_line_gl_dist real_rec
              WHERE
                     real_rec.customer_trx_id  = rec.customer_trx_id
              AND    real_rec.account_class    = 'ROUND'
              AND    real_rec.account_set_flag = 'N'
            );

      l_rows := sql%rowcount;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ROUND lines inserted: ' ||
                       l_rows);
       arp_standard.debug(   'arp_auto_rule.create_round()- ' ||
                       TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;

   RETURN( l_rows);

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_round()');
           arp_standard.debug( SQLERRM);
           arp_standard.debug(   'arp_auto_rule.create_round()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_round;
/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_other_plug                                                     |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   Row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to create        |
 |                                  revenue account assignments by trx_id  |
 |    10-MAY-02  M Raymond          Added column rec_offset_flag to
 |                                  ra_cust_trx_line_gl_dist_all.  Added
 |                                  logic to this insert to populate it
 |                                  with a 'Y' if inserting UNEARN or
 |                                  UNBILL lines.
 |                                  See bug 2150541 for details.
 |    18-SEP-02  J Beckett          Bug 2560048 RAM-C - create cr UNEARN / |
 |                                  dr UNBILL if deferred/arrears. Select  |
 |                                  restructured into cursor fetched into  |
 |                                  variables.                             |
 |    09-OCT-02  J Beckett          Bug 2560048: U-turn on the above       |
 |                                  approach - code is reverted to prior   |
 |                                  state                                  |
 |    31-JAN-03  M Raymond          Bug 2779454 - Added logic to limit
 |                                  the processing of UNEARN/UNBILL rows
 |                                  to only those with rof = Y. Rows with
 |                                  rof=null are processed in
 |                                  create_assignments
 |    14-APR-03  M Raymond          Bug 2899714 - Corrected assignment of
 |                                  cust_trx_line_salesrep_id for Credit
 |                                  Memos.  Also removed some old RELEASE 9
 |                                  logic to improve performance a bit.
 |    17-SEP-05  M Raymond          Bug 4602892 - We now allow multiple
 |                                  lines on one CM to point to a single
 |                                  invoice line.  The fix from 2899714
 |                                  causes too many rows to be inserted.
 +-------------------------------------------------------------------------*/


FUNCTION create_other_plug(
                p_trx_id         IN NUMBER,
                p_base_precision IN NUMBER,
                p_bmau           IN NUMBER)

         RETURN NUMBER IS

   /* added for MRC */
 l_rows   NUMBER;
 /* bug 3550426 */
 l_ctt_id 		ra_cust_trx_types.cust_trx_type_id%TYPE;
 l_inv_rule_id 		ra_customer_trx.invoicing_rule_id%TYPE;
 l_ctt_type 		ra_cust_trx_types.type%TYPE;
 l_revrec_run_flag 	VARCHAR2(1);
 l_prev_cust_trx_id 	ra_customer_trx.customer_trx_id%TYPE;

 l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

/*FP 5450534 for bug 5260489 take a dummy parameter to pass in call to rev. rec.*/
 l_request_id           ra_customer_trx.request_id%type;

 l_result               NUMBER;
 NO_ROF_EXCEPTION       EXCEPTION;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(   'arp_auto_rule.create_other_plug()+ ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        arp_standard.debug('  use_inv_acctg = ' || g_use_inv_acctg);
     END IF;

     /* Bug 3550426 */
     SELECT cust_trx_type_id ,
 	    invoicing_rule_id,
	    previous_customer_trx_id
     INTO   l_ctt_id,
	    l_inv_rule_id,
	    l_prev_cust_trx_id
     FROM   ra_customer_trx
     WHERE  customer_trx_id = p_trx_id;

     arp_standard.debug(' prev ct id ' || l_prev_cust_trx_id);

     l_ctt_type :=  arpt_sql_func_util.get_trx_type_details(l_ctt_id, 'TYPE') ;
     arp_standard.debug(' l_ctt_type ' || l_ctt_type);

     IF l_ctt_type = 'CM' AND
        g_use_inv_acctg = 'Y'
     THEN
        /* 5598773 - no reason to get the l_revrec_run_flag if
           use_inv_acctg is 'N' */
        l_revrec_run_flag :=  arpt_sql_func_util.get_revenue_recog_run_flag(l_prev_cust_trx_id,
                                                                            l_inv_rule_id);
        arp_standard.debug(' l_revrec_run_flag ' || l_revrec_run_flag);
     END IF;

     IF l_ctt_type in ('INV','DM')   /*Bug 4547416*/
        OR
	( l_ctt_type = 'CM' AND l_revrec_run_flag = 'N')
        OR
        ( l_ctt_type = 'CM' AND g_use_inv_acctg = 'N') /* 5598773 */
     THEN
     INSERT INTO ra_cust_trx_line_gl_dist		/* OTHER */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            program_application_id,
            program_id,
            program_update_date,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            rec_offset_flag, /* Bug 2150541 */
            org_id
          )
     SELECT
            lines.customer_trx_line_id,
            lines.customer_trx_id,
            psum.code_combination_id,
            arp_standard.sysparm.set_of_books_id,
            psum.account_class,
            'N',                        /* account_set_flag */
            ROUND((DECODE(psum.account_class,
                          'SUSPENSE',  (lines.extended_amount -
                                           lines.revenue_amount),
                          decode(lines.revenue_amount,0,1,lines.revenue_amount)) /
                            DECODE(psum.account_class,
                                   'SUSPENSE',decode((lines.extended_amount -
                                                    lines.revenue_amount),0,1,
                                                    (lines.extended_amount -
                                                    lines.revenue_amount)),
                                DECODE(lines.extended_amount,
                                       0,1,
                                       lines.extended_amount))  /*3550426*/
                   ) * psum.percent, 4
                 ),                     /* percent */
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( ((psum.percent / 100) *
                                 DECODE(psum.account_class,
                                        'SUSPENSE', (lines.extended_amount -
                                                    lines.revenue_amount),
                                        lines.revenue_amount)), fc.precision),
                   ROUND( ((psum.percent / 100) *
                            DECODE(psum.account_class,
                                   'SUSPENSE', (lines.extended_amount -
                                                    lines.revenue_amount),
                                   lines.revenue_amount)) /
                                    fc.minimum_accountable_unit) *
                                    fc.minimum_accountable_unit
                  ),    		/* amount */
            DECODE(p_bmau,
                   NULL, ROUND(
                                NVL(trx.exchange_rate, 1) *
                                DECODE(fc.minimum_accountable_unit,
                                       NULL, ROUND( ((psum.percent / 100) *
                                                     DECODE(psum.account_class,
                                                      'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                      lines.revenue_amount)),
                                                   fc.precision),
                                       ROUND( ((psum.percent / 100) *
                                               DECODE(psum.account_class,
                                                      'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                       lines.revenue_amount)) /
                                                 fc.minimum_accountable_unit) *
                                                 fc.minimum_accountable_unit),
                                p_base_precision),
                   ROUND(
                         ( NVL(trx.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((psum.percent / 100) *
                                                DECODE(psum.account_class,
                                                     'SUSPENSE',
                                                      (lines.extended_amount -
                                                       lines.revenue_amount),
                                                     lines.revenue_amount)),
                                                   fc.precision),
                                  ROUND( ((psum.percent / 100) *
                                          DECODE(psum.account_class,
                                                 'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                      lines.revenue_amount)) /
                                                 fc.minimum_accountable_unit) *
                                                 fc.minimum_accountable_unit)) /
                                p_bmau) *
                         p_bmau), /* acctd_amount */
            DECODE(rec.gl_date,
                   NULL, NULL,
                   assign_gl_rec(rec.gl_date)
                  ),                            /* derived gl_date */
            DECODE(psum.customer_trx_id, trx.customer_trx_id,
                      psum.cust_trx_line_salesrep_id,
                      cmsrep.cust_trx_line_salesrep_id), /* salescred ID */
            arp_standard.profile.request_id,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            -3,                            /* posting_control_id */
            NVL( NVL(rec.original_gl_date, rec.gl_date), trx.trx_date),
            ra_cust_trx_line_gl_dist_s.NEXTVAL,
            /* Bug 2150541 */
            DECODE(psum.account_class, 'UNEARN', 'Y',
                                       'UNBILL', 'Y',
                                       NULL) ,
           trx.org_id
     FROM
            ra_customer_trx_lines psum_lines,
            ra_customer_trx psum_trx,
            ra_cust_trx_line_gl_dist psum, /* model plug account assignments */
            ra_cust_trx_line_salesreps cmsrep, /* 2899714 */
            ra_customer_trx_lines lines,
            ra_cust_trx_line_gl_dist rec,  /* model receivable account */
            fnd_currencies fc,
            ra_customer_trx trx
     WHERE
            trx.customer_trx_id              = p_trx_id
     AND    trx.complete_flag                = 'Y'
     AND    fc.currency_code                 = trx.invoice_currency_code
     AND    rec.customer_trx_id              = trx.customer_trx_id
     AND    rec.account_class                = 'REC'
     AND    rec.latest_rec_flag              = 'Y'
     AND    rec.customer_trx_line_id         IS NULL
     AND    lines.customer_trx_id            = trx.customer_trx_id
     AND    lines.autorule_complete_flag||'' = 'N'
     AND    psum_trx.customer_trx_id         = psum.customer_trx_id
     AND    psum_lines.customer_trx_line_id  = psum.customer_trx_line_id
     AND    psum.account_class               IN
            (
              'SUSPENSE'||
              DECODE(lines.extended_amount - NVL(lines.revenue_amount, 0),
                     0, 'X',
                     NULL),
              DECODE(trx.invoicing_rule_id,
                     -2, 'UNEARN',
                     -3, 'UNBILL')
            )
     AND    psum.customer_trx_line_id     =
            (SELECT
                    DECODE(COUNT(cust_trx_line_gl_dist_id),
                           0, NVL(lines.previous_customer_trx_line_id,
                                  lines.customer_trx_line_id),
                           lines.customer_trx_line_id)
             FROM
                    ra_cust_trx_line_gl_dist subdist2
             WHERE
                    subdist2.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist2.account_set_flag     = 'Y'
             AND    subdist2.gl_date              IS NULL
             AND    ROWNUM                        < 2
            )
            /* Bug 2899714 */
     AND    cmsrep.prev_cust_trx_line_salesrep_id (+) =
                psum.cust_trx_line_salesrep_id
     AND    cmsrep.customer_trx_id (+) = p_trx_id
            /* Bug 4602892 - avoid cartesian product for CMs
              w/ multiple lines against 1 invoice line. */
     AND    lines.customer_trx_line_id = DECODE(lines.previous_customer_trx_id,
                         NULL, lines.customer_trx_line_id,
                         NVL(cmsrep.customer_trx_line_id,
                              lines.customer_trx_line_id))
            /* Bug 2899714 - removed RELEASE 9 code */
     AND    psum.account_set_flag       = 'Y'
     AND    NOT EXISTS
            (
             SELECT
                    'plug sum account exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    subdist.account_class IN
                    ( 'SUSPENSE', DECODE(trx.invoicing_rule_id,
                                         -2, 'UNEARN',
                                         -3, 'UNBILL')
                    )
             AND    subdist.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist.account_set_flag     = 'N'
             AND    subdist.rec_offset_flag      = 'Y');

      l_rows := sql%rowcount;

     /*3550426 */
     ELSE

     INSERT INTO ra_cust_trx_line_gl_dist		/* OTHER */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            program_application_id,
            program_id,
            program_update_date,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            rec_offset_flag, /* Bug 2150541 */
            org_id
          )
     SELECT
            lines.customer_trx_line_id,
            lines.customer_trx_id,
            psum.code_combination_id,
            arp_standard.sysparm.set_of_books_id,
            psum.account_class,
            'N',                        /* account_set_flag */
            ROUND((DECODE(psum.account_class,
                          'SUSPENSE',  (lines.extended_amount -
                                           lines.revenue_amount),
                          decode(lines.revenue_amount,0,1,lines.revenue_amount)) /
                            DECODE(psum.account_class,
                                   'SUSPENSE', decode((lines.extended_amount -
                                                    lines.revenue_amount),0,1,
                                                    (lines.extended_amount -
                                                    lines.revenue_amount)),
                                DECODE(lines.extended_amount,
                                       0,1,
                                       lines.extended_amount))
                   ) * psum.percent, 4
                 ),                     /* percent */
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( ((psum.percent / 100) *
                                 DECODE(psum.account_class,
                                        'SUSPENSE', (lines.extended_amount -
                                                    lines.revenue_amount),
                                        lines.revenue_amount)), fc.precision),
                   ROUND( ((psum.percent / 100) *
                            DECODE(psum.account_class,
                                   'SUSPENSE', (lines.extended_amount -
                                                    lines.revenue_amount),
                                   lines.revenue_amount)) /
                                    fc.minimum_accountable_unit) *
                                    fc.minimum_accountable_unit
                  ),    		/* amount */
            DECODE(p_bmau,
                   NULL, ROUND(
                                NVL(trx.exchange_rate, 1) *
                                DECODE(fc.minimum_accountable_unit,
                                       NULL, ROUND( ((psum.percent / 100) *
                                                     DECODE(psum.account_class,
                                                      'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                      lines.revenue_amount)),
                                                   fc.precision),
                                       ROUND( ((psum.percent / 100) *
                                               DECODE(psum.account_class,
                                                      'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                       lines.revenue_amount)) /
                                                 fc.minimum_accountable_unit) *
                                                 fc.minimum_accountable_unit),
                                p_base_precision),
                   ROUND(
                         ( NVL(trx.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((psum.percent / 100) *
                                                DECODE(psum.account_class,
                                                     'SUSPENSE',
                                                      (lines.extended_amount -
                                                       lines.revenue_amount),
                                                     lines.revenue_amount)),
                                                   fc.precision),
                                  ROUND( ((psum.percent / 100) *
                                          DECODE(psum.account_class,
                                                 'SUSPENSE',
                                                       (lines.extended_amount -
                                                        lines.revenue_amount),
                                                      lines.revenue_amount)) /
                                                 fc.minimum_accountable_unit) *
                                                 fc.minimum_accountable_unit)) /
                                p_bmau) *
                         p_bmau), /* acctd_amount */
            DECODE(rec.gl_date,
                   NULL, NULL,
                   assign_gl_rec(rec.gl_date)
                  ),                            /* derived gl_date */
            DECODE(psum.customer_trx_id, trx.customer_trx_id,
                      psum.cust_trx_line_salesrep_id,
                      cmsrep.cust_trx_line_salesrep_id), /* salescred ID */
            arp_standard.profile.request_id,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            -3,                            /* posting_control_id */
            NVL( NVL(rec.original_gl_date, rec.gl_date), trx.trx_date),
            ra_cust_trx_line_gl_dist_s.NEXTVAL,
            /* Bug 2150541 */
            DECODE(psum.account_class, 'UNEARN', 'Y',
                                       'UNBILL', 'Y',
                                       NULL),
            trx.org_id
     FROM
            ra_customer_trx_lines psum_lines,
            ra_customer_trx psum_trx,
            ra_cust_trx_line_gl_dist psum, /* model plug account assignments */
            ra_cust_trx_line_salesreps cmsrep, /* 2899714 */
            ra_customer_trx_lines lines,
            ra_cust_trx_line_gl_dist rec,  /* model receivable account */
            fnd_currencies fc,
            ra_customer_trx trx
     WHERE
            trx.customer_trx_id              = p_trx_id
     AND    trx.complete_flag                = 'Y'
     AND    fc.currency_code                 = trx.invoice_currency_code
     AND    rec.customer_trx_id              = trx.customer_trx_id
     AND    rec.account_class                = 'REC'
     AND    rec.latest_rec_flag              = 'Y'
     AND    rec.customer_trx_line_id         IS NULL
     AND    lines.customer_trx_id            = trx.customer_trx_id
     AND    lines.autorule_complete_flag||'' = 'N'
     AND    psum_trx.customer_trx_id         = psum.customer_trx_id
     AND    psum_lines.customer_trx_line_id  = psum.customer_trx_line_id
     AND    psum.customer_trx_line_id        = lines.previous_customer_trx_line_id
     AND    psum.account_set_flag            = 'N'
     AND    ( ( psum.account_class IN ('UNEARN', 'UNBILL')
		AND
		psum.rec_offset_flag =  'Y'
	       )
	       OR
	       ( psum.account_class = 'SUSPENSE'
		 AND
		 psum.rec_offset_flag IS NULL
	        )
	    )
     AND    cmsrep.prev_cust_trx_line_salesrep_id (+) =
                psum.cust_trx_line_salesrep_id
     AND    cmsrep.customer_trx_id (+) = p_trx_id
            /* Bug 4602892 - avoid cartesian product for CMs
              w/ multiple lines against 1 invoice line. */
     AND    lines.customer_trx_line_id = DECODE(lines.previous_customer_trx_id,
                         NULL, lines.customer_trx_line_id,
                         NVL(cmsrep.customer_trx_line_id,
                               lines.customer_trx_line_id))
     AND    NOT EXISTS
            (
             SELECT
                    'plug sum account exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    subdist.account_class IN
                    ( 'SUSPENSE', DECODE(trx.invoicing_rule_id,
                                         -2, 'UNEARN',
                                         -3, 'UNBILL')
                    )
             AND    subdist.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist.account_set_flag     = 'N'
             AND    subdist.rec_offset_flag      = 'Y');

     l_rows := sql%rowcount;

     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug( 'Other plug lines inserted: ' ||
                           l_rows);
        arp_standard.debug(   'arp_auto_rule.create_other_plug()- ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;

/*Bug 5450534 FP of bug 5260489*/

    IF (l_rows = 0) THEN
      arp_rounding.SET_REC_OFFSET_FLAG(l_prev_cust_trx_id,l_request_id,l_result);

      /* 6782405 - basically, we try setting rec_offset if create_other_plug
         inserts no rows.  To re-execute this function, we have to return -99.
         The result values are -1 = None created, 0 = None needed, 1 = rows created */
      IF l_result = 1
      THEN
        /* We set rof on some lines, so make the second call.

           If result is 0, nothing was needed, and if it was -1, then we
           have some sort of problem where we can't set rof when we think
           one is needed */
        l_rows := -99;
      ELSIF l_result = -1
      THEN
        /* This is an error condition in that we could not set rof and
           the program felt that they were required */
        RAISE NO_ROF_EXCEPTION;
      ELSE
        /* l_result was 0, no action required */
        NULL;
      END IF;
    END IF;

   RETURN( l_rows );

EXCEPTION
   WHEN NO_ROF_EXCEPTION THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_other_plug()');
           arp_standard.debug( 'set_rec_offset_flag unable to set flag properly');
           arp_standard.debug(   'arp_auto_rule.create_other_plug()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;
        RETURN( -1 );
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_other_plug()');
           arp_standard.debug( SQLERRM);
           arp_standard.debug(   'arp_auto_rule.create_other_plug()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_other_plug;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_other_tax                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   Row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to create        |
 |                                  revenue account assignments by trx_id  |
 +-------------------------------------------------------------------------*/

FUNCTION create_other_tax(
                p_trx_id         IN NUMBER,
                p_base_precision IN NUMBER,
                p_bmau           IN NUMBER,
                p_ignore_rule_flag  IN VARCHAR2 DEFAULT NULL)

         RETURN NUMBER IS

/* added for mrc */
l_rows NUMBER;
l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;
l_ignore_rule_flag VARCHAR2(1);

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(   'arp_auto_rule.create_other_tax()+ ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;

     /* 7131147 - ignore autorule_complete_flag on an
         explicit (external) call */
     IF p_ignore_rule_flag = 'Y'
     THEN
        l_ignore_rule_flag := 'Y';
     ELSE
        l_ignore_rule_flag := 'N';
     END IF;

     INSERT INTO ra_cust_trx_line_gl_dist		/* TAX Lines */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            program_application_id,
            program_id,
            program_update_date,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            collected_tax_ccid,
            org_id
          )
     SELECT
            tax_line.customer_trx_line_id,
            tax_line.customer_trx_id,
            tax.code_combination_id,
            arp_standard.sysparm.set_of_books_id,
            tax.account_class,
            'N',
            tax.percent,
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( ((tax.percent / 100) *
                                 tax_line.extended_amount), fc.precision),
                   ROUND( ((tax.percent / 100) *
                           tax_line.extended_amount) /
                               fc.minimum_accountable_unit) *
                               fc.minimum_accountable_unit),    /* amount */
            DECODE(p_bmau,
              NULL, ROUND(
                           NVL(trx.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((tax.percent / 100) *
                                                tax_line.extended_amount),
                                              fc.precision),
                                        ROUND( ((tax.percent / 100) *
                                               tax_line.extended_amount) /
                                            fc.minimum_accountable_unit) *
                                        fc.minimum_accountable_unit),
                           p_base_precision),
                    ROUND(
                           ( NVL(trx.exchange_rate, 1) *
                            DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((tax.percent / 100) *
                                               tax_line.extended_amount),
                                              fc.precision),
                                        ROUND( ((tax.percent / 100) *
                                               tax_line.extended_amount) /
                                            fc.minimum_accountable_unit) *
                                        fc.minimum_accountable_unit)) /
                           p_bmau) *
                    p_bmau), /* acctd_amount */
            DECODE(rec.gl_date,
                   NULL, NULL,
                   assign_gl_rec(rec.gl_date)
                  ),                            /* derived gl_date */
            tax.cust_trx_line_salesrep_id,
            arp_standard.profile.request_id,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            -3,
            NVL( NVL(rec.original_gl_date, rec.gl_date), trx.trx_date),
            ra_cust_trx_line_gl_dist_s.NEXTVAL,
            tax.collected_tax_ccid,
            trx.org_id
     FROM
            ra_customer_trx model_trx,
            ra_cust_trx_line_gl_dist tax,
            ra_customer_trx_lines tax_line,
            ra_customer_trx_lines line_line,
            ra_cust_trx_line_gl_dist rec,
            fnd_currencies fc,
            ra_customer_trx trx
     WHERE
            trx.customer_trx_id               = p_trx_id
     AND    trx.complete_flag                 = 'Y'
     AND    fc.currency_code                  = trx.invoice_currency_code
     AND    rec.customer_trx_id               = trx.customer_trx_id
     AND    rec.account_class                 = 'REC'
     AND    rec.latest_rec_flag               = 'Y'
     AND    line_line.customer_trx_id         = rec.customer_trx_id
     AND   (line_line.autorule_complete_flag||''  = 'N'
              OR l_ignore_rule_flag = 'Y')
     AND    tax_line.link_to_cust_trx_line_id = line_line.customer_trx_line_id
     AND    tax_line.line_type                = 'TAX'
     AND    tax_line.customer_trx_id + 0      = line_line.customer_trx_id
     AND    trx.customer_trx_id               = tax_line.customer_trx_id
     AND    model_trx.customer_trx_id         = tax.customer_trx_id
     AND    tax.account_class                 = 'TAX'
     AND    tax.customer_trx_line_id          =
            (SELECT
                    DECODE( COUNT(cust_trx_line_gl_dist_id),
                            0, NVL(tax_line.previous_customer_trx_line_id,
                                   tax_line.customer_trx_line_id),
                            tax_line.customer_trx_line_id)
             FROM
                    ra_cust_trx_line_gl_dist subdist2
             WHERE
                    subdist2.customer_trx_line_id=tax_line.customer_trx_line_id
             AND    subdist2.account_set_flag    = 'Y'
             AND    subdist2.gl_date             IS NULL
             AND    ROWNUM                       < 2
            )
     AND    ( tax.account_set_flag            = 'Y'
              OR
              model_trx.created_from          IN ('RAXTRX_REL9', 'FORM_REL9')
            )
     AND    NOT EXISTS
            (SELECT
                    'tax account exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    tax_line.customer_trx_line_id = subdist.customer_trx_line_id
             AND    subdist.account_set_flag      = 'N'
             AND    subdist.gl_date               IS NOT NULL
             AND    subdist.account_class         = 'TAX'
           );

      l_rows := sql%rowcount;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug( 'Tax lines inserted: ' ||
                           l_rows);
        arp_standard.debug(   'arp_auto_rule.create_other_tax()- ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;

     RETURN( l_rows );

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_other_tax()');
           arp_standard.debug( SQLERRM);
           arp_standard.debug(   'arp_auto_rule.create_other_tax()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_other_tax;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   create_other_freight                                                  |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   Row count of number of records inserted.                              |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to create        |
 |                                  revenue account assignments by trx_id  |
 +-------------------------------------------------------------------------*/

FUNCTION create_other_freight(
                p_trx_id         IN NUMBER,
                p_base_precision IN NUMBER,
                p_bmau           IN NUMBER)

         RETURN NUMBER IS

 /* added for mrc */
 l_rows NUMBER;
l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(   'arp_auto_rule.create_other_freight()+ ' ||
                        TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
     END IF;

     INSERT INTO ra_cust_trx_line_gl_dist		/* FREIGHT Lines */
          (
            customer_trx_line_id,
            customer_trx_id,
            code_combination_id,
            set_of_books_id,
            account_class,
            account_set_flag,
            percent,
            amount,
            acctd_amount,
            gl_date,
            cust_trx_line_salesrep_id,
            request_id,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            program_application_id,
            program_id,
            program_update_date,
            posting_control_id,
            original_gl_date,
            cust_trx_line_gl_dist_id,
            org_id
          )
     SELECT
            lines.customer_trx_line_id,
            lines.customer_trx_id,
            freight.code_combination_id,
            arp_standard.sysparm.set_of_books_id,
            freight.account_class,
            'N',
            freight.percent,
            DECODE(fc.minimum_accountable_unit,
                   NULL, ROUND( ((freight.percent / 100) *
                                 lines.extended_amount), fc.precision),
                   ROUND( ((freight.percent / 100) *
                           lines.extended_amount) /
                               fc.minimum_accountable_unit) *
                               fc.minimum_accountable_unit),    /* amount */
            DECODE(p_bmau,
              NULL, ROUND(
                           NVL(trx.exchange_rate, 1) *
                           DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((freight.percent / 100) *
                                                lines.extended_amount),
                                              fc.precision),
                                  ROUND( ((freight.percent / 100) *
                                          lines.extended_amount) /
                                            fc.minimum_accountable_unit) *
                                            fc.minimum_accountable_unit),
                           p_base_precision),
                    ROUND(
                           ( NVL(trx.exchange_rate, 1) *
                            DECODE(fc.minimum_accountable_unit,
                                  NULL, ROUND( ((freight.percent / 100) *
                                               lines.extended_amount),
                                              fc.precision),
                                  ROUND( ((freight.percent / 100) *
                                          lines.extended_amount) /
                                            fc.minimum_accountable_unit) *
                                            fc.minimum_accountable_unit)) /
                           p_bmau) *
                    p_bmau), /* acctd_amount */
            rec.gl_date,
            freight.cust_trx_line_salesrep_id,
            arp_standard.profile.request_id,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.profile.user_id,
            sysdate,
            arp_standard.application_id,
            arp_standard.profile.program_id,
            sysdate,
            -3,
            NVL( NVL(rec.original_gl_date, rec.gl_date), trx.trx_date),
            ra_cust_trx_line_gl_dist_s.NEXTVAL,
            trx.org_id
      FROM
            ra_customer_trx model_trx,
            ra_cust_trx_line_gl_dist freight,
            ra_customer_trx_lines lines,
            ra_cust_trx_line_gl_dist rec,
            fnd_currencies fc,
            ra_customer_trx trx
      WHERE
            trx.customer_trx_id               = p_trx_id
      AND   trx.complete_flag                 = 'Y'
      AND   fc.currency_code                  = trx.invoice_currency_code
      AND   rec.customer_trx_id               = trx.customer_trx_id
      AND   rec.account_class                 = 'REC'
      AND   rec.latest_rec_flag               = 'Y'
      AND   rec.customer_trx_line_id          IS NULL
      AND   EXISTS
            (
              SELECT 1
              FROM   ra_customer_trx_lines line_line
              WHERE  line_line.customer_trx_id            = trx.customer_trx_id
              AND    line_line.autorule_complete_flag||'' = 'N'
            )
      AND   lines.customer_trx_id             = rec.customer_trx_id
      AND   lines.line_type                   = 'FREIGHT'
      AND   model_trx.customer_trx_id         = freight.customer_trx_id
          /* for CMs: use the invoice's account set
             if USE_INV_ACCT_FOR_CM_FLAG = Yes.  */
      AND   freight.customer_trx_line_id      =
            (SELECT
                    DECODE( COUNT(cust_trx_line_gl_dist_id),
                            0, NVL(lines.previous_customer_trx_line_id,
                                   lines.customer_trx_line_id),
                            lines.customer_trx_line_id)
             FROM
                    ra_cust_trx_line_gl_dist subdist2
             WHERE
                    subdist2.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist2.account_set_flag     = 'Y'
             AND    subdist2.gl_date              IS NULL
             AND    ROWNUM                        < 2
            )
      AND   freight.account_class             = 'FREIGHT'
      AND   ( freight.account_set_flag        = 'Y'
              OR
              model_trx.created_from          IN ( 'RAXTRX_REL9', 'FORM_REL9')
            )
      AND   NOT EXISTS
            (SELECT
                    'freight account exists'
             FROM
                    ra_cust_trx_line_gl_dist subdist
             WHERE
                    subdist.customer_trx_line_id = lines.customer_trx_line_id
             AND    subdist.account_set_flag     = 'N'
             AND    subdist.gl_date              IS NOT NULL
             AND    subdist.account_class        = 'FREIGHT'
            );

      l_rows := sql%rowcount;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug( 'Freight lines inserted: ' ||
                           l_rows);
         arp_standard.debug(   'arp_auto_rule.create_other_freight()- ' ||
                         TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
      END IF;

      RETURN( l_rows );

EXCEPTION
   WHEN OTHERS THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_auto_rule.create_other_freight()');
           arp_standard.debug( SQLERRM);
           arp_standard.debug(   'arp_auto_rule.create_other_freight()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( -1 );

END create_other_freight;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   update_durations                                                      |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Increment autorule_duration_processed and autorule_complete_flag for |
 |    lines for which we have created distributions.                       |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   row count of number of records updated.                               |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-JAN-93  Nigel Smith        created.                               |
 |    11-MAY-93  Charlie Tomberg    Rewrote to perform the desired function|
 |    20-MAR-98  S.Jandyala         Modified the function to update        |
 |                                  by trx_id                              |
 |    05-OCT-00  Jon Beckett        BUG 1551488 Deferred revenue           |
 |    19-SEP-02  J Beckett          Bug 2560048 RAM-C - revenue can be     |
 |                                  deferred on arrears or deferred due to |
 |                                  collectibility decision                |
 |    09-OCT-02  J Beckett          Bug 2560048: above only applies to     |
 |                                  advance invoicing rule                 |
 |    29-JAN-03  O RASHID           Added the fix for bug # 2774432.       |
 |                                  credit memos on ramc invoices with     |
 |                                  rules should stamp the                 |
 |                                  autorule_complete_flag.                |
 |    19-FEB-03  M Raymond          Bug 2584263 - redesigned logic in
 |                                  this function to always update any
 |                                  transactions where distributions were
 |                                  created.
 |    07-MAR-04  M Raymond          Bug 3416070 - created branched logic
 |                                  that utilizes request_id when it is
 |                                  present or skips it when it is null
 +-------------------------------------------------------------------------*/


FUNCTION update_durations( p_trx_id IN NUMBER )

         RETURN NUMBER IS
l_rows NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN

       arp_standard.debug(  'arp_auto_rule.update_durations()+ ' ||
                       TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;

    /* This statement needs to update the autorule_complete_flag
       and autorule_duration_processed for any transactions that
       were picked up by the rev rec process.  This includes:

       o INV w/ rules
       o INV w/ deferred rules
       o INV that are non-collectible
       o CMs targeting above transactions
       o Either type of transaction if tax or customer is modified

       We can do this based on the existance of a row with the
       rev rec request_id because, at this time, no transaction will
       ever intentionally pass through revenue recognition more
       than once.  The EXISTS clause is really just a safety net
       to prevent us from flagging transactions that did not, for
       other reasons, process.
    */

    /* Bug 3416070/3403067 - Modified update to only be dependent on
       request_id when one is set.  ARP_ALLOCATIONS_PKG calls this
       code without one. */
  /*4578927 suppressed the index on autorule_complete_flag*/
  IF arp_standard.profile.request_id IS NOT NULL
  THEN
    /* Existing logic - request_id is set */

    update ra_customer_trx_lines ul
    set    autorule_complete_flag = null,
           autorule_duration_processed =
              accounting_rule_duration,
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           program_application_id = arp_standard.application_id,
           program_update_date = sysdate,
           program_id = arp_standard.profile.program_id
    where  customer_trx_id = p_trx_id
    and    autorule_complete_flag||'' = 'N'
    and   (exists (select 'at least one distribution'
                   from  ra_cust_trx_line_gl_dist gl
                   where gl.customer_trx_line_id = ul.customer_trx_line_id
                   and   gl.account_set_flag = 'N'
                   and   gl.request_id = arp_standard.profile.request_id)
      or   exists (select 'a distribution for a linked line'
                   from  ra_customer_trx_lines tl,
                         ra_cust_trx_line_gl_dist tgl
                   where tl.customer_trx_id = ul.customer_trx_id
                   and   tl.link_to_cust_trx_line_id = ul.customer_trx_line_id
                   and   tgl.customer_trx_line_id = tl.customer_trx_line_id
                   and   tgl.account_set_flag = 'N'
                   and   tgl.request_id = arp_standard.profile.request_id));

  ELSE
     /* Request_id is not set */
    update ra_customer_trx_lines ul
    set    autorule_complete_flag = null,
           autorule_duration_processed =
              accounting_rule_duration,
           last_update_date = sysdate,
           last_updated_by = arp_standard.profile.user_id,
           program_application_id = arp_standard.application_id,
           program_update_date = sysdate,
           program_id = arp_standard.profile.program_id
    where  customer_trx_id = p_trx_id
    and    autorule_complete_flag||'' = 'N'
    and   (exists (select 'at least one distribution'
                   from  ra_cust_trx_line_gl_dist gl
                   where gl.customer_trx_line_id = ul.customer_trx_line_id
                   and   gl.account_set_flag = 'N')
      or   exists (select 'a distribution for a linked line'
                   from  ra_customer_trx_lines tl,
                         ra_cust_trx_line_gl_dist tgl
                   where tl.customer_trx_id = ul.customer_trx_id
                   and   tl.link_to_cust_trx_line_id = ul.customer_trx_line_id
                   and   tgl.customer_trx_line_id = tl.customer_trx_line_id
                   and   tgl.account_set_flag = 'N'));

  END IF;

      l_rows := sql%rowcount;

   IF (PG_DEBUG = 'Y') THEN
      arp_standard.debug('  rows updated: ' ||
                      l_rows);

      arp_standard.debug(  'arp_auto_rule.update_durations()- ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS' || cr));
   END IF;

   RETURN( l_rows );

EXCEPTION
   WHEN OTHERS THEN

        arp_standard.debug('EXCEPTION: arp_auto_rule.update_durations()');
        arp_standard.debug(SQLERRM);
        arp_standard.debug(  'arp_auto_rule.update_durations()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));

        RETURN( -1 );

END update_durations;


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
 | CALLS                                                                   |
 |    populate_glp_table                                                   |
 |    create_assignments                                                   |
 |    create_round                                              |
 |    create_other_receivable                                              |
 |    create_other_plug                                                    |
 |    create_other_freight                                                 |
 |    update_durations                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |    stats structure, with rowcount for each major operation              |
 |                                                                         |
 | EXCEPTIONS RAISED                                                       |
 |    None                                                                 |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 |    stats := auto_rule.create_distributions(                             |
 |                        p_commit_at_end,                                 |
 |                        p_debug_flag);                                   |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |    22-Jan-93  Nigel Smith        Created.                               |
 |    04-Apr-98  Srini Jandyala     Redesigned the function to create      |
 |                                  distribution by customer_trx_id.       |
 |                                  Removed gl_date range and create all   |
 |                                  distributions the first time it runs   |
 |                                  for a transaction with rules.          |
 |    11-Sep-98  Ramakant Alat      Added call to create_round and changed |
 |                                  RECORD stat_type (added round)         |
 |    15-MAY-02  M Raymond          Bug 2150541 - Added parameter that
 |                                  allows us to supress rounding call
 |                                  This is specifically for diagnosing
 |                                  rounding-related problems.
 |    08-JUL-02  M Raymond          Bug 2399504 - Added parameter that
 |                                  permits us to override the on-error-
 |                                  halt behavior for bad lines.  This
 |                                  means that the only
 |                                  remaining ungenerated transactions
 |                                  after a run
 |                                  (with this parameter set) would be those
 |                                  that had some problem.
 |    01-OCT-02  M Raymond          Bug 2552858 - Swapped positions of
 |                                  create_other_rec and create_round to
 |                                  make sure REC row exists when ROUND row
 |                                  is created.
 |    25-FEB-03  M Raymond          Bug 2649674 - Added logic to allow
 |                                  report to end (WARNING) if transactions
 |                                  were skipped based on p_continue_on_error
 |    17-SEP-04  M Raymond          Bug 3879222 - Moved call-once logic around
 |                                  populate_glp_table inside the routine.
 +-------------------------------------------------------------------------*/

FUNCTION create_distributions( p_commit IN VARCHAR2,
                               p_debug  IN VARCHAR2,
                               p_trx_id IN NUMBER,
                               p_suppress_round IN VARCHAR2,
                               p_continue_on_error IN VARCHAR2)
         RETURN NUMBER IS

TYPE  stat_type is RECORD -- Return statistics from create_distributions
(
    assignments NUMBER := 0,  -- Number of new rev distributions created
    round       NUMBER := 0,  -- Number of new round distributions created
    receivables NUMBER := 0,  -- Number of new receivable distributions created
    tax         NUMBER := 0,  -- Number of new tax distributions created
    freight     NUMBER := 0,  -- Number of new freight distributions created
    plugs       NUMBER := 0,  -- Number of new plug distributions created
    durations   NUMBER := 0   -- Number of durations updated.
);

   /* Cursor selects all the transactions for which distributions are not
      completely created. */

   /* Bug 2133254 - Changed code from using a single c_trx cursor to
      using either c_trx or c_trx_no_id cursors.  (in Bug 2122202,
      we had done this with dynamic cursors - but this caused the
      cursors to be reparsed. */

   /* Bug 2399504 - Added the autorule_duration_processed
      condition to both cursors.  This should help avoid
      problems with CMs that are not flagged properly */

 /*Change for bug-5444411 to suppress index on autorule_complete_flag*/
      CURSOR c_trx IS
          SELECT
                 ct.customer_trx_id,
                 ct.trx_number,
		 ct.upgrade_method -- Bug 8478031
          FROM
                 ra_customer_trx ct
          WHERE
                 ct.complete_flag           = 'Y'
          AND    ct.customer_trx_id         = p_trx_id
          AND EXISTS (
               SELECT 'line needing dists'
               FROM   ra_customer_trx_lines ctl
               WHERE  ctl.customer_trx_id = ct.customer_trx_id
	       AND    ctl.autorule_complete_flag||'' = 'N'
               AND    (ctl.autorule_duration_processed <
                       ctl.accounting_rule_duration OR
                       ctl.autorule_duration_processed is NULL))
          FOR UPDATE OF ct.customer_trx_id; -- ref bug 8269482

      /* bug3282969 added nvl func for performance */
      CURSOR c_trx_no_id IS
          SELECT
                 DISTINCT ctl.customer_trx_id,
                 ct.trx_number,
 		 ct.upgrade_method -- Bug 8478031
          FROM
                 ra_customer_trx ct,
                 ra_customer_trx_lines ctl
          WHERE
                 ctl.autorule_complete_flag = 'N'
          AND    nvl(ctl.autorule_duration_processed,-2) <
                  nvl(ctl.accounting_rule_duration,-1)
          AND    ct.customer_trx_id         = ctl.customer_trx_id
          AND    ct.complete_flag           = 'Y';

stats              STAT_TYPE;
period_set_name    VARCHAR(15);
error_message      FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE; -- Bug 4127356
base_precision     NUMBER;
base_min_acc_unit  NUMBER;  -- base_minimum_accountable_unit
num_round_err_corr NUMBER;  -- num_rounding_errors_corrected

i                  NUMBER;
trx_id             NUMBER;
trx_num            VARCHAR(30);
sum_dist_created   NUMBER := 0;
trx_dist_created   NUMBER := 0;
return_warning     BOOLEAN := FALSE;
--Bug#2750340
l_xla_ev_rec       arp_xla_events.xla_events_type;

l_invoice_class    ar_payment_schedules.class%TYPE;
l_lock             VARCHAR2(30);

-- Bug 8478031
l_customer_trx     ra_customer_trx%ROWTYPE;
upgrade_method     ra_customer_trx.upgrade_method%TYPE;
l_return_status    VARCHAR2(1)   := fnd_api.g_ret_sts_success;
l_msg_data         VARCHAR2(2000);
l_msg_count        NUMBER;

BEGIN

   IF (p_debug = 'Y')
   THEN
       arp_standard.enable_debug;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'arp_auto_rule.create_distributions()+ ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
      arp_standard.debug( 'debug = '|| p_debug ||', commit = ' || p_commit);
      arp_standard.debug( 'round = ' || p_suppress_round || ', continue on error = ' ||
                           p_continue_on_error);
   END IF;

--   11i OE/OM change
--   fnd_profile.get( 'SO_ORGANIZATION_ID', org_id );
   oe_profile.get( 'SO_ORGANIZATION_ID', org_id );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'org_id = '|| to_char(org_id));
   END IF;

   stats.round       := 0;
   stats.receivables := 0;
   stats.plugs       := 0;
   stats.tax         := 0;
   stats.freight     := 0;
   stats.durations   := 0;

   /*-----------------------------------------------------------------------+
    | Validate each of the extended who columns                             |
    +-----------------------------------------------------------------------*/

   IF  arp_standard.profile.request_id IS NULL
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('create_distributions(): NULL Request_id');
        END IF;
        arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER',
                     'OBJECT', 'AUTO_RULE.CREATE_DISTRIBUTIONS',
                     'PARAMETER', 'ARP_STANDARD.PROFILE.REQUEST_ID' );
   END IF;

   IF  arp_standard.profile.program_id IS NULL
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('create_distributions(): NULL Program_id');
        END IF;
        arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER',
                     'OBJECT', 'AUTO_RULE.CREATE_DISTRIBUTIONS',
                     'PARAMETER', 'ARP_STANDARD.PROFILE.PROGRAM_ID' );
   END IF;

   IF  arp_standard.profile.user_id IS NULL
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('create_distributions(): NULL User_id');
        END IF;
        arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER',
                     'OBJECT', 'AUTO_RULE.CREATE_DISTRIBUTIONS',
                     'PARAMETER', 'ARP_STANDARD.PROFILE.USER_ID' );
   END IF;

   IF  arp_standard.application_id IS NULL
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('create_distributions(): NULL Program_app_id');
        END IF;
        arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER',
                     'OBJECT', 'AUTO_RULE.CREATE_DISTRIBUTIONS',
                     'PARAMETER', 'ARP_STANDARD.APPLICATION_ID' );
   END IF;

   IF  arp_standard.profile.last_update_login IS NULL
   THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('create_distributions(): NULL Last_update_login');
        END IF;
        arp_standard.fnd_message( 'AR_PP_NULL_PARAMETER',
                     'OBJECT', 'AUTO_RULE.CREATE_DISTRIBUTIONS',
                     'PARAMETER', 'ARP_STANDARD.PROFILE.LAST_UPDATE_LOGIN' );
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('create_distributions(): Passed validation');
   END IF;

  /*---------------------------------------------------+
    | Get the period_set_name and currency information |
    +--------------------------------------------------*/

   SELECT
	  period_set_name,
          precision,
          minimum_accountable_unit
   INTO
	  period_set_name,
          base_precision,
          base_min_acc_unit
   FROM
          fnd_currencies fc,
	  gl_sets_of_books gsb,
          ar_system_parameters asp
   WHERE
	  gsb.set_of_books_id = asp.set_of_books_id
   AND    fc.currency_code    = gsb.currency_code;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(
	'create_distributions(): '||
        '    Period Set: '|| period_set_name ||
        '    Base Precision: '|| base_precision ||
        '    Base Minimum Accountable Unit: ' ||
               NVL(base_min_acc_unit, 0));
   END IF;

   /* Populate the GL periods PL/SQL table. */
   populate_glp_table(arp_standard.sysparm.set_of_books_id,
                      arp_standard.application_id);

/* DEBUG INFO. */
/*      FOR i IN 1..rows LOOP

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(
                'index = '||i||', '||
                TO_CHAR(gl_start_t(i), 'DD-MON-RRRR')||', '||
                TO_CHAR(gl_end_t(i), 'DD-MON-RRRR')||', '||
                gl_status_t(i)||', '||
                TO_CHAR(gl_bump_t(i), 'DD-MON-RRRR') );
            END IF;

        END LOOP;
*/

     /* Bug 2122202/2133254 - open appropriate cursor using
        different sql depending on
        whether p_trx_id is null or not. */

     IF (p_trx_id IS NOT NULL) THEN
        /* This is the modified logic using a sub-query - bug 2122202 */
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('p_trx_id is NOT null, using subquery');
        END IF;

        OPEN c_trx;
     ELSE
        /* This is almost exactly like original select */
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('p_trx_id is null, using joined tables');
        END IF;

        OPEN c_trx_no_id;
     END IF;

     LOOP   /* Loop through all transactions returned by cusror trx_id */

<<next_trx>>

        /* Bug 2133254 - Fetch from correct cursor */
        IF (p_trx_id IS NOT NULL) THEN
           FETCH c_trx INTO trx_id, trx_num,upgrade_method;
           EXIT WHEN c_trx%NOTFOUND;
        ELSE
           FETCH c_trx_no_id INTO trx_id, trx_num,upgrade_method;
           EXIT WHEN c_trx_no_id%NOTFOUND;

	   --lock header record to avoid data corruption ref bug 8269482
	   SELECT 'LOCK'
	   INTO l_lock
	   FROM ra_customer_trx
	   WHERE customer_trx_id = trx_id
	   FOR UPDATE OF customer_trx_id;
        END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(
		'Creating distributions for trx_number = '|| trx_num);
        END IF;

        /*------------------------------------------------------------------+
         | Generate new account distributions, building plug, tax, freight  |
         | and receivable accounts as well as standard distributions        |
         +------------------------------------------------------------------*/

         trx_dist_created := 0;

         SAVEPOINT AR_AUTORULE_1;

         stats.assignments := create_assignments(
				trx_id,
                               	period_set_name,
                               	base_precision,
                                base_min_acc_unit );

         IF   (stats.assignments = -2)
         THEN

             glp_index_start := 1;    /* reset glp table index, start */
             glp_index_end   := g_rows; /* reset glp table index, end */

             GOTO next_trx;

         END IF;

         /*
            If create_assignments() fails, rollback and exit function.
         */

         IF   (stats.assignments = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             /* Bug 2399504 - added handler for p_continue_on_error */
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.assignments;

         stats.receivables := create_other_receivable(
				trx_id,
                                base_precision,
                                base_min_acc_unit );

         /*
            If create_other_receivable() fails, rollback and exit function.
         */

         IF   (stats.receivables = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             /* Bug 2399504 - added handler for p_continue_on_error */
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.receivables;

         stats.round := create_round(
				trx_id,
                                base_precision,
                                base_min_acc_unit );

         /*
            If create_round() fails, rollback and exit function.
         */

         IF   (stats.round = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.round;

         stats.plugs       := create_other_plug(
				trx_id,
                                base_precision,
                                base_min_acc_unit );
        /* Bug 5450534 FP of 5260489 check for status to make a
            recursive call to create other plug*/
        /* 6782405 - Revised this logic (internal to create_other_plug)
           so that it only returns -99 if set_rec_offset_flag was
           able to do anything.  Otherwise it returns rows as-is and
           continues or fails accordingly */
        IF stats.plugs = -99
        THEN
          stats.plugs := create_other_plug(
                                trx_id,
                                base_precision,
                                base_min_acc_unit );
          /* This would only be -99 the second time if the second call
             to set_rec_offset_flag updated more rows (should really never happen) */
          IF stats.plugs = -99
          THEN
            stats.plugs := -1;
          END IF;
        END IF;

         /*
            If create_other_plug() fails, rollback and exit function.
         */

         IF   (stats.plugs = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             /* Bug 2399504 - added handler for p_continue_on_error */
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.plugs;

         stats.tax         := create_other_tax(
				trx_id,
                                base_precision,
                                base_min_acc_unit );

         /*
            If create_other_tax() fails, rollback and exit function.
         */

         IF   (stats.tax = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             /* Bug 2399504 - added handler for p_continue_on_error */
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.tax;

         stats.freight     := create_other_freight(
				trx_id,
                                base_precision,
                                base_min_acc_unit );

         /*
            If create_other_freight() fails, rollback and exit function.
         */

         IF   (stats.freight = -1)
         THEN
             ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
             /* Bug 2399504 - added handler for p_continue_on_error */
             IF (p_continue_on_error IS NULL) THEN
                RETURN( -1 );
             ELSE
                return_warning := TRUE;
                GOTO next_trx;
             END IF;
         END IF;

         trx_dist_created  := trx_dist_created + stats.freight;

         /* Update durations processed and correct rounding errors ONLY if any
            distributions are created for this transaction in this run. */

         IF ( trx_dist_created > 0 )
         THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'trx_id = '|| trx_id ||
                          ', distributions created = '|| trx_dist_created);
            END IF;

            stats.durations := update_durations(trx_id);

            /*
               If update_durations() fails, rollback and exit function.
            */

            IF   (stats.durations = -1)
            THEN
                ROLLBACK TO SAVEPOINT AR_AUTORULE_1;
                /* Bug 2399504 - added handler for p_continue_on_error */
                IF (p_continue_on_error IS NULL) THEN
                   RETURN( -1 );
                ELSE
                   return_warning := TRUE;
                   GOTO next_trx;
                END IF;
            END IF;
            /* Bug 2150541 - allow bypass of rounding
               for diagnostic purposes */
            IF (p_suppress_round IS NULL)
            THEN

               /* Bug 2497841 - Allow bypass of set_rec_offset_flag
                  routine inside rounding logic */
               IF (arp_rounding.correct_dist_rounding_errors(
                        NULL,
                        trx_id,
                        NULL,
                        num_round_err_corr,
                        error_message,
                        NULL,
                        NULL,
                        'ALL',
                        'Y',
                        p_debug,
                        arp_global.sysparam.trx_header_level_rounding,
                        'N',
                        'N') = 0 )
               THEN

                  ROLLBACK TO SAVEPOINT AR_AUTORULE_1;

                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_standard.debug('create_distributions(): '|| error_message);
                  END IF;

                  /* Bug 2399504 - added handler for p_continue_on_error */
                  IF (p_continue_on_error IS NULL) THEN
                    /* This FND_MESSAGE call halts execution of program */
                    arp_standard.fnd_message( 'GENERIC_MESSAGE',
                                         'GENERIC_TEXT', error_message);
                    RETURN( -1 );
                  ELSE
                    return_warning := TRUE;
                    GOTO next_trx;
                  END IF;

               ELSE

                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_standard.debug(
                     'Rounding errors corrected for:  '||
                     num_round_err_corr || ' rows.');
                  END IF;

               END IF;	/* rounding */

            ELSE
               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug( 'ROUNDING SUPPRESSED!');
               END IF;
            END IF;

            /* All the distributions are created, rounding done, so we can
               safely commit here, if, Rev Rec is run in COMMIT mode. */

           -- 8478031 Calling Line Level balance stamping routine if Upgrade methosd is R12.

	    IF upgrade_method = 'R12' THEN
	      l_customer_trx.customer_trx_id := trx_id;
	       ARP_DET_DIST_PKG.set_original_rem_amt_r12(
	        p_customer_trx => l_customer_trx,
		x_return_status   =>  l_return_status,
		x_msg_count       =>  l_msg_count,
		x_msg_data        =>  l_msg_data,
		p_from_llca       => 'N');

		 IF l_return_status <> fnd_api.g_ret_sts_success THEN
		   arp_standard.debug( 'Error while stamping line level balance. Trx Id - '|| trx_id);
		END IF;
            END IF;

	    -- END 8478031

            /****************************************************************
             * Bug 8206609 - Do not call create_events if the session is an *
             * Autoinvoice session and call is for a credit Memo, as this   *
             * will be called in autoinvoice in bulk by request_id. The call*
             * here is restricted to avoid duplicate event/entity creation. *
             ****************************************************************/
            BEGIN
                SELECT max(class) INTO l_invoice_class FROM ar_payment_schedules
                WHERE customer_trx_id = trx_id;
            EXCEPTION
                WHEN OTHERS THEN
                    l_invoice_class := 'NOT_CM';
            END;

            IF g_autoinv AND l_invoice_class = 'CM' THEN
                IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug( 'Not calling create_events as this is an Autoinvoice session and for a Credit Memo.');
                END IF;
            ELSE
                l_xla_ev_rec.xla_from_doc_id := trx_id;
                l_xla_ev_rec.xla_to_doc_id   := trx_id;
                l_xla_ev_rec.xla_doc_table := 'CT';
                l_xla_ev_rec.xla_mode := 'O';
                l_xla_ev_rec.xla_call := 'B';
                l_xla_ev_rec.xla_fetch_size := 999;
                ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
            END IF;

            IF (p_commit = 'Y')
            THEN
                COMMIT WORK;
            END IF;

         ELSE

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug( 'trx_id = '|| trx_id ||
                  ', distributions created = '|| trx_dist_created);
            END IF;

         END IF;	/* if (trx_dist_created > 0) */

         sum_dist_created := sum_dist_created + nvl(trx_dist_created,0);

         glp_index_start := 1;    /* reset glp table index, start */
         glp_index_end   := g_rows; /* reset glp table index, end */


     END LOOP;	/* Cursor trx_id loop */

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  'create_distributions(): ' ||
                           'Total number of create_distributions created = '||
                           TO_CHAR(NVL(sum_dist_created, 0)));
        END IF;

     /* Bug 2118867 - close those cursors */
     IF (p_trx_id IS NOT NULL) THEN
        CLOSE c_trx;
     ELSE
        CLOSE c_trx_no_id;
     END IF;

     /* Bug 2649674 - Return WARNING if something went wrong for at
        least one transaction that was processed by this (single thread)
        run.  */
     IF (return_warning AND p_trx_id IS NULL)
     THEN
         arp_standard.debug('Attempting to set WARNING return status');
         error_message := FND_MESSAGE.GET_STRING('AR','ARBARL_WARN_BAD_TRX');

         IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', error_message) = FALSE)
         THEN
               arp_standard.debug('Unable to set WARNING return status');
         END IF;
     END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug(  'arp_auto_rule.create_distributions()- ' ||
                           TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( NVL(sum_dist_created, 0) );

END create_distributions;

BEGIN
    /* Bug 2560048: check if revenue management is installed */
    IF ar_revenue_management_pvt.revenue_management_enabled
    THEN
      g_rev_mgt_installed := 'Y';
    ELSE
      g_rev_mgt_installed := 'N';
    END IF;

    /* 5598773 - get profile for USE_INV_ACCT */
    fnd_profile.get('AR_USE_INV_ACCT_FOR_CM_FLAG',
                    g_use_inv_acctg );
    IF g_use_inv_acctg IS NULL
    THEN
       g_use_inv_acctg := 'N';
    END IF;

   /***************************************************************
    * 8206609 - Detect if this is an autoinvoice session. If yes, *
    *           set g_autoinv to TRUE, otherwise FALSE.           *
    ***************************************************************/
    BEGIN

       SELECT req.request_id
       INTO   g_autoinv_request_id
       FROM  fnd_concurrent_programs prog,
             fnd_concurrent_requests req
       WHERE req.request_id = FND_GLOBAL.CONC_REQUEST_ID
       AND   req.concurrent_program_id = prog.concurrent_program_id
       AND   prog.application_id = 222
       AND   prog.concurrent_program_name = 'RAXTRX';

       IF g_autoinv_request_id is not NULL
       THEN
          g_autoinv := TRUE;
       ELSE
          /* Dummy condition, never gets executed */
          g_autoinv := FALSE;
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
          g_autoinv := FALSE;
    END;

END ARP_AUTO_RULE;

/
