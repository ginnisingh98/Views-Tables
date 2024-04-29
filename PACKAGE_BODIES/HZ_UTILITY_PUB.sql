--------------------------------------------------------
--  DDL for Package Body HZ_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_UTILITY_PUB" AS
/*$Header: ARHUTILB.pls 120.1 2005/06/16 21:16:19 jhuang ship $ */

   FUNCTION created_by RETURN NUMBER IS
   BEGIN
      RETURN nvl(FND_GLOBAL.user_id,-1);
   END;

   FUNCTION creation_date RETURN DATE IS
   BEGIN
      RETURN SYSDATE;
   END;

   FUNCTION last_updated_by RETURN NUMBER IS
   BEGIN
      RETURN nvl(FND_GLOBAL.user_id,-1);
   END;

   FUNCTION last_update_date RETURN DATE IS
   BEGIN
      RETURN SYSDATE;
   END;

   FUNCTION last_update_login RETURN NUMBER IS
   BEGIN
      IF FND_GLOBAL.conc_login_id = -1 OR
         FND_GLOBAL.conc_login_id IS NULL
      THEN
         RETURN FND_GLOBAL.login_id;
      ELSE
         RETURN FND_GLOBAL.conc_login_id;
      END IF;
   END;

   FUNCTION request_id RETURN NUMBER IS
   BEGIN
      IF ( FND_GLOBAL.conc_request_id = -1 ) OR
         ( FND_GLOBAL.conc_request_id IS NULL )
      THEN
         RETURN NULL;
      ELSE
         RETURN FND_GLOBAL.conc_request_id;
      END IF;
   END;

   FUNCTION program_id RETURN NUMBER IS
   BEGIN
      IF ( FND_GLOBAL.conc_program_id = -1 ) OR
         ( FND_GLOBAL.conc_program_id IS NULL )
      THEN
         RETURN NULL;
      ELSE
         RETURN FND_GLOBAL.conc_program_id;
      END IF;
   END;

   FUNCTION program_application_id RETURN NUMBER IS
   BEGIN
      IF ( FND_GLOBAL.prog_appl_id = -1 ) OR
         ( FND_GLOBAL.prog_appl_id IS NULL )
      THEN
         RETURN NULL;
      ELSE
         RETURN FND_GLOBAL.prog_appl_id;
      END IF;
   END;

   FUNCTION program_update_date RETURN DATE IS
   BEGIN
      IF ( program_id IS NULL )
      THEN
         RETURN NULL;
      ELSE
         RETURN SYSDATE;
      END IF;
   END;

   FUNCTION user_id RETURN NUMBER IS
   BEGIN
      RETURN nvl(FND_GLOBAL.user_id,-1);
   END;

END hz_utility_pub;

/
