--------------------------------------------------------
--  DDL for Package Body BOMPCCLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCCLT" AS
/* $Header: BOMCCLTB.pls 120.2 2006/02/16 04:24:22 abbhardw ship $ */
/*-----------------------------------------------------------------------------
-------------------------------------------------------------------------------
 Copyright (c) 1993 Oracle Corporation Belmont, California, USA
                        All rights reserved.
-------------------------------------------------------------------------------

File Name    : BOMCCLTB.pls
DESCRIPTION  : This file is a packaged procedure for lead time rollup.
               This package contains 4 procedures. Procedure explode_assy
               explodes a given assembly into its components. Procedure
               set_comp_lt computes cumulative lead times for all
               purchased items. Procedure process_items computes cum lead
               times for a given bom level. Procedure update_lt updates
               mtl_system_items with cumulative lead time values.
Required Tables :
               BOM_PARAMETERS
               BOM_INVENTORY_COMPONENTS
               BOM_BILL_OF_MATERIALS
               BOM_LOW_LEVEL_CODES
               MTL_SYSTEM_ITEMS
History
         20-Feb-1996  Manu Chadha
                            -Added the MTL.ORGANIZATION_ID = org_id; line to to
          update_lc as a fix for bug#343531
         02-Oct-1997  Rob Yee
          Streamline for performance by using
          recursion for explosion and updating leadtimes
          in mtl_system_items directly
         21-Aug-1998  Mani
          Added unit number and changed SQL statements
          to implement Serial Effectivity.
         13-May-2004  Rahul Chitko
          -Added alternate_bom_code parameter to be able to
          perform rollup for specified alternate.
-----------------------------------------------------------------------------*/
Type StackTabType is table of number index by binary_integer;
G_CommitRows constant number := 1000; -- frequency of commits

Procedure explode_next_level(
  p_item_id       IN NUMBER,
  p_org_id        IN NUMBER,
  p_prgm_id       IN NUMBER,
  p_prgm_app_id   IN NUMBER,
  p_req_id        IN NUMBER,
  p_roll_id       IN NUMBER,
  p_unit_number   IN VARCHAR2,
  p_eff_date      IN DATE,
  p_max_level     IN NUMBER DEFAULT 60,
  p_alternate_bom_code  IN VARCHAR2 DEFAULT NULL,
  p_Path    IN OUT NOCOPY StackTabType,
  p_Level     IN OUT NOCOPY  binary_integer,
  x_LoopFound     IN OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
  x_err_msg       IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) is

l_LoopFound boolean := false;
l_err_msg varchar2(2000) := null;
l_FatalError exception;
Cursor l_comps_csr (p_org_id number, p_item_id number, p_unit_number varchar2,
      p_eff_date date) is
  SELECT COM.COMPONENT_ITEM_ID
  FROM MTL_SYSTEM_ITEMS         MTL2,
       BOM_INVENTORY_COMPONENTS COM,
       MTL_SYSTEM_ITEMS         MTL1,
       BOM_BILL_OF_MATERIALS    BOM
  WHERE NVL(BOM.ALTERNATE_BOM_DESIGNATOR,'XXXXXXXXXXX') =
  NVL(p_alternate_bom_code,'XXXXXXXXXXX')
  AND   COM.BILL_SEQUENCE_ID = BOM.COMMON_BILL_SEQUENCE_ID
  AND   BOM.ORGANIZATION_ID = p_org_id
  AND   BOM.ASSEMBLY_ITEM_ID = p_item_id
  AND   MTL1.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
  AND   MTL1.ORGANIZATION_ID = BOM.ORGANIZATION_ID
  AND   MTL2.INVENTORY_ITEM_ID = COM.COMPONENT_ITEM_ID
  AND   MTL2.ORGANIZATION_ID = BOM.ORGANIZATION_ID
  AND   COM.IMPLEMENTATION_DATE IS NOT NULL
  AND   NVL(COM.ECO_FOR_PRODUCTION,2) = 2
  AND  NOT  (mtl1.replenish_to_order_flag = 'Y'
       AND mtl1.bom_item_type = 4
       AND mtl1.base_item_id IS NOT NULL
       AND MTL2.BOM_ITEM_TYPE IN (1,2))
  AND   (
         COM.DISABLE_DATE IS NULL
         OR
         COM.DISABLE_DATE > p_eff_date
        )
  AND   ((MTL1.EFFECTIVITY_CONTROL <> 1
  AND   p_unit_number is NOT NULL
  AND   COM.DISABLE_DATE IS NULL
  AND   p_unit_number BETWEEN COM.FROM_END_ITEM_UNIT_NUMBER AND
        NVL(COM.TO_END_ITEM_UNIT_NUMBER, p_unit_number))
   OR   (MTL1.EFFECTIVITY_CONTROL = 1
  AND   COM.EFFECTIVITY_DATE <=  p_eff_date));

cursor l_item_csr(P_ItemId number, P_OrgId number) is
  Select item_number
  From mtl_item_flexfields
  Where item_id = P_ItemId
  And organization_id = P_OrgId;
  l_stmt varchar2(3);
Begin
  l_LoopFound := false;
  l_err_msg := null;
  l_stmt := '1';
  For l_comps_rec in l_comps_csr(
  p_org_id => p_org_id,
  p_item_id => p_item_id,
  p_unit_number => p_unit_number,
  p_eff_date => p_eff_date) loop
    l_stmt := '2';
    For i in 0..p_level loop -- loop check
      If p_path(i) =  l_comps_rec.component_item_id then
        l_LoopFound := true;
      End if;
    End loop;
    p_level := p_level + 1;
    p_path(p_level) := l_comps_rec.component_item_id;
    If (not l_LoopFound) and (p_level < p_max_level) then
      explode_next_level(
        p_item_id     => l_comps_rec.component_item_id,
        p_org_id      => p_org_id,
        p_prgm_id     => p_prgm_id,
        p_prgm_app_id => p_prgm_app_id,
        p_req_id      => p_req_id,
        p_roll_id     => p_roll_id,
        p_unit_number => p_unit_number,
        p_eff_date    => p_eff_date,
        p_max_level   => p_max_level,
        p_path        => p_path,
        p_level       => p_level,
  p_alternate_bom_code => p_alternate_bom_code,
        x_LoopFound   => l_LoopFound,
        x_err_msg     => l_err_msg);
    End if; -- recursion
    If l_LoopFound then
      l_stmt := '3';
      For l_item_rec in l_item_csr(
      P_ItemId => l_comps_rec.component_item_id,
      P_OrgId => p_org_id) loop
        l_err_msg := '-->'||l_item_rec.item_number||l_err_msg;
      End loop; -- loop string
      Exit;
    Elsif l_err_msg is not null then
      Raise l_FatalError;
    Else
      l_stmt := '4';
      Update bom_low_level_codes
      Set low_level_code = p_level,
          program_update_date = sysdate
      Where rollup_id = p_roll_id
      And inventory_item_id = l_comps_rec.component_item_id
      And low_level_code < p_level;
      l_stmt := '5';
      Insert into bom_low_level_codes(
        rollup_id,
        inventory_item_id,
        low_level_code,
        request_id,
        program_application_id,
        program_id,
        program_update_date)
      Select
        p_roll_id,
        l_comps_rec.component_item_id,
        p_level,
        p_req_id,
        p_prgm_app_id,
        p_prgm_id,
        sysdate
      From dual
      Where not exists(
        Select null
        From bom_low_level_codes
        Where rollup_id = p_roll_id
        And inventory_item_id = l_comps_rec.component_item_id
        And low_level_code >= p_level);
    End if;
    If mod(l_comps_csr%rowcount, G_CommitRows) = 0 then
      --Commit; -- conserve rollback segments
  null;
    End if;
    p_level := p_level - 1;
  End loop; -- components
  --Commit;
  x_LoopFound := l_LoopFound;
  x_err_msg := l_err_msg;
Exception
  When l_FatalError then
    x_LoopFound := false;
    x_err_msg := l_err_msg;
  When others then
    x_LoopFound := false;
    FND_MSG_PUB.Build_Exc_Msg(
      p_pkg_name => 'BOMPCCLT',
      p_procedure_name => 'explode_next_level('||l_stmt||')');
      x_err_msg := Fnd_Message.Get_Encoded;
End explode_next_level;

Procedure explode_assy(
  org_id          IN NUMBER,
  prgm_id         IN NUMBER,
  prgm_app_id     IN NUMBER,
  req_id          IN NUMBER,
  roll_id         IN NUMBER,
  unit_number     IN VARCHAR2,
  eff_date        IN DATE,
  alternate_bom_code  IN VARCHAR2,
  loop_found      IN OUT NOCOPY /* file.sql.39 change */ BOOLEAN,
  err_msg         IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

  l_AbsoluteMaxLevel constant number := 60;
  cursor l_parameter_csr is
    SELECT MAXIMUM_BOM_LEVEL
    FROM   BOM_PARAMETERS
    WHERE  ORGANIZATION_ID = org_id;
  max_bom_level     NUMBER;
  l_stmt_num      varchar2(3);
  cursor l_list_csr is
    Select bl.assembly_item_id,
           bl.conc_flex_string
    From bom_lists bl, mtl_system_items msi
    Where bl.sequence_id = roll_id
      and msi.organization_id = org_id
      and msi.inventory_item_id = bl.assembly_item_id
      and (unit_number is NOT NULL
       or (unit_number is NULL and msi.effectivity_control = 1));
  l_LoopFound boolean := false;
  l_err_msg varchar2(2000) := null;
  l_FatalError exception;
  l_path StackTabType;
  l_level binary_integer := 0;
BEGIN
  -- maximum levels that a BOM can be exploded
  max_bom_level := l_AbsoluteMaxLevel;
  l_stmt_num := '1';
  For l_parameter_rec in l_parameter_csr loop
    max_bom_level := l_parameter_rec.MAXIMUM_BOM_LEVEL;
  End loop;
  If max_bom_level is NULL then
    max_bom_level := l_AbsoluteMaxLevel;
  End if;

  -- explode the assemblies in list and insert into BOM_LOW_LEVEL_CODES

--bom_debug('starting walk down of ' || alternate_bom_code);

  l_LoopFound := false;
  l_err_msg := null;
  For l_bill_rec in l_list_csr loop
    l_level := 0;
    l_path(l_level) := l_bill_rec.assembly_item_id;
    explode_next_level(
          p_item_id         => l_bill_rec.assembly_item_id,
          p_org_id          => org_id,
          p_prgm_id         => prgm_id,
          p_prgm_app_id     => prgm_app_id,
          p_req_id          => req_id,
          p_roll_id         => roll_id,
          p_unit_number     => unit_number,
          p_eff_date        => eff_date,
          p_max_level       => max_bom_level,
          p_path          => l_path,
          p_level           => l_level,
          p_alternate_bom_code  => alternate_bom_code,
          x_LoopFound       => l_LoopFound,
          x_err_msg         => l_err_msg);
    If l_LoopFound then
      l_stmt_num := '2';
      l_err_msg := l_bill_rec.conc_flex_string||l_err_msg;
      Exit;
    Elsif l_err_msg is not null then
      Raise l_FatalError;
    Else
      l_stmt_num := '3';
      Insert into bom_low_level_codes(
        rollup_id,
        inventory_item_id,
        low_level_code,
        request_id,
        program_application_id,
        program_id,
        program_update_date)
      Select
        roll_id,
        l_bill_rec.assembly_item_id,
        0,
        req_id,
        prgm_app_id,
        prgm_id,
        sysdate
      From dual
      Where not exists(
        Select null
        From bom_low_level_codes
        Where rollup_id = roll_id
        And inventory_item_id = l_bill_rec.assembly_item_id
        And low_level_code >= 0);
    End if;
    If mod(l_list_csr%rowcount, G_CommitRows) = 0 then
      --Commit; -- conserve rollback segments
  null;
    End if;
  End loop; -- components
  --Commit;
  loop_found := l_LoopFound;
  err_msg := l_err_msg;
EXCEPTION
  When l_FatalError then
    loop_found := false;
    err_msg := l_err_msg;
  WHEN OTHERS THEN
    loop_found := false;
    FND_MSG_PUB.Build_Exc_Msg(
      p_pkg_name => 'BOMPCCLT',
      p_procedure_name => 'explode_assy('||l_stmt_num||')');
      err_msg := Fnd_Message.Get_Encoded;
END explode_assy;

PROCEDURE update_lt(
  org_id      IN NUMBER,
  roll_id     IN NUMBER,
  prgm_id     IN NUMBER,
  prgm_app_id IN NUMBER,
  req_id      IN NUMBER,
  unit_number IN VARCHAR2,
  rev_date    IN DATE,
  err_msg     IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

X_include_in_rollup  varchar2(1) := 'N';
X_include_models     varchar2(1) := 'N';

  cursor l_LowLevelCode_csr is
    Select nvl(max(low_level_code), -1) depth
    From bom_low_level_codes
    Where rollup_id = roll_id;
  l_depth number;

  CURSOR l_assy_csr(p_level number) is
      select  MTL.ROWID row_id,
            MTL.INVENTORY_ITEM_ID,
            NVL(MTL.PREPROCESSING_LEAD_TIME, 0) +
              NVL(MTL.POSTPROCESSING_LEAD_TIME, 0) +
              NVL(MTL.FULL_LEAD_TIME, 0) TOTAL_LEAD_TIME,
      DECODE(MTL.PLANNING_MAKE_BUY_CODE,
              2, 0,
              NVL(MTL.FULL_LEAD_TIME, 0)) FULL_LEAD_TIME,
            MTL.PLANNING_MAKE_BUY_CODE,
            MTL.bom_item_type bom_item_type
  from mtl_system_items MTL,
       bom_low_level_codes LLC
  where  LLC.ROLLUP_ID = roll_id
        AND    LLC.LOW_LEVEL_CODE = p_level
  AND    MTL.INVENTORY_ITEM_ID = LLC.INVENTORY_ITEM_ID
  AND    MTL.ORGANIZATION_ID = org_id
        For update of mtl.CUMULATIVE_TOTAL_LEAD_TIME,
                      mtl.CUM_MANUFACTURING_LEAD_TIME NOWAIT;

Cursor l_comps_csr (p_org_id number, p_item_id number, p_unit_number varchar2,
      p_eff_date date) is
  SELECT NVL(MTL2.CUMULATIVE_TOTAL_LEAD_TIME, 0) CUMULATIVE_TOTAL_LEAD_TIME,
         NVL(MTL2.CUM_MANUFACTURING_LEAD_TIME, 0) CUM_MANUFACTURING_LEAD_TIME,
         COM.OPERATION_SEQ_NUM
  FROM MTL_SYSTEM_ITEMS         MTL2,
       BOM_INVENTORY_COMPONENTS COM,
       MTL_SYSTEM_ITEMS         MTL1,
       BOM_BILL_OF_MATERIALS    BOM
  WHERE BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
  AND   COM.BILL_SEQUENCE_ID = BOM.COMMON_BILL_SEQUENCE_ID
  AND   BOM.ORGANIZATION_ID = p_org_id
  AND   BOM.ASSEMBLY_ITEM_ID = p_item_id
  AND   MTL1.INVENTORY_ITEM_ID = BOM.ASSEMBLY_ITEM_ID
  AND   MTL1.ORGANIZATION_ID = BOM.ORGANIZATION_ID
  AND   MTL2.INVENTORY_ITEM_ID = COM.COMPONENT_ITEM_ID
  AND   MTL2.ORGANIZATION_ID = BOM.ORGANIZATION_ID
  AND   COM.IMPLEMENTATION_DATE IS NOT NULL
  AND   NVL(COM.ECO_FOR_PRODUCTION,2) = 2
  AND   COM.COMPONENT_QUANTITY > 0
  AND  NOT  (mtl1.replenish_to_order_flag = 'Y'
       AND mtl1.bom_item_type = 4
       AND mtl1.base_item_id IS NOT NULL
       AND MTL2.BOM_ITEM_TYPE IN (1,2))
  AND   (
         COM.DISABLE_DATE IS NULL
         OR
         COM.DISABLE_DATE > p_eff_date
        )
  AND   ((MTL1.EFFECTIVITY_CONTROL <> 1
  AND   p_unit_number is NOT NULL
  AND   COM.DISABLE_DATE IS NULL
  AND   p_unit_number BETWEEN COM.FROM_END_ITEM_UNIT_NUMBER AND
        NVL(COM.TO_END_ITEM_UNIT_NUMBER, p_unit_number))
   OR   (MTL1.EFFECTIVITY_CONTROL = 1
  AND   COM.EFFECTIVITY_DATE <=  p_eff_date));
   Cursor Get_OLTP (P_Assembly number, P_Org_Id number, P_Operation number) is
     Select nvl(bos.operation_lead_time_percent, 0) operation_lead_time_percent
     From Bom_Operation_Sequences bos,
          Bom_Operational_Routings bor
     Where bor.assembly_item_id = P_Assembly
     And   bor.organization_Id = P_Org_Id
     And   bor.alternate_routing_designator is null
     And   bor.common_routing_sequence_id = bos.routing_sequence_id
     And   bos.operation_seq_num = P_Operation
     And   NVL(bos.eco_for_production,2) = 2
  -- Changed for bug 2647027
  /**  And   bos.effectivity_date <= trunc(rev_date)
     And   nvl(bos.disable_date, rev_date + 1) >= trunc(rev_date); **/
     And   bos.effectivity_date <= rev_date
     And   nvl(bos.disable_date, rev_date + 1) >= rev_date;
  l_oltp number := 0; -- operation lead time percent
  l_cmlt number := 0; -- cumulative mfg lead time
  l_ctlt number := 0; -- cumulative total lead time
  l_stmt varchar2(5);
  l_last_updated_by number;		-- BUG 4990802
  l_last_update_login number;		-- BUG 4990802
BEGIN
  l_stmt := '1';
  For l_LevelCode_rec in l_LowLevelCode_csr loop
    l_depth := l_LevelCode_rec.depth;
  End loop;

  For l_level in reverse 0..l_depth loop
    l_stmt := '2';
    For l_assy_rec in l_assy_csr(p_level => l_level) loop
      l_cmlt := 0; -- cumulative mfg lead time
      l_ctlt := 0; -- cumulative total lead time

-- added for Lead time rollup enh to exclude models


      SELECT INCLUDE_MODELS_IN_ROLLUP
          INTO X_include_models
      FROM bom_parameters
      WHERE organization_id = org_id;
     if(X_include_models ='Y' OR
        (l_assy_rec.bom_item_type <>1 AND l_assy_rec.bom_item_type <> 2)) THEN
          X_include_in_rollup :='Y';
     else
          X_include_in_rollup := 'N';
     end if;


      If (l_assy_rec.planning_make_buy_code = 1 AND X_include_in_rollup='Y') then
        l_stmt := '3';
        For l_comps_rec in l_comps_csr (
        p_org_id => org_id,
        p_item_id => l_assy_rec.inventory_item_id,
        p_unit_number => unit_number,
        p_eff_date => rev_date) loop
          l_oltp := 0; -- operation lead time percent
          l_stmt := '4';
          For l_operaton_rec in Get_OLTP (
          P_Assembly => l_assy_rec.inventory_item_id,
          P_Org_Id => org_id,
          P_Operation => l_comps_rec.operation_seq_num) loop
            l_oltp := l_operaton_rec.operation_lead_time_percent;
          End loop;
          l_ctlt := greatest(l_ctlt, l_comps_rec.cumulative_total_lead_time -
            l_oltp/100 * l_assy_rec.full_lead_time);
          l_cmlt := greatest(l_cmlt, l_comps_rec.cum_manufacturing_lead_time -
            l_oltp/100 * l_assy_rec.full_lead_time);
        End loop; -- components
      End if; -- make
      l_stmt := '5';

      l_last_updated_by := NVL(fnd_global.user_id, -1);		-- BUG 4990802
      l_last_update_login := NVL(fnd_global.login_id, -1);	-- BUG 4990802
     /* Modified update statement to include the attributes last_update_date, last_updated_by, last_update_login for BUG 4990802 */
     if (X_include_in_rollup ='Y') then
      Update  mtl_system_items set
	CUMULATIVE_TOTAL_LEAD_TIME = l_assy_rec.total_lead_time + l_ctlt ,
	CUM_MANUFACTURING_LEAD_TIME = l_assy_rec.full_lead_time + l_cmlt ,
	REQUEST_ID = req_id,
        PROGRAM_APPLICATION_ID = prgm_app_id,
        PROGRAM_ID = prgm_id,
	PROGRAM_UPDATE_DATE = SYSDATE,
 	LAST_UPDATE_DATE = SYSDATE,
    	LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_LOGIN = l_last_update_login
       where   ROWID = l_assy_rec.row_id;
      end if; -- include in roll up is 'Y'
    end loop; -- items
    --COMMIT WORK;
  end loop; -- level
  err_msg := null;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Build_Exc_Msg(
      p_pkg_name => 'BOMPCCLT',
      p_procedure_name => 'update_lt('||l_stmt||')');
      err_msg := Fnd_Message.Get_Encoded;
END update_lt;

  /******************************************************************/
  /*#
  * Delete Processed Rows will delete the processed rows within the session
  * under a given rollup id
        * @param p_rollup_id current rollup identifier
        * @rep:scope private
        * @rep:lifecycle active
        * @rep:displayname Delete Processed Rows within a rollup session.
  ********************************************************************/
        PROCEDURE Delete_Processed_Rows
      (p_rollup_id    IN  NUMBER)
        IS
                l_RowsFound BOOLEAN;
        BEGIN
                l_RowsFound := true;
                While l_RowsFound
                LOOP
                        DELETE FROM BOM_LOW_LEVEL_CODES
                        WHERE  ROLLUP_ID = p_rollup_id
                        and rownum <= G_CommitRows;
                        l_RowsFound := sql%found;
                End loop;
                --Commit;
        END Delete_Processed_Rows;

PROCEDURE process_items(
  org_id      IN NUMBER,
  roll_id     IN NUMBER,
  unit_number IN VARCHAR2,
  eff_date    IN DATE,
  prgm_id     IN NUMBER,
  prgm_app_id IN NUMBER,
  req_id      IN NUMBER,
  err_msg     IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

  l_RowsFound boolean := true;
  l_LoopFound boolean := false;
  l_yes constant number := 1;
  l_no  constant number := 2;
  l_err_msg   varchar2(2000) := null;
  l_stmt      varchar2(5);
BEGIN
  l_RowsFound := true;
  While l_RowsFound loop
    l_stmt := '1';
    DELETE FROM BOM_LOW_LEVEL_CODES
    WHERE  ROLLUP_ID = roll_id
    and rownum <= G_CommitRows;
    l_RowsFound := sql%found;
  End loop;
  Commit;

  l_err_msg := null;
  explode_assy(
    org_id        => org_id,
    prgm_id       => prgm_id,
    prgm_app_id   => prgm_app_id,
    req_id        => req_id,
    roll_id       => roll_id,
    unit_number   => unit_number,
    eff_date      => eff_date,
    alternate_bom_code  => null,
    loop_found    => l_LoopFound,
    err_msg       => l_err_msg);

  If l_err_msg is null then
    update_lt(
    org_id      => org_id,
    roll_id     => roll_id,
    prgm_id     => prgm_id,
    prgm_app_id => prgm_app_id,
    req_id      => req_id,
    unit_number      => unit_number,
    rev_date    => eff_date,
    err_msg     => l_err_msg);
  End if;

  l_RowsFound := true;
  While l_RowsFound loop
    l_stmt := '2';
    DELETE FROM BOM_LOW_LEVEL_CODES
    WHERE  ROLLUP_ID = roll_id
    and rownum <= G_CommitRows;
    l_RowsFound := sql%found;
  End loop;
  --Commit;

  If l_LoopFound then
    Fnd_Message.Set_Name('BOM', 'BOM_ONLINE_LOOP');
    Fnd_Message.Set_Token('ENTITY1', l_err_msg);
    err_msg := Fnd_Message.Get_Encoded;
  Else
    err_msg := l_err_msg;
  End if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Build_Exc_Msg(
      p_pkg_name => 'BOMPCCLT',
      p_procedure_name => 'process_items('||l_stmt||')');
      err_msg := Fnd_Message.Get_Encoded;
END process_items;


  PROCEDURE process_items(
    p_org_id                IN NUMBER,
    p_item_id     IN NUMBER,
    p_roll_id               IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
    p_unit_number           IN VARCHAR2,
    p_eff_date              IN DATE,
    p_alternate_bom_code    IN VARCHAR2,
    p_prgm_id               IN NUMBER,
    p_prgm_app_id           IN NUMBER,
    p_req_id                IN NUMBER,
    x_err_msg               IN OUT NOCOPY VARCHAR2)
  IS
    l_loopFound boolean := false;
    l_err_code  number;
  BEGIN
--bom_debug('in process item . . . ' || p_item_id );
    /*
    explode_assy( org_id        => org_id
               ,prgm_id       => prgm_id
               ,prgm_app_id   => prgm_app_id
               ,req_id        => req_id
               ,roll_id       => roll_id
               ,unit_number   => unit_number
               ,eff_date      => eff_date
           ,alternate_bom_code=> alternate_bom_code
               ,loop_found    => l_LoopFound
               ,err_msg       => err_msg);

    */
    bom_exploder_pub.exploder_userexit(
            org_id                  => p_org_id,
            alt_desg                => p_alternate_bom_code,
            pk_value1               => p_item_id,
            pk_value2               => p_org_id,
            order_by                => 1,
            grp_id                  => p_roll_id,
            levels_to_explode       => 60,
            impl_flag               => 2,
            expl_qty                => 1,
            p_autonomous_transaction => 2,
            err_msg                 => x_err_msg,
            error_code              => l_err_code);
--bom_debug('out of process item . . . ');

  END process_items;

END BOMPCCLT;

/
