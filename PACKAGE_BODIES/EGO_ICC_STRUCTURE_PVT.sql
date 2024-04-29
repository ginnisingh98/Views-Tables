--------------------------------------------------------
--  DDL for Package Body EGO_ICC_STRUCTURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ICC_STRUCTURE_PVT" AS
/* $Header: egoistpb.pls 120.0.12010000.13 2009/09/10 19:45:00 sisankar ship $ */

date_fmt varchar2(25) := 'yyyy/mm/dd hh24:mi:ss';
type item_revision_record is record
(revision_id   Number,
 revision      Varchar2(10),
 start_date    Date,
 end_date      Date);

/* This PL/SQL table is used storing and retrieving for item revision details. */
type revision_rec is table of item_revision_record index by binary_integer;
v_item_revisions_tbl revision_rec;

type rev_index is table of number index by binary_integer;
v_rev_index rev_index;

G_COMP_ITEM_NAME VARCHAR2(1000);
G_ASSY_ITEM_NAME VARCHAR2(1000);
G_ALTCODE VARCHAR2(10);
G_EFF_FROM VARCHAR2(80);

/*  UT Fix : Added to store assembly_item_id for procedures create_structure_inherit and inherit_icc_components. */
G_INV_ITEM_ID NUMBER;

/*
 * This Procedure will delete the user attributes for components.
 */
Procedure Delete_Comp_User_Attrs(p_comp_seq_id IN NUMBER)
IS
BEGIN

    delete from BOM_COMPONENTS_EXT_B
    where component_sequence_id = p_comp_seq_id;

    delete from BOM_COMPONENTS_EXT_TL
    where component_sequence_id = p_comp_seq_id;

END Delete_Comp_User_Attrs;

Procedure Create_Default_Header(p_item_catalog_grp_id IN NUMBER)
IS
    l_create_header Number := 0;
    l_bill_sequence_id Number;

    cursor Get_str_catalog_hierarchy
    IS
    select structures.bill_sequence_id
    from ( select item_catalog_group_id
           from mtl_item_catalog_groups_b
           connect by prior parent_catalog_group_id = item_catalog_group_id
           start with item_catalog_group_id = p_item_catalog_grp_id ) icc,
         BOM_STRUCTURES_B structures
    where structures.pk1_value = icc.item_catalog_group_id
    and structures.obj_name = 'EGO_CATALOG_GROUP'
    and rownum = 1;

Begin

    /* We need to create structure header only for versioned ICCs which doesn't have structure header already. */

    select 1
    into l_create_header
    from dual
    where exists (select 1
                  from EGO_MTL_CATALOG_GRP_VERS_B
                  where item_catalog_group_id = p_item_catalog_grp_id)
    and not exists (select 1
                    from BOM_STRUCTURES_B
                    where pk1_value = p_item_catalog_grp_id
                    and obj_name = 'EGO_CATALOG_GROUP');

    if l_create_header = 1 then

        for icc_structure in Get_str_catalog_hierarchy loop

            select bom_inventory_components_s.nextval
            into l_bill_sequence_id
            from dual;

            insert into BOM_STRUCTURES_B
            (BILL_SEQUENCE_ID,
             SOURCE_BILL_SEQUENCE_ID,
             COMMON_BILL_SEQUENCE_ID,
             ORGANIZATION_ID,
             ALTERNATE_BOM_DESIGNATOR,
             ASSEMBLY_TYPE,
             STRUCTURE_TYPE_ID,
             EFFECTIVITY_CONTROL,
             IS_PREFERRED,
             OBJ_NAME,
             PK1_VALUE,
             PK2_VALUE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN)
            select
             l_bill_sequence_id,
             l_bill_sequence_id,
             l_bill_sequence_id,
             ORGANIZATION_ID,
             ALTERNATE_BOM_DESIGNATOR,
             ASSEMBLY_TYPE,
             STRUCTURE_TYPE_ID,
             EFFECTIVITY_CONTROL,
             IS_PREFERRED,
             OBJ_NAME,
             p_item_catalog_grp_id,
             PK2_VALUE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN
            from BOM_STRUCTURES_B
            where BILL_SEQUENCE_ID = icc_structure.bill_sequence_id ;

        end loop;

    end if;

Exception
    when others then
        null;
End Create_Default_Header;

/*
 * This Procedure will revert the components for the Draft version of the ICC.
 */
PROCEDURE Revert_draft_components (p_item_catalog_grp_id IN NUMBER,
                                   p_version_seq_id      IN NUMBER,
                                   x_Return_Status       OUT NOCOPY NUMBER,
                                   x_Error_Message       OUT NOCOPY VARCHAR2)
IS
    Cursor get_draft_components(p_bill_seq_id   NUMBER)
    IS
      SELECT COMPONENT_SEQUENCE_ID
      from BOM_COMPONENTS_B
      where bill_sequence_id = p_bill_seq_id
      and nvl(from_object_revision_id,0) = 0;

    Cursor get_version_components(p_bill_seq_id   NUMBER)
    IS
      SELECT COMPONENT_SEQUENCE_ID
      from BOM_COMPONENTS_B
      where bill_sequence_id = p_bill_seq_id
      and from_object_revision_id = p_version_seq_id
      and nvl(parent_bill_seq_id,p_bill_seq_id) = p_bill_seq_id;

    l_bill_seq_id Number;
    l_new_component_seq_id Number;
    l_structure_type_id Number;

    l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_src_pk_col_name_val_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_str_type                   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_pks             EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_id              Number;

    l_errorcode Number;
    l_msg_count Number;
    l_msg_data  Varchar2(2000);
    l_Return_Status Varchar2(1) := 'S';

BEGIN
    x_Return_Status := 0;
    x_Error_Message := null;

    Begin
        SELECT bill_sequence_id,
               structure_type_id
        INTO   l_bill_seq_id,
               l_structure_type_id
        FROM BOM_STRUCTURES_B
        WHERE pk1_value = p_item_catalog_grp_id
        AND obj_name = 'EGO_CATALOG_GROUP';
    Exception
        when others then
            null;
    End;

    if l_bill_seq_id is not null then

        for component in get_draft_components(l_bill_seq_id) loop
            delete_comp_user_attrs(component.component_sequence_id);
        end loop;

        delete from bom_components_b
        where bill_sequence_id = l_bill_seq_id
        and nvl(from_object_revision_id,0) = 0;

        select data_level_id
        into l_data_level_id
        from ego_data_level_b
        where data_level_name = 'COMPONENTS_LEVEL'
        and attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
        and application_id = 702;

        for component in get_version_components(l_bill_seq_id) loop

            select BOM_INVENTORY_COMPONENTS_S.NEXTVAL
            into l_new_component_seq_id
            from dual;

            Insert into BOM_COMPONENTS_B
            (OPERATION_SEQ_NUM,
             COMPONENT_ITEM_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             ITEM_NUM,
             COMPONENT_QUANTITY,
             COMPONENT_YIELD_FACTOR,
             EFFECTIVITY_DATE,
             IMPLEMENTATION_DATE,
             PLANNING_FACTOR,
             QUANTITY_RELATED,
             SO_BASIS,
             OPTIONAL,
             MUTUALLY_EXCLUSIVE_OPTIONS,
             INCLUDE_IN_COST_ROLLUP,
             CHECK_ATP,
             SHIPPING_ALLOWED,
             REQUIRED_TO_SHIP,
             REQUIRED_FOR_REVENUE,
             INCLUDE_ON_SHIP_DOCS,
             COMPONENT_SEQUENCE_ID,
             BILL_SEQUENCE_ID,
             WIP_SUPPLY_TYPE,
             PICK_COMPONENTS,
             SUPPLY_SUBINVENTORY,
             SUPPLY_LOCATOR_ID,
             BOM_ITEM_TYPE,
             ENFORCE_INT_REQUIREMENTS,
             COMPONENT_ITEM_REVISION_ID,
             PARENT_BILL_SEQ_ID,
             AUTO_REQUEST_MATERIAL,
             PK1_VALUE,
             PK2_VALUE,
             PK3_VALUE,
             PK4_VALUE,
             PK5_VALUE,
             FROM_OBJECT_REVISION_ID,
             COMPONENT_REMARKS,
             CHANGE_NOTICE,
             BASIS_TYPE,
             LOW_QUANTITY,
             HIGH_QUANTITY)
             select
             BCB.OPERATION_SEQ_NUM,
             BCB.COMPONENT_ITEM_ID,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             BCB.ITEM_NUM,
             BCB.COMPONENT_QUANTITY,
             BCB.COMPONENT_YIELD_FACTOR,
             BCB.EFFECTIVITY_DATE,
             BCB.IMPLEMENTATION_DATE,
             BCB.PLANNING_FACTOR,
             BCB.QUANTITY_RELATED,
             BCB.SO_BASIS,
             BCB.OPTIONAL,
             BCB.MUTUALLY_EXCLUSIVE_OPTIONS,
             BCB.INCLUDE_IN_COST_ROLLUP,
             BCB.CHECK_ATP,
             BCB.SHIPPING_ALLOWED,
             BCB.REQUIRED_TO_SHIP,
             BCB.REQUIRED_FOR_REVENUE,
             BCB.INCLUDE_ON_SHIP_DOCS,
             l_new_component_seq_id,
             l_bill_seq_id,
             BCB.WIP_SUPPLY_TYPE,
             BCB.PICK_COMPONENTS,
             BCB.SUPPLY_SUBINVENTORY,
             BCB.SUPPLY_LOCATOR_ID,
             BCB.BOM_ITEM_TYPE,
             BCB.ENFORCE_INT_REQUIREMENTS,
             BCB.COMPONENT_ITEM_REVISION_ID,
             BCB.PARENT_BILL_SEQ_ID,
             BCB.AUTO_REQUEST_MATERIAL,
             BCB.PK1_VALUE,
             BCB.PK2_VALUE,
             BCB.PK3_VALUE,
             BCB.PK4_VALUE,
             BCB.PK5_VALUE,
             0,
             BCB.COMPONENT_REMARKS,
             BCB.CHANGE_NOTICE,
             BCB.BASIS_TYPE,
             BCB.LOW_QUANTITY,
             BCB.HIGH_QUANTITY
             from BOM_COMPONENTS_B BCB
             where BCB.COMPONENT_SEQUENCE_ID = component.component_sequence_id
             and BCB.BILL_SEQUENCE_ID = l_bill_seq_id;

            l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                     to_char(component.component_sequence_id)),
                                                                         EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                     to_char(l_bill_seq_id)));
            l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                       to_char(l_new_component_seq_id)),
                                                                          EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                       to_char(l_bill_seq_id)));
            l_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID',
                                                                                    TO_CHAR(l_structure_type_id)));

            l_data_level_pks :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID' , null));


            EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data
               (
                   p_api_version                   => 1.0
                  ,p_application_id                => 702
                  ,p_object_name                   => 'BOM_COMPONENTS'
                  ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
                  ,p_new_pk_col_value_pairs        => l_dest_pk_col_name_val_pairs
                  ,p_old_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_new_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_old_data_level_id             => l_data_level_id
                  ,p_new_data_level_id             => l_data_level_id
                  ,p_new_cc_col_value_pairs        => l_str_type
                  ,x_return_status                 => l_Return_Status
                  ,x_errorcode                     => l_errorcode
                  ,x_msg_count                     => l_msg_count
                  ,x_msg_data                      => l_msg_data
               );

            IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                x_Return_Status := 1;
                x_Error_Message := l_msg_data;
                exit;
            END IF;
        end loop;
    end if;
EXCEPTION
    WHEN others THEN
        x_Return_Status := 1;
        x_Error_Message := 'UnHandled exception while reverting structure components'||sqlerrm(sqlcode);
END Revert_draft_components;

/*
 * This Procedure will create the components for the newly released version of the ICC.
 */
PROCEDURE Release_Components (p_item_catalog_grp_id IN NUMBER,
                              p_version_seq_id      IN NUMBER,
                              p_start_date          IN DATE,
                              x_Return_Status       OUT NOCOPY NUMBER,
                              x_Error_Message       OUT NOCOPY VARCHAR2)
IS
  Cursor get_components(p_bill_seq_id  NUMBER,
                        p_ver_seq_id   NUMBER)
  IS
  SELECT component_sequence_id,
         component_item_id,
         item_num,
         component_quantity,
         component_item_revision_id,
         parent_bill_seq_id,
         pk1_value,
         pk2_value,
         pk3_value,
         component_remarks,
         change_notice,
         quantity_related,
         component_yield_factor,
         enforce_int_requirements,
         include_in_cost_rollup,
         basis_type,
         bom_item_type,
         planning_factor,
         supply_locator_id,
         supply_subinventory,
         auto_request_material,
         wip_supply_type,
         check_atp,
         optional,
         mutually_exclusive_options,
         low_quantity,
         high_quantity,
         so_basis,
         shipping_allowed,
         include_on_ship_docs,
         required_for_revenue,
         required_to_ship,
         pick_components
  from BOM_COMPONENTS_B
  where bill_sequence_id = p_bill_seq_id
  and nvl(parent_bill_seq_id,bill_sequence_id) = bill_sequence_id
  and from_object_revision_id = p_ver_seq_id;

  Cursor parent_catalog is
  select item_catalog_group_id,
         parent_catalog_group_id
  from mtl_item_catalog_groups_b
  connect by prior parent_catalog_group_id = item_catalog_group_id
  start with item_catalog_group_id = p_item_catalog_grp_id;

  type rec_component IS record(
       component_sequence_id       NUMBER,
       component_item_id           NUMBER,
       item_num                    NUMBER,
       component_quantity          NUMBER,
       component_item_revision_id  NUMBER,
       parent_bill_seq_id          NUMBER,
       pk1_value                   VARCHAR2(240),
       pk2_value                   VARCHAR2(240),
       pk3_value                   VARCHAR2(240),
       component_remarks           VARCHAR2(240),
       change_notice               VARCHAR2(10),
       quantity_related            NUMBER,
       component_yield_factor      NUMBER,
       enforce_int_requirements    NUMBER,
       include_in_cost_rollup      NUMBER,
       basis_type                  NUMBER,
       bom_item_type               NUMBER,
       planning_factor             NUMBER,
       supply_locator_id           NUMBER,
       supply_subinventory         VARCHAR2(10),
       auto_request_material       VARCHAR2(1),
       wip_supply_type             NUMBER,
       check_atp                   NUMBER,
       optional                    NUMBER,
       mutually_exclusive_options  NUMBER,
       low_quantity                NUMBER,
       high_quantity               NUMBER,
       so_basis                    NUMBER,
       shipping_allowed            NUMBER,
       include_on_ship_docs        NUMBER,
       required_for_revenue        NUMBER,
       required_to_ship            NUMBER,
       pick_components             NUMBER);

  type t_struct_comp is table of rec_component index by binary_integer;
  v_struct_comp             t_struct_comp;

  type t_component_item is table of number index by binary_integer;
  v_component_item        t_component_item;

  l_counter number;

  l_duplicate_component Number := 0;
  l_default_wip_params Number;
  l_bill_seq_id Number;
  l_parent_catalog_grp_id Number;
  l_parent_bill_seq_id Number;
  l_new_component_seq_id Number;
  l_assembly_type Number;
  l_pk2_value NUMBER;
  l_effectivity_control NUMBER;
  l_alternate_bom_designator VARCHAR2(10);
  l_structure_type_id NUMBER;
  l_par_assembly_type Number;
  l_par_pk2_value NUMBER;
  l_par_effectivity_control NUMBER;
  l_par_alternate_bom_designator VARCHAR2(10);
  l_par_structure_type_id NUMBER;
  l_parent_ver_seq_id Number;

  l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_src_pk_col_name_val_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_str_type                   EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_data_level_pks             EGO_COL_NAME_VALUE_PAIR_ARRAY;
  l_data_level_id              Number;

  l_errorcode Number;
  l_msg_count Number;
  l_msg_data  Varchar2(2000);
  l_Return_Status Varchar2(1) := 'S';

BEGIN

  x_Return_Status := 0;
  x_Error_Message := null;
  l_counter       := 0;

  /* We will create default structure if any ICC in the hierarchy has some structure.*/
  Create_Default_Header(p_item_catalog_grp_id);

  Begin
      SELECT bill_sequence_id,
             assembly_type,
             pk2_value,
             effectivity_control,
             alternate_bom_designator,
             structure_type_id
      INTO   l_bill_seq_id,
             l_assembly_type,
             l_pk2_value,
             l_effectivity_control,
             l_alternate_bom_designator,
             l_structure_type_id
      FROM BOM_STRUCTURES_B
      WHERE pk1_value = p_item_catalog_grp_id
      and obj_name = 'EGO_CATALOG_GROUP';
  Exception
      when others then
          null;
  End;

  If l_bill_seq_id is not null then
    for component in get_components(l_bill_seq_id,0) loop
        l_counter := l_counter+1;
        if v_component_item.exists(component.component_item_id) then
            l_duplicate_component := 1;
            exit;
        end if;
        v_component_item(component.component_item_id)       := component.component_item_id;
        v_struct_comp(l_counter).component_sequence_id      := component.component_sequence_id;
        v_struct_comp(l_counter).component_item_id          := component.component_item_id;
        v_struct_comp(l_counter).item_num                   := component.item_num;
        v_struct_comp(l_counter).component_quantity         := component.component_quantity;
        v_struct_comp(l_counter).component_item_revision_id := component.component_item_revision_id;
        v_struct_comp(l_counter).parent_bill_seq_id         := component.parent_bill_seq_id;
        v_struct_comp(l_counter).pk1_value                  := component.pk1_value;
        v_struct_comp(l_counter).pk2_value                  := component.pk2_value;
        v_struct_comp(l_counter).pk3_value                  := component.pk3_value;
        v_struct_comp(l_counter).component_remarks          := component.component_remarks;
        v_struct_comp(l_counter).change_notice              := component.change_notice;
        v_struct_comp(l_counter).quantity_related           := component.quantity_related;
        v_struct_comp(l_counter).component_yield_factor     := component.component_yield_factor;
        v_struct_comp(l_counter).enforce_int_requirements   := component.enforce_int_requirements;
        v_struct_comp(l_counter).include_in_cost_rollup     := component.include_in_cost_rollup;
        v_struct_comp(l_counter).basis_type                 := component.basis_type;
        v_struct_comp(l_counter).bom_item_type              := component.bom_item_type;
        v_struct_comp(l_counter).planning_factor            := component.planning_factor;
        v_struct_comp(l_counter).supply_locator_id          := component.supply_locator_id;
        v_struct_comp(l_counter).supply_subinventory        := component.supply_subinventory;
        v_struct_comp(l_counter).auto_request_material      := component.auto_request_material;
        v_struct_comp(l_counter).wip_supply_type            := component.wip_supply_type;
        v_struct_comp(l_counter).check_atp                  := component.check_atp;
        v_struct_comp(l_counter).optional                   := component.optional;
        v_struct_comp(l_counter).mutually_exclusive_options := component.mutually_exclusive_options;
        v_struct_comp(l_counter).low_quantity               := component.low_quantity;
        v_struct_comp(l_counter).high_quantity              := component.high_quantity;
        v_struct_comp(l_counter).so_basis                   := component.so_basis;
        v_struct_comp(l_counter).shipping_allowed           := component.shipping_allowed;
        v_struct_comp(l_counter).include_on_ship_docs       := component.include_on_ship_docs;
        v_struct_comp(l_counter).required_for_revenue       := component.required_for_revenue;
        v_struct_comp(l_counter).required_to_ship           := component.required_to_ship;
        v_struct_comp(l_counter).pick_components            := component.pick_components;
    end loop;
    if l_duplicate_component = 0 then
        for catalog in parent_catalog loop
            l_parent_catalog_grp_id := catalog.parent_catalog_group_id;
            if l_parent_catalog_grp_id is not null then
                Begin
                    SELECT bill_sequence_id,
                           assembly_type,
                           pk2_value,
                           effectivity_control,
                           alternate_bom_designator,
                           structure_type_id
                    into   l_parent_bill_seq_id,
                           l_par_assembly_type,
                           l_par_pk2_value,
                           l_par_effectivity_control,
                           l_par_alternate_bom_designator,
                           l_par_structure_type_id
                    FROM BOM_STRUCTURES_B
                    WHERE pk1_value = l_parent_catalog_grp_id
                    and obj_name = 'EGO_CATALOG_GROUP';
                Exception
                    when others then
                        null;
                end;
                l_parent_ver_seq_id := 0;
                if l_parent_bill_seq_id is not null and
                   l_par_assembly_type = l_assembly_type and
                   l_par_pk2_value = l_pk2_value and
                   l_par_effectivity_control = l_effectivity_control and
                   l_par_alternate_bom_designator = l_alternate_bom_designator and
                   l_par_structure_type_id = l_structure_type_id then
                    l_parent_ver_seq_id := get_effective_version(l_parent_catalog_grp_id,p_start_date);
                    if nvl(l_parent_ver_seq_id,0) <> 0 then
                        for component in get_components(l_parent_bill_seq_id,l_parent_ver_seq_id) loop
                            l_counter := l_counter+1;
                            if v_component_item.exists(component.component_item_id) then
                                l_duplicate_component := 1;
                                exit;
                            end if;
                            v_component_item(component.component_item_id)       := component.component_item_id;
                            v_struct_comp(l_counter).component_sequence_id      := component.component_sequence_id;
                            v_struct_comp(l_counter).component_item_id          := component.component_item_id;
                            v_struct_comp(l_counter).item_num                   := component.item_num;
                            v_struct_comp(l_counter).component_quantity         := component.component_quantity;
                            v_struct_comp(l_counter).component_item_revision_id := component.component_item_revision_id;
                            v_struct_comp(l_counter).parent_bill_seq_id         := component.parent_bill_seq_id;
                            v_struct_comp(l_counter).pk1_value                  := component.pk1_value;
                            v_struct_comp(l_counter).pk2_value                  := component.pk2_value;
                            v_struct_comp(l_counter).pk3_value                  := component.pk3_value;
                            v_struct_comp(l_counter).component_remarks          := component.component_remarks;
                            v_struct_comp(l_counter).change_notice              := component.change_notice;
                            v_struct_comp(l_counter).quantity_related           := component.quantity_related;
                            v_struct_comp(l_counter).component_yield_factor     := component.component_yield_factor;
                            v_struct_comp(l_counter).enforce_int_requirements   := component.enforce_int_requirements;
                            v_struct_comp(l_counter).include_in_cost_rollup     := component.include_in_cost_rollup;
                            v_struct_comp(l_counter).basis_type                 := component.basis_type;
                            v_struct_comp(l_counter).bom_item_type              := component.bom_item_type;
                            v_struct_comp(l_counter).planning_factor            := component.planning_factor;
                            v_struct_comp(l_counter).supply_locator_id          := component.supply_locator_id;
                            v_struct_comp(l_counter).supply_subinventory        := component.supply_subinventory;
                            v_struct_comp(l_counter).auto_request_material      := component.auto_request_material;
                            v_struct_comp(l_counter).wip_supply_type            := component.wip_supply_type;
                            v_struct_comp(l_counter).check_atp                  := component.check_atp;
                            v_struct_comp(l_counter).optional                   := component.optional;
                            v_struct_comp(l_counter).mutually_exclusive_options := component.mutually_exclusive_options;
                            v_struct_comp(l_counter).low_quantity               := component.low_quantity;
                            v_struct_comp(l_counter).high_quantity              := component.high_quantity;
                            v_struct_comp(l_counter).so_basis                   := component.so_basis;
                            v_struct_comp(l_counter).shipping_allowed           := component.shipping_allowed;
                            v_struct_comp(l_counter).include_on_ship_docs       := component.include_on_ship_docs;
                            v_struct_comp(l_counter).required_for_revenue       := component.required_for_revenue;
                            v_struct_comp(l_counter).required_to_ship           := component.required_to_ship;
                            v_struct_comp(l_counter).pick_components            := component.pick_components;
                        end loop;
                    end if;
                end if;
            end if;
        end loop;
    end if;
    if l_duplicate_component = 0 then
        l_default_wip_params := fnd_profile.value('BOM:DEFAULT_WIP_VALUES');

        select data_level_id
        into l_data_level_id
        from ego_data_level_b
        where data_level_name = 'COMPONENTS_LEVEL'
        and attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
        and application_id = 702;
        for cntr IN 1..v_struct_comp.COUNT LOOP

            select BOM_INVENTORY_COMPONENTS_S.NEXTVAL
            into l_new_component_seq_id
            from dual;

            Insert into BOM_COMPONENTS_B
            (OPERATION_SEQ_NUM,
             COMPONENT_ITEM_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             ITEM_NUM,
             COMPONENT_QUANTITY,
             COMPONENT_YIELD_FACTOR,
             EFFECTIVITY_DATE,
             IMPLEMENTATION_DATE,
             PLANNING_FACTOR,
             QUANTITY_RELATED,
             SO_BASIS,
             OPTIONAL,
             MUTUALLY_EXCLUSIVE_OPTIONS,
             INCLUDE_IN_COST_ROLLUP,
             CHECK_ATP,
             SHIPPING_ALLOWED,
             REQUIRED_TO_SHIP,
             REQUIRED_FOR_REVENUE,
             INCLUDE_ON_SHIP_DOCS,
             COMPONENT_SEQUENCE_ID,
             BILL_SEQUENCE_ID,
             WIP_SUPPLY_TYPE,
             PICK_COMPONENTS,
             SUPPLY_SUBINVENTORY,
             SUPPLY_LOCATOR_ID,
             BOM_ITEM_TYPE,
             ENFORCE_INT_REQUIREMENTS,
             COMPONENT_ITEM_REVISION_ID,
             PARENT_BILL_SEQ_ID,
             AUTO_REQUEST_MATERIAL,
             PK1_VALUE,
             PK2_VALUE,
             PK3_VALUE,
             FROM_OBJECT_REVISION_ID,
             COMPONENT_REMARKS,
             CHANGE_NOTICE,
             BASIS_TYPE,
             LOW_QUANTITY,
             HIGH_QUANTITY)
            values(
             1,
             v_struct_comp(cntr).component_item_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             v_struct_comp(cntr).item_num,
             v_struct_comp(cntr).component_quantity,
             v_struct_comp(cntr).component_yield_factor,
             sysdate,
             sysdate,
             v_struct_comp(cntr).planning_factor,
             v_struct_comp(cntr).quantity_related,
             v_struct_comp(cntr).so_basis,
             v_struct_comp(cntr).optional,
             v_struct_comp(cntr).mutually_exclusive_options,
             v_struct_comp(cntr).include_in_cost_rollup,
             v_struct_comp(cntr).check_atp,
             v_struct_comp(cntr).shipping_allowed,
             v_struct_comp(cntr).required_to_ship,
             v_struct_comp(cntr).required_for_revenue,
             v_struct_comp(cntr).include_on_ship_docs,
             l_new_component_seq_id,
             l_bill_seq_id,
             v_struct_comp(cntr).wip_supply_type,
             v_struct_comp(cntr).pick_components,
             v_struct_comp(cntr).supply_subinventory,
             v_struct_comp(cntr).supply_locator_id,
             v_struct_comp(cntr).bom_item_type,
             v_struct_comp(cntr).enforce_int_requirements,
             v_struct_comp(cntr).component_item_revision_id,
             decode(v_struct_comp(cntr).parent_bill_seq_id,null,l_bill_seq_id,v_struct_comp(cntr).parent_bill_seq_id),
             v_struct_comp(cntr).auto_request_material,
             v_struct_comp(cntr).pk1_value,
             v_struct_comp(cntr).pk2_value,
             v_struct_comp(cntr).component_item_revision_id,
             p_version_seq_id,
             v_struct_comp(cntr).component_remarks,
             v_struct_comp(cntr).change_notice,
             v_struct_comp(cntr).basis_type,
             v_struct_comp(cntr).low_quantity,
             v_struct_comp(cntr).high_quantity);
/*           from mtl_system_items msi
             where inventory_item_id = v_struct_comp(cntr).component_item_id
             and organization_id = v_struct_comp(cntr).pk2_value;  */

           l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                      to_char(v_struct_comp(cntr).component_sequence_id)),
                                                                        EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                      to_char(nvl(v_struct_comp(cntr).parent_bill_seq_id,l_bill_seq_id))));
           l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                      to_char(l_new_component_seq_id)),
                                                                         EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                      to_char(l_bill_seq_id)));
           l_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID',
                                                                                     TO_CHAR(l_structure_type_id)));
           l_data_level_pks :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID' , null));

           EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data
               (
                   p_api_version                   => 1.0
                  ,p_application_id                => 702
                  ,p_object_name                   => 'BOM_COMPONENTS'
                  ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
                  ,p_new_pk_col_value_pairs        => l_dest_pk_col_name_val_pairs
                  ,p_old_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_new_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_old_data_level_id             => l_data_level_id
                  ,p_new_data_level_id             => l_data_level_id
                  ,p_new_cc_col_value_pairs        => l_str_type
                  ,x_return_status                 => l_Return_Status
                  ,x_errorcode                     => l_errorcode
                  ,x_msg_count                     => l_msg_count
                  ,x_msg_data                      => l_msg_data
               );

            IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                x_Return_Status := 1;
                x_Error_Message := l_msg_data;
                exit;
            END IF;
        end loop;
    else
        x_Return_Status := 1;
        fnd_message.set_name('EGO','EGO_DUP_ICC_COMPONENTS_REL');
        x_Error_Message := fnd_message.get;
    end if;
  end if;
EXCEPTION
  WHEN others THEN
      x_Return_Status := 1;
      x_Error_Message := 'UnHandled Exception during Structure Processing'||sqlerrm(sqlcode);
END Release_Components;

/*
 * This Procedure will get the ICC Name for a given Bill Seq Id.
 */
Function   getIccName(p_item_catalog_grp_id IN NUMBER,
                      p_parent_bill_seq_id  IN NUMBER)
RETURN VARCHAR2
IS
l_item_catalog_grp_name VARCHAR2(819) := NULL;
l_item_catalog_grp_id Number ;
BEGIN

    if p_parent_bill_seq_id is null then
        select concatenated_segments
        into l_item_catalog_grp_name
        from MTL_ITEM_CATALOG_GROUPS_B_KFV
        where item_catalog_group_id = p_item_catalog_grp_id;
    else
        select pk1_value
        into l_item_catalog_grp_id
        from BOM_STRUCTURES_B
        where bill_sequence_id = p_parent_bill_seq_id
        and obj_name= 'EGO_CATALOG_GROUP';

        select concatenated_segments
        into l_item_catalog_grp_name
        from MTL_ITEM_CATALOG_GROUPS_B_KFV
        where item_catalog_group_id = l_item_catalog_grp_id;
    end if;

    return l_item_catalog_grp_name;
EXCEPTION
    WHEN others THEN
        return null;
END getIccName;

/*
 * This Procedure will get the effective version of a ICC for a given date.
 */
Function   Get_Effective_Version(p_item_catalog_grp_id IN NUMBER,
                                 p_start_date          IN DATE)
RETURN NUMBER
IS
l_effective_version NUMBER := NULL;
BEGIN
    select version_seq_id
    into l_effective_version
    from EGO_MTL_CATALOG_GRP_VERS_B
    where item_catalog_group_id = p_item_catalog_grp_id
    and version_seq_id <> 0
    and nvl(p_start_date,sysdate) between start_active_date and nvl(end_active_date,nvl(p_start_date,sysdate+1));

    return l_effective_version;
EXCEPTION
    WHEN OTHERS THEN
        return null;
END Get_Effective_Version;

/*
 * This Procedure will get the effective version of a Parent ICC for a given date.
 */
Function   Get_Parent_Version(p_item_catalog_grp_id IN NUMBER,
                              p_start_date          IN DATE)
RETURN NUMBER
IS
l_effective_version NUMBER := NULL;
l_parent_catalog_grp_id NUMBER;
BEGIN
    SELECT parent_catalog_group_id
    into l_parent_catalog_grp_id
    FROM MTL_ITEM_CATALOG_GROUPS_B
    WHERE item_catalog_group_id = p_item_catalog_grp_id;

    if l_parent_catalog_grp_id is not null then
        l_effective_version := Get_Effective_Version(l_parent_catalog_grp_id,p_start_date);
    end if;
    return l_effective_version;
EXCEPTION
    WHEN OTHERS THEN
        return null;
END Get_Parent_Version;

/*
 * This Procedure will give whether Draft version has been updated or not.
 */
Function  Is_Structure_Updated(p_item_catalog_grp_id IN NUMBER,
                               p_start_date          IN DATE)
RETURN NUMBER
IS

    Cursor get_components(p_bill_seq_id  NUMBER,
                          p_ver_seq_id   NUMBER)
    IS
    SELECT component_sequence_id,
           component_item_id,
           item_num,
           component_quantity,
           component_item_revision_id,
           parent_bill_seq_id,
           pk1_value,
           pk2_value,
           pk3_value,
           component_remarks,
           change_notice,
           quantity_related,
           component_yield_factor,
           enforce_int_requirements,
           include_in_cost_rollup,
           basis_type,
           bom_item_type,
           planning_factor,
           supply_locator_id,
           supply_subinventory,
           auto_request_material,
           wip_supply_type,
           check_atp,
           optional,
           mutually_exclusive_options,
           low_quantity,
           high_quantity,
           so_basis,
           shipping_allowed,
           include_on_ship_docs,
           required_for_revenue,
           required_to_ship
    from BOM_COMPONENTS_B
    where bill_sequence_id = p_bill_seq_id
    and nvl(parent_bill_seq_id,bill_sequence_id) = bill_sequence_id
    and from_object_revision_id = p_ver_seq_id;

    Cursor get_released_components(p_bill_seq_id  NUMBER,
                                   p_ver_seq_id   NUMBER)
    IS
    SELECT component_sequence_id,
           component_item_id,
           item_num,
           component_quantity,
           component_item_revision_id,
           parent_bill_seq_id,
           pk1_value,
           pk2_value,
           pk3_value,
           component_remarks,
           change_notice,
           quantity_related,
           component_yield_factor,
           enforce_int_requirements,
           include_in_cost_rollup,
           basis_type,
           bom_item_type,
           planning_factor,
           supply_locator_id,
           supply_subinventory,
           auto_request_material,
           wip_supply_type,
           check_atp,
           optional,
           mutually_exclusive_options,
           low_quantity,
           high_quantity,
           so_basis,
           shipping_allowed,
           include_on_ship_docs,
           required_for_revenue,
           required_to_ship
    from BOM_COMPONENTS_B
    where bill_sequence_id = p_bill_seq_id
    and from_object_revision_id = p_ver_seq_id;

    Cursor parent_catalog
    is
    select item_catalog_group_id,
           parent_catalog_group_id
    from mtl_item_catalog_groups_b
    connect by prior parent_catalog_group_id = item_catalog_group_id
    start with item_catalog_group_id = p_item_catalog_grp_id;

    type rec_component IS record(
         component_sequence_id       NUMBER,
         component_item_id           NUMBER,
         item_num                    NUMBER,
         component_quantity          NUMBER,
         component_item_revision_id  NUMBER,
         parent_bill_seq_id          NUMBER,
         pk1_value                   VARCHAR2(240),
         pk2_value                   VARCHAR2(240),
         pk3_value                   VARCHAR2(240),
         component_remarks           VARCHAR2(240),
         change_notice               VARCHAR2(10),
         quantity_related            NUMBER,
         component_yield_factor      NUMBER,
         enforce_int_requirements    NUMBER,
         include_in_cost_rollup      NUMBER,
         basis_type                  NUMBER,
         bom_item_type               NUMBER,
         planning_factor             NUMBER,
         supply_locator_id           NUMBER,
         supply_subinventory         VARCHAR2(10),
         auto_request_material       VARCHAR2(1),
         wip_supply_type             NUMBER,
         check_atp                   NUMBER,
         optional                    NUMBER,
         mutually_exclusive_options  NUMBER,
         low_quantity                NUMBER,
         high_quantity               NUMBER,
         so_basis                    NUMBER,
         shipping_allowed            NUMBER,
         include_on_ship_docs        NUMBER,
         required_for_revenue        NUMBER,
         required_to_ship            NUMBER);

    type t_struct_comp is table of rec_component index by binary_integer;
    v_draft_struct_comp                t_struct_comp;
    v_released_struct_comp             t_struct_comp;

    type t_component_item is table of number index by binary_integer;
    v_component_item        t_component_item;

    l_counter number;

    l_updated Number;
    l_bill_seq_id Number;
    l_effective_version Number;
    l_parent_ver_seq_id Number;
    l_parent_catalog_grp_id Number;
    l_assembly_type Number;
    l_pk2_value NUMBER;
    l_effectivity_control NUMBER;
    l_alternate_bom_designator VARCHAR2(10);
    l_structure_type_id NUMBER;
    l_parent_bill_seq_id Number;
    l_par_assembly_type Number;
    l_par_pk2_value Number;
    l_par_effectivity_control Number;
    l_par_alternate_bom_designator Varchar2(10);
    l_par_structure_type_id Number;
    l_draft_index Number;

BEGIN

    l_updated := 0;
    l_effective_version := Get_Effective_Version(p_item_catalog_grp_id,p_start_date);
    l_counter       := 0;

    /* Allow releasing empty initial version for ICC. */
    if nvl(l_effective_version,0) = 0 then
        l_updated := 1;
    else
        Begin
            SELECT bill_sequence_id,
                   assembly_type,
                   pk2_value,
                   effectivity_control,
                   alternate_bom_designator,
                   structure_type_id
            INTO   l_bill_seq_id,
                   l_assembly_type,
                   l_pk2_value,
                   l_effectivity_control,
                   l_alternate_bom_designator,
                   l_structure_type_id
            FROM BOM_STRUCTURES_B
            WHERE pk1_value = p_item_catalog_grp_id
            and obj_name = 'EGO_CATALOG_GROUP';
        Exception
            when others then
                null;
        End;
        If l_bill_seq_id is not null then
            for component in get_components(l_bill_seq_id,0) loop
                l_counter := l_counter+1;
                v_component_item(component.component_item_id)             := l_counter;
                v_draft_struct_comp(l_counter).component_sequence_id      := component.component_sequence_id;
                v_draft_struct_comp(l_counter).component_item_id          := component.component_item_id;
                v_draft_struct_comp(l_counter).item_num                   := component.item_num;
                v_draft_struct_comp(l_counter).component_quantity         := component.component_quantity;
                v_draft_struct_comp(l_counter).component_item_revision_id := component.component_item_revision_id;
                v_draft_struct_comp(l_counter).parent_bill_seq_id         := component.parent_bill_seq_id;
                v_draft_struct_comp(l_counter).pk1_value                  := component.pk1_value;
                v_draft_struct_comp(l_counter).pk2_value                  := component.pk2_value;
                v_draft_struct_comp(l_counter).pk3_value                  := component.pk3_value;
                v_draft_struct_comp(l_counter).component_remarks          := component.component_remarks;
                v_draft_struct_comp(l_counter).change_notice              := component.change_notice;
                v_draft_struct_comp(l_counter).quantity_related           := component.quantity_related;
                v_draft_struct_comp(l_counter).component_yield_factor     := component.component_yield_factor;
                v_draft_struct_comp(l_counter).enforce_int_requirements   := component.enforce_int_requirements;
                v_draft_struct_comp(l_counter).include_in_cost_rollup     := component.include_in_cost_rollup;
                v_draft_struct_comp(l_counter).basis_type                 := component.basis_type;
                v_draft_struct_comp(l_counter).bom_item_type              := component.bom_item_type;
                v_draft_struct_comp(l_counter).planning_factor            := component.planning_factor;
                v_draft_struct_comp(l_counter).supply_locator_id          := component.supply_locator_id;
                v_draft_struct_comp(l_counter).supply_subinventory        := component.supply_subinventory;
                v_draft_struct_comp(l_counter).auto_request_material      := component.auto_request_material;
                v_draft_struct_comp(l_counter).wip_supply_type            := component.wip_supply_type;
                v_draft_struct_comp(l_counter).check_atp                  := component.check_atp;
                v_draft_struct_comp(l_counter).optional                   := component.optional;
                v_draft_struct_comp(l_counter).mutually_exclusive_options := component.mutually_exclusive_options;
                v_draft_struct_comp(l_counter).low_quantity               := component.low_quantity;
                v_draft_struct_comp(l_counter).high_quantity              := component.high_quantity;
                v_draft_struct_comp(l_counter).so_basis                   := component.so_basis;
                v_draft_struct_comp(l_counter).shipping_allowed           := component.shipping_allowed;
                v_draft_struct_comp(l_counter).include_on_ship_docs       := component.include_on_ship_docs;
                v_draft_struct_comp(l_counter).required_for_revenue       := component.required_for_revenue;
                v_draft_struct_comp(l_counter).required_to_ship           := component.required_to_ship;
            end loop;
            for catalog in parent_catalog loop
                l_parent_catalog_grp_id := catalog.parent_catalog_group_id;
                if l_parent_catalog_grp_id is not null then
                    Begin
                        SELECT bill_sequence_id,
                               assembly_type,
                               pk2_value,
                               effectivity_control,
                               alternate_bom_designator,
                               structure_type_id
                        into   l_parent_bill_seq_id,
                               l_par_assembly_type,
                               l_par_pk2_value,
                               l_par_effectivity_control,
                               l_par_alternate_bom_designator,
                               l_par_structure_type_id
                        FROM BOM_STRUCTURES_B
                        WHERE pk1_value = l_parent_catalog_grp_id
                        and obj_name = 'EGO_CATALOG_GROUP';
                    Exception
                        when others then
                            null;
                    end;
                    l_parent_ver_seq_id := 0;
                    if l_parent_bill_seq_id is not null and
                       l_par_assembly_type = l_assembly_type and
                       l_par_pk2_value = l_pk2_value and
                       l_par_effectivity_control = l_effectivity_control and
                       l_par_alternate_bom_designator = l_alternate_bom_designator and
                       l_par_structure_type_id = l_structure_type_id then
                        l_parent_ver_seq_id := get_effective_version(l_parent_catalog_grp_id,p_start_date);
                        if nvl(l_parent_ver_seq_id,0) <> 0 then
                            for component in get_components(l_parent_bill_seq_id,l_parent_ver_seq_id) loop
                                l_counter := l_counter+1;
                                v_component_item(component.component_item_id)             := l_counter;
                                v_draft_struct_comp(l_counter).component_sequence_id      := component.component_sequence_id;
                                v_draft_struct_comp(l_counter).component_item_id          := component.component_item_id;
                                v_draft_struct_comp(l_counter).item_num                   := component.item_num;
                                v_draft_struct_comp(l_counter).component_quantity         := component.component_quantity;
                                v_draft_struct_comp(l_counter).component_item_revision_id := component.component_item_revision_id;
                                v_draft_struct_comp(l_counter).parent_bill_seq_id         := component.parent_bill_seq_id;
                                v_draft_struct_comp(l_counter).pk1_value                  := component.pk1_value;
                                v_draft_struct_comp(l_counter).pk2_value                  := component.pk2_value;
                                v_draft_struct_comp(l_counter).pk3_value                  := component.pk3_value;
                                v_draft_struct_comp(l_counter).component_remarks          := component.component_remarks;
                                v_draft_struct_comp(l_counter).change_notice              := component.change_notice;
                                v_draft_struct_comp(l_counter).quantity_related           := component.quantity_related;
                                v_draft_struct_comp(l_counter).component_yield_factor     := component.component_yield_factor;
                                v_draft_struct_comp(l_counter).enforce_int_requirements   := component.enforce_int_requirements;
                                v_draft_struct_comp(l_counter).include_in_cost_rollup     := component.include_in_cost_rollup;
                                v_draft_struct_comp(l_counter).basis_type                 := component.basis_type;
                                v_draft_struct_comp(l_counter).bom_item_type              := component.bom_item_type;
                                v_draft_struct_comp(l_counter).planning_factor            := component.planning_factor;
                                v_draft_struct_comp(l_counter).supply_locator_id          := component.supply_locator_id;
                                v_draft_struct_comp(l_counter).supply_subinventory        := component.supply_subinventory;
                                v_draft_struct_comp(l_counter).auto_request_material      := component.auto_request_material;
                                v_draft_struct_comp(l_counter).wip_supply_type            := component.wip_supply_type;
                                v_draft_struct_comp(l_counter).check_atp                  := component.check_atp;
                                v_draft_struct_comp(l_counter).optional                   := component.optional;
                                v_draft_struct_comp(l_counter).mutually_exclusive_options := component.mutually_exclusive_options;
                                v_draft_struct_comp(l_counter).low_quantity               := component.low_quantity;
                                v_draft_struct_comp(l_counter).high_quantity              := component.high_quantity;
                                v_draft_struct_comp(l_counter).so_basis                   := component.so_basis;
                                v_draft_struct_comp(l_counter).shipping_allowed           := component.shipping_allowed;
                                v_draft_struct_comp(l_counter).include_on_ship_docs       := component.include_on_ship_docs;
                                v_draft_struct_comp(l_counter).required_for_revenue       := component.required_for_revenue;
                                v_draft_struct_comp(l_counter).required_to_ship           := component.required_to_ship;
                            end loop;
                        end if;
                    end if;
                end if;
            end loop;
            l_counter       := 0;
            for component in get_released_components(l_bill_seq_id,l_effective_version) loop
                l_counter := l_counter+1;
                v_released_struct_comp(l_counter).component_sequence_id      := component.component_sequence_id;
                v_released_struct_comp(l_counter).component_item_id          := component.component_item_id;
                v_released_struct_comp(l_counter).item_num                   := component.item_num;
                v_released_struct_comp(l_counter).component_quantity         := component.component_quantity;
                v_released_struct_comp(l_counter).component_item_revision_id := component.component_item_revision_id;
                v_released_struct_comp(l_counter).parent_bill_seq_id         := component.parent_bill_seq_id;
                v_released_struct_comp(l_counter).pk1_value                  := component.pk1_value;
                v_released_struct_comp(l_counter).pk2_value                  := component.pk2_value;
                v_released_struct_comp(l_counter).pk3_value                  := component.pk3_value;
                v_released_struct_comp(l_counter).component_remarks          := component.component_remarks;
                v_released_struct_comp(l_counter).change_notice              := component.change_notice;
                v_released_struct_comp(l_counter).quantity_related           := component.quantity_related;
                v_released_struct_comp(l_counter).component_yield_factor     := component.component_yield_factor;
                v_released_struct_comp(l_counter).enforce_int_requirements   := component.enforce_int_requirements;
                v_released_struct_comp(l_counter).include_in_cost_rollup     := component.include_in_cost_rollup;
                v_released_struct_comp(l_counter).basis_type                 := component.basis_type;
                v_released_struct_comp(l_counter).bom_item_type              := component.bom_item_type;
                v_released_struct_comp(l_counter).planning_factor            := component.planning_factor;
                v_released_struct_comp(l_counter).supply_locator_id          := component.supply_locator_id;
                v_released_struct_comp(l_counter).supply_subinventory        := component.supply_subinventory;
                v_released_struct_comp(l_counter).auto_request_material      := component.auto_request_material;
                v_released_struct_comp(l_counter).wip_supply_type            := component.wip_supply_type;
                v_released_struct_comp(l_counter).check_atp                  := component.check_atp;
                v_released_struct_comp(l_counter).optional                   := component.optional;
                v_released_struct_comp(l_counter).mutually_exclusive_options := component.mutually_exclusive_options;
                v_released_struct_comp(l_counter).low_quantity               := component.low_quantity;
                v_released_struct_comp(l_counter).high_quantity              := component.high_quantity;
                v_released_struct_comp(l_counter).so_basis                   := component.so_basis;
                v_released_struct_comp(l_counter).shipping_allowed           := component.shipping_allowed;
                v_released_struct_comp(l_counter).include_on_ship_docs       := component.include_on_ship_docs;
                v_released_struct_comp(l_counter).required_for_revenue       := component.required_for_revenue;
                v_released_struct_comp(l_counter).required_to_ship           := component.required_to_ship;
            end loop;
            if v_released_struct_comp.COUNT <> v_draft_struct_comp.COUNT and
               v_released_struct_comp.COUNT <> v_component_item.COUNT then
                l_updated := 1;
            else
                for cntr IN 1..v_released_struct_comp.COUNT LOOP
                    begin
                        l_draft_index := v_component_item(v_released_struct_comp(cntr).component_item_id);
                        if v_released_struct_comp(cntr).component_item_id <> v_draft_struct_comp(l_draft_index).component_item_id or
                           v_released_struct_comp(cntr).item_num <> v_draft_struct_comp(l_draft_index).item_num or
                           v_released_struct_comp(cntr).component_item_revision_id <> v_draft_struct_comp(l_draft_index).component_item_revision_id or
                           v_released_struct_comp(cntr).component_quantity <> v_draft_struct_comp(l_draft_index).component_quantity or
                           v_released_struct_comp(cntr).component_remarks <> v_draft_struct_comp(l_draft_index).component_remarks or
                           v_released_struct_comp(cntr).change_notice <> v_draft_struct_comp(l_draft_index).change_notice or
                           v_released_struct_comp(cntr).quantity_related <> v_draft_struct_comp(l_draft_index).quantity_related or
                           v_released_struct_comp(cntr).component_yield_factor <> v_draft_struct_comp(l_draft_index).component_yield_factor or
                           v_released_struct_comp(cntr).enforce_int_requirements <> v_draft_struct_comp(l_draft_index).enforce_int_requirements or
                           v_released_struct_comp(cntr).include_in_cost_rollup <> v_draft_struct_comp(l_draft_index).include_in_cost_rollup or
                           v_released_struct_comp(cntr).basis_type <> v_draft_struct_comp(l_draft_index).basis_type or
                           v_released_struct_comp(cntr).bom_item_type <> v_draft_struct_comp(l_draft_index).bom_item_type or
                           v_released_struct_comp(cntr).planning_factor <> v_draft_struct_comp(l_draft_index).planning_factor or
                           v_released_struct_comp(cntr).supply_locator_id <> v_draft_struct_comp(l_draft_index).supply_locator_id or
                           v_released_struct_comp(cntr).supply_subinventory <> v_draft_struct_comp(l_draft_index).supply_subinventory or
                           v_released_struct_comp(cntr).auto_request_material <> v_draft_struct_comp(l_draft_index).auto_request_material or
                           v_released_struct_comp(cntr).wip_supply_type <> v_draft_struct_comp(l_draft_index).wip_supply_type or
                           v_released_struct_comp(cntr).check_atp <> v_draft_struct_comp(l_draft_index).check_atp or
                           v_released_struct_comp(cntr).optional <> v_draft_struct_comp(l_draft_index).optional or
                           v_released_struct_comp(cntr).mutually_exclusive_options <> v_draft_struct_comp(l_draft_index).mutually_exclusive_options or
                           v_released_struct_comp(cntr).low_quantity <> v_draft_struct_comp(l_draft_index).low_quantity or
                           v_released_struct_comp(cntr).high_quantity <> v_draft_struct_comp(l_draft_index).high_quantity or
                           v_released_struct_comp(cntr).so_basis <> v_draft_struct_comp(l_draft_index).so_basis or
                           v_released_struct_comp(cntr).shipping_allowed <> v_draft_struct_comp(l_draft_index).shipping_allowed or
                           v_released_struct_comp(cntr).include_on_ship_docs <> v_draft_struct_comp(l_draft_index).include_on_ship_docs or
                           v_released_struct_comp(cntr).required_for_revenue <> v_draft_struct_comp(l_draft_index).required_for_revenue or
                           v_released_struct_comp(cntr).required_to_ship <> v_draft_struct_comp(l_draft_index).required_to_ship
                        then
                            l_updated := 1;
                            exit;
                        end if;
                        l_updated := compare_uda_values(v_released_struct_comp(cntr).component_sequence_id,
                                                        v_draft_struct_comp(l_draft_index).component_sequence_id);
                        if l_updated <> 0 then
                            exit;
                        end if;
                    exception
                        when others then
                            l_updated := 1;
                            exit;
                    end;
                end loop;
            end if;
        end if;
    end if;
return l_updated;
EXCEPTION
    WHEN OTHERS THEN
        return 0;
END Is_Structure_Updated;

/*
 * This Procedure will compare UDA values for two different components and gives whether they are same or different.
 */

Function Compare_UDA_Values(p_draft_comp_seq_id    IN NUMBER,
                            p_released_comp_seq_id IN NUMBER)
RETURN NUMBER
IS
l_updated Number;
l_data_level_id Number;
BEGIN
    l_updated := 0;

    /* UT Fix: Should not consider Component Override attributes. */
    select data_level_id
    into l_data_level_id
    from ego_data_level_b
    where data_level_name = 'COMPONENTS_LEVEL'
    and attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
    and application_id = 702;

    select 1
    into l_updated
    from dual
    where exists(
        ((select
        ATTR_GROUP_ID,
        C_EXT_ATTR1,C_EXT_ATTR2,C_EXT_ATTR3,C_EXT_ATTR4,C_EXT_ATTR5,C_EXT_ATTR6,C_EXT_ATTR7,C_EXT_ATTR8,C_EXT_ATTR9,C_EXT_ATTR10,
        C_EXT_ATTR11,C_EXT_ATTR12,C_EXT_ATTR13,C_EXT_ATTR14,C_EXT_ATTR15,C_EXT_ATTR16,C_EXT_ATTR17,C_EXT_ATTR18,C_EXT_ATTR19,C_EXT_ATTR20,
        C_EXT_ATTR21,C_EXT_ATTR22,C_EXT_ATTR23,C_EXT_ATTR24,C_EXT_ATTR25,C_EXT_ATTR26,C_EXT_ATTR27,C_EXT_ATTR28,C_EXT_ATTR29,C_EXT_ATTR30,
        C_EXT_ATTR31,C_EXT_ATTR32,C_EXT_ATTR33,C_EXT_ATTR34,C_EXT_ATTR35,C_EXT_ATTR36,C_EXT_ATTR37,C_EXT_ATTR38,C_EXT_ATTR39,C_EXT_ATTR40,
        N_EXT_ATTR1,N_EXT_ATTR2,N_EXT_ATTR3,N_EXT_ATTR4,N_EXT_ATTR5,N_EXT_ATTR6,N_EXT_ATTR7,N_EXT_ATTR8,N_EXT_ATTR9,N_EXT_ATTR10,
        N_EXT_ATTR11,N_EXT_ATTR12,N_EXT_ATTR13,N_EXT_ATTR14,N_EXT_ATTR15,N_EXT_ATTR16,N_EXT_ATTR17,N_EXT_ATTR18,N_EXT_ATTR19,N_EXT_ATTR20,
        D_EXT_ATTR1,D_EXT_ATTR2,D_EXT_ATTR3,D_EXT_ATTR4,D_EXT_ATTR5,D_EXT_ATTR6,D_EXT_ATTR7,D_EXT_ATTR8,D_EXT_ATTR9,D_EXT_ATTR10,
        UOM_EXT_ATTR1,UOM_EXT_ATTR2,UOM_EXT_ATTR3,UOM_EXT_ATTR4,UOM_EXT_ATTR5,UOM_EXT_ATTR6,UOM_EXT_ATTR7,UOM_EXT_ATTR8,UOM_EXT_ATTR9,UOM_EXT_ATTR10,
        UOM_EXT_ATTR11,UOM_EXT_ATTR12,UOM_EXT_ATTR13,UOM_EXT_ATTR14,UOM_EXT_ATTR15,UOM_EXT_ATTR16,UOM_EXT_ATTR17,UOM_EXT_ATTR18,UOM_EXT_ATTR19,UOM_EXT_ATTR20
        from bom_components_ext_b
        where data_level_id = l_data_level_id and COMPONENT_SEQUENCE_ID = p_draft_comp_seq_id)
        minus
        (select
        ATTR_GROUP_ID,
        C_EXT_ATTR1,C_EXT_ATTR2,C_EXT_ATTR3,C_EXT_ATTR4,C_EXT_ATTR5,C_EXT_ATTR6,C_EXT_ATTR7,C_EXT_ATTR8,C_EXT_ATTR9,C_EXT_ATTR10,
        C_EXT_ATTR11,C_EXT_ATTR12,C_EXT_ATTR13,C_EXT_ATTR14,C_EXT_ATTR15,C_EXT_ATTR16,C_EXT_ATTR17,C_EXT_ATTR18,C_EXT_ATTR19,C_EXT_ATTR20,
        C_EXT_ATTR21,C_EXT_ATTR22,C_EXT_ATTR23,C_EXT_ATTR24,C_EXT_ATTR25,C_EXT_ATTR26,C_EXT_ATTR27,C_EXT_ATTR28,C_EXT_ATTR29,C_EXT_ATTR30,
        C_EXT_ATTR31,C_EXT_ATTR32,C_EXT_ATTR33,C_EXT_ATTR34,C_EXT_ATTR35,C_EXT_ATTR36,C_EXT_ATTR37,C_EXT_ATTR38,C_EXT_ATTR39,C_EXT_ATTR40,
        N_EXT_ATTR1,N_EXT_ATTR2,N_EXT_ATTR3,N_EXT_ATTR4,N_EXT_ATTR5,N_EXT_ATTR6,N_EXT_ATTR7,N_EXT_ATTR8,N_EXT_ATTR9,N_EXT_ATTR10,
        N_EXT_ATTR11,N_EXT_ATTR12,N_EXT_ATTR13,N_EXT_ATTR14,N_EXT_ATTR15,N_EXT_ATTR16,N_EXT_ATTR17,N_EXT_ATTR18,N_EXT_ATTR19,N_EXT_ATTR20,
        D_EXT_ATTR1,D_EXT_ATTR2,D_EXT_ATTR3,D_EXT_ATTR4,D_EXT_ATTR5,D_EXT_ATTR6,D_EXT_ATTR7,D_EXT_ATTR8,D_EXT_ATTR9,D_EXT_ATTR10,
        UOM_EXT_ATTR1,UOM_EXT_ATTR2,UOM_EXT_ATTR3,UOM_EXT_ATTR4,UOM_EXT_ATTR5,UOM_EXT_ATTR6,UOM_EXT_ATTR7,UOM_EXT_ATTR8,UOM_EXT_ATTR9,UOM_EXT_ATTR10,
        UOM_EXT_ATTR11,UOM_EXT_ATTR12,UOM_EXT_ATTR13,UOM_EXT_ATTR14,UOM_EXT_ATTR15,UOM_EXT_ATTR16,UOM_EXT_ATTR17,UOM_EXT_ATTR18,UOM_EXT_ATTR19,UOM_EXT_ATTR20
        from bom_components_ext_b
        where data_level_id = l_data_level_id and COMPONENT_SEQUENCE_ID = p_released_comp_seq_id))
        union
        ((select
        ATTR_GROUP_ID,
        C_EXT_ATTR1,C_EXT_ATTR2,C_EXT_ATTR3,C_EXT_ATTR4,C_EXT_ATTR5,C_EXT_ATTR6,C_EXT_ATTR7,C_EXT_ATTR8,C_EXT_ATTR9,C_EXT_ATTR10,
        C_EXT_ATTR11,C_EXT_ATTR12,C_EXT_ATTR13,C_EXT_ATTR14,C_EXT_ATTR15,C_EXT_ATTR16,C_EXT_ATTR17,C_EXT_ATTR18,C_EXT_ATTR19,C_EXT_ATTR20,
        C_EXT_ATTR21,C_EXT_ATTR22,C_EXT_ATTR23,C_EXT_ATTR24,C_EXT_ATTR25,C_EXT_ATTR26,C_EXT_ATTR27,C_EXT_ATTR28,C_EXT_ATTR29,C_EXT_ATTR30,
        C_EXT_ATTR31,C_EXT_ATTR32,C_EXT_ATTR33,C_EXT_ATTR34,C_EXT_ATTR35,C_EXT_ATTR36,C_EXT_ATTR37,C_EXT_ATTR38,C_EXT_ATTR39,C_EXT_ATTR40,
        N_EXT_ATTR1,N_EXT_ATTR2,N_EXT_ATTR3,N_EXT_ATTR4,N_EXT_ATTR5,N_EXT_ATTR6,N_EXT_ATTR7,N_EXT_ATTR8,N_EXT_ATTR9,N_EXT_ATTR10,
        N_EXT_ATTR11,N_EXT_ATTR12,N_EXT_ATTR13,N_EXT_ATTR14,N_EXT_ATTR15,N_EXT_ATTR16,N_EXT_ATTR17,N_EXT_ATTR18,N_EXT_ATTR19,N_EXT_ATTR20,
        D_EXT_ATTR1,D_EXT_ATTR2,D_EXT_ATTR3,D_EXT_ATTR4,D_EXT_ATTR5,D_EXT_ATTR6,D_EXT_ATTR7,D_EXT_ATTR8,D_EXT_ATTR9,D_EXT_ATTR10,
        UOM_EXT_ATTR1,UOM_EXT_ATTR2,UOM_EXT_ATTR3,UOM_EXT_ATTR4,UOM_EXT_ATTR5,UOM_EXT_ATTR6,UOM_EXT_ATTR7,UOM_EXT_ATTR8,UOM_EXT_ATTR9,UOM_EXT_ATTR10,
        UOM_EXT_ATTR11,UOM_EXT_ATTR12,UOM_EXT_ATTR13,UOM_EXT_ATTR14,UOM_EXT_ATTR15,UOM_EXT_ATTR16,UOM_EXT_ATTR17,UOM_EXT_ATTR18,UOM_EXT_ATTR19,UOM_EXT_ATTR20
        from bom_components_ext_b
        where data_level_id = l_data_level_id and COMPONENT_SEQUENCE_ID = p_released_comp_seq_id)
        minus
        (select
        ATTR_GROUP_ID,
        C_EXT_ATTR1,C_EXT_ATTR2,C_EXT_ATTR3,C_EXT_ATTR4,C_EXT_ATTR5,C_EXT_ATTR6,C_EXT_ATTR7,C_EXT_ATTR8,C_EXT_ATTR9,C_EXT_ATTR10,
        C_EXT_ATTR11,C_EXT_ATTR12,C_EXT_ATTR13,C_EXT_ATTR14,C_EXT_ATTR15,C_EXT_ATTR16,C_EXT_ATTR17,C_EXT_ATTR18,C_EXT_ATTR19,C_EXT_ATTR20,
        C_EXT_ATTR21,C_EXT_ATTR22,C_EXT_ATTR23,C_EXT_ATTR24,C_EXT_ATTR25,C_EXT_ATTR26,C_EXT_ATTR27,C_EXT_ATTR28,C_EXT_ATTR29,C_EXT_ATTR30,
        C_EXT_ATTR31,C_EXT_ATTR32,C_EXT_ATTR33,C_EXT_ATTR34,C_EXT_ATTR35,C_EXT_ATTR36,C_EXT_ATTR37,C_EXT_ATTR38,C_EXT_ATTR39,C_EXT_ATTR40,
        N_EXT_ATTR1,N_EXT_ATTR2,N_EXT_ATTR3,N_EXT_ATTR4,N_EXT_ATTR5,N_EXT_ATTR6,N_EXT_ATTR7,N_EXT_ATTR8,N_EXT_ATTR9,N_EXT_ATTR10,
        N_EXT_ATTR11,N_EXT_ATTR12,N_EXT_ATTR13,N_EXT_ATTR14,N_EXT_ATTR15,N_EXT_ATTR16,N_EXT_ATTR17,N_EXT_ATTR18,N_EXT_ATTR19,N_EXT_ATTR20,
        D_EXT_ATTR1,D_EXT_ATTR2,D_EXT_ATTR3,D_EXT_ATTR4,D_EXT_ATTR5,D_EXT_ATTR6,D_EXT_ATTR7,D_EXT_ATTR8,D_EXT_ATTR9,D_EXT_ATTR10,
        UOM_EXT_ATTR1,UOM_EXT_ATTR2,UOM_EXT_ATTR3,UOM_EXT_ATTR4,UOM_EXT_ATTR5,UOM_EXT_ATTR6,UOM_EXT_ATTR7,UOM_EXT_ATTR8,UOM_EXT_ATTR9,UOM_EXT_ATTR10,
        UOM_EXT_ATTR11,UOM_EXT_ATTR12,UOM_EXT_ATTR13,UOM_EXT_ATTR14,UOM_EXT_ATTR15,UOM_EXT_ATTR16,UOM_EXT_ATTR17,UOM_EXT_ATTR18,UOM_EXT_ATTR19,UOM_EXT_ATTR20
        from bom_components_ext_b
        where data_level_id = l_data_level_id and COMPONENT_SEQUENCE_ID = p_draft_comp_seq_id)));

        return l_updated;
EXCEPTION
    WHEN OTHERS THEN
        return 0;
END Compare_UDA_Values;

/*
 * This Procedure will compare two different components and its UDA and gives whether they are same or different.
 */

Function Compare_components(p_draft_comp_seq_id    IN NUMBER,
                            p_released_comp_seq_id IN NUMBER)
RETURN NUMBER
IS
l_updated Number;
BEGIN

    l_updated := 0;

    begin -- Added UT fix

    select 1
    into l_updated
    from dual
    where exists(
        ((select
           component_item_id,component_quantity,component_item_revision_id,
           component_remarks,change_notice,quantity_related,
           component_yield_factor,enforce_int_requirements,include_in_cost_rollup,
           basis_type,bom_item_type,planning_factor,
           supply_locator_id,supply_subinventory,auto_request_material,
           wip_supply_type,check_atp,optional,
           mutually_exclusive_options,low_quantity,high_quantity,
           so_basis,shipping_allowed,include_on_ship_docs,
           required_for_revenue,required_to_ship
          from bom_components_b
          where COMPONENT_SEQUENCE_ID = p_draft_comp_seq_id)
        minus
        (select
           component_item_id,component_quantity,component_item_revision_id,
           component_remarks,change_notice,quantity_related,
           component_yield_factor,enforce_int_requirements,include_in_cost_rollup,
           basis_type,bom_item_type,planning_factor,
           supply_locator_id,supply_subinventory,auto_request_material,
           wip_supply_type,check_atp,optional,
           mutually_exclusive_options,low_quantity,high_quantity,
           so_basis,shipping_allowed,include_on_ship_docs,
           required_for_revenue,required_to_ship
         from bom_components_b
         where COMPONENT_SEQUENCE_ID = p_released_comp_seq_id))
        union
        ((select
           component_item_id,component_quantity,component_item_revision_id,
           component_remarks,change_notice,quantity_related,
           component_yield_factor,enforce_int_requirements,include_in_cost_rollup,
           basis_type,bom_item_type,planning_factor,
           supply_locator_id,supply_subinventory,auto_request_material,
           wip_supply_type,check_atp,optional,
           mutually_exclusive_options,low_quantity,high_quantity,
           so_basis,shipping_allowed,include_on_ship_docs,
           required_for_revenue,required_to_ship
        from bom_components_b
        where COMPONENT_SEQUENCE_ID = p_released_comp_seq_id)
        minus
        (select
           component_item_id,component_quantity,component_item_revision_id,
           component_remarks,change_notice,quantity_related,
           component_yield_factor,enforce_int_requirements,include_in_cost_rollup,
           basis_type,bom_item_type,planning_factor,
           supply_locator_id,supply_subinventory,auto_request_material,
           wip_supply_type,check_atp,optional,
           mutually_exclusive_options,low_quantity,high_quantity,
           so_basis,shipping_allowed,include_on_ship_docs,
           required_for_revenue,required_to_ship
        from bom_components_b
        where COMPONENT_SEQUENCE_ID = p_draft_comp_seq_id)));

    -- Added as UT fix
    exception
        when others then
     l_updated := 0;
    end;

    if l_updated = 0 then
        l_updated := compare_uda_values(p_draft_comp_seq_id,
                                        p_released_comp_seq_id);
    end if;
    return l_updated;
EXCEPTION
    WHEN OTHERS THEN
        return 0;
END Compare_components;

/**** This function returns the catalog group id  ****/
FUNCTION get_icc_id(p_inventory_item_id  NUMBER,
                    p_organzation_id     NUMBER) RETURN NUMBER IS

   l_catalog_group_id NUMBER;
BEGIN
     select item_catalog_group_id
     INTO l_catalog_group_id
     from mtl_system_items_b
     where inventory_item_id = p_inventory_item_id
     and organization_id = p_organzation_id;

     RETURN l_catalog_group_id;

END get_icc_id;

procedure populate_item_rev_details(p_inventory_item_id  Number,
                                    p_organization_id    Number)
Is
l_counter Number := 0;
cursor get_revision_details(p_inventory_item_id NUMBER,
                            p_organization_id   NUMBER) is
     select revision_id,
            revision,
            effectivity_date,
            (select nvl( min(b.effectivity_date)-(1/86400),to_date('9999/12/31 00:00:00',date_fmt)) end_date
             from mtl_item_revisions_b b
             where b.inventory_item_id = a.inventory_item_id
             and b.organization_id = a.organization_id
             and b.effectivity_date > a.effectivity_date) end_date
     from mtl_item_revisions_b a
     where inventory_item_id = p_inventory_item_id
     and organization_id = p_organization_id
     order by effectivity_date;
Begin
   v_item_revisions_tbl.delete;
   v_rev_index.delete;
   for revision in get_revision_details(p_inventory_item_id,p_organization_id) Loop
      l_counter := l_counter+1;
      v_rev_index(revision.revision_id) := l_counter;
      v_item_revisions_tbl(l_counter).revision_id  := revision.revision_id;
      v_item_revisions_tbl(l_counter).revision := revision.revision;
      v_item_revisions_tbl(l_counter).start_date := revision.effectivity_date;
      v_item_revisions_tbl(l_counter).end_date := revision.end_date;
   End Loop;
   l_counter := l_counter+1;
   v_rev_index(-1) := l_counter;
   v_item_revisions_tbl(l_counter).revision_id  := null;
   v_item_revisions_tbl(l_counter).revision := null;
   v_item_revisions_tbl(l_counter).start_date := null;
   v_item_revisions_tbl(l_counter).end_date := to_date('9999/12/31 00:00:00',date_fmt);
End populate_item_rev_details;


Function validate_component_overlap(p_bill_seq_id IN Number,
                                    p_alt_desg    IN VARCHAR2,
                                    x_error_msg OUT NOCOPY VARCHAR2)
Return Number
Is

cursor components is
select * from bom_components_b
where bill_sequence_id = p_bill_seq_id;

l_count Number := 0;
l_return_val Number := 0;
fromEndItemMinorRevCode Varchar2(80);
toEndItemMinorRevCode Varchar2(80);
endItemId Number;
endItemOrgId Number;
fromMinorRevCode Varchar2(80);
toMinorRevCode Varchar2(80);

cursor overlap(P_comp_seq_id Number,
               P_obj_type varchar2,
               P_pk1_value varchar2,
               P_pk2_value varchar2,
               P_op_seq    number,
               P_toMinorRevCode varchar2,
               P_fromMinorRevCode varchar2,
               P_fromMinorRevisionId number,
               P_changeNotice varchar2,
               P_fromEndItemMinorRevCode varchar2,
               P_toEndItemMinorRevCode varchar2,
               P_endItemOrgId Number,
               P_endItemId Number)
is
SELECT count(1)
FROM bom_components_b bic
WHERE bill_sequence_id  = p_bill_seq_id
AND component_sequence_id <> P_comp_seq_id
AND nvl(obj_name,'EGO_ITEM') = nvl(P_obj_type,'EGO_ITEM')
AND pk1_value = P_pk1_value
AND nvl(pk2_value,'-1') = nvl(P_pk2_value,'-1')
AND operation_seq_num = P_op_seq
AND ((P_obj_type IS NOT NULL AND
      P_fromMinorRevisionId BETWEEN nvl(from_minor_revision_id,P_fromMinorRevisionId) AND nvl(to_minor_revision_id,P_fromMinorRevisionId))
     OR (P_obj_type IS NULL AND P_toMinorRevCode IS NULL OR
         P_toMinorRevCode >= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(nvl(from_minor_revision_id,0)))
                FROM mtl_item_revisions_b WHERE revision_id = FROM_OBJECT_REVISION_ID)
     AND (to_object_revision_id IS NULL OR
        P_fromMinorRevCode <= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(nvl(to_minor_revision_id,9999999999999999)))
                FROM mtl_item_revisions_b WHERE revision_id = TO_OBJECT_REVISION_ID))))
     AND (change_notice is not null
          and( implementation_date is not null and P_changeNotice is null OR
               (implementation_date is null and change_notice = P_changeNotice
                AND EXISTS( SELECT 1 from eng_revised_items eri
                            where eri.revised_item_sequence_id = bic.revised_item_sequence_id
                            and eri.bill_Sequence_id = bic.bill_Sequence_id )))
     OR (change_notice is null and P_changeNotice is null))
     AND (( EXISTS (SELECT null FROM mtl_item_revisions_b
                    WHERE inventory_item_id = P_endItemId AND organization_id  = P_endItemOrgId
                    AND revision_id = from_end_item_rev_id)
      AND ( P_toEndItemMinorRevCode IS NULL OR P_toEndItemMinorRevCode >= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(from_end_item_minor_rev_id))
                                   FROM mtl_item_revisions_b WHERE revision_id = from_end_item_rev_id))
      AND ( to_end_item_rev_id IS NULL OR P_fromEndItemMinorRevCode <= (SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(nvl(to_end_item_minor_rev_id,9999999999999999)))
                                                  FROM mtl_item_revisions_b WHERE revision_id = to_end_item_rev_id))));

begin

    for comp in components loop

        l_count := 0;
        fromEndItemMinorRevCode := null;
        toEndItemMinorRevCode := null;
        endItemId := null;
        endItemOrgId := null;
        fromMinorRevCode := null;
        toMinorRevCode := null;

        if comp.FROM_END_ITEM_REV_ID is not null then
            SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),to_char(comp.FROM_END_ITEM_MINOR_REV_ID)),
                   inventory_item_id,
                   organization_id
            into   fromEndItemMinorRevCode,
                   endItemId,
                   endItemOrgId
            FROM mtl_item_revisions_b
            WHERE revision_id = comp.FROM_END_ITEM_REV_ID;
        end if;

        if comp.TO_END_ITEM_REV_ID is not null then
            SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),nvl(to_char(comp.TO_END_ITEM_MINOR_REV_ID),'9999999999999999L')),
                   inventory_item_id,
                   organization_id
            into   toEndItemMinorRevCode,
                   endItemId,
                   endItemOrgId
            FROM mtl_item_revisions_b
            WHERE revision_id = comp.TO_END_ITEM_REV_ID;
        end if;

        if fromEndItemMinorRevCode is not null then
            SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),nvl(to_char(comp.FROM_MINOR_REVISION_ID),'9999999999999999L')),
                   inventory_item_id,
                   organization_id
            into   fromMinorRevCode,
                   endItemId,
                   endItemOrgId
            FROM mtl_item_revisions_b
            WHERE revision_id = comp.FROM_OBJECT_REVISION_ID;
        end if;

        if toMinorRevCode is not null then
            SELECT concat(to_char(effectivity_date,'yyyymmddhh24miss'),nvl(to_char(comp.TO_MINOR_REVISION_ID),'9999999999999999L')),
                   inventory_item_id,
                   organization_id
            into   toMinorRevCode,
                   endItemId,
                   endItemOrgId
            FROM mtl_item_revisions_b
            WHERE revision_id = comp.TO_OBJECT_REVISION_ID;
        end if;

        open  overlap(comp.component_sequence_id,
                      comp.OBJ_NAME,
                      comp.PK1_VALUE,
                      comp.PK2_VALUE,
                      comp.OPERATION_SEQ_NUM,
                      toMinorRevCode,
                      fromMinorRevCode,
                      comp.FROM_MINOR_REVISION_ID,
                      comp.change_notice,
                      fromEndItemMinorRevCode,
                      toEndItemMinorRevCode,
                      endItemOrgId,
                      endItemId);
        fetch overlap into l_count;
        close overlap;

        if l_count <> 0 then
            l_return_val := 1;
            begin

                select concatenated_segments into G_COMP_ITEM_NAME
                from mtl_system_items_kfv where inventory_item_id = comp.PK1_VALUE
                and organization_id = comp.pk2_value;

                /* UT Fix: Modified query to use ass_item_id instead of comp_item_id. */
                select revision_label into G_EFF_FROM
                from mtl_item_revisions where inventory_item_id = G_INV_ITEM_ID
                and organization_id = comp.pk2_value and revision_id = comp.FROM_END_ITEM_REV_ID;

            exception
                when others then
                    G_COMP_ITEM_NAME := null;
                    G_EFF_FROM := null;
            end;
            fnd_message.set_name('EGO','EGO_INHERIT_COMP_OVERLAP');
            fnd_message.set_token('COMPONENT_ITEM_NAME', G_COMP_ITEM_NAME);
            fnd_message.set_token('ALTCODE', p_alt_desg);
            fnd_message.set_token('EFFECTIVE_FROM', G_EFF_FROM);
            x_error_msg := substr(x_error_msg||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
            --return l_count;
        end if;

    end loop;

    l_count := l_return_val;
    return l_count;

end validate_component_overlap;

PROCEDURE create_structure_inherit(p_inventory_item_id  IN NUMBER,
                                   p_organization_id     IN NUMBER,
                                   p_bill_seq_id         IN NUMBER,
                                   p_comm_bill_seq_id    IN NUMBER,
                                   p_structure_type_id   IN NUMBER,
                                   p_alt_desg            IN VARCHAR2,
                                   x_Return_Status       OUT NOCOPY NUMBER,
                                   x_Error_Message       OUT NOCOPY VARCHAR2,
                                   p_eff_control         IN NUMBER) IS

    l_catalog_group_id           Number;
    l_catalog_bill_sequence_id   Number;
    l_effective_version          Number;
    l_icc_index                  Number;
    l_ins_cntr                   Number;
    l_current_rev_id             Number;
    l_prev_rev_id                Number;
    l_prev_icc_version           Number;
    l_item_comp_id               Number;
    l_new_component_seq_id       Number;
    l_errorcode                  Number;
    l_msg_count                  Number;
    l_msg_data                   Varchar2(2000);

    cursor get_all_icc_components(p_item_catalog_grp_id  Number,
                                  p_rev_date Date) is
     select icc_str_comp.component_sequence_id,icc_str_comp.component_item_id,icc_str_comp.bill_sequence_id,0 is_component_present,
            msiv.bom_item_type,msiv.eam_item_type,msiv.base_item_id,msiv.replenish_to_order_flag,msiv.pick_components_flag,
            icc_str_comp.component_yield_factor,icc_str_comp.basis_type,msiv.ato_forecast_control,icc_str_comp.planning_factor,
            icc_str_comp.optional,msiv.atp_components_flag,icc_str_comp.component_quantity,
            icc_str_comp.required_to_ship,icc_str_comp.required_for_revenue
     from (
            select icc_str_components.component_sequence_id,
                   icc_str_components.component_item_id,
                   icc_structure.pk1_value,
                   icc_str_components.from_object_revision_id,
                   icc_str_components.bill_sequence_id,
                   icc_str_components.component_yield_factor,
                   icc_str_components.basis_type,
                   icc_str_components.planning_factor,
                   icc_str_components.optional,
                   icc_str_components.component_quantity,
                   icc_str_components.required_to_ship,
                   icc_str_components.required_for_revenue
            from (select item_catalog_group_id
                  from mtl_item_catalog_groups_b
                  connect by prior parent_catalog_group_id = item_catalog_group_id
                  start with item_catalog_group_id = p_item_catalog_grp_id) icc,
                 bom_structures_b icc_structure,
                 bom_components_b icc_str_components
            where icc_structure.pk1_value = icc.item_catalog_group_id
            and   icc_structure.pk2_value = p_organization_id
            and   icc_structure.obj_name = 'EGO_CATALOG_GROUP'
            and   icc_structure.structure_type_id = p_structure_type_id
            and   icc_structure.alternate_bom_designator = p_alt_desg
            and   icc_structure.assembly_type = 2
            and   icc_structure.effectivity_control = 4
            and   icc_structure.bill_sequence_id = icc_str_components.bill_sequence_id
            and   nvl(icc_str_components.parent_bill_seq_id,icc_str_components.bill_sequence_id) = icc_structure.bill_sequence_id) icc_str_comp,
          mtl_system_items_vl msiv
     where icc_str_comp.from_object_revision_id = EGO_ICC_STRUCTURE_PVT.Get_Effective_Version(icc_str_comp.pk1_value,p_rev_date)
     and msiv.inventory_item_id = icc_str_comp.component_item_id
     and msiv.organization_id = p_organization_id;

    /* This PL/SQL table will be populated with ICC components for the effective version. */
    type icc_component_record is record
    (component_sequence_id  Number,
     component_item_id      Number,
     bill_sequence_id       Number,
     is_component_present   Number);

    type icc_component_rec is table of icc_component_record index by binary_integer;
    v_icc_comp_tbl icc_component_rec;

    type component_record is record
    (bill_sequence_id           Number,
     component_sequence_id      Number,
     component_item_id          Number,
     from_revision_id           Number,
     to_revision_id             Number);

    /* This PL/SQL table is used for final DML Operations. */
    type component_rec is table of component_record index by binary_integer;
    v_insert_comp_tbl      component_rec;

    l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_src_pk_col_name_val_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_str_type                   EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_pks             EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_data_level_id              Number;

    l_assy_bom_item_type MTL_SYSTEM_ITEMS_VL.bom_item_type%type;
    l_assy_eam_item_type MTL_SYSTEM_ITEMS_VL.eam_item_type%type;
    l_assy_base_item_id MTL_SYSTEM_ITEMS_VL.base_item_id%type;
    l_assy_replenish_to_order_flag MTL_SYSTEM_ITEMS_VL.replenish_to_order_flag%type;
    l_assy_pick_components_flag MTL_SYSTEM_ITEMS_VL.pick_components_flag%type;
    l_assy_atp_comp_flag MTL_SYSTEM_ITEMS_VL.atp_components_flag%type;

    l_Return_Status Varchar2(1) := 'S';

    l_item_seq_incr_prof VARCHAR2(10) := nvl(fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT'),10);
    l_item_seq_incr Number := 0;
    l_stmt_no Number := 0;

BEGIN
    l_stmt_no := 10;
    If nvl(p_eff_control,1) <> 4 Then
        x_Return_Status := 0;
        x_Error_Message := null;
        Return;
    End If;
    l_stmt_no := 20;
    If p_bill_seq_id <> nvl(p_comm_bill_seq_id,p_bill_seq_id) Then
        x_Return_Status := 0;
        x_Error_Message := null;
        Return;
    End If;
    l_stmt_no := 30;
    l_catalog_group_id :=  get_icc_id(p_inventory_item_id,p_organization_id);
    l_stmt_no := 40;
    if l_catalog_group_id is null then
         x_Return_Status := 0;
         x_Error_Message := null;
         Return;
    end if;
    l_stmt_no := 50;
    begin
        select bill_sequence_id
        into l_catalog_bill_sequence_id
        from bom_structures_b
        where pk1_value = to_char(l_catalog_group_id)
        and pk2_value = to_char(p_organization_id)
        and obj_name = 'EGO_CATALOG_GROUP'
        and assembly_type = 2
        and effectivity_control = 4
        and structure_type_id = p_structure_type_id
        and alternate_bom_designator = p_alt_desg;
    exception
        when no_data_found then
            /* Some Parent ICC might have structure and components */
            l_stmt_no := 60;
            begin
                select null
                into l_catalog_bill_sequence_id
                from bom_structures_b
                where pk1_value in (select item_catalog_group_id
                                    from mtl_item_catalog_groups_b
                                    connect by prior parent_catalog_group_id = item_catalog_group_id
                                    start with item_catalog_group_id = l_catalog_group_id)
                and pk2_value = to_char(p_organization_id)
                and obj_name = 'EGO_CATALOG_GROUP'
                and assembly_type = 2
                and effectivity_control = 4
                and structure_type_id = p_structure_type_id
                and alternate_bom_designator = p_alt_desg
                and rownum = 1;
            exception
                when no_data_found then
                    x_Return_Status := 0;
                    x_Error_Message := null;
                    Return;
                when others then
                    null;
            end;
        when others then
            null;
    end;
    l_stmt_no := 70;
    select bom_item_type,eam_item_type,base_item_id,replenish_to_order_flag,pick_components_flag,atp_components_flag
    into l_assy_bom_item_type,l_assy_eam_item_type,l_assy_base_item_id,l_assy_replenish_to_order_flag,l_assy_pick_components_flag,
         l_assy_atp_comp_flag
    from MTL_SYSTEM_ITEMS_VL
    where inventory_item_id = p_inventory_item_id
    and organization_id = p_organization_id;
    l_stmt_no := 80;
    select concatenated_segments into G_ASSY_ITEM_NAME
    from mtl_system_items_kfv  where inventory_item_id = p_inventory_item_id and organization_id = p_organization_id;
    l_stmt_no := 90;
    populate_item_rev_details(p_inventory_item_id,p_organization_id);
    l_stmt_no := 100;
    l_ins_cntr := 0;
    For rev_count in 1..v_rev_index.count loop
        l_stmt_no := 110;
        l_current_rev_id := v_item_revisions_tbl(rev_count).revision_id;

        --For first iteration, l_current_rev_id is null
        If l_current_rev_id is null then
            goto process_next_revision;
        End if;
        l_stmt_no := 120;
        -- Before populating, we need to clear v_icc_comp_tbl
        v_icc_comp_tbl.DELETE;
        l_stmt_no := 130;
        for component in get_all_icc_components(l_catalog_group_id,v_item_revisions_tbl(rev_count).start_date) loop
            If(component.component_item_id = p_inventory_item_id) then
                x_Return_Status := 1;
                fnd_message.set_name('EGO','EGO_ASSY_AS_INH_COMP');
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                --Return;
            End If;
            l_stmt_no := 140;
            select concatenated_segments into G_COMP_ITEM_NAME
            from mtl_system_items_kfv where inventory_item_id = component.component_item_id
            and organization_id = p_organization_id;
            l_stmt_no := 150;
            if v_icc_comp_tbl.exists(component.component_item_id) then
                x_Return_Status := 1;

                fnd_message.set_name('EGO','EGO_INHERIT_COMP_OVERLAP');
                fnd_message.set_token('COMPONENT_ITEM_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('ALTCODE', p_alt_desg);
                fnd_message.set_token('EFFECTIVE_FROM', v_item_revisions_tbl(rev_count).revision);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                --Return;
            end if;
            l_stmt_no := 160;
            -- Added for Bom Item type validation for inherited components.
            if (
                ( ( l_assy_bom_item_type = 1 and component.bom_item_type <> 3) or
                  ( l_assy_bom_item_type = 2 and component.bom_item_type <> 3) or
                  ( l_assy_bom_item_type = 3) or
                   ( l_assy_bom_item_type = 4 and
                   (component.bom_item_type = 4 or
                   (l_assy_eam_item_type is null and
                   (component.bom_item_type IN (2, 1) and
                    component.replenish_to_order_flag = 'Y'  and
                    l_assy_base_item_id IS  NOT NULL and
                    l_assy_replenish_to_order_flag = 'Y'))))
                )
            and ( l_assy_bom_item_type = 3 or
                  l_assy_pick_components_flag = 'Y' or
                  component.pick_components_flag = 'N')
            and ( l_assy_bom_item_type = 3 or
                  NVL(component.bom_item_type, 4) <> 2 or
                  (component.bom_item_type = 2 and
                   ((l_assy_pick_components_flag = 'Y' and
                     component.pick_components_flag = 'Y') or
                    (l_assy_replenish_to_order_flag = 'Y' and
                     component.replenish_to_order_flag = 'Y')))
                )
            and NOT(l_assy_bom_item_type = 4 and
                    l_assy_pick_components_flag = 'Y' and
                    component.bom_item_type = 4 and
                    component.replenish_to_order_flag = 'Y')
               ) then
                null;
            else
                x_Return_Status := 1;
                l_stmt_no := 170;
                fnd_message.set_name('EGO','EGO_INHERIT_COMP_ITEMTYPE');
                fnd_message.set_token('COMPONENT_ITEM_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('ALTCODE', p_alt_desg);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                --Return;
            end if;
            l_stmt_no := 180;
            if (component.component_yield_factor <> 1 and l_assy_bom_item_type = 3) then
                fnd_message.set_name('BOM','BOM_COMP_YIELD_NOT_ONE');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            end if;
            l_stmt_no := 190;
            if l_assy_pick_components_flag = 'Y' and component.basis_type = 2 then
                fnd_message.set_name('BOM','BOM_LOT_BASED_PTO');
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            end if;
            l_stmt_no := 200;
            IF component.PLANNING_FACTOR <> 100 THEN
                IF l_assy_bom_item_type = 4 THEN
                    fnd_message.set_name('BOM','BOM_NOT_A_PLANNING_PARENT');
                    fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                    fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                    x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                    x_Return_Status := 1;
                ELSIF ( l_assy_bom_item_type IN (1,2) AND component.OPTIONAL <> 1 AND
                        component.ato_forecast_control  <> 2 ) THEN
                    fnd_message.set_name('BOM','BOM_COMP_MODEL_OC_OPTIONAL');
                    fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                    x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                    x_Return_Status := 1;
                ELSIF ( l_assy_bom_item_type IN (1,2) AND ( component.OPTIONAL = 1 AND
                        component.ato_forecast_control <> 2 )) THEN
                    fnd_message.set_name('BOM','BOM_COMP_OPTIONAL_ATO_FORECAST');
                    fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                    x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                    x_Return_Status := 1;
                END IF;
            END IF;
            l_stmt_no := 210;
            IF ( l_assy_pick_components_flag = 'Y' AND l_assy_bom_item_type IN ( 1, 2) AND
                 component.replenish_to_order_flag = 'Y' AND component.bom_item_type = 4 AND
                 NVL(component.base_item_id,0) = 0 AND component.OPTIONAL = 2 ) THEN
                fnd_message.set_name('BOM','BOM_COMP_OPTIONAL');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            ELSIF ( l_assy_bom_item_type IN (3,4) AND component.OPTIONAL = 1 ) THEN
                fnd_message.set_name('BOM','BOM_COMP_NOT_OPTIONAL');
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            END IF;
            l_stmt_no := 220;
            IF component.required_for_revenue = 1 AND component.required_to_ship = 2 AND l_assy_atp_comp_flag = 'Y' THEN
                fnd_message.set_name('BOM','BOM_COMP_REQ_FOR_REV_INVALID');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            ELSIF component.required_to_ship = 1 AND component.required_for_revenue = 2 AND l_assy_atp_comp_flag = 'Y' THEN
                fnd_message.set_name('BOM','BOM_COMP_REQ_TO_SHIP_INVALID');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            ELSIF component.required_to_ship = 1 AND component.required_for_revenue = 1 AND l_assy_atp_comp_flag = 'Y' THEN
                fnd_message.set_name('BOM','BOM_COMP_REQ_TO_SHIP_INVALID');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                fnd_message.set_name('BOM','BOM_COMP_REQ_FOR_REV_INVALID');
                fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                x_Return_Status := 1;
            END IF;
            l_stmt_no := 230;
            v_icc_comp_tbl(component.component_item_id).bill_sequence_id := component.bill_sequence_id;
            v_icc_comp_tbl(component.component_item_id).component_item_id := component.component_item_id;
            v_icc_comp_tbl(component.component_item_id).component_sequence_id := component.component_sequence_id;
            v_icc_comp_tbl(component.component_item_id).is_component_present := component.is_component_present;
        end loop;
        l_stmt_no := 240;
        If(rev_count <> 1 and v_insert_comp_tbl.count >= 1) then
            For insert_comp_tbl_count in 1..v_insert_comp_tbl.count loop
                l_item_comp_id := v_insert_comp_tbl(insert_comp_tbl_count).component_item_id;
                l_stmt_no := 250;
                if(v_icc_comp_tbl.exists(l_item_comp_id)) then
                    if EGO_ICC_STRUCTURE_PVT.Compare_components(v_insert_comp_tbl(insert_comp_tbl_count).component_sequence_id,
                                                                v_icc_comp_tbl(l_item_comp_id).component_sequence_id) = 0 then
                        --Components with same attributes
                        l_stmt_no := 260;
                        If v_insert_comp_tbl(insert_comp_tbl_count).to_revision_id is null then
                            v_icc_comp_tbl(l_item_comp_id).is_component_present := 1;
                        End If;
                    Else
                        --Components with different attributes
                        l_stmt_no := 270;
                        If v_insert_comp_tbl(insert_comp_tbl_count).to_revision_id is null then
                            v_insert_comp_tbl(insert_comp_tbl_count).to_revision_id := l_prev_rev_id;
                        End If;
                    End If;
                Else
                    --Update current row in v_insert_comp_tbl as : to_revision_id := l_prev_rev_id;
                    l_stmt_no := 280;
                    If v_insert_comp_tbl(insert_comp_tbl_count).to_revision_id is null then
                        v_insert_comp_tbl(insert_comp_tbl_count).to_revision_id := l_prev_rev_id;
                    End If;
                End If;
            End loop;
        End If;
        l_stmt_no := 290;
        -- process unprocessed rows in v_icc_comp_tbl
        l_icc_index := v_icc_comp_tbl.first;
        while l_icc_index <= v_icc_comp_tbl.last loop
            if v_icc_comp_tbl(l_icc_index).is_component_present = 0 then
                l_ins_cntr := l_ins_cntr+1;
                v_insert_comp_tbl(l_ins_cntr).bill_sequence_id := v_icc_comp_tbl(l_icc_index).bill_sequence_id;
                v_insert_comp_tbl(l_ins_cntr).component_sequence_id := v_icc_comp_tbl(l_icc_index).component_sequence_id;
                v_insert_comp_tbl(l_ins_cntr).component_item_id := v_icc_comp_tbl(l_icc_index).component_item_id;
                v_insert_comp_tbl(l_ins_cntr).from_revision_id := l_current_rev_id;
                v_insert_comp_tbl(l_ins_cntr).to_revision_id := null;
            End If;
            l_stmt_no := 300;
            l_icc_index := v_icc_comp_tbl.next(l_icc_index);
        End loop;
        <<process_next_revision>>
        l_prev_rev_id := l_current_rev_id;
    End loop;
    l_stmt_no := 310;
    if x_Return_Status <> 0 then
        return;
    end if;
    l_stmt_no := 320;
    select data_level_id
    into l_data_level_id
    from ego_data_level_b
    where data_level_name = 'COMPONENTS_LEVEL'
    and attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
    and application_id = 702;
    l_stmt_no := 330;
    --Create UDA values for the new components created.
    for cntr in 1..v_insert_comp_tbl.count loop

       l_item_seq_incr := l_item_seq_incr+to_number(l_item_seq_incr_prof);

       select BOM_INVENTORY_COMPONENTS_S.NEXTVAL
            into l_new_component_seq_id
            from dual;
       l_stmt_no := 340;
       Insert into BOM_COMPONENTS_B
            (OPERATION_SEQ_NUM,
             COMPONENT_ITEM_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             ITEM_NUM,
             COMPONENT_QUANTITY,
             COMPONENT_YIELD_FACTOR,
             EFFECTIVITY_DATE,
             IMPLEMENTATION_DATE,
             PLANNING_FACTOR,
             QUANTITY_RELATED,
             SO_BASIS,
             OPTIONAL,
             MUTUALLY_EXCLUSIVE_OPTIONS,
             INCLUDE_IN_COST_ROLLUP,
             CHECK_ATP,
             SHIPPING_ALLOWED,
             REQUIRED_TO_SHIP,
             REQUIRED_FOR_REVENUE,
             INCLUDE_ON_SHIP_DOCS,
             COMPONENT_SEQUENCE_ID,
             BILL_SEQUENCE_ID,
             WIP_SUPPLY_TYPE,
             PICK_COMPONENTS,
             SUPPLY_SUBINVENTORY,
             SUPPLY_LOCATOR_ID,
             BOM_ITEM_TYPE,
             ENFORCE_INT_REQUIREMENTS,
             COMPONENT_ITEM_REVISION_ID,
             PARENT_BILL_SEQ_ID,
             AUTO_REQUEST_MATERIAL,
             PK1_VALUE,
             PK2_VALUE,
             PK3_VALUE,
             PK4_VALUE,
             PK5_VALUE,
             FROM_END_ITEM_REV_ID,
             TO_END_ITEM_REV_ID,
             FROM_OBJECT_REVISION_ID,
             TO_OBJECT_REVISION_ID,
             INHERIT_FLAG,
             COMPONENT_REMARKS,
             CHANGE_NOTICE,
             BASIS_TYPE,
             LOW_QUANTITY,
             HIGH_QUANTITY)
             select
             BCB.OPERATION_SEQ_NUM,
             BCB.COMPONENT_ITEM_ID,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             l_item_seq_incr,
             BCB.COMPONENT_QUANTITY,
             BCB.COMPONENT_YIELD_FACTOR,
             BCB.EFFECTIVITY_DATE,
             BCB.IMPLEMENTATION_DATE,
             BCB.PLANNING_FACTOR,
             BCB.QUANTITY_RELATED,
             BCB.SO_BASIS,
             BCB.OPTIONAL,
             BCB.MUTUALLY_EXCLUSIVE_OPTIONS,
             BCB.INCLUDE_IN_COST_ROLLUP,
             BCB.CHECK_ATP,
             BCB.SHIPPING_ALLOWED,
             BCB.REQUIRED_TO_SHIP,
             BCB.REQUIRED_FOR_REVENUE,
             BCB.INCLUDE_ON_SHIP_DOCS,
             l_new_component_seq_id,
             p_bill_seq_id,
             BCB.WIP_SUPPLY_TYPE,
             BCB.PICK_COMPONENTS,
             BCB.SUPPLY_SUBINVENTORY,
             BCB.SUPPLY_LOCATOR_ID,
             BCB.BOM_ITEM_TYPE,
             BCB.ENFORCE_INT_REQUIREMENTS,
             BCB.COMPONENT_ITEM_REVISION_ID,
             null,
             BCB.AUTO_REQUEST_MATERIAL,
             BCB.PK1_VALUE,
             BCB.PK2_VALUE,
             BCB.PK3_VALUE,
             BCB.PK4_VALUE,
             BCB.PK5_VALUE,
             v_insert_comp_tbl(cntr).from_revision_id,
             v_insert_comp_tbl(cntr).to_revision_id,
             v_insert_comp_tbl(cntr).from_revision_id,
             v_insert_comp_tbl(cntr).to_revision_id,
             1,
             BCB.COMPONENT_REMARKS,
             BCB.CHANGE_NOTICE,
             BCB.BASIS_TYPE,
             BCB.LOW_QUANTITY,
             BCB.HIGH_QUANTITY
             from BOM_COMPONENTS_B BCB
             where BCB.COMPONENT_SEQUENCE_ID = v_insert_comp_tbl(cntr).component_sequence_id;
             /* UT Fix : Commented as component_seq_id is primary key in bom_components_b */
             -- and BCB.BILL_SEQUENCE_ID = l_catalog_bill_sequence_id;

       l_stmt_no := 350;
       l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                  to_char(v_insert_comp_tbl(cntr).component_sequence_id)),
                                                                    EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                  to_char(v_insert_comp_tbl(cntr).bill_sequence_id)));
       l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                  to_char(l_new_component_seq_id)),
                                                                     EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                  to_char(p_bill_seq_id)));
       l_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID',
                                                                                 TO_CHAR(p_structure_type_id)));


       l_data_level_pks :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID' , null));
       l_stmt_no := 360;
       EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data
               (
                   p_api_version                   => 1.0
                  ,p_application_id                => 702
                  ,p_object_name                   => 'BOM_COMPONENTS'
                  ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
                  ,p_new_pk_col_value_pairs        => l_dest_pk_col_name_val_pairs
                  ,p_old_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_new_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_old_data_level_id             => l_data_level_id
                  ,p_new_data_level_id             => l_data_level_id
                  ,p_new_cc_col_value_pairs        => l_str_type
                  ,x_return_status                 => l_Return_Status
                  ,x_errorcode                     => l_errorcode
                  ,x_msg_count                     => l_msg_count
                  ,x_msg_data                      => l_msg_data
               );
        l_stmt_no := 370;
        IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
            x_Return_Status := 1;
            x_Error_Message := l_msg_data;
            exit;
        END IF;
        l_stmt_no := 380;
    end loop;

    /* Assigned ass_item_id to global variable, this will be used in validate_component_overlap procedure. */
    G_INV_ITEM_ID := p_inventory_item_id;
    --x_Return_Status := validate_component_overlap(p_bill_seq_id);
    l_stmt_no := 390;
    x_Return_Status := validate_component_overlap(p_bill_seq_id => p_bill_seq_id,
                                                  p_alt_desg    => p_alt_desg,
                                                  x_error_msg   => x_Error_Message);
    l_stmt_no := 400;

EXCEPTION
    WHEN others THEN
        x_Return_Status := 1;
        x_Error_Message := 'UnHandled exception while inheriting structure components('||l_stmt_no||') : '||sqlerrm(sqlcode);

END create_structure_inherit;

Function get_revision_start_date(p_rev_id in Number)
Return Date is
Begin
    return v_item_revisions_tbl(v_rev_index(p_rev_id)).start_date;
End get_revision_start_date;

Function get_revision_end_date(p_rev_id in Number)
Return Date is
Begin
    return v_item_revisions_tbl(v_rev_index(p_rev_id)).end_date;
End get_revision_end_date;


PROCEDURE inherit_icc_components(p_inventory_item_id IN NUMBER,
                                p_organization_id   IN NUMBER,
                                p_revision_id       IN NUMBER,
                                p_rev_date          IN DATE,
                                x_Return_Status     OUT NOCOPY NUMBER,
                                x_Error_Message     OUT NOCOPY VARCHAR2) IS

     l_catalog_group_id           NUMBER;
     l_temp                       Number :=0;
     l_catalog_str_type_id        Number;
     l_catalog_str_name           Varchar2(10);
     l_item_bill_sequence_id      Number;
     l_catalog_bill_sequence_id   Number;
     l_effective_version          Number;

     l_prev_rev_id                Number;
     l_next_rev_id                Number;
     l_upd_cntr                   Number;
     l_ins_cntr                   Number;
     l_comp_id                    Number;
     l_comp_diff_count            Number;
     l_icc_index                  Number;
     l_new_component_seq_id       Number;
     l_comp_from_rev_id           Number;
     l_comp_to_rev_id             Number;
     l_errorcode                  Number;
     l_msg_count                  Number;
     l_msg_data                   Varchar2(2000);

     l_assy_bom_item_type MTL_SYSTEM_ITEMS_VL.bom_item_type%type;
     l_assy_eam_item_type MTL_SYSTEM_ITEMS_VL.eam_item_type%type;
     l_assy_base_item_id MTL_SYSTEM_ITEMS_VL.base_item_id%type;
     l_assy_replenish_to_order_flag MTL_SYSTEM_ITEMS_VL.replenish_to_order_flag%type;
     l_assy_pick_components_flag MTL_SYSTEM_ITEMS_VL.pick_components_flag%type;
     l_assy_atp_comp_flag MTL_SYSTEM_ITEMS_VL.atp_components_flag%type;

     cursor item_structure(p_inventory_item_id Number,
                           p_organization_id   Number) is
     select structure_type_id,alternate_bom_designator,bill_sequence_id
     from bom_structures_b
     where
     assembly_item_id = p_inventory_item_id
     and organization_id = p_organization_id
     and obj_name is null
     and assembly_type = 2
     and effectivity_control = 4
     and source_bill_sequence_id = bill_sequence_id;

     cursor get_all_icc_components(p_item_catalog_grp_id  Number,
                                   p_structure_type_id    Number,
                                   p_alt_desg             Varchar2) is
     select icc_str_comp.component_sequence_id,icc_str_comp.component_item_id,icc_str_comp.bill_sequence_id,0 is_component_present,
            msiv.bom_item_type,msiv.eam_item_type,msiv.base_item_id,msiv.replenish_to_order_flag,msiv.pick_components_flag,
            icc_str_comp.component_yield_factor,icc_str_comp.basis_type,msiv.ato_forecast_control,icc_str_comp.planning_factor,
            icc_str_comp.optional,msiv.atp_components_flag,icc_str_comp.component_quantity,
            icc_str_comp.required_to_ship,icc_str_comp.required_for_revenue
     from (
            select icc_str_components.component_sequence_id,
                   icc_str_components.component_item_id,
                   icc_structure.pk1_value,
                   icc_str_components.from_object_revision_id,
                   icc_structure.bill_sequence_id,
                   icc_str_components.component_yield_factor,
                   icc_str_components.basis_type,
                   icc_str_components.planning_factor,
                   icc_str_components.optional,
                   icc_str_components.component_quantity,
                   icc_str_components.required_to_ship,
                   icc_str_components.required_for_revenue
            from (select item_catalog_group_id
                  from mtl_item_catalog_groups_b
                  connect by prior parent_catalog_group_id = item_catalog_group_id
                  start with item_catalog_group_id = p_item_catalog_grp_id) icc,
                 bom_structures_b icc_structure,
                 bom_components_b icc_str_components
            where icc_structure.pk1_value = icc.item_catalog_group_id
            and   icc_structure.pk2_value = p_organization_id
            and   icc_structure.obj_name = 'EGO_CATALOG_GROUP'
            and   icc_structure.structure_type_id = p_structure_type_id
            and   icc_structure.alternate_bom_designator = p_alt_desg
            and   icc_structure.assembly_type = 2
            and   icc_structure.effectivity_control = 4
            and   icc_structure.bill_sequence_id = icc_str_components.bill_sequence_id
            and   nvl(icc_str_components.parent_bill_seq_id,icc_str_components.bill_sequence_id) = icc_structure.bill_sequence_id) icc_str_comp,
            mtl_system_items_vl msiv
     where icc_str_comp.from_object_revision_id = EGO_ICC_STRUCTURE_PVT.Get_Effective_Version(icc_str_comp.pk1_value,p_rev_date)
     and msiv.inventory_item_id = icc_str_comp.component_item_id
     and msiv.organization_id = p_organization_id;

     type component_record is record
     (component_sequence_id       Number,
      component_item_id           Number,
      from_revision_id            Number,
      to_revision_id              Number,
      bill_seq_id                 Number);

     /* This PL/SQL table is used for final DML Operations. */
     type component_rec is table of component_record index by binary_integer;
     v_insert_comp_tbl component_rec;
     v_update_comp_tbl component_rec;
     v_delete_comp_tbl component_rec;

     /* This PL/SQL table will be populated with ICC components. */
     type icc_component_record is record
     (component_sequence_id  Number,
      component_item_id      Number,
      bill_sequence_id       Number,
      is_component_present   Number);
     type icc_component_rec is table of icc_component_record index by binary_integer;
     v_icc_comp_tbl icc_component_rec;

     /* This PL/SQL table will be populated with Item components. */
     type item_component_record is record(
     component_sequence_id Number,
     component_item_id     Number,
     from_end_item_rev_id  Number,
     to_end_item_rev_id    Number,
     inherit_flag          Number);

     type item_component_rec is table of item_component_record index by binary_integer;
     v_item_comp_tbl item_component_rec;

     l_dest_pk_col_name_val_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_src_pk_col_name_val_pairs  EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_str_type                   EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_data_level_pks             EGO_COL_NAME_VALUE_PAIR_ARRAY;
     l_data_level_id              Number;
     l_Return_Status Varchar2(1) := 'S';

     l_item_seq_incr_prof VARCHAR2(10) := nvl(fnd_profile.value('BOM:ITEM_SEQUENCE_INCREMENT'),10);
     l_item_seq_incr Number := 0;
     l_stmt_no       Number := 0;

BEGIN
     l_stmt_no := 10;
     l_catalog_group_id :=  get_icc_id(p_inventory_item_id,p_organization_id);
     x_Return_Status := 0;
     if l_catalog_group_id is null then
         x_Error_Message := null;
         Return;
     end if;
     l_stmt_no := 20;
     for structure in item_structure(p_inventory_item_id,p_organization_id) loop
         begin
             l_stmt_no := 30;
             select bill_sequence_id,structure_type_id,alternate_bom_designator
             into l_catalog_bill_sequence_id,l_catalog_str_type_id,G_ALTCODE
             from bom_structures_b
             where pk1_value = to_char(l_catalog_group_id)
             and pk2_value = to_char(p_organization_id)
             and obj_name = 'EGO_CATALOG_GROUP'
             and assembly_type = 2
             and effectivity_control = 4
             and structure_type_id = structure.structure_type_id
             and alternate_bom_designator = structure.alternate_bom_designator;

             l_item_bill_sequence_id := structure.bill_sequence_id;
             exit;
         exception
             when no_data_found then
                 /* Some Parent ICC might have structure and components */
                 begin
                     l_stmt_no := 40;
                     select structure_type_id,alternate_bom_designator
                     into l_catalog_str_type_id,G_ALTCODE
                     from bom_structures_b
                     where pk1_value in (select item_catalog_group_id
                                         from mtl_item_catalog_groups_b
                                         connect by prior parent_catalog_group_id = item_catalog_group_id
                                         start with item_catalog_group_id = l_catalog_group_id)
                     and pk2_value = to_char(p_organization_id)
                     and obj_name = 'EGO_CATALOG_GROUP'
                     and assembly_type = 2
                     and effectivity_control = 4
                     and structure_type_id = structure.structure_type_id
                     and alternate_bom_designator = structure.alternate_bom_designator
                     and rownum = 1;

                     l_item_bill_sequence_id := structure.bill_sequence_id;
                     exit;
                 exception
                     when others then
                         null;
                 end;
             when others then
                 null;
         end;
     end loop;

     l_stmt_no := 50;
     if l_item_bill_sequence_id is null then
         x_Return_Status := 0;
         x_Error_Message := null;
         Return;
     end if;

     l_stmt_no := 60;
     select max(ITEM_NUM) into l_item_seq_incr
     from bom_components_b where bill_sequence_id = l_item_bill_sequence_id;

     l_stmt_no := 70;
     select bom_item_type,eam_item_type,base_item_id,replenish_to_order_flag,pick_components_flag,atp_components_flag
     into l_assy_bom_item_type,l_assy_eam_item_type,l_assy_base_item_id,l_assy_replenish_to_order_flag,l_assy_pick_components_flag,
     l_assy_atp_comp_flag
     from MTL_SYSTEM_ITEMS_VL
     where inventory_item_id = p_inventory_item_id
     and organization_id = p_organization_id;

     l_stmt_no := 80;
     select concatenated_segments into G_ASSY_ITEM_NAME
     from mtl_system_items_kfv  where inventory_item_id = p_inventory_item_id and organization_id = p_organization_id;
     l_stmt_no := 90;
     populate_item_rev_details(p_inventory_item_id,p_organization_id);
     l_stmt_no := 100;
     if v_item_revisions_tbl.exists(v_rev_index(p_revision_id)-1) then
         l_prev_rev_id := v_item_revisions_tbl(v_rev_index(p_revision_id)-1).revision_id;
     else
         l_prev_rev_id := null;
     end if;
     l_stmt_no := 110;
     if v_item_revisions_tbl.exists(v_rev_index(p_revision_id)+1) then
         l_next_rev_id := v_item_revisions_tbl(v_rev_index(p_revision_id)+1).revision_id;
     else
         l_next_rev_id := null;
     end if;
     l_stmt_no := 120;
     for component in get_all_icc_components(l_catalog_group_id,l_catalog_str_type_id,G_ALTCODE) loop
         If(component.component_item_id = p_inventory_item_id) then
             x_Return_Status := 1;
             fnd_message.set_name('EGO','EGO_ASSY_AS_INH_COMP');
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             --Return;
         End If;
         l_stmt_no := 130;
         select concatenated_segments into G_COMP_ITEM_NAME
         from mtl_system_items_kfv where inventory_item_id = component.component_item_id
         and organization_id = p_organization_id;
         l_stmt_no := 140;
         if v_icc_comp_tbl.exists(component.component_item_id) then
             x_Return_Status := 1;
             fnd_message.set_name('EGO','EGO_INHERIT_COMP_OVERLAP');
             fnd_message.set_token('COMPONENT_ITEM_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('ALTCODE', G_ALTCODE);
             fnd_message.set_token('EFFECTIVE_FROM', v_item_revisions_tbl(v_rev_index(p_revision_id)).revision);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
         end if;
         l_stmt_no := 150;
         -- Added for Bom Item type validation for inherited components.
         if (
             ( ( l_assy_bom_item_type = 1 and component.bom_item_type <> 3) or
               ( l_assy_bom_item_type = 2 and component.bom_item_type <> 3) or
               ( l_assy_bom_item_type = 3) or
                ( l_assy_bom_item_type = 4 and
                (component.bom_item_type = 4 or
                (l_assy_eam_item_type is null and
                (component.bom_item_type IN (2, 1) and
                 component.replenish_to_order_flag = 'Y'  and
                 l_assy_base_item_id IS  NOT NULL and
                 l_assy_replenish_to_order_flag = 'Y'))))
             )
         and ( l_assy_bom_item_type = 3 or
               l_assy_pick_components_flag = 'Y' or
               component.pick_components_flag = 'N')
         and ( l_assy_bom_item_type = 3 or
               NVL(component.bom_item_type, 4) <> 2 or
               (component.bom_item_type = 2 and
                ((l_assy_pick_components_flag = 'Y' and
                  component.pick_components_flag = 'Y') or
                 (l_assy_replenish_to_order_flag = 'Y' and
                  component.replenish_to_order_flag = 'Y')))
             )
         and NOT(l_assy_bom_item_type = 4 and
                 l_assy_pick_components_flag = 'Y' and
                 component.bom_item_type = 4 and
                 component.replenish_to_order_flag = 'Y')
            ) then
             null;
         else
             x_Return_Status := 1;
             fnd_message.set_name('EGO','EGO_INHERIT_COMP_ITEMTYPE');
             fnd_message.set_token('COMPONENT_ITEM_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('ALTCODE', G_ALTCODE);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             --Return;
         end if;
         l_stmt_no := 160;
         if (component.component_yield_factor <> 1 and l_assy_bom_item_type = 3) then
             fnd_message.set_name('BOM','BOM_COMP_YIELD_NOT_ONE');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         end if;
         l_stmt_no := 170;
         if l_assy_pick_components_flag = 'Y' and component.basis_type = 2 then
             fnd_message.set_name('BOM','BOM_LOT_BASED_PTO');
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         end if;
         l_stmt_no := 180;
         IF component.PLANNING_FACTOR <> 100 THEN
             IF l_assy_bom_item_type = 4 THEN
                 fnd_message.set_name('BOM','BOM_NOT_A_PLANNING_PARENT');
                 fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
                 fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                 x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                 x_Return_Status := 1;
             ELSIF ( l_assy_bom_item_type IN (1,2) AND component.OPTIONAL <> 1 AND
                     component.ato_forecast_control  <> 2 ) THEN
                 fnd_message.set_name('BOM','BOM_COMP_MODEL_OC_OPTIONAL');
                 fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                 x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                 x_Return_Status := 1;
             ELSIF ( l_assy_bom_item_type IN (1,2) AND ( component.OPTIONAL = 1 AND
                     component.ato_forecast_control <> 2 )) THEN
                 fnd_message.set_name('BOM','BOM_COMP_OPTIONAL_ATO_FORECAST');
                 fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
                 x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
                 x_Return_Status := 1;
             END IF;
         END IF;
         l_stmt_no := 190;
         IF ( l_assy_pick_components_flag = 'Y' AND l_assy_bom_item_type IN ( 1, 2) AND
              component.replenish_to_order_flag = 'Y' AND component.bom_item_type = 4 AND
               NVL(component.base_item_id,0) = 0 AND component.OPTIONAL = 2 ) THEN
             fnd_message.set_name('BOM','BOM_COMP_OPTIONAL');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         ELSIF ( l_assy_bom_item_type IN (3,4) AND component.OPTIONAL = 1 ) THEN
             fnd_message.set_name('BOM','BOM_COMP_NOT_OPTIONAL');
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         END IF;
         l_stmt_no := 200;
         IF component.required_for_revenue = 1 AND component.required_to_ship = 2 AND l_assy_atp_comp_flag = 'Y' THEN
             fnd_message.set_name('BOM','BOM_COMP_REQ_FOR_REV_INVALID');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         ELSIF component.required_to_ship = 1 AND component.required_for_revenue = 2 AND l_assy_atp_comp_flag = 'Y' THEN
             fnd_message.set_name('BOM','BOM_COMP_REQ_TO_SHIP_INVALID');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         ELSIF component.required_to_ship = 1 AND component.required_for_revenue = 1 AND l_assy_atp_comp_flag = 'Y' THEN
             fnd_message.set_name('BOM','BOM_COMP_REQ_TO_SHIP_INVALID');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             fnd_message.set_name('BOM','BOM_COMP_REQ_FOR_REV_INVALID');
             fnd_message.set_token('REVISED_COMPONENT_NAME', G_COMP_ITEM_NAME);
             fnd_message.set_token('REVISED_ITEM_NAME', G_ASSY_ITEM_NAME);
             x_Error_Message := substr(x_Error_Message||FND_CONST.NEWLINE||fnd_message.get,1,2000) ;
             x_Return_Status := 1;
         END IF;
         l_stmt_no := 210;
         v_icc_comp_tbl(component.component_item_id).bill_sequence_id := component.bill_sequence_id;
         v_icc_comp_tbl(component.component_item_id).component_item_id := component.component_item_id;
         v_icc_comp_tbl(component.component_item_id).component_sequence_id := component.component_sequence_id;
         v_icc_comp_tbl(component.component_item_id).is_component_present := component.is_component_present;
     end loop;
     l_stmt_no := 220;
     if x_Return_Status <> 0 then
         return;
     end if;
     l_stmt_no := 230;
     /* Get components that are valid only for current revision */
     begin
         select bcb.component_sequence_id,bcb.component_item_id,bcb.from_end_item_rev_id,bcb.to_end_item_rev_id,bcb.inherit_flag
         bulk collect into v_item_comp_tbl
         from bom_components_b bcb
         where bcb.bill_sequence_id = l_item_bill_sequence_id
         and bcb.inherit_flag = 1
         and (p_rev_date between EGO_ICC_STRUCTURE_PVT.get_revision_start_date(bcb.from_end_item_rev_id) and
                                 EGO_ICC_STRUCTURE_PVT.get_revision_end_date(nvl(bcb.to_end_item_rev_id,-1)));
     exception
         when others then
             null;
     end;
     l_stmt_no := 240;
     l_upd_cntr := 0;
     l_ins_cntr := 0;

     for cntr in 1..v_item_comp_tbl.count loop
         l_comp_id := v_item_comp_tbl(cntr).component_item_id;
         l_stmt_no := 250;
         -- Start: Process components existing in both ICC and Item structure with same attributes
         if v_icc_comp_tbl.exists(l_comp_id) and
            EGO_ICC_STRUCTURE_PVT.Compare_components(v_item_comp_tbl(cntr).component_sequence_id,
                                                     v_icc_comp_tbl(l_comp_id).component_sequence_id) = 0 then
             /* If the component has same attributes as that in ICC component list, We do not need to process it. */
             l_stmt_no := 260;
             v_icc_comp_tbl(l_comp_id).is_component_present := 1;
         else

             /* Processing components having differing attributes is same as component not found in ICC.
                But we need to additionally insert a new row with modified attributes. * /

             /* Say we are updating revision B's date. If loop handles below cases :
                A - null, A - B,  A - C   Revision A can be any of the earlier revisions. */
             -- Start: Process Components efeective from previous revisions
             l_stmt_no := 270;
             if (v_rev_index(v_item_comp_tbl(cntr).from_end_item_rev_id) <= v_rev_index(l_prev_rev_id)) and -- if-4
                (v_rev_index(nvl(v_item_comp_tbl(cntr).to_end_item_rev_id,p_revision_id)) >= v_rev_index(p_revision_id)) then

                 /*  As the comp is not present for current rev, Upd to_end_item_rev_id = l_prev_rev_id.  for eg: A - A  */
                 l_upd_cntr := l_upd_cntr+1;
                 v_update_comp_tbl(l_upd_cntr).component_sequence_id := v_item_comp_tbl(cntr).component_sequence_id;
                 v_update_comp_tbl(l_upd_cntr).component_item_id := v_item_comp_tbl(cntr).component_item_id;
                 v_update_comp_tbl(l_upd_cntr).from_revision_id := v_item_comp_tbl(cntr).from_end_item_rev_id;
                 v_update_comp_tbl(l_upd_cntr).to_revision_id := l_prev_rev_id;
                 l_stmt_no := 280;
                 if v_item_comp_tbl(cntr).to_end_item_rev_id is null then -- if-2
                     if l_next_rev_id is not null then   -- if-1
                         /* In case of A - C,A - null and next rev exists, Insert with from_rev_id as l_next_rev_id. For eg : C - C,C - null */
                         l_stmt_no := 290;
                         l_ins_cntr := l_ins_cntr+1;
                         v_insert_comp_tbl(l_ins_cntr).component_sequence_id := v_item_comp_tbl(cntr).component_sequence_id;
                         v_insert_comp_tbl(l_ins_cntr).component_item_id := v_item_comp_tbl(cntr).component_item_id;
                         v_insert_comp_tbl(l_ins_cntr).from_revision_id := l_next_rev_id;
                         v_insert_comp_tbl(l_ins_cntr).to_revision_id := null;
                         v_insert_comp_tbl(l_ins_cntr).bill_seq_id := l_item_bill_sequence_id;
                     end if; -- if-1
                 else
                     if v_rev_index(v_item_comp_tbl(cntr).to_end_item_rev_id) > v_rev_index(p_revision_id) then -- if-3
                         /* If to_rev_id is not null and greater than current rev, then insert Eg : C - null or C - D */
                         l_stmt_no := 300;
                         l_ins_cntr := l_ins_cntr+1;
                         v_insert_comp_tbl(l_ins_cntr).component_sequence_id := v_item_comp_tbl(cntr).component_sequence_id;
                         v_insert_comp_tbl(l_ins_cntr).component_item_id := v_item_comp_tbl(cntr).component_item_id;
                         v_insert_comp_tbl(l_ins_cntr).from_revision_id := l_next_rev_id;
                         v_insert_comp_tbl(l_ins_cntr).to_revision_id := v_item_comp_tbl(cntr).to_end_item_rev_id;
                         v_insert_comp_tbl(l_ins_cntr).bill_seq_id := l_item_bill_sequence_id;
                     end if; -- if-3
                end if; -- if-2
            else
                /* This else handles comp with from_rev_id as current rev. Eg : B - B, B - C, B - null */
                -- Start: Process Components efeective from current revision
                l_stmt_no := 310;
                if v_item_comp_tbl(cntr).from_end_item_rev_id = p_revision_id then  -- if-5
                    if v_item_comp_tbl(cntr).to_end_item_rev_id = p_revision_id then --if-6
                        /* Deleting the comp and its attributes. if it exists only for the current revision. */
                        l_stmt_no := 320;
                        Delete_Comp_User_Attrs(v_item_comp_tbl(cntr).component_sequence_id);

                        delete from bom_components_b
                        where component_sequence_id = v_item_comp_tbl(cntr).component_sequence_id;

                    else
                        if v_item_comp_tbl(cntr).to_end_item_rev_id is null then -- if-7
                            if l_next_rev_id is not null then -- if-8
                                 /* In case of B - C or B - null and next rev exists :
                                    Inserting a row with from_rev_id as l_next_rev_id. For eg : C - C or C - null */
                                 l_stmt_no := 330;
                                 l_upd_cntr := l_upd_cntr+1;
                                 v_update_comp_tbl(l_upd_cntr).component_sequence_id := v_item_comp_tbl(cntr).component_sequence_id;
                                 v_update_comp_tbl(l_upd_cntr).component_item_id := v_item_comp_tbl(cntr).component_item_id;
                                 v_update_comp_tbl(l_upd_cntr).from_revision_id := l_next_rev_id;
                                 v_update_comp_tbl(l_upd_cntr).to_revision_id := v_item_comp_tbl(cntr).to_end_item_rev_id;
                             else
                                 /* Delete if component and its attributes which exists as B - null  */
                                 l_stmt_no := 340;
                                 Delete_Comp_User_Attrs(v_item_comp_tbl(cntr).component_sequence_id);

                                 delete from bom_components_b
                                 where component_sequence_id = v_item_comp_tbl(cntr).component_sequence_id;
                             end if; -- if-8
                         else
                             /* If to_rev_id is not null then update from_rev_id. For eg : C - null or C - D */
                             l_stmt_no := 350;
                             l_upd_cntr := l_upd_cntr+1;
                             v_update_comp_tbl(l_upd_cntr).component_sequence_id := v_item_comp_tbl(cntr).component_sequence_id;
                             v_update_comp_tbl(l_upd_cntr).component_item_id := v_item_comp_tbl(cntr).component_item_id;
                             v_update_comp_tbl(l_upd_cntr).from_revision_id := l_next_rev_id;
                             v_update_comp_tbl(l_upd_cntr).to_revision_id := v_item_comp_tbl(cntr).to_end_item_rev_id;
                         end if; --if-7
                     end if; -- if-6
                 end if; -- if-5
                 -- End: Process Components efeective from current revision
             end if; --if-4
             -- End: Process Components efeective from previous revisions
         end if;
         -- End: Process components existing in both ICC and Item structure with same attributes
     end loop;
     l_stmt_no := 360;
     -- process rows which earlier didn't exist in item structure.
     l_icc_index := v_icc_comp_tbl.first;
     while l_icc_index <= v_icc_comp_tbl.last loop
         if v_icc_comp_tbl(l_icc_index).is_component_present = 0 then
             l_stmt_no := 370;
             l_ins_cntr := l_ins_cntr+1;
             v_insert_comp_tbl(l_ins_cntr).component_sequence_id := v_icc_comp_tbl(l_icc_index).component_sequence_id;
             v_insert_comp_tbl(l_ins_cntr).component_item_id := v_icc_comp_tbl(l_icc_index).component_item_id;
             v_insert_comp_tbl(l_ins_cntr).from_revision_id := p_revision_id;
             v_insert_comp_tbl(l_ins_cntr).bill_seq_id := v_icc_comp_tbl(l_icc_index).bill_sequence_id;
             -- Modified
             If l_next_rev_id is null then
                 v_insert_comp_tbl(l_ins_cntr).to_revision_id := l_next_rev_id;
             Else
                 v_insert_comp_tbl(l_ins_cntr).to_revision_id := p_revision_id;
             End If;
         end if;
         l_icc_index := v_icc_comp_tbl.next(l_icc_index);
         l_stmt_no := 380;
     end loop;
     l_stmt_no := 390;
     select data_level_id
     into l_data_level_id
     from ego_data_level_b
     where data_level_name = 'COMPONENTS_LEVEL'
     and attr_group_type = 'BOM_COMPONENTMGMT_GROUP'
     and application_id = 702;
     l_stmt_no := 400;
     -- Create UDA values for the new components created.
     for cntr in 1..v_insert_comp_tbl.count loop
            l_stmt_no := 410;
            l_item_seq_incr := l_item_seq_incr + to_number(l_item_seq_incr_prof);

            select BOM_INVENTORY_COMPONENTS_S.NEXTVAL
            into l_new_component_seq_id
            from dual;
            l_stmt_no := 420;
            Insert into BOM_COMPONENTS_B
            (OPERATION_SEQ_NUM,
             COMPONENT_ITEM_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN,
             ITEM_NUM,
             COMPONENT_QUANTITY,
             COMPONENT_YIELD_FACTOR,
             EFFECTIVITY_DATE,
             IMPLEMENTATION_DATE,
             PLANNING_FACTOR,
             QUANTITY_RELATED,
             SO_BASIS,
             OPTIONAL,
             MUTUALLY_EXCLUSIVE_OPTIONS,
             INCLUDE_IN_COST_ROLLUP,
             CHECK_ATP,
             SHIPPING_ALLOWED,
             REQUIRED_TO_SHIP,
             REQUIRED_FOR_REVENUE,
             INCLUDE_ON_SHIP_DOCS,
             COMPONENT_SEQUENCE_ID,
             BILL_SEQUENCE_ID,
             WIP_SUPPLY_TYPE,
             PICK_COMPONENTS,
             SUPPLY_SUBINVENTORY,
             SUPPLY_LOCATOR_ID,
             BOM_ITEM_TYPE,
             ENFORCE_INT_REQUIREMENTS,
             COMPONENT_ITEM_REVISION_ID,
             PARENT_BILL_SEQ_ID,
             AUTO_REQUEST_MATERIAL,
             PK1_VALUE,
             PK2_VALUE,
             PK3_VALUE,
             PK4_VALUE,
             PK5_VALUE,
             FROM_END_ITEM_REV_ID,
             TO_END_ITEM_REV_ID,
             FROM_OBJECT_REVISION_ID,
             TO_OBJECT_REVISION_ID,
             INHERIT_FLAG,
             COMPONENT_REMARKS,
             CHANGE_NOTICE,
             BASIS_TYPE,
             LOW_QUANTITY,
             HIGH_QUANTITY)
             select
             BCB.OPERATION_SEQ_NUM,
             BCB.COMPONENT_ITEM_ID,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             fnd_global.login_id,
             l_item_seq_incr,
             BCB.COMPONENT_QUANTITY,
             BCB.COMPONENT_YIELD_FACTOR,
             BCB.EFFECTIVITY_DATE,
             BCB.IMPLEMENTATION_DATE,
             BCB.PLANNING_FACTOR,
             BCB.QUANTITY_RELATED,
             BCB.SO_BASIS,
             BCB.OPTIONAL,
             BCB.MUTUALLY_EXCLUSIVE_OPTIONS,
             BCB.INCLUDE_IN_COST_ROLLUP,
             BCB.CHECK_ATP,
             BCB.SHIPPING_ALLOWED,
             BCB.REQUIRED_TO_SHIP,
             BCB.REQUIRED_FOR_REVENUE,
             BCB.INCLUDE_ON_SHIP_DOCS,
             l_new_component_seq_id,
             l_item_bill_sequence_id,
             BCB.WIP_SUPPLY_TYPE,
             BCB.PICK_COMPONENTS,
             BCB.SUPPLY_SUBINVENTORY,
             BCB.SUPPLY_LOCATOR_ID,
             BCB.BOM_ITEM_TYPE,
             BCB.ENFORCE_INT_REQUIREMENTS,
             BCB.COMPONENT_ITEM_REVISION_ID,
             null,
             BCB.AUTO_REQUEST_MATERIAL,
             BCB.PK1_VALUE,
             BCB.PK2_VALUE,
             BCB.PK3_VALUE,
             BCB.PK4_VALUE,
             BCB.PK5_VALUE,
             v_insert_comp_tbl(cntr).from_revision_id,
             v_insert_comp_tbl(cntr).to_revision_id,
             v_insert_comp_tbl(cntr).from_revision_id,
             v_insert_comp_tbl(cntr).to_revision_id,
             1,
             BCB.COMPONENT_REMARKS,
             BCB.CHANGE_NOTICE,
             BCB.BASIS_TYPE,
             BCB.LOW_QUANTITY,
             BCB.HIGH_QUANTITY
             from BOM_COMPONENTS_B BCB
             where
             BCB.COMPONENT_SEQUENCE_ID = v_insert_comp_tbl(cntr).component_sequence_id;
             /* UT Fix : Commented as Comp_seq_id is alone enough to find a record in bom_components_b  */
             -- and BCB.BILL_SEQUENCE_ID = l_catalog_bill_sequence_id) );
           l_stmt_no := 430;
           l_src_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                      to_char(v_insert_comp_tbl(cntr).component_sequence_id)),
                                                                        EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                      to_char(v_insert_comp_tbl(cntr).bill_seq_id)));
           l_dest_pk_col_name_val_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'COMPONENT_SEQUENCE_ID' ,
                                                                                                      l_new_component_seq_id),
                                                                         EGO_COL_NAME_VALUE_PAIR_OBJ( 'BILL_SEQUENCE_ID' ,
                                                                                                      to_char(l_item_bill_sequence_id)));
           l_str_type := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'STRUCTURE_TYPE_ID',
                                                                                     TO_CHAR(l_catalog_str_type_id)));
           l_data_level_pks :=  EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ( 'CONTEXT_ID' , null));
           l_stmt_no := 440;
           EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data
               (
                   p_api_version                   => 1.0
                  ,p_application_id                => 702
                  ,p_object_name                   => 'BOM_COMPONENTS'
                  ,p_old_pk_col_value_pairs        => l_src_pk_col_name_val_pairs
                  ,p_new_pk_col_value_pairs        => l_dest_pk_col_name_val_pairs
                  ,p_old_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_new_dtlevel_col_value_pairs   => l_data_level_pks
                  ,p_old_data_level_id             => l_data_level_id
                  ,p_new_data_level_id             => l_data_level_id
                  ,p_new_cc_col_value_pairs        => l_str_type
                  ,x_return_status                 => l_Return_Status
                  ,x_errorcode                     => l_errorcode
                  ,x_msg_count                     => l_msg_count
                  ,x_msg_data                      => l_msg_data
               );
            l_stmt_no := 450;
            IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
                x_Return_Status := 1;
                x_Error_Message := l_msg_data;
                exit;
            END IF;

    end loop;
    l_stmt_no := 460;
    -- update bom_components_b based on v_update_comp_tbl.
    -- Modified Since 10G doesn't support BULK In-BIND table of records. Only 11G supports it.

/*    forall upd_index in v_update_comp_tbl.first..v_update_comp_tbl.last
    update bom_components_b set
    from_end_item_rev_id = v_update_comp_tbl(upd_index).from_revision_id,
    to_end_item_rev_id = v_update_comp_tbl(upd_index).to_revision_id,
    from_object_revision_id = v_update_comp_tbl(upd_index).from_revision_id,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id
    where
    component_sequence_id = v_update_comp_tbl(upd_index).component_sequence_id;  */
    l_stmt_no := 470;
    if v_update_comp_tbl.exists(v_update_comp_tbl.first) then
        for upd_index in v_update_comp_tbl.first..v_update_comp_tbl.last
        loop
            update bom_components_b
            set
              from_end_item_rev_id = v_update_comp_tbl(upd_index).from_revision_id,
              to_end_item_rev_id = v_update_comp_tbl(upd_index).to_revision_id,
              from_object_revision_id = v_update_comp_tbl(upd_index).from_revision_id,
              last_update_date = sysdate,
              last_updated_by = fnd_global.user_id,
              last_update_login = fnd_global.login_id
            where
            component_sequence_id = v_update_comp_tbl(upd_index).component_sequence_id;
        end loop;
    end if;
    l_stmt_no := 480;
    if l_item_bill_sequence_id is not null then
        /* UT Fix : Assigned ass_item_id to global variable and this value will be used in  validate_component_overlap. */
        G_INV_ITEM_ID := p_inventory_item_id;
        --x_Return_Status := validate_component_overlap(l_item_bill_sequence_id);

        x_Return_Status := validate_component_overlap(p_bill_seq_id => l_item_bill_sequence_id,
                                                      p_alt_desg    => G_ALTCODE,
                                                      x_error_msg   => x_Error_Message);
        l_stmt_no := 490;
    end if;

EXCEPTION
    WHEN others THEN
        x_Return_Status := 1;
        x_Error_Message := x_Return_Status||'UnHandled exception while inheriting structure components('||l_stmt_no||') : '||sqlerrm(sqlcode);

END inherit_icc_components;

Function  Is_Structure_Inheriting(p_item_catalog_grp_id IN NUMBER,
                                  p_organization_id     IN NUMBER,
                                  p_inv_item_id         IN NUMBER,
                                  p_structure_type_id   IN NUMBER,
                                  p_alt_desig           IN VARCHAR2)
RETURN NUMBER
IS
    l_return_status Number;
    l_effective_version Number;
    l_bill_seq_id Number;

    cursor item_revisions is
    select effectivity_date
    from mtl_item_revisions_b
    where inventory_item_id = p_inv_item_id
    and organization_id = p_organization_id;

BEGIN

    for revision in item_revisions loop

        begin

            select 1
            into l_return_status
            from dual
            where exists (select 1
                          from (select item_catalog_group_id
                                from mtl_item_catalog_groups_b
                                connect by prior parent_catalog_group_id = item_catalog_group_id
                                start with item_catalog_group_id = p_item_catalog_grp_id) icc,
                               bom_structures_b icc_structure,
                               bom_components_b icc_str_components
                          where icc_structure.pk1_value = icc.item_catalog_group_id
                          and   icc_structure.pk2_value = p_organization_id
                          and   icc_structure.obj_name = 'EGO_CATALOG_GROUP'
                          and   icc_structure.structure_type_id = p_structure_type_id
                          and   icc_structure.alternate_bom_designator = p_alt_desig
                          and   icc_structure.assembly_type = 2
                          and   icc_structure.effectivity_control = 4
                          and   icc_structure.bill_sequence_id = icc_str_components.bill_sequence_id
                          and   nvl(icc_str_components.parent_bill_seq_id,icc_str_components.bill_sequence_id) = icc_structure.bill_sequence_id
                          and icc_str_components.from_object_revision_id = EGO_ICC_STRUCTURE_PVT.Get_Effective_Version(icc_structure.pk1_value,
                                                                                                                       revision.effectivity_date)
                          and rownum = 1);

        exception
            when no_data_found then
                l_return_status := 0;
        end;

        if l_return_status = 1 then
            exit;
        end if;

    end loop;
    return l_return_status;
EXCEPTION
    WHEN OTHERS THEN
        return 0;
END Is_Structure_Inheriting;

/*
 * This Procedure creates default structure header for versioned ICCs based on its hierarchy.
 * This procedure has autonomous commit since, it will be called from ICC Structures Page processRequest().
 */
Procedure Create_Default_Header(p_item_catalog_grp_id IN NUMBER,
                                p_commit_flag IN NUMBER)
IS
PRAGMA autonomous_transaction;

    l_create_header Number := 0;
    l_bill_sequence_id Number;

    cursor Get_str_catalog_hierarchy
    IS
    select structures.bill_sequence_id
    from ( select item_catalog_group_id
           from mtl_item_catalog_groups_b
           connect by prior parent_catalog_group_id = item_catalog_group_id
           start with item_catalog_group_id = p_item_catalog_grp_id ) icc,
         BOM_STRUCTURES_B structures
    where structures.pk1_value = icc.item_catalog_group_id
    and structures.obj_name = 'EGO_CATALOG_GROUP'
    and rownum = 1;

Begin

    /* We need to create structure header only for versioned ICCs which doesn't have structure header already. */

    select 1
    into l_create_header
    from dual
    where exists (select 1
                  from EGO_MTL_CATALOG_GRP_VERS_B
                  where item_catalog_group_id = p_item_catalog_grp_id)
    and not exists (select 1
                    from BOM_STRUCTURES_B
                    where pk1_value = p_item_catalog_grp_id
                    and obj_name = 'EGO_CATALOG_GROUP');

    if l_create_header = 1 then

        for icc_structure in Get_str_catalog_hierarchy loop

            select bom_inventory_components_s.nextval
            into l_bill_sequence_id
            from dual;

            insert into BOM_STRUCTURES_B
            (BILL_SEQUENCE_ID,
             SOURCE_BILL_SEQUENCE_ID,
             COMMON_BILL_SEQUENCE_ID,
             ORGANIZATION_ID,
             ALTERNATE_BOM_DESIGNATOR,
             ASSEMBLY_TYPE,
             STRUCTURE_TYPE_ID,
             EFFECTIVITY_CONTROL,
             IS_PREFERRED,
             OBJ_NAME,
             PK1_VALUE,
             PK2_VALUE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN)
            select
             l_bill_sequence_id,
             l_bill_sequence_id,
             l_bill_sequence_id,
             ORGANIZATION_ID,
             ALTERNATE_BOM_DESIGNATOR,
             ASSEMBLY_TYPE,
             STRUCTURE_TYPE_ID,
             EFFECTIVITY_CONTROL,
             IS_PREFERRED,
             OBJ_NAME,
             p_item_catalog_grp_id,
             PK2_VALUE,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             CREATION_DATE,
             CREATED_BY,
             LAST_UPDATE_LOGIN
            from BOM_STRUCTURES_B
            where BILL_SEQUENCE_ID = icc_structure.bill_sequence_id ;

        end loop;

    end if;

    if p_commit_flag = 1 then
        commit;
    end if;

Exception
    when others then
        null;
End Create_Default_Header;

/*
 * This Function gives whether Parent-ICC is updatable for a ICC.
 */
Function Is_Parent_Updatable(p_item_catalog_grp_id IN NUMBER)
Return NUMBER
IS
    l_updatable Number := 0 ;
Begin

    select 1
    into l_updatable
    from dual
    where not exists (select 1
                      from BOM_STRUCTURES_B bsb,
                           (select item_catalog_group_id
                            from mtl_item_catalog_groups_b
                            connect by prior item_catalog_group_id = parent_catalog_group_id
                            start with item_catalog_group_id = p_item_catalog_grp_id ) child_icc
                      where bsb.pk1_value = child_icc.item_catalog_group_id
                      and bsb.obj_name = 'EGO_CATALOG_GROUP'
                      and rownum = 1);

    return l_updatable;
Exception
    when others then
        return 0;
End Is_Parent_Updatable;

/*
 * This Function Validates component Base Attributes.
 */
Function Validate_Base_attributes(
  p_organization_id             IN NUMBER,
  p_operation_seq_num           IN NUMBER,
  p_component_item_id           IN NUMBER,
  p_item_num                    IN NUMBER,
  p_basis_type                  IN NUMBER,
  p_component_quantity          IN NUMBER,
  p_component_yield_factor      IN NUMBER,
  p_component_remarks           IN VARCHAR2,
  p_planning_factor             IN NUMBER,
  p_quantity_related            IN NUMBER,
  p_so_basis                    IN NUMBER,
  p_optional                    IN NUMBER,
  p_mutually_exclusive_options  IN NUMBER,
  p_include_in_cost_rollup      IN NUMBER,
  p_check_atp                   IN NUMBER,
  p_shipping_allowed            IN NUMBER,
  p_required_to_ship            IN NUMBER,
  p_required_for_revenue        IN NUMBER,
  p_include_on_ship_docs        IN NUMBER,
  p_low_quantity                IN NUMBER,
  p_high_quantity               IN NUMBER,
  p_component_sequence_id       IN NUMBER,
  p_bill_sequence_id            IN NUMBER,
  p_wip_supply_type             IN NUMBER,
  p_pick_components             IN NUMBER,
  p_supply_subinventory         IN VARCHAR2,
  p_supply_locator_id           IN NUMBER,
  p_bom_item_type               IN NUMBER,
  p_component_item_revision_id  IN NUMBER,
  p_enforce_int_requirements    IN NUMBER,
  p_auto_request_material       IN VARCHAR2,
  p_component_name              IN VARCHAR2)
Return NUMBER
IS
    l_val_failure Number := 0 ;
    l_dummy Number;
    l_Bom_Status VARCHAR2(80);
    l_Industry VARCHAR2(80);
    l_org_locator_control Number := 0;
    l_item_locator_control Number := 0;
    l_locator_control Number;
    l_sub_locator_control Number :=0;
Begin
    FND_MSG_PUB.Delete_Msg(null);
    if p_component_yield_factor is null then
        FND_MESSAGE.set_name('BOM', 'BOM_COMP_YIELD_MISSING');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if (p_component_yield_factor is not null AND
       (p_component_yield_factor < 0 OR p_component_yield_factor > 1 )) then
        FND_MESSAGE.set_name('BOM', 'BOM_COMPYIELD_OUT_OF_RANGE');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    -- Component is Option Class and yield <> 1
    if nvl(p_component_yield_factor,1) <> 1 and
       p_bom_item_type = 2 then
        FND_MESSAGE.set_name('BOM', 'BOM_COMP_YIELD_NOT_ONE');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MESSAGE.set_token('REVISED_ITEM_NAME', null);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    -- Enforce_Integer can be UP only if rounding control type allows to round order quantities.
    if p_enforce_int_requirements = 1 then
        BEGIN
            select 1
            into l_dummy
            from mtl_system_items
            where inventory_item_id = p_component_item_id
            and organization_id = p_organization_id
            and rounding_control_type = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.set_name('BOM', 'BOM_ENFORCE_INT_INVALID');
                FND_MSG_PUB.add;
                l_val_failure := l_val_failure+1;
        END;
    end if;

    if p_basis_type = 2 and p_wip_supply_type = 6 then
        FND_MESSAGE.set_name('BOM', 'BOM_LOT_BASED_PHANTOM');
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if ( p_basis_type = 2 and ( p_optional = 1 or p_bom_item_type in (1,2))) THEN
        FND_MESSAGE.set_name('BOM', 'BOM_LOT_BASED_ATO');
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if p_auto_request_material IS NOT NULL AND upper(p_auto_request_material) NOT IN ('Y','N') THEN
        FND_MESSAGE.set_name('BOM', 'BOM_AUTO_REQ_MAT_INVALID');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MESSAGE.set_token('AUTO_REQ_MATERIAL', p_auto_request_material);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if NVL(p_high_quantity,p_component_quantity) < NVL(p_component_quantity,0) THEN
        FND_MESSAGE.set_name('BOM', 'BOM_MAX_QUANTITY_INVALID');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if NVL(p_low_quantity, p_component_quantity) > NVL(p_component_quantity,0) THEN
        FND_MESSAGE.set_name('BOM', 'BOM_MIN_QUANTITY_INVALID');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if BOM_EAMUTIL.Asset_Activity_Item(item_id => p_component_item_id,
                                       org_id  => p_organization_id ) = 'Y' and
       p_wip_supply_type NOT IN (1,4) THEN
        FND_MESSAGE.set_name('BOM', 'BOM_INVALID_AA_SUPTYPES');
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if p_wip_supply_type is not null and p_wip_supply_type = 7 THEN
        FND_MESSAGE.set_name('BOM', 'BOM_WIP_SUPPLY_TYPE_7');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MESSAGE.set_token('WIP_SUPPLY_TYPE', 'Based On Bill');
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if p_check_atp = 1 and p_component_quantity < 0 THEN
        FND_MESSAGE.set_name('BOM', 'BOM_COMP_QTY_NEGATIVE');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    if p_pick_components = 1 and p_component_quantity < 0 THEN
        FND_MESSAGE.set_name('BOM', 'BOM_COMP_PTO_QTY_NEGATIVE');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    end if;

    IF p_mutually_exclusive_options = 1 THEN
        IF Fnd_Installation.Get( appl_id     => '702',
                                 dep_appl_id => '702',
                                 status      => l_bom_status,
                                 industry    => l_industry)  AND
           p_bom_item_type IN (1,2) THEN
            null;
        ELSIF p_bom_item_type NOT IN (1,2) THEN
            FND_MESSAGE.set_name('BOM', 'BOM_MUT_EXCL_NOT_MDL_OPTCLASS');
            FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
            FND_MSG_PUB.add;
            l_val_failure := l_val_failure+1;
        ELSE
            FND_MESSAGE.set_name('BOM', 'BOM_MUT_EXCL_BOM_NOT_INST');
            FND_MSG_PUB.add;
            l_val_failure := l_val_failure+1;
        END IF;
    ELSE
        null;
    END IF;

    IF p_so_basis = 1 AND p_bom_item_type <> Bom_Globals.G_OPTION_CLASS THEN
        FND_MESSAGE.set_name('BOM', 'BOM_SO_BASIS_ONE');
        FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
        FND_MSG_PUB.add;
        l_val_failure := l_val_failure+1;
    END IF;

    Begin
        SELECT stock_locator_control_code INTO l_org_locator_control
        FROM mtl_parameters WHERE organization_id = p_organization_id;

        SELECT location_control_code INTO l_item_locator_control
        FROM mtl_system_items
        WHERE organization_id = p_organization_id AND inventory_item_id = p_component_item_id;

        SELECT  LOCATOR_TYPE into l_sub_locator_control
        FROM    MTL_SECONDARY_INVENTORIES
        WHERE   ORGANIZATION_ID = p_organization_id and SECONDARY_INVENTORY_NAME = p_supply_subinventory;

        l_locator_control := BOM_Validate_Bom_Component.Control
                              ( Org_Control  => l_org_locator_control,
                                Sub_Control  => l_item_locator_control,
                                Item_Control => l_sub_locator_control);

        if l_locator_control = 1 and p_supply_locator_id is null then
            FND_MESSAGE.set_name('BOM', 'BOM_LOCATOR_REQUIRED');
            FND_MESSAGE.set_token('REVISED_COMPONENT_NAME', p_component_name);
            FND_MSG_PUB.add;
            l_val_failure := l_val_failure+1;
        end if;
    Exception
        when others then
            null;
    End;

    return l_val_failure;

Exception
    when others then
        FND_MSG_PUB.Add_Exc_Msg('EGO_ICC_STRUCTURE_PVT','Validate_Base_attributes',sqlerrm(sqlcode));
        return 1;
End Validate_Base_attributes;

END EGO_ICC_STRUCTURE_PVT;

/
