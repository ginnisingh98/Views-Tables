--------------------------------------------------------
--  DDL for Package Body GL_ARCH_PRG_FROM_PRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ARCH_PRG_FROM_PRD_PKG" AS
/* $Header: glfapfpb.pls 120.5 2005/05/05 02:03:57 kvora ship $ */
    PROCEDURE get_from_prd_bal_act_arch(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- The following SQL statement retrieves the first non-never opened period
-- beyond the latest archived period (if there is one). If the closing_status
-- of the returned row is not permanently closed or if there is no row returned
-- an appropriate error message will be displayed.

      CURSOR get_from_period IS
	SELECT
	      PS.closing_status,
	      PS.period_name,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS
        WHERE
	      PS.application_id          =  x_appl_id
        AND   PS.ledger_id               =  x_ledger_id
        AND   PS.closing_status          <> 'N'
        AND   PS.effective_period_num    >
              (SELECT
                     NVL(MAX(AH.last_archived_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id        =  x_ledger_id
               AND   AH.data_type        =  x_data_type
               AND   AH.actual_flag      =  x_actual_flag)
        ORDER BY PS.effective_period_num ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_closing_status,
		x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    IF (x_closing_status <> 'P') THEN
	      fnd_message.set_name('SQLGL', 'GL_PERIOD_NOT_PERM_CLOSED');
	      app_exception.raise_exception;
	    END IF;
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_from_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_arch');
	  RAISE;
      END get_from_prd_bal_act_arch;


    PROCEDURE get_from_prd_bal_act_purg(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the earliest never purged period. This period must have
-- been archived before.

      CURSOR get_from_period IS
	SELECT
	      PS.closing_status,
	      PS.period_name,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS
        WHERE
	      PS.application_id          =  x_appl_id
        AND   PS.ledger_id               =  x_ledger_id
        AND   PS.closing_status          <> 'N'
        AND   PS.effective_period_num    >
              (SELECT
                     NVL(MAX(AH.last_purged_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id        =  x_ledger_id
               AND   AH.actual_flag      =  x_actual_flag
               AND   AH.data_type        =  x_data_type )
        AND   PS.effective_period_num <=
              (SELECT
                     NVL(MAX(AH.last_archived_eff_period_num), -1)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id        =  x_ledger_id
               AND   AH.data_type        =  x_data_type
               AND   AH.actual_flag      =  x_actual_flag)
        ORDER BY PS.effective_period_num ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_closing_status,
		x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    IF (x_closing_status <> 'P') THEN
	      fnd_message.set_name('SQLGL', 'GL_PERIOD_NOT_PERM_CLOSED');
	      app_exception.raise_exception;
	    END IF;
          ELSE
  	    CLOSE get_from_period;
	    x_closing_status := 'N';
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_purg');
	  RAISE;
      END get_from_prd_bal_act_purg;

    PROCEDURE get_from_prd_bal_act_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the earliest never purged period. This period must have
-- been archived before.

      CURSOR get_from_period IS
	SELECT
	      PS.closing_status,
	      PS.period_name,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS
        WHERE
	      PS.application_id          =  x_appl_id
        AND   PS.ledger_id               =  x_ledger_id
        AND   PS.closing_status          <> 'N'
        AND   PS.effective_period_num    >
              (SELECT
                     NVL(MAX(AH.last_purged_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id        =  x_ledger_id
               AND   AH.data_type        =  x_data_type
               AND   AH.actual_flag      =  x_actual_flag)
        ORDER BY PS.effective_period_num ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_closing_status,
		x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    IF (x_closing_status <> 'P') THEN
	      fnd_message.set_name('SQLGL', 'GL_PERIOD_NOT_PERM_CLOSED');
	      app_exception.raise_exception;
	    END IF;
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_from_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_act_both');
	  RAISE;
      END get_from_prd_bal_act_both;

    PROCEDURE get_from_prd_bal_bud_arch(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the earliest never archived period for the chosen budget.
-- The budget year must be open.

      CURSOR get_from_period IS
	SELECT
	      BPR.start_period_name,
	      ( BPR.period_year * 10000 + BPR.start_period_num )
        FROM
	      GL_BUDGET_PERIOD_RANGES BPR
        WHERE
	      BPR.budget_version_id      =  x_budget_version_id
        AND   BPR.open_flag              =  'O'
        AND   ( BPR.period_year * 10000 + BPR.start_period_num ) >
              (SELECT
                     NVL(MAX(AH.last_archived_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id          =  x_ledger_id
               AND   AH.data_type          =  x_data_type
               AND   AH.actual_flag        =  x_actual_flag
               AND   AH.budget_version_id  =  x_budget_version_id )
        ORDER BY ( BPR.period_year * 10000 + BPR.start_period_num ) ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_from_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_arch');
	  RAISE;
      END get_from_prd_bal_bud_arch;


    PROCEDURE get_from_prd_bal_bud_purg(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the earliest never purged period for the chosen budget.
-- This period must have been archived before.

      CURSOR get_from_period IS
	SELECT
	      BPR.start_period_name,
	      ( BPR.period_year * 10000 + BPR.start_period_num )
        FROM
	      GL_BUDGET_PERIOD_RANGES BPR
        WHERE
	      BPR.budget_version_id      =  x_budget_version_id
        AND   BPR.open_flag              =  'O'
        AND   ( BPR.period_year * 10000 + BPR.start_period_num ) >
              (SELECT
                     NVL(MAX(AH.last_purged_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id          =  x_ledger_id
               AND   AH.data_type          =  x_data_type
               AND   AH.actual_flag        =  x_actual_flag
               AND   AH.budget_version_id  =  x_budget_version_id )
        AND   ( BPR.period_year * 10000 + BPR.start_period_num ) <=
              (SELECT
		     NVL(MAX(AH.last_archived_eff_period_num), 0)
               FROM
		    GL_ARCHIVE_HISTORY AH
               WHERE
		     AH.ledger_id          = x_ledger_id
               AND   AH.data_type          = x_data_type
	       AND   AH.actual_flag        = x_actual_flag
	       AND   AH.budget_version_id  = x_budget_version_id )
        ORDER BY ( BPR.period_year * 10000 + BPR.start_period_num ) ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_from_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_arch');
	  RAISE;
      END get_from_prd_bal_bud_purg;

    PROCEDURE get_from_prd_bal_bud_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
		 	x_from_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_from_period_eff_num   IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the earliest never purged period for the chosen budget.
-- This budget year must be open.

      CURSOR get_from_period IS
	SELECT
	      BPR.start_period_name,
	      ( BPR.period_year * 10000 + BPR.start_period_num )
        FROM
	      GL_BUDGET_PERIOD_RANGES BPR
        WHERE
	      BPR.budget_version_id      =  x_budget_version_id
        AND   BPR.open_flag              =  'O'
        AND   ( BPR.period_year * 10000 + BPR.start_period_num ) >
              (SELECT
                     NVL(MAX(AH.last_purged_eff_period_num), 0)
               FROM
	             GL_ARCHIVE_HISTORY AH
               WHERE
	             AH.ledger_id          =  x_ledger_id
               AND   AH.data_type          =  x_data_type
               AND   AH.actual_flag        =  x_actual_flag
               AND   AH.budget_version_id  =  x_budget_version_id )
        ORDER BY ( BPR.period_year * 10000 + BPR.start_period_num ) ASC;

        BEGIN

          OPEN  get_from_period;
	  FETCH get_from_period
	  INTO  x_from_period,
		x_from_period_eff_num;

  	  IF get_from_period%FOUND THEN
  	    CLOSE get_from_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_from_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_from_prd_bal_bud_arch');
	  RAISE;
      END get_from_prd_bal_bud_both;

    PROCEDURE get_to_prd_trn_both(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the latest ever translated period.

      CURSOR get_to_period IS
	SELECT
	      PS.period_name,
	      PS.closing_status,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS,
	      GL_TRANSLATION_TRACKING TT
        WHERE
	      PS.application_id                    =  x_appl_id
        AND   PS.ledger_id                         =  x_ledger_id
	AND   TT.ledger_id                         =  x_ledger_id
	AND   TT.target_currency                   =  x_currency
	AND   TT.actual_flag                       =  x_actual_flag
	AND   NVL(TT.target_budget_version_id,-1)  =  NVL(x_budget_version_id,-1)
	AND   PS.effective_period_num              >=
	      (TT.earliest_ever_period_year * 10000 + TT.earliest_ever_period_num)
        AND   PS.effective_period_num              <
	      (TT.earliest_never_period_year * 10000 + TT.earliest_never_period_num)
        ORDER BY PS.effective_period_num DESC;

        BEGIN

          OPEN  get_to_period;
	  FETCH get_to_period
	  INTO  x_to_period,
		x_closing_status,
		x_to_period_eff_num;

  	  IF get_to_period%FOUND THEN
  	    CLOSE get_to_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_to_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_to_prd_trn_both');
	  RAISE;
      END get_to_prd_trn_both;

    PROCEDURE get_to_prd_trn_standard(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the latest ever translated period.

      CURSOR get_to_period IS
	SELECT
	      PS.period_name,
	      PS.closing_status,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS,
	      GL_TRANSLATION_TRACKING TT
        WHERE
	      PS.application_id                    =  x_appl_id
        AND   PS.ledger_id                         =  x_ledger_id
	AND   TT.ledger_id                         =  x_ledger_id
	AND   TT.target_currency                   =  x_currency
	AND   TT.average_translation_flag          =  'N'
	AND   TT.actual_flag                       =  x_actual_flag
	AND   NVL(TT.target_budget_version_id,-1)  =  NVL(x_budget_version_id,-1)
	AND   PS.effective_period_num              >=
	      (TT.earliest_ever_period_year * 10000 + TT.earliest_ever_period_num)
        AND   PS.effective_period_num              <
	      (TT.earliest_never_period_year * 10000 + TT.earliest_never_period_num)
        ORDER BY PS.effective_period_num DESC;

        BEGIN

          OPEN  get_to_period;
	  FETCH get_to_period
	  INTO  x_to_period,
		x_closing_status,
		x_to_period_eff_num;

  	  IF get_to_period%FOUND THEN
  	    CLOSE get_to_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_to_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_to_prd_trn_standard');
	  RAISE;
      END get_to_prd_trn_standard;

    PROCEDURE get_to_prd_trn_average(
			x_appl_id 		IN NUMBER,
		        x_ledger_id 		IN NUMBER,
		 	x_data_type		IN VARCHAR2,
		 	x_actual_flag		IN VARCHAR2,
		 	x_budget_version_id	IN NUMBER,
			x_currency              IN VARCHAR2,
		 	x_to_period		IN OUT NOCOPY VARCHAR2,
		 	x_closing_status	IN OUT NOCOPY VARCHAR2,
			x_to_period_eff_num     IN OUT NOCOPY NUMBER
			) IS

-- This procedure retrieves the latest ever translated period.

      CURSOR get_to_period IS
	SELECT
	      PS.period_name,
	      PS.closing_status,
	      PS.effective_period_num
        FROM
	      GL_PERIOD_STATUSES PS,
	      GL_TRANSLATION_TRACKING TT
        WHERE
	      PS.application_id                    =  x_appl_id
        AND   PS.ledger_id                         =  x_ledger_id
	AND   TT.ledger_id                         =  x_ledger_id
	AND   TT.target_currency                   =  x_currency
	AND   TT.average_translation_flag          =  'Y'
	AND   TT.actual_flag                       =  x_actual_flag
	AND   NVL(TT.target_budget_version_id,-1)  =  NVL(x_budget_version_id,-1)
	AND   PS.effective_period_num              >=
	      (TT.earliest_ever_period_year * 10000 + TT.earliest_ever_period_num)
        AND   PS.effective_period_num              <
	      (TT.earliest_never_period_year * 10000 + TT.earliest_never_period_num)
        ORDER BY PS.effective_period_num DESC;

        BEGIN

          OPEN  get_to_period;
	  FETCH get_to_period
	  INTO  x_to_period,
		x_closing_status,
		x_to_period_eff_num;

  	  IF get_to_period%FOUND THEN
  	    CLOSE get_to_period;
	    x_closing_status := 'Y';
          ELSE
	    x_closing_status := 'N';
  	    CLOSE get_to_period;
	    FND_message.set_name('SQLGL', 'GL_NO_PERIODS_FOUND');
	    app_exception.raise_exception;
          END IF;

        EXCEPTION
	WHEN app_exceptions.application_exception THEN
	  RAISE;
        WHEN OTHERS THEN
	  fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
	  fnd_message.set_token('PROCEDURE',
				'gl_arch_prg_from_prd_pkg.get_to_prd_trn_average');
	  RAISE;
      END get_to_prd_trn_average;

END gl_arch_prg_from_prd_pkg;

/
