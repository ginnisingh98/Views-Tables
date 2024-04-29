--------------------------------------------------------
--  DDL for Package Body BOM_STRUCT_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_STRUCT_SYNC_PUB" AS
/* $Header: BOMSYNCB.pls 120.1 2008/01/09 15:44:29 pgandhik noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMSYNCS.pls
--
--  DESCRIPTION
--
--      Spec for package BOM_STRUCT_SYNC_PUB
--
--  NOTES
--
--  HISTORY
--
--  CREATED on 02-Jan-2008 by PGANDHIK
***************************************************************************/

FUNCTION VALIDATE_ORG_ID
(p_org_id IN NUMBER,
 x_error_message OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
l_return_code NUMBER := 0;
BEGIN
  if (p_org_id is null or p_org_id = '') then
    l_return_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_INVALID_ORGANIZATION');
    FND_MESSAGE.SET_TOKEN('L_ORGANIZATION_ID', p_org_id);
    x_error_message := FND_MESSAGE.GET ;
  end if;
  return l_return_code;
END VALIDATE_ORG_ID;

FUNCTION VALIDATE_ITEM_ID
(p_item_id IN NUMBER,
 p_org_id  IN NUMBER,
 x_error_message OUT NOCOPY VARCHAR2)
RETURN NUMBER
IS
l_return_code NUMBER := 0;
l_orderable_item NUMBER := 0;
BEGIN
  if (p_item_id is null or p_item_id = '') then
    l_return_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_INVALID_ORGANIZATION');
    FND_MESSAGE.SET_TOKEN('L_ORGANIZATION_ID', p_org_id);
    x_error_message := FND_MESSAGE.GET ;
  else
    SELECT
      1
    INTO
      l_orderable_item
    FROM
      MTL_SYSTEM_ITEMS_B
    WHERE
          CUSTOMER_ORDER_FLAG = 'Y'
      AND CUSTOMER_ORDER_ENABLED_FLAG = 'Y'
      AND inventory_item_id = p_item_id
      AND organization_id = p_org_id;
    if (l_orderable_item = 0) then
      l_return_code := 1;
      FND_MESSAGE.SET_NAME('BOM','BOM_NOT_ORDERABLE_TOP_ITEM');
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_item_id);
      x_error_message := FND_MESSAGE.GET ;
    end if;
  end if;
  return l_return_code;
END VALIDATE_ITEM_ID;

PROCEDURE EXPLODE_STRUCTURE
(     p_org_id            IN  NUMBER
  ,   p_item_id           IN  NUMBER
  ,   x_items_count       OUT NOCOPY NUMBER
  ,   x_error_code        OUT NOCOPY NUMBER
  ,   x_error_message     OUT NOCOPY VARCHAR2
)
IS
l_items_count NUMBER := 0;
BEGIN

    if (Validate_Org_ID (
              p_org_id => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;


    if (Validate_Item_ID (
              p_item_id => p_item_id,
              p_org_id  => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;



   /* Call explosions with ALL options and Sysdate as effectivity constraint */
   bom_oe_exploder_pkg.be_exploder (
       arg_org_id               =>     p_org_id
     , arg_starting_rev_date    =>     sysdate
     , arg_expl_type            =>     'ALL'
     , arg_levels_to_explode    =>     60
     , arg_item_id              =>     p_item_id
     , arg_alt_bom_desig        =>     null
     , arg_error_code           =>     x_error_code
     , arg_err_msg              =>     x_error_message);

    select
      count(top_item_id)
    into
      l_items_count
    from
      bom_explosions be
    where
          be.top_item_id       = p_item_id
      and be.organization_id   = p_org_id
      and ( be.customer_order_flag = 'N'
            OR  be.CUSTOMER_ORDER_ENABLED_FLAG = 'N' );

   x_items_count := l_items_count;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
  WHEN OTHERS THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
END EXPLODE_STRUCTURE;

/* this can be removed */
PROCEDURE GET_ITEMS_TO_SYNCH
(     p_org_id            IN NUMBER
  ,   p_item_id           IN NUMBER
  ,   x_Bom               OUT NOCOPY XMLTYPE
  ,   x_error_code        OUT NOCOPY NUMBER
  ,   x_error_message     OUT NOCOPY VARCHAR2
)
IS
p_bom xmlType;
BEGIN

    if (Validate_Org_ID (
              p_org_id => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;

    if (Validate_Item_ID (
              p_item_id => p_item_id,
              p_org_id  => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;



   /* Call explosions with ALL options and Sysdate as effectivity constraint */
   bom_oe_exploder_pkg.be_exploder (
       arg_org_id               =>     p_org_id
     , arg_starting_rev_date    =>     sysdate
     , arg_expl_type            =>     'ALL'
     , arg_levels_to_explode    =>     60
     , arg_item_id              =>     p_item_id
     , arg_alt_bom_desig        =>     null
     , arg_error_code           =>     x_error_code
     , arg_err_msg              =>     x_error_message);


  if (x_error_code <> 0) then
    return;
  end if;


  x_BOM := p_bom;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
  WHEN OTHERS THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
END GET_ITEMS_TO_SYNCH;


PROCEDURE GET_STRUCTURE_PAYLOAD
(     p_org_id            IN NUMBER
  ,   p_item_id           IN NUMBER
  ,   x_Bom               OUT NOCOPY XMLTYPE
  ,   x_error_code        OUT NOCOPY NUMBER
  ,   x_error_message     OUT NOCOPY VARCHAR2
)
IS
p_bom xmlType;
BEGIN

    if (Validate_Org_ID (
              p_org_id => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;

    if (Validate_Item_ID (
              p_item_id => p_item_id,
              p_org_id  => p_org_id,
              x_error_message => x_error_message) = 1) then
      return;
    end if;

    /*Bug 6407303 Added the attribute OPERATING_UNIT_ID */
  SELECT
    XMLElement("db:listOfBillOfMaterial",
    XMLATTRIBUTES ( 'http://xmlns.oracle.com/pcbpel/adapter/db/APPS/BOM_STRUCT_SYNC_PUB/GET_STRUCTURE_PAYLOAD/' AS "xmlns:db"),
               XMLAgg(XMLElement(
                        "db:billOfMaterial",
                        XMLAttributes(comp_bill_seq_id as "BillSequenceId"),
                        XMLForest(component_item_name  as "db:AssemblyName"),
                        XMLForest(nvl(component_item_id, assembly_item_id)  as "db:AssemblyItemId"),
                        XMLForest(OPERATING_UNIT_NAME as "db:OperatingUnit"),
                        XMLForest(ORGANIZATION_CODE as "db:OrganizationCode"),
                        XMLForest(ORGANIZATION_ID  as "db:OrganizationId"),
			XMLForest(OPERATING_UNIT_ID as "db:OperatingUnitId"),
                        (SELECT XMLElement("db:listOfBomComponent",
                                           XMLAgg(XMLElement(
                                                    "db:billOfMaterialComponent",
                                                    XMLAttributes(
                                                      component_item_id as "Id"),
                                                    XMLForest(
                                                      component_sequence_id as "db:ComponentSequenceId",
                                                      component_item_name as "db:ComponentName",
                                                      Component_Quantity as "db:Quantity",
                                                      EFFECTIVITY_DATE as "db:EffectivityDate",
                                                      DISABLE_DATE as "db:DisableDate",
                                                      ORGANIZATION_CODE as "db:OrganizationCode",
                                                      ORGANIZATION_ID as "db:OrganizationId",
						      OPERATING_UNIT_ID as "db:OperatingUnitId"))))
                           FROM bom_structure_sync_v c
                           WHERE c.top_bill_sequence_id=a.top_bill_sequence_id
                           and   c.bill_sequence_id= a.comp_bill_seq_id
                           and   c.top_item_id <> c.component_item_id                                                         and   c.effectivity_date <= sysdate --bug#5891992
                           )))) into p_bom
    FROM bom_structure_sync_v a
    where a.top_item_id = p_item_id
    and a.organization_id = p_org_id
    and a.comp_bill_seq_id is not null
    order by bill_sequence_id;



  x_BOM := p_bom;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
  WHEN OTHERS THEN
    x_error_code := 1;
    FND_MESSAGE.SET_NAME('BOM','BOM_UNEXPECTED_ERROR');
    x_error_message := FND_MESSAGE.GET ;
    x_error_message := x_error_message ||':'||SQLCODE || ':'||SQLERRM;
    return;
END GET_STRUCTURE_PAYLOAD;



END BOM_STRUCT_SYNC_PUB;

/
