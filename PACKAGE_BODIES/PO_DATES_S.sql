--------------------------------------------------------
--  DDL for Package Body PO_DATES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DATES_S" AS
/* $Header: POXCODAB.pls 115.9 2004/05/26 00:34:59 spangulu ship $*/
/*===========================================================================

  FUNCTION NAME:	val_open_period()

===========================================================================*/

FUNCTION val_open_period(x_trx_date IN DATE,
			 x_sob_id   IN NUMBER,
			 x_app_name IN VARCHAR2,
			 x_org_id   IN NUMBER) RETURN BOOLEAN IS

/*
**  Function checks if inventory or purchasing is installed.  If not, returns
**  'TRUE'.  If so,  checks if date is in an open inventory or purchasing
**  period by calling get_closing_status.  For GL, always calls
**  get_closing_status to check if date is in an open GL period.  Returns
**  TRUE if the period is open, FALSE otherwise.
*/

x_progress VARCHAR2(3) := NULL;

BEGIN
   x_progress := '000';

/* bao - cache values to reduce the number of select statements */
/* Bug 3647086: forward port fix; removed caching logic of the closed
 * status for po, inv, and gl; caching for these values
 * is  not working correctly in some cases.
 * Kept caching for install status and app id, which are working fine.
 */

   IF (x_app_name = 'PO') THEN

     IF (PO_DATES_S.x_po_install_status is NULL) THEN
       /* derive and cache po_install_status */
       PO_DATES_S.x_po_install_status := PO_CORE_S.get_product_install_status(x_app_name);
     END IF;

     IF (PO_DATES_S.x_po_install_status = 'I') THEN

       IF (PO_DATES_S.x_po_app_id IS NULL) THEN
           /* derive and cache app_id */
           PO_DATES_S.x_po_app_id := get_app_id(x_app_name);
       END IF;

       -- Bug 3647806: Remove caching of po_closed_status
       IF (PO_DATES_S.get_closing_status( x_trx_date => x_trx_date
                                        , x_sob_id   => x_sob_id
                                        , x_app_id   => PO_DATES_S.x_po_app_id
                                        )
                     NOT IN ('O', 'F'))
       THEN
           RETURN(FALSE);
       END IF;

    END IF; /* x_po_install_status = 'I' */

   ELSIF (x_app_name = 'INV') THEN

     IF (PO_DATES_S.x_inv_install_status is NULL) THEN
       /* derive and cache inv_install_status */
       PO_DATES_S.x_inv_install_status := PO_CORE_S.get_product_install_status(x_app_name);
     END IF;

     IF (PO_DATES_S.x_inv_install_status = 'I') THEN

       -- Bug 3647806: Store inv_app_id in x_inv_app_id
       -- Also, changed get_app_id('SQLGL') to get_app_id('INV'), which is correct for inv
       IF (PO_DATES_S.x_inv_app_id is NULL) THEN
           PO_DATES_S.x_inv_app_id := get_app_id('INV');
       END IF;

       -- Bug 3647806: Remove caching of inv_closed_status
       IF (PO_DATES_S.get_acct_period_status( x_trx_date => x_trx_date
                                            , x_sob_id   => x_sob_id
                                            , x_app_id   => PO_DATES_S.x_inv_app_id
                                            , x_org_id   => x_org_id
                                            )
                     NOT IN ('O', 'F'))
       THEN
           RETURN(FALSE);
       END IF;

     END IF; /* x_inv_install_status = 'I' */

   ELSE


     /* Bug 3647806: Also cached gl install status. */
     IF (x_app_name = 'SQLGL') THEN

       IF (PO_DATES_S.x_sqlgl_install_status is NULL) THEN
         /* derive and cache gl_install_status */
         PO_DATES_S.x_sqlgl_install_status := PO_CORE_S.get_product_install_status(x_app_name);
       END IF;

     END IF;

     IF ((PO_DATES_S.x_sqlgl_install_status = 'I') OR
        (PO_CORE_S.get_product_install_status(x_app_name) = 'I')) THEN

       IF (PO_DATES_S.x_sqlgl_app_id is NULL) THEN
           /* derive and cache gl_app_id in x_sqlgl_app_id */
           PO_DATES_S.x_sqlgl_app_id := get_app_id('SQLGL');
       END IF;

       -- Bug 3647806: Remove caching of gl_closed_status
       IF (PO_DATES_S.get_closing_status( x_trx_date => x_trx_date
                                        , x_sob_id   => x_sob_id
                                        , x_app_id   => PO_DATES_S.x_sqlgl_app_id
                                        )
                     NOT IN ('O', 'F'))
       THEN
           RETURN(FALSE);
       END IF;

     END IF; /* get_product_install_status = 'I' */

   END IF;

   RETURN(TRUE);

EXCEPTION

   WHEN OTHERS THEN
      po_message_s.sql_error('val_open_period', x_progress, sqlcode);
      RAISE;

END val_open_period;

/*===========================================================================

  FUNCTION NAME:	get_app_id()

===========================================================================*/

FUNCTION get_app_id(x_app_name IN VARCHAR2) RETURN NUMBER IS

/*
**  Function determines the application id using the application short name
**  passed in.
*/

x_progress VARCHAR2(3) := NULL;
x_app_id NUMBER := NULL;

BEGIN
   x_progress := '010';

   SELECT application_id
   INTO   x_app_id
   FROM   fnd_application
   WHERE  application_short_name = x_app_name ;

   RETURN(x_app_id);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_app_id', x_progress, sqlcode);
   RAISE;

END get_app_id;
/*===========================================================================

  FUNCTION NAME:	get_closing_status()

===========================================================================*/

FUNCTION get_closing_status(x_trx_date IN DATE,
		       	    x_sob_id   IN NUMBER,
		    	    x_app_id   IN NUMBER) RETURN VARCHAR2 IS

/*
**  Function determines the application id using the application short name
**  passed in.  It returns period closing status.
*/

x_progress VARCHAR2(3) := NULL;
x_closing_status VARCHAR2(1) := NULL;

BEGIN

   x_progress := '010';

   SELECT ps.closing_status
   INTO   x_closing_status
   FROM   gl_period_statuses ps
   WHERE  ps.application_id = x_app_id
   AND	  ps.adjustment_period_flag = 'N'
   AND    ps.set_of_books_id = x_sob_id
   AND    trunc(x_trx_date) BETWEEN trunc(nvl(ps.start_date, x_trx_date))
                            AND     trunc(nvl(ps.end_date, x_trx_date))
   AND    ps.adjustment_period_flag = 'N';

   RETURN(x_closing_status);

   EXCEPTION
   WHEN NO_DATA_FOUND then
      po_message_s.app_error('PO_PO_ENTER_OPEN_GL_DATE');
      RAISE;
   WHEN TOO_MANY_ROWS then
      po_message_s.app_error(''); --bad data in gl_period_statuses
      RAISE;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_closing_status', x_progress, sqlcode);
      RAISE;

END get_closing_status;

/*===========================================================================

  FUNCTION NAME:	get_acct_period_status()

===========================================================================*/

FUNCTION get_acct_period_status(x_trx_date IN DATE,
		       	        x_sob_id   IN NUMBER,
				x_app_id   IN NUMBER,
		    	        x_org_id   IN NUMBER) RETURN VARCHAR2 IS

/*
**  Function returns accounting period closing status.
*/

x_progress        VARCHAR2(3) := NULL;
x_closing_status  VARCHAR2(1) := NULL;
x_open_flag       VARCHAR2(1) := NULL;

BEGIN

   x_progress := '010';

  /* SELECT glps.closing_status
   INTO   x_closing_status
   FROM   org_acct_periods oap,
          gl_period_statuses glps,
          gl_periods glp
   WHERE  oap.organization_id = x_org_id
   AND    oap.period_set_name  = glp.period_set_name
   AND    oap.period_name = glp.period_name   -- Bug 873654
   AND    glp.period_name = glps.period_name
   AND   (trunc(x_trx_date)
          BETWEEN trunc(oap.period_start_date) AND
          trunc(nvl(oap.period_close_date, oap.schedule_close_date)))
   AND    oap.open_flag = 'Y'
   AND   (trunc(x_trx_date)
         BETWEEN trunc(glps.start_date) AND trunc(glps.end_date))
   AND    glps.set_of_books_id = x_sob_id
   AND    glps.application_id  = x_app_id
   AND    glps.adjustment_period_flag = 'N';
*/
   SELECT oap.open_flag
   INTO   x_open_flag
   FROM   org_acct_periods oap
   WHERE  oap.organization_id = x_org_id
   AND   (trunc(x_trx_date)
          BETWEEN trunc(oap.period_start_date) AND
          trunc(nvl(oap.period_close_date, oap.schedule_close_date)))
   AND    oap.open_flag = 'Y';

   if (x_open_flag = 'Y') then
      x_closing_status := 'O';
   end if;

   RETURN(x_closing_status);

   EXCEPTION
   WHEN NO_DATA_FOUND then
      po_message_s.app_error('PO_INV_NO_OPEN_PERIOD');
      RAISE;
   WHEN TOO_MANY_ROWS then
      po_message_s.app_error('PO_INV_MUL_PERIODS');
      RAISE;
   WHEN OTHERS THEN
      po_message_s.sql_error('get_acct_period_status', x_progress, sqlcode);
      RAISE;

END get_acct_period_status;

END PO_DATES_S;

/
