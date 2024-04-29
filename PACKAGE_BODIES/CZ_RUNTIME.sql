--------------------------------------------------------
--  DDL for Package Body CZ_RUNTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_RUNTIME" AS
/* $Header: czrunb.pls 120.7 2007/05/04 19:01:22 qmao ship $ */
  PS_NODE_BOM_MODEL_TYPE   CONSTANT INTEGER := 436;
  PS_NODE_REFERENCE_TYPE   CONSTANT INTEGER := 263;
  TYPE NUM_TBL_TYPE IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

  G_MAX_PAGE_INCLUSION_DEPTH CONSTANT INTEGER := 1000000;

  CONFIG_STATUS_COMPLETE  CONSTANT  VARCHAR2(1) := '2';
  JRAD_STYLE_UI CONSTANT  NUMBER := 7;


PROCEDURE sort_options	( p_ui_def_id 	IN	NUMBER,
			  p_property_id IN	NUMBER,
			  p_sort_order	IN	NUMBER,
			  x_sorted_table IN OUT NOCOPY system.cz_sort_tbl_type
			 )
IS
v_ui_features_ref	NUM_TBL_TYPE;
v_ui_opt_meth_ref	NUM_TBL_TYPE;
v_ui_opt_prop_ref	NUM_TBL_TYPE;
v_ui_opt_ord_ref	NUM_TBL_TYPE;
v_ui_nodes_tbl		NUM_TBL_TYPE;
v_ui_nodes_ref		NUM_TBL_TYPE;
v_ps_nodes_tbl		NUM_TBL_TYPE;
v_ps_nodes_ref		NUM_TBL_TYPE;
v_ui_feat_ref		NUM_TBL_TYPE;
v_ui_node_count		NUMBER;
v_property_data_type    cz_properties.data_type%TYPE;
BEGIN
	v_ui_features_ref.DELETE;
	v_ui_opt_meth_ref.DELETE;
	v_ui_opt_prop_ref.DELETE;
	v_ui_opt_ord_ref.DELETE ;
	x_sorted_table	:= system.cz_sort_tbl_type();
	IF (p_ui_def_id IS NOT NULL) THEN
		IF (p_property_id = -1) THEN
			BEGIN
				SELECT ui_node_id
					,option_sort_method
					,option_sort_property
					,option_sort_order
				BULK
				COLLECT
				INTO	 v_ui_features_ref
					,v_ui_opt_meth_ref
					,v_ui_opt_prop_ref
					,v_ui_opt_ord_ref
				FROM	cz_ui_nodes
				WHERE   cz_ui_nodes.ui_def_id 	= p_ui_def_id
				AND	cz_ui_nodes.deleted_flag 	= '0'
				AND	cz_ui_nodes.ui_node_type	= 148
				AND	cz_ui_nodes.option_sort_method  = 2;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_sorted_table.DELETE;
			WHEN OTHERS THEN
				RAISE;
			END;

		ELSE
			BEGIN
				SELECT ui_node_id
					,option_sort_method
					,option_sort_property
					,option_sort_order
				BULK
				COLLECT
				INTO	 v_ui_features_ref
					,v_ui_opt_meth_ref
					,v_ui_opt_prop_ref
					,v_ui_opt_ord_ref
				FROM	cz_ui_nodes
				WHERE cz_ui_nodes.ui_def_id 	= p_ui_def_id
				AND	cz_ui_nodes.deleted_flag 	= '0'
				AND	cz_ui_nodes.ui_node_type	= 148
				AND   cz_ui_nodes.option_sort_method  IN (-1, 2);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_sorted_table.DELETE;
			WHEN OTHERS THEN
				RAISE;
			END;
		END IF;
	END IF;
	IF (v_ui_features_ref.COUNT > 0) THEN
		v_ui_nodes_ref.DELETE;
		v_ps_nodes_ref.DELETE;
		v_ui_feat_ref.DELETE;
		v_ui_node_count := 0.0;
		FOR I IN v_ui_features_ref.FIRST..v_ui_features_ref.LAST
		LOOP
			IF (  (v_ui_features_ref(i) IS NOT NULL )
				AND ( (v_ui_opt_meth_ref(i) = 2)
			 	       OR (v_ui_opt_meth_ref(i) = -1) ) )  THEN
				v_ui_nodes_tbl.DELETE;
				v_ps_nodes_tbl.DELETE;

				IF (v_ui_opt_meth_ref(i) = -1) THEN
					v_ui_opt_ord_ref(i)  := p_sort_order;
					v_ui_opt_prop_ref(i) := p_property_id;
				END IF;

				-----get the data_type of the property
				IF (v_ui_opt_prop_ref(i) IS NOT NULL) THEN
					BEGIN
						SELECT data_type INTO v_property_data_type
						FROM   cz_properties
						WHERE  cz_properties.property_id = v_ui_opt_prop_ref(i)
						AND    cz_properties.deleted_flag = '0';
					EXCEPTION
					WHEN OTHERS THEN
						RAISE;
					END;
				END IF;

				IF (v_ui_opt_ord_ref(i) = 0) THEN

					BEGIN
						-----if datatype is integer or decimal then order numerically
                                           IF (v_property_data_type IN (1,2,3) ) THEN

select v.ui_node_id, v.ps_node_id
  bulk collect into v_ui_nodes_tbl, v_ps_nodes_tbl
  from
  (
  SELECT ps_node_id, ui_node_id, parent_id, ps_node_name, property_id, property_name,
        data_type, substr (min (cnct || property_value), 3) as
        property_value,max (item_id) as item_id, max (item_type_id) as
        item_type_id, devl_project_id,default_value
  from (
        select  '1P'  as cnct, psn1.devl_project_id, psn1.ps_node_id,
              psn1.name as ps_node_name,psn1.parent_id, nvl (
              psp1.data_value, prp1.def_value) as property_value,
              prp1.name as property_name, prp1.property_id,
              prp1.data_type, psn1.item_id, to_number (null)
              as item_type_id, prp1.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn1,
              cz_ps_prop_vals psp1,
              CZ_UI_NODES uin,
              cz_properties prp1
        where psn1.deleted_flag = '0'
          and psn1.ps_node_id =psp1.ps_node_id
          and uin.ps_node_id = psn1.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and psp1.deleted_flag = '0'
          and psp1.property_id =prp1.property_id
          and prp1.deleted_flag = '0'
        union all
        select  '2I'  as cnct, psn2.devl_project_id, psn2.ps_node_id,
              psn2.name as ps_node_name, psn2.parent_id,nvl (
              ipv2.property_value, prp2.def_value) as property_value,
              prp2.name as property_name, prp2.property_id,
              prp2.data_type,psn2.item_id, to_number (null) as item_type_id
              , prp2.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn2,
              cz_ui_nodes uin,
              cz_item_property_values ipv2,
              cz_properties prp2,
              cz_item_masters itm2
        where psn2.deleted_flag = '0'
          and psn2.item_id = ipv2.item_id
          and ipv2.deleted_flag = '0'
          and ipv2.property_id = prp2.property_id
          and uin.ps_node_id = psn2.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and prp2.deleted_flag = '0'
          and itm2.item_id = ipv2.item_id
        union all
        select
              '3T'  as cnct, psn3.devl_project_id, psn3.ps_node_id,
              psn3.name as ps_node_name, psn3.parent_id, prp3.def_value
              as property_value,prp3.name as property_name,
              prp3.property_id,
              prp3.data_type,psn3.item_id, itm3.item_type_id , prp3.def_value as
              default_value, uin.ui_node_id
          from
              cz_ps_nodes psn3,
              cz_item_masters itm3,
              cz_ui_nodes uin,
              cz_item_type_properties itp3,
              cz_properties prp3
        where  psn3.deleted_flag = '0'
          and psn3.item_id = itm3.item_id
          and itm3.deleted_flag = '0'
          and itm3.item_type_id = itp3.item_type_id
          and  uin.ps_node_id = psn3.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and itp3.deleted_flag = '0'
          and itp3.property_id = prp3.property_id
          and prp3.deleted_flag = '0'
  )
  group by ps_node_id, parent_id, ps_node_name, devl_project_id,
 property_id,property_name, data_type, default_value, ui_node_id
  ) v
 WHERE v.PROPERTY_ID = v_ui_opt_prop_ref(i)
 ORDER BY To_number(V.property_value) DESC;

						 ELSE

select v.ui_node_id, v.ps_node_id
  bulk collect into v_ui_nodes_tbl, v_ps_nodes_tbl
  from
  (
  SELECT ps_node_id, ui_node_id, parent_id, ps_node_name, property_id, property_name,
        data_type, substr (min (cnct || property_value), 3) as
        property_value,max (item_id) as item_id, max (item_type_id) as
        item_type_id,devl_project_id,default_value
  from (
        select  '1P'  as cnct, psn1.devl_project_id, psn1.ps_node_id,
              psn1.name as ps_node_name,psn1.parent_id, nvl (
              psp1.data_value, prp1.def_value) as property_value,
              prp1.name as property_name, prp1.property_id,
              prp1.data_type,psn1.item_id, to_number (null)
              as item_type_id, prp1.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn1,
              cz_ps_prop_vals psp1,
              CZ_UI_NODES uin,
              cz_properties prp1
        where psn1.deleted_flag = '0'
          and psn1.ps_node_id =psp1.ps_node_id
          and uin.ps_node_id = psn1.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and psp1.deleted_flag = '0'
          and psp1.property_id =prp1.property_id
          and prp1.deleted_flag = '0'
        union all
        select  '2I'  as cnct, psn2.devl_project_id, psn2.ps_node_id,
              psn2.name as ps_node_name, psn2.parent_id,nvl (
              ipv2.property_value, prp2.def_value) as property_value,
              prp2.name as property_name, prp2.property_id,
              prp2.data_type,psn2.item_id, to_number (null) as item_type_id
              , prp2.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn2,
              cz_ui_nodes uin,
              cz_item_property_values ipv2,
              cz_properties prp2,
              cz_item_masters itm2
        where psn2.deleted_flag = '0'
          and psn2.item_id = ipv2.item_id
          and ipv2.deleted_flag = '0'
          and ipv2.property_id = prp2.property_id
          and uin.ps_node_id = psn2.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and prp2.deleted_flag = '0'
          and itm2.item_id = ipv2.item_id
        union all
        select
              '3T'  as cnct, psn3.devl_project_id, psn3.ps_node_id,
              psn3.name as ps_node_name, psn3.parent_id, prp3.def_value
              as property_value,prp3.name as property_name,
              prp3.property_id,
              prp3.data_type,psn3.item_id, itm3.item_type_id , prp3.def_value as
              default_value, uin.ui_node_id
          from
              cz_ps_nodes psn3,
              cz_item_masters itm3,
              cz_ui_nodes uin,
              cz_item_type_properties itp3,
              cz_properties prp3
        where  psn3.deleted_flag = '0'
          and psn3.item_id = itm3.item_id
          and itm3.deleted_flag = '0'
          and itm3.item_type_id = itp3.item_type_id
          and  uin.ps_node_id = psn3.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and itp3.deleted_flag = '0'
          and itp3.property_id = prp3.property_id
          and prp3.deleted_flag = '0'
  )
  group by ps_node_id, parent_id, ps_node_name, devl_project_id,
 property_id,property_name, data_type, default_value, ui_node_id
  ) v
 WHERE v.PROPERTY_ID = v_ui_opt_prop_ref(i)
 ORDER BY  V.PROPERTY_VALUE DESC;

						 END IF;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						NULL;
					WHEN OTHERS THEN
						RAISE;
					END;
				ELSIF (v_ui_opt_ord_ref(i) = 1) THEN

					BEGIN

						IF (v_property_data_type IN (1,2) ) THEN
select v.ui_node_id, v.ps_node_id
  bulk collect into v_ui_nodes_tbl, v_ps_nodes_tbl
  from
  (
  SELECT ps_node_id, ui_node_id, parent_id, ps_node_name, property_id, property_name,
        data_type, substr (min (cnct || property_value), 3) as
        property_value,max (item_id) as item_id, max (item_type_id) as
        item_type_id,devl_project_id,default_value
  from (
        select  '1P'  as cnct, psn1.devl_project_id, psn1.ps_node_id,
              psn1.name as ps_node_name,psn1.parent_id, nvl (
              psp1.data_value, prp1.def_value) as property_value,
              prp1.name as property_name, prp1.property_id,
              prp1.data_type,psn1.item_id, to_number (null)
              as item_type_id, prp1.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn1,
              cz_ps_prop_vals psp1,
              CZ_UI_NODES uin,
              cz_properties prp1
        where psn1.deleted_flag = '0'
          and psn1.ps_node_id =psp1.ps_node_id
          and uin.ps_node_id = psn1.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and psp1.deleted_flag = '0'
          and psp1.property_id =prp1.property_id
          and prp1.deleted_flag = '0'
        union all
        select  '2I'  as cnct, psn2.devl_project_id, psn2.ps_node_id,
              psn2.name as ps_node_name, psn2.parent_id,nvl (
              ipv2.property_value, prp2.def_value) as property_value,
              prp2.name as property_name, prp2.property_id,
              prp2.data_type,psn2.item_id, to_number (null) as item_type_id
              , prp2.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn2,
              cz_ui_nodes uin,
              cz_item_property_values ipv2,
              cz_properties prp2,
              cz_item_masters itm2
        where psn2.deleted_flag = '0'
          and psn2.item_id = ipv2.item_id
          and ipv2.deleted_flag = '0'
          and ipv2.property_id = prp2.property_id
          and uin.ps_node_id = psn2.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and prp2.deleted_flag = '0'
          and itm2.item_id = ipv2.item_id
        union all
        select
              '3T'  as cnct, psn3.devl_project_id, psn3.ps_node_id,
              psn3.name as ps_node_name, psn3.parent_id, prp3.def_value
              as property_value,prp3.name as property_name,
              prp3.property_id,
              prp3.data_type,psn3.item_id, itm3.item_type_id , prp3.def_value as
              default_value, uin.ui_node_id
          from
              cz_ps_nodes psn3,
              cz_item_masters itm3,
              cz_ui_nodes uin,
              cz_item_type_properties itp3,
              cz_properties prp3
        where  psn3.deleted_flag = '0'
          and psn3.item_id = itm3.item_id
          and itm3.deleted_flag = '0'
          and itm3.item_type_id = itp3.item_type_id
          and  uin.ps_node_id = psn3.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and itp3.deleted_flag = '0'
          and itp3.property_id = prp3.property_id
          and prp3.deleted_flag = '0'
  )
  group by ps_node_id, parent_id, ps_node_name, devl_project_id,
 property_id,property_name, data_type, default_value, ui_node_id
  ) v
 WHERE v.PROPERTY_ID = v_ui_opt_prop_ref(i)
 ORDER BY To_number(V.property_value) ASC;


						 ELSE
select v.ui_node_id, v.ps_node_id
  bulk collect into v_ui_nodes_tbl, v_ps_nodes_tbl
  from
  (
  SELECT ps_node_id, ui_node_id, parent_id, ps_node_name, property_id, property_name,
        data_type, substr (min (cnct || property_value), 3) as
        property_value,max (item_id) as item_id, max (item_type_id) as
        item_type_id,devl_project_id,default_value
  from (
        select  '1P'  as cnct, psn1.devl_project_id, psn1.ps_node_id,
              psn1.name as ps_node_name,psn1.parent_id, nvl (
              psp1.data_value, prp1.def_value) as property_value,
              prp1.name as property_name, prp1.property_id,
              prp1.data_type, psn1.item_id, to_number (null)
              as item_type_id, prp1.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn1,
              cz_ps_prop_vals psp1,
              CZ_UI_NODES uin,
              cz_properties prp1
        where psn1.deleted_flag = '0'
          and psn1.ps_node_id =psp1.ps_node_id
          and uin.ps_node_id = psn1.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and psp1.deleted_flag = '0'
          and psp1.property_id =prp1.property_id
          and prp1.deleted_flag = '0'
        union all
        select  '2I'  as cnct, psn2.devl_project_id, psn2.ps_node_id,
              psn2.name as ps_node_name, psn2.parent_id,nvl (
              ipv2.property_value, prp2.def_value) as property_value,
              prp2.name as property_name, prp2.property_id,
              prp2.data_type, psn2.item_id, to_number (null) as item_type_id
              , prp2.def_value as default_value, uin.ui_node_id
          from cz_ps_nodes psn2,
              cz_ui_nodes uin,
              cz_item_property_values ipv2,
              cz_properties prp2,
              cz_item_masters itm2
        where psn2.deleted_flag = '0'
          and psn2.item_id = ipv2.item_id
          and ipv2.deleted_flag = '0'
          and ipv2.property_id = prp2.property_id
          and uin.ps_node_id = psn2.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and prp2.deleted_flag = '0'
          and itm2.item_id = ipv2.item_id
        union all
        select
              '3T'  as cnct, psn3.devl_project_id, psn3.ps_node_id,
              psn3.name as ps_node_name, psn3.parent_id, prp3.def_value
              as property_value,prp3.name as property_name,
              prp3.property_id,
              prp3.data_type, psn3.item_id, itm3.item_type_id , prp3.def_value as
              default_value, uin.ui_node_id
          from
              cz_ps_nodes psn3,
              cz_item_masters itm3,
              cz_ui_nodes uin,
              cz_item_type_properties itp3,
              cz_properties prp3
        where  psn3.deleted_flag = '0'
          and psn3.item_id = itm3.item_id
          and itm3.deleted_flag = '0'
          and itm3.item_type_id = itp3.item_type_id
          and  uin.ps_node_id = psn3.ps_node_id
          and uin.PARENT_ID = v_ui_features_ref(i)
          and uin.DELETED_FLAG = '0'
          and itp3.deleted_flag = '0'
          and itp3.property_id = prp3.property_id
          and prp3.deleted_flag = '0'
  )
  group by ps_node_id, parent_id, ps_node_name, devl_project_id,
 property_id,property_name, data_type, default_value, ui_node_id
  ) v
 WHERE v.PROPERTY_ID = v_ui_opt_prop_ref(i)
 ORDER BY V.PROPERTY_VALUE ASC; END IF;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						NULL;
					WHEN OTHERS THEN
						RAISE;
					END;
				ELSE
					-----do nothing
					NULL;
				END IF;
			END IF;
			v_ui_node_count	:= v_ui_nodes_ref.COUNT;
			IF (v_ui_nodes_tbl.COUNT > 0) THEN
				FOR J IN v_ui_nodes_tbl.FIRST..v_ui_nodes_tbl.LAST
				LOOP
					IF(v_ui_nodes_tbl(j) IS NOT NULL) THEN
						v_ui_node_count				:= v_ui_node_count + 1;
						v_ui_nodes_ref(v_ui_node_count)		:= v_ui_nodes_tbl(j);
						v_ps_nodes_ref(v_ui_node_count)		:= v_ps_nodes_tbl(j);
						v_ui_feat_ref(v_ui_node_count)		:= j;
					END IF;
				END LOOP;
			END IF;
		END LOOP;
	END IF;
	IF (v_ui_nodes_ref.COUNT > 0) THEN
		x_sorted_table.EXTEND(v_ui_nodes_ref.COUNT);
		FOR final IN v_ui_nodes_ref.FIRST..v_ui_nodes_ref.LAST
		LOOP
		 	x_sorted_table(final)	:= system.cz_sort_obj_type(v_ui_nodes_ref(final),v_ui_feat_ref(final));
		END LOOP;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	 RAISE_APPLICATION_ERROR (-20001,SQLERRM);
END;
------------------------------------------------------------------------
  -- checks if a node (p_parent_id) is the ancestor of the other node (p_node_id)
  FUNCTION check_parent(p_parent_id IN NUMBER, p_node_id IN NUMBER, p_model_id IN NUMBER)
    RETURN BOOLEAN
  IS
    CURSOR ps_node_cursor IS
      SELECT ps_node_id
      FROM cz_ps_nodes
      WHERE devl_project_id = p_model_id
      START WITH ps_node_id = p_node_id
      CONNECT BY ps_node_id = PRIOR parent_ID;
  BEGIN
    FOR ps_node_rec IN ps_node_cursor LOOP
      EXIT WHEN ps_node_cursor%NOTFOUND;
      IF (ps_node_rec.ps_node_id = p_parent_id) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
    RETURN FALSE;
  END check_parent;
---------------------------------------------------------------------------------
  -- identifies contained bom models in a model and returns root node id(s) of found bom(s)
  PROCEDURE get_root_bom_node_internal(p_model_id IN NUMBER,
                                       p_ps_node_id IN OUT NOCOPY NUMBER,
                                       p_ids IN OUT NOCOPY NUM_TBL_TYPE
                                      )
  IS
    v_persistent_node_id    NUMBER;
    v_ps_node_id            NUMBER;
    v_parent_id             NUMBER;
    v_ps_node_type          NUMBER;
    v_reference_id          NUMBER;
    v_bom_model_id          NUMBER;
    v_ids                   NUM_TBL_TYPE;
    CURSOR ps_node_cursor IS
      SELECT persistent_node_id, ps_node_id, parent_id, ps_node_type, reference_id
      FROM CZ_PS_NODES
      WHERE devl_project_id = p_model_id
        AND ps_node_type in (PS_NODE_BOM_MODEL_TYPE, PS_NODE_REFERENCE_TYPE)
        AND deleted_flag = '0'
      ORDER BY ps_node_type DESC;
  BEGIN
    FOR ps_node_rec IN ps_node_cursor LOOP
      EXIT WHEN ps_node_cursor%NOTFOUND;
      v_persistent_node_id := ps_node_rec.persistent_node_id;
      v_ps_node_id := ps_node_rec.ps_node_id;
      v_parent_id := ps_node_rec.parent_id;
      v_ps_node_type := ps_node_rec.ps_node_type;
      v_reference_id := ps_node_rec.reference_id;
      IF (v_ps_node_type = PS_NODE_BOM_MODEL_TYPE) THEN
        p_ps_node_id := v_ps_node_id;
        p_ids(p_ids.count + 1) := v_persistent_node_id;
        IF (v_parent_id IS NULL) THEN
          RETURN;
        ELSE
          v_bom_model_id := v_ps_node_id;
        END IF;
      ELSE
        -- recursively looks up further by reference_id if no bom model found yet so far
        -- or found a bom model but the referring node is not a descendant of the bom root
        IF (v_bom_model_id IS NULL OR (NOT check_parent(v_bom_model_id, v_ps_node_id, p_model_id))) THEN
          get_root_bom_node_internal(v_reference_id, p_ps_node_id, p_ids);
        END IF;
      END IF;
    END LOOP;
  END get_root_bom_node_internal;
--------------------------------------------------------------------------
  /* wrapper for getting root bom node id(s) in a model
     Aug. 28, 2001 created for dio root bom node looking up
     Sept. 18, 2001 modified to set p_err_flag to 2 if no bom found for publication
  */
  PROCEDURE get_root_bom_node(p_model_id IN NUMBER,
                              p_persistent_node_id OUT NOCOPY NUMBER,
                              p_ps_node_id OUT NOCOPY NUMBER,
                              p_err_flag OUT NOCOPY VARCHAR2,
                              p_err_msg OUT NOCOPY VARCHAR2
                             )
  IS
    v_ids   NUM_TBL_TYPE;
  BEGIN
    get_root_bom_node_internal(p_model_id, p_ps_node_id, v_ids);
    IF (v_ids.count = 0) THEN
      p_err_flag := 2;
      p_err_msg := 'ERROR: No BOM component found in model ' || TO_CHAR(p_model_id);
    ELSIF (v_ids.count = 1) THEN
      p_err_flag := '0';
      p_persistent_node_id := v_ids(1);
    ELSE
      p_err_flag := '1';
      p_err_msg := 'ERROR: Two bom models exist in model ' || TO_CHAR(p_model_id) ||
                   ' at different subtrees (root bom persistent node id=' || TO_CHAR(v_ids(1)) || ',' || TO_CHAR(v_ids(2)) || ').';
    END IF;
  END get_root_bom_node;

---------------------------------------------------------------------------------
PROCEDURE get_config_info(p_config_hdr_id  IN  NUMBER
                         ,p_config_rev_nbr IN  NUMBER
                         ,x_component_id         OUT  NOCOPY  NUMBER
                         ,x_top_item_id          OUT  NOCOPY  NUMBER
                         ,x_organization_id      OUT  NOCOPY  NUMBER
                         ,x_quantity             OUT  NOCOPY  NUMBER
                         ,x_usage_name           OUT  NOCOPY  VARCHAR2
                         ,x_effective_date       OUT  NOCOPY  DATE
                         ,x_config_date_created  OUT  NOCOPY  DATE
                         ,x_complete_flag        OUT  NOCOPY  VARCHAR2
                         ,x_valid_flag           OUT  NOCOPY  VARCHAR2
                         ,x_return_status        OUT  NOCOPY  VARCHAR2
                         ,x_msg_data             OUT  NOCOPY  VARCHAR2)
IS
  l_config_status        cz_config_hdrs.config_status%TYPE;
  l_node_identifier      cz_config_items.node_identifier%TYPE;
  l_config_item_id       cz_config_items.config_item_id%TYPE := NULL;
  l_column_name          VARCHAR2(80);
  l_dummy                NUMBER;

  null_db_value_exc      EXCEPTION;
  no_bom_item_found_exc  EXCEPTION;

BEGIN
  SELECT component_id, config_status, config_date_created, effective_date, usg.name
    INTO x_component_id, l_config_status, x_config_date_created, x_effective_date, x_usage_name
  FROM  cz_config_hdrs hdr, cz_model_usages usg
  WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND deleted_flag = '0'
    AND hdr.effective_usage_id = usg.model_usage_id;

  IF (x_component_id IS NULL) THEN
    l_column_name := 'component_id';
    RAISE null_db_value_exc;
  END IF;

  IF (l_config_status IS NULL) THEN
    l_column_name := 'config_status';
    RAISE null_db_value_exc;
  ELSIF (l_config_status = CONFIG_STATUS_COMPLETE) THEN
    x_complete_flag := FND_API.G_TRUE;
  ELSE
    x_complete_flag := FND_API.G_FALSE;
  END IF;

  IF (x_config_date_created IS NULL) THEN
    l_column_name := 'config_date_created';
    RAISE null_db_value_exc;
  END IF;

  IF (x_effective_date IS NULL) THEN
    l_column_name := 'effective_date';
    RAISE null_db_value_exc;
  END IF;

  BEGIN
    SELECT 1 INTO l_dummy
    FROM cz_config_messages
    WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
      AND deleted_flag = '0' AND ROWNUM < 2;

    x_valid_flag := FND_API.G_FALSE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_valid_flag := FND_API.G_TRUE;
  END;

  BEGIN
    SELECT node_identifier INTO l_node_identifier
    FROM cz_config_items
    WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
      AND deleted_flag = '0'
      AND node_identifier IS NOT NULL AND node_identifier <> 'PRD'
      AND ROWNUM < 2;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE no_bom_item_found_exc;
  END;

  l_dummy := instr(l_node_identifier, '-');
  IF (l_dummy > 0) THEN
    x_top_item_id := to_number(substr(l_node_identifier, 1, l_dummy-1));
  ELSE
    x_top_item_id := to_number(l_node_identifier);
  END IF;

  SELECT organization_id, quantity, config_item_id
  INTO x_organization_id, x_quantity, l_config_item_id
  FROM cz_config_details_v
  WHERE config_hdr_id = p_config_hdr_id AND config_rev_nbr = p_config_rev_nbr
    AND inventory_item_id = x_top_item_id;

  IF (x_organization_id IS NULL) THEN
    l_column_name := 'organization_id';
    RAISE null_db_value_exc;
  END IF;

  IF (x_quantity IS NULL) THEN
    l_column_name := 'item_val';
    RAISE null_db_value_exc;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN no_data_found THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'No such config header found in database with header id ' || to_char(p_config_hdr_id)
                  || ', revision ' || to_char(p_config_rev_nbr);

  WHEN null_db_value_exc THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'Data Error: ' || l_column_name || ' is NULL for record - config_hdr_id ' ||
                  to_char(p_config_hdr_id) || ', config_rev_nbr ' || to_char(p_config_rev_nbr);
    IF (l_config_item_id IS NOT NULL) THEN
      x_msg_data := x_msg_data || ', config_item_id ' || to_char(l_config_item_id);
    END IF;

  WHEN no_bom_item_found_exc THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'No config item found having an inventory_item_id for the input config' ||
                  ': config_hdr_id ' || to_char(p_config_hdr_id) ||
                  ', config_rev_nbr ' || to_char(p_config_rev_nbr);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;

END get_config_info;

----------------------------------
----This procedure is called when a configurator runtime UI is
----launched from embedded JRAD Region
----The API returns NULL if the ui_style on the publication
----is not a JRAD style UI otherwise it returns a publictaion_id.
FUNCTION embedded_publication_for_item (inventory_item_id     IN   NUMBER,
                               organization_id        IN   NUMBER,
                               config_lookup_date     IN   DATE,
                               calling_application_id IN  NUMBER,
                               usage_name             IN  VARCHAR2,
                               publication_mode       IN  VARCHAR2 DEFAULT NULL,
                               language               IN  VARCHAR2 DEFAULT NULL
                   		 )
RETURN NUMBER
IS

l_publication_id cz_model_publications.publication_id%TYPE;
l_ui_style       cz_model_publications.ui_style%TYPE;

BEGIN
  l_publication_id := cz_cf_api.publication_for_item  (inventory_item_id,organization_id,config_lookup_date,
                        			calling_application_id,usage_name,publication_mode,language);

  IF (l_publication_id IS NOT NULL) THEN
     BEGIN
     	    Select ui_style INTO l_ui_style
	    from   cz_model_publications
	    where  cz_model_publications.publication_id = l_publication_id
	     and   cz_model_publications.deleted_flag = '0';
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
	     l_ui_style := -1;
     END;
     IF (l_ui_style <> JRAD_STYLE_UI) THEN
	   RETURN NULL;
     END IF;
 END IF;
 RETURN l_publication_id;
END embedded_publication_for_item ;

-------------------------------------
----This procedure is called when a configurator runtime UI is
----launched from embedded JRAD Region
----The API returns NULL if the ui_style on the publication
----is not a JRAD style UI otherwise it returns a publictaion_id.

FUNCTION embedded_pubId_for_product(product_key           IN VARCHAR2,
                          config_lookup_date        IN DATE,
                          calling_application_id      IN NUMBER,
                          usage_name            IN VARCHAR2,
                          publication_mode        IN VARCHAR2 DEFAULT NULL,
                          language            IN VARCHAR2 DEFAULT NULL
                         )
RETURN NUMBER
IS

l_publication_id cz_model_publications.publication_id%TYPE;
l_ui_style       cz_model_publications.ui_style%TYPE;

BEGIN
   l_publication_id := cz_cf_api.publication_for_product(product_key,
                          			  config_lookup_date,
                        			  calling_application_id,
                              		  usage_name,
                        			  publication_mode,
                        			  language);
  IF (l_publication_id IS NOT NULL) THEN
     BEGIN
     	    Select ui_style INTO l_ui_style
	    from   cz_model_publications
	    where  cz_model_publications.publication_id = l_publication_id
	     and   cz_model_publications.deleted_flag = '0';
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
	     l_ui_style := -1;
     END;
     IF (l_ui_style <> JRAD_STYLE_UI) THEN
	   RETURN NULL;
     END IF;
 END IF;
 RETURN l_publication_id;
END embedded_pubId_for_product;

---------------------------------------
----This procedure is called when a configurator runtime UI is
----launched from embedded JRAD Region
----The API returns NULL if the ui_style on the publication
----is not a JRAD style UI otherwise it returns a publictaion_id.

FUNCTION embedded_pub_for_savedconfig (config_hdr_id  IN	NUMBER,
		               	 	   config_rev_nbr IN	NUMBER,
		      		 	   config_lookup_date		IN	DATE,
		      		 	   calling_application_id  	IN	NUMBER,
		     		 	 	   usage_name			IN	VARCHAR2,
 		      		 	   publication_mode		IN	VARCHAR2 DEFAULT NULL,
		      		 	   language			IN	VARCHAR2 DEFAULT NULL
		      			)
RETURN NUMBER
IS

l_publication_id cz_model_publications.publication_id%TYPE;
l_ui_style       cz_model_publications.ui_style%TYPE;

BEGIN
    l_publication_id := cz_cf_api.publication_for_saved_config (config_hdr_id,
                                       config_rev_nbr,
                                       config_lookup_date,
                                       calling_application_id,
                                       usage_name,
                                       publication_mode,
                                       language
                                       );
  IF (l_publication_id IS NOT NULL) THEN
     BEGIN
     	    Select ui_style INTO l_ui_style
	    from   cz_model_publications
	    where  cz_model_publications.publication_id = l_publication_id
	     and   cz_model_publications.deleted_flag = '0';
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
	     l_ui_style := -1;
     END;
     IF (l_ui_style <> JRAD_STYLE_UI) THEN
	   RETURN NULL;
     END IF;
 END IF;
 RETURN l_publication_id;

END embedded_pub_for_savedconfig ;

------------------------------------------

  FUNCTION annotated_node_path
  (p_root_model_id            IN NUMBER,
   p_target_page_expl_id      IN NUMBER,
   p_target_ui_def_id         IN NUMBER,
   p_target_page_persist_id   IN NUMBER,
   p_root_model_expl_id       IN NUMBER
   ) RETURN VARCHAR2 IS

    l_component_id      NUMBER;
    l_referring_node_id NUMBER;
    l_model_id          NUMBER;
    l_model_ref_expl_id NUMBER;
    l_root_persist_id   NUMBER;
    l_target_ps_node_id NUMBER;
    l_path              VARCHAR2(2000);

  BEGIN
    SELECT component_id,model_id INTO l_component_id, l_model_id FROM CZ_MODEL_REF_EXPLS
     WHERE model_ref_expl_id=p_target_page_expl_id;

      SELECT persistent_node_id INTO l_root_persist_id FROM CZ_PS_NODES
      WHERE devl_project_id=p_root_model_id AND parent_id IS NULL AND deleted_flag='0';

    IF p_root_model_id=l_model_id THEN
      SELECT ps_node_id INTO l_target_ps_node_id FROM CZ_PS_NODES WHERE devl_project_id=l_model_id AND
      persistent_node_id=p_target_page_persist_id AND deleted_flag='0';
      SELECT model_ref_expl_id INTO l_model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
        WHERE model_id=l_model_id AND parent_expl_node_id IS NULL AND deleted_flag='0';

      l_path := cz_developer_utils_pvt.annotated_node_path (p_root_model_id,
                                                            p_target_page_expl_id,
                                                            l_target_ps_node_id);
      IF l_path IS NULL THEN
         RETURN To_char(l_root_persist_id);
       ELSE
         RETURN To_char(l_root_persist_id)||'.'||l_path;
      END IF;

    ELSE

      FOR l IN(SELECT component_id,referring_node_id FROM CZ_MODEL_REF_EXPLS
                WHERE ps_node_type=263
                START WITH model_ref_expl_id=p_root_model_expl_id
               CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag='0'
                                AND PRIOR deleted_flag='0')
      LOOP
        BEGIN
          SELECT l.referring_node_id INTO l_referring_node_id FROM CZ_MODEL_REF_EXPLS
           WHERE model_id=l.component_id AND model_ref_expl_id=p_target_page_expl_id;
          EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
        END;
      END LOOP;

      FOR i IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                WHERE referring_node_id=l_referring_node_id AND deleted_flag='0'
                START WITH model_id=p_root_model_id AND parent_expl_node_id IS NULL AND deleted_flag='0'
                CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0'
                                 AND PRIOR deleted_flag='0')
      LOOP
        FOR j IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                   WHERE component_id=l_component_id AND deleted_flag='0'
                   START WITH model_ref_expl_id=i.model_ref_expl_id
                   CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0'
                                    AND PRIOR deleted_flag='0')
        LOOP

          SELECT ps_node_id INTO l_target_ps_node_id FROM CZ_PS_NODES
         WHERE devl_project_id=(SELECT devl_project_id FROM CZ_UI_DEFS WHERE ui_def_id=p_target_ui_def_id) AND
          persistent_node_id=p_target_page_persist_id AND deleted_flag='0';

          RETURN TO_CHAR(l_root_persist_id)||'.'||cz_developer_utils_pvt.annotated_node_path (
	   			p_root_model_id,
				j.model_ref_expl_id,
				l_target_ps_node_id);
        END LOOP;
      END LOOP;

    END IF;
    RETURN NULL;
  END annotated_node_path;

  FUNCTION get_TARGET_PAGE_REF_DEPTH
  (p_root_model_id       IN NUMBER,
   p_target_page_expl_id IN NUMBER,
   p_target_ui_def_id    IN NUMBER,
   p_root_model_expl_id  IN NUMBER) RETURN NUMBER IS

    l_component_id      NUMBER;
    l_referring_node_id NUMBER;
    l_model_id          NUMBER;

  BEGIN

     SELECT component_id,model_id INTO l_component_id,l_model_id FROM CZ_MODEL_REF_EXPLS
     WHERE model_ref_expl_id=p_target_page_expl_id;

     IF p_root_model_id=l_model_id THEN
       RETURN 0;
     END IF;

      FOR l IN(SELECT component_id,referring_node_id FROM CZ_MODEL_REF_EXPLS
                WHERE ps_node_type=263
                START WITH model_ref_expl_id=p_root_model_expl_id
               CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag='0'
                                AND PRIOR deleted_flag='0')
      LOOP
        BEGIN
          SELECT l.referring_node_id INTO l_referring_node_id FROM CZ_MODEL_REF_EXPLS
           WHERE model_id=l.component_id AND model_ref_expl_id=p_target_page_expl_id;
          EXIT;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;
        END;
      END LOOP;

      FOR i IN(SELECT model_ref_expl_id,node_depth FROM CZ_MODEL_REF_EXPLS
                WHERE referring_node_id=l_referring_node_id AND deleted_flag='0'
                START WITH model_id=p_root_model_id AND parent_expl_node_id IS NULL AND deleted_flag='0'
                CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0'
                                 AND PRIOR deleted_flag='0')
      LOOP
        FOR j IN (SELECT node_depth FROM CZ_MODEL_REF_EXPLS
                   WHERE component_id=l_component_id AND deleted_flag='0'
                   START WITH model_ref_expl_id=i.model_ref_expl_id
                   CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0'
                                    AND PRIOR deleted_flag='0')
        LOOP
          RETURN i.node_depth;
        END LOOP;
      END LOOP;
     RETURN 0;
  END get_TARGET_PAGE_REF_DEPTH;


  PROCEDURE get_Target_UI_Pages(p_root_ui_def_id         IN NUMBER,
                                p_root_model_expl_id     IN NUMBER,
                                p_root_model_node_id     IN NUMBER,
                                p_node_collection_flag   IN VARCHAR2,
                                p_curr_ui_def_id         IN NUMBER,
                                p_curr_page_id           IN NUMBER,
                                p_order_by_template      IN NUMBER,
                                x_ui_page_tbl            OUT NOCOPY SYSTEM.cz_tgt_ui_page_tbl) IS

    TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_ui_pages_tbl0 SYSTEM.CZ_UI_PAGE_ELEM_TBL := SYSTEM.CZ_UI_PAGE_ELEM_TBL(SYSTEM.CZ_UI_PAGE_ELEM_REC(NULL,NULL,NULL));
    l_ui_pages_tbl1 SYSTEM.CZ_UI_PAGE_ELEM_TBL := SYSTEM.CZ_UI_PAGE_ELEM_TBL(SYSTEM.CZ_UI_PAGE_ELEM_REC(NULL,NULL,NULL));

    l_hash_map      number_tbl_type;
    l_root_model_id NUMBER;
    l_tbl_counter   NUMBER;

  BEGIN

    x_ui_page_tbl :=  SYSTEM.cz_tgt_ui_page_tbl(SYSTEM.CZ_TGT_UI_PAGE_REC(NULL,NULL,NULL,NULL,NULL,NULL));
    l_tbl_counter := 1;

    SELECT devl_project_id INTO l_root_model_id
      FROM CZ_UI_DEFS WHERE ui_def_id=p_root_ui_def_id;


    FOR k IN(SELECT vv.target_page_id, vv.target_ui_def_id,vv.element_id,vv.bound_via_parent_flag from cz_uipages_for_explnodes_v vv
              WHERE vv.root_ui_def_id = p_root_ui_def_id AND
             	  vv.root_model_expl_id = p_root_model_expl_id AND
             	  vv.root_model_node_id = p_root_model_node_id AND
                    vv.node_collection_flag=p_node_collection_flag)
    LOOP
      IF k.bound_via_parent_flag='0' THEN
        l_ui_pages_tbl0.extend;
        l_ui_pages_tbl0(l_ui_pages_tbl0.LAST) := SYSTEM.CZ_UI_PAGE_ELEM_REC(k.target_ui_def_id,k.target_page_id,k.element_id);
      ELSE
        l_ui_pages_tbl1.extend;
        l_ui_pages_tbl1(l_ui_pages_tbl1.LAST) := SYSTEM.CZ_UI_PAGE_ELEM_REC(k.target_ui_def_id,k.target_page_id,k.element_id);
      END IF;
    END LOOP;

    IF p_order_by_template=0 THEN

    -- Bug 5129001 - Performance team suggested CARDINALITY hints below for fixing 10G optimizer problem.
    FOR i IN(SELECT * FROM (
             SELECT
             uipages.ui_def_id                      AS TARGET_UI_DEF_ID,
             uipages.page_id                        AS TARGET_PAGE_ID,
             (SELECT annotated_node_path(l_root_model_id,
                     UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,UIPAGES.persistent_node_id,p_root_model_expl_id)
                FROM dual
             	)                                 AS TARGET_PAGE_ANN_PATH,
              uipages.DISPLAY_CONDITION_ID          AS TARGET_PAGE_DISPCOND_ID,
              uipages.DISPLAY_CONDITION_COMP        AS TARGET_PAGE_DISPCOND_COMP,
              uipages.DISPLAY_CONDITION_VALUE       AS TARGET_PAGE_DISPCOND_VALUE,
              uiels.PAGE_LEVEL                      AS PAGE_INCLUSION_DEPTH,
              uiels.element_id,
              uiels.ui_def_id,
              uiels.page_id,
              (SELECT get_TARGET_PAGE_REF_DEPTH(l_root_model_id,
                      UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,p_root_model_expl_id)
             	   FROM dual
             	)                             AS TARGET_PAGE_REFERENCE_DEPTH,
               '0'                               AS BOUND_VIA_PARENT_FLAG
             FROM
             CZ_UI_PAGES uipages,
             (SELECT els.ui_def_id,els.page_id,els.element_id,level as PAGE_LEVEL FROM CZ_UI_PAGE_ELEMENTS els
              START WITH  (els.page_id,els.ui_def_id,els.element_id) IN
              (SELECT /*+ CARDINALITY (UITPAGES 1) */ uitpages.page_id,uitpages.ui_def_id,uitpages.element_id FROM TABLE(CAST(l_ui_pages_tbl0 AS SYSTEM.CZ_UI_PAGE_ELEM_TBL)) UITPAGES)
                        CONNECT BY els.element_signature_id=6073 AND
                         els.target_page_ui_def_id= PRIOR els.ui_def_id AND
                                els.target_page_id= PRIOR els.page_id AND deleted_flag='0' AND PRIOR deleted_flag='0') uiels
             WHERE uipages.page_id=uiels.page_id AND uipages.ui_def_id=uiels.ui_def_id
             UNION
             select
             uipages.ui_def_id                      AS TARGET_UI_DEF_ID,
             uipages.page_id                        AS TARGET_PAGE_ID,
             (SELECT annotated_node_path(l_root_model_id,
                     UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,UIPAGES.persistent_node_id,p_root_model_expl_id)
                FROM dual
             	)                             AS TARGET_PAGE_ANN_PATH,
              uipages.DISPLAY_CONDITION_ID          AS TARGET_PAGE_DISPCOND_ID,
              uipages.DISPLAY_CONDITION_COMP        AS TARGET_PAGE_DISPCOND_COMP,
              uipages.DISPLAY_CONDITION_VALUE       AS TARGET_PAGE_DISPCOND_VALUE,
              uiels.PAGE_LEVEL                      AS PAGE_INCLUSION_DEPTH,
              uiels.element_id,
              uiels.ui_def_id,
              uiels.page_id,
              (SELECT get_TARGET_PAGE_REF_DEPTH(l_root_model_id,
                      UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,p_root_model_expl_id)
             	   FROM dual
             	)                             AS TARGET_PAGE_REFERENCE_DEPTH,
              '1'                                AS BOUND_VIA_PARENT_FLAG
             FROM
             CZ_UI_PAGES uipages,
             (SELECT els.ui_def_id,els.page_id,els.element_id,level as PAGE_LEVEL FROM CZ_UI_PAGE_ELEMENTS els
              START WITH  (els.page_id,els.ui_def_id,els.element_id) IN
              (SELECT /*+ CARDINALITY(UITPAGES1 1) */ uitpages1.page_id,uitpages1.ui_def_id,uitpages1.element_id FROM TABLE(CAST(l_ui_pages_tbl1 AS SYSTEM.CZ_UI_PAGE_ELEM_TBL)) UITPAGES1)
                        CONNECT BY els.element_signature_id=6073 AND
                         els.target_page_ui_def_id= PRIOR els.ui_def_id AND
                                els.target_page_id= PRIOR els.page_id AND deleted_flag='0' AND PRIOR deleted_flag='0') uiels
             WHERE uipages.page_id=uiels.page_id AND uipages.ui_def_id=uiels.ui_def_id
        )
      WHERE TARGET_UI_DEF_ID IN
           (SELECT p_root_ui_def_id FROM dual
             UNION
            SELECT ref_ui_def_id FROM cz_ui_refs
            START WITH ui_def_id=p_root_ui_def_id AND deleted_flag='0'
            CONNECT BY PRIOR ref_ui_def_id=ui_def_id AND deleted_flag='0') AND
           TARGET_PAGE_ANN_PATH IS NOT NULL
      ORDER BY
        BOUND_VIA_PARENT_FLAG asc,
        DECODE(TARGET_PAGE_ID,p_curr_page_id,DECODE(TARGET_UI_DEF_ID,p_curr_ui_def_id,0,1),1) asc,
        DECODE(PAGE_INCLUSION_DEPTH,1,DECODE(TARGET_UI_DEF_ID,p_curr_ui_def_id,G_MAX_PAGE_INCLUSION_DEPTH,1),PAGE_INCLUSION_DEPTH) desc,
        TARGET_PAGE_REFERENCE_DEPTH desc
    )
  LOOP
    IF NOT(l_hash_map.EXISTS(i.TARGET_PAGE_ID)) THEN
      x_ui_page_tbl(l_tbl_counter).UI_DEF_ID              := i.TARGET_UI_DEF_ID;
      x_ui_page_tbl(l_tbl_counter).PAGE_ID                := i.TARGET_PAGE_ID;
      x_ui_page_tbl(l_tbl_counter).ANNOTATED_NODE_PATH    := i.TARGET_PAGE_ANN_PATH;
      x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_ID        := i.TARGET_PAGE_DISPCOND_ID;
      x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_COMP      := i.TARGET_PAGE_DISPCOND_COMP;
      x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_VALUE     := i.TARGET_PAGE_DISPCOND_VALUE;
      l_hash_map(i.TARGET_PAGE_ID) := i.TARGET_PAGE_ID;
      x_ui_page_tbl.EXTEND(1,1);
      l_tbl_counter := l_tbl_counter + 1;
    END IF;
  END LOOP;

  ELSIF p_order_by_template=1 THEN

    FOR i IN(SELECT * FROM (
             SELECT
             uipages.ui_def_id                      AS TARGET_UI_DEF_ID,
             uipages.page_id                        AS TARGET_PAGE_ID,
             (SELECT annotated_node_path(l_root_model_id,
                     UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,UIPAGES.persistent_node_id,p_root_model_expl_id)
                FROM dual
             	)                                 AS TARGET_PAGE_ANN_PATH,
              uipages.DISPLAY_CONDITION_ID          AS TARGET_PAGE_DISPCOND_ID,
              uipages.DISPLAY_CONDITION_COMP        AS TARGET_PAGE_DISPCOND_COMP,
              uipages.DISPLAY_CONDITION_VALUE       AS TARGET_PAGE_DISPCOND_VALUE,
              uiels.PAGE_LEVEL                      AS PAGE_INCLUSION_DEPTH,
              uiels.element_id,
              uiels.ui_def_id,
              uiels.page_id,
              (SELECT get_TARGET_PAGE_REF_DEPTH(l_root_model_id,
                      UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,p_root_model_expl_id)
             	   FROM dual
             	)                             AS TARGET_PAGE_REFERENCE_DEPTH,
               '0'                               AS BOUND_VIA_PARENT_FLAG
             FROM
             CZ_UI_PAGES uipages,
             (SELECT els.ui_def_id,els.page_id,els.element_id,level as PAGE_LEVEL FROM CZ_UI_PAGE_ELEMENTS els
              START WITH  (els.page_id,els.ui_def_id,els.element_id) IN
              (SELECT uitpages.page_id,uitpages.ui_def_id,uitpages.element_id FROM TABLE(CAST(l_ui_pages_tbl0 AS SYSTEM.CZ_UI_PAGE_ELEM_TBL)) uitpages)
                        CONNECT BY els.element_signature_id=6073 AND
                         els.target_page_ui_def_id= PRIOR els.ui_def_id AND
                                els.target_page_id= PRIOR els.page_id AND deleted_flag='0' AND PRIOR deleted_flag='0') uiels
             WHERE uipages.page_id=uiels.page_id AND uipages.ui_def_id=uiels.ui_def_id
             UNION
             select
             uipages.ui_def_id                      AS TARGET_UI_DEF_ID,
             uipages.page_id                        AS TARGET_PAGE_ID,
             (SELECT annotated_node_path(l_root_model_id,
                     UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,UIPAGES.persistent_node_id,p_root_model_expl_id)
                FROM dual
             	)                             AS TARGET_PAGE_ANN_PATH,
              uipages.DISPLAY_CONDITION_ID          AS TARGET_PAGE_DISPCOND_ID,
              uipages.DISPLAY_CONDITION_COMP        AS TARGET_PAGE_DISPCOND_COMP,
              uipages.DISPLAY_CONDITION_VALUE       AS TARGET_PAGE_DISPCOND_VALUE,
              uiels.PAGE_LEVEL                      AS PAGE_INCLUSION_DEPTH,
              uiels.element_id,
              uiels.ui_def_id,
              uiels.page_id,
              (SELECT get_TARGET_PAGE_REF_DEPTH(l_root_model_id,
                      UIPAGES.PAGEBASE_EXPL_NODE_ID,UIPAGES.ui_def_id,p_root_model_expl_id)
             	   FROM dual
             	)                             AS TARGET_PAGE_REFERENCE_DEPTH,
              '1'                                AS BOUND_VIA_PARENT_FLAG
             FROM
             CZ_UI_PAGES uipages,
             (SELECT els.ui_def_id,els.page_id,els.element_id,level as PAGE_LEVEL FROM CZ_UI_PAGE_ELEMENTS els
              START WITH  (els.page_id,els.ui_def_id,els.element_id) IN
              (SELECT uitpages1.page_id,uitpages1.ui_def_id,uitpages1.element_id FROM TABLE(CAST(l_ui_pages_tbl1 AS SYSTEM.CZ_UI_PAGE_ELEM_TBL)) uitpages1)
                        CONNECT BY els.element_signature_id=6073 AND
                         els.target_page_ui_def_id= PRIOR els.ui_def_id AND
                                els.target_page_id= PRIOR els.page_id AND deleted_flag='0' AND PRIOR deleted_flag='0') uiels
             WHERE uipages.page_id=uiels.page_id AND uipages.ui_def_id=uiels.ui_def_id )
     WHERE TARGET_UI_DEF_ID IN
           (SELECT p_root_ui_def_id FROM dual
             UNION
            SELECT ref_ui_def_id FROM cz_ui_refs
            START WITH ui_def_id=p_root_ui_def_id AND deleted_flag='0'
            CONNECT BY PRIOR ref_ui_def_id=ui_def_id AND deleted_flag='0') AND
           TARGET_PAGE_ANN_PATH IS NOT NULL
     ORDER BY
       DECODE(TARGET_PAGE_ID,p_curr_page_id,DECODE(TARGET_UI_DEF_ID,p_curr_ui_def_id,0,1),1) desc,
       BOUND_VIA_PARENT_FLAG asc,
       DECODE(PAGE_INCLUSION_DEPTH,1,DECODE(TARGET_UI_DEF_ID,p_curr_ui_def_id,G_MAX_PAGE_INCLUSION_DEPTH,1),PAGE_INCLUSION_DEPTH) desc,
       TARGET_PAGE_REFERENCE_DEPTH desc
    )
    LOOP
      IF NOT(l_hash_map.EXISTS(i.TARGET_PAGE_ID)) THEN
        x_ui_page_tbl(l_tbl_counter).UI_DEF_ID              := i.TARGET_UI_DEF_ID;
        x_ui_page_tbl(l_tbl_counter).PAGE_ID                := i.TARGET_PAGE_ID;
        x_ui_page_tbl(l_tbl_counter).ANNOTATED_NODE_PATH    := i.TARGET_PAGE_ANN_PATH;
        x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_ID        := i.TARGET_PAGE_DISPCOND_ID;
        x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_COMP      := i.TARGET_PAGE_DISPCOND_COMP;
        x_ui_page_tbl(l_tbl_counter).DISPLAY_COND_VALUE     := i.TARGET_PAGE_DISPCOND_VALUE;
        l_hash_map(i.TARGET_PAGE_ID) := i.TARGET_PAGE_ID;
        x_ui_page_tbl.EXTEND(1,1);
        l_tbl_counter := l_tbl_counter + 1;
      END IF;
    END LOOP;

  END IF;
  x_ui_page_tbl.DELETE(l_tbl_counter);

END get_Target_UI_Pages;

-------------------------------------------

END cz_runtime;

/
