--------------------------------------------------------
--  DDL for Package Body GL_JE_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_LINES_PKG" as
/* $Header: glijelnb.pls 120.18.12010000.3 2009/05/28 11:53:05 skotakar ship $ */

  --
  -- PRIVATE VARIABLES
  --

  -- Keeps track of the last entered and accounted currencies
  -- and their minimum accountable unit and precision
  current_entered_currency  	VARCHAR2(15);
  entered_precision 		NUMBER;
  entered_mau			NUMBER;
  current_accounted_currency  	VARCHAR2(15);
  accounted_precision 		NUMBER;
  accounted_mau			NUMBER;

  -- Keeps track of the current delimiter
  delim               	VARCHAR2(1) := '';
  delim_coa_id		NUMBER := '';

  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE check_unique(header_id NUMBER, line_num NUMBER,
                         row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_JE_LINES jel
      WHERE  jel.je_header_id = header_id
      AND    jel.je_line_num = line_num
      AND    (   row_id is null
              OR jel.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_LINE_NUM');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.check_unique');
      RAISE;
  END check_unique;

  PROCEDURE delete_lines(header_id  NUMBER) IS
  BEGIN
    -- Delete all of the lines in that header
    DELETE gl_je_lines
    WHERE  je_header_id = header_id;

    -- Delete the reference lines if any.
    GL_IMPORT_REFERENCES_PKG.delete_lines (header_id);

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.delete_lines');
      RAISE;
  END delete_lines;

  PROCEDURE update_lines(header_id		NUMBER,
			 x_period_name          VARCHAR2,
			 x_effective_date       DATE,
			 conversion_denom_rate  NUMBER,
			 conversion_numer_rate  NUMBER,
			 entered_currency	VARCHAR2,
			 accounted_currency	VARCHAR2,
                         ignore_ignore_flag     VARCHAR2,
			 clear_stat		VARCHAR2,
			 user_id		NUMBER,
			 login_id		NUMBER) IS
    ext_precision 	NUMBER;
    entered_divisor	NUMBER := 1;
    accounted_divisor	NUMBER := 1;
  BEGIN

    IF (conversion_numer_rate <> -1) THEN
      -- Get the minimum accountable unit and the precision
      -- of the accounted currency
      IF (accounted_currency <> nvl(current_accounted_currency,
	  			    '01234567890123456789')
         ) THEN
        current_accounted_currency := accounted_currency;

        -- Get the precision and minimum accountable
        -- unit for the accounted currency
        fnd_currency.get_info(current_accounted_currency,
                              accounted_precision,
                              ext_precision,
                              accounted_mau);
      END IF;

      -- Get the minimum accountable unit and the precision
      -- of the entered currency
      IF (entered_currency <> nvl(current_entered_currency,
	  			  '01234567890123456789')
         ) THEN
        current_entered_currency := entered_currency;

        IF (current_entered_currency = current_accounted_currency) THEN
          entered_precision := accounted_precision;
	  entered_mau := accounted_mau;
        ELSE
          -- Get the precision and minimum accountable
          -- unit for the accounted currency
          fnd_currency.get_info(current_entered_currency,
                                entered_precision,
                                ext_precision,
                              entered_mau);
        END IF;
      END IF;

      -- Get the minimum unit for the entered currency
      IF (entered_mau IS NULL) THEN
        entered_divisor := power(10, -1 * entered_precision);
      ELSE
        entered_divisor := entered_mau;
      END IF;

      -- Get the minimum unit for the accounted currency
      IF (accounted_mau IS NULL) THEN
        accounted_divisor := power(10, -1 * accounted_precision);
      ELSE
        accounted_divisor := accounted_mau;
      END IF;
    END IF;

    UPDATE gl_je_lines
    SET period_name	  = x_period_name,
	effective_date	  = x_effective_date,
	entered_dr	  = decode(conversion_numer_rate, -1, entered_dr,
			      round(entered_dr/entered_divisor)*entered_divisor),
	entered_cr	  = decode(conversion_numer_rate, -1, entered_cr,
			      round(entered_cr/entered_divisor)*entered_divisor),
	accounted_dr	  = decode(conversion_numer_rate, -1, accounted_dr,
                              decode(decode(ignore_ignore_flag,
				       'Y', 'N',
				       ignore_rate_flag),
				'Y', accounted_dr,
				round((((round(entered_dr/entered_divisor)
                                          *entered_divisor)
                                          /conversion_denom_rate)
                                          *conversion_numer_rate)
                                      / accounted_divisor)*accounted_divisor)),
	accounted_cr	  = decode(conversion_numer_rate, -1, accounted_cr,
                              decode(decode(ignore_ignore_flag,
				       'Y', 'N',
				       ignore_rate_flag),
				'Y', accounted_cr,
				round((((round(entered_cr/entered_divisor)
                                          *entered_divisor)
                                          /conversion_denom_rate)
                                          *conversion_numer_rate)
                                      / accounted_divisor)*accounted_divisor)),
        ignore_rate_flag  = decode(ignore_ignore_flag, 'Y', null,
                                                       ignore_rate_flag),
	stat_amount       = decode(clear_stat, 'Y', null, stat_amount),
        last_update_date  = sysdate,
	last_updated_by	  = user_id,
	last_update_login = login_id
    WHERE  je_header_id = header_id;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.update_lines');
      RAISE;
  END update_lines;

  PROCEDURE calculate_totals(	header_id				NUMBER,
		      		running_total_dr		IN OUT NOCOPY	NUMBER,
		      		running_total_cr		IN OUT NOCOPY	NUMBER,
		      		running_total_accounted_dr	IN OUT NOCOPY	NUMBER,
		      		running_total_accounted_cr	IN OUT NOCOPY	NUMBER
                            ) IS
    CURSOR calc_totals is
      SELECT sum(nvl(entered_dr, 0)),
             sum(nvl(entered_cr, 0)),
             sum(nvl(accounted_dr, 0)),
             sum(nvl(accounted_cr, 0))
      FROM   GL_JE_LINES jel
      WHERE  jel.je_header_id = header_id;
  BEGIN
    OPEN calc_totals;
    FETCH calc_totals INTO running_total_dr, running_total_cr,
			   running_total_accounted_dr,
			   running_total_accounted_cr;

    IF calc_totals%NOTFOUND THEN
      CLOSE calc_totals;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE calc_totals;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.calculate_totals');
      RAISE;
  END calculate_totals;

  FUNCTION header_has_stat(header_id	NUMBER) RETURN BOOLEAN IS
    CURSOR has_stat is
      SELECT stat_amount
      FROM   GL_JE_LINES jel
      WHERE  jel.je_header_id = header_id
      AND    stat_amount IS NOT NULL;
    dummy   NUMBER;
  BEGIN
    OPEN has_stat;
    FETCH has_stat INTO dummy;

    IF has_stat%NOTFOUND THEN
      CLOSE has_stat;
      RETURN(FALSE);
    END IF;

    CLOSE has_stat;
    RETURN(TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.header_has_stat');
      RAISE;
  END header_has_stat;

  FUNCTION header_has_tax(header_id	NUMBER) RETURN BOOLEAN IS
    CURSOR has_tax is
      SELECT 'Has tax'
      FROM   GL_JE_LINES jel
      WHERE  jel.je_header_id = header_id
      AND    tax_type_code IS NOT NULL;
    dummy   VARCHAR2(100);
  BEGIN
    OPEN has_tax;
    FETCH has_tax INTO dummy;

    IF has_tax%NOTFOUND THEN
      CLOSE has_tax;
      RETURN(FALSE);
    END IF;

    CLOSE has_tax;
    RETURN(TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.header_has_tax');
      RAISE;
  END header_has_tax;

  PROCEDURE populate_fields(x_ledger_id				NUMBER,
                            x_org_id                            NUMBER,
			    x_coa_id				NUMBER,
			    x_ccid				NUMBER,
			    x_account_num		IN OUT NOCOPY	VARCHAR2,
			    x_account_type		IN OUT NOCOPY	VARCHAR2,
                            x_jgzz_recon_flag           IN OUT NOCOPY   VARCHAR2,
			    x_tax_enabled			 VARCHAR2,
			    x_taxable_account		IN OUT NOCOPY  VARCHAR2,
			    x_stat_enabled			VARCHAR2,
			    x_unit_of_measure		IN OUT NOCOPY  VARCHAR2,
			    x_tax_code_id			NUMBER,
			    x_tax_type_code			VARCHAR2,
			    x_tax_code			IN OUT NOCOPY  VARCHAR2) IS
    dummy_tax_type_code	VARCHAR2(1);
    dummy_tax_code  	VARCHAR2(50);
    dummy_tax_code_id	NUMBER;
    dummy_rounding_code VARCHAR2(1);
    dummy_incl_tax_flag VARCHAR2(1);
    temp_return_status VARCHAR2(1);
    err_msg             VARCHAR2(2000);
  BEGIN
    IF (nvl(delim_coa_id, -1) <> x_coa_id) THEN
      -- Get the delimiter
      delim := fnd_flex_apis.get_segment_delimiter(
        	 x_application_id 	=> 101,
      	  	 x_id_flex_code		=> 'GL#',
      		 x_id_flex_num		=> x_coa_id);
    END IF;

    IF (fnd_flex_keyval.validate_ccid(
            	appl_short_name 	=> 'SQLGL',
	    	key_flex_code		=> 'GL#',
	    	structure_number	=> x_coa_id,
		combination_id		=> x_ccid,
		displayable		=> 'GL_ACCOUNT')
       ) THEN
      x_account_num  := replace(fnd_flex_keyval.concatenated_values,
				'
', delim);
      x_account_type := fnd_flex_keyval.qualifier_value('GL_ACCOUNT_TYPE');

      IF (x_tax_code_id IS NOT NULL) THEN

        temp_return_status :=null;
        err_msg :=null;

        zx_gl_tax_options_pkg.get_tax_rate_code
        (  1.0,
           x_tax_type_code,
           x_tax_code_id,
           x_tax_code,
           temp_return_status, err_msg
        );

        IF (temp_return_status = 'E') THEN
          FND_MESSAGE.Set_Name('ZX', err_msg);
          fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.populate_fields');
         -- APP_EXCEPTION.Raise_Exception;
        ELSIF (temp_return_status = 'U') THEN
          fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
          fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.populate_fields');
          APP_EXCEPTION.Raise_Exception;
        END IF;
      END IF;

      gl_je_lines_pkg.init_acct_dependencies(
	x_ledger_id 		=> x_ledger_id,
        x_org_id                => x_org_id,
	x_coa_id		=> x_coa_id,
        x_ccid			=> x_ccid,
	x_account_num		=> x_account_num,
        x_account_type		=> x_account_type,
	x_tax_enabled   	=> x_tax_enabled,
	x_taxable_account	=> x_taxable_account,
	x_get_default_tax_info 	=> 'N',
	x_eff_date		=> sysdate,
	x_default_tax_type_code	=> dummy_tax_type_code,
	x_default_tax_code	=> dummy_tax_code,
        x_default_tax_code_id   => dummy_tax_code_id,
        x_default_rounding_code => dummy_rounding_code,
        x_default_incl_tax_flag => dummy_incl_tax_flag,
	x_stat_enabled		=> x_stat_enabled,
	x_unit_of_measure	=> x_unit_of_measure,
        x_jgzz_recon_flag       => x_jgzz_recon_flag);

     ELSE
       fnd_message.set_encoded(fnd_flex_keyval.encoded_error_message);
       app_exception.raise_exception;
    END IF;

  END populate_fields;

  PROCEDURE init_acct_dependencies(
			    x_ledger_id				NUMBER,
			    x_org_id                            NUMBER,
			    x_coa_id				NUMBER,
                            x_ccid                              NUMBER,
			    x_account_num			VARCHAR2,
			    x_account_type			VARCHAR2,
			    x_tax_enabled			VARCHAR2,
			    x_taxable_account		IN OUT NOCOPY  VARCHAR2,
			    x_get_default_tax_info		VARCHAR2,
			    x_eff_date				DATE,
			    x_default_tax_type_code	IN OUT NOCOPY  VARCHAR2,
			    x_default_tax_code		IN OUT NOCOPY  VARCHAR2,
			    x_default_tax_code_id	IN OUT NOCOPY  NUMBER,
			    x_default_rounding_code	IN OUT NOCOPY	VARCHAR2,
			    x_default_incl_tax_flag	IN OUT NOCOPY	VARCHAR2,
			    x_stat_enabled			VARCHAR2,
			    x_unit_of_measure		IN OUT NOCOPY  VARCHAR2,
                            x_jgzz_recon_flag           IN OUT NOCOPY  VARCHAR2) IS

    description 		VARCHAR2(255);

    coa_id			NUMBER := x_coa_id;
    acct_num			VARCHAR2(25) := x_account_num;

    dummy			NUMBER;

    x_default_taxable_flag	VARCHAR2(1);
    tmp_recon_flag              VARCHAR2(1);
    dummy_return_status         VARCHAR2(1);
    err_msg                     VARCHAR2(2000);
    return_status VARCHAR2(30);
    msg_count     NUMBER;
    msg_data      VARCHAR2(2000);
    le_id         NUMBER;
    p_date        DATE;
  BEGIN
    -- initialize everything
    x_unit_of_measure := null;

    -- If tax is enabled, then determine if by default this
    -- account is tax
    x_default_taxable_flag := 'N';
    x_taxable_account := 'N';

    IF (nvl(x_tax_enabled,'N') = 'Y') THEN

      le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(
               x_org_id);
      ZX_API_PUB.set_tax_security_context(1.0, null, null, null,
            return_status, msg_count, msg_data, x_org_id, le_id,
            x_eff_date, NULL, NULL, p_date);

      SELECT max(decode(allow_rate_override_flag, 'N', 1, 0))
      INTO   dummy
      FROM  zx_account_rates    rates
      WHERE  rates.ledger_id = x_ledger_id
      AND    rates.account_segment_value = x_account_num
      AND    rates.tax_class = 'NON_TAXABLE';

      IF (dummy IS NULL) THEN
	x_default_taxable_flag := 'Y';
	x_taxable_account := 'Y';
      ELSIF (dummy = 0) THEN
	x_default_taxable_flag := 'N';
	x_taxable_account := 'Y';
      ELSE
	x_default_taxable_flag := 'N';
	x_taxable_account := 'N';
      END IF;

    ELSE
      x_default_taxable_flag := 'N';
      x_taxable_account := 'Y';
    END IF;

    -- Get the other defaults, if desired
    IF (    (x_tax_enabled = 'Y')
	AND (x_default_taxable_flag = 'Y')
	AND (x_get_default_tax_info = 'Y')
       ) THEN

      x_default_tax_type_code := null;
      x_default_tax_code := null;
      x_default_tax_code_id := null;
      x_default_rounding_code := null;
      x_default_incl_tax_flag := null;

      -- Get the default tax code id
      x_default_tax_type_code := default_tax_type(
                                   'I', x_ledger_id, x_org_id,
                                   x_account_num, x_account_type);

      IF (x_default_tax_type_code IS NOT NULL) THEN

        x_default_tax_code_id := to_number(default_tax_code(
	  		                     'I', x_ledger_id, x_org_id,
					     x_account_num,
			                     x_default_tax_type_code,
					     x_eff_date));

        -- Get the tax code associated with the default tax code id
        IF (x_default_tax_code_id IS NOT NULL) THEN
          dummy_return_status :=null;
          err_msg :=null;

          zx_gl_tax_options_pkg.get_tax_rate_code
          (   1.0,
              x_default_tax_type_code,
              x_default_tax_code_id,
              x_default_tax_code,
              dummy_return_status, err_msg
           );

          IF (dummy_return_status = 'E') THEN
            FND_MESSAGE.Set_Name('ZX', err_msg);
            fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.init_acct_dependencies');
            -- APP_EXCEPTION.Raise_Exception;
          ELSIF (dummy_return_status = 'U') THEN
            fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
            fnd_message.set_token('PROCEDURE', 'gl_je_lines_pkg.init_acct_dependencies');
            APP_EXCEPTION.Raise_Exception;
          END IF;

          -- Get the default rounding rule code and default include tax flag
          get_tax_defaults(x_ledger_id, x_org_id, x_account_num,
	      	           x_default_tax_type_code, x_default_rounding_code,
                           x_default_incl_tax_flag);
        END IF;
      END IF;
    END IF;

    IF (nvl(x_stat_enabled,'N') = 'Y') THEN
      BEGIN
        gl_stat_account_uom_pkg.select_columns(
            coa_id,
            acct_num,
            x_unit_of_measure,
            description);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_unit_of_measure := null;
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;

    -- If the ccid exists, get the jgzz_recon_flag from it
    IF (nvl(x_ccid,-1) <> -1) THEN
        BEGIN
          SELECT jgzz_recon_flag
          INTO tmp_recon_flag
          FROM gl_code_combinations
          WHERE code_combination_id = x_ccid;

          x_jgzz_recon_flag := tmp_recon_flag;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_jgzz_recon_flag := null;
        END;
      ELSE
        IF (fnd_flex_keyval.validate_segs(
               	operation       => 'CHECK_SEGMENTS',
		appl_short_name	=> 'SQLGL',
		key_flex_code	=> 'GL#',
		structure_number=> coa_id,
		concat_segments	=> x_account_num,
                displayable     => 'GL_ACCOUNT',
                validation_date	=> NULL,
                allow_nulls     => TRUE,
                allow_orphans   => TRUE)) THEN
          x_jgzz_recon_flag := fnd_flex_keyval.qualifier_value('RECONCILIATION FLAG');
        ELSE
          x_jgzz_recon_flag := 'Y';
        END IF;
    END IF;
  END init_acct_dependencies;

  PROCEDURE get_tax_defaults(x_ledger_id			NUMBER,
                             x_org_id                           NUMBER,
			     x_account_value			VARCHAR2,
			     x_tax_type_code			VARCHAR2,
			     x_default_rounding_code	IN OUT NOCOPY	VARCHAR2,
			     x_default_incl_tax_flag	IN OUT NOCOPY	VARCHAR2
			    ) IS

  BEGIN

    x_default_rounding_code := default_rounding_rule(
				 'I', x_ledger_id,
				 x_org_id, x_tax_type_code);

    x_default_incl_tax_flag := default_includes_tax(
				 'I', x_ledger_id,
				 x_org_id, x_account_value, x_tax_type_code);

  END get_tax_defaults;


  FUNCTION default_tax_type(output_type			IN VARCHAR2,
			    x_ledger_id                 IN NUMBER,
                            x_org_id                    IN NUMBER,
                            x_account_value             IN VARCHAR2,
                            x_account_type              IN VARCHAR2
                           ) RETURN VARCHAR2 IS

    num_defaults                NUMBER;
    default_tax_type            VARCHAR2(80) := '';
    default_tax_type_code       VARCHAR2(1)  := '';
    le_id         NUMBER;
    p_date        DATE;
    return_status VARCHAR2(30);
    msg_count     NUMBER;
    msg_data      VARCHAR2(2000);
  BEGIN
    default_tax_type := '';
    default_tax_type_code := '';

    le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(x_org_id);
    ZX_API_PUB.set_tax_security_context(1.0, null, null, null,
               return_status, msg_count, msg_data, x_org_id, le_id,
               sysdate, NULL, NULL, p_date);

    SELECT count(*), max(decode(rates.tax_class, 'INPUT', 'I', 'OUTPUT', 'O', NULL, 'T'))
    INTO    num_defaults, default_tax_type_code
    FROM    zx_account_rates  rates
    WHERE   rates.ledger_id = x_ledger_id
    AND     rates.account_segment_value = x_account_value
    AND     nvl(rates.tax_class,'T') <> 'NON_TAXABLE';

    -- If there are two or more default rows, then don't
    -- default
    IF (num_defaults >= 2) THEN
      default_tax_type := '';
      default_tax_type_code := '';

    -- If there are no default rows, then default based
    -- upon the account type
    ELSIF (num_defaults = 0) THEN
      default_tax_type_code :='T';
    END IF;

    IF (    (default_tax_type_code IS NOT NULL)
	AND (output_type = 'V')
       ) THEN
      SELECT l.meaning
      INTO default_tax_type
      FROM gl_lookups l
      WHERE l.lookup_type = 'TAX_TYPE'
      AND   l.lookup_code = default_tax_type_code;
    END IF;

    IF (output_type = 'I') THEN
      RETURN(default_tax_type_code);
    ELSE
      RETURN(default_tax_type);
    END IF;

  END default_tax_type;

  FUNCTION default_tax_code(output_type			IN VARCHAR2,
			    x_ledger_id			IN NUMBER,
                            x_org_id                    IN NUMBER,
			    x_account_value		IN VARCHAR2,
			    x_acct_type			IN VARCHAR2,
			    x_eff_date			IN DATE
                           ) RETURN VARCHAR2 IS

    temp_regime_code  varchar2(30);
    temp_tax varchar2(50);
    temp_status varchar2(30);
    default_tax_code varchar2(50);
    default_tax_code_id NUMBER(15);
    temp_rounding_rule varchar2(30);
    temp_includes_tax_flag varchar2(1);
    temp_return_status varchar2(1);
    err_msg varchar2(2000);
    le_id  NUMBER;
  BEGIN
  le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(x_org_id);

   zx_gl_tax_options_pkg.get_default_values(
           1.0, x_ledger_id, x_org_id, le_id,
            x_account_value, x_acct_type,
            x_eff_date,
            temp_regime_code,
            temp_tax,
            temp_status,
            default_tax_code,
            default_tax_code_id,
            temp_rounding_rule,
            temp_includes_tax_flag,
            temp_return_status, err_msg);

    IF (temp_return_status = 'E') THEN
      FND_MESSAGE.Set_Name('ZX', err_msg);
      fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_tax_code');
      --APP_EXCEPTION.Raise_Exception;
    ELSIF (temp_return_status = 'U') THEN
     fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
     fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_tax_code');
     APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (output_type = 'I') THEN
       RETURN(to_char(default_tax_code_id));
    ELSE
       RETURN(default_tax_code);
    END IF;
  END default_tax_code;


  FUNCTION default_rounding_rule(output_type			IN VARCHAR2,
				 x_ledger_id			IN NUMBER,
                                 x_org_id                       IN NUMBER,
			         x_tax_type			IN VARCHAR2
                                ) RETURN VARCHAR2 IS

    default_rounding_rule 	VARCHAR2(80);
    default_rounding_rule_code 	VARCHAR2(1);
    temp_return_status         VARCHAR2(1);
    err_msg                    VARCHAR2(2000);
    le_id  NUMBER;
  BEGIN
    default_rounding_rule := null;
    default_rounding_rule_code := null;
    le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(x_org_id);

    zx_gl_tax_options_pkg.get_rounding_rule_code
   (
    1.0,
     x_ledger_id ,
     x_org_id ,
     le_id,
     x_tax_type,
     default_rounding_rule_code,
     temp_return_status,
     err_msg
    );

    IF (temp_return_status = 'E') THEN
      FND_MESSAGE.Set_Name('ZX', err_msg);
      fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_rounding_rule');
      --APP_EXCEPTION.Raise_Exception;
    ELSIF (temp_return_status = 'U') THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_rounding_rule');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF default_rounding_rule_code IS NOT NULL THEN
      SELECT l.lookup_code, l.meaning
      INTO   default_rounding_rule_code,
             default_rounding_rule
      FROM   gl_lookups l
      WHERE  l.lookup_type = 'TAX_ROUNDING_RULE'
      AND    l.lookup_code = default_rounding_rule_code;
    END IF;

    IF (output_type = 'I') THEN
      RETURN(default_rounding_rule_code);
    ELSE
      RETURN(default_rounding_rule);
    END IF;

  END default_rounding_rule;


  FUNCTION default_includes_tax(output_type			IN VARCHAR2,
				x_ledger_id			IN NUMBER,
                                x_org_id                        IN NUMBER,
			        x_account_value			IN VARCHAR2,
			        x_tax_type			IN VARCHAR2
                               ) RETURN VARCHAR2 IS

    default_includes_tax 	VARCHAR2(80);
    default_includes_tax_flag 	VARCHAR2(1);

    temp_regime_code  varchar2(30);
    temp_tax varchar2(50);
    temp_status varchar2(30);
    default_tax_code varchar2(50);
    default_tax_code_id NUMBER(15);
    temp_rounding_rule varchar2(30);
    temp_includes_tax_flag varchar2(1);
    temp_return_status varchar2(1);
    err_msg varchar2(2000);
    le_id NUMBER(15);
  BEGIN
    default_includes_tax := null;
    default_includes_tax_flag := null;
    le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(x_org_id);

    zx_gl_tax_options_pkg.get_default_tax_include_flag
    (
      1.0,
      x_ledger_id,
      x_org_id,
      le_id,
      x_account_value,
      x_tax_type,
      temp_includes_tax_flag,
      temp_return_status,
      err_msg);

    IF (temp_return_status = 'E') THEN
      FND_MESSAGE.Set_Name('ZX', err_msg);
      fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_includes_tax');
     -- APP_EXCEPTION.Raise_Exception;
    ELSIF (temp_return_status = 'U') THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('FUNCTION', 'gl_je_lines_pkg.default_includes_tax');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF temp_includes_tax_flag IS NOT NULL THEN
      SELECT l.lookup_code, l.meaning
      INTO   default_includes_tax_flag,
             default_includes_tax
      FROM   gl_lookups l
      WHERE  l.lookup_type = 'YES/NO'
      AND    l.lookup_code = temp_includes_tax_flag;
    END IF;

    IF (output_type = 'I') THEN
      RETURN(default_includes_tax_flag);
    ELSE
      RETURN(default_includes_tax);
    END IF;

  END default_includes_tax;

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Je_Header_Id            IN OUT NOCOPY NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_id                      NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Status                         VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Accounted_Dr                   NUMBER,
                       X_Accounted_Cr                   NUMBER,
                       X_Description                    VARCHAR2,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Reference_3                    VARCHAR2,
                       X_Reference_4                    VARCHAR2,
                       X_Reference_5                    VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Context2                       VARCHAR2,
                       X_Invoice_Date                   DATE,
                       X_Tax_Code                       VARCHAR2,
                       X_Invoice_Identifier             VARCHAR2,
                       X_Invoice_Amount                 NUMBER,
                       X_No1                            VARCHAR2,
                       X_Stat_Amount                    NUMBER,
                       X_Ignore_Rate_Flag               VARCHAR2,
                       X_Context3                       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Subledger_Doc_Sequence_Id      NUMBER,
                       X_Context4                       VARCHAR2,
                       X_Subledger_Doc_Sequence_Value   NUMBER,
                       X_Reference_6                    VARCHAR2,
                       X_Reference_7                    VARCHAR2,
                       X_Reference_8                    VARCHAR2,
                       X_Reference_9                    VARCHAR2,
                       X_Reference_10                   VARCHAR2,
                       X_Recon_On_Flag			VARCHAR2,
		       X_Recon_Rowid	  IN OUT NOCOPY VARCHAR2,
		       X_Jgzz_Recon_Status		VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id			NUMBER,
		       X_Jgzz_Recon_Ref			VARCHAR2,
		       X_Taxable_Line_Flag		VARCHAR2,
		       X_Tax_Type_Code			VARCHAR2,
		       X_Tax_Code_Id			NUMBER,
		       X_Tax_Rounding_Rule_Code		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_Tax_Document_Identifier	VARCHAR2,
		       X_Tax_Document_Date		DATE,
		       X_Tax_Customer_Name		VARCHAR2,
		       X_Tax_Customer_Reference		VARCHAR2,
		       X_Tax_Registration_Number	VARCHAR2,
		       X_Tax_Line_Flag			VARCHAR2,
		       X_Tax_Group_Id			NUMBER,
                       X_Third_Party_Id		        VARCHAR2,
		       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2
   ) IS
     CURSOR C IS SELECT rowid FROM GL_JE_LINES
                 WHERE je_header_id = X_Je_Header_Id
                 AND   je_line_num = X_Je_Line_Num;

      dummy RowId;
    BEGIN

      -- Get the header id, if it has not yet been retrieved
      IF (X_Je_Header_Id IS NULL) THEN
        X_Je_Header_Id := gl_je_headers_pkg.get_unique_id;
      END IF;

      -- Add any new segment values
      gl_je_segment_values_pkg.insert_ccid_segment_values(
         X_Je_Header_Id,
         X_Code_Combination_Id,
         X_Last_Updated_By,
         X_Last_Update_Login);

      INSERT INTO GL_JE_LINES (
               je_header_id,
               je_line_num,
               last_update_date,
               last_updated_by,
               ledger_id,
               code_combination_id,
               period_name,
               effective_date,
               status,
               creation_date,
               created_by,
               last_update_login,
               entered_dr,
               entered_cr,
               accounted_dr,
               accounted_cr,
               description,
               reference_1,
               reference_2,
               reference_3,
               reference_4,
               reference_5,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               attribute6,
               attribute7,
               attribute8,
               attribute9,
               attribute10,
               attribute11,
               attribute12,
               attribute13,
               attribute14,
               attribute15,
               attribute16,
               attribute17,
               attribute18,
               attribute19,
               attribute20,
               context,
               context2,
               invoice_date,
               tax_code,
               invoice_identifier,
               invoice_amount,
               no1,
               stat_amount,
               ignore_rate_flag,
               context3,
               ussgl_transaction_code,
               subledger_doc_sequence_id,
               context4,
               subledger_doc_sequence_value,
               reference_6,
               reference_7,
               reference_8,
               reference_9,
               reference_10,
	       taxable_line_flag,
	       tax_type_code,
	       tax_code_id,
	       tax_rounding_rule_code,
	       amount_includes_tax_flag,
	       tax_document_identifier,
	       tax_document_date,
	       tax_customer_name,
	       tax_customer_reference,
	       tax_registration_number,
	       tax_line_flag,
	       tax_group_id,
               co_third_party,
	       global_attribute1,
	       global_attribute2,
	       global_attribute3,
	       global_attribute4,
	       global_attribute5,
	       global_attribute6,
	       global_attribute7,
	       global_attribute8,
	       global_attribute9,
	       global_attribute10,
	       global_attribute_category
             ) VALUES (
               X_Je_Header_Id,
               X_Je_Line_Num,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Ledger_id,
               X_Code_Combination_Id,
               X_Period_Name,
               X_Effective_Date,
               X_Status,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Entered_Dr,
               X_Entered_Cr,
               X_Accounted_Dr,
               X_Accounted_Cr,
               X_Description,
               X_Reference_1,
               X_Reference_2,
               X_Reference_3,
               X_Reference_4,
               X_Reference_5,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Attribute6,
               X_Attribute7,
               X_Attribute8,
               X_Attribute9,
               X_Attribute10,
               X_Attribute11,
               X_Attribute12,
               X_Attribute13,
               X_Attribute14,
               X_Attribute15,
               X_Attribute16,
               X_Attribute17,
               X_Attribute18,
               X_Attribute19,
               X_Attribute20,
               X_Context,
               X_Context2,
               X_Invoice_Date,
               X_Tax_Code,
               X_Invoice_Identifier,
               X_Invoice_Amount,
               X_No1,
               X_Stat_Amount,
               X_Ignore_Rate_Flag,
               X_Context3,
               X_Ussgl_Transaction_Code,
               X_Subledger_Doc_Sequence_Id,
               X_Context4,
               X_Subledger_Doc_Sequence_Value,
               X_Reference_6,
               X_Reference_7,
               X_Reference_8,
               X_Reference_9,
               X_Reference_10,
	       X_Taxable_Line_Flag,
	       X_Tax_Type_Code,
	       X_Tax_Code_Id,
	       X_Tax_Rounding_Rule_Code,
	       X_Amount_Includes_Tax_Flag,
	       X_Tax_Document_Identifier,
	       X_Tax_Document_Date,
	       X_Tax_Customer_Name,
	       X_Tax_Customer_Reference,
	       X_Tax_Registration_Number,
	       X_Tax_Line_Flag,
	       X_Tax_Group_Id,
               X_Third_Party_Id,
               X_Global_Attribute1,
	       X_Global_Attribute2,
	       X_Global_Attribute3,
	       X_Global_Attribute4,
	       X_Global_Attribute5,
	       X_Global_Attribute6,
	       X_Global_Attribute7,
	       X_Global_Attribute8,
	       X_Global_Attribute9,
	       X_Global_Attribute10,
	       X_Global_Attribute_Category
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

    -- Insert a reconciliation row if reconciliation is on
    IF (X_Recon_On_Flag = 'Y') THEN
      gl_je_lines_recon_pkg.insert_row(
        X_Rowid=>X_Recon_Rowid,
        X_Je_Header_Id=>X_Je_Header_id,
        X_Je_Line_Num=>X_Je_Line_Num,
        X_Ledger_Id=>X_Ledger_Id,
        X_Jgzz_Recon_Status=>X_Jgzz_Recon_Status,
        X_Jgzz_Recon_Date=>X_Jgzz_Recon_Date,
        X_Jgzz_Recon_Id=>X_Jgzz_Recon_Id,
        X_Jgzz_Recon_Ref=>X_Jgzz_Recon_Ref,
        X_Last_Update_Date=>X_Last_Update_Date,
        X_Last_Updated_By=>X_Last_Updated_By,
        X_Last_Update_Login=>X_Last_Update_Login);
    END IF;
  END Insert_Row;



  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Je_Header_Id                     NUMBER,
                     X_Je_Line_Num                      NUMBER,
                     X_Ledger_id 			NUMBER,
                     X_Code_Combination_Id              NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Effective_Date                   DATE,
                     X_Status                           VARCHAR2,
                     X_Entered_Dr                       NUMBER,
                     X_Entered_Cr                       NUMBER,
                     X_Accounted_Dr                     NUMBER,
                     X_Accounted_Cr                     NUMBER,
                     X_Description                      VARCHAR2,
                     X_Reference_1                      VARCHAR2,
                     X_Reference_2                      VARCHAR2,
                     X_Reference_3                      VARCHAR2,
                     X_Reference_4                      VARCHAR2,
                     X_Reference_5                      VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2,
                     X_Attribute16                      VARCHAR2,
                     X_Attribute17                      VARCHAR2,
                     X_Attribute18                      VARCHAR2,
                     X_Attribute19                      VARCHAR2,
                     X_Attribute20                      VARCHAR2,
                     X_Context                          VARCHAR2,
                     X_Context2                         VARCHAR2,
                     X_Invoice_Date                     DATE,
                     X_Tax_Code                         VARCHAR2,
                     X_Invoice_Identifier               VARCHAR2,
                     X_Invoice_Amount                   NUMBER,
                     X_No1                              VARCHAR2,
                     X_Stat_Amount                      NUMBER,
                     X_Ignore_Rate_Flag                 VARCHAR2,
                     X_Context3                         VARCHAR2,
                     X_Ussgl_Transaction_Code           VARCHAR2,
                     X_Subledger_Doc_Sequence_Id        NUMBER,
                     X_Context4                         VARCHAR2,
                     X_Subledger_Doc_Sequence_Value     NUMBER,
                     X_Reference_6                      VARCHAR2,
                     X_Reference_7                      VARCHAR2,
                     X_Reference_8                      VARCHAR2,
                     X_Reference_9                      VARCHAR2,
                     X_Reference_10                     VARCHAR2,
		     X_Recon_Rowid	                VARCHAR2,
		     X_Jgzz_Recon_Status		VARCHAR2,
		     X_Jgzz_Recon_Date			DATE,
		     X_Jgzz_Recon_Id			NUMBER,
		     X_Jgzz_Recon_Ref			VARCHAR2,
		     X_Taxable_Line_Flag		VARCHAR2,
		     X_Tax_Type_Code			VARCHAR2,
		     X_Tax_Code_Id			NUMBER,
		     X_Tax_Rounding_Rule_Code		VARCHAR2,
		     X_Amount_Includes_Tax_Flag		VARCHAR2,
		     X_Tax_Document_Identifier		VARCHAR2,
		     X_Tax_Document_Date		DATE,
		     X_Tax_Customer_Name		VARCHAR2,
		     X_Tax_Customer_Reference		VARCHAR2,
		     X_Tax_Registration_Number		VARCHAR2,
		     X_Tax_Line_Flag			VARCHAR2,
		     X_Tax_Group_Id			NUMBER,
                     X_Third_Party_Id		        VARCHAR2,
		     X_Global_Attribute1                VARCHAR2,
                     X_Global_Attribute2                VARCHAR2,
                     X_Global_Attribute3                VARCHAR2,
                     X_Global_Attribute4                VARCHAR2,
                     X_Global_Attribute5                VARCHAR2,
                     X_Global_Attribute6                VARCHAR2,
                     X_Global_Attribute7                VARCHAR2,
                     X_Global_Attribute8                VARCHAR2,
                     X_Global_Attribute9                VARCHAR2,
                     X_Global_Attribute10               VARCHAR2,
                     X_Global_Attribute_Category        VARCHAR2
  ) IS
    CURSOR C IS
        SELECT *
        FROM   GL_JE_LINES
        WHERE  rowid = X_Rowid
        FOR UPDATE of Je_Header_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
               (Recinfo.je_header_id = X_Je_Header_Id)
           AND (Recinfo.je_line_num = X_Je_Line_Num)
           AND (Recinfo.ledger_id = X_Ledger_id)
           AND (Recinfo.code_combination_id = X_Code_Combination_Id)
           AND (Recinfo.period_name = X_Period_Name)
           AND (Recinfo.effective_date = X_Effective_Date)
           AND (Recinfo.status = X_Status)
           AND (   (Recinfo.entered_dr = X_Entered_Dr)
                OR (    (Recinfo.entered_dr IS NULL)
                    AND (X_Entered_Dr IS NULL)))
           AND (   (Recinfo.entered_cr = X_Entered_Cr)
                OR (    (Recinfo.entered_cr IS NULL)
                    AND (X_Entered_Cr IS NULL)))
           AND (   (Recinfo.accounted_dr = X_Accounted_Dr)
                OR (    (Recinfo.accounted_dr IS NULL)
                    AND (X_Accounted_Dr IS NULL)))
           AND (   (Recinfo.accounted_cr = X_Accounted_Cr)
                OR (    (Recinfo.accounted_cr IS NULL)
                    AND (X_Accounted_Cr IS NULL)))
           AND (   (Recinfo.description = X_Description)
                OR (    (rtrim(Recinfo.description,' ') IS NULL)
                    AND (X_Description IS NULL)))
           AND (   (Recinfo.reference_1 = X_Reference_1)
                OR (    (rtrim(Recinfo.reference_1,' ') IS NULL)
                    AND (X_Reference_1 IS NULL)))
           AND (   (Recinfo.reference_2 = X_Reference_2)
                OR (    (rtrim(Recinfo.reference_2,' ') IS NULL)
                    AND (X_Reference_2 IS NULL)))
           AND (   (Recinfo.reference_3 = X_Reference_3)
                OR (    (rtrim(Recinfo.reference_3,' ') IS NULL)
                    AND (X_Reference_3 IS NULL)))
           AND (   (Recinfo.reference_4 = X_Reference_4)
                OR (    (rtrim(Recinfo.reference_4,' ') IS NULL)
                    AND (X_Reference_4 IS NULL)))
           AND (   (Recinfo.reference_5 = X_Reference_5)
                OR (    (rtrim(Recinfo.reference_5,' ') IS NULL)
                    AND (X_Reference_5 IS NULL)))
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (rtrim(Recinfo.attribute1,' ') IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (rtrim(Recinfo.attribute2,' ') IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (rtrim(Recinfo.attribute3,' ') IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (rtrim(Recinfo.attribute4,' ') IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (rtrim(Recinfo.attribute5,' ') IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 = X_Attribute6)
                OR (    (rtrim(Recinfo.attribute6,' ') IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 = X_Attribute7)
                OR (    (rtrim(Recinfo.attribute7,' ') IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 = X_Attribute8)
                OR (    (rtrim(Recinfo.attribute8,' ') IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 = X_Attribute9)
                OR (    (rtrim(Recinfo.attribute9,' ') IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 = X_Attribute10)
                OR (    (rtrim(Recinfo.attribute10,' ') IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 = X_Attribute11)
                OR (    (rtrim(Recinfo.attribute11,' ') IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 = X_Attribute12)
                OR (    (rtrim(Recinfo.attribute12,' ') IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 = X_Attribute13)
                OR (    (rtrim(Recinfo.attribute13,' ') IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 = X_Attribute14)
                OR (    (rtrim(Recinfo.attribute14,' ') IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 = X_Attribute15)
                OR (    (rtrim(Recinfo.attribute15,' ') IS NULL)
                    AND (X_Attribute15 IS NULL)))
           AND (   (Recinfo.attribute16 = X_Attribute16)
                OR (    (rtrim(Recinfo.attribute16,' ') IS NULL)
                    AND (X_Attribute16 IS NULL)))
           AND (   (Recinfo.attribute17 = X_Attribute17)
                OR (    (rtrim(Recinfo.attribute17,' ') IS NULL)
                    AND (X_Attribute17 IS NULL)))
           AND (   (Recinfo.attribute18 = X_Attribute18)
                OR (    (rtrim(Recinfo.attribute18,' ') IS NULL)
                    AND (X_Attribute18 IS NULL)))
           AND (   (Recinfo.attribute19 = X_Attribute19)
                OR (    (rtrim(Recinfo.attribute19,' ') IS NULL)
                    AND (X_Attribute19 IS NULL)))
           AND (   (Recinfo.attribute20 = X_Attribute20)
                OR (    (rtrim(Recinfo.attribute20,' ') IS NULL)
                    AND (X_Attribute20 IS NULL)))
           AND (   (Recinfo.context = X_Context)
                OR (    (rtrim(Recinfo.context,' ') IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.context2 = X_Context2)
                OR (    (rtrim(Recinfo.context2,' ') IS NULL)
                    AND (X_Context2 IS NULL)))
           AND (   (Recinfo.invoice_date = X_Invoice_Date)
                OR (    (Recinfo.invoice_date IS NULL)
                    AND (X_Invoice_Date IS NULL)))
           AND (   (Recinfo.tax_code = X_Tax_Code)
                OR (    (rtrim(Recinfo.tax_code,' ') IS NULL)
                    AND (X_Tax_Code IS NULL)))
           AND (   (Recinfo.invoice_identifier = X_Invoice_Identifier)
                OR (    (rtrim(Recinfo.invoice_identifier,' ') IS NULL)
                    AND (X_Invoice_Identifier IS NULL)))
           AND (   (Recinfo.invoice_amount = X_Invoice_Amount)
                OR (    (Recinfo.invoice_amount IS NULL)
                    AND (X_Invoice_Amount IS NULL)))
           AND (   (Recinfo.no1 = X_No1)
                OR (    (rtrim(Recinfo.no1,' ') IS NULL)
                    AND (X_No1 IS NULL)))
           AND (   (Recinfo.stat_amount = X_Stat_Amount)
                OR (    (Recinfo.stat_amount IS NULL)
                    AND (X_Stat_Amount IS NULL)))
           AND (   (Recinfo.ignore_rate_flag = X_Ignore_Rate_Flag)
                OR (    (rtrim(Recinfo.ignore_rate_flag,' ') IS NULL)
                    AND (X_Ignore_Rate_Flag IS NULL)))
           AND (   (Recinfo.context3 = X_Context3)
                OR (    (rtrim(Recinfo.context3,' ') IS NULL)
                    AND (X_Context3 IS NULL)))
           AND (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
                OR (    (rtrim(Recinfo.ussgl_transaction_code,' ') IS NULL)
                    AND (X_Ussgl_Transaction_Code IS NULL)))
           AND (   (Recinfo.subledger_doc_sequence_id
                      = X_Subledger_Doc_Sequence_Id)
                OR (    (Recinfo.subledger_doc_sequence_id IS NULL)
                    AND (X_Subledger_Doc_Sequence_Id IS NULL)))
           AND (   (Recinfo.context4 = X_Context4)
                OR (    (rtrim(Recinfo.context4,' ') IS NULL)
                    AND (X_Context4 IS NULL)))
           AND (   (Recinfo.subledger_doc_sequence_value
                      = X_Subledger_Doc_Sequence_Value)
                OR (    (Recinfo.subledger_doc_sequence_value IS NULL)
                    AND (X_Subledger_Doc_Sequence_Value IS NULL)))
           AND (   (Recinfo.reference_6 = X_Reference_6)
                OR (    (rtrim(Recinfo.reference_6,' ') IS NULL)
                    AND (X_Reference_6 IS NULL)))
           AND (   (Recinfo.reference_7 = X_Reference_7)
                OR (    (rtrim(Recinfo.reference_7,' ') IS NULL)
                    AND (X_Reference_7 IS NULL)))
           AND (   (Recinfo.reference_8 = X_Reference_8)
                OR (    (rtrim(Recinfo.reference_8,' ') IS NULL)
                    AND (X_Reference_8 IS NULL)))
           AND (   (Recinfo.reference_9 = X_Reference_9)
                OR (    (rtrim(Recinfo.reference_9,' ') IS NULL)
                    AND (X_Reference_9 IS NULL)))
           AND (   (Recinfo.reference_10 = X_Reference_10)
                OR (    (rtrim(Recinfo.reference_10,' ') IS NULL)
                    AND (X_Reference_10 IS NULL)))
      ) then
        if (
               (   (Recinfo.taxable_line_flag = X_Taxable_Line_Flag)
                OR (    (Recinfo.taxable_line_flag IS NULL)
                    AND (X_Taxable_Line_Flag IS NULL)))
           AND (   (Recinfo.tax_type_code = X_Tax_Type_Code)
                OR (    (Recinfo.tax_type_code IS NULL)
                    AND (X_Tax_Type_Code IS NULL)))
           AND (   (Recinfo.tax_code_id = X_Tax_Code_Id)
                OR (    (Recinfo.tax_code_id IS NULL)
                    AND (X_Tax_Code_Id IS NULL)))
           AND (   (Recinfo.tax_rounding_rule_code = X_Tax_Rounding_Rule_Code)
                OR (    (Recinfo.tax_rounding_rule_code IS NULL)
                    AND (X_Tax_Rounding_Rule_Code IS NULL)))
           AND (   (Recinfo.amount_includes_tax_flag
                      = X_Amount_Includes_Tax_Flag)
                OR (    (Recinfo.amount_includes_tax_flag IS NULL)
                    AND (X_Amount_Includes_Tax_Flag IS NULL)))
           AND (   (Recinfo.tax_document_identifier=X_Tax_Document_Identifier)
                OR (    (Recinfo.tax_document_identifier IS NULL)
                    AND (X_Tax_Document_Identifier IS NULL)))
           AND (   (Recinfo.tax_document_date=X_Tax_Document_Date)
                OR (    (Recinfo.tax_document_date IS NULL)
                    AND (X_Tax_Document_Date IS NULL)))
           AND (   (Recinfo.tax_customer_name=X_Tax_Customer_Name)
                OR (    (Recinfo.tax_customer_name IS NULL)
                    AND (X_Tax_Customer_Name IS NULL)))
           AND (   (Recinfo.tax_customer_reference=X_Tax_Customer_Reference)
                OR (    (Recinfo.tax_customer_reference IS NULL)
                    AND (X_Tax_Customer_Reference IS NULL)))
           AND (   (Recinfo.tax_registration_number=X_Tax_Registration_Number)
                OR (    (Recinfo.tax_registration_number IS NULL)
                    AND (X_Tax_Registration_Number IS NULL)))
           AND (   (Recinfo.tax_line_flag=X_Tax_Line_Flag)
                OR (    (Recinfo.tax_line_flag IS NULL)
                    AND (X_Tax_Line_Flag IS NULL)))
           AND (   (Recinfo.tax_group_id=X_Tax_Group_Id)
                OR (    (Recinfo.tax_group_id IS NULL)
                    AND (X_Tax_Group_Id IS NULL)))
           AND (   (Recinfo.co_third_party=X_Third_Party_Id)
                OR (    (Recinfo.co_third_party IS NULL)
                    AND (X_Third_Party_Id IS NULL)))
           AND (   (Recinfo.global_attribute1=X_Global_Attribute1)
                OR (    (Recinfo.global_attribute1 IS NULL)
                    AND (X_Global_Attribute1 IS NULL)))
           AND (   (Recinfo.global_attribute2=X_Global_Attribute2)
                OR (    (Recinfo.global_attribute2 IS NULL)
                    AND (X_Global_Attribute2 IS NULL)))
           AND (   (Recinfo.global_attribute3=X_Global_Attribute3)
                OR (    (Recinfo.global_attribute3 IS NULL)
                    AND (X_Global_Attribute3 IS NULL)))
           AND (   (Recinfo.global_attribute4=X_Global_Attribute4)
                OR (    (Recinfo.global_attribute4 IS NULL)
                    AND (X_Global_Attribute4 IS NULL)))
           AND (   (Recinfo.global_attribute5=X_Global_Attribute5)
                OR (    (Recinfo.global_attribute5 IS NULL)
                    AND (X_Global_Attribute5 IS NULL)))
           AND (   (Recinfo.global_attribute6=X_Global_Attribute6)
                OR (    (Recinfo.global_attribute6 IS NULL)
                    AND (X_Global_Attribute6 IS NULL)))
           AND (   (Recinfo.global_attribute7=X_Global_Attribute7)
                OR (    (Recinfo.global_attribute7 IS NULL)
                    AND (X_Global_Attribute7 IS NULL)))
           AND (   (Recinfo.global_attribute8=X_Global_Attribute8)
                OR (    (Recinfo.global_attribute8 IS NULL)
                    AND (X_Global_Attribute8 IS NULL)))
           AND (   (Recinfo.global_attribute9=X_Global_Attribute9)
                OR (    (Recinfo.global_attribute9 IS NULL)
                    AND (X_Global_Attribute9 IS NULL)))
           AND (   (Recinfo.global_attribute10=X_Global_Attribute10)
                OR (    (Recinfo.global_attribute10 IS NULL)
                    AND (X_Global_Attribute10 IS NULL)))
           AND (   (Recinfo.global_attribute_category
                     =X_Global_Attribute_Category)
                OR (    (Recinfo.global_attribute_category IS NULL)
                    AND (X_Global_Attribute_Category IS NULL)))
         ) then

           IF (X_Recon_Rowid IS NOT NULL) THEN
             gl_je_lines_recon_pkg.lock_row(
               X_RowId => X_Recon_Rowid,
               X_Je_Header_Id=>X_Je_Header_id,
               X_Je_Line_Num=>X_Je_Line_Num,
               X_Ledger_Id=>X_Ledger_Id,
               X_Jgzz_Recon_Status=>X_Jgzz_Recon_Status,
               X_Jgzz_Recon_Date=>X_Jgzz_Recon_Date,
               X_Jgzz_Recon_Id=>X_Jgzz_Recon_Id,
               X_Jgzz_Recon_Ref=>X_Jgzz_Recon_Ref);
           END IF;
         else
           FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
           APP_EXCEPTION.RAISE_EXCEPTION;
         end if;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Je_Header_Id                   NUMBER,
                       X_Je_Line_Num                    NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Ledger_Id			NUMBER,
                       X_Code_Combination_Id            NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Effective_Date                 DATE,
                       X_Status                         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Entered_Dr                     NUMBER,
                       X_Entered_Cr                     NUMBER,
                       X_Accounted_Dr                   NUMBER,
                       X_Accounted_Cr                   NUMBER,
                       X_Description                    VARCHAR2,
                       X_Reference_1                    VARCHAR2,
                       X_Reference_2                    VARCHAR2,
                       X_Reference_3                    VARCHAR2,
                       X_Reference_4                    VARCHAR2,
                       X_Reference_5                    VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Context2                       VARCHAR2,
                       X_Invoice_Date                   DATE,
                       X_Tax_Code                       VARCHAR2,
                       X_Invoice_Identifier             VARCHAR2,
                       X_Invoice_Amount                 NUMBER,
                       X_No1                            VARCHAR2,
                       X_Stat_Amount                    NUMBER,
                       X_Ignore_Rate_Flag               VARCHAR2,
                       X_Context3                       VARCHAR2,
                       X_Ussgl_Transaction_Code         VARCHAR2,
                       X_Subledger_Doc_Sequence_Id      NUMBER,
                       X_Context4                       VARCHAR2,
                       X_Subledger_Doc_Sequence_Value   NUMBER,
                       X_Reference_6                    VARCHAR2,
                       X_Reference_7                    VARCHAR2,
                       X_Reference_8                    VARCHAR2,
                       X_Reference_9                    VARCHAR2,
                       X_Reference_10                   VARCHAR2,
                       X_Recon_On_Flag			VARCHAR2,
		       X_Recon_Rowid	  IN OUT NOCOPY VARCHAR2,
		       X_Jgzz_Recon_Status		VARCHAR2,
		       X_Jgzz_Recon_Date		DATE,
		       X_Jgzz_Recon_Id			NUMBER,
		       X_Jgzz_Recon_Ref			VARCHAR2,
		       X_Taxable_Line_Flag		VARCHAR2,
		       X_Tax_Type_Code			VARCHAR2,
		       X_Tax_Code_Id			NUMBER,
		       X_Tax_Rounding_Rule_Code		VARCHAR2,
		       X_Amount_Includes_Tax_Flag	VARCHAR2,
		       X_Tax_Document_Identifier	VARCHAR2,
		       X_Tax_Document_Date		DATE,
		       X_Tax_Customer_Name		VARCHAR2,
		       X_Tax_Customer_Reference		VARCHAR2,
		       X_Tax_Registration_Number	VARCHAR2,
		       X_Tax_Line_Flag			VARCHAR2,
		       X_Tax_Group_Id			NUMBER,
                       X_Third_Party_Id		        VARCHAR2,
		       X_Global_Attribute1              VARCHAR2,
                       X_Global_Attribute2              VARCHAR2,
                       X_Global_Attribute3              VARCHAR2,
                       X_Global_Attribute4              VARCHAR2,
                       X_Global_Attribute5              VARCHAR2,
                       X_Global_Attribute6              VARCHAR2,
                       X_Global_Attribute7              VARCHAR2,
                       X_Global_Attribute8              VARCHAR2,
                       X_Global_Attribute9              VARCHAR2,
                       X_Global_Attribute10             VARCHAR2,
                       X_Global_Attribute_Category      VARCHAR2

 ) IS
 BEGIN
   -- Add any new segment values
   gl_je_segment_values_pkg.insert_ccid_segment_values(
      X_Je_Header_Id,
      X_Code_Combination_Id,
      X_Last_Updated_By,
      X_Last_Update_Login);

   UPDATE GL_JE_LINES
   SET
     je_header_id                      =     X_Je_Header_Id,
     je_line_num                       =     X_Je_Line_Num,
     last_update_date                  =     X_Last_Update_Date,
     last_updated_by                   =     X_Last_Updated_By,
     ledger_id                         =     X_Ledger_Id,
     code_combination_id               =     X_Code_Combination_Id,
     period_name                       =     X_Period_Name,
     effective_date                    =     X_Effective_Date,
     status                            =     X_Status,
     last_update_login                 =     X_Last_Update_Login,
     entered_dr                        =     X_Entered_Dr,
     entered_cr                        =     X_Entered_Cr,
     accounted_dr                      =     X_Accounted_Dr,
     accounted_cr                      =     X_Accounted_Cr,
     description                       =     X_Description,
     reference_1                       =     X_Reference_1,
     reference_2                       =     X_Reference_2,
     reference_3                       =     X_Reference_3,
     reference_4                       =     X_Reference_4,
     reference_5                       =     X_Reference_5,
     attribute1                        =     X_Attribute1,
     attribute2                        =     X_Attribute2,
     attribute3                        =     X_Attribute3,
     attribute4                        =     X_Attribute4,
     attribute5                        =     X_Attribute5,
     attribute6                        =     X_Attribute6,
     attribute7                        =     X_Attribute7,
     attribute8                        =     X_Attribute8,
     attribute9                        =     X_Attribute9,
     attribute10                       =     X_Attribute10,
     attribute11                       =     X_Attribute11,
     attribute12                       =     X_Attribute12,
     attribute13                       =     X_Attribute13,
     attribute14                       =     X_Attribute14,
     attribute15                       =     X_Attribute15,
     attribute16                       =     X_Attribute16,
     attribute17                       =     X_Attribute17,
     attribute18                       =     X_Attribute18,
     attribute19                       =     X_Attribute19,
     attribute20                       =     X_Attribute20,
     context                           =     X_Context,
     context2                          =     X_Context2,
     invoice_date                      =     X_Invoice_Date,
     tax_code                          =     X_Tax_Code,
     invoice_identifier                =     X_Invoice_Identifier,
     invoice_amount                    =     X_Invoice_Amount,
     no1                               =     X_No1,
     stat_amount                       =     X_Stat_Amount,
     ignore_rate_flag                  =     X_Ignore_Rate_Flag,
     context3                          =     X_Context3,
     ussgl_transaction_code            =     X_Ussgl_Transaction_Code,
     subledger_doc_sequence_id         =     X_Subledger_Doc_Sequence_Id,
     context4                          =     X_Context4,
     subledger_doc_sequence_value      =     X_Subledger_Doc_Sequence_Value,
     reference_6                       =     X_Reference_6,
     reference_7                       =     X_Reference_7,
     reference_8                       =     X_Reference_8,
     reference_9                       =     X_Reference_9,
     reference_10                      =     X_Reference_10,
     taxable_line_flag		       =     X_Taxable_Line_Flag,
     tax_type_code		       =     X_Tax_Type_Code,
     tax_code_id                       =     X_Tax_Code_Id,
     tax_rounding_rule_code            =     X_Tax_Rounding_Rule_Code,
     amount_includes_tax_flag          =     X_Amount_Includes_Tax_Flag,
     tax_document_identifier           =     X_Tax_Document_Identifier,
     tax_document_date                 =     X_Tax_Document_Date,
     tax_customer_name                 =     X_Tax_Customer_Name,
     tax_customer_reference            =     X_Tax_Customer_Reference,
     tax_registration_number           =     X_Tax_Registration_Number,
     tax_line_flag                     =     X_Tax_Line_Flag,
     tax_group_id                      =     X_Tax_Group_Id,
     co_third_party                    =     X_Third_Party_Id,
     global_attribute1                 =     X_Global_Attribute1,
     global_attribute2                 =     X_Global_Attribute2,
     global_attribute3                 =     X_Global_Attribute3,
     global_attribute4                 =     X_Global_Attribute4,
     global_attribute5                 =     X_Global_Attribute5,
     global_attribute6                 =     X_Global_Attribute6,
     global_attribute7                 =     X_Global_Attribute7,
     global_attribute8                 =     X_Global_Attribute8,
     global_attribute9                 =     X_Global_Attribute9,
     global_attribute10                =     X_Global_Attribute10,
     global_attribute_category         =     X_Global_Attribute_Category
   WHERE rowid = X_rowid;

   IF (SQL%NOTFOUND) THEN
     Raise NO_DATA_FOUND;
   END IF;

   -- If no row exists, insert one if reconciliation is now on
   IF (X_Recon_Rowid IS NULL) THEN
     IF (X_Recon_On_Flag = 'Y') THEN
       gl_je_lines_recon_pkg.insert_row(
         X_Rowid=>X_Recon_Rowid,
         X_Je_Header_Id=>X_Je_Header_id,
         X_Je_Line_Num=>X_Je_Line_Num,
         X_Ledger_Id=>X_Ledger_Id,
         X_Jgzz_Recon_Status=>X_Jgzz_Recon_Status,
         X_Jgzz_Recon_Date=>X_Jgzz_Recon_Date,
         X_Jgzz_Recon_Id=>X_Jgzz_Recon_Id,
         X_Jgzz_Recon_Ref=>X_Jgzz_Recon_Ref,
         X_Last_Update_Date=>X_Last_Update_Date,
         X_Last_Updated_By=>X_Last_Updated_By,
         X_Last_Update_Login=>X_Last_Update_Login);
     END IF;

   -- If a row exists, update it if reconciliation is on.  Delete it if
   -- reconciliation is off.
   ELSE
     IF (X_Recon_On_Flag = 'Y') THEN
       gl_je_lines_recon_pkg.update_row(
         X_Rowid=>X_Recon_Rowid,
         X_Je_Header_Id=>X_Je_Header_id,
         X_Je_Line_Num=>X_Je_Line_Num,
         X_Ledger_Id=>X_Ledger_Id,
         X_Jgzz_Recon_Status=>X_Jgzz_Recon_Status,
         X_Jgzz_Recon_Date=>X_Jgzz_Recon_Date,
         X_Jgzz_Recon_Id=>X_Jgzz_Recon_Id,
         X_Jgzz_Recon_Ref=>X_Jgzz_Recon_Ref,
         X_Last_Update_Date=>X_Last_Update_Date,
         X_Last_Updated_By=>X_Last_Updated_By,
         X_Last_Update_Login=>X_Last_Update_Login);
     ELSE
       gl_je_lines_recon_pkg.delete_row(
         X_Rowid=>X_Recon_Rowid);
       X_Recon_Rowid := null;
     END IF;
   END IF;
  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid                          VARCHAR2,
                       X_Recon_Rowid			VARCHAR2) IS
     CURSOR c_del_line (lv_row_id VARCHAR2 )IS
     SELECT je_line_num,je_header_id
     FROM GL_JE_LINES
     WHERE rowid = lv_row_id ;

     lv_header_id number;
     lv_line_num number;
  BEGIN
    OPEN c_del_line ( X_Rowid);
    FETCH c_del_line into lv_line_num , lv_header_id ;
    CLOSE c_del_line;

    DELETE FROM GL_JE_LINES
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    -- To delete the reference lines if any in GL_IMPORT_REFERENCES
    GL_IMPORT_REFERENCES_PKG.delete_line (lv_header_id ,lv_line_num );

    -- Delete any reconciliation row
    IF (X_Recon_Rowid IS NOT NULL) THEN
           gl_je_lines_recon_pkg.delete_row(
             X_Rowid=>X_Recon_Rowid);
    END IF;
  END Delete_Row;

END GL_JE_LINES_PKG;

/
