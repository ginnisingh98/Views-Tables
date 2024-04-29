--------------------------------------------------------
--  DDL for Package Body BIS_DELEGATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DELEGATION_PUB" AS
/* $Header: BISPDLGB.pls 120.1 2006/08/08 07:48:29 nbarik noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.1=120.1):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDLGB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     This is the Delegation API Pkg. for PMV.                          |
REM |                                                                       |
REM | HISTORY                                                               |
REM | jrhyde   06/25/05    Created   Enh 4325431                            |
REM |                                                                       |
REM +=======================================================================+
*/
--
-- Constants for the FND_GRANTS when used for PMV delegation
g_c_program_name CONSTANT FND_GRANTS.program_name%TYPE := 'BIS_PMV_GRANTS';
-- Exceptions
g_e_INVALID_DATES             EXCEPTION;  -- either or both dates not
g_e_INVALID_DELEGATION_TYPE   EXCEPTION;  -- delegate type not defined
g_e_INVALID_FND_OBJECT        EXCEPTION;  -- object not defined
g_e_INVALID_INSTANCE          EXCEPTION;  -- instance is not valid for delegate
g_e_INVALID_GRANTEE           EXCEPTION;  -- grantee not valid
g_e_INVALID_MENU_NAME         EXCEPTION;  -- menu not valid
--
-- Global table of records to store details of each delegate type
-- Note: Need to Populate and stay resident in session memory
--
-- Define global record type
TYPE g_rec_delegate_type_t IS RECORD
  (parameter1                     fnd_grants.parameter1%TYPE -- delegate type
  ,grantee_type                   fnd_grants.grantee_type%TYPE
  ,instance_type                  fnd_grants.instance_type%TYPE
  ,object_id                      fnd_objects.object_id%TYPE --runtime TBD
  ,object_name                    fnd_objects.obj_name%TYPE -- grantee object
  ,object_database_object_name    fnd_objects.database_object_name%TYPE
  ,object_pk1_column_name         fnd_objects.pk1_column_name%TYPE --runtime TBD
  ,object_pk1_column_type         fnd_objects.pk1_column_type%TYPE --runtime TBD
  --unlikely to need but put in for completeness
  ,object_pk2_column_name         fnd_objects.pk2_column_name%TYPE --runtime TBD
  ,object_pk2_column_type         fnd_objects.pk2_column_type%TYPE --runtime TBD
  -- may want to derive and store the SQL to from:
  --   object name
  --   object_pkX_column_name
  --   object_pkX_column_type
  -- to validate the grantor
  -- will not implement for first version where only design for HRI_PER_USRDR
  -- will use hardcoded SQL
  --,object_sql_stmt --
  );
-- Define global table / collection of record
TYPE g_tbl_delegate_type_t
  IS TABLE OF g_rec_delegate_type_t
  INDEX BY fnd_grants.parameter1%TYPE; -- Index by delegate type indentifier
-- Define global table of records
g_tbl_delegate_type g_tbl_delegate_type_t;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--***************************PRIVATE FUNCTIIONS*******************************--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--                         output
--------------------------------------------------------------------------------
--
-- Simple central point to handle user output messages
  PROCEDURE output(text IN VARCHAR2)
   IS
  BEGIN
    NULL;
--    DBMS_OUTPUT.put_line(text);
  END;
--------------------------------------------------------------------------------
--                         dbg
--------------------------------------------------------------------------------
--
-- Simple central point to handle debug messages
  PROCEDURE dbg(text IN VARCHAR2)
   IS
  BEGIN
    NULL;
--	output(' DEBUG : '||text);
  END;
--
--------------------------------------------------------------------------------
--                         setup_globals
--------------------------------------------------------------------------------
  PROCEDURE setup_globals
   IS
    --
    l_delegate_type fnd_grants.parameter1%TYPE;
    --
    l_object_id                       fnd_objects.object_id%TYPE;
    l_object_database_object_name     fnd_objects.database_object_name%TYPE;
    l_object_pk1_column_name          fnd_objects.pk1_column_name%TYPE;
    l_object_pk1_column_type          fnd_objects.pk1_column_type%TYPE;
    l_object_pk2_column_name          fnd_objects.pk2_column_name%TYPE;
    l_object_pk2_column_type          fnd_objects.pk2_column_type%TYPE;
    --
    CURSOR csr_fnd_objects
             (cp_obj_name fnd_objects.obj_name%TYPE
             )
     IS
      SELECT o.object_id
           , o.database_object_name
           , o.pk1_column_name
           , o.pk1_column_type
           , o.pk2_column_name
           , o.pk2_column_type
        FROM fnd_objects o
       WHERE o.obj_name = cp_obj_name
    ;
    --
  BEGIN
    -- Setup Metatdata
    dbg('  Setup Globals---------------');
    -- Currently on HRI_PER_USRDR_H supported
    g_tbl_delegate_type('HRI_PER_USRDR_H').parameter1    := 'HRI_PER_USRDR_H';
    g_tbl_delegate_type('HRI_PER_USRDR_H').grantee_type  := 'USER';
    g_tbl_delegate_type('HRI_PER_USRDR_H').object_name   := 'HRI_PER';
    g_tbl_delegate_type('HRI_PER_USRDR_H').instance_type := 'INSTANCE';
    -- Designed to be extend to multiple types
    l_delegate_type := 'HRI_PER_USRDR_H';
    -- query object information
    BEGIN
      -- Ensure cursor is closed prior to opening
      IF csr_fnd_objects%ISOPEN THEN
         CLOSE csr_fnd_objects;
      END IF;
      --
      OPEN csr_fnd_objects(g_tbl_delegate_type('HRI_PER_USRDR_H').object_name);
      FETCH csr_fnd_objects INTO
         l_object_id
        ,l_object_database_object_name
        ,l_object_pk1_column_name
        ,l_object_pk1_column_type
        ,l_object_pk2_column_name
        ,l_object_pk2_column_type
      ;
      IF (csr_fnd_objects%FOUND) THEN
        g_tbl_delegate_type(l_delegate_type).object_id
          :=l_object_id;
        g_tbl_delegate_type(l_delegate_type).object_pk1_column_name
          :=l_object_pk1_column_name;
        g_tbl_delegate_type(l_delegate_type).object_pk1_column_type
          :=l_object_pk1_column_type;
        /* Not currently required
        g_tbl_delegate_type(l_delegate_type).object_pk2_column_name
          :=l_object_pk2_column_name;
        g_tbl_delegate_type(l_delegate_type).object_pk2_column_type
          :=l_object_pk2_column_type;
        */
        --
        dbg('  object_id                    :'
              ||g_tbl_delegate_type(l_delegate_type).object_id);
        dbg('  object_pk1_column_name       :'
              ||g_tbl_delegate_type(l_delegate_type).object_pk1_column_name);
        dbg('  object_pk1_column_type       :'
              ||g_tbl_delegate_type(l_delegate_type).object_pk1_column_type);
      ELSE
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE csr_fnd_objects;
    --
    EXCEPTION
      WHEN OTHERS THEN
        IF csr_fnd_objects%ISOPEN THEN
          CLOSE csr_fnd_objects;
        END IF;
        RAISE g_e_INVALID_FND_OBJECT;
    END;
    --
  END setup_globals;
--
--------------------------------------------------------------------------------
--                         DELEGATE_TYPE_IS_VALID
--------------------------------------------------------------------------------
  FUNCTION delegate_type_is_valid
    (  p_delegate_type                       IN VARCHAR2
    )
   RETURN BOOLEAN
   IS
    l_result BOOLEAN;
  BEGIN
    IF p_delegate_type = 'HRI_PER_USRDR_H' THEN
      l_result := TRUE;
    ELSE
      l_result := FALSE;
    END IF;
  RETURN l_result;
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
  END delegate_type_is_valid;
--
--------------------------------------------------------------------------------
--                         GRANTEE_IS_VALID
--------------------------------------------------------------------------------
  FUNCTION grantee_is_valid
    (  p_delegate_type                       IN VARCHAR2
      ,p_grantee_key                         IN VARCHAR2
      ,p_start_date                          IN DATE DEFAULT SYSDATE
      ,p_end_date                            IN DATE DEFAULT NULL
    )
   RETURN BOOLEAN
   IS
    -- varialbe to take teh grantee key if it needs to be converted to a NUMBER
    l_grantee_key_num NUMBER;
    -- buffer to get the output of the validation cursor
    l_crs_op_buf_char VARCHAR2(200);
    l_result BOOLEAN;
    CURSOR crs_grantee_test_person
       ( cp_person_id NUMBER
        ,cp_date DATE
       )
     IS
      SELECT VALUE
        FROM hri_cl_per_n_v
       WHERE ID = cp_person_id
         AND cp_date BETWEEN effective_start_date AND effective_end_date
    ;
  BEGIN
    dbg('  Grantee_is_valid------------');
    -- Default result to FALSE.
    l_result := FALSE;
    -- this section intended to be replaced by more generic validation
    -- mechansims based on information stored in the g_tbl_delegate_type
    IF p_delegate_type = 'HRI_PER_USRDR_H' THEN
      -- convert varchar2 to number => Person_id
      -- note if it doesn't convert exception will be thrown suggesting that
      -- a bad parameter has been passed
      l_grantee_key_num := TO_NUMBER(p_grantee_key);
      BEGIN
        -- Ensure cursor is closed prior to opening
        IF crs_grantee_test_person%ISOPEN THEN
          CLOSE crs_grantee_test_person;
        END IF;
        --
        OPEN crs_grantee_test_person(l_grantee_key_num,p_start_date);
        FETCH crs_grantee_test_person INTO l_crs_op_buf_char;
        IF crs_grantee_test_person%FOUND THEN
          dbg('  Person validated             :'||l_crs_op_buf_char);
          l_result := TRUE;
        ELSE
          dbg('  Person not validated');
          l_result := FALSE;
        END IF;
        CLOSE crs_grantee_test_person;
      EXCEPTION
        WHEN OTHERS THEN
        dbg('  Cursor exception');
         IF crs_grantee_test_person%ISOPEN THEN
          CLOSE crs_grantee_test_person;
         END IF;
      END;
      --
    ELSE
      --
      dbg('  Not a supported delegate type');
      l_result := FALSE;
    END IF;
    RETURN l_result;
  --
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
  END grantee_is_valid;
--
--------------------------------------------------------------------------------
--                         INSTANCE_IS_VALID
--------------------------------------------------------------------------------
-- Tests to determine if instance is valid based
  FUNCTION instance_is_valid
    (  p_delegate_type                       IN VARCHAR2
      ,p_instance_pk1_value                  IN VARCHAR2
      ,p_instance_pk2_value                  IN VARCHAR2 DEFAULT NULL
      ,p_start_date                          IN DATE DEFAULT sysdate
      ,p_end_date                            IN DATE DEFAULT NULL
    )
   RETURN BOOLEAN
   IS
    -- variable to take the instance keys if it needs to be converted to a NUMBER
    l_instance_pk1_num NUMBER;
    l_instance_pk2_num NUMBER;
    -- buffer to get the output of the validation cursor
    l_crs_op_buf_char VARCHAR2(200);
    -- local variable holding the ultimate result of the function
    l_result BOOLEAN;
    --
    CURSOR crs_instance_test_person
       ( cp_person_id NUMBER
        ,cp_date DATE
       )
     IS
      SELECT VALUE
        FROM hri_cl_per_n_v
       WHERE ID = cp_person_id
         AND cp_date BETWEEN effective_start_date AND effective_end_date
    ;
  BEGIN
    dbg('  Instance_is_valid------------');
    -- Default result to FALSE.
    l_result := FALSE;
    -- this section intended to be replaced by more generic validation
    -- mechansims based on information stored in the g_tbl_delegate_type
    IF p_delegate_type = 'HRI_PER_USRDR_H' THEN
      -- convert varchar2 to number => Person_id
      -- note if it doesn't convert exception will be thrown suggesting that
      -- a bad parameter has been passed
      -- Hence test has failed and FALSE returned
      l_instance_pk1_num := TO_NUMBER(p_instance_pk1_value);
      BEGIN
        -- Ensure cursor is closed prior to opening
        IF crs_instance_test_person%ISOPEN THEN
         CLOSE crs_instance_test_person;
        END IF;
        --
        OPEN crs_instance_test_person(l_instance_pk1_num,p_start_date);
        FETCH crs_instance_test_person INTO l_crs_op_buf_char;
        IF crs_instance_test_person%FOUND THEN
          dbg('  Person instance validated    :'||l_crs_op_buf_char);
          l_result := TRUE;
        ELSE
          dbg('  Person instance not validated');
          l_result := FALSE;
        END IF;
        CLOSE crs_instance_test_person;
      EXCEPTION
        WHEN OTHERS THEN
          dbg('  Cursor exception');
          IF crs_instance_test_person%ISOPEN THEN
            CLOSE crs_instance_test_person;
          END IF;
      END;
      --
    ELSE
      --
      dbg('  Not a supported delegate type');
      l_result := FALSE;
    END IF;
    RETURN l_result;
  EXCEPTION
    WHEN others THEN
      RETURN FALSE;
  END instance_is_valid;
--
--------------------------------------------------------------------------------
--                         GET_MENU_ID
--------------------------------------------------------------------------------
--
  FUNCTION get_menu_id
    (p_menu_name                   IN VARCHAR2
    )
   RETURN NUMBER
   IS
    --
    CURSOR csr_get_menu_id(cp_menu_name VARCHAR2)
     IS
      SELECT m.menu_id
        FROM fnd_menus m
       WHERE m.menu_name =cp_menu_name
    ;
    --
    l_menu_id NUMBER;
    --
  BEGIN
    --
    dbg('  Get_menu_id-----------------');
    -- Ensure cursor is closed prior to opening
    IF csr_get_menu_id%ISOPEN THEN
      CLOSE csr_get_menu_id;
    END IF;
    --
    OPEN csr_get_menu_id(p_menu_name);
    FETCH csr_get_menu_id INTO l_menu_id;
    IF (csr_get_menu_id%NOTFOUND) THEN
      CLOSE  csr_get_menu_id;
      dbg('  menu not found');
      RAISE NO_DATA_FOUND;
    ELSE
      dbg('  menu found');
    END IF;
    CLOSE  csr_get_menu_id;
    --
    RETURN l_menu_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF csr_get_menu_id%ISOPEN THEN
        CLOSE csr_get_menu_id;
      END IF;
      RAISE g_e_INVALID_MENU_NAME;
  END;
--------------------------------------------------------------------------------
--                         GRANT_EXISTS
--------------------------------------------------------------------------------
-- Tests to determine if grant exists
  FUNCTION grant_exists
    (  p_delegate_type                IN VARCHAR2
      ,p_grantee_key                  IN VARCHAR2
      ,p_instance_pk1_value           IN VARCHAR2
      ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
      ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
      ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
      ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
      ,p_start_date                   IN DATE DEFAULT sysdate
      ,p_end_date                     IN DATE DEFAULT NULL
      ,p_menu_id                      IN NUMBER
      ,x_grant_guid                   OUT NOCOPY RAW
    )
   RETURN BOOLEAN
   IS
    l_result BOOLEAN;
    --
    CURSOR csr_grant_exits
             (cp_grantee_type        IN VARCHAR2
             ,cp_grantee_key         IN VARCHAR2
             ,cp_menu_id             IN NUMBER
             ,cp_start_date          IN DATE DEFAULT SYSDATE
             ,cp_end_date            IN DATE DEFAULT NULL
             ,cp_object_id           IN NUMBER
             ,cp_instance_pk1_value  IN VARCHAR2
             ,cp_instance_pk2_value  IN VARCHAR2 DEFAULT NULL
             ,cp_parameter1          IN VARCHAR2
             )
     IS
      SELECT g.grant_guid
        FROM fnd_grants g
       WHERE g.grantee_type = cp_grantee_type
         AND g.grantee_key  = cp_grantee_key
         AND g.menu_id      = cp_menu_id
         AND (cp_end_date IS NULL
              OR g.start_date <= cp_end_date)
         AND (g.end_date IS NULL
              OR cp_start_date <= g.end_date)
         AND g.object_id = cp_object_id
         AND g.instance_pk1_value = cp_instance_pk1_value
         AND (   cp_instance_pk2_value IS NULL
              OR cp_instance_pk2_value = g.instance_pk2_value)
         AND g.parameter1   = cp_parameter1
         AND g.program_name = g_c_program_name
    ;
    l_grant_guid  fnd_grants.grant_guid%TYPE;
    --
  BEGIN
    --
    dbg('  Grant_Exists----------------');
    dbg('  grantee_type                 :'
                        ||g_tbl_delegate_type(p_delegate_type).grantee_type);
    dbg('  grantee_key                  :'||p_grantee_key);
    dbg('  menu_id                      :'||to_char(p_menu_id));
    dbg('  start_date                   :'||to_char(p_start_date));
    dbg('  end_date                     :'||TO_CHAR(p_end_date));
    dbg('  object_id                    :'
                        ||g_tbl_delegate_type(p_delegate_type).object_id);
    dbg('  instance_pk1_value           :'||p_instance_pk1_value);
    dbg('  instance_pk2_value           :'||p_instance_pk2_value);
    dbg('  parameter1                   :'
                        ||g_tbl_delegate_type(p_delegate_type).parameter1);
    dbg('  program_name                 :'||g_c_program_name);
    -- Check that the cursors is not already open
    IF csr_grant_exits%ISOPEN THEN
      CLOSE csr_grant_exits;
    END IF;
    --
    OPEN csr_grant_exits
             (cp_grantee_type
               =>g_tbl_delegate_type(p_delegate_type).grantee_type
             ,cp_grantee_key         => p_grantee_key
             ,cp_menu_id             => p_menu_id
             ,cp_start_date          => p_start_date
             ,cp_end_date            => p_end_date
             ,cp_object_id
               =>g_tbl_delegate_type(p_delegate_type).object_id
             ,cp_instance_pk1_value  => p_instance_pk1_value
             ,cp_instance_pk2_value  => p_instance_pk2_value
             ,cp_parameter1
               =>g_tbl_delegate_type(p_delegate_type).parameter1
             );
    FETCH csr_grant_exits INTO l_grant_guid;
    dbg('  grat_guid                    :'||TO_CHAR(l_grant_guid));
    IF (csr_grant_exits%NOTFOUND) THEN
      l_result := FALSE;
    ELSE
      x_grant_guid := l_grant_guid;
      l_result := TRUE;
    END IF;
    --
    CLOSE csr_grant_exits;
    --
    RETURN l_result;
    --
  EXCEPTION
    WHEN others THEN
      IF csr_grant_exits%ISOPEN THEN
        CLOSE csr_grant_exits;
      END IF;
      RETURN FALSE;
  END grant_exists;
--
--------------------------------------------------------------------------------
--                         UPDATE_DELEGATE_GRANTS
--------------------------------------------------------------------------------
-- Updates a number of grants for a delegate type and instance across:
--   grantees
--   menus
-- Decision to not make it across instance was for security and performance
-- No retrospective transactions, all transactions must be for either present
--  or future delegations.
-- 2 modes of operation - p_update_mode:
--    REVOKE - trims the grants down to the end_date if the records are larger
--    EXTEND - extends the grants up to the end_date if records are smaller
--------------------------------------------------------------------------------
  PROCEDURE update_delegation_grants
    ( p_delegate_type                IN VARCHAR2
     ,p_grantee_key                  IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk1_value           IN VARCHAR2
     ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
     ,p_start_date                   IN DATE DEFAULT SYSDATE
     ,p_end_date                     IN DATE DEFAULT SYSDATE
     ,p_menu_id                      IN NUMBER DEFAULT NULL
     ,x_success                      OUT NOCOPY VARCHAR /* Boolean */
     ,x_errorcode                    OUT NOCOPY VARCHAR2
     ,p_update_mode                  IN VARCHAR2 DEFAULT 'EXTEND'
    )
   IS
    --
    l_result BOOLEAN;
    -- buffer for FND API success code
    l_success VARCHAR(1);
    --
    l_cntr NUMBER := 0;
    --
    -- Cursor parameters
    l_cp_start_date  DATE;
    l_cp_end_date    DATE;
    -- Local to a record in the cursor loop
    l_start_date  DATE;
    l_end_date    DATE;
    -- Cursor to do a search of all existing delegations
    -- matching criteria
    -- Note: Order by required to order by date
    ---      to allow adjustments of concurrent periods
    CURSOR csr_grant
             (cp_grantee_type        IN VARCHAR2
             ,cp_grantee_key         IN VARCHAR2 DEFAULT NULL
             ,cp_menu_id             IN NUMBER DEFAULT NULL
             ,cp_start_date          IN DATE DEFAULT NULL
             ,cp_end_date            IN DATE DEFAULT NULL
             ,cp_object_id           IN NUMBER
             ,cp_instance_pk1_value  IN VARCHAR2
             ,cp_instance_pk2_value  IN VARCHAR2 DEFAULT NULL
             ,cp_parameter1          IN VARCHAR2
             )
     IS
      SELECT g.grant_guid grant_guid
           , g.START_DATE start_date
           , g.end_date   end_date
           , g.program_name
           , g.grantee_type
           , g.grantee_key
           , g.menu_id
           , g.object_id
           , g.instance_pk1_value
           , g.instance_pk2_value
           , g.parameter1
        FROM fnd_grants g
       WHERE g.grantee_type = cp_grantee_type
         AND (cp_grantee_key IS NULL
              OR g.grantee_key  = cp_grantee_key)
         AND g.menu_id      = cp_menu_id
         AND (cp_end_date IS NULL
              OR g.start_date <= cp_end_date)
         AND (g.end_date IS NULL
              OR cp_start_date <= g.end_date)
         AND g.object_id = cp_object_id
         AND g.instance_pk1_value = cp_instance_pk1_value
         AND (   cp_instance_pk2_value IS NULL
              OR cp_instance_pk2_value = g.instance_pk2_value)
         AND g.parameter1   = cp_parameter1
         AND g.program_name = g_c_program_name
      ORDER BY g.parameter1
              ,g.program_name
              ,g.menu_id
              ,g.grantee_key
              ,g.instance_pk1_value
              ,g.start_date
    ;
    --
    -- Previous record details
    c_rec_prev csr_grant%ROWTYPE;
    --
  BEGIN
    --
    x_success := FND_API.G_FALSE;
    x_errorcode:= NULL;  --meaning nothing done
    dbg('  Update_Delegate_Grants------');
    dbg('  p_mode_type                  :'||p_update_mode);
    dbg('  p_start_date                 :'||to_char(p_start_date));
    dbg('  p_end_date                   :'||TO_CHAR(p_end_date));
    -- Prepare cursor date parameters
    ---Start_date must be sysdate or greater
    --- Otherwise default to sysdate
    IF p_start_date >= TRUNC(SYSDATE) THEN
      l_cp_start_date   := p_start_date;
    ELSE
      l_cp_start_date   := TRUNC(SYSDATE);
    END IF;
    ---End_date must be NULL = meaning EOT
    --- OR sysdate or greater
    --- Otherwise default to sysdate
    IF (   p_end_date IS NULL
        OR p_end_date >= SYSDATE) THEN
      l_cp_end_date   := p_end_date;
    ELSE
      l_cp_end_date   := TRUNC(SYSDATE);
    END IF;
    -- End_date >= Start_date
    -- Leave to the FND_GRATS API to handle
    dbg('  Cursor Parameters ->');
    dbg('  grantee_type                 :'
                        ||g_tbl_delegate_type(p_delegate_type).grantee_type);
    dbg('  grantee_key                  :'||p_grantee_key);
    dbg('  menu_id                      :'||to_char(p_menu_id));
    dbg('  cp_start_date                :'||to_char(l_cp_start_date));
    dbg('  cp_end_date                  :'||TO_CHAR(l_cp_end_date));
    dbg('  object_id                    :'
                        ||g_tbl_delegate_type(p_delegate_type).object_id);
    dbg('  instance_pk1_value           :'||p_instance_pk1_value);
    dbg('  instance_pk2_value           :'||p_instance_pk2_value);
    dbg('  parameter1                   :'
                        ||g_tbl_delegate_type(p_delegate_type).parameter1);
    dbg('  program_name                 :'||g_c_program_name);
    --
    -- Loop through all the results returned by the cursor and update
    --  all records that are valid within the start_date and end_date window
    dbg('  Loop through records matching search criteria');
    -- Check that cursor is not already open
    IF csr_grant%ISOPEN THEN
      CLOSE csr_grant;
    END IF;
    --
    FOR c_rec IN csr_grant
                   (cp_grantee_type
                     =>g_tbl_delegate_type(p_delegate_type).grantee_type
                   ,cp_grantee_key         => p_grantee_key
                   ,cp_menu_id             => p_menu_id
                   ,cp_start_date          => l_cp_start_date
                   ,cp_end_date            => l_cp_end_date
                   ,cp_object_id
                     =>g_tbl_delegate_type(p_delegate_type).object_id
                   ,cp_instance_pk1_value  => p_instance_pk1_value
                   ,cp_instance_pk2_value  => p_instance_pk2_value
                   ,cp_parameter1
                     =>g_tbl_delegate_type(p_delegate_type).parameter1
                   )
    LOOP
      --
      dbg('    loop_number        :'||to_char(l_cntr+1));
      dbg('    record grant_guid  :'||to_char(c_rec.grant_guid));
      dbg('    record start_date  :'||to_char(c_rec.start_date));
      dbg('    record end_date    :'||TO_CHAR(c_rec.end_date));
      -- Update logic
      -- EXTEND mode
      -- If the existing record is a subset of the new period then extend
      -- REVOKE mode
      -- If the specified record is a subset of the new period then revoke
      --
      -- Extend tests:
      -- 1. Check to determine if this is not the second delegation record
      --    where all criteria match except for dates.  In this case need to
      --    merge records based on previously updated records
      -- 2. Extend End Date -> New End_date > Existing record End_date
      --     needs to account for NULL = End of Time
      -- 3. Bring forward start -> New Start_date < Existing record Start_date
      --     any tests for valid start date needs to have occured prior to this
      -- 4. Check for identical records
      --      do nothing but record as success to prevent new record
      -- 5. Check for records already extending beyond parameters of this update
      --      again do nothing but record as success to prevent new record
      IF (p_update_mode = 'EXTEND') THEN
        IF (    --1.
                 c_rec.program_name       = c_rec_prev.program_name
             AND c_rec.parameter1         = c_rec_prev.parameter1
             AND c_rec.object_id          = c_rec_prev.object_id
             AND c_rec.grantee_type       = c_rec_prev.grantee_type
             AND c_rec.grantee_key        = c_rec_prev.grantee_key
             AND c_rec.menu_id            = c_rec_prev.menu_id
             AND c_rec.instance_pk1_value = c_rec_prev.instance_pk1_value
             AND NVL(c_rec.instance_pk2_value,'X')
                 = NVL(c_rec_prev.instance_pk2_value,'X')
           )
        THEN
          -- At this point a record has already been extended
          -- and this record is duplicating a period of the grant
          -- hence need to determine 2 different cases
          --  A. current record is entirely overlapped by prev new record
          ---    in this case need to delete duplicate record
          --  B. current record partially overlapped by prev. record
          ---    in this case need to update the record
          --
          dbg('    Overlapping delegation grant found');
          dbg('    program_name       :'||c_rec.program_name);
          dbg('    parameter1         :'||c_rec.parameter1);
          dbg('    object_id          :'||c_rec.object_id);
          dbg('    grantee_type       :'||c_rec.grantee_type);
          dbg('    grantee_key        :'||c_rec.grantee_key);
          dbg('    instance_pk1_value :'||c_rec.instance_pk1_value);
          dbg('    instance_pk2_value :'||c_rec.instance_pk2_value);
          dbg('    menu_id            :'||to_char(c_rec.menu_id));
          dbg('    grant_guid         :'||to_char(c_rec.grant_guid));
          -- A.
          IF(  --A.
                l_cp_end_date IS NULL
                --Note if c_rec.end_date is NULL=>EOT then this will be false
             OR c_rec.end_date <= l_cp_end_date
            )
          THEN -- delete
            dbg('    deleting completely overlapped grant....');
            fnd_grants_pkg.revoke_grant
              (p_api_version    =>1.0 --IN  NUMBER,
              ,p_grant_guid     =>c_rec.grant_guid --IN  raw,
              ,x_success        =>x_success --OUT NOCOPY VARCHAR2,
              ,x_errorcode      =>x_errorcode --OUT NOCOPY NUMBER
              );
            dbg('    ....deleting grant complete');
            dbg('    API success result     :'||x_success);
            -- Add formated output comments
            IF x_success = FND_API.G_TRUE THEN
              dbg('Record Deleted');
              dbg(' -grant_guid        :'||to_char(c_rec.grant_guid));
            END IF;
          ELSE --B.
            -- c_rec.end_date > l_cp_end_date
            dbg('    updatting partially overlapped grant....');
            l_start_date := l_cp_end_date + 1;
            l_end_date := c_rec.end_date;
            dbg('    new start_date     :'||to_char(l_start_date));
            fnd_grants_pkg.update_grant
              (p_api_version => 1.0
              ,p_grant_guid  => c_rec.grant_guid
              ,p_start_date  => l_start_date
              ,p_end_date    => l_end_date
              ,p_name        => NULL
              ,p_description => 'BIS_DELEGATION API -> EXTEND'
              ,x_success     => l_success);
            dbg('    ...updatting grant completed');
            dbg('    API success result :'||x_success);
            -- Add formated output comments
            IF x_success = FND_API.G_TRUE THEN
              dbg('Record Updated');
              dbg(' -grant_guid        :'||to_char(c_rec.grant_guid));
            END IF;
          END IF;
          --
        ELSIF (    --2.
                   l_cp_end_date > c_rec.end_date
                OR (l_cp_end_date IS NULL AND c_rec.end_date IS NOT NULL)
                --3.
                OR l_cp_start_date < c_rec.START_DATE
              )
        THEN
          dbg('    updating grant....');
          --Note only moving start date back to earliest of sysdate
          l_start_date := LEAST(l_cp_start_date,c_rec.START_DATE);
          l_end_date := GREATEST(l_cp_end_date,c_rec.end_date);
          dbg('      new start date   :'||TO_CHAR(l_start_date));
          dbg('      new end date     :'||TO_CHAR(l_end_date));
          fnd_grants_pkg.update_grant
            (p_api_version => 1.0
            ,p_grant_guid  => c_rec.grant_guid
            ,p_start_date  => l_start_date
            ,p_end_date    => l_end_date
            ,p_name        => NULL
            ,p_description => 'BIS_DELEGATION API -> EXTEND'
            ,x_success     => l_success);
          dbg('    ....updating grant complete');
          dbg('    API success result :'||l_success);
          -- Add formated output comments
          IF x_success = FND_API.G_TRUE THEN
            dbg('Record Updated');
            dbg(' -grant_guid        :'||to_char(c_rec.grant_guid));
          END IF;
        ELSIF (   --4.
                  (    l_cp_end_date = c_rec.end_date
                   OR (l_cp_end_date IS NULL AND c_rec.end_date IS NULL) )
               AND l_cp_start_date = c_rec.START_DATE
              )
        THEN
          dbg('    Existing record found with same details as request');
          dbg('    -> No need for any record changes');
          x_success := FND_API.G_TRUE;
        ELSIF (   --5.
                  (    l_cp_end_date <= c_rec.end_date
                   OR (l_cp_end_date IS NULL AND c_rec.end_date IS NOT NULL) )
               AND l_cp_start_date >= c_rec.START_DATE
              )
        THEN
          dbg('    Existing record a super set of request');
          dbg('    -> No need for any record changes');
          x_success := FND_API.G_TRUE;
        END IF;
      --
      -- Revoke tests:
      -- 1. Existing record date range must be outside modified record dates
      -- 2. Check if record has already started -> Change end date
      --     Otherwise delete the dlegation
      ELSIF (p_update_mode = 'REVOKE'
              -- 1.
              AND(    (     c_rec.end_date IS NULL
                         OR l_cp_end_date < c_rec.end_date
                      )
                    OR l_cp_start_date > c_rec.START_DATE
                 )
            )
      THEN
        -- 2.
        IF c_rec.START_DATE <= TRUNC(SYSDATE) THEN
          -- If the grant has started then update the end date
          -- Note only changing the end date
          dbg('    revoking grant....');
          -- Calculate dates for new record
          --- Start Date is unchanged
          l_start_date := c_rec.START_DATE;
          --- End Date modified based on
          ---- 1. start_date=NULL then use SYSDATE-1 (BIS implementation)
          ---- 2. start of revoke window.
          IF p_start_date IS NULL THEN
            l_end_date := TRUNC(SYSDATE - 1);
          ELSE
            l_end_date := LEAST(l_cp_start_date
                               ,NVL(c_rec.end_date,l_cp_start_date)
                               );
          END IF;
          --
          dbg('      new end date     :'||TO_CHAR(l_end_date));
          fnd_grants_pkg.update_grant
            (p_api_version => 1.0
            ,p_grant_guid  => c_rec.grant_guid
            ,p_start_date  => l_start_date
            ,p_end_date    => l_end_date
            ,p_name        => NULL
            ,p_description => 'BIS_DELEGATION API -> REVOKE'
            ,x_success     => l_success);
          dbg('    ....revoking grant complete');
          dbg('      success result:'||l_success);
          -- Add formated output comments
          IF x_success = FND_API.G_TRUE THEN
            dbg('Record Updated');
            dbg(' -grant_guid        :'||to_char(c_rec.grant_guid));
          END IF;
        ELSE
          -- Else record has not come into usage as it's future
          -- so delete
          dbg('    deleting grant....');
          fnd_grants_pkg.revoke_grant
            (p_api_version    =>1.0 --IN  NUMBER,
            ,p_grant_guid     =>c_rec.grant_guid --IN  raw,
            ,x_success        =>x_success --OUT NOCOPY VARCHAR2, /* Boolean */
            ,x_errorcode      =>x_errorcode --OUT NOCOPY NUMBER
            );
          dbg('    ....deleting grant complete');
          dbg('      success result:'||x_success);
          -- Add formated output comments
          IF x_success = FND_API.G_TRUE THEN
            dbg('Record Deleted');
            dbg(' -grant_guid        :'||to_char(c_rec.grant_guid));
          END IF;
        END IF;
      ELSE
          -- Row not updated
          --  this is valid and does not require an exception at this point
          --  calling method to determine how to handle
        dbg('    Record found but does not required update or delete');
        x_success := FND_API.G_TRUE;
      END IF;
      -- increment loop counter
      l_cntr:=l_cntr+1;
      -- Update success output flag if a row updated/revoked successfully
      IF (   x_success = FND_API.G_TRUE
          OR l_success = FND_API.G_TRUE)
      THEN
        x_success := FND_API.G_TRUE;
      END IF;
      dbg(' x_success                     :'||x_success);
      --
      -- Take a copy of the current record
      c_rec_prev:=c_rec;
      END LOOP;
    dbg(' Update success result         :'||x_success);
  --
  -- Deliberately have not put exception here to ensure that un-forseen
  -- exceptions are propagated to calling method and out to calling code
  --
  END update_delegation_grants;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--***************************PUBLIC FUNCTIIONS********************************--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
--                         GRANT_DELEGATE_FUNCTION
--------------------------------------------------------------------------------
  PROCEDURE grant_delegation
    ( p_delegate_type                IN VARCHAR2
     ,p_grantee_key                  IN VARCHAR2
     ,p_instance_pk1_value           IN VARCHAR2
     ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
     ,p_start_date                   IN DATE DEFAULT NULL
     ,p_end_date                     IN DATE DEFAULT NULL
     ,p_menu_name                    IN VARCHAR2
     ,x_grant_guid                   OUT NOCOPY RAW /*fnd_grants pk*/
     ,x_success                      OUT NOCOPY VARCHAR /* Boolean */
     ,x_errorcode                    OUT NOCOPY VARCHAR2
    )
   IS
   -- Local variables
   -- fnd_grants PK used if need to do update instead of a new record
   l_grant_guid  fnd_grants.grant_guid%TYPE;
   -- local parameters for fnd_grants API
   l_start_date  DATE;
   l_end_date    DATE;
   l_menu_id     NUMBER; --menu_id for menu name
   --
  BEGIN
    --
    dbg('Grant_delegation--------------');
    dbg('  p_delegate_type              :'||p_delegate_type);
    dbg('  p_grantee_key                :'||p_grantee_key);
    dbg('  p_instance_pk1_value         :'||p_instance_pk1_value);
    dbg('  p_instance_pk2_value         :'||p_instance_pk2_value);
    dbg('  p_instance_pk3_value         :'||p_instance_pk3_value);
    dbg('  p_instance_pk4_value         :'||p_instance_pk4_value);
    dbg('  p_instance_pk5_value         :'||p_instance_pk5_value);
    dbg('  p_start_date                 :'||to_char(p_start_date));
    dbg('  p_end_date                   :'||to_char(p_end_date));
    dbg('  p_menu_name                  :'||p_menu_name);
    -- Initialize globals
    setup_globals;
    -- get menu_id for name passed in
    l_menu_id := get_menu_id(p_menu_name);
    dbg('  menu_id                      :'||TO_CHAR(l_menu_id));
    -- Validate parameters
    --Note do not need to validate role or menu as this is done by fnd API
    -- Step 1. validate date
    --- Ensure Start_date < End_date
    --- Ensure dates are not prior to sysdate (rewritting history)
    --- Truncating all dates
    --- Have to validate first as these dates used for other validation steps
    dbg('  Check Grant Dates-----------');
    IF TRUNC(p_start_date) > TRUNC(p_end_date) THEN
      --
      dbg('RAISE:g_e_INVALID_DATES');
      RAISE g_e_INVALID_DATES;
    ELSIF (   p_start_date IS NULL
        OR TRUNC(p_start_date) < TRUNC(SYSDATE))
    THEN
      l_start_date := TRUNC(SYSDATE);
    ELSE
      l_start_date := TRUNC(p_start_date);
    END IF;
    --
    IF (   p_end_date IS NULL
        OR TRUNC(p_end_date) >= TRUNC(SYSDATE))
    THEN
      l_end_date   := TRUNC(p_end_date);
    ELSE
      l_end_date   := TRUNC(SYSDATE);
    END IF;
    dbg('  l_start_date                 :'||to_char(l_start_date));
    dbg('  l_end_date                   :'||to_char(l_end_date));
    --
    -- Step 2. check that delegate type is supported
    --
    IF NOT delegate_type_is_valid(p_delegate_type) THEN
      dbg('RAISE:g_e_INVALID_DELEGATION_TYPE');
      RAISE g_e_INVALID_DELEGATION_TYPE;
    END IF;
    -- Step 2. check that grantee is a valid value for delegate type
    IF NOT grantee_is_valid
              (p_delegate_type
              ,p_grantee_key
              ,l_start_date
              ,l_end_date)
    THEN
      dbg('RAISE:g_e_INVALID_GRANTEE');
      RAISE g_e_INVALID_GRANTEE;
    END IF;
    --
    -- Step 3. check that instance parameters are valid
    --
    IF NOT instance_is_valid
              (p_delegate_type
              ,p_instance_pk1_value
              ,p_instance_pk2_value
              ,l_start_date
              ,l_end_date)
    THEN
      dbg('RAISE:g_e_INVALID_INSTANCE');
      RAISE g_e_INVALID_INSTANCE;
    END IF;
    --
    -- Step 4. Implement delegation
    --- First Check if an over lapping grant record exists by trying an update
    update_delegation_grants
      ( p_delegate_type                =>p_delegate_type--IN VARCHAR2
       ,p_grantee_key                  =>p_grantee_key--IN VARCHAR2 DEFAULT NULL
       ,p_instance_pk1_value           =>p_instance_pk1_value--IN VARCHAR2
       --,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
       ,p_start_date                   =>l_start_date--IN DATE DEFAULT SYSDATE
       ,p_end_date                     =>l_end_date--IN DATE DEFAULT SYSDATE
       ,p_menu_id                      =>l_menu_id--IN NUMBER DEFAULT NULL
       ,x_success                      =>x_success--OUT NOCOPY VARCHAR /* Boolean */
       ,x_errorcode                    =>x_errorcode--OUT NOCOPY NUMBER
       ,p_update_mode                  =>'EXTEND'--IN VARCHAR2 DEFAULT 'EXTEND'
      );
    ---- Second if the update failed then do an insert
    IF x_success = FND_API.G_FALSE THEN
      -- Note: grant function api does a number of parameter checks:
      --   menu
      --   object
      dbg('  no matching records found');
      dbg('  granting function.....');
      fnd_grants_pkg.grant_function
        (p_api_version         =>1.0 --IN  NUMBER,
        ,p_menu_name           =>p_menu_name--IN  VARCHAR2,
        ,p_object_name         --IN  VARCHAR2,
          =>g_tbl_delegate_type(p_delegate_type).object_name
        ,p_instance_type       --IN  VARCHAR2,
          =>g_tbl_delegate_type(p_delegate_type).instance_type
        --,p_instance_set_id     IN  NUMBER  DEFAULT NULL,
        ,p_instance_pk1_value  =>p_instance_pk1_value--IN  VARCHAR2 DEFAULT NULL,
        --,p_instance_pk2_value  IN  VARCHAR2 DEFAULT NULL,
        --,p_instance_pk3_value  IN  VARCHAR2 DEFAULT NULL,
        --,p_instance_pk4_value  IN  VARCHAR2 DEFAULT NULL,
        --,p_instance_pk5_value  --IN  VARCHAR2 DEFAULT NULL,
        ,p_grantee_type        --IN  VARCHAR2 DEFAULT 'USER',
           =>g_tbl_delegate_type(p_delegate_type).grantee_type
        ,p_grantee_key         =>p_grantee_key--IN  VARCHAR2,
        ,p_start_date          =>l_start_date--IN  DATE,
        ,p_end_date            =>l_end_date--IN  DATE,
        ,p_program_name        =>g_c_program_name--IN  VARCHAR2 DEFAULT NULL,
        --,p_program_tag    IN  VARCHAR2 DEFAULT NULL,
        ,x_grant_guid          =>x_grant_guid--OUT NOCOPY RAW,
        ,x_success             =>x_success--OUT NOCOPY VARCHAR, /* Boolean */
        ,x_errorcode           =>x_errorcode--OUT NOCOPY NUMBER,
        ,p_parameter1          --IN  VARCHAR2 DEFAULT NULL,
          =>g_tbl_delegate_type(p_delegate_type).parameter1
        --,p_parameter2     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter3     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter4     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter5     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter6     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter7     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter8     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter9     IN  VARCHAR2 DEFAULT NULL,
        --,p_parameter10    IN  VARCHAR2 DEFAULT NULL,
        --,p_ctx_secgrp_id    IN NUMBER default -1,
        --,p_ctx_resp_id      IN NUMBER default -1,
        --,p_ctx_resp_appl_id IN NUMBER default -1,
        --,p_ctx_org_id       IN NUMBER default -1,
        --,p_name             in VARCHAR2 default null,
        ,p_description      =>'BIS_DELEGATION API -> NEW'
           --in VARCHAR2 default null
      );
      dbg('  ....grant function complete');
      dbg('    success result:'||x_success);
      -- Add formated output comments
      IF x_success = FND_API.G_TRUE THEN
        dbg('Record Created');
        dbg(' -grant_guid        :'||to_char(x_grant_guid));
      END IF;
    END IF;
    --
  EXCEPTION
    WHEN g_e_INVALID_DATES THEN
      x_success :='F';
      x_errorcode := 'INVALID_DATES';
    WHEN g_e_INVALID_DELEGATION_TYPE THEN
      x_success :='F';
      x_errorcode := 'INVALID_DELEGATION_TYPE';
    WHEN g_e_INVALID_FND_OBJECT THEN
      x_success :='F';
      x_errorcode := 'INVALID_FND_OBJECT';
    WHEN g_e_INVALID_INSTANCE THEN
      x_success :='F';
      x_errorcode := 'INVALID_INSTANCE';
    WHEN g_e_INVALID_GRANTEE THEN
      x_success :='F';
      x_errorcode := 'INVALID_GRANTEE';
    WHEN g_e_INVALID_MENU_NAME THEN
      x_success :='F';
      x_errorcode := 'INVALID_MENU_NAME';
  END grant_delegation;
--
--------------------------------------------------------------------------------
--                         REVOKE_DELEGATE_FUNCTION
--------------------------------------------------------------------------------
  PROCEDURE revoke_delegation
    ( p_delegate_type                IN VARCHAR2
     ,p_grantee_key                  IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk1_value           IN VARCHAR2
     ,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
     ,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
     ,p_start_date                   IN DATE DEFAULT NULL
     ,p_end_date                     IN DATE DEFAULT NULL
     ,p_menu_name                    IN VARCHAR2 DEFAULT NULL
     ,x_success                      OUT NOCOPY VARCHAR /* Boolean */
     ,x_errorcode                    OUT NOCOPY VARCHAR2
    )
   IS
   --
   l_start_date  DATE;
   l_end_date    DATE;
   l_menu_id     NUMBER; --menu_id for menu name
  BEGIN
    --
    dbg('Revoke_delegaton----------------');
    dbg('  p_delegate_type              :'||p_delegate_type);
    dbg('  p_grantee_key                :'||p_grantee_key);
    dbg('  p_instance_pk1_value         :'||p_instance_pk1_value);
    dbg('  p_instance_pk2_value         :'||p_instance_pk2_value);
    dbg('  p_instance_pk3_value         :'||p_instance_pk3_value);
    dbg('  p_instance_pk4_value         :'||p_instance_pk4_value);
    dbg('  p_instance_pk5_value         :'||p_instance_pk5_value);
    dbg('  p_start_date                 :'||to_char(p_start_date));
    dbg('  p_end_date                   :'||to_char(p_end_date));
    dbg('  p_menu_name                  :'||p_menu_name);
    -- Initialize globals
    setup_globals;
    -- get menu_id for name passed in
    l_menu_id := get_menu_id(p_menu_name);
    dbg('  menu_id                      :'||TO_CHAR(l_menu_id));
    -- Validate parameters
    --Note do not need to validate role or menu as this is done by fnd API
    -- Step 1. check that delegate type is supported
    IF NOT delegate_type_is_valid(p_delegate_type)
      THEN
        dbg('RAISE:g_e_INVALID_DELEGATE_TYPE');
        RAISE g_e_INVALID_DELEGATION_TYPE;
    END IF;
    -- Step 2. validate dates
    --- Rules:
    --- a. Truncate dates
    --- b. Start Date must be < End Date otherwise raise error
    --- c. Start Date and hence End Date must be >= TRUNC(sysdate)
    ---    otherwise raise error
    --- NOTE
    --- - Start Date can be NULL to mean revoke "as of now" evaluated
    ---    as SYSDATE in validations
    --- - End Date can be NULL to mean revoke everything from start date to
    ---    "end of time", evaluated in validations as "End of Time"
    --
    -- a.
    dbg('  Check Revoke Dates----------');
    l_start_date := TRUNC(p_start_date);
    l_end_date := TRUNC(p_end_date);
    -- b. & c.
    IF (    -- b.
            (   l_end_date IS NULL
             OR NVL(l_start_date,TRUNC(SYSDATE)) < l_end_date )
            -- c.
        AND (   l_start_date IS NULL
             OR l_start_date >= TRUNC(SYSDATE) )
       )
    THEN
      dbg('  Dates are valid');
      dbg('  l_start_date                 :'||TO_CHAR(l_start_date));
      dbg('  l_end_date                   :'||TO_CHAR(l_end_date));
    ELSE
      --
      dbg('RAISE:g_e_INVALID_DATES');
      RAISE g_e_INVALID_DATES;
    END IF;
    --
    -- Step 3. check that either:
    --  1. instance ids are NULL - defaulted
    --  2. instance parameters are valid
    IF (    --1.
            p_instance_pk1_value IS NULL
            --2.
         OR(instance_is_valid
                    (p_delegate_type
                    ,p_instance_pk1_value
                    ,p_instance_pk2_value
                    ,TRUNC(SYSDATE)
                    ,p_end_date)
           )
       )
    THEN
      dbg('  Instance keys are valid');
    ELSE
      dbg('RAISE:g_e_INVALID_INSTANCE');
      RAISE g_e_INVALID_INSTANCE;
    END IF;
    -- Step 5. update records in revoke mode
    update_delegation_grants
      ( p_delegate_type                =>p_delegate_type--IN VARCHAR2
       ,p_grantee_key                  =>p_grantee_key--IN VARCHAR2 DEFAULT NULL
       ,p_instance_pk1_value           =>p_instance_pk1_value--IN VARCHAR2
       --,p_instance_pk2_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk3_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk4_value           IN VARCHAR2 DEFAULT NULL
       --,p_instance_pk5_value           IN VARCHAR2 DEFAULT NULL
       ,p_start_date                   =>l_start_date--IN DATE DEFAULT SYSDATE
       ,p_end_date                     =>l_end_date--IN DATE DEFAULT SYSDATE
       ,p_menu_id                      =>l_menu_id--IN NUMBER DEFAULT NULL
       ,x_success                      =>x_success--OUT NOCOPY VARCHAR /* Boolean */
       ,x_errorcode                    =>x_errorcode--OUT NOCOPY NUMBER
       ,p_update_mode                  =>'REVOKE'--IN VARCHAR2 DEFAULT 'EXTEND'
      );
  EXCEPTION
    WHEN g_e_INVALID_DATES THEN
      x_success :='F';
      x_errorcode := 'INVALID_DATES';
    WHEN g_e_INVALID_DELEGATION_TYPE THEN
      x_success   := 'F';
      x_errorcode := 'INVALID_DELEGATION_TYPE';
    WHEN g_e_INVALID_FND_OBJECT THEN
      x_success   := 'F';
      x_errorcode := 'INVALID_FND_OBJECT';
    WHEN g_e_INVALID_INSTANCE THEN
      x_success   := 'F';
      x_errorcode := 'INVALID_INSTANCE';
    WHEN g_e_INVALID_GRANTEE THEN
      x_success   := 'F';
      x_errorcode := 'INVALID_GRANTEE';
    WHEN g_e_INVALID_MENU_NAME THEN
      x_success   := 'F';
      x_errorcode := 'INVALID_MENU_NAME';
  END revoke_delegation;
--
END BIS_DELEGATION_PUB;

/
