--------------------------------------------------------
--  DDL for Package Body BOM_TA_EXCLUSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_TA_EXCLUSIONS_PVT" AS
/* $Header: BOMVTAXB.pls 120.0.12010000.1 2009/03/17 22:46:21 kkonada noship $ */

PROCEDURE Delete_Item_TA_Exclusions (p_del_comp_seq NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2) IS
l_bill_seq_id   NUMBER;
l_comp_item_id Number;

CURSOR C_bic(p_comp_seq_id Number) IS
  SELECT bill_sequence_id,component_item_id
    FROM bom_inventory_components
   WHERE component_sequence_id = p_del_comp_seq;

BEGIN

  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  FOR c_comp_level IN C_bic(p_del_comp_seq) LOOP
    l_bill_seq_id := c_comp_level.bill_sequence_id;
    l_comp_item_id := c_comp_level.component_item_id;
  END LOOP;

 DELETE FROM BOM_TA_VAL_EXCLUSION_DEF_B
      WHERE EXCLUSION_RULE_ID IN
      (SELECT EXCLUSION_RULE_ID FROM BOM_TA_VAL_EXCLUSION_RULES_B
       WHERE COMPONENT_ITEM_ID = l_comp_item_id
       AND PARENT_BILL_SEQ_ID = l_bill_seq_id
       AND 1 = (SELECT COUNT(*)
               FROM BOM_INVENTORY_COMPONENTS
	       WHERE  COMPONENT_ITEM_ID = l_comp_item_id
	       AND BILL_SEQUENCE_ID = l_bill_seq_id)
      );


DELETE FROM BOM_TA_VAL_EXCLUSION_RULES_B
      WHERE EXCLUSION_RULE_ID IN
      (SELECT EXCLUSION_RULE_ID FROM BOM_TA_VAL_EXCLUSION_RULES_B
       WHERE COMPONENT_ITEM_ID = l_comp_item_id
       AND PARENT_BILL_SEQ_ID = l_bill_seq_id
       AND 1 = (SELECT COUNT(*)
               FROM BOM_INVENTORY_COMPONENTS
	       WHERE  COMPONENT_ITEM_ID = l_comp_item_id
	       AND BILL_SEQUENCE_ID = l_bill_seq_id)
      );



EXCEPTION WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Delete_Item_TA_Exclusions;



END BOM_TA_EXCLUSIONS_PVT;


/
