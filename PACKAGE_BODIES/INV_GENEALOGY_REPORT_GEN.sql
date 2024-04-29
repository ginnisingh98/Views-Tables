--------------------------------------------------------
--  DDL for Package Body INV_GENEALOGY_REPORT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_GENEALOGY_REPORT_GEN" AS
  /* $Header: INVLTGNB.pls 120.11.12010000.3 2010/02/10 14:32:12 skommine ship $ */
  --
  -- File        : INVLTGNB.pls
  -- Content     : inv_genealogy_report_gen Body
  -- Description : generate XML file for genealogy report
  -- Notes       :
  -- Modified    : 07/18/05 lgao created orginal file
  --
  g_pkg_name                 CONSTANT VARCHAR2(30) := 'inv_genealogy_report_gen';
  g_debug                    NUMBER;
  g_inventory_item_id        NUMBER;
  g_organization_id          NUMBER;
  g_organization_desc        VARCHAR2(240);
  g_tracking_quantity_ind    mtl_system_items_kfv.tracking_quantity_ind%type; --Bug#5436402
  g_wip_entity_id            NUMBER;
  g_wip_entity_type          NUMBER;
  g_current_org_id           NUMBER;
  g_include_txns             VARCHAR2(1);
  g_include_move_txns        VARCHAR2(1);
  g_include_pending_txns     VARCHAR2(1);
  g_include_grd_sts          VARCHAR2(1);
  g_quality_control          VARCHAR2(1);
  g_genealogy_type           NUMBER;
  g_genealogy_type_code      VARCHAR2(100);

TYPE item_array IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

Procedure XML_write
  ( column_name                IN VARCHAR2
  , column_value                IN VARCHAR2
  ) ;

procedure write_genealogy_report
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER
   );
PROCEDURE write_query_input
  (p_organization_code          IN  VARCHAR2
  ,p_item_no                    IN  VARCHAR2 DEFAULT null
  ,p_lot_number                 IN  VARCHAR2 DEFAULT null
  ,p_serial_number              IN  VARCHAR2 DEFAULT null
  ,p_wip_entity_name            IN  VARCHAR2 DEFAULT null
  ,p_include_txns               IN  VARCHAR2 DEFAULT 'N'
  ,p_include_move_txns          IN  VARCHAR2 DEFAULT 'N'
  ,p_include_pending_txns       IN  VARCHAR2 DEFAULT 'N'
  ,p_include_grd_sts            IN  VARCHAR2 DEFAULT 'N'
  ,p_quality_control            IN  VARCHAR2 DEFAULT 'N'
  ,p_genealogy_type             IN  NUMBER   DEFAULT 1
   );
Procedure write_header_info
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_item_no             IN VARCHAR2
   , p_lot_number          IN VARCHAR2
   , p_serial_number       IN VARCHAR2
   , p_wip_entity_name     IN VARCHAR2
   , p_level               IN NUMBER    -- 1 query item, 2 component item
   );
Procedure write_item_info
   ( p_item_info_rec       IN OUT NOCOPY inv_genealogy_report_gen.item_info_rec_type
   );

Procedure write_lot_info
   ( p_lot_attributes_rec  IN OUT NOCOPY inv_genealogy_report_gen.lot_attributes_rec_type
   );

Procedure write_serial_info
   ( p_serial_attributes_rec  IN OUT NOCOPY inv_genealogy_report_gen.serial_attributes_rec_type
   );

Procedure write_work_order_info
   ( p_work_order_header_rec     IN OUT NOCOPY inv_genealogy_report_gen.work_order_header_rec_type
   , p_work_order_dtl_rec        IN OUT NOCOPY inv_genealogy_report_gen.work_order_dtl_rec_type
   , p_item_info_rec             IN OUT NOCOPY inv_genealogy_report_gen.item_info_rec_type
   );

Procedure write_material_txn_info
   ( p_material_txn_rec     IN OUT NOCOPY inv_genealogy_report_gen.material_txn_rec_type
   );

Procedure write_pending_txn_info
   ( p_pending_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.pending_txn_rec_type
   );

Procedure write_product_info
   ( p_product_rec      IN OUT NOCOPY inv_genealogy_report_gen.product_rec_type
   );

Procedure write_component_info
   ( p_component_rec      IN OUT NOCOPY inv_genealogy_report_gen.component_rec_type
   );

Procedure write_quality_collections_info
   ( p_quality_collections_rec      IN OUT NOCOPY inv_genealogy_report_gen.quality_collections_rec_type
   );

Procedure write_quality_samples_info
   ( p_quality_samples_rec      IN OUT NOCOPY inv_genealogy_report_gen.quality_samples_rec_type
   );

Procedure write_lotbased_wip_txn_info
   ( p_lotbased_wip_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.lotbased_wip_txn_rec_type
   );

Procedure write_move_txn_info
   ( p_move_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.move_txn_rec_type
   );

Procedure write_grade_status_info
   ( p_grade_status_rec      IN OUT NOCOPY inv_genealogy_report_gen.grade_status_rec_type
   );

procedure get_all_children
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   );
procedure get_one_level_child
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) ;
procedure write_children_reports
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) ;

procedure get_all_parents
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   );

procedure write_parent_reports
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   );

Procedure Write_tree_node
  (p_object_id                  IN NUMBER
  ,p_object_type                IN NUMBER
  ,p_object_id2                 IN NUMBER
  ,p_object_type2               IN NUMBER
  ,p_level                      IN NUMBER  -- 0, main level
  ,p_child_parent               IN NUMBER            -- 1 child, 2 parent
  );

procedure get_one_level_parent
   ( p_parent_object_id           IN NUMBER
   , p_parent_object_type         IN NUMBER
   , p_parent_object_id2          IN NUMBER
   , p_parent_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) ;

Procedure write_group_begin
  (column_name                  IN VARCHAR2
  ) ;
Procedure write_group_end
  (column_name                  IN VARCHAR2
  );

Function get_formula_security
  ( p_org_id                    IN NUMBER
   ,p_object_id                 IN NUMBER
   ,p_object_type               IN NUMBER) return NUMBER;

  --Procedures for logging messages
PROCEDURE debug(p_message VARCHAR2) IS
    l_module VARCHAR2(255);
BEGIN
    --l_module  := 'inv.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, g_pkg_name, 9);
    gmi_reservation_util.println(l_module ||' '|| p_message);
END debug;


/*
  p_organization_code is required
  p_item_no is required
  others are optional
*/
PROCEDURE genealogy_report
  (
   errbuf                       OUT NOCOPY VARCHAR2
  ,retcode                      OUT NOCOPY VARCHAR2
  ,p_organization_code          IN  VARCHAR2
  ,p_item_no                    IN  VARCHAR2 DEFAULT null
  ,p_lot_number                 IN  VARCHAR2 DEFAULT null
  ,p_serial_number              IN  VARCHAR2 DEFAULT null
  ,p_wip_entity_name            IN  VARCHAR2 DEFAULT null
  ,p_include_txns               IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_move_txns          IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_pending_txns       IN  VARCHAR2 DEFAULT 'Y'
  ,p_include_grd_sts            IN  VARCHAR2 DEFAULT 'Y'
  ,p_quality_control            IN  VARCHAR2 DEFAULT 'Y'
  ,p_genealogy_type             IN  NUMBER   DEFAULT 1
   ) IS

type rc is ref cursor;
main_query rc;

l_main_query                    VARCHAR2(5000);
l_object_id                     NUMBER;
l_object_type                   NUMBER;
l_object_id2                    NUMBER;
l_object_type2                  NUMBER;
l_data                          VARCHAR2(30);
l_object_name                   VARCHAR2(200);
l_object_description            VARCHAR2(720);
l_object_type_name              VARCHAR2(240);
l_unit_number                   VARCHAR2(60);
l_org_code                      VARCHAR2(3);
l_expiration_date               DATE;
l_inventory_item_id             NUMBER;
l_object_number                 VARCHAR2(1200);
l_material_status               VARCHAR2(30);
l_primary_uom                   VARCHAR2(3);
l_secondary_uom                 VARCHAR2(3);
l_start_quantity                NUMBER;
l_status_type_disp              VARCHAR2(2000);
l_assembly                      VARCHAR2(2000);
l_assembly_description          VARCHAR2(2000);
l_datalength                    NUMBER;
l_wip_entity_id                 NUMBER;
l_operation_seq_num             NUMBER;
l_intraoperation_step_type      NUMBER;
l_wip_entity_type               NUMBER;
l_wip_entity_name               VARCHAR2(240);
l_step                          VARCHAR2(2000);
l_current_lot_number            VARCHAR2(80);

--Bug#5436402 getting tracking_quantity_ind also
Cursor get_item_info is
Select inventory_item_id, tracking_quantity_ind
From mtl_system_items_kfv
Where concatenated_segments = p_item_no
   and organization_id = g_organization_id;

Cursor get_wip_info is
Select wip_entity_id
    ,  entity_type
From wip_entities
Where organization_id = g_organization_id
  and wip_entity_name= p_wip_entity_name
  ;

Begin
  debug('Generate Genealogy Report ');
  debug('p_organization_code '||p_organization_code);
  debug('p_item_no '||p_item_no);
  debug('p_lot_number '||p_lot_number);
  debug('p_serial_number '||p_serial_number);
  debug('p_wip_entity_name '||p_wip_entity_name);
  write_group_begin('INVLTGEN');      -- the main group for the report

  write_query_input
     (p_organization_code          => p_organization_code
     ,p_item_no                    => p_item_no
     ,p_lot_number                 => p_lot_number
     ,p_serial_number              => p_serial_number
     ,p_wip_entity_name            => p_wip_entity_name
     ,p_include_txns               => p_include_txns
     ,p_include_move_txns          => p_include_move_txns
     ,p_include_pending_txns       => p_include_pending_txns
     ,p_include_grd_sts            => p_include_grd_sts
     ,p_quality_control            => p_quality_control
     ,p_genealogy_type             => p_genealogy_type
     );

  -- get item info
  --Bug#5436402 getting tracking_quantity_ind also
  Open get_item_info;
  Fetch get_item_info into g_inventory_item_id, g_tracking_quantity_ind;
  Close get_item_info;

  -- get wip info
  if p_wip_entity_name is not null then
     Open get_wip_info;
     Fetch get_wip_info into g_wip_entity_id, g_wip_entity_type;
     Close get_wip_info;
  end if;

  debug('item info, item_id '||g_inventory_item_id);
  g_include_txns             := p_include_txns;
  g_include_move_txns        := p_include_move_txns;
  g_include_pending_txns     := p_include_pending_txns;
  g_include_grd_sts          := p_include_grd_sts;
  g_quality_control          := p_quality_control;
  g_genealogy_type := p_genealogy_type;

  -- construct the cursor query_item based on the query input
/* we need a few cursors for the main query
  1) only item and org
  2) serial number is not null, generic query for lot_number and wip
  3) only serial number
  4) only wip name
  5) lot + wip
 */
  if g_wip_entity_id is null then
     g_wip_entity_id := -9999;
  end if;

  if p_lot_number is null
   and p_serial_number is null
   and p_wip_entity_name is null
  then
     l_main_query := ' Select gen_object_id        object_id'
                   ||'     ,  1                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_lot_numbers'
                   ||' Where inventory_item_id = '||g_inventory_item_id
                   ||'   and organization_id = '||g_organization_id
                   ||'   and lot_number not in (Select lot_number '
                   ||'                         from mtl_serial_numbers'
                   ||'                         where lot_number is not null) '
                   ||' Union all'
                   ||' Select gen_object_id        object_id'
                   ||'     ,  5                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_serial_numbers'
                   ||' Where inventory_item_id = '||g_inventory_item_id
                   ;
  elsif p_serial_number is not null
    and p_wip_entity_name is null then
     l_main_query := ' Select gen_object_id        object_id'
                   ||'     ,  2                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_serial_numbers'
                   ||' Where inventory_item_id =' || g_inventory_item_id
                   ||'   and serial_number = '||''''||p_serial_number||''''
                   ||'   and decode(lot_number, null, '||''''||'%%%%%'||''''||', lot_number) '
                   ||'     = decode('||''''||p_lot_number||''''||', null, '||''''||'%%%%%'||''''||','||''''||p_lot_number||''''||')'
                   ;
  elsif p_lot_number is not null
   and p_serial_number is null
   and p_wip_entity_name is null
  then
     l_main_query := ' Select gen_object_id        object_id'
                   ||'     ,  2                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_serial_numbers'
                   ||' Where inventory_item_id = '||g_inventory_item_id
                   ||'   and lot_number = '||''''||p_lot_number||''''
                   ||' Union all '
                   ||' Select gen_object_id        object_id'
                   ||'     ,  1                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_lot_numbers'
                   ||' Where inventory_item_id = '||g_inventory_item_id
                   ||'   and organization_id = '||g_organization_id
                   ||'   and lot_number = '||''''||p_lot_number||''''
                   ||'   and lot_number not in (Select lot_number'
                   ||'                          From mtl_serial_numbers'
                   ||'                          Where lot_number is not null )'
                   ;
  elsif p_wip_entity_name is not null
   and p_lot_number is null
   and p_serial_number is null
  then
     l_main_query := ' Select gen_object_id        object_id'
                   ||'     ,  5                    object_type'
                   ||'     ,  null                 lot_number'
                   ||' From wip_entities'
                   ||' Where primary_item_id = '||g_inventory_item_id
                   ||'   and organization_id = '||g_organization_id
                   ||'   and wip_entity_name = '||''''||p_wip_entity_name||''''
                   ;
     /*l_main_query := ' Select gen_object_id        object_id'
                   ||'     ,  5                    object_type'
                   ||' From wsm_discrete_jobs_lotattr_v'
                   ||' Where primary_item_id = '||g_inventory_item_id
                   ||'   and organization_id = '||g_organization_id
                   ||'   and wip_entity_name = '||p_wip_entity_name
                   ||' Union All'
                   ||' Select gen_object_id        object_id'
                   ||'     ,  5                    object_type'
                   ||' From mtl_mfg_genealogy_lotattr_v'
                   ||' Where primary_item_id = '||g_inventory_item_id
                   ||'   and organization_id = '||g_organization_id
                   ||'   and wip_entity_name = '||p_wip_entity_name
                   ||' Union All'
                   ;
     */
  elsif p_wip_entity_name is not null
   and p_lot_number is not null
   and p_serial_number is null
  then
     l_main_query := ' Select we.gen_object_id     object_id'
                   ||'     ,  5                    object_type'
                   ||'     ,  mln.lot_number       lot_number'
                   ||' From wip_entities  we'
                   ||'   ,  mtl_lot_numbers mln'
                   ||' Where we.primary_item_id = '||g_inventory_item_id
                   ||'   and we.organization_id = '||g_organization_id
                   ||'   and we.organization_id = mln.organization_id'
                   ||'   and mln.inventory_item_id = we.primary_item_id'
                   ||'   and mln.lot_number = '||''''||p_lot_number||''''
                   ||'   and we.wip_entity_name = '||''''||p_wip_entity_name||''''
                   ;
  elsif p_wip_entity_name is not null
   and p_lot_number is null
   and p_serial_number is not null
  then
     l_main_query := ' Select we.gen_object_id     object_id'
                   ||'     ,  5                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_serial_numbers msn '
                   ||'    , wip_entities       we '
                   ||' Where msn.serial_number = '||''''|| p_serial_number||''''
                   ||'   and we.wip_entity_name = '||''''||p_wip_entity_name||''''
                   --||'   and we.wip_entity_id = msn.wip_entity_id '
                   ||'   and we.primary_item_id = msn.inventory_item_id '
                   ;
  elsif p_wip_entity_name is not null
   and p_lot_number is not null
   and p_serial_number is not null
  then
     l_main_query := ' Select we.gen_object_id     object_id'
                   ||'     ,  5                    object_type'
                   ||'     ,  lot_number           lot_number'
                   ||' From mtl_serial_numbers msn '
                   ||'    , wip_entities       we '
                   ||' Where msn.serial_number = '||''''|| p_serial_number||''''
                   ||'   and we.wip_entity_name = '||''''||p_wip_entity_name||''''
                   ||'   and msn.lot_number = '||''''||p_lot_number||''''
                   ||'   and we.primary_item_id = msn.inventory_item_id '
                   ;
  end if;

  debug('main query '||l_main_query);
  -- do the loop for each tree node to get all the reports
  Open main_query for l_main_query;
  Loop
     Fetch main_query into l_object_id, l_object_type, l_current_lot_number;
        Exit when main_query %NOTFOUND;
        debug('main query object_id '||l_object_id ||' object_type '||l_object_type);
        if l_object_type = 2 and l_current_lot_number is not null then
           Select gen_object_id
             ,    1
           Into l_object_id2
             ,  l_object_type2
           From mtl_lot_numbers
           Where lot_number = l_current_lot_number
           and   organization_id = g_organization_id
           and   inventory_item_id = g_inventory_item_id;
        end if;
        write_genealogy_report
                     ( p_object_id           => l_object_id
                     , p_object_type         => l_object_type
                     , p_object_id2          => l_object_id2
                     , p_object_type2        => l_object_type2
                     , p_level               => 0
                     );

        /* write the child or parent reports*/
        if p_genealogy_type = 1 then
           get_all_children
                 (  p_object_id       => l_object_id
                  , p_object_type     => l_object_type
                  , p_object_id2      => l_object_id2
                  , p_object_type2    => l_object_type2
                 );
        else
           get_all_parents
                 (  p_object_id       => l_object_id
                  , p_object_type     => l_object_type
                  , p_object_id2      => l_object_id2
                  , p_object_type2    => l_object_type2
                 );
        end if;

     --write_group_end('ITEM_INFO');      -- the item_info
  end loop;
  Close main_query;
  write_group_end('INVLTGEN');      -- the main group for the report
End genealogy_report;

PROCEDURE write_query_input
  (p_organization_code          IN  VARCHAR2
  ,p_item_no                    IN  VARCHAR2 DEFAULT null
  ,p_lot_number                 IN  VARCHAR2 DEFAULT null
  ,p_serial_number              IN  VARCHAR2 DEFAULT null
  ,p_wip_entity_name            IN  VARCHAR2 DEFAULT null
  ,p_include_txns               IN  VARCHAR2 DEFAULT 'N'
  ,p_include_move_txns          IN  VARCHAR2 DEFAULT 'N'
  ,p_include_pending_txns       IN  VARCHAR2 DEFAULT 'N'
  ,p_include_grd_sts            IN  VARCHAR2 DEFAULT 'N'
  ,p_quality_control            IN  VARCHAR2 DEFAULT 'N'
  ,p_genealogy_type             IN  NUMBER   DEFAULT 1
   ) IS
l_org_desc                      VARCHAR2(240);
   Cursor get_organization is
     SELECT mp.organization_id
       ,   hou.NAME
    FROM mtl_parameters mp
       , hr_organization_units hou
   WHERE mp.organization_code = p_organization_code
     AND hou.organization_id = mp.organization_id;

   Cursor get_genealogy_type is
     Select meaning
     From mfg_lookups
     where lookup_type='INV_REPORT_GENEALOGY_TYPE'
       and lookup_code = g_genealogy_type;
Begin
  debug('write query input');
  write_group_begin('Query_Input');
  open get_organization;
  Fetch get_organization into g_organization_id, g_organization_desc;
  Close get_organization;

  XML_write('org_code',p_organization_code);
  XML_write('org_desc',g_organization_desc);
  XML_write('item_no',p_item_no);
  XML_write('lot_number',p_lot_number);
  XML_write('serial_number',p_serial_number);
  XML_write('job_batch',p_wip_entity_name);
  XML_write('include_material_transactions',p_include_txns);
  XML_write('include_move_transactions',p_include_move_txns);
  XML_write('include_pending_transactions',p_include_pending_txns);
  XML_write('include_grade_status',p_include_grd_sts);
  XML_write('include_QC',p_quality_control);
  XML_write('genealogy_type',p_genealogy_type);

  /*Open get_genealogy_type;
  Fetch get_genealogy_type into g_genealogy_type_code;
  Close get_genealogy_type;

  debug('write query input, catergory_code '||g_genealogy_type_code);
  XML_write('report_catergory', g_genealogy_type_code);
  */
  if p_genealogy_type = 1 then
     XML_write('report_catergory','Source');
  else
     XML_write('report_catergory','Where Used');
  end if;
  write_group_end('Query_Input');

End write_query_input;

Procedure write_header_info
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_item_no             IN VARCHAR2
   , p_lot_number          IN VARCHAR2
   , p_serial_number       IN VARCHAR2
   , p_wip_entity_name     IN VARCHAR2
   , p_level               IN NUMBER    -- 1 query item, 2 component item
   ) IS
l_object_label      VARCHAR2(1200);
Begin
  debug('Write header info');
  write_group_begin('Header_info');
  if p_item_no is not null then
     if p_level = 1 then
        XML_write('item_assembly', 'Query Item: '||p_item_no);
     else
        XML_write('item_assembly', 'Component Item: '||p_item_no);
     end if;
  end if;
  l_object_label  := inv_object_genealogy.getobjectnumber
              (p_object_id, p_object_type, p_object_id2, p_object_type2);
  XML_write('object_label', l_object_label);
  if p_lot_number is not null then
     XML_write('lot', 'Lot: '||p_lot_number);
  end if;
  if p_serial_number is not null then
     XML_write('serial', 'Serial: '||p_serial_number);
  end if;
  if p_wip_entity_name is not null then
     XML_write('job_batch', 'Job/Batch: '||p_wip_entity_name);
  end if;
     XML_write('header2_item', 'Item: '||p_item_no);
  write_group_end('Header_info');
End write_header_info;

procedure write_genealogy_report
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER
   ) IS
l_object_id                     NUMBER;
l_object_type                   NUMBER;
l_object_id2                    NUMBER;
l_object_type2                  NUMBER;
l_data                          VARCHAR2(30);
l_object_name                   VARCHAR2(200);
l_object_description            VARCHAR2(720);
l_object_type_name              VARCHAR2(240);
l_unit_number                   VARCHAR2(60);
l_org_code                      VARCHAR2(3);
l_expiration_date               DATE;
l_inventory_item_id             NUMBER;
l_object_number                 VARCHAR2(1200);
l_material_status               VARCHAR2(30);
l_primary_uom                   VARCHAR2(3);
l_secondary_uom                 VARCHAR2(3);
l_start_quantity                NUMBER;
l_status_type_disp              VARCHAR2(2000);
l_assembly                      VARCHAR2(2000);
l_assembly_description          VARCHAR2(2000);
l_datalength                    NUMBER;
l_wip_entity_id                 NUMBER;
l_operation_seq_num             NUMBER;
l_intraoperation_step_type      NUMBER;
l_wip_entity_type               NUMBER;
l_wip_entity_name               VARCHAR2(240);
l_step                          VARCHAR2(2000);
l_current_lot_number            VARCHAR2(80);
l_current_org_id                NUMBER;
l_current_org_code              VARCHAR2(5);
l_current_org_desc              VARCHAR2(50);
l_allow_security                VARCHAR2(1);
l_security                      Number;
x_return_status                 VARCHAR2(5);

l_item_info_rec                 inv_genealogy_report_gen.item_info_rec_type;
l_lot_attributes_rec            inv_genealogy_report_gen.lot_attributes_rec_type;
l_serial_attributes_rec         inv_genealogy_report_gen.serial_attributes_rec_type;
l_work_order_header_rec         inv_genealogy_report_gen.work_order_header_rec_type;
l_work_order_dtl_rec            inv_genealogy_report_gen.work_order_dtl_rec_type  ;
l_material_txn_rec              inv_genealogy_report_gen.material_txn_rec_type   ;
l_pending_txn_rec               inv_genealogy_report_gen.pending_txn_rec_type   ;
l_product_rec                   inv_genealogy_report_gen.product_rec_type  ;
l_component_rec                 inv_genealogy_report_gen.component_rec_type  ;
l_quality_collections_rec       inv_genealogy_report_gen.quality_collections_rec_type;
l_quality_samples_rec           inv_genealogy_report_gen.quality_samples_rec_type;
l_move_txn_rec                  inv_genealogy_report_gen.move_txn_rec_type  ;
l_lotbased_wip_txn_rec          inv_genealogy_report_gen.lotbased_wip_txn_rec_type  ;
l_grade_status_rec              inv_genealogy_report_gen.grade_status_rec_type  ;

Cursor get_wip IS
    SELECT wip_entity_name
       ,   entity_type
       ,   organization_id
       ,   wip_entity_id
       ,   primary_item_id
      FROM wip_entities
     WHERE gen_object_id = l_object_id
     ;
Cursor get_gme_security Is
Select 1
From gme_batch_header_vw
Where batch_id = l_wip_entity_id;
Begin
  -- Sort out object information
  debug('writing report for object_type '||p_object_type||' object_id '||p_object_id
        ||'object_type2 '||p_object_type2|| 'object_id2 '||p_object_id2);
  l_object_id := p_object_id;
  l_object_type := p_object_type;
  l_object_id2 := p_object_id2;
  l_object_type2 := p_object_type2;
  l_security := 1;

  IF l_object_type = 1 THEN
    SELECT mp.organization_code
         , hou.NAME
         , mln.organization_id
      INTO l_current_org_code
         , l_current_org_desc
         , l_current_org_id
      FROM mtl_parameters mp
         , hr_organization_units hou
         , mtl_lot_numbers mln
     WHERE mln.gen_object_id = l_object_id
       AND mp.organization_id = mln.organization_id
       AND hou.organization_id = mln.organization_id;
  ELSIF l_object_type = 2 THEN
    SELECT mp.organization_code
         , hou.NAME
         , msn.current_organization_id
      INTO l_current_org_code
         , l_current_org_desc
         , l_current_org_id
      FROM mtl_parameters mp
         , hr_organization_units hou
         , mtl_serial_numbers msn
     WHERE msn.gen_object_id = l_object_id
       AND mp.organization_id = msn.current_organization_id
       AND hou.organization_id = msn.current_organization_id;
  END IF;

  IF l_object_type = 2 THEN
    inv_object_genealogy.getobjectinfo(
      l_object_id
    , l_object_type
    , l_object_name
    , l_object_description
    , l_object_type_name
    , l_expiration_date
    , l_primary_uom
    , l_inventory_item_id
    , l_object_number
    , l_material_status
    , l_unit_number
    , l_wip_entity_id
    , l_operation_seq_num
    , l_intraoperation_step_type
    , l_current_lot_number
    );
  ELSIF l_object_type = 1 Then
    inv_object_genealogy.getobjectinfo(
      l_object_id
    , l_object_type
    , l_object_name
    , l_object_description
    , l_object_type_name
    , l_expiration_date
    , l_primary_uom
    , l_inventory_item_id
    , l_object_number
    , l_material_status
    , l_unit_number
    );
  END IF;

  g_current_org_id := l_current_org_id;

  l_item_info_rec.inventory_item_id := l_inventory_item_id;
  l_item_info_rec.item_no           := l_object_name;
  l_item_info_rec.item_desc         := l_object_description;
  l_item_info_rec.primary_uom       := l_primary_uom;
  --l_item_info_rec.secondary_uom     := l_secondary_uom;

  l_lot_attributes_rec.expiration_date := l_expiration_date;
  l_lot_attributes_rec.lot_number := l_current_lot_number;
  if (l_object_type = 1 or (l_object_type = 2 and l_current_lot_number is not null)) then
     l_lot_attributes_rec.object_id         := l_object_id;
     l_lot_attributes_rec.status            := l_material_status;
     if l_object_type = 1 then
        l_lot_attributes_rec.lot_number        := l_object_number;
     else
        l_lot_attributes_rec.lot_number        := l_current_lot_number;
     end if;
     l_lot_attributes_rec.organization_id   := l_current_org_id  ;
     l_lot_attributes_rec.org_code          := l_current_org_code  ;
     l_lot_attributes_rec.org_desc          := l_current_org_desc  ;
     l_lot_attributes_rec.inventory_item_id := l_inventory_item_id ;
  end if;

  l_serial_attributes_rec.unit_number := l_unit_number;
  if (l_object_type = 2 ) then
     l_serial_attributes_rec.object_id      := l_object_id;
     l_serial_attributes_rec.status         := l_material_status;
     l_serial_attributes_rec.serial_number  := l_object_number;
     l_serial_attributes_rec.org_code       := l_current_org_code  ;
     l_serial_attributes_rec.org_desc       := l_current_org_desc  ;
  end if;

  if (l_object_type = 5 ) then
    Open get_wip;
    Fetch get_wip
    INTO l_wip_entity_name
        ,  l_wip_entity_type
        ,  l_current_org_id
        ,  l_wip_entity_id
        ,  l_inventory_item_id
        ;
    Close get_wip;
    /*
    SELECT wip_entity_name
       ,   entity_type
       ,   organization_id
       ,   wip_entity_id
       ,   primary_item_id
      INTO l_wip_entity_name
        ,  l_wip_entity_type
        ,  l_current_org_id
        ,  l_wip_entity_id
        ,  l_inventory_item_id
      FROM wip_entities
     WHERE wip_entity_id = l_object_id;
     */
     l_work_order_header_rec.object_id         := l_object_id;
     l_work_order_header_rec.work_order_number := l_wip_entity_name;
     l_work_order_header_rec.wip_entity_type   := l_wip_entity_type;
     l_work_order_header_rec.wip_entity_id     := l_wip_entity_id;
     l_work_order_header_rec.current_org_id    := l_current_org_id;
     l_work_order_header_rec.org_code          := l_current_org_code;
     l_work_order_header_rec.org_desc          := l_current_org_desc;
     l_work_order_header_rec.prod_item_id      := l_inventory_item_id;
     if l_wip_entity_type in (9, 10) then
        l_work_order_header_rec.work_order_type := 'BATCH';
        GMD_API_GRP.fetch_parm_values(g_current_org_id,'GMI_LOTGENE_ENABLE_FMSEC',l_allow_security,x_return_status);
        if (l_allow_security = '1' or l_allow_security = 'Y') then
           l_security := 0 ;       -- set it to 0
           Open get_gme_security;
           Fetch get_gme_security into l_security;
           Close get_gme_security;
        End if;
        debug('    Gme security is '||l_security);
     else
        l_work_order_header_rec.work_order_type := 'JOBS';
     end if;
     -- find out he product name by query for the product_item_id

  END IF;

  write_group_begin('ITEM_INFO');
  write_header_info
               ( p_object_id           => l_object_id
               , p_object_type         => l_object_type
               , p_object_id2          => l_object_id2
               , p_object_type2        => l_object_type2
               , p_item_no             => l_item_info_rec.item_no
               , p_lot_number          => l_lot_attributes_rec.lot_number
               , p_serial_number       => l_serial_attributes_rec.serial_number
               , p_wip_entity_name     => l_work_order_header_rec.work_order_number
               , p_level               => p_level
               );

  if p_level = 0 then
     debug('Write Main item Report');
     -- for the main query item
     --write_group_begin('tree_node_main_level');
     /* populate the child or parent tree for the main level*/
     if g_genealogy_type = 1 then
        write_tree_node (l_object_id, l_object_type, l_object_id2, l_object_type2, p_level, 1);
     else
        write_tree_node (l_object_id, l_object_type, l_object_id2, l_object_type2, p_level, 2);
     end if;
     --write_group_end('tree_node_main_level');
  end if;

  /*
  write_tree_node
           ( p_object_id        => l_object_id
           , p_object_type      => l_object_type
           , p_object_id2       => l_object_id2
           , p_object_type2     => l_object_type2
           );
  */
  l_item_info_rec.inventory_item_id      := l_inventory_item_id;
  l_lot_attributes_rec.inventory_item_id := l_inventory_item_id;
  write_item_info
           ( p_item_info_rec    => l_item_info_rec
           );
  write_lot_info
           ( p_lot_attributes_rec     => l_lot_attributes_rec
           );
  write_serial_info
           ( p_serial_attributes_rec     => l_serial_attributes_rec
           );
  write_work_order_info
           ( p_work_order_header_rec     => l_work_order_header_rec
            ,p_work_order_dtl_rec        => l_work_order_dtl_rec
            ,p_item_info_rec             => l_item_info_rec
           );
  if g_include_txns = 'Y' and l_security = 1 then
     l_material_txn_rec.object_id        := l_object_id;
     l_material_txn_rec.object_type      := l_object_type;
     l_material_txn_rec.current_org_id   := l_current_org_id;
     l_material_txn_rec.secondary_uom    := l_item_info_rec.secondary_uom;
     write_material_txn_info
           ( p_material_txn_rec          => l_material_txn_rec);
  end if;
  if g_include_pending_txns = 'Y' and l_security = 1 then
     l_pending_txn_rec.object_id        := l_object_id;
     l_pending_txn_rec.object_type      := l_object_type;
     l_pending_txn_rec.current_org_id   := l_current_org_id;
     l_pending_txn_rec.secondary_uom    := l_item_info_rec.secondary_uom;
     write_pending_txn_info
           ( p_pending_txn_rec           => l_pending_txn_rec);
  end if;
  if (g_genealogy_type = 2 and l_object_type <> 5) then
     l_product_rec.current_org_id        := l_current_org_id;
     l_product_rec.inventory_item_id     := l_item_info_rec.inventory_item_id;
     l_product_rec.comp_lot_number       := l_lot_attributes_rec.lot_number;
     l_product_rec.comp_serial_number    := l_serial_attributes_rec.serial_number;
     write_product_info
           ( p_product_rec               => l_product_rec
           );
  end if;
  if (g_genealogy_type = 1 and l_object_type <> 5) then
     l_component_rec.current_org_id        := l_current_org_id;
     l_component_rec.inventory_item_id     := l_item_info_rec.inventory_item_id;
     l_component_rec.product_lot_number    := l_lot_attributes_rec.lot_number;
     l_component_rec.product_serial_number := l_serial_attributes_rec.serial_number;
     l_component_rec.wip_entity_id         := l_work_order_header_rec.wip_entity_id;
     write_component_info
           ( p_component_rec             => l_component_rec
           );
  end if;
  if g_include_move_txns = 'Y' then
     l_lotbased_wip_txn_rec.object_id          := l_object_id;
     write_lotbased_wip_txn_info
           ( p_lotbased_wip_txn_rec         => l_lotbased_wip_txn_rec );
  end if;
  if g_quality_control = 'Y' then
     l_quality_collections_rec.inventory_item_id     := l_inventory_item_id;
     l_quality_collections_rec.wip_entity_id         := l_wip_entity_id;
     l_quality_collections_rec.lot_number            := l_lot_attributes_rec.lot_number;
     l_quality_collections_rec.serial_number         := l_serial_attributes_rec.serial_number;
     write_quality_collections_info
           ( p_quality_collections_rec    => l_quality_collections_rec );

     l_quality_samples_rec.sampling_event_id := l_lot_attributes_rec.sampling_event_id;
     l_quality_samples_rec.current_org_id := l_current_org_id;
     l_quality_samples_rec.inventory_item_id := l_inventory_item_id;
     l_quality_samples_rec.lot := l_lot_attributes_rec.lot_number;
     l_quality_samples_rec.parent_lot := l_lot_attributes_rec.parent_lot;
  write_quality_samples_info
           ( p_quality_samples_rec        => l_quality_samples_rec );
  end if;
  if g_include_move_txns = 'Y' then
     l_move_txn_rec.object_id          := l_object_id;
     l_move_txn_rec.wip_entity_id      := l_wip_entity_id;
     l_move_txn_rec.organization_id    := l_current_org_id;
     l_move_txn_rec.assembly           := l_work_order_header_rec.assembly;
     write_move_txn_info
           ( p_move_txn_rec         => l_move_txn_rec );
  end if;
  if g_include_grd_sts = 'Y' then
     l_grade_status_rec.inventory_item_id   := l_inventory_item_id;
     l_grade_status_rec.current_org_id      := l_current_org_id   ;
     l_grade_status_rec.uom                 := l_item_info_rec.primary_uom   ;
     l_grade_status_rec.secondary_uom       := l_item_info_rec.secondary_uom   ;
     l_grade_status_rec.lot_number          := l_lot_attributes_rec.lot_number   ;
     write_grade_status_info
           ( p_grade_status_rec          => l_grade_status_rec );
  end if;
  write_group_end('ITEM_INFO');

End write_genealogy_report;

Procedure write_item_info
           ( p_item_info_rec    IN OUT NOCOPY inv_genealogy_report_gen.item_info_rec_type
           ) IS
cursor get_more_item_info is
Select shelf_life_days
  ,    concatenated_segments
  ,    description
  ,    retest_interval
  ,    DECODE(tracking_quantity_ind,'PS',secondary_uom_code) secondary_uom_code --Bug#5436402
from mtl_system_items_kfv
where inventory_item_id= p_item_info_rec.inventory_item_id
  and organization_id = g_organization_id;
Begin
  debug('write item info');
  open get_more_item_info;
  fetch get_more_item_info
  into p_item_info_rec.shelf_life
    ,  p_item_info_rec.item_no
    ,  p_item_info_rec.item_desc
    ,  p_item_info_rec.retest_interval
    ,  p_item_info_rec.secondary_uom
    ;
  Close get_more_item_info;
  XML_write('organization_code', p_item_info_rec.org_code);
  XML_write('inventory_item_id', p_item_info_rec.inventory_item_id);
  XML_write('item_no', p_item_info_rec.item_no);
  XML_write('item_desc1', p_item_info_rec.item_desc);
  XML_write('shelf_life', p_item_info_rec.shelf_life);
  XML_write('retest_interval', p_item_info_rec.retest_interval);
End write_item_info;

Procedure write_lot_info
           ( p_lot_attributes_rec  IN OUT NOCOPY inv_genealogy_report_gen.lot_attributes_rec_type
           ) IS
l_orig_txn_id                NUMBER;
l_txn_action_id              NUMBER;
l_txn_type_id                NUMBER;
l_transaction_id             NUMBER;

cursor get_more_lot_info IS
select parent_lot_number
   ,   grade_code
   ,   retest_date
   ,   expiration_date
   ,   hold_date
   ,   vendor_name
   ,   origination_date
   ,   sampling_event_id
From mtl_lot_numbers
where lot_number = p_lot_attributes_rec.lot_number
and   organization_id = p_lot_attributes_rec.organization_id
and   inventory_item_id = p_lot_attributes_rec.inventory_item_id;

/*Cursor get_orig_txn_id	IS
Select origin_txn_id
From mtl_object_genealogy
Where object_id = p_lot_attributes_rec.object_id;
Cursor get_source_data	IS
Select transaction_source_name
      ,transaction_quantity
      ,transaction_uom
      ,receiving_document
      ,transaction_action_id
      ,transaction_date
From mtl_material_transactions
Where transaction_id = l_orig_txn_id;
Cursor get_txn_action_code	IS
Select meaning
From mfg_lookups
Where lookup_type = 'MTL_TRANSACTION_ACTION'
and   lookup_code = l_txn_action_id;
*/

Cursor get_orig_trans IS
Select transaction_id
     , transaction_source_name
     , transaction_source
     , transaction_date
     , transaction_uom
     , transaction_quantity
     , transaction_type_id
     , trading_partner
From mtl_transaction_details_v
Where object_id = p_lot_attributes_rec.object_id
Order by transaction_date asc;

Cursor get_type_name IS
Select mtt.transaction_type_name
From mtl_transaction_types mtt
Where mtt.transaction_type_id = l_txn_type_id;

Begin
  write_group_begin('Lot_attributes');
  Open get_more_lot_info;
  Fetch get_more_lot_info
  Into p_lot_attributes_rec.parent_lot
    ,  p_lot_attributes_rec.grade_code
    ,  p_lot_attributes_rec.retest_date
    ,  p_lot_attributes_rec.expiration_date
    ,  p_lot_attributes_rec.hold_date
    ,  p_lot_attributes_rec.supplier
    ,  p_lot_attributes_rec.init_date
    ,  p_lot_attributes_rec.sampling_event_id
    ;
  Close get_more_lot_info;

  Open get_orig_trans;
  Fetch get_orig_trans
     Into l_transaction_id
       ,  p_lot_attributes_rec.source_origin
       ,  p_lot_attributes_rec.document
       ,  p_lot_attributes_rec.init_date
       ,  p_lot_attributes_rec.uom
       ,  p_lot_attributes_rec.init_quantity
       ,  l_txn_type_id
       ,  p_lot_attributes_rec.supplier
       ;
  Close get_orig_trans;
  if nvl(l_txn_type_id,0)<>0 then
     Open get_type_name;
     Fetch get_type_name
     into p_lot_attributes_rec.init_transaction;
     Close get_type_name;
  end if;

  XML_write('lot_number', p_lot_attributes_rec.lot_number);
  XML_write('parent_lot', p_lot_attributes_rec.parent_lot);
  --Bug#5436511 Writing expiration tag to the XML file.
  XML_write('expiration_date', p_lot_attributes_rec.expiration_date);
  XML_write('lot_status', p_lot_attributes_rec.status);
  XML_write('grade_code', p_lot_attributes_rec.grade_code);
  XML_write('retest_date', p_lot_attributes_rec.retest_date);
  XML_write('hold_date', p_lot_attributes_rec.hold_date);
  XML_write('source_origin', p_lot_attributes_rec.source_origin);
  XML_write('init_quantity', p_lot_attributes_rec.init_quantity);
  XML_write('uom', p_lot_attributes_rec.uom);
  XML_write('init_transaction', p_lot_attributes_rec.init_transaction);
  XML_write('init_date', p_lot_attributes_rec.init_date);
  XML_write('document', p_lot_attributes_rec.document);
  XML_write('supplier', p_lot_attributes_rec.supplier);
  write_group_end('Lot_attributes');
End write_lot_info;

Procedure write_serial_info
  ( p_serial_attributes_rec  IN OUT NOCOPY inv_genealogy_report_gen.serial_attributes_rec_type
  ) IS
l_wip_entity_id              NUMBER;
l_inventory_item_id          NUMBER;

cursor get_more_serial_info is
select current_status_name
  ,    completion_date
  ,    ship_date
  ,    original_wip_entity_id
  ,    inventory_item_id
  ,    operation_seq_num
  ,    intraoperation_step_type
  ,    lot_number
from mtl_serial_numbers_all_v
where serial_number = p_serial_attributes_rec.serial_number
  and gen_object_id = p_serial_attributes_rec.object_id;

cursor get_job_info IS
select we.wip_entity_name
from wip_entities we
where we.wip_entity_id = p_serial_attributes_rec.wip_entity_id
;

Cursor get_intraoperation_step  IS
SELECT meaning
FROM   mfg_lookups
WHERE  lookup_type = 'WIP_INTRAOPERATION_STEP'
and    lookup_code = p_serial_attributes_rec.intraoperation_step_type;

Begin
  debug('Write Serial Info');
  write_group_begin('Serial_Info');
  Open get_more_serial_info;
  Fetch get_more_serial_info
  Into  p_serial_attributes_rec.state
     ,  p_serial_attributes_rec.receipt_date
     ,  p_serial_attributes_rec.ship_date
     ,  p_serial_attributes_rec.wip_entity_id
     ,  l_inventory_item_id
     ,  p_serial_attributes_rec.operation_seq_num
     ,  p_serial_attributes_rec.intraoperation_step_type
     ,  p_serial_attributes_rec.current_lot_number
     ;
  Close get_more_serial_info;

  if l_wip_entity_id is not null then
     Open get_job_info;
     Fetch get_job_info
     into p_serial_attributes_rec.job
       ;
     Close get_job_info;
  end if;

  open get_intraoperation_step;
  Fetch get_intraoperation_step into p_serial_attributes_rec.step;
  Close get_intraoperation_step;

  XML_write('unit_number', p_serial_attributes_rec.unit_number);
  XML_write('serial_number', p_serial_attributes_rec.serial_number);
  XML_write('serial_status', p_serial_attributes_rec.status);
  XML_write('state', p_serial_attributes_rec.state);
  XML_write('current_lot_number', p_serial_attributes_rec.current_lot_number);
  XML_write('receipt_date', p_serial_attributes_rec.receipt_date);
  XML_write('ship_date', p_serial_attributes_rec.ship_date);
  XML_write('job', p_serial_attributes_rec.job);
  XML_write('operation', p_serial_attributes_rec.operation_seq_num);
  XML_write('step', p_serial_attributes_rec.step);

  write_group_end('Serial_Info');
End write_serial_info;

Procedure write_work_order_info
   ( p_work_order_header_rec     IN OUT NOCOPY inv_genealogy_report_gen.work_order_header_rec_type
   , p_work_order_dtl_rec        IN OUT NOCOPY inv_genealogy_report_gen.work_order_dtl_rec_type
   , p_item_info_rec             IN OUT NOCOPY inv_genealogy_report_gen.item_info_rec_type
   ) IS

l_batch_status                  VARCHAR2(80);
l_job_status                    VARCHAR2(80);

l_select                        VARCHAR2(1000);
l_from                          VARCHAR2(200);
l_where                         VARCHAR2(200);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

cursor get_work_order_header is
Select  item_number
    ,   item_description
    ,   batch_status
    ,   status_type
    ,   organization_code
    ,   organization_name
    ,   work_order_type
    ,   wip_entity_name
    ,   date_released
    ,   date_completed
from mtl_work_order_header_v
where wip_entity_id = p_work_order_header_rec.wip_entity_id
;
cursor get_wip_dtl is
select  item_number
     ,  item_description
     ,  start_quantity
     ,  quantity_remaining
     ,  quantity_scrapped
     ,  quantity_completed
     ,  uom
from wsm_wip_genealogy_lotattr_v
where wip_entity_id = p_work_order_header_rec.wip_entity_id
;
cursor get_gme_dtl is
select  item_number
     ,  item_description
     ,  start_quantity
     ,  quantity_remaining
     ,  quantity_scrapped
     ,  quantity_completed
     ,  uom
from mtl_mfg_genealogy_lotattr_v
where wip_entity_id = p_work_order_header_rec.wip_entity_id
;
Begin
  debug('Write Work Order Info');

  Open get_work_order_header;
  Fetch get_work_order_header
  Into p_work_order_header_rec.assembly
    ,  p_work_order_header_rec.assembly_desc
    ,  l_batch_status
    ,  l_job_status
    ,  p_work_order_header_rec.org_code
    ,  p_work_order_header_rec.org_desc
    ,  p_work_order_header_rec.work_order_type
    ,  p_work_order_header_rec.work_order_number
    ,  p_work_order_header_rec.date_released
    ,  p_work_order_header_rec.date_completed
    ;
  Close get_work_order_header;

  if l_batch_status is not null then
    p_work_order_header_rec.status := l_batch_status;
  end if;
  if l_job_status is not null then
    p_work_order_header_rec.status := l_job_status;
  end if;

  write_group_begin('Work_order_header');
  XML_write('assembly', p_work_order_header_rec.assembly);
  XML_write('assembly_desc', p_work_order_header_rec.assembly_desc);
  XML_write('status', p_work_order_header_rec.status);
  XML_write('org_code', p_work_order_header_rec.org_code);
  XML_write('org_desc', p_work_order_header_rec.org_desc);
  XML_write('work_order_type', p_work_order_header_rec.work_order_type);
  XML_write('work_order_number', p_work_order_header_rec.work_order_number);
  XML_write('date_released', p_work_order_header_rec.date_released);
  XML_write('date_completed', p_work_order_header_rec.date_completed);
  write_group_end('Work_order_header');

  if p_work_order_header_rec.wip_entity_id is null then
     return;
  end if;
  l_select := 'select  item_number'
           ||'  ,  item_description'
           ||'  ,  start_quantity'
           ||'  ,  quantity_remaining'
           ||'  ,  quantity_scrapped'
           ||'  ,  quantity_completed'
           ||'  ,  uom'
           ;
  debug('wip_entity_type '||p_work_order_header_rec.wip_entity_type);
  if p_work_order_header_rec.wip_entity_type in (9, 10) then
     l_from := ' from mtl_mfg_genealogy_lotattr_v';
  else
     l_from := ' from wsm_wip_genealogy_lotattr_v';
  end if;

  l_where := ' where wip_entity_id = '||p_work_order_header_rec.wip_entity_id;

  l_query := l_select||l_from||l_where;
  --debug('work order dtl query: '||l_query);

  Open l_rec_query for l_query;
  Loop
     Fetch l_rec_query
     Into  p_work_order_dtl_rec.product
        ,  p_work_order_dtl_rec.product_desc
        ,  p_work_order_dtl_rec.planned_qty
        ,  p_work_order_dtl_rec.qty_remaining
        ,  p_work_order_dtl_rec.qty_scrapped
        ,  p_work_order_dtl_rec.qty_completed
        ,  p_work_order_dtl_rec.uom
        ;
     Exit when l_rec_query %NOTFOUND;

     write_group_begin('Work_order_details');
     XML_write('product', p_work_order_dtl_rec.product);
     XML_write('product_desc', p_work_order_dtl_rec.product_desc);
     XML_write('planned_qty', p_work_order_dtl_rec.planned_qty);
     XML_write('qty_scrapped', p_work_order_dtl_rec.qty_scrapped);
     XML_write('qty_remaining', p_work_order_dtl_rec.qty_remaining);
     XML_write('qty_completed', p_work_order_dtl_rec.qty_completed);
     XML_write('uom', p_work_order_dtl_rec.uom);
     write_group_end('Work_order_details');
  End loop;
  Close l_rec_query;

End write_work_order_info;

Procedure write_material_txn_info
   ( p_material_txn_rec     IN OUT NOCOPY inv_genealogy_report_gen.material_txn_rec_type
   ) IS

l_transaction_type_id           NUMBER;
l_locator_id                    NUMBER;
l_source_line_id                NUMBER;
l_source_code                   VARCHAR2(80);

l_select                        VARCHAR2(1000);
l_from                          VARCHAR2(200);
l_where                         VARCHAR2(200);
l_order_by                      VARCHAR2(200);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

cursor get_material_txns
is
select
     transaction_date
   , organization_code
   , transaction_source_name
   , transaction_type_id
   , transaction_source                   -- document?
   , transaction_quantity
   , transaction_uom
   , secondary_quantity
   , subinventory_code
   , locator_id
   , source_line_id
   , project
   , task
   , lpn_number
   , transfer_lpn_number
   , content_lpn_number
from mtl_transaction_details_v
where object_id = p_material_txn_rec.object_id
  and object_type = p_material_txn_rec.object_type
  and organization_id = p_material_txn_rec.current_org_id
  ;
cursor get_wip_material_txns
is
select
     transaction_date
   , organization_code
   , transaction_source_name
   , transaction_type_id
   , source_code                   -- document?
   , transaction_quantity
   , transaction_uom
   , secondary_quantity
   , subinventory_code
   , locator_id
   , source_line_id
   , project
   , task
   , lpn_number
   , transfer_lpn_number
   , content_lpn_number
from wsm_inv_txns_wip_lots_v
where object_id = p_material_txn_rec.object_id
  and object_type = p_material_txn_rec.object_type
  and organization_id = p_material_txn_rec.current_org_id
  ;
cursor get_gme_material_txns
is
select
     transaction_date
   , organization_code
   , transaction_source_name
   , transaction_type_id
   , source_code                   -- document?
   , transaction_quantity
   , transaction_uom
   , secondary_quantity
   , subinventory_code
   , locator_id
   , source_line_id
   , project
   , task
   , lpn_number
   , transfer_lpn_number
   , content_lpn_number
from mtl_inv_txns_mfg_lots_v
where object_id = p_material_txn_rec.object_id
  and object_type = p_material_txn_rec.object_type
  and organization_id = p_material_txn_rec.current_org_id
  ;

Begin
  debug('Write Material Txns');

  l_select := 'select'
             ||'   transaction_date'
             ||' , organization_code'
             ||' , transaction_source_name'
             ||' , transaction_source'
             ||' , transaction_type_id'
             ||' , source_code'
             ||' , transaction_quantity'
             ||' , transaction_uom'
             ||' , secondary_quantity'
             ||' , subinventory_code'
             ||' , locator_id'
             ||' , source_line_id'
             ||' , project'
             ||' , task'
             ||' , lpn_number'
             ||' , transfer_lpn_number'
             ||' , content_lpn_number'
             --Bug#5436511 Added grade_code column to the select statement.
             ||' , grade_code'
             ;
  l_where := ' where object_id = '||p_material_txn_rec.object_id
             ||' and object_type = '||p_material_txn_rec.object_type
             ||' and organization_id = '||p_material_txn_rec.current_org_id
             ;
  if p_material_txn_rec.object_type <> 5 then
     l_from := ' from mtl_transaction_details_v';
  elsif p_material_txn_rec.wip_entity_type in (9, 10) then
     l_from := ' from mtl_inv_txns_mfg_lots_v';
  else
     l_from := ' from wsm_inv_txns_wip_lots_v';
  end if;
  l_order_by := ' order by transaction_date desc';
  l_query := l_select||l_from||l_where||l_order_by;
  --debug('Material_txn Query: '||l_query);

  Open l_rec_query for l_query;
  Loop
     Fetch l_rec_query
     Into  p_material_txn_rec.transaction_date
        ,  p_material_txn_rec.organization
        ,  p_material_txn_rec.transaction_source_type
        ,  p_material_txn_rec.document
        ,  l_transaction_type_id
        ,  l_source_code
        ,  p_material_txn_rec.quantity
        ,  p_material_txn_rec.uom
        ,  p_material_txn_rec.secondary_quantity
        ,  p_material_txn_rec.subinventory
        ,  l_locator_id
        ,  l_source_line_id
        ,  p_material_txn_rec.project
        ,  p_material_txn_rec.task
        ,  p_material_txn_rec.lpn
        ,  p_material_txn_rec.transfer_lpn
        ,  p_material_txn_rec.content_lpn
        --Bug#5436511
        ,  p_material_txn_rec.grade
        ;
     Exit when l_rec_query %NOTFOUND;

     /*Bug#5436402 if the item is not tracked in Primary and Secondary then
       we should not display sec qty.sec uom is already filtered by the cursor cur_get_item_info*/
     IF g_tracking_quantity_ind <> 'PS' THEN
       p_material_txn_rec.secondary_quantity := NULL;
     END IF;

     p_material_txn_rec.locator := INV_PROJECT.GET_LOCATOR(l_locator_id,
                                    p_material_txn_rec.current_org_id) ;
     if (l_source_code='WSM'
        and p_material_txn_rec.object_type = 1
        and l_transaction_type_id in (32, 42) )
     then
        SELECT ml.meaning
             into p_material_txn_rec.TRANSACTION_TYPE
             from wsm_lot_split_merges wlsm
                , mfg_lookups ml
        where wlsm.transaction_id= l_source_line_id
        and ml.lookup_type='WSM_INV_LOT_TXN_TYPE'
        and ml.lookup_code=wlsm.transaction_type_id;
     else
       select mtt.transaction_type_name
       into p_material_txn_rec.transaction_type
       from MTL_TRANSACTION_TYPES mtt
       where mtt.transaction_type_id = l_transaction_type_id;
     end if;

     write_group_begin('transaction_details');
     XML_write('transaction_date', p_material_txn_rec.transaction_date);
     XML_write('organization', p_material_txn_rec.organization);
     XML_write('transaction_source_type', p_material_txn_rec.transaction_source_type);
     XML_write('transaction_type', p_material_txn_rec.transaction_type);
     XML_write('document', p_material_txn_rec.document);
     XML_write('quantity', p_material_txn_rec.quantity);
     XML_write('uom', p_material_txn_rec.uom);
     XML_write('secondary_quantity', p_material_txn_rec.secondary_quantity);
     XML_write('secondary_uom', p_material_txn_rec.secondary_uom);
     XML_write('subinventory', p_material_txn_rec.subinventory);
     XML_write('locator', p_material_txn_rec.locator);
     XML_write('project', p_material_txn_rec.project);
     XML_write('task', p_material_txn_rec.task);
     XML_write('lpn', p_material_txn_rec.lpn);
     XML_write('transfer_lpn', p_material_txn_rec.transfer_lpn);
     XML_write('content_lpn', p_material_txn_rec.content_lpn);
     XML_write('grade', p_material_txn_rec.grade);
     write_group_end('transaction_details');
  End loop;
  Close l_rec_query;
End write_material_txn_info;

Procedure write_pending_txn_info
   ( p_pending_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.pending_txn_rec_type
   ) IS
l_transaction_type_id           NUMBER;
l_locator_id                    NUMBER;
l_txn_status_code               NUMBER;
l_source_line_id                NUMBER;
l_source_code                   VARCHAR2(20);

l_select                        VARCHAR2(1000);
l_from                          VARCHAR2(200);
l_where                         VARCHAR2(200);
l_order_by                      VARCHAR2(200);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

cursor get_pending_txns
is
select
     transaction_date
   , organization_code
   , transaction_source_name
   , transaction_type_id
   , source_code                   -- document?
   , transaction_quantity
   , transaction_uom
   , secondary_quantity
   , subinventory_code
   , locator_id
   , source_line_id
   , project
   , task
   , lpn_number
   , transfer_lpn_number
   , content_lpn_number
   , transaction_status
from mtl_pending_txn_details_v
where object_id = p_pending_txn_rec.object_id
  and object_type = p_pending_txn_rec.object_type
  and organization_id = p_pending_txn_rec.current_org_id
  ;
cursor get_mfg_pending_txns
is
select
     transaction_date
   , organization_code
   , transaction_source_name
   , transaction_type_id
   , source_code                   -- document?
   , transaction_quantity
   , transaction_uom
   , secondary_quantity
   , subinventory_code
   , locator_id
   , source_line_id
   , project
   , task
   , lpn_number
   , transfer_lpn_number
   , content_lpn_number
   , transaction_status
from mtl_pending_txns_mfg_lots_v
where object_id = p_pending_txn_rec.object_id
  and object_type = p_pending_txn_rec.object_type
  and organization_id = p_pending_txn_rec.current_org_id
  ;
Begin
  debug('Write pending txns ');

  l_select := 'select transaction_date '
            ||'  , organization_code'
            ||'  , transaction_source_name'
            ||'  , transaction_type_id'
            ||'  , source_code'
            ||'  , transaction_quantity'
            ||'  , transaction_uom'
            ||'  , secondary_quantity'
            ||'  , subinventory_code'
            ||'  , locator_id'
            ||'  , source_line_id'
            ||'  , project'
            ||'  , task'
            ||'  , lpn_number'
            ||'  , transfer_lpn_number'
            ||'  , content_lpn_number'
            ||'  , transaction_status'
            ;
  l_where := ' where object_id = '||p_pending_txn_rec.object_id
            ||' and object_type = '||p_pending_txn_rec.object_type
            ||' and organization_id = '||p_pending_txn_rec.current_org_id
            ;
  if p_pending_txn_rec.object_type <> 5 then
     l_from := ' from mtl_pending_txn_details_v';
  else
     l_from := ' from mtl_pending_txns_mfg_lots_v';
  end if;

  l_order_by := ' order by transaction_date desc';
  l_query := l_select||l_from||l_where||l_order_by;
  --debug('Pending_txn Query: '||l_query);

  Open l_rec_query for l_query;
  Loop
     Fetch l_rec_query
     Into  p_pending_txn_rec.transaction_date
        ,  p_pending_txn_rec.organization
        ,  p_pending_txn_rec.transaction_source_type
        ,  l_transaction_type_id
        ,  l_source_code
        ,  p_pending_txn_rec.quantity
        ,  p_pending_txn_rec.uom
        ,  p_pending_txn_rec.secondary_quantity
        ,  p_pending_txn_rec.subinventory
        ,  l_locator_id
        ,  l_source_line_id
        ,  p_pending_txn_rec.project
        ,  p_pending_txn_rec.task
        ,  p_pending_txn_rec.lpn
        ,  p_pending_txn_rec.transfer_lpn
        ,  p_pending_txn_rec.content_lpn
        ,  l_txn_status_code
        ;
     Exit when l_rec_query %NOTFOUND;

     /*Bug#5436402 if the item is not tracked in Primary and Secondary then
       we should not display sec qty. sec uom is already filtered by the cursor cur_get_item_info*/
     IF g_tracking_quantity_ind <> 'PS' THEN
       p_pending_txn_rec.secondary_quantity := NULL;
     END IF;

     p_pending_txn_rec.locator := INV_PROJECT.GET_LOCATOR(l_locator_id,
                                    p_pending_txn_rec.current_org_id) ;
     if (l_source_code='WSM'
        and p_pending_txn_rec.object_type = 1
        and l_transaction_type_id in (32, 42) )
     then
        SELECT ml.meaning
             into p_pending_txn_rec.TRANSACTION_TYPE
             from wsm_lot_split_merges wlsm
                , mfg_lookups ml
        where wlsm.transaction_id= l_source_line_id
        and ml.lookup_type='WSM_INV_LOT_TXN_TYPE'
        and ml.lookup_code=wlsm.transaction_type_id;
     else
       select mtt.transaction_type_name
       into p_pending_txn_rec.transaction_type
       from MTL_TRANSACTION_TYPES mtt
       where mtt.transaction_type_id = l_transaction_type_id;
     end if;

     if l_txn_status_code = 2 then
       p_pending_txn_rec.transaction_status := 'Allocated';
     else
       p_pending_txn_rec.transaction_status := 'Pending';
     end if;

     write_group_begin('pending_transaction_details');
     XML_write('transaction_date', p_pending_txn_rec.transaction_date);
     XML_write('organization', p_pending_txn_rec.organization);
     XML_write('transaction_source_type', p_pending_txn_rec.transaction_source_type);
     XML_write('transaction_type', p_pending_txn_rec.transaction_type);
     XML_write('document', p_pending_txn_rec.document);
     XML_write('quantity', p_pending_txn_rec.quantity);
     XML_write('uom', p_pending_txn_rec.uom);
     XML_write('secondary_quantity', p_pending_txn_rec.secondary_quantity);
     XML_write('secondary_uom', p_pending_txn_rec.secondary_uom);
     XML_write('subinventory', p_pending_txn_rec.subinventory);
     XML_write('locator', p_pending_txn_rec.locator);
     XML_write('project', p_pending_txn_rec.project);
     XML_write('task', p_pending_txn_rec.task);
     XML_write('lpn', p_pending_txn_rec.lpn);
     XML_write('transfer_lpn', p_pending_txn_rec.transfer_lpn);
     XML_write('content_lpn', p_pending_txn_rec.content_lpn);
     XML_write('grade', p_pending_txn_rec.grade);
     write_group_end('pending_transaction_details');
  End loop;
  Close l_rec_query;

End write_pending_txn_info;

Procedure write_product_info
   ( p_product_rec      IN OUT NOCOPY inv_genealogy_report_gen.product_rec_type
   ) IS

l_locator_id              NUMBER;

l_select                        VARCHAR2(1000);
l_from                          VARCHAR2(200);
l_where                         VARCHAR2(200);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

cursor get_products is
select organization_code
   ,   transaction_date
   ,   item_number
   ,   item_type
   ,   lot_number
   ,   primary_quantity
   ,   primary_uom_code
   ,   secondary_quantity
   ,   secondary_uom_code
   ,   subinventory_code
   ,   locator_id
   ,   grade_code
   ,   serial_number
from mtl_mfg_products_v
where comp_item_id = p_product_rec.inventory_item_id
  and organization_id = p_product_rec.current_org_id
  ;
Begin
  debug('Write Product Info for item_id '||p_product_rec.inventory_item_id||'Org '||p_product_rec.current_org_id);

  Open get_products;
  Loop
     Fetch get_products
     Into p_product_rec.organization
       ,  p_product_rec.transaction_date
       ,  p_product_rec.assembly
       ,  p_product_rec.product_type
       ,  p_product_rec.lot
       ,  p_product_rec.quantity
       ,  p_product_rec.uom
       ,  p_product_rec.secondary_quantity
       ,  p_product_rec.secondary_uom
       ,  p_product_rec.subinventory
       ,  l_locator_id
       ,  p_product_rec.grade
       ,  p_product_rec.serial
       ;
     Exit when get_products %NOTFOUND;

     /*Bug#5436402 The selection from view mtl_mfg_products_v fetches secondary uom irrespeive of tracking id.
       if the item is not tracked in Primary and Secondary then we should not display sec qty and sec uom*/
     IF g_tracking_quantity_ind <> 'PS' THEN
       p_product_rec.secondary_quantity := NULL;
       p_product_rec.secondary_uom := NULL;
     END IF;

     p_product_rec.locator := INV_PROJECT.GET_LOCATOR(l_locator_id,
                                    p_product_rec.current_org_id) ;

     write_group_begin('Products');
     XML_write('organization',p_product_rec.organization);
     XML_write('assembly',p_product_rec.assembly);
     XML_write('transaction_date',p_product_rec.transaction_date);
     XML_write('product_type',p_product_rec.product_type);
     XML_write('product_lot',p_product_rec.lot);
     XML_write('product_serial',p_product_rec.serial);
     XML_write('quantity',p_product_rec.quantity);
     XML_write('uom',p_product_rec.uom);
     XML_write('secondary_quantity',p_product_rec.secondary_quantity);
     XML_write('secondary_uom',p_product_rec.secondary_uom);
     XML_write('subinventory',p_product_rec.subinventory);
     XML_write('locator',p_product_rec.locator);
     XML_write('grade',p_product_rec.grade);
     write_group_end('Products');
  End Loop;
  Close get_products;

End write_product_info;

Procedure write_component_info
   ( p_component_rec      IN OUT NOCOPY inv_genealogy_report_gen.component_rec_type
   ) IS

l_locator_id              NUMBER;

cursor get_components is
select organization_code
   ,   transaction_date
   ,   item_number
   ,   lot_number
   ,   primary_quantity
   ,   primary_uom_code
   ,   secondary_quantity
   ,   secondary_uom_code
   ,   subinventory_code
   ,   locator_id
   ,   grade_code
   ,   serial_number
   ,   wip_entity_name
from mtl_mfg_components_v
where product_item_id = p_component_rec.inventory_item_id
  AND DECODE(product_lot_number,NULL, '%%$#', product_lot_number)
           = DECODE( p_component_rec.product_lot_number, NULL, '%%$#', p_component_rec.product_lot_number)
  AND DECODE(product_serial_number, NULL, '%%##', product_serial_number)
           = DECODE(p_component_rec.product_serial_number, NULL, '%%##', p_component_rec.product_serial_number)
  ORDER BY transaction_date DESC
  ;
Begin
  debug('Write Component Info for item_id '||p_component_rec.inventory_item_id||'Org '||p_component_rec.current_org_id);
  Open get_components;
  Loop
     Fetch get_components
     Into p_component_rec.organization
       ,  p_component_rec.transaction_date
       ,  p_component_rec.item
       ,  p_component_rec.lot
       ,  p_component_rec.quantity
       ,  p_component_rec.uom
       ,  p_component_rec.secondary_quantity
       ,  p_component_rec.secondary_uom
       ,  p_component_rec.subinventory
       ,  l_locator_id
       ,  p_component_rec.grade
       ,  p_component_rec.serial
       ,  p_component_rec.wip_entity_name
       ;
     Exit when get_components %NOTFOUND;

     /*Bug#5436402 The selection from view mtl_mfg_components_v fetches secondary uom irrespeive of tracking ind.
       if the item is not tracked in Primary and Secondary then we should not display sec qty and sec uom*/
     IF g_tracking_quantity_ind <> 'PS' THEN
       p_component_rec.secondary_quantity := NULL;
       p_component_rec.secondary_uom := NULL;
     END IF;

     p_component_rec.locator := INV_PROJECT.GET_LOCATOR(l_locator_id,
                                    p_component_rec.current_org_id) ;

     write_group_begin('Components');
     XML_write('organization', p_component_rec.organization);
     XML_write('component_item', p_component_rec.item);
     XML_write('transaction_date', p_component_rec.transaction_date);
     XML_write('component_lot', p_component_rec.lot);
     XML_write('component_serial', p_component_rec.serial);
     XML_write('quantity', p_component_rec.quantity);
     XML_write('uom', p_component_rec.uom);
     XML_write('secondary_quantity', p_component_rec.secondary_quantity);
     XML_write('secondary_uom', p_component_rec.secondary_uom);
     XML_write('subinventory', p_component_rec.subinventory);
     XML_write('locator', p_component_rec.locator);
     XML_write('grade', p_component_rec.grade);
     XML_write('wip_document', p_component_rec.wip_entity_name);
     write_group_end('Components');
  End Loop;
  Close get_components;

End write_component_info;

Procedure write_quality_collections_info
   ( p_quality_collections_rec      IN OUT NOCOPY inv_genealogy_report_gen.quality_collections_rec_type
   ) IS

l_where                         VARCHAR2(2000);
l_query                         VARCHAR2(5000);

type rc is ref cursor;
l_rec_query rc;

/*cursor get_collections is
Select name
   ,   description
   ,   plan_type_description
from mtl_genealogy_qa_data
where (item_id = p_quality_collections_rec.inventory_item_id)
    or comp_item_id = p_quality_collections_rec.inventory_item_id))
   and lot_number = decode(p_quality_collections_rec.lot_number, null,'%%XX', p_quality_collections_rec.lot_number)
     or comp_lot_number = decode(p_quality_collections_rec.lot_number, null,'%%XX', p_quality_collections_rec.lot_number))
   and serial_number = decode(p_quality_collections_rec.serial_number, null,'%%XX', p_quality_collections_rec.serial_number)
     or comp_serial_number = decode(p_quality_collections_rec.serial_number, null,'%%XX', p_quality_collections_rec.serial_number))
   and decode(wip_entity_id, null,'%%XX', wip_entity_id)
           = decode(p_quality_collections_rec.wip_entity_id, null,'%%XX', p_quality_collections_rec.wip_entity_id)
   ;
*/
Begin
  debug('Write Quality Collections Info');
  debug('     item_id '||p_quality_collections_rec.inventory_item_id);
  debug('     lot_number '||p_quality_collections_rec.lot_number);
  debug('     serial_number '||p_quality_collections_rec.serial_number);
  debug('     wip_entity_id '||p_quality_collections_rec.wip_entity_id);

  l_query :=     ' Select name '
           || ',   description'
           || ',   plan_type_description'
           || '    from mtl_genealogy_qa_data   '
           ;
  l_where := ' where (item_id = '
           ||     p_quality_collections_rec.inventory_item_id
           ||'    or comp_item_id = '
           ||     p_quality_collections_rec.inventory_item_id
           ||' ) '
           ;
  if p_quality_collections_rec.lot_number is not null then
     l_where := l_where ||' and '
            ||' (lot_number = '
            ||''''|| p_quality_collections_rec.lot_number ||''''
            ||' or comp_lot_number = '
            ||''''|| p_quality_collections_rec.lot_number ||''''
            ||' ) '
            ;
  end if;
  if p_quality_collections_rec.serial_number is not null then
     l_where := l_where ||' and '
           ||' (serial_number = '
           ||''''|| p_quality_collections_rec.serial_number ||''''
           ||' or comp_serial_number = '
           ||''''||p_quality_collections_rec.serial_number||''''
           ||' ) ';
  end if;
  if p_quality_collections_rec.wip_entity_id is not null then
     l_where := l_where ||' and '
           ||' wip_entity_id = '
           || p_quality_collections_rec.wip_entity_id ;
  end if;

  l_query := l_query || l_where;
  debug('quality collections: '||l_query);

  Open l_rec_query for l_query;
  Loop
     Fetch l_rec_query
     Into p_quality_collections_rec.collection_plan
        , p_quality_collections_rec.plan_description
        , p_quality_collections_rec.plan_type
        ;
     Exit when l_rec_query %NOTFOUND;
     write_group_begin('quality_collections');
     XML_write('collection_plan', p_quality_collections_rec.collection_plan);
     XML_write('plan_type', p_quality_collections_rec.plan_type);
     XML_write('plan_description', p_quality_collections_rec.plan_description);
     write_group_end('quality_collections');
  End Loop;
  Close l_rec_query;

End write_quality_collections_info;

Procedure write_quality_samples_info
  ( p_quality_samples_rec      IN OUT NOCOPY inv_genealogy_report_gen.quality_samples_rec_type
  ) IS

l_locator_id                 NUMBER;
l_count                      NUMBER;

l_select                        VARCHAR2(1000);
l_from                          VARCHAR2(200);
--#  Sunitha Ch. 21jun06. Bug#5312854. Changed the size of l_where to 500 from 200
-- l_where                         VARCHAR2(200);
l_where                         VARCHAR2(500);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

Cursor get_samples is
select sample_no
   ,   sample_desc
   ,   date_drawn
   ,   source
   ,   lot_number
   ,   subinventory
   ,   sample_qty
   ,   sample_qty_uom
   ,   locator_id
from gmd_samples
where inventory_item_id = p_quality_samples_rec.inventory_item_id
  and   organization_id = p_quality_samples_rec.current_org_id
  and   decode(lot_number,'%%XX', lot_number) = decode(p_quality_samples_rec.lot, '%%XX', p_quality_samples_rec.lot)
  ;

Cursor get_samples_count is
select count(*)
from gmd_samples
where inventory_item_id = p_quality_samples_rec.inventory_item_id
  and   organization_id = p_quality_samples_rec.current_org_id
  and   decode(lot_number,'%%XX', lot_number) = decode(p_quality_samples_rec.lot, '%%XX', p_quality_samples_rec.lot)
  ;

Cursor get_org is
SELECT mp.organization_code
FROM mtl_parameters mp
WHERE mp.organization_id = p_quality_samples_rec.current_org_id
;

Cursor get_samples_parent is
select sample_no
   ,   sample_desc
   ,   date_drawn
   ,   source
   ,   lot_number
   ,   subinventory
   ,   sample_qty
   ,   sample_qty_uom
   ,   locator_id
from gmd_samples
where inventory_item_id = p_quality_samples_rec.inventory_item_id
  and   organization_id = p_quality_samples_rec.current_org_id
  and   decode(lot_number,'%%XX', lot_number) = decode(p_quality_samples_rec.parent_lot, '%%XX', p_quality_samples_rec.parent_lot)
  ;

Cursor get_samples_parent_count is
select count(*)
from gmd_samples
where inventory_item_id = p_quality_samples_rec.inventory_item_id
  and   organization_id = p_quality_samples_rec.current_org_id
  and   decode(lot_number,'%%XX', lot_number) = decode(p_quality_samples_rec.parent_lot, '%%XX', p_quality_samples_rec.parent_lot)
  ;

Cursor get_samples_sample_event is
select sample_no
   ,   sample_desc
   ,   date_drawn
   ,   source
   ,   lot_number
   ,   subinventory
   ,   sample_qty
   ,   sample_qty_uom
   ,   locator_id
from gmd_samples
where sampling_event_id = p_quality_samples_rec.sampling_event_id
  ;

Begin
  debug('Write Quality Samples Info');

  l_select := 'select sample_no'
            ||'  ,   sample_desc'
            ||'  ,   date_drawn'
            ||'  ,   source'
            ||'  ,   lot_number'
            ||'  ,   subinventory'
            ||'  ,   sample_qty'
            ||'  ,   sample_qty_uom'
            ||'  ,   locator_id'
            ;
  l_from := ' from gmd_samples';
  l_where := ' where inventory_item_id = '||p_quality_samples_rec.inventory_item_id
             ||'    and   organization_id = '||p_quality_samples_rec.current_org_id
             ||'    and   decode(lot_number,'||''''||'%%XX'||''''||', lot_number) = '
             ||'decode('||p_quality_samples_rec.lot||', '||''''||'%%XX'||''''||', '||p_quality_samples_rec.lot||')'
             ;
  Open get_samples_count;
  Fetch get_samples_count Into l_count;
  Close get_samples_count;

  if l_count = 0 then
     l_where := '';
     l_where := ' where inventory_item_id = '||p_quality_samples_rec.inventory_item_id
             ||'    and   organization_id = '||p_quality_samples_rec.current_org_id
             ||'    and   decode(lot_number,'||''''||'%%XX'||''''||', lot_number) = '
             ||'decode('||p_quality_samples_rec.parent_lot||', '||''''||'%%XX'||''''||', '||p_quality_samples_rec.parent_lot||')'
              ;

     Open get_samples_parent_count;
     Fetch get_samples_parent_count Into l_count;
     Close get_samples_parent_count;

     if l_count = 0 then
        l_where := '';
        l_where := ' where sampling_event_id = '||p_quality_samples_rec.sampling_event_id ;
        if p_quality_samples_rec.sampling_event_id is null then
           return;
        end if;
     end if;
  end if;

  l_query := l_select||l_from||l_where;
  Open l_rec_query for l_query;
  Loop
     Fetch l_rec_query
     Into p_quality_samples_rec.sample_number
      ,   p_quality_samples_rec.sample_description
      ,   p_quality_samples_rec.date_drawn
      ,   p_quality_samples_rec.sample_source
      ,   p_quality_samples_rec.lot
      ,   p_quality_samples_rec.subinventory
      ,   p_quality_samples_rec.sample_quantity
      ,   p_quality_samples_rec.uom
      ,   l_locator_id
      ;
     Exit when l_rec_query %NOTFOUND;

     p_quality_samples_rec.locator := INV_PROJECT.GET_LOCATOR(l_locator_id,
                                    p_quality_samples_rec.current_org_id) ;
     Open get_org;
     Fetch get_org into p_quality_samples_rec.organization;
     Close get_org;
     write_group_begin('quality_samples');
     XML_write('sample_number', p_quality_samples_rec.organization||'-'||p_quality_samples_rec.sample_number);
     XML_write('sample_description', p_quality_samples_rec.sample_description);
     XML_write('date_drawn', p_quality_samples_rec.date_drawn);
     XML_write('sample_source', p_quality_samples_rec.sample_source);
     XML_write('lot', p_quality_samples_rec.lot);
     XML_write('subinventory', p_quality_samples_rec.subinventory);
     XML_write('locator', p_quality_samples_rec.locator);
     XML_write('sample_quantity', p_quality_samples_rec.sample_quantity);
     XML_write('uom', p_quality_samples_rec.uom);
     write_group_end('quality_samples');
  End loop;
  Close l_rec_query;

End write_quality_samples_info;

Procedure write_lotbased_wip_txn_info
   ( p_lotbased_wip_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.lotbased_wip_txn_rec_type
   ) IS
l_user_name               VARCHAR2(240);
l_wip_entity_name         VARCHAR2(240);
l_item_no                 VARCHAR2(240);

cursor get_move_txn Is
select *
from wsm_wip_lot_txns_v
Where object_id = p_lotbased_wip_txn_rec.object_id;

cursor get_item_no (p_item_id IN NUMBER
                 ,  p_organization_id IN NUMBER
                 )
is
Select concatenated_segments
from mtl_system_items_kfv
Where inventory_item_id = p_item_id
   and organization_id = p_organization_id
 ;
Begin
  debug('Write Lot Based WIP Txns info');

  Open get_move_txn;
  Loop

     fetch get_move_txn into p_lotbased_wip_txn_rec;
     Exit when get_move_txn %NOTFOUND;

     Select user_name
     into l_user_name
     From fnd_user
     Where user_id = p_lotbased_wip_txn_rec.created_by
     ;

     write_group_begin('lotbased_wip_txn');

     XML_write('transaction_date', p_lotbased_wip_txn_rec.transaction_date);
     XML_write('transaction_type', p_lotbased_wip_txn_rec.transaction_type);
     XML_write('prev_wip_entity_name', p_lotbased_wip_txn_rec.prev_wip_entity_name);
     XML_write('prev_start_quantity', p_lotbased_wip_txn_rec.prev_start_quantity);
     XML_write('prev_alt_routing_designator', p_lotbased_wip_txn_rec.prev_alt_routing_designator);

     Open get_item_no(g_organization_id, p_lotbased_wip_txn_rec.prev_primary_item_id);
     Fetch get_item_no Into l_item_no;
     Close get_item_no;

     XML_write('prev_primary_item_no', l_item_no);

     XML_write('chg_wip_entity_name', p_lotbased_wip_txn_rec.chg_wip_entity_name);
     XML_write('chg_start_quantity', p_lotbased_wip_txn_rec.chg_start_quantity);
     XML_write('chg_alt_routing_designator', p_lotbased_wip_txn_rec.chg_alt_routing_designator);

     Open get_item_no(g_organization_id, p_lotbased_wip_txn_rec.chg_primary_item_id);
     Fetch get_item_no Into l_item_no;
     Close get_item_no;

     XML_write('chg_primary_item_no', l_item_no);
     XML_write('created_by', l_user_name);
     XML_write('transaction_id', p_lotbased_wip_txn_rec.transaction_id);

     write_group_end('lotbased_wip_txn');
  End loop;

End write_lotbased_wip_txn_info;

Procedure write_move_txn_info
   ( p_move_txn_rec      IN OUT NOCOPY inv_genealogy_report_gen.move_txn_rec_type
   ) IS
l_user_name               VARCHAR2(240);
l_wip_entity_name         VARCHAR2(240);
l_item_no                 VARCHAR2(240);

cursor get_move_txn Is
select transaction_date
  ,    wip_entity_name
  ,    fm_operation_seq_num
  ,    fm_operation_code
  ,    fm_department_code
  ,    fm_intraoperation_step_meaning
  ,    to_operation_seq_num
  ,    to_operation_code
  ,    to_department_code
  ,    to_intraoperation_step_meaning
  ,    transaction_uom
  ,    transaction_quantity
  ,    primary_uom
  ,    primary_quantity
  ,    overcompletion_transaction_qty
  ,    overcompletion_primary_qty
from wip_move_transactions_v
Where wip_entity_id = p_move_txn_rec.wip_entity_id
  and organization_id = p_move_txn_rec.organization_id;

cursor get_item_no (p_item_id IN NUMBER
                 ,  p_organization_id IN NUMBER
                 )
is
Select concatenated_segments
from mtl_system_items_kfv
Where inventory_item_id = p_item_id
   and organization_id = p_organization_id
 ;
Begin
  debug('Write Move Txns info');

  Open get_move_txn;
  Loop
     fetch get_move_txn
     into p_move_txn_rec.transaction_date
        , p_move_txn_rec.Job
        , p_move_txn_rec.From_Seq
        , p_move_txn_rec.From_Code
        , p_move_txn_rec.From_Department
        , p_move_txn_rec.From_Step
        , p_move_txn_rec.To_Seq
        , p_move_txn_rec.To_Code
        , p_move_txn_rec.To_Department
        , p_move_txn_rec.To_Step
        , p_move_txn_rec.Transaction_UOM
        , p_move_txn_rec.Transaction_Quantity
        , p_move_txn_rec.Primary_UOM
        , p_move_txn_rec.Primary_Quantity
        , p_move_txn_rec.Over_Cplt_Txn_Qty
        , p_move_txn_rec.Over_Cplt_Primary_Qty
     ;
     Exit when get_move_txn %NOTFOUND;

     write_group_begin('move_transactions');

     XML_write('transaction_date', p_move_txn_rec.transaction_date);
     XML_write('job', p_move_txn_rec.job);
     XML_write('assembly', p_move_txn_rec.assembly);
     XML_write('from_seq', p_move_txn_rec.from_seq);
     XML_write('from_code', p_move_txn_rec.from_code);
     XML_write('from_department', p_move_txn_rec.from_department);
     XML_write('from_step', p_move_txn_rec.from_step);
     XML_write('to_seq', p_move_txn_rec.to_seq);
     XML_write('to_code', p_move_txn_rec.to_code);
     XML_write('to_department', p_move_txn_rec.to_department);
     XML_write('to_step', p_move_txn_rec.to_step);
     XML_write('transaction_uom', p_move_txn_rec.transaction_uom);
     XML_write('transaction_quantity', p_move_txn_rec.transaction_quantity);
     XML_write('primary_uom', p_move_txn_rec.primary_uom);
     XML_write('primary_quantity', p_move_txn_rec.primary_quantity);
     XML_write('over_cplt_txn_qty', p_move_txn_rec.over_cplt_txn_qty);
     XML_write('over_cplt_primary_qty', p_move_txn_rec.over_cplt_primary_qty);

     write_group_end('move_transactions');

  End loop;

End write_move_txn_info;

Procedure write_grade_status_info
  ( p_grade_status_rec      IN OUT NOCOPY inv_genealogy_report_gen.grade_status_rec_type
  ) IS

l_user_id              NUMBER;
cursor get_grade_status is
select date_stamp
    ,  action
    ,  old_value
    ,  new_value
    ,  primary_quantity
    ,  secondary_quantity
    ,  change_reason
    ,  user_id
from mtl_grd_sts_history_v
where inventory_item_id = p_grade_status_rec.inventory_item_id
  and organization_id = p_grade_status_rec.current_org_id
  and lot_number      = p_grade_status_rec.lot_number
  ;
Begin
  debug('Write grade status info');

  Open get_grade_status;
  Loop
     Fetch get_grade_status
     Into   p_grade_status_rec.date_time
         ,  p_grade_status_rec.action
         ,  p_grade_status_rec.from_value
         ,  p_grade_status_rec.to_value
         ,  p_grade_status_rec.quantity
         ,  p_grade_status_rec.secondary_quantity
         ,  p_grade_status_rec.reason
         ,  l_user_id
         ;
     Exit when get_grade_status %NOTFOUND;
     Select user_name
     into p_grade_status_rec.user
     From fnd_user
     Where user_id = l_user_id;

     write_group_begin('grade_status_changes');
     XML_write('organization', p_grade_status_rec.organization);
     XML_write('date_time', p_grade_status_rec.date_time);
     XML_write('action', p_grade_status_rec.action);
     XML_write('from_value', p_grade_status_rec.from_value);
     XML_write('to_value', p_grade_status_rec.to_value);
     XML_write('quantity', p_grade_status_rec.quantity);
     XML_write('uom', p_grade_status_rec.uom);
     XML_write('secondary_quantity', p_grade_status_rec.secondary_quantity);
     XML_write('secondary_uom', p_grade_status_rec.secondary_uom);
     XML_write('source', p_grade_status_rec.source);
     XML_write('reason', p_grade_status_rec.reason);
     XML_write('user', p_grade_status_rec.user);
     write_group_end('grade_status_changes');
  End Loop;
  Close get_grade_status;

End write_grade_status_info;

procedure get_all_children
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   ) IS

l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_object_type          NUMBER;
l_current_object_id    NUMBER;
l_level                NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

Cursor get_child is
SELECT object_id
  ,    inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)
FROM mtl_object_genealogy
WHERE parent_object_id = l_object_id
;

Begin
  debug('Get All Children');
  l_node_name    := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
  l_object_id    := p_object_id;
  l_object_type  := p_object_type;

  debug('Main level Node '||l_node_name);

  /*write_group_begin('tree_node_main_level');
  XML_write('main_level', l_node_name);

  write_tree_node (p_object_id, p_object_type, p_object_id2, p_object_type2, 1, 1);

  write_group_end('tree_node_main_level');

  -- for the query item
  write_genealogy_report
               ( p_object_id           => l_object_id
               , p_object_type         => l_object_type
               , p_object_id2          => l_object_id2
               , p_object_type2        => l_object_type2
               , p_level               => 2
               );
  */
  -- for the children
  write_children_reports
         ( p_object_id           => l_object_id
         , p_object_type         => l_object_type
         , p_object_id2          => p_object_id2
         , p_object_type2        => p_object_type2
         , p_level               => 0
         );

End get_all_children;

procedure get_one_level_child
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) IS

l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_object_id2           NUMBER;
l_object_type          NUMBER;
l_object_type2         NUMBER;
l_current_object_id    NUMBER;
l_level                NUMBER;
l_fake_object_id2      NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);
l_child_rg_name                 VARCHAR2(2000);
l_security                      Number;
x_return_status                 VARCHAR2(5);

type rc is ref cursor;
l_child_query rc;

Cursor get_child is
SELECT object_id
  ,    object_type
  ,    object_id2
  ,    object_type2
  ,    inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)
FROM mtl_object_genealogy
WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)
     CONNECT BY PRIOR object_id = parent_object_id
     START WITH (parent_object_id2 IS NULL OR parent_object_id2 = l_object_id2)
              AND parent_object_id = l_object_id
;


Begin
  debug('Get one level child, level '||p_level);
  l_current_object_id := p_object_id;
  l_object_id := p_object_id;
  l_object_type := p_object_type;
  l_object_id2 := p_object_id2;
  l_object_type2 := p_object_type2;
  l_level := p_level;

  l_fake_object_id2 := l_object_id2;
  if l_fake_object_id2 is null then
     l_fake_object_id2 := -9999;
  end if;

  if l_object_type <> 5 then
     l_query       := ' SELECT object_id '
                    ||'   ,    object_type'
                    ||'   ,    object_id2'
                    ||'   ,    object_type2'
                    ||'   ,    inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)'
                    ||'   FROM mtl_object_genealogy'
                    ||'   WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)'
                    ||'         and decode(parent_object_id2,null, -9999, parent_object_id2) = '||l_fake_object_id2
                    ||'         AND parent_object_id = '||l_object_id
                    --||'      CONNECT BY PRIOR object_id = parent_object_id'
                    --||'      START WITH decode(parent_object_id2,null, -9999, parent_object_id2) = '||l_fake_object_id2
                    --||'               AND parent_object_id = '||l_object_id
                    ;
     /* It was decided that the direct job link should also be included */
     /*l_child_rg_name  := inv_object_genealogy.findchildrecordgroup(l_object_id);
     if l_child_rg_name = 'CHILD_INFO_DGEN' THEN
        l_query := l_query || ' and object_type <> 5';
     end if;
     */
  else
     l_query        :=  'SELECT object_id '
                   ||'     , object_type '
                   ||'     , object_id2 '
                   ||'     , object_type2 '
                   ||'     , inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)'
                   ||'  FROM mtl_object_genealogy '
                   ||' WHERE parent_object_id = '||l_object_id
                   ||'   AND(end_date_active IS NULL '
                   ||'       OR TRUNC(end_date_active) >= TRUNC(SYSDATE)) '
                   ;
  end if;

  /*Bug#9048298 call the function where the secutiry logic is coded */
  /* check gme formula security, no expansion what so ever, if security is on*/
  l_security := get_formula_security(g_organization_id, p_object_id,l_object_type);     -- security is off for all

  --debug(' child query '||l_query);
  if l_security = 1 Then
  Open l_child_query for l_query;
     Loop

        Fetch l_child_query
        Into l_object_id
           , l_object_type
           , l_object_id2
           , l_object_type2
           , l_node_name
           ;
        --if l_level <> p_level then
        --   write_group_end('tree_node_level'||(l_level-1));
        --end if;
        Exit When l_child_query %NOTFOUND;

        debug(' drill down the tree, level '||l_level||' '||l_node_name||' Object_type '||l_object_type||' object_id '||l_object_id);

        l_node_name    := inv_object_genealogy.getobjectnumber
                       (l_object_id, l_object_type, l_object_id2, l_object_type2);

        write_group_begin('tree_node_level'||l_level);
        XML_write('level'||l_level, l_node_name);
        Get_one_level_child(l_object_id, l_object_type, l_object_id2, l_object_type2, l_level + 1);
        write_group_end('tree_node_level'||l_level);

     End loop;
     close l_child_query;
  end if;

End get_one_level_child;

procedure write_children_reports
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) IS

l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_object_id2           NUMBER;
l_object_type          NUMBER;
l_object_type2         NUMBER;
l_current_object_id    NUMBER;
l_level                NUMBER;
l_fake_object_id2      NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);
l_child_rg_name                 VARCHAR2(2000);
l_security                      Number;
x_return_status                 VARCHAR2(5);

type rc is ref cursor;
l_child_query rc;

Cursor get_child is
SELECT object_id
  ,    object_type
  ,    object_id2
  ,    object_type2
  ,    inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)
FROM mtl_object_genealogy
WHERE parent_object_id = l_object_id
;
Begin
  debug(' Write children reports');
  l_node_name    := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
  l_current_object_id := p_object_id;
  l_object_id := p_object_id;
  l_object_type := p_object_type;
  l_object_id2 := p_object_id2;
  l_object_type2 := p_object_type2;
  --l_level := p_level + 1;
  l_level := p_level ;

  -- write the tree from this object's all children
  write_tree_node(l_object_id, l_object_type, l_object_id2, l_object_type2, l_level, 1);

  l_fake_object_id2 := l_object_id2;
  if l_fake_object_id2 is null then
     l_fake_object_id2 := -9999;
  end if;

  if l_object_type <> 5 then
     l_query       := ' SELECT object_id '
                    ||'   ,    object_type'
                    ||'   ,    object_id2'
                    ||'   ,    object_type2'
                    ||'   ,    inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)'
                    ||'   FROM mtl_object_genealogy'
                    ||'   WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)'
                    ||'        and decode(parent_object_id2,null, -9999, parent_object_id2) = '||l_fake_object_id2
                    ||'        AND parent_object_id = '||l_object_id
                    --||'      CONNECT BY PRIOR object_id = parent_object_id'
                    --||'      START WITH decode(parent_object_id2,null, -9999, parent_object_id2) = '||l_fake_object_id2
                    --||'               AND parent_object_id = '||l_object_id
                    ;
     /*l_child_rg_name  := inv_object_genealogy.findchildrecordgroup(l_object_id);
     if l_child_rg_name = 'CHILD_INFO_DGEN' THEN
        l_query := l_query || ' and object_type <> 5';
     end if;
     */
  else
     l_query        :=  'SELECT object_id '
                   ||'     , object_type '
                   ||'     , object_id2 '
                   ||'     , object_type2 '
                   ||'     , inv_object_genealogy.getobjectnumber(object_id, object_type, object_id2, object_type2)'
                   ||'  FROM mtl_object_genealogy '
                   ||' WHERE parent_object_id = '||l_object_id
                   ||'   AND(end_date_active IS NULL '
                   ||'       OR TRUNC(end_date_active) >= TRUNC(SYSDATE)) '
                   ;
  end if;

  /*Bug#9048298 call the function where the secutiry logic is coded */
  /* check gme formula security, no expansion what so ever, if security is on*/
  l_security := get_formula_security(g_organization_id, p_object_id,l_object_type);     -- security is off for all

  --debug(' child query '||l_query);
  if l_security = 1 Then           -- security is allowed
     Open l_child_query for l_query;
     Loop

        Fetch l_child_query
        Into l_object_id
           , l_object_type
           , l_object_id2
           , l_object_type2
           , l_node_name
           ;
        Exit When l_child_query %NOTFOUND;

        debug(' Write children reports: drill down the tree, level '||l_level||' '||l_node_name);
        write_genealogy_report
                  ( p_object_id           => l_object_id
                  , p_object_type         => l_object_type
                  , p_object_id2          => l_object_id2
                  , p_object_type2        => l_object_type2
                  , p_level               => l_level
                  );
        write_children_reports(l_object_id, l_object_type, l_object_id2, l_object_type2, l_level);
     End loop;
     close l_child_query;
  end if;  -- security

End write_children_reports;

procedure get_all_parents
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   ) IS

l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_object_type          NUMBER;
l_current_object_id    NUMBER;
l_level                NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);

type rc is ref cursor;
l_rec_query rc;

Begin
  debug('Get All Parents');
  l_node_name    := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
  l_object_id    := p_object_id;
  l_object_type  := p_object_type;

  debug('Main level Node '||l_node_name);

  -- for the parents
  write_parent_reports
         ( p_object_id           => l_object_id
         , p_object_type         => l_object_type
         , p_object_id2          => p_object_id2
         , p_object_type2        => p_object_type2
         , p_level               => 0
         );
End get_all_parents;

procedure get_one_level_parent
   ( p_parent_object_id           IN NUMBER
   , p_parent_object_type         IN NUMBER
   , p_parent_object_id2          IN NUMBER
   , p_parent_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) IS

l_node_name            VARCHAR2(100);
l_parent_object_id            NUMBER;
l_parent_object_id2           NUMBER;
l_parent_object_type          NUMBER;
l_parent_object_type2         NUMBER;
l_current_parent_object_id    NUMBER;
l_level                NUMBER;
l_fake_object_id2           NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);
l_parent_rg_name                VARCHAR2(2000);
l_security                      Number;
x_return_status                 VARCHAR2(5);

type rc is ref cursor;
l_parent_query rc;

Cursor get_parent is
SELECT parent_object_id
  ,    parent_object_type
  ,    parent_object_id2
  ,    parent_object_type2
  ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)
FROM mtl_object_genealogy
WHERE object_id = l_parent_object_id
;

Begin
  debug('Get one level parent, level '||p_level);
  l_node_name    := inv_object_genealogy.getobjectnumber
                    (p_parent_object_id, p_parent_object_type, p_parent_object_id2, p_parent_object_type2);
  l_current_parent_object_id := p_parent_object_id;
  l_parent_object_id := p_parent_object_id;
  l_parent_object_type := p_parent_object_type;
  l_parent_object_id2 := p_parent_object_id2;
  l_parent_object_type2 := p_parent_object_type2;
  l_level := p_level;
  l_fake_object_id2 := l_parent_object_id2;
  if l_fake_object_id2 is null then
     l_fake_object_id2 := -9999;
  end if;

  write_group_begin('tree_node_level'||l_level);

  if l_parent_object_type <> 5 then
     l_query       := ' SELECT parent_object_id '
                    ||'   ,    parent_object_type'
                    ||'   ,    parent_object_id2'
                    ||'   ,    parent_object_type2'
                    ||'   ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)'
                    ||'   FROM mtl_object_genealogy'
                    ||'   WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)'
                    ||'         and decode(object_id2,null, -9999, object_id2) = '||l_fake_object_id2
                    ||'         AND object_id = '||l_parent_object_id
                    --||'      CONNECT BY object_id = PRIOR parent_object_id '
                    --||'      START WITH decode(object_id2,null, -9999, object_id2) = '||l_fake_object_id2
                    --||'               AND object_id = '||l_parent_object_id
                    ;
     /*l_parent_rg_name  := inv_object_genealogy.findchildrecordgroup(l_parent_object_id);
     if l_parent_rg_name = 'CHILD_INFO_DGEN' THEN
        l_query := l_query || ' and parent_object_type <> 5';
     end if;
     */
  else
     l_query        := ' SELECT parent_object_id '
                     ||'      , parent_object_type '
                     ||'      , parent_object_id2 '
                     ||'      , parent_object_type2 '
                     ||'   ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)'
                     ||'  FROM mtl_object_genealogy '
                     ||'   WHERE object_id = '||l_parent_object_id
                     ||'   AND(end_date_active IS NULL '
                     ||'      OR TRUNC(end_date_active) >= TRUNC(SYSDATE)) '
                      ;
  end if;
  /*Bug#9048298 call the function where the secutiry logic is coded */
  /* check gme formula security, no expansion what so ever, if security is on*/
  l_security := get_formula_security(g_organization_id, p_parent_object_id,l_parent_object_type);     -- security is off for all

  --debug(' parent query '||l_query);
  if l_security = 1 Then
     Open l_parent_query for l_query ;
     Loop

        Fetch l_parent_query
        Into l_parent_object_id
           , l_parent_object_type
           , l_parent_object_id2
           , l_parent_object_type2
           , l_node_name
           ;
        Exit When l_parent_query %NOTFOUND;

        debug(' drill down the tree, level '||l_level||' '||l_node_name);

        XML_write('level'||l_level, l_node_name);
        Get_one_level_parent(l_parent_object_id, l_parent_object_type, l_parent_object_id2, l_parent_object_type2, l_level + 1);
     End loop;
     close l_parent_query;
  end if;

  write_group_end('tree_node_level'||l_level);

End get_one_level_parent;

procedure write_parent_reports
   ( p_object_id           IN NUMBER
   , p_object_type         IN NUMBER
   , p_object_id2          IN NUMBER
   , p_object_type2        IN NUMBER
   , p_level               IN NUMBER  -- 0, main level
   ) IS

l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_object_id2           NUMBER;
l_object_type          NUMBER;
l_object_type2         NUMBER;
l_current_object_id    NUMBER;
l_level                NUMBER;
l_fake_object_id2      NUMBER;

l_statement                     VARCHAR2(2000);
l_query                         VARCHAR2(2000);
l_parent_rg_name                 VARCHAR2(2000);
l_security                      Number;
x_return_status                 VARCHAR2(5);

type rc is ref cursor;
l_parent_query rc;

Begin
  debug(' Write Parents Reports');
  l_node_name    := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
  l_current_object_id := p_object_id;
  l_object_id := p_object_id;
  l_object_type := p_object_type;
  l_object_id2 := p_object_id2;
  l_object_type2 := p_object_type2;
  --l_level := p_level + 1;
  l_level := p_level ;

  -- write the tree from this object's all parents
  write_tree_node(l_object_id, l_object_type, l_object_id2, l_object_type2, l_level, 2);

  l_fake_object_id2 := l_object_id2;
  if l_fake_object_id2 is null then
     l_fake_object_id2 := -9999;
  end if;

  if l_object_type <> 5 then
     l_query       := ' SELECT parent_object_id '
                    ||'   ,    parent_object_type'
                    ||'   ,    parent_object_id2'
                    ||'   ,    parent_object_type2'
                    ||'   ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)'
                    ||'   FROM mtl_object_genealogy'
                    ||'   WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)'
                    ||'        and decode(object_id2,null, -9999, object_id2) = '||l_fake_object_id2
                    ||'        AND object_id = '||l_object_id
                    --||'      CONNECT BY object_id = PRIOR parent_object_id '
                    --||'      START WITH decode(object_id2,null, -9999, object_id2) = '||l_fake_object_id2
                    --||'               AND object_id = '||l_object_id
                    ;
     /*l_parent_rg_name  := inv_object_genealogy.findchildrecordgroup(l_object_id);
     if l_parent_rg_name = 'CHILD_INFO_DGEN'  THEN
        l_query := l_query || ' and parent_object_type <> 5';
     end if;
     */
  else
     l_query        := ' SELECT parent_object_id '
                     ||'      , parent_object_type '
                     ||'      , parent_object_id2 '
                     ||'      , parent_object_type2 '
                     ||'   ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)'
                     ||'  FROM mtl_object_genealogy '
                     ||'   WHERE object_id = '||l_object_id
                     ||'   AND(end_date_active IS NULL '
                     ||'      OR TRUNC(end_date_active) >= TRUNC(SYSDATE)) '
                      ;
  end if;
  /*
  l_query       := ' SELECT parent_object_id '
                 ||'   ,    parent_object_type'
                 ||'   ,    parent_object_id2'
                 ||'   ,    parent_object_type2'
                 ||'   ,    inv_object_genealogy.getobjectnumber(parent_object_id, parent_object_type, parent_object_id2, parent_object_type2)'
                 ||'   FROM mtl_object_genealogy'
                 ||'   WHERE (end_date_active IS NULL OR end_date_active >= SYSDATE)'
                 ||'      CONNECT BY object_id = PRIOR parent_object_id '
                 ||'      START WITH decode(object_id2,null, -9999, object_id2) = '||l_fake_object_id2
                 ||'               AND object_id = '||l_parent_object_id
                 ;
  l_parent_rg_name  := inv_object_genealogy.findchildrecordgroup(l_parent_object_id);
  if l_parent_rg_name = 'CHILD_INFO_DGEN' THEN
     l_query := l_query || ' and parent_object_type <> 5';
  end if;
  */
  /*Bug#9048298 call the function where the secutiry logic is coded */
  /* check gme formula security, no expansion what so ever, if security is on*/
  l_security := get_formula_security(g_organization_id, p_object_id,l_object_type);     -- security is off for all

  --debug(' parent query '||l_query);

  if l_security = 1 then
  Open l_parent_query for l_query;
     Loop

        Fetch l_parent_query
        Into l_object_id
           , l_object_type
           , l_object_id2
           , l_object_type2
           , l_node_name
           ;
        Exit When l_parent_query %NOTFOUND;

        debug(' Write parents reports: drill down the tree, level '||l_level||' '||l_node_name);
        write_genealogy_report
                  ( p_object_id           => l_object_id
                  , p_object_type         => l_object_type
                  , p_object_id2          => l_object_id2
                  , p_object_type2        => l_object_type2
                  , p_level               => l_level
                  );
        write_parent_reports(l_object_id, l_object_type, l_object_id2, l_object_type2, l_level);
     End loop;
     close l_parent_query;
  end if;

End write_parent_reports;

Procedure XML_write
  ( column_name                 IN VARCHAR2
  , column_value                IN VARCHAR2
  ) IS

  l_string          VARCHAR2(240);
Begin
     l_string := '<'||column_name||'>';
     l_string := l_string||column_value;
     l_string := l_string||'</'||column_name||'>';
     fnd_file.put_line(FND_FILE.OUTPUT,l_string);
     --dbms_output.put_line(l_string);
End XML_write;

Procedure Write_tree_node
  (p_object_id                  IN NUMBER
  ,p_object_type                IN NUMBER
  ,p_object_id2                 IN NUMBER
  ,p_object_type2               IN NUMBER
  ,p_level                      IN NUMBER            -- 0 main, >0 component
  ,p_child_parent               IN NUMBER            -- 1 child, 2 parent
  )
Is

l_level                VARCHAR2(50);
--#  Sunitha Ch. 21jun06. Bug#5312854. Changed the size of l_node_name to 100 from 50
--l_node_name            VARCHAR2(50);
l_node_name            VARCHAR2(100);
l_object_id            NUMBER;
l_count                NUMBER;

Begin
  debug('Write the tree node, level '||p_level);
  if p_level = 0 then
     write_group_begin('tree_node_main_level');
     l_node_name := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
     XML_write('main_level', l_node_name);
  else
     l_count := 0 ;
     /*loop
        l_count := l_count + 1 ;
        exit when l_count = p_level;
        write_group_begin('tree_node_level'||l_count);
     end loop;
     */
     l_node_name := inv_object_genealogy.getobjectnumber
                    (p_object_id, p_object_type, p_object_id2, p_object_type2);
     write_group_begin('tree_node_level'||p_level);
     XML_write('level'||p_level, l_node_name);
  end if;

  if p_child_parent = 1 then
     get_one_level_child (p_object_id, p_object_type, p_object_id2, p_object_type2, p_level+1);
  else
     get_one_level_parent (p_object_id, p_object_type, p_object_id2, p_object_type2, p_level+1);
  end if;

  if p_level = 0 then
     write_group_end('tree_node_main_level');
     null;
  else
     write_group_end('tree_node_level'||p_level);

     l_count := p_level ;
     /*
     loop
        l_count := l_count - 1 ;
        exit when l_count = 0;
        write_group_end('tree_node_level'||l_count);
     end loop;
     */
  end if;

End write_tree_node;

Procedure write_group_begin
  (column_name                  IN VARCHAR2
  ) IS
  l_string          VARCHAR2(240);
Begin
     l_string :='';
     l_string := l_string||'<'||column_name||'>';
     fnd_file.put_line(FND_FILE.OUTPUT,l_string);
     --dbms_output.put_line(l_string);
End write_group_begin;

Procedure write_group_end
  (column_name                  IN VARCHAR2
  ) IS
  l_string          VARCHAR2(240);
Begin
     l_string := '</'||column_name||'>';
     fnd_file.put_line(FND_FILE.OUTPUT,l_string);
     --dbms_output.put_line(l_string);
End write_group_end;

Function get_formula_security
  ( p_org_id                    IN NUMBER
   ,p_object_id             IN NUMBER
   ,p_object_type               IN NUMBER) return NUMBER
 IS
    l_security NUMBER := 1;
    l_process_org NUMBER;
    l_allow_security                VARCHAR2(1);
    x_return_status                 VARCHAR2(5);

    Cursor get_gme_security Is
      Select 1
      From wip_entities wip
         , gme_batch_header_vw gme
      Where wip.gen_object_id = p_object_id
      and wip.entity_type in (9, 10)
      and wip.wip_entity_id = gme.batch_id;
    Cursor is_org_process_enabled IS
      Select 1
      From mtl_parameters
      Where organization_id = g_organization_id
      and process_enabled_flag= 'Y';
BEGIN
    if( p_object_type = 5) then
      /*Bug#9048298 */
      Open is_org_process_enabled;
      Fetch is_org_process_enabled into l_process_org;
      Close is_org_process_enabled;
      if l_process_org = 1 then
        GMD_API_GRP.fetch_parm_values(g_organization_id,'GMI_LOTGENE_ENABLE_FMSEC',l_allow_security,x_return_status);
        if (l_allow_security = '1' or l_allow_security = 'Y') then
          l_security := 0;
          Open get_gme_security;
          Fetch get_gme_security into l_security;
          Close get_gme_security;
        end if;
        debug(' GME security: '|| l_security);
      end if;
    end if;
   RETURN l_security;
 END;

END;

/
