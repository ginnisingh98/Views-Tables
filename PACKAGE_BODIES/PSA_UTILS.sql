--------------------------------------------------------
--  DDL for Package Body PSA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_UTILS" as
/* $Header: PSAUTILB.pls 120.3 2005/06/08 10:24:28 rgopalan ship $ */

g_debug_level NUMBER;
g_unexp_level NUMBER;

-- This procedure is stubbed out because this has been replaced with fnd logging procedures
-- The signature is still kept because some AR packages are accessing it

PROCEDURE debug_mesg ( p_msg    IN   VARCHAR2 )
IS

BEGIN
 null;
END debug_mesg;

/* ====================== DEBUG_UNEXPECTED_MSG ===================== */

PROCEDURE debug_unexpected_msg(p_full_path IN VARCHAR2) IS
BEGIN
        FND_MESSAGE.SET_NAME('PSA','PSA_LOGGING_USER_ERROR');
	FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
        IF (g_unexp_level >= g_debug_level) THEN
	   	FND_MESSAGE.SET_NAME('PSA','PSA_LOGGING_UNEXP_ERROR');
     		FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
     		FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
     		FND_LOG.MESSAGE (g_unexp_level,p_full_path, TRUE);
	END IF;

END debug_unexpected_msg;

/* ===================== DEBUG_OTHER_MSG ============================ */

PROCEDURE debug_other_msg(p_level IN NUMBER,
			      p_full_path IN VARCHAR2,
			      p_remove_from_stack IN BOOLEAN) IS
BEGIN
     	IF (p_level >= g_debug_level) THEN
		fnd_log.message(p_level,p_full_path,p_remove_from_stack);
        END IF;

END debug_other_msg;

/* ==================== DEBUG_OTHER_STRING ========================= */

PROCEDURE debug_other_string(p_level IN NUMBER,
          			     p_full_path IN VARCHAR2,
			         p_string IN VARCHAR2) IS
BEGIN
	IF (p_level >= g_debug_level) THEN
	   fnd_log.string(p_level,p_full_path,p_string);
	END IF;

END debug_other_string;

BEGIN
  g_debug_level :=      FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_unexp_level :=      FND_LOG.LEVEL_UNEXPECTED;
END ;

/
