--------------------------------------------------------
--  DDL for Package Body IBY_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DEBUG_PUB" AS
/* $Header: ibypdbgb.pls 120.2.12010000.6 2010/02/12 05:59:13 svinjamu ship $ */


--
--
PROCEDURE Add(debug_msg IN VARCHAR2, debug_level IN NUMBER, module IN VARCHAR2)
IS
BEGIN

   IF (debug_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN

     fnd_log.string(debug_level,module,debug_msg);
     --COMMIT;

     -- if in a concurrent request, also add to the CP log
     IF fnd_global.CONC_REQUEST_ID <> -1 THEN
       FND_FILE.put_line(FND_FILE.LOG, debug_msg);
     END IF;

   END IF;


EXCEPTION
   WHEN OTHERS THEN
     NULL;
END Add;

--
--
PROCEDURE Add(debug_msg IN VARCHAR2)
IS
BEGIN
  iby_debug_pub.Add(debug_msg,
      iby_debug_pub.G_DEBUG_LEVEL,iby_debug_pub.G_DEBUG_MODULE);
END Add;



PROCEDURE Log(module IN VARCHAR2,debug_msg IN VARCHAR2,debug_level IN NUMBER)
IS
BEGIN

   -- Write into log ALWAYS.
   IF fnd_global.CONC_REQUEST_ID <> -1 THEN
      FND_FILE.put_line(FND_FILE.LOG, debug_msg);
   END IF;

   -- Write into log only if DEBUG LEVELS match.
   IF (debug_level >= fnd_log.G_CURRENT_RUNTIME_LEVEL) THEN
     fnd_log.string(debug_level,module,debug_msg);
   END IF;


EXCEPTION
   WHEN OTHERS THEN
     NULL;
END Log;

END IBY_DEBUG_PUB;

/
