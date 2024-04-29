--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_UTILS_PKG" AS
/* $Header: glubdmsb.pls 120.11.12010000.2 2009/03/20 06:05:14 skotakar ship $ */

  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE get_current_budget(x_ledger_id 		NUMBER,
                               x_budget_version_id 	IN OUT NOCOPY NUMBER,
                               x_budget_name 		IN OUT NOCOPY VARCHAR2,
                               x_bj_required            IN OUT NOCOPY VARCHAR2) IS

    CURSOR chk_budget IS
      SELECT bv.budget_version_id, b.budget_name,
             b.require_budget_journals_flag
      FROM   gl_budgets b, gl_budget_versions bv
      WHERE  b.ledger_id = x_ledger_id
      AND    b.status = 'C'
      AND    bv.budget_name = b.budget_name
      AND    bv.budget_type = b.budget_type;
  BEGIN
    OPEN chk_budget;
    FETCH chk_budget INTO x_budget_version_id, x_budget_name, x_bj_required;
    CLOSE chk_budget;
  END get_current_budget;

  FUNCTION is_funding_budget(x_ledger_id		NUMBER,
			     x_funct_curr		VARCHAR2,
			     x_budget_version_id 	NUMBER)
                              RETURN BOOLEAN IS

    CURSOR chk_funding IS
      SELECT 'Funding budget'
      FROM   gl_budget_assignment_ranges rng, gl_budorg_bc_options bc
      WHERE  rng.ledger_id = x_ledger_id
      AND    rng.currency_code = x_funct_curr
      AND    bc.range_id = rng.range_id
      AND    bc.funds_check_level_code IN ('D', 'B')
      AND    bc.funding_budget_version_id = x_budget_version_id;
    CURSOR chk_sum_funding IS
      SELECT 'Summary Funding budget'
      FROM   gl_summary_templates sum, gl_summary_bc_options bc
      WHERE  sum.ledger_id = x_ledger_id
      AND    bc.template_id = sum.template_id
      AND    bc.funds_check_level_code IN ('D','B')
      AND    bc.funding_budget_version_id = x_budget_version_id;
    dummy VARCHAR2(100);
    dummy2 VARCHAR2(100);
  BEGIN
    OPEN chk_funding;
    FETCH chk_funding INTO dummy;

    OPEN chk_sum_funding;
    FETCH chk_sum_funding INTO dummy2;

    IF chk_funding%FOUND OR chk_sum_funding%FOUND THEN
      CLOSE chk_funding;
      CLOSE chk_sum_funding;
      return(TRUE);
    ELSE
      CLOSE chk_funding;
      CLOSE chk_sum_funding;
      return(FALSE);
    END IF;
  END is_funding_budget;

  FUNCTION is_master_budget(budget_id NUMBER)
                            RETURN BOOLEAN IS

    CURSOR chk_master IS
      SELECT 'Used as master'
      FROM   gl_budget_versions detail
      WHERE  detail.control_budget_version_id = budget_id;
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_master;
    FETCH chk_master INTO dummy;

    IF chk_master%FOUND THEN
      CLOSE chk_master;
      return(TRUE);
    ELSE
      CLOSE chk_master;
      return(FALSE);
    END IF;
  END is_master_budget;

  FUNCTION frozen_budget(budget_version_id NUMBER) RETURN BOOLEAN IS
    CURSOR chk_frozen IS
      SELECT status
      FROM   gl_budget_versions
      WHERE  budget_version_id = frozen_budget.budget_version_id;
    tmp_status VARCHAR2(1);
  BEGIN
    OPEN chk_frozen;
    FETCH chk_frozen INTO tmp_status;

    IF chk_frozen%FOUND THEN
      CLOSE chk_frozen;
      IF (tmp_status = 'F') THEN
        return(TRUE);
      ELSE
        return(FALSE);
      END IF;
    ELSE
      CLOSE chk_frozen;
      RAISE NO_DATA_FOUND;
    END IF;
  END frozen_budget;

  FUNCTION frozen_budget_entity(budget_version_id NUMBER,
				budget_entity_id  NUMBER) RETURN BOOLEAN IS
    CURSOR chk_frozen IS
      SELECT frozen_flag
      FROM   gl_entity_budgets
      WHERE  budget_version_id = frozen_budget_entity.budget_version_id
      AND    budget_entity_id  = frozen_budget_entity.budget_entity_id;
    tmp_status VARCHAR2(1);
  BEGIN
    OPEN chk_frozen;
    FETCH chk_frozen INTO tmp_status;

    IF chk_frozen%FOUND THEN
      CLOSE chk_frozen;
      IF (tmp_status = 'Y') THEN
        return(TRUE);
      ELSE
        return(FALSE);
      END IF;
    ELSE
      CLOSE chk_frozen;
      RAISE NO_DATA_FOUND;
    END IF;
  END frozen_budget_entity;
  /* Bug Fix 3866812 */
  /*
    Modications in frozen_account function:
    Added two new parameters:
    Parameters 1. ledger_id 2. Currency_code
    Added four new cursors :
    Cursors 1. get_org_name : Fetch the budget organization name
                              corresponding to budget organization id.
            2. get_entity_id: Fetch the budget organization id to which
    	                  a code combination belongs.
    	3. get_status   : Fetch the status of the given budget organization.
    	4. get_all_meaning : Fetch the meaning of lookup_code 'ALL'.
    Modified cursor chk_frozen:Added parameter entity_id to the cursor.
    Change in logic:
    Fetch the organization name from the organization ID
    IF organization name is found THEN
      IF organization name is 'ALL' THEN
           Fetch user organization (ALL is system defined),
           based on LEDGER_ID, CCID and CURRENCY.
           IF user organization is found THEN
                Check if user organization is frozen
                IF user organization frozen info found THEN
                    IF user organization is frozen THEN
                        return 'TRUE' (frozen org)
                    Else
                         Check if acccount (CCID) is frozen in the organization.
    	             IF account is frozen THEN
    	                  return 'TRUE'
          	       Else
                        return 'FALSE'
               Else -- user organization frozen info not found then
                   -- donot register new message since this will rarely happen,
    	       -- if data modified externally to the system
                   Raise NO_DATA_FOUND
          Else -- user organization not found
              -- happens only if data is corrupted
              Raise NO_DATA_FOUND
       Else -- organization name is not 'ALL'
           Check if acccount (CCID) is frozen in the organization.
           IF account is frozen then
               return 'TRUE'
           Else
               return 'FALSE'
    Else
      -- happens only if data is corrupted
      Raise NO_DATA_FOUND
  */
  FUNCTION frozen_account(coa_id	      NUMBER,
			  budget_version_id   NUMBER,
                          budget_entity_id    NUMBER,
			  code_combination_id NUMBER,
 			  ledger_id           NUMBER,
			  currency_code       VARCHAR2) RETURN BOOLEAN IS
    CURSOR chk_frozen (entity_id NUMBER) IS
      SELECT 'Frozen'
      FROM   gl_code_combinations cc, gl_budget_frozen_ranges bfr
      WHERE  bfr.budget_version_id = frozen_account.budget_version_id
      AND    bfr.budget_entity_id  = entity_id
      AND    cc.code_combination_id = frozen_account.code_combination_id
      AND    cc.chart_of_accounts_id = frozen_account.coa_id
      AND    nvl(cc.segment1,'XXX') between nvl(bfr.segment1_low,'XXX')
                                    and nvl(bfr.segment1_high,'XXX')
      AND    nvl(cc.segment2,'XXX') between nvl(bfr.segment2_low,'XXX')
                                    and     nvl(bfr.segment2_high,'XXX')
      AND    nvl(cc.segment3,'XXX') between nvl(bfr.segment3_low,'XXX')
                                    and     nvl(bfr.segment3_high,'XXX')
      AND    nvl(cc.segment4,'XXX') between nvl(bfr.segment4_low,'XXX')
                                    and     nvl(bfr.segment4_high,'XXX')
      AND    nvl(cc.segment5,'XXX') between nvl(bfr.segment5_low,'XXX')
                                    and     nvl(bfr.segment5_high,'XXX')
      AND    nvl(cc.segment6,'XXX') between nvl(bfr.segment6_low,'XXX')
                                    and     nvl(bfr.segment6_high,'XXX')
      AND    nvl(cc.segment7,'XXX') between nvl(bfr.segment7_low,'XXX')
                                    and     nvl(bfr.segment7_high,'XXX')
      AND    nvl(cc.segment8,'XXX') between nvl(bfr.segment8_low,'XXX')
                                    and     nvl(bfr.segment8_high,'XXX')
      AND    nvl(cc.segment9,'XXX') between nvl(bfr.segment9_low,'XXX')
                                    and     nvl(bfr.segment9_high,'XXX')
      AND    nvl(cc.segment10,'XXX') between nvl(bfr.segment10_low,'XXX')
                                     and     nvl(bfr.segment10_high,'XXX')
      AND    nvl(cc.segment11,'XXX') between nvl(bfr.segment11_low,'XXX')
                                     and     nvl(bfr.segment11_high,'XXX')
      AND    nvl(cc.segment12,'XXX') between nvl(bfr.segment12_low,'XXX')
                                     and     nvl(bfr.segment12_high,'XXX')
      AND    nvl(cc.segment13,'XXX') between nvl(bfr.segment13_low,'XXX')
                                     and     nvl(bfr.segment13_high,'XXX')
      AND    nvl(cc.segment14,'XXX') between nvl(bfr.segment14_low,'XXX')
                                     and     nvl(bfr.segment14_high,'XXX')
      AND    nvl(cc.segment15,'XXX') between nvl(bfr.segment15_low,'XXX')
                                     and     nvl(bfr.segment15_high,'XXX')
      AND    nvl(cc.segment16,'XXX') between nvl(bfr.segment16_low,'XXX')
                                     and     nvl(bfr.segment16_high,'XXX')
      AND    nvl(cc.segment17,'XXX') between nvl(bfr.segment17_low,'XXX')
                                     and     nvl(bfr.segment17_high,'XXX')
      AND    nvl(cc.segment18,'XXX') between nvl(bfr.segment18_low,'XXX')
                                     and     nvl(bfr.segment18_high,'XXX')
      AND    nvl(cc.segment19,'XXX') between nvl(bfr.segment19_low,'XXX')
                                     and     nvl(bfr.segment19_high,'XXX')
      AND    nvl(cc.segment20,'XXX') between nvl(bfr.segment20_low,'XXX')
                                     and     nvl(bfr.segment20_high,'XXX')
      AND    nvl(cc.segment21,'XXX') between nvl(bfr.segment21_low,'XXX')
                                     and     nvl(bfr.segment21_high,'XXX')
      AND    nvl(cc.segment22,'XXX') between nvl(bfr.segment22_low,'XXX')
                                     and     nvl(bfr.segment22_high,'XXX')
      AND    nvl(cc.segment23,'XXX') between nvl(bfr.segment23_low,'XXX')
                                     and     nvl(bfr.segment23_high,'XXX')
      AND    nvl(cc.segment24,'XXX') between nvl(bfr.segment24_low,'XXX')
                                     and     nvl(bfr.segment24_high,'XXX')
      AND    nvl(cc.segment25,'XXX') between nvl(bfr.segment25_low,'XXX')
                                     and     nvl(bfr.segment25_high,'XXX')
      AND    nvl(cc.segment26,'XXX') between nvl(bfr.segment26_low,'XXX')
                                     and     nvl(bfr.segment26_high,'XXX')
      AND    nvl(cc.segment27,'XXX') between nvl(bfr.segment27_low,'XXX')
                                     and     nvl(bfr.segment27_high,'XXX')
      AND    nvl(cc.segment28,'XXX') between nvl(bfr.segment28_low,'XXX')
                                     and     nvl(bfr.segment28_high,'XXX')
      AND    nvl(cc.segment29,'XXX') between nvl(bfr.segment29_low,'XXX')
                                     and     nvl(bfr.segment29_high,'XXX')
      AND    nvl(cc.segment30,'XXX') between nvl(bfr.segment30_low,'XXX')
                                     and     nvl(bfr.segment30_high,'XXX');
    CURSOR get_org_name is
      SELECT name
      FROM gl_budget_entities
      WHERE budget_entity_id = frozen_account.budget_entity_id;

    CURSOR get_entity_id is
      SELECT budget_entity_id
      FROM gl_budget_assignments
      WHERE ledger_id =  frozen_account.ledger_id AND
            code_combination_id = frozen_account.code_combination_id AND
            currency_code=frozen_account.currency_code;

    CURSOR get_status(entity_id number) is
      SELECT frozen_flag
      FROM gl_entity_budgets
      WHERE budget_version_id=frozen_account.budget_version_id and budget_entity_id=entity_id;

    CURSOR get_all_meaning is
      SELECT meaning
      FROM gl_lookups
      WHERE lookup_type='LITERAL' AND lookup_code='ALL';

    tmp_status VARCHAR2(100);
    budget_org_all VARCHAR2(30);
    budget_org_name VARCHAR2(100);
    bud_entity_id NUMBER;
    frozen_flag VARCHAR2(2);
  BEGIN
    OPEN get_all_meaning;
    FETCH get_all_meaning INTO budget_org_all;
      IF get_all_meaning%FOUND THEN
        CLOSE get_all_meaning;
      ELSE
        CLOSE get_all_meaning;
      END IF;
   OPEN get_org_name;
   FETCH get_org_name INTO budget_org_name;
     IF get_org_name%FOUND THEN
       CLOSE get_org_name;
     ELSE
       CLOSE get_org_name;
     END IF;
     IF UPPER(budget_org_name)= UPPER(budget_org_all) THEN
       OPEN get_entity_id;
       FETCH get_entity_id INTO bud_entity_id;
       IF get_entity_id%FOUND THEN
         CLOSE get_entity_id;
         OPEN get_status(bud_entity_id);
         FETCH get_status INTO frozen_flag;
         IF get_status%FOUND THEN
           CLOSE get_status;
           IF frozen_flag='Y' THEN
             return(TRUE);
           END IF;
         ELSE
           CLOSE get_status;
           RAISE NO_DATA_FOUND;
         END IF;
       ELSE
         CLOSE get_entity_id;
         RAISE NO_DATA_FOUND;
       END IF;
       OPEN chk_frozen(bud_entity_id);
       FETCH chk_frozen INTO tmp_status;
       IF chk_frozen%FOUND THEN
         CLOSE chk_frozen;
         return(TRUE);
       ELSE
         CLOSE chk_frozen;
         return(FALSE);
       END IF;
     ELSE
       OPEN chk_frozen(frozen_account.budget_entity_id);
       FETCH chk_frozen INTO tmp_status;
       IF chk_frozen%FOUND THEN
         CLOSE chk_frozen;
         return(TRUE);
       ELSE
         CLOSE chk_frozen;
         return(FALSE);
       END IF;
     END IF;
  END frozen_account;

  PROCEDURE validate_budget_account(lgr_id		         NUMBER,
				    coa_id	                 NUMBER,
			            budget_version_id            NUMBER,
 		                    code_combination_id          NUMBER,
                                    currency_code                VARCHAR2,
				    return_code		  IN OUT NOCOPY VARCHAR2,
                                    budget_entity_id      IN OUT NOCOPY NUMBER,
				    budget_entity         IN OUT NOCOPY VARCHAR2,
				    password_flag         IN OUT NOCOPY VARCHAR2,
				    encrypted_password    IN OUT NOCOPY VARCHAR2,
				    status_code		  IN OUT NOCOPY VARCHAR2) IS
  BEGIN

    -- Find out which budget organization the account is assigned to
    DECLARE
      entry_code VARCHAR2(1);
      retvalue   VARCHAR2(1);
      security_flag VARCHAR2(1);--Added as part of bug7382899
    BEGIN
      gl_budget_assignment_pkg.select_columns(lgr_id,
					      code_combination_id,
					      currency_code,
					      budget_entity_id,
                                              entry_code);

    --Pulled this call from below:bug7382899
    -- Get various information about the budget organization
    gl_budget_entities_pkg.select_columns(budget_entity_id,
                                          budget_entity,
                                          password_flag,
                                          encrypted_password,
					  status_code,
					  security_flag);


    IF 	security_flag  = 'Y' THEN--Added as part of bug7382899
	      retvalue := fnd_data_security.check_function(1.0,'GL_DAS_BUDGET_ORG_U',
			     'GL_DAS_BUDGET_ORG', to_char(budget_entity_id),null,
			     null,null,null,fnd_global.user_name);
	      IF(retvalue <> 'T') THEN
		 return_code := 'A';
		 return;
	      END IF;
    END IF;----Added as part of bug7382899

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return_code := 'A';
	return;
    END;


    --Commented as part of bug7382899: Moving this procedure above
    --as we need security flag for conditional calling of data security api.
   /*-- Get various information about the budget organization
    gl_budget_entities_pkg.select_columns(budget_entity_id,
                                          budget_entity,
                                          password_flag,
                                          encrypted_password,
					  status_code);*/

    -- Verify that the budget organization is not frozen
    IF (gl_budget_utils_pkg.frozen_budget_entity(budget_version_id,
						 budget_entity_id)) THEN
      return_code := 'O';
      return;
    END IF;

    -- Verify that the account is not frozen
    /* Bug Fix 3866812 */
    /* Added two parameters lgr_id and currency_code */
    IF (gl_budget_utils_pkg.frozen_account(coa_id,
					   budget_version_id,
					   budget_entity_id,
					   code_combination_id,
                                           lgr_id,
                                           currency_code)) THEN
      return_code := 'F';
      return;
    END IF;

    return_code := 'Z';
    return;
  END validate_budget_account;


FUNCTION get_unique_id RETURN NUMBER IS
-- get unique id for range_id
    CURSOR c_getid IS
      SELECT GL_BUDGET_FROZEN_RANGES_S.NEXTVAL
      FROM   dual;
    id number;

  BEGIN
    OPEN  c_getid;
    FETCH c_getid INTO id;

    IF c_getid%FOUND THEN
      CLOSE c_getid;
      RETURN( id );
    ELSE
      CLOSE c_getid;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_BUDGET_FROZEN_RANGES_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN APP_EXCEPTION.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_budget_utils_pkg.get_unique_id');
      RAISE;
END get_unique_id;

  FUNCTION get_opyr_per_range (	x_budget_version_id IN NUMBER,
				x_start_period_year IN OUT NOCOPY NUMBER,
				x_start_period_name IN OUT NOCOPY VARCHAR2,
				x_start_period_num  IN OUT NOCOPY NUMBER,
				x_end_period_year   IN OUT NOCOPY NUMBER,
				x_end_period_name   IN OUT NOCOPY VARCHAR2,
				x_end_period_num    IN OUT NOCOPY NUMBER)
				RETURN BOOLEAN IS
      CURSOR get_prd IS
	SELECT	prs.period_year,
		prs.start_period_name,
		prs.start_period_num,
		pre.period_year,
		pre.end_period_name,
		pre.end_period_num
    	FROM	gl_budget_period_ranges prs,
		gl_budget_period_ranges pre
	WHERE	prs.budget_version_id = pre.budget_version_id
	  AND	prs.budget_version_id = x_budget_version_id
	  AND 	prs.period_year * 100000 + prs.start_period_num =
		(SELECT MIN(period_year * 100000 + start_period_num)
		 FROM	gl_budget_period_ranges
		 WHERE	budget_version_id = x_budget_version_id
		   AND  open_flag = 'O')
	  AND	pre.period_year * 100000 + pre.start_period_num =
		(SELECT MAX(period_year * 100000 + start_period_num)
		 FROM	gl_budget_period_ranges
		 WHERE	budget_version_id = x_budget_version_id
		   AND  open_flag = 'O');
  BEGIN
	OPEN 	get_prd;
	FETCH 	get_prd INTO 	x_start_period_year,
				x_start_period_name,
				x_start_period_num,
				x_end_period_year,
				x_end_period_name,
				x_end_period_num;

	IF get_prd%FOUND THEN
	  CLOSE get_prd;
	  return (TRUE);
	ELSE
	  CLOSE get_prd;
	  return (FALSE);
	END IF;
  END get_opyr_per_range;



PROCEDURE validate_budget(
                     X_Rowid                           IN OUT NOCOPY VARCHAR2,
                     X_Budget_Type                     VARCHAR2,
                     X_Budget_Name                     VARCHAR2,
                     X_Ledger_Id                       NUMBER,
                     X_Status                          VARCHAR2,
                     X_Date_Created                    DATE,
                     X_Require_Budget_Journals_Flag    VARCHAR2,
                     X_Current_Version_Id              NUMBER DEFAULT NULL,
                     X_Latest_Opened_Year              NUMBER DEFAULT NULL,
                     X_First_Valid_Period_Name         VARCHAR2 DEFAULT NULL,
                     X_Last_Valid_Period_Name          VARCHAR2 DEFAULT NULL,
                     X_Description                     VARCHAR2 DEFAULT NULL,
                     X_Date_Closed                     DATE DEFAULT NULL,
                     X_Attribute1                      VARCHAR2 DEFAULT NULL,
                     X_Attribute2                      VARCHAR2 DEFAULT NULL,
                     X_Attribute3                      VARCHAR2 DEFAULT NULL,
                     X_Attribute4                      VARCHAR2 DEFAULT NULL,
                     X_Attribute5                      VARCHAR2 DEFAULT NULL,
                     X_Attribute6                      VARCHAR2 DEFAULT NULL,
                     X_Attribute7                      VARCHAR2 DEFAULT NULL,
                     X_Attribute8                      VARCHAR2 DEFAULT NULL,
                     X_Context                         VARCHAR2 DEFAULT NULL,
		     X_User_Id 			       NUMBER,
		     X_Login_Id			       NUMBER,
		     X_Date                            DATE,
		     X_Budget_Version_Id	       NUMBER,
		     X_Master_Budget_Version_Id        NUMBER DEFAULT NULL) IS

  CURSOR chk_first_period IS
    SELECT period_year, period_num
    FROM gl_period_statuses
    WHERE application_id = 101
    AND   ledger_id = X_Ledger_Id
    AND   period_num between 1 and 60
    AND   period_name = X_First_Valid_Period_Name;

  CURSOR chk_last_period
          (p_first_valid_period_year NUMBER,
           p_first_valid_period_num  NUMBER) IS
    SELECT period_year, period_num
    FROM gl_period_statuses
    WHERE application_id = 101
    AND   ledger_id = X_Ledger_Id
    AND   period_num between 1 and 60
    AND   period_year * 10000 + period_num >=
            p_first_valid_period_year * 10000 + p_first_valid_period_num
    AND   period_name = X_Last_Valid_Period_Name;

  v_rbj_flag                 VARCHAR2(1);
  v_func_curr_code           VARCHAR2(15);
  v_ledger_name              VARCHAR2(30);
  v_first_valid_period_year  NUMBER;
  v_first_valid_period_num   NUMBER;
  v_last_valid_period_year   NUMBER;
  v_last_valid_period_num    NUMBER;

BEGIN

  -- validate Require_Budget_Journals_Flag
  --   the flag cannot be 'N' if
  --   the set_of_books has its require_budget_journals_flag checked, or
  --   the budget is a funding budget
  IF (X_Require_Budget_Journals_Flag = 'N') THEN

    SELECT require_budget_journals_flag, currency_code, name
    INTO v_rbj_flag, v_func_curr_code, v_ledger_name
    FROM gl_ledgers
    WHERE ledger_id = X_Ledger_Id;

    IF (v_rbj_flag = 'Y') THEN
      fnd_message.set_name('SQLGL', 'GL_API_BUDGET_REQUIRE_JOURNALS');
      fnd_message.set_token('LEDGER_NAME', v_ledger_name);
      app_exception.raise_exception;
    END IF;

    IF (gl_budget_utils_pkg.is_funding_budget(
          X_Ledger_Id,
          v_func_curr_code,
          X_Budget_Version_Id)) THEN
      fnd_message.set_name('SQLGL', 'GL_API_BUDGET_FUNDING_JOURNALS');
      fnd_message.set_token('BUDGET', X_Budget_Name);
      app_exception.raise_exception;
    END IF;
  END IF;

  -- validate First_Valid_Period_Name
  OPEN chk_first_period;
  FETCH chk_first_period
    INTO v_first_valid_period_year, v_first_valid_period_num;

  IF chk_first_period%NOTFOUND THEN
    CLOSE chk_first_period;
    fnd_message.set_name('SQLGL', 'GL_API_INVALID_VALUE');
    fnd_message.set_token('VALUE', NVL(X_First_Valid_Period_Name, 'null'));
    fnd_message.set_token('ATTRIBUTE', 'FirstValidPeriodName');
    app_exception.raise_exception;
  END IF;

  CLOSE chk_first_period;

  -- validate Last_Valid_Period_Name
  OPEN chk_last_period(v_first_valid_period_year, v_first_valid_period_num);
  FETCH chk_last_period
    INTO v_last_valid_period_year, v_last_valid_period_num;

  IF chk_last_period%NOTFOUND THEN
    CLOSE chk_last_period;
    fnd_message.set_name('SQLGL', 'GL_API_INVALID_VALUE');
    fnd_message.set_token('VALUE', NVL(X_Last_Valid_Period_Name, 'null'));
    fnd_message.set_token('ATTRIBUTE', 'LastValidPeriodName');
    app_exception.raise_exception;
  END IF;

  CLOSE chk_last_period;

EXCEPTION
  WHEN app_exceptions.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
    RAISE;

END validate_budget;


END gl_budget_utils_pkg;

/
