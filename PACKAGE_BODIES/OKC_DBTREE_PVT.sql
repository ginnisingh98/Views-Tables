--------------------------------------------------------
--  DDL for Package Body OKC_DBTREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DBTREE_PVT" AS
/*$Header: OKCTREEB.pls 120.1 2006/02/17 06:51:34 maanand noship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--===================
-- TYPES
--===================
-- add your type declarations here if any
--


--===================
-- CONSTANTS
--===================
   G_PKG_NAME CONSTANT VARCHAR2(30) := 'OKCTREE';
--
-- add your constants here if any

--===================
-- GLOBAL VARIABLES
--===================
-- add your private global variables here if any
--
      MaxDataRecs      NUMBER;

--
-- ========================================================
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ========================================================
--

--
--
--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  SaveNodeIndex                                                      --
-- PURPOSE:   Updates the start/stop index of the node's children in the          --
--            IControltable for the tree id and node number passed                --
-- DEPENDENCIES: the IControlTable has been intitialized                          --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE SaveNodeIndex
              (p_tree_id	IN	NUMBER
               ,p_node_number   IN      NUMBER
               ,p_start		IN	NUMBER
               ,p_end           IN      NUMBER
              )
IS
      i		NUMBER := 0;
      node_updated   BOOLEAN;

BEGIN
  i := 0;
  node_updated := FALSE;

  FOR i in IControlTable.FIRST..IControlTable.LAST LOOP
     IF IControlTable.EXISTS(i) THEN
          IF (IControlTable(i).tree_id = p_tree_id AND
             IControlTable(i).node_number = p_node_number) THEN
                 IControlTable(i).start_ind := p_start;
                 IControlTable(i).end_ind := p_end;
                 IControlTAble(i).num_entries := p_end - p_start + 1;
                 IControLTable(i).current_set := 1;
                 node_updated := TRUE;
                 EXIT;
          END IF;
     END IF;
  END LOOP;

--
--   if no nodes were updated, then add one to the end of the table
--
  IF NOT node_updated THEN
       IControlTable.EXTEND;
       i := IControlTable.LAST;
       IControlTable(i).tree_id := p_tree_id;
       IControlTable(i).node_number := p_node_number;
       IControlTable(i).start_ind := p_start;
       IControlTable(i).end_ind := p_end;
       IControlTable(i).num_entries := p_end - p_start + 1;
       IControlTable(i).current_set := 1;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
      raise_application_error(-20407,'Exception in SaveNodeIndex: ' || to_char(p_tree_id)
                               || ':' || to_char(p_node_number)
                               || ':' || to_char(p_start)
                               || ':' || to_char(p_end) ,TRUE );
END    SaveNodeIndex;
--
--
--
-- ---------------------------------------------------------------------------------
-- FUNCTION:  GetNodeIndex                                                        --
-- PURPOSE:   Gets the requested attribute from IControlTable for the             --
--            tree/level/node number passed                                       --
--                                                                                --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION GetNodeIndex
              ( p_tree_id	IN	NUMBER
               ,p_node_number	IN	NUMBER
               ,p_type		IN	VARCHAR2
              )
RETURN NUMBER IS
    i		       NUMBER;
BEGIN
  i := 0;
  FOR i IN IControlTable.FIRST..IControlTable.LAST LOOP
    IF (IControlTable(i).tree_id = p_tree_id
       AND IControlTable(i).node_number = p_node_number) THEN
       IF p_type = 'START' THEN
          return IControlTAble(i).start_ind;
       ELSIF p_type = 'END' THEN
          return IControlTAble(i).end_ind;
       ELSIF p_type = 'ENTRY' THEN
          return IControlTAble(i).num_entries;
       ELSIF p_type = 'SET' THEN
	  return IControLTable(i).current_set;
       END IF;
    END IF;
  END LOOP;

  return -1;
EXCEPTION
  WHEN OTHERS THEN
       raise_application_error(-20408,'Exception in GetNodeIndex: ' || to_char(p_tree_id)
                                || ':' || to_char(p_node_number)
                                || ':' || p_type, TRUE );
END      GetNodeIndex;
--
--
--
-- ---------------------------------------------------------------------------------
-- FUNCTION:  get_data_parameter                                                  --
-- PURPOSE:   Returns the requested parameter from the data string passed.        --
--            Paramters are separated by '\'. Parameter names passed are:         --
--                   TYPE - parameter 1 - node type (ROOT,GRP,KHDR)               --
--                   LEVEL - parameter 2 - level of the node 0 = root             --
--                   NODEID - parameter 3 - index# for node in tDataTable         --
--                   CHILD - parameter 4 - #of children for this node             --
--                   OCCUR - parameter 5 - id value of the corresponding row      --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
FUNCTION    get_data_parameter
                (p_data_string          IN      VARCHAR2,
                 p_parm_name            IN      VARCHAR2
                )
RETURN VARCHAR2 IS
      x                       NUMBER := 0;
      plen                    NUMBER := 0;
      parmno                  NUMBER := 0;
BEGIN
  IF p_parm_name = 'TYPE' THEN
     parmno := 1;
  ELSIF p_parm_name = 'LEVEL' THEN
     parmno := 2;
  ELSIF p_parm_name = 'NODEID' THEN
     parmno := 3;
  ELSIF p_parm_name = 'CHILD' THEN
     parmno := 4;
  ELSIF p_parm_name = 'OCCUR' THEN
     parmno := 5;
  END IF;

  IF parmno < 1 THEN
     raise_application_error(-20106,'Invalid Parmater Name received', TRUE);
  END IF;

  x := INSTR(p_data_string,'\',1,parmno) + 1;
  plen := INSTR(p_data_string,'\',1,parmno+1) - x;

  return  SUBSTR(p_data_string,x,plen);

EXCEPTION
   WHEN OTHERS THEN
	raise_application_error(-20105,'Failure in get_data_parameter: ' || p_parm_name
					|| ':' || substr(p_data_string,1,150), TRUE);

END     get_data_parameter;

--
--
--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  DeleteControlRec                                                   --
-- PURPOSE:    Deletes the row corresponding to the tree_id, node_number passed   --
--             from the IControlTable                                             --
-- Dependencies: None                                                             --
-- ---------------------------------------------------------------------------------
--
PROCEDURE DeleteControlRec
                (p_tree_id        IN   NUMBER
                 ,p_node_number   IN   NUMBER)
IS
    i             NUMBER := 0;
BEGIN
   i := IControlTable.FIRST;
   WHILE i <= IControlTable.LAST LOOP
	IF (IControlTable(i).tree_id = p_tree_id
            AND IControlTable(i).node_number = p_node_number) THEN
		IControlTable.DELETE(i);
                EXIT;
	END IF;
	i := IControltable.NEXT(i);
   END LOOP;

EXCEPTION
   WHEN OTHERS THEN
	raise_application_error(-20195,'Failure inDeleteControlRec: ' || to_char(p_tree_id)
					|| ':' || to_char(p_node_number), TRUE);

END   DeleteControlRec;

--
--
--
-- ========================================================
-- PUBLIC PROCEDURES AND FUNCTIONS
-- ========================================================
--
--
--
PROCEDURE push_error
		(p_package_name		IN	VARCHAR2
		,p_program_name		IN	VARCHAR2
		,p_entry_point		IN	NUMBER
		,p_error_type		IN	VARCHAR2
		,p_error_msg		IN	VARCHAR2
		 )
IS
BEGIN
	null;
END  push_error;


PROCEDURE pop_error
		(p_delete_flag		IN	BOOLEAN
		,p_Package_name	 OUT NOCOPY VARCHAR2
		,p_program_name	 OUT NOCOPY VARCHAR2
		,p_entry_point	 OUT NOCOPY NUMBER
		,p_error_type	 OUT NOCOPY VARCHAR2
		,p_error_msg	 OUT NOCOPY VARCHAR2
		)
IS
BEGIN
	null;
END  pop_error;

PROCEDURE clear_stack
IS
BEGIN
	null;
END  clear_stack;
--
--
--
-- ------------------------------------------------------------------------------
--  FUNCITON:	Get_Tree_ID                                                    --
--  PURPOSE:	Converts the tree name passed to the id in the tree definition --
--		table.                                                         --
-- ------------------------------------------------------------------------------
--
FUNCTION  Get_Tree_ID
		(p_tree_name		IN	VARCHAR2
		)
	RETURN NUMBER
IS
   id_out		NUMBER := 0;

BEGIN
--
   return 1;

END     Get_Tree_id;
--
--
--
--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  ClearNodeCache                                                     --
-- PURPOSE:    Clears the tree formatted records cached in a PLSQL table          --
--             for the treeid and level number passed by deleting the rows        --
--             from this table and then updating the start/end pointers for the   --
--             node in the IControl TAble. If the IControlTable entry is not      --
--             found then the children were never queried and this routine        --
--             does nothing                                                       --
-- Prerequisites: None.                                                           --
--                                                                                --                                                                               --
-- ---------------------------------------------------------------------------------
--

PROCEDURE ClearNodeCache
		(p_tree_id		IN	NUMBER
		 ,p_node_number		IN	NUMBER)
IS
    x		NUMBER := 0;
    y		NUMBER := 0;

BEGIN
--
--  initialize the table records table (index by table)
--
   x := GetNodeIndex(p_tree_id, p_node_number, 'START');
   y := GetNodeIndex(p_tree_id, p_node_number, 'END');

--
--  Loop thru each table entry and delete any children queried for that node
--  Delete the child node entry in IControlTAable when done
--

   WHILE x <= y LOOP
       okc_dbtree_pvt.ClearNodeCache(p_tree_id, tDataTable(x).tree_node_id);
       okc_dbtree_pvt.DeleteControlRec(p_tree_id, tDataTable(x).tree_node_id);
       tDataTable.DELETE(x);

       x:= tDataTable.NEXT(x);

   END LOOP;

--
--   Update the Control Table for the node_number passed to reflect the deleted rows
--
   SaveNodeIndex(p_tree_id, p_node_number, 0, 0);

END   ClearNodeCache;

--
--
--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  ProcessRootNode                                                    --
-- PURPOSE:    process the root node for the Contracts group tree and put results --
--             in the tDataTable table.                                           --
--             Access flag parameter controls which groups are selected:          --
--                 'U' = Public only                                              --
--                 'P' = Private Only                                             --
--                 'A' = both public and private                                  --
-- DEPENDENCIES:  tDataTable must be initialized and empty                        --
-- ---------------------------------------------------------------------------------
--
PROCEDURE ProcessRootNode
              (  p_tree_id              IN  NUMBER
                 ,p_access_flag         IN  VARCHAR2 )
IS
/*
  CURSOR   rt (gflag   In  VARCHAR2) IS
        select  id,
                name,
                public_yn,
                created_by,
                creation_date,
                okc_query.GetChildCount(id) numchildren
         from   okc_k_groups_v g
        where   NOT EXISTS (select  1
                              from  okc_k_grpings_v p
                             where  p.included_cgp_id = g.id)
          AND   ( (g.public_yn = decode(gflag,'U','Y',gflag,'A','Y'))
                 OR (g.public_yn = decode(gflag,'P','N') AND created_by = 10589)
                 OR (gflag = 'A' AND created_by = 10589)
                )
        ORDER BY g.name;
*/
-- The cursor has been modified by manash to take care of public/private grouping problem Bug#1159200

/*
  CURSOR   rt (gflag   In  VARCHAR2) IS
        select  id,
                name,
                public_yn,
                created_by,
                creation_date,
                okc_query.GetChildCount(id) numchildren
         from   okc_k_groups_v g
        where   NOT EXISTS (select  1
                              from  okc_k_grpings_v p
                             where  p.included_cgp_id = g.id)
          AND   ( (g.public_yn = decode(gflag,'U','Y','A','Y'))
                 OR (g.public_yn = decode(gflag,'P','N') AND user_id = FND_GLOBAL.USER_ID)
                 OR (gflag = 'A' AND user_id = FND_GLOBAL.USER_ID)
                )
        ORDER BY g.name;
*/
-- The cursor has been modified by manash to take care of public/private grouping problem Bug#1159200

-- Bug Bug Fix 4958704 - Performance issue

  CURSOR   rt (gflag   In  VARCHAR2) IS
        select  id,
                name,
                public_yn,
                created_by,
                creation_date,
                okc_query.GetChildCount(id) numchildren
         from   okc_k_groups_v g
        where   NOT EXISTS (
				select  1
				from  okc_k_grpings_v p, okc_k_groups_v g1
				where  p.included_cgp_id = g.id
				and	g1.id = p.cgp_parent_id
				and 	g1.public_yn = 'Y'

				UNION

				select  1
				from  okc_k_grpings_v p, okc_k_groups_v g1
				where  p.included_cgp_id = g.id
				and	g1.id = p.cgp_parent_id
				AND   g1.public_yn = 'N' and g1.user_id = FND_GLOBAL.USER_ID
			   )
          AND   ( (g.public_yn = decode(gflag,'U','Y','A','Y'))
                 OR (g.public_yn = decode(gflag,'P','N') AND user_id = FND_GLOBAL.USER_ID)
                 OR (gflag = 'A' AND user_id = FND_GLOBAL.USER_ID)
                )
        ORDER BY g.name;


-- Bug Bug Fix 4958704

    i                  NUMBER;
    x                  NUMBER;
    pname              VARCHAR2(20);
    rows_fetched       NUMBER := 0;
    More_records       BOOLEAN := FALSE;
    num_children       NUMBER := 0;

BEGIN
    tDataTable := TreeDataTableType();
    IControlTable := IndexControlTable();
   --
   --    store the root node as entry 1 in the data table....
   --
   TDataTable.EXTEND;
   x := TDataTable.LAST;
   tDataTable(x).tree_initial_state := 1;
   tDataTable(x).tree_depth := 1;
   tDataTable(x).tree_label := 'Contracts Group Root';
   tDataTable(x).tree_icon_name := okc_dbtree_pvt.icon_name;
   tDataTable(x).tree_data := '\ROOT\0\' || to_char(x) || '\3\root\';
   tDataTable(x).tree_node_id := x;
   tDataTable(x).tree_node_type := 'GRP';
   tDataTable(x).tree_parent_node_id := null;
   tDataTable(x).tree_level_number := 1;

   --
   --   store a Controltable entry for the root so start/stop for its
   --   children can be saved in the following query
   --
   IControlTable.EXTEND;
   x := IControlTable.LAST;
   IControlTable(x).tree_id := p_tree_id;
   IControlTable(x).node_number := 1;
   IControlTable(x).start_ind := 0;
   IControlTable(x).end_ind := 0;
   IControlTable(x).num_entries := 0;
   IControlTable(x).current_set := 1;
--
--   execute the query and put the results into the datatable
--
   rows_fetched := 0;
   FOR rtrec IN rt(p_access_flag) LOOP
     --
     --   Process the record just fetched into the TDataTable
     --
     rows_fetched := rows_fetched + 1;

     TDataTAble.EXTEND;
     x := TDataTable.LAST;

     tDataTable(x).tree_depth := 1;
     tDataTable(x).tree_label := rtrec.name;
	if rtrec.public_yn = 'Y' then
       tDataTable(x).tree_icon_name := 'treepubl';
	else
       tDataTable(x).tree_icon_name := 'treepers';
	end if;
     tDataTable(x).tree_num_children := rtrec.numchildren;

     IF rtrec.numchildren > 0 THEN
         tDataTable(x).tree_initial_state := 1;
     ELSE
         tDataTable(x).tree_initial_state := 0;
     END IF;
     tDataTable(x).tree_data := '\GRP' || '\1' || '\' || to_char(x) || '\'
                                || to_char(rtrec.numchildren) || '\'
                                || to_char(rtrec.id) || '\';
     tDataTable(x).tree_node_id := x;
     tDataTable(x).tree_node_type := 'GRP';
     tDataTable(x).tree_parent_node_id := 1;
     tDataTable(x).tree_level_number := 1;

  END LOOP;

  --
  --  Update the level controls into IControltable
  --
   SaveNodeIndex (p_tree_id ,1 ,2 ,x);

--  for i in 1..x LOOP
--      jrt_message('OKCDBTREE-ProcessRootNode', to_char(i) || ':' || 'Data: ' || tDataTable(i).tree_data, sysdate);
--      jrt_message('OKCDBTREE-ProcessRootNode', to_char(i) || ':' || 'NodeType: ' || tDataTable(i).tree_node_type, sysdate);
--      jrt_message('OKCDBTREE-ProcessRootNode', to_char(i) || ':' || 'NodeId: ' || to_char(tDataTable(i).tree_node_id), sysdate);
--      jrt_message('OKCDBTREE-ProcessRootNode', to_char(i) || ':' || 'LevelNo: ' || to_char(tDataTable(i).tree_level_number), sysdate);
--  END LOOP;

--  FOR x in IControlTable.FIRST..IControlTable.LAST LOOP
--      jrt_message('OKCDBTREE-ProcessRootNode', ' Control Entry: ' || to_char(x) || ' TreeID:'
--           || to_char(IControlTable(x).tree_id) || ' Node:'
--           || to_char(IControlTable(x).node_number) || ' Start:'
--           || to_char(IControlTable(x).start_ind) || ' End:'
--           || to_char(IControlTable(x).end_ind) || ' Entries:'
--           || to_char(IControlTable(x).num_entries), sysdate );
--  END LOOP;

EXCEPTION
   WHEN OTHERS THEN
        raise_application_error(-20457,'Exception in Process Root Node ' ||
                                 to_char(p_tree_id) || p_access_flag, TRUE);

END   ProcessRootNode;


--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  ReturnChildrenNodes                                                --
-- PURPOSE:    retreives all cached nodes for the tree and node passed. If the    --
--             reload_flag = 'Y' then the cached is cleared and the rows          --
--             requireied and reloaded before returning to the requesting form    --
-- Prerequisites: Result table must be initialized in form before call            --
--                TreeDataTable in package spec must be initialized               --
--                                                                                --
------------------------------------------------------------------------------------
--

PROCEDURE ReturnChildrenNodes
                      (p_tree_id              IN  NUMBER
                       ,p_node_number         IN  NUMBER
                       ,p_reload_flag         IN  VARCHAR2
                       ,p_nodes_out           OUT NOCOPY NUMBER
                       ,p_Result_table        OUT NOCOPY okc_dbtree_pvt.ResultRecTableType)
IS
      x              NUMBER;
      y              NUMBER;
      z              NUMBER;
BEGIN
 --
 --  set the start/end indexes for the children of the node_number passed
 --
    x := GetNodeIndex(p_tree_id, p_node_number, 'START');
    y := GetNodeIndex(p_tree_id, p_node_number, 'END');
    p_nodes_out := GetNodeIndex(p_tree_id, p_node_number, 'ENTRY');

 --
 --  move the node entries to the result set table. S separate table is used for
 --  results as the format is different and the result is an index by table
 --  which forms PLSQL seems to like better....
 --

   z := 0;
   FOR i in x..y LOOP
      z := z + 1;
      IF tDataTable.EXISTS(i) THEN
         p_result_table(z).initial_state := 1;
         p_result_table(z).tree_depth    := tDataTable(i).tree_level_number;
         p_result_table(z).node_label    := substr(tDataTable(i).tree_label,1,255);
         p_result_table(z).node_icon     := substr(tDataTable(i).tree_icon_name,1,255);
         p_result_table(z).node_data     := substr(tDataTable(i).tree_data,1,255);
         p_result_table(z).node_children  := tDataTable(i).tree_num_children;
      END IF;

   END LOOP;

   --
   --  check that the actual number returned = number stored in control table
   --  question is what to do if they are not the same?????
   --
   IF p_nodes_out <> z THEN
      p_nodes_out := z;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
        raise_application_error(-20458,'Exception in DBTREE:ReturnChildrenNodes ' ||
                                 to_char(p_tree_id) || ':' || to_char(p_node_number), TRUE);


END   ReturnChildrenNodes;
--
--
--
-- ---------------------------------------------------------------------------------
-- PROCEDURE:  LoadNodeChildren                                                   --
-- PURPOSE:    creates the TDataTable entries for the children nodes below the    --
--             specified tree and level and node passed                           --
--                                                                                --
-- Prerequisites: Tree Node defintion must be loaded into TDefTable              --
--                TreeDataTable in package spec must be iinitialized              --
--                                                                                --
-- ---------------------------------------------------------------------------------
--
PROCEDURE LoadNodeChildren
		(p_tree_id		IN    NUMBER
                ,p_node_number          IN    NUMBER
                ,p_reload_flag          IN    VARCHAR2
                ,p_nodes_out            OUT NOCOPY   NUMBER)
IS
   CURSOR s ( p_grp_id  IN   NUMBER) IS
          select  'GRP' rec_type,
                  g.id node_id,
                  g.included_cgp_id occur_id,
                  t.name node_name,
			   b.public_yn,
                  okc_query.GetChildCount(b.id) numchildren
           from   okc_k_grpings g,
                  okc_k_groups_b b,
                  okc_k_groups_tl t
          where   g.cgp_parent_id = p_grp_id
            and   g.included_cgp_id IS NOT NULL
            and   g.included_cgp_id = b.id
            and   b.id = t.id
            and   t.language = USERENV('LANG')
--    UNION
--          select  'KHDR' rec_type,
--                  g.id node_id,
--                  g.included_chr_id occur_id,
--                  b.contract_number node_name,
--                  okc_query.GetChildCount(b.id) numchildren
--           from   okc_k_grpings g,
--                  okc_k_headers_b b,
--                  okc_k_headers_tl t
--          where   g.cgp_parent_id = p_grp_id
--            and   g.included_chr_id IS NOT NULL
--            and   g.included_chr_id = b.id
--            and   b.id = t.id
--            and   t.language = USERENV('LANG')
   order by 4;

-- The cursor has been modified by manash (added order by) to take care of sorting problem Bug#1162535
-- and the column node_name (see commented out) to display K number only Bug#1160083

   start_index         NUMBER;
   end_index           NUMBER;
   k_id                NUMBER;
   level_no            NUMBER;
   num_recs            NUMBER;
   entered_ind NUMBER := 0;

BEGIN

  --
  --   delete any previously loaded children nodes
  --
    num_recs := 0;
    num_recs := GetNodeIndex(p_tree_id, p_node_number, 'ENTRY');
--    jrt_message('DBTREE_PVT: ','Start of LoadNodeChildren', sysdate);

    IF num_recs > 0 AND p_reload_flag = 'Y' THEN
           ClearNodeCache(p_tree_id, p_node_number);
    ELSIF num_recs > 0 AND p_reload_flag = 'N' THEN
           p_nodes_out := num_recs;
           goto quit_proc;
    END IF;

  --
  --   open the cursor and read recs into table
  --
      k_id := 0;
      k_id := to_number(Get_Data_Parameter(tDataTable(p_node_number).tree_data, 'OCCUR'));
      level_no := to_number(Get_Data_Parameter(tDataTable(p_node_number).tree_data, 'LEVEL')) + 1;

  --
  --  set the table indexes in tDataTable, execute the query and load the results
  --

      start_index := tDataTable.LAST + 1;
	 end_index := start_index;
      FOR srec IN s(k_id) LOOP
		entered_ind := 1;
          tDataTAble.EXTEND;
          end_index := tdataTable.LAST;
          tDataTable(end_index).tree_num_children := srec.numchildren;
--    jrt_message('DBTREE_PVT: ','Cursor loop' || srec.node_name || srec.numchildren, sysdate);
          IF srec.numchildren > 0 THEN
               tDataTable(end_index).tree_initial_state := 1;
          ELSE
               tDataTable(end_index).tree_initial_state := 0;
          END IF;
          tDataTable(end_index).tree_depth := level_no;
/*          tDataTable(end_index).tree_label := srec.rec_type || ': ' || srec.node_name
                                      || ': ' || to_char(srec.numchildren);
							   */
-- The following line has been added by manash to diaplay K number only Bug#1160083

          tDataTable(end_index).tree_label := srec.node_name;

          tDataTable(end_index).tree_parent_node_id := p_node_number;
          tDataTable(end_index).tree_level_number := level_no;
          tDataTable(end_index).tree_node_id := end_index;

          IF srec.rec_type = 'KHDR' THEN
               tDataTable(end_index).tree_icon_name := null;
               tDataTable(end_index).tree_data := '\KHDR\' || to_char(level_no) || '\'
                                || to_char(end_index) || '\'
                                || to_char(srec.numchildren) || '\'
                                || to_char(srec.occur_id) || '\';
               tDataTable(end_index).tree_node_type := 'KHDR';
          ELSE
	        if srec.public_yn = 'Y' then
               tDataTable(end_index).tree_icon_name := 'treepubl';
	        else
               tDataTable(end_index).tree_icon_name := 'treepers';
	        end if;
               tDataTable(end_index).tree_data := '\GRP\' || to_char(level_no) || '\'
                                || to_char(end_index) || '\'
                                || to_char(srec.numchildren) || '\'
                                || to_char(srec.occur_id) || '\';
          END IF;

     END LOOP;

  --
  --   store the IcontrolTable entry for the node just loaded
  --
    if entered_ind = 0 then
	 p_nodes_out := 0;
    else
      SaveNodeIndex( p_tree_id, p_node_number, start_index, end_index);
      p_nodes_out := end_index - start_index + 1;
    end if;



<<quit_proc>>
   null;

EXCEPTION
   WHEN OTHERS THEN
      raise_application_error(-20458,'Exception in Get_node_children ', TRUE);

END  LoadNodeChildren;
--
--
--
--  PROCEDURE:  Initialize_Package
--  PURPOSE:  reinitialize all package nestedtables and variables
--
PROCEDURE Initialize_Package
IS
BEGIN
--
--   Initialize all the nested tables for this session....
--

  IControlTable := IndexControlTable ();
  tDataTable := TreeDataTableType ();

--
--   initialize the datarecs table when I remember how to that for an index by table?????
--



END   Initialize_Package;



END okc_dbtree_pvt;

/
