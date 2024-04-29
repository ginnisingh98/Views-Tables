--------------------------------------------------------
--  DDL for Package Body BOM_IMPLODER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_IMPLODER_PUB" as
/* $Header: BOMPIMPB.pls 120.13.12010000.5 2010/02/04 07:34:11 maychen ship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : bom_imploder_pub.sql                                               |
| DESCRIPTION  : This file is a packaged procedure for the imploders.
|                This package contains 2 different imploders for the
|                single level and multi level implosion. The package
|                imploders calls the correct imploder based on the
|    # of levels to implode.
| Parameters:   org_id          organization_id
|               sequence_id     unique value to identify current implosion
|                               use value from sequence bom_small_impl_temp_s
|               levels_to_implode
|               eng_mfg_flag    1 - BOM
|                               2 - ENG
|               impl_flag       1 - implemented only
|                               2 - both impl and unimpl
|               display_option  1 - All
|                               2 - Current
|                               3 - Current and future
|               item_id         item id of asembly to explode
|               impl_date       explosion date dd-mon-rr hh24:mi
|               err_msg         error message out buffer
|               error_code      error code out.  returns sql error code
|                               if sql error, -9999 if loop detected.
|   organization_option
|       1 - Current Organization
|       2 - Organization Hierarchy
|       3 - All Organizations to which access is allowed
|   organization_hierarchy
|       Organization Hierarchy Name
|
| HISTORY
| 06-JUL-05   Bhavnesh Patel    Changes for Revision Effective Structure
| 27-SEP-05   Bhavnesh Patel    Changes for Exclusion Rules
| 09-NOV-05   Bhavnesh Patel    Added Revision Filter
| 07-FEB-06   Bhavnesh Patel    Changes for improving performance
+==========================================================================*/
--Constants
G_CAD_OBJ_NAME  VARCHAR2(30)  := 'DDD_CADVIEW';
G_EGO_OBJ_NAME  VARCHAR2(30)  := 'EGO_ITEM';

/*Function added for BUG fix 3377394 */
FUNCTION CALCULATE_COMP_COUNT
( PK_VALUE1 IN VARCHAR2,
  PK_VALUE2 IN VARCHAR2,
  IMPL_DATE IN VARCHAR2)

RETURN NUMBER
IS
  COUNTER NUMBER;
BEGIN
  SELECT COUNT(COMPONENT_SEQUENCE_ID) INTO COUNTER
                   FROM bom_components_b
                   WHERE pk1_value = PK_VALUE1
                    AND pk2_value = PK_VALUE2
		    AND to_date(impl_date, 'YYYY/MM/DD HH24:MI:SS')
			between effectivity_date
			and nvl(disable_date, sysdate) ;
/*bug: 3807198, taking care of disabled components*/
  RETURN COUNTER;
END CALCULATE_COMP_COUNT;

  FUNCTION Check_User_View_priv(Itemid VARCHAR2, OrgId VARCHAR2)
  RETURN Varchar2 IS
        l_access_flag varchar2(10);
  BEGIN
  Select  BOM_SECURITY_PUB.CHECK_USER_PRIVILEGE( 1,
        'EGO_VIEW_ITEM',
        'EGO_ITEM',
        ItemId,
        OrgId,
        null,
        null,
        null,
        BOM_SECURITY_PUB.Get_EGO_User
        ) into l_access_flag
	from dual;
  Return l_access_flag;
  End Check_User_View_priv;

/* Procedure imploder_userexit for PLM support
   This procedure will call overloaded procedure with null revision
*/
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2,
  pk4_value   IN  VARCHAR2,
  pk5_value   IN  VARCHAR2,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE
  )
AS
BEGIN
  imploder_userexit(
                    sequence_id => sequence_id,
                    eng_mfg_flag => eng_mfg_flag,
                    org_id => org_id,
                    impl_flag => impl_flag,
                    display_option => display_option,
                    levels_to_implode => levels_to_implode,
                    obj_name => obj_name,
                    pk1_value => pk1_value,
                    pk2_value => pk2_value,
                    pk3_value => pk3_value,
                    pk4_value => pk4_value,
                    pk5_value => pk5_value,
                    impl_date => impl_date,
                    unit_number_from => unit_number_from,
                    unit_number_to => unit_number_to,
                    err_msg => err_msg,
                    err_code => err_code,
                    organization_option => organization_option,
                    organization_hierarchy => organization_hierarchy,
                    serial_number_from => serial_number_from,
                    serial_number_to => serial_number_to,
                    struct_name => struct_name,
                    revision => NULL
                   );
END imploder_userexit;

PROCEDURE implosion_cad(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  impl_date   IN  VARCHAR2,
  unit_number_from  IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  serial_number_from  IN  VARCHAR2 default NULL,
  serial_number_to  IN  VARCHAR2 default NULL  ,
  struct_name       IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision          IN  VARCHAR2) AS

    implosion_date    VARCHAR2(25);
    error_msg     VARCHAR(2000);--bug:4204847 Increasing the length so that component path can be
                                --returned in case of loop
    error_code      NUMBER;

BEGIN
    implosion_date  := substr(impl_date, 1, 19);

      ml_imploder_cad(sequence_id, eng_mfg_flag, org_id, impl_flag,
    levels_to_implode, implosion_date, unit_number_from,
          unit_number_to, error_msg, error_code,
                serial_number_from, serial_number_to,struct_name, revision);

    err_msg := error_msg;
    err_code  := error_code;

    if (error_code <> 0) then
  ROLLBACK;
    end if;

EXCEPTION
    WHEN OTHERS THEN
  err_msg   := error_msg;
  err_code  := error_code;
  ROLLBACK;
END implosion_cad;

PROCEDURE ml_imploder_cad(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  a_levels_to_implode IN  NUMBER,
  impl_date   IN  VARCHAR2,
  unit_number_from        IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  error_code    OUT NOCOPY NUMBER,
  serial_number_from      IN  VARCHAR2,
  serial_number_to        IN  VARCHAR2,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision                IN  VARCHAR2) AS

    prev_parent_item_id   NUMBER;
    cum_count     NUMBER;
    cur_level     NUMBER;
    total_rows      NUMBER;
    levels_to_implode   NUMBER;
    max_level     NUMBER;
    cat_sort      VARCHAR2(7);
    max_extents     EXCEPTION;


/*
** max extents exceeded exception
*/
    PRAGMA EXCEPTION_INIT(max_extents, -1631);

    CURSOR imploder (c_current_level NUMBER, c_sequence_id NUMBER,
    c_eng_mfg_flag NUMBER, c_org_id NUMBER,
    c_implosion_date VARCHAR2, c_unit_number_from VARCHAR2,
                c_unit_number_to VARCHAR2,c_serial_number_from VARCHAR2,
                c_serial_number_to VARCHAR2, c_implemented_only_option NUMBER,
                c_levels_to_implode NUMBER
    ) IS
        SELECT --/*+ ordered first_rows */
         BITT.LOWEST_pk1_value  LID1,
         BITT.LOWEST_pk2_value  LID2,
         BITT.LOWEST_pk3_value  LID3,
         BITT.LOWEST_pk4_value  LID4,
         BITT.LOWEST_pk5_value  LID5,
         BITT.LOWEST_obj_name LON,
         BITT.PARENT_pk1_value    PID1,
         BITT.PARENT_pk2_value    PID2,
         BITT.PARENT_pk3_value    PID3,
         BITT.PARENT_pk4_value    PID4,
         BITT.PARENT_pk5_value    PID5,
         BITT.PARENT_obj_name  PON,
         BBM.PK1_VALUE AID1,
         BBM.PK2_VALUE AID2,
         BBM.PK3_VALUE AID3,
         BBM.PK4_VALUE AID4,
         BBM.PK5_VALUE AID5,
         nvl(BBM.OBJ_NAME,G_EGO_OBJ_NAME)  AON,
         BBM.ALTERNATE_BOM_DESIGNATOR ABD,
         BITT.SORT_CODE SC,
         BITT.LOWEST_ALTERNATE_DESIGNATOR LAD,
         BBM.ASSEMBLY_TYPE CAT,
         BIC.COMPONENT_SEQUENCE_ID CSI,
         BIC.OPERATION_SEQ_NUM OSN,
         BIC.EFFECTIVITY_DATE ED,
         BIC.DISABLE_DATE DD,
         BIC.BASIS_TYPE BT,
         BIC.COMPONENT_QUANTITY CQ,
         BIC.REVISED_ITEM_SEQUENCE_ID RISD,
         BIC.CHANGE_NOTICE CN,
         DECODE(BIC.IMPLEMENTATION_DATE, NULL, 2, 1) IMPF,
         BBM.ORGANIZATION_ID OI,
         BIC.FROM_END_ITEM_UNIT_NUMBER FUN,
         BIC.TO_END_ITEM_UNIT_NUMBER TUN,
         BBM.STRUCTURE_TYPE_ID,
         BITT.COMPONENT_PATH COMPONENT_PATH,
         BIC.COMPONENT_ITEM_REVISION_ID COMPONENT_ITEM_REVISION_ID ,
         DECODE( BIC.FROM_END_ITEM_REV_ID
                ,NULL ,NULL
                ,(
                   SELECT  mirb.REVISION
                   FROM    MTL_ITEM_REVISIONS_B mirb
                   WHERE   mirb.REVISION_ID = BIC.FROM_END_ITEM_REV_ID
                  ) ) FROM_END_ITEM_REVISION,
         DECODE( BIC.TO_END_ITEM_REV_ID
                ,NULL ,NULL
                ,(
                   SELECT  mirb.REVISION
                   FROM    MTL_ITEM_REVISIONS_B mirb
                   WHERE   mirb.REVISION_ID = BIC.TO_END_ITEM_REV_ID
                  ) ) TO_END_ITEM_REVISION ,
         BBM.EFFECTIVITY_CONTROL EFFECTIVITY_CONTROL
         FROM
         BOM_SMALL_IMPL_TEMP BITT,
         BOM_COMPONENTS_B BIC,
         BOM_STRUCTURES_B BBM
         where
     bitt.current_level = c_current_level
       and bitt.organization_id = c_org_id
   and bitt.sequence_id = c_sequence_id
/* Bug#7389906 Starts here. Took out the common condition */
  and ((bitt.parent_obj_name = G_EGO_OBJ_NAME
      and (bitt.parent_obj_name = nvl(bic.obj_name,G_EGO_OBJ_NAME)))
       or
       (bitt.parent_obj_name =  G_CAD_OBJ_NAME
 and (bitt.parent_obj_name = to_char(bic.obj_name))))
 and bitt.parent_pk1_value = bic.pk1_value
 /* Bug#7389906 Ends here*/
  and bic.bill_sequence_id = bbm.common_bill_sequence_id
  and bbm.organization_id = c_org_id
  and  (   (struct_name = FND_LOAD_UTIL.NULL_VALUE)
             or
              ( struct_name is null AND bbm.alternate_bom_designator  is null )
             or ( bbm.alternate_bom_designator = struct_name ) )
  and NVL(BIC.ECO_FOR_PRODUCTION,2) = 2
  and ( c_eng_mfg_flag = 2 or c_eng_mfg_flag = 1 and
    ( c_current_level = 0
      and bbm.assembly_type = 1
                  or c_current_level <> 0 and bitt.current_assembly_type = 1
                   and bbm.assembly_type = 1))
  and ( c_current_level = 0
        or   /* start of all alternate logic */
        bbm.alternate_bom_designator is null and
        bitt.lowest_alternate_designator is null
        or bbm.alternate_bom_designator = bitt.lowest_alternate_designator
              or ( bitt.lowest_alternate_designator is null
                and bbm.alternate_bom_designator is not null
                and not exists (select NULL     /*for current item */
                              from BOM_STRUCTURES_B bbm2
                          where bbm2.organization_id = c_org_id
                          and   (bitt.parent_obj_name = G_EGO_OBJ_NAME
              and (bbm2.assembly_item_id = bitt.parent_pk1_value
              and bitt.parent_obj_name = nvl(bbm2.obj_name,G_EGO_OBJ_NAME)
                                and bbm2.alternate_bom_designator = bbm.alternate_bom_designator))
                          and ( bitt.current_assembly_type = 2
                                or  bbm2.assembly_type = 1
                                and bitt.current_assembly_type = 1)
                             )
                 )
              or /* Pickup prim par only if starting alt is not
      null and bill for .. */
              (bitt.lowest_alternate_designator is not null
               and bbm.alternate_bom_designator is null
               and not exists (select NULL
                          from BOM_STRUCTURES_B bbm2
                          where bbm2.organization_id = c_org_id
                          and  (bitt.parent_obj_name = G_EGO_OBJ_NAME
              and (bbm2.assembly_item_id = bbm.assembly_item_id
             and nvl(bbm2.obj_name,G_EGO_OBJ_NAME) = nvl(bbm.obj_name,G_EGO_OBJ_NAME)
                               and bbm2.alternate_bom_designator = bitt.lowest_alternate_designator))
                          and ( bitt.current_assembly_type = 1
                                and bbm2.assembly_type = 1
                              or bitt.current_assembly_type = 2)
                        )
              )
            )
        and (
       (
        bbm.obj_name = 'EGO_ITEM' or bbm.obj_name is NULL
        and (exists (select 'X'
         from   MTL_SYSTEM_ITEMS_B MSI,
                MTL_SYSTEM_ITEMS_B MSI_CHILD
         where  MSI.ORGANIZATION_ID = BBM.ORGANIZATION_ID
         and    MSI.INVENTORY_ITEM_ID = BBM.ASSEMBLY_ITEM_ID
         AND MSI_CHILD.ORGANIZATION_ID = BBM.ORGANIZATION_ID
         AND MSI_CHILD.INVENTORY_ITEM_ID = bic.COMPONENT_ITEM_ID
         AND
            (   ( c_current_level = 0 )
             OR
                (
                    ( c_current_level >= 1 )
                 AND
                    NOT  ( -- start for checking configured parent
                                 msi.BOM_ITEM_TYPE = 4 -- Standard
                           AND   msi.REPLENISH_TO_ORDER_FLAG = 'Y'
                           AND   msi.BASE_ITEM_ID IS NOT NULL -- configured item
                           AND   msi_child.BOM_ITEM_TYPE IN (1, 2) -- model or option class
                         ) -- end for checking configured parent
                 AND msi.BOM_ENABLED_FLAG = 'Y' -- parent should be enabled
                )
            )
         and
      ( -- start revision filter logic
       (
          /* For non-null revision, select first level parents having same comp fixed revision, irrespective of
             any effectivity criteria. */
            revision IS NOT NULL
        AND c_current_level = 0
        AND revision = bic.COMPONENT_ITEM_REVISION_ID
        AND (     ( NVL(BBM.EFFECTIVITY_CONTROL,1) = 1 ) /* bug:5227395 Filter out disabled components of non-date eff bill */
              OR  ( ( NVL(BBM.EFFECTIVITY_CONTROL,1) <> 1 ) AND ( bic.DISABLE_DATE IS NULL ) )
            )
       )
       OR
       (
          ( ( revision IS NULL ) OR ( c_current_level <> 0 ) )
       AND
       ( /* Effectivity Control */
        ( msi.effectivity_control=1 -- Date Effectivity Control
          AND
            (
              (    BBM.EFFECTIVITY_CONTROL IS NULL
               OR  BBM.EFFECTIVITY_CONTROL <> 4 -- Date Effective structure
              )
            OR
              (
                    BBM.EFFECTIVITY_CONTROL = 4 --Revision Effectivity
              AND   (
                          ( c_implemented_only_option = 1 AND bic.IMPLEMENTATION_DATE IS NOT NULL )
                     OR   ( c_implemented_only_option = 2 )
                    )
              AND   ( bic.DISABLE_DATE IS NULL )
              AND
                    ( --From end item revision for component  <=  parent current revision
                          BIC.FROM_END_ITEM_REV_ID IS NOT NULL
                     AND  ( SELECT
                              MIRB.REVISION
                            FROM
                              MTL_ITEM_REVISIONS_B MIRB
                            WHERE
                                MIRB.INVENTORY_ITEM_ID =  MSI.INVENTORY_ITEM_ID
                            AND MIRB.ORGANIZATION_ID   =  MSI.ORGANIZATION_ID
                            AND MIRB.REVISION_ID       =  BIC.FROM_END_ITEM_REV_ID
                           )  <=
                                 (SELECT
                                    MAX(MIRB.REVISION)
                                  FROM
                                    MTL_ITEM_REVISIONS_B MIRB
                                  WHERE
                                      MIRB.INVENTORY_ITEM_ID =  MSI.INVENTORY_ITEM_ID
                                  AND MIRB.ORGANIZATION_ID   =  MSI.ORGANIZATION_ID
                                  AND MIRB.EFFECTIVITY_DATE <=  to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS') )
                    )
              AND
                    ( --To end item revision for component  >=  parent current revision
                          BIC.TO_END_ITEM_REV_ID IS NULL
                     OR
                          ( SELECT
                              MIRB.REVISION
                            FROM
                              MTL_ITEM_REVISIONS_B MIRB
                            WHERE
                                MIRB.INVENTORY_ITEM_ID =  MSI.INVENTORY_ITEM_ID
                            AND MIRB.ORGANIZATION_ID   =  MSI.ORGANIZATION_ID
                            AND MIRB.REVISION_ID       =  BIC.TO_END_ITEM_REV_ID
                           )  >=
                                 (SELECT
                                    MAX(MIRB.REVISION)
                                  FROM
                                    MTL_ITEM_REVISIONS_B MIRB
                                  WHERE
                                      MIRB.INVENTORY_ITEM_ID =  MSI.INVENTORY_ITEM_ID
                                  AND MIRB.ORGANIZATION_ID   =  MSI.ORGANIZATION_ID
                                  AND MIRB.EFFECTIVITY_DATE <=  to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS') )
                    )
              )
            ) --end revision effectivity
                --and bic.effectivity_date <= to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
                --and ( bic.disable_date is null or
                --                bic.disable_date > to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS'))
                /* bug:4215514 For component of fixed revision parent, take implosion date
                   as high date of fixed revision
                   Hight Date = fixed rev effectivity date if (sysdate < fixed rev effectivity date)
                   Hight Date = fixed rev disable date if (sysdate > fixed rev disable date)
                   Hight Date = sysdate if (fixed rev effectivity date < sysdate < fixed rev disable date)
                 */
                  and
                    (
                      (     --floating revision of parent
                            (bic.component_item_revision_id is null OR c_current_level = 0)
                        and (bic.effectivity_date <= to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
                        or BBM.EFFECTIVITY_CONTROL = 4) /*Bug 8225025, remove bic.effectivity_date,implosion_date comparsion for revision effectivity control BOM*/
                        and
                          (
                              bic.disable_date is null
                          or  bic.disable_date > to_date (c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
                          or (bic.disable_date is not null and  bic.implementation_date is null)  /* bug 8304937 */
                          )
                      )
                      or
                      (
                            -- fixed revision of parent
                            (bic.component_item_revision_id is not null and c_current_level <> 0)
                        and
                          (
                            (
                                (    bitt.EFFECTIVITY_CONTROL IS NULL
                                 OR  bitt.EFFECTIVITY_CONTROL <> 4 -- Date Effective structure
                                )
                              and
                                  bitt.effectivity_date <=
                                    (
                                       select
                                          decode( sign( min(frm.effectivity_date) - sysdate ),
                                                  0,sysdate,
                                                  1,min(frm.effectivity_date),
                                                  decode( min(tom.effectivity_date),
                                                          null,sysdate,
                                                          decode( sign( min(tom.effectivity_date) - sysdate ),
                                                                  0,sysdate,
                                                                  1,sysdate,
                                                                  min(tom.effectivity_date)
                                                                )
                                                        )
                                                ) disable_date
                                        from
                                          mtl_item_revisions_b frm,
                                          mtl_item_revisions_b tom
                                        where
                                            frm.revision_id = bic.component_item_revision_id
                                        and tom.revision_id(+) <> frm.revision_id
                                        and frm.effectivity_date < tom.effectivity_date(+)
                                        and tom.inventory_item_id(+) = frm.inventory_item_id
                                        and tom.organization_id(+) = frm.organization_id
                                    )
                              and
                                (
                                    bitt.disable_date is null
                                or  bitt.disable_date >
                                      (
                                         select
                                          decode( sign( min(frm.effectivity_date) - sysdate ),
                                                  0,sysdate,
                                                  1,min(frm.effectivity_date),
                                                  decode( min(tom.effectivity_date),
                                                          null,sysdate,
                                                          decode( sign( min(tom.effectivity_date) - sysdate ),
                                                                  0,sysdate,
                                                                  1,sysdate,
                                                                  min(tom.effectivity_date)
                                                                )
                                                        )
                                                ) disable_date
                                          from
                                            mtl_item_revisions_b frm,
                                            mtl_item_revisions_b tom
                                          where
                                              frm.revision_id = bic.component_item_revision_id
                                          and tom.revision_id(+) <> frm.revision_id
                                          and frm.effectivity_date < tom.effectivity_date(+)
                                          and tom.inventory_item_id(+) = frm.inventory_item_id
                                          and tom.organization_id(+) = frm.organization_id
                                      )
                                ) -- end of and for disable date
                            ) -- end of date effective fixed rev parent
                          or
                            (
                                bitt.EFFECTIVITY_CONTROL = 4 -- Revision Effective structure
                             and
                                (   -- check for from end item revision
                                     bitt.FROM_END_ITEM_REVISION IS NOT NULL
                                 and bitt.FROM_END_ITEM_REVISION <=
                                                                (
                                                                  SELECT  mirb.REVISION
                                                                  FROM    MTL_ITEM_REVISIONS_B mirb
                                                                  WHERE   mirb.REVISION_ID = bic.COMPONENT_ITEM_REVISION_ID
                                                                )
                                )
                             and
                                (   -- check for to end item revision
                                    bitt.TO_END_ITEM_REVISION IS NULL
                                 or bitt.TO_END_ITEM_REVISION >=
                                                                (
                                                                  SELECT  mirb.REVISION
                                                                  FROM    MTL_ITEM_REVISIONS_B mirb
                                                                  WHERE   mirb.REVISION_ID = bic.COMPONENT_ITEM_REVISION_ID
                                                                )
                                )
                            ) -- end of rev effective fixed rev parent
                          ) -- end of and fixed rev parent
                      ) -- end of fixed rev parent
                    ) -- end of and fixed/floating rev parent
                and (( c_implemented_only_option = 1
                        and bic.implementation_date is not null)
                            or
                          (( c_implemented_only_option = 2
                  and bic.effectivity_date  in     /*bug 8304937,display both impl and unimpl BOM details */
             (select      effectivity_date         /*bug 8304937,display both impl and unimpl BOM details */
                      from BOM_COMPONENTS_B bic2
                            where bic.bill_sequence_id = bic2.bill_sequence_id
              and (
              (nvl(bic.obj_name,G_EGO_OBJ_NAME) = G_EGO_OBJ_NAME
              and (bic.component_item_id = bic2.component_item_id
                      and nvl(bic.obj_name,G_EGO_OBJ_NAME) = nvl(bic2.obj_name,G_EGO_OBJ_NAME)))
                    or
              (bic.obj_name = G_CAD_OBJ_NAME
                and (bic.pk1_value = bic2.pk1_value
                    and bic.obj_name = bic2.obj_name))
                            )
                          and   NVL(BIC2.ECO_FOR_PRODUCTION,2) = 2
                      and   decode(bic.implementation_date, NULL,
                           decode(bic.old_component_sequence_id,null,
                       bic.component_sequence_id,
                       bic.old_component_sequence_id)
                     ,bic.component_sequence_id) =
                    decode(bic2.implementation_date,NULL,
                     decode(bic2.old_component_sequence_id,null,
                            /* corrected typo for bug 7321827
			    bic2.component_sequence_id,bic.old_component_sequence_id) */
                            bic2.component_sequence_id,bic2.old_component_sequence_id)
                           , bic2.component_sequence_id)
                      and   bic2.effectivity_date <= to_date(c_implosion_date,'YYYY/MM/DD HH24:MI:SS')
              and NOT EXISTS (SELECT null
                                FROM BOM_COMPONENTS_B bic3
                                                WHERE bic3.bill_sequence_id = bic.bill_sequence_id
                    AND   bic3.old_component_sequence_id = bic.component_sequence_id
                                            and NVL(BIC3.ECO_FOR_PRODUCTION,2)= 2
                      AND bic3.acd_type in (2,3)
                    AND bic3.disable_date <=
                  to_date(c_implosion_date,'YYYY/MM/DD HH24:MI:SS')
                  and bic3.implementation_date is not null    /* For bug8304937,display both impl and unimpl BOM details */
                  )
                     and   (bic2.disable_date is null or bic2.disable_date
                  > to_date(c_implosion_date, 'YYYY/MM/DD HH24:MI:SS')
                  or (bic2.disable_date is not null and  bic2.implementation_date is null)  /* For bug8304937,display both impl and unimpl BOM details */
                  )
             )
              ) or BBM.EFFECTIVITY_CONTROL = 4 )  /*Bug 8225025, remove bic.effectivity_date/disable_date,implosion_date comparsion for revision effectivity control BOM*/
              )
        )--end date/revision effectivity
                OR
                (       msi.effectivity_control = 2
                  and   ( bic.DISABLE_DATE IS NULL )
                  and
                   BIC.FROM_END_ITEM_UNIT_NUMBER <= NVL(BITT.TO_END_ITEM_UNIT_NUMBER, BIC.FROM_END_ITEM_UNIT_NUMBER)
                    and
             NVL(BIC.TO_END_ITEM_UNIT_NUMBER, NVL(BITT.FROM_END_ITEM_UNIT_NUMBER,
              BIC.FROM_END_ITEM_UNIT_NUMBER)) >=
             NVL(BITT.FROM_END_ITEM_UNIT_NUMBER, BIC.FROM_END_ITEM_UNIT_NUMBER)
              and  ((c_implemented_only_option=1 and bic.implementation_date is not null)
                             or  c_implemented_only_option = 2)
                    and bic.from_end_item_unit_number <= decode(msi.eam_item_type,1,c_serial_number_to, NVL(c_unit_number_to,bic.from_end_item_unit_number) )
                    and decode(msi.eam_item_type,1,c_serial_number_from,nvl(c_unit_number_from,bic.from_end_item_unit_number)) is not null
                  -- exclude serial eff EAM items
                    and (bic.to_end_item_unit_number is null
                    or bic.to_end_item_unit_number >=
          decode(msi.eam_item_type,1,c_serial_number_from,nvl(c_unit_number_from,bic.from_end_item_unit_number)))
        )
        ) -- end Effectivity Logic
        ) -- end OR
       ) -- end revision filter logic
        ) -- end select
                  ) -- end exists
            ) -- end effectivity for EGO_ITEM
      OR
        (bbm.obj_name = G_CAD_OBJ_NAME)
  ) -- end main query AND
  order by bitt.parent_pk1_value, bitt.parent_pk2_value,bitt.parent_pk3_value,bitt.parent_pk4_value,bitt.parent_pk5_value,
     bbm.assembly_item_id, bic.operation_seq_num;

     TYPE number_tab_tp IS TABLE OF NUMBER
       INDEX BY BINARY_INTEGER;

     TYPE date_tab_tp IS TABLE OF DATE
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_30 IS TABLE OF VARCHAR2(30)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_150 IS TABLE OF VARCHAR2(150)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_10 IS TABLE OF VARCHAR2(10)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_240 IS TABLE OF VARCHAR2(240)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_1 IS TABLE OF VARCHAR2(1)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_4000 IS TABLE OF VARCHAR2(4000)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_25 IS TABLE OF VARCHAR2(25)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_35 IS TABLE OF VARCHAR2(35)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_50 IS TABLE OF VARCHAR2(50)
       INDEX BY BINARY_INTEGER;

     TYPE varchar_tab_3 IS TABLE OF VARCHAR2(3)
       INDEX BY BINARY_INTEGER;

    l_lpk1  varchar_tab_150;
    l_lpk2  varchar_tab_150;
    l_lpk3  varchar_tab_150;
    l_lpk4  varchar_tab_150;
    l_lpk5  varchar_tab_150;
    l_lobj  varchar_tab_30;
    l_ppk1  varchar_tab_150;
    l_ppk2  varchar_tab_150;
    l_ppk3  varchar_tab_150;
    l_ppk4  varchar_tab_150;
    l_ppk5  varchar_tab_150;
    l_pobj  varchar_tab_30;
    l_apk1  varchar_tab_150;
    l_apk2  varchar_tab_150;
    l_apk3  varchar_tab_150;
    l_apk4  varchar_tab_150;
    l_apk5  varchar_tab_150;
    l_aobj  varchar_tab_30;

    l_abd   varchar_tab_10;
    l_sc    varchar_tab_4000;
    l_lad   varchar_tab_10;
    l_cat   number_tab_tp;
    l_csi   number_tab_tp;
    l_oi    number_tab_tp;
    l_osn   number_tab_tp;
    l_ed    date_tab_tp;
    l_dd    date_tab_tp;
    l_fun   varchar_tab_30;
    l_tun   varchar_tab_30;
    l_bt    number_tab_tp;
    l_cq    number_tab_tp;
    l_risd  number_tab_tp;
    l_cn    varchar_tab_10;
    l_impf  number_tab_tp;
    l_str_type number_tab_tp;

    --bug:4204847 Store the component path with each parent
    -- if the loop is found then throw loop_found exception
    l_component_path    varchar_tab_4000;
    l_cur_component_path  VARCHAR2(4000);
    l_cur_component       VARCHAR2(20);
    l_cur_substr          VARCHAR2(20);
    l_start_pos           NUMBER;
    loop_found          EXCEPTION;
    PRAGMA EXCEPTION_INIT(loop_found, -9999);

    --bug:4218468 Component Item Revision Id tables
    l_component_item_revision_id      number_tab_tp;
    l_from_end_item_revision          varchar_tab_3;
    l_to_end_item_revision            varchar_tab_3;
    l_effectivity_control             number_tab_tp;

    Loop_Count_Val      Number := 0;

BEGIN

    SELECT max(MAXIMUM_BOM_LEVEL)
  INTO max_level
  FROM BOM_PARAMETERS
  WHERE ORGANIZATION_ID = org_id;

    IF SQL%NOTFOUND or max_level is null THEN
  max_level   := 60;
    END IF;

    levels_to_implode := a_levels_to_implode;

    IF (levels_to_implode < 0 OR levels_to_implode > max_level) THEN
  levels_to_implode   := max_level;
    END IF;

    cur_level := 0;   /* initialize level */

    WHILE (cur_level < levels_to_implode) LOOP
  Loop_Count_Val      := 0;
  total_rows  := 0;
  cum_count := 0;

--      Delete pl/sql tables.

    l_lpk1.delete;
    l_lpk2.delete;
    l_lpk3.delete;
    l_lpk4.delete;
    l_lpk5.delete;
    l_lobj.delete;
    l_ppk1.delete;
    l_ppk2.delete;
    l_ppk3.delete;
    l_ppk4.delete;
    l_ppk5.delete;
    l_pobj.delete;
    l_apk1.delete;
    l_apk2.delete;
    l_apk3.delete;
    l_apk4.delete;
    l_apk5.delete;
    l_aobj.delete;
                l_abd.delete;
                l_sc.delete;
                l_lad.delete;
                l_cat.delete;
                l_csi.delete;
                l_oi.delete;
                l_osn.delete;
                l_ed.delete;
                l_dd.delete;
                l_fun.delete;
                l_tun.delete;
                l_bt.delete;
                l_cq.delete;
                l_risd.delete;
                l_cn.delete;
                l_impf.delete;
    l_str_type.delete;
    --bug:4204847 Clear the component path tables
    l_component_path.delete;
    --bug:4218468 Clear the component item revision id tables
    l_component_item_revision_id.delete;

    l_from_end_item_revision.delete;
    l_to_end_item_revision.delete;
    l_effectivity_control.delete;


--      Open the Cursor, Fetch and Close for each level

        IF not imploder%isopen then
                open imploder(cur_level,sequence_id,
                eng_mfg_flag, org_id, IMpl_date,
                unit_number_from, unit_number_to,
                serial_number_from, serial_number_to,impl_flag, levels_to_implode);
        end if;
--LOOP
        FETCH imploder bulk collect into
    l_lpk1,
    l_lpk2,
    l_lpk3,
    l_lpk4,
    l_lpk5,
    l_lobj,
    l_ppk1,
    l_ppk2,
    l_ppk3,
    l_ppk4,
    l_ppk5,
    l_pobj,
    l_apk1,
    l_apk2,
    l_apk3,
    l_apk4,
    l_apk5,
    l_aobj,
                l_abd,
                l_sc,
                l_lad,
                l_cat,
                l_csi,
                l_osn,
                l_ed,
                l_dd,
                l_bt,
                l_cq,
                l_risd,
                l_cn,
                l_impf,
                l_oi,
                l_fun,
                l_tun,
        l_str_type,
        l_component_path,
        l_component_item_revision_id ,
        l_from_end_item_revision,
        l_to_end_item_revision,
        l_effectivity_control;
           loop_Count_Val := imploder%rowcount ;

        CLOSE imploder;
--      Loop through the values and check for cursors Check_Configured_Parent
--      and Check_Disabled_Parent. If Record is found then delete that
--      row from the pl/sql table


-- Need to do checkconfigure parent only if obj_nam is EGO.

              For i in 1..loop_Count_Val Loop -- Check Loop
                 Begin
                        total_rows      := total_rows + 1;
                        IF (cur_level = 0) THEN
                                l_LAD(i) := l_ABD(i);
                        END IF;
                        IF (cum_count = 0) THEN
                                prev_parent_item_id     := l_ppk1(i);
                        END IF;

                        IF (prev_parent_item_id <> l_ppk1(i)) THEN
                                cum_count               := 0;
                                prev_parent_item_id     := l_ppk1(i);
                        END IF;

                        cum_count       := cum_count + 1;

                        cat_sort        := lpad(cum_count, 7, '0');
                        l_SC(i) := l_SC(i) || cat_sort;
                        --bug:4204847 Check for loops using component path stored
                        --check for loops by checking if the current parent exist in component path
                        l_cur_component_path := l_component_path(i);

                        IF l_lobj(i) = G_CAD_OBJ_NAME THEN
                          l_cur_component := LPAD('C'||l_apk1(i), 20, '0');
                        ELSE
                          l_cur_component := LPAD('I'||l_apk1(i), 20, '0');
                        END IF;

                        FOR j IN 1..(cur_level+1) LOOP
                          l_start_pos := 1+( (j-1) * 20 );
                          l_cur_substr := SUBSTR( l_cur_component_path, l_start_pos, 20 );
                          IF (l_cur_component = l_cur_substr) THEN
                            --loop found, raise exception
                            RAISE loop_found;
                            EXIT;
                          END IF;
                        END LOOP;

                        --update the component path for current parent
                        l_component_path(i) := l_cur_component || l_component_path(i);
                End;
              End Loop; -- End of Check Loop


--Loop to check if the record exist. If It exist then copy the record into
--an other table and insert the other table.
--This has to be done to avoid "ELEMENT DOES NOT EXIST exception"

-- Insert the Second table values using FORALL.

            FORALL i IN 1..loop_Count_Val
            INSERT INTO BOM_SMALL_IMPL_TEMP
                (LOWEST_ITEM_ID,
                 CURRENT_ITEM_ID,
                 PARENT_ITEM_ID,
     LOWEST_PK1_VALUE,
     LOWEST_PK2_VALUE,
     LOWEST_PK3_VALUE,
     LOWEST_PK4_VALUE,
     LOWEST_PK5_VALUE,
     LOWEST_OBJ_NAME,
                 CURRENT_PK1_VALUE,
                 CURRENT_PK2_VALUE,
                 CURRENT_PK3_VALUE,
                 CURRENT_PK4_VALUE,
                 CURRENT_PK5_VALUE,
     CURRENT_OBJ_NAME,
                 PARENT_PK1_VALUE,
                 PARENT_PK2_VALUE,
                 PARENT_PK3_VALUE,
                 PARENT_PK4_VALUE,
                 PARENT_PK5_VALUE,
     PARENT_OBJ_NAME,
                 ALTERNATE_DESIGNATOR,
                 CURRENT_LEVEL,
                 SORT_CODE,
                 LOWEST_ALTERNATE_DESIGNATOR,
                 CURRENT_ASSEMBLY_TYPE,
                 SEQUENCE_ID,
                 COMPONENT_SEQUENCE_ID,
                 ORGANIZATION_ID,
                 REVISED_ITEM_SEQUENCE_ID,
                 CHANGE_NOTICE,
                 OPERATION_SEQ_NUM,
                 EFFECTIVITY_DATE,
                 DISABLE_DATE,
     FROM_END_ITEM_UNIT_NUMBER,
                 TO_END_ITEM_UNIT_NUMBER,
                 BASIS_TYPE,
                 COMPONENT_QUANTITY,
                 IMPLEMENTED_FLAG,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 PARENT_SORT_CODE,
     IMPLOSION_DATE,
     STRUCTURE_TYPE_ID,
     ACCESS_FLAG,
     COMPONENT_PATH ,
     COMPONENT_ITEM_REVISION_ID,
     FROM_END_ITEM_REVISION,
     TO_END_ITEM_REVISION,
     EFFECTIVITY_CONTROL
     ) VALUES (
                 l_lpk1(i),
                 l_ppk1(i),
                 l_apk1(i),
                 l_lpk1(i),
                 l_lpk2(i),
                 l_lpk3(i),
                 l_lpk4(i),
                 l_lpk5(i),
                 l_lobj(i),
                 l_ppk1(i),
                 l_ppk2(i),
                 l_ppk3(i),
                 l_ppk4(i),
                 l_ppk5(i),
                 l_pobj(i),
                 l_apk1(i),
                 l_apk2(i),
                 l_apk3(i),
                 l_apk4(i),
                 l_apk5(i),
                 l_aobj(i),
                 l_abd(i),
                 cur_level + 1,
                 l_sc(i),
                 l_lad(i),
                 l_cat(i),
                 sequence_id,
                 l_csi(i),
                 l_oi(i),
                 l_risd(i),
                 l_cn(i),
                 l_osn(i),
                 l_ed(i),
                 l_dd(i),
                 l_fun(i),
                 l_tun(i),
                 l_bt(i),
                 l_cq(i),
                 l_impf(i),
                 sysdate,
                  -1,
                 sysdate,
                 -1,
                 decode(length(l_sc(i)), 7,null,substrb(l_sc(i),1,length(l_sc(i))-7)),
     to_date(impl_date, 'YYYY/MM/DD HH24:MI:SS'),
         l_str_type(i),
          --Check_User_View_priv(l_apk1(i),l_apk2(i)),
          'T',
          l_component_path(i) ,
          l_component_item_revision_id(i),
          l_from_end_item_revision(i),
          l_to_end_item_revision(i),
          l_effectivity_control(i)
         );

           IF (total_rows <> 0) THEN
                cur_level       := cur_level + 1;
            ELSE
                goto done_imploding;
            END IF;

        END LOOP;               /* while levels */


<<done_imploding>>

    /* Set the top item flag for which parent item row is not present in bom_small_impl_temp */
    UPDATE BOM_SMALL_IMPL_TEMP bsit_child
    SET
      bsit_child.TOP_ITEM_FLAG = 'Y'
    WHERE
    (
        ( levels_to_implode - 1 = bsit_child.CURRENT_LEVEL )
     OR
      (
        NOT EXISTS
          (
            SELECT 1
            FROM BOM_SMALL_IMPL_TEMP bsit_parent
            WHERE
                bsit_parent.CURRENT_ITEM_ID = bsit_child.PARENT_ITEM_ID
            AND bsit_parent.ORGANIZATION_ID = bsit_child.ORGANIZATION_ID
            AND bsit_parent.CURRENT_LEVEL = (bsit_child.CURRENT_LEVEL + 1)
            AND bsit_parent.SEQUENCE_ID = sequence_id
          )
      )
    )
    AND bsit_child.CURRENT_LEVEL > 0 -- top item page shows parents only
    AND bsit_child.SEQUENCE_ID = sequence_id;

    /* Set the is_excluded_by_rule to 'Y' for parent item from which implosion item is excluded */
    UPDATE BOM_SMALL_IMPL_TEMP bsit_source
    SET IS_EXCLUDED_BY_RULE = 'Y'
    WHERE
        EXISTS
        (
          SELECT
          *
          FROM
            BOM_SMALL_IMPL_TEMP bsit,
            BOM_EXCLUSION_RULE_DEF berd,
            BOM_RULES_B brb
          WHERE
            (
              (
                  berd.FROM_REVISION_ID IS NULL
              OR
                (
                  (
                    SELECT REVISION
                    FROM MTL_ITEM_REVISIONS_B
                    WHERE REVISION_ID = berd.FROM_REVISION_ID
                  ) <=
                      (
                        SELECT
                          mir.REVISION
                        FROM
                          MTL_ITEM_REVISIONS_B mir
                        WHERE
                          mir.EFFECTIVITY_DATE =
                                                (
                                                  SELECT
                                                    MAX(mir1.EFFECTIVITY_DATE)
                                                  FROM
                                                    MTL_ITEM_REVISIONS_B mir1
                                                  WHERE
                                                      mir1.EFFECTIVITY_DATE <= TO_DATE(impl_date, 'YYYY/MM/DD HH24:MI:SS')
                                                  AND mir1.INVENTORY_ITEM_ID = bsit.PARENT_ITEM_ID
                                                  AND mir1.ORGANIZATION_ID   = bsit.ORGANIZATION_ID
                                                )
                        AND mir.INVENTORY_ITEM_ID = bsit.PARENT_ITEM_ID
                        AND mir.ORGANIZATION_ID   = bsit.ORGANIZATION_ID
                      )
                )
              )
            AND
              (
                  berd.TO_REVISION_ID IS NULL
              OR
                (
                  (
                    SELECT
                      mir.REVISION
                    FROM
                      MTL_ITEM_REVISIONS_B mir
                    WHERE
                      mir.EFFECTIVITY_DATE =
                                            (
                                              SELECT
                                                MAX(mir1.EFFECTIVITY_DATE)
                                              FROM
                                                MTL_ITEM_REVISIONS_B mir1
                                              WHERE
                                                  mir1.EFFECTIVITY_DATE <= TO_DATE(impl_date, 'YYYY/MM/DD HH24:MI:SS')
                                              AND mir1.INVENTORY_ITEM_ID = bsit.PARENT_ITEM_ID
                                              AND mir1.ORGANIZATION_ID   = bsit.ORGANIZATION_ID
                                            )
                    AND mir.INVENTORY_ITEM_ID = bsit.PARENT_ITEM_ID
                    AND mir.ORGANIZATION_ID   = bsit.ORGANIZATION_ID
                  ) <=
                      (
                        SELECT REVISION
                        FROM MTL_ITEM_REVISIONS_B
                        WHERE REVISION_ID = berd.TO_REVISION_ID
                      )
                )
              )
            )
          AND
            (
                  berd.IMPLEMENTATION_DATE IS NOT NULL
             AND  berd.DISABLE_DATE IS NULL
            /* Exclusion rule does not have effectivity associated, either it is applied or not applied
            AND   berd.IMPLEMENTATION_DATE <= to_date(impl_date, 'YYYY/MM/DD HH24:MI:SS')
            AND
              (
                  berd.DISABLE_DATE IS NULL
              OR  TO_DATE(impl_date, 'YYYY/MM/DD HH24:MI:SS') <= berd.DISABLE_DATE
              )
             */
            )
          AND berd.ACD_TYPE = 1
          AND bsit.COMPONENT_PATH LIKE berd.EXCLUSION_PATH || '%'
          AND brb.RULE_ID = berd.RULE_ID
          AND brb.BILL_SEQUENCE_ID = (SELECT BILL_SEQUENCE_ID FROM BOM_COMPONENTS_B WHERE COMPONENT_SEQUENCE_ID = bsit.COMPONENT_SEQUENCE_ID)
          AND bsit.COMPONENT_SEQUENCE_ID IS NOT NULL
          AND bsit.ROWID = bsit_source.ROWID
        )
    AND bsit_source.CURRENT_LEVEL > 0
    AND bsit_source.SEQUENCE_ID = sequence_id;

    error_code  := 0;
    err_msg     := '';
/*
** exception handlers
*/
EXCEPTION
    WHEN max_extents THEN
  error_code  := SQLCODE;
  err_msg   := substrb(SQLERRM, 1, 80);
    --bug:4204847 If loop found then pass the current component path to get component loop string
    WHEN loop_found THEN
      error_code  := SQLCODE;
      err_msg     := l_cur_component || l_cur_component_path;
    WHEN OTHERS THEN
        error_code      := SQLCODE;
        err_msg         := substrb(SQLERRM, 1, 80);
END ml_imploder_cad;


/* This is an overloaded procedure that will narrow down the where used to the
 * provided structure type. It will simply call the existing imploder_userexit
 * without regard to structure type and then delete the rows from bom_mall_impl_temp
 * which do not conform to the user entered structure type.
 * One of the out parameters will indicate whether any structures of the reqd.
 * structure_type were found containing this item.
 * Extra parameters:
 *		struct_type       : structure type name
 *		preferred_only    : flag to check indicate only whether
 *		                    implosion should be caried out only
 *				    for preferred structures.
 *				    1 for true/ 2 for false
 *		used_in_structure : Out parameter to indicate if any structures
 *				    of given structure type were found containing
 *				    this item.
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER ,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2,
  pk4_value   IN  VARCHAR2,
  pk5_value   IN  VARCHAR2,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  struct_type             IN  VARCHAR2,
  preferred_only          IN NUMBER DEFAULT 2,
  used_in_structure   OUT NOCOPY VARCHAR2
  )
IS
BEGIN
  imploder_userexit(
                    sequence_id => sequence_id,
                    eng_mfg_flag => eng_mfg_flag,
                    org_id => org_id,
                    impl_flag => impl_flag,
                    display_option => display_option,
                    levels_to_implode => levels_to_implode,
                    obj_name => obj_name,
                    pk1_value => pk1_value,
                    pk2_value => pk2_value,
                    pk3_value => pk3_value,
                    pk4_value => pk4_value,
                    pk5_value => pk5_value,
                    impl_date => impl_date,
                    unit_number_from => unit_number_from,
                    unit_number_to => unit_number_to,
                    err_msg => err_msg,
                    err_code => err_code,
                    organization_option => organization_option,
                    organization_hierarchy => organization_hierarchy,
                    serial_number_from => serial_number_from,
                    serial_number_to => serial_number_to,
                    struct_name => struct_name,
                    struct_type => struct_type,
                    preferred_only => preferred_only,
                    used_in_structure => used_in_structure,
                    revision => NULL
                   );
END imploder_userexit;


/*
 * Overloaded procedure to take revision of component to search in first level
 * parent
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2,
  pk4_value   IN  VARCHAR2,
  pk5_value   IN  VARCHAR2,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  revision                IN  VARCHAR2
  )
  AS
  a_err_msg   VARCHAR2(2000); --bug:4204847 Increasing the length so that component path can be
                              --returned in case of loop
  a_err_code    NUMBER;
  t_org_code_list INV_OrgHierarchy_PVT.OrgID_tbl_type;
  N                   NUMBER:=0;
  dummy               NUMBER;
  l_org_name  VARCHAR2(60);
  item_found    BOOLEAN:=TRUE;

  l_parents_for_pk1 NUMBER := 0;
  l_seq_id NUMBER;
  l_preferred_structure_name VARCHAR2(10);

   l_person VARCHAR2(30);
   l_predicate VARCHAR2(32767);
   l_predicate_api_status VARCHAR2(1);

BEGIN
  --DBMS_PROFILER.START_PROFILER(sequence_id);
  l_seq_id := sequence_id;
  /* If the parameter :
  Organization_Option = 1 then
    Take the current Organization
  else If Organization_Option = 2 is passed then
    Call the Inventory API to get the list of Organizations
    under the current Organization Hierarchy
        else if Organization Option = 3 is passed then
    Find the list of all the Organizations to which
    access is allowed */


  if ( organization_option =2  ) then
         INV_ORGHIERARCHY_PVT.ORG_HIERARCHY_LIST(organization_hierarchy ,
    org_id ,t_org_code_list );

  elsif ( organization_option = 3 ) then

    If (OBJ_NAME = 'EGO_ITEM' OR OBJ_NAME IS NULL) then
    -- bug:4931463 Re-written following query to reduce shared memory.
    for C1 in (
                SELECT
                    orgs.ORGANIZATION_ID
                FROM
                    ORG_ACCESS_VIEW oav,
                    MTL_SYSTEM_ITEMS_B msi,
                    MTL_PARAMETERS orgs,
                    MTL_PARAMETERS child_org
                WHERE
                    orgs.ORGANIZATION_ID = oav.ORGANIZATION_ID
                AND msi.ORGANIZATION_ID = orgs.ORGANIZATION_ID
                AND orgs.MASTER_ORGANIZATION_ID = child_org.MASTER_ORGANIZATION_ID
                AND oav.RESPONSIBILITY_ID = FND_PROFILE.Value('RESP_ID')
                AND oav.RESP_APPLICATION_ID = FND_PROFILE.value('RESP_APPL_ID')
                AND msi.INVENTORY_ITEM_ID = pk1_value
                AND child_org.ORGANIZATION_ID = org_id
              )
    LOOP
      N:=N+1;
      t_org_code_list(N) := C1.organization_id;
    END LOOP;
    end if;
  elsif
    ( organization_option = 1 ) then
    t_org_code_list(1) := org_id;
  end if;

  FOR I in t_org_code_list.FIRST..t_org_code_list.LAST LOOP

  --if ( organization_option = 2 or organization_option = 3 ) THEN
  -- We do not need to check if Item exists for org option 3 as
  -- this is already being done in the above if cond's.

  if ( organization_option = 2 ) THEN

  /*Check the existence of the Item in the curent Organization,
  if found then call the Imploder API for the Organization,otherwise
  check the existence of the Item in the next Organization of the
  Organization List*/

   select count(*)
      into dummy
      from mtl_system_items
      where organization_id = t_org_code_list(I)
      and inventory_item_id = pk1_value;

      if dummy <1 then
          item_found := FALSE;
     end if;
  end if;


  --dbms_output.put_line('trying to insert ');
    --bug:4204847 Store the component path with each parent with respect to item to be imploded.
    --bug:4218468 Store the component revision id to get the revision label in View
       if item_found then
    INSERT INTO BOM_SMALL_IMPL_TEMP
      (SEQUENCE_ID,
      LOWEST_ITEM_ID,
      CURRENT_ITEM_ID,
      PARENT_ITEM_ID,
      ALTERNATE_DESIGNATOR,
      CURRENT_LEVEL,
      SORT_CODE,
      CURRENT_ASSEMBLY_TYPE,
      COMPONENT_SEQUENCE_ID,
      ORGANIZATION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      current_pk1_value,
      current_pk2_value,
      current_pk3_value,
      current_pk4_value,
      current_pk5_value,
      current_obj_name,
      parent_pk1_value,
      parent_pk2_value,
      parent_pk3_value,
      parent_pk4_value,
      parent_pk5_value,
      parent_obj_name,
      lowest_pk1_value,
      lowest_pk2_value,
      lowest_pk3_value,
      lowest_pk4_value,
      lowest_pk5_value,
      lowest_obj_name,
      implosion_date ,
      lowest_gtin_number,
      lowest_gtin_description,
      lowest_trade_item_descriptor,
      current_gtin_number,
      current_gtin_description,
      current_trade_item_descriptor,
      parent_gtin_number,
      parent_gtin_description,
      parent_trade_item_descriptor,
      primary_uom_descriptor,
      GTIN_PUBLICATION_STATUS,
     access_flag,
      COMPONENT_PATH,
      COMPONENT_ITEM_REVISION_ID,
      FROM_END_ITEM_REVISION,
      TO_END_ITEM_REVISION,
      EFFECTIVITY_CONTROL,
      BASIS_TYPE
      ) VALUES (
      sequence_id,
      decode(obj_name,'EGO_ITEM',pk1_value,NULL),
      decode(obj_name,'EGO_ITEM',pk1_value,NULL),
      decode(obj_name,'EGO_ITEM',pk1_value,NULL),
      NULL,
      0,
      '0000001',
      NULL,
      NULL,
      t_org_code_list(I),
      sysdate,
      -1,
      sysdate,
      -1,
      pk1_value,
      decode(obj_name,'EGO_ITEM',t_org_code_list(I),NULL,t_org_code_list(I),pk2_value), --pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      nvl(obj_name,G_EGO_OBJ_NAME),
      pk1_value,
      decode(obj_name,'EGO_ITEM',t_org_code_list(I),NULL,t_org_code_list(I),pk2_value), --pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      nvl(obj_name,G_EGO_OBJ_NAME),
      pk1_value,
      decode(obj_name,'EGO_ITEM',t_org_code_list(I),NULL,t_org_code_list(I),pk2_value), --pk2_value,
      pk3_value,
      pk4_value,
      pk5_value,
      nvl(obj_name,G_EGO_OBJ_NAME),
      to_date(impl_date, 'YYYY/MM/DD HH24:MI:SS'),
      NULL,--l_gtin,
      NULL,--l_gtin_description,
      NULL,--l_gtin_trade_item_descriptor,
      NULL,--l_gtin,
      NULL,--l_gtin_description,
      NULL,--l_gtin_trade_item_descriptor,
      NULL,--l_gtin,
      NULL,--l_gtin_description,
      NULL,--l_gtin_trade_item_descriptor,
      NULL,--l_primary_uom_desc,
      NULL,--l_gtin_publication_status
      Check_User_View_priv(pk1_value,pk2_value)--'T'
      ,lpad( decode(obj_name,G_CAD_OBJ_NAME,'C','I') || pk1_value, 20, '0')
      ,NULL --bug:4218468 For header row, insert NULL
      ,NULL
      ,NULL
      ,NULL
      ,-1 -- set the basis type to -1 for displaying blank value for header row
      );
  bom_imploder_pub.implosion_cad(sequence_id,eng_mfg_flag,t_org_code_list(I),
                impl_flag, display_option, levels_to_implode, impl_date,
                unit_number_from, unit_number_to,
                a_err_msg, a_err_code, serial_number_from, serial_number_to,
                struct_name, revision);

    err_msg   := a_err_msg;
    err_code  := a_err_code;
      end if;
  item_found      := TRUE;

  /*BEGIN
  IF (structure_type_id IS NOT NULL)
  THEN

     SELECT COUNT(COMPONENT_SEQUENCE_ID) INTO l_parents_for_pk1
     from BOM_SMALL_IMPL_TEMP
     WHERE
     LOWEST_ITEM_ID = pk1_value AND ORGANIZATION_ID = t_org_code_list(I)
     AND CURRENT_LEVEL = 1 AND SEQUENCE_ID = l_seq_id;

     BEGIN
       IF (l_parents_for_pk1 = 0)
       THEN
         SELECT ALTERNATE_BOM_DESIGNATOR INTO  l_preferred_structure_name
         FROM BOM_STRUCTURES_B
         WHERE ASSEMBLY_ITEM_ID = pk1_value
               AND ORGANIZATION_ID = pk2_value
               AND STRUCTURE_TYPE_ID = structure_type_id
               AND IS_PREFERRED = 'Y';

         UPDATE BOM_SMALL_IMPL_TEMP
         SET TOP_ITEM_FLAG ='Y',
         ALTERNATE_DESIGNATOR = l_preferred_structure_name,
         STRUCTURE_TYPE_ID = structure_type_id
         WHERE CURRENT_LEVEL = 0 AND SEQUENCE_ID = l_seq_id
         AND LOWEST_ITEM_ID = pk1_value AND ORGANIZATION_ID = t_org_code_list(I) ;

       END IF;
     EXCEPTION
       WHEN OTHERS THEN
         l_preferred_structure_name := NULL;
         ROLLBACK;
     END;
  END IF;
  END;  */

end loop;
 if (a_err_code <> 0) then
     ROLLBACK;
 end if;

    /* Get the security predicate */

    SELECT 'HZ_PARTY'||':'||person_party_id INTO l_person
    FROM fnd_user WHERE user_name = FND_Global.User_Name;

    EGO_DATA_SECURITY.get_security_predicate(
             p_api_version      =>1.0,
             p_function         =>'EGO_VIEW_ITEM',
             p_object_name      =>'EGO_ITEM',
             p_user_name        => l_person,
             p_statement_type   =>'EXISTS',
             p_pk1_alias        =>'BI.PARENT_PK1_VALUE',
             p_pk2_alias        =>'BI.ORGANIZATION_ID',
             p_pk3_alias        =>NULL,
             p_pk4_alias        =>NULL,
             p_pk5_alias        =>NULL,
             x_predicate        => l_predicate,
             x_return_status    => l_predicate_api_status);

    IF l_predicate_api_status <> 'T'
    THEN
      Raise NO_DATA_FOUND;
    END IF;

    IF l_predicate IS NOT NULL
    THEN

      EXECUTE IMMEDIATE 'UPDATE bom_small_impl_temp BI SET BI.access_flag = ''F'' WHERE NOT '|| l_predicate;

    END IF;

  --DBMS_PROFILER.STOP_PROFILER;

    -- R12C: Remove the rows for normal implosion results when the structure name <> 'PIM_PBOM_S'
    -- For packs, below procedure is called. So it will delete the rows.

    IF ( struct_name <> 'PIM_PBOM_S' )
    THEN
      -- Normal implosion without packs
      DELETE
      FROM    BOM_SMALL_IMPL_TEMP
      WHERE
              ALTERNATE_DESIGNATOR = 'PIM_PBOM_S'
      AND     SEQUENCE_ID = sequence_id;

    END IF;


EXCEPTION
WHEN OTHERS THEN
  err_msg   := substrb(SQLERRM, 1, 80);
  err_code  := SQLCODE;
  ROLLBACK;
END imploder_userexit;

/*
 * Overloaded procedure to take revision of component to search in first level
 * parent. This is an overloaded procedure that will narrow down the where used to the
 * provided structure type.
 */
PROCEDURE imploder_userexit(
  sequence_id   IN  NUMBER ,
  eng_mfg_flag    IN  NUMBER,
  org_id      IN  NUMBER,
  impl_flag   IN  NUMBER,
  display_option    IN  NUMBER,
  levels_to_implode IN  NUMBER,
  obj_name    IN  VARCHAR2  DEFAULT 'EGO_ITEM',
  pk1_value   IN  VARCHAR2,
  pk2_value   IN  VARCHAR2,
  pk3_value   IN  VARCHAR2,
  pk4_value   IN  VARCHAR2,
  pk5_value   IN  VARCHAR2,
  impl_date   IN  VARCHAR2,
  unit_number_from      IN  VARCHAR2,
  unit_number_to    IN  VARCHAR2,
  err_msg     OUT NOCOPY VARCHAR2,
  err_code    OUT NOCOPY NUMBER,
  organization_option     IN  NUMBER default 1,
  organization_hierarchy  IN  VARCHAR2 default NULL,
  serial_number_from      IN VARCHAR2 default NULL,
  serial_number_to        IN VARCHAR2 default NULL,
  struct_name             IN  VARCHAR2 DEFAULT FND_LOAD_UTIL.NULL_VALUE,
  struct_type             IN  VARCHAR2,
  preferred_only          IN NUMBER DEFAULT 2,
  used_in_structure   OUT NOCOPY VARCHAR2,
  revision            IN  VARCHAR2
  )
  IS
  l_str_type_id NUMBER;
  l_row_count NUMBER;
  l_sequence_id NUMBER;
  l_structure_count NUMBER := 0;
  l_pk1_value VARCHAR2(100);
  BEGIN
  IF sequence_id is null then
    SELECT BOM_IMPLOSION_TEMP_S.nextval
    INTO l_sequence_id
    FROM SYS.DUAL;
  else
    l_sequence_id := sequence_id;
  end if;
--first populate the temp table.
  imploder_userexit(
  sequence_id    => l_sequence_id   ,
  eng_mfg_flag   => eng_mfg_flag  ,
  org_id      => org_id      ,
  impl_flag    => impl_flag   ,
  display_option => display_option,
  levels_to_implode => levels_to_implode ,
  obj_name => obj_name    ,
  pk1_value => pk1_value   ,
  pk2_value => pk2_value   ,
  pk3_value => pk3_value  ,
  pk4_value => pk4_value   ,
  pk5_value => pk5_value   ,
  impl_date => impl_date   ,
  unit_number_from => unit_number_from ,
  unit_number_to  =>   unit_number_to,
  err_msg => err_msg  ,
  err_code => err_code,
  organization_option => organization_option   ,
  organization_hierarchy => organization_hierarchy ,
  serial_number_from => serial_number_from ,
  serial_number_to => serial_number_to  ,
  struct_name => struct_name,
  revision => revision);

  l_pk1_value := pk1_value;
--Find the structure type id for the struct_type
  select structure_type_id into l_str_type_id
  from bom_structure_types_b
  where structure_type_name = struct_type;

--Delete those records from bom_small_impl_temp
--which do not have the structure type id
--user wants

  IF ( preferred_only = 2) THEN
    DELETE FROM BOM_SMALL_IMPL_TEMP
    WHERE STRUCTURE_TYPE_ID <> l_str_type_id;
  ELSE
  /* Look only for preferred structures */
    DELETE FROM BOM_SMALL_IMPL_TEMP
    WHERE STRUCTURE_TYPE_ID <> l_str_type_id
      OR
      (STRUCTURE_TYPE_ID = l_str_type_id
         AND not exists
         (
	  SELECT 1 from bom_structures_b
	  where assembly_item_id = l_pk1_value
	    and organization_id = org_id
	    and structure_type_id = l_str_type_id
	    and is_preferred = 'Y'
	 )
      );
  END IF;

--Check if any records apart from the item record exist.
  SELECT count(*) into l_row_count
  from bom_small_impl_temp
  where SEQUENCE_ID = l_sequence_id;
--Check if the item itself has a structure header of given str type defined
--Fix for Bug 5943195
--If an item has structure header only without components , then it won't
--be canddidate as part of packaging heirrarchy.

  l_structure_count := 0;
  begin
    SELECT 1 into l_structure_count
    FROM BOM_STRUCTURES_B BST1
    WHERE BST1.ASSEMBLY_ITEM_ID = l_pk1_value
    AND BST1.ORGANIZATION_ID = org_id
    AND BST1.STRUCTURE_TYPE_ID = l_str_type_id
    AND exists
    (
     SELECT 1 FROM  BOM_COMPONENTS_B  CPT1 WHERE CPT1.bill_sequence_id = BST1.bill_sequence_id
     AND CPT1.Disable_date IS NULL
    )
    AND rownum = 1;
  exception when no_data_found then
    l_structure_count := 0;
  end;
  IF l_row_count < 2 AND l_structure_count = 0 THEN
    used_in_structure := 'F';
  ELSE
    used_in_structure := 'T';
  END IF;
END imploder_userexit;

END bom_imploder_pub;

/
