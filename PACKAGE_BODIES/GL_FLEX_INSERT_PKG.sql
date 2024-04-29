--------------------------------------------------------
--  DDL for Package Body GL_FLEX_INSERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FLEX_INSERT_PKG" AS
/* $Header: glffglib.pls 120.11.12000000.2 2007/01/23 23:17:26 djogg ship $ */

/* ------------------------------------------------------------------------- */
/*      Function called just after code combination is inserted into         */
/*      GL code combinations table in the accounting flexfield.              */
/*      Returns TRUE if ok, or returns FALSE and sets FND_MESSAGE on error.  */
/* ------------------------------------------------------------------------- */

 --===========================FND_LOG.START=====================================
   g_state_level NUMBER :=      FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER :=      FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER :=      FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER :=      FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER :=      FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER :=      FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(100) := 'psa.plsql.glffglib.gl_flex_insert_pkg.';
 --===========================FND_LOG.END=======================================

  g_segment_nvl_value     CONSTANT VARCHAR2(30)  := '-99$$!!';
  -- Types :


  -- SegValArray contains values for all the Segments

  TYPE SegValArray IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;

  -- TokNameArray contains names of all tokens

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- SegTypeArray contains entries for the Segment Types in the
  -- Summary Templates

  TYPE SegTypeArray IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;

  -- SegRgrpArray contains the Rollup Groups for Segments

  TYPE SegRgrpArray IS TABLE OF VARCHAR2(11) INDEX BY BINARY_INTEGER;

  -- RgrpSrtArray contains the Rollup Groups sorted by Rollup Group Scores

  TYPE RgrpSrtArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- RgrpIndArray contains the Segment Indices for the Sorted Rollup Group
  -- Scores

  TYPE RgrpIndArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- SegVsetArray contains the Value Set IDs for Segments

  TYPE SegVsetArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- TabColArray contains Segment Names

  TYPE TabColArray IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


  -- Private Global Variables :


  -- Flex Num for the Accounting Flexfield Structure

  coaid               gl_code_combinations.chart_of_accounts_id%TYPE;

  -- User ID

  user_id             gl_code_combinations.last_updated_by%TYPE;

  -- Responsibility ID

  user_resp_id        NUMBER;

  -- Login ID (unique per signon)

  login_id            gl_budget_assignments.last_update_login%TYPE;

  -- Segment Values for the Code Combination. Segment Values are stored in
  -- an array. A row in the array identifies the corresponding Segment Value.
  -- Thus, if a Code Combination has valid values for Segments 2, 4, 7, 11
  -- and 9, the 2nd, 4th, 7th, 11th and 9th rows of the array will contain
  -- the corresponding Segment Values

  seg_val             SegValArray;

  -- Whether Detail Budgeting is allowed for the Code Combination

  db_allowed_flag     VARCHAR2(1);

  -- Account Category for the Code Combination

  acct_category       VARCHAR2(1);

  -- Dynamic Group ID

  dyn_grp_id          gl_dynamic_summ_combinations.dynamic_group_id%TYPE;

  -- Whether GL has been installed

  gl_installed        VARCHAR2(15);

  -- Whether Government Install

  industry            VARCHAR2(1);

  -- Number of Active Segments in the Code Combination

  num_active_segs     NUMBER;

  -- Cardinal Number of the Accounting Segment in the Code Combination

  acct_seg_index      NUMBER;

  -- Minimum CCID. All new Parent Accounts will have CCIDs greater than the
  -- minimum CCID

  min_ccid            gl_dynamic_summ_combinations.code_combination_id%TYPE;

  -- Number of Budgetary Control Ledgers

  num_bc_lgr          NUMBER;

  -- Number of Summary Templates

  num_templates       NUMBER;

  -- Whether Parent Accounts have been created for this CCID

  created_parent      BOOLEAN;

  -- Number of Message Tokens

  no_msg_tokens       NUMBER;

  -- Message Token Name

  msg_tok_names       TokNameArray;

  -- Message Token Value

  msg_tok_val         TokValArray;

  -- For bug 3380377
  -- check to see if ccid already exists

  num_ccid  NUMBER;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

  FUNCTION glfcin RETURN BOOLEAN;


  FUNCTION glfini(ccid IN NUMBER) RETURN BOOLEAN;


  FUNCTION glfisi(val_set IN OUT NOCOPY SegVsetArray) RETURN BOOLEAN;


  FUNCTION glfiba(ccid IN NUMBER) RETURN BOOLEAN;


  FUNCTION glfcst(val_set IN SegVsetArray, ccid IN gl_code_combinations.code_combination_id%TYPE) RETURN BOOLEAN;


  FUNCTION glfgdg RETURN BOOLEAN;


  FUNCTION glfcrg(val_set       IN     SegVsetArray,
                  seg_type      IN     SegTypeArray,
                  rgroup        IN OUT NOCOPY SegRgrpArray,
                  template_name IN     VARCHAR2) RETURN BOOLEAN;





  FUNCTION glfcpc(seg_type      IN SegTypeArray,
                  rgroup        IN SegRgrpArray,
                  rgroup_sorted IN RgrpSrtArray,
                  rgroup_ind    IN RgrpIndArray,
                  val_set       IN SegVsetArray,
                  template_id   IN NUMBER,
                  lgr_id        IN NUMBER) RETURN BOOLEAN;


  FUNCTION glflst RETURN BOOLEAN;


  FUNCTION glfaec RETURN BOOLEAN;


  FUNCTION glfanc RETURN BOOLEAN;


  FUNCTION glficc RETURN BOOLEAN;


  FUNCTION glfmah(ccid IN NUMBER) RETURN BOOLEAN;


  FUNCTION glgfdi(ccid IN NUMBER) RETURN BOOLEAN;


  FUNCTION glfupd(ccid IN NUMBER) RETURN BOOLEAN;


  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2);


  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2);


  FUNCTION dsql_execute(sql_statement IN VARCHAR2) RETURN NUMBER;

  PROCEDURE allocate_lock(lockname IN VARCHAR2,
                          lockhandle OUT NOCOPY VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION; -- Bug   5074981
  BEGIN
      dbms_lock.allocate_unique(lockname, lockhandle);
  END allocate_lock;

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*    Main Routine for insertion of Foundation Flexfields. Returns TRUE    */
/*    if successful; otherwise, it returns FALSE.                          */
/*                                                                         */
/*    If Oracle General Ledger is not installed or the number of Ledgers   */
/*    with the Budgetary Control Option enabled is 0 or less, this         */
/*    function returns TRUE (successful).                                  */
/*                                                                         */
/*    In case of failure, this routine will populate the global Message    */
/*    Stack using FND_MESSAGE. The calling routine will read the Message   */
/*    from the Stack.                                                      */
/*                                                                         */
/*    External Packages which are being invoked include :                  */
/*                                                                         */
/*              FND_GLOBAL                                                 */
/*              FND_PROFILE                                                */
/*              FND_INSTALLATION                                           */
/*              FND_MESSAGE                                                */
/*                                                                         */
/*    GL Tables which are being used include :                             */
/*                                                                         */
/*              GL_CODE_COMBINATIONS                                       */
/*              GL_LEDGERS                                                 */
/*              GL_BUDGET_ASSIGNMENT_RANGES                                */
/*              GL_BUDGET_ASSIGNMENTS                                      */
/*              GL_SUMMARY_TEMPLATES                                       */
/*              GL_DYNAMIC_SUMM_COMBINATIONS                               */
/*              GL_ROLLUP_GROUP_SCORES                                     */
/*              GL_CONCURRENCY_CONTROL                                     */
/*              GL_ACCOUNT_HIERARCHIES                                     */
/*                                                                         */
/*    AOL Tables which are being used include :                            */
/*                                                                         */
/*              FND_ID_FLEX_SEGMENTS                                       */
/*              FND_SEGMENT_ATTRIBUTE_VALUES                               */
/*              FND_FLEX_HIERARCHIES                                       */
/*              FND_FLEX_VALUE_HIERARCHIES                                 */
/*              FND_FLEX_VALUES                                            */
/*              FND_SEG_RPT_ATTRIBUTES                                     */
/*              FND_FLEX_VALUE_SETS                                        */
/*              FND_TABLES                                                 */
/*              FND_FLEX_VALIDATION_TABLES                                 */
/*                                                                         */
/* ----------------------------------------------------------------------- */


  -- Called Routines :

  -- glfini : Setup Global Variables

  -- glfcin : Check if GL has been installed

  -- glfisi : Retrieve Value Set IDs for the Segments in the Code Combination

  -- glfiba : Insert into Budget Assignments table only if Segment Values fall
  --          within any Account Ranges in the Budget Organization

  -- glfcst : Loop through the Summary Templates and create Parent Accounts for
  --          each template

  -- glflst : Lock Summary Templates

  -- glfaec : Find CCIDs for existing Code Combinations

  -- glfanc : Assign new CCID to new Code Combinations

  -- glficc : Insert newly created Parent Accounts into Code Combinations
  --          Table

  -- glfmah : Maintain Account Hierarchies

  -- glgfdi : Maintain Reporting Attributes


  -- Arguments :

  -- ccid : Code Combination ID


  FUNCTION fdfgli(ccid IN NUMBER) RETURN BOOLEAN IS

    val_set  SegVsetArray;

    i        BINARY_INTEGER;
    lockhandle VARCHAR2(128);
    retval   INTEGER;
    lock_flag BOOLEAN;
    l_temp_var VARCHAR2(1);

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'fdfgli.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START fdfgli ');
   -- ========================= FND LOG ===========================

    -- Initialize Global Variables

    dyn_grp_id := -1;
    gl_installed := 'HAVENT_CHECKED';
    num_active_segs := 0;
    num_bc_lgr := 0;
    num_templates := 0;
    created_parent := FALSE;
    no_msg_tokens := 0;
    num_ccid := 0;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' Initializing Variables ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' dyn_grp_id      -> ' || to_char(dyn_grp_id));
      psa_utils.debug_other_string(g_state_level,l_full_path,' gl_installed    -> ' || gl_installed);
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_active_segs -> ' || num_active_segs);
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_bc_lgr      -> ' || num_bc_lgr);
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_templates   -> ' || num_templates);
   -- ========================= FND LOG ===========================

    --select count(*)
    --into num_ccid
    --from gl_code_combinations
    --where code_combination_id = ccid;

    BEGIN
            select 'Y' into l_temp_var
            from dual
            where not exists (select 'x'
                              from gl_account_hierarchies
                              where detail_code_combination_id = ccid)
              and not exists (select 'x'
                              from gl_budget_assignments
                              where code_combination_id = ccid);

           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' l_temp_var -> ' || l_temp_var);
           -- ========================= FND LOG ===========================

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN NO_DATA_FOUND');
           psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
        -- ========================= FND LOG ===========================
        RETURN (true);
     END;

    -- For bug 3380377, check to see if ccid exists.  If it already exists, just return TRUE
    --if (num_ccid > 0) then
    --   return(TRUE);
    --end if;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfini -> ' || ccid);
    -- ========================= FND LOG ===========================

    -- Setup Global Variables

    if not glfini(ccid) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
      return(FALSE);
    end if;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfcin ');
    -- ========================= FND LOG ===========================

    -- Check if GL has been installed

    if not glfcin then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
      return(FALSE);
    end if;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' gl_installed -> ' || gl_installed);
    -- ========================= FND LOG ===========================

    -- If GL is not installed or number of set of books with the
    -- budgetary control option enabled is zero or less then
    -- return TRUE

    if gl_installed = 'NOT_INSTALLED' then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
       -- ========================= FND LOG ===========================
      return(TRUE);
    end if;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Calling HR_GL_COST_CENTERS.create_org');
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' update company_cost_enter_org_id of GL_CODE_COMBINATIONS');
    -- ========================= FND LOG ===========================

   -- Call API to update company_cost_enter_org_id of GL_CODE_COMBINATIONS table..
   -- We pass CCID as parameter to this procedure

   HR_GL_COST_CENTERS.create_org(ccid);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' num_bc_lgr -> ' || num_bc_lgr);
    -- ========================= FND LOG ===========================

    -- If no Budgetary Control then maintain Reporting Attributes
    -- and exit

    if num_bc_lgr = 0 then

      -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glgfdi -> '|| ccid);
      -- ========================= FND LOG ===========================

      if not glgfdi(ccid) then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
         return(FALSE);
      else
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
         -- ========================= FND LOG ===========================
         return(TRUE);
      end if;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Retrieve Value Set IDs for the Segments in the Code Combination ');
    -- ========================= FND LOG ===========================

    -- Retrieve Value Set IDs for the Segments in the Code Combination

    for i in 1..30 loop
      val_set(i) := null;
    end loop;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Calling glfisi passing val_set ');
    -- ========================= FND LOG ===========================

    if not glfisi(val_set) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    end if;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' db_allowed_flag -> ' || db_allowed_flag);
    -- ========================= FND LOG ===========================

    -- Maintain Budget Assignments only if Detail Budgeting is allowed for the
    -- new Code Combination

    if (db_allowed_flag = 'Y') then

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfiba -> ' || ccid);
      -- ========================= FND LOG ===========================

      -- Insert into Budget Assignments table only if Segment Values fall
      -- within any Account Ranges in the Budget Organization

      if not glfiba(ccid) then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
        return(FALSE);
      end if;

    end if;

    lock_flag := FALSE;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Doing the Locking');
    -- ========================= FND LOG ===========================

    -- A new share user name lock is added. It will be released at the end.
    -- This ensures that when a new code combination is created, no GLSIMS
    -- runs to incrementally update the hierarchies.

    LOOP

        if(lock_flag = TRUE) then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' lock_flag - TRUE - EXIT');
           -- ========================= FND LOG ===========================
           exit;

        end if;

        allocate_lock('GL_BC_SUMMARY_TEMPLATES'||coaid, lockhandle); -- Bug 5074981
        retval := dbms_lock.request(lockhandle,4,32767,FALSE);

        -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' retval -> ' || retval);
        -- ========================= FND LOG ===========================

        if(retval = 0 OR retval = 4)then
          lock_flag := TRUE;
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' lock_flag -> TRUE');
          -- ========================= FND LOG ===========================

        elsif(retval = 1)then
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' Calling dbms_lock.sleep');
          -- ========================= FND LOG ===========================
          dbms_lock.sleep(15);

        else
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN FALSE');
          -- ========================= FND LOG ===========================
          return(FALSE);

        end if;

    END LOOP;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Loop through the Summary Templates and create Parent Accounts');
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Calling glfcst passing val_set ');
   -- ========================= FND LOG ===========================

   -- Loop through the Summary Templates and create Parent Accounts
   -- for each template

    if not glfcst(val_set, ccid) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    end if;

    -- Now that parent accounts have been created for all the Summary
    -- Templates, we
    -- (1) lock the summary templates that have parent accounts created
    -- (2) find ccids for existing parents
    -- (3) assign new ccids to new parents
    -- (4) insert the newly created parents into gl_code_combinations
    -- (5) maintain gl_account_hierarchies

    if created_parent then

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' Lock Summary Templates');
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glflst');
      -- ========================= FND LOG ===========================

      -- Lock Summary Templates

      if not glflst then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
         return(FALSE);
      end if;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' Find CCIDs for existing Code Combinations');
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfaec');
      -- ========================= FND LOG ===========================

      -- Find CCIDs for existing Code Combinations

      if not glfaec then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================

         return(FALSE);
      end if;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' Assign new CCIDs to new Code Combinations');
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfanc');
      -- ========================= FND LOG ===========================

      -- Assign new CCIDs to new Code Combinations

      if not glfanc then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
         return(FALSE);
      end if;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' Insert newly created Parent Accounts into Code Combinations table');
         psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glficc');
      -- ========================= FND LOG ===========================

      -- Insert newly created Parent Accounts into Code Combinations table

      if not glficc then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
         return(FALSE);
      end if;


      -- Maintain Account Hierarchies

      if not glfmah(ccid) then
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
         -- ========================= FND LOG ===========================
         return(FALSE);
      end if;

    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Release the budgetary control locks');
    -- ========================= FND LOG ===========================

    -- Release the budgetary control user name lock after maintaining the
    -- account hierarchies.

    retval := dbms_lock.release(lockhandle);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' retval -> ' || retval);
    -- ========================= FND LOG ===========================

    if(retval <> 0) then
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================
      return(FALSE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' Maintain Reporting Attributes');
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glgfdi -> ' || ccid);
    -- ========================= FND LOG ===========================

    -- Maintain Reporting Attributes

    if not glgfdi(ccid) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================
    return(TRUE);

  END FDFGLI;

/* ------------------------------------------------------------------------ */

  -- Setup Global Variables


  -- Called Routines :

  -- FND_GLOBAL : Setup User ID, Login ID, Responsibility ID

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Define a Message Token with a Value and set the Message Name


  -- Arguments :

  -- ccid : Code Combination ID


  FUNCTION glfini(ccid IN NUMBER) RETURN BOOLEAN IS

    -- Maximum Length for this Dynamic SQL Statement is 463

    sql_glcc     VARCHAR2(700);
    cur_glcc     INTEGER;
    ignore       INTEGER;

    i            BINARY_INTEGER;

    account_type gl_code_combinations.account_type%TYPE;
    segment1     gl_code_combinations.segment1%TYPE;
    segment2     gl_code_combinations.segment2%TYPE;
    segment3     gl_code_combinations.segment3%TYPE;
    segment4     gl_code_combinations.segment4%TYPE;
    segment5     gl_code_combinations.segment5%TYPE;
    segment6     gl_code_combinations.segment6%TYPE;
    segment7     gl_code_combinations.segment7%TYPE;
    segment8     gl_code_combinations.segment8%TYPE;
    segment9     gl_code_combinations.segment9%TYPE;
    segment10    gl_code_combinations.segment10%TYPE;
    segment11    gl_code_combinations.segment11%TYPE;
    segment12    gl_code_combinations.segment12%TYPE;
    segment13    gl_code_combinations.segment13%TYPE;
    segment14    gl_code_combinations.segment14%TYPE;
    segment15    gl_code_combinations.segment15%TYPE;
    segment16    gl_code_combinations.segment16%TYPE;
    segment17    gl_code_combinations.segment17%TYPE;
    segment18    gl_code_combinations.segment18%TYPE;
    segment19    gl_code_combinations.segment19%TYPE;
    segment20    gl_code_combinations.segment20%TYPE;
    segment21    gl_code_combinations.segment21%TYPE;
    segment22    gl_code_combinations.segment22%TYPE;
    segment23    gl_code_combinations.segment23%TYPE;
    segment24    gl_code_combinations.segment24%TYPE;
    segment25    gl_code_combinations.segment25%TYPE;
    segment26    gl_code_combinations.segment26%TYPE;
    segment27    gl_code_combinations.segment27%TYPE;
    segment28    gl_code_combinations.segment28%TYPE;
    segment29    gl_code_combinations.segment29%TYPE;
    segment30    gl_code_combinations.segment30%TYPE;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfini.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfini ');
   -- ========================= FND LOG ===========================

    -- Setup User ID
    user_id := FND_GLOBAL.USER_ID;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' user_id -> ' || user_id);
   -- ========================= FND LOG ===========================

    if user_id = -1 then
      message_token('ROUTINE', 'FDFGLI');
      add_message('FND', 'FLEXGL-CANNOT GET USERID');
--     goto return_invalid;
    end if;

    -- Setup Login ID
    login_id := FND_GLOBAL.LOGIN_ID;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' login_id -> ' || login_id);
   -- ========================= FND LOG ===========================

    if login_id = -1 then
      message_token('ROUTINE', 'FDFGLI');
      add_message('FND', 'FLEXGL-CANNOT GET LOGIN ID');
--     goto return_invalid;
    end if;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' user_resp_id -> ' || user_resp_id);
   -- ========================= FND LOG ===========================

    -- Setup Responsibility ID
    user_resp_id := FND_GLOBAL.RESP_ID;

    if user_resp_id = -1 then
      message_token('ROUTINE', 'FDFGLI');
      add_message('FND', 'FLEX-CANNOT FIND RESP_ID PROF');
--    goto return_invalid;
    end if;


    -- Initialize Segment Values array

    for i in 1..30 loop
      seg_val(i) := null;
    end loop;


    -- Dynamic SQL for fetching from the Code Combinations table

    sql_glcc := 'select ' ||
                'chart_of_accounts_id, ' ||
                'detail_budgeting_allowed_flag, ' ||
                'account_type';

    for i in 1..30 loop
      sql_glcc := sql_glcc ||
                  ', segment' || i;
    end loop;

    sql_glcc := sql_glcc ||
                ' from gl_code_combinations ' ||
                'where code_combination_id = :ccid';


   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_glcc -> ' || sql_glcc);
   -- ========================= FND LOG ===========================

    cur_glcc := dbms_sql.open_cursor;
    dbms_sql.parse(cur_glcc, sql_glcc, dbms_sql.v7);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' BIND PARAMETERS');
      psa_utils.debug_other_string(g_state_level,l_full_path,' ccid -> ' || ccid);
   -- ========================= FND LOG ===========================

    dbms_sql.bind_variable(cur_glcc, ':ccid', ccid);

    dbms_sql.define_column(cur_glcc, 1, coaid);
    dbms_sql.define_column(cur_glcc, 2, db_allowed_flag, 1);
    dbms_sql.define_column(cur_glcc, 3, account_type, 1);

    for i in 1..30 loop
      dbms_sql.define_column(cur_glcc, i + 3, 'segment' || i , 25);
    end loop;

    ignore := dbms_sql.execute(cur_glcc);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' ignore -> ' || ignore);
   -- ========================= FND LOG ===========================

    loop

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' start loop');
      -- ========================= FND LOG ===========================

      if dbms_sql.fetch_rows(cur_glcc) = 0 then
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' exit');
        -- ========================= FND LOG ===========================
        exit;
      end if;

      dbms_sql.column_value(cur_glcc, 1, coaid);
      dbms_sql.column_value(cur_glcc, 2, db_allowed_flag);
      dbms_sql.column_value(cur_glcc, 3, account_type);

      for i in 1..30 loop
        dbms_sql.column_value(cur_glcc, i + 3, seg_val(i));
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' seg_val(' || i || ') -> ' || seg_val(i));
        -- ========================= FND LOG ===========================
      end loop;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' end loop');
      -- ========================= FND LOG ===========================

    end loop;

    dbms_sql.close_cursor(cur_glcc);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' account_type -> ' || account_type);
    -- ========================= FND LOG ===========================

    if account_type in ('A', 'L', 'O', 'R', 'E') then
      acct_category := 'P';
    else
      acct_category := 'B';
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' acct_category -> ' || acct_category);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_invalid');
    -- ========================= FND LOG ===========================
    if dbms_sql.is_open(cur_glcc) then
      dbms_sql.close_cursor(cur_glcc);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_glcc) then
        dbms_sql.close_cursor(cur_glcc);
      end if;

      message_token('MSG', 'glfini() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' EXCEPTION WHEN OTHERS GLFINI - '||SQLERRM);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

      return(FALSE);

  END glfini;

/* ------------------------------------------------------------------------- */

  -- Check if GL has been installed


  -- Called Routines :

  -- FND_PROFILE.GET_SPECIFIC : Get Profile Value

  -- FND_INSTALLATION.GET : Get Product Installation Info

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Define a Message Token with a Value and set the Message Name


  FUNCTION glfcin RETURN BOOLEAN IS

    dep_appl_id    fnd_application.application_id%TYPE;
    status         fnd_product_installations.status%TYPE;
    l_temp_industry     fnd_product_installations.industry%TYPE;
    l_industry     fnd_profile_option_values.profile_option_value%type;

    l_defined      BOOLEAN;

    cursor cnt_lgr(coaid NUMBER) IS
      select count(*)
        from gl_ledgers
       where enable_budgetary_control_flag = 'Y'
         and chart_of_accounts_id = coaid;


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfcin.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfcin ');
   -- ========================= FND LOG ===========================

   -- Get Product Installation info by Application ID (101 for SQLGL)

    dep_appl_id := FND_GLOBAL.RESP_APPL_ID;

    if dep_appl_id = -1 then
      dep_appl_id := 101;
    end if;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' dep_appl_id -> ' || to_char(dep_appl_id));
   -- ========================= FND LOG ===========================

    -- Get GL Installation Status
    -- The installation info is now implemented as a profile option (INDUSTRY).

    FND_PROFILE.GET_SPECIFIC('INDUSTRY',
                             user_id,
                             user_resp_id,
                             dep_appl_id,
                             l_industry,
                             l_defined);

    if not FND_INSTALLATION.GET(dep_appl_id,
                                101,
                                status,
                                l_temp_industry) then

          message_token('ROUTINE', 'FDFGLI');
          add_message('SQLGL', 'GL_CANT_GET_INSTALL_INDUSTRY');
          return(FALSE);

    end if;

    if not l_defined then

        l_industry := l_temp_industry;

    end if;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_industry -> ' || l_industry);
   -- ========================= FND LOG ===========================

    -- If installed check count of Set of Books with Budgetary Control flag
    -- enabled

    if status = 'I' then

      gl_installed := 'INSTALLED';
      industry := l_industry;

      open cnt_lgr(coaid);

      fetch cnt_lgr
       into num_bc_lgr;

      close cnt_lgr;

    end if;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_bc_lgr -> ' || num_bc_lgr);
      psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
   -- ========================= FND LOG ===========================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if cnt_lgr%ISOPEN then
        close cnt_lgr;
      end if;

      message_token('MSG', 'glfcin() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFCIN - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glfcin;

/* ------------------------------------------------------------------------- */

  -- Retrieve Value Set IDs for the Segments in the Code Combination


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- val_set : Value Set IDs for all the Segments in the Combination


  FUNCTION glfisi(val_set IN OUT NOCOPY SegVsetArray) RETURN BOOLEAN IS

    i           BINARY_INTEGER;

    col_name    fnd_id_flex_segments.application_column_name%TYPE;
    vset_id     fnd_id_flex_segments.flex_value_set_id%TYPE;
    e_val_set   SegVsetArray;

    cursor valset(flex_num  NUMBER,
                  appl_id   NUMBER,
                  flex_code VARCHAR2) IS
      select application_column_name,
             nvl(flex_value_set_id, 0) value_set_id
        from fnd_id_flex_segments
       where enabled_flag = 'Y'
         and id_flex_num = flex_num
         and application_id = appl_id
         and id_flex_code = flex_code;

    cursor accseg(flex_num  NUMBER,
                  appl_id   NUMBER,
                  flex_code VARCHAR2) IS
      select /*+ ORDERED INDEX (FND_SEGMENT_ATTRIBUTE_VALUES
                 FND_SEGMENT_ATTRIBUTE_VALS_U1) */
             application_column_name
        from fnd_segment_attribute_values
       where attribute_value = 'Y'
         and segment_attribute_type = 'GL_ACCOUNT'
         and id_flex_num = flex_num
         and application_id = appl_id
         and id_flex_code = flex_code;


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfisi.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfisi ');
   -- ========================= FND LOG ===========================

    e_val_set := val_set;
    -- Assign Value Set IDs for the Segments

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' populating temp table val_set ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' coaid -> '|| coaid );
   -- ========================= FND LOG ===========================

    for c_valset in valset(coaid, 101, 'GL#') loop

      col_name := c_valset.application_column_name;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' col_name -> ' || col_name);
      -- ========================= FND LOG ===========================

      vset_id := c_valset.value_set_id;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' vset_id -> ' || vset_id);
      -- ========================= FND LOG ===========================

      i := to_number(substr(col_name, 8, length(col_name) - 7));

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' i -> ' || i);
      -- ========================= FND LOG ===========================

      val_set(i) := vset_id;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' val_set(' || i || ') ->' || vset_id);
      -- ========================= FND LOG ===========================

      num_active_segs := num_active_segs + 1;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,'  num_active_segs -> ' ||  num_active_segs);
      -- ========================= FND LOG ===========================

    end loop;


    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'  opening accseg ');
    -- ========================= FND LOG ===========================

    -- Get Cardinal Order or Index Number of the Account Segment
    open accseg(coaid, 101, 'GL#');

    fetch accseg
     into col_name;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'  col_name -> ' ||  col_name);
    -- ========================= FND LOG ===========================

    -- No Accounting Segment defined

    if accseg%NOTFOUND then
      message_token('ROUTINE', 'FDFGLI');
      add_message('FND', 'FLEXGL-NO ACCT SEG');
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' No Accounting Segment defined');
         psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
      -- ========================= FND LOG ===========================
      goto return_invalid;
    end if;

    close accseg;

    i := to_number(substr(col_name, 8, length(col_name) - 7));

    acct_seg_index := i;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' acct_seg_index -> ' || acct_seg_index);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_invalid');
    -- ========================= FND LOG ===========================

    if accseg%ISOPEN then
      close accseg;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN
      val_set := e_val_set;
      if accseg%ISOPEN then
        close accseg;
      end if;

      message_token('MSG', 'glfisi() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFISI -> ' || SQLERRM);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

      return(FALSE);

  END glfisi;

/* ------------------------------------------------------------------------- */

  -- Insert into Budget Assignments table only if Segment Values fall within
  -- any Account Ranges in the Budget Organization


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- ccid : Code Combination ID


  FUNCTION glfiba(ccid IN NUMBER) RETURN BOOLEAN IS

    -- Maximum Length for this Dynamic SQL Statement is 3387

    sql_insba   VARCHAR2(4000);
    cur_insba   INTEGER;
    num_rows    INTEGER;

    i           BINARY_INTEGER;


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfiba.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfiba. ');
   -- ========================= FND LOG ===========================
   -- Bug 5501177/Bug 5556665 -dynamic sql changed to static sql from performance
   -- improvement
       insert into gl_budget_assignments (
                 budget_entity_id,
                 ledger_id,
                 currency_code,
                 range_id,
                 entry_code,
                 ordering_value,
                 code_combination_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login )
                select bar.budget_entity_id,
                 bar.ledger_id,
                 bar.currency_code,
                 bar.range_id,
                 bar.entry_code,
                 seg_val(acct_seg_index),
                 ccid,
                 sysdate,
                 user_id,
                 sysdate,
                 user_id,
                 login_id
                 from gl_budget_assignment_ranges bar,
                gl_ledgers lgr
                 where
		  exists (select 'found' from gl_budorg_bc_options bco
                  where bar.range_id = bco.range_id)
                 AND (seg_val(1) IS NULL OR seg_val(1) BETWEEN bar.segment1_low AND
                      bar.segment1_high)
                 AND (seg_val(2) IS NULL OR seg_val(2) BETWEEN bar.segment2_low AND
                      bar.segment2_high)
                 AND (seg_val(3) IS NULL OR seg_val(3) BETWEEN bar.segment3_low AND
                      bar.segment3_high)
                 AND (seg_val(4) IS NULL OR seg_val(4) BETWEEN bar.segment4_low AND
                      bar.segment4_high)
                  AND (seg_val(5) IS NULL OR seg_val(5) BETWEEN bar.segment5_low AND
                      bar.segment5_high)
                  AND (seg_val(6) IS NULL OR seg_val(6) BETWEEN bar.segment6_low AND
                      bar.segment6_high)
                 AND (seg_val(7) IS NULL OR seg_val(7) BETWEEN bar.segment7_low AND
                      bar.segment7_high)
                 AND (seg_val(8) IS NULL OR seg_val(8) BETWEEN bar.segment8_low AND
                      bar.segment8_high)
                 AND (seg_val(9) IS NULL OR seg_val(9) BETWEEN bar.segment9_low AND
                      bar.segment9_high)
                 AND (seg_val(10) IS NULL OR seg_val(10) BETWEEN bar.segment10_low AND
                      bar.segment10_high)
                 AND (seg_val(11) IS NULL OR seg_val(11) BETWEEN bar.segment11_low AND
                      bar.segment11_high)
                 AND (seg_val(12) IS NULL OR seg_val(12) BETWEEN bar.segment12_low AND
                      bar.segment12_high)
                 AND (seg_val(13) IS NULL OR seg_val(13) BETWEEN bar.segment13_low AND
                      bar.segment13_high)
                 AND (seg_val(14) IS NULL OR seg_val(14) BETWEEN bar.segment14_low AND
                      bar.segment14_high)
                  AND (seg_val(15) IS NULL OR seg_val(15) BETWEEN bar.segment15_low AND
                      bar.segment15_high)
                  AND (seg_val(16) IS NULL OR seg_val(16) BETWEEN bar.segment16_low AND
                      bar.segment16_high)
                 AND (seg_val(17) IS NULL OR seg_val(17) BETWEEN bar.segment17_low AND
                      bar.segment17_high)
                 AND (seg_val(18) IS NULL OR seg_val(18) BETWEEN bar.segment18_low AND
                      bar.segment18_high)
                 AND (seg_val(19) IS NULL OR seg_val(19) BETWEEN bar.segment19_low AND
                      bar.segment19_high)
                 AND (seg_val(20) IS NULL OR seg_val(20) BETWEEN bar.segment20_low AND
                      bar.segment20_high)
                 AND (seg_val(21) IS NULL OR seg_val(21) BETWEEN bar.segment21_low AND
                      bar.segment21_high)
                 AND (seg_val(22) IS NULL OR seg_val(22) BETWEEN bar.segment22_low AND
                      bar.segment22_high)
                 AND (seg_val(23) IS NULL OR seg_val(23) BETWEEN bar.segment23_low AND
                      bar.segment23_high)
                 AND (seg_val(24) IS NULL OR seg_val(24) BETWEEN bar.segment24_low AND
                      bar.segment24_high)
                  AND (seg_val(25) IS NULL OR seg_val(25) BETWEEN bar.segment25_low AND
                      bar.segment25_high)
                  AND (seg_val(26) IS NULL OR seg_val(26) BETWEEN bar.segment26_low AND
                      bar.segment26_high)
                 AND (seg_val(27) IS NULL OR seg_val(27) BETWEEN bar.segment27_low AND
                      bar.segment27_high)
                 AND (seg_val(28) IS NULL OR seg_val(28) BETWEEN bar.segment28_low AND
                      bar.segment28_high)
                 AND (seg_val(29) IS NULL OR seg_val(29) BETWEEN bar.segment29_low AND
                      bar.segment29_high)
                 AND (seg_val(30) IS NULL OR seg_val(30) BETWEEN bar.segment30_low AND
                      bar.segment30_high)
		 and bar.currency_code = lgr.currency_code
                 and bar.ledger_id = lgr.ledger_id
                 and lgr.enable_budgetary_control_flag = 'Y'
                 and lgr.chart_of_accounts_id = coaid ;
   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' BIND PARAMETERS ');
      psa_utils.debug_other_string(g_state_level,l_full_path,
      ' seg_val(' || acct_seg_index || ') -> ' || seg_val(acct_seg_index));
      psa_utils.debug_other_string(g_state_level,l_full_path,' ccid -> ' || ccid);
      psa_utils.debug_other_string(g_state_level,l_full_path,' user_id -> ' || user_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' login_id -> ' || login_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' coaid -> ' || coaid);

      psa_utils.debug_other_string(g_state_level,l_full_path,' num_rows -> ' || num_rows);

      psa_utils.debug_other_string(g_state_level,l_full_path,'RETURN -> TRUE');
   -- ========================= FND LOG ===========================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN


      -- Dynamic SQL Exception

      message_token('MSG', SQLERRM);
      message_token('SQLSTR', substr(sql_insba, 1, 1000));
      add_message('FND', 'FLEX-DSQL EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFIBA -> ' || SQLERRM);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

      return(FALSE);

  END glfiba;

/* ------------------------------------------------------------------------- */

  -- Loop through the Summary Templates and create Parent Accounts for
  -- each template


  -- Called Routines :

  -- glfgdg : Get Dynamic Group ID for the new Parent Accounts

  -- glfcrg : Identify Rollup Groups


  -- glfcpc : Create Parent Accounts

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- val_set : Value Set IDs for the Segments in the Code Combination


  FUNCTION glfcst(val_set IN SegVsetArray, ccid IN gl_code_combinations.code_combination_id%TYPE) RETURN BOOLEAN IS

    -- Maximum Length for this Dynamic SQL Statement is 993

    sql_stmp        VARCHAR2(32767);
    sql_stmp_length INTEGER;
    sql_stmp_printed INTEGER;
    cur_stmp        INTEGER;
    ignore          INTEGER;
    sql_stmp_count  INTEGER;
    test_value      INTEGER;
    i               BINARY_INTEGER;
    seg_type        SegTypeArray;
    rgroup          SegRgrpArray;
    rgroup_sorted   RgrpSrtArray;
    rgroup_ind      RgrpIndArray;

    template_name   gl_summary_templates.template_name%TYPE;
    template_id     gl_summary_templates.template_id%TYPE;
    lgr_id          gl_summary_templates.ledger_id%TYPE;
    segment1_type   gl_summary_templates.segment1_type%TYPE;
    segment2_type   gl_summary_templates.segment2_type%TYPE;
    segment3_type   gl_summary_templates.segment3_type%TYPE;
    segment4_type   gl_summary_templates.segment4_type%TYPE;
    segment5_type   gl_summary_templates.segment5_type%TYPE;
    segment6_type   gl_summary_templates.segment6_type%TYPE;
    segment7_type   gl_summary_templates.segment7_type%TYPE;
    segment8_type   gl_summary_templates.segment8_type%TYPE;
    segment9_type   gl_summary_templates.segment9_type%TYPE;
    segment10_type  gl_summary_templates.segment10_type%TYPE;
    segment11_type  gl_summary_templates.segment11_type%TYPE;
    segment12_type  gl_summary_templates.segment12_type%TYPE;
    segment13_type  gl_summary_templates.segment13_type%TYPE;
    segment14_type  gl_summary_templates.segment14_type%TYPE;
    segment15_type  gl_summary_templates.segment15_type%TYPE;
    segment16_type  gl_summary_templates.segment16_type%TYPE;
    segment17_type  gl_summary_templates.segment17_type%TYPE;
    segment18_type  gl_summary_templates.segment18_type%TYPE;
    segment19_type  gl_summary_templates.segment19_type%TYPE;
    segment20_type  gl_summary_templates.segment20_type%TYPE;
    segment21_type  gl_summary_templates.segment21_type%TYPE;
    segment22_type  gl_summary_templates.segment22_type%TYPE;
    segment23_type  gl_summary_templates.segment23_type%TYPE;
    segment24_type  gl_summary_templates.segment24_type%TYPE;
    segment25_type  gl_summary_templates.segment25_type%TYPE;
    segment26_type  gl_summary_templates.segment26_type%TYPE;
    segment27_type  gl_summary_templates.segment27_type%TYPE;
    segment28_type  gl_summary_templates.segment28_type%TYPE;
    segment29_type  gl_summary_templates.segment29_type%TYPE;
    segment30_type  gl_summary_templates.segment30_type%TYPE;


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfcst.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfcst ');
   -- ========================= FND LOG ===========================

    sql_stmp := 'select ' ||
                'smt.template_name, ' ||
                'smt.template_id, ' ||
                'smt.ledger_id';

    for i in 1..30 loop
      sql_stmp := sql_stmp ||
                  ', smt.segment' || i || '_type';
    end loop;

    sql_stmp := sql_stmp || ' ' ||
                'from gl_summary_templates smt, ' ||
                'gl_ledgers lgr ' ||
                'where smt.status in (''A'', ''F'') ' ||
                'and smt.account_category_code = :catg ' ||
                'and smt.ledger_id = lgr.ledger_id ' ||
                'and lgr.enable_budgetary_control_flag = ''Y'' ' ||
                'and lgr.chart_of_accounts_id = :coaid ' ||
                'and EXISTS (select ''found'' from ' ||
                'gl_summary_bc_options smb where ' ||
                'smt.template_id = smb.template_id) ' ;

for i in 1..10 loop
-- This query is for performance improvement Bug 5220785
-- The query will run fine without this loop.
-- The objective of this loop is to restrict the no of summary templates so
-- that less PL/SQL processing would be required in the later
-- process to create the parents.
-- When the loop is set to run from 1 to 30, it will only include the
-- summary templates that are associated with the code combination
-- Please note that the iteration only runs from 1 to 10 at this moment in
-- time.  It is specifically set this way for :
-- 1.  Avoid the huge query that may have occurred
-- 2.  Normally customers would not be using more than 10 segments.  As
-- this is used as an optimization, it is okay even the customer
-- has more than 10 segments defined
-- 3.  Since there are quite some tables involved, by having less joins can
--     improve performance for normal case.
    sql_stmp := sql_stmp || ' ' ||
                'and (segment' || i || '_type is null ' ||
                'or segment' || i || '_type in (''D'', ''T'') ' ||
                'or segment' || i || '_type in (select fh.hierarchy_name ' ||
                'from gl_code_combinations cc, gl_summary_hierarchies gsh, fnd_flex_values fv, fnd_id_flex_segments fs, ' ||
                'fnd_flex_hierarchies_vl fh ' ||
                'where cc.code_combination_id = :ccid and ' ||
                'cc.segment' || i || ' between gsh.child_flex_value_low and gsh.child_flex_value_high and ' ||
                'gsh.flex_value_set_id = fv.flex_value_set_id and ' ||
                'gsh.parent_flex_value = fv.flex_value  and ' ||
                'gsh.flex_value_set_id = fv.flex_value_set_id and ' ||
                'fv.enabled_flag = ''Y'' and ' ||
                'fs.flex_value_set_id = gsh.flex_value_set_id and ' ||
               -- 'sob.chart_of_accounts_id = cc.chart_of_accounts_id and ' ||
                'fs.enabled_flag = ''Y'' and ' ||
                'cc.chart_of_accounts_id = fs.id_flex_num and ' ||
                'fs.application_id = 101 and ' ||
                'fs.id_flex_code = ''GL#'' and ' ||
                'fs.application_column_name = ''SEGMENT' || i || ''' and ' ||
                'fv.flex_value_set_id = fh.flex_value_set_id and ' ||
                'fv.structured_hierarchy_level = fh.hierarchy_id)) ';
-- Still need to get the val_set_id somehow
 -- take this out later
   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp -> here' || i);
   -- ========================= FND LOG ===========================
    end loop;

    sql_stmp := sql_stmp || ' ' || 'order by smt.template_id, smt.ledger_id';



   -- ========================= FND LOG ===========================
      -- psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp -> ' || sql_stmp);
    sql_stmp_printed := 1;
    sql_stmp_length := length(sql_stmp);
    psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp length -> ' || sql_stmp_length);
    loop
      exit when sql_stmp_printed >= sql_stmp_length;
      psa_utils.debug_other_string(g_state_level,l_full_path,' here again');
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp -> ' || SUBSTR(sql_stmp,sql_stmp_printed,3000));
      sql_stmp_printed := sql_stmp_printed + 3000;
      --psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp -> ' || SUBSTR(sql_stmp,3001,6000));
      --psa_utils.debug_other_string(g_state_level,l_full_path,' here again2');
    end loop;

   -- ========================= FND LOG ===========================

    cur_stmp := dbms_sql.open_cursor;
    dbms_sql.parse(cur_stmp, sql_stmp, dbms_sql.v7);

   -- ========================= FND LOG ===========================
     -- psa_utils.debug_other_string(g_state_level,l_full_path,' BIND PARAMETERS');
     -- psa_utils.debug_other_string(g_state_level,l_full_path,' coaid -> ' || coaid);
    -- psa_utils.debug_other_string(g_state_level,l_full_path,' acct_category -> ' || acct_category);

      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp BIND PARAMETERS');
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp coaid -> ' || coaid);
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp acct_category -> ' || acct_category);
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp ccid -> ' || ccid);
   -- ========================= FND LOG ===========================

    dbms_sql.bind_variable(cur_stmp, ':coaid', coaid);
    dbms_sql.bind_variable(cur_stmp, ':catg', acct_category);
    dbms_sql.bind_variable(cur_stmp, ':ccid', ccid);

    dbms_sql.define_column(cur_stmp, 1, template_name, 50);
    dbms_sql.define_column(cur_stmp, 2, template_id);
    dbms_sql.define_column(cur_stmp, 3, lgr_id);

    for i in 1..30 loop
      dbms_sql.define_column(cur_stmp, i + 3, 'segment' || i || '_' ||
                             'type', 25);
    end loop;

    ignore := dbms_sql.execute(cur_stmp);
    sql_stmp_count := 0;
   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' ignore ->' || ignore);
   -- ========================= FND LOG ===========================

    loop

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' start loop');
      -- ========================= FND LOG ===========================
		test_value := dbms_sql.fetch_rows(cur_stmp);
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp test_value -> ' || test_value);
      -- ========================= FND LOG ===========================
      -- if dbms_sql.fetch_rows(cur_stmp) > 0 then
      if test_value > 0 then
          psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp -> here1');
          sql_stmp_count := sql_stmp_count + 1;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp dyn_grp_id -> ' || dyn_grp_id);
        -- ========================= FND LOG ===========================

        -- Get a new Dynamic Group ID if the number of templates > 0

        if dyn_grp_id = -1 then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfgdg');
           -- ========================= FND LOG ===========================

          if not glfgdg then
             -- ========================= FND LOG ===========================
                psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
             -- ========================= FND LOG ===========================
            goto return_invalid;
          end if;
        end if;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' Initialize the Summary Template structure');
        -- ========================= FND LOG ===========================

        -- Initialize the Summary Template structure

        for i in 1..30 loop
          seg_type(i) := null;
        end loop;

        dbms_sql.column_value(cur_stmp, 1, template_name);
        dbms_sql.column_value(cur_stmp, 2, template_id);
        dbms_sql.column_value(cur_stmp, 3, lgr_id);

	    -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp Template name -> ' || template_name);
        -- ========================= FND LOG ===========================
        for i in 1..30 loop
          dbms_sql.column_value(cur_stmp, i + 3, seg_type(i));
        end loop;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' Calling glfcrg - Identify Rollup Groups');
        -- ========================= FND LOG ===========================

        -- Identify Rollup Groups

        if not glfcrg(val_set, seg_type, rgroup, template_name) then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
           -- ========================= FND LOG ===========================
           goto return_invalid;
        end if;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' Initializing the rgroup_sorted and rgroup_ind array');
        -- ========================= FND LOG ===========================

        FOR i IN 1..30 LOOP
           rgroup_sorted(i) := null;
           rgroup_ind(i) := null;
        END LOOP;

        FOR i IN 1..30 LOOP
           IF ((rgroup(i) is not null) and (rgroup(i) not in ('D', 'T'))) then
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' rgroup(' || i || ') -> ' || rgroup(i));
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' val_set(' || i || ') -> ' || val_set(i));
        -- ========================= FND LOG ===========================

                  rgroup_ind(i) := i;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' rgroup_ind(' || i || ') -> ' || rgroup_ind(i));
        -- ========================= FND LOG ===========================
           END IF;
        END LOOP;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' Calling glfcpc - Create Parent Accounts');
        -- ========================= FND LOG ===========================

        -- Create Parent Accounts

        if not glfcpc(seg_type, rgroup, rgroup_sorted, rgroup_ind,
                      val_set, template_id, lgr_id) then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
           -- ========================= FND LOG ===========================
          goto return_invalid;
        else
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' Created_parent -> TRUE');
           -- ========================= FND LOG ===========================
          created_parent := TRUE;
        end if;

      else
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' exit ');
        -- ========================= FND LOG ===========================
        exit;
      end if;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' end loop ');
      -- ========================= FND LOG ===========================

    end loop;

    --num_templates := dbms_sql.last_row_count;
    num_templates := sql_stmp_count;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' sql_stmp: num_templates -> '|| num_templates);
    -- ========================= FND LOG ===========================

    dbms_sql.close_cursor(cur_stmp);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_valid');
    -- ========================= FND LOG ===========================

    if dbms_sql.is_open(cur_stmp) then
      dbms_sql.close_cursor(cur_stmp);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_stmp) then
        dbms_sql.close_cursor(cur_stmp);
      end if;

      -- Dynamic SQL Exception

      message_token('MSG', SQLERRM);
      message_token('SQLSTR', substr(sql_stmp, 1, 1000));
      add_message('FND', 'FLEX-DSQL EXCEPTION');

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFCST -' || SQLERRM);
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE ');
    -- ========================= FND LOG ===========================

      return(FALSE);

  END glfcst;

/* ------------------------------------------------------------------------- */

  -- Get Dynamic Group ID for the new Parent Accounts


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glfgdg RETURN BOOLEAN IS

    cursor dyngrp is
      select gl_dynamic_summ_combinations_s.NEXTVAL
        from sys.dual;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfgdg.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfgdg ');
   -- ========================= FND LOG ===========================

    open dyngrp;

    fetch dyngrp
     into dyn_grp_id;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' dyn_grp_id -> ' || dyn_grp_id);
   -- ========================= FND LOG ===========================

    if dyngrp%NOTFOUND then
      add_message('FND', 'FLEX-NO ROWS IN DUAL');
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid ');
      -- ========================= FND LOG ===========================
      goto return_invalid;
    end if;

    close dyngrp;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
   -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_invalid');
    -- ========================= FND LOG ===========================

    if dyngrp%ISOPEN then
      close dyngrp;
    end if;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
   -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      if dyngrp%ISOPEN then
        close dyngrp;
      end if;

      message_token('MSG', 'glfgdg() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN PTHERS GLFGDG - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glfgdg;

/* ------------------------------------------------------------------------- */

  -- Identify Rollup Groups


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- val_set : Value Set IDs for the Segments in the Code Combination

  -- seg_type : Summary Template Segment Types

  -- rgroup : Rollup Group for the Summary Template Segment Types

  -- template_name : Template Name


  FUNCTION glfcrg(val_set       IN     SegVsetArray,
                  seg_type      IN     SegTypeArray,
                  rgroup        IN OUT NOCOPY SegRgrpArray,
                  template_name IN     VARCHAR2) RETURN BOOLEAN IS

    i        BINARY_INTEGER;
    e_rgroup SegRgrpArray;

    cursor flexhid(vsid  NUMBER,
                   hname VARCHAR2) is
      select hierarchy_id
        from fnd_flex_hierarchies_vl
       where flex_value_set_id = vsid
         and hierarchy_name = hname;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfcrg.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfcrg ');
   -- ========================= FND LOG ===========================

    -- Initialize Rollup Groups everytime this function is invoked
    e_rgroup := rgroup;

    for i in 1..30 loop
      rgroup(i) := null;
    end loop;

    for i in 1..30 loop

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' start loop ');
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' seg_type(' || i || ') -> ' || seg_type(i));
      -- ========================= FND LOG ===========================

      if seg_type(i) is not null then

        if seg_type(i) in ('D', 'T') then
          rgroup(i) := seg_type(i);
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
             ' rgroup(' || i || ') -> ' || rgroup(i));
          -- ========================= FND LOG ===========================
        else

        begin

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
             ' val_set(' || i || ') -> ' || val_set(i));
             psa_utils.debug_other_string(g_state_level,l_full_path,
             ' seg_type(' || i || ') -> ' || seg_type(i));
          -- ========================= FND LOG ===========================

          open flexhid(val_set(i), seg_type(i));

          fetch flexhid
           into rgroup(i);

          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,
             ' rgroup(' || i || ') -> ' || rgroup(i));
          -- ========================= FND LOG ===========================

          if flexhid%NOTFOUND then

            -- Cannot find Hierarchy ID for this Rollup Group

            message_token('HNAME', seg_type(i));
            message_token('TNAME', template_name);
            add_message('FND', 'FLEXGL-CANNOT FIND HCHY ID');
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,
               ' Cannot find Hierarchy ID for this Rollup Group ');
               psa_utils.debug_other_string(g_state_level,l_full_path,
               ' goto return_invalid ');
            -- ========================= FND LOG ===========================
            goto return_invalid;

          end if;

          close flexhid;

        end;
        end if;

      end if;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' end loop ');
      -- ========================= FND LOG ===========================

    end loop;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_invalid');
    -- ========================= FND LOG ===========================

    if flexhid%ISOPEN then
      close flexhid;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN
      rgroup := e_rgroup;

      if flexhid%ISOPEN then
        close flexhid;
      end if;

      message_token('MSG', 'glfcrg() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFCRG - '|| SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glfcrg;


  -- Create Parent Accounts


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- seg_type : Summary Template Segment Types

  -- rgroup : Rollup Group for the Summary Template Segment Types

  -- rgroup_sorted : Rollup Groups sorted by Rollup Group Scores

  -- rgroup_ind : Segment Indices for the Sorted Rollup Group Scores

  -- val_set : Value Set IDs for the Segments in the Code Combination

  -- template_id : Template ID

  -- lgr_id : Ledger ID

  /*======================================================================================+
   | Bug 3805589 : This function glfcpc has been re-written to get rid of                 |
   |               the shared pool overflow issue caused by the function                  |
   |                                                                                      |
   | The logic used is to create a PL/SQL table and dump the values to be inserted        |
   | in this table. Later use the values from this table for inserting data.              |
   | The original design had a cartesian join and hence the same is implemented in this   |
   | change. The logic is implemented using 3 procedures initialize_values, assign_values |
   | and create_duplicates. Parameters passed to these procedures are as below            |
   |                                                                                      |
   | p_row         -> Row Number to be updated                                            |
   | p_segment     -> Segment to be be updated (eg. segment1, segment2 etc.)              |
   | p_val         -> Value to be updated                                                 |
   | p_status_code -> This is used to set the ledger_id                                   |
   |                                                                                      |
   | We go on assigning the value to the PL/SQL table until we find multiple parents      |
   | For the second parent we create duplicate rows and assign the new value to the       |
   | duplicated rows. This is the way cartesian is established.                           |
   | Finally we insert all rows in the table and later delete the duplicate ones          |
   | Earlier since DML was used we could make use of distinct clause but now since we are |
   | inserting via PL/SQL table we cant make use of that clause. Hence we insert all rows |
   | and later delete the duplicate ones                                                  |
   +======================================================================================*/


  FUNCTION glfcpc(seg_type      IN SegTypeArray,
                  rgroup        IN SegRgrpArray,
                  rgroup_sorted IN RgrpSrtArray,
                  rgroup_ind    IN RgrpIndArray,
                  val_set       IN SegVsetArray,
                  template_id   IN NUMBER,
                  lgr_id        IN NUMBER) RETURN BOOLEAN IS

    -- Create a PL/SQL table which will have the same structure as that of the table
    -- it will update
    Type GDSC_Table  IS TABLE OF GL_DYNAMIC_SUMM_COMBINATIONS%ROWTYPE;
    GDSC_Type   GDSC_Table := GDSC_Table();
    l_dup_rows NUMBER; -- Bug 5265341

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfcpc.';
   -- ========================= FND LOG ===========================

    PROCEDURE assign_values (p_row NUMBER, p_segment NUMBER, p_val VARCHAR2, p_status_code VARCHAR2) IS

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'assign_values.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' START assign_values ');
      psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
      psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_row         -->' || p_row );
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_segment     -->' || p_segment);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_val         -->' || p_val);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_status_code -->' || p_status_code);
   -- ========================= FND LOG ===========================

        IF (p_segment = 1) THEN
            GDSC_Type(p_row).SEGMENT1 := p_val;
        ELSIF (p_segment = 2) THEN
            GDSC_Type(p_row).SEGMENT2 := p_val;
        ELSIF (p_segment = 3) THEN
            GDSC_Type(p_row).SEGMENT3 := p_val;
        ELSIF (p_segment = 4) THEN
            GDSC_Type(p_row).SEGMENT4 := p_val;
        ELSIF (p_segment = 5) THEN
            GDSC_Type(p_row).SEGMENT5 := p_val;
        ELSIF (p_segment = 6) THEN
            GDSC_Type(p_row).SEGMENT6 := p_val;
        ELSIF (p_segment = 7) THEN
            GDSC_Type(p_row).SEGMENT7 := p_val;
        ELSIF (p_segment = 8) THEN
            GDSC_Type(p_row).SEGMENT8 := p_val;
        ELSIF (p_segment = 9) THEN
            GDSC_Type(p_row).SEGMENT9 := p_val;
        ELSIF (p_segment = 10) THEN
            GDSC_Type(p_row).SEGMENT10 := p_val;
        ELSIF (p_segment =11) THEN
            GDSC_Type(p_row).SEGMENT11 := p_val;
        ELSIF (p_segment = 12) THEN
            GDSC_Type(p_row).SEGMENT12 := p_val;
        ELSIF (p_segment = 13) THEN
            GDSC_Type(p_row).SEGMENT13 := p_val;
        ELSIF (p_segment = 14) THEN
            GDSC_Type(p_row).SEGMENT14 := p_val;
        ELSIF (p_segment = 15) THEN
            GDSC_Type(p_row).SEGMENT15 := p_val;
        ELSIF (p_segment = 16) THEN
            GDSC_Type(p_row).SEGMENT16 := p_val;
        ELSIF (p_segment = 17) THEN
            GDSC_Type(p_row).SEGMENT17 := p_val;
        ELSIF (p_segment = 18) THEN
            GDSC_Type(p_row).SEGMENT18 := p_val;
        ELSIF (p_segment = 19) THEN
            GDSC_Type(p_row).SEGMENT19 := p_val;
        ELSIF (p_segment = 20) THEN
            GDSC_Type(p_row).SEGMENT20 := p_val;
        ELSIF (p_segment = 21) THEN
            GDSC_Type(p_row).SEGMENT21 := p_val;
        ELSIF (p_segment = 22) THEN
            GDSC_Type(p_row).SEGMENT22 := p_val;
        ELSIF (p_segment = 23) THEN
            GDSC_Type(p_row).SEGMENT23 := p_val;
        ELSIF (p_segment = 24) THEN
            GDSC_Type(p_row).SEGMENT24 := p_val;
        ELSIF (p_segment = 25) THEN
            GDSC_Type(p_row).SEGMENT25 := p_val;
        ELSIF (p_segment = 26) THEN
            GDSC_Type(p_row).SEGMENT26 := p_val;
        ELSIF (p_segment = 27) THEN
            GDSC_Type(p_row).SEGMENT27 := p_val;
        ELSIF (p_segment = 28) THEN
            GDSC_Type(p_row).SEGMENT28 := p_val;
        ELSIF (p_segment = 29) THEN
            GDSC_Type(p_row).SEGMENT29 := p_val;
        ELSIF (p_segment = 30) THEN
            GDSC_Type(p_row).SEGMENT30 := p_val;
        END IF;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           'GDSC_Type(' || p_row || ').SEGMENT' || p_segment ||' ->' || p_val);
           psa_utils.debug_other_string(g_state_level,l_full_path,
           'p_status_code -> ' || p_status_code);
           psa_utils.debug_other_string(g_state_level,l_full_path,
           'GDSC_Type(' || p_row || ').LEDGER_ID ->' || GDSC_Type(p_row).LEDGER_ID);
        -- ========================= FND LOG ===========================

        IF (p_status_code = 'I') AND (GDSC_Type(p_row).LEDGER_ID IS NULL) THEN
                GDSC_Type(p_row).LEDGER_ID := -lgr_id;
                GDSC_Type(p_row).TEMPLATE_ID := -template_id;
                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   'GDSC_Type(' || p_row || ').LEDGER_ID -> -' || lgr_id);
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   'GDSC_Type(' || p_row || ').TEMPLATE_ID -> -' || template_id);
                -- ========================= FND LOG ===========================
        END IF;


   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' END assign_values ');
   -- ========================= FND LOG ===========================

    END assign_values;

    PROCEDURE initialize_values (p_segment number, p_val VARCHAR2, p_status_code VARCHAR2) IS

       -- ========================= FND LOG ===========================
          l_full_path VARCHAR2(100) := g_path ||  'initialize_values.';
       -- ========================= FND LOG ===========================

    BEGIN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' START initialize_values ');
          psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
          psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_segment     -->' || p_segment);
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_val         -->' || p_val);
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_status_code -->' || p_status_code);
       -- ========================= FND LOG ===========================

        FOR cntr IN GDSC_Type.FIRST .. GDSC_Type.LAST LOOP
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' Calling assign_values ');
            -- ========================= FND LOG ===========================
            assign_values(cntr, p_segment, p_val, p_status_code);

        END LOOP;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' END initialize_values ');
       -- ========================= FND LOG ===========================

    END initialize_values;

    PROCEDURE create_duplicates (p_segment NUMBER, p_val VARCHAR2, p_status_code VARCHAR2) IS

        l_curr_cnt NUMBER;
       -- ========================= FND LOG ===========================
          l_full_path VARCHAR2(100) := g_path ||  'create_duplicates.';
       -- ========================= FND LOG ===========================

    BEGIN

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' START create_duplicates ');
          psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
          psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
          psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_segment     -->' || p_segment);
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_val         -->' || p_val);
          psa_utils.debug_other_string(g_state_level,l_full_path,' p_status_code -->' || p_status_code);
       -- ========================= FND LOG ===========================

        l_curr_cnt := GDSC_Type.COUNT;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_curr_cnt -->' || l_curr_cnt);
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_dup_rows -->' || l_dup_rows); -- Bug 5265341
       -- ========================= FND LOG ===========================

        GDSC_Type.Extend(l_dup_rows); -- Bug 5265341

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type.COUNT extended-->' || GDSC_Type.COUNT);
       -- ========================= FND LOG ===========================


        FOR cntr IN 1..l_dup_rows LOOP  -- Bug 5265341
            GDSC_Type(l_curr_cnt + cntr) := GDSC_Type(cntr);
            -- ========================= FND LOG ===========================
               psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || cntr || ')');
            --   psa_utils.debug_other_string(g_state_level,l_full_path,
             --  ' GDSC_Type(' || l_curr_cnt + cntr || ') := GDSC_Type(' || cntr || ')');
               psa_utils.debug_other_string(g_state_level,l_full_path,' Calling assign_values');
            -- ========================= FND LOG ===========================

            assign_values(l_curr_cnt + cntr, p_segment, p_val, p_status_code);

        END LOOP;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' END create_duplicates ');
       -- ========================= FND LOG ===========================

    END create_duplicates;


  BEGIN

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
       psa_utils.debug_other_string(g_state_level,l_full_path,' START glfcpc ');
       psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
       psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
       psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
       psa_utils.debug_other_string(g_state_level,l_full_path,' template_id     -->' || template_id);
       psa_utils.debug_other_string(g_state_level,l_full_path,' lgr_id          -->' || lgr_id);
    -- ========================= FND LOG ===========================

    -- Creating the first row. Rows are later extended as required.
    GDSC_Type.Extend(1);
    l_dup_rows := 1; -- Bug 5265341

    -- Loop through 30 times and assign the values to PL/SQL table columns
    for i in 1..30 loop

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' rgroup(' || i || ') -> ' || rgroup(i));
      -- ========================= FND LOG ===========================

      if rgroup(i) is not null then

        if (rgroup(i) = 'D') then
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' Calling initialize_values- D');
          -- ========================= FND LOG ===========================
          initialize_values(i, seg_val(i), NULL);
        elsif (rgroup(i) = 'T') then
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' Calling initialize_values - T');
          -- ========================= FND LOG ===========================
          initialize_values(i, 'T', NULL);
        else
          -- ========================= FND LOG ===========================
             psa_utils.debug_other_string(g_state_level,l_full_path,' IN the else part ');
          -- ========================= FND LOG ===========================

--
-- Bug 4143033
-- ***********
-- c_get_parents modified:
-- 1. join on value_set_id
-- 2. utilization of new index on gl_summary_hierarchies
-- Bug 4191758
-- ***********
-- Added 'distinct' to select of c_get_parents to prevent excessive
-- looping.
--

            DECLARE
                CURSOR c_get_parents IS
                SELECT DISTINCT gsh.status_code, fv.flex_value
                FROM gl_summary_hierarchies gsh, fnd_flex_values fv
                WHERE gsh.flex_value_set_id = fv.flex_value_set_id
                AND gsh.parent_flex_value = fv.flex_value
                AND  (seg_val(rgroup_ind(i)) between gsh.child_flex_value_low
                                             and gsh.child_flex_value_high)
                AND gsh.flex_value_set_id = val_set(rgroup_ind(i))
                AND fv.flex_value_set_id = val_set(rgroup_ind(i))
                AND fv.structured_hierarchy_level = rgroup(rgroup_ind(i))
                AND fv.enabled_flag = 'Y';

                l_curr_val fnd_flex_values.flex_value%type;
                l_status_code gl_summary_hierarchies.status_code%type;
            BEGIN

                -- ========================= FND LOG ===========================
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   ' With in pl/sql block ');
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   'seg_val(rgroup_ind(' || i || ')) -> ' || seg_val(rgroup_ind(i)));
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   'val_set(rgroup_ind(' || i || ')) -> ' || val_set(rgroup_ind(i)));
                   psa_utils.debug_other_string(g_state_level,l_full_path,
                   ' rgroup_ind(' || i || ') -> ' || rgroup_ind(i));
                -- ========================= FND LOG ===========================

                OPEN c_get_parents;
                LOOP

                   FETCH c_get_parents INTO l_status_code, l_curr_val;

                   -- ========================= FND LOG ===========================
                      psa_utils.debug_other_string(g_state_level,l_full_path,
                      ' l_status_code -> ' || l_status_code);
                      psa_utils.debug_other_string(g_state_level,l_full_path,
                      ' l_curr_val -> ' || l_curr_val);
                      psa_utils.debug_other_string(g_state_level,l_full_path,
                      ' c_get_parents%ROWCOUNT -> ' || c_get_parents%ROWCOUNT);
                   -- ========================= FND LOG ===========================

                   EXIT WHEN c_get_parents%NOTFOUND;


                   IF (c_get_parents%ROWCOUNT) = 1 THEN
                       -- ========================= FND LOG ===========================
                          psa_utils.debug_other_string(g_state_level,l_full_path,' Calling initialize_values');
                       -- ========================= FND LOG ===========================
                           -- Since this is only first record, just set this value to all the existing rows
                           initialize_values(i, l_curr_val, l_status_code);
                           l_dup_rows := GDSC_TYPE.COUNT;  -- Bug 5265341

                       -- ========================= FND LOG ===========================
                  psa_utils.debug_other_string(g_state_level,l_full_path,' l_dup_rows set to -->' || l_dup_rows); -- Bug 5265341
                       -- ========================= FND LOG ===========================

                   ELSIF (c_get_parents%ROWCOUNT > 1) THEN
                       -- ========================= FND LOG ===========================
                          psa_utils.debug_other_string(g_state_level,l_full_path,'create_duplicates ');
                       -- ========================= FND LOG ===========================
                       -- Since this is the second parent found, first duplicate the existing rows and
                           -- assign the new value to the duplicates
                           create_duplicates(i, l_curr_val, l_status_code);

                   END IF;

                END LOOP;


                IF (c_get_parents%ROWCOUNT = 0) THEN
                    -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,' No rows found ');
                    -- ========================= FND LOG ===========================
                        -- Since query fetched now rows return TRUE
                        CLOSE c_get_parents;
                    -- ========================= FND LOG ===========================
                       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE ');
                    -- ========================= FND LOG ===========================
                        return (TRUE);
                END IF;

                CLOSE c_get_parents;

            EXCEPTION
                WHEN OTHERS THEN
                     -- ========================= FND LOG ===========================
                        psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION IN pl/sql block ');
                        psa_utils.debug_other_string(g_state_level,l_full_path,' - ' || SQLERRM);
                        psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE ');
                     -- ========================= FND LOG ===========================
                     return (FALSE);
            END;

        end if;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' rgroup(' || i || ') -> ' || rgroup(i));
        -- ========================= FND LOG ===========================

      end if;

    end loop;

    -- Insert the record using the PL/SQL table thus using bind variables.
    -- This will also insert duplicate rows. The duplicates are later removed using a delete
    -- statement. This is again to overcome a PL/SQL table limitation

    FOR i IN 1..GDSC_Type.COUNT LOOP

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Inserting into gl_dynamic_summ_combinations');
    -- ========================= FND LOG ===========================

    insert into gl_dynamic_summ_combinations (
                 dynamic_group_id,
                 code_combination_id,
                 last_update_date,
                 last_updated_by,
                 segment1,
                 segment2,
                 segment3,
                 segment4,
                 segment5,
                 segment6,
                 segment7,
                 segment8,
                 segment9,
                 segment10,
                 segment11,
                 segment12,
                 segment13,
                 segment14,
                 segment15,
                 segment16,
                 segment17,
                 segment18,
                 segment19,
                 segment20,
                 segment21,
                 segment22,
                 segment23,
                 segment24,
                 segment25,
                 segment26,
                 segment27,
                 segment28,
                 segment29,
                 segment30,
                 ledger_id,
                 template_id
                )
    VALUES      (
                 dyn_grp_id,
                 -1,
                 sysdate,
                 user_id,
                 GDSC_Type(i).SEGMENT1,
                 GDSC_Type(i).SEGMENT2,
                 GDSC_Type(i).SEGMENT3,
                 GDSC_Type(i).SEGMENT4,
                 GDSC_Type(i).SEGMENT5,
                 GDSC_Type(i).SEGMENT6,
                 GDSC_Type(i).SEGMENT7,
                 GDSC_Type(i).SEGMENT8,
                 GDSC_Type(i).SEGMENT9,
                 GDSC_Type(i).SEGMENT10,
                 GDSC_Type(i).SEGMENT11,
                 GDSC_Type(i).SEGMENT12,
                 GDSC_Type(i).SEGMENT13,
                 GDSC_Type(i).SEGMENT14,
                 GDSC_Type(i).SEGMENT15,
                 GDSC_Type(i).SEGMENT16,
                 GDSC_Type(i).SEGMENT17,
                 GDSC_Type(i).SEGMENT18,
                 GDSC_Type(i).SEGMENT19,
                 GDSC_Type(i).SEGMENT20,
                 GDSC_Type(i).SEGMENT21,
                 GDSC_Type(i).SEGMENT22,
                 GDSC_Type(i).SEGMENT23,
                 GDSC_Type(i).SEGMENT24,
                 GDSC_Type(i).SEGMENT25,
                 GDSC_Type(i).SEGMENT26,
                 GDSC_Type(i).SEGMENT27,
                 GDSC_Type(i).SEGMENT28,
                 GDSC_Type(i).SEGMENT29,
                 GDSC_Type(i).SEGMENT30,
                 DECODE(GDSC_Type(i).LEDGER_ID, NULL, lgr_id, GDSC_Type(i).LEDGER_ID),
                 DECODE(GDSC_Type(i).TEMPLATE_ID, NULL, template_id, GDSC_Type(i).TEMPLATE_ID)
                );

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' ####### START ');
       psa_utils.debug_other_string(g_state_level,l_full_path,' dynamic_group_id ->' || dyn_grp_id);
       psa_utils.debug_other_string(g_state_level,l_full_path,' code_combination_id -> -1');
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT1 ->' || GDSC_Type(i).SEGMENT1);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT2 ->' || GDSC_Type(i).SEGMENT2);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT3 ->' || GDSC_Type(i).SEGMENT3);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT4 ->' || GDSC_Type(i).SEGMENT4);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT5 ->' || GDSC_Type(i).SEGMENT5);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT6 ->' || GDSC_Type(i).SEGMENT6);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT7 ->' || GDSC_Type(i).SEGMENT7);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT8 ->' || GDSC_Type(i).SEGMENT8);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT9 ->' || GDSC_Type(i).SEGMENT9);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT10 ->' || GDSC_Type(i).SEGMENT10);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT11 ->' || GDSC_Type(i).SEGMENT11);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT12 ->' || GDSC_Type(i).SEGMENT12);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT13 ->' || GDSC_Type(i).SEGMENT13);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT14 ->' || GDSC_Type(i).SEGMENT14);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT15 ->' || GDSC_Type(i).SEGMENT15);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT16 ->' || GDSC_Type(i).SEGMENT16);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT17 ->' || GDSC_Type(i).SEGMENT17);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT18 ->' || GDSC_Type(i).SEGMENT18);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT19 ->' || GDSC_Type(i).SEGMENT19);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT20 ->' || GDSC_Type(i).SEGMENT20);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT21 ->' || GDSC_Type(i).SEGMENT21);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT22 ->' || GDSC_Type(i).SEGMENT22);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT23 ->' || GDSC_Type(i).SEGMENT23);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT24 ->' || GDSC_Type(i).SEGMENT24);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT25 ->' || GDSC_Type(i).SEGMENT25);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT26 ->' || GDSC_Type(i).SEGMENT26);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT27 ->' || GDSC_Type(i).SEGMENT27);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT28 ->' || GDSC_Type(i).SEGMENT28);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT29 ->' || GDSC_Type(i).SEGMENT29);
       psa_utils.debug_other_string(g_state_level,l_full_path,' GDSC_Type(' || i || ').SEGMENT30 ->' || GDSC_Type(i).SEGMENT30);
       IF GDSC_Type(i).LEDGER_ID IS NULL THEN
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' GDSC_Type(' || i || ').LEDGER_ID - lgr_id ->' || lgr_id);
       ELSE
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' GDSC_Type(' || i || ').LEDGER_ID ->' || GDSC_Type(i).LEDGER_ID);
       END IF;
       IF GDSC_Type(i).TEMPLATE_ID IS NULL THEN
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' GDSC_Type(' || i || ').TEMPLATE_ID - template_id ->' || template_id);
       ELSE
          psa_utils.debug_other_string(g_state_level,l_full_path,
          ' GDSC_Type(' || i || ').TEMPLATE_ID ->' || GDSC_Type(i).TEMPLATE_ID);
       END IF;
       psa_utils.debug_other_string(g_state_level,l_full_path,' ####### END');
    -- ========================= FND LOG ===========================


    END LOOP;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' DELETEING DUPLICATE ROWS.');
    -- ========================= FND LOG ===========================


    -- Delete the duplicate rows for this dynamic group id.
    -- This will not delete rows which have negative lgr and template ids
    DELETE FROM gl_dynamic_summ_combinations
    WHERE rowid NOT IN (SELECT min(rowid)
                        FROM gl_dynamic_summ_combinations
                        WHERE dynamic_group_id = dyn_grp_id
                        GROUP BY dynamic_group_id,
                                 ledger_id,
                                 template_id,
                                 segment1,
                                 segment2,
                                 segment3,
                                 segment4,
                                 segment5,
                                 segment6,
                                 segment7,
                                 segment8,
                                 segment9,
                                 segment10,
                                 segment11,
                                 segment12,
                                 segment13,
                                 segment14,
                                 segment15,
                                 segment16,
                                 segment17,
                                 segment18,
                                 segment19,
                                 segment20,
                                 segment21,
                                 segment22,
                                 segment23,
                                 segment24,
                                 segment25,
                                 segment26,
                                 segment27,
                                 segment28,
                                 segment29,
                                 segment30)
        and dynamic_group_id = dyn_grp_id;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' DELETE FROM gl_dynamic_summ_combinations -> ' || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================

       -- bug 4130352 start

      -- delete duplicate negative ledger_id/template_id rows where there is a
      -- matching positive ledger_id/template_id row for this dyn_grp_id
      -- having the same segment values.
      -- CCID at this point cannot be relied upon as it could be -1

      FOR crec in (SELECT abs(ledger_id) ledger_id,
                        abs(template_id)     template_id,
                        segment1,  segment2,  segment3,
                        segment4,  segment5,  segment6,
                        segment7,  segment8,  segment9,
                        segment10, segment11, segment12,
                        segment13, segment14, segment15,
                        segment16, segment17, segment18,
                        segment19, segment20, segment21,
                        segment22, segment23, segment24,
                        segment25, segment26, segment27,
                        segment28, segment29, segment30
                  FROM  gl_dynamic_summ_combinations
                        WHERE dynamic_group_id = dyn_grp_id
                        GROUP BY dynamic_group_id,
                                   abs(ledger_id),
                                   abs(template_id),
                                   segment1,  segment2,  segment3,
                                   segment4,  segment5,  segment6,
                                   segment7,  segment8,  segment9,
                                   segment10, segment11, segment12,
                                   segment13, segment14, segment15,
                                   segment16, segment17, segment18,
                                   segment19, segment20, segment21,
                                   segment22, segment23, segment24,
                                   segment25, segment26, segment27,
                                   segment28, segment29, segment30
                        HAVING count(*) > 1)
     LOOP

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,' Inside crec cursor');
        -- ========================= FND LOG ===========================

        DELETE from gl_dynamic_summ_combinations
        WHERE ledger_id   = -1 * crec.ledger_id
        AND   template_id       = -1 * crec.template_id
        AND   dynamic_group_id  = dyn_grp_id
        AND   nvl(segment1,g_segment_nvl_value)          = nvl(crec.segment1,g_segment_nvl_value)
        AND   nvl(segment2,g_segment_nvl_value)          = nvl(crec.segment2,g_segment_nvl_value)
        AND   nvl(segment3,g_segment_nvl_value)          = nvl(crec.segment3,g_segment_nvl_value)
        AND   nvl(segment4,g_segment_nvl_value)          = nvl(crec.segment4,g_segment_nvl_value)
        AND   nvl(segment5,g_segment_nvl_value)          = nvl(crec.segment5,g_segment_nvl_value)
        AND   nvl(segment6,g_segment_nvl_value)          = nvl(crec.segment6,g_segment_nvl_value)
        AND   nvl(segment7,g_segment_nvl_value)          = nvl(crec.segment7,g_segment_nvl_value)
        AND   nvl(segment8,g_segment_nvl_value)          = nvl(crec.segment8,g_segment_nvl_value)
        AND   nvl(segment9,g_segment_nvl_value)          = nvl(crec.segment9,g_segment_nvl_value)
        AND   nvl(segment10,g_segment_nvl_value)         = nvl(crec.segment10,g_segment_nvl_value)
        AND   nvl(segment11,g_segment_nvl_value)         = nvl(crec.segment11,g_segment_nvl_value)
        AND   nvl(segment12,g_segment_nvl_value)         = nvl(crec.segment12,g_segment_nvl_value)
        AND   nvl(segment13,g_segment_nvl_value)         = nvl(crec.segment13,g_segment_nvl_value)
        AND   nvl(segment14,g_segment_nvl_value)         = nvl(crec.segment14,g_segment_nvl_value)
        AND   nvl(segment15,g_segment_nvl_value)         = nvl(crec.segment15,g_segment_nvl_value)
        AND   nvl(segment16,g_segment_nvl_value)         = nvl(crec.segment16,g_segment_nvl_value)
        AND   nvl(segment17,g_segment_nvl_value)         = nvl(crec.segment17,g_segment_nvl_value)
        AND   nvl(segment18,g_segment_nvl_value)         = nvl(crec.segment18,g_segment_nvl_value)
        AND   nvl(segment19,g_segment_nvl_value)         = nvl(crec.segment19,g_segment_nvl_value)
        AND   nvl(segment20,g_segment_nvl_value)         = nvl(crec.segment20,g_segment_nvl_value)
        AND   nvl(segment21,g_segment_nvl_value)         = nvl(crec.segment21,g_segment_nvl_value)
        AND   nvl(segment22,g_segment_nvl_value)         = nvl(crec.segment22,g_segment_nvl_value)
        AND   nvl(segment23,g_segment_nvl_value)         = nvl(crec.segment23,g_segment_nvl_value)
        AND   nvl(segment24,g_segment_nvl_value)         = nvl(crec.segment24,g_segment_nvl_value)
        AND   nvl(segment25,g_segment_nvl_value)         = nvl(crec.segment25,g_segment_nvl_value)
        AND   nvl(segment26,g_segment_nvl_value)         = nvl(crec.segment26,g_segment_nvl_value)
        AND   nvl(segment27,g_segment_nvl_value)         = nvl(crec.segment27,g_segment_nvl_value)
        AND   nvl(segment28,g_segment_nvl_value)         = nvl(crec.segment28,g_segment_nvl_value)
        AND   nvl(segment29,g_segment_nvl_value)         = nvl(crec.segment29,g_segment_nvl_value)
        AND   nvl(segment30,g_segment_nvl_value)         = nvl(crec.segment30,g_segment_nvl_value);

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' DELETE FROM gl_dynamic_summ_combinations II -> ' || SQL%ROWCOUNT);
        -- ========================= FND LOG ===========================

      END LOOP;

      --bug 4130352 end

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return (TRUE);

  EXCEPTION

    WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS - glfcpc ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      -- Dynamic SQL Exception
      message_token('MSG', SQLERRM);
      message_token('SQLSTR', 'INSERT INTO GL_DYNAMIC_SUMM_COMBINATIONS ...');
      add_message('FND', 'FLEXGL-DSQL EXCEPTION');

      return(FALSE);

  END glfcpc;

/* ------------------------------------------------------------------------- */

  -- Lock Summary Templates


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glflst RETURN BOOLEAN IS

    tmpmsg VARCHAR2(100);

    cursor lockst(dyn_grp_id NUMBER) is
      select 'Obtain Row Share Lock on the ' ||
             'corresponding record of this template in ' ||
             'gl_concurrency_control'
        from gl_concurrency_control ct
       where ct.concurrency_class = 'INSERT_SUMMARY_ACCOUNTS'
         and ct.concurrency_entity_name = 'SUMMARY_TEMPLATE'
         and exists (
                     select 1
                       from gl_dynamic_summ_combinations dsc
                      where to_char(abs(dsc.template_id)) = ct.concurrency_entity_id
                        and dsc.dynamic_group_id = dyn_grp_id
                    )
      FOR UPDATE;
      -- FOR UPDATE NOWAIT; -- Bug 4074489

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glflst.';
   -- ========================= FND LOG ===========================

  BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glflst ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' dyn_grp_id -> ' || dyn_grp_id);
   -- ========================= FND LOG ===========================

    -- All rows are locked when the Cursor is opened; these rows are unlocked
    -- after commit or rollback of the fdfgli routine

    open lockst(dyn_grp_id);

    fetch lockst
     into tmpmsg;

    close lockst;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' LOCKING gl_concurrency_control ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE ');
   -- ========================= FND LOG ===========================

    return(TRUE);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      if lockst%ISOPEN then
        close lockst;
      end if;

      message_token('MSG', 'glflst() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION NO_DATA_FOUND - glflst ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

    WHEN OTHERS THEN

      if lockst%ISOPEN then
        close lockst;
      end if;

      message_token('TABLE', 'GL_CONCURRENCY_CONTROL');
      add_message('FND', 'FORM-CANNOT LOCK');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION OTHERS - glflst ');
         psa_utils.debug_other_string(g_state_level,l_full_path,' - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glflst;

/* ------------------------------------------------------------------------- */

  -- Find CCIDs for existing Code Combinations


  -- Called Routines :

  -- dsql_execute : Execute a Dynamic SQL Statement with no Bind Variables


  FUNCTION glfaec RETURN BOOLEAN IS

    -- Maximum Length for this Dynamic SQL Statement is 1393 assuming there
    -- is a 30 Segment Flexfield

    sql_statement  VARCHAR2(1800);
    num_rows       INTEGER;

    i              BINARY_INTEGER;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfaec.';
   -- ========================= FND LOG ===========================

  BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfaec ');
   -- ========================= FND LOG ===========================

    sql_statement := 'update gl_dynamic_summ_combinations tc1 ' ||
                     'set code_combination_id = (' ||
                     'select nvl(cc.code_combination_id, -1) ' ||
                     'from gl_code_combinations cc, ' ||
                     'gl_dynamic_summ_combinations tc2 ' ||
                     'where cc.template_id(+) = abs(tc1.template_id) ' ||
                     'and cc.chart_of_accounts_id(+) = ' || coaid || ' ';

    for i in 1..30 loop
      if seg_val(i) is not null then
        sql_statement := sql_statement ||
                         'and cc.segment' || i || '(+) = ' ||
                         'tc2.segment' || i || ' ';
      end if;
    end loop;

    sql_statement := sql_statement ||
                     'and tc2.rowid = tc1.rowid) ' ||
                     'where tc1.dynamic_group_id = ' || dyn_grp_id;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' sql_statement -> ' || sql_statement);
    -- ========================= FND LOG ===========================

    num_rows := dsql_execute(sql_statement);

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'num_rows -> ' || num_rows);
    -- ========================= FND LOG ===========================

    if num_rows < 0 then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,'RETURN -> FALSE');
       -- ========================= FND LOG ===========================
      return(FALSE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

  END glfaec;

/* ------------------------------------------------------------------------- */

  -- Assign new CCIDs to new Code Combinations


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glfanc RETURN BOOLEAN IS

    cursor ccid_seq is
      select gl_code_combinations_s.NEXTVAL
        from sys.dual;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfanc.';
   -- ========================= FND LOG ===========================

  BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfanc ');
   -- ========================= FND LOG ===========================

    open ccid_seq;

    fetch ccid_seq
     into min_ccid;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' min_ccid -> ' || min_ccid);
   -- ========================= FND LOG ===========================

    if ccid_seq%NOTFOUND then
      add_message('FND', 'FLEX-NO ROWS IN DUAL');
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
      -- ========================= FND LOG ===========================
      goto return_invalid;
    end if;

    update gl_dynamic_summ_combinations
       set code_combination_id = gl_code_combinations_s.NEXTVAL
     where code_combination_id = -1
       and dynamic_group_id = dyn_grp_id;

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' update gl_dynamic_summ_combinations -' || SQL%ROWCOUNT);
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' RETURN -> TRUE');
      -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' LABEL -> return_invalid');
    -- ========================= FND LOG ===========================

    if ccid_seq%ISOPEN then
      close ccid_seq;
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' RETURN -> FALSE');
    -- ========================= FND LOG ===========================

    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      if ccid_seq%ISOPEN then
        close ccid_seq;
      end if;

      message_token('MSG', 'glfanc() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' EXCEPTION WHEN OTHERS - ' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glfanc;

/* ------------------------------------------------------------------------- */

  -- Insert newly created Parent Accounts into Code Combinations table


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glficc RETURN BOOLEAN IS

    -- Maximum Length for this Dynamic SQL Statement is 1144

    sql_inscc   VARCHAR2(1800);
    cur_inscc   INTEGER;
    num_rows    INTEGER;
    i           BINARY_INTEGER;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glficc.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glficc ');
   -- ========================= FND LOG ===========================

    sql_inscc := 'insert into gl_code_combinations (' ||
                 'code_combination_id, ' ||
                 'last_update_date, ' ||
                 'last_updated_by, ' ||
                 'chart_of_accounts_id, ' ||
                 'detail_posting_allowed_flag, ' ||
                 'detail_budgeting_allowed_flag, ' ||
                 'account_type, ' ||
                 'enabled_flag, ' ||
                 'summary_flag, ' ||
                 'template_id, ' ||
                 'allocation_create_flag, ' ||
                 'start_date_active, ' ||
                 'end_date_active';

    for i in 1..30 loop
      sql_inscc := sql_inscc ||
                   ', segment' || i;
    end loop;

    sql_inscc := sql_inscc ||
                 ') ';

    sql_inscc := sql_inscc ||
                 'select ' ||
                 'code_combination_id, ' ||
                 'sysdate, ' ||
                 ':user_id, ' ||
                 ':coaid, ' ||
                 '''N'', ' ||
                 '''N'', ' ||
                 '''O'', ' ||
                 '''Y'', ' ||
                 '''Y'', ' ||
                 'abs(template_id), ' ||
                 '''Y'', ' ||
                 'null, ' ||
                 'null';

    for i in 1..30 loop
      sql_inscc := sql_inscc ||
                   ', segment' || i;
    end loop;

    sql_inscc := sql_inscc ||
                 ' from gl_dynamic_summ_combinations dsc ' ||
                 'where dynamic_group_id = :grp_id ' ||
                 'and code_combination_id > :min_ccid';

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_inscc -> ' || sql_inscc);
   -- ========================= FND LOG ===========================

    cur_inscc := dbms_sql.open_cursor;
    dbms_sql.parse(cur_inscc, sql_inscc, dbms_sql.v7);

    dbms_sql.bind_variable(cur_inscc, ':user_id', user_id);
    dbms_sql.bind_variable(cur_inscc, ':coaid', coaid);
    dbms_sql.bind_variable(cur_inscc, ':grp_id', dyn_grp_id);
    dbms_sql.bind_variable(cur_inscc, ':min_ccid', min_ccid);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' user_id    -> ' || user_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' coaid      -> ' || coaid);
      psa_utils.debug_other_string(g_state_level,l_full_path,' dyn_grp_id -> ' || dyn_grp_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' min_ccid   -> ' || min_ccid);
   -- ========================= FND LOG ===========================

    num_rows := dbms_sql.execute(cur_inscc);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_rows -> ' || num_rows);
   -- ========================= FND LOG ===========================

    dbms_sql.close_cursor(cur_inscc);


    -- Call API to update account types of the summary accounts
    BEGIN

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' Calling GL_SUMMARY_ACCOUNT_TYPES_PKG.update_account_types');
      -- ========================= FND LOG ===========================

      GL_SUMMARY_ACCOUNT_TYPES_PKG.update_account_types(coaid, min_ccid);

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' After GL_SUMMARY_ACCOUNT_TYPES_PKG.update_account_types');
      -- ========================= FND LOG ===========================

    EXCEPTION

      WHEN GL_SUMMARY_ACCOUNT_TYPES_PKG.invalid_combination THEN

        add_message('SQLGL', 'GL_FLEX_ACC_TYPE_INVALID_COMB');
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
           ' GL_SUMMARY_ACCOUNT_TYPES_PKG RETURN -> FALSE');
        -- ========================= FND LOG ===========================
        return(FALSE);

      WHEN OTHERS THEN
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' EXCEPTION WHEN OTHERS GL_SUMMARY_ACCOUNT_TYPES_PKG - ' || SQLERRM);
      -- ========================= FND LOG ===========================

        RAISE;
    END;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,
       ' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_inscc) then
        dbms_sql.close_cursor(cur_inscc);
      end if;

      -- Dynamic SQL Exception

      message_token('MSG', SQLERRM);
      message_token('SQLSTR', substr(sql_inscc, 1, 1000));
      add_message('FND', 'FLEX-DSQL EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
         ' GLFICC RETURN -> FALSE ' || SQLERRM);
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glficc;

/* ------------------------------------------------------------------------- */

  -- Maintain Account Hierarchies


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glfmah(ccid IN NUMBER) RETURN BOOLEAN IS

    -- Maximum Length of this Dynamic SQL Statement is 510

    sql_acchy   VARCHAR2(800);
    cur_acchy   INTEGER;
    num_rows    INTEGER;


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfmah.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfmah ');
   -- ========================= FND LOG ===========================

    sql_acchy := 'insert into gl_account_hierarchies (' ||
                 'ledger_id, ' ||
                 'summary_code_combination_id, ' ||
                 'detail_code_combination_id, ' ||
                 'template_id, ' ||
                 'last_updated_by, ' ||
                 'last_update_date, ' ||
                 'ordering_value) ';

    sql_acchy := sql_acchy ||
                 'select ledger_id, ' ||
                 'code_combination_id, ' ||
                 ':ccid, ' ||
                 'template_id, ' ||
                 ':user_id, ' ||
                 'sysdate, ' ||
                 ':ordering_value ' ||
                 'from gl_dynamic_summ_combinations dsc ' ||
                 'where dsc.dynamic_group_id = :grp_id ' ||
                 'and not exists (' ||
                 'select 1 ' ||
                 'from gl_account_hierarchies ah ' ||
                 'where ah.summary_code_combination_id = ' ||
                 'dsc.code_combination_id ' ||
                 'and ah.detail_code_combination_id = :ccid)';

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' sql_acchy -> ' || sql_acchy);
   -- ========================= FND LOG ===========================

    cur_acchy := dbms_sql.open_cursor;
    dbms_sql.parse(cur_acchy, sql_acchy, dbms_sql.v7);

    dbms_sql.bind_variable(cur_acchy, ':ccid', ccid);
    dbms_sql.bind_variable(cur_acchy, ':user_id', user_id);
    dbms_sql.bind_variable(cur_acchy, ':ordering_value',
                           seg_val(acct_seg_index));
    dbms_sql.bind_variable(cur_acchy, ':grp_id', dyn_grp_id);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' ccid -> ' || ccid);
      psa_utils.debug_other_string(g_state_level,l_full_path,' user_id -> ' || user_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' dyn_grp_id -> ' || dyn_grp_id);
   -- ========================= FND LOG ===========================

    num_rows := dbms_sql.execute(cur_acchy);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' num_rows -> ' || num_rows);
   -- ========================= FND LOG ===========================

    dbms_sql.close_cursor(cur_acchy);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
   -- ========================= FND LOG ===========================

    return(TRUE);


  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cur_acchy) then
        dbms_sql.close_cursor(cur_acchy);
      end if;

      -- Dynamic SQL Exception

      message_token('MSG', SQLERRM);
      message_token('SQLSTR', substr(sql_acchy, 1, 1000));
      add_message('FND', 'FLEX-DSQL EXCEPTION');

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS - '||SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================

      return(FALSE);

  END glfmah;

/* ------------------------------------------------------------------------- */

  -- Maintain Reporting Attributes

  -- This function is used to maintain the reporting attribute segments
  -- for a new ccid created; it also maintains the reporting attributes
  -- for any new summary accounts that have been created.

  -- Reporting Attributes are maintained only for Government GL install
  -- when the reporting attribute profile is set.

  -- This function returns TRUE for non-Government install and when
  -- the Reporting Attributes profile is not set.

  -- This function first updates the reporting attributes for a detail
  -- account; it then goes thru the gl_dynamic_summ_combinations table
  -- to update the reporting attributes for all the summary accounts that
  -- have been created.


  -- Called Routines :

  -- FND_PROFILE.GET_SPECIFIC : Get Profile Value

  -- glfupd : Update Segment Attributes in the Code Combinations table

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glgfdi(ccid IN NUMBER) RETURN BOOLEAN IS

    cursor SummAcct(grp_id   number,
                    min_ccid number) IS
      select code_combination_id ccid
        from gl_dynamic_summ_combinations
       where dynamic_group_id = grp_id
         and code_combination_id >= min_ccid;

    value    fnd_profile_option_values.profile_option_value%TYPE;
    defined  BOOLEAN;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glgfdi.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glgfdi ');
   -- ========================= FND LOG ===========================

    -- Check if this is a OGF installation

    if industry <> 'G' then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Industry G  RETURN -> TRUE');
       -- ========================= FND LOG ===========================
       return(TRUE);
    end if;


    -- Check Reporting Attribute profile

    FND_PROFILE.GET_SPECIFIC('ATTRIBUTE_REPORTING',
                             user_id,
                             user_resp_id,
                             101,
                             value,
                             defined);


    -- If Reporting Attributes profile option is not set return TRUE

    if not defined then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' Reporting Attributes not defined');
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
       -- ========================= FND LOG ===========================
       return(TRUE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfupd ');
    -- ========================= FND LOG ===========================

    if not glfupd(ccid) then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' GLFUPD RETURN -> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' num_bc_lgr -> ' || num_bc_lgr);
    -- ========================= FND LOG ===========================

   -- repeat for all the summary accounts that have been created
   if num_bc_lgr > 0 then

      for c_SummAcct in SummAcct(dyn_grp_id, min_ccid) loop

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' c_SummAcct.ccid -> ' || c_SummAcct.ccid);
          psa_utils.debug_other_string(g_state_level,l_full_path,' Calling glfupd ');
       -- ========================= FND LOG ===========================

        if not glfupd(c_SummAcct.ccid) then
           -- ========================= FND LOG ===========================
              psa_utils.debug_other_string(g_state_level,l_full_path,' goto return_invalid');
           -- ========================= FND LOG ===========================
           goto return_invalid;
        end if;

      end loop;

    end if;

    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
    -- ========================= FND LOG ===========================

    return(TRUE);

    <<return_invalid>>
    -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,' LABEL - return_invalid');
       psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
    -- ========================= FND LOG ===========================
    return(FALSE);


  EXCEPTION

    WHEN OTHERS THEN

      message_token('MSG', 'glgfdi() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');
      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHER GLGFDI -' || SQLERRM);
         psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
      -- ========================= FND LOG ===========================
      return(FALSE);

  END glgfdi;

/* ------------------------------------------------------------------------ */

  -- Update Segment Attributes in the Code Combinations table

  -- This function updates the segment_attribute1..42 columns in the
  -- gl_code_combination table

  -- SQL statement for the update is constructed dynamically from the
  -- definition fnd_flex tables; the SQL will be in this form:
  --
  -- UPDATE gl_code_combinations glcc set
  -- segment_attribute1 = (select attribute2
  --                     from fnd_flex_values ffval
  --                     where ffval.flex_value_set_id = 1234
  --                     and   enable_flag = 'Y'
  --                     and   ffval.flex_value = glcc.segment1)
  -- segment_attribute2 = (select ....)
  -- ...
  -- last_update_by = user_id
  -- last_updated_date = sysdate
  -- where glcc.code_combination = ccid


  -- Called Routines :

  -- dsql_execute : Execute a Dynamic SQL Statement with no Bind Variables

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  FUNCTION glfupd(ccid IN NUMBER) RETURN BOOLEAN IS

    cursor RptAttr(flex_num NUMBER) IS
      select attr.flex_value_set_id vsid,
             nvl(attr.attribute_num, '') attr_name,
             attr.table_id table_id,
             nvl(attr.application_column_name, '') col_name,
             nvl(attr.segment_name, '') seg_name,
             attr.segment_num seg_num,
             nvl(attr.attr_segment_name, '') aseg_name,
             nvl(valset.validation_type, '') vtype,
             valset.parent_flex_value_set_id parent_vsid
        from fnd_seg_rpt_attributes attr,
             fnd_flex_value_sets valset
       where attr.application_id = 101
         and valset.flex_value_set_id = attr.flex_value_set_id
         and attr.id_flex_num = flex_num
       order by attr.segment_num;

    update_cl       VARCHAR2(10000);

    vsid_array      SegVsetArray;
    vseg_array      TabColArray;
    attr_num        NUMBER := 1;

    parentval       VARCHAR2(20);
    vs_column_name  VARCHAR2(30);
    vs_table_name   VARCHAR2(30);


   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) := g_path ||  'glfupd.';
   -- ========================= FND LOG ===========================

    BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' START glfupd ');
   -- ========================= FND LOG ===========================

    update_cl := 'UPDATE gl_code_combinations glcc SET ';

    for c_RptAttr in RptAttr(coaid) loop

      vsid_array(attr_num) := c_RptAttr.vsid;
      vseg_array(attr_num) := c_RptAttr.seg_name;

      if c_RptAttr.vtype <> 'F' then

        update_cl := update_cl ||
                     c_RptAttr.aseg_name ||
                     ' = (select ' || c_RptAttr.attr_name ||
                     ' from fnd_flex_values ffval '||
                     ' where ffval.flex_value_set_id = ' || c_RptAttr.vsid ||
                     ' and enabled_flag = ''Y''' ||
                     ' and ffval.flex_value = glcc.' || c_RptAttr.seg_name;

        -- Dependent Value Set

        if c_RptAttr.parent_vsid is NOT NULL then

          for i in reverse 1..attr_num loop

            if (c_RptAttr.parent_vsid = vsid_array(i)) then
              parentval := vseg_array(i);
              exit;
            end if;

          end loop;

          update_cl := update_cl ||
                       ' and parent_flex_value_low = glcc.'|| parentval;

        end if;

        update_cl := update_cl || '), ';

      -- Column is table validated

      else

        select user_table_name
          into vs_table_name
          from fnd_tables
         where application_id = 101
           and table_id = c_RptAttr.table_id;

        select value_column_name
          into vs_column_name
          from fnd_flex_validation_tables
         where flex_value_set_id = c_RptAttr.vsid;

        update_cl := update_cl ||
                     c_RptAttr.aseg_name ||
                     ' = ( select ' || c_RptAttr.col_name ||
                     ' from ' || vs_table_name ||
                     ' where ' || vs_column_name || ' = glcc.' ||
                     c_RptAttr.seg_name || ' ), ';

      end if;

      attr_num := attr_num + 1;

    end loop;

    update_cl := update_cl ||
                 'last_update_date = sysdate, ' ||
                 'last_updated_by = ' || user_id ||
                 ' where glcc.code_combination_id = ' || ccid;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' update_cl -> ' || SUBSTR(update_cl,1,3000));
      psa_utils.debug_other_string(g_state_level,l_full_path,' update_cl -> ' || SUBSTR(update_cl,3000,6000));
   -- ========================= FND LOG ===========================

    if dsql_execute(update_cl) < 0 then
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> FALSE');
       -- ========================= FND LOG ===========================
       return(FALSE);
    else
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN -> TRUE');
       -- ========================= FND LOG ===========================
       return(TRUE);
    end if;


  EXCEPTION

    WHEN OTHERS THEN

      message_token('MSG', 'glfupd() exception:' || SQLERRM);
      add_message('FND', 'FLEX-SSV EXCEPTION');
       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' EXCEPTION WHEN OTHERS GLFUPD - ' || SQLERRM);
          psa_utils.debug_other_string(g_state_level,l_full_path,' RETURN FALSE');
       -- ========================= FND LOG ===========================
      return(FALSE);

  END glfupd;

/* ----------------------------------------------------------------------- */

  -- Add Token and Value to the Message Token array


  -- Arguments :

  -- tokname : Token Name

  -- tokval : Token Value


  PROCEDURE message_token(tokname IN VARCHAR2,
                          tokval  IN VARCHAR2) IS

  BEGIN

    if no_msg_tokens is null then
      no_msg_tokens := 1;
    else
      no_msg_tokens := no_msg_tokens + 1;
    end if;

    msg_tok_names(no_msg_tokens) := tokname;
    msg_tok_val(no_msg_tokens) := tokval;

  END message_token;

/* ----------------------------------------------------------------------- */

  -- Define a Message Token with a Value and set the Message Name

  -- Calls FND_MESSAGE server package to set the Message Stack. This message is
  -- retrieved by the calling program.


  -- Called Routines :

  -- FND_MESSAGE.SET_NAME : Set Message Name

  -- FND_MESSAGE.SET_TOKEN : Defines a Message Token with a Value


  -- Arguments :

  -- appname : Application Short Name

  -- msgname : Message Name


  PROCEDURE add_message(appname IN VARCHAR2,
                        msgname IN VARCHAR2) IS

    i  BINARY_INTEGER;

  BEGIN

    if ((appname is not null) and
        (msgname is not null)) then

      FND_MESSAGE.SET_NAME(appname, msgname);

      if no_msg_tokens is not null then
        for i in 1..no_msg_tokens loop
          FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
        end loop;
      end if;

    end if;


    -- Clear Message Token stack

    no_msg_tokens := 0;

  END add_message;

/* ----------------------------------------------------------------------- */

  -- Execute a Dynamic SQL Statement with no Bind Variables

  -- Returns number of rows processed or -1 if error (add_message)
  -- Return Value is valid only for insert, update and delete statements


  -- Called Routines :

  -- message_token : Add Token and Value to the Message Token array

  -- add_message : Update global Message String


  -- Arguments :

  -- sql_statement : SQL Statement


  FUNCTION dsql_execute(sql_statement IN VARCHAR2) RETURN NUMBER IS

    cursornum   INTEGER;
    nprocessed  INTEGER;

  BEGIN

    cursornum := dbms_sql.open_cursor;
    dbms_sql.parse(cursornum, sql_statement, dbms_sql.v7);
    nprocessed := dbms_sql.execute(cursornum);
    dbms_sql.close_cursor(cursornum);
    return(nprocessed);

  EXCEPTION

    WHEN OTHERS THEN

      if dbms_sql.is_open(cursornum) then
        dbms_sql.close_cursor(cursornum);
      end if;

      -- Dynamic SQL Exception

      message_token('MSG', SQLERRM);
      message_token('SQLSTR', substr(sql_statement, 1, 1000));
      add_message('FND', 'FLEXGL-DSQL EXCEPTION');

      return(-1);

  END dsql_execute;

/* ----------------------------------------------------------------------- */

END GL_FLEX_INSERT_PKG;

/
