--------------------------------------------------------
--  DDL for Package Body CSTPSCEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPSCEX" as
/* $Header: CSTSCEXB.pls 120.12.12010000.5 2010/04/11 19:54:11 smsasidh ship $ */


-- This is the low level code for the bottom most component in an explosion
LOWEST_LEVEL_CODE CONSTANT NUMBER(15) := 0;



procedure insert_assembly_items (
  i_rollup_id         in  number,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2
)
is
  l_stmt_num NUMBER(15);
begin


  /* OPM INVCONV umoogala 17-oct-2004
  ** Delete process org/item combinations, if any
  */
  l_stmt_num := 5;

  delete cst_sc_lists csl
   where exists (select 'process org'
                   from mtl_parameters mp
                  where mp.organization_id = csl.organization_id
                    and NVL(mp.process_enabled_flag, 'N') = 'Y')
  ;
  /* End OPM INVCONV change */

  l_stmt_num := 10;

  insert into cst_sc_bom_explosion
  (
    ROLLUP_ID,
    ASSEMBLY_ITEM_ID,
    ASSEMBLY_ORGANIZATION_ID,
    COMPONENT_SEQUENCE_ID,
    COMPONENT_ITEM_ID,
    COMPONENT_ORGANIZATION_ID,
    COMPONENT_QUANTITY,
    DELETED_FLAG,
    EXPLODED_FLAG,
    PLAN_LEVEL,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE
  )
  select
    i_rollup_id,                 -- ROLLUP_ID
    -1,                          -- ASSEMBLY_ITEM_ID
    -1,                          -- ASSEMBLY_ORGANIZATION_ID
    null,                        -- COMPONENT_SEQUENCE_ID
    CSL.inventory_item_id,       -- COMPONENT_ITEM_ID
    CSL.organization_id,         -- COMPONENT_ORGANIZATION_ID
    1,                           -- COMPONENT_QUANTITY
    'N',                         -- DELETED_FLAG
    'N',                         -- EXPLODED_FLAG
    1,                           -- PLAN_LEVEL
    sysdate,                     -- LAST_UPDATE_DATE
    i_user_id,                   -- LAST_UPDATED_BY
    i_login_id,                  -- LAST_UPDATE_LOGIN
    sysdate,                     -- CREATION_DATE
    i_user_id,                   -- CREATED_BY
    i_request_id,                -- REQUEST_ID
    i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
    i_prog_id,                   -- PROGRAM_ID
    sysdate                      -- PROGRAM_UPDATE_DATE
  from
    cst_sc_lists CSL
  where
    CSL.rollup_id = i_rollup_id;


exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.insert_assembly_items():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end insert_assembly_items;



procedure snapshot_sc_sourcing_rules (
  i_rollup_id         in  number,
  i_assignment_set_id in  number,
  i_inventory_item_id in  number,
  i_organization_id   in  number,
  i_effective_date    in  date,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2
) is

  l_stmt_num             number(15);
  l_sourcing_rules_count number(15);

  l_min_rank             number(15);

  /* OPM INVCONV umoogala 17-oct-2004 */
  l_sourcing_rule_name mrp_sourcing_rules.sourcing_rule_name%TYPE;
  l_organization_code  mtl_parameters.organization_code%TYPE;

begin
  o_error_code := 0;
  o_error_msg := null;


  if i_assignment_set_id is null then
    return;
  end if;

  -- SCAPI: use minimum sourcing rule rank
  l_stmt_num := 15;

  select min(MSV.rank)
  into   l_min_rank
  from   mrp_sources_v MSV
  where
    MSV.assignment_set_id  = i_assignment_set_id and
    MSV.inventory_item_id  = i_inventory_item_id and
    MSV.organization_id    = i_organization_id   and
    MSV.allocation_percent is not null           and
    MSV.source_type        is not null           and
    MSV.effective_date <= i_effective_date and
    nvl( MSV.disable_date, i_effective_date + 1 ) > i_effective_date;

  --
  -- stmt_num 20
  --   Take snapshot from MRP_SOURCES_V, all rows except for
  --   same org rows.  Those will be inserted in the next
  --   SQL statement using the percentage left of the 100%.
  --   Note:
  --     source_type codes:
  --     After this function executes, the possible values
  --     for source_type are:
  --     1: Transfer From.  It is guarenteed that
  --          source_organization_id <> organization_id.
  --     2: Make At.   It is guarenteed that
  --          source_organization_id = organization_id.
  --     3: Buy From.  It is gurenteed that
  --          source_organization_id is null and
  --          vendor_id is not null.
  l_stmt_num := 20;

  insert into CST_SC_SOURCING_RULES
  (
    ROLLUP_ID,
    ASSIGNMENT_SET_ID,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    SOURCE_ORGANIZATION_ID,
    VENDOR_ID,
    VENDOR_SITE_ID,
    SOURCE_TYPE,
    SHIP_METHOD,
    ALLOCATION_PERCENT,
    MARKUP_CODE,
    MARKUP,
    ITEM_COST,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    SOURCING_RULE_NAME
  )
  select
    i_rollup_id,                         -- ROLLUP_ID
    MSV.assignment_set_id,               -- ASSIGNMENT_SET_ID
    MSV.inventory_item_id,               -- INVENTORY_ITEM_ID
    MSV.organization_id,                 -- ORGANIZATION_ID
    MSV.source_organization_id,          -- SOURCE_ORGANIZATION_ID
    MSV.vendor_id,                       -- VENDOR_ID
    MSV.vendor_site_id,                  -- VENDOR_SITE_ID
    MSV.source_type,                     -- SOURCE_TYPE
    MSV.ship_method,                     -- SHIP_METHOD
    MSV.allocation_percent,              -- ALLOCATION_PERCENT
    null,                                -- MARKUP_CODE
    null,                                -- MARKUP
    null,                                -- ITEM_COST
    sysdate,                             -- LAST_UPDATE_DATE
    i_user_id,                           -- LAST_UPDATED_BY
    i_login_id,                          -- LAST_UPDATE_LOGIN
    sysdate,                             -- CREATION_DATE
    i_user_id,                           -- CREATED_BY
    i_request_id,                        -- REQUEST_ID
    i_prog_appl_id,                      -- PROGRAM_APPLICATION_ID
    i_prog_id,                           -- PROGRAM_ID
    sysdate,                             -- PROGRAM_UPDATE_DATE
    msv.sourcing_rule_name
  from
    mrp_sources_v MSV
  where
    MSV.assignment_set_id  = i_assignment_set_id and
    MSV.inventory_item_id  = i_inventory_item_id and
    MSV.organization_id    = i_organization_id   and
    MSV.rank               = l_min_rank          and  -- SCAPI: use minimum rank
    MSV.allocation_percent is not null           and
    MSV.source_type        is not null           and
    MSV.effective_date <= i_effective_date and
    nvl( MSV.disable_date, i_effective_date + 1 ) > i_effective_date
    and exists (select 1
                from mtl_system_items msi
                where msi.inventory_item_id = i_inventory_item_id
                and   msi.organization_id   = nvl(MSV.source_organization_id,msi.organization_id));


  /* OPM INVCONV umoogala 17-oct-2004
  ** Exit the program if there are any sourcing rules which
  ** contains process org as sourcing org.
  */
  BEGIN
    l_stmt_num := 30;

    select cssr.sourcing_rule_name, mp.organization_code
      into l_sourcing_rule_name, l_organization_code
      from cst_sc_sourcing_rules cssr, mtl_parameters mp
     where rollup_id              = i_rollup_id
       and cssr.inventory_item_id = i_inventory_item_id
       and cssr.organization_id   = i_organization_id
       and cssr.assignment_set_id = i_assignment_set_id
       and mp.organization_id     = cssr.source_organization_id
       and NVL(mp.process_enabled_flag, 'N') = 'Y'
    ;

    FND_MESSAGE.set_name( 'GMF', 'GMF_SCR_PROCESS_ORG_ERROR' );
    FND_MESSAGE.set_token( 'SOURCING_RULE_NAME', l_sourcing_rule_name );
    FND_MESSAGE.set_token( 'PROCESS_ORG', l_organization_code );
    o_error_code := -1;
    o_error_msg  := FND_MESSAGE.get;
    RETURN;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
    NULL;
   /* when others will be handled by the main exception below */
  END;
  /* End INVCONV change */

exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.snapshot_sc_sourcing_rules():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);
end snapshot_sc_sourcing_rules;





procedure snapshot_sc_conversion_rates (
  i_rollup_id         in  number,
  i_conversion_type   in  varchar2,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2
)
is
  l_stmt_num NUMBER(15);

  cursor rates_cur is
select distinct
      CSSR.source_organization_id,
      SOB_FROM.currency_code from_currency,
      CSSR.organization_id,
      SOB_TO.currency_code to_currency
from
      cst_sc_sourcing_rules        CSSR,
      hr_organization_information  OOD_FROM,
      gl_sets_of_books             SOB_FROM,
      hr_organization_information  OOD_TO,
      gl_sets_of_books             SOB_TO
where
      CSSR.rollup_id              = i_rollup_id and
      CSSR.source_organization_id is not null   and
      CSSR.organization_id        is not null   and
      OOD_FROM.organization_id = CSSR.source_organization_id AND
      OOD_FROM.org_information_context = 'Accounting Information' AND
      SOB_FROM.set_of_books_id = OOD_FROM.org_information1    and
      OOD_TO.organization_id   = CSSR.organization_id        AND
      OOD_TO.org_information_context = 'Accounting Information' AND
      SOB_TO.set_of_books_id   = OOD_TO.org_information1;


begin


  FOR rate IN rates_cur LOOP

    BEGIN
      l_stmt_num := 10;

      update cst_sc_sourcing_rules CSSR
      set
        CSSR.conversion_type = i_conversion_type,
        CSSR.conversion_rate =
          gl_currency_api.get_rate
          (
            rate.from_currency,
            rate.to_currency,
            sysdate,
            i_conversion_type
          )
      where
        CSSR.rollup_id              = i_rollup_id                      and
        CSSR.organization_id        = rate.organization_id        and
        CSSR.source_organization_id = rate.source_organization_id;


    exception
      when OTHERS then
        FND_MESSAGE.SET_NAME( 'SQLGL', 'MRC_RATE_NOT_FOUND' );
        FND_MESSAGE.SET_TOKEN( 'MODULE', null );
        FND_MESSAGE.SET_TOKEN( 'FROM', rate.from_currency );
        FND_MESSAGE.SET_TOKEN( 'TO', rate.to_currency );
        FND_MESSAGE.SET_TOKEN( 'TRANS_DATE',
                               FND_DATE.DATE_TO_CHARDATE( sysdate ) );
        FND_MESSAGE.SET_TOKEN( 'TYPE', i_conversion_type );
        APP_EXCEPTION.RAISE_EXCEPTION;
        RETURN;

    END;
  END LOOP;

exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.snapshot_sc_conversion_rates():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);
end snapshot_sc_conversion_rates;




procedure explode_sc_bom (
  i_rollup_id         in  number,
  i_explosion_levels  in  number,
  i_assignment_set_id in  number,
  i_effective_date    in  date,
  i_inc_unimpl_ecn    in  number,  -- 1 = Include Unimplemented, 2 = No
  i_inc_eng_bill      in  number,  -- 1 = Include Engineering Bills, 2 = No
  i_alt_bom_desg      in  varchar2,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2
)
is

  cursor CSBE_cursor is
  select /*+ INDEX (CSBE CST_SC_BOM_EXPLOSION_N1)*/
    CSBE.component_item_id,
    CSBE.component_organization_id,
    min( CSBE.plan_level ) prior_plan_level
  from
    cst_sc_bom_explosion CSBE
  where
    CSBE.rollup_id     = i_rollup_id  and
    CSBE.exploded_flag = 'N'          and
    CSBE.plan_level    <= decode( i_explosion_levels, null, CSBE.plan_level+1,
                                  i_explosion_levels ) and
    not exists
    (
      select /*+ INDEX (CSBE2 CST_SC_BOM_EXPLOSION_N1)*/ 'x'
      from   cst_sc_bom_explosion CSBE2
      where
        CSBE2.rollup_id                 =  CSBE.rollup_id                 and
        CSBE2.component_item_id         =  CSBE.component_item_id         and
        CSBE2.component_organization_id =  CSBE.component_organization_id and
        CSBE2.exploded_flag             <> 'N'
    )
  group by
    CSBE.component_item_id,
    CSBE.component_organization_id;


  l_rows_processed NUMBER(15);
  l_stmt_num       NUMBER(15);
  l_active_flag    NUMBER(2) ; /* Added for bug 4547027 */

begin

  loop
    l_rows_processed := 0;


    l_stmt_num := 10;

    for CSBE in CSBE_cursor loop

      if i_assignment_set_id is not null then

      /* Added for Bug 6124274 */
      BEGIN
      /* Added for bug 4547027 */
      select decode(nvl(msi.inventory_item_status_code,'NOT'||bp.bom_delete_status_code),
                   nvl(bp.bom_delete_status_code,' '),2,1)
      into l_active_flag
      from mtl_system_items msi,
           bom_parameters bp
      where msi.inventory_item_id = CSBE.component_item_id
      and   msi.organization_id   = CSBE.component_organization_id
      and   bp.organization_id (+) = msi.organization_id;
      /*Added exception to avoid the request erroring due to incorrect sourcing rule set*/
      EXCEPTION
         WHEN OTHERS THEN
             l_active_flag := 2;
             fnd_file.put_line(FND_FILE.LOG, 'Missing Source Org/item in MSI..     Item:= ' || CSBE.component_item_id || '   Org: ' || CSBE.component_organization_id);
      END;


      if l_active_flag = 1 then

        l_stmt_num := 20;
        CSTPSCEX.snapshot_sc_sourcing_rules
        (
          i_rollup_id,
          i_assignment_set_id,
          CSBE.component_item_id,
          CSBE.component_organization_id,
          i_effective_date,
          i_user_id,
          i_login_id,
          i_request_id,
          i_prog_id,
          i_prog_appl_id,
          o_error_code,
          o_error_msg
        );

        if o_error_code <> 0 then
          return;
        end if;
       end if; -- l_active_flag
      end if; -- i_assignment_set_id is not null


      l_stmt_num := 30;
      insert into cst_sc_bom_explosion
      (
        ROLLUP_ID,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORGANIZATION_ID,
        OPERATION_SEQ_NUM,
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        COMPONENT_ORGANIZATION_ID,
        COMPONENT_QUANTITY,
        DELETED_FLAG,
        EXPLODED_FLAG,
        PLAN_LEVEL,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
      )
      select
        i_rollup_id,                 -- ROLLUP_ID
        CSSR.inventory_item_id,      -- ASSEMBLY_ITEM_ID
        CSSR.organization_id,        -- ASSEMBLY_ORGANIZATION_ID
        to_number( null ),           -- OPERATION_SEQ_NUM
        to_number( null ),           -- COMPONENT_SEQUENCE_ID
        CSSR.inventory_item_id,      -- COMPONENT_ITEM_ID
        CSSR.source_organization_id, -- COMPONENT_ORGANIZATION_ID
        CSSR.allocation_percent / 100, -- COMPONENT_QUANTITY
        'N',                         -- DELETED_FLAG
        'N',                         -- EXPLODED_FLAG
        CSBE.prior_plan_level + 1,   -- PLAN_LEVEL
        sysdate,                     -- LAST_UPDATE_DATE
        i_user_id,                   -- LAST_UPDATED_BY
        i_login_id,                  -- LAST_UPDATE_LOGIN
        sysdate,                     -- CREATION_DATE
        i_user_id,                   -- CREATED_BY
        i_request_id,                -- REQUEST_ID
        i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
        i_prog_id,                   -- PROGRAM_ID
        sysdate                      -- PROGRAM_UPDATE_DATE
      from
        cst_sc_sourcing_rules CSSR, mtl_system_items msi /* Bug 6124274 */
      where
        CSSR.rollup_id         = i_rollup_id                    and
        msi.inventory_item_id  = cssr.inventory_item_id         and
        msi.organization_id    = cssr.organization_id           and
        CSSR.inventory_item_id = CSBE.component_item_id         and
        CSSR.organization_id   = CSBE.component_organization_id and
        CSSR.source_type       = 1   -- Transfer items only


      -- all we need is a UNION ALL, but I'm using UNION to
      -- force an implicit sort so that the resulting connect by
      -- select will (usually) be sorted by op_seq_num
      union

      select
        i_rollup_id,                 -- ROLLUP_ID
        BOM.assembly_item_id,        -- ASSEMBLY_ITEM_ID
        BOM.organization_id,         -- ASSEMBLY_ORGANIZATION_ID
        BIC.operation_seq_num,       -- OPERATION_SEQ_NUM
        BIC.component_sequence_id,   -- COMPONENT_SEQUENCE_ID
        BIC.component_item_id,       -- COMPONENT_ITEM_ID
        BOM.organization_id,         -- COMPONENT_ORGANIZATION_ID
        BIC.component_quantity,      -- COMPONENT_QUANTITY
        'N',                         -- DELETED_FLAG
        'N',                         -- EXPLODED_FLAG
        CSBE.prior_plan_level + 1,   -- PLAN_LEVEL
        sysdate,                     -- LAST_UPDATE_DATE
        i_user_id,                   -- LAST_UPDATED_BY
        i_login_id,                  -- LAST_UPDATE_LOGIN
        sysdate,                     -- CREATION_DATE
        i_user_id,                   -- CREATED_BY
        i_request_id,                -- REQUEST_ID
        i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
        i_prog_id,                   -- PROGRAM_ID
        sysdate                      -- PROGRAM_UPDATE_DATE
      from
        bom_bill_of_materials BOM,
        bom_inventory_components BIC
      where
        BOM.common_bill_sequence_id = BIC.bill_sequence_id           and
        BOM.assembly_item_id        = CSBE.component_item_id         and
        BOM.organization_id         = CSBE.component_organization_id and
        ----------------------------
        --- effectivity checking
        ----------------------------
        BIC.effectivity_date <= i_effective_date and
        nvl( BIC.disable_date, i_effective_date + 1 ) > i_effective_date and
        ----------------------------
        --- alternate bom designator
        ----------------------------
        BOM.assembly_type =
          decode( i_inc_eng_bill, 1, BOM.assembly_type, 1 ) AND
        (
          (
            i_alt_bom_desg IS NULL AND
            BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
          )
          OR
          (
            i_alt_bom_desg IS NOT NULL AND
            BOM.ALTERNATE_BOM_DESIGNATOR = i_alt_bom_desg
          )
          OR
          ( i_alt_bom_desg IS NOT NULL AND
            BOM.ALTERNATE_BOM_DESIGNATOR IS NULL AND
            NOT EXISTS
            (
              SELECT 'X'
              FROM   BOM_BILL_OF_MATERIALS BOM2
              WHERE  BOM2.ORGANIZATION_ID          = BOM.ORGANIZATION_ID  AND
                     BOM2.ASSEMBLY_ITEM_ID         = BOM.ASSEMBLY_ITEM_ID AND
                     BOM2.ALTERNATE_BOM_DESIGNATOR = i_alt_bom_desg       AND
                     BOM2.assembly_type =
                       decode( i_inc_eng_bill, 1, BOM2.assembly_type, 1 )
            )
          )
        ) AND
        ( BOM.ALTERNATE_BOM_DESIGNATOR IS NULL
          OR
          BOM.ALTERNATE_BOM_DESIGNATOR = i_alt_bom_desg
        ) AND
        ----------------------------
        --- implementation option
        ----------------------------
        (
          (
            i_inc_unimpl_ecn = 2 AND
            BIC.IMPLEMENTATION_DATE IS NOT NULL
          )
          OR
          (
            i_inc_unimpl_ecn = 1 AND
            BIC.EFFECTIVITY_DATE =
            (
              SELECT MAX(EFFECTIVITY_DATE)
              FROM   BOM_INVENTORY_COMPONENTS BIC2
              WHERE
                BIC2.BILL_SEQUENCE_ID  = BIC.BILL_SEQUENCE_ID  AND
                BIC2.COMPONENT_ITEM_ID = BIC.COMPONENT_ITEM_ID AND
                (
                  decode( BIC2.IMPLEMENTATION_DATE,
                          NULL, BIC2.OLD_COMPONENT_SEQUENCE_ID,
                                BIC2.COMPONENT_SEQUENCE_ID ) =
                  decode( BIC.IMPLEMENTATION_DATE,
                          NULL, BIC.OLD_COMPONENT_SEQUENCE_ID,
                                BIC.COMPONENT_SEQUENCE_ID )
                  OR
                  BIC2.OPERATION_SEQ_NUM = BIC.OPERATION_SEQ_NUM
                )
                AND
                BIC2.EFFECTIVITY_DATE <= i_effective_date
                AND
                NVL( BIC2.eco_for_production, 2 ) = 2
            ) -- end of subquery
          )
        ) AND
        ----------------------------------------------------
        -- This should take care of excluding model and oc
        ----------------------------------------------------
        BIC.INCLUDE_IN_COST_ROLLUP = 1 and
        ----------------------------------------------------
        -- This is for ECO changes in 11i.4
        ----------------------------------------------------
        NVL( BIC.eco_for_production, 2 ) = 2 and

        /* Fix for BUG 1604207 */
        NVL( bic.acd_type, 1 ) <> 3 and

        ----------------------------------------------------
        -- only insert BOM if there is a Make rule
        ----------------------------------------------------
        0 < (
           select nvl( sum( decode( CSSR.source_type, 2,
                                    CSSR.allocation_percent, 0 ) ), 100 )
           from   cst_sc_sourcing_rules CSSR
           where
             CSSR.rollup_id         = i_rollup_id                    and
             CSSR.inventory_item_id = CSBE.component_item_id         and
             CSSR.organization_id   = CSBE.component_organization_id
        );



      l_stmt_num := 40;

      update cst_sc_bom_explosion
      set    exploded_flag = 'Y'
      where  rollup_id = i_rollup_id and
             component_item_id         = CSBE.component_item_id and
             component_organization_id = CSBE.component_organization_id;

      l_rows_processed := l_rows_processed + 1;
    end loop;

    exit when l_rows_processed = 0;
  end loop;



  -- This will scale down the component_quantity of components of
  -- assemblies that have partial Make sourcing rules.
  update cst_sc_bom_explosion CSBE
  set    CSBE.component_quantity
  =      (
           select CSBE.component_quantity *
                  nvl( sum( decode( CSSR.source_type, 2,
                                    CSSR.allocation_percent, 0 ) ) / 100, 1 )
           from   cst_sc_sourcing_rules CSSR
           where  CSSR.rollup_id         = CSBE.rollup_id                and
                  CSSR.inventory_item_id = CSBE.assembly_item_id         and
                  CSSR.organization_id   = CSBE.assembly_organization_id
         )
  where  CSBE.rollup_id                = i_rollup_id and
         CSBE.assembly_organization_id = component_organization_id;



  -- This will clear out all exploded rows, essentially the rows
  -- that are stuck in a loop.
  update /*+ INDEX (CSBE CST_SC_BOM_EXPLOSION_N1)*/
  cst_sc_bom_explosion CSBE
  set    exploded_flag = 'Y'
  where
    rollup_id = i_rollup_id and
    exploded_flag = 'N' and
    exists (
      select /*+ INDEX (CSBE2 CST_SC_BOM_EXPLOSION_N1)*/ 'x'
      from   cst_sc_bom_explosion CSBE2
      where
        CSBE2.rollup_id                 = CSBE.rollup_id                 and
        CSBE2.component_item_id         = CSBE.component_item_id         and
        CSBE2.component_organization_id = CSBE.component_organization_id and
        CSBE2.exploded_flag = 'Y'
    );


exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.explode_sc_bom():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end explode_sc_bom;






procedure explode_sc_cost_flags (
  i_rollup_id         in  number,
  i_cost_type_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2
)
is
  cursor assm_cursor is
  select
    CSBS.rowid,
    decode( CIC.inventory_asset_flag, 2, 2,
      decode( CIC.based_on_rollup_flag, 2, 2, 1 ) ) new_ext_cost_flag
  from
    cst_sc_bom_structures    CSBS,
    cst_item_costs           CIC
  where
    CSBS.rollup_id                = i_rollup_id                    and
    CSBS.assembly_item_id         = -1                             and
    CIC.inventory_item_id         = CSBS.component_item_id         and
    CIC.organization_id           = CSBS.component_organization_id and
    CIC.cost_type_id              = i_cost_type_id;


  /* the outer join to CIC is necessary because we're joining
     to the assembly, and assembly_id can be -1 */


  -- Note that this join to CSSR depends on the fact that
  -- there can be at most one Make At sourcing rule for an item.
  -- This is currently being enforced by the MRP forms.

  -- Added planning factor for bug 2947036
  /* Bug 4547027 Changed the cursor to get active_flag for the component */
  cursor component_cursor is
    select
    CSBS.top_inventory_item_id top_inventory_item_id,
    CSBS.top_organization_id top_organization_id,
    CSBS.sort_order sort_order,
    CSBS.rowid,
    CSBS.bom_level,
    BIC.basis_type,
    /* LBM Project 3926918: Changes made to support Lot Based Materials. Added decode to check for basis type
       of the component. If lot based then component qty becomes compt_qty/lot_size else it is unchanged. */
    CSBS.component_quantity,
    BIC.include_in_cost_rollup include_in_cost_rollup,
    nvl(BIC.component_yield_factor, 1) component_yield_factor,
    nvl(BIC.planning_factor/100, 1) component_planning_factor,
    nvl(CIC.inventory_asset_flag,2) inventory_asset_flag,
    nvl(CIC.based_on_rollup_flag,2) based_on_rollup_flag, -- added NVL for bug 4377129
    decode(bp.use_phantom_routings, 1, decode(nvl(BIC.wip_supply_type, nvl( MSI.wip_supply_type, 1)), 6, 1, 2), 2) phantom_flag,
    decode(nvl(msi.inventory_item_status_code,'NOT'||bp.bom_delete_status_code),nvl(bp.bom_delete_status_code,' '), 2, 1) active_flag,
    0 shrinkage_rate,
    decode(CIC.lot_size, 0, 1, NULL, 1, CIC.lot_size) lot_size
  from
    cst_sc_bom_structures    CSBS,
    cst_item_costs           CIC,
    mtl_system_items         MSI,
    bom_inventory_components BIC,
    bom_parameters           bp   /* Bug 4547027 */
  where
    CSBS.rollup_id                = i_rollup_id                    and
    CSBS.assembly_item_id  = -1 and
    CIC.inventory_item_id (+)     = CSBS.top_inventory_item_id and
    CIC.organization_id (+)       = CSBS.top_organization_id and
    CIC.cost_type_id (+)          = i_cost_type_id                 and
    MSI.inventory_item_id         = CSBS.component_item_id         and
    MSI.organization_id           = CSBS.component_organization_id and
    bp.organization_id (+)        = CSBS.component_organization_id and  /* Bug 4547027 */
    BIC.component_sequence_id (+) = CSBS.component_sequence_id
  UNION ALL
    select
    CSBS.top_inventory_item_id top_inventory_item_id,
    CSBS.top_organization_id top_organization_id,
    CSBS.sort_order sort_order,
    CSBS.rowid,
    CSBS.bom_level,
    BIC.basis_type,
    /* LBM Project 3926918: Changes made to support Lot Based Materials. Added decode to check for basis type
       of the component. If lot based then component qty becomes compt_qty/lot_size else it is unchanged. */
    CSBS.component_quantity,
    BIC.include_in_cost_rollup include_in_cost_rollup,
    nvl(BIC.component_yield_factor, 1) component_yield_factor,
    nvl(BIC.planning_factor/100, 1) component_planning_factor,
    nvl(CIC.inventory_asset_flag,2) inventory_asset_flag,
    nvl(CIC.based_on_rollup_flag,2) based_on_rollup_flag, -- added NVL for bug 4377129
    decode(bp.use_phantom_routings, 1, decode(nvl(BIC.wip_supply_type, nvl( MSI.wip_supply_type, 1)), 6, 1, 2), 2) phantom_flag,
    decode(nvl(msi.inventory_item_status_code,'NOT'||bp.bom_delete_status_code),nvl(bp.bom_delete_status_code,' '), 2, 1) active_flag,
    decode(CSBS.assembly_organization_id, CSBS.component_organization_id, nvl(CIC.shrinkage_rate, 0), 0) shrinkage_rate,
    decode(CIC.lot_size, 0, 1, NULL, 1, CIC.lot_size) lot_size
  from
    cst_sc_bom_structures    CSBS,
    cst_item_costs           CIC,
    mtl_system_items         MSI,
    bom_inventory_components BIC,
    bom_parameters           bp   /* Bug 4547027 */
  where
    CSBS.rollup_id                = i_rollup_id                    and
    CSBS.assembly_item_id         <> -1                            and
    CIC.inventory_item_id (+)     = CSBS.assembly_item_id          and
    CIC.organization_id (+)       = CSBS.assembly_organization_id  and
    CIC.cost_type_id (+)          = i_cost_type_id                 and
    MSI.inventory_item_id         = CSBS.component_item_id         and
    MSI.organization_id           = CSBS.component_organization_id and
    bp.organization_id (+)        = CSBS.component_organization_id and  /* Bug 4547027 */
    BIC.component_sequence_id (+) = CSBS.component_sequence_id
    order by
    top_inventory_item_id,
    top_organization_id,
    sort_order;

  TYPE STACK_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  ext_qty_stack STACK_TYPE;

  ext_cost_flag_stack STACK_TYPE;

  phtm_factor_stack STACK_TYPE;

  l_stmt_num number(15);

  l_comp_yield_flag number(15);

begin

  -- top level extended_quantity is always 1
  ext_qty_stack(0) := 1;

  ext_cost_flag_stack(0) := 1;

  phtm_factor_stack(0) := 1;

 /* Get component_yield_fla: Bug 2297027 */

  select component_yield_flag
  into l_comp_yield_flag
  from cst_cost_types
  where cost_type_id = i_cost_type_id;

  -- set up the top level extend_cost_flag
  l_stmt_num := 10;

  FOR assm in assm_cursor LOOP
    update cst_sc_bom_structures CSBS
    set CSBS.extend_cost_flag = assm.new_ext_cost_flag
    where CSBS.rowid = assm.rowid;
  END LOOP;

  FOR comp in component_cursor LOOP

    l_stmt_num := 15;
    /*  Bug 4547027 Added extra check so that the cost of the components
        of inactive assemblies is not shown in the report */
    IF ext_cost_flag_stack(comp.bom_level - 1) = 2 OR
          comp.inventory_asset_flag = 2 OR comp.based_on_rollup_flag = 2 OR
          comp.active_flag = 2 OR nvl(comp.include_in_cost_rollup, 1) = 2 THEN
       ext_cost_flag_stack(comp.bom_level) := 2;
    ELSE
       ext_cost_flag_stack(comp.bom_level) := 1;
    END IF;

    /* Only active components are considered */
    IF ext_cost_flag_stack(comp.bom_level) = 1 THEN

       /* Added for bug#7418952 to include shrinakge rate from the previous levels into consideration */
       l_stmt_num := 20;
       ext_qty_stack(comp.bom_level) := ext_qty_stack(comp.bom_level - 1) *
                 comp.component_quantity * comp.component_planning_factor / (1-comp.shrinkage_rate);

       l_stmt_num := 25;
       /* Consider component_yield_factor and planning_factor in Extended Quantity
          Bug 2297027 and Bug 2947036 */
       IF l_comp_yield_flag = 1 THEN
          ext_qty_stack(comp.bom_level) := ext_qty_stack(comp.bom_level) / comp.component_yield_factor;
       END IF;

       l_stmt_num := 30;
       /* Added this stmt to set the proper extended quantity in case if components are lot based LBM Project. In this case we
          have to consider the lot size of the assembly, while calculating the extended quantity of the component */
       IF comp.basis_type = 2 THEN
          ext_qty_stack(comp.bom_level) := ext_qty_stack(comp.bom_level) / comp.lot_size;
       END IF;

       l_stmt_num := 35;
       /* If a sub-assembly is phantom it cannot be a Lot Based Material from Bills Of Materials Forms
          A phantom will not include the component lot size and component quantity and only considers
          assembly lot size for calculation. The assembly cost will be calculated same, irrespective of
          whether it is a phantom or not. The difference happens in the way the component phantom costs
          goes into assembly.
          The new phantom factor column is used to display phantom material correctly */
       l_stmt_num := 40;
       IF comp.phantom_flag = 1 THEN
          select cic.lot_size / (comp.lot_size * comp.component_quantity)
          into phtm_factor_stack(comp.bom_level)
          from cst_item_costs cic,
               cst_sc_bom_structures csbs
          where csbs.rowid = comp.rowid
            and CIC.inventory_item_id (+) = CSBS.component_item_id
            and CIC.organization_id (+)   = CSBS.component_organization_id
            and CIC.cost_type_id (+)      = i_cost_type_id;
       ELSE
          phtm_factor_stack(comp.bom_level) := 1;
       END IF;

    ELSE -- ext_cost_flag_stack(comp.bom_level) = 2
       ext_qty_stack(comp.bom_level) := 1;
       phtm_factor_stack(comp.bom_level) := 1;
    END IF;

    l_stmt_num := 50;

    update    cst_sc_bom_structures CSBS
    set
      CSBS.component_quantity     = comp.component_quantity,
      CSBS.extended_quantity      = ext_qty_stack(comp.bom_level),
      CSBS.include_in_cost_rollup = comp.include_in_cost_rollup,
      CSBS.extend_cost_flag       = ext_cost_flag_stack(comp.bom_level),
      CSBS.phantom_flag           = comp.phantom_flag,
      CSBS.phantom_factor         = phtm_factor_stack(comp.bom_level)
    where     CSBS.rowid = comp.rowid;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.explode_sc_cost_flags():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end explode_sc_cost_flags;





procedure snapshot_sc_bom_structures (
  i_rollup_id         in  number,
  i_cost_type_id      in  number,
  i_report_levels     in  number,
  i_effective_date    in  date,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2,
  i_report_type_type  in  number
)
is
  cursor top_assembly_cursor is
  select
    CSBE.component_item_id,
    CSBE.component_organization_id
  from
    cst_sc_bom_explosion CSBE
  where
    CSBE.rollup_id        = i_rollup_id and
    CSBE.assembly_item_id = -1 and
    CSBE.deleted_flag = 'Y'; -- Bug 3665428: make snapshot only for valid items without loop




  l_err_code NUMBER(15);
  l_err_mesg VARCHAR2(100);

  l_bom_level number(15);

  l_stmt_num number(15);

begin

  IF i_report_levels IS NULL THEN
    return;
  END IF;


  -- SCAPI: delete previous data;
  delete cst_sc_bom_structures
  where  rollup_id in (i_rollup_id, -1*i_rollup_id);


  l_stmt_num := 10;
  FOR top_assm in top_assembly_cursor LOOP
    BEGIN

      l_stmt_num := 20;

      insert into cst_sc_bom_structures
      (
        ROLLUP_ID,
        TOP_INVENTORY_ITEM_ID,
        TOP_ORGANIZATION_ID,
        SORT_ORDER,
        BOM_LEVEL,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORGANIZATION_ID,
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        COMPONENT_ORGANIZATION_ID,
        COMPONENT_QUANTITY,
        EXTENDED_QUANTITY,
        INCLUDE_IN_COST_ROLLUP,
        EXTEND_COST_FLAG,
        PHANTOM_FLAG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
      )
      select
        i_rollup_id,                        -- ROLLUP_ID
        top_assm.component_item_id,         -- TOP_INVENTORY_ITEM_ID
        top_assm.component_organization_id, -- TOP_ORGANIZATION_ID
        rownum,                             -- SORT_ORDER
        level,                              -- BOM_LEVEL
        CSBE.assembly_item_id,              -- ASSEMBLY_ITEM_ID
        CSBE.assembly_organization_id,      -- ASSEMBLY_ORGANIZATION_ID
        CSBE.component_sequence_id,         -- COMPONENT_SEQUENCE_ID
        CSBE.component_item_id,             -- COMPONENT_ITEM_ID
        CSBE.component_organization_id,     -- COMPONENT_ORGANIZATION_ID
        CSBE.component_quantity,            -- COMPONENT_QUANTITY
        1,                                  -- EXTENDED_QUANTITY
        1,                                  -- INCLUDE_IN_COST_ROLLUP
        1,                                  -- EXTEND_COST_FLAG
        2,                                  -- PHANTOM_FLAG
        sysdate,                     -- LAST_UPDATE_DATE
        i_user_id,                   -- LAST_UPDATED_BY
        i_login_id,                  -- LAST_UPDATE_LOGIN
        sysdate,                     -- CREATION_DATE
        i_user_id,                   -- CREATED_BY
        i_request_id,                -- REQUEST_ID
        i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
        i_prog_id,                   -- PROGRAM_ID
        sysdate                      -- PROGRAM_UPDATE_DATE
      from
        cst_sc_bom_explosion CSBE
      start with
        rollup_id                 = i_rollup_id                        and
        assembly_item_id          = -1                                 and
        component_item_id         = top_assm.component_item_id         and
        component_organization_id = top_assm.component_organization_id
      connect by
        prior rollup_id                 =  rollup_id                and
        prior component_item_id         =  assembly_item_id         and
        prior component_organization_id =  assembly_organization_id and
        level                           <= i_report_levels;


    EXCEPTION
      WHEN OTHERS THEN

      l_err_code := SQLCODE;
      l_err_mesg := substrb( SQLERRM, 1, 100 );

      insert into cst_sc_bom_structures
      (
        ROLLUP_ID,
        TOP_INVENTORY_ITEM_ID,
        TOP_ORGANIZATION_ID,
        SORT_ORDER,
        BOM_LEVEL,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORGANIZATION_ID,
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        COMPONENT_ORGANIZATION_ID,
        COMPONENT_QUANTITY,
        EXTENDED_QUANTITY,
        INCLUDE_IN_COST_ROLLUP,
        EXTEND_COST_FLAG,
        PHANTOM_FLAG,
        ERROR_CODE,
        ERROR_MESG,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
      )
      values
      (
        i_rollup_id,                        -- ROLLUP_ID
        top_assm.component_item_id,         -- TOP_INVENTORY_ITEM_ID
        top_assm.component_organization_id, -- TOP_ORGANIZATION_ID
        0,                                  -- SORT_ORDER
        0,                                  -- BOM_LEVEL
        -1,                                 -- ASSEMBLY_ITEM_ID
        -1,                                 -- ASSEMBLY_ORGANIZATION_ID
        null,                               -- COMPONENT_SEQUENCE_ID
        top_assm.component_item_id,         -- COMPONENT_ITEM_ID
        top_assm.component_organization_id, -- COMPONENT_ORGANIZATION_ID
        0,                                  -- COMPONENT_QUANTITY
        0,                                  -- EXTENDED_QUANTITY
        2,                                  -- INCLUDE_IN_COST_ROLLUP
        2,                                  -- EXTEND_COST_FLAG
        2,                                  -- PHANTOM_FLAG
        l_err_code,                         -- ERROR_CODE
        l_err_mesg,                         -- ERROR_MESG
        sysdate,                     -- LAST_UPDATE_DATE
        i_user_id,                   -- LAST_UPDATED_BY
        i_login_id,                  -- LAST_UPDATE_LOGIN
        sysdate,                     -- CREATION_DATE
        i_user_id,                   -- CREATED_BY
        i_request_id,                -- REQUEST_ID
        i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
        i_prog_id,                   -- PROGRAM_ID
        sysdate                      -- PROGRAM_UPDATE_DATE
      );

    END;
  END LOOP;



  l_stmt_num := 30;

  -- update the item revision column
  update cst_sc_bom_structures CSBS
  set    CSBS.component_revision =
  (
    select
      substr( max( to_char( MIR.effectivity_date, 'YYYY/MM/DD HH24:MI:SS' ) ||
                   MIR.revision ), 20 )
    from
      mtl_item_revisions MIR
    where
      MIR.inventory_item_id = CSBS.component_item_id and
      MIR.organization_id   = CSBS.component_organization_id and
      MIR.effectivity_date <= i_effective_date
  )
  where  CSBS.rollup_id = i_rollup_id;



  l_stmt_num := 40;
  IF i_cost_type_id is not null THEN
    explode_sc_cost_flags
    (
      i_rollup_id,
      i_cost_type_id,
      o_error_code,
      o_error_msg
    );

    IF o_error_code <> 0 THEN
      RETURN;
    END IF;
  END IF;

  -- SCAPI: insert data for consolidated report using negative rollup_id
  l_stmt_num := 50;
  IF i_report_type_type = 2 THEN
      insert into cst_sc_bom_structures
      (
        ROLLUP_ID,
        TOP_INVENTORY_ITEM_ID,
        TOP_ORGANIZATION_ID,
        SORT_ORDER,
        BOM_LEVEL,
        ASSEMBLY_ITEM_ID,
        ASSEMBLY_ORGANIZATION_ID,
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        COMPONENT_ORGANIZATION_ID,
        COMPONENT_QUANTITY,
        EXTENDED_QUANTITY,
        INCLUDE_IN_COST_ROLLUP,
        EXTEND_COST_FLAG,
        PHANTOM_FLAG,
        COMPONENT_REVISION,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE
      )
      select
        -1*i_rollup_id,                     -- ROLLUP_ID
        CSBS.top_inventory_item_id,         -- TOP_INVENTORY_ITEM_ID
        CSBS.top_organization_id,           -- TOP_ORGANIZATION_ID
        max(CSBS.sort_order),               -- SORT_ORDER
        max(CSBS.bom_level),                -- BOM_LEVEL
        max(CSBS.assembly_item_id),         -- ASSEMBLY_ITEM_ID
        CSBS.assembly_organization_id,      -- ASSEMBLY_ORGANIZATION_ID
        null,                               -- COMPONENT_SEQUENCE_ID
        CSBS.component_item_id,             -- COMPONENT_ITEM_ID
        CSBS.component_organization_id,     -- COMPONENT_ORGANIZATION_ID
        sum(CSBS.component_quantity),       -- COMPONENT_QUANTITY
        sum(CSBS.extended_quantity),        -- EXTENDED_QUANTITY
        null,                               -- INCLUDE_IN_COST_ROLLUP
        CSBS.extend_cost_flag,              -- EXTEND_COST_FLAG
        CSBS.phantom_flag,                  -- PHANTOM_FLAG
        CSBS.component_revision,            -- COMPONENT_REVISION
        sysdate,                     -- LAST_UPDATE_DATE
        i_user_id,                   -- LAST_UPDATED_BY
        i_login_id,                  -- LAST_UPDATE_LOGIN
        sysdate,                     -- CREATION_DATE
        i_user_id,                   -- CREATED_BY
        i_request_id,                -- REQUEST_ID
        i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
        i_prog_id,                   -- PROGRAM_ID
        sysdate                      -- PROGRAM_UPDATE_DATE
      from
        cst_sc_bom_structures CSBS
      where
        rollup_id                 = i_rollup_id
      group by
        CSBS.top_inventory_item_id,
        CSBS.top_organization_id,
        CSBS.assembly_organization_id,
        CSBS.component_item_id,
        CSBS.component_organization_id,
        CSBS.extend_cost_flag,
        CSBS.phantom_flag,
        CSBS.component_revision;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.snapshot_sc_bom_structures():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end snapshot_sc_bom_structures;

PROCEDURE check_loop (i_rollup_id  in number,
                    o_error_code out NOCOPY number,
                    o_error_msg  out NOCOPY varchar2)
IS
  cursor loop_cursor is
    select plan_level-1 plan_level,
           ASSM.concatenated_segments assembly_item,
           MP1.organization_code assembly_organization,
           COMP.concatenated_segments component_item,
           MP2.organization_code component_organization
    from cst_sc_bom_explosion CSBE,
         mtl_system_items_kfv ASSM,
         mtl_parameters MP1,
         mtl_system_items_kfv COMP,
         mtl_parameters MP2
    where CSBE.rollup_id = i_rollup_id
    and CSBE.deleted_flag = 'N'
    and ASSM.inventory_item_id = CSBE.assembly_item_id
    and ASSM.organization_id = CSBE.assembly_organization_id
    and MP1.organization_id = CSBE.assembly_organization_id
    and COMP.inventory_item_id = CSBE.component_item_id
    and COMP.organization_id = CSBE.component_organization_id
    and MP2.organization_id = CSBE.component_organization_id
    order by CSBE.plan_level;

  l_stmt_num     number;
  l_loop_flag    boolean := FALSE;

BEGIN

  l_stmt_num := 10;

  for rec in loop_cursor loop
    l_stmt_num := 20;
    l_loop_flag := TRUE;
    fnd_file.put_line(fnd_file.log, LPAD(rec.plan_level, 3)||' : '||
                                    rec.assembly_item||'[Org:'||rec.assembly_organization||']'||' ==> '||
                                    rec.component_item||'[Org:'||rec.component_organization||']');
  end loop;

  l_stmt_num := 30;
  if l_loop_flag then
    fnd_file.put_line(fnd_file.log, 'Warning: Please check for Loop in the BOM structure above.');
  end if;

EXCEPTION

  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.check_loop():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);
END check_loop;

procedure compute_sc_low_level_codes (
  i_rollup_id         in  number,
  i_explosion_levels  in  number,
  i_cost_type_id      in  number,
  i_user_id           in  number,
  i_login_id          in  number,
  i_request_id        in  number,
  i_prog_id           in  number,
  i_prog_appl_id      in  number,
  o_error_code        out NOCOPY number,
  o_error_msg         out NOCOPY varchar2,
  i_report_option_type  in  number   -- SCAPI: for supply chain cost reports
)
is
  l_low_level_code NUMBER(15);
  l_frozen_standard_flag number(15);

  l_stmt_num number(15);
begin

  l_low_level_code := LOWEST_LEVEL_CODE;

  /* Supply chain enhancement: if not a full rollup, only assign low level codes
     for items that exist in cst_sc_lists */

  IF i_explosion_levels is not null THEN

     l_stmt_num := 5;

     update cst_sc_bom_explosion CSBE
     set deleted_flag = 'Y'
     where
       CSBE.rollup_id    = i_rollup_id and
       CSBE.deleted_flag = 'N'         and
       not exists ( select 'Item in List'
                    from cst_sc_lists CSL
                    where CSL.rollup_id = i_rollup_id
                    and CSL.inventory_item_id = CSBE.component_item_id
                    and CSL.organization_id = CSBE.component_organization_id );

  END IF;

LOOP

  l_stmt_num := 10;

  insert into cst_sc_low_level_codes
  (
    ROLLUP_ID,
    INVENTORY_ITEM_ID,
    ORGANIZATION_ID,
    LOW_LEVEL_CODE,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE
  )
  select distinct
    i_rollup_id,                    -- ROLLUP_ID
    CSBE.component_item_id,         -- INVENTORY_ITEM_ID
    CSBE.component_organization_id, -- ORGANIZATION_ID
    l_low_level_code,               -- LOW_LEVEL_CODE
    sysdate,                     -- LAST_UPDATE_DATE
    i_user_id,                   -- LAST_UPDATED_BY
    i_login_id,                  -- LAST_UPDATE_LOGIN
    sysdate,                     -- CREATION_DATE
    i_user_id,                   -- CREATED_BY
    i_request_id,                -- REQUEST_ID
    i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
    i_prog_id,                   -- PROGRAM_ID
    sysdate                      -- PROGRAM_UPDATE_DATE
  from
    cst_sc_bom_explosion CSBE
  where
    CSBE.rollup_id    = i_rollup_id and
    CSBE.deleted_flag = 'N'         and
    not exists
    (
      select 'x'
      from   cst_sc_bom_explosion CSBE2
      where
        CSBE2.rollup_id                = CSBE.rollup_id                 and
        CSBE2.assembly_item_id         = CSBE.component_item_id         and
        CSBE2.assembly_organization_id = CSBE.component_organization_id and
        CSBE2.deleted_flag             = 'N'
    );

  l_stmt_num := 20;

  update cst_sc_bom_explosion CSBE
  set deleted_flag = 'Y'
  where
    CSBE.rollup_id    = i_rollup_id and
    CSBE.deleted_flag = 'N'         and
    not exists
    (
      select 'x'
      from   cst_sc_bom_explosion CSBE2
      where
        CSBE2.rollup_id                = CSBE.rollup_id                 and
        CSBE2.assembly_item_id         = CSBE.component_item_id         and
        CSBE2.assembly_organization_id = CSBE.component_organization_id and
        CSBE2.deleted_flag             = 'N'
    );

  l_low_level_code := l_low_level_code + 1;

  EXIT WHEN SQL%ROWCOUNT = 0;

END LOOP;



  IF i_cost_type_id is not null THEN

    l_stmt_num := 30;

    select CCT.frozen_standard_flag
    into   l_frozen_standard_flag
    from   cst_cost_types CCT
    where  CCT.cost_type_id = i_cost_type_id;

    -- SCAPI: to support supply chain cost reports
    IF ( (l_frozen_standard_flag = 1) and (i_report_option_type <> -1 or i_report_option_type is null) ) THEN

      l_stmt_num := 40;

      delete cst_sc_low_level_codes CSLLC
      where
        CSLLC.rollup_id      =  i_rollup_id       and
        exists
        (
          select 'x'
          from   mtl_material_transactions MMT
          where  MMT.inventory_item_id = CSLLC.inventory_item_id and
                 MMT.organization_id   = CSLLC.organization_id
        );

      IF SQL%ROWCOUNT > 0 THEN
        o_error_code := 1001;
        o_error_msg  :=
          'CSTPSCEX.compute_sc_low_level_codes():' ||
          to_char(l_stmt_num) || ':' ||
          'Cannot update standard cost for ' || to_char(SQL%ROWCOUNT) ||
          ' items due to existing MMT transactions';
      END IF;

    END IF;

  END IF;

exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.compute_sc_low_level_codes():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end compute_sc_low_level_codes;


procedure supply_chain_rollup (
  i_rollup_id          in  number,   -- rollup ID, CST_LISTS_S
  i_explosion_levels   in  number,   -- levels to explode, NULL for all levels
  i_report_levels      in  number,   -- levels in report, NULL for no report
  i_assignment_set_id  in  number,   -- MRP assignment_set_id, NULL for none
  i_conversion_type    in  varchar2, -- GL_DAILY_CONVERSION_TYPES
  i_cost_type_id       in  number,   -- rollup cost type
  i_buy_cost_type_id   in  number,   -- buy cost cost type
  i_effective_date     in  date,     -- BIC.effectivity_date
  i_exclude_unimpl_eco in  number,   -- 1 = exclude unimplemented, 2 = include
  i_exclude_eng        in  number,   -- 1 = exclude eng items, 2 = include
  i_alt_bom_desg       in  varchar2,
  i_alt_rtg_desg       in  varchar2,
  i_lock_flag          in  number,   -- 1 = wait for locks, 2 = no
  i_user_id            in  number,
  i_login_id           in  number,
  i_request_id         in  number,
  i_prog_id            in  number,
  i_prog_appl_id       in  number,
  o_error_code         out NOCOPY number,
  o_error_msg          out NOCOPY varchar2,
  i_lot_size_option    in  number,  -- SCAPI: dynamic lot size
  i_lot_size_setting   in  number,
  i_report_option_type in  number,
  i_report_type_type   in  number,
  i_buy_cost_detail    in  number
)
is
  l_include_unimpl_eco number(15);
  l_include_eng        number(15);
  l_rollup_id          number(15);

  l_rollup_option number(15);

  l_stmt_num number(15);

  l_timestamp date;

  l_no_bom_org number(15);  -- SCAPI: check for bom parameters setup

  l_report_levels number(15); -- := i_report_levels;  commented to remove GSCC warning

begin

  l_report_levels := i_report_levels; -- added to remove GSCC warning

  l_stmt_num := 0;
  l_rollup_id := i_rollup_id;
  IF l_rollup_id IS NULL THEN
    select cst_lists_s.nextval
    into   l_rollup_id
    from   dual;
  END IF;

  l_stmt_num := 10;
  IF i_exclude_eng = 1 THEN
    l_include_eng := 2;
  ELSE
    l_include_eng := 1;
  END IF;

  l_stmt_num := 20;
  IF i_exclude_unimpl_eco = 1 THEN
    l_include_unimpl_eco := 2;
  ELSE
    l_include_unimpl_eco := 1;
  END IF;

  l_stmt_num := 30;
  -- SCAPI: no insert for supply chain cost reports
  IF (i_report_option_type <> -1 or i_report_option_type is null) THEN
     insert into cst_sc_rollup_history
     (
       rollup_id,
       explosion_level,
       report_level,
       assignment_set_id,
       conversion_type,
       cost_type_id,
       buy_cost_type_id,
       revision_date,
       INC_UNIMP_ECN_FLAG,
       ENG_BILL_FLAG,
       alt_bom_desg,
       alt_rtg_desg,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       CREATION_DATE,
       CREATED_BY,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE
     )
     select
       l_rollup_id,
       i_explosion_levels,
       l_report_levels,
       i_assignment_set_id,
       i_conversion_type,
       i_cost_type_id,
       i_buy_cost_type_id,
       i_effective_date,
       l_include_unimpl_eco,
       l_include_eng,
       i_alt_bom_desg,
       i_alt_rtg_desg,
       sysdate,                     -- LAST_UPDATE_DATE
       i_user_id,                   -- LAST_UPDATED_BY
       i_login_id,                  -- LAST_UPDATE_LOGIN
       sysdate,                     -- CREATION_DATE
       i_user_id,                   -- CREATED_BY
       i_request_id,                -- REQUEST_ID
       i_prog_appl_id,              -- PROGRAM_APPLICATION_ID
       i_prog_id,                   -- PROGRAM_ID
       sysdate                      -- PROGRAM_UPDATE_DATE
     from   dual
     where  not exists
     (
       select 'x'
       from   cst_sc_rollup_history
       where  rollup_id = l_rollup_id
     );
  END IF;



  l_stmt_num := 40;
  CSTPSCEX.insert_assembly_items
  (
    l_rollup_id,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    o_error_code,
    o_error_msg
  );
  IF o_error_code <> 0 THEN
    RETURN;
  END IF;



  l_timestamp := SYSDATE;

  l_stmt_num := 50;
  CSTPSCEX.explode_sc_bom
  (
    l_rollup_id,
    i_explosion_levels,
    i_assignment_set_id,
    i_effective_date,
    l_include_unimpl_eco,
    l_include_eng,
    i_alt_bom_desg,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    o_error_code,
    o_error_msg
  );
  IF o_error_code <> 0 THEN
    RETURN;
  END IF;

  update cst_sc_rollup_history CSRH
  set    CSRH.explosion_time = (SYSDATE - l_timestamp) * 86400
  where  CSRH.rollup_id = l_rollup_id;



  l_stmt_num := 60;
  CSTPSCEX.snapshot_sc_conversion_rates
  (
    l_rollup_id,
    i_conversion_type,
    o_error_code,
    o_error_msg
  );
  IF o_error_code <> 0 THEN
    RETURN;
  END IF;



  l_timestamp := SYSDATE;

  l_stmt_num := 70;
  CSTPSCEX.compute_sc_low_level_codes
  (
    l_rollup_id,
    i_explosion_levels,
    i_cost_type_id,
    i_user_id,
    i_login_id,
    i_request_id,
    i_prog_id,
    i_prog_appl_id,
    o_error_code,
    o_error_msg,
    i_report_option_type
  );
  IF o_error_code <> 0 THEN
    RETURN;
  END IF;

  --To print the BOM structure loops if any, to the log file.
  l_stmt_num := 75;
  CSTPSCEX.check_loop (
    l_rollup_id,
    o_error_code,
    o_error_msg
  );

  IF o_error_code <> 0 THEN
    RETURN;
  END IF;

   -- SCAPI: always use the maximum report level for consolidated reports
  l_stmt_num := 76;
  IF ((l_report_levels IS NOT NULL) and (i_report_type_type = 2)) THEN
     select max(low_level_code)+2
     into   l_report_levels
     from   cst_sc_low_level_codes
     where  rollup_id = l_rollup_id;
  END IF;


  update cst_sc_rollup_history CSRH
  set    CSRH.low_level_code_time = (SYSDATE - l_timestamp) * 86400
  where  CSRH.rollup_id = l_rollup_id;


  l_timestamp := SYSDATE;

  l_stmt_num := 80;
  -- SCAPI: no costs removal for supply chain cost reports
  IF (i_report_option_type <> -1 or i_report_option_type is null) THEN
     o_error_code := CSTPSCCR.REMOVE_ROLLEDUP_COSTS
     (
        l_rollup_id,
        to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'), -- P_ROLLUP_DATE VARCHAR2 IN
        i_buy_cost_type_id,  -- P_SRC_COST_TYPE_ID  NUMBER   IN
        i_cost_type_id,      -- P_DEST_COST_TYPE_ID NUMBER   IN
        null,                -- P_CONC_FLAG         NUMBER   IN
        i_request_id,        -- REQ_ID              NUMBER   IN
        i_prog_appl_id,      -- PRGM_APPL_ID        NUMBER   IN
        i_prog_id,           -- PRGM_ID             NUMBER   IN
        o_error_msg,         -- X_ERR_BUF           VARCHAR2 OUT
        i_lot_size_option,
        i_lot_size_setting,
        i_lock_flag  -- Bug 3111820
     );

     IF o_error_code <> 0 THEN
        RETURN;
     END IF;
  END IF;

  update cst_sc_rollup_history CSRH
  set    CSRH.remove_costs_time = (SYSDATE - l_timestamp) * 86400
  where  CSRH.rollup_id = l_rollup_id;



  l_stmt_num := 90;
  IF i_explosion_levels IS NULL THEN
    l_rollup_option := 2; -- full rollup option
  ELSE
    l_rollup_option := 1; -- single level rollup option
  END IF;



  l_timestamp := SYSDATE;

  l_stmt_num := 100;
  -- SCAPI: no cost calculation for supply chain cost reports
  IF (i_report_option_type <> -1 or i_report_option_type is null) THEN
     o_error_code := CSTPSCCR.CSTSCCRU
     (
        l_rollup_id,          -- L_ROLLUP_ID         NUMBER   IN
        i_request_id,         -- REQ_ID              NUMBER   IN
        i_buy_cost_type_id,   -- L_SRC_COST_TYPE_ID  NUMBER   IN
        i_cost_type_id,       -- L_DEST_COST_TYPE_ID NUMBER   IN
        i_assignment_set_id,  -- L_ASSIGNMENT_SET_ID NUMBER   IN
        i_prog_appl_id,       -- PRGM_APPL_ID        NUMBER   IN
        i_prog_id,            -- PRGM_ID             NUMBER   IN
        i_user_id,            -- L_LAST_UPDATED_BY   NUMBER   IN
        1,                    -- CONC_FLAG           NUMBER   IN
        l_include_unimpl_eco, -- UNIMP_FLAG          NUMBER   IN
        i_lock_flag,          -- LOCKING_FLAG        NUMBER   IN
        to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'), -- ROLLUP_DATE   VARCHAR2 IN
        /* Bug 2305807. Need Effectivity Date. Bug 3098303: pass full time components */
        to_char(i_effective_date, 'YYYY/MM/DD HH24:MI:SS'),
        i_alt_bom_desg,       -- ALT_BOM_DESIGNATOR  VARCHAR2 IN
        i_alt_rtg_desg,       -- ALT_RTG_DESIGNATOR  VARCHAR2 IN
        l_rollup_option,      -- ROLLUP_OPTION       NUMBER   IN
        1,                    -- REPORT_OPTION       NUMBER   IN
        i_exclude_eng,        -- L_MFG_FLAG          NUMBER   IN
        o_error_msg,          -- ERR_BUF             VARCHAR2 OUT
        i_buy_cost_detail     -- BUY_COST_DETAIL     NUMBER   IN
     );

     IF o_error_code <> 0 THEN
        RETURN;
     END IF;
  END IF;

  update cst_sc_rollup_history CSRH
  set    CSRH.rollup_time = (SYSDATE - l_timestamp) * 86400
  where  CSRH.rollup_id = l_rollup_id;



  l_timestamp := SYSDATE;

  IF l_report_levels IS NOT NULL THEN

    l_stmt_num := 105;
    CSTPSCEX.snapshot_sc_bom_structures
    (
      l_rollup_id,
      i_cost_type_id,
      l_report_levels,
      i_effective_date,
      i_user_id,
      i_login_id,
      i_request_id,
      i_prog_id,
      i_prog_appl_id,
      o_error_code,
      o_error_msg,
      i_report_type_type    -- SCAPI: support consolidated report
    );
    IF o_error_code <> 0 THEN
      RETURN;
    END IF;

  END IF;

  update cst_sc_rollup_history CSRH
  set    CSRH.bom_structure_time = (SYSDATE - l_timestamp) * 86400
  where  CSRH.rollup_id = l_rollup_id;

  l_timestamp := SYSDATE;

/* Removed this code for bug 5678464 */
/*  IF i_request_id is NOT NULL THEN  -- Bug 4244467
   l_stmt_num := 110;
   o_error_code := CSTPSCCM.remove_rollup_history
   (
     p_rollup_id       => l_rollup_id,
     p_sc_cost_type_id => i_cost_type_id,
     p_rollup_option   => l_rollup_option,
     x_err_buf         => o_error_msg
   );
  END IF;
*/

exception
  when OTHERS then
    o_error_code := SQLCODE;
    o_error_msg  := 'CSTPSCEX.supply_chain_rollup():' ||
                    to_char(l_stmt_num) || ':' ||
                    substrb(SQLERRM, 1, 1000);

end supply_chain_rollup;



end CSTPSCEX;

/
