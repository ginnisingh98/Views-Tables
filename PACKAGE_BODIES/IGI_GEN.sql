--------------------------------------------------------
--  DDL for Package Body IGI_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_GEN" AS
--- $Header: igigccab.pls 120.7.12010000.2 2008/08/04 13:01:52 sasukuma ship $

 /*
 ## The function is_req_installed is modified to handle
 ## both MOAC and thru normal profile option.
 */

 FUNCTION is_req_installed (p_option_name VARCHAR2,
                            p_org_id       NUMBER)
 RETURN VARCHAR2
 IS

  CURSOR Get_installed_option
         is
         SELECT status_flag
         FROM   igi_gcc_inst_options_all -- Use _ALL table instead of view
         WHERE  option_name = upper(p_option_name)
         AND    org_id             = p_org_id;

  --Two queries seperated for Bug3855184:Start
  CURSOR Get_gl_fa_installed_option
    is
         SELECT status_flag
         FROM   igi_gcc_gl_fa_inst_ops
         WHERE  option_name = upper(p_option_name) ;
  --Two queries seperated for Bug3855184:End

  v_installed_flag     varchar2(1);

 BEGIN

  OPEN  get_installed_option ;
  FETCH get_installed_option into v_installed_flag;
  IF Get_installed_option%NOTFOUND THEN       --Bug3855184
  OPEN Get_gl_fa_installed_option;      --Bug3855184
  FETCH get_gl_fa_installed_option into v_installed_flag; --Bug3855184
  CLOSE Get_gl_fa_installed_option;     --Bug3855184
  END IF;             --Bug3855184
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

FUNCTION is_req_installed (p_option_name VARCHAR2) RETURN BOOLEAN
is
  -- Bug 3974541 agovil
  -- CURSOR Get_installed_option (p_org_id NUMBER)
  CURSOR Get_installed_option
         is
         SELECT status_flag
         FROM   igi_gcc_installed_options
         WHERE  option_name = upper(p_option_name);
         -- AND    org_id             = p_org_id

  --Two queries seperated for Bug3855184:Start
  CURSOR Get_gl_fa_installed_option IS
         SELECT status_flag
         FROM   IGI_gcc_gl_fa_inst_ops
         WHERE  option_name = upper(p_option_name) ;
  --Two queries seperated for Bug3855184:End

  v_installed_flag     varchar2(1);
  -- l_org_id             number;

BEGIN

  /*
  ## As the client_info is removed from the view due to
  ## MOAC changes we have to explicitly set the org id
  ## from the profile option.
  */

  -- l_org_id := fnd_profile.value('ORG_ID');

  -- OPEN get_installed_option (l_org_id);
  OPEN get_installed_option ;
  FETCH get_installed_option into v_installed_flag;
  if get_installed_option%NOTFOUND then       --Bug3855184
  OPEN GET_GL_FA_INSTALLED_OPTION;      --Bug3855184
  FETCH get_gl_fa_installed_option into v_installed_flag; --Bug3855184
  CLOSE Get_gl_fa_installed_option;     --Bug3855184
  end if;             --Bug3855184
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
   =================================================================== */

PROCEDURE DEBUG
                ( p_module          IN VARCHAR2
                , p_module_variable IN VARCHAR2
                , p_variable_value  IN VARCHAR2
                , P_message         IN VARCHAR2
                )
  is
  begin

   NULL;

/* *******************************************************
 UNCOMMENT OUT NOCOPY THIS LINE ONCE THE TABLE IS DEFINED
  ********************************************************
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

--Two queries seperated for Bug3855184:Start
CURSOR gl_fa_stat_check IS
          (SELECT status_flag
          FROM   IGI_gcc_gl_fa_inst_ops
          WHERE  option_name = upper(p_option_name ))  ;
--Two queries seperated for Bug3855184:End

BEGIN
      p_error_num := 0;
      p_status_flag := 'N';

      OPEN stat_check ;
      FETCH stat_check into p_status_flag;
      IF stat_check%NOTFOUND then     --Bug3855184
  OPEN gl_fa_stat_check;        --Bug3855184
  FETCH gl_fa_stat_check into p_status_flag;  --Bug3855184
  CLOSE gl_fa_stat_check;       --Bug3855184
      END IF;           --Bug3855184
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
        (p_sob  NUMBER
        ,p_efc1 IN OUT NOCOPY VARCHAR2
        ) IS
 -- 29-MAR-00 EGARRETT
 -- Removed the payment_funds_check_flag as it no longer exists
 -- in table (part of EFC II).
    CURSOR c_get_efc_options IS
  SELECT  mult_funding_budgets_flag
  FROM  psa_efc_options
  WHERE set_of_books_id = p_sob;

  x_mfb VARCHAR2(1);

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


Function Get_Igi_Prompt(p_lookup_code in Varchar2) Return Varchar2 Is
   Cursor Igi_Prompt Is
      Select meaning
      from igi_lookups
      Where lookup_type = 'IGI_PROMPTS'
        and lookup_code = p_lookup_code;
   l_prompt varchar2(80);
Begin
   Open Igi_Prompt;
   Fetch igi_Prompt into l_prompt;
   Close Igi_Prompt;
   return l_prompt;
Exception
   When Others Then
        Close Igi_Prompt;
        return l_prompt;
End Get_Igi_Prompt;


--Function added for MOAC returns responsibility the user has signed into
Function get_igi_window_title return varchar2 is

BEGIN
return null;
END get_igi_window_title;

/* ============================================================== */
END;

/
