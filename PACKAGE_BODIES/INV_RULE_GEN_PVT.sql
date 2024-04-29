--------------------------------------------------------
--  DDL for Package Body INV_RULE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RULE_GEN_PVT" AS
  /* $Header: INVRLGNB.pls 120.4.12010000.3 2008/11/26 13:34:58 sneelise ship $ */
  --
  -- File        : INVRLGNB.pls
  -- Content     : INV_RULE_GEN_PVT
  -- Description : wms rules engine private API's
  -- Notes       :
  -- Modified    : 08/30/04 ckuenzel created orginal file in inventory
  --

/*  Global variables  */
G_PKG_NAME      CONSTANT  VARCHAR2(30):='INV_RULE_GEN_PVT';
  /* Save procedure will save the record to the following
     Mtl_picking_rules
     Wms_rules_b
     Wms_rules_tl
     Wms_restrictions - if any
     Wms_rule_consistencies - if any
     Wms_sort_criteria - if any
  */
--Procedures for logging messages
PROCEDURE debug(p_message VARCHAR2) IS
    l_module VARCHAR2(255);
BEGIN
    --l_module  := 'inv.plsql.' || g_pkg_name || '.' || p_api_name || '.' || p_label;
    inv_log_util.trace(p_message, g_pkg_name, 9);
    gmi_reservation_util.println(l_module ||' '|| p_message);
END debug;


  PROCEDURE Save
  (p_mtl_picking_rule_rec IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  ) IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'SAVE';
  l_parameter_id          NUMBER;
  l_is_new_rec            NUMBER;
  cursor check_exist(p_inv_rule_id IN NUMBER) is
  Select 1
  From mtl_inv_picking_rules
  Where inv_rule_id = p_inv_rule_id;

  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     debug('Procedure Save');
     l_is_new_rec := 1;
     if p_mtl_picking_rule_rec.inv_rule_id is not null then
        l_is_new_rec := 0;
     end if;
     debug('new record ? 1-y,0-n: '||l_is_new_rec);

     save_to_wms_rule
           (
             p_mtl_picking_rule_rec   => p_mtl_picking_rule_rec
           , x_return_status          => x_return_status
           , x_msg_data               => x_msg_data
           , x_msg_count              => x_msg_count
           );

     save_to_mtl_picking_rules
           (
             p_mtl_picking_rule_rec   => p_mtl_picking_rule_rec
           , x_return_status          => x_return_status
           , x_msg_data               => x_msg_data
           , x_msg_count              => x_msg_count
           );


    If l_is_new_rec = 1 then
        inv_rule_gen_pvt.Restrictions_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.consistency_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.sorting_criteria_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
     Else
        inv_rule_gen_pvt.restrictions_update
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.consistency_update
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );

         inv_rule_gen_pvt.sorting_criteria_update
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
       END IF;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      debug('save. error exception');
      WHEN OTHERS THEN
        debug('save others'||SQLCODE||'.');
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END save;

  PROCEDURE Save_to_mtl_picking_rules
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'Save_to_mtl_picking_rules';
  l_inv_rule_id           NUMBER;
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_inv_rule_id := p_mtl_picking_rule_rec.inv_rule_id;
     debug('Procedure Save_to_mtl_picking_rules');
     If l_inv_rule_id is null then
        select mtl_inv_picking_rules_s.nextval into l_inv_Rule_id from dual;
        debug('insert rule: rule_id '||l_inv_rule_id);
        debug('insert rule: fnd_global.user_id '||fnd_global.user_id);
        Insert into mtl_inv_picking_rules
           (
               INV_RULE_ID
             , SHELF_DAYS
             , SINGLE_LOT
             , PARTIAL_ALLOWED_FLAG
             , CUST_SPEC_MATCH_FLAG
             , LOT_SORT
             , LOT_SORT_RANK
             , REVISION_SORT
             , REVISION_SORT_RANK
             , SUBINVENTORY_SORT
             , SUBINVENTORY_SORT_RANK
             , LOCATOR_SORT
             , LOCATOR_SORT_RANK
             , WMS_RULE_ID
             , WMS_STRATEGY_ID
             , APPLY_TO_SOURCE
             , CREATION_DATE
             , CREATED_BY
             , LAST_UPDATE_DATE
             , LAST_UPDATED_BY
             , LAST_UPDATE_LOGIN
             , PROGRAM_APPLICATION_ID
             , PROGRAM_ID
             , REQUEST_ID
           )
           values
           (
               l_inv_rule_id
             , p_mtl_picking_rule_rec.shelf_days
             , p_mtl_picking_rule_rec.single_lot
             , p_mtl_picking_rule_rec.partial_allowed_flag
             , p_mtl_picking_rule_rec.cust_spec_match_flag
             , p_mtl_picking_rule_rec.lot_sort
             , p_mtl_picking_rule_rec.lot_sort_rank
             , p_mtl_picking_rule_rec.revision_sort
             , p_mtl_picking_rule_rec.revision_sort_rank
             , p_mtl_picking_rule_rec.subinventory_sort
             , p_mtl_picking_rule_rec.subinventory_sort_rank
             , p_mtl_picking_rule_rec.locator_sort
             , p_mtl_picking_rule_rec.locator_sort_rank
             , p_mtl_picking_rule_rec.wms_rule_id
             , p_mtl_picking_rule_rec.wms_strategy_id
             , p_mtl_picking_rule_rec.apply_to_source
             , sysdate
             , fnd_global.user_id
             , sysdate
             , fnd_global.user_id
             , fnd_global.login_id
             , null
             , null
             , null
           );
           p_mtl_picking_rule_rec.inv_rule_id := l_inv_rule_id;
           debug('insert, inv_rule_id '||l_inv_rule_id);
     else -- update
        update mtl_inv_picking_rules
        set
            SHELF_DAYS                 = p_mtl_picking_rule_rec.shelf_days
          , SINGLE_LOT                 = p_mtl_picking_rule_rec.single_lot
          , PARTIAL_ALLOWED_FLAG       = p_mtl_picking_rule_rec.partial_allowed_flag
          , CUST_SPEC_MATCH_FLAG       = p_mtl_picking_rule_rec.cust_spec_match_flag
          , LOT_SORT                   = p_mtl_picking_rule_rec.lot_sort
          , LOT_SORT_RANK              = p_mtl_picking_rule_rec.lot_sort_rank
          , REVISION_SORT              = p_mtl_picking_rule_rec.revision_sort
          , REVISION_SORT_RANK         = p_mtl_picking_rule_rec.revision_sort_rank
          , SUBINVENTORY_SORT          = p_mtl_picking_rule_rec.subinventory_sort
          , SUBINVENTORY_SORT_RANK     = p_mtl_picking_rule_rec.subinventory_sort_rank
          , LOCATOR_SORT               = p_mtl_picking_rule_rec.locator_sort
          , LOCATOR_SORT_RANK          = p_mtl_picking_rule_rec.locator_sort_rank
          , WMS_RULE_ID                = p_mtl_picking_rule_rec.wms_rule_id
          , WMS_STRATEGY_ID            = NULL /* p_mtl_picking_rule_rec.wms_strategy_id */
          , APPLY_TO_SOURCE            = p_mtl_picking_rule_rec.apply_to_source
          , LAST_UPDATE_DATE           = sysdate
          , LAST_UPDATED_BY            = fnd_global.user_id
          , LAST_UPDATE_LOGIN          = fnd_global.login_id
        where inv_rule_id = l_inv_rule_id;
     end if;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END save_to_mtl_picking_rules;

  PROCEDURE Save_to_wms_rule
  (p_mtl_picking_rule_rec IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status       OUT NOCOPY VARCHAR2
  , x_msg_data            OUT NOCOPY VARCHAR2
  , x_msg_count           OUT NOCOPY NUMBER
  ) IS
  l_api_name              CONSTANT VARCHAR2 (30) := 'Save_to_wms_rule';
  l_picking_rule_rec      INV_RULE_GEN_PVT.picking_rule_rec;
  l_wms_rule_id           NUMBER;
  l_row_id                VARCHAR2(500);
  l_organization_id       NUMBER;
  l_allocation_mode_id    NUMBER;

  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_picking_rule_rec   := p_mtl_picking_rule_rec;
     l_organization_id    := -1;              -- all orgs
     l_allocation_mode_id := 3;               -- NON LPN
     l_wms_rule_id        := p_mtl_picking_rule_rec.wms_rule_id;
     debug('Save_to_wms_rule ');
     debug('wms_rule_id '||l_wms_rule_id);
     If l_wms_rule_id is null then
        select wms_rules_s.nextval into l_wms_rule_Id from dual;
        debug('insert wms rule ');
        wms_RULES_PKG.Insert_Row
        (
            X_Rowid                => l_Row_Id,
            X_Rule_Id              => l_wms_rule_Id,
            X_Organization_Id      => l_Organization_Id,
            X_Type_Code            => 2,
            X_Name                 => l_picking_rule_rec.Name,
            X_Description          => l_picking_rule_rec.Description,
            X_Qty_Function_Parameter_Id => 10009,
            X_Enabled_Flag         => l_picking_rule_rec.Enabled_Flag,
            X_min_pick_tasks_flag  => 'N',
            X_User_Defined_Flag    => 'Y',
            X_Creation_Date        => sysdate,
            X_Created_By           => fnd_global.user_id,
            X_Last_Update_Date     => sysdate,
            X_Last_Updated_By      => fnd_global.user_id,
            X_Last_Update_Login    => fnd_global.login_id,
            X_Type_header_id       => null,
            X_Rule_Weight          => null,
            X_Attribute1           => null,
            X_Attribute2           => null,
            X_Attribute3           => null,
            X_Attribute4           => null,
            X_Attribute5           => null,
            X_Attribute6           => null,
            X_Attribute7           => null,
            X_Attribute8           => null,
            X_Attribute9           => null,
            X_Attribute10          => null,
            X_Attribute11          => null,
            X_Attribute12          => null,
            X_Attribute13          => null,
            X_Attribute14          => null,
            X_Attribute15          => null,
            X_Attribute_Category   => null,
            X_Allocation_mode_id   => l_Allocation_mode_id,
            X_wms_enabled_flag     => 'N'
        );

        /* update the rec */
        l_picking_rule_rec.wms_rule_id := l_wms_rule_id;
        debug('insert wms_rule_id '||l_wms_rule_id);
     else -- update
        debug('update wms rule ');
        debug('update wms rule, enabled_flag '||l_picking_rule_rec.enabled_flag);
        wms_RULES_PKG.Update_Row
        (
            X_Rule_Id              => l_picking_rule_rec.wms_Rule_Id,
            X_Organization_Id      => l_Organization_Id,
            X_Type_Code            => 2,
            X_Name                 => l_picking_rule_rec.Name,
            X_Description          => l_picking_rule_rec.Description,
            X_Qty_Function_Parameter_Id => 10009,
            X_Enabled_Flag         => l_picking_rule_rec.Enabled_Flag,
            X_User_Defined_Flag    => 'Y',
            X_min_pick_tasks_flag  => 'N',
            X_Last_Updated_By      => fnd_global.user_id,
            X_Last_Update_Date     => sysdate,
            X_Last_Update_Login    => fnd_global.user_id,
            X_Type_header_id       => null,
            X_Rule_Weight          => null,
            X_Attribute1           => null,
            X_Attribute2           => null,
            X_Attribute3           => null,
            X_Attribute4           => null,
            X_Attribute5           => null,
            X_Attribute6           => null,
            X_Attribute7           => null,
            X_Attribute8           => null,
            X_Attribute9           => null,
            X_Attribute10          => null,
            X_Attribute11          => null,
            X_Attribute12          => null,
            X_Attribute13          => null,
            X_Attribute14          => null,
            X_Attribute15          => null,
            X_Attribute_Category   => null,
            X_Allocation_mode_id   => l_Allocation_mode_id
        );
     end if;

     l_picking_rule_rec.created_by := fnd_global.user_id;
     l_picking_rule_rec.last_updated_by := fnd_global.user_id;
     l_picking_rule_rec.last_update_login := fnd_global.login_id;
     l_picking_rule_rec.creation_date := sysdate;
     l_picking_rule_rec.last_update_date := sysdate;

     p_mtl_picking_rule_rec := l_picking_rule_rec;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END save_to_wms_rule;

  PROCEDURE Restrictions_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS

  l_api_name                    CONSTANT VARCHAR2 (30) := 'Restrictions_insert';
  l_picking_rule_rec            INV_RULE_GEN_PVT.picking_rule_rec;
  l_parameter_id                NUMBER;
  l_Row_Id                      VARCHAR2(500) ;
  l_Sequence_Number             NUMBER;
  l_shelf_days                  NUMBER;
  l_Operator_Code               NUMBER;
  l_Operand_Type_Code           NUMBER;
  l_Operand_Constant_Number     NUMBER ;
  l_Operand_Constant_Character  VARCHAR2(50);
  l_Operand_Constant_Date       DATE;
  l_Operand_Parameter_Id        NUMBER;
  l_Operand_Expression          VARCHAR2(500);
  l_Operand_Flex_Value_Set_Id   NUMBER;
  l_Logical_Operator_Code       NUMBER;
  l_Bracket_Open                VARCHAR2(3);
  l_Bracket_Close               VARCHAR2(3);
  l_apply_to_source             NUMBER;
  l_go_ahead                    NUMBER;
  l_is_mo_line                  NUMBER;
  i                             NUMBER;

  BEGIN
     /* total 3 restrictions
      * 1) shelf days
      * 2) grade for SO
      * 3) customer spec match for SO
      */
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_picking_rule_rec  := p_mtl_picking_rule_rec;
     l_apply_to_source      := l_picking_rule_rec.apply_to_source;

     For i in 1..6 Loop
        l_go_ahead := 0;
        debug('Procedure restrictions_insert i loop '||i);
        debug('source to apply '||l_apply_to_source);
        /* shelf days */
        IF (i = 1 AND (p_mtl_picking_rule_rec.shelf_days is not null) ) then -- shelf days
           l_shelf_days      := p_mtl_picking_rule_rec.shelf_days;
           l_sequence_number := 10;
           debug('shelf days '||l_shelf_days);
           If l_apply_to_source      = 1 then -- SO
              /* SO.schedule_ship_date */
              l_parameter_id                := 60018; -- lot.expiration_date
              l_operand_parameter_id        := 60185; -- SO.schedule_ship_date
              l_operator_code               := '5';   -- '>='
              l_operand_type_code           := '4';   -- ?
              l_operand_expression          := '+'||to_char(l_shelf_days); -- '+ shelf days'
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := null;

              l_go_ahead := 1;
           elsif l_apply_to_source      = 2 then -- GME
              /* GMEMD.plan_start_date */
              l_parameter_id                := 60018; -- the lot.expiration_date
              l_operand_parameter_id        := 5001003;   -- gmebh.plan_start_date
              l_operator_code               := '5';   -- '>='
              l_operand_type_code           := '4';   -- ?
              l_operand_expression          := '+'||to_char(l_shelf_days); -- '+ shelf days'
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := null;

              l_go_ahead := 1;
           elsif l_apply_to_source      = 3 then -- WIP
              /* Lot.date */
              l_parameter_id                := 60018; -- lot.expiration_date
              l_operand_parameter_id        := 10010; -- current date
              l_operator_code               := '5';   -- '>='
              l_operand_type_code           := '4';   -- ?
              l_operand_expression          := '+'||to_char(l_shelf_days); -- '+ shelf days'
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := null;

              l_go_ahead := 1;
           elsif l_apply_to_source IS NULL then -- MO line
              l_parameter_id                := 60018; -- lot.expiration_date
              l_operand_parameter_id        := 60193; -- mo_date_required
              l_operator_code               := '5';   -- '>='
              l_operand_type_code           := '4';   -- ?
              l_operand_expression          := '+'||to_char(l_shelf_days); -- '+ shelf days'
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := null;

              l_is_mo_line := 1;

              l_go_ahead := 1;
           end if;
        END IF;
        /* grade for SO */
        IF  p_mtl_picking_rule_rec.apply_to_source = 1
          and nvl(p_mtl_picking_rule_rec.cust_spec_match_flag,'N') = 'N'
        THEN
           IF i = 2 THEN -- grade rule
              debug('grade rule ');
              -- always insert the grade rule
              l_sequence_number             := 20;
              l_parameter_id                := 60183; -- SO.preferred_grade
              l_operand_parameter_id        := 60141; -- lot.grade_code
              l_operator_code               := '3';   -- '='
              l_operand_type_code           := '4';   -- ?
              l_operand_expression          := null;
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := '((';
              l_bracket_close               := null;
              IF (p_mtl_picking_rule_rec.shelf_days is not null)
              THEN
                 l_logical_operator_code       := 1;  -- 'AND' if rule already exists
              END IF;

              l_go_ahead := 1;
              debug('grade rule go ahead ?'||l_go_ahead);
           END IF;
           IF i = 3 THEN -- grade control rule
              -- and ool.grade_code is not null
              debug('grade ctl rule ');
              -- always insert the grade rule
              l_sequence_number             := 30;
              l_parameter_id                := 60183; -- ool.preferred_grade
              l_operand_parameter_id        := null;
              l_operator_code               := '12';   -- 'is NOT NULL'
              l_operand_type_code           := 7;
              l_operand_expression          := null;
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := ')';

              l_logical_operator_code       := 1;  -- 'AND' grade is inserted already
              l_go_ahead := 1;
              debug('grade rule go ahead ?'||l_go_ahead);
           END IF;
           IF i = 4 THEN -- grade control rule
              -- or ool.grade_code is null
              debug('grade ctl rule ');
              -- always insert the grade rule
              l_sequence_number             := 40;
              l_parameter_id                := 60183; -- ool.preferred_grade
              l_operand_parameter_id        := null;
              l_operator_code               := '11';   -- 'is NOT NULL'
              l_operand_type_code           := 7;
              l_operand_expression          := null;
              l_operand_constant_number     := null;
              l_operand_constant_character  := null;
              l_operand_constant_date       := null;
              l_logical_operator_code       := null;
              l_bracket_open                := null;
              l_bracket_close               := ')';

              l_logical_operator_code       := 2;  -- 'AND' grade is inserted already
              l_go_ahead := 1;
              debug('grade rule go ahead ?'||l_go_ahead);
           END IF;

        END IF;
        IF i = 5 AND p_mtl_picking_rule_rec.apply_to_source = 1
              AND p_mtl_picking_rule_rec.cust_spec_match_flag = 'Y'
        THEN
           debug('cust spec match ');
           l_sequence_number             := 50;
           l_parameter_id                := 60187; -- SO.customer_spec_match
           l_operand_parameter_id        := null;
           l_operator_code               := '3';   -- '='
           l_operand_type_code           := '2';   -- constant character
           l_operand_expression          := null;
           l_operand_constant_number     := null;
           l_operand_constant_character  := 'ACCEPTABLE';
           l_operand_constant_date       := null;
           l_bracket_open                := null;
           l_bracket_close               := null;
           IF (p_mtl_picking_rule_rec.shelf_days is not null)
           THEN
              l_logical_operator_code       := 1;  -- 'AND' if rule already exists
           END IF;

           l_go_ahead := 1;
           debug('cust spec go ahead ?'||l_go_ahead);
        END IF;
        IF i = 6 AND l_is_mo_line = 1 THEN
           debug('add moline.line_id into the where clause');
           l_sequence_number             := 60;
           l_parameter_id                := 60195; -- moline.line_id
           l_operand_parameter_id        := null;
           l_operator_code               := '3';   -- '='
           l_operand_type_code           := '5';   -- expression
           l_operand_expression          := 'mptdtv.line_id'; --null;
           l_operand_constant_number     := null;
           l_operand_constant_character  := null; --'mptdtv.line_id';
           l_operand_constant_date       := null;
           l_bracket_open                := null;
           l_bracket_close               := null;
           IF (p_mtl_picking_rule_rec.shelf_days is not null)
           THEN
              l_logical_operator_code       := 1;  -- 'AND' if rule already exists
           END IF;

           l_go_ahead := 1;
           debug('cust spec go ahead ?'||l_go_ahead);
        END IF;

        IF l_go_ahead = 1 THEN
              debug('call wms restriction insert '||l_go_ahead);
              wms_RESTRICTIONS_PKG.Insert_Row(
               X_Rowid                => l_Row_Id,
               X_Rule_Id              => l_picking_rule_rec.WMS_Rule_Id,
               X_Sequence_Number      => l_Sequence_Number,
               X_Last_Updated_By      => fnd_global.user_id,
               X_Last_Update_Date     => sysdate,
               X_Created_By           => fnd_global.user_id,
               X_Creation_Date        => sysdate,
               X_Last_Update_Login    => fnd_global.login_id,
               X_Parameter_Id         => l_Parameter_Id,
               X_Operator_Code        => l_Operator_Code,
               X_Operand_Type_Code    => l_Operand_Type_Code,
               X_Operand_Constant_Number=> l_Operand_Constant_Number,
               X_Operand_Constant_Character=> l_Operand_Constant_Character,
               X_Operand_Constant_Date=> l_Operand_Constant_Date,
               X_Operand_Parameter_Id => l_Operand_Parameter_Id,
               X_Operand_Expression   => l_Operand_Expression,
               X_Operand_Flex_Value_Set_Id=> l_Operand_Flex_Value_Set_Id,
               X_Logical_Operator_Code=> l_Logical_Operator_Code,
               X_Bracket_Open         => l_Bracket_Open,
               X_Bracket_Close        => l_Bracket_Close,
               X_Attribute_Category   => null,
               X_Attribute1           => null,
               X_Attribute2           => null,
               X_Attribute3           => null,
               X_Attribute4           => null,
               X_Attribute5           => null,
               X_Attribute6           => null,
               X_Attribute7           => null,
               X_Attribute8           => null,
               X_Attribute9           => null,
               X_Attribute10          => null,
               X_Attribute11          => null,
               X_Attribute12          => null,
               X_Attribute13          => null,
               X_Attribute14          => null,
               X_Attribute15          => null
               );
        END IF;
     END LOOP;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END restrictions_insert;

  /*Restrictions update for the form will consist two parts,
   * 1) delete the current rows for the rule_id
   * 2) insert the new rows for the current p_mtl_picking_rule_rec
   */
  PROCEDURE Restrictions_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name                    CONSTANT VARCHAR2 (30) := 'Restrictions_Update';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
        inv_rule_gen_pvt.Restrictions_delete
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.Restrictions_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END restrictions_update;

  PROCEDURE Restrictions_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name                    CONSTANT VARCHAR2 (30) := 'Restrictions_Delete';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     Delete wms_restrictions where rule_id = p_mtl_picking_rule_rec.wms_rule_id;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END restrictions_delete;

  PROCEDURE consistency_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  )
   IS
   l_api_name                    CONSTANT VARCHAR2 (30) := 'consistency_insert';
   l_picking_rule_rec            INV_RULE_GEN_PVT.picking_rule_rec;
   l_consistency_id              NUMBER;
   l_row_id                      VARCHAR2(500);
   l_parameter_id                NUMBER;
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_picking_rule_rec := p_mtl_picking_rule_rec;
     If p_mtl_picking_rule_rec.single_lot = 'Y' then
        -- find the parameter for lot.lot_number
        l_parameter_id := 60006; -- lot.lot_Number
        select wms_rule_consistencies_s.nextval into l_consistency_Id from dual;

        WMS_RULE_CONSISTENCIES_PKG.INSERT_ROW(
          X_ROWID              => l_ROW_ID,
          X_CONSISTENCY_ID     => l_CONSISTENCY_ID,
          X_RULE_ID            => l_picking_rule_rec.WMS_RULE_ID,
          X_CREATION_DATE      => sysdate,
          X_CREATED_BY         => fnd_global.user_id,
          X_LAST_UPDATE_DATE   => sysdate,
          X_LAST_UPDATED_BY    => fnd_global.user_id,
          X_LAST_UPDATE_LOGIN  => fnd_global.login_id,
          X_PARAMETER_ID       => l_parameter_id,
          X_ATTRIBUTE_CATEGORY => '',
          X_ATTRIBUTE1         => '',
          X_ATTRIBUTE2         => '',
          X_ATTRIBUTE3         => '',
          X_ATTRIBUTE4         => '',
          X_ATTRIBUTE5         => '',
          X_ATTRIBUTE6         => '',
          X_ATTRIBUTE7         => '',
          X_ATTRIBUTE8         => '',
          X_ATTRIBUTE9         => '',
          X_ATTRIBUTE10        => '',
          X_ATTRIBUTE11        => '',
          X_ATTRIBUTE12        => '',
          X_ATTRIBUTE13        => '',
          X_ATTRIBUTE14        => '',
          X_ATTRIBUTE15        => ''
         );

     end if;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END consistency_insert;

  PROCEDURE Consistency_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  )
   IS
  l_api_name                    CONSTANT VARCHAR2 (30) := 'Consistency_Update';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
        inv_rule_gen_pvt.consistency_delete
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.consistency_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END consistency_update;

  PROCEDURE Consistency_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER
  )
   IS
  l_api_name                    CONSTANT VARCHAR2 (30) := 'Consistency_Delete';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     Delete wms_rule_consistencies where rule_id = p_mtl_picking_Rule_rec.wms_rule_id;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END consistency_delete;

  PROCEDURE Sorting_criteria_insert
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Sorting_criteria_insert';
  l_sort_order              NUMBER;
  l_sequence                NUMBER;
  l_row_id                  VARCHAR2(500);
  l_parameter_id            NUMBER;
  l_order_code              NUMBER;
  i                         NUMBER;
  l_go_ahead                NUMBER;
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     debug('sort insert, lot_sort_rank '||p_mtl_picking_rule_rec.lot_sort_rank);
     debug('sort insert, revision_sort_rank '||p_mtl_picking_rule_rec.revision_sort_rank);
     debug('sort insert, sub_sort_rank '||p_mtl_picking_rule_rec.subinventory_sort_rank);
     debug('sort insert, locator_sort_rank '||p_mtl_picking_rule_rec.locator_sort_rank);
     FOR i IN 1..4 LOOP
        l_go_ahead := 0;              -- NO insert
        If i = 1 AND p_mtl_picking_rule_rec.lot_sort IS NOT NULL Then
           --Get the parameter_id for lot.FIFO/FEFO
           --Get the parameter_id lot_number, base.lot_number 10004
           l_sequence   := p_mtl_picking_rule_rec.lot_sort_rank;
           l_sort_order := p_mtl_picking_rule_rec.lot_sort;
           if l_sort_order = 3 THEN -- FIFO
              l_parameter_id := 10008;  -- Receipt Date --60012; -- creation_date
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 4 THEN -- FEFO
              l_parameter_id := 60018; -- expiration_date
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 1 THEN -- Lot Number Asc
              l_parameter_id := 10004; -- Lot number
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 2 THEN -- Lot Number Desc
              l_parameter_id := 10004; -- Lot number
              l_order_code   := 2;     -- Descending
           end if;
          l_go_ahead := 1;
        End if;
        If i = 2 AND p_mtl_picking_rule_rec.revision_sort IS NOT NULL Then
           --Get the parameter_id for object mtl_item_revisions.revision object_id=5
           --Get the parameter_id for object mtl_item_revisions.effectivity_date object_id=5 50013
           l_sequence   := p_mtl_picking_rule_rec.revision_sort_rank;
           l_sort_order := p_mtl_picking_rule_rec.revision_sort;
           if l_sort_order = 1 THEN -- revision asceding
              l_parameter_id := 10003; -- revision
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 2 THEN -- revision desceding
              l_parameter_id := 10003; -- expiration_date
              l_order_code   := 2;     -- Desceding
           elsif l_sort_order = 3 THEN -- effective date asceding
              l_parameter_id := 50013; -- effective_date
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 4 THEN -- effective date desceding
              l_parameter_id := 50013; -- effective_date
              l_order_code   := 2;     -- Desceding
           end if;
          l_go_ahead := 1;
        End if;
        If i = 3 AND p_mtl_picking_rule_rec.locator_sort IS NOT NULL Then
           --Get the parameter_id for object source locator.locator identifier
           -- mtl_item_locations.picking_order object_id=8
           -- stock on hand. receipt date object_id=54
           l_sequence   := p_mtl_picking_rule_rec.locator_sort_rank;
           l_sort_order := p_mtl_picking_rule_rec.locator_sort;
           if l_sort_order = 1 THEN -- locator asceding
              l_parameter_id := 80012; -- picking order
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 2 THEN -- revision desceding
              l_parameter_id := 80012; -- picking order
              l_order_code   := 2;     -- Desceding
           elsif l_sort_order = 3 THEN -- receipt date asceding
              l_parameter_id := 10008; -- receipt date
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 4 THEN -- receipt date desceding
              l_parameter_id := 10008; -- receipt date
              l_order_code   := 2;     -- Desceding
           end if;
          l_go_ahead := 1;
        End if;
        If i = 4 AND p_mtl_picking_rule_rec.subinventory_sort IS NOT NULL Then
           --Get the parameter_id for object source subinventory
           -- mtl_secondary_inventories.picking order object_id=7
           -- stock on hand. receipt date object_id=54
           l_sequence   := p_mtl_picking_rule_rec.subinventory_sort_rank;
           l_sort_order := p_mtl_picking_rule_rec.subinventory_sort;
           if l_sort_order = 1 THEN -- locator asceding
              l_parameter_id := 70015; -- picking order
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 2 THEN -- revision desceding
              l_parameter_id := 70015; -- picking order
              l_order_code   := 2;     -- Desceding
           elsif l_sort_order = 3 THEN -- receipt date asceding
              l_parameter_id := 10008; -- receipt date
              l_order_code   := 1;     -- Asceding
           elsif l_sort_order = 4 THEN -- receipt date desceding
              l_parameter_id := 10008; -- receipt date
              l_order_code   := 2;     -- Desceding
           end if;
          l_go_ahead := 1;
        End if;

        if l_go_ahead = 1 THEN
           debug('sort insert, '|| i);
           debug('sort insert, sequence '||l_sequence);
           debug('sort insert, wms_rule_id '||p_mtl_picking_rule_rec.wms_rule_id);
           wms_SORT_CRITERIA_PKG.Insert_Row
           (
              X_Rowid                => l_Row_Id,
              X_Rule_Id              => p_mtl_picking_rule_rec.WMS_Rule_Id,
              X_Sequence_Number      => l_Sequence,
              X_Parameter_Id         => l_Parameter_Id,
              X_Order_Code           => l_Order_Code,
              X_Created_By           => fnd_global.user_id,
              X_Creation_Date        => sysdate,
              X_Last_Updated_By      => fnd_global.user_id,
              X_Last_Update_Date     => sysdate,
              X_Last_Update_Login    => fnd_global.login_id,
              X_Attribute1           => null,
              X_Attribute2           => null,
              X_Attribute3           => null,
              X_Attribute4           => null,
              X_Attribute5           => null,
              X_Attribute6           => null,
              X_Attribute7           => null,
              X_Attribute8           => null,
              X_Attribute9           => null,
              X_Attribute10          => null,
              X_Attribute11          => null,
              X_Attribute12          => null,
              X_Attribute13          => null,
              X_Attribute14          => null,
              X_Attribute15          => null,
              X_Attribute_Category   => null
           );
        end if;
     END LOOP;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END sorting_criteria_insert;

  /* Update consist two parts
   * 1) Delete the current row for the rule_id
   * 2) Insert new rows for the current setup
   */

  PROCEDURE sorting_criteria_update
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Sorting_criteria_Update';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
        inv_rule_gen_pvt.sorting_criteria_delete
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
        inv_rule_gen_pvt.sorting_criteria_insert
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END sorting_criteria_update;

  PROCEDURE Sorting_criteria_delete
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Sorting_criteria_Delete';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     debug('delete sorting criteria');
     Delete wms_sort_criteria where rule_id = p_mtl_picking_Rule_rec.wms_rule_id;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END sorting_criteria_delete;

  PROCEDURE Strategy_insert
  (p_mtl_picking_rule_rec       IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  )
  IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Strategy_insert';
  l_strategy_id              NUMBER;
  l_strategy_name            VARCHAR2(50);
  l_rowid                    VARCHAR2(500);
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --check enabled flag for the rule, only insert strategy for enabled rules
     debug('Procedure Strategy_insert');
     if p_mtl_picking_rule_rec.enabled_flag <> 'Y' Then
        return;
     end if;
     -- insert the strategy with the same name of the rule
     select WMS_strategies_s.nextval into l_strategy_id from sys.dual;
     l_strategy_name := p_mtl_picking_rule_rec.name;
     debug('strategy_id '||l_strategy_id);
     debug('strategy_name '||l_strategy_name);
     WMS_STRATEGIES_PKG.Insert_Row
     (
          X_Rowid                => l_ROWID
        , X_Strategy_Id          => l_Strategy_Id
        , X_Organization_Id      => -1
        , X_Type_Code            => 2
        , X_Name                 => l_strategy_name
        , X_Description          => l_strategy_name
        , X_Enabled_Flag         => 'Y'
        , X_User_Defined_Flag    => 'Y'
        , X_Created_By           => fnd_global.user_id
        , X_Creation_Date        => SYSDATE
        , X_Last_Updated_By      => fnd_global.user_id
        , X_Last_Update_Date     => SYSDATE
        , X_Last_Update_Login    => fnd_global.login_id
        , X_Attribute1           => null
        , X_Attribute2           => null
        , X_Attribute3           => null
        , X_Attribute4           => null
        , X_Attribute5           => null
        , X_Attribute6           => null
        , X_Attribute7           => null
        , X_Attribute8           => null
        , X_Attribute9           => null
        , X_Attribute10          => null
        , X_Attribute11          => null
        , X_Attribute12          => null
        , X_Attribute13          => null
        , X_Attribute14          => null
        , X_Attribute15          => null
        , X_Attribute_Category   => null
     );
     p_mtl_picking_rule_rec.wms_strategy_id := l_strategy_id;
     /* insert strategy_members */
     debug('calling insert strategy members ');
     WMS_STRATEGY_MEMBERS_PKG.Insert_Row(
          X_Rowid                => l_RowId
        , X_Strategy_Id          => l_Strategy_Id
        , X_Sequence_Number      => 10
        , X_Rule_Id              => p_mtl_picking_rule_rec.wms_Rule_Id
        , X_Partial_Success_Allowed_Flag=> p_mtl_picking_rule_rec.Partial_Allowed_Flag
        , X_Effective_From       => null
        , X_Effective_To         => null
        , X_Created_By           => fnd_global.user_id
        , X_Creation_Date        => sysdate
        , X_Last_Updated_By      => fnd_global.user_id
        , X_Last_Update_Date     => sysdate
        , X_Last_Update_Login    => fnd_global.login_id
        , X_Attribute1           => null
        , X_Attribute2           => null
        , X_Attribute3           => null
        , X_Attribute4           => null
        , X_Attribute5           => null
        , X_Attribute6           => null
        , X_Attribute7           => null
        , X_Attribute8           => null
        , X_Attribute9           => null
        , X_Attribute10          => null
        , X_Attribute11          => null
        , X_Attribute12          => null
        , X_Attribute13          => null
        , X_Attribute14          => null
        , X_Attribute15          => null
        , X_Attribute_Category   => null
        , X_Date_Type_Code       => 11              -- always
        , X_Date_Type_Lookup_Type => null
        , X_Date_Type_From        => null
        , X_Date_Type_To          => null
         );
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  End strategy_insert;

  /* Only enabled flag can be updated. */
  /* disable the strategy when rule is disabled */
  PROCEDURE Strategy_update
  (p_mtl_picking_rule_rec       IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  )
   IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Strategy_Update';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     if p_mtl_picking_rule_rec.enabled_flag = 'N' then
        WMS_STRATEGIES_PKG.Update_Row(
            X_Strategy_Id          => p_mtl_picking_rule_rec.wms_Strategy_Id,
            X_Organization_Id      => -1,
            X_Type_Code            => 2,
            X_Name                 => p_mtl_picking_rule_rec.name,
            X_Description          => p_mtl_picking_rule_rec.name,
            X_Enabled_Flag         => p_mtl_picking_rule_rec.enabled_flag,
            X_User_Defined_Flag    => 'Y',
            X_Last_Updated_By      => fnd_global.user_id,
            X_Last_Update_Date     => sysdate,
            X_Last_Update_Login    => fnd_global.user_id,
            X_Attribute1           => null,
            X_Attribute2           => null,
            X_Attribute3           => null,
            X_Attribute4           => null,
            X_Attribute5           => null,
            X_Attribute6           => null,
            X_Attribute7           => null,
            X_Attribute8           => null,
            X_Attribute9           => null,
            X_Attribute10          => null,
            X_Attribute11          => null,
            X_Attribute12          => null,
            X_Attribute13          => null,
            X_Attribute14          => null,
            X_Attribute15          => null,
            X_Attribute_Category   => null
            );
    end if;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END;

  /*  when rule is deleted, strategy is also deleted */
  PROCEDURE Strategy_delete
  (p_mtl_picking_rule_rec       IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status             OUT NOCOPY VARCHAR2
  , x_msg_data                  OUT NOCOPY VARCHAR2
  , x_msg_count                 OUT NOCOPY NUMBER
  )
   IS
  l_api_name                CONSTANT VARCHAR2 (30) := 'Strategy_Delete';
  Begin
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     null;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END;

  PROCEDURE Rule_Enabled_Flag
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'Strategy_Delete';
  l_picking_rule_rec       INV_RULE_GEN_PVT.picking_rule_rec;
  l_return_status          VARCHAR2(1);
  l_msg_data               VARCHAR2(2000);
  l_msg_count              NUMBER;
  v_type_code              number;
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_picking_rule_rec := p_mtl_picking_rule_rec;
       debug('Procedure rule enable flag');
       IF l_picking_rule_rec.Enabled_Flag = 'Y' THEN
         l_picking_rule_rec.enabled_flag:='Y';
          -- Check rule Syntax
            debug('checksyntax');
            WMS_rule_PVT.CheckSyntax (
            p_api_version             => 1.0
            ,p_init_msg_list          => FND_API.G_TRUE
            ,p_validation_level       => FND_API.G_VALID_LEVEL_NONE
            ,x_return_status          => l_return_status
            ,x_msg_count              => l_msg_count
            ,x_msg_data               => l_msg_data
            ,p_rule_id	               => l_picking_rule_rec.wms_rule_ID
               );
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               debug('checksyntax failed');
               --INV_GLOBAL_PKG.Show_Errors;
               l_picking_rule_rec.Enabled_Flag := 'N';
            END IF;
           ---  Calling The Generate l_mtl_picking_rule_rec.list pkg
           IF l_picking_rule_rec.Enabled_Flag = 'Y' THEN
              debug('generateruleexecpkgs');
              WMS_rule_gen_pkgs.GenerateRuleExecPkgs
              (
                 p_api_version           => 1.0
                ,p_init_msg_list         => FND_API.G_TRUE
                ,p_validation_level      => FND_API.G_VALID_LEVEL_NONE
                ,x_return_status         => l_return_status
                ,x_msg_count             => l_msg_count
                ,x_msg_data              => l_msg_data
                ,p_pick_code             => 2
                ,p_put_code              => null
                ,p_task_code             => null
                ,p_label_code            => null
                ,p_CG_code               => null
                ,p_op_code               => null
                ,p_pkg_type              => 'B'
              );

            /*  if l_picking_rule_rec.wms_strategy_id is null THEN
                 inv_rule_gen_pvt.Strategy_insert
                 (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
                 , x_return_status      => x_return_status
                 , x_msg_data           => x_msg_data
                 , x_msg_count          => x_msg_count
                 );
              Else
                 inv_rule_gen_pvt.Strategy_Update
                 (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
                 , x_return_status      => x_return_status
                 , x_msg_data           => x_msg_data
                 , x_msg_count          => x_msg_count
                 );
              End if;
           */
              debug('after strategy_insert '||p_mtl_picking_rule_rec.wms_strategy_id);
              update wms_rules_b
              set enabled_flag = 'Y'
              where rule_id=p_mtl_picking_rule_rec.wms_rule_id;
              commit;
           End if;
       ELSE -- disable the flag
         l_picking_rule_rec.enabled_flag:='N';
           debug('disabling the rule and strategy');
           /*
           inv_rule_gen_pvt.Strategy_Update
           (p_mtl_picking_rule_rec=> p_mtl_picking_rule_rec
           , x_return_status      => x_return_status
           , x_msg_data           => x_msg_data
           , x_msg_count          => x_msg_count
           );
           */
           debug('after strategy_update '||p_mtl_picking_rule_rec.wms_strategy_id);
           update wms_rules_b
           set enabled_flag = 'N'
           where rule_id=p_mtl_picking_rule_rec.wms_rule_id;
           commit;
       END IF;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END Rule_Enabled_Flag;

  FUNCTION rule_assigned_to_strategy
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
  RETURN BOOLEAN IS
  l_api_name               CONSTANT VARCHAR2 (30) := 'rule_assigned_to_strategy';
/*
    CURSOR L_curStrategyMembers(p_rule_id IN NUMBER) IS
    SELECT 'X'
    FROM   wms_strategy_members MPSM, wms_strategies_b S
    WHERE  MPSM.rule_id = p_rule_id
    AND    S.Strategy_Id = MPSM.Strategy_Id
    AND    S.Enabled_Flag = 'Y'
    AND    NVL(MPSM.Effective_From,TO_DATE('01011900','DDMMYYYY')) <= TRUNC(sysdate)
    AND    NVL(MPSM.Effective_To,TO_DATE('31124000','DDMMYYYY')) >= TRUNC(sysdate)
    AND    rownum < 2;

    CURSOR StratAssignments_old (p_strategy_id in NUMBER) IS
   SELECT 'X'
     FROM  wms_selection_criteria_txn WSCT
    WHERE  WSCT.return_type_code  = 'S'
      AND  WSCT.return_type_id = p_strategy_id
      AND  WSCT.enabled_flag = 1
      AND  NVL(WSCT.Effective_From,TO_DATE('01011900','DDMMYYYY')) <= TRUNC(sysdate)
      AND  NVL(WSCT.Effective_To,TO_DATE('31124000','DDMMYYYY')) >= TRUNC(sysdate)
      AND  rownum           < 2;
 */
  ---- New Cursor added for checking if the rule is assigned directly in the assignment matrix

    CURSOR StratAssignments_new (p_rule_id IN NUMBER) IS
   SELECT 'X'
     FROM  wms_selection_criteria_txn WSCT
    WHERE  WSCT.return_type_code  = 'R'
      AND  WSCT.return_type_id = p_rule_id
      AND  WSCT.enabled_flag = 1
      AND  NVL(WSCT.Effective_From,TO_DATE('01011900','DDMMYYYY')) <= TRUNC(sysdate)
      AND  NVL(WSCT.Effective_To,TO_DATE('31124000','DDMMYYYY')) >= TRUNC(sysdate)
      AND  rownum           < 2;

  --- Setting the profile option to be deleted later on
    -- Bug# 7502663 Defaulted the value of rules engine to 1 instead of picking from profile
    -- l_rules_engine_mode     NUMBER  :=  NVL(FND_PROFILE.VALUE('WMS_RULES_ENGINE_MODE'), 0);
    l_rules_engine_mode     NUMBER := 1;

    l_nDummy	VARCHAR2(1);
    l_bReturn	BOOLEAN;
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     debug('check rule is assigned');
     debug('rule_id '|| p_mtl_picking_rule_rec.wms_rule_id);
     debug('strategy_id '|| p_mtl_picking_rule_rec.wms_strategy_id);
   /*
    -- Check if rule is assigned to strategy member
    OPEN L_curStrategyMembers(p_mtl_picking_rule_rec.wms_rule_id);
    FETCH L_curStrategyMembers INTO L_nDummy;
    IF L_curStrategyMembers%NOTFOUND THEN
       L_bReturn := FALSE;
    ELSE
       L_bReturn := TRUE;
    END IF;

    OPEN StratAssignments_old(p_mtl_picking_rule_rec.wms_strategy_id);
    FETCH StratAssignments_old into L_nDummy;
    IF StratAssignments_old%NOTFOUND THEN
      L_bReturn := FALSE;
    ELSE
      L_bReturn := TRUE;
    END IF;
    CLOSE StratAssignments_old;
   */
    --- checking if the rule is assigned directly in the assignment matrix

    IF (l_rules_engine_mode = 1) then

      -- Bug# 7502663 Modified the parameter for opening the cursor to
      -- wms_rule_id instead of wms_strategy_id
      -- OPEN StratAssignments_new(p_mtl_picking_rule_rec.wms_strategy_id);
       OPEN StratAssignments_new(p_mtl_picking_rule_rec.wms_rule_id);

       FETCH StratAssignments_new into L_nDummy;
       IF StratAssignments_new%NOTFOUND THEN
         L_bReturn := FALSE;
       ELSE
         L_bReturn := TRUE;
       END IF;
       CLOSE StratAssignments_new;
    end if;

    RETURN(l_bReturn);
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      WHEN OTHERS THEN
        debug('sqlerror'|| SUBSTRB(SQLERRM, 1, 100));
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END rule_assigned_to_strategy;

  PROCEDURE GenerateRulePKG
  (p_mtl_picking_rule_rec    IN OUT NOCOPY INV_RULE_GEN_PVT.picking_rule_rec
  , x_return_status          OUT NOCOPY VARCHAR2
  , x_msg_data               OUT NOCOPY VARCHAR2
  , x_msg_count              OUT NOCOPY NUMBER)
   IS
  l_api_name           CONSTANT VARCHAR2 (30) := 'GenerateRulePKG';
  l_return_status      VARCHAR2(1);
  l_msg_data           VARCHAR2(2000);
  l_msg_count          NUMBER;
  rec_status           VARCHAR2(25);
  BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_mtl_picking_rule_rec.Enabled_Flag = 'Y' THEN
        WMS_Rule_PVT.GenerateRulePackage
        (
          p_api_version            => 1.0
         ,p_init_msg_list          => FND_API.G_TRUE
         ,p_validation_level       => FND_API.G_VALID_LEVEL_NONE
         ,x_return_status          => x_return_status
         ,x_msg_count              => x_msg_count
         ,x_msg_data               => x_msg_data
         ,p_rule_id                => p_mtl_picking_rule_rec.wms_RULE_ID
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
           p_mtl_picking_rule_rec.Enabled_Flag := 'N';
           RAISE FND_API.G_EXC_ERROR;
        ELSE
           fnd_message.set_name('WMS','WMS_PACKAGE_REGENERATE');
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
      debug('regenerate rule pkgs. error exception');
      WHEN OTHERS THEN
        debug('regenerate others'||SQLCODE||'.');
        x_return_status := SQLCODE;
        FND_MSG_PUB.Add_Exc_Msg (g_pkg_name
                               , l_api_name
                              );
      /*   Get message count and data */
      FND_MSG_Pub.count_and_get
       (   p_count  => x_msg_count
         , p_data  => x_msg_data
       );
  END GenerateRulePKG;

END inv_rule_gen_pvt;

/
