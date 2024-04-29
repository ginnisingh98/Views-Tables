--------------------------------------------------------
--  DDL for Package Body EDW_TRUNCATE_MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_TRUNCATE_MD" AS
/* $Header: EDWUPMDB.pls 115.3 2002/12/06 22:33:32 sbuenits noship $  */
   version   CONSTANT VARCHAR (80)
            := '$Header: EDWUPMDB.pls 115.3 2002/12/06 22:33:32 sbuenits noship $';
   g_flag             BOOLEAN      := TRUE;

   FUNCTION get_syn_info (syn_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR c_get_tbl_owner (syn_name IN VARCHAR2)
      IS
         SELECT table_owner
           FROM user_synonyms
          WHERE synonym_name = syn_name;

      l_tbl_owner   c_get_tbl_owner%ROWTYPE;
   BEGIN
      OPEN c_get_tbl_owner (syn_name);
      FETCH c_get_tbl_owner INTO l_tbl_owner;

      IF c_get_tbl_owner%NOTFOUND
      THEN
         RAISE g_getsyn;
      END IF;

      CLOSE c_get_tbl_owner;
      RETURN l_tbl_owner.table_owner;
   END get_syn_info;

   PROCEDURE clean_up (tbl_name IN VARCHAR2)
   IS
      l_str   VARCHAR2 (200);
   BEGIN
      l_str :=    'truncate table '
               || get_syn_info (tbl_name)
               || '.'
               || tbl_name;

      IF g_flag
      THEN
         EXECUTE IMMEDIATE l_str;
      g_flag := FALSE;
      END IF;
   END clean_up;
END edw_truncate_md;


/
