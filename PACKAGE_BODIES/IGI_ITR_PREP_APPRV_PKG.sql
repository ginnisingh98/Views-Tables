--------------------------------------------------------
--  DDL for Package Body IGI_ITR_PREP_APPRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_PREP_APPRV_PKG" as
-- $Header: igiitrub.pls 120.6.12010000.2 2008/08/04 13:04:16 sasukuma ship $
--


      l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
      l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
      l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
      l_event_level number	:=	FND_LOG.LEVEL_EVENT;
      l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
      l_error_level number	:=	FND_LOG.LEVEL_ERROR;
      l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
      l_path    VARCHAR2(50):= 'IGI.PLSQL.igiitrub.IGI_ITR_PREP_APPRV_PKG.';

-- ****************************************************************************
-- Private procedure: Display diagnostic message
-- ****************************************************************************
PROCEDURE diagn_msg (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2 ) IS
BEGIN
        IF (p_level >=  l_debug_level ) THEN
                  FND_LOG.STRING (p_level , l_path || p_path , p_mesg );
        END IF;
END ;



--
-- ****************************************************************************
-- Private function: Get authorization limit..--
--****************************************************************************
FUNCTION get_authorization_limit (p_employee_id NUMBER,
                                  p_set_of_books_id NUMBER) RETURN NUMBER IS
 l_limit  NUMBER;
BEGIN

  SELECT nvl(authorization_limit, 0)
  INTO   l_limit
  FROM   GL_AUTHORIZATION_LIMITS
  WHERE  employee_id = p_employee_id
    AND  ledger_id = p_set_of_books_id;

  return (l_limit);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_limit := 0;
    return (l_limit);
  WHEN OTHERS
  THEN
   IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrub.IGI_ITR_PREP_APPRV_PKG.get_authorization_limit',TRUE);
    END IF;
   raise_application_error (-20001,'IGI_ITR_PREP_APPRV_PKG.get_authorization_limit'||SQLERRM);

END get_authorization_limit;


--
--  ********************************************************************
-- can_preparer_approve
-- *********************************************************************
--
-- finds out whether preparer is authorised to approve AND has enough
-- approval limit to approve the service line on the cross charge
--  returns a value of 'Y' or 'N'
--
  PROCEDURE can_preparer_approve(p_cc_id NUMBER
                                ,p_cc_line_num NUMBER
                                ,p_preparer_fnd_user_id NUMBER
                                ,p_sob_id NUMBER
                                ,p_prep_can_approve OUT NOCOPY VARCHAR2
   )
  IS
    l_cc_approval_amt     NUMBER;
    l_preparer_id         NUMBER;
    l_originator_approve  VARCHAR2(1);
    l_profile_option_val  fnd_profile_option_values.profile_option_value%TYPE;
    l_authorization_limit NUMBER;

  BEGIN

-- get the amount of the service line and populate the cross charge
-- approval amount.
   SELECT   abs(nvl(ITRL.entered_dr,0) - nvl(ITRL.entered_cr,0))
   INTO     l_cc_approval_amt
   FROM     IGI_ITR_CHARGE_LINES ITRL
   WHERE    ITRL.it_header_id = p_cc_id
   AND      ITRL.it_line_num = p_cc_line_num;

    diagn_msg(l_state_level,'can_preparer_approve','l_cc_approval_amt ='||l_cc_approval_amt);

-- get employee id of the preparer
    SELECT employee_id
    INTO   l_preparer_id
    FROM   fnd_user
    WHERE  user_id = p_preparer_fnd_user_id;

    diagn_msg(l_state_level,'can_preparer_approve','l_preparer_id ='||l_preparer_id);


--  find if the originator can approve is set to yes or no
    SELECT nvl(originator_approve_flag,'N')
    INTO   l_originator_approve
    FROM   igi_itr_charge_setup
    WHERE  set_of_books_id = p_sob_id;

    diagn_msg(l_state_level,'can_preparer_approve','originator_approve_flag ='||l_originator_approve);

--  get authorization limit of preparer
    l_authorization_limit := get_authorization_limit(l_preparer_id,
                                                     p_sob_id);


    diagn_msg(l_state_level,'can_preparer_approve','l_authorization_limit ='||l_authorization_limit);

    IF (l_originator_approve = 'Y') AND
       (l_authorization_limit >= l_cc_approval_amt) THEN
      p_prep_can_approve := 'Y';
    ELSE
      p_prep_can_approve := 'N';
    END IF;

  EXCEPTION
    WHEN OTHERS
    THEN
     /* ssemwal for NOCOPY begin(1) */
     p_prep_can_approve := Null;
     /* ssemwal for NOCOPY end(1) */
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrub.IGI_ITR_PREP_APPRV_PKG.can_preparer_approve',TRUE);
    END IF;
    raise_application_error
    (-20001,'IGI_ITR_PREP_APPRV_PKG.can_preparer_approve'||SQLERRM);

END can_preparer_approve;


END IGI_ITR_PREP_APPRV_PKG;

/
