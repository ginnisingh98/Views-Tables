--------------------------------------------------------
--  DDL for Package Body BOM_RTG_NETWORK_VALIDATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_RTG_NETWORK_VALIDATE_API" AS
/* $Header: BOMRNWVB.pls 115.2 99/08/05 13:21:58 porting ship  $ */

/*-------------------------------------------------------------------------
    Name
	get_routing_sequence_id
    Description
	Function to get the routing_sequence_id when the alternate key
	IDs are specified.
    Returns
        routing_sequence_id
+--------------------------------------------------------------------------*/
FUNCTION get_routing_sequence_id (
       	 	p_assy_item_id      IN  NUMBER,
        	p_org_id            IN  NUMBER,
        	p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

  l_rtg_seq_id NUMBER := NULL;

  BEGIN
     SELECT routing_sequence_id
     INTO   l_rtg_seq_id
     FROM   bom_operational_routings
     WHERE  assembly_item_id = p_assy_item_id
        AND    organization_id  = p_org_id
        AND    NVL(alternate_routing_designator, 'NONE') =
                                NVL(p_alt_rtg_desig, 'NONE');

     RETURN (l_rtg_seq_id);

  EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN NULL;
  END;

/*-------------------------------------------------------------------------
    Name
	check_network_exists
    Description
	Function to get the routing_sequence_id when the alternate key
	IDs are specified.
    Returns
	TRUE if a network of p_operation_type exists for p_rtg_sequence_id;
	FALSE otherwise.
+--------------------------------------------------------------------------*/
FUNCTION check_network_exists (
		p_rtg_sequence_id IN NUMBER,
		p_operation_type  IN NUMBER) RETURN BOOLEAN IS
  net_exists NUMBER;
  BEGIN
     SELECT 1
     INTO   net_exists
     FROM dual
     WHERE EXISTS (SELECT null
		   FROM bom_operation_networks_v
		   WHERE routing_sequence_id = p_rtg_sequence_id
			AND   operation_type = p_operation_type);

     RETURN (TRUE);
  EXCEPTION WHEN NO_DATA_FOUND THEN
     RETURN (FALSE);
  END check_network_exists;

/*-------------------------------------------------------------------------
    Name
	ref_pos
    Description
	Function to get the reference position which is the first row from
	the top of the table with flag = 'C'.
    Returns
	Reference, if there exists rows with flag = 'C';
	-1, otherwise.
+--------------------------------------------------------------------------*/
FUNCTION ref_pos (
		p_lnk_tbl  IN Lnk_Tbl_Type) RETURN NUMBER IS
  i INTEGER;
  BEGIN
     FOR i IN 1..p_lnk_tbl.COUNT LOOP
         IF p_lnk_tbl(i).flag = 'C' THEN
            RETURN (i);
         END IF;
     END LOOP;
     RETURN (-1);
  END ref_pos;

/*-------------------------------------------------------------------------
    Name
	ref_rev_pos
    Description
	Function to get the reference position which is the first row from
	the bottom of the table with flag = 'C'.
    Returns
	Reference, if there exists rows with flag = 'C';
	-1, otherwise.
+--------------------------------------------------------------------------*/
FUNCTION ref_rev_pos (
		p_lnk_tbl  IN Lnk_Tbl_Type) RETURN NUMBER IS
  i INTEGER;
  BEGIN
     FOR i IN REVERSE 1..p_lnk_tbl.COUNT LOOP
         IF p_lnk_tbl(i).flag = 'C' THEN
            RETURN (i);
         END IF;
     END LOOP;
     RETURN (-1);
  END ref_rev_pos;

/*-------------------------------------------------------------------------
    Name
	find_op
    Description
	Function to search the table for a particular operation seq.
    Returns
	TRUE, if p_op_seq_num in p_op_tbl;
	FALSE, otherwise.
+--------------------------------------------------------------------------*/
FUNCTION find_op (
                p_op_seq_num IN NUMBER,
                p_op_tbl     IN Op_Tbl_Type) RETURN BOOLEAN IS
  i INTEGER;
  BEGIN
        FOR i IN 1..p_op_tbl.COUNT LOOP
            IF p_op_tbl(i).operation_seq_num = p_op_seq_num THEN
               RETURN (TRUE);
            END IF;
        END LOOP;
        RETURN (FALSE);
  END find_op;

/*-------------------------------------------------------------------------
    Name
	is_connected
    Description
	Function to to see if there are any rows common in the two tables
	i.e. if the two tables are connected.
    Returns
	TRUE, if p_con_tbl is connected to p_mst_tbl;
	FALSE, otherwise.
+--------------------------------------------------------------------------*/
FUNCTION is_connected (
                p_con_tbl  IN Op_Tbl_Type,
                p_mst_tbl  IN Op_Tbl_Type) RETURN BOOLEAN IS
  i INTEGER;
  j INTEGER;
  BEGIN
	--dbms_output.put_line('check if connected');
     FOR i IN 1..p_mst_tbl.COUNT LOOP
        FOR j IN 1..p_con_tbl.COUNT LOOP
            IF p_mst_tbl(i).operation_seq_num
                        = p_con_tbl(j).operation_seq_num THEN
		 --dbms_output.put_line('TRUE');
                RETURN (TRUE);
            END IF;
        END LOOP;
     END LOOP;
 	--dbms_output.put_line('FALSE');
     RETURN (FALSE);
  END is_connected;

/*-------------------------------------------------------------------------
    Name
	get_all_links
    Description
	This PROCEDURE gets all the operation links on the network for
        the routing.
    Returns
        A PL/SQL table of Lnk_Tbl_Type type as OUT parameter that includes
        a list of all operation links for the routing network of
	p_operation_type.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_links (
    p_rtg_sequence_id   IN  NUMBER,
    p_operation_type    IN  NUMBER,
    x_Lnk_Tbl           OUT Lnk_Tbl_Type ) IS

  i INTEGER := 1;
  CURSOR all_links  IS
    SELECT from_op_seq_id,from_seq_num,
           to_op_seq_id
    FROM bom_operation_networks_v
    WHERE routing_sequence_id = p_rtg_sequence_id
      AND   operation_type = p_operation_type
      AND   transition_type <> 3
    ORDER BY from_seq_num;

  BEGIN
    FOR all_links_rec IN all_links LOOP
        x_Lnk_Tbl(i).from_op_seq_id := all_links_rec.from_op_seq_id;
        x_Lnk_Tbl(i).to_op_seq_id := all_links_rec.to_op_seq_id;
        x_Lnk_Tbl(i).flag := 'C';
	--dbms_output.put_line('Row #'||to_char(i)||' '||
	--		to_char(x_Lnk_Tbl(i).from_op_seq_id)||' '||
	--		to_char(x_Lnk_Tbl(i).to_op_seq_id)||' '||
	--		x_Lnk_Tbl(i).flag);
        i := i + 1;
    END LOOP;
  END get_all_links;

/*-------------------------------------------------------------------------
    Name
	get_all_start_nodes
    Description
	This PROCEDURE gets all the starting nodes of the operation links on
	the network for the routing.
    Returns
        A PL/SQL table of Op_Tbl_Type type as OUT parameter that includes
        a list of all starting nodes for the routing network of type
	p_operation_type.
+--------------------------------------------------------------------------*/
PROCEDURE get_all_start_nodes (
    p_rtg_sequence_id   IN  NUMBER,
    p_operation_type    IN  NUMBER,
    x_Op_Tbl           OUT Op_Tbl_Type ) IS

  i INTEGER := 1;
  CURSOR all_start_nodes  IS
    SELECT DISTINCT from_op_seq_id, from_seq_num
    FROM bom_operation_networks_v bonv
    WHERE routing_sequence_id = p_rtg_sequence_id
      AND   operation_type = p_operation_type
      AND   transition_type <> 3
      AND NOT EXISTS (SELECT NULL
			FROM  bom_operation_networks_v net
			WHERE net.to_op_seq_id = bonv.from_op_seq_id)
    ORDER BY from_seq_num;

  BEGIN
    FOR all_start_nodes_rec IN all_start_nodes LOOP
        x_Op_Tbl(i).operation_seq_id := all_start_nodes_rec.from_op_seq_id;
        x_Op_Tbl(i).operation_seq_num := all_start_nodes_rec.from_seq_num;
	--dbms_output.put_line('Row# '||to_char(i)||' '||
	--			to_char(x_Op_Tbl(i).operation_seq_id)||' '||
	--			to_char(x_Op_Tbl(i).operation_seq_num));
        i := i + 1;
    END LOOP;
  END get_all_start_nodes;

/*-------------------------------------------------------------------------
    Name
	create_con_op_list
    Description
	This PROCEDURE gets all the connected nodes on the network for the
	routing starting from the p_str_op_num node.
    Returns
        A PL/SQL table of Op_Tbl_Type type as OUT parameter that includes
        a list of all connected nodes for the routing network of type
	p_operation_type.
+--------------------------------------------------------------------------*/
PROCEDURE create_con_op_list (
    p_str_op_id		IN  NUMBER,
    p_str_op_num	IN  NUMBER,
    x_Op_Tbl           OUT Op_Tbl_Type ) IS

  i INTEGER := 2;
  l_op_seq_num NUMBER;

  CURSOR all_con_ops (c_str_op_id NUMBER) IS
    SELECT DISTINCT to_op_seq_id operation_sequence_id
    FROM bom_operation_networks
    CONNECT BY PRIOR to_op_seq_id = from_op_seq_id
        AND transition_type <> 3
    START WITH from_op_seq_id = c_str_op_id
        AND transition_type <> 3;

  BEGIN
    --dbms_output.put_line('Connected lst----');
    -- create a list of connected nodes starting from the start node
    -- add the start node
    x_Op_Tbl(1).operation_seq_id := p_str_op_id;
    x_Op_Tbl(1).operation_seq_num := p_str_op_num;
    --dbms_output.put_line('Row# 1'||' '||to_char(x_Op_Tbl(1).operation_seq_id)||' '||
    --					to_char(x_Op_Tbl(1).operation_seq_num));
    FOR all_con_op_rec IN all_con_ops(p_str_op_id) LOOP
	SELECT operation_seq_num
        INTO   l_op_seq_num
        FROM   bom_operation_sequences
        WHERE  operation_sequence_id =
                   all_con_op_rec.operation_sequence_id;
        x_Op_Tbl(i).operation_seq_id :=
                        all_con_op_rec.operation_sequence_id;
        x_Op_Tbl(i).operation_seq_num := l_op_seq_num;
	--dbms_output.put_line('Row# '||to_char(i)||' '||to_char(x_Op_Tbl(i).operation_seq_id)||' '||
	--				to_char(x_Op_Tbl(i).operation_seq_num));
        i := i + 1;
    END LOOP;
  EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;

  END create_con_op_list;

/*-------------------------------------------------------------------------
    Name
	append_to_mst_lst
    Description
	This PROCEDURE appends p_Con_Op_Tbl to the master list x_Mst_Op_Tbl
	making sure that there is no redundancy.
    Returns
        A PL/SQL table of Op_Tbl_Type type as IN OUT parameter that is
	the master list of the connected nodes in the network.
+--------------------------------------------------------------------------*/
PROCEDURE append_to_mst_lst (
	p_Con_Op_Tbl IN     Op_Tbl_Type,
	x_Mst_Op_Tbl IN OUT Op_Tbl_Type) IS

  i INTEGER;
  mst_ctr INTEGER;
  BEGIN
    mst_ctr := x_Mst_Op_Tbl.COUNT + 1;
	   --dbms_output.put_line('Append to Mst lst');
    FOR i IN 1..p_Con_Op_Tbl.COUNT LOOP
	IF NOT find_op(p_Con_Op_Tbl(i).operation_seq_num, x_Mst_Op_Tbl) THEN
	   x_Mst_Op_Tbl(mst_ctr).operation_seq_id :=
				p_Con_Op_Tbl(i).operation_seq_id;
	   x_Mst_Op_Tbl(mst_ctr).operation_seq_num :=
				p_Con_Op_Tbl(i).operation_seq_num;
	   --dbms_output.put_line('Mst: row# '||to_char(mst_ctr)||' '||
	   --			to_char(x_Mst_Op_Tbl(mst_ctr).operation_seq_id)||' '||
	   --			to_char(x_Mst_Op_Tbl(mst_ctr).operation_seq_num));
    	   mst_ctr := mst_ctr + 1;
	END IF;
    END LOOP;

  END append_to_mst_lst;


/*-------------------------------------------------------------------------
    Name
	validate_routing_network
    Description
	This PROCEDURE is the main procedure thats called from the form,
	java applet code, or the Routing Open Interface code to validate
	the Routing Network.
    Returns
	x_status  -- Result of the validation.
	x_message -- Message to include the LOOP or Broken Link it they exist.
+--------------------------------------------------------------------------*/
PROCEDURE validate_routing_network(
    p_rtg_sequence_id 	IN  NUMBER,
    p_assy_item_id      IN  NUMBER,
    p_org_id            IN  NUMBER,
    p_alt_rtg_desig     IN  VARCHAR2 DEFAULT NULL,
    p_operation_type	IN  NUMBER,
    x_status		OUT VARCHAR2,
    x_message		OUT VARCHAR2) IS

  l_rtg_seq_id NUMBER := NULL;
  l_Lnk_Tbl Lnk_Tbl_Type;
  l_connected INTEGER;
  l_top_ptr INTEGER;
  l_bot_ptr INTEGER;
  l_flag_changed INTEGER := 1;
  l_Str_Op_Tbl Op_Tbl_Type;
  l_Mtr_Op_Tbl Op_Tbl_Type;
  l_Con_Op_Tbl Op_Tbl_Type;

  BEGIN
     IF p_rtg_sequence_id is NOT NULL THEN
	--dbms_output.put_line('rtg seq specified');
	l_rtg_seq_id := p_rtg_sequence_id;
     ELSE
	--dbms_output.put_line('rtg seq retreived');
        l_rtg_seq_id := get_routing_sequence_id (
                                        p_assy_item_id,
                                        p_org_id,
                                        p_alt_rtg_desig);
     END IF;

     IF check_network_exists(l_rtg_seq_id, p_operation_type) THEN
	--dbms_output.put_line('network EXISTS');

	-- Check For LOOPS
	-- Create the PL/SQL table
	get_all_links (l_rtg_seq_id,
			p_operation_type,
			l_Lnk_Tbl);

	--dbms_output.put_line('START check for loops');
	-- get the top and bottom reference pointers
	l_top_ptr := ref_pos(l_Lnk_Tbl);
	l_bot_ptr := ref_rev_pos(l_Lnk_Tbl);
	--dbms_output.put_line('top_ptr:'|| to_char(l_top_ptr));
	--dbms_output.put_line('bot_ptr:'|| to_char(l_bot_ptr));

	-- While there are rows with flag='C'
	WHILE (l_top_ptr <> -1 and l_bot_ptr <> -1 and l_flag_changed = 1) LOOP
	    l_flag_changed := 0;
	    FOR t_counter IN l_top_ptr..l_bot_ptr LOOP
		IF l_Lnk_Tbl(t_counter).flag = 'C' THEN
		    l_connected := 0;
	    	    --dbms_output.put_line('in loop1 :'||to_char(t_counter)||' time');
	    	    FOR j IN l_top_ptr..l_bot_ptr LOOP
			IF (l_Lnk_Tbl(t_counter).from_op_seq_id = l_Lnk_Tbl(j).to_op_seq_id
					AND l_Lnk_Tbl(j).flag = 'C') THEN
		  		l_connected := 1;
			END IF;
	    	    END LOOP;
	    	    IF (l_connected = 0) THEN
			l_Lnk_Tbl(t_counter).flag := 'D';
			l_flag_changed := 1;
	    		--dbms_output.put_line('changing row# '||to_char(t_counter)
			--					||' '||'flag to D');
	    	    END IF;
	    	END IF;
	    END LOOP;

	    l_top_ptr := ref_pos(l_Lnk_Tbl);
            l_bot_ptr := ref_rev_pos(l_Lnk_Tbl);
	    --dbms_output.put_line('top_ptr:'|| to_char(l_top_ptr));
	    --dbms_output.put_line('bot_ptr:'|| to_char(l_bot_ptr));

	    l_flag_changed := 0;
	    IF (l_top_ptr <> -1 and l_bot_ptr <> -1) THEN
	   	FOR b_counter IN REVERSE l_top_ptr..l_bot_ptr LOOP
	      	    IF l_Lnk_Tbl(b_counter).flag = 'C' THEN
	     		l_connected := 0;
	     		--dbms_output.put_line('in loop2 :'||to_char(b_counter)||' time');
	     		FOR j IN REVERSE l_top_ptr..l_bot_ptr LOOP
	 	    	    IF (l_Lnk_Tbl(b_counter).to_op_seq_id = l_Lnk_Tbl(j).from_op_seq_id
							and l_Lnk_Tbl(j).flag = 'C') THEN
				l_connected := 1;
		    	    END IF;
	        	END LOOP;
	        	IF (l_connected = 0) THEN
			    l_Lnk_Tbl(b_counter).flag := 'D';
			    l_flag_changed := 1;
	        	    --dbms_output.put_line('changing row# '||to_char(b_counter)||' '||
			--							'flag to D');
	        	END IF;
	      	    END IF;
	   	END LOOP;
	    END IF;
	    l_top_ptr := ref_pos(l_Lnk_Tbl);
	    l_bot_ptr := ref_rev_pos(l_Lnk_Tbl);
	    --dbms_output.put_line('top_ptr:'|| to_char(l_top_ptr));
	    --dbms_output.put_line('bot_ptr:'|| to_char(l_bot_ptr));
	END LOOP; -- while

	IF (l_top_ptr <> -1 or l_bot_ptr <> -1) THEN
	    FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_LOOP_EXISTS');
	    x_status := 'F'; -- LOOP exists
            x_message:= FND_MESSAGE.GET;
	    RETURN;
	END IF;
	--dbms_output.put_line('END check for loops');

	-- Check For BROKEN LINKS
	--dbms_output.put_line('START check for BROKEN links');

	get_all_start_nodes(l_rtg_seq_id,
                        	p_operation_type,
                        	l_Str_Op_Tbl);
	-- add the first start node into the master list
	l_Mtr_Op_Tbl(1).operation_seq_id := l_Str_Op_Tbl(1).operation_seq_id;
	l_Mtr_Op_Tbl(1).operation_seq_num := l_Str_Op_Tbl(1).operation_seq_num;
	--dbms_output.put_line('Mst: row# 1 '||to_char(l_Mtr_Op_Tbl(1).operation_seq_id)||' '||
	--			to_char(l_Mtr_Op_Tbl(1).operation_seq_num));
	-- get each start node, get the nodes it is connected to, compare with
	-- the master list to see if there is any common node i.e. connected.
	-- if there is, add the nodes to the master list. if there is none,
	-- this is the broken link; print the broken link.

	FOR i IN 1..l_Str_Op_Tbl.COUNT LOOP
	  create_con_op_list(l_Str_Op_Tbl(i).operation_seq_id,
				l_Str_Op_Tbl(i).operation_seq_num,
				l_Con_Op_Tbl);
	 IF is_connected(l_Con_Op_Tbl, l_Mtr_Op_Tbl) THEN
	    -- add the nodes to the master list
	    append_to_mst_lst(l_Con_Op_Tbl, l_Mtr_Op_Tbl);
            -- add the starting node into the Master list
            IF NOT find_op (l_Str_Op_Tbl(i).operation_seq_num, l_Mtr_Op_Tbl) THEN
                l_Mtr_Op_Tbl(l_Mtr_Op_Tbl.COUNT+1).operation_seq_id :=
                                                l_Str_Op_Tbl(i).operation_seq_id;
                l_Mtr_Op_Tbl(l_Mtr_Op_Tbl.COUNT+1).operation_seq_num :=
                                                l_Str_Op_Tbl(i).operation_seq_num;
            END IF;
	    -- delete the connected list for re-use
	    l_Con_Op_Tbl.DELETE;
	 ELSE
	    --dbms_output.put_line('BROKEN link exists');
	    FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_BROKEN_LINK_EXIST');
	    x_status := 'F'; -- BROKEN Link exists
            x_message:= FND_MESSAGE.GET;
	    RETURN;
	 END IF;
	END LOOP;

	FND_MESSAGE.SET_NAME('BOM','BOM_RTG_NTWK_VALID');
	x_status := 'S'; -- NO LOOPS or BROKEN Link exists
	x_message:= FND_MESSAGE.GET;

     ELSE
		-- nothing done when NO network exists
		x_status := 'F'; -- NO Network
		x_message:= '';
     END IF;

  END validate_routing_network;


END BOM_RTG_NETWORK_VALIDATE_API;

/
