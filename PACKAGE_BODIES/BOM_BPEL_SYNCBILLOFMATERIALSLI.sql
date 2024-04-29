--------------------------------------------------------
--  DDL for Package Body BOM_BPEL_SYNCBILLOFMATERIALSLI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_BPEL_SYNCBILLOFMATERIALSLI" AS
/* $Header: BOMAIASB.pls 120.0.12010000.1 2009/06/26 07:00:43 vggarg noship $ */
/****************************************************************************
--
--  Copyright (c) 2008 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMAIASB.pls
--
--  DESCRIPTION
--
--      Body of package  BOM_BPEL_SYNCBILLOFMATERIALSLI
--
--  NOTES
--
--  HISTORY
--
--  02-OCT-2008 Kashif Suleman      Initial Creation
--
****************************************************************************/

  g_org_code VARCHAR2(3) := NULL;
  g_org_id   NUMBER      := NULL;
FUNCTION Get_Org_Code
  (
    P_organization_id IN NUMBER)
  RETURN VARCHAR2
IS
  l_org_code VARCHAR2(3);
BEGIN
  IF g_org_code IS NULL THEN
     SELECT organization_code
       INTO l_org_code
       FROM mtl_parameters
      WHERE organization_id = P_organization_id;
      g_org_code := l_org_code;
  ELSE
    l_org_code := g_org_code;
  END IF;
  RETURN l_org_code;
END;
FUNCTION Get_Org_Id
  (
    P_organization_code IN VARCHAR2)
  RETURN NUMBER
IS
  l_org_id NUMBER;
BEGIN
  IF g_org_id IS NULL THEN
     SELECT organization_id
       INTO l_org_id
       FROM mtl_parameters
      WHERE organization_code = P_organization_code;
      g_org_id := l_org_id;
  ELSE
    l_org_id := g_org_id;
  END IF;
  RETURN l_org_id;
END;
FUNCTION PL_TO_SQL_HEAD_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_HEAD_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_HEAD_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_HEAD_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                           := BOM_BO_PUB_BOM_HEAD_REC_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  aSqlItem.ASSEMBLY_ITEM_NAME        := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.ORGANIZATION_ID           := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ALTERNATE_BOM_CODE        := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.COMMON_ASSEMBLY_ITEM_NAME := aPlsqlItem.COMMON_ASSEMBLY_ITEM_NAME;
  aSqlItem.COMMON_ORGANIZATION_CODE  := aPlsqlItem.COMMON_ORGANIZATION_CODE;
  aSqlItem.ASSEMBLY_COMMENT          := aPlsqlItem.ASSEMBLY_COMMENT;
  aSqlItem.ASSEMBLY_TYPE             := aPlsqlItem.ASSEMBLY_TYPE;
  aSqlItem.TRANSACTION_TYPE          := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.RETURN_STATUS             := aPlsqlItem.RETURN_STATUS;
  aSqlItem.ATTRIBUTE_CATEGORY        := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3                := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4                := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7                := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8                := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10               := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11               := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12               := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13               := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14               := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15               := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.ORIGINAL_SYSTEM_REFERENCE := aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aSqlItem.DELETE_GROUP_NAME         := aPlsqlItem.DELETE_GROUP_NAME;
  aSqlItem.DG_DESCRIPTION            := aPlsqlItem.DG_DESCRIPTION;
  aSqlItem.ROW_IDENTIFIER            := aPlsqlItem.ROW_IDENTIFIER;
  aSqlItem.BOM_IMPLEMENTATION_DATE   := aPlsqlItem.BOM_IMPLEMENTATION_DATE;
  RETURN aSqlItem;
END PL_TO_SQL_HEAD_REC;
FUNCTION SQL_TO_PL_HEAD_REC
  (
    aSqlItem BOM_BO_PUB_BOM_HEAD_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_HEAD_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_HEAD_REC_TYPE;
BEGIN
  aPlsqlItem.ASSEMBLY_ITEM_NAME        := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.ORGANIZATION_CODE         := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ALTERNATE_BOM_CODE        := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.COMMON_ASSEMBLY_ITEM_NAME := aSqlItem.COMMON_ASSEMBLY_ITEM_NAME;
  aPlsqlItem.COMMON_ORGANIZATION_CODE  := aSqlItem.COMMON_ORGANIZATION_CODE;
  aPlsqlItem.ASSEMBLY_COMMENT          := aSqlItem.ASSEMBLY_COMMENT;
  aPlsqlItem.ASSEMBLY_TYPE             := aSqlItem.ASSEMBLY_TYPE;
  aPlsqlItem.TRANSACTION_TYPE          := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.RETURN_STATUS             := aSqlItem.RETURN_STATUS;
  aPlsqlItem.ATTRIBUTE_CATEGORY        := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3                := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4                := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7                := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8                := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10               := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11               := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12               := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13               := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14               := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15               := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE := aSqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aPlsqlItem.DELETE_GROUP_NAME         := aSqlItem.DELETE_GROUP_NAME;
  aPlsqlItem.DG_DESCRIPTION            := aSqlItem.DG_DESCRIPTION;
  aPlsqlItem.ROW_IDENTIFIER            := aSqlItem.ROW_IDENTIFIER;
  aPlsqlItem.BOM_IMPLEMENTATION_DATE   := aSqlItem.BOM_IMPLEMENTATION_DATE;
  RETURN aPlsqlItem;
END SQL_TO_PL_HEAD_REC;
FUNCTION PL_TO_SQL_REV_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_REVISION_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_REV_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_REV_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                           := BOM_BO_PUB_BOM_REV_REC_TYPE(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  aSqlItem.ASSEMBLY_ITEM_NAME        := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.ORGANIZATION_ID           := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.REVISION                  := aPlsqlItem.REVISION;
  aSqlItem.REVISION_LABEL            := aPlsqlItem.REVISION_LABEL;
  aSqlItem.REVISION_REASON           := aPlsqlItem.REVISION_REASON;
  aSqlItem.ALTERNATE_BOM_CODE        := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.DESCRIPTION               := aPlsqlItem.DESCRIPTION;
  aSqlItem.START_EFFECTIVE_DATE      := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.TRANSACTION_TYPE          := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.RETURN_STATUS             := aPlsqlItem.RETURN_STATUS;
  aSqlItem.ATTRIBUTE_CATEGORY        := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3                := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4                := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7                := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8                := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10               := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11               := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12               := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13               := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14               := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15               := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.ORIGINAL_SYSTEM_REFERENCE := aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aSqlItem.ROW_IDENTIFIER            := aPlsqlItem.ROW_IDENTIFIER;
  RETURN aSqlItem;
END PL_TO_SQL_REV_REC;
FUNCTION SQL_TO_PL_REV_REC
  (
    aSqlItem BOM_BO_PUB_BOM_REV_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_REVISION_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_REVISION_REC_TYPE;
BEGIN
  aPlsqlItem.ASSEMBLY_ITEM_NAME        := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.ORGANIZATION_CODE         := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.REVISION                  := aSqlItem.REVISION;
  aPlsqlItem.REVISION_LABEL            := aSqlItem.REVISION_LABEL;
  aPlsqlItem.REVISION_REASON           := aSqlItem.REVISION_REASON;
  aPlsqlItem.ALTERNATE_BOM_CODE        := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.DESCRIPTION               := aSqlItem.DESCRIPTION;
  aPlsqlItem.START_EFFECTIVE_DATE      := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.TRANSACTION_TYPE          := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.RETURN_STATUS             := aSqlItem.RETURN_STATUS;
  aPlsqlItem.ATTRIBUTE_CATEGORY        := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3                := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4                := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7                := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8                := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10               := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11               := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12               := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13               := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14               := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15               := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE := aSqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aPlsqlItem.ROW_IDENTIFIER            := aSqlItem.ROW_IDENTIFIER;
  RETURN aPlsqlItem;
END SQL_TO_PL_REV_REC;
FUNCTION PL_TO_SQL_REV_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_REVISION_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_REV_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_REV_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_REV_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_REV_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_REV_TBL;
FUNCTION SQL_TO_PL_REV_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_REV_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_REVISION_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_REVISION_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_REV_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_REV_TBL;
FUNCTION PL_TO_SQL_COMPS_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_COMPS_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_COMPS_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_COMPS_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                               := BOM_BO_PUB_BOM_COMPS_REC_TYPE(NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL);
  aSqlItem.ORGANIZATION_ID               := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ASSEMBLY_ITEM_NAME            := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.START_EFFECTIVE_DATE          := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.DISABLE_DATE                  := aPlsqlItem.DISABLE_DATE;
  aSqlItem.OPERATION_SEQUENCE_NUMBER     := aPlsqlItem.OPERATION_SEQUENCE_NUMBER;
  aSqlItem.COMPONENT_ITEM_NAME           := aPlsqlItem.COMPONENT_ITEM_NAME;
  aSqlItem.ALTERNATE_BOM_CODE            := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.NEW_EFFECTIVITY_DATE          := aPlsqlItem.NEW_EFFECTIVITY_DATE;
  aSqlItem.NEW_OPERATION_SEQUENCE_NUMBER := aPlsqlItem.NEW_OPERATION_SEQUENCE_NUMBER;
  aSqlItem.ITEM_SEQUENCE_NUMBER          := aPlsqlItem.ITEM_SEQUENCE_NUMBER;
  aSqlItem.QUANTITY_PER_ASSEMBLY         := aPlsqlItem.QUANTITY_PER_ASSEMBLY;
  aSqlItem.PLANNING_PERCENT              := aPlsqlItem.PLANNING_PERCENT;
  aSqlItem.PROJECTED_YIELD               := aPlsqlItem.PROJECTED_YIELD;
  aSqlItem.INCLUDE_IN_COST_ROLLUP        := aPlsqlItem.INCLUDE_IN_COST_ROLLUP;
  aSqlItem.WIP_SUPPLY_TYPE               := aPlsqlItem.WIP_SUPPLY_TYPE;
  aSqlItem.SO_BASIS                      := aPlsqlItem.SO_BASIS;
  aSqlItem.OPTIONAL                      := aPlsqlItem.OPTIONAL;
  aSqlItem.MUTUALLY_EXCLUSIVE            := aPlsqlItem.MUTUALLY_EXCLUSIVE;
  aSqlItem.CHECK_ATP                     := aPlsqlItem.CHECK_ATP;
  aSqlItem.SHIPPING_ALLOWED              := aPlsqlItem.SHIPPING_ALLOWED;
  aSqlItem.REQUIRED_TO_SHIP              := aPlsqlItem.REQUIRED_TO_SHIP;
  aSqlItem.REQUIRED_FOR_REVENUE          := aPlsqlItem.REQUIRED_FOR_REVENUE;
  aSqlItem.INCLUDE_ON_SHIP_DOCS          := aPlsqlItem.INCLUDE_ON_SHIP_DOCS;
  aSqlItem.QUANTITY_RELATED              := aPlsqlItem.QUANTITY_RELATED;
  aSqlItem.SUPPLY_SUBINVENTORY           := aPlsqlItem.SUPPLY_SUBINVENTORY;
  aSqlItem.LOCATION_NAME                 := aPlsqlItem.LOCATION_NAME;
  aSqlItem.MINIMUM_ALLOWED_QUANTITY      := aPlsqlItem.MINIMUM_ALLOWED_QUANTITY;
  aSqlItem.MAXIMUM_ALLOWED_QUANTITY      := aPlsqlItem.MAXIMUM_ALLOWED_QUANTITY;
  aSqlItem.COMMENTS                      := aPlsqlItem.COMMENTS;
  aSqlItem.ATTRIBUTE_CATEGORY            := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                    := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                    := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3                    := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4                    := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                    := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                    := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7                    := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8                    := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                    := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10                   := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11                   := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12                   := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13                   := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14                   := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15                   := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.FROM_END_ITEM_UNIT_NUMBER     := aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aSqlItem.NEW_FROM_END_ITEM_UNIT_NUMBER := aPlsqlItem.NEW_FROM_END_ITEM_UNIT_NUMBER;
  aSqlItem.TO_END_ITEM_UNIT_NUMBER       := aPlsqlItem.TO_END_ITEM_UNIT_NUMBER;
  aSqlItem.RETURN_STATUS                 := aPlsqlItem.RETURN_STATUS;
  aSqlItem.TRANSACTION_TYPE              := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.ORIGINAL_SYSTEM_REFERENCE     := aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aSqlItem.DELETE_GROUP_NAME             := aPlsqlItem.DELETE_GROUP_NAME;
  aSqlItem.DG_DESCRIPTION                := aPlsqlItem.DG_DESCRIPTION;
  aSqlItem.ENFORCE_INT_REQUIREMENTS      := aPlsqlItem.ENFORCE_INT_REQUIREMENTS;
  aSqlItem.AUTO_REQUEST_MATERIAL         := aPlsqlItem.AUTO_REQUEST_MATERIAL;
  aSqlItem.ROW_IDENTIFIER                := aPlsqlItem.ROW_IDENTIFIER;
  aSqlItem.SUGGESTED_VENDOR_NAME         := aPlsqlItem.SUGGESTED_VENDOR_NAME;
  aSqlItem.UNIT_PRICE                    := aPlsqlItem.UNIT_PRICE;
  RETURN aSqlItem;
END PL_TO_SQL_COMPS_REC;
FUNCTION SQL_TO_PL_COMPS_REC
  (
    aSqlItem BOM_BO_PUB_BOM_COMPS_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_COMPS_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_COMPS_REC_TYPE;
BEGIN
  aPlsqlItem.ORGANIZATION_CODE             := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ASSEMBLY_ITEM_NAME            := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.START_EFFECTIVE_DATE          := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.DISABLE_DATE                  := aSqlItem.DISABLE_DATE;
  aPlsqlItem.OPERATION_SEQUENCE_NUMBER     := aSqlItem.OPERATION_SEQUENCE_NUMBER;
  aPlsqlItem.COMPONENT_ITEM_NAME           := aSqlItem.COMPONENT_ITEM_NAME;
  aPlsqlItem.ALTERNATE_BOM_CODE            := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.NEW_EFFECTIVITY_DATE          := aSqlItem.NEW_EFFECTIVITY_DATE;
  aPlsqlItem.NEW_OPERATION_SEQUENCE_NUMBER := aSqlItem.NEW_OPERATION_SEQUENCE_NUMBER;
  aPlsqlItem.ITEM_SEQUENCE_NUMBER          := aSqlItem.ITEM_SEQUENCE_NUMBER;
  aPlsqlItem.QUANTITY_PER_ASSEMBLY         := aSqlItem.QUANTITY_PER_ASSEMBLY;
  aPlsqlItem.PLANNING_PERCENT              := aSqlItem.PLANNING_PERCENT;
  aPlsqlItem.PROJECTED_YIELD               := aSqlItem.PROJECTED_YIELD;
  aPlsqlItem.INCLUDE_IN_COST_ROLLUP        := aSqlItem.INCLUDE_IN_COST_ROLLUP;
  aPlsqlItem.WIP_SUPPLY_TYPE               := aSqlItem.WIP_SUPPLY_TYPE;
  aPlsqlItem.SO_BASIS                      := aSqlItem.SO_BASIS;
  aPlsqlItem.OPTIONAL                      := aSqlItem.OPTIONAL;
  aPlsqlItem.MUTUALLY_EXCLUSIVE            := aSqlItem.MUTUALLY_EXCLUSIVE;
  aPlsqlItem.CHECK_ATP                     := aSqlItem.CHECK_ATP;
  aPlsqlItem.SHIPPING_ALLOWED              := aSqlItem.SHIPPING_ALLOWED;
  aPlsqlItem.REQUIRED_TO_SHIP              := aSqlItem.REQUIRED_TO_SHIP;
  aPlsqlItem.REQUIRED_FOR_REVENUE          := aSqlItem.REQUIRED_FOR_REVENUE;
  aPlsqlItem.INCLUDE_ON_SHIP_DOCS          := aSqlItem.INCLUDE_ON_SHIP_DOCS;
  aPlsqlItem.QUANTITY_RELATED              := aSqlItem.QUANTITY_RELATED;
  aPlsqlItem.SUPPLY_SUBINVENTORY           := aSqlItem.SUPPLY_SUBINVENTORY;
  aPlsqlItem.LOCATION_NAME                 := aSqlItem.LOCATION_NAME;
  aPlsqlItem.MINIMUM_ALLOWED_QUANTITY      := aSqlItem.MINIMUM_ALLOWED_QUANTITY;
  aPlsqlItem.MAXIMUM_ALLOWED_QUANTITY      := aSqlItem.MAXIMUM_ALLOWED_QUANTITY;
  aPlsqlItem.COMMENTS                      := aSqlItem.COMMENTS;
  aPlsqlItem.ATTRIBUTE_CATEGORY            := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                    := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                    := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3                    := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4                    := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                    := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                    := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7                    := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8                    := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                    := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10                   := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11                   := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12                   := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13                   := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14                   := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15                   := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER     := aSqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.NEW_FROM_END_ITEM_UNIT_NUMBER := aSqlItem.NEW_FROM_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.TO_END_ITEM_UNIT_NUMBER       := aSqlItem.TO_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.RETURN_STATUS                 := aSqlItem.RETURN_STATUS;
  aPlsqlItem.TRANSACTION_TYPE              := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE     := aSqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aPlsqlItem.DELETE_GROUP_NAME             := aSqlItem.DELETE_GROUP_NAME;
  aPlsqlItem.DG_DESCRIPTION                := aSqlItem.DG_DESCRIPTION;
  aPlsqlItem.ENFORCE_INT_REQUIREMENTS      := aSqlItem.ENFORCE_INT_REQUIREMENTS;
  aPlsqlItem.AUTO_REQUEST_MATERIAL         := aSqlItem.AUTO_REQUEST_MATERIAL;
  aPlsqlItem.ROW_IDENTIFIER                := aSqlItem.ROW_IDENTIFIER;
  aPlsqlItem.SUGGESTED_VENDOR_NAME         := aSqlItem.SUGGESTED_VENDOR_NAME;
  aPlsqlItem.UNIT_PRICE                    := aSqlItem.UNIT_PRICE;
  RETURN aPlsqlItem;
END SQL_TO_PL_COMPS_REC;
FUNCTION PL_TO_SQL_COMPS_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_COMPS_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_COMPS_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_COMPS_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_COMPS_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_COMPS_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_COMPS_TBL;
FUNCTION SQL_TO_PL_COMPS_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_COMPS_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_COMPS_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_COMPS_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_COMPS_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_COMPS_TBL;
FUNCTION PL_TO_SQL_RF_DES_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_REF_DESIGNATOR_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_RF_DES_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_RF_DES_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                           := BOM_BO_PUB_BOM_RF_DES_REC_TYPE(NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                        NULL, NULL, NULL, NULL, NULL, NULL, NULL);
  aSqlItem.ORGANIZATION_ID           := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ASSEMBLY_ITEM_NAME        := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.START_EFFECTIVE_DATE      := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.OPERATION_SEQUENCE_NUMBER := aPlsqlItem.OPERATION_SEQUENCE_NUMBER;
  aSqlItem.COMPONENT_ITEM_NAME       := aPlsqlItem.COMPONENT_ITEM_NAME;
  aSqlItem.ALTERNATE_BOM_CODE        := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.REFERENCE_DESIGNATOR_NAME := aPlsqlItem.REFERENCE_DESIGNATOR_NAME;
  aSqlItem.REF_DESIGNATOR_COMMENT    := aPlsqlItem.REF_DESIGNATOR_COMMENT;
  aSqlItem.ATTRIBUTE_CATEGORY        := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3                := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4                := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7                := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8                := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10               := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11               := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12               := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13               := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14               := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15               := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.FROM_END_ITEM_UNIT_NUMBER := aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aSqlItem.ORIGINAL_SYSTEM_REFERENCE := aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aSqlItem.NEW_REFERENCE_DESIGNATOR  := aPlsqlItem.NEW_REFERENCE_DESIGNATOR;
  aSqlItem.RETURN_STATUS             := aPlsqlItem.RETURN_STATUS;
  aSqlItem.TRANSACTION_TYPE          := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.ROW_IDENTIFIER            := aPlsqlItem.ROW_IDENTIFIER;
  RETURN aSqlItem;
END PL_TO_SQL_RF_DES_REC;
FUNCTION SQL_TO_PL_RF_DES_REC
  (
    aSqlItem BOM_BO_PUB_BOM_RF_DES_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_REF_DESIGNATOR_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_REF_DESIGNATOR_REC_TYPE;
BEGIN
  aPlsqlItem.ORGANIZATION_CODE         := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ASSEMBLY_ITEM_NAME        := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.START_EFFECTIVE_DATE      := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.OPERATION_SEQUENCE_NUMBER := aSqlItem.OPERATION_SEQUENCE_NUMBER;
  aPlsqlItem.COMPONENT_ITEM_NAME       := aSqlItem.COMPONENT_ITEM_NAME;
  aPlsqlItem.ALTERNATE_BOM_CODE        := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.REFERENCE_DESIGNATOR_NAME := aSqlItem.REFERENCE_DESIGNATOR_NAME;
  aPlsqlItem.REF_DESIGNATOR_COMMENT    := aSqlItem.REF_DESIGNATOR_COMMENT;
  aPlsqlItem.ATTRIBUTE_CATEGORY        := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3                := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4                := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7                := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8                := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10               := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11               := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12               := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13               := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14               := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15               := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER := aSqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE := aSqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aPlsqlItem.NEW_REFERENCE_DESIGNATOR  := aSqlItem.NEW_REFERENCE_DESIGNATOR;
  aPlsqlItem.RETURN_STATUS             := aSqlItem.RETURN_STATUS;
  aPlsqlItem.TRANSACTION_TYPE          := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.ROW_IDENTIFIER            := aSqlItem.ROW_IDENTIFIER;
  RETURN aPlsqlItem;
END SQL_TO_PL_RF_DES_REC;
FUNCTION PL_TO_SQL_RF_DES_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_RF_DES_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_RF_DES_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_RF_DES_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_RF_DES_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_RF_DES_TBL;
FUNCTION SQL_TO_PL_RF_DES_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_RF_DES_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_RF_DES_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_RF_DES_TBL;
FUNCTION PL_TO_SQL_SUB_COMP_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_SUB_COMPONENT_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_SUBCMP_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_SUBCMP_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                               := BOM_BO_PUB_BOM_SUBCMP_REC_TYPE(NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL, NULL, NULL, NULL, NULL, NULL,
                                            NULL);
  aSqlItem.ORGANIZATION_ID               := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ASSEMBLY_ITEM_NAME            := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.START_EFFECTIVE_DATE          := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.OPERATION_SEQUENCE_NUMBER     := aPlsqlItem.OPERATION_SEQUENCE_NUMBER;
  aSqlItem.COMPONENT_ITEM_NAME           := aPlsqlItem.COMPONENT_ITEM_NAME;
  aSqlItem.ALTERNATE_BOM_CODE            := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.SUBSTITUTE_COMPONENT_NAME     := aPlsqlItem.SUBSTITUTE_COMPONENT_NAME;
  aSqlItem.NEW_SUBSTITUTE_COMPONENT_NAME := aPlsqlItem.NEW_SUBSTITUTE_COMPONENT_NAME;
  aSqlItem.SUBSTITUTE_ITEM_QUANTITY      := aPlsqlItem.SUBSTITUTE_ITEM_QUANTITY;
  aSqlItem.ATTRIBUTE_CATEGORY            := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                    := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                    := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE4                    := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                    := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                    := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE8                    := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                    := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10                   := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE12                   := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13                   := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14                   := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15                   := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.PROGRAM_ID                    := aPlsqlItem.PROGRAM_ID;
  aSqlItem.ATTRIBUTE3                    := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE7                    := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE11                   := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.FROM_END_ITEM_UNIT_NUMBER     := aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aSqlItem.ENFORCE_INT_REQUIREMENTS      := aPlsqlItem.ENFORCE_INT_REQUIREMENTS;
  aSqlItem.ORIGINAL_SYSTEM_REFERENCE     := aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aSqlItem.RETURN_STATUS                 := aPlsqlItem.RETURN_STATUS;
  aSqlItem.TRANSACTION_TYPE              := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.ROW_IDENTIFIER                := aPlsqlItem.ROW_IDENTIFIER;
  RETURN aSqlItem;
END PL_TO_SQL_SUB_COMP_REC;
FUNCTION SQL_TO_PL_SUB_COMP_REC
  (
    aSqlItem BOM_BO_PUB_BOM_SUBCMP_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_SUB_COMPONENT_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_SUB_COMPONENT_REC_TYPE;
BEGIN
  aPlsqlItem.ORGANIZATION_CODE             := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ASSEMBLY_ITEM_NAME            := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.START_EFFECTIVE_DATE          := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.OPERATION_SEQUENCE_NUMBER     := aSqlItem.OPERATION_SEQUENCE_NUMBER;
  aPlsqlItem.COMPONENT_ITEM_NAME           := aSqlItem.COMPONENT_ITEM_NAME;
  aPlsqlItem.ALTERNATE_BOM_CODE            := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.SUBSTITUTE_COMPONENT_NAME     := aSqlItem.SUBSTITUTE_COMPONENT_NAME;
  aPlsqlItem.NEW_SUBSTITUTE_COMPONENT_NAME := aSqlItem.NEW_SUBSTITUTE_COMPONENT_NAME;
  aPlsqlItem.SUBSTITUTE_ITEM_QUANTITY      := aSqlItem.SUBSTITUTE_ITEM_QUANTITY;
  aPlsqlItem.ATTRIBUTE_CATEGORY            := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                    := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                    := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE4                    := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                    := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                    := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE8                    := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                    := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10                   := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE12                   := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13                   := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14                   := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15                   := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.PROGRAM_ID                    := aSqlItem.PROGRAM_ID;
  aPlsqlItem.ATTRIBUTE3                    := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE7                    := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE11                   := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER     := aSqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.ENFORCE_INT_REQUIREMENTS      := aSqlItem.ENFORCE_INT_REQUIREMENTS;
  aPlsqlItem.ORIGINAL_SYSTEM_REFERENCE     := aSqlItem.ORIGINAL_SYSTEM_REFERENCE;
  aPlsqlItem.RETURN_STATUS                 := aSqlItem.RETURN_STATUS;
  aPlsqlItem.TRANSACTION_TYPE              := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.ROW_IDENTIFIER                := aSqlItem.ROW_IDENTIFIER;
  RETURN aPlsqlItem;
END SQL_TO_PL_SUB_COMP_REC;
FUNCTION PL_TO_SQL_SUB_COMP_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_SUB_COMP_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_SUB_COMP_TBL;
FUNCTION SQL_TO_PL_SUB_COMP_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_SUB_COMP_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_SUB_COMP_TBL;
FUNCTION PL_TO_SQL_COMP_OPS_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_COMP_OPS_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_COMPOP_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_COMPOP_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                              := BOM_BO_PUB_BOM_COMPOP_REC_TYPE(NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL, NULL, NULL,
                                           NULL, NULL, NULL, NULL);
  aSqlItem.ORGANIZATION_ID              := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ASSEMBLY_ITEM_NAME           := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.START_EFFECTIVE_DATE         := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.FROM_END_ITEM_UNIT_NUMBER    := aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aSqlItem.TO_END_ITEM_UNIT_NUMBER      := aPlsqlItem.TO_END_ITEM_UNIT_NUMBER;
  aSqlItem.OPERATION_SEQUENCE_NUMBER    := aPlsqlItem.OPERATION_SEQUENCE_NUMBER;
  aSqlItem.ADDITIONAL_OPERATION_SEQ_NUM := aPlsqlItem.ADDITIONAL_OPERATION_SEQ_NUM;
  aSqlItem.NEW_ADDITIONAL_OP_SEQ_NUM    := aPlsqlItem.NEW_ADDITIONAL_OP_SEQ_NUM;
  aSqlItem.COMPONENT_ITEM_NAME          := aPlsqlItem.COMPONENT_ITEM_NAME;
  aSqlItem.ALTERNATE_BOM_CODE           := aPlsqlItem.ALTERNATE_BOM_CODE;
  aSqlItem.ATTRIBUTE_CATEGORY           := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1                   := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2                   := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3                   := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4                   := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5                   := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6                   := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7                   := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8                   := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9                   := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10                  := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11                  := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12                  := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13                  := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14                  := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15                  := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.RETURN_STATUS                := aPlsqlItem.RETURN_STATUS;
  aSqlItem.TRANSACTION_TYPE             := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.ROW_IDENTIFIER               := aPlsqlItem.ROW_IDENTIFIER;
  RETURN aSqlItem;
END PL_TO_SQL_COMP_OPS_REC;
FUNCTION SQL_TO_PL_COMP_OPS_REC
  (
    aSqlItem BOM_BO_PUB_BOM_COMPOP_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_COMP_OPS_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_COMP_OPS_REC_TYPE;
BEGIN
  aPlsqlItem.ORGANIZATION_CODE            := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ASSEMBLY_ITEM_NAME           := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.START_EFFECTIVE_DATE         := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.FROM_END_ITEM_UNIT_NUMBER    := aSqlItem.FROM_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.TO_END_ITEM_UNIT_NUMBER      := aSqlItem.TO_END_ITEM_UNIT_NUMBER;
  aPlsqlItem.OPERATION_SEQUENCE_NUMBER    := aSqlItem.OPERATION_SEQUENCE_NUMBER;
  aPlsqlItem.ADDITIONAL_OPERATION_SEQ_NUM := aSqlItem.ADDITIONAL_OPERATION_SEQ_NUM;
  aPlsqlItem.NEW_ADDITIONAL_OP_SEQ_NUM    := aSqlItem.NEW_ADDITIONAL_OP_SEQ_NUM;
  aPlsqlItem.COMPONENT_ITEM_NAME          := aSqlItem.COMPONENT_ITEM_NAME;
  aPlsqlItem.ALTERNATE_BOM_CODE           := aSqlItem.ALTERNATE_BOM_CODE;
  aPlsqlItem.ATTRIBUTE_CATEGORY           := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1                   := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2                   := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3                   := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4                   := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5                   := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6                   := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7                   := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8                   := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9                   := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10                  := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11                  := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12                  := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13                  := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14                  := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15                  := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.RETURN_STATUS                := aSqlItem.RETURN_STATUS;
  aPlsqlItem.TRANSACTION_TYPE             := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.ROW_IDENTIFIER               := aSqlItem.ROW_IDENTIFIER;
  RETURN aPlsqlItem;
END SQL_TO_PL_COMP_OPS_REC;
FUNCTION PL_TO_SQL_COMP_OPS_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_COMPOP_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_COMPOP_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_COMPOP_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_COMP_OPS_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_COMP_OPS_TBL;
FUNCTION SQL_TO_PL_COMP_OPS_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_COMPOP_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_COMP_OPS_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_COMP_OPS_TBL;
FUNCTION PL_TO_SQL_PROD_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_PROD_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_PROD_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                    := BOM_BO_PUB_BOM_PROD_REC_TYPE(NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                 NULL, NULL, NULL, NULL);
  aSqlItem.ASSEMBLY_ITEM_NAME := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.ORGANIZATION_ID    := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.ATTRIBUTE_CATEGORY := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1         := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2         := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3         := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4         := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5         := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6         := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7         := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8         := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9         := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10        := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11        := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12        := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13        := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14        := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15        := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.DELETE_GROUP_NAME  := aPlsqlItem.DELETE_GROUP_NAME;
  aSqlItem.DG_DESCRIPTION     := aPlsqlItem.DG_DESCRIPTION;
  aSqlItem.ROW_IDENTIFIER     := aPlsqlItem.ROW_IDENTIFIER;
  aSqlItem.TRANSACTION_TYPE   := aPlsqlItem.TRANSACTION_TYPE;
  aSqlItem.RETURN_STATUS      := aPlsqlItem.RETURN_STATUS;
  RETURN aSqlItem;
END PL_TO_SQL_PROD_REC;
FUNCTION SQL_TO_PL_PROD_REC
  (
    aSqlItem BOM_BO_PUB_BOM_PROD_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_PRODUCT_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_REC_TYPE;
BEGIN
  aPlsqlItem.ASSEMBLY_ITEM_NAME := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.ORGANIZATION_CODE  := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.ATTRIBUTE_CATEGORY := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1         := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2         := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3         := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4         := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5         := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6         := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7         := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8         := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9         := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10        := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11        := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12        := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13        := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14        := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15        := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.DELETE_GROUP_NAME  := aSqlItem.DELETE_GROUP_NAME;
  aPlsqlItem.DG_DESCRIPTION     := aSqlItem.DG_DESCRIPTION;
  aPlsqlItem.ROW_IDENTIFIER     := aSqlItem.ROW_IDENTIFIER;
  aPlsqlItem.TRANSACTION_TYPE   := aSqlItem.TRANSACTION_TYPE;
  aPlsqlItem.RETURN_STATUS      := aSqlItem.RETURN_STATUS;
  RETURN aPlsqlItem;
END SQL_TO_PL_PROD_REC;
FUNCTION PL_TO_SQL_PROD_MEM_REC
  (
    aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_MEMBER_REC_TYPE)
  RETURN BOM_BO_PUB_BOM_PRDMEM_REC_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_PRDMEM_REC_TYPE;
BEGIN
  -- initialize the object
  aSqlItem                      := BOM_BO_PUB_BOM_PRDMEM_REC_TYPE(NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                   NULL, NULL, NULL, NULL, NULL, NULL);
  aSqlItem.ASSEMBLY_ITEM_NAME   := aPlsqlItem.ASSEMBLY_ITEM_NAME;
  aSqlItem.ORGANIZATION_ID      := Get_Org_Id(aPlsqlItem.ORGANIZATION_CODE);
  aSqlItem.COMPONENT_ITEM_NAME  := aPlsqlItem.COMPONENT_ITEM_NAME;
  aSqlItem.PLANNING_PERCENT     := aPlsqlItem.PLANNING_PERCENT;
  aSqlItem.OLD_EFFECTIVITY_DATE := aPlsqlItem.OLD_EFFECTIVITY_DATE;
  aSqlItem.START_EFFECTIVE_DATE := aPlsqlItem.START_EFFECTIVE_DATE;
  aSqlItem.NEW_EFFECTIVITY_DATE := aPlsqlItem.NEW_EFFECTIVITY_DATE;
  aSqlItem.DISABLE_DATE         := aPlsqlItem.DISABLE_DATE;
  aSqlItem.COMMENTS             := aPlsqlItem.COMMENTS;
  aSqlItem.ATTRIBUTE_CATEGORY   := aPlsqlItem.ATTRIBUTE_CATEGORY;
  aSqlItem.ATTRIBUTE1           := aPlsqlItem.ATTRIBUTE1;
  aSqlItem.ATTRIBUTE2           := aPlsqlItem.ATTRIBUTE2;
  aSqlItem.ATTRIBUTE3           := aPlsqlItem.ATTRIBUTE3;
  aSqlItem.ATTRIBUTE4           := aPlsqlItem.ATTRIBUTE4;
  aSqlItem.ATTRIBUTE5           := aPlsqlItem.ATTRIBUTE5;
  aSqlItem.ATTRIBUTE6           := aPlsqlItem.ATTRIBUTE6;
  aSqlItem.ATTRIBUTE7           := aPlsqlItem.ATTRIBUTE7;
  aSqlItem.ATTRIBUTE8           := aPlsqlItem.ATTRIBUTE8;
  aSqlItem.ATTRIBUTE9           := aPlsqlItem.ATTRIBUTE9;
  aSqlItem.ATTRIBUTE10          := aPlsqlItem.ATTRIBUTE10;
  aSqlItem.ATTRIBUTE11          := aPlsqlItem.ATTRIBUTE11;
  aSqlItem.ATTRIBUTE12          := aPlsqlItem.ATTRIBUTE12;
  aSqlItem.ATTRIBUTE13          := aPlsqlItem.ATTRIBUTE13;
  aSqlItem.ATTRIBUTE14          := aPlsqlItem.ATTRIBUTE14;
  aSqlItem.ATTRIBUTE15          := aPlsqlItem.ATTRIBUTE15;
  aSqlItem.DELETE_GROUP_NAME    := aPlsqlItem.DELETE_GROUP_NAME;
  aSqlItem.DG_DESCRIPTION       := aPlsqlItem.DG_DESCRIPTION;
  aSqlItem.RETURN_STATUS        := aPlsqlItem.RETURN_STATUS;
  aSqlItem.TRANSACTION_TYPE     := aPlsqlItem.TRANSACTION_TYPE;
  RETURN aSqlItem;
END PL_TO_SQL_PROD_MEM_REC;
FUNCTION SQL_TO_PL_PROD_MEM_REC
  (
    aSqlItem BOM_BO_PUB_BOM_PRDMEM_REC_TYPE)
  RETURN BOM_BO_PUB.BOM_PRODUCT_MEMBER_REC_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_MEMBER_REC_TYPE;
BEGIN
  aPlsqlItem.ASSEMBLY_ITEM_NAME   := aSqlItem.ASSEMBLY_ITEM_NAME;
  aPlsqlItem.ORGANIZATION_CODE    := Get_Org_Code(aSqlItem.ORGANIZATION_ID);
  aPlsqlItem.COMPONENT_ITEM_NAME  := aSqlItem.COMPONENT_ITEM_NAME;
  aPlsqlItem.PLANNING_PERCENT     := aSqlItem.PLANNING_PERCENT;
  aPlsqlItem.OLD_EFFECTIVITY_DATE := aSqlItem.OLD_EFFECTIVITY_DATE;
  aPlsqlItem.START_EFFECTIVE_DATE := aSqlItem.START_EFFECTIVE_DATE;
  aPlsqlItem.NEW_EFFECTIVITY_DATE := aSqlItem.NEW_EFFECTIVITY_DATE;
  aPlsqlItem.DISABLE_DATE         := aSqlItem.DISABLE_DATE;
  aPlsqlItem.COMMENTS             := aSqlItem.COMMENTS;
  aPlsqlItem.ATTRIBUTE_CATEGORY   := aSqlItem.ATTRIBUTE_CATEGORY;
  aPlsqlItem.ATTRIBUTE1           := aSqlItem.ATTRIBUTE1;
  aPlsqlItem.ATTRIBUTE2           := aSqlItem.ATTRIBUTE2;
  aPlsqlItem.ATTRIBUTE3           := aSqlItem.ATTRIBUTE3;
  aPlsqlItem.ATTRIBUTE4           := aSqlItem.ATTRIBUTE4;
  aPlsqlItem.ATTRIBUTE5           := aSqlItem.ATTRIBUTE5;
  aPlsqlItem.ATTRIBUTE6           := aSqlItem.ATTRIBUTE6;
  aPlsqlItem.ATTRIBUTE7           := aSqlItem.ATTRIBUTE7;
  aPlsqlItem.ATTRIBUTE8           := aSqlItem.ATTRIBUTE8;
  aPlsqlItem.ATTRIBUTE9           := aSqlItem.ATTRIBUTE9;
  aPlsqlItem.ATTRIBUTE10          := aSqlItem.ATTRIBUTE10;
  aPlsqlItem.ATTRIBUTE11          := aSqlItem.ATTRIBUTE11;
  aPlsqlItem.ATTRIBUTE12          := aSqlItem.ATTRIBUTE12;
  aPlsqlItem.ATTRIBUTE13          := aSqlItem.ATTRIBUTE13;
  aPlsqlItem.ATTRIBUTE14          := aSqlItem.ATTRIBUTE14;
  aPlsqlItem.ATTRIBUTE15          := aSqlItem.ATTRIBUTE15;
  aPlsqlItem.DELETE_GROUP_NAME    := aSqlItem.DELETE_GROUP_NAME;
  aPlsqlItem.DG_DESCRIPTION       := aSqlItem.DG_DESCRIPTION;
  aPlsqlItem.RETURN_STATUS        := aSqlItem.RETURN_STATUS;
  aPlsqlItem.TRANSACTION_TYPE     := aSqlItem.TRANSACTION_TYPE;
  RETURN aPlsqlItem;
END SQL_TO_PL_PROD_MEM_REC;
FUNCTION PL_TO_SQL_PROD_MEM_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_MEM_TAB_TYPE)
  RETURN BOM_BO_PUB_BOM_PRDMEM_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_PRDMEM_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_PRDMEM_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_PROD_MEM_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_PROD_MEM_TBL;
FUNCTION SQL_TO_PL_PROD_MEM_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_PRDMEM_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_PRODUCT_MEM_TAB_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_PRODUCT_MEM_TAB_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_PROD_MEM_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_PROD_MEM_TBL;
FUNCTION PL_TO_SQL_HEADER_TBL
  (
    aPlsqlItem BOM_BO_PUB.BOM_HEADER_TBL_TYPE)
  RETURN BOM_BO_PUB_BOM_HEADER_TBL_TYPE
IS
  aSqlItem BOM_BO_PUB_BOM_HEADER_TBL_TYPE;
BEGIN
  -- initialize the table
  aSqlItem           := BOM_BO_PUB_BOM_HEADER_TBL_TYPE();
  IF aPlsqlItem.COUNT > 0 THEN
    aSqlItem.EXTEND(aPlsqlItem.COUNT);
    FOR I IN aPlsqlItem.FIRST..aPlsqlItem.LAST
    LOOP
      aSqlItem(I + 1 - aPlsqlItem.FIRST) := PL_TO_SQL_HEAD_REC(aPlsqlItem(I));
    END LOOP;
  END IF;
  RETURN aSqlItem;
END PL_TO_SQL_HEADER_TBL;
FUNCTION SQL_TO_PL_HEADER_TBL
  (
    aSqlItem BOM_BO_PUB_BOM_HEADER_TBL_TYPE)
  RETURN BOM_BO_PUB.BOM_HEADER_TBL_TYPE
IS
  aPlsqlItem BOM_BO_PUB.BOM_HEADER_TBL_TYPE;
BEGIN
  FOR I IN 1..aSqlItem.COUNT
  LOOP
    aPlsqlItem(I) := SQL_TO_PL_HEAD_REC(aSqlItem(I));
  END LOOP;
  RETURN aPlsqlItem;
END SQL_TO_PL_HEADER_TBL;
PROCEDURE BOM_BO_PUB$PROCESS_BOM
  (
    P_BO_IDENTIFIER      VARCHAR2,
    P_API_VERSION_NUMBER NUMBER,
    P_INIT_MSG_LIST      INTEGER,
    P_BOM_HEADER_TBL BOM_BO_PUB_BOM_HEADER_TBL_TYPE,
    P_BOM_REVISION_TBL BOM_BO_PUB_BOM_REV_TBL_TYPE,
    P_BOM_COMPONENT_TBL BOM_BO_PUB_BOM_COMPS_TBL_TYPE,
    P_BOM_REF_DESIGNATOR_TBL BOM_BO_PUB_BOM_RF_DES_TBL_TYPE,
    P_BOM_SUB_COMPONENT_TBL BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE,
    P_BOM_COMP_OPS_TBL BOM_BO_PUB_BOM_COMPOP_TBL_TYPE,
    X_BOM_HEADER_TBL         IN OUT NOCOPY BOM_BO_PUB_BOM_HEADER_TBL_TYPE,
    X_BOM_REVISION_TBL       IN OUT NOCOPY BOM_BO_PUB_BOM_REV_TBL_TYPE,
    X_BOM_COMPONENT_TBL      IN OUT NOCOPY BOM_BO_PUB_BOM_COMPS_TBL_TYPE,
    X_BOM_REF_DESIGNATOR_TBL IN OUT NOCOPY BOM_BO_PUB_BOM_RF_DES_TBL_TYPE,
    X_BOM_SUB_COMPONENT_TBL  IN OUT NOCOPY BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE,
    X_BOM_COMP_OPS_TBL       IN OUT NOCOPY BOM_BO_PUB_BOM_COMPOP_TBL_TYPE,
    X_RETURN_STATUS          IN OUT NOCOPY VARCHAR2,
    X_MSG_COUNT              IN OUT NOCOPY NUMBER,
    X_ERROR_MESSAGE          IN OUT NOCOPY VARCHAR2,
    P_DEBUG          VARCHAR2,
    P_OUTPUT_DIR     VARCHAR2,
    P_DEBUG_FILENAME VARCHAR2)
IS
  P_INIT_MSG_LIST_ BOOLEAN;
  P_BOM_HEADER_TBL_ APPS.BOM_BO_PUB.BOM_HEADER_TBL_TYPE                 := APPS.Bom_Bo_Pub.G_MISS_BOM_HEADER_TBL;
  P_BOM_REVISION_TBL_ APPS.BOM_BO_PUB.BOM_REVISION_TBL_TYPE             := APPS.Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL;
  P_BOM_COMPONENT_TBL_ APPS.BOM_BO_PUB.BOM_COMPS_TBL_TYPE               := APPS.Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL;
  P_BOM_REF_DESIGNATOR_TBL_ APPS.BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE := APPS.Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL;
  P_BOM_SUB_COMPONENT_TBL_ APPS.BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE   := APPS.Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL;
  P_BOM_COMP_OPS_TBL_ APPS.BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE             := APPS.Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL;
  X_BOM_HEADER_TBL_ APPS.BOM_BO_PUB.BOM_HEADER_TBL_TYPE;
  X_BOM_REVISION_TBL_ APPS.BOM_BO_PUB.BOM_REVISION_TBL_TYPE;
  X_BOM_COMPONENT_TBL_ APPS.BOM_BO_PUB.BOM_COMPS_TBL_TYPE;
  X_BOM_REF_DESIGNATOR_TBL_ APPS.BOM_BO_PUB.BOM_REF_DESIGNATOR_TBL_TYPE;
  X_BOM_SUB_COMPONENT_TBL_ APPS.BOM_BO_PUB.BOM_SUB_COMPONENT_TBL_TYPE;
  X_BOM_COMP_OPS_TBL_ APPS.BOM_BO_PUB.BOM_COMP_OPS_TBL_TYPE;
  L_ERROR_MESSAGE_LIST ERROR_HANDLER.ERROR_TBL_TYPE;
  L_ERROR_MESSAGE VARCHAR2(4000);
BEGIN
  Error_Handler.Initialize;

  P_INIT_MSG_LIST_          := SYS.SQLJUTL.INT2BOOL(P_INIT_MSG_LIST);
  P_BOM_HEADER_TBL_         := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_HEADER_TBL(P_BOM_HEADER_TBL);
  P_BOM_REVISION_TBL_       := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_REV_TBL(P_BOM_REVISION_TBL);
  P_BOM_COMPONENT_TBL_      := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_COMPS_TBL(P_BOM_COMPONENT_TBL);
  P_BOM_REF_DESIGNATOR_TBL_ := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_RF_DES_TBL(P_BOM_REF_DESIGNATOR_TBL);
  P_BOM_SUB_COMPONENT_TBL_  := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_SUB_COMP_TBL(P_BOM_SUB_COMPONENT_TBL);
  P_BOM_COMP_OPS_TBL_       := BOM_BPEL_SYNCBILLOFMATERIALSLI.SQL_TO_PL_COMP_OPS_TBL(P_BOM_COMP_OPS_TBL);
  APPS.BOM_BO_PUB.PROCESS_BOM(P_BO_IDENTIFIER, P_API_VERSION_NUMBER, P_INIT_MSG_LIST_,
                              P_BOM_HEADER_TBL_, P_BOM_REVISION_TBL_, P_BOM_COMPONENT_TBL_,
                              P_BOM_REF_DESIGNATOR_TBL_, P_BOM_SUB_COMPONENT_TBL_, P_BOM_COMP_OPS_TBL_,
                              X_BOM_HEADER_TBL_, X_BOM_REVISION_TBL_, X_BOM_COMPONENT_TBL_,
                              X_BOM_REF_DESIGNATOR_TBL_, X_BOM_SUB_COMPONENT_TBL_, X_BOM_COMP_OPS_TBL_,
                              X_RETURN_STATUS, X_MSG_COUNT, P_DEBUG, P_OUTPUT_DIR, P_DEBUG_FILENAME);

  Error_Handler.Get_message_list(L_ERROR_MESSAGE_LIST);

  FOR i IN 1..x_msg_count
  LOOP
    L_ERROR_MESSAGE := L_ERROR_MESSAGE||l_error_message_list(i).message_text;
  END LOOP;

  g_org_id                 := NULL;
  g_org_code               := NULL;
  X_ERROR_MESSAGE          := L_ERROR_MESSAGE;
  X_BOM_HEADER_TBL         := BOM_BO_PUB_BOM_HEADER_TBL_TYPE();
  X_BOM_REVISION_TBL       := BOM_BO_PUB_BOM_REV_TBL_TYPE();
  X_BOM_COMPONENT_TBL      := BOM_BO_PUB_BOM_COMPS_TBL_TYPE();
  X_BOM_REF_DESIGNATOR_TBL := BOM_BO_PUB_BOM_RF_DES_TBL_TYPE();
  X_BOM_SUB_COMPONENT_TBL  := BOM_BO_PUB_BOM_SUBCMP_TBL_TYPE();
  X_BOM_COMP_OPS_TBL       := BOM_BO_PUB_BOM_COMPOP_TBL_TYPE();
  X_BOM_HEADER_TBL         := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_HEADER_TBL(X_BOM_HEADER_TBL_);
  X_BOM_REVISION_TBL       := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_REV_TBL(X_BOM_REVISION_TBL_);
  X_BOM_COMPONENT_TBL      := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_COMPS_TBL(X_BOM_COMPONENT_TBL_);
  X_BOM_REF_DESIGNATOR_TBL := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_RF_DES_TBL(X_BOM_REF_DESIGNATOR_TBL_);
  X_BOM_SUB_COMPONENT_TBL  := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_SUB_COMP_TBL(X_BOM_SUB_COMPONENT_TBL_);
  X_BOM_COMP_OPS_TBL       := BOM_BPEL_SYNCBILLOFMATERIALSLI.PL_TO_SQL_COMP_OPS_TBL(X_BOM_COMP_OPS_TBL_);
END BOM_BO_PUB$PROCESS_BOM;




END BOM_BPEL_SYNCBILLOFMATERIALSLI;

/
