--------------------------------------------------------
--  DDL for Package Body FEM_DIM_MEMBER_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DIM_MEMBER_LOADER_PKG" AS
-- $Header: femdimldr_pkb.plb 120.22 2008/02/15 18:20:28 gcheng ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    femdimldr_pkb.plb

  DESCRIPTION
    See femdimldr_pkh.pls for details

  HISTORY
  Rob Flippo 20-Oct-2003  Created
  Rob Flippo 24-Dec-2003  Fixed put message for unexpected error
                          Added log messages in GET_ATTR_VERSION
                          Fixed GET_ATTR_VERSION so that version_id
                          select returns only versions for that
                          attribute and dimension label combo
  Rob Flippo 29-Dec-2003  Fixed read_only_flag select from
                          FEM_DIM_ATTRIBUTES_B to
                          assignment_is_read_only;
                          Also fixed case where new member has
                          TL row but with status <>'LOAD' - now
                          such members get status update
                          'MISSING NAME';
  Rob Flippo 02-Jan-2004   Fixed problem where missing required
                           attribute did not update _B status
  Rob Flippo 06-Jan-2004   Fixed no_data_found problem for
                           retrieving attr assign value set
  Rob Flippo 16-Mar-2004   Modified for Drop3 db.  Implemented
                           Process Locks;  Implemented other changes
                           documented in the detail design doc.
  Rob Flippo 24-Mar-2004   Fixed problem with null dimension_group
                           for member loads.  To do this, added outer
                           join (+) to attr_select and member_Select
                           queries
  Rob Flippo 31-Mar-2004   Implemented Error Reprocesing.  Fixed
                           several bugs having to do with outputing
                           the correct status for failed records,
                           and preventing members from loading with
                           insufficient req attr assignments in the
                           _ATTR_T table.
  Rob Flippo 06-May-2004   Implemented changes for Multi-processing.
                           Also added support for non-value set
                           attribute dims, like Financial Element,
                           Dataset, etc.
  Rob Flippo 29-June-2004  Remove deprecated code for
                           BULK_FETCH_LIMIT profile option
  Rob Flippo 16-Sep-2004   Bug#3835758  Incorrect logic on checking
                           the Value Set of Attribute assignments
                           Bug#3848996  Simple Dimension loads fail

                           Also fixed several issues with the
                           status messaging. Previously, error rows
                           were getting incorrect STATUS.
                           Also removed the error row count from the
                           log, since it is not possible for this
                           number to be accurate due to the fact that
                           the loader performs several bulk updates
                           on bad data in the interface tables.

                           Also fixed the logic on checking attributes
                           in FEM_DIM_ATTR_GRPS - this has been
                           changed so that the loader ignores any
                           entries into FEM_DIM_ATTR_GRPS for required
                           attributes assigned. Because the DHM is
                           supposed to prevent such occurrences - only
                           optional attributes are allowed to be
                           assigned to a specific group.
  Rob Flippo 17-Sep-04     Bug#3843739 DIM LOAD REPROCESS FAILS IF
                           _TL_T STATUS=LOAD.
                           This is fixed by modifying the loader so
                           that when run in Error Reprocessing mode
                           it loads both 'LOAD' and error status
                           records.
                           Bug#3881433 ERROR MESSAGE REQUIRED TO
                           DEBUG MULTI LANG LOADS THAT FAIL.
                           The loader now updates the STATUS column
                           in _TL_T table to "LANGUAGE_NOT_INSTALLED"
                           for all records where the LANGUAGE value
                           is not designated as installed in
                           FND_LANGUAGES.
  Rob Flippo 21-Sep-04     Bug#3900960 INSUFFICIENT ERROR MESSAGES
                           WHEN RUNNING FEM DIMENSION LOADER
                           - to fix this, add to_char wrapper
                             on date values inside of the to_date
  Rob Flippo 27-Sep-04     Bug#3906366 ADD ABILITY TO
                           TRACK NUMBER OF ERROR ROWS IN THE MEMBER
                           LOADER
                           --  added accumulators for total rows
                               to load as well as counting all the
                               various error rows encountered
                           Bug#3909390 SIMPLE DIM LOADER ISSUE WHEN
                           SAME MEMBER_CODE IN 2 DIFFT TBLS
                           -- This was fixed by adding a where
                           condition on the "existing" mbr select stmt
                            on dimension_varchar_label when the load
                              is for simple dims.
  Rob Flippo 28-Sep-04    Bug#3906218 NEED ABILITY TO UNDELETE
                          DIMENSIONS
                          -- added new procedure
                             build_enable_update_stmt;  modified the
                             Base_Update procedure to call this new
                             update
  Rob Flippo 01-OCT-04    Bug#3925620 CAL PERIOD LOAD FAILS WHEN
                          UPDATING CAL_PERIOD_END_DATE ATTRIBUTE IN
                          INTF TABLE
                          -- The loader now allows update on
                             assignment_is_read_only attributes, but
                             only as long as the update is identical
                             to the existing assignment.
  Rob Flippo 11-OCT-04    Bug#3906182  Enable RCM dimensions for
                          loading
                          - added object_definition_id values
                            to the CASE statement in Main
  Rob Flippo 13-OCT-04    Added SIC and Credit Status dims

  Rob Flippo 27-OCT-04    Bug#3973837
                          FEM.C.DP3.4: DIMENSION LOADER
                          ERRORS ALL ATTRIBUTES IN ATTR_T TABLE
                          -- this change affected the
                             build_bad_attr_select_stmt procedure

  Rob Flippo 01-NOV-04   Attributes for members with
                         invalid_dim_grps not getting updated -
                         modified new_members procedure
                         so that it continues even if bad drp
                         or value_set so that the attr records
                         get updated.
  Rob Flippo 11-NOV-04   Bug#4002917 DIM LDR SHOULD PROHIBIT
                         OVERLAP CAL PERIODS
                         - modify the start/end date validations
                           for cal period so that overlaps are
                           prevented;
                         also added restriction that
                         cal_period_number must always be >0
  Rob Flippo 22-NOV-04   Overlap changes
                         Bug#4019853 - Fix Data Overlap logic -
                         Added section that checks within the
                         attr array for date overlaps.  This logic
                         assumes num_of_processes = 1 for CAL_PEIOD
                         load
  Rob Flippo 23-NOV-04   Fixes to the error counts

  Rob Flippo 24-NOV-04   Bug#4031308 Remove periods_in_year check
  Rob Flippo 16-DEC-04   Bug#4061097 CAN NOT CREATE BUDGET DIM USING
                            DIMENSION MEMBER LOADER
                         Bug#3654256 UPDATE DIMENSION NAMES IN DHM
                            SHOULD ALSO UPDATE LOADER OBJECT NAMES
                         -- the loader now requires a dim_id as a
                           parm and reads the associated object_Def_id
                            from the fem_Xdim_dimensions table
  Rob Flippo 02-FEB-05   Bug#4066869 FEM.D MODIFY DIM MBR LOADER TO
                         READ DIM_ID AS PARM INSTEAD OF OBJECT_DEF_ID
                         Bug#4030717 FEM.D: MODIFY DIM MBR LOADER
                         OVERLAP DATE LOGIC TO ALLOW MP FOR CAL_PERIOD
                         Bug#3822561 FEM.D.1.DP1: MODIFY DIM MEMBER
                         LOADER TO SUPPORT ATTRIBUTES OF CAL PERIOD
                         -- added the CALPATTR columns to support
                            attributes of CAL_PERIOD dimension;
                         -- revised the OVERLAP logic so that it now
                            uses temporary tables.  This means that
                         CAL_PERIOD loads can now be Multi-processed
                         -- implemented FEM_SHARED_ATTR_T as a
                            shared interface table for attributed
                            dimensions that don't have their own
                            separate tables
  Rob Flippo 02-FEB-18   Fix Dimension Group problem where if name
                         is same for 2 dim grps in different dims
                         the loader fails because of no where
                         condition on dimension_id
                         -- this prob recognized in FEM.C in
                            bug#4189544
  Rob Flippo 02-MAR-05   Bug#4170444 Add check to see if
                         READ_ONLY_FLAG='Y' in the target ATTR
                         table for existing rows.  If it is, then
                         set STATUS = 'PROTECTED_ATTR_ASSIGN'
  Rob Flippo 03-MAR-05  Modify base_update so that for dim grp
                        load we don't
                 get a unique dimgrp seq error unless the conflict is
                 caused by a dimension group other than the one
                 that is being loaded.
  Rob Flippo 15-MAR-05  Bug#4226011
                        - new entity attributes require new col
                    USER_ASSIGN_ALLOWED_FLAG in FEM_DIM_ATTRIBUTES_B.
                    Modify all attribute queries to exclude attributes
                    where user_assign_allowed_flag = 'N';  Also add
                    update in Pre_Valid_attr to mark rows where the
                    attribute_varchar_label is
                    user_assign_allowed_flag='N';
                      -- also fix enabled_flag update stmt to use
                         value_set in the subquery
  Rob Flippo 22-MAR-05  Bug#4030730 add ability to update dimgrp
                        of a member
                    as long as member not in a sequence enforced hier;
                        Add p_dimension_id as parm for
                        build_remain_mbr_select
  Rob Flippo 22-APR-05  Bug#4305050 Calendar_ID and Dimension_Group_ID
                        were being swapped on insert member in
                        Post_Cal_Periods procedure
  sshanmug   28-APR-05  Support for Composite Dimension Loader
                        Added the following PROCEDURES
                        Pre_Process
                        Process_Rows
                        Get_Display_Codes

  sshanmug   09-MAY-05  Modified according to Nico Review comments
                        Added a PROCEDURE  Metadata_Initialize
  Rflippo    26-MAY-05  Bug#4355484
                        Added raise_member_bus_event procedure
                        to be called
                        whenever a new member is created
  Rob Flippo 02-JUN-05  Bug#4408918 Fix Overlap comparisons to not use
                        to_char and instead do direct date compare
                        using bind variables
  Rob Flippo 14-JUN-05  Bug numbers:
                        4107370 - folder security
                        3920599 - log file changes
                        3928148 - prevent TL update for
                                  read only members
                        3895203 - status update for level
                                  specific attr
                        3923485 - remove date_format_mask parm
                        4429725 - array out of bounds error
                        4429443 - changes for splitting out
                                  comp dim loader
  Rob Flippo 30-JUN-05  Bug#4355484
                        CALL BUS EVENT WHEN CCC-ORGS
                        LOADED WITH DIM LOADER
                        As long as >0 new members created in a load
                        the loader calls the bus. event
  Rob Flippo 11-AUG-05  Bug#4547868 performance issue -
                        fixed the Attr_assign_update so that the
                        member_id and value_set_id are retrieved
                        in the main attr query, thus allowing
                        the later query on does_attr_exist
                        to use those values directly, rather than join
                        with the base table.
                        Same applies to the actual
                        ATTR update statement - it no longer
                        joins with the base table.
  Rob Flippo 07-OCT-05  Bug#4630742 10G issue -
                        Attr_assign_update fails
                        on does_attr_exist checks:  Modified the fetch
                        so that both the "version" and
                        "non-version" queries
                        are identical for output variables;
                        Bug#4628009 Fixed problem in
                        Post_Cal_Periods where
                        the Cal Period Name and Description table
                        variables had a type of varchar2(30)
                        instead of 150 and 255;
                        Modified Cal period update statement  in
                        build_tl_ro_mbr_upd_stmt for performance
                        issue encountered during regression
                        testing (no bug)
  Rob Flippo 24-JAN-06  Bug#4927869 Change ICX_DATE_FORMAT to
                        FEM_INTF_ATTR_DATE_FORMAT_MASK;
  Rob Flippo 13-MAR-06  Bug#5068022 Need check on member name to ensure that
                        it doesn't already exist.  Added new status
                        'DUPLICATE_NAME' for this situation.  Edit occurs in
                        new_members and tl_update procedures;
  Rob Flippo 04-APR-06  Bug#5117594 Remove unique name check for Customer
                        dimension
Naveen Kumar 26-APR-06  Bug#4736810. Added the call to get_mp_rows_rejected
                        after the call to MP engine for composite dimensions.
 Rob Flippo  28-APR-06  Bug 5174039
                        New_Members and Attr_Assign_Update:  Added validation
                        that calp start_date must be <= calp end date
 Rob Flippo  18-JUL-06  Bug 5024575 Updates for Many-to-many attributes
 Rob Flippo  04-AUG-06  Bug 5060746 Change literals to bind variables wherever possible
 Rob Flippo  12-AUG-06  Bug 5459028 fixed bind variable error for
                        :b_gv_apps_user_id
Naveen Kumar 07-Sep-06  Bug#4429427. Call to FEM_COMP_DIM_MEMBER_LOADER_PKG.Process_Rows
                        through fem_multi_proc_pkg.MASTER altered to comply with Bind Variable Push
                        architecture.
Rob Flippo  15-MAR-07  Bug#5900463 - TL rows for other languages
                        getting deleted when new members are being
                        loaded - modifications to build_calp_delete_stmt
                        to fix this
Rob Flippo  15-MAR-07  Bug#5905501 Need to update source_lang so that
                       translated rows get marked properly
 G Cheng    15-FEM-08  6407625 (FP:6256819). Commented out two IF conditions
                       in get_dimension_info

 *******************************************************************/

-------------------------------
-- Declare package variables --
-------------------------------
   f_set_status  BOOLEAN;

   c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
   c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
   c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
   c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
   c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
   c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

   v_log_level    NUMBER;

   gv_prg_msg      VARCHAR2(2000);
   gv_callstack    VARCHAR2(2000);

-- Global Variables for Post Processing information
   gv_rows_fetched                    NUMBER := 0;
   gv_rows_rejected                   NUMBER := 0;
   gv_rows_loaded                     NUMBER := 0;
   gv_temp_rows_rejected              NUMBER := 0;

   gv_dimgrp_rows_rejected            NUMBER := 0;

   gv_request_id  NUMBER := fnd_global.conc_request_id;
   gv_apps_user_id     NUMBER := FND_GLOBAL.User_Id;
   gv_login_id    NUMBER := FND_GLOBAL.Login_Id;
   gv_pgm_id      NUMBER := FND_GLOBAL.Conc_Program_Id;
   gv_pgm_app_id  NUMBER := FND_GLOBAL.Prog_Appl_ID;
   gv_concurrent_status BOOLEAN;

   -- Engine SQL for Composite Dimension Loader

   g_select_statement  LONG;

/*   -- This stores the details of each component dimensions of Flex Field

   TYPE rt_metadata IS RECORD (
     dimension_id            fem_xdim_dimensions.dimension_id%TYPE,
     member_col              fem_xdim_dimensions.member_col%TYPE,
     member_display_code_col fem_xdim_dimensions.member_display_code_col%TYPE,
     member_b_table_name     fem_xdim_dimensions.member_b_table_name%TYPE,
     value_set_required_flag fem_xdim_dimensions.value_set_required_flag%TYPE,
     dimension_varchar_label VARCHAR2(100),
     member_sql              VARCHAR2(200));

   TYPE tt_metadata IS TABLE OF rt_metadata  INDEX BY BINARY_INTEGER;
     t_metadata      tt_metadata;


   -- This is used to store the values of the Interface(_T) tables
   TYPE display_code_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
    t_global_vs_combo_dc   display_code_type;
    t_fin_elem_dc   display_code_type;
    t_ledger_dc     display_code_type;
    t_cctr_org_dc   display_code_type;
    t_product_dc    display_code_type;
    t_channel_dc    display_code_type;
    t_project_dc    display_code_type;
    t_customer_dc   display_code_type;
    t_task_dc       display_code_type;
    t_user_dim1_dc  display_code_type;
    t_user_dim2_dc  display_code_type;
    t_user_dim3_dc  display_code_type;
    t_user_dim4_dc  display_code_type;
    t_user_dim5_dc  display_code_type;
    t_user_dim6_dc  display_code_type;
    t_user_dim7_dc  display_code_type;
    t_user_dim8_dc  display_code_type;
    t_user_dim9_dc  display_code_type;
    t_user_dim10_dc display_code_type;

    -- This stores the concatenated display code for composite dimension
    t_display_code  display_code_type;

    -- This stores the value of 'UOM_CODE' column for FEM_COST_OBECTS Table.
    t_uom_code      display_code_type;

    --This is used to store the component dimensions of Composite Dimension

    TYPE dim_structure IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
    t_component_dim_dc dim_structure;*/

 --   TYPE varchar2_std_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    t_status        varchar2_150_type;
   -- Execution Mode Clause for all Fetches against the interface tables
   --gv_exec_mode_clause VARCHAR2(100);

   -- Bulk Fetch profile no longer used
   -- Default limit for all BULK Fetches
   --gv_fetch_limit  NUMBER := NVL(FND_PROFILE.Value_Specific(
   --                         'FEM_BULK_FETCH_LIMIT',gv_apps_user_id,null,null),
   --                          c_fetch_limit);

-------------------------------------
-- Array of Source System Codes for the load
-- This is a global table so that the data in it doesn't need
-- to be passed between procedures
-------------------------------------
   tg_src_system_dc                varchar2_150_type;

-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------
-- Wrapper module that calls all Primary modules
PROCEDURE Load_Dimension (
  x_rows_rejected_accum        OUT NOCOPY NUMBER
  ,x_rows_to_load               OUT NOCOPY NUMBER
  ,p_execution_mode             IN       VARCHAR2
  ,p_object_id                 IN       NUMBER
  ,p_object_definition_id       IN       NUMBER
  ,p_dimension_varchar_label    IN       VARCHAR2
  ,p_master_request_id          IN       NUMBER);


-- Primary Modules:  These are procedures called from Load_Dimension
PROCEDURE Engine_Master_Prep ( p_dimension_varchar_label   IN  VARCHAR2
                              ,p_object_definition_id      IN         NUMBER
                              ,p_execution_mode            IN         VARCHAR2
                              ,x_dimension_id               OUT NOCOPY NUMBER
                              ,x_target_b_table             OUT NOCOPY VARCHAR2
                              ,x_target_tl_table            OUT NOCOPY VARCHAR2
                              ,x_target_attr_table          OUT NOCOPY VARCHAR2
                              ,x_source_b_table             OUT NOCOPY VARCHAR2
                              ,x_source_tl_table            OUT NOCOPY VARCHAR2
                              ,x_source_attr_table          OUT NOCOPY VARCHAR2
                              ,x_member_col                 OUT NOCOPY VARCHAR2
                              ,x_member_dc_col              OUT NOCOPY VARCHAR2
                              ,x_member_t_dc_col            OUT NOCOPY VARCHAR2
                              ,x_member_name_col            OUT NOCOPY VARCHAR2
                              ,x_member_t_name_col          OUT NOCOPY VARCHAR2
                              ,x_member_description_col     OUT NOCOPY VARCHAR2
                              ,x_value_set_required_flag    OUT NOCOPY VARCHAR2
                              ,x_user_defined_flag          OUT NOCOPY VARCHAR2
                              ,x_simple_dimension_flag      OUT NOCOPY VARCHAR2
                              ,x_shared_dimension_flag      OUT NOCOPY VARCHAR2
                              ,x_table_handler_name         OUT NOCOPY VARCHAR2
                              ,x_composite_dimension_flag   OUT NOCOPY VARCHAR2
                              ,x_structure_id               OUT NOCOPY NUMBER
                              ,x_exec_mode_clause           OUT NOCOPY VARCHAR2
                              ,x_eng_master_prep_status     OUT NOCOPY VARCHAR2
                              ,x_hier_table_name            OUT NOCOPY VARCHAR2
                              ,x_hier_dimension_flag        OUT NOCOPY VARCHAR2
                              ,x_member_id_method_code      OUT NOCOPY VARCHAR2
                              ,x_rows_to_load               OUT NOCOPY NUMBER
                              ,x_date_format_mask           OUT NOCOPY VARCHAR2
                              );



PROCEDURE Register_process_execution (p_object_id IN NUMBER
                                     ,p_obj_def_id IN NUMBER
                                     ,p_execution_mode IN VARCHAR2
                                     ,x_completion_status OUT NOCOPY VARCHAR2);

PROCEDURE Eng_Master_Post_Proc (p_object_id IN NUMBER
                               ,p_rows_rejected_accum IN NUMBER
                               ,p_rows_to_load IN NUMBER);


PROCEDURE Post_dim_status (p_dimension_id   IN  VARCHAR2
                          ,p_source_system_dc IN VARCHAR2
                          ,p_source_attr_table IN VARCHAR2);

/*--For Composite Dimension Loader
PROCEDURE Process_Rows (x_status OUT NOCOPY NUMBER
                      ,x_message OUT NOCOPY VARCHAR2
                      ,x_rows_processed OUT NOCOPY NUMBER
                      ,x_rows_loaded OUT NOCOPY NUMBER
                      ,x_rows_rejected OUT NOCOPY NUMBER
                      ,p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_slice_id IN VARCHAR2
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_execution_mode IN VARCHAR2
                      ,p_structure_id IN NUMBER);

/*PROCEDURE Pre_Process (x_pre_process_status OUT NOCOPY NUMBER
                       ,p_execution_mode IN VARCHAR2
                       ,p_dimension_varchar_label IN VARCHAR2);

PROCEDURE Get_Display_Codes (p_dimension_varchar_label IN VARCHAR2,
                             p_structure_id            IN NUMBER);

PROCEDURE Metadata_Initialize(p_dimension_varchar_label IN VARCHAR2);*/

PROCEDURE Get_Put_Messages (p_msg_count       IN   NUMBER
                           ,p_msg_data        IN   VARCHAR2);

procedure get_dimension_info (p_dimension_varchar_label    IN         VARCHAR2
                             ,x_dimension_id               OUT NOCOPY NUMBER
                             ,x_target_b_table             OUT NOCOPY VARCHAR2
                             ,x_target_tl_table            OUT NOCOPY VARCHAR2
                             ,x_target_attr_table          OUT NOCOPY VARCHAR2
                             ,x_source_b_table             OUT NOCOPY VARCHAR2
                             ,x_source_tl_table            OUT NOCOPY VARCHAR2
                             ,x_source_attr_table          OUT NOCOPY VARCHAR2
                             ,x_member_col                 OUT NOCOPY VARCHAR2
                             ,x_member_dc_col              OUT NOCOPY VARCHAR2
                             ,x_member_t_dc_col            OUT NOCOPY VARCHAR2
                             ,x_member_name_col            OUT NOCOPY VARCHAR2
                             ,x_member_t_name_col          OUT NOCOPY VARCHAR2
                             ,x_member_description_col     OUT NOCOPY VARCHAR2
                             ,x_value_set_required_flag    OUT NOCOPY VARCHAR2
                             ,x_user_defined_flag          OUT NOCOPY VARCHAR2
                             ,x_simple_dimension_flag      OUT NOCOPY VARCHAR2
                             ,x_shared_dimension_flag      OUT NOCOPY VARCHAR2
                             ,x_hier_table_name            OUT NOCOPY VARCHAR2
                             ,x_hier_dimension_flag        OUT NOCOPY VARCHAR2
                             ,x_member_id_method_code      OUT NOCOPY VARCHAR2
                             ,x_table_handler_name         OUT NOCOPY VARCHAR2
                             ,x_composite_dimension_flag   OUT NOCOPY VARCHAR2
                             ,x_structure_id               OUT NOCOPY NUMBER);


   procedure build_mbr_select_stmt  (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_t_name_col IN VARCHAR2
                                ,p_member_description_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_exists_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2);

procedure build_bad_tl_select_stmt  (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2);

procedure build_tl_ro_mbr_upd_stmt  (p_load_type IN VARCHAR2
                                   ,p_dimension_varchar_label IN VARCHAR2
                                   ,p_dimension_id IN NUMBER
                                   ,p_source_tl_table IN VARCHAR2
                                   ,p_target_b_table IN VARCHAR2
                                   ,p_member_dc_col IN VARCHAR2
                                   ,p_member_t_dc_col IN VARCHAR2
                                   ,p_exec_mode_clause IN VARCHAR2
                                   ,p_shared_dimension_flag IN VARCHAR2
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,x_update_stmt OUT NOCOPY VARCHAR2);


procedure build_bad_lang_upd_stmt  (p_load_type IN VARCHAR2
                                   ,p_dimension_varchar_label IN VARCHAR2
                                   ,p_dimension_id IN NUMBER
                                   ,p_source_tl_table IN VARCHAR2
                                   ,p_exec_mode_clause IN VARCHAR2
                                   ,p_shared_dimension_flag IN VARCHAR2
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,x_update_stmt OUT NOCOPY VARCHAR2);

procedure build_enable_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_update_stmt OUT NOCOPY VARCHAR2);

procedure build_tl_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_name_col IN VARCHAR2
                                ,p_member_description_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_update_stmt OUT NOCOPY VARCHAR2);

procedure build_tl_dupname_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_name_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_calling_mode IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2);

procedure build_does_attr_exist_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_version_flag IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2);

procedure build_does_multattr_exist_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_attr_value_column_name IN VARCHAR2
                                ,p_attr_assign_vs_id IN NUMBER
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2);


   procedure build_get_identical_assgn_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_date_format_mask IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2);

procedure build_attr_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_outer_join_flag IN VARCHAR2
                                ,p_specific_member_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2);

procedure build_attr_lvlspec_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_outer_join_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2);


procedure build_bad_attr_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_bad_attr_select_stmt OUT NOCOPY VARCHAR2);


procedure verify_attr_member   (p_attribute_varchar_label IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_attr_member_dc IN VARCHAR2
                                ,p_attr_member_vs_dc IN VARCHAR2
                                ,x_attr_success OUT NOCOPY VARCHAR2
                                ,x_member OUT NOCOPY VARCHAR2);


procedure build_member_exists_stmt (p_member_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_member_exists_stmt OUT NOCOPY VARCHAR2);

procedure build_bad_new_mbrs_stmt (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_bad_member_select_stmt OUT NOCOPY VARCHAR2);

procedure build_bad_attr_vers_stmt (p_dimension_varchar_label IN VARCHAR2
                                   ,p_source_attr_table IN VARCHAR2
                                   ,p_shared_dimension_flag IN VARCHAR2
                                   ,p_exec_mode_clause IN VARCHAR2
                                   ,x_bad_attr_vers_select_stmt OUT NOCOPY VARCHAR2);

procedure get_attr_version (p_dimension_varchar_label IN VARCHAR2
                           ,p_attribute_varchar_label IN VARCHAR2
                           ,p_version_display_code IN VARCHAR2
                           ,x_version_id OUT NOCOPY NUMBER);

procedure build_insert_member_stmt (p_table_handler_name IN VARCHAR2
                                   ,p_dimension_id IN NUMBER
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,p_hier_dimension_flag IN VARCHAR2
                                   ,p_simple_dimension_flag IN VARCHAR2
                                   ,p_member_id_method_code VARCHAR2
                                   ,p_member_col IN VARCHAR2
                                   ,p_member_dc_col IN VARCHAR
                                   ,p_member_name_col IN VARCHAR2
                                   ,x_insert_member_stmt OUT NOCOPY VARCHAR2);

procedure build_insert_attr_stmt (p_target_attr_table IN VARCHAR2
                                 ,p_target_b_table IN VARCHAR2
                                 ,p_member_col IN VARCHAR2
                                 ,p_member_dc_col IN VARCHAR2
                                 ,p_value_set_required_flag IN VARCHAR2
                                 ,x_insert_attr_stmt OUT NOCOPY VARCHAR2);


procedure build_status_update_stmt (p_source_table IN VARCHAR2
                                   ,x_update_status_stmt OUT NOCOPY VARCHAR2);

procedure build_dep_status_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                       ,p_source_table IN VARCHAR2
                                       ,p_member_t_dc_col IN VARCHAR2
                                       ,p_value_set_required_flag IN VARCHAR2
                                       ,x_update_status_stmt OUT NOCOPY VARCHAR2);

procedure build_attrlab_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_attr_table IN VARCHAR2
                                      ,p_shared_dimension_flag IN VARCHAR2
                                      ,p_exec_mode_clause IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2);

procedure build_not_user_label_upd_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_attr_table IN VARCHAR2
                                      ,p_shared_dimension_flag IN VARCHAR2
                                      ,p_exec_mode_clause IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2);

procedure build_delete_stmt (p_source_table IN VARCHAR2
                            ,x_delete_stmt OUT NOCOPY VARCHAR2);

procedure build_special_delete_stmt (p_source_table IN VARCHAR2
                                    ,x_delete_stmt OUT NOCOPY VARCHAR2);

procedure build_remain_mbr_select_stmt  (p_load_type IN VARCHAR2
                                        ,p_dimension_id IN NUMBER
                                        ,p_dimension_varchar_label IN VARCHAR2
                                        ,p_shared_dimension_flag IN VARCHAR2
                                        ,p_value_set_required_flag IN VARCHAR2
                                        ,p_hier_dimension_flag IN VARCHAR2
                                        ,p_source_b_table IN VARCHAR2
                                        ,p_target_b_table IN VARCHAR2
                                        ,p_member_col IN VARCHAR2
                                        ,p_member_dc_col IN VARCHAR2
                                        ,p_member_t_dc_col IN VARCHAR2
                                        ,p_exec_mode_clause IN VARCHAR2
                                        ,x_remain_mbr_select_stmt OUT NOCOPY VARCHAR2);

procedure build_dimgrp_update_stmt (p_target_b_table IN VARCHAR2
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,p_member_dc_col IN VARCHAR2
                                   ,x_update_stmt OUT NOCOPY VARCHAR2);

procedure build_attr_update_stmt (p_target_attr_table IN VARCHAR2
                                 ,p_target_b_table IN VARCHAR2
                                 ,p_member_dc_col IN VARCHAR2
                                 ,p_member_col IN VARCHAR2
                                 ,p_value_set_required_flag IN VARCHAR2
                                 ,x_update_stmt OUT NOCOPY VARCHAR2);

procedure build_src_sys_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                    ,p_source_attr_table IN VARCHAR2
                                    ,p_shared_dimension_flag IN VARCHAR2
                                    ,x_src_sys_select_stmt OUT NOCOPY VARCHAR2);

procedure get_mp_rows_rejected (x_rows_rejected OUT NOCOPY NUMBER
                               ,x_rows_loaded OUT NOCOPY NUMBER);

procedure build_seq_enf_hiercount_stmt (p_value_set_required_flag IN VARCHAR2
                                 ,p_hier_table_name IN VARCHAR2
                                 ,x_select_stmt OUT NOCOPY VARCHAR2);

procedure calp_date_overlap_check(x_rows_rejected OUT NOCOPY NUMBER
                                 ,p_operation_mode IN VARCHAR2);

procedure build_calp_interim_insert_stmt (x_insert_calp_stmt OUT NOCOPY VARCHAR2
                                         ,x_insert_calp_attr_stmt OUT NOCOPY VARCHAR2);

procedure build_calp_status_update_stmt (p_operation_mode IN VARCHAR2
                                        ,p_source_table IN VARCHAR2
                                        ,x_update_status_stmt OUT NOCOPY VARCHAR2);

procedure build_calp_delete_stmt (p_source_table IN VARCHAR2
                                 ,p_operation_mode IN VARCHAR2
                                 ,x_calp_delete_stmt OUT NOCOPY VARCHAR2);


procedure truncate_calp_interim;

procedure get_attr_assign_calp          (x_cal_period_id OUT NOCOPY VARCHAR2
                                        ,x_record_status OUT NOCOPY VARCHAR2
                                        ,p_calendar_dc IN VARCHAR2
                                        ,p_dimension_group_dc IN VARCHAR2
                                        ,p_end_date IN DATE
                                        ,p_cal_period_number IN NUMBER);


procedure raise_member_bus_event (p_dimension_varchar_label IN VARCHAR2);

-----------------------------------------------------------------------------
--  Package bodies for functions/procedures
-----------------------------------------------------------------------------

-------------------------------------------------------------
--  Procedure for getting number of rejected rows from the MP sub-processes
--  Bug#4355484 also gets the number of rows loaded so that we can figure
--  out if we created new members or not
-------------------------------------------------------------
procedure get_mp_rows_rejected (x_rows_rejected OUT NOCOPY NUMBER
                               ,x_rows_loaded OUT NOCOPY NUMBER) IS

BEGIN


   SELECT NVL(SUM(rows_rejected),0), NVL(SUM(rows_loaded),0)
   INTO x_rows_rejected, x_rows_loaded
   FROM fem_mp_process_ctl_t
   WHERE req_id = gv_request_id;

END get_mp_rows_rejected;
-------------------------------------------------------------
--  Procedure for getting messages off the stack
-------------------------------------------------------------
PROCEDURE Get_Put_Messages (
   p_msg_count       IN   NUMBER,
   p_msg_data        IN   VARCHAR2
)
IS

v_msg_count        NUMBER;
v_msg_data         VARCHAR2(4000);
v_msg_out          NUMBER;
v_message          VARCHAR2(4000);

v_block  CONSTANT  VARCHAR2(80) :=
   'fem.plsql.fem_dim_member_loader_pkg.get_put_messages';

BEGIN

FEM_ENGINES_PKG.TECH_MESSAGE
 (p_severity => c_log_level_2,
  p_module => v_block||'.msg_count',
  p_msg_text => p_msg_count);

v_msg_data := p_msg_data;

IF (p_msg_count = 1)
THEN
   FND_MESSAGE.Set_Encoded(v_msg_data);
   v_message := FND_MESSAGE.Get;

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => v_message);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_2,
     p_module => v_block||'.msg_data',
     p_msg_text => v_message);

ELSIF (p_msg_count > 1)
THEN
   FOR i IN 1..p_msg_count
   LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded => c_false,
      p_data => v_message,
      p_msg_index_out => v_msg_out);

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.msg_data',
        p_msg_text => v_message);

   END LOOP;
END IF;

   FND_MSG_PUB.Initialize;

END Get_Put_Messages;


/*===========================================================================+
 | PROCEDURE
 |              Raise_member_bus_event
 |
 | DESCRIPTION
 |                 Raises a business event for when a new member is
 |                 created or updated
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |   Rob Flippo   25-MAY-05  Created
 +===========================================================================*/

procedure raise_member_bus_event (p_dimension_varchar_label IN VARCHAR2) IS

    v_param_list                wf_parameter_list_t;
    v_event_sequence            NUMBER;
    c_proc_name VARCHAR2(30) := 'Raise_bus_event';
BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


   SELECT FEM_DHM_METADATA_OPS_KEY_S.nextval
   INTO v_event_sequence
   FROM dual;


   WF_EVENT.addparametertolist
     (p_name          => 'DIMENSION_VARCHAR_LABEL',
      p_value         => p_dimension_varchar_label,
      p_parameterlist => v_param_list);


 WF_Event.Raise( p_event_name => 'oracle.apps.fem.dhm.dimension.event'
                ,p_event_key  => v_event_sequence
                ,p_parameters => v_param_list);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


END raise_member_bus_event;


/*===========================================================================+
 | PROCEDURE
 |              Engine_Master_Prep
 |
 | DESCRIPTION
 |                 Called from Load Dimension
 |                 Validates input parameters and gets dimension metadata
 |                 for the run
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |    Added SQL verification on having multiple versions for the dimension
 |    marked as "Default = Y".  Since this data error causes unexpected behavior
 |    in the loader, the loader throws an exception for this and requires the
 |    user to clean up the versions for that dimension before proceeding with
 |    the load
 |
 | MODIFICATION HISTORY
 |  Rob Flippo  27-FEB-04  Created
 |  Rob Flippo  21-SEP-04  Bug#3900960  Add mesaging for when 0 rows found
 |                         for Snapshot loading
 |  Rob Flippo  16-MAR-05  Bug#4244082 Added x_hier_table_name
 |  Rob Flippo  24-JAN-06  Bug#4927869 - Changed ICX Date format to
 |                         FEM_INTF_ATTR_DATE_FORMAT_MASK;
 +===========================================================================*/

PROCEDURE Engine_Master_Prep ( p_dimension_varchar_label   IN  VARCHAR2
                              ,p_object_definition_id      IN         NUMBER
                              ,p_execution_mode            IN         VARCHAR2
                              ,x_dimension_id               OUT NOCOPY NUMBER
                              ,x_target_b_table             OUT NOCOPY VARCHAR2
                              ,x_target_tl_table            OUT NOCOPY VARCHAR2
                              ,x_target_attr_table          OUT NOCOPY VARCHAR2
                              ,x_source_b_table             OUT NOCOPY VARCHAR2
                              ,x_source_tl_table            OUT NOCOPY VARCHAR2
                              ,x_source_attr_table          OUT NOCOPY VARCHAR2
                              ,x_member_col                 OUT NOCOPY VARCHAR2
                              ,x_member_dc_col              OUT NOCOPY VARCHAR2
                              ,x_member_t_dc_col            OUT NOCOPY VARCHAR2
                              ,x_member_name_col            OUT NOCOPY VARCHAR2
                              ,x_member_t_name_col          OUT NOCOPY VARCHAR2
                              ,x_member_description_col     OUT NOCOPY VARCHAR2
                              ,x_value_set_required_flag    OUT NOCOPY VARCHAR2
                              ,x_user_defined_flag          OUT NOCOPY VARCHAR2
                              ,x_simple_dimension_flag      OUT NOCOPY VARCHAR2
                              ,x_shared_dimension_flag      OUT NOCOPY VARCHAR2
                              ,x_table_handler_name         OUT NOCOPY VARCHAR2
                              ,x_composite_dimension_flag   OUT NOCOPY VARCHAR2
                              ,x_structure_id               OUT NOCOPY NUMBER
                              ,x_exec_mode_clause           OUT NOCOPY VARCHAR2
                              ,x_eng_master_prep_status     OUT NOCOPY VARCHAR2
                              ,x_hier_table_name            OUT NOCOPY VARCHAR2
                              ,x_hier_dimension_flag        OUT NOCOPY VARCHAR2
                              ,x_member_id_method_code      OUT NOCOPY VARCHAR2
                              ,x_rows_to_load               OUT NOCOPY NUMBER
                              ,x_date_format_mask           OUT NOCOPY VARCHAR2
                              )
IS

-- Variable for validating if the Date Format Mask is valid
   v_date_format_result              DATE;
   c_proc_name VARCHAR2(30) := 'Engine_Maser_Prep';
   v_default_version_count NUMBER;
   v_temp_attribute VARCHAR2(30);  -- temporary holding variable for attribute
                                   -- when there is more than 1 default version
                                   -- defined for it
   v_sql_stmt          VARCHAR2(4000);  -- variable for holding NDS statements
   v_dim_label_where_cond VARCHAR2(1000);

   -- for testing the date format
   v_test_date DATE;

   -- variables for counting rows in the source tables
   v_source_b_count    NUMBER :=0;
   v_source_tl_count   NUMBER :=0;
   v_source_attr_count NUMBER :=0;
   v_source_dimgrpb_count NUMBER :=0;
   v_source_dimgrptl_count NUMBER :=0;
   v_obj_def_display_name VARCHAR2(150); -- translatable name for the load operation

   CURSOR c_attr_vers (p_dimension_id NUMBER) IS
      SELECT attribute_id, attribute_varchar_label
      FROM fem_dim_attributes_b
      WHERE dimension_id = p_dimension_id;

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

/**************************************************************
RCF 5/31/2005 Bug#3923485  Commenting out date_format_mask validation
              since we are going to use the ICX: Date Format Mask profile option
   BEGIN
      IF p_date_format_mask IS NULL THEN
         RAISE e_invalid_date_mask;
      END IF;
      v_date_format_result := to_date((to_char(sysdate,p_date_format_mask)),p_date_format_mask);
   EXCEPTION
      WHEN e_invalid_date_result THEN
         RAISE e_invalid_date_mask;
      WHEN e_invalid_date_month THEN
         RAISE e_invalid_date_mask;
   END;
***************************************************************/

   ------------------------------------------------------------------------------
   -- Bug#4927869 Date format mask comes from FEM_INTF_ATTR_DATE_FORMAT_MASK profile option
   ------------------------------------------------------------------------------
   x_date_format_mask:= FND_PROFILE.Value_Specific(
                        'FEM_INTF_ATTR_DATE_FORMAT_MASK',null,null,null);

   BEGIN
      IF x_date_format_mask IS NULL THEN
         RAISE e_invalid_date_mask;
      ELSE
         v_test_date := to_date((to_char(sysdate,x_date_format_mask)),x_date_format_mask);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE e_invalid_date_mask;
   END;


   ------------------------------------------------------------------------------
   -- Validate the Dimension input parameter and get the source and target table
   -- names for the members and translatable names/descriptions
   ------------------------------------------------------------------------------

   get_dimension_info (p_dimension_varchar_label
                      ,x_dimension_id
                      ,x_target_b_table
                      ,x_target_tl_table
                      ,x_target_attr_table
                      ,x_source_b_table
                      ,x_source_tl_table
                      ,x_source_attr_table
                      ,x_member_col
                      ,x_member_dc_col
                      ,x_member_t_dc_col
                      ,x_member_name_col
                      ,x_member_t_name_col
                      ,x_member_description_col
                      ,x_value_set_required_flag
                      ,x_user_defined_flag
                      ,x_simple_dimension_flag
                      ,x_shared_dimension_flag
                      ,x_hier_table_name
                      ,x_hier_dimension_flag
                      ,x_member_id_method_code
                      ,x_table_handler_name
                      ,x_composite_dimension_flag
                      ,x_structure_id);

   -- Setting the Execution Mode clause for Selects against the interface tables
   IF p_execution_mode = 'S' THEN
      x_exec_mode_clause := ' IN (''LOAD'')';
   ELSE
      x_exec_mode_clause := ' LIKE ''%''';
   END IF; -- execution mode where condition

   -- Begin comp_dim_loader code
   IF x_composite_dimension_flag = 'N' THEN

   -- Verification that only one default version exists
   -- for each attribute of the dimension being processed
   FOR attr IN c_attr_vers (x_dimension_id) LOOP
      SELECT count(*)
      INTO v_default_version_count
      FROM fem_dim_attr_versions_b
      WHERE attribute_id = attr.attribute_id
      AND default_version_flag='Y';

      IF (v_default_version_count > 1) THEN
         v_temp_attribute := attr.attribute_varchar_label;
         RAISE e_mult_default_version;
      END IF;
   END LOOP;  -- c_attr_vers cursor

   -- Bug#3900960  Raise exception when Snapshot load and 0 rows found
   -- in all interface tables
   IF x_shared_dimension_flag = 'Y' and x_value_set_required_flag = 'N' THEN
      v_dim_label_where_cond :=  ' AND dimension_varchar_label = '''||p_dimension_varchar_label||'''';
   ELSE v_dim_label_where_cond := '';
   END IF;
 END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Engine_Master_Prep',
        p_msg_text => 'Check for Source rows');

      v_sql_stmt := 'SELECT count(*) FROM '||x_source_b_table||
                    ' WHERE status '||x_exec_mode_clause||
                    v_dim_label_where_cond;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Engine_Master_Prep'||'.source_b',
        p_msg_text => v_sql_stmt);
      execute immediate v_sql_stmt
         into v_source_b_count;

   IF x_composite_dimension_flag = 'N' then --

      v_sql_stmt := 'SELECT count(*) FROM '||x_source_tl_table||
                    ' WHERE status '||x_exec_mode_clause||
                    v_dim_label_where_cond;
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Engine_Master_Prep'||'.source_tl',
        p_msg_text => v_sql_stmt);
      execute immediate v_sql_stmt
         into v_source_tl_count;


      IF x_simple_dimension_flag ='N' THEN
         v_sql_stmt := 'SELECT count(*) FROM '||x_source_attr_table||
                    ' WHERE status '||x_exec_mode_clause||
                    v_dim_label_where_cond;
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Engine_Master_Prep'||'.source_attr',
        p_msg_text => v_sql_stmt);
         execute immediate v_sql_stmt
            into v_source_attr_count;
      END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.after attr count',null);

      IF x_hier_dimension_flag = 'Y' THEN
         v_sql_stmt := 'SELECT count(*) FROM fem_dimension_grps_b_t '||
                       ' WHERE dimension_varchar_label ='||
                       ''''||p_dimension_varchar_label||''''||
                       ' AND status '||x_exec_mode_clause;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => c_block||'.'||'Engine_Master_Prep'||'.dimgrp_b',
           p_msg_text => v_sql_stmt);
         execute immediate v_sql_stmt
            into v_source_dimgrpb_count;
         v_sql_stmt := 'SELECT count(*) FROM fem_dimension_grps_tl_t '||
                       'WHERE dimension_varchar_label ='||
                       ''''||p_dimension_varchar_label||''''||
                       ' AND status '||x_exec_mode_clause;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module => c_block||'.'||'Engine_Master_Prep'||'.dimgrp_tl',
           p_msg_text => v_sql_stmt);

         execute immediate v_sql_stmt
            into v_source_dimgrptl_count;
      END IF;

      -- If no rows exist in all source tables, quit with an exception
      IF --p_execution_mode = 'S' AND
         v_source_b_count = 0 AND v_source_tl_count = 0 AND
         v_source_attr_count = 0 AND v_source_dimgrpb_count = 0 AND
         v_source_dimgrptl_count = 0 THEN
         RAISE e_no_rows_to_load;
      END IF;
   ELSE

       IF --p_execution_mode = 'S' AND
         v_source_b_count = 0 THEN

         RAISE e_no_rows_to_load;
      END IF;

       x_rows_to_load := v_source_b_count;
   END IF;


     x_rows_to_load := v_source_b_count + v_source_tl_count + v_source_attr_count
                       + v_source_dimgrpb_count + v_source_dimgrptl_count;

   x_eng_master_prep_status := 'SUCCESS';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN e_no_rows_to_load THEN

         SELECT display_name
         INTO v_obj_def_display_name
         FROM fem_object_definition_vl
         WHERE object_definition_id = p_object_definition_id;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_NO_ROWS_TO_LOAD
          ,P_TOKEN1 => 'OPERATION'
          ,P_VALUE1 => v_obj_def_display_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_NO_ROWS_TO_LOAD
          ,P_TOKEN1 => 'OPERATION'
          ,P_VALUE1 => v_obj_def_display_name);

         x_eng_master_prep_status := 'ERROR';

      WHEN e_invalid_date_mask THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_DATE_MASK);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_DATE_MASK);

         x_eng_master_prep_status := 'ERROR';


      WHEN e_dimension_not_found THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_FOUND);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_FOUND);

         x_eng_master_prep_status := 'ERROR';

      WHEN e_invalid_simple_dim THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_SIMPLE_DIM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_SIMPLE_DIM);

         x_eng_master_prep_status := 'ERROR';

      WHEN e_mult_default_version THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_MULT_DEFAULT_VERSION);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_MULT_DEFAULT_VERSION
          ,P_TOKEN1 => 'ATTRIBUTE_VARCHAR_LABEL'
          ,P_VALUE1 => v_temp_attribute);

         x_eng_master_prep_status := 'ERROR';


END Engine_Master_Prep;

/*===========================================================================+
 | PROCEDURE
 |              Register_process_execution
 |
 | DESCRIPTION
 |    Registers the concurrent request in FEM_PL_REQUESTS, registers
 |    the object execution in FEM_PL_OBJECT_EXECUTIION, obtaining an
 |    FEM "execution lock, and performs other FEM process initialization
 |    steps.
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |       x_completion_code returns 0 for success, 2 for failure.
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   27-FEB-04  Created
 |
 +===========================================================================*/

PROCEDURE Register_process_execution (p_object_id IN NUMBER
                                     ,p_obj_def_id IN NUMBER
                                     ,p_execution_mode IN VARCHAR2
                                     ,x_completion_status OUT NOCOPY VARCHAR2)
IS

      v_API_return_status  VARCHAR2(30);
      v_exec_state       VARCHAR2(30); -- NORMAL, RESTART, RERUN
      v_num_msg          NUMBER;
      v_stmt_type        fem_pl_tables.statement_type%TYPE;
      i                  PLS_INTEGER;
      v_msg_count        NUMBER;
      v_msg_data         VARCHAR2(4000);
      v_previous_request_id NUMBER;

      Exec_Lock_Exists   EXCEPTION;
      e_pl_register_req_failed  EXCEPTION;
      e_exec_lock_failed  EXCEPTION;


   BEGIN
      x_completion_status := 'SUCCESS';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_2,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'BEGIN');

   -- Call the FEM_PL_PKG.Register_Request API procedure to register
   -- the concurrent request in FEM_PL_REQUESTS.

      FEM_PL_PKG.Register_Request
        (P_API_VERSION            => c_api_version,
         P_COMMIT                 => c_false,
         P_CAL_PERIOD_ID          => null,
         P_LEDGER_ID              => null,
         P_DATASET_IO_OBJ_DEF_ID  => null,
         P_OUTPUT_DATASET_CODE    => null,
         P_SOURCE_SYSTEM_CODE     => null,
         P_EFFECTIVE_DATE         => null,
         P_RULE_SET_OBJ_DEF_ID    => null,
         P_RULE_SET_NAME          => null,
         P_REQUEST_ID             => gv_request_id,
         P_USER_ID                => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN      => gv_login_id,
         P_PROGRAM_ID             => gv_pgm_id,
         P_PROGRAM_LOGIN_ID       => gv_login_id,
         P_PROGRAM_APPLICATION_ID => gv_pgm_app_id,
         P_EXEC_MODE_CODE         => p_execution_mode,
         P_DIMENSION_ID           => null,
         P_TABLE_NAME             => null,
         P_HIERARCHY_NAME         => null,
         X_MSG_COUNT              => v_msg_count,
         X_MSG_DATA               => v_msg_data,
         X_RETURN_STATUS          => v_API_return_status);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_request.v_api_return_status',
            p_msg_text => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
         RAISE e_pl_register_req_failed;
      END IF;
   -- Check for process locks and process overlaps and register
   -- the execution in FEM_PL_OBJECT_EXECUTIONS, obtaining an execution lock.

      FEM_PL_PKG.Register_Object_Execution
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => gv_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_EXEC_OBJECT_DEFINITION_ID => p_obj_def_id,
         P_USER_ID                   => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => gv_login_id,
         P_EXEC_MODE_CODE            => p_execution_mode,
         X_EXEC_STATE                => v_exec_state,
         X_PREV_REQUEST_ID           => v_previous_request_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;

      FEM_PL_PKG.Register_Object_Def
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => gv_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_OBJECT_DEFINITION_ID      => p_obj_def_id,
         P_USER_ID                   => gv_apps_user_id,
         P_LAST_UPDATE_LOGIN         => gv_login_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;

   -- Successful completion

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'END');


      COMMIT;

   EXCEPTION
      WHEN e_pl_register_req_failed THEN
         -- get errors from the stack
         Get_Put_Messages (
            p_msg_count => v_msg_count,
            p_msg_data => v_msg_data);

         -- display user message
         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => G_PL_REG_REQUEST_ERR);

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => 'FEM_DIM_MBR_LDR_OBJEXEC');

         x_completion_status := 'ERROR';

         RAISE e_pl_registration_failed;

      WHEN e_exec_lock_failed THEN
         -- get errors from the stack
         -- Bug#3920599 - remove extraneous messages
         --   Get_Put_Messages (
         --     p_msg_count => v_msg_count,
         --      p_msg_data => v_msg_data);

         --FEM_ENGINES_PKG.USER_MESSAGE
         --(P_APP_NAME => c_fem
         --,P_MSG_NAME => G_PL_OBJ_EXEC_LOCK_ERR);

         FEM_ENGINES_PKG.USER_MESSAGE
          (P_APP_NAME => c_fem
          ,P_MSG_NAME => 'FEM_DIM_MBR_LDR_OBJEXEC');

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_process_execution',
            p_msg_text => 'raising Exec_Lock_failed');

         FEM_PL_PKG.Unregister_Request(
            P_API_VERSION               => c_api_version,
            P_COMMIT                    => c_true,
            P_REQUEST_ID                => gv_request_id,
            X_MSG_COUNT                 => v_msg_count,
            X_MSG_DATA                  => v_msg_data,
            X_RETURN_STATUS             => v_API_return_status);
      -- Technical messages have already been logged by the API;

         x_completion_status := 'ERROR';

         RAISE e_pl_registration_failed;

   END Register_Process_Execution;


/*===========================================================================+
 | PROCEDURE
 |              Eng_Master_Post_Proc
 |
 | DESCRIPTION
 |    Updates the PL data model with rows rejected and rows loaded
 |    Registers the Dimension Load Status
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |

 | MODIFICATION HISTORY
 |    Rob Flippo   4-MAR-04  Created
 |    Rob Flippo   16-SEP-2004  Removing the error row count message
 |                             Since it is impossible to get an accrurate count
 |                             of error rows given that a number of status updates
 |                             are bulk
 |
 +===========================================================================*/

PROCEDURE Eng_Master_Post_Proc (p_object_id IN NUMBER
                               ,p_rows_rejected_accum IN NUMBER
                               ,p_rows_to_load IN NUMBER)
IS

   v_execution_status VARCHAR2(30);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(4000);
   v_API_return_status VARCHAR2(30);
   --v_rows_rejected NUMBER;
   e_post_process EXCEPTION;
   v_rows_loaded NUMBER;

BEGIN
   v_rows_loaded := p_rows_to_load - p_rows_rejected_accum;

   IF p_rows_rejected_accum > 0 THEN
      v_execution_status := 'ERROR_RERUN';
      gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
   ELSE v_execution_status := 'SUCCESS';
        gv_concurrent_status := fnd_concurrent.set_completion_status('NORMAL',null);
   END IF;
   /*****************************************
   -- Clean out the data slice table
   FEM_MULTI_PROC_PKG.Delete_Data_Slices(
      p_req_id => gv_request_id);
   ******************************************/

   ------------------------------------
   -- Update Object Execution Errors --
   ------------------------------------
   FEM_PL_PKG.Update_Obj_Exec_Errors(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => p_object_id,
     P_ERRORS_REPORTED           => p_rows_rejected_accum,
     P_ERRORS_REPROCESSED        => 0,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   ----------------------------------
   -- Update Number of Rows Loaded --
   ----------------------------------

   ------------------------------------
   -- Update Object Execution Status --
   ------------------------------------

   FEM_PL_PKG.Update_Obj_Exec_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_OBJECT_ID                 => p_object_id,
     P_EXEC_STATUS_CODE          => v_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   ---------------------------
   -- Update Request Status --
   ---------------------------
   FEM_PL_PKG.Update_Request_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => gv_request_id,
     P_EXEC_STATUS_CODE          => v_execution_status,
     P_USER_ID                   => gv_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   -------------------
   -- Post Messages --
   -------------------

   FEM_ENGINES_PKG.USER_MESSAGE
    (P_APP_NAME => c_fem
    ,P_MSG_NAME => 'FEM_SD_LDR_PROCESS_SUMMARY'
    ,P_TOKEN1 => 'LOADNUM'
    ,P_VALUE1 => v_rows_loaded
    ,P_TOKEN2 => 'REJECTNUM'
    ,P_VALUE2 => p_rows_rejected_accum);

   IF v_execution_status = 'ERROR_RERUN' THEN

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => 'FEM_EXEC_RERUN');

   ELSE
      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => 'FEM_EXEC_SUCCESS');
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_3,
     p_module => c_block||'.'||'Eng_Master_Post_Proc',
     p_msg_text => 'End');

EXCEPTION
   WHEN e_post_process THEN
      -- get messages from the stack
      Get_Put_Messages (
         p_msg_count => v_msg_count,
         p_msg_data => v_msg_data);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Eng_Master_Post_Proc',
        p_msg_text => 'Post Process failed');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_EXT_LDR_POST_PROC_ERR);


   WHEN OTHERS THEN
      -- get messages from the stack
      Get_Put_Messages (
         p_msg_count => v_msg_count,
         p_msg_data => v_msg_data);

      gv_prg_msg := sqlerrm;
      gv_callstack := dbms_utility.format_call_stack;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||'Eng_Master_Post_Proc.Unexpected Exception'
       ,p_msg_text => gv_prg_msg);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||'Eng_Master_Post_Proc.Unexpected Exception'
       ,p_msg_text => gv_callstack);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_text => gv_prg_msg);

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_EXT_LDR_POST_PROC_ERR);


END Eng_Master_Post_Proc;


/*===========================================================================+
 | PROCEDURE
 |              Pre_Validation
 |
 | DESCRIPTION
 |     New Dimension Members without corresponding TL records
 |     This step processes members that do not yet exist in FEM
 |     but that do not have at least one TL record in the _TL_T interface table.
 |     These groups are "bad" so we will update their status to MISSING_NAME
 |
 |     This step also updates the records in the TL_T table where the LANGUAGE
 |     is not installed.
 |
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |   1.	Update Status of all "new" members missing TL_T record with 'MISSING_NAME'
 |   2.	(Simple Dim = 'N') Update Status of attribute assignments where the member
 |      doesn't exist in FEM and also is not in the join of _B_T/_TL_T with 'INVALID_MEMBER'
 |   3.	Special Status update for CAL PERIOD attribute assignment records
 |      with invalid CALENDAR_DISPLAY_CODE or DIMENSION_GROUP_DISPLAY_CODE.
 |      Status is 'INVALID_MEMBER'
 |   4.	(Simple Dim = 'N') Update status of all attribute assignment records where the
 |      VERSION_DISPLAY_CODE doesn't exist.  Status is 'INVALID_VERSION'
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   22-MAR-04  Created
 |    Rob Flippo   17-SEP-04  Modified to add update on the _TL_T tables where
 |                            the LANGUAGE is not installed
 |
 +===========================================================================*/

PROCEDURE Pre_Validation (p_eng_sql IN VARCHAR2
                         ,p_data_slc IN VARCHAR2
                         ,p_proc_num IN NUMBER
                         ,p_partition_code           IN  NUMBER
                         ,p_fetch_limit IN NUMBER
                         ,p_load_type IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2
                         ,p_dimension_id IN NUMBER
                         ,p_source_b_table IN VARCHAR2
                         ,p_source_tl_table IN VARCHAR2
                         ,p_source_attr_table IN VARCHAR2
                         ,p_target_b_table IN VARCHAR2
                         ,p_member_t_dc_col IN VARCHAR2
                         ,p_member_dc_col IN VARCHAR2
                         ,p_value_set_required_flag IN VARCHAR2
                         ,p_simple_dimension_flag IN VARCHAR2
                         ,p_shared_dimension_flag IN VARCHAR2
                         ,p_exec_mode_clause IN VARCHAR2
                         ,p_master_request_id IN NUMBER)


IS
-- Constants
   c_proc_name                      VARCHAR2(30) := 'Pre_Validation';
-- Dynamic SQL statement variables
   x_bad_mbr_select_stmt             VARCHAR2(4000);
   x_update_mbr_status_stmt          VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_mbr_last_row                    NUMBER;
   v_rows_rejected                   NUMBER :=0;
   v_temp_rows_rejected              NUMBER :=0;

-- Other variables
   v_fetch_limit                     NUMBER;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   t_rowid                           rowid_type;
   t_b_status                        varchar2_std_type;

---------------------
-- Declare cursors --
---------------------
   cv_get_bad_mbr        cv_curs;

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


   --x_status := 0; -- initialize status of the Pre_Validation procedure
   --x_message := 'COMPLETE:NORMAL';


   build_bad_new_mbrs_stmt (p_load_type
                           ,p_dimension_varchar_label
                           ,p_source_b_table
                           ,p_source_tl_table
                           ,p_target_b_table
                           ,p_member_t_dc_col
                           ,p_member_dc_col
                           ,p_value_set_required_flag
                           ,p_shared_dimension_flag
                           ,p_exec_mode_clause
                           ,x_bad_mbr_select_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_bad_mbr_select_stmt := REPLACE(x_bad_mbr_select_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_bad_mbr_select_stmt := REPLACE(x_bad_mbr_select_stmt,'{{data_slice}}','1=1');
   END IF;

   -- set the local fetch limit variable based on the parameter
   -- this will be null for Dimension Group loads
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.bad_new_mbrs_select_stmt',x_bad_mbr_select_stmt);

   build_status_update_stmt (p_source_b_table
                            ,x_update_mbr_status_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.update_mbr_status_stmt '
    ,x_update_mbr_status_stmt);

   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop
LOOP

   IF p_load_type <> ('DIMENSION_GROUP') THEN

      FEM_Multi_Proc_Pkg.Get_Data_Slice(
        x_slc_id => v_slc_id,
        x_slc_val1 => v_slc_val,
        x_slc_val2 => v_slc_val2,
        x_slc_val3 => v_slc_val3,
        x_slc_val4 => v_slc_val4,
        x_num_vals  => v_num_vals,
        x_part_name => v_part_name,
        p_req_id => p_master_request_id,
        p_proc_num => p_proc_num);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
       ,v_slc_val);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
       ,v_slc_val2);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
       ,v_slc_val3);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
       ,v_slc_val4);


      EXIT WHEN (v_slc_id IS NULL);
   ELSE
      EXIT WHEN (v_loop_counter > 0);
      v_loop_counter := v_loop_counter + 1;
   END IF;

   IF p_load_type <> ('DIMENSION_GROUP') THEN

      OPEN cv_get_bad_mbr FOR x_bad_mbr_select_stmt USING v_slc_val, v_slc_val2;
   ELSE
      OPEN cv_get_bad_mbr FOR x_bad_mbr_select_stmt;
   END IF;

   LOOP
      ------------------------------------------------------------------
      -- Bulk Collect Rows from the source _B_T table missing TL_T name
      -- where the member does not already exist in FEM
      -- Using Dynamic SELECT Statement
      ------------------------------------------------------------------

      FETCH cv_get_bad_mbr BULK COLLECT INTO
             t_rowid
            ,t_b_status
      LIMIT v_fetch_limit;

      ----------------------------------------------
      -- EXIT Fetch LOOP If No Rows are Retrieved --
      ----------------------------------------------

      v_mbr_last_row := t_rowid.LAST;

      FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_1,c_block||'.'||c_proc_name||'.v_mbr_last_row'
      ,v_mbr_last_row);

      IF (v_mbr_last_row IS NULL)
      THEN
         EXIT;
      END IF;

      ----------------------------------------------------------
      -- Update Status of Bad Member Collection
      ----------------------------------------------------------
      FORALL i IN 1..v_mbr_last_row
         EXECUTE IMMEDIATE x_update_mbr_status_stmt
         USING t_b_status(i)
              ,t_rowid(i)
              ,t_b_status(i);

      COMMIT;

      ----------------------------------------------------------
      -- Count the error rows
      ----------------------------------------------------------
      v_rows_rejected := v_rows_rejected + v_mbr_last_row;
      FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected'
      ,v_rows_rejected);

      ----------------------------------------------------------
      -- Clear the array for the next BULK fetch
      ----------------------------------------------------------
      t_rowid.DELETE;
      t_b_status.DELETE;

   END LOOP; -- bad_members

   IF p_load_type <> ('DIMENSION_GROUP') THEN
      FEM_Multi_Proc_Pkg.Post_Data_Slice(
        p_req_id => p_master_request_id,
        p_slc_id => v_slc_id,
        p_status => v_mp_status,
        p_message => v_mp_message,
        p_rows_processed => 0,
        p_rows_loaded => 0,
        p_rows_rejected => v_rows_rejected);
   END IF;

END LOOP; -- data_slice loop

   IF p_load_type = ('DIMENSION_GROUP') THEN
      gv_dimgrp_rows_rejected := gv_dimgrp_rows_rejected + v_rows_rejected;
   END IF;

   IF cv_get_bad_mbr%ISOPEN THEN
      CLOSE cv_get_bad_mbr;
   END IF;
   --x_rows_rejected := v_rows_rejected;
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_bad_mbr%ISOPEN THEN
            CLOSE cv_get_bad_mbr;
         END IF;
         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
       ,P_TOKEN1 => 'ERR_MSG'
       ,P_VALUE1 => gv_prg_msg);

         RAISE e_main_terminate;


END Pre_Validation;


/*===========================================================================+
 | PROCEDURE
 |              Pre_Validation_Attr
 |
 | DESCRIPTION
 |     This procedure performs validations on the _ATTR_T table for bad records
 |
 |     Attribute assignment rows with bad version_display_code
 |     This step processes records in the _ATTR_T table
 |     that have a version_display_code which does not exist in FEM.
 |     These assignments are "bad" so we will update their status to INVALID_VERSION
 |
 |     Attribute assignment rows where the member doesn't exist in FEM
 |     and the member doesn't exist in the join of the _B_T and _TL_T tables.
 |     The member in this case is either a 'MISSING_NAME' member in the _B_T,
 |     or it is just a non-existent member.  These attribute assignment rows are
 |     marked as 'INVALID_MEMBER'.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   15-APR-04  Created
 |    Rob Flippo   15-MAR-05  Bug#4226011 added call to not_user_label procedure
 |                            to update attr_t records where the attribute
 |                            is user_assign_allowed_flag = 'N';
 |    Rob Flippo   09-JUN-05  Bug#3895203 modified to update level specific
 |                            attributes
 +===========================================================================*/

PROCEDURE Pre_Validation_Attr (p_eng_sql IN VARCHAR2
                         ,p_data_slc IN VARCHAR2
                         ,p_proc_num IN VARCHAR2
                         ,p_partition_code IN NUMBER
                         ,p_fetch_limit IN NUMBER
                         ,p_load_type IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2
                         ,p_dimension_id IN NUMBER
                         ,p_source_b_table IN VARCHAR2
                         ,p_source_tl_table IN VARCHAR2
                         ,p_source_attr_table IN VARCHAR2
                         ,p_target_b_table IN VARCHAR2
                         ,p_member_t_dc_col IN VARCHAR2
                         ,p_member_dc_col IN VARCHAR2
                         ,p_value_set_required_flag IN VARCHAR2
                         ,p_simple_dimension_flag IN VARCHAR2
                         ,p_shared_dimension_flag IN VARCHAR2
                         ,p_hier_dimension_flag IN VARCHAR2
                         ,p_exec_mode_clause IN VARCHAR2
                         ,p_master_request_id IN NUMBER)
IS
-- Constants
   c_proc_name                      VARCHAR2(30) := 'Pre_Validation_Attr';
-- Dynamic SQL statement variables
   x_bad_attr_select_stmt            VARCHAR2(4000);
   x_bad_attr_vers_select_stmt       VARCHAR2(4000);
   x_not_user_label_status_stmt      VARCHAR2(4000);
   x_bad_attrlab_status_stmt         VARCHAR2(4000);
   x_update_attr_status_stmt         VARCHAR2(4000);
   x_special_calp_status_stmt        VARCHAR2(4000);
   x_attr_lvlspec_select_stmt       VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_attr_last_row                   NUMBER;
   v_rows_rejected                   NUMBER :=0;
   v_rows_loaded                     NUMBER :=0;
   v_temp_rows_rejected              NUMBER :=0;
   v_bulk_rows_rejected              NUMBER :=0; -- rows rejected for any status
                                                 --bulk update statements

-- Other variables
   v_fetch_limit                     NUMBER;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);


-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   t_rowid                           rowid_type;
   t_b_status                        varchar2_std_type;

---------------------
-- Declare cursors --
---------------------
   cv_get_bad_attr       cv_curs;
   cv_get_bad_attr_vers  cv_curs;

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   --DBMS_SESSION.SET_SQL_TRACE (sql_trace => TRUE);
   --x_status := 0; -- initialize status of the Pre_Validation procedure
   --x_message := 'COMPLETE:NORMAL';


   -- set the local fetch limit variable based on the parameter
   -- this will be null for Dimension Group loads
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;

     -----------------------------------------------------------------------
     -- Update rows in the _ATTR_T table where the attribute_varchar_label
     -- doesn't exist
     ----------------------------------------------------------------------------
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name
        ,'Invalid ATTRIBUTE_VARCHAR_LABEL');


      build_attrlab_update_stmt (p_dimension_varchar_label
                               ,p_source_attr_table
                               ,p_shared_dimension_flag
                               ,p_exec_mode_clause
                               ,x_bad_attrlab_status_stmt);

      IF p_data_slc IS NOT NULL THEN
         x_bad_attrlab_status_stmt := REPLACE(x_bad_attrlab_status_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_bad_attrlab_status_stmt := REPLACE(x_bad_attrlab_status_stmt,'{{data_slice}}','1=1');
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.bad_attrlab_status_stmt',x_bad_attrlab_status_stmt);


      build_not_user_label_upd_stmt (p_dimension_varchar_label
                               ,p_source_attr_table
                               ,p_shared_dimension_flag
                               ,p_exec_mode_clause
                               ,x_not_user_label_status_stmt);

      IF p_data_slc IS NOT NULL THEN
         x_not_user_label_status_stmt := REPLACE(x_not_user_label_status_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_not_user_label_status_stmt := REPLACE(x_not_user_label_status_stmt,'{{data_slice}}','1=1');
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.not_user_label_status_stmt',x_not_user_label_status_stmt);



      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name
        ,'Attribute assignments for Invalid member');

      build_status_update_stmt (p_source_attr_table
                               ,x_update_attr_status_stmt);

      build_bad_attr_select_stmt (p_dimension_varchar_label
                                 ,p_dimension_id
                                 ,p_source_b_table
                                 ,p_source_tl_table
                                 ,p_source_attr_table
                                 ,p_target_b_table
                                 ,p_member_t_dc_col
                                 ,p_member_dc_col
                                 ,p_value_set_required_flag
                                 ,p_shared_dimension_flag
                                 ,p_exec_mode_clause
                                 ,x_bad_attr_select_stmt);
      IF p_data_slc IS NOT NULL THEN
         x_bad_attr_select_stmt := REPLACE(x_bad_attr_select_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_bad_attr_select_stmt := REPLACE(x_bad_attr_select_stmt,'{{data_slice}}','1=1');
      END IF;


      build_attr_lvlspec_select_stmt (p_dimension_varchar_label
                             ,p_dimension_id
                             ,p_source_b_table
                             ,p_source_attr_table
                             ,p_target_b_table
                             ,p_member_t_dc_col
                             ,p_member_dc_col
                             ,p_value_set_required_flag
                             ,p_shared_dimension_flag
                             ,p_hier_dimension_flag
                             ,'Y'
                             ,p_exec_mode_clause
                             ,x_attr_lvlspec_select_stmt);

      IF p_data_slc IS NOT NULL THEN
         x_attr_lvlspec_select_stmt := REPLACE(x_attr_lvlspec_select_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_attr_lvlspec_select_stmt := REPLACE(x_attr_lvlspec_select_stmt,'{{data_slice}}','1=1');
      END IF;


      build_bad_attr_vers_stmt (p_dimension_varchar_label
                               ,p_source_attr_table
                               ,p_shared_dimension_flag
                               ,p_exec_mode_clause
                               ,x_bad_attr_vers_select_stmt);

      IF p_data_slc IS NOT NULL THEN
         x_bad_attr_vers_select_stmt := REPLACE(x_bad_attr_vers_select_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_bad_attr_vers_select_stmt := REPLACE(x_bad_attr_vers_select_stmt,'{{data_slice}}','1=1');
      END IF;


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.bad_attr_vers_select_stmt',x_bad_attr_vers_select_stmt);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.update_attr_status_stmt '
       ,x_update_attr_status_stmt);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.bad_attr_select_stmt'
       ,x_bad_attr_select_stmt);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.attr_lvlspec_select_stmt'
       ,x_attr_lvlspec_select_stmt);

      LOOP

         IF p_load_type <> ('DIMENSION_GROUP') THEN

         FEM_Multi_Proc_Pkg.Get_Data_Slice(
           x_slc_id => v_slc_id,
           x_slc_val1 => v_slc_val,
           x_slc_val2 => v_slc_val2,
           x_slc_val3 => v_slc_val3,
           x_slc_val4 => v_slc_val4,
           x_num_vals  => v_num_vals,
           x_part_name => v_part_name,
           p_req_id => p_master_request_id,
           p_proc_num => p_proc_num);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
          ,v_slc_val);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
          ,v_slc_val2);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
          ,v_slc_val3);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
          ,v_slc_val4);


         EXIT WHEN (v_slc_id IS NULL);
         ELSE
            EXIT WHEN (v_loop_counter > 0);
            v_loop_counter := v_loop_counter + 1;
         END IF;

         ---------------------------------------------------------------------------
         -- Execute the updates
         IF p_load_type <> ('DIMENSION_GROUP') THEN
            EXECUTE IMMEDIATE x_bad_attrlab_status_stmt USING v_slc_val, v_slc_val2;
         ELSE
            EXECUTE IMMEDIATE x_bad_attrlab_status_stmt;
         END IF;
         v_bulk_rows_rejected := SQL%ROWCOUNT;
         v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;

         IF p_load_type <> ('DIMENSION_GROUP') THEN
            EXECUTE IMMEDIATE x_not_user_label_status_stmt USING v_slc_val, v_slc_val2;
         ELSE
            EXECUTE IMMEDIATE x_not_user_label_status_stmt;
         END IF;
         v_bulk_rows_rejected := SQL%ROWCOUNT;
         v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;
         ---------------------------------------------------------------------------


         IF p_load_type <> ('DIMENSION_GROUP') THEN
            OPEN cv_get_bad_attr FOR x_bad_attr_select_stmt USING v_slc_val, v_slc_val2;
         ELSE
            OPEN cv_get_bad_attr FOR x_bad_attr_select_stmt;
         END IF;


         LOOP
            -------------------------------------------
            -- Bulk Collect Rows from the source _ATTR_T table
            -- where the member doesn't exist in FEM and the member
            -- doesn't exist in the join of _B_T/_TL_T tables
            -- but the version is a valid version
            -- Using Dynamic SELECT Statement
            -------------------------------------------
            FETCH cv_get_bad_attr BULK COLLECT INTO
                t_rowid
               ,t_b_status
            LIMIT v_fetch_limit;

            ----------------------------------------------
            -- EXIT Fetch LOOP If No Rows are Retrieved --
            ----------------------------------------------
            v_attr_last_row := t_rowid.LAST;

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.v_attr_last_row'
            ,v_attr_last_row);

            IF (v_attr_last_row IS NULL)
            THEN
               EXIT;
            END IF;

            ----------------------------------------------------------
            -- Update Status of Bad Attr Collection
            ----------------------------------------------------------
            FORALL i IN 1..v_attr_last_row
               EXECUTE IMMEDIATE x_update_attr_status_stmt
               USING t_b_status(i)
                    ,t_rowid(i)
                    ,t_b_status(i);

               COMMIT;

            ----------------------------------------------------------
            -- Count the error rows
            ----------------------------------------------------------
            v_rows_rejected := v_rows_rejected + v_attr_last_row;
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected'
            ,v_rows_rejected);

            ----------------------------------------------------------
            -- Clear the array for the next BULK fetch
            ----------------------------------------------------------
            t_rowid.DELETE;
            t_b_status.DELETE;

         END LOOP; -- attributes with Invalid Member
         IF cv_get_bad_attr%ISOPEN THEN
            CLOSE cv_get_bad_attr;
         END IF;


         IF p_hier_dimension_flag = 'Y' AND p_load_type <> 'DIMENSION_GROUP' THEN
            OPEN cv_get_bad_attr FOR x_attr_lvlspec_select_stmt USING v_slc_val, v_slc_val2;

            LOOP
               -------------------------------------------
               -- Bulk Collect Rows from the source _ATTR_T table
               -- where the attribute is a level specific attribute
               -- and the member doesn't belong to that level
               -------------------------------------------
               FETCH cv_get_bad_attr BULK COLLECT INTO
                   t_rowid
                  ,t_b_status
               LIMIT v_fetch_limit;

               ----------------------------------------------
               -- EXIT Fetch LOOP If No Rows are Retrieved --
               ----------------------------------------------
               v_attr_last_row := t_rowid.LAST;

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.v_attr_last_row'
               ,v_attr_last_row);

               IF (v_attr_last_row IS NULL)
               THEN
                  EXIT;
               END IF;

               ----------------------------------------------------------
               -- Update Status of Bad Attr Collection
               ----------------------------------------------------------
               FORALL i IN 1..v_attr_last_row
                  EXECUTE IMMEDIATE x_update_attr_status_stmt
                  USING t_b_status(i)
                       ,t_rowid(i)
                       ,t_b_status(i);

                  COMMIT;

               ----------------------------------------------------------
               -- Count the error rows
               ----------------------------------------------------------
               v_rows_rejected := v_rows_rejected + v_attr_last_row;
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected'
               ,v_rows_rejected);

               ----------------------------------------------------------
               -- Clear the array for the next BULK fetch
               ----------------------------------------------------------
               t_rowid.DELETE;
               t_b_status.DELETE;

            END LOOP; -- attributes with Invalid Member
            IF cv_get_bad_attr%ISOPEN THEN
               CLOSE cv_get_bad_attr;
            END IF;
         END IF;  -- p_hier_dimension_flag = 'Y'

         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            --------------------------------------------------------------
            -- Special Status Update for CAL_PERIOD ATTR_T records
            -- where either the CALENDAR_DISPLAY_CODE or DIMENSION_GROUP_DISPLAY_CODE
            -- do not exist.  We have to update these records because they will
            -- not otherwise be marked as Invalid since they don't show up in any
            -- of the CAL_PERIOD cursors
            ----------------------------------------------------------------
            x_special_calp_status_stmt := 'UPDATE fem_cal_periods_attr_t B'||
                                       ' SET status = ''INVALID_CALENDAR'''||
                                       ' WHERE NOT EXISTS (SELECT 0 FROM fem_calendars_b C2'||
                                       ' WHERE C2.calendar_display_code = B.calendar_display_code)'||
                                       ' AND   {{data_slice}} '||
                                       ' AND B.STATUS'||p_exec_mode_clause;

            IF p_data_slc IS NOT NULL THEN
               x_special_calp_status_stmt := REPLACE(x_special_calp_status_stmt,'{{data_slice}}',p_data_slc);
            ELSE
               x_special_calp_status_stmt := REPLACE(x_special_calp_status_stmt,'{{data_slice}}','1=1');
            END IF;

            EXECUTE IMMEDIATE x_special_calp_status_stmt USING v_slc_val, v_slc_val2;
            v_bulk_rows_rejected := SQL%ROWCOUNT;
            v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||'.bulk_rows_rejected',v_bulk_rows_rejected);


            x_special_calp_status_stmt := 'UPDATE fem_cal_periods_attr_t B'||
                                          ' SET status = ''INVALID_DIMENSION_GROUP'''||
                                          ' WHERE NOT EXISTS (SELECT 0 FROM fem_dimension_grps_b D2'||
                                          ' WHERE D2.dimension_group_display_code = B.dimension_group_display_code)'||
                                          ' AND   {{data_slice}} '||
                                          ' AND EXISTS (SELECT 0 FROM FEM_CALENDARS_B C3'||
                                          ' WHERE C3.calendar_display_code = B.calendar_display_code)'||
                                          ' AND B.STATUS'||p_exec_mode_clause;
            IF p_data_slc IS NOT NULL THEN
               x_special_calp_status_stmt := REPLACE(x_special_calp_status_stmt,'{{data_slice}}',p_data_slc);
            ELSE
               x_special_calp_status_stmt := REPLACE(x_special_calp_status_stmt,'{{data_slice}}','1=1');
            END IF;

            EXECUTE IMMEDIATE x_special_calp_status_stmt USING v_slc_val, v_slc_val2;
            v_bulk_rows_rejected := SQL%ROWCOUNT;
            v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||'.bulk_rows_rejected',v_bulk_rows_rejected);

            --------------------------------------------------------------------------
            -- END Special CAL_PERIOD Status Update
            --------------------------------------------------------------------------
         END IF;  -- special CAL_PERIOD status update
         --------------------------------------------------------------------------
         -- BEGIN Invalid Version Display Code in ATTR_T table
         --------------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name
           ,'Attribute assignments with invalid version_display_code');

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.bad_attr_vers_select_stmt',x_bad_attr_vers_select_stmt);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.update_attr_status_stmt '
          ,x_update_attr_status_stmt);

         IF p_load_type <> ('DIMENSION_GROUP') THEN
            OPEN cv_get_bad_attr_vers FOR x_bad_attr_vers_select_stmt USING v_slc_val, v_slc_val2;
         ELSE
            OPEN cv_get_bad_attr_vers FOR x_bad_attr_vers_select_stmt;
         END IF;

         LOOP
            -------------------------------------------
            -- Bulk Collect Rows from the source _ATTR_T table
            -- where the version_display_code doesn't exist
            -- Using Dynamic SELECT Statement
            -------------------------------------------

            FETCH cv_get_bad_attr_vers BULK COLLECT INTO
                   t_rowid
                  ,t_b_status
            LIMIT v_fetch_limit;

            ----------------------------------------------
            -- EXIT Fetch LOOP If No Rows are Retrieved --
            ----------------------------------------------
            v_attr_last_row := t_rowid.LAST;

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.v_attr_last_row'
            ,v_attr_last_row);

            IF (v_attr_last_row IS NULL)
            THEN
               EXIT;
            END IF;

            ----------------------------------------------------------
            -- Update Status of Bad Attr Version Collection
            ----------------------------------------------------------
            FORALL i IN 1..v_attr_last_row
               EXECUTE IMMEDIATE x_update_attr_status_stmt
               USING t_b_status(i)
                    ,t_rowid(i)
                    ,t_b_status(i);

                COMMIT;

            ----------------------------------------------------------
            -- Count the error rows
            ----------------------------------------------------------
            v_rows_rejected := v_rows_rejected + v_attr_last_row;
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected'
            ,v_rows_rejected);

            ----------------------------------------------------------
            -- Clear the array for the next BULK fetch
            ----------------------------------------------------------
            t_rowid.DELETE;
            t_b_status.DELETE;

         END LOOP; -- bad_attr_vers

   FEM_Multi_Proc_Pkg.Post_Data_Slice(
     p_req_id => p_master_request_id,
     p_slc_id => v_slc_id,
     p_status => v_mp_status,
     p_message => v_mp_message,
     p_rows_processed => 0,
     p_rows_loaded => 0,
     p_rows_rejected => v_rows_rejected);

      END LOOP; -- get_data_slice
      IF cv_get_bad_attr_vers%ISOPEN THEN
         CLOSE cv_get_bad_attr_vers;
      END IF;

   --x_rows_rejected := v_rows_rejected;
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_bad_attr%ISOPEN THEN
            CLOSE cv_get_bad_attr;
         END IF;

         IF cv_get_bad_attr_vers%ISOPEN THEN
            CLOSE cv_get_bad_attr;
         END IF;
         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
          ,P_TOKEN1 => 'ERR_MSG'
          ,P_VALUE1 => gv_prg_msg);

      /*   FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_text => gv_prg_msg); */


         RAISE e_main_terminate;


END Pre_Validation_Attr;


/*===========================================================================+
 | PROCEDURE
 |              New_Members
 |
 | DESCRIPTION
 |  Loop through the members that do not yet exist and have names/desc in the TL table
 |  to perform validations and eventually insert into the target dimension member tables
 |  In the case where the user provides multiple versions of the attribute
 |  assignments for the same member, only the "default" version is read for "required"
 |  attributes
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |   New Members
 |
 |   1.	Retrieve members from join of _B_T/_TL_T where the member does not
 |      already exist in FEM.
 |   2.	If Simple Dim = 'N', for each member, retrieve all "required" attribute
 |      assignment records from _ATTR_T where the VERSION_DISPLAY_CODE exists.
 |   3.	If number attribute assignments < number of required attributes, the member
 |      fails with status = 'MISSING_REQUIRED_ATTRIBUTE'.  The _TL_T gets
 |      'INVALID_MEMBER' and all of the _ATTR_T records get 'INVALID_MEMBER'.
 |   4.	If the number of attribute assignments = number of required attributes,
 |      then each assignment record is validated individually:
 |      	For Dimension Groups - check the Dim Group Sequence.  Failure =
 |         'DIM_GROUP_SEQUENCE_NOT_UNIQUE'.
 |      	For Dimension Groups (CAL_PERIOD only) - check Time Group Type Code.
 |          Failure = 'INVALID_TIME_GROUP_TYPE'.
 |      	If a DIMENSION assignment, then assignment value must exist in the
 |          attribute dimension table.  Status = 'INVALID_DIM_ASSIGNMENT' for failure
 |      	If a DATE assignment, then assignment value must be a valid date.
 |          Status='INVALID_DATE' for failure
 |      	If a NUMBER assignment, then assignment value must be a valid number.
 |          Status = 'INVALID_NUMBER' for failure.
 |      	Special CAL_PERIOD validation on GL_PERIOD_NUM attribute - attribute
 |          assignment must match value in the CAL_PERIOD_NUMBER identifier column
 |           Status = 'INVALID_CAL_PERIOD_END_DATE' for failure
 |
 |      The _B_T gets 'INVALID_REQUIRED_ATTRIBUTE' whenever one fails.  The
 |      _TL_T gets 'INVALID_MEMBER'.
 |   5.	Insert success records into FEM.  Only the _TL_T record for the user's
 |      current session is used to initially create the member - records for
 |      other installed languages default to that value for this stage.
 |   6.	Delete success records from _B_T/_TL_T/_ATTR_T.
 |
 |   SPECIAL NOTE:  The x_rows_loaded output variable is only populated if a
 |                  new member is created.  It does not represent the number of
 |                  rows loaded.  Rather, it is just serving as a flag to indicate
 |                  that at least one new member was created.
 | MODIFICATION HISTORY
 |  Rob Flippo 22-MAR-04  Created
 |  Rob Flippo 13-SEP-04  Bug#3835758  Validation on the attr_Assign_vs
 |                                     was modified to include dimension_id
 |                                     in the where condition
 |
 |  Rob Flippo 14-SEP-04  Removed the build_dep_status_update procedure call
 |                        since attribute records where the member is invalid
 |                        is already handled in the attr_update section
 |  Rob Flippo 15-SEP-04  Bug#3835758  Added exception handler so no failure
 |                        if VS didn't exist.  Also moved the section
 |                        that verifies the VS so that only called
 |                        for DIMENSION attributes;
 |  Rob Flippo 16-NOV-04  Bug#4002917  for preventing overlap cal periods
 |                        Added a new section in the attr validations for
 |                        checking date overlap conditions;  also added
 |                        new validation to require cal_period_number > 0;
 |  Rob Flippo 22-NOV-04  Bug#4019066 Add validation on Accounting_Year
 |                        and GL_PERIOD_NUM for CAL_PERIOD;  ACCOUNTING_YEAR
 |                        must be >=1900 and <= 2599 while GL_PERIOD_NUM
 |                          must be <= periods_in_year for the Time Group Type
 | Rob Flippo  24-NOV-04  Bug#4041308 Remove periods_in_year check
 | Rob Flippo  03-JAN-05  Bug#4030717 FEM.D: MODIFY DIM MBR LOADER OVERLAP
 |                        DATE LOGIC TO ALLOW MP FOR CAL_PERIOD
 |                        -- using 2 new interim tables for Cal Period loads
 |                           FEM_CALP_INTERIM_T and FEM_CALP_ATTR_INTERIM_T
 |                           The loader inserts from the final array into
 |                           these new tables, then performs date overlap
 |                           check before moving all good records into FEM
 | Rob Flippo  30-JUN-05  Bug#4355484
 |                        CALL BUS EVENT WHEN CCC-ORGS LOADED WITH DIM LOADER
 |                        As long as >0 new members created in a load, the
 |                        loader calls the bus. event
 | Rob Flippo  10-MAR-06  Bug#5068022 - unique constraint error on duplicate
 |                        names
 | Rob Flippo 04-APR-06  Bug#5117594 Remove unique name check for Customer
 |                       dimension
 | Rob Flippo 28-APR-06  Bug 5174039 Added validation that calp start_date
 |                       must be <= calp end date
 | Rob Flippo 04-AUG-06  Bug 5060746 Change literals to bind variables wherever possible
 +===========================================================================*/

PROCEDURE New_Members (p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_partition_code IN NUMBER
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_date_format_mask IN VARCHAR2
                      ,p_dimension_id IN VARCHAR2
                      ,p_target_b_table IN VARCHAR2
                      ,p_target_tl_table IN VARCHAR2
                      ,p_target_attr_table IN VARCHAR2
                      ,p_source_b_table IN VARCHAR2
                      ,p_source_tl_table IN VARCHAR2
                      ,p_source_attr_table IN VARCHAR2
                      ,p_table_handler_name IN VARCHAR2
                      ,p_member_col IN VARCHAR2
                      ,p_member_dc_col IN VARCHAR2
                      ,p_member_name_col IN VARCHAR2
                      ,p_member_t_dc_col IN VARCHAR2
                      ,p_member_t_name_col IN VARCHAR2
                      ,p_member_description_col IN VARCHAR2
                      ,p_value_set_required_flag IN VARCHAR2
                      ,p_simple_dimension_flag IN VARCHAR2
                      ,p_shared_dimension_flag IN VARCHAR2
                      ,p_hier_dimension_flag IN VARCHAR2
                      ,p_member_id_method_code IN VARCHAR2
                      ,p_exec_mode_clause IN VARCHAR2
                      ,p_master_request_id IN NUMBER)
IS
-- Constants
   c_proc_name                       VARCHAR2(30) := 'New_Members';

-- variables storing temporary state information
   v_attr_success                    VARCHAR2(30);
   v_temp_member                     VARCHAR2(100);
   v_count                           NUMBER;
   v_req_attribute_count             NUMBER;

-- Dynamic SQL statement variables
   x_select_stmt                     VARCHAR2(4000);
   x_attr_select_stmt                VARCHAR2(4000);
   x_remain_mbr_select_stmt          VARCHAR2(4000);
   x_insert_member_stmt              VARCHAR2(4000);
   x_insert_attr_stmt                VARCHAR2(4000);
   x_update_stmt                     VARCHAR2(4000);
   x_attr_update_stmt                VARCHAR2(4000);
   x_update_tl_stmt                  VARCHAR2(4000);
   x_update_dep_attr_status_stmt     VARCHAR2(4000);
   x_update_dep_tl_status_stmt       VARCHAR2(4000);
   x_update_attr_status_stmt         VARCHAR2(4000);
   x_update_mbr_status_stmt          VARCHAR2(4000);
   x_update_tl_status_stmt           VARCHAR2(4000);
   x_update_dimgrp_stmt              VARCHAR2(4000);
   x_delete_attr_stmt                VARCHAR2(4000);
   x_special_delete_attr_stmt        VARCHAR2(4000);
   x_delete_mbr_stmt                 VARCHAR2(4000);
   x_delete_tl_stmt                  VARCHAR2(4000);
   x_does_attr_exist_stmt            VARCHAR2(4000);
   x_does_attr_exist_novers_stmt     VARCHAR2(4000);
   x_overlap_sql_stmt                VARCHAR2(4000);
   x_adj_period_stmt                 VARCHAR2(4000);
   x_dupname_count_stmt              VARCHAR2(4000);

   -- special stmt for CAL_PERIOD loads only
   -- for inserting into interim tables (to support Date Overlap checks)
   x_calp_interim_stmt        VARCHAR2(4000);
   x_calp_attr_interim_stmt   VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_dupname_count                   NUMBER := 0;
   v_attr_final_count                NUMBER := 0;
   v_mbr_final_count                 NUMBER := 0;
   v_mbr_count                       NUMBER := 0;
   v_mbr_subcount                    NUMBER := 0;
   v_attr_count                      NUMBER := 0;
   v_final_mbr_last_row              NUMBER;
   v_attr_last_row                   NUMBER;
   v_mbr_last_row                    NUMBER;
   v_rows_fetched                    NUMBER;
   v_temp_rows_rejected              NUMBER :=0;
   v_rows_rejected                   NUMBER :=0;
   v_rows_loaded                     NUMBER :=0;
   v_temp_rows_loaded                NUMBER :=0;
   v_adj_period_count                NUMBER :=0;
   v_overlap_count                   NUMBER :=0;  -- counter for the number of
                                                  -- cal periods that have overlapping
                                                  -- dates in the _ATTR_T table
   v_duplicate_attr_count            NUMBER;  -- counter for verifying that duplicate
                                              -- assignments for same attr don't exist
                                              -- in the interface table

   -- Other variables
   v_fetch_limit                     NUMBER;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   t_rowid                           rowid_type;
   t_tl_rowid                        rowid_type;
   tf_tl_rowid                       rowid_type;
   tf_rowid                          rowid_type;
   ta_rowid                          rowid_type;
   tfa_rowid                         rowid_type;


   --t_member_id                       number_type;
   t_value_set_id                    number_type;
   t_dimension_group_id              number_type;
   t_calendar_id                     number_type;
   t_cal_period_number               number_type;
   t_dimension_group_seq             number_type;
   t_time_group_type_code            varchar2_std_type;
   t_seq_conflict_count              number_type;
   -- t_periods_in_year                 number_type;  -- not used at this time
                                                      -- per bug#4031308

   --tf_member_id                      number_type;
   tf_value_set_id                   number_type;
   tf_dimension_group_id             number_type;
   tf_calendar_id                    number_type;
   tf_cal_period_number              number_type;
   tf_dimension_group_seq            number_type;
   tf_time_dimension_group_key       number_type;
   tf_time_group_type_code           varchar2_std_type;
   tf_dimension_id                   number_type;
   tf_dimgrp_dimension_group_id      number_type;

   ta_attribute_id                   number_type;
   ta_attribute_dimension_id         number_type;
   ta_dim_attr_numeric_member        number_type;
   ta_number_assign_value            number_type;
   ta_version_id                     number_type;
   ta_attr_assign_vs_id              number_type;
   ta_attr_exists_count              number_type;  -- count of existing attr assign with version_id
   ta_attr_exists_novers_count       number_type;  -- count of existing attr assign without version_id


   tfa_attribute_id                  number_type;
   tfa_dim_attr_numeric_member       number_type;
   tfa_number_assign_value           number_type;
   tfa_version_id                    number_type;
   tfa_attr_assign_vs_id             number_type;

   t_cal_period_end_date             date_type;
   ta_cal_period_end_date            date_type;
   tf_cal_period_end_date            date_type;
   tfa_cal_period_end_date           date_type;
   t_cal_period_start_date           date_type;
   tf_cal_period_start_date          date_type;

   ta_date_assign_value              date_type;
   tfa_date_assign_value             date_type;

   t_b_status                        varchar2_std_type;
   t_tl_status                       varchar2_std_type;
   tf_status                         varchar2_std_type;

   ta_attribute_varchar_label        varchar2_std_type;
   tfa_attribute_varchar_label       varchar2_std_type;
   ta_attr_value_column_name         varchar2_std_type;
   ta_attribute_data_type_code       varchar2_std_type;
   ta_dim_attr_varchar_member        varchar2_std_type;
   ta_status                         varchar2_std_type;


   tfa_dim_attr_varchar_member       varchar2_std_type;
   tfa_status                        varchar2_std_type;

   t_member_dc                       varchar2_150_type;
   t_calendar_dc                     varchar2_150_type;
   t_value_set_dc                    varchar2_150_type;
   t_dimension_group_dc              varchar2_150_type;
   t_member_name                     varchar2_150_type;
   t_adj_period_flag                 flag_type;  -- Y means it is an adj period

   tf_member_dc                      varchar2_150_type;
   tf_member_name                    varchar2_150_type;
   tf_calendar_dc                    varchar2_150_type;
   tf_dimension_group_dc             varchar2_150_type;
   tf_adj_period_flag                flag_type;

   ta_member_dc                      varchar2_150_type;
   ta_value_set_dc                   varchar2_150_type;
   ta_version_display_code           varchar2_150_type;
   ta_attr_assign_vs_dc              varchar2_150_type;

   tfa_member_dc                     varchar2_150_type;
   tfa_value_set_dc                  varchar2_150_type;

   t_member_desc                     desc_type;
   tf_member_desc                    desc_type;

   t_new_member_flag                 flag_type;

   ta_attribute_required_flag        flag_type;
   ta_allow_mult_assign_flag         flag_type;
   ta_read_only_flag                 flag_type;
   ta_allow_mult_versions_flag       flag_type;
   ta_use_interim_table_flag         flag_type; -- placeholder only - not functional

   t_language                        lang_type;
   tf_language                       lang_type;
   ta_language                       lang_type;

   ta_varchar_assign_value           varchar2_1000_type;
   ta_attribute_assign_value         varchar2_1000_type;
   tfa_varchar_assign_value          varchar2_1000_type;

   ta_member_read_only_flag          flag_type;  -- designates if the member is
                                                 -- read only;  this is ignored
                                                 -- in the new_member section and
                                                 -- only included for consistency
                                                 -- with the bulk select
   -- variables for holding attributes of CAL_PERIOD
   ta_calpattr_cal_dc                varchar2_std_type;
   ta_calpattr_dimgrp_dc             varchar2_std_type;
   ta_calpattr_end_date              date_type;
   ta_calpattr_period_num            number_type;

---------------------
-- Declare cursors --
---------------------
   cv_get_rows           cv_curs;
   cv_get_attr_rows      cv_curs;

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   --DBMS_SESSION.SET_SQL_TRACE (sql_trace => TRUE);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.p_simple_dimension_flag'
     ,p_simple_dimension_flag);

   --x_status := 0; -- initialize status of the New_Members procedure
   --x_message := 'COMPLETE:NORMAL';

   ------------------------------------------------------------------------------
   -- Build the select stmt for new Dimension members using the information
   -- returned from get_dimension_info
   ------------------------------------------------------------------------------

   build_mbr_select_stmt  (p_load_type
                          ,p_dimension_varchar_label
                          ,p_dimension_id
                          ,p_target_b_table
                          ,p_target_tl_table
                          ,p_source_b_table
                          ,p_source_tl_table
                          ,p_member_dc_col
                          ,p_member_t_dc_col
                          ,p_member_t_name_col
                          ,p_member_description_col
                          ,p_value_set_required_flag
                          ,p_shared_dimension_flag
                          ,p_hier_dimension_flag
                          ,'N'
                          ,p_exec_mode_clause
                          ,x_select_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_select_stmt := REPLACE(x_select_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_select_stmt := REPLACE(x_select_stmt,'{{data_slice}}','1=1');
   END IF;

   -- set the local fetch limit variable based on the parameter
   -- this will be null for Dimension Group loads
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.member select_stmt'
   ,x_select_stmt);


  build_insert_member_stmt (p_table_handler_name
                           ,p_dimension_id
                           ,p_value_set_required_flag
                           ,p_hier_dimension_flag
                           ,p_simple_dimension_flag
                           ,p_member_id_method_code
                           ,p_member_col
                           ,p_member_dc_col
                           ,p_member_name_col
                           ,x_insert_member_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.insert member stmt'
   ,x_insert_member_stmt);

   build_status_update_stmt (p_source_b_table
                            ,x_update_mbr_status_stmt);

   build_status_update_stmt (p_source_tl_table
                            ,x_update_tl_status_stmt);

   build_delete_stmt (p_source_b_table
                     ,x_delete_mbr_stmt);

   build_delete_stmt (p_source_tl_table
                     ,x_delete_tl_stmt);


   build_tl_dupname_stmt (p_dimension_varchar_label
                         ,p_dimension_id
                         ,p_load_type
                         ,p_target_b_table
                         ,p_target_tl_table
                         ,p_member_col
                         ,p_member_dc_col
                         ,p_member_name_col
                         ,p_value_set_required_flag
                         ,'NEW_MEMBERS'
                         ,x_dupname_count_stmt);
     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.dupname select stmt'
     ,x_dupname_count_stmt);


   IF (p_simple_dimension_flag = 'N') THEN
      build_attr_select_stmt (p_dimension_varchar_label
                             ,p_dimension_id
                             ,p_source_b_table
                             ,p_source_attr_table
                             ,p_target_b_table
                             ,p_member_t_dc_col
                             ,p_member_dc_col
                             ,p_member_col
                             ,p_value_set_required_flag
                             ,p_shared_dimension_flag
                             ,p_hier_dimension_flag
                             ,'Y'
                             ,'Y'
                             ,p_exec_mode_clause
                             ,x_attr_select_stmt);

      IF p_data_slc IS NOT NULL THEN
         x_attr_select_stmt := REPLACE(x_attr_select_stmt,'{{data_slice}}',p_data_slc);
      ELSE
         x_attr_select_stmt := REPLACE(x_attr_select_stmt,'{{data_slice}}','1=1');
      END IF;

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.attribute select stmt'
     ,x_attr_select_stmt);


     build_status_update_stmt (p_source_attr_table
                              ,x_update_attr_status_stmt);

/*  RCF 9-14-2004 Commented out since no longer needed
     build_dep_status_update_stmt (p_dimension_varchar_label
                                  ,p_source_attr_table
                                  ,p_member_t_dc_col
                                  ,p_value_set_required_flag
                                  ,x_update_dep_attr_status_stmt);  */

     build_insert_attr_stmt (p_target_attr_table
                            ,p_target_b_table
                            ,p_member_col
                            ,p_member_dc_col
                            ,p_value_set_required_flag
                            ,x_insert_attr_stmt);

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.insert attr stmt'
     ,x_insert_attr_stmt);


      build_delete_stmt (p_source_attr_table
                        ,x_delete_attr_stmt);

      -- special insert stmts for the INTERIM tables for CAL_PERIOD loads
      IF p_dimension_varchar_label = 'CAL_PERIOD' THEN

         build_calp_interim_insert_stmt(x_calp_interim_stmt
                                       ,x_calp_attr_interim_stmt);
      END IF;

   END IF;  --v_simple_dimension_flag = 'N'

   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop
   LOOP

      IF p_load_type <> ('DIMENSION_GROUP') THEN

         FEM_Multi_Proc_Pkg.Get_Data_Slice(
           x_slc_id => v_slc_id,
           x_slc_val1 => v_slc_val,
           x_slc_val2 => v_slc_val2,
           x_slc_val3 => v_slc_val3,
           x_slc_val4 => v_slc_val4,
           x_num_vals  => v_num_vals,
           x_part_name => v_part_name,
           p_req_id => p_master_request_id,
           p_proc_num => p_proc_num);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
          ,v_slc_val);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
          ,v_slc_val2);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
          ,v_slc_val3);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
          ,v_slc_val4);

         EXIT WHEN (v_slc_id IS NULL);
      ELSE
         EXIT WHEN (v_loop_counter > 0);
         v_loop_counter := v_loop_counter + 1;
      END IF;


   ------------------------------------------------------------------------------
   -- Loop through the new members
   -- to perform validations and eventually insert into the target dimension tables
   ------------------------------------------------------------------------------
      IF p_load_type <> ('DIMENSION_GROUP') THEN
         OPEN cv_get_rows FOR x_select_stmt USING v_slc_val, v_slc_val2;
      ELSE
         OPEN cv_get_rows FOR x_select_stmt;
      END IF;


      LOOP

      -------------------------------------------
      -- Bulk Collect Rows from the source _T tables
      -- Using Dynamic SELECT Statement
      -------------------------------------------
         FETCH cv_get_rows BULK COLLECT INTO
                t_rowid
               ,t_tl_rowid
               ,t_member_dc
               ,t_calendar_dc
               ,t_calendar_id
               ,t_cal_period_end_date
               ,t_cal_period_number
               ,t_value_set_dc
               ,t_value_set_id
               ,t_dimension_group_dc
               ,t_dimension_group_id
               ,t_b_status
               ,t_member_name
               ,t_member_desc
               ,t_language
               ,t_tl_status
               ,t_cal_period_start_date
               ,t_dimension_group_seq
               ,t_time_group_type_code
         LIMIT v_fetch_limit;
         ----------------------------------------------
         -- EXIT Fetch LOOP If No Rows are Retrieved --
         ----------------------------------------------

         v_mbr_last_row := t_member_dc.LAST;

         IF (v_mbr_last_row IS NULL)
         THEN
            EXIT;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.Rows retrieved this fetch',v_mbr_last_row);

         v_rows_fetched := v_rows_fetched + v_mbr_last_row;

         ----------------------------------------------
         --  Begin Validations
         ----------------------------------------------
         FOR i IN 1..v_mbr_last_row
         LOOP

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.member display code'
            ,t_member_dc(i));
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.dimension_group_id'
            ,t_dimension_group_id(i));

            -- initializing the adj_period_flag
            -- this will get set appropriately if the period
            -- is not an adj period during the date_overlap check
            t_adj_period_flag(i) := 'Y';

         -------------------------------------------------------------------
         -- For CAL_PERIOD member load, need to retrieve the periods_in_year
         -- for the Time Group Type of the new member.
         /***************************************************
           RCF 11/24/2004 Removing this check per bug#4031308
         IF (p_dimension_varchar_label = 'CAL_PERIOD'
             AND p_load_type NOT IN ('DIMENSION_GROUP')) THEN
            BEGIN
               SELECT A.number_assign_value
               INTO t_periods_in_year(i)
               FROM fem_time_grp_types_attr A
                   ,fem_dim_attributes_b DA
                   ,fem_dim_attr_versions_B V
                   ,fem_dimension_grps_b DG
               WHERE A.time_group_type_code = DG.time_group_type_code
               AND DG.dimension_group_id = t_dimension_group_id(i)
               AND A.attribute_id = DA.attribute_id
               AND DA.dimension_id = 33
               AND DA.attribute_varchar_label = 'PERIODS_IN_YEAR'
               AND A.version_id = V.version_id
               AND V.default_version_flag = 'Y'
               AND V.aw_snapshot_flag = 'N'
               AND V.attribute_id = DA.attribute_id;
             EXCEPTION
                WHEN no_data_found THEN
                   t_periods_in_year(i) := 0;
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.periods_in_year'
                  ,t_periods_in_year(i));

             END;
         END IF; -- CAL_PERIOD
         *************************************************/

         ----------------------------------------------
         --  Begin Duplicate Name Validations (only if dim <> 'CUSTOMER')
         --  Check to see if the translatabe name that will be load
         --  already exists for ANY language in the target TL table
         --  Set STATUS = 'DUPLICATE_NAME' if the name already exists
         ----------------------------------------------
         IF p_dimension_varchar_label <> 'CUSTOMER' THEN
            IF p_dimension_varchar_label = 'CAL_PERIOD'
               AND p_load_type <> 'DIMENSION_GROUP' THEN
                  EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                     USING t_member_name(i)
                          ,t_dimension_group_id(i)
                          ,t_calendar_id(i);

            ELSE
               IF p_value_set_required_flag = 'Y' THEN
                  EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                     USING t_member_name(i)
                          ,t_value_set_dc(i);
               ELSE
                  EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                     USING t_member_name(i);
               END IF;
            END IF;

            IF v_dupname_count > 0 THEN
               t_b_status(i) := 'INVALID_MEMBER';
               t_tl_status(i) := 'DUPLICATE_NAME';
            END IF;
         END IF; -- p_dim_label <> 'CUSTOMER'

         ----------------------------------------------
         --  Begin Dimension Group Validations
         ----------------------------------------------
            IF (p_load_type = 'DIMENSION_GROUP') AND t_b_status(i) = 'LOAD' THEN
               SELECT count(*)
               INTO t_seq_conflict_count(i)
               FROM fem_dimension_grps_b
               WHERE dimension_group_seq = t_dimension_group_seq(i)
               AND dimension_id = p_dimension_id;

               IF t_seq_conflict_count(i) > 0 THEN
                  t_b_status(i) := 'DIMENSION_GROUP_SEQ_NOT_UNIQUE';
               END IF; -- seq_conflict_count
               IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
                  SELECT count(*)
                  INTO v_count
                  FROM fem_time_group_types_b
                  WHERE time_group_type_code = t_time_group_type_code(i);

                  IF v_count =0 THEN
                     t_b_status(i) := 'INVALID_TIME_GROUP_TYPE';
                     t_tl_status(i) := 'INVALID_MEMBER';
                  END IF;
               END IF; -- CAL_PERIOD
            ELSE
               IF (p_value_set_required_flag = 'Y' AND t_value_set_id(i) IS NULL) THEN
                  t_b_status(i) := 'INVALID_VALUE_SET';
                  t_tl_status(i) := 'INVALID_MEMBER';
               END IF;

               IF (p_dimension_varchar_label = 'CAL_PERIOD' AND t_calendar_id(i) IS NULL) THEN
                  t_b_status(i) := 'INVALID_CALENDAR';
                  t_tl_status(i) := 'INVALID_MEMBER';
               END IF;

               IF (p_hier_dimension_flag = 'Y'
                   AND t_b_status(i) = 'LOAD'
                   AND t_dimension_group_dc(i) IS NOT NULL
                   AND t_dimension_group_id(i) IS NULL) THEN
                  t_b_status(i) := 'INVALID_DIMENSION_GROUP';
                  t_tl_status(i) := 'INVALID_MEMBER';
               END IF; -- Validate Dimension Group
            END IF; -- Load Type Dimension Group v.s. Dimension

            IF p_simple_dimension_flag = 'N' THEN

               -- Count the number of required attribute rows
               SELECT count(*)
               INTO v_req_attribute_count
               FROM fem_dim_attributes_b
               WHERE dimension_id = p_dimension_id
               AND attribute_required_flag = 'Y'
               AND nvl(user_assign_allowed_flag,'Y') NOT IN ('N');

   /*  This section commented out - because Required attributes can't be assigned
       to a level.  Only optional attributes
               AND (attribute_id NOT IN (SELECT attribute_id FROM fem_dim_attr_grps)
               OR attribute_id IN (SELECT attribute_id
            FROM fem_dim_attr_grps
            WHERE dimension_group_id = t_dimension_group_id(i)));  */


               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.member status'
               ,t_b_status(i));

               ------------------------------------------------------------
               -- Bulk Collect ATTR_T Rows
               -- Using Dynamic SELECT Statement
               -- 11/03/2004 For this section, we only want to enter
               -- the attribute loop for Cal Period dimension when
               -- the Dimension Group is valid. Otherwise, the loader
               -- would report MISSING_REQ_ATTRIBUTE status for that member
               -- which is not correct.  For other dimensions, we want to
               -- enter the loop even when the Dimension Group is incorrect,
               -- so that all required attr rows in the _ATTR_T table get
               -- updated with INVALID_MEMBER
               -- The special update in the Pre Validation Attr section
               -- will update any req attr rows for CAL_PERIOD dimension
               -- when the Dimension Group is wrong
               ------------------------------------------------------------
            IF ((p_dimension_varchar_label = 'CAL_PERIOD' AND
                 t_b_status(i) in ('LOAD')) OR
                (p_dimension_varchar_label NOT IN ('CAL_PERIOD') AND
                 t_b_status(i) IN ('LOAD','INVALID_VALUE_SET',
                                   'INVALID_DIMENSION_GROUP')))
               THEN
                  IF (p_value_set_required_flag = 'Y') THEN
                     OPEN cv_get_attr_rows FOR x_attr_select_stmt
                        USING t_member_dc(i)
                             ,t_value_set_dc(i);
                  ELSE
                     OPEN cv_get_attr_rows FOR x_attr_select_stmt
                        USING t_member_dc(i);
                   END IF; -- v_value_set_required_flag

                  FETCH cv_get_attr_rows BULK COLLECT INTO
                     ta_rowid
                    ,ta_member_read_only_flag
                    ,ta_attribute_id
                    ,ta_attribute_varchar_label
                    ,ta_attribute_dimension_id
                    ,ta_attr_value_column_name
                    ,ta_attribute_data_type_code
                    ,ta_attribute_required_flag
                    ,ta_read_only_flag
                    ,ta_allow_mult_versions_flag
                    ,ta_allow_mult_assign_flag
                    ,ta_member_dc
                    ,ta_value_set_dc
                    ,ta_attribute_assign_value
                    ,ta_dim_attr_numeric_member
                    ,ta_dim_attr_varchar_member
                    ,ta_number_assign_value
                    ,ta_varchar_assign_value
                    ,ta_date_assign_value
                    ,ta_version_display_code
                    ,ta_version_id
                    ,ta_attr_assign_vs_dc
                    ,ta_attr_assign_vs_id
                    ,ta_status
                    ,ta_use_interim_table_flag
                    ,ta_calpattr_cal_dc
                    ,ta_calpattr_dimgrp_dc
                    ,ta_calpattr_end_date
                    ,ta_calpattr_period_num
                  LIMIT v_fetch_limit;

                  v_attr_last_row := NVL(ta_attribute_id.LAST,0);
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.assignment rows',v_attr_last_row);

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.req_attr_rows',v_req_attribute_count);

                  -- Not enough attribute rows were returned because of either:
                  -- 1) the join to the  Version table (bad version display_code in _ATTR_T)
                  -- or
                  -- 2)  a missing required attribute row
                  -- In either case, we mark
                  -- the member as MISSING_REQUIRED_ATTRIBUTE and the attribute rows with the
                  -- valid version_display_code will get 'INVALID_MEMBER'.  The
                  -- Bad version display_code records have already been marked as
                  -- INVALID_VERSION in the Pre_validation
                  -- Note:  It is also possible to return too many attr rows,
                  --        if the user has attempted to provide "many to many"
                  --        for a requried attribute (which is not allowed).
                  --        So the comparison is <> to check for this case
                  IF t_b_status(i) IN ('LOAD')
                    AND v_attr_last_row < v_req_attribute_count THEN
                     t_b_status(i) := 'MISSING_REQUIRED_ATTRIBUTE';
                     t_tl_status(i) := 'INVALID_MEMBER';
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.missing_req - end_date=',t_cal_period_end_date(i));
                  ELSIF t_b_status(i) IN ('LOAD')
                    AND v_attr_last_row > v_req_attribute_count THEN
                     t_b_status(i) := 'DUPLICATE_REQUIRED_ATTRIBUTES';
                     t_tl_status(i) := 'INVALID_MEMBER';
                  ELSE
                  FOR j IN 1..v_attr_last_row
                  LOOP

                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_label'
                     ,ta_attribute_varchar_label(j));
                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name||'.attribute assign value'
                     ,ta_attribute_assign_value(j));
                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_column_name'
                     ,ta_attr_value_column_name(j));

/*
                  -- Checking for duplicate attribute assignments
                  -- Because the unique index on the ATTR_T table allows
                  -- for duplicate assignments, we need to identify if such
                  -- cases exist and update the status appropriately
                  -- If allow_mult_assign = 'N' and duplicate exists,
                  -- then status = MULT_ASSIGN_NOT_ALLOWED
                  -- If allow_mult_assign = 'Y', then we have to check if
                  -- the assignments are identical - if they are identical,
                  -- then status = DUPLICATE_ATTR_ASSIGNMENTS
                  -- Note:  Since this is in the NEW_MEMBERS procedure,
                  -- we are dealing with just the default version here
                  -- which means we don't have compare version by version
                  IF ta_allow_mult_assign_flag(j) = 'N' THEN
                     v_duplicate_attr_count := 0;
                     FOR k IN 1..v_attr_last_row LOOP
                        IF ta_attribute_varchar_label(j) = ta_attribute_varchar_label(k) THEN
                          v_duplicate_attr_count := v_duplicate_attr_count + 1;
                        END IF;
                     END LOOP;
                     IF v_duplicate_attr_count > 1 THEN
                           ta_status(j) := 'MULT_ASSIGN_NOT_ALLOWED';
                           t_b_status(i) := 'INVALID_MEMBER';
                           t_tl_status(i) := 'INVALID_MEMBER';
                        EXIT; -- member is no good so exit
                     END IF;
                   -- for the default version, can't have multiple records with same assignment
                   -- when attribute is not CAL_PERIOD
                  ELSIF ta_allow_mult_assign_flag(j) = 'Y'
                     AND ta_attribute_dimension_id(j) <> 1 THEN
                     v_duplicate_attr_count := 0;
                     FOR k IN 1..v_attr_last_row LOOP
                        IF ta_attribute_varchar_label(j) = ta_attribute_varchar_label(k)
                           AND ta_attribute_assign_value(j) = ta_attribute_assign_value(k)
                           THEN
                          v_duplicate_attr_count := v_duplicate_attr_count + 1;
                        END IF;
                     END LOOP;
                     IF v_duplicate_attr_count > 1 THEN
                           ta_status(j) := 'DUPLICATE_ATTR_ASSIGNMENTS';
                           t_b_status(i) := 'INVALID_MEMBER';
                           t_tl_status(i) := 'INVALID_MEMBER';
                        EXIT; -- member is no good so exit
                     END IF;
                   -- for the default version, can't have multiple records with the same
                   -- CAL_PERIOD attr assignment columns when the attribute
                   -- is of dimension = CAL_PERIOD
                  ELSIF ta_allow_mult_assign_flag(j) = 'Y'
                     AND ta_attribute_dimension_id(j) = 1 THEN
                     v_duplicate_attr_count := 0;
                     FOR k IN 1..v_attr_last_row LOOP
                        IF ta_attribute_varchar_label(j) = ta_attribute_varchar_label(k)
                           AND ta_calpattr_cal_dc(j) = ta_calpattr_cal_dc(j)
                           AND ta_calpattr_dimgrp_dc(j) = ta_calpattr_dimgrp_dc(j)
                           AND ta_calpattr_end_date(j) = ta_calpattr_end_date(j)
                           AND ta_calpattr_period_num(j) = ta_calpattr_period_num(j)
                           THEN
                          v_duplicate_attr_count := v_duplicate_attr_count + 1;
                        END IF;
                     END LOOP;
                     IF v_duplicate_attr_count > 1 THEN
                           ta_status(j) := 'DUPLICATE_ATTR_ASSIGNMENTS';
                           t_b_status(i) := 'INVALID_MEMBER';
                           t_tl_status(i) := 'INVALID_MEMBER';
                        EXIT; -- member is no good so exit
                     END IF;
                  END IF;
*/
                     -----------------------------------------
                     -- Bug#3822561 Support for attributes of CAL_PERIOD
                     -- if the attribute_dimension_id = 1 (CAL_PERIOD)
                     -- then we construct a CAL_PERIOD_ID from the
                     -- special CALP columns and move it into the
                     -- ta_attribute_assign_value(j)
                     -----------------------------------------
                     IF ta_attribute_dimension_id(j) = 1 THEN
                        get_attr_assign_calp(ta_attribute_assign_value(j)
                                            ,ta_status(j)
                                            ,ta_calpattr_cal_dc(j)
                                            ,ta_calpattr_dimgrp_dc(j)
                                            ,ta_calpattr_end_date(j)
                                            ,ta_calpattr_period_num(j));

                        IF ta_status(j) NOT IN ('LOAD') THEN
                           FEM_ENGINES_PKG.TECH_MESSAGE
                           (c_log_level_1,c_block||'.'||c_proc_name
                           ,'Invalid Member - exiting Attribute loop');

                              t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                           EXIT; -- member is no good so exit
                        END IF;
                     END IF;
                     -----------------------------------------
                        -- BEGIN ATTR VALIDATIONS
                     --    validate version_display_code
                     -----------------------------------------
                     get_attr_version (p_dimension_varchar_label
                                      ,ta_attribute_varchar_label(j)
                                      ,ta_version_display_code(j)
                                      ,ta_version_id(j));

                     -----------------------------------------
                     -- validate attribute_assign_value
                     -----------------------------------------
                     -- VARCHAR_ASSIGN_VALUE
                     IF (ta_attr_value_column_name(j) = 'VARCHAR_ASSIGN_VALUE'
                        AND ta_attribute_assign_value(j) IS NOT NULL
                        AND ta_version_id(j) IS NOT NULL) THEN

                        ta_varchar_assign_value(j)
                           := to_char(ta_attribute_assign_value(j));
                     -- NUMBER_ASSIGN_VALUE
                     ELSIF (ta_attr_value_column_name(j) = 'NUMBER_ASSIGN_VALUE'
                        AND ta_attribute_assign_value(j) IS NOT NULL
                        AND ta_version_id(j) IS NOT NULL) THEN
                        BEGIN
                           ta_number_assign_value(j)
                              := to_number(ta_attribute_assign_value(j));

                           -- Special validation for CAL_PERIOD_NUMBER
                           -- ensures that the GL_PERIOD_NUM attr is identical
                           -- to the value in the CAL_PERIOD_NUMBER column
                           -- in the interface table
                           -- and also must be <= periods_in_year for the
                           -- Time Group Type
                           IF p_dimension_varchar_label = 'CAL_PERIOD' AND
                              ta_attribute_varchar_label(j) = 'GL_PERIOD_NUM' AND
                              ((t_cal_period_number(i) <> ta_number_assign_value(j) OR
                              t_cal_period_number(i) < 1 )) THEN

                              FEM_ENGINES_PKG.TECH_MESSAGE
                              (c_log_level_1,c_block||'.'||c_proc_name||'.period_number'
                              ,ta_number_assign_value(j));

                              RAISE e_invalid_cal_period_number;
                           END IF;

                           -- Special validation for ACCOUNTING_YEAR
                           -- ensures that the ACCOUNTING_YEAR value
                           -- is within the year range supported
                           IF p_dimension_varchar_label = 'CAL_PERIOD' AND
                              ta_attribute_varchar_label(j) = 'ACCOUNTING_YEAR' AND
                              (ta_number_assign_value(j) < 1900 OR
                              ta_number_assign_value(j) >= 2599) THEN
                              RAISE e_invalid_acct_year;
                           END IF;

                        EXCEPTION
                           WHEN e_invalid_cal_period_number THEN
                              ta_status(j) := 'INVALID_GL_PERIOD_NUM';
                              t_b_status(i) := 'INVALID_GL_PERIOD_NUM';
                              t_tl_status(i) := 'INVALID_GL_PERIOD_NUM';

                           WHEN e_invalid_acct_year THEN
                              ta_status(j) := 'INVALID_ACCOUNTING_YEAR';
                              t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                              t_tl_status(i) := 'INVALID_MEMBER';

                           WHEN e_invalid_number THEN
                              ta_status(j) := 'INVALID_NUMBER';
                              t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                              t_tl_status(i) := 'INVALID_MEMBER';

                           WHEN e_invalid_number1722 THEN
                              ta_status(j) := 'INVALID_NUMBER';
                              t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                              t_tl_status(i) := 'INVALID_MEMBER';

                        END;  -- NUMBER_ASSIGN_VALUE
                     -- DATE_ASSIGN_VALUE
                     ELSIF (ta_attr_value_column_name(j) = 'DATE_ASSIGN_VALUE'
                        AND ta_attribute_assign_value(j) IS NOT NULL
                        AND ta_version_id(j) IS NOT NULL) THEN
                        BEGIN
                           FEM_ENGINES_PKG.TECH_MESSAGE
                           (c_log_level_1,c_block||'.'||c_proc_name||'.assigning date'
                           ,ta_attribute_assign_value(j));
                           ta_date_assign_value(j)
                              := to_date(ta_attribute_assign_value(j),p_date_format_mask);

                           FEM_ENGINES_PKG.TECH_MESSAGE
                           (c_log_level_1,c_block||'.'||c_proc_name||'.end assigning date'
                           ,ta_date_assign_value(j));

                           -- Special validations for CAL_PERIOD
                           IF p_dimension_varchar_label = 'CAL_PERIOD' THEN

                              IF ta_attribute_varchar_label(j) = 'CAL_PERIOD_START_DATE' THEN
                                 -- Saving the start_date at the member level so we
                                 -- can compare it later for date overlaps
                                 t_cal_period_start_date(i) := ta_date_assign_value(j);

                                 IF t_cal_period_start_date(i) > t_cal_period_end_date(i) THEN
                                    RAISE e_invalid_calp_start_date;
                                 END IF;

                              END IF;

                              IF ta_attribute_varchar_label(j) = 'CAL_PERIOD_END_DATE' AND
                                 t_cal_period_end_date(i) <> ta_date_assign_value(j) THEN
                                 RAISE e_invalid_cal_period_end_date;
                              END IF;
                              -- Special validation for CAL_PERIOD_START_DATE
                              -- looking for overlap periods in the _ATTR_T table for
                              -- new Cal Periods that the user is trying to load
                              -- We are only checking within our data slice, since
                              -- if the overlap is in a separate data slice, the main
                              -- check on "existing" overlap records will catch it
                              IF ta_attribute_varchar_label(j) = 'CAL_PERIOD_START_DATE' THEN
                              -- query to see if any records exist for the same
                              -- calendar/dimgrp in the ATTR_T interface table
                              -- for the data slice
                              -- where start_date <= x and end_date >= x
                              -- (where x is the new start date)

                              -- First check to see if the new cal period with the new start
                              -- date is an adj. period or not
                              /*********************************************************
                              bug#5060746 - comment out so can convert literals to bind variables
                                 x_adj_period_stmt := 'select count(*)'||
                                 ' from fem_cal_periods_attr_t A1'||
                                 ' where A1.calendar_display_code = '''||t_calendar_dc(i)||''''||
                                 ' and A1.dimension_group_display_code = '''||t_dimension_group_dc(i)||''''||
                                 ' and A1.cal_period_number = '''||t_cal_period_number(i)||''''||
                                 ' and to_char(A1.cal_period_end_date,'''||p_date_format_mask||''')'||
                                 ' = '''||to_char(t_cal_period_end_date(i),p_date_format_mask)||''''||
                                 ' and A1.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                                 ' and A1.attribute_assign_value = ''Y''';
                                ********************************************************/

                                 x_adj_period_stmt := 'select count(*)'||
                                 ' from fem_cal_periods_attr_t A1'||
                                 ' where A1.calendar_display_code = :b_cal_dc'||
                                 ' and A1.dimension_group_display_code = :b_dimgrp_dc'||
                                 ' and A1.cal_period_number = :b_calp_nbr'||
                                 ' and A1.cal_period_end_date'||
                                 ' = :b_calp_end_date'||
                                 ' and A1.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                                 ' and A1.attribute_assign_value = ''Y''';

                                  EXECUTE IMMEDIATE x_adj_period_stmt INTO v_adj_period_count
                                  USING t_calendar_dc(i)
                                       ,t_dimension_group_dc(i)
                                       ,t_cal_period_number(i)
                                       ,t_cal_period_end_date(i);

                                 -- If not an adjustment period, then we need to check for
                                 -- date overlap
                                 IF v_adj_period_count = 0 THEN
                                    t_adj_period_flag(i) := 'N';
                                    -- query to see if any records exist for the same
                                    -- calendar/dimgrp in the offical db
                                    -- (new) array_start_date <= table.end_date AND
                                    -- array_end_date >= table.start_date
                                    -- and the existing members are not adj periods
                                    -- and the existing members are enabled=Y
                                     x_overlap_sql_stmt :=
                                     'select count(*)'||
                                     ' from fem_cal_periods_attr CS, fem_cal_periods_attr CE,'||
                                     ' fem_cal_periods_b C,'||
                                     ' fem_dim_attributes_b AE,'||
                                     ' fem_dim_attr_Versions_b VE,'||
                                     ' fem_cal_periods_attr CP,'||
                                     ' fem_dim_attributes_b AP,'||
                                     ' fem_dim_attr_versions_b VP'||
                                     ' where CS.cal_period_id = C.cal_period_id'||
                                     ' and C.cal_period_id = CP.cal_period_id'||
                                     ' and C.enabled_flag = ''Y'''||
                                     ' and CP.attribute_id = AP.attribute_id'||
                                     ' and CP.version_id = VP.version_id'||
                                     ' and CP.dim_attribute_varchar_member = ''N'''||
                                     ' and AP.dimension_id = 1'||
                                     ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                                     ' and VP.attribute_id = AP.attribute_id'||
                                     ' and VP.default_version_flag = ''Y'''||
                                     ' and VP.aw_snapshot_flag = ''N'''||
                                     ' and C.calendar_id = :b_cal_id'||
                                     ' and C.dimension_group_id = :b_dimgrp_id'||
                                     ' and CS.attribute_id = :b_attr_id'||
                                     ' and CS.version_id = :b_vers_id'||
                                     ' and CS.date_assign_value'||
                                     ' <= :b_new_end_date'||
                                     ' and CS.cal_period_id = CE.cal_period_id'||
                                     ' and CE.attribute_id = AE.attribute_id'||
                                     ' and AE.attribute_varchar_label = ''CAL_PERIOD_END_DATE'''||
                                     ' and CE.version_id = VE.version_id'||
                                     ' and VE.aw_snapshot_flag = ''N'''||
                                     ' and VE.default_version_flag = ''Y'''||
                                     ' and VE.attribute_id = AE.attribute_id'||
                                     ' and CE.date_assign_value'||
                                     ' >= :b_new_start_date';

                                     FEM_ENGINES_PKG.TECH_MESSAGE
                                     (c_log_level_1,c_block||'.'||c_proc_name||'.overlap_sql_stmt3'
                                     ,x_overlap_sql_stmt);

                                     EXECUTE IMMEDIATE x_overlap_sql_stmt INTO v_overlap_count
                                        USING t_calendar_id(i)
                                             ,t_dimension_group_id(i)
                                             ,ta_attribute_id(j)
                                             ,ta_version_id(j)
                                             ,t_cal_period_end_date(i)
                                             ,ta_date_assign_value(j);


                                     /********************************************************
                                     bug#5060746 - comment out so can convert literals to bind variables
                                     x_overlap_sql_stmt :=
                                     'select count(*)'||
                                     ' from fem_cal_periods_attr CS, fem_cal_periods_attr CE,'||
                                     ' fem_cal_periods_b C,'||
                                     ' fem_dim_attributes_b AE,'||
                                     ' fem_dim_attr_Versions_b VE,'||
                                     ' fem_cal_periods_attr CP,'||
                                     ' fem_dim_attributes_b AP,'||
                                     ' fem_dim_attr_versions_b VP'||
                                     ' where CS.cal_period_id = C.cal_period_id'||
                                     ' and C.cal_period_id = CP.cal_period_id'||
                                     ' and C.enabled_flag = ''Y'''||
                                     ' and CP.attribute_id = AP.attribute_id'||
                                     ' and CP.version_id = VP.version_id'||
                                     ' and CP.dim_attribute_varchar_member = ''N'''||
                                     ' and AP.dimension_id = 1'||
                                     ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                                     ' and VP.attribute_id = AP.attribute_id'||
                                     ' and VP.default_version_flag = ''Y'''||
                                     ' and VP.aw_snapshot_flag = ''N'''||
                                     ' and C.calendar_id = '||t_calendar_id(i)||
                                     ' and C.dimension_group_id = '||t_dimension_group_id(i)||
                                     ' and CS.attribute_id = '||ta_attribute_id(j)||
                                     ' and CS.version_id = '||ta_version_id(j)||
                                     ' and CS.date_assign_value'||
                                     ' <= :b_new_end_date'||
                                     ' and CS.cal_period_id = CE.cal_period_id'||
                                     ' and CE.attribute_id = AE.attribute_id'||
                                     ' and AE.attribute_varchar_label = ''CAL_PERIOD_END_DATE'''||
                                     ' and CE.version_id = VE.version_id'||
                                     ' and VE.aw_snapshot_flag = ''N'''||
                                     ' and VE.default_version_flag = ''Y'''||
                                     ' and VE.attribute_id = AE.attribute_id'||
                                     ' and CE.date_assign_value'||
                                     ' >= :b_new_start_date';
                                     **********************************************************/


                                     IF v_overlap_count > 0 THEN
                                        ta_status(j) := 'OVERLAP_EXIST_START_DATE';
                                        t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                        t_tl_status(i) := 'INVALID_MEMBER';
                                     END IF; -- overlap if
                                  /*******************************************************
                                  ELSE  -- query to see if any records exist for the same
                                        -- calendar/dimgrp in the offical db
                                        -- where start_date >= x and start_date <= y
                                        -- (where x is the new start date and
                                        --  y is the new end date)
                                        -- and the exist periods are not adj periods
                                     x_overlap_sql_stmt :=
                                     'select count(*)'||
                                     ' from fem_cal_periods_attr CS,'||
                                     ' fem_cal_periods_b C,'||
                                     ' fem_cal_periods_attr CP,'||
                                     ' fem_dim_attributes_b AP,'||
                                     ' fem_dim_attr_versions_b VP'||
                                     ' where CS.cal_period_id = C.cal_period_id'||
                                     ' and C.cal_period_id = CP.cal_period_id'||
                                     ' and C.enabled_flag = ''Y'''||
                                     ' and CP.attribute_id = AP.attribute_id'||
                                     ' and CP.version_id = VP.version_id'||
                                     ' and CP.dim_attribute_varchar_member = ''N'''||
                                     ' and AP.dimension_id = 1'||
                                     ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                                     ' and VP.attribute_id = AP.attribute_id'||
                                     ' and VP.default_version_flag = ''Y'''||
                                     ' and VP.aw_snapshot_flag = ''N'''||
                                     ' and C.calendar_id = '||t_calendar_id(i)||
                                     ' and C.dimension_group_id = '||t_dimension_group_id(i)||
                                     ' and CS.attribute_id = '||ta_attribute_id(j)||
                                     ' and CS.version_id = '||ta_version_id(j)||
                                     ' and to_char(CS.date_assign_value,'''||p_date_format_mask||''')'||
                                     ' >= '''||to_char(ta_date_assign_value(j),p_date_format_mask)||''''||
                                     ' and to_char(CS.date_assign_value,'''||p_date_format_mask||''')'||
                                     ' <= '''||to_char(t_cal_period_end_date(i),p_date_format_mask)||'''';

                                     FEM_ENGINES_PKG.TECH_MESSAGE
                                      (c_log_level_1,c_block||'.'||c_proc_name||'.overlap_sql_stmt4'
                                      ,x_overlap_sql_stmt);
                                     EXECUTE IMMEDIATE x_overlap_sql_stmt INTO v_overlap_count;

                                     IF v_overlap_count > 0 THEN
                                        ta_status(j) := 'OVERLAP_EXIST_START_DATE';
                                        t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                        t_tl_status(i) := 'INVALID_MEMBER';
                                     END IF;
                                     ***********************************************/
                                  ELSE
                                     t_adj_period_flag(i) := 'Y';
                                  END IF; -- adj_count >0
                               END IF; -- attribute is start_date
                            END IF;  -- special checks for 'CAL_PERIOD' dimension
                           --End Special Checks for CAL Period
                           ----------------------------------------------------------------
                        EXCEPTION
                           WHEN e_invalid_calp_start_date THEN
                              ta_status(j) := 'INVALID_CAL_PERIOD_START_DATE';
                              t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                              t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_cal_period_end_date THEN
                              ta_status(j) := 'INVALID_CAL_PERIOD_END_DATE';
                              t_b_status(i) := 'INVALID_CAL_PERIOD_END_DATE';
                              t_tl_status(i) := 'INVALID_CAL_PERIOD_END_DATE';
                           WHEN e_date_string_too_long THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date_format THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date_numeric THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date_between THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date_year THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           WHEN e_invalid_date_day THEN
                                 ta_status(j) := 'INVALID_DATE';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';

                        END; -- DATE_ASSIGN_VALUE
                     ELSIF (ta_attr_value_column_name(j) IN
                        ('DIM_ATTRIBUTE_VARCHAR_MEMBER', 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
                        AND ta_attribute_assign_value(j) IS NOT NULL
                        AND ta_version_id(j) IS NOT NULL) THEN

                     --------------------------------------------------
                     -- get the Value Set ID for the assigned attribute
                     -- 9/15/2004 RCF Modify this section so that if the
                     -- attr_assign_vs_dc doesn't exist for the specified dimension
                     -- the row fails
                     -- Note that the INVALID_ATTR_ASSIGN_VS status will never
                     -- appear, since the INVALID_DIM_ASSIGNMENT will overwrite it
                     -- in the case of a bad VS being specified for a member
                     --------------------------------------------------
                        IF (ta_attr_assign_vs_dc(j) IS NOT NULL) THEN
                           BEGIN
                              SELECT value_set_id
                              INTO ta_attr_assign_vs_id(j)
                              FROM fem_value_sets_b
                              WHERE value_set_display_code = ta_attr_assign_vs_dc(j)
                              AND dimension_id = ta_attribute_dimension_id(j);
                           EXCEPTION
                              WHEN no_data_found THEN
                                 ta_status(j) := 'INVALID_ATTR_ASSIGN_VALUE_SET';
                                 t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                                 t_tl_status(i) := 'INVALID_MEMBER';
                           END;
                        END IF;

                        verify_attr_member (ta_attribute_varchar_label(j)
                                           ,p_dimension_varchar_label
     		                        ,ta_attribute_assign_value(j)
	                                ,ta_attr_assign_vs_dc(j)
	                                ,v_attr_success
	                                ,v_temp_member);
                        FEM_ENGINES_PKG.TECH_MESSAGE
                        (c_log_level_1,c_block||'.'||c_proc_name||'.verify_attribute_success'
                        ,v_attr_success);

                        IF (v_attr_success = 'N') THEN
                           ta_status(j) := 'INVALID_DIM_ASSIGNMENT';
                           t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                        ELSIF (v_attr_success = 'MISSING_ATTR_ASSIGN_VS') THEN
                           ta_status(j) := 'MISSING_ATTR_ASSIGN_VS';
                           t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                        ELSE -- DIM Assignment is good
                           IF (ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_VARCHAR_MEMBER') THEN
                              ta_dim_attr_varchar_member(j) := to_char(v_temp_member);
                           ELSE
                              ta_dim_attr_numeric_member(j) := to_number(v_temp_member);
                           END IF; -- Choice between VARCHAR and NUMERIC Dim members
                        END IF;  -- attr_req=Y and success=N
                     ELSIF (ta_member_dc(j) IS NULL) THEN
                           ta_status(j) := 'INVALID_MEMBER';
                           t_b_status(i) := 'MISSING_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                     ELSIF (ta_version_id(j) IS NULL) THEN-- Version is NULL
                           ta_status(j) := 'INVALID_VERSION';
                           t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                     ELSE -- Assignment is NULL or Assignment Column not valid
                           ta_status(j) := 'INVALID_ATTRIBUTE_ASSIGNMENT';
                           t_b_status(i) := 'INVALID_REQUIRED_ATTRIBUTE';
                           t_tl_status(i) := 'INVALID_MEMBER';
                     END IF; -- Main IF on validating the attributes

                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_status'
                     ,ta_status(j));
                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name||'.member_status'
                     ,t_b_status(i));

                     IF (t_b_status(i) NOT IN ('LOAD')) THEN
                        FEM_ENGINES_PKG.TECH_MESSAGE
                        (c_log_level_1,c_block||'.'||c_proc_name
                        ,'Invalid Member - exiting Attribute loop');

                        EXIT; -- member is no good so exit
                     END IF;
                  END LOOP; -- attribute validations
                  END IF;  -- If v_attr_last_row = v_req_attribute_count
                  --------------------------------------------------------------------
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.member status'
                  ,t_b_status(i));

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.tl_member status'
                  ,t_tl_status(i));

                  IF (t_b_status(i) NOT IN ('LOAD')) THEN
                     FEM_ENGINES_PKG.TECH_MESSAGE
                     (c_log_level_1,c_block||'.'||c_proc_name
                     ,'Invalid Member - Reset all attributes of the member to INVALID_MEMBER');

                     FOR k IN 1..v_attr_last_row
                     LOOP
                        IF (ta_status(k) = 'LOAD') THEN
                           ta_status(k) := 'INVALID_MEMBER';
                        END IF;
                     END LOOP;
                  END IF;

                  -----------------------------------------------------------------
                  -- Copy ATTR Collection for good members in prep for insert later
                  -----------------------------------------------------------------
                  IF (t_b_status(i) = 'LOAD') THEN

                     v_attr_count := 1;
                     WHILE v_attr_count <= v_attr_last_row
                     LOOP
                        IF (ta_status(v_attr_count) = 'LOAD') THEN
                           v_attr_final_count := v_attr_final_count + 1;

                           tfa_rowid(v_attr_final_count) := ta_rowid(v_attr_count);
                           tfa_attribute_id(v_attr_final_count) := ta_attribute_id(v_attr_count);
                           tfa_member_dc(v_attr_final_count) := ta_member_dc(v_attr_count);
                           tfa_value_set_dc(v_attr_final_count) := ta_value_set_dc(v_attr_count);
                           tfa_dim_attr_numeric_member(v_attr_final_count) := ta_dim_attr_numeric_member(v_attr_count);
                           tfa_dim_attr_varchar_member(v_attr_final_count) := ta_dim_attr_varchar_member(v_attr_count);
                           tfa_number_assign_value(v_attr_final_count) := ta_number_assign_value(v_attr_count);
                           tfa_varchar_assign_value(v_attr_final_count) := ta_varchar_assign_value(v_attr_count);
                           tfa_date_assign_value(v_attr_final_count) := ta_date_assign_value(v_attr_count);
                           tfa_version_id(v_attr_final_count) := ta_version_id(v_attr_count);
                           tfa_attr_assign_vs_id(v_attr_final_count) := ta_attr_assign_vs_id(v_attr_count);
                           tfa_status(v_attr_final_count) := ta_status(v_attr_count);
                           tfa_attribute_varchar_label(v_attr_final_count) := ta_attribute_varchar_label(v_attr_count);


                        END IF; -- Copy ATTR for good members

                        v_attr_count    := v_attr_count + 1;
                     END LOOP;
                  ELSE
                     ----------------------------------------------------------
                     -- Count the error rows
                     ----------------------------------------------------------
                     v_temp_rows_rejected := v_temp_rows_rejected + v_attr_last_row;

                  END IF; -- Copy good members and ATTR

                  ----------------------------------------------------------
                  -- Update Status of ATTR Collection for failed records
                  ----------------------------------------------------------
                  FORALL i IN 1..v_attr_last_row
                     EXECUTE IMMEDIATE x_update_attr_status_stmt
                     USING ta_status(i)
                          ,ta_rowid(i)
                          ,ta_status(i);

                  --------------------------------------------
                  -- Delete ATTR Collection for Next Bulk Fetch --
                  --------------------------------------------
                  ta_rowid.DELETE;
                  ta_member_read_only_flag.DELETE;
                  ta_attribute_id.DELETE;
                  ta_attribute_varchar_label.DELETE;
                  ta_attribute_dimension_id.DELETE;
                  ta_attr_value_column_name.DELETE;
                  ta_attribute_data_type_code.DELETE;
                  ta_attribute_required_flag.DELETE;
                  ta_read_only_flag.DELETE;
                  ta_allow_mult_versions_flag.DELETE;
                  ta_allow_mult_assign_flag.DELETE;
                  ta_member_dc.DELETE;
                  ta_value_set_dc.DELETE;
                  ta_attribute_assign_value.DELETE;
                  ta_dim_attr_numeric_member.DELETE;
                  ta_dim_attr_varchar_member.DELETE;
                  ta_number_assign_value.DELETE;
                  ta_varchar_assign_value.DELETE;
                  ta_date_assign_value.DELETE;
                  ta_version_display_code.DELETE;
                  ta_version_id.DELETE;
                  ta_language.DELETE;
                  ta_attr_assign_vs_dc.DELETE;
                  ta_attr_assign_vs_id.DELETE;
                  ta_status.DELETE;
                  ta_use_interim_table_flag.DELETE;
                  ta_calpattr_cal_dc.DELETE;
                  ta_calpattr_dimgrp_dc.DELETE;
                  ta_calpattr_end_date.DELETE;
                  ta_calpattr_period_num.DELETE;


                  CLOSE cv_get_attr_rows;
             END IF; -- t_b_status(i) = 'LOAD'
            END IF; -- Simple Dimension Flag = N
         END LOOP;  -- Begin Validations


         -----------------------------------------------------------------
         -- Copy Member Collection for good members in prep for insert later
         -----------------------------------------------------------------
         v_mbr_last_row := t_member_dc.LAST;
         v_mbr_count := 1;

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.before copy good members',
         v_mbr_last_row);


         ----------------------------------------------------------
         -- Count the attribute error rows
         ----------------------------------------------------------
         v_rows_rejected := v_rows_rejected + v_temp_rows_rejected;
         v_temp_rows_rejected := 0;  -- initialize so we can use again
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr error rows',
         v_rows_rejected);

         WHILE v_mbr_count <= v_mbr_last_row
            LOOP
               IF (t_b_status(v_mbr_count) = 'LOAD') THEN
            /************************************
            Commenting out Array Date Overlap checks per bug#4030717
            Date Overlap checks within the load are now handled in the
            FEM_CALP_INTERIM_T and FEM_CALP_ATTR_INTERIM_T tables
            so that we can use MP for CAL_PERIOD loads
            ______________________________________________________

            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name
             ,'Start Overlap Check - t_b_status = '||t_b_status(v_mbr_count));


            -- perform date overlap checks
            -- cycle thru every member in the array to look for
            -- date overlaps
               v_mbr_subcount := v_mbr_count + 1;  -- we always start checking
                                               -- for date overlaps starting one
                                               -- member below our current position
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name
             ,'Overlap Check - v_mbr_count = '||v_mbr_count);

               IF p_dimension_varchar_label = 'CAL_PERIOD'
                AND p_load_type NOT IN ('DIMENSION_GROUP')
                AND t_b_status(v_mbr_count) = 'LOAD'
                AND t_adj_period_flag(v_mbr_count) = 'N' THEN

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check inside CAL_PERIOD = ');

                  WHILE v_mbr_subcount <= v_mbr_last_row AND t_b_status(v_mbr_count) = 'LOAD'
                  LOOP

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check - sub start_date = '||t_cal_period_start_date(v_mbr_subcount));

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check - start_date = '||t_cal_period_start_date(v_mbr_count));

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check - sub end_date = '||t_cal_period_end_date(v_mbr_subcount));

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check - end_date = '||t_cal_period_end_date(v_mbr_count));

               FEM_ENGINES_PKG.TECH_MESSAGE
                (c_log_level_1,c_block||'.'||c_proc_name
                ,'Overlap Check - sub adj_flag = '||t_adj_period_flag(v_mbr_subcount));

                    IF t_adj_period_flag(v_mbr_subcount) = 'N'
                       AND ((t_cal_period_start_date(v_mbr_subcount) <=
                        t_cal_period_start_date(v_mbr_count)
                       AND t_cal_period_end_date(v_mbr_subcount) >=
                           t_cal_period_start_date(v_mbr_count))
                       OR (t_cal_period_start_date(v_mbr_subcount) >=
                           t_cal_period_start_date(v_mbr_count)
                       AND t_cal_period_start_date(v_mbr_subcount) <=
                           t_cal_period_end_date(v_mbr_count)))
                    THEN
                       v_attr_last_row := NVL(tfa_attribute_id.LAST,0);
                       v_attr_count := 0;
                       FEM_ENGINES_PKG.TECH_MESSAGE
                        (c_log_level_1,c_block||'.'||c_proc_name
                        ,'Overlap Member - Reset all attributes of the member to INVALID_MEMBER');

                       FOR k IN 1..v_attr_last_row
                       LOOP
                          IF ((tfa_member_dc(k) = t_member_dc(v_mbr_count) OR
                               tfa_member_dc(k) = t_member_dc(v_mbr_subcount))) AND
                             (tfa_attribute_varchar_label(k) = 'CAL_PERIOD_START_DATE') AND
                              tfa_status(k) = 'LOAD' THEN
                             tfa_status(k) := 'OVERLAP_START_DATE_IN_LOAD';
                             v_rows_rejected := v_rows_rejected + 1;
                          ELSIF ((tfa_member_dc(k) = t_member_dc(v_mbr_count) OR
                                  tfa_member_dc(k) = t_member_dc(v_mbr_subcount))) AND
                             (tfa_attribute_varchar_label(k) NOT IN ('CAL_PERIOD_START_DATE')) AND
                             tfa_status(k) = 'LOAD' THEN
                             tfa_status(k) := 'INVALID_MEMBER';
                             v_rows_rejected := v_rows_rejected + 1;
                          END IF;
                       END LOOP;
                       t_tl_status(v_mbr_count) := 'INVALID_MEMBER';
                       t_b_status(v_mbr_count) := 'INVALID_REQUIRED_ATTRIBUTE';
                       t_tl_status(v_mbr_subcount) := 'INVALID_MEMBER';
                       t_b_status(v_mbr_subcount) := 'INVALID_REQUIRED_ATTRIBUTE';
                    END IF; -- overlap checking
                    v_mbr_subcount    := v_mbr_subcount + 1;
                    END LOOP;
                 END IF; -- CAL_PERIOD and not a dimension group load

               IF (t_b_status(v_mbr_count) = 'LOAD') THEN
               -- end commented out Array date overlap check
               */
               ------------------------------------------------------------

                  -- if the member is still in LOAD status, we copy it to the final array
                     v_mbr_final_count := v_mbr_final_count + 1;

                     IF (p_load_type = 'DIMENSION_GROUP') THEN
                        SELECT fem_dimension_grps_b_s.nextval
                        INTO tf_dimgrp_dimension_group_id(v_mbr_final_count)
                        FROM dual;

                        SELECT fem_time_dimension_group_key_s.nextval
                        INTO tf_time_dimension_group_key(v_mbr_final_count)
                        FROM dual;

                        tf_time_group_type_code(v_mbr_final_count) :=t_time_group_type_code(v_mbr_count);
                        tf_dimension_group_seq(v_mbr_final_count) :=t_dimension_group_seq(v_mbr_count);

                     END IF;
                       FEM_ENGINES_PKG.TECH_MESSAGE
                         (c_log_level_1,c_block||'.'||c_proc_name||'.In the copy',
                          null);


                     tf_rowid(v_mbr_final_count) := t_rowid(v_mbr_count);
                     tf_tl_rowid(v_mbr_final_count) := t_tl_rowid(v_mbr_count);
                     tf_member_dc(v_mbr_final_count) := t_member_dc(v_mbr_count);
                     tf_calendar_id(v_mbr_final_count) := t_calendar_id(v_mbr_count);
                     tf_cal_period_end_date(v_mbr_final_count) := t_cal_period_end_date(v_mbr_count);
                     tf_cal_period_number(v_mbr_final_count) := t_cal_period_number(v_mbr_count);
                     tf_value_set_id(v_mbr_final_count) := t_value_set_id(v_mbr_count);
                     tf_dimension_group_id(v_mbr_final_count) := t_dimension_group_id(v_mbr_count);
                     tf_member_name(v_mbr_final_count) := t_member_name(v_mbr_count);
                     tf_member_desc(v_mbr_final_count) := t_member_desc(v_mbr_count);
                     tf_language(v_mbr_final_count) := t_language(v_mbr_count);
                     tf_status(v_mbr_final_count) := t_b_status(v_mbr_count);
                     tf_dimension_id(v_mbr_final_count) := p_dimension_id;
                     tf_calendar_dc(v_mbr_final_count) := t_calendar_dc(v_mbr_count);
                     tf_dimension_group_dc(v_mbr_final_count) := t_dimension_group_dc(v_mbr_count);
                     tf_cal_period_start_date(v_mbr_final_count) := t_cal_period_start_date(v_mbr_count);
                     tf_adj_period_flag(v_mbr_final_count) := t_adj_period_flag(v_mbr_count);


               /*
               Commented out Array Date Overlap checks per bug#4030717
               ELSE
                  -- count the error members
                  -- we add 2 because every new member always has 1 B_T record
                  -- and a TL_T record
                  v_temp_rows_rejected := v_temp_rows_rejected + 2;
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected',
                   v_temp_rows_rejected);

               END IF; -- Copy good members
               ***************/
               ELSE
                  -- count the error members
                  -- we add 2 because every new member always has 1 B_T record
                  -- and a TL_T record
                  v_temp_rows_rejected := v_temp_rows_rejected + 2;
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected',
                   v_temp_rows_rejected);

               END IF;  -- status = LOAD
            v_mbr_count    := v_mbr_count + 1;
            END LOOP;

------------------------------------------------------------------------
--  INSERTING
------------------------------------------------------------------------
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_3,c_block||'.'||c_proc_name||'.Member_Insert',
             null);

            ---------------------------------------------------------
            -- set the v_final_mbr_last_row in case a member was removed
            ---------------------------------------------------------
            v_final_mbr_last_row := tf_member_dc.LAST;
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_3,c_block||'.'||c_proc_name||'.v_attr_final_count',
            v_final_mbr_last_row);


            IF (v_final_mbr_last_row IS NULL) THEN
               v_final_mbr_last_row := 0;
            ELSIF v_final_mbr_last_row >0 THEN
               v_rows_loaded := v_rows_loaded + v_final_mbr_last_row;
            END IF;
            ---------------------------------------------------------
            -- Call table handler for the remaining good members
            ---------------------------------------------------------
            IF (p_load_type = 'DIMENSION_GROUP') THEN
               FORALL i IN 1..v_final_mbr_last_row
                  EXECUTE IMMEDIATE x_insert_member_stmt
                  USING tf_member_dc(i)
                       ,tf_member_name(i)
                       ,tf_member_desc(i)
                       ,gv_apps_user_id
                       ,gv_apps_user_id
                       ,tf_time_dimension_group_key(i)
                       ,tf_dimension_group_seq(i)
                       ,tf_time_group_type_code(i)
                       ,tf_dimgrp_dimension_group_id(i)
                       ,tf_dimension_id(i);

            END IF;
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update member status.p_value_set_req_flag'
         ,p_value_set_required_flag);

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update member status.p_hier_dim_flag'
         ,p_hier_dimension_flag);


         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update member status.gv_apps_user_id'
         ,gv_apps_user_id);

            IF (p_load_type = 'DIMENSION_MEMBER') THEN
               IF (p_value_set_required_flag = 'Y'
                   AND p_hier_dimension_flag = 'Y') THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update member status.in the forall'
         ,null);

                  FORALL i IN 1..v_final_mbr_last_row
                     EXECUTE IMMEDIATE x_insert_member_stmt
                     USING tf_value_set_id(i)
                          ,tf_dimension_group_id(i)
                          ,tf_member_dc(i)
                          ,tf_member_name(i)
                          ,tf_member_desc(i)
                          ,gv_apps_user_id
                          ,gv_apps_user_id;
               ELSIF (p_value_set_required_flag = 'Y'
                   AND p_hier_dimension_flag = 'N') THEN
                  FORALL i IN 1..v_final_mbr_last_row
                     EXECUTE IMMEDIATE x_insert_member_stmt
                     USING tf_value_set_id(i)
                          ,tf_member_dc(i)
                          ,tf_member_name(i)
                          ,tf_member_desc(i)
                          ,gv_apps_user_id
                          ,gv_apps_user_id;
               ELSIF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
                  -- Members for the CAL_PERIOD dimensions are inserted into an
                  -- Interim table for further processing
                  FORALL i IN 1 .. v_final_mbr_last_row
                     EXECUTE IMMEDIATE x_calp_interim_stmt
                     USING tf_cal_period_end_date(i)
                     ,tf_cal_period_number(i)
                     ,tf_calendar_dc(i)
                     ,tf_dimension_group_dc(i)
                     ,tf_cal_period_start_date(i)
                     ,tf_member_dc(i)
                     ,tf_dimension_group_id(i)
                     ,tf_calendar_id(i)
                     ,tf_member_name(i)
                     ,tf_member_desc(i)
                     ,tf_adj_period_flag(i)
                     ,'Y' -- use_interim_table_flag
                     ,'LOAD';


               /**********************************
               Commented out per bug#4030717
               This statement is replaced with an insert into the
               CAL_PERIOD INTERIM tables.
               FORALL i IN 1..v_final_mbr_last_row
                  EXECUTE IMMEDIATE x_insert_member_stmt
                  USING tf_cal_period_end_date(i)
                       ,tf_cal_period_number(i)
                       ,tf_calendar_id(i)
                       ,tf_dimension_group_id(i)
                       ,tf_member_name(i)
                       ,tf_member_desc(i);
                       ************************/
               ELSIF (p_value_set_required_flag = 'N'
                   AND p_hier_dimension_flag = 'Y') THEN
                  FORALL i IN 1..v_final_mbr_last_row
                     EXECUTE IMMEDIATE x_insert_member_stmt
                     USING tf_dimension_group_id(i)
                          ,tf_member_dc(i)
                          ,tf_member_name(i)
                          ,tf_member_desc(i)
                          ,gv_apps_user_id
                          ,gv_apps_user_id;
               ELSE
                  FORALL i IN 1..v_final_mbr_last_row
                     EXECUTE IMMEDIATE x_insert_member_stmt
                     USING tf_member_dc(i)
                          ,tf_member_name(i)
                          ,tf_member_desc(i)
                          ,gv_apps_user_id
                          ,gv_apps_user_id;

               END IF;  -- checking the p_dimenson_varchar_label
            END IF; -- Load_Type = Dimension Member

            ----------------------------------------------------------
            -- Count the member loaded and error rows
            ----------------------------------------------------------
            --x_rows_loaded   := x_rows_loaded + v_mbr_last_row;
            v_rows_rejected := v_rows_rejected + v_temp_rows_rejected;
            v_temp_rows_rejected := 0;

            ---------------------------------------------------------
            -- Insert attributes for the good dimension members
            ---------------------------------------------------------
            IF (p_value_set_required_flag = 'Y') THEN
               FORALL i IN 1..v_attr_final_count
                  EXECUTE IMMEDIATE x_insert_attr_stmt
                  USING tfa_attribute_id(i)
                       ,tfa_version_id(i)
                       ,tfa_dim_attr_numeric_member(i)
                       ,tfa_attr_assign_vs_id(i)
                       ,tfa_dim_attr_varchar_member(i)
                       ,tfa_number_assign_value(i)
                       ,tfa_varchar_assign_value(i)
                       ,tfa_date_assign_value(i)
                       ,gv_apps_user_id
                       ,gv_apps_user_id
                       ,tfa_member_dc(i)
                       ,tfa_value_set_dc(i)
                       ,tfa_status(i);
            ELSIF (p_value_set_required_flag = 'N') AND
                   (p_dimension_varchar_label NOT IN ('CAL_PERIOD')) THEN
                FORALL i IN 1..v_attr_final_count
                  EXECUTE IMMEDIATE x_insert_attr_stmt
                  USING tfa_attribute_id(i)
                       ,tfa_version_id(i)
                       ,tfa_dim_attr_numeric_member(i)
                       ,tfa_attr_assign_vs_id(i)
                       ,tfa_dim_attr_varchar_member(i)
                       ,tfa_number_assign_value(i)
                       ,tfa_varchar_assign_value(i)
                       ,tfa_date_assign_value(i)
                       ,gv_apps_user_id
                       ,gv_apps_user_id
                       ,tfa_member_dc(i)
                       ,tfa_status(i);
            ELSIF p_dimension_varchar_label = 'CAL_PERIOD' THEN
                FORALL i IN 1..v_attr_final_count
                  EXECUTE IMMEDIATE x_calp_attr_interim_stmt
                  USING tfa_member_dc(i)
                       ,tfa_attribute_id(i)
                       ,tfa_version_id(i)
                       ,tfa_dim_attr_numeric_member(i)
                       ,tfa_attr_assign_vs_id(i)
                       ,tfa_dim_attr_varchar_member(i)
                       ,tfa_number_assign_value(i)
                       ,tfa_varchar_assign_value(i)
                       ,tfa_date_assign_value(i)
                       ,'Y' -- use_interim_table_flag
                       ,'LOAD';
            END IF;
         ----------------------------------------------------------
         -- Count the attribute rows loaded
         ----------------------------------------------------------
         --x_rows_loaded := x_rows_loaded + v_attr_final_count;

-----------------------------------------------------------------------------------------

         ----------------------------------------------------------
         -- Update Status of Member Collection for failed records
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_mbr_status_stmt
            USING t_b_status(i)
                 ,t_rowid(i)
                 ,t_b_status(i);
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update member status.v_mbr_last_row'
         ,v_mbr_last_row);

         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_tl_status_stmt
            USING t_tl_status(i)
                 ,t_tl_rowid(i)
                 ,t_tl_status(i);

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.update tl status.v_mbr_last_row'
         ,v_mbr_last_row);


      /************************************
      Commenting out Array Date Overlap per bug#4030717
      --------------------------------------------------------------------
      -- Update Status of ATTR Final Collection for failed overlap records
      --------------------------------------------------------------------
      FORALL i IN 1..v_attr_final_count
         EXECUTE IMMEDIATE x_update_attr_status_stmt
         USING tfa_status(i)
              ,tfa_rowid(i)
              ,tfa_status(i);
      **********************************************************************/

         ----------------------------------------------------------
         -- Update Status of dependent ATTR records for bad members
         ----------------------------------------------------------
         IF (p_load_type NOT IN ('DIMENSION_GROUP') AND p_simple_dimension_flag = 'N') THEN

/* 9/14/2004  RCF Commenting this out because this update is already handled
              in the attr_update step for bad_versions and bad_members

         IF (p_value_set_required_flag = 'Y') THEN
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_update_dep_attr_status_stmt
               USING t_member_dc(i)
                    ,t_value_set_dc(i)
                    ,t_b_status(i);

         ELSIF (p_dimension_varchar_label = 'CAL_PERIOD') THEN

            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_update_dep_attr_status_stmt
               USING t_calendar_dc(i)
                    ,t_dimension_group_dc(i)
                    ,t_cal_period_end_date(i)
                    ,t_cal_period_number(i)
                    ,t_b_status(i);
         END IF;  */

         ----------------------------------------------------------------
         -- Delete Loaded records and clear Collections for Next Bulk Fetch
         ----------------------------------------------------------------
            ---------------------------------------------------------
            -- Delete Loaded attribute records from the _ATTR_T table
            -- exception:  CAL_PERIOD loads
            -- Interface rows for CAL_PERIOD loads not deleted at this time since we
            -- have not yet completed the date overlap checks in the Interim table
            ---------------------------------------------------------
            IF p_dimension_varchar_label NOT IN ('CAL_PERIOD') THEN
               FORALL i IN 1..v_attr_final_count
                  EXECUTE IMMEDIATE x_delete_attr_stmt
                  USING tfa_rowid(i)
                       ,tfa_status(i)
                       ,'N'; -- use_interim_table_flag
            END IF;

            --------------------------------------------
            -- Delete ATTR Collection for Next Bulk Fetch
            --------------------------------------------
            tfa_rowid.DELETE;
            tfa_attribute_id.DELETE;
            tfa_attribute_varchar_label.DELETE;
            tfa_member_dc.DELETE;
            tfa_value_set_dc.DELETE;
            tfa_dim_attr_numeric_member.DELETE;
            tfa_dim_attr_varchar_member.DELETE;
            tfa_number_assign_value.DELETE;
            tfa_varchar_assign_value.DELETE;
            tfa_date_assign_value.DELETE;
            tfa_version_id.DELETE;
            tfa_attr_assign_vs_id.DELETE;
            tfa_status.DELETE;
         END IF; -- load_type not Dimension Group and Simple dimension_flag='N'

         ---------------------------------------------------------
         -- Delete Loaded member records from the _B_T and _TL_T tables
         -- exception:  CAL_PERIOD Member loads
         -- Interface rows for CAL_PERIOD loads not deleted at this time since we
         -- have not yet completed the date overlap checks in the Interim table
         ---------------------------------------------------------
         IF p_dimension_varchar_label NOT IN ('CAL_PERIOD') AND
            p_load_type NOT IN ('DIMENSION_GROUP') THEN
            FORALL i IN 1..v_mbr_final_count
               EXECUTE IMMEDIATE x_delete_mbr_stmt
               USING tf_rowid(i)
                    ,tf_status(i)
                    ,'N'; -- use_interim_table_flag

            FORALL i IN 1..v_mbr_final_count
               EXECUTE IMMEDIATE x_delete_tl_stmt
               USING tf_tl_rowid(i)
                    ,tf_status(i)
                    ,'N'; -- use_interim_table_flag
         END IF;


         tf_rowid.DELETE;
         tf_tl_rowid.DELETE;
         tf_member_dc.DELETE;
         tf_calendar_id.DELETE;
         tf_cal_period_end_date.DELETE;
         tf_cal_period_number.DELETE;
         tf_value_set_id.DELETE;
         tf_dimension_group_id.DELETE;
         tf_member_name.DELETE;
         tf_member_desc.DELETE;
         tf_language.DELETE;
         tf_status.DELETE;
         tf_dimension_group_seq.DELETE;
         tf_time_group_type_code.DELETE;
         tf_time_dimension_group_key.DELETE;
         tf_calendar_dc.DELETE;
         tf_dimension_group_dc.DELETE;
         tf_cal_period_start_date.DELETE;
         tf_adj_period_flag.DELETE;

         t_rowid.DELETE;
         t_tl_rowid.DELETE;
         t_member_dc.DELETE;
         t_calendar_dc.DELETE;
         t_calendar_id.DELETE;
         t_cal_period_end_date.DELETE;
         t_cal_period_start_date.DELETE;
         t_cal_period_number.DELETE;
         t_value_set_dc.DELETE;
         t_value_set_id.DELETE;
         t_dimension_group_dc.DELETE;
         t_dimension_group_id.DELETE;
         t_b_status.DELETE;
         t_member_name.DELETE;
         t_member_desc.DELETE;
         t_language.DELETE;
         t_tl_status.DELETE;
         t_dimension_group_seq.DELETE;
         t_time_group_type_code.DELETE;
   --      t_periods_in_year.DELETE;
         t_adj_period_flag.DELETE;

         v_attr_final_count := 0;
         v_attr_count       := 0;
         v_mbr_last_row     := 0;
         v_mbr_count        := 0;
         v_mbr_final_count  := 0;


                   COMMIT;
      END LOOP;  -- New Members

   IF p_load_type <> ('DIMENSION_GROUP') THEN
      FEM_Multi_Proc_Pkg.Post_Data_Slice(
        p_req_id => p_master_request_id,
        p_slc_id => v_slc_id,
        p_status => v_mp_status,
        p_message => v_mp_message,
        p_rows_processed => 0,
        p_rows_loaded => v_rows_loaded,
        p_rows_rejected => v_rows_rejected);
    END IF;

   END LOOP; -- get data slice

   IF p_load_type = ('DIMENSION_GROUP') THEN
      gv_dimgrp_rows_rejected := gv_dimgrp_rows_rejected + v_rows_rejected;
   END IF;

   IF cv_get_rows%ISOPEN THEN CLOSE cv_get_rows;
   END IF;
   --x_rows_rejected := v_rows_rejected;
   --x_rows_loaded := v_rows_loaded;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_rows%ISOPEN THEN
            CLOSE cv_get_rows;
         END IF;
         IF cv_get_attr_rows%ISOPEN THEN
            CLOSE cv_get_attr_rows;
         END IF;

         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
          ,P_TOKEN1 => 'ERR_MSG'
          ,P_VALUE1 => gv_prg_msg);

        -- FEM_ENGINES_PKG.USER_MESSAGE
         -- (p_app_name => c_fem
         -- ,p_msg_text => gv_prg_msg);

         RAISE e_main_terminate;

END New_Members;

/*===========================================================================+
 | PROCEDURE
 |              TL_Update
 |
 | DESCRIPTION
 |   This step updates the translatable names and descriptions for existing
 |   Dimension members.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 |   1.	Other language rows in FEM are updated for the member if they exist.
 |   2.	Delete any TL rows that are successfully updated.
 |
 |   Update Base (Dimension Group and Simple Dim = 'N' only)
 |   Note:  This module only performs error checks.  It does not perform any updates.
 |          Therefore, the Base status will remain unchanged, unless
 |          there is something invalid about one of the values in a base columns, in which
 |          case the Base Update module identifies the error and updates the status
 |   1.	Base columns for the member or Group are updated for any base records in
 |      the _B_T table.  This update only occurs if the member exists in FEM.
 |   2.	Delete any _B_T records that are successful.
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   8-MAR-04  Created
 |    Rob Flippo  10-MAR-06  Bug#5068022 add error checking to identify
 |                           translatable names in the TL_T table that
 |                           already exist in the target TL table for
 |                           other members
 |    Rob Flippo 04-APR-06  Bug#5117594 Remove unique name check for Customer
 |                          dimension
 |  Rob Flippo  04-AUG-06  Bug 5060746 Change literals to bind variables wherever possible
 |  Rob Flippo 15-MAR-07  Bug#5905501 Modify execute immediate on tl_update
 |                        to pass in the source_lang = language
 +===========================================================================*/

PROCEDURE TL_Update (p_eng_sql IN VARCHAR2
                    ,p_data_slc IN VARCHAR2
                    ,p_proc_num IN VARCHAR2
                    ,p_partition_code IN NUMBER
                    ,p_fetch_limit IN NUMBER
                    ,p_load_type IN VARCHAR2
                    ,p_dimension_varchar_label IN VARCHAR2
                    ,p_dimension_id IN VARCHAR2
                    ,p_target_b_table IN VARCHAR2
                    ,p_target_tl_table IN VARCHAR2
                    ,p_source_b_table IN VARCHAR2
                    ,p_source_tl_table IN VARCHAR2
                    ,p_member_col IN VARCHAR2
                    ,p_member_dc_col IN VARCHAR2
                    ,p_member_name_col IN VARCHAR2
                    ,p_member_t_dc_col IN VARCHAR2
                    ,p_member_t_name_col IN VARCHAR2
                    ,p_member_description_col IN VARCHAR2
                    ,p_value_set_required_flag IN VARCHAR2
                    ,p_simple_dimension_flag IN VARCHAR2
                    ,p_shared_dimension_flag IN VARCHAR2
                    ,p_hier_dimension_flag IN VARCHAR2
                    ,p_exec_mode_clause IN VARCHAR2
                    ,p_master_request_id IN NUMBER)

IS
-- Constants
   c_proc_name VARCHAR2(30) := 'TL_Update';

-- Dynamic SQL statement variables
   x_bad_tl_select_stmt              VARCHAR2(4000);
   x_select_stmt                     VARCHAR2(4000);
   x_update_stmt                     VARCHAR2(4000);
   x_update_tl_stmt                  VARCHAR2(4000);
   x_update_tl_status_stmt           VARCHAR2(4000);
   x_delete_tl_stmt                  VARCHAR2(4000);
   x_bad_lang_upd_stmt               VARCHAR2(4000);
   x_ro_mbr_upd_stmt                 VARCHAR2(4000);
   x_dupname_count_stmt              VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_mbr_last_row                    NUMBER;
   v_temp_rows_rejected              NUMBER :=0;
   v_rows_rejected                   NUMBER :=0;
   v_rows_fetched                    NUMBER :=0;
   v_bulk_rows_rejected              NUMBER; -- rejected row count for any status bulk
                                             -- update statements


-- Other variables
   v_fetch_limit                     NUMBER;
   v_dupname_count                   NUMBER :=0;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   t_rowid                           rowid_type;
   t_tl_rowid                        rowid_type;
   t_value_set_id                    number_type;
   t_dimension_group_id              number_type;
   t_calendar_id                     number_type;
   t_cal_period_number               number_type;
   t_cal_period_end_date             date_type;
   t_b_status                        varchar2_std_type;
   t_tl_status                       varchar2_std_type;
   t_member_dc                       varchar2_150_type;
   t_calendar_dc                     varchar2_150_type;
   t_value_set_dc                    varchar2_150_type;
   t_dimension_group_dc              varchar2_150_type;
   t_member_name                     varchar2_150_type;
   t_member_desc                     desc_type;
   t_language                        lang_type;
   t_dimension_group_seq             number_type;
   t_time_group_type_code            varchar2_std_type;

---------------------
-- Declare cursors --
---------------------
   cv_get_rows           cv_curs;

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   --x_status := 0; -- initialize status of the TL_Update procedure
   --x_message := 'COMPLETE:NORMAL';

   -- Build Update for the _TL_T table where the LANGUAGE is not installed
   build_bad_lang_upd_stmt  (p_load_type
                            ,p_dimension_varchar_label
                            ,p_dimension_id
                            ,p_source_tl_table
                            ,p_exec_mode_clause
                            ,p_shared_dimension_flag
                            ,p_value_set_required_flag
                            ,x_bad_lang_upd_stmt);
   IF p_data_slc IS NOT NULL THEN
      x_bad_lang_upd_stmt := REPLACE(x_bad_lang_upd_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_bad_lang_upd_stmt := REPLACE(x_bad_lang_upd_stmt,'{{data_slice}}','1=1');
   END IF;

   -- Build Update for the _TL_T table where
   -- the member is a read_only_member
   build_tl_ro_mbr_upd_stmt  (p_load_type
                            ,p_dimension_varchar_label
                            ,p_dimension_id
                            ,p_source_tl_table
                            ,p_target_b_table
                            ,p_member_dc_col
                            ,p_member_t_dc_col
                            ,p_exec_mode_clause
                            ,p_shared_dimension_flag
                            ,p_value_set_required_flag
                            ,x_ro_mbr_upd_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_ro_mbr_upd_stmt := REPLACE(x_ro_mbr_upd_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_ro_mbr_upd_stmt := REPLACE(x_ro_mbr_upd_stmt,'{{data_slice}}','1=1');
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.ro_mbr_upd stmt'
   ,x_ro_mbr_upd_stmt);


   ------------------------------------------------------------------------------
   -- Build the select stmt for exising Dimension members using the information
   -- returned from get_dimension_info
   ------------------------------------------------------------------------------
   build_mbr_select_stmt  (p_load_type
                          ,p_dimension_varchar_label
                          ,p_dimension_id
                          ,p_target_b_table
                          ,p_target_tl_table
                          ,p_source_b_table
                          ,p_source_tl_table
                          ,p_member_dc_col
                          ,p_member_t_dc_col
                          ,p_member_t_name_col
                          ,p_member_description_col
                          ,p_value_set_required_flag
                          ,p_shared_dimension_flag
                          ,p_hier_dimension_flag
                          ,'Y'
                          ,p_exec_mode_clause
                          ,x_select_stmt);

   build_bad_tl_select_stmt  (p_load_type
                          ,p_dimension_varchar_label
                          ,p_dimension_id
                          ,p_target_b_table
                          ,p_target_tl_table
                          ,p_source_b_table
                          ,p_source_tl_table
                          ,p_member_dc_col
                          ,p_member_t_dc_col
                          ,p_value_set_required_flag
                          ,p_shared_dimension_flag
                          ,p_hier_dimension_flag
                          ,p_exec_mode_clause
                          ,x_bad_tl_select_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_select_stmt := REPLACE(x_select_stmt,'{{data_slice}}',p_data_slc);
      x_bad_tl_select_stmt := REPLACE(x_bad_tl_select_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_select_stmt := REPLACE(x_select_stmt,'{{data_slice}}','1=1');
      x_bad_tl_select_stmt := REPLACE(x_bad_tl_select_stmt,'{{data_slice}}','1=1');
   END IF;

   -- set the local fetch limit variable based on the parameter
   -- this will be null for Dimension Group loads
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;


   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.member select stmt'
   ,x_select_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.bad_tl_select_stmt'
   ,x_bad_tl_select_stmt);


   build_tl_update_stmt (p_dimension_varchar_label
                        ,p_dimension_id
                        ,p_load_type
                        ,p_target_b_table
                        ,p_target_tl_table
                        ,p_member_col
                        ,p_member_dc_col
                        ,p_member_name_col
                        ,p_member_description_col
                        ,p_value_set_required_flag
                        ,x_update_tl_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.tl table update stmt'
   ,x_update_tl_stmt);

   build_delete_stmt (p_source_tl_table
                     ,x_delete_tl_stmt);


   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.delete stmt'
   ,x_delete_tl_stmt);

   build_status_update_stmt (p_source_tl_table
                            ,x_update_tl_status_stmt);

   build_tl_dupname_stmt (p_dimension_varchar_label
                         ,p_dimension_id
                         ,p_load_type
                         ,p_target_b_table
                         ,p_target_tl_table
                         ,p_member_col
                         ,p_member_dc_col
                         ,p_member_name_col
                         ,p_value_set_required_flag
                         ,'TL_UPDATE'
                         ,x_dupname_count_stmt);

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.dupname select stmt'
     ,x_dupname_count_stmt);




   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop

   -- Begin the Data Slice Loop
   LOOP

      IF p_load_type <> ('DIMENSION_GROUP') THEN

      FEM_Multi_Proc_Pkg.Get_Data_Slice(
        x_slc_id => v_slc_id,
        x_slc_val1 => v_slc_val,
        x_slc_val2 => v_slc_val2,
        x_slc_val3 => v_slc_val3,
        x_slc_val4 => v_slc_val4,
        x_num_vals  => v_num_vals,
        x_part_name => v_part_name,
        p_req_id => p_master_request_id,
        p_proc_num => p_proc_num);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
       ,v_slc_val);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
       ,v_slc_val2);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
       ,v_slc_val3);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
       ,v_slc_val4);


      EXIT WHEN (v_slc_id IS NULL);
      ELSE
         EXIT WHEN (v_loop_counter > 0);
         v_loop_counter := v_loop_counter + 1;
      END IF;


   --------------------------------------------------------------------------
   -- Execute the Updates
   IF p_load_type <> ('DIMENSION_GROUP') THEN
      EXECUTE IMMEDIATE x_bad_lang_upd_stmt USING v_slc_val, v_slc_val2;
   ELSE
      EXECUTE IMMEDIATE x_bad_lang_upd_stmt;
   END IF;
   v_bulk_rows_rejected := SQL%ROWCOUNT;

   COMMIT;
   --------------------------------------------------------------------------

   IF p_load_type <> ('DIMENSION_GROUP') THEN
      EXECUTE IMMEDIATE x_ro_mbr_upd_stmt USING v_slc_val, v_slc_val2;
   ELSE
      EXECUTE IMMEDIATE x_ro_mbr_upd_stmt;
   END IF;
   v_bulk_rows_rejected := v_bulk_rows_rejected + SQL%ROWCOUNT;

   COMMIT;
   --------------------------------------------------------------------------


   ------------------------------------------------------------------------------
   -- Loop through the members that already exist
   -- to perform updates on name/description columns
   ------------------------------------------------------------------------------
      IF p_load_type <> ('DIMENSION_GROUP') THEN
         OPEN cv_get_rows FOR x_select_stmt USING v_slc_val, v_slc_val2;
      ELSE
         OPEN cv_get_rows FOR x_select_stmt;
      END IF;

      LOOP
         -------------------------------------------
         -- Bulk Collect Rows from the source _T tables
         -- Using Dynamic SELECT Statement
         -------------------------------------------
         FETCH cv_get_rows BULK COLLECT INTO
                t_rowid
               ,t_tl_rowid
               ,t_member_dc
               ,t_calendar_dc
               ,t_calendar_id
               ,t_cal_period_end_date
               ,t_cal_period_number
               ,t_value_set_dc
               ,t_value_set_id
               ,t_dimension_group_dc
               ,t_dimension_group_id
               ,t_b_status
               ,t_member_name
               ,t_member_desc
               ,t_language
               ,t_tl_status
               ,t_dimension_group_seq
               ,t_time_group_type_code
         LIMIT v_fetch_limit;

         ----------------------------------------------
         -- EXIT Fetch LOOP If No Rows are Retrieved --
         ----------------------------------------------
         v_mbr_last_row := t_member_dc.LAST;

         IF (v_mbr_last_row IS NULL)
         THEN
            EXIT;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.Rows retrieved this fetch',v_mbr_last_row);

         --v_rows_fetched := v_rows_fetched + v_mbr_last_row;

         FOR i IN 1..v_mbr_last_row
         LOOP

            ----------------------------------------------
            --  Begin Duplicate Name Validations (only if dim <> 'CUSTOMER')
            --  Check to see if the translatabe name that will be load
            --  already exists for ANY language in the target TL table
            --  Set STATUS = 'DUPLICATE_NAME' if the name already exists
            ----------------------------------------------
            IF p_dimension_varchar_label <> 'CUSTOMER' THEN
               IF p_dimension_varchar_label = 'CAL_PERIOD' AND
                  p_load_type <> 'DIMENSION_GROUP' THEN

                  EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                     USING t_member_name(i)
                          ,t_member_dc(i)
                          ,t_language(i)
                          ,t_dimension_group_id(i)
                          ,t_calendar_id(i);

               ELSE
                  IF p_value_set_required_flag = 'Y' THEN
                     EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                        USING t_member_name(i)
                             ,t_member_dc(i)
                             ,t_language(i)
                             ,t_value_set_dc(i);
                  ELSE
                     EXECUTE IMMEDIATE x_dupname_count_stmt INTO v_dupname_count
                        USING t_member_name(i)
                             ,t_member_dc(i)
                             ,t_language(i);
                  END IF;
               END IF;
               IF v_dupname_count > 0 THEN
                  t_tl_status(i) := 'DUPLICATE_NAME';
                  ----------------------------------------------------------
                  -- Count the error rows
                  ----------------------------------------------------------
                  v_rows_rejected := v_rows_rejected + 1;

               END IF;
            END IF; -- p_dim_label <> 'CUSTOMER'

         END LOOP;

         --------------------------------------------------------------------------------------
         -- Perform the update on the TL table
         --------------------------------------------------------------------------------------
         IF (p_value_set_required_flag = 'Y') THEN
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_update_tl_stmt
               USING t_member_name(i)
                 ,t_member_desc(i)
                 ,t_language(i)
                 ,gv_apps_user_id
                 ,gv_login_id
                 ,t_member_dc(i)
                 ,t_value_set_dc(i)
                 ,t_value_set_dc(i)
                 ,t_language(i)
                 ,t_tl_status(i);

         ELSE
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_update_tl_stmt
               USING t_member_name(i)
                    ,t_member_desc(i)
                    ,t_language(i)
                    ,gv_apps_user_id
                    ,gv_login_id
                    ,t_member_dc(i)
                    ,t_language(i)
                    ,t_tl_status(i);
         END IF;

         ---------------------------------------------------------
         -- Delete Loaded member records from the _TL_T table
         ---------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.Deleting TL_T rows','start');
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_delete_tl_stmt
            USING t_tl_rowid(i)
                 ,t_tl_status(i)
                 ,'N';

         ----------------------------------------------------------
         -- Update Status of Error TL records
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_tl_status_stmt
            USING t_tl_status(i)
                 ,t_tl_rowid(i)
                 ,t_tl_status(i);

            COMMIT;


         --------------------------------------------
         -- Delete Collections for Next Bulk Fetch --
         --------------------------------------------
         t_rowid.DELETE;
         t_tl_rowid.DELETE;
         t_member_dc.DELETE;
         t_calendar_dc.DELETE;
         t_calendar_id.DELETE;
         t_cal_period_end_date.DELETE;
         t_cal_period_number.DELETE;
         t_value_set_dc.DELETE;
         t_value_set_id.DELETE;
         t_dimension_group_dc.DELETE;
         t_dimension_group_id.DELETE;
         t_b_status.DELETE;
         t_member_name.DELETE;
         t_member_desc.DELETE;
         t_language.DELETE;
         t_tl_status.DELETE;
         t_dimension_group_seq.DELETE;
         t_time_group_type_code.DELETE;

      COMMIT;
      END LOOP;  -- Existing Members
      IF cv_get_rows%ISOPEN THEN
         CLOSE cv_get_rows;
      END IF;

      ---------------------------------------------------------------
      -- Identify records in TL_T table that do not exist in FEM
      -- and also do not have a "new" base record in the _B_T table
      ---------------------------------------------------------------
      IF p_load_type <> ('DIMENSION_GROUP') THEN
         OPEN cv_get_rows FOR x_bad_tl_select_stmt USING v_slc_val, v_slc_val2;
      ELSE
         OPEN cv_get_rows FOR x_bad_tl_select_stmt;
      END IF;

      LOOP
         -------------------------------------------
         -- Bulk Collect Rows from the source TL_T table
         -- Using Dynamic SELECT Statement
         -------------------------------------------
         FETCH cv_get_rows BULK COLLECT INTO
                t_rowid
               ,t_member_dc
               ,t_calendar_dc
               ,t_calendar_id
               ,t_cal_period_end_date
               ,t_cal_period_number
               ,t_value_set_dc
               ,t_b_status
         LIMIT v_fetch_limit;

         ----------------------------------------------
         -- EXIT Fetch LOOP If No Rows are Retrieved --
         ----------------------------------------------
         v_mbr_last_row := t_member_dc.LAST;

         IF (v_mbr_last_row IS NULL)
         THEN
            EXIT;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.Rows retrieved this fetch',v_mbr_last_row);

         ----------------------------------------------------------
         -- Update Status of Bad TL Collection
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_tl_status_stmt
            USING t_b_status(i)
                 ,t_rowid(i)
                 ,t_b_status(i);

            COMMIT;

         ----------------------------------------------------------
         -- Count the error rows
         ----------------------------------------------------------
         v_rows_rejected := v_rows_rejected + v_mbr_last_row;

         --------------------------------------------
         -- Delete Collections for Next Bulk Fetch --
         --------------------------------------------
         t_rowid.DELETE;
         t_tl_rowid.DELETE;
         t_member_dc.DELETE;
         t_calendar_dc.DELETE;
         t_calendar_id.DELETE;
         t_cal_period_end_date.DELETE;
         t_cal_period_number.DELETE;
         t_value_set_dc.DELETE;
         t_value_set_id.DELETE;
         t_dimension_group_dc.DELETE;
         t_dimension_group_id.DELETE;
         t_b_status.DELETE;
         t_member_name.DELETE;
         t_member_desc.DELETE;
         t_language.DELETE;
         t_tl_status.DELETE;
         t_dimension_group_seq.DELETE;
         t_time_group_type_code.DELETE;

         COMMIT;
      END LOOP;  -- Bad TL members

   IF p_load_type <> ('DIMENSION_GROUP') THEN
      FEM_Multi_Proc_Pkg.Post_Data_Slice(
        p_req_id => p_master_request_id,
        p_slc_id => v_slc_id,
        p_status => v_mp_status,
        p_message => v_mp_message,
        p_rows_processed => 0,
        p_rows_loaded => 0,
        p_rows_rejected => v_rows_rejected+v_bulk_rows_rejected);
   END IF;

   END LOOP; -- get_data_slice

   IF p_load_type = ('DIMENSION_GROUP') THEN
      gv_dimgrp_rows_rejected := gv_dimgrp_rows_rejected + v_rows_rejected + v_bulk_rows_rejected;
   END IF;

   IF cv_get_rows%ISOPEN THEN
      CLOSE cv_get_rows;
   END IF;

   --x_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_rows%ISOPEN THEN
            CLOSE cv_get_rows;
         END IF;

         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
          ,P_TOKEN1 => 'ERR_MSG'
          ,P_VALUE1 => gv_prg_msg);

       --  FEM_ENGINES_PKG.USER_MESSAGE
       --   (p_app_name => c_fem
       --   ,p_msg_text => gv_prg_msg);

         RAISE e_main_terminate;
END TL_Update;

/*===========================================================================+
 | PROCEDURE
 |              Base_Update
 |
 | DESCRIPTION
 |  These are all of the records in the _B_T table that are existing
 |  dimension members in FEM.  For these we will update any
 |  "Base" table columns.
 |   Note:  Inserts of new attribute assignments for existing members, as well
 |   as updates of existing attribute assignments, are handled in the Update_Attr module
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |   This procedure does not perform any updates of the FEM tables at the moment
 |   since the rules for updating the Dimension Group are unclear
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   8-MAR-04  Created
 |    Rob Flippo   28-SEP-04  Bug#3906218 Ability undelete members
 |    Rob Flippo   03-MAR-05  Modify so that for dim grp load we don't get a
 |                            unique dimgrp seq error unless the conflict is
 |                            caused by a dimension group other than the one
 |                            that is being loaded.
 |    Rob Flippo   16-MAR-05  Bug#4244082 Modify to update dimgrp as long as
 |                            member does not participate in a sequence enforced
 |                            hier
 |                            -- note - if the dimgrp doesn't change, the loader
 |                               won't mark the _b_t record as an error (for seq
 |                               enf hier situation)
 |    Rob Flippo   22-MAR-05  Add p_dimension_id as parm for build_remain_mbr_select
 +===========================================================================*/
PROCEDURE Base_Update (p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_partition_code IN NUMBER
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_simple_dimension_flag IN VARCHAR2
                      ,p_shared_dimension_flag IN VARCHAR2
                      ,p_dimension_id IN NUMBER
                      ,p_value_set_required_flag IN VARCHAR2
                      ,p_hier_table_name IN VARCHAR2
                      ,p_hier_dimension_flag IN VARCHAR2
                      ,p_source_b_table IN VARCHAR2
                      ,p_target_b_table IN VARCHAR2
                      ,p_member_dc_col IN VARCHAR2
                      ,p_member_t_dc_col IN VARCHAR2
                      ,p_member_col IN VARCHAR2
                      ,p_exec_mode_clause IN VARCHAR2
                      ,p_master_request_id IN NUMBER)
IS
-- Consants
   c_proc_name VARCHAR2(30) := 'Base_Update';

-- Dynamic SQL statement variables
   x_remain_mbr_select_stmt          VARCHAR2(4000);
   x_update_stmt                     VARCHAR2(4000);
   x_update_mbr_status_stmt          VARCHAR2(4000);
   x_update_dimgrp_stmt              VARCHAR2(4000);
   x_delete_mbr_stmt                 VARCHAR2(4000);
   x_enabled_flag_update_stmt        VARCHAR2(4000);
   x_seq_enf_hiercount_stmt          VARCHAR2(4000);

-- Count variables
   v_mbr_last_row                    NUMBER;
   v_seq_conflict_count              NUMBER;
   v_count                           NUMBER;
   v_temp_rows_rejected              NUMBER :=0;
   v_rows_rejected                   NUMBER :=0;
   v_rows_loaded                     NUMBER :=0;
   v_seq_enf_hiercount               NUMBER;
   v_calp_dimgrp_count               NUMBER; -- used to identify is the dimgrp
                                             -- for an existing cal period member
                                             -- matches the dimgrp in the target_b
                                             -- for that member

-- Other variables
   v_fetch_limit                     NUMBER;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   t_rowid                           rowid_type;
   t_member_id                       varchar2_150_type;
   t_value_set_id                    number_type;
   t_dimension_group_id              number_type;
   t_old_dimension_group_id          number_type; -- dimgrp of the member as it exists in
                                                  -- in the _B table
   t_b_status                        varchar2_std_type;
   t_member_dc                       varchar2_150_type;
   t_value_set_dc                    varchar2_150_type;
   t_dimension_group_dc              varchar2_150_type;
   t_dimension_group_seq             number_type;
   t_time_group_type_code            varchar2_std_type;

---------------------
-- Declare cursors --
---------------------
   cv_get_remain_mbr     cv_curs;

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   --x_status := 0; -- initialize status of the Base_Update procedure
   --x_message := 'COMPLETE:NORMAL';

   -- set the local fetch limit variable based on the parameter
   -- this will be null for Dimension Group loads
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;


   build_remain_mbr_select_stmt  (p_load_type
                                 ,p_dimension_id
                                 ,p_dimension_varchar_label
                                 ,p_shared_dimension_flag
                                 ,p_value_set_required_flag
                                 ,p_hier_dimension_flag
                                 ,p_source_b_table
                                 ,p_target_b_table
                                 ,p_member_col
                                 ,p_member_dc_col
                                 ,p_member_t_dc_col
                                 ,p_exec_mode_clause
                                 ,x_remain_mbr_select_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_remain_mbr_select_stmt := REPLACE(x_remain_mbr_select_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_remain_mbr_select_stmt := REPLACE(x_remain_mbr_select_stmt,'{{data_slice}}','1=1');
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.member select stmt'
   ,x_remain_mbr_select_stmt);

   build_status_update_stmt (p_source_b_table
                            ,x_update_mbr_status_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.status update stmt'
   ,x_update_mbr_status_stmt);

   build_delete_stmt (p_source_b_table
                     ,x_delete_mbr_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.delete stmt'
   ,x_delete_mbr_stmt);

   build_seq_enf_hiercount_stmt (p_value_set_required_flag
                                ,p_hier_table_name
                                ,x_seq_enf_hiercount_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.seq_enf_hiercount_stmt'
   ,x_seq_enf_hiercount_stmt);

   build_dimgrp_update_stmt (p_target_b_table
                            ,p_value_set_required_flag
                            ,p_member_dc_col
                            ,x_update_dimgrp_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.update member base table stmt'
   ,x_update_dimgrp_stmt);

   build_enable_update_stmt (p_dimension_varchar_label
                            ,p_dimension_id
                            ,p_load_type
                            ,p_target_b_table
                            ,p_member_col
                            ,p_member_dc_col
                            ,p_value_set_required_flag
                            ,x_enabled_flag_update_stmt);
   IF p_data_slc IS NOT NULL THEN
      x_enabled_flag_update_stmt := REPLACE(x_enabled_flag_update_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_enabled_flag_update_stmt := REPLACE(x_enabled_flag_update_stmt,'{{data_slice}}','1=1');
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.update member enabled_flag stmt'
   ,x_enabled_flag_update_stmt);


   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop

   LOOP

      IF p_load_type <> ('DIMENSION_GROUP') THEN

      FEM_Multi_Proc_Pkg.Get_Data_Slice(
        x_slc_id => v_slc_id,
        x_slc_val1 => v_slc_val,
        x_slc_val2 => v_slc_val2,
        x_slc_val3 => v_slc_val3,
        x_slc_val4 => v_slc_val4,
        x_num_vals  => v_num_vals,
        x_part_name => v_part_name,
        p_req_id => p_master_request_id,
        p_proc_num => p_proc_num);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
       ,v_slc_val);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
       ,v_slc_val2);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
       ,v_slc_val3);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
       ,v_slc_val4);


      EXIT WHEN (v_slc_id IS NULL);
      ELSE
         EXIT WHEN (v_loop_counter > 0);
         v_loop_counter := v_loop_counter + 1;
      END IF;

   ------------------------------------------------------------------------------
   -- Loop through the remaining members that already exist in the _B_T table
   -- to perform update on the Dimension Group
   ------------------------------------------------------------------------------
      IF p_load_type <> ('DIMENSION_GROUP') THEN
         OPEN cv_get_remain_mbr FOR x_remain_mbr_select_stmt USING v_slc_val, v_slc_val2;
      ELSE
         OPEN cv_get_remain_mbr FOR x_remain_mbr_select_stmt;
      END IF;

      LOOP
         -------------------------------------------
         -- Bulk Collect Rows from the source _B table
         -- Using Dynamic SELECT Statement
         -------------------------------------------
         FETCH cv_get_remain_mbr BULK COLLECT INTO
                t_rowid
                ,t_member_id
               ,t_member_dc
               ,t_value_set_dc
               ,t_value_set_id
               ,t_dimension_group_dc
               ,t_dimension_group_id
               ,t_old_dimension_group_id
               ,t_dimension_group_seq
               ,t_time_group_type_code
               ,t_b_status
         LIMIT v_fetch_limit;
         ----------------------------------------------
         -- EXIT Fetch LOOP If No Rows are Retrieved --
         ----------------------------------------------
         v_mbr_last_row := t_member_dc.LAST;

         IF (v_mbr_last_row IS NULL)
         THEN
            EXIT;
         END IF;

         FOR i IN 1..v_mbr_last_row
         LOOP
         ----------------------------------------------
         --  Begin Load_Type = 'DIMENSION_GROUP' Validations
         ----------------------------------------------
            IF (p_load_type = 'DIMENSION_GROUP') THEN
               SELECT count(*)
               INTO v_seq_conflict_count
               FROM fem_dimension_grps_b
               WHERE dimension_group_seq = t_dimension_group_seq(i)
               AND dimension_id = p_dimension_id
               AND dimension_group_id <> t_dimension_group_id(i);

               IF v_seq_conflict_count > 0 THEN
                  t_b_status(i) := 'DIMENSION_GROUP_SEQ_NOT_UNIQUE';
                  ----------------------------------------------------------
                  -- Count the error rows
                  ----------------------------------------------------------
                  v_temp_rows_rejected := v_temp_rows_rejected + 1;
                    FEM_ENGINES_PKG.TECH_MESSAGE
                      (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected1',v_temp_rows_rejected);
               END IF; -- seq_conflict_count

               IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN
                  SELECT count(*)
                  INTO v_count
                  FROM fem_time_group_types_b
                  WHERE time_group_type_code = t_time_group_type_code(i);

                  IF v_count =0 THEN
                     t_b_status(i) := 'INVALID_TIME_GROUP_TYPE';
                     ----------------------------------------------------------
                     -- Count the error rows
                     ----------------------------------------------------------
                     v_temp_rows_rejected := v_temp_rows_rejected + 1;
                  END IF;
               END IF; -- CAL_PERIOD
            ELSE
            ----------------------------------------------
            -- Load_Type = 'DIMENSION_MEMBER' validations
            ----------------------------------------------
               IF p_hier_dimension_flag = 'Y' THEN
                  -- Validate the Dimension Group for the member

                  IF (t_dimension_group_dc(i) IS NOT NULL
                      AND t_dimension_group_id(i) IS NULL
                      AND p_dimension_varchar_label NOT IN ('CAL_PERIOD')) THEN
                     t_b_status(i) := 'INVALID_DIMENSION_GROUP';
                     ----------------------------------------------------------
                     -- Count the error rows
                     ----------------------------------------------------------
                     v_temp_rows_rejected := v_temp_rows_rejected + 1;
                    FEM_ENGINES_PKG.TECH_MESSAGE
                      (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected2',v_temp_rows_rejected);
                  END IF; -- validation on dimgrp being not null

                 -- Get count of sequence enforced hiers in which the member participates
                 IF p_dimension_varchar_label NOT IN ('CAL_PERIOD') THEN
                    IF p_value_set_required_flag = 'Y' THEN
                       EXECUTE IMMEDIATE x_seq_enf_hiercount_stmt
                       INTO v_seq_enf_hiercount
                       USING t_member_id(i)
                            ,t_value_set_id(i);
                    ELSE
                       EXECUTE IMMEDIATE x_seq_enf_hiercount_stmt
                       INTO v_seq_enf_hiercount
                       USING t_member_id(i);
                    END IF; -- hiercount immediate

                    IF v_seq_enf_hiercount > 0
                       AND t_dimension_group_id(i) <> t_old_dimension_group_id(i) THEN
                       t_b_status(i) := 'INVALID_DIMGRP_MBR_IN_SEQ_HIER';
                       ----------------------------------------------------------
                       -- Count the error rows
                       ----------------------------------------------------------
                       v_temp_rows_rejected := v_temp_rows_rejected + 1;
                      FEM_ENGINES_PKG.TECH_MESSAGE
                        (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected3',v_temp_rows_rejected);
                    ELSE -- update the dimension_group
                       IF p_value_set_required_flag = 'Y' THEN
                          EXECUTE IMMEDIATE x_update_dimgrp_stmt
                          USING t_dimension_group_id(i)
                               ,gv_apps_user_id
                               ,gv_login_id
                               ,t_member_dc(i)
                               ,t_value_set_id(i)
                               ,t_b_status(i);
                       ELSE
                          EXECUTE IMMEDIATE x_update_dimgrp_stmt
                          USING t_dimension_group_id(i)
                               ,gv_apps_user_id
                               ,gv_login_id
                               ,t_member_dc(i)
                               ,t_b_status(i);
                       END IF; -- execute immediate x_update_dimgrp_stmt
                    END IF; -- v_seq_enf_hiercount
                  END IF; -- not CAL_PERIOD
               END IF; -- dimensions that use_groups
            END IF; -- Load_Type 'DIMENSION_GROUP' v.s. 'DIMENSION_MEMBER'
         END LOOP;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected4',v_temp_rows_rejected);

         ---------------------------------------------------------
         -- Update member records in the _B table for Rejected records
         ---------------------------------------------------------
        FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.updating mbr status','start');
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_mbr_status_stmt
               USING t_b_status(i)
                    ,t_rowid(i)
                    ,t_b_status(i);

         ---------------------------------------------------------
         -- Delete member records from the _B_T table
         ---------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_delete_mbr_stmt
            USING t_rowid(i)
                 ,t_b_status(i)
                 ,'N';

         ---------------------------------------------------------
         --  Bug#3906218 NEED ABILITY TO UNDELETE DIMENSIONS
         --  Perform the Enabled Flag update on the B table
         ---------------------------------------------------------
        FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.updating enabled flag','start');

         IF (p_value_set_required_flag = 'Y') THEN
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_enabled_flag_update_stmt
               USING t_member_dc(i)
                    ,t_value_set_dc(i)
                    ,t_value_set_dc(i)
                    ,t_b_status(i);

         ELSE
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_enabled_flag_update_stmt
               USING t_member_dc(i)
                    ,t_b_status(i);
         END IF;


         ----------------------------------------------------------
         -- Count the error and loaded rows
         ----------------------------------------------------------
         v_rows_rejected := v_rows_rejected + v_temp_rows_rejected;
         v_rows_loaded := v_rows_loaded + (v_mbr_last_row - v_temp_rows_rejected);
        FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected',v_rows_rejected);

         --x_rows_loaded   := x_rows_loaded + (v_mbr_last_row - v_temp_rows_rejected);
         v_temp_rows_rejected := 0;  -- initialize for next pass of the loop
         v_rows_loaded := 0;

         --------------------------------------------
         -- Delete Collections for Next Bulk Fetch --
         --------------------------------------------
         t_rowid.DELETE;
         t_member_id.DELETE;
         t_member_dc.DELETE;
         t_value_set_dc.DELETE;
         t_value_set_id.DELETE;
         t_dimension_group_dc.DELETE;
         t_dimension_group_id.DELETE;
         t_b_status.DELETE;

      COMMIT;
      END LOOP;  -- Remaining members BULK Collect

   IF p_load_type <> ('DIMENSION_GROUP') THEN
      FEM_Multi_Proc_Pkg.Post_Data_Slice(
        p_req_id => p_master_request_id,
        p_slc_id => v_slc_id,
        p_status => v_mp_status,
        p_message => v_mp_message,
        p_rows_processed => 0,
        p_rows_loaded => 0,
        p_rows_rejected => v_rows_rejected);
   END IF;

   END LOOP; -- get_data_slice

   IF p_load_type = ('DIMENSION_GROUP') THEN
      gv_dimgrp_rows_rejected := gv_dimgrp_rows_rejected + v_rows_rejected;
   END IF;


   IF cv_get_remain_mbr%ISOPEN THEN
      CLOSE cv_get_remain_mbr;
   END IF;

   --x_rows_rejected := v_rows_rejected;
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_remain_mbr%ISOPEN THEN
            CLOSE cv_get_remain_mbr;
         END IF;

         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
          ,P_TOKEN1 => 'ERR_MSG'
          ,P_VALUE1 => gv_prg_msg);

       --  FEM_ENGINES_PKG.USER_MESSAGE
       --   (p_app_name => c_fem
       --   ,p_msg_text => gv_prg_msg);

         RAISE e_main_terminate;


END Base_Update;

/*===========================================================================+
 | PROCEDURE
 |              Attr_Assign_Update
 |
 | DESCRIPTION
 |   This step updates attribute rows for existing members.  It also inserts
 |   new attribute rows for existing members.  It is not necessary for users
 |   to populate the _B_T table in order for this step to run - it just queries
 |   attribute assignments from the _ATTR_T table
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
  |   Update Attribute Assign (Simple Dim = 'N' only)
 |   1.	Attribute assignment rows for members that exist in FEM can be updated
 |      where the assignment already exists.  Also, assignment rows for
 |      additional versions can be loaded as long as the attribute supports multiple versions.
 |      	If a DIMENSION assignment, then assignment value must exist in the
 |          attribute dimension table.  Status = 'INVALID_DIM_ASSIGNMENT' for failure
 |      	If a DATE assignment, then assignment value must be a valid date.
 |          Status='INVALID_DATE' for failure
 |      	If a NUMBER assignment, then assignment value must be a valid number.
 |          Status = 'INVALID_NUMBER' for failure.
 |      	If an assignment exists for the VERSION_DISPLAY_CODE and the attribute
 |          is Read Only, then record is rejected and
 |          Status = 'READ_ONLY_ATTRIBUTE'
 |      	If an assignment does not exist for the VERSION_DISPLAY_CODE and
 |          and an assignment does exist for one or more versions and the attribute
 |          is a "Single Version Only", then record is rejected and
 |          Status = 'MULT_VERSION_NOT_ALLOWED'
 |
 |            -If the attribute assignment already exists for the provided version, it will be
 |             updated in FEM with the new value as long as it is not a "read only"
 |             version and as long as the attribute is not a "multiple assignment" attribute.
 |
 |            -If the assignment exists for the provided version and the attribute
 |             is a "multiple assignment" attribute, then a new attribute row will be
 |             inserted for that version.
 |
 |            -If the attribute assignment exists for the member but for a different version,
 |             then a new assignment row will be created only if the attribute "allows
 |             multiple versions".
 |
 |            -If the attribute assignment does not exist at all for the member (either for
 |             provided version or for any version), then a new assignment row will be
 |             inserted.
 |   2.	Delete any _ATTR_T rows that are successful.
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   22-MAR-04  Created
 |    Rob Flippo   13-SEP-04  Bug#3835758  Validation on the attr_Assign_vs
 |                                         was modified to include dimension_id
 |                                         in the where condition
 |    Rob Flippo   15-SEP-04  Bug#3835758  Added exception handler so no failure
 |                                         if VS didn't exist.  Also moved the section
 |                                         that verifies the VS so that only called
 |                                         for DIMENSION attributes;
 |    Rob Flippo   30-SEP-04  Bug#3925655  For assignment_is_read_only='Y' attr,
 |                                         if the new value = the existing value,
 |                                         go ahead and do the update so that the
 |                                         interface row can be deleted and not
 |                                         show up as an error
 |    Logic for assignment_is_read_only is as follows:
 |     If assignment_is_read_only_flag = 'Y', and there is an existing
 |     assignment record for the same version (i.e., - using build_does_attr_exist
 |     with version_flag = 'Y'), then
 |        query the target ATTR table again for that member, attribute, version,
 |        and include the appropriate assignment columns to see if you get 1 row
 |        back.  If you do, then go ahead an update, since it is identical
 |        If no row comes back, then error as normal for when user tries to update
 |        assignment_is_read_only attribute
 |
 |     Rob Flippo   01-OCT-04 Added logic so that if member is read
 |                            only, the attribute update is not
 |
 |    Rob Flippo   22-NOV-04  Bug#4019066 Add validation on Accounting_Year
 |                            and GL_PERIOD_NUM for CAL_PERIOD;  ACCOUNTING_YEAR
 |                            must be >=1900 and <= 2599 while GL_PERIOD_NUM
 |                            must be <= periods_in_year for the Time Group Type
 |                            allowed
 |                            Bug#4019853 - Fix Data Overlap logic -
 |                            Added section that checks within the
 |                            attr array for date overlaps.  This logic
 |                            assumes num_of_processes = 1 for CAL_PEIOD
 |                            load
 |   Rob Flippo   05-MAR-05   Bug#4170444 Add check to see if READ_ONLY_FLAG='Y'
 |                            in the target ATTR table for existing rows.  If
 |                            it is, then set STATUS = 'PROTECTED_ATTR_ASSIGN'
 |   Rob Flippo   11-AUG-05   Bug#4547868 Performance issue - change ATTR
 |                            Select to get member_id and value_set_id
 |   Rob Flippo   07-OCT-05   Bug#4630742 10G issue - Attr_assign_update fails
 |                            on does_attr_exist checks:  Modified the fetch
 |                            so that both the "version" and "non-version" queries
 |                            are identical for output variables;
 | Rob Flippo     28-APR-06   Bug 5174039 Added validation that calp start_date
 |                            must be <= calp end date
 | Rob Flippo     18-JUL-06   Bug 5024575 Updates for Many-to-many attributes
 +===========================================================================*/
PROCEDURE Attr_Assign_Update (p_eng_sql IN VARCHAR2
                             ,p_data_slc IN VARCHAR2
                             ,p_proc_num IN VARCHAR2
                             ,p_partition_code IN NUMBER
                             ,p_fetch_limit IN NUMBER
                             ,p_dimension_varchar_label IN VARCHAR2
                             ,p_date_format_mask IN VARCHAR2
                             ,p_dimension_id IN VARCHAR2
                             ,p_target_b_table IN VARCHAR2
                             ,p_target_attr_table IN VARCHAR2
                             ,p_source_b_table IN VARCHAR2
                             ,p_source_attr_table IN VARCHAR2
                             ,p_member_col IN VARCHAR2
                             ,p_member_dc_col IN VARCHAR2
                             ,p_member_t_dc_col IN VARCHAR2
                             ,p_value_set_required_flag IN VARCHAR2
                             ,p_hier_dimension_flag IN VARCHAR2
                             ,p_simple_dimension_flag IN VARCHAR2
                             ,p_shared_dimension_flag IN VARCHAR2
                             ,p_exec_mode_clause IN VARCHAR2
                             ,p_master_request_id IN NUMBER )
IS
-- Constants
   c_proc_name VARCHAR2(30) := 'Attr_Assign_Update';

-- variables storing temporary state information
   v_attr_success                    VARCHAR2(30);
   v_temp_member                     VARCHAR2(100);
   v_temp_rows_rejected              NUMBER :=0;
   v_rows_rejected                   NUMBER :=0;
   v_rows_loaded                     NUMBER :=0;

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);

-- Dynamic SQL statement variables
   x_select_stmt                     VARCHAR2(4000);
   x_attr_select_stmt                VARCHAR2(4000);
   x_remain_mbr_select_stmt          VARCHAR2(4000);
   x_insert_member_stmt              VARCHAR2(4000);
   x_insert_attr_stmt                VARCHAR2(4000);
   x_update_stmt                     VARCHAR2(4000);
   x_attr_update_stmt                VARCHAR2(4000);
   x_update_tl_stmt                  VARCHAR2(4000);
   x_update_attr_status_stmt         VARCHAR2(4000);
   x_update_mbr_status_stmt          VARCHAR2(4000);
   x_update_tl_status_stmt           VARCHAR2(4000);
   x_update_dimgrp_stmt              VARCHAR2(4000);
   x_delete_attr_stmt                VARCHAR2(4000);
   x_special_delete_attr_stmt        VARCHAR2(4000);
   x_delete_mbr_stmt                 VARCHAR2(4000);
   x_delete_tl_stmt                  VARCHAR2(4000);
   x_does_attr_exist_stmt            VARCHAR2(4000);
   x_does_multattr_exist_stmt        VARCHAR2(4000);
   x_does_attr_exist_novers_stmt     VARCHAR2(4000);
   x_identical_attr_select_stmt      VARCHAR2(4000);
   x_adj_period_stmt                 VARCHAR2(4000);
   x_overlap_sql_stmt                VARCHAR2(4000);
   x_calp_interim_stmt               VARCHAR2(4000);
   x_calp_attr_interim_stmt          VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_attr_final_count                NUMBER := 0;
   v_mbr_final_count                 NUMBER := 0;
   v_mbr_count                       NUMBER := 0;
   v_attr_count                      NUMBER := 0;
   v_attr_subcount                   NUMBER := 0;
   v_final_mbr_last_row              NUMBER;
   v_attr_last_row                   NUMBER;
   v_mbr_last_row                    NUMBER;
   v_nonadj_period_count             NUMBER :=0;
   v_overlap_count                   NUMBER :=0;

-------------------------------------
-- Declare bulk collection columns --
-------------------------------------

-- Common abbreviations:
--    t_ = array of raw interface table member rows
--    tf = "final" array of interface table member rows that have been validated for insert
--    ta = array of raw interface table attribute rows
--    tfa = "final" array of interface table attribute rows that have been validated for insert

   ta_rowid                          rowid_type;
   tfa_rowid                         rowid_type;

   ta_member_id                      number_type;
   ta_value_set_id                   number_type;
   ta_attribute_id                   number_type;
   ta_attribute_dimension_id         number_type;
   ta_dim_attr_numeric_member        number_type;
   ta_number_assign_value            number_type;
   ta_version_id                     number_type;
   ta_attr_assign_vs_id              number_type;
   ta_attr_exists_count              number_type;  -- count of existing attr assign with version_id
   ta_multattr_exists_count          number_type;  -- count of existing attr assign with version_id and same assignment key
   ta_attr_exists_novers_count       number_type;  -- count of existing attr assign without version_id
   ta_attr_identical_count           number_type; -- count where the assignment values in the
                                                  -- target attr table are identical to the assignment
                                                  -- from the interface table

   tfa_attribute_id                  number_type;
   tfa_dim_attr_numeric_member       number_type;
   tfa_number_assign_value           number_type;
   tfa_version_id                    number_type;
   tfa_attr_assign_vs_id             number_type;

   ta_date_assign_value              date_type;
   ta_temp_date_assign_value         date_type;
   tfa_date_assign_value             date_type;
   ta_cal_period_end_date            date_type;

   ta_attribute_varchar_label        varchar2_std_type;
   ta_attr_value_column_name         varchar2_std_type;
   ta_attribute_data_type_code       varchar2_std_type;
   ta_dim_attr_varchar_member        varchar2_std_type;
   ta_status                         varchar2_std_type;
   ta_adj_period_flag                flag_type;
   ta_protected_assign_flag          flag_type;
   ta_use_interim_table_flag         flag_type;  -- identifies assignment rows where
                                                 -- we need to insert into the interim
                                                 -- tables prior to moving into FEM

   tfa_dim_attr_varchar_member       varchar2_std_type;
   tfa_status                        varchar2_std_type;

   ta_member_dc                      varchar2_150_type;
   ta_value_set_dc                   varchar2_150_type;
   ta_version_display_code           varchar2_150_type;
   ta_attr_assign_vs_dc              varchar2_150_type;

   tfa_member_dc                     varchar2_150_type;
   tfa_value_set_dc                  varchar2_150_type;

   ta_attribute_required_flag        flag_type;
   ta_allow_mult_assign_flag          flag_type;
   ta_read_only_flag                 flag_type;
   ta_allow_mult_versions_flag       flag_type;

   ta_language                       lang_type;

   ta_varchar_assign_value           varchar2_1000_type;
   ta_attribute_assign_value         varchar2_1000_type;
   tfa_varchar_assign_value          varchar2_1000_type;

   ta_member_read_only_flag          flag_type; -- member read_only flag;  If
                                                -- 'Y', no attributes can be
                                                -- modified by the loader

   -- table variables used in Interim processing for Cal Periods
   ta_cal_period_number              number_type;
   ta_calendar_dc                    varchar2_std_type;
   ta_dimension_group_dc             varchar2_std_type;
   ta_dimension_group_id             number_type;
   ta_calendar_id                    number_type;

   -- variables for holding attributes of CAL_PERIOD
   ta_calpattr_cal_dc                varchar2_std_type;
   ta_calpattr_dimgrp_dc             varchar2_std_type;
   ta_calpattr_end_date              date_type;
   ta_calpattr_period_num            number_type;


---------------------
-- Declare cursors --
---------------------
   cv_get_attr_rows      cv_curs;

   v_session_sql varchar2(1000);

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

      FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_1,c_block||'.'||c_proc_name||'.attr_final_count'
      ,v_attr_final_count);

   --x_status := 0; -- initialize status of the Attr_Assign_Update procedure
   --x_message := 'COMPLETE:NORMAL';

   v_temp_rows_rejected := 0;  -- reset this temp counter so we can count invalid
                               -- attr records as we go

   build_attr_select_stmt (p_dimension_varchar_label
                          ,p_dimension_id
                          ,p_source_b_table
                          ,p_source_attr_table
                          ,p_target_b_table
                          ,p_member_t_dc_col
                          ,p_member_dc_col
                          ,p_member_col
                          ,p_value_set_required_flag
                          ,p_shared_dimension_flag
                          ,p_hier_dimension_flag
                          ,'N'
                          ,'N'
                          ,p_exec_mode_clause
                          ,x_attr_select_stmt);

   IF p_data_slc IS NOT NULL THEN
      x_attr_select_stmt := REPLACE(x_attr_select_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_attr_select_stmt := REPLACE(x_attr_select_stmt,'{{data_slice}}','1=1');
   END IF;


   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.attr select stmt'
   ,x_attr_select_stmt);

   build_does_attr_exist_stmt (p_target_attr_table
                              ,p_target_b_table
                              ,p_member_col
                              ,p_member_dc_col
                              ,p_value_set_required_flag
                              ,'Y'
                              ,x_does_attr_exist_stmt);


   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.does attr exist for version stmt'
   ,x_does_attr_exist_stmt);


   build_does_attr_exist_stmt (p_target_attr_table
                              ,p_target_b_table
                              ,p_member_col
                              ,p_member_dc_col
                              ,p_value_set_required_flag
                              ,'N'
                              ,x_does_attr_exist_novers_stmt);

   build_get_identical_assgn_stmt (p_target_attr_table
                                ,p_target_b_table
                                ,p_member_col
                                ,p_member_dc_col
                                ,p_value_set_required_flag
                                ,p_date_format_mask
                                ,x_identical_attr_select_stmt);

   build_attr_update_stmt (p_target_attr_table
                          ,p_target_b_table
                          ,p_member_dc_col
                          ,p_member_col
                          ,p_value_set_required_flag
                          ,x_attr_update_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.attr update stmt'
   ,x_attr_update_stmt);

   build_delete_stmt (p_source_attr_table
                     ,x_delete_attr_stmt);

   build_special_delete_stmt (p_source_attr_table
                             ,x_special_delete_attr_stmt);


   build_insert_attr_stmt (p_target_attr_table
                          ,p_target_b_table
                          ,p_member_col
                          ,p_member_dc_col
                          ,p_value_set_required_flag
                          ,x_insert_attr_stmt);

   FEM_ENGINES_PKG.TECH_MESSAGE
   (c_log_level_1,c_block||'.'||c_proc_name||'.insert attr stmt'
   ,x_insert_attr_stmt);

   build_status_update_stmt (p_source_attr_table
                            ,x_update_attr_status_stmt);

   -- special insert stmts for the INTERIM tables for CAL_PERIOD loads
   IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
      build_calp_interim_insert_stmt(x_calp_interim_stmt
                                    ,x_calp_attr_interim_stmt);
   END IF;


   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop
   LOOP

         FEM_Multi_Proc_Pkg.Get_Data_Slice(
           x_slc_id => v_slc_id,
           x_slc_val1 => v_slc_val,
           x_slc_val2 => v_slc_val2,
           x_slc_val3 => v_slc_val3,
           x_slc_val4 => v_slc_val4,
           x_num_vals  => v_num_vals,
           x_part_name => v_part_name,
           p_req_id => p_master_request_id,
           p_proc_num => p_proc_num);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
          ,v_slc_val);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
          ,v_slc_val2);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
          ,v_slc_val3);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
          ,v_slc_val4);

         EXIT WHEN (v_slc_id IS NULL);

      -----------------------------------------------------
      -- Bulk Collect ATTR_T Rows for non-simple dimensions
      -- Using Dynamic SELECT Statement
      -----------------------------------------------------
      OPEN cv_get_attr_rows FOR x_attr_select_stmt USING v_slc_val, v_slc_val2;

      LOOP  -- ATTR Collection Loop
         FETCH cv_get_attr_rows BULK COLLECT INTO
            ta_rowid
           ,ta_member_read_only_flag
           ,ta_attribute_id
           ,ta_attribute_varchar_label
           ,ta_attribute_dimension_id
           ,ta_attr_value_column_name
           ,ta_attribute_data_type_code
           ,ta_attribute_required_flag
           ,ta_read_only_flag
           ,ta_allow_mult_versions_flag
           ,ta_allow_mult_assign_flag
           ,ta_member_dc
           ,ta_value_set_dc
           ,ta_member_id
           ,ta_value_set_id
           ,ta_attribute_assign_value
           ,ta_dim_attr_numeric_member
           ,ta_dim_attr_varchar_member
           ,ta_number_assign_value
           ,ta_varchar_assign_value
           ,ta_date_assign_value
           ,ta_version_display_code
           ,ta_version_id
           ,ta_attr_assign_vs_dc
           ,ta_attr_assign_vs_id
           ,ta_cal_period_end_date
           ,ta_status
           ,ta_use_interim_table_flag
           ,ta_cal_period_number
           ,ta_calendar_dc
           ,ta_calendar_id
           ,ta_dimension_group_dc
           ,ta_dimension_group_id
           ,ta_calpattr_cal_dc
           ,ta_calpattr_dimgrp_dc
           ,ta_calpattr_end_date
           ,ta_calpattr_period_num
      LIMIT p_fetch_limit;

         v_attr_last_row := ta_attribute_id.LAST;
         IF (v_attr_last_row IS NULL) THEN
 	    EXIT;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr_last_row'
         ,v_attr_last_row);

         FOR j IN 1..v_attr_last_row
         LOOP

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_label'
            ,ta_attribute_varchar_label(j));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_assign_value'
            ,ta_attribute_assign_value(j));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attr_value_column_name'
            ,ta_attr_value_column_name(j));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.use_interim_table_flag'
            ,ta_use_interim_table_flag(j));

            -- Bug#4429725
            -- reset the attr_final_count variable
            v_attr_final_count := 0;

            -----------------------------------------
            -- BEGIN ATTR VALIDATIONS

            -----------------------------------------
            -- Bug#3822561 Support for attributes of CAL_PERIOD
            -- if the attribute_dimension_id = 1 (CAL_PERIOD)
            -- then we construct a CAL_PERIOD_ID from the
            -- special CALP columns and move it into the
            -- ta_attribute_assign_value(j)
            -----------------------------------------
            IF ta_attribute_dimension_id(j) = 1 THEN
               get_attr_assign_calp(ta_attribute_assign_value(j)
                                   ,ta_status(j)
                                   ,ta_calpattr_cal_dc(j)
                                   ,ta_calpattr_dimgrp_dc(j)
                                   ,ta_calpattr_end_date(j)
                                   ,ta_calpattr_period_num(j));
            END IF;
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_assign_value - post conv'
            ,ta_attribute_assign_value(j));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.status post conv'
            ,ta_status(j));

            -----------------------------------------
            --    validate version_display_code
            -----------------------------------------
            get_attr_version (p_dimension_varchar_label
                             ,ta_attribute_varchar_label(j)
                             ,ta_version_display_code(j)
                             ,ta_version_id(j));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attribute version id'
            ,ta_version_id(j));

            ----------------------------------------------------------
            -- Initialize variables - in case status <> 'LOAD'
            -- we still need values for the variables so we don't
            -- array element error
            ----------------------------------------------------------
            -- assume adj_period_flag = 'Y' for all cal_period
            -- this will get updated to 'N' later if appropriate
            IF p_dimension_Varchar_label = 'CAL_PERIOD' THEN
               ta_adj_period_flag(j) := 'Y';
            END IF;
            -- Assume the attr assignment doesn't exist
            ta_attr_exists_count(j) := 0;
            ta_multattr_exists_count(j) := 0;
            -- initializing the date field
            -- this will get updated appropriately for CAL_PERIOD members
            -- during the overlap check
            -- we use the temp variable later on for comparisons
            -- where we would expect it to be null
            ta_temp_date_assign_value(j) := ta_date_assign_value(j);
            ta_date_assign_value(j) := to_date('12/31/2499','MM/DD/YYYY');
            ------------------------------------------------------------------


            ------------------------------------------
            --  Member Read Only Flag validation
            -- Main IF for attr validation
            ------------------------------------------
            IF ta_member_read_only_flag(j) = 'N' AND ta_status(j) = 'LOAD'THEN

               -----------------------------------------
               -- validate attribute_assign_value
               -----------------------------------------
               -- VARCHAR_ASSIGN_VALUE
               IF (ta_attr_value_column_name(j) = 'VARCHAR_ASSIGN_VALUE'
                  AND ta_attribute_assign_value(j) IS NOT NULL
                  AND ta_version_id(j) IS NOT NULL) THEN

                  ta_varchar_assign_value(j)
                     := to_char(ta_attribute_assign_value(j));
               -- NUMBER_ASSIGN_VALUE
               ELSIF (ta_attr_value_column_name(j) = 'NUMBER_ASSIGN_VALUE'
                  AND ta_attribute_assign_value(j) IS NOT NULL
                     AND ta_version_id(j) IS NOT NULL) THEN
                  BEGIN
                     ta_number_assign_value(j) := to_number(ta_attribute_assign_value(j));

                     -- Special validation for ACCOUNTING_YEAR
                     -- ensures that the ACCOUNTING_YEAR value
                     -- is within the year range supported
                     IF p_dimension_varchar_label = 'CAL_PERIOD' AND
                        ta_attribute_varchar_label(j) = 'ACCOUNTING_YEAR' AND
                        (ta_number_assign_value(j) < 1900 OR
                        ta_number_assign_value(j) >= 2599) THEN
                        RAISE e_invalid_acct_year;
                     END IF;

                  EXCEPTION
                     WHEN e_invalid_number THEN
                           ta_status(j) := 'INVALID_NUMBER';
                     WHEN e_invalid_number1722 THEN
                           ta_status(j) := 'INVALID_NUMBER';
                     WHEN e_invalid_acct_year THEN
                        ta_status(j) := 'INVALID_ACCOUNTING_YEAR';

                  END;  -- NUMBER_ASSIGN_VALUE
               -- DATE_ASSIGN_VALUE
               ELSIF (ta_attr_value_column_name(j) = 'DATE_ASSIGN_VALUE'
                  AND ta_attribute_assign_value(j) IS NOT NULL
                  AND ta_version_id(j) IS NOT NULL) THEN
                  BEGIN
                     ta_date_assign_value(j) := to_date(ta_attribute_assign_value(j),p_date_format_mask);
                     ta_temp_date_assign_value(j) := to_date(ta_attribute_assign_value(j),p_date_format_mask);

                     -- Special validation for CAL_PERIOD_START_DATE
                     -- looking for existing cal periods where adj_period_flag='N'
                     -- where there is a start_date entry in the ATTR_T table
                     -- that overlaps with the start_date that is being "updated"
                     -- We are only checking within our data slice, since
                     -- if the overlap is in a separate data slice, the main
                     -- check on "existing" overlap records will catch it

                     IF p_dimension_varchar_label = 'CAL_PERIOD' AND
                       ta_attribute_varchar_label(j) = 'CAL_PERIOD_START_DATE' THEN

                       IF ta_cal_period_end_date(j) < ta_date_assign_value(j) THEN
                          RAISE e_invalid_calp_start_date;
                       END IF;

                        -- First check to see if the cal period with the new start
                        -- date is not an adj. period and it does not have an identical
                        -- start_date to its existing record in the "real" db
                        -- we exlude situations where the start_date is identical for
                        -- the same cal_period_id because the load is not changing
                        -- anything
                        x_adj_period_stmt := 'select count(*)'||
                        ' from fem_cal_periods_attr A1, fem_dim_attributes_b DA1'||
                        ',fem_dim_attr_versions_b V1'||
                        ',fem_cal_periods_attr A2, fem_dim_attributes_b DA2'||
                        ',fem_dim_attr_Versions_b V2'||
                        ' where to_char(A1.cal_period_id) = :b_mbr_dc'||
                        ' and A1.attribute_id = DA1.attribute_id'||
                        ' and DA1.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                        ' and DA1.dimension_id = 1'||
                        ' and A1.dim_attribute_varchar_member = ''N'''||
                        ' and A1.version_id = V1.version_id'||
                        ' and V1.attribute_id = DA1.attribute_id'||
                        ' and V1.aw_snapshot_flag = ''N'''||
                        ' and V1.default_version_flag =''Y'''||
                        ' and A1.cal_period_id = A2.cal_period_id'||
                        ' and A2.date_assign_value '||
                        ' <> :b_date_assign'||
                        ' and A2.attribute_id = DA2.attribute_id'||
                        ' and DA2.attribute_varchar_label = ''CAL_PERIOD_START_DATE'''||
                        ' and DA2.dimension_id=1'||
                        ' and A2.version_id = V2.version_id'||
                        ' and V2.attribute_id = DA2.attribute_id'||
                        ' and V2.aw_snapshot_flag = ''N'''||
                        ' and V2.default_version_flag = ''Y''';

                        /*************************************************
                        bug#5060746 comment out to use bind variables
                        x_adj_period_stmt := 'select count(*)'||
                        ' from fem_cal_periods_attr A1, fem_dim_attributes_b DA1'||
                        ',fem_dim_attr_versions_b V1'||
                        ',fem_cal_periods_attr A2, fem_dim_attributes_b DA2'||
                        ',fem_dim_attr_Versions_b V2'||
                        ' where to_char(A1.cal_period_id) = '''||ta_member_dc(j)||''''||
                        ' and A1.attribute_id = DA1.attribute_id'||
                        ' and DA1.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                        ' and DA1.dimension_id = 1'||
                        ' and A1.dim_attribute_varchar_member = ''N'''||
                        ' and A1.version_id = V1.version_id'||
                        ' and V1.attribute_id = DA1.attribute_id'||
                        ' and V1.aw_snapshot_flag = ''N'''||
                        ' and V1.default_version_flag =''Y'''||
                        ' and A1.cal_period_id = A2.cal_period_id'||
                        ' and A2.date_assign_value '||
                        ' <> to_date('''||to_char(ta_date_assign_value(j),p_date_format_mask)||''','''||p_date_format_mask||''')'||
                        ' and A2.attribute_id = DA2.attribute_id'||
                        ' and DA2.attribute_varchar_label = ''CAL_PERIOD_START_DATE'''||
                        ' and DA2.dimension_id=1'||
                        ' and A2.version_id = V2.version_id'||
                        ' and V2.attribute_id = DA2.attribute_id'||
                        ' and V2.aw_snapshot_flag = ''N'''||
                        ' and V2.default_version_flag = ''Y''';
                        *****************************************************************/

                         EXECUTE IMMEDIATE x_adj_period_stmt INTO v_nonadj_period_count
                         USING ta_member_dc(j),ta_date_assign_value(j);

                        -- If not an adjustment period, then we need to check for
                        -- date overlap
                        IF v_nonadj_period_count > 0 THEN
                           ta_adj_period_flag(j) := 'N';
                           -- query to see if any records exist for the same
                           -- calendar/dimgrp in the offical db
                           -- where:
                           -- (new) array_start_date <= table.end_date AND
                           -- array_end_date >= table.start_date
                           -- and the existing periods are not adj periods
                           -- and the offending records have a diff cal_period_id
                           -- than the one being loaded
                           -- and the offending cal_periods are enabled=Y
                           x_overlap_sql_stmt :=
                           'select count(*)'||
                           ' from fem_cal_periods_attr CS, fem_cal_periods_attr CE,'||
                           ' fem_cal_periods_b C,'||
                           ' fem_dimension_grps_b D,'||
                           ' fem_dim_attributes_b AE,'||
                           ' fem_dim_attr_Versions_b VE,'||
                           ' fem_cal_periods_attr CP,'||
                           ' fem_dim_attributes_b AP,'||
                           ' fem_dim_attr_versions_b VP'||
                           ' where CS.cal_period_id = C.cal_period_id'||
                           ' and to_char(C.cal_period_id) <> :b_mbr_dc'||
                           ' and C.cal_period_id = CP.cal_period_id'||
                           ' and C.enabled_flag = ''Y'''||
                           ' and CP.attribute_id = AP.attribute_id'||
                           ' and CP.version_id = VP.version_id'||
                           ' and CP.dim_attribute_varchar_member = ''N'''||
                           ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                           ' and AP.dimension_id = 1'||
                           ' and AP.attribute_id = VP.attribute_id'||
                           ' and VP.default_version_flag = ''Y'''||
                           ' and VP.aw_snapshot_flag = ''N'''||
                           ' and C.calendar_id = :b_cal_id'||
                           ' and C.dimension_group_id = D.dimension_group_id'||
                           ' and D.time_dimension_group_key = :b_dimgrp_key'||
                           ' and D.dimension_id = 1'||
                           ' and CS.attribute_id = :b_attr_id'||
                           ' and CS.version_id = :b_vers_id'||
                           ' and CE.date_assign_value'||
                           ' >= :b_new_start_date'||
                           ' and CS.cal_period_id = CE.cal_period_id'||
                           ' and CE.attribute_id = AE.attribute_id'||
                           ' and AE.attribute_varchar_label = ''CAL_PERIOD_END_DATE'''||
                           ' and AE.dimension_id = 1'||
                           ' and CE.version_id = VE.version_id'||
                           ' and VE.aw_snapshot_flag = ''N'''||
                           ' and VE.default_version_flag = ''Y'''||
                           ' and VE.attribute_id = AE.attribute_id'||
                           ' and CS.date_assign_value'||
                           ' <= :b_new_end_date';


                           /*************************************************
                           bug#5060746 comment out to use bind variables

                           x_overlap_sql_stmt :=
                           'select count(*)'||
                           ' from fem_cal_periods_attr CS, fem_cal_periods_attr CE,'||
                           ' fem_cal_periods_b C,'||
                           ' fem_dimension_grps_b D,'||
                           ' fem_dim_attributes_b AE,'||
                           ' fem_dim_attr_Versions_b VE,'||
                           ' fem_cal_periods_attr CP,'||
                           ' fem_dim_attributes_b AP,'||
                           ' fem_dim_attr_versions_b VP'||
                           ' where CS.cal_period_id = C.cal_period_id'||
                           ' and to_char(C.cal_period_id) <>'''||ta_member_dc(j)||''''||
                           ' and C.cal_period_id = CP.cal_period_id'||
                           ' and C.enabled_flag = ''Y'''||
                           ' and CP.attribute_id = AP.attribute_id'||
                           ' and CP.version_id = VP.version_id'||
                           ' and CP.dim_attribute_varchar_member = ''N'''||
                           ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                           ' and AP.dimension_id = 1'||
                           ' and AP.attribute_id = VP.attribute_id'||
                           ' and VP.default_version_flag = ''Y'''||
                           ' and VP.aw_snapshot_flag = ''N'''||
                           ' and C.calendar_id = '||substr(ta_member_dc(j),23,5)||
                           ' and C.dimension_group_id = D.dimension_group_id'||
                           ' and D.time_dimension_group_key = '||substr(ta_member_dc(j),28,5)||
                           ' and D.dimension_id = 1'||
                           ' and CS.attribute_id = '||ta_attribute_id(j)||
                           ' and CS.version_id = '||ta_version_id(j)||
                           ' and CE.date_assign_value'||
                           ' >= :b_new_start_date'||
                           ' and CS.cal_period_id = CE.cal_period_id'||
                           ' and CE.attribute_id = AE.attribute_id'||
                           ' and AE.attribute_varchar_label = ''CAL_PERIOD_END_DATE'''||
                           ' and AE.dimension_id = 1'||
                           ' and CE.version_id = VE.version_id'||
                           ' and VE.aw_snapshot_flag = ''N'''||
                           ' and VE.default_version_flag = ''Y'''||
                           ' and VE.attribute_id = AE.attribute_id'||
                           ' and CS.date_assign_value'||
                           ' <= :b_new_end_date';

                           **************************************************/

                           FEM_ENGINES_PKG.TECH_MESSAGE
                           (c_log_level_1,c_block||'.'||c_proc_name||'.overlap_sql_stmt3'
                           ,x_overlap_sql_stmt);

                           EXECUTE IMMEDIATE x_overlap_sql_stmt INTO v_overlap_count
                              USING ta_member_dc(j)
                                   ,substr(ta_member_dc(j),23,5)
                                   ,substr(ta_member_dc(j),28,5)
                                   ,ta_attribute_id(j)
                                   ,ta_version_id(j)
                                   ,ta_date_assign_value(j)
                                   ,ta_cal_period_end_date(j);

                           IF v_overlap_count > 0 THEN
                              ta_status(j) := 'OVERLAP_EXIST_START_DATE';
                              FEM_ENGINES_PKG.TECH_MESSAGE
                              (c_log_level_1,c_block||'.'||c_proc_name||'.overlap_count'
                              ,v_overlap_count);

                           END IF;
                        /************************************************8
                        ELSE  -- query to see if any records exist for the same
                              -- calendar/dimgrp in the offical db
                              -- where start_date >= x and start_date <= y
                              -- (where x is the new start date and
                              --  y is the new end date)
                              -- and the existing periods are not adj periods
                              -- and the offending records have a diff cal_period_id
                              -- than the one being loaded
                              -- and the offending cal_periods are enabled=Y
                           x_overlap_sql_stmt :=
                           'select count(*)'||
                           ' from fem_cal_periods_attr CS'||
                           ',fem_cal_periods_b C'||
                           ',fem_dimension_grps_b D'||
                           ',fem_cal_periods_attr CP'||
                           ',fem_dim_attributes_b AP'||
                           ',fem_dim_attr_versions_b VP'||
                           ' where CS.cal_period_id = C.cal_period_id'||
                           ' and to_char(C.cal_period_id) <>'''||ta_member_dc(j)||''''||
                           ' and C.cal_period_id = CP.cal_period_id'||
                           ' and C.enabled_flag = ''Y'''||
                           ' and CP.attribute_id = AP.attribute_id'||
                           ' and CP.version_id = VP.version_id'||
                           ' and CP.dim_attribute_varchar_member = ''N'''||
                           ' and AP.attribute_varchar_label = ''ADJ_PERIOD_FLAG'''||
                           ' and AP.dimension_id = 1'||
                           ' and AP.attribute_id = VP.attribute_id'||
                           ' and VP.default_version_flag = ''Y'''||
                           ' and VP.aw_snapshot_flag = ''N'''||
                           ' and C.calendar_id = '||substr(ta_member_dc(j),23,5)||
                           ' and C.dimension_group_id = D.dimension_group_id'||
                           ' and D.time_dimension_group_key = '||substr(ta_member_dc(j),28,5)||
                           ' and CS.attribute_id = '||ta_attribute_id(j)||
                           ' and CS.version_id = '||ta_version_id(j)||
                           ' and to_char(CS.date_assign_value,'''||p_date_format_mask||''')'||
                           ' >= '''||to_char(ta_date_assign_value(j),p_date_format_mask)||''''||
                           ' and to_char(CS.date_assign_value,''j'')'||
                           ' <= '||to_char(substr(ta_member_dc(j),1,7));

                           FEM_ENGINES_PKG.TECH_MESSAGE
                           (c_log_level_1,c_block||'.'||c_proc_name||'.overlap_sql_stmt4'
                           ,x_overlap_sql_stmt);
                           EXECUTE IMMEDIATE x_overlap_sql_stmt INTO v_overlap_count;

                           IF v_overlap_count > 0 THEN
                              ta_status(j) := 'OVERLAP_EXIST_START_DATE';
                           END IF;
                        END IF; -- overlap if  */
                        ELSE
                           ta_adj_period_flag(j) := 'Y';
                        END IF; -- adj_period_flag count if
                     END IF; -- attribute is start_date
                     --End Special Checks for CAL Period
                  ----------------------------------------------------------------
                  EXCEPTION
                     WHEN e_invalid_calp_start_date THEN
                        ta_status(j) := 'INVALID_CAL_PERIOD_START_DATE';
                     WHEN e_date_string_too_long THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date_format THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date_numeric THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date_between THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date_year THEN
                        ta_status(j) := 'INVALID_DATE';
                     WHEN e_invalid_date_day THEN
                        ta_status(j) := 'INVALID_DATE';
                  END; -- DATE_ASSIGN_VALUE
               ELSIF (ta_attr_value_column_name(j) IN
                  ('DIM_ATTRIBUTE_VARCHAR_MEMBER', 'DIM_ATTRIBUTE_NUMERIC_MEMBER')
                  AND ta_attribute_assign_value(j) IS NOT NULL
                  AND ta_version_id(j) IS NOT NULL) THEN

                  --------------------------------------------------
                  -- get the Value Set ID for the assigned attribute
                  -- 9/15/2004 RCF Modify this section so that if the
                  -- attr_assign_vs_dc doesn't exist for the specified dimension
                  -- the row fails
                  -- Note that the INVALID_ATTR_ASSIGN_VS status will never
                  -- appear, since the INVALID_DIM_ASSIGNMENT will overwrite it
                  -- in the case of a bad VS being specified for a member
                  --------------------------------------------------
                  IF (ta_attr_assign_vs_dc(j) IS NOT NULL) THEN
                     BEGIN
                        SELECT value_set_id
                        INTO ta_attr_assign_vs_id(j)
                        FROM fem_value_sets_b
                        WHERE value_set_display_code = ta_attr_assign_vs_dc(j)
                        AND dimension_id = ta_attribute_dimension_id(j);
                     EXCEPTION
                        WHEN no_data_found THEN
                           ta_status(j) := 'INVALID_ATTR_ASSIGN_VALUE_SET';
                     END;
                  END IF;

                  verify_attr_member (ta_attribute_varchar_label(j)
                                     ,p_dimension_varchar_label
                                     ,ta_attribute_assign_value(j)
                                     ,ta_attr_assign_vs_dc(j)
                                     ,v_attr_success
                                     ,v_temp_member);
                  IF (v_attr_success = 'N') THEN
                     ta_status(j) := 'INVALID_DIM_ASSIGNMENT';
                  ELSIF (v_attr_success = 'MISSING_ATTR_ASSIGN_VS') THEN
                         ta_status(j) := 'MISSING_ATTR_ASSIGN_VS';
                  ELSE -- DIM Assignment is good
                     IF (ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_VARCHAR_MEMBER') THEN
                        ta_dim_attr_varchar_member(j) := to_char(v_temp_member);
                     ELSE
                        ta_dim_attr_numeric_member(j) := to_number(v_temp_member);
                     END IF; -- Choice between VARCHAR and NUMERIC Dim members
                  END IF;  -- attr_success=N
               ELSIF (ta_version_id(j) IS NULL) THEN-- Version is NULL
                  ta_status(j) := 'INVALID_VERSION';

               ELSE -- Assignment is NULL or Assignment Column not valid
                  ta_status(j) := 'INVALID_ATTRIBUTE_ASSIGNMENT';

               END IF; -- Main IF on validating the attributes
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_status'
               ,ta_status(j));

               -----------------------------------------------------------------
               -- Check to see if the attribute row already exists in the _ATTR table
               -----------------------------------------------------------------
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_id'
               ,ta_attribute_id(j));

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.version_id'
               ,ta_version_id(j));

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.member display code'
               ,ta_member_dc(j));

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.value_set display code'
               ,ta_value_set_dc(j));

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.value_set_id'
               ,ta_value_set_id(j));

               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.member_id'
               ,ta_member_id(j));


               -- Check if the attribute assignment exists for any version
               IF (ta_status(j) = 'LOAD') AND (p_value_set_required_flag = 'Y' ) THEN
                  EXECUTE IMMEDIATE x_does_attr_exist_novers_stmt
                  INTO ta_attr_exists_novers_count(j), ta_protected_assign_flag(j)
                  USING ta_attribute_id(j)
                       ,ta_member_id(j)
                       ,ta_value_set_id(j);
               ELSIF (ta_status(j) = 'LOAD') AND (p_value_set_required_flag = 'N' ) THEN
                  IF p_member_col = p_member_dc_col THEN
                     EXECUTE IMMEDIATE x_does_attr_exist_novers_stmt
                     INTO ta_attr_exists_novers_count(j), ta_protected_assign_flag(j)
                     USING ta_attribute_id(j)
                       ,ta_member_dc(j);
                  ELSE
                     EXECUTE IMMEDIATE x_does_attr_exist_novers_stmt
                     INTO ta_attr_exists_novers_count(j), ta_protected_assign_flag(j)
                     USING ta_attribute_id(j)
                       ,ta_member_id(j);

                  END IF;
               ELSE
                  ta_attr_exists_novers_count(j) := 0;
               END IF; -- value_set_required

               -- Check if the attr assignment exists for the specific version
               IF (ta_status(j) = 'LOAD') AND (p_value_set_required_flag = 'Y' )
                  AND (ta_allow_mult_assign_flag(j) = 'N') THEN
                  EXECUTE IMMEDIATE x_does_attr_exist_stmt
                  INTO ta_attr_exists_count(j), ta_protected_assign_flag(j)
                  USING ta_attribute_id(j)
                       ,ta_version_id(j)
                       ,ta_member_id(j)
                       ,ta_value_set_id(j);

               ELSIF (ta_status(j) = 'LOAD') AND (p_value_set_required_flag = 'N' )
                  AND (ta_allow_mult_assign_flag(j) = 'N') THEN
                  IF p_member_col = p_member_dc_col THEN

                     EXECUTE IMMEDIATE x_does_attr_exist_stmt
                     INTO ta_attr_exists_count(j), ta_protected_assign_flag(j)
                     USING ta_attribute_id(j)
                          ,ta_version_id(j)
                          ,ta_member_dc(j);
                  ELSE
                     EXECUTE IMMEDIATE x_does_attr_exist_stmt
                     INTO ta_attr_exists_count(j), ta_protected_assign_flag(j)
                     USING ta_attribute_id(j)
                          ,ta_version_id(j)
                          ,ta_member_id(j);
                  END IF;
               ELSIF (ta_status(j) = 'LOAD')
                  AND (p_value_set_required_flag = 'Y')
                  AND (ta_allow_mult_assign_flag(j) = 'Y') THEN

                  build_does_multattr_exist_stmt (p_target_attr_table
                                 ,p_target_b_table
                                 ,p_member_col
                                 ,p_member_dc_col
                                 ,p_value_set_required_flag
                                 ,ta_attr_value_column_name(j)
                                 ,ta_attr_assign_vs_id(j)
                                 ,x_does_multattr_exist_stmt);

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.does multattr vs exist stmt'
                  ,x_does_multattr_exist_stmt);

                   IF ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
                      AND ta_attr_assign_vs_id(j) IS NOT NULL THEN

                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_value_set_id(j)
                            ,ta_dim_attr_numeric_member(j)
                            ,ta_attr_assign_vs_id(j);

                   ELSIF ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
                      AND ta_attr_assign_vs_id(j) IS NULL THEN

                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_value_set_id(j)
                            ,ta_dim_attr_numeric_member(j);

                   ELSE
                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_value_set_id(j)
                            ,ta_dim_attr_varchar_member(j);
                   END IF;

               ELSIF (ta_status(j) = 'LOAD')
                  AND (p_value_set_required_flag = 'N')
                  AND (ta_allow_mult_assign_flag(j) = 'Y') THEN

                  build_does_multattr_exist_stmt (p_target_attr_table
                                 ,p_target_b_table
                                 ,p_member_col
                                 ,p_member_dc_col
                                 ,p_value_set_required_flag
                                 ,ta_attr_value_column_name(j)
                                 ,ta_attr_assign_vs_id(j)
                                 ,x_does_multattr_exist_stmt);

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.does multattr exist stmt'
                  ,x_does_multattr_exist_stmt);

                   IF ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
                      AND ta_attr_assign_vs_id(j) IS NOT NULL THEN

                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_dim_attr_numeric_member(j)
                            ,ta_attr_assign_vs_id(j);

                   ELSIF ta_attr_value_column_name(j) = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
                      AND ta_attr_assign_vs_id(j) IS NULL THEN

                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_dim_attr_numeric_member(j);

                   ELSE
                       EXECUTE IMMEDIATE x_does_multattr_exist_stmt
                       INTO ta_multattr_exists_count(j)
                       USING ta_attribute_id(j)
                            ,ta_version_id(j)
                            ,ta_member_id(j)
                            ,ta_dim_attr_varchar_member(j);
                   END IF;


               ELSE
                  ta_attr_exists_count(j) := 0;
                  ta_multattr_exists_count(j) := 0;
               END IF; -- value_set_required
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.does_attr_exist'
               ,null);

              ---------------------------------------------------
              -- Bug#5024575
              -- 7/6/2006 For Multi-assignment attributes, we can't update,
              -- we can only insert.  Because of this, when we encounter
              -- an assignment that already exists for the specific
              -- dim_attribute_numeric_member/varchar_member/vs combination,
              -- we update the STATUS as an error.
              --
              -- In the future, if users decide they don't want this to be
              -- an error, we can make a special delete to remove the row
              -- from the interface table.  The important thing is that we
              -- cannot insert (since the key for that assignment already exists)
              ---------------------------------------------------
               IF ta_status(j) = 'LOAD' THEN
                  IF (ta_attr_exists_count(j) = 0 AND ta_attr_exists_novers_count(j) > 0
                      AND ta_allow_mult_assign_flag(j) = 'N') THEN
                     ta_status(j) := 'MULT_VERSION_NOT_ALLOWED';
                  ELSIF ta_allow_mult_assign_flag(j) = 'N'
                     AND ta_protected_assign_flag(j) = 'Y' THEN
                     ta_status(j) := 'PROTECTED_ATTR_ASSIGN';
                  ELSIF ta_allow_mult_assign_flag(j) = 'Y'
                     AND ta_multattr_exists_count(j) >0 THEN
                      ta_status(j) := 'DUPLICATE_MULTI_ASSIGN';
                  END IF;
               END IF;

              ----------------------------------------------------------------------
              --Bug#3925655  For assignment_is_read_only_flag='Y' attributes,
              -- we need to identify if the assignment coming from the interface
              -- table is identical to the existing assignment.  If it is, we want
              -- to go ahead and let it update.
              -- If it is not identical, we want to mark the row with an ERROR status
              ----------------------------------------------------------------------
               IF (ta_status(j) = 'LOAD') AND (ta_read_only_flag(j) = 'Y') THEN
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.identical attr select stmt'
                  ,x_identical_attr_select_stmt);

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.dim_attr_numeric'
                  ,ta_dim_attr_numeric_member(j));
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.attr_assign_vs'
                  ,ta_attr_assign_vs_id(j));
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.dim_attr_varchar'
                  ,ta_dim_attr_varchar_member(j));
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.number_assign'
                  ,ta_number_assign_value(j));
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.varchar_assign'
                  ,ta_varchar_assign_value(j));
                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.date_assign'
                  ,to_char(ta_temp_date_assign_value(j),'YYYY/MM/DD'));

                  -- we use a temp variable to handle the case where
                  -- we have set the date_assign_value to 2499/12/31

                  IF (p_value_set_required_flag = 'Y' ) THEN
                     EXECUTE IMMEDIATE x_identical_attr_select_stmt
                     INTO ta_attr_identical_count(j)
                        USING ta_attribute_id(j)
                       ,ta_version_id(j)
                       ,ta_value_set_dc(j)
                       ,ta_member_dc(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_number_assign_value(j)
                       ,ta_number_assign_value(j)
                       ,ta_number_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,ta_temp_date_assign_value(j);

                  ELSIF (p_value_set_required_flag = 'N' ) THEN
                     EXECUTE IMMEDIATE x_identical_attr_select_stmt
                     INTO ta_attr_identical_count(j)
                     USING ta_attribute_id(j)
                       ,ta_version_id(j)
                       ,ta_member_dc(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_dim_attr_numeric_member(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_number_assign_value(j)
                       ,ta_number_assign_value(j)
                       ,ta_number_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,ta_temp_date_assign_value(j);
                  END IF; -- value_set_required

                  FEM_ENGINES_PKG.TECH_MESSAGE
                  (c_log_level_1,c_block||'.'||c_proc_name||'.identical_count'
                  ,ta_attr_identical_count(j));

                  IF ta_attr_identical_count(j) = 0 THEN
                     ta_status(j) := 'READ_ONLY_ATTRIBUTE';
                  END IF;
               END IF;  -- read_only_flag validation
            ------------------------------------------------------------------
            ELSIF  ta_member_read_only_flag(j) = 'Y'
                    AND ta_status(j) = 'LOAD' THEN
               BEGIN
                  ta_status(j) := 'MEMBER_IS_READ_ONLY';
                  ta_attr_exists_count(j) := 1;
               END;
            END IF;  -- Member_read_only_flag = 'N'


            -- Count the error rows
            IF ta_status(j) <> 'LOAD' THEN
               v_temp_rows_rejected := v_temp_rows_rejected + 1;
            END IF;

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.v_temp_rows_rejected'
            ,v_temp_rows_rejected);

         END LOOP; -- attr_validations
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr_validation'
         ,'end');

      /*********************************************************
      Commented Out per bug#4030717
      ---------------------------------------------------------------------
      -- Overlap Date checks
      -- we loop over the entire attribute array one final time
      -- looking for start/end date ranges that conflict
      ---------------------------------------------------------------------
      IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
         v_attr_count := 1;
         WHILE v_attr_count <= v_attr_last_row
         LOOP
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.attr_varchar_label'
            ,ta_attribute_varchar_label(v_attr_count));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.status'
            ,ta_status(v_attr_count));

            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.adj_period_flag'
            ,ta_adj_period_flag(v_attr_count));

            v_attr_subcount := v_attr_count + 1;  -- we always check 1 lower than
                                                  -- current position
            IF ta_attribute_varchar_label(v_attr_count) = 'CAL_PERIOD_START_DATE' AND
              ta_status(v_attr_count) = 'LOAD' AND
              ta_adj_period_flag(v_attr_count) = 'N' THEN
               WHILE v_attr_subcount <= v_attr_last_row AND
                  ta_status(v_attr_count) = 'LOAD' LOOP
                  IF ta_adj_period_flag(v_attr_subcount) = 'N'
                     AND ta_attribute_varchar_label(v_attr_subcount) = 'CAL_PERIOD_START_DATE'
                     AND ((ta_date_assign_value(v_attr_subcount) <=
                     ta_date_assign_value(v_attr_count)
                     AND ta_cal_period_end_date(v_attr_subcount) >=
                        ta_date_assign_value(v_attr_count))
                     OR (ta_date_assign_value(v_attr_subcount) >=
                        ta_date_assign_value(v_attr_count)
                     AND ta_date_assign_value(v_attr_subcount) <=
                        ta_cal_period_end_date(v_attr_count)))
                  THEN
                     ta_status(v_attr_count) := 'OVERLAP_START_DATE_IN_LOAD';
                     ta_status(v_attr_subcount) := 'OVERLAP_START_DATE_IN_LOAD';
                     v_temp_rows_rejected := v_temp_rows_rejected + 2;
                  END IF;
                  v_attr_subcount := v_attr_subcount + 1;
               END LOOP;
            END IF; -- label = 'CAL_PERIOD_START_DATE' and status = 'LOAD'
         v_attr_count := v_attr_count + 1;
         END LOOP;
      END IF;  -- overlap check for CAL_PERIOD
      ******************************************************************/

         -----------------------------------------------------------------
         -- Update existing ATTR rows
         -- Note:  Only attributes where "allow_multiple_assign_flag" = 'N'
         -- are updated.  For many to many attributes, only inserts are performed.
         -- Also - only attributes marked with "use_interim_table_flag = 'N' are
         -- updated in this step.
         -- Attributes with use_interim_table_flag = 'Y' are put into an interim
         -- table for further processing
         -----------------------------------------------------------------
         IF (p_value_set_required_flag = 'Y') THEN

            FORALL j IN 1..v_attr_last_row
               EXECUTE IMMEDIATE x_attr_update_stmt
               USING ta_dim_attr_numeric_member(j)
                    ,ta_attr_assign_vs_id(j)
                    ,ta_dim_attr_varchar_member(j)
                    ,ta_number_assign_value(j)
                    ,ta_varchar_assign_value(j)
                    ,ta_temp_date_assign_value(j)
                    ,gv_apps_user_id
                    ,gv_login_id
                    ,ta_member_id(j)
                    ,ta_value_set_id(j)
                    ,ta_attribute_id(j)
                    ,ta_version_id(j)
                    ,ta_allow_mult_assign_flag(j)
                    ,ta_attr_exists_count(j)
                    ,ta_status(j);
         ELSE
            IF p_member_col = p_member_dc_col THEN
               FORALL j IN 1..v_attr_last_row
                  EXECUTE IMMEDIATE x_attr_update_stmt
                  USING ta_dim_attr_numeric_member(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_number_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,gv_apps_user_id
                       ,gv_login_id
                       ,ta_member_dc(j)
                       ,ta_attribute_id(j)
                       ,ta_version_id(j)
                       ,ta_allow_mult_assign_flag(j)
                       ,ta_attr_exists_count(j)
                       ,ta_status(j)
                       ,ta_use_interim_table_flag(j);
            ELSE
               FORALL j IN 1..v_attr_last_row
                  EXECUTE IMMEDIATE x_attr_update_stmt
                  USING ta_dim_attr_numeric_member(j)
                       ,ta_attr_assign_vs_id(j)
                       ,ta_dim_attr_varchar_member(j)
                       ,ta_number_assign_value(j)
                       ,ta_varchar_assign_value(j)
                       ,ta_temp_date_assign_value(j)
                       ,gv_apps_user_id
                       ,gv_login_id
                       ,ta_member_id(j)
                       ,ta_attribute_id(j)
                       ,ta_version_id(j)
                       ,ta_allow_mult_assign_flag(j)
                       ,ta_attr_exists_count(j)
                       ,ta_status(j)
                       ,ta_use_interim_table_flag(j);

               END IF;
         END IF;

         -- insert rows into the INTERIM tables
         -- for CAL_PERIOD loads for date overlap
         -- checks
         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            -- Insert a row into the interim table for each
            -- Calendar Period member that has an assignment
            -- for the CALENDAR_PERIOD_START_DATE attribute
            -- in the array (such rows have been marked with
            -- use_interim_table_flag = 'Y'
            FORALL j IN 1 .. v_attr_last_row
               EXECUTE IMMEDIATE x_calp_interim_stmt
               USING ta_cal_period_end_date(j)
               ,ta_cal_period_number(j)
               ,ta_calendar_dc(j)
               ,ta_dimension_group_dc(j)
               ,ta_date_assign_value(j)
               ,ta_member_dc(j)
               ,ta_dimension_group_id(j)
               ,ta_calendar_id(j)
               ,'' -- this is cal period name
               ,'' -- this is cal period desc
               ,ta_adj_period_flag(j)
               ,ta_use_interim_table_flag(j)
               ,ta_status(j);

             -- insert a row into the CALP_ATTR Interim table for each
             -- assignment row where the attribute = CALENDAR_PERIOD_START_DATE
             -- (such rows have been marked with use_interim_table_flag = 'Y')
             FORALL j IN 1..v_attr_last_row
               EXECUTE IMMEDIATE x_calp_attr_interim_stmt
               USING ta_member_dc(j)
                    ,ta_attribute_id(j)
                    ,ta_version_id(j)
                    ,'' --dim_attr_numeric_member
                    ,'' --attr_assign_vs_id
                    ,'' --dim_attr_varchar_member(j)
                    ,'' --number_assign_value
                    ,'' -- varchar_assign_value
                    ,ta_date_assign_value(j)
                    ,ta_use_interim_table_flag(j)
                    ,ta_status(j);

         END IF;

         ----------------------------------------------------------------
         -- Delete records that successfully updated
         ----------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.prior_to_special_delete'
         ,null);

         FORALL j IN 1..v_attr_last_row
             EXECUTE IMMEDIATE x_special_delete_attr_stmt
             USING ta_rowid(j)
                  ,ta_allow_mult_assign_flag(j)
                  ,ta_attr_exists_count(j)
                  ,ta_status(j)
                  ,ta_use_interim_table_flag(j);

         -----------------------------------------------------------------
         -- Copy ATTR Collection for good members in prep for insert later
         -- This final collection only includes multi-assign attributes
         -- (where it doesn't matter whether or not an assignment exists
         --  for any version or for the specific version being loaded)
         -- and non-multi-assign attributes where assignment rows do not
         -- exist for either the specific version being loaded, or any other
         -- version
         -- NOTE:  By definition, this insert collection does NOT include
         --        the CALENDAR_PERIOD_START_DATE attribute rows, since
         --        that attribute is non-multi assign.  This means that
         --        we don't have to worry about checking the use_interim_table_flag='Y'
         --        condition at this time.  In the future, if additional attributes
         --        appear that require an Interim table for processing, we can
         --        modify this insert to include recognition of that flag
         -----------------------------------------------------------------
         v_attr_last_row := ta_attribute_id.LAST;
         v_attr_count := 1;

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr_final_count'
         ,v_attr_final_count);
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr_count'
         ,v_attr_count);
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attr_last_row'
         ,v_attr_last_row);


         WHILE v_attr_count <= v_attr_last_row
         LOOP
            IF (  (ta_status(v_attr_count) = 'LOAD'
                   AND ta_attr_exists_count(v_attr_count) >= 0
                   AND ta_attr_exists_novers_count(v_attr_count) > 0
                   AND ta_allow_mult_assign_flag(v_attr_count) = 'Y') OR
                   (ta_status(v_attr_count) = 'LOAD'
                   AND ta_attr_exists_count(v_attr_count) = 0
                   AND ta_attr_exists_novers_count(v_attr_count) = 0)    ) THEN

               v_attr_final_count := v_attr_final_count + 1;

               tfa_rowid(v_attr_final_count) := ta_rowid(v_attr_count);
               tfa_attribute_id(v_attr_final_count) := ta_attribute_id(v_attr_count);
               tfa_member_dc(v_attr_final_count) := ta_member_dc(v_attr_count);
               tfa_value_set_dc(v_attr_final_count) := ta_value_set_dc(v_attr_count);
               tfa_dim_attr_numeric_member(v_attr_final_count) := ta_dim_attr_numeric_member(v_attr_count);
               tfa_dim_attr_varchar_member(v_attr_final_count) := ta_dim_attr_varchar_member(v_attr_count);
               tfa_number_assign_value(v_attr_final_count) := ta_number_assign_value(v_attr_count);
               tfa_varchar_assign_value(v_attr_final_count) := ta_varchar_assign_value(v_attr_count);
               tfa_date_assign_value(v_attr_final_count) := ta_temp_date_assign_value(v_attr_count);
               tfa_version_id(v_attr_final_count) := ta_version_id(v_attr_count);
               tfa_attr_assign_vs_id(v_attr_final_count) := ta_attr_assign_vs_id(v_attr_count);
               tfa_status(v_attr_final_count) := ta_status(v_attr_count);

            END IF; -- Copy ATTR for good members
            v_attr_count    := v_attr_count + 1;
         END LOOP; -- WHILE loop

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.after_the_copy'
         ,null);

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.attribute_final_count'
         ,v_attr_final_count);

         ----------------------------------------------------------
         -- Update Status of ATTR Collection for failed records
         ----------------------------------------------------------
         FORALL j IN 1..v_attr_last_row
            EXECUTE IMMEDIATE x_update_attr_status_stmt
            USING ta_status(j)
                 ,ta_rowid(j)
                 ,ta_status(j);

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.after_status_update'
         ,null);

         ---------------------------------------------------------
         -- Insert attributes for the good dimension members
         ---------------------------------------------------------
         IF (p_value_set_required_flag = 'Y') THEN
             FORALL j IN 1..v_attr_final_count
               EXECUTE IMMEDIATE x_insert_attr_stmt
               USING tfa_attribute_id(j)
                    ,tfa_version_id(j)
                    ,tfa_dim_attr_numeric_member(j)
                    ,tfa_attr_assign_vs_id(j)
                    ,tfa_dim_attr_varchar_member(j)
                    ,tfa_number_assign_value(j)
                    ,tfa_varchar_assign_value(j)
                    ,tfa_date_assign_value(j)
                    ,gv_apps_user_id
                    ,gv_apps_user_id
                    ,tfa_member_dc(j)
                    ,tfa_value_set_dc(j)
                    ,tfa_status(j);
         ELSE
            FORALL j IN 1..v_attr_final_count
               EXECUTE IMMEDIATE x_insert_attr_stmt
               USING tfa_attribute_id(j)
                    ,tfa_version_id(j)
                    ,tfa_dim_attr_numeric_member(j)
                    ,tfa_attr_assign_vs_id(j)
                    ,tfa_dim_attr_varchar_member(j)
                    ,tfa_number_assign_value(j)
                    ,tfa_varchar_assign_value(j)
                    ,tfa_date_assign_value(j)
                    ,gv_apps_user_id
                    ,gv_apps_user_id
                    ,tfa_member_dc(j)
                    ,tfa_status(j);
         END IF; -- v_value_set_required = 'Y'

         ----------------------------------------------------------
         -- Count the loaded rows and error rows
         ----------------------------------------------------------
         v_rows_rejected := v_rows_rejected + v_temp_rows_rejected;
         --x_rows_loaded   := x_rows_loaded + (v_attr_last_row - v_temp_rows_rejected);
         v_temp_rows_rejected := 0;  -- initialize for next pass of the loop

         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected'
         ,v_rows_rejected);

         ----------------------------------------------------------------
         -- Delete Loaded records and clear Collections for Next Bulk Fetch
         ----------------------------------------------------------------
         FORALL j IN 1..v_attr_final_count
             EXECUTE IMMEDIATE x_delete_attr_stmt
             USING tfa_rowid(j)
                  ,tfa_status(j)
                  ,ta_use_interim_table_flag(j);

         tfa_rowid.DELETE;
         tfa_attribute_id.DELETE;
         tfa_member_dc.DELETE;
         tfa_value_set_dc.DELETE;
         tfa_dim_attr_numeric_member.DELETE;
         tfa_dim_attr_varchar_member.DELETE;
         tfa_number_assign_value.DELETE;
         tfa_varchar_assign_value.DELETE;
         tfa_date_assign_value.DELETE;
         tfa_version_id.DELETE;
         tfa_attr_assign_vs_id.DELETE;
         tfa_status.DELETE;

         ta_rowid.DELETE;
         ta_member_read_only_flag.DELETE;
         ta_attribute_id.DELETE;
         ta_attribute_varchar_label.DELETE;
         ta_attribute_dimension_id.DELETE;
         ta_attr_value_column_name.DELETE;
         ta_attribute_data_type_code.DELETE;
         ta_attribute_required_flag.DELETE;
         ta_read_only_flag.DELETE;
         ta_allow_mult_assign_flag.DELETE;
         ta_member_dc.DELETE;
         ta_value_set_dc.DELETE;
         ta_attribute_assign_value.DELETE;
         ta_dim_attr_numeric_member.DELETE;
         ta_dim_attr_varchar_member.DELETE;
         ta_number_assign_value.DELETE;
         ta_varchar_assign_value.DELETE;
         ta_date_assign_value.DELETE;
         ta_temp_date_assign_value.DELETE;
         ta_version_display_code.DELETE;
         ta_version_id.DELETE;
         ta_language.DELETE;
         ta_attr_assign_vs_dc.DELETE;
         ta_attr_assign_vs_id.DELETE;
         ta_status.DELETE;
         ta_attr_exists_count.DELETE;
         ta_multattr_exists_count.DELETE;
         ta_attr_identical_count.DELETE;
         ta_cal_period_end_date.DELETE;
         ta_adj_period_flag.DELETE;
         ta_use_interim_table_flag.DELETE;
         ta_cal_period_number.DELETE;
         ta_calendar_dc.DELETE;
         ta_calendar_id.DELETE;
         ta_protected_assign_flag.DELETE;
         ta_dimension_group_dc.DELETE;
         ta_dimension_group_id.DELETE;
         ta_calpattr_cal_dc.DELETE;
         ta_calpattr_dimgrp_dc.DELETE;
         ta_calpattr_end_date.DELETE;
         ta_calpattr_period_num.DELETE;
         ta_member_id.DELETE;
         ta_value_set_id.DELETE;



      COMMIT;
      END LOOP; -- attribute loop

   FEM_Multi_Proc_Pkg.Post_Data_Slice(
     p_req_id => p_master_request_id,
     p_slc_id => v_slc_id,
     p_status => v_mp_status,
     p_message => v_mp_message,
     p_rows_processed => 0,
     p_rows_loaded => 0,
     p_rows_rejected => v_rows_rejected);

   END LOOP; -- get_data_slice
   IF cv_get_attr_rows%ISOPEN THEN
      CLOSE cv_get_attr_rows;
   END IF;
   --x_rows_rejected := v_rows_rejected;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||c_proc_name||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         IF cv_get_attr_rows%ISOPEN THEN
            CLOSE cv_get_attr_rows;
         END IF;

         --x_status:= 2;
         --x_message := 'COMPLETE:ERROR';

         gv_prg_msg := sqlerrm;
         gv_callstack := dbms_utility.format_call_stack;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_prg_msg);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_6
          ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
          ,p_msg_text => gv_callstack);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
          ,P_TOKEN1 => 'ERR_MSG'
          ,P_VALUE1 => gv_prg_msg);


       --  FEM_ENGINES_PKG.USER_MESSAGE
       --   (p_app_name => c_fem
       --   ,p_msg_text => gv_prg_msg);

         RAISE e_main_terminate;


END Attr_Assign_Update;

/*===========================================================================+
 | PROCEDURE
 |              Src_Sys_select_stmt
 |
 | DESCRIPTION
 |    Identifies the Source System Codes for the load
 |    specifically, for the purposes of updating FEM_DIM_LOAD_STATUS
 |    after the load is complete
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   8-MAR-04  Created
 |    Rob Flippo   31-JAN-05 Added where condition on dimension_varchar_label
 |                           for dimensions that use the shared ATTR_T table
 |
 +===========================================================================*/

   procedure build_src_sys_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                       ,p_source_attr_table IN VARCHAR2
                                       ,p_shared_dimension_flag IN VARCHAR2
                                       ,x_src_sys_select_stmt OUT NOCOPY VARCHAR2)
   IS

      v_dim_label_where_cond  VARCHAR2(1000);

   BEGIN
      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


      x_src_sys_select_stmt := 'SELECT DISTINCT(attribute_assign_value)'||
                               ' FROM '||p_source_attr_table||
                               ' WHERE attribute_varchar_label = ''SOURCE_SYSTEM_CODE'''||
                               v_dim_label_where_cond;

   END build_src_sys_select_stmt;


/*===========================================================================+
 | PROCEDURE
 |              LOAD_DIM_GROUPS
 |
 | DESCRIPTION
 |                 Creates new and updates existing Dimension Groups from the
 |                 interface tables
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |         The Dimension Group Loader has 5 main categories of records for loading.  These are:
 |         1)  Bad New Groups
 |         2)  New Groups
 |         3)  Existing Groups for name/desc update
 |         4)  Remaining Groups for base table update
 |         5)  Groups that exist but for a different Dimension_ID
 |
 |         The records that belong in each of the above categories are described
 |         in detail below in the Introduction to each section.
 |
 |         For each step, the following sub-steps are involved:
 |            a)  BULK Collect members for the category
 |            b)  Validate (if necessary)
 |            c)  Update _B_T or _TL_T table for invalid records
 |            d)  Update/insert FEM with the new record (or new name/description)
 |            e)  Delete records from _B_T or _TL_T tables where appropriate
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   10-NOV-03  Created
 |
 +===========================================================================*/




/*===========================================================================+
 | PROCEDURE
 |              get_dimension_info
 |
 | DESCRIPTION
 |                 Validates the inputs and obtains object and column names
 |                 for the dimension
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   21-OCT-03  Created
 |    Rob Flippo   12-JAN-05  Bug#4030756 Retieve interface table names
 |                            from fem_xdim_dimensions metadata rather than
 |                            rely on naming convention
 |    Rob Flippo   16-MAR-05  Bug#4244082 properly identify dimensions that have
 |                            dimension_group_id on their tables
 |                            Previously, the hier_dimension_flag designated
 |                            if the dim had a HIER table or not.  Now it
 |                            designates that the dim uses dimension_groups.
 |                            -- p_simple_dimension_flag now means no attributes
 |                               (as opposed to no hierarchies and no attributes)
 |                               so it will not necessarily match what is in the table
 +===========================================================================*/

procedure get_dimension_info (p_dimension_varchar_label IN VARCHAR2
                             ,x_dimension_id OUT NOCOPY NUMBER
                             ,x_target_b_table OUT NOCOPY VARCHAR2
                             ,x_target_tl_table OUT NOCOPY VARCHAR2
                             ,x_target_attr_table OUT NOCOPY VARCHAR2
                             ,x_source_b_table OUT NOCOPY VARCHAR2
                             ,x_source_tl_table OUT NOCOPY VARCHAR2
                             ,x_source_attr_table OUT NOCOPY VARCHAR2
                             ,x_member_col OUT NOCOPY VARCHAR2
                             ,x_member_dc_col OUT NOCOPY VARCHAR2
                             ,x_member_t_dc_col OUT NOCOPY VARCHAR2
                             ,x_member_name_col OUT NOCOPY VARCHAR2
                             ,x_member_t_name_col OUT NOCOPY VARCHAR2
                             ,x_member_description_col OUT NOCOPY VARCHAR2
                             ,x_value_set_required_flag OUT NOCOPY VARCHAR2
                             ,x_user_defined_flag OUT NOCOPY VARCHAR2
                             ,x_simple_dimension_flag OUT NOCOPY VARCHAR2
                             ,x_shared_dimension_flag OUT NOCOPY VARCHAR2
                             ,x_hier_table_name OUT NOCOPY VARCHAR2
                             ,x_hier_dimension_flag OUT NOCOPY VARCHAR2
                             ,x_member_id_method_code OUT NOCOPY VARCHAR2
                             ,x_table_handler_name OUT NOCOPY VARCHAR2
                             ,x_composite_dimension_flag   OUT NOCOPY VARCHAR2 --
                             ,x_structure_id OUT NOCOPY NUMBER) --
IS
   v_hierarchy_table_name VARCHAR2(30);
   v_use_groups_flag VARCHAR2(1);
   v_hier_editor_managed_flag VARCHAR2(1);
   v_xdim_read_only_flag VARCHAR2(1);


BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'get_dimension_info','Begin');

   SELECT dimension_id
         ,member_b_table_name
         ,member_tl_table_name
         ,attribute_table_name
         ,intf_member_b_table_name
         ,intf_member_tl_table_name
         ,intf_attribute_table_name
         ,member_col
         ,member_display_code_col
         ,member_name_col
         ,member_description_col
         ,value_set_required_flag
         ,user_defined_flag
         ,hierarchy_table_name
         ,decode(group_use_code,'OPTIONAL','Y','REQUIRED','Y','N')
         ,hier_editor_managed_flag
         ,read_only_flag
         ,member_id_method_code
         ,SUBSTR(member_b_table_name,1,length(member_b_table_name)-2)||'_PKG'
         ,composite_dimension_flag --
         ,id_flex_num --
   INTO   x_dimension_id
         ,x_target_b_table
         ,x_target_tl_table
         ,x_target_attr_table
         ,x_source_b_table
         ,x_source_tl_table
         ,x_source_attr_table
         ,x_member_col
         ,x_member_dc_col
         ,x_member_name_col
         ,x_member_description_col
         ,x_value_set_required_flag
         ,x_user_defined_flag
         ,x_hier_table_name
         ,v_use_groups_flag
         ,v_hier_editor_managed_flag
         ,v_xdim_read_only_flag
         ,x_member_id_method_code
         ,x_table_handler_name
         ,x_composite_dimension_flag --
         ,x_structure_id
   FROM fem_xdim_dimensions_vl
   WHERE dimension_varchar_label = p_dimension_varchar_label;

   IF x_source_b_table = 'FEM_SIMPLE_DIMS_B_T' THEN
      x_shared_dimension_flag := 'Y';
      x_member_t_dc_col       := 'MEMBER_CODE';
      x_member_t_name_col     := 'MEMBER_NAME';

   ELSE x_shared_dimension_flag := 'N';
        x_member_t_dc_col       := x_member_dc_col;
        x_member_t_name_col     := x_member_name_col;

   END IF;

   IF x_target_attr_table IS NULL THEN
      x_simple_dimension_flag := 'Y';
   ELSE x_simple_dimension_flag := 'N';
   END IF;

   x_hier_dimension_flag := v_use_groups_flag;  --bug#4244082 use_groups_flag
                                                -- instead of hier_dim_flag

   /**********************************************************
   Obsolete because we have use_groups_flag logic instead
   due to bug#4244082
   IF v_hierarchy_table_name IS NOT NULL THEN
      x_hier_dimension_flag := 'Y';
   ELSE
      x_hier_dimension_flag := 'N';
   END IF;
   *******************/

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'get_dimension_info','End');

   EXCEPTION
      WHEN no_data_found THEN
        RAISE e_dimension_not_found;
         --p_Err_Code := 2;
         --p_Err_Msg  := G_DIM_NOT_FOUND;


END get_dimension_info;



/*===========================================================================+
 | PROCEDURE
 |              build_mbr_select_stmt
 |
 | DESCRIPTION
 |                 Builds the dynamic SELECT statement for retrieving
 |                 the member data from the _T interface tables
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   22-OCT-03  Created
 |    Rob Flippo   08-SEP-04  Added where condition exists = 'Y' query so that
 |                            when querying from the TL_T table, only rows of
 |                            installed languages are retrieved.  This is for
 |                            bug#3857097 where it was retrieving rows for all
 |                            languages, trying to update, and when no update row
 |                            found it would just delete the source row
 |
 |    Rob Flippo  08-Sep-04   Bug#3835758  Modified the vs_where_cond so that it
 |                            joins to fem_value_set_b where the dimension_id =
 |                            the dimension being loaded
 |    Rob Flippo   16-FEB-05  Bug#4189544 DIMENSION GROUP LOADER ISSUE
 |                            add dimension_id where condition when target
 |                            table is fem_dimension_grps_b
 |                            -- also fix so only load grps of the specific dim
 |    Rob Flippo   10-JUN-05  Bug#3928148 For TL update, only allow updates for
 |                            members that are not read_only_flag = Y
 +===========================================================================*/
   procedure build_mbr_select_stmt  (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_t_name_col IN VARCHAR2
                                ,p_member_description_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_exists_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2)


   IS
      -- Value Set Where conditions
      v_vs_where_cond       VARCHAR2(1000);
      v_vs_t_where_cond     VARCHAR2(1000);
      v_vs_table           VARCHAR2(1000);
      v_vs_col           VARCHAR2(1000);
      v_vs_subq_where_cond          VARCHAR2(1000);
      v_vs_subq_table       VARCHAR2(1000);
      v_data_slice_pred     VARCHAR2(100);

      -- Dimension Label where condition (for Simple dimensions)
      v_dim_label_where_cond       VARCHAR2(1000);
      v_dim_label_join_cond        VARCHAR2(1000);
      v_dim_id_where_cond          VARCHAR2(1000);

      -- Dimension Group Where Conditions (for member loads)
      v_dimension_grp_col          VARCHAR2(1000);
      v_dimension_grp_table        VARCHAR2(1000);
      v_dimension_grp_where_cond   VARCHAR2(1000);

      -- Special conditions to handle CAL_PERIOD
      v_member_code                VARCHAR2(1000);
      v_cal_period_cols            VARCHAR2(1000);
      v_calendar_table             VARCHAR2(100);
      v_calendar_where_cond        VARCHAR2(1000);
      v_member_dc_where_cond       VARCHAR2(1000);

      -- Columns for loading Dimension Groups
      v_dimgrp_load_col            VARCHAR2(1000);

   BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_mbr_select_stmt','Begin Build member select statement');

      IF p_value_set_required_flag = 'Y' THEN

         v_vs_col          := ',B.value_set_display_code, V1.value_set_id ';
         v_vs_t_where_cond := ' AND B.value_set_display_code = T.value_set_display_code';

         v_vs_table        := ', FEM_VALUE_SETS_B V1';
         v_vs_where_cond   := ' AND B.value_set_display_code = V1.value_set_display_code (+)'||
                              ' AND V1.dimension_id (+) = '||p_dimension_id;

         v_vs_subq_table   := ', FEM_VALUE_SETS_B V2';
         v_vs_subq_where_cond   := ' AND G.value_set_id = V2.value_set_id AND '||
                                        'V2.value_set_display_code = B.value_set_display_code';
      ELSE

         v_vs_col           := ', null, null';
         v_vs_t_where_cond  := '';

         v_vs_table         := '';
         v_vs_where_cond    := '';

         v_vs_subq_table    := '';
         v_vs_subq_where_cond         := '';
      END IF;

      -- setting the Dim Label conditions
      IF ((p_value_set_required_flag = 'N'
          AND p_shared_dimension_flag = 'Y') OR
          (p_load_type = 'DIMENSION_GROUP'))
          AND (p_exists_flag = 'N') THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
         v_dim_label_join_cond :=
            ' AND B.dimension_varchar_label = T.dimension_varchar_label';
      ELSIF ((p_value_set_required_flag = 'N'
             AND p_shared_dimension_flag = 'Y') OR
             (p_load_type = 'DIMENSION_GROUP'))
             AND (p_exists_flag = 'Y') THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
         v_dim_label_join_cond   := '';
      ELSE
         v_dim_label_where_cond  := '';
         v_dim_label_join_cond   := '';

      END IF; -- setting the Dim Label conditions

         -- Use Dimension Groups only when query for New members from the _B_T table
         -- for Hierarchy dimensions
      IF (p_hier_dimension_flag = 'Y'
          AND p_exists_flag = 'N') OR (p_dimension_varchar_label = 'CAL_PERIOD')  THEN
         v_dimension_grp_col    := ',B.dimension_group_display_code, D.dimension_group_id';
         v_dimension_grp_table  := ', FEM_DIMENSION_GRPS_B D';
         v_dimension_grp_where_cond := ' AND B.dimension_group_display_code = '||
                                       'D.dimension_group_display_code (+) '||
                                      ' AND D.dimension_id (+) = '||p_dimension_id;
      ELSE
         v_dimension_grp_col          := ',null, null';
         v_dimension_grp_table        := '';
         v_dimension_grp_where_cond   := '';
      END IF;

      -- Setting the special conditions for CAL_PERIOD
      IF (p_dimension_varchar_label = 'CAL_PERIOD')
      AND (p_load_type NOT IN ('DIMENSION_GROUP')) THEN
         v_member_code :=
               'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'')';
         v_cal_period_cols    := ', C.calendar_display_code, C.calendar_id, B.cal_period_end_date,B.cal_period_number';
         v_calendar_table := ', FEM_CALENDARS_VL C';
         v_calendar_where_cond := ' AND B.calendar_display_code = C.calendar_display_code (+) ';
         v_member_dc_where_cond := ' AND B.calendar_display_code = T.calendar_display_code'||
                                   ' AND B.cal_period_number = T.cal_period_number'||
                                   ' AND B.cal_period_end_date = T.cal_period_end_date'||
                                   ' AND B.dimension_group_display_code = T.dimension_group_display_code';

      ELSE
         v_member_code := 'B.'||p_member_t_dc_col;
         v_cal_period_cols := ',null ,null, null, null';
         v_calendar_table := '';
         v_calendar_where_cond := '';
         v_member_dc_where_cond := ' AND B.'||p_member_t_dc_col||
                                   '=T.'||p_member_t_dc_col;
      END IF; -- p_dimension_varchar_label = 'CAL_PERIOD'

      -- Because we load both Dimension Groups and Members using the same
      -- dynamic query, we have to allow for the extra columns on FEM_DIMENSION_GRPS_B
      IF (p_load_type = 'DIMENSION_GROUP') THEN
         v_dimgrp_load_col := ',B.dimension_group_seq, B.time_group_type_code';
         v_data_slice_pred := '';
         v_dim_id_where_cond := ' AND G.dimension_id ='||p_dimension_id;
      ELSE
         v_dimgrp_load_col := ',null,null';
         v_data_slice_pred := 'AND   {{data_slice}} ';
         v_dim_id_where_cond := '';
      END IF;


      IF (p_exists_flag = 'N') THEN
      x_select_stmt :=
         'SELECT B.rowid'||
            ',T.rowid'||
            ','||v_member_code||
            v_cal_period_cols||
            v_vs_col||
            v_dimension_grp_col||
            ', ''LOAD'' '||
            ',T.'||p_member_t_name_col||
            ',T.'||p_member_description_col||
            ',T.language'||
            ', ''LOAD'' '||
            ', to_date(''12/31/2499'',''MM/DD/YYYY'')'||
            v_dimgrp_load_col||
         ' FROM '||p_source_b_table||' B,'||
                   p_source_tl_table||' T'||
                   v_dimension_grp_table||
                   v_vs_table||
                   v_calendar_table||
         ' WHERE B.status'||p_exec_mode_clause||
         v_data_slice_pred||
         ' AND T.status'||p_exec_mode_clause||
         v_member_dc_where_cond||
         v_vs_t_where_cond||
         v_dim_label_where_cond||
         v_dim_label_join_cond||
         ' AND NOT EXISTS (SELECT 0 FROM '||
         p_target_b_table||' G'||v_vs_subq_table||
         ' WHERE to_char(G.'||p_member_dc_col||') = '||v_member_code||
         v_dim_id_where_cond||
         v_vs_subq_where_cond||')'||
         v_dimension_grp_where_cond||
         v_calendar_where_cond||
         v_vs_where_cond||
         ' AND T.language = userenv(''LANG'')';

       ELSE
         -- "B" now refers to the TL table
      x_select_stmt :=
         'SELECT null'||
            ',B.rowid'||
            ','||v_member_code||
            v_cal_period_cols||
            v_vs_col||
            ',null,null'||
            ',null'||
            ',B.'||p_member_t_name_col||
            ',B.'||p_member_description_col||
            ',B.language'||
            ', ''LOAD'' '||
            ',null,null'||
         ' FROM '||p_source_tl_table||' B'||
                   v_dimension_grp_table||
                   v_vs_table||
                   v_calendar_table||
         ' WHERE B.status'||p_exec_mode_clause||
         v_data_slice_pred||
         v_dim_label_where_cond||
         ' AND EXISTS (SELECT 0 FROM '||
         p_target_b_table||' G'||v_vs_subq_table||
         ' WHERE to_char(G.'||p_member_dc_col||') = '||v_member_code||
         ' AND G.read_only_flag = ''N'''||
         v_dim_id_where_cond||
         v_vs_subq_where_cond||')'||
         ' AND B.language in (SELECT language_code from FND_LANGUAGES '||
         ' WHERE installed_flag in (''I'',''B'')) '||
         v_dimension_grp_where_cond||
         v_calendar_where_cond||
         v_vs_where_cond;

       END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_mbr_select_stmt','End');

   END build_mbr_select_stmt;

/*===========================================================================+
 | PROCEDURE
 |              build_bad_lang_upd_stmt
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating the TL_T
 |                 records where the LANGUAGE is not installed
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   17-Sep-04  Created
 +===========================================================================*/
procedure build_bad_lang_upd_stmt  (p_load_type IN VARCHAR2
                                   ,p_dimension_varchar_label IN VARCHAR2
                                   ,p_dimension_id IN NUMBER
                                   ,p_source_tl_table IN VARCHAR2
                                   ,p_exec_mode_clause IN VARCHAR2
                                   ,p_shared_dimension_flag IN VARCHAR2
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,x_update_stmt OUT NOCOPY VARCHAR2)
IS
   v_dim_label_where_cond   VARCHAR2(1000); -- where condition for when updating
                                            -- dimension grp TL table

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_bad_tl_lang_upd_stmt','Begin');

   IF (p_load_type = 'DIMENSION_GROUP')
      OR (p_shared_dimension_flag ='Y' AND p_value_set_required_flag = 'N') THEN
      v_dim_label_where_cond  :=
         ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
   ELSE
      v_dim_label_where_cond  := '';
   END IF;

      x_update_stmt := 'UPDATE '||p_source_tl_table||' B'||
                       ' SET B.status = ''LANGUAGE_NOT_INSTALLED'' '||
                       ' WHERE B.language NOT IN '||
                       ' (SELECT language_code from FND_LANGUAGES '||
                       ' WHERE installed_flag in (''I'',''B'')) '||
                       v_dim_label_where_cond||
                       ' AND B.status'||p_exec_mode_clause||
                       ' AND   {{data_slice}} ';


   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_bad_tl_lang_upd_stmt','End');


END build_bad_lang_upd_stmt;

/*===========================================================================+
 | PROCEDURE
 |              build_tl_ro_mbr_upd_stmt
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating the TL_T
 |                 records where the member is read_only_flag='Y'
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   10-Jun-05  Created
 |    Rob Flippo   07-OCT-05  Modified Cal period update statement for performance
 |                            issue encountered during regression testing (no bug)
 +===========================================================================*/
procedure build_tl_ro_mbr_upd_stmt  (p_load_type IN VARCHAR2
                                   ,p_dimension_varchar_label IN VARCHAR2
                                   ,p_dimension_id IN NUMBER
                                   ,p_source_tl_table IN VARCHAR2
                                   ,p_target_b_table IN VARCHAR2
                                   ,p_member_dc_col IN VARCHAR2
                                   ,p_member_t_dc_col IN VARCHAR2
                                   ,p_exec_mode_clause IN VARCHAR2
                                   ,p_shared_dimension_flag IN VARCHAR2
                                   ,p_value_set_required_flag IN VARCHAR2
                                   ,x_update_stmt OUT NOCOPY VARCHAR2)
IS
   v_dim_label_where_cond   VARCHAR2(1000); -- where condition for when updating
                                            -- dimension grp TL table
   v_vs_where_cond          VARCHAR2(1000); -- for value set dimensions
   v_vs_from_cond           VARCHAR2(1000);
   v_calp_from_cond        VARCHAR2(1000);

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_tl_ro_mbr_upd_stmt','Begin');

   IF (p_load_type = 'DIMENSION_GROUP')
      OR (p_shared_dimension_flag ='Y' AND p_value_set_required_flag = 'N') THEN
      v_dim_label_where_cond  :=
         ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
   ELSE
      v_dim_label_where_cond  := '';
   END IF;

   IF p_value_set_required_flag = 'Y' and p_load_type NOT IN ('DIMENSION_GROUP') THEN
      v_vs_from_cond := ',fem_value_sets_b V ';
      v_vs_where_cond := ' AND V.value_set_display_code = B.value_set_display_code'||
                         ' AND V.value_set_id = G.value_set_id'||
                         ' AND V.dimension_id = '||p_dimension_id;
   ELSE
      v_vs_from_cond := '';
      v_vs_where_cond := '';
   END IF;

   IF p_dimension_varchar_label = 'CAL_PERIOD' AND
         p_load_type NOT IN ('DIMENSION_GROUP') THEN

      v_calp_from_cond := ',fem_calendars_b C, fem_dimension_grps_b D';

      x_update_stmt := 'UPDATE '||p_source_tl_table||' B'||
                       ' SET B.status = ''READ_ONLY_MEMBER'' '||
                       ' WHERE B.language IN '||
                       ' (SELECT language_code from FND_LANGUAGES '||
                       ' WHERE installed_flag in (''I'',''B'')) '||
                       v_dim_label_where_cond||
                       ' AND B.status'||p_exec_mode_clause||
                       ' AND EXISTS (SELECT 0 FROM '||p_target_b_table||' G'||
                       v_calp_from_cond||
                       ' WHERE to_char(G.'||p_member_dc_col||') = '||
                       'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
                       'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
                       'LPAD(to_char(C.calendar_id),5,''0'')||'||
                       'LPAD(to_char(D.time_dimension_group_key),5,''0'') '||
                       ' AND G.read_only_flag = ''Y'''||
                       ' AND G.dimension_group_id = D.dimension_group_id '||
                       ' AND C.calendar_id = G.calendar_id '||
                       ')'||
                       ' AND   {{data_slice}} ';

    ELSE

      x_update_stmt := 'UPDATE '||p_source_tl_table||' B'||
                       ' SET B.status = ''READ_ONLY_MEMBER'' '||
                       ' WHERE B.language IN '||
                       ' (SELECT language_code from FND_LANGUAGES '||
                       ' WHERE installed_flag in (''I'',''B'')) '||
                       v_dim_label_where_cond||
                       ' AND B.status'||p_exec_mode_clause||
                       ' AND EXISTS (SELECT 0 FROM '||p_target_b_table||' G'||
                       v_vs_from_cond||
                       ' WHERE G.'||p_member_dc_col||'=B.'||p_member_t_dc_col||
                       ' AND G.read_only_flag = ''Y'''||
                       v_vs_where_cond||
                       ')'||
                       ' AND   {{data_slice}} ';

    END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_tl_ro_mbr_upd_stmt','End');


END build_tl_ro_mbr_upd_stmt;



/*===========================================================================+
 | PROCEDURE
 |              build_bad_tl_select_stmt
 |
 | DESCRIPTION
 |                 Builds the dynamic SELECT statement for retrieving
 |                 the TL records that are not for new members (i.e., no data
 |                 in _B_T table) and are not for existing members (i.e., member
 |                 doesn't exist in FEM)
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   04-May-04  Created
 |    Rob Flippo   07-Sep-04  Bug#3848996 - Simple Dim load failing because
 |                            Invalid column name.  The select was using the
 |                            wrong variable name - it should use p_member_t_dc_col
 |                            since that is the name of the member col on the
 |                            interface table
 |
 |    Rob Flippo   16-Sep-04  Added condition on the NOT EXISTS subquery for the B2
 |                            table to check the dimension_Varchar_label when the
 |                            load is for a Simple Dimension
 |    Rob Flippo   16-FEB-05  Bug#4189544 DIMENSION GROUP LOADER ISSUE
 |                            add dimension_id where condition when target
 |                            table is fem_dimension_grps_b
 |                            -- also modified so only load grps of specific
 |                               dimension
 +===========================================================================*/
   procedure build_bad_tl_select_stmt  (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2)

   IS
      -- Value Set Where conditions
      v_vs_where_cond       VARCHAR2(1000);
      v_vs_t_where_cond     VARCHAR2(1000);
      v_vs_table           VARCHAR2(1000);
      v_vs_col           VARCHAR2(1000);
      v_vs_subq_where_cond          VARCHAR2(1000);
      v_vs_subq_table       VARCHAR2(1000);
      v_vs_subq_where_condB2          VARCHAR2(1000);
      v_data_slice_pred     VARCHAR2(100);

      -- Dimension Label where condition (for Simple dimensions)
      v_dim_label_where_cond       VARCHAR2(1000);
      v_dim_label_subqwhere_cond       VARCHAR2(1000);
      v_dim_label_join_cond        VARCHAR2(1000);
      v_dim_id_where_cond          VARCHAR2(1000);

      -- Dimension Group Where Conditions (for member loads)
      v_dimension_grp_col          VARCHAR2(1000);
      v_dimension_grp_table        VARCHAR2(1000);
      v_dimension_grp_where_cond   VARCHAR2(1000);


      -- Special conditions to handle CAL_PERIOD
      v_member_code                VARCHAR2(1000);
      v_member_code_b_t              VARCHAR2(1000);
      v_cal_period_cols            VARCHAR2(1000);
      v_calendar_table             VARCHAR2(100);
      v_calendar_where_cond        VARCHAR2(1000);
      v_member_dc_where_cond       VARCHAR2(1000);

      -- Columns for loading Dimension Groups
      v_dimgrp_load_col            VARCHAR2(1000);

   BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_bad_tl_select_stmt','Begin');

      IF p_value_set_required_flag = 'Y' THEN

         v_vs_col          := ',B.value_set_display_code ';
         v_vs_t_where_cond := ' AND B.value_set_display_code = T.value_set_display_code';

         v_vs_table        := ', FEM_VALUE_SETS_B V1';
         v_vs_where_cond   := ' AND B.value_set_display_code = V1.value_set_display_code (+)';

         v_vs_subq_table   := ', FEM_VALUE_SETS_B V2';
         v_vs_subq_where_cond   := ' AND G.value_set_id = V2.value_set_id AND '||
                                        'V2.value_set_display_code = B.value_set_display_code';
         v_vs_subq_where_condB2   :=  ' AND B2.value_set_display_code = B.value_set_display_code';


      ELSE

         v_vs_col           := ', null';
         v_vs_t_where_cond  := '';

         v_vs_table         := '';
         v_vs_where_cond    := '';

         v_vs_subq_table    := '';
         v_vs_subq_where_cond         := '';
         v_vs_subq_where_condB2         := '';

      END IF;

      -- setting the Dim Label conditions
      IF (p_value_set_required_flag = 'N'
          AND p_shared_dimension_flag = 'Y') OR
          (p_load_type = 'DIMENSION_GROUP') THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
         v_dim_label_subqwhere_cond :=
            ' AND B2.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
         v_dim_label_join_cond :=
            ' AND B.dimension_varchar_label = T.dimension_varchar_label';
      ELSE
         v_dim_label_where_cond  := '';
         v_dim_label_join_cond   := '';
         v_dim_label_subqwhere_cond := '';

      END IF; -- setting the Dim Label conditions

      -- Setting the special conditions for CAL_PERIOD
      IF (p_dimension_varchar_label = 'CAL_PERIOD')
      AND (p_load_type NOT IN ('DIMENSION_GROUP')) THEN
         v_member_code :=
               'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'')';
         v_member_code_b_t :=
               'LPAD(to_char(to_number(to_char(B2.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B2.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'')';

         v_cal_period_cols    := ', C.calendar_display_code, C.calendar_id, B.cal_period_end_date, B.cal_period_number';
         v_calendar_table := ', FEM_CALENDARS_VL C';
         v_calendar_where_cond := ' AND B.calendar_display_code = C.calendar_display_code (+) ';
         v_member_dc_where_cond := ' AND B.calendar_display_code = T.calendar_display_code'||
                                   ' AND B.cal_period_number = T.cal_period_number'||
                                   ' AND B.cal_period_end_date = T.cal_period_end_date'||
                                   ' AND B.dimension_group_display_code = T.dimension_group_display_code';
         v_dimension_grp_table  := ', FEM_DIMENSION_GRPS_B D';
         v_dimension_grp_where_cond := ' AND B.dimension_group_display_code = '||
                                       'D.dimension_group_display_code (+) '||
                                      ' AND D.dimension_id (+) = '||p_dimension_id;

      ELSE
         v_member_code := 'B.'||p_member_t_dc_col;
         v_member_code_b_t := 'B2.'||p_member_t_dc_col;
         v_cal_period_cols := ',null ,null, null, null';
         v_calendar_table := '';
         v_calendar_where_cond := '';
         v_member_dc_where_cond := ' AND B.'||p_member_t_dc_col||
                                   '=T.'||p_member_t_dc_col;
         v_dimension_grp_table        := '';
         v_dimension_grp_where_cond   := '';

      END IF; -- p_dimension_varchar_label = 'CAL_PERIOD'

      -- Because we load both Dimension Groups and Members using the same
      -- dynamic query, we have to allow for the extra columns on FEM_DIMENSION_GRPS_B
      IF (p_load_type = 'DIMENSION_GROUP') THEN
         v_dimgrp_load_col := ',B.dimension_group_seq, B.time_group_type_code';
         v_data_slice_pred := '';
         v_dim_id_where_cond := ' AND G.dimension_id = '||p_dimension_id;
      ELSE
         v_dimgrp_load_col := ',null,null';
         v_data_slice_pred := 'AND   {{data_slice}} ';
         v_dim_id_where_cond := '';
      END IF;

      x_select_stmt :=
         'SELECT B.rowid'||
            ','||v_member_code||
            v_cal_period_cols||
            v_vs_col||
            ', ''INVALID_MEMBER'' '||
         ' FROM '||p_source_tl_table||' B'||
                   v_dimension_grp_table||
                   v_calendar_table||
         ' WHERE B.status'||p_exec_mode_clause||' '||
         v_data_slice_pred||
         v_dim_label_where_cond||
         ' AND NOT EXISTS (SELECT 0 FROM '||
         p_target_b_table||' G'||v_vs_subq_table||
         ' WHERE to_char(G.'||p_member_dc_col||') = '||v_member_code||
         v_dim_id_where_cond||
         v_vs_subq_where_cond||')'||
         ' AND NOT EXISTS (SELECT 0 FROM '||
         p_source_b_table||' B2'||
         ' WHERE to_char('||v_member_code_b_t||') = '||v_member_code||
         v_dim_label_subqwhere_cond||
         v_vs_subq_where_condB2||')'||
         v_dimension_grp_where_cond||
         v_calendar_where_cond;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'build_bad_TL_select_stmt','End');

   END build_bad_tl_select_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_CALP_INTERM_INSERT_STMT
 |
 | DESCRIPTION
 |                 Builds the update statement for the inserts into the
 |                 FEM_CALP_INTERIM_T and FEM_CALP_ATTR_INTERIM_T
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   04-JAN-05  Created
 |
 +===========================================================================*/

procedure build_calp_interim_insert_stmt (x_insert_calp_stmt OUT NOCOPY VARCHAR2
                                         ,x_insert_calp_attr_stmt OUT NOCOPY VARCHAR2)

IS

BEGIN

        x_insert_calp_stmt := 'INSERT INTO FEM_CALP_INTERIM_T'||
                               '(CAL_PERIOD_END_DATE'||
                               ',CAL_PERIOD_NUMBER'||
                               ',CALENDAR_DISPLAY_CODE'||
                               ',DIMENSION_GROUP_DISPLAY_CODE'||
                               ',CAL_PERIOD_START_DATE'||
                               ',CAL_PERIOD_ID'||
                               ',DIMENSION_GROUP_ID'||
                               ',CALENDAR_ID'||
                               ',CAL_PERIOD_NAME'||
                               ',DESCRIPTION'||
                               ',OVERLAP_FLAG'||
                               ',ADJUSTMENT_PERIOD_FLAG)'||
                               ' SELECT'||
                               ':b_end_date'||
                               ',:b_period_number'||
                               ',:b_calendar_display_code'||
                               ',:b_dimgrp_display_code'||
                               ',:b_start_date'||
                               ',:b_cal_period_id'||
                               ',:b_dimgrp_id'||
                               ',:b_calendar_id'||
                               ',:b_cal_period_name'||
                               ',:b_description'||
                               ',''N'''||
                               ',:b_adj_period_flag'||
                               ' FROM dual'||
                               ' WHERE :b_use_interim_table_flag = ''Y'''||
                               ' AND :b_status = ''LOAD''';
         x_insert_calp_attr_stmt := 'INSERT INTO fem_calp_attr_interim_t'||
                                     '(CAL_PERIOD_ID'||
                                     ',ATTRIBUTE_ID'||
                                     ',VERSION_ID'||
                                     ',DIM_ATTRIBUTE_NUMERIC_MEMBER'||
                                     ',DIM_ATTRIBUTE_VALUE_SET_ID'||
                                     ',DIM_ATTRIBUTE_VARCHAR_MEMBER'||
                                     ',NUMBER_ASSIGN_VALUE'||
                                     ',VARCHAR_ASSIGN_VALUE'||
                                     ',DATE_ASSIGN_VALUE'||
                                     ',OVERLAP_FLAG)'||
                                     ' SELECT'||
                                     ':b_cal_period_id'||
                                     ',:b_attribute_id'||
                                     ',:b_version_id'||
                                     ',:b_dim_attr_numeric_member'||
                                     ',:b_dim_attr_value_set_id'||
                                     ',:b_dim_attr_varchar_member'||
                                     ',:b_number_assign_value'||
                                     ',:b_varchar_assign_value'||
                                     ',:b_date_assign_value'||
                                     ',''N'''||
                                     ' FROM dual'||
                                     ' WHERE :b_use_interim_table_flag = ''Y'''||
                                     ' AND :b_status = ''LOAD''';



END build_calp_interim_insert_stmt;


/*===========================================================================+
 | PROCEDURE
 |              TRUNCATE_CALP_INTERIM
 |
 | DESCRIPTION
 |                 Truncates the INTERIM tables used in CAL_PERIOD loads
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   11-JAN-05  Created
 |
 +===========================================================================*/
PROCEDURE truncate_calp_interim

IS

   v_truncate_stmt VARCHAR2(4000);

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'Truncate_calp_interim'||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   v_truncate_stmt := 'delete from fem_calp_interim_t';
   EXECUTE IMMEDIATE v_truncate_stmt;

     commit;
   v_truncate_stmt := 'delete from fem_calp_attr_interim_t';
   EXECUTE IMMEDIATE v_truncate_stmt;

             commit;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'Truncate_calp_interim'||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


END truncate_calp_interim;

/*===========================================================================+
 | PROCEDURE
 |              GET_ATTR_ASSIGN_CALP
 |
 | DESCRIPTION
 |                 Identifies the CAL_PERIOD_ID for the attribute assignment
 |                 when the attribute LOV comes from the CAL_PERIOD dimension
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   11-JAN-05  Created
 |
 +===========================================================================*/
procedure get_attr_assign_calp          (x_cal_period_id OUT NOCOPY VARCHAR2
                                        ,x_record_status OUT NOCOPY VARCHAR2
                                        ,p_calendar_dc IN VARCHAR2
                                        ,p_dimension_group_dc IN VARCHAR2
                                        ,p_end_date IN DATE
                                        ,p_cal_period_number IN NUMBER)
IS

   v_calendar_id        NUMBER;
   v_dimension_group_id NUMBER;
   v_cal_period_id      NUMBER;

BEGIN

   BEGIN
      SELECT calendar_id
      INTO v_calendar_id
      FROM fem_calendars_b
      WHERE calendar_display_code = p_calendar_dc;
   EXCEPTION
      WHEN no_data_found THEN x_record_status := 'INVALID_CALPATTR_CALENDAR';
   END;

   BEGIN
      SELECT dimension_group_id
      INTO v_dimension_group_id
      FROM fem_dimension_grps_b
      WHERE dimension_group_display_code = p_dimension_group_dc;
   EXCEPTION
      WHEN no_data_found THEN x_record_status := 'INVALID_CALPATTR_DIMGRP';
   END;

   v_cal_period_id := fem_dimension_util_pkg.generate_member_id(
      P_END_DATE => p_end_date
     ,P_PERIOD_NUM => p_cal_period_number
     ,P_CALENDAR_ID => v_calendar_id
     ,P_DIM_GRP_ID => v_dimension_group_id);

   IF x_record_status IS NULL
      AND (v_cal_period_id IS NULL
      OR v_cal_period_id <= 0) THEN
      x_record_status := 'INVALID_CALPATTR';
   ELSIF x_record_status IS NULL
      AND v_cal_period_id > 0 THEN
      x_record_status := 'LOAD';
   END IF;

   x_cal_period_id := to_char(v_cal_period_id);

END get_attr_assign_calp;


/*===========================================================================+
 | PROCEDURE
 |              POST_CAL_PERIODS
 |
 | DESCRIPTION
 |                 Moves Cal Periods from the Interim table into
 |                 FEM
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   06-JAN-05  Created
 |    Rob Flippo   22-APR-05  Bug#4305050 Calendar_ID and Dimension_Group_ID
 |                            were being swapped on insert member
 |    Rob Flippo   07-OCT-05  Bug#4628009 Fixed problem in Post_Cal_Periods where
 |                            the Cal Period Name and Description table variables
 |                            had a type of varchar2(30) instead of 150 and 255.
 |    Rob Flippo  04-AUG-06   Bug 5060746 Change literals to bind variables wherever possible
 |
 +===========================================================================*/
PROCEDURE Post_Cal_Periods (p_eng_sql IN VARCHAR2
                           ,p_data_slc IN VARCHAR2
                           ,p_proc_num IN VARCHAR2
                           ,p_partition_code IN NUMBER
                           ,p_fetch_limit IN NUMBER
                           ,p_operation_mode IN VARCHAR2
                           ,p_master_request_id IN NUMBER)
IS

   c_proc_name                       VARCHAR2(30) := 'Post_Cal_Periods';

   v_fetch_limit                     NUMBER;
   v_mbr_last_row                    NUMBER;
   v_attribute_id                    NUMBER;  -- of the CAL_PERIOD_START_DATE attribute
   v_version_id                      NUMBER;  -- Default version of CAL_PERIOD_START_DATE

   t_cal_period_id                number_type;
   t_calendar_id                  number_type;
   t_dimension_group_id           number_type;
   t_cal_period_name              varchar2_150_type;
   t_description                  desc_type;
   t_start_date                   date_type;
   t_cal_period_number            number_type;
   t_cal_period_end_date          date_type;
   t_calendar_display_code        varchar2_std_type;
   t_dimension_group_display_code varchar2_std_type;

   x_insert_mbr_stmt                 VARCHAR2(4000);
   x_insert_attr_stmt                VARCHAR2(4000);
   x_select_mbr_stmt                 VARCHAR2(4000);
   x_update_attr_stmt                VARCHAR2(4000);
   x_delete_b_stmt                   VARCHAR2(4000);
   x_delete_tl_stmt                  VARCHAR2(4000);
   x_delete_attr_stmt                VARCHAR2(4000);

-- MP variables
   v_loop_counter                    NUMBER;
   v_slc_id                          NUMBER;
   v_slc_val                         VARCHAR2(100);
   v_slc_val2                        VARCHAR2(100);
   v_slc_val3                        VARCHAR2(100);
   v_slc_val4                        VARCHAR2(100);
   v_mp_status                       VARCHAR2(30);
   v_mp_message                      VARCHAR2(4000);
   v_num_vals                        NUMBER;
   v_part_name                       VARCHAR2(4000);


   ---------------------
   -- Declare cursors --
   ---------------------
   cv_get_rows           cv_curs;

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'Post_Cal_Periods'||'.Begin',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||'Post_Cal_Periods'||'.p_operation_mode',p_operation_mode);

   --x_status := 0; -- initialize status of the New_Members procedure
   --x_message := 'COMPLETE:NORMAL';

   -- set the local fetch limit variable based on the parameter
   v_fetch_limit := p_fetch_limit;
   IF v_fetch_limit IS NULL THEN
      v_fetch_limit := 10000;
   END IF;

   ----------------------------------------------
   -- build the statement to fetch the members for processing
   -- This statement is used by both modes (New Members and Attr Update)
   ----------------------------------------------
   x_select_mbr_stmt := 'SELECT '||
                        'B.cal_period_id'||
                        ', B.calendar_id'||
                        ', B.dimension_group_id'||
                        ', B.cal_period_name'||
                        ', B.description'||
                        ', B.cal_period_start_date'||
                        ', B.cal_period_end_date'||
                        ', B.cal_period_number'||
                        ', B.calendar_display_code'||
                        ', B.dimension_group_display_code'||
                        ' FROM fem_calp_interim_t B'||
                        ' WHERE B.overlap_flag = ''N'''||
                        ' AND   {{data_slice}} ';
   IF p_data_slc IS NOT NULL THEN
      x_select_mbr_stmt := REPLACE(x_select_mbr_stmt,'{{data_slice}}',p_data_slc);
   ELSE
      x_select_mbr_stmt := REPLACE(x_select_mbr_stmt,'{{data_slice}}','1=1');
   END IF;
   ----------------------------------------------------------------------
     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.select_mbr_stmt'
     ,x_select_mbr_stmt);

   IF p_operation_mode = 'NEW_MEMBERS' THEN
         x_insert_mbr_stmt :=
                   'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER;'||
                   'BEGIN FEM_CAL_PERIODS_PKG.INSERT_ROW '||
                   '(x_rowid => v_row_id '||
                  ',x_cal_period_id => :b_cal_period_id'||
                  ',x_dimension_group_id => :b_dimension_group_id '||
                  ',x_calendar_id => :b_calendar_id '||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_cal_period_name => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.insert_mbr_stmt'
     ,x_insert_mbr_stmt);

      x_insert_attr_stmt := 'INSERT INTO FEM_CAL_PERIODS_ATTR '||
                            '(CAL_PERIOD_ID'||
                            ',ATTRIBUTE_ID'||
                            ',VERSION_ID'||
                            ',DIM_ATTRIBUTE_NUMERIC_MEMBER'||
                            ',DIM_ATTRIBUTE_VALUE_SET_ID'||
                            ',DIM_ATTRIBUTE_VARCHAR_MEMBER'||
                            ',NUMBER_ASSIGN_VALUE'||
                            ',VARCHAR_ASSIGN_VALUE'||
                            ',DATE_ASSIGN_VALUE'||
                            ',CREATION_DATE'||
                            ',CREATED_BY'||
                            ',LAST_UPDATED_BY'||
                            ',LAST_UPDATE_DATE'||
                            ',LAST_UPDATE_LOGIN'||
                            ',OBJECT_VERSION_NUMBER'||
                            ',AW_SNAPSHOT_FLAG) '||
                            'SELECT cal_period_id'||
                            ',attribute_id'||
                            ',version_id'||
                            ',dim_attribute_numeric_member'||
                            ',dim_attribute_value_set_id'||
                            ',dim_attribute_varchar_member'||
                            ',number_assign_value'||
                            ',varchar_assign_value'||
                            ',date_assign_value'||
                            ', sysdate'||
                            ',:b_apps_user_id'||
                            ',:b_apps_user_id2'||
                            ', sysdate'||
                            ', null'||
                            ', 1'||
                            ', ''N'''||
                            ' FROM fem_calp_attr_interim_t'||
                            ' WHERE cal_period_id = :b_cal_period_id';
     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.insert_attr_stmt'
     ,x_insert_attr_stmt);

     build_calp_delete_stmt ('FEM_CAL_PERIODS_B_T'
                            ,p_operation_mode
                            ,x_delete_b_stmt);

     build_calp_delete_stmt ('FEM_CAL_PERIODS_TL_T'
                            ,p_operation_mode
                            ,x_delete_tl_stmt);

     build_calp_delete_stmt ('FEM_CAL_PERIODS_ATTR_T'
                            ,p_operation_mode
                            ,x_delete_attr_stmt);


   ELSE
      x_update_attr_stmt := 'UPDATE fem_cal_periods_attr'||
                            ' SET date_assign_value = :b_start_date'||
                            ',creation_date = sysdate'||
                            ',last_update_date = sysdate'||
                            ',last_updated_by = :b_apps_user_id'||
                            ' WHERE cal_period_id = :b_cal_period_id'||
                            ' AND attribute_id = :b_attribute_id'||
                            ' AND version_id = :b_version_id';

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.update_attr_stmt'
     ,x_update_attr_stmt);

     build_calp_delete_stmt ('FEM_CAL_PERIODS_ATTR_T'
                            ,p_operation_mode
                            ,x_delete_attr_stmt);

     FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_1,c_block||'.'||c_proc_name||'.delete_attr_stmt'
     ,x_delete_attr_stmt);

      -- identify the attribute_id and default version for the START_DATE attribute
      SELECT attribute_id
      INTO v_attribute_id
      FROM fem_dim_attributes_b
      WHERE attribute_varchar_label = 'CAL_PERIOD_START_DATE';

      SELECT version_id
      INTO v_version_id
      FROM fem_dim_attr_versions_b
      WHERE attribute_id = v_attribute_id
      AND default_version_flag = 'Y';

   END IF;

   v_loop_counter := 0; -- used for DIMENSION_GROUP loads to identify when to exit
                        -- the data slice loop
   LOOP

      FEM_Multi_Proc_Pkg.Get_Data_Slice(
        x_slc_id => v_slc_id,
        x_slc_val1 => v_slc_val,
        x_slc_val2 => v_slc_val2,
        x_slc_val3 => v_slc_val3,
        x_slc_val4 => v_slc_val4,
        x_num_vals  => v_num_vals,
        x_part_name => v_part_name,
        p_req_id => p_master_request_id,
        p_proc_num => p_proc_num);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val'
       ,v_slc_val);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val2'
       ,v_slc_val2);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val3'
       ,v_slc_val3);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||c_proc_name||'.get_data_slice.slc_val4'
       ,v_slc_val4);


      EXIT WHEN (v_slc_id IS NULL);

   ----------------------------------------------
   -- Fetch the new members into the array
   ----------------------------------------------
   OPEN cv_get_rows FOR x_select_mbr_stmt USING v_slc_val, v_slc_val2;

   LOOP

      FETCH cv_get_rows BULK COLLECT INTO
            t_cal_period_id
            ,t_calendar_id
            ,t_dimension_group_id
            ,t_cal_period_name
            ,t_description
            ,t_start_date
            ,t_cal_period_end_date
            ,t_cal_period_number
            ,t_calendar_display_code
            ,t_dimension_group_display_code
      LIMIT v_fetch_limit;
      ----------------------------------------------
      -- EXIT Fetch LOOP If No Rows are Retrieved --
      ----------------------------------------------
      v_mbr_last_row := t_cal_period_id.LAST;

      IF (v_mbr_last_row IS NULL) THEN
         EXIT;
      END IF;

      -- If running in NEW_MEMBERS mode, we do the following:
      -- 1)  call table handler to create the new CAL_PERIOD members
      -- 2)  run an insert statement to move the attribute assignments from the
      --     INTERIM table into FEM_CAL_PERIODS_ATTR
      -- 3)  Remove the rows from the _B_T, TL_T and ATTR_T tables for the successful
      --     members
      IF p_operation_mode = 'NEW_MEMBERS' THEN
         ----------------------------------------------------------
         -- Call the table handler insert stmt for each new member
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_insert_mbr_stmt
            USING t_cal_period_id(i)
                 ,t_dimension_group_id(i)
                 ,t_calendar_id(i)
                 ,t_cal_period_name(i)
                 ,t_description(i)
                 ,gv_apps_user_id
                 ,gv_apps_user_id;

         ----------------------------------------------------------
         -- Call the insert attr stmt for each new member
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_insert_attr_stmt
            USING gv_apps_user_id
                 ,gv_apps_user_id
                 ,t_cal_period_id(i);

         ----------------------------------------------------------
         -- Delete the records from the _B_T table
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_delete_b_stmt
            USING t_cal_period_number(i)
                 ,t_cal_period_end_date(i)
                 ,t_calendar_display_code(i)
                 ,t_dimension_group_display_code(i);

         ----------------------------------------------------------
         -- Delete the records from the _TL_T table
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_delete_tl_stmt
            USING t_cal_period_number(i)
                 ,t_cal_period_end_date(i)
                 ,t_calendar_display_code(i)
                 ,t_dimension_group_display_code(i);

         ----------------------------------------------------------
         -- Delete the records from the _ATTR_T table
         ----------------------------------------------------------
         IF p_operation_mode = 'NEW_MEMBERS' THEN
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_delete_attr_stmt
               USING t_cal_period_number(i)
                    ,t_cal_period_end_date(i)
                    ,t_calendar_display_code(i)
                    ,t_dimension_group_display_code(i);

         ELSE
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_delete_attr_stmt
               USING t_cal_period_number(i)
                    ,t_cal_period_end_date(i)
                    ,t_calendar_display_code(i)
                    ,t_dimension_group_display_code(i)
                    ,t_cal_period_id(i);
         END IF;

      ELSE -- we only update an existing assignment
           -- since the START_DATE attribute is required and must
           -- therefore always already exist
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_attr_stmt
            USING t_start_date(i)
                 ,gv_apps_user_id
                 ,t_cal_period_id(i)
                 ,v_attribute_id
                 ,v_version_id;

         ----------------------------------------------------------
         -- Delete the records from the _ATTR_T table
         ----------------------------------------------------------
         IF p_operation_mode = 'NEW_MEMBERS' THEN
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_delete_attr_stmt
               USING t_cal_period_number(i)
                    ,t_cal_period_end_date(i)
                    ,t_calendar_display_code(i)
                    ,t_dimension_group_display_code(i);

         ELSE
            FORALL i IN 1..v_mbr_last_row
               EXECUTE IMMEDIATE x_delete_attr_stmt
               USING t_cal_period_number(i)
                    ,t_cal_period_end_date(i)
                    ,t_calendar_display_code(i)
                    ,t_dimension_group_display_code(i)
                    ,t_cal_period_id(i);
         END IF;

      END IF;

      t_cal_period_id.DELETE;
      t_calendar_id.DELETE;
      t_dimension_group_id.DELETE;
      t_cal_period_name.DELETE;
      t_description.DELETE;
      t_start_date.DELETE;
      t_cal_period_end_date.DELETE;
      t_cal_period_number.DELETE;
      t_calendar_display_code.DELETE;
      t_dimension_group_display_code.DELETE;


           COMMIT;

   END LOOP;
   END LOOP; --get_data_slice
   IF cv_get_rows%ISOPEN THEN
      CLOSE cv_get_rows;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'Post_Cal_Periods'||'.End',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

END Post_Cal_Periods;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_ENABLE_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating
 |                 the enabled flag for dimension members.  This procedure
 |                 allows users to "undelete" a member by populating the
 |                 _B_T table with the member for a load.  The loader will
 |                 automatically undelete any existing members from the _B_T
 |                 table.
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   27-SEP-04  Created
 |    Rob Flippo   03-MAR-05  Modified so that is updating a Dim Grp we use
 |                            where condition on dimension_id so that dim grps
 |                            with the same name for other dimensions don't get
 |                            mixed into the update
 |    Rob Flippo   15-MAR-05  Modify value set update so that use value_set
 |                            in the subquery (otherwise get too many rows if
 |                            2 members have same display_code)
 +===========================================================================*/


   procedure build_enable_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_update_stmt OUT NOCOPY VARCHAR2)

    IS

       v_dimlabel_cond VARCHAR2(1000);

     BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_enable_update_stmt','Begin Build Enabled flag update statement');

        IF p_load_type = 'DIMENSION_GROUP' THEN
           v_dimlabel_cond := ' AND dimension_id = '||p_dimension_id;
        ELSE
           v_dimlabel_cond := '';
        END IF;


        IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN

        x_update_stmt :=
        'UPDATE '||p_target_b_table||
           ' SET enabled_flag = ''Y'''||
           ',last_update_date = sysdate '||
           ',last_updated_by = '||gv_apps_user_id||
           ',last_update_login = '||gv_login_id||
           ' WHERE to_char('||p_member_col||') = :b_member_code'||
           ' AND   :b_t_a_status = ''LOAD''';

        ELSIF (p_value_set_required_flag = 'Y') THEN

        x_update_stmt :=
        'UPDATE '||p_target_b_table||
           ' SET enabled_flag = ''Y'''||
           ',last_update_date = sysdate '||
           ',last_updated_by = '||gv_apps_user_id||
           ',last_update_login = '||gv_login_id||
           ' WHERE '||p_member_col||' = (SELECT '||p_member_col||
           ' FROM '||p_target_b_table||' T'||
           ', fem_value_sets_b V'||
           ' WHERE to_char(T.'||p_member_dc_col||') = :b_member_display_code'||
           ' AND T.value_set_id = V.value_set_id'||
           ' AND V.value_set_display_code = :b_value_set_display_code)'||
           ' AND value_set_id = (SELECT value_set_id FROM FEM_VALUE_SETS_B'||
           ' WHERE value_set_display_code = :b_value_set_display_code)'||
           ' AND   :b_t_a_status = ''LOAD''';


        ELSE

        x_update_stmt :=
        'UPDATE '||p_target_b_table||
           ' SET enabled_flag = ''Y'''||
           ',last_update_date = sysdate '||
           ',last_updated_by = '||gv_apps_user_id||
           ',last_update_login = '||gv_login_id||
           ' WHERE '||p_member_col||' = (SELECT '||p_member_col||
           ' FROM '||p_target_b_table||
           ' WHERE to_char('||p_member_dc_col||') = :b_member_display_code'||
           v_dimlabel_cond||
           ')'||
           ' AND   :b_t_a_status = ''LOAD''';

        END IF;
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_enable_update_stmt','End');

     END build_enable_update_stmt;

/*===========================================================================+
 | PROCEDURE
 |              BUILD_TL_DUPNAME_STMT
 |
 | DESCRIPTION
 |                 Builds the dynamic SELECT statement for verifying if
 |                 a translatable name already exists for another dimension
 |                 member
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   13-MAR-06  Created
 |
 +===========================================================================*/

procedure build_tl_dupname_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_name_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_calling_mode IN VARCHAR2
                                ,x_select_stmt OUT NOCOPY VARCHAR2)
IS

   v_dim_id_where_cond VARCHAR2(1000);
   v_vs_where_cond VARCHAR2(1000);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_tl_dupname_stmt','Begin Build select statement for dupname check');

      IF p_load_type IN ('DIMENSION_GROUP') THEN
         v_dim_id_where_cond := ' AND B.dimension_id = '||p_dimension_id;
      ELSE
         v_dim_id_where_cond := '';
      END IF;


      IF p_dimension_varchar_label = 'CAL_PERIOD'
         AND p_load_type NOT IN ('DIMENSION_GROUP') THEN
         IF p_calling_mode = 'NEW_MEMBERS' THEN
             x_select_stmt :=
               'SELECT count(*) FROM '||p_target_tl_table||
               ' WHERE '||p_member_name_col||' = :b_member_name'||
               ' AND dimension_group_id = :b_dimgrp_id'||
               ' AND calendar_id = :b_calendar_id';
         ELSE
             x_select_stmt :=
               'SELECT count(*) FROM '||
               p_target_tl_table||' T, '||p_target_b_table||' B'||
               ' WHERE T.'||p_member_name_col||' = :b_member_name'||
               ' AND T.'||p_member_col||' = B.'||p_member_col||
               ' AND to_char(B.'||p_member_dc_col||') <> :b_member_dc'||
               ' AND T.language = :b_lang'||
               ' AND T.dimension_group_id = :b_dimgrp_id'||
               ' AND T.calendar_id = :b_calendar_id';
         END IF;


      ELSE
         IF p_calling_mode = 'NEW_MEMBERS' THEN
            IF p_value_set_required_flag = 'Y'
               AND p_load_type NOT IN ('DIMENSION_GROUP') THEN
              v_vs_where_cond := ' AND value_set_id = (SELECT value_set_id'||
                                 ' FROM fem_value_sets_b '||
                                 ' WHERE value_set_display_code = :vs_dc)';
            ELSE v_vs_where_cond := '';
            END IF;

             x_select_stmt :=
               'SELECT count(*) FROM '||p_target_tl_table||
               ' WHERE '||p_member_name_col||' = :b_member_name'||
               v_vs_where_cond;
         ELSE
            IF p_value_set_required_flag = 'Y'
               AND p_load_type NOT IN ('DIMENSION_GROUP') THEN
              v_vs_where_cond := ' AND B.value_set_id = T.value_set_id'||
                                 ' AND B.value_set_id = (SELECT value_set_id'||
                                 ' FROM fem_value_sets_b '||
                                 ' WHERE value_set_display_code = :vs_dc)';
            ELSE v_vs_where_cond := '';
            END IF;

             x_select_stmt :=
               'SELECT count(*) FROM '||
               p_target_tl_table||' T, '||p_target_b_table||' B'||
               ' WHERE T.'||p_member_name_col||' = :b_member_name'||
               ' AND T.'||p_member_col||' = B.'||p_member_col||
               ' AND to_char(B.'||p_member_dc_col||') <> :b_member_dc'||
               ' AND T.language = :b_lang'||
               v_vs_where_cond||
               v_dim_id_where_cond;
         END IF;

      END IF; -- cal_period

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_tl_dupname_stmt','End');


END build_tl_dupname_stmt;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_TL_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating
 |                 the translatable names/descriptions for dimension members
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |    This procedure does not use the table handlers for performing the update,
 |    since we may be updating multiple languages.
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   22-OCT-03  Created
 |
 |    Rob Flippo   16-FEB-05  Bug#4189544 DIMENSION GROUP LOADER ISSUE
 |                            add dimension_id where condition when target
 |                            table is fem_dimension_grps_b
 |    Rob Flippo   22-MAR-05  Fix problem with same display_code in multiple
 |                            value sets (single row query returns multiple rows)
 |    Rob Flippo   10-MAR-06  Bug#5068022 modify update so that only
 |                            records where status in the array = 'LOAD' get
 |                            updated
 |    Rob Flippo  04-AUG-06   Bug 5060746 Change literals to bind variables wherever possible
 |    Rob Flippo  15-MAR-07  Bug#5905501 Need to update source_lang so that
 |                           translated rows get marked properly
 +===========================================================================*/


   procedure build_tl_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_load_type IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_target_tl_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_name_col IN VARCHAR2
                                ,p_member_description_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_update_stmt OUT NOCOPY VARCHAR2)

    IS

       v_dim_id_where_cond VARCHAR2(1000);

     BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_tl_update_stmt','Begin Build update statement for TL table');

        IF p_load_type IN ('DIMENSION_GROUP') THEN
           v_dim_id_where_cond := ' AND dimension_id = '||p_dimension_id;
        ELSE
           v_dim_id_where_cond := '';
        END IF;

        IF (p_dimension_varchar_label = 'CAL_PERIOD') AND
         p_load_type NOT IN ('DIMENSION_GROUP') THEN

        x_update_stmt :=
        'UPDATE '||p_target_tl_table||
           ' SET '||p_member_name_col||' = :b_member_name,'||
           p_member_description_col||' = :b_member_desc'||
           ',source_lang = :b_source_lang'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE to_char('||p_member_col||') = :b_member_code'||
           ' AND language = :b_language'||
           ' AND :b_status = ''LOAD''';

        ELSIF (p_value_set_required_flag = 'Y') AND
         p_load_type NOT IN ('DIMENSION_GROUP') THEN

        x_update_stmt :=
        'UPDATE '||p_target_tl_table||
           ' SET '||p_member_name_col||' = :b_member_name,'||
           p_member_description_col||' = :b_member_desc'||
           ',source_lang = :b_source_lang'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE '||p_member_col||' = (SELECT T.'||p_member_col||
           ' FROM '||p_target_b_table||' T'||
           ',fem_value_sets_b V'||
           ' WHERE to_char(T.'||p_member_dc_col||') = :b_member_display_code'||
           ' AND T.value_set_id = V.value_set_id'||
           ' AND V.value_set_display_code = :b_value_set_display_code'||
           ')'||
           ' AND value_set_id = (SELECT value_set_id FROM FEM_VALUE_SETS_B'||
           ' WHERE value_set_display_code = :b_value_set_display_code)'||
           ' AND language = :b_language'||
           ' AND :b_status = ''LOAD''';


        ELSE

        x_update_stmt :=
        'UPDATE '||p_target_tl_table||
           ' SET '||p_member_name_col||' = :b_member_name,'||
           p_member_description_col||' = :b_member_desc'||
           ',source_lang = :b_source_lang'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE '||p_member_col||' = (SELECT '||p_member_col||
           ' FROM '||p_target_b_table||
           ' WHERE to_char('||p_member_dc_col||') = :b_member_display_code'||
           v_dim_id_where_cond||
           ')'||
           ' AND language = :b_language'||
           ' AND :b_status = ''LOAD''';

        END IF;
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_tl_update_stmt','End');

     END build_tl_update_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_ATTR_LVLSPEC_SELECT_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 retrieving attribute rows from the ATTR_T table
 |                 where the attribute is level specific but the member
 |                 does not belong to the level.  This is so we can update
 |                 the row with status = 'INVALID_LVL_SPEC_ATTR_LABEL'.
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   09-JUN-05  Created
 |
 +===========================================================================*/

   procedure build_attr_lvlspec_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_outer_join_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2)
   IS
      -- Value Set where conditions
      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_select_T1         VARCHAR2(1000);
      v_value_set_select_T2         VARCHAR2(1000);
      v_vs_where_M2               VARCHAR2(1000);  -- where condition for Specific Member='No'
      v_vs_table                  VARCHAR2(1000);

      -- Special conditions to handle CAL_PERIOD
      v_member_code                VARCHAR2(1000);
      v_calendar_id                VARCHAR2(100);
      v_calendar_table             VARCHAR2(100);
      v_calendar_where_cond        VARCHAR2(1000);
      v_member_dc_where_cond       VARCHAR2(1000);

      -- additional conditions
      v_outer_join                 VARCHAR2(3);
      v_dim_label_where_cond       VARCHAR2(1000);


   BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_attr_lvlspec_select_stmt',
          'Begin Build select statement for level specific attribute assignments from source _ATTR_T table');

      IF p_outer_join_flag = 'Y' THEN
         v_outer_join := '(+)';
      ELSE
         v_outer_join := '';
      END IF; -- p_outer_join_flag

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


      IF p_dimension_varchar_label = 'CAL_PERIOD' THEN

         v_member_code :=
               'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'') ';

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,''INVALID_LVL_SPEC_ATTR_LABEL'' '||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.cal_period_number CAL_PERIOD_NUMBER'||
           ', C.calendar_id CALENDAR_ID'||
           ', C.calendar_display_code CALENDAR_DC'||
           ', D.dimension_group_id DIMENSION_GROUP_ID'||
           ', D.dimension_group_display_code DIMENSION_GROUP_DC'||
           ', B.version_display_code'||
    	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
	       ', B.cal_period_end_date'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ', FEM_CALENDARS_VL C, FEM_DIMENSION_GRPS_B D'||
           ' WHERE B.calendar_display_code = C.calendar_display_code '||
           ' AND B.status'||p_exec_mode_clause||
           ' AND   {{data_slice}} '||
           ' AND B.dimension_group_display_code = D.dimension_group_display_code'||
           ' AND D.dimension_id = '||p_dimension_id||') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND ('||
           ' ((A1.attribute_required_flag =''N'') '||
           ' AND (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2)))'||
           ' AND (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG3'||
           ' WHERE AG3.dimension_group_id = T2.dimension_group_id)))';

      ELSE -- not a Cal Period
         v_member_code := p_member_t_dc_col;

         IF (p_hier_dimension_flag = 'Y')
            AND (p_value_set_required_flag = 'Y') THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,''INVALID_LVL_SPEC_ATTR_LABEL'' '||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.value_set_display_code'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ', fem_value_sets_b V2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND M2.value_set_id = V2.value_set_id '||
           ' AND V2.value_set_display_code = T2.value_set_display_code'||
           ' AND V2.dimension_id = '||p_dimension_id||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND ('||
           ' ((A1.attribute_required_flag =''N'') '||
           ' AND (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2)))'||
           ' AND (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG3'||
           ' WHERE AG3.dimension_group_id = M2.dimension_group_id)))';

         ELSIF (p_hier_dimension_flag = 'Y')
            AND (p_value_set_required_flag = 'N') THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,''INVALID_LVL_SPEC_ATTR_LABEL'' '||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND ('||
           ' ((A1.attribute_required_flag =''N'') '||
           ' AND (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2)))'||
           ' AND (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG3'||
           ' WHERE AG3.dimension_group_id = M2.dimension_group_id)))';

         END IF;
      END IF; -- IF Cal Period 'Y' or 'N'


        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_attr_lvlspec_select_stmt',
          'End');


   END build_attr_lvlspec_select_stmt;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_ATTR_SELECT_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 retrieving attribute rows from the ATTR_T table
 |                 along with the corresponding attribute metadata from
 |                 FEM_DIM_ATTRIBUTES_B
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |    Procedure is split into 4 sections:
 |       For CAL Period - getting for new specific member
 |                        getting only where member exists, but multiple members
 |       For Value Set Dim - getting for new specific member
 |                           getting only where member exists but mult members
 |
 |       When getting for new specific member:
 |          Only get default version of 'Req' attributes
 |
 |       This means that when processing new members, only required attributes
 |       are read.  All other attribute assignments get loaded only after
 |       the member is already created.
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   23-OCT-03  Created
 |    Rob Flippo   13-SEP-04  Modified so that when looking for required attributes
 |                            (in the specific member select), we don't care if
 |                            any rows exist in FEM_DIM_ATTR_GRPS, because Req
 |                            attributes not allowed to be assigned in that table
 |                            However, when specific_member = 'N', we do need to
 |                            check FEM_DIM_ATTR_GRPS.
 |
 |                            The logic for checking is as follows:
 |                            If attribute_required_flag = 'N', then we
 |                            check FEM_DIM_ATTR_GRPS to see if it has been
 |                            assigned specifically to any groups.  But if the
 |                            attribute_required_flag='Y', then we don't check.
 |
 |                            Also - modified all of the queries to join with the
 |                            fem_dim_attr_versions_b table and restrict on min(version_id)
 |                            Previously, this was only occuring for specific_member='Y'.
 |                            This needs to occur for every attribute query since
 |                            the pre_validation_attr procedure already exists to mark
 |                            rows with invalid version_display_code.
 |   Rob Flippo   01-OCT-04   Modified query to retieve member read_only_flag
 |                            for the "specific_member=Y" queries (i.e., the queries used
 |                            by the attr_assign_update procedure to update attr
 |                            of existing members);  For "specific_member=N", it returns
 |                            null for that flag;
 |   Rob Flippo   12-NOV-04   Add where condition on aw_snapshot_flag = 'N' so that
 |                            users can't try to update snapshot versions using the
 |                            loader
 |   Rob Flippo   04-JAN-05   For CAL_PERIOD, added a new column
 |                            to the select for "use_interim_table_flag = Y".  This
 |                            info is only queried during the ATTR_ASSIGN_UPDATE
 |                            to identify any CAL Period attributes that require
 |                            use of the FEM_CALP_ATTR_INTERIM_T table prior to
 |                            moving the assignment into FEM
 |
 |                            Also added selection of new columns for Spec Mbr =N
 |                            for CAL_PERIOD so that we have enough information to
 |                            insert into the INTERIM tables for overlap checking
 |
 |                            Bug#3822561  Added 4 new CALPATTR columns to all
 |                            Select statements to support attributes of CAL_PERIOD
 |
 |                            Also - for non-value set dims, added where condition
 |                            for dimension_varchar_label if the dim uses the shared
 |                            attr table
 |   Rob Flippo   15-MAR-05   Bug#4226011 Modified to only retreive attributes where
 |                            user_assign_allowed_flag not in ('N');
 |   Rob Flippo   09-JUN-05   Modify for Specific_mbr_flag='N' case
 |                            where dim supports levels (hier_flag=Y)
 |                            but is value_set_required='N'
 |   Rob Flippo   11-AUG-05   Bug#4547868 get member_id and value_set_id
 |                            for the attr_update phase
 +===========================================================================*/

   procedure build_attr_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_hier_dimension_flag IN VARCHAR2
                                ,p_outer_join_flag IN VARCHAR2
                                ,p_specific_member_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2)
   IS
      -- Value Set where conditions
      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_select_T1         VARCHAR2(1000);
      v_value_set_select_T2         VARCHAR2(1000);
      v_vs_where_M2               VARCHAR2(1000);  -- where condition for Specific Member='No'
      v_vs_table                  VARCHAR2(1000);

      -- Special conditions to handle CAL_PERIOD
      v_member_code                VARCHAR2(1000);
      v_calendar_id                VARCHAR2(100);
      v_calendar_table             VARCHAR2(100);
      v_calendar_where_cond        VARCHAR2(1000);
      v_member_dc_where_cond       VARCHAR2(1000);

      -- additional conditions
      v_outer_join                 VARCHAR2(3);
      v_dim_label_where_cond       VARCHAR2(1000);
      v_spcmbr_dim_label_where_cond    VARCHAR2(1000);


   BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_attr_select_stmt',
          'Begin Build select statement for attributes from source _ATTR_T table');

      -- The Specific Member Flag indicates if we are looking for attributes of a
      -- given Member ID and Value Set where attribute_required_flag = 'Y'.
      -- If we are not looking for a specific member, then we are looking only
      -- for attributes where the member already exists
      -- The SQL for "specific Member" is used when creating new members,
      -- since it does not require that the member exist, and also only gets
      -- attr assignments for the "default" version


      IF p_outer_join_flag = 'Y' THEN
         v_outer_join := '(+)';
      ELSE
         v_outer_join := '';
      END IF; -- p_outer_join_flag

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
         v_spcmbr_dim_label_where_cond :=
            ' AND S1.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
         v_spcmbr_dim_label_where_cond := '';
      END IF;

/*
      IF p_value_set_required_flag = 'Y' THEN
        v_value_set_where_cond := ' AND T2.value_set_display_code'||v_outer_join||' = :b_value_set_display_code';
        v_value_set_select_T1     := ', T1.value_set_display_code';
        v_value_set_select_T2     := ', T2.value_set_display_code';
        v_vs_where_M2  := ' AND M2.value_set_id = V2.value_set_id '||
                          ' AND V2.value_set_display_code = T2.value_set_display_code';
        v_vs_table     := ', fem_value_sets_b V2';


      ELSE
        v_value_set_where_cond       := '';
        v_value_set_select_T1           := ',null';
        v_value_set_select_T2           := ',null';
        v_vs_where_M2                   := '';
        v_vs_table                      := '';

      END IF; */

      IF p_dimension_varchar_label = 'CAL_PERIOD' THEN

         v_member_code :=
               'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'') ';
/*
         v_calendar_id    := ', C.calendar_id';
         v_calendar_table := ', FEM_CALENDARS_VL C, FEM_DIMENSION_GRPS_B D';
         v_calendar_where_cond := ' WHERE T1.calendar_display_code = C.calendar_display_code '||
                                  ' AND T1.dimension_group_display_code = D.dimension_group_display_code';
*/

         IF (p_specific_member_flag = 'Y') THEN
         -- Data_slc predicate does not apply
           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,null'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ' ,T2.member_code'||
           ' ,null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null'||
           ' ,''LOAD'''||
           ',''Y'''||
           ', T2.CALPATTR_CAL_DISPLAY_CODE'||
           ', T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', T2.CALPATTR_END_DATE'||
           ', T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', D.dimension_group_id'||
           ', B.version_display_code'||
      	   ', B.attribute_assign_value'||
    	   ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ','||p_source_b_table||' S1'||
           ', fem_dimension_grps_b D'||
           ', FEM_CALENDARS_VL C'||
           ' WHERE B.calendar_display_code = C.calendar_display_code'||
           ' AND S1.calendar_display_code = B.calendar_display_code'||
           ' AND S1.dimension_group_display_code = B.dimension_group_display_code'||
           ' AND S1.cal_period_end_date = B.cal_period_end_date'||
           ' AND S1.cal_period_number = B.cal_period_number'||
           ' AND B.status'||p_exec_mode_clause||
           ' AND S1.dimension_group_display_code = D.dimension_group_display_code'||
           ' AND D.dimension_id = '||p_dimension_id||') T2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND T2.member_code '||v_outer_join||' = :b_member_display_code'||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.version_id IN (SELECT min(version_id) FROM fem_dim_attr_versions_b V3'||
           ' WHERE V3.default_version_flag = ''Y'''||
           ' AND V3.aw_snapshot_flag = ''N'''||
           ' AND V3.attribute_id = A1.attribute_id)'||
           ' AND A1.attribute_id = V1.attribute_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND A1.attribute_required_flag = ''Y''';


         ELSE
           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ' ,T2.member_code'||
           ' ,null'||
           ' ,T2.member_code'||
           ' ,null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null'||
           ' ,T2.cal_period_end_date'||
           ' ,''LOAD'' '||
           ',decode(A1.attribute_varchar_label,''CAL_PERIOD_START_DATE'',''Y'',''N'')'||
           ' ,T2.cal_period_number'||
           ' ,T2.calendar_dc'||
           ' ,T2.calendar_id'||
           ' ,T2.dimension_group_dc'||
           ' ,T2.dimension_group_id'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.cal_period_number CAL_PERIOD_NUMBER'||
           ', C.calendar_id CALENDAR_ID'||
           ', C.calendar_display_code CALENDAR_DC'||
           ', D.dimension_group_id DIMENSION_GROUP_ID'||
           ', D.dimension_group_display_code DIMENSION_GROUP_DC'||
           ', B.version_display_code'||
    	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
	       ', B.cal_period_end_date'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ', FEM_CALENDARS_VL C, FEM_DIMENSION_GRPS_B D'||
           ' WHERE B.calendar_display_code = C.calendar_display_code '||
           ' AND B.status'||p_exec_mode_clause||
           ' AND   {{data_slice}} '||
           ' AND B.dimension_group_display_code = D.dimension_group_display_code'||
           ' AND D.dimension_id = '||p_dimension_id||') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND (((A1.attribute_required_flag = ''Y''))'||
           ' OR ((A1.attribute_required_flag =''N'') AND '||
           ' (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG1))'||
           ' OR (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2'||
           ' WHERE AG2.dimension_group_id = T2.dimension_group_id))))';


         END IF; -- specific member flag 'Y' or 'N' for Cal Period

      ELSE -- not a Cal Period
         v_member_code := p_member_t_dc_col;
/*
         v_calendar_id := '';
         v_calendar_table := '';
         v_calendar_where_cond := '';
         v_member_dc_where_cond := ' AND B.'||p_member_t_dc_col||
                                   '=T.'||p_member_t_dc_col; */


         IF (p_specific_member_flag = 'Y')
            AND ((p_hier_dimension_flag = 'Y') OR (p_hier_dimension_flag = 'N'))
            AND (p_value_set_required_flag = 'Y') THEN
         -- Data_slc predicate does not apply
           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,null'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', T2.value_set_display_code'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,B.'||v_member_code||' MEMBER_CODE'||
           ', B.value_set_display_code'||
           ', B.version_display_code'||
      	   ', B.attribute_assign_value'||
    	   ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ','||p_source_b_table||' S1'||
           ' WHERE S1.'||v_member_code||' = B.'||v_member_code||
           ' AND S1.value_set_display_code = B.value_set_display_code'||
           ' AND B.status'||p_exec_mode_clause||') T2 '||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND T2.member_code '||v_outer_join||' = :b_member_display_code'||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.version_id IN (SELECT min(version_id) FROM fem_dim_attr_versions_b V3'||
           ' WHERE V3.default_version_flag = ''Y'''||
           ' AND V3.aw_snapshot_flag = ''N'''||
           ' AND V3.attribute_id = A1.attribute_id)'||
           ' AND A1.attribute_id = V1.attribute_id'||
           ' AND T2.value_set_display_code'||v_outer_join||' = :b_value_set_display_code'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND A1.attribute_required_flag = ''Y''';


         ELSIF (p_specific_member_flag = 'Y')
            AND ((p_hier_dimension_flag = 'N') OR (p_hier_dimension_flag = 'Y'))
            AND (p_value_set_required_flag = 'N') THEN
         -- Data_slc predicate does not apply
           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,null'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,B.'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
      	   ', B.attribute_assign_value'||
    	   ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ','||p_source_b_table||' S1'||
           ' WHERE S1.'||v_member_code||' = B.'||v_member_code||
           v_dim_label_where_cond||
           v_spcmbr_dim_label_where_cond||
           ' AND B.status'||p_exec_mode_clause||') T2 '||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND T2.member_code '||v_outer_join||' = :b_member_display_code'||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.version_id IN (SELECT min(version_id) FROM fem_dim_attr_versions_b V3'||
           ' WHERE V3.default_version_flag = ''Y'''||
           ' AND V3.aw_snapshot_flag = ''N'''||
           ' AND V3.attribute_id = A1.attribute_id)'||
           ' AND A1.attribute_id = V1.attribute_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND A1.attribute_required_flag = ''Y''';


         ELSIF (p_specific_member_flag = 'N')
            AND (p_hier_dimension_flag = 'Y')
            AND (p_value_set_required_flag = 'Y') THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', T2.value_set_display_code'||
           ', M2.'||p_member_col||
           ', M2.value_set_id'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.value_set_display_code'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ', fem_value_sets_b V2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND M2.value_set_id = V2.value_set_id '||
           ' AND V2.value_set_display_code = T2.value_set_display_code'||
           ' AND V2.dimension_id = '||p_dimension_id||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND (((A1.attribute_required_flag = ''Y''))'||
           ' OR ((A1.attribute_required_flag =''N'') AND '||
           ' (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG1))'||
           ' OR (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2'||
           ' WHERE AG2.dimension_group_id = M2.dimension_group_id))))';


         ELSIF (p_specific_member_flag = 'N')
            AND (p_hier_dimension_flag = 'N')
            AND (p_value_set_required_flag = 'Y') THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', T2.value_set_display_code'||
           ', M2.'||p_member_col||
           ', M2.value_set_id'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.value_set_display_code'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ', fem_value_sets_b V2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND M2.value_set_id = V2.value_set_id '||
           ' AND V2.dimension_id = '||p_dimension_id||
           ' AND V2.value_set_display_code = T2.value_set_display_code';

         -- surrogate key
         ELSIF (p_specific_member_flag = 'N')
            AND (p_hier_dimension_flag = 'Y')
            AND (p_value_set_required_flag = 'N')
            AND (p_member_col <> p_member_dc_col) THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', null'||
           ', M2.'||p_member_col||
           ', null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND (((A1.attribute_required_flag = ''Y''))'||
           ' OR ((A1.attribute_required_flag =''N'') AND '||
           ' (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG1))'||
           ' OR (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2'||
           ' WHERE AG2.dimension_group_id = M2.dimension_group_id))))';

         -- No surrogate key
         ELSIF (p_specific_member_flag = 'N')
            AND (p_hier_dimension_flag = 'Y')
            AND (p_value_set_required_flag = 'N')
            AND (p_member_col = p_member_dc_col) THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', null'||
           ', null'||
           ', null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code'||
           ' AND (((A1.attribute_required_flag = ''Y''))'||
           ' OR ((A1.attribute_required_flag =''N'') AND '||
           ' (A1.attribute_id NOT IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG1))'||
           ' OR (A1.attribute_id IN (SELECT attribute_id'||
           ' FROM fem_dim_attr_grps AG2'||
           ' WHERE AG2.dimension_group_id = M2.dimension_group_id))))';

         -- surrogate key
         ELSIF p_member_col <> p_member_dc_col THEN

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', null'||
           ',M2.'||p_member_col||
           ', null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code';

         -- no surrogate key
         ELSE

           x_attr_select_stmt :=
           'SELECT T2.base_rowid'||
           ' ,M2.read_only_flag'||
           ' ,A1.attribute_id'||
           ' ,A1.attribute_varchar_label'||
           ' ,A1.attribute_dimension_id'||
           ' ,A1.attribute_value_column_name'||
           ' ,A1.attribute_data_type_code'||
           ' ,A1.attribute_required_flag'||
           ' ,A1.assignment_is_read_only_flag'||
           ' ,A1.allow_multiple_versions_flag'||
           ' ,A1.allow_multiple_assignment_flag'||
           ',T2.member_code'||
           ', null'||
           ', null'||
           ', null'||
           ' ,T2.attribute_assign_value'||
           ' ,null, null, null, null, null'||
           ' ,T2.version_display_code, null'||
           ' ,T2.attr_assign_vs_display_code, null,null'||
           ' ,''LOAD'' '||
           ' ,''N'''||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,null'||
           ' ,T2.CALPATTR_CAL_DISPLAY_CODE'||
           ' ,T2.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ' ,T2.CALPATTR_END_DATE'||
           ' ,T2.CALPATTR_PERIOD_NUM'||
           ' FROM fem_dim_attributes_b A1'||
           ',fem_dim_attr_versions_b V1'||
           ',fem_dimensions_b B1'||
           ',(SELECT B.rowid base_rowid'||
           ', B.attribute_varchar_label,'||v_member_code||' MEMBER_CODE'||
           ', B.version_display_code'||
     	   ', B.attribute_assign_value'||
	       ', B.attr_assign_vs_display_code'||
           ', B.CALPATTR_CAL_DISPLAY_CODE'||
           ', B.CALPATTR_DIMGRP_DISPLAY_CODE'||
           ', B.CALPATTR_END_DATE'||
           ', B.CALPATTR_PERIOD_NUM'||
           ' FROM '||p_source_attr_table||' B'||
           ' WHERE B.status'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND   {{data_slice}} '||
           ') T2'||
           ', '||p_target_b_table||' M2'||
           ' WHERE T2.attribute_varchar_label'||v_outer_join||' = A1.attribute_varchar_label '||
           ' AND B1.dimension_id = A1.dimension_id'||
           ' AND nvl(A1.user_assign_allowed_flag,''Y'') NOT IN (''N'')'||
           ' AND B1.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
           ' AND T2.version_display_code = V1.version_display_code'||
           ' AND V1.attribute_id = A1.attribute_id'||
           ' AND V1.aw_snapshot_flag = ''N'''||
           ' AND M2.'||p_member_dc_col||' = T2.member_code';

         END IF;  -- Specific member flag 'Y' or 'N'
      END IF; -- IF Cal Period 'Y' or 'N'


        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_attr_select_stmt',
          'End');


   END build_attr_select_stmt;

/*===========================================================================+
 | PROCEDURE
 |              BUILD_BAD_ATTR_SELECT_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 retrieving attribute rows from the ATTR_T table
 |                 where the Member does not exist in FEM and does not exist
 |                 in the _B_T interface table.  Such attribute rows are bad
 |                 because the member isn't value, and we want to update their
 |                 STATUS since otherwise it would left as 'LOAD'.
 |
 |                 This procedure runs after the Attribute loader sections
 |                 to ensure that we don't retrieve any ATTR_T records for members
 |                 that would be created by the loader
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |    We are getting ATTR_T records where the member does not exist in
 |    either the "real" FEM dimension member table and does not exist in
 |    the join of the _B_T with the _TL_T.  In the case of the join, any
 |    bad attr records that have a member in the join of _B_T/TL_T will be identified
 |    during the NEW_MEMBERS module.
 |
 |    Procedure is split into 2 sections:
 |       For CAL PERIOD
 |          Only need to look for records where the
 |          CALENDAR_DISPLAY_CODE and DIMENSION_GROUP_DISPLAY_CODE are valid, since
 |          the New Members module performs validations on those columns already.
 |
 |       For Value Set Dim
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   26-MAR-04  Created
 |    Rob Flippo   14-SEP-04  Modify so that it excludes records
 |                            where the version is actually valid.
 |                            This allows the
 |                            Bad version cursor to find the bad version rows
 |                            and update
 |                            them appropriately;
 |                            Also modify so that don't join with the source
 |                            B_T and _TL_T
 |                            tables - since this procedure gets called after
 |                            NEW_MEMBER
 |                            is already complete, we don't have worry if the
 |                            new_members
 |                            have been processed or not
 |    Rob Flippo  27-OCT-04   Bug#3973837
 |                            FEM.C.DP3.4: DIMENSION LOADER ERRORS
 |                            ALL ATTRIBUTES IN ATTR_T TABLE
 |                            Fixed the select stmt to select rows as follows:
 |                            1)  the attribute is not required AND the member
 |                                does not exist in the official _B table OR
 |                            2)  the attribute is required AND the member does
 |                                not exist in the official _B table AND the
 |                                member does not exist in a join of the
 |                                interface _B_T/_TL_T tables
 |
 |   Rob Flippo   01-NOV-04   Modified so that members with invalid grp
 |                            or bad value_set continue to be processed
 |                            so that their attr records can get updated
 |                            with an invalid_member status
 |   Rob Flippo   15-MAR-05   Bug#4226011 add user_assign_allowed_flag not in ('N')
 |                            to all queries against the fem_dim_attributes_b table
 +===========================================================================*/

procedure build_bad_attr_select_stmt (p_dimension_varchar_label IN VARCHAR2
                                ,p_dimension_id IN NUMBER
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_source_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_bad_attr_select_stmt OUT NOCOPY VARCHAR2)
IS

      -- Value Set where conditions
      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_select_T1         VARCHAR2(1000);
      v_value_set_select_T2         VARCHAR2(1000);
      v_vs_where_M2               VARCHAR2(1000);  -- where condition for Specific Member='No'
      v_vs_table                  VARCHAR2(1000);

      -- Special conditions to handle CAL_PERIOD
      v_member_code                VARCHAR2(1000);
      v_calendar_id                VARCHAR2(100);
      v_calendar_table             VARCHAR2(100);
      v_calendar_where_cond        VARCHAR2(1000);
      v_member_dc_where_cond       VARCHAR2(1000);

      -- other conditions
      v_dim_label_where_cond       VARCHAR2(1000);

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
     (c_log_level_2,c_block||'.'||
      'build_bad_attr_select_stmt',
      'Begin Build_bad_attr_select_stmt');

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


   IF p_dimension_varchar_label = 'CAL_PERIOD' THEN

           x_bad_attr_select_stmt :=
           'SELECT B.rowid'||
           ',''INVALID_MEMBER'''||
           ' FROM '||p_source_attr_table||' B'||
           ', FEM_CALENDARS_VL C, FEM_DIMENSION_GRPS_B D'||
           ', FEM_DIM_ATTR_VERSIONS_B V'||
           ', FEM_DIM_ATTRIBUTES_B A'||
           ' WHERE B.calendar_display_code = C.calendar_display_code '||
           ' AND B.dimension_group_display_code = D.dimension_group_display_code'||
           ' AND B.STATUS'||p_exec_mode_clause||
           ' AND B.attribute_varchar_label = A.attribute_varchar_label'||
           ' AND A.dimension_id = '||p_dimension_id||
           ' AND B.version_display_code = V.version_display_code'||
           ' AND V.attribute_id = A.attribute_id'||
           ' AND LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
           'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
           'LPAD(to_char(C.calendar_id),5,''0'')||'||
           'LPAD(to_char(D.time_dimension_group_key),5,''0'') '||
           ' NOT IN (SELECT cal_period_id FROM fem_cal_periods_b) '||
           ' AND ((A.attribute_required_flag = ''N'')'||
           ' OR (A.attribute_required_flag = ''Y'''||
           ' AND NOT EXISTS (SELECT 0 FROM fem_cal_periods_b_t B2'||
           ' ,fem_cal_periods_tl_t TL2'||
           ' WHERE B2.cal_period_end_date = B.cal_period_end_date'||
           ' AND B2.cal_period_number = B.cal_period_number'||
           ' AND B2.calendar_display_code = B.calendar_display_code'||
           ' AND B2.dimension_group_display_code = B.dimension_group_display_code'||
           ' AND B2.cal_period_end_date = TL2.cal_period_end_date'||
           ' AND B2.calendar_display_code = TL2.calendar_display_code'||
           ' AND B2.dimension_group_display_code = TL2.dimension_group_display_code'||
           ' AND B2.cal_period_number = TL2.cal_period_number'||
           ' AND B2.STATUS'||p_exec_mode_clause||
           ' AND TL2.STATUS'||p_exec_mode_clause||')))'||
           ' AND   {{data_slice}} ';

/* RCF 9-14-2004  Removing this since we should always update in the _ATTR table
                  when the member doesn't exist in the _B table.  That's because this
                  update occurs after the NEW_MEMBER procedure is complete
           ' AND B.cal_period_number NOT IN (SELECT B1.cal_period_number '||
           ' FROM fem_cal_periods_b_t B1, fem_cal_periods_tl_t TL '||
           ' WHERE B1.calendar_display_code = B.calendar_display_code '||
           ' AND B1.dimension_group_display_code = B.dimension_group_display_code '||
           ' AND B1.cal_period_end_date = B.cal_period_end_date'||
           ' AND B1.calendar_display_code = TL.calendar_display_code'||
           ' AND B1.dimension_group_display_code = TL.dimension_group_display_code'||
           ' AND B1.cal_period_end_date = TL.cal_period_end_date'||
           ' AND B1.cal_period_number = TL.cal_period_number) '||

*/

   ELSIF p_value_set_required_flag = 'Y' THEN
           x_bad_attr_select_stmt :=
           'SELECT B.rowid'||
           ',''INVALID_MEMBER'''||
           ' FROM '||p_source_attr_table||' B'||
           ', FEM_DIM_ATTR_VERSIONS_B V'||
           ', FEM_DIM_ATTRIBUTES_B A'||
           ' WHERE B.STATUS'||p_exec_mode_clause||
           ' AND B.attribute_varchar_label = A.attribute_varchar_label'||
           ' AND A.dimension_id = '||p_dimension_id||
           ' AND nvl(A.user_assign_allowed_flag,''Y'') not in (''N'')'||
           ' AND B.version_display_code = V.version_display_code'||
           ' AND V.attribute_id = A.attribute_id'||
           ' AND NOT EXISTS (SELECT 0'||
           ' FROM '||p_target_b_table||' T'||
           ',fem_value_sets_b V'||
           ' WHERE T.value_set_id = V.value_set_id'||
           ' AND V.value_set_display_code = B.value_set_display_code'||
           ' AND T.'||p_member_dc_col||' = B.'||p_member_t_dc_col||')'||
           ' AND ((A.attribute_required_flag = ''N'')'||
           ' OR (A.attribute_required_flag = ''Y'''||
           ' AND NOT EXISTS (SELECT 0 FROM '||p_source_b_table||' B2'||
           ', '||p_source_tl_table||' TL2'||
           ' WHERE B2.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||
           ' AND B2.value_set_display_code = B.value_set_display_code'||
           ' AND B2.'||p_member_t_dc_col||' = TL2.'||p_member_t_dc_col||
           ' AND B2.value_set_display_code = TL2.value_set_display_code'||
           ' AND B2.STATUS'||p_exec_mode_clause||
           ' AND TL2.STATUS'||p_exec_mode_clause||')))'||
           ' AND   {{data_slice}} ';

/* RCF 9-14-2004  Removing this since we should always update in the _ATTR table
                  when the member doesn't exist in the _B table.  That's because this
                  update occurs after the NEW_MEMBER procedure is complete
           ' AND NOT EXISTS (SELECT 0'||
           ' FROM '||p_source_b_table||' B1'||
           ','||p_source_tl_table||' TL'||
           ' WHERE B1.value_set_display_code = B.value_set_display_code'||
           ' AND B1.value_set_display_code = TL.value_set_display_code'||
           ' AND B1.'||p_member_t_dc_col||' = TL.'||p_member_t_dc_col||
           ' AND B1.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||')'||

           */
   ELSE
           x_bad_attr_select_stmt :=
           'SELECT B.rowid'||
           ',''INVALID_MEMBER'''||
           ' FROM '||p_source_attr_table||' B'||
           ',FEM_DIM_ATTR_VERSIONS_B V'||
           ',FEM_DIM_ATTRIBUTES_B A'||
           ' WHERE B.STATUS'||p_exec_mode_clause||
           v_dim_label_where_cond||
           ' AND B.attribute_varchar_label = A.attribute_varchar_label'||
           ' AND A.dimension_id = '||p_dimension_id||
           ' AND nvl(A.user_assign_allowed_flag,''Y'') not in (''N'')'||
           ' AND B.version_display_code = V.version_display_code'||
           ' AND V.attribute_id = A.attribute_id'||
           ' AND NOT EXISTS (SELECT 0'||
           ' FROM '||p_target_b_table||' T'||
           ' WHERE T.'||p_member_dc_col||' = B.'||p_member_t_dc_col||')'||
           ' AND ((A.attribute_required_flag = ''N'')'||
           ' OR (A.attribute_required_flag = ''Y'''||
           ' AND NOT EXISTS (SELECT 0 FROM '||p_source_b_table||' B2'||
           ', '||p_source_tl_table||' TL2'||
           ' WHERE B2.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||
           ' AND B2.'||p_member_t_dc_col||' = TL2.'||p_member_t_dc_col||
           ' AND B2.STATUS'||p_exec_mode_clause||
           ' AND TL2.STATUS'||p_exec_mode_clause||')))'||
           ' AND   {{data_slice}} ';

/* RCF 9-14-2004  Removing this since we should always update in the _ATTR table
                  when the member doesn't exist in the _B table.  That's because this
                  update occurs after the NEW_MEMBER procedure is complete
           ' AND NOT EXISTS (SELECT 0'||
           ' FROM '||p_source_b_table||' B1'||
           ','||p_source_tl_table||' TL'||
           ' WHERE B1.'||p_member_t_dc_col||' = TL.'||p_member_t_dc_col||
           ' AND B1.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||')'||

*/
   END IF;

     FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_2,c_block||'.'||
       'build_bad_attr_select_stmt',
       'End Build_bad_attr_select_stmt');


END build_bad_attr_select_stmt;

/*===========================================================================+
 | PROCEDURE
 |              BUILD_SEQ_ENF_HIERCOUNT_STMT
 |
 | DESCRIPTION
 |     Procedure for building the dynamic SELECT statement for
 |     identifying if a member participates in a sequence enforced hierarchy
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   16-MAR-05  Created
 |
 +===========================================================================*/

procedure build_seq_enf_hiercount_stmt (p_value_set_required_flag IN VARCHAR2
                                 ,p_hier_table_name IN VARCHAR2
                                 ,x_select_stmt OUT NOCOPY VARCHAR2)
IS

BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_2,c_block||'.'||'build_seq_enf_hiercount_stmt',
       'Begin Build SQL statement to identify if member participates in sequence enf hier');

   IF p_value_set_required_flag = 'Y' THEN
      x_select_stmt := 'SELECT count(*)'||
                       ' FROM '||p_hier_table_name||' H'||
                       ',fem_object_definition_b D'||
                       ',fem_hierarchies O'||
                       ' WHERE H.hierarchy_obj_def_id = D.object_definition_id'||
                       ' AND D.object_id = O.hierarchy_obj_id'||
                       ' AND O.group_sequence_enforced_code '||
                       ' IN (''SEQUENCE_ENFORCED'',''SEQUENCE_ENFORCED_SKIP_LEVEL'')'||
                       ' AND to_char(child_id) = to_char(:b_member_id)'||
                       ' AND H.child_value_set_id = :b_value_set_id';
   ELSE
      x_select_stmt := 'SELECT count(*)'||
                       ' FROM '||p_hier_table_name||' H'||
                       ',fem_object_definition_b D'||
                       ',fem_hierarchies O'||
                       ' WHERE H.hierarchy_obj_def_id = D.object_definition_id'||
                       ' AND D.object_id = O.hierarchy_obj_id'||
                       ' AND O.group_sequence_enforced_code '||
                       ' IN (''SEQUENCE_ENFORCED'',''SEQUENCE_ENFORCED_SKIP_LEVEL'')'||
                       ' AND to_char(child_id) = to_char(:b_member_id)';

   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
      (c_log_level_2,c_block||'.'||'build_seq_enf_hiercount_stmt',
       'End Build SQL statement to identify if member participates in sequence enf hier');

END build_seq_enf_hiercount_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_DOES_ATTR_EXIST_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 identifying if an attribute row already exists in the _ATTR table
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   23-OCT-03  Created
 |    Rob Flippo   02-MAR-05  Bug#4170444 Modified to return value for the
 |                            READ_ONLY_FLAG from the ATTR table
 |    Rob Flippo   11-AUG-05  Bug#4547868 performance issue on query
 |                            - remove join to _B table
 |
 +===========================================================================*/

   procedure build_does_attr_exist_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_version_flag IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2)
   IS

      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_table                VARCHAR2(100);
      v_version_where_cond         VARCHAR2(1000);


   BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_does_attr_exist_stmt',
          'Begin Build SQL statement to identify if attribute assignment already exists');

      IF p_value_set_required_flag = 'Y' THEN
        v_value_set_where_cond := ' and A.value_set_id = :b_value_set_id';

        /*** commented out 8/11/2005
        ' AND A.value_set_id = V.value_set_id'||
                                  ' AND V.value_set_display_code = :b_value_set_dc'||
                                  ' AND A.value_set_id = B.value_set_id'; */

        v_value_set_table      := ',fem_value_sets_b V ';
      ELSE
        v_value_set_where_cond       := '';
        v_value_set_table            := '';
      END IF;

      IF p_version_flag = 'Y' THEN
         v_version_where_cond :=   ' AND A.version_id = :b_version_id';

      ELSE
         v_version_where_cond := '';
      END IF;

        x_attr_select_stmt :=
           'SELECT count(*), max(A.read_only_flag)'||
           ' FROM '||p_target_attr_table||' A'||
           ' WHERE A.attribute_id = :b_attribute_id'||
           v_version_where_cond||
           ' AND A.'||p_member_col||' = :b_member_id'||
           v_value_set_where_cond;

        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_does_attr_exist_stmt',
          'End');


   END build_does_attr_exist_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_DOES_MULTATTR_EXIST_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 identifying if an attribute row already exists in the _ATTR table
 |                 when the attribute is Multi-assignment
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   06-JUL-06  Created
 |
 +===========================================================================*/

   procedure build_does_multattr_exist_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_attr_value_column_name IN VARCHAR2
                                ,p_attr_assign_vs_id IN NUMBER
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2)
   IS

      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_table                VARCHAR2(100);
      v_version_where_cond         VARCHAR2(1000);
      v_assign_where_cond          VARCHAR2(4000);


   BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_does_multattr_exist_stmt',
          'Begin Build SQL statement to identify if attribute assignment already exists for multi-assign attributes');

      IF p_value_set_required_flag = 'Y' THEN
        v_value_set_where_cond := ' and A.value_set_id = :b_value_set_id';
        v_value_set_table      := ',fem_value_sets_b V ';
      ELSE
        v_value_set_where_cond       := '';
        v_value_set_table            := '';
      END IF;

      IF p_attr_value_column_name = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
         AND p_attr_assign_vs_id IS NOT NULL THEN

         v_assign_where_cond :=
           ' AND A.dim_attribute_numeric_member = :b_dim_attr_numeric_mbr'||
           ' AND A.dim_attribute_value_set_id = :b_dim_attr_vs';
      ELSIF p_attr_value_column_name = 'DIM_ATTRIBUTE_NUMERIC_MEMBER'
         AND p_attr_assign_vs_id IS NULL THEN
         v_assign_where_cond :=
           ' AND A.dim_attribute_numeric_member = :b_dim_attr_numeric_mbr';
      ELSE
         v_assign_where_cond :=
           ' AND A.dim_attribute_varchar_member = :b_dim_attr_varchar_mbr';

      END IF;

      v_version_where_cond :=   ' AND A.version_id = :b_version_id';

        x_attr_select_stmt :=
           'SELECT count(*)'||
           ' FROM '||p_target_attr_table||' A'||
           ' WHERE A.attribute_id = :b_attribute_id'||
           v_version_where_cond||
           ' AND A.'||p_member_col||' = :b_member_id'||
           v_value_set_where_cond||
           v_assign_where_cond;

        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_does_multattr_exist_stmt',
          'End');


   END build_does_multattr_exist_stmt;


/*===========================================================================+
 | PROCEDURE
 |              build_get_identical_assgn_stmt
 |
 | DESCRIPTION
 |                 Procedure for building the dynamic SELECT statement for
 |                 identifying if the attribute assignment from the interface
 |                 table is exactly the same as an existing attr assignment row
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   30-SEP-04  Created
 |
 +===========================================================================*/

   procedure build_get_identical_assgn_stmt (p_target_attr_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_date_format_mask IN VARCHAR2
                                ,x_attr_select_stmt OUT NOCOPY VARCHAR2)
   IS

      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_table                VARCHAR2(100);


   BEGIN
        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_get_identical_assgn_stmt',
          'Begin Build SQL statement to identify if existing attr assignment is identical to one from the interface table');

      IF p_value_set_required_flag = 'Y' THEN
        v_value_set_where_cond := ' AND A.value_set_id = V.value_set_id'||
                                  ' AND V.value_set_display_code = :b_value_set_dc'||
                                  ' AND A.value_set_id = B.value_set_id';
        v_value_set_table      := ',fem_value_sets_b V ';
      ELSE
        v_value_set_where_cond       := '';
        v_value_set_table            := '';
      END IF;


        x_attr_select_stmt :=
           'SELECT count(*)'||
           ' FROM '||p_target_attr_table||' A'||
           ','||p_target_b_table||' B'||
           v_value_set_table||
           ' WHERE A.attribute_id = :b_attribute_id'||
           ' AND A.version_id = :b_version_id'||
           ' AND A.'||p_member_col||' = B.'||p_member_col||
           v_value_set_where_cond||
           ' AND B.'||p_member_dc_col||' = :b_member_dc'||
           ' AND ((:b_dim_attr_numeric_member IS NULL '||
           ' AND A.dim_attribute_numeric_member IS NULL)'||
           ' OR (:b_dim_attr_numeric_member IS NOT NULL '||
           ' AND A.dim_attribute_numeric_member = :b_dim_attr_numeric_member))'||
           ' AND ((:b_dim_attr_vs_id IS NULL '||
           ' AND A.dim_attribute_value_set_id IS NULL)'||
           ' OR (:b_dim_attr_vs_id IS NOT NULL '||
           ' AND A.dim_attribute_value_set_id = :b_dim_attr_vs_id))'||
           ' AND ((:b_dim_attr_varchar_member IS NULL '||
           ' AND A.dim_attribute_varchar_member IS NULL)'||
           ' OR (:b_dim_attr_varchar_member IS NOT NULL '||
           ' AND A.dim_attribute_varchar_member = :b_dim_attr_varchar_member))'||
           ' AND ((:b_number_assign_value IS NULL '||
           ' AND A.number_assign_value IS NULL)'||
           ' OR (:b_number_assign_value IS NOT NULL '||
           ' AND A.number_assign_value = :b_number_assign_value))'||
           ' AND ((:b_varchar_assign_value IS NULL '||
           ' AND A.varchar_assign_value IS NULL)'||
           ' OR (:b_varchar_assign_value IS NOT NULL '||
           ' AND A.varchar_assign_value = :b_varchar_assign_value))'||
           ' AND ((:b_date_assign_value IS NULL '||
           ' AND A.date_assign_value IS NULL) '||
           ' OR (:b_date_assign_value IS NOT NULL '||
           ' AND A.date_assign_value = :b_date_assign_value))';


        FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_2,c_block||'.'||
          'build_get_identical_assgn_stmt',
          'End');


   END build_get_identical_assgn_stmt;


/*===========================================================================+
 | PROCEDURE
 |              VERIFY_ATTR_MEMBER
 |
 | DESCRIPTION
 |                 Procedure for checking if the Attribute assignment value
 |                 exists in the appropriate dimension member table
 |                 for DIM_ATTRIBUTE_VARCHAR_MEMBER and DIM_ATTRIBUTE_NUMERIC_MEMBER
 |                 attributes
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   27-OCT-03  Created
 |    Rob Flippo   03-MAR-05  Added new return status MISSING_ATTR_ASSIGN_VS to
 |                            identify when the user forgets to populate the
 |                            ATTR_ASSIGN_VS_DISPLAY_CODE column for attributes
 |                            that point to value set required dimensions
 |
 +===========================================================================*/

   procedure verify_attr_member (p_attribute_varchar_label IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_attr_member_dc IN VARCHAR2
                                ,p_attr_member_vs_dc IN VARCHAR2
                                ,x_attr_success OUT NOCOPY VARCHAR2
                                ,x_member OUT NOCOPY VARCHAR2)
   IS

      v_dimension_id                 NUMBER;
      v_attr_dimension_varchar_label VARCHAR2(30);
      v_get_dim_status             VARCHAR2(30);  -- ignore this in this procedure
      v_target_b_table             VARCHAR2(30);
      v_target_tl_table            VARCHAR2(30);
      v_target_attr_table          VARCHAR2(30);
      v_source_b_table             VARCHAR2(30);
      v_source_tl_table            VARCHAR2(30);
      v_source_attr_table          VARCHAR2(30);
      v_member_col                 VARCHAR2(30);
      v_member_dc_col    VARCHAR2(30);
      v_member_t_dc_col  VARCHAR2(30);
      v_member_name_col            VARCHAR2(30);
      v_member_t_name_col          VARCHAR2(30);
      v_member_description_col     VARCHAR2(30);
      v_value_set_required_flag    VARCHAR2(1);
      v_user_defined_flag          VARCHAR2(1);
      v_hier_table_name            VARCHAR2(30);
      v_simple_dimension_flag      VARCHAR2(1);
      v_shared_dimension_flag      VARCHAR2(1);
      v_hier_dimension_flag        VARCHAR2(1);
      v_member_id_method_code      VARCHAR2(30);
      v_table_handler_name         VARCHAR2(30);
      v_err_code  NUMBER        := 0;
      v_err_msg   VARCHAR2(255);
      v_composite_dimension_flag   VARCHAR2(1); --
      v_structure_id NUMBER; --

      x_member_exists_stmt         VARCHAR2(4000);


   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'verify_attr_member',
        'Begin identify if attribute assignment member is valid');

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'verify_attr_member.p_attr_member_vs_dc',
        p_attr_member_vs_dc);


      SELECT B2.dimension_varchar_label
      INTO v_attr_dimension_varchar_label
      FROM fem_dimensions_b B1, fem_dim_attributes_b A1, fem_dimensions_b B2
      WHERE B1.dimension_id = A1.dimension_id
      AND A1.attribute_varchar_label = p_attribute_varchar_label
      AND B1.dimension_varchar_label = p_dimension_varchar_label
      AND B2.dimension_id = A1.attribute_dimension_id;


      --dbms_output.put_line('attr label = '||v_attr_dimension_varchar_label);

      get_dimension_info (v_attr_dimension_varchar_label
                         ,v_dimension_id
                         ,v_target_b_table
                         ,v_target_tl_table
                         ,v_target_attr_table
                         ,v_source_b_table
                         ,v_source_tl_table
                         ,v_source_attr_table
                         ,v_member_col
                         ,v_member_dc_col
                         ,v_member_t_dc_col
                         ,v_member_name_col
                         ,v_member_t_name_col
                         ,v_member_description_col
                         ,v_value_set_required_flag
                         ,v_user_defined_flag
                         ,v_simple_dimension_flag
                         ,v_shared_dimension_flag
                         ,v_hier_table_name
                         ,v_hier_dimension_flag
                         ,v_member_id_method_code
                         ,v_table_handler_name
                         ,v_composite_dimension_flag --
                         ,v_structure_id); --

      build_member_exists_stmt (v_target_b_table
                               ,v_member_col
                               ,v_member_dc_col
                               ,v_value_set_required_flag
                               ,x_member_exists_stmt);
      --dbms_output.put_line(substr(x_member_exists_stmt, 1,200));
      --dbms_output.put_line(substr(x_member_exists_stmt, 201,200));

      -- add check to see if the attr_vs_display_code is populated for an
      -- attribute that points to a value set required dimension.  If it is
      -- null, then we should skip the check altogether and report
      -- a special status to the calling procedure
      IF v_value_set_required_flag = 'Y' AND p_attr_member_vs_dc is not null THEN
         EXECUTE IMMEDIATE x_member_exists_stmt
            INTO x_member
            USING p_attr_member_dc
                 ,p_attr_member_vs_dc;
      ELSIF v_value_set_required_flag = 'N' THEN
         EXECUTE IMMEDIATE x_member_exists_stmt
            INTO x_member
            USING p_attr_member_dc;
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'verify_attr_member.after the member exists query',
        null);


      IF x_member IS NOT NULL THEN
         x_attr_success := 'Y';
      ELSIF v_value_set_required_flag = 'Y' AND p_attr_member_vs_dc is null THEN
         x_attr_success := 'MISSING_ATTR_ASSIGN_VS';
      ELSE
         x_attr_success := 'N';
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'x_attr_sucess',
        x_attr_success);
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'verify_attr_member',
        'End');

   EXCEPTION
      WHEN no_data_found THEN
        x_attr_success := 'N';

   END verify_attr_member;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_MEMBER_EXISTS_STMT
 |
 | DESCRIPTION
 |                 Procedure for building the SQL statement that checks
 |                 if a member exists in a dimension table
 |
 | SCOPE - PRIVATE
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   27-OCT-03  Created
 |
 +===========================================================================*/

   procedure build_member_exists_stmt (p_member_table IN VARCHAR2
                                ,p_member_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,x_member_exists_stmt OUT NOCOPY VARCHAR2)


   IS

      v_value_set_where_cond       VARCHAR2(1000);
      v_value_set_table            VARCHAR2(1000);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_member_exists_stmt',
        'Begin Build SQL statement to identify if a dimension member exists in FEM');

      IF (p_value_set_required_flag = 'Y') THEN
        v_value_set_where_cond := ' AND V1.value_set_id = B1.value_set_id '||
                                  ' AND V1.value_set_display_code = :b_value_set_display_code';
        v_value_set_table      := ', FEM_VALUE_SETS_B V1';

      ELSE
        v_value_set_where_cond := '';
        v_value_set_table      := '';
      END IF;


        x_member_exists_stmt :=
           'SELECT '||p_member_col||
           ' FROM '||p_member_table||' B1 '||v_value_set_table||
           ' WHERE to_char('||p_member_dc_col||') = to_char(:b_member_dc)'||
           v_value_set_where_cond;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'build_member_exists_stmt',
        x_member_exists_stmt);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_member_exists_stmt',
        'End');

   END build_member_exists_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_BAD_NEW_MBRS_STMT
 |
 | DESCRIPTION
 |                 Retrieves any members from the _B_T table that do not exist
 |                 in FEM but also do not have a corresponding _TL_T name/desc record.
 |                 Such members are considered invalid and cannot be loaded.
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   28-OCT-03  Created
 |    Rob Flippo   28-SEP-04  Bug#3906218 Ability undelete members
 |                            Modified the select stmt so that it excludes
 |                            members that already exist in the target table
 |
 +===========================================================================*/

   procedure build_bad_new_mbrs_stmt (p_load_type IN VARCHAR2
                                ,p_dimension_varchar_label IN VARCHAR2
                                ,p_source_b_table IN VARCHAR2
                                ,p_source_tl_table IN VARCHAR2
                                ,p_target_b_table IN VARCHAR2
                                ,p_member_t_dc_col IN VARCHAR2
                                ,p_member_dc_col IN VARCHAR2
                                ,p_value_set_required_flag IN VARCHAR2
                                ,p_shared_dimension_flag IN VARCHAR2
                                ,p_exec_mode_clause IN VARCHAR2
                                ,x_bad_member_select_stmt OUT NOCOPY VARCHAR2)
      IS

      v_member_code                VARCHAR2(1000); -- used only in the CAL_PERIOD select

 BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_bad_new_members_stmt',
        'Begin Build SQL statement to retrieve invalid new members from the source _B_T table');

      --dbms_output.put_line('Building the Bad New Members Select');

      IF (p_load_type = 'DIMENSION_MEMBER') AND
         (p_dimension_varchar_label = 'CAL_PERIOD') THEN

      -- Setting the special conditions for CAL_PERIOD
         v_member_code :=
               'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
               'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
               'LPAD(to_char(C.calendar_id),5,''0'')||'||
               'LPAD(to_char(D.time_dimension_group_key),5,''0'')';


            x_bad_member_select_stmt :=
            'SELECT B.rowid'||
            ',''MISSING_NAME'''||
            ' FROM '||p_source_b_table||' B'||
            ', fem_calendars_b C, fem_dimension_grps_b D'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND B.calendar_display_code = C.calendar_display_code'||
            ' AND B.dimension_group_display_code = D.dimension_group_display_code'||

            ' AND   {{data_slice}} '||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_source_tl_table||' S1'||
            ' WHERE S1.CALENDAR_DISPLAY_CODE = B.CALENDAR_DISPLAY_CODE'||
            ' AND S1.DIMENSION_GROUP_DISPLAY_CODE = B.DIMENSION_GROUP_DISPLAY_CODE'||
            ' AND S1.CAL_PERIOD_END_DATE = B.CAL_PERIOD_END_DATE'||
            ' AND S1.CAL_PERIOD_NUMBER = B.CAL_PERIOD_NUMBER'||
            ' AND S1.STATUS'||p_exec_mode_clause||')'||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_target_b_table||' G'||
            ' WHERE to_char(G.cal_period_id) = '||v_member_code||')';


      ELSIF (p_load_type = 'DIMENSION_MEMBER')
            AND (p_value_set_required_flag = 'Y') THEN
            x_bad_member_select_stmt :=
            'SELECT B.rowid'||
            ',''MISSING_NAME'''||
            ' FROM '||p_source_b_table||' B'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} '||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_source_tl_table||' S1'||
            ' WHERE S1.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||
            ' AND S1.value_set_display_code = B.value_set_display_code'||
            ' AND S1.status'||p_exec_mode_clause||')'||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_target_b_table||' G'||
            ', fem_value_sets_b V'||
            ' WHERE to_char(G.'||p_member_dc_col||') = B.'||p_member_t_dc_col||
            ' AND G.value_set_id = V.value_set_id'||
            ' AND V.value_set_display_code = B.value_set_display_code)';
      ELSIF (p_load_type = 'DIMENSION_MEMBER')
            AND (p_value_set_required_flag = 'N')
            AND (p_shared_dimension_flag = 'N') THEN
            x_bad_member_select_stmt :=
            'SELECT B.rowid'||
            ',''MISSING_NAME'''||
            ' FROM '||p_source_b_table||' B'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} '||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_source_tl_table||' S1'||
            ' WHERE S1.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||
            ' AND S1.status'||p_exec_mode_clause||')'||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_target_b_table||' G'||
            ' WHERE to_char(G.'||p_member_dc_col||') = B.'||p_member_t_dc_col||')';
      ELSE
            x_bad_member_select_stmt :=
            'SELECT B.rowid'||
            ',''MISSING_NAME'''||
            ' FROM '||p_source_b_table||' B'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} '||
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_source_tl_table||' S1'||
            ' WHERE S1.'||p_member_t_dc_col||' = B.'||p_member_t_dc_col||
            ' AND S1.dimension_varchar_label = B.dimension_varchar_label'||
            ' AND S1.status'||p_exec_mode_clause||')'||
            ' AND NOT EXISTS (SELECT 0 FROM '||
            p_target_b_table||' G'||
            ' WHERE to_char(G.'||p_member_dc_col||') = B.'||p_member_t_dc_col||')';


      END IF;


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_bad_new_members_stmt',
        'End');

      END build_bad_new_mbrs_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_BAD_ATTR_VERS_STMT
 |
 | DESCRIPTION
 |                 Retrieves any attribute assignment records from the _ATTR_T
 |                 table that have version_display_code values that do not exist
 |                 in FEM.
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   10-MAR-04  Created
 |    Rob Flippo   12-NOV-04  Added where condition on aw_snapshot_flag = N
 |                            to prevent users from trying update snapshot
 |                            versions
 |    Rob Flippo   31-JAN-05  Added where condition on dimension_varchar_label
 |                            when the dimension uses the shared ATTR_T table
 |    Rob Flippo   15-MAR-05  Bug#4226011 add where user_assign_allowed_flag
 |                            not in 'N' to the select stmt
 +===========================================================================*/

   procedure build_bad_attr_vers_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_attr_table IN VARCHAR2
                                      ,p_shared_dimension_flag IN VARCHAR2
                                      ,p_exec_mode_clause IN VARCHAR2
                                      ,x_bad_attr_vers_select_stmt OUT NOCOPY VARCHAR2)
 IS
    v_dim_label_where_cond VARCHAR2(1000);

 BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_bad_attr_vers_stmt',
        'Begin Build SQL statement to retrieve invalid attribute assignments from the source _ATTR_T table');

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


         x_bad_attr_vers_select_stmt :=
            'SELECT B.rowid'||
            ',''INVALID_VERSION'''||
            ' FROM '||p_source_attr_table||' B'||
            ' WHERE B.status'||p_exec_mode_clause||
            v_dim_label_where_cond||
            ' AND NOT EXISTS (SELECT 0 FROM fem_dim_attr_versions_b V'||
            ' ,fem_dim_attributes_b D'||
            ' WHERE V.version_display_code = B.version_display_code'||
            ' AND V.attribute_id = D.attribute_id'||
            ' AND V.aw_snapshot_flag = ''N'''||
            ' AND D.attribute_varchar_label = B.attribute_varchar_label)'||
            ' AND EXISTS (SELECT 0 FROM fem_dim_attributes_b A'||
            ' WHERE A.attribute_varchar_label = B.attribute_varchar_label'||
            ' AND nvl(A.user_assign_allowed_flag,''Y'') not in (''N''))'||
            ' AND   {{data_slice}} ';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_bad_attr_vers_stmt',
        'End');

      END build_bad_attr_vers_stmt;


/*===========================================================================+
 | PROCEDURE
 |              GET_ATTR_VERSION
 |
 | DESCRIPTION
 |                 Verifies that a version name for a particular attribute
 |                 exists for the given Language and returns the VERSION_ID
 |
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   28-OCT-03  Created
 |
 +===========================================================================*/


   procedure get_attr_version (p_dimension_varchar_label IN VARCHAR2
                              ,p_attribute_varchar_label IN VARCHAR2
                              ,p_version_display_code IN VARCHAR2
                              ,x_version_id OUT NOCOPY NUMBER)
   IS


   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'get_attr_version',
        'Begin verify that a version display_code exists for an attribute');

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'get_attr_version.attribute_varchar_label',
        p_attribute_varchar_label);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_1,c_block||'.'||
        'get_attr_version.version_display_code',
        p_version_display_code);

      SELECT B.version_id
      INTO x_version_id
      FROM fem_dim_attr_versions_b B, fem_dim_attributes_b A, fem_dimensions_b D
      WHERE B.version_display_code = p_version_display_code
      AND B.attribute_id = A.attribute_id
      AND A.attribute_varchar_label = p_attribute_varchar_label
      AND D.dimension_varchar_label = p_dimension_varchar_label
      AND D.dimension_id = A.dimension_id;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'get_attr_version',
        'End');

   EXCEPTION
      WHEN no_data_found THEN
         x_version_id := '';

   END get_attr_version;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_INSERT_MEMBER_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic statement that calls the
 |                 INSERT_ROW procedure of the table handler
 |
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   28-OCT-03  Created
 |    Rob Flippo   04-AUG-06  Bug5060746 Change literals to bind variables
 |                            whereever possible
 |
 +===========================================================================*/


   procedure build_insert_member_stmt (p_table_handler_name IN VARCHAR2
                                      ,p_dimension_id IN NUMBER
                                      ,p_value_set_required_flag IN VARCHAR2
                                      ,p_hier_dimension_flag IN VARCHAR2
                                      ,p_simple_dimension_flag IN VARCHAR2
                                      ,p_member_id_method_code IN VARCHAR2
                                      ,p_member_col IN VARCHAR2
                                      ,p_member_dc_col IN VARCHAR
                                      ,p_member_name_col IN VARCHAR2
                                      ,x_insert_member_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_insert_member_stmt',
        'Begin SQL statement to insert new dimension members');

      IF p_table_handler_name = 'FEM_CAL_PERIODS_PKG' THEN
         x_insert_member_stmt :=
                   'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER;'||
                   'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                   '(x_rowid => v_row_id '||
                  ',x_'||p_member_col||' => fem_dimension_util_pkg.generate_member_id('||
                  ':b_end_date,:b_period_number,:b_calendar_id, :b_dimension_group_id,v_err_code,x_num_msg) '||
                  ',x_dimension_group_id => :b_dimension_group_id '||
                  ',x_calendar_id => :b_calendar_id '||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';
      ELSIF (p_table_handler_name = 'FEM_DIMENSION_GRPS_PKG') THEN
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id '||
                  ',x_'||p_member_dc_col||' => :b_member_dc '||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null '||
                  ',x_time_dimension_group_key => :b_time_dimension_group_key '||
                  ',x_dimension_group_seq => :b_dimension_group_seq'||
                  ',x_time_group_type_code => :b_time_group_type_code'||
                  ',x_dimension_group_id => :b_dimension_group_id'||
                  ',x_dimension_id => :b_dimension_id ); END;';

      ELSIF (p_value_set_required_flag = 'Y'
             AND p_hier_dimension_flag = 'Y'
             AND p_member_id_method_code = 'FUNCTION') THEN
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER; '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id'||
                   ',x_'||p_member_col||' =>'||
                   'fem_dimension_util_pkg.generate_member_id('||p_dimension_id||',v_err_code,x_num_msg)'||
                  ',x_value_set_id => :b_value_set_id '||
                  ',x_dimension_group_id =>:b_dimension_group_id '||
                  ',x_'||p_member_dc_col||' => :b_member_dc'||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';

      ELSIF (p_value_set_required_flag = 'Y'
             AND p_hier_dimension_flag = 'N'
             AND p_member_id_method_code = 'FUNCTION') THEN
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER; '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id'||
                   ',x_'||p_member_col||' =>'||
                   'fem_dimension_util_pkg.generate_member_id('||p_dimension_id||',v_err_code,x_num_msg)'||
                  ',x_value_set_id => :b_value_set_id '||
                  ',x_'||p_member_dc_col||' => :b_member_dc'||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';
      ELSIF (p_value_set_required_flag = 'N'
             AND p_hier_dimension_flag = 'Y'
             AND p_member_id_method_code = 'FUNCTION') THEN
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER; '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id'||
                   ',x_'||p_member_col||' =>'||
                   'fem_dimension_util_pkg.generate_member_id('||p_dimension_id||',v_err_code,x_num_msg)'||
                  ',x_dimension_group_id =>:b_dimension_group_id '||
                  ',x_'||p_member_dc_col||' => :b_member_dc'||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';
      ELSIF (p_value_set_required_flag = 'N'
             AND p_hier_dimension_flag = 'N'
             AND p_member_id_method_code = 'FUNCTION') THEN
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); v_err_code NUMBER; x_num_msg NUMBER; '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id'||
                   ',x_'||p_member_col||' =>'||
                   'fem_dimension_util_pkg.generate_member_id('||p_dimension_id||',v_err_code,x_num_msg)'||
                  ',x_'||p_member_dc_col||' => :b_member_dc'||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';

      ELSE
         x_insert_member_stmt :=
                  'DECLARE v_row_id VARCHAR2(1000); '||
                  'BEGIN '||p_table_handler_name||'.INSERT_ROW'||
                  '(x_rowid => v_row_id '||
                  ',x_'||p_member_col||' => :b_member_dc '||
                  ',x_enabled_flag => ''Y'' '||
                  ',x_personal_flag => ''N'' '||
                  ',x_read_only_flag => ''N'' '||
                  ',x_object_version_number => '||c_object_version_number||
                  ',x_'||p_member_name_col||' => :b_member_name'||
                  ',x_description => :b_member_desc '||
                  ',x_creation_date => sysdate '||
                  ',x_created_by => :b_apps_user_id'||
                  ',x_last_update_date => sysdate '||
                  ',x_last_updated_by => :b_apps_user_id2'||
                  ',x_last_update_login => null ); END;';

      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_insert_member_stmt',
        'End');

   END build_insert_member_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_INSERT_ATTR_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic insert statement
 |                 for inserting into the ATTR table
 |
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   28-OCT-03  Created
 |    Rob Flippo   04-AUG-06  Bug5060746 Change literals to bind variables
 |                            whereever possible
 |
 +===========================================================================*/


   procedure build_insert_attr_stmt (p_target_attr_table IN VARCHAR2
                                    ,p_target_b_table IN VARCHAR2
                                    ,p_member_col IN VARCHAR2
                                    ,p_member_dc_col IN VARCHAR2
                                    ,p_value_set_required_flag IN VARCHAR2
                                    ,x_insert_attr_stmt OUT NOCOPY VARCHAR2)

   IS

      v_value_set_parm       VARCHAR2(100);
      v_value_set_column     VARCHAR2(30);
      v_value_set_select     VARCHAR2(100);
      v_value_set_where_cond VARCHAR2(1000);
      v_value_set_table      VARCHAR2(100);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_insert_attr_stmt',
        'Begin SQL statement to insert new attribute assignments');

      IF p_value_set_required_flag = 'Y' THEN
         v_value_set_parm := ', :b_value_set_id';
         v_value_set_column := ', value_set_id';
         v_value_set_select := ', V1.value_set_id';
         v_value_set_where_cond := ' AND B1.value_set_id = V1.value_set_id '||
                                   ' AND V1.value_set_display_code = :b_value_set_display_code';
         v_value_set_table := ', FEM_VALUE_SETS_B V1';
      ELSE
         v_value_set_parm := '';
         v_value_set_column := '';
         v_value_set_select := '';
         v_value_set_where_cond := '';
         v_value_set_table := '';
      END IF;


      x_insert_attr_stmt := 'INSERT INTO '||p_target_attr_table||' ('||
                            'attribute_id'||
                            ',version_id'||
                            ','||p_member_col||
                            v_value_set_column||
                            ', dim_attribute_numeric_member'||
                            ', dim_attribute_value_set_id'||
                            ', dim_attribute_varchar_member'||
                            ', number_assign_value'||
                            ', varchar_assign_value'||
                            ', date_assign_value'||
                            ', creation_date'||
                            ', created_by'||
                            ', last_updated_by'||
                            ', last_update_date'||
                            ', last_update_login'||

                            ', object_version_number'||
                            ', aw_snapshot_flag)'||
                            ' SELECT'||
                            ' :b_attribute_id '||
                            ', :b_version_id '||
                            ','||p_member_col||
                            v_value_set_select||
                            ', :b_dim_attribute_numeric_member'||
                            ', :b_attr_assign_vs_id'||
                            ', :b_dim_attribute_varchar_member'||
                            ', :b_number_assign_value'||
                            ', :b_varchar_assign_value'||
                            ', :b_date_assign_value'||
                            ', sysdate'||
                            ',:b_apps_user_id'||
                            ',:b_apps_user_id2'||
                            ', sysdate'||
                            ', null'||
                            ', 1'||
                            ', ''N'''||
                            ' FROM '||p_target_b_table||' B1 '||
                            v_value_set_table||
                            ' WHERE B1.'||p_member_dc_col||' = :b_member_dc'||
                            v_value_set_where_cond||
                            ' AND :b_status = ''LOAD''';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_insert_attr_stmt',
        'End');

   END build_insert_attr_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_STATUS_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic update statement
 |                 for setting the status in the _T table for any records
 |                 not loaded.
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   04-NOV-03  Created
 |
 +===========================================================================*/

   procedure build_status_update_stmt (p_source_table IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_status_update_stmt',
        'Begin SQL statement to update the status in the source interface table');


      x_update_status_stmt := 'UPDATE '||p_source_table||
                              ' SET status = :b_t_a_status '||
                              ' WHERE rowid = :b_rowid'||
                              ' AND   :b_t_a_status <> ''LOAD''';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_status_update_stmt',
        'End');

   END build_status_update_stmt;

/*===========================================================================+
 | PROCEDURE
 |              BUILD_CALP_STATUS_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic update statement
 |                 for setting the status in the various CAL_PERIOD
 |                 _T table for any records identified in the Interim table
 |                 as having an error
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   05-JAN-05  Created
 |
 +===========================================================================*/

   procedure build_calp_status_update_stmt (p_operation_mode IN VARCHAR2
                                           ,p_source_table IN VARCHAR2
                                           ,x_update_status_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_calp_status_update_stmt',
        'Begin SQL statement to update the status in the interface table based on bad records from the CALP Interim table');

      IF p_operation_mode = 'ATTRIBUTE_LABEL' THEN

         x_update_status_stmt := 'UPDATE '||p_source_table||
                                 ' SET status = :b_t_a_status '||
                                 ' WHERE cal_period_number = :b_cal_period_number'||
                                 ' AND cal_period_end_date = :b_cal_period_end_date'||
                                 ' AND calendar_display_code = :b_calendar_dc'||
                                 ' AND dimension_group_display_code = :b_dimension_group_dc'||
                                 ' AND :b_overlap_flag = ''Y'''||
                                 ' AND attribute_varchar_label = ''CAL_PERIOD_START_DATE''';
      ELSE
         x_update_status_stmt := 'UPDATE '||p_source_table||
                                 ' SET status = :b_t_a_status '||
                                 ' WHERE cal_period_number = :b_cal_period_number'||
                                 ' AND cal_period_end_date = :b_cal_period_end_date'||
                                 ' AND calendar_display_code = :b_calendar_dc'||
                                 ' AND dimension_group_display_code = :b_dimension_group_dc'||
                                 ' AND   :b_overlap_flag = ''Y''';

      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_calp_status_update_stmt',
        'End');

   END build_calp_status_update_stmt;
/*===========================================================================+
 | PROCEDURE
 |              BUILD_CALP_DELETE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic delete statement
 |                 for setting CAL_PERIOD members from the INTERIM table
 |                 that were successfully moved into FEM
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   25-JAN-05  Created
 |    Rob Flippo   15-MAR-07  Bug#5900463 - TL rows for other languages
 |                            getting deleted when new members are being
 |                            loaded
 |
 +===========================================================================*/

   procedure build_calp_delete_stmt (p_source_table IN VARCHAR2
                                    ,p_operation_mode IN VARCHAR2
                                    ,x_calp_delete_stmt OUT NOCOPY VARCHAR2)

   IS

      v_attr_where_cond VARCHAR2(4000);
      v_tl_where_cond VARCHAR2(4000);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_calp_delete_stmt',
        'Begin SQL statement to delete rows from the CAL_PERIOD interface tables');
      IF p_source_table = 'FEM_CAL_PERIODS_ATTR_T' THEN
         v_tl_where_cond := null;
         IF p_operation_mode = 'NEW_MEMBERS' THEN
            v_attr_where_cond := ' AND attribute_varchar_label IN '||
                                 ' (SELECT attribute_varchar_label'||
                                 '  FROM fem_dim_attributes_b'||
                                 '  WHERE dimension_id=1'||
                                 '  AND attribute_required_flag = ''Y'')';
         ELSE
            v_attr_where_cond := ' AND attribute_varchar_label IN '||
                                 ' (SELECT attribute_varchar_label'||
                                 '  FROM fem_dim_attributes_b A, fem_calp_attr_interim_t I'||
                                 '  WHERE A.dimension_id=1'||
                                 '  AND A.attribute_id = I.attribute_id'||
                                 '  AND I.cal_period_id = :cal_period_id'||
                                 '  AND overlap_flag = ''N'')';

         END IF;
      ELSIF p_source_table = 'FEM_CAL_PERIODS_TL_T' THEN
         v_attr_where_cond := null;
         v_tl_where_cond := ' AND language = userenv(''LANG'')';
      ELSE
         v_attr_where_cond := null;
         v_tl_where_cond := null;
      END IF;



         x_calp_delete_stmt := 'DELETE FROM '||p_source_table||
                               ' WHERE cal_period_number = :b_cal_period_number'||
                               ' AND cal_period_end_date = :b_cal_period_end_date'||
                               ' AND calendar_display_code = :b_calendar_dc'||
                               ' AND dimension_group_display_code = :b_dimension_group_dc'||
                               v_attr_where_cond||v_tl_where_cond;


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_calp_delete_stmt',
        'End');

   END build_calp_delete_stmt;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_DEP_STATUS_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic update statement
 |                 for setting the status in the depended _T tables (_ATTR and _TL_T)
 |                 for records with the same member identifier as records
 |                 that were identified in the _B_T table as having a bad Dimension Group,
 |                 Bad Value Set, or Missing Name
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |    We only want to update dependent attribute records where the status='LOAD'
 |    And the member failed for some other reason.  This is just so that all attr
 |    records for failed members have some sort of error status, thus enabling
 |    the records to be all reprocessed with an Error Reprocessing run
 | MODIFICATION HISTORY
 |    Rob Flippo   29-MAR-04  Created
 |    Rob Flippo   17-SEP-04  This procedure is obsolete and is no longer called
 |
 +===========================================================================*/

   procedure build_dep_status_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_table IN VARCHAR2
                                      ,p_member_t_dc_col IN VARCHAR2
                                      ,p_value_set_required_flag IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_dep_status_update_stmt',
        'Begin');

   IF (p_dimension_varchar_label = 'CAL_PERIOD') THEN

      x_update_status_stmt := 'UPDATE '||p_source_table||
                              ' SET status = ''INVALID_MEMBER'' '||
                              ' WHERE calendar_display_code = :b_calendar_display_code'||
                              ' AND dimension_group_display_code = :b_dimension_group_display_code'||
                              ' AND cal_period_end_date = :b_cal_period_end_date'||
                              ' AND cal_period_number = :b_cal_period_number'||
                              ' AND   :b_t_a_status <> ''LOAD'''||
                              ' AND status IN (''LOAD'')';

   ELSIF (p_value_set_required_flag = 'Y') THEN
      x_update_status_stmt := 'UPDATE '||p_source_table||
                              ' SET status = ''INVALID_MEMBER'' '||
                              ' WHERE '||p_member_t_dc_col||' = :b_member_dc'||
                              ' AND value_set_display_code = :b_value_set_display_code'||
                              ' AND   :b_t_a_status <> ''LOAD'''||
                              ' AND status IN (''LOAD'')';
   END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_dep_status_update_stmt',
        'End');

   END build_dep_status_update_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_ATTRLAB_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic update statement
 |                 for setting the status in the ATTR_T tables
 |                 for records where the ATTRIBUTE_VARCHAR_LABEL does not exist;
 |                 such records would not otherwise be updated
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 | MODIFICATION HISTORY
 |    Rob Flippo   14-SEP-04  Created
 |
 +===========================================================================*/

   procedure build_attrlab_update_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_attr_table IN VARCHAR2
                                      ,p_shared_dimension_flag IN VARCHAR2
                                      ,p_exec_mode_clause IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2)

   IS

      v_dim_label_where_cond VARCHAR2(1000);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attrlab_update_stmt',
        'Begin');

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


      x_update_status_stmt := 'UPDATE '||p_source_attr_table||' B'||
                              ' SET status = ''INVALID_ATTRIBUTE_LABEL'' '||
                              ' WHERE attribute_varchar_label NOT IN (SELECT '||
                              ' attribute_varchar_label FROM fem_dim_attributes_b A'||
                              ' ,fem_dimensions_b D '||
                              ' WHERE D.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
                              ' AND D.dimension_id = A.dimension_id)'||
                              ' AND B.status '||p_exec_mode_clause||
                              v_dim_label_where_cond||
                              ' AND   {{data_slice}} ';


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attrlab_update_stmt',
        'End');

   END build_attrlab_update_stmt;

/*===========================================================================+
 | PROCEDURE
 |              BUILD_NOT_USER_LABEL_UPD_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic update statement
 |                 for setting the status in the ATTR_T tables
 |                 for records where the ATTRIBUTE_VARCHAR_LABEL is
 |                 user_assign_allowed_flag = 'N';
 |                 such records would not otherwise be updated
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 | MODIFICATION HISTORY
 |    Rob Flippo   15-MAR-05  Created
 |
 +===========================================================================*/

   procedure build_not_user_label_upd_stmt (p_dimension_varchar_label IN VARCHAR2
                                      ,p_source_attr_table IN VARCHAR2
                                      ,p_shared_dimension_flag IN VARCHAR2
                                      ,p_exec_mode_clause IN VARCHAR2
                                      ,x_update_status_stmt OUT NOCOPY VARCHAR2)

   IS

      v_dim_label_where_cond VARCHAR2(1000);

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attrlab_update_stmt',
        'Begin');

      IF p_shared_dimension_flag = 'Y' THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond := '';
      END IF;


      x_update_status_stmt := 'UPDATE '||p_source_attr_table||' B'||
                              ' SET status = ''ATTR_LABEL_NOT_USER_ASSIGN'' '||
                              ' WHERE attribute_varchar_label IN (SELECT '||
                              ' attribute_varchar_label FROM fem_dim_attributes_b A'||
                              ' ,fem_dimensions_b D '||
                              ' WHERE D.dimension_varchar_label = '''||p_dimension_varchar_label||''''||
                              ' AND nvl(A.user_assign_allowed_flag,''Y'') = ''N'''||
                              ' AND D.dimension_id = A.dimension_id)'||
                              ' AND B.status '||p_exec_mode_clause||
                              v_dim_label_where_cond||
                              ' AND   {{data_slice}} ';


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attrlab_update_stmt',
        'End');

   END build_not_user_label_upd_stmt;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_DELETE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic delete statement
 |                 for removing loaded records from the _ATTR_T and _TL_T tables
 |
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |   Rob Flippo   04-NOV-03  Created
 |   Rob Flippo   05-JAN-05  Modified to include use_interim_table_flag
 +===========================================================================*/

   procedure build_delete_stmt (p_source_table IN VARCHAR2
                               ,x_delete_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_delete_stmt',
        'Begin');

      x_delete_stmt := 'DELETE FROM '||p_source_table||
                       ' WHERE rowid = :b_rowid'||
                       ' AND   :b_t_a_status = ''LOAD'''||
                       ' AND :b_use_interim_table_flag = ''N''';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_delete_stmt',
        'End');

   END build_delete_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_SPECIAL_DELETE_STMT
 |
 | DESCRIPTION
 |                 Procedure that constructs the dynamic delete statement
 |                 for removing records from the _ATTR_T that successfully updated
 |
 |
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   04-NOV-03  Created
 |
 +===========================================================================*/

   procedure build_special_delete_stmt (p_source_table IN VARCHAR2
                               ,x_delete_stmt OUT NOCOPY VARCHAR2)

   IS

   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_special_delete_stmt',
        'Begin');

      x_delete_stmt := 'DELETE FROM '||p_source_table||
                       ' WHERE rowid = :b_rowid'||
                       ' AND :b_allow_mult_assign_flag = ''N'''||
                       ' AND :b_attr_exists_count > 0'||
                       ' AND :b_status = ''LOAD'''||
                       ' AND :b_use_interim_table_flag = ''N''';


      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_special_delete_stmt',
        'End');

   END build_special_delete_stmt;



/*===========================================================================+
 | PROCEDURE
 |              build_remain_mbr_select_stmt
 |
 | DESCRIPTION
 |                 Builds the dynamic SELECT statement for retrieving
 |                 the remaining members from the _B_T interface table.
 |                 When this SELECT is run, only the only records remaining
 |                 in the _B_T table with "LOAD" status are those for Value Set Required
 |                 dimensions that already exist in FEM.
 |                 Note that this SELECT stmt is not run for CAL_PERIOD and Simple dimensions
 |                 since the Dimension Group for members of those dimensions either
 |                 doesn't apply (Simple Dimensions) or can't be changed (CAL_PERIOD)
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   06-NOV-03  Created
 |    Rob Flippo   16-MAR-05  Bug34244082 Modify to return the member_id
 |                            in the select so that we can use that to
 |                            query the HIER table in Base_update
 |    Rob Flippo   22-MAR-05  Fix query so that dimension_id is part of where
 |                            condition when joining to FEM_DIMENSION_GRPS_B
 +===========================================================================*/


   procedure build_remain_mbr_select_stmt  (p_load_type IN VARCHAR2
                                           ,p_dimension_id IN NUMBER
                                           ,p_dimension_varchar_label IN VARCHAR2
                                           ,p_shared_dimension_flag IN VARCHAR2
                                           ,p_value_set_required_flag IN VARCHAR2
                                           ,p_hier_dimension_flag IN VARCHAR2
                                           ,p_source_b_table IN VARCHAR2
                                           ,p_target_b_table IN VARCHAR2
                                           ,p_member_col IN VARCHAR2
                                           ,p_member_dc_col IN VARCHAR2
                                           ,p_member_t_dc_col IN VARCHAR2
                                           ,p_exec_mode_clause IN VARCHAR2
                                           ,x_remain_mbr_select_stmt OUT NOCOPY VARCHAR2)
   IS
     -- Dimension Label where condition (for shared dimensions)
      v_dim_label_where_cond       VARCHAR2(1000);


   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_remain_mbr_select_stmt',
        'Begin');

      -- setting the Dim Label conditions
      IF (p_value_set_required_flag = 'N'
          AND p_shared_dimension_flag = 'Y') THEN
         v_dim_label_where_cond  :=
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';
      ELSE
         v_dim_label_where_cond  := '';
      END IF; -- setting the Dim Label conditions


   IF (p_load_type = 'DIMENSION_MEMBER') AND
      (p_value_set_required_flag = 'Y') AND
      (p_hier_dimension_flag = 'Y') THEN
         x_remain_mbr_select_stmt :=
            'SELECT B.rowid'||
            ', to_char(TB.'||p_member_col||')'||
            ', B.'||p_member_t_dc_col||
            ', B.value_set_display_code'||
            ', V.value_set_id'||
            ', B.dimension_group_display_code'||
            ', D.dimension_group_id'||
            ', TB.dimension_group_id'||
            ',null'||
            ',null'||
            ', ''LOAD'' '||
            ' FROM '||p_source_b_table||' B'||
            ', FEM_DIMENSION_GRPS_B D'||
            ', FEM_VALUE_SETS_B V'||
            ', '||p_target_b_table||' TB'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} '||
            ' AND B.value_set_display_code = V.value_set_display_code'||
            ' AND B.dimension_group_display_code = D.dimension_group_display_code (+)'||
            ' AND D.dimension_id (+) = '||p_dimension_id||
            ' AND B.'||p_member_t_dc_col||' = TB.'||p_member_dc_col||
            ' AND TB.value_set_id = V.value_set_id';

             /*****************************************************
             3/16/05 commented out because doing join now to target b table
            ' AND EXISTS (SELECT 0'||
            ' FROM '||p_target_b_table||
            ' WHERE '||p_member_dc_col||' = B.'||p_member_t_dc_col||
            ' AND value_set_id = (SELECT value_set_id FROM fem_value_sets_b'||
            ' WHERE value_set_display_code = B.value_set_display_code))';
            ********************************************************/

   ELSIF (p_load_type = 'DIMENSION_MEMBER') AND
      (p_value_set_required_flag = 'Y') AND
      (p_hier_dimension_flag = 'N') THEN
         x_remain_mbr_select_stmt :=
            'SELECT B.rowid'||
            ', to_char(TB.'||p_member_col||')'||
            ', B.'||p_member_t_dc_col||
            ', B.value_set_display_code'||
            ', V.value_set_id'||
            ', null'||
            ', null'||
            ',null'||
            ',null'||
            ',null'||
            ', ''LOAD'' '||
            ' FROM '||p_source_b_table||' B'||
            ', FEM_VALUE_SETS_B V'||
            ', '||p_target_b_table||' TB'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} '||
            ' AND B.value_set_display_code = V.value_set_display_code'||
            ' AND B.'||p_member_t_dc_col||' = TB.'||p_member_dc_col||
            ' AND TB.value_set_id = V.value_set_id';

             /*****************************************************
             3/16/05 commented out because doing join now to target b table
            ' AND EXISTS (SELECT 0'||
            ' FROM '||p_target_b_table||
            ' WHERE '||p_member_dc_col||' = B.'||p_member_t_dc_col||
            ' AND value_set_id = (SELECT value_set_id FROM fem_value_sets_b'||
            ' WHERE value_set_display_code = B.value_set_display_code))';
            ********************************************************/

   ELSIF (p_load_type = 'DIMENSION_MEMBER')
         AND (p_dimension_varchar_label = 'CAL_PERIOD') THEN

         -- keeping the where exists clause rather than straight join due to
         -- the fact that source_b table doesn't have a single display_code col
         -- for CAL_PERIOD
         x_remain_mbr_select_stmt :=
            'SELECT B.rowid'||
            ',LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
            'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
            'LPAD(to_char(C.calendar_id),5,''0'')||'||
            'LPAD(to_char(D.time_dimension_group_key),5,''0'') '||
            ',LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
            'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
            'LPAD(to_char(C.calendar_id),5,''0'')||'||
            'LPAD(to_char(D.time_dimension_group_key),5,''0'') '||
            ', null'||
            ', null'||
            ', null'||
            ', null'||
            ',null'||
            ',null'||
            ',null'||
            ', ''LOAD'' '||
            ' FROM '||p_source_b_table||' B'||
            ', FEM_CALENDARS_B C'||
            ', FEM_DIMENSION_GRPS_B D'||
            ' WHERE B.calendar_display_code = C.calendar_display_code'||
            ' AND B.dimension_group_display_code = D.dimension_group_display_code'||
            ' AND EXISTS (SELECT 0'||
            ' FROM '||p_target_b_table||
            ' WHERE to_char('||p_member_dc_col||') = '||
            'LPAD(to_char(to_number(to_char(B.cal_period_end_date,''j''))),7,''0'')||'||
            'LPAD(TO_CHAR(B.cal_period_number),15,''0'')||'||
            'LPAD(to_char(C.calendar_id),5,''0'')||'||
            'LPAD(to_char(D.time_dimension_group_key),5,''0'')) '||
            ' AND B.status'||p_exec_mode_clause||
            ' AND   {{data_slice}} ';
   ELSIF (p_load_type = 'DIMENSION_MEMBER') AND
      (p_value_set_required_flag = 'N') AND
      (p_dimension_varchar_label NOT IN  ('CAL_PERIOD')) THEN
         x_remain_mbr_select_stmt :=
            'SELECT B.rowid'||
            ', to_char(TB.'||p_member_col||')'||
            ', B.'||p_member_t_dc_col||
            ', null'||
            ', null'||
            ', null'||
            ', null'||
            ',null'||
            ',null'||
            ',null'||
            ', ''LOAD'' '||
            ' FROM '||p_source_b_table||' B'||
            ', '||p_target_b_table||' TB'||
            ' WHERE B.status'||p_exec_mode_clause||
            v_dim_label_where_cond||
            ' AND B.'||p_member_t_dc_col||' = TB.'||p_member_dc_col||
            ' AND   {{data_slice}} ';

             /*****************************************************
             3/16/05 commented out because doing join now to target b table
            ' WHERE EXISTS (SELECT 0'||
            ' FROM '||p_target_b_table||
            ' WHERE '||p_member_dc_col||' = '||
            ' B.'||p_member_t_dc_col||')'||
            ******************************************************/

   ELSIF (p_load_type = 'DIMENSION_GROUP') THEN
         x_remain_mbr_select_stmt :=
            'SELECT B.rowid'||
            ', to_char(TB.'||p_member_col||')'||
            ', B.'||p_member_t_dc_col||
            ', null'||
            ', null'||
            ', null'||
            ', null'||
            ', null'||
            ',B.dimension_group_seq'||
            ',B.time_group_type_code'||
            ', ''LOAD'' '||
            ' FROM '||p_source_b_table||' B'||
            ', '||p_target_b_table||' TB'||
            ', fem_dimensions_b D'||
            ' WHERE B.status'||p_exec_mode_clause||
            ' AND B.dimension_varchar_label = D.dimension_varchar_label'||
            ' AND D.dimension_id = TB.dimension_id'||
            ' AND TB.dimension_group_display_code = B.dimension_group_display_code'||
            ' AND B.dimension_varchar_label = '''||p_dimension_varchar_label||'''';

             /*****************************************************
             3/16/05 commented out because doing join now to target b table
            ' WHERE EXISTS (SELECT 0'||
            ' FROM '||p_target_b_table||
            ' WHERE '||p_member_dc_col||' = '||
            ' B.'||p_member_t_dc_col||')'||
            *******************************************************/

   END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_remain_mbr_select_stmt',
        'End');

   END build_remain_mbr_select_stmt;


/*===========================================================================+
 | PROCEDURE
 |              BUILD_DIMGRP_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating
 |                 the DIMENSION_GROUP_ID column on the _B member table
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |    This procedure does not use the table handlers for performing the update
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   06-NOV-03  Created
 |    Rob Flippo   16-MAR-05  Bug#4244082 requires this procedure
 |    Rob Flippo   04-AUG-06  Bug 5060746 Change literals to bind variables wherever possible
 +===========================================================================*/


   procedure build_dimgrp_update_stmt (p_target_b_table IN VARCHAR2
                                      ,p_value_set_required_flag IN VARCHAR2
                                      ,p_member_dc_col IN VARCHAR2
                                      ,x_update_stmt OUT NOCOPY VARCHAR2)

   IS


   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_dimgrp_update_stmt',
        'Begin');


      IF p_value_set_required_flag = 'Y' THEN
        x_update_stmt :=
        'UPDATE '||p_target_b_table||
           ' SET dimension_group_id = :b_dimension_group_id'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE '||p_member_dc_col||' = :b_member_dc'||
           ' AND value_set_id = :b_value_set_id'||
           ' AND :b_status = ''LOAD''';

      ELSE
        x_update_stmt :=
        'UPDATE '||p_target_b_table||
           ' SET dimension_group_id = :b_dimension_group_id'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE '||p_member_dc_col||' = :b_member_dc'||
           ' AND :b_status = ''LOAD''';

      END IF;
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_dimgrp_update_stmt',
        'End');

   END build_dimgrp_update_stmt;



/*===========================================================================+
 | PROCEDURE
 |              BUILD_ATTR_UPDATE_STMT
 |
 | DESCRIPTION
 |                 Builds the dynamic UPDATE statement for updating
 |                 existing ATTR rows using the interface source _ATTR_T rows
 |
 | SCOPE - PRIVATE
 |
 | NOTES
 |
 |
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   13-NOV-03  Created
 |    Rob Flippo   04-JAN-05  Added "use_interim_table_flag" condition
 |                            so that the update only happens for rows that are
 |                            not going to the FEM_CALP_ATTR_INTERIM_T table for
 |                            additional processing
 |   Rob Flippo   11-AUG-05   Bug#4547868 performance issue - fix update
 |                            so no subquery against base table
 | Rob Flippo  04-AUG-06  Bug 5060746 Change literals to bind variables wherever possible
 +===========================================================================*/


   procedure build_attr_update_stmt (p_target_attr_table IN VARCHAR2
                                    ,p_target_b_table IN VARCHAR2
                                    ,p_member_dc_col IN VARCHAR2
                                    ,p_member_col IN VARCHAR2
                                    ,p_value_set_required_flag IN VARCHAR2
                                    ,x_update_stmt OUT NOCOPY VARCHAR2)

   IS


   BEGIN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attr_update_stmt',
        'Begin');

   IF p_value_set_required_flag = 'Y' THEN
        x_update_stmt :=

        'UPDATE '||p_target_attr_table||' A'||
           ' SET dim_attribute_numeric_member = :b_dim_attribute_numeric_member'||
           ' ,dim_attribute_value_set_id = :b_dim_attribute_value_set_id'||
           ' ,dim_attribute_varchar_member = :b_dim_attribute_varchar_member'||
           ' ,number_assign_value = :b_number_assign_value'||
           ' ,varchar_assign_value = :b_varchar_assign_value'||
           ' ,date_assign_value = :b_date_assign_value'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE A.'||p_member_col||' = :b_member_id'||
           ' AND A.value_set_id = :value_set_id'||
           ' AND A.attribute_id = :b_attribute_id'||
           ' AND A.version_id = :b_version_id'||
           ' AND :b_allow_mult_assign_flag = ''N'''||
           ' AND :b_attr_exists_count > 0'||
           ' AND :b_status = ''LOAD''';


/*************************8
commented out per bug#4547868
        'UPDATE '||p_target_attr_table||' A'||
           ' SET dim_attribute_numeric_member = :b_dim_attribute_numeric_member'||
           ' ,dim_attribute_value_set_id = :b_dim_attribute_value_set_id'||
           ' ,dim_attribute_varchar_member = :b_dim_attribute_varchar_member'||
           ' ,number_assign_value = :b_number_assign_value'||
           ' ,varchar_assign_value = :b_varchar_assign_value'||
           ' ,date_assign_value = :b_date_assign_value'||
           ',last_update_date = sysdate '||
           ',last_updated_by = '||gv_apps_user_id||
           ',last_update_login = '||gv_login_id||
           ' WHERE A.'||p_member_col||' = (SELECT '||p_member_col||
           ' FROM '||p_target_b_table||' B'||
           ', fem_value_sets_b V'||
           ' WHERE B.'||p_member_dc_col||' = :b_member_dc'||
           ' AND B.value_set_id = V.value_set_id'||
           ' AND V.value_set_display_code = :value_set_dc)'||
           ' AND A.attribute_id = :b_attribute_id'||
           ' AND A.version_id = :b_version_id'||
           ' AND :b_allow_mult_assign_flag = ''N'''||
           ' AND :b_attr_exists_count > 0'||
           ' AND :b_status = ''LOAD''';
****************************************************/
   ELSE
        x_update_stmt :=
        'UPDATE '||p_target_attr_table||' A'||
           ' SET dim_attribute_numeric_member = :b_dim_attribute_numeric_member'||
           ' ,dim_attribute_value_set_id = :b_dim_attribute_value_set_id'||
           ' ,dim_attribute_varchar_member = :b_dim_attribute_varchar_member'||
           ' ,number_assign_value = :b_number_assign_value'||
           ' ,varchar_assign_value = :b_varchar_assign_value'||
           ' ,date_assign_value = :b_date_assign_value'||
           ',last_update_date = sysdate '||
           ',last_updated_by = :b_apps_user_id'||
           ',last_update_login = :b_login_id'||
           ' WHERE A.'||p_member_col||' = :b_member_id'||
           ' AND A.attribute_id = :b_attribute_id'||
           ' AND A.version_id = :b_version_id'||
           ' AND :b_allow_mult_assig_flag = ''N'''||
           ' AND :b_attr_exists_count > 0'||
           ' AND :b_status = ''LOAD'''||
           ' AND :b_use_interim_table_flag = ''N''';
/***********************************
commented out per bug#4547868
        'UPDATE '||p_target_attr_table||' A'||
           ' SET dim_attribute_numeric_member = :b_dim_attribute_numeric_member'||
           ' ,dim_attribute_value_set_id = :b_dim_attribute_value_set_id'||
           ' ,dim_attribute_varchar_member = :b_dim_attribute_varchar_member'||
           ' ,number_assign_value = :b_number_assign_value'||
           ' ,varchar_assign_value = :b_varchar_assign_value'||
           ' ,date_assign_value = :b_date_assign_value'||
           ',last_update_date = sysdate '||
           ',last_updated_by = '||gv_apps_user_id||
           ',last_update_login = '||gv_login_id||
           ' WHERE A.'||p_member_col||' = (SELECT '||p_member_col||
           ' FROM '||p_target_b_table||' B'||
           ' WHERE to_char(B.'||p_member_dc_col||') = :b_member_dc)'||
           ' AND A.attribute_id = :b_attribute_id'||
           ' AND A.version_id = :b_version_id'||
           ' AND :b_allow_mult_assig_flag = ''N'''||
           ' AND :b_attr_exists_count > 0'||
           ' AND :b_status = ''LOAD'''||
           ' AND :b_use_interim_table_flag = ''N''';
*******************************************/


   END IF; -- p_value_set_required_flag
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_2,c_block||'.'||
        'build_attr_update_stmt',
        'End');

   END build_attr_update_stmt;

/*===========================================================================+
 | PROCEDURE
 |              Calp_Date_Overlap_Check
 |
 | DESCRIPTION
 |                 Called after New_Members and ATTR_ASSIGN_UPDATE
 |                 procedures are complete
 |                 Identifies Date Overlap records for CAL_PERIOD loads
 |                 This procedure does not employ MP - it is single threaded
 |                 because all cal_periods to be loaded must be evaluated
 |                 for each member to be loaded
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |   If operation_mode = 'NEW_MEMBERS', then Bulk Collect CAL_PERIOD_IDs
 |      to check from FEM_CALP_INTERIM_T
 |   Else operation_mode = 'ATTR_UPDATE', then Bulk Collect CAL_PERIOD_IDs
 |      to check from join of FEM_CALP_ATTR_INTERIM_T and FEM_CALP_INTERIM_T
 |      where the attribute = CAL_PERIOD_START_DATE
 |      Note that FEM_CALP_INTERIM_T is always populated, even for Attr Update,
 |      which is why we can use this table to perform the overlap checks
 |
 |   Once the list of CAL_PERIOD_IDs to check is populated query the
 |     FEM_CALP_INTERIM_T table for each one to see if any date overlaps exist
 |     This table will be populated for all CAL_PERIODs in the load, whether
 |     for a New_Member phase or an ATTR_ASSIGN_UPDATE phase
 |
 |   For NEW_MEMBER phase, if an overlap is found, update the OVERLAP_FLAG = 'Y'
 |   in FEM_CALP_INTERIM_T for that cal_period_id.
 |   -- also update the STATUS in the _B_T, _TL_T and ATTR_T tables for CAL_PERIOD
 |      for each member as follows:
 |      ATTR_T table: CALENDAR_PERIOD_START_DATE attr row =  "OVERLAP_START_DATE_IN_LOAD"
 |      ATTR_T table: all other attr rows = "INVALID_MEMBER"
 |      TL_T table: "INVALID_MEMBER"
 |      B_T table:  "INVALID_REQUIRED_ATTRIBUTE"
 |
 |   For ATTR_UPDATE phase, if an overlap is found, update the OVERLAP_FLAG = 'Y'
 |   in FEM_CALP_ATTR_INTERIM_T for the "START_DATE" attribute rows
 |   -- also update the STATUS in the _ATTR_T table as follows:
 |      CALENDAR_PERIOD_START_DATE attr row = "OVERLAP_START_DATE_IN_LOAD"
 |
 |   Note:  We perform the STATUS updates on the interface tables in this procedure
 |          since we already have the bad rows in our array.  Rather than require
 |          a requery of the Interim tables in another procedure, it's more performant just
 |          to perform the status update now, even though it is single threaded
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   03-JAN-05  Created
 |
 +===========================================================================*/

procedure calp_date_overlap_check(x_rows_rejected OUT NOCOPY NUMBER
                                 ,p_operation_mode IN VARCHAR2
)
IS

   t_cal_period_id      number_type;
   t_calendar_id        number_type;
   t_dimension_group_id number_type;
   t_start_date         date_type;
   t_end_date           date_type;
   t_rowid              rowid_type;
   t_overlap_flag       flag_type;
   t_calendar_dc        varchar2_std_type;
   t_dimension_group_dc varchar2_std_type;
   t_cal_period_number  number_type;


   v_bulk_rows_rejected NUMBER;
   v_rows_rejected NUMBER;
   v_mbr_last_row NUMBER;
   v_count        NUMBER;
   v_fetch_limit  NUMBER;
   v_interim_table_name   VARCHAR2(30);  -- this holds the interim table_name for sql operations

   x_select_stmt                VARCHAR2(4000);
   x_date_check_stmt            VARCHAR2(4000);
   x_update_stmt                VARCHAR2(4000);
   x_update_mbr_status_stmt     VARCHAR2(4000);
   x_update_tl_status_stmt      VARCHAR2(4000);
   x_update_attr_status_stmt    VARCHAR2(4000);
   x_update_attrlab_status_stmt VARCHAR2(4000);

   -- Declare Table names for status updates
   v_source_b_table    VARCHAR2(4000);
   v_source_tl_table   VARCHAR2(4000);
   v_source_attr_table VARCHAR2(4000);

---------------------
-- Declare cursors --
---------------------
   cv_get_rows           cv_curs;

BEGIN

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'calp_date_overlap_check','Begin Date Overlap Check for CAL_PERIOD load');

   -- initialize the fetch limit to 10,000 rows
   -- since calp_date_overlap_check is not an MP procedure, we can't get
   -- the fetch limit from the MP parameters.  So we set it manually
   -- here
   v_fetch_limit := 10000;

   -- initialize the table name variables for CAL_PERIOD interface table names
   v_source_b_table := 'FEM_CAL_PERIODS_B_T';
   v_source_tl_table := 'FEM_CAL_PERIODS_TL_T';
   v_source_attr_table := 'FEM_CAL_PERIODS_ATTR_T';

   -- initialize the rejected row count
   v_rows_rejected := 0;

   build_calp_status_update_stmt ('ATTRIBUTE_LABEL'
                                 ,v_source_attr_table
                                 ,x_update_attrlab_status_stmt);


   IF p_operation_mode = 'NEW_MEMBERS' THEN
      v_interim_table_name := 'FEM_CALP_INTERIM_T';

      x_select_stmt := 'SELECT rowid'||
                       ', cal_period_id'||
                       ', calendar_id'||
                       ', dimension_group_id'||
                       ', cal_period_end_date'||
                       ', cal_period_start_date'||
                       ', overlap_flag'||
                       ', cal_period_number'||
                       ', calendar_display_code'||
                       ', dimension_group_display_code'||
                       ' FROM fem_calp_interim_t'||
                       ' WHERE adjustment_period_flag = ''N''';

      -- When processing Members, we have to perform status
      -- updates on the other interface tables, plus the other
      -- rows in the ATTR_T table
      build_calp_status_update_stmt ('NO_LABEL'
                                    ,v_source_b_table
                                    ,x_update_mbr_status_stmt);

      build_calp_status_update_stmt ('NO_LABEL'
                                    ,v_source_tl_table
                                    ,x_update_tl_status_stmt);

      build_calp_status_update_stmt ('NO_LABEL'
                                    ,v_source_attr_table
                                    ,x_update_attr_status_stmt);


   ELSE
      v_interim_table_name := 'FEM_CALP_ATTR_INTERIM_T';
      x_select_stmt := 'SELECT AI.rowid'||
                       ', AI.cal_period_id'||
                       ', I.calendar_id'||
                       ', I.dimension_group_id'||
                       ', I.cal_period_end_date'||
                       ', I.cal_period_start_date'||
                       ', I.overlap_flag'||
                       ', I.cal_period_number'||
                       ', I.calendar_display_code'||
                       ', I.dimension_group_display_code'||
                       ' FROM fem_calp_attr_interim_t AI'||
                       ',fem_calp_interim_t I'||
                       ',fem_dim_attributes_b A'||
                       ' WHERE AI.cal_period_id = I.cal_period_id'||
                       ' AND AI.attribute_id = A.attribute_id'||
                       ' AND A.attribute_varchar_label = ''CAL_PERIOD_START_DATE'''||
                       ' AND I.adjustment_period_flag = ''N''';


   END IF;
   x_date_check_stmt := 'SELECT count(*) FROM fem_calp_interim_t'||
                        ' WHERE cal_period_end_date >= :b_start_date'||
                        ' AND cal_period_start_date <= :b_end_date'||
                        ' AND calendar_id = :b_calendar_id'||
                        ' AND dimension_group_id = :b_dimension_group_id'||
                        ' AND adjustment_period_flag = ''N'''||
                        ' AND cal_period_id <> :b_cal_period_id';

   x_update_stmt := 'UPDATE '||v_interim_table_name||
                            ' SET overlap_flag = ''Y'''||
                            ' WHERE rowid = :b_rowid'||
                            ' AND :b_overlap_flag = ''Y''';

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||'x_select_stmt',x_select_stmt);

   OPEN cv_get_rows FOR x_select_stmt;

   LOOP

      FETCH cv_get_rows BULK COLLECT INTO
             t_rowid
            ,t_cal_period_id
            ,t_calendar_id
            ,t_dimension_group_id
            ,t_end_date
            ,t_start_date
            ,t_overlap_flag
            ,t_cal_period_number
            ,t_calendar_dc
            ,t_dimension_group_dc
      LIMIT v_fetch_limit;
      ----------------------------------------------
      -- EXIT Fetch LOOP If No Rows are Retrieved --
      ----------------------------------------------
      v_mbr_last_row := t_cal_period_id.LAST;

      IF (v_mbr_last_row IS NULL)
      THEN
         EXIT;
      END IF;

      --------------------------------------------------------------------------
      --  Begin Looking for Overlaps
      --  process each calendar period id in the array row by row
      --  when an overlap condition found, mark the selected cal_period_id
      --  in the interim table.  Note that we don't attempt to mark any of the
      --  cal_period_ids that caused the overlap, because to do so would be
      --  expensive in terms of code and even performance because it would require
      --  an additional I/O since the overlaps might not exist within the array
      ------------------------------------------------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||'calp_date_overlap_check','Begin looking for overlaps');

      FOR i IN 1..v_mbr_last_row
      LOOP
         EXECUTE IMMEDIATE x_date_check_stmt
         INTO v_count
         USING t_start_date(i)
              ,t_end_date(i)
              ,t_calendar_id(i)
              ,t_dimension_group_id(i)
              ,t_cal_period_id(i);

         IF v_count > 0 THEN
            t_overlap_flag(i) := 'Y';
         END IF;

      END LOOP; -- Begin Looking for Overlaps
      ------------------------------------------------------------
      -- Update the Interim table Overlap Flag for all bad records
      -- this statement either updates FEM_CALP_INTERIM_T or
      -- FEM_CALP_ATTR_INTERIM_T, depending on the Operation Mode
      ------------------------------------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||'calp_date_overlap_check','Update interim table');

      FORALL i IN 1..v_mbr_last_row
         EXECUTE IMMEDIATE x_update_stmt
         USING t_rowid(i)
              ,t_overlap_flag(i);

      -- For mode = NEW_MEMBERS, we update the status in the
      -- following interface tables:
      -- FEM_CAL_PERIODS_B_T
      -- FEM_CAL_PERIODS_TL_T
      -- FEM_CAL_PERIODS_ATTR_T (for the START_DATE attribute)
      -- FEM_CAL_PERIODS_ATTR_T (for any other attr rows of that member)
      --
      -- Otherwise (Attr Assign Update mode), we only update the
      -- following interface table:
      -- FEM_CAL_PERIODS_ATTR_T (for the START_DATE attribute)
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||'calp_date_overlap_check','Update status of bad records');

      IF p_operation_mode = 'NEW_MEMBERS' THEN
         ----------------------------------------------------------
         -- Update Status of _B_T table for failed members
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_mbr_status_stmt
            USING 'INVALID_REQUIRED_ATTRIBUTE'
                 ,t_cal_period_number(i)
                 ,t_end_date(i)
                 ,t_calendar_dc(i)
                 ,t_dimension_group_dc(i)
                 ,t_overlap_flag(i);

            v_bulk_rows_rejected := SQL%ROWCOUNT;
            v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;

         ----------------------------------------------------------
         -- Update Status of _TL_T table for failed members
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_tl_status_stmt
            USING 'INVALID_MEMBER'
                 ,t_cal_period_number(i)
                 ,t_end_date(i)
                 ,t_calendar_dc(i)
                 ,t_dimension_group_dc(i)
                 ,t_overlap_flag(i);

            v_bulk_rows_rejected := SQL%ROWCOUNT;
            v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;
         ----------------------------------------------------------
         -- Update Status of other (non START_DATE) attr assignments for the member
         -- in the _ATTR_T table
         ----------------------------------------------------------
         FORALL i IN 1..v_mbr_last_row
            EXECUTE IMMEDIATE x_update_attr_status_stmt
            USING 'INVALID_MEMBER'
                 ,t_cal_period_number(i)
                 ,t_end_date(i)
                 ,t_calendar_dc(i)
                 ,t_dimension_group_dc(i)
                 ,t_overlap_flag(i);

            v_bulk_rows_rejected := SQL%ROWCOUNT;
            v_rows_rejected := v_rows_rejected + v_bulk_rows_rejected;

      END IF;

      ----------------------------------------------------------
      -- Update Status of Attr Collection for failed START_DATE records
      -- this update applies to both NEW_MEMBERS and ATTR_ASSIGN_UPDATE
      -- modes
      -- We do this last since we are overwriting the previous
      -- status update for the single record where attribute_varchar_label =
      -- CAL_PERIOD_START_DATE
      ----------------------------------------------------------
      FORALL i IN 1..v_mbr_last_row
         EXECUTE IMMEDIATE x_update_attrlab_status_stmt
         USING 'OVERLAP_START_DATE_IN_LOAD'
              ,t_cal_period_number(i)
              ,t_end_date(i)
              ,t_calendar_dc(i)
              ,t_dimension_group_dc(i)
              ,t_overlap_flag(i);
      -- NOTE:  We do not count the error rows for this particular
      --        status update because we have already counted the
      --        row in the previous ATTR_T update (i.e., we don't want
      --        to double-count)


      --------------------------------------------
      -- Delete CAL_PERIOD Collection for Next Bulk Fetch --
      --------------------------------------------
      t_rowid.DELETE;
      t_cal_period_id.DELETE;
      t_calendar_id.DELETE;
      t_dimension_group_id.DELETE;
      t_start_date.DELETE;
      t_end_date.DELETE;
      t_overlap_flag.DELETE;
      t_cal_period_number.DELETE;
      t_calendar_dc.DELETE;
      t_dimension_group_dc.DELETE;

    --COMMIT;
   END LOOP; -- main bulk collect
   CLOSE cv_get_rows;
   x_rows_rejected := v_rows_rejected;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_2,c_block||'.'||'calp_date_overlap_check','End Date Overlap Check for CAL_PERIOD load');


END calp_date_overlap_check;


----------------------------------------------------------------------
-- Post Dimension Status (called by Main)
--
--   This procedure puts an entry into FEM_DIM_LOAD_STATUS
--   for each source system code in the load
--
--   If # of records in source attr table =0, the entry is 'INCOMPLETE'
--   Otherwise, it is 'INCOMPLETE'
------------------------------------------------------------------------
   PROCEDURE Post_dim_status (p_dimension_id   IN  VARCHAR2
                             ,p_source_system_dc IN VARCHAR2
                             ,p_source_attr_table IN VARCHAR2)
   IS
      v_src_sys_select_stmt VARCHAR2(4000);
      v_src_sys_status VARCHAR2(30);
      v_status_count NUMBER;
      v_attr_count NUMBER;
      v_dim_load_status VARCHAR2(30);
      v_source_system_code NUMBER;
      v_sql_stmt VARCHAR2(4000);
      c_proc_name VARCHAR2(30) := 'Post_dim_status';

      e_invalid_src_sys EXCEPTION;

   BEGIN
      -- Get the source_system_code for the input source_system_dc
      BEGIN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name,'Begin');

      SELECT source_system_code
      INTO v_source_system_code
      FROM fem_source_systems_b
      WHERE source_system_display_code = p_source_system_dc;

      EXCEPTION
         WHEN no_data_found THEN
            RAISE e_invalid_src_sys;
      END;

      -- Is there an existing status row in FEM_DIM_LOAD_STATUS
      -- for the Source System Code and Dimension combination?
      SELECT count(*)
      INTO v_status_count
      FROM fem_dim_load_status
      WHERE dimension_id = p_dimension_id
      AND source_system_code = v_source_system_code;

      -- Check the record count in the source ATTR_T table
      -- This is the only table we check for error rows, since it is the
      -- only table that has a source system context
      v_src_sys_select_stmt := 'SELECT count(*) FROM '||p_source_attr_table||
                               ' WHERE attribute_varchar_label = ''SOURCE_SYSTEM_CODE'''||
                               ' AND attribute_assign_value = '''||p_source_system_dc||''''||
                               ' AND rownum=1';

      EXECUTE IMMEDIATE v_src_sys_select_stmt
      INTO v_attr_count;

      IF v_attr_count = 0 THEN
         v_dim_load_status := 'COMPLETE';
      ELSE v_dim_load_status := 'INCOMPLETE';
      END IF;

      IF v_status_count = 0 THEN
         INSERT INTO fem_dim_load_status (DIMENSION_ID
                                         ,SOURCE_SYSTEM_CODE
                                         ,LOAD_STATUS
                                         ,REPROCESS_ERRORS_FLAG
                                         ,CREATION_DATE
                                         ,CREATED_BY
                                         ,LAST_UPDATED_BY
                                         ,LAST_UPDATE_DATE
                                         ,LAST_UPDATE_LOGIN
                                         ,OBJECT_VERSION_NUMBER)
         SELECT p_dimension_id
               ,v_source_system_code
               ,v_dim_load_status
               ,'N'
               ,sysdate
               ,gv_apps_user_id
               ,gv_apps_user_id
               ,sysdate
               ,gv_login_id
               ,1
         FROM dual;
      ELSE
         UPDATE fem_dim_load_status
         SET load_status = v_dim_load_status,
         last_updated_by = gv_apps_user_id,
         last_update_date = sysdate,
         last_update_login = gv_login_id
         WHERE dimension_id = p_dimension_id
         AND source_system_code = v_source_system_code;
      END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name,'End');

   EXCEPTION
      WHEN e_invalid_src_sys THEN
         null;

   END Post_dim_status;

    --------------------------------------------------------------------------
    -- This Procedure is to intialize the TABLE TYPE variable which stores
    -- the flex field information of the Activity and Cost Objects


    -- The TABLE TYPE variable holds the following values for each
    -- component Dimension

    --   ATTRIBUTE                      VALUE

	--   dimension_varchar_label         Component Dimension varchar label
    --   dimension_id                    -999
    --   member_col                      null
    --   member_display_code_col         null
    --   member_b_table_name             null
    --   value_set_required_flag         null
    --   member_sql                      null


    -- PARAMETER Information

    -- p_dimension_varchar_label     The Varchar Label of Composite Dimension

    -- MODIFICATION HISTORY
    --  sshanmug     11-May-05       Created.
    ----------------------------------------------------------------------------

 /* PROCEDURE Metadata_Initialize(p_dimension_varchar_label IN VARCHAR2)

    IS

    c_proc_name CONSTANT VARCHAR2(20) := 'Metadata_Initialize';
    i NUMBER; -- counting variable for no:of segments of Flex Field

    BEGIN

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

    ----------------------------------------------------------------------------
    --Clean the previous Values
    ----------------------------------------------------------------------------

     t_component_dim_dc.DELETE;

    ----------------------------------------------------------------------------
    -- "t_component_dim_dc" is a TABLE TYPE which holds the display code
    -- values of all the component dimension members of Activity/Cost Object
    ----------------------------------------------------------------------------

	 IF p_dimension_varchar_label = 'COST_OBJECT' THEN

      t_component_dim_dc(1)  := 'FINANCIAL_ELEM_DISPLAY_CODE';
      t_component_dim_dc(2)  := 'LEDGER_DISPLAY_CODE';
      t_component_dim_dc(3)  := 'PRODUCT_DISPLAY_CODE';
      t_component_dim_dc(4)  := 'CCTR_ORG_DISPLAY_CODE';
      t_component_dim_dc(5)  := 'CUSTOMER_DISPLAY_CODE';
      t_component_dim_dc(6)  := 'CHANNEL_DISPLAY_CODE';
      t_component_dim_dc(7)  := 'PROJECT_DISPLAY_CODE';
      t_component_dim_dc(8)  := 'USER_DIM1_DISPLAY_CODE';
      t_component_dim_dc(9)  := 'USER_DIM2_DISPLAY_CODE';
      t_component_dim_dc(10) := 'USER_DIM3_DISPLAY_CODE';
      t_component_dim_dc(11) := 'USER_DIM4_DISPLAY_CODE';
      t_component_dim_dc(12) := 'USER_DIM5_DISPLAY_CODE';
      t_component_dim_dc(13) := 'USER_DIM6_DISPLAY_CODE';
      t_component_dim_dc(14) := 'USER_DIM7_DISPLAY_CODE';
      t_component_dim_dc(15) := 'USER_DIM8_DISPLAY_CODE';
      t_component_dim_dc(16) := 'USER_DIM9_DISPLAY_CODE';
      t_component_dim_dc(17) := 'USER_DIM10_DISPLAY_CODE';

	  --------------------------------------------------------------------------
	  --As per Cost Object HLD, the Cost Object FF can have 17 segments and
	  --hence initializing it to 17
	  --------------------------------------------------------------------------
	  i := 17;


     ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

      t_component_dim_dc(1)  := 'TASK_DISPLAY_CODE';
      t_component_dim_dc(2)  := 'CCTR_ORG_DISPLAY_CODE';
      t_component_dim_dc(3)  := 'CUSTOMER_DISPLAY_CODE';
      t_component_dim_dc(4)  := 'CHANNEL_DISPLAY_CODE';
      t_component_dim_dc(5)  := 'PRODUCT_DISPLAY_CODE';
      t_component_dim_dc(6)  := 'PROJECT_DISPLAY_CODE';
      t_component_dim_dc(7)  := 'USER_DIM1_DISPLAY_CODE';
      t_component_dim_dc(8)  := 'USER_DIM2_DISPLAY_CODE';
      t_component_dim_dc(9)  := 'USER_DIM3_DISPLAY_CODE';
      t_component_dim_dc(10) := 'USER_DIM4_DISPLAY_CODE';
      t_component_dim_dc(11) := 'USER_DIM5_DISPLAY_CODE';
      t_component_dim_dc(12) := 'USER_DIM6_DISPLAY_CODE';
      t_component_dim_dc(13) := 'USER_DIM7_DISPLAY_CODE';
      t_component_dim_dc(14) := 'USER_DIM8_DISPLAY_CODE';
      t_component_dim_dc(15) := 'USER_DIM9_DISPLAY_CODE';
      t_component_dim_dc(16) := 'USER_DIM10_DISPLAY_CODE';

	  --------------------------------------------------------------------------
	  --As per Activity HLD, the Cost Object FF can have 16 segments and
	  --hence initializing it to 16
	  --------------------------------------------------------------------------
       i := 16;

     END IF;

     ---------------------------------------------------------------------------
     --Initialize the TABLE TYPE variable 't_metadata' with default values.
     ---------------------------------------------------------------------------

    FOR j IN 1 .. i LOOP

         t_metadata(j).dimension_varchar_label := NULL;
         t_metadata(j).member_display_code_col := t_component_dim_dc(j);
         t_metadata(j).dimension_id := -999;
         t_metadata(j).member_col := NULL;
         t_metadata(j).member_b_table_name := NULL;
         t_metadata(j).value_set_required_flag := NULL;
         t_metadata(j).member_sql := NULL;

     END LOOP;

	 fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.End'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

     EXCEPTION

     WHEN others THEN

      fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

      RAISE e_terminate;

    END Metadata_Initialize;


/*===========================================================================+
 | PROCEDURE
 |              Get_Display_Code
 |
 | DESCRIPTION
 |    This procedure concatenates the individual component dimension members
 |   of the Composite Dimensions(Activity and Cost Objects).
 |
 |     The component dimension members are concatenated to form a
 |   single Composite Dimension Member.The component dimension members
 |   are separated by the delimiter of the corresponding flex filed.
 |
 |ARGUMENTS  : IN:
 |
 |  p_dimension_varchar_label - Composite Dimension Name
 |  p_structure_id            - FF structure Code
 |
 | MODIFICATION HISTORY
 |    Aturlapa     06-APR-05  Created
 |    sshanmug     11-May-05  Generalised the common piece of code both AC/CO.
 +===========================================================================*/

 /* PROCEDURE Get_Display_Codes (p_dimension_varchar_label IN VARCHAR2,
                               p_structure_id            IN NUMBER)

   IS

     c_proc_name CONSTANT VARCHAR2(20) := 'Get_Display_Codes';

     -- FF Details
     l_segment_delimiter VARCHAR2(1);
     p_ff_code_activity  VARCHAR2(4) := 'FEAC';
     p_ff_code_cost VARCHAR2(4) := 'FECO';

     --Counting Variable
     v_last_row NUMBER;

   BEGIN

    fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

    ----------------------------------------------------------------------------
    --Get the count of records in the interface table (this fetch)
    ----------------------------------------------------------------------------

    v_last_row := t_status.COUNT;

    ----------------------------------------------------------------------------
    --Clean the previous Values
    ----------------------------------------------------------------------------

    t_display_code.DELETE;

    ----------------------------------------------------------------------
    --Get the segment delimiter
    ----------------------------------------------------------------------

    IF p_dimension_varchar_label = 'COST_OBJECT' THEN

	  l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER('FEM',p_ff_code_cost,
                                                    p_structure_id);
    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

	  l_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER('FEM',p_ff_code_activity,
                                                    p_structure_id);
    END IF;



    FOR i IN 1..v_last_row LOOP

      --------------------------------------------------------------------------
      -- Concatenate only rows with STATUS = 'LOAD'
      --------------------------------------------------------------------------

      IF t_status(i) = 'LOAD' THEN

        IF p_dimension_varchar_label = 'COST_OBJECT' THEN

          ----------------------------------------------------------------------
          --Fin Elem and Ledger are mandatory for CO hence it is concatenated
          ----------------------------------------------------------------------

          t_display_code(i) := t_fin_elem_dc(i) || l_segment_delimiter;
          t_display_code(i) := t_display_code(i) || t_ledger_dc(i);

          ----------------------------------------------------------------------
          --Concatenate other segments only if they are not null.
          ----------------------------------------------------------------------

          IF t_product_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_product_dc(i);
          END IF;
          IF t_cctr_org_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_cctr_org_dc(i);
          END IF;
          IF t_customer_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_customer_dc(i);
          END IF;
		  IF t_channel_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_channel_dc(i);
          END IF;
          IF t_project_dc(i) IS NOT NULL THEN
          t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_project_dc(i);
          END IF;

        ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

          ----------------------------------------------------------------------
          --Task is mandatory for Activity hence it is concatenated
          ----------------------------------------------------------------------

          t_display_code(i) := t_task_dc(i);

         -----------------------------------------------------------------------
         --Concatenate other segments only if they are not null.
         -----------------------------------------------------------------------

         IF t_cctr_org_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_cctr_org_dc(i);
         END IF;
         IF t_customer_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_customer_dc(i);
         END IF;
         IF t_channel_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_channel_dc(i);
         END IF;
         IF t_product_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_product_dc(i);
         END IF;
         IF t_project_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_project_dc(i);
         END IF;

        END IF;

        ------------------------------------------------------------------------
        -- The following component Dimensions are common for both Activity and
        -- Cost Object. Hence it will be common code for both dimensions.
        ------------------------------------------------------------------------

         IF t_user_dim1_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim1_dc(i);
         END IF;
         IF t_user_dim2_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim2_dc(i);
         END IF;
         IF t_user_dim3_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim3_dc(i);
         END IF;
         IF t_user_dim4_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim4_dc(i);
         END IF;
         IF t_user_dim5_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim5_dc(i);
         END IF;
         IF t_user_dim6_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                               l_segment_delimiter||t_user_dim6_dc(i);
         END IF;
         IF t_user_dim7_dc(i) IS NOT NULL THEN
             t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim7_dc(i);
         END IF;
         IF t_user_dim8_dc(i) IS NOT NULL THEN
           t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim8_dc(i);
         END IF;
         IF t_user_dim9_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim9_dc(i);
         END IF;
         IF t_user_dim10_dc(i) IS NOT NULL THEN
            t_display_code(i) := t_display_code(i) ||
                             l_segment_delimiter||t_user_dim10_dc(i);
         END IF;

      ELSE

       t_display_code(i) := NULL;

      END IF; -- STATUS = 'LOAD'

    END LOOP;

   -----------------------------------------------------------------------------
   ---End Concatenate the segments
   -----------------------------------------------------------------------------

       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.End'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label);

  EXCEPTION

    WHEN others THEN
      fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

      RAISE e_terminate;

  END Get_Display_Codes;

/*===========================================================================+
 | PROCEDURE
 |              pre_process
 |
 | DESCRIPTION
 |
 |     This Procedure is used to get the flexfield information of the composite
 | Dimensions (Activity and Cost Object).It populates the component dimension
 | information into a TABLE TYPE variable.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              p_execution_mode - 'S'(Snapshot) / 'E'(Error Reprocessing) Mode.
 |              p_dimension_varchar_label - Indicates the Dimension
 |
 |              OUT:
 |
 |              x_pre_process_status - Status of the Procedure.
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Aturlapa        31-MAR-05  Created
 |    sshanmug        10-May-05  Incorporated the comments from Nico.
 +===========================================================================*/

 /* PROCEDURE Pre_Process (x_pre_process_status OUT NOCOPY VARCHAR2
                         ,p_execution_mode IN VARCHAR2
                         ,p_dimension_varchar_label IN VARCHAR2)
   IS

   c_proc_name CONSTANT varchar2(20) := 'Pre_Process';

   -- variable to get the status of AC/CO FF Definition.
   l_dim_active_flag VARCHAR2(1);

   BEGIN

     -- Initialize the return status
     x_pre_process_status := 'SUCCESS';

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Mode'||p_execution_mode
			                      ||'Dimension'||p_dimension_varchar_label);

     --------------------------------------------------------------------------
     -- Check whether the AC/CO structure is defined or not
     -- Raise the Exception if the AC / CO Structure is not freezed.
     --------------------------------------------------------------------------
     BEGIN

       SELECT dimension_active_flag
       INTO l_dim_active_flag
       FROM Fem_Xdim_Dimensions_VL
       WHERE dimension_varchar_label = p_dimension_varchar_label;

     EXCEPTION

	   WHEN no_data_found THEN
	     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Freeze_Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);
     END;

     IF l_dim_active_flag = 'N' THEN

	   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_5
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||' Flex Field
			  Definition Not Freezed');

	   RAISE e_no_structure_defined;
     END IF;

     ---------------------------------------------------------------------------
     --Clean up the MetaData Variable
     ---------------------------------------------------------------------------

     t_metadata.DELETE;

     ---------------------------------------------------------------------------
     --Initialize the TABLE TYPE Variable which holds the metadata information
     ---------------------------------------------------------------------------
     Metadata_Initialize(p_dimension_varchar_label);

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'After Metadata_Initialize');

     IF p_dimension_varchar_label = 'COST_OBJECT' THEN

	  -------------------------------------------------------------------------
       --This loop runs for all the component Dimension members of
       --the Cost Object Dimension and populates their details into
       --'t_metadata' variable
       -------------------------------------------------------------------------

        FOR c_metadata_cost IN (
          SELECT x.dimension_id
          ,x.dimension_varchar_label
          ,x.member_col
          ,x.member_display_code_col
          ,x.member_b_table_name
          ,x.value_set_required_flag
          FROM FEM_COLUMN_REQUIREMNT_VL c
          ,FEM_XDIM_DIMENSIONS_VL x
          WHERE c.dimension_id = x.dimension_id
          AND c.cost_obj_dim_component_flag = 'Y'
          ORDER BY 1 )
          LOOP
            FOR i IN 1 .. t_metadata.COUNT LOOP
       	    IF c_metadata_cost.member_display_code_col = t_component_dim_dc(i) THEN
              t_metadata(i).dimension_id := c_metadata_cost.dimension_id;
              t_metadata(i).dimension_varchar_label :=
			                       c_metadata_cost.dimension_varchar_label;
              t_metadata(i).member_col := c_metadata_cost.member_col;
              t_metadata(i).member_b_table_name :=
                                            c_metadata_cost.member_b_table_name;
              t_metadata(i).value_set_required_flag :=
                              c_metadata_cost.value_set_required_flag;
              t_metadata(i).member_sql :=
              ' SELECT '||c_metadata_cost.member_col||
              ' FROM '||c_metadata_cost.member_b_table_name||
              ' WHERE enabled_flag = ''Y'''||
              ' AND '||c_metadata_cost.member_display_code_col||' = :b_dc_val';

              IF (c_metadata_cost.value_set_required_flag = 'Y') THEN
                t_metadata(i).member_sql := t_metadata(i).member_sql||
				                         ' AND value_set_id = :b_value_set_id';
              END IF;
       	    END IF;
            END LOOP;
          END LOOP;

        -------------------------------------------------------------------------
        -- Build Engine SQL --
        -------------------------------------------------------------------------

        g_select_statement :=
         'SELECT rowid,'||
         ' GLOBAL_VS_COMBO_DISPLAY_CODE,'||
         ' financial_elem_display_code,'||
         ' ledger_display_code,'||
         ' product_display_code,'||
         ' CCTR_ORG_DISPLAY_CODE,'||
         ' customer_display_code,'||
         ' channel_display_code,'||
         ' project_display_code,'||
         ' user_dim1_display_code,'||
         ' user_dim2_display_code,'||
         ' user_dim3_display_code,'||
         ' user_dim4_display_code,'||
         ' user_dim5_display_code,'||
         ' user_dim6_display_code,'||
         ' user_dim7_display_code,'||
         ' user_dim8_display_code,'||
         ' user_dim9_display_code,'||
         ' user_dim10_display_code,'||
         ' status'||
         ' FROM FEM_COST_OBJECTS_T '||
         ' WHERE {{data_slice}} ';

     ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN

       -------------------------------------------------------------------------
       --Initialize the TABLE TYPE Variable which holds the metadata information
       -------------------------------------------------------------------------

       Metadata_Initialize(p_dimension_varchar_label);

       -------------------------------------------------------------------------
       --Thid loop runs for all the component Dimension members of
       --the Activity Dimension and populates their details into
       --'t_metadata' variable
       -------------------------------------------------------------------------

       FOR c_metadata_activity IN (
         SELECT x.dimension_id
         ,x.dimension_varchar_label
         ,x.member_col
         ,x.member_display_code_col
         ,x.member_b_table_name
         ,x.value_set_required_flag
         FROM FEM_COLUMN_REQUIREMNT_VL c
         ,FEM_XDIM_DIMENSIONS_VL x
         WHERE c.dimension_id = x.dimension_id
         AND c.activity_dim_component_flag = 'Y'
         ORDER BY 1 )
        LOOP
           FOR i IN 1 .. t_metadata.COUNT LOOP
             IF c_metadata_activity.member_display_code_col
			                                       = t_component_dim_dc(i) THEN
             t_metadata(i).dimension_id := c_metadata_activity.dimension_id;
             t_metadata(i).dimension_varchar_label :=
			                       c_metadata_activity.dimension_varchar_label;
             t_metadata(i).member_col := c_metadata_activity.member_col;
             t_metadata(i).member_b_table_name :=
                                      c_metadata_activity.member_b_table_name;
             t_metadata(i).value_set_required_flag :=
                                    c_metadata_activity.value_set_required_flag;
             t_metadata(i).member_sql :=
             ' SELECT '||c_metadata_activity.member_col||
             ' FROM '||c_metadata_activity.member_b_table_name||
             ' WHERE enabled_flag = ''Y'''||
             ' AND '||c_metadata_activity.member_display_code_col||' = :b_dc_val';

               IF (c_metadata_activity.value_set_required_flag = 'Y') THEN
                 t_metadata(i).member_sql := t_metadata(i).member_sql||
				                          ' AND value_set_id = :b_value_set_id';
               END IF;
             END IF;
           END LOOP;
         END LOOP;

       -------------------------------------------------------------------------
       -- Build Engine SQL --
       -------------------------------------------------------------------------

       g_select_statement :=
         'SELECT rowid,'||
         ' GLOBAL_VS_COMBO_DISPLAY_CODE,'||
         ' TASK_DISPLAY_CODE,'||
         ' CCTR_ORG_DISPLAY_CODE,'||
         ' customer_display_code,'||
         ' channel_display_code,'||
         ' product_display_code,'||
         ' project_display_code,'||
         ' user_dim1_display_code,'||
         ' user_dim2_display_code,'||
         ' user_dim3_display_code,'||
         ' user_dim4_display_code,'||
         ' user_dim5_display_code,'||
         ' user_dim6_display_code,'||
         ' user_dim7_display_code,'||
         ' user_dim8_display_code,'||
         ' user_dim9_display_code,'||
         ' user_dim10_display_code,'||
         ' status'||
         ' FROM FEM_ACTIVITIES_T '||
         ' WHERE {{data_slice}} ';
	 END IF;



     fem_engines_pkg.tech_message (
       p_severity  => c_log_level_1
	   ,p_module   => c_block||'.'||c_proc_name||'.End'
       ,p_msg_text => 'Mode'||p_execution_mode
	                     ||'Dimension'||p_dimension_varchar_label);

   EXCEPTION

     WHEN e_no_structure_defined THEN

       fem_engines_pkg.tech_message (
          p_severity => c_log_level_4
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_NO_STRUCTURE_DEFINED
          ,P_TOKEN1 => 'OPERATION'
          ,P_VALUE1 => p_dimension_varchar_label);

       x_pre_process_status := 'ERROR';

      WHEN others THEN

       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Mode'||p_execution_mode||
                            'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

       x_pre_process_status := 'ERROR';

   END Pre_Process;

 /*===========================================================================+
 | PROCEDURE
 |              process_rows
 |
 | DESCRIPTION
 |
 |             This procedure is used to process all the rows in the interface
 |  table of composite dimensions (FEM_ACTIVITIES_T/FEM_COST_OBJECTS_T) and
 |  performs various validations on these records,concatenate the component
 |  dimension members and inserts only the valid records into the member table
 |  of Composite Dimensions.The invalid records will be processed in
 |  'Error Reproceesing' Mode.
 |
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Aturlapa    31-MAR-05  Created
 |    sshanmug    17-MAY-05  Incorporated comments from Nico
 |
 +===========================================================================*/

/*  procedure Process_Rows (x_status OUT NOCOPY NUMBER
                      ,x_message OUT NOCOPY VARCHAR2
                      ,x_rows_processed OUT NOCOPY NUMBER
                      ,x_rows_loaded OUT NOCOPY NUMBER
                      ,x_rows_rejected OUT NOCOPY NUMBER
                      ,p_eng_sql IN VARCHAR2
                      ,p_data_slc IN VARCHAR2
                      ,p_proc_num IN VARCHAR2
                      ,p_slice_id IN VARCHAR2
                      ,p_fetch_limit IN NUMBER
                      ,p_load_type IN VARCHAR2
                      ,p_dimension_varchar_label IN VARCHAR2
                      ,p_execution_mode IN VARCHAR2
                      ,p_structure_id IN NUMBER)
   IS

   c_proc_name CONSTANT varchar2(20) := 'Process_Rows';

   lv_status VARCHAR2(200);

   v_fetch_limit NUMBER;
   v_rows_processed NUMBER;
   v_rows_rejected NUMBER;
   v_rows_loaded NUMBER;

   v_cost_object_dc FEM_COST_OBJECTS.cost_object_display_code%TYPE;
   v_activity_dc FEM_ACTIVITIES.activity_display_code%TYPE;

   -- Follwoing 3 params are needed for FEM_DIM_UTILS_PVT.Check_Unique_Member

   v_return_status  VARCHAR2(20);
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(200);

   v_cost_structure_id NUMBER;
   v_activity_structure_id NUMBER;

   v_select_stmt LONG;
   v_data_slc VARCHAR2(4000);

   v_update_stmt VARCHAR2(4000);
   v_delete_stmt VARCHAR2(4000);
   v_member_table_name VARCHAR2(200);

   v_CREATED_BY        NUMBER := fnd_global.user_id;
   v_LAST_UPDATED_BY   NUMBER := fnd_global.user_id;
   v_LAST_UPDATE_LOGIN NUMBER := fnd_global.login_id;

   v_last_row   NUMBER;
   v_mbr_last_row NUMBER;

   x_pre_process_status VARCHAR2(30);

   l_count NUMBER;-- var to keep track of inavlid values for each validation

  ------------------------------------------
  -- DML Statements used in the procedure --
  -------------------------------------------

   v_insert_cost_stmt CONSTANT LONG :=
   'INSERT INTO FEM_COST_OBJECTS ('||
   ' COST_OBJECT_ID, '||
   ' COST_OBJECT_DISPLAY_CODE, '||
   ' SUMMARY_FLAG, '||
   ' START_DATE_ACTIVE, '||
   ' END_DATE_ACTIVE, '||
   ' COST_OBJECT_STRUCTURE_ID, '||
   ' LOCAL_VS_COMBO_ID, '||
   ' UOM_CODE, '||
   ' FINANCIAL_ELEM_ID, '||
   ' LEDGER_ID, '||
   ' PRODUCT_ID, '||
   ' COMPANY_COST_CENTER_ORG_ID, '||
   ' CUSTOMER_ID, '||
   ' CHANNEL_ID, '||
   ' PROJECT_ID, '||
   ' USER_DIM1_ID, '||
   ' USER_DIM2_ID, '||
   ' USER_DIM3_ID, '||
   ' USER_DIM4_ID, '||
   ' USER_DIM5_ID, '||
   ' USER_DIM6_ID, '||
   ' USER_DIM7_ID, '||
   ' USER_DIM8_ID, '||
   ' USER_DIM9_ID, '||
   ' USER_DIM10_ID, '||
   ' SEGMENT1, '||
   ' SEGMENT2, '||
   ' SEGMENT3, '||
   ' SEGMENT4, '||
   ' SEGMENT5, '||
   ' SEGMENT6, '||
   ' SEGMENT7, '||
   ' SEGMENT8, '||
   ' SEGMENT9, '||
   ' SEGMENT10, '||
   ' SEGMENT11, '||
   ' SEGMENT12, '||
   ' SEGMENT13, '||
   ' SEGMENT14, '||
   ' SEGMENT15, '||
   ' SEGMENT16, '||
   ' SEGMENT17, '||
   ' SEGMENT18, '||
   ' SEGMENT19, '||
   ' SEGMENT20, '||
   ' SEGMENT21, '||
   ' SEGMENT22, '||
   ' SEGMENT23, '||
   ' SEGMENT24, '||
   ' SEGMENT25, '||
   ' SEGMENT26, '||
   ' SEGMENT27, '||
   ' SEGMENT28, '||
   ' SEGMENT29, '||
   ' SEGMENT30, '||
   ' CREATION_DATE, '||
   ' CREATED_BY, '||
   ' LAST_UPDATED_BY, '||
   ' LAST_UPDATE_DATE, '||
   ' LAST_UPDATE_LOGIN, '||
   ' OBJECT_VERSION_NUMBER, '||
   ' ENABLED_FLAG, '||
   ' PERSONAL_FLAG, '||
   ' READ_ONLY_FLAG )'||
   ' SELECT fem_cost_objects_s.nextval,'||
          ' :b_COST_OBJECT_DISPLAY_CODE, '||
          ' :b_SUMMARY_FLAG, '||
          ' :b_START_DATE_ACTIVE, '||
          ' :b_END_DATE_ACTIVE, '||
          ' :b_COST_OBJECT_STRUCTURE_ID, '||
          ' :b_LOCAL_VS_COMBO_ID, '||
          ' :b_UOM_CODE, '||
          ' :b_FINANCIAL_ELEM_ID, '||
          ' :b_LEDGER_ID, '||
          ' :b_PRODUCT_ID, '||
          ' :b_COMPANY_COST_CENTER_ORG_ID, '||
          ' :b_CUSTOMER_ID, '||
          ' :b_CHANNEL_ID, '||
          ' :b_PROJECT_ID, '||
          ' :b_USER_DIM1_ID, '||
          ' :b_USER_DIM2_ID, '||
          ' :b_USER_DIM3_ID, '||
          ' :b_USER_DIM4_ID, '||
          ' :b_USER_DIM5_ID, '||
          ' :b_USER_DIM6_ID, '||
          ' :b_USER_DIM7_ID, '||
          ' :b_USER_DIM8_ID, '||
          ' :b_USER_DIM9_ID, '||
          ' :b_USER_DIM10_ID, '||
          ' :b_SEGMENT1, '||
          ' :b_SEGMENT2, '||
          ' :b_SEGMENT3, '||
          ' :b_SEGMENT4, '||
          ' :b_SEGMENT5, '||
          ' :b_SEGMENT6, '||
          ' :b_SEGMENT7, '||
          ' :b_SEGMENT8, '||
          ' :b_SEGMENT9, '||
          ' :b_SEGMENT10, '||
          ' :b_SEGMENT11, '||
          ' :b_SEGMENT12, '||
          ' :b_SEGMENT13, '||
          ' :b_SEGMENT14, '||
          ' :b_SEGMENT15, '||
          ' :b_SEGMENT16, '||
          ' :b_SEGMENT17, '||
          ' :b_SEGMENT18, '||
          ' :b_SEGMENT19, '||
          ' :b_SEGMENT20, '||
          ' :b_SEGMENT21, '||
          ' :b_SEGMENT22, '||
          ' :b_SEGMENT23, '||
          ' :b_SEGMENT24, '||
          ' :b_SEGMENT25, '||
          ' :b_SEGMENT26, '||
          ' :b_SEGMENT27, '||
          ' :b_SEGMENT28, '||
          ' :b_SEGMENT29, '||
          ' :b_SEGMENT30, '||
          ' :b_CREATION_DATE, '||
          ' :b_CREATED_BY, '||
          ' :b_LAST_UPDATED_BY, '||
          ' :b_LAST_UPDATE_DATE, '||
          ' :b_LAST_UPDATE_LOGIN, '||
          ' :b_OBJECT_VERSION_NUMBER, '||
          ' :b_ENABLED_FLAG, '||
          ' :b_PERSONAL_FLAG, '||
          ' :b_read_only_flag '||
          ' FROM dual'||
          ' WHERE :b_status = ''LOAD''';

  v_insert_activity_stmt CONSTANT LONG :=
   'INSERT INTO FEM_ACTIVITIES ('||
   ' ACTIVITY_ID, '||
   ' ACTIVITY_DISPLAY_CODE, '||
   ' SUMMARY_FLAG, '||
   ' START_DATE_ACTIVE, '||
   ' END_DATE_ACTIVE, '||
   ' ACTIVITY_STRUCTURE_ID, '||
   ' LOCAL_VS_COMBO_ID, '||
   ' TASK_ID, '||
   ' COMPANY_COST_CENTER_ORG_ID, '||
   ' CUSTOMER_ID, '||
   ' CHANNEL_ID, '||
   ' PRODUCT_ID, '||
   ' PROJECT_ID, '||
   ' USER_DIM1_ID, '||
   ' USER_DIM2_ID, '||
   ' USER_DIM3_ID, '||
   ' USER_DIM4_ID, '||
   ' USER_DIM5_ID, '||
   ' USER_DIM6_ID, '||
   ' USER_DIM7_ID, '||
   ' USER_DIM8_ID, '||
   ' USER_DIM9_ID, '||
   ' USER_DIM10_ID, '||
   ' SEGMENT1, '||
   ' SEGMENT2, '||
   ' SEGMENT3, '||
   ' SEGMENT4, '||
   ' SEGMENT5, '||
   ' SEGMENT6, '||
   ' SEGMENT7, '||
   ' SEGMENT8, '||
   ' SEGMENT9, '||
   ' SEGMENT10, '||
   ' SEGMENT11, '||
   ' SEGMENT12, '||
   ' SEGMENT13, '||
   ' SEGMENT14, '||
   ' SEGMENT15, '||
   ' SEGMENT16, '||
   ' SEGMENT17, '||
   ' SEGMENT18, '||
   ' SEGMENT19, '||
   ' SEGMENT20, '||
   ' SEGMENT21, '||
   ' SEGMENT22, '||
   ' SEGMENT23, '||
   ' SEGMENT24, '||
   ' SEGMENT25, '||
   ' SEGMENT26, '||
   ' SEGMENT27, '||
   ' SEGMENT28, '||
   ' SEGMENT29, '||
   ' SEGMENT30, '||
   ' CREATION_DATE, '||
   ' CREATED_BY, '||
   ' LAST_UPDATED_BY, '||
   ' LAST_UPDATE_DATE, '||
   ' LAST_UPDATE_LOGIN, '||
   ' OBJECT_VERSION_NUMBER, '||
   ' ENABLED_FLAG, '||
   ' PERSONAL_FLAG, '||
   ' READ_ONLY_FLAG )'||
   ' SELECT fem_activities_s.nextval,'||
          ' :b_ACTIVITY_DISPLAY_CODE, '||
          ' :b_SUMMARY_FLAG, '||
          ' :b_START_DATE_ACTIVE, '||
          ' :b_END_DATE_ACTIVE, '||
          ' :b_ACTIVITY_STRUCTURE_ID, '||
          ' :b_LOCAL_VS_COMBO_ID, '||
          ' :b_TASK_ID, '||
          ' :b_COMPANY_COST_CENTER_ORG_ID, '||
          ' :b_CUSTOMER_ID, '||
          ' :b_CHANNEL_ID, '||
          ' :b_PRODUCT_ID, '||
          ' :b_PROJECT_ID, '||
          ' :b_USER_DIM1_ID, '||
          ' :b_USER_DIM2_ID, '||
          ' :b_USER_DIM3_ID, '||
          ' :b_USER_DIM4_ID, '||
          ' :b_USER_DIM5_ID, '||
          ' :b_USER_DIM6_ID, '||
          ' :b_USER_DIM7_ID, '||
          ' :b_USER_DIM8_ID, '||
          ' :b_USER_DIM9_ID, '||
          ' :b_USER_DIM10_ID, '||
          ' :b_SEGMENT1, '||
          ' :b_SEGMENT2, '||
          ' :b_SEGMENT3, '||
          ' :b_SEGMENT4, '||
          ' :b_SEGMENT5, '||
          ' :b_SEGMENT6, '||
          ' :b_SEGMENT7, '||
          ' :b_SEGMENT8, '||
          ' :b_SEGMENT9, '||
          ' :b_SEGMENT10, '||
          ' :b_SEGMENT11, '||
          ' :b_SEGMENT12, '||
          ' :b_SEGMENT13, '||
          ' :b_SEGMENT14, '||
          ' :b_SEGMENT15, '||
          ' :b_SEGMENT16, '||
          ' :b_SEGMENT17, '||
          ' :b_SEGMENT18, '||
          ' :b_SEGMENT19, '||
          ' :b_SEGMENT20, '||
          ' :b_SEGMENT21, '||
          ' :b_SEGMENT22, '||
          ' :b_SEGMENT23, '||
          ' :b_SEGMENT24, '||
          ' :b_SEGMENT25, '||
          ' :b_SEGMENT26, '||
          ' :b_SEGMENT27, '||
          ' :b_SEGMENT28, '||
          ' :b_SEGMENT29, '||
          ' :b_SEGMENT30, '||
          ' :b_CREATION_DATE, '||
          ' :b_CREATED_BY, '||
          ' :b_LAST_UPDATED_BY, '||
          ' :b_LAST_UPDATE_DATE, '||
          ' :b_LAST_UPDATE_LOGIN, '||
          ' :b_OBJECT_VERSION_NUMBER, '||
          ' :b_ENABLED_FLAG, '||
          ' :b_PERSONAL_FLAG, '||
          ' :b_read_only_flag '||
          ' FROM dual'||
          ' WHERE :b_status = ''LOAD''';

  v_update_cost_stmt CONSTANT VARCHAR2(4000) :=
  'UPDATE FEM_COST_OBJECTS_T '||
  ' SET status = :b_status'||
  ' WHERE rowid = :b_rowid';

  v_update_activity_stmt CONSTANT VARCHAR2(4000) :=
  'UPDATE FEM_ACTIVITIES_T '||
  ' SET status = :b_status'||
  ' WHERE rowid = :b_rowid';

  v_delete_cost_stmt CONSTANT VARCHAR2(4000) :=
  'DELETE FROM FEM_COST_OBJECTS_T '||
  ' WHERE rowid = :b_rowid'||
  ' AND   :b_status = ''LOAD''';

  v_delete_activity_stmt CONSTANT VARCHAR2(4000) :=
  'DELETE FROM FEM_ACTIVITIES_T '||
  ' WHERE rowid = :b_rowid'||
  ' AND   :b_status = ''LOAD''';

  -------------------------------------
  -- Declare bulk collection columns --
  -------------------------------------

  TYPE rowid_type IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
   t_rowid rowid_type;

  TYPE number_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   t_global_vs_combo_id    number_type;
   t_fin_elem_id    number_type;
   t_ledger_id    number_type;
   t_cctr_org_id    number_type;
   t_product_id     number_type;
   t_channel_id     number_type;
   t_project_id     number_type;
   t_customer_id    number_type;
   t_task_id        number_type;
   t_user_dim1_id   number_type;
   t_user_dim2_id   number_type;
   t_user_dim3_id   number_type;
   t_user_dim4_id   number_type;
   t_user_dim5_id   number_type;
   t_user_dim6_id   number_type;
   t_user_dim7_id   number_type;
   t_user_dim8_id   number_type;
   t_user_dim9_id   number_type;
   t_user_dim10_id  number_type;

  ----------------------------------------
  -- Ref cursors used in this Procedure --
  ----------------------------------------

   TYPE cv_curs IS REF CURSOR;
   cv_get_rows cv_curs;
   cv_get_invalid_fin_elems cv_curs;
   cv_get_invalid_ledgers cv_curs;
   cv_get_invalid_gvscs cv_curs;
   cv_get_invalid_comp_dims cv_curs;


   BEGIN

   fem_engines_pkg.tech_message(
             p_severity  => c_log_level_2
             ,p_module   => c_block||'.'||c_proc_name||'.Begin'
             ,p_msg_text => 'Execution Mode' || p_execution_mode||
			                'Dimension' || p_dimension_varchar_label);


   --------------------------------------------------------------------------
   -- Initialize all OUT params
   --------------------------------------------------------------------------
   x_status  := 0;
   x_message := 'COMPLETE:NORMAL';
   --Need to initialize X_rows_processed,X_rows_loaded and x_rows_rejected

   --------------------------------------------------------------------------
   -- This procedure gets the flexfield info of the Composite Dimension
   -- and populates the TABLE Type variable
   --------------------------------------------------------------------------

   pre_process (x_pre_process_status
                ,p_execution_mode
                ,p_dimension_varchar_label);



   fem_engines_pkg.tech_message(
             p_severity  => c_log_level_5
             ,p_module   => c_block||'.'||c_proc_name||'.After Pre_Process'
             ,p_msg_text => 'Pre_Process Error '||x_pre_process_status);


   --------------------------------------------------------------------------
   -- Check for the error message from procedure pre-process
   --------------------------------------------------------------------------


   IF x_pre_process_status = 'ERROR' THEN

	 fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'Pre_Process Error'
             ,p_msg_text => 'Code'||SQLCODE||'Err'||SQLERRM);

     RAISE e_terminate;

   END IF;

   -----------------------------------------------------------------------------
   --Initialize MultiProcessing variables
   -----------------------------------------------------------------------------

   v_data_slc := p_data_slc;

   IF v_data_slc IS NULL THEN
     v_data_slc := '1=1';
   END IF;

   IF (p_fetch_limit IS NOT NULL) THEN
     v_fetch_limit := p_fetch_limit;
   ELSE
     v_fetch_limit := c_fetch_limit;
   END IF;

   -----------------------------------------------------------------------------
   -- Add data slice to select statement
   -----------------------------------------------------------------------------

     v_select_stmt := REPLACE(p_eng_sql,'{{data_slice}}',v_data_slc);
  -- v_select_stmt := REPLACE(g_select_statement,'{{data_slice}}',v_data_slc);

   -----------------------------------------------------------------------------
   --Assign the update/delete statement according to the dimension
   -----------------------------------------------------------------------------


   IF (p_dimension_varchar_label = 'COST_OBJECT') THEN
     v_update_stmt := v_update_cost_stmt;
     v_delete_stmt := v_delete_cost_stmt;
     v_member_table_name := 'fem_cost_objects_t';

   ELSIF (p_dimension_varchar_label = 'ACTIVITY') THEN
     v_update_stmt := v_update_activity_stmt;
     v_delete_stmt := v_delete_activity_stmt;
     v_member_table_name := 'fem_activities_t';

   END IF;


   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'v_update_stmt '||v_update_stmt||
			                'v_member_table_name'||v_member_table_name);


   fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'v_delete_stmt '||v_delete_stmt||
		                    'v_member_table_name'||v_member_table_name);

   -----------------------------------------------------------------------------
   -- In Error Reprocessing mode, update status to LOAD
   -----------------------------------------------------------------------------

   IF (p_execution_mode = 'E') THEN
     EXECUTE IMMEDIATE
     ' UPDATE '||v_member_table_name||' b'||
     ' SET status = ''LOAD'''||
     ' WHERE status <> ''LOAD'''||
     ' AND '||v_data_slc;

     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_1
	         ,p_module   => c_block||'.'||c_proc_name||'.Error Reproceesing Mode'
             ,p_msg_text => 'v_data_slc '||v_data_slc||
		                    'v_member_table_name'||v_member_table_name);
   END IF;


/*------------------------------------------------------------------------------
    VALIDATION#1

    This validation checks whether the values in GLOBAL_VS_COMBO_DISPLAY_CODE
    column of interface table is valid.
-------------------------------------------------------------------------------*/

/*   l_count :=0 ;

   OPEN cv_get_invalid_gvscs FOR
     ' SELECT a.rowid '||
	 ' FROM '||v_member_table_name||' a'||
	 ' WHERE not exists '||
     ' (SELECT 1 FROM fem_global_vs_combos_b b '||
	 ' WHERE a.global_vs_combo_display_code= b.global_vs_combo_display_code)'||
     ' AND a.status = ''LOAD'''||
     ' AND '||v_data_slc;

   LOOP
     EXIT WHEN cv_get_invalid_gvscs%NOTFOUND;
     FETCH cv_get_invalid_gvscs BULK COLLECT
     INTO t_rowid
     LIMIT v_fetch_limit;

     -- local var which holds the no : of invalid values

     l_count := l_count + t_rowid.COUNT;

     --Get the count of no : of records this fetch
	 v_last_row := t_rowid.COUNT;

	 IF (v_last_row IS NOT NULL) THEN
       lv_status := 'INVALID_GVSC';

	   FORALL i IN 1..v_last_row
         EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
       t_rowid.DELETE;
       COMMIT;

	 END IF; -- v_last_row

   END LOOP;

   fem_engines_pkg.tech_message (
          p_severity  => c_log_level_1
          ,p_module   => c_block||'.'||c_proc_name||'.Validation#1'
          ,p_msg_text => 'v_data_slc '||v_data_slc||
                         'v_member_table_name'||v_member_table_name||
						 'No:of Invalid Records'|| l_count);


   CLOSE cv_get_invalid_gvscs;

/*------------------------------------------------------------------------------
VALIDATION#2:

            ***This is only for Cost Object Dimension ***

1. The members of the Financial Element should have the value of
COST_OBJECT_UNIT_FLAG attribute as 'Y' and  'DATA_TYPE_CODE' attribute
as 'RATE"

2.The Members of Ledger Dimension and Global_VS_Combo Column should be in sync.
-------------------------------------------------------------------------------*/

/*   IF p_dimension_varchar_label = 'COST_OBJECT' THEN

     FOR c_attr IN (
       SELECT a.attribute_id
       ,v.version_id
       ,a.attribute_varchar_label
       ,a.dimension_id
       FROM fem_dim_attributes_vl a
       ,fem_dim_attr_versions_vl v
       WHERE a.attribute_id = v.attribute_id
       AND v.default_version_flag = 'Y'
       AND (
       (a.attribute_varchar_label IN ('COST_OBJECT_UNIT_FLAG','DATA_TYPE_CODE')
        AND a.dimension_id = 12) -- Financial Element
       OR
       (a.attribute_varchar_label IN ('GLOBAL_VS_COMBO')
        AND a.dimension_id = 7) -- Ledger
       )
       AND v.default_version_flag = 'Y' )
       LOOP
         IF c_attr.dimension_id = 12 THEN -- Financial Element

		   IF c_attr.attribute_varchar_label = 'COST_OBJECT_UNIT_FLAG' THEN

		     l_count :=0 ;

			 OPEN cv_get_invalid_fin_elems FOR
			 ' SELECT b.rowid'||
			 ' FROM fem_cost_objects_t b'||
			 ' ,fem_fin_elems_attr a'||
			 ' ,fem_fin_elems_vl m'||
			 ' WHERE a.financial_elem_id = m.financial_elem_id'||
			 ' AND m.financial_elem_display_code = b.financial_elem_display_code'||
			 ' AND a.attribute_id = '||c_attr.attribute_id||
			 ' AND a.version_id = '||c_attr.version_id||
			 ' AND a.dim_attribute_varchar_member <> ''Y'''||
			 ' AND b.status = ''LOAD'''||
			 ' AND '||v_data_slc;
             LOOP

			 EXIT WHEN cv_get_invalid_fin_elems%NOTFOUND;
			 FETCH cv_get_invalid_fin_elems BULK COLLECT
			 INTO  t_rowid
			 LIMIT v_fetch_limit;

	         -- local var which holds the no : of invalid values

             l_count := l_count + t_rowid.COUNT;

			 v_last_row := t_rowid.COUNT;

			 IF (v_last_row IS NOT NULL) THEN
	           lv_status := 'INVALID_FIN_ELEMS_NOT_COUC_FLAG';
               FORALL i IN 1..v_last_row
               EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
			 END IF; -- v_last_row

             END LOOP;

             CLOSE cv_get_invalid_fin_elems;

             fem_engines_pkg.tech_message (
                        p_severity  => c_log_level_1
                        ,p_module => c_block||'.'||c_proc_name||'.Validation#2.1'
                        ,p_msg_text => 'v_data_slc '||v_data_slc||
                        'v_member_table_name'||v_member_table_name||
						'No:of Invalid Records'|| l_count);

		   ELSE  -- DATA_TYPE_CODE = 'RATE'

		     l_count :=0 ;

             OPEN cv_get_invalid_fin_elems FOR
    		 ' SELECT b.rowid'||
             ' FROM fem_cost_objects_t b'||
             ' ,fem_fin_elems_attr a'||
             ' ,fem_fin_elems_vl m'||
             ' WHERE a.financial_elem_id = m.financial_elem_id'||
             ' AND m.financial_elem_display_code = b.financial_elem_display_code'||
             ' AND a.attribute_id = '||c_attr.attribute_id||
             ' AND a.version_id = '||c_attr.version_id||
             ' AND a.dim_attribute_varchar_member <> ''RATE'''||
             ' AND b.status = ''LOAD'''||
             ' AND '||v_data_slc;

			 LOOP

		     EXIT WHEN cv_get_invalid_fin_elems%NOTFOUND;
             FETCH cv_get_invalid_fin_elems BULK COLLECT
			 INTO t_rowid
			 LIMIT v_fetch_limit;

			 -- local var which holds the no : of invalid values

             l_count := l_count + t_rowid.COUNT;

             v_last_row := t_rowid.COUNT;
             IF (v_last_row IS NOT NULL) THEN
               lv_status := 'INVALID_FIN_ELEMS_NOT_RATE_DATA_TYPE';
               FORALL i IN 1..v_last_row
                 EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
             END IF; -- v_last_row

			 END LOOP;

             CLOSE cv_get_invalid_fin_elems;

             fem_engines_pkg.tech_message (
                        p_severity  => c_log_level_1
                        ,p_module => c_block||'.'||c_proc_name||'.Validation#2.2'
                        ,p_msg_text => 'v_data_slc '||v_data_slc||
                        'v_member_table_name'||v_member_table_name||
						'No:of Invalid Records'|| l_count);

		   END IF; -- attribute_varchar_label = 'COST_OBJECT_UNIT_FLAG'

         ELSE --- if the dimension_id = 7(ledger)

           l_count :=0 ;

           OPEN cv_get_invalid_ledgers FOR
           ' SELECT b.rowid'||
           ' FROM fem_cost_objects_t b'||
           ' WHERE NOT EXISTS ('||
           '  SELECT 1'||
           '  FROM fem_ledgers_b l'||
           '  ,fem_ledgers_attr a'||
           '  ,fem_global_vs_combos_b g'||
           '  WHERE l.ledger_display_code = b.ledger_display_code'||
           '  AND a.ledger_id = l.ledger_id'||
           '  AND a.attribute_id = '||c_attr.attribute_id||
           '  AND a.version_id = '||c_attr.version_id||
           '  AND a.dim_attribute_numeric_member = g.global_vs_combo_id'||
           '  AND g.global_vs_combo_display_code = b.global_vs_combo_display_code'||
           ' )'||
           ' AND status = ''LOAD'''||
           ' AND '||v_data_slc;
           LOOP

		   EXIT WHEN cv_get_invalid_ledgers%NOTFOUND;
           FETCH cv_get_invalid_ledgers BULK COLLECT
		   INTO  t_rowid
		   LIMIT v_fetch_limit;

		   -- local var which holds the no : of invalid values

		   l_count := l_count + t_rowid.COUNT;

		   v_last_row := t_rowid.COUNT;

           IF (v_last_row IS NOT NULL) THEN
             lv_status := 'INVALID_LEDGER_FOR_GVSC';
              FORALL i IN 1..v_last_row
                EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
           END IF; -- v_last_row

           END LOOP;

		   CLOSE cv_get_invalid_ledgers;

		   fem_engines_pkg.tech_message (
                       p_severity  => c_log_level_1
                       ,p_module=> c_block||'.'||c_proc_name||'.Validation#2.3'
                       ,p_msg_text => 'v_data_slc '||v_data_slc||
                       'v_member_table_name'||v_member_table_name||
		        	   'No:of Invalid Records'|| l_count);

         END IF; -- dimension_id = 7(ledger)

         t_rowid.DELETE;

       END LOOP; -- c_attr

   END IF; --- p_dimension_varchar_label = 'COST_OBJECT'

   COMMIT;
/*------------------------------------------------------------------------------
VALIDATION#3:

--This validation ensures that the strucutre of the composite
--dimension flex field is in synch with the records of the interface table.
--(ie) Those component dimensions defined as a part of FlexField should only
--have the 'DISPLAY_CODE' values in the interface table.Other component
--dimension's display code values should be null.Moreover the display code of
--component dimension which is a part of Flex Field Definition should not be
-- null(Inverse of the above scenario).

------------------------------------------------------------------------------*/

/*  l_count := 0;

  FOR i IN 1..t_metadata.COUNT LOOP  -- Loop within the component dimensions

    IF (t_metadata(i).dimension_id <> -999) THEN

      OPEN cv_get_invalid_comp_dims FOR
      ' SELECT b.rowid '||
      ' FROM '||v_member_table_name||' b'||
      ' WHERE '||t_metadata(i).member_display_code_col||' is null'||
      ' AND status = ''LOAD'''||
      ' AND '||v_data_slc;

    ELSE

      OPEN cv_get_invalid_comp_dims FOR
	  ' SELECT b.rowid '||
	  ' FROM '||v_member_table_name||' b'||
	  ' WHERE '||t_metadata(i).member_display_code_col||' is not null'||
	  ' AND status = ''LOAD'''||
	  ' AND '||v_data_slc;

    END IF;

    LOOP
      EXIT WHEN cv_get_invalid_comp_dims%NOTFOUND;
      FETCH cv_get_invalid_comp_dims BULK COLLECT
      INTO t_rowid
      LIMIT v_fetch_limit;

      -- local var which holds the no : of invalid values

      l_count := l_count + t_rowid.COUNT;

      v_last_row := t_rowid.COUNT;

      IF (v_last_row IS NOT NULL) THEN

        lv_status := 'INVALID_STR_'||t_metadata(i).member_display_code_col;

        FORALL i IN 1..v_last_row
          EXECUTE IMMEDIATE v_update_stmt USING lv_status,t_rowid(i);
          t_rowid.DELETE;

      END IF; -- v_last_row

    END LOOP; -- cursor

    CLOSE cv_get_invalid_comp_dims;

   -- END IF;

  END LOOP; -- FOR LOOP

  COMMIT;

  fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#3'
                  ,p_msg_text => 'v_data_slc '||v_data_slc||
                  'v_member_table_name'||v_member_table_name||
				  'No:of Invalid Records'|| l_count);

  ------------------------------------------------------------------------------
  -- end of Validation # 3
  ------------------------------------------------------------------------------

  ------------------------------------------------------------------------------
  -- Start processing Rows from Interface table.
  -- Open the cursor to get the rows from interface table
  ------------------------------------------------------------------------------

  OPEN cv_get_rows FOR v_select_stmt;

  LOOP
    EXIT WHEN cv_get_rows%NOTFOUND;
    IF p_dimension_varchar_label = 'COST_OBJECT' THEN
      FETCH cv_get_rows BULK COLLECT
	  INTO    t_rowid,
              t_global_vs_combo_dc,
              t_fin_elem_dc,
              t_ledger_dc,
              t_product_dc,
              t_cctr_org_dc,
              t_customer_dc,
              t_channel_dc,
              t_project_dc,
              t_user_dim1_dc,
              t_user_dim2_dc,
              t_user_dim3_dc,
              t_user_dim4_dc,
              t_user_dim5_dc,
              t_user_dim6_dc,
              t_user_dim7_dc,
              t_user_dim8_dc,
              t_user_dim9_dc,
              t_user_dim10_dc,
              t_status
	  LIMIT v_fetch_limit;

    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN
      FETCH cv_get_rows BULK COLLECT
	  INTO    t_rowid,
              t_global_vs_combo_dc,
              t_task_dc,
              t_cctr_org_dc,
              t_customer_dc,
              t_channel_dc,
              t_product_dc,
              t_project_dc,
              t_user_dim1_dc,
              t_user_dim2_dc,
              t_user_dim3_dc,
              t_user_dim4_dc,
              t_user_dim5_dc,
              t_user_dim6_dc,
              t_user_dim7_dc,
              t_user_dim8_dc,
              t_user_dim9_dc,
              t_user_dim10_dc,
              t_status
	  LIMIT v_fetch_limit;

    END IF; -- End of Fetch rows

    -- Get the no:of rows this fetch
	v_mbr_last_row := t_status.COUNT;

    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#3'
                  ,p_msg_text => 'v_data_slc '||v_data_slc||
                  'v_member_table_name'||v_member_table_name||
				  'No:of Invalid Records'|| l_count);

     /*  IF (x_rows_loaded IS NULL) THEN
           x_rows_loaded := 0;
        END IF;

        x_rows_loaded := x_rows_loaded + v_mbr_last_row; */


/*------------------------------------------------------------------------------
VALIDATION#4:
-- The Member Ids of component dimension members are populated in the
-- following piece of code.
-- If the member is not present in the component dimension member table
-- that row will be marked as invalid.
------------------------------------------------------------------------------*/

   -- Loop within the number of records in interface table
/*	FOR j IN 1..v_mbr_last_row   LOOP
    -- Initialize the TABLE TYPE Varible
      t_channel_id(j)   := NULL;
      t_cctr_org_id(j)  := NULL;
      t_customer_id(j)  := NULL;
      t_fin_elem_id(j)  := NULL;
      t_ledger_id(j)    := NULL;
      t_product_id(j)   := NULL;
      t_project_id(j)   := NULL;
      t_task_id(j)      := NULL;
      t_user_dim1_id(j) := NULL;
      t_user_dim2_id(j) := NULL;
      t_user_dim3_id(j) := NULL;
      t_user_dim4_id(j) := NULL;
      t_user_dim5_id(j) := NULL;
      t_user_dim6_id(j) := NULL;
      t_user_dim7_id(j) := NULL;
      t_user_dim8_id(j) := NULL;
      t_user_dim9_id(j) := NULL;
      t_user_dim10_id(j):= NULL;

	  t_global_vs_combo_id(j) := -1;

      FOR i IN 1..t_metadata.COUNT LOOP

        IF (t_metadata(i).dimension_id <> '-999') AND (t_status(j) = 'LOAD')THEN

		  FOR c_value_set IN (
            SELECT g.dimension_id
			       ,g.value_set_id
                   ,g.global_vs_combo_id
            FROM FEM_GLOBAL_VS_COMBO_DEFS g,
                 FEM_GLOBAL_VS_COMBOS_b m
            WHERE g.global_vs_combo_id = m.global_vs_combo_id
            AND g.dimension_id = t_metadata(i).dimension_id
            AND m.global_vs_combo_display_code =  t_global_vs_combo_dc(j)
            ORDER BY 1)
          LOOP

          t_global_vs_combo_id(j) := c_value_set.global_vs_combo_id;

		  --Ledger is not handled here as it is non VSR Dimension

          CASE t_metadata(i).member_display_code_col

          WHEN 'FINANCIAL_ELEM_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_fin_elem_id(j)
                          USING  t_fin_elem_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_FIN_ELEM';
                END;

          WHEN 'TASK_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                            INTO  t_task_id(j)
                            USING t_task_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_TASK';
                END;

          WHEN 'CHANNEL_DISPLAY_CODE' THEN

 				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_channel_id(j)
                          USING t_channel_dc(j), c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_CHANNEL';
                END;

          WHEN 'CCTR_ORG_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_cctr_org_id(j)
                          USING  t_cctr_org_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_CCTR_ORG';
                END;

          WHEN 'CUSTOMER_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_customer_id(j)
                          USING t_customer_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_CUSTOMER';
                END;

          WHEN 'PRODUCT_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                         INTO  t_product_id(j)
                         USING t_product_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                   t_status(j) := 'INAVLID_PRODUCT';
                END;

          WHEN 'PROJECT_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                           INTO  t_project_id(j)
                           USING t_project_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_PROJECT';
                END;

          WHEN 'USER_DIM1_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim1_id(j)
                          USING t_user_dim1_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM1';
                END;

          WHEN 'USER_DIM2_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim2_id(j)
                          USING t_user_dim2_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM2';
                END;

          WHEN 'USER_DIM3_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim3_id(j)
                          USING t_user_dim3_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM3';
                END;

          WHEN 'USER_DIM4_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim4_id(j)
                          USING t_user_dim4_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM4';
                END;

          WHEN 'USER_DIM5_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim5_id(j)
                          USING t_user_dim5_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM5';
                END;

          WHEN 'USER_DIM6_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim6_id(j)
                          USING t_user_dim6_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM6';
                END;

          WHEN 'USER_DIM7_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim7_id(j)
                          USING t_user_dim7_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM7';
                END;

          WHEN 'USER_DIM8_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim8_id(j)
                          USING t_user_dim8_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM8';
                END;

          WHEN 'USER_DIM9_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim9_id(j)
                          USING t_user_dim9_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM9';
                END;

          WHEN 'USER_DIM10_DISPLAY_CODE' THEN

				BEGIN
                  EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_user_dim10_id(j)
                          USING t_user_dim10_dc(j),c_value_set.value_set_id;

                EXCEPTION
                  WHEN no_data_found THEN
                    t_status(j) := 'INAVLID_USER_DIM10';
                END;

          ELSE NULL;

          END CASE;

          END LOOP; -- c_value_Set



         /* IF (t_status(j) <> 'LOAD') THEN
            x_rows_rejected := x_rows_rejected + 1;
          END IF;*/

        -- This piece of code is not needed as this validation is done already
       /* ELSIF p_dimension_varchar_label = 'COST_OBJECT'
              AND t_metadata(i).member_display_code_col = 'LEDGER_DISPLAY_CODE'
              AND t_status(j) = 'LOAD' THEN

          BEGIN
           /* SELECT ledger_id
			INTO t_ledger_id(j)
			FROM fem_ledgers_vl
		    WHERE ledger_display_code = t_ledger_dc(j);

		     EXECUTE IMMEDIATE t_metadata(i).member_sql
                          INTO  t_ledger_id(j)
                          USING t_ledger_dc(j);
          EXCEPTION
            WHEN no_data_found THEN
              t_status(j) := 'INAVLID_LEDGER';
          END;*/

/*        END IF; -- if dim_id <> -999


      END LOOP; --1..17(i)

      --------------------------------------------------------------------------
      -- Initialize UOM_CODE column for cost objects
      --------------------------------------------------------------------------

      IF p_dimension_varchar_label = 'COST_OBJECT' THEN
      --we can use FEM_DIM_UTILS_PVT.Get_UOM_Code as well.
        t_uom_code(j) := 'Ea';

        IF t_product_id(j) IS NOT NULL THEN
          BEGIN
            SELECT prod.dim_attribute_varchar_member AS uom_code
            INTO   t_uom_code(j)
            FROM   fem_products_attr prod,
                   fem_dim_attributes_b attr,
                   fem_dim_attr_versions_vl ver
            WHERE  prod.product_id = t_product_id(j)
				   AND  prod.attribute_id = attr.attribute_id
				   AND  prod.version_id = ver.version_id
				   AND  attr.attribute_varchar_label = 'PRODUCT_UOM'
				   AND  ver.attribute_id = attr.attribute_id
				   AND  ver.default_version_flag = 'Y';
          EXCEPTION
            WHEN no_data_found THEN
              t_uom_code(j) := 'Ea';
          END;
        END IF;  -- UOM code

      END IF;  -- Cost Object

	END LOOP; -- 1...v_member_last_row.(j)

	fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#4 - End');



	----------------------------------------------------------------------------
    -- Get the concatenated display code
    -----------------------------------------------------------------------------

     Get_Display_Codes(p_dimension_varchar_label, p_structure_id);

   ----------------------------------------------------------------------------
    -- VALIDATION#5
    -- check for existence of unique member (eliminate unique records in
    -- set of records selected for insertion)
	-- (ie) The following combination must be unique
	--  Display Code + GVSC id
    -----------------------------------------------------------------------------

    FOR i IN 1..v_mbr_last_row LOOP
      FOR j IN (i+1) .. v_mbr_last_row LOOP
        IF  t_display_code(i) =  t_display_code(j)
		              AND t_global_vs_combo_id(i) = t_global_vs_combo_id(j) THEN
          t_status(i) := 'MEMBER_EXISTS';
        END IF;
      END LOOP;
    END LOOP;


    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#5 - End');

    ----------------------------------------------------------------------------
    -- VALIDATION#6
    -- Check for uniqueness of records in the interface table and
    -- Composite Dimension member table
    ----------------------------------------------------------------------------

    FOR i IN 1..v_mbr_last_row LOOP
      IF t_status(i) = 'LOAD' THEN

	    FEM_DIM_UTILS_PVT.Check_Unique_Member( p_api_version => 1.0,
                        p_return_status => v_return_status,
                        p_msg_count => v_msg_count,
                        p_msg_data => v_msg_data,
                        p_comp_dim_flag => 'Y',
                        p_member_name => NULL,
                        p_member_display_code => t_display_code(i),
                        p_dimension_varchar_label => p_dimension_varchar_label,
                        p_value_set_id => NULL,
                        p_global_vs_combo_id => t_global_vs_combo_id(i));

	    IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
	      t_status(i) := 'MEMBER_EXISTS';
	    END IF;
      END IF;
    END LOOP;


    fem_engines_pkg.tech_message (
                  p_severity  => c_log_level_1
                  ,p_module=> c_block||'.'||c_proc_name||'.Validation#6 - End');

    ----------------------------------------------------------------------------
    -- Insert the valid record into composite dimension member table
    ----------------------------------------------------------------------------

    IF p_dimension_varchar_label = 'COST_OBJECT' THEN
      FORALL i IN 1..v_mbr_last_row
        EXECUTE IMMEDIATE v_insert_cost_stmt
        USING t_display_code(i),
              'N',
              sysdate,
              sysdate,
              p_structure_id,
              t_global_vs_combo_id(i),
              t_uom_code(i),
              t_fin_elem_id(i),
              t_ledger_id(i),
              t_product_id(i),
              t_cctr_org_id(i),
              t_customer_id(i),
              t_channel_id(i),
              t_project_id(i),
              t_user_dim1_id(i),
              t_user_dim2_id(i),
              t_user_dim3_id(i),
              t_user_dim4_id(i),
              t_user_dim5_id(i),
              t_user_dim6_id(i),
              t_user_dim7_id(i),
              t_user_dim8_id(i),
              t_user_dim9_id(i),
              t_user_dim10_id(i),
              t_fin_elem_dc(i),
              t_ledger_dc(i),
              t_product_dc(i),
              t_cctr_org_dc(i),
              t_customer_dc(i),
              t_channel_dc(i),
              t_project_dc(i),
              t_user_dim1_dc(i),
              t_user_dim2_dc(i),
              t_user_dim3_dc(i),
              t_user_dim4_dc(i),
              t_user_dim5_dc(i),
              t_user_dim6_dc(i),
              t_user_dim7_dc(i),
              t_user_dim8_dc(i),
              t_user_dim9_dc(i),
              t_user_dim10_dc(i),
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              sysdate,
              v_CREATED_BY,
              v_LAST_UPDATED_BY,
              sysdate,
              v_LAST_UPDATE_LOGIN,
              1,
              'Y',
              'N',
              'N',
              t_status(i);

    ELSIF p_dimension_varchar_label = 'ACTIVITY' THEN
      FORALL i IN 1..v_mbr_last_row
        EXECUTE IMMEDIATE v_insert_activity_stmt
        USING t_display_code(i),
              'N',
              sysdate,
              sysdate,
              p_structure_id,
              t_global_vs_combo_id(i),
              t_task_id(i),
              t_cctr_org_id(i),
              t_customer_id(i),
              t_channel_id(i),
              t_product_id(i),
              t_project_id(i),
              t_user_dim1_id(i),
              t_user_dim2_id(i),
              t_user_dim3_id(i),
              t_user_dim4_id(i),
              t_user_dim5_id(i),
              t_user_dim6_id(i),
              t_user_dim7_id(i),
              t_user_dim8_id(i),
              t_user_dim9_id(i),
              t_user_dim10_id(i),
              t_task_dc(i),
              t_cctr_org_dc(i),
              t_customer_dc(i),
              t_channel_dc(i),
              t_product_dc(i),
              t_project_dc(i),
              t_user_dim1_dc(i),
              t_user_dim2_dc(i),
              t_user_dim3_dc(i),
              t_user_dim4_dc(i),
              t_user_dim5_dc(i),
              t_user_dim6_dc(i),
              t_user_dim7_dc(i),
              t_user_dim8_dc(i),
              t_user_dim9_dc(i),
              t_user_dim10_dc(i),
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              sysdate,
              v_CREATED_BY,
              v_LAST_UPDATED_BY,
              sysdate,
              v_LAST_UPDATE_LOGIN,
              1,
              'Y',
              'N',
              'N',
              t_status(i);

    END IF; -- Actvity / Cost Object

    ----------------------------------------------------------------------------
    --Populate the parameters for logging
    ----------------------------------------------------------------------------
    v_rows_loaded := v_rows_loaded + SQL%ROWCOUNT;
    v_rows_processed := v_rows_processed  + cv_get_rows%ROWCOUNT;
    v_rows_rejected := v_rows_rejected + (v_rows_processed - v_rows_loaded);

    ----------------------------------------------------------------------------
    -- This is common for both Activity and Cost Object
    -- Update the 'STATUS' column of Interface table
    -- Delete the  insertes rows from interface tables ((ie) STATUS = LOAD )
    ----------------------------------------------------------------------------

    FORALL i IN 1..v_mbr_last_row
      EXECUTE IMMEDIATE v_update_stmt USING t_status(i),t_rowid(i);

    FORALL i IN 1..v_mbr_last_row
      EXECUTE IMMEDIATE v_delete_stmt USING t_rowid(i),t_status(i);

  END LOOP; --- Bulk fetch from interface tables.

  CLOSE cv_get_rows;


  fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
                            'Data Slice'||v_data_slc||
                            'Rows Processed'||v_rows_processed||
                            'Rows Loaded'||v_rows_loaded||
                            'Rows Rejected'||v_rows_rejected );

  --x_rows_rejected := get_mp_rows_rejected (x_rows_rejected)

  --------------------------
  -- Commit the transaaction
  --------------------------

   COMMIT;

   --------------------------------------------
   -- Delete Collections for Next Bulk Fetch --
   --------------------------------------------

   t_fin_elem_id.DELETE;
   t_ledger_id.DELETE;
   t_rowid.DELETE;
   t_global_vs_combo_id.DELETE;
   t_task_id.DELETE;
   t_cctr_org_id.DELETE;
   t_channel_id.DELETE;
   t_customer_id.DELETE;
   t_product_id.DELETE;
   t_project_id.DELETE;
   t_user_dim1_id.DELETE;
   t_user_dim2_id.DELETE;
   t_user_dim3_id.DELETE;
   t_user_dim4_id.DELETE;
   t_user_dim5_id.DELETE;
   t_user_dim6_id.DELETE;
   t_user_dim7_id.DELETE;
   t_user_dim8_id.DELETE;
   t_user_dim9_id.DELETE;
   t_user_dim10_id.DELETE;
   t_global_vs_combo_dc.DELETE;
   t_task_dc.DELETE;
   t_cctr_org_dc.DELETE;
   t_channel_dc.DELETE;
   t_customer_dc.DELETE;
   t_product_dc.DELETE;
   t_project_dc.DELETE;
   t_fin_elem_dc.DELETE;
   t_ledger_dc.DELETE;
   t_user_dim1_dc.DELETE;
   t_user_dim2_dc.DELETE;
   t_user_dim3_dc.DELETE;
   t_user_dim4_dc.DELETE;
   t_user_dim5_dc.DELETE;
   t_user_dim6_dc.DELETE;
   t_user_dim7_dc.DELETE;
   t_user_dim8_dc.DELETE;
   t_user_dim9_dc.DELETE;
   t_user_dim10_dc.DELETE;
   t_display_code.DELETE;
   t_status.DELETE;

   EXCEPTION
      WHEN e_terminate THEN

       fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_4
	             ,p_module   => c_block||'.'||c_proc_name||'Exception');

       IF cv_get_rows%ISOPEN THEN
         CLOSE cv_get_rows;
       END IF;

       IF cv_get_invalid_fin_elems%ISOPEN THEN
         CLOSE cv_get_invalid_fin_elems;
       END IF;

       IF cv_get_invalid_ledgers%ISOPEN THEN
         CLOSE cv_get_invalid_ledgers;
       END IF;

       IF cv_get_invalid_gvscs%ISOPEN THEN
         CLOSE cv_get_invalid_gvscs;
       END IF;

       IF cv_get_invalid_comp_dims%ISOPEN THEN
         CLOSE cv_get_invalid_comp_dims;
       END IF;

	   x_status := 2;
	   x_message := 'INCOMPLETE:EXCEPTION';

       RAISE e_main_terminate;

     WHEN OTHERS THEN
       fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Exception'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);

       IF cv_get_rows%ISOPEN THEN
         CLOSE cv_get_rows;
       END IF;

       IF cv_get_invalid_fin_elems%ISOPEN THEN
         CLOSE cv_get_invalid_fin_elems;
       END IF;

       IF cv_get_invalid_ledgers%ISOPEN THEN
         CLOSE cv_get_invalid_ledgers;
       END IF;

       IF cv_get_invalid_gvscs%ISOPEN THEN
         CLOSE cv_get_invalid_gvscs;
       END IF;

       IF cv_get_invalid_comp_dims%ISOPEN THEN
         CLOSE cv_get_invalid_comp_dims;
       END IF;

	   x_status := 2;
	   x_message := 'INCOMPLETE:EXCEPTION';

       RAISE e_main_terminate;

   END process_rows;


/*===========================================================================+
 | PROCEDURE
 |                 Load Dimension
 |
 | DESCRIPTION
 |                 Main engine procedure for loading dimension members
 |                 and attribute assignments into FEM
 |
 |
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                p_dimension_varchar_label (identifies the Dimension being loaded)
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |    The Load_Dimension procedure performs the following:
 |       1)  Engine_Master_Prep - gets the metadata for the dimension

 |       2)  Determines the Source System Codes for the load
 |       3)  Load Dimension Grps (of that dimension) -
 |              Pre-validation - identifies and updates bad records
 |              New Members - creates new dimension groups
 |              TL Update - updates the name/desc of groups
 |              Base Update - updates base properties of the groups
 |        4)  Load Dimension Members
 |              Pre-validation - identifies and updates bad records
 |              New Members - creates new dim members and their req. attr assignments
 |              TL Update - updates name/desc of members
 |              Base Update - updates base properties of members
 |              Pre-valid Attr - identifies bad optional attr records
 |              Attr Update - loads new optional attr assignments and updates existing
 |                  assignments
 |        5)  Engine_Master_Post - post error counts and PL status
 |
 |   SPECIAL NOTE:  The x_rows_loaded output variable is only populated if a
 |                  new member is created.  It does not represent the number of
 |                  rows loaded.  Rather, it is just serving as a flag to indicate
 |                  that at least one new member was created.  The other procedures
 |                  such as TL_UPDATE, BASE_UPDATE and ATTR_ASSIGN_UPDATE do not
 |                  populate this output value.
 |
 |
 |
 | MODIFICATION HISTORY
 |  Rob Flippo  21-OCT-03  Created
 |  Rob Flippo  08-SEP-04  Added condition on the MP Master return status so
 |                         that if no data slices found on Pre Validation, the
 |                         loader continues rather than terminating
 |  sshanmug    28-APR-05  Added Logic for Composite_dimension_loader
 |  Rob Flippo  31-MAY-05  Bug#3923485  Removed p_date_format_mask input parm
 |                         now using ICX: Date Format Mask profile option
 |  navekuma   26-APR-06  Bug#4736810. Added the call to get_mp_rows_rejected
 |                        after the call to MP engine for composite dimensions.
 +===========================================================================*/

PROCEDURE Load_Dimension (
  x_rows_rejected_accum        OUT NOCOPY NUMBER
  ,x_rows_to_load               OUT NOCOPY NUMBER
  ,p_execution_mode             IN       VARCHAR2
  ,p_object_id                 IN       NUMBER
  ,p_object_definition_id       IN       NUMBER
  ,p_dimension_varchar_label    IN       VARCHAR2
  ,p_master_request_id          IN       NUMBER
)

IS

-----------------------
-- Declare constants --
-----------------------
   c_proc_name                       VARCHAR2(30) := 'load_dimension_members';

   -- Constants for Dimension Group loading
   c_dimgrp_tbl_handler              VARCHAR2(30) := 'FEM_DIMENSION_GRPS_PKG';
   c_dimgrp_b_t_table                VARCHAR2(30) := 'FEM_DIMENSION_GRPS_B_T';
   c_dimgrp_tl_t_table               VARCHAR2(30) := 'FEM_DIMENSION_GRPS_TL_T';
   c_dimgrp_b_table                  VARCHAR2(30) := 'FEM_DIMENSION_GRPS_B';
   c_dimgrp_tl_table                 VARCHAR2(30) := 'FEM_DIMENSION_GRPS_TL';
   c_dimgrp_label                    VARCHAR2(30) := 'DIMENSION_GROUP';
   c_dimgrp_dc_col                   VARCHAR2(30) := 'DIMENSION_GROUP_DISPLAY_CODE';
   c_dimgrp_col                      VARCHAR2(30) := 'DIMENSION_GROUP_ID';
   c_dimgrp_name_col                 VARCHAR2(30) := 'DIMENSION_GROUP_NAME';
   c_dimgrp_desc_col                 VARCHAR2(30) := 'DESCRIPTION';
-----------------------
-- Declare variables --
-----------------------

----------------------------------------------------------
--  Variables for Object ID and Proces Locks Processing architecture
   v_object_id       NUMBER;
   v_object_definition_id NUMBER;
   v_num_msg         NUMBER; -- number of error messages on the stack
   v_completion_status VARCHAR2(30); -- return code for PL registration
                                 -- values are 'SUCCESS' and 'ERROR'
   v_eng_master_prep_status VARCHAR2(30) := 'SUCCESS';  -- return code for Engine Master Prep
                                                        -- values are 'SUCCESS' and 'ERROR'

   v_mp_prg_status VARCHAR2(30);
   v_mp_exception_code VARCHAR2(240);
   i                 NUMBER; -- counting variable for loops

   v_date_format_mask VARCHAR2(100);  -- result from FEM_INTF_ATTR_DATE_FORMAT_MASK for site

-- Common abbreviations:  dc = display_code
--                        _t = interface table
--                        mbr = member
--                        attr = attribute
--                        source = interface table
--                        target = FEM table

-- Variable designating whether we are loading Dimension Groups or Members
   v_load_type                       VARCHAR2(30);

-- These variables are retrieved as part of GET_DIMENSION_INFO
   v_dimension_id                    NUMBER;
   v_get_dim_status                  VARCHAR2(30);
   v_target_b_table                  VARCHAR2(30);
   v_target_tl_table                 VARCHAR2(30);
   v_target_attr_table               VARCHAR2(30);
   v_source_b_table                  VARCHAR2(30);
   v_source_tl_table                 VARCHAR2(30);
   v_source_attr_table               VARCHAR2(30);
   v_member_col                      VARCHAR2(30);
   v_member_dc_col                   VARCHAR2(30);
   v_member_t_dc_col                 VARCHAR2(30);
   v_member_name_col                 VARCHAR2(30);
   v_member_t_name_col               VARCHAR2(30);
   v_member_description_col          VARCHAR2(30);
   v_value_set_required_flag         VARCHAR2(1);
   v_simple_dimension_flag           VARCHAR2(1);
   v_shared_dimension_flag           VARCHAR2(1);
   v_hier_table_name                 VARCHAR2(30);
   v_hier_dimension_flag             VARCHAR2(1);
   v_member_id_method_code           VARCHAR2(30);
   v_user_defined_flag               VARCHAR2(1);
   v_table_handler_name              VARCHAR2(30);

-- These variables are needed for Composite Dimension Loader
   v_composite_dimension_flag        VARCHAR2(1);
   v_structure_id                    NUMBER;

-- variables storing temporary state information
   v_attr_success                    VARCHAR2(1);
   v_temp_member                     VARCHAR2(100);
   v_status                          NUMBER;
   v_message                         VARCHAR2(4000);
   v_rows_processed                  NUMBER :=0;
   v_rows_processed_accum            NUMBER :=0; -- running total
   v_rows_loaded                     NUMBER :=0; -- used as a placeholder for when
                                                 -- calling get_mp_rows_rejected;  The value
                                                 -- is only meaningful for identifying if
                                                 -- >0 new members were created - otherwise
                                                 -- it is ignored
   v_rows_loaded_accum               NUMBER :=0; -- running total
   v_rows_rejected                   NUMBER :=0;
   v_rows_rejected_accum             NUMBER :=0; -- running total

-- Dynamic SQL statement variables
   x_src_sys_select_stmt             VARCHAR2(4000);

-- Count variables for manipulating the member and attribute arrays
   v_src_sys_last_row                NUMBER;

-- STATUS clause for all WHERE conditions
   v_exec_mode_clause VARCHAR2(100);

---------------------
-- Declare cursors --
---------------------
   cv_get_src_sys        cv_curs;  -- Retreives Source System Codes for the load


/**************************************************************************
*                                                                         *
*                          Load Dimension                                 *
*                          Execution Block                                *
*                                                                         *
**************************************************************************/

BEGIN
   v_object_definition_id := p_object_definition_id;
   IF v_object_definition_id IS NULL THEN
      v_object_definition_id := 1200;
   END IF;

   -- initialize the dimension group error count
   gv_dimgrp_rows_rejected := 0;

   -----------------------------------------------------------------------------
   -- populate the composite dimension information
   -- Needed for composite dimension loader
   -----------------------------------------------------------------------------

   IF p_dimension_varchar_label IN ('ACTIVITY','COST_OBJECT') THEN
     BEGIN

       SELECT composite_dimension_flag,id_flex_num
       INTO  v_composite_dimension_flag,v_structure_id
       FROM Fem_XDim_Dimensions_VL
       WHERE dimension_varchar_label = p_dimension_varchar_label;

     EXCEPTION

       WHEN no_data_found THEN
	     fem_engines_pkg.tech_message (
             p_severity  => c_log_level_4
	         ,p_module   => c_block||'.'||c_proc_name||'.Comp Dim Params not found'
             ,p_msg_text => 'Dimension'||p_dimension_varchar_label||
							'Code'||SQLCODE||'Err'||SQLERRM);
	     RAISE e_main_terminate;
     END;
   END IF;



   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_3,c_block||'.'||c_proc_name||'.Preparation','Get dimension information');
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.p_dimension_varchar_label',p_dimension_varchar_label);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.c_user_id',c_user_id);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.v_obj_def_id',v_object_definition_id);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.p_object_id',p_object_id);

   Engine_Master_Prep (p_dimension_varchar_label
                      ,v_object_definition_id
                      ,p_execution_mode
                      ,v_dimension_id
                      ,v_target_b_table
                      ,v_target_tl_table
                      ,v_target_attr_table
                      ,v_source_b_table
                      ,v_source_tl_table
                      ,v_source_attr_table
                      ,v_member_col
                      ,v_member_dc_col
                      ,v_member_t_dc_col
                      ,v_member_name_col
                      ,v_member_t_name_col
                      ,v_member_description_col
                      ,v_value_set_required_flag
                      ,v_user_defined_flag
                      ,v_simple_dimension_flag
                      ,v_shared_dimension_flag
                      ,v_table_handler_name
                      ,v_composite_dimension_flag
                      ,v_structure_id
                      ,v_exec_mode_clause
                      ,v_eng_master_prep_status
                      ,v_hier_table_name
                      ,v_hier_dimension_flag
                      ,v_member_id_method_code
                      ,x_rows_to_load
                      ,v_date_format_mask
                      );

   IF v_eng_master_prep_status IN ('ERROR') THEN
      RAISE e_terminate;
   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.source_b_table ',v_source_b_table);

  ------------------------------------------------------------------------------
  --Composite Dimensions dont have _TL and _ATTR tables.
  ------------------------------------------------------------------------------

  IF v_composite_dimension_flag = 'N' THEN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.source_tl_table ',v_source_tl_table);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.source_attr_table ',v_source_attr_table);
  END IF;


   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.value_set_required_flag ',v_value_set_required_flag);
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.table handler ',v_table_handler_name);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.v_exec_mode_clause ',v_exec_mode_clause);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.v_date_format_mask ',v_date_format_mask);

  -- The following are not needed composite dimension

  IF v_composite_dimension_flag = 'N' THEN

      ------------------------------------------------------------------------------
      -- Preparation STEP:  Determing the Source System Codes in the load
      ------------------------------------------------------------------------------
      IF v_simple_dimension_flag = 'N' THEN

          FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||
           '.Preparation STEP','Determing Source System Codes for the load');
         build_src_sys_select_stmt (p_dimension_varchar_label
                                   ,v_source_attr_table
                                   ,v_shared_dimension_flag
                                   ,x_src_sys_select_stmt);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.Preparation.src_sys_select_stmt',x_src_sys_select_stmt);
         OPEN cv_get_src_sys FOR x_src_sys_select_stmt;
         FETCH cv_get_src_sys BULK COLLECT INTO
               tg_src_system_dc;
            v_src_sys_last_row := tg_src_system_dc.LAST;
            FEM_ENGINES_PKG.TECH_MESSAGE
            (c_log_level_1,c_block||'.'||c_proc_name||'.Source_System_Step.v_src_sys_last_row'
            ,v_src_sys_last_row);
      END IF;  -- src system selection

      IF (v_hier_dimension_flag = 'Y') THEN
         ------------------------------------------------------------------------------
         -- Load Dimension Groups
         ------------------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||
           '.Dimension Groups','Starting the Dimension Group load section');
         v_load_type := 'DIMENSION_GROUP';

         ------------------------------------------------------------------------------
         -- Pre_Validation
         -- This step identifies new Dimension Groups missing TL records
         ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name||'.Start Grp Pre_Validation',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         Pre_Validation (P_ENG_SQL => null
                        ,P_DATA_SLC => null
                        ,P_PROC_NUM => null
                        ,P_PARTITION_CODE => null
                        ,P_FETCH_LIMIT => null
                        ,P_LOAD_TYPE => v_load_type
                        ,P_DIMENSION_VARCHAR_LABEL => p_dimension_varchar_label
                        ,P_DIMENSION_ID => v_dimension_id
                        ,P_SOURCE_B_TABLE => c_dimgrp_b_t_table
                        ,P_SOURCE_TL_TABLE => c_dimgrp_tl_t_table
                        ,P_SOURCE_ATTR_TABLE => null
                        ,P_TARGET_B_TABLE => c_dimgrp_b_table
                        ,P_MEMBER_T_DC_COL => c_dimgrp_dc_col
                        ,P_MEMBER_DC_COL => c_dimgrp_dc_col
                        ,P_VALUE_SET_REQUIRED_FLAG => 'N'
                        ,P_SIMPLE_DIMENSION_FLAG => 'Y'
                        ,P_SHARED_DIMENSION_FLAG => 'N'
                        ,P_EXEC_MODE_CLAUSE => v_exec_mode_clause
                        ,P_MASTER_REQUEST_ID => p_master_request_id);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.gv_dimgrp_rows_rejected',gv_dimgrp_rows_rejected);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Grp Pre_Valdation',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


         ------------------------------------------------------------------------------
         -- New Dimension Groups
         ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name||'.Start Grp New_Members',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         New_Members (P_ENG_SQL => null
                     ,P_DATA_SLC => null
                     ,P_PROC_NUM => null
                     ,P_PARTITION_CODE => null
                     ,P_FETCH_LIMIT => null
                     ,P_LOAD_TYPE => v_load_type
                     ,P_DIMENSION_VARCHAR_LABEL => p_dimension_varchar_label
                     ,P_DATE_FORMAT_MASK => v_date_format_mask
                     ,P_DIMENSION_ID => v_dimension_id
                     ,P_TARGET_B_TABLE => c_dimgrp_b_table
                     ,P_TARGET_TL_TABLE => c_dimgrp_tl_table
                     ,P_TARGET_ATTR_TABLE => null
                     ,P_SOURCE_B_TABLE => c_dimgrp_b_t_table
                     ,P_SOURCE_TL_TABLE => c_dimgrp_tl_t_table
                     ,P_SOURCE_ATTR_TABLE => null
                     ,P_TABLE_HANDLER_NAME => c_dimgrp_tbl_handler
                     ,P_MEMBER_COL => c_dimgrp_col
                     ,P_MEMBER_DC_COL => c_dimgrp_dc_col
                     ,P_MEMBER_NAME_COL => c_dimgrp_name_col
                     ,P_MEMBER_T_DC_COL => c_dimgrp_dc_col
                     ,P_MEMBER_T_NAME_COL => c_dimgrp_name_col
                     ,P_MEMBER_DESCRIPTION_COL => c_dimgrp_desc_col
                     ,P_VALUE_SET_REQUIRED_FLAG => 'N'
                     ,P_SIMPLE_DIMENSION_FLAG => 'Y'
                     ,P_SHARED_DIMENSION_FLAG => 'N'
                     ,P_HIER_DIMENSION_FLAG => 'N'
                     ,P_MEMBER_ID_METHOD_CODE => 'FUNCTION'
                     ,P_EXEC_MODE_CLAUSE => v_exec_mode_clause
                     ,P_MASTER_REQUEST_ID => p_master_request_id);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.gv_dimgrp_rows_rejected',gv_dimgrp_rows_rejected);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Grp New_Members',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         ------------------------------------------------------------------------------
         -- Update Name/Descriptions for existing Members
         ------------------------------------------------------------------------------
      FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name||'.Start Grp TL_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         TL_Update (P_ENG_SQL => null
                   ,P_DATA_SLC => null
                   ,P_PROC_NUM => null
                   ,P_PARTITION_CODE => null
                   ,P_FETCH_LIMIT => null
                   ,P_LOAD_TYPE => v_load_type
                   ,P_DIMENSION_VARCHAR_LABEL => p_dimension_varchar_label
                   ,P_DIMENSION_ID => v_dimension_id
                   ,P_TARGET_B_TABLE => c_dimgrp_b_table
                   ,P_TARGET_TL_TABLE => c_dimgrp_tl_table
                   ,P_SOURCE_B_TABLE => c_dimgrp_b_t_table
                   ,P_SOURCE_TL_TABLE => c_dimgrp_tl_t_table
                   ,P_MEMBER_COL => c_dimgrp_col
                   ,P_MEMBER_DC_COL => c_dimgrp_dc_col
                   ,P_MEMBER_NAME_COL => c_dimgrp_name_col
                   ,P_MEMBER_T_DC_COL => c_dimgrp_dc_col
                   ,P_MEMBER_T_NAME_COL => c_dimgrp_name_col
                   ,P_MEMBER_DESCRIPTION_COL => c_dimgrp_desc_col
                   ,P_VALUE_SET_REQUIRED_FLAG => 'N'
                   ,P_SIMPLE_DIMENSION_FLAG => 'Y'
                   ,P_SHARED_DIMENSION_FLAG => 'N'
                   ,P_HIER_DIMENSION_FLAG => 'N'
                   ,P_EXEC_MODE_CLAUSE => v_exec_mode_clause
                   ,P_MASTER_REQUEST_ID => p_master_request_id);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.gv_dimgrp_rows_rejected',gv_dimgrp_rows_rejected);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Grp TL_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         ----------------------------------------------------------------------------------
         --  Base_Update
         ----------------------------------------------------------------------------------
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Grp Base_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         Base_Update (P_ENG_SQL => null
                     ,P_DATA_SLC => null
                     ,P_PROC_NUM => null
                     ,P_PARTITION_CODE => null
                     ,P_FETCH_LIMIT => null
                     ,P_LOAD_TYPE => v_load_type
                     ,P_DIMENSION_VARCHAR_LABEL => p_dimension_varchar_label
                     ,P_SIMPLE_DIMENSION_FLAG => 'N'
                     ,P_SHARED_DIMENSION_FLAG => 'N'
                     ,P_DIMENSION_ID => v_dimension_id
                     ,P_VALUE_SET_REQUIRED_FLAG => 'N'
                     ,P_HIER_TABLE_NAME => null
                     ,P_HIER_DIMENSION_FLAG => 'N'
                     ,P_SOURCE_B_TABLE => c_dimgrp_b_t_table
                     ,P_TARGET_B_TABLE => c_dimgrp_b_table
                     ,P_MEMBER_DC_COL => c_dimgrp_dc_col
                     ,P_MEMBER_T_DC_COL => c_dimgrp_dc_col
                     ,P_MEMBER_COL => c_dimgrp_col
                     ,P_EXEC_MODE_CLAUSE => v_exec_mode_clause
                     ,P_MASTER_REQUEST_ID => p_master_request_id);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.gv_dimgrp_rows_rejected',gv_dimgrp_rows_rejected);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Grp Base_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

      END IF; -- Dimension Group Processing only happens for v_hier_dimension_flag = 'Y'
         v_rows_rejected_accum :=  gv_dimgrp_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);

      ------------------------------------------------------------------------------
      -- Load Dimension Members
      ------------------------------------------------------------------------------
       FEM_ENGINES_PKG.TECH_MESSAGE
       (c_log_level_3,c_block||'.'||c_proc_name||
        '.Dimension Members','Starting the Dimension Member load section');

      v_load_type := 'DIMENSION_MEMBER';
      ------------------------------------------------------------------------------
      -- Pre_Validation
      -- This step identifies new members missing TL records
      ------------------------------------------------------------------------------

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr Pre_Validation',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_b_table
         ,P_ENG_SQL => null
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'Pre_Validation'
         ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Pre_Validation'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
         ,P_ARG1 => v_load_type
         ,P_ARG2 => p_dimension_varchar_label
         ,P_ARG3 => v_dimension_id
         ,P_ARG4 => v_source_b_table
         ,P_ARG5 => v_source_tl_table
         ,P_ARG6 => v_source_attr_table
         ,P_ARG7 => v_target_b_table
         ,P_ARG8 => v_member_t_dc_col
         ,P_ARG9 => v_member_dc_col
         ,P_ARG10 => v_value_set_required_flag
         ,P_ARG11 => v_simple_dimension_flag
         ,P_ARG12 => v_shared_dimension_flag
         ,P_ARG13 => v_exec_mode_clause
         ,P_ARG14 => p_master_request_id);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_pgr_status',v_mp_prg_status);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_exception_code',v_mp_exception_code);

         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;

         -- accumulate rejected row count
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Mbr Pre_Validation',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);


      ------------------------------------------------------------------------------
      -- New Dimension Members
      ------------------------------------------------------------------------------

         -- truncate the INTERIM tables in preparation for CALP processing
         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            truncate_calp_interim;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr New_Members',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));


         fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_b_table
         ,P_ENG_SQL => null
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'New_Members'
         ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.New_Members'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
         ,P_ARG1 => v_load_type
         ,P_ARG2 => p_dimension_varchar_label
         ,P_ARG3 => v_date_format_mask
         ,P_ARG4 => v_dimension_id
         ,P_ARG5 => v_target_b_table
         ,P_ARG6 => v_target_tl_table
         ,P_ARG7 => v_target_attr_table
         ,P_ARG8 => v_source_b_table
         ,P_ARG9 => v_source_tl_table
         ,P_ARG10 => v_source_attr_table
         ,P_ARG11 => v_table_handler_name
         ,P_ARG12 => v_member_col
         ,P_ARG13 => v_member_dc_col
         ,P_ARG14 => v_member_name_col
         ,P_ARG15 => v_member_t_dc_col
         ,P_ARG16 => v_member_t_name_col
         ,P_ARG17 => v_member_description_col
         ,P_ARG18 => v_value_set_required_flag
         ,P_ARG19 => v_simple_dimension_flag
         ,P_ARG20 => v_shared_dimension_flag
         ,P_ARG21 => v_hier_dimension_flag
         ,P_ARG22 => v_member_id_method_code
         ,P_ARG23 => v_exec_mode_clause
         ,P_ARG24 => p_master_request_id
         );
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_exception',v_mp_exception_code);


         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;
         -- accumulate rejected row count
         v_rows_loaded := 0;  -- initializing this variable so we can use it to
                              -- figure out if any new members were created
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_loaded',v_rows_loaded);

         IF v_rows_loaded > 0 THEN
            raise_member_bus_event (p_dimension_varchar_label);
         END IF;

         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Mbr New_Members',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Overlap Processing',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));
         --------------------------------------------------------------
         -- Perform the Date Overlap Check for CAL_PERIOD loads
         -- and move all valid new members into FEM
         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            calp_date_overlap_check(v_rows_rejected
                                    ,'NEW_MEMBERS');
            v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;

            fem_multi_proc_pkg.MASTER
            (X_PRG_STAT => v_mp_prg_status
            ,X_EXCEPTION_CODE => v_mp_exception_code
            ,P_RULE_ID => p_object_id
            ,P_ENG_STEP => 'ALL'
            ,P_DATA_TABLE => 'FEM_CALP_INTERIM_T'
            ,P_ENG_SQL => null
            ,P_TABLE_ALIAS => 'B'
            ,P_RUN_NAME => 'Post_Cal_Periods'
            ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Post_Cal_Periods'
            ,P_CONDITION => null
            ,P_FAILED_REQ_ID => null
            ,P_ARG1 => 'NEW_MEMBERS'
            ,P_ARG2 => p_master_request_id);

            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_exception',v_mp_exception_code);

            IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
              IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
                 null;
              ELSE
                 RAISE e_terminate;
              END IF;
            END IF;

            -- accumulate rejected row count
            get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
            v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||
              '.v_rows_rejected_accum',v_rows_rejected_accum);

            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Overlap Processing',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         END IF; -- overlap check for CAL_PERIOD load
         --------------------------------------------------------------


      ----------------------------------------------------------------------------------
      --  Base_Update
      ----------------------------------------------------------------------------------


         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr Base_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

            fem_multi_proc_pkg.MASTER
            (X_PRG_STAT => v_mp_prg_status
            ,X_EXCEPTION_CODE => v_mp_exception_code
            ,P_RULE_ID => p_object_id
            ,P_ENG_STEP => 'ALL'
            ,P_DATA_TABLE => v_source_b_table
            ,P_ENG_SQL => null
            ,P_TABLE_ALIAS => 'B'
            ,P_RUN_NAME => 'Base_Update'
            ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Base_Update'
            ,P_CONDITION => null
            ,P_FAILED_REQ_ID => null
            ,P_ARG1 => v_load_type
            ,P_ARG2 => p_dimension_varchar_label
            ,P_ARG3 => v_simple_dimension_flag
            ,P_ARG4 => v_shared_dimension_flag
            ,P_ARG5 => v_dimension_id
            ,P_ARG6 => v_value_set_required_flag
            ,P_ARG7 => v_hier_table_name
            ,P_ARG8 => v_hier_dimension_flag
            ,P_ARG9 => v_source_b_table
            ,P_ARG10 => v_target_b_table
            ,P_ARG11 => v_member_dc_col
            ,P_ARG12 => v_member_t_dc_col
            ,P_ARG13 => v_member_col
            ,P_ARG14 => v_exec_mode_clause
            ,P_ARG15 => p_master_request_id
            );
         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Mbr Base_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         -- accumulate rejected row count
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);
      --END IF; -- simple dim = 'N' (for Base Update)

      ------------------------------------------------------------------------------
      -- Update Name/Descriptions for existing Members
      ------------------------------------------------------------------------------

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr TL_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_tl_table
         ,P_ENG_SQL => null
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'TL_Update'
         ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.TL_Update'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
         ,P_ARG1 => v_load_type
         ,P_ARG2 => p_dimension_varchar_label
         ,P_ARG3 => v_dimension_id
         ,P_ARG4 => v_target_b_table
         ,P_ARG5 => v_target_tl_table
         ,P_ARG6 => v_source_b_table
         ,P_ARG7 => v_source_tl_table
         ,P_ARG8 => v_member_col
         ,P_ARG9 => v_member_dc_col
         ,P_ARG10 => v_member_name_col
         ,P_ARG11 => v_member_t_dc_col
         ,P_ARG12 => v_member_t_name_col
         ,P_ARG13 => v_member_description_col
         ,P_ARG14 => v_value_set_required_flag
         ,P_ARG15 => v_simple_dimension_flag
         ,P_ARG16 => v_shared_dimension_flag
         ,P_ARG17 => v_hier_dimension_flag
         ,P_ARG18 => v_exec_mode_clause
         ,P_ARG19 => p_master_request_id
         );
         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Mbr TL_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         -- accumulate rejected row count
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);

      ------------------------------------------------------------------------------
      -- Pre_Validation_Attr
      --This step identifies bad attr records (only run for Simple_dim='N'
      ------------------------------------------------------------------------------
      IF (v_simple_dimension_flag = 'N') THEN
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr Pre_Validation_Attr',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_attr_table
         ,P_ENG_SQL => null
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'Pre_Validation_Attr'
         ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Pre_Validation_Attr'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
         ,P_ARG1 => v_load_type
         ,P_ARG2 => p_dimension_varchar_label
         ,P_ARG3 => v_dimension_id
         ,P_ARG4 => v_source_b_table
         ,P_ARG5 => v_source_tl_table
         ,P_ARG6 => v_source_attr_table
         ,P_ARG7 => v_target_b_table
         ,P_ARG8 => v_member_t_dc_col
         ,P_ARG9 => v_member_dc_col
         ,P_ARG10 => v_value_set_required_flag
         ,P_ARG11 => v_simple_dimension_flag
         ,P_ARG12 => v_shared_dimension_flag
         ,P_ARG13 => v_hier_dimension_flag
         ,P_ARG14 => v_exec_mode_clause
         ,P_ARG15 => p_master_request_id
         );
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_exception',v_mp_exception_code);

         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Mbr Pre_Validation_Attr',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         -- accumulate rejected row count
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);

      ----------------------------------------------------------------------------------
      --  Update attributes
      ----------------------------------------------------------------------------------

         -- truncate the INTERIM tables in preparation for CALP processing
         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            truncate_calp_interim;
         END IF;

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Start Mbr Attr_Assign_Update',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_attr_table
         ,P_ENG_SQL => null
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'Attr_Assign_Update'
         ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Attr_Assign_Update'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
--         ,P_REUSE_SLICES => 'R'
         ,P_ARG1 => p_dimension_varchar_label
         ,P_ARG2 => v_date_format_mask
         ,P_ARG3 => v_dimension_id
         ,P_ARG4 => v_target_b_table
         ,P_ARG5 => v_target_attr_table
         ,P_ARG6 => v_source_b_table
         ,P_ARG7 => v_source_attr_table
         ,P_ARG8 => v_member_col
         ,P_ARG9 => v_member_dc_col
         ,P_ARG10 => v_member_t_dc_col
         ,P_ARG11 => v_value_set_required_flag
         ,P_ARG12 => v_hier_dimension_flag
         ,P_ARG13 => v_simple_dimension_flag
         ,P_ARG14 => v_shared_dimension_flag
         ,P_ARG15 => v_exec_mode_clause
         ,P_ARG16 => p_master_request_id
         );
         IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
           IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
              null;
           ELSE
              RAISE e_terminate;
           END IF;
         END IF;

         -- accumulate rejected row count
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.v_rows_rejected_accum',v_rows_rejected_accum);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Attr_Assign',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_3,c_block||'.'||c_proc_name||'.Begin Attr Overlap Processing',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         --------------------------------------------------------------
         -- Perform the Date Overlap Check for CAL_PERIOD loads
         -- and update valid START_DATE attributes in FEM
         IF p_dimension_varchar_label = 'CAL_PERIOD' THEN
            calp_date_overlap_check(v_rows_rejected
                                    ,'ATTR_ASSIGN_UPDATE');
            v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;

            fem_multi_proc_pkg.MASTER
            (X_PRG_STAT => v_mp_prg_status
            ,X_EXCEPTION_CODE => v_mp_exception_code
            ,P_RULE_ID => p_object_id
            ,P_ENG_STEP => 'ALL'
            ,P_DATA_TABLE => v_source_attr_table
            ,P_ENG_SQL => null
            ,P_TABLE_ALIAS => 'B'
            ,P_RUN_NAME => 'Post_Cal_Periods'
            ,P_ENG_PRG => 'FEM_DIM_MEMBER_LOADER_PKG.Post_Cal_Periods'
            ,P_CONDITION => null
            ,P_FAILED_REQ_ID => null
            ,P_ARG1 => 'ATTR_ASSIGN_UPDATE'
            ,P_ARG2 => p_master_request_id);

            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||'.v_mp_exception',v_mp_exception_code);

            IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN
              IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN
                 null;
              ELSE
                 RAISE e_terminate;
              END IF;
            END IF;
            -- accumulate rejected row count
            get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
            v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_1,c_block||'.'||c_proc_name||
              '.v_rows_rejected_accum',v_rows_rejected_accum);
            FEM_ENGINES_PKG.TECH_MESSAGE
             (c_log_level_3,c_block||'.'||c_proc_name||'.Finish Attr Overlap Processing',to_char(sysdate,'MM/DD/YYY:HH:MI:SS'));

         END IF; -- overlap check for CAL_PERIOD load

         --------------------------------------------------------------

      END IF; -- Simple Dimension Flag = 'N' (for Attr validation and Attr Update)

      ----------------------------------------------------------------------------------
      --  Post Dimension Member load status to FEM_DIM_LOAD_STATUS
      ----------------------------------------------------------------------------------
      IF v_simple_dimension_flag = 'N' THEN
         v_src_sys_last_row := NVL(tg_src_system_dc.LAST,0);
         FEM_ENGINES_PKG.TECH_MESSAGE
         (c_log_level_1,c_block||'.'||c_proc_name||'.Step10.v_src_sys_last_row'
         ,v_src_sys_last_row);

            FOR i IN 1..v_src_sys_last_row
            LOOP
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.Step10.tg_src_system_dc'
               ,tg_src_system_dc(i));

               Post_dim_status (v_dimension_id
                               ,tg_src_system_dc(i)
                               ,v_source_attr_table);
            END LOOP;
      END IF; -- src_system Post_dim_status

      x_rows_rejected_accum := v_rows_rejected_accum;
         FEM_ENGINES_PKG.TECH_MESSAGE
          (c_log_level_1,c_block||'.'||c_proc_name||
           '.x_rows_rejected_accum',x_rows_rejected_accum);

      -----------------------------------------------------------------------------------
      -- Close any open cursors
      -----------------------------------------------------------------------------------
      IF cv_get_src_sys%ISOPEN THEN
         CLOSE cv_get_src_sys;
      END IF;


      --------------------------------------------------------------------------
      -- The following piece of code is for loading
      -- Composite Dimensions
      --------------------------------------------------------------------------


    ELSIF v_composite_dimension_flag = 'Y' THEN


      fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_2
	             ,p_module   => c_block||'.'||c_proc_name||'.Before Process_Rows'
                 ,p_msg_text => 'Calling Process_Rows via MP Framework');

      --------------------------------------------------------------------------
      -- This procedure calls the MP Engine for the proc 'Process_rows'
      --------------------------------------------------------------------------

      fem_multi_proc_pkg.MASTER
         (X_PRG_STAT => v_mp_prg_status
         ,X_EXCEPTION_CODE => v_mp_exception_code
         ,P_RULE_ID => p_object_id
         ,P_ENG_STEP => 'ALL'
         ,P_DATA_TABLE => v_source_b_table
         ,P_ENG_SQL => g_select_statement
         ,P_TABLE_ALIAS => 'B'
         ,P_RUN_NAME => 'Process_Rows'
         ,P_ENG_PRG => 'FEM_COMP_DIM_MEMBER_LOADER_PKG.Process_Rows'
         ,P_CONDITION => null
         ,P_FAILED_REQ_ID => null
         ,P_ARG1 => p_dimension_varchar_label
         ,P_ARG2 => p_execution_mode
         ,P_ARG3 => v_structure_id
         ,P_ARG4 => p_master_request_id);
         --Bug#4736810
         get_mp_rows_rejected (v_rows_rejected, v_rows_loaded);
         v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
         x_rows_rejected_accum := v_rows_rejected_accum;

     fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_5
	             ,p_module   => c_block||'.'||c_proc_name||'.After Process_Rows'
                 ,p_msg_text => 'Process_Rows Status '||v_mp_prg_status||
				 'Process_Rows Err Code '||v_mp_exception_code);

      --------------------------------------------------------------------------
      -- Check for the MP error message from process_rows
      --------------------------------------------------------------------------

          IF v_mp_prg_status NOT IN ('COMPLETE:NORMAL') THEN

		   IF v_mp_exception_code IN ('FEM_MP_NO_DATA_SLICES_ERR') THEN

			 fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_1
	             ,p_module   => c_block||'.'||c_proc_name||'.After Process_Rows'
                 ,p_msg_text => 'Process_Rows Error '||v_mp_exception_code);

           ELSE

              RAISE e_terminate;

           END IF;

         END IF;


	  fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_1
	             ,p_module   => c_block||'.'||c_proc_name||'.After Process_Rows'
                 ,p_msg_text => 'End of Process_Rows');

  END IF;


      --COMMIT;



--------------------------------------------------------------------------------
--            Load Dimension
--            Exception Block
--------------------------------------------------------------------------------

EXCEPTION
   WHEN e_terminate THEN

       fem_engines_pkg.tech_message(
	             p_severity  => c_log_level_4
	             ,p_module   => c_block||'.'||c_proc_name||'. Load_Dimension'
                 ,p_msg_text => 'Process_Rows Error '||v_mp_exception_code);

       RAISE e_main_terminate;

   WHEN e_exec_lock_exists THEN
         gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
         IF v_num_msg > 0 THEN
            FOR i IN 1 .. v_num_msg LOOP
               FEM_ENGINES_PKG.User_Message
                 (p_msg_text => FND_MSG_PUB.Get(p_encoded => 'F'));
            END LOOP;
         END IF;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_5
       ,p_module => c_block||'.'||c_proc_name||'.Exception'
       ,p_app_name => c_fem
       ,p_msg_name => G_EXEC_LOCK_EXISTS
       ,P_TOKEN1 => 'OBJECT_ID'
       ,P_VALUE1 => v_object_id);

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_EXEC_LOCK_EXISTS
       ,P_TOKEN1 => 'OBJECT_ID'
       ,P_VALUE1 => v_object_id);


   WHEN OTHERS THEN
      gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
      gv_prg_msg := sqlerrm;
      gv_callstack := dbms_utility.format_call_stack;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_prg_msg);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_callstack);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
       ,P_TOKEN1 => 'ERR_MSG'
       ,P_VALUE1 => gv_prg_msg);

    --  FEM_ENGINES_PKG.USER_MESSAGE
    --   (p_app_name => c_fem
    --   ,p_msg_text => gv_prg_msg);

      RAISE e_main_terminate;

END Load_Dimension;



/*===========================================================================+
 | PROCEDURE
 |                 Main
 |
 | DESCRIPTION
 |                 Main engine procedure for loading dimension members
 |                 and attribute assignments into FEM
 |
 |
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |    This procedure is called by Concurrent Manager when the loader is launched
 |    It performs the following:
 |       1)  Validates the parameters passed by CM
 |       2)  Obtains the associated object_Definition_id and dimension_Varchar_label
 |            for the dimension_id passed in as a parm
 |       3)  Registers the Process Execution
 |       4)  Loads the dimension
 |
 | HISTORY
 |    5/31/2005 Rob Flippo  Bug#3923485  Removed p_date_format_mask input parm
 |                          now using ICX: Date Format Mask profile option
 ===========================================================================*/
PROCEDURE Main (
   errbuf                       OUT NOCOPY     VARCHAR2
  ,retcode                      OUT NOCOPY     VARCHAR2
  ,p_execution_mode             IN       VARCHAR2
  ,p_dimension_id               IN       NUMBER
)

IS

   -- Nested Procedure declarations
   PROCEDURE Get_Object_Def (p_dimension_id              IN       NUMBER
                            ,x_object_definition_id       OUT NOCOPY NUMBER
                            ,x_dimension_varchar_label  OUT NOCOPY VARCHAR2);

   -- Constants for body of Main
   c_proc_name VARCHAR2(30) := 'Main';

   -- Variables for body of Main
   v_completion_status VARCHAR2(30);
   v_object_id NUMBER(9);
   v_object_definition_id NUMBER(9);
   v_dimension_varchar_label VARCHAR2(30);
   v_pl_status VARCHAR2(30);
   v_rows_rejected NUMBER :=0;
   v_rows_rejected_accum NUMBER :=0;
   v_rows_to_load NUMBER :=0;
   v_rows_to_load_accum NUMBER :=0;
   v_bulk_rows_rejected NUMBER :=0;

   v_obj_def_display_name VARCHAR2(150);  -- used when terminating and want to show
                                          -- the type of load in the log

   /*************************************************
   obsolete variables
   -- these are variables for counting from fem_simple_dims_b_t/tl_t
   -- to see if there are any rows for loading
   v_source_b_count NUMBER :=0;
   v_source_tl_count NUMBER :=0;
   v_source_count_accum NUMBER :=0;

   -- Variables to determine valid Simple Dimensions for loading
   -- when loading from the Object = "Simple Dimensions"
   v_hier_editor_managed_flag VARCHAR2(1);
   v_xdim_read_only_flag VARCHAR2(1);
   v_value_set_required_flag VARCHAR2(1);
   v_simple_dimension_flag VARCHAR2(1);
   ****************************************************/

   v_msg_count NUMBER;
   v_sec_folder_count NUMBER;  -- used to see if user has privs to the Integrations folder
   v_msg_data VARCHAR2(4000);
   v_API_return_status VARCHAR2(30);
   v_sec_folder_name VARCHAR2(150); -- folder name that the user must have privs in

   ----------------------------------------------------------------
   -- Nested Procedure bodies
   ----------------------------------------------------------------

   -- Get_Object Def
   --   This procedure gets Object Definition associated with the dimension.
   --   Each dimension has a hard-coded associated object_definition where the
   --   MP settings are located.
   --   This procedure also gets the Dimension Varchar label for the dimension
   --   being loaded so that we can use that to identify the dimension in the code
   --   rather than the _ID
   --
   PROCEDURE Get_Object_Def (p_dimension_id          IN         NUMBER
                            ,x_object_definition_id  OUT NOCOPY NUMBER
                            ,x_dimension_varchar_label OUT NOCOPY VARCHAR2)

   IS

   BEGIN

      BEGIN
         SELECT loader_object_def_id, dimension_varchar_label
         INTO x_object_definition_id, x_dimension_varchar_label
         FROM fem_xdim_dimensions_vl
         WHERE dimension_id = p_dimension_id;

         IF x_object_definition_id IS NULL THEN
            RAISE e_dim_load_not_enabled;
         END IF;
      EXCEPTION
         WHEN no_data_found THEN
            raise e_dimension_not_found;
      END;
   EXCEPTION
      WHEN e_dimension_not_found THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_FOUND);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_DIM_NOT_FOUND);

         RAISE e_main_terminate;

      WHEN e_dim_load_not_enabled THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_SIMPLE_DIM);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_SIMPLE_DIM);

         RAISE e_main_terminate;


   END Get_Object_Def;

---------------------------------------------------------------------------
--  Main body of the "Main" procedure
---------------------------------------------------------------------------
BEGIN

   -- Get the OBject Definition ID and the label of the dimension_id to be loaded
   Get_Object_Def (p_dimension_id
                  ,v_object_definition_id
                  ,v_dimension_varchar_label);

   -- Get Object ID
   BEGIN
      SELECT object_id
      INTO v_object_id
      FROM fem_object_definition_b
      WHERE object_definition_id = v_object_definition_id
      AND object_id IN (SELECT object_id FROM fem_object_catalog_b
      WHERE object_type_code = 'DIM_MEMBER_LOADER');
   EXCEPTION
      WHEN no_data_found THEN
         RAISE e_invalid_obj_def;
   END;
   -----------------------------------------------------
   --  Validate Security - does user have privs to the Integrations folder
   -----------------------------------------------------
   SELECT count(*)
   INTO v_sec_folder_count
   FROM fem_user_folders
   WHERE user_id=c_user_id
   AND folder_id=1000;

   IF v_sec_folder_count = 0 THEN
      RAISE e_no_folder_privs;
   END IF;



   -----------------------------------------------------
   --  Validate the execution mode
   -----------------------------------------------------
   IF p_execution_mode NOT IN ('S','E') THEN
      RAISE e_invalid_exec_mode;
   END IF;
   -----------------------------------------------------


   Register_process_execution (v_object_id
                              ,v_object_definition_id
                              ,p_execution_mode
                              ,v_completion_status);

   IF v_pl_status IN ('ERROR') THEN
      raise e_pl_registration_failed;
   END IF;

   Load_Dimension (
      v_rows_rejected
     ,v_rows_to_load
     ,p_execution_mode
     ,v_object_id
     ,v_object_definition_id
     ,v_dimension_varchar_label
     ,gv_request_id);

      v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
      v_rows_to_load_accum := v_rows_to_load_accum + v_rows_to_load;


         /*****************************************************************
         Obsolete code for updating rows in a shared interface table
         when the dimension is invalid.  In this case, we are not
         updating the records with a STATUS
         FOR dim IN cv_dimension LOOP
            v_dimension_varchar_label := dim.dimension_varchar_label;
               FEM_ENGINES_PKG.TECH_MESSAGE
               (c_log_level_1,c_block||'.'||c_proc_name||'.dimension'
               ,v_dimension_varchar_label);


            -- Only process simple dims that are Value Set = N and
            -- Hier Edtitor Managed Flag = 'Y'.  All other records
            -- in FEM_SIMPLE_DIMS_B_T/TL_T will be updated with
            -- INVALID_SIMPLE_DIM status
            BEGIN
               SELECT X.hier_editor_managed_flag
               ,X.read_only_flag
               ,X.value_set_required_flag
               ,X.simple_dimension_flag
               INTO v_hier_editor_managed_flag
               ,v_xdim_read_only_flag
               ,v_value_set_required_flag
               ,v_simple_dimension_flag
               FROM fem_xdim_dimensions X, fem_dimensions_b B
               WHERE B.dimension_varchar_label = v_dimension_varchar_label
               AND B.dimension_id = X.dimension_id;
            EXCEPTION
               WHEN no_data_found THEN
                  v_simple_dimension_flag := 'N';
                  v_value_set_required_flag := 'N';
                  v_xdim_read_only_flag := 'Y';
                  v_hier_editor_managed_flag := 'N';

            END; -- sub block

            IF (v_simple_dimension_flag = 'Y') AND
            (v_value_set_required_flag = 'N') AND
            (v_xdim_read_only_flag = 'N') AND
            (v_hier_editor_managed_flag = 'Y') THEN

               Load_Dimension (
                 v_rows_rejected
                 ,v_rows_to_load
                 ,p_execution_mode
                 ,v_object_id
                 ,p_object_definition_id
                 ,v_dimension_varchar_label
                 ,p_date_format_mask);

               v_rows_rejected_accum := v_rows_rejected_accum + v_rows_rejected;
               v_rows_to_load_accum := v_rows_to_load_accum + v_rows_to_load;
            ELSE
               UPDATE fem_simple_dims_b_t
               SET STATUS = 'INVALID_SIMPLE_DIM'
               WHERE dimension_varchar_label = v_dimension_varchar_label;

               v_bulk_rows_rejected := SQL%ROWCOUNT;
               v_rows_rejected_accum := v_rows_rejected_accum + v_bulk_rows_rejected;
               -- rows to load gets incremented because these invalid_simple_dim rows
               -- don't appear in the original total since they don't belong to a legal
               -- dimension
               v_rows_to_load_accum := v_rows_to_load_accum + v_bulk_rows_rejected;
               UPDATE fem_simple_dims_tl_t
               SET STATUS = 'INVALID_SIMPLE_DIM'
               WHERE dimension_varchar_label = v_dimension_varchar_label;

               v_bulk_rows_rejected := SQL%ROWCOUNT;
               v_rows_rejected_accum := v_rows_rejected_accum + v_bulk_rows_rejected;
               -- rows to load gets incremented because these invalid_simple_dim rows
               -- don't appear in the original total since they don't belong to a legal
               -- dimension
               v_rows_to_load_accum := v_rows_to_load_accum + v_bulk_rows_rejected;

             COMMIT;
            END IF;
         END LOOP;
         *******************************************************************/
   ----------------------------------------------------------------------------------
   --  Engine Master Post Processing
   --  This step updates the status tables with number of rows processed,
   --  number of error rows, etc.
   ----------------------------------------------------------------------------------
   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_rejected_accum',v_rows_rejected_accum);

   FEM_ENGINES_PKG.TECH_MESSAGE
    (c_log_level_1,c_block||'.'||c_proc_name||'.v_rows_to_load_accum',v_rows_to_load_accum);

   Eng_Master_Post_Proc (v_object_id
                        ,v_rows_rejected_accum
                        ,v_rows_to_load_accum);


EXCEPTION
      WHEN e_no_folder_privs THEN

         SELECT folder_name
         INTO v_sec_folder_name
         FROM fem_folders_vl
         WHERE folder_id=1000;


         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_NO_FOLDER_PRIVS
          ,P_TOKEN1 => 'FOLDER'
          ,P_VALUE1 => v_sec_folder_name);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_NO_FOLDER_PRIVS
          ,P_TOKEN1 => 'FOLDER'
          ,P_VALUE1 => v_sec_folder_name);

         gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

      WHEN e_invalid_exec_mode THEN

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_5
          ,p_module => c_block||'.'||c_proc_name||'.Exception'
          ,p_app_name => c_fem
          ,p_msg_name => G_INVALID_EXEC_MODE);

         FEM_ENGINES_PKG.USER_MESSAGE
          (p_app_name => c_fem
          ,p_msg_name => G_INVALID_EXEC_MODE);

         gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

   WHEN e_main_terminate THEN

       gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

       FEM_PL_PKG.Update_Obj_Exec_Status(
        P_API_VERSION               => c_api_version,
        P_COMMIT                    => c_true,
        P_REQUEST_ID                => gv_request_id,
        P_OBJECT_ID                 => v_object_id,
        P_EXEC_STATUS_CODE          => 'ERROR_RERUN',
        P_USER_ID                   => gv_apps_user_id,
        P_LAST_UPDATE_LOGIN         => null,
        X_MSG_COUNT                 => v_msg_count,
        X_MSG_DATA                  => v_msg_data,
        X_RETURN_STATUS             => v_API_return_status);

      ---------------------------
      -- Update Request Status --
      ---------------------------
      FEM_PL_PKG.Update_Request_Status(
        P_API_VERSION               => c_api_version,
        P_COMMIT                    => c_true,
        P_REQUEST_ID                => gv_request_id,
        P_EXEC_STATUS_CODE          => 'ERROR_RERUN',
        P_USER_ID                   => gv_apps_user_id,
        P_LAST_UPDATE_LOGIN         => null,
        X_MSG_COUNT                 => v_msg_count,
        X_MSG_DATA                  => v_msg_data,
        X_RETURN_STATUS             => v_API_return_status);

   WHEN e_invalid_obj_def THEN

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_5
       ,p_module => c_block||'.'||c_proc_name||'.Exception'
       ,p_app_name => c_fem
       ,p_msg_name => G_INVALID_OBJ_DEF);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => G_INVALID_OBJ_DEF
       ,P_TOKEN1 => 'OBJECT'
       ,P_VALUE1 => null);

      gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

   WHEN e_pl_registration_failed THEN

      -- User and Tech messages have already been posted, so do nothing
      gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);

   WHEN OTHERS THEN

      gv_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
      gv_prg_msg := sqlerrm;
      gv_callstack := dbms_utility.format_call_stack;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_prg_msg);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_callstack);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
       ,P_TOKEN1 => 'ERR_MSG'
       ,P_VALUE1 => gv_prg_msg);
/*
      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_text => gv_prg_msg); */


END Main;

/***************************************************************************/

END FEM_DIM_MEMBER_LOADER_PKG;

/
