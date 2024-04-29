--------------------------------------------------------
--  DDL for Package Body CZ_FCE_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_FCE_COMPILE" AS
/*	$Header: czfcecpb.pls 120.91.12010000.4 2010/05/10 11:43:21 vsingava ship $		*/
---------------------------------------------------------------------------------------
const_epoch_begin              CONSTANT DATE          := cz_utils.epoch_begin_;
const_epoch_end                CONSTANT DATE          := cz_utils.epoch_end_;
const_java_epoch_begin         CONSTANT DATE          := TO_DATE ('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS');

const_file_signature           CONSTANT RAW(4)        := HEXTORAW ('00000000');

const_logicfile_def            CONSTANT PLS_INTEGER   := 1;
const_logicfile_port           CONSTANT PLS_INTEGER   := 2;
const_logicfile_constraint     CONSTANT PLS_INTEGER   := 3;

const_domainorder_minfirst     CONSTANT PLS_INTEGER   := 1;
const_domainorder_maxfirst     CONSTANT PLS_INTEGER   := 2;
const_domainorder_decmax       CONSTANT PLS_INTEGER   := 3;
const_domainorder_incmin       CONSTANT PLS_INTEGER   := 4;
const_domainorder_preffalse    CONSTANT PLS_INTEGER   := 5;
const_domainorder_preftrue     CONSTANT PLS_INTEGER   := 6;

const_max_localvariables       CONSTANT PLS_INTEGER   := 256;
const_max_registers            CONSTANT PLS_INTEGER   := 65536;

const_constantpool_maxsize     CONSTANT PLS_INTEGER   := 65536;
const_constantpool_buffersize  CONSTANT PLS_INTEGER   := 32768;

const_codememory_buffersize    CONSTANT PLS_INTEGER   := 32768;

const_min_double               CONSTANT BINARY_DOUBLE := -1E+100D;
const_max_double               CONSTANT BINARY_DOUBLE := 1E+100D;
const_max_instance_set         CONSTANT PLS_INTEGER   := 100;

const_context_generic          CONSTANT PLS_INTEGER   := 0;
const_context_target           CONSTANT PLS_INTEGER   := 1;
const_context_contributor      CONSTANT PLS_INTEGER   := 2;
const_context_literal          CONSTANT PLS_INTEGER   := 3;
const_context_accumulation     CONSTANT PLS_INTEGER   := 4;
const_context_logical          CONSTANT PLS_INTEGER   := 5;
const_context_forall           CONSTANT PLS_INTEGER   := 6;
const_context_compatible       CONSTANT PLS_INTEGER   := 7;
const_context_selection        CONSTANT PLS_INTEGER   := 8;
const_context_numeric          CONSTANT PLS_INTEGER   := 9;
const_context_constant         CONSTANT PLS_INTEGER   := 10;
const_context_heuristics       CONSTANT PLS_INTEGER   := 11;
const_context_aggregatesum     CONSTANT PLS_INTEGER   := 12;

const_no_instances             CONSTANT PLS_INTEGER   := 0;
const_quantifier_created       CONSTANT PLS_INTEGER   := 1;
const_resourcesum_required     CONSTANT PLS_INTEGER   := 2;

const_ruletype_compatible      CONSTANT PLS_INTEGER   := 0;
const_ruletype_forall          CONSTANT PLS_INTEGER   := 1;

const_valuetype_unknown        CONSTANT PLS_INTEGER   := -1;
const_valuetype_node           CONSTANT PLS_INTEGER   := 0;
const_valuetype_literal        CONSTANT PLS_INTEGER   := 1;
const_valuetype_variable       CONSTANT PLS_INTEGER   := 2;
const_valuetype_selection      CONSTANT PLS_INTEGER   := 3;
const_valuetype_sysprop        CONSTANT PLS_INTEGER   := 4;

const_textid_resultnotvalid    CONSTANT PLS_INTEGER   := 74;
const_mask_all_usages          CONSTANT VARCHAR2(16) := '0000000000000000';
const_mask_no_usages           CONSTANT VARCHAR2(16) := 'FFFFFFFFFFFFFFFF';

g_sw_msg_prefix                VARCHAR2(4000) := NULL;
g_se_msg_prefix                VARCHAR2(4000) := NULL;

/*------------------------------------------------------------------------------------
  List of tags:
  -------------
    #<path in model def>
    #<constant pool format>
    #<problem>
    #<dio integration>
    #<optimization>
    #<optimization-reverseport>
    #<verification>
    #<temporary>
    #<should never happen>
    #<important>
    #<logic files handling>
    #<todo>
-------------------------------------------------------------------------------------*/
--------------------------------------------------------------------------------------
/*------------------------------------------------------------------------------------
  Hash keys for local variables:
  ------------------------------
    model defs:                               psnodeid
    instance quantifiers:                     psnodeid1_psnodeid2_..._psnodeidN
    any node except targets and contributors: psnodeid-explid

    temporary local variables (never need to be re-generated): 'var', 'iq', 'exp'

  Hash keys for registers:
  ------------------------
    instance quantifies in accumulator rules: psnodeid1_psnodeid2_..._psnodeidN
    targets in accumulator rules:             psnodeid:explid
    contributors to a target:                 <number>$psnodeid:explid
    generic assistant variables:              _<assistant_var_id>
    dedicated register for contributions:     'value'

  Variable names:
  ---------------
    feature-property assistant variable:      _psnodeid_propertyid
-------------------------------------------------------------------------------------*/
-- Function that is be used to get the message text for the not translated
-- system messages.
-- Note: It is temporarily used for new FCE user warnings and errors till they are
--       defined in FND_NEW_MESSAGES table.
FUNCTION GET_NOT_TRANSLATED_TEXT(inMessageName IN VARCHAR2,
                  inToken1 IN VARCHAR2 DEFAULT NULL, inValue1 IN VARCHAR2 DEFAULT NULL,
                  inToken2 IN VARCHAR2 DEFAULT NULL, inValue2 IN VARCHAR2 DEFAULT NULL,
                  inToken3 IN VARCHAR2 DEFAULT NULL, inValue3 IN VARCHAR2 DEFAULT NULL,
                  inToken4 IN VARCHAR2 DEFAULT NULL, inValue4 IN VARCHAR2 DEFAULT NULL,
                  inToken5 IN VARCHAR2 DEFAULT NULL, inValue5 IN VARCHAR2 DEFAULT NULL,
                  inToken6 IN VARCHAR2 DEFAULT NULL, inValue6 IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  v_String  VARCHAR2(4000) := NULL;
BEGIN
  IF inToken1 IS NULL THEN
    RETURN inMessageName;
  ELSE
    v_String := replace(inMessageName, '^'||inToken1, inValue1);
    IF inToken2 IS NULL THEN
      RETURN v_String;
    ELSE
      v_String := replace(v_String, '^'||inToken2, inValue2);
      IF inToken3 IS NULL THEN
        RETURN v_String;
      ELSE
        v_String := replace(v_String, '^'||inToken3, inValue3);
        IF inToken4 IS NULL THEN
          RETURN v_String;
        ELSE
          v_String := replace(v_String, '^'||inToken4, inValue4);
          IF inToken5 IS NULL THEN
            RETURN v_String;
          ELSE
            v_String := replace(v_String, '^'||inToken5, inValue5);
            IF inToken6 IS NULL THEN
             RETURN v_String;
            ELSE
             v_String := replace(v_String, '^'||inToken5, inValue5);
            END IF; --Token6
          END IF; -- Token5
        END IF; -- Token4
      END IF; -- Token3
    END IF; -- Token2
  END IF; -- Token1
  RETURN v_String;
END GET_NOT_TRANSLATED_TEXT;
-------------------------------------------------------------------------------------
-- Following three report_and_raise procedures log the message to cz_db_logs
-- and raise the appropriate exception

-- This procedure reports user warning and by default raises
-- CZ_LOGICGEN_WARNING exception. To stop raising exception
-- set the p_raise_exception flag to FALSE.
PROCEDURE report_and_raise_warning(
      p_message         IN VARCHAR2
    , p_run_id          IN NUMBER
    , p_model_id        IN NUMBER
    , p_ps_node_id      IN NUMBER DEFAULT NULL
    , p_rule_id         IN NUMBER DEFAULT NULL
    , p_error_stack     IN VARCHAR2 DEFAULT NULL
    , p_raise_exception IN BOOLEAN DEFAULT TRUE ) IS
BEGIN
    CZ_FCE_COMPILE_UTILS.REPORT_WARNING(
                p_message => p_message,
                p_run_id => p_run_id,
                p_model_id => p_model_id,
                p_ps_node_id => p_ps_node_id,
                p_rule_id => p_rule_id,
                p_error_stack => p_error_stack
    );
    IF p_raise_exception THEN
        RAISE CZ_LOGICGEN_WARNING;
    END IF;
END report_and_raise_warning;
-------------------------------------------------------------------------------------
-- This procedure reports user system warning and by default raises
-- CZ_LOGICGEN_WARNING exception. This procedure prefixes the
-- given message with generic system warning note. To stop raising exception
-- set the p_raise_exception flag to FALSE.
PROCEDURE report_and_raise_sys_warning(
      p_message         IN VARCHAR2
    , p_run_id          IN NUMBER
    , p_model_id        IN NUMBER
    , p_ps_node_id      IN NUMBER DEFAULT NULL
    , p_rule_id         IN NUMBER DEFAULT NULL
    , p_error_stack     IN VARCHAR2 DEFAULT NULL
    , p_raise_exception IN BOOLEAN DEFAULT TRUE ) IS
BEGIN
    IF g_sw_msg_prefix IS NULL THEN
         -- System Warning: Generally caused by environment or system issues.
         g_sw_msg_prefix := CZ_UTILS.GET_TEXT(CZ_FCE_SW_GENERIC_PREFIX);
    END IF;
    CZ_FCE_COMPILE_UTILS.REPORT_WARNING(
                p_message => g_sw_msg_prefix || p_message,
                p_run_id => p_run_id,
                p_model_id => p_model_id,
                p_ps_node_id => p_ps_node_id,
                p_rule_id => p_rule_id,
                p_error_stack => p_error_stack
    );
    IF p_raise_exception THEN
        RAISE CZ_LOGICGEN_SYS_WARNING;
    END IF;
END report_and_raise_sys_warning;
-------------------------------------------------------------------------------------
-- This procedure reports user error and by default raises
-- CZ_LOGICGEN_ERROR exception. To stop raising exception
-- set the p_raise_exception flag to FALSE.
PROCEDURE report_and_raise_error(
      p_message         IN VARCHAR2
    , p_run_id          IN NUMBER
    , p_model_id        IN NUMBER
    , p_ps_node_id      IN NUMBER DEFAULT NULL
    , p_rule_id         IN NUMBER DEFAULT NULL
    , p_error_stack     IN VARCHAR2 DEFAULT NULL
    , p_raise_exception IN BOOLEAN DEFAULT TRUE ) IS
BEGIN
    CZ_FCE_COMPILE_UTILS.REPORT_ERROR(
                p_message => p_message,
                p_run_id => p_run_id,
                p_model_id => p_model_id,
                p_ps_node_id => p_ps_node_id,
                p_rule_id => p_rule_id,
                p_error_stack => p_error_stack
    );
    IF p_raise_exception THEN
        RAISE CZ_LOGICGEN_ERROR;
    END IF;
END report_and_raise_error;
-------------------------------------------------------------------------------------
-- This procedure reports system error and by default raises
-- CZ_LOGICGEN_ERROR exception. This procedure prefixes the
-- given message with generic system error note. To stop raising exception
-- set the p_raise_exception flag to FALSE.
PROCEDURE report_and_raise_sys_error(
      p_message         IN VARCHAR2
    , p_run_id          IN NUMBER
    , p_model_id        IN NUMBER
    , p_ps_node_id      IN NUMBER DEFAULT NULL
    , p_rule_id         IN NUMBER DEFAULT NULL
    , p_error_stack     IN VARCHAR2 DEFAULT NULL
    , p_raise_exception IN BOOLEAN DEFAULT TRUE ) IS
BEGIN
    IF g_se_msg_prefix IS NULL THEN
         -- System Error: Generally caused by environment or system issues.
         g_se_msg_prefix := CZ_UTILS.GET_TEXT(CZ_FCE_SE_GENERIC_PREFIX);
    END IF;
    CZ_FCE_COMPILE_UTILS.REPORT_SYSTEM_ERROR(
                p_message => g_se_msg_prefix || p_message,
                p_run_id => p_run_id,
                p_model_id => p_model_id,
                p_ps_node_id => p_ps_node_id,
                p_rule_id => p_rule_id,
                p_error_stack => p_error_stack
    );
    IF p_raise_exception THEN
        RAISE CZ_LOGICGEN_SYS_ERROR;
    END IF;
END report_and_raise_sys_error;
-------------------------------------------------------------------------------------
--This procedure compiles logic for a model specified by either a database id
--
--p_object_id: Database model id. Used when the second parameter is null.
--x_run_id: Unique id of the compilation session.
--p_two_phase_commit: 0 - compiler commits the logic, 1 - no commit.
--p_debug_mode: 0 - normal mode, 1 - debug mode.

PROCEDURE compile_logic_ ( p_object_id        IN NUMBER
                         , x_run_id           IN OUT NOCOPY NUMBER
                         , p_two_phase_commit IN PLS_INTEGER
                         , p_debug_mode       IN PLS_INTEGER
                         ) IS

  v_index                      PLS_INTEGER;

  h_psnid_psnodetype           type_node_hashtable;
  h_psnid_detailedtype         type_node_hashtable;
  h_psnid_decimalqtyflag       type_flag_hashtable;
  h_psnid_persistentnodeid     type_node_hashtable;
  h_psnid_devlprojectid        type_node_hashtable;
  h_psnid_parentid             type_node_hashtable;
  h_psnid_name                 type_name_hashtable;

  h_devlid_modelvisited        type_data_hashtable;
  h_psnid_createreverseport    type_data_hashtable;
  h_psnid_numberofchildren     type_data_hashtable;
  h_psnid_lastchildindex       type_data_hashtable;
  h_psnid_backindex            type_data_hashtable;
  h_psnid_propid_isvalid       type_bool_hashtable;

  t_psn_psnodeid               type_number_table;
  t_psn_parentid               type_number_table;
  t_psn_itemid                 type_number_table;
  t_psn_minimum                type_number_table;
  t_psn_maximum                type_number_table;
  t_psn_name                   type_varchar4000_table;
  t_psn_intltextid             type_number_table;
  t_psn_minimumselected        type_number_table;
  t_psn_maximumselected        type_number_table;
  t_psn_psnodetype             type_number_table;
  t_psn_initialvalue           type_varchar4000_table;
  t_psn_virtualflag            type_varchar1_table;
  t_psn_featuretype            type_number_table;
  t_psn_bomrequiredflag        type_varchar1_table;
  t_psn_referenceid            type_number_table;
  t_psn_persistentnodeid       type_number_table;
  t_psn_effectivefrom          type_date_table;
  t_psn_effectiveuntil         type_date_table;
  t_psn_effectiveusagemask     type_varchar16_table;
  t_psn_effectivitysetid       type_number_table;
  t_psn_decimalqtyflag         type_varchar1_table;
  t_psn_ibtrackable            type_varchar1_table;
  t_psn_accumulatorflag        type_varchar1_table;
  t_psn_initialnumvalue        type_number_table;
  t_psn_instantiableflag       type_varchar1_table;
  t_psn_shippableitemflag      type_varchar1_table;
  t_psn_invtransactflag        type_varchar1_table;
  t_psn_atoflag                type_varchar1_table;
  t_psn_serialitemflag         type_varchar1_table;
  t_psn_countedoptionsflag     type_varchar1_table;
  t_psn_devlprojectid          type_number_table;
  t_psn_domainorder            type_number_table;
  t_psn_reverseportid          type_number_table;
  t_psn_maxqtyperoption        type_number_table;
  t_psn_detailedtype           type_number_table;

  h_explid_referencepath       type_numbertable_hashtable;
  h_psnid_modelpath            type_numbertable_hashtable;
  h_psnid_explid_completepath  type_numbertable_hashtable;

  t_effset_effectivitysetid    type_number_table;
  t_effset_effectivefrom       type_date_table;
  t_effset_effectiveuntil      type_date_table;

  h_effsetid_effectivefrom     type_date_hashtable;
  h_effsetid_effectiveuntil    type_date_hashtable;
---------------------------------------------------------------------------------------
  -- Scope: compile_logic_
  PROCEDURE debug ( p_message IN VARCHAR2 ) IS
  BEGIN

    IF ( p_debug_mode = 1 ) THEN

      CZ_FCE_COMPILE_UTILS.REPORT_INFO(
                p_message => p_message,
                p_run_id => - x_run_id,
                p_model_id => null,
                p_ps_node_id => null,
                p_rule_id => null,
                p_error_stack => null
     );
    END IF;
  END debug;
---------------------------------------------------------------------------------------
  FUNCTION build_model_path ( p_node_id IN NUMBER ) RETURN type_number_table IS

       l_node        NUMBER;
       l_key         VARCHAR2(4000) := TO_CHAR ( p_node_id );
       tl_id_path    type_number_table;

  BEGIN

       IF ( h_psnid_modelpath.EXISTS ( l_key )) THEN RETURN h_psnid_modelpath ( l_key ); END IF;

       --When participant is a Bom Reference, we need to switch to the referenced Bom Model and
       --have it in the path. This way generate_path correctly generate instance quantifier for
       --the referring reference.

       IF ( h_psnid_psnodetype ( l_key ) = h_psntypes ('bommodel')) THEN

          tl_id_path ( 1 ) := p_node_id;

       END IF;

       l_node := p_node_id;

       WHILE ( h_psnid_parentid ( TO_CHAR ( l_node )) IS NOT NULL ) LOOP

         tl_id_path ( tl_id_path.COUNT + 1 ) := l_node;
         l_node := h_psnid_parentid ( TO_CHAR ( l_node ));

       END LOOP;

       h_psnid_modelpath ( l_key ) := tl_id_path;

       RETURN tl_id_path;

     EXCEPTION
        WHEN OTHERS THEN

           tl_id_path.DELETE;
           RETURN tl_id_path;

  END build_model_path;
----------------------------------------------------------------------------------
  FUNCTION ps_node_id_table_to_string ( p_node_id_table type_number_table ) RETURN VARCHAR2 IS

      l_path VARCHAR2(4000) := NULL;

  BEGIN

       IF ( p_node_id_table IS NULL OR p_node_id_table.COUNT = 0 ) THEN

         RETURN NULL;

       ELSE

         FOR iNode IN REVERSE 1 .. p_node_id_table.COUNT LOOP

           IF ( iNode = p_node_id_table.COUNT ) THEN

               l_path := l_path || h_psnid_name ( p_node_id_table ( iNode ));

           ELSE

               l_path := l_path || '.' || h_psnid_name ( p_node_id_table ( iNode ));

           END IF;
         END LOOP;

         RETURN l_path;

       END IF;
  EXCEPTION
     WHEN OTHERS THEN

        RETURN NULL;

  END ps_node_id_table_to_string;
---------------------------------------------------------------------------------------
  PROCEDURE read_model_data ( p_component_id IN NUMBER ) IS

     l_psn_psnodeid             type_number_table;
     l_psn_parentid             type_number_table;
     l_psn_itemid               type_number_table;
     l_psn_minimum              type_number_table;
     l_psn_maximum              type_number_table;
     l_psn_name                 type_varchar4000_table;
     l_psn_intltextid           type_number_table;
     l_psn_minimumselected      type_number_table;
     l_psn_maximumselected      type_number_table;
     l_psn_psnodetype           type_number_table;
     l_psn_initialvalue         type_varchar4000_table;
     l_psn_virtualflag          type_varchar1_table;
     l_psn_featuretype          type_number_table;
     l_psn_bomrequiredflag      type_varchar1_table;
     l_psn_referenceid          type_number_table;
     l_psn_persistentnodeid     type_number_table;
     l_psn_effectivefrom        type_date_table;
     l_psn_effectiveuntil       type_date_table;
     l_psn_effectiveusagemask   type_varchar16_table;
     l_psn_effectivitysetid     type_number_table;
     l_psn_decimalqtyflag       type_varchar1_table;
     l_psn_ibtrackable          type_varchar1_table;
     l_psn_accumulatorflag      type_varchar1_table;
     l_psn_initialnumvalue      type_number_table;
     l_psn_instantiableflag     type_varchar1_table;
     l_psn_shippableitemflag    type_varchar1_table;
     l_psn_invtransactflag      type_varchar1_table;
     l_psn_atoflag              type_varchar1_table;
     l_psn_serialitemflag       type_varchar1_table;
     l_psn_countedoptionsflag   type_varchar1_table;
     l_psn_devlprojectid        type_number_table;
     l_psn_domainorder          type_number_table;
     l_psn_reverseportid        type_number_table;
     l_psn_maxqtyperoption      type_number_table;
     l_psn_detailedtype         type_number_table;

     l_port_table               type_integer_table;
     l_reverseport_table        type_integer_table;
     l_index                    PLS_INTEGER;
     l_parent_id                VARCHAR2(4000);
     l_node_id                  VARCHAR2(4000);

     l_model_id                 NUMBER;
     ----------------------------------------------------------------------------------
     PROCEDURE set_token ( p_mark IN VARCHAR2 ) IS
     BEGIN

        t_psn_psnodetype ( v_index ) := h_psntypes ( p_mark );
        t_psn_psnodeid ( v_index ) := p_component_id;
        t_psn_devlprojectid ( v_index ) := p_component_id;
        t_psn_parentid ( v_index ) := NULL;

        v_index := v_index + 1;

     END set_token;
     ----------------------------------------------------------------------------------
  BEGIN --> read_model_data

      --This procedure reads model hierarchy structure in a certain format that is used by
      --compile_logic_file procedure. The format uses tokens - dummy nodes of special type
      --that are embedded into the structure (see the above procedure set_token for the
      --columns that are used in the definition). The resulting memory structure looks
      --like this:

      --'beginstructure'
      --  <model_data>
      --    'beginstructure'
      --       <child_model_data>
      --          ...
      --       'beginport'
      --         <child_model_ports>
      --       'endport'
      --     'endstructure'
      --     ...
      --  'beginport'
      --     <model_ports>
      --  'endport'
      --  'beginrule'
      --     <reverse_ports>
      --  'endrule'
      --'endstructure'

      --Each model data is contained only once in this hierarchy, when the model is first referenced.
      --The port section of the referencing model cannot be processed before the referenced model is
      --processed.

      h_devlid_modelvisited ( TO_CHAR (p_component_id)) := 1;

      SELECT ps_node_id, parent_id, item_id, minimum, maximum, name, intl_text_id, minimum_selected,
             maximum_selected, ps_node_type, initial_value, virtual_flag, feature_type, bom_required_flag,
             reference_id, persistent_node_id, effective_from, effective_until, effective_usage_mask,
             effectivity_set_id, decimal_qty_flag, ib_trackable, accumulator_flag, initial_num_value,
             instantiable_flag, shippable_item_flag, inventory_transactable_flag, assemble_to_order_flag,
             serializable_item_flag, counted_options_flag, devl_project_id, domain_order,
             reverse_connector_id, max_qty_per_option
        BULK COLLECT INTO
             l_psn_psnodeid, l_psn_parentid, l_psn_itemid, l_psn_minimum, l_psn_maximum, l_psn_name,
             l_psn_intltextid, l_psn_minimumselected, l_psn_maximumselected, l_psn_psnodetype,
             l_psn_initialvalue, l_psn_virtualflag, l_psn_featuretype, l_psn_bomrequiredflag,
             l_psn_referenceid, l_psn_persistentnodeid, l_psn_effectivefrom, l_psn_effectiveuntil,
             l_psn_effectiveusagemask, l_psn_effectivitysetid, l_psn_decimalqtyflag, l_psn_ibtrackable,
             l_psn_accumulatorflag, l_psn_initialnumvalue, l_psn_instantiableflag, l_psn_shippableitemflag,
             l_psn_invtransactflag, l_psn_atoflag, l_psn_serialitemflag, l_psn_countedoptionsflag,
             l_psn_devlprojectid, l_psn_domainorder, l_psn_reverseportid, l_psn_maxqtyperoption
        FROM cz_ps_nodes
       WHERE deleted_flag = '0'
       START WITH ps_node_id = p_component_id
     CONNECT BY PRIOR deleted_flag = '0' AND PRIOR ps_node_id = parent_id;

     --Note: the condition on PRIOR deleted_flag is included to handle the cases when children of a deleted
     --parent are not deleted, for example when options of a deleted option feature still have the value of
     --deleted_flag = '0'. If such situation is not possible, the condition can be removed if it slows down
     --the query.

     IF (l_psn_psnodeid.COUNT > 0) THEN

        set_token ('beginstructure');

        FOR i IN 1..l_psn_psnodeid.COUNT LOOP

           l_psn_virtualflag ( i ) := NVL ( l_psn_virtualflag ( i ), '1' );
           l_psn_instantiableflag ( i ) := NVL ( l_psn_instantiableflag ( i ), h_instantiability ('mandatory'));
           l_psn_detailedtype ( i ) := l_psn_psnodetype ( i );

           --#<important>
           --If splitting the detailed type further, it is necessary to find all existing references
           --to this detailed type in the code to see if they need to be modified.

           IF ( l_psn_psnodetype ( i ) = h_psntypes ('feature')) THEN

              l_psn_detailedtype ( i ) := l_psn_featuretype ( i );

           ELSIF ( l_psn_psnodetype ( i ) = h_psntypes ('component')) THEN

              IF ( l_psn_parentid ( i ) IS NULL ) THEN

                l_psn_detailedtype ( i ) := h_psntypes ('root');

              ELSIF ( l_psn_virtualflag ( i ) = '1' ) THEN

                l_psn_detailedtype ( i ) := h_psntypes ('singleton');

              END IF;
           END IF;

           t_psn_psnodeid ( v_index ) := l_psn_psnodeid ( i );
           t_psn_parentid ( v_index ) := l_psn_parentid ( i );
           t_psn_itemid ( v_index ) := l_psn_itemid ( i );
           t_psn_minimum ( v_index ) := l_psn_minimum ( i );
           t_psn_maximum ( v_index ) := l_psn_maximum ( i );
           t_psn_name ( v_index ) := l_psn_name ( i );
           t_psn_intltextid ( v_index ) := l_psn_intltextid ( i );
           t_psn_minimumselected ( v_index ) := l_psn_minimumselected ( i );
           t_psn_maximumselected ( v_index ) := l_psn_maximumselected ( i );
           t_psn_psnodetype ( v_index ) := l_psn_psnodetype ( i );
           t_psn_initialvalue ( v_index ) := l_psn_initialvalue ( i );
           t_psn_virtualflag ( v_index ) := l_psn_virtualflag ( i );
           t_psn_featuretype ( v_index ) := l_psn_featuretype ( i );
           t_psn_bomrequiredflag ( v_index ) := l_psn_bomrequiredflag ( i );
           t_psn_referenceid ( v_index ) := l_psn_referenceid ( i );
           t_psn_persistentnodeid ( v_index ) := l_psn_persistentnodeid ( i );
           t_psn_effectivefrom ( v_index ) := l_psn_effectivefrom ( i );
           t_psn_effectiveuntil ( v_index ) := l_psn_effectiveuntil ( i );
           t_psn_effectiveusagemask ( v_index ) := l_psn_effectiveusagemask ( i );
           t_psn_effectivitysetid ( v_index ) := l_psn_effectivitysetid ( i );
           t_psn_decimalqtyflag ( v_index ) := l_psn_decimalqtyflag ( i );
           t_psn_ibtrackable ( v_index ) := l_psn_ibtrackable ( i );
           t_psn_accumulatorflag ( v_index ) := l_psn_accumulatorflag ( i );
           t_psn_initialnumvalue ( v_index ) := l_psn_initialnumvalue ( i );
           t_psn_instantiableflag ( v_index ) := l_psn_instantiableflag ( i );
           t_psn_shippableitemflag ( v_index ) := l_psn_shippableitemflag ( i );
           t_psn_invtransactflag ( v_index ) := l_psn_invtransactflag ( i );
           t_psn_atoflag ( v_index ) := l_psn_atoflag ( i );
           t_psn_serialitemflag ( v_index ) := l_psn_serialitemflag ( i );
           t_psn_countedoptionsflag ( v_index ) := l_psn_countedoptionsflag ( i );
           t_psn_devlprojectid ( v_index ) := l_psn_devlprojectid ( i );
           t_psn_domainorder ( v_index ) := l_psn_domainorder ( i );
           t_psn_reverseportid ( v_index ) := l_psn_reverseportid ( i );
           t_psn_maxqtyperoption ( v_index ) := l_psn_maxqtyperoption ( i );
           t_psn_detailedtype ( v_index ) := l_psn_detailedtype ( i );

           l_node_id := TO_CHAR ( l_psn_psnodeid ( i ));

           h_psnid_backindex ( l_node_id ) := v_index;
           h_psnid_numberofchildren ( l_node_id  ) := 0;

           --If node is assigned to an effectivity set, its effectivities should be taken from this set.

           IF ( l_psn_effectivitysetid ( i ) IS NOT NULL ) THEN
              IF ( NOT h_effsetid_effectivefrom.EXISTS ( TO_CHAR ( l_psn_effectivitysetid ( i )))) THEN

                  report_and_raise_warning (
                      p_message => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_NODEINCORRECTEFFSET,
                          'NODE_NAME',
                          CZ_FCE_COMPILE_UTILS.GET_NODE_PATH ( l_psn_psnodeid ( i ),
                            ps_node_id_table_to_string (
                                build_model_path ( l_psn_psnodeid ( i )))),
                          'MODEL_NAME',
                          CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, null )),
                      p_run_id => x_run_id,
                      p_model_id => p_component_id,
                      p_raise_exception => FALSE
                  );

              ELSE

                  t_psn_effectivefrom ( v_index ) := h_effsetid_effectivefrom ( TO_CHAR ( l_psn_effectivitysetid ( i )));
                  t_psn_effectiveuntil ( v_index ) := h_effsetid_effectiveuntil ( TO_CHAR ( l_psn_effectivitysetid ( i )));

              END IF;
           END IF;

           --This is a global variable, it is used to index the whole hierarchy, in particular,
           --it needs to be increased -before- following the references. So, caution should be
           --exercised when moving this statement.

           v_index := v_index + 1;

           h_psnid_psnodetype ( l_node_id ) := l_psn_psnodetype ( i );
           h_psnid_detailedtype ( l_node_id ) := l_psn_detailedtype ( i );
           h_psnid_decimalqtyflag ( l_node_id ) := l_psn_decimalqtyflag ( i );
           h_psnid_persistentnodeid ( l_node_id ) := l_psn_persistentnodeid ( i );
           h_psnid_devlprojectid( l_node_id ) := l_psn_devlprojectid ( i );

           --#<path in model def>
           --This two arrays are introduced to be able to generate a full model path to be used when
           --creating model defs. Currently this is used only for debugging purposes. For example in
           --the following situation:
           --
           --M
           --|_C1
           --|  |_C3
           --|_C2
           --   |_C3
           --
           --C3 can be different node with the same name. When creating XML from byte-code it will be
           --not clear which model def for C3 belongs under which component.

           h_psnid_name( l_node_id ) := l_psn_name ( i );
           h_psnid_parentid( l_node_id ) := l_psn_parentid ( i );

           --We have to do this here and not earlier as we may need the hash tables above to build to
           --construct the path in the model.

           IF ( l_psn_psnodetype ( i ) = h_psntypes ('connector')) THEN
               -- Node ^NODE_NAME in Model ^MODEL_NAME is a Connector. In this release, Connectors are only supported in Orginal Configuration Engine type models.
               report_and_raise_error (
                    p_message => CZ_UTILS.GET_TEXT ( CZ_FCE_E_CONNECTNOTSUPPORTED,
                          'NODE_NAME',
                          CZ_FCE_COMPILE_UTILS.GET_NODE_PATH ( l_psn_psnodeid ( i ),
                              ps_node_id_table_to_string(
                                build_model_path(l_psn_psnodeid ( i )) )
                              ),
                          'MODEL_NAME',
                          CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id )),
                    p_run_id => x_run_id,
                    p_model_id => p_component_id
               );
           END IF;

           IF ( l_psn_psnodetype(i) IN ( h_psntypes ('reference'), h_psntypes ('connector')) OR
                ( l_psn_psnodetype(i) = h_psntypes('component') AND l_psn_parentid ( i ) IS NOT NULL)) THEN

               --References, connectors and all non-root component variables go to the port file.

               l_port_table ( l_port_table.COUNT + 1 ) := i;

               --Now handle additional control tables for reverse ports. It is important to do it here before
               --following the reference. The reason is that although Solver does not care on which of the
               --reverse ports we call the setReversePort method, from the DIO integration point of view we
               --need to call it on the 'parent' port.

               IF ( l_psn_reverseportid ( i ) IS NOT NULL AND ( NOT h_psnid_createreverseport.EXISTS ( TO_CHAR ( l_psn_reverseportid ( i ))))) THEN

                   --This port has a reverse port defined, so we need to call setReversePort either on this
                   --port, or on the other port. If the other port has not been added to the rule section,
                   --add this one and remember it.

                   l_reverseport_table ( l_reverseport_table.COUNT + 1 ) := i;
                   h_psnid_createreverseport ( TO_CHAR ( l_psn_psnodeid ( i ))) := 1;

                   IF ( NOT h_psnid_devlprojectid.EXISTS ( TO_CHAR ( l_psn_reverseportid ( i )))) THEN

                      --The model containing the referring port has not been processed, we need to process this model
                      --to make sure that its logic exists, otherwise there will be a hash miss in emit_reverseport,
                      --and DIO won't be able to get the model def.

                      BEGIN

                          SELECT devl_project_id INTO l_model_id
                            FROM cz_ps_nodes
                           WHERE deleted_flag = '0'
                             AND ps_node_id = l_psn_reverseportid ( i );

                      EXCEPTION
                         WHEN OTHERS THEN

                            --#<should never happen>
                            report_and_raise_error (
                                p_message => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SE_REVCONNMODELNOTFOUND,
                                    'MODEL_NAME',
                                    CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( l_psn_reverseportid ( i ))),
                                p_run_id => x_run_id,
                                p_model_id => l_psn_reverseportid ( i )
                            );

                      END;

                      read_model_data ( l_model_id );

                   END IF;
               END IF;

               IF ( l_psn_referenceid ( i ) IS NOT NULL AND ( NOT h_devlid_modelvisited.EXISTS ( TO_CHAR ( l_psn_referenceid ( i ))))) THEN

                  read_model_data ( l_psn_referenceid ( i ));

               END IF;
           END IF;

           IF ( l_psn_parentid ( i ) IS NOT NULL ) THEN

              --Calculate number of children for each parent. May be useful for setting fields like maximum_selected.

              l_parent_id  := TO_CHAR ( l_psn_parentid ( i ));
              h_psnid_numberofchildren ( l_parent_id  ) := h_psnid_numberofchildren ( l_parent_id  ) + 1;

              --This table is useful when we need to collect all children of a parent across the whole
              --structure.

              h_psnid_lastchildindex ( l_parent_id ) := h_psnid_backindex ( l_node_id );

           END IF;
        END LOOP;

        --After the model structure is read we append a 'port' section at the end containing all the
        --references and connectors in the structure, for which port variables will be created. The
        --section is enclosed in 'beginport'/'endport' tokens and contains only the values that are
        --required for creating port variables - this determined what arrays we populate below. For
        --example, initial_value is not used for port variables, and we don't populate the array.

        --Components with defined reverse port are also here (one from each pair, another one is in
        --the def file).

        --This section is REQUIRED even if it is empty - we always create all files of all possible
        --types as a solution to the problem described in #<logic files handling>.

        set_token ('beginport');

        FOR i IN 1..l_port_table.COUNT LOOP

           l_index := l_port_table ( i );

           t_psn_psnodeid ( v_index ) := l_psn_psnodeid ( l_index );
           t_psn_persistentnodeid ( v_index ) := l_psn_persistentnodeid ( l_index );
           t_psn_parentid ( v_index ) := l_psn_parentid ( l_index );
           t_psn_psnodetype ( v_index ) := l_psn_psnodetype ( l_index );
           t_psn_referenceid ( v_index ) := l_psn_referenceid ( l_index );
           t_psn_reverseportid ( v_index ) := l_psn_reverseportid ( l_index );
           t_psn_devlprojectid ( v_index ) := l_psn_devlprojectid ( l_index );
           t_psn_name ( v_index ) := l_psn_name ( l_index );
           t_psn_minimum ( v_index ) := l_psn_minimum ( l_index );
           t_psn_maximum ( v_index ) := l_psn_maximum ( l_index );
           t_psn_virtualflag ( v_index ) := l_psn_virtualflag ( l_index );
           t_psn_instantiableflag ( v_index ) := l_psn_instantiableflag ( l_index );
           t_psn_bomrequiredflag ( v_index ) := l_psn_bomrequiredflag ( l_index );
           t_psn_minimumselected( v_index ) := l_psn_minimumselected( l_index );
           t_psn_maximumselected( v_index ) := l_psn_maximumselected( l_index );
           t_psn_initialnumvalue( v_index ) := l_psn_initialnumvalue( l_index );
           t_psn_effectivefrom( v_index ) := l_psn_effectivefrom( l_index );
           t_psn_effectiveuntil( v_index ) := l_psn_effectiveuntil( l_index );
           t_psn_effectiveusagemask( v_index ) := l_psn_effectiveusagemask( l_index );
           t_psn_detailedtype ( v_index ) := l_psn_detailedtype ( l_index );

           v_index := v_index + 1;

        END LOOP;

        set_token ('endport');

        --Now append the 'rule' section which contains all ports on which we need to call setReversePort.
        --For each of them, the call will be generated in the rule logic file. Note, that this section is
        --REQUIRED even if there is no reverse ports and it is empty.

        set_token ('beginrule');

        FOR i IN 1..l_reverseport_table.COUNT LOOP

           l_index := l_reverseport_table ( i );

           t_psn_psnodeid ( v_index ) := l_psn_psnodeid ( l_index );
           t_psn_persistentnodeid ( v_index ) := l_psn_persistentnodeid ( l_index );
           t_psn_reverseportid ( v_index ) := l_psn_reverseportid ( l_index );
           t_psn_psnodetype ( v_index ) := l_psn_psnodetype ( l_index );

           v_index := v_index + 1;

        END LOOP;

        set_token ('endrule');
        set_token ('endstructure');

     END IF; --> l_psn_psnodeid.COUNT > 0
  END read_model_data;
---------------------------------------------------------------------------------------
  -- Scope: compile_logic_
  PROCEDURE compile_logic_file ( p_component_id IN NUMBER
                               , p_type IN PLS_INTEGER
                               , p_model_path IN VARCHAR2 DEFAULT NULL
                               ) IS

   h_StringConstantHash       type_data_hashtable;
   h_IntegerConstantHash      type_data_hashtable;
   h_LongConstantHash         type_data_hashtable;
   h_MaskConstantHash         type_data_hashtable;
   h_DoubleConstantHash       type_data_hashtable;
   h_MethodDescriptorHash     type_integer_table;

   h_LocalVariableHash        type_data_hashtable;
   h_LocalVariableBackPtr     type_varchar4000_table;
   h_RegisterHash             type_data_hashtable;

   l_var_min                  NUMBER;
   l_var_max                  NUMBER;
   l_var_count                NUMBER;
   l_option_count             PLS_INTEGER;
   l_feature_idx              PLS_INTEGER;
   l_reverseportcount         PLS_INTEGER;

   l_begin_date               DATE;
   l_end_date                 DATE;
   l_model_path               VARCHAR2(4000);
---------------------------------------------------------------------------------------
-------------------------- LOGIC FILE IMPLEMENTATION ----------------------------------
---------------------------------------------------------------------------------------
   pool_ptr                   PLS_INTEGER;
   code_ptr                   PLS_INTEGER;
   localvariable_ptr          PLS_INTEGER;
   register_ptr               PLS_INTEGER;

   this_segment_nbr           NUMBER;
   this_file_id               NUMBER;

   segment_nbr_svp            PLS_INTEGER;
   code_ptr_svp               PLS_INTEGER;
   pool_ptr_svp               PLS_INTEGER;

   h_StringConstantHash_svp   type_data_hashtable;
   h_IntegerConstantHash_svp  type_data_hashtable;
   h_LongConstantHash_svp     type_data_hashtable;
   h_MaskConstantHash_svp     type_data_hashtable;
   h_DoubleConstantHash_svp   type_data_hashtable;
   h_MethodDescriptorHash_svp type_integer_table;

   h_LocalVariableHash_svp    type_data_hashtable;
   h_RegisterHash_svp         type_data_hashtable;

   ConstantPool               BLOB;
   CodeMemory                 BLOB;

   CodeMemory_buffer          VARCHAR2(32767 BYTE);
   code_buffer_ptr            PLS_INTEGER;

   ConstantPool_buffer        VARCHAR2(32767 BYTE);
   pool_buffer_ptr            PLS_INTEGER;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE flush_constant_pool IS

     l_raw   RAW(32767) := HEXTORAW ( ConstantPool_buffer );
     l_len   BINARY_INTEGER := UTL_RAW.LENGTH ( l_raw );

   BEGIN

     IF ( l_len > 0 ) THEN

        DBMS_LOB.WRITEAPPEND ( ConstantPool, l_len, l_raw );

     END IF;
   END flush_constant_pool;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE flush_code_memory IS

     l_raw   RAW(32767) := HEXTORAW ( CodeMemory_buffer );
     l_len   BINARY_INTEGER := UTL_RAW.LENGTH ( l_raw );

   BEGIN

     IF ( l_len > 0 ) THEN

        DBMS_LOB.WRITEAPPEND ( CodeMemory, l_len, l_raw );

     END IF;
   END flush_code_memory;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE init_logic_file IS
   BEGIN

     DBMS_LOB.CREATETEMPORARY ( ConstantPool, TRUE );
     DBMS_LOB.CREATETEMPORARY ( CodeMemory, TRUE );

     CodeMemory_buffer := NULL;
     code_buffer_ptr := 0;

     ConstantPool_buffer := NULL;
     pool_buffer_ptr := 0;

     pool_ptr := 0;
     code_ptr := 0;
     this_segment_nbr := 1;

     localvariable_ptr := 0;
     register_ptr := 0;

   END init_logic_file;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE next_logic_segment IS
   BEGIN

     DBMS_LOB.TRIM ( ConstantPool, 0 );
     DBMS_LOB.TRIM ( CodeMemory, 0 );

     CodeMemory_buffer := NULL;
     code_buffer_ptr := 0;

     ConstantPool_buffer := NULL;
     pool_buffer_ptr := 0;

     pool_ptr := 0;
     code_ptr := 0;
     this_segment_nbr := this_segment_nbr + 1;

     h_StringConstantHash.DELETE;
     h_IntegerConstantHash.DELETE;
     h_LongConstantHash.DELETE;
     h_MaskConstantHash.DELETE;
     h_DoubleConstantHash.DELETE;
     h_MethodDescriptorHash.DELETE;

   END next_logic_segment;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE spool_logic_file IS

     l_file_id  NUMBER;
     l_loc      BLOB;

   BEGIN

     flush_constant_pool ();
     flush_code_memory ();

     IF ( pool_ptr + code_ptr > 0 ) THEN

        DBMS_LOB.CREATETEMPORARY ( l_loc, TRUE );

        IF ( pool_ptr > 0 ) THEN DBMS_LOB.APPEND ( l_loc, ConstantPool ); END IF;
        IF ( code_ptr > 0 ) THEN DBMS_LOB.APPEND ( l_loc, CodeMemory ); END IF;

        DBMS_LOB.WRITEAPPEND ( l_loc, 4, cz_fce_compile_utils.integer_raw ( pool_ptr ));
        DBMS_LOB.WRITEAPPEND ( l_loc, 4, const_file_signature );

        IF ( this_segment_nbr = 1 ) THEN

           SELECT cz_fce_files_s.NEXTVAL INTO this_file_id FROM DUAL;

           --This does not delete a logic file if there is no such type in the current generation.
           --For example, if an only port has been removed from the model, there will be no port
           --file in this generation, so the current port file will not be deleted.

           --#<problem>
           --Need a better handling of this problem. For now we will always create files of all
           --possible types even if they are empty. We do that for rule files anyway.

           UPDATE cz_fce_files SET deleted_flag = '1'
            WHERE component_id = p_component_id
              AND fce_file_type = p_type;

        ELSE

           --Need that in case we are restoring to a savepoint in the previous segment.

           DELETE FROM cz_fce_files
            WHERE component_id = p_component_id
              AND fce_file_type = p_type
              AND segment_nbr = this_segment_nbr;

        END IF;

        INSERT INTO cz_fce_files ( FCE_FILE_ID
                                 , FCE_FILE_TYPE
                                 , COMPONENT_ID
                                 , SEGMENT_NBR
                                 , FCE_FILE
                                 , DELETED_FLAG
                                 , DEBUG_FLAG
                                 )
                          VALUES ( this_file_id
                                 , p_type
                                 , p_component_id
                                 , this_segment_nbr
                                 , l_loc
                                 , '0'
                                 , TO_CHAR ( p_debug_mode )
                                 );
     END IF;
   END spool_logic_file;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_code ( p_code IN RAW ) IS

     l_code      VARCHAR2(128 BYTE) := RAWTOHEX ( p_code );
     l_len       BINARY_INTEGER := LENGTHB ( l_code );

   BEGIN

      code_buffer_ptr := code_buffer_ptr + l_len;
      code_ptr := code_ptr + UTL_RAW.LENGTH ( p_code );

      IF ( code_buffer_ptr >= const_codememory_buffersize ) THEN

        flush_code_memory ();

        CodeMemory_buffer := NULL;
        code_buffer_ptr := l_len;

      END IF;

      CodeMemory_buffer := CodeMemory_buffer || l_code;

   END emit_code;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_data ( p_data IN RAW ) RETURN PLS_INTEGER IS

     l_pool_ptr  PLS_INTEGER;
     l_len       BINARY_INTEGER := UTL_RAW.LENGTH ( p_data );

     l_data      VARCHAR2(32767 BYTE) := RAWTOHEX ( p_data );
     l_data_len  BINARY_INTEGER := LENGTHB ( l_data );

   BEGIN

      IF ( pool_ptr >= const_constantpool_maxsize ) THEN

          --Here the switch to the next logic file will be handled. The switch will occur
          --when the constant pool overflown.

          emit_code ( h_inst ('ret'));
          spool_logic_file ();

          next_logic_segment ();

      END IF;

      IF ( l_data_len >= const_constantpool_buffersize ) THEN

        flush_constant_pool ();

        DBMS_LOB.WRITEAPPEND ( ConstantPool, l_len, p_data );

        ConstantPool_buffer := NULL;
        pool_buffer_ptr := 0;

      ELSE

         pool_buffer_ptr := pool_buffer_ptr + l_data_len;

         IF ( pool_buffer_ptr >= const_constantpool_buffersize ) THEN

           flush_constant_pool ();

           ConstantPool_buffer := NULL;
           pool_buffer_ptr := l_data_len;

         END IF;

         ConstantPool_buffer := ConstantPool_buffer || l_data;

      END IF;

      l_pool_ptr := pool_ptr;
      pool_ptr := pool_ptr + l_len;

      RETURN l_pool_ptr;

   END emit_data;
---------------------------------------------------------------------------------------
   --Savepoints allow to delete partially generated byte-code when generation fails.
   -- Scope: compile_logic_file
   PROCEDURE set_savepoint IS
   BEGIN

      segment_nbr_svp := this_segment_nbr;

      code_ptr_svp := code_ptr;
      pool_ptr_svp := pool_ptr;

      h_StringConstantHash_svp := h_StringConstantHash;
      h_IntegerConstantHash_svp := h_IntegerConstantHash;
      h_LongConstantHash_svp := h_LongConstantHash;
      h_MaskConstantHash_svp := h_MaskConstantHash;
      h_DoubleConstantHash_svp := h_DoubleConstantHash;
      h_MethodDescriptorHash_svp := h_MethodDescriptorHash;

      h_LocalVariableHash_svp := h_LocalVariableHash;
      h_RegisterHash_svp := h_RegisterHash;

   END set_savepoint;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE restore_savepoint IS

      l_size       PLS_INTEGER;
      l_tail       PLS_INTEGER;

      l_fce_file   BLOB;

   BEGIN

      IF ( segment_nbr_svp < this_segment_nbr ) THEN

         --This is a situation when the savepoint is in the previous segment, which has
         --already been saved to the database, for example segment switching occured in
         --in the middle of a rule generation, and this rule has to be rolled back. The
         --previous segment nees to be restored in memory from the database.

         DBMS_LOB.TRIM ( ConstantPool, 0 );
         DBMS_LOB.TRIM ( CodeMemory, 0 );

         SELECT fce_file INTO l_fce_file FROM cz_fce_files
          WHERE deleted_flag = '0'
            AND component_id = p_component_id
            AND fce_file_type = p_type
            AND segment_nbr = segment_nbr_svp;

         --According to the logic file format, second four bytes from the end store the
         --size of the Constant Pool.

         l_size := UTL_RAW.CAST_TO_BINARY_INTEGER ( DBMS_LOB.SUBSTR ( l_fce_file, 4, DBMS_LOB.GETLENGTH ( l_fce_file ) - 7 ));
         l_tail := DBMS_LOB.GETLENGTH ( l_fce_file ) - 8 - l_size;

         IF ( l_size > 0 ) THEN ConstantPool := DBMS_LOB.SUBSTR ( l_fce_file, l_size, 1 ); END IF;
         IF ( l_tail > 0 ) THEN CodeMemory := DBMS_LOB.SUBSTR ( l_fce_file, l_tail, l_size + 1 ); END IF;

         this_segment_nbr := segment_nbr_svp;

      ELSE

         flush_constant_pool ();
         flush_code_memory ();

      END IF;

      code_ptr := code_ptr_svp;
      pool_ptr := pool_ptr_svp;

      DBMS_LOB.TRIM ( CodeMemory, code_ptr_svp );
      DBMS_LOB.TRIM ( ConstantPool, pool_ptr_svp );

      CodeMemory_buffer := NULL;
      code_buffer_ptr := 0;

      ConstantPool_buffer := NULL;
      pool_buffer_ptr := 0;

      h_StringConstantHash := h_StringConstantHash_svp;
      h_IntegerConstantHash := h_IntegerConstantHash_svp;
      h_LongConstantHash := h_LongConstantHash_svp;
      h_MaskConstantHash := h_MaskConstantHash_svp;
      h_DoubleConstantHash := h_DoubleConstantHash_svp;
      h_MethodDescriptorHash := h_MethodDescriptorHash_svp;

      h_LocalVariableHash := h_LocalVariableHash_svp;
      h_RegisterHash := h_RegisterHash_svp;

   END restore_savepoint;
---------------------------------------------------------------------------------------
-------------------------- LOGIC FILE IMPLEMENTATION ----------------------------------
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_ldc ( p_ptr IN PLS_INTEGER ) IS
   BEGIN

      IF ( cz_fce_compile_utils.assert_unsigned_byte ( p_ptr )) THEN

         emit_code ( h_inst ('ldc') || cz_fce_compile_utils.unsigned_byte ( p_ptr ));

      ELSIF ( cz_fce_compile_utils.assert_unsigned_word ( p_ptr )) THEN

         emit_code ( h_inst ('ldc_w') || cz_fce_compile_utils.unsigned_word ( p_ptr ));

      ELSE

         report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_POINTER_TOO_LONG),
            p_run_id => x_run_id,
            p_model_id => p_component_id
         );

      END IF;
   END emit_ldc;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_iconst ( p_int IN NUMBER ) IS
   BEGIN

      IF ( p_int = ( -1 )) THEN

         emit_code ( h_inst ('iconst_m1'));

      ELSE

         emit_code ( h_inst ('iconst_' || TO_CHAR ( p_int )));

      END IF;
   END emit_iconst;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_dup IS
   BEGIN

      emit_code ( h_inst ('dup'));

   END emit_dup;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_swap IS
   BEGIN

      emit_code ( h_inst ('swap'));

   END emit_swap;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_string_constant ( p_string IN VARCHAR2 ) RETURN PLS_INTEGER IS

     l_pool_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_StringConstantHash.EXISTS( p_string )) THEN

         --This uses the format of string constant entry in the constant pool. If the format changes,
         --this will have to change.
         --#<constant pool format>

         IF ( cz_fce_compile_utils.assert_unsigned_word ( LENGTHB ( p_string ))) THEN

            l_pool_ptr := emit_data ( const_string_tag || cz_fce_compile_utils.unsigned_word ( LENGTHB ( p_string )) ||
                          UTL_RAW.CAST_TO_RAW ( p_string ));
            h_StringConstantHash( p_string ) := l_pool_ptr;

         ELSE

            report_and_raise_sys_error(
                p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_STRING_TOO_LONG),
                p_run_id => x_run_id,
                p_model_id => p_component_id
             );

         END IF;

      ELSE

         l_pool_ptr := h_StringConstantHash( p_string );

      END IF;
      RETURN l_pool_ptr;

   END emit_string_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_integer_constant ( p_int IN NUMBER ) RETURN PLS_INTEGER IS

     l_key  VARCHAR2(4000) := TO_CHAR (p_int);
     l_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_IntegerConstantHash.EXISTS ( l_key )) THEN

         --#<constant pool format>

         l_ptr := emit_data ( const_integer_tag || cz_fce_compile_utils.integer_raw ( p_int ));
         h_IntegerConstantHash( l_key ) := l_ptr;

      ELSE

         l_ptr := h_IntegerConstantHash ( l_key );

      END IF;
      RETURN l_ptr;
   END emit_integer_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_long_constant ( p_int IN NUMBER ) RETURN PLS_INTEGER IS

     l_key  VARCHAR2(4000) := TO_CHAR ( p_int );
     l_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_LongConstantHash.EXISTS ( l_key )) THEN

         --#<constant pool format>

         l_ptr := emit_data ( const_long_tag || cz_fce_compile_utils.long_raw ( p_int ));
         h_LongConstantHash( l_key ) := l_ptr;

      ELSE

         l_ptr := h_LongConstantHash ( l_key );

      END IF;
      RETURN l_ptr;
   END emit_long_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   --This functions emits a string of 16 hex characters as a long.
   --Example: effective_usage_mask
   FUNCTION emit_mask_constant ( p_mask IN VARCHAR2 ) RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_MaskConstantHash.EXISTS ( p_mask )) THEN

          --#<constant pool format> long constant.

         l_ptr := emit_data ( const_long_tag || HEXTORAW ( p_mask ));
         h_MaskConstantHash( p_mask ) := l_ptr;

      ELSE

         l_ptr := h_MaskConstantHash ( p_mask );

      END IF;
      RETURN l_ptr;
   END emit_mask_constant;
---------------------------------------------------------------------------------------
   --Scope: compile_logic_file
   --This functions emits a date in Java's long representation.
   --Example: effective_from, effective_until
   FUNCTION emit_date_constant ( p_date IN DATE ) RETURN PLS_INTEGER IS

     l_num  NUMBER := ( p_date - const_java_epoch_begin ) * 86400000;
     l_key  VARCHAR2(4000) := TO_CHAR ( l_num );
     l_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_LongConstantHash.EXISTS ( l_key )) THEN

         --#<constant pool format>

         l_ptr := emit_data ( const_date_tag || cz_fce_compile_utils.long_raw ( l_num ));
         h_LongConstantHash ( l_key ) := l_ptr;

      ELSE

         l_ptr := h_LongConstantHash ( l_key );

      END IF;
      RETURN l_ptr;
   END emit_date_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_double_constant ( p_number IN NUMBER ) RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER;
     l_key  VARCHAR2(4000) := TO_CHAR ( p_number );

   BEGIN

      IF (NOT h_DoubleConstantHash.EXISTS ( l_key )) THEN

         --#<constant pool format>

         l_ptr := emit_data ( const_double_tag || cz_fce_compile_utils.double_raw ( p_number ));
         h_DoubleConstantHash ( l_key ) := l_ptr;

      ELSE

         l_ptr := h_DoubleConstantHash ( l_key );

      END IF;
      RETURN l_ptr;
   END emit_double_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE push_string_constant ( p_string IN VARCHAR2 ) IS
   BEGIN

        emit_ldc ( emit_string_constant ( p_string ));

   END push_string_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE push_double_constant ( p_number IN NUMBER ) IS
   BEGIN

      emit_ldc ( emit_double_constant ( p_number ));

   END push_double_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE push_mask_constant ( p_mask IN VARCHAR2 ) IS
   BEGIN

      emit_ldc ( emit_mask_constant ( p_mask ));

   END push_mask_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE push_date_constant ( p_date IN DATE ) IS
   BEGIN

      emit_ldc ( emit_date_constant ( p_date ));

   END push_date_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   --This procedure is different from the push_long_constant in that it does not go
   --beyond integer. This is useful when we need to be sure that the number is not
   --long, for example when pushing an array size or integer parameters.

   PROCEDURE push_integer_constant ( p_int IN PLS_INTEGER ) IS
   BEGIN

      IF ( cz_fce_compile_utils.assert_iconst ( p_int )) THEN

         emit_iconst ( p_int );

      ELSIF ( cz_fce_compile_utils.assert_byte ( p_int )) THEN

         emit_code ( h_inst ('bipush') || cz_fce_compile_utils.byte ( p_int ));

      ELSIF ( cz_fce_compile_utils.assert_word ( p_int )) THEN

         emit_code ( h_inst ('sipush') || cz_fce_compile_utils.word ( p_int ));

      ELSIF ( cz_fce_compile_utils.assert_integer ( p_int )) THEN

         emit_ldc ( emit_integer_constant ( p_int ));

      ELSE

         report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_INTEGER_TOO_LONG, 'VALUE', TO_CHAR ( p_int )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
         );

      END IF;
   END push_integer_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE push_long_constant ( p_int IN NUMBER ) IS

      l_ptr  PLS_INTEGER;

   BEGIN

      IF ( cz_fce_compile_utils.assert_integer ( p_int )) THEN

         push_integer_constant ( p_int );

      ELSIF ( cz_fce_compile_utils.assert_long ( p_int )) THEN

         emit_ldc ( emit_long_constant ( p_int ));

      ELSE

         report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_LONG_TOO_LONG, 'VALUE', TO_CHAR ( p_int )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
         );

      END IF;
   END push_long_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   --This procedure tries to push the decimal in the most economical way, first as an
   --integer, if that fails as a 4-byte float and if that fails - as a 8-byte double.
   --If there are any problems in Java with implicit conversions, we may need to give
   --up using float constants at all, and this procedure will just push double.

   --Bug #6730258 shows, that we have to give up trying to store decimal constants as
   --floats. All procedures working with float numbers are removed from this package.
   --They can also be removed from cz_fce_compile_utils and ConstantPool class.

   PROCEDURE push_decimal_constant ( p_number IN NUMBER ) IS
   BEGIN

      IF ( ROUND ( p_number ) = p_number AND cz_fce_compile_utils.assert_long ( p_number )) THEN

         push_long_constant ( p_number );

      ELSE

         push_double_constant ( p_number );

      END IF;
   END push_decimal_constant;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_pop ( p_elements IN PLS_INTEGER ) IS
   BEGIN

      IF ( p_elements = 0 ) THEN

         RETURN;

      ELSIF ( p_elements = 1 ) THEN

         emit_code( h_inst('pop'));

      ELSE

         push_integer_constant ( p_elements );
         emit_code( h_inst('mpop'));

      END IF;
   END emit_pop;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION emit_method_descriptor ( p_ptr IN PLS_INTEGER ) RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER;

   BEGIN

      IF (NOT h_MethodDescriptorHash.EXISTS( p_ptr )) THEN

         IF ( cz_fce_compile_utils.assert_unsigned_byte( p_ptr )) THEN

            l_ptr := emit_data(const_method_tag || cz_fce_compile_utils.unsigned_byte( p_ptr ));
            h_MethodDescriptorHash( p_ptr ) := l_ptr;

         ELSE

            report_and_raise_sys_error(
                p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_METHODIX_OUTOFRANGE, 'VALUE', TO_CHAR ( p_ptr )),
                p_run_id => x_run_id,
                p_model_id => p_component_id
             );

         END IF;

      ELSE

         l_ptr := h_MethodDescriptorHash( p_ptr );

      END IF;
      RETURN l_ptr;
   END emit_method_descriptor;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_invokestatic ( p_signature IN VARCHAR2 ) IS
   BEGIN

      emit_code(h_inst('invokestatic') ||
           cz_fce_compile_utils.unsigned_word ( emit_method_descriptor ( h_methoddescriptors ( p_signature ))));

   END emit_invokestatic;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_invokevirtual ( p_signature IN VARCHAR2 ) IS
   BEGIN

      emit_code(h_inst('invokevirtual') ||
           cz_fce_compile_utils.unsigned_word ( emit_method_descriptor ( h_methoddescriptors ( p_signature ))));

   END emit_invokevirtual;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_regop ( p_ptr IN PLS_INTEGER, p_op IN VARCHAR2 ) IS
   BEGIN

      IF ( p_op NOT IN ( 'astore', 'copyto', 'aload' )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_UNKNOWN_OPERATION, 'OPERATION', p_op),
            p_run_id => x_run_id,
            p_model_id => p_component_id
           );

      END IF;

      IF ( NOT cz_fce_compile_utils.assert_unsigned_byte ( p_ptr )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_INVALID_ACCESS_VAR, 'OPERATION', p_op, 'VAR', TO_CHAR ( p_ptr )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
           );

      END IF;

      IF ( p_ptr < 4 ) THEN

         emit_code ( h_inst ( p_op || '_' || TO_CHAR ( p_ptr )));

      ELSE

         emit_code ( h_inst ( p_op ) || cz_fce_compile_utils.unsigned_byte ( p_ptr ));

      END IF;
   END emit_regop;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_regop_w ( p_ptr IN PLS_INTEGER, p_op IN VARCHAR2 ) IS
   BEGIN

      IF ( p_op NOT IN ( 'astore', 'copyto', 'aload' )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_UNKNOWN_OPERATION, 'OPERATION', p_op || '_w'),
            p_run_id => x_run_id,
            p_model_id => p_component_id
           );

      END IF;

      IF ( NOT cz_fce_compile_utils.assert_unsigned_word ( p_ptr )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_INVALID_ACCESS_VARW, 'OPERATION', p_op, 'VAR', TO_CHAR ( p_ptr )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
           );

      END IF;

      emit_code ( h_inst ( p_op || '_w') || cz_fce_compile_utils.unsigned_word ( p_ptr ));

   END emit_regop_w;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_boolean ( p_value IN VARCHAR2 ) IS
   BEGIN

      IF ( p_value = '0' ) THEN

         emit_code ( h_inst ('pushfalse'));

      ELSE

         emit_code ( h_inst ('pushtrue'));

      END IF;
   END emit_boolean;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_constant ( p_int IN NUMBER ) IS
   BEGIN

      emit_code ( h_inst ('pushmath') || cz_fce_compile_utils.unsigned_byte ( p_int ));

   END emit_constant;
---------------------------------------------------------------------------------------
   PROCEDURE emit_comment ( p_string IN VARCHAR2 ) IS
   BEGIN

      emit_code ( h_inst ('comment') || cz_fce_compile_utils.unsigned_word ( emit_string_constant ( p_string )));

   END emit_comment;
---------------------------------------------------------------------------------------
   --The Interpreter has 2 hastore instructions:
   --hastore_0 stores in the internal hash #0;
   --hastore_1 stores in the internal hash #1.
   -- Scope: compile_logic_file
   PROCEDURE hastore_object ( p_id IN NUMBER, p_hash IN PLS_INTEGER ) IS
   BEGIN

      push_long_constant( p_id );
      emit_code ( h_inst ( 'hastore_' || TO_CHAR ( p_hash )));

   END hastore_object;
---------------------------------------------------------------------------------------
   --The Interpreter has 3 haload instructions, this procedure handles 2 of them:
   --haload_0 loads from the internal hash #0;
   --haload_1 loads from the internal hash #1;
   -- Scope: compile_logic_file
   PROCEDURE haload_object ( p_id IN NUMBER, p_hash IN PLS_INTEGER ) IS
   BEGIN

      push_long_constant ( p_id );
      emit_code (h_inst ( 'haload_' || TO_CHAR ( p_hash )));

   END haload_object;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE haload2_object ( p_ref_id IN NUMBER ) IS
   BEGIN

      push_long_constant( p_ref_id );
      emit_code ( h_inst ( 'haload_2'));

   END haload2_object;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION allocate_local_variable RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER := localvariable_ptr;

   BEGIN

      IF ( localvariable_ptr < const_max_localvariables ) THEN

         localvariable_ptr := localvariable_ptr + 1;

      ELSE

         --All local variables are allocated, select a local variables to use.
         --Algorithms, like 'least used' variable, can be implemented here.

         localvariable_ptr := 0;
         l_ptr := 0;

      END IF;

      --Important: if the allocated local variable was used to store an object
      --and now is being overloaded, we need to disassociate that object with
      --this local variable otherwise code may think that this object is still
      --stored in this variable.

      IF (h_LocalVariableBackPtr.EXISTS( l_ptr )) THEN

         h_LocalVariableHash.DELETE(h_LocalVariableBackPtr( l_ptr ));

      END IF;

      RETURN l_ptr;
   END allocate_local_variable;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION local_variable_defined ( p_key IN VARCHAR ) RETURN BOOLEAN IS
   BEGIN

      RETURN h_LocalVariableHash.EXISTS( p_key );

   END local_variable_defined;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION local_variable_index ( p_key IN VARCHAR2 ) RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER;

   BEGIN

      --Note, that this implementation re-writes a local variable, if such variable has
      --already been allocated for the key. This is done in order to allow many-to-one
      --object-key relation, for example, several root expressions in the same rule can
      --be keyed by rule_id and stored in the same variable one after another.

      IF ( NOT local_variable_defined ( p_key )) THEN

         l_ptr := allocate_local_variable ();
         h_LocalVariableHash( p_key ) := l_ptr;
         h_LocalVariableBackPtr( l_ptr ) := p_key;

      ELSE

         l_ptr := h_LocalVariableHash ( p_key );

      END IF;

      RETURN l_ptr;
   END local_variable_index;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE astore_local_variable ( p_key IN VARCHAR2 ) IS
   BEGIN

      emit_regop ( local_variable_index ( p_key ), 'astore' );

   END astore_local_variable;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE copyto_local_variable ( p_id IN NUMBER ) IS
   BEGIN

      emit_regop ( local_variable_index ( TO_CHAR( p_id )), 'copyto' );

   END copyto_local_variable;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE copyto_local_variable ( p_key IN VARCHAR2 ) IS
   BEGIN

      emit_regop ( local_variable_index ( p_key ), 'copyto' );

   END copyto_local_variable;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE aload_local_variable ( p_key IN VARCHAR2 ) IS
   BEGIN

      IF ( NOT local_variable_defined ( p_key )) THEN

        --#<should never happen>
        report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_UNDEFINED_LOCAL_VAR, 'KEY', p_key),
            p_run_id => x_run_id,
            p_model_id => p_component_id
        );

      END IF;

      emit_regop ( h_LocalVariableHash ( p_key ), 'aload' );

   END aload_local_variable;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE free_registers IS
   BEGIN

       register_ptr := 0;
       h_RegisterHash.DELETE;

   END free_registers;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION allocate_register RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER := register_ptr;

   BEGIN

      IF ( register_ptr >= const_max_registers ) THEN

         report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_NO_MORE_REGISTERS),
            p_run_id => x_run_id,
            p_model_id => p_component_id
        );
      END IF;

      register_ptr := register_ptr + 1;

      RETURN l_ptr;
   END allocate_register;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION register_defined ( p_key IN VARCHAR ) RETURN BOOLEAN IS
   BEGIN

      RETURN h_RegisterHash.EXISTS( p_key );

   END register_defined;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION register_index ( p_key IN VARCHAR2 ) RETURN PLS_INTEGER IS

     l_ptr  PLS_INTEGER;

   BEGIN

      --Note, that this implementation re-writes a local variable, if such variable has
      --already been allocated for the key.

      IF ( NOT register_defined ( p_key )) THEN

         l_ptr := allocate_register ();
         h_RegisterHash( p_key ) := l_ptr;

      ELSE

         l_ptr := h_RegisterHash ( p_key );

      END IF;

      RETURN l_ptr;
   END register_index;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE astore_register ( p_key IN VARCHAR2 ) IS
   BEGIN

      emit_regop_w ( register_index ( p_key ), 'astore' );

   END astore_register;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE copyto_register ( p_key IN VARCHAR2 ) IS
   BEGIN

      emit_regop_w ( register_index ( p_key ), 'copyto' );

   END copyto_register;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE aload_register ( p_key IN VARCHAR2 ) IS
   BEGIN

      IF ( NOT register_defined ( p_key )) THEN

        --#<should never happen>
        report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_UNDEFINED_REGISTER, 'KEY', p_key),
            p_run_id => x_run_id,
            p_model_id => p_component_id
        );

      END IF;

      emit_regop_w ( h_RegisterHash ( p_key ), 'aload' );

   END aload_register;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE create_array ( p_size IN PLS_INTEGER, p_type IN PLS_INTEGER ) IS
   BEGIN

      IF ( NOT cz_fce_compile_utils.assert_unsigned_byte ( p_type )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_INCORRECT_IX, 'VALUE', TO_CHAR ( p_type )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
        );

      END IF;

      push_integer_constant ( p_size );
      emit_code( h_inst ('newarray') || cz_fce_compile_utils.unsigned_byte ( p_type ));

   END create_array;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE populate_array_element ( p_index IN PLS_INTEGER ) IS
   BEGIN

      push_integer_constant ( p_index );
      emit_code( h_inst ('aastore'));

   END populate_array_element;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE populate_array ( p_size IN PLS_INTEGER ) IS
   BEGIN

      push_integer_constant ( p_size );
      emit_code( h_inst ('bulkaastore'));

   END populate_array;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE create_multi_array ( p_sizes IN type_integer_table, p_type IN PLS_INTEGER ) IS

      l_count   PLS_INTEGER;

   BEGIN

      IF ( NOT cz_fce_compile_utils.assert_unsigned_byte ( p_type )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_INCORRECT_IX, 'VALUE', TO_CHAR ( p_type )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
          );

      END IF;

      l_count := p_sizes.COUNT;

      IF ( NOT cz_fce_compile_utils.assert_unsigned_byte ( l_count )) THEN

          report_and_raise_sys_error(
            p_message => GET_NOT_TRANSLATED_TEXT(CZ_FCE_SE_EXCEED_INTTABLESIZE, 'VALUE', TO_CHAR ( l_count )),
            p_run_id => x_run_id,
            p_model_id => p_component_id
          );

      END IF;

      FOR i IN REVERSE 1..l_count LOOP

         push_integer_constant ( p_sizes ( i ));

      END LOOP;

      emit_code( h_inst ('multinewarray') || cz_fce_compile_utils.unsigned_byte ( l_count ) ||
                          cz_fce_compile_utils.unsigned_byte ( p_type ));

   END create_multi_array;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_return IS
   BEGIN

      IF ( p_type = const_logicfile_def ) THEN

        emit_code ( h_inst ('areturn'));

      ELSE

        emit_code ( h_inst ('ret'));

      END IF;
   END emit_return;
---------------------------------------------------------------------------------------
------------------------------ HIGH LEVEL METHODS -------------------------------------
---------------------------------------------------------------------------------------
  PROCEDURE comment ( p_message IN VARCHAR2 ) IS
  BEGIN

    IF ( p_debug_mode = 1 ) THEN

      emit_comment ( p_message );

    END IF;
  END comment;
---------------------------------------------------------------------------------------
   --This procedure writes to the Constant Pool and pushed a variable name to the stack.
   --In the debug mode, the variable name is the structure node name.
   --In the regular mode, the variable name is the persistent id (as a string).
   -- Scope: compile_logic_file

   PROCEDURE push_variable_name ( p_index IN PLS_INTEGER ) IS
   BEGIN

      IF ( p_debug_mode = 1 ) THEN

        push_string_constant ( t_psn_name ( p_index ));

      ELSE

        push_string_constant( TO_CHAR ( t_psn_persistentnodeid ( p_index )));

      END IF;
   END push_variable_name;
---------------------------------------------------------------------------------------
   --This is the same procedure as above, but the input parameter is ps_node_id.
   -- Scope: compile_logic_file

   PROCEDURE push_variable_name ( p_id IN NUMBER ) IS
   BEGIN

      IF ( p_debug_mode = 1 ) THEN

        push_string_constant ( h_psnid_name ( TO_CHAR ( p_id )));

      ELSE

        push_string_constant( h_psnid_persistentnodeid ( TO_CHAR ( p_id )));

      END IF;
   END push_variable_name;
---------------------------------------------------------------------------------------
   --This procedure is used to store model defs in the local hash.
   --Note that model defs are hashed by persistent_node_id.

   --Here is why we need to hash by persistent_node_id, not ps_node_id. This procedure
   --will put a hash key on the stack and emit haload_0 instruction. The hash key will
   --be used to poke hash in order to get model def object. If there is no model def
   --for this key in the Interpreter's hash, the Interpreter must ask DIO for it.
   --DIO needs the referring node's persistent_node_id to be able to return model def.
   --So, to avoid conflicts, we need to always use persistent_node_id as the hash key.

   --However, because of using persistent_node_id, the model def hash (#0) can only be
   --used for 'local' model defs, or model defs, that are directly referenced from the
   --'local' model, not for remote models defs, retrieved with haload_2.

   -- Scope: compile_logic_file

   PROCEDURE hastore_def ( p_index IN PLS_INTEGER ) IS
   BEGIN

     hastore_object ( t_psn_persistentnodeid ( p_index ), 0);

   END hastore_def;
---------------------------------------------------------------------------------------
   --This procedure is used to load model defs from the local hash.

   --p_id - ps_node_id. Note that model defs are hashed by persistent_node_id.
   -- Scope: compile_logic_file

   PROCEDURE haload_def ( p_id IN NUMBER ) IS
   BEGIN

     haload_object ( h_psnid_persistentnodeid ( TO_CHAR ( p_id )), 0);

   END haload_def;
---------------------------------------------------------------------------------------
   --This procedure is used to retrieve model definitions, stored in a local variable.
   --Model definitions use ps_node_id as a hash key to allocate local variables.

   --Note that this procedure can be used as a universal access to 'local' model defs.
   --Even in port or constrain logic file, try to get model def from a local variable,
   --and if it is not there, get it from hash and store in a local variable.

   --Made a change to use this procedure for access to 'local' model defs.
   -- Scope: compile_logic_file

   PROCEDURE aload_model_def ( p_id IN NUMBER ) IS

     l_key  VARCHAR2(4000) := TO_CHAR ( p_id );

   BEGIN

      IF (NOT local_variable_defined ( l_key )) THEN

         --Model defs are always stored both in local variables and in hash. So, if it's
         --not in a local variable, meaning that the local variable has been overloaded,
         --we can get it from hash and re-store in a local variable.

         haload_def ( p_id );
         copyto_local_variable ( l_key );

      ELSE

         aload_local_variable ( l_key );

      END IF;
   END aload_model_def;
---------------------------------------------------------------------------------------
   --This procedure is used to store Solver variables in the local hash.

   --p_id - ps_node_id. Note that variable objects are hashed by ps_node_id.
   -- Scope: compile_logic_file

   PROCEDURE hastore_var ( p_index IN PLS_INTEGER ) IS
   BEGIN

       hastore_object ( t_psn_psnodeid ( p_index ), 1 );

   END hastore_var;
---------------------------------------------------------------------------------------
   PROCEDURE push_modeldef_name ( p_index IN PLS_INTEGER ) IS

     l_name   VARCHAR2(4000);

   BEGIN

      --Bug #6926688. For root models, we need to specify the repository model name
      --instead of ps_node name. We don't need to handle no_data_found here because
      --it will not get this far without the data.

      IF ( t_psn_parentid ( p_index ) IS NULL ) THEN

         SELECT name INTO l_name FROM cz_rp_entries
          WHERE deleted_flag = '0'
            AND object_type = 'PRJ'
            AND object_id = t_psn_psnodeid ( p_index );

         --Note that we always write name independently of debug mode.

         push_string_constant ( l_name );
         comment ( 'Create model: "' || l_name || '" (model_id = ' || t_psn_psnodeid ( p_index ) || ')');

      ELSE

         push_variable_name ( p_index );

      END IF;
   END push_modeldef_name;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file

   PROCEDURE emit_model_def ( p_index IN PLS_INTEGER ) IS

     l_path       VARCHAR2(32000);
     l_id         NUMBER := t_psn_psnodeid ( p_index );
     l_parent_id  NUMBER;

   BEGIN

      push_modeldef_name ( p_index );
      emit_invokestatic ('Solver.createModelDef(String)');

      --If this is the root model, save the model def on stack to be returned at the
      --end.

      IF ( t_psn_parentid ( p_index ) IS NULL ) THEN emit_dup (); END IF;

      --Store in a hash and in a local variable.

      copyto_local_variable ( l_id );
      hastore_def ( p_index );
   END emit_model_def;
---------------------------------------------------------------------------------------
   PROCEDURE emit_effectivity ( p_classname   IN VARCHAR2
                              , p_eff_from    IN DATE
                              , p_eff_until   IN DATE
                              , p_eff_usages  IN VARCHAR2
                              ) IS

      l_eff_from     DATE := NVL ( p_eff_from, const_epoch_begin );
      l_eff_until    DATE := NVL ( p_eff_until, const_epoch_end );
      l_eff_usages   VARCHAR2(16) := LPAD ( p_eff_usages, 16, '0');

   BEGIN

        IF ( l_eff_from > const_epoch_begin ) THEN

            emit_dup ();
            push_date_constant ( l_eff_from );

            emit_invokevirtual ( p_classname || '.setEffectiveFrom(Date)');
            emit_pop ( 1 );

        END IF;

        IF ( l_eff_until < const_epoch_end ) THEN

            emit_dup ();
            push_date_constant ( l_eff_until );

            emit_invokevirtual ( p_classname || '.setEffectiveUntil(Date)');
            emit_pop ( 1 );

        END IF;

        IF ( l_eff_usages <> const_mask_all_usages ) THEN

            emit_dup ();
            push_mask_constant ( p_eff_usages );

            emit_invokevirtual ( p_classname || '.setEffectiveUsages(long)');
            emit_pop ( 1 );

        END IF;
   END emit_effectivity;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_domainorder ( p_index IN PLS_INTEGER ) IS
   BEGIN

      --This handles NULL correctly: NULL <> 0 is false, nothing will be generated.

      IF ( t_psn_domainorder ( p_index ) <> 0) THEN

        --This method is called on a variable right after the variable is created, so the variable
        --is on the stack. Need to 'dup' because after calling this method the variable will again
        --be either haloaded or popped.

        emit_dup ();

        emit_invokevirtual (
             CASE t_psn_domainorder ( p_index )
                 WHEN const_domainorder_minfirst THEN 'IIntExprDef.setDomOrderMinFirst()'
                 WHEN const_domainorder_maxfirst THEN 'IIntExprDef.setDomOrderMaxFirst()'
                 WHEN const_domainorder_decmax THEN 'IIntExprDef.setDomOrderDecMax()'
                 WHEN const_domainorder_incmin THEN 'IIntExprDef.setDomOrderIncMin()'
                 WHEN const_domainorder_preffalse THEN 'IIntExprDef.setDomOrderMinFirst()'
                 WHEN const_domainorder_preftrue THEN 'IIntExprDef.setDomOrderMaxFirst()'
             END);

        --Void methods push null, need to pop it from the stack.

        emit_pop ( 1 );
      END IF;
   END emit_domainorder;
---------------------------------------------------------------------------------------
   PROCEDURE emit_setid ( p_index IN PLS_INTEGER ) IS
   BEGIN

      emit_dup ();
      push_long_constant ( t_psn_persistentnodeid ( p_index ));
      emit_invokevirtual ('IExprDef.setId(long)');

      --Remove the null object from stack after a void method.

      emit_pop ( 1 );

   END emit_setid;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_logicvar ( p_index IN PLS_INTEGER ) IS
   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

      emit_invokevirtual ('IModelDef.logicVar(String)');
      emit_domainorder ( p_index );

      emit_effectivity ( 'ILogicExprDef', t_psn_effectivefrom ( p_index ), t_psn_effectiveuntil ( p_index ), t_psn_effectiveusagemask ( p_index ));

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_logicvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_intvar ( p_index IN PLS_INTEGER
                         , p_min   IN NUMBER
                         , p_max   IN NUMBER
                         ) IS

     l_ptr  PLS_INTEGER;

   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

      push_integer_constant ( p_min );
      push_integer_constant ( p_max );

      emit_invokevirtual ('IModelDef.intVar(String, int, int)');
      emit_domainorder ( p_index );

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_intvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_floatvar ( p_index IN PLS_INTEGER
                           , p_min   IN NUMBER
                           , p_max   IN NUMBER
                           ) IS
   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

      --Null values should not be allowed.

      push_double_constant ( p_min );
      push_double_constant ( p_max );

      emit_invokevirtual ('IModelDef.floatVar(String, double, double)');
      emit_domainorder ( p_index );

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_floatvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   --This procedure pushes on the stack the parent's object and the current variable
   --name. It is called for a feature to put the first two parameters of the feature
   --method on the stack before the options array.
   -- Scope: compile_logic_file
   PROCEDURE prepare_feature ( p_index IN PLS_INTEGER) IS
   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

   END prepare_feature;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bagvar( p_index          IN PLS_INTEGER
                        , p_option_count   IN PLS_INTEGER
                        , p_cardmin        IN NUMBER
                        , p_cardmax        IN NUMBER
                        , p_countmin       IN NUMBER
                        , p_countmax       IN NUMBER
                        , p_max_option_qty IN NUMBER
                        ) IS
   BEGIN

      create_array ( p_option_count, h_javatypes('Object'));
      populate_array ( p_option_count );
      push_integer_constant ( p_cardmin );
      push_integer_constant ( p_cardmax );
      push_integer_constant ( p_countmin );
      push_integer_constant ( p_countmax );
      push_integer_constant ( p_max_option_qty );

      emit_invokevirtual ('IModelDef.bagVar(String, Object[], int, int, int, int, int)');
      emit_effectivity ( 'ISetExprDef', t_psn_effectivefrom ( p_index ), t_psn_effectiveuntil ( p_index ), t_psn_effectiveusagemask ( p_index ));

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_bagvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_setvar( p_index        IN PLS_INTEGER
                        , p_option_count IN PLS_INTEGER
                        , p_cardmin      IN NUMBER
                        , p_cardmax      IN NUMBER
                        ) IS
   BEGIN

      create_array ( p_option_count, h_javatypes('Object'));
      populate_array ( p_option_count );
      push_integer_constant ( p_cardmin );
      push_integer_constant ( p_cardmax );

      emit_invokevirtual ('IModelDef.setVar(String, Object[], int, int)');
      emit_effectivity ( 'ISetExprDef', t_psn_effectivefrom ( p_index ), t_psn_effectiveuntil ( p_index ), t_psn_effectiveusagemask ( p_index ));

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_setvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_singletonvar( p_index IN PLS_INTEGER ) IS

     l_id  NUMBER := t_psn_psnodeid ( p_index );

   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );
      aload_model_def ( l_id );
      emit_invokevirtual ('IModelDef.singletonVar(String, IModelDef)');

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_singletonvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_instancesetvar( p_index    IN PLS_INTEGER
                                , p_cardmin  IN NUMBER
                                , p_cardmax  IN NUMBER
                                ) IS
   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

      --#<dio integration>
      --A call to DIO will be made to retrieve the model def of the referenced model. The
      --referenced model is uniquely identified by the reference's persistent_node_id
      --within the context of the referencing model.

      aload_model_def ( t_psn_psnodeid (p_index));
      push_integer_constant ( p_cardmin );
      push_integer_constant ( p_cardmax );

      emit_invokevirtual ('IModelDef.instanceSetVar(String, IModelDef, int, int)');
      emit_effectivity ( 'IPortExprDef', t_psn_effectivefrom ( p_index ), t_psn_effectiveuntil ( p_index ), t_psn_effectiveusagemask ( p_index ));

      emit_setid ( p_index );

      --Variables can be only referenced in rule or port logic files, so there is
      --no need to store them in a local variable.

      hastore_var ( p_index );
   END emit_instancesetvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_connectorsetvar( p_index    IN PLS_INTEGER
                                 , p_cardmin  IN NUMBER
                                 , p_cardmax  IN NUMBER
                                 ) IS
   BEGIN

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );

      --#<dio integration>
      --A call to DIO will be made to retrieve the model def of the referenced model. The
      --referenced model is uniquely identified by the reference's persistent_node_id
      --within the context of the referencing model.

      aload_model_def ( t_psn_psnodeid (p_index));
      push_integer_constant ( p_cardmin );
      push_integer_constant ( p_cardmax );

      emit_invokevirtual ('IModelDef.connectorSetVar(String, IModelDef, int, int)');
      emit_effectivity ( 'IPortExprDef', t_psn_effectivefrom ( p_index ), t_psn_effectiveuntil ( p_index ), t_psn_effectiveusagemask ( p_index ));

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_connectorsetvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bommodel_def ( p_index        IN PLS_INTEGER
                               , p_decimal_flag IN VARCHAR2
                               ) IS

     l_id   NUMBER := t_psn_psnodeid ( p_index );

   BEGIN

      push_modeldef_name ( p_index );
      emit_boolean ( p_decimal_flag );
      emit_invokestatic ('Solver.createBomModelDef(String, boolean)');

      --If this is the root model, save the model def on stack to be returned at the end.

      IF ( t_psn_parentid ( p_index ) IS NULL) THEN emit_dup (); END IF;

      --Store in a hash and in a local variable.

      copyto_local_variable ( l_id );
      hastore_def ( p_index );
   END emit_bommodel_def;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bomoptionclass_def ( p_index        IN PLS_INTEGER
                                     , p_decimal_flag IN VARCHAR2
                                     ) IS

     l_id   NUMBER := t_psn_psnodeid ( p_index );

   BEGIN

      push_variable_name ( p_index );
      emit_boolean ( p_decimal_flag );
      emit_invokestatic ('Solver.createBomOCDef(String, boolean)');

      --Option class definition is used to create the child standard items, and also the
      --option class variable. Those will be always in the same file, and access the def
      --via a local variable.

      --Also need to hastore, because if there is a reference to another bom model under
      --this option class, the bomModelVar will be called on this object in a different
      --logic file.

      copyto_local_variable ( l_id );
      hastore_def ( p_index );
   END emit_bomoptionclass_def;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bommodelvar ( p_index         IN PLS_INTEGER
                              , p_decimal_flag  IN VARCHAR2
                              , p_required_flag IN VARCHAR2
                              , p_min_qty       IN NUMBER
                              , p_max_qty       IN NUMBER
                              , p_def_qty       IN NUMBER
                              , p_cardmin       IN NUMBER
                              , p_cardmax       IN NUMBER
                              , p_eff_from      IN DATE
                              , p_eff_until     IN DATE
                              , p_eff_mask      IN VARCHAR2
                              ) IS
   BEGIN

      aload_model_def ( t_psn_parentid ( p_index ));
      push_variable_name ( p_index );

      --#<dio integration>
      --A call to DIO will be made to retrieve the model def of the referenced model. The
      --referenced model is uniquely identified by the reference's persistent_node_id
      --within the context of the referencing model.

      aload_model_def ( t_psn_psnodeid ( p_index ));
      emit_boolean ( p_required_flag );

      IF ( p_decimal_flag = '0') THEN

         push_integer_constant ( p_min_qty );
         push_integer_constant ( p_max_qty );
         push_integer_constant ( p_def_qty );
         push_integer_constant ( p_cardmin );
         push_integer_constant ( p_cardmax );

      ELSE

         push_double_constant ( p_min_qty );
         push_double_constant ( p_max_qty );
         push_double_constant ( p_def_qty );
         push_double_constant ( p_cardmin );
         push_double_constant ( p_cardmax );

      END IF;

      push_date_constant ( p_eff_from );
      push_date_constant ( p_eff_until );
      push_mask_constant ( p_eff_mask );

      IF ( p_decimal_flag = '0' ) THEN

         emit_invokevirtual ('IModelDef.bomModelVar(String, IBomModelDef, boolean, int, int, int, int, int, Date, Date, long)');

      ELSE

         emit_invokevirtual ('IModelDef.bomModelVar(String, IBomModelDef, boolean, double, double, double, int, int, Date, Date, long)');

      END IF;

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_bommodelvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bomoptionclassvar ( p_index         IN PLS_INTEGER
                                    , p_decimal_flag  IN VARCHAR2
                                    , p_required_flag IN VARCHAR2
                                    , p_min_qty       IN NUMBER
                                    , p_max_qty       IN NUMBER
                                    , p_def_qty       IN NUMBER
                                    , p_minselected   IN NUMBER
                                    , p_maxselected   IN NUMBER
                                    , p_eff_from      IN DATE
                                    , p_eff_until     IN DATE
                                    , p_eff_mask      IN VARCHAR2
                                    ) IS

     l_id   NUMBER := t_psn_psnodeid ( p_index );

   BEGIN

      --Is there a reason not to use local variable here?

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );
      aload_model_def ( l_id );
      emit_boolean ( p_required_flag );

      IF ( p_decimal_flag = '0' ) THEN

         push_integer_constant ( p_min_qty );
         push_integer_constant ( p_max_qty );
         push_integer_constant ( p_def_qty );
         push_integer_constant ( p_minselected );
         push_integer_constant ( p_maxselected );

      ELSE

         push_double_constant ( p_min_qty );
         push_double_constant ( p_max_qty );
         push_double_constant ( p_def_qty );
         push_double_constant ( p_minselected );
         push_double_constant ( p_maxselected );

      END IF;

      push_date_constant ( p_eff_from );
      push_date_constant ( p_eff_until );
      push_mask_constant ( p_eff_mask );

      IF ( p_decimal_flag = '0') THEN

         emit_invokevirtual ('IBomDef.bomOptionClassVar(String, IBomOCDef, boolean, int, int, int, int, int, Date, Date, long)');

      ELSE

         emit_invokevirtual ('IBomDef.bomOptionClassVar(String, IBomOCDef, boolean, double, double, double, int, int, Date, Date, long)');

      END IF;

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_bomoptionclassvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_bomstandarditemvar ( p_index         IN PLS_INTEGER
                                     , p_decimal_flag  IN VARCHAR2
                                     , p_required_flag IN VARCHAR2
                                     , p_min_qty       IN NUMBER
                                     , p_max_qty       IN NUMBER
                                     , p_def_qty       IN NUMBER
                                     , p_eff_from      IN DATE
                                     , p_eff_until     IN DATE
                                     , p_eff_mask      IN VARCHAR2
                                     ) IS
   BEGIN

      --Is there a reason not to use local variable here?

      aload_model_def ( t_psn_parentid (p_index));
      push_variable_name ( p_index );
      emit_boolean ( p_required_flag );

      IF ( p_decimal_flag = '0' ) THEN

         push_integer_constant ( p_min_qty );
         push_integer_constant ( p_max_qty );
         push_integer_constant ( p_def_qty );

      ELSE

         push_double_constant ( p_min_qty );
         push_double_constant ( p_max_qty );
         push_double_constant ( p_def_qty );

      END IF;

      push_date_constant ( p_eff_from );
      push_date_constant ( p_eff_until );
      push_mask_constant ( p_eff_mask );

      IF ( p_decimal_flag = '0' ) THEN

         emit_invokevirtual ('IBomDef.bomStandardItemVar(String, boolean, int, int, int, Date, Date, long)');

      ELSE

         emit_invokevirtual ('IBomDef.bomStandardItemVar(String, boolean, double, double, double, Date, Date, long)');

      END IF;

      emit_setid ( p_index );
      hastore_var ( p_index );
   END emit_bomstandarditemvar;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE emit_reverseport ( p_index IN PLS_INTEGER) IS
   BEGIN

      --This is a local variable. This only works if this port is a direct child of its own root.

      haload_object ( t_psn_psnodeid (p_index), 1 );

      --This is a remote variable in a direct child model. This only works if this port is
      --a direct child of its own root.

      push_variable_name ( t_psn_reverseportid (p_index));
      haload2_object ( t_psn_persistentnodeid (p_index));

      emit_invokevirtual ('IPortExprDef.setReversePort(IPortExprDef)');

      --#<optimization-reverseport>:Void methods push null, need to pop it from the stack.
      --We do not pop it here in order to implement optimization.
   END emit_reverseport;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE create_feature ( p_index         IN PLS_INTEGER
                            , p_option_count  IN PLS_INTEGER
                            , p_var_min       IN NUMBER
                            , p_var_max       IN NUMBER
                            , p_var_count     IN NUMBER
                            ) IS
   BEGIN

      CASE t_psn_countedoptionsflag ( p_index )

         WHEN '1' THEN

            IF ( p_var_count = 0 ) THEN

               report_and_raise_sys_error(
                p_message => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SE_OPTION_MAXQ_NOT_ZERO,
                    'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH (
                      t_psn_psnodeid ( p_index ),
                      ps_node_id_table_to_string(
                                build_model_path(t_psn_psnodeid ( p_index )) ) ) ),
                p_run_id => x_run_id,
                p_model_id => p_component_id
              );

            END IF;

            emit_bagvar( p_index
                       , p_option_count
                       , p_var_min
                       , p_var_max * p_var_count
                       , p_var_min
                       , p_var_max
                       , p_var_count
                       );

         ELSE

            emit_setvar( p_index
                       , p_option_count
                       , p_var_min
                       , p_var_max
                       );

      END CASE;
   END create_feature;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION is_bom_port ( p_index IN PLS_INTEGER ) RETURN BOOLEAN IS
   BEGIN

      RETURN t_psn_psnodetype ( p_index ) IN ( h_psntypes ('reference'), h_psntypes ('connector')) AND
                 h_psnid_psnodetype ( TO_CHAR ( t_psn_referenceid ( p_index ))) =
                     h_psntypes ('bommodel');

   END is_bom_port;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION is_bom_node ( p_index IN PLS_INTEGER ) RETURN BOOLEAN IS
   BEGIN

      RETURN t_psn_psnodetype ( p_index ) IN ( h_psntypes ('bomoptionclass'), h_psntypes ('bommodel'), h_psntypes ('bomstandard'));

   END is_bom_node;
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   FUNCTION is_bom ( p_index IN PLS_INTEGER ) RETURN BOOLEAN IS
   BEGIN

      RETURN is_bom_node ( p_index ) OR is_bom_port ( p_index );

   END is_bom;
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
   -- Scope: compile_logic_file
   PROCEDURE compile_constraints IS

     t_expl_modelrefexplid        type_number_table;
     t_expl_parentexplnodeid      type_number_table;
     t_expl_componentid           type_number_table;
     t_expl_referringnodeid       type_number_table;
     t_expl_explnodetype          type_number_table;

     h_explid_backindex           type_data_hashtable;
     h_parentid_referring_explid  type_nodehashtable_hashtable;

     t_exp_modelrefexplid         type_number_table;
     t_exp_exprtype               type_number_table;
     t_exp_exprnodeid             type_number_table;
     t_exp_exprparentid           type_number_table;
     t_exp_templateid             type_number_table;
     t_exp_psnodeid               type_number_table;
     t_exp_datavalue              type_varchar4000_table;
     t_exp_propertyid             type_number_table;
     t_exp_paramindex             type_number_table;
     t_exp_argumentindex          type_number_table;
     t_exp_argumentname           type_varchar4000_table;
     t_exp_datatype               type_number_table;
     t_exp_datanumvalue           type_number_table;
     t_exp_paramsignatureid       type_number_table;
     t_exp_relativenodepath       type_varchar4000_table;
     t_exp_seqnbr                 type_number_table;

     h_exprid_childrenindex       type_data_hashtable;
     h_exprid_backindex           type_data_hashtable;
     h_exprid_numberofchildren    type_data_hashtable;
     t_instancequantifiers        type_varchar4000_table;
     h_instancequantifiers        type_data_hashtable;

     h_propertyid_datatype        type_node_hashtable;
     h_propertyid_type            type_node_hashtable;
     h_propertyid_defvalue        type_name_hashtable;
     h_psnid_propertyid_value     type_name_hashtable;

     t_acc_complete_path          type_numbertable_table;
     t_acc_targets                type_varchar4000_table;
     t_acc_target_sequence        type_integer_table;
     t_acc_local_quantifiers      type_varchar4000_table;
     t_acc_contributors           type_contributortable_table;
     t_acc_quantifiers            type_varchar4000table_table;
     h_acc_targets                type_data_hashtable;
     h_acc_quantifiers            type_datahashtable_table;
     t_target_quantifiers         type_varchar4000table_table;
     h_target_quantifiers         type_datahashtable_table;

     h_parameter_stack            type_iteratorhashtable_table;
     t_argument_table             type_integertable_table;

     l_rule_expr_lastindex        PLS_INTEGER;
     l_input_context              expression_context;
     l_output_context             expression_context;

     this_rule_id                 NUMBER;
     this_reason_id               NUMBER;
     this_rule_class              NUMBER;
     this_rule_name               VARCHAR2(255);
     this_effective_from          DATE;
     this_effective_until         DATE;
     this_effective_usages        VARCHAR2(16);

     l_key                        VARCHAR2(4000);
     l_count                      PLS_INTEGER;
     l_run_id                     NUMBER;

     assistant_var_id             PLS_INTEGER := 0;
     target_count_svp             PLS_INTEGER;

     contributor_validation       PLS_INTEGER;

     ----------------------------------------------------------------------------------
     -- This procedure reports user rule warning and by default raises
     -- CZ_LOGICGEN_WARNING exception. Optional p_warning_location can be
     -- specified to record the code location of the warning (like method where
     -- the warning occurred). Warning location is stored in the error_stack column
     -- of the cz_db_logs table.
     -- Scope: compile_constraints
     PROCEDURE report_and_raise_rule_warning (
        p_text IN VARCHAR2,
        p_warning_location IN VARCHAR2 DEFAULT NULL ) IS

     BEGIN
       report_and_raise_warning(
                p_message => p_text,
                p_run_id => x_run_id,
                p_model_id => p_component_id,
                p_ps_node_id => NULL,
                p_rule_id => this_rule_id,
                p_error_stack => p_warning_location
              );
     END report_and_raise_rule_warning;

     -- This procedure reports user rule warning and by default raises
     -- CZ_LOGICGEN_WARNING exception. This procedure substitutes the rule_name
     -- and model_name parameters in the given message. Optional p_warning_location can be
     -- specified to record the code location of the warning (like method where
     -- the warning occurred). Warning location is stored in the error_stack column
     -- of the cz_db_logs table.
     -- Scope: compile_constraints
     PROCEDURE report_and_raise_rule_sys_warn (
        p_text IN VARCHAR2,
        p_warning_location IN VARCHAR2 DEFAULT NULL ) IS

     BEGIN

       report_and_raise_sys_warning(
                p_message => GET_NOT_TRANSLATED_TEXT(
                                p_text,
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_run_id => x_run_id,
                p_model_id => p_component_id,
                p_ps_node_id => NULL,
                p_rule_id => this_rule_id,
                p_error_stack => p_warning_location
              );
     END report_and_raise_rule_sys_warn;

     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION build_reference_path ( p_expl_id IN NUMBER ) RETURN type_number_table IS

       l_expl_id     VARCHAR2(4000) := TO_CHAR ( p_expl_id );
       l_key         VARCHAR2(4000);
       l_index       PLS_INTEGER;
       tl_id_path    type_number_table;

     BEGIN

       IF ( h_explid_referencepath.EXISTS ( l_expl_id )) THEN RETURN h_explid_referencepath ( l_expl_id ); END IF;

       l_key := l_expl_id;

       BEGIN

          WHILE ( l_expl_id IS NOT NULL ) LOOP

             l_index := h_explid_backindex ( l_expl_id );

             IF ( t_expl_referringnodeid ( l_index ) IS NOT NULL ) THEN

                --This is a reference or connector.

                tl_id_path ( tl_id_path.COUNT + 1 ) := t_expl_referringnodeid ( l_index );

             END IF;

             l_expl_id := TO_CHAR ( t_expl_parentexplnodeid ( l_index ));
          END LOOP;

       EXCEPTION
          WHEN OTHERS THEN

              --#<should never happen>
              report_and_raise_rule_sys_warn(
                GET_NOT_TRANSLATED_TEXT(
                    CZ_FCE_SW_INCORRECT_EXPL_ID,
                    'EXPLOSION_ID', l_expl_id),
                p_warning_location => 'build_reference_path');
       END;

       h_explid_referencepath ( l_key ) := tl_id_path;

       RETURN tl_id_path;
     END build_reference_path;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION build_complete_path ( p_node_id IN NUMBER, p_expl_id IN NUMBER ) RETURN type_number_table IS

       tl_complete_path   type_number_table;
       tl_reference_path  type_number_table;
       tl_model_path      type_number_table;

       l_key              VARCHAR2(4000);
       l_start            PLS_INTEGER := 1;

     BEGIN

       l_key := TO_CHAR ( p_node_id ) || '_' || TO_CHAR ( p_expl_id );
       IF ( h_psnid_explid_completepath.EXISTS ( l_key )) THEN RETURN h_psnid_explid_completepath ( l_key ); END IF;

       tl_complete_path := build_model_path ( p_node_id );
       tl_reference_path :=  build_reference_path ( p_expl_id );

       IF ( tl_reference_path.COUNT = 0 ) THEN

          h_psnid_explid_completepath ( l_key ) := tl_complete_path;
          RETURN tl_complete_path;

       END IF;

       IF ( h_psnid_psnodetype ( TO_CHAR ( p_node_id )) IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

          --If the node is a reference or connector itself, we need to cut off its own explosion,
          --which is the first element because the array is populated bottom up.

          l_start := 2;

       END IF;

       FOR i IN l_start..tl_reference_path.COUNT LOOP

          tl_model_path := build_model_path ( tl_reference_path ( i ));

          FOR ii IN 1..tl_model_path.COUNT LOOP

             tl_complete_path ( tl_complete_path.COUNT + 1 ) := tl_model_path ( ii );

          END LOOP;
       END LOOP;

       h_psnid_explid_completepath ( l_key ) := tl_complete_path;

       RETURN tl_complete_path;
     END build_complete_path;
     ----------------------------------------------------------------------------------
    -- Scope: compile_constraints
     PROCEDURE generate_expression ( j IN PLS_INTEGER
                                   , p_input_context IN expression_context
                                   , x_output_context IN OUT NOCOPY expression_context );
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE set_rule_savepoint IS
     BEGIN

        set_savepoint ();
        target_count_svp := t_acc_targets.COUNT;

     END set_rule_savepoint;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE restore_rule_savepoint IS
     BEGIN

        restore_savepoint ();
        t_acc_targets.DELETE ( target_count_svp + 1, t_acc_targets.COUNT );

     END restore_rule_savepoint;
     ----------------------------------------------------------------------------------
   -- Scope: compile_logic_file
     PROCEDURE sum_numeric ( p_count IN PLS_INTEGER ) IS
     BEGIN

        IF ( p_count = 2 ) THEN

           --There are two distinct values, use addition instead of sum.

           emit_invokevirtual ('INumExprDef.sum(INumExprDef)');

        ELSIF ( p_count > 2 ) THEN

           --In general case create an array of parameters and call IModelDef.sum. The model def
           --for that should already be on stack.

           create_array ( p_count, h_javatypes ('INumExprDef'));
           populate_array ( p_count );
           emit_invokevirtual ('IModelDef.sum(INumExprDef[])');

        END IF;
     END sum_numeric;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE clear_argument_table IS
     BEGIN

        IF ( t_argument_table.EXISTS ( h_parameter_stack.COUNT )) THEN

           t_argument_table ( h_parameter_stack.COUNT ).DELETE;

        END IF;
     END clear_argument_table;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE add_argument ( j IN PLS_INTEGER ) IS

        l_count  PLS_INTEGER := 1;

     BEGIN

        IF ( t_argument_table.EXISTS ( h_parameter_stack.COUNT )) THEN

           l_count := t_argument_table ( h_parameter_stack.COUNT ).COUNT + 1;

        END IF;

        t_argument_table ( h_parameter_stack.COUNT )( l_count ) := j;

     END add_argument;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE restore_arguments IS
     BEGIN

        IF ( t_argument_table.EXISTS ( h_parameter_stack.COUNT )) THEN

           FOR i IN 1..t_argument_table ( h_parameter_stack.COUNT ).COUNT LOOP

              t_exp_exprtype ( t_argument_table ( h_parameter_stack.COUNT )( i )) := h_exprtypes ('argument');

           END LOOP;
        END IF;
     END restore_arguments;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION retrieve_parameter ( p_name IN VARCHAR2 ) RETURN type_iterator_value IS

        l_count   PLS_INTEGER;

     BEGIN

        --When generating or looking up a parameter, it is always enough to look up only
        --on top of the stack. We only look up parameters during parsing of where clause
        --which happens before the forall, currently being generated, puts parameters on
        --the stack, so at this moment the parameter from the outer forall, which we are
        --looking up, should be on top of the stack.

        l_count := h_parameter_stack.COUNT;

        IF ( NOT h_parameter_stack ( l_count ).EXISTS ( p_name )) THEN

           --#<should never happen>
           report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT (
                        CZ_FCE_SW_NO_VALUE_PARAMSTK,
                        'PARAM', p_name ),
                p_warning_location => 'retrieve_parameter' );

        END IF;

        RETURN h_parameter_stack ( l_count )( p_name );

     END;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns TRUE when the given expression has children, otherwise returns FALSE.
     FUNCTION expr_has_children ( p_expr_id IN VARCHAR2 ) RETURN BOOLEAN IS
     BEGIN
        IF ( NOT h_exprid_childrenindex.EXISTS ( p_expr_id )) THEN
            RETURN FALSE;
        ELSE
            RETURN TRUE;
        END IF;
     END expr_has_children;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns TRUE when the given expression has only one child, otherwise returns FALSE.
     FUNCTION expr_has_one_child ( p_expr_id IN VARCHAR2 ) RETURN BOOLEAN IS
     BEGIN
        IF ( expr_has_children(p_expr_id) AND h_exprid_numberofchildren ( p_expr_id ) = 1) THEN
         RETURN TRUE;
        ELSE
         RETURN FALSE;
        END IF;
     END expr_has_one_child;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns TRUE when the given expression has only two child, otherwise returns FALSE.
     FUNCTION expr_has_two_children ( p_expr_id IN VARCHAR2 ) RETURN BOOLEAN IS
     BEGIN
        IF ( expr_has_children(p_expr_id) AND h_exprid_numberofchildren ( p_expr_id ) = 2) THEN
         RETURN TRUE;
        ELSE
         RETURN FALSE;
        END IF;
     END expr_has_two_children;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns the node details (using type_iterator_value structure)
     -- associated with the given line index. Returns type_iterator_value.value_type
     -- as null when the line index is not referrings to a node.
     FUNCTION get_structure_node ( p_index IN PLS_INTEGER ) RETURN type_iterator_value IS

        l_parameter        type_iterator_value;

     BEGIN

        l_parameter.value_type := const_valuetype_unknown;

        IF ( t_exp_exprtype ( p_index ) = h_exprtypes ('node')) THEN

           l_parameter.ps_node_id := t_exp_psnodeid ( p_index );
           l_parameter.model_ref_expl_id := t_exp_modelrefexplid ( p_index );

           l_parameter.value_type := const_valuetype_node;

        ELSIF ( t_exp_exprtype ( p_index ) = h_exprtypes ('argument')) THEN

           l_parameter := retrieve_parameter ( t_exp_argumentname ( p_index ));

        END IF;

        IF ( l_parameter.value_type <> const_valuetype_node ) THEN

           l_parameter.value_type := NULL;

        END IF;

        RETURN l_parameter;
     END get_structure_node;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns TRUE when the given node has children, otherwise returns FALSE.
     FUNCTION node_has_children ( p_node_id IN VARCHAR2 ) RETURN BOOLEAN IS
     BEGIN
        IF ( h_psnid_lastchildindex.EXISTS ( p_node_id )) THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
     END node_has_children;
     ----------------------------------------------------------------------------------
     --This function verifies that a node is a port, and returns its target.
     -- Scope: compile_constraints
     -- Returns the target node id for the given port. Returns NULL when
     -- the given id is not a port.
     FUNCTION get_port_id ( p_node_id IN VARCHAR2 ) RETURN NUMBER IS
       l_index   PLS_INTEGER := h_psnid_backindex ( p_node_id );
     BEGIN
       IF ( t_psn_detailedtype ( l_index ) IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

           RETURN t_psn_referenceid ( l_index );

       ELSIF ( t_psn_detailedtype ( l_index ) = h_psntypes ('component')) THEN

           RETURN t_psn_psnodeid ( l_index );

       ELSE

          RETURN NULL;
       END IF;
     END get_port_id;
     ----------------------------------------------------------------------------------
     --This function is used to explode OptionOf or Options() operation into a table of
     --children for boms. Only bom children are included.
    -- Scope: compile_constraints
     FUNCTION explode_bom_children ( p_node_id        IN NUMBER
                                   , p_expl_id        IN NUMBER
                                   , p_first_index    IN PLS_INTEGER
                                   , p_last_index     IN PLS_INTEGER
                                   , p_optional_only  IN BOOLEAN
                                   ) RETURN type_iteratornode_table IS

        t_children          type_iteratornode_table;
        l_expl_id           VARCHAR2(4000);

        l_index             PLS_INTEGER;
        l_count             PLS_INTEGER;

     BEGIN

        l_index := p_first_index;
        l_count := 1;

        l_expl_id := TO_CHAR ( p_expl_id );

        WHILE ( l_index <= p_last_index ) LOOP

           IF ( t_psn_parentid ( l_index ) = p_node_id AND is_bom ( l_index ) AND
                  ( NOT p_optional_only OR t_psn_bomrequiredflag ( l_index ) = '0' )) THEN

              t_children ( l_count ).expr_index := l_index;
              t_children ( l_count ).ps_node_id := t_psn_psnodeid ( l_index );

              IF ( t_psn_psnodetype ( l_index ) IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

                 --If the bom child is a reference, we need to adjust the explosion id to be that
                 --of the reference.

                 t_children ( l_count ).model_ref_expl_id := h_parentid_referring_explid ( l_expl_id )( TO_CHAR ( t_psn_psnodeid ( l_index )));

              ELSE

                 t_children ( l_count ).model_ref_expl_id := p_expl_id;

              END IF;

              l_count := l_count + 1;

           END IF;

           l_index := l_index + 1;

        END LOOP;

        IF ( t_children.COUNT = 0 ) THEN

           -- BOM node ^NODE_NAME has no optional selections to participate in rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

           report_and_raise_rule_warning (
             CZ_UTILS.GET_TEXT ( CZ_FCE_W_NO_OPTIONAL_CHILDREN,
               'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH( p_node_id,
                          ps_node_id_table_to_string(
                                build_complete_path(p_node_id, p_expl_id) ) ),
               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name )),
             'explode_bom_children'
            );

        END IF;

        RETURN t_children;
     END explode_bom_children;
     ----------------------------------------------------------------------------------
     --This function is used to explode OptionOf or Options() operation into a table of
     --children.
     -- Scope: compile_constraints
     FUNCTION explode_node_children ( p_node_id IN NUMBER, p_expl_id IN NUMBER, p_optional_only IN BOOLEAN )
       RETURN type_iteratornode_table IS

        t_children          type_iteratornode_table;
        l_node_id           VARCHAR2(4000);

        l_last_index        PLS_INTEGER;
        l_index             PLS_INTEGER;
        l_count             PLS_INTEGER;

     BEGIN

        l_node_id := TO_CHAR ( p_node_id );
        l_index := h_psnid_backindex ( l_node_id );

        IF ( is_bom_port ( l_index )) THEN

           l_node_id := TO_CHAR ( t_psn_referenceid ( l_index ));
           l_index := h_psnid_backindex ( l_node_id );

        END IF;

        --  Node ^NODE_NAME has no children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

        IF ( node_has_children ( l_node_id )) THEN

          l_last_index := h_psnid_lastchildindex ( l_node_id );

        ELSE

          -- Node ^NODE_NAME has no children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

          report_and_raise_rule_warning (
              p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_NODE_MUST_HAVE_CHILD,
                        'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH( p_node_id,
                          ps_node_id_table_to_string(
                                build_complete_path(p_node_id, p_expl_id) ) ),
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path)
                        ),
              p_warning_location => 'explode_node_children');

        END IF;

        IF ( is_bom_node ( l_index )) THEN

           t_children := explode_bom_children ( l_node_id, p_expl_id, l_index + 1, l_last_index, p_optional_only );

        ELSE

           --If this is non-bom, the operation can only be performed on an option feature.
           --Options always follow the feature and there can be no tokens among them. The
           --explosion is always that of the feature.

           l_index := l_index + 1;
           l_count := 1;

           WHILE ( l_index <= l_last_index ) LOOP

              t_children ( l_count ).expr_index := l_index;
              t_children ( l_count ).ps_node_id := t_psn_psnodeid ( l_index );
              t_children ( l_count ).model_ref_expl_id := p_expl_id;

              l_count := l_count + 1;
              l_index := l_index + 1;

           END LOOP;
        END IF;

        RETURN t_children;
     END explode_node_children;
---------------------------------------------------------------------------------------
     --p_type is either 'ISingletonExprDef', 'IInstanceQuantifier' or 'IPortExprDef'.
     --It can also be NULL if the variable is local.
     -- Scope: compile_constraints
     PROCEDURE push_variable ( p_id IN NUMBER, p_type IN VARCHAR2 ) IS

       l_id   VARCHAR2(4000) := TO_CHAR ( p_id );

     BEGIN

        --This procedure can be called on a Bom Model, when a reference to this model
        --participates in rules.

        IF ( h_psnid_psnodetype ( l_id ) = h_psntypes ('bommodel')) THEN RETURN; END IF;

        IF ( h_psnid_devlprojectid ( l_id ) = p_component_id ) THEN

           --This is a local variable, we can just retrieve it from the local hash.

           haload_object ( p_id , 1 );

        ELSE

           --This is a remote variable. Need to duplicate parent's object on the stack
           --to be used for the call to getType().

           emit_dup ();
           emit_invokevirtual ( p_type || '.getType()');
           push_variable_name ( p_id );
           emit_invokevirtual ('IModelDef.getVar(String)');

        END IF;
     END push_variable;
     ----------------------------------------------------------------------------------
     --This function splits the '_'-separated path of ps_node_id(s) into a number table.
     -- Scope: compile_constraints
     FUNCTION split_path ( p_path IN VARCHAR2 ) RETURN type_number_table IS

       l_substr      VARCHAR2(32000) := p_path;
       l_index       PLS_INTEGER;
       l_return_tbl  type_number_table;

     BEGIN

       IF ( l_substr IS NULL )THEN RETURN l_return_tbl; END IF;

       LOOP

          l_index := INSTR ( l_substr, '_', -1 );

          IF ( l_index > 0 ) THEN

             l_return_tbl ( l_return_tbl.COUNT + 1 ) := TO_NUMBER ( SUBSTR ( l_substr, l_index + 1 ));
             l_substr := SUBSTR (l_substr, 1, l_index - 1 );

          ELSE

             l_return_tbl (l_return_tbl.COUNT + 1 ) := TO_NUMBER ( l_substr );
             EXIT;

          END IF;
       END LOOP;

       RETURN l_return_tbl;
     END split_path;
---------------------------------------------------------------------------------------
     FUNCTION split_str_path ( p_path IN VARCHAR2 ) RETURN type_varchar4000_table IS

       l_substr      VARCHAR2(32000) := p_path;
       l_index       PLS_INTEGER;
       l_return_tbl  type_varchar4000_table;

     BEGIN

       IF ( p_path IS NULL ) THEN RETURN l_return_tbl; END IF;

       LOOP

         l_index := INSTR ( l_substr, FND_GLOBAL.LOCAL_CHR ( 7 ));

         IF( l_index > 0 )THEN

           l_return_tbl (l_return_tbl.COUNT + 1 ) := SUBSTR ( l_substr, 1, l_index - 1 );
           l_substr := SUBSTR( l_substr, l_index + 1 );

         ELSE

           l_return_tbl (l_return_tbl.COUNT + 1 ) := l_substr;
           EXIT;

         END IF;
       END LOOP;

       RETURN l_return_tbl;

     END split_str_path;
---------------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION generate_path ( p_complete_path IN type_number_table
                            , p_input_context IN expression_context
                            , x_output_context IN OUT NOCOPY expression_context
                            ) RETURN PLS_INTEGER IS

        tl_target_path       type_number_table;

        l_count              PLS_INTEGER;
        l_quantifier_index   PLS_INTEGER;
        l_instances_index    PLS_INTEGER;
        l_target_index       PLS_INTEGER;
        l_contrib_index      PLS_INTEGER;
        l_singleton_count    PLS_INTEGER;
        l_acc_count          PLS_INTEGER;
        l_target_count       PLS_INTEGER;

        l_key                VARCHAR2(4000);
        l_return             PLS_INTEGER := const_no_instances;

     BEGIN

        IF ( p_input_context.context_type = const_context_target ) THEN

           l_target_count := t_acc_targets.COUNT;

        END IF;

        --Find the most shallow port, it's instancesOf should be called on IModelDef.

        l_count := p_complete_path.COUNT;
        l_instances_index := l_count;

        WHILE ( l_instances_index > 0 AND h_psnid_detailedtype ( p_complete_path ( l_instances_index )) NOT IN
                 ( h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) LOOP

            l_instances_index := l_instances_index - 1;

        END LOOP;

        IF ( l_instances_index <= l_count AND l_instances_index > 1 ) THEN

           --We count the number of node participants in the contributor expression which are
           --under ports for validation. Participant itself can be the only port in the path,
           --this is allowed (l_instances_index > 1)

           contributor_validation := contributor_validation + 1;

        END IF;

        IF ( p_input_context.context_type = const_context_contributor ) THEN

           --We are generating an accumulation contributor. Need to find the LCA with the target's path,
           --because this will be the instance quantifier. Below this node we will generate hierarchical
           --unions.

           --The target for this contributor is the last element in the array of target.

           l_target_count := p_input_context.context_num_data;
           tl_target_path := t_acc_complete_path ( l_target_count );

           --Find the LCA.

           l_target_index := tl_target_path.COUNT;
           l_contrib_index := l_count;
           l_quantifier_index := l_contrib_index + 1;

           IF ( l_target_index > 0 ) THEN

              WHILE ( l_target_index > 0 AND l_contrib_index > 0 AND
                           tl_target_path ( l_target_index ) = p_complete_path ( l_contrib_index )) LOOP

                 IF ( h_psnid_detailedtype ( p_complete_path ( l_contrib_index )) IN
                            ( h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) THEN

                    l_quantifier_index := l_contrib_index;

                 END IF;

                 l_target_index := l_target_index - 1;
                 l_contrib_index := l_contrib_index - 1;

              END LOOP;
           END IF;

        ELSE

           --Find the deepest port, this will be the instance quantifier to use in forAll.

           l_quantifier_index := 2;

           --#<important>
           --Using h_psnid_detailedtype is very essential here and in the next block. If any changes are made
           --to the definition of h_psnid_detailedtype array, this code may need to change.

           WHILE ( l_quantifier_index <= l_count AND h_psnid_detailedtype ( p_complete_path ( l_quantifier_index )) NOT IN
                    (h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) LOOP

               l_quantifier_index := l_quantifier_index + 1;

           END LOOP;
        END IF;

        IF ( l_instances_index > 1 AND l_instances_index >= l_quantifier_index AND
             NVL ( p_input_context.context_type, const_context_generic ) <> const_context_aggregatesum ) THEN

           --There is a port variable in the path, and it is not the variable itself (l_instances_index > 1),
           --so we will have to call instancesOf on IModelDef.

           aload_model_def ( p_component_id );

        END IF;

        push_variable ( p_complete_path ( l_count ), NULL );
        l_key := TO_CHAR ( p_complete_path ( l_count ));

        l_singleton_count := 0;

        FOR i IN REVERSE 1..l_count - 1 LOOP

           --(need to include 'bommodel' below to support rare cases of old upgraded models, bug #6613028).

           IF ( h_psnid_detailedtype ( p_complete_path ( i + 1 )) IN ( h_psntypes ('singleton'), h_psntypes ('bomoptionclass'), h_psntypes ('bommodel'))) THEN

              l_singleton_count := l_singleton_count + 1;

              push_variable ( p_complete_path ( i ), 'ISingletonExprDef');
              emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

           ELSIF ( h_psnid_detailedtype ( p_complete_path ( i + 1 )) IN ( h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) THEN

              IF ( p_input_context.context_type = const_context_aggregatesum ) THEN

                 IF ( i + 1 < l_instances_index ) THEN

                    emit_invokevirtual('IPortExprDef.hierarchicalUnion(IPortExprDef)');

                 END IF;

                 push_variable ( p_complete_path ( i ), 'IPortExprDef');
                 l_return := const_resourcesum_required;

              ELSE

                 IF ( i + 1 = l_instances_index ) THEN

                    --For the most shallow port down the path need to use this signature.

                    IF ( l_instances_index >= l_quantifier_index ) THEN

                       --This condition is required for contributors, because in this case first component
                       --does not necessarily need instancesOf.

                       emit_invokevirtual('IModelDef.instancesOf(IPortExprDef)');

                    END IF;

                 ELSIF ( i + 1 >= l_quantifier_index ) THEN

                    --We are still above the deepest port.

                    emit_invokevirtual('IInstanceQuantifier.instancesOf(IPortExprDef)');

                 END IF;

                 IF ( i + 1 = l_quantifier_index ) THEN

                    --We need to collect only distinct instance quantifiers.

                    IF ( p_input_context.context_type IN ( const_context_contributor, const_context_target)) THEN

                       t_acc_local_quantifiers ( t_acc_local_quantifiers.COUNT + 1 ) := l_key;

                       IF ( NOT h_acc_quantifiers ( l_target_count ).EXISTS ( l_key )) THEN

                           l_acc_count := t_acc_quantifiers ( l_target_count ).COUNT + 1;

                           t_acc_quantifiers ( l_target_count )( l_acc_count ) := l_key;
                           h_acc_quantifiers ( l_target_count )( l_key ) := 1;

                           copyto_register ( l_key );

                       END IF;

                    ELSE

                       IF ( NOT h_instancequantifiers.EXISTS ( l_key )) THEN

                           t_instancequantifiers ( t_instancequantifiers.COUNT + 1 ) := l_key;
                           h_instancequantifiers ( l_key ) := 1;

                           copyto_local_variable ( l_key );

                       END IF;
                    END IF;

                    l_return := const_quantifier_created;

                 END IF;

                 --Note that if we are below the path's instance quantifier (i + 1 < l_quantifier_index)
                 --and still are on a port, we are generating a contributor, because for a regular node
                 --path's instance quantifier will be on the deepest port.

                 l_contrib_index := i + 2 + l_singleton_count;

                 IF ( l_return = const_quantifier_created AND l_contrib_index = l_quantifier_index ) THEN

                    emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

                 END IF;

                 IF ( l_contrib_index < l_quantifier_index ) THEN

                    emit_invokevirtual('IPortExprDef.hierarchicalUnion(IPortExprDef)');
                    push_variable ( p_complete_path ( i ), 'IPortExprDef');

                    l_return := const_resourcesum_required;

                 ELSIF ( l_contrib_index = l_quantifier_index ) THEN

                    push_variable ( p_complete_path ( i ), 'IPortExprDef');
                    l_return := const_resourcesum_required;

                 ELSE

                    push_variable ( p_complete_path ( i ), 'IInstanceQuantifier');

                 END IF;
              END IF;

              l_singleton_count := 0;

           END IF;

           l_key := l_key || '_' || TO_CHAR ( p_complete_path ( i ));

        END LOOP;

        IF ( p_input_context.context_type = const_context_aggregatesum ) THEN
          IF ( h_psnid_detailedtype ( p_complete_path ( 1 )) IN ( h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) THEN

             IF ( l_instances_index > 1 ) THEN

                emit_invokevirtual('IPortExprDef.hierarchicalUnion(IPortExprDef)');

             END IF;

             l_return := const_resourcesum_required;

          END IF;
        END IF;

        RETURN l_return;
     END generate_path;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION generate_path ( p_node_id IN NUMBER
                            , p_expl_id IN NUMBER
                            , p_input_context IN expression_context
                            , x_output_context IN OUT NOCOPY expression_context
                            ) RETURN PLS_INTEGER IS

        l_target_key         VARCHAR2(4000);
        l_target_count       PLS_INTEGER;

        l_acc_init           type_varchar4000_table;
        h_acc_init           type_data_hashtable;
        tl_complete_path     type_number_table;

     BEGIN

        IF ( p_input_context.context_type = const_context_target ) THEN

           --In general, this key should contain more information about the target,
           --such as properties, applied to the target.

           l_target_key := TO_CHAR ( p_node_id ) || ':' || TO_CHAR ( p_expl_id );

           x_output_context.context_type := const_context_target;
           x_output_context.context_data := l_target_key;

           t_acc_target_sequence ( t_acc_targets.COUNT + 1 ) := 0;
           t_acc_targets ( t_acc_targets.COUNT + 1 ) := l_target_key;

           l_target_count := t_acc_targets.COUNT;

           h_acc_targets ( l_target_key ) := l_target_count;
           t_acc_quantifiers ( l_target_count ) := l_acc_init;
           h_acc_quantifiers ( l_target_count ) := h_acc_init;

           x_output_context.context_num_data := l_target_count;

        END IF;

        tl_complete_path := build_complete_path ( p_node_id, p_expl_id );

        IF ( p_input_context.context_type = const_context_target ) THEN

          t_acc_complete_path ( l_target_count ) := tl_complete_path;

        END IF;

        IF ( tl_complete_path.COUNT = 0 ) THEN RETURN const_no_instances; END IF;

        RETURN generate_path ( tl_complete_path, p_input_context, x_output_context );

     END generate_path;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_quantifier ( p_key IN VARCHAR2 ) IS

        tl_complete_path    type_number_table;
        l_count             PLS_INTEGER;

        l_instancesOf       VARCHAR2(4000);

     BEGIN

        tl_complete_path := split_path ( p_key );
        l_count := tl_complete_path.COUNT;

        IF ( l_count = 0 ) THEN RETURN; END IF;

        l_instancesOf := 'IModelDef.instancesOf(IPortExprDef)';

        aload_model_def ( p_component_id );
        push_variable ( tl_complete_path ( l_count ), NULL );

        FOR i IN REVERSE 1..l_count - 1 LOOP

           IF ( h_psnid_detailedtype ( tl_complete_path ( i + 1 )) IN ( h_psntypes ('singleton'), h_psntypes ('bomoptionclass'))) THEN

              push_variable ( tl_complete_path ( i ), 'ISingletonExprDef');
              emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

           ELSE --(h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))

              emit_invokevirtual( l_instancesOf );
              l_instancesOf := 'IInstanceQuantifier.instancesOf(IPortExprDef)';

              push_variable ( tl_complete_path ( i ), 'IInstanceQuantifier');

           END IF;
        END LOOP;

        emit_invokevirtual( l_instancesOf );
        copyto_local_variable ( p_key );

     END generate_quantifier;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE aload_quantifier ( p_key IN VARCHAR2 ) IS
     BEGIN

        IF ( NOT local_variable_defined ( p_key )) THEN

           generate_quantifier ( p_key );

        ELSE

           aload_local_variable ( p_key );

        END IF;
     END aload_quantifier;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_bom_property ( p_property IN VARCHAR2 ) IS
     BEGIN

         emit_dup ();
         emit_invokevirtual ('ISingletonExprDef.getType()');
         emit_invokevirtual ( p_property );
         emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

     END apply_bom_property;
     ----------------------------------------------------------------------------------
     PROCEDURE any_option_selected IS
     BEGIN

        emit_invokevirtual ('ISetExprDef.card()');
        push_integer_constant ( 0 );
        emit_invokevirtual('INumExprDef.gt(int)');

     END any_option_selected;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE all_options_selected ( p_card IN PLS_INTEGER ) IS
     BEGIN

        emit_invokevirtual ('ISetExprDef.card()');
        push_integer_constant ( p_card );
        emit_invokevirtual('INumExprDef.eq(int)');

     END all_options_selected;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_context_type ( j IN PLS_INTEGER ) RETURN PLS_INTEGER IS

        l_index      PLS_INTEGER;

     BEGIN

        l_index := h_exprid_backindex ( TO_CHAR ( t_exp_exprparentid ( j )));

        CASE t_exp_exprtype ( l_index ) WHEN h_exprtypes ('operator') THEN

          IF ( t_exp_templateid ( l_index ) IN (
                    h_templates ('and')
                  , h_templates ('or')
                  , h_templates ('not')
                  )) THEN

              RETURN h_datatypes ('boolean');

          ELSIF ( t_exp_templateid ( l_index ) IN (
                    h_templates ('equals')
                  , h_templates ('notequals')
                  , h_templates ('gt')
                  , h_templates ('lt')
                  , h_templates ('ge')
                  , h_templates ('le')
                  , h_templates ('add')
                  , h_templates ('subtract')
                  , h_templates ('multiply')
                  , h_templates ('div')
                  , h_templates ('neg')
                  , h_templates ('totext')
                  )) THEN

              --Note, that ToText operator means numeric context for its argument. That means that ToText
              --cannot be applied to a text argument. May need to change if this is a problem.

              RETURN h_datatypes ('decimal');

          ELSIF ( t_exp_templateid ( l_index ) IN (
                    h_templates ('doesnotbeginwith')
                  , h_templates ('doesnotendwith')
                  , h_templates ('doesnotcontain')
                  , h_templates ('notlike')
                  , h_templates ('concatenate')
                  , h_templates ('beginswith')
                  , h_templates ('endswith')
                  , h_templates ('contains')
                  , h_templates ('like')
                  , h_templates ('matches')
                  , h_templates('textequals')
                  , h_templates('textnotequals')
                  )) THEN

              RETURN h_datatypes ('text');

           ELSE
              -- 'Unknown operator type "^OPERTYPE" in the rule. Rule "^RULE_NAME" in the Model ^MODEL_NAME" ignored.';
              report_and_raise_rule_sys_warn(
                GET_NOT_TRANSLATED_TEXT(CZ_FCE_SW_UNKNOWN_OP_TYPE,
                  'OPERTYPE',  TO_CHAR(t_exp_templateid ( j ))),
                'get_context_type'
               );
              RETURN NULL;
           END IF;

        ELSE
           -- 'Unable to get context data type for expression node with the id "^EXPR_ID". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_NO_DTYPE,
                        'EXPR_ID', l_index),
                p_warning_location => 'get_context_type');
           RETURN NULL;

        END CASE;
     END get_context_type;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION logical_context ( j IN PLS_INTEGER, p_context_type IN PLS_INTEGER ) RETURN BOOLEAN IS

        l_parent_id  VARCHAR2(4000);
        l_child      PLS_INTEGER;
        l_index      PLS_INTEGER;

     BEGIN

        IF ( p_context_type = const_context_logical ) THEN RETURN TRUE; END IF;

        l_parent_id := TO_CHAR ( t_exp_exprparentid ( j ));
        IF ( l_parent_id IS NULL ) THEN RETURN FALSE; END IF;

        l_index := h_exprid_backindex ( l_parent_id );

        IF ( h_logical_ops.EXISTS ( t_exp_templateid ( l_index ))) THEN RETURN TRUE; END IF;

        --Bug #7026587. Check the special case when the other operand of equality operator is a boolean literal.

        IF ( t_exp_templateid ( l_index ) IN ( h_templates ('equals'), h_templates ('notequals'))) THEN

           l_child := h_exprid_childrenindex ( l_parent_id );
           IF ( l_child = j ) THEN l_child := l_child + 1; END IF;

           IF ( t_exp_exprtype ( l_child ) = h_exprtypes ('literal') AND t_exp_datatype ( l_child ) = h_datatypes ('boolean')) THEN

              RETURN TRUE;

           END IF;
        END IF;

        RETURN FALSE;
     END logical_context;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION numeric_context ( j IN PLS_INTEGER, p_context_type IN PLS_INTEGER ) RETURN BOOLEAN IS

        l_parent_id  VARCHAR2(4000);
        l_child      PLS_INTEGER;
        l_index      PLS_INTEGER;

     BEGIN

        IF ( p_context_type IN ( const_context_numeric, const_context_contributor, const_context_target, const_context_aggregatesum )) THEN

           RETURN TRUE;

        END IF;

        l_parent_id := TO_CHAR ( t_exp_exprparentid ( j ));
        IF ( l_parent_id IS NULL ) THEN RETURN FALSE; END IF;

        l_index := h_exprid_backindex ( l_parent_id );

        IF (NOT h_numeric_ops.EXISTS ( t_exp_templateid ( l_index ))) THEN RETURN FALSE; END IF;

        --Bug #7026587. Check the special case when the other operand of equality operator is a boolean literal.

        IF ( t_exp_templateid ( l_index ) IN ( h_templates ('equals'), h_templates ('notequals'))) THEN

           l_child := h_exprid_childrenindex ( l_parent_id );
           IF ( l_child = j ) THEN l_child := l_child + 1; END IF;

           IF ( t_exp_exprtype ( l_child ) = h_exprtypes ('literal') AND t_exp_datatype ( l_child ) = h_datatypes ('boolean')) THEN

              RETURN FALSE;

           END IF;
        END IF;

        RETURN TRUE;
     END numeric_context;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_bom_logical_context ( p_node_id IN NUMBER, p_instances IN PLS_INTEGER ) IS

        l_type      NUMBER;

     BEGIN

        l_type := h_psnid_detailedtype ( TO_CHAR ( p_node_id ));

        IF ( l_type IN ( h_psntypes ('bomoptionclass'), h_psntypes ('bomstandard'))) THEN

            apply_bom_property ('IBomDef.selected()');
            IF ( p_instances = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

        ELSIF ( l_type IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

            IF ( p_instances = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

            emit_invokevirtual ('IPortExprDef.card()');
            push_integer_constant ( 0 );
            emit_invokevirtual('INumExprDef.gt(int)');

        ELSE

            --#<should never happen>
            -- 'Type ^TYPE is not a known BOM child node type. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
            report_and_raise_rule_sys_warn(
               p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_BOM_INVAL_CHILD_TYP,
                            'TYPE', l_type ),
               p_warning_location => 'apply_bom_logical_context');

        END IF;
     END apply_bom_logical_context;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_logical_context ( p_node_id IN NUMBER, p_context_type IN PLS_INTEGER ) IS

        l_type      NUMBER;

     BEGIN

        l_type := h_psnid_detailedtype ( TO_CHAR ( p_node_id ));

        IF ( l_type IN ( h_psntypes ('bomoptionclass'), h_psntypes ('bomstandard'))) THEN

            apply_bom_property ('IBomDef.selected()');

        ELSIF ( l_type = h_psntypes ('bommodel')) THEN

            IF ( p_node_id <> p_component_id ) THEN

               --Bug #6779671. This call is required only if the property is not applied to the root bom model itself.

               emit_dup ();
               emit_invokevirtual ('IInstanceQuantifier.getType()');

            ELSE

               aload_model_def ( p_node_id );

            END IF;

            emit_invokevirtual ('IBomDef.selected()');

        ELSIF ( l_type = h_psntypes ('optionfeature')) THEN

            any_option_selected ();

        ELSIF ( l_type IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

            emit_invokevirtual ('IPortExprDef.card()');
            push_integer_constant ( 0 );
            emit_invokevirtual('INumExprDef.gt(int)');

        ELSIF ( l_type = h_psntypes ('integerfeature')) THEN

            push_integer_constant ( 0 );
            emit_invokevirtual('INumExprDef.gt(int)');

        ELSIF ( l_type = h_psntypes ('option')) THEN

            push_variable_name ( p_node_id );

            IF ( p_context_type = const_context_contributor ) THEN

               emit_invokevirtual ('ISetExprDef.elementCount(Object)');

            ELSE

               emit_invokevirtual ('ISetExprDef.contains(Object)');

            END IF;
        END IF;
     END apply_logical_context;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_numeric_context ( p_node_id IN NUMBER, p_context_type IN PLS_INTEGER ) IS

        l_node_id   VARCHAR2(4000);
        l_index     PLS_INTEGER;
        l_type      NUMBER;

     BEGIN

        l_node_id := TO_CHAR ( p_node_id );

        l_type := h_psnid_detailedtype ( l_node_id );
        l_index := h_psnid_backindex ( l_node_id );

        IF ( l_type IN ( h_psntypes ('bomoptionclass'), h_psntypes ('bomstandard'))) THEN

           apply_bom_property ('IBomDef.absQty()');

        ELSIF ( l_type = h_psntypes ('bommodel')) THEN

           IF ( p_node_id <> p_component_id ) THEN

              --Bug #6779671. This call is required only if the property is not applied to the root bom model itself.

              emit_dup ();
              emit_invokevirtual ('IInstanceQuantifier.getType()');

           ELSE

              aload_model_def ( p_node_id );

           END IF;

           emit_invokevirtual ('IBomDef.absQty()');

        ELSIF ( l_type IN ( h_psntypes ('reference'), h_psntypes ('connector'))) THEN

           emit_invokevirtual ('IPortExprDef.card()');

        ELSIF ( l_type = h_psntypes ('optionfeature')) THEN

           emit_invokevirtual ('ISetExprDef.card()');

        ELSIF ( l_type = h_psntypes ('option')) THEN

           --Solver has introduced a new method that can be used in numeric context
           --for options universally (Re: bug #6733300).

           push_variable_name ( l_node_id );
           emit_invokevirtual ('ISetExprDef.elementCount(Object)');

        END IF;
     END apply_numeric_context;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_system_property ( p_template_id IN NUMBER
                                     , p_index IN NUMBER
                                     , p_input_context IN expression_context
                                     ) IS

        l_is_bom            BOOLEAN;
        l_is_bomreference   BOOLEAN;

        l_return            NUMBER;

     BEGIN

        l_is_bom := is_bom_node ( p_index );
        l_is_bomreference := is_bom_port ( p_index );

        IF ( p_template_id = h_templates ('state')) THEN

           apply_logical_context ( t_psn_psnodeid ( p_index ), p_input_context.context_type);

        ELSIF ( h_quantities.EXISTS ( p_template_id ) OR p_template_id = h_templates ('selectioncount')) THEN

           IF ( l_is_bom or l_is_bomreference ) THEN

               IF ( t_psn_psnodetype ( p_index ) <> h_psntypes ('bommodel')) THEN

                 --This call is required only if the property is not applied to the root bom model itself.
                 --If the property cannot be applied to the root model, this condition can be removed.

                 emit_dup ();

                 IF ( l_is_bom ) THEN

                    emit_invokevirtual ('ISingletonExprDef.getType()');

                 ELSE

                    IF ( p_input_context.context_type = const_context_contributor ) THEN

                       emit_invokevirtual ( 'IPortExprDef.getType()');

                    ELSE

                       emit_invokevirtual ( 'IInstanceQuantifier.getType()');

                    END IF;
                 END IF;

               ELSE

                  aload_model_def ( t_psn_psnodeid ( p_index ));

               END IF;

               IF ( h_quantities.EXISTS ( p_template_id )) THEN

                  emit_invokevirtual ( h_quantities ( p_template_id ));

               ELSE

                  --This is selectionCount property.

                  emit_invokevirtual ('IBomDef.getOCCardSet()');
                  emit_invokevirtual ('ISetExprDef.card()');

               END IF;

           ELSE

               IF ( t_psn_detailedtype ( p_index ) = h_psntypes ('optionfeature')) THEN

                  IF ( p_template_id = h_templates ('selectioncount') AND t_psn_countedoptionsflag ( p_index ) = '1' ) THEN

                     --Property is applied to a Counted Option Feature.

                     emit_invokevirtual ('IBagExprDef.count()');

                  ELSE

                     emit_invokevirtual ('ISetExprDef.card()');

                  END IF;

               ELSIF ( t_psn_detailedtype ( p_index ) = h_psntypes ('option')) THEN

                  --This is the same code as in apply_numeric_context to an option. The procedure
                  --is not used here because it checks whether the node is bom, and this has been
                  --done already at this point.

                  push_variable_name ( TO_CHAR ( t_psn_psnodeid ( p_index )));
                  emit_invokevirtual ('ISetExprDef.elementCount(Object)');

               END IF;
           END IF;

        ELSIF ( p_template_id = h_templates ('instancecount')) THEN

           -- Property ^PROP_NAME is only applicable to nodes that can contain instances. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

           l_return := get_port_id ( TO_CHAR ( t_psn_psnodeid ( p_index )));

           IF ( l_return IS NULL ) THEN

             report_and_raise_rule_warning (
                p_text => CZ_UTILS.GET_TEXT(
                    CZ_FCE_W_PROP_ONLY_ICOMP_REF,
                    'PROP_NAME', 'InstanceCount()',
                    'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                    'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                p_warning_location => 'apply_system_property');

           END IF;

           emit_invokevirtual ('IPortExprDef.card()');

        ELSIF ( p_template_id NOT IN ( h_templates ('value')
                                     , h_templates ('integervalue')
                                     , h_templates ('decimalvalue')
                                     )) THEN

           --#<should never happen>
           -- 'Unknown property template "^TEMPLATE" found. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                    CZ_FCE_SW_UNKNOWN_TEMPLATE,
                    'TEMPLATE', p_template_id ),
                p_warning_location => 'apply_system_property' );

        END IF;

        IF ( l_is_bom AND t_psn_psnodetype ( p_index ) <> h_psntypes ('bommodel') AND p_template_id <> h_templates ('state')) THEN

           --For 'state' this call has already been done.

           emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

        END IF;
     END apply_system_property;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_system_property ( p_template_id IN NUMBER
                                        , p_node_id IN NUMBER
                                        , p_expl_id IN NUMBER
                                        , p_input_context IN expression_context
                                        , x_output_context IN OUT NOCOPY expression_context
                                        ) IS

        l_return            PLS_INTEGER;
        l_index             PLS_INTEGER;

        l_is_bom            BOOLEAN;
        l_is_bomreference   BOOLEAN;

     BEGIN

        l_index := h_psnid_backindex ( TO_CHAR ( p_node_id ));
        l_is_bom := is_bom_node ( l_index );
        l_is_bomreference := is_bom_port ( l_index );

        IF ( l_is_bomreference AND ( h_quantities.EXISTS ( TO_CHAR ( p_template_id )) OR p_template_id = h_templates ('selectioncount'))) THEN

           l_return := generate_path ( t_psn_referenceid ( l_index ), p_expl_id, p_input_context, x_output_context );

        ELSE

           l_return := generate_path ( t_psn_psnodeid ( l_index ), p_expl_id, p_input_context, x_output_context );

        END IF;

        IF ( l_return = const_quantifier_created AND ( NOT ( l_is_bom OR l_is_bomreference ))) THEN

           --If this is not a bom node and it is necessary to apply getExprFromInstance, we need to
           --do it before applying the property.

           emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

        END IF;

        apply_system_property ( p_template_id, l_index, p_input_context );

        IF ( p_input_context.context_type = const_context_contributor AND l_is_bomreference AND h_quantities.EXISTS ( TO_CHAR ( p_template_id ))) THEN

            l_return := const_resourcesum_required;

        END IF;

        IF ( l_is_bom OR l_is_bomreference ) THEN

           --For bom nodes, the result of applying property is a variable, so, if necessary, we need to call
           --getExprFromInstance on this variable.

           IF ( l_return = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

        END IF;

        IF ( l_return = const_resourcesum_required ) THEN

           emit_invokevirtual('IPortExprDef.sum(INumExprDef)');

        END IF;
     END generate_system_property;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE apply_context ( p_node_id IN NUMBER, p_instance IN PLS_INTEGER, p_input_context IN PLS_INTEGER ) IS

        l_index            PLS_INTEGER;
        l_is_bom           BOOLEAN;

     BEGIN

        l_index := h_psnid_backindex ( TO_CHAR ( p_node_id));
        l_is_bom := is_bom_node ( l_index );

        IF ( p_input_context = const_context_logical ) THEN

            apply_logical_context ( p_node_id, p_input_context );

        END IF;

     END apply_context;
     ----------------------------------------------------------------------------------
     --Nodes other than targets and contributors can be stored in local variables using
     --the following key:

     --ps_node_id-model_ref_expl_id

     --This procedure can be used to restore such nodes from the local variable. The
     --path will be regenerated if necessary. Note that if this node has an instance
     --quantifier, associated with it, the key for this quanitifer will be added to
     --the global quantifier arrays so that if this node participates in constraint,
     --correct ForAll will be generated by addConstraint call.

     --The input context is not passed to generate_path. It is only used to apply to
     --the context after path is generated.
     -- Scope: compile_constraints
     PROCEDURE aload_context_node ( p_key IN VARCHAR2, p_input_context IN PLS_INTEGER ) IS

        l_input_context    expression_context;
        l_output_context   expression_context;

        l_return           PLS_INTEGER;
        l_index            PLS_INTEGER;
        l_count            PLS_INTEGER;
        l_node_id          NUMBER;
        l_expl_id          NUMBER;

        tl_complete_path   type_number_table;
        l_key              VARCHAR2(4000);

     BEGIN

        l_node_id := TO_NUMBER ( SUBSTR ( p_key, 1, INSTR ( p_key, '-' ) - 1));
        l_expl_id := TO_NUMBER ( SUBSTR ( p_key, INSTR ( p_key, '-' ) + 1));

        IF ( NOT local_variable_defined ( p_key )) THEN

           l_return := generate_path ( l_node_id, l_expl_id, l_input_context, l_output_context );

        ELSE

           --If the variable is defined, we need to also take care of related quantifiers if any.
           --We just add them to the global quantifier arrays, the rest will be done by
           --aload_quantifier when necessary.

           aload_local_variable ( p_key );

           tl_complete_path := build_complete_path ( l_node_id, l_expl_id );
           l_count := tl_complete_path.COUNT;

           IF ( l_count > 0 ) THEN

              --Find the deepest port, this will be the instance quantifier to use in forAll.

              l_index := 2;

              --#<important>
              --Using h_psnid_detailedtype is very essential here and in the next block. If any changes are made
              --to the definition of h_psnid_detailedtype array, this code may need to change.

              WHILE ( l_index <= l_count AND h_psnid_detailedtype ( tl_complete_path ( l_index )) NOT IN
                       (h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) LOOP

                  l_index := l_index + 1;

              END LOOP;

              l_key := TO_CHAR ( tl_complete_path ( l_count ));

              FOR i IN REVERSE l_index..l_count - 1 LOOP

                 l_key := l_key || '_' || TO_CHAR ( tl_complete_path ( i ));

              END LOOP;

              IF ( l_index <= l_count ) THEN

                 IF ( NOT h_instancequantifiers.EXISTS ( l_key )) THEN

                    t_instancequantifiers ( t_instancequantifiers.COUNT + 1 ) := l_key;
                    h_instancequantifiers ( l_key ) := 1;

                 END IF;
              END IF;
           END IF;
        END IF;

        apply_context ( l_node_id, l_return, p_input_context );

     END aload_context_node;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_node ( j IN PLS_INTEGER
                             , p_input_context IN expression_context
                             , x_output_context IN OUT NOCOPY expression_context
                             ) IS

        l_return          PLS_INTEGER;
        l_node_id         NUMBER;
        l_is_bom          BOOLEAN;
        l_index           PLS_INTEGER;

     BEGIN

        l_node_id := t_exp_psnodeid ( j );
        l_index := h_psnid_backindex ( TO_CHAR ( l_node_id ));

        l_is_bom := is_bom_node ( l_index );

        l_return := generate_path ( t_exp_psnodeid ( j ), t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

        IF ( l_return = const_quantifier_created AND ( NOT l_is_bom )) THEN

           emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

        END IF;

        IF ( logical_context ( j, p_input_context.context_type )) THEN

            apply_logical_context ( l_node_id, p_input_context.context_type );

        ELSIF ( numeric_context ( j, p_input_context.context_type )) THEN

            apply_numeric_context ( l_node_id, p_input_context.context_type );

        END IF;

        IF ( l_return = const_quantifier_created AND l_is_bom ) THEN

           emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

        END IF;

        IF ( l_return = const_resourcesum_required ) THEN

            emit_invokevirtual('IPortExprDef.sum(INumExprDef)');

        END IF;
     END generate_node;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_logical_options ( j IN PLS_INTEGER
                                        , p_input_context IN expression_context
                                        , x_output_context IN OUT NOCOPY expression_context
                                        ) IS

        l_parent_id        VARCHAR2(4000);
        l_node_id          VARCHAR2(4000);
        l_expl_id          NUMBER;

        l_logic_operator   NUMBER;

        l_last_index       PLS_INTEGER;
        l_index            PLS_INTEGER;
        l_return           PLS_INTEGER;

        t_children         type_iteratornode_table;

     BEGIN

        l_parent_id := TO_CHAR ( t_exp_exprparentid ( j ));

        IF ( l_parent_id IS NULL ) THEN

              --#<should never happen>
              report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                    CZ_FCE_SW_OPTIONS_PARENT_NULL),
                p_warning_location => 'generate_logical_options' );

        END IF;

        l_node_id := TO_CHAR ( t_exp_psnodeid ( j ));
        l_expl_id := t_exp_modelrefexplid ( j );
        l_index := h_psnid_backindex ( l_node_id );

        --If this is a BOM Reference, switch to the referenced BOM Model.

        IF ( is_bom_port ( l_index )) THEN

           l_node_id := TO_CHAR ( t_psn_referenceid ( l_index ));
           l_index := h_psnid_backindex ( l_node_id );

        END IF;

        --<#temporary>
        --Options() cannot be called on a node that has no children.

        IF ( node_has_children ( l_node_id )) THEN

          l_last_index := h_psnid_lastchildindex ( l_node_id );

        ELSE

          -- Node ^NODE_NAME has no children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

          report_and_raise_rule_warning (
              p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_NODE_MUST_HAVE_CHILD,
                        'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH( l_node_id,
                          ps_node_id_table_to_string(
                                build_complete_path(l_node_id, l_expl_id))),
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path)
                        ),
              p_warning_location => 'generate_logical_options');

        END IF;

        l_return := generate_path ( l_node_id, t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

        IF ( t_psn_detailedtype ( l_index ) = h_psntypes ('optionfeature')) THEN

            l_logic_operator := t_exp_templateid ( h_exprid_backindex ( l_parent_id ));

            IF ( l_return = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

            CASE l_logic_operator

               WHEN h_templates ('anytrue') THEN

                   any_option_selected ();

               WHEN h_templates ('alltrue') THEN

                   all_options_selected ( h_psnid_numberofchildren ( l_node_id ));

               ELSE

                  -- 'Invalid parent operator "^OPERATOR" for property options(). Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                  report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_OPTIONS_PARENT_INVA,
                        'OPERATOR', l_logic_operator),
                    p_warning_location => 'generate_logical_options' );

            END CASE;

        ELSE

          --We are generating Options() on a bom node, explode its children.

          t_children := explode_bom_children ( l_node_id, t_exp_modelrefexplid ( j ), l_index + 1, l_last_index, FALSE );

          --Adjust the actual number of children of the parent operator as it may be used for generation.
          --We replace the one child with Options() applied by the number of its children.

          h_exprid_numberofchildren ( l_parent_id ) := h_exprid_numberofchildren ( l_parent_id ) + t_children.COUNT - 1;

          --Store the generated parent in a local variable. This object will be used for each child.

          IF ( h_psnid_psnodetype ( l_node_id ) <> h_psntypes ('bommodel')) THEN astore_local_variable ( 'var' ); END IF;

          --If there is an instance quantifier, it is now on top of stack. Also need to store.

          IF ( l_return = const_quantifier_created ) THEN astore_local_variable ( 'iq' ); END IF;

          FOR i IN 1..t_children.COUNT LOOP

             IF ( l_return = const_quantifier_created ) THEN aload_local_variable ( 'iq' ); END IF;

             IF ( h_psnid_psnodetype ( l_node_id ) = h_psntypes ('bommodel')) THEN

                push_variable ( t_children ( i ).ps_node_id, 'IInstanceQuantifier');

             ELSE

                aload_local_variable ( 'var' );
                push_variable ( t_children ( i ).ps_node_id, 'ISingletonExprDef');
                emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

             END IF;

             apply_bom_logical_context ( t_children ( i ).ps_node_id, l_return );

          END LOOP;
        END IF;
     END generate_logical_options;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_numeric_options ( j IN PLS_INTEGER
                                        , p_template_id IN NUMBER
                                        , p_optional_only IN BOOLEAN
                                        , p_input_context IN expression_context
                                        , x_output_context IN OUT NOCOPY expression_context
                                        ) IS

        l_template_id      NUMBER := p_template_id;

        l_parent_id        VARCHAR2(4000);
        l_node_id          VARCHAR2(4000);
        l_expl_id          NUMBER;

        l_last_index       PLS_INTEGER;
        l_index            PLS_INTEGER;
        l_return           PLS_INTEGER;

        t_children         type_iteratornode_table;

     BEGIN

        l_node_id := TO_CHAR ( t_exp_psnodeid ( j ));
        l_expl_id := t_exp_modelrefexplid ( j );
        l_index := h_psnid_backindex ( l_node_id );

        --If this is a BOM Reference, switch to the referenced BOM Model.

        IF ( is_bom_port ( l_index )) THEN

            l_node_id := TO_CHAR ( t_psn_referenceid ( l_index ));
            l_index := h_psnid_backindex ( l_node_id );

        END IF;

        --<#temporary>
        --Options() cannot be called on a node that has no children.

        IF ( node_has_children ( l_node_id )) THEN

          l_last_index := h_psnid_lastchildindex ( l_node_id );

        ELSE

           report_and_raise_rule_warning (
                p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_NODE_MUST_HAVE_CHILD,
                        'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH( l_node_id,
                          ps_node_id_table_to_string(
                                build_complete_path(l_node_id, l_expl_id) ) ),
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path)
                        ),
                p_warning_location => 'generate_numeric_options');

        END IF;

        IF ( t_psn_detailedtype ( l_index ) = h_psntypes ('optionfeature')) THEN

            l_return := generate_path ( l_node_id, t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

            IF ( l_return = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

            --Options() is applied to an option feature. Need to generate card() for both counted or
            --non-counted option feature.

            emit_invokevirtual ('ISetExprDef.card()');
            IF ( l_return = const_resourcesum_required ) THEN emit_invokevirtual('IPortExprDef.sum(INumExprDef)'); END IF;

        ELSE

          --We are generating Options() on a bom node in numeric context, default the bom property.

          IF ( l_template_id IS NULL ) THEN l_template_id := h_templates ('quantity'); END IF;
          IF ( NOT h_quantities.EXISTS ( l_template_id )) THEN
             -- 'In the numeric context invalid property applied to a BOM node. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
             report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_BOM_NUM_INVALPROP ),
                    p_warning_location => 'generate_numeric_options' );
          END IF;

          t_children := explode_bom_children ( l_node_id, t_exp_modelrefexplid ( j ), l_index + 1, l_last_index, p_optional_only );
          l_parent_id := TO_CHAR ( t_exp_exprparentid ( j ));

          --Adjust the actual number of children of the parent operator as it may be used for generation.
          --We replace the one child with Options() applied by the number of its children.

          h_exprid_numberofchildren ( l_parent_id ) := h_exprid_numberofchildren ( l_parent_id ) + t_children.COUNT - 1;

          IF ( t_children.COUNT > 2 ) THEN

             --If there are more than two chilren, we will be summing them up later, so we need
             --a model def for that. It will be used by sum_numeric procedure.

             aload_model_def ( p_component_id );

          END IF;

          l_return := generate_path ( l_node_id, t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

          --Store the generated parent in a local variable. This object will be used for each child.

          IF ( h_psnid_psnodetype ( l_node_id ) <> h_psntypes ('bommodel')) THEN astore_local_variable ( 'var' ); END IF;

          --Next on stack is either an instance quantifier, or a port that will require sum in case of
          --contributor. Also need to store.

          IF ( l_return <> const_no_instances ) THEN astore_local_variable ( 'iq' ); END IF;

          FOR i IN 1..t_children.COUNT LOOP

             IF ( l_return <> const_no_instances ) THEN aload_local_variable ( 'iq' ); END IF;

             IF ( h_psnid_psnodetype ( l_node_id ) = h_psntypes ('bommodel')) THEN

               IF ( l_return = const_quantifier_created ) THEN

                   push_variable ( t_children ( i ).ps_node_id, 'IInstanceQuantifier');

               ELSE

                   push_variable ( t_children ( i ).ps_node_id, 'IPortExprDef');

               END IF;

             ELSE

                aload_local_variable ( 'var' );
                push_variable ( t_children ( i ).ps_node_id, 'ISingletonExprDef');
                emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

             END IF;

             IF ( t_psn_psnodetype ( t_children ( i ).expr_index ) IN ( h_psntypes ('bomoptionclass'), h_psntypes ('bomstandard'))) THEN

                 apply_bom_property ( h_quantities ( l_template_id ));
                 IF ( l_return = const_resourcesum_required ) THEN emit_invokevirtual('IPortExprDef.sum(INumExprDef)'); END IF;

             ELSE

                 --This is a bom port.

                 emit_dup ();
                 emit_invokevirtual ('IPortExprDef.getType()');
                 emit_invokevirtual ( h_quantities ( l_template_id ));
                 emit_invokevirtual('IPortExprDef.sum(INumExprDef)');

             END IF;

             IF ( l_return = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

          END LOOP;

          --We need to sum up all the generated numeric expressions into a contributor term.

          sum_numeric ( t_children.COUNT );

        END IF;
     END generate_numeric_options;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_options ( j IN PLS_INTEGER
                                , p_input_context IN expression_context
                                , x_output_context IN OUT NOCOPY expression_context
                                ) IS
     BEGIN

        IF ( numeric_context ( j, p_input_context.context_type )) THEN

           generate_numeric_options ( j, NULL, FALSE, p_input_context, x_output_context );

        ELSIF ( logical_context ( j, p_input_context.context_type )) THEN

           generate_logical_options ( j, p_input_context, x_output_context );

        ELSE

           -- 'Unknown context occurred for options(). Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_UNKNOWN_CONTEXT ),
                    p_warning_location => 'generate_options' );

        END IF;
     END generate_options;
     ----------------------------------------------------------------------------------
     --This procedure should be called when the generated expression is on top of stack.
     --Does not change the state of stack.
     -- Scope: compile_constraints

     PROCEDURE set_reason_id IS

        l_id     NUMBER;
        l_text   cz_localized_texts.localized_str%TYPE;

     BEGIN

        --reason_id for constraints, for which we call this procedure, cannot be null, so
        --it should be possible to remove this condition.

        IF ( this_reason_id IS NOT NULL ) THEN

           --Bug #6899574. Need to get the persistent id of localized text record.

           SELECT persistent_intl_text_id, localized_str INTO l_id, l_text FROM cz_localized_texts
            WHERE deleted_flag = '0' AND language = USERENV ('LANG') AND intl_text_id = this_reason_id;

           comment ( 'Set rule violation message: "' || l_text || '"' );

           emit_dup ();
           push_long_constant ( l_id );
           emit_invokevirtual('IExprDef.setId(long)');

           --Remove the null object from stack after a void method.

           emit_pop ( 1 );

        END IF;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN

          report_and_raise_rule_sys_warn ( p_text => CZ_FCE_SW_NO_INTL_TEXT, p_warning_location => 'set_reason_id' );

     END set_reason_id;
     ----------------------------------------------------------------------------------
     --This procedure should be called when the generated expression is on top of stack.
     --Does not change the state of stack.
    -- Scope: compile_constraints
     PROCEDURE add_constraint IS

        l_method   VARCHAR2(4000);

     BEGIN

        emit_effectivity ( 'ILogicExprDef', this_effective_from, this_effective_until, this_effective_usages );

        l_method := 'IModelDef.add' || CASE NVL ( this_rule_class, h_ruleclasses ('constraint'))
               WHEN h_ruleclasses ('constraint') THEN 'Constraint'
               WHEN h_ruleclasses ('default') THEN 'DefaultDecision'
               WHEN h_ruleclasses ('search') THEN 'SearchDecision' END;

        --Finish generation of the constraint and add it to the model def.

        IF ( t_instancequantifiers.COUNT > 0 ) THEN

          --There were instance quantifiers generated, so we need a ForAll and an extra root model
          --def to call ForAll on. But first we need to store the generated expression, which then
          --will be passed as the last argument to ForAll.

          --Store the generated expression in a local variable. May be, a new instruction would be
          --better, something about storing in a register. We can use aload_local_variable here as
          --there is no way this local variable will be replaced with something else while we load
          --quantifiers.

          --Note, that if forAll method had ILogicExprDef as the first parameter we'd just need to
          --swap it with the model def.

          astore_local_variable ( 'exp' );
          aload_model_def ( p_component_id );

          FOR i IN 1..t_instancequantifiers.COUNT LOOP

             aload_quantifier ( t_instancequantifiers ( i ));

          END LOOP;

          CASE t_instancequantifiers.COUNT

             WHEN 1 THEN

                aload_local_variable ( 'exp' );
                emit_invokevirtual('IModelDef.forAll(IInstanceQuantifier, ILogicExprDef)');

             WHEN 2 THEN

                aload_local_variable ( 'exp' );
                emit_invokevirtual('IModelDef.forAll(IInstanceQuantifier, IInstanceQuantifier, ILogicExprDef)');

             ELSE

                create_array ( t_instancequantifiers.COUNT, h_javatypes ('IInstanceQuantifier'));
                populate_array ( t_instancequantifiers.COUNT );
                aload_local_variable ( 'exp' );
                emit_invokevirtual('IModelDef.forAll(IInstanceQuantifier[], ILogicExprDef)');

          END CASE;

          emit_invokevirtual( l_method || '(IForAllDef)');

        ELSE

          emit_invokevirtual( l_method || '(ILogicExprDef)');

        END IF;

        --Remove the null object from stack after a void method.

        emit_pop ( 1 );

     END add_constraint;
     ----------------------------------------------------------------------------------
         -- Scope: compile_constraints
     FUNCTION push_numeric_literal ( p_value IN NUMBER ) RETURN PLS_INTEGER IS
     BEGIN

        IF ( ROUND ( p_value ) = p_value ) THEN

           push_integer_constant ( p_value );
           RETURN h_datatypes ('integer');

        ELSE

           push_decimal_constant ( p_value );
           RETURN h_datatypes ('decimal');

        END IF;
     END push_numeric_literal;
     ----------------------------------------------------------------------------------
         -- Scope: compile_constraints
     FUNCTION get_literal_value ( j IN PLS_INTEGER ) RETURN VARCHAR2 IS

        l_val   NUMBER;

     BEGIN

       IF ( t_exp_datatype ( j ) IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

          RETURN TO_CHAR ( t_exp_datanumvalue ( j ));

       ELSIF ( t_exp_datatype ( j ) IN ( h_datatypes ('boolean'), h_datatypes ('text'))) THEN

          RETURN t_exp_datavalue ( j );

       ELSIF ( t_exp_datatype ( j ) IS NULL ) THEN

          --#<temporary>
          --Developer does not populate data_type for constants in simple comparison rules.
          --Such constants can only be numeric, but the value is in data_value column.
          --It would be more consistent to have data_type column always populated for
          --literals and throw an inconsistency exception here.

          l_val := TO_NUMBER ( NVL ( t_exp_datanumvalue ( j ), t_exp_datavalue ( j )));

          --Need to populate data_type properly, because it is used to select the best signature.

          t_exp_datatype ( j ) := CASE ROUND ( l_val ) WHEN l_val THEN h_datatypes ('integer') ELSE h_datatypes ('decimal') END;
          RETURN l_val;

       ELSE

          --#<should never happen>
          -- 'Invalid literal data type "^TYPE" found for the expression with the id ^EXPR_ID. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
          report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVALID_LIT_DTYPE,
                        'TYPE', t_exp_datatype ( j ),
                        'EXPR_ID', t_exp_exprnodeid ( j )),
                    p_warning_location => 'get_literal_value' );
          RETURN NULL;

       END IF;
     END get_literal_value;
     ----------------------------------------------------------------------------------
         -- Scope: compile_constraints
     PROCEDURE push_constant_expr ( p_value IN VARCHAR2, p_data_type IN NUMBER ) IS
     BEGIN

       IF ( p_data_type NOT IN ( h_datatypes ('integer'), h_datatypes ('decimal'), h_datatypes ('boolean'))) THEN

          --#<should never happen>
          -- 'Invalid constant data type "^TYPE" found. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
          report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVAL_CONST_DTYPE,
                        'TYPE', p_data_type),
                    p_warning_location => 'push_constant_expr' );

       END IF;

       IF ( p_value IS NULL ) THEN
           -- 'Null constant value occurred. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_NULL_CONSTANT_VALUE),
                    p_warning_location => 'push_constant_expr' );

       END IF;

       aload_model_def ( p_component_id );

       CASE p_data_type

         WHEN h_datatypes('integer') THEN

            push_integer_constant ( TO_NUMBER ( p_value ));
            emit_invokevirtual('IModelDef.literal(int)');

         WHEN h_datatypes('decimal') THEN

            push_decimal_constant ( TO_NUMBER ( p_value ));
            emit_invokevirtual('IModelDef.literal(double)');

         WHEN h_datatypes('boolean') THEN

            emit_boolean ( p_value );
            emit_invokevirtual('IModelDef.literal(boolean)');

       END CASE;

     EXCEPTION
        WHEN INVALID_NUMBER THEN

             --#<should never happen>
             -- 'Invalid number "^VALUE" found. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
             report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVALID_NUMBER,
                        'VALUE', p_value ),
                  p_warning_location => 'push_constant_expr:' || DBMS_UTILITY.FORMAT_ERROR_STACK ||
                  '\nBack Trace:' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

     END push_constant_expr;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE push_constant ( p_value IN VARCHAR2, p_data_type IN NUMBER ) IS
     BEGIN

       IF ( p_value IS NULL ) THEN
           -- 'Null constant value occurred. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_NULL_CONSTANT_VALUE),
                    p_warning_location => 'push_constant_expr' );


       END IF;

       CASE p_data_type

         WHEN h_datatypes ('integer') THEN

            push_integer_constant ( TO_NUMBER ( p_value ));

         WHEN h_datatypes ('decimal') THEN

            push_decimal_constant ( TO_NUMBER ( p_value ));

         WHEN h_datatypes ('boolean') THEN

            emit_boolean ( p_value );

         WHEN h_datatypes ('text') THEN

            push_string_constant ( p_value );

         ELSE

             --#<should never happen>
             -- 'Invalid constant data type "^TYPE" found. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
             report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INVAL_CONST_DTYPE ),
                p_warning_location => 'push_constant' );

       END CASE;

     EXCEPTION
        WHEN INVALID_NUMBER THEN

             --#<should never happen>
             -- 'Invalid number "^VALUE" found. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
             report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVALID_NUMBER,
                        'VALUE', p_value ),
                  p_warning_location => 'push_constant:' || DBMS_UTILITY.FORMAT_ERROR_STACK ||
                  '\nBack Trace:' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

     END push_constant;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_constant ( j IN PLS_INTEGER ) IS

        l_template_id   NUMBER := t_exp_templateid ( j );

     BEGIN

        IF ( l_template_id NOT IN ( h_mathconstants ('e'), h_mathconstants ('pi'))) THEN
           -- 'Mathematical operator is not implemented for template_id "^TEMPL_ID". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
              p_text => GET_NOT_TRANSLATED_TEXT(
                    CZ_FCE_SW__NO_MATH_CONST,
                    'TEMPL_ID', l_template_id ),
              p_warning_location => 'generate_constant' );
        END IF;

        emit_constant ( l_template_id );

     END generate_constant;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_literal ( j                IN PLS_INTEGER
                                , p_value          IN VARCHAR2
                                , p_data_type      IN NUMBER
                                , p_input_context  IN expression_context
                                , x_output_context IN OUT NOCOPY expression_context ) IS

        l_expr_id       VARCHAR2(4000);
        l_index         PLS_INTEGER;
        l_count         PLS_INTEGER;

        l_template_id   NUMBER;

     BEGIN

       IF ( p_input_context.context_type = const_context_selection ) THEN

          --This literal partitipates in an expression involving Selection() with a text
          --property. We just need to populate data structures that will be used in the
          --Selection() generation.

         l_count := s_.COUNT + 1;

         s_( l_count ) := 1;
         o_( l_count )( 1 ) := NULL; --this value is not used.
         t_( l_count )( 1 )( 1 ) := p_value;

         RETURN;

       END IF;

       IF ( t_exp_exprparentid ( j ) IS NULL ) THEN

          push_constant_expr ( p_value, p_data_type );
          RETURN;

       END IF;

       l_expr_id := TO_CHAR ( t_exp_exprparentid ( j ));
       l_index := h_exprid_backindex ( l_expr_id );

       l_template_id := t_exp_templateid ( l_index );

       IF ( p_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

         IF ( TO_NUMBER ( p_value ) = 1 AND l_template_id IN ( h_templates ('multiply'), h_templates ('div'))) THEN

             --#<optimization>
             --The literal is an operand to mutliplication or division, and its value is 1.

             x_output_context.context_type := const_context_literal;
             RETURN;

         END IF;
       END IF;

       --#<optimization>
       --We need to convert the literal to expression if
       --  it is the first operand of an operator;
       --  it is the only operand;
       --  it is any operand of 'array' operators.
       --These are not exact conditions and can be enhanced.

       IF ( t_exp_seqnbr ( j ) = 1 OR
            h_exprid_numberofchildren ( l_expr_id ) = 1 OR
            h_operators_3.EXISTS ( l_template_id )
          ) THEN

           push_constant_expr ( p_value, p_data_type );

       ELSE

           push_constant ( p_value, p_data_type );
           x_output_context.context_type := const_context_constant;

       END IF;
     END generate_literal;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE invoke_operator2 ( p_template_id IN PLS_INTEGER, p_rhs_index IN PLS_INTEGER, p_input_context IN expression_context ) IS
     BEGIN

        IF ( p_input_context.context_type = const_context_constant OR t_exp_exprtype ( p_rhs_index ) = h_exprtypes ('literal')) THEN

           --The RHS operand is a literal or has been evaluated to a literal.
           --Select the best signature for the method to call.

           IF ( t_exp_datatype ( p_rhs_index ) = h_datatypes ('integer')) THEN

              emit_invokevirtual ( h_operators_2_int ( p_template_id ));

           ELSIF ( t_exp_datatype ( p_rhs_index ) = h_datatypes ('decimal')) THEN

              emit_invokevirtual ( h_operators_2_double ( p_template_id ));

           ELSIF ( t_exp_datatype ( p_rhs_index ) = h_datatypes ('boolean')) THEN

              emit_invokevirtual ( h_operators_2_boolean ( p_template_id ));

           ELSE

              emit_invokevirtual ( h_operators_2 ( p_template_id ));

           END IF;

        ELSE

           emit_invokevirtual ( h_operators_2 ( p_template_id ));

        END IF;
     END invoke_operator2;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE invoke_operator3 ( p_template_id IN PLS_INTEGER, p_count IN PLS_INTEGER, p_type IN VARCHAR2 ) IS
     BEGIN

        --Parameters are on stack, create the array.

        create_array ( p_count, h_javatypes ( p_type ));
        populate_array ( p_count );

        --To call the method, we need a model def. We have to push it now and swap with
        --the array of parameters. We could not push the model def before generation of
        --parameters, for example: AnyTrue(F.Options()) - only when we generate Options
        --we will have the correct number of children of AnyTrue.

        aload_model_def ( p_component_id );
        emit_swap ();
        emit_invokevirtual ( h_operators_3 ( p_template_id ));

     END invoke_operator3;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE invoke_anyalltrue ( p_template_id IN PLS_INTEGER, p_count IN PLS_INTEGER, p_parent_id IN NUMBER DEFAULT 0 ) IS
     BEGIN

        --#<optimization>
        --If there is only one actual operand, we don't need to do anything.

        --Bug #6979696. Default and Search decision can have this operator on the root
        --level, in which case we need to apply it because we need to call addDecision
        --on the result. In many cases when we call this procedure we know it is not a
        --decision, so we don't have to specify the p_parent_id.

        IF ( p_count < 2 AND p_parent_id IS NOT NULL ) THEN RETURN; END IF;

        IF ( p_count = 2 ) THEN

           --If there are two parameters, use Or/And instead.

           emit_invokevirtual ( h_operators_3_opt ( p_template_id ));

        ELSE

           invoke_operator3 ( p_template_id, p_count, 'ILogicExprDef' );

        END IF;
     END invoke_anyalltrue;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_property_id ( j IN PLS_INTEGER ) RETURN NUMBER IS

        l_type   PLS_INTEGER;

     BEGIN

        IF ( t_exp_exprtype ( j ) IN ( h_exprtypes ('property'), h_exprtypes ('literal'))) THEN

           h_propertyid_type ( TO_CHAR ( t_exp_propertyid ( j ))) := h_exprtypes ('property');
           RETURN t_exp_propertyid ( j );

        ELSIF ( t_exp_exprtype ( j ) = h_exprtypes ('systemproperty')) THEN

           h_propertyid_type ( TO_CHAR ( t_exp_templateid ( j ))) := h_exprtypes ('systemproperty');
           RETURN t_exp_templateid ( j );

        ELSIF ( t_exp_exprtype ( j ) = h_exprtypes ('argument')) THEN

           --In case of statement ForAll rule, iterator can participate in the where clause without
           --any property applied. We emulate this as non-existant system property with property_id
           --and data_type equal to the data type of the context.

           l_type := get_context_type ( j );

           h_propertyid_type ( TO_CHAR ( l_type )) := h_exprtypes ('systemproperty');
           RETURN l_type;

        ELSE
           -- 'No property id found for the expression id "^EXPR_ID". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_NO_PROP_ID_EXPR_ID,
                        'EXPR_ID', TO_CHAR ( t_exp_exprnodeid ( j )) ),
                p_warning_location => 'get_property_id');
           RETURN NULL;

        END IF;
     END get_property_id;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_property_type ( p_property_id IN NUMBER ) RETURN PLS_INTEGER IS

        l_property_id   VARCHAR2(4000) := TO_CHAR ( p_property_id );

     BEGIN

        IF ( NOT h_propertyid_type.EXISTS ( l_property_id )) THEN
           -- 'No property type found for the property id "^PROP_ID". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_NO_TYPE_FOR_PROP_ID,
                        'PROP_ID', l_property_id ),
                p_warning_location => 'get_property_type');

        END IF;

        RETURN h_propertyid_type ( l_property_id );
     END get_property_type;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE get_static_info ( p_property_id  IN NUMBER
                               , x_data_type    IN OUT NOCOPY NUMBER
                               ) IS

        l_property_id   VARCHAR2(4000);

     BEGIN

        l_property_id := TO_CHAR ( p_property_id );

        IF ( h_propertyid_datatype.EXISTS ( l_property_id )) THEN

            x_data_type := h_propertyid_datatype ( l_property_id );

        ELSE

           IF ( p_property_id = h_templates ('name')) THEN

              x_data_type := h_datatypes('text');

           ELSIF ( p_property_id IN ( h_templates ('minvalue')
                                    , h_templates ('maxvalue')
                                    , h_templates ('minquantity')
                                    , h_templates ('maxquantity')
                                    , h_templates ('minselected')
                                    , h_templates ('maxselected')
                                    )
                 ) THEN

              x_data_type := h_datatypes ('decimal');

           ELSIF ( p_property_id IN ( h_datatypes ('decimal')
                                    , h_datatypes ('boolean')
                                    , h_datatypes ('text')
                                    )
                 ) THEN

              --Case of iterator without any properties in the where clause of a statement ForAll.

              x_data_type := p_property_id;

           ELSIF ( p_property_id = h_templates ('description')) THEN
              -- System Property ^PROP_NAME is invalid in WHERE clause of a COMPATIBLE or FORALL operator because it is translatable. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
              report_and_raise_rule_warning(
                CZ_UTILS.GET_TEXT(CZ_FCE_W_DESCRIPTION_IN_WHERE,
                  'PROP_NAME','description',
                  'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                  'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                'get_static_info'
               );

           ELSE

              -- System Property ^PROPERTY_NAME is invalid in WHERE clause of
              -- COMPATIBLE or FORALL operator because its value is not static at runtime.
              -- Rule "^RULE_NAME" in the Model "^MODEL_NAME" ignored.'

              report_and_raise_rule_warning(
                CZ_UTILS.GET_TEXT(CZ_FCE_W_PROPERTY_NOT_STATIC,
                  'PROPERTY_NAME',CZ_FCE_COMPILE_UTILS.GET_PROPERTY_PATH(p_property_id),
                  'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                  'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                'get_static_info'
               );

           END IF;

           h_propertyid_datatype ( l_property_id ) := x_data_type;

        END IF;
     END get_static_info;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_static_value ( p_property_id  IN NUMBER
                               , p_node_id      IN NUMBER
                               )
     RETURN VARCHAR2 IS

        l_key           VARCHAR2(4000);
        l_node_id       VARCHAR2(4000);
        l_property_id   VARCHAR2(4000);

        l_value         VARCHAR2(4000);
        l_index         PLS_INTEGER;

     BEGIN

       l_node_id := TO_CHAR ( p_node_id );
       l_property_id := TO_CHAR ( p_property_id );

       l_key := l_node_id || '-' || l_property_id;

       IF ( h_psnid_propertyid_value.EXISTS ( l_key )) THEN

           RETURN h_psnid_propertyid_value ( l_key );

       END IF;

       l_index := h_psnid_backindex ( l_node_id );

       IF ( p_property_id = h_templates ('name')) THEN

           l_value := t_psn_name ( l_index );

       ELSIF ( p_property_id IN ( h_templates ('minvalue')
                                , h_templates ('minquantity')
                                , h_templates ('minselected')
                                )
               ) THEN

           l_value := t_psn_minimum ( l_index );

       ELSIF ( p_property_id IN ( h_templates ('maxvalue')
                                , h_templates ('maxquantity')
                                , h_templates ('maxselected')
                                )
              ) THEN

           l_value := t_psn_maximum ( l_index );

       ELSE
          -- 'Property with the template id "^PROP_ID" is not static. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
          report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_NOT_STATIC_PROPERTY,
                        'PROP_ID', l_property_id ),
                p_warning_location => 'get_static_value');
       END IF;

       h_psnid_propertyid_value ( l_key ) := l_value;
       RETURN l_value;

     END get_static_value;
     ----------------------------------------------------------------------------------
     PROCEDURE get_user_info ( p_property_id  IN NUMBER
                             , x_data_type    IN OUT NOCOPY NUMBER
                             , x_def_value    IN OUT NOCOPY VARCHAR2
                             ) IS

        l_property_id   VARCHAR2(4000);

     BEGIN

        l_property_id := TO_CHAR ( p_property_id );

        IF ( h_propertyid_datatype.EXISTS ( l_property_id )) THEN

            x_data_type := h_propertyid_datatype ( l_property_id );
            x_def_value := h_propertyid_defvalue ( l_property_id );

        ELSE

            SELECT NVL( TO_CHAR ( def_num_value ), def_value ), data_type INTO x_def_value, x_data_type
              FROM cz_properties
             WHERE property_id = p_property_id
               AND deleted_flag = '0';

            h_propertyid_datatype ( l_property_id ) := x_data_type;
            h_propertyid_defvalue ( l_property_id ) := x_def_value;

        END IF;
     END get_user_info;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_user_value ( p_property_id  IN NUMBER
                             , p_node_id      IN NUMBER
                             , p_expl_id      IN NUMBER
                             , p_item_id      IN NUMBER
                             )
     RETURN VARCHAR2 IS

        l_def_value     VARCHAR2(4000);
        l_data_type     NUMBER;
        l_key           VARCHAR2(4000);
        l_tab           type_varchar4000_table;

        l_node_id       VARCHAR2(4000);
        l_property_id   VARCHAR2(4000);

     BEGIN

       l_node_id := TO_CHAR ( p_node_id );
       l_property_id := TO_CHAR ( p_property_id );

       --#<temporary>
       --This key works well enough for properties, attached to structure nodes directly.
       --However, for properties attached through items it can result in excessive
       --quering as different ps nodes can have the same item id and hence the same
       --property value.

       l_key := l_node_id || '-'  || l_property_id;

       IF ( h_psnid_propertyid_value.EXISTS ( l_key )) THEN

           RETURN h_psnid_propertyid_value ( l_key );

       END IF;

       IF ( h_propertyid_defvalue.EXISTS ( l_property_id )) THEN

           l_def_value := h_propertyid_defvalue ( l_property_id );

       ELSE

           get_user_info ( p_property_id, l_data_type, l_def_value );

       END IF;

       SELECT NVL ( TO_CHAR( data_num_value ), data_value ) BULK COLLECT INTO l_tab
         FROM cz_ps_prop_vals
        WHERE ps_node_id = p_node_id
          AND property_id = p_property_id
          AND deleted_flag = '0';

       IF ( l_tab.COUNT = 0 AND p_item_id IS NOT NULL ) THEN

           SELECT NVL( TO_CHAR ( property_num_value ), property_value ) BULK COLLECT INTO l_tab
             FROM cz_item_property_values
            WHERE property_id = p_property_id
              AND item_id = p_item_id
              AND deleted_flag = '0';

           IF ( l_tab.COUNT = 0 )THEN

               SELECT NULL BULK COLLECT INTO l_tab
                 FROM cz_item_type_properties t, cz_item_masters m
                WHERE m.item_id = p_item_id
                  AND m.deleted_flag = '0'
                  AND t.deleted_flag = '0'
                  AND t.property_id = p_property_id
                  AND t.item_type_id = m.item_type_id;

           END IF;
       END IF;

       IF ( l_tab.COUNT = 0 ) THEN
           -- Property ^PROP_NAME is not defined for node ^NODE_NAME.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_NO_PROPERTY_FOR_NODE,
                    'PROP_NAME', CZ_FCE_COMPILE_UTILS.GET_PROPERTY_PATH(l_property_id),
                    'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH(p_node_id,
                                  ps_node_id_table_to_string(
                                    build_complete_path(p_node_id, p_expl_id) ) ),
                    'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                    'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'get_user_value');
       END IF;

       h_psnid_propertyid_value ( l_key ) := NVL ( l_tab ( 1 ), l_def_value );

       IF ( h_psnid_propertyid_value ( l_key ) IS NULL ) THEN
            -- 'Property ^PROP_NAME has no value for node ^NODE_NAME. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_PROPERTY_NULL_VALUE,
                    'PROP_NAME', CZ_FCE_COMPILE_UTILS.GET_PROPERTY_PATH(l_property_id),
                    'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH(p_node_id,
                                  ps_node_id_table_to_string(
                                    build_complete_path(p_node_id, p_expl_id) ) ),
                    'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                    'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'get_user_value');

       END IF;

       RETURN h_psnid_propertyid_value ( l_key );

     END get_user_value;
     ----------------------------------------------------------------------------------
     PROCEDURE get_property_info ( p_property_id   IN NUMBER
                                 , x_data_type     IN OUT NOCOPY NUMBER
                                 , x_def_value     IN OUT NOCOPY VARCHAR2
                                 ) IS
     BEGIN

        IF ( get_property_type ( p_property_id ) = h_exprtypes ('property')) THEN

           get_user_info ( p_property_id, x_data_type, x_def_value );

        ELSE

           get_static_info ( p_property_id, x_data_type );

        END IF;
     END get_property_info;
     ----------------------------------------------------------------------------------
     FUNCTION get_property_value ( p_property_id   IN NUMBER
                                 , p_node_id       IN NUMBER
                                 , p_expl_id       IN NUMBER
                                 )
     RETURN VARCHAR2 IS
     BEGIN

        IF ( get_property_type ( p_property_id ) = h_exprtypes ('property')) THEN

           RETURN get_user_value ( p_property_id, p_node_id, p_expl_id, t_psn_itemid ( h_psnid_backindex ( TO_CHAR ( p_node_id ))));

        ELSE

           RETURN get_static_value ( p_property_id, p_node_id );

        END IF;
     END get_property_value;
     ----------------------------------------------------------------------------------
     --For operators with one operand (totext, not, neg), p_left_operand is used.
     -- Scope: compile_constraints
     FUNCTION parse_operator ( p_left_operand   IN VARCHAR2
                             , p_operator       IN PLS_INTEGER
                             , p_right_operand  IN VARCHAR2
                             ) RETURN VARCHAR2 IS
     BEGIN

        IF ( p_operator IN
                ( h_templates ('and')
                , h_templates ('or')
                , h_templates ('equals')
                , h_templates ('notequals')
                , h_templates ('gt')
                , h_templates ('lt')
                , h_templates ('ge')
                , h_templates ('le')
                , h_templates ('add')
                , h_templates ('subtract')
                , h_templates ('multiply')
                , h_templates ('div')
                , h_templates('textequals')
                , h_templates('textnotequals')
                )) THEN

           RETURN '(' || p_left_operand || h_template_tokens ( p_operator ) || p_right_operand || ')';

        ELSIF ( p_operator IN
                  ( h_templates ('totext')
                  , h_templates ('not')
                  , h_templates ('neg')
                  )) THEN

           RETURN '(' || h_template_tokens ( p_operator ) || '(' || p_left_operand || '))';

        ELSIF ( p_operator = h_templates ('doesnotbeginwith')) THEN

           RETURN '(' || p_left_operand || ' NOT LIKE ' || p_right_operand || '||''%'')';

        ELSIF ( p_operator = h_templates ('doesnotendwith')) THEN

           RETURN '(' || p_left_operand || ' NOT LIKE ''%''||' || p_right_operand || ')';

        ELSIF ( p_operator = h_templates ('doesnotcontain')) THEN

           RETURN '(' || p_left_operand || ' NOT LIKE ''%''||' || p_right_operand || '||''%'')';

        ELSIF ( p_operator = h_templates ('notlike')) THEN

           RETURN '(' || p_left_operand || ' NOT LIKE ' || p_right_operand || ')';

        ELSIF ( p_operator = h_templates ('concatenate')) THEN

           RETURN p_left_operand || '||' || p_right_operand;

        ELSIF ( p_operator = h_templates ('beginswith')) THEN

           RETURN '(' || p_left_operand || ' LIKE ' || p_right_operand || '||''%'')';

        ELSIF ( p_operator = h_templates ('endswith')) THEN

           RETURN '(' || p_left_operand || ' LIKE ''%''||' || p_right_operand || ')';

        ELSIF ( p_operator = h_templates ('contains')) THEN

           RETURN '(' || p_left_operand || ' LIKE ''%''||' || p_right_operand || '||''%'')';

        ELSIF ( p_operator = h_templates ('like')) THEN

           RETURN '(' || p_left_operand || ' LIKE ' || p_right_operand || ')';

        ELSIF ( p_operator = h_templates ('matches')) THEN

           RETURN '(' || p_left_operand || ' LIKE ' || p_right_operand || ')';

        END IF;
     END parse_operator;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION build_executable ( p_count IN PLS_INTEGER, p_parsed IN VARCHAR2 ) RETURN VARCHAR2 IS

        l_open         VARCHAR2(32000);
        l_body         VARCHAR2(32000);
        l_close        VARCHAR2(32000);

        l_value        VARCHAR2(4000);

     BEGIN

        FOR i IN 1..p_count LOOP

           l_value := TO_CHAR ( i );

           l_open := l_open || ' FOR i' || l_value || ' IN 1..cz_fce_compile.s_(' || l_value || ') LOOP';
           l_body := l_body || ' cz_fce_compile.c_.combinations(l)(' || l_value || '):=cz_fce_compile.o_(' || l_value || ')(i' || l_value || ');';
           l_close := l_close || 'END LOOP;';

        END LOOP;

        --Example of an executable block that will be constructed for the following WHERE clause
        --(passed in p_condition).

        --#<optimization> See bug #6531346 for possible optimization.

        --WHERE #x.Property("p1") = #y.Property("p2")
        --  AND #x.Property("p1") = #z.Property("p2")
        --  AND #z.Name() BEGINSWITH "abc"
        --  AND #x.Property("p3") = TRUE
        --  AND (2 = 2)

        --Resulting code (note that parser has rewritten (2 = 2) as TRUE):

        --DECLARE
        --  l PLS_INTEGER:=1;
        --BEGIN
        --  FOR i1 IN 1..cz_fce_compile.s_(1) LOOP
        --  FOR i2 IN 1..cz_fce_compile.s_(2) LOOP
        --  FOR i3 IN 1..cz_fce_compile.s_(3) LOOP
        --     IF((cz_fce_compile.n_(1)(i1)(1)=cz_fce_compile.n_(2)(i2)(2))AND
        --        (cz_fce_compile.n_(1)(i1)(1)=cz_fce_compile.n_(3)(i3)(2))AND
        --        (cz_fce_compile.t_(3)(i3)(3) LIKE 'abc%')AND
        --        (cz_fce_compile.b_(1)(i1)(4)=1)AND(TRUE))THEN
        --           cz_fce_compile.c_.combinations(l)(1):=cz_fce_compile.o_(1)(i1);
        --           cz_fce_compile.c_.combinations(l)(2):=cz_fce_compile.o_(2)(i2);
        --           cz_fce_compile.c_.combinations(l)(3):=cz_fce_compile.o_(3)(i3);
        --           l := l + 1;
        --     END IF;
        --  END LOOP;
        --  END LOOP;
        --  END LOOP;
        --END;

        RETURN 'DECLARE l PLS_INTEGER:=1;BEGIN'
               || l_open ||
               ' IF(' || NVL ( p_parsed, 'TRUE' ) || ')THEN'
               || l_body ||
               'l:=l+1;END IF;'
               || l_close ||
              'END;';
     END;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_user_property ( j IN PLS_INTEGER
                                      , p_input_context IN expression_context
                                      , x_output_context IN OUT NOCOPY expression_context ) IS

        l_property_id     NUMBER;
        l_data_type       NUMBER;
        l_def_value       VARCHAR2(4000);
        l_value           VARCHAR2(4000);
        l_expr_id         VARCHAR2(4000);
        l_index           PLS_INTEGER;

        l_input_context   expression_context;

     BEGIN

        l_property_id := t_exp_propertyid ( h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( j ))));
        get_user_info ( l_property_id, l_data_type, l_def_value );

        l_value := get_user_value ( l_property_id
                                  , t_exp_psnodeid ( j )
                                  , t_exp_modelrefexplid ( j )
                                  , t_psn_itemid ( h_psnid_backindex ( TO_CHAR ( t_exp_psnodeid ( j ))))
                                  );

        IF ( l_data_type = h_datatypes('text')) THEN

            IF ( numeric_context ( j, p_input_context.context_type )) THEN

               --This property is used as a numeric property but has data type 'text', for example,
               --bom properties imported without data type resolution. In this case, all values of
               --this property are assumed to be convertible to numbers. If this is not true, this
               --will cause problems later in push_constant_expr where will be actually converted.

               --We can add the check for number here, and also see if it is decimal or integer for
               --better resolution of data type.

               l_data_type := h_datatypes ('decimal');

            ELSE

               --#<should never happen>
               -- 'Found property with the id "^PROP_ID" as text property. Rules cannot handle text properties. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
               report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_NO_TEXT_PROP,
                        'PROP_ID', l_property_id ),
                p_warning_location => 'generate_user_property');

            END IF;
        END IF;

        --#<problem>
        --Note that the input context of this procedure is not passed down to generate_literal.
        --The local context variable is not used in any other way, so it seems that it's been
        --created specifically for this purpose. Not sure if this was done intentionally, need
        --to keep an eye on it.

        generate_literal ( j, l_value, l_data_type, l_input_context, x_output_context );

     END generate_user_property;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_selection_property ( j IN PLS_INTEGER
                                           , p_property_id IN NUMBER
                                           , p_input_context IN expression_context
                                           , x_output_context IN OUT NOCOPY expression_context
                                           ) IS

        l_return            PLS_INTEGER;
        l_index             PLS_INTEGER;

        l_is_bom            BOOLEAN;

     BEGIN

        IF ( h_quantities.EXISTS ( p_property_id )) THEN

           generate_numeric_options ( j, p_property_id, TRUE, p_input_context, x_output_context );
           RETURN;

        END IF;

        l_index := h_psnid_backindex ( TO_CHAR ( t_exp_psnodeid ( j )));
        l_is_bom := is_bom_node ( l_index );

        l_return := generate_path ( t_exp_psnodeid ( j ), t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

        IF ( l_return = const_quantifier_created ) THEN

           emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

        END IF;

        --This procedure is called in generate_selection only when the property applied
        --to selection, is one of Quantity(), State() or Value(). In case of Value() we
        --just generate the node, which is already done above. So, here we only have to
        --generate State().

        IF ( l_is_bom ) THEN

           apply_bom_property ('IBomDef.getOCCardSet()');

        END IF;

        IF ( p_property_id = h_templates ('state')) THEN

           any_option_selected ();

        END IF;

        IF ( l_return = const_resourcesum_required ) THEN

           emit_invokevirtual('IPortExprDef.sum(INumExprDef)');

        END IF;
     END generate_selection_property;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_selection_object ( p_node_id          IN NUMBER
                                         , p_expl_id          IN NUMBER
                                         , p_data_type        IN NUMBER
                                         , p_property_values  IN type_numbertable_hashtable
                                         , p_input_context    IN expression_context
                                         , x_output_context   IN OUT NOCOPY expression_context
                                         ) IS

        l_return   PLS_INTEGER;
        l_count    PLS_INTEGER;
        l_value    VARCHAR2(4000);

     BEGIN

        IF ( p_property_values.COUNT > 2 ) THEN

           --If there are more than two distinct property values, we will call 'sum' later,
           --and need model def for that.

           aload_model_def ( p_component_id );

        END IF;

        l_return := generate_path ( p_node_id, p_expl_id, p_input_context, x_output_context );

        IF ( h_psnid_detailedtype ( TO_CHAR ( p_node_id )) = h_psntypes ('optionfeature')) THEN

          IF ( l_return = const_quantifier_created ) THEN emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)'); END IF;

          astore_local_variable ( 'var' );

          l_value := p_property_values.FIRST;

          WHILE ( l_value IS NOT NULL ) LOOP

             l_count := p_property_values ( l_value ).COUNT;
             aload_local_variable ( 'var' );

             FOR i IN 1..l_count LOOP

                push_variable_name ( p_property_values ( l_value )( i ));

             END LOOP;

             IF ( l_count = 1 ) THEN

                --Just one option, generate 'contains' instead of 'intersects'.

                emit_invokevirtual ('ISetExprDef.contains(Object)');

             ELSE

                create_array ( l_count, h_javatypes ('Object'));
                populate_array ( l_count );
                emit_invokevirtual ('ISetExprDef.intersects(Object[])');

             END IF;

             --If the property value is 1, there is no need to multiply.

             IF ( TO_NUMBER ( l_value ) <> 1 ) THEN

                push_decimal_constant ( TO_NUMBER ( l_value ));
                emit_invokevirtual ( CASE p_data_type WHEN h_datatypes ('decimal') THEN 'INumExprDef.prod(double)' ELSE 'INumExprDef.prod(int)' END );

             END IF;

             l_value := p_property_values.NEXT ( l_value );

          END LOOP;

        ELSIF ( h_psnid_detailedtype ( TO_CHAR ( p_node_id )) = h_psntypes ('bomoptionclass')) THEN

          astore_local_variable ( 'var' );

          --If there is an instance quantifier, it is now on top of stack. Also need to store.

          IF ( l_return = const_quantifier_created ) THEN astore_local_variable ( 'iq' ); END IF;

          l_value := p_property_values.FIRST;

          WHILE ( l_value IS NOT NULL ) LOOP

             l_count := p_property_values ( l_value ).COUNT;

             FOR i IN 1..l_count LOOP

               IF ( l_return = const_quantifier_created ) THEN aload_local_variable ( 'iq' ); END IF;
               aload_local_variable ( 'var' );

               push_variable ( p_property_values ( l_value )( i ), 'ISingletonExprDef');
               emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

               apply_bom_logical_context ( p_property_values ( l_value )( i ), l_return );

             END LOOP;

             invoke_anyalltrue ( h_templates ('anytrue'), l_count );

             --If the property value is 1, there is no need to multiply.

             IF ( TO_NUMBER ( l_value ) <> 1 ) THEN

                push_decimal_constant ( TO_NUMBER ( l_value ));
                emit_invokevirtual ( CASE p_data_type WHEN h_datatypes ('decimal') THEN 'INumExprDef.prod(double)' ELSE 'INumExprDef.prod(int)' END );

             END IF;

             l_value := p_property_values.NEXT ( l_value );

          END LOOP;

        ELSE
            -- '"Selection()" property is allowed only for Option Feature or BOM Option Class. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_SELECT_PROP_NOTALLOW ),
                p_warning_location => 'generate_selection_object');

        END IF;

        sum_numeric ( p_property_values.COUNT );

     END generate_selection_object;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_text_comparison ( p_operator IN PLS_INTEGER
                                        , p_side IN PLS_INTEGER
                                        , p_input_context IN expression_context
                                        , x_output_context IN OUT NOCOPY expression_context
                                        ) IS

        t_property_values   type_numbertable_hashtable;

     BEGIN

        EXECUTE IMMEDIATE build_executable ( 2, parse_operator ( 'cz_fce_compile.t_(1)(i1)(1)', p_operator, 'cz_fce_compile.t_(2)(i2)(1)'));

        IF ( p_side = 0 ) THEN

           --There is no selection, both sides are text literals, just push either true or false.

           push_constant_expr ( CASE c_.combinations.COUNT WHEN 0 THEN '0' ELSE '1' END, h_datatypes ('boolean'));

        ELSE

           --We populate the table in such a way, that the following procedure will just generate
           --intersect of all options or bom children. The key '1' is used so that this intersect
           --would not be multiplied by anything.

           FOR i IN 1..c_.combinations.COUNT LOOP

              t_property_values ( '1' )( i ) := c_.combinations ( i )( p_side ).ps_node_id;

           END LOOP;

           generate_selection_object ( c_.participants ( p_side ).ps_node_id
                                     , c_.participants ( p_side ).model_ref_expl_id
                                     , h_datatypes ('text')
                                     , t_property_values
                                     , p_input_context, x_output_context );
        END IF;
     END generate_text_comparison;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_selection ( j IN PLS_INTEGER
                                  , p_property_id IN NUMBER
                                  , p_input_context IN expression_context
                                  , x_output_context IN OUT NOCOPY expression_context
                                  ) IS

        l_property_id       NUMBER := p_property_id;
        l_data_type         NUMBER;
        l_value             VARCHAR2(4000);
        l_count             PLS_INTEGER;

        l_text_property     BOOLEAN := FALSE;
        l_side              PLS_INTEGER;

        t_children          type_iteratornode_table;
        t_property_values   type_numbertable_hashtable;

     BEGIN

        IF ( t_exp_psnodeid ( j ) IS NULL ) THEN
           -- '"Selection()" property is allowed only for Option Feature or BOM Option Class. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_SELECT_PROP_NOTALLOW ),
                p_warning_location => 'generate_selection');

        END IF;

        IF ( l_property_id IS NULL ) THEN

           --No explicitly specified property, derive one from the context.

           IF ( logical_context ( j, p_input_context.context_type )) THEN

              l_property_id := h_templates ('state');

           ELSIF ( numeric_context ( j, p_input_context.context_type )) THEN

              l_property_id := h_templates ('quantity');

           ELSE
              -- 'Invalid context found for applying default property. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
              report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_DEFPROP_INVAL_CTX ),
                p_warning_location => 'generate_selection');

           END IF;

           h_propertyid_type ( TO_CHAR ( l_property_id )) := h_exprtypes ('systemproperty');

        END IF;

        IF ( h_quantities.EXISTS ( l_property_id ) OR l_property_id IN ( h_templates ('state'), h_templates ('value'))) THEN

           generate_selection_property ( j, l_property_id, p_input_context, x_output_context );
           RETURN;

        ELSIF ( l_property_id IN ( h_templates ('name'), h_templates ('description'))) THEN

           get_static_info ( l_property_id, l_data_type );

        ELSIF ( get_property_type ( l_property_id ) = h_exprtypes ('property')) THEN

           get_user_info ( l_property_id, l_data_type, l_value );

        ELSE
           -- 'Invalid system property is used with the "Selection()" operator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INVAL_SPROP_SELECT ),
                p_warning_location => 'generate_selection');

        END IF;

        t_children := explode_node_children ( t_exp_psnodeid ( j ), t_exp_modelrefexplid ( j ), TRUE );

        IF ( l_data_type = h_datatypes ('text') OR p_input_context.context_type = const_context_selection ) THEN

           --This will be 'text' selection, prepare the data structures.

           l_side := s_.COUNT + 1;
           s_( l_side ) := t_children.COUNT;

           c_.participants ( l_side ).ps_node_id := t_exp_psnodeid ( j );
           c_.participants ( l_side ).model_ref_expl_id := t_exp_modelrefexplid ( j );

           l_text_property := TRUE;

        END IF;

        --All distinct property values are keys to the tables of all options that have these values.

        FOR i IN 1..t_children.COUNT LOOP

           l_value := get_property_value ( l_property_id, t_children ( i ).ps_node_id, t_children ( i ).model_ref_expl_id );

           IF ( l_value IS NULL ) THEN
              -- 'Property ^PROP_NAME has no value for node ^NODE_NAME. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
              report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT( CZ_FCE_W_PROPERTY_NULL_VALUE,
                    'PROP_NAME', CZ_FCE_COMPILE_UTILS.GET_PROPERTY_PATH(l_property_id),
                    'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH(t_children ( i ).ps_node_id,
                        ps_node_id_table_to_string(
                                    build_complete_path(t_children ( i ).ps_node_id, t_children ( i ).model_ref_expl_id) ) ),
                    'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                    'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_selection');

           END IF;

           IF ( l_text_property ) THEN

              --Populate the data structures that will be used for generation.

              o_( l_side )( i ).ps_node_id := t_children ( i ).ps_node_id;
              o_( l_side )( i ).model_ref_expl_id := t_children ( i ).model_ref_expl_id;

              t_( l_side )( i )( 1 ) := l_value;

           ELSE

              IF ( NOT t_property_values.EXISTS ( l_value )) THEN

                 t_property_values ( l_value )( 1 ) := t_children ( i ).ps_node_id;

              ELSE

                 l_count := t_property_values ( l_value ).COUNT + 1;
                 t_property_values ( l_value )( l_count ) := t_children ( i ).ps_node_id;

              END IF;
           END IF;
        END LOOP;

        IF ( NOT l_text_property ) THEN

           --Generate the 'numeric' selection object.

           generate_selection_object ( t_exp_psnodeid ( j )
                                     , t_exp_modelrefexplid ( j )
                                     , l_data_type
                                     , t_property_values
                                     , p_input_context, x_output_context );

        END IF;
     END generate_selection;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     -- Returns the data type of the given signature argument.

     FUNCTION get_signature_arg_info ( p_arg_index    IN NUMBER
                                     , p_signature_id IN NUMBER
                                     , x_mutable      IN OUT NOCOPY VARCHAR2
                                     , x_collection   IN OUT NOCOPY VARCHAR2
                                     ) RETURN NUMBER IS

          l_data_type  cz_signature_arguments.data_type%TYPE;

      BEGIN

          SELECT data_type, mutable_flag, collection_flag INTO l_data_type, x_mutable, x_collection
            FROM cz_signature_arguments
           WHERE deleted_flag = '0'
             AND argument_signature_id = p_signature_id
             AND argument_index = p_arg_index;

          RETURN l_data_type;

      EXCEPTION
        WHEN OTHERS THEN

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENSARG_NO_DTYPE,
                        'ARG_IX', p_arg_index,
                        'SIGNATURE_ID', p_signature_id ),
                p_warning_location => 'get_signature_arg_info');

          RETURN NULL;

      END get_signature_arg_info;
      ---------------------------------------------------------------------------------------
      -- Scope: compile_constraints
      -- Returns TRUE when the given property associated with the given node id is valid, otherwise
      -- returns FALSE.

      FUNCTION is_valid_property ( j             IN PLS_INTEGER
                                 , p_ps_node_id  IN NUMBER
                                 , p_property_id IN NUMBER
                                 ) RETURN BOOLEAN IS

          l_null        PLS_INTEGER;
          l_data_type   cz_signature_arguments.data_type%TYPE;
          l_mutable     cz_signature_arguments.mutable_flag%TYPE;
          l_collection  cz_signature_arguments.collection_flag%TYPE;

          l_key         VARCHAR2(4000);

      BEGIN

         l_key := TO_CHAR ( p_ps_node_id ) || ':' || TO_CHAR ( p_property_id );

         IF ( NOT h_psnid_propid_isvalid.EXISTS ( l_key )) THEN

           IF ( t_exp_paramindex ( j ) IS NULL OR t_exp_paramsignatureid ( j ) IS NULL ) THEN

              --Some of the upgraded rules may not have param_index and param_signature_id populated. However, upgraded
              --rules are not real statement rules, so they are not supposed to have any user error in them and in this
              --case the verification is not required.

              h_psnid_propid_isvalid ( l_key ) := TRUE;

           ELSE

             BEGIN

               l_data_type := get_signature_arg_info ( t_exp_paramindex ( j ), t_exp_paramsignatureid ( j ), l_mutable, l_collection );

               SELECT NULL INTO l_null
                 FROM cz_rul_typedpsn_v psn,
                      cz_conversion_rels_v cnv,
                      cz_system_property_rels_v rel,
                      cz_system_properties_v sys,
                      cz_conversion_rels_v cnv2
                WHERE psn.detailed_type_id = cnv.object_type
                  AND cnv.subject_type = rel.subject_type
                  AND rel.object_type = sys.rule_id
                  AND rel.rel_type_code = 'SYS'
                  AND sys.data_type = cnv2.object_type
                  AND psn.ps_node_id = p_ps_node_id
                  AND sys.rule_id = p_property_id
                  AND sys.mutable_flag >= l_mutable
--Note: Collection flag filter is removed, to allow rules like AddsTo(OptionFeature.options(), Total).
--                AND sys.collection_flag <= l_collection
                  AND cnv2.subject_type = l_data_type;

               h_psnid_propid_isvalid ( l_key ) := TRUE;

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   h_psnid_propid_isvalid ( l_key ) := FALSE;
                WHEN TOO_MANY_ROWS THEN
                   h_psnid_propid_isvalid ( l_key ) := TRUE;
                WHEN OTHERS THEN
                   RAISE;
             END;
           END IF;
         END IF;

         RETURN h_psnid_propid_isvalid ( l_key );

      END is_valid_property;
     ---------------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_structure_node ( j IN PLS_INTEGER
                                       , p_input_context IN expression_context
                                       , x_output_context IN OUT NOCOPY expression_context ) IS

       l_expr_id       VARCHAR2(4000);
       l_property_id   NUMBER;
       l_index         PLS_INTEGER;
       l_target_key    VARCHAR2(4000);

    BEGIN

       IF ( p_input_context.context_type = const_context_target ) THEN

          --This has been moved here from generate_path because when the target exists, we need
          --to just populate the output context and exit and not apply any context that is done
          --usually after generate_path (for example, see generate_node).

          --In general, this key should contain more information about the target and the rule,
          --including rule's effecitivity and usage, and target's properties.

          l_target_key := TO_CHAR ( t_exp_psnodeid ( j )) || ':' || TO_CHAR ( t_exp_modelrefexplid ( j ));

          IF ( h_acc_targets.EXISTS ( l_target_key )) THEN

             --Target has been generated before, just return. Context is changed to generic to
             --indicate that.

             x_output_context.context_type := const_context_generic;
             x_output_context.context_num_data := h_acc_targets ( l_target_key );

             RETURN;
          END IF;
       END IF;

       l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

       IF ( NOT h_exprid_childrenindex.EXISTS ( l_expr_id )) THEN

          generate_node ( j, p_input_context, x_output_context );

       ELSE

          l_index := h_exprid_childrenindex ( l_expr_id );

          IF ( t_exp_exprtype ( l_index ) = h_exprtypes ('property')) THEN

              generate_user_property ( j, p_input_context, x_output_context );

          ELSIF ( t_exp_templateid ( l_index ) = h_templates ('selection')) THEN

              l_index := l_index + 1;

              IF ( t_exp_exprparentid.EXISTS ( l_index ) AND t_exp_exprparentid ( l_index ) = t_exp_exprnodeid ( j )) THEN

                 l_property_id := get_property_id ( l_index );

              END IF;

              generate_selection ( j, l_property_id, p_input_context, x_output_context );

          ELSE

             l_property_id := t_exp_templateid ( l_index );

             IF ( l_property_id IN ( h_templates ('mininstances'), h_templates ('maxinstances')) OR
                  ( NOT is_valid_property ( j, t_exp_psnodeid ( j ), l_property_id ))) THEN

              --#Dave Kulik, 10/05/07 regarding Min/MaxInstances:

              --The plan has always been to disallow operations directly on the mins and maxes. They would just
              --be side-effected by rules like "node.InstanceCount() > x". So if you want to use accumulator
              --rules you have a couple of options.  You could just write "x AddsTo node.InstanceCount()". Or,
              --if you wanted to constrain the domain of InstanceCount without affecting it directly and
              --immediately, you could maintain a couple of intermediate variables using accumulator rules and
              --constrain InstanceCount relative to those.

              --Property ^PROP_NAME is invalid for the node ^NODE_NAME. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

              report_and_raise_rule_warning (
                  p_text => CZ_UTILS.GET_TEXT (
                          CZ_FCE_W_INVALID_PROPERTY,
                          'PROP_NAME', CZ_FCE_COMPILE_UTILS.GET_PROPERTY_PATH ( l_property_id ),
                          'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH ( t_exp_psnodeid ( j ),
                                   ps_node_id_table_to_string (
                                    build_complete_path ( t_exp_psnodeid ( j ), t_exp_modelrefexplid( j )))),
                          'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                          'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH( p_component_id, p_model_path )),
                p_warning_location => 'generate_structure_node');

            END IF;

            IF ( l_property_id = h_templates ('options')) THEN

                generate_options ( j, p_input_context, x_output_context );

             ELSE

                generate_system_property ( l_property_id, t_exp_psnodeid ( j ), t_exp_modelrefexplid ( j ), p_input_context, x_output_context );

             END IF;
          END IF;
       END IF;
    END generate_structure_node;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_logic_template ( j IN PLS_INTEGER
                                       , p_input_context IN expression_context
                                       , x_output_context IN OUT NOCOPY expression_context
                                       ) IS

        l_expr_id             VARCHAR2(4000);
        l_exprnode_id         NUMBER;
        l_index               PLS_INTEGER;
        l_expr_index          PLS_INTEGER;

        t_lhs_operator        type_integer_table;
        t_lhs_index           type_integer_table;
        t_logic_operator      type_integer_table;
        t_rhs_operator        type_integer_table;
        t_rhs_index           type_integer_table;

        l_input_context       expression_context;

     BEGIN

        --This procedure implements generation of simple logic rule. The template application
        --specifies the following parameters:

        -- param_index = 1: left-hand side AnyTrue or AllTrue operator
        -- param_index = 2: left-hand side participant(s)
        -- param_index = 3: logic operator
        -- param_index = 4: right-hand side AnyTrue or AllTrue operator
        -- param_index = 5: right-hand side participant(s)

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                            'EXPR_ID', l_expr_id ),
                p_warning_location => 'generate_logic_template');

        END IF;

        --Parse the template application.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_paramindex ( l_expr_index )

               WHEN 1 THEN

                  t_lhs_operator ( t_lhs_operator.COUNT + 1 ) := l_expr_index;

               WHEN 2 THEN

                  t_lhs_index ( t_lhs_index.COUNT + 1 ) := l_expr_index;

               WHEN 3 THEN

                  t_logic_operator ( t_logic_operator.COUNT + 1 ) := t_exp_templateid ( l_expr_index );

               WHEN 4 THEN

                  t_rhs_operator ( t_rhs_operator.COUNT + 1 ) := l_expr_index;

               WHEN 5 THEN

                  t_rhs_index ( t_rhs_index.COUNT + 1 ) := l_expr_index;

           END CASE;
        END LOOP;

        --Verify the template application.

        IF ( t_lhs_operator.COUNT <> 1 OR ( NOT h_operators_3.EXISTS ( t_exp_templateid ( t_lhs_operator ( 1 ))))) THEN
            -- 'Left-hand side operator is either not-specified or invalid. Logic rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_LR_MISSING_LHS_OP ),
                p_warning_location => 'generate_logic_template');

        ELSIF ( t_lhs_index.COUNT = 0 ) THEN
            -- Right-hand side participants are missing.  Logic rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
            report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_LR_MISSING_LHS_PARTS,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_logic_template');

        ELSIF ( t_logic_operator.COUNT <> 1 OR ( NOT h_operators_2.EXISTS ( t_logic_operator ( 1 )))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_LR_MISSING_LOGIC_OP ),
                p_warning_location => 'generate_logic_template');

        ELSIF ( t_rhs_operator.COUNT <> 1 OR ( NOT h_operators_3.EXISTS ( t_exp_templateid ( t_rhs_operator ( 1 ))))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_LR_MISSING_RHS_OP ),
                p_warning_location => 'generate_logic_template');

        ELSIF ( t_rhs_index.COUNT = 0 ) THEN
            -- Right-hand side participants are missing.  Logic rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
            report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_LR_MISSING_RHS_PARTS,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_logic_template');

        END IF;

        l_input_context.context_type := const_context_logical;

        --Need to emulate all participants as children of the AnyTrue or AllTrue operator
        --in order to provide context for participants' generation, and to know the exact
        --number of arguments to this operator.

        l_exprnode_id := t_exp_exprnodeid ( t_lhs_operator ( 1 ));
        l_expr_id := TO_CHAR ( l_exprnode_id );

        h_exprid_numberofchildren ( l_expr_id ) := 0;

        FOR i IN 1..t_lhs_index.COUNT LOOP

            t_exp_exprparentid ( t_lhs_index ( i )) := l_exprnode_id;
            h_exprid_numberofchildren ( l_expr_id ) := h_exprid_numberofchildren ( l_expr_id ) + 1;

            generate_expression ( t_lhs_index ( i ), l_input_context, x_output_context );

        END LOOP;

        invoke_anyalltrue ( t_exp_templateid ( t_lhs_operator ( 1 )), h_exprid_numberofchildren ( l_expr_id ));

        l_exprnode_id := t_exp_exprnodeid ( t_rhs_operator ( 1 ));
        l_expr_id := TO_CHAR ( l_exprnode_id );

        h_exprid_numberofchildren ( l_expr_id ) := 0;

        FOR i IN 1..t_rhs_index.COUNT LOOP

            t_exp_exprparentid ( t_rhs_index ( i )) := l_exprnode_id;
            h_exprid_numberofchildren ( l_expr_id ) := h_exprid_numberofchildren ( l_expr_id ) + 1;

            generate_expression ( t_rhs_index ( i ), l_input_context, x_output_context );

        END LOOP;

        invoke_anyalltrue ( t_exp_templateid ( t_rhs_operator ( 1 )), h_exprid_numberofchildren ( l_expr_id ));
        emit_invokevirtual ( h_operators_2 ( t_logic_operator ( 1 )));

     END generate_logic_template;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_comparison_template ( j IN PLS_INTEGER
                                            , p_input_context IN expression_context
                                            , x_output_context IN OUT NOCOPY expression_context
                                            ) IS

        l_expr_id               VARCHAR2(4000);
        l_exprnode_id           NUMBER;
        l_index                 PLS_INTEGER;
        l_expr_index            PLS_INTEGER;

        t_lhs_operand           type_integer_table;
        t_comparison_operator   type_integer_table;
        t_rhs_operand           type_integer_table;
        t_logic_operator        type_integer_table;
        t_rhs_operator          type_integer_table;
        t_rhs_index             type_integer_table;

        l_input_context         expression_context;

     BEGIN

        --This procedure implements generation of simple comparison rule. The template application
        --specifies the following parameters:

        -- param_index = 1: left operand of the comparison operator
        -- param_index = 2: comparison operator
        -- param_index = 3: right operand of the comparison operator
        -- param_index = 4: logic operator
        -- param_index = 5: right-hand side AnyTrue or AllTrue operator
        -- param_index = 6: right-hand side participant(s)

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                            'EXPR_ID', l_expr_id ),
                p_warning_location => 'generate_comparison_template');

        END IF;

        --Parse the template application.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_paramindex ( l_expr_index )

               WHEN 1 THEN

                  t_lhs_operand ( t_lhs_operand.COUNT + 1 ) := l_expr_index;

               WHEN 2 THEN

                  t_comparison_operator ( t_comparison_operator.COUNT + 1 ) := t_exp_templateid ( l_expr_index );

               WHEN 3 THEN

                  t_rhs_operand ( t_rhs_operand.COUNT + 1 ) := l_expr_index;

               WHEN 4 THEN

                  t_logic_operator ( t_logic_operator.COUNT + 1 ) := t_exp_templateid ( l_expr_index );

               WHEN 5 THEN

                  t_rhs_operator ( t_rhs_operator.COUNT + 1 ) := l_expr_index;

               WHEN 6 THEN

                  t_rhs_index ( t_rhs_index.COUNT + 1 ) := l_expr_index;

           END CASE;
        END LOOP;

        --Verify the template application.

        IF ( t_lhs_operand.COUNT <> 1 ) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_CR_NO_LHS_OPAND ),
                p_warning_location => 'generate_comparison_template');

        ELSIF ( t_comparison_operator.COUNT <> 1 OR ( NOT h_operators_2.EXISTS ( t_comparison_operator ( 1 )))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_CR_NO_OPERATOR ),
                p_warning_location => 'generate_comparison_template');

        ELSIF ( t_rhs_operand.COUNT <> 1 ) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_CR_NO_RHS_OPAND ),
                p_warning_location => 'generate_comparison_template');

        ELSIF ( t_logic_operator.COUNT <> 1 OR ( NOT h_operators_2.EXISTS ( t_logic_operator ( 1 )))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_CR_NO_LOGIC_OP ),
                p_warning_location => 'generate_comparison_template');

        ELSIF ( t_rhs_operator.COUNT <> 1 OR ( NOT h_operators_3.EXISTS ( t_exp_templateid ( t_rhs_operator ( 1 ))))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_CR_NO_RHS_OP ),
                p_warning_location => 'generate_comparison_template');

        ELSIF ( t_rhs_index.COUNT = 0 ) THEN
            -- Right-hand side participants are missing.  Comparison rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
            report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_CR_MISSING_RHS_PARTS,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_comparison_template');

        END IF;

        --Generate the math expression which is left-hand side of the logic operator.

        l_input_context.context_type := const_context_numeric;

        generate_expression ( t_lhs_operand ( 1 ), l_input_context, x_output_context );
        generate_expression ( t_rhs_operand ( 1 ), l_input_context, x_output_context );

        invoke_operator2 ( t_comparison_operator ( 1 ), t_rhs_operand ( 1 ), x_output_context );

        l_input_context.context_type := const_context_logical;

        --Need to emulate all participants as children of the AnyTrue or AllTrue operator
        --in order to provide context for participants' generation, and to know the exact
        --number of arguments to this operator.

        l_exprnode_id := t_exp_exprnodeid ( t_rhs_operator ( 1 ));
        l_expr_id := TO_CHAR ( l_exprnode_id );

        h_exprid_numberofchildren ( l_expr_id ) := 0;

        FOR i IN 1..t_rhs_index.COUNT LOOP

            t_exp_exprparentid ( t_rhs_index ( i )) := l_exprnode_id;
            h_exprid_numberofchildren ( l_expr_id ) := h_exprid_numberofchildren ( l_expr_id ) + 1;

            generate_expression ( t_rhs_index ( i ), l_input_context, x_output_context );

        END LOOP;

        invoke_anyalltrue ( t_exp_templateid ( t_rhs_operator ( 1 )), h_exprid_numberofchildren ( l_expr_id ));
        emit_invokevirtual ( h_operators_2 ( t_logic_operator ( 1 )));

     END generate_comparison_template;
     ----------------------------------------------------------------------------------
     FUNCTION next_interval_key ( p_target_id IN PLS_INTEGER ) RETURN VARCHAR2 IS

       l_seq   PLS_INTEGER := t_acc_target_sequence ( p_target_id );

     BEGIN

        t_acc_target_sequence ( p_target_id ) := l_seq + 1;
        RETURN TO_CHAR ( l_seq ) || '$' || t_acc_targets ( p_target_id );

     END next_interval_key;
     ----------------------------------------------------------------------------------
     --This function adds instance quantifies, generated for the new contribution, to the
     --list of instance quantifiers of the record with index p_index.

     PROCEDURE combine_instance_quantifiers ( p_target_id IN PLS_INTEGER, p_index IN PLS_INTEGER ) IS

        l_count   PLS_INTEGER;

     BEGIN

        --Add all the quantifiers that were created for this contribution and are not present in the
        --record's arrays, to the record.

        FOR i IN 1..t_acc_local_quantifiers.COUNT LOOP

           IF ( NOT t_acc_contributors ( p_target_id )( p_index ).hash_quantifiers.EXISTS ( t_acc_local_quantifiers ( i ))) THEN

              l_count := t_acc_contributors ( p_target_id )( p_index ).quantifiers.COUNT + 1;

              t_acc_contributors ( p_target_id )( p_index ).quantifiers ( l_count ) := t_acc_local_quantifiers ( i );
              t_acc_contributors ( p_target_id )( p_index ).hash_quantifiers ( t_acc_local_quantifiers ( i )) := 1;

           END IF;
        END LOOP;
     END combine_instance_quantifiers;
     ----------------------------------------------------------------------------------
     --This function is used to store a combined contribution for the newly created record
     --with index p_index. When this function is called, the new contribution is on top of
     --stack.

     --The function combines the new contribution with the contribution which is currently
     --stored in the register p_exist_key (if any) and stores the combined contribution in
     --the register of the new record (the value is removed from stack). Target's instance
     --quantifiers are combined.

     PROCEDURE combine_contributions ( p_target_id IN PLS_INTEGER, p_index IN PLS_INTEGER, p_exist_key IN VARCHAR2 ) IS
     BEGIN

        aload_register ('value');

        IF ( p_exist_key IS NOT NULL ) THEN

           aload_register ( p_exist_key );
           emit_invokevirtual ('INumExprDef.sum(INumExprDef)');

        END IF;

        IF ( t_acc_contributors ( p_target_id )( p_index ).interval_key IS NULL ) THEN

           t_acc_contributors ( p_target_id )( p_index ).interval_key := next_interval_key ( p_target_id );

        END IF;

        astore_register ( t_acc_contributors ( p_target_id )( p_index ).interval_key );
        combine_instance_quantifiers ( p_target_id, p_index );

     END combine_contributions;
     ----------------------------------------------------------------------------------
     PROCEDURE combine_contribution_records ( p_target_id IN PLS_INTEGER, p_index IN PLS_INTEGER, p_exist_key IN VARCHAR2 ) IS

        l_count         PLS_INTEGER;

        l_exist_mask_   RAW(16);
        l_new_mask_     RAW(16);

        l_common_mask   VARCHAR2(16);
        l_exist_mask    VARCHAR2(16);
        l_new_mask      VARCHAR2(16);

     BEGIN

        l_exist_mask_ := HEXTORAW ( t_acc_contributors ( p_target_id )( p_index ).effective_usage_mask );
        l_new_mask_ := HEXTORAW ( this_effective_usages );

        l_common_mask := RAWTOHEX ( UTL_RAW.BIT_OR ( l_exist_mask_, l_new_mask_ ));

        IF ( l_common_mask <> const_mask_no_usages ) THEN

           --Usages, defined only for the existing contribution record.

           l_exist_mask := RAWTOHEX ( UTL_RAW.BIT_OR ( l_exist_mask_, UTL_RAW.BIT_COMPLEMENT ( l_new_mask_ )));

           --Usages, defined only for the new contribution.

           l_new_mask := RAWTOHEX ( UTL_RAW.BIT_OR ( UTL_RAW.BIT_COMPLEMENT ( l_exist_mask_ ), l_new_mask_ ));

           IF ( l_common_mask = t_acc_contributors ( p_target_id )( p_index ).effective_usage_mask ) THEN

              --New usage mask containt the existing or masks are equal, combine contributions on the existing
              --record.

              IF ( t_acc_contributors ( p_target_id )( p_index ).interval_key IS NOT NULL ) THEN

                 --If the interval has a contribution stored in a register, we need to create a new register
                 --because we will be changing the contribution while the existing register may be also used
                 --on some other interval.

                 t_acc_contributors ( p_target_id )( p_index ).interval_key := next_interval_key ( p_target_id );

              END IF;

              combine_contributions ( p_target_id, p_index, p_exist_key );

           ELSE

              --Existing usage mask contains the new or masks intersect. We need to change the mask
              --on the existing record to l_exist_mask because only on this usages we will have the
              --existing contribution. Then we create a new record for common usages summing up the
              --contributions.

              l_count := t_acc_contributors ( p_target_id ).COUNT + 1;
              t_acc_contributors ( p_target_id )( l_count ) := t_acc_contributors ( p_target_id )( p_index );

              t_acc_contributors ( p_target_id )( p_index ).effective_usage_mask := l_exist_mask;

              t_acc_contributors ( p_target_id )( l_count ).effective_usage_mask := l_common_mask;
              t_acc_contributors ( p_target_id )( l_count ).interval_key := next_interval_key ( p_target_id );

              combine_contributions ( p_target_id, l_count, p_exist_key );

           END IF;
        END IF;
     END combine_contribution_records;
     ----------------------------------------------------------------------------------
     PROCEDURE combine_contributors ( p_target_id IN PLS_INTEGER ) IS

        l_contribs      PLS_INTEGER;
        l_count         PLS_INTEGER;

        l_eff_from      DATE;
        l_eff_until     DATE;
        l_interval_key VARCHAR2(4000);

     BEGIN

        IF ( t_acc_contributors.EXISTS ( p_target_id )) THEN

           --There are existing contributions to this target. We need combine this new contribution
           --with others according to effectivities and usages.

           --The new contribution is currently on top of the stack and needs to be available for
           --each interval that we process. We store it in a dedicated register and then push it
           --from there before each use.

           astore_register ('value');
           l_contribs := t_acc_contributors ( p_target_id ).COUNT;

           FOR i IN 1..l_contribs LOOP

              l_eff_from := t_acc_contributors ( p_target_id )( i ).effective_from;
              l_eff_until := t_acc_contributors ( p_target_id )( i ).effective_until;

              IF ( this_effective_until > l_eff_from AND this_effective_from < l_eff_until ) THEN

                 --Effectivity intervals intersect.

                 IF ( this_effective_from <= l_eff_from AND this_effective_until >= l_eff_until ) THEN

                    --        |------------------------| - existing interval
                    -- |------------------------------------| - new interval

                    --The new contribution's effectivity interval contains the existing interval, or intervals
                    --are the same, including the case when both are always effective.
                    -- vsingava 06th May '10 - bug9368550
                    -- Do not pass a PL/SQL table record directly as a parameter, when the table
                    -- record being passed can change inside the invoked procedure/function.
                    -- This behavior is most likely a PL/SQL bug, and this change is a workaround.
                    l_interval_key := t_acc_contributors ( p_target_id )( i ).interval_key;
                    combine_contribution_records ( p_target_id, i, l_interval_key );

                 ELSE

                    --One or both ends of the new effectivity interval are inside the existing interval, split them
                    --into several intervals and add them to the table of contribution records.

                    l_count := t_acc_contributors ( p_target_id ).COUNT + 1;
                    t_acc_contributors ( p_target_id )( l_count ) := t_acc_contributors ( p_target_id )( i );

                    IF ( this_effective_from <= l_eff_from ) THEN

                       --        |------------------------| - existing interval
                       -- |----------------| - new interval

                       --Modify the existing interval. As contributions does not change, we don't need to store it
                       --in the register, it's already there.

                       t_acc_contributors ( p_target_id )( i ).effective_from := this_effective_until;

                       --Create a new record for the intersection.

                       t_acc_contributors ( p_target_id )( l_count ).effective_from := l_eff_from;
                       t_acc_contributors ( p_target_id )( l_count ).effective_until := this_effective_until;

                    ELSIF ( this_effective_until >= l_eff_until ) THEN

                       -- |------------------------| - existing interval
                       --               |-----------------| - new interval

                       --Modify the existing interval. As contributions does not change, we don't need to store it
                       --in the register, it's already there.

                       t_acc_contributors ( p_target_id )( i ).effective_until := this_effective_from;

                       --Create a new record for the intersection.

                       t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_from;
                       t_acc_contributors ( p_target_id )( l_count ).effective_until := l_eff_until;

                    ELSE

                       -- |------------------------| - existing interval
                       --     |------------| - new interval

                       --Split the existing interval into two with the same contributions.

                       t_acc_contributors ( p_target_id )( i ).effective_until := this_effective_from;
                       t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_until;

                       --Create a new record for the intersection.

                       l_count := l_count + 1;
                       t_acc_contributors ( p_target_id )( l_count ) := t_acc_contributors ( p_target_id )( i );

                       t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_from;
                       t_acc_contributors ( p_target_id )( l_count ).effective_until := this_effective_until;

                    END IF;

                    --Process the intersection for usages.
                    --vsingava 06th May '10 - bug9368550
                    -- Do not pass a PL/SQL table record directly as a parameter, when the table
                    -- record being passed can change inside the invoked procedure/function.
                    -- This behavior is most likely a PL/SQL bug, and this change is a workaround.
                    l_interval_key := t_acc_contributors ( p_target_id )( i ).interval_key;
                    combine_contribution_records ( p_target_id, l_count, l_interval_key );

                 END IF;
              END IF;
           END LOOP;

        ELSE

           --This is the first contributor to this target.

           l_count := 1;

           IF ( this_effective_from > const_epoch_begin ) THEN

              t_acc_contributors ( p_target_id )( l_count ).effective_from := const_epoch_begin;
              t_acc_contributors ( p_target_id )( l_count ).effective_until := this_effective_from;
              t_acc_contributors ( p_target_id )( l_count ).effective_usage_mask := const_mask_all_usages;

              t_acc_contributors ( p_target_id )( l_count ).interval_key := NULL;
              t_acc_contributors ( p_target_id )( l_count ).quantifiers := t_acc_quantifiers ( p_target_id );
              t_acc_contributors ( p_target_id )( l_count ).hash_quantifiers := h_acc_quantifiers ( p_target_id );

              l_count := l_count + 1;

           END IF;

           t_acc_contributors ( p_target_id )( l_count ).interval_key := next_interval_key ( p_target_id );

           --Note that t_acc_quantifiers at this point contains also the target's quantifier, so
           --we are initializing the quantifiers array with all quantifiers generated for the
           --first contribution to this target. After that we will be appending this array, when
           --combining contributions, with quantifiers, generated for contributors.

           t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_from;
           t_acc_contributors ( p_target_id )( l_count ).effective_until := this_effective_until;
           t_acc_contributors ( p_target_id )( l_count ).effective_usage_mask := this_effective_usages;

           t_acc_contributors ( p_target_id )( l_count ).quantifiers := t_acc_quantifiers ( p_target_id );
           t_acc_contributors ( p_target_id )( l_count ).hash_quantifiers := h_acc_quantifiers ( p_target_id );

           astore_register ( t_acc_contributors ( p_target_id )( l_count ).interval_key );

           IF ( this_effective_usages <> const_mask_all_usages ) THEN

              --If this contribution is not for all usages, we need to add a dummy record with null
              --key and complemental usage mask. It works for the same purpose as dummy effectivity
              --intervals.

              l_count := l_count + 1;

              t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_from;
              t_acc_contributors ( p_target_id )( l_count ).effective_until := this_effective_until;
              t_acc_contributors ( p_target_id )( l_count ).effective_usage_mask := RAWTOHEX ( UTL_RAW.BIT_COMPLEMENT ( this_effective_usages ));

              t_acc_contributors ( p_target_id )( l_count ).interval_key := NULL;
              t_acc_contributors ( p_target_id )( l_count ).quantifiers := t_acc_quantifiers ( p_target_id );
              t_acc_contributors ( p_target_id )( l_count ).hash_quantifiers := h_acc_quantifiers ( p_target_id );

           END IF;

           IF ( this_effective_until < const_epoch_end ) THEN

              l_count := l_count + 1;

              t_acc_contributors ( p_target_id )( l_count ).effective_from := this_effective_until;
              t_acc_contributors ( p_target_id )( l_count ).effective_until := const_epoch_end;
              t_acc_contributors ( p_target_id )( l_count ).effective_usage_mask := const_mask_all_usages;

              t_acc_contributors ( p_target_id )( l_count ).interval_key := NULL;
              t_acc_contributors ( p_target_id )( l_count ).quantifiers := t_acc_quantifiers ( p_target_id );
              t_acc_contributors ( p_target_id )( l_count ).hash_quantifiers := h_acc_quantifiers ( p_target_id );

           END IF;
        END IF;
     END combine_contributors;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_accumulator_template ( j IN PLS_INTEGER
                                             , p_input_context IN expression_context
                                             , x_output_context IN OUT NOCOPY expression_context
                                             ) IS

        l_expr_id             VARCHAR2(4000);
        l_index               PLS_INTEGER;
        l_expr_index          PLS_INTEGER;
        l_count               PLS_INTEGER;
        l_key                 VARCHAR2(4000);

        t_contributor_index   type_integer_table;
        t_multiplier          type_number_table;
        t_accumulation_op     type_integer_table;
        t_rounding_op         type_integer_table;
        t_target_index        type_integer_table;

        l_input_context       expression_context;

     BEGIN

        --This procedure implements generation of simple accumulation rule. The template application
        --specifies the following parameters:

        -- param_index = 1: contributor(s)
        -- param_index = 2: multiplier (constant)
        -- param_index = 3: accumulation operator
        -- param_index = 4: rounding operator
        -- param_index = 5: target

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                            'EXPR_ID', l_expr_id ),
                p_warning_location => 'generate_accumulator_template');

        END IF;

        --Parse the template application.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_paramindex ( l_expr_index )

               WHEN 1 THEN

                  t_contributor_index ( t_contributor_index.COUNT + 1 ) := l_expr_index;

               WHEN 2 THEN

                  t_multiplier ( t_multiplier.COUNT + 1 ) := NVL ( t_exp_datanumvalue ( l_expr_index ), 1 );

               WHEN 3 THEN

                  t_accumulation_op ( t_accumulation_op.COUNT + 1 ) := t_exp_templateid ( l_expr_index );

               WHEN 4 THEN

                  t_rounding_op ( t_rounding_op.COUNT + 1 ) := t_exp_templateid ( l_expr_index );

               WHEN 5 THEN

                  t_target_index ( t_target_index.COUNT + 1 ) := l_expr_index;

           END CASE;
        END LOOP;

        --Verify the template application.

        IF ( t_contributor_index.COUNT = 0 ) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_AR_NO_LHS_OPAND ),
                p_warning_location => 'generate_accumulator_template');

        ELSIF ( t_multiplier.COUNT <> 1 ) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_AR_NO_MLTIPLIER ),
                p_warning_location => 'generate_accumulator_template');

        ELSIF ( t_accumulation_op.COUNT <> 1 OR ( NOT h_accumulation_ops.EXISTS ( t_accumulation_op ( 1 )))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_AR_NO_OPERATOR ),
                p_warning_location => 'generate_accumulator_template');

        ELSIF ( t_rounding_op.COUNT <> 1 OR ( NOT h_rounding_ops.EXISTS ( t_rounding_op ( 1 )))) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_AR_NO_ROUND_OP ),
                p_warning_location => 'generate_accumulator_template');

        ELSIF ( t_target_index.COUNT <> 1 ) THEN

            report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_AR_NO_RHS_OPAND ),
                p_warning_location => 'generate_accumulator_template');

        END IF;

        --Need to generate the target first, because generation of contributor will depend on the
        --target (LCA). Cannot just generate the path here because target can be an argument, for
        --example, in case of FORALL operator.

        l_input_context.context_type := const_context_target;
        generate_expression ( t_target_index ( 1 ), l_input_context, x_output_context );

        l_count := x_output_context.context_num_data;
        l_key := x_output_context.context_data;

        --If output context is 'target', the target didn't exist and needs to be stored.
        --For an exiting target, the context would have been changed to 'generic' in
        --generate_path procedure.

        IF ( x_output_context.context_type = const_context_target ) THEN

           astore_register ( l_key );

           t_target_quantifiers ( l_count ) := t_acc_quantifiers ( l_count );
           h_target_quantifiers ( l_count ) := h_acc_quantifiers ( l_count );

        END IF;

        --If there are more than 2 contributors, we will put them into an array and call
        --IModelDef.sum. To do this, we need extra model def on stack.

        IF ( t_contributor_index.COUNT > 2 ) THEN

            aload_model_def ( p_component_id );

        END IF;

        --Now generate all the contributors.

        t_acc_local_quantifiers.DELETE;

        FOR i IN 1..t_contributor_index.COUNT LOOP

            l_input_context.context_type := const_context_contributor;
            l_input_context.context_num_data := l_count;

            generate_expression ( t_contributor_index ( i ), l_input_context, x_output_context );

            --Multiply by the multiplier if it is other than 1.

            IF ( t_multiplier ( 1 ) <> 1 ) THEN

               emit_invokevirtual ( CASE push_numeric_literal ( t_multiplier ( 1 ))
                                    WHEN h_datatypes ('integer') THEN 'INumExprDef.prod(int)'
                                    ELSE 'INumExprDef.prod(double)'
                                    END );
            END IF;

            --Apply the rounding operator if any.

            IF ( t_rounding_op ( 1 ) <> h_templates ('none')) THEN

               emit_invokevirtual ( h_operators_1 ( t_rounding_op ( 1 )));

            END IF;
        END LOOP;

        --Sum up all the generated contributors as appropriate.

        IF ( t_contributor_index.COUNT = 2 ) THEN

           emit_invokevirtual ('INumExprDef.sum(INumExprDef)');

        ELSIF ( t_contributor_index.COUNT > 2 ) THEN

           create_array ( t_contributor_index.COUNT, h_javatypes ('INumExprDef'));
           populate_array ( t_contributor_index.COUNT );
           emit_invokevirtual ('IModelDef.sum(INumExprDef[])');

        END IF;

        IF ( t_accumulation_op ( 1 ) = h_templates ('subtractsfrom')) THEN

           emit_invokevirtual ('INumExprDef.neg()');

        END IF;

        combine_contributors ( l_count );
        x_output_context.context_type := const_context_accumulation;

     END generate_accumulator_template;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_compat_table ( p_compat_table   type_compat_table
                                     , p_input_context  IN expression_context
                                     , x_output_context IN OUT NOCOPY expression_context
                                     ) IS

        l_key               VARCHAR2(4000);
        l_exclude_key       VARCHAR2(4000);
        l_node_id           VARCHAR2(4000);
        l_expl_id           VARCHAR2(4000);
        l_option_id         NUMBER;

        l_participants      PLS_INTEGER;
        l_combinations      PLS_INTEGER;
        l_return            PLS_INTEGER;
        l_index             PLS_INTEGER;
        l_count             PLS_INTEGER;

        tl_sizes            type_integer_table;
        tl_excludes_id      type_number_table;
        tl_excludes         type_varchar4000_table;
        hl_options          type_datahashtable_table;

     BEGIN

        h_instancequantifiers.DELETE;
        t_instancequantifiers.DELETE;

        l_combinations := p_compat_table.combinations.COUNT;
        l_participants := p_compat_table.participants.COUNT;

        --This is to call IModelDef.addConstraint

        aload_model_def ( p_component_id );

        --This is to call IModelDef.compat. As model def is definitely in a local variable after
        --the previous call, this may be faster than dup.

        IF ( l_combinations > 0 ) THEN

            --We will need to call compat only if there are combinations.

            aload_model_def ( p_component_id );

        END IF;

        --Generate all the participants.

        FOR i IN 1..l_participants LOOP

           IF ( h_psnid_detailedtype ( p_compat_table.participants ( i ).ps_node_id ) NOT IN
                   ( h_psntypes ('optionfeature'), h_psntypes ('bomoptionclass'))) THEN
            -- Invalid participant in compatibility rule.  Valid participants are Option Feature or BOM Option Class nodes.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
            report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_CMR_INVALID_PART,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_compat_table');

           END IF;

           l_return := generate_path ( p_compat_table.participants ( i ).ps_node_id
                                     , p_compat_table.participants ( i ).model_ref_expl_id
                                     , p_input_context
                                     , x_output_context );

           IF ( l_return = const_quantifier_created ) THEN

              emit_invokevirtual('IInstanceQuantifier.getExprFromInstance(IExprDef)');

           END IF;

           --We will not need to store in a local variable if there is no excludes for this feature,
           --or if there are no combinations, so this can be optimized.

           l_key := TO_CHAR ( p_compat_table.participants ( i ).ps_node_id ) || '-' ||
                    TO_CHAR ( p_compat_table.participants ( i ).model_ref_expl_id );

           IF ( l_combinations > 0 ) THEN

              IF ( NOT local_variable_defined ( l_key )) THEN

                  copyto_local_variable ( l_key );

              END IF;

           ELSE

              --If there is no combinations, we will be generating an exclude, and do not need to
              --store the participants, instead, we need to apply the logical context.

              apply_context ( p_compat_table.participants ( i ).ps_node_id, l_return, const_context_logical );

           END IF;
        END LOOP;

        IF ( l_combinations = 0 ) THEN

           --There is no combinations. This is possible between a primary and an optional feature.
           --Generate exclude and return.

           --#<optimization>As an optimization, we could collect all optional features with no selections
           --before we go into generate_compat_table. There is no need to build compatibility tables for
           --such features and process them separately, we could just exclude all of them. This could be
           --implemented, but it's not a good idea to use Design Chart for such purposes anyway.

           emit_invokevirtual ('ILogicExprDef.excludes(ILogicExprDef)');
           set_reason_id ();
           add_constraint ();

           RETURN;
        END IF;

        --Create the array of participants that will be the first argument to compat.

        create_array ( l_participants, h_javatypes ('Object'));
        populate_array ( l_participants );

        --Now we need to create the second argument for the compat - a two-dimensional array of all combinations.
        --For non-bom, the second dimension is the array of the names of options comprising the combination. For
        --bom the type depends on the bom type. Mixed case is also possible.

        --Create an array for each combination. Note, that the correct order of options within the combinations
        --is guaranteed by the construction of p_compat_table.combinations

        FOR i IN 1..l_combinations LOOP
            FOR j IN 1..l_participants LOOP

               l_key := TO_CHAR ( p_compat_table.participants ( j ).ps_node_id ) || '-' ||
                        TO_CHAR ( p_compat_table.participants ( j ).model_ref_expl_id );

               l_option_id := p_compat_table.combinations ( i )( j ).ps_node_id;
               l_index := h_psnid_backindex ( l_option_id );

               IF ( t_psn_psnodetype ( l_index ) = h_psntypes ('option')) THEN

                  push_variable_name ( l_option_id );

               ELSE

                  --The parent is bom. The following approach should work for all kinds of options
                  --including references.

                  IF ( h_psnid_devlprojectid ( l_option_id ) = p_component_id ) THEN

                     haload_object ( l_option_id , 1 );

                  ELSE

                     --push_variable assumes that the parent is on the stack if the variable is remote.
                     --Note that we need the participant in the local context and we won't be calling
                     --getVarRef on it therefore we don't neef to dup the parent as push_variable does.

                     aload_context_node ( l_key, const_context_generic );

                     emit_invokevirtual ( 'ISingletonExprDef.getType()');
                     push_variable_name ( l_option_id );
                     emit_invokevirtual ( 'IModelDef.getVar(String)');

                  END IF;
               END IF;

               --Mark that this option participates in a combination.

               hl_options ( j )( TO_CHAR ( l_option_id )) := 1;

            END LOOP;

            create_array ( l_participants, h_javatypes ('Object'));
            populate_array ( l_participants );

        END LOOP;

        --Create two-dimensional array and populate the first dimension.

        tl_sizes ( 1 ) := l_combinations;
        tl_sizes ( 2 ) := l_participants;

        create_multi_array ( tl_sizes, h_javatypes ('Object'));
        populate_array ( l_combinations );

        --Finally call the compat to generate the constraint.

        emit_invokevirtual ('IModelDef.compat(Object[], Object[][])');

        set_reason_id ();
        add_constraint ();

        --Now we need to generate all the exclude constraints for the options that don't
        --participate in compat.

        FOR i IN 1..l_participants LOOP

           --Collect all the options that are not in the combinations.

           l_node_id := TO_CHAR ( p_compat_table.participants ( i ).ps_node_id );
           l_expl_id := TO_CHAR ( p_compat_table.participants ( i ).model_ref_expl_id );

           l_key := l_node_id || '-' || l_expl_id;

           l_index := h_psnid_backindex ( l_node_id );

           IF ( h_psnid_numberofchildren ( l_node_id ) <> hl_options ( i ).COUNT ) THEN

              --Number of children is different from the number of options that participate
              --in combinations, need to generate exclude. Note that this condition work in
              --all cases, bom and non-bom, as non-bom children of a bom are considered as
              --participating options - Developer allows to select them for combinations.

              --We will be adding another contraint which may have it's own ForAll.

              h_instancequantifiers.DELETE;
              t_instancequantifiers.DELETE;

              --Also, we need one more model def to call addConstraint.

              aload_model_def ( p_component_id );

              --All children directly follow the participant in the structure.

              l_index := l_index + 1;
              l_count := 0;

              --The participant cannot be a bom reference, so we don't have to use is_bom.

              IF ( NOT is_bom_node ( l_index )) THEN

                 --This is a feature.
                 --Put the participant on stack for whatever method we are going to call.

                 aload_context_node ( l_key, const_context_generic );

                 WHILE ( l_index <= h_psnid_lastchildindex ( l_node_id )) LOOP

                    IF ( NOT hl_options ( i ).EXISTS ( TO_CHAR ( t_psn_psnodeid ( l_index )))) THEN

                       --Push option name as a parameter to intersect.

                       push_variable_name ( t_psn_psnodeid ( l_index ));
                       l_count := l_count + 1;

                    END IF;

                    l_index := l_index + 1;

                 END LOOP;

                 IF ( l_count = 1 ) THEN

                    --Just one option, generate contains instead of intersects.

                    emit_invokevirtual ('ISetExprDef.contains(Object)');

                 ELSE

                    create_array ( l_count, h_javatypes ('Object'));
                    populate_array ( l_count );
                    emit_invokevirtual ('ISetExprDef.intersects(Object[])');

                 END IF;

              ELSE

                 tl_excludes_id.DELETE;

                 --The participant is a bom. All children still directly follow the participant in
                 --the structure, but there can also be tokens, so we need to check the parent_id.

                 WHILE ( l_index <= h_psnid_lastchildindex ( l_node_id ) AND t_psn_parentid ( l_index ) = l_node_id ) LOOP

                    l_option_id := t_psn_psnodeid ( l_index );

                    IF ( NOT hl_options ( i ).EXISTS ( TO_CHAR ( l_option_id ))) THEN

                       l_count := l_count + 1;
                       tl_excludes_id ( l_count ) := l_option_id ;

                    END IF;

                    l_index := l_index + 1;

                 END LOOP;

                 IF ( l_count > 2 ) THEN

                    --Need this to call AnyTrue.

                    aload_model_def ( p_component_id );

                 END IF;

                 FOR i IN 1..l_count LOOP

                    l_option_id := tl_excludes_id ( i );

                    aload_context_node ( l_key, const_context_generic );
                    push_variable ( l_option_id, 'ISingletonExprDef');
                    emit_invokevirtual ('ISingletonExprDef.getVarRef(IExprDef)');

                    apply_logical_context ( l_option_id, p_input_context.context_type );

                 END LOOP;

                 --If there's only one excluding option, do nothing. If there's two, call or, otherwise
                 --create an array an call AnyTrue.

                 IF ( l_count = 2 ) THEN

                    emit_invokevirtual ('ILogicExprDef.or(ILogicExprDef)');

                 ELSIF ( l_count > 2) THEN

                    create_array ( l_count, h_javatypes ('ILogicExprDef'));
                    populate_array ( l_count );
                    emit_invokevirtual ('IModelDef.any(ILogicExprDef[])');

                 END IF;
              END IF;

              tl_excludes.DELETE;
              l_index := 1;

              FOR j IN 1..l_participants LOOP

                 l_exclude_key := TO_CHAR ( p_compat_table.participants ( j ).ps_node_id ) || '-' ||
                                  TO_CHAR ( p_compat_table.participants ( j ).model_ref_expl_id );

                 IF ( l_exclude_key <> l_key ) THEN

                    tl_excludes ( l_index ) := l_exclude_key;
                    l_index := l_index + 1;

                 END IF;
              END LOOP;

              IF ( tl_excludes.COUNT > 2) THEN

                 --We need this to call AllTrue.

                 aload_model_def ( p_component_id );

              END IF;

              --Push all the participants to exclude on the stack.

              FOR j IN 1..tl_excludes.COUNT LOOP

                 aload_context_node ( tl_excludes ( j ), const_context_logical );

              END LOOP;

              --If there is only one participant for exclude, do nothing. If there's two, use 'and',
              --otherwise create an array and call AllTrue.

              IF ( tl_excludes.COUNT = 2 ) THEN

                 emit_invokevirtual ('ILogicExprDef.and(ILogicExprDef)');

              ELSIF ( tl_excludes.COUNT > 2 ) THEN

                 create_array ( tl_excludes.COUNT, h_javatypes ('ILogicExprDef'));
                 populate_array ( tl_excludes.COUNT );
                 emit_invokevirtual ('IModelDef.all(ILogicExprDef[])');

              END IF;

              --Now call the exclude and add the constraint.

              emit_invokevirtual ('ILogicExprDef.excludes(ILogicExprDef)');
              set_reason_id ();
              add_constraint ();

           END IF; --exclude required.
        END LOOP;
     END generate_compat_table;
     ----------------------------------------------------------------------------------
     --If p_emptiness is true, the table is allowed to be empty - no combinations. This
     --is true for the primary-optional compat tables.
     -- Scope: compile_constraints
     PROCEDURE verify_compatibility_table ( p_compat_table IN type_compat_table, p_emptiness IN BOOLEAN ) IS

        l_count       PLS_INTEGER;
        l_maximum     PLS_INTEGER;
        l_index       PLS_INTEGER;

        hl_parentid   type_data_hashtable;

     BEGIN

        IF ( p_compat_table.participants.COUNT < 2 ) THEN

           --#<verification>
           --This error can actually be raised here only for explicit compatibility rules.
           --For property-based and design-chart this will be caught earlier. Even if it
           --gets here for these types of rules, the message is still relevant.

           report_and_raise_rule_warning (
             p_text => CZ_UTILS.GET_TEXT(
                     CZ_FCE_W_CT_INCOMPLETE_RULE,
                     'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                     'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
             p_warning_location => 'verify_compatibility_table' );

        END IF;

        IF (( NOT p_emptiness ) AND p_compat_table.combinations.COUNT = 0 ) THEN

           --#<verification>
           --Compatibility table should be not empty. This error can be actually raised here only for
           --property-based compatibility rules, not for desing chart or explicit compatibility, so
           --the message can be significantly enhanced with property-based specifics specifics.

           -- No valid combinations. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
           report_and_raise_rule_warning (
                CZ_UTILS.GET_TEXT ( CZ_FCE_W_COMPAT_NO_COMB,
                  'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                  'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                'verify_compatibility_table'
               );

        END IF;

        --#<verification>
        --Only one of the participating features is allowed to have maximum > 1. When we call this procedure
        --on compat tables constructed for a design chart, there is a little overhead as the primary feature
        --participates in all these tables, and we end up checking its maximum several times.

        l_count := 0;

        FOR i IN 1..p_compat_table.participants.COUNT LOOP

           l_index := h_psnid_backindex ( TO_CHAR ( p_compat_table.participants ( i ).ps_node_id ));
           hl_parentid ( TO_CHAR ( t_psn_parentid ( l_index ))) := 1;

           l_maximum := CASE is_bom_node ( l_index ) WHEN TRUE THEN t_psn_maximumselected ( l_index ) ELSE t_psn_maximum ( l_index ) END;

           IF ( l_maximum IS NULL OR l_maximum > 1 ) THEN

              l_count := l_count + 1;

           END IF;
        END LOOP;

        --Verify for cyclic relationships in rule definition, when a participant is also a child of another
        --participant.

        FOR i IN 1..p_compat_table.participants.COUNT LOOP

           IF ( hl_parentid.EXISTS ( TO_CHAR ( p_compat_table.participants ( i ).ps_node_id ))) THEN
              -- Cyclic relationship between compatibility rule participants.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
              report_and_raise_rule_warning (
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_CT_CYCLIC_RELATION,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                p_warning_location => 'verify_compatibility_table' );

           END IF;
        END LOOP;

        IF ( l_count > 1 ) THEN
           -- Only one participant of a compatibility rule is allowed to have non-mutually-exclusive children.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_CT_ONLY_ONE_NON_MEXC,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'verify_compatibility_table');

        END IF;

        --#<verification>
        --All the combination tuples must have the same size.

        --#<optimization>
        --This verification may potentially be expensive if there are millions of combinations. As compatibility
        --table is built by the compiler itself this verification is not necessary and can be removed when there
        --are no bugs in this area.

        IF ( p_compat_table.combinations.COUNT > 0 ) THEN

           l_count := p_compat_table.combinations ( 1 ).COUNT;

           FOR i IN 1..p_compat_table.combinations.COUNT LOOP

              IF ( p_compat_table.combinations ( i ).COUNT <> l_count ) THEN

                 --Every combination should consist of the same number of options.

                 --#<should never happen>
                 -- 'Incorrect size of a compatible combination occurred. Compatibility Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                 report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                            CZ_FCE_SW_CT_INCORRECT_SIZE ),
                    p_warning_location => 'verify_compatibility_table');

              END IF;
           END LOOP;
        END IF;
     END verify_compatibility_table;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION get_table_reference ( p_data_type       IN NUMBER
                                  , p_iterator_index  IN PLS_INTEGER
                                  , p_property_index  IN PLS_INTEGER
                                  ) RETURN VARCHAR2 IS

        l_key   VARCHAR2(4000);

     BEGIN

        l_key := p_iterator_index || ')(i' || p_iterator_index || ')(' || p_property_index || ')';

        IF ( p_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

           RETURN 'cz_fce_compile.n_(' || l_key;

        ELSIF ( p_data_type = h_datatypes ('boolean')) THEN

           --We use integer representation of boolean as 0/1.

           RETURN 'cz_fce_compile.b_(' || l_key;

        ELSE

           --For all other type (text and translatable) we use text.

           RETURN 'cz_fce_compile.t_(' || l_key;

        END IF;
     END get_table_reference;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION lookup_parameter_value ( j IN PLS_INTEGER, l_property_id IN NUMBER ) RETURN VARCHAR2 IS

        l_parameter   type_iterator_value;

     BEGIN

        l_parameter := retrieve_parameter ( t_exp_argumentname ( j ));

        CASE l_parameter.value_type WHEN const_valuetype_literal THEN

           IF ( l_parameter.data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

              RETURN l_parameter.data_num_value;

           ELSE

              RETURN l_parameter.data_value;

           END IF;

        WHEN const_valuetype_node THEN

           RETURN get_property_value ( l_property_id, l_parameter.ps_node_id, l_parameter.model_ref_expl_id );

        ELSE
           -- 'In paramater stack invalid value type ^VALUE_TYPE associated with the parameter "^PARAM". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVAL_VAL_PARAMSTK,
                        'VALUE_TYPE', l_parameter.value_type,
                        'PARAM', t_exp_argumentname ( j ) ),
                p_warning_location => 'lookup_parameter_value');
           RETURN NULL;
        END CASE;
     END lookup_parameter_value;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_parameter ( j IN PLS_INTEGER
                                  , p_input_context  IN expression_context
                                  , x_output_context IN OUT NOCOPY expression_context
                                  ) IS

        l_parameter   type_iterator_value;

     BEGIN

        l_parameter := retrieve_parameter ( t_exp_argumentname ( j ));

        CASE l_parameter.value_type WHEN const_valuetype_literal THEN

           t_exp_datavalue ( j ) := l_parameter.data_value;
           t_exp_datanumvalue ( j ) := l_parameter.data_num_value;
           t_exp_datatype ( j ) := l_parameter.data_type;

           t_exp_exprtype ( j ) := h_exprtypes ('literal');

           generate_literal ( j, get_literal_value ( j ), l_parameter.data_type, p_input_context, x_output_context );

        WHEN const_valuetype_variable THEN

           aload_register ( l_parameter.data_value );

        WHEN const_valuetype_sysprop THEN

           generate_system_property ( l_parameter.data_num_value, l_parameter.ps_node_id, l_parameter.model_ref_expl_id, p_input_context, x_output_context );

        WHEN const_valuetype_node THEN

           t_exp_psnodeid ( j ) := l_parameter.ps_node_id;
           t_exp_modelrefexplid ( j ) := l_parameter.model_ref_expl_id;

           t_exp_exprtype ( j ) := h_exprtypes ('node');

           generate_structure_node ( j, p_input_context, x_output_context );

        WHEN const_valuetype_selection THEN

           t_exp_psnodeid ( j ) := l_parameter.ps_node_id;
           t_exp_modelrefexplid ( j ) := l_parameter.model_ref_expl_id;

           IF ( h_exprid_childrenindex.EXISTS ( TO_CHAR ( t_exp_exprnodeid ( j )))) THEN

              l_parameter.data_num_value := get_property_id ( h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( j ))));

           END IF;

           generate_selection ( j, l_parameter.data_num_value, p_input_context, x_output_context );

        ELSE
           -- 'In paramater stack invalid value type ^VALUE_TYPE associated with the parameter "^PARAM". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVAL_VAL_PARAMSTK,
                        'VALUE_TYPE', l_parameter.value_type,
                        'PARAM', t_exp_argumentname ( j ) ),
                p_warning_location => 'generate_parameter');

        END CASE;

        add_argument ( j );

     END generate_parameter;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION value_string ( j             IN PLS_INTEGER
                           , p_data_type   IN NUMBER
                           , p_num_value   IN VARCHAR2
                           , p_value       IN VARCHAR2 ) RETURN VARCHAR2 IS
     BEGIN

        IF ( p_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

           RETURN p_num_value;

        ELSIF ( p_data_type = h_datatypes ('text')) THEN

           RETURN '''' || p_value || '''';

        ELSIF ( p_data_type = h_datatypes ('boolean')) THEN

           --In cz_expression_nodes value of a boolean literal is represented by 0 or 1 in data_value.
           --Here we are trying to handle cases, when the user writes logical constants explicitly as
           --operands to logical operands, for example NOT FALSE.

           IF ( logical_context ( j, NULL )) THEN

              RETURN '(' || CASE p_value WHEN 0 THEN 'FALSE' ELSE 'TRUE' END || ')';

           ELSE

              RETURN p_value;

           END IF;

        ELSE

           RETURN NVL ( p_num_value, '''' || p_value || '''' );

        END IF;
     END value_string;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION parse_where_clause ( j                        IN PLS_INTEGER
                                 , p_rule_type              IN PLS_INTEGER
                                 , p_index_by_iterator      IN OUT NOCOPY type_data_hashtable
                                 , p_property_by_iterator   IN OUT NOCOPY type_datahashtable_table
                                 ) RETURN VARCHAR2 IS

        l_property_id         NUMBER;
        l_data_type           NUMBER;
        l_value               VARCHAR2(4000);
        l_key                 VARCHAR2(4000);
        l_expr_id             VARCHAR2(4000);

        l_index               PLS_INTEGER;
        l_iterator_index      PLS_INTEGER;
        l_property_index      PLS_INTEGER;

     BEGIN

       l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

       IF ( t_exp_exprtype ( j ) IN ( h_exprtypes ('argument'), h_exprtypes ('node'))) THEN

          IF ( p_rule_type = const_ruletype_compatible ) THEN

             --This will get the property_id appropriately for user or system property.

             IF ( expr_has_one_child ( l_expr_id )) THEN

                l_index := h_exprid_childrenindex ( l_expr_id );

             ELSE

                report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_SNODE_WHERE_LIMITS,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'parse_where_clause');

             END IF;

          END IF;

          IF ( h_exprid_childrenindex.EXISTS ( l_expr_id )) THEN

             l_property_id := get_property_id ( h_exprid_childrenindex ( l_expr_id ));

          ELSE

             --In a statement forall, iterator can participate in the where clause without any property applied.
             --In this case we use property_id = 0 and get data type from the parent operator.

             l_property_id := get_property_id ( j );

          END IF;

          get_property_info ( l_property_id, l_data_type, l_value );

       END IF;

       CASE t_exp_exprtype ( j ) WHEN h_exprtypes ('argument') THEN

          IF ( NOT p_index_by_iterator.EXISTS ( t_exp_argumentname ( j ))) THEN

             --This is an iterator from an outer forall, need to evaluate it to a constant.

             l_value := lookup_parameter_value ( j, l_property_id );
             RETURN value_string ( j, l_data_type, l_value, l_value );

          ELSE

             l_iterator_index := p_index_by_iterator ( t_exp_argumentname ( j ));
             l_key := TO_CHAR ( l_property_id );

             IF ( p_property_by_iterator.EXISTS ( l_iterator_index ) AND p_property_by_iterator ( l_iterator_index ).EXISTS ( l_key )) THEN

                l_property_index := p_property_by_iterator ( l_iterator_index )( l_key );

             ELSIF ( NOT p_property_by_iterator.EXISTS ( l_iterator_index )) THEN

                p_property_by_iterator ( l_iterator_index )( l_key ) := 1;
                l_property_index := 1;

             ELSE

                l_property_index := p_property_by_iterator ( l_iterator_index ).COUNT + 1;
                p_property_by_iterator ( l_iterator_index )( l_key ) := l_property_index;

             END IF;

             --Depending on the data type, generate reference to corresponding table.

             RETURN get_table_reference ( l_data_type, l_iterator_index, l_property_index );

          END IF;

       WHEN h_exprtypes ('node') THEN

          l_value := get_property_value ( l_property_id, t_exp_psnodeid ( j ), t_exp_modelrefexplid ( j ));
          RETURN value_string ( j, l_data_type, l_value, l_value );

       WHEN h_exprtypes ('literal') THEN

          RETURN value_string ( j, t_exp_datatype ( j ), TO_CHAR ( t_exp_datanumvalue ( j )), t_exp_datavalue ( j ));

       WHEN h_exprtypes ('operator') THEN

          IF ( t_exp_templateid ( j ) IN
                  ( h_templates ('and')
                  , h_templates ('or')
                  , h_templates ('equals')
                  , h_templates ('notequals')
                  , h_templates ('gt')
                  , h_templates ('lt')
                  , h_templates ('ge')
                  , h_templates ('le')
                  , h_templates ('add')
                  , h_templates ('subtract')
                  , h_templates ('multiply')
                  , h_templates ('div')
                  , h_templates ('doesnotbeginwith')
                  , h_templates ('doesnotendwith')
                  , h_templates ('doesnotcontain')
                  , h_templates ('notlike')
                  , h_templates ('concatenate')
                  , h_templates ('beginswith')
                  , h_templates ('endswith')
                  , h_templates ('contains')
                  , h_templates ('like')
                  , h_templates ('matches')
                  , h_templates ('textequals')
                  , h_templates ('textnotequals')
                  )) THEN

              IF ( expr_has_two_children ( l_expr_id )) THEN

                 l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                 report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_TWO_CHILD,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'parse_where_clause');

              END IF;

              RETURN parse_operator ( parse_where_clause ( l_index, p_rule_type, p_index_by_iterator, p_property_by_iterator )
                                    , t_exp_templateid ( j )
                                    , parse_where_clause ( l_index + 1, p_rule_type, p_index_by_iterator, p_property_by_iterator )
                                    );

          ELSIF ( t_exp_templateid ( j ) IN
                  ( h_templates ('totext')
                  , h_templates ('not')
                  , h_templates ('neg')
                  )) THEN

              IF ( expr_has_one_child ( l_expr_id )) THEN

                  l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                  report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                               'EXPR_ID', l_expr_id ),
                    p_warning_location => 'parse_where_clause');

              END IF;

              RETURN parse_operator ( parse_where_clause ( l_index, p_rule_type, p_index_by_iterator, p_property_by_iterator )
                                    , t_exp_templateid ( j ), NULL );

          ELSE

              -- 'Unknown operator in the WHERE clause. Rule "^RULE_NAME" in the Model "^MODEL_NAME" ignored.';

              report_and_raise_rule_sys_warn(
                GET_NOT_TRANSLATED_TEXT(CZ_FCE_SW_UKNOWN_OP_IN_COMPAT),
                'parse_where_clause'
               );
               RETURN NULL;

          END IF;

       ELSE

          -- 'Unknown expression node type in the WHERE clause, expr_node_id "^EXPR_ID". Rule ^RULE_NAME in the model ^MODEL_NAME ignored.';

          report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVAL_E_ID_IN_WHERE,
                        'EXPR_ID', l_expr_id ),
                p_warning_location => 'parse_where_clause');
          RETURN NULL;

       END CASE;
     END parse_where_clause;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_statement_forall ( j IN PLS_INTEGER
                                         , p_input_context  IN expression_context
                                         , x_output_context IN OUT NOCOPY expression_context
                                         ) IS

        l_index                  PLS_INTEGER;
        l_expr_index             PLS_INTEGER;
        l_expression_index       PLS_INTEGER;
        l_where_index            PLS_INTEGER;
        l_property_index         PLS_INTEGER;
        l_count                  PLS_INTEGER;

        l_parsed                 VARCHAR2(32000);
        l_expr_id                VARCHAR2(4000);
        l_key                    VARCHAR2(4000);
        l_value                  VARCHAR2(4000);

        l_data_type              NUMBER;
        l_property_id            NUMBER;

        h_index_by_iterator      type_data_hashtable;
        h_property_by_iterator   type_datahashtable_table;
        t_iterator_table         type_iteratortable_table;
        l_iterator               type_iterator_table;
        t_argument_table         type_varchar4000_table;
        h_distinct_values        type_data_hashtable;

        l_compat                 type_compat_table;

        l_distinct               BOOLEAN;
        l_embedded               BOOLEAN;
        l_iterator_collect       BOOLEAN;
     ----------------------------------------------------------------------------------
     -- Scope: generate_statement_forall
     FUNCTION generate_iterator ( j IN PLS_INTEGER ) RETURN type_iterator_table IS

        l_expr_id          VARCHAR2(4000);
        l_property_id      NUMBER;
        l_data_type        NUMBER;
        l_value            VARCHAR2(4000);

        l_index            PLS_INTEGER;
        l_count            PLS_INTEGER;
        l_child            PLS_INTEGER;
        l_node_index       PLS_INTEGER;

        l_iterator         type_iterator_table;
        t_children         type_iteratornode_table;

        l_input_context    expression_context;
        l_output_context   expression_context;

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

          -- 'Incomplete forall rule, empty iterator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_INCOMPLETE_FORALL ),
                p_warning_location => 'generate_iterator');

        END IF;

        WHILE ( t_exp_exprparentid.EXISTS ( l_index ) AND t_exp_exprparentid ( l_index ) = t_exp_exprnodeid ( j )) LOOP

          l_count := l_iterator.COUNT + 1;
          t_children.DELETE;

          l_expr_id := TO_CHAR ( t_exp_exprnodeid ( l_index ));

          IF ( t_exp_exprtype ( l_index ) IN ( h_exprtypes ('forall'), h_exprtypes ('foralldistinct'))) THEN

              generate_statement_forall ( l_index, l_input_context, l_output_context );

              FOR i IN 1..c_.combinations.COUNT LOOP

                 --This is a COLLECT in the iterator, there can be only one iterator in it and the expression
                 --should resolve to a literal.

                 l_iterator ( l_count ) := c_.combinations ( i )( 1 );
                 l_count := l_count + 1;

              END LOOP;

          ELSIF ( h_exprid_childrenindex.EXISTS ( l_expr_id )) THEN

             l_child := h_exprid_childrenindex ( l_expr_id );

             --A strange way to identify options operator or property.

             IF (( t_exp_exprtype ( l_index ) = h_exprtypes ('operator') AND t_exp_templateid ( l_index ) = h_templates ('optionsof')) OR
                 ( t_exp_exprtype ( l_child ) = h_exprtypes ('systemproperty') AND t_exp_templateid ( l_child ) = h_templates ('options'))) THEN

                l_node_index := CASE t_exp_exprtype ( l_index ) WHEN h_exprtypes ('operator') THEN l_child ELSE l_index END;
                t_children := explode_node_children ( t_exp_psnodeid ( l_node_index ), t_exp_modelrefexplid ( l_node_index ), FALSE );

                FOR i IN 1..t_children.COUNT LOOP

                   l_iterator ( l_count ).value_type := const_valuetype_node;
                   l_iterator ( l_count ).ps_node_id := t_children ( i ).ps_node_id;
                   l_iterator ( l_count ).model_ref_expl_id := t_children ( i ).model_ref_expl_id;

                   l_count := l_count + 1;

                END LOOP;

             ELSE

                IF ( t_exp_psnodeid ( l_index ) IS NULL ) THEN

                   --User or system property can be applied only to a structure node.

                   report_and_raise_rule_warning(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_PROP_USAGE),
                        p_warning_location => 'generate_iterator');

                END IF;

                l_property_id := get_property_id ( l_child );

                IF ( h_runtime_properties.EXISTS ( l_property_id )) THEN

                   --Bug #7348938. We used to generate the expression right here and store the result
                   --in iterator value of type variable. Later this variable would be aloaded when
                   --generating the forall expression. We could do that because such iterator values
                   --cannot participate in the WHERE clause and so we could forget about them until
                   --the forall expression is generated. However, this does not work for accumulator
                   --rules because target should be generated BEFORE contributors, and so we cannot
                   --generate contributors here.

                   l_iterator ( l_count ).value_type := const_valuetype_sysprop;
                   l_iterator ( l_count ).ps_node_id := t_exp_psnodeid ( l_index );
                   l_iterator ( l_count ).model_ref_expl_id := t_exp_modelrefexplid ( l_index );
                   l_iterator ( l_count ).data_num_value := l_property_id;

                ELSIF ( l_property_id = h_templates ('selection')) THEN

                   l_iterator ( l_count ).value_type := const_valuetype_selection;
                   l_iterator ( l_count ).ps_node_id := t_exp_psnodeid ( l_index );
                   l_iterator ( l_count ).model_ref_expl_id := t_exp_modelrefexplid ( l_index );

                   l_child := l_child + 1;

                   IF ( t_exp_exprparentid.EXISTS ( l_child ) AND t_exp_exprparentid ( l_child ) = t_exp_exprnodeid ( l_index )) THEN

                      l_iterator ( l_count ).data_num_value := get_property_id ( l_child );

                   END IF;

                ELSE

                   l_iterator ( l_count ).value_type := const_valuetype_literal;

                   get_property_info ( l_property_id, l_data_type, l_value );
                   l_value := get_property_value ( l_property_id, t_exp_psnodeid ( l_index ), t_exp_modelrefexplid ( l_index ));

                   l_iterator ( l_count ).data_type := l_data_type;

                   IF ( l_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                      l_iterator ( l_count ).data_num_value := TO_NUMBER ( l_value );

                   ELSE

                      l_iterator ( l_count ).data_value := l_value;

                   END IF;
                END IF;
             END IF;

          ELSIF ( t_exp_exprtype ( l_index ) = h_exprtypes ('literal')) THEN

             l_iterator ( l_count ).value_type := const_valuetype_literal;
             l_iterator ( l_count ).data_type := t_exp_datatype ( l_index );

             IF ( t_exp_datatype ( l_index ) IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                l_iterator ( l_count ).data_num_value := t_exp_datanumvalue ( l_index );

             ELSE

                l_iterator ( l_count ).data_value := t_exp_datavalue ( l_index );

             END IF;

          ELSIF ( t_exp_exprtype ( l_index ) = h_exprtypes ('node')) THEN

             l_iterator ( l_count ).value_type := const_valuetype_node;
             l_iterator ( l_count ).ps_node_id := t_exp_psnodeid ( l_index );
             l_iterator ( l_count ).model_ref_expl_id := t_exp_modelrefexplid ( l_index );

          ELSE

             --#<should never happen>
             report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVALID_EXPR_NODE,
                        'EXPR_TYPE', t_exp_exprtype ( l_index ) ),
                p_warning_location => 'generate_iterator');

          END IF;

          l_index := l_index + 1;

        END LOOP;

        RETURN l_iterator;
     END generate_iterator;
     ----------------------------------------------------------------------------------
     BEGIN

        l_distinct := ( t_exp_exprtype ( j ) = h_exprtypes ('foralldistinct'));
        l_embedded := ( t_exp_exprparentid ( j ) IS NOT NULL );
        l_iterator_collect := ( l_embedded AND t_exp_exprtype ( h_exprid_backindex ( TO_CHAR ( t_exp_exprparentid ( j )))) = h_exprtypes ('iterator'));

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                            'EXPR_ID', l_expr_id ),
                p_warning_location => 'generate_statement_forall');

        END IF;

        l_where_index := 0;

        --Find iterator definition indexes and WHERE clause index, and generate all iterators.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_exprtype ( l_expr_index ) WHEN h_exprtypes ('iterator') THEN

              h_index_by_iterator ( t_exp_argumentname ( l_expr_index )) := h_index_by_iterator.COUNT + 1;

              t_iterator_table ( t_iterator_table.COUNT + 1 ) := generate_iterator ( l_expr_index );
              t_argument_table ( t_argument_table.COUNT + 1 ) := t_exp_argumentname ( l_expr_index );

           WHEN h_exprtypes ('where') THEN

              IF ( expr_has_children ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )))) THEN

                l_where_index := h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )));

              ELSE

                report_and_raise_rule_sys_warn (
                      p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                                  'EXPR_ID', TO_CHAR ( t_exp_exprnodeid ( l_expr_index ))),
                      p_warning_location => 'generate_logic_template');

              END IF;

           ELSE

              l_expression_index := l_expr_index;

           END CASE;
        END LOOP;

        IF ( l_where_index <> 0 ) THEN

           l_parsed := parse_where_clause ( l_where_index, const_ruletype_forall, h_index_by_iterator, h_property_by_iterator );

        END IF;

        IF ( t_iterator_table.COUNT = 0 ) THEN

           --#<should never happen>
           -- 'Incomplete forall rule, empty iterator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';

           report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INCOMPLETE_FORALL ),
                p_warning_location => 'generate_statement_forall');

        END IF;

        IF ( l_distinct AND t_iterator_table.COUNT > 1 ) THEN

           -- DISTINCT COLLECT and FOR ALL operations are not supported when there is more than one iterator.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT (
                        CZ_FCE_W_MORE_THAN_ONE_IT_LIM,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                    'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH (p_component_id, p_model_path)),
                p_warning_location => 'generate_statement_forall');

        END IF;

        c_.participants.DELETE;
        c_.combinations.DELETE;

        o_.DELETE;
        n_.DELETE;
        s_.DELETE;
        t_.DELETE;
        b_.DELETE;

        FOR i IN 1..t_iterator_table.COUNT LOOP

           s_( i ) := t_iterator_table ( i ).COUNT;

           l_iterator := t_iterator_table ( i );
           o_( i ) := l_iterator;

           FOR ii IN 1..s_( i ) LOOP

              IF ( l_parsed IS NOT NULL AND h_property_by_iterator.EXISTS ( i )) THEN

                 --h_property_by_iterator ( i ) value would exist only for iterators that are referenced
                 --in the WHERE clause. If an iterator is not referenced, we don't need it here.

                 l_key := h_property_by_iterator ( i ).FIRST;

                 WHILE ( l_key IS NOT NULL ) LOOP

                    l_property_id := TO_NUMBER ( l_key );
                    l_property_index := h_property_by_iterator ( i )( l_key );
                    get_property_info ( l_property_id, l_data_type, l_value );

                    --Populate corresponding arrays if there is a WHERE clause.

                    IF ( l_property_id IN ( h_datatypes ('decimal'), h_datatypes ('boolean'), h_datatypes ('text'))) THEN

                       --Iterator is referenced without any property applied.

                       IF ( l_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                          --The iterator was referenced in the where clause without explicit property applied.
                          --For now, allow this only for literals. Later we can set up applying 'default'
                          --properties for nodes. However, applying default would be equivalent to allowing
                          --dynamic properties in the where clause, because default property is either State()
                          --or Quantity(), so we probably will not do that.

                          IF ( l_iterator ( ii ).value_type <> const_valuetype_literal ) THEN

                             -- Incorrect COLLECT or FOR ALL Rule: The conditional expression in the WHERE clause must be static. A dynamic source for
                             -- a value provided for iterator ^ITER was detected.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

                             report_and_raise_rule_warning(
                                p_text => CZ_UTILS.GET_TEXT (
                                        CZ_FCE_W_DYNAMIC_ITERATOR,
                                   'ITER', t_argument_table ( i ),
                                   'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                                   'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path )),
                                p_warning_location => 'generate_statement_forall');

                          END IF;

                          --Need the case below because boolean literals can participate in numeric context
                          --and so the data type of the implicit property would be assumed as numeric.

                          n_( i )( ii )( l_property_index ) :=
                                 CASE l_iterator ( ii ).data_type
                                     WHEN h_datatypes ('boolean') THEN TO_NUMBER ( l_iterator ( ii ).data_value )
                                     ELSE l_iterator ( ii ).data_num_value END;

                       ELSIF ( l_data_type = h_datatypes ('boolean')) THEN

                          --We use integer representation of boolean as 0/1.

                          b_( i )( ii )( l_property_index ) := TO_NUMBER ( l_iterator ( ii ).data_value );

                       ELSE

                          --For all other types (text and translatable) we use text.

                          t_( i )( ii )( l_property_index ) := l_iterator ( ii ).data_value;

                       END IF;

                    ELSE

                       --This is an actual system or user property. It can only be applied to a node.
                       --Later this verification can be removed.

                       IF ( l_iterator ( ii ).value_type <> const_valuetype_node ) THEN

                          --#<should never happen>
                          -- 'Found invalid iterator value type "^VALUE". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                          report_and_raise_rule_sys_warn(
                                p_text => GET_NOT_TRANSLATED_TEXT(
                                        CZ_FCE_SW_INVALID_IT_VALUE,
                                        'VALUE', l_iterator ( ii ).value_type),
                                p_warning_location => 'generate_statement_forall');

                       END IF;

                       l_value := get_property_value ( l_property_id, l_iterator ( ii ).ps_node_id, l_iterator (ii).model_ref_expl_id );

                       IF ( l_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                          n_( i )( ii )( l_property_index ) := TO_NUMBER ( l_value );

                       ELSIF ( l_data_type = h_datatypes ('boolean')) THEN

                          --We use integer representation of boolean as 0/1.

                          b_( i )( ii )( l_property_index ) := TO_NUMBER ( l_value );

                       ELSE

                          --For all other types (text and translatable) we use text.

                          t_( i )( ii )( l_property_index ) := l_value;

                       END IF;
                    END IF;

                    l_key := h_property_by_iterator ( i ).NEXT ( l_key );

                 END LOOP;
              END IF;
           END LOOP;
        END LOOP;

        EXECUTE IMMEDIATE build_executable ( t_iterator_table.COUNT, l_parsed );

        IF ( l_iterator_collect ) THEN

           --This is a collect within an iterator of an outer forall, it can only have single
           --iterator, and the expression can only be the iterator with or without static
           --property applied.

           IF ( h_exprid_childrenindex.EXISTS ( t_exp_exprnodeid ( l_expression_index ))) THEN

               l_property_id := get_property_id ( h_exprid_childrenindex ( t_exp_exprnodeid ( l_expression_index )));
               get_property_info ( l_property_id, l_data_type, l_value );

               FOR i IN 1..c_.combinations.COUNT LOOP

                   l_value := get_property_value ( l_property_id, c_.combinations ( i )( 1 ).ps_node_id, c_.combinations ( i )( 1 ).model_ref_expl_id  );

                   c_.combinations ( i )( 1 ).value_type := const_valuetype_literal;
                   c_.combinations ( i )( 1 ).data_type := l_data_type;

                   IF ( l_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                      c_.combinations ( i )( 1 ).data_num_value := TO_NUMBER ( l_value );

                   ELSE

                      c_.combinations ( i )( 1 ).data_value := l_value;

                   END IF;
               END LOOP;

               IF ( l_distinct ) THEN

                  l_compat := c_;
                  c_.combinations.DELETE;

                  l_count := 1;

                  FOR i IN 1..l_compat.combinations.COUNT LOOP

                      IF ( l_compat.combinations ( i )( 1 ).value_type <> const_valuetype_literal ) THEN
                          -- 'Found non-literal value type in COLLECT DISTINCT. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                          report_and_raise_rule_sys_warn(
                            p_text => GET_NOT_TRANSLATED_TEXT(
                                    CZ_FCE_SW_NON_LIT_IN_COLLECT),
                            p_warning_location => 'generate_statement_forall');

                      END IF;

                      IF ( l_compat.combinations ( i )( 1 ).data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                         l_value := TO_CHAR ( l_compat.combinations ( i )( 1 ).data_num_value );

                      ELSE

                         l_value := l_compat.combinations ( i )( 1 ).data_value;

                      END IF;

                      IF ( NOT h_distinct_values.EXISTS ( l_value )) THEN

                         c_.combinations ( l_count )( 1 ) := l_compat.combinations ( i )( 1 );
                         l_count := l_count + 1;

                         h_distinct_values ( l_value ) := 1;

                      END IF;
                  END LOOP;
               END IF;
           END IF;

           RETURN;
        END IF;

        --Need to copy the result to the local table because of the possibility of embedding.

        l_compat := c_;

        IF ( l_embedded ) THEN

           --The forall is not on the top level so it is a collect. We will not add generated
           --expressions as constrains just generate them as arguments to the parent operator,
           --therefore we need to adjust the number of children of this operator.

           l_expr_id := TO_CHAR ( t_exp_exprparentid ( j ));
           h_exprid_numberofchildren ( l_expr_id ) := h_exprid_numberofchildren ( l_expr_id ) - 1;

        END IF;

        l_count := h_parameter_stack.COUNT + 1;

        FOR i IN 1..l_compat.combinations.COUNT LOOP

           --Put each value from the combination into the parameter stack.

           FOR ii IN 1..t_iterator_table.COUNT LOOP

              h_parameter_stack ( l_count )( t_argument_table ( ii )) := l_compat.combinations ( i )( ii );

           END LOOP;

           clear_argument_table ();

           IF ( NOT l_embedded ) THEN

              --This is a top-level forall, generate it as a set of constraints.

              h_instancequantifiers.DELETE;
              t_instancequantifiers.DELETE;

              --Put the ModelDef on the stack for the last addConstraint call.

              aload_model_def ( p_component_id );
              generate_expression ( l_expression_index, p_input_context, x_output_context );

              IF (l_output_context.context_type NOT IN ( const_context_accumulation, const_context_heuristics )) THEN

                 set_reason_id ();
                 add_constraint ();

              ELSE

                 --In case of accumulator rule, we need to remove the model def, put on the stack
                 --before expression generation, as we did not add the constraint yet.
                 --In the case of ForAll all the constraints are already added so we also need to
                 --remove the model def.

                 emit_pop ( 1 );

              END IF;

           ELSE

              --The forall is not on the top level, therefore it is a collect.

              generate_expression ( l_expression_index, p_input_context, x_output_context );
              h_exprid_numberofchildren ( l_expr_id ) := h_exprid_numberofchildren ( l_expr_id ) + 1;

           END IF;

           --When generating parameters, we change the expression type of parameter node to the
           --type of the retrieved argument and keep it during the expression generation. After
           --that we need to restore the argument type for the next iteration.

           restore_arguments ();

        END LOOP;

        h_parameter_stack.DELETE ( l_count );
        x_output_context.context_type := const_context_forall;

     END generate_statement_forall;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_compatible ( j IN PLS_INTEGER
                                   , p_input_context  IN expression_context
                                   , x_output_context IN OUT NOCOPY expression_context
                                   ) IS

        l_property_index         PLS_INTEGER;
        l_data_type              NUMBER;
        l_property_id            NUMBER;
        l_key                    VARCHAR2(4000);
        l_value                  VARCHAR2(4000);
        l_parsed                 VARCHAR2(32000);

        h_index_by_iterator      type_data_hashtable;
        h_property_by_iterator   type_datahashtable_table;
        t_children               type_iteratornode_table;
     ----------------------------------------------------------------------------------
     -- Scope: generate_compatible
     FUNCTION parse_template_application ( j IN PLS_INTEGER ) RETURN VARCHAR2 IS

        l_index               PLS_INTEGER;
        l_expr_index          PLS_INTEGER;
        l_operator            PLS_INTEGER;
        l_expr_id             VARCHAR2(4000);

        l_property_id         NUMBER;
        l_data_type           NUMBER;
        l_def_value           VARCHAR2(4000);

        l_left_key            VARCHAR2(4000);
        l_right_key           VARCHAR2(4000);

        l_if                  VARCHAR2(32000);

     BEGIN

        --This procedure parses a simple Property-based Compatibility template application
        --and prepares memory tables necessary for generation.
        --It returns the 'if' condition generated from the 'where' clause.

        --The template application specifies the following parameters:

        -- param_index = 1: first participant
        -- param_index = 2: property applied to the first participant
        -- param_index = 3: compatibility operator
        -- param_index = 4: second participant
        -- param_index = 5: property applied to the second participant

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          -- Incomplete simple Property-based Compatibility rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
          report_and_raise_rule_warning (
                p_text => CZ_UTILS.GET_TEXT(
                                CZ_FCE_W_INCOMPLETE_PROPBASED,
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                p_warning_location => 'parse_template_application');

        END IF;

        --Parse the template application.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_paramindex ( l_expr_index )

               WHEN 1 THEN

                  --First participant.
                  -- 'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                  IF ( t_exp_exprtype ( l_expr_index ) <> h_exprtypes ('node')) THEN

                     report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_ARG_PARAM,
                                'EXPR_TYPE', t_exp_exprtype ( l_expr_index ),
                                'ARG_LOCATION', 'first' ),
                        p_warning_location => 'parse_template_application');

                  END IF;

                  c_.participants ( 1 ).ps_node_id := t_exp_psnodeid ( l_expr_index );
                  c_.participants ( 1 ).model_ref_expl_id := t_exp_modelrefexplid ( l_expr_index );

               WHEN 2 THEN

                  --First property.

                  IF ( t_exp_exprtype ( l_expr_index ) NOT IN ( h_exprtypes ('literal'), h_exprtypes ('property'), h_exprtypes ('systemproperty'))) THEN
                     -- 'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_ARG_PARAM,
                                'EXPR_TYPE', t_exp_exprtype ( l_expr_index ),
                                'ARG_LOCATION', 'second' ),
                        p_warning_location => 'parse_template_application');

                  ELSIF ( t_exp_exprtype ( l_expr_index ) = h_exprtypes ('literal') AND t_exp_propertyid ( i ) IS NULL ) THEN
                     -- 'Property is not defined. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                            p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_PROP_NOT_DEFINED,
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name)),
                            p_warning_location => 'parse_template_application');

                  END IF;

                  l_property_id := get_property_id ( l_expr_index );
                  get_property_info ( l_property_id, l_data_type, l_def_value );

                  h_property_by_iterator ( 1 )( TO_CHAR ( l_property_id )) := 1;
                  l_left_key := get_table_reference ( l_data_type, 1, 1 );

               WHEN 3 THEN

                  --The operator is specified by name.

                  IF ( t_exp_exprtype ( l_expr_index ) NOT IN ( h_exprtypes ('template'), h_exprtypes ('operator'), h_exprtypes ('operatorbyname'))) THEN
                     -- 'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_ARG_PARAM,
                                'EXPR_TYPE', t_exp_exprtype ( l_expr_index ),
                                'ARG_LOCATION', 'third' ),
                        p_warning_location => 'parse_template_application');

                  END IF;

                  l_operator := CASE t_exp_exprtype ( l_expr_index )
                       WHEN h_exprtypes ('operatorbyname') THEN h_templates ( LOWER ( t_exp_argumentname ( l_expr_index )))
                       ELSE t_exp_templateid ( l_expr_index ) END;

               WHEN 4 THEN

                  --Second participant.

                  IF ( t_exp_exprtype ( l_expr_index ) <> h_exprtypes ('node')) THEN
                     -- 'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_ARG_PARAM,
                                'EXPR_TYPE', t_exp_exprtype ( l_expr_index ),
                                'ARG_LOCATION', 'forth' ),
                        p_warning_location => 'parse_template_application');

                  END IF;

                  c_.participants ( 2 ).ps_node_id := t_exp_psnodeid ( l_expr_index );
                  c_.participants ( 2 ).model_ref_expl_id := t_exp_modelrefexplid ( l_expr_index );

               WHEN 5 THEN

                  --Second property.

                  IF ( t_exp_exprtype ( l_expr_index ) NOT IN ( h_exprtypes ('literal'), h_exprtypes ('property'), h_exprtypes ('systemproperty'))) THEN
                     -- 'Invalid parameter of type "^EXPR_TYPE" specified for the "^ARG_LOCATION" argument of the property-based compatibility template application. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INVALID_ARG_PARAM,
                                'EXPR_TYPE', t_exp_exprtype ( l_expr_index ),
                                'ARG_LOCATION', 'fifth' ),
                        p_warning_location => 'parse_template_application');

                  ELSIF ( t_exp_exprtype ( l_expr_index ) = h_exprtypes ('literal') AND t_exp_propertyid ( i ) IS NULL ) THEN
                     -- 'Property is not defined. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
                     report_and_raise_rule_sys_warn(
                            p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_PROP_NOT_DEFINED),
                            p_warning_location => 'parse_template_application');

                  END IF;

                  l_property_id := get_property_id ( l_expr_index );
                  get_property_info ( l_property_id, l_data_type, l_def_value );

                  h_property_by_iterator ( 2 )( TO_CHAR ( l_property_id )) := 1;
                  l_right_key := get_table_reference ( l_data_type, 2, 1 );

           END CASE;
        END LOOP;

        RETURN parse_operator ( l_left_key, l_operator, l_right_key );
     END parse_template_application;
     ----------------------------------------------------------------------------------
     -- Scope: generate_compatible
     FUNCTION parse_statement_compatible ( j IN PLS_INTEGER ) RETURN VARCHAR2 IS

        l_index               PLS_INTEGER;
        l_expr_index          PLS_INTEGER;
        l_participant_index   PLS_INTEGER;
        l_where_index         PLS_INTEGER;
        l_count               PLS_INTEGER;

        l_if                  VARCHAR2(32000);
        l_expr_id             VARCHAR2(4000);

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_children ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id ) - 1;

        ELSE

          report_and_raise_rule_sys_warn (
                p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                            'EXPR_ID', l_expr_id ),
                p_warning_location => 'parse_statement_compatible');

        END IF;

        l_where_index := 0;

        --This is a COMPATIBLE rule. Find iterator definition indexes and WHERE clause index.

        FOR i IN 1..h_exprid_numberofchildren ( l_expr_id ) LOOP

           l_expr_index := l_index + i;

           CASE t_exp_exprtype ( l_expr_index ) WHEN h_exprtypes ('iterator') THEN

              l_count := h_index_by_iterator.COUNT + 1;
              h_index_by_iterator ( t_exp_argumentname ( l_expr_index )) := l_count;

              --For A COMPATIBLE, a child of an iterator is always a participant.

              IF ( expr_has_one_child ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )))) THEN

                l_participant_index := h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )));

              ELSE

                report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                          'EXPR_ID', TO_CHAR ( t_exp_exprnodeid ( l_expr_index ))),
                  p_warning_location => 'parse_where_clause');

              END IF;

              c_.participants ( l_count ).ps_node_id := t_exp_psnodeid ( l_participant_index );
              c_.participants ( l_count ).model_ref_expl_id := t_exp_modelrefexplid ( l_participant_index );

          WHEN h_exprtypes ('where') THEN

              IF ( expr_has_children ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )))) THEN

                l_where_index := h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( l_expr_index )));

              ELSE

                report_and_raise_rule_sys_warn (
                      p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                                  'EXPR_ID', TO_CHAR ( t_exp_exprnodeid ( l_expr_index ))),
                      p_warning_location => 'parse_statement_compatible');

              END IF;

          ELSE

              --#<should never happen>
              -- 'Invalid structure of a compatibility rule. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
              report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVALID_STRUCTURE),
                    p_warning_location => 'parse_statement_compatible');

          END CASE;
        END LOOP;

        IF ( h_index_by_iterator.COUNT = 0 ) THEN

           --#<should never happen>
           -- 'No iterator specified. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_NO_ITERATOR ),
                    p_warning_location => 'parse_statement_compatible');

        END IF;

        IF ( l_where_index <> 0 ) THEN

           l_if := parse_where_clause ( l_where_index, const_ruletype_compatible, h_index_by_iterator, h_property_by_iterator );

        END IF;
        RETURN l_if;

     END parse_statement_compatible;
     ----------------------------------------------------------------------------------
     BEGIN --> generate_compatible

        c_.participants.DELETE;
        c_.combinations.DELETE;

        o_.DELETE;
        n_.DELETE;
        s_.DELETE;
        t_.DELETE;
        b_.DELETE;

        IF ( t_exp_exprtype ( j ) = h_exprtypes ('compatible')) THEN

           l_parsed := parse_statement_compatible ( j );

        ELSE

           l_parsed := parse_template_application ( j );

        END IF;

        --Read all the property values and populate the arrays.

        FOR i IN 1..c_.participants.COUNT LOOP

          l_key := h_property_by_iterator ( i ).FIRST;
          t_children := explode_node_children ( c_.participants ( i ).ps_node_id, c_.participants ( i ).model_ref_expl_id, FALSE );

          WHILE ( l_key IS NOT NULL ) LOOP

             l_property_id := TO_NUMBER ( l_key );

             get_property_info ( l_property_id, l_data_type, l_value );
             l_property_index := h_property_by_iterator ( i )( l_key );

             FOR ii IN 1..t_children.COUNT LOOP

                o_( i )( ii ).ps_node_id := t_children ( ii ).ps_node_id;

                IF ( l_parsed IS NOT NULL ) THEN

                   --We need to actually get the property values and populate corresponding arrays only if there
                   --is a WHERE clause. Probably, a compatibility rule without a WHERE clause should be reported.

                   l_value := get_property_value ( l_property_id, t_children ( ii ).ps_node_id, t_children ( ii ).model_ref_expl_id );

                   IF ( l_data_type IN ( h_datatypes ('integer'), h_datatypes ('decimal'))) THEN

                      n_( i )( ii )( l_property_index ) := TO_NUMBER ( l_value );

                   ELSIF ( l_data_type = h_datatypes ('boolean')) THEN

                      --We use integer representation of boolean as 0/1.

                      b_( i )( ii )( l_property_index ) := TO_NUMBER ( l_value );

                   ELSE

                      --For all other types (text and translatable) we use text.

                      t_( i )( ii )( l_property_index ) := l_value;

                   END IF;
                END IF;
             END LOOP;

             s_( i ) := t_children.COUNT;
             l_key := h_property_by_iterator ( i ).NEXT ( l_key );

          END LOOP;
        END LOOP;

        --This will populate the table of combinations.

        EXECUTE IMMEDIATE build_executable ( c_.participants.COUNT, l_parsed );
        verify_compatibility_table ( c_, FALSE );

        --Now generate the compatibility table.

        generate_compat_table ( c_, p_input_context, x_output_context );
        x_output_context.context_type := const_context_compatible;

     END generate_compatible;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_explicit_compat ( p_input_context  IN expression_context
                                        , x_output_context IN OUT NOCOPY expression_context
                                        ) IS

        tl_modelrefexplid   type_number_table;
        tl_featureid        type_number_table;
        tl_primaryoptid     type_number_table;
        tl_secondaryoptid   type_number_table;

        l_compat_table      type_compat_table;
        hl_features         type_data_hashtable;

        l_key               VARCHAR2(4000);
        l_count             PLS_INTEGER;

     BEGIN

        --We don't even need cz_des_chart_features table for explicit compatibility. Here we read all the data
        --in bulk and then transform it into another form in memory. This way we don't need any SQL ordering.

        SELECT primary_opt_id, secondary_opt_id, secondary_feature_id, secondary_feat_expl_id
          BULK COLLECT INTO tl_primaryoptid, tl_secondaryoptid, tl_featureid, tl_modelrefexplid
          FROM cz_des_chart_cells
         WHERE deleted_flag = '0'
           AND rule_id = this_rule_id;

        FOR i IN 1..tl_primaryoptid.COUNT LOOP

            --We are using the same key as for storing context nodes in local variables because we will be
            --storing and loading nodes when generating compatibility table.

           l_key := tl_featureid ( i ) || '-' || tl_modelrefexplid ( i );

           IF ( NOT hl_features.EXISTS ( l_key )) THEN

              l_count := l_compat_table.participants.COUNT + 1;
              hl_features ( l_key ) := l_count;

              l_compat_table.participants ( l_count ).ps_node_id := tl_featureid ( i );
              l_compat_table.participants ( l_count ).model_ref_expl_id := tl_modelrefexplid ( i );

           ELSE

              l_count := hl_features ( l_key );

           END IF;

           l_compat_table.combinations ( tl_primaryoptid ( i ))( l_count ).ps_node_id := tl_secondaryoptid ( i );

        END LOOP;

        verify_compatibility_table ( l_compat_table, FALSE );

        --Now generate the compatibility table.

        generate_compat_table ( l_compat_table, p_input_context, x_output_context );

     END generate_explicit_compat;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_design_chart ( p_input_context  IN expression_context
                                     , x_output_context IN OUT NOCOPY expression_context
                                     ) IS

        tl_modelrefexplid        type_number_table;
        tl_featureid             type_number_table;
        tl_featuretype           type_number_table;
        tl_primaryoptid          type_number_table;
        tl_secondaryoptid        type_number_table;
        tl_secondaryfeatid       type_number_table;
        tl_secondaryfeatexplid   type_number_table;

        tl_primary               type_iteratornode_table;
        tl_defining              type_iteratornode_table;
        tl_optional              type_iteratornode_table;

        hl_combinations          type_nodehashtable_hashtable;
        h_comb_number            type_data_hashtable;

        l_compat_tables          type_compattable_table;
        l_count                  PLS_INTEGER;
        l_index                  PLS_INTEGER;
        l_compat_index           PLS_INTEGER;
        l_combinations           PLS_INTEGER;

        l_key                    VARCHAR2(4000);
        l_primary_key            VARCHAR2(4000);

     BEGIN

        SELECT feature_id, model_ref_expl_id, feature_type
          BULK COLLECT INTO tl_featureid, tl_modelrefexplid, tl_featuretype
          FROM cz_des_chart_features
         WHERE deleted_flag = '0'
           AND rule_id = this_rule_id;

        IF ( tl_featureid.COUNT = 0 ) THEN
           -- Design chart is empty.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_EMPTY_DESIGN_CHART,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_design_chart' );

        END IF;

        FOR i IN 1..tl_featureid.COUNT LOOP

            IF ( tl_featuretype ( i ) = h_designtypes('primary')) THEN

               l_count := tl_primary.COUNT + 1;

               tl_primary ( l_count ).ps_node_id := tl_featureid ( i );
               tl_primary ( l_count ).model_ref_expl_id := tl_modelrefexplid ( i );

            ELSIF ( tl_featuretype ( i ) = h_designtypes('defining')) THEN

               l_count := tl_defining.COUNT + 1;

               tl_defining ( l_count ).ps_node_id := tl_featureid ( i );
               tl_defining ( l_count ).model_ref_expl_id := tl_modelrefexplid ( i );

            ELSIF ( tl_featuretype ( i ) = h_designtypes('optional')) THEN

               l_count := tl_optional.COUNT + 1;

               tl_optional ( l_count ).ps_node_id := tl_featureid ( i );
               tl_optional ( l_count ).model_ref_expl_id := tl_modelrefexplid ( i );

            ELSE
               -- 'Found invalid feature type "^FEAT_TYPE". Design Chart Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
               report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT(
                        CZ_FCE_SW_INVAL_FEAT_TYPE_DC,
                        'FEAT_TYPE', tl_featuretype ( i )
                        ),
                p_warning_location => 'generate_design_chart' );

            END IF;
        END LOOP;

        IF ( tl_primary.COUNT <> 1 ) THEN
           -- The primary feature in the design chart is either missing or duplicated.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_NO_PRIMARY_FEAT_DC,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                p_warning_location => 'generate_design_chart' );

        END IF;

        IF ( tl_defining.COUNT = 0 AND tl_optional.COUNT = 0) THEN

           report_and_raise_rule_warning(
                p_text => CZ_UTILS.GET_TEXT(
                        CZ_FCE_W_EMPTY_DESIGN_CHART,
                        'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                        'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                p_warning_location => 'generate_design_chart' );

        END IF;

        SELECT primary_opt_id, secondary_opt_id, secondary_feature_id, secondary_feat_expl_id
          BULK COLLECT INTO tl_primaryoptid, tl_secondaryoptid, tl_secondaryfeatid, tl_secondaryfeatexplid
          FROM cz_des_chart_cells
         WHERE deleted_flag = '0'
           AND rule_id = this_rule_id;

        FOR i IN 1..tl_primaryoptid.COUNT LOOP

           l_key := TO_CHAR ( tl_secondaryfeatid ( i )) || '-' || TO_CHAR ( tl_secondaryfeatexplid ( i ));
           hl_combinations ( l_key )( i ) := tl_secondaryoptid ( i );

        END LOOP;

        l_compat_index := 1;

        IF ( tl_defining.COUNT > 0 ) THEN

           --Build and verify the defining compatibility table.

           l_compat_tables ( l_compat_index ).participants ( 1 ) := tl_primary ( 1 );

           FOR i IN 1..tl_defining.COUNT LOOP

              l_compat_tables ( l_compat_index ).participants ( i + 1 ) := tl_defining ( i );
              l_key := TO_CHAR ( tl_defining ( i ).ps_node_id ) || '-' || TO_CHAR ( tl_defining ( i ).model_ref_expl_id );

              IF ( NOT hl_combinations.EXISTS ( l_key )) THEN
                 -- No selection made between primary and defining feature in design chart rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
                 report_and_raise_rule_warning(
                    p_text => CZ_UTILS.GET_TEXT(
                            CZ_FCE_W_NO_COMBINATIONS_DC,
                            'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                            'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                    p_warning_location => 'generate_design_chart' );

              END IF;

              IF ( i = 1 ) THEN

                 l_combinations := hl_combinations ( l_key ).COUNT;

              ELSE

                 IF ( hl_combinations ( l_key ).COUNT <> l_combinations ) THEN
                    -- No one-to-one correspondence between options of primary and defining feature in design chart rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
                    report_and_raise_rule_warning(
                        p_text => CZ_UTILS.GET_TEXT(
                                CZ_FCE_W_INVALID_NUM_COMB_DC,
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                        p_warning_location => 'generate_design_chart' );

                 END IF;
              END IF;

              l_index := hl_combinations ( l_key ).FIRST;

              IF ( i = 1 ) THEN

                 --As part of the processing for the first defining feature, we will populate the first position
                 --of each combination with corresponding primary option id, and establish a map between primary
                 --options and combinations. This map will be used to retrieve the combination number by primary
                 --option for other defining features.

                 l_count := 1;

                 WHILE ( l_index IS NOT NULL ) LOOP

                     l_compat_tables ( l_compat_index ).combinations ( l_count )( 1 ).ps_node_id := tl_primaryoptid ( l_index );
                     l_compat_tables ( l_compat_index ).combinations ( l_count )( 2 ).ps_node_id := hl_combinations ( l_key )( l_index );

                     --Bug #7519498 - we cannot assume the same order of primary options within each combination
                     --because the sql statement does not use any ordering. So, we need to build a map between
                     --primary option id(s) and combination numbers.

                     h_comb_number ( TO_CHAR ( tl_primaryoptid ( l_index ))) := l_count;

                     l_index := hl_combinations ( l_key ).NEXT ( l_index );
                     l_count := l_count + 1;

                 END LOOP;

              ELSE

                 WHILE ( l_index IS NOT NULL ) LOOP

                     l_count := h_comb_number ( TO_CHAR ( tl_primaryoptid ( l_index )));
                     l_compat_tables ( l_compat_index ).combinations ( l_count )( i + 1 ).ps_node_id := hl_combinations ( l_key )( l_index );

                     l_index := hl_combinations ( l_key ).NEXT ( l_index );

                 END LOOP;
              END IF;
           END LOOP;

           verify_compatibility_table ( l_compat_tables ( l_compat_index ), FALSE );
           l_compat_index := l_compat_index + 1;

        END IF; --build defining compatibility table

        --Build all the optional compatibility tables.

        FOR i IN 1..tl_optional.COUNT LOOP

           l_compat_tables ( l_compat_index ).participants ( 1 ) := tl_primary ( 1 );
           l_compat_tables ( l_compat_index ).participants ( 2 ) := tl_optional ( i );

           l_key := TO_CHAR ( tl_optional ( i ).ps_node_id ) || '-' || TO_CHAR ( tl_optional ( i ).model_ref_expl_id );

           --For the optional feature there can be no combinations. In this case generate_compat_table
           --will generate and exclude relation between the primary and the optional features.

           IF ( hl_combinations.EXISTS ( l_key )) THEN

              l_index := hl_combinations ( l_key ).FIRST;
              l_count := 1;

              WHILE ( l_index IS NOT NULL ) LOOP

                 l_compat_tables ( l_compat_index ).combinations ( l_count )( 2 ).ps_node_id := hl_combinations ( l_key )( l_index );
                 l_compat_tables ( l_compat_index ).combinations ( l_count )( 1 ).ps_node_id := tl_primaryoptid ( l_index );

                 l_index := hl_combinations ( l_key ).NEXT ( l_index );
                 l_count := l_count + 1;

              END LOOP;
           END IF;

           verify_compatibility_table ( l_compat_tables ( l_compat_index ), TRUE );
           l_compat_index := l_compat_index + 1;

        END LOOP;

        --Generate all the compatibility tables.

        FOR i IN 1..l_compat_tables.COUNT LOOP

           generate_compat_table ( l_compat_tables ( i ), p_input_context, x_output_context );

        END LOOP;
     END generate_design_chart;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_power ( j IN PLS_INTEGER
                              , p_input_context IN expression_context
                              , x_output_context IN OUT NOCOPY expression_context
                              ) IS

        l_expr_id          VARCHAR2(4000);
        l_index            PLS_INTEGER;
        l_aux              PLS_INTEGER;

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_two_children ( l_expr_id )) THEN

           l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

           -- 'Incomplete power operator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
            p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_INCOMPLETE_POWER ),
            p_warning_location => 'generate_power');

        END IF;

        l_aux := l_index + 1;

        IF ( t_exp_exprtype ( l_aux ) <> h_exprtypes ('literal') OR t_exp_datatype ( l_aux ) <> h_datatypes ('integer')) THEN
           -- 'The exponent of the power operaror must be an integer constant. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                            CZ_FCE_SW_EXP_PWR_MUST_BE_INT ),
                    p_warning_location => 'generate_power' );

        END IF;

        generate_expression ( l_index, p_input_context, x_output_context );
        generate_expression ( l_aux, p_input_context, x_output_context );

        emit_invokevirtual ('INumExprDef.pow(int)');

     END generate_power;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_mathrounding ( j IN PLS_INTEGER
                                     , p_input_context IN expression_context
                                     , x_output_context IN OUT NOCOPY expression_context
                                     ) IS

        l_expr_id          VARCHAR2(4000);
        l_index            PLS_INTEGER;
        l_aux              PLS_INTEGER;

        l_template_id      NUMBER := t_exp_templateid ( j );

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_two_children ( l_expr_id )) THEN

           l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

           -- 'Incomplete math rounding operator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';

           report_and_raise_rule_sys_warn(
              p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INCOMPLETE_MROUND ),
              p_warning_location => 'generate_mathrounding');

        END IF;

        l_aux := l_index + 1;

        generate_expression ( l_index, p_input_context, x_output_context );

        IF ( l_template_id = h_templates ('mod')) THEN

           emit_dup ();

        END IF;

        generate_expression ( l_aux, p_input_context, x_output_context );
        copyto_local_variable ('var');

        invoke_operator2 ( h_templates ('div'), l_aux, x_output_context );
        emit_invokevirtual ( h_mathrounding_ops ( l_template_id ));

        aload_local_variable ('var');
        invoke_operator2 ( h_templates ('multiply'), l_aux, x_output_context );

        IF ( l_template_id = h_templates ('mod')) THEN

           emit_invokevirtual ('INumExprDef.diff(INumExprDef)');

        END IF;
     END generate_mathrounding;
     ----------------------------------------------------------------------------------
     PROCEDURE generate_trigonometric ( j IN PLS_INTEGER
                                      , p_input_context IN expression_context
                                      , x_output_context IN OUT NOCOPY expression_context
                                      ) IS

        l_expr_id          VARCHAR2(4000);
        l_index            PLS_INTEGER;

        l_template_id      NUMBER := t_exp_templateid ( j );

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_one_child ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

          -- 'Incomplete math trigonometric operator. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';

          report_and_raise_rule_sys_warn(
            p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INCOMPLETE_TRIG ),
            p_warning_location => 'generate_trigonometric');

        END IF;

        generate_expression ( l_index, p_input_context, x_output_context );

        IF ( l_template_id = h_templates ('log')) THEN

           --<log> ::= x.log().div(Solver.literal(10).log())

           emit_invokevirtual ('INumExprDef.log()');

           aload_model_def ( p_component_id );

           emit_code ( h_inst ('bipush') || cz_fce_compile_utils.byte ( 10 ));
           emit_invokevirtual('IModelDef.literal(int)');

           emit_invokevirtual ('INumExprDef.log()');
           emit_invokevirtual ('INumExprDef.div(INumExprDef)');

        ELSIF ( l_template_id IN ( h_templates ('cosh'), h_templates ('sinh'))) THEN

           --<cosh> ::= (x.exp().sum(x.neg().exp())).div(2)
           --<sinh> ::= (x.exp().diff(x.neg().exp())).div(2)

           copyto_local_variable ('var');
           emit_invokevirtual ('INumExprDef.exp()');

           aload_local_variable ('var');
           emit_invokevirtual ('INumExprDef.neg()');
           emit_invokevirtual ('INumExprDef.exp()');

           emit_invokevirtual ('INumExprDef.' || CASE l_template_id WHEN h_templates ('cosh') THEN 'sum' ELSE 'diff' END || '(INumExprDef)');
           emit_code ( h_inst ('iconst_2'));
           emit_invokevirtual ('INumExprDef.div(int)');

        ELSIF ( l_template_id IN ( h_templates ('sin'), h_templates ('tan'))) THEN

           --<sin> ::= (x.diff(Solver.literal(Math.PI).div(2))).cos()
           --<tan> ::= ((x.diff(Solver.literal(Math.PI).div(2))).cos()).div(x.cos())

           IF ( l_template_id = h_templates ('tan')) THEN

              copyto_local_variable ('var');

           END IF;

           aload_model_def ( p_component_id );
           emit_constant ( h_mathconstants ('pi'));
           emit_invokevirtual('IModelDef.literal(double)');

           emit_code ( h_inst ('iconst_2'));
           emit_invokevirtual ('INumExprDef.div(int)');

           emit_invokevirtual ('INumExprDef.diff(INumExprDef)');
           emit_invokevirtual ('INumExprDef.cos()');

           IF ( l_template_id = h_templates ('tan')) THEN

              aload_local_variable ('var');
              emit_invokevirtual ('INumExprDef.cos()');
              emit_invokevirtual ('INumExprDef.div(INumExprDef)');

           END IF;

        ELSIF ( l_template_id = h_templates ('tanh')) THEN

           --<tanh> ::= (((x.prod(2)).exp()).diff(1)).div((((x.prod(2)).exp())).sum(1))

           emit_code ( h_inst ('iconst_2'));
           emit_invokevirtual ('INumExprDef.prod(int)');
           emit_invokevirtual ('INumExprDef.exp()');

           copyto_local_variable ('var');
           emit_code ( h_inst ('iconst_1'));
           emit_invokevirtual ('INumExprDef.diff(int)');

           aload_local_variable ('var');
           emit_code ( h_inst ('iconst_1'));
           emit_invokevirtual ('INumExprDef.sum(int)');

           emit_invokevirtual ('INumExprDef.div(INumExprDef)');

        ELSE
           -- 'Mathematical operator is not implemented for template_id "^TEMPL_ID". Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
           report_and_raise_rule_sys_warn(
              p_text => GET_NOT_TRANSLATED_TEXT(
                    CZ_FCE_SW__NO_MATH_OP,
                    'TEMPL_ID', l_template_id ),
              p_warning_location => 'generate_trigonometric' );

        END IF;
     END generate_trigonometric;
     ----------------------------------------------------------------------------------
     PROCEDURE generate_heuristics ( j IN PLS_INTEGER
                                   , p_input_context IN expression_context
                                   , x_output_context IN OUT NOCOPY expression_context
                                   ) IS

        l_expr_id          VARCHAR2(4000);
        l_method           VARCHAR2(4000);
        l_key              VARCHAR2(4000);

        l_index            PLS_INTEGER;
        l_node_id          NUMBER;
        l_property_id      NUMBER;

        l_parameter        type_iterator_value;

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_one_child ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

          -- 'Incomplete Default or Search Decision. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';
          report_and_raise_rule_sys_warn(
            p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INCOMPLETE_SEARCH ),
            p_warning_location => 'generate_heuristics');

        END IF;

        -- 'Invalid default or search decision is found. Here operand can only be a structure node. Rule "^RULE_NAME" in the model "^MODEL_NAME" ignored.';

        l_parameter := get_structure_node ( l_index );

        IF ( l_parameter.value_type IS NULL ) THEN

          report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_SD_OPAND_STRUCT_N ),
                p_warning_location => 'generate_heuristics');

        END IF;

        l_node_id := l_parameter.ps_node_id;
        l_key := TO_CHAR ( l_node_id );

        IF ( h_psnid_devlprojectid ( l_key ) <> p_component_id ) THEN

           --  Defaults and search decisions cannot be defined across different models.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.

           report_and_raise_rule_warning(
                    p_text => CZ_UTILS.GET_TEXT(
                            CZ_FCE_W_SD_NOT_ACROSS_MODELS,
                            'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                            'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                    p_warning_location => 'generate_heuristics');

        END IF;

        --Load the model def, in which the constraint will be defined, and the variable.

        aload_model_def ( h_psnid_parentid ( l_key ));
        haload_object ( l_node_id, 1 );

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( l_index ));

        IF ( NOT h_exprid_childrenindex.EXISTS ( l_expr_id )) THEN

           --No property is specified, need to default in some cases.

           IF ( is_bom_node ( h_psnid_backindex ( l_key ))) THEN

              l_property_id := h_templates ('quantity');

           ELSIF ( t_exp_templateid ( j ) <> h_templates ('assign')) THEN

              --We don't need to default property for assign operator except for bom.

              IF ( h_psnid_detailedtype ( l_key ) IN ( h_psntypes ('component'), h_psntypes ('reference'), h_psntypes ('connector'))) THEN

                 l_property_id := h_templates('instancecount');

              ELSIF ( h_psnid_detailedtype ( l_key ) = h_psntypes ('optionfeature')) THEN

                 l_property_id := h_templates ('quantity');

              END IF;
           END IF;
        ELSE

           l_property_id := get_property_id ( h_exprid_childrenindex ( l_expr_id ));

        END IF;

        IF ( l_property_id IS NOT NULL ) THEN

           apply_system_property ( l_property_id, h_psnid_backindex ( l_key ), p_input_context );

        END IF;

        emit_invokevirtual ( h_heuristic_ops ( t_exp_templateid ( j )));
        emit_effectivity ( 'IDecisionDef', this_effective_from, this_effective_until, this_effective_usages );

        IF ( this_rule_class = h_ruleclasses ('default')) THEN

           emit_invokevirtual ('IModelDef.addDefaultDecision(IDecisionExprDef)');

        ELSIF ( this_rule_class = h_ruleclasses ('search')) THEN

           emit_invokevirtual ('IModelDef.addSearchDecision(IDecisionExprDef)');

        ELSE
           -- Heuristic operators (IncMin, DecMax, Assign, MinFirst, MaxFirst) can only be used in defaults or search decisions.  Rule ^RULE_NAME in model ^MODEL_NAME ignored.
           report_and_raise_rule_warning(
                    p_text => CZ_UTILS.GET_TEXT(
                            CZ_FCE_W_HEUR_ONLY_IN_DEF,
                            'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                            'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                    p_warning_location => 'generate_heuristics' );

        END IF;

        emit_pop ( 1 );
        x_output_context.context_type := const_context_heuristics;

     END generate_heuristics;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_aggregatesum ( j IN PLS_INTEGER
                                     , p_input_context IN expression_context
                                     , x_output_context IN OUT NOCOPY expression_context
                                     ) IS

        l_expr_id          VARCHAR2(4000);
        l_index            PLS_INTEGER;
        l_return           PLS_INTEGER := const_no_instances;

        l_input_context    expression_context := p_input_context;
        l_output_context   expression_context;

        l_parameter        type_iterator_value;

     BEGIN

        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

        IF ( expr_has_one_child ( l_expr_id )) THEN

          l_index := h_exprid_childrenindex ( l_expr_id );

        ELSE

          report_and_raise_rule_sys_warn(
            p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_INCOMPLETE_AGSUM ),
            p_warning_location => 'generate_aggregatesum');

        END IF;

        l_parameter := get_structure_node ( l_index );

        IF ( l_parameter.value_type IS NULL ) THEN

          report_and_raise_rule_sys_warn(
                p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_AS_OPAND_STRUCT_N ),
                p_warning_location => 'generate_aggregatesum');

        END IF;

        l_input_context.context_type := const_context_aggregatesum;
/*
        l_expr_id := TO_CHAR ( t_exp_exprnodeid ( l_index ));

        IF ( h_exprid_childrenindex.EXISTS ( l_expr_id ) AND t_exp_exprtype ( h_exprid_childrenindex ( l_expr_id ) ) = h_exprtypes ('property')) THEN

           --User property is a special case - we need to generate the node, then push the
           --property value as an expression, and then call sum if necessary.

           l_return := generate_path ( l_parameter.ps_node_id, l_parameter.model_ref_expl_id, l_input_context, x_output_context );

        END IF;
*/
        generate_expression ( l_index, l_input_context, l_output_context );

        IF ( l_return = const_resourcesum_required ) THEN

           emit_invokevirtual('IPortExprDef.sum(INumExprDef)');

        END IF;
     END generate_aggregatesum;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION is_operator ( j IN PLS_INTEGER, p_operator IN VARCHAR2 ) RETURN BOOLEAN IS
     BEGIN

        RETURN t_exp_exprtype ( j ) = h_exprtypes ('operator') AND t_exp_templateid ( j ) = h_templates ( p_operator );

     END is_operator;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     FUNCTION is_text_selection ( j IN PLS_INTEGER ) RETURN BOOLEAN IS

        l_expr_id         VARCHAR2(4000);
        l_index           PLS_INTEGER;

     BEGIN

        IF ( t_exp_exprtype ( j ) = h_exprtypes ('argument')) THEN

           RETURN retrieve_parameter ( t_exp_argumentname ( j )).value_type = const_valuetype_selection;

        ELSE

           l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

           IF (( NOT h_exprid_childrenindex.EXISTS ( l_expr_id )) OR h_exprid_numberofchildren ( l_expr_id ) = 1 ) THEN RETURN FALSE; END IF;

           l_index := h_exprid_childrenindex ( l_expr_id );
           IF ( NVL ( t_exp_templateid ( l_index ), 0 ) = h_templates ('selection')) THEN RETURN TRUE; END IF;

        END IF;

        RETURN FALSE;
     END is_text_selection;
     ----------------------------------------------------------------------------------
     -- Scope: compile_constraints
     PROCEDURE generate_expression ( j IN PLS_INTEGER
                                   , p_input_context IN expression_context
                                   , x_output_context IN OUT NOCOPY expression_context
                                   ) IS

       --Must be local variables because of recursion.

       l_expr_id          VARCHAR2(4000);
       l_index            PLS_INTEGER;
       l_aux              PLS_INTEGER;
       l_count            PLS_INTEGER;
       l_key              VARCHAR2(4000);

       l_input_context    expression_context := p_input_context;
       l_output_context   expression_context;

       l_left_context     expression_context;
       l_right_context    expression_context;
       l_acc_init         type_varchar4000_table;

       l_lhs_selection    BOOLEAN;
       l_rhs_selection    BOOLEAN;
       l_side             PLS_INTEGER;

       l_lhs_target       NUMBER;
       l_rhs_target       NUMBER;

     BEGIN

       CASE t_exp_exprtype ( j )

         WHEN h_exprtypes ('node') THEN

           generate_structure_node ( j, p_input_context, x_output_context );

         WHEN h_exprtypes ('literal') THEN

           generate_literal ( j, get_literal_value ( j ), t_exp_datatype ( j ), p_input_context, x_output_context );

         WHEN h_exprtypes ('argument') THEN

           generate_parameter ( j, p_input_context, x_output_context );

         WHEN h_exprtypes ('operator') THEN

           l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

           IF ( l_input_context.context_type = const_context_generic ) THEN

              IF ( h_logical_ops.EXISTS ( t_exp_templateid ( j ))) THEN

                 l_input_context.context_type := const_context_logical;

              ELSIF ( h_numeric_ops.EXISTS ( t_exp_templateid ( j ))) THEN

                 l_input_context.context_type := const_context_numeric;

              END IF;
           END IF;

           IF ( h_operators_2.EXISTS ( t_exp_templateid ( j ))) THEN

              --Operators with 2 operands.

              IF ( expr_has_two_children ( l_expr_id )) THEN

                 l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                 report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_TWO_CHILD,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'generate_expression');

              END IF;

              l_aux := l_index + 1;

              IF ( t_exp_templateid ( j ) IN ( h_templates ('subsetof'), h_templates ('union'))) THEN

                 --Special validation for SubsetOf and Union operators.

                 l_lhs_target := 0;
                 l_rhs_target := 0;

                 IF ( t_exp_exprtype ( l_index ) = h_exprtypes ('node')) THEN

                    l_lhs_target := get_port_id ( TO_CHAR ( t_exp_psnodeid ( l_index )));

                    IF ( l_lhs_target IS NULL ) THEN

                       report_and_raise_rule_sys_warn (
                        p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_AS_PORT_LIMITS ),
                        p_warning_location => 'generate_expression');

                    END IF;
                 END IF;

                 IF ( t_exp_exprtype ( l_aux ) = h_exprtypes ('node')) THEN

                    l_rhs_target := get_port_id ( TO_CHAR ( t_exp_psnodeid ( l_aux )));

                    IF ( l_rhs_target IS NULL ) THEN

                       report_and_raise_rule_sys_warn (
                        p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_AS_PORT_LIMITS ),
                        p_warning_location => 'generate_expression');

                    END IF;
                 END IF;

                 IF ( l_lhs_target <> 0 AND l_rhs_target <> 0 AND l_lhs_target <> l_rhs_target ) THEN

                    report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT(
                            CZ_FCE_SW_COMPARE_TXPROP_TXLIT ),
                    p_warning_location => 'generate_expression' );

                 END IF;
              END IF;

              generate_expression ( l_index, p_input_context, l_left_context );
              generate_expression ( l_aux, p_input_context, l_right_context );

              --The following line corresponds to the case of division or multiplication by 1.

              IF ( l_left_context.context_type = const_context_literal OR l_right_context.context_type = const_context_literal ) THEN RETURN; END IF;

              invoke_operator2 ( t_exp_templateid ( j ), l_aux, l_right_context );

           ELSIF ( h_operators_3.EXISTS ( t_exp_templateid ( j ))) THEN

              --n-ary operators, defined on IModelDef: AnyTrue, AllTrue, Min, Max.

              IF ( expr_has_children ( l_expr_id )) THEN

                l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                report_and_raise_rule_sys_warn (
                      p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_CHILDREN,
                                  'EXPR_ID', l_expr_id ),
                      p_warning_location => 'generate_expression');

              END IF;

              l_aux := h_exprid_numberofchildren ( l_expr_id );

              --Put all the operand expressions on the stack.

              FOR i IN 1..l_aux LOOP

                 generate_expression ( l_index, l_input_context, x_output_context );
                 l_index := l_index + 1;

              END LOOP;

              IF ( t_exp_templateid ( j ) IN ( h_templates ('anytrue'), h_templates ('alltrue'))) THEN

                  invoke_anyalltrue ( t_exp_templateid ( j ), h_exprid_numberofchildren ( l_expr_id ), t_exp_exprparentid ( j ));

              ELSIF ( h_exprid_numberofchildren ( l_expr_id ) > 1 ) THEN

                  invoke_operator3 ( t_exp_templateid ( j ), h_exprid_numberofchildren ( l_expr_id ), 'INumExprDef' );

              END IF;

              --The number of children may have been changed by a collect, need to restore.

              h_exprid_numberofchildren ( l_expr_id ) := l_aux;

           ELSIF ( h_operators_1.EXISTS ( t_exp_templateid ( j ))) THEN

              --Operators with 1 operand.

              IF ( expr_has_one_child ( l_expr_id )) THEN

                generate_expression ( h_exprid_childrenindex ( l_expr_id ), p_input_context, x_output_context );

              ELSE

                -- 'The expression node with the id-^EXPR_ID must have exactly one child. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.'

                report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'generate_expression');

              END IF;

              emit_invokevirtual ( h_operators_1 ( t_exp_templateid ( j )));

           ELSIF ( t_exp_templateid ( j ) = h_templates('optionsof')) THEN

              IF ( expr_has_one_child ( l_expr_id )) THEN

                 l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                 -- 'The expression node with the id-^EXPR_ID must have exactly one child. Rule ^RULE_NAME in the model ^MODEL_NAME ignored.'

                 report_and_raise_rule_sys_warn(
                   p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                         'EXPR_ID', l_expr_id ),
                   p_warning_location => 'generate_expression');

              END IF;

              IF ( logical_context ( j, p_input_context.context_type )) THEN

                 --This is operator OptionsOf as a child of AnyTrue/AllTrue. Emulate property Options(),
                 --applied to the operand.

                 t_exp_exprparentid ( l_index ) := t_exp_exprparentid ( j );
                 generate_options ( l_index, p_input_context, x_output_context );

              END IF;

           ELSIF ( t_exp_templateid ( j ) = h_templates ('aggregatesum')) THEN

              generate_aggregatesum ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) = h_templates ('logic')) THEN

              generate_logic_template ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) = h_templates ('comparison')) THEN

              generate_comparison_template ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) = h_templates ('accumulator')) THEN

              generate_accumulator_template ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) = h_templates ('propertybased')) THEN

              generate_compatible ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) IN ( h_templates ('addsto'), h_templates ('subtractsfrom'))) THEN

              --This is an Accumulator rule.

              l_expr_id := TO_CHAR ( t_exp_exprnodeid ( j ));

              --Accumulator operator can only have two arguments.

              IF ( expr_has_two_children ( l_expr_id )) THEN

                 l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                 report_and_raise_rule_sys_warn (
                  p_text => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SW_RE_ENODE_TWO_CHILD,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'generate_expression');

              END IF;

              --This is expression index of the target.

              --Need to generate the target first, because generation of contributor will depend on the
              --target (LCA). Cannot just generate the path here because target can be an argument, for
              --example, in case of FORALL operator.

              l_aux := l_index + 1;
              l_input_context.context_type := const_context_target;

              generate_expression ( l_aux, l_input_context, x_output_context );

              l_count := x_output_context.context_num_data;
              l_key := x_output_context.context_data;

              --If output context is 'target', the target didn't exist and needs to be stored.
              --For an existing target, the context would have been changed to 'generic' in
              --generate_path procedure.

              IF ( x_output_context.context_type = const_context_target ) THEN

                 astore_register ( l_key );

                 t_target_quantifiers ( l_count ) := t_acc_quantifiers ( l_count );
                 h_target_quantifiers ( l_count ) := h_acc_quantifiers ( l_count );

              END IF;

              l_input_context.context_type := const_context_contributor;
              l_input_context.context_num_data := l_count;

              t_acc_local_quantifiers.DELETE;
              contributor_validation := 0;

              generate_expression ( l_index, l_input_context, x_output_context );

              IF ( contributor_validation > 1 ) THEN

                 --The output context contains the number of the generated expression's participants
                 --that are under ports. This validates the following restrictions:

                 --If all the nodes participating in the expressions are in the mandatory closure of
                 --the root, there are no restrictions on the expression.
                 --Otherwise, we allow only one node which can be multiplied by a constant, which is
                 --either a literal or a value of a user property.

                 --A contribution expression that uses a participant which is under an instantiable
                 --Component or referenced Model cannot also use another participant. Rule ^RULE_NAME
                 --in the Model ^MODEL_NAME ignored.

                 report_and_raise_rule_warning(
                    p_text => CZ_UTILS.GET_TEXT(
                            CZ_FCE_W_INVALID_CONTRIB,
                            'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                            'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                    p_warning_location => 'generate_expression' );

              END IF;

              IF ( t_exp_templateid ( j ) = h_templates('subtractsfrom')) THEN

                 emit_invokevirtual ( 'INumExprDef.neg()');

              END IF;

              combine_contributors ( l_count );
              x_output_context.context_type := const_context_accumulation;

           ELSIF ( h_heuristic_ops.EXISTS ( t_exp_templateid ( j ))) THEN

              --This is one of the heuristics operators: Assign, DecMax, IncMin, MinFirst or MaxFirst.
              --These operators can only be applied to a variable and the decision should be added to
              --the model def of this variable's parent.

              generate_heuristics ( j, p_input_context, x_output_context );

           ELSIF ( h_mathrounding_ops.EXISTS ( t_exp_templateid ( j ))) THEN

              generate_mathrounding ( j, p_input_context, x_output_context );

           ELSIF ( h_trigonometric_ops.EXISTS ( t_exp_templateid ( j ))) THEN

              generate_trigonometric ( j, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) IN ( h_templates('pow'), h_templates('integerpow'))) THEN

              generate_power ( j, p_input_context, x_output_context );

           ELSIF ( h_operators_2_text.EXISTS ( t_exp_templateid ( j ))) THEN

              --Text comparison operators.

              IF ( expr_has_two_children ( l_expr_id )) THEN

                 l_index := h_exprid_childrenindex ( l_expr_id );

              ELSE

                 report_and_raise_rule_sys_warn(
                  p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_TWO_CHILD,
                          'EXPR_ID', l_expr_id ),
                  p_warning_location => 'generate_expression');

              END IF;

              l_aux := l_index + 1;

              --Need to skip the totext operator if present.

              IF ( is_operator ( l_index, 'totext')) THEN

                IF  ( expr_has_one_child ( TO_CHAR ( t_exp_exprnodeid ( l_index )))) THEN

                  l_index := h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( l_index )));

                ELSE

                  report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                          'EXPR_ID',  TO_CHAR ( t_exp_exprnodeid ( l_index ))),
                    p_warning_location => 'generate_expression');

                END IF;

              END IF;

              IF ( is_operator ( l_aux, 'totext')) THEN

                IF ( expr_has_one_child ( TO_CHAR ( t_exp_exprnodeid ( l_aux )))) THEN

                  l_aux := h_exprid_childrenindex ( TO_CHAR ( t_exp_exprnodeid ( l_aux )));

                ELSE

                  report_and_raise_rule_sys_warn(
                    p_text => GET_NOT_TRANSLATED_TEXT( CZ_FCE_SW_RE_ENODE_ONE_CHILD,
                            'EXPR_ID', TO_CHAR ( t_exp_exprnodeid ( l_aux ))),
                    p_warning_location => 'generate_expression');

                END IF;
              END IF;

              l_lhs_selection := is_text_selection ( l_index );
              l_rhs_selection := is_text_selection ( l_aux );

              IF (( l_lhs_selection AND t_exp_exprtype ( l_aux ) <> h_exprtypes ('literal')) OR
                  ( l_rhs_selection AND t_exp_exprtype ( l_index ) <> h_exprtypes ('literal')))THEN

                 report_and_raise_rule_sys_warn(
                    CZ_UTILS.GET_TEXT(CZ_FCE_SW_COMPARE_TXPROP_TXLIT ),
                    'generate_expression' );

              END IF;

              l_input_context.context_type := const_context_selection;

              c_.combinations.DELETE;
              c_.participants.DELETE;

              o_.DELETE;
              s_.DELETE;
              t_.DELETE;

              l_side := 0;

              IF ( l_lhs_selection ) THEN l_side := 1;
              ELSIF ( l_rhs_selection ) THEN l_side := 2; END IF;

              generate_expression ( l_index, l_input_context, l_output_context );
              generate_expression ( l_aux, l_input_context, l_output_context );

              --All the data necessary for generation are already in the corresponding data structures.

              generate_text_comparison ( t_exp_templateid ( j ), l_side, p_input_context, x_output_context );

           ELSIF ( t_exp_templateid ( j ) = h_templates('none')) THEN

              RETURN;

           ELSE

              --#<should never happen>
              -- 'Unknown operator type "^OPERTYPE" in the rule. Rule "^RULE_NAME" in the Model ^MODEL_NAME" ignored.';
              report_and_raise_rule_sys_warn(
                GET_NOT_TRANSLATED_TEXT(CZ_FCE_SW_UNKNOWN_OP_TYPE,
                  'OPERTYPE',  TO_CHAR(t_exp_templateid ( j ))),
                'generate_expression'
               );

           END IF;

         WHEN h_exprtypes ('forall') THEN

           generate_statement_forall ( j, p_input_context, x_output_context );

         WHEN h_exprtypes ('compatible') THEN

           generate_compatible ( j, p_input_context, x_output_context );

         WHEN h_exprtypes ('constant') THEN

           generate_constant ( j );

         ELSE

           --#<should never happen>
           report_and_raise_rule_sys_warn(
                CZ_UTILS.GET_TEXT('CZ_E_UNKNOWN_EXPR_TYPE',
                  'RULENAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name)),
                'generate_expression'
               );

       END CASE;
     END generate_expression;
     ----------------------------------------------------------------------------------
     PROCEDURE resolve_node ( p_relative_node_path IN VARCHAR2
                            , p_parent_node_id     IN NUMBER
                            , p_parent_expl_id     IN NUMBER
                            , x_child_node_id      IN OUT NOCOPY NUMBER
                            , x_child_expl_id      IN OUT NOCOPY NUMBER
                            ) IS

       l_eff_from            DATE := const_epoch_begin;
       l_eff_until           DATE := const_epoch_end;
       l_index               PLS_INTEGER;
       l_parent_id           NUMBER;

       l_path_tbl            type_number_table;
       l_node_tbl            type_varchar4000_table;
       l_counter             NUMBER;

       l_return_node_id_tbl  type_number_table;
       l_return_expl_id_tbl  type_number_table;

     ----------------------------------------------------------------------------------
       PROCEDURE resolve_children ( p_index      IN PLS_INTEGER
                                  , p_node_id    IN NUMBER
                                  , p_expl_id    IN NUMBER
                                  , p_eff_from   IN DATE
                                  , p_eff_until  IN DATE
                                  ) IS

         t_eff_from_tbl   type_date_table;
         t_eff_until_tbl  type_date_table;
         t_node_id_tbl    type_number_table;
         t_expl_id_tbl    type_number_table;

         l_eff_from_tbl   type_date_table;
         l_eff_until_tbl  type_date_table;
         l_node_id_tbl    type_number_table;
         l_expl_id_tbl    type_number_table;
         l_path_tbl       type_number_table;

         l_counter        PLS_INTEGER := 0;
         l_index          PLS_INTEGER;

       BEGIN

         SELECT ps_node_id, model_ref_expl_id, effective_from, effective_until
           BULK COLLECT INTO l_node_id_tbl, l_expl_id_tbl, l_eff_from_tbl, l_eff_until_tbl
           FROM cz_explmodel_nodes_v
          WHERE model_id = p_component_id
            AND parent_psnode_expl_id = p_expl_id
            AND effective_parent_id = p_node_id
            AND suppress_flag = '0'
            AND name = l_node_tbl ( p_index );

         FOR i IN 1..l_node_id_tbl.COUNT LOOP

           IF ( p_eff_from > l_eff_from_tbl ( i )) THEN l_eff_from_tbl ( i ) := p_eff_from; END IF;
           IF ( p_eff_until < l_eff_until_tbl ( i )) THEN l_eff_until_tbl ( i ) := p_eff_until; END IF;

           IF( l_eff_from_tbl ( i ) <= l_eff_until_tbl ( i )) THEN

             l_counter := l_counter + 1;

             t_eff_from_tbl ( l_counter ) := l_eff_from_tbl ( i );
             t_eff_until_tbl ( l_counter ) := l_eff_until_tbl ( i );
             t_node_id_tbl ( l_counter ) := l_node_id_tbl ( i );
             t_expl_id_tbl ( l_counter ) := l_expl_id_tbl ( i );

           END IF;
         END LOOP;

         FOR i IN 1..t_node_id_tbl.COUNT LOOP

           IF( p_index = l_node_tbl.COUNT )THEN

             l_index := l_return_node_id_tbl.COUNT + 1;

             l_return_node_id_tbl ( l_index ) := t_node_id_tbl ( i );
             l_return_expl_id_tbl ( l_index ) := t_expl_id_tbl ( i );

           ELSE

             resolve_children ( p_index + 1, t_node_id_tbl ( i ), t_expl_id_tbl ( i ), t_eff_from_tbl ( i ), t_eff_until_tbl ( i ));

           END IF;
         END LOOP;
       END resolve_children;
     ----------------------------------------------------------------------------------
     BEGIN

        l_node_tbl := split_str_path ( p_relative_node_path );
        l_path_tbl := build_reference_path ( p_parent_expl_id );

        --Propagate effectivity from all the bom references down from the root model.

        FOR i IN 1..l_path_tbl.COUNT LOOP

          --We need to stop on the model, in which the rule is defined.

          IF ( l_path_tbl ( i ) = p_component_id ) THEN EXIT; END IF;

            --Account only for references to bom(s).

            l_index := h_psnid_backindex ( l_path_tbl ( i ));

            IF ( is_bom_port ( l_index )) THEN

               IF ( t_psn_effectivefrom ( l_index ) > l_eff_from ) THEN l_eff_from := t_psn_effectivefrom ( l_index ); END IF;
               IF ( t_psn_effectiveuntil ( l_index ) < l_eff_until ) THEN l_eff_until := t_psn_effectiveuntil ( l_index ); END IF;

            END IF;
        END LOOP;

        --Adjust effectivities for the least unambiguous parent.

        l_index := h_psnid_backindex(p_parent_node_id);

        IF ( t_psn_effectivefrom ( l_index ) > l_eff_from ) THEN l_eff_from := t_psn_effectivefrom ( l_index ); END IF;
        IF ( t_psn_effectiveuntil ( l_index ) < l_eff_until ) THEN l_eff_until := t_psn_effectiveuntil ( l_index ); END IF;

        --Finally adjust for the rule effectivity.

        IF( this_effective_from > l_eff_from)THEN l_eff_from := this_effective_from; END IF;
        IF( this_effective_until < l_eff_until)THEN l_eff_until := this_effective_until; END IF;

        --If effectivity range is empty, it will be impossible to resolve the node.

        IF( l_eff_until < l_eff_from )THEN
          -- The reference ^NODE_NAME is invalid. At least one node does not exist in the Model or is not effective when the rule is effective. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
          report_and_raise_rule_warning (
             CZ_UTILS.GET_TEXT ( CZ_FCE_W_INCORRECT_REFERENCE,
               'NODE_NAME', REPLACE (p_relative_node_path, FND_GLOBAL.LOCAL_CHR(7), '.'),
               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH( p_component_id, p_model_path ),
               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name )),
             'RESOLVE_CHILDREN'
            );
        END IF;

        IF( l_node_tbl.COUNT = 0 )THEN

          x_child_node_id := p_parent_node_id;
          x_child_expl_id := p_parent_expl_id;
          RETURN;

        END IF;

        resolve_children ( 1, p_parent_node_id, p_parent_expl_id, l_eff_from, l_eff_until );

        IF ( l_return_node_id_tbl.COUNT = 0 ) THEN
          -- The reference ^NODE_NAME is invalid. At least one node does not exist in the Model or is not effective when the rule is effective. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
          report_and_raise_rule_warning (
             CZ_UTILS.GET_TEXT ( CZ_FCE_W_INCORRECT_REFERENCE,
               'NODE_NAME', REPLACE (p_relative_node_path, FND_GLOBAL.LOCAL_CHR(7), '.'),
               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path ),
               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name )),
             'RESOLVE_CHILDREN'
            );

        ELSIF ( l_return_node_id_tbl.COUNT > 1 ) THEN
          -- Unable to resolve Model node reference ^NODE_NAME because it is ambiguous. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
          report_and_raise_rule_warning (
             CZ_UTILS.GET_TEXT ( CZ_FCE_W_AMBIGUOUS_REFERENCE,
               'NODE_NAME', REPLACE (p_relative_node_path, FND_GLOBAL.LOCAL_CHR(7), '.'),
               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path ),
               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name )),
             'RESOLVE_CHILDREN'
            );

        ELSE

          x_child_node_id := l_return_node_id_tbl ( 1 );
          x_child_expl_id := l_return_expl_id_tbl ( 1 );

        END IF;
   END resolve_node;
 ---------------------------------------------------------------------------------------
   BEGIN --> compile_constraints

     free_registers ();

     SELECT model_ref_expl_id, parent_expl_node_id, component_id, referring_node_id, expl_node_type
       BULK COLLECT INTO t_expl_modelrefexplid, t_expl_parentexplnodeid, t_expl_componentid,
                         t_expl_referringnodeid, t_expl_explnodetype
       FROM cz_model_ref_expls
      WHERE model_id = p_component_id
        AND deleted_flag = '0';

     FOR i IN 1..t_expl_modelrefexplid.COUNT LOOP

       h_explid_backindex ( TO_CHAR ( t_expl_modelrefexplid ( i ))) := i;

       IF ( t_expl_referringnodeid ( i ) IS NOT NULL ) THEN

          h_parentid_referring_explid ( TO_CHAR ( t_expl_parentexplnodeid ( i )))( TO_CHAR ( t_expl_referringnodeid ( i ))) := t_expl_modelrefexplid ( i );

       END IF;
     END LOOP;

     FOR rule IN ( SELECT rule_id, rule_type, name, reason_id, rule_folder_id, component_id, model_ref_expl_id,
                         effective_from, effective_until, effective_usage_mask, effectivity_set_id, invalid_flag,
                         unsatisfied_msg_id, unsatisfied_msg_source, presentation_flag, rule_class, class_name
                     FROM cz_rules
                    WHERE devl_project_id = p_component_id
                      AND deleted_flag = '0'
                      AND disabled_flag = '0'
                    ORDER BY class_seq ) LOOP
     BEGIN

        this_rule_id := rule.rule_id;
        this_reason_id := rule.reason_id;
        this_rule_class := rule.rule_class;
        this_rule_name := rule.name;
        this_effective_from := NVL ( rule.effective_from, const_epoch_begin );
        this_effective_until := NVL ( rule.effective_until, const_epoch_end );
        this_effective_usages := LPAD ( rule.effective_usage_mask, 16, '0' );

        set_rule_savepoint ();

        IF ( rule.invalid_flag = '1' ) THEN
           IF ( rule.presentation_flag = '0' ) THEN
              -- Parsing errors found. Fix parsing errors. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
              report_and_raise_rule_warning(
                     p_text => CZ_UTILS.GET_TEXT (
                               CZ_FCE_W_PARSE_FAILED,
                               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)
                               ),
                     p_warning_location => 'compile_constraints' );

           ELSE

              report_and_raise_rule_warning(
                     -- Invalid or incomplete rule, please check the rule. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
                     p_text => CZ_UTILS.GET_TEXT (
                               CZ_FCE_W_TEMPLATE_INVALID,
                               'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                               'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path)),
                     p_warning_location => 'compile_constraints' );

           END IF;
        END IF;

        IF ( rule.effectivity_set_id IS NOT NULL ) THEN
           IF ( NOT h_effsetid_effectivefrom.EXISTS ( TO_CHAR ( rule.effectivity_set_id ))) THEN

              report_and_raise_rule_sys_warn (
                  p_text => GET_NOT_TRANSLATED_TEXT (
                            CZ_FCE_SW_RULEINCORRECTEFFSET,
                            'RULE_NAME',
                            CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                            'MODEL_NAME',
                            CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH (p_component_id, p_model_path )),
                  p_warning_location => 'compile_constraints');

           ELSE

              this_effective_from := h_effsetid_effectivefrom ( TO_CHAR ( rule.effectivity_set_id ));
              this_effective_until := h_effsetid_effectiveuntil ( TO_CHAR ( rule.effectivity_set_id ));

           END IF;
        END IF;

        t_exp_modelrefexplid.DELETE;
        t_exp_exprtype.DELETE;
        t_exp_exprnodeid.DELETE;
        t_exp_exprparentid.DELETE;
        t_exp_templateid.DELETE;
        t_exp_psnodeid.DELETE;
        t_exp_datavalue.DELETE;
        t_exp_propertyid.DELETE;
        t_exp_paramindex.DELETE;
        t_exp_argumentindex.DELETE;
        t_exp_argumentname.DELETE;
        t_exp_datatype.DELETE;
        t_exp_datanumvalue.DELETE;
        t_exp_paramsignatureid.DELETE;
        t_exp_relativenodepath.DELETE;
        t_exp_seqnbr.DELETE;

        h_exprid_childrenindex.DELETE;
        h_exprid_numberofchildren.DELETE;
        h_exprid_backindex.DELETE;

        IF ( rule.rule_type = h_ruletypes ('statement')) THEN

          SELECT model_ref_expl_id, expr_type, expr_node_id, expr_parent_id, template_id, ps_node_id, data_value,
                 property_id, param_index, argument_index, argument_name, data_type, data_num_value,
                 param_signature_id, relative_node_path, seq_nbr
            BULK COLLECT INTO t_exp_modelrefexplid, t_exp_exprtype, t_exp_exprnodeid, t_exp_exprparentid,
                              t_exp_templateid, t_exp_psnodeid, t_exp_datavalue, t_exp_propertyid,
                              t_exp_paramindex, t_exp_argumentindex, t_exp_argumentname, t_exp_datatype,
                              t_exp_datanumvalue, t_exp_paramsignatureid, t_exp_relativenodepath, t_exp_seqnbr
            FROM cz_expression_nodes
           WHERE rule_id = rule.rule_id
             AND expr_type <> h_exprtypes ('punctuation')
             AND deleted_flag = '0'
           ORDER BY expr_parent_id, seq_nbr;

          l_rule_expr_lastindex := t_exp_exprnodeid.COUNT;

          IF ( l_rule_expr_lastindex = 0 ) THEN
             -- Rule definition is empty.  Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
             report_and_raise_rule_warning(
                  p_text => CZ_UTILS.GET_TEXT(
                            CZ_FCE_W_EMPTY_RULE,
                            'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH(this_rule_id, this_rule_name),
                            'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH(p_component_id, p_model_path) ),
                    p_warning_location => 'compile_constraints' );

          END IF;

          FOR i IN 1..l_rule_expr_lastindex LOOP

            IF ( t_exp_exprparentid ( i ) IS NOT NULL ) THEN

              l_key := TO_CHAR ( t_exp_exprparentid ( i ));

              IF( h_exprid_numberofchildren.EXISTS ( l_key ))THEN

                h_exprid_numberofchildren ( l_key ) := h_exprid_numberofchildren ( l_key ) + 1;

              ELSE

                h_exprid_numberofchildren ( l_key ) := 1;

              END IF;

              IF ( NOT h_exprid_childrenindex.EXISTS ( l_key ))THEN

                h_exprid_childrenindex ( l_key ) := i;

              END IF;
            END IF;

            --Sanity check on basic expression node types. May be moved from here to the first pass
            --over rules (when implemented).

            CASE t_exp_exprtype ( i )

                WHEN h_exprtypes ('node') THEN

                   IF ( t_exp_psnodeid ( i ) IS NULL OR t_exp_modelrefexplid ( i ) IS NULL ) THEN

                      report_and_raise_rule_sys_warn (
                        p_text => GET_NOT_TRANSLATED_TEXT (
                                CZ_FCE_SW_UNDEFINED_STRUC_NODE ),
                        p_warning_location => 'compile_constraints');

                   ELSIF ( NOT h_explid_backindex.EXISTS ( TO_CHAR ( t_exp_modelrefexplid ( i )))) THEN

                      -- Rule participant ^NODE_NAME is not accessible. May be its model reference has been deleted.

                      report_and_raise_rule_warning (
                        p_text => CZ_UTILS.GET_TEXT (
                                CZ_FCE_W_NODE_NOT_FOUND,
                                'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH ( t_exp_psnodeid ( i ),
                                   ps_node_id_table_to_string ( build_model_path ( t_exp_psnodeid ( i )))),
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path )),
                        p_warning_location => 'compile_constraints');

                   ELSIF ( NOT h_psnid_backindex.EXISTS ( TO_CHAR ( t_exp_psnodeid ( i )))) THEN

                      report_and_raise_rule_warning (
                        p_text => CZ_UTILS.GET_TEXT (
                                CZ_FCE_W_NODE_DELETED,
                                'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH ( t_exp_psnodeid ( i ),
                                   ps_node_id_table_to_string ( build_model_path ( t_exp_psnodeid ( i )))),
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH( this_rule_id, this_rule_name ),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path )),
                        p_warning_location => 'compile_constraints');

                   END IF;

                WHEN h_exprtypes ('property') THEN

                   IF ( t_exp_propertyid ( i ) IS NULL ) THEN
                      --  The rule is incomplete because a property is undefined. Rule ^RULE_NAME in the Model ^MODEL_NAME ignored.
                      report_and_raise_rule_warning (
                        p_text => CZ_UTILS.GET_TEXT (
                                CZ_FCE_W_UNDEFINED_PROPERTY,
                                'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name ),
                                'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH ( p_component_id, p_model_path )),
                        p_warning_location => 'compile_constraints');

                   END IF;

                WHEN h_exprtypes ('systemproperty') THEN

                   IF ( t_exp_templateid ( i ) IS NULL ) THEN

                      report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_UNDEFINED_SYS_PROP ),
                        p_warning_location => 'compile_constraints' );

                   END IF;

                WHEN h_exprtypes ('operator') THEN

                   IF ( t_exp_templateid ( i ) IS NULL ) THEN

                      report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_UNDEFINED_OPERATOR ),
                        p_warning_location => 'compile_constraints' );

                   END IF;

                WHEN h_exprtypes ('template') THEN

                   IF ( t_exp_templateid ( i ) IS NULL ) THEN

                      report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_UNDEFINED_OP_TEMPL ),
                        p_warning_location => 'compile_constraints' );

                   END IF;

                WHEN h_exprtypes ('operatorbyname') THEN

                   IF ( t_exp_argumentname ( i ) IS NULL ) THEN

                      report_and_raise_rule_sys_warn(
                        p_text => GET_NOT_TRANSLATED_TEXT(
                                CZ_FCE_SW_UNDEFINED_OP_BY_NAME ),
                        p_warning_location => 'compile_constraints' );

                   END IF;

                WHEN h_exprtypes ('nodebyname') THEN

                   resolve_node ( p_relative_node_path => t_exp_relativenodepath ( i )
                                , p_parent_node_id     => t_exp_psnodeid ( i )
                                , p_parent_expl_id     => t_exp_modelrefexplid ( i )
                                , x_child_node_id      => t_exp_psnodeid ( i )
                                , x_child_expl_id      => t_exp_modelrefexplid ( i )
                                );

                   t_exp_exprtype ( i ) := h_exprtypes ('node');

                ELSE NULL;
            END CASE;

            h_exprid_backindex ( TO_CHAR ( t_exp_exprnodeid ( i ))) := i;

          END LOOP;

          FOR i IN 1..l_rule_expr_lastindex LOOP

            --One statement rule can contain several constraints. Right now, if there is a problem
            --in any of these constraints, the whole rule will be ignored. This is why it is ok to
            --set the savepoint for the whole rule at the beginning. If we want to ignore specific
            --constraint within a rule we need to set and restore savepoints inside this loop.

            IF ( t_exp_exprparentid ( i ) IS NULL ) THEN

              comment ( 'Create rule: "' || this_rule_name || '" (rule_id = ' || this_rule_id || ')');

              --These arrays are per constraint.

              h_instancequantifiers.DELETE;
              t_instancequantifiers.DELETE;
              h_parameter_stack.DELETE;

              --All assistant variables by definition are used only within a constraint.

              assistant_var_id := 0;

              --Put the ModelDef on the stack for the last addConstraint call.

              aload_model_def ( p_component_id );

              l_output_context.context_type := const_context_generic;
              l_input_context.context_type := const_context_generic;

              generate_expression ( i, l_input_context, l_output_context );

              IF ( l_output_context.context_type NOT IN ( const_context_accumulation
                                                        , const_context_forall
                                                        , const_context_compatible
                                                        , const_context_heuristics
                                                        )) THEN

                set_reason_id ();
                add_constraint ();

              ELSE

                --In case of accumulator rule, we need to remove the model def, put on the stack
                --before expression generation, as we did not add the constraint yet.
                --In the case of ForAll all the constraints are already added so we also need to
                --remove the model def.

                emit_pop ( 1 );

              END IF;
            END IF;
          END LOOP;

        ELSIF ( rule.rule_type = h_ruletypes ('explicitcompat')) THEN

          --Instance quantifiers are initialized inside the procedure as necessary.

          generate_explicit_compat ( l_input_context, l_output_context );

        ELSIF ( rule.rule_type = h_ruletypes ('designchart')) THEN

          --Instance quantifiers are initialized inside the procedure as necessary.

          generate_design_chart ( l_input_context, l_output_context );

        ELSIF ( rule.rule_type = h_ruletypes ('companion')) THEN

          l_run_id := x_run_id;
          CZ_DEVELOPER_UTILS_PVT.verify_special_rule( this_rule_id, this_rule_name, l_run_id );

        END IF; --> rule type

     EXCEPTION --> compile_constraints block
       WHEN CZ_LOGICGEN_WARNING THEN
          restore_rule_savepoint ();
       WHEN CZ_LOGICGEN_SYS_WARNING THEN
          restore_rule_savepoint ();
       WHEN CZ_LOGICGEN_ERROR THEN
          RAISE;
       WHEN CZ_LOGICGEN_SYS_ERROR THEN
          RAISE;
       WHEN OTHERS THEN
          report_and_raise_sys_error (
            p_message => GET_NOT_TRANSLATED_TEXT ( CZ_FCE_SE_UNKNOWN_IN_RULE,
              'RULE_NAME', CZ_FCE_COMPILE_UTILS.GET_RULE_PATH ( this_rule_id, this_rule_name )),
            p_run_id => x_run_id,
            p_model_id => p_component_id,
            p_error_stack => DBMS_UTILITY.FORMAT_ERROR_STACK || ' Error backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
          );
     END;
     END LOOP;

     --Now handle all the accumulator rules, defined in the model, if any.
     --Accumulator rules can only be constraints.

     IF ( t_acc_targets.COUNT > 0 ) THEN

        --Target is not just a node but includes some of the properties that can be applied, for example,
        --MinInstances()/MaxInstances(), applied to the same target component, will be different targets.

        FOR i IN 1..t_acc_targets.COUNT LOOP

           FOR j IN 1..t_acc_contributors ( i ).COUNT LOOP

              --We need to skip dummy contribution records that may have been created when combining
              --effectivity intervals.

              IF ( t_acc_contributors ( i )( j ).interval_key IS NOT NULL ) THEN

                 --Model def for addConstraint method.

                 aload_model_def ( p_component_id );

                 l_count := t_acc_contributors ( i )( j ).quantifiers.COUNT;

                 IF ( l_count > 0 ) THEN

                    --Will need another model def for the ForAll.

                    emit_dup ();

                    FOR jj IN 1..l_count LOOP

                      aload_register ( t_acc_contributors ( i )( j ).quantifiers ( jj ));

                    END LOOP;

                    IF ( l_count > 2 ) THEN

                      create_array ( l_count, h_javatypes ('IInstanceQuantifier'));
                      populate_array ( l_count );

                    END IF;
                 END IF;

                 aload_register ( t_acc_targets ( i ));
                 aload_register ( t_acc_contributors ( i )( j ).interval_key );
                 emit_invokevirtual('INumExprDef.eq(INumExprDef)');

                 --Set the violation message to the generic seeded message.

                 emit_dup ();

                 push_long_constant ( const_textid_resultnotvalid );
                 emit_invokevirtual('IExprDef.setId(long)');

                 --Remove the null object from stack after a void method.

                 emit_pop ( 1 );
                 emit_effectivity ( 'ILogicExprDef', t_acc_contributors ( i )( j ).effective_from, t_acc_contributors ( i )( j ).effective_until, t_acc_contributors ( i )( j ).effective_usage_mask );

                 IF ( l_count > 0 ) THEN

                    emit_invokevirtual ( CASE l_count
                                         WHEN 1 THEN 'IModelDef.forAll(IInstanceQuantifier, ILogicExprDef)'
                                         WHEN 2 THEN 'IModelDef.forAll(IInstanceQuantifier, IInstanceQuantifier, ILogicExprDef)'
                                         ELSE 'IModelDef.forAll(IInstanceQuantifier[], ILogicExprDef)'
                                         END );

                    emit_invokevirtual('IModelDef.addConstraint(IForAllDef)');

                 ELSE

                    emit_invokevirtual('IModelDef.addConstraint(ILogicExprDef)');

                 END IF;

                 emit_pop ( 1 );

              END IF;
           END LOOP;
        END LOOP;
     END IF;
   END compile_constraints;
---------------------------------------------------------------------------------------
  BEGIN --> compile_logic_file

     init_logic_file ();
     h_devlid_modelvisited ( TO_CHAR ( p_component_id )) := 1;

     ----------------------------------------------------------------------------------
     CASE p_type WHEN const_logicfile_def THEN
     ----------------------------------------------------------------------------------
     LOOP

        v_index := v_index + 1;

        CASE t_psn_psnodetype(v_index)

            WHEN h_psntypes('component') THEN --> component

               emit_model_def (v_index);

            WHEN h_psntypes('feature') THEN --> feature

               CASE t_psn_featuretype ( v_index )

                  WHEN h_psntypes ('booleanfeature') THEN

                       emit_logicvar ( v_index );

                  WHEN h_psntypes ('integerfeature') THEN

                       emit_intvar ( v_index
                                   , NVL ( t_psn_minimum ( v_index ), cz_fce_compile_utils.const_min_integer )
                                   , NVL ( t_psn_maximum ( v_index ), cz_fce_compile_utils.const_max_integer )
                                   );

                  WHEN h_psntypes ('decimalfeature') THEN

                       emit_floatvar ( v_index
                                     , NVL ( t_psn_minimum ( v_index ), const_min_double )
                                     , NVL ( t_psn_maximum ( v_index ), const_max_double )
                                     );

                  WHEN h_psntypes ('optionfeature') THEN

                       --Code will be generated when the last option is reached. Here just initialize the option count
                       --and store the feature index.

                       l_feature_idx := v_index;
                       l_var_min := NVL ( t_psn_minimum ( v_index ), 0 );

                       IF ( h_psnid_numberofchildren ( TO_CHAR ( t_psn_psnodeid ( v_index ))) > 0 ) THEN

                          l_option_count := h_psnid_numberofchildren ( TO_CHAR ( t_psn_psnodeid ( v_index )));

                       ELSE

                          IF ( l_var_min > 0 ) THEN
                             -- Invalid problem definition: Option Feature with minimum quantity greater than 0 must have children. The Option Feature is ^NODE_NAME in the Model ^MODEL_NAME.
                             report_and_raise_error(
                                  p_message => CZ_UTILS.GET_TEXT ( CZ_FCE_E_OPTION_MAXQ_NO_CHILD,
                                      'NODE_NAME', CZ_FCE_COMPILE_UTILS.GET_NODE_PATH(t_psn_psnodeid ( v_index ),
                                        ps_node_id_table_to_string(
                                          build_model_path(t_psn_psnodeid ( v_index ) ) ) ),
                                      'MODEL_NAME', CZ_FCE_COMPILE_UTILS.GET_MODEL_PATH( p_component_id, p_model_path) ),
                                  p_run_id => x_run_id,
                                  p_model_id => p_component_id
                             );

                          END IF;

                          l_option_count := 0;

                       END IF;

                       l_var_max := NVL ( t_psn_maximum ( v_index ), l_option_count );
                       l_var_count := NVL ( t_psn_maxqtyperoption ( v_index ), 1 );

                       --This procedure puts the first two parameters to the feature's method on the stack.

                       prepare_feature ( v_index );

                       IF ( l_option_count = 0 ) THEN

                          --This is a valid feature with no options, need to create the variable here.

                          create_feature ( v_index, l_option_count, l_var_min, l_var_max, l_var_count );

                       END IF;

                  ELSE NULL;

               END CASE;

            WHEN h_psntypes('option') THEN --> option

               push_variable_name ( v_index );

               IF ( v_index = h_psnid_lastchildindex ( TO_CHAR ( t_psn_parentid ( v_index )))) THEN

                  --This is the last option of the feature, create the feature after that.

                  create_feature ( l_feature_idx, l_option_count, l_var_min, l_var_max, l_var_count );

               END IF;

            WHEN h_psntypes('total') THEN --> total

                       emit_floatvar ( v_index
                                     , NVL ( t_psn_minimum ( v_index ), const_min_double )
                                     , NVL ( t_psn_maximum ( v_index ), const_max_double )
                                     );

            WHEN h_psntypes('resource') THEN --> resource

                       emit_floatvar ( v_index
                                     , NVL ( t_psn_minimum ( v_index ), 0 )
                                     , NVL ( t_psn_maximum ( v_index ), const_max_double )
                                     );

            WHEN h_psntypes('integertotal') THEN --> integer total

                       emit_intvar ( v_index
                                   , NVL ( t_psn_minimum ( v_index ), cz_fce_compile_utils.const_min_integer )
                                   , NVL ( t_psn_maximum ( v_index ), cz_fce_compile_utils.const_max_integer )
                                   );

            WHEN h_psntypes('integerresource') THEN --> integer resource

                       emit_intvar ( v_index
                                   , NVL ( t_psn_minimum ( v_index ), 0 )
                                   , NVL ( t_psn_maximum ( v_index ), cz_fce_compile_utils.const_max_integer )
                                   );

            WHEN h_psntypes('bommodel') THEN --> bom model

               emit_bommodel_def ( v_index, NVL ( t_psn_decimalqtyflag( v_index ), '0' ));

               --Bug #6613028. If the bom model is not root, need to create a variable here.

               --This is the same code as for a bom reference in the port file generation, except for
               --using ps_node_id instead of reference_id.

               IF ( t_psn_parentid ( v_index ) IS NOT NULL ) THEN

                  --See Section 23.13.2 'BOM Instantiatibility and Quantity' in
                  --http://files.oraclecorp.com/content/AllPublic/SharedFolders/CZ-Dev-Project-Documents-Public/12.1/Design/CZ_CP_Engine_UI_FD.doc

                  IF ( t_psn_instantiableflag ( v_index ) = h_instantiability ('mandatory')) THEN

                     l_var_min := 1;
                     l_var_max := 1;

                  ELSIF ( t_psn_instantiableflag ( v_index ) = h_instantiability ('optional')) THEN

                     l_var_min := 0;
                     l_var_max := 1;

                  ELSE

                     l_var_min := 0;
                     l_var_max := NVL ( t_psn_maximumselected( v_index ), cz_fce_compile_utils.const_max_integer);

                  END IF;

                  l_begin_date := NVL ( t_psn_effectivefrom ( v_index ), const_epoch_begin );
                  l_end_date := NVL ( t_psn_effectiveuntil ( v_index ), const_epoch_end );

                  IF ( l_begin_date < const_epoch_begin ) THEN l_begin_date := const_epoch_begin; END IF;
                  IF ( l_end_date > const_epoch_end ) THEN l_end_date := const_epoch_end; END IF;

                  --Note, that the value of the decimal quantity flag is taken using ps_node_id, not reference_id,
                  --because we are on the model node, not reference node.

                  emit_bommodelvar ( v_index
                                   , NVL ( h_psnid_decimalqtyflag ( TO_CHAR ( t_psn_psnodeid ( v_index ))), '0')
                                   , NVL ( t_psn_bomrequiredflag ( v_index ), '0')
                                   , NVL ( t_psn_minimumselected ( v_index ), 0 )
                                   , NVL ( t_psn_maximumselected ( v_index ), cz_fce_compile_utils.const_max_integer)
                                   , NVL ( t_psn_initialnumvalue ( v_index ), 0 )
                                   , l_var_min
                                   , l_var_max
                                   , l_begin_date
                                   , l_end_date
                                   , LPAD ( t_psn_effectiveusagemask ( v_index ), 16, '0')
                                   );
               END IF;

            WHEN h_psntypes('bomoptionclass') THEN --> bom option class

               emit_bomoptionclass_def( v_index, NVL ( t_psn_decimalqtyflag(v_index), '0'));

               l_begin_date := NVL ( t_psn_effectivefrom(v_index), const_epoch_begin);
               l_end_date := NVL ( t_psn_effectiveuntil(v_index), const_epoch_end);

               IF ( l_begin_date < const_epoch_begin) THEN l_begin_date := const_epoch_begin; END IF;
               IF ( l_end_date > const_epoch_end) THEN l_end_date := const_epoch_end; END IF;

               --Bug #7039221.

               l_var_max := 1;

               IF ( NVL ( t_psn_maximumselected ( v_index ), -1 ) = -1 ) THEN

                  l_var_max := h_psnid_numberofchildren ( TO_CHAR ( t_psn_psnodeid ( v_index )));

               END IF;

               emit_bomoptionclassvar ( v_index
                                      , NVL ( t_psn_decimalqtyflag ( v_index ), '0')
                                      , NVL ( t_psn_bomrequiredflag ( v_index ), '0')
                                      , NVL ( t_psn_minimum ( v_index ), 0 )
                                      , NVL ( t_psn_maximum ( v_index ), cz_fce_compile_utils.const_max_integer )
                                      , NVL ( t_psn_initialnumvalue ( v_index ), 0 )
                                      , NVL ( t_psn_minimumselected ( v_index ), 0 )
                                      , l_var_max
                                      , l_begin_date
                                      , l_end_date
                                      , LPAD ( t_psn_effectiveusagemask ( v_index ), 16, '0' )
                                      );

            WHEN h_psntypes('bomstandard') THEN --> bom standard item

               l_begin_date := NVL ( t_psn_effectivefrom(v_index), const_epoch_begin);
               l_end_date := NVL ( t_psn_effectiveuntil(v_index), const_epoch_end);

               IF ( l_begin_date < const_epoch_begin) THEN l_begin_date := const_epoch_begin; END IF;
               IF ( l_end_date > const_epoch_end) THEN l_end_date := const_epoch_end; END IF;

               emit_bomstandarditemvar ( v_index
                                       , NVL ( t_psn_decimalqtyflag(v_index), '0')
                                       , NVL ( t_psn_bomrequiredflag (v_index), '0')
                                       , NVL ( t_psn_minimum(v_index), 0)
                                       , NVL ( t_psn_maximum(v_index), cz_fce_compile_utils.const_max_integer)
                                       , NVL ( t_psn_initialnumvalue(v_index), 0)
                                       , l_begin_date
                                       , l_end_date
                                       , LPAD ( t_psn_effectiveusagemask( v_index ), 16, '0' )
                                       );

            WHEN h_psntypes('beginstructure') THEN --> begin structure data

               IF (NOT h_devlid_modelvisited.EXISTS ( TO_CHAR ( t_psn_devlprojectid (v_index)))) THEN
                   IF p_model_path IS NULL OR p_model_path = '' THEN
                    l_model_path := t_psn_name ( v_index - 1 );
                   ELSE
                    l_model_path := p_model_path || '/' || t_psn_name ( v_index - 1 );
                   END IF;

                   compile_logic_file ( t_psn_devlprojectid ( v_index ), const_logicfile_def, l_model_path );

               END IF;

            WHEN h_psntypes('beginport') THEN --> begin port variables

               compile_logic_file ( p_component_id, const_logicfile_port, p_model_path );

            WHEN h_psntypes('beginrule') THEN --> begin port variables

               compile_logic_file ( p_component_id, const_logicfile_constraint, p_model_path );

            WHEN h_psntypes('endstructure') THEN --> end structure data

              EXIT;

            ELSE

              NULL;

        END CASE;
     END LOOP;
     ----------------------------------------------------------------------------------
     WHEN const_logicfile_port THEN
     ----------------------------------------------------------------------------------
     LOOP
        v_index := v_index + 1;

        CASE t_psn_psnodetype(v_index)

            WHEN h_psntypes('component') THEN --> component

               IF (t_psn_virtualflag ( v_index ) = h_instantiability ('nonvirtual')) THEN --> component instance

                  emit_instancesetvar ( v_index, t_psn_minimum(v_index), t_psn_maximum(v_index));

               ELSE --> mandatory component

                  emit_singletonvar (v_index);

               END IF; --> component

            WHEN h_psntypes('reference') THEN --> reference

               IF ( h_psnid_psnodetype ( TO_CHAR ( t_psn_referenceid (v_index))) = h_psntypes('bommodel')) THEN --> reference to BOM

                      --See Section 23.13.2 'BOM Instantiatibility and Quantity' in
                      --http://files.oraclecorp.com/content/AllPublic/SharedFolders/CZ-Dev-Project-Documents-Public/12.1/Design/CZ_CP_Engine_UI_FD.doc

                      IF ( t_psn_instantiableflag ( v_index ) = h_instantiability ('mandatory')) THEN

                         l_var_min := 1;
                         l_var_max := 1;

                      ELSIF ( t_psn_instantiableflag ( v_index ) = h_instantiability ('optional')) THEN

                         l_var_min := 0;
                         l_var_max := 1;

                      ELSE

                         l_var_min := 0;
                         l_var_max := NVL ( t_psn_maximumselected(v_index), cz_fce_compile_utils.const_max_integer);

                      END IF;

                      l_begin_date := NVL ( t_psn_effectivefrom(v_index), const_epoch_begin );
                      l_end_date := NVL ( t_psn_effectiveuntil(v_index), const_epoch_end );

                      IF ( l_begin_date < const_epoch_begin) THEN l_begin_date := const_epoch_begin; END IF;
                      IF ( l_end_date > const_epoch_end) THEN l_end_date := const_epoch_end; END IF;

                      emit_bommodelvar ( v_index
                                       , NVL ( h_psnid_decimalqtyflag ( TO_CHAR ( t_psn_referenceid (v_index))), '0')
                                       , NVL ( t_psn_bomrequiredflag (v_index), '0')
                                       , NVL ( t_psn_minimumselected(v_index), 0)
                                       , NVL ( t_psn_maximumselected(v_index), cz_fce_compile_utils.const_max_integer)
                                       , NVL ( t_psn_initialnumvalue(v_index), 0)
                                       , l_var_min
                                       , l_var_max
                                       , l_begin_date
                                       , l_end_date
                                       , LPAD ( t_psn_effectiveusagemask ( v_index ), 16, '0' )
                                       );

               ELSE --> component reference

                      emit_instancesetvar ( v_index, t_psn_minimum(v_index), t_psn_maximum(v_index));

               END IF;

            WHEN h_psntypes('connector') THEN --> connector

               emit_connectorsetvar ( v_index, t_psn_minimum(v_index), t_psn_maximum(v_index));

            WHEN h_psntypes('endport') THEN --> end port variables

              EXIT;

            ELSE

              NULL;

        END CASE;
     END LOOP;
     ----------------------------------------------------------------------------------
     WHEN const_logicfile_constraint THEN
     ----------------------------------------------------------------------------------

     --First generate all reverse port relations defined in the structure, then compile
     --constraints.

     l_reverseportcount := 0;

     LOOP
        v_index := v_index + 1;

        CASE t_psn_psnodetype(v_index)

            WHEN h_psntypes('endrule') THEN --> end port variables

              EXIT;

            ELSE

              emit_reverseport ( v_index );
              l_reverseportcount := l_reverseportcount + 1;

        END CASE;
     END LOOP;

     --#<optimization-reverseport>: Pop the nulls here in bulk.

     emit_pop ( l_reverseportcount );

     compile_constraints ();
     ----------------------------------------------------------------------------------
     END CASE;

     emit_return ();
     spool_logic_file ();

END compile_logic_file;
---------------------------------------------------------------------------------------
BEGIN --> compile_logic_

    IF ( x_run_id IS NULL OR x_run_id = 0 ) THEN

      SELECT cz_xfr_run_infos_s.NEXTVAL INTO x_run_id FROM DUAL;

    END IF;

    --Read effectivity sets into memory and build hash tables for quick lookup.

    SELECT effectivity_set_id, effective_from, effective_until
      BULK COLLECT INTO t_effset_effectivitysetid, t_effset_effectivefrom, t_effset_effectiveuntil
      FROM cz_effectivity_sets
     WHERE deleted_flag = '0';

    FOR i IN 1..t_effset_effectivitysetid.COUNT LOOP

       h_effsetid_effectivefrom ( TO_CHAR ( t_effset_effectivitysetid ( i ))) := t_effset_effectivefrom ( i );
       h_effsetid_effectiveuntil ( TO_CHAR ( t_effset_effectivitysetid ( i ))) := t_effset_effectiveuntil ( i );

    END LOOP;

   --Pass 1. Process the model data to transform it into the internal format.

   v_index := 1;
   h_devlid_modelvisited.DELETE;
   read_model_data ( p_object_id );

   --Pass 2. Compilation.

   v_index := 1;
   h_devlid_modelvisited.DELETE;
   compile_logic_file ( p_object_id, const_logicfile_def );

   IF ( p_two_phase_commit = 0 ) THEN COMMIT; END IF;

EXCEPTION
   WHEN CZ_LOGICGEN_ERROR THEN
          ROLLBACK;
   WHEN CZ_LOGICGEN_SYS_ERROR THEN
          ROLLBACK;
   WHEN OTHERS THEN
          ROLLBACK;
          -- Unknown Error:
          report_and_raise_sys_error(
            p_message => CZ_UTILS.GET_TEXT(CZ_FCE_UE_GENERIC_PREFIX) || DBMS_UTILITY.FORMAT_ERROR_STACK,
            p_run_id => x_run_id,
            p_model_id => p_object_id,
            p_error_stack => DBMS_UTILITY.FORMAT_ERROR_STACK || ' Error backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            p_raise_exception => FALSE
          );

END compile_logic_;
---------------------------------------------------------------------------------------
--Default method to generate logic in debug mode.

PROCEDURE debug_logic ( p_object_id IN NUMBER
                      , x_run_id    IN OUT NOCOPY NUMBER
                      ) IS
BEGIN

   compile_logic_ ( p_object_id, x_run_id, 0, 1 );

END debug_logic;
---------------------------------------------------------------------------------------
--Default method to generate logic for a model in the database.

PROCEDURE compile_logic ( p_object_id IN NUMBER
                        , x_run_id    IN OUT NOCOPY NUMBER
                        ) IS
BEGIN

   compile_logic_ ( p_object_id, x_run_id, 0, 0 );

END compile_logic;
---------------------------------------------------------------------------------------
--This method is not required in FCE as there is no DDL in generation of property-based
--compatibility rules (Re: bug #2028790). The caller of this method is responsible for
--commiting the generated logic to the database.

PROCEDURE compile_logic__ ( p_object_id IN NUMBER
                          , p_run_id    IN NUMBER
                          ) IS
  l_run_id  NUMBER := p_run_id;

BEGIN

   compile_logic_ ( p_object_id, l_run_id, 1, 0 );

END compile_logic__;
---------------------------------------------------------------------------------------
BEGIN

  CZ_FCE_DATA.populate_fce_data ();

END;

/
