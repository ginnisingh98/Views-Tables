--------------------------------------------------------
--  DDL for Package Body BOM_CALC_CYNP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CALC_CYNP" AS
/* $Header: bomcynpb.pls 120.3.12000000.2 2007/04/13 12:33:57 deegupta ship $ */

-- Declare functions/procedures
FUNCTION on_primary_path(
	p_str_op_seq_id	IN	NUMBER
) RETURN BOOLEAN;

PROCEDURE collect_ops_between_rework (
          start_op_ptr         IN      NUMBER
         ,end_op_ptr           IN      NUMBER
         ,dummy_pct            IN      NUMBER
);
procedure collect_total_rework_prob(
          start_op_ptr         IN      NUMBER
         ,end_op_ptr           IN      NUMBER
         ,dummy_pct            IN      NUMBER
);
PROCEDURE calc_npp_sanity_when_rework;

PROCEDURE calc_net_planning_pct_rework (
         dummy_plan_percent IN      NUMBER
);

FUNCTION find_op (
	p_op_seq_id	IN	NUMBER
) RETURN NUMBER;

FUNCTION get_fed_rework_pct(
          to_ptr             IN      NUMBER
)RETURN BOOLEAN;

PROCEDURE calc_net_planning_pct (
	 from_ptr	IN	NUMBER,
	 to_ptr		IN	NUMBER,
	 rwk_pln_pct	IN      NUMBER
);

PROCEDURE calc_cum_yld (
         op_ptr     IN      NUMBER
);

PROCEDURE calc_rev_cum_yld (
         op_ptr     IN      NUMBER
);

FUNCTION is_dummy(
	p_index IN	NUMBER
) RETURN BOOLEAN;

FUNCTION calc_dummy_net_planning_pct (
          op_id IN      NUMBER
) RETURN NUMBER;

PROCEDURE calc_net_plan_pct(sanity_counter IN NUMBER);
PROCEDURE calc_net_plan_pct_sanity ( op_seq_id IN NUMBER);

PROCEDURE calc_primary_network (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER
);

PROCEDURE calc_feeder_network (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER,
	p_ind			IN	NUMBER
);

FUNCTION find_in_main_tbl(
	p_op_seq_id	IN	NUMBER
) RETURN NUMBER;

FUNCTION isCyclical(
	p_op_seq_id	IN	NUMBER,
	p_ind		IN	NUMBER
) RETURN BOOLEAN;

g_Debug_File      UTL_FILE.FILE_TYPE;


-- Declare variables
v_tab_size	NUMBER;
Rework_Effect_index NUMBER;

-- Declare PL/SQL records
TYPE Op_Rec_Type IS RECORD
        (  operation_seq_id     NUMBER,
           operation_seq_num    NUMBER,
	   yield 		NUMBER);

TYPE rework_effect_rec IS RECORD
        (  operation_seq_id     NUMBER,
           operation_seq_num    NUMBER
         );
TYPE Op_Detail_Rec_Type IS RECORD
        (  operation_seq_id     NUMBER,
           operation_seq_num    NUMBER,
	   net_planning_pct	NUMBER,
	   yield_nppct	        NUMBER,
	   rework_loop_flag     NUMBER,
	   rework_effect_end_flag     NUMBER,
	   cumulative_rwk_pct   NUMBER,
	   cumulative_yield	NUMBER,
	   is_dummy             NUMBER,
	   mark_for_rework_feed NUMBER,
	   rev_cumulative_yield	NUMBER );

-- Declare PL/SQL tables
TYPE numTabTyp IS TABLE OF NUMBER
	INDEX BY BINARY_INTEGER;

TYPE Op_Tbl_Type IS TABLE OF Op_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE Op_Detail_Tbl_Type IS TABLE OF Op_Detail_Rec_Type
        INDEX BY BINARY_INTEGER;

TYPE Op_Rework_Effect_Type IS TABLE OF rework_effect_rec
        INDEX BY BINARY_INTEGER;

op_tab		numTabTyp;
yld_tab		numTabTyp;
pln_tab		numTabTyp;
odf_tab 	numTabTyp;
cumyld_tab	numTabTyp;
revcumyld_tab	numTabTyp;
netpln_tab	numTabTyp;

start_tbl	Op_Tbl_Type;
temp_tbl	Op_Tbl_Type;
ntwk_op_tbl	Op_Detail_Tbl_Type;
prim_path_tbl   numTabTyp;
temp_op_detail_rec Op_Detail_Rec_Type;

main_ntwk_op_tbl Op_Detail_Tbl_Type;
main_cnt	NUMBER := 1;

rework_effect_tbl  Op_Rework_Effect_Type;
g_total_rework_prob  NUMBER := 0;
reworks_found boolean := FALSE;

temp_op_tbl numTabTyp;
temp_tbl_cnt number;

visited numTabTyp;
g_rtg_seq_id NUMBER;
g_op_type NUMBER;
-- g_cfm_flag NUMBER;  -- added for bug 2739224 to differentiate Flow and OSFM routings
rwrk_found BOOLEAN := FALSE;
token NUMBER;
--err_msg VARCHAR2(2000);

--Declare exceptions
  MULTIPLE_JUNCTION_OP EXCEPTION;
  PRAGMA exception_init(MULTIPLE_JUNCTION_OP, -20001);

  CYCLICAL_EXCEPTION EXCEPTION;
  PRAGMA exception_init(CYCLICAL_EXCEPTION, -20002);

  REWORK_FORWARD EXCEPTION;
  PRAGMA exception_init(REWORK_FORWARD, -20003);

  NO_START_OP EXCEPTION;
  PRAGMA exception_init(NO_START_OP, -20004);

  MULTIPLE_ENTRY_DUMMY EXCEPTION;
  PRAGMA exception_init(MULTIPLE_ENTRY_DUMMY, -20005);

  NO_PRIMARY_LINK EXCEPTION;
  PRAGMA exception_init(NO_PRIMARY_LINK, -20006);

  PLANNING_PCT_SUM_ERROR EXCEPTION;
  PRAGMA exception_init(PLANNING_PCT_SUM_ERROR, -20009);

  NO_NWK_DEFINED_ERROR EXCEPTION;	-- BUG 4348554
  PRAGMA exception_init(NO_NWK_DEFINED_ERROR, -20010);

PROCEDURE Open_Debug_Session
IS
     l_found NUMBER := 0;
     l_utl_file_dir    VARCHAR2(2000);
     p_output_dir      VARCHAR2(80) := '/sqlcom/log/tst115rw' ;
     p_debug_filename  VARCHAR2(30) := 'bom_cynpp.log' ;

BEGIN

     select  value
     INTO l_utl_file_dir
     FROM v$parameter
     WHERE name = 'utl_file_dir';

     l_found := INSTR(l_utl_file_dir, p_output_dir);


     IF l_found = 0
     THEN
          RETURN;
     END IF;

     g_Debug_File := utl_file.fopen(  p_output_dir
                                    , p_debug_filename
                                    , 'w');

END ;

-- Close Debug_Session
PROCEDURE Close_Debug_Session
IS
BEGIN
      utl_file.fclose(g_Debug_File);
END Close_Debug_Session;


-- Test Debug
PROCEDURE Write_Debug
(  p_debug_message      IN  VARCHAR2 )
IS
BEGIN

     utl_file.put_line(g_Debug_File, p_debug_message);

END Write_Debug;

PROCEDURE copy_ntwk_op_tbl
IS
    cnt NUMBER;
BEGIN
   FOR cnt IN 1..ntwk_op_tbl.COUNT LOOP
       main_ntwk_op_tbl(main_cnt).operation_seq_id := ntwk_op_tbl(cnt).operation_seq_id;
       main_ntwk_op_tbl(main_cnt).operation_seq_num := ntwk_op_tbl(cnt).operation_seq_num;
       main_ntwk_op_tbl(main_cnt).net_planning_pct := ntwk_op_tbl(cnt).net_planning_pct;
       main_ntwk_op_tbl(main_cnt).yield_nppct := ntwk_op_tbl(cnt).yield_nppct;
       main_ntwk_op_tbl(main_cnt).rework_loop_flag := ntwk_op_tbl(cnt).rework_loop_flag;
       main_ntwk_op_tbl(main_cnt).rework_effect_end_flag := ntwk_op_tbl(cnt).rework_effect_end_flag;
       main_ntwk_op_tbl(main_cnt).cumulative_rwk_pct := ntwk_op_tbl(cnt).cumulative_rwk_pct;
       main_ntwk_op_tbl(main_cnt).cumulative_yield := ntwk_op_tbl(cnt).cumulative_yield;
       main_ntwk_op_tbl(main_cnt).is_dummy := ntwk_op_tbl(cnt).is_dummy;
       main_ntwk_op_tbl(main_cnt).mark_for_rework_feed := ntwk_op_tbl(cnt).mark_for_rework_feed;
       main_ntwk_op_tbl(main_cnt).rev_cumulative_yield := ntwk_op_tbl(cnt).rev_cumulative_yield;

       main_cnt := main_cnt + 1;
   END LOOP;
END copy_ntwk_op_tbl;

-- Added for RBO support for NPP. This procedure is exactly similar to the calc_cynp procedure
-- These two procedures need to be always in sync and should both be tested together and always.
-- Bug 2689249
PROCEDURE calc_cynp_rbo (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER,
      	x_token_tbl		OUT NOCOPY Error_Handler.Token_Tbl_Type,
      	x_err_msg		OUT NOCOPY VARCHAR2,
      	x_return_status		OUT NOCOPY VARCHAR2
) IS
  -- Select all the operations in the routing that do NOT have a FROM
  -- operation.  These are valid starting points for multiple paths (i.e.
  -- it includes feeder lines)
/*  CURSOR start_ops_cur  IS
    SELECT DISTINCT from_op_seq_id start_op_seq_id,
			from_seq_num start_op_seq_num,
			nvl(yield, 1) start_op_yield
    FROM bom_operation_networks_v bonv,
	 bom_operation_sequences bos
    WHERE bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND   bonv.from_op_seq_id = bos.operation_sequence_id
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.to_op_seq_id = bonv.from_op_seq_id
			AND   net.transition_type <> 3)
    ORDER BY from_seq_num;*/
  -- BUG 4506235
  CURSOR start_ops_cur  IS
    SELECT DISTINCT from_op_seq_id start_op_seq_id,
			from_seq_num start_op_seq_num,
			DECODE(borv.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1)) start_op_yield
    FROM bom_operation_networks_v bonv,
	 bom_operation_sequences bos,
	 bom_operational_routings_v borv
    WHERE bonv.routing_sequence_id = borv.routing_Sequence_id
      AND   bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND   bonv.from_op_seq_id = bos.operation_sequence_id
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.to_op_seq_id = bonv.from_op_seq_id
			AND   net.transition_type <> 3)
    ORDER BY from_seq_num;

    CURSOR check_nwk_links_cur IS
      SELECT null FROM DUAL
      WHERE exists
      ( SELECT null FROM bom_operation_networks_v bonv
        WHERE bonv.routing_sequence_id = p_routing_sequence_id
        AND   bonv.operation_type = p_operation_type
	AND   bonv.transition_type <> 3 );
/****
    CURSOR set_cfm_cur IS
      SELECT cfm_routing_flag
      FROM BOM_OPERATIONAL_ROUTINGS bor
      WHERE bor.routing_sequence_id = p_routing_sequence_id;
****/

    CURSOR check_nwk_exists_cur( p_rtg_seq_id NUMBER ) IS	-- BUG 4348554
      SELECT COUNT(*) FROM bom_operation_networks
      WHERE from_op_seq_id IN
	( SELECT operation_sequence_id FROM bom_operation_sequences
	  WHERE routing_sequence_id = p_rtg_seq_id )
      OR to_op_SEQ_ID IN
	( SELECT operation_sequence_id FROM bom_operation_sequences
	  WHERE routing_sequence_id = p_rtg_seq_id );

    CURSOR get_cfm_flag_cur( p_rtg_seq_id NUMBER ) IS		-- BUG 4348554
      SELECT nvl(cfm_routing_flag, 2)
      FROM bom_operational_routings
      WHERE routing_sequence_id = p_rtg_seq_id;

  i NUMBER;
  l_yield NUMBER;
  succ_start BOOLEAN := FALSE;
--  l_token_tbl  Error_Handler.Token_Tbl_Type
  -- Primary path - traverse the network to select all the 'to' operations
  -- until the end using the primary path
  l_chk_new_exists NUMBER;
  l_cfm_flag NUMBER;

BEGIN
  --Open_Debug_Session;
  start_tbl.DELETE;
  ntwk_op_tbl.DELETE;
  main_ntwk_op_tbl.DELETE;
  prim_path_tbl.DELETE;
  rework_effect_tbl.DELETE;
  main_cnt := 1;
/****
  FOR set_cfm_rec IN set_cfm_cur LOOP  -- Added for bug 2739224
	g_cfm_flag := nvl(set_cfm_rec.cfm_routing_flag, 2);
  END LOOP;
****/

  OPEN get_cfm_flag_cur( p_routing_sequence_id );		-- BUG 4348554
  FETCH get_cfm_flag_cur INTO l_cfm_flag;
  CLOSE get_cfm_flag_cur;
  IF l_cfm_flag = 3 THEN
	OPEN check_nwk_exists_cur( p_routing_sequence_id );
	FETCH check_nwk_exists_cur INTO l_chk_new_exists;
	CLOSE check_nwk_exists_cur;
	IF l_chk_new_exists = 0 THEN
		RAISE NO_NWK_DEFINED_ERROR;
	END IF;
  /*
  ELSIF l_cfm_flag = 1 THEN
	OPEN check_nwk_exists_cur( p_routing_sequence_id );
	FETCH check_nwk_exists_cur INTO l_chk_new_exists;
	CLOSE check_nwk_exists_cur;
	IF l_chk_new_exists = 0 THEN
		RAISE NO_NWK_DEFINED_ERROR;
	END IF;
  */
  END IF;

  Rework_Effect_index := 0;--resetting the global index for rework collections
  -- Fetch all the starting opns, save the min op seq num as the
  -- starting point for the main line
  i := 1;
  FOR start_ops_rec IN start_ops_cur LOOP
	start_tbl(i).operation_seq_id := start_ops_rec.start_op_seq_id;
	start_tbl(i).operation_seq_num := start_ops_rec.start_op_seq_num;
	start_tbl(i).yield := start_ops_rec.start_op_yield;
	i := i + 1;
  END LOOP;

  IF start_tbl.COUNT = 0 THEN
     FOR C1 IN check_nwk_links_cur LOOP
         raise NO_START_OP;
     END LOOP;
     RETURN;
  END IF;
  succ_start := TRUE;
  calc_primary_network(p_routing_sequence_id,p_operation_type,p_update_events);
  copy_ntwk_op_tbl();
  FOR i in 2..start_tbl.count
  LOOP
    ntwk_op_tbl.DELETE;
    prim_path_tbl.DELETE;
    rework_effect_tbl.DELETE;
    Rework_Effect_index := 0;
    reworks_found := false;
    calc_feeder_network(p_routing_sequence_id,p_operation_type,p_update_events, i);
    copy_ntwk_op_tbl();
  END LOOP;

  -- might need to truncate tables for re-use
  start_tbl.DELETE;
  ntwk_op_tbl.DELETE;
  main_ntwk_op_tbl.DELETE;
  prim_path_tbl.DELETE;
  rework_effect_tbl.DELETE;

--Close_Debug_session;
EXCEPTION
	WHEN MULTIPLE_JUNCTION_OP THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
		x_err_msg := 'BOM_MULT_JUNC_OP';
		x_return_status := 'E';
	WHEN CYCLICAL_EXCEPTION THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
		x_err_msg := 'BOM_LOOP_FOUND';
		x_return_status := 'E';
	WHEN REWORK_FORWARD THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
		x_err_msg := 'BOM_RWRK_LOOP_FOUND';
		x_return_status := 'E';
	WHEN NO_START_OP THEN
		x_err_msg := 'BOM_NO_START_OP';
		x_return_status := 'E';
	WHEN MULTIPLE_ENTRY_DUMMY THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
		x_err_msg := 'BOM_MULT_ENTRY_DUMMY';
		x_return_status := 'E';
	WHEN NO_PRIMARY_LINK THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
		x_err_msg := 'BOM_NO_PRIMARY_LINK';
		x_return_status := 'E';
	WHEN PLANNING_PCT_SUM_ERROR THEN
		x_token_tbl(1).token_name := 'SEQ_NUM';
		x_token_tbl(1).token_value := token;
                x_err_msg := 'BOM_PLANNING_PCT_SUM_ERROR';
                x_return_status := 'E';
	WHEN NO_NWK_DEFINED_ERROR THEN		-- BUG 4348554
		x_err_msg := 'BOM_NO_RTG_NWK_DEF_ERROR';
		x_return_status := 'E';
	WHEN OTHERS THEN
		IF succ_start THEN
                   x_err_msg := 'BOM_UNKNOWN_ERROR';
                   x_return_status := 'E';
		ELSE
		   x_token_tbl(1).token_name := 'SEQ_NUM';
		   x_token_tbl(1).token_value := start_tbl(start_tbl.COUNT).operation_seq_num;
		   x_err_msg := 'BOM_LOOP_FOUND';
		   x_return_status := 'E';
		END IF;

END calc_cynp_rbo;

PROCEDURE calc_cynp (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER
) IS
  -- Select all the operations in the routing that do NOT have a FROM
  -- operation.  These are valid starting points for multiple paths (i.e.
  -- it includes feeder lines)
/*  CURSOR start_ops_cur  IS
    SELECT DISTINCT from_op_seq_id start_op_seq_id,
			from_seq_num start_op_seq_num,
			nvl(yield, 1) start_op_yield
    FROM bom_operation_networks_v bonv,
	 bom_operation_sequences bos
    WHERE bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND   bonv.from_op_seq_id = bos.operation_sequence_id
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.to_op_seq_id = bonv.from_op_seq_id
			AND   net.transition_type <> 3)
    ORDER BY from_seq_num;*/
  -- BUG 4506235
  CURSOR start_ops_cur  IS
    SELECT DISTINCT from_op_seq_id start_op_seq_id,
			from_seq_num start_op_seq_num,
			DECODE(borv.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1)) start_op_yield
    FROM bom_operation_networks_v bonv,
	 bom_operation_sequences bos,
	 bom_operational_routings_v borv
    WHERE bonv.routing_sequence_id = borv.routing_Sequence_id
      AND   bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND   bonv.from_op_seq_id = bos.operation_sequence_id
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.to_op_seq_id = bonv.from_op_seq_id
			AND   net.transition_type <> 3)
    ORDER BY from_seq_num;

    CURSOR check_nwk_links_cur IS
      SELECT null FROM DUAL
      WHERE exists
      ( SELECT null FROM bom_operation_networks_v bonv
        WHERE bonv.routing_sequence_id = p_routing_sequence_id
        AND   bonv.operation_type = p_operation_type
	AND   bonv.transition_type <> 3 );

    CURSOR check_nwk_exists_cur( p_rtg_seq_id NUMBER ) IS	-- BUG 4348554
      SELECT COUNT(*) FROM bom_operation_networks
      WHERE from_op_seq_id IN
	( SELECT operation_sequence_id FROM bom_operation_sequences
	  WHERE routing_sequence_id = p_rtg_seq_id )
      OR to_op_SEQ_ID IN
	( SELECT operation_sequence_id FROM bom_operation_sequences
	  WHERE routing_sequence_id = p_rtg_seq_id );

    CURSOR get_cfm_flag_cur( p_rtg_seq_id NUMBER ) IS		-- BUG 4348554
      SELECT nvl(cfm_routing_flag, 2)
      FROM bom_operational_routings
      WHERE routing_sequence_id = p_rtg_seq_id;


/****
    CURSOR set_cfm_cur IS
      SELECT cfm_routing_flag
      FROM BOM_OPERATIONAL_ROUTINGS bor
      WHERE bor.routing_sequence_id = p_routing_sequence_id;
****/
  i NUMBER;
  l_yield NUMBER;
  succ_start BOOLEAN := FALSE;
  -- Primary path - traverse the network to select all the 'to' operations
  -- until the end using the primary path
  l_chk_new_exists NUMBER;
  l_cfm_flag NUMBER;

BEGIN
  --Open_Debug_Session;
  start_tbl.DELETE;
  ntwk_op_tbl.DELETE;
  main_ntwk_op_tbl.DELETE;
  prim_path_tbl.DELETE;
  rework_effect_tbl.DELETE;
  main_cnt := 1;

/***
	To determine whether a routing is flow or OSFM can be decided using the operation_type
	Operation type is 2 for process ops and 3 for line ops in flow routings
	Operation type is 1 in OSFM routings
***
  FOR set_cfm_rec IN set_cfm_cur LOOP  -- Added for bug 2739224
	g_cfm_flag := nvl(set_cfm_rec.cfm_routing_flag, 2);
  END LOOP;
***/

  OPEN get_cfm_flag_cur( p_routing_sequence_id );		-- BUG 4348554
  FETCH get_cfm_flag_cur INTO l_cfm_flag;
  CLOSE get_cfm_flag_cur;
  IF l_cfm_flag = 3 THEN
	OPEN check_nwk_exists_cur( p_routing_sequence_id );
	FETCH check_nwk_exists_cur INTO l_chk_new_exists;
	CLOSE check_nwk_exists_cur;
	IF l_chk_new_exists = 0 THEN
		RAISE NO_NWK_DEFINED_ERROR;
	END IF;
  /*
  ELSIF l_cfm_flag = 1 THEN
	OPEN check_nwk_exists_cur( p_routing_sequence_id );
	FETCH check_nwk_exists_cur INTO l_chk_new_exists;
	CLOSE check_nwk_exists_cur;
	IF l_chk_new_exists = 0 THEN
		RAISE NO_NWK_DEFINED_ERROR;
	END IF;*/
  END IF;

  Rework_Effect_index := 0;--resetting the global index for rework collections
  -- Fetch all the starting opns, save the min op seq num as the
  -- starting point for the main line
  i := 1;
  FOR start_ops_rec IN start_ops_cur LOOP
	start_tbl(i).operation_seq_id := start_ops_rec.start_op_seq_id;
	start_tbl(i).operation_seq_num := start_ops_rec.start_op_seq_num;
	start_tbl(i).yield := start_ops_rec.start_op_yield;
	i := i + 1;
  END LOOP;

  IF start_tbl.COUNT = 0 THEN
     FOR C1 IN check_nwk_links_cur LOOP
         raise NO_START_OP;
     END LOOP;
     RETURN;
  END IF;
  succ_start := TRUE;

  calc_primary_network(p_routing_sequence_id,p_operation_type,p_update_events);
  copy_ntwk_op_tbl();
  FOR i in 2..start_tbl.count
  LOOP
    ntwk_op_tbl.DELETE;
    prim_path_tbl.DELETE;
    rework_effect_tbl.DELETE;
    Rework_Effect_index := 0;
    reworks_found := false;
    calc_feeder_network(p_routing_sequence_id,p_operation_type,p_update_events, i);
    copy_ntwk_op_tbl();
  END LOOP;

  -- might need to truncate tables for re-use
  start_tbl.DELETE;
  ntwk_op_tbl.DELETE;
  main_ntwk_op_tbl.DELETE;
  prim_path_tbl.DELETE;
  rework_effect_tbl.DELETE;

--Close_Debug_session;
EXCEPTION
	WHEN MULTIPLE_JUNCTION_OP THEN
		fnd_message.set_name('BOM','BOM_MULT_JUNC_OP');
		fnd_message.set_token('SEQ_NUM',to_char(token));
		fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		err_msg := 'Feeder subnetwork starting with operation sequence number '||to_char(token)||' joins another sub-network in more than one place. Please correct this and try again.';
--		raise_application_error(-20001,err_msg,FALSE);
--		dbms_output.put_line('Feeder subnetwork starting with operation sequence number '||to_char(token)||' joins another sub-network in more than one place. Please correct this and try again.');
--		null;
	WHEN CYCLICAL_EXCEPTION THEN
		fnd_message.set_name('BOM','BOM_LOOP_FOUND');
		fnd_message.set_token('SEQ_NUM',to_char(token));
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20002,err_msg,FALSE);
--		dbms_output.put_line('All primary and alternate paths should go forward. Path terminating in operation with operation sequence number '||to_char(token)||' traverses backward. Please correct this and try again.');
--		null;
	WHEN REWORK_FORWARD THEN
		fnd_message.set_name('BOM','BOM_RWRK_LOOP_FOUND');
		fnd_message.set_token('SEQ_NUM',to_char(token));
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20003,err_msg,FALSE);
--		dbms_output.put_line('Some reworks are going forward in sub-network starting with operation sequence number '||to_char(token)||'. Please correct this and try again.');
--		null;
	WHEN NO_START_OP THEN
		fnd_message.set_name('BOM','BOM_NO_START_OP');
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20004,err_msg,FALSE);
--		dbms_output.put_line('There is no start operation defined in the network');
--		null;
	WHEN MULTIPLE_ENTRY_DUMMY THEN
		fnd_message.set_name('BOM','BOM_MULT_ENTRY_DUMMY');
		fnd_message.set_token('SEQ_NUM',to_char(token));
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20005,err_msg,FALSE);
--		dbms_output.put_line('Two or more rework links are coming into the dummy operation with operation sequence number '||to_char(token)||'. Please correct this and try again.');
--		null;
	WHEN NO_PRIMARY_LINK THEN
		fnd_message.set_name('BOM','BOM_NO_PRIMARY_LINK');
		fnd_message.set_token('SEQ_NUM',to_char(token));
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20006,err_msg,FALSE);
--		dbms_output.put_line('The Operation '||to_char(token)||' must have a primary link going out of it, if it has alternate link going out of it. Please correct this and try again.');
--		null;
	WHEN PLANNING_PCT_SUM_ERROR THEN
		fnd_message.set_name('BOM','BOM_PLANNING_PCT_SUM_ERROR');
		fnd_message.set_token('SEQ_NUM',to_char(token));
                fnd_message.raise_error;
--		err_msg := fnd_message.get;
--		raise_application_error(-20009,err_msg,FALSE);
--		dbms_output.put_line('Sum of percentages of all out going primary and alternate links for operation '||to_char(token)||' must be 100. Please correct this and try again.');
--		null;
--	WHEN NO_DATA_FOUND THEN
--		raise_application_error(-06512,'No data found error');
--		dbms_output.put_line('----main no data found----');
--		NULL;
	WHEN NO_NWK_DEFINED_ERROR THEN		-- BUG 4348554
		fnd_message.set_name('BOM','BOM_NO_RTG_NWK_DEF_ERROR');
                fnd_message.raise_error;
	WHEN OTHERS THEN
		IF succ_start THEN
		   fnd_message.set_name('BOM','BOM_UNKNOWN_ERROR');
                   fnd_message.raise_error;
		ELSE
		   fnd_message.set_name('BOM','BOM_LOOP_FOUND');
		   fnd_message.set_token('SEQ_NUM',to_char(start_tbl(start_tbl.COUNT).operation_seq_num));
                   fnd_message.raise_error;
		END IF;
--		err_msg := fnd_message.get;
--		raise_application_error(-20020,err_msg,FALSE);
--		dbms_output.put_line('An unidentified error has occurred in the planning percent calculations. Please contact Oracle Support.');
END calc_cynp;

PROCEDURE updt_db(
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	NUMBER,
	p_update_events		IN	NUMBER
)
IS
i	NUMBER;
BEGIN
  for i in 1..ntwk_op_tbl.COUNT loop
    update bom_operation_sequences
    set cumulative_yield = ntwk_op_tbl(i).cumulative_yield,
        reverse_cumulative_yield = ntwk_op_tbl(i).rev_cumulative_yield,
        net_planning_percent = ntwk_op_tbl(i).net_planning_pct
    where operation_sequence_id = ntwk_op_tbl(i).operation_seq_id;

    -- Update child events based on the parameter
    if p_update_events = 1 then
      if p_operation_type = 2 then
        update bom_operation_sequences
        set cumulative_yield = ntwk_op_tbl(i).cumulative_yield,
            reverse_cumulative_yield = ntwk_op_tbl(i).rev_cumulative_yield,
            net_planning_percent = ntwk_op_tbl(i).net_planning_pct
        where routing_sequence_id = p_routing_sequence_id
        and  process_op_seq_id = ntwk_op_tbl(i).operation_seq_id;
      elsif p_operation_type = 3 then
        update bom_operation_sequences
        set cumulative_yield = ntwk_op_tbl(i).cumulative_yield,
            reverse_cumulative_yield = ntwk_op_tbl(i).rev_cumulative_yield,
            net_planning_percent = ntwk_op_tbl(i).net_planning_pct
        where routing_sequence_id = p_routing_sequence_id
        and  line_op_seq_id = ntwk_op_tbl(i).operation_seq_id;
      end if;
    end if;
  end loop;
END updt_db;

PROCEDURE swap_ops(i NUMBER) IS
l_count NUMBER;
BEGIN
       temp_op_detail_rec.operation_seq_id := ntwk_op_tbl(i).operation_seq_id;
       temp_op_detail_rec.operation_seq_num := ntwk_op_tbl(i).operation_seq_num;
       temp_op_detail_rec.net_planning_pct := ntwk_op_tbl(i).net_planning_pct;
       temp_op_detail_rec.yield_nppct := ntwk_op_tbl(i).yield_nppct;
       temp_op_detail_rec.rework_loop_flag := ntwk_op_tbl(i).rework_loop_flag;
       temp_op_detail_rec.rework_effect_end_flag := ntwk_op_tbl(i).rework_effect_end_flag;
       temp_op_detail_rec.cumulative_rwk_pct := ntwk_op_tbl(i).cumulative_rwk_pct;
       temp_op_detail_rec.cumulative_yield := ntwk_op_tbl(i).cumulative_yield;
       temp_op_detail_rec.is_dummy := ntwk_op_tbl(i).is_dummy;
       temp_op_detail_rec.mark_for_rework_feed := ntwk_op_tbl(i).mark_for_rework_feed;
       temp_op_detail_rec.rev_cumulative_yield := ntwk_op_tbl(i).rev_cumulative_yield;

       l_count := ntwk_op_tbl.COUNT;

       ntwk_op_tbl(i).operation_seq_id := ntwk_op_tbl(l_count).operation_seq_id;
       ntwk_op_tbl(i).operation_seq_num := ntwk_op_tbl(l_count).operation_seq_num;
       ntwk_op_tbl(i).net_planning_pct := ntwk_op_tbl(l_count).net_planning_pct;
       ntwk_op_tbl(i).yield_nppct := ntwk_op_tbl(l_count).yield_nppct;
       ntwk_op_tbl(i).rework_loop_flag := ntwk_op_tbl(l_count).rework_loop_flag;
       ntwk_op_tbl(i).rework_effect_end_flag := ntwk_op_tbl(l_count).rework_effect_end_flag;
       ntwk_op_tbl(i).cumulative_rwk_pct := ntwk_op_tbl(l_count).cumulative_rwk_pct;
       ntwk_op_tbl(i).cumulative_yield := ntwk_op_tbl(l_count).cumulative_yield;
       ntwk_op_tbl(i).is_dummy := ntwk_op_tbl(l_count).is_dummy;
       ntwk_op_tbl(i).mark_for_rework_feed := ntwk_op_tbl(l_count).mark_for_rework_feed;
       ntwk_op_tbl(i).rev_cumulative_yield := ntwk_op_tbl(l_count).rev_cumulative_yield;

       ntwk_op_tbl(l_count).operation_seq_id := temp_op_detail_rec.operation_seq_id;
       ntwk_op_tbl(l_count).operation_seq_num := temp_op_detail_rec.operation_seq_num;
       ntwk_op_tbl(l_count).net_planning_pct := temp_op_detail_rec.net_planning_pct;
       ntwk_op_tbl(l_count).yield_nppct := temp_op_detail_rec.yield_nppct;
       ntwk_op_tbl(l_count).rework_loop_flag := temp_op_detail_rec.rework_loop_flag;
       ntwk_op_tbl(l_count).rework_effect_end_flag := temp_op_detail_rec.rework_effect_end_flag;
       ntwk_op_tbl(l_count).cumulative_rwk_pct := temp_op_detail_rec.cumulative_rwk_pct;
       ntwk_op_tbl(l_count).cumulative_yield := temp_op_detail_rec.cumulative_yield;
       ntwk_op_tbl(l_count).is_dummy := temp_op_detail_rec.is_dummy;
       ntwk_op_tbl(l_count).mark_for_rework_feed := temp_op_detail_rec.mark_for_rework_feed;
       ntwk_op_tbl(l_count).rev_cumulative_yield := temp_op_detail_rec.rev_cumulative_yield;
END swap_ops;

PROCEDURE check_loops IS
i number;
BEGIN
	---   To find if rework loops are going forward...
	rwrk_found := FALSE;
	FOR i IN 1..ntwk_op_tbl.COUNT LOOP
	    visited(i) := 0;
	END LOOP;
	FOR i IN 1..ntwk_op_tbl.COUNT LOOP
	    IF visited(i) = 0 THEN
	       IF isCyclical(ntwk_op_tbl(i).operation_seq_id, i) THEN
		  IF rwrk_found THEN
		     token := ntwk_op_tbl(1).operation_seq_num;
		     raise REWORK_FORWARD;
		  ELSE
		     raise CYCLICAL_EXCEPTION;
		  END IF;
	       END IF;
	    END IF;
	END LOOP;
END;

FUNCTION isCyclical(p_op_seq_id NUMBER, p_ind NUMBER)
RETURN BOOLEAN IS
  CURSOR next_ops_cur (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
	   to_seq_num next_op_seq_num,
	   transition_type
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = g_rtg_seq_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = g_op_type
--	AND transition_type <> 3
    ORDER BY transition_type  -- the order is important - primary, alternate and then rework loop shud be considered
    , next_op_seq_num;
  j NUMBER;
  l_flag BOOLEAN := FALSE;
BEGIN
	visited(p_ind) := 1;
	FOR C1 in next_ops_cur(p_op_seq_id) LOOP
	    j := find_op(C1.next_op_seq_id);
	    IF C1.transition_type = 3 THEN
	       rwrk_found := TRUE;  --- set the rework flag indicating that a rework loop is being checked for its end
	    END IF;
	    IF j <> -1 AND NOT l_flag THEN   --- If not junction operation and no cycle is found till now
	       IF visited(j) = 1 THEN  --- This operation has already been 'visited' in this traversal
		  IF NOT is_dummy(j) AND rwrk_found AND NOT l_flag THEN
		     rwrk_found := false;  --- unset the flag indicating that the rework loop ends in a correct preceding operation
		  ELSE
		     token := ntwk_op_tbl(j).operation_seq_num;
		     return TRUE;
		  END IF;
	       ELSIF visited(j) = 0 THEN   ---- Not necessary to check for visited(j) = 2 because that has already been 'expanded' completely
	          l_flag := isCyclical(C1.next_op_seq_id, j);
	       END IF;
	    END IF;
	END LOOP;
	IF NOT l_flag THEN  --- Say explored only when NOT returning from a rework loop
	   visited(p_ind) := 2;      --- Completely explored
	END IF;
	IF l_flag OR rwrk_found THEN   ---- If there is an unended rework loop or if the rework goes to a subsequent operation
	   RETURN TRUE;
	ELSE
	   RETURN FALSE;
	END IF;
END isCyclical;

PROCEDURE calc_dummy_rev_cum_yld (
         op_ptr     IN      NUMBER
) IS

  CURSOR prev_opns_cur (cv_to_seq_id number) IS
        SELECT from_op_seq_id prev_op, planning_pct
        FROM bom_operation_networks
        WHERE to_op_seq_id = cv_to_seq_id
                AND transition_type = 3;
  j NUMBER := 0;
BEGIN

    FOR prev_opns_rec IN prev_opns_cur(ntwk_op_tbl(op_ptr).operation_seq_id) LOOP
       IF j <> 0 THEN
          token := ntwk_op_tbl(j).operation_seq_num;
	  raise MULTIPLE_ENTRY_DUMMY;
       END IF;
       j := find_op(prev_opns_rec.prev_op);
--       IF j <> -1 AND ntwk_op_tbl(j).rev_cumulative_yield is NULL THEN  --- no need to check j <> -1 as any previous operation cannot be a junction operation
       IF ntwk_op_tbl(j).rev_cumulative_yield is NULL THEN
          IF NOT(nvl(ntwk_op_tbl(j).is_dummy,0) <> 1) THEN
	     calc_dummy_rev_cum_yld(j);
	  END IF;
       END IF;
    END LOOP;
       ntwk_op_tbl(op_ptr).rev_cumulative_yield := ntwk_op_tbl(j).rev_cumulative_yield;
END calc_dummy_rev_cum_yld;

PROCEDURE validate_operation(i NUMBER) is
   CURSOR next_op_cur(cv_start_op_seq_id NUMBER) is
     SELECT bonv.transition_type, bonv.planning_pct
     FROM bom_operation_networks_v bonv
     WHERE routing_sequence_id = g_rtg_seq_id
	AND bonv.from_op_seq_id = cv_start_op_seq_id
	AND bonv.operation_type = g_op_type
	AND bonv.transition_type <> 3;

   prim_found BOOLEAN := FALSE;
   next_op_found BOOLEAN := FALSE;
   tot_pct NUMBER := 0;
BEGIN
   FOR next_op_rec IN next_op_cur(ntwk_op_tbl(i).operation_seq_id) LOOP
      next_op_found := TRUE;
      IF next_op_rec.transition_type = 1 THEN
         prim_found := TRUE;
      END IF;
      tot_pct := tot_pct + nvl(next_op_rec.planning_pct, 0);
   END LOOP;
   IF next_op_found THEN
--      IF NOT prim_found AND g_cfm_flag = 1 THEN -- added cfm flag check for bug 2739224
      IF NOT prim_found AND g_op_type in (2,3) THEN -- This check is only for flow routings - for bug 2739224
         token := ntwk_op_tbl(i).operation_seq_num;
         raise NO_PRIMARY_LINK;
      END IF;
      IF tot_pct <> 100 THEN
         token := ntwk_op_tbl(i).operation_seq_num;
         raise PLANNING_PCT_SUM_ERROR;
      END IF;
   END IF;
END validate_operation;

PROCEDURE calc_primary_network (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER
) IS

   CURSOR end_op_cur  IS
    SELECT max(to_op_seq_id) end_op_seq_id
    FROM bom_operation_networks_v bonv
    WHERE bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.from_op_seq_id = bonv.to_op_seq_id
			AND   net.transition_type <> 3);

  -- For cv_start_op_seq_id, traverse the network to select all the
  -- adjacent 'to' operations (first the primary and then alternates
  -- except rework)
  CURSOR next_ops_cur (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
	   to_seq_num next_op_seq_num,
	   transition_type
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type <> 3
    ORDER BY transition_type desc, next_op_seq_num;

  CURSOR next_alt_ops_cur (cv_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
	   to_seq_num next_op_seq_num,
	   transition_type
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 2
    ORDER BY transition_type desc, next_op_seq_num;

  -- For cv_start_op_seq_id, traverse the network to select all the
  -- adjacent REWORK 'to' operations
  CURSOR rework_ops_cur (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id, to_seq_num,
	   transition_type, nvl(planning_pct, 0) planning_pct,
           from_op_seq_id, from_seq_num
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 3
    ORDER BY to_seq_num;

  CURSOR rework_ops_cur1 (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id, to_seq_num,
	   transition_type, nvl(planning_pct, 0) planning_pct,
           from_op_seq_id, from_seq_num
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 3
    ORDER BY to_seq_num;

  cursor prim_path_cur (cv_start_op_seq_id number) is
  select bon.to_op_seq_id prim_op_seq_id
  from bom_operation_networks bon
  connect by prior to_op_seq_id = from_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3)
  start with from_op_seq_id = cv_start_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3);
  i					number;
  k					number;
  ii					number;
  j					number;
  v_ptr					number;
  v_local_ptr			        number;--used for temp loop and always
  -- takse its value from v_ptr at the start of the loop
  v_alt_ptr				number;
  v_to_op_seq_id			number;
  v_to_seq_num				number;
  v_planning_pct			number;
  v_cnt					number;
  v_yield				number;
  v_cumyld				number;
  v_on_alternate			boolean;

  v_start_op_seq_id			number;
  v_start_operation_seq_num		number;
  v_netpln				number;
  v_odf					number;  -- Option dependent flag
  v_rework				boolean := false;
  l_yield				number := 0;
  dummy_plan_pct                       number;
  next_op_pln_pct                      number;
  next_op_ptr                              number;
  low_ptr                              number;
  high_ptr                             number;
  dummy_loop                           boolean;
  v_temp                               number;

BEGIN
  -- Create the primary path table
  k := 1;
  FOR prim_path_rec IN prim_path_cur(start_tbl(1).operation_seq_id) LOOP
	prim_path_tbl(k):= prim_path_rec.prim_op_seq_id;
	k := k + 1;
  END LOOP;
--print_primary;
  -- Save the STARTing op in the Ntwk_Op table
  -- Default np% to 100 since the starting op cannot have a % assigned
  -- cum_yld of the start opn is equal to its yield
  ntwk_op_tbl(1).operation_seq_id := start_tbl(1).operation_seq_id;
  ntwk_op_tbl(1).operation_seq_num := start_tbl(1).operation_seq_num;
  ntwk_op_tbl(1).net_planning_pct := 100;
  ntwk_op_tbl(1).yield_nppct      := 100;
  ntwk_op_tbl(1).rework_loop_flag := 0;
  ntwk_op_tbl(1).cumulative_rwk_pct := 0;
  ntwk_op_tbl(1).cumulative_yield := start_tbl(1).yield;
  ntwk_op_tbl(1).is_dummy := 0;

  v_ptr := 1;
  v_local_ptr := 1;
  -- Fetch all the next TO operations from the starting operation
  i := 1;
  WHILE (v_ptr <= i) LOOP
    v_local_ptr := v_ptr;
    IF nvl(ntwk_op_tbl(v_ptr).is_dummy,0) <> 1 THEN -- if not dummy
    FOR rework_ops_rec IN rework_ops_cur(ntwk_op_tbl(v_local_ptr).operation_seq_id) LOOP
      reworks_found := TRUE;
      ntwk_op_tbl(v_local_ptr).rework_loop_flag := 1;
      IF ( find_op(rework_ops_rec.to_op_seq_id) = -1 ) THEN   /**** Add the operation to the table ****/
        i := i + 1;
        v_ptr := v_ptr + 1;
        ntwk_op_tbl(i).operation_seq_id := rework_ops_rec.to_op_seq_id;
        ntwk_op_tbl(i).operation_seq_num := rework_ops_rec.to_seq_num;
        ntwk_op_tbl(i).rework_loop_flag := 1;
      END IF;

      IF( is_dummy(find_op(ntwk_op_tbl(i).operation_seq_id))) THEN
        ntwk_op_tbl(v_local_ptr).mark_for_rework_feed := 1;
	ntwk_op_tbl(i).is_dummy := 1;
        dummy_plan_pct := calc_dummy_net_planning_pct(ntwk_op_tbl(i).operation_seq_id);
        -- Now, try and find where this rework meets the original path
        dummy_loop := TRUE;
        WHILE dummy_loop LOOP
          FOR rework_ops_rec1 IN rework_ops_cur1(ntwk_op_tbl(i).operation_seq_id)
          LOOP
            reworks_found := TRUE;

            next_op_pln_pct := rework_ops_rec1.planning_pct;
            next_op_ptr := find_op(rework_ops_rec1.to_op_seq_id);
--            IF find_op(rework_ops_rec1.to_op_seq_id ) = -1 THEN
            IF next_op_ptr = -1 THEN
              i := i + 1;
              v_ptr := v_ptr + 1;
              ntwk_op_tbl(i).operation_seq_id := rework_ops_rec1.to_op_seq_id;
              ntwk_op_tbl(i).operation_seq_num:= rework_ops_rec1.to_seq_num;
              ntwk_op_tbl(i).rework_loop_flag := 1;
            ELSE
--              ntwk_op_tbl(find_op(rework_ops_rec1.to_op_seq_id)).rework_loop_flag := 1;
              ntwk_op_tbl(next_op_ptr).rework_loop_flag := 1;
            END IF;
            IF is_dummy(find_op(rework_ops_rec1.to_op_seq_id)) THEN
              ntwk_op_tbl(i).is_dummy := 1;
              dummy_plan_pct := calc_dummy_net_planning_pct(ntwk_op_tbl(i).operation_seq_id);
            ELSE
              dummy_loop := FALSE;
            END IF;
          END LOOP;
        END LOOP; -- END OF dummy_loop
      END IF;
    END LOOP; -- end of REWORK LOOP
    FOR next_ops_rec IN next_ops_cur (ntwk_op_tbl(v_local_ptr).operation_seq_id) LOOP
	-- if not already in table
	--bug 1030309
	--and if on the alternate path, should not be on the primary also
	IF find_op(next_ops_rec.next_op_seq_id) = -1 AND
		(next_ops_rec.transition_type = 1 or
		 (next_ops_rec.transition_type = 2
			and NOT on_primary_path(next_ops_rec.next_op_seq_id))) THEN
	 -- add node into the ntwk_op_tbl and calc np%
	  i := i + 1;
          ntwk_op_tbl(i).operation_seq_id := next_ops_rec.next_op_seq_id;
          ntwk_op_tbl(i).operation_seq_num := next_ops_rec.next_op_seq_num;
--          calc_net_planning_pct(find_op(ntwk_op_tbl(i).operation_seq_id),
--                                find_op(ntwk_op_tbl(i).operation_seq_id), -1);
          calc_net_planning_pct(i,i, -1);
--          calc_cum_yld(find_op(ntwk_op_tbl(i).operation_seq_id));
          calc_cum_yld(i);
	END IF;
      END LOOP;  -- End loop for next_ops_cur
  -- move pointer to the next row in table
    END IF;--only execute if not dummy
  v_ptr := v_ptr + 1;
  END LOOP; -- while loop

--print_op();
  FOR ii in 1..ntwk_op_tbl.COUNT LOOP
    FOR end_op_rec in end_op_cur LOOP
      IF end_op_rec.end_op_seq_id = ntwk_op_tbl(ii).operation_seq_id THEN
         swap_ops(ii);
      END IF; -- If they match
    END LOOP;
  END LOOP;

  visited.DELETE;
  g_rtg_seq_id := p_routing_sequence_id;
  g_op_type := p_operation_type;
  FOR ii in 1..ntwk_op_tbl.COUNT LOOP
      IF NOT is_dummy(ii) THEN
         validate_operation(ii);
      END IF;
  END LOOP;
  check_loops();

  temp_op_tbl.DELETE;
  temp_tbl_cnt := 1;

  IF NOT reworks_found THEN
    calc_net_plan_pct_sanity(ntwk_op_tbl(ntwk_op_tbl.COUNT).operation_seq_id);
  ELSE
    calc_net_plan_pct_sanity(ntwk_op_tbl(ntwk_op_tbl.COUNT).operation_seq_id);
    calc_npp_sanity_when_rework();
  END IF;

  -- Calculate the REV CUM YIELD for all the operations
  FOR i in REVERSE 1..ntwk_op_tbl.COUNT LOOP
    if i = ntwk_op_tbl.COUNT then/*
      select nvl(yield, 1)
        into l_yield
        from bom_operation_sequences
        where operation_sequence_id = ntwk_op_tbl(i).operation_seq_id;*/
      -- BUG 4506235
      select DECODE(bor.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1))
	into l_yield
	from bom_operational_routings bor, bom_operation_sequences bos
	where bor.routing_sequence_id = bos.routing_sequence_id
	and bos.operation_sequence_id = ntwk_op_tbl(i).operation_seq_id;
       ntwk_op_tbl(i).rev_cumulative_yield := l_yield;
    else
      temp_op_tbl.DELETE;
      temp_tbl_cnt := 1;

--      IF NOT is_dummy(find_op(ntwk_op_tbl(i).operation_seq_id)) THEN
      IF NOT is_dummy(i) THEN
--	 calc_rev_cum_yld(find_op(ntwk_op_tbl(i).operation_seq_id));
	 calc_rev_cum_yld(i);
      END IF;
    end if;
  END LOOP;

  FOR i in REVERSE 1..ntwk_op_tbl.COUNT LOOP
--      IF is_dummy(find_op(ntwk_op_tbl(i).operation_seq_id)) THEN
      IF is_dummy(i) THEN
        IF ntwk_op_tbl(i).rev_cumulative_yield is NULL THEN
--	   calc_dummy_rev_cum_yld(find_op(ntwk_op_tbl(i).operation_seq_id));
	   calc_dummy_rev_cum_yld(i);
	END IF;
      END IF;
  END LOOP;
/*
  FOR i IN 1..ntwk_op_tbl.COUNT LOOP
	dbms_output.put_line('row: '||to_char(i)||
		' op: '||to_char(ntwk_op_tbl(i).operation_seq_num)||
		' ID: '||to_char(ntwk_op_tbl(i).operation_seq_id)||
		' cyld '||to_char(ntwk_op_tbl(i).cumulative_yield)||
		' rcyld '||to_char(ntwk_op_tbl(i).rev_cumulative_yield)||
		' np% '||to_char(ntwk_op_tbl(i).net_planning_pct));
  END LOOP;
*/
  -- Update the database fields for cum yield/rev cum yield/net planning
  updt_db(p_routing_sequence_id, p_operation_type, p_update_events);
END calc_primary_network;

FUNCTION bld_ntwk_op_tbl(
	p_op_seq_id		IN	NUMBER,
	p_routing_sequence_id   IN	NUMBER,
	p_operation_type	IN	NUMBER
) RETURN NUMBER IS

  CURSOR end_op_cur  IS
    SELECT max(to_op_seq_id) end_op_seq_id
    FROM bom_operation_networks_v bonv
    WHERE bonv.routing_sequence_id = p_routing_sequence_id
      AND   bonv.operation_type = p_operation_type
      AND   bonv.transition_type <> 3
      AND NOT EXISTS (SELECT NULL
                        FROM  bom_operation_networks net
                        WHERE net.from_op_seq_id = bonv.to_op_seq_id
			AND   net.transition_type <> 3);

  -- For cv_start_op_seq_id, traverse the network to select all the
  -- adjacent 'to' operations (first the primary and then alternates
  -- except rework)
  CURSOR next_ops_cur (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
	   to_seq_num next_op_seq_num,
	   transition_type
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type <> 3
    ORDER BY transition_type desc, next_op_seq_num;

  CURSOR next_alt_ops_cur (cv_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
	   to_seq_num next_op_seq_num,
	   transition_type
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 2
    ORDER BY transition_type desc, next_op_seq_num;

  -- For cv_start_op_seq_id, traverse the network to select all the
  -- adjacent REWORK 'to' operations
  CURSOR rework_ops_cur (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id, to_seq_num,
	   transition_type, nvl(planning_pct, 0) planning_pct,
           from_op_seq_id, from_seq_num
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 3
    ORDER BY to_seq_num;
  CURSOR rework_ops_cur1 (cv_start_op_seq_id number) IS
    SELECT to_op_seq_id, to_seq_num,
	   transition_type, nvl(planning_pct, 0) planning_pct,
           from_op_seq_id, from_seq_num
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_routing_sequence_id
	AND from_op_seq_id = cv_start_op_seq_id
	AND operation_type = p_operation_type
	AND transition_type = 3
    ORDER BY to_seq_num;

  i					number;
  k					number;
  ii					number;
  j					number;
  v_ptr					number;
  v_local_ptr			        number;--used for temp loop and always
  -- takse its value from v_ptr at the start of the loop
  v_alt_ptr				number;
  v_to_op_seq_id			number;
  v_to_seq_num				number;
  v_planning_pct			number;
  v_cnt					number;
  v_yield				number;
  v_cumyld				number;
  v_on_alternate			boolean;

  v_start_op_seq_id			number;
  v_start_operation_seq_num		number;
  v_netpln				number;
  v_odf					number;  -- Option dependent flag
  v_rework				boolean := false;
  next_op_pln_pct                      number;
  next_op_ptr                          number;
  low_ptr                              number;
  high_ptr                             number;
  dummy_loop                           boolean;
  v_temp                               number;
  l_jop				       number;
  jop					number;
  jop_found				boolean;

BEGIN
  v_ptr := 1;
  v_local_ptr := 1;
  -- Fetch all the next TO operations from the starting operation
  j := 1;
  jop_found := FALSE;
  WHILE (v_ptr <= j) LOOP
    v_local_ptr := v_ptr;
    IF nvl(ntwk_op_tbl(v_ptr).is_dummy,0) <> 1 THEN
    FOR rework_ops_rec IN rework_ops_cur(ntwk_op_tbl(v_local_ptr).operation_seq_id) LOOP
      reworks_found := TRUE;
      ntwk_op_tbl(v_local_ptr).rework_loop_flag := 1;
      IF find_op(rework_ops_rec.to_op_seq_id) = -1 AND find_in_main_tbl(rework_ops_rec.to_op_seq_id) = -1 THEN
----- Added another check so that wrong operations are not added to ntwk_op_tbl when the network is wrongly created.
	j := j + 1;
--        v_ptr := v_ptr + 1;   --- commented so that no operation is missed, the operation going into the last operation, if having a rework, will fail if this increment happens
	ntwk_op_tbl(j).operation_seq_id := rework_ops_rec.to_op_seq_id;
        ntwk_op_tbl(j).operation_seq_num := rework_ops_rec.to_seq_num;
        ntwk_op_tbl(j).rework_loop_flag := 1;
      END IF;

--      IF( is_dummy(find_op(ntwk_op_tbl(j).operation_seq_id))) THEN
      IF( is_dummy(j)) THEN
        ntwk_op_tbl(v_local_ptr).mark_for_rework_feed := 1;
        ntwk_op_tbl(j).is_dummy := 1;
        -- Now, try and find where this rework meets the original path
        dummy_loop := TRUE;
        WHILE dummy_loop LOOP
          FOR rework_ops_rec1 IN rework_ops_cur1(ntwk_op_tbl(j).operation_seq_id)
          LOOP
            reworks_found := TRUE;

            next_op_pln_pct := rework_ops_rec1.planning_pct;
            next_op_ptr := find_op(rework_ops_rec1.to_op_seq_id);
--            IF find_op(rework_ops_rec1.to_op_seq_id ) = -1 THEN
            IF next_op_ptr = -1 THEN
              j := j + 1;
--              v_ptr := v_ptr + 1;   --- may be valid here, need to investigate further, commented for the time being
              ntwk_op_tbl(j).operation_seq_id := rework_ops_rec1.to_op_seq_id;
              ntwk_op_tbl(j).operation_seq_num:= rework_ops_rec1.to_seq_num;
              ntwk_op_tbl(j).rework_loop_flag := 1;
            ELSE
--              ntwk_op_tbl(find_op(rework_ops_rec1.to_op_seq_id)).rework_loop_flag := 1;
              ntwk_op_tbl(next_op_ptr).rework_loop_flag := 1;
            END IF;
--            IF is_dummy(find_op(rework_ops_rec1.to_op_seq_id)) THEN
            IF is_dummy(next_op_ptr) THEN
              ntwk_op_tbl(j).is_dummy := 1;
            ELSE
              dummy_loop := FALSE;
            END IF;
          END LOOP;
        END LOOP; -- END OF dummy_loop
      END IF;  -- end of IF dummy
    END LOOP;-- end of REWORK LOOP
      FOR next_ops_rec IN next_ops_cur (ntwk_op_tbl(v_local_ptr).operation_seq_id) LOOP
/*********** if the operation found is on the parent network, exit (junction is found)  ***********/
        l_jop := find_in_main_tbl(next_ops_rec.next_op_seq_id);
       if l_jop <> -1 THEN

	  if jop_found THEN
	     token := ntwk_op_tbl(1).operation_seq_num;
	     raise MULTIPLE_JUNCTION_OP;
	  end if;

	  jop := l_jop;
	  jop_found := TRUE;
	  v_temp := v_local_ptr;
       END IF;

	-- if not already in table
	--bug 1030309
	--and if on the alternate path, should not be on the primary also
	IF (find_op(next_ops_rec.next_op_seq_id) = -1) AND
		(next_ops_rec.transition_type = 1 or
		 (next_ops_rec.transition_type = 2
			and (NOT on_primary_path(next_ops_rec.next_op_seq_id))))
		 AND (NOT jop_found OR l_jop = -1) THEN
	 -- add node into the ntwk_op_tbl and calc np%
	  j := j + 1;
          ntwk_op_tbl(j).operation_seq_id := next_ops_rec.next_op_seq_id;
          ntwk_op_tbl(j).operation_seq_num := next_ops_rec.next_op_seq_num;
	 END IF;
      END LOOP;  -- End loop for next_ops_cur
  -- move pointer to the next row in table
    END IF;--only execute if not dummy
  v_ptr := v_ptr + 1;
  END LOOP; -- while loop
	i := v_temp;
  IF v_temp <> ntwk_op_tbl.COUNT AND v_temp <> 1 THEN
	swap_ops(i);
  END IF; -- If they match
  return jop;
END bld_ntwk_op_tbl;


PROCEDURE calc_feeder_network (
	p_routing_sequence_id	IN	NUMBER,
	p_operation_type	IN	VARCHAR2,
      	p_update_events		IN	NUMBER,
	p_ind			IN	NUMBER
)
IS
  cursor prim_path_fdr_cur (cv_start_op_seq_id number) is
  select bon.to_op_seq_id prim_op_seq_id
  from bom_operation_networks bon
  connect by prior to_op_seq_id = from_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3)
  start with from_op_seq_id = cv_start_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3);

  i					number;
  k					number;
  l_jop					number;
  dummy_plan_pct			number;
  l_yield				number := 0;

BEGIN
  -- Create the primary path table for the feeder
  k := 1;
  FOR prim_path_fdr_rec IN prim_path_fdr_cur(start_tbl(p_ind).operation_seq_id) LOOP
	prim_path_tbl(k):= prim_path_fdr_rec.prim_op_seq_id;
	k := k + 1;
  END LOOP;
  -- Save the STARTing op in the Ntwk_Op table
  -- Default np% to 100 since the starting op cannot have a % assigned
  -- cum_yld of the start opn is equal to its yield

  ntwk_op_tbl(1).operation_seq_id := start_tbl(p_ind).operation_seq_id;
  ntwk_op_tbl(1).operation_seq_num := start_tbl(p_ind).operation_seq_num;
  ntwk_op_tbl(1).net_planning_pct := 100;
  ntwk_op_tbl(1).yield_nppct      := 100;
  ntwk_op_tbl(1).rework_loop_flag := 0;
  ntwk_op_tbl(1).cumulative_rwk_pct := 0;
  ntwk_op_tbl(1).cumulative_yield := start_tbl(p_ind).yield;
  ntwk_op_tbl(1).is_dummy := 0;  -- starting operation cannot be dummy

  l_jop := bld_ntwk_op_tbl(start_tbl(p_ind).operation_seq_id, p_routing_sequence_id, p_operation_type);

  visited.DELETE;
  g_rtg_seq_id := p_routing_sequence_id;
  g_op_type := p_operation_type;
  FOR i in 1..ntwk_op_tbl.COUNT LOOP
      IF NOT is_dummy(i) THEN
         validate_operation(i);
      END IF;
  END LOOP;
  check_loops();

  FOR i IN 2..ntwk_op_tbl.COUNT LOOP
    calc_net_planning_pct(i, i, -1);
  END LOOP;

  FOR i IN 2..ntwk_op_tbl.COUNT LOOP
    IF nvl(ntwk_op_tbl(i).is_dummy,0) = 1 THEN
       dummy_plan_pct := calc_dummy_net_planning_pct(ntwk_op_tbl(i).operation_seq_id);
    END IF;
  END LOOP;



/********* Check for operations that are alternate and not on primary path??  *************/

  temp_op_tbl.DELETE;
  temp_tbl_cnt := 1;

  IF NOT reworks_found THEN
    calc_net_plan_pct_sanity(main_ntwk_op_tbl(l_jop).operation_seq_id);
  ELSE
    calc_net_plan_pct_sanity(main_ntwk_op_tbl(l_jop).operation_seq_id);
    calc_npp_sanity_when_rework();
  END IF;


/************* Multiply the NPP of the junction operation as the factor to NPP of all operations  ********/
  FOR i IN 1..ntwk_op_tbl.COUNT LOOP
    ntwk_op_tbl(i).net_planning_pct := ntwk_op_tbl(i).net_planning_pct * nvl(main_ntwk_op_tbl(l_jop).net_planning_pct,100)/100;
  END LOOP;

  -- Calculate the REV CUM YIELD for all the operations
  FOR i in REVERSE 1..ntwk_op_tbl.COUNT LOOP
    if i = ntwk_op_tbl.COUNT then/*
      select nvl(yield, 1)
        into l_yield
        from bom_operation_sequences
        where operation_sequence_id = ntwk_op_tbl(i).operation_seq_id;*/
      -- BUG 4506235
      select DECODE(bor.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1))
	into l_yield
	from bom_operational_routings bor, bom_operation_sequences bos
	where bor.routing_sequence_id = bos.routing_sequence_id
	and bos.operation_sequence_id = ntwk_op_tbl(i).operation_seq_id;
       ntwk_op_tbl(i).rev_cumulative_yield := l_yield;
    else
      temp_op_tbl.DELETE;
      temp_tbl_cnt := 1;
--      IF NOT is_dummy(find_op(ntwk_op_tbl(i).operation_seq_id)) THEN
      IF NOT is_dummy(i) THEN
--        calc_rev_cum_yld(find_op(ntwk_op_tbl(i).operation_seq_id));
        calc_rev_cum_yld(i);
      END IF;
    end if;
  END LOOP;

  FOR i in REVERSE 1..ntwk_op_tbl.COUNT LOOP
--      IF is_dummy(find_op(ntwk_op_tbl(i).operation_seq_id)) THEN
      IF is_dummy(i) THEN
        IF ntwk_op_tbl(i).rev_cumulative_yield is NULL THEN
--	   calc_dummy_rev_cum_yld(find_op(ntwk_op_tbl(i).operation_seq_id));
	   calc_dummy_rev_cum_yld(i);
	END IF;
      END IF;
  END LOOP;
/*
   dbms_output.put_line('*********feeder************');
   FOR i IN 1..ntwk_op_tbl.COUNT LOOP
	dbms_output.put_line('row: '||to_char(i)||
		' op: '||to_char(ntwk_op_tbl(i).operation_seq_num)||
		' ID: '||to_char(ntwk_op_tbl(i).operation_seq_id)||
		' cyld '||to_char(ntwk_op_tbl(i).cumulative_yield)||
		' rcyld '||to_char(ntwk_op_tbl(i).rev_cumulative_yield)||
		' np% '||to_char(ntwk_op_tbl(i).net_planning_pct));
  END LOOP;
*/
  -- Update the database fields for cum yield/rev cum yield/net planning  --- changes may be required
   updt_db(p_routing_sequence_id, p_operation_type, p_update_events);
END calc_feeder_network;

FUNCTION find_op (
	p_op_seq_id	IN	NUMBER
) RETURN NUMBER IS
BEGIN
  FOR i IN 1..ntwk_op_tbl.COUNT LOOP
    IF (ntwk_op_tbl(i).operation_seq_id = p_op_seq_id) THEN
      RETURN (i);
    END IF;
  END LOOP;
  RETURN (-1);
END find_op;

FUNCTION find_temp_op (
	p_op_seq_id	IN	NUMBER
) RETURN NUMBER IS
BEGIN
  FOR i IN 1..temp_op_tbl.COUNT LOOP
    IF (temp_op_tbl(i) = p_op_seq_id) THEN
      RETURN (i);
    END IF;
  END LOOP;
  RETURN (-1);
END find_temp_op;

FUNCTION find_in_main_tbl(
	p_op_seq_id	IN	NUMBER
) RETURN NUMBER IS
BEGIN
    FOR i IN 1..main_ntwk_op_tbl.COUNT LOOP
    IF (main_ntwk_op_tbl(i).operation_seq_id = p_op_seq_id) THEN
      RETURN (i);
    END IF;
  END LOOP;
  RETURN (-1);
END find_in_main_tbl;

PROCEDURE calc_net_planning_pct (
         from_ptr     IN      NUMBER,
         to_ptr       IN      NUMBER,
	 rwk_pln_pct  IN      NUMBER
) IS

  CURSOR prev_links_cur (cv_to_seq_id number) IS
	SELECT from_op_seq_id prev_op, planning_pct
	--FROM bom_operation_networks_v
	FROM bom_operation_networks
	WHERE to_op_seq_id = cv_to_seq_id
		AND transition_type <> 3;

  j NUMBER;
  k NUMBER := 0;
  l_net_planning_pct NUMBER := 0;
  l_yield_nppct      NUMBER := 0;

BEGIN
	-- if REWORK Calc
	IF (rwk_pln_pct <> -1) THEN
	  k := 1;
	ELSE k := 0;
	END IF;
	FOR ii IN from_ptr+k..to_ptr LOOP
          IF NOT ( nvl(ntwk_op_tbl(ii).is_dummy,0) = 1) THEN
	    l_yield_nppct      := 0;
	    FOR prev_links_rec IN prev_links_cur(ntwk_op_tbl(ii).operation_seq_id) LOOP
	      j := find_op(prev_links_rec.prev_op);
	      IF (j <> -1) THEN
	        l_yield_nppct := nvl(l_yield_nppct, 0)
                 + (ntwk_op_tbl(j).yield_nppct
                    * prev_links_rec.planning_pct)/100;
	      END IF;
	    END LOOP;
	    ntwk_op_tbl(ii).yield_nppct := l_yield_nppct;
	  END IF;
	END LOOP;

	FOR ii IN from_ptr..to_ptr LOOP
          IF NOT ( nvl(ntwk_op_tbl(ii).is_dummy,0)=1) THEN
            IF (ii = 1) THEN
	      l_net_planning_pct := 100;
	    ELSE
	      l_net_planning_pct := 0;
	    END IF;
	    FOR prev_links_rec IN prev_links_cur(ntwk_op_tbl(ii).operation_seq_id) LOOP
	      j := find_op(prev_links_rec.prev_op);
	      IF (j <> -1) THEN
	        l_net_planning_pct := nvl(l_net_planning_pct, 0)
	        +(ntwk_op_tbl(j).yield_nppct * prev_links_rec.planning_pct)/100;
	      END IF;
	    END LOOP;
	    IF (ntwk_op_tbl(ii).rework_loop_flag = 1) THEN
	      l_net_planning_pct :=
              l_net_planning_pct + nvl(ntwk_op_tbl(ii).cumulative_rwk_pct,0);
	    END IF;
	    ntwk_op_tbl(ii).net_planning_pct := l_net_planning_pct;
	  END IF;
	END LOOP;
END calc_net_planning_pct;

PROCEDURE calc_cum_yld (
         op_ptr     IN      NUMBER
) IS

  CURSOR prev_opns_cur (cv_to_seq_id number) IS
        SELECT from_op_seq_id prev_op, planning_pct
        FROM bom_operation_networks
        WHERE to_op_seq_id = cv_to_seq_id
                AND transition_type <> 3;

  j NUMBER;
  l_yield NUMBER := 0;
  l_cum_yld NUMBER := 0;

BEGIN
/*
    select nvl(yield, 1)
    into l_yield
    from bom_operation_sequences
    where operation_sequence_id = ntwk_op_tbl(op_ptr).operation_seq_id;*/
    -- BUG 4506235
    select DECODE(bor.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1))
    into l_yield
    from bom_operational_routings bor, bom_operation_sequences bos
    where bor.routing_sequence_id = bos.routing_sequence_id
    and bos.operation_sequence_id = ntwk_op_tbl(op_ptr).operation_seq_id;

    FOR prev_opns_rec IN prev_opns_cur(ntwk_op_tbl(op_ptr).operation_seq_id) LOOP
	j := find_op(prev_opns_rec.prev_op);
	IF (j <> -1) THEN
          IF(ntwk_op_tbl(op_ptr).yield_nppct = 0) THEN
	    l_cum_yld := nvl(l_cum_yld, 0)
			+ (ntwk_op_tbl(j).cumulative_yield
			   * (prev_opns_rec.planning_pct * ntwk_op_tbl(j).yield_nppct
			      /(100*100)));
	  ELSE
	    l_cum_yld := nvl(l_cum_yld, 0)
			+ (ntwk_op_tbl(j).cumulative_yield
			   * (prev_opns_rec.planning_pct * ntwk_op_tbl(j).yield_nppct
			      /(nvl(ntwk_op_tbl(op_ptr).yield_nppct,100)*100)));
	  END IF;
	END IF;
    END LOOP;
    ntwk_op_tbl(op_ptr).cumulative_yield := l_cum_yld * l_yield;
END calc_cum_yld;

PROCEDURE calc_rev_cum_yld (
         op_ptr     IN      NUMBER
) IS

  CURSOR next_opns_cur (cv_to_seq_id number) IS
        SELECT to_op_seq_id next_op, planning_pct
        FROM bom_operation_networks
        WHERE from_op_seq_id = cv_to_seq_id
                AND transition_type <> 3;

  j NUMBER;
  l_yield NUMBER := 0;
  l_rev_cum_yld NUMBER := 0;

BEGIN/*
    select nvl(yield, 1)
    into l_yield
    from bom_operation_sequences
    where operation_sequence_id = ntwk_op_tbl(op_ptr).operation_seq_id;*/
    -- BUG 4506235
      select DECODE(bor.cfm_routing_flag, 3, (DECODE(bos.operation_yield_enabled, 1, NVL(bos.yield, 1), 1)), NVL(bos.yield, 1))
	into l_yield
	from bom_operational_routings bor, bom_operation_sequences bos
	where bor.routing_sequence_id = bos.routing_sequence_id
	and bos.operation_sequence_id = ntwk_op_tbl(op_ptr).operation_seq_id;

    FOR next_opns_rec IN next_opns_cur(ntwk_op_tbl(op_ptr).operation_seq_id) LOOP
	j := find_op(next_opns_rec.next_op);
	IF (j <> -1) THEN
          IF (ntwk_op_tbl(j).rev_cumulative_yield IS NULL) AND find_temp_op(next_opns_rec.next_op) = -1 THEN
            temp_op_tbl(temp_tbl_cnt) := next_opns_rec.next_op;
	    temp_tbl_cnt := temp_tbl_cnt + 1;
            calc_rev_cum_yld(j);
	  END IF;
        ELSE
          RETURN;
	END IF;
	l_rev_cum_yld := nvl(l_rev_cum_yld, 0)
			+ (nvl(ntwk_op_tbl(j).rev_cumulative_yield,1) * next_opns_rec.planning_pct/100);
    END LOOP;
    ntwk_op_tbl(op_ptr).rev_cumulative_yield := l_rev_cum_yld * l_yield;
END calc_rev_cum_yld;

FUNCTION is_dummy( p_index NUMBER )
  RETURN BOOLEAN IS
  CURSOR prev_ops_cur (cv_op_seq_id number) IS
    SELECT from_op_seq_id prev_op_seq_id,
           transition_type
    FROM bom_operation_networks bonv
    --WHERE routing_sequence_id = p_routing_sequence_id
    WHERE to_op_seq_id = cv_op_seq_id;
    --AND operation_type = p_operation_type;

  CURSOR next_ops_cur (cv_op_seq_id number) IS
    SELECT to_op_seq_id next_op_seq_id,
           transition_type
    FROM bom_operation_networks bonv
    --WHERE routing_sequence_id = p_routing_sequence_id
    WHERE from_op_seq_id = cv_op_seq_id;
    --AND operation_type = p_operation_type;
  rework_in_found BOOLEAN := FALSE;
  rework_out_found BOOLEAN := FALSE;
  is_dummy BOOLEAN := TRUE;
BEGIN
  FOR prev_ops_rec IN prev_ops_cur(ntwk_op_tbl(p_index).operation_seq_id) LOOP
    IF prev_ops_rec.transition_type = 3 THEN
      rework_in_found := TRUE;
    END IF;
    IF prev_ops_rec.transition_type <> 3 THEN
      is_dummy := FALSE;
    END IF;
  END LOOP;
  IF is_dummy = FALSE THEN
    return is_dummy;
  END IF;
  FOR next_ops_rec IN next_ops_cur(ntwk_op_tbl(p_index).operation_seq_id) LOOP
    IF next_ops_rec.transition_type = 3 THEN
      rework_out_found := TRUE;
    END IF;
    IF next_ops_rec.transition_type <> 3 THEN
      is_dummy := FALSE;
    END IF;
  END LOOP;
  IF is_dummy AND rework_in_found AND rework_out_found THEN
    return TRUE;
  ELSE
    return FALSE;
  END IF;
END;

FUNCTION calc_dummy_net_planning_pct (
          op_id IN      NUMBER
) RETURN NUMBER IS

  CURSOR prev_links_cur (cv_to_seq_id number) IS
        SELECT from_op_seq_id prev_op, planning_pct
        FROM bom_operation_networks
        WHERE to_op_seq_id = cv_to_seq_id
        AND transition_type = 3;

  j NUMBER;
  l_yield_nppct NUMBER;
  l_nppct NUMBER;
BEGIN
  FOR prev_ops_rec IN prev_links_cur(op_id) LOOP
    l_yield_nppct := nvl(l_yield_nppct,0) +
    ntwk_op_tbl(find_op(prev_ops_rec.prev_op)).yield_nppct *
    prev_ops_rec.planning_pct / 100;
    l_nppct := nvl(l_nppct,0) +
    ntwk_op_tbl(find_op(prev_ops_rec.prev_op)).net_planning_pct *
    prev_ops_rec.planning_pct / 100;
  END LOOP;
  ntwk_op_tbl(find_op(op_id)).yield_nppct := l_yield_nppct;
  ntwk_op_tbl(find_op(op_id)).net_planning_pct := l_nppct;
  return l_nppct;
END calc_dummy_net_planning_pct;

FUNCTION get_fed_rework_pct(
          to_ptr             IN      NUMBER
) RETURN BOOLEAN IS
  CURSOR feeding_links_cur (cv_to_seq_id number) IS
        SELECT from_op_seq_id prev_op, planning_pct
        FROM bom_operation_networks
        WHERE to_op_seq_id = cv_to_seq_id
        AND transition_type <> 3;
  CURSOR fed_sum (cv_from_seq_id number) IS
        SELECT SUM(planning_pct) pct_sum
        FROM bom_operation_networks
        WHERE from_op_seq_id = cv_from_seq_id
        AND transition_type <> 3;
  rework_accum NUMBER := 0;
  grab_rework BOOLEAN := FALSE;
  prev_op NUMBER;
  rework_sum_out NUMBER;
BEGIN
  FOR feed_rec IN feeding_links_cur(ntwk_op_tbl(to_ptr).operation_seq_id) LOOP
    prev_op := find_op(feed_rec.prev_op);
    IF prev_op <> -1 THEN
      FOR fed_sum_cur in fed_sum(ntwk_op_tbl(prev_op).operation_seq_id) LOOP
        rework_sum_out := fed_sum_cur.pct_sum;
      END LOOP;
      rework_accum := rework_accum +ntwk_op_tbl(prev_op).cumulative_rwk_pct *
      feed_rec.planning_pct / rework_sum_out;
      IF ntwk_op_tbl(prev_op).mark_for_rework_feed = 1 THEN
        grab_rework := TRUE;
      END IF;
    END IF;
  END LOOP;
  if grab_rework THEN
    ntwk_op_tbl(to_ptr).cumulative_rwk_pct := rework_accum;
    return grab_rework;
  else
    return false;
  end if;
END get_fed_rework_pct;

procedure collect_total_rework_prob(
          start_op_ptr         IN      NUMBER
         ,end_op_ptr           IN      NUMBER
         ,dummy_pct            IN      NUMBER
)  IS
  CURSOR forward_links_cur (cv_from_seq_id number) IS
        SELECT to_op_seq_id next_op
        FROM bom_operation_networks
        WHERE from_op_seq_id = cv_from_seq_id
                AND transition_type <> 3;
  CURSOR link_percent_cur (cv_from_seq_id number,cv_to_seq_id number) IS
        SELECT  PLANNING_PCT npp
        FROM bom_operation_networks
        WHERE from_op_seq_id = cv_from_seq_id
        AND to_op_seq_id = cv_to_seq_id
                AND transition_type <> 3;

  l_branch_rework_percent_dstr number:=1;
  rows_exist number:=0;
  j NUMBER;
BEGIN
  IF start_op_ptr = end_op_ptr THEN -- When the rework starts and ends in the same operation
     g_total_rework_prob := 1;
  ELSE
  FOR forward_link in forward_links_cur(ntwk_op_tbl(start_op_ptr).operation_seq_id ) LOOP
    Rework_Effect_index := Rework_Effect_index + 1;
    rework_effect_tbl(Rework_Effect_index).operation_seq_id := forward_link.next_op;
    IF (forward_link.next_op = ntwk_op_tbl(end_op_ptr).operation_seq_id ) THEN
        FOR ii IN 1..(Rework_Effect_index-1) LOOP
          FOR link_percent_rec IN
                 link_percent_cur(rework_effect_tbl(ii).operation_seq_id,
                         rework_effect_tbl(ii+1).operation_seq_id) LOOP
            l_branch_rework_percent_dstr :=
            (l_branch_rework_percent_dstr * nvl(link_percent_rec.npp,100))/100;
          END LOOP;
        END LOOP;
      g_total_rework_prob := g_total_rework_prob + l_branch_rework_percent_dstr;
      Rework_Effect_index := Rework_Effect_index - 1;
    ELSE
      j := find_op(forward_link.next_op);
      IF j <> -1 THEN
         collect_total_rework_prob(j , end_op_ptr, dummy_pct);
         Rework_Effect_index := Rework_Effect_index - 1;
      END IF;
    END IF;
  END LOOP;
  END IF;
END collect_total_rework_prob;

procedure collect_ops_between_rework (
          start_op_ptr         IN      NUMBER
         ,end_op_ptr           IN      NUMBER
         ,dummy_pct            IN      NUMBER
)  IS
  CURSOR forward_links_cur (cv_from_seq_id number) IS
        SELECT to_op_seq_id next_op
        FROM bom_operation_networks
        WHERE from_op_seq_id = cv_from_seq_id
                AND transition_type <> 3;
  rows_exist number:=0;
  j NUMBER;
BEGIN
  IF start_op_ptr = end_op_ptr THEN -- When the rework starts and ends in the same operation
     calc_net_planning_pct_rework(dummy_pct);
  ELSE
  FOR forward_link in forward_links_cur(ntwk_op_tbl(start_op_ptr).operation_seq_id ) LOOP
    Rework_Effect_index := Rework_Effect_index + 1;
    rework_effect_tbl(Rework_Effect_index).operation_seq_id := forward_link.next_op;

    IF (forward_link.next_op = ntwk_op_tbl(end_op_ptr).operation_seq_id ) THEN
      calc_net_planning_pct_rework(dummy_pct);
      Rework_Effect_index := Rework_Effect_index - 1;
    ELSE
      j := find_op(forward_link.next_op);
      IF j <> -1 THEN
         collect_ops_between_rework(j , end_op_ptr, dummy_pct);
         Rework_Effect_index := Rework_Effect_index - 1;
      END IF;
    END IF;
  END LOOP;
  END IF;
END collect_ops_between_rework;

PROCEDURE calc_net_planning_pct_rework (
          --from_ptr           IN      NUMBER
         --,to_ptr             IN      NUMBER,
         dummy_plan_percent    IN      NUMBER
) IS
  CURSOR prev_links_cur (cv_to_seq_id number) IS
        SELECT from_op_seq_id prev_op, planning_pct
        FROM bom_operation_networks
        WHERE to_op_seq_id = cv_to_seq_id
                AND transition_type <> 3;

  CURSOR forward_links_cur (cv_from_seq_id number,cv_to_seq_id number) IS
        SELECT  PLANNING_PCT npp
        FROM bom_operation_networks
	        WHERE from_op_seq_id = cv_from_seq_id
        AND to_op_seq_id = cv_to_seq_id
                AND transition_type <> 3;

l_yield_nppct         NUMBER;
l_net_planning_pct    NUMBER;
j                     NUMBER;
temp                  NUMBER;
l_dummy_percent_dstr  NUMBER := 1;
BEGIN
--print_op();
        FOR ii IN 1..(Rework_Effect_index-1) LOOP
          FOR forward_link_rec IN
              forward_links_cur(rework_effect_tbl(ii).operation_seq_id,
                         rework_effect_tbl(ii+1).operation_seq_id) LOOP
            l_dummy_percent_dstr := (l_dummy_percent_dstr * nvl(forward_link_rec.npp,100))/100;
          END LOOP;
        END LOOP;
        l_dummy_percent_dstr := (dummy_plan_percent * nvl(l_dummy_percent_dstr,1))/nvl(g_total_rework_prob,1);
        FOR ii IN 1..Rework_Effect_index LOOP
          temp := find_op(rework_effect_tbl(ii).operation_seq_id);
          ntwk_op_tbl(temp).rework_loop_flag := 1;
          IF (nvl(ntwk_op_tbl(temp).is_dummy,0) <> 1) THEN
            ntwk_op_tbl(temp).cumulative_rwk_pct :=
            nvl(ntwk_op_tbl(temp).cumulative_rwk_pct,0) +
            l_dummy_percent_dstr; -- * ntwk_op_tbl(temp).yield_nppct/100;
          END IF;
        END LOOP;
        FOR ii IN 1..Rework_Effect_index LOOP
          temp := find_op(rework_effect_tbl(ii).operation_seq_id);
          IF (nvl(ntwk_op_tbl(temp).is_dummy,0) <> 1) THEN
            IF (temp = 1) THEN
              l_net_planning_pct := 100;
            ELSE
              l_net_planning_pct := 0;
            END IF;
            FOR prev_links_rec IN prev_links_cur(ntwk_op_tbl(temp).operation_seq_id) LOOP
              j := find_op(prev_links_rec.prev_op);
              IF (j <> -1) THEN
                l_net_planning_pct := nvl(l_net_planning_pct, 0)
                +(ntwk_op_tbl(j).yield_nppct * prev_links_rec.planning_pct)/100;
              END IF;
            END LOOP;
            IF (ntwk_op_tbl(temp).rework_loop_flag = 1) THEN
              l_net_planning_pct :=
              l_net_planning_pct + ntwk_op_tbl(temp).cumulative_rwk_pct;
            END IF;
            ntwk_op_tbl(temp).net_planning_pct := l_net_planning_pct;
          END IF;
        END LOOP;
END calc_net_planning_pct_rework;

FUNCTION on_primary_path (
	p_str_op_seq_id	IN	NUMBER
) RETURN BOOLEAN IS

BEGIN
   FOR j IN 1..prim_path_tbl.COUNT LOOP
      if prim_path_tbl(j) = p_str_op_seq_id then
	return(TRUE);
      end if;
   END LOOP;
   return(FALSE);

END on_primary_path;

PROCEDURE calc_net_plan_pct(
        sanity_counter IN NUMBER
) IS
  l_npp               number;
  j                   number;
  l_yield_nppct       number;
  CURSOR prev_links_cur (cv_to_seq_id number) IS
  SELECT from_op_seq_id prev_op, planning_pct
  FROM bom_operation_networks
  WHERE to_op_seq_id = cv_to_seq_id
  AND transition_type <> 3;

BEGIN
      IF NOT ( nvl(ntwk_op_tbl(sanity_counter).is_dummy,0) = 1) THEN
        l_yield_nppct      := 0;
        FOR prev_links_rec IN
        prev_links_cur(ntwk_op_tbl(sanity_counter).operation_seq_id) LOOP
          j := find_op(prev_links_rec.prev_op);
          IF (j <> -1) THEN
            l_yield_nppct := nvl(l_yield_nppct, 0)
            + (ntwk_op_tbl(j).yield_nppct *
            prev_links_rec.planning_pct)/100;
          END IF;
        END LOOP;
        ntwk_op_tbl(sanity_counter).yield_nppct := l_yield_nppct;
      END IF;

   l_npp      := 0;
   j          := 0;
   FOR prev_links_rec IN
     prev_links_cur(ntwk_op_tbl(sanity_counter).operation_seq_id) LOOP
     j := find_op(prev_links_rec.prev_op);
     IF (j <> -1) THEN
       l_npp := nvl(l_npp, 0)
       + (ntwk_op_tbl(j).net_planning_pct * prev_links_rec.planning_pct)/100;
     END IF;
    END LOOP;
    ntwk_op_tbl(sanity_counter).net_planning_pct := l_npp;
END;

PROCEDURE calc_net_plan_pct_sanity (
	op_seq_id IN NUMBER
) IS
  sanity_counter      number;
  j                   number;
  l_count NUMBER := 0;

  CURSOR prev_links_count_cur (cv_to_seq_id number) IS
  SELECT count(*) count
  FROM bom_operation_networks
  WHERE to_op_seq_id = cv_to_seq_id
  AND transition_type <> 3;

  CURSOR prev_links_cur (cv_to_seq_id number) IS
  SELECT from_op_seq_id prev_op, planning_pct
  FROM bom_operation_networks
  WHERE to_op_seq_id = cv_to_seq_id
  AND transition_type <> 3;
BEGIN
  FOR count_rec in prev_links_count_cur(op_seq_id) LOOP
    l_count := count_rec.count;
  END LOOP;
  IF l_count <> 0 THEN
    FOR prev_op_rec IN prev_links_cur(op_seq_id) LOOP
      IF find_temp_op(prev_op_rec.prev_op) = -1 THEN
         temp_op_tbl(temp_tbl_cnt) := prev_op_rec.prev_op;
	 temp_tbl_cnt := temp_tbl_cnt + 1;
         calc_net_plan_pct_sanity(prev_op_rec.prev_op);
      END IF;
/*
      IF find_op(op_seq_id) <> -1 THEN
        calc_net_plan_pct(find_op(op_seq_id));
	calc_cum_yld(find_op(op_seq_id));
      END IF;
*/
      j := find_op(op_seq_id);
      IF j <> -1 THEN
        calc_net_plan_pct(j);
	calc_cum_yld(j);
      END IF;
    END LOOP;
  END IF;
END calc_net_plan_pct_sanity;

PROCEDURE calc_npp_sanity_when_rework IS
  sanity_counter      number;
  l_npp               number;
  j                   number;
  CURSOR rework_out_cur (cv_from_seq_id number) IS
  SELECT to_op_seq_id next_op, planning_pct
  FROM bom_operation_networks
  WHERE from_op_seq_id = cv_from_seq_id
  AND transition_type = 3;

  CURSOR next_rework_cur (cv_op_seq_id number) IS
  SELECT to_op_seq_id next_op, planning_pct
  FROM bom_operation_networks
  WHERE from_op_seq_id = cv_op_seq_id
  AND transition_type = 3;

  CURSOR next_op_cur (cv_op_seq_id number) IS
  SELECT to_op_seq_id next_op, planning_pct
  FROM bom_operation_networks
  WHERE from_op_seq_id = cv_op_seq_id
  AND transition_type <> 3;

  CURSOR next_op_cur1 (cv_op_seq_id number) IS
  SELECT to_op_seq_id next_op, planning_pct
  FROM bom_operation_networks
  WHERE from_op_seq_id = cv_op_seq_id
  AND transition_type <> 3;

  sanity_rework_pct NUMBER ;
  i NUMBER := 0;
  rework_loop_ends_op    NUMBER := 0;
  rework_effect_limit_op NUMBER := 0;
  dummy_loop BOOLEAN ;
  non_primary_loop BOOLEAN ;
  TABLE_ENDED  EXCEPTION;
  l_dummy NUMBER;
BEGIN
  FOR sanity_counter in 1..ntwk_op_tbl.COUNT LOOP
    ntwk_op_tbl(sanity_counter).cumulative_rwk_pct :=0;
  END LOOP;
  FOR sanity_counter in 2..ntwk_op_tbl.COUNT LOOP
  rework_effect_tbl.DELETE;
  Rework_Effect_index := 0;
  IF NOT is_dummy(sanity_counter) THEN
    rework_loop_ends_op    := 0;
    rework_effect_limit_op := 0;
    FOR rework_out_rec IN rework_out_cur(ntwk_op_tbl(sanity_counter).operation_seq_id) LOOP
     rework_loop_ends_op    := 0;
     rework_effect_limit_op := 0;
     sanity_rework_pct := rework_out_rec.planning_pct *
     (ntwk_op_tbl(sanity_counter).yield_nppct/100);
   IF (find_op(rework_out_rec.next_op) <> -1) THEN
     IF is_dummy(find_op(rework_out_rec.next_op)) THEN
       dummy_loop := TRUE;
	 i := find_op(rework_out_rec.next_op);
       WHILE dummy_loop LOOP
         FOR next_rework_rec IN next_rework_cur(ntwk_op_tbl(i).operation_seq_id) LOOP
            IF is_dummy(find_op(next_rework_rec.next_op)) THEN
              i := find_op(next_rework_rec.next_op);
            ELSE
              dummy_loop := FALSE;
              rework_loop_ends_op := find_op(next_rework_rec.next_op);
            END IF;
          END LOOP;
        END LOOP; -- END OF dummy_loop
      ELSE
        rework_loop_ends_op := find_op(rework_out_rec.next_op);
      END IF;
    END IF;
      /* At this point rework_loop_ends has start of rework  */
      /* Lets go now for the search of rework_effect_limit_op*/
    i := 0;
    IF(rework_loop_ends_op >0 ) THEN
      IF NOT on_primary_path(ntwk_op_tbl(sanity_counter).operation_seq_id) THEN
      FOR next_op_rec IN next_op_cur(ntwk_op_tbl(sanity_counter).operation_seq_id) LOOP
        IF NOT on_primary_path(next_op_rec.next_op) THEN
          non_primary_loop := TRUE;
          WHILE non_primary_loop LOOP
            IF(i = 0) THEN
              i := find_op(next_op_rec.next_op);
            END IF;
            IF ( i >= ntwk_op_tbl.COUNT) THEN
              raise TABLE_ENDED;
            END IF;
            FOR next_op_rec1 IN
            next_op_cur1(ntwk_op_tbl(i).operation_seq_id) LOOP
              IF NOT on_primary_path(next_op_rec1.next_op) THEN
                i := find_op(next_op_rec1.next_op);
              ELSE
                non_primary_loop := FALSE;
                rework_effect_limit_op := find_op(next_op_rec1.next_op);
              END IF;
            END LOOP;
          END LOOP; -- END OF non_primary_loop
        ELSE
          rework_effect_limit_op := find_op(next_op_rec.next_op);
        END IF;
      END LOOP;--END OF rework_effect_limit_op find LOOP
      ELSE
      rework_effect_limit_op := sanity_counter;
      END IF ; -- See if the operation from which the rework generates
      -- itself is on primary.

      Rework_Effect_index := 1;
      rework_effect_tbl.DELETE;
      g_total_rework_prob := 0;

      IF(rework_loop_ends_op < rework_effect_limit_op) THEN
	rework_effect_tbl(Rework_Effect_index).operation_seq_id :=
                 ntwk_op_tbl(rework_loop_ends_op).operation_seq_id;
        collect_total_rework_prob(rework_loop_ends_op,rework_effect_limit_op,sanity_rework_pct);
        Rework_Effect_index := 1;
        collect_ops_between_rework(rework_loop_ends_op,rework_effect_limit_op,sanity_rework_pct);
      ELSE
        rework_effect_tbl(Rework_Effect_index).operation_seq_id :=
                 ntwk_op_tbl(rework_effect_limit_op).operation_seq_id;
        collect_total_rework_prob(rework_loop_ends_op,rework_effect_limit_op,sanity_rework_pct);
      Rework_Effect_index := 1;
        collect_ops_between_rework(rework_loop_ends_op,rework_effect_limit_op,sanity_rework_pct);
     END IF;
    END IF;-- IF rework_loop_ends_op >0
   END LOOP;
  END IF;-- ONLY IF NO DUMMY
  END LOOP;
END calc_npp_sanity_when_rework;

END BOM_CALC_CYNP;

/
