--------------------------------------------------------
--  DDL for Package Body POS_ORG_HASH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ORG_HASH_PKG" AS
/* $Header: POSORGHB.pls 115.1 2002/11/20 22:08:26 jazhang noship $ */

FUNCTION get_hashkey(p_org_id IN NUMBER) RETURN VARCHAR2
  IS
     PRAGMA autonomous_transaction;

     l_hashkey pos_org_hash.hashkey%TYPE;

     CURSOR l_org_id_cur IS
	SELECT 1
	  FROM hr_operating_units
	  WHERE organization_id = p_org_id;

     CURSOR l_hashkey_cur IS
     SELECT hashkey
       FROM pos_org_hash
       WHERE org_id = p_org_id;

     l_temp_number NUMBER;
BEGIN
   -- validate p_org_id
   OPEN l_org_id_cur;
   FETCH l_org_id_cur INTO l_temp_number;
   IF l_org_id_cur%notfound THEN
      CLOSE l_org_id_cur;
      raise_application_error(-20001, 'invalid operating unit id ' || p_org_id, TRUE);
   END IF;
   CLOSE l_org_id_cur;

   -- query from pos_org_hash table
   OPEN l_hashkey_cur;
   FETCH l_hashkey_cur INTO l_hashkey;
   IF l_hashkey_cur%notfound THEN
      -- create a new row when not found
      l_hashkey := icx_call.encrypt3(p_org_id);
      INSERT INTO pos_org_hash(org_id, hashkey) VALUES (p_org_id, l_hashkey);
      COMMIT;
   END IF;
   CLOSE l_hashkey_cur;

   RETURN l_hashkey;

END get_hashkey;

FUNCTION get_org_id_by_key(p_hashkey IN VARCHAR2) RETURN NUMBER
IS

l_org_id pos_org_hash.org_id%TYPE := NULL;

CURSOR l_org_id_cur IS
  SELECT org_id
  FROM   pos_org_hash
  WHERE  hashkey = p_hashkey;

BEGIN

  IF p_hashkey IS NULL THEN
    RAISE NO_DATA_FOUND;
  END IF;

  OPEN l_org_id_cur;
  FETCH l_org_id_cur INTO l_org_id;
  IF l_org_id_cur%NOTFOUND THEN
    CLOSE l_org_id_cur;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE l_org_id_cur;

  RETURN l_org_id;

END get_org_id_by_key;

END pos_org_hash_pkg;

/
