--------------------------------------------------------
--  DDL for Package Body FEM_DIMENSION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIMENSION_UTIL_PKG" AS
--$Header: FEMDIMAPB.plb 120.16.12000000.3 2007/08/08 16:16:46 gdonthir ship $
/*==========================================================================+
 |    Copyright (c) 1997 Oracle Corporation, Redwood Shores, CA, USA        |
 |                         All rights reserved.                             |
 +==========================================================================+
 | FILENAME
 |
 |    FEMDIMAPB.plb
 |
 | NAME fem_dimension_util_pkg
 |
 | DESCRIPTION
 |
 |   Package Body for fem_dimension_util_pkg
 |
 | HISTORY
 |
 |    16-JUN-03  SSista  Added APIs for Local VS Combo ID
 |    02-MAY-03  RFlippo Created
 |    27-OCT-03  TimMoore added following:
 |                    Get_Cal_Period_ID
 |                    Register_Data_Location
 |                    UnRegister_Data_Location
 |                    Generate_Member_ID
 |                    New_Dataset
 |                    New_Ledger
 |                    Get_Dim_Attr_ID_Ver_ID
 |    05-NOV-03  TimMoore modified following:
 |                    Effective_Cal_Period_ID
 |    03-JUN-04  Rflippo added SOURCE_SYSTEM as a member_id_method_code
 |    06-JUL-04  Rfippo  changes to the Generate_Default_Load_Member procedure
 |                       to create attr assignment rows for each member;  also
 |                       changed name/display_code of the generated members to
 |                       'Default' instead of 'Undefined';
 |
 |    09-JUL-04 Rflippo bug#3755923 changes to new_ledger API signature
 |                      so that all "Is Pop" attributes are defaulted to 'N';
 |                      Also added new 'Is Pop' attributes for Task and
 |                      Financial Element.
 |    10-AUG-04 Rflippo bug#3824427 - added New_Budget API to create budget
 |                      members
 |    28-OCT-04 Rflippo bug#3972903 - modify the Local_vs_combo_id function to
 |                      return the Global Combo, not the Local.  This change
 |                      is for the FEM.C modifications in the rule sharing
 |                      design;
 |    22-Nov-04 gcheng  bug#4005877 - obsolete the Effective_Cal_Period_ID
 |                      and replaced it with a new Relative_Cal_Period_ID
 |                      function.  The details of this new function can be
 |                      found in the Dimension APIs document on ASDEV.
 |    13-JAN-05 gcheng  Bug 3824701 - altered Register_Data_Location
 |                                    and Unregister_Data_Location APIs
 |
 |    17-JAN-05 tmoore  Bug 4106880 - added following APIs:
 |                         Register_Budget
 |                         Register_Ledger
 |                         Register_Encumbrance_Type
 |                         New_Global_VS_Combo
 |
 |    26-JAN-05 tmoore  Bug 4145122 - added New_Encumbrance_Type
 |    21-APR-05 RFlippo  Bug#4303380  Add Global_vs_combo_display_code to the
 |                       Insert statement for FEM_GLOBAL_VS_COMBOS_PKG
 |                       -- this fix will preserve the original signature
 |                        for this API so that it is backward compatible
 |                        with OGL by employing a default for the
 |                        global combo display_code.  If the user passes
 |                        null for the display code, it set it = global combo name.
 |    03-MAY-05 tmoore  Bug 4036498 - Added Get_Dim_Member_ID.
 |                                    This function returns a dimension
 |                                     member ID
 |    13-MAY-05 Rflippo Bug4367375 - some required attributes missing
 |                                   a default assignment for the
 |                                   generate_default_load_member proc
 |    23-MAY-05 Rflippo Bug4316406 modify generate_default_load_member
 |                                 for new req attribute security_enabled_flag
 |    15-JUN-05 gcheng  4417618. Created the Get_Default_Dim_Member procedures.
 |    30-JUN-05 gcheng  4143586. Added another version to the overloaded
 |                      Generate_Default_Load_Member procedure.
 |                      Also extensively modified the existing versions.
 |                      Also modified Get_Default_Dim_Member to make sure
 |                      it exits when OA Param validation fails.
 |    26-JUL-05 ghall   4503014. Added user messages for Attribute errors
 |                      in Relative_Cal_Period; changed WHEN OTHERS exception
 |                      to WHEN e_error, so that database errors can
 |                      pass through (for now, anyway).
 |    24-OCT-05 tmoore  4619062. Added Get_Dim_Member_Display_Code.
 |    21-NOV-05 rflippo 4749235 Modified get_default_dim_member (1) - set
 |                      variable v_member_code to be typed as varchar2
 |                      so the procedure will work for both non-value set
 |                      and value set dims
 |    30-JAN-06 gcheng  5011140 (FP:4596447) . Added an optional parameter
 |              v120.9  p_table_name to UnRegister_Data_Location.
 |    17-FEB-06 rflippo Bug#5040996 - added support for Composite dimensions
 |                      in v120.10 to Get_Dim_Member_ID function.
 |    27-FEB-06 rflippo Bug#5065490 Performance improvement for
 |                      Dimension_Value_Set_ID function when called for VS view
 |    09-MAR-06 rflippo Bug#5065490 - modified return statement for
 |                      Dimension_Value_Set_ID function to be nvl
 |                      because DHM calls the function for non-vsr dims
 |    17-MAR-06 rflippo Bug#5102692 Overload Generate_Member_ID for Cal Period
 |                      dimension;
 |    04-AUG-06 rflippo Bug 5060702 modify get_cal_period_id function to be
 |                      more performant
 |    23-AUG-06 rflippo Bug#5486589 Modify logic so that if -1 passed in as the
 |                       Cal Period Hier ID then it doesn't try to validate it.
 |    24-AUG-06 nmartine Bug 5473131. Added Get_Dim_Member_Name.
 |    23-MAR-07 rflippo MappingWizard project - modify Dimension_Value_Set_Id
 |                      API to return -1 if passed in a non-vsr dimension
 |    01-AUG-07 gdonthir Bug#5604779
 +=========================================================================*/

-----------------------
-- Package Constants --
-----------------------
c_resp_app_id CONSTANT NUMBER := FND_GLOBAL.RESP_APPL_ID;

c_user_id CONSTANT NUMBER := FND_GLOBAL.USER_ID;
c_login_id    NUMBER := FND_GLOBAL.Login_Id;

c_module_pkg   CONSTANT  VARCHAR2(80) := 'fem.plsql.fem_dimension_util_pkg';
G_PKG_NAME     CONSTANT  VARCHAR2(30) := 'FEM_DIMENSION_UTIL_PKG';

f_set_status  BOOLEAN;

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

-----------------------
-- Package Variables --
-----------------------
v_module_log   VARCHAR2(255);

v_session_ledger_id NUMBER := NULL;

g_cache_ledger_id NUMBER := NULL; -- this replaces v_session_ledger_id for
                                  -- use with the Dimension_Value_Set_ID API
g_cache_dimension_id NUMBER := NULL; -- cached dimension_id
g_cache_dim_vs_id NUMBER := NULL; -- cached value set

v_varchar      VARCHAR2(255);

-- v_attr_label   VARCHAR2(30);
-- v_attr_value   VARCHAR2(150);

v_token_value  VARCHAR2(150);
v_token_trans  VARCHAR2(1);

v_msg_text     VARCHAR2(4000);

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);

------------------------
-- Package Exceptions --
------------------------
e_bad_param_value     EXCEPTION;
e_null_param_value    EXCEPTION;
e_no_value_found      EXCEPTION;
e_many_values_found   EXCEPTION;
e_no_version_name     EXCEPTION;
e_bad_dim_id          EXCEPTION;
e_dup_mem_id          EXCEPTION;
e_user_exception      EXCEPTION;
e_dup_display_code    EXCEPTION;
e_req_attr_assign     EXCEPTION;
e_FEM_XDIM_UTIL_ATTR_NODEFAULT EXCEPTION;
e_unexp               EXCEPTION;
e_error               EXCEPTION;

/*************************************************************************

                             FEM_Initialize

 This procuedure sets a global variable storing the Ledger ID so that it
  can be available to other subprograms in the package.

*************************************************************************/

PROCEDURE FEM_Initialize (
   p_ledger_id IN NUMBER
) IS
BEGIN
   v_session_ledger_id := p_ledger_id;
End FEM_Initialize;

/*************************************************************************

                           Ledger_From_Session

 This function returns the Ledger ID that was set with FEM_Initialize

*************************************************************************/

FUNCTION Ledger_From_Session
RETURN NUMBER
IS
BEGIN
   RETURN v_session_ledger_id;
END Ledger_From_Session;

/*************************************************************************

                         Application_Group_ID

*************************************************************************/

FUNCTION Application_Group_ID
RETURN NUMBER
IS
   v_app_grp_id NUMBER;
BEGIN

SELECT application_group_id
INTO   v_app_grp_id
FROM   fem_applications
WHERE  application_id = c_resp_app_id;

RETURN v_app_grp_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN -1;

END Application_Group_ID;

/*************************************************************************

                         Is_Ledger_ID_Valid

*************************************************************************/

FUNCTION Is_Ledger_ID_Valid (
   p_ledger_id IN NUMBER
) RETURN VARCHAR2
IS
   v_ledger_id NUMBER;
BEGIN

SELECT ledger_id
INTO   v_ledger_id
FROM   fem_ledgers_b
WHERE  ledger_id = p_ledger_id;

RETURN 'Y';

EXCEPTION
   WHEN no_data_found THEN
      RETURN 'N';

END Is_Ledger_ID_Valid;

/*************************************************************************

                         Is_Dimension_ID_Valid

*************************************************************************/

FUNCTION Is_Dimension_ID_Valid (
   p_dimension_id IN NUMBER
) RETURN VARCHAR2
IS
   v_dimension_id NUMBER;
BEGIN

SELECT dimension_id
INTO   v_dimension_id
FROM   fem_xdim_dimensions
WHERE  dimension_id = p_dimension_id;

RETURN 'Y';

EXCEPTION
   WHEN no_data_found THEN
      RETURN 'N';

END Is_Dimension_ID_Valid;

/*************************************************************************

                         Global_VS_Combo_ID

 Ths procedure obtains the Global VS Combo attribute assignment of the
  current Ledger.  The current Ledger is determined in any of the
  following ways:
   a)  directly passed in as a parameter
   b)  set by the FEM_INITIALIZE procedure
   c)  from the Set of Books user profile

*************************************************************************/

FUNCTION Global_VS_Combo_ID (
   p_ledger_id IN NUMBER,
   x_err_code OUT NOCOPY NUMBER,
   x_num_msg  OUT NOCOPY NUMBER
) RETURN NUMBER
IS
   v_global_vs_id NUMBER;
   v_ledger_id NUMBER;
   v_dim_name VARCHAR2(80);
BEGIN

x_err_code := 0;
x_num_msg := 0;
IF (p_ledger_id is NULL)
THEN
   IF (v_session_ledger_id IS NULL)
   THEN
      v_ledger_id := FND_PROFILE.VALUE_SPECIFIC (
                       c_fem_ledger,
                       fnd_global.user_id,
                       null ,null);
   ELSE
      v_ledger_id := v_session_ledger_id;
   END IF;
ELSE
   v_ledger_id := p_ledger_id;
END IF;

v_dim_name := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                 p_dim_label => 'LEDGER');

IF (v_ledger_id is NULL)
THEN
   v_token_value := v_dim_name;
   x_err_code := 2;
   x_num_msg := x_num_msg + 1;
   RAISE e_null_param_value;

ELSE
   IF (Is_Ledger_ID_Valid(v_ledger_id) = 'Y')
   THEN
      BEGIN
         SELECT dim_attribute_numeric_member
         INTO   v_global_vs_id
         FROM   fem_ledgers_attr f
         WHERE  f.ledger_id = v_ledger_id
         AND    f.attribute_id =
            (SELECT attribute_id
             FROM   fem_dim_attributes_b
             WHERE attribute_varchar_label = 'GLOBAL_VS_COMBO')
         AND    f.version_id =
            (SELECT version_id
             FROM   fem_dim_attr_versions_b
             WHERE  attribute_id = f.attribute_id
             AND    default_version_flag = 'Y');
      EXCEPTION
         WHEN no_data_found THEN
            v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                             p_dim_label => 'LEDGER',
                             p_attr_label => 'GLOBAL_VS_COMBO');
            x_err_code := 2;
            x_num_msg := x_num_msg + 1;
            RAISE e_no_value_found;
      END;
   ELSE
      v_token_value := v_dim_name;
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RAISE e_no_value_found;
   END IF;
END IF;

RETURN v_global_vs_id;

EXCEPTION
   WHEN e_null_param_value THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => v_token_value);
      RETURN -1;

   WHEN e_no_value_found THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      RETURN -1;

END Global_VS_Combo_ID;

--------------------------------------------------------------------------

FUNCTION Global_VS_Combo_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER
) RETURN NUMBER
IS
   v_global_vs_id NUMBER;
   v_ledger_id NUMBER;
   v_dim_name VARCHAR2(80);
BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

IF (p_ledger_id is NULL)
THEN
   IF (v_session_ledger_id IS NULL)
   THEN
      v_ledger_id := FND_PROFILE.VALUE_SPECIFIC (
                       c_fem_ledger,
                       fnd_global.user_id,
                       null ,null);
   ELSE
      v_ledger_id := v_session_ledger_id;
   END IF;
ELSE
   v_ledger_id := p_ledger_id;
END IF;

v_dim_name := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
              p_dim_label => 'LEDGER');

IF (v_ledger_id is NULL)
THEN
   v_token_value := v_dim_name;
   RAISE e_null_param_value;

ELSE
   IF (Is_Ledger_ID_Valid(v_ledger_id) = 'Y')
   THEN
      BEGIN
         SELECT dim_attribute_numeric_member
         INTO   v_global_vs_id
         FROM   fem_ledgers_attr f
         WHERE  f.ledger_id = v_ledger_id
         AND    f.attribute_id =
            (SELECT attribute_id
             FROM   fem_dim_attributes_b
             WHERE attribute_varchar_label = 'GLOBAL_VS_COMBO')
         AND    f.version_id =
            (SELECT version_id
             FROM   fem_dim_attr_versions_b
             WHERE  attribute_id = f.attribute_id
             AND    default_version_flag = 'Y');
      EXCEPTION
         WHEN no_data_found THEN
            v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                             p_dim_label => 'LEDGER',
                             p_attr_label => 'GLOBAL_VS_COMBO');
            RAISE e_no_value_found;
      END;
   ELSE
      v_token_value := v_dim_name;
      RAISE e_no_value_found;
   END IF;
END IF;

RETURN v_global_vs_id;

EXCEPTION
   WHEN e_null_param_value THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => v_token_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_no_value_found THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

END Global_VS_Combo_ID;

/*************************************************************************

                          Local_VS_Combo_ID

rflippo 10/26/2004  Due to changes in the rule sharing design for FEM.C,
                    this function now returns the Global VS Combo ID.
                    Local Combos have been obsoleted and are no longer
                    applicable to FEM.

                     The function returns the value for the GLOBAL_VS_COMBO
                     attribute assignment for the given ledger.

PURPOSE:  This function is meant to be called by engines and UI to determine
          the value set context for a given ledger.  The returned Global combo
          then gets attached to business rules when they are created - this
          controls how those rules are shared.

          For example - you create a Mapping Rule - the UI should call this
          function to identify the Global Combo for that mapping rule based upon
          the ledger under which it was created.  It then
          stores that value into FEM_OBJECT_CATALOG_B.local_vs_combo_id.

          When you go to open that rule under a different ledger, the UI compares
          the Global Combo that returns for the new Ledger with the global combo
          stored in FEM_OBJECT_CATALOG_B.local_vs_combo_id for the rule being
          opened.

          There are 2 signatures for this function - one is OA framework
          compatible while the other is not.

*************************************************************************/

-- Non OA framework compatible signature
FUNCTION Local_VS_Combo_ID (
   p_ledger_id IN NUMBER,
   x_err_code OUT NOCOPY NUMBER,
   x_num_msg  OUT NOCOPY NUMBER
) RETURN NUMBER
IS

   v_global_vs_id NUMBER;

BEGIN

x_err_code := 0;
x_num_msg := 0;

v_global_vs_id := Global_VS_Combo_ID (
                  p_ledger_id => p_ledger_id,
                  x_err_code => x_err_code,
                  x_num_msg => x_num_msg);

IF (v_global_vs_id = -1)
THEN
   RAISE e_user_exception;
END IF;


RETURN v_global_vs_id;

EXCEPTION
   WHEN e_user_exception THEN
      RETURN -1;

END Local_VS_Combo_ID;

--------------------------------------------------------------------------
-- OA Framework compatible signature
FUNCTION Local_VS_Combo_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER
) RETURN NUMBER
IS
   v_global_vs_id NUMBER;

BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

v_global_vs_id := Global_VS_Combo_ID (
                  p_api_version => p_api_version,
                  p_init_msg_list => c_false,
                  p_commit => c_false,
                  p_encoded => p_encoded,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_ledger_id => p_ledger_id);

IF (v_global_vs_id = -1)
THEN
   RAISE e_user_exception;
END IF;


RETURN v_global_vs_id;

EXCEPTION

   WHEN e_user_exception THEN
      RETURN -1;

END Local_VS_Combo_ID;

/*************************************************************************

                       Dimension_Value_Set_ID

 This procedure returns the Value Set ID based upon the Global
  Value Set of the ledger

 Normally, call the overloaded version of the function
  that has the OUT NOCOPY parameters.
 The version that only accepts the Dimension ID parameter is called only
  as the where condition in the Value Set context views (_VS).

 2/27/2006 rflippo
 NOTE:  In order to improve performance of this function for the VS views
        I have done the following:
           - cached values for ledger, dimension_id and value_set
             The function returns the cache value set whenever the
             ledger + dimension in the cache match the ledger + dimension
             in the user's session.  This saves work because we don't
             need to retrieve the global combo info again
           - duplicated code for the global combo retreival from the
             Global_VS_Combo_ID procedure in this package.  This will
             improve performance because it skips error checks that are
             in that procedure, as well as provides more efficient access
             by removing one calling layer
           - duplicated code from the overloaded Dimension_Value_Set_ID
             function.  This improves performance by removing one calling
             layer
        The idea is to make this function as efficient as possible for
        use with the VS views.  This means doing away from with error checks
        so that we assume that we are getting a valid ledger/dimension being
        passed in.  The function always has to call out to the
        FND_PROFILE.value function in order to identify the ledger of the current
        session - this is unavoidable because of the way that OA framework pools
        sessions.  However, other than this one function call, we can return
        the value set without any additional work for the same session.  This
        means the VS views will only have to call the FND_PROFILE.value function
        when returning rows, rather than redo all of the global combo/value
        set retrievals.

*************************************************************************/

FUNCTION Dimension_Value_Set_ID (
   p_dimension_id IN NUMBER,
   p_ledger_id IN NUMBER DEFAULT NULL
) RETURN NUMBER
IS
   v_count NUMBER;
   v_vsr_flag VARCHAR2(1);
   v_current_session_ledger_id NUMBER;
   v_global_vs_id NUMBER;

   v_dim_vs_id NUMBER;
   v_err_code NUMBER;
   v_num_msg  NUMBER;
   v_return_value_set NUMBER;
BEGIN

   SELECT count(*)
   INTO v_count
   FROM fem_xdim_dimensions
   WHERE dimension_id = p_dimension_id;

   IF v_count > 0 THEN
      v_vsr_flag := 'Y';
   ELSE v_vsr_flag := 'N';
   END IF;

   /****************************************************
    If the calling app passes in the ledger, then we use that ledger
    for determining the global value set combo info.
    Otherwise, we compare the ledger and dimension of the user's session with the
    Ledger and dimension in the global variable for the package -
    if they are NOT the same, then we need to retrieve all of the global combo
    info from the database again (and store into global variables in the
    package).
    However, if they are the same, we use the value set that we already have
    cached in a global package variable
   ******************************************************/
   IF v_vsr_flag = 'Y' THEN

   IF (p_ledger_id IS NULL) THEN
      --Bug#5604779: Use Value_Specific to prevent caching
      --v_current_session_ledger_id := FND_PROFILE.VALUE (c_fem_ledger);
      v_current_session_ledger_id := FND_PROFILE.VALUE_SPECIFIC(
                  c_fem_ledger,
                  fnd_global.user_id,
                  null,null);
   ELSE v_current_session_ledger_id := p_ledger_id;
   END IF;

   IF v_current_session_ledger_id <> nvl(g_cache_ledger_id,-1) OR
     p_dimension_id <> nvl(g_cache_dimension_id,-1) THEN
      g_cache_ledger_id := v_current_session_ledger_id;
      g_cache_dimension_id := p_dimension_id;

      BEGIN
         SELECT dim_attribute_numeric_member
         INTO   v_global_vs_id
         FROM   fem_ledgers_attr f
         WHERE  f.ledger_id = v_current_session_ledger_id
         AND    f.attribute_id =
         (SELECT attribute_id
          FROM   fem_dim_attributes_b
          WHERE attribute_varchar_label = 'GLOBAL_VS_COMBO')
          AND    f.version_id =
         (SELECT version_id
          FROM   fem_dim_attr_versions_b
          WHERE  attribute_id = f.attribute_id
          AND    default_version_flag = 'Y');
      EXCEPTION
         WHEN no_data_found THEN
            v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                             p_dim_label => 'LEDGER',
                             p_attr_label => 'GLOBAL_VS_COMBO');
            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
               p_token1 => 'ENTITY',
               p_value1 => v_token_value);
      END;

      BEGIN
         SELECT value_set_id
         INTO   v_dim_vs_id
         FROM   fem_global_vs_combo_defs
         WHERE  global_vs_combo_id = v_global_vs_id
         AND    dimension_id = p_dimension_id;

         g_cache_dim_vs_id := v_dim_vs_id;
      EXCEPTION
         WHEN no_data_found THEN
            v_token_value := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                             p_dim_label => 'VALUE_SET');
            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
               p_token1 => 'ENTITY',
               p_value1 => v_token_value);

      END;

   END IF;
   END IF;  -- v_vsr_flag

   IF v_vsr_flag = 'N' THEN
      v_return_value_set := -1;
   ELSE
      v_return_value_set := nvl(g_cache_dim_vs_id,-1);
   END IF;
RETURN v_return_value_set;


END Dimension_Value_Set_ID;

------------------------------------------------------------------------

FUNCTION Dimension_Value_Set_ID (
   p_dimension_id IN NUMBER,
   p_ledger_id IN NUMBER,
   x_err_code OUT NOCOPY NUMBER,
   x_num_msg  OUT NOCOPY NUMBER
) RETURN NUMBER
IS
   v_vs_id NUMBER;
   v_global_vs_id NUMBER;
BEGIN

x_err_code := 0;
x_num_msg := 0;

IF (Is_Dimension_ID_Valid(p_dimension_id) <> 'Y')
THEN
   v_token_value := 'FEM_DIMENSION_TXT';
   v_token_trans := 'Y';
   x_err_code := 2;
   x_num_msg := x_num_msg + 1;
   RAISE e_no_value_found;
ELSE
   v_global_vs_id := Global_VS_Combo_ID (
                     p_ledger_id => p_ledger_id,
                     x_err_code => x_err_code,
                     x_num_msg  => x_num_msg);
   IF (v_global_vs_id = -1)
   THEN
      RAISE e_user_exception;
   END IF;

   BEGIN
      SELECT value_set_id
      INTO   v_vs_id
      FROM   fem_global_vs_combo_defs
      WHERE  global_vs_combo_id = v_global_vs_id
      AND    dimension_id = p_dimension_id;
   EXCEPTION
      WHEN no_data_found THEN
         v_token_value := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                          p_dim_label => 'VALUE_SET');
         v_token_trans := 'N';
         x_err_code := 2;
         x_num_msg := x_num_msg + 1;
         RAISE e_no_value_found;
   END;

END IF;

RETURN v_vs_id;

EXCEPTION
   WHEN e_no_value_found THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value,
         p_trans1 => v_token_trans);
      RETURN -1;

   WHEN e_user_exception THEN
      RETURN -1;

END Dimension_Value_Set_ID;

------------------------------------------------------------------------

FUNCTION Dimension_Value_Set_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dimension_id    IN NUMBER,
   p_ledger_id       IN NUMBER
) RETURN NUMBER
IS
   v_vs_id NUMBER;
   v_global_vs_id NUMBER;
BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

IF (Is_Dimension_ID_Valid(p_dimension_id) <> 'Y')
THEN
   v_token_value := 'FEM_DIMENSION_TXT';
   v_token_trans := 'Y';
   x_return_status := c_error;
   RAISE e_no_value_found;
ELSE
   v_global_vs_id := Global_VS_Combo_ID (
                     p_api_version => p_api_version,
                     p_init_msg_list => c_false,
                     p_commit => c_false,
                     p_encoded => p_encoded,
                     x_return_status => x_return_status,
                     x_msg_count => x_msg_count,
                     x_msg_data => x_msg_data,
                     p_ledger_id => p_ledger_id);

   IF (v_global_vs_id = -1)
   THEN
      RAISE e_user_exception;
   END IF;

   BEGIN
      SELECT value_set_id
      INTO   v_vs_id
      FROM   fem_global_vs_combo_defs
      WHERE  global_vs_combo_id = v_global_vs_id
      AND    dimension_id = p_dimension_id;
   EXCEPTION
      WHEN no_data_found THEN
         v_token_value := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                          p_dim_label => 'VALUE_SET');
         v_token_trans := 'N';
         RAISE e_no_value_found;
   END;

END IF;

RETURN v_vs_id;

EXCEPTION
   WHEN e_no_value_found THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value,
         p_trans1 => v_token_trans);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_user_exception THEN
      RETURN -1;

END Dimension_Value_Set_ID;

/*************************************************************************

                        Is_Rule_Valid_For_Ledger

*************************************************************************/

FUNCTION Is_Rule_Valid_For_Ledger (
   p_object_id   IN NUMBER,
   p_ledger_id   IN NUMBER
) RETURN VARCHAR2
IS
   v_return_status VARCHAR2(1);
   v_msg_count  NUMBER;
   v_msg_data   VARCHAR2(255);
   v_rule_vs_id NUMBER;
   v_local_vs_id NUMBER;
BEGIN

v_local_vs_id := Local_VS_Combo_ID (
                 p_api_version => c_api_version,
                 p_init_msg_list => c_false,
                 p_commit => c_false,
                 p_encoded => c_true,
                 x_return_status => v_return_status,
                 x_msg_count => v_msg_count,
                 x_msg_data => v_msg_data,
                 p_ledger_id => p_ledger_id);

IF (v_local_vs_id = -1)
THEN
   RETURN 'N';
END IF;

BEGIN
   SELECT local_vs_combo_id
   INTO   v_rule_vs_id
   FROM fem_object_catalog_b
   WHERE object_id = p_object_id;
EXCEPTION
   WHEN no_data_found THEN
      RETURN 'N';
END;

   IF (v_local_vs_id = v_rule_vs_id)
   THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;

END Is_Rule_Valid_For_Ledger;

/*************************************************************************

                      Create_Local_VS_Combo_ID

*************************************************************************/

PROCEDURE Create_Local_VS_Combo_ID
IS
   v_app_grp NUMBER;
   v_global_vs_id NUMBER;
BEGIN

SELECT application_group_id
INTO   v_app_grp
FROM   fem_applications;

SELECT global_vs_combo_id
INTO   v_global_vs_id
FROM   fem_global_vs_combos_b;

END Create_Local_VS_Combo_ID;


/*************************************************************************

                       Relative_Cal_Period_ID
Purpose:  To identify an offset calendar period when given
          a base calendar period and an offset count, within
          the same level (Dimension Group) and Calendar of
          the base period.

The function works as follows:

It builds a list of all of the Calendar Periods for the level
and Calendar of the Base Period.  It orders these periods by
End Date and period number.  Note that because CAL_PERIOD_ID
is a composite key, it allows us to simploy order by CAL_PERIOD_ID
to achieve the desire sequence.  This is because the first 2
components of CAL_PERIOD_ID are End_Date (julian) and Period Number.

The function then counts up and down the list based upon the
offset value.

Adjustment periods are considered based upon the value for a new
attribute "USE_ADJ_PERIOD_FLAG" for the "CALENDAR" dimension.

For example - here is a possible list of Periods
(notice there is a gap for AUG):

Calendar = Financial
Level = Month

End Date Period Number  Adjustment Period Flag? Fiscal Year
JAN-31-2004 1  N  2003
FEB-28-2004 2  N  2003
MAR-31-2004 3  N  2003
MAR-31-2004 13 Y  2003
APR-30-2004 4  N  2004
MAY-31-2004 5  N  2004
JUN-30-2004 6  N  2004
JUL-31-2004 7  N  2004
SEP-30-2004 9  N  2004
OCT-31-2004 10 N  2004
NOV-30-2004 11 N  2004
DEC-31-2004 12 N  2004
DEC-31-2004 14 Y  2004


Example1 - Assuming Adjustment Periods are counted:
Base Period = JAN-31-2004
Offset = +4
Function returns - APR-30-2004

Example2 - Assuming Adjustment Periods are not counted:
Base Period = JAN-31-2004
Offset= +4
Function returns: MAY-31-2004

Example3:
Base Period = APR-30-2004
Offset=+6
Function returns: NOV-30-2004

Note: The function returns p_base_cal_period_id when p_per_num_offset = 0
(regardless of the adjustment period attribute settings).

*************************************************************************/

FUNCTION Relative_Cal_Period_ID (
   p_api_version        IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list      IN VARCHAR2   DEFAULT c_false,
   p_commit             IN VARCHAR2   DEFAULT c_false,
   p_encoded            IN VARCHAR2   DEFAULT c_true,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_per_num_offset     IN NUMBER,
   p_base_cal_period_id IN NUMBER
) RETURN NUMBER
IS
  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.relative_cal_period_id';
  C_LIMIT         CONSTANT NUMBER := 10000;  -- fetch limit
  e_unexp         EXCEPTION;

  TYPE cal_period_tbl_type IS TABLE OF FEM_CAL_PERIODS_B.cal_period_id%TYPE;
  v_cal_period_tbl   cal_period_tbl_type;
  TYPE cal_period_cur_type IS REF CURSOR;  -- define weak REF CURSOR type
  v_cal_period_cv    cal_period_cur_type;

  v_base_dimgrp_id   FEM_CAL_PERIODS_B.calendar_id%TYPE;
  v_base_calendar_id FEM_CAL_PERIODS_B.dimension_group_id%TYPE;
  v_dim_id           FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_dim_name         FEM_DIMENSIONS_TL.dimension_name%TYPE;
  v_dim_attr_id      FEM_DIM_ATTRIBUTES_B.attribute_id%TYPE;
  v_dim_attr_ver_id  FEM_DIM_ATTR_VERSIONS_B.version_id%TYPE;
  v_cal_attr_id      FEM_DIM_ATTRIBUTES_B.attribute_id%TYPE;
  v_cal_attr_ver_id  FEM_DIM_ATTR_VERSIONS_B.version_id%TYPE;
  v_cal_attr_name    FEM_DIM_ATTRIBUTES_TL.attribute_name%TYPE;
  v_incl_adj_period  FEM_CALENDARS_ATTR.dim_attribute_varchar_member%TYPE;

  v_return_code      NUMBER;
  v_sql              VARCHAR2(1000);
  v_offset           NUMBER;
  v_fetch_count      NUMBER;
  v_index            NUMBER;
  v_fetches_needed   NUMBER;
BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  x_return_status := c_success;

  Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

  IF (x_return_status <> c_success)
  THEN
    FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
    RETURN -1;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_per_num_offset = '||to_char(p_per_num_offset));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_base_cal_period_id = '||to_char(p_base_cal_period_id));
  END IF;

  -- Determine the dimension_group_id and calendar_id
  -- of the base period
  BEGIN
    SELECT calendar_id, dimension_group_id
    INTO v_base_calendar_id, v_base_dimgrp_id
    FROM fem_cal_periods_b
    WHERE cal_period_id = p_base_cal_period_id;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'v_base_calendar_id = '||to_char(v_base_calendar_id));
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'v_base_dimgrp_id = '||to_char(v_base_dimgrp_id));
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_error,
          p_module   => C_MODULE,
          p_msg_text => 'Calendar period '||to_char(p_base_cal_period_id)
            ||' cannot be found.');
      END IF;

   -- Log user message onto the message stack:
   -- Calendar Period 'CAL_PER' is invalid
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DATAX_LDR_BAD_CAL_PER_ERR',
         p_token1 => 'CAL_PER',
         p_value1 => TO_CHAR(p_base_cal_period_id));

      RAISE e_error;
  END;

  -- Obtain the value of the calendar attribute INCLUDE_ADJ_PERIOD_FLAG
  -- that determines whether or not Adjustment Periods
  -- will be considered in the relative period calc

  -- 1. Get the Dimension ID for Calendar.
  BEGIN
    SELECT dimension_id, dimension_name
    INTO v_dim_id, v_dim_name
    FROM fem_dimensions_vl
    WHERE dimension_varchar_label = 'CALENDAR';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension ID of Calendar dimenions is '
          ||to_char(v_dim_id));
    END IF;
  EXCEPTION
    WHEN others THEN
      IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_error,
          p_module   => C_MODULE,
          p_msg_text => 'CALENDAR dimension does not exist!');
      END IF;
      RAISE e_error;
  END;

  -- 2. Get the default dimension attribute id and version for
  --    calendar attribute INCLUDE_ADJ_PERIOD_FLAG.
  get_dim_attr_id_ver_id
     (p_dim_id      => v_dim_id,
      p_attr_label  => 'INCLUDE_ADJ_PERIOD_FLAG',
      x_attr_id     => v_cal_attr_id,
      x_ver_id      => v_cal_attr_ver_id,
      x_err_code    => v_return_code);

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_Dimension_Util_Pkg.get_dim_attr_id_ver_id'
          ||'(INCLUDE_ADJ_PERIOD_FLAG) returned with return code of '
          ||to_char(v_return_code));
  END IF;

  IF v_return_code <> 0 THEN  -- if not success

  -- Log debug message and put user user message on the message stack:
  -- The specified Dimension Attribute was not found. Please contact your System
  -- Administrator for assistance.
  -- Dimension: DIMENSION_VARCHAR_LABEL
  -- Attribute: ATTRIBUTE_VARCHAR_LABEL

    IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => FND_LOG.level_error,
         p_module   => C_MODULE,
         p_app_name => 'FEM',
         p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VER_ERR',
         p_token1 => 'DIMENSION_VARCHAR_LABEL',
         p_value1 => v_dim_name,
         p_token2 => 'ATTRIBUTE_VARCHAR_LABEL',
         p_value2 => 'INCLUDE_ADJ_PERIOD_FLAG');
     END IF;

     FEM_ENGINES_PKG.Put_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VER_ERR',
        p_token1 => 'DIMENSION_VARCHAR_LABEL',
        p_value1 => v_dim_name,
        p_token2 => 'ATTRIBUTE_VARCHAR_LABEL',
        p_value2 => 'INCLUDE_ADJ_PERIOD_FLAG');

    RAISE e_error;

  END IF;

  -- 3. Get the default version attribute assignment for
  -- calendar attribute INCLUDE_ADJ_PERIOD_FLAG.
  BEGIN
    SELECT dim_attribute_varchar_member
    INTO v_incl_adj_period
    FROM fem_calendars_attr
    WHERE attribute_id  = v_cal_attr_id
    AND version_id    = v_cal_attr_ver_id
    AND calendar_id   = v_base_calendar_id;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Calendar attribute INCLUDE_ADJ_PERIOD_FLAG is set to '
          ||v_incl_adj_period);
    END IF;
  EXCEPTION
    WHEN others THEN

      IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_error,
          p_module   => C_MODULE,
          p_msg_text => 'Calendar does not have attribute value for '
            ||'attribute INCLUDE_ADJ_PERIOD_FLAG');
      END IF;

   -- Put user user message on the message stack:
   -- A Valid Attribute value was not found for the specified Dimension Attribute.
   -- Please contact your System Administrator for assistance.
   -- Dimension: DIMENSION_VARCHAR_LABEL
   -- Attribute: ATTRIBUTE_VARCHAR_LABEL

      SELECT attribute_name
      INTO v_cal_attr_name
      FROM fem_dim_attributes_vl
      WHERE attribute_id = v_cal_attr_id;

      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VAL_ERR',
         p_token1 => 'DIMENSION_VARCHAR_LABEL',
         p_value1 => v_dim_name,
         p_token2 => 'ATTRIBUTE_VARCHAR_LABEL',
         p_value2 => v_cal_attr_name);

       RAISE e_error;
   END;

  -- Obtain the dim attribute id and attribute version id for
  -- the calendar period attribute ADJ_PERIOD_FLAG
  -- that determines if a calendar period is an adjustment period.

  -- 1. Get the Dimension ID for Calendar Period.
  BEGIN
    SELECT dimension_id, dimension_name
    INTO v_dim_id, v_dim_name
    FROM fem_dimensions_vl
    WHERE dimension_varchar_label = 'CAL_PERIOD';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension ID of Calendar Period dimenions is '
          ||to_char(v_dim_id));
    END IF;
  EXCEPTION
    WHEN others THEN
      IF FND_LOG.level_error >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_error,
          p_module   => C_MODULE,
          p_msg_text => 'CAL_PERIOD dimension does not exist!');
      END IF;
      RAISE e_error;
  END;

  -- 2. Get the default dimension attribute id and version for
  --    calendar period attribute ADJ_PERIOD_FLAG.
  get_dim_attr_id_ver_id
     (p_dim_id      => v_dim_id,
      p_attr_label  => 'ADJ_PERIOD_FLAG',
      x_attr_id     => v_dim_attr_id,
      x_ver_id      => v_dim_attr_ver_id,
      x_err_code    => v_return_code);

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'FEM_Dimension_Util_Pkg.get_dim_attr_id_ver_id '
          ||'(INCLUDE_ADJ_PERIOD_FLAG) returned with error code of '
          ||to_char(v_return_code));
  END IF;

  IF v_return_code <> 0 THEN  -- if not success

  -- Log a debug message and put user user message on the message stack:
  -- The specified Dimension Attribute was not found. Please contact your System
  -- Administrator for assistance.
  -- Dimension: DIMENSION_VARCHAR_LABEL
  -- Attribute: ATTRIBUTE_VARCHAR_LABEL

    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_error,
        p_module   => C_MODULE,
        p_app_name => 'FEM',
        p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VER_ERR',
        p_token1 => 'DIMENSION_VARCHAR_LABEL',
        p_value1 => v_dim_name,
        p_token2 => 'ATTRIBUTE_VARCHAR_LABEL',
        p_value2 => 'ADJ_PERIOD_FLAG');

     FEM_ENGINES_PKG.Put_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_ENG_NO_DIM_ATTR_VER_ERR',
        p_token1 => 'DIMENSION_VARCHAR_LABEL',
        p_value1 => v_dim_name,
        p_token2 => 'ATTRIBUTE_VARCHAR_LABEL',
        p_value2 => 'ADJ_PERIOD_FLAG');

     RAISE e_error;

  END IF;

  IF p_per_num_offset = 0 THEN

  -- 0 offset returns the base period as the relative period

    FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

    x_return_status := c_success;

    RETURN p_base_cal_period_id;

  END IF;

  -- Build the dynamic sql to return the relevant calendar periods
  -- needed for the relative offset calcs

  v_sql := 'SELECT CP.cal_period_id FROM fem_cal_periods_b CP';

  IF v_incl_adj_period = 'N' THEN
    v_sql := v_sql||',fem_cal_periods_attr CPA';
  END IF;

  v_sql := v_sql||' WHERE CP.calendar_id=:1'
    || ' AND CP.dimension_group_id=:2'
    || ' AND CP.cal_period_id';
  -- If offset is negative, then only look at earlier cal periods.
  -- Else, if offset is 0, then validate that the cal period
  --   being passed in actually exists.
  -- Else, only look at later cal periods.
  IF p_per_num_offset < 0 THEN
    v_sql := v_sql||'<';
  ELSIF p_per_num_offset = 0 THEN
    v_sql := v_sql||'=';
  ELSE
    v_sql := v_sql||'>';
  END IF;
  v_sql := v_sql||':3';

  IF v_incl_adj_period = 'N' THEN
    v_sql := v_sql||' AND CP.cal_period_id=CPA.cal_period_id'
      ||' AND CPA.attribute_id='||to_char(v_dim_attr_id)
      ||' AND CPA.version_id='||to_char(v_dim_attr_ver_id)
      ||' AND CPA.dim_attribute_varchar_member = ''N''';
  END IF;

  -- If offset is negative, then order by descending order.
  -- Else, order by ascending order.
  IF p_per_num_offset < 0 THEN
    v_sql := v_sql||' ORDER BY cal_period_id desc';
  ELSE
    v_sql := v_sql||' ORDER BY cal_period_id asc';
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Dynamic sql is '||v_sql);
  END IF;

  -- Fetch all of the cal periods for the same
  -- Calendar and Dimension Group into an array.
  -- As the number of calendar periods fetched can be large
  -- the bulk collect fetch is set with a limit.

  -- If the offset parameter is 0, set the offset variable
  -- to 1 since the table index starts at 1.
  -- Otherwise, the offset variable needs to be set as
  -- a positive number so it can be used as the table index.
  IF p_per_num_offset = 0 THEN
    v_offset := 1;
  ELSE
    v_offset := abs(p_per_num_offset);
  END IF;
  -- Counter to keep track of number of fetches
  v_fetch_count := 1;
  -- Number of fetches needed to reach the offset number.
  v_fetches_needed := ceil(v_offset/C_LIMIT);
  -- Position of the cal period in the table, adjusted to compensate
  --  for the multiple fetches
  v_index := mod(v_offset,C_LIMIT);

  OPEN v_cal_period_cv FOR v_sql
    USING v_base_calendar_id, v_base_dimgrp_id, p_base_cal_period_id;
  LOOP
    FETCH v_cal_period_cv BULK COLLECT INTO v_cal_period_tbl LIMIT C_LIMIT;
    -- Exit loop if there are no more rows to fetch (cv%NOTFOUND), or
    -- if there is no need to fetch any further as the offset
    -- number has already been reached.
    EXIT WHEN v_cal_period_cv%NOTFOUND or v_fetch_count>=v_fetches_needed;
    v_fetch_count := v_fetch_count + 1;
  END LOOP;
  CLOSE v_cal_period_cv;

  IF v_index > v_cal_period_tbl.count OR v_fetch_count < v_fetches_needed THEN

  -- If number of calendar periods found is less than the offset number,
  -- return -1 and set return status to error.

  -- Log debug and user messages:
  -- Invalid Calendar Period Offset: CAL_PERIOD_OFFSET. The offset is greater
  -- than the number of existing Calendar Periods before or after the base period.

    SELECT attribute_name
    INTO v_cal_attr_name
    FROM fem_dim_attributes_vl
    WHERE attribute_id = v_cal_attr_id;

    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_error,
      p_module   => C_MODULE,
      p_app_name => 'FEM',
      p_msg_name => 'FEM_INVALID_PERIOD_OFFSET',
      p_token1 => 'CAL_PERIOD_OFFSET',
      p_value1 => TO_CHAR(p_per_num_offset));

    FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_INVALID_PERIOD_OFFSET',
      p_token1 => 'CAL_PERIOD_OFFSET',
      p_value1 => TO_CHAR(p_per_num_offset));

    RAISE e_error;

  ELSE
    v_return_code := v_cal_period_tbl(v_index);
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_fetch_count = '||to_char(v_fetch_count));
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_fetches_needed = '||to_char(v_fetches_needed));
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_index = '||to_char(v_index));
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_cal_period_tbl.count = '||to_char(v_cal_period_tbl.count));
    FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Returning value = '||to_char(v_return_code));
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

  FND_MSG_PUB.Count_and_Get(
    p_encoded => p_encoded,
    p_count => x_msg_count,
    p_data => x_msg_data);

  x_return_status := c_success;

  RETURN v_return_code;

EXCEPTION

  WHEN e_error THEN

    FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;

    x_return_status := c_error;

    RETURN -1;

END Relative_Cal_Period_ID;


/*************************************************************************

                       Effective_Cal_Period_ID

*************************************************************************/

FUNCTION Effective_Cal_Period_ID (
   p_per_num_offset   IN NUMBER,
   p_rel_dim_grp_id   IN NUMBER,
   p_ledger_id        IN NUMBER,
   p_ref_cal_per_id   IN NUMBER,
   x_err_code         OUT NOCOPY  NUMBER,
   x_num_msg          OUT NOCOPY  NUMBER
) RETURN NUMBER
IS
BEGIN

x_err_code := 2;
x_num_msg := 0;
RETURN -1;

END Effective_Cal_Period_Id;


/*************************************************************************

                         Get_Cal_Period_ID

*************************************************************************
This function is called by the OGL integration.  Note
that the fiscal_year does not always match the calendar year, so this
procedure could return a cal_period_id where the Year of the End Date
belongs in a different year than the fiscal year.

The above version finds the CAL_PERIOD_ID where:
    CALENDAR_ID (in fem_cal_periods_b) is the same as the Calendar
    of the CAL_PERIOD_HIER_OBJ_DEF_ID attribute of the p_ledger_id

    DIMENSION_GROUP_ID (in fem_cal_periods_b) matches the
    DIMENSION_GROUP_ID from fem_dimension_grps_b where
    the DIMENSION_GROUP_DISPLAY_CODE = p_dim grp_dc

    Value for the GL_PERIOD_NUM attribute (in fem_cal_periods_attr)
    matches the value from p_cal_per_num

    Value for the ACCOUNTING_YEAR attribute (in fem_Cal_periods_attr)
    matches value in p_fiscal_year.

 HISTORY
    04-AUG-06 rflippo Bug 5060702 Split single sql statement into individual
                      statements to avoid cartesian join

*************************************************************************/

FUNCTION Get_Cal_Period_ID
  (p_ledger_id       IN NUMBER,
   p_dim_grp_dc      IN VARCHAR2,
   p_cal_per_num     IN NUMBER,
   p_fiscal_year     IN NUMBER)
RETURN NUMBER IS
   v_calp_dim_id        NUMBER;
   v_ledger_dim_id      NUMBER;

   v_cal_period_id      NUMBER;
   v_periodnum_attr_id  NUMBER;
   v_acctyear_attr_id   NUMBER;
   v_ledgerobj_attr_id  NUMBER;

   v_periodnum_vers_id  NUMBER;
   v_acctyear_vers_id   NUMBER;
   v_ledgerobj_vers_id  NUMBER;

   v_ledger_calphier_id NUMBER;
   v_ledger_calphier_obj_id NUMBER;
   v_calendar_id        NUMBER;
BEGIN

SELECT dimension_id
INTO v_calp_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label='CAL_PERIOD';

SELECT dimension_id
INTO v_ledger_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label='LEDGER';


SELECT attribute_id
INTO v_ledgerobj_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='CAL_PERIOD_HIER_OBJ_DEF_ID'
AND dimension_id = v_ledger_dim_id;

SELECT version_id
INTO v_ledgerobj_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_ledgerobj_attr_id
AND default_version_flag='Y';

SELECT dim_attribute_numeric_member
INTO v_ledger_calphier_id
FROM fem_ledgers_attr
WHERE ledger_id = p_ledger_id
AND attribute_id = v_ledgerobj_attr_id
AND version_id = v_ledgerobj_vers_id;

SELECT object_id
INTO v_ledger_calphier_obj_id
FROM fem_object_definition_b
WHERE object_definition_id = v_ledger_calphier_id;

SELECT calendar_id
INTO v_calendar_id
FROM fem_hierarchies
WHERE hierarchy_obj_id = v_ledger_calphier_obj_id;

SELECT attribute_id
INTO v_periodnum_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='GL_PERIOD_NUM'
AND dimension_id = v_calp_dim_id;

SELECT attribute_id
INTO v_acctyear_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='ACCOUNTING_YEAR'
AND dimension_id = v_calp_dim_id;

SELECT version_id
INTO v_periodnum_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_periodnum_attr_id
AND default_version_flag = 'Y';

SELECT version_id
INTO v_acctyear_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_acctyear_attr_id
AND default_version_flag = 'Y';


SELECT B.cal_period_id
INTO   v_cal_period_id
FROM   fem_cal_periods_b B,
       fem_cal_periods_attr N,
       fem_cal_periods_attr D,
       fem_dimension_grps_b G
WHERE  N.attribute_id = v_periodnum_attr_id
AND    N.version_id = v_periodnum_vers_id
AND    N.cal_period_id = B.cal_period_id
AND    N.number_assign_value = p_cal_per_num
AND    D.attribute_id = v_acctyear_attr_id
AND    D.version_id = v_acctyear_vers_id
AND    D.cal_period_id = B.cal_period_id
AND    D.number_assign_value = p_fiscal_year
AND    B.calendar_id = v_calendar_id
AND    G.dimension_group_id = B.dimension_group_id
AND    G.dimension_group_display_code = p_dim_grp_dc;
RETURN v_cal_period_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN -1;
   WHEN too_many_rows THEN
      RETURN -1;

END Get_Cal_Period_ID;

/*************************************************************************
This function is available for applications to call when they
want to find the corresponding CAL_PERIOD_ID for a given end date.

The above version finds the CAL_PERIOD_ID where:
    CALENDAR_ID (in fem_cal_periods_b) is the same as the Calendar
    of the CAL_PERIOD_HIER_OBJ_DEF_ID attribute of the p_ledger_id

    DIMENSION_GROUP_ID (in fem_cal_periods_b) matches the
    DIMENSION_GROUP_ID from fem_dimension_grps_b where
    the DIMENSION_GROUP_DISPLAY_CODE = p_dim grp_dc

    Value for the GL_PERIOD_NUM attribute (in fem_cal_periods_attr)
    matches the value from p_cal_per_num

    Value for the CAL_PERIOD_END_DATE attribute (in
    fem_Cal_periods_attr) matches value in p_cal_per_end_date.

    04-AUG-06 rflippo Bug 5060702 Split single sql statement into individual
                      statements to avoid cartesian join
*************************************************************************/

FUNCTION Get_Cal_Period_ID
  (p_ledger_id        IN NUMBER,
   p_dim_grp_dc       IN VARCHAR2,
   p_cal_per_num      IN NUMBER,
   p_cal_per_end_date IN DATE)
RETURN NUMBER IS
   v_calp_dim_id        NUMBER;
   v_ledger_dim_id      NUMBER;

   v_cal_period_id      NUMBER;
   v_periodnum_attr_id  NUMBER;
   v_enddate_attr_id   NUMBER;
   v_ledgerobj_attr_id  NUMBER;

   v_periodnum_vers_id  NUMBER;
   v_enddate_vers_id   NUMBER;
   v_ledgerobj_vers_id  NUMBER;

   v_ledger_calphier_id NUMBER;
   v_ledger_calphier_obj_id NUMBER;
   v_calendar_id        NUMBER;


BEGIN

SELECT dimension_id
INTO v_calp_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label='CAL_PERIOD';

SELECT dimension_id
INTO v_ledger_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label='LEDGER';


SELECT attribute_id
INTO v_ledgerobj_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='CAL_PERIOD_HIER_OBJ_DEF_ID'
AND dimension_id = v_ledger_dim_id;

SELECT version_id
INTO v_ledgerobj_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_ledgerobj_attr_id
AND default_version_flag='Y';

SELECT dim_attribute_numeric_member
INTO v_ledger_calphier_id
FROM fem_ledgers_attr
WHERE ledger_id = p_ledger_id
AND attribute_id = v_ledgerobj_attr_id
AND version_id = v_ledgerobj_vers_id;

SELECT object_id
INTO v_ledger_calphier_obj_id
FROM fem_object_definition_b
WHERE object_definition_id = v_ledger_calphier_id;

SELECT calendar_id
INTO v_calendar_id
FROM fem_hierarchies
WHERE hierarchy_obj_id = v_ledger_calphier_obj_id;

SELECT attribute_id
INTO v_periodnum_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='GL_PERIOD_NUM'
AND dimension_id = v_calp_dim_id;

SELECT attribute_id
INTO v_enddate_attr_id
FROM fem_dim_attributes_b
WHERE attribute_varchar_label='CAL_PERIOD_END_DATE'
AND dimension_id = v_calp_dim_id;

SELECT version_id
INTO v_periodnum_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_periodnum_attr_id
AND default_version_flag = 'Y';

SELECT version_id
INTO v_enddate_vers_id
FROM fem_dim_attr_versions_b
WHERE attribute_id = v_enddate_attr_id
AND default_version_flag = 'Y';


SELECT B.cal_period_id
INTO   v_cal_period_id
FROM   fem_cal_periods_b B,
       fem_cal_periods_attr N,
       fem_cal_periods_attr D,
       fem_dimension_grps_b G
WHERE  N.attribute_id = v_periodnum_attr_id
AND    N.version_id = v_periodnum_vers_id
AND    N.cal_period_id = B.cal_period_id
AND    N.number_assign_value = p_cal_per_num
AND    D.attribute_id = v_enddate_attr_id
AND    D.version_id = v_enddate_vers_id
AND    D.cal_period_id = B.cal_period_id
AND    D.date_assign_value = p_cal_per_end_date
AND    B.calendar_id = v_calendar_id
AND    G.dimension_group_id = B.dimension_group_id
AND    G.dimension_group_display_code = p_dim_grp_dc;

RETURN v_cal_period_id;

EXCEPTION
   WHEN no_data_found THEN
      RETURN -1;
   WHEN too_many_rows THEN
      RETURN -1;

END Get_Cal_Period_ID;

/*************************************************************************

                         Register_Data_Location

*************************************************************************/

PROCEDURE Register_Data_Location (
   p_request_id  NUMBER,
   p_object_id  NUMBER,
   p_table_name VARCHAR2,
   p_ledger_id  NUMBER,
   p_cal_per_id NUMBER,
   p_dataset_cd NUMBER,
   p_source_cd NUMBER,
   p_load_status VARCHAR2 DEFAULT NULL,
   p_avg_bal_flag    IN VARCHAR2 DEFAULT NULL,
   p_trans_curr      IN VARCHAR2 DEFAULT NULL
) IS
   v_ledger_col   VARCHAR2(30);
   v_cal_per_col  VARCHAR2(30);
   v_dataset_col  VARCHAR2(30);
   v_source_col   VARCHAR2(30);
   v_bal_type_col VARCHAR2(30);
   v_bal_type_cd  VARCHAR2(50);
   v_number       NUMBER;
   v_sql_cmd      VARCHAR2(32767);
   v_avg_balances NUMBER;
BEGIN
  -- Verify prcedure parameters are valid
  IF p_load_status IS NOT NULL AND
     p_load_status NOT IN ('COMPLETE','INCOMPLETE') THEN
    RAISE e_bad_param_value;
  END IF;

  IF p_avg_bal_flag IS NOT NULL AND
     p_avg_bal_flag NOT IN ('Y','N') THEN
    RAISE e_bad_param_value;
  END IF;

-- Comments by gcheng:
-- From looking at the legacy code, this is what I think it is doing.
--
-- If load status is not given (i.e. not being called from the loader),
-- make sure the dimension values actually exist on the table.
-- Only register data locations if dimension values are found.
--
-- Not sure why the check is not necessary wen called by the loaders.
-- Also, not sure why the dynamic sql selects from a hard-coded
-- column name for ledger ID, and not use v_ledger_col.
-- This is probably a mute issue because all existing tables
-- store ledger ID in columns named ledger_id.
IF (p_load_status IS NULL)
THEN
   SELECT column_name
   INTO   v_ledger_col
   FROM   fem_tab_columns_b
   WHERE  table_name = p_table_name
   AND    dimension_id =
             (SELECT dimension_id
              FROM fem_dimensions_b
              WHERE dimension_varchar_label = 'LEDGER');

   SELECT column_name
   INTO   v_cal_per_col
   FROM   fem_tab_columns_b
   WHERE  table_name = p_table_name
   AND    dimension_id =
             (SELECT dimension_id
              FROM fem_dimensions_b
              WHERE dimension_varchar_label = 'CAL_PERIOD');

   SELECT column_name
   INTO   v_dataset_col
   FROM   fem_tab_columns_b
   WHERE  table_name = p_table_name
   AND    dimension_id =
             (SELECT dimension_id
              FROM fem_dimensions_b
              WHERE dimension_varchar_label = 'DATASET');

   SELECT column_name
   INTO   v_source_col
   FROM   fem_tab_columns_b
   WHERE  table_name = p_table_name
   AND    dimension_id =
             (SELECT dimension_id
              FROM fem_dimensions_b
              WHERE dimension_varchar_label = 'SOURCE_SYSTEM');

   v_sql_cmd :=
   'SELECT MIN(ledger_id)'||
   ' FROM '||p_table_name||
   ' WHERE '||v_ledger_col||' = :b_ledger_id'||
   ' AND '||v_cal_per_col||' = :b_cal_per_id'||
   ' AND '||v_dataset_col||' = :b_dataset_cd'||
   ' AND '||v_source_col||' = :b_source_cd';

   EXECUTE IMMEDIATE v_sql_cmd
   INTO v_number
   USING p_ledger_id,
         p_cal_per_id,
         p_dataset_cd,
         p_source_cd;
ELSE
   v_number := 0;
END IF;

IF (v_number IS NOT NULL)
THEN
   -- Grab the dataset balance type code
   SELECT attribute_value_column_name
   INTO v_bal_type_col
   FROM fem_dim_attributes_b
   WHERE dimension_id =
     (SELECT dimension_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'DATASET')
   AND attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE';

   v_sql_cmd :=
   'SELECT '||v_bal_type_col||
   ' FROM fem_datasets_attr A,fem_dim_attr_versions_b V'||
   ' WHERE dataset_code = :b_dataset_cd'||
   ' AND A.attribute_id = '||
   '   (SELECT attribute_id'||
   '    FROM fem_dim_attributes_b'||
   '    WHERE dimension_id ='||
   '      (SELECT dimension_id'||
   '       FROM fem_dimensions_b'||
   '       WHERE dimension_varchar_label = ''DATASET'')'||
   '    AND attribute_varchar_label = ''DATASET_BALANCE_TYPE_CODE'')'||
   ' AND A.attribute_id = V.attribute_id'||
   ' AND A.version_id = V.version_id'||
   ' AND V.default_version_flag = ''Y''';

   EXECUTE IMMEDIATE v_sql_cmd
   INTO v_bal_type_cd
   USING p_dataset_cd;

   -- Determin avg_balances value.
   -- avg_balances should be 1 if avg_bal_flag is 'Y',
   --   0 if avg_bal_flag is 'N', and null otherwise.
   IF p_avg_bal_flag = 'Y' THEN
     v_avg_balances := 1;
   ELSIF p_avg_bal_flag = 'N' THEN
     v_avg_balances := 0;
   ELSE
     v_avg_balances := NULL;
   END IF;

   -- Insert into fem_dl_dimensions.
   -- If duplicate, update load status and avg_balances
   BEGIN
      INSERT INTO fem_dl_dimensions
        (request_id,
         object_id,
         ledger_id,
         cal_period_id,
         dataset_code,
         source_system_code,
         balance_type_code,
         table_name,
         avg_balances,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         load_status,
         reprocess_errors_flag,
         object_version_number)
      VALUES
         (p_request_id,
          p_object_id,
          p_ledger_id,
          p_cal_per_id,
          p_dataset_cd,
          p_source_cd,
          v_bal_type_cd,
          p_table_name,
          v_avg_balances,
          sysdate,
          c_user_id,
          c_user_id,
          sysdate,
          null,
          p_load_status,
          'N',
          1);
   EXCEPTION
      WHEN dup_val_on_index THEN
         UPDATE fem_dl_dimensions
         SET load_status = p_load_status,
             avg_balances = v_avg_balances,
             last_updated_by = c_user_id,
             last_update_date = sysdate
         WHERE request_id = p_request_id
         AND object_id = p_object_id
         AND ledger_id = p_ledger_id
         AND cal_period_id = p_cal_per_id
         AND dataset_code = p_dataset_cd
         AND source_system_code = p_source_cd
         AND table_name = p_table_name;
   END;

   -- If p_trans_curr is not null, insert into fem_dl_trans_curr
   -- Do nothing if inserting duplicate row.
   IF p_trans_curr IS NOT NULL THEN
     BEGIN
       INSERT INTO fem_dl_trans_curr
        (request_id,
         object_id,
         ledger_id,
         cal_period_id,
         dataset_code,
         source_system_code,
         table_name,
         translated_currency,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         object_version_number)
       VALUES
         (p_request_id,
          p_object_id,
          p_ledger_id,
          p_cal_per_id,
          p_dataset_cd,
          p_source_cd,
          p_table_name,
          p_trans_curr,
          sysdate,
          c_user_id,
          c_user_id,
          sysdate,
          null,
          1);
     EXCEPTION WHEN dup_val_on_index THEN null;
     END;
   END IF;
END IF;

END Register_Data_Location;


/*************************************************************************

                         UnRegister_Data_Location

*************************************************************************/

PROCEDURE UnRegister_Data_Location (
   p_request_id     IN NUMBER,
   p_object_id      IN NUMBER,
   p_table_name     IN VARCHAR2 DEFAULT NULL
) IS
-- =========================================================================
-- Purpose
--    Given an object execution, check if it has been chained to other
--    object executions.  If yes, this procedure also returns one
--    of the object executions chained to the given object execution.
-- History
--    01-30-06  G Cheng    Bug 4596447. Created.
-- Arguments
--    p_request_id         Object execution Concurrent Request ID
--    p_object_id          Object execution Object ID
--    p_table_name         Table name (Optional)
-- Logic
--    If the optional p_table_name parameter is provided, delete
--    data locations information for just one table.  Otherwise,
--    remove data locations information for all tables associated with
--    the object execution.
-- =========================================================================
BEGIN

  -- If p_table_name is not passed, then unregister the whole object execution.
  -- Otherwise, just unregister the data locations for the table.
  IF p_table_name IS NULL THEN
    DELETE FROM fem_dl_dimensions
    WHERE request_id = p_request_id
    AND object_id = p_object_id;

    DELETE FROM fem_dl_trans_curr
    WHERE request_id = p_request_id
    AND object_id = p_object_id;
  ELSE
    DELETE FROM fem_dl_dimensions
    WHERE request_id = p_request_id
    AND object_id = p_object_id
    AND table_name = p_table_name;

    DELETE FROM fem_dl_trans_curr
    WHERE request_id = p_request_id
    AND object_id = p_object_id
    AND table_name = p_table_name;
  END IF;
END UnRegister_Data_Location;

/*************************************************************************

                         Generate_Member_ID

*************************************************************************/

FUNCTION Generate_Member_ID (
   p_dim_id    IN NUMBER
) RETURN NUMBER
AS
   v_dim_label VARCHAR2(80);
   v_source_cd VARCHAR2(30);
   v_mem_id NUMBER;
BEGIN

BEGIN
   SELECT dimension_varchar_label
   INTO v_dim_label
   FROM fem_dimensions_b
   WHERE dimension_id = p_dim_id;
EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END;

BEGIN
   SELECT member_id_source_code
   INTO   v_source_cd
   FROM   fem_xdim_dimensions
   WHERE  dimension_id = p_dim_id
   AND    member_id_method_code = 'FUNCTION';
EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END;

CASE v_source_cd
   WHEN 'DATASET' THEN
      SELECT fem_datasets_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'SOURCE_SYSTEM' THEN
      SELECT fem_source_systems_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'CALENDAR' THEN
      SELECT fem_calendars_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'FLEX' THEN
      SELECT fnd_flex_values_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'LEDGER' THEN
      SELECT gl_sets_of_books_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ORG' THEN
      SELECT fem_cctr_orgs_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'BUDGET' THEN
      SELECT gl_budget_versions_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ENCUMBRANCE' THEN
      SELECT gl_encumbrance_types_s.NEXTVAL
      INTO v_mem_id FROM dual;
   ELSE
      RETURN null;
END CASE;

RETURN v_mem_id;

END Generate_Member_ID;

------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_dim_id    IN NUMBER,
   x_err_code OUT NOCOPY NUMBER,
   x_num_msg  OUT NOCOPY NUMBER
) RETURN NUMBER
AS
   v_dim_name VARCHAR2(80);
   v_source_cd VARCHAR2(30);
   v_mem_id NUMBER;

   no_source_code   EXCEPTION;
BEGIN

x_err_code := 0;
x_num_msg := 0;

IF (p_dim_id IS NOT NULL)
THEN
   BEGIN
      SELECT dimension_name
      INTO v_dim_name
      FROM fem_dimensions_tl
      WHERE dimension_id = p_dim_id
      AND   language = userenv('LANG');
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_dim_id;
   END;
ELSE
   RAISE e_null_param_value;
END IF;

BEGIN
   SELECT member_id_source_code
   INTO   v_source_cd
   FROM   fem_xdim_dimensions
   WHERE  dimension_id = p_dim_id
   AND    member_id_method_code = 'FUNCTION';
EXCEPTION
   WHEN no_data_found THEN
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RAISE no_source_code;
END;

CASE v_source_cd
   WHEN 'DATASET' THEN
      SELECT fem_datasets_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'SOURCE_SYSTEM' THEN
      SELECT fem_source_systems_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'CALENDAR' THEN
      SELECT fem_calendars_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'FLEX' THEN
      SELECT fnd_flex_values_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'LEDGER' THEN
      SELECT gl_sets_of_books_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ORG' THEN
      SELECT fem_cctr_orgs_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'BUDGET' THEN
      SELECT gl_budget_versions_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ENCUMBRANCE' THEN
      SELECT gl_encumbrance_types_s.NEXTVAL
      INTO v_mem_id FROM dual;
   ELSE
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RAISE no_source_code;
END CASE;

RETURN v_mem_id;

EXCEPTION
   WHEN no_source_code THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_SOURCE_CODE_ERR',
         p_token1 => 'DIMENSION',
         p_value1 => v_dim_name);
      RETURN -1;

   WHEN e_bad_dim_id THEN
      FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_DIM_ID_ERR',
         p_token1 => 'DIM_ID',
         p_value1 => p_dim_id);
      RETURN -1;

   WHEN e_null_param_value THEN
      FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => 'FEM_DIMENSION_TXT',
         p_trans1 => 'Y');
      RETURN -1;

END Generate_Member_ID;

------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dim_id          IN NUMBER
) RETURN NUMBER
AS
   v_dim_name VARCHAR2(80);
   v_source_cd VARCHAR2(30);
   v_mem_id NUMBER;

   no_source_code   EXCEPTION;
BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

IF (p_dim_id IS NOT NULL)
THEN
   BEGIN
      SELECT dimension_name
      INTO v_dim_name
      FROM fem_dimensions_tl
      WHERE dimension_id = p_dim_id
      AND   language = userenv('LANG');
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_bad_dim_id;
   END;
ELSE
   RAISE e_null_param_value;
END IF;

BEGIN
   SELECT member_id_source_code
   INTO   v_source_cd
   FROM   fem_xdim_dimensions
   WHERE  dimension_id = p_dim_id
   AND    member_id_method_code = 'FUNCTION';
EXCEPTION
   WHEN no_data_found THEN
      RAISE no_source_code;
END;

CASE v_source_cd
   WHEN 'DATASET' THEN
      SELECT fem_datasets_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'SOURCE_SYSTEM' THEN
      SELECT fem_source_systems_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'CALENDAR' THEN
      SELECT fem_calendars_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'FLEX' THEN
      SELECT fnd_flex_values_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'LEDGER' THEN
      SELECT gl_sets_of_books_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ORG' THEN
      SELECT fem_cctr_orgs_b_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'BUDGET' THEN
      SELECT gl_budget_versions_s.NEXTVAL
      INTO v_mem_id FROM dual;
   WHEN 'ENCUMBRANCE' THEN
      SELECT gl_encumbrance_types_s.NEXTVAL
      INTO v_mem_id FROM dual;
   ELSE
      RAISE no_source_code;
END CASE;

RETURN v_mem_id;

EXCEPTION
   WHEN no_source_code THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_SOURCE_CODE_ERR',
         p_token1 => 'DIMENSION',
         p_value1 => v_dim_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_bad_dim_id THEN
      FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_DIM_ID_ERR',
         p_token1 => 'DIM_ID',
         p_value1 => p_dim_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_null_param_value THEN
      FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => 'FEM_DIMENSION_TXT',
         p_trans1 => 'Y');
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

END Generate_Member_ID;

--------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_end_date        IN   DATE,
   p_period_num      IN   NUMBER,
   p_calendar_id     IN   NUMBER,
   p_dim_grp_id      IN   NUMBER
) RETURN NUMBER
IS
   v_cal_per_id     NUMBER;
   v_num_of_periods NUMBER;
   v_julian_date    VARCHAR2(7);
   v_period_chr     VARCHAR2(15);
   v_calendar_chr   VARCHAR2(5);
   v_dim_grp_key    VARCHAR2(5);
BEGIN

SELECT TO_CHAR(p_end_date,'J')
INTO v_julian_date
FROM dual;

BEGIN
   SELECT T.number_assign_value
   INTO v_num_of_periods
   FROM fem_time_grp_types_attr T,
        fem_dimension_grps_b G,
        fem_dim_attributes_b A,
        fem_dim_attr_versions_b V
   WHERE G.dimension_group_id = p_dim_grp_id
   AND A.attribute_varchar_label = 'PERIODS_IN_YEAR'
   AND A.attribute_id = T.attribute_id
   AND G.time_group_type_code = T.time_group_type_code
   AND V.attribute_id = T.attribute_id
   AND V.version_id = T.version_id
   AND V.default_version_flag = 'Y';
EXCEPTIOn
   WHEN no_data_found THEN
      RETURN null;
   WHEN too_many_rows THEN
      RETURN null;
END;

-- IF (p_period_num > v_num_of_periods)
-- THEN
--    RETURN null;
-- END IF;

SELECT LPAD(TO_CHAR(p_period_num),15,'0')
INTO v_period_chr
FROM dual;

BEGIN
   SELECT LPAD(TO_CHAR(calendar_id),5,'0')
   INTO v_calendar_chr
   FROM fem_calendars_b
   WHERE calendar_id = p_calendar_id;
EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END;

SELECT LPAD(TO_CHAR(time_dimension_group_key),5,'0')
INTO v_dim_grp_key
FROM fem_dimension_grps_b
WHERE dimension_group_id = p_dim_grp_id;

SELECT TO_NUMBER(v_julian_date||v_period_chr||v_calendar_chr||v_dim_grp_key)
INTO v_cal_per_id
FROM dual;

RETURN v_cal_per_id;

END Generate_Member_ID;

--------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_end_date        IN   DATE,
   p_period_num      IN   NUMBER,
   p_calendar_dc     IN   VARCHAR2,
   p_dim_grp_dc      IN   VARCHAR2
) RETURN NUMBER
IS
   v_cal_per_id     NUMBER;
   v_num_of_periods NUMBER;
   v_julian_date    VARCHAR2(7);
   v_period_chr     VARCHAR2(15);
   v_calendar_chr   VARCHAR2(5);
   v_dim_grp_key    VARCHAR2(5);
BEGIN

SELECT TO_CHAR(p_end_date,'J')
INTO v_julian_date
FROM dual;

BEGIN
   SELECT T.number_assign_value
   INTO v_num_of_periods
   FROM fem_time_grp_types_attr T,
        fem_dimension_grps_b G,
        fem_dim_attributes_b A,
        fem_dim_attr_versions_b V
   WHERE G.dimension_group_display_code = p_dim_grp_dc
   AND A.attribute_varchar_label = 'PERIODS_IN_YEAR'
   AND A.attribute_id = T.attribute_id
   AND G.time_group_type_code = T.time_group_type_code
   AND V.attribute_id = T.attribute_id
   AND V.version_id = T.version_id
   AND V.default_version_flag = 'Y';
EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
   WHEN too_many_rows THEN
      RETURN null;
END;

-- IF (p_period_num > v_num_of_periods)
-- THEN
--    RETURN null;
-- END IF;

SELECT LPAD(TO_CHAR(p_period_num),15,'0')
INTO v_period_chr
FROM dual;

BEGIN
   SELECT LPAD(TO_CHAR(calendar_id),5,'0')
   INTO v_calendar_chr
   FROM fem_calendars_b
   WHERE calendar_display_code = p_calendar_dc;
EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END;

SELECT LPAD(TO_CHAR(time_dimension_group_key),5,'0')
INTO v_dim_grp_key
FROM fem_dimension_grps_b
WHERE dimension_group_display_code = p_dim_grp_dc;

SELECT TO_NUMBER(v_julian_date||v_period_chr||v_calendar_chr||v_dim_grp_key)
INTO v_cal_per_id
FROM dual;

RETURN v_cal_per_id;

END Generate_Member_ID;

--------------------------------------------------------------------------
FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_dc     IN VARCHAR2,
   p_dim_grp_dc      IN VARCHAR2
) RETURN NUMBER IS

   v_cal_per_id     NUMBER;

BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

v_cal_per_id := Generate_Member_ID (p_end_date => p_end_date
                                   ,p_period_num => p_period_num
                                   ,p_calendar_dc => p_calendar_dc
                                   ,p_dim_grp_dc => p_dim_grp_dc);


RETURN v_cal_per_id;

END Generate_Member_ID;


------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_id     IN NUMBER,
   p_dim_grp_id      IN NUMBER,
   x_err_code       OUT NOCOPY   NUMBER,
   x_num_msg        OUT NOCOPY   NUMBER
) RETURN NUMBER
IS
   v_cal_per_id     NUMBER;
   v_num_of_periods NUMBER;
   v_attr_value     VARCHAR2(150);
   v_julian_date    VARCHAR2(7);
   v_period_chr     VARCHAR2(15);
   v_calendar_chr   VARCHAR2(5);
   v_dim_grp_key    VARCHAR2(5);
BEGIN

x_err_code := 0;
x_num_msg := 0;

SELECT TO_CHAR(p_end_date,'J')
INTO v_julian_date
FROM dual;

BEGIN
   SELECT T.number_assign_value
   INTO v_num_of_periods
   FROM fem_time_grp_types_attr T,
        fem_dimension_grps_b G,
        fem_dim_attributes_b A,
        fem_dim_attr_versions_b V
   WHERE G.dimension_group_id = p_dim_grp_id
   AND A.attribute_varchar_label = 'PERIODS_IN_YEAR'
   AND A.attribute_id = T.attribute_id
   AND G.time_group_type_code = T.time_group_type_code
   AND V.attribute_id = T.attribute_id
   AND V.version_id = T.version_id
   AND V.default_version_flag = 'Y';
EXCEPTION
   WHEN no_data_found THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                          p_dim_label => 'TIME_GROUP_TYPE',
                          p_attr_label => 'PERIODS_IN_YEAR');
      RAISE e_no_value_found;
   WHEN too_many_rows THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                          p_dim_label => 'TIME_GROUP_TYPE',
                          p_attr_label => 'PERIODS_IN_YEAR');
      RAISE e_many_values_found;
END;

-- IF (p_period_num > v_num_of_periods)
-- THEN
--    v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
--                        p_dim_label => 'CAL_PERIOD',
--                        p_attr_label => 'GL_PERIOD_NUM');
--    v_attr_value := TO_CHAR(p_period_num);
--    RAISE e_bad_param_value;
-- END IF;

SELECT LPAD(TO_CHAR(p_period_num),15,'0')
INTO v_period_chr
FROM dual;

BEGIN
   SELECT LPAD(TO_CHAR(calendar_id),5,'0')
   INTO v_calendar_chr
   FROM fem_calendars_b
   WHERE calendar_id = p_calendar_id;
EXCEPTION
   WHEN no_data_found THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                          p_dim_label => 'CALENDAR');
      v_attr_value := TO_CHAR(p_calendar_id);
      RAISE e_bad_param_value;
END;

SELECT LPAD(TO_CHAR(time_dimension_group_key),5,'0')
INTO v_dim_grp_key
FROM fem_dimension_grps_b
WHERE dimension_group_id = p_dim_grp_id;

SELECT TO_NUMBER(v_julian_date||v_period_chr||v_calendar_chr||v_dim_grp_key)
INTO v_cal_per_id
FROM dual;
RETURN v_cal_per_id;

EXCEPTION
   WHEN e_bad_param_value THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => v_token_value,
         p_trans1 => null,
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RETURN -1;

   WHEN e_no_value_found THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RETURN -1;

   WHEN e_many_values_found THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_MANY_VALUES_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;
      RETURN -1;
END Generate_Member_ID;

------------------------------------------------------------------------

FUNCTION Generate_Member_ID (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_end_date        IN DATE,
   p_period_num      IN NUMBER,
   p_calendar_id     IN NUMBER,
   p_dim_grp_id      IN NUMBER
) RETURN NUMBER
IS
   v_cal_per_id     NUMBER;
   v_num_of_periods NUMBER;
   v_julian_date    VARCHAR2(7);
   v_period_chr     VARCHAR2(15);
   v_calendar_chr   VARCHAR2(5);
   v_dim_grp_key    VARCHAR2(5);
   v_attr_value     VARCHAR2(150);
BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

SELECT TO_CHAR(p_end_date,'J')
INTO v_julian_date
FROM dual;

BEGIN
   SELECT T.number_assign_value
   INTO v_num_of_periods
   FROM fem_time_grp_types_attr T,
        fem_dimension_grps_b G,
        fem_dim_attributes_b A,
        fem_dim_attr_versions_b V
   WHERE G.dimension_group_id = p_dim_grp_id
   AND A.attribute_varchar_label = 'PERIODS_IN_YEAR'
   AND A.attribute_id = T.attribute_id
   AND G.time_group_type_code = T.time_group_type_code
   AND V.attribute_id = T.attribute_id
   AND V.version_id = T.version_id
   AND V.default_version_flag = 'Y';
EXCEPTION
   WHEN no_data_found THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                       p_dim_label => 'TIME_GROUP_TYPE',
                       p_attr_label => 'PERIODS_IN_YEAR');
      RAISE e_no_value_found;
   WHEN too_many_rows THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                       p_dim_label => 'TIME_GROUP_TYPE',
                       p_attr_label => 'PERIODS_IN_YEAR');
      RAISE e_many_values_found;
END;

-- IF (p_period_num > v_num_of_periods)
-- THEN
--    v_token_value := FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
--                     p_dim_label => 'CAL_PERIOD',
--                     p_attr_label => 'GL_PERIOD_NUM');
--    v_attr_value := TO_CHAR(p_period_num);
--    RAISE e_bad_param_value;
-- END IF;

SELECT LPAD(TO_CHAR(p_period_num),15,'0')
INTO v_period_chr
FROM dual;

BEGIN
   SELECT LPAD(TO_CHAR(calendar_id),5,'0')
   INTO v_calendar_chr
   FROM fem_calendars_b
   WHERE calendar_id = p_calendar_id;
EXCEPTION
   WHEN no_data_found THEN
      v_token_value := FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                       p_dim_label => 'CALENDAR');
      v_attr_value := TO_CHAR(p_calendar_id);
      RAISE e_bad_param_value;
END;

SELECT LPAD(TO_CHAR(time_dimension_group_key),5,'0')
INTO v_dim_grp_key
FROM fem_dimension_grps_b
WHERE dimension_group_id = p_dim_grp_id;

SELECT TO_NUMBER(v_julian_date||v_period_chr||v_calendar_chr||v_dim_grp_key)
INTO v_cal_per_id
FROM dual;

RETURN v_cal_per_id;

EXCEPTION
   WHEN e_bad_param_value THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => v_token_value,
         p_trans1 => null,
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_no_value_found THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VALUE_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;

   WHEN e_many_values_found THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_MANY_VALUES_FOUND_ERR',
         p_token1 => 'ENTITY',
         p_value1 => v_token_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN -1;
END Generate_Member_ID;


/*************************************************************************

                       Generate_Default_Load_Member

PURPOSE:  This procedure creates a default member for dimensions
          that do not already have any members in the system.
          The new member is named "Default".  This procedure is
          overloaded and each version performs a slightly different task.

          If called with a dimension (and value set for VSR dimensions),
          this version will return the default member for the dimension
          (and value set).  If a default member already exists, this
          version will return that default member.  If members exist
          but no default has yet been designated, this version will
          return the first member that was created in the system and
          set that as the new default member.  If no members exist, this
          version will create a default member and set that as the default member.

          If called with just a value set, this version will set a default
          member for the value set.  If a default member already exists,
          this version does nothing.  If members exist but no default has
          yet been designated, this version will find the first member that
          was created in the system and set that as the new default member.
          If no members exist, this version will create a default member and
          set that as the default member.

          If called with no API-specific parameters, this version generates
          default members for all dimensions that can be defaulted.  For each
          Value Set Required (VSR) dimension, this version will populate all
          dimension value sets (FEM_VALUE_SETS_B) with the newly created
          default member.  For each non-VSR dimension, this version will
          populate the dimensions metadata (FEM_XDIM_DIMENSIONS) with the
          default member display code.

          When each member is created, the procedure also creates the
          assignments for any required attributes of the dimension.
          These assignments are defined in the fem_dim_attributes_b.

          This procedure is run at installation time.  It may also
          be called separately after installation.

*************************************************************************/

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_dim_label       IN VARCHAR2,
   p_vs_id           IN NUMBER     DEFAULT NULL,
   x_member_code    OUT NOCOPY VARCHAR2
)
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.generate_default_load_member(1)';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Genereate_Default_Load_Member';

  v_sql               VARCHAR2(8191);
  v_member_code       VARCHAR2(250);
  v_member_dc         VARCHAR2(250);
  v_member_name       VARCHAR2(150);
  v_member_desc       VARCHAR2(255);
  v_dim_id            FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_member_b_tab      FEM_XDIM_DIMENSIONS.member_b_table_name%TYPE;
  v_member_col        FEM_XDIM_DIMENSIONS.member_col%TYPE;
  v_member_dc_col     FEM_XDIM_DIMENSIONS.member_display_code_col%TYPE;
  v_member_name_col   FEM_XDIM_DIMENSIONS.member_name_col%TYPE;
  v_member_desc_col   FEM_XDIM_DIMENSIONS.member_description_col%TYPE;
  v_member_data_type_code  FEM_XDIM_DIMENSIONS.member_data_type_code%TYPE;
  v_group_use_code    FEM_XDIM_DIMENSIONS.group_use_code%TYPE;
  v_attr_tab          FEM_XDIM_DIMENSIONS.attribute_table_name%TYPE;
  v_vsr_flag          FEM_XDIM_DIMENSIONS.value_set_required_flag%TYPE;
  v_default_member_dc FEM_XDIM_DIMENSIONS.default_member_display_code%TYPE;
  v_member_id_method_code  FEM_XDIM_DIMENSIONS.member_id_method_code%TYPE;
  v_default_load_member_id FEM_VALUE_SETS_B.default_load_member_id%TYPE;
  v_member_pkg        VARCHAR2(30);

  -- This cursor retrieves all of the required attributes
  -- of the dimension of the value set
  CURSOR c_req_attr (p_dimension_id NUMBER) IS
      SELECT A.attribute_id,
             A.attribute_varchar_label,
              A.attribute_value_column_name,
              A.attribute_data_type_code,
                A.default_assignment,
             A.default_assignment_vs_id,
             V.version_id
      FROM fem_dim_attributes_b A, fem_dim_attr_versions_b V
      WHERE A.attribute_required_flag = 'Y'
      AND A.dimension_id = p_dimension_id
      AND V.version_id =
        (SELECT min(version_id)
         FROM fem_dim_attr_versions_b V2
         WHERE V2.attribute_id = A.attribute_id
         AND V2.default_version_flag = 'Y');

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  gen_default_load_member1_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_dim_label = '||p_dim_label);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_vs_id = '||to_char(p_vs_id));
  END IF;

  -- Get dimension info.
  -- This API will only populate default members for those dimensions where
  --  * members can be created in DHM, i.e. not seeded or created
  --    through another mechanism (READ_ONLY_FLAG = 'N')
  --  * is not a composite dimension (COMPOSITE_DIMENSION_FLAG = 'N')
  --  * dimension is a not hidden dimension and shows up in DHM
  --    (HIER_EDITOR_MANAGED_FLAG = 'Y')
  BEGIN
    SELECT d.dimension_id,
           x.member_b_table_name,
           x.member_col,
           x.member_display_code_col,
           x.member_name_col,
           x.member_description_col,
           x.member_data_type_code,
           x.group_use_code,
           x.attribute_table_name,
           x.value_set_required_flag,
           x.member_id_method_code,
           x.default_member_display_code,
           REPLACE(x.member_b_table_name||'XYZ','_BXYZ','_PKG')
    INTO   v_dim_id,
           v_member_b_tab,
           v_member_col,
           v_member_dc_col,
           v_member_name_col,
           v_member_desc_col,
           v_member_data_type_code,
           v_group_use_code,
           v_attr_tab,
           v_vsr_flag,
           v_member_id_method_code,
           v_default_member_dc,
           v_member_pkg
    FROM   fem_xdim_dimensions x, fem_dimensions_b d
    WHERE  d.dimension_varchar_label = p_dim_label
    AND    x.read_only_flag = 'N'
    AND    x.composite_dimension_flag = 'N'
    AND    x.hier_editor_managed_flag = 'Y'
    AND    x.dimension_id = d.dimension_id;
  EXCEPTION
    WHEN no_data_found THEN
      FEM_Engines_Pkg.Put_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_BAD_DIM_ID_ERR',
        p_token1 => 'DIM_ID',
        p_value1 => v_dim_id);
      RAISE e_error;
  END;

  -- Check that value set exists if dimension is VSR
  IF v_vsr_flag = 'Y' THEN
    BEGIN
      SELECT default_load_member_id
      INTO   v_default_load_member_id
      FROM   fem_value_sets_b
      WHERE  value_set_id = p_vs_id
      AND    dimension_id = v_dim_id;
    EXCEPTION
      WHEN no_data_found THEN
        FEM_Engines_Pkg.Put_Message(
           p_app_name => 'FEM',
           p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
           p_token1 => 'PARAM',
           p_value1 => 'FEM_VALUE_SET_TXT',
           p_trans1 => 'Y',
           p_token2 => 'VALUE',
           p_value2 => p_vs_id);
        RAISE e_error;
    END;
  END IF; -- v_vsr_flag = 'Y'

  -- Initialize
  v_member_code := null;

  -- If defaults already exist, verify that the member exists
  IF (v_vsr_flag = 'N' AND v_default_member_dc IS NOT NULL) OR
     (v_vsr_flag = 'Y' AND v_default_load_member_id IS NOT NULL) THEN
    v_sql := 'SELECT '||v_member_col||', '||v_member_dc_col
          ||' FROM '||v_member_b_tab;
    IF v_vsr_flag = 'N' THEN
      v_sql := v_sql||' WHERE '||v_member_dc_col||' = :1';
    ELSE
      v_sql := v_sql||' WHERE '||v_member_col||' = :1'
          ||' AND value_set_id = :2';
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql = '||v_sql);
    END IF;

    BEGIN
      IF v_vsr_flag = 'N' THEN
        EXECUTE IMMEDIATE v_sql INTO v_member_code, v_member_dc USING v_default_member_dc;
      ELSE
        EXECUTE IMMEDIATE v_sql INTO v_member_code, v_member_dc USING v_default_load_member_id, p_vs_id;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        v_default_member_dc := null;
        v_default_load_member_id := null;
        v_member_code := null;
    END;
  END IF;

  -- If default does not exist, check if any members exist
  IF v_member_code IS NULL THEN
    -- If the dimension already has a member,
    -- return the first created member.
    v_sql :=  'SELECT MAX('||v_member_col||') KEEP (DENSE_RANK FIRST ORDER BY creation_date),'
           ||' MAX('||v_member_dc_col||') KEEP (DENSE_RANK FIRST ORDER BY creation_date)'
           ||' FROM '||v_member_b_tab;
    IF v_vsr_flag = 'Y' THEN
      v_sql := v_sql||' WHERE value_set_id = :1';
    END IF;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql = '||v_sql);
    END IF;

    BEGIN
      IF v_vsr_flag = 'Y' THEN
        EXECUTE IMMEDIATE v_sql INTO v_member_code, v_member_dc USING p_vs_id;
      ELSE
        EXECUTE IMMEDIATE v_sql INTO v_member_code, v_member_dc;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        v_member_code := null;
    END;
  END IF; -- v_member_code IS NULL

  -- If no members exist, then create default member
  IF v_member_code IS NULL THEN
    -- the default member display code is hard coded
    v_member_dc := 'Default';

    IF v_member_id_method_code = 'FUNCTION' THEN
      v_member_code := FEM_Dimension_Util_Pkg.Generate_Member_ID (
                  p_api_version => 1.0,
                  p_init_msg_list => c_false,
                  p_commit => c_false,
                  p_encoded => p_encoded,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_dim_id => v_dim_id);
    ELSE
      IF v_member_data_type_code = 'VARCHAR' THEN
        -- Display code is only necessary if the member code column
        -- is a surrogate key column (which should have a NUMBER data type).
        -- IF that is not the case, this API does not know what value to
        -- use to default the display code column and errors.
        IF v_member_col <> v_member_dc_col THEN
          IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_exception,
              p_module   => C_MODULE,
              p_msg_text => 'Dimension member display code column ('||v_member_dc_col
                          ||') must be same as member code column ('||v_member_col
                          ||') if member data type is VARCHAR.');
          END IF;
          RAISE e_unexp;
        END IF; -- v_member_col <> v_member_dc_col

        v_member_code := v_member_dc;
      ELSE
        -- If member data type is not VARCHAR, this API
        -- does not know what value to default so it errors.
        IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_exception,
            p_module   => C_MODULE,
            p_msg_text => 'Dimension member data type ('||v_member_data_type_code
                        ||') has to be VARCHAR if the member ID source code is not FUNCTION');
        END IF;
        RAISE e_unexp;
      END IF; -- v_member_data_type_code = 'VARCHAR'
    END IF; -- v_member_id_source_code = 'FUNCTION'

    ----------------------------------------------------------
    -- Insert new member using Dimension table handler package
    ----------------------------------------------------------

    -- First get the translated default member name and description
    FND_MESSAGE.Set_Name('FEM','FEM_DEFAULT_TXT');
    v_member_name := substr(FND_MESSAGE.Get,1,150);
    FND_MESSAGE.Set_Name('FEM','FEM_DEFAULT_MEMBER_TXT');
    v_member_desc := substr(FND_MESSAGE.Get,1,255);

    v_sql :=
      'DECLARE v_rowid VARCHAR2(20);'||
      ' BEGIN '||
         v_member_pkg||'.INSERT_ROW('||
        'x_rowid => v_rowid,';

    IF v_member_data_type_code = 'NUMBER' THEN
      v_sql := v_sql||'x_'||substr(v_member_col,1,28)||' => '||v_member_code||',';
    ELSIF v_member_data_type_code = 'VARCHAR' THEN
      v_sql := v_sql||'x_'||substr(v_member_col,1,28)||' => '''||v_member_code||''',';
    ELSE
      IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_exception,
          p_module   => C_MODULE,
          p_msg_text => 'Member data type ('||v_member_data_type_code
                      ||') must be is not NUMBER or VARCHAR.');
      END IF;
      RAISE e_unexp;
    END IF;

    IF v_member_id_method_code = 'FUNCTION' THEN
      v_sql := v_sql||'x_'||substr(v_member_dc_col,1,28)||' => '''||v_member_dc||''',';
    END IF;

    IF v_vsr_flag = 'Y' THEN
      v_sql := v_sql||'x_value_set_id => '||p_vs_id||',';
    END IF;

    IF v_group_use_code <> 'NOT_SUPPORTED' THEN
      v_sql := v_sql||'x_dimension_group_id => null,';
    END IF;

    v_sql := v_sql||
        'x_'||substr(v_member_name_col,1,28)||' => '''||v_member_name||''','||
        'x_'||substr(v_member_desc_col,1,28)||' => '''||v_member_desc||''','||
        'x_enabled_flag => ''Y'','||
        'x_personal_flag => ''N'','||
        'x_read_only_flag => ''N'','||
        'x_object_version_number => 1,'||
        'x_creation_date => sysdate,'||
        'x_created_by => '||c_user_id||','||
        'x_last_update_date => sysdate,'||
        'x_last_updated_by => '||c_user_id||','||
        'x_last_update_login => null);'||
      ' END;';

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'v_sql = '||v_sql);
    END IF;

    BEGIN
      EXECUTE IMMEDIATE v_sql;
    EXCEPTION
      WHEN dup_val_on_index THEN
        FEM_Engines_Pkg.Put_Message(
          p_app_name => 'FEM',
          p_msg_name => 'FEM_DUP_NEW_MEMBER_ERR',
          p_token1 => 'VALUE',
          p_value1 => v_member_code,
          p_trans1 => 'N',
          p_token2 => 'DIMENSION',
          p_value2 => FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                        p_dim_id => v_dim_id));
        RAISE e_error;
    END;

    ----------------------------------------
    -- Create attribute assignments for the new member,
    -- but only for the required attributes.
    -- If the assignment value is a DATE, it will be stored as a VARCHAR2
    -- in the Canonical date format as defined in FND_DATE package.
    ----------------------------------------
    IF v_attr_tab IS NOT NULL THEN
      FOR attr IN c_req_attr (v_dim_id) LOOP
        -- Raise error if no default assignment is found
        IF attr.default_assignment IS NULL THEN
          FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_XDIM_UTIL_ATTR_NODEFAULT',
            p_token1 => 'DIMLABEL',
            p_value1 => p_dim_label,
            p_trans1 => 'N',
            p_token2 => 'ATTRLABEL',
            p_value2 => attr.attribute_varchar_label,
            p_trans2 => 'N');
          RAISE e_error;
        END IF;
        -- Otherwise, insert the attribute assignment
        v_sql := 'INSERT INTO '||v_attr_tab||
                          ' (ATTRIBUTE_ID'||
                          ',VERSION_ID'||
                          ','||v_member_col;
        IF v_vsr_flag = 'Y' THEN
          v_sql := v_sql||',VALUE_SET_ID';
        END IF;
        IF attr.default_assignment_vs_id IS NOT NULL THEN
          v_sql := v_sql||',DIM_ATTRIBUTE_VALUE_SET_ID';
        END IF;
        v_sql := v_sql||
                          ','||attr.attribute_value_column_name||
                          ',CREATION_DATE'||
                          ',CREATED_BY'||
                          ',LAST_UPDATED_BY'||
                          ',LAST_UPDATE_DATE'||
                          ',LAST_UPDATE_LOGIN'||
                          ',OBJECT_VERSION_NUMBER'||
                          ',AW_SNAPSHOT_FLAG)'||
                          ' select '||attr.attribute_id||
                          ','||attr.version_id||
                          ','||v_member_code;
        IF v_vsr_flag = 'Y' THEN
          v_sql := v_sql||','||p_vs_id;
        END IF;
        IF attr.default_assignment_vs_id IS NOT NULL THEN
          v_sql := v_sql||','''||attr.default_assignment_vs_id||'''';
        END IF;
        -- If the attribute is a DATE, it would have been stored
        -- in DEFAULT_ASSIGNMENT in the canonical format.
        -- Otherwise, just assign it as is.
        IF attr.attribute_data_type_code = 'DATE' THEN
          v_sql := v_sql||','''||to_char(FND_DATE.canonical_to_date(attr.default_assignment))||'''';
        ELSE
          v_sql := v_sql||','''||attr.default_assignment||'''';
        END IF;
        v_sql := v_sql||
                          ',sysdate'||
                          ','||c_user_id||
                          ','||c_user_id||
                          ',sysdate'||
                          ','||c_login_id||
                          ','||1||
                          ','||'''N'' from dual';

        IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => 'v_sql = '||v_sql);
        END IF;

        EXECUTE IMMEDIATE v_sql;

      END LOOP;
    END IF;  -- v_attr_tab is not null
  END IF; -- v_member_code IS NULL

  -- Set the default member if none exists
  IF v_vsr_flag = 'Y' THEN
    IF v_default_load_member_id IS NULL THEN
      UPDATE fem_value_sets_b
      SET default_load_member_id = to_number(v_member_code),
          last_update_date = sysdate,
          last_updated_by = c_user_id
      WHERE value_set_id = p_vs_id;

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Updated FEM_VALUE_SETS_B.default_load_member_id = '
                       ||v_member_code);
      END IF;
    END IF;
  ELSE
    IF v_default_member_dc IS NULL THEN
      UPDATE fem_xdim_dimensions
      SET default_member_display_code = (v_member_dc),
          last_update_date = sysdate,
          last_updated_by = c_user_id
      WHERE dimension_id = v_dim_id;

      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Updated FEM_XDIM_DIMENSIONS.default_member_display_code = '
                       ||v_member_dc);
      END IF;
    END IF;
  END IF; -- v_vsr_flag = 'Y'

  IF (p_commit = c_true) THEN
    COMMIT;
  END IF;

  x_member_code := v_member_code;
  x_return_status := c_success;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_member_code = '||x_member_code);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_error THEN
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO gen_default_load_member1_pub;
    x_return_status := c_error;

  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => SQLERRM);
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO gen_default_load_member1_pub;
    x_return_status := c_unexp;

END;

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_vs_id           IN NUMBER
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.generate_default_load_member(2)';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Genereate_Default_Load_Member';

  v_dim_label        FEM_DIMENSIONS_B.dimension_varchar_label%TYPE;
  v_def_load_id      NUMBER;
  v_member_code      VARCHAR2(38);
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  gen_default_load_member2_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_vs_id = '||to_char(p_vs_id));
  END IF;

  -------------------------------------
  -- Check that Value Set ID was passed
  -------------------------------------
  IF (p_vs_id IS NULL) THEN
    FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => 'FEM_VALUE_SET_TXT',
         p_trans1 => 'Y');
    RAISE e_error;
  END IF;

  ------------------------------
  -- Check that Value Set exists
  ------------------------------
  BEGIN
    SELECT D.dimension_varchar_label,
           V.default_load_member_id
    INTO   v_dim_label,
           v_def_load_id
    FROM   fem_value_sets_b V, fem_dimensions_b D
    WHERE  V.value_set_id = p_vs_id
    AND    V.dimension_id = D.dimension_id;
  EXCEPTION
    WHEN no_data_found THEN
     FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => 'FEM_VALUE_SET_TXT',
         p_trans1 => 'Y',
         p_token2 => 'VALUE',
         p_value2 => p_vs_id);
      RAISE e_error;
  END;

  -----------------------------------------------
  -- Return if Default Load Member already exists
  -----------------------------------------------
  IF (v_def_load_id IS NULL) THEN
    Generate_Default_Load_Member (
                  p_api_version   => 1.0,
                  p_init_msg_list => c_false,
                  p_commit        => c_false,
                  p_encoded       => p_encoded,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_dim_label     => v_dim_label,
                  p_vs_id         => p_vs_id,
                  x_member_code   => v_member_code);

    IF (x_return_status <> c_success) THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Call to FEM_Dimension_Util_Pkg.Generate_Default_Load_Member(1)'
                  ||' returned with status: '||x_return_status);
      END IF;
      RAISE e_error;
    END IF;
  END IF;  -- v_def_load_id IS NULL

  IF (p_commit = c_true) THEN
    COMMIT;
  END IF;

  x_return_status := c_success;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_error THEN
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO gen_default_load_member2_pub;
    x_return_status := c_error;

  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO gen_default_load_member2_pub;
    x_return_status := c_unexp;

END Generate_Default_Load_Member;

--------------------------------------------------------------------

PROCEDURE Generate_Default_Load_Member (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2
)
IS
  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.generate_default_load_member(3)';
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Genereate_Default_Load_Member';

  v_member_code       VARCHAR2(250);
  v_exception_flag    BOOLEAN;

  -- All dimensions that this API is able to default
  CURSOR c_dims IS
    SELECT d.dimension_id,
           d.dimension_varchar_label,
           x.value_set_required_flag
    FROM   fem_xdim_dimensions x, fem_dimensions_b d
    WHERE  x.dimension_id = d.dimension_id
    AND    x.read_only_flag = 'N'
    AND    x.composite_dimension_flag = 'N'
    AND    x.hier_editor_managed_flag = 'Y'
    AND   (x.default_member_display_code IS NULL OR
           x.value_set_required_flag = 'Y');

  -- All value sets given a dimension
  CURSOR c_value_sets (p_dim_id NUMBER) IS
      SELECT value_set_id
      FROM   fem_value_sets_b
      WHERE  dimension_id = p_dim_id
      AND    default_load_member_id IS NULL;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  gen_default_load_member3_pub;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize variables
  x_return_status := c_unexp;
  v_exception_flag := FALSE;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (c_api_version,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    RAISE e_error;
  END IF;

  FOR dims IN c_dims LOOP
    IF dims.value_set_required_flag = 'Y' THEN
      FOR value_sets IN c_value_sets(dims.dimension_id) LOOP
        Generate_Default_Load_Member(
          p_api_version => 1.0,
          p_init_msg_list => c_false,
          p_commit => c_false,
          p_encoded => p_encoded,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data,
          p_dim_label => dims.dimension_varchar_label,
          p_vs_id => value_sets.value_set_id,
          x_member_code => v_member_code);

        IF x_return_status <> c_success THEN
          IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            v_exception_flag := TRUE;
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_exception,
              p_module   => C_MODULE,
              p_msg_text => 'Generate_Default_Load_Member returned with error for'
                         ||' dim_label = '||dims.dimension_varchar_label
                         ||', value_set_id = '||value_sets.value_set_id);
          END IF;
        END IF;
      END LOOP;
    ELSE
      Generate_Default_Load_Member(
        p_api_version => 1.0,
        p_init_msg_list => c_false,
        p_commit => c_false,
        p_encoded => p_encoded,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_dim_label => dims.dimension_varchar_label,
        x_member_code => v_member_code);

      IF x_return_status <> c_success THEN
        v_exception_flag := TRUE;
        IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_exception,
            p_module   => C_MODULE,
            p_msg_text => 'Generate_Default_Load_Member returned with error for'
                       ||' dim_label = '||dims.dimension_varchar_label);
        END IF;
      END IF;
    END IF;
  END LOOP;

  IF (p_commit = c_true) THEN
    COMMIT;
  END IF;

  IF v_exception_flag THEN
    x_return_status := c_error;
  ELSE
    x_return_status := c_success;
  END IF;

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    ROLLBACK TO gen_default_load_member3_pub;
    x_return_status := c_unexp;

END Generate_Default_Load_Member;

/*************************************************************************

                            New_Dataset

*************************************************************************/

PROCEDURE New_Dataset (
   p_display_code  IN VARCHAR2,
   p_dataset_name  IN VARCHAR2,
   p_bal_type_cd   IN VARCHAR2,
   p_source_cd     IN NUMBER,
   p_pft_w_flg     IN VARCHAR2   DEFAULT 'Y',
   p_prod_flg      IN VARCHAR2   DEFAULT 'Y',
   p_budget_id     IN NUMBER,
   p_enc_type_id   IN NUMBER,
   p_ver_name      IN VARCHAR2,
   p_ver_disp_cd   IN VARCHAR2,
   p_dataset_desc  IN VARCHAR2,
   x_err_code     OUT NOCOPY   NUMBER,
   x_num_msg      OUT NOCOPY   NUMBER
)
IS

c_module_prg   CONSTANT   VARCHAR2(160) := c_module_pkg||'.new_dataset';

c_dim_label    CONSTANT   VARCHAR2(30) := 'DATASET';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_prg_msg      VARCHAR2(4000);
v_err_code     NUMBER;
v_num_msg      NUMBER;
v_err_msg      VARCHAR2(4000);

v_dim_id       NUMBER;
v_ds_cd        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_label   VARCHAR2(150);
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

TYPE cv_curs_type IS REF CURSOR;
cv_attr_dim   cv_curs_type;

BEGIN

x_err_code := 0;
x_num_msg := 0;

------------------------
-- Get New Dataset ID --
------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_ds_cd := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_dim_id => v_dim_id,
              x_err_code => v_err_code,
              x_num_msg => v_num_msg);
IF (v_err_code > 0)
THEN
   RAISE e_user_exception;
END IF;

-------------------------------
-- Insert New Dataset Member --
-------------------------------
BEGIN
   FEM_DATASETS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_dataset_code => v_ds_cd,
      x_enabled_flag => c_enbld_flg,
      x_dataset_display_code => p_display_code,
      x_read_only_flag => c_ro_flg,
      x_personal_flag => c_pers_flg,
      x_object_version_number => c_obj_ver_no,
      x_dataset_name => p_dataset_name,
      x_description => p_dataset_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-----------------------------------
-- Insert New Dataset Attributes --
-----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'DATASET_BALANCE_TYPE_CODE' THEN
         v_attr_value := p_bal_type_cd;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'PFT_ENG_WRITE_FLAG' THEN
         v_attr_value := p_pft_w_flg;
      WHEN 'PRODUCTION_FLAG' THEN
         v_attr_value := p_prod_flg;
      WHEN 'BUDGET_ID' THEN
         v_attr_value := p_budget_id;
      WHEN 'ENCUMBRANCE_TYPE_ID' THEN
         v_attr_value := p_enc_type_id;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Dataset.bad_attr_list',
            p_msg_text => 'The Dataset attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);

         x_err_code := 1;
         x_num_msg := x_num_msg + 1;
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         --------------------------------------
         -- Attribute is an assigned date value
         --------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      END IF;
   END IF;
END LOOP;

EXCEPTION
   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id));
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_display_code);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_user_exception THEN
   ROLLBACK;
      x_err_code := 2;
      x_num_msg := v_num_msg;

END New_Dataset;

---------------------------------------------------------------

PROCEDURE New_Dataset (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_display_code    IN VARCHAR2,
   p_dataset_name    IN VARCHAR2,
   p_bal_type_cd     IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_pft_w_flg       IN VARCHAR2   DEFAULT 'Y',
   p_prod_flg        IN VARCHAR2   DEFAULT 'Y',
   p_budget_id       IN NUMBER,
   p_enc_type_id     IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_dataset_desc    IN VARCHAR2
)
IS

c_module_prg   CONSTANT   VARCHAR2(160) := c_module_pkg||'.new_dataset';

c_dim_label    CONSTANT   VARCHAR2(30) := 'DATASET';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_ds_cd        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_label   VARCHAR2(150);
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

TYPE cv_curs_type IS REF CURSOR;
cv_attr_dim   cv_curs_type;

BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

------------------------
-- Get New Dataset ID --
------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_ds_cd := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_api_version => p_api_version,
              p_init_msg_list => c_false,
              p_commit => c_false,
              p_encoded => p_encoded,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              p_dim_id => v_dim_id);

IF (x_return_status <> c_success)
THEN
   RETURN;
END IF;

-------------------------------
-- Insert New Dataset Member --
-------------------------------
BEGIN
   FEM_DATASETS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_dataset_code => v_ds_cd,
      x_enabled_flag => c_enbld_flg,
      x_dataset_display_code => p_display_code,
      x_read_only_flag => c_ro_flg,
      x_personal_flag => c_pers_flg,
      x_object_version_number => c_obj_ver_no,
      x_dataset_name => p_dataset_name,
      x_description => p_dataset_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-----------------------------------
-- Insert New Dataset Attributes --
-----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'DATASET_BALANCE_TYPE_CODE' THEN
         v_attr_value := p_bal_type_cd;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'PFT_ENG_WRITE_FLAG' THEN
         v_attr_value := p_pft_w_flg;
      WHEN 'PRODUCTION_FLAG' THEN
         v_attr_value := p_prod_flg;
      WHEN 'BUDGET_ID' THEN
         v_attr_value := p_budget_id;
      WHEN 'ENCUMBRANCE_TYPE_ID' THEN
         v_attr_value := p_enc_type_id;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Dataset.bad_attr_list',
            p_msg_text => 'The Dataset attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned date value
         -----------------------------------------
         INSERT INTO fem_datasets_attr(
            attribute_id,
            version_id,
            dataset_code,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_ds_cd,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      END IF;
   END IF;
END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_bad_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_display_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Dataset;

/*************************************************************************

                            New_Ledger

*************************************************************************/

PROCEDURE New_Ledger (
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2,
   x_err_code       OUT NOCOPY   NUMBER,
   x_num_msg        OUT NOCOPY   NUMBER
)
IS

c_module_prg   VARCHAR2(160) := c_module_pkg||'.new_ledger';

c_dim_label     CONSTANT   VARCHAR2(30) := 'LEDGER';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_prg_msg      VARCHAR2(4000);
v_err_code     NUMBER;
v_num_msg      NUMBER;
v_err_msg      VARCHAR2(4000);

v_dim_id       NUMBER;
v_lg_id        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

BEGIN

x_err_code := 0;
x_num_msg := 0;

------------------------
-- Get New Ledger ID --
------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_lg_id := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_dim_id => v_dim_id,
              x_err_code => v_err_code,
              x_num_msg => v_num_msg);
IF (v_err_code > 0)
THEN
   RAISE e_user_exception;
END IF;

------------------------------
-- Insert New Ledger Member --
------------------------------
BEGIN
   FEM_LEDGERS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_ledger_id => v_lg_id,
      x_personal_flag => c_pers_flg,
      x_read_only_flag => c_ro_flg,
      x_object_version_number => c_obj_ver_no,
      x_enabled_flag => c_enbld_flg,
      x_ledger_display_code => p_display_code,
      x_ledger_name => p_ledger_name,
      x_description => p_ledger_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

----------------------------------
-- Insert New Ledger Attributes --
----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'LEDGER_FUNCTIONAL_CRNCY_CODE' THEN
         v_attr_value := p_func_curr_cd;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'CAL_PERIOD_HIER_OBJ_DEF_ID' THEN
         v_attr_value := p_cal_per_hid;
      WHEN 'GLOBAL_VS_COMBO' THEN
         v_attr_value := p_global_vs_id;
      WHEN 'EPB_DEFAULT_LEDGER_FLAG' THEN
         v_attr_value := null;
      WHEN 'ENTERED_CRNCY_ENABLE_FLAG' THEN
         v_attr_value := p_ent_curr_flg;
      WHEN 'LEDGER_ENABLE_AVG_BAL_FLAG' THEN
         v_attr_value := p_avg_bal_flg;
      WHEN 'LEDGER_CHANNEL_IS_POP_FLAG' THEN
         v_attr_value := p_chan_flg;
      WHEN 'LEDGER_CCTR_IS_POP_FLAG' THEN
         v_attr_value := p_cctr_flg;
      WHEN 'LEDGER_CUSTOMER_IS_POP_FLAG' THEN
         v_attr_value := p_cust_flg;
      WHEN 'LEDGER_GEOGRAPHY_IS_POP_FLAG' THEN
         v_attr_value := p_geog_flg;
      WHEN 'LEDGER_LINE_ITEM_IS_POP_FLAG' THEN
         v_attr_value := p_ln_item_flg;
      WHEN 'LEDGER_NAT_ACCT_IS_POP_FLAG' THEN
         v_attr_value := p_nat_acct_flg;
      WHEN 'LEDGER_PRODUCT_IS_POP_FLAG' THEN
         v_attr_value := p_prod_flg;
      WHEN 'LEDGER_PROJECT_IS_POP_FLAG' THEN
         v_attr_value := p_proj_flg;
      WHEN 'LEDGER_ENTITY_IS_POP_FLAG' THEN
         v_attr_value := p_entity_flg;
      WHEN 'LEDGER_USER_DIM1_IS_POP_FLAG' THEN
         v_attr_value := p_user1_flg;
      WHEN 'LEDGER_USER_DIM2_IS_POP_FLAG' THEN
         v_attr_value := p_user2_flg;
      WHEN 'LEDGER_USER_DIM3_IS_POP_FLAG' THEN
         v_attr_value := p_user3_flg;
      WHEN 'LEDGER_USER_DIM4_IS_POP_FLAG' THEN
         v_attr_value := p_user4_flg;
      WHEN 'LEDGER_USER_DIM5_IS_POP_FLAG' THEN
         v_attr_value := p_user5_flg;
      WHEN 'LEDGER_USER_DIM6_IS_POP_FLAG' THEN
         v_attr_value := p_user6_flg;
      WHEN 'LEDGER_USER_DIM7_IS_POP_FLAG' THEN
         v_attr_value := p_user7_flg;
      WHEN 'LEDGER_USER_DIM8_IS_POP_FLAG' THEN
         v_attr_value := p_user8_flg;
      WHEN 'LEDGER_USER_DIM9_IS_POP_FLAG' THEN
         v_attr_value := p_user9_flg;
      WHEN 'LEDGER_USER_DIM10_IS_POP_FLAG' THEN
         v_attr_value := p_user10_flg;
      WHEN 'LEDGER_TASK_IS_POP_FLAG' THEN
         v_attr_value := p_task_flg;
      WHEN 'LEDGER_FIN_ELEM_IS_POP_FLAG' THEN
         v_attr_value := p_fin_elem_flg;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Ledger.bad_attr_list',
            p_msg_text => 'The Ledger attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);

         x_err_code := 1;
         x_num_msg := x_num_msg + 1;
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         --------------------------------------
         -- Attribute is an assigned date value
         --------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      END IF;
   END IF;
END LOOP;

EXCEPTION
   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id),
         p_trans1 => 'n',
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_display_code);
      x_err_code := 2;
      x_num_msg := x_num_msg + 1;

   WHEN e_user_exception THEN
   ROLLBACK;

      x_err_code := 2;
      x_num_msg := v_num_msg;

END New_Ledger;

------------------------------------------------------------------

PROCEDURE New_Ledger (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2
)
IS

c_module_prg   VARCHAR2(160) := c_module_pkg||'.new_ledger';

c_dim_label    CONSTANT   VARCHAR2(30) := 'LEDGER';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_lg_id        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

------------------------
-- Get New Ledger ID --
------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_lg_id := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_api_version => p_api_version,
              p_init_msg_list => c_false,
              p_commit => c_false,
              p_encoded => p_encoded,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              p_dim_id => v_dim_id);

IF (x_return_status <> c_success)
THEN
   RETURN;
END IF;

------------------------------
-- Insert New Ledger Member --
------------------------------
BEGIN
   FEM_LEDGERS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_ledger_id => v_lg_id,
      x_personal_flag => c_pers_flg,
      x_read_only_flag => c_ro_flg,
      x_object_version_number => c_obj_ver_no,
      x_enabled_flag => c_enbld_flg,
      x_ledger_display_code => p_display_code,
      x_ledger_name => p_ledger_name,
      x_description => p_ledger_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

----------------------------------
-- Insert New Ledger Attributes --
----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'LEDGER_FUNCTIONAL_CRNCY_CODE' THEN
         v_attr_value := p_func_curr_cd;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'CAL_PERIOD_HIER_OBJ_DEF_ID' THEN
         v_attr_value := p_cal_per_hid;
      WHEN 'GLOBAL_VS_COMBO' THEN
         v_attr_value := p_global_vs_id;
      WHEN 'EPB_DEFAULT_LEDGER_FLAG' THEN
         v_attr_value := null;
      WHEN 'ENTERED_CRNCY_ENABLE_FLAG' THEN
         v_attr_value := p_ent_curr_flg;
      WHEN 'LEDGER_ENABLE_AVG_BAL_FLAG' THEN
         v_attr_value := p_avg_bal_flg;
      WHEN 'LEDGER_CHANNEL_IS_POP_FLAG' THEN
         v_attr_value := p_chan_flg;
      WHEN 'LEDGER_CCTR_IS_POP_FLAG' THEN
         v_attr_value := p_cctr_flg;
      WHEN 'LEDGER_CUSTOMER_IS_POP_FLAG' THEN
         v_attr_value := p_cust_flg;
      WHEN 'LEDGER_GEOGRAPHY_IS_POP_FLAG' THEN
         v_attr_value := p_geog_flg;
      WHEN 'LEDGER_LINE_ITEM_IS_POP_FLAG' THEN
         v_attr_value := p_ln_item_flg;
      WHEN 'LEDGER_NAT_ACCT_IS_POP_FLAG' THEN
         v_attr_value := p_nat_acct_flg;
      WHEN 'LEDGER_PRODUCT_IS_POP_FLAG' THEN
         v_attr_value := p_prod_flg;
      WHEN 'LEDGER_PROJECT_IS_POP_FLAG' THEN
         v_attr_value := p_proj_flg;
      WHEN 'LEDGER_ENTITY_IS_POP_FLAG' THEN
         v_attr_value := p_entity_flg;
      WHEN 'LEDGER_USER_DIM1_IS_POP_FLAG' THEN
         v_attr_value := p_user1_flg;
      WHEN 'LEDGER_USER_DIM2_IS_POP_FLAG' THEN
         v_attr_value := p_user2_flg;
      WHEN 'LEDGER_USER_DIM3_IS_POP_FLAG' THEN
         v_attr_value := p_user3_flg;
      WHEN 'LEDGER_USER_DIM4_IS_POP_FLAG' THEN
         v_attr_value := p_user4_flg;
      WHEN 'LEDGER_USER_DIM5_IS_POP_FLAG' THEN
         v_attr_value := p_user5_flg;
      WHEN 'LEDGER_USER_DIM6_IS_POP_FLAG' THEN
         v_attr_value := p_user6_flg;
      WHEN 'LEDGER_USER_DIM7_IS_POP_FLAG' THEN
         v_attr_value := p_user7_flg;
      WHEN 'LEDGER_USER_DIM8_IS_POP_FLAG' THEN
         v_attr_value := p_user8_flg;
      WHEN 'LEDGER_USER_DIM9_IS_POP_FLAG' THEN
         v_attr_value := p_user9_flg;
      WHEN 'LEDGER_USER_DIM10_IS_POP_FLAG' THEN
         v_attr_value := p_user10_flg;
      WHEN 'LEDGER_TASK_IS_POP_FLAG' THEN
         v_attr_value := p_task_flg;
      WHEN 'LEDGER_FIN_ELEM_IS_POP_FLAG' THEN
         v_attr_value := p_fin_elem_flg;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Ledger.bad_attr_list',
            p_msg_text => 'The Ledger attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         --------------------------------------
         -- Attribute is an assigned date value
         --------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      END IF;
   END IF;
END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_display_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Ledger;

/*************************************************************************

                         New_Budget
This procedure creates a new budget member
Notes:
   The "FIRST_PERIOD" and "LAST_PERIOD" attributes both require a
   CAL_PERIOD_ID assignment.  Since the person calling the API will
   not necessarily know the 32 digit numeric CAL_PERIOD_ID value,
   the API requires that they specify the 4 components (Calendar, Dimension Group,
   Period Number and End Date) instead.

*************************************************************************/


PROCEDURE New_Budget (
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   p_budget_display_code     IN VARCHAR2,
   p_budget_name             IN VARCHAR2,
   p_budget_ledger           IN VARCHAR2,
   p_require_journals_flag   IN VARCHAR2,
   p_budget_status_code      IN VARCHAR2,
   p_budget_latest_open_year IN NUMBER,
   p_budget_source_system    IN VARCHAR2,
   p_first_period_calendar   IN VARCHAR2,
   p_first_period_dimgrp     IN VARCHAR2,
   p_first_period_number     IN VARCHAR2,
   p_first_period_end_date   IN DATE,
   p_last_period_calendar    IN VARCHAR2,
   p_last_period_dimgrp      IN VARCHAR2,
   p_last_period_number      IN VARCHAR2,
   p_last_period_end_date    IN DATE,
   p_ver_name                IN VARCHAR2,
   p_ver_disp_cd             IN VARCHAR2,
   p_budget_desc             IN VARCHAR2)
IS

   -- constant declarations
   c_module_prg   CONSTANT   VARCHAR2(160) := c_module_pkg||'.new_budget';

   c_budget_label            CONSTANT   VARCHAR2(30) := 'BUDGET';
   c_enabled_flag            CONSTANT   VARCHAR2(1)  := 'Y';
   c_read_only_flag          CONSTANT   VARCHAR2(1)  := 'N';
   c_personal_flag           CONSTANT   VARCHAR2(1)  := 'N';
   c_object_version_number   CONSTANT   NUMBER       := 1;
   c_aw_snapshot_flag        CONSTANT   VARCHAR2(1)  := 'N';

   v_row_id       VARCHAR2(20) := '';

   v_budget_dimension_id       NUMBER;  -- dimension_id of BUDGET
   v_budget_id                 NUMBER;
   v_version_id                NUMBER;
   v_attr_label                VARCHAR2(30);
   v_attr_assign_value         VARCHAR2(150);  -- placeholder for the assignment
                                               -- value that will be used for each
                                               -- attribute

   v_attr_numeric_member       NUMBER;         -- placeholder for numeric dimensions
   v_attr_number_assign        NUMBER;         -- placeholder for number assignment values
   v_attr_varchar_member       VARCHAR2(30);   -- placeholder for alphanumeric dimensions

   -- Variables used to identify the CAL_PERIOD_ID for the BUDGET_FIRST_PERIOD
   -- and BUDGET_LAST_PERIOD attribute assignments
   v_first_period_calendar_id       NUMBER;
   v_last_period_calendar_id        NUMBER;
   v_first_period_time_dimgrp_key   NUMBER;
   v_last_period_time_dimgrp_key    NUMBER;

   -- placeholder variables for the member table of the Dimension from which
   -- the attribute assignment comes from
   -- we use this information to validate that the attribute assignment
   -- is a valid Dimension member (for DIMENSION attributes only)
   v_attribute_id                  NUMBER;
   v_attr_member_tab               VARCHAR2(30);
   v_attr_member_col               VARCHAR2(30);
   v_attr_member_dc_col            VARCHAR2(30);  -- display_code column of the attribute dim
   v_param_req                     BOOLEAN;

   v_sql_stmt      VARCHAR2(32767);

   CURSOR cv_budget_attr IS
      SELECT attribute_id,
             attribute_varchar_label,
             attribute_dimension_id,
             attribute_value_column_name
      FROM fem_dim_attributes_b
      WHERE dimension_id =
         (SELECT dimension_id
          FROM fem_dimensions_b
          WHERE dimension_varchar_label = 'BUDGET')
      AND attribute_required_flag = 'Y';

   TYPE cv_curs_type IS REF CURSOR;
   cv_attr_dim   cv_curs_type;

BEGIN

x_return_status := c_success;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

------------------------
-- Get the next BUDGET_ID value available --
------------------------
SELECT dimension_id
INTO v_budget_dimension_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_budget_label;

v_budget_id := FEM_Dimension_Util_Pkg.Generate_Member_ID(
              p_api_version => p_api_version,
              p_init_msg_list => c_false,
              p_commit => c_false,
              p_encoded => p_encoded,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              p_dim_id => v_budget_dimension_id);

IF (x_return_status <> c_success)
THEN
   RETURN;
END IF;

-------------------------------
-- Insert New Budget Member --
-------------------------------
BEGIN
   FEM_BUDGETS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_budget_id => v_budget_id,
      x_enabled_flag => c_enabled_flag,
      x_budget_display_code => p_budget_display_code,
      x_read_only_flag => c_read_only_flag,
      x_personal_flag => c_personal_flag,
      x_object_version_number => c_object_version_number,
      x_budget_name => p_budget_name,
      x_description => p_budget_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-----------------------------------
-- Insert New Budget Attributes --
-----------------------------------
FOR attr IN cv_budget_attr
LOOP

   v_attribute_id := attr.attribute_id;
   v_attr_label := attr.attribute_varchar_label;
   -------------------------------
   -- Check Attribute Version --
   -------------------------------
   BEGIN
      SELECT MIN(version_id)
      INTO v_version_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id = v_attribute_id
      AND default_version_flag = 'Y';
   EXCEPTION
      WHEN no_data_found THEN
      -- In this case, the version did not exist, so we will try
      -- to create a new version for the attribute using the provided
      -- version display code and version name

         IF (p_ver_name IS NULL)
         THEN
            RAISE e_no_version_name;
         ELSIF (p_ver_disp_cd IS NULL)
         THEN
            RAISE e_no_version_name;
         END IF;

         SELECT fem_dim_attr_versions_b_s.NEXTVAL
         INTO v_version_id FROM dual;

         FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
            x_rowid => v_row_id,
            x_version_id => v_version_id,
            x_aw_snapshot_flag => c_aw_snapshot_flag,
            x_version_display_code => p_ver_disp_cd,
            x_object_version_number => c_object_version_number,
            x_default_version_flag => 'Y',
            x_personal_flag => c_personal_flag,
            x_attribute_id => v_attribute_id,
            x_version_name => p_ver_name,
            x_description => null,
            x_creation_date => sysdate,
            x_created_by => c_user_id,
            x_last_update_date => sysdate,
            x_last_updated_by => c_user_id,
            x_last_update_login => null);
   END;

   -----------------------------
   -- Get Attribute information --
   -----------------------------
   CASE attr.attribute_varchar_label
      WHEN 'BUDGET_LEDGER' THEN
         v_attr_assign_value := p_budget_ledger;
         v_param_req := TRUE;
      WHEN 'REQUIRE_JOURNALS_FLAG' THEN
         v_attr_assign_value := p_require_journals_flag;
         v_param_req := TRUE;
      WHEN 'BUDGET_STATUS_CODE' THEN
         v_attr_assign_value := p_budget_status_code;
         v_param_req := TRUE;
      WHEN 'BUDGET_LATEST_OPEN_YEAR' THEN
         v_attr_assign_value := p_budget_latest_open_year;
         v_param_req := TRUE;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_assign_value := p_budget_source_system;
         v_param_req := TRUE;
      WHEN 'BUDGET_FIRST_PERIOD' THEN
         -- for this attribute we have to identify the CAL_PERIOD_ID
         -- of the assignment
         BEGIN
            select calendar_id
            into v_first_period_calendar_id
            from fem_calendars_b
            where calendar_display_code = p_first_period_calendar;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         BEGIN
            select time_dimension_group_key
            into v_first_period_time_dimgrp_key
            from fem_dimension_grps_b D, fem_dimensions_b B
            where D.dimension_group_display_code = p_first_period_dimgrp
            and D.dimension_id = B.dimension_id
            and B.dimension_varchar_label = 'CAL_PERIOD';
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         select LPAD(to_char(to_number(to_char(p_first_period_end_date,'j'))),7,'0')||
         LPAD(TO_CHAR(p_first_period_number),15,'0')||
         LPAD(to_char(v_first_period_calendar_id),5,'0')||
         LPAD(to_char(v_first_period_time_dimgrp_key),5,'0')
         into v_attr_assign_value
         from dual;

         v_param_req := TRUE;
      WHEN 'BUDGET_LAST_PERIOD' THEN
         -- for this attribute we have to identify the CAL_PERIOD_ID
         -- of the assignment
         BEGIN
            select calendar_id
            into v_last_period_calendar_id
            from fem_calendars_b
            where calendar_display_code = p_last_period_calendar;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         BEGIN
            select time_dimension_group_key
            into v_last_period_time_dimgrp_key
            from fem_dimension_grps_b D, fem_dimensions_b B
            where D.dimension_group_display_code = p_last_period_dimgrp
            and D.dimension_id = B.dimension_id
            and B.dimension_varchar_label = 'CAL_PERIOD';
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         select LPAD(to_char(to_number(to_char(p_last_period_end_date,'j'))),7,'0')||
         LPAD(TO_CHAR(p_last_period_number),15,'0')||
         LPAD(to_char(v_last_period_calendar_id),5,'0')||
         LPAD(to_char(v_last_period_time_dimgrp_key),5,'0')
         into v_attr_assign_value
         from dual;

         v_param_req := TRUE;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Budget.bad_attr_list',
            p_msg_text => 'The Budget attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_assign_value IS NULL)
   THEN
      CASE v_param_req
         WHEN TRUE THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE

      -------------------------
      -- Verify that the attribute assignment value is a valid
      -- for that attribute
      -- this only applies for DIMENSION attributes (i.e., where
      -- attribute_dimension_id is not null
      -------------------------
      IF attr.attribute_dimension_id is not null THEN
         SELECT member_b_table_name,
                member_col,
                member_display_code_col
         INTO v_attr_member_tab,
              v_attr_member_col,
              v_attr_member_dc_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = attr.attribute_dimension_id;

         v_sql_stmt :=
            'SELECT '||v_attr_member_col||
            ' FROM '||v_attr_member_tab||
            ' WHERE to_char('||v_attr_member_dc_col||') = '''||v_attr_assign_value||'''';
     END IF;

      IF (attr.attribute_value_column_name = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
      THEN
         BEGIN
            EXECUTE IMMEDIATE v_sql_stmt
            INTO v_attr_numeric_member;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_bad_param_value;
         END;
         v_attr_varchar_member := '';
         v_attr_number_assign := '';
      ELSIF (attr.attribute_value_column_name = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         BEGIN
            EXECUTE IMMEDIATE v_sql_stmt
            INTO v_attr_varchar_member;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_bad_param_value;
         END;
         v_attr_numeric_member := '';
         v_attr_number_assign := '';
      ELSIF (attr.attribute_value_column_name = 'NUMBER_ASSIGN_VALUE')
      THEN
         v_attr_number_assign := v_attr_assign_value;
         v_attr_numeric_member := '';
         v_attr_varchar_member := '';
      END IF;

      -----------------------------
      -- Insert Attribute Values --
      -----------------------------
      INSERT INTO fem_budgets_attr(
         attribute_id,
         version_id,
         budget_id,
         dim_attribute_numeric_member,
         dim_attribute_varchar_member,
         number_assign_value,
         varchar_assign_value,
         date_assign_value,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         aw_snapshot_flag,
         object_version_number)
      VALUES(
         v_attribute_id,
         v_version_id,
         v_budget_id,
         v_attr_numeric_member,
         v_attr_varchar_member,
         v_attr_number_assign,
         null,
         null,
         sysdate,
         c_user_id,
         c_user_id,
         sysdate,
         null,
         c_aw_snapshot_flag,
         c_object_version_number);

   END IF;

END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_bad_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attribute_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_assign_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attribute_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attribute_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_budget_display_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Budget;

/*************************************************************************

                        Register Budget

*************************************************************************/

PROCEDURE Register_Budget (
   p_api_version             IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list           IN VARCHAR2   DEFAULT c_false,
   p_commit                  IN VARCHAR2   DEFAULT c_false,
   p_encoded                 IN VARCHAR2   DEFAULT c_true,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,
   p_budget_id               IN NUMBER,
   p_budget_display_code     IN VARCHAR2,
   p_budget_name             IN VARCHAR2,
   p_budget_ledger           IN VARCHAR2,
   p_require_journals_flag   IN VARCHAR2,
   p_budget_status_code      IN VARCHAR2,
   p_budget_latest_open_year IN NUMBER,
   p_budget_source_system    IN VARCHAR2,
   p_first_period_calendar   IN VARCHAR2,
   p_first_period_dimgrp     IN VARCHAR2,
   p_first_period_number     IN VARCHAR2,
   p_first_period_end_date   IN DATE,
   p_last_period_calendar    IN VARCHAR2,
   p_last_period_dimgrp      IN VARCHAR2,
   p_last_period_number      IN VARCHAR2,
   p_last_period_end_date    IN DATE,
   p_ver_name                IN VARCHAR2,
   p_ver_disp_cd             IN VARCHAR2,
   p_budget_desc             IN VARCHAR2)
IS

-- constant declarations
c_module_prg   CONSTANT   VARCHAR2(160) := c_module_pkg||'.new_budget';

c_budget_label            CONSTANT   VARCHAR2(30) := 'BUDGET';
c_enabled_flag            CONSTANT   VARCHAR2(1)  := 'Y';
c_read_only_flag          CONSTANT   VARCHAR2(1)  := 'N';
c_personal_flag           CONSTANT   VARCHAR2(1)  := 'N';
c_object_version_number   CONSTANT   NUMBER       := 1;
c_aw_snapshot_flag        CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';
v_dim_id       NUMBER;
v_budget_dimension_id       NUMBER;  -- dimension_id of BUDGET
v_budget_id                 NUMBER;
v_version_id                NUMBER;
v_attr_label                VARCHAR2(30);
v_attr_assign_value         VARCHAR2(150);  -- placeholder for the assignment
                                            -- value that will be used for each
                                            -- attribute

v_attr_numeric_member       NUMBER;         -- placeholder for numeric dimensions
v_attr_number_assign        NUMBER;         -- placeholder for number assignment values
v_attr_varchar_member       VARCHAR2(30);   -- placeholder for alphanumeric dimensions

-- Variables used to identify the CAL_PERIOD_ID for the BUDGET_FIRST_PERIOD
-- and BUDGET_LAST_PERIOD attribute assignments
v_first_period_calendar_id       NUMBER;
v_last_period_calendar_id        NUMBER;
v_first_period_time_dimgrp_key   NUMBER;
v_last_period_time_dimgrp_key    NUMBER;

-- placeholder variables for the member table of the Dimension from which
-- the attribute assignment comes from
-- we use this information to validate that the attribute assignment
-- is a valid Dimension member (for DIMENSION attributes only)

v_attribute_id                  NUMBER;
v_attr_member_tab               VARCHAR2(30);
v_attr_member_col               VARCHAR2(30);
v_attr_member_dc_col            VARCHAR2(30);  -- display_code column of the attribute dim
v_param_req                     BOOLEAN;

v_sql_stmt      VARCHAR2(32767);

CURSOR cv_budget_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = 'BUDGET')
   AND attribute_required_flag = 'Y';

TYPE cv_curs_type IS REF CURSOR;
cv_attr_dim   cv_curs_type;

e_dup_reg_id   EXCEPTION;

BEGIN

x_return_status := c_success;

---------------------
-- Validate Budget ID
---------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_budget_label;

BEGIN
   SELECT budget_id
   INTO v_budget_id
   FROM fem_budgets_b
   WHERE budget_id = p_budget_id;
EXCEPTION
   WHEN no_data_found THEN
      v_budget_id := null;
END;

IF (v_budget_id IS NULL)
THEN
   v_budget_id := p_budget_id;
ELSE
   RAISE e_dup_reg_id;
END IF;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

-------------------------------
-- Insert New Budget Member --
-------------------------------
BEGIN
   FEM_BUDGETS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_budget_id => v_budget_id,
      x_enabled_flag => c_enabled_flag,
      x_budget_display_code => p_budget_display_code,
      x_read_only_flag => c_read_only_flag,
      x_personal_flag => c_personal_flag,
      x_object_version_number => c_object_version_number,
      x_budget_name => p_budget_name,
      x_description => p_budget_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

-----------------------------------
-- Insert New Budget Attributes --
-----------------------------------
FOR attr IN cv_budget_attr
LOOP

   v_attribute_id := attr.attribute_id;
   v_attr_label := attr.attribute_varchar_label;
   -------------------------------
   -- Check Attribute Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_version_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attribute_id
   AND default_version_flag = 'Y';

   IF (v_version_id IS NULL)
   THEN
      -- In this case, the version did not exist, so we will try
      -- to create a new version for the attribute using the provided
      -- version display code and version name

      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_version_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_version_id,
         x_aw_snapshot_flag => c_aw_snapshot_flag,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_object_version_number,
         x_default_version_flag => 'Y',
         x_personal_flag => c_personal_flag,
         x_attribute_id => v_attribute_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute information --
   -----------------------------
   CASE attr.attribute_varchar_label
      WHEN 'BUDGET_LEDGER' THEN
         v_attr_assign_value := p_budget_ledger;
         v_param_req := TRUE;
      WHEN 'REQUIRE_JOURNALS_FLAG' THEN
         v_attr_assign_value := p_require_journals_flag;
         v_param_req := TRUE;
      WHEN 'BUDGET_STATUS_CODE' THEN
         v_attr_assign_value := p_budget_status_code;
         v_param_req := TRUE;
      WHEN 'BUDGET_LATEST_OPEN_YEAR' THEN
         v_attr_assign_value := p_budget_latest_open_year;
         v_param_req := TRUE;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_assign_value := p_budget_source_system;
         v_param_req := TRUE;
      WHEN 'BUDGET_FIRST_PERIOD' THEN
         -- for this attribute we have to identify the CAL_PERIOD_ID
         -- of the assignment
         BEGIN
            select calendar_id
            into v_first_period_calendar_id
            from fem_calendars_b
            where calendar_display_code = p_first_period_calendar;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         BEGIN
            select time_dimension_group_key
            into v_first_period_time_dimgrp_key
            from fem_dimension_grps_b D, fem_dimensions_b B
            where D.dimension_group_display_code = p_first_period_dimgrp
            and D.dimension_id = B.dimension_id
            and B.dimension_varchar_label = 'CAL_PERIOD';
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         select LPAD(to_char(to_number(to_char(p_first_period_end_date,'j'))),7,'0')||
         LPAD(TO_CHAR(p_first_period_number),15,'0')||
         LPAD(to_char(v_first_period_calendar_id),5,'0')||
         LPAD(to_char(v_first_period_time_dimgrp_key),5,'0')
         into v_attr_assign_value
         from dual;

         v_param_req := TRUE;
      WHEN 'BUDGET_LAST_PERIOD' THEN
         -- for this attribute we have to identify the CAL_PERIOD_ID
         -- of the assignment
         BEGIN
            select calendar_id
            into v_last_period_calendar_id
            from fem_calendars_b
            where calendar_display_code = p_last_period_calendar;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         BEGIN
            select time_dimension_group_key
            into v_last_period_time_dimgrp_key
            from fem_dimension_grps_b D, fem_dimensions_b B
            where D.dimension_group_display_code = p_last_period_dimgrp
            and D.dimension_id = B.dimension_id
            and B.dimension_varchar_label = 'CAL_PERIOD';
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_null_param_value;
         END;

         select LPAD(to_char(to_number(to_char(p_last_period_end_date,'j'))),7,'0')||
         LPAD(TO_CHAR(p_last_period_number),15,'0')||
         LPAD(to_char(v_last_period_calendar_id),5,'0')||
         LPAD(to_char(v_last_period_time_dimgrp_key),5,'0')
         into v_attr_assign_value
         from dual;

         v_param_req := TRUE;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Budget.bad_attr_list',
            p_msg_text => 'The Budget attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_assign_value IS NULL)
   THEN
      CASE v_param_req
         WHEN TRUE THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE

      -------------------------
      -- Verify that the attribute assignment value is a valid
      -- for that attribute
      -- this only applies for DIMENSION attributes (i.e., where
      -- attribute_dimension_id is not null
      -------------------------
      IF attr.attribute_dimension_id is not null THEN
         SELECT member_b_table_name,
                member_col,
                member_display_code_col
         INTO v_attr_member_tab,
              v_attr_member_col,
              v_attr_member_dc_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = attr.attribute_dimension_id;

         v_sql_stmt :=
            'SELECT '||v_attr_member_col||
            ' FROM '||v_attr_member_tab||
            ' WHERE to_char('||v_attr_member_dc_col||') = '''||v_attr_assign_value||'''';
     END IF;

      IF (attr.attribute_value_column_name = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
      THEN
         BEGIN
            EXECUTE IMMEDIATE v_sql_stmt
            INTO v_attr_numeric_member;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_bad_param_value;
         END;
         v_attr_varchar_member := '';
         v_attr_number_assign := '';
      ELSIF (attr.attribute_value_column_name = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         BEGIN
            EXECUTE IMMEDIATE v_sql_stmt
            INTO v_attr_varchar_member;
         EXCEPTION
            WHEN no_data_found THEN
               RAISE e_bad_param_value;
         END;
         v_attr_numeric_member := '';
         v_attr_number_assign := '';
      ELSIF (attr.attribute_value_column_name = 'NUMBER_ASSIGN_VALUE')
      THEN
         v_attr_number_assign := v_attr_assign_value;
         v_attr_numeric_member := '';
         v_attr_varchar_member := '';
      END IF;

      -----------------------------
      -- Insert Attribute Values --
      -----------------------------
      INSERT INTO fem_budgets_attr(
         attribute_id,
         version_id,
         budget_id,
         dim_attribute_numeric_member,
         dim_attribute_varchar_member,
         number_assign_value,
         varchar_assign_value,
         date_assign_value,
         creation_date,
         created_by,
         last_updated_by,
         last_update_date,
         last_update_login,
         aw_snapshot_flag,
         object_version_number)
      VALUES(
         v_attribute_id,
         v_version_id,
         v_budget_id,
         v_attr_numeric_member,
         v_attr_varchar_member,
         v_attr_number_assign,
         null,
         null,
         sysdate,
         c_user_id,
         c_user_id,
         sysdate,
         null,
         c_aw_snapshot_flag,
         c_object_version_number);

   END IF;

END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_dup_reg_id THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_REG_MEMBER_ERR',
         p_token1 => 'DIMENSION',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                        p_dim_id => v_dim_id),
         p_trans1 => 'N',
         p_token2 => 'VALUE',
         p_value2 => p_budget_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attribute_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_assign_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                    p_attr_id => v_attribute_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attribute_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
      ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_budget_display_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END Register_Budget;

/*************************************************************************

                        Register Ledger

  08/23/2006 rflippo Bug#5486589 Modify logic so that if -1 passed in as the
                     Cal Period Hier ID then it doesn't try to validate it.
                     The reason is that the OGL integration needs to create the
                     ledger with a placeholder for the Cal Period Hier ID, since
                     they won't have that information until the Cal Period hiers
                     are created later.
*************************************************************************/

PROCEDURE Register_Ledger (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_ledger_id       IN NUMBER,
   p_display_code    IN VARCHAR2,
   p_ledger_name     IN VARCHAR2,
   p_func_curr_cd    IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_cal_per_hid     IN NUMBER,
   p_global_vs_id    IN NUMBER,
   p_epb_def_lg_flg  IN VARCHAR2,
   p_ent_curr_flg    IN VARCHAR2,
   p_avg_bal_flg     IN VARCHAR2,
   p_chan_flg        IN VARCHAR2 DEFAULT 'N',
   p_cctr_flg        IN VARCHAR2 DEFAULT 'N',
   p_cust_flg        IN VARCHAR2 DEFAULT 'N',
   p_geog_flg        IN VARCHAR2 DEFAULT 'N',
   p_ln_item_flg     IN VARCHAR2 DEFAULT 'N',
   p_nat_acct_flg    IN VARCHAR2 DEFAULT 'N',
   p_prod_flg        IN VARCHAR2 DEFAULT 'N',
   p_proj_flg        IN VARCHAR2 DEFAULT 'N',
   p_entity_flg      IN VARCHAR2 DEFAULT 'N',
   p_user1_flg       IN VARCHAR2 DEFAULT 'N',
   p_user2_flg       IN VARCHAR2 DEFAULT 'N',
   p_user3_flg       IN VARCHAR2 DEFAULT 'N',
   p_user4_flg       IN VARCHAR2 DEFAULT 'N',
   p_user5_flg       IN VARCHAR2 DEFAULT 'N',
   p_user6_flg       IN VARCHAR2 DEFAULT 'N',
   p_user7_flg       IN VARCHAR2 DEFAULT 'N',
   p_user8_flg       IN VARCHAR2 DEFAULT 'N',
   p_user9_flg       IN VARCHAR2 DEFAULT 'N',
   p_user10_flg      IN VARCHAR2 DEFAULT 'N',
   p_task_flg        IN VARCHAR2 DEFAULT 'N',
   p_fin_elem_flg    IN VARCHAR2 DEFAULT 'N',
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2,
   p_ledger_desc     IN VARCHAR2
)
IS

c_module_prg   VARCHAR2(160) := c_module_pkg||'.new_ledger';

c_dim_label     CONSTANT   VARCHAR2(30) := 'LEDGER';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_lg_id        NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

e_dup_reg_id   EXCEPTION;

BEGIN

x_return_status := c_success;

---------------------
-- Validate Ledger ID
---------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

BEGIN
   SELECT ledger_id
   INTO v_lg_id
   FROM fem_ledgers_b
   WHERE ledger_id = p_ledger_id;
EXCEPTION
   WHEN no_data_found THEN
      v_lg_id := null;
END;

IF (v_lg_id IS NULL)
THEN
   v_lg_id := p_ledger_id;
ELSE
   RAISE e_dup_reg_id;
END IF;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

------------------------------
-- Insert New Ledger Member --
------------------------------
BEGIN
   FEM_LEDGERS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_ledger_id => v_lg_id,
      x_personal_flag => c_pers_flg,
      x_read_only_flag => c_ro_flg,
      x_object_version_number => c_obj_ver_no,
      x_enabled_flag => c_enbld_flg,
      x_ledger_display_code => p_display_code,
      x_ledger_name => p_ledger_name,
      x_description => p_ledger_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

----------------------------------
-- Insert New Ledger Attributes --
----------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'LEDGER_FUNCTIONAL_CRNCY_CODE' THEN
         v_attr_value := p_func_curr_cd;
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      WHEN 'CAL_PERIOD_HIER_OBJ_DEF_ID' THEN
         v_attr_value := p_cal_per_hid;
      WHEN 'GLOBAL_VS_COMBO' THEN
         v_attr_value := p_global_vs_id;
      WHEN 'EPB_DEFAULT_LEDGER_FLAG' THEN
         v_attr_value := p_epb_def_lg_flg;
      WHEN 'ENTERED_CRNCY_ENABLE_FLAG' THEN
         v_attr_value := p_ent_curr_flg;
      WHEN 'LEDGER_ENABLE_AVG_BAL_FLAG' THEN
         v_attr_value := p_avg_bal_flg;
      WHEN 'LEDGER_CHANNEL_IS_POP_FLAG' THEN
         v_attr_value := p_chan_flg;
      WHEN 'LEDGER_CCTR_IS_POP_FLAG' THEN
         v_attr_value := p_cctr_flg;
      WHEN 'LEDGER_CUSTOMER_IS_POP_FLAG' THEN
         v_attr_value := p_cust_flg;
      WHEN 'LEDGER_GEOGRAPHY_IS_POP_FLAG' THEN
         v_attr_value := p_geog_flg;
      WHEN 'LEDGER_LINE_ITEM_IS_POP_FLAG' THEN
         v_attr_value := p_ln_item_flg;
      WHEN 'LEDGER_NAT_ACCT_IS_POP_FLAG' THEN
         v_attr_value := p_nat_acct_flg;
      WHEN 'LEDGER_PRODUCT_IS_POP_FLAG' THEN
         v_attr_value := p_prod_flg;
      WHEN 'LEDGER_PROJECT_IS_POP_FLAG' THEN
         v_attr_value := p_proj_flg;
      WHEN 'LEDGER_ENTITY_IS_POP_FLAG' THEN
         v_attr_value := p_entity_flg;
      WHEN 'LEDGER_USER_DIM1_IS_POP_FLAG' THEN
         v_attr_value := p_user1_flg;
      WHEN 'LEDGER_USER_DIM2_IS_POP_FLAG' THEN
         v_attr_value := p_user2_flg;
      WHEN 'LEDGER_USER_DIM3_IS_POP_FLAG' THEN
         v_attr_value := p_user3_flg;
      WHEN 'LEDGER_USER_DIM4_IS_POP_FLAG' THEN
         v_attr_value := p_user4_flg;
      WHEN 'LEDGER_USER_DIM5_IS_POP_FLAG' THEN
         v_attr_value := p_user5_flg;
      WHEN 'LEDGER_USER_DIM6_IS_POP_FLAG' THEN
         v_attr_value := p_user6_flg;
      WHEN 'LEDGER_USER_DIM7_IS_POP_FLAG' THEN
         v_attr_value := p_user7_flg;
      WHEN 'LEDGER_USER_DIM8_IS_POP_FLAG' THEN
         v_attr_value := p_user8_flg;
      WHEN 'LEDGER_USER_DIM9_IS_POP_FLAG' THEN
         v_attr_value := p_user9_flg;
      WHEN 'LEDGER_USER_DIM10_IS_POP_FLAG' THEN
         v_attr_value := p_user10_flg;
      WHEN 'LEDGER_TASK_IS_POP_FLAG' THEN
         v_attr_value := p_task_flg;
      WHEN 'LEDGER_FIN_ELEM_IS_POP_FLAG' THEN
         v_attr_value := p_fin_elem_flg;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Ledger.bad_attr_list',
            p_msg_text => 'The Ledger attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER') THEN
            IF v_attr_label = 'CAL_PERIOD_HIER_OBJ_DEF_ID' AND v_attr_value = -1 THEN
               v_attr_num := v_attr_value;
            ELSE
               BEGIN
                  EXECUTE IMMEDIATE v_sql_cmd
                  INTO v_attr_num
                  USING v_attr_value;
               EXCEPTION
                  WHEN no_data_found THEN
                     RAISE e_bad_param_value;
               END;
            END IF;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         --------------------------------------
         -- Attribute is an assigned date value
         --------------------------------------
         INSERT INTO fem_ledgers_attr(
            attribute_id,
            version_id,
            ledger_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            aw_snapshot_flag)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_lg_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_obj_ver_no,
            c_aw_flg);

      END IF;
   END IF;
END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_dup_reg_id THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_REG_MEMBER_ERR',
         p_token1 => 'DIMENSION',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                        p_dim_id => v_dim_id),
         p_trans1 => 'N',
         p_token2 => 'VALUE',
         p_value2 => p_ledger_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_display_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END Register_Ledger;

/*************************************************************************

                        New Encumbrance Type

*************************************************************************/

PROCEDURE New_Encumbrance_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_enc_type_id    OUT NOCOPY NUMBER,
   p_enc_type_code   IN VARCHAR2,
   p_enc_type_name   IN VARCHAR2,
   p_enc_type_desc   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2
)
IS

c_module_prg   VARCHAR2(160) := c_module_pkg||'.new_enc_type';

c_dim_label    CONSTANT   VARCHAR2(30) := 'ENCUMBRANCE_TYPE';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_enc_type_id  NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

BEGIN

x_return_status := c_success;
x_enc_type_id := -1;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

---------------------------------
-- Get New Encumbrance Type ID --
---------------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

v_enc_type_id := FEM_Dimension_Util_Pkg.Generate_Member_ID(
                  p_api_version => p_api_version,
                  p_init_msg_list => c_false,
                  p_commit => c_false,
                  p_encoded => p_encoded,
                  x_return_status => x_return_status,
                  x_msg_count => x_msg_count,
                  x_msg_data => x_msg_data,
                  p_dim_id => v_dim_id);

IF (x_return_status <> c_success)
THEN
   RETURN;
END IF;

----------------------------------------
-- Insert New Encumbrance Type Member --
----------------------------------------
BEGIN
   FEM_ENCUMBRANCE_TYPES_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_encumbrance_type_id => v_enc_type_id,
      x_personal_flag => c_pers_flg,
      x_encumbrance_type_code => p_enc_type_code,
      x_enabled_flag => c_enbld_flg,
      x_object_version_number => c_obj_ver_no,
      x_read_only_flag => c_ro_flg,
      x_encumbrance_type_name => p_enc_type_name,
      x_description => p_enc_type_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

--------------------------------------------
-- Insert New Encumbrance Type Attributes --
--------------------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Encumbrance Type.bad_attr_list',
            p_msg_text => 'The Encumbrance Type attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned date value
         -----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      END IF;
   END IF;
END LOOP;

x_enc_type_id := v_enc_type_id;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_enc_type_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END New_Encumbrance_Type;

/*************************************************************************

                    Register Encumbrance Type

*************************************************************************/

PROCEDURE Register_Encumbrance_Type (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   p_enc_type_id     IN NUMBER,
   p_enc_type_code   IN VARCHAR2,
   p_enc_type_name   IN VARCHAR2,
   p_enc_type_desc   IN VARCHAR2,
   p_source_cd       IN NUMBER,
   p_ver_name        IN VARCHAR2,
   p_ver_disp_cd     IN VARCHAR2
)
IS

c_module_prg   VARCHAR2(160) := c_module_pkg||'.new_enc_type';

c_dim_label    CONSTANT   VARCHAR2(30) := 'ENCUMBRANCE_TYPE';
c_enbld_flg    CONSTANT   VARCHAR2(1)  := 'Y';
c_ro_flg       CONSTANT   VARCHAR2(1)  := 'N';
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';
c_obj_ver_no   CONSTANT   NUMBER       := 1;
c_aw_flg       CONSTANT   VARCHAR2(1)  := 'N';

v_row_id       VARCHAR2(20) := '';

v_dim_id       NUMBER;
v_enc_type_id  NUMBER;
v_ver_id       NUMBER;
v_attr_id      NUMBER;
v_xdim_id      NUMBER;
v_xdim_tab     VARCHAR2(30);
v_xdim_col     VARCHAR2(30);
v_xdim_cd_col  VARCHAR2(30);
v_attr_label   VARCHAR2(30);
v_attr_col     VARCHAR2(30);
v_reqd_flg     VARCHAR2(1);
v_attr_value   VARCHAR2(1000);
v_attr_date    DATE;
v_attr_num     NUMBER;
v_attr_vch     VARCHAR2(30);

v_sql_cmd      VARCHAR2(32767);

CURSOR cv_dim_attr IS
   SELECT attribute_id,
          attribute_varchar_label,
          attribute_dimension_id,
          attribute_value_column_name,
          attribute_required_flag
   FROM fem_dim_attributes_b
   WHERE dimension_id =
      (SELECT dimension_id
       FROM fem_dimensions_b
       WHERE dimension_varchar_label = c_dim_label);

e_dup_reg_id   EXCEPTION;

BEGIN

x_return_status := c_success;

-------------------------------
-- Validate Encumbrance Type ID
-------------------------------
SELECT dimension_id
INTO v_dim_id
FROM fem_dimensions_b
WHERE dimension_varchar_label = c_dim_label;

BEGIN
   SELECT encumbrance_type_id
   INTO v_enc_type_id
   FROM fem_encumbrance_types_b
   WHERE encumbrance_type_id = p_enc_type_id;
EXCEPTION
   WHEN no_data_found THEN
      v_enc_type_id := null;
END;

IF (v_enc_type_id IS NULL)
THEN
   v_enc_type_id := p_enc_type_id;
ELSE
   RAISE e_dup_reg_id;
END IF;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

----------------------------------------
-- Insert New Encumbrance Type Member --
----------------------------------------
BEGIN
   FEM_ENCUMBRANCE_TYPES_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_encumbrance_type_id => v_enc_type_id,
      x_personal_flag => c_pers_flg,
      x_encumbrance_type_code => p_enc_type_code,
      x_enabled_flag => c_enbld_flg,
      x_object_version_number => c_obj_ver_no,
      x_read_only_flag => c_ro_flg,
      x_encumbrance_type_name => p_enc_type_name,
      x_description => p_enc_type_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      RAISE e_dup_display_code;
END;

--------------------------------------------
-- Insert New Encumbrance Type Attributes --
--------------------------------------------
FOR r_dim_attr IN cv_dim_attr
LOOP
   v_attr_id := r_dim_attr.attribute_id;
   v_attr_label := r_dim_attr.attribute_varchar_label;
   v_xdim_id := r_dim_attr.attribute_dimension_id;
   v_attr_col := r_dim_attr.attribute_value_column_name;
   v_reqd_flg := r_dim_attr.attribute_required_flag;

   -------------------------------
   -- Check Attribute's Version --
   -------------------------------
   SELECT MIN(version_id)
   INTO v_ver_id
   FROM fem_dim_attr_versions_b
   WHERE attribute_id = v_attr_id
   AND default_version_flag = 'Y';

   IF (v_ver_id IS NULL)
   THEN
      IF (p_ver_name IS NULL)
      THEN
         RAISE e_no_version_name;
      ELSIF (p_ver_disp_cd IS NULL)
      THEN
         RAISE e_no_version_name;
      END IF;

      SELECT fem_dim_attr_versions_b_s.NEXTVAL
      INTO v_ver_id FROM dual;

      FEM_DIM_ATTR_VERSIONS_PKG.INSERT_ROW(
         x_rowid => v_row_id,
         x_version_id => v_ver_id,
         x_aw_snapshot_flag => c_aw_flg,
         x_version_display_code => p_ver_disp_cd,
         x_object_version_number => c_obj_ver_no,
         x_default_version_flag => 'Y',
         x_personal_flag => c_pers_flg,
         x_attribute_id => v_attr_id,
         x_version_name => p_ver_name,
         x_description => null,
         x_creation_date => sysdate,
         x_created_by => c_user_id,
         x_last_update_date => sysdate,
         x_last_updated_by => c_user_id,
         x_last_update_login => null);
   END IF;

   -----------------------------
   -- Get Attribute Parameter --
   -----------------------------
   CASE v_attr_label
      WHEN 'SOURCE_SYSTEM_CODE' THEN
         v_attr_value := p_source_cd;
      ELSE
         FEM_ENGINES_PKG.Tech_Message(
            p_severity => c_log_level_1,
            p_module => c_module_pkg||'.New_Encumbrance Type.bad_attr_list',
            p_msg_text => 'The Encumbrance Type attribute '||v_attr_label||
                          ' is in FEM_DIM_ATTRIBUTES_B but not in'||
                          ' the API''s list of attribute labels');

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_BAD_ATTR_LIST_WARN',
            p_token1 => 'ATTR',
            p_value1 => v_attr_label);
   END CASE;

   IF (v_attr_value IS NULL)
   THEN
      CASE v_reqd_flg
         WHEN 'Y' THEN
            RAISE e_null_param_value;
         ELSE null;
      END CASE;
   ELSE
      IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER' OR
          v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
      THEN
         -------------------------------------
         -- Attribute is a Dimension Attribute
         -- which needs to be validated
         -------------------------------------
         SELECT member_b_table_name,
                member_col
         INTO v_xdim_tab,
              v_xdim_col
         FROM fem_xdim_dimensions
         WHERE dimension_id = v_xdim_id;

         v_sql_cmd :=
            'SELECT '||v_xdim_col||
            ' FROM '||v_xdim_tab||
            ' WHERE '||v_xdim_col||' = :b_attr_value';

         IF (v_attr_col = 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_num
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_vch := '';
         ELSIF (v_attr_col = 'DIM_ATTRIBUTE_VARCHAR_MEMBER')
         THEN
            BEGIN
               EXECUTE IMMEDIATE v_sql_cmd
               INTO v_attr_vch
               USING v_attr_value;
            EXCEPTION
               WHEN no_data_found THEN
                  RAISE e_bad_param_value;
            END;
            v_attr_num := '';
         END IF;

         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            v_attr_num,
            v_attr_vch,
            null,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'NUMBER_ASSIGN_VALUE')
      THEN
         ----------------------------------------
         -- Attribute is an assigned number value
         ----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            v_attr_value,
            null,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'VARCHAR_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned varchar value
         -----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            null,
            v_attr_value,
            null,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);

      ELSIF (v_attr_col = 'DATE_ASSIGN_VALUE')
      THEN
         -----------------------------------------
         -- Attribute is an assigned date value
         -----------------------------------------
         INSERT INTO fem_enc_types_attr(
            attribute_id,
            version_id,
            encumbrance_type_id,
            dim_attribute_numeric_member,
            dim_attribute_varchar_member,
            number_assign_value,
            varchar_assign_value,
            date_assign_value,
            creation_date,
            created_by,
            last_updated_by,
            last_update_date,
            last_update_login,
            aw_snapshot_flag,
            object_version_number)
         VALUES(
            v_attr_id,
            v_ver_id,
            v_enc_type_id,
            null,
            null,
            null,
            null,
            v_attr_date,
            sysdate,
            c_user_id,
            c_user_id,
            sysdate,
            null,
            c_aw_flg,
            c_obj_ver_no);
      END IF;

   END IF;
END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

FND_MSG_PUB.Count_and_Get(
   p_encoded => p_encoded,
   p_count => x_msg_count,
   p_data => x_msg_data);

EXCEPTION
   WHEN e_dup_reg_id THEN
      FEM_Engines_Pkg.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_REG_MEMBER_ERR',
         p_token1 => 'DIMENSION',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dimension_Name(
                        p_dim_id => v_dim_id),
         p_trans1 => 'N',
         p_token2 => 'VALUE',
         p_value2 => p_enc_type_id);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_bad_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id),
         p_token2 => 'VALUE',
         p_value2 => v_attr_value);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_null_param_value THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NULL_PARAM_VALUE_ERR',
         p_token1 => 'PARAM',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_no_version_name THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_NO_VERSION_NAME_ERR',
         p_token1 => 'ENTITY',
         p_value1 => FEM_Dimension_Util_Pkg.Get_Dim_Attr_Name(
                        p_attr_id => v_attr_id));
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

   WHEN e_dup_display_code THEN
   ROLLBACK;
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_enc_type_code);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;

END Register_Encumbrance_Type;

/*************************************************************************

                        New_Global_VS_Combo

4/20/2005 RobFlippo  Bug#4303380  Add Global_vs_combo_display_code to the
                     Insert statement for FEM_GLOBAL_VS_COMBOS_PKG
                     -- this fix will preserve the original signature
                        for this API so that it is backward compatible
                        with OGL by employing a default for the
                        global combo display_code.  If the user passes
                        null for the display code, it set it = global combo name.

*************************************************************************/

PROCEDURE New_Global_VS_Combo (
   p_api_version     IN NUMBER     DEFAULT c_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT c_false,
   p_commit          IN VARCHAR2   DEFAULT c_false,
   p_encoded         IN VARCHAR2   DEFAULT c_true,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_global_vs_combo_id  OUT NOCOPY NUMBER,
   p_global_vs_combo_name IN VARCHAR2,
   p_global_vs_combo_desc IN VARCHAR2 DEFAULT NULL,
   p_read_only_flag       IN VARCHAR2 DEFAULT 'N',
   p_enabled_flag         IN VARCHAR2 DEFAULT 'Y',
   p_global_vs_combo_dc   IN VARCHAR2 DEFAULT NULL
)
IS

c_obj_ver_no   CONSTANT   NUMBER := 1;
c_pers_flg     CONSTANT   VARCHAR2(1)  := 'N';

v_vs_id        NUMBER  := -1;

v_row_id       VARCHAR2(20) := '';
v_gvsc_id      NUMBER;
v_vs_dim_id    NUMBER;
v_global_vs_combo_dc  VARCHAR2(150);

---------------------------------------------------
-- Cursor to get dimensions that require Value Sets
---------------------------------------------------
CURSOR c_vs_dim_ids IS
   SELECT dimension_id, dimension_varchar_label
   FROM fem_xdim_dimensions_vl
   WHERE value_set_required_flag = 'Y'
   ORDER BY dimension_id;

BEGIN

x_return_status := c_success;
x_global_vs_combo_id := -1;

Validate_OA_Params (
   p_api_version => p_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN;
END IF;

--------------------------------
-- Get New Global VS Combo ID --
--------------------------------
SELECT fem_global_vs_combos_b_s.NEXTVAL
INTO v_gvsc_id
FROM dual;
---------------------------------------
-- Validate the Global VS Combo Display Code --
---------------------------------------
IF p_global_vs_combo_dc IS NULL THEN
   v_global_vs_combo_dc := p_global_vs_combo_name;
ELSE
   v_global_vs_combo_dc := p_global_vs_combo_dc;
END IF;


---------------------------------------
-- Insert New Global VS Combo Member --
---------------------------------------
BEGIN
   FEM_GLOBAL_VS_COMBOS_PKG.INSERT_ROW(
      x_rowid => v_row_id,
      x_global_vs_combo_id => v_gvsc_id,
      x_global_vs_combo_display_code => v_global_vs_combo_dc,
      x_enabled_flag => p_enabled_flag,
      x_read_only_flag => p_read_only_flag,
      x_personal_flag => c_pers_flg,
      x_object_version_number => c_obj_ver_no,
      x_global_vs_combo_name => p_global_vs_combo_name,
      x_description => p_global_vs_combo_desc,
      x_creation_date => sysdate,
      x_created_by => c_user_id,
      x_last_update_date => sysdate,
      x_last_updated_by => c_user_id,
      x_last_update_login => null);
EXCEPTION
   WHEN dup_val_on_index THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_DUP_DISPLAY_CODE_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_global_vs_combo_name);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_error;
      RETURN;
END;

----------------------------------------------------------------
-- Initialize Value Set ID for each value-set_required dimension
----------------------------------------------------------------
FOR r_vs_dim_id IN c_vs_dim_ids
LOOP

   -- Retrieve the seeded value set for the dimension
   -- We do this by getting the value_set_id that has
   -- the display_code = dimension varchar label
   SELECT value_set_id
   INTO v_vs_id
   FROM fem_value_sets_b
   WHERE dimension_id = r_vs_dim_id.dimension_id
   AND value_set_display_code = r_vs_dim_id.dimension_varchar_label;

   -- RCF 4/20/2005 Obsolete - v_vs_dim_id := r_vs_dim_id.dimension_id;

   INSERT INTO fem_global_vs_combo_defs
     (global_vs_combo_id,
      dimension_id,
      value_set_id,
      creation_date,
      created_by,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
   VALUES
     (v_gvsc_id,
      r_vs_dim_id.dimension_id,
      v_vs_id,
      sysdate,
      c_user_id,
      c_user_id,
      sysdate,
      null,
      c_obj_ver_no);
END LOOP;

IF (p_commit = c_true)
THEN
   COMMIT;
END IF;

x_global_vs_combo_id := v_gvsc_id;

END New_Global_VS_Combo;

/*************************************************************************

                         Get_Dim_Attr_ID_Ver_ID

*************************************************************************/

PROCEDURE Get_Dim_Attr_ID_Ver_ID (
   p_dim_id          IN NUMBER,
   p_attr_label      IN VARCHAR,
   x_attr_id        OUT NOCOPY   NUMBER,
   x_ver_id         OUT NOCOPY   NUMBER,
   x_err_code       OUT NOCOPY   NUMBER
)
IS
BEGIN

x_err_code := 0;

SELECT A.attribute_id,
       V.version_id
INTO   x_attr_id,
       x_ver_id
FROM   fem_dim_attributes_b A,
       fem_dim_attr_versions_b V
WHERE attribute_varchar_label = p_attr_label
AND   dimension_id = p_dim_id
AND   A.attribute_id = V.attribute_id
AND   V.default_version_flag = 'Y';

EXCEPTION
   WHEN no_data_found THEN
      x_err_code := 2;
END Get_Dim_Attr_ID_Ver_ID;

/*************************************************************************

                         Get_Dim_Member_ID

          This function returns a dimension member ID

NOTE:  This procedure assumes that the dimension being evaluated
       is a surrogate key dimension.  If the dimension does not have
       a surrogate key (i.e., member_col = member_display_code_col),
       then the function returns a -1 since there is no "member_id"
       for that members of that dimension.

HISTORY:
Rob Flippo 2/17/2006 Bug#5040996 - added support for Composite dimensions

*************************************************************************/

FUNCTION Get_Dim_Member_ID (
   p_api_version                 IN  NUMBER     DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2   DEFAULT c_false,
   p_commit                      IN  VARCHAR2   DEFAULT c_false,
   p_encoded                     IN  VARCHAR2   DEFAULT c_true,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   p_dimension_varchar_label     IN  VARCHAR2,
   p_member_display_code         IN  VARCHAR2,
   p_member_vs_display_code      IN  VARCHAR2
) RETURN VARCHAR2
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.get_dim_member_id';

v_dim_id         NUMBER;
v_vs_id          NUMBER;
v_mem_b_tab      VARCHAR2(30);
v_mem_col        VARCHAR2(30);
v_mem_dc_col     VARCHAR2(30);
v_vs_req_flg     VARCHAR2(1);
v_gvsc_id        NUMBER; --- Global Value Set Combo ID for the users session

v_comp_dim_flg   VARCHAR2(1); -- Designates if the dimension is a composite dim
v_member_id      NUMBER;

v_sql_stmt       VARCHAR2(32767);

-- OUT parameters for calling the Global_vs_combo_id function
-- we ignore these parameters - if there is an error, that function
-- will post a message to the stack and this api exits via the When OTHERS
v_return_status  VARCHAR2(100);
v_msg_count      NUMBER;
v_msg_data       VARCHAR2(4000);

e_bad_dim_label  EXCEPTION;
e_bad_vs_code    EXCEPTION;
e_no_member      EXCEPTION;

BEGIN

---------------------------
-- Verify the OA parameters
---------------------------
FEM_Dimension_Util_Pkg.Validate_OA_Params (
   p_api_version => c_api_version,
   p_init_msg_list => p_init_msg_list,
   p_commit => p_commit,
   p_encoded => p_encoded,
   x_return_status => x_return_status);

IF (x_return_status <> c_success)
THEN
   FND_MSG_PUB.Count_and_Get(
      p_encoded => c_false,
      p_count => x_msg_count,
      p_data => x_msg_data);
   RETURN -1;
END IF;

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_varchar_label = p_dimension_varchar_label;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_bad_dim_label;
END;

-------------------------------
-- Get the Dimension's metadata
-------------------------------
SELECT member_b_table_name,
       member_col,
       member_display_code_col,
       value_set_required_flag,
       composite_dimension_flag
INTO   v_mem_b_tab,
       v_mem_col,
       v_mem_dc_col,
       v_vs_req_flg,
       v_comp_dim_flg
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

---------------------------------
-- Verify the specified Value Set
---------------------------------

v_gvsc_id := null;
v_vs_id := null;
-- For composite dimensions, we also need to get the Global VS Combo
-- for the user's session
IF (v_comp_dim_flg = 'Y')
THEN
  v_gvsc_id :=
    Global_VS_Combo_ID (
      x_return_status  => v_return_status,
      x_msg_count      => v_msg_count,
      x_msg_data       => v_msg_data,
      p_ledger_id      => null);

ELSIF (v_vs_req_flg = 'Y')
THEN
   BEGIN
      SELECT value_set_id
      INTO   v_vs_id
      FROM   fem_value_sets_b
      WHERE  value_set_display_code = p_member_vs_display_code
      AND    dimension_id = v_dim_id;
   EXCEPTION
      WHEN no_data_found THEN
          RAISE e_bad_vs_code;
   END;
ELSE
   v_vs_id := null;
END IF;

----------------
-- Get Member ID
----------------
IF (v_gvsc_id IS NOT NULL)  -- query for composite dims
THEN
   v_sql_stmt :=
   'SELECT '||v_mem_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_dc_col||' = :b_member_display_code'||
   ' AND local_vs_combo_id = :b_gvsc_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_id
      USING p_member_display_code,
            v_gvsc_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_member;
   END;

ELSIF (v_vs_id  IS NOT NULL) -- query for value set dims
THEN
   v_sql_stmt :=
   'SELECT '||v_mem_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_dc_col||' = :b_member_display_code'||
   ' AND value_set_id = :b_vs_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_id
      USING p_member_display_code,
            v_vs_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_member;
   END;
ELSE
   v_sql_stmt :=
   'SELECT '||v_mem_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_dc_col||' = :b_member_display_code';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_id
      USING p_member_display_code;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_no_member;
   END;
END IF;

x_return_status := c_success;
RETURN v_member_id;

------------------
-- Exception Block
------------------
EXCEPTION

WHEN e_bad_dim_label THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_BAD_DIM_LABEL',
      p_token1 => 'DIM_LABEL',
      p_value1 => p_dimension_varchar_label);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := c_error;
   RETURN -1;

WHEN e_bad_vs_code THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_BAD_VS_CODE',
      p_token1 => 'VS_CODE',
      p_value1 => p_member_vs_display_code);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
  x_return_status := c_error;
   RETURN -1;

WHEN e_no_member THEN
   FEM_ENGINES_PKG.Put_Message(
      p_app_name => 'FEM',
      p_msg_name => 'FEM_DIM_NO_MEMBER',
      p_token1 => 'MEM_CODE',
      p_value1 => p_member_display_code);
   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);
   x_return_status := c_error;
   RETURN -1;

  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := c_unexp;
    RETURN -1;


END Get_Dim_Member_ID;

/*************************************************************************

                         Get_Dim_Attr_Name

*************************************************************************/

FUNCTION Get_Dim_Attr_Name (
   p_attr_id        IN   NUMBER
) RETURN VARCHAR2
IS
   v_attr_name VARCHAR2(80);
BEGIN

SELECT attribute_name
INTO v_attr_name
FROM fem_dim_attributes_tl
WHERE attribute_id = p_attr_id
AND   language = userenv('LANG');

RETURN v_attr_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END Get_Dim_Attr_Name;

--------------------------------------------------------------------------

FUNCTION Get_Dim_Attr_Name (
   p_dim_id        IN   NUMBER,
   p_attr_label    IN   VARCHAR2
) RETURN VARCHAR2
IS
   v_attr_name VARCHAR2(80);
BEGIN

SELECT T.attribute_name
INTO v_attr_name
FROM fem_dim_attributes_b B,
     fem_dim_attributes_tl T
WHERE B.attribute_varchar_label = p_attr_label
AND B.dimension_id = p_dim_id
AND T.attribute_id = B.attribute_id
AND T.language = userenv('LANG');

RETURN v_attr_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END Get_Dim_Attr_Name;

--------------------------------------------------------------------------

FUNCTION Get_Dim_Attr_Name (
   p_dim_label     IN   VARCHAR2,
   p_attr_label    IN   VARCHAR2
) RETURN VARCHAR2
IS
   v_attr_name VARCHAR2(80);
BEGIN

SELECT AT.attribute_name
INTO v_attr_name
FROM fem_dim_attributes_b AB,
     fem_dim_attributes_tl AT,
     fem_dimensions_b DB
WHERE AB.attribute_varchar_label = p_attr_label
AND DB.dimension_varchar_label = p_dim_label
AND AB.dimension_id = DB.dimension_id
AND AT.attribute_id = AB.attribute_id
AND AT.language = userenv('LANG');

RETURN v_attr_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END Get_Dim_Attr_Name;

/*************************************************************************

                         Get_Dimension_Name

*************************************************************************/

FUNCTION Get_Dimension_Name (
   p_dim_id        IN   NUMBER
) RETURN VARCHAR2
IS
   v_dim_name VARCHAR2(80);
BEGIN

SELECT dimension_name
INTO v_dim_name
FROM fem_dimensions_tl
WHERE dimension_id = p_dim_id
AND language = userenv('LANG');

RETURN v_dim_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END Get_Dimension_Name;

--------------------------------------------------------------------------

FUNCTION Get_Dimension_Name (
   p_dim_label    IN   VARCHAR2
) RETURN VARCHAR2
IS
   v_dim_name VARCHAR2(80);
BEGIN

SELECT T.dimension_name
INTO v_dim_name
FROM fem_dimensions_b B,
     fem_dimensions_tl T
WHERE B.dimension_varchar_label = p_dim_label
AND T.dimension_id = B.dimension_id
AND T.language = userenv('LANG');

RETURN v_dim_name;

EXCEPTION
   WHEN no_data_found THEN
      RETURN null;
END Get_Dimension_Name;

/*************************************************************************

                         OA Exception Handler

*************************************************************************/

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;
BEGIN

x_return_status := c_success;

CASE p_api_version
   WHEN c_api_version THEN NULL;
   ELSE RAISE e_bad_p_api_ver;
END CASE;

CASE p_init_msg_list
   WHEN c_false THEN NULL;
   WHEN c_true THEN
      FND_MSG_PUB.Initialize;
   ELSE RAISE e_bad_p_init_msg_list;
END CASE;

CASE p_encoded
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_encoded;
END CASE;

CASE p_commit
   WHEN c_false THEN NULL;
   WHEN c_true THEN NULL;
   ELSE RAISE e_bad_p_commit;
END CASE;

EXCEPTION
   WHEN e_bad_p_api_ver THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      x_return_status := c_error;

   WHEN e_bad_p_init_msg_list THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_encoded THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_commit THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      x_return_status := c_error;

END Validate_OA_Params;

/*************************************************************************

                         Get_Default_Dim_Member

Purpose:  This function returns the default dimension member code and
          display code given a ledger ID and dimension.

Usage:    The caller has the option to provide either the dimension ID
          or dimension varchar label - but at least one must be provided.
          If both are provided, the dimension ID is used.

          Ledger ID is an optional parameter because:
           1) Only value set required (VSR) dimensions require the ledger ID.
              In fact, for non VSR dimensions, if Ledger ID is provided,
              it is ignored.
           2) Even for VSR dimensions, if the Ledger ID is left null, this
              API will attempt to find a default ledger based on the
              User Profile: 'FEM_LEDGER'.

Return variables:
   x_member_code           - Member ID/Code
   x_member_data_type      - Member ID/Code Data Type
                            (from FEM_XDIM_DIMENSIONS.MEMBER_DATA_TYPE_CODE)
   x_member_display_code   - Member Display Code
   x_return_status
      - FND_API.G_RET_STS_SUCCESS ('S') if default member was found
      - FND_API.G_RET_STS_ERROR ('E') if no default member exists
      - FND_API.G_RET_STS_UNEXP_ERROR if something unexpected occurs

*************************************************************************/

PROCEDURE Get_Default_Dim_Member (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT c_false,
   p_commit                      IN  VARCHAR2 DEFAULT c_false,
   p_encoded                     IN  VARCHAR2 DEFAULT c_true,
   p_dimension_id                IN  NUMBER DEFAULT NULL,
   p_dimension_varchar_label     IN  VARCHAR2 DEFAULT NULL,
   p_ledger_id                   IN  NUMBER DEFAULT NULL,
   x_member_code                 OUT NOCOPY VARCHAR2,
   x_member_data_type            OUT NOCOPY VARCHAR2,
   x_member_display_code         OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.get_default_dim_member';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Default_Dim_Member';
  e_no_member         EXCEPTION;

  v_dim_id            FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_member_table      FEM_XDIM_DIMENSIONS.member_b_table_name%TYPE;
  v_member_col        FEM_XDIM_DIMENSIONS.member_col%TYPE;
  v_member_dc_col     FEM_XDIM_DIMENSIONS.member_display_code_col%TYPE;
  v_vsr_flag          FEM_XDIM_DIMENSIONS.value_set_required_flag%TYPE;
  v_default_member_dc FEM_XDIM_DIMENSIONS.default_member_display_code%TYPE;
  v_vs_id             FEM_VALUE_SETS_B.value_set_id%TYPE;
  v_default_member    FEM_XDIM_DIMENSIONS.default_member_display_code%TYPE;
  v_sql               VARCHAR2(4000);

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RETURN;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_ledger_id = '||to_char(p_ledger_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_dimension_id = '||to_char(p_dimension_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_dimension_varchar_label = '||p_dimension_varchar_label);
  END IF;

  -- Make sure at least one dimension parameter is provided
  IF p_dimension_id IS NULL AND p_dimension_varchar_label IS NULL THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'At least one of the dimension parameters must be provided');
    END IF;
    RAISE e_unexp;
  END IF;

  -- Obtain some dimension info
  BEGIN
    IF p_dimension_id IS NULL THEN
      SELECT dimension_id
      INTO v_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = p_dimension_varchar_label;
    ELSE
      v_dim_id := p_dimension_id;
    END IF;

    SELECT member_b_table_name,
           member_col,
           member_display_code_col,
           member_data_type_code,
           value_set_required_flag,
           default_member_display_code
    INTO   v_member_table,
           v_member_col,
           v_member_dc_col,
           x_member_data_type,
           v_vsr_flag,
           v_default_member_dc
    FROM   fem_xdim_dimensions
    WHERE  dimension_id = v_dim_id;

    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'XDIM Info for dim '||v_dim_id
                   ||': v_member_table = '||v_member_table
                   ||', v_member_col = '||v_member_col
                   ||', v_member_dc_col = '||v_member_dc_col
                   ||', v_vsr_flag = '||v_vsr_flag
                   ||', v_default_member_dc = '||v_default_member_dc);
    END IF;

  EXCEPTION WHEN no_data_found THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Dimension is not registered in FEM_DIMENSIONS_B or FEM_XDIM_DIMENSIONS');
    END IF;
    RAISE e_unexp;
  END;

  -- If dimension is a VSR dimension, then the default
  -- member is stored in with the Global Combo Value Set.
  -- Otherwise, it is stored in XDIM_DIMENSIONS.
  IF v_vsr_flag = 'Y' THEN
    v_vs_id := Dimension_Value_Set_ID (
                  p_api_version    => 1.0,
                  p_init_msg_list  => p_init_msg_list,
                  p_commit         => p_commit,
                  p_encoded        => p_encoded,
                  p_dimension_id   => v_dim_id,
                  p_ledger_id      => p_ledger_id,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data);

    IF x_return_status <> c_success THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Call to Dimension_Value_Set_ID failed');
      END IF;
      raise e_unexp;
    END IF;

    BEGIN
      SELECT default_load_member_id
      INTO v_default_member
      FROM fem_value_sets_b
      WHERE value_set_id = v_vs_id;

      -- Get the default member display code
      IF v_default_member IS NOT NULL THEN
        v_sql :=  'SELECT '||v_member_dc_col
               ||' FROM '||v_member_table
               ||' WHERE '||v_member_col||' = :v_default_member'
               ||' AND value_set_id = :v_vs_id';

        BEGIN
          v_default_member_dc := NULL;

          EXECUTE IMMEDIATE v_sql
          INTO v_default_member_dc
          USING v_default_member, v_vs_id;
        EXCEPTION WHEN no_data_found THEN
          IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_statement,
              p_module   => C_MODULE,
              p_msg_text => 'Following SQL failed to return rows: '||v_sql);
            FEM_ENGINES_PKG.TECH_MESSAGE(
              p_severity => FND_LOG.level_statement,
              p_module   => C_MODULE,
              p_msg_text => 'Cannot find the dimension member (ID) = '||to_char(v_default_member)
                         ||' in '||v_member_table||' where vaset set ID = '||to_char(v_vs_id));
          END IF;
          RAISE e_no_member;
        END;
      END IF; -- v_default_member IS NOT NULL
    EXCEPTION WHEN no_data_found THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Cannot find value set ID = '||to_char(v_vs_id));
      END IF;
      RAISE e_unexp;
    END;
  ELSE -- v_vsr_flag = 'N'
    -- Get the default member code
    IF v_default_member_dc IS NOT NULL THEN
      v_sql :=  'SELECT '||v_member_col
             ||' FROM '||v_member_table
             ||' WHERE '||v_member_dc_col||' = :v_default_member_dc';

      BEGIN
        EXECUTE IMMEDIATE v_sql
        INTO v_default_member
        USING v_default_member_dc;
      EXCEPTION WHEN no_data_found THEN
        IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => 'Following SQL failed to return rows: '||v_sql);
          FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => FND_LOG.level_statement,
            p_module   => C_MODULE,
            p_msg_text => 'Cannot find the dimension member (display code) '
                       ||v_default_member_dc||' in '||v_member_table);
        END IF;
        RAISE e_no_member;
      END;
    END IF; -- v_default_member IS NOT NULL
  END IF; -- v_vsr_flag

  -- set return vars
  x_member_code := v_default_member;
  x_member_display_code := v_default_member_dc;

  IF x_member_code IS NULL THEN
    x_return_status := c_error;
  ELSE
    x_return_status := c_success;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_member_code = '||x_member_code);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_member_data_type = '||x_member_data_type);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_member_display_code = '||x_member_display_code);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_return_status = '||x_return_status);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_no_member THEN
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_member_code := NULL;
    x_member_data_type := NULL;
    x_member_display_code := NULL;
    x_return_status := c_error;
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := c_unexp;

END Get_Default_Dim_Member;

/*************************************************************************

                         Get_Default_Dim_Member

Purpose:  This procedure returns the default dimension member code and display code
          given a ledger ID, table name and column name.

Usage:    Ledger ID is an optional parameter because:
           1) Only value set required (VSR) dimensions require the ledger ID.
              In fact, for non VSR dimensions, if Ledger ID is provided,
              it is ignored.
           2) Even for VSR dimensions, if the Ledger ID is left null, this
              API will attempt to find a default ledger based on the
              User Profile: 'FEM_LEDGER'.

Return variables:
   x_member_code           - Member ID/Code
   x_member_data_type      - Member ID/Code Data Type
                            (from FEM_XDIM_DIMENSIONS.MEMBER_DATA_TYPE_CODE)
   x_member_display_code   - Member Display Code
   x_return_status
      - FND_API.G_RET_STS_SUCCESS ('S') if default member was found
      - FND_API.G_RET_STS_ERROR ('E') if no default member exists
      - FND_API.G_RET_STS_UNEXP_ERROR if something unexpected occurs

*************************************************************************/

PROCEDURE Get_Default_Dim_Member (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT c_false,
   p_commit                      IN  VARCHAR2 DEFAULT c_false,
   p_encoded                     IN  VARCHAR2 DEFAULT c_true,
   p_table_name                  IN  VARCHAR2,
   p_column_name                 IN  VARCHAR2,
   p_ledger_id                   IN  NUMBER DEFAULT NULL,
   x_member_code                 OUT NOCOPY VARCHAR2,
   x_member_data_type            OUT NOCOPY VARCHAR2,
   x_member_display_code         OUT NOCOPY VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS

  C_MODULE        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_dimension_util_pkg.get_default_dim_member.table';
  C_API_VERSION   CONSTANT NUMBER := 1.0;
  C_API_NAME      CONSTANT VARCHAR2(30)  := 'Get_Default_Dim_Member';

  v_dim_id           FEM_DIMENSIONS_B.dimension_id%TYPE;

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := c_unexp;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                G_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_encoded => p_encoded,
    x_return_status => x_return_status);

  IF (x_return_status <> c_success) THEN
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RETURN;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_ledger_id = '||to_char(p_ledger_id));
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_table_name = '||p_table_name);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_column_name = '||p_column_name);
  END IF;

  -- Determine the dimension associated with the column
  BEGIN
    SELECT dimension_id
    INTO v_dim_id
    FROM fem_tab_columns_b
    WHERE table_name = Upper(p_table_name)
    AND column_name = Upper(p_column_name);

    IF v_dim_id IS NULL THEN
      IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FEM_ENGINES_PKG.TECH_MESSAGE(
          p_severity => FND_LOG.level_statement,
          p_module   => C_MODULE,
          p_msg_text => 'Column does not point to a dimension');
      END IF;
      RAISE e_unexp;
    END IF;

  EXCEPTION WHEN no_data_found THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Column is not registered in FEM_TAB_COLUMNS_B');
    END IF;
    RAISE e_unexp;
  END;

  -- Call Get_Default_Dim_Member with the dimension ID
  -- to obtain the default dim member
  Get_Default_Dim_Member (
              p_api_version            => 1.0,
              p_init_msg_list          => p_init_msg_list,
              p_commit                 => p_commit,
              p_encoded                => p_encoded,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data,
              p_dimension_id           => v_dim_id,
              p_ledger_id              => p_ledger_id,
              x_member_code            => x_member_code,
              x_member_data_type       => x_member_data_type,
              x_member_display_code    => x_member_display_code);

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := c_unexp;

END Get_Default_Dim_Member;


/*************************************************************************

                      Get_Dim_Member_Display_Code

*************************************************************************/

FUNCTION Get_Dim_Member_Display_Code (
   p_dimension_id                IN  NUMBER,
   p_dimension_member_id         IN  VARCHAR2,
   p_dimension_member_vs_id      IN  NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS

v_dim_id         NUMBER;
v_vs_id          NUMBER;
v_mem_b_tab      VARCHAR2(30);
v_mem_col        VARCHAR2(30);
v_mem_dc_col     VARCHAR2(30);
v_vs_req_flg     VARCHAR2(1);

v_member_display_code    VARCHAR(150);

v_sql_stmt       VARCHAR2(32767);

e_error          EXCEPTION;

BEGIN

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_id = p_dimension_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_error;
END;

-------------------------------
-- Get the Dimension's metadata
-------------------------------
SELECT member_b_table_name,
       member_col,
       member_display_code_col,
       value_set_required_flag
INTO   v_mem_b_tab,
       v_mem_col,
       v_mem_dc_col,
       v_vs_req_flg
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

---------------------------------
-- Verify the specified Value Set
---------------------------------
IF (v_vs_req_flg = 'Y')
THEN
   BEGIN
      SELECT value_set_id
      INTO   v_vs_id
      FROM   fem_value_sets_b
      WHERE  value_set_id = p_dimension_member_vs_id
      AND    dimension_id = v_dim_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
ELSE
   v_vs_id := null;
END IF;

----------------
-- Get Member ID
----------------
IF (v_vs_id  IS NOT NULL)
THEN
   v_sql_stmt :=
   'SELECT '||v_mem_dc_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_col||' = :b_dimension_member_id'||
   ' AND value_set_id = :b_vs_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_display_code
      USING p_dimension_member_id,
            v_vs_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
ELSE
   v_sql_stmt :=
   'SELECT '||v_mem_dc_col||
   ' FROM '||v_mem_b_tab||
   ' WHERE '||v_mem_col||' = :b_dimension_member_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_display_code
      USING p_dimension_member_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
END IF;

RETURN v_member_display_code;

------------------
-- Exception Block
------------------
EXCEPTION

WHEN e_error THEN
   RETURN null;

END Get_Dim_Member_Display_Code;


/*************************************************************************

                      Get_Dim_Member_Name

*************************************************************************/

FUNCTION Get_Dim_Member_Name (
   p_dimension_id                IN  NUMBER,
   p_dimension_member_id         IN  VARCHAR2,
   p_dimension_member_vs_id      IN  NUMBER DEFAULT NULL
) RETURN VARCHAR2
IS

v_dim_id         NUMBER;
v_vs_id          NUMBER;
v_mem_vl_tab     VARCHAR2(30);
v_mem_col        VARCHAR2(30);
v_mem_name_col   VARCHAR2(30);
v_vs_req_flg     VARCHAR2(1);

v_member_name    VARCHAR(150);

v_sql_stmt       VARCHAR2(32767);

e_error          EXCEPTION;

BEGIN

---------------------------------
-- Verify the specified Dimension
---------------------------------
BEGIN
   SELECT dimension_id
   INTO   v_dim_id
   FROM   fem_dimensions_b
   WHERE  dimension_id = p_dimension_id;
EXCEPTION
   WHEN no_data_found THEN
      RAISE e_error;
END;

-------------------------------
-- Get the Dimension's metadata
-------------------------------
SELECT member_vl_object_name,
       member_col,
       member_name_col,
       value_set_required_flag
INTO   v_mem_vl_tab,
       v_mem_col,
       v_mem_name_col,
       v_vs_req_flg
FROM   fem_xdim_dimensions
WHERE  dimension_id = v_dim_id;

---------------------------------
-- Verify the specified Value Set
---------------------------------
IF (v_vs_req_flg = 'Y')
THEN
   BEGIN
      SELECT value_set_id
      INTO   v_vs_id
      FROM   fem_value_sets_b
      WHERE  value_set_id = p_dimension_member_vs_id
      AND    dimension_id = v_dim_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
ELSE
   v_vs_id := null;
END IF;

----------------
-- Get Member ID
----------------
IF (v_vs_id  IS NOT NULL)
THEN
   v_sql_stmt :=
   'SELECT '||v_mem_name_col||
   ' FROM '||v_mem_vl_tab||
   ' WHERE '||v_mem_col||' = :b_dimension_member_id'||
   ' AND value_set_id = :b_vs_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_name
      USING p_dimension_member_id,
            v_vs_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
ELSE
   v_sql_stmt :=
   'SELECT '||v_mem_name_col||
   ' FROM '||v_mem_vl_tab||
   ' WHERE '||v_mem_col||' = :b_dimension_member_id';

   BEGIN
      EXECUTE IMMEDIATE v_sql_stmt
      INTO v_member_name
      USING p_dimension_member_id;
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_error;
   END;
END IF;

RETURN v_member_name;

------------------
-- Exception Block
------------------
EXCEPTION

WHEN e_error THEN
   RETURN null;

END Get_Dim_Member_Name;


---------------------------------------------

END FEM_Dimension_Util_Pkg;

/
