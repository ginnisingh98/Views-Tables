--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_UTILS_PKG" as
/* $Header: AFOAMDSCUTILB.pls 120.2 2005/12/19 11:27 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_UTILS_PKG.';

   DATE_VALUE_ERROR     EXCEPTION;
   PRAGMA EXCEPTION_INIT(DATE_VALUE_ERROR, -1858);

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION BOOLEAN_TO_CANONICAL(p_boolean              IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_boolean THEN
         RETURN FND_API.G_TRUE;
      END IF;

      RETURN FND_API.G_FALSE;
   END;

   -- Public
   FUNCTION CANONICAL_TO_BOOLEAN(p_canonical_value      IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_canonical_value IS NOT NULL THEN
         IF p_canonical_value = FND_API.G_TRUE THEN
            RETURN TRUE;
         ELSIF p_canonical_value = FND_API.G_FALSE THEN
            RETURN FALSE;
         END IF;
      END IF;
      RAISE VALUE_ERROR;
   END;

   -- Public
   FUNCTION NUMBER_TO_CANONICAL(p_number                IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN FND_NUMBER.NUMBER_TO_CANONICAL(p_number);
   END;

   -- Public
   FUNCTION CANONICAL_TO_NUMBER(p_canonical_value       IN VARCHAR2)
      RETURN NUMBER
   IS
   BEGIN
      --Null canonical can be a null date
      IF p_canonical_value IS NULL THEN
         RETURN NULL;
      END IF;

      --let conversion errors come out as VALUE_ERROR exceptions
      RETURN FND_NUMBER.CANONICAL_TO_NUMBER(p_canonical_value);
   END;

   -- Public
   FUNCTION DATE_TO_CANONICAL(p_date            IN DATE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN FND_DATE.DATE_TO_CANONICAL(p_date);
   END;

   -- Public
   FUNCTION CANONICAL_TO_DATE(p_canonical_value IN VARCHAR2)
      RETURN DATE
   IS
   BEGIN
      --Null canonical can be a null date
      IF p_canonical_value IS NULL THEN
         RETURN NULL;
      END IF;

      --force conversion errors to come out as VALUE_ERROR exceptions
      RETURN FND_DATE.CANONICAL_TO_DATE(p_canonical_value);
   EXCEPTION
      WHEN DATE_VALUE_ERROR THEN
         RAISE VALUE_ERROR;
      WHEN OTHERS THEN
         RAISE;
   END;

   -- Public
   FUNCTION GET_TABLE_OWNER(p_table_name                IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_owner   VARCHAR2(30);
   BEGIN
      -- Currently throws a GSCC error, we don't use it yet anyway - missing owners are treated as non-recoverable errors.
/*
      SELECT owner
         INTO l_owner
         FROM dba_tables
         where table_name = UPPER(p_table_name);
      RETURN l_owner;
*/
      RETURN NULL;
   END;

   -- Public
   FUNCTION GET_TABLE_WEIGHT(p_table_owner      IN VARCHAR2,
                             p_table_name       IN VARCHAR2)
      RETURN NUMBER
   IS
      l_blocks          NUMBER;
   BEGIN
      SELECT blocks
         INTO l_blocks
         FROM dba_tables
         WHERE owner = p_table_owner
         AND table_name = p_table_name;

      RETURN l_blocks;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

END FND_OAM_DSCFG_UTILS_PKG;

/
