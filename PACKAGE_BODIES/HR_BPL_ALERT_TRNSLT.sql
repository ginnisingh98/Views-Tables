--------------------------------------------------------
--  DDL for Package Body HR_BPL_ALERT_TRNSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BPL_ALERT_TRNSLT" AS
/* $Header: perbatsl.pkb 115.3 2003/06/03 16:00:47 jrstewar noship $ */
--
--------------------------------------------------------------------------------
-- Variables and Cursors Required by the decode_lookup functions
--
--
  TYPE lookup_value_pair_rec IS RECORD(
    lookup_type                   fnd_lookup_values.lookup_type%TYPE,
    lookup_code                   fnd_lookup_values.lookup_code%TYPE,
    language                      fnd_lookup_values.language%TYPE,
    meaning                       fnd_lookup_values.meaning%TYPE);

  TYPE fnd_lookups_cache_tabtype IS table OF lookup_value_pair_rec
    INDEX BY BINARY_INTEGER;
  g_lookups_tab       fnd_lookups_cache_tabtype;
  -- define the security group
  g_security_group_id fnd_lookup_values.security_group_id%TYPE;
  -- define a global meaning
  g_meaning           fnd_lookup_values.meaning%TYPE;
  -- define a holder for the hash number
  g_language              fnd_lookup_values.language%TYPE;
  g_hash_number       BINARY_INTEGER;
  -- define the bis_decode_lookup cursors

  --
CURSOR g_csr_lookup_default_sg(c_lookup_type VARCHAR2
                              ,c_lookup_code VARCHAR2
                              ,c_language    VARCHAR2)
    IS
    SELECT   flv.meaning
    FROM     fnd_lookup_values flv
    WHERE    flv.lookup_code = c_lookup_code
    AND      flv.lookup_type = c_lookup_type
    AND      flv.language = c_language
    AND      flv.view_application_id = 3
    AND      flv.security_group_id = 0;

--
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
PROCEDURE Cache_organization_details(p_language        IN VARCHAR2
                                    ,p_organization_id IN NUMBER)
IS
  --
  CURSOR c_organization_details
      ( cp_organization_id NUMBER
      , cp_language        VARCHAR2 )
  IS
  SELECT org1.name
        ,org1.language
  FROM hr_all_organization_units_tl org1
  WHERE org1.organization_id = cp_organization_id
  AND   ((org1.language = cp_language) OR
         ((NOT EXISTS (SELECT 'x'
                       FROM hr_all_organization_units_tl org2
                       WHERE org1.organization_id = org2.organization_id
                       AND org2.language = cp_language)) AND
          (org1.language = org1.source_lang)));
  --
BEGIN
  --
  -- If we don't have an id then we can't get a location_code
  --
  IF p_organization_id IS NULL THEN
    --
    g_organization_name := 'unkown';
    g_organization_language := 'unknown';
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_organization_id = g_organization_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_organization_id := p_organization_id;
  g_organization_name    := 'unknown';
  g_organization_language := 'unknown';
  --
  OPEN c_organization_details(
        p_organization_id
      , p_language );
  --
  FETCH c_organization_details
  INTO  g_organization_name
       ,g_organization_language;
  --
  CLOSE c_organization_details;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_organization_details;
    --
    g_organization_name     := 'unknown';
    g_organization_language := 'unknown';
    --
    RETURN;
    --
  --
END Cache_organization_details;
-- -----------------------------------------------------------------------------
--
-- Get's an email address for a given person_id
--
PROCEDURE Cache_location_details(p_language IN VARCHAR2
                                ,p_location_id IN NUMBER)
IS
  --
  CURSOR c_location_details
      ( cp_location_id NUMBER
      , cp_language    VARCHAR2 )
  IS
  SELECT loc1.location_code
        ,loc1.language
  FROM hr_locations_all_tl loc1
  WHERE loc1.location_id = cp_location_id
  AND   ((loc1.language = cp_language) OR
         ((NOT EXISTS (SELECT 'x'
                       FROM hr_locations_all_tl loc2
                       WHERE loc1.location_id = loc2.location_id
                       AND language = cp_language)) AND
          (loc1.language = loc1.source_lang)));
  --
BEGIN
  --
  -- If we don't have an id then we can't get a location_code
  --
  IF p_location_id IS NULL THEN
    --
    g_location_code     := 'unknown';
    g_location_language := 'unknown';
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_location_id = g_location_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_location_id := p_location_id;
  g_location_code     := 'unknown';
  g_location_language := 'unknown';
  --
  OPEN c_location_details
      ( p_location_id
      , p_language );
  --
  FETCH c_location_details
  INTO  g_location_code
       ,g_location_language;
  --
  CLOSE c_location_details;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_location_details;
    --
    g_location_code     := 'unknown';
    g_location_language := 'unknown';
    --
    RETURN;
    --
  --
END Cache_location_details;
--
-- -----------------------------------------------------------------------------
--
-- This function caches job details
--
PROCEDURE Cache_job_details(p_job_id IN NUMBER)
IS
  --
  CURSOR c_job_details
       ( cp_job_id NUMBER )
  IS
  SELECT job.job_id
        ,job.name
  FROM per_jobs job
  WHERE job.job_id = cp_job_id;
  --
BEGIN
  --
  -- If we don't have an id then we can't get a job_name
  --

  IF p_job_id IS NULL THEN

    --
    g_job_id             := NULL;
    g_job_code           := NULL;
    g_job_name           := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  job_name use it.
  --

  IF p_job_id = g_job_id THEN
    --

    RETURN;
    --
  END IF;

  --
  g_job_id            := p_job_id;
  g_job_code          := ' ';
  g_job_name          := ' ';
  --
  OPEN c_job_details
      ( p_job_id );
  --
  FETCH c_job_details
  INTO  g_job_code
       ,g_job_name;
  --
  CLOSE c_job_details;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_job_details;
    --
    RETURN;
    --
  --
END Cache_job_details;
--
-- -----------------------------------------------------------------------------
--
-- This function caches position details
--
PROCEDURE Cache_position_details(p_position_id IN NUMBER)
IS
  --
  CURSOR c_position_details
      ( cp_position_id NUMBER )
  IS
  SELECT pos.position_id
        ,pos.name
  FROM per_positions pos
  WHERE pos.position_id = cp_position_id;
  --
BEGIN
  --
  -- If we don't have an id then we can't get a location_code
  --
  IF p_position_id IS NULL THEN
    --
    g_position_id            := NULL;
    g_position_code          := NULL;
    g_position_name          := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_position_id = g_position_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_position_id            := p_position_id;
  g_position_code          := ' ';
  g_position_name          := ' ';
  --
  OPEN c_position_details
      ( p_position_id );
  --
  FETCH c_position_details
  INTO  g_position_code
       ,g_position_name;
  --
  CLOSE c_position_details;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_position_details;
    --
    RETURN;
    --
  --
END Cache_position_details;
--
-- -----------------------------------------------------------------------------
--
-- This function caches grade details
--
PROCEDURE Cache_grade_details(p_grade_id IN NUMBER)
IS
  --
  CURSOR c_grade_details
      ( cp_grade_id NUMBER )
  IS
  SELECT grd.grade_id
        ,grd.name
  FROM per_grades   grd
  WHERE grd.grade_id = cp_grade_id;
  --
BEGIN
  --
  -- If we don't have an id then we can't get a location_code
  --
  IF p_grade_id IS NULL THEN
    --
    g_grade_id              := NULL;
    g_grade_code            := NULL;
    g_grade_name            := NULL;
    --
    RETURN;
    --
  END IF;
  --
  -- If we already have the  email address use it.
  --
  IF p_grade_id = g_grade_id THEN
    --
    RETURN;
    --
  END IF;
  --
  g_grade_id            := p_grade_id;
  g_grade_code          := ' ';
  g_grade_name          := ' ';
  --
  OPEN c_grade_details
      ( p_grade_id );
  --
  FETCH c_grade_details
  INTO  g_grade_code
       ,g_grade_name;
  --
  CLOSE c_grade_details;
  --
  RETURN;
  --
EXCEPTION
  WHEN OTHERS THEN
    --
    CLOSE c_grade_details;
    --
    RETURN;
    --
  --
END Cache_grade_details;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for a language and location_id
--
FUNCTION location(p_language IN VARCHAR2
                 ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(p_language
                        ,p_location_id);
  --
  RETURN g_location_code;
  --
END location;
--
--
-- -----------------------------------------------------------------------------
--
-- Get's an Organization Name for a language and organization_id
--
FUNCTION organization(p_language IN VARCHAR2
                     ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(p_language
                            ,p_organization_id);
  --
  RETURN g_location_code;
  --
END organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job_name for a job_id
--
FUNCTION job(p_job_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_job_details(p_job_id);
  --
  RETURN g_job_name;
  --
END job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position_name for a position_id
--
FUNCTION position(p_position_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_position_details(p_position_id);
  --
  RETURN g_position_name;
  --
END position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade_name for a grade_id
--
FUNCTION grade(p_grade_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_grade_details(p_grade_id);
  --
  RETURN g_grade_name;
  --
END grade;
--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given person_ids language.
--
--
FUNCTION psn_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_person_id IN NUMBER)
  RETURN fnd_lookup_values.meaning%TYPE IS

BEGIN
  -- check to ensure the lookup type/code combo is NOT NULL
  IF   p_lookup_type    IS NULL
    OR p_lookup_code    IS NULL
    OR p_person_id  IS NULL
    THEN
    -- exit incomplete type/code combo
      RETURN (NULL);
  END IF;
  -- determine hash number for plsql table index.
  g_hash_number  :=
    DBMS_UTILITY.get_hash_value(p_lookup_code || ':' || p_lookup_type || ':' || p_person_id
                               ,1
                               ,1048576);
  g_language := hr_bpl_alert_recipient.get_psn_lng(p_person_id);
                                                                                                                              -- (2^20)
  BEGIN
  -- check if we have a hash number generated that is for a different
  -- lookup_type and lookup_code combination
  -- very rare but possible from the hashing algorithm
  -- on the first call to this if statement for any given g_hash_number
  -- the if condition will raise a no_data_found before the else condition
  -- because the plsql will not contain any values at the start of the session
    IF    g_lookups_tab(g_hash_number).lookup_type = p_lookup_type
      AND g_lookups_tab(g_hash_number).lookup_code = p_lookup_code
      AND g_lookups_tab(g_hash_number).language    = g_language
      THEN
      -- cache hit
      -- return the value from the plsql table
        RETURN (g_lookups_tab(g_hash_number).meaning);
    ELSE
      -- cache miss
      RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
        THEN
        -- cache miss, determine value, and place in cache for next retrieval
        -- use the default security group
        OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code,g_language);
        FETCH g_csr_lookup_default_sg INTO g_meaning;
          IF g_csr_lookup_default_sg%NOTFOUND THEN
          -- lookup type/code combo not found so return NULL
            CLOSE g_csr_lookup_default_sg;
              RETURN (NULL);
          END IF;
        CLOSE g_csr_lookup_default_sg;
        -- add to plsql table
        g_lookups_tab(g_hash_number).lookup_type   := p_lookup_type;
        g_lookups_tab(g_hash_number).lookup_code   := p_lookup_code;
        g_lookups_tab(g_hash_number).language      := g_language;
        g_lookups_tab(g_hash_number).meaning       := g_meaning;

        RETURN (g_meaning);
    END;
  EXCEPTION
    -- unexpected error
    WHEN OTHERS THEN
      -- check to see if a cursor is open
      IF g_csr_lookup_default_sg%ISOPEN THEN
        CLOSE g_csr_lookup_default_sg;
      END IF;
      RETURN (NULL);
  END psn_lng_decode_lookup;

--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for a person and location_id
--
FUNCTION psn_lng_location(p_person_id   IN NUMBER
                         ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(hr_bpl_alert_recipient.Get_psn_lng(p_person_id)
                        ,p_location_id);
  --
  RETURN g_location_code;
  --
END psn_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name for a person and organization_id
--
FUNCTION psn_lng_organization(p_person_id   IN NUMBER
                             ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(hr_bpl_alert_recipient.Get_psn_lng(p_person_id)
                        ,p_organization_id);
  --
  RETURN g_organization_name;
  --
END psn_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the primary assignment supervisor of a person_id
-- for a given location_id
--
FUNCTION psn_sup_lng_location(p_person_id   IN NUMBER
                            ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(hr_bpl_alert_recipient.Get_psn_sup_psn_lng(
                                                          p_person_id)
                        ,p_location_id);

  --
  RETURN g_location_code;
  --
END psn_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name for the primary assignment supervisor of
-- a person_id for a given organization_id
--
FUNCTION psn_sup_lng_organization(p_person_id       IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(hr_bpl_alert_recipient.Get_psn_sup_psn_lng(
                                                          p_person_id)
                        ,p_organization_id);

  --
  RETURN g_organization_name;
  --
END psn_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job_name for a job_id
--
FUNCTION psn_lng_job(p_person_id   IN NUMBER
                    ,p_job_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_job_details(p_job_id);
  --
  RETURN g_job_name;
  --
END psn_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job_name for a job_id
--
FUNCTION psn_sup_lng_job(p_person_id   IN NUMBER
                        ,p_job_id      IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_job_details(p_job_id);
  --
  RETURN g_job_name;
  --
END psn_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position_name for a position_id
--
FUNCTION psn_lng_position(p_person_id   IN NUMBER
                         ,p_position_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_position_details(p_position_id);
  --
  RETURN g_position_name;
  --
END psn_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position_name for a position_id
--
FUNCTION psn_sup_lng_position(p_person_id   IN NUMBER
                             ,p_position_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_position_details(p_position_id);
  --
  RETURN g_position_name;
  --
END psn_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade_name for a grade_id
--
FUNCTION psn_lng_grade(p_person_id IN NUMBER
                      ,p_grade_id  IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_grade_details(p_grade_id);
  --
  RETURN g_grade_name;
  --
END psn_lng_grade;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade_name for a grade_id
--
FUNCTION psn_sup_lng_grade(p_person_id IN NUMBER
                          ,p_grade_id  IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_grade_details(p_grade_id);
  --
  RETURN g_grade_name;
  --
END psn_sup_lng_grade;
--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given assignment language.
--
--

FUNCTION asg_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_assignment_id IN NUMBER)
  RETURN fnd_lookup_values.meaning%TYPE IS

BEGIN
  -- check to ensure the lookup type/code combo is NOT NULL
  IF   p_lookup_type    IS NULL
    OR p_lookup_code    IS NULL
    OR p_assignment_id  IS NULL
    THEN
    -- exit incomplete type/code combo
      RETURN (NULL);
  END IF;
  -- determine hash number for plsql table index.
  g_hash_number  :=
    DBMS_UTILITY.get_hash_value(p_lookup_code || ':' || p_lookup_type || ':' || p_assignment_id
                               ,1
                               ,1048576);
  g_language := hr_bpl_alert_recipient.get_asg_psn_lng(p_assignment_id);
                                                                                                                              -- (2^20)
  BEGIN
  -- check if we have a hash number generated that is for a different
  -- lookup_type and lookup_code combination
  -- very rare but possible from the hashing algorithm
  -- on the first call to this if statement for any given g_hash_number
  -- the if condition will raise a no_data_found before the else condition
  -- because the plsql will not contain any values at the start of the session
    IF    g_lookups_tab(g_hash_number).lookup_type = p_lookup_type
      AND g_lookups_tab(g_hash_number).lookup_code = p_lookup_code
      AND g_lookups_tab(g_hash_number).language    = g_language
      THEN
      -- cache hit
      -- return the value from the plsql table
        RETURN (g_lookups_tab(g_hash_number).meaning);
    ELSE
      -- cache miss
      RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
        THEN
        -- cache miss, determine value, and place in cache for next retrieval
        -- use the default security group
        OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code,g_language);
        FETCH g_csr_lookup_default_sg INTO g_meaning;
          IF g_csr_lookup_default_sg%NOTFOUND THEN
          -- lookup type/code combo not found so return NULL
            CLOSE g_csr_lookup_default_sg;
              RETURN (NULL);
          END IF;
        CLOSE g_csr_lookup_default_sg;
        -- add to plsql table
        g_lookups_tab(g_hash_number).lookup_type   := p_lookup_type;
        g_lookups_tab(g_hash_number).lookup_code   := p_lookup_code;
        g_lookups_tab(g_hash_number).language      := g_language;
        g_lookups_tab(g_hash_number).meaning       := g_meaning;

        RETURN (g_meaning);
    END;
  EXCEPTION
    -- unexpected error
    WHEN OTHERS THEN
      -- check to see if a cursor is open
      IF g_csr_lookup_default_sg%ISOPEN THEN
        CLOSE g_csr_lookup_default_sg;
      END IF;
      RETURN (NULL);
  END asg_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for a given assignment_id and location_id
--
FUNCTION asg_lng_location(p_assignment_id   IN NUMBER
                         ,p_location_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(hr_bpl_alert_recipient.Get_asg_psn_lng(
                                                          p_assignment_id)
                        ,p_location_id);
  --
  RETURN g_location_code;
  --
END asg_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by for the assignment_id
-- and organization_id
--
FUNCTION asg_lng_organization(p_assignment_id   IN NUMBER
                             ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(hr_bpl_alert_recipient.Get_asg_psn_lng(
                                                     p_assignment_id)
                        ,p_organization_id);
  --
  RETURN g_organization_name;
  --
END asg_lng_organization;
--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given language for a assignment supervisor.
--
--

FUNCTION asg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_assignment_id IN NUMBER)
  RETURN fnd_lookup_values.meaning%TYPE IS

BEGIN
  -- check to ensure the lookup type/code combo is NOT NULL
  IF   p_lookup_type    IS NULL
    OR p_lookup_code    IS NULL
    OR p_assignment_id  IS NULL
    THEN
    -- exit incomplete type/code combo
      RETURN (NULL);
  END IF;
  -- determine hash number for plsql table index.
  g_hash_number  :=
    DBMS_UTILITY.get_hash_value(p_lookup_code || ':' || p_lookup_type || ':' || p_assignment_id
                               ,1
                               ,1048576);
  g_language := hr_bpl_alert_recipient.get_asg_sup_lng(p_assignment_id);
                                                                                                                               -- (2^20)
  BEGIN
  -- check if we have a hash number generated that is for a different
  -- lookup_type and lookup_code combination
  -- very rare but possible from the hashing algorithm
  -- on the first call to this if statement for any given g_hash_number
  -- the if condition will raise a no_data_found before the else condition
  -- because the plsql will not contain any values at the start of the session
    IF    g_lookups_tab(g_hash_number).lookup_type = p_lookup_type
      AND g_lookups_tab(g_hash_number).lookup_code = p_lookup_code
      AND g_lookups_tab(g_hash_number).language    = g_language
      THEN
      -- cache hit
      -- return the value from the plsql table
        RETURN (g_lookups_tab(g_hash_number).meaning);
    ELSE
      -- cache miss
      RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
        THEN
        -- cache miss, determine value, and place in cache for next retrieval
        -- use the default security group
        OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code,g_language);
        FETCH g_csr_lookup_default_sg INTO g_meaning;
          IF g_csr_lookup_default_sg%NOTFOUND THEN
          -- lookup type/code combo not found so return NULL
            CLOSE g_csr_lookup_default_sg;
              RETURN (NULL);
          END IF;
        CLOSE g_csr_lookup_default_sg;
        -- add to plsql table
        g_lookups_tab(g_hash_number).lookup_type   := p_lookup_type;
        g_lookups_tab(g_hash_number).lookup_code   := p_lookup_code;
        g_lookups_tab(g_hash_number).language      := g_language;
        g_lookups_tab(g_hash_number).meaning       := g_meaning;

        RETURN (g_meaning);
    END;
  EXCEPTION
    -- unexpected error
    WHEN OTHERS THEN
      -- check to see if a cursor is open
      IF g_csr_lookup_default_sg%ISOPEN THEN
        CLOSE g_csr_lookup_default_sg;
      END IF;
      RETURN (NULL);
  END asg_sup_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the assignment supervisor of an assignment_id
-- for a given location_id
--
FUNCTION asg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id     IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(hr_bpl_alert_recipient.Get_asg_sup_lng(
                                                          p_assignment_id)
                        ,p_location_id);

  --
  RETURN g_location_code;
  --
END asg_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by the assignment
-- supervisor for a given assignment_id and organization_id
--
FUNCTION asg_sup_lng_organization(p_assignment_id   IN NUMBER
                                 ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(hr_bpl_alert_recipient.Get_asg_sup_lng(
                                                      p_assignment_id)
                        ,p_organization_id);

  --
  RETURN g_organization_name;
  --
END asg_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job_name for a job_id
--
FUNCTION asg_sup_lng_job(p_assignment_id IN NUMBER
                        ,p_job_id        IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_job_details(p_job_id);
  --
  RETURN g_job_name;
  --
END asg_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position_name for a position_id
--
FUNCTION asg_sup_lng_position(p_assignment_id IN NUMBER
                             ,p_position_id   IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_position_details(p_position_id);
  --
  RETURN g_position_name;
  --
END asg_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade_name for a grade_id
--
FUNCTION asg_sup_lng_grade(p_assignment_id IN NUMBER
                          ,p_grade_id      IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_grade_details(p_grade_id);
  --
  RETURN g_grade_name;
  --
END asg_sup_lng_grade;

--
--------------------------------------------------------------------------------
-- Returns Lookup Meaning for a given language for a primary assignment
-- supervisor.
--
--

FUNCTION pasg_sup_lng_decode_lookup(p_lookup_type   IN VARCHAR2
                              ,p_lookup_code   IN VARCHAR2
                              ,p_assignment_id IN NUMBER)
  RETURN fnd_lookup_values.meaning%TYPE IS

BEGIN
  -- check to ensure the lookup type/code combo is NOT NULL
  IF   p_lookup_type    IS NULL
    OR p_lookup_code    IS NULL
    OR p_assignment_id  IS NULL
    THEN
    -- exit incomplete type/code combo
      RETURN (NULL);
  END IF;
  -- get the security group
  -- determine hash number for plsql table index.
  g_hash_number  :=
    DBMS_UTILITY.get_hash_value(p_lookup_code || ':' || p_lookup_type || ':' || p_assignment_id
                               ,1
                               ,1048576);
  g_language := hr_bpl_alert_recipient.get_pasg_sup_lng(p_assignment_id);
                                                                                                                            -- (2^20)
  BEGIN
  -- check if we have a hash number generated that is for a different
  -- lookup_type and lookup_code combination
  -- very rare but possible from the hashing algorithm
  -- on the first call to this if statement for any given g_hash_number
  -- the if condition will raise a no_data_found before the else condition
  -- because the plsql will not contain any values at the start of the session
    IF    g_lookups_tab(g_hash_number).lookup_type = p_lookup_type
      AND g_lookups_tab(g_hash_number).lookup_code = p_lookup_code
      AND g_lookups_tab(g_hash_number).language    = g_language
      THEN
      -- cache hit
      -- return the value from the plsql table
        RETURN (g_lookups_tab(g_hash_number).meaning);
    ELSE
      -- cache miss
      RAISE NO_DATA_FOUND;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND
        THEN
        -- cache miss, determine value, and place in cache for next retrieval
        -- use the default security group
        OPEN g_csr_lookup_default_sg(p_lookup_type, p_lookup_code,g_language);
        FETCH g_csr_lookup_default_sg INTO g_meaning;
          IF g_csr_lookup_default_sg%NOTFOUND THEN
          -- lookup type/code combo not found so return NULL
            CLOSE g_csr_lookup_default_sg;
              RETURN (NULL);
          END IF;
        CLOSE g_csr_lookup_default_sg;
        -- add to plsql table
        g_lookups_tab(g_hash_number).lookup_type   := p_lookup_type;
        g_lookups_tab(g_hash_number).lookup_code   := p_lookup_code;
        g_lookups_tab(g_hash_number).language      := g_language;
        g_lookups_tab(g_hash_number).meaning       := g_meaning;

        RETURN (g_meaning);
    END;
  EXCEPTION
    -- unexpected error
    WHEN OTHERS THEN
      -- check to see if a cursor is open
      IF g_csr_lookup_default_sg%ISOPEN THEN
        CLOSE g_csr_lookup_default_sg;
      END IF;
      RETURN (NULL);
  END pasg_sup_lng_decode_lookup;
--
-- -----------------------------------------------------------------------------
--
-- Get's a location_code for the primary assignment supervisor of an
-- assignment_id for a given location_id
--
FUNCTION pasg_sup_lng_location(p_assignment_id   IN NUMBER
                             ,p_location_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_location_details(hr_bpl_alert_recipient.Get_pasg_sup_lng(
                                                          p_assignment_id)
                        ,p_location_id);

  --
  RETURN g_location_code;
  --
END pasg_sup_lng_location;
--
-- -----------------------------------------------------------------------------
--
-- Get's a Organization Name in the language required by the primary assignment
-- supervisor for a given assignment_id and organization_id
--
FUNCTION pasg_sup_lng_organization(p_assignment_id   IN NUMBER
                                  ,p_organization_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_organization_details(hr_bpl_alert_recipient.Get_pasg_sup_lng(
                                                      p_assignment_id)
                        ,p_organization_id);

  --
  RETURN g_organization_name;
  --
END pasg_sup_lng_organization;
--
-- -----------------------------------------------------------------------------
--
-- Get's a job_name for a job_id
--
FUNCTION pasg_sup_lng_job(p_assignment_id IN NUMBER
                         ,p_job_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_job_details(p_job_id);
  --
  RETURN g_job_name;
  --
END pasg_sup_lng_job;
--
-- -----------------------------------------------------------------------------
--
-- Get's a position_name for a position_id
--
FUNCTION pasg_sup_lng_position(p_assignment_id IN NUMBER
                              ,p_position_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_position_details(p_position_id);
  --
  RETURN g_position_name;
  --
END pasg_sup_lng_position;
--
-- -----------------------------------------------------------------------------
--
-- Get's a grade_name for a grade_id
--
FUNCTION pasg_sup_lng_grade(p_assignment_id IN NUMBER
                           ,p_grade_id IN NUMBER)
          RETURN VARCHAR2 IS
  --
BEGIN
  --
  Cache_grade_details(p_grade_id);
  --
  RETURN g_grade_name;
  --
END pasg_sup_lng_grade;
--
END HR_BPL_ALERT_TRNSLT;

/
