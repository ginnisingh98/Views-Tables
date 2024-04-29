--------------------------------------------------------
--  DDL for Package Body IGI_GEN_VERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_GEN_VERT" AS
--- $Header: igigccbb.pls 120.8.12010000.2 2008/08/04 13:02:29 sasukuma ship $


--sdixit 28 jul 2003 MOAC changes START
FUNCTION is_req_installed
                (p_option_name VARCHAR2
                 ,p_org_id NUMBER) RETURN VARCHAR2
IS
  CURSOR Get_installed_option
         is
         SELECT status_flag
         FROM   igi_gcc_installed_options
         WHERE  option_name = upper(p_option_name)
         AND    org_id             = p_org_id;

  --Two queries seperated for bug3855184:Start
  CURSOR Get_gl_fa_installed_option is
         SELECT status_flag
         FROM   igi_gcc_gl_fa_inst_ops
         WHERE  option_name = upper(p_option_name) ;
  --Two queries seperated for bug3855184:End

  v_installed_flag     varchar2(1);

 BEGIN

  OPEN  get_installed_option ;
  FETCH get_installed_option into v_installed_flag;
  IF get_installed_option%NOTFOUND then				--Bug3855184
	OPEN Get_gl_fa_installed_option;			--Bug3855184
	FETCH Get_gl_fa_installed_option into v_installed_flag;	--Bug3855184
	CLOSE Get_gl_fa_installed_option;			--Bug3855184
  END IF;							--Bug3855184
  CLOSE get_installed_option ;

  IF v_installed_flag = 'Y' THEN
     RETURN 'Y';
  ELSE
     RETURN 'N';
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
       RETURN 'N';
END is_req_installed;
--sdixit MOAC chenges END

FUNCTION is_req_installed
                (p_option_name VARCHAR2) RETURN BOOLEAN
is


CURSOR get_installed_option is
 (SELECT status_flag
 FROM   IGI_gcc_installed_options
 WHERE  option_name = upper(p_option_name) );

--Two queries seperated for bug3855184:Start
CURSOR Get_gl_fa_installed_option is
 (SELECT status_flag
 FROM   IGI_gcc_gl_fa_inst_ops
 WHERE  option_name = upper(p_option_name) ) ;
--Two queries seperated for bug3855184:End

v_installed_flag     varchar2(1);

BEGIN

  OPEN get_installed_option ;
  FETCH get_installed_option into v_installed_flag;
  IF get_installed_option%NOTFOUND then				--Bug3855184
	OPEN Get_gl_fa_installed_option;			--Bug3855184
	FETCH Get_gl_fa_installed_option into v_installed_flag;	--Bug3855184
	CLOSE Get_gl_fa_installed_option;			--Bug3855184
  END IF;							--Bug3855184
  CLOSE get_installed_option ;


  IF v_installed_flag = 'Y' THEN
     RETURN TRUE;
  ELSE
     RETURN FALSE;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN

                 RETURN FALSE;

END is_req_installed;


/* ===================================================================
   This Procedure is used to record debug information
   ===================================================================
 */
PROCEDURE DEBUG
                ( p_module          IN VARCHAR2
                , p_module_variable IN VARCHAR2
                , p_variable_value  IN VARCHAR2
                , P_message         IN VARCHAR2
                )
  is
  begin

NULL;
/* ********************************************
 UNCOMMENT OUT NOCOPY THIS LINE ONCE THE TABLE IS DEFINED

*****************************************************  *
            insert into IGI_debug_all ( MODULE
                                    , MODULE_VARIABLE
                                    , VARIABLE_VALUE
                                    , MODULE_MESSAGE
                                    , DEBUG_SEQUENCE)
            select                    p_module
                                    , p_module_variable
                                    , p_variable_value
                                    , P_message
                                    , IGI_debug_s.nextval
            from dual;
            commit;

*********************************************************  */
  EXCEPTION
        when others then null;
  end;

/* ===================================================================
   This Procedure returns entries STATUS_FLAG and ERROR_NUM from
   IGI_INSTALLED_OPTIONS for a given OPTION_NAME
   ===================================================================
 */

PROCEDURE get_option_status
                ( p_option_name  IN  VARCHAR2
                , p_status_flag  OUT NOCOPY VARCHAR2
                , p_error_num    OUT NOCOPY NUMBER
                )
IS

CURSOR stat_check IS
         (SELECT status_flag
         FROM   IGI_gcc_installed_options
         WHERE  option_name = upper(p_option_name ));

--Two queries seperated for bug3855184:Start
CURSOR gl_fa_stat_check is
          (SELECT status_flag
          FROM   IGI_gcc_gl_fa_inst_ops
          WHERE  option_name = upper(p_option_name ))  ;
--Two queries seperated for bug3855184:End

BEGIN
      p_error_num := 0;
      p_status_flag := 'N';

      OPEN stat_check ;
      FETCH stat_check into p_status_flag;
      IF stat_check%NOTFOUND then			--Bug3855184
	OPEN gl_fa_stat_check;				--Bug3855184
	FETCH gl_fa_stat_check into p_status_flag;	--Bug3855184
	CLOSE gl_fa_stat_check;				--Bug3855184
      END IF;						--Bug3855184
      CLOSE stat_check;

EXCEPTION
        WHEN NO_DATA_FOUND THEN p_status_flag := 'N';
                                p_error_num   := 1  ;
        WHEN TOO_MANY_ROWS THEN p_status_flag := 'N';
                                p_error_num   := 1  ;
        WHEN OTHERS        THEN p_status_flag := 'N';
                                p_error_num   := 1  ;
END;            -- Of get_option_status




FUNCTION GET_LOOKUP_MEANING (l_lookup_type VARCHAR2
                            ) RETURN VARCHAR2 IS

l_return_meaning VARCHAR2(240);
BEGIN

   SELECT meaning into l_return_meaning
          from IGI_LOOKUPS
          WHERE LOOKUP_TYPE = l_lookup_type;

    return (l_return_meaning);
EXCEPTION
   WHEN OTHERS THEN
        return (l_lookup_type);
END;          -- Of GET_LOOKUP_MEANING



PROCEDURE IGI_EFC_CHECK_OPTIONS
				(p_sob 	NUMBER
				,p_efc1	IN OUT NOCOPY VARCHAR2
				) IS
 -- 29-MAR-00 EGARRETT
 -- Removed the payment_funds_check_flag as it no longer exists
 -- in table (part of EFC II).
    CURSOR c_get_efc_options IS
	SELECT	mult_funding_budgets_flag
	FROM	psa_efc_options
	WHERE	set_of_books_id = p_sob;

	x_mfb	VARCHAR2(1);

BEGIN
	OPEN c_get_efc_options;
	FETCH c_get_efc_options INTO x_mfb;
        IF c_get_efc_options%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;
	IF c_get_efc_options%ISOPEN THEN
		CLOSE c_get_efc_options;
	END IF;

	p_efc1 := x_mfb;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
            IF c_get_efc_options%ISOPEN THEN
			CLOSE c_get_efc_options;
	    END IF;
            p_efc1 := 'N';

        --null;

        WHEN OTHERS THEN
	    fnd_message.set_name('IGI','IGI_EFC_CHECK_OPTIONS');
	    app_exception.raise_exception;
END;

--M Thompson 23-Dec-1998 Add HUL functions  START

FUNCTION get_ap_sob_id  RETURN NUMBER IS
sErrMsg VARCHAR2(2000);
p_sob_id NUMBER;
BEGIN
        SELECT set_of_books_id
        INTO   p_sob_id
        FROM   ap_system_parameters;
        RETURN  (p_sob_id);
EXCEPTION
        WHEN OTHERS THEN sErrMsg := SQLERRM;
                    raise_application_error(-20000, sErrMsg);

END;

FUNCTION get_ar_sob_id  RETURN NUMBER IS
sErrMsg VARCHAR2(2000);
p_sob_id NUMBER;
BEGIN
        SELECT set_of_books_id
        INTO   p_sob_id
        FROM   ar_system_parameters;
        RETURN (p_sob_id);
EXCEPTION
        WHEN OTHERS THEN sErrMsg := SQLERRM;
                    raise_application_error(-20000, sErrMsg);
END;


FUNCTION get_po_sob_id  RETURN NUMBER IS
sErrMsg VARCHAR2(2000);
p_sob_id NUMBER;
BEGIN
        SELECT set_of_books_id
        INTO   p_sob_id
        FROM   financials_system_parameters;
        RETURN (p_sob_id);
EXCEPTION
        WHEN OTHERS THEN sErrMsg := SQLERRM;
                    raise_application_error(-20000, sErrMsg);
END;

--M Thompson 23-Dec-1998 Add HUL functions  END


/* ===================================================================
   This Function checks for at least one igi option installed
   It is being used by IGIUTIL2, to see if it will need to process.
   Any DB hits from IGILUTIL2 are being moved here to package.
   ===================================================================
 */

FUNCTION igiInstalled RETURN BOOLEAN IS

l_ErrMsg VARCHAR2(2000);
l_dummy   VARCHAR2(1);

CURSOR c_igi_install is
       SELECT 'x'
       FROM   igi_gcc_gl_fa_inst_ops
       WHERE  status_flag = 'Y';

BEGIN

  OPEN c_igi_install;
  FETCH c_igi_install INTO l_dummy;
  IF c_igi_install%FOUND THEN
    CLOSE c_igi_install;
    RETURN TRUE;
  END IF;
  CLOSE c_igi_install;
  RETURN FALSE;


EXCEPTION
  WHEN OTHERS THEN l_errMsg := SQLERRM;
    raise_application_error(-20000, l_errMsg);

END igiInstalled;


/* ===================================================================
   This Function saves the IGI installed options within global variables
   This is unavoidable is to prevent continious accesses to the DB.
   This is being used by IGILUTIL2
   ===================================================================
 */

FUNCTION cacheProductOptions RETURN BOOLEAN IS

l_ErrMsg VARCHAR2(2000);

CURSOR c_install_option is
 (SELECT option_name
 FROM   IGI_gcc_installed_options
 WHERE  status_flag = 'Y')
UNION
 (SELECT option_name
 FROM   IGI_gcc_gl_fa_inst_ops
 WHERE  status_flag = 'Y');

BEGIN

  IGI_IGILUTIL2_CBC := FALSE;
  IGI_IGILUTIL2_CC  := FALSE;
  IGI_IGILUTIL2_CIS := FALSE;
  IGI_IGILUTIL2_DOS := FALSE;
  IGI_IGILUTIL2_EXP := FALSE;
  IGI_IGILUTIL2_IAC := FALSE;
  IGI_IGILUTIL2_MHC := FALSE;
  IGI_IGILUTIL2_SIA := FALSE;
  IGI_IGILUTIL2_STP := FALSE;

 FOR install_option_rec IN c_install_option LOOP

    IF  upper(install_option_rec.option_name) = 'CBC' THEN
      IGI_IGILUTIL2_CBC := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'CC' THEN
      IGI_IGILUTIL2_CC := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'CIS' THEN
      IGI_IGILUTIL2_CIS := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'DOS' THEN
      IGI_IGILUTIL2_DOS := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'EXP' THEN
      IGI_IGILUTIL2_EXP := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'IAC' THEN
      IGI_IGILUTIL2_IAC := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'MHC' THEN
      IGI_IGILUTIL2_MHC := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'SIA' THEN
      IGI_IGILUTIL2_SIA := TRUE;
    ELSIF upper(install_option_rec.option_name) = 'STP' THEN
      IGI_IGILUTIL2_STP := TRUE;
    ELSE
      null;
    END IF;

  END LOOP;

  IF IGI_IGILUTIL2_CBC OR IGI_IGILUTIL2_CC OR IGI_IGILUTIL2_CIS OR
     IGI_IGILUTIL2_DOS OR IGI_IGILUTIL2_EXP OR IGI_IGILUTIL2_IAC OR
     IGI_IGILUTIL2_MHC OR IGI_IGILUTIL2_SIA OR IGI_IGILUTIL2_STP
     THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;


EXCEPTION
  WHEN OTHERS THEN l_errMsg := SQLERRM;
    raise_application_error(-20000, l_errMsg);

END cacheProductOptions;



/* ===================================================================
   This Function gets the global variables from the package spec.
   Apparently Forms and libraries cannot access global variables
   in a stored package directly, you have to go by function or procedure
   ===================================================================
 */

FUNCTION productEnabled ( prod IN VARCHAR2 ) RETURN BOOLEAN IS

l_ErrMsg VARCHAR2(2000);

BEGIN

  IF  upper(prod) = 'CBC' THEN
    IF IGI_IGILUTIL2_CBC THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'CC' THEN
    IF IGI_IGILUTIL2_CC THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'CIS' THEN
    IF IGI_IGILUTIL2_CIS THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'DOS' THEN
    IF IGI_IGILUTIL2_DOS THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'EXP' THEN
    IF IGI_IGILUTIL2_EXP THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'IAC' THEN
    IF IGI_IGILUTIL2_IAC THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'MHC' THEN
    IF IGI_IGILUTIL2_MHC THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'SIA' THEN
    IF IGI_IGILUTIL2_SIA THEN
      RETURN TRUE;
    END IF;
  ELSIF upper(prod) = 'STP' THEN
    IF IGI_IGILUTIL2_STP THEN
      RETURN TRUE;
    END IF;
  ELSE
    RETURN FALSE;
  END IF;

  RETURN FALSE;


EXCEPTION
  WHEN OTHERS THEN l_errMsg := SQLERRM;
    raise_application_error(-20000, l_errMsg);

END productEnabled;

/* ============================================================== */
END;

/
