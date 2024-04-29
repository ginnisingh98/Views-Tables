--------------------------------------------------------
--  DDL for Package Body FLM_COPY_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_COPY_ROUTING" AS
/* $Header: FLMCPYRB.pls 120.1.12010000.2 2009/08/10 06:43:11 adasa ship $  */

G_LOG_ON	boolean	:= ('Y' = FND_PROFILE.VALUE('MRP_DEBUG'));


TYPE two_id_rec IS RECORD (old_id number,new_id number);

TYPE two_id_list is TABLE OF two_id_rec INDEX BY BINARY_INTEGER;

Function get_org_code(p_org_id number) Return Varchar2 Is
l_org_code	varchar2(3) := NULL;
Begin

  select organization_code into l_org_code
  from mtl_parameters
  where organization_id = p_org_id;
  return l_org_code;
Exception
  when others then
    return l_org_code;

End get_org_code;

Function get_line_code(p_org_id number,p_line_id number) Return Varchar2 Is
l_line_code	varchar2(10) := NULL;
Begin

  select line_code into l_line_code
  from wip_lines
  where organization_id = p_org_id
	and line_id = p_line_id;
  return l_line_code;
Exception
  when others then
    return l_line_code;

End get_line_code;

Function std_op_exists(		p_org_id number,
				p_line_id number,
				p_std_op_code varchar2,
				p_op_type number) Return Boolean Is
l_total number := 0;
Begin
  select count(*) into l_total
  from bom_standard_operations
  where organization_id = p_org_id
  and line_id = p_line_id
  and operation_code = p_std_op_code
  and operation_type = p_op_type;

  if l_total > 0 then
    return TRUE;
  end if;

  Return FALSE;

Exception
  when OTHERS then
    return FALSE;

End std_op_exists;

Function bill_exists(		p_item_id number,
				p_org_id number,
				p_alternate varchar2) Return Boolean Is
l_total number := 0;
Begin
  select count(*) into l_total
  from bom_bill_of_materials
  where assembly_item_id = p_item_id
  and organization_id = p_org_id
  and nvl(alternate_bom_designator,'NONE') = nvl(p_alternate,'NONE');

  if l_total > 0 then
    return TRUE;
  end if;

  Return FALSE;

Exception
  when OTHERS then
    return FALSE;

End bill_exists;

Procedure copy_attach(obj_from varchar2,obj_to varchar2,id_list two_id_list) Is
i number;
last number;
Begin
  if (id_list.COUNT > 0) then
    i := id_list.FIRST;
    last := id_list.LAST;
    LOOP
    fnd_attached_documents2_pkg.copy_attachments(
                        X_from_entity_name      =>  obj_from,
                        X_from_pk1_value        =>  id_list(i).old_id,
                        X_from_pk2_value        =>  '',
                        X_from_pk3_value        =>  '',
                        X_from_pk4_value        =>  '',
                        X_from_pk5_value        =>  '',
                        X_to_entity_name        =>  obj_to,
                        X_to_pk1_value          =>  id_list(i).new_id,
                        X_to_pk2_value          =>  '',
                        X_to_pk3_value          =>  '',
                        X_to_pk4_value          =>  '',
                        X_to_pk5_value          =>  '',
                        X_created_by            =>  fnd_global.user_id,
                        X_last_update_login     =>  '',
                        X_program_application_id=>  '',
                        X_program_id            =>  '',
                        X_request_id            =>  ''
                    );

      exit when i = last;
      i := id_list.NEXT(i);
    END LOOP;
  end if;
End;


Procedure copy_routings(
	 errbuf		OUT	NOCOPY	varchar2
	,retcode	OUT 	NOCOPY	number
	,p_mode			number
	,p_organization_id	number
	,p_line_id_to		number
	,p_alternate_code_to	varchar2
	,p_copy_bom		varchar2
	,p_line_id_from		number
	,p_alternate_code_from	varchar2
	,p_product_family_id	number
	,p_assembly_name_from	varchar2
	,p_assembly_name_to	varchar2
	,p_tpct_from		number
	,p_tpct_to		number
	,p_lineop_code		varchar2
	,p_process_code		varchar2
	) IS


  i number;
  j number;
  ii number;
  jj number;
  in_list boolean;
  lineop_in_list boolean;
  process_in_list boolean;
  dup number;
  last number;
  success number;
  new_row_id varchar2(18);
  new_std_op_id number;
  l_rtg_total number;

  -- routing header key
  l_org_code varchar2(3) := get_org_code(p_organization_id);
  l_line_code varchar2(10) := get_line_code(p_organization_id,p_line_id_to);

  --Added for bugfix:8416058
  l_line_code_from varchar2(10) := get_line_code(p_organization_id,p_line_id_from);
  l_dept_diff number :=0;
  l_diff_count number;

  l_assembly_item_name varchar2(81);
  l_today date := sysdate;

  l_rtg_header_rec	Bom_Rtg_Pub.Rtg_Header_Rec_Type;
  l_rtg_revision_tbl	Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
  l_operation_tbl	Bom_Rtg_Pub.Operation_Tbl_Type;
  l_op_resource_tbl	Bom_Rtg_Pub.Op_Resource_Tbl_Type;
  l_sub_resource_tbl	Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
  l_op_network_tbl	Bom_Rtg_Pub.Op_Network_Tbl_Type;

  o_rtg_header_rec	Bom_Rtg_Pub.Rtg_Header_Rec_Type;
  o_rtg_revision_tbl	Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
  o_operation_tbl	Bom_Rtg_Pub.Operation_Tbl_Type;
  o_op_resource_tbl	Bom_Rtg_Pub.Op_Resource_Tbl_Type;
  o_sub_resource_tbl	Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
  o_op_network_tbl	Bom_Rtg_Pub.Op_Network_Tbl_Type;

  t_rtg_revision_tbl	Bom_Rtg_Pub.Rtg_Revision_Tbl_Type;
  t_operation_tbl	Bom_Rtg_Pub.Operation_Tbl_Type;
  t_op_resource_tbl	Bom_Rtg_Pub.Op_Resource_Tbl_Type;
  t_sub_resource_tbl	Bom_Rtg_Pub.Sub_Resource_Tbl_Type;
  t_op_network_tbl	Bom_Rtg_Pub.Op_Network_Tbl_Type;

  a_operation_tbl	Bom_Rtg_Pub.Operation_Tbl_Type;

  o_return_status	Varchar2(8);
  o_msg_count		Number;
  l_msg varchar2(1000);
  l_index number;
  l_id varchar2(30);
  l_type varchar2(10);

  l_std_op_exist boolean;

  l_new_rtg_seq_id number;
  l_old_op_seq_id number;
  l_new_op_seq_id number;

  l_2_ids two_id_list;
  l_2_seq_ids two_id_list;
  t_2_ids two_id_list;

  l_from_sequence_id	number;
  l_to_sequence_id	number;
  l_to_common_seq_id	number;

  -- CURSORS
  Cursor c_routings IS
/*
  Select
	bor.routing_sequence_id,
	bor.common_routing_sequence_id,
	bor.assembly_item_id,
	bor.common_assembly_item_id,
	bor.alternate_routing_designator
  From
	bom_operational_routings bor, mtl_system_items_kfv msi_kfv
  Where
	bor.organization_id = p_organization_id
	and bor.organization_id = msi_kfv.organization_id
	and bor.assembly_item_id = msi_kfv.inventory_item_id
	and bor.line_id = p_line_id_from
	and bor.cfm_routing_flag = 1
	and bor.routing_type = 1
	and ((p_mode = 1 and msi_kfv.bom_item_type <> 5) or (p_mode = 2 and msi_kfv.bom_item_type = 5))
	and ((p_alternate_code_from is NULL and bor.alternate_routing_designator is NULL)
	   or p_alternate_code_from = bor.alternate_routing_designator)
	and (p_product_family_id is NULL or p_product_family_id = msi_kfv.product_family_item_id)
	and (p_assembly_name_from is NULL or p_assembly_name_from <= msi_kfv.concatenated_segments)
	and (p_assembly_name_to is NULL or p_assembly_name_to >= msi_kfv.concatenated_segments)
	and (p_tpct_from is NULL or bor.total_product_cycle_time >= p_tpct_from)
	and (p_tpct_to is NULL or bor.total_product_cycle_time <= p_tpct_to)
	and (p_lineop_code is NULL or exists (
		select 1 from bom_operation_sequences_v bosv
		where bosv.routing_sequence_id = bor.common_routing_sequence_id
		  and p_lineop_code = bosv.standard_operation_code
		  and bosv.operation_type = 3)
	     )
	and (p_process_code is NULL or exists (
		select 1 from bom_operation_sequences_v bosv
		where bosv.routing_sequence_id = bor.common_routing_sequence_id
		  and p_process_code = bosv.standard_operation_code
 		  and bosv.operation_type = 2)
	     )
  Order by
	bor.routing_sequence_id
	;
*/
Select
	bor.routing_sequence_id,
	bor.common_routing_sequence_id,
	bor.assembly_item_id,
	bor.common_assembly_item_id,
	bor.alternate_routing_designator
  From
	bom_operational_routings bor, mtl_system_items_kfv msi_kfv
  Where
	bor.organization_id = p_organization_id
	and bor.organization_id = msi_kfv.organization_id
	and bor.assembly_item_id = msi_kfv.inventory_item_id
	and bor.line_id = p_line_id_from
	and bor.cfm_routing_flag = 1
	and bor.routing_type = 1
	and ((p_mode = 1 and msi_kfv.bom_item_type <> 5) or (p_mode = 2 and msi_kfv.bom_item_type = 5))
	and ((p_alternate_code_from is NULL and bor.alternate_routing_designator is NULL)
	   or p_alternate_code_from = bor.alternate_routing_designator)
	and (p_product_family_id is NULL or p_product_family_id = msi_kfv.product_family_item_id)
	and (p_assembly_name_from is NULL or p_assembly_name_from <= msi_kfv.concatenated_segments)
	and (p_assembly_name_to is NULL or p_assembly_name_to >= msi_kfv.concatenated_segments)
	and (p_tpct_from is NULL or bor.total_product_cycle_time >= p_tpct_from)
	and (p_tpct_to is NULL or bor.total_product_cycle_time <= p_tpct_to)
	and (p_lineop_code is NULL or exists (
          select 1
            from bom_operation_sequences bos1, bom_standard_operations bso1
           where bos1.routing_sequence_id = bor.common_routing_sequence_id
             and p_lineop_code = bso1.operation_code
             and bos1.standard_operation_id = bso1.standard_operation_id
             and bso1.organization_id = p_organization_id
             and bso1.line_id = p_line_id_from
             and bos1.operation_type = 3)
	     )
	and (p_process_code is NULL or exists (
          select 1
            from bom_operation_sequences bos1, bom_standard_operations bso1
           where bos1.routing_sequence_id = bor.common_routing_sequence_id
             and p_process_code = bso1.operation_code
             and bos1.standard_operation_id = bso1.standard_operation_id
             and bso1.organization_id = p_organization_id
             and bso1.line_id = p_line_id_from
             and bos1.operation_type = 2)
             )
  Order by
	bor.routing_sequence_id
  ;

  Cursor c_bill_sequence(p_item_id number,p_org_id number,p_alternate varchar2) IS
  Select
	*
  From
	bom_bill_of_materials
  Where
	organization_id = p_org_id
	and assembly_item_id = p_item_id
	and (nvl(alternate_bom_designator,'NONE') = nvl(p_alternate,'NONE'))
	;

  Cursor c_routing_header(p_routing_sequence_id number) Is
  Select
	 flm_util.get_key_flex_item(assembly_item_id,p_organization_id) Assembly_Item_Name
	,l_org_code Organization_Code
	,p_alternate_code_to Alternate_Routing_Code
	,2 Eng_Routing_Flag --eng_routing_flag is oAlternate_Routing_Codepposite of routing_type
	,flm_util.get_key_flex_item(common_assembly_item_id,p_organization_id) Common_Assembly_Item_Name
	,routing_comment Routing_Comment
	,completion_subinventory Completion_Subinventory
	,flm_util.get_key_flex_location(completion_locator_id,p_organization_id) Completion_Location_Name
	,l_line_code Line_Code
	,cfm_routing_flag CFM_Routing_Flag
	,2 Mixed_Model_Map_Flag -- mixed_model_map_flag has only one 'Y'=1 for an item
	,priority Priority
	,total_product_cycle_time Total_Cycle_Time
	,2 CTP_Flag --ctp_flag: only one YES=1 for an item
	,attribute_category Attribute_category
	,attribute1 Attribute1
	,attribute2 Attribute2
	,attribute3 Attribute3
	,attribute4 Attribute4
	,attribute5 Attribute5
	,attribute6 Attribute6
	,attribute7 Attribute7
	,attribute8 Attribute8
	,attribute9 Attribute9
	,attribute10 Attribute10
	,attribute11 Attribute11
	,attribute12 Attribute12
	,attribute13 Attribute13
	,attribute14 Attribute14
	,attribute15 Attribute15
	,original_system_reference Original_System_Reference
	,'CREATE' Transaction_Type
	,NULL Return_Status
	,NULL Delete_Group_Name
        ,NULL DG_Description
  From
	bom_operational_routings_v
  Where
	routing_sequence_id = p_routing_sequence_id
	;
  l_routing_header_rec c_routing_header%ROWTYPE;


  Cursor c_routing_revision(p_assembly_item_id number) Is
  Select
	 l_assembly_item_name
	,l_org_code -- organization_code
	,p_alternate_code_to
	,process_revision revision
	,effectivity_date start_effective_date
	,attribute_category
	,attribute1
	,attribute2
	,attribute3
	,attribute4
	,attribute5
	,attribute6
	,attribute7
	,attribute8
	,attribute9
	,attribute10
	,attribute11
	,attribute12
	,attribute13
	,attribute14
	,attribute15
	,NULL
	,'CREATE' -- transaction_type
	,NULL -- return status
  From
	mtl_rtg_item_revisions mrir
  Where
	inventory_item_id = p_assembly_item_id
	and organization_id = p_organization_id
	;


  Cursor c_operations(p_routing_sequence_id number) Is
  Select
	 l_assembly_item_name Assembly_Item_Name
	,l_org_code Organization_Code
	,p_alternate_code_to Alternate_Routing_Code
	,bosv.operation_seq_num Operation_Sequence_Number
	,bosv.operation_type Operation_Type
	,bosv.effectivity_date Start_Effective_Date
	,bosv.operation_seq_num New_Operation_Sequence_Number
	,bosv.effectivity_date New_Start_Effective_Date
	,bosv.standard_operation_code Standard_Operation_Code
	,bosv.department_code Department_Code
	,bosv.operation_lead_time_percent Op_Lead_Time_Percent
	,bosv.minimum_transfer_quantity Minimum_Transfer_Quantity
	,bosv.count_point_type Count_Point_Type
	,bosv.operation_description  Operation_Description
	,bosv.disable_date Disable_Date
	,bosv.backflush_flag Backflush_Flag
	,NULL Option_Dependent_Flag
	,1 Reference_Flag -- copied always referenced
	,bosv.process_seq_num Process_Seq_Number
	,bosv.process_code Process_Code
	,bosv.line_op_seq_num Line_Op_Seq_Number
	,bosv.line_op_code Line_Op_Code
	,bosv.yield Yield
	,bosv.cumulative_yield Cumulative_Yield
	,bosv.reverse_cumulative_yield Reverse_CUM_Yield
	,bosv.labor_time_user User_Labor_Time
	,bosv.machine_time_user User_Machine_Time
	,100 Net_Planning_Percent --??????
	,bosv.include_in_rollup Include_In_Rollup
	,bosv.operation_yield_enabled Op_Yield_Enabled_Flag
	,bosv.shutdown_type Shutdown_Type
	,bosv.attribute_category Attribute_category
	,bosv.attribute1 Attribute1
	,bosv.attribute2 Attribute2
	,bosv.attribute3 Attribute3
	,bosv.attribute4 Attribute4
	,bosv.attribute5 Attribute5
	,bosv.attribute6 Attribute6
	,bosv.attribute7 Attribute7
	,bosv.attribute8 Attribute8
	,bosv.attribute9 Attribute9
	,bosv.attribute10 Attribute10
	,bosv.attribute11 Attribute11
	,bosv.attribute12 Attribute12
	,bosv.attribute13 Attribute13
	,bosv.attribute14 Attribute14
	,bosv.attribute15 Attribute15
	,bosv.original_system_reference Original_System_Reference
	,'CREATE' Transaction_Type
	,NULL Return_Status
	,NULL Delete_Group_Name
        ,NULL DG_Description
  From
	bom_operation_sequences_v bosv
  Where
	bosv.routing_sequence_id = p_routing_sequence_id
	and ((bosv.effectivity_date <= l_today and nvl(bosv.disable_date,l_today+1) > l_today)
		or (bosv.effectivity_date > l_today and nvl(bosv.disable_date, bosv.effectivity_date+1) > bosv.effectivity_date))
  Order by
	bosv.operation_type desc
	;
  l_operations_rec c_operations%ROWTYPE;


  Cursor c_networks(p_routing_sequence_id number) Is
  Select
	 l_assembly_item_name Assembly_Item_Name
	,l_org_code Organization_Code
	,p_alternate_code_to Alternate_Routing_Code
	,bonv.operation_type Operation_Type
	,bonv.from_seq_num From_Op_Seq_Number
	,bos1.x_coordinate From_X_Coordinate
	,bos1.y_coordinate From_Y_Coordinate
	,bonv.from_effectivity_date From_Start_Effective_Date
	,bonv.to_seq_num To_Op_Seq_Number
	,bos2.x_coordinate To_X_Coordinate
	,bos2.y_coordinate To_Y_Coordinate
	,bonv.to_effectivity_date To_Start_Effective_Date
	,bonv.from_seq_num New_From_Op_Seq_Number
	,bonv.from_effectivity_date New_From_Start_Effective_Date
	,bonv.to_seq_num New_To_Op_Seq_Number
	,bonv.to_effectivity_date New_To_Start_Effective_Date
	,bonv.transition_type Connection_Type
	,bonv.planning_pct Planning_Percent
	,bonv.attribute_category Attribute_category
	,bonv.attribute1 Attribute1
	,bonv.attribute2 Attribute2
	,bonv.attribute3 Attribute3
	,bonv.attribute4 Attribute4
	,bonv.attribute5 Attribute5
	,bonv.attribute6 Attribute6
	,bonv.attribute7 Attribute7
	,bonv.attribute8 Attribute8
	,bonv.attribute9 Attribute9
	,bonv.attribute10 Attribute10
	,bonv.attribute11 Attribute11
	,bonv.attribute12 Attribute12
	,bonv.attribute13 Attribute13
	,bonv.attribute14 Attribute14
	,bonv.attribute15 Attribute15
	,bonv.original_system_reference Original_System_Reference
	,'CREATE' Transaction_Type
	,NULL Return_Status
  From
	bom_operation_networks_v bonv,
	bom_operation_sequences bos1,
	bom_operation_sequences bos2
  Where
	bonv.routing_sequence_id = p_routing_sequence_id
	and bonv.from_op_seq_id = bos1.operation_sequence_id
	and ((bos1.effectivity_date <= l_today and nvl(bos1.disable_date,l_today+1) > l_today)
		or (bos1.effectivity_date > l_today and nvl(bos1.disable_date, bos1.effectivity_date+1) > bos1.effectivity_date))
	and bonv.to_op_seq_id = bos2.operation_sequence_id
	and ((bos2.effectivity_date <= l_today and nvl(bos2.disable_date,l_today+1) > l_today)
		or (bos2.effectivity_date > l_today and nvl(bos2.disable_date, bos2.effectivity_date+1) > bos2.effectivity_date))
	;
  l_networks_rec c_networks%ROWTYPE;


  Cursor c_std_ops(p_routing_sequence_id number) Is
  Select distinct
	 standard_operation_id
	,standard_operation_code
	,operation_type
  From
	bom_operation_sequences_v bosv
  Where
	routing_sequence_id = p_routing_sequence_id
	and ((effectivity_date <= l_today and nvl(disable_date,l_today+1) > l_today)
		or (effectivity_date > l_today and nvl(disable_date, effectivity_date+1) > effectivity_date))
  Order by
	standard_operation_code
	;


  Cursor c_std_op(p_standard_operation_id number) Is
  Select
	*
  From
	bom_standard_operations
  Where
	standard_operation_id = p_standard_operation_id
	;


  Cursor c_std_op_res(p_standard_operation_id number) Is
  Select
	 *
  From
	bom_std_op_resources
  Where
	standard_operation_id = p_standard_operation_id
	;

  Cursor c_new_rtg_seq_id(p_item_id number, p_org_id number, p_alternate varchar2) Is
  Select
	routing_sequence_id
  From
	bom_operational_routings
  Where
	assembly_item_id = p_item_id
	and organization_id = p_org_id
	and nvl(alternate_routing_designator,'NONE') = nvl(p_alternate,'NONE')
	;

  Cursor c_op_seq_id(p_rtg_seq_id number, p_op_type number, p_op_seq_num number) Is
  Select
	operation_sequence_id
  From
	bom_operation_sequences
  Where
	routing_sequence_id = p_rtg_seq_id
	and nvl(operation_type,0) = nvl(p_op_type,0)
	and operation_seq_num = p_op_seq_num
	;


  l_bom_rec c_bill_sequence%ROWTYPE;

  TYPE flm_rtg_tbl IS TABLE of c_routings%ROWTYPE INDEX BY BINARY_INTEGER;

  l_rtg_tbl flm_rtg_tbl;
  t_rtg_tbl flm_rtg_tbl;

  std_op_rec c_std_op%ROWTYPE;


Begin
  retcode := 0;


  -- retrieve list of routings
  i := 1;
  l_rtg_tbl := t_rtg_tbl;

  FOR l_rtg_rec IN c_routings LOOP
    l_rtg_tbl(i) := l_rtg_rec;
    i := i + 1;
  END LOOP;

  if (l_rtg_tbl.COUNT <= 0) then
    if (G_LOG_ON) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'No routings to copy.');
    end if;
    return;
  end if;


  -- remove duplicates on destination line
  i := l_rtg_tbl.FIRST;
  last := l_rtg_tbl.LAST;
  LOOP
    select count(*) into dup
    from bom_operational_routings bor
    where bor.organization_id = p_organization_id
    -- and bor.line_id = p_line_id_to
    and bor.assembly_item_id = l_rtg_tbl(i).assembly_item_id
    and bor.alternate_routing_designator = p_alternate_code_to;
    if (dup > 0) then
      l_rtg_tbl.DELETE(i);
    end if;
    EXIT WHEN i = last;
    i := l_rtg_tbl.NEXT(i);
  END LOOP;

  if (l_rtg_tbl.COUNT <= 0) then
    if (G_LOG_ON) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'No routings to copy.');
    end if;
    return;
  end if;

  -- add common routings
  i := l_rtg_tbl.FIRST;
  last := l_rtg_tbl.LAST;
  j := -1;
  LOOP
    if (l_rtg_tbl(i).routing_sequence_id <> l_rtg_tbl(i).common_routing_sequence_id) then
      select count(*) into dup
      from bom_operational_routings bor
      where bor.organization_id = p_organization_id
      -- and bor.line_id = p_line_id_to
      and bor.assembly_item_id = l_rtg_tbl(i).common_assembly_item_id
      and bor.alternate_routing_designator = p_alternate_code_to;

      in_list := false;
      ii := l_rtg_tbl.FIRST;
      jj := l_rtg_tbl.LAST;
      LOOP
        if l_rtg_tbl(ii).routing_sequence_id = l_rtg_tbl(i).common_routing_sequence_id then
          in_list := true;
        end if;
        EXIT WHEN in_list OR (ii = jj);
        ii := l_rtg_tbl.NEXT(ii);
      END LOOP;

      if (dup = 0) AND (NOT in_list) then
        select routing_sequence_id,common_routing_sequence_id,assembly_item_id,
	       common_assembly_item_id,alternate_routing_designator
	into l_rtg_tbl(j)
	from bom_operational_routings
	where routing_sequence_id = l_rtg_tbl(i).common_routing_sequence_id;
        j := j - 1;
      end if;
    end if;
    EXIT WHEN i = last;
    i := l_rtg_tbl.NEXT(i);
  END LOOP;

  l_rtg_total := l_rtg_tbl.COUNT;
  if (G_LOG_ON) then
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total routings to copy: '||l_rtg_total);
  end if;

  success := 0;

  -- copy each routing to destination line
  -- and, copy associated bill if p_copy_bom = 'Y'
  i := l_rtg_tbl.FIRST;
  last := l_rtg_tbl.LAST;

  LOOP
    -- routing header
    OPEN c_routing_header(l_rtg_tbl(i).routing_sequence_id);
    FETCH c_routing_header into l_routing_header_rec;
    l_rtg_header_rec.Assembly_Item_Name := l_routing_header_rec.Assembly_Item_Name;
    l_rtg_header_rec.Organization_Code  := l_routing_header_rec.Organization_Code;
    l_rtg_header_rec.Alternate_Routing_Code := l_routing_header_rec.Alternate_Routing_Code ;
    l_rtg_header_rec.Eng_Routing_Flag := l_routing_header_rec.Eng_Routing_Flag;
    l_rtg_header_rec.Common_Assembly_Item_Name := l_routing_header_rec.Common_Assembly_Item_Name;
    l_rtg_header_rec.Routing_Comment := l_routing_header_rec.Routing_Comment;
    l_rtg_header_rec.Completion_Subinventory := l_routing_header_rec.Completion_Subinventory;
    l_rtg_header_rec.Completion_Location_Name := l_routing_header_rec.Completion_Location_Name;
    l_rtg_header_rec.Line_Code := l_routing_header_rec.Line_Code;
    l_rtg_header_rec.CFM_Routing_Flag := l_routing_header_rec.CFM_Routing_Flag;
    l_rtg_header_rec.Mixed_Model_Map_Flag := l_routing_header_rec.Mixed_Model_Map_Flag;
    l_rtg_header_rec.Priority := l_routing_header_rec.Priority;
    l_rtg_header_rec.Total_Cycle_Time := l_routing_header_rec.Total_Cycle_Time;
    l_rtg_header_rec.CTP_Flag := l_routing_header_rec.CTP_Flag;
    l_rtg_header_rec.Attribute_category := l_routing_header_rec.Attribute_category;
    l_rtg_header_rec.Attribute1 := l_routing_header_rec.Attribute1;
    l_rtg_header_rec.Attribute2 := l_routing_header_rec.Attribute2;
    l_rtg_header_rec.Attribute3 := l_routing_header_rec.Attribute3;
    l_rtg_header_rec.Attribute4 := l_routing_header_rec.Attribute4;
    l_rtg_header_rec.Attribute5 := l_routing_header_rec.Attribute5;
    l_rtg_header_rec.Attribute6 := l_routing_header_rec.Attribute6;
    l_rtg_header_rec.Attribute7 := l_routing_header_rec.Attribute7;
    l_rtg_header_rec.Attribute8 := l_routing_header_rec.Attribute8;
    l_rtg_header_rec.Attribute9 := l_routing_header_rec.Attribute9;
    l_rtg_header_rec.Attribute10 := l_routing_header_rec.Attribute10;
    l_rtg_header_rec.Attribute11 := l_routing_header_rec.Attribute11;
    l_rtg_header_rec.Attribute12 := l_routing_header_rec.Attribute12;
    l_rtg_header_rec.Attribute13 := l_routing_header_rec.Attribute13;
    l_rtg_header_rec.Attribute14 := l_routing_header_rec.Attribute14;
    l_rtg_header_rec.Attribute15 := l_routing_header_rec.Attribute15;
    l_rtg_header_rec.Original_System_Reference := l_routing_header_rec.Original_System_Reference;
    l_rtg_header_rec.Transaction_Type := l_routing_header_rec.Transaction_Type;
    l_rtg_header_rec.Return_Status := l_routing_header_rec.Return_Status;
    l_rtg_header_rec.Delete_Group_Name := l_routing_header_rec.Delete_Group_Name;
    l_rtg_header_rec.DG_Description := l_routing_header_rec.DG_Description;
    CLOSE c_routing_header;

    l_assembly_item_name := l_rtg_header_rec.assembly_item_name;

    if (G_LOG_ON) then
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Copy routing: '||
		l_assembly_item_name||' ('||p_alternate_code_from||' -> '||p_alternate_code_to||')');
    end if;

    -- routing revisions
    l_rtg_revision_tbl := t_rtg_revision_tbl;
    o_rtg_revision_tbl := l_rtg_revision_tbl;


    -- copy standard operations and their resources
    SAVEPOINT copy_std;
    l_2_ids := t_2_ids;
    l_2_seq_ids := t_2_ids;
    FOR stdop in c_std_ops(l_rtg_tbl(i).routing_sequence_id) LOOP
      -- insert std_op for p_line_id_to
      -- cp std_op_res from old_op_id to new_op_id

      if (not std_op_exists(	p_organization_id, p_line_id_to,
				stdop.standard_operation_code,
				stdop.operation_type)) then
        l_std_op_exist := true;
        OPEN c_std_op(stdop.standard_operation_id);
        FETCH c_std_op into std_op_rec;
        IF c_std_op%NOTFOUND THEN
          l_std_op_exist := false;
        END IF;
        CLOSE c_std_op;

        if (l_std_op_exist) then
          new_row_id := NULL;
          new_std_op_id := NULL;
          b_std_op_pkg.Insert_Row( x_rowid			=>new_row_id
				,x_standard_operation_id	=>new_std_op_id
				,x_operation_code		=>std_op_rec.operation_code
				,x_operation_type		=>std_op_rec.operation_type
				,x_line_id			=>p_line_id_to
				,x_sequence_num			=>std_op_rec.sequence_num
				,x_organization_id		=>std_op_rec.organization_id
				,x_department_id		=>std_op_rec.department_id
				,x_last_update_date		=>sysdate
				,x_last_updated_by		=>fnd_global.user_id
				,x_creation_date		=>sysdate
				,x_created_by			=>fnd_global.user_id
				,x_last_update_login		=>fnd_global.login_id
				,x_minimum_transfer_quantity	=>std_op_rec.minimum_transfer_quantity
				,x_count_point_type		=>std_op_rec.count_point_type
				,x_operation_description	=>std_op_rec.operation_description
				,x_option_dependent_flag	=>std_op_rec.option_dependent_flag
				,x_attribute_category		=>std_op_rec.attribute_category
				,x_attribute1			=>std_op_rec.attribute1
				,x_attribute2			=>std_op_rec.attribute2
				,x_attribute3			=>std_op_rec.attribute3
				,x_attribute4			=>std_op_rec.attribute4
				,x_attribute5			=>std_op_rec.attribute5
				,x_attribute6			=>std_op_rec.attribute6
				,x_attribute7			=>std_op_rec.attribute7
				,x_attribute8			=>std_op_rec.attribute8
				,x_attribute9			=>std_op_rec.attribute9
				,x_attribute10			=>std_op_rec.attribute10
				,x_attribute11			=>std_op_rec.attribute11
				,x_attribute12			=>std_op_rec.attribute12
				,x_attribute13			=>std_op_rec.attribute13
				,x_attribute14			=>std_op_rec.attribute14
				,x_attribute15			=>std_op_rec.attribute15
				,x_backflush_flag		=>std_op_rec.backflush_flag
				,x_wms_task_type		=>std_op_rec.wms_task_type
				,x_yield			=>std_op_rec.yield
				,x_operation_yield_enabled	=>std_op_rec.operation_yield_enabled);

	  l_2_ids(stdop.standard_operation_id).old_id := stdop.standard_operation_id;
	  l_2_ids(stdop.standard_operation_id).new_id := new_std_op_id;

          FOR std_op_res_rec in c_std_op_res(stdop.standard_operation_id) LOOP
	    new_row_id := null;
            b_std_op_res_pkg.Insert_Row( x_rowid			=>new_row_id
					,x_standard_operation_id	=>new_std_op_id
					,x_resource_id			=>std_op_res_rec.resource_id
					,x_activity_id			=>std_op_res_rec.activity_id
					,x_last_update_date		=>sysdate
					,x_last_updated_by		=>fnd_global.user_id
					,x_creation_date		=>sysdate
					,x_created_by			=>fnd_global.user_id
					,x_last_update_login		=>fnd_global.login_id
					,x_resource_seq_num		=>std_op_res_rec.resource_seq_num
					,x_usage_rate_or_amount		=>std_op_res_rec.usage_rate_or_amount
					,x_usage_rate_or_amount_inverse	=>std_op_res_rec.usage_rate_or_amount_inverse
					,x_basis_type			=>std_op_res_rec.basis_type
					,x_autocharge_type		=>std_op_res_rec.autocharge_type
					,x_standard_rate_flag		=>std_op_res_rec.standard_rate_flag
					,x_assigned_units		=>std_op_res_rec.assigned_units
					,x_schedule_flag		=>std_op_res_rec.schedule_flag
					,x_attribute_category		=>std_op_res_rec.attribute_category
					,x_attribute1			=>std_op_res_rec.attribute1
					,x_attribute2			=>std_op_res_rec.attribute2
					,x_attribute3			=>std_op_res_rec.attribute3
					,x_attribute4			=>std_op_res_rec.attribute4
					,x_attribute5			=>std_op_res_rec.attribute5
					,x_attribute6			=>std_op_res_rec.attribute6
					,x_attribute7			=>std_op_res_rec.attribute7
					,x_attribute8			=>std_op_res_rec.attribute8
					,x_attribute9			=>std_op_res_rec.attribute9
					,x_attribute10			=>std_op_res_rec.attribute10
					,x_attribute11			=>std_op_res_rec.attribute11
					,x_attribute12			=>std_op_res_rec.attribute12
					,x_attribute13			=>std_op_res_rec.attribute13
					,x_attribute14			=>std_op_res_rec.attribute14
					,x_attribute15			=>std_op_res_rec.attribute15);
          END LOOP;

        end if;  -- l_std_op_exist

      /*Added below else condition for bugfix:8416058.If line operation/process/event already exists on
        destination line,check whether department of line operation/process/event is same on both source
        and destination lines.If not same,report it in log file and skip copy for that assembly */
      else

         BEGIN
           l_diff_count := 0;
           select count(*) into l_diff_count
           from (select department_id from bom_standard_operations where standard_operation_id = stdop.standard_operation_id) a,
                (select department_id from bom_standard_operations where organization_id = p_organization_id and line_id = p_line_id_to
                 and operation_code = stdop.standard_operation_code and operation_type = stdop.operation_type) b
           where a.department_id <> b.department_id;
           if (l_diff_count = 1) then
             l_dept_diff := 1;
             retcode := 1;
             if    (stdop.operation_type = 1) then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Copy flow routing across Lines program failed to copy for assembly '||
                l_assembly_item_name||' as department of Event '||stdop.standard_operation_code||' on source line '||l_line_code_from||
                ' is different from that on the destination line '||l_line_code||'.');
             elsif (stdop.operation_type = 2) then
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Copy flow routing across Lines program failed to copy for assembly '||
                l_assembly_item_name||' as department of Process '||stdop.standard_operation_code||' on source line '||l_line_code_from||
                ' is different from that on the destination line '||l_line_code||'.');
             else
              FND_FILE.PUT_LINE(FND_FILE.LOG,'Copy flow routing across Lines program failed to copy for assembly '||
                l_assembly_item_name||' as department of Line Operation '||stdop.standard_operation_code||' on source line '||l_line_code_from||
                ' is different from that on the destination line '||l_line_code||'.');
             end if;
           end if;
         Exception
           When others then
                 null;
         END;

      end if;  -- to_line std_op not exist

    END LOOP;

 -- Added below code for bugfix:8416058
    if (l_dept_diff=1) then
    l_dept_diff :=0;
    goto SKIP_TILL_HERE;
    end if;

    -- operation sequences
    l_operation_tbl := t_operation_tbl;
    o_operation_tbl := t_operation_tbl;
    j := 1;
    OPEN c_operations(l_rtg_tbl(i).routing_sequence_id);
    LOOP
      FETCH c_operations into l_operations_rec;
      EXIT WHEN c_operations%NOTFOUND;
      --first initialize the record
      l_operation_tbl(j).Assembly_Item_Name := null;
      l_operation_tbl(j).Organization_Code := null;
      l_operation_tbl(j).Alternate_Routing_Code := null;
      l_operation_tbl(j).Operation_Sequence_Number := null;
      l_operation_tbl(j).Operation_Type := null;
      l_operation_tbl(j).Start_Effective_Date := null;
      l_operation_tbl(j).New_Operation_Sequence_Number := null;
      l_operation_tbl(j).New_Start_Effective_Date := null;
      l_operation_tbl(j).Standard_Operation_Code := null;
      l_operation_tbl(j).Department_Code := null;
      l_operation_tbl(j).Op_Lead_Time_Percent := null;
      l_operation_tbl(j).Minimum_Transfer_Quantity := null;
      l_operation_tbl(j).Count_Point_Type := null;
      l_operation_tbl(j).Operation_Description := null;
      l_operation_tbl(j).Disable_Date := null;
      l_operation_tbl(j).Backflush_Flag := null;
      l_operation_tbl(j).Option_Dependent_Flag := null;
      l_operation_tbl(j).Reference_Flag := null;
      l_operation_tbl(j).Process_Seq_Number := null;
      l_operation_tbl(j).Process_Code := null;
      l_operation_tbl(j).Line_Op_Seq_Number := null;
      l_operation_tbl(j).Line_Op_Code := null;
      l_operation_tbl(j).Yield := null;
      l_operation_tbl(j).Cumulative_Yield := null;
      l_operation_tbl(j).Reverse_CUM_Yield := null;
      l_operation_tbl(j).User_Labor_Time := null;
      l_operation_tbl(j).User_Machine_Time := null;
      l_operation_tbl(j).Net_Planning_Percent := null;
      l_operation_tbl(j).Include_In_Rollup := null;
      l_operation_tbl(j).Op_Yield_Enabled_Flag := null;
      l_operation_tbl(j).Shutdown_Type := null;
      l_operation_tbl(j).Attribute_category := null;
      l_operation_tbl(j).Attribute1 := null;
      l_operation_tbl(j).Attribute2 := null;
      l_operation_tbl(j).Attribute3 := null;
      l_operation_tbl(j).Attribute4 := null;
      l_operation_tbl(j).Attribute5 := null;
      l_operation_tbl(j).Attribute6 := null;
      l_operation_tbl(j).Attribute7 := null;
      l_operation_tbl(j).Attribute8 := null;
      l_operation_tbl(j).Attribute9 := null;
      l_operation_tbl(j).Attribute10 := null;
      l_operation_tbl(j).Attribute11 := null;
      l_operation_tbl(j).Attribute12 := null;
      l_operation_tbl(j).Attribute13 := null;
      l_operation_tbl(j).Attribute14 := null;
      l_operation_tbl(j).Attribute15 := null;
      l_operation_tbl(j).Original_System_Reference := null;
      l_operation_tbl(j).Transaction_Type := null;
      l_operation_tbl(j).Return_Status := null;
      l_operation_tbl(j).Delete_Group_Name := null;
      l_operation_tbl(j).DG_Description := null;

      --now populate the record from cursor record
      l_operation_tbl(j).Assembly_Item_Name := l_operations_rec.Assembly_Item_Name;
      l_operation_tbl(j).Organization_Code := l_operations_rec.Organization_Code;
      l_operation_tbl(j).Alternate_Routing_Code := l_operations_rec.Alternate_Routing_Code;
      l_operation_tbl(j).Operation_Sequence_Number := l_operations_rec.Operation_Sequence_Number;
      l_operation_tbl(j).Operation_Type := l_operations_rec.Operation_Type;
      l_operation_tbl(j).Start_Effective_Date := l_operations_rec.Start_Effective_Date;
      l_operation_tbl(j).New_Operation_Sequence_Number := l_operations_rec.New_Operation_Sequence_Number;
      l_operation_tbl(j).New_Start_Effective_Date := l_operations_rec.New_Start_Effective_Date;
      l_operation_tbl(j).Standard_Operation_Code := l_operations_rec.Standard_Operation_Code;
      l_operation_tbl(j).Department_Code := l_operations_rec.Department_Code;
      l_operation_tbl(j).Op_Lead_Time_Percent := l_operations_rec.Op_Lead_Time_Percent;
      l_operation_tbl(j).Minimum_Transfer_Quantity := l_operations_rec.Minimum_Transfer_Quantity;
      l_operation_tbl(j).Count_Point_Type := l_operations_rec.Count_Point_Type;
      l_operation_tbl(j).Operation_Description := l_operations_rec.Operation_Description;
      l_operation_tbl(j).Disable_Date := l_operations_rec.Disable_Date;
      l_operation_tbl(j).Backflush_Flag := l_operations_rec.Backflush_Flag;
      l_operation_tbl(j).Option_Dependent_Flag := l_operations_rec.Option_Dependent_Flag;
      l_operation_tbl(j).Reference_Flag := l_operations_rec.Reference_Flag;
      l_operation_tbl(j).Process_Seq_Number := l_operations_rec.Process_Seq_Number;
      l_operation_tbl(j).Process_Code := l_operations_rec.Process_Code;
      l_operation_tbl(j).Line_Op_Seq_Number := l_operations_rec.Line_Op_Seq_Number;
      l_operation_tbl(j).Line_Op_Code := l_operations_rec.Line_Op_Code;
      l_operation_tbl(j).Yield := l_operations_rec.Yield;
      l_operation_tbl(j).Cumulative_Yield := l_operations_rec.Cumulative_Yield;
      l_operation_tbl(j).Reverse_CUM_Yield := l_operations_rec.Reverse_CUM_Yield;
      l_operation_tbl(j).User_Labor_Time := l_operations_rec.User_Labor_Time;
      l_operation_tbl(j).User_Machine_Time := l_operations_rec.User_Machine_Time;
      l_operation_tbl(j).Net_Planning_Percent := l_operations_rec.Net_Planning_Percent;
      l_operation_tbl(j).Include_In_Rollup := l_operations_rec.Include_In_Rollup;
      l_operation_tbl(j).Op_Yield_Enabled_Flag := l_operations_rec.Op_Yield_Enabled_Flag;
      l_operation_tbl(j).Shutdown_Type := l_operations_rec.Shutdown_Type;
      l_operation_tbl(j).Attribute_category := l_operations_rec.Attribute_category;
      l_operation_tbl(j).Attribute1 := l_operations_rec.Attribute1;
      l_operation_tbl(j).Attribute2 := l_operations_rec.Attribute2;
      l_operation_tbl(j).Attribute3 := l_operations_rec.Attribute3;
      l_operation_tbl(j).Attribute4 := l_operations_rec.Attribute4;
      l_operation_tbl(j).Attribute5 := l_operations_rec.Attribute5;
      l_operation_tbl(j).Attribute6 := l_operations_rec.Attribute6;
      l_operation_tbl(j).Attribute7 := l_operations_rec.Attribute7;
      l_operation_tbl(j).Attribute8 := l_operations_rec.Attribute8;
      l_operation_tbl(j).Attribute9 := l_operations_rec.Attribute9;
      l_operation_tbl(j).Attribute10 := l_operations_rec.Attribute10;
      l_operation_tbl(j).Attribute11 := l_operations_rec.Attribute11;
      l_operation_tbl(j).Attribute12 := l_operations_rec.Attribute12;
      l_operation_tbl(j).Attribute13 := l_operations_rec.Attribute13;
      l_operation_tbl(j).Attribute14 := l_operations_rec.Attribute14;
      l_operation_tbl(j).Attribute15 := l_operations_rec.Attribute15;
      l_operation_tbl(j).Original_System_Reference := l_operations_rec.Original_System_Reference;
      l_operation_tbl(j).Transaction_Type := l_operations_rec.Transaction_Type;
      l_operation_tbl(j).Return_Status := l_operations_rec.Return_Status;
      l_operation_tbl(j).Delete_Group_Name := l_operations_rec.Delete_Group_Name;
      l_operation_tbl(j).DG_Description := l_operations_rec.DG_Description;

      if l_operation_tbl(j).start_effective_date < l_today then
        l_operation_tbl(j).start_effective_date := l_today;
        l_operation_tbl(j).new_start_effective_date := l_today;
      end if;
      if l_operation_tbl(j).operation_type = 1 then
        -- check event's process /lineop
        lineop_in_list := false;
        process_in_list := false;
        ii := l_operation_tbl.FIRST;
        jj := l_operation_tbl.LAST;
        LOOP
          if l_operation_tbl(ii).operation_type = 2 and
	     l_operation_tbl(ii).operation_sequence_number = l_operation_tbl(j).process_seq_number and
	     l_operation_tbl(ii).standard_operation_code =  l_operation_tbl(j).process_code then
            process_in_list := true;
          end if;

          if l_operation_tbl(ii).operation_type = 3 and
	     l_operation_tbl(ii).operation_sequence_number = l_operation_tbl(j).line_op_seq_number and
	     l_operation_tbl(ii).standard_operation_code =  l_operation_tbl(j).line_op_code then
            lineop_in_list := true;
          end if;

          exit when ii = jj;
          ii := l_operation_tbl.NEXT(ii);

        END LOOP;

        if (not process_in_list) then
          l_operation_tbl(j).process_seq_number := null;
          l_operation_tbl(j).process_code := null;
        end if;

        if (not lineop_in_list) then
          l_operation_tbl(j).line_op_seq_number := null;
          l_operation_tbl(j).line_op_code := null;
        end if;

      end if;
      j := j + 1;
    END LOOP;
    CLOSE c_operations;

    a_operation_tbl := l_operation_tbl;

    -- operation networks
    l_op_network_tbl := t_op_network_tbl;
    o_op_network_tbl := t_op_network_tbl;
    j := 1;
    OPEN c_networks(l_rtg_tbl(i).routing_sequence_id);
    LOOP
      FETCH c_networks into l_networks_rec;
      EXIT WHEN c_networks%NOTFOUND;
      --first initialize the record
      l_op_network_tbl(j).Assembly_Item_Name := null;
      l_op_network_tbl(j).Organization_Code := null;
      l_op_network_tbl(j).Alternate_Routing_Code := null;
      l_op_network_tbl(j).Operation_Type := null;
      l_op_network_tbl(j).From_Op_Seq_Number := null;
      l_op_network_tbl(j).From_X_Coordinate := null;
      l_op_network_tbl(j).From_Y_Coordinate  := null;
      l_op_network_tbl(j).From_Start_Effective_Date := null;
      l_op_network_tbl(j).To_Op_Seq_Number := null;
      l_op_network_tbl(j).To_X_Coordinate := null;
      l_op_network_tbl(j).To_Y_Coordinate := null;
      l_op_network_tbl(j).To_Start_Effective_Date := null;
      l_op_network_tbl(j).New_From_Op_Seq_Number := null;
      l_op_network_tbl(j).New_From_Start_Effective_Date := null;
      l_op_network_tbl(j).New_To_Op_Seq_Number := null;
      l_op_network_tbl(j).New_To_Start_Effective_Date := null;
      l_op_network_tbl(j).Connection_Type := null;
      l_op_network_tbl(j).Planning_Percent := null;
      l_op_network_tbl(j).Attribute_category := null;
      l_op_network_tbl(j).Attribute1 := null;
      l_op_network_tbl(j).Attribute2 := null;
      l_op_network_tbl(j).Attribute3 := null;
      l_op_network_tbl(j).Attribute4 := null;
      l_op_network_tbl(j).Attribute5 := null;
      l_op_network_tbl(j).Attribute6 := null;
      l_op_network_tbl(j).Attribute7 := null;
      l_op_network_tbl(j).Attribute8 := null;
      l_op_network_tbl(j).Attribute9 := null;
      l_op_network_tbl(j).Attribute10 := null;
      l_op_network_tbl(j).Attribute11 := null;
      l_op_network_tbl(j).Attribute12 := null;
      l_op_network_tbl(j).Attribute13 := null;
      l_op_network_tbl(j).Attribute14 := null;
      l_op_network_tbl(j).Attribute15 := null;
      l_op_network_tbl(j).Original_System_Reference := null;
      l_op_network_tbl(j).Transaction_Type := null;
      l_op_network_tbl(j).Return_Status := null;

      --now populate the record from cursor record
      l_op_network_tbl(j).Assembly_Item_Name := l_networks_rec.Assembly_Item_Name;
      l_op_network_tbl(j).Organization_Code := l_networks_rec.Organization_Code;
      l_op_network_tbl(j).Alternate_Routing_Code := l_networks_rec.Alternate_Routing_Code;
      l_op_network_tbl(j).Operation_Type := l_networks_rec.Operation_Type;
      l_op_network_tbl(j).From_Op_Seq_Number := l_networks_rec.From_Op_Seq_Number;
      l_op_network_tbl(j).From_X_Coordinate := l_networks_rec.From_X_Coordinate;
      l_op_network_tbl(j).From_Y_Coordinate  := l_networks_rec.From_Y_Coordinate;
      l_op_network_tbl(j).From_Start_Effective_Date := l_networks_rec.From_Start_Effective_Date;
      l_op_network_tbl(j).To_Op_Seq_Number := l_networks_rec.To_Op_Seq_Number;
      l_op_network_tbl(j).To_X_Coordinate := l_networks_rec.To_X_Coordinate;
      l_op_network_tbl(j).To_Y_Coordinate := l_networks_rec.To_Y_Coordinate;
      l_op_network_tbl(j).To_Start_Effective_Date := l_networks_rec.To_Start_Effective_Date;
      l_op_network_tbl(j).New_From_Op_Seq_Number := l_networks_rec.New_From_Op_Seq_Number;
      l_op_network_tbl(j).New_From_Start_Effective_Date := l_networks_rec.New_From_Start_Effective_Date;
      l_op_network_tbl(j).New_To_Op_Seq_Number := l_networks_rec.New_To_Op_Seq_Number;
      l_op_network_tbl(j).New_To_Start_Effective_Date := l_networks_rec.New_To_Start_Effective_Date;
      l_op_network_tbl(j).Connection_Type := l_networks_rec.Connection_Type;
      l_op_network_tbl(j).Planning_Percent := l_networks_rec.Planning_Percent;
      l_op_network_tbl(j).Attribute_category := l_networks_rec.Attribute_category;
      l_op_network_tbl(j).Attribute1 := l_networks_rec.Attribute1;
      l_op_network_tbl(j).Attribute2 := l_networks_rec.Attribute2;
      l_op_network_tbl(j).Attribute3  := l_networks_rec.Attribute3;
      l_op_network_tbl(j).Attribute4 := l_networks_rec.Attribute4;
      l_op_network_tbl(j).Attribute5 := l_networks_rec.Attribute5;
      l_op_network_tbl(j).Attribute6 := l_networks_rec.Attribute6;
      l_op_network_tbl(j).Attribute7 := l_networks_rec.Attribute7;
      l_op_network_tbl(j).Attribute8 := l_networks_rec.Attribute8;
      l_op_network_tbl(j).Attribute9 := l_networks_rec.Attribute9;
      l_op_network_tbl(j).Attribute10 := l_networks_rec.Attribute10;
      l_op_network_tbl(j).Attribute11 := l_networks_rec.Attribute11;
      l_op_network_tbl(j).Attribute12 := l_networks_rec.Attribute12;
      l_op_network_tbl(j).Attribute13 := l_networks_rec.Attribute13;
      l_op_network_tbl(j).Attribute14 := l_networks_rec.Attribute14;
      l_op_network_tbl(j).Attribute15 := l_networks_rec.Attribute15;
      l_op_network_tbl(j).Original_System_Reference := l_networks_rec.Original_System_Reference;
      l_op_network_tbl(j).Transaction_Type  := l_networks_rec.Transaction_Type;
      l_op_network_tbl(j).Return_Status := l_networks_rec.Return_Status;

      if l_op_network_tbl(j).from_start_effective_date < l_today then
        l_op_network_tbl(j).from_start_effective_date := l_today;
        l_op_network_tbl(j).new_from_start_effective_date := l_today;
      end if;
      if l_op_network_tbl(j).to_start_effective_date < l_today then
        l_op_network_tbl(j).to_start_effective_date := l_today;
        l_op_network_tbl(j).new_to_start_effective_date := l_today;
      end if;
      j := j + 1;
    END LOOP;
    CLOSE c_networks;

    error_handler.initialize;

    Bom_Rtg_Pub.Process_Rtg(	 p_rtg_header_rec	=>l_rtg_header_rec
				,p_rtg_revision_tbl	=>l_rtg_revision_tbl
				,p_operation_tbl	=>l_operation_tbl
				,p_op_resource_tbl	=>l_op_resource_tbl
				,p_sub_resource_tbl	=>l_sub_resource_tbl
				,p_op_network_tbl	=>l_op_network_tbl
				,x_rtg_header_rec	=>o_rtg_header_rec
				,x_rtg_revision_tbl	=>o_rtg_revision_tbl
				,x_operation_tbl	=>o_operation_tbl
				,x_op_resource_tbl	=>o_op_resource_tbl
				,x_sub_resource_tbl	=>o_sub_resource_tbl
				,x_op_network_tbl	=>o_op_network_tbl
				,x_return_status	=>o_return_status
				,x_msg_count		=>o_msg_count
				,p_debug		=>'N'
				,p_output_dir		=>NULL
				,p_debug_filename	=>'1.log');

    if (o_return_status <> 'S') then
      retcode := 1;
      fnd_message.set_name('FLM','FLM_RTG_BOM_API_FAILED');
      fnd_message.set_token('MSG_COUNT',error_handler.get_message_count);
      errbuf := fnd_message.get;
      if (G_LOG_ON) then
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf || ' - ' || l_assembly_item_name);
        while o_msg_count > 0 loop
          error_handler.get_message(l_msg,l_index,l_id,l_type);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_type||' - '||l_msg||' - '||l_id);
          o_msg_count := o_msg_count - 1;
        end loop;
      end if;
      ROLLBACK TO SAVEPOINT copy_std;
    elsif (o_msg_count > 0) then
      if (G_LOG_ON) then
        while o_msg_count > 0 loop
          error_handler.get_message(l_msg,l_index,l_id,l_type);
          FND_FILE.PUT_LINE(FND_FILE.LOG,l_type||' - '||l_msg||' - '||l_id);
          o_msg_count := o_msg_count - 1;
        end loop;
      end if;
    end if;

    -- copy BOM if source exists and destination doesn't and
    -- the assembly is not a product family (p_mode <> 2)
    if (o_return_status = 'S' and nvl(p_copy_bom,'N') = 'Y' and p_mode = 1) then
      if (not bill_exists(l_rtg_tbl(i).assembly_item_id,p_organization_id,p_alternate_code_to)) then

        Open c_bill_sequence(l_rtg_tbl(i).assembly_item_id,p_organization_id,p_alternate_code_from);
        Fetch c_bill_sequence into l_bom_rec;
        if (c_bill_sequence%NOTFOUND) then
          l_from_sequence_id := NULL;
        else
          l_from_sequence_id := l_bom_rec.bill_sequence_id;
          l_to_common_seq_id := l_bom_rec.common_bill_sequence_id;
        end if;
        Close c_bill_sequence;

        if (l_from_sequence_id is not NULL) then

          if (G_LOG_ON) then
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Copy bill: '||
		l_assembly_item_name||' ('||p_alternate_code_from||' -> '||p_alternate_code_to||')');
          end if;

	  l_to_sequence_id := null;

          bom_bill_of_matls_pkg.Insert_Row(
		        X_Rowid				 =>new_row_id
                       ,X_Assembly_Item_Id		 =>l_bom_rec.assembly_item_id
                       ,X_Organization_Id		 =>l_bom_rec.organization_id
                       ,X_Alternate_Bom_Designator	 =>p_alternate_code_to
                       ,X_Last_Update_Date               =>sysdate
                       ,X_Last_Updated_By                =>fnd_global.user_id
                       ,X_Creation_Date                  =>sysdate
                       ,X_Created_By                     =>fnd_global.user_id
                       ,X_Last_Update_Login              =>fnd_global.login_id
                       ,X_Common_Assembly_Item_Id        =>l_bom_rec.common_assembly_item_id
                       ,X_Specific_Assembly_Comment      =>l_bom_rec.Specific_Assembly_Comment
                       ,X_Pending_From_Ecn               =>l_bom_rec.Pending_From_Ecn
                       ,X_Attribute_Category             =>l_bom_rec.attribute_category
                       ,X_Attribute1                     =>l_bom_rec.attribute1
                       ,X_Attribute2                     =>l_bom_rec.attribute2
                       ,X_Attribute3                     =>l_bom_rec.attribute3
                       ,X_Attribute4                     =>l_bom_rec.attribute4
                       ,X_Attribute5                     =>l_bom_rec.attribute5
                       ,X_Attribute6                     =>l_bom_rec.attribute6
                       ,X_Attribute7                     =>l_bom_rec.attribute7
                       ,X_Attribute8                     =>l_bom_rec.attribute8
                       ,X_Attribute9                     =>l_bom_rec.attribute9
                       ,X_Attribute10                    =>l_bom_rec.attribute10
                       ,X_Attribute11                    =>l_bom_rec.attribute11
                       ,X_Attribute12                    =>l_bom_rec.attribute12
                       ,X_Attribute13                    =>l_bom_rec.attribute13
                       ,X_Attribute14                    =>l_bom_rec.attribute14
                       ,X_Attribute15                    =>l_bom_rec.attribute15
                       ,X_Assembly_Type                  =>l_bom_rec.assembly_type
                       ,X_Common_Bill_Sequence_Id        =>l_to_common_seq_id
                       ,X_Bill_Sequence_Id               =>l_to_sequence_id
                       ,X_Common_Organization_Id         =>l_bom_rec.Common_Organization_Id
                       ,X_Next_Explode_Date              =>l_bom_rec.Next_Explode_Date
		);
          bom_copy_bill.copy_bill(
		 to_sequence_id		=>l_to_sequence_id
		,from_sequence_id	=>l_from_sequence_id
		,from_org_id		=>p_organization_id
		,to_org_id		=>p_organization_id
		,display_option		=>3 -- current+future
		,user_id		=>fnd_global.user_id
		,to_item_id		=>l_rtg_tbl(i).assembly_item_id
		,direction		=>1
		,to_alternate		=>p_alternate_code_to
		,rev_date		=>sysdate
		,e_change_notice	=>NULL
		,rev_item_seq_id	=>NULL
		,bill_or_eco		=>1
		,eco_eff_date		=>NULL
		,eco_unit_number	=>NULL
		,unit_number		=>NULL
		,from_item_id		=>l_rtg_tbl(i).assembly_item_id
		);
        end if;
      end if;
    end if;

    -- both RTG and/or BOM copied, then copy attachments
    if (o_return_status = 'S') then
      if l_2_ids.COUNT > 0 then
        copy_attach('BOM_STANDARD_OPERATIONS','BOM_STANDARD_OPERATIONS',l_2_ids);
      end if;
      if a_operation_tbl.COUNT > 0 then

        l_new_rtg_seq_id := null;
        OPEN c_new_rtg_seq_id(l_rtg_tbl(i).assembly_item_id,p_organization_id,p_alternate_code_to);
        FETCH c_new_rtg_seq_id INTO l_new_rtg_seq_id;
        if c_new_rtg_seq_id%NOTFOUND then
          l_new_rtg_seq_id := null;
        end if;
        CLOSE c_new_rtg_seq_id;

        if (l_new_rtg_seq_id is NOT NULL) then
          ii := a_operation_tbl.FIRST;
          jj := a_operation_tbl.LAST;
          LOOP
            l_old_op_seq_id := null;
            l_new_op_seq_id := null;
            OPEN c_op_seq_id(	 l_rtg_tbl(i).routing_sequence_id
				,a_operation_tbl(ii).operation_type
				,a_operation_tbl(ii).operation_sequence_number);

            FETCH c_op_seq_id into l_old_op_seq_id;
	    IF c_op_seq_id%NOTFOUND THEN
              l_old_op_seq_id := null;
            END IF;
            CLOSE c_op_seq_id;

            OPEN c_op_seq_id(	 l_new_rtg_seq_id
				,a_operation_tbl(ii).operation_type
				,a_operation_tbl(ii).operation_sequence_number);

            FETCH c_op_seq_id into l_new_op_seq_id;
	    IF c_op_seq_id%NOTFOUND THEN
              l_new_op_seq_id := null;
            END IF;
            CLOSE c_op_seq_id;

            if (l_old_op_seq_id is not null and l_new_op_seq_id is not null) then
              l_2_seq_ids(l_old_op_seq_id).old_id := l_old_op_seq_id;
              l_2_seq_ids(l_old_op_seq_id).new_id := l_new_op_seq_id;
            end if;

            EXIT WHEN ii = jj;
	    ii := a_operation_tbl.NEXT(ii);
          END LOOP;
        end if;
      end if;
      if l_2_seq_ids.COUNT > 0 then
        copy_attach('BOM_OPERATION_SEQUENCES','BOM_OPERATION_SEQUENCES',l_2_seq_ids);
      end if;
      success := success + 1;
    end if;

--Added skip till here for bugfix:8416058
<<SKIP_TILL_HERE>>

    EXIT WHEN i = last;
    i := l_rtg_tbl.NEXT(i);
  END LOOP;

  if (success = 0) then
    retcode := 2;
    fnd_message.set_name('FLM', 'FLM_RTG_COPY_NONE');
    fnd_message.set_token('RTG_TOTAL',l_rtg_total);
    errbuf := fnd_message.get;
    if (G_LOG_ON) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    end if;
    rollback;
  else
    fnd_message.set_name('FLM', 'FLM_RTG_COPY_DONE');
    fnd_message.set_token('RTG_COUNT', success);
    fnd_message.set_token('RTG_TOTAL',l_rtg_total);
    errbuf := fnd_message.get;
    if (G_LOG_ON) then
      FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
    end if;
    commit;
  end if;

  EXCEPTION
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := 'Exception - ' || substr(SQLERRM,1,200) || ' (' || SQLCODE || ')';
      if (G_LOG_ON) then
        FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
      end if;
      rollback;
      return;

End copy_routings;

END flm_copy_routing;

/
