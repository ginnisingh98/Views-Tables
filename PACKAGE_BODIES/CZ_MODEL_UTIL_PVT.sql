--------------------------------------------------------
--  DDL for Package Body CZ_MODEL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_MODEL_UTIL_PVT" AS
/* $Header: czvmdlub.pls 120.4 2008/05/08 12:14:54 jonatara ship $  */
-- COPIED FROM ARCS 2004-09-22 1230 EDT by ADW

  /*
   * Revisions 2004-07-30 by ADW as part of bugs 3804946 (3732895)
   * in function: FIND_NODES_BY_PATH
   *
   * Revision 2006-Feb by ADW for bug 4760372, parsing references that appear
   * ambiguous, but which are uniquely resolved at runtime due to non-
   * overlapping effectivities
   */

PS_NODE_TYPE_REFERENCE     CONSTANT PLS_INTEGER := 263;
PS_NODE_TYPE_COMPONENT     CONSTANT PLS_INTEGER := 259;
PS_NODE_TYPE_OPTION_CLASS  CONSTANT PLS_INTEGER := 437;

TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE number_tbl_type_idx_vc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15); -- --jonatara:int2long:bug7028517

--------------------------------------------------------------------------------
PROCEDURE get_referenced_models_pvt(p_parent_id  IN NUMBER
                                   ,px_model_tbl IN OUT NOCOPY number_tbl_type
                                   ,px_model_map IN OUT NOCOPY number_tbl_type_idx_vc2
                                   )
IS

BEGIN
  FOR psn_rec IN (SELECT ps_node_id, reference_id FROM cz_ps_nodes
                  WHERE deleted_flag = '0' AND parent_id = p_parent_id
                  AND ps_node_type IN (PS_NODE_TYPE_REFERENCE,
                                       PS_NODE_TYPE_COMPONENT,
                                       PS_NODE_TYPE_OPTION_CLASS)
                  ORDER BY tree_seq) LOOP
    IF (psn_rec.reference_id IS NOT NULL) THEN
      IF (NOT px_model_map.EXISTS(psn_rec.reference_id)) THEN
        px_model_tbl(px_model_tbl.COUNT + 1) := psn_rec.reference_id;
        px_model_map(psn_rec.reference_id) := psn_rec.reference_id;
      END IF;
    ELSE
      get_referenced_models_pvt(psn_rec.ps_node_id, px_model_tbl, px_model_map);
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_referenced_models_pvt;

--------------------------------------------------------------------------------
-- Returns array of distinct ordered referenced model ids under the top-level
-- model specified by p_model_id
--
-- For example, given the following model tree,
--    M1
--    |_OC
--    |  |_M2
--    |    |_OC
--    |    |  |_OC
--    |    |     |_OC
--    |    |        |_M3
--    |    |           |_M4
--    |    |_M5
--    |_M6
--      |_OC
--         |_M7
--           |_M5
-- the model_id field of the returned array will be [M1, M2, M6, M3, M5, M7, M4]
-- while the seq_nbr will be the same as the array indexes.

FUNCTION get_referenced_models(p_model_id IN NUMBER)
    RETURN system.cz_model_order_tbl_type
IS
  l_ret_tbl    system.cz_model_order_tbl_type := system.cz_model_order_tbl_type();
  l_model_map  number_tbl_type_idx_vc2;
  l_model_tbl  number_tbl_type;

  l_last_finished_index  PLS_INTEGER := 0;

BEGIN
  l_model_tbl(1) := p_model_id;
  l_model_map(p_model_id) := p_model_id;

  WHILE (l_last_finished_index < l_model_tbl.COUNT) LOOP
    l_last_finished_index := l_last_finished_index + 1;
    get_referenced_models_pvt(l_model_tbl(l_last_finished_index)
                             ,l_model_tbl
                             ,l_model_map
                             );
  END LOOP;

  l_ret_tbl.EXTEND(l_last_finished_index);
  FOR i IN l_model_tbl.FIRST .. l_model_tbl.LAST LOOP
    l_ret_tbl(i) := system.cz_model_order_obj_type(l_model_tbl(i), i);
  END LOOP;
  RETURN l_ret_tbl;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20999,
                      'cz_model_util_pvt.get_referenced_models: ' || SQLERRM);
    return NULL;
END get_referenced_models;

--------------------------------------------------------------------------------
FUNCTION find_nodes_by_path(p_model_to_search IN NUMBER
                           ,p_namepath IN system.cz_varchar2_2000_tbl_type
                           )
    RETURN system.cz_model_node_tbl_type
IS
    nodelist system.cz_model_node_tbl_type;
BEGIN

	nodelist := find_unique_node_by_path (
		p_model_to_search,
		p_namepath,
		p_path_preference => PATH_PREFERENCE_ROOT_KIDS
		);

	return nodelist;
END find_nodes_by_path;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
FUNCTION find_unique_node_by_path(p_model_to_search IN NUMBER
                           ,p_namepath IN system.cz_varchar2_2000_tbl_type
						   ,p_path_preference IN NUMBER
                           )
    RETURN "SYSTEM".cz_model_node_tbl_type
  /*
   * Revision 2006-02-21 by ADW for ambiguous reference bug 4760372
   * 1. moved marklist variables into main structure CZ_MODEL_NODE_OBJ_TYPE
   * 2. removed marklist handling from routine
   * 3. added new path-head information retrieval
   *
   * Revisions 2004-07-30 by ADW as part of bugs 3804946 (3732895)
   *
   * 1. move call to CZ_TYPES.GET_RULE_SIGNATURE_ID into queries instead of iterating
   * 2. fix parent/child relationship in subsequent-path query to use PARENT_PSNODE_EXPL_ID
   *    instead of decode
   * 3. implement preference for absolute path and/or direct-under-root path
   *    a. mark each partial path with whether or not it is ROOT using a parallel TABLE
   *    b. keep track of a high water mark for matches
   *    c. implement preference for 'root' paths
   */

IS
  retlist    "SYSTEM".cz_model_node_tbl_type := "SYSTEM".cz_model_node_tbl_type();
  lastfound  "SYSTEM".cz_model_node_tbl_type;

  /* ADW20040730:3a
   * Set up a parallel structure to mark which entries are paths from root
   * why overload the object types:1  1. need to do a table (cast), so an internal
   * record type won't work; must be an object type; 2. do not want to create a
   * new object type and table type in SYSTEM; 3. the structure is already almost
   * exactly what is needed
   */
  -- marklist	 "SYSTEM".cz_model_node_tbl_type := "SYSTEM".cz_model_node_tbl_type ();
  -- lastmarks	 "SYSTEM".cz_model_node_tbl_type;
  root_closest_path_index number;		   -- 20040730:3b
  root_closest_path_marker number;

  pathiter   integer;
  foundnodes CZ_EXPLMODEL_NODES_V%rowtype;
  foundcount integer := 0;

BEGIN
  -- Parameter check: namepath
  IF p_namepath.last IS NULL THEN
    RETURN NULL;
  END IF;

  FOR pathiter IN p_namepath.first .. p_namepath.last LOOP
    -- Another parm check... no embedded empty strings
    EXIT WHEN p_namepath(pathiter) IS NULL;

    -- copy RETLIST to another variable; it will be used as a query paremeter
    lastfound := retlist;

    -- clear RETLIST to get the next set of nodes
    retlist := "SYSTEM".cz_model_node_tbl_type();
    foundcount := 0;

    -- ADW20040730:3a move last MARKLIST into LASTMARKS for later query and reinitialize MARKLIST
    -- LASTMARKS := MARKLIST;
    -- MARKLIST  := "SYSTEM".cz_model_node_tbl_type ();
    -- ADW20060221 don't really need marklist any more

    -- ADW20040730:3b
    root_closest_path_marker := 10;
    root_closest_path_index  := null;

    IF pathiter = p_namepath.first THEN
      -- query all nodes in the model by the start of the path
      FOR foundnodes IN (
          SELECT
            XPLNODE.MODEL_REF_EXPL_ID,
            XPLNODE.psn_component_id              as COMPONENT_ID,
            XPLNODE.PS_NODE_ID,
            --
            CZ_TYPES.get_rule_signature_id (	 	-- ADW20040730:1
                  XPLNODE.instantiable_flag
                  ,XPLNODE.feature_type
                  ,XPLNODE.counted_options_flag
                  ,XPLNODE.maximum
                  ,XPLNODE.minimum
                  ,XPLNODE.psn_ps_node_type
                  ,XPLNODE.reference_id
                  ,XPLNODE.maximum_selected
                  ,XPLNODE.decimal_qty_flag
                  ,XPLNODE.ib_trackable
                  ,XPLNODE.devl_project_id
            )                                     as DETAILED_TYPE_ID,
            XPLNODE.ps_node_id                    as PATH_HEAD_PSNODE_ID,
            XPLNODE.model_ref_expl_id             as PATH_HEAD_EXPL_ID,
            --
            XPLNODE.effective_parent_id           as PATHHEAD_EFFPARENT_NODE_ID,
            XPLNODE.parent_psnode_expl_id         as PATHHEAD_EFFPARENT_EXPL_ID,
            XPLNODE.effective_from                as NODE_EFFECTIVE_FROM,
            --
            XPLNODE.effective_until               as NODE_EFFECTIVE_UNTIL,
            XPLNODE.effective_from                as WHOLE_PATH_EFFECTIVE_FROM,
            XPLNODE.effective_until               as WHOLE_PATH_EFFECTIVE_UNTIL,
            --
            decode (XPLNODE.parent_psnode_expl_id,	  -- ADW20040730:3a
                null, path_preference_root_only, -- only the model root has this calculated field null
                    ROOTEXPL.model_ref_expl_id, decode (XPLNODE.parent_id,
                        XPLNODE.model_id, path_preference_root_kids,
                             -- if parent is MODEL_ID, and the calc parent expl
                             -- is the root expl, this is a direct child of root
                        99),
                    999
                    )                             as NEAR_ROOT_MARKER
          FROM CZ_EXPLMODEL_NODES_V XPLNODE
               , CZ_MODEL_REF_EXPLS ROOTEXPL
          WHERE XPLNODE.model_id = p_model_to_search
            AND ROOTEXPL.MODEL_ID = P_MODEL_TO_SEARCH
            AND ROOTEXPL.parent_expl_node_id IS NULL
            AND ROOTEXPL.DELETED_FLAG = '0'
            AND XPLNODE.name = p_namepath(pathiter)
            AND suppress_flag = '0'
          )
      LOOP
        foundcount := foundcount + 1;
        retlist.extend ();
        -- push each node into retlist
        retlist (foundcount) := "SYSTEM".cz_model_node_obj_type (
            model_ref_expl_id           => foundnodes.MODEL_REF_EXPL_ID,
            component_id                => foundnodes.COMPONENT_ID,
            ps_node_id                  => foundnodes.PS_NODE_ID,
            --
            detailed_type_id            => foundnodes.DETAILED_TYPE_ID,
            path_head_psnode_id         => foundnodes.PATH_HEAD_PSNODE_ID,
            path_head_expl_id           => foundnodes.PATH_HEAD_EXPL_ID,
            --
            pathhead_effparent_node_id  => foundnodes.PATHHEAD_EFFPARENT_NODE_ID,
            pathhead_effparent_expl_id  => foundnodes.PATHHEAD_EFFPARENT_EXPL_ID,
            node_effective_from         => foundnodes.NODE_EFFECTIVE_FROM,
            --
            node_effective_until        => foundnodes.NODE_EFFECTIVE_UNTIL,
            whole_path_effective_from   => foundnodes.WHOLE_PATH_EFFECTIVE_FROM,
            whole_path_effective_until  => foundnodes.WHOLE_PATH_EFFECTIVE_UNTIL,
            --
            near_root_marker            => foundnodes.NEAR_ROOT_MARKER
            ); 	 	 -- ADW20040730:1

            if foundnodes.near_root_marker < root_closest_path_marker		  		 -- ADW20040730:3b
            then
                    root_closest_path_marker := foundnodes.near_root_marker;	   -- record the nearest to root
                    root_closest_path_index := foundcount;		 	   -- record the index of nearest
            elsif foundnodes.near_root_marker = root_closest_path_marker
            then -- a previous entry started just as close to root -- NULL THE INDEX OUT
                    root_closest_path_index := NULL;
            end if;

      END LOOP;
    ELSE
      -- query nodes in the model, but based on a parent-child relationship
      -- with records in prior query "lastfound"
      FOR foundnodes IN (
          SELECT
            XPLNODE.MODEL_REF_EXPL_ID,
            XPLNODE.PSN_COMPONENT_ID        as COMPONENT_ID,
            XPLNODE.PS_NODE_ID,
            --
            CZ_TYPES.get_rule_signature_id ( 		-- ADW20040730:1
                XPLNODE.instantiable_flag
                ,XPLNODE.feature_type
                ,XPLNODE.counted_options_flag
                ,XPLNODE.maximum
                ,XPLNODE.minimum
                ,XPLNODE.psn_ps_node_type
                ,XPLNODE.reference_id
                ,XPLNODE.maximum_selected
                ,XPLNODE.decimal_qty_flag
                ,XPLNODE.ib_trackable
                ,XPLNODE.devl_project_id
                )                           as DETAILED_TYPE_ID,
            PARNODE.PATH_HEAD_PSNODE_ID,
            PARNODE.PATH_HEAD_EXPL_ID,
            --
            PARNODE.PATHHEAD_EFFPARENT_NODE_ID,
            PARNODE.PATHHEAD_EFFPARENT_EXPL_ID,
            XPLNODE.effective_from          as NODE_EFFECTIVE_FROM,
            --
            XPLNODE.effective_until         as NODE_EFFECTIVE_UNTIL,
            greatest (
                PARNODE.whole_path_effective_from,
                XPLNODE.effective_from
                )                           as WHOLE_PATH_EFFECTIVE_FROM,
            least (
                PARNODE.whole_path_effective_until,
                XPLNODE.effective_until
                )                           as WHOLE_PATH_EFFECTIVE_UNTIL,
            --
            PARNODE.NEAR_ROOT_MARKER 			  -- ADW20040730:3a
          FROM
            CZ_EXPLMODEL_NODES_V XPLNODE,
            --                     table (cast (LASTMARKS AS cz_model_node_tbl_type)) PARMARK, -- ADW20040730:3a
            table (cast (LASTFOUND as "SYSTEM".cz_model_node_tbl_type)) PARNODE
          WHERE
            XPLNODE.model_id = p_model_to_search
            AND XPLNODE.name = p_namepath(pathiter)
            AND XPLNODE.effective_parent_id = PARNODE.PS_NODE_ID
            AND XPLNODE.parent_psnode_expl_id = PARNODE.model_ref_expl_id  -- ADW20040730:2
--            AND PARMARK.model_ref_expl_id = PARNODE.model_ref_expl_id      -- ADW20040730:3
--            AND PARMARK.ps_node_id = PARNODE.ps_node_id
            AND suppress_flag='0'
          )
      LOOP
        -- push each node into retlist
        foundcount := foundcount + 1;
        retlist.extend ();
        retlist (foundcount) := "SYSTEM".cz_model_node_obj_type (
            model_ref_expl_id           => foundnodes.MODEL_REF_EXPL_ID,
            component_id                => foundnodes.COMPONENT_ID,
            ps_node_id                  => foundnodes.PS_NODE_ID,
            --
            detailed_type_id            => foundnodes.DETAILED_TYPE_ID,
            path_head_psnode_id         => foundnodes.PATH_HEAD_PSNODE_ID,
            path_head_expl_id           => foundnodes.PATH_HEAD_EXPL_ID,
            --
            pathhead_effparent_node_id  => foundnodes.PATHHEAD_EFFPARENT_NODE_ID,
            pathhead_effparent_expl_id  => foundnodes.PATHHEAD_EFFPARENT_EXPL_ID,
            node_effective_from         => foundnodes.NODE_EFFECTIVE_FROM,
            --
            node_effective_until        => foundnodes.NODE_EFFECTIVE_UNTIL,
            whole_path_effective_from   => foundnodes.WHOLE_PATH_EFFECTIVE_FROM,
            whole_path_effective_until  => foundnodes.WHOLE_PATH_EFFECTIVE_UNTIL,
            --
            near_root_marker            => foundnodes.NEAR_ROOT_MARKER
            ); 	 	 -- ADW20060221

            if foundnodes.near_root_marker < root_closest_path_marker		-- ADW20040730:3b
            then
                    root_closest_path_marker := foundnodes.near_root_marker;	-- record the nearest to root
                    root_closest_path_index := foundcount;		 	-- record the index of nearest
            elsif foundnodes.NEAR_ROOT_MARKER = root_closest_path_marker
            then -- a previous entry started just as close to root -- NULL THE INDEX OUT
                    root_closest_path_index := NULL;
            end if;

      END LOOP;
    END IF;
    EXIT WHEN foundcount = 0;
  END LOOP;

  if -- ADW20040730:3c
  	  foundcount > 1
  	  and root_closest_path_index is not null
	  and root_closest_path_marker <= p_path_preference
  then
  	  lastfound := "SYSTEM".cz_model_node_tbl_type ();
	  lastfound.extend ();
	  lastfound (1) := retlist (root_closest_path_index);
	  return lastfound;
  else
  	  RETURN retlist;
  end if;



END find_unique_node_by_path;

--------------------------------------------------------------------------------

FUNCTION URFINMODEL_TO_STRING (P_UI_MODEL_ENTRY IN "SYSTEM".CZ_UIREFS_INMODEL_OBJ_TYPE) RETURN STRING
IS
	WORKINGSTRING VARCHAR2 (2000);
BEGIN
	WORKINGSTRING :=
		  'MODEL => ' || TO_CHAR (P_UI_MODEL_ENTRY.ROOT_MODEL_ID) ||
		', RTUDF => ' || TO_CHAR (P_UI_MODEL_ENTRY.ROOT_UI_DEF_ID) ||
		', RTXPL => ' || TO_CHAR (P_UI_MODEL_ENTRY.ROOT_MODEL_EXPL_ID) ||
		--
		', REFND => ' || TO_CHAR (P_UI_MODEL_ENTRY.REFERRING_NODE_ID) ||
		', XDEEP => ' || TO_CHAR (P_UI_MODEL_ENTRY.EXPL_NODE_DEPTH) ||
		', REFDP => ' || TO_CHAR (P_UI_MODEL_ENTRY.MODEL_REFERENCE_DEPTH) ||
		--
		', VIRTF => ' || P_UI_MODEL_ENTRY.VIRTUAL_FLAG ||
		', CHLUI => ' || TO_CHAR (P_UI_MODEL_ENTRY.CHILD_UI_DEF_ID) ||
		', PARUI => ' || TO_CHAR (P_UI_MODEL_ENTRY.PARENT_UI_DEF_ID) ||
		--
		', CHMDL => ' || TO_CHAR (P_UI_MODEL_ENTRY.CHILD_MODEL_ID) ||
		', REFXP => ' || TO_CHAR (P_UI_MODEL_ENTRY.REF_EXPL_NODE_ID) ||
		', LEAFX => ' || TO_CHAR (P_UI_MODEL_ENTRY.LEAF_EXPL_NODE_ID) ||
		--
		', LEAFN => ' || TO_CHAR (P_UI_MODEL_ENTRY.LEAF_PERSISTENT_NODE_ID) ||
		'';
	RETURN WORKINGSTRING;
END URFINMODEL_TO_STRING;

--------------------------------------------------------------------------------
FUNCTION get_ui_refs_under_model (
	p_root_ui_def_id IN NUMBER,
	p_maxdepth IN NUMBER
) return
	system.CZ_UIREFS_INMODEL_TBL_TYPE
IS
	listsofar system.CZ_UIREFS_INMODEL_TBL_TYPE := "SYSTEM".CZ_UIREFS_INMODEL_TBL_TYPE ();
	listsize number := 0;
	curdepth number := 0;
	depthcount number := 0;
	childuihack number;
	parentuihack number;
BEGIN
	FOR rootinfo in (
		select
			udf.devl_project_id        as root_model_id,
			udf.ui_def_id              as root_ui_def_id,
			xpl.model_ref_expl_id      as root_model_expl_id,
			xpl.parent_expl_node_id	   as root_mdl_parnt_expl_id,
			to_number (null)           as referring_node_id,
			xpl.node_depth             as expl_node_depth,
			0                          as model_reference_depth,
			'1'                        as virtual_flag,
			udf.ui_def_id              as child_ui_def_id,
			to_number (null)		   as parent_ui_def_id,
			udf.devl_project_id        as child_model_id,
			xpl.model_ref_expl_id      as ref_expl_node_id,
			xpl.model_ref_expl_id 	   as leaf_expl_node_id,
			rootn.persistent_node_id   as leaf_persistent_node_id
		from
			cz_ui_defs udf,
			cz_model_ref_expls xpl,
			cz_ps_nodes rootn
		where
			rootn.deleted_flag = '0' and
			rootn.ps_node_id = xpl.component_id and
			xpl.model_id = udf.devl_project_id and
			xpl.deleted_flag = '0' and
			xpl.parent_expl_node_id is null and
			udf.ui_def_id = p_root_ui_def_id and
			udf.deleted_flag = '0'
		)
	LOOP
		listsofar.extend ();
		listsize := listsize + 1;
		listsofar (listsize) := system.cz_uirefs_inmodel_obj_type (
			ROOT_MODEL_ID => rootinfo.ROOT_MODEL_ID,
			ROOT_UI_DEF_ID => rootinfo.ROOT_UI_DEF_ID,
			ROOT_MODEL_EXPL_ID => rootinfo.ROOT_MODEL_EXPL_ID,
			ROOT_MDL_PARNT_EXPL_ID => rootinfo.ROOT_MDL_PARNT_EXPL_ID,
			referring_node_id => rootinfo.referring_node_id,
			expl_node_depth => rootinfo.expl_node_depth,
			model_reference_depth => rootinfo.model_reference_depth,
			virtual_flag => rootinfo.virtual_flag,
			child_ui_def_id => rootinfo.child_ui_def_id,
			parent_ui_def_id => rootinfo.parent_ui_def_id,
			child_model_id => rootinfo.child_model_id,
			ref_expl_node_id => rootinfo.ref_expl_node_id,
			leaf_expl_node_id => rootinfo.leaf_expl_node_id,
			leaf_persistent_node_id => rootinfo.leaf_persistent_node_id
		);
		depthcount := depthcount + 1;

-- 		DBMS_OUTPUT.PUT_LINE ('Root fetch: curdepth ' || to_char (curdepth) ||
-- 			', depthcount ' || to_char (depthcount) ||
-- 			', listsize ' || to_char (listsize));
-- 		dbms_output.put_line (urfinmodel_to_string (listsofar (listsize)));
	END LOOP;

	curdepth := curdepth + 1;
	if depthcount = 0 then return listsofar; end if;


    LOOP
	    EXIT WHEN curdepth > p_maxdepth;

		depthcount := 0;
    	for nextinfo in (
			select
				rootxp.model_id as root_model_id,
				extlist.root_ui_def_id as root_ui_def_id,
				rootxp.model_ref_expl_id as root_model_expl_id,
				rootxp.parent_expl_node_id as root_mdl_parnt_expl_id,
				rootxp.referring_node_id,
				rootxp.node_depth as expl_node_depth,
				extlist.model_reference_depth + decode (extlist.child_model_id,
					DECODE (enclexpl.ps_node_type,
						263, enclexpl.component_id,
						264, enclexpl.component_id,
						enclexpl.model_id
					), 0,
					1
					) as model_reference_depth,
				rootxp.virtual_flag,
 				extlist.child_ui_def_id as child_ui_def_id,
				extlist.parent_ui_def_id as parent_ui_def_id,
				DECODE (enclexpl.ps_node_type,
					263, enclexpl.component_id,
					264, enclexpl.component_id,
					enclexpl.model_id
					) as child_model_id,
				enclexpl.model_ref_expl_id as ref_expl_node_id,
				enclexpl.child_model_expl_id as leaf_expl_node_id,
				comp.persistent_node_id as leaf_persistent_node_id
			from
				cz_ps_nodes comp,
				cz_model_ref_expls rootxp,
				cz_model_ref_expls enclexpl,
				table (cast (listsofar as "SYSTEM".cz_uirefs_inmodel_tbl_type)) extlist
			where
				comp.ps_node_id = rootxp.component_id and
				comp.deleted_flag = '0' and
			    rootxp.node_depth = curdepth and
				extlist.expl_node_depth = curdepth - 1 and
				rootxp.component_id = enclexpl.component_id and
				decode (rootxp.referring_node_id, enclexpl.referring_node_id, 1, 0) = 1 and
			    rootxp.deleted_flag = '0' and
				rootxp.parent_expl_node_id = EXTLIST.ROOT_model_expl_id and
				enclexpl.deleted_flag = '0' and
				enclexpl.parent_expl_node_id in (EXTLIST.REF_EXPL_NODE_id,
					EXTLIST.LEAF_EXPL_NODE_ID)
				-- 2004-09-22 ADW: this join criterion from the 'parent row' would spelunk down references
				-- to the child UI/expl but NOT in the parent UI/expl tree.  I think only the following clause
				-- caused this behavior.  Minor tweak above may fix the problem...
-- 				enclexpl.parent_expl_node_id = decode (EXTLIST.referring_node_id,
-- 					null, EXTLIST.REF_EXPL_NODE_id,
-- 					EXTLIST.LEAF_EXPL_NODE_ID)
    		)
		loop
			listsofar.extend ();
			listsize := listsize + 1;
			begin
				select
					urf.ref_ui_def_id as current_child_ui,
					urf.ui_def_id as current_parent_ui
				into
					childuihack,
					parentuihack
				from cz_ui_refs urf
				where
					nextinfo.ref_expl_node_id = urf.model_ref_expl_id AND
					nextinfo.child_ui_def_id = urf.ui_def_id and
					urf.deleted_flag = '0';
--				dbms_output.put_line ('Fetched reference info for expl and UI');
			exception
				when NO_DATA_FOUND then
--					dbms_output.put_line ('No ref info available, using prior');
					childuihack := nextinfo.child_ui_def_id;
					parentuihack := nextinfo.parent_ui_def_id;
			end;
			listsofar (listsize) := system.cz_uirefs_inmodel_obj_type (
				ROOT_MODEL_ID => nextinfo.ROOT_MODEL_ID,
				ROOT_UI_DEF_ID => nextinfo.ROOT_UI_DEF_ID,
				ROOT_MODEL_EXPL_ID => nextinfo.ROOT_MODEL_EXPL_ID,
				ROOT_MDL_PARNT_EXPL_ID => nextinfo.ROOT_MDL_PARNT_EXPL_ID,
				referring_node_id => nextinfo.referring_node_id,
				expl_node_depth => nextinfo.expl_node_depth,
				model_reference_depth => nextinfo.model_reference_depth,
				virtual_flag => nextinfo.virtual_flag,
				child_ui_def_id => childuihack,
				parent_ui_def_id => parentuihack,
				child_model_id => nextinfo.child_model_id,
				ref_expl_node_id => nextinfo.ref_expl_node_id,
				leaf_expl_node_id => nextinfo.leaf_expl_node_id,
				leaf_persistent_node_id => nextinfo.leaf_persistent_node_id
			);
			depthcount := depthcount + 1;

-- 			DBMS_OUTPUT.PUT_LINE ('Next-level fetch: curdepth ' || to_char (curdepth) ||
-- 				', depthcount ' || to_char (depthcount) ||
-- 				', listsize ' || to_char (listsize));
-- 			dbms_output.put_line (urfinmodel_to_string (listsofar (listsize)));
		end loop;

-- 		DBMS_OUTPUT.PUT_LINE ('End of per-level loop: curdepth ' || to_char (curdepth) ||
-- 			', depthcount ' || to_char (depthcount) ||
-- 			', listsize ' || to_char (listsize));
-- 		dbms_output.put_line (urfinmodel_to_string (listsofar (listsize)));

		if depthcount = 0 then return listsofar; end if;

		curdepth := curdepth + 1;

    END LOOP;
	return listsofar;
EXCEPTION
	WHEN OTHERS THEN
--		dbms_output.put_line ('Received exception ' || sqlerrm);
		raise;
END get_ui_refs_under_model;
--------------------------------------------------------------------------------

  FUNCTION get_parallel_expls (p_encl_expl_id in number, p_desc_expl_id in number, p_max_expl_depth in number)
  return "SYSTEM".cz_expl_pair_tbl
  is
  	  -- Added new component to CZ_EXPL_PAIR for bug 4486182, 7/12/2005
	  -- model reference depth, to support field of same name in cz_uicomponent_hgrid_v
	  --
	  -- restructured algorithm 2004-10-12
	  -- uses the same parallel-expl query structure, but instead of joining to a table case as cz_expl_pair_tbl,
	  -- this approach simply iterates over the pairs and gets the matching children for each
	  -- this allows me to use a single cz_expl_pair_tbl.
	  pairs "SYSTEM".cz_expl_pair_tbl := "SYSTEM".cz_expl_pair_tbl ();
	  paircount number;
	  newpair "SYSTEM".cz_expl_pair;
	  cur_pair_index number;
	  start_encl_depth number;
	  desc_ref_depth number;
	  curdepth number;
  begin
  	  -- first -- verify that p_desc_expl_id really is a child model expl ID of p_encl_expl_id
	  -- we can also use this to calculate MODEL_REFERENCE_DEPTH
	  begin
		  select (level - 1) into desc_ref_depth
		  from cz_model_ref_expls
		  where model_ref_expl_id = p_desc_expl_id and deleted_flag = '0'
		  start with model_ref_expl_id = p_encl_expl_id and deleted_flag = '0'
		  connect by model_ref_expl_id = prior child_model_expl_id and deleted_flag = '0' and
		  prior model_ref_expl_id <> p_desc_expl_id;

		  -- FOLLOWING probably won't occur, I expect NO_DATA_FOUND exception, but I'll play
		  -- it safe
		  if SQL%ROWCOUNT = 0 then return pairs; end if;

	  exception
		  when NO_DATA_FOUND then
			  return pairs;
	  end;

	  -- to honor the "limiter", we get the original explosion depth.  This will be used to determine
	  -- if we have exceeded the depth limit specified by the P_MAX_EXPL_DEPTH parameter
	  select node_depth into start_encl_depth
	  from cz_model_ref_expls
	  where model_ref_expl_id = p_encl_expl_id;

	  -- get some room
	  pairs.extend ();
	  paircount := 1;

	  -- take the requested pair, instantiate it, and put it at the top of the results
	  pairs (paircount) := "SYSTEM".cz_expl_pair (
			  ENCLOSING_EXPL_ID         => p_encl_expl_id,
			  DESCENDANT_EXPL_ID        => p_desc_expl_id,
			  DESC_EXPL_REFERENCE_DEPTH => desc_ref_depth
			  );
	  curdepth := start_encl_depth;
	  cur_pair_index := 0;

	  -- LOOP:  track down the explosions in parallel
	  -- loop invariants:
	  --     CUR_PAIR_INDEX -- each iteration of the loop "consumes" a pair from the results table ("pairs")
	  --         and searches for child explosions (paired) for that pair.  Each one found is appended to PAIRS,
	  --         which obviously increases PAIRS.LAST, continuing the iteration
	  --     CURDEPTH -- the loops track the depth from the NODE_DEPTH variable.  When the depth has gotten to
	  --         the limit specified in P_MAX_EXPL_DEPTH, the loop exits
	  while
		  cur_pair_index < pairs.last
			  and
		  (p_max_expl_depth is null or (1 + curdepth - start_encl_depth) < p_max_expl_depth)
	  loop
	  	  cur_pair_index := cur_pair_index + 1;
		  -- increment the index to "look" at the next pair in the results table

	  	  for nextpair in (
			  select
				  r_xp.model_ref_expl_id as encl_expl,
				  r_xp.node_depth as encl_depth,
 				  c_xp.model_ref_expl_id as desc_expl
			  from
 			  	  cz_model_ref_expls r_xp,
 				  cz_model_ref_expls c_xp
			  where
			          -- retrieve the child expl nodes of both the ENCL and DESC nodes in the current pair
				  r_xp.parent_expl_node_id = pairs (cur_pair_index).enclosing_expl_id and
				  c_xp.parent_expl_node_id = pairs (cur_pair_index).descendant_expl_id and
				      -- restrict to expl pairs that match by component ID and by non-null REFERRING_NODE_ID
				  r_xp.component_id = c_xp.component_id and
				  decode (r_xp.referring_node_id, c_xp.referring_node_id, 1, 0) = 1 and
				      -- filter deleted expls
				  r_xp.deleted_flag = '0' and
				  c_xp.deleted_flag = '0'
		  )
		  loop
			  newpair := "SYSTEM".cz_expl_pair (
					  ENCLOSING_EXPL_ID         =>  nextpair.encl_expl,
					  DESCENDANT_EXPL_ID        => nextpair.desc_expl,
					  DESC_EXPL_REFERENCE_DEPTH => desc_ref_depth);
			  pairs.extend ();
			  paircount := paircount + 1;
			  pairs (paircount) := newpair;
			  curdepth := nextpair.encl_depth;
--			  dbms_output.put_line ('ending inner loop with ' || to_char (pairs.last) || ' pairs and ' ||
--			  	  to_char (frompairs.last) || ' in frompairs');
		  end loop;

	  end loop;

  	  return pairs;
  end get_parallel_expls;

END cz_model_util_pvt;

/
