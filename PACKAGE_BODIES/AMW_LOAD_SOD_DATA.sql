--------------------------------------------------------
--  DDL for Package Body AMW_LOAD_SOD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_LOAD_SOD_DATA" AS
/* $Header: amwsodwb.pls 120.2.12000000.3 2007/06/14 06:59:33 ptulasi ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMW_LOAD_SOD_DATA';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amwsodwb.pls';

G_USER_ID NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
v_error_msg VARCHAR2(2000);
v_err_msg VARCHAR2(2000);
v_error_found boolean;

AMW_DEBUG_HIGH_ON boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMW_DEBUG_LOW_ON boolean    := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMW_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


/* To insert data */
PROCEDURE insert_data(
      errbuf       OUT NOCOPY      VARCHAR2
     ,retcode      OUT NOCOPY      VARCHAR2
     ,p_batch_id   IN              NUMBER
   )
IS
  CURSOR c_constraint_data IS
    SELECT cst_interface_id,
           cst_name,
           risk_name,
           cst_start_date,
           cst_type_code,
           cst_entries_function_id,
           cst_entries_resp_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id;


  -- Invalid Function
  CURSOR invalid_func IS
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND cst_type_code in ('ALL','ME','SET')
    AND cst_violat_obj_type = 'FUNC'
    AND cst_entries_function_id IS NOT NULL
    AND NOT EXISTS
    (   SELECT 'Y'
        FROM  fnd_form_functions
        WHERE function_id = cst_entries_function_id
    )
    UNION
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND cst_type_code in ('ALL','ME','SET')
    AND cst_violat_obj_type = 'CP'
    AND cst_entries_function_id IS NOT NULL
    AND NOT EXISTS
    (
        SELECT 'Y'
        FROM fnd_request_group_units rgu ,
             fnd_concurrent_programs cpv
        WHERE rgu.request_unit_type = 'P'
        AND rgu.request_unit_id = cpv.concurrent_program_id
        AND cpv.enabled_flag = 'Y'
        AND cpv.concurrent_program_id =cst_entries_function_id
    );


  -- Invalid Responsibility
  CURSOR invalid_resp IS
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND  cst_entries_resp_id IS NOT NULL
    AND NOT EXISTS
    (   SELECT 'Y'
        FROM FND_RESPONSIBILITY
        WHERE responsibility_id = cst_entries_resp_id
        AND start_date <= sysdate
        AND (end_date >= sysdate OR end_date IS NULL)
    );

  -- Invalid Type Code
  CURSOR invalid_type_code IS
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND NOT EXISTS
    (   SELECT 'Y'
        FROM amw_lookups
        WHERE lookup_code = cst_type_code
        AND lookup_type='AMW_CONSTRAINT_TYPE'
        AND enabled_flag ='Y'
        AND (end_date_active > SYSDATE OR end_date_active IS NULL)
    );

  -- Object type is responsibility. Responsibility should be entered
  -- and function should not be entered
  CURSOR invalid_resptype IS
    SELECT cst_interface_id,
           cst_entries_resp_id,
           cst_entries_function_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND (substr(cst_type_code,1,4) = 'RESP')
    AND (cst_entries_resp_id IS NULL OR cst_entries_function_id IS NOT NULL);

  -- Object type is function. Function should be entered
  -- Responsibility should not be entered
  CURSOR invalid_functype IS
    SELECT cst_interface_id,
           cst_entries_resp_id,
           cst_entries_function_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND cst_type_code IN ('ALL','ME','SET')
    AND (cst_entries_function_id IS NULL OR cst_entries_resp_id IS NOT NULL);

  -- CST_VIOLAT_OBJ_TYPE cannot be null for Function Type constraint
  CURSOR invalid_obj_type IS
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND cst_type_code in ('ALL','ME','SET')
    AND cst_entries_function_id IS NOT NULL
    AND (cst_violat_obj_type IS NULL OR cst_violat_obj_type NOT IN ('FUNC','CP') );


  -- CST_ENTRIES_GROUP_CODE cannot be null for Incompatible sets Type constraint
  CURSOR invalid_group_code IS
    SELECT cst_interface_id
    FROM amw_constraint_interface
    WHERE batch_id = p_batch_id
    AND cst_type_code in ('SET','RESPSET')
    AND (cst_entries_group_code IS NULL OR cst_entries_group_code NOT IN ('1','2'));

  v_name_exists number;
  v_risk_exists number;
  v_function_exists number;
  v_resp_exists number;
  v_type_exists number;
  v_interface_status   amw_constraint_interface.interface_status%TYPE;
  BEGIN
    begin

    for cstfunc_rec in invalid_func LOOP
        v_error_msg := 'Not a valid Incompatible Function';
        update_interface_with_error(v_error_msg,cstfunc_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || cstfunc_rec.cst_interface_id );
    end loop;

    for cstresp_rec in invalid_resp LOOP
        v_error_msg := 'Not a valid Incompatible Responsibility';
        update_interface_with_error(v_error_msg,cstresp_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || cstresp_rec.cst_interface_id );
    end loop;

    for typecode_rec in invalid_type_code LOOP
        v_error_msg := 'Not a valid Constraint Type Code';
        update_interface_with_error(v_error_msg,typecode_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || typecode_rec.cst_interface_id );
    end loop;

    for cstresptype_rec in invalid_resptype LOOP
        if cstresptype_rec.cst_entries_resp_id is null then
                v_error_msg := 'Object type is for Responsibility. But responsibility is not defined';
        else if cstresptype_rec.cst_entries_function_id is not null then
                v_error_msg := 'Object type is for Responsibility. But function is defined';
             end if;
        end if;
         update_interface_with_error(v_error_msg,cstresptype_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || cstresptype_rec.cst_interface_id );
    end loop;

    for cstfunctype_rec in invalid_functype LOOP
        if cstfunctype_rec.cst_entries_function_id is null then
                v_error_msg := 'Object type is for Function. But function is not defined';
        else if cstfunctype_rec.cst_entries_resp_id is not null then
                v_error_msg := 'Object type is for Function. But responsibility is defined';
             end if;
        end if;
         update_interface_with_error(v_error_msg,cstfunctype_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || cstfunctype_rec.cst_interface_id );
    end loop;

    for objtype_rec in invalid_obj_type LOOP
        v_error_msg := 'Not a valid Constraint Object Type';
        update_interface_with_error(v_error_msg,objtype_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || objtype_rec.cst_interface_id );
    end loop;

    for grpcode_rec in invalid_group_code LOOP
        v_error_msg := 'Not a valid Constraint Function Set';
        update_interface_with_error(v_error_msg,grpcode_rec.cst_interface_id);
        fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || grpcode_rec.cst_interface_id );
    end loop;

  IF (v_error_msg is NULL OR v_error_msg = NULL) THEN
  AMW_LOAD_CONSTRAINT_DATA.create_constraints
  ( errbuf => v_error_msg,
    retcode => v_err_msg,
    p_batch_id => p_batch_id,
    p_user_id => g_user_id);
  ELSE
    errbuf := v_error_msg;
    retcode := v_err_msg;
  END IF;

  fnd_file.put_line (fnd_file.LOG, 'After Calling the webadi procedure');
  EXCEPTION
  WHEN OTHERS
  THEN
        v_err_msg := 'Error during package processing  '
                  || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
  END;

END insert_data;
--
-- procedure update_interface_with_error
--
--
PROCEDURE update_interface_with_error (
    p_err_msg        IN   VARCHAR2
    ,p_interface_id   IN   NUMBER
)
IS
  l_interface_status   amw_constraint_interface.interface_status%TYPE;
  BEGIN
  ROLLBACK; -- rollback any inserts done during the current loop process
  v_error_found := TRUE;

    BEGIN
      SELECT interface_status INTO l_interface_status FROM amw_constraint_interface
      WHERE cst_interface_id = p_interface_id;
      if l_interface_status is not null then
        l_interface_status := l_interface_status || ' ; ';
      end if;
      l_interface_status := l_interface_status || p_err_msg || ' ';
      UPDATE amw_constraint_interface SET interface_status = l_interface_status
        ,error_flag = 'Y'
        WHERE cst_interface_id = p_interface_id;
      COMMIT;
    EXCEPTION
      WHEN OTHERS
       THEN
         v_err_msg := 'Error during package processing  ' || ' interface_id: = '
                || p_interface_id  || SUBSTR (SQLERRM, 1, 100);
         fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
      END;


   END update_interface_with_error;

-- ===============================================================
-- Procedure name
--          create_constraint_waivers
-- Purpose
-- 		  	import constraint waivers
--          from interface table to AMW_CONSTRAINT_WAIVERS_B and
--          AMW_CONSTRAINT_WAIVERS_TL
-- Notes
--          this procedure is called in Concurrent Executable
-- ===============================================================
PROCEDURE create_constraint_waivers (
    ERRBUF             OUT NOCOPY VARCHAR2,
    RETCODE            OUT NOCOPY VARCHAR2,
    p_batch_id         IN  NUMBER := NULL,
    p_del_after_import IN  VARCHAR2 := 'Y'
)
IS
  L_API_NAME           CONSTANT VARCHAR2(30) := 'create_constraint_waivers';
  L_API_VERSION_NUMBER CONSTANT NUMBER		 := 1.0;

  TYPE waiverCurTyp IS REF CURSOR;
  l_waiver_c waiverCurTyp;

  -- Cursor to check if the constraint for which the waiver is specified is
  -- valid
  CURSOR c_invld_cst_name_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   batch_id = p_batch_id
    AND     constraint_rev_id IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invld_cst_name IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   constraint_rev_id IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  -- Cursor to check if the responsibility constraint has responsibility waivers
  CURSOR c_invalid_resp_cst_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   type_code in ('RESPALL','RESPME','RESPSET')
    AND     object_type = 'RESP'
    AND     batch_id = p_batch_id
    AND     pk1 IS NOT NULL
    AND     pk2 IS NOT NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_resp_cst IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   type_code in ('RESPALL','RESPME','RESPSET')
    AND     object_type = 'RESP'
    AND     pk1 IS NOT NULL
    AND     pk2 IS NOT NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  -- Cursor to check if a user waiver is defined without specifing a valid user
  CURSOR c_invalid_user_waiver_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   object_type = 'USER'
    AND     batch_id = p_batch_id
    AND     pk1 IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_user_waiver IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   object_type = 'USER'
    AND     pk1 IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');


  -- Cursor to check if a responsibility waiver is defined without specifing a
  -- valid responsibility
  CURSOR c_invalid_resp_waiver_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   object_type = 'RESP'
    AND     batch_id = p_batch_id
    AND     pk1 IS NULL
    AND     pk2 IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_resp_waiver IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   object_type = 'RESP'
    AND     pk1 IS NULL
    AND     pk2 IS NULL
    AND     (process_flag IS NULL OR process_flag = 'N');


  -- Cursor to check if a start_date is valid. The start date should be greater
  -- or equal to sysdate
  CURSOR c_invalid_start_date_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   TRUNC(start_date)<TRUNC(sysdate)
    AND     batch_id = p_batch_id
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_start_date IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   TRUNC(start_date)<TRUNC(sysdate)
    AND     (process_flag IS NULL OR process_flag = 'N');

  -- ptulasi : 06/01/2007 : Bug 6067714:
  -- Cursor to check if a start_date is valid. The start date should be greater
  -- or equal to the sysdate. If the waiver start date is past to the sysdate, then
  -- the waiver start date should be set to constraint start date if the constraint
  -- start date is in future or else it is set to the sysdate.
  CURSOR c_invalid_st_date_batch IS
    SELECT  interface_id, decode(sign(sysdate-acv.start_date),1,sysdate,acv.start_date) start_date
    FROM    amw_constraints_vl acv, amw_cst_waiver_interface acwi
    WHERE   acwi.constraint_name = acv.constraint_name
    AND     acwi.constraint_name IS NOT NULL
    AND     acv.start_date IS NOT NULL
    AND     TRUNC(acwi.start_date)<TRUNC(acv.start_date)
    AND     batch_id = p_batch_id
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_st_date IS
    SELECT  interface_id, decode(sign(sysdate-acv.start_date),1,sysdate,acv.start_date) start_date
    FROM    amw_constraints_vl acv, amw_cst_waiver_interface acwi
    WHERE   acwi.constraint_name = acv.constraint_name
    AND     acwi.constraint_name IS NOT NULL
    AND     acv.start_date IS NOT NULL
    AND     TRUNC(acwi.start_date)<TRUNC(acv.start_date)
    AND     (process_flag IS NULL OR process_flag = 'N');

  -- Cursor to check if a end_date is valid. The end date should be not be less
  -- than sysdate
  CURSOR c_invalid_end_date_batch IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   ( TRUNC(end_date)< TRUNC(start_date)
              OR TRUNC(end_date)<TRUNC(sysdate) )
    AND     batch_id = p_batch_id
    AND     (process_flag IS NULL OR process_flag = 'N');

  CURSOR c_invalid_end_date IS
    SELECT  Interface_id
    FROM    amw_cst_waiver_interface
    WHERE   ( TRUNC(end_date)< TRUNC(start_date)
              OR TRUNC(end_date)<TRUNC(sysdate) )
    AND     (process_flag IS NULL OR process_flag = 'N');


  -- Cursor to check if a duplicate user waiver is specified for a constraint
  -- This check should consider the user waivers in the interface table as well
  -- as the user waiver allready existing in the constraint
  CURSOR    c_duplicate_user_waiver_batch IS
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi,
            amw_constraint_waivers_b cstw
    WHERE   acwi.object_type = 'USER'
    AND     cstw.object_type = 'USER'
    AND     acwi.batch_id = p_batch_id
    AND     cstw.constraint_rev_id= acwi.constraint_rev_id
    AND     cstw.pk1 = acwi.pk1
    AND     TRUNC(cstw.start_date)=TRUNC(acwi.start_date)
    AND     (cstw.end_date IS NULL OR TRUNC(cstw.end_date)=TRUNC(acwi.end_date) )
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    UNION
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi
    WHERE   acwi.object_type = 'USER'
    AND     acwi.batch_id = p_batch_id
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    AND     EXISTS ( SELECT 'Y'
                     FROM  amw_cst_waiver_interface acw
                     WHERE acw.batch_id = p_batch_id
                     AND   acw.object_type = 'USER'
                     AND   acw.pk1 = acwi.pk1
                     AND   acw.object_type = acwi.object_type
                     AND   acw.Interface_id <> acwi.Interface_id
                     AND   acw.constraint_rev_id = acwi.constraint_rev_id
                     AND   acw.constraint_rev_id IS NOT NULL
                     AND   (acw.process_flag IS NULL OR acw.process_flag = 'N')
                   );

  CURSOR    c_duplicate_user_waiver IS
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi,
            amw_constraint_waivers_b cstw
    WHERE   acwi.object_type = 'USER'
    AND     cstw.object_type = 'USER'
    AND     cstw.constraint_rev_id= acwi.constraint_rev_id
    AND     cstw.pk1 = acwi.pk1
    AND     TRUNC(cstw.start_date)=TRUNC(acwi.start_date)
    AND     (cstw.end_date IS NULL OR TRUNC(cstw.end_date)=TRUNC(acwi.end_date) )
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    UNION
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi
    WHERE   acwi.object_type = 'USER'
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    AND     EXISTS ( SELECT 'Y'
                     FROM  amw_cst_waiver_interface acw
                     WHERE acw.object_type = 'USER'
                     AND   acw.pk1 = acwi.pk1
                     AND   acw.object_type = acwi.object_type
                     AND   acw.Interface_id <> acwi.Interface_id
                     AND   acw.constraint_rev_id = acwi.constraint_rev_id
                     AND   acw.constraint_rev_id IS NOT NULL
                     AND   (acw.process_flag IS NULL OR acw.process_flag = 'N')
                   );

  -- Cursor to check if a duplicate responsibility waiver is specified for a constraint
  -- This check should consider the responsibility waivers in the interface table as well
  -- as the user waiver allready existing in the constraint
  CURSOR    c_duplicate_resp_waiver_batch IS
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi,
            amw_constraint_waivers_b cstw
    WHERE   acwi.object_type = 'RESP'
    AND     cstw.object_type = 'RESP'
    AND     acwi.batch_id = p_batch_id
    AND     cstw.constraint_rev_id= acwi.constraint_rev_id
    AND     cstw.pk1 = acwi.pk1
    AND     cstw.pk2 = acwi.pk2
    AND     TRUNC(cstw.start_date)=TRUNC(acwi.start_date)
    AND     (cstw.end_date IS NULL OR TRUNC(cstw.end_date)=TRUNC(acwi.end_date))
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     acwi.type_code in ('ALL','ME','SET')
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    UNION
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi
    WHERE   acwi.object_type = 'RESP'
    AND     acwi.batch_id = p_batch_id
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     acwi.type_code in ('ALL','ME','SET')
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    AND     EXISTS ( SELECT 'Y'
                     FROM  amw_cst_waiver_interface acw
                     WHERE acw.batch_id = p_batch_id
                     AND   acw.object_type = 'RESP'
                     AND   acw.pk1 = acwi.pk1
                     AND   acw.pk2 = acwi.pk2
                     AND   acw.object_type = acwi.object_type
                     AND   acw.Interface_id <> acwi.Interface_id
                     AND   acw.constraint_rev_id = acwi.constraint_rev_id
                     AND   acw.constraint_rev_id IS NOT NULL
                     AND   (acw.process_flag IS NULL OR acw.process_flag = 'N')
                   );

  CURSOR    c_duplicate_resp_waiver IS
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi,
            amw_constraint_waivers_b cstw
    WHERE   acwi.object_type = 'RESP'
    AND     cstw.object_type = 'RESP'
    AND     cstw.constraint_rev_id= acwi.constraint_rev_id
    AND     cstw.pk1 = acwi.pk1
    AND     cstw.pk2 = acwi.pk2
    AND     TRUNC(cstw.start_date)=TRUNC(acwi.start_date)
    AND     (cstw.end_date IS NULL OR TRUNC(cstw.end_date)=TRUNC(acwi.end_date))
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     acwi.type_code in ('ALL','ME','SET')
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    UNION
    SELECT  acwi.Interface_id
    FROM    amw_cst_waiver_interface acwi
    WHERE   acwi.object_type = 'RESP'
    AND     acwi.constraint_rev_id IS NOT NULL
    AND     acwi.type_code in ('ALL','ME','SET')
    AND     (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
    AND     EXISTS ( SELECT 'Y'
                     FROM  amw_cst_waiver_interface acw
                     WHERE acw.object_type = 'RESP'
                     AND   acw.pk1 = acwi.pk1
                     AND   acw.pk2 = acwi.pk2
                     AND   acw.object_type = acwi.object_type
                     AND   acw.Interface_id <> acwi.Interface_id
                     AND   acw.constraint_rev_id = acwi.constraint_rev_id
                     AND   acw.constraint_rev_id IS NOT NULL
                     AND   (acw.process_flag IS NULL OR acw.process_flag = 'N')
                   );


BEGIN
    /*
    Validations To be handled
    1. Check if the Constraint Name is Valid.
       If Not,
            Set the error_flag = 'Y' and Interface_Status = 'Constraint does
            not exist.Please enter a valid Constraint' for each waiver record
            of the constraint.

    2. Check if the Responsibility Type Constraint has any responsibility waivers.
       If yes,
            Set the error_flag = 'Y' and Interface_Status = 'Responsibility Type
            Constraint Cannot have Responsibility Waiver' for each responsibility
            waiver record of the current constraint. Since there is an error in
            the current constraint, all waivers of this constraint should not be
            uploaded. We should set a error messages in the valid wiaver records
            too for the constraint.

    3. When Object_Type= 'USER',
            The User_Name Should not be null.
            The Application_Short_Name Should be null
            The Responsibility_Name Should be null
            Set the error_flag = 'Y' and Interface_Status = 'The Application_Short_Name
            and Responsibility_Name Should be null' for waiver record of the
            constraint.Since there is an error in the current constraint, all
            waivers of this constraint should not be uploaded. We should set a
            error messages in the valid wiaver records too for the constraint.

    4. When Object_type= 'RESP'
            The Application_short_name should not be null;
            Responsbility_Name should not be null;
            The User_Name Should be null;
            Set the error_flag = 'Y' and Interface_Status = 'The User_Name
            Should be null' for waiver record of the constraint.
            Since there is an error in the current constraint, all waivers of
            this constraint should not be uploaded. We should set a error messages
            in the valid wiaver records too for the constraint.

    4. Check if the User_Name is valid
        If Not,
            Set the error_flag = 'Y' and Interface_Status = 'Invalid User Name.
            Please enter a valid User Name' for waiver record of the constraint.
            Since there is an error in the current constraint, all waivers of
            this constraint should not be uploaded. We should set a error messages
            in the valid wiaver records too for the constraint.

    5. Check if the Application_Short_Name and Responsibility Name is valid
        If Not,
            Set the error_flag = 'Y' and Interface_Status = 'Invalid User Name.
            Please enter a valid User Name' for waiver record of the constraint.
            Since there is an error in the current constraint, all waivers of
            this constraint should not be uploaded. We should set a error messages
            in the valid wiaver records too for the constraint.


    6. Check if the Start_Date and End_Date is less than sysdate
        If yes ,
            Set the error_flag = 'Y' and Interface_Status = 'Start_date/End_Date
            Cannot be less than sysdate' for waiver record of the constraint.
            Since there is an error in the current constraint, all waivers of
            this constraint should not be uploaded. We should set a error messages
            in the valid wiaver records too for the constraint.

    7. Check if duplicate User/Responsibility waiver exist.
       If Yes,
            Set the error_flag = 'Y' and Interface_Status = 'Duplicate
            Responsibility/user waiver' for the waiver record of the constraint.
            We should take into account the exsisting user waivers.
            Since there is an error in the current constraint, all waivers of
            this constraint should not be uploaded. We should set a error messages
            in the valid wiaver records too for the constraint.
    */

    IF p_batch_id IS NOT NULL THEN

        -- If Last_update_date is null , then set it to system date
        UPDATE amw_cst_waiver_interface
        SET last_update_date = SYSDATE
        WHERE batch_id = p_batch_id
        AND last_update_date IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If creation_date is null , then set it to system date
        UPDATE amw_cst_waiver_interface
        SET creation_date = SYSDATE
        WHERE batch_id = p_batch_id
        AND   creation_date IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If last_updated_by is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET last_updated_by = g_user_id
        WHERE batch_id = p_batch_id
        AND   last_updated_by IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If created_by is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET created_by = g_user_id
        WHERE batch_id = p_batch_id
        AND   created_by IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If last_update_login is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET last_update_login = g_user_id
        WHERE batch_id = p_batch_id
        AND   last_update_login IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        /*
        Set the Constraint_Rev_Id from the Constraint Name.

        If the constraint name is not valid, then the Constraint_Rev_Id will
        be set to NULL. If the Constraint_Rev_id is Null, then it means that the
        Constraint Name in the interface table is invalid.

        Populating of the Constraint_Rev_Id will avoid the joining of interface table
        with Amw_Constraint_Vl to get the constraint_rev_id from constraint name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.constraint_rev_id = ( SELECT acv.constraint_rev_id
                                       FROM   amw_constraints_vl acv
                                       WHERE  acwi.constraint_name = acv.constraint_name
                                       AND    acv.start_date IS NOT NULL
                                       AND    (acv.end_date IS NULL OR acv.end_date>=sysdate))
        WHERE acwi.batch_id = p_batch_id
        AND   acwi.constraint_name IS NOT NULL
        AND   acwi.constraint_rev_id IS NULL
        AND   (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        Set the TYPE_CODE from the Constraint Revision Id.

        If the Constraint Revision Id is NULL, then the TYPE_CODE will
        be set to NULL. If the Constraint_Rev_id is Null, then it means that the
        Constraint Name in the interface table is invalid.

        Populating of the TYPE_CODE will avoid the joining of interface table
        with Amw_Constraint_Vl to get the TYPE_CODE from constraint name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.type_code = ( SELECT acv.type_code
                                       FROM   amw_constraints_vl acv
                                       WHERE  acwi.constraint_rev_id = acv.constraint_rev_id
                                       AND    acv.start_date IS NOT NULL
                                       AND    (acv.end_date IS NULL OR acv.end_date>=sysdate))
        WHERE acwi.batch_id = p_batch_id
        AND   acwi.constraint_name IS NOT NULL
        AND   acwi.constraint_rev_id IS NOT NULL
        AND   acwi.type_code IS NULL
        AND   (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
         Set the Pk1 = User_id for user waiver defined in the interfcae table.

         If the User Name is not valid, then the PK1 will be set to NULL. If the
         PK1 is Null, then it means that the User_Name in the interface table is invalid.

         Populating of the Pk1 will avoid the joining of interface table
         with FND_USER to get the user_id from User_Name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk1 = ( SELECT user_id
                         FROM   fnd_user usr
                         WHERE  usr.user_name = acwi.user_name
                         AND    usr.start_date IS NOT NULL
                         AND    (usr.end_date IS NULL OR usr.end_date>=sysdate))
        WHERE acwi.batch_id = p_batch_id
        AND acwi.object_type = 'USER'
        AND acwi.user_name IS NOT NULL
        AND acwi.pk1 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
         Set the Pk2 = application_id for responsibility waivers defined in the
         interfcae table.

         If the Application_Short_Name  is not valid, then the PK2 will be set to NULL.
         If the PK2 is Null, then it means that the Application_Short_name in the
         interface table is invalid.

         Populating of the Pk2 will avoid the joining of interface table with
         FND_APPlication to get the application_id from Application_Short_Name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk2 = ( SELECT application_id
                         FROM   fnd_application appl
                         WHERE  appl.Application_short_name = acwi.application_short_name)
        WHERE acwi.batch_id = p_batch_id
        AND acwi.object_type = 'RESP'
        AND acwi.application_short_name IS NOT NULL
        AND acwi.pk2 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
         Set the Pk1 = responsibility_id for responsibility waivers defined in the
         interfcae table.

         If the Responsibility_Name is not valid, then the PK1 will be set to NULL.
         If the PK1 is Null, then it means that the responsibility_name in the
         interface table is invalid.

         Populating of the Pk1 will avoid the joining of interface table with
         Fnd_Responsibility_Vl to get the responsibility_id from responsibility_name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk1 = ( SELECT responsibility_id
                         FROM   fnd_responsibility_vl resp
                         WHERE  resp.application_id = acwi.pk2
                         AND    resp.responsibility_name = acwi.responsibility_name)
        WHERE acwi.batch_id = p_batch_id
        AND acwi.object_type = 'RESP'
        AND acwi.responsibility_name IS NOT NULL
        AND acwi.pk2 IS NOT NULL
        AND acwi.pk1 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        If the pk1 is null for responsibility waiver, we are setting the pk2 to null

        This is to indicate that a responsibility waiver is invalid when pk1 and
        pk2 is null
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk2 = NULL
        WHERE acwi.batch_id = p_batch_id
        AND acwi.object_type = 'RESP'
        AND acwi.pk1 IS NULL
        AND pk2 IS NOT NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
         Identify the invalid constraints
        */
        FOR invldcst_rec IN c_invld_cst_name_batch
        LOOP
            v_error_msg := 'Invalid Constraint Name ';
            update_waiver_intf_with_error(v_error_msg,invldcst_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldcst_rec.interface_id);
        END LOOP;

       -- ptulasi : 06/01/2007 : Bug 6067714 :
       -- Update all the invalid start date in amw_cst_waiver_interface
        FOR invldstdate_rec IN c_invalid_st_date_batch
        LOOP
            UPDATE amw_cst_waiver_interface acwi
            SET acwi.start_date = invldstdate_rec.start_date
            WHERE acwi.interface_id=invldstdate_rec.interface_id;
        END LOOP;

        /*
         Identify the responsibility constraint having responsibility waivers
        */
        FOR invldrespcst_rec IN c_invalid_resp_cst_batch
        LOOP
            v_error_msg := 'Responsibility Type Constraint cannot have Responsibility waivers';
            update_waiver_intf_with_error(v_error_msg,invldrespcst_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldrespcst_rec.interface_id);
        END LOOP;

        /*
         Identify the invalid user waiver
        */
        FOR invlduser_rec IN c_invalid_user_waiver_batch
        LOOP
            v_error_msg := 'Invalid User Name ';
            update_waiver_intf_with_error(v_error_msg,invlduser_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invlduser_rec.interface_id);
        END LOOP;

        /*
         Identify the invalid responsibility waiver
        */
        FOR invldresp_rec IN c_invalid_resp_waiver_batch
        LOOP
            v_error_msg := 'Invalid Application Short Name/Responsibility Name  ';
            update_waiver_intf_with_error(v_error_msg,invldresp_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldresp_rec.interface_id);
        END LOOP;

        /*  Commenting this check as the customer may populate the constraint waiver
            interface and the run the concurren ptogram on different days
         Identify the invalid start_date
        FOR invldstdate_rec IN c_invalid_start_date_batch
        LOOP
            v_error_msg := 'The Start Date should be greater than or equal to System Date';
            update_waiver_intf_with_error(v_error_msg,invldstdate_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldstdate_rec.interface_id);
        END LOOP;
        */

        /*
         Identify the invalid end_date
        */
        FOR invldenddate_rec IN c_invalid_end_date_batch
        LOOP
            v_error_msg := 'The End Date should not be less than System date/Start Date';
            update_waiver_intf_with_error(v_error_msg,invldenddate_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldenddate_rec.interface_id);
        END LOOP;

        /*
         Identify the duplicate user waivers
        */
        FOR dupuserwaiv_rec IN c_duplicate_user_waiver
        LOOP
            v_error_msg := 'The User Wiaver is either defined more than once '
            ||' in the interface table for the constraint / It is allready defined '
            ||' in the constraint';
            update_waiver_intf_with_error(v_error_msg,dupuserwaiv_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || dupuserwaiv_rec.interface_id);
        END LOOP;

        /*
         Identify the duplicate responsibility waivers
        */
        FOR duprespwaiv_rec IN c_duplicate_resp_waiver_batch
        LOOP
            v_error_msg := 'The Responsibility Wiaver is either defined more than once '
            ||' in the interface table for the constraint / It is allready defined '
            ||' in the constraint ';
            update_waiver_intf_with_error(v_error_msg,duprespwaiv_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || duprespwaiv_rec.interface_id);
        END LOOP;

        /*
          Should not upload the constraint waivers for a constraint, if any waiver
          is invalid.
          So set the error flag and the status.
        */
        UPDATE amw_cst_waiver_interface
        SET error_flag = 'Y',
        interface_status = 'Please correct the invalid waiver defined for this Constraint'
        WHERE error_flag IS NULL
        AND   batch_id = p_batch_id
        AND  (process_flag IS NULL OR process_flag = 'N')
        AND   constraint_rev_id IN ( SELECT DISTINCT constraint_rev_id
                                     FROM  amw_cst_waiver_interface
                                     WHERE error_flag = 'Y'
                                     AND   batch_id = p_batch_id
                                     AND  (process_flag IS NULL OR process_flag = 'N') );

        /*
         Set the constraint waiver id for the valid constraint waivers.

         We do this to avoid iterating over each waiver record to set the
         constraint waiver id by executing select sequence.nextval.

         This also helps us to insert all the data in one single query.
        */
        UPDATE amw_cst_waiver_interface
        SET    constraint_waiver_id = amw_constraint_waiver_s.nextval
        WHERE  error_flag IS NULL
        AND  (process_flag IS NULL OR process_flag = 'N')
        AND    batch_id = p_batch_id;


        /*
         Insert the valid constraint wavers into the amw_constraint_waivers_b
        */
        INSERT INTO amw_constraint_waivers_b(
    				    last_update_date,
	       			    last_updated_by,
	   	      		    last_update_login,
		    		    creation_date,
		      		    created_by,
			     	    security_group_id,
				       constraint_rev_id,
				        object_type,
    				    pk1,
	       			    pk2,
		      			pk3,
			     		pk4,
			        	pk5,
            			start_date,
			      		end_date,
				    	constraint_waiver_id,
					   object_version_number
                     )
        SELECT acwi.last_update_date,
	           acwi.last_updated_by,
	           acwi.last_update_login,
    	       acwi.creation_date,
	           acwi.created_by,
	           NULL,
	           acwi.constraint_rev_id,
    	       acwi.object_type,
	           acwi.pk1,
	           acwi.pk2,
    	       acwi.pk3,
	           acwi.pk4,
	           acwi.pk5,
	           acwi.start_date,
    	       acwi.end_date,
	          acwi.constraint_waiver_id,
	           1
        FROM   amw_cst_waiver_interface acwi
        WHERE  acwi.error_flag IS NULL
        AND    acwi.batch_id = p_batch_id
        AND    (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
         Insert the valid constraint wavers into the amw_constraint_waivers_tl
        */
        INSERT INTO amw_constraint_waivers_tl (
                        constraint_waiver_id,
                        justification,
                        language,
                        source_lang,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        security_group_id
                    )
        SELECT acwi.constraint_waiver_id,
        	   trim(acwi.justification),
    	       l.language_code,
    	       userenv('LANG'),
        	   acwi.last_update_date,
        	   acwi.last_updated_by,
    	       acwi.creation_date,
        	   acwi.created_by,
        	   acwi.last_update_login,
               NULL
        FROM   fnd_languages l,
  	           amw_cst_waiver_interface acwi
        WHERE  l.installed_flag IN ('I', 'B')
        AND    acwi.error_flag IS NULL
        AND    acwi.batch_id = p_batch_id
        AND    (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
        AND NOT EXISTS ( SELECT NULL
                         FROM   amw_constraint_waivers_tl t
                         WHERE  t.constraint_waiver_id = acwi.constraint_waiver_id
                         AND    t.language = l.language_code);

        IF p_del_after_import = 'Y' THEN
            -- Delete the uploaded constraint waiver
            DELETE FROM amw_cst_waiver_interface
            WHERE batch_id = p_batch_id
            AND error_flag IS NULL;
        ELSE
            -- Set the process_flag for valid constraint waivers
            UPDATE amw_cst_waiver_interface
            SET process_flag = 'Y'
            WHERE batch_id = p_batch_id
            AND error_flag IS NULL;
        END IF;
    ELSE
        -- If Last_update_date is null , then set it to system date
        UPDATE amw_cst_waiver_interface
        SET last_update_date = SYSDATE
        WHERE last_update_date IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If creation_date is null , then set it to system date
        UPDATE amw_cst_waiver_interface
        SET creation_date = SYSDATE
        WHERE creation_date IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If last_updated_by is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET last_updated_by = g_user_id
        WHERE last_updated_by IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If created_by is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET created_by = g_user_id
        WHERE created_by IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        -- If last_update_login is null , then set it to logged in user id
        UPDATE amw_cst_waiver_interface
        SET last_update_login = g_user_id
        WHERE last_update_login IS NULL
        AND   (process_flag IS NULL OR process_flag = 'N');

        /*
        Set the Constraint_Rev_Id from the Constraint Name.

        If the constraint name is not valid, then the Constraint_Rev_Id will
        be set to NULL. If the Constraint_Rev_id is Null, then it means that the
        Constraint Name in the interface table is invalid.

        Populating of the Constraint_Rev_Id will avoid the joining of interface table
        with Amw_Constraint_Vl to get the constraint_rev_id from constraint name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.constraint_rev_id = ( SELECT acv.constraint_rev_id
                                       FROM   amw_constraints_vl acv
                                       WHERE  acwi.constraint_name = acv.constraint_name
                                       AND    acv.start_date IS NOT NULL
                                       AND    (acv.end_date IS NULL OR acv.end_date>=sysdate))
        WHERE acwi.constraint_name IS NOT NULL
        AND acwi.constraint_rev_id IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        Set the TYPE_CODE from the Constraint Revision Id.

        If the Constraint Revision Id is NULL, then the TYPE_CODE will
        be set to NULL. If the Constraint_Rev_id is Null, then it means that the
        Constraint Name in the interface table is invalid.

        Populating of the TYPE_CODE will avoid the joining of interface table
        with Amw_Constraint_Vl to get the TYPE_CODE from constraint name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.type_code = (  SELECT acv.type_code
                                FROM   amw_constraints_vl acv
                                WHERE  acwi.constraint_rev_id = acv.constraint_rev_id
                                AND    acv.start_date IS NOT NULL
                                AND    (acv.end_date IS NULL OR acv.end_date>=sysdate))
        WHERE acwi.constraint_name IS NOT NULL
        AND   acwi.constraint_rev_id IS NOT NULL
        AND   acwi.type_code IS NULL
        AND   (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        Set the Pk1 = User_id for user waiver defined in the interfcae table.

        If the User Name is not valid, then the PK1 will be set to NULL. If the
        PK1 is Null, then it means that the User_Name in the interface table is invalid.

        Populating of the Pk1 will avoid the joining of interface table
        with FND_USER to get the user_id from User_Name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk1 = ( SELECT user_id
                         FROM   fnd_user usr
                         WHERE  usr.user_name = acwi.user_name
                         AND    usr.start_date IS NOT NULL
                         AND    (usr.end_date IS NULL OR usr.end_date>=sysdate))
        WHERE acwi.object_type = 'USER'
        AND acwi.user_name IS NOT NULL
        AND acwi.pk1 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        Set the Pk2 = application_id for responsibility waivers defined in the
        interfcae table.

        If the Application_Short_Name  is not valid, then the PK2 will be set to NULL.
        If the PK2 is Null, then it means that the Application_Short_name in the
        interface table is invalid.

        Populating of the Pk2 will avoid the joining of interface table with
        FND_APPlication to get the application_id from Application_Short_Name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk2 = ( SELECT application_id
                         FROM   fnd_application appl
                         WHERE  appl.Application_short_name = acwi.application_short_name)
        WHERE acwi.object_type = 'RESP'
        AND acwi.application_short_name IS NOT NULL
        AND acwi.pk2 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
        Set the Pk1 = responsibility_id for responsibility waivers defined in the
        interfcae table.

        If the Responsibility_Name is not valid, then the PK1 will be set to NULL.
        If the PK1 is Null, then it means that the responsibility_name in the
        interface table is invalid.

        Populating of the Pk1 will avoid the joining of interface table with
        Fnd_Responsibility_Vl to get the responsibility_id from responsibility_name
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk1 = ( SELECT responsibility_id
                         FROM   fnd_responsibility_vl resp
                         WHERE  resp.application_id = acwi.pk2
                         AND    resp.responsibility_name = acwi.responsibility_name)
        WHERE acwi.object_type = 'RESP'
        AND acwi.responsibility_name IS NOT NULL
        AND acwi.pk2 IS NOT NULL
        AND acwi.pk1 IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');

        /*
        If the pk1 is null for responsibility waiver, we are setting the pk2 to null

        This is to indicate that a responsibility waiver is invalid when pk1 and
        pk2 is null
        */
        UPDATE amw_cst_waiver_interface acwi
        SET acwi.pk2 = NULL
        WHERE acwi.object_type = 'RESP'
        AND acwi.pk1 IS NULL
        AND pk2 IS NOT NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
        Identify the invalid constraints
        */
        FOR invldcst_rec IN c_invld_cst_name
        LOOP
            v_error_msg := 'Invalid Constraint Name ';
            update_waiver_intf_with_error(v_error_msg,invldcst_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldcst_rec.interface_id);
        END LOOP;

       -- ptulasi : 06/01/2007 : Bug 6067714 :
       -- Update all the invalid start date in amw_cst_waiver_interface
        FOR invldstdate_rec IN c_invalid_st_date
        LOOP
            UPDATE amw_cst_waiver_interface acwi
            SET acwi.start_date = invldstdate_rec.start_date
            WHERE acwi.interface_id=invldstdate_rec.interface_id;
        END LOOP;

        /*
        Identify the responsibility constraint having responsibility waivers
        */
        FOR invldrespcst_rec IN c_invalid_resp_cst
        LOOP
            v_error_msg := 'Responsibility Type Constraint cannot have Responsibility waivers';
            update_waiver_intf_with_error(v_error_msg,invldrespcst_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldrespcst_rec.interface_id);
        END LOOP;

        /*
        Identify the invalid user waiver
        */
        FOR invlduser_rec IN c_invalid_user_waiver
        LOOP
            v_error_msg := 'Invalid User Name ';
            update_waiver_intf_with_error(v_error_msg,invlduser_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invlduser_rec.interface_id);
        END LOOP;

        /*
        Identify the invalid responsibility waiver
        */
        FOR invldresp_rec IN c_invalid_resp_waiver
        LOOP
            v_error_msg := 'Invalid Application Short Name/Responsibility Name  ';
            update_waiver_intf_with_error(v_error_msg,invldresp_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldresp_rec.interface_id);
        END LOOP;

        /*
            Commenting this check as the customer may populate the constraint waiver
            interface and the run the concurren ptogram on different days
            Identify the invalid start_date

        FOR invldstdate_rec IN c_invalid_start_date
        LOOP
            v_error_msg := 'The Start Date should be greater than or equal to System Date';
            update_waiver_intf_with_error(v_error_msg,invldstdate_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldstdate_rec.interface_id);
        END LOOP; */

        /*
        Identify the invalid end_date
        */
        FOR invldenddate_rec IN c_invalid_end_date
        LOOP
            v_error_msg := 'The End Date should not be less than System date/Start Date';
            update_waiver_intf_with_error(v_error_msg,invldenddate_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || invldenddate_rec.interface_id);
        END LOOP;

        /*
        Identify the duplicate user waivers
        */
        FOR dupuserwaiv_rec IN c_duplicate_user_waiver
        LOOP
            v_error_msg := 'The User Wiaver is either defined more than once '
            ||' in the interface table for the constraint / It is allready defined '
            ||' in the constraint';
            update_waiver_intf_with_error(v_error_msg,dupuserwaiv_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || dupuserwaiv_rec.interface_id);
        END LOOP;

        /*
        Identify the duplicate responsibility waivers
        */
        FOR duprespwaiv_rec IN c_duplicate_resp_waiver
        LOOP
            v_error_msg := 'The Responsibility Wiaver is either defined more than once '
            ||' in the interface table for the constraint / It is allready defined '
            ||' in the constraint ';
            update_waiver_intf_with_error(v_error_msg,duprespwaiv_rec.interface_id);
            fnd_file.put_line (fnd_file.LOG, v_error_msg || ' for interface id ' || duprespwaiv_rec.interface_id);
        END LOOP;

        /*
        Should not upload the constraint waivers for a constraint, if any waiver
        is invalid.
        So set the error flag and the status.
        */
        UPDATE amw_cst_waiver_interface
        SET error_flag = 'Y',
            interface_status = 'Please correct the invalid waiver defined for this Constraint'
        WHERE error_flag IS NULL
        AND (process_flag IS NULL OR process_flag = 'N')
        AND constraint_rev_id IN ( SELECT DISTINCT constraint_rev_id
                                    FROM  amw_cst_waiver_interface
                                    WHERE error_flag = 'Y');

        /*
        Set the constraint waiver id for the valid constraint waivers.

        We do this to avoid iterating over each waiver record to set the
        constraint waiver id by executing select sequence.nextval.

        This also helps us to insert all the data in one single query.
        */
        UPDATE amw_cst_waiver_interface
        SET    constraint_waiver_id = amw_constraint_waiver_s.nextval
        WHERE  error_flag IS NULL
        AND    (process_flag IS NULL OR process_flag = 'N');

        /*
        Insert the valid constraint wavers into the amw_constraint_waivers_b
        */
        INSERT INTO amw_constraint_waivers_b(
				    last_update_date,
				    last_updated_by,
				    last_update_login,
				    creation_date,
				    created_by,
				    security_group_id,
				    constraint_rev_id,
				    object_type,
				    pk1,
				    pk2,
					pk3,
					pk4,
					pk5,
					start_date,
					end_date,
					constraint_waiver_id,
					object_version_number
                 )
        SELECT acwi.last_update_date,
	           acwi.last_updated_by,
	           acwi.last_update_login,
	           acwi.creation_date,
	           acwi.created_by,
	           NULL,
	           acwi.constraint_rev_id,
	           acwi.object_type,
	           acwi.pk1,
	           acwi.pk2,
	           acwi.pk3,
	           acwi.pk4,
	           acwi.pk5,
	           acwi.start_date,
	           acwi.end_date,
	           acwi.constraint_waiver_id,
	           1
        FROM   amw_cst_waiver_interface acwi
        WHERE  acwi.error_flag IS NULL
        AND    (acwi.process_flag IS NULL OR acwi.process_flag = 'N');


        /*
        Insert the valid constraint wavers into the amw_constraint_waivers_tl
        */
        INSERT INTO amw_constraint_waivers_tl (
                    constraint_waiver_id,
                    justification,
                    language,
                    source_lang,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    security_group_id
                )
        SELECT acwi.constraint_waiver_id,
    	       trim(acwi.justification),
    	       l.language_code,
    	       userenv('LANG'),
    	       acwi.last_update_date,
    	       acwi.last_updated_by,
    	       acwi.creation_date,
    	       acwi.created_by,
    	       acwi.last_update_login,
                NULL
        FROM fnd_languages l,
  	         amw_cst_waiver_interface acwi
        WHERE l.installed_flag IN ('I', 'B')
        AND acwi.error_flag IS NULL
        AND (acwi.process_flag IS NULL OR acwi.process_flag = 'N')
        AND NOT EXISTS ( SELECT NULL
                         FROM amw_constraint_waivers_tl t
                         WHERE t.constraint_waiver_id = acwi.constraint_waiver_id
                         AND t.language = l.language_code);

        IF p_del_after_import = 'Y' THEN
            -- Delete the uploaded constraint waiver
            DELETE FROM amw_cst_waiver_interface
            WHERE error_flag IS NULL;
        ELSE
            -- Set the process_flag for valid constraint waivers
            UPDATE amw_cst_waiver_interface
            SET process_flag = 'Y'
            WHERE error_flag IS NULL;
        END IF;
    END IF;
    -- commmit all the changes
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        v_err_msg := 'Error during package processing '||SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));
END create_constraint_waivers;

-- ===============================================================
-- Procedure name
--          update_waiver_intf_with_error
-- Purpose
-- 		  	Updates error flag and interface status of
--          amw_cst_waiver_interface interface table
-- ===============================================================
PROCEDURE update_waiver_intf_with_error (
    p_err_msg        IN   VARCHAR2,
    p_interface_id   IN   NUMBER
)
IS
    l_interface_status  amw_cst_waiver_interface.interface_status%TYPE;
BEGIN
    SELECT  interface_status
    INTO    l_interface_status
    FROM    amw_cst_waiver_interface
    WHERE   interface_id = p_interface_id;

    IF l_interface_status IS NOT NULL THEN
        l_interface_status := l_interface_status || ' ; ';
    END IF;

    l_interface_status := l_interface_status || p_err_msg || ' ';

    UPDATE  amw_cst_waiver_interface
    SET     interface_status = l_interface_status,
            error_flag       = 'Y'
    WHERE   interface_id     = p_interface_id;

EXCEPTION
    WHEN OTHERS THEN
        v_err_msg := 'Error during package processing  ' || ' interface_id: = '
        || p_interface_id  || SUBSTR (SQLERRM, 1, 100);
        fnd_file.put_line (fnd_file.LOG, SUBSTR (v_err_msg, 1, 200));

END update_waiver_intf_with_error;

-- ===============================================================
-- Procedure name
--          cst_table_update_report
-- Purpose
--      Report the issues identified during updating of the following
--      columsn the application_id
--      1. AMW_VIOLAT_USER_ENTRIES.APPLICATION_ID
--      2. AMW_CONSTRAINT_ENTRIES.APPLICATION_ID
--      3. AMW_VIOLAT_RESP_ENTRIES.APPLICATION_ID
--      4. AMW_VIOLAT_USER_ENTRIES.PROGRAM_APPLICATION_ID
--      5. AMW_CONSTRAINT_WAIVERS_B.PK2
-- Notes
--          this procedure is called in Concurrent Executable
-- ===============================================================
PROCEDURE cst_table_update_report  (
    ERRBUF      OUT NOCOPY   VARCHAR2,
    RETCODE     OUT NOCOPY   VARCHAR2
) is
    TYPE G_NUMBER_TABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE G_VARCHAR_TABLE IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
    TYPE G_VARCHAR2_CODE_TABLE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    l_cst_rev_id_list               G_NUMBER_TABLE;
    l_function_id_list              G_NUMBER_TABLE;
    l_resp_id_list		            G_NUMBER_TABLE;
    l_appl_id_list                  G_NUMBER_TABLE;
    l_prg_appl_id_list              G_NUMBER_TABLE;
    l_cst_name_list                 G_VARCHAR_TABLE;
    l_resp_name_list                G_VARCHAR_TABLE;
    l_appl_name_list                  G_VARCHAR_TABLE;
    l_cp_name_list                  G_VARCHAR_TABLE;
    l_object_type_list              G_VARCHAR2_CODE_TABLE;

    CURSOR c_invalid_resp IS
        SELECT  distinct acv.CONSTRAINT_REV_ID,
                acv.CONSTRAINT_NAME,
                avue.RESPONSIBILITY_ID
        FROM    AMW_CONSTRAINTS_VL acv,
                AMW_VIOLATIONS av,
                AMW_VIOLATION_USERS avu,
                AMW_VIOLAT_USER_ENTRIES avue
        WHERE   acv.START_DATE<= SYSDATE
        AND     (acv.END_DATE IS NULL OR acv.END_DATE>=SYSDATE)
        AND     acv.CONSTRAINT_REV_ID=av.CONSTRAINT_REV_ID
        AND     av.VIOLATION_ID=avu.VIOLATION_ID
        AND     av.STATUS_CODE  <> 'NA'
        AND     avu.USER_VIOLATION_ID=avue.USER_VIOLATION_ID
        AND     avue.RESPONSIBILITY_ID IS NOT NULL
        AND     1 < (   SELECT  COUNT(1)
                        FROM    FND_RESPONSIBILITY resp
                        WHERE   resp.START_DATE <= SYSDATE
                        AND     (resp.END_DATE >= SYSDATE or resp.END_DATE IS NULL)
                        AND     resp.RESPONSIBILITY_ID=avue.RESPONSIBILITY_ID);


    -- Identifies all the Incompatible Responsibility/Concurrent Program
    -- having more than 1 Application Id
    CURSOR c_cst_entries IS
        SELECT  acv.CONSTRAINT_REV_ID,
                acv.CONSTRAINT_NAME,
                ace.OBJECT_TYPE,
                ace.FUNCTION_ID
        FROM    AMW_CONSTRAINTS_VL acv,
                AMW_CONSTRAINT_ENTRIES ace
        WHERE   acv.START_DATE<= SYSDATE
        AND     (acv.END_DATE IS NULL OR acv.END_DATE>=SYSDATE)
        AND      acv.CONSTRAINT_REV_ID=ace.CONSTRAINT_REV_ID
        AND      ace.OBJECT_TYPE = 'RESP'
        AND     1 < (   SELECT  COUNT(1)
                        FROM    FND_RESPONSIBILITY resp
                        WHERE   resp.START_DATE <= SYSDATE
                        AND     (resp.END_DATE >= SYSDATE or resp.END_DATE IS NULL)
                        AND     resp.RESPONSIBILITY_ID=ace.FUNCTION_ID)
        UNION ALL
        SELECT  acv.CONSTRAINT_REV_ID,
                acv.CONSTRAINT_NAME,
                ace.OBJECT_TYPE,
                ace.FUNCTION_ID
        FROM    AMW_CONSTRAINTS_VL acv,
                AMW_CONSTRAINT_ENTRIES ace
        WHERE   acv.START_DATE<= SYSDATE
        AND     (acv.END_DATE IS NULL OR acv.END_DATE>=SYSDATE)
        AND      acv.CONSTRAINT_REV_ID=ace.CONSTRAINT_REV_ID
        AND      ace.OBJECT_TYPE = 'CP'
        AND     1 < (   SELECT  COUNT(1)
                        FROM    FND_CONCURRENT_PROGRAMS conc
                        WHERE   conc.CONCURRENT_PROGRAM_ID=ace.FUNCTION_ID
                        AND     ENABLED_FLAG='Y');


    -- Identifies the Constraint whose User Violation has Concurrent Program
    -- having more than 1 Application Id
    CURSOR c_valid_amw_vio_user_entries IS
        SELECT  DISTINCT acv.CONSTRAINT_REV_ID,
                acv.CONSTRAINT_NAME,
                avue.FUNCTION_ID
        FROM    AMW_CONSTRAINTS_VL acv,
                AMW_VIOLATIONS av,
                AMW_VIOLATION_USERS avu,
                AMW_VIOLAT_USER_ENTRIES avue
        WHERE   acv.CONSTRAINT_REV_ID=av.CONSTRAINT_REV_ID
        AND     av.VIOLATION_ID=avu.VIOLATION_ID
        AND     avu.USER_VIOLATION_ID=avue.USER_VIOLATION_ID
        AND     avue.OBJECT_TYPE='CP'
        AND     av.STATUS_CODE  <> 'NA'
        AND     1 < (   SELECT  COUNT(1)
                        FROM    FND_CONCURRENT_PROGRAMS conc
                        WHERE   conc.CONCURRENT_PROGRAM_ID=avue.FUNCTION_ID
                        AND     ENABLED_FLAG='Y');

    -- Identifies the Constraint whose Responsibility Violation has Concurrent Program
    -- having more than 1 Application Id
    CURSOR c_amw_violation_resp_entries IS
        SELECT  DISTINCT acv.CONSTRAINT_REV_ID,
                acv.CONSTRAINT_NAME,
                avre.FUNCTION_ID
        FROM    AMW_VIOLATIONS av,
                AMW_CONSTRAINTS_VL acv,
                AMW_VIOLATION_RESP avr,
                AMW_VIOLAT_RESP_ENTRIES  avre
        WHERE   av.CONSTRAINT_REV_ID  = acv.CONSTRAINT_REV_ID
        AND     av.VIOLATION_ID       = avr.VIOLATION_ID
        AND    avr.RESP_VIOLATION_ID = avre.RESP_VIOLATION_ID
        AND     avre.OBJECT_TYPE='CP'
        AND     av.STATUS_CODE  <> 'NA'
        AND     1 < (   SELECT  COUNT(1)
                        FROM    FND_CONCURRENT_PROGRAMS conc
                        WHERE   conc.CONCURRENT_PROGRAM_ID = avre.FUNCTION_ID
                        AND     ENABLED_FLAG='Y');

    -- Identifies the Constraint Responsibility Wiaver
    -- having more than 1 Application Id
    CURSOR c_amw_cst_waiver IS
        SELECT acwb.CONSTRAINT_REV_ID,
	           acv.CONSTRAINT_NAME,
	           acwb.PK1
        FROM   AMW_CONSTRAINT_WAIVERS_B acwb,
	           AMW_CONSTRAINTs_VL acv
        WHERE  acwb.CONSTRAINT_REV_ID =acv.CONSTRAINT_REV_ID
        AND    acwb.OBJECT_TYPE='RESP'
        AND    1 < ( SELECT COUNT(1)
                 FROM   FND_RESPONSIBILITY resp
                 WHERE  resp.START_DATE <= SYSDATE
                 AND    (resp.END_DATE >= SYSDATE or resp.END_DATE IS NULL)
                 AND    resp.RESPONSIBILITY_ID=acwb.PK1);

BEGIN
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| Start Data Fix for AMW_VIOLAT_USER_ENTRIES.APPLICATION_ID          |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'Please Re-Run the violation check for Constraints');

    l_cst_rev_id_list.delete();
    l_cst_name_list.delete();
    l_resp_id_list.delete();

    OPEN c_invalid_resp;
    FETCH c_invalid_resp
    BULK COLLECT INTO l_cst_rev_id_list,
                      l_cst_name_list,
                      l_resp_id_list;
    CLOSE c_invalid_resp;

    IF ((l_resp_id_list IS NOT NULL) and (l_resp_id_list.FIRST IS NOT NULL)) THEN
    FOR i in l_resp_id_list.FIRST .. l_resp_id_list.LAST
    LOOP
            fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------------------------');
            fnd_file.put_line(fnd_file.LOG,'Constraint Name : '||l_cst_name_list(i));
       	    fnd_file.put_line(fnd_file.LOG,'Responsibility Id that mapping to more than 1 Application_Id : '||l_resp_id_list(i));

       	    l_appl_id_list.delete();
            l_resp_name_list.delete();
            l_appl_name_list.delete();

            SELECT APPL.APPLICATION_ID,APPL.APPLICATION_NAME,RESP.RESPONSIBILITY_NAME
            BULK COLLECT INTO l_appl_id_list,
                              l_appl_name_list,
                              l_resp_name_list
            FROM  FND_RESPONSIBILITY_VL RESP,
                  FND_APPLICATION_VL APPL
            WHERE RESP.RESPONSIBILITY_ID = l_resp_id_list(i)
            AND   RESP.START_DATE <= SYSDATE
            AND   (RESP.END_DATE >= SYSDATE OR RESP.END_DATE IS NULL)
            AND   RESP.APPLICATION_ID=APPL.APPLICATION_ID;
                        IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
                FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                LOOP
       	            fnd_file.put_line(fnd_file.LOG,'   Responsibility Name     : '||l_resp_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application Name        : '||l_appl_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application_Id          : '||l_appl_id_list(k));
                END LOOP;
            END IF;
    END LOOP;
    END IF;
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| End Data Fix for AMW_VIOLAT_USER_ENTRIES.APPLICATION_ID          |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| Start Data Fix for AMW_CONSTRAINT_ENTRIES.APPLICATION_ID           |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    -- Data fix for AMW_CONSTRAINT_ENTRIES
    -- Cleaning the lists
    l_cst_rev_id_list.delete();
    l_cst_name_list.delete();
    l_function_id_list.delete();
    l_object_type_list.delete();

    fnd_file.put_line (fnd_file.LOG,'Please Manaully verify the following Constraints  ');

    OPEN c_cst_entries;
    FETCH c_cst_entries
    BULK COLLECT INTO l_cst_rev_id_list,
                      l_cst_name_list,
                      l_object_type_list,
                      l_function_id_list;
    CLOSE c_cst_entries;

    IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN
        FOR i IN l_function_id_list.FIRST .. l_function_id_list.LAST
        LOOP
            fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------------------------');
       	    fnd_file.put_line(fnd_file.LOG,'Constraint Name : '||l_cst_name_list(i));

       	    IF l_object_type_list(i)='RESP' THEN
       	        fnd_file.put_line(fnd_file.LOG,'Responsibility Id that mapping to more than 1 Application_Id : '||l_function_id_list(i));
       	        fnd_file.put_line(fnd_file.LOG,'Possible Responsibilities to be included in the contraint : ');

       	        -- Clear the List
       	        l_appl_id_list.delete();
                l_appl_name_list.delete();
                l_resp_name_list.delete();

       	        SELECT  APPL.APPLICATION_ID,APPL.APPLICATION_NAME,RESP.RESPONSIBILITY_NAME
                BULK COLLECT INTO l_appl_id_list,
                                  l_appl_name_list,
                                  l_resp_name_list
                FROM  FND_RESPONSIBILITY_VL RESP,
                      FND_APPLICATION_VL APPL
                WHERE RESP.RESPONSIBILITY_ID = l_function_id_list(i)
                AND   RESP.START_DATE <= SYSDATE
                AND   (RESP.END_DATE >= SYSDATE OR RESP.END_DATE IS NULL)
                AND   RESP.APPLICATION_ID=APPL.APPLICATION_ID
                ORDER BY APPLICATION_ID;

                IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
                    FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                    LOOP
       	                fnd_file.put_line(fnd_file.LOG,'   Responsibility Name : '||l_resp_name_list(k));
                        fnd_file.put_line(fnd_file.LOG,'   Application Name    : '||l_appl_name_list(k));
                        fnd_file.put_line(fnd_file.LOG,'   Application Id      : '||l_appl_id_list(k));
                    END LOOP; -- FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
       	            fnd_file.put_line(fnd_file.LOG,'Responsibility automatically migrated for the Constraint : ');
       	            fnd_file.put_line(fnd_file.LOG,'   Responsibility Name : '||l_resp_name_list(1));
                    fnd_file.put_line(fnd_file.LOG,'   Application Name    : '||l_appl_name_list(1));
                    fnd_file.put_line(fnd_file.LOG,'   Application Id      : '||l_appl_id_list(1));
                END IF; -- IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
            ELSE
                fnd_file.put_line(fnd_file.LOG,'Conc Program Id that mapping to more than 1 Application_Id : '||l_function_id_list(i));
       	        fnd_file.put_line(fnd_file.LOG,'Possible Conc. Programs to be included in the Contraint : ');

                l_appl_id_list.delete();
                l_cp_name_list.delete();
                l_appl_name_list.delete();

                SELECT appl.APPLICATION_ID,appl.APPLICATION_NAME,conc.USER_CONCURRENT_PROGRAM_NAME
                BULK COLLECT INTO l_appl_id_list,
                                  l_appl_name_list,
                                  l_cp_name_list
                FROM  FND_CONCURRENT_PROGRAMS_VL conc,
                      FND_APPLICATION_VL appl
                WHERE conc.CONCURRENT_PROGRAM_ID=l_function_id_list(i)
                AND   conc.APPLICATION_ID=appl.APPLICATION_ID
                AND   conc.ENABLED_FLAG='Y'
                ORDER BY APPLICATION_ID;

                IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
                    FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                    LOOP
       	                fnd_file.put_line(fnd_file.LOG,'   Concurrent Program Name : '||l_cp_name_list(k));
                        fnd_file.put_line(fnd_file.LOG,'   Application Name        : '||l_appl_name_list(k));
                        fnd_file.put_line(fnd_file.LOG,'   Application Id          : '||l_appl_id_list(k));
                    END LOOP; -- FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST

       	            fnd_file.put_line(fnd_file.LOG,'Concurrent Program automatically migrated for the Constraint : ');
       	            fnd_file.put_line(fnd_file.LOG,'   Concurrent Program Name : '||l_cp_name_list(1));
                    fnd_file.put_line(fnd_file.LOG,'   Application Name        : '||l_appl_name_list(1));
                    fnd_file.put_line(fnd_file.LOG,'   Application Id          : '||l_appl_id_list(1));
                END IF; -- IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
            END IF; -- IF l_object_type_list(i)='RESP' THEN
        END LOOP; -- FOR i IN l_function_id_list.FIRST .. l_function_id_list.LAST
    END IF; --  IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| End Data Fix for AMW_CONSTRAINT_ENTRIES.APPLICATION_ID             |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'|Starting Data Fix for AMW_VIOLAT_USER_ENTRIES.PROGRAM_APPLICATION_ID|');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line (fnd_file.LOG,'Please Re-Run the violation check for Constraints');

    -- Data fix for AMW_VIOLAT_USER_ENTRIES.PROGRAM_APPLICATION_ID
    -- Clear the List
    l_cst_rev_id_list.delete();
    l_cst_name_list.delete();
    l_function_id_list.delete();

    -- Get all the valid amw_violate_user_entries
    OPEN  c_valid_amw_vio_user_entries;
    FETCH c_valid_amw_vio_user_entries
    BULK COLLECT INTO  l_cst_rev_id_list,l_cst_name_list,l_function_id_list;
    CLOSE c_valid_amw_vio_user_entries;

    IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN
        FOR i in l_function_id_list.FIRST .. l_function_id_list.LAST
        LOOP
            fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------------------------');
            fnd_file.put_line(fnd_file.LOG,'Constraint Name : '||l_cst_name_list(i));
       	    fnd_file.put_line(fnd_file.LOG,'Conc Program Id that mapping to more than 1 Application_Id : '||l_function_id_list(i));

            l_appl_id_list.delete();
            l_cp_name_list.delete();
            l_appl_name_list.delete();

            SELECT appl.APPLICATION_ID,appl.APPLICATION_NAME,conc.USER_CONCURRENT_PROGRAM_NAME
            BULK COLLECT INTO l_appl_id_list,
                              l_appl_name_list,
                              l_cp_name_list
            FROM  FND_CONCURRENT_PROGRAMS_VL conc,
                  FND_APPLICATION_VL appl
            WHERE conc.CONCURRENT_PROGRAM_ID=l_function_id_list(i)
            AND   conc.APPLICATION_ID=appl.APPLICATION_ID
            AND   conc.ENABLED_FLAG='Y';

            IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
                FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                LOOP
       	            fnd_file.put_line(fnd_file.LOG,'   Concurrent Program Name : '||l_cp_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application Name        : '||l_appl_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application_Id          : '||l_appl_id_list(k));
                END LOOP;
            END IF; -- IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
        END LOOP; -- FOR i in l_function_id_list.FIRST .. l_function_id_list.LAST
    END IF; -- IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| Ending Data Fix for AMW_VIOLAT_USER_ENTRIES.PROGRAM_APPLICATION_ID |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| Start Data Fix for AMW_VIOLAT_RESP_ENTRIES.APPLICATION_ID          |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    -- Clear the list
    l_cst_rev_id_list.delete();
    l_cst_name_list.delete();
    l_function_id_list.delete();

    OPEN  c_amw_violation_resp_entries;
    FETCH c_amw_violation_resp_entries
    BULK COLLECT INTO  l_cst_rev_id_list,l_cst_name_list,l_function_id_list;
    CLOSE c_amw_violation_resp_entries;

    IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN
        FOR i in l_function_id_list.FIRST .. l_function_id_list.LAST
        LOOP
            fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------------------------');
            fnd_file.put_line(fnd_file.LOG, 'Constraint Name : '||l_cst_name_list(i));
       	    fnd_file.put_line(fnd_file.LOG, 'Conc Program Id that mapping to more than 1 Application_Id : '||l_function_id_list(i));

            l_appl_id_list.delete();
            l_cp_name_list.delete();
            l_appl_name_list.delete();

            SELECT appl.APPLICATION_ID,appl.APPLICATION_NAME,conc.USER_CONCURRENT_PROGRAM_NAME
            BULK COLLECT INTO l_appl_id_list,
                              l_appl_name_list,
                              l_cp_name_list
            FROM  FND_CONCURRENT_PROGRAMS_VL conc,
                  FND_APPLICATION_VL appl
            WHERE conc.CONCURRENT_PROGRAM_ID=l_function_id_list(i)
            AND   conc.APPLICATION_ID=appl.APPLICATION_ID
            AND   conc.ENABLED_FLAG='Y';

            IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
                FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                LOOP
       	            fnd_file.put_line(fnd_file.LOG,'   Concurrent Program Name : '||l_cp_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application Name        : '||l_appl_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'   Application Id          : '||l_appl_id_list(k));
                END LOOP; -- FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
            END IF; -- IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
        END LOOP; -- end of FOR j in l_function_id_list.FIRST .. l_function_id_list.LAST
    END IF; -- end of IF ((l_function_id_list IS NOT NULL) and (l_function_id_list.FIRST IS NOT NULL)) THEN


    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| End Data Fix for AMW_VIOLAT_RESP_ENTRIES.APPLICATION_ID            |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| Start Data Fix for AMW_CONSTRAINT_WAIVERS_B.PK2                    |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');

    fnd_file.put_line(fnd_file.LOG, 'Please Manaully verify the following Constraints Responsibility Waiver .');

    -- clean up the list
    l_cst_rev_id_list.delete();
    l_resp_id_list.delete();
    l_cst_name_list.delete();

    OPEN  c_amw_cst_waiver;
    FETCH c_amw_cst_waiver
    BULK COLLECT INTO  	l_cst_rev_id_list,l_cst_name_list,l_resp_id_list;
    CLOSE c_amw_cst_waiver;

    IF ((l_resp_id_list IS NOT NULL) and (l_resp_id_list.FIRST IS NOT NULL)) THEN
        FOR i in l_resp_id_list.FIRST .. l_resp_id_list.LAST
        LOOP
            fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------------------------');
            fnd_file.put_line(fnd_file.LOG,'Constraint Name : '||l_cst_name_list(i));

            -- Clear the List.
            l_appl_id_list.delete();
            l_appl_name_list.delete();
            l_resp_name_list.delete();

            -- Get all the application Ids associated with the responsibility
            -- into the list l_appl_id_list in assending order so that the
            -- minimum application id is first in the list.
            SELECT APPL.APPLICATION_ID,APPL.APPLICATION_NAME,RESP.RESPONSIBILITY_NAME
            BULK COLLECT INTO l_appl_id_list,
                              l_appl_name_list,
                              l_resp_name_list
            FROM  FND_RESPONSIBILITY_VL RESP,
                  FND_APPLICATION_VL APPL
            WHERE RESP.RESPONSIBILITY_ID = l_resp_id_list(i)
            AND   RESP.START_DATE <= SYSDATE
            AND   (RESP.END_DATE >= SYSDATE OR RESP.END_DATE IS NULL)
            AND   RESP.APPLICATION_ID=APPL.APPLICATION_ID
            ORDER BY APPLICATION_ID;

            IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN

       	        fnd_file.put_line(fnd_file.LOG,'Responsibility Id that mapping to more than 1 Application_Id : '||l_resp_id_list(i));
       	        fnd_file.put_line(fnd_file.LOG,'Possible Responsibilities Waivers to be included in the contraint :');
       	        FOR k in l_appl_id_list.FIRST .. l_appl_id_list.LAST
                LOOP
       	            fnd_file.put_line(fnd_file.LOG,'    Responsibility Name : '||l_resp_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'    Application Name    : '||l_appl_name_list(k));
                    fnd_file.put_line(fnd_file.LOG,'    Application Id      : '||l_appl_id_list(k));
                END LOOP;
       	        fnd_file.put_line(fnd_file.LOG,'Responsibility Waiver automatically migrated for the Constraint:');
       	        fnd_file.put_line(fnd_file.LOG,'    Responsibility Name : '||l_resp_name_list(1));
                fnd_file.put_line(fnd_file.LOG,'    Application Name    : '||l_appl_name_list(1));
                fnd_file.put_line(fnd_file.LOG,'    Application Id      : '||l_appl_id_list(1));
            END IF;-- End of IF ((l_appl_id_list IS NOT NULL) and (l_appl_id_list.FIRST IS NOT NULL)) THEN
        END LOOP; -- FOR i in l_resp_id_list.FIRST .. l_resp_id_list.LAST
    END IF; -- end of ((l_resp_id_list IS NOT NULL) and (l_resp_id_list.FIRST IS NOT NULL)) THEN

    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'| End Data Fix for AMW_CONSTRAINT_WAIVERS_B.PK2                      |');
    fnd_file.put_line(fnd_file.LOG,'|                                                                    |');
    fnd_file.put_line(fnd_file.LOG,'+====================================================================+');
EXCEPTION
    WHEN OTHERS THEN
        fnd_file.put_line (fnd_file.LOG, SUBSTR (SQLERRM, 1, 200));
END;


END AMW_LOAD_SOD_DATA;

/
