--------------------------------------------------------
--  DDL for Package Body IGI_SLS_CONTEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_SLS_CONTEXT_PKG" AS
-- $Header: igislsib.pls 120.6.12000000.2 2007/10/03 17:18:44 npandya ship $
--

	l_debug_level NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
	l_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
	l_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
	l_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
	l_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
	l_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
	l_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
	l_path        VARCHAR2(50)  :=  'IGI.PLSQL.igislsib.igi_sls_context_pkg.';


/*-----------------------------------------------------------------
  This procedure writes to the error log.
 -----------------------------------------------------------------*/
PROCEDURE Write_To_Log (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
BEGIN
    IF (p_level >=  l_debug_level ) THEN
           FND_LOG.STRING  (p_level , l_path || p_path , p_mesg );
    END IF;
END Write_To_Log;

/*---------------------------------------------------------------
  This procedure initializes the SLS Application Context.
----------------------------------------------------------------*/
PROCEDURE set_sls_context IS
-- $Header: igislsib.pls 115.0 2000/08/16 13:16:20 asmales ship
--
l_sls_security_group 	VARCHAR2(40);
l_security_name 	VARCHAR2(40):= 'IGI_SLS_SECURITY_GROUP';
l_default_security_name VARCHAR2(40):= 'IGI_SLS_DEFAULT_USER_GROUP';
l_sls_responsibility 	VARCHAR2(40):= 'IGI_SLS_RESPONSIBILITY';
l_value1 		VARCHAR2(40);
l_value2 		VARCHAR2(40);
l_status  		VARCHAR2(5) ;
l_resp			VARCHAR2(5);
l_dummy	                VARCHAR2(1);
l_mess			VARCHAR2(2000);
l_sec_grp               VARCHAR2(30);

cursor c1 (p_sec_grp   VARCHAR2) is
                SELECT  'Y'
		FROM igi_sls_groups
		WHERE sls_group = p_sec_grp
                AND   date_removed IS NULL
                AND   date_disabled IS NULL;
--
BEGIN

  /* Change made to simply policy and trigger checks
  SLS_ENABLED is being set to 'Y' only is SLS responsibility and SLS is
  enabled for the operating unit.
  SLS_SECURITY_GROUP is being set to the Security Group if present or the
  default security group
  Bidisha S,  28 Mar 2002
  */

  DBMS_SESSION.SET_CONTEXT('IGI','SLS_ENABLED','N');
  DBMS_SESSION.SET_CONTEXT('IGI','SLS_GROUP_STATUS','N');
  DBMS_SESSION.SET_CONTEXT('IGI','SLS_RESPONSIBILITY','N');

  FND_PROFILE.GET(l_sls_responsibility, l_resp);

  IF l_resp = 'Y' THEN
/*     -- check for the existance of the IGI context
     SELECT 'X'
     INTO l_dummy
     FROM all_context
     WHERE namespace = 'IGI';
*/  -- Removed the above code as it is no longer required - ak bug3975504.

     DBMS_SESSION.SET_CONTEXT('IGI','SLS_RESPONSIBILITY','Y');

/* R12 SLS uptake::
     Removing the check if SLS is enabled for this org-id.
     IF IGI_GEN.IS_REQ_INSTALLED('SLS')
     THEN
*/
          DBMS_SESSION.SET_CONTEXT('IGI','SLS_ENABLED','Y');

          DBMS_SESSION.SET_CONTEXT('IGI','SLS_DEFAULT_SECURITY_GROUP',
                                   FND_PROFILE.VALUE(l_default_security_name));

          -- Set to Security Group or default security Group
          l_sec_grp := Nvl(FND_PROFILE.VALUE(l_security_name),
                           FND_PROFILE.VALUE(l_default_security_name));

          DBMS_SESSION.SET_CONTEXT('IGI','SLS_SECURITY_GROUP',l_sec_grp);

          Open C1 (l_sec_grp);
          fetch c1 into l_status;
          IF c1%NOTFOUND THEN
             l_Status := 'N';
          END IF;
          CLOSE C1;

          DBMS_SESSION.SET_CONTEXT('IGI','SLS_GROUP_STATUS',l_status);

/*
     R12 SLS uptake::
     Removing the check if SLS is enabled for this org-id.
     END IF; -- SLS Enabled
*/

   END IF; -- SLS Responsibility

EXCEPTION
WHEN NO_DATA_FOUND THEN
     igi_sls_context_pkg .write_to_log(l_excep_level, 'set_sls_context','igi_sls_context_pkg.set_sls_context - failed with error ' || SQLERRM );
     fnd_message.set_name('IGI','IGI_SLS_IGI_CONTEXT_NOT_SET');
     IF ( l_excep_level >=  l_debug_level ) THEN
         FND_LOG.MESSAGE (l_excep_level,l_path || 'set_sls_context',FALSE);
     END IF;
     app_exception.raise_exception;

WHEN OTHERS THEN
     igi_sls_context_pkg .write_to_log(l_excep_level, 'set_sls_context','igi_sls_context_pkg.set_sls_context - failed with error ' || SQLERRM );

     IF ( l_unexp_level >= l_debug_level ) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE ( l_unexp_level,l_path || 'set_sls_context', FALSE);
     END IF;
     app_exception.raise_exception;

END set_sls_context;

END igi_sls_context_pkg;

/
