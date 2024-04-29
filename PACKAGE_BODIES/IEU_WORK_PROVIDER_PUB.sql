--------------------------------------------------------
--  DDL for Package Body IEU_WORK_PROVIDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WORK_PROVIDER_PUB" AS
/* $Header: ieuwpdb.pls 115.4 2004/03/31 17:12:10 dolee noship $ */

--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteActionPackage
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_action_key     IN   VARCHAR2(32)    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DeleteNode(x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY VARCHAR2,
                              r_enumId IN ieu_uwq_sel_enumerators.sel_enum_id%type)
As
v_cursor1               NUMBER;
v_cursor               NUMBER;
v_numrows1              NUMBER;
sql_stmt             varchar2(2000);
l_property_id ieu_wp_param_props_b.property_id%type;
l_delete_param_property_id IEU_WP_PARAM_PROPS_B.param_property_id%type;
l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
l_enumID  ieu_uwq_sel_enumerators.sel_enum_id%type;
l_applId  ieu_wp_action_maps.application_id%type;
l_panel   ieu_uwq_maction_defs_b.maction_def_type_flag%type;
cursor c_cursor is
select distinct a.action_param_set_id
from ieu_wp_action_maps a, ieu_uwq_sel_enumerators b
where b.sel_enum_id = r_enumId
and a.action_map_code = b.enum_type_uuid;
begin
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    x_msg_data := '';
    --DBMS_OUTPUT.Put_Line('before cursor loop');
 -- find enumId, applicationId, and panel for
-- given a sel_enum_id
-- a. delete the work node definition from the sel_enumerators table
-- b. delete the two profile options created for the node
-- c. delete any work panel data created for this node
-- d. delete any data source mapping set up for this node (used by quick filters)

-- start real work
-- d.
Execute IMMEDIATE  ' delete from ieu_wp_node_section_maps where enum_type_uuid in '||
                  ' (select enum_type_uuid from ieu_uwq_sel_enumerators  '||
                  '  where sel_enum_id = :1 ) '
USING r_enumId;

-- c.
/*
PROCEDURE Delete_Action_From_Node (
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count OUT  NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY  VARCHAR2,
  x_param_set_id IN NUMBER,
  x_node_id IN NUMBER,
  x_maction_id IN NUMBER,// if no maction_id information, provide -1
  x_maction_def_flag IN VARCHAR2
  );
END IEU_Work_ACTION_PVT;
*/

FOR cur_rec IN c_cursor
    LOOP
       IEU_WORK_ACTION_PVT.Delete_Action_From_Node(x_return_status,
                                    x_msg_count ,
                                    x_msg_data  ,
                                    cur_rec.action_param_set_id,
                                    r_enumId,
							 '-1',
							 'W');
    END loop;

 -- b.
 EXECUTE IMMEDIATE  ' delete from fnd_profile_options_tl where profile_option_name '||
                   ' in (select work_q_enable_profile_option from ieu_uwq_sel_enumerators '||
                   ' where sel_enum_id = :1 ) '
 USING r_enumId;
 EXECUTE IMMEDIATE  ' delete from fnd_profile_options_tl where profile_option_name '||
                   ' in (select work_q_order_profile_option from ieu_uwq_sel_enumerators '||
                   ' where sel_enum_id = :1 ) '
 USING r_enumId;
 EXECUTE IMMEDIATE  ' delete from fnd_profile_options where profile_option_name '||
                   ' in (select work_q_enable_profile_option from ieu_uwq_sel_enumerators '||
                   ' where sel_enum_id = :1 ) '
 USING r_enumId;
 EXECUTE IMMEDIATE  ' delete from fnd_profile_options where profile_option_name '||
                   ' in (select work_q_order_profile_option from ieu_uwq_sel_enumerators '||
                   ' where sel_enum_id = :1 ) '
 USING r_enumId;

 -- a.
EXECUTE IMMEDIATE 'delete from fnd_lookup_values where (lookup_type, lookup_code) in  '||
                  ' (select work_q_label_lu_type, work_q_label_lu_code   ' ||
                  ' from ieu_uwq_sel_enumerators where sel_enum_id = :1 )'
USING r_enumId;
EXECUTE IMMEDIATE  ' delete from ieu_uwq_sel_enumerators '||
                   ' where sel_enum_id = :1  '
 USING r_enumId;

  EXCEPTION
       WHEN fnd_api.g_exc_error THEN
           ROLLBACK;
           x_return_status := fnd_api.g_ret_sts_error;

        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            ROLLBACK;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

commit;
end DeleteNode;
END IEU_WORK_PROVIDER_PUB;

/
