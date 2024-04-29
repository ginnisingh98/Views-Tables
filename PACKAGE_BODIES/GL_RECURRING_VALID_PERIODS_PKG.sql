--------------------------------------------------------
--  DDL for Package Body GL_RECURRING_VALID_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RECURRING_VALID_PERIODS_PKG" AS
/* $Header: glirjvpb.pls 120.4 2005/05/05 01:20:38 kvora ship $ */
--
-- PUBLIC FUNCTIONS
--

PROCEDURE get_next_period(
        x_ledger_id             NUMBER,
	x_recurring_batch_id    NUMBER,
        x_period                VARCHAR2,
        x_next_period   IN OUT NOCOPY VARCHAR2 )  IS

  CURSOR c_period IS
    SELECT vp1.period_name
    FROM   gl_recurring_valid_periods_v vp1,
           gl_recurring_valid_periods_v vp2
    WHERE  vp1.ledger_id = x_ledger_id
    AND    vp2.ledger_id = x_ledger_id
    AND    vp1.recurring_batch_id = x_recurring_batch_id
    AND    vp2.recurring_batch_id = x_recurring_batch_id
    AND    vp2.period_name = x_period
    AND    ( vp1.start_date =
               ( SELECT MIN( vp3.start_date )
                 FROM   gl_recurring_valid_periods_v vp3
                 WHERE  vp3.ledger_id = x_ledger_id
		 AND    vp3.recurring_batch_id = x_recurring_batch_id
                 AND    vp3.start_date > vp2.start_date ) );

  BEGIN
    OPEN c_period;
    FETCH c_period INTO x_next_period;
    CLOSE c_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_recurring_valid_periods_pkg.get_next_period');
      RAISE;

  END get_next_period;


END gl_recurring_valid_periods_pkg;

/
