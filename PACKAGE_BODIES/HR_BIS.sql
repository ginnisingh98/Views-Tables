--------------------------------------------------------
--  DDL for Package Body HR_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BIS" AS
/* $Header: hr_bis.pkb 120.1 2005/08/11 10:09:42 cbridge noship $ */

  TYPE lookup_value_pair_rec IS RECORD(
    lookup_type                   fnd_lookup_values.lookup_type%TYPE,
    lookup_code                   fnd_lookup_values.lookup_code%TYPE,
    meaning                       fnd_lookup_values.meaning%TYPE);

  TYPE fnd_lookups_cache_tabtype IS table OF lookup_value_pair_rec
    INDEX BY BINARY_INTEGER;
  g_lookups_tab       fnd_lookups_cache_tabtype;
  -- define the client info
  g_client_info       VARCHAR2(64) := USERENV('CLIENT_INFO'); -- bug 1533907
  -- define the security group
  g_security_group_id fnd_lookup_values.security_group_id%TYPE;
  -- define a global meaning
  g_meaning           fnd_lookup_values.meaning%TYPE;
  -- define a holder for the hash number
  g_hash_number       BINARY_INTEGER;
  -- define the bis_decode_lookup cursors
  CURSOR g_csr_lookup_select_sg(
    c_lookup_type VARCHAR2,
    c_lookup_code VARCHAR2) IS
    SELECT   flv.meaning
    FROM     fnd_lookup_values flv
    WHERE    flv.lookup_code = c_lookup_code
    AND      flv.lookup_type = c_lookup_type
    AND      flv.language = USERENV('LANG')
    AND      flv.view_application_id = 3
    AND      flv.security_group_id =
               fnd_global.lookup_security_group(
                 flv.lookup_type,
                 flv.view_application_id);
  --
  CURSOR g_csr_lookup_default_sg(
    c_lookup_type VARCHAR2,
    c_lookup_code VARCHAR2) IS
    SELECT   flv.meaning
    FROM     fnd_lookup_values flv
    WHERE    flv.lookup_code = c_lookup_code
    AND      flv.lookup_type = c_lookup_type
    AND      flv.language = USERENV('LANG')
    AND      flv.view_application_id = 3
    AND      flv.security_group_id = 0;
    --
  --******************************************************************************
  --* Returns the meaning for a lookup code of a specified type.
  --******************************************************************************
  FUNCTION bis_decode_lookup(
    p_lookup_type VARCHAR2,
    p_lookup_code VARCHAR2)
    RETURN fnd_lookup_values.meaning%TYPE IS
  BEGIN
    -- Note the language, security group and legislation code cannot
    -- be changed within a Discoverer session
    -- check to ensure the lookup type/code combo is NOT NULL
    IF    p_lookup_type IS NULL
       OR p_lookup_code IS NULL THEN
      -- exit incomplete type/code combo
      RETURN (NULL);
    END IF;
    -- get the security group
    IF g_security_group_id IS NULL THEN
      -- the global security group has not been set
      IF    NVL(SUBSTRB(g_client_info, 55, 1), '0') = '0'
         OR NVL(SUBSTRB(g_client_info, 55, 1), '0') = ' ' THEN
        g_security_group_id  := 0;
      ELSE
        g_security_group_id  := TO_NUMBER(SUBSTRB(g_client_info, 55, 10));
      END IF;
    END IF;
    -- determine hash number for plsql table index.
    g_hash_number  :=
     DBMS_UTILITY.get_hash_value(
       p_lookup_code || ':' || p_lookup_type,
       1,
       1048576);                                                      -- (2^20)
    BEGIN
      -- check if we have a hash number generated that is for a different
      -- lookup_type and lookup_code combination
      -- very rare but possible from the hashing algorithm

      -- on the first call to this if statement for any given g_hash_number
      -- the if condition will raise a no_data_found before the else condition
      -- because the plsql will not contain any values at the start of the session
      IF     g_lookups_tab(g_hash_number).lookup_type = p_lookup_type
         AND g_lookups_tab(g_hash_number).lookup_code = p_lookup_code THEN

        -- cache hit
        -- return the value from the plsql table
        RETURN (g_lookups_tab(g_hash_number).meaning);
      ELSE /* bug 1548213 */
        -- cache miss
        RAISE NO_DATA_FOUND;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- cache miss, determine value, and place in cache for next retrieval
        IF g_security_group_id = 0 THEN
          -- use the default security group
          OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code);
          FETCH g_csr_lookup_default_sg INTO g_meaning;
          IF g_csr_lookup_default_sg%NOTFOUND THEN
            -- lookup type/code combo not found so return NULL
            CLOSE g_csr_lookup_default_sg;
            RETURN (NULL);
          END IF;
          CLOSE g_csr_lookup_default_sg;
        ELSE
          -- not using the default security group
          OPEN g_csr_lookup_select_sg(p_lookup_type, p_lookup_code);
          FETCH g_csr_lookup_select_sg INTO g_meaning;
          IF g_csr_lookup_select_sg%NOTFOUND THEN
            -- lookup type/code combo not found so check for default sec. group.
            CLOSE g_csr_lookup_select_sg;

            -- bug 2204602 start of changes. 30-JAN-2002
            -- use the default security group
            OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code);
            FETCH g_csr_lookup_default_sg INTO g_meaning;
            IF g_csr_lookup_default_sg%NOTFOUND THEN
              -- lookup type/code combo not found so return NULL
              CLOSE g_csr_lookup_default_sg;
              RETURN (NULL);
            END IF;
            CLOSE g_csr_lookup_default_sg;

            -- bug 2204602 end of changes. 30-JAN-2002

            --RETURN (NULL);
          END IF;
          CLOSE g_csr_lookup_select_sg;
        END IF;
        -- add to plsql table
        g_lookups_tab(g_hash_number).lookup_type   := p_lookup_type;
        g_lookups_tab(g_hash_number).lookup_code   := p_lookup_code;
        g_lookups_tab(g_hash_number).meaning       := g_meaning;

        RETURN (g_meaning);
    END;
  EXCEPTION
    -- unexpected error
    WHEN OTHERS THEN
      -- check to see if a cursor is open
      IF g_csr_lookup_default_sg%ISOPEN THEN
        CLOSE g_csr_lookup_default_sg;
      ELSIF g_csr_lookup_select_sg%ISOPEN THEN
        CLOSE g_csr_lookup_select_sg;
      END IF;
      RETURN (NULL);
  END bis_decode_lookup;

/******************************************************************************/
/* Returns business group id of the current security profile                  */
/******************************************************************************/
  FUNCTION get_sec_profile_bg_id
      RETURN   per_security_profiles.business_group_id%TYPE IS

  BEGIN

    RETURN hr_security.get_sec_profile_bg_id;

  END get_sec_profile_bg_id;

/*******************************************************************************/
/* Returns legislation code of the current secuirty profile                    */
/*******************************************************************************/
   FUNCTION get_legislation_code
   RETURN   VARCHAR2 IS
   --
   -- local parameters
   --
      l_legislation_code  VARCHAR2(150);
   --
   BEGIN
   --
   -- get the legislation code
   --
      SELECT org_info.org_information9 INTO l_legislation_code
      FROM   hr_organization_information    org_info
      WHERE  org_info.org_information_context = 'Business Group Information'
      AND    org_info.organization_id = hr_security.get_sec_profile_bg_id;
   --
      RETURN (l_legislation_code);
   --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      --
	RETURN (NULL);
   --
   END get_legislation_code;
--

/*******************************************************************************/
/* Returns a fnd lookup meaning, for a given fnd_language                      */
/*******************************************************************************/

  FUNCTION decode_lang_lookup(p_language    VARCHAR2,
                              p_lookup_type VARCHAR2,
                              p_lookup_code VARCHAR2)
    RETURN fnd_lookup_values.meaning%TYPE IS

    l_meaning   fnd_lookup_values.meaning%TYPE := TO_CHAR(NULL);

    -- define the bis_decode_lookup cursors
    CURSOR csr_lookup_select_sg(
                                c_language VARCHAR2,
                                c_lookup_type VARCHAR2,
                                c_lookup_code VARCHAR2) IS
    SELECT   flv.meaning
    FROM     fnd_lookup_values flv
    WHERE    flv.lookup_code = c_lookup_code
    AND      flv.lookup_type = c_lookup_type
    AND      flv.language = c_language
    AND      flv.view_application_id = 3
    AND      flv.security_group_id = 0;

  BEGIN

    IF (   p_language IS NULL
        OR p_lookup_type IS NULL
        OR p_lookup_code IS NULL ) THEN
            RETURN TO_CHAR(NULL);
    END IF;

    -- call existing function if language requested is same as
    -- the current session language
    IF ( p_language = USERENV('LANG') ) THEN
        RETURN hr_bis.bis_decode_lookup(p_lookup_type, p_lookup_code);
    END IF;


    OPEN csr_lookup_select_sg(p_language, p_lookup_type, p_lookup_code);
    FETCH csr_lookup_select_sg INTO l_meaning;
    IF csr_lookup_select_sg%NOTFOUND THEN
      -- lookup language/type/code combo not found so return NULL
      CLOSE csr_lookup_select_sg;
      RETURN (TO_CHAR(NULL));
    END IF;
    CLOSE csr_lookup_select_sg;

    RETURN l_meaning;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          RETURN TO_CHAR(NULL);

  END decode_lang_lookup;


END hr_bis;

/
