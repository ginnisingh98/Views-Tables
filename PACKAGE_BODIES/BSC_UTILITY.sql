--------------------------------------------------------
--  DDL for Package Body BSC_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UTILITY" AS
/*$Header: BSCUTILB.pls 120.31 2007/10/04 14:39:13 sirukull ship $ */
/*===========================================================================+
 |               Copyright (c) 1995 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 | History:                                                                  |
 | Modified Date     Modified By     Description                             |
 |  31-JUL-2003      mahrao          Increased the size of l_dim_level var.  |
 |                                   in get_kpi_dim_levels procedure for     |
 |                                   bug# 3030788                            |
 |  20-Aug-03   Adeulgao fixed bug#3008243 eliminated hard coding            |
 |                      of schema name                                       |
 |  12-NOV-03    Bug #3232366                                                |
 |  27-FEB-2004 adeulgao fixed bug#3431750                                   |
 |  20-APR-2004 ADRAO Added API is_Indicator_In_Production for KPI end-to-end|
 |  16-JUN-2004 ADRAO added API Is_BSC_Licensed() for Bug#3764205            |
 |  09-AUG-2004 sawu  Added API Get_Default_Internal_Name for bug#3819855    |
 |  18-AUG-2004 ADRAO Fixed Bug#3831815                                      |
 |  01-OCT-2004 ashankar Fixed Bug#3908204                                   |
 |  31-MAR-2005 ADRAO added API is_Mix_Dim_Objects_Allowed                   |
 |  08-APR-2005 kyadamak Added function get_valid_bsc_master_tbl_name() for  |
 |                       bug# 4290359                                        |
 |  30-JUN-2005 ppandey   added Dimension entity validation APIs             |
 |  01-SEP-2005 adrao    Added API Get_Responsibility_Key for Bug#4563456    |
 |  25-AUG-2005 ppandey   added validation for Weighted Report generated     |
 |                        Bug #4570320 Dim and Dim Group used in Report      |
 |  13-Sep-2005 sawu  Bug#4602231: Broken is_internal_dim into component apis|
 |  05-Oct-2005 ashankar Bug#      Added the method Get_User_Time            |
 |  10-Oct-2005 akoduri   Bug#4646118 Recognize 120 as seed user for R12     |
 |  25-OCT-2005 kyadamak  Removed literals for Enhancement#4618419        |
 |  02-Jan-2006 akoduri Bug#4611303 - Support For Enable/Disable All         |
 |                       In Report Designer                                  |
 |  05-JAN-06   ppandey  Enh#4860106 - Defined Is_More as a public function  |
 | 06-Jan-2006 akoduri   Enh#4739401 - Hide Dimensions/Dim Objects           |
 | 13-JAN-06    adrao                                                        |
 | The following APIs have been added as a part of the Enhancement#3909868   |
 |                                                                           |
 |  Validate_Plsql_For_Report                                                |
 |      -- actual api to validation the pl/sql for the report                |
 |  Get_Plsql_Parameters                                                     |
 |      -- gets the pl/sql report for the passed pl/sql procedure            |
 |  Remove_Repeating_Comma                                                   |
 |      -- Removes and parses repeating comma's                              |
 |  Validate_PLSQL                                                           |
 |      -- Validates existentially the pl/sql package and performes some     |
 |         validation apis                                                   |
 |  Obtain_Report_Query                                                      |
 |      -- Does the job of actually getting the Report query                 |
 |  Insert_Into_Query_Table                                                  |
 |      -- An API to insert into the PL/SQL table.                           |
 |  Do_DDL_AT                                                                |
 |      -- Autonously call DDL statements, used in our case for creating     |
 |         and dropping views                                                |
 |  Validate_Sql_String                                                      |
 |      -- Validate's if a SQL string is ok by creating a view               |
 |  Sort_String                                                              |
 |     -- sorts a comma separated string values                              |
 |                                                                           |
 |  17-JAN-2005 adrao  modified Validate_Plsql for Bug#4957841               |
 |  24-JAN-2006 ankgoel  Bug#4954663 Show Info text for AG to PL/SQL or VB conversion|
 |  15-FEB-2006 adrao   Bug#5034549; Added ABS() to DBMS_UTILITY.GET_TIME,   |
 |                      since it can return a negative value                 |
 |  29-MAR-2006 visuri  Enh#5125893 Direct Creation of Pl/Sql reports        |
 |  19-JUN-2006 adrao   Added util API Create_Unique_Comma_List &            |
 |                      Get_Unique_List for Bug#5300060                      |
 |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112               |
 |  21-MAR-2007 akoduri Copy Indicator Enh#5943238                           |
 |  02-JUl-2007 lbodired Bug#6152009;To make use get_nof_independent_dimobj  |
 |              function for 'PMF' dimension objects also         |
 |  04-OCT-2007 sirukull  Bug#6406844. Comparing Leapyear daily periodicity  |
  |			  data with non-leapyear data.			     |
+===========================================================================*/
/*----------------------------------------------------------------------------
 FILE NAME

    BSCUTILB.pls

 PACKAGE NAME

    bsc_utility

 DESCRIPTION
    This package includes all OBSC public utility functions/procedures.

 PUBLIC PROCEDURES
    enable_debug
    enable_debug()
    disable_debug
    debug()
    print_fcn_label()
    print_fcn_label2()
    close_cursor()
    update_edw_flag()

 PRIVATE PROCEDURES/FUNCTIONS
    exec_dynamic_sql()
    create_synonym_for_edw_time_m()

 PRIVATE PROCEDURES/FUNCTIONS

 EXTERNAL PROCEDURES/FUNCTIONS ACCESSED

 HISTORY
 15-JAN-1999    Srinivasan Jandyala Created
 22-JAN-1999    Alex Yang           Added Do_SQL() procedure.
 29-MAR-2001    Srini               Added PUBLIC PROCEDURE update_edw_flag(),
                                    PRIVATE PROCEDURE
                                    create_synonym_for_edw_time_m().
 27-Apr-2001    Srini               Added PUBLIC FUNCTION is_edw_installed().
 21-DEC-2001    Mario-Jair Campos   Added procedures:  get_dataset_id
                                                       get_kpi_dim_levels
 27-DEC-2001    Srini               Added function:get_kpi_dim_level_short_names
 23-APR-2003    mdamle              Added the Add_To_Fnd_Msg_Stack
 06-AUG-2003    mdamle              Added token-value to add_to_fnd_msg_stack
 08-FEB-2006    akoduri             Bug#4956836 Updating dim object cache should
                                    invalidate AK Cache also
----------------------------------------------------------------------------*/

-----------------------------------------------------------------------------
-- Private Variables
-----------------------------------------------------------------------------
   debug_flag boolean := false;

--This is for caching User schema names
TYPE user_schema_table IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(30);
user_schema_tbl  user_schema_table;

g_apps_user_schema CONSTANT VARCHAR2(100) := 'APPS';

FUNCTION is_attached_to_objective (
  p_dataset_id   IN  NUMBER
, p_region_code  IN  VARCHAR2
) RETURN VARCHAR2;

FUNCTION is_formula_measure (
  p_dataset_id   IN  NUMBER
) RETURN VARCHAR2;


-----------------------------------------------------------------------------
-- Debugging functions
-----------------------------------------------------------------------------
PROCEDURE enable_debug IS
BEGIN

   debug_flag := true;
   --dbms_output.enable;

END;

PROCEDURE enable_debug( buffer_size NUMBER ) IS
BEGIN

   debug_flag := true;
   --dbms_output.enable( buffer_size );

END;

PROCEDURE disable_debug IS
BEGIN

   debug_flag := false;

END;

PROCEDURE print_debug( line IN VARCHAR2 ) IS

   rest            varchar2(32767);
   buffer_overflow exception;
   pragma exception_init(buffer_overflow, -20000);

BEGIN

      IF debug_flag THEN

        rest := line;

        LOOP

            IF (rest IS NULL) THEN
                exit;
            ELSE
                --dbms_output.put_line(substrb(rest, 1, 255));
                rest := substrb(rest, 256);
            END IF;

        END LOOP;

      END IF;

EXCEPTION
  WHEN buffer_overflow THEN
      NULL;  -- buffer overflow, ignore
  WHEN OTHERS THEN
      RAISE;

END print_debug;

PROCEDURE print_debug( str VARCHAR2, print_level NUMBER ) IS
BEGIN

    IF( bsc_utility.msg_level >= print_level ) THEN
    print_debug( str );
    END IF;

END print_debug;


Procedure Debug(
    x_calling_fn    IN  Varchar2,
    x_debug_msg     IN  Varchar2 := NULL,
    x_mode          IN  Varchar2 := 'N'
) Is
    l_debug_msg Varchar2(2000);
Begin
    IF debug_flag THEN
        l_debug_msg := x_calling_fn || ': ' || x_debug_msg;

        BSC_MESSAGE.add(x_message => l_debug_msg,
                        x_source  => x_calling_fn,
                        x_type    => 4,
                        x_mode    => x_mode
                        );
    END IF;
End Debug;


PROCEDURE print_fcn_label( p_label VARCHAR2 ) IS
BEGIN

    print_debug( p_label || ' ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'),
           bsc_utility.MSG_LEVEL_TIMING );

END print_fcn_label;

PROCEDURE print_fcn_label2( p_label VARCHAR2 ) IS
BEGIN

    print_debug( p_label || ' ' || to_char(sysdate, 'DD-MON-YY HH:MI:SS'),
           bsc_utility.MSG_LEVEL_DEBUG );

END print_fcn_label2;

-----------------------------------------------------------------------------
-- Database utilities
-----------------------------------------------------------------------------
FUNCTION exec_dynamic_sql(x_sql_stmt IN VARCHAR2)

    RETURN NUMBER IS

    h_handle NUMBER;
    h_ignore NUMBER;

BEGIN

    bsc_utility.print_debug('SQL stmt: '||x_sql_stmt);

    h_handle := dbms_sql.open_cursor;
    dbms_sql.parse(h_handle, x_sql_stmt, dbms_sql.native);
    h_ignore := dbms_sql.execute(h_handle);

    RETURN(h_handle);

END exec_dynamic_sql;


PROCEDURE close_cursor( p_cursor_handle IN OUT NOCOPY NUMBER ) IS
BEGIN

    IF( dbms_sql.is_open( p_cursor_handle ) ) THEN

        dbms_sql.close_cursor( p_cursor_handle );

    END IF;

EXCEPTION
    WHEN OTHERS THEN
    BSC_MESSAGE.add(
        x_message => sqlerrm,
        x_source  => 'BSC_UTILITY.Close_Cursor'
        );

        print_debug('ERROR: bsc_utility.close_cursor()',
             bsc_utility.MSG_LEVEL_BASIC);
        RAISE;
END close_cursor;




Procedure Do_SQL(
    x_sql_stmt  IN  Varchar2,
    x_calling_fn    IN  Varchar2
) Is
    h_handle    NUMBER;
        h_ignore    NUMBER;
Begin

    h_handle := dbms_sql.open_cursor;

    dbms_sql.parse(h_handle, x_sql_stmt, dbms_sql.native);

    h_ignore := dbms_sql.execute(h_handle);

    dbms_sql.close_cursor(h_handle);

Exception
    When Others Then

    BSC_MESSAGE.add(x_message => sqlerrm,
                        x_source  => x_calling_fn,
                        x_type    => 0,
                        x_mode    => 'I'
            );

        BSC_UTILITY.debug(x_calling_fn => 'BSC_UTILITY.DO_SQL',
                          x_debug_msg  => x_sql_stmt,
                          x_mode => 'I'
                  );

        if (dbms_sql.is_open(h_handle)) then
        dbms_sql.close_cursor(h_handle);
        end if;

End Do_SQL;


Procedure Do_Rollback Is
Begin

   -- Rollback uncommitted transactions.
   rollback;

   -- Insert error messages into bsc_message_logs table.
   bsc_message.flush;

   -- commit rows in bsc_message_logs table.
   -- commit work;

End Do_Rollback;

-----------------------------------------------------------------------------
-- Private Procedure: create_synonym_for_edw_time_m (for BSC v5.0)
-----------------------------------------------------------------------------

-- Purpose: To create synonym for APPS.edw_time_m object. This is required to
--          be created seperately since EDW time is not mapped as a regular
--          dimension. This means DIM DDL generator will not create it.
--          We create it only when EDW is enabled by user.
--
--          This procedure is called by update_edw_flag() precedure.
--
-- Arguments
--
--  h_call_proc_name: Calling Function/Procedure name.
--  h_mode:           ENABLE/DISABLE mode.
--
-----------------------------------------------------------------------------

PROCEDURE create_synonym_for_edw_time_m(h_call_proc_name IN VARCHAR2) IS

l_call_proc     VARCHAR2(1024) := NULL;
l_object_name   VARCHAR2(30)   := NULL;
l_sql_stmt      VARCHAR2(100);
l_Bsc_Temp      VARCHAR2(3);

BEGIN

    l_call_proc := RTRIM(LTRIM(h_call_proc_name));

    -- to avoid GSCC Fail - File.Sql.6 Hard-coded Schema name 'BSC'.
    l_Bsc_Temp  := 'BSC';
    l_sql_stmt  := 'CREATE SYNONYM '|| l_Bsc_Temp||'.edw_time_m FOR edw_time_m';

    --dbms_output.put_line(l_sql_stmt);

    BEGIN     -- Check for edw_time_m

        SELECT
            synonym_name
        INTO
            l_object_name
        FROM
            ALL_SYNONYMS
        WHERE
            TABLE_NAME  = 'EDW_TIME_M'
        AND owner       = BSC_APPS.get_user_schema;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_object_name := NULL;
            --dbms_output.put_line('EDW_TIME_M does not exist');

    END;      -- Check for edw_time_m

    -- We will create synonym only if doesn't exist. Otherwise, you will get
    -- ORA error: Object already exists.

    IF (l_object_name IS NULL) THEN

      BEGIN

        -- Create synonym.

        EXECUTE IMMEDIATE l_sql_stmt;
        --dbms_output.put_line('EDW_TIME_M synonym created');

      EXCEPTION
        WHEN OTHERS THEN
            bsc_message.add(
                x_message => 'create_synonym_for_edw_time_m: '||SQLERRM,
                x_source  => l_call_proc,
                x_mode    => 'I' );

            RAISE;
      END;

    END IF;

END create_synonym_for_edw_time_m;

-----------------------------------------------------------------------------
-- Function: is_edw_installed (for BSC v5.0)
-----------------------------------------------------------------------------

-- Purpose: To ENABLE/DISABLE menu item 'EDW' in Builder. This function will
--          check if EDW and BSC patch are installed. If they are, then
--          Builder will show menu item 'EDW' enabled, otherwise, disabled.
--
--          This function is called by BUILDER.
--
-- Arguments
--
--  h_call_proc_name: Calling Function/Procedure name.
--
-- Return code
--
--  1 = EDW installed
--  0 = EDW not installed
--
-----------------------------------------------------------------------------

FUNCTION is_edw_installed(h_call_proc_name IN VARCHAR2)
    RETURN NUMBER IS

-- Objects to check for.

l_edw_obj_name      VARCHAR2(30)   := 'EDW_DIMENSIONS_MD_V';
l_bsc_obj_name      VARCHAR2(30)   := 'BSC_INTEGRATION_MV_GEN';

-- Local variables

l_count             NUMBER         := 0;
l_message           VARCHAR2(1024) := NULL;
l_call_proc         VARCHAR2(1024) := NULL;
l_object_name       VARCHAR2(30)   := NULL;

l_sql_stmt          VARCHAR2(512);

l_edw_dimensions_md_v_exist     BOOLEAN := FALSE;
l_dimensions_exist              BOOLEAN := FALSE;
l_bsc_integration_mv_gen_exist  BOOLEAN := FALSE;

BEGIN

    l_call_proc := RTRIM(LTRIM(h_call_proc_name));

    -- Check for the existance of EDW metadata view 'EDW_DIMENSIONS_MD_V'.
    -- (To determine if EDW is properly installed for use by BSC).

    BEGIN     -- Check EDW object_name

        SELECT
            object_name
        INTO
            l_object_name
        FROM
            user_objects
        WHERE
            object_name = l_edw_obj_name
        AND object_type IN ('VIEW', 'SYNONYM');

        -- Returned row, i.e., EDW_DIMENSIONS_MD_V view exists.

        l_edw_dimensions_md_v_exist := TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_edw_dimensions_md_v_exist := FALSE;
            RETURN (0);

        WHEN OTHERS THEN
            l_message := 'is_edw_installed.SQL1: '||SQLERRM;
            RAISE;

    END;      -- Check EDW object_name

    -- Check if EDW metadata import was done successfully.
    -- This can be verified if any dimensions exist in edw_dimensions_md_v
    -- view.

    l_sql_stmt := 'SELECT dim_id FROM edw_dimensions_md_v WHERE ROWNUM < 2';

    BEGIN       -- Do dimensions exist ?

        EXECUTE IMMEDIATE l_sql_stmt INTO l_count;
        --dbms_output.put_line('l_count: '||l_count);

        l_dimensions_exist := TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_dimensions_exist := FALSE;
            RETURN (0);

        WHEN OTHERS THEN
            l_message := 'is_edw_installed.SQL2: '||SQLERRM;
            RAISE;

    END;        -- Do dimensions exist ?

    -- If we are here, it means that EDW is installed and metadata import
    -- was done successfully.
    -- Check if BSC-EDW Integration package(s) is installed.

      BEGIN     -- Check BSC object_name

        SELECT
            object_name
        INTO
            l_object_name
        FROM
            user_objects
        WHERE
            object_name = l_bsc_obj_name
        AND object_type = 'PACKAGE BODY';

        l_bsc_integration_mv_gen_exist := TRUE;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_bsc_integration_mv_gen_exist := FALSE;
            RETURN (0);

        WHEN OTHERS THEN
            l_message := 'is_edw_installed.SQL3: '||SQLERRM;
            RAISE;

      END;      -- Check BSC object_name

    IF ( l_edw_dimensions_md_v_exist AND
         l_dimensions_exist          AND
         l_bsc_integration_mv_gen_exist ) THEN

        RETURN(1);
    ELSE
        RETURN(0);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        bsc_message.add(
            x_message => l_message,
            x_source  => l_call_proc,
            x_type    => 1,
            x_mode    => 'I' );

        RETURN(0);

END is_edw_installed;

-----------------------------------------------------------------------------
-- Procedure: update_edw_flag (for BSC v5.0)
-----------------------------------------------------------------------------

-- Purpose: To ENABLE/DISABLE bsc_sys_init.property_code = 'EDW_INSTALLED'.
--          This procedure is called by BUILDER.
--
--          We do the same checks as in is_edw_installed() function since
--          from the time EDW is installed/implemented, the objects
--          in questions may have been deleted.
--
--          If the checks fail, we don't update EDW_INSTALLED property code
--          wrongly. I log any errors.
--
-- Arguments
--
--  h_call_proc_name: Calling Function/Procedure name.
--  h_mode:           ENABLE/DISABLE.
--
-----------------------------------------------------------------------------

PROCEDURE update_edw_flag(
            h_call_proc_name  IN VARCHAR2,
            h_mode            IN VARCHAR2) IS

-- Local variables

-- Objects to check for.

l_edw_obj_name      VARCHAR2(30)   := 'EDW_DIMENSIONS_MD_V';
l_bsc_obj_name      VARCHAR2(30)   := 'BSC_INTEGRATION_MV_GEN';

l_count             NUMBER         := 0;
l_message           VARCHAR2(1024) := NULL;
l_call_proc         VARCHAR2(1024) := NULL;
l_object_name       VARCHAR2(30)   := NULL;
l_property_code     bsc_sys_init.property_code%TYPE := 'EDW_INSTALLED';
l_property_value    bsc_sys_init.property_value%TYPE;

l_sql_stmt          VARCHAR2(512);

BEGIN

    l_call_proc := RTRIM(LTRIM(h_call_proc_name));

  IF (h_mode = 'ENABLE') THEN

    -- Check for the existance of EDW metadata view 'EDW_DIMENSIONS_MD_V'.
    -- (To determine if EDW is properly installed for use by BSC).

    BEGIN     -- Check EDW object_name

        SELECT
            object_name
        INTO
            l_object_name
        FROM
            user_objects
        WHERE
            object_name = l_edw_obj_name
        AND object_type IN ('VIEW', 'SYNONYM');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_message := 'Error: '||l_edw_obj_name||' view not found.';

            --dbms_output.put_line(l_message);

            bsc_message.add(
                x_message => 'update_edw_flag(ENABLE): '||l_message,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

            goto done;

    END;      -- Check EDW object_name

    -- Check if EDW metadata import was done successfully.
    -- This can be verified if any dimensions exist in edw_dimensions_md_v
    -- view.

    l_sql_stmt := 'SELECT dim_id FROM edw_dimensions_md_v WHERE ROWNUM < 2';

    BEGIN       -- Do dimensions exist ?

        EXECUTE IMMEDIATE l_sql_stmt INTO l_count;
        --dbms_output.put_line('l_count: '||l_count);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_message := 'Warning: No dimensions exist.';

            bsc_message.add(
                x_message => 'update_edw_flag(ENABLE): '||l_message,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

            goto done;

    END;        -- Do dimensions exist ?


    -- If we are here, it means that EDW is installed and metadata import
    -- was done successfully.
    -- Check if  BSC-EDW Integration package(s) is installed.

      BEGIN     -- Check BSC object_name

        SELECT
            object_name
        INTO
            l_object_name
        FROM
            user_objects
        WHERE
            object_name = l_bsc_obj_name
        AND object_type = 'PACKAGE BODY';

      EXCEPTION
        WHEN NO_DATA_FOUND THEN

            l_message := 'Error: '||l_bsc_obj_name||' view not found.';

            --dbms_output.put_line(l_message);

            bsc_message.add(
                x_message => 'update_edw_flag(ENABLE): '||l_message,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

            goto done;

      END;      -- Check BSC object_name

    -- Now, we can update property_value for EDW_INSTALLED property_code.

    BEGIN       -- Update EDW_INSTALLED flag

        UPDATE bsc_sys_init
        SET    property_value = 'TRUE'
        WHERE  property_code  = l_property_code
        AND    property_value = 'FALSE';

    EXCEPTION
        WHEN OTHERS THEN

            --dbms_output.put_line(SQLERRM);

            bsc_message.add(
                x_message => 'update_edw_flag(ENABLE): '||SQLERRM,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

            goto done;

    END;        -- Update EDW_INSTALLED flag

    -- Since we updated EDW_INSTALLED property code, we can create the
    -- EDW_TIME_M synonym from BSC schema. This is done only once.
    --
    create_synonym_for_edw_time_m(l_call_proc);

    --dbms_output.put_line('Updated bsc_sys_init.EDW_INSTALLED = TRUE.');


<<done>>
    NULL;

  ELSIF (h_mode = 'DISABLE') THEN

    -- Check if any KPIs are currently mapped to EDW. If so, ask the user
    -- to delete them before we disable EDW Integration.

    l_count := 0;

    BEGIN       -- Check for EDW mapped KPIs

        SELECT
            indicator
        INTO
            l_count
        FROM
            bsc_kpis_vl
        WHERE
            edw_flag = 1
        AND ROWNUM   < 2;

    EXCEPTION
        WHEN OTHERS THEN

            --dbms_output.put_line(SQLERRM);

            bsc_message.add(
                x_message => 'update_edw_flag(DISABLE): '||SQLERRM,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

    END;        -- Check for EDW mapped KPIs


    -- If there are EDW mapped KPIs, don't update flag. Instead, ask user to
    -- first delete these KPIs before he can disable it.

    IF (l_count = 0) THEN

      BEGIN       -- Update EDW_INSTALLED flag

        UPDATE bsc_sys_init
        SET    property_value = 'FALSE'
        WHERE  property_code  = l_property_code
        AND    property_value = 'TRUE';

        --dbms_output.put_line('Updated bsc_sys_init.EDW_INSTALLED = FALSE.');

      EXCEPTION
        WHEN OTHERS THEN

            --dbms_output.put_line(SQLERRM);

            bsc_message.add(
                x_message => 'update_edw_flag(ENABLE): '||SQLERRM,
                x_source  => l_call_proc,
                x_type    => 1,
                x_mode    => 'I' );

      END;        -- Update EDW_INSTALLED flag

    ELSE

        l_message := BSC_UPDATE_UTIL.Get_Message('BSC_EDW_DISABLE');

        --dbms_output.put_line(l_message);

        bsc_message.add(
            x_message => l_message,
            x_source  => l_call_proc,
            x_type    => 0,
            x_mode    => 'I' );

    END IF;     -- IF (l_count = 0)

  ELSE

      -- Invalid mode passed.

        l_message := 'ERROR: Invalid mode ('||h_mode||') passed.';

        --dbms_output.put_line(l_message);

        bsc_message.add(
            x_message => 'update_edw_flag(): '||l_message,
            x_source  => l_call_proc,
            x_mode    => 'I' );

  END IF;   -- IF (p_mode = 'ENABLE')

    COMMIT WORK;

EXCEPTION
    WHEN OTHERS THEN
        --dbms_output.put_line(SQLERRM);
        bsc_message.add(
            x_message => 'update_edw_flag: '||SQLERRM,
            x_source  => l_call_proc,
            x_mode    => 'I' );

    COMMIT WORK;

END update_edw_flag;

-----------------------------------------------------------------------------

/* The following function is used to get the dataset id for an analysis
   option.  A function is needed to do this because of the way
   BSC_KPI_ANALYSIS_MEASURES_B handles analysis option ids, it has different
   columns for the different analysis groups.  This Function in a way
   normalizes these columns.
   Parameters for the function are:  BSC KPI Id, Analysis Option group Id,
                                     Analysis Option Id.
*/

function get_dataset_id(
  p_kpi_id              number
 ,p_option_group_id     number
 ,p_option_id          number
) return number is

TYPE Recdc_value IS REF CURSOR;
dc_value                Recdc_value;

l_cnt                   number;
l_dataset_id            number;

l_column                varchar2(30);
l_sql                   varchar2(5000);

begin

  if p_option_group_id = 0 then
    l_column := 'analysis_option0';
  elsif p_option_group_id = 1 then
    l_column := 'analysis_option1';
  else
    l_column := 'analysis_option2';
  end if;

  l_sql := ' select distinct dataset_id ' ||
           '   from BSC_KPI_ANALYSIS_MEASURES_B ' ||
           '  where indicator = :1 '||
           '    and ' || l_column || ' = : 2' ;

  open dc_value for l_sql using p_kpi_id,p_option_id;
    fetch dc_value into l_dataset_id;
  close dc_value;
  return l_dataset_id;

EXCEPTION
  when others then
    return NULL;
    --dbms_output.put_line('Error:' || SQLERRM);

end get_dataset_id;

-----------------------------------------------------------------------------

/*  The following function is used to obtain the dimension levels for a given
    Analysis Option.  This function returns all dimension levels in a single
    string.
*/

function get_kpi_dim_levels(
  p_kpi_id              number
 ,p_dim_set_id          number
) return varchar2 is
    l_dim_levels            varchar2(32000);

    CURSOR c_KPI_Names IS
    SELECT DISTINCT NAME
    FROM   BSC_KPI_DIM_LEVELS_TL
    WHERE  INDICATOR    = p_kpi_id
    AND    DIM_SET_ID   = p_dim_set_id;
begin
    FOR cd IN c_KPI_Names LOOP
        IF (l_dim_levels IS NULL) THEN
            l_dim_levels := cd.Name;
        ELSE
            l_dim_levels := l_dim_levels || ', ' || cd.Name;
        END IF;
    END LOOP;
    return l_dim_levels;
EXCEPTION
  when others then
    NULL;
    --dbms_output.put_line('Error:' || SQLERRM);
end get_kpi_dim_levels;

function get_kpi_dim_level_short_names(
  p_kpi_id              number
 ,p_dim_set_id          number
) return varchar2 is
    l_dim_levels            varchar2(2000);

    CURSOR c_KPI_Names IS
    SELECT DISTINCT Level_ShortName
    FROM   BSC_KPI_DIM_LEVELS_VL
    WHERE  INDICATOR    = p_kpi_id
    AND    DIM_SET_ID   = p_dim_set_id;
begin
    FOR cd IN c_KPI_Names LOOP
        IF (l_dim_levels IS NULL) THEN
            l_dim_levels := cd.Level_ShortName;
        ELSE
            l_dim_levels := l_dim_levels || ', ' || cd.Level_ShortName;
        END IF;
    END LOOP;
    return l_dim_levels;
EXCEPTION
  when others then
    NULL;
    --dbms_output.put_line('Error:' || SQLERRM);

end get_kpi_dim_level_short_names;

function get_system_timestamp(
  x_return_status   OUT NOCOPY  varchar2
 ,x_msg_count       OUT NOCOPY  number
 ,x_msg_data        OUT NOCOPY  varchar2
) return varchar2 is

l_timestamp         varchar2(20);

begin

  select to_char(last_update_date, 'DD-MON-YYYY-HH24-MI-SS')
    into l_timestamp
    from BSC_SYS_INIT
   where property_code = 'LOCK_SYSTEM';

  return l_timestamp;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end get_system_timestamp;

function get_session_error(
  x_return_status       OUT NOCOPY     varchar2
 ,x_msg_count           OUT NOCOPY     number
 ,x_msg_data            OUT NOCOPY     varchar2
) return varchar2 is

l_message           varchar2(2000);
l_session_id            number;
l_count             number;

begin

  FND_MSG_PUB.Initialize;

  select userenv('SESSIONID')
    into l_session_id
    from dual;

  select count(message)
    into l_count
    from BSC_MESSAGE_LOGS
   where type = 0
     and upper(source) = 'BSC_SECURITY.CHECK_SYSTEM_LOCK'
     and last_update_login =  l_session_id;

  if l_count < 1 then
    return 'N';
  else
    select message
      into l_message
      from BSC_MESSAGE_LOGS
     where type = 0
       and upper(source) = 'BSC_SECURITY.CHECK_SYSTEM_LOCK'
       and last_update_login =  l_session_id;

    return l_message;

  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);
  WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count    =>      x_msg_count
                              ,p_data     =>      x_msg_data);

end get_session_error;


FUNCTION ListToNumericArray(
    x_string IN VARCHAR2,
    x_number_array IN OUT NOCOPY t_array_of_number,
        x_separator IN VARCHAR2
    ) RETURN NUMBER IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1))));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_number_array(h_num_items) := TO_NUMBER(RTRIM(LTRIM(h_sub_string)));

    END IF;

    RETURN h_num_items;

END ListToNumericArray;


FUNCTION ListToStringArray(
    x_string IN VARCHAR2,
    x_array IN OUT NOCOPY t_array_of_varchar2,
        x_separator IN VARCHAR2
    ) RETURN NUMBER IS

    h_num_items NUMBER := 0;

    h_sub_string VARCHAR2(32700);
    h_position NUMBER;

BEGIN

    IF x_string IS NOT NULL THEN
        h_sub_string := x_string;
        h_position := INSTR(h_sub_string, x_separator);

        WHILE h_position <> 0 LOOP
            h_num_items := h_num_items + 1;
            x_array(h_num_items) := RTRIM(LTRIM(SUBSTR(h_sub_string, 1, h_position - 1)));

            h_sub_string := SUBSTR(h_sub_string, h_position + 1);
            h_position := INSTR(h_sub_string, x_separator);
        END LOOP;

        h_num_items := h_num_items + 1;
        x_array(h_num_items) := RTRIM(LTRIM(h_sub_string));

    END IF;

    RETURN h_num_items;

END ListToStringArray;


PROCEDURE Add_To_Fnd_Msg_Stack
(p_error_tbl    IN  BIS_UTILITIES_PUB.ERROR_TBL_TYPE
,x_msg_count    OUT NOCOPY     NUMBER
,x_msg_data     OUT NOCOPY     VARCHAR2
,x_return_status   OUT NOCOPY     VARCHAR2
)
IS
BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
       FOR l_Count in 1..p_error_tbl.COUNT LOOP
           FND_MESSAGE.SET_NAME('BIS',p_error_tbl(l_count).error_msg_name);

       -- mdamle 08/06/2003 - Add tokens and values
       if (p_error_tbl(l_count).error_token1 is not null) then
        FND_MESSAGE.SET_TOKEN(p_error_tbl(l_count).error_token1, p_error_tbl(l_count).error_value1);
       end if;

       if (p_error_tbl(l_count).error_token2 is not null) then
        FND_MESSAGE.SET_TOKEN(p_error_tbl(l_count).error_token2, p_error_tbl(l_count).error_value2);
       end if;
       if (p_error_tbl(l_count).error_token3 is not null) then
        FND_MESSAGE.SET_TOKEN(p_error_tbl(l_count).error_token3, p_error_tbl(l_count).error_value3);
       end if;

           FND_MSG_PUB.Add;
       END LOOP;
-- Fix for 2332823
          FND_MSG_PUB.Count_And_Get
          ( p_count    =>  x_msg_count,
            p_data    =>  x_msg_data
          );
/*
-- Fix for 2254597 starts here
      x_msg_count := p_error_tbl.count;
      x_msg_data  := p_error_tbl(p_error_tbl.count).error_description;
-- Fix for 2254597 ends here
*/
    END IF;
END ADD_TO_FND_MSG_STACK;

/*********************************************************************************/
FUNCTION is_Internal_User
RETURN BOOLEAN IS
    l_internal      VARCHAR2(30);
BEGIN
    SELECT FND_PROFILE.VALUE('BSC_INTERNAL_USER') INTO l_internal FROM DUAL;
    IF((l_internal IS NOT NULL) AND (UPPER(l_internal) = 'YES')) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END is_Internal_User;
/*********************************************************************************/



/**************************************************************************************
FUNCTION get_Next_DispName

Function to generated names as required by Bug 3137260 , for example if Country
is passed we will get 'Country 1' if 'Country 5' is passed, we will get
'Country 6', if 'Country A' is passed, we will get 'Country A 1', etc.
**************************************************************************************/

FUNCTION get_Next_DispName
(
    p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
    l_alias      VARCHAR2(255);
    l_number     NUMBER;
    l_return     VARCHAR2(255);
    l_count      NUMBER;
    l_count1     NUMBER;
    l_tempcnt    NUMBER;
    l_tempalias  VARCHAR2(255);
    l_isNumber   VARCHAR2(255);
BEGIN
    IF (p_Alias IS NULL) THEN
        l_return :=  'A';
    ELSE
        l_count  := LENGTH(p_Alias);

        if(l_count > 255) THEN
           l_alias  := SUBSTR(p_Alias, 1, 250); -- Reduce the size to 250 chars
        else
           l_alias  := p_Alias;
        end if;

        l_count1 := INSTR(p_Alias, ' ');
        l_tempcnt := 0;
        l_tempalias := p_Alias;
        l_number := 0;

        while(l_count1 > 0) loop
          l_tempcnt := l_tempcnt + l_count1;
          l_count := LENGTH(l_tempalias);
          l_tempalias := SUBSTR(l_tempalias, l_count1+1, l_count);
          l_count1 := INSTR(l_tempalias, ' ');
          l_number := l_number + 1;
        end loop;
        l_count  := LENGTH(p_Alias);
        l_tempalias := RTRIM(LTRIM(l_tempalias));

        select replace(translate(l_tempalias,'0123456789.','???????????'), '?', '')
        into l_isNumber
        from dual;

        if(l_number = 0 or (l_isNumber is not null)) then
           l_return := l_alias ||' '||TO_CHAR(1);
        else
           l_alias  := SUBSTR(l_alias, 1, l_tempcnt-1);
           l_return := l_alias ||' '||TO_CHAR(TO_NUMBER(l_tempalias)+1);
        end if;
    END IF;
    RETURN l_return;
END get_Next_DispName;

/**************************************************************************************
**************************************************************************************/

FUNCTION get_Next_Name (
   p_Name           IN   VARCHAR2
  ,p_Max_Count      IN   NUMBER
  ,p_Table_Name     IN   VARCHAR2
  ,p_Column_Name    IN   VARCHAR2
  ,p_Character      IN   CHAR
) RETURN VARCHAR2
IS
  l_sql VARCHAR2(32000);
  l_Name VARCHAR2(2000);
  l_Count  NUMBER := 0;
  l_Loop_Count NUMBER := 1;
  TYPE c_cur_type IS REF CURSOR;
  cd c_cur_type;
BEGIN
  l_sql := 'SELECT COUNT(1) FROM '|| p_Table_Name || ' WHERE ' || p_Column_Name ||' = :1';
  OPEN cd FOR l_sql USING p_Name ;
  FETCH cd INTO l_Count;
  CLOSE cd;

  l_Name := p_Name;
  IF l_Count = 0 THEN
    RETURN p_Name;
  END IF;

  WHILE l_Count > 0 LOOP
    l_Name := p_Name || p_Character || l_Loop_Count;
    l_Loop_Count := l_Loop_Count + 1;
    IF LENGTH(l_Name) > p_Max_Count THEN
      l_Name := SUBSTR(p_Name , 0, (LENGTH(p_Name) - (LENGTH(l_Name) - p_Max_Count))) || p_Character || l_Count;
    END IF;
    l_sql := 'SELECT COUNT(1) FROM '|| p_Table_Name || ' WHERE ' || p_Column_Name ||' = :1';
    OPEN cd FOR l_sql USING l_Name ;
    FETCH cd INTO l_Count;
    CLOSE cd;

  END LOOP;
  RETURN l_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN p_Name;
END get_Next_Name;

/**************************************************************************************/

/*********************************************************************************
                            FUNCTION isBscInProductionMode
*********************************************************************************/
FUNCTION isBscInProductionMode
RETURN BOOLEAN
IS
    l_property_value            BSC_SYS_INIT.Property_Value%TYPE;

    CURSOR  c_isBscInProductionMode  IS
    SELECT  Property_Value
    FROM    BSC_SYS_INIT
    WHERE   PROPERTY_CODE ='SYSTEM_STAGE';
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIM_OBJ_PUB.isBscInProductionMode Function');
    IF (c_isBscInProductionMode%ISOPEN) THEN
        CLOSE c_isBscInProductionMode;
    END IF;
    OPEN    c_isBscInProductionMode;
    FETCH   c_isBscInProductionMode
    INTO    l_property_value;

    CLOSE c_isBscInProductionMode;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIM_OBJ_PUB.isBscInProductionMode Function');
    IF (l_property_value = '2') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS <'||SQLERRM||'>');
    IF (c_isBscInProductionMode%ISOPEN) THEN
        CLOSE c_isBscInProductionMode;
    END IF;
    RETURN FALSE;
END;
/*********************************************************************************/
FUNCTION is_MV_Exists(
    p_MV_Name  IN VARCHAR2
) RETURN BOOLEAN
IS
    l_Count         NUMBER   := 0;
    l_Tab_Name      VARCHAR2(100);
BEGIN
    IF (p_MV_Name IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_Tab_Name  :=  UPPER(TRIM(p_MV_Name));
    --Bug#3431750 appended schema name
    SELECT COUNT(*) INTO l_Count
    FROM   ALL_MVIEWS
    WHERE  MVIEW_NAME = l_Tab_Name
    AND OWNER = BSC_APPS.get_user_schema;

    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_MV_Exists;
/*********************************************************************************/
FUNCTION is_View_Exists(
    p_View_Name  IN VARCHAR2
) RETURN BOOLEAN
IS
    l_Count         NUMBER   := 0;
    l_Tab_Name      VARCHAR2(100);
BEGIN
    IF (p_View_Name IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_Tab_Name  :=  UPPER(TRIM(p_View_Name));
    SELECT COUNT(0) INTO l_Count
    FROM   ALL_VIEWS
    WHERE  VIEW_NAME = l_Tab_Name
    AND OWNER = BSC_APPS.get_user_schema('APPS');

    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_View_Exists;
/*********************************************************************************/
FUNCTION is_Table_Exists(
    p_Table_Name  IN VARCHAR2
) RETURN BOOLEAN
IS
    l_Count         NUMBER   := 0;
    l_Tab_Name      VARCHAR2(100);
BEGIN
    IF (p_Table_Name IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_Tab_Name  :=  UPPER(TRIM(p_Table_Name));
    SELECT COUNT(0) INTO l_Count
    FROM   ALL_TABLES
    WHERE  TABLE_NAME = l_Tab_Name
    AND OWNER = get_owner_for_object(p_Table_Name);
    IF (l_Count <> 0) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_Table_Exists;
/*********************************************************************************/
FUNCTION is_Table_View_Exists(
    p_Table_View_Name  IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
    IF (BSC_UTILITY.is_View_Exists(p_Table_View_Name)) THEN
        RETURN TRUE;
    ELSIF (BSC_UTILITY.is_Table_Exists(p_Table_View_Name)) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_Table_View_Exists;

/*********************************************************************************/

FUNCTION get_owner_for_object(
   p_object_name IN VARCHAR2

) RETURN VARCHAR2 IS

  l_owner       VARCHAR2(100);
  l_object_type VARCHAR2(100);
  l_object_name VARCHAR2(256);

  CURSOR c_object_type(c_object_name VARCHAR2)
  IS
  SELECT object_type
  FROM user_objects
  WHERE object_name =  c_object_name;

  CURSOR c_owner(c_syn_name VARCHAR2)
  IS
  SELECT table_owner
  FROM user_synonyms
  WHERE synonym_name = c_syn_name;

BEGIN

  l_object_name := UPPER(p_object_name);

  IF (c_object_type%ISOPEN)  THEN
    CLOSE c_object_type;
  END IF;

  OPEN c_object_type(l_object_name);
  FETCH c_object_type INTO l_object_type;
  CLOSE c_object_type;

  IF (l_object_type = 'VIEW') THEN
    -- view always in apps schema
    l_owner := BSC_APPS.get_user_schema('APPS');
  ELSE
    -- table then it should be synonym
    IF (c_owner%ISOPEN)  THEN
      CLOSE c_owner;
    END IF;

    OPEN c_owner(l_object_name);
    FETCH c_owner INTO l_owner;
    CLOSE c_owner;

    IF(l_owner IS NULL) THEN
      l_owner := BSC_APPS.get_user_schema('APPS');
    END IF;
  END IF;

  RETURN l_owner;
EXCEPTION
  WHEN OTHERS THEN

    IF (c_object_type%ISOPEN)  THEN
        CLOSE c_object_type;
    END IF;
    IF (c_owner%ISOPEN)  THEN
          CLOSE c_owner;
    END IF;
    RAISE;
END get_owner_for_object;


-- Added by ADRAO for End-To-End KPI Project
/*********************************************************************************/
FUNCTION is_Indicator_In_Production(
    p_kpi_id  IN NUMBER
) RETURN BOOLEAN IS

  CURSOR c_Production IS
    SELECT PROTOTYPE_FLAG
    FROM   BSC_KPIS_B
    WHERE  INDICATOR = p_Kpi_Id;

  l_Prototype_Flag   NUMBER;
BEGIN

   l_Prototype_Flag := 2;

   FOR ckpi IN c_Production LOOP
     l_Prototype_Flag := ckpi.Prototype_Flag;
   END LOOP;

   IF ((l_Prototype_Flag = 0) OR (l_Prototype_Flag = 2)) THEN
        RETURN TRUE;
   ELSE
        RETURN FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
    RETURN TRUE;
END is_Indicator_In_Production;
/*********************************************************************************/

/*********************************************************************************

   This API Is_BSC_Licensed() returns "T" if BSC is licensed otherwise returns "F"

*********************************************************************************/

FUNCTION Is_BSC_Licensed
RETURN VARCHAR2 IS
  l_Application_Short_Name  FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
  l_Status                  FND_PRODUCT_INSTALLATIONS.STATUS%TYPE;
  l_Industry                FND_PRODUCT_INSTALLATIONS.INDUSTRY%TYPE;
  l_Oracle_Schema           FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;

  l_Return                  VARCHAR2(1);
  l_Function_Return         BOOLEAN;

BEGIN

  l_Application_Short_Name := BSC_UTILITY.c_BSC;

  l_Function_Return := FND_INSTALLATION.Get_App_Info
                       (
                          Application_Short_Name => l_Application_Short_Name
                        , Status                 => l_Status
                        , Industry               => l_Industry
                        , Oracle_Schema          => l_Oracle_Schema
                       );

  IF (l_Function_Return = TRUE) THEN
    IF( (l_Status = 'L') OR (l_Status = 'S') OR (l_Status = 'I')) THEN
       RETURN FND_API.G_TRUE;
    ELSE
       RETURN FND_API.G_FALSE;
    END IF;
  ELSE
    RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       RETURN FND_API.G_FALSE;

END Is_BSC_Licensed;



/*********************************************************************************

   This API returns 'T' if the Advance Summarization is set >= 0, else returns 'F'

   Added for Start-to-End KPI Project.
*********************************************************************************/

FUNCTION Is_Adv_Sum_Enabled
RETURN VARCHAR2 IS
  l_Profile_Value VARCHAR2(10);
BEGIN

  SELECT FND_PROFILE.VALUE(c_ADV_SUMMARIZATION_LEVEL)
  INTO   l_Profile_Value
  FROM   DUAL;

  IF (TO_NUMBER(NVL(l_Profile_Value, '-1')) >= 0) THEN
      RETURN FND_API.G_TRUE;
  ELSE
      RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN FND_API.G_FALSE;

   WHEN OTHERS THEN
       RETURN FND_API.G_FALSE;

END Is_Adv_Sum_Enabled;


/*********************************************************************************

   This API returns 'T' if table BSC_SYS_INIT.adv_sum_level is set >= 0, else returns 'F'

   Added for Start-to-End KPI Project.
*********************************************************************************/

FUNCTION Is_Init_Adv_Sum_Enabled
RETURN VARCHAR2 IS
  l_Profile_Value VARCHAR2(10);
BEGIN

  SELECT property_value
  INTO l_Profile_Value
  FROM BSC_SYS_INIT
  WHERE property_code = 'ADV_SUM_LEVEL';

  IF (TO_NUMBER(NVL(l_Profile_Value, '-1')) >= 0) THEN
      RETURN FND_API.G_TRUE;
  ELSE
      RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN FND_API.G_FALSE;

   WHEN OTHERS THEN
       RETURN FND_API.G_FALSE;

END Is_Init_Adv_Sum_Enabled;


/*********************************************************************************

   This API returns 'T' if the Advance Summarization is set >= 0 or
   if table BSC_SYS_INIT.adv_sum_level is set >= 0, else returns 'F'

   Added for Start-to-End KPI Project.
*********************************************************************************/

FUNCTION Is_Adv_Summarization_Enabled
RETURN VARCHAR2 IS
  l_Profile_Value VARCHAR2(10);
BEGIN

  IF (Is_Adv_Sum_Enabled = FND_API.G_TRUE) THEN
      RETURN FND_API.G_TRUE;
  ELSIF (Is_Init_Adv_Sum_Enabled = FND_API.G_TRUE) THEN
      RETURN FND_API.G_TRUE;
  ELSE
      RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       RETURN FND_API.G_FALSE;

   WHEN OTHERS THEN
       RETURN FND_API.G_FALSE;

END Is_Adv_Summarization_Enabled;


/*********************************************************************************
 This funciton is added to get the no of independent dimension objects in a
 dimension set of an Objective
    Input Parameters:-
       p_kpi_id         :- Objective Id
       p_dim_set_id     :- Dimension set Id
*********************************************************************************/
FUNCTION get_nof_independent_dimobj
(         p_Kpi_Id          IN   NUMBER
     ,    p_Dim_Set_Id      IN   NUMBER
)RETURN NUMBER IS
  l_count            NUMBER;
  l_souce            VARCHAR2(100);
  l_Flag             BOOLEAN := FALSE;
  l_Short_Name       BSC_KPIS_B.SHORT_NAME%TYPE;
  l_Is_EndToEnd_Kpi  VARCHAR2(2);

  CURSOR  c_source IS
  SELECT  DISTINCT(sys.source)  source
  FROM    bsc_sys_dim_levels_b sys,
          bsc_kpi_dim_level_properties kpi
  WHERE   sys.dim_level_id = kpi.dim_level_id
  AND     kpi.INDICATOR = p_Kpi_Id
  AND     kpi.dim_set_id = p_Dim_Set_Id;

BEGIN
  l_count := 0;
  FOR c_rec IN c_source
  LOOP
    IF(c_rec.source = 'BSC') THEN
      l_Flag := TRUE;
      EXIT;
    ELSIF(c_rec.source = 'PMF') THEN
      SELECT short_name
      INTO l_Short_Name
      FROM  BSC_KPIS_B
      WHERE indicator= p_Kpi_Id;
      l_Is_EndToEnd_Kpi := BSC_BIS_KPI_CRUD_PUB.IS_KPI_ENDTOEND_KPI(l_Short_Name);
      IF(l_Is_EndToEnd_Kpi = 'T') THEN
        l_Flag := TRUE;
        EXIT;
      END IF;
    END IF;
  END LOOP;

  IF(l_Flag = TRUE)THEN
    SELECT COUNT(0) into l_count
    FROM (
    (SELECT dim_level_index
    FROM   bsc_kpi_dim_levels_b
    WHERE  INDICATOR = p_kpi_id
    AND    dim_set_id = p_dim_set_id )
    MINUS
    ((SELECT DISTINCT (parent_level_index)
    FROM   bsc_kpi_dim_levels_b
    WHERE  INDICATOR = p_kpi_id
    AND    dim_set_id = p_dim_set_id
    AND    parent_level_index IS NOT NULL)
    UNION
    (SELECT  dim_level_index
    FROM    bsc_kpi_dim_levels_b
    WHERE   INDICATOR = p_kpi_id
    AND     dim_set_id = p_dim_set_id
    AND     parent_level_index IS NOT NULL)));
  END IF;

  return l_count;

END get_nof_independent_dimobj;

/*********************************************************************************/




/*********************************************************************************
  Return default internal name based on p_type. Currently supported type:
  bsc_utility.c_BSC_MEASURE,
  bsc_utility.c_BSC_DIMENSION,
  bsc_utility.c_BSC_DIM_OBJECT

    Input Parameters:-
        p_type    :- one of the supported types
*********************************************************************************/
FUNCTION Get_Default_Internal_Name(
  p_type                IN      VARCHAR2
)RETURN VARCHAR2 IS
l_next                          NUMBER := 0;
l_type                          VARCHAR2(15);
l_ret_val                       VARCHAR2(30);
l_msg_data                      VARCHAR2(10);
l_msg_count                     NUMBER;
BEGIN
  l_type := UPPER(p_type);
  IF (l_type = bsc_utility.c_BSC_MEASURE) THEN
    SELECT NVL(MAX(dataset_id) + 1, 0)
    INTO   l_next
    FROM   BSC_SYS_DATASETS_TL;
    l_ret_val := bsc_bis_measure_pub.c_PMD || l_next;

  ELSIF (l_type = bsc_utility.c_BSC_DIMENSION) THEN
    SELECT NVL(MAX(dim_group_id) + 1, 0)
    INTO   l_next
    FROM   BSC_SYS_DIM_GROUPS_TL;
    l_ret_val := bsc_bis_dimension_pub.c_BSC_DIM || l_next;

  ELSIF (l_type = bsc_utility.c_BSC_DIM_OBJ) THEN
    SELECT NVL(MAX(dim_level_id) + 1, 0)
    INTO   l_next
    FROM   BSC_SYS_DIM_LEVELS_B;
    l_ret_val := bsc_bis_dim_obj_pub.c_BSC_DIM_OBJ || l_next;
  END IF;

  RETURN l_ret_val;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get( p_count  =>      l_msg_count
                              ,p_data   =>      l_msg_data);
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    RAISE;
  WHEN NO_DATA_FOUND THEN
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    RAISE;
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get( p_count    =>      l_msg_count
                              ,p_data     =>      l_msg_data);
    RAISE;
END Get_Default_Internal_Name;



/************************************************************
Name        :- Parse_String
Description :- This function will parse the comma separated String
               and return the table containing the data
               Before using this API check if p_List is NULL or not
               and lenght(p_List) must be >0.and
Creaor      :- Ashankar to fix the bug  3908204
/*****************************************************************/

PROCEDURE Parse_String
(
     p_List          VARCHAR2
  ,  p_Separator    VARCHAR2
  ,  p_List_Data     OUT NOCOPY BSC_UTILITY.varchar_tabletype
  ,  p_List_number   OUT NOCOPY NUMBER
) IS

 l_start    NUMBER;
 l_end      NUMBER;
 l_len      NUMBER;
BEGIN

  p_List_number:=0;
  l_len:=LENGTH(p_List);

  IF (INSTR(p_List,p_Separator)=0) THEN
     p_List_number:=1;
     p_List_Data(p_List_number):=TRIM(p_List);
  ELSE
    l_start:=1;
    LOOP
      l_end:=INSTR(p_List,p_Separator,l_start);
      IF(l_end = 0 ) THEN
        l_end:=l_len+1;
      END IF;
      p_List_number:=p_List_number+1;
      p_List_Data(p_List_number):=TRIM(SUBSTR(p_List,l_start,(l_end-l_start)));
      l_start:=l_end+1;
      IF (l_end>=l_len) THEN
        EXIT;
      END IF;
    END LOOP;
  END IF;
END Parse_String;

/************************************************************
Name        :- get_Next_Alias
Description :- This function will retrun the next alias which
               can be sufuxed to short_names and Names.
               It can be used to check the uniqueness of short_names
               or names
Creaor      :- Ashankar to fix the bug  4054812
/*****************************************************************/

FUNCTION get_Next_Alias
(
  p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_alias     VARCHAR2(3);
  l_return    VARCHAR2(3);
  l_count     NUMBER;
BEGIN
  IF (p_Alias IS NULL) THEN
    l_return :=  'A';
  ELSE
    l_count := LENGTH(p_Alias);
    IF (l_count = 1) THEN
      l_return   := 'A0';
    ELSIF (l_count > 1) THEN
      l_alias     :=  SUBSTR(p_Alias, 2);
      l_count     :=  TO_NUMBER(l_alias)+1;
      l_return    :=  'A'||TO_CHAR(l_count);
    END IF;
  END IF;
  RETURN l_return;

END get_Next_Alias;


/*********************************************************************************
         API TO CHECK IF MIXED DIMENSION OBJECTS SHOULD BE ALLOWED AT THE
         DIMENSION AND DIMENSION SET LEVEL
*********************************************************************************/

FUNCTION is_Mix_Dim_Objects_Allowed
RETURN VARCHAR2 IS
   l_Return VARCHAR2(1);
   l_Count  NUMBER;
BEGIN
   l_Count := 0;
   l_Return := FND_API.G_FALSE;

   SELECT COUNT(1) INTO l_Count
   FROM   BSC_SYS_INIT B
   WHERE  B.PROPERTY_CODE  = c_MIXED_DIM_OBJS
   AND    B.PROPERTY_VALUE > 0;

   IF (l_Count > 0) THEN
      l_Return := FND_API.G_TRUE;
   END IF;

   RETURN l_Return;

EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_API.G_FALSE;
END is_Mix_Dim_Objects_Allowed;

FUNCTION get_valid_bsc_master_tbl_name
(
 p_short_name IN VARCHAR2
)
RETURN VARCHAR2 IS
l_found       BOOLEAN;
l_alias       VARCHAR2(30);
l_count       NUMBER;
l_table_name  BSC_SYS_DIM_LEVELS_B.LEVEL_TABLE_NAME%TYPE;
BEGIN
  l_found      := TRUE;
  l_alias      := NULL;
  l_table_name := 'BSC_D_' || SUBSTR(UPPER(REPLACE(p_short_name, ' ', '_')) , 1, 22) || '_V';
  WHILE (l_found) LOOP
    SELECT COUNT(1)
    INTO   l_count
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  Level_Table_Name = l_table_name
    AND short_name <> p_short_name ;
    IF (l_count = 0) THEN
      l_found := FALSE;
    END IF;
    IF(l_found) THEN
      l_alias      := bsc_utility.get_Next_Alias(l_alias);
      l_table_name := 'BSC_D_' ||SUBSTR(UPPER(REPLACE(p_short_name, ' ', '_')) , 1, 18)||l_alias|| '_V';
    END IF;
  END LOOP;

  RETURN l_table_name;

END get_valid_bsc_master_tbl_name;

/*
API to return if the Dimension Object and Dimension passed form a Periodicity type
*/

FUNCTION Is_Time_Period_Type (
    p_Dimension_Short_Name        IN VARCHAR2
  , p_Dimension_Object_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;
    l_Sql   VARCHAR2(300);
BEGIN

    -- Using dyanamic query, since BSC52 maynot have the data model changes for the SHORT_NAME
    l_Sql := ' SELECT COUNT(1) ' ||
             ' FROM BSC_SYS_CALENDARS_B BC, BSC_SYS_PERIODICITIES BP ' ||
             ' WHERE  BC.SHORT_NAME  = :1 AND BP.SHORT_NAME  = :2 ' ||
             ' AND    BP.CALENDAR_ID = BC.CALENDAR_ID ';

    EXECUTE IMMEDIATE l_Sql INTO l_Count USING p_Dimension_Short_Name, p_Dimension_Object_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Time_Period_Type;


/*
API to return if the Dimension passed form a Periodicity type
*/

FUNCTION is_dim_time_period_type (
  p_dimension_short_name  IN VARCHAR2
)
RETURN VARCHAR2
IS
  l_count NUMBER;
  l_sql   VARCHAR2(300);
BEGIN

  -- Using dyanamic query, since BSC52 maynot have the data model changes for the SHORT_NAME
  l_sql := ' SELECT COUNT(1) ' ||
           ' FROM BSC_SYS_CALENDARS_B BC ' ||
           ' WHERE  BC.SHORT_NAME  = :1 ';

  EXECUTE IMMEDIATE l_sql INTO l_Count USING p_dimension_short_name;

  IF (l_count <> 0) THEN
    RETURN FND_API.G_TRUE;
  END IF;

  RETURN FND_API.G_FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END is_dim_time_period_type;


/*
API to return if the Dimension Object of a Periodicity type
*/

FUNCTION Is_Dim_Object_Periodicity_Type (
    p_Dimension_Object_Short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;
    l_Sql   VARCHAR2(300);
BEGIN

    l_Sql := ' SELECT COUNT(1) ' ||
             ' FROM BSC_SYS_PERIODICITIES BP ' ||
             ' WHERE BP.SHORT_NAME = :1 ' ;

    EXECUTE IMMEDIATE l_Sql INTO l_Count USING p_Dimension_Object_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Dim_Object_Periodicity_Type;

/*********************************************************************************
         API TO CHECK IF DIMENSION/DIMENSION OBJECTS SHOULD BE ALLOWED AT THE
         DIMENSION AND DIMENSION SET LEVEL
         Type- DIMENSION, DIMENSION_OBJECT, MIX(DIMENSION+DIMENSION_OBJECT).
         entity_short_name- comman seperated short_names.
*********************************************************************************/

PROCEDURE Enable_Dimensions_Entity (
    p_Entity_Type           IN VARCHAR2
  , p_Entity_Short_Names    IN VARCHAR2
  , p_Entity_Action_Type    IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
) IS
    l_Count         NUMBER;
    l_Sql           VARCHAR2(2000);
    l_Entity_Name   VARCHAR2(300);
    l_Short_Name    VARCHAR2(100);
    l_pos_value     NUMBER;
    l_temp_snames   VARCHAR2(2000);
    l_dim_sname     VARCHAR2(30);
    l_dim_obj_sname VARCHAR2(30);
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF ((p_Entity_Short_Names IS NULL) OR (BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE)) THEN
        RETURN;
    END IF;

    l_temp_snames := p_Entity_Short_Names;
    WHILE (Is_More(l_temp_snames, l_Short_Name)) LOOP

            IF(p_Entity_Type = c_MIXED_DIM_OBJS) THEN
              -- each Dimension/Dimension Object combination split that and call API individually.
                l_pos_value           := INSTR(l_Short_Name,   '+');
                IF (l_pos_value > 0) THEN
                    l_dim_sname      :=  TRIM(SUBSTR(l_Short_Name,    1,    l_pos_value - 1));
                    l_dim_obj_sname   :=  TRIM(SUBSTR(l_Short_Name,    l_pos_value + 1));
                    l_Entity_Name := null;
                    Enable_Dimension_Entity (
                          p_Entity_Type           => c_DIMENSION
                          , p_Entity_Short_Name   => l_dim_sname
                          , p_Entity_Action_Type  => p_Entity_Action_Type
                          , p_Entity_Name         => null
                          , x_Return_Status       => x_Return_Status
                          , x_Msg_Count           => x_Msg_Count
                          , x_Msg_Data            => x_Msg_Data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    l_Entity_Name := null;
                    Enable_Dimension_Entity (
                          p_Entity_Type           => c_DIMENSION_OBJECT
                          , p_Entity_Short_Name   => l_dim_obj_sname
                          , p_Entity_Action_Type  => p_Entity_Action_Type
                          , p_Entity_Name         => null
                          , x_Return_Status       => x_Return_Status
                          , x_Msg_Count           => x_Msg_Count
                          , x_Msg_Data            => x_Msg_Data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                 END IF;

            ELSE
              -- fetch the entity name.
              l_Entity_Name := null;
              Enable_Dimension_Entity (
                  p_Entity_Type           => p_Entity_Type
                  , p_Entity_Short_Name   => l_Short_Name
                  , p_Entity_Action_Type  => p_Entity_Action_Type
                  , p_Entity_Name         => null
                  , x_Return_Status       => x_Return_Status
                  , x_Msg_Count           => x_Msg_Count
                  , x_Msg_Data            => x_Msg_Data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                  RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
    END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Enable_Dimensions_Entity;

FUNCTION Get_Name(
    p_Entity_Type           IN VARCHAR2
  , p_Entity_Short_Name     IN VARCHAR2
) RETURN VARCHAR IS
    l_name VARCHAR2(400);
BEGIN
    IF(p_Entity_Type = c_DIMENSION_OBJECT) THEN
        SELECT NAME
        INTO l_name
        FROM BSC_SYS_DIM_LEVELS_VL
        WHERE SHORT_NAME = p_Entity_Short_Name;
    ELSE
        SELECT NAME
        INTO l_name
        FROM BSC_SYS_DIM_GROUPS_VL
        WHERE SHORT_NAME = p_Entity_Short_Name;
    END IF;
    RETURN l_name;
END;


/****************************************************************************************************
This functions retuns error message, for a given dimension short_name if:
1. Dimension is Autogenerated Dimension (Report Designer).
2. If Dimension is import Dimension (created while importing a BIS report in BSC)
3. Dimension is Weighted Report Dimension (Report Designer).
else returns null.
****************************************************************************************************/
FUNCTION Is_Internal_Dim(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
    l_Msg   VARCHAR2(80);
BEGIN
    l_Msg := Is_Internal_AG_Dim(p_Short_Name);
    IF (l_Msg IS NOT NULL) THEN
      RETURN l_Msg;
    END IF;

    l_Msg := Is_Internal_BIS_Import_Dim(p_Short_Name);
    IF (l_Msg IS NOT NULL) THEN
      RETURN l_Msg;
    END IF;

    -- Condition for Dimension Group created/used in Weighted Report or VB Report.
    l_Msg := Is_Internal_WKPI_Dim(p_Short_Name);
    IF (l_Msg IS NOT NULL) THEN
      RETURN l_Msg;
    END IF;

    l_Msg := Is_Internal_VB_Dim(p_Short_Name);
    IF (l_Msg IS NOT NULL) THEN
      RETURN l_Msg;
    END IF;

    RETURN NULL;
END Is_Internal_Dim;


/****************************************************************************************************
The following three apis are taken from Is_Internal_Dim. They are required for fixes of bug#4602231
where the Dimension LOV window will only call Is_Internal_AG_Dim and Is_Internal_BIS_Import_Dim
to boost LOV performance. Is_Internal_WKPI_Dim is causing performance issue since it queries
ak_regions without using indexed columns.
****************************************************************************************************/
FUNCTION Is_Internal_AG_Dim(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_DIM_GROUPS_VL B
         , BSC_KPIS_B            K
         , BSC_KPI_DIM_GROUPS    G
    WHERE B.SHORT_NAME = p_Short_Name
    AND   K.SHORT_NAME = B.SHORT_NAME
    AND   G.INDICATOR  = K.INDICATOR;

    IF (l_Count <> 0) THEN
        RETURN 'BIS_DIM_ASSIGN_AGREPORT';
    END IF;

    RETURN null;
END Is_Internal_AG_Dim;


FUNCTION Is_Internal_BIS_Import_Dim(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO l_Count
    FROM BSC_SYS_DIM_GROUPS_VL d,
    BSC_KPI_DIM_GROUPS k
    WHERE d.DIM_GROUP_ID = k.DIM_GROUP_ID
    AND BSC_BIS_DIMENSION_PUB.Get_Dimension_Source(d.SHORT_NAME)=BSC_UTILITY.c_PMF
    AND d.SHORT_NAME=p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN 'BIS_DIM_IMPORT_DIM';
    END IF;

    RETURN null;
END Is_Internal_BIS_Import_Dim;


FUNCTION Is_Internal_WKPI_Dim(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    -- Condition for Dimension Group created/used in Weighted Report.
    SELECT COUNT(1)
    INTO l_Count
    FROM ak_regions
    WHERE attribute_category = BSC_UTILITY.C_ATTRIBUTE_CATEGORY
    AND attribute10 = BSC_UTILITY.C_REPORT_TYPE_MDS
    AND attribute12 = p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN 'BIS_DIM_ASSIGN_AGREPORT';
    END IF;

    RETURN NULL;
END Is_Internal_WKPI_Dim;

FUNCTION Is_Internal_VB_Dim(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    -- Condition for Dimension Group created/used in Table Based Report.
    SELECT COUNT(1)
    INTO l_Count
    FROM ak_regions
    WHERE attribute_category = BSC_UTILITY.C_ATTRIBUTE_CATEGORY
    AND attribute10 = BSC_UTILITY.C_REPORT_TYPE_TABLE
    AND attribute12 = p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN 'BIS_DIM_ASSIGN_TABLEREPORT';
    END IF;

    SELECT COUNT(1)
    INTO l_Count
    FROM ak_regions
    WHERE attribute_category = BSC_UTILITY.C_ATTRIBUTE_CATEGORY
    AND attribute10 IS NULL
    AND attribute12 = p_Short_Name;

    IF (l_Count <> 0) THEN
        RETURN 'BIS_DIM_ASSIGN_VIEWREPORT';
    END IF;

    RETURN NULL;
END Is_Internal_VB_Dim;


PROCEDURE Enable_Dimension_Entity (
    p_Entity_Type           IN VARCHAR2
  , p_Entity_Short_Name     IN VARCHAR2
  , p_Entity_Action_Type    IN VARCHAR2
  , p_Entity_Name           IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
) IS
    l_Count NUMBER;
    l_Sql   VARCHAR2(2000);
    l_tmp_EntityName VARCHAR2(4000);
    l_Return_Msg  VARCHAR2(30);
BEGIN
    -- pick the name if it is null.
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF ((p_Entity_Short_Name IS NULL) OR (BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE)) THEN
        RETURN;
    END IF;

    IF(p_Entity_Type = c_DIMENSION_OBJECT) THEN

    -- Check if it is associated to a Periodicity
        l_Sql := ' SELECT COUNT(1) FROM BIS_LEVELS L, BSC_SYS_PERIODICITIES P '
                 || ' WHERE L.SHORT_NAME = :1 '
                 || ' AND   P.SHORT_NAME = L.SHORT_NAME ';

        EXECUTE IMMEDIATE l_Sql INTO l_Count USING p_Entity_Short_Name;

        IF (l_Count <> 0) THEN
            IF (p_Entity_Name IS NULL) THEN
                l_tmp_EntityName := Get_Name(p_Entity_Type, p_Entity_Short_Name);
            ELSE
                l_tmp_EntityName := p_Entity_Name;
            END IF;
            FND_MESSAGE.SET_NAME('BIS','BIS_DIMOBJ_ASSIGN_PERIODS');
            FND_MESSAGE.SET_TOKEN('DIMOBJ', l_tmp_EntityName);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF (p_Entity_Type = c_DIMENSION) THEN
        l_Sql :=   ' SELECT COUNT(1) FROM BIS_DIMENSIONS D, BSC_SYS_CALENDARS_B C '
                 ||' WHERE D.SHORT_NAME = :1 AND C.SHORT_NAME = D.SHORT_NAME  ';

        EXECUTE IMMEDIATE l_Sql INTO l_Count USING p_Entity_Short_Name;

        IF (l_Count <> 0) THEN
            IF (p_Entity_Name IS NULL) THEN
                l_tmp_EntityName := Get_Name(p_Entity_Type, p_Entity_Short_Name);
            ELSE
                l_tmp_EntityName := p_Entity_Name;
            END IF;
            FND_MESSAGE.SET_NAME('BIS','BIS_DIM_ASSIGN_PERIODS');
            FND_MESSAGE.SET_TOKEN('DIM', l_tmp_EntityName);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_Return_Msg := Is_Internal_Dim(p_Entity_Short_Name);

        IF (l_Return_Msg IS NOT NULL) THEN
          IF (p_Entity_Name IS NULL) THEN
            l_tmp_EntityName := Get_Name(p_Entity_Type, p_Entity_Short_Name);
          ELSE
            l_tmp_EntityName := p_Entity_Name;
          END IF;
          FND_MESSAGE.SET_NAME('BIS',l_Return_Msg);
          FND_MESSAGE.SET_TOKEN('DIM', l_tmp_EntityName);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Enable_Dimension_Entity;

/*
  Verify whether the comma(,) separated dimensions are not internal
  dimensions created for WA report.
*/
PROCEDURE Check_Weighted_Dimension (
  p_Dim_Short_Names  IN VARCHAR2
, x_Return_Status    OUT NOCOPY VARCHAR2
, x_Msg_Count        OUT NOCOPY NUMBER
, x_Msg_Data         OUT NOCOPY VARCHAR2
) IS
  l_Entity_Name   VARCHAR2(300);
  l_Short_Name    VARCHAR2(100);
  l_temp_snames   VARCHAR2(2000);
  l_Return_Msg    VARCHAR2(100);
BEGIN
  FND_MSG_PUB.Initialize;

  l_temp_snames := p_Dim_Short_Names;
  WHILE (Is_More(l_temp_snames, l_Short_Name)) LOOP
    l_Return_Msg := Is_Internal_WKPI_Dim(l_Short_Name);
    IF (l_Return_Msg IS NOT NULL) THEN
      l_Entity_Name := Get_Name(c_DIMENSION, l_Short_Name);
      FND_MESSAGE.SET_NAME('BIS',l_Return_Msg);
      FND_MESSAGE.SET_TOKEN('DIM', l_Entity_Name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Check_Weighted_Dimension;


FUNCTION Is_More
(       p_comma_sep_values  IN  OUT NOCOPY  VARCHAR2
    ,   x_value             OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_values               NUMBER;
BEGIN
    IF (p_comma_sep_values IS NOT NULL) THEN
        l_pos_values           := INSTR(p_comma_sep_values, ',');
        IF (l_pos_values > 0) THEN
            x_value      :=  TRIM(SUBSTR(p_comma_sep_values,    1,    l_pos_values - 1));
            p_comma_sep_values   :=  TRIM(SUBSTR(p_comma_sep_values,  l_pos_values + 1));
        ELSE
            x_value      :=  TRIM(p_comma_sep_values);
            p_comma_sep_values     :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/****************************************************************************************************
This functions returns an unique time based short name .
It Prefixes the word based on type of the object sent in parameter p_Object_Type
****************************************************************************************************/
-- Bug#5034549; Added ABS() to DBMS_UTILITY.GET_TIME, since it can return negative value
FUNCTION Get_Unique_Sht_Name_By_Obj_Typ(p_Object_Type IN VARCHAR2)
RETURN VARCHAR2
IS
    l_Return_Short_Name VARCHAR2(30);
BEGIN
  IF(p_Object_Type = bsc_utility.c_BSC_MEASURE) THEN
    l_Return_Short_Name := bsc_utility.c_BSC_MEASURE_SHORT_NAME||TO_CHAR(SYSDATE,'J')||ABS(DBMS_UTILITY.GET_TIME);
  END IF;
  RETURN l_Return_Short_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Unique_Sht_Name_By_Obj_Typ;
/****************************************************************************************************/

FUNCTION Is_Internal_Dimension(p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Return_Msg  VARCHAR2(30);
BEGIN
  l_Return_Msg := Is_Internal_Dim(p_Short_Name);
  IF (l_Return_Msg IS NULL) THEN
    RETURN FND_API.G_FALSE;
  ELSE
    RETURN FND_API.G_TRUE;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_TRUE;
END Is_Internal_Dimension;


/****************************************************************************************************
Append_Report_List appends report_name to regions list,
and return true if added count reaches maximum limit of 10
****************************************************************************************************/

FUNCTION Append_Report_List(
    p_Report_Name     IN VARCHAR2
  , p_count           IN NUMBER
  , p_Regions         IN OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
BEGIN
  IF (p_Regions IS NULL) THEN
    p_Regions := p_Report_Name;
  ELSE
    p_Regions := p_Regions ||', '||p_Report_Name;
  END IF;
  IF (p_count >= 10) THEN
    p_Regions := p_Regions || ' ...';
    RETURN TRUE;
  END IF;

  RETURN FALSE;
END Append_Report_List;

/****************************************************************************************************
This API takes a comman separated list of dimension objects and returns the region Codes of all the
reports containing these dimension objects
p_Short_Names : Comma separated list of the dimension objects
x_region_codes: Table of region Codes containing the above dimension objects
****************************************************************************************************/
PROCEDURE Is_Dim_Obj_In_AKReport(
    p_Short_Names      IN VARCHAR2
  , x_region_codes     OUT NOCOPY FND_TABLE_OF_VARCHAR2_30
  , x_Return_Status    OUT NOCOPY VARCHAR2
  , x_Msg_Count        OUT NOCOPY NUMBER
  , x_Msg_Data         OUT NOCOPY VARCHAR2
) IS
    l_short_names  VARCHAR2(32000);
    l_sql               VARCHAR2(32000);
    l_attr2_sql         VARCHAR2(32000);
    l_region_sht_name   AK_REGIONS.REGION_CODE%TYPE;
    l_dim_obj_sht_name  BIS_LEVELS.SHORT_NAME%TYPE;
    l_count             NUMBER := 0;
    TYPE ref_cur IS REF CURSOR;
    c_regions_dim_obj   ref_cur;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF (p_Short_Names IS NOT NULL) THEN
        x_region_codes := FND_TABLE_OF_VARCHAR2_30();
        l_sql := 'SELECT DISTINCT REGION_CODE FROM ak_region_items  WHERE node_query_flag = ''Y'' AND node_display_flag = ''N'' AND SUBSTR(attribute2,INSTR(attribute2,''+'') +1 ,LENGTH(attribute2)) IN (' ;
        l_short_names := p_Short_Names;
        WHILE (BSC_UTILITY.is_more( l_short_names,l_dim_obj_sht_name)) LOOP
            l_attr2_sql := l_attr2_sql || '''' ||  l_dim_obj_sht_name  || ''',' ;
        END LOOP;
        IF(l_attr2_sql IS NOT NULL) THEN
          --Remove the additional comma at the end
          l_attr2_sql := SUBSTR(l_attr2_sql,0,LENGTH(l_attr2_sql) - 1);
          l_sql := l_sql || l_attr2_sql || ')';
          OPEN c_regions_dim_obj FOR l_sql;
          LOOP
            FETCH c_regions_dim_obj INTO l_region_sht_name;
            EXIT WHEN c_regions_dim_obj%NOTFOUND;
                x_region_codes.extend(l_count+1);
                x_region_codes(l_count+1) := l_region_sht_name;
                l_count := l_count + 1;
          END LOOP;
          CLOSE c_regions_dim_obj;
        END IF;
      END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Is_Dim_Obj_In_AKReport;

/****************************************************************************************************
Checkes if Report a Dimension or Dimension+Dimension Object is used in a Report.
p_Short_Name can have values 'DIMENSION' or 'MIXED_DIM_OBJS'
p_Short_name: For DIMENSION- Dimension short name should be passed.
              For MIXED_DIM_OBJS- <Dim shortname>+<Dim Object ShortName> should be passed.
****************************************************************************************************/
FUNCTION Is_Dim_In_AKReport(
    p_Short_Name     IN VARCHAR2
  , p_Entity_Type    IN VARCHAR2 := c_MIXED_DIM_OBJS
)
RETURN VARCHAR2 IS
    l_regions      VARCHAR2(32000);
    l_region       VARCHAR2(200);
    l_count        NUMBER;
    l_report_name  VARCHAR2(100);

    CURSOR c_regions_dim IS
    SELECT DISTINCT REGION_CODE
    FROM ak_region_items
    WHERE attribute2 LIKE p_Short_name ||'+%'
    AND attribute1 IN ('VIEWBY PARAMETER', 'DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE', 'HIDE VIEW BY DIMENSION');

    CURSOR c_regions_dim_grp IS
    SELECT region_code
    FROM ak_regions
    WHERE attribute12 = p_Short_Name;

    CURSOR c_regions_dim_obj IS
    SELECT DISTINCT REGION_CODE
    FROM ak_region_items
    WHERE attribute2 = p_Short_name
    AND attribute1 IN ('VIEWBY PARAMETER', 'DIMENSION LEVEL', 'DIM LEVEL SINGLE VALUE', 'HIDE VIEW BY DIMENSION');
BEGIN

  l_count := 1;
  IF(p_Entity_Type = c_DIMENSION) THEN
    FOR l_regions_val IN c_regions_dim LOOP
      l_report_name := Get_Report_Name(l_regions_val.REGION_CODE);
      IF(Append_Report_List(l_report_name, l_count, l_regions)) THEN
        EXIT;
      END IF;
      l_count := l_count + 1;
    END LOOP;

    IF (l_count < 10) THEN
      FOR l_regions_dim_grp_val IN c_regions_dim_grp LOOP
        l_report_name := Get_Report_Name(l_regions_dim_grp_val.REGION_CODE);

        IF(Append_Report_List(l_report_name, l_count, l_regions)) THEN
          EXIT;
        END IF;
        l_count := l_count + 1;
      END LOOP;
    END IF;
  ELSIF (p_Entity_Type = c_MIXED_DIM_OBJS) THEN
    FOR l_regions_val IN c_regions_dim_obj LOOP
      l_report_name := Get_Report_Name(l_regions_val.REGION_CODE);
      IF(Append_Report_List(l_report_name, l_count, l_regions)) THEN
        EXIT;
      END IF;
      l_count := l_count + 1;
    END LOOP;
  END IF;

  RETURN l_regions;
END Is_Dim_In_AKReport;


/****************************************************************************************************
Returns Report Name for given region_code.
First Checks if there is a form functions pointing to this Report
(Will pick first in case of multiple form functions)
Otherwise returns the ak_region name.
****************************************************************************************************/
FUNCTION Get_Report_Name(
    p_Region_Code     IN VARCHAR2
)
RETURN VARCHAR2 IS
  report_name    fnd_form_functions_vl.User_Function_Name%TYPE;

  CURSOR c_function_name IS
  SELECT user_function_name FROM fnd_form_functions_vl
  WHERE parameters like '%pRegionCode='|| p_Region_Code ||'%'
  AND rownum < 2;

  CURSOR c_region_name IS
  SELECT name FROM ak_regions_vl
  WHERE region_code = p_Region_Code;

BEGIN
  FOR c_function_name_val IN c_function_name LOOP
    report_name := c_function_name_val.user_function_name;
  END LOOP;

  IF (report_name IS NULL) THEN
    FOR c_region_name_val IN c_region_name LOOP
      report_name := c_region_name_val.name;
    END LOOP;
  END IF;

  return report_name;
END Get_Report_Name;

-- added for Bug#4563456
FUNCTION Get_Responsibility_Key
RETURN VARCHAR2 IS
    l_Resp_Key FND_RESPONSIBILITY.RESPONSIBILITY_KEY%TYPE;
BEGIN
    SELECT F.RESPONSIBILITY_KEY INTO l_Resp_Key
    FROM   FND_RESPONSIBILITY F
    WHERE  F.RESPONSIBILITY_ID = FND_GLOBAL.RESP_ID
    AND    F.APPLICATION_ID    = FND_GLOBAL.RESP_APPL_ID;

    RETURN l_Resp_Key;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Responsibility_Key;

-- added for Bug#4599432
FUNCTION Is_Measure_Seeded (p_Short_Name IN VARCHAR2)
RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    SELECT COUNT(1) INTO l_Count
    FROM   BIS_INDICATORS B
    WHERE  B.SHORT_NAME = p_Short_Name
    AND    BIS_UTIL.is_Seeded(B.CREATED_BY,'Y','N') = 'Y';

    IF (l_Count <> 0 AND NOT BIS_UTIL.Is_Internal_Customer) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_TRUE;
END Is_Measure_Seeded;


/****************************************************************
 Name   : Get_User_Time
 Input  : p_current_user_time (Current User Time)
          p_date_format       (Format in which the date is to be displayed)
 Output : out time in the desired format as specified by the user.
 Creation date : 05-OCT-2005
 Created By    : ashankar
/****************************************************************/
FUNCTION Get_User_Time
(
     p_current_user_time  IN DATE
   , p_date_format        IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN

RETURN TO_CHAR(fnd_timezones_pvt.adjust_datetime
               (
                  date_time  => p_current_user_time
                , from_tz    => fnd_timezones.get_server_timezone_code
                , to_tz      => fnd_timezones.get_client_timezone_code
               ),p_date_format
              );
EXCEPTION
    WHEN OTHERS THEN
    RETURN NULL;
END Get_User_Time;


/****************************************************************************************************

 Implementation of SQL Parser Starts from here


 Current Implementation Algorithm
 --------------------------------

 STEP#1: Validate the PL/SQL Procedure passed down from the API
   STEP#1A: Existential check
   STEP#1B: Check if the package has both spec/body
   STEP#1C: Check if the package body/speck has any errors

 STEP#2: Obtain the parameter to pass to the PL/SQL package.

 STEP#3: Validate and parse the function input parameters

 STEP#4: Call the Report PL/SQL Function

 STEP#5: Validate default report query
****************************************************************************************************/

PROCEDURE Validate_Plsql_For_Report (
    p_Region_Code           IN VARCHAR2
  , p_Region_Application_Id IN VARCHAR2
  , p_Plsql_Function        IN VARCHAR2
  , p_Attribute_Code        IN VARCHAR2
  , p_Attribute1            IN VARCHAR2
  , p_Attribute2            IN VARCHAR2
  , p_Attribute3            IN VARCHAR2
  , p_Default_Values        IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
) IS

  l_Function_Parameter    VARCHAR2(30);
  l_Parameter             VARCHAR2(30);
  l_Parameter_1           VARCHAR2(30);
  l_Parameter_2           VARCHAR2(30);
  l_Parameter_3           VARCHAR2(30);
  l_Parameter_1_type      VARCHAR2(30);
  l_Parameter_2_type      VARCHAR2(30);
  l_Parameter_3_type      VARCHAR2(30);
  l_Parameter_1_var       VARCHAR2(30);
  l_Parameter_2_var       VARCHAR2(30);
  l_Parameter_3_var       VARCHAR2(30);

  l_Custom_Sql              VARCHAR2(3000);
  l_Custom_Output           BIS_QUERY_ATTRIBUTES_TBL;

  l_View_Cols               VARCHAR2(2000);
  l_Custom_Cols             VARCHAR2(2000);
BEGIN
    -- STEP#1 of algorithm
    BSC_UTILITY.Validate_PLSQL (
        p_Plsql_Function => p_Plsql_Function
      , x_Return_Status  => x_Return_Status
      , x_Msg_Count      => x_Msg_Count
      , x_Msg_Data       => x_Msg_Data
    );
    IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*
    -- STEP#2 of algorithm
    l_Function_Parameter := Get_Plsql_Parameter(p_Plsql_Function);

    IF (l_Function_Parameter IS NULL) THEN
        -- BIS_PLSQL_INVALID_PARAMETERS
        -- The PL/SQL Function provided has been defined with invalid parameters
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_INVALID_PARAMETERS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    */

    -- STEP#2 of algorithm
    BSC_UTILITY.Get_Plsql_Parameters (
         p_Report_Function   => p_Plsql_Function
       , x_Parameter_1       => l_Parameter_1
       , x_Parameter_2       => l_Parameter_2
       , x_Parameter_3       => l_Parameter_3
       , x_Parameter_1_type  => l_Parameter_1_type
       , x_Parameter_2_type  => l_Parameter_2_type
       , x_Parameter_3_type  => l_Parameter_3_type
       , x_Parameter_1_var   => l_Parameter_1_var
       , x_Parameter_2_var   => l_Parameter_2_var
       , x_Parameter_3_var   => l_Parameter_3_var
    );
    IF ((l_Parameter_1 IS NULL) AND
        (l_Parameter_2 IS NULL) AND
        (l_Parameter_3 IS NULL)) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_INVALID_FUNC_NAME');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*
     Perform validations here from STEP#2
    */

    -- STEP#3 of Algorithm
    -- l_Custom_Cols has the comma seperated SELECT CLAUSE required
    -- and sufficient for the Report region.
    BSC_UTILITY.Obtain_Report_Query (
        p_Region_Code           => p_Region_Code
      , p_Region_Application_Id => p_Region_Application_Id
      , p_Plsql_Function        => p_Plsql_Function
      , p_Attribute_Code        => p_Attribute_Code
      , p_Attribute1            => p_Attribute1
      , p_Attribute2            => p_Attribute2
      , p_Attribute3            => p_Attribute3
      , p_Default_Values        => p_Default_Values
      , x_Custom_Sql            => l_Custom_Sql
      , x_Custom_Output         => l_Custom_Output
      , x_Custom_Columns        => l_Custom_Cols
      , x_Return_Status         => x_Return_Status
      , x_Msg_Count             => x_Msg_Count
      , x_Msg_Data              => x_Msg_Data
    );
    -- BIS_ERR_OBTAIN_RPT_QUERY - There was an error when extracting Report Query using the Default
    -- parameter values. Please verify if your PL/SQL API returns a SQL for the default parameters.
    IF ((x_Return_Status <> FND_API.G_RET_STS_SUCCESS) OR (l_Custom_Sql IS NULL)) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_ERR_OBTAIN_RPT_QUERY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_UTILITY.Validate_Sql_String (
        p_Sql_String     => l_Custom_Sql
      , x_Columns        => l_View_Cols
      , x_Return_Status  => x_Return_Status
      , x_Msg_Count      => x_Msg_Count
      , x_Msg_Data       => x_Msg_Data
    );
    -- BIS_ERR_WITH_REPORT_SQL
    -- The Report Query returned from the PL/SQL procedure has the following
    -- error(s) : ERROR
    IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_ERR_WITH_REPORT_SQL');
        FND_MESSAGE.SET_TOKEN('ERROR', x_Msg_Data);
        FND_MSG_PUB.ADD;
        x_Msg_Data := NULL;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_Custom_Cols := Sort_String(l_Custom_Cols);
    l_View_Cols := Sort_String(l_View_Cols);

    -- BIS_ERR_COLS_RPT_MISMATCH
    -- The columns in the report query returned from the PL/SQL Package does not match
    -- the number of columns required to run the report for default parameters. Please review the
    -- PL/SQL procedure.
    IF ((l_Custom_Cols IS NULL) OR (l_Custom_Cols <> l_View_Cols)) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_ERR_COLS_RPT_MISMATCH');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Finally the PL/SQL is OK - return that the PL/SQL has passed the validation.
    IF ((x_Return_Status = FND_API.G_RET_STS_SUCCESS) OR (x_Msg_Data IS NULL)) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_PACKAGE_IS_VALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Validate_Plsql_For_Report ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Validate_Plsql_For_Report ';
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Validate_Plsql_For_Report ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Validate_Plsql_For_Report ';
        END IF;
END Validate_Plsql_For_Report;


-- This API returns the parameter being used for a PL/SQL API, which should have the one parameter
-- and should take the type BIS_PMV_PAGE_PARAMETER_TBL

PROCEDURE Get_Plsql_Parameters (
     p_Report_Function   IN VARCHAR2
   , x_Parameter_1       OUT NOCOPY VARCHAR2
   , x_Parameter_2       OUT NOCOPY VARCHAR2
   , x_Parameter_3       OUT NOCOPY VARCHAR2
   , x_Parameter_1_type  OUT NOCOPY VARCHAR2
   , x_Parameter_2_type  OUT NOCOPY VARCHAR2
   , x_Parameter_3_type  OUT NOCOPY VARCHAR2
   , x_Parameter_1_var   OUT NOCOPY VARCHAR2
   , x_Parameter_2_var   OUT NOCOPY VARCHAR2
   , x_Parameter_3_var   OUT NOCOPY VARCHAR2
) IS
    l_Function_Name VARCHAR2(30);
    l_Package_Name  VARCHAR2(30);
    l_Temp_String1  ALL_SOURCE.TEXT%TYPE;
    l_Temp_String2  ALL_SOURCE.TEXT%TYPE;

    l_Package_Specification VARCHAR2(32000);

    l_Package_Token_Table   BSC_UTILITY.Varchar_Tabletype;
    l_Package_Token_Count   NUMBER;

    l_Token_Count1          NUMBER;
    l_Token_Count2          NUMBER;

    l_Parameter             VARCHAR2(30);
    l_Parameter_1           VARCHAR2(30);
    l_Parameter_2           VARCHAR2(30);
    l_Parameter_3           VARCHAR2(30);
    l_Parameter_1_type      VARCHAR2(30);
    l_Parameter_2_type      VARCHAR2(30);
    l_Parameter_3_type      VARCHAR2(30);
    l_Parameter_1_var       VARCHAR2(30);
    l_Parameter_2_var       VARCHAR2(30);
    l_Parameter_3_var       VARCHAR2(30);

    l_Index_Cnt             NUMBER;

    CURSOR c_Parse_Package_Spec IS
        SELECT A.LINE, A.TEXT
        FROM   ALL_SOURCE A
        WHERE  A.OWNER = BSC_APPS.get_user_schema(C_PACKAGE_OWNER)
        AND    A.TYPE  = C_PACKAGE_SPECIFICATION
        AND    A.NAME  = l_Package_Name;
BEGIN

    l_Package_Name  := UPPER(SUBSTR(p_Report_Function, 1, INSTR(p_Report_Function, '.')-1));
    l_Function_Name := UPPER(SUBSTR(p_Report_Function, INSTR(p_Report_Function, '.')+1));

    FOR cPPS IN c_Parse_Package_Spec LOOP
        l_Temp_String1 := UPPER(Remove_Repeating_Comma(TRANSLATE(cPPS.TEXT,  ',.() +-*/;'||fnd_global.local_chr(10)||fnd_global.local_chr(9) ,',,,,,,,,,,,,')));
        --DBMS_OUTPUT.PUT_LINE (' l_Temp_String1  - ' || l_Temp_String1);
        l_Package_Specification := Remove_Repeating_Comma(l_Package_Specification ||','||l_Temp_String1);
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE (' l_Package_Name  - ' || l_Package_Name);
    --DBMS_OUTPUT.PUT_LINE (' l_Function_Name - ' || l_Function_Name);

    BSC_UTILITY.Parse_String
    (
       p_List        => l_Package_Specification
     , p_Separator   => ','
     , p_List_Data   => l_Package_Token_Table
     , p_List_number => l_Package_Token_Count
    );

    FOR i IN 1..l_Package_Token_Count LOOP
        --DBMS_OUTPUT.PUT_LINE (' l_Package_Token_Table  - ' || l_Package_Token_Table(i));


        IF (l_Package_Token_Table(i) = C_PLSQL_TOKEN_PROCEDURE) THEN
            IF(l_Package_Token_Table(i+1) = UPPER(l_Function_Name)) THEN
                --l_Parameter := l_Package_Token_Table(i+2);
                -- Get the first parameter details

                --DBMS_OUTPUT.PUT_LINE (' l_Package_Token_Table  - ' || l_Package_Token_Table(i));
                --DBMS_OUTPUT.PUT_LINE (' l_Index_Cnt  - ' || l_Index_Cnt);

                l_Index_Cnt := 2;
                l_Parameter_1 := l_Package_Token_Table(i+l_Index_Cnt);
                l_Index_Cnt := l_Index_Cnt + 1; -- 3
                l_Parameter_1_type := l_Package_Token_Table(i+l_Index_Cnt);
                l_Index_Cnt := l_Index_Cnt + 1; -- 4
                l_Parameter_1_var := l_Package_Token_Table(i+l_Index_Cnt);

                -- Get the second parameter details
                l_Index_Cnt := l_Index_Cnt + 1; -- 5
                l_Parameter_2 := l_Package_Token_Table(i+l_Index_Cnt);
                l_Index_Cnt := l_Index_Cnt + 1; -- 6
                l_Parameter_2_type := l_Package_Token_Table(i+l_Index_Cnt);
                IF (l_Package_Token_Table(i+l_Index_Cnt+1) = 'NOCOPY') THEN
                    l_Parameter_2_type := l_Package_Token_Table(i+l_Index_Cnt);
                    l_Index_Cnt := l_Index_Cnt + 1; -- ~7
                    l_Parameter_2_type := l_Parameter_2_type || ' ' || l_Package_Token_Table(i+l_Index_Cnt);
                END IF;
                l_Index_Cnt := l_Index_Cnt + 1; -- ~ 7 || 8
                l_Parameter_2_var := l_Package_Token_Table(i+l_Index_Cnt);


                -- Get the third parameter details
                l_Index_Cnt := l_Index_Cnt + 1; -- 9
                l_Parameter_3 := l_Package_Token_Table(i+l_Index_Cnt);
                l_Index_Cnt := l_Index_Cnt + 1; -- 10
                l_Parameter_3_type := l_Package_Token_Table(i+l_Index_Cnt);
                IF (l_Package_Token_Table(i+l_Index_Cnt+1) = 'NOCOPY') THEN
                    l_Parameter_3_type := l_Package_Token_Table(i+l_Index_Cnt) ;
                    l_Index_Cnt := l_Index_Cnt + 1; -- ~11
                    l_Parameter_3_type := l_Parameter_3_type || ' ' || l_Package_Token_Table(i+l_Index_Cnt);
                END IF;
                l_Index_Cnt := l_Index_Cnt + 1; -- ~ 11 || 12
                l_Parameter_3_var := l_Package_Token_Table(i+l_Index_Cnt);

                x_Parameter_1       := l_Parameter_1;
                x_Parameter_2       := l_Parameter_2;
                x_Parameter_3       := l_Parameter_3;
                x_Parameter_1_type  := l_Parameter_1_type;
                x_Parameter_2_type  := l_Parameter_2_type;
                x_Parameter_3_type  := l_Parameter_3_type;
                x_Parameter_1_var   := l_Parameter_1_var;
                x_Parameter_2_var   := l_Parameter_2_var;
                x_Parameter_3_var   := l_Parameter_3_var;
                EXIT;
            END IF;
        END IF;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        NULL;
END Get_Plsql_Parameters;


-- this API trims all moving comma's to a single comma.

FUNCTION Remove_Repeating_Comma (
    p_String IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Remove_Comma  BOOLEAN;
    l_Return        VARCHAR2(32000);
    l_Char          VARCHAR2(1);
BEGIN

    l_Remove_Comma := FALSE;

    FOR i IN 1..LENGTH(p_String) LOOP
        l_Char := SUBSTR(p_String, i, 1);

        IF (NOT l_Remove_Comma) THEN
            l_Return := l_Return || l_Char;
        END IF;

        IF (l_Char = ',') THEN
            l_Remove_Comma := TRUE;
        ELSE
            IF (l_Remove_Comma) THEN
                l_Return := l_Return || l_Char;
            END IF;
            l_Remove_Comma := FALSE;
        END IF;
    END LOOP;

    RETURN l_Return;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Remove_Repeating_Comma;


-- this API does an existential validation on the PL/SQL Package/function.
PROCEDURE Validate_PLSQL (
    p_Plsql_Function        IN VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
) IS
    l_Function_Name VARCHAR2(30);
    l_Package_Name  VARCHAR2(30);
    l_Count         NUMBER;
BEGIN

    -- BIS_PLSQL_INVALID_FUNC_NAME
    -- The PL/SQL "Package_Name.Function_Name" specification is incorrect or does not exist.
    IF (INSTR(p_Plsql_Function, '.') = 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_INVALID_FUNC_NAME');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_Package_Name  := UPPER(SUBSTR(p_Plsql_Function, 1, INSTR(p_Plsql_Function, '.')-1));
    l_Function_Name := UPPER(SUBSTR(p_Plsql_Function, INSTR(p_Plsql_Function, '.')+1));

    SELECT COUNT(1) INTO l_Count
    FROM   ALL_SOURCE A
    WHERE  A.TYPE  = C_PACKAGE_SPECIFICATION
    AND    A.OWNER = BSC_APPS.get_user_schema(C_PACKAGE_OWNER)
    AND    A.NAME  = l_Package_Name;

    -- BIS_PLSQL_PKG_NOT_EXIST
    -- The PL/SQL procedure or function does not exist in the database
    IF (l_Count = 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_PKG_NOT_EXIST');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    SELECT COUNT(1) INTO l_Count
    FROM   USER_OBJECTS A
    WHERE  A.OBJECT_NAME  = l_Package_Name
    AND    A.STATUS       = C_PACKAGE_STATUS_INVALID;

    -- BIS_PLSQL_PKG_NOT_EXIST
    -- The PL/SQL package has errors.
    IF (l_Count <> 0) THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_PLSQL_PKG_HAS_ERRORS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Validate_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Validate_PLSQL ';
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Validate_PLSQL ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Validate_PLSQL ';
        END IF;
END Validate_PLSQL;


-- Get's the report query
PROCEDURE Obtain_Report_Query (
    p_Region_Code           IN VARCHAR2
  , p_Region_Application_Id IN VARCHAR2
  , p_Plsql_Function        IN VARCHAR2
  , p_Attribute_Code        IN VARCHAR2
  , p_Attribute1            IN VARCHAR2
  , p_Attribute2            IN VARCHAR2
  , p_Attribute3            IN VARCHAR2
  , p_Default_Values        IN VARCHAR2
  , x_Custom_Sql            OUT NOCOPY VARCHAR2
  , x_Custom_Output         OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
  , x_Custom_Columns        OUT NOCOPY VARCHAR2
  , x_Return_Status         OUT NOCOPY VARCHAR2
  , x_Msg_Count             OUT NOCOPY NUMBER
  , x_Msg_Data              OUT NOCOPY VARCHAR2
) IS
    l_Attribute_Code   BSC_UTILITY.Varchar_Tabletype;
    l_Attribute1       BSC_UTILITY.Varchar_Tabletype;
    l_Attribute2       BSC_UTILITY.Varchar_Tabletype;
    l_Attribute3       BSC_UTILITY.Varchar_Tabletype;
    l_Default_Values   BSC_UTILITY.Varchar_Tabletype;

    l_Non_Time_Dimension_Type   BSC_UTILITY.Varchar_Tabletype;
    l_Non_Time_Dimension_Value  BSC_UTILITY.Varchar_Tabletype;
    l_Time_Dimension_Type       BSC_UTILITY.Varchar_Tabletype;
    l_Time_Dimension_Value      BSC_UTILITY.Varchar_Tabletype;

    l_Attribute_Code_Count  NUMBER;
    l_Attribute1_Count      NUMBER;
    l_Attribute2_Count      NUMBER;
    l_Attribute3_Count      NUMBER;
    l_Default_Values_Count  NUMBER;

    l_PMV_Query_Table       BIS_PMV_PAGE_PARAMETER_TBL := BIS_PMV_PAGE_PARAMETER_TBL();
    l_Table_Count           NUMBER;

    l_Page_Parameter_Tbl    BIS_PMV_PAGE_PARAMETER_TBL := BIS_PMV_PAGE_PARAMETER_TBL();
    l_Page_Parameter_Rec    BIS_PMV_PAGE_PARAMETER_REC := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);

    l_Sql                   VARCHAR2(8192);
    l_Comparison_Type       VARCHAR2(30);
    l_Measure_Columns       VARCHAR2(4096);
BEGIN
    FND_MSG_PUB.Initialize;
    l_Table_Count := 0;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_UTILITY.Parse_String
    (
       p_List        => p_Attribute_Code
     , p_Separator   => ','
     , p_List_Data   => l_Attribute_Code
     , p_List_number => l_Attribute_Code_Count
    );

    BSC_UTILITY.Parse_String
    (
       p_List        => p_Attribute1
     , p_Separator   => ','
     , p_List_Data   => l_Attribute1
     , p_List_number => l_Attribute1_Count
    );

    BSC_UTILITY.Parse_String
    (
       p_List        => p_Attribute2
     , p_Separator   => ','
     , p_List_Data   => l_Attribute2
     , p_List_number => l_Attribute2_Count
    );

    BSC_UTILITY.Parse_String
    (
       p_List        => p_Attribute3
     , p_Separator   => ','
     , p_List_Data   => l_Attribute3
     , p_List_number => l_Attribute3_Count
    );

    BSC_UTILITY.Parse_String
    (
       p_List        => p_Default_Values
     , p_Separator   => ','
     , p_List_Data   => l_Default_Values
     , p_List_number => l_Default_Values_Count
    );

    --DBMS_OUTPUT.PUT_LINE ('Stage 1');

    FOR i IN 1..l_Attribute_Code_Count LOOP -- BRANCH #1
      IF (l_Attribute1(i)  IN (    -- BRANCH #2
               'DIMENSION LEVEL',
               'DIM LEVEL SINGLE VALUE',
               'DIMENSION VALUE',
               'HIDE_VIEW_BY',
               'HIDE_VIEW_BY_SINGLE',
               'HIDE PARAMETER',
               'VIEWBY PARAMETER',
               'HIDE_DIM_LVL',
               'HIDE DIMENSION LEVEL',
               'HIDE VIEW BY DIMENSION',
               'HIDE_VIEW_BY_DIM_SINGLE')) THEN

        --DBMS_OUTPUT.PUT_LINE ('Stage 2');

        IF (l_Attribute2(i) = 'AS_OF_DATE') THEN  -- BRANCH #3
          Insert_Into_Query_Table(l_PMV_Query_Table
                                  ,'BIS_CURRENT_ASOF_DATE'
                                  ,i
                                  ,l_Default_Values(i)
                                  ,NULL
                                  ,NULL
                                  ,NULL
          );
          Insert_Into_Query_Table(l_PMV_Query_Table
                                  ,'AS_OF_DATE'
                                  ,i
                                  ,l_Default_Values(i)
                                  ,NULL
                                  ,NULL
                                  ,NULL
          );
        ELSIF (SUBSTR(l_Attribute2(i), 1, INSTR(l_Attribute2(i),'+') - 1) IN ('TIME', 'EDW_TIME')) THEN -- BRANCH#3
          IF (l_Default_Values(i) IS NOT NULL) THEN -- BRANCH #4A

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'BIS_CURRENT_EFFECTIVE_END_DATE'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'BIS_CURRENT_EFFECTIVE_END_DATE'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'BIS_PERIOD_TYPE'
                                    ,i
                                    ,SUBSTR(l_Attribute2(i), INSTR(l_Attribute2(i),'+') + 1)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'_LOCAL_TIME_PARAM'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,l_Attribute2(i) || '_FROM'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,l_Attribute2(i) || '_TO'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,l_Attribute2(i) || '_PFROM'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,l_Attribute2(i) || '_PTO'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );
          END IF; -- BRANCH #4A
        -- WHEN PASSING THE TIME_COMPARISON_TYPE,THE VALUE SHOULD BE EITHER SEQUENTIAL OR YEARLY
        ELSIF (SUBSTR(l_Attribute2(i), 1, INSTR(l_Attribute2(i),'+') - 1) = 'TIME_COMPARISON_TYPE') THEN -- BRANCH#3
            l_Comparison_Type := SUBSTR(l_Attribute2(i), INSTR(l_Attribute2(i),'+') + 1);

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'BIS_TIME_COMPARISON_TYPE'
                                    ,i
                                    ,l_Comparison_Type
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'TIME_COMPARISON_TYPE'
                                    ,i
                                    ,l_Comparison_Type
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

        ELSE -- BRANCH#3
            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,l_Attribute2(i)
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

            -- needs review
            Insert_Into_Query_Table(l_PMV_Query_Table
                                    ,'BIS_SELECTED_TOP_MANAGER'
                                    ,i
                                    ,l_Default_Values(i)
                                    ,NULL
                                    ,NULL
                                    ,NULL
            );

        END IF; -- BRANCH#3
      ELSIF (l_Attribute1(i) = 'VIEW_BY') THEN -- BRANCH#2
        Insert_Into_Query_Table(l_PMV_Query_Table
                                ,l_Attribute1(i)
                                ,i
                                ,l_Default_Values(i)
                                ,NULL
                                ,NULL
                                ,NULL
        );
      ELSIF (l_Attribute1(i) IN ('BUCKET_MEASURE',
                                 'MEASURE',
                                 'MEASURE_NOTARGET',
                                 'SUB MEASURE',
                                 'COMPARE_TO_MEASURE_NO_TARGET',
                                 'COMPARE_TO_MEASURE')) THEN
        IF (l_Measure_Columns IS NULL) THEN -- BRANCH#3
          l_Measure_Columns := l_Attribute_Code(i);
        ELSE
          l_Measure_Columns := l_Measure_Columns  || ',' || l_Attribute_Code(i);
        END IF;  -- BRANCH#3

      ELSIF (l_Attribute1(i) IN ('CHANGE_MEASURE_NO_TARGET',
                                 'CHANGE_MEASURE')) THEN

        -- We must return the MEASURE column only if the base column (ATTRIBUTE3) has
        -- not been defined for a Change/ Percentage of total [NOTSURE].
        IF (l_Attribute3(i) IS NULL) THEN -- BRANCH#3
          IF (l_Measure_Columns IS NULL) THEN -- BRANCH#4
            l_Measure_Columns := l_Attribute_Code(i);
          ELSE
            l_Measure_Columns := l_Measure_Columns  || ',' || l_Attribute_Code(i);
          END IF;  -- BRANCH#4
        END IF; -- BRANCH#3

      END IF; -- BRANCH#2
    END LOOP;  -- BRANCH#1

    -- No insert into the table misc Key,Value pairs.
    Insert_Into_Query_Table(l_PMV_Query_Table
                            ,'BIS_FXN_NAME'
                            ,NULL
                            ,p_Region_Code
                            ,NULL
                            ,NULL
                            ,NULL
    );

    Insert_Into_Query_Table(l_PMV_Query_Table
                            ,'BIS_REGION_CODE'
                            ,NULL
                            ,p_Region_Code
                            ,NULL
                            ,NULL
                            ,NULL
    );

    Insert_Into_Query_Table(l_PMV_Query_Table
                            ,'BIS_ICX_SESSION_ID'
                            ,NULL
                            ,'-1'
                            ,NULL
                            ,NULL
                            ,NULL
    );

    --FOR i IN 1..l_PMV_Query_Table.COUNT LOOP
      --DBMS_OUTPUT.PUT_LINE (' parameter_name ('||i||') || - ' || l_PMV_Query_Table(i).parameter_name);
      --DBMS_OUTPUT.PUT_LINE (' parameter_value('||i||') || - ' || l_PMV_Query_Table(i).parameter_value);
    --END LOOP;


    x_Custom_Columns := l_Measure_Columns;

    l_Sql := 'BEGIN ' || p_Plsql_Function || ' (:1, :2, :3); END;';
    EXECUTE IMMEDIATE l_Sql USING l_PMV_Query_Table, OUT x_Custom_Sql, OUT x_Custom_Output;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Obtain_Report_Query ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Obtain_Report_Query ';
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_UTILITY.Obtain_Report_Query ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_UTILITY.Obtain_Report_Query ';
        END IF;
END Obtain_Report_Query;


-- Inserts into Parameter Query table.
PROCEDURE Insert_Into_Query_Table (
    x_Param_Table IN OUT NOCOPY BIS_PMV_PAGE_PARAMETER_TBL
  , p_Parameter_Name  IN VARCHAR2
  , p_Parameter_Id    IN VARCHAR2
  , p_Parameter_Value IN VARCHAR2
  , p_Dimension       IN VARCHAR2
  , p_Period_Date     IN DATE
  , p_Operator        IN VARCHAR2
) IS
    l_Index NUMBER;
    l_Page_Parameter_Rec BIS_PMV_PAGE_PARAMETER_REC := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);

BEGIN
    l_Page_Parameter_Rec.Parameter_Name  := p_Parameter_Name;
    l_Page_Parameter_Rec.Parameter_Id    := l_Index;
    l_Page_Parameter_Rec.Parameter_Value := p_Parameter_Value;
    l_Page_Parameter_Rec.Dimension       := p_Dimension;
    l_Page_Parameter_Rec.Period_Date     := p_Period_Date;
    l_Page_Parameter_Rec.Operator        := p_Operator;

    x_Param_Table.EXTEND;
    x_Param_Table(x_Param_Table.LAST) := l_Page_Parameter_Rec;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END Insert_Into_Query_Table;

-- Procedure to perform transactions autonomously
PROCEDURE Do_DDL_AT(
     p_Statement           IN VARCHAR2,
     p_Statement_Type      IN INTEGER,
     p_Object_Name         IN VARCHAR2,
     p_Fnd_Apps_Schema     IN VARCHAR2,
     p_Apps_Short_Name     IN VARCHAR2
    ) IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    AD_DDL.Do_DDL(p_Fnd_Apps_Schema,
                  p_Apps_Short_Name,
                  p_Statement_Type,
                  p_Statement,
                  p_Object_Name);
END Do_DDL_AT;


/*
Current Algorithm

-- Taken in the SQL
-- Validate by Creating a View autonomously
-- Report Failure to create
-- Return the comma separated list (ordered)
-- Drop the view autonomously

*/

PROCEDURE Validate_Sql_String (
    p_Sql_String     IN  VARCHAR2
  , x_Columns        OUT NOCOPY VARCHAR2
  , x_Return_Status  OUT NOCOPY VARCHAR2
  , x_Msg_Count      OUT NOCOPY NUMBER
  , x_Msg_Data       OUT NOCOPY VARCHAR2
) IS
  l_Temp_View_Name VARCHAR2(30);
  l_Sql_View       VARCHAR2(2048);
  l_View_Cols      VARCHAR2(2048);

  l_Stage          VARCHAR2(30);

  CURSOR c_Get_Column_Names IS
    SELECT A.COLUMN_NAME
    FROM   ALL_TAB_COLS A
    WHERE  A.TABLE_NAME = l_Temp_View_Name
    AND    A.OWNER = BSC_APPS.get_user_schema(C_PACKAGE_OWNER)
    ORDER BY A.COLUMN_NAME;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- Bug#5034549; Added ABS() to DBMS_UTILITY.GET_TIME, since it can return negative value
  l_Temp_View_Name := 'BIS_TMP_' || TO_CHAR(SYSDATE,'J')||ABS(DBMS_UTILITY.GET_TIME) || '_V';

  l_Sql_View := 'CREATE OR REPLACE VIEW ' || l_Temp_View_Name;
  l_Sql_View := l_Sql_View || ' AS ';
  l_Sql_View := l_Sql_View || p_Sql_String;

  l_Stage := 'CREATE_VIEW';
  BSC_UTILITY.Do_Ddl_AT(l_Sql_View, AD_DDL.CREATE_VIEW, l_Temp_View_Name, 'APPS', 'BIS');

  -- View has been created successfully, if it reaches here.

  FOR cGCN IN c_Get_Column_Names LOOP
    IF (x_Columns IS NULL) THEN
      x_Columns := cGCN.COLUMN_NAME;
    ELSE
      x_Columns := x_Columns || ',' || cGCN.COLUMN_NAME;
    END IF;
  END LOOP;

  l_Sql_View := 'DROP VIEW ' || l_Temp_View_Name;
  l_Stage := 'DROP_VIEW';
  BSC_UTILITY.Do_Ddl_AT(l_Sql_View, AD_DDL.DROP_VIEW, l_Temp_View_Name, 'APPS', 'BIS');

EXCEPTION
  WHEN OTHERS THEN
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_Msg_Data := SQLERRM;
END Validate_Sql_String;

-- Sorts a comma separated string using a Enhanced Bubble Sort (Very bad - but ok for now)
FUNCTION Sort_String (
  p_String IN VARCHAR2
) RETURN VARCHAR2 IS
    l_String_Table  BSC_UTILITY.Varchar_Tabletype;
    l_Temp  VARCHAR2(1024);
    l_Count NUMBER;
    i NUMBER;
    j NUMBER;
    l_Return_String VARCHAR2(8192);
BEGIN
    IF (p_String IS NULL) THEN
      RETURN NULL;
    END IF;
    BSC_UTILITY.Parse_String
    (
       p_List        => p_String
     , p_Separator   => ','
     , p_List_Data   => l_String_Table
     , p_List_number => l_Count
    );

    FOR i IN REVERSE 1..l_Count LOOP
      FOR j IN 1..(i-1) LOOP
        IF (l_String_Table(j) > l_String_Table(j+1)) THEN
          l_Temp := l_String_Table(j);
          l_String_Table(j) := l_String_Table(j+1);
          l_String_Table(j+1) := l_Temp;
        END IF;
      END LOOP;
    END LOOP;

    FOR i IN 1..l_String_Table.COUNT LOOP
      IF l_Return_String IS NULL THEN
        l_Return_String := l_String_Table(i);
      ELSE
        l_Return_String := l_Return_String || ',' || l_String_Table(i);
      END IF;
    END LOOP;

    RETURN l_Return_String;

EXCEPTION
  WHEN OTHERS THEN
    RETURN SQLERRM;
END Sort_String;

FUNCTION is_bsc_measure_convertible (
  p_dataset_id   IN  NUMBER
, p_region_code  IN  VARCHAR2
) RETURN VARCHAR2
IS
  l_convertible   VARCHAR2(10);
  l_obj_attached  VARCHAR2(10);
  l_formula_meas  VARCHAR2(10);
BEGIN
  l_convertible := FND_API.G_FALSE;

  l_obj_attached := is_attached_to_objective
                      ( p_dataset_id  => p_dataset_id
              , p_region_code => p_region_code
              );

  IF (l_obj_attached = FND_API.G_FALSE) THEN
    l_formula_meas := is_formula_measure
                        ( p_dataset_id  => p_dataset_id
                );
  END IF;

  IF (l_obj_attached = FND_API.G_FALSE AND l_formula_meas = FND_API.G_FALSE) THEN
    l_convertible := FND_API.G_TRUE;
  END IF;

  RETURN l_convertible;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END is_bsc_measure_convertible;

-- Returns 'T' if the p_dataset_id is attached to any objective except the objective for p_region_code
FUNCTION is_attached_to_objective (
  p_dataset_id   IN  NUMBER
, p_region_code  IN  VARCHAR2
) RETURN VARCHAR2
IS
  l_attached   VARCHAR2(10);
  l_obj_count  NUMBER;

  CURSOR c_attached_obj IS
    SELECT COUNT(1)
      FROM bsc_kpis_b k, bsc_kpi_analysis_measures_b m
      WHERE k.indicator = m.indicator
      AND   m.dataset_id = p_dataset_id
      AND   k.short_name <> p_region_code;

BEGIN
  l_attached := FND_API.G_FALSE;

  IF (c_attached_obj%ISOPEN) THEN
    CLOSE c_attached_obj;
  END IF;
  OPEN c_attached_obj;
  FETCH c_attached_obj INTO l_obj_count;
  IF (l_obj_count > 0) THEN
    l_attached := FND_API.G_TRUE;
  END IF;
  CLOSE c_attached_obj;

  RETURN l_attached;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_attached_obj%ISOPEN) THEN
      CLOSE c_attached_obj;
    END IF;
    RETURN FND_API.G_FALSE;
END is_attached_to_objective;

-- Wrapper over BSC_BIS_MEASURE_PUB.Is_Src_Col_In_Formulas to return a VARCHAR so that it can be used in a SQL query.
FUNCTION Is_Src_Col_In_Formulas (
  p_Source_Col IN VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
  IF (BSC_BIS_MEASURE_PUB.Is_Src_Col_In_Formulas(p_Source_Col)) THEN
    RETURN FND_API.G_TRUE;
  END IF;
  RETURN FND_API.G_FALSE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.G_FALSE;
END Is_Src_Col_In_Formulas;

-- Returns 'T' if the p_dataset_id is itself a Formula measure or a part of the formula for some other measure.
FUNCTION is_formula_measure (
  p_dataset_id   IN  NUMBER
) RETURN VARCHAR2
IS
  l_formula    VARCHAR2(10);
  l_count  NUMBER;

  CURSOR c_formula_meas IS
     SELECT COUNT(1)
       FROM bsc_sys_datasets_b d, bsc_sys_measures m
       WHERE d.dataset_id = p_dataset_id
       AND   m.measure_id = d.measure_id1
       AND  ((BSC_BIS_MEASURE_PUB.Is_Formula_Type(m.measure_Col) = 'T') OR
             (d.measure_id2 IS NOT NULL) OR
             (BSC_UTILITY.Is_Src_Col_In_Formulas(m.measure_Col) = 'T') OR
             ((SELECT COUNT(1) FROM bsc_sys_datasets_b
                 WHERE dataset_id <> d.dataset_id
         AND   (measure_id1 = d.measure_id1 OR measure_id2 = d.measure_id1)) > 0)
            );

BEGIN
  l_formula := FND_API.G_FALSE;

  IF (c_formula_meas%ISOPEN) THEN
    CLOSE c_formula_meas;
  END IF;
  OPEN c_formula_meas;
  FETCH c_formula_meas INTO l_count;
  IF (l_count > 0) THEN
    l_formula := FND_API.G_TRUE;
  END IF;
  CLOSE c_formula_meas;

  RETURN l_formula;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_formula_meas%ISOPEN) THEN
      CLOSE c_formula_meas;
    END IF;
    RETURN FND_API.G_FALSE;
END is_formula_measure;


/***********************************************
UTILITY FUNCTION TO RETURN A UNIQUE MERGED LIST
************************************************/

FUNCTION Create_Unique_Comma_List (
  p_List1 IN VARCHAR2,
  p_List2 IN VARCHAR2
) RETURN VARCHAR2 IS

  l_Merged_String  VARCHAR2(32000);

  l_List_Table   BSC_UTILITY.Varchar_Tabletype;
  l_List_Count   NUMBER;
  l_UList_Table   BSC_UTILITY.Varchar_Tabletype;
  l_UList_Count   NUMBER;

  l_Final_List    VARCHAR2(32000);
BEGIN
    IF (p_List1 IS NOT NULL) THEN
      l_Merged_String := p_List1;

      IF (p_List2 IS NOT NULL) THEN
        l_Merged_String  := l_Merged_String || ',' || p_List2;
      END IF;
    ELSE
      IF (p_List2 IS NOT NULL) THEN
        l_Merged_String := p_List2;
      END IF;
    END IF;

    IF (l_Merged_String IS NOT NULL) THEN
      BSC_UTILITY.Parse_String
      (
         p_List        => l_Merged_String
       , p_Separator   => ','
       , p_List_Data   => l_List_Table
       , p_List_number => l_List_Count
      );
    END IF;

    l_UList_Table := BSC_UTILITY.Get_Unique_List(l_List_Table);

    FOR i IN 1..l_UList_Table.COUNT LOOP
      IF (l_Final_List IS NULL) THEN
        l_Final_List := l_UList_Table(i);
      ELSE
        l_Final_List := l_Final_List || ',' || l_UList_Table(i);
      END IF;
    END LOOP;

    RETURN l_Final_List;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Create_Unique_Comma_List;


/*****************************************************************************
UTILITY FUNCTION TO RETURN A UNIQUE LIST of TYPE BSC_UTILITY.varchar_tabletype
******************************************************************************/

FUNCTION Get_Unique_List (p_List IN BSC_UTILITY.varchar_tabletype)
RETURN BSC_UTILITY.varchar_tabletype IS
  l_Unique_List BSC_UTILITY.varchar_tabletype;
  l_Element VARCHAR2(32000);
  l_Count NUMBER;
  l_Duplicate BOOLEAN;
BEGIN
  l_Count := 1;
  l_Duplicate := FALSE;

  IF ((p_List IS NOT NULL) AND p_List.COUNT > 0) THEN
    FOR i IN 1..p_List.COUNT LOOP
      l_Element := p_List(i);

      FOR j IN (i+1)..p_List.COUNT LOOP
        IF (l_Element = p_List(j)) THEN
          l_Duplicate := TRUE;
        END IF;
      END LOOP;

      IF NOT l_Duplicate THEN
        l_Unique_List(l_Count) := l_Element;
        l_Count := l_Count + 1;
      END IF;

      l_Duplicate := FALSE;
    END LOOP;
  END IF;

  RETURN l_Unique_List;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_Unique_List;
END Get_Unique_List;

/*****************************************************************************
                       UTILITY FUNCTIONS FOR MEASURES
******************************************************************************/

FUNCTION is_Calculated_kpi
(
  p_Measure_Short_Name     IN  VARCHAR2
)RETURN VARCHAR2
IS
l_flag         VARCHAR2(10);
l_measure_type VARCHAR2(10);
BEGIN
    l_flag :=FND_API.G_FALSE;

    SELECT measure_type
    INTO   l_measure_type
    FROM   bis_indicators
    WHERE  short_name = p_Measure_Short_Name;

    IF(l_measure_type=BSC_UTILITY.C_MEASURE_SOURCE_CDS_CALC)THEN
     l_flag:=FND_API.G_TRUE;
    END IF;
    RETURN l_flag;

EXCEPTION
 WHEN OTHERS THEN
 RETURN l_flag;
END is_Calculated_kpi;



FUNCTION Is_Meas_Used_In_Targets
(
  p_Dataset_Id        IN    BSC_SYS_DATASETS_VL.dataset_id%TYPE
) RETURN VARCHAR2
IS
  l_count     NUMBER;
BEGIN

  l_count := 0;

  SELECT  COUNT(0)
  INTO    l_count
  FROM    bis_target_levels tl,
          bis_indicators    i
  WHERE   i.dataset_id    = p_Dataset_Id
  AND     tl.indicator_id = i.indicator_id;

  IF(l_count>0)THEN
   RETURN FND_API.G_TRUE;
  ELSE
   RETURN FND_API.G_FALSE;
  END IF;
END Is_Meas_Used_In_Targets;


FUNCTION Is_Wam_Kpi
(
  p_dataset_id    IN   BSC_SYS_DATASETS_VL.dataset_id%TYPE
)RETURN VARCHAR2
IS
  l_count        NUMBER;
  l_flag         VARCHAR2(10);
  l_measure_type VARCHAR2(10);
BEGIN
   l_flag :=FND_API.G_FALSE;

    SELECT measure_type
    INTO   l_measure_type
    FROM   bis_indicators
    WHERE  dataset_id = p_dataset_id;

    IF((l_measure_type=BSC_UTILITY.C_MEASURE_TYPE_CDS_SCORE) OR (l_measure_type=BSC_UTILITY.C_MEASURE_TYPE_CDS_PERF))THEN
     l_flag:=FND_API.G_TRUE;
    END IF;
    RETURN l_flag;
EXCEPTION
 WHEN OTHERS THEN
 RETURN l_flag;
END Is_Wam_Kpi;



FUNCTION Is_Report_Primary_Data_Source
(
  p_Indicator        IN    BSC_KPIS_B.indicator%TYPE
 ,p_Dataset_Id       IN    BSC_SYS_DATASETS_B.dataset_id%TYPE
) RETURN VARCHAR2
IS
  l_region_code       BSC_KPIS_B.short_name%TYPE;
  l_meas_short_name   BIS_INDICATORS.short_name%TYPE;
  l_flag              VARCHAR2(10);
BEGIN

  l_flag :=  FND_API.G_FALSE;

  SELECT short_name
  INTO   l_region_code
  FROM   bsc_kpis_b
  WHERE  indicator =p_Indicator;

  SELECT short_name
  INTO   l_meas_short_name
  FROM   bis_indicators
  WHERE  dataset_id =p_Dataset_Id;

  l_flag := BSC_BIS_KPI_CRUD_PUB.Is_Primary_Source_Of_Measure
            (
              p_Measure_Short_Name =>  l_meas_short_name
             ,p_Region_Code        =>  l_region_code
            );
  RETURN l_flag;

EXCEPTION
  WHEN OTHERS THEN
   RETURN l_flag;
END Is_Report_Primary_Data_Source;


FUNCTION is_Calculated_kpi
(
  p_dataset_id     IN  BSC_SYS_DATASETS_B.dataset_id%TYPE
)RETURN VARCHAR2
IS
l_flag         VARCHAR2(10);
l_measure_type VARCHAR2(10);
BEGIN
    l_flag :=FND_API.G_FALSE;

    SELECT measure_type
    INTO   l_measure_type
    FROM   bis_indicators
    WHERE  dataset_id = p_dataset_id;

    IF(l_measure_type=BSC_UTILITY.C_MEASURE_SOURCE_CDS_CALC)THEN
     l_flag:=FND_API.G_TRUE;
    END IF;
    RETURN l_flag;

EXCEPTION
 WHEN OTHERS THEN
 RETURN l_flag;
END is_Calculated_kpi;


FUNCTION Is_Meas_Used_In_Wam_Report
(
  p_dataset_id   IN   BSC_SYS_DATASETS_B.dataset_id%TYPE
)RETURN VARCHAR2
IS
  l_count        NUMBER;
  l_flag         VARCHAR2(10);
  l_attribute2   ak_region_items.attribute2%TYPE;
BEGIN

  l_flag  := FND_API.G_FALSE;
  l_count := 0;

  SELECT short_name
  INTO   l_attribute2
  FROM   bis_indicators
  WHERE  dataset_id =p_dataset_id;

  SELECT COUNT(1)
  INTO   l_count
  FROM   ak_region_items a,
         ak_regions b
  WHERE  a.region_code = b.region_code
  AND    a.attribute1 IN (BSC_UTILITY.C_ATTRTYPE_MEASURE,BSC_UTILITY.C_ATTRTYPE_MEASURE_NO_TARGET,BSC_UTILITY.C_BUCKET_MEASURE,BSC_UTILITY.C_SUB_MEASURE)
  AND    a.attribute2  = l_attribute2
  AND    b.attribute10 = BSC_UTILITY.C_MULTIPLE_DATA_SOURCE;

  IF(l_count>0)THEN
   l_flag  := FND_API.G_TRUE;
  END IF;

  RETURN l_flag;

EXCEPTION
 WHEN OTHERS THEN
 RETURN l_flag;
END Is_Meas_Used_In_Wam_Report;


 PROCEDURE comp_leapyear_prioryear(
  p_calid IN NUMBER,
  p_cyear IN NUMBER,
  p_pyear IN NUMBER,
  x_result OUT nocopy NUMBER
 )IS
lday number :=0;
lmonth number:=0;

CURSOR diff IS
SELECT day30, MONTH
FROM bsc_db_calendar
WHERE calendar_id = p_calid
AND   calendar_year =  p_cyear
MINUS
SELECT day30, MONTH
FROM bsc_db_calendar
WHERE calendar_id = p_calid
AND   calendar_year = p_pyear;
BEGIN
  OPEN diff;
  IF diff%NOTFOUND THEN
    x_result := -1;
  ELSE
    FETCH diff into lday, lmonth;
  END IF;
  CLOSE diff;
  IF lday <>0 THEN
   SELECT day365
   INTO x_result
   FROM bsc_db_calendar
   WHERE calendar_id = p_calid
   AND  calendar_year = p_cyear
   AND  day30 = lday
   AND  MONTH = lmonth;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   x_result := -1;
END comp_leapyear_prioryear;

END BSC_UTILITY;

/
