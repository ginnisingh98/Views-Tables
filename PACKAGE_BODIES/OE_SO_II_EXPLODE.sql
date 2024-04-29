--------------------------------------------------------
--  DDL for Package Body OE_SO_II_EXPLODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SO_II_EXPLODE" AS
/* $Header: oesoiitb.pls 115.4 99/07/16 08:28:14 porting ship  $ */

  PROCEDURE Copy_Exploded_BOM (

		P_II_BOM_Explosion_Group_Id	OUT	NUMBER,
		P_II_Session_Id			IN	NUMBER,
		P_II_Inventory_Item_Id		IN	NUMBER,
		P_II_Top_Component_Code		IN	VARCHAR2,
		P_II_Std_Comp_Freeze_Date	IN	DATE,
		P_II_Line_Id			IN	NUMBER,
		P_Result			OUT	VARCHAR2
		) is

	bom_err_message	VARCHAR2(255)	:= NULL;
	bom_error_code	NUMBER		:= NULL;
	org_id 		NUMBER		:= FND_PROFILE.Value('SO_ORGANIZATION_ID');
	bom_group_id    NUMBER		:= NULL;

  begin

	P_Result := 'Y';

	BOMPNORD.BMXPORDER_Explode_For_Order (
		  ORG_ID => org_id
		, COPY_FLAG => 1
		, EXPL_TYPE => 'INCLUDED'
		, ORDER_BY => 2
		, GRP_ID => bom_group_id
		, SESSION_ID => P_II_Session_ID
		, LEVELS_TO_EXPLODE => 60
		, ITEM_ID => P_II_Inventory_Item_Id
		, COMP_CODE => P_II_Top_Component_Code
		, REV_DATE => to_char(nvl(P_II_Std_Comp_Freeze_Date, SYSDATE),
				      'YYYY/MM/DD HH24:MI')
		, USER_ID => To_Number(FND_PROFILE.Value('USER_ID'))
		, ERR_MSG => bom_err_message
		, ERROR_CODE => bom_error_code
		);

	P_II_BOM_Explosion_Group_Id := bom_group_id;

	UPDATE 	bom_config_explosions
	SET	line_id = P_II_Line_Id
	WHERE	session_id = P_II_Session_Id
	AND	group_id + 0 = bom_group_id
	AND	explosion_type = 'INCLUDED'
	AND     component_code <> P_II_Top_Component_Code;

	Return;

  exception
	WHEN OTHERS THEN
		OE_MSG.Internal_Exception('OE_SO_II_EXPLODE.Copy_Exploded_BOM',
					  'Copy_Exploded_BOM', 'INCLUDED_ITEM');
		P_Result := 'N';

  end Copy_Exploded_BOM;



/*
  Does a manual explosion of Included Items into BOM_CONFIG_EXPLOSIONS based on
  what is in SO_LINE_DETAILS.
*/
  PROCEDURE Explode_Manually (
		P_II_BOM_Explosion_Group_Id	IN OUT	NUMBER,
		P_II_Top_Component_Code		IN	VARCHAR2,
		P_II_Session_Id			IN	NUMBER,
		P_II_Line_Id			IN	NUMBER,
		P_Result			OUT	VARCHAR2
		) is

    length_rtrim NUMBER := NULL;

  begin

    P_Result := 'Y';

    P_II_BOM_Explosion_Group_Id := 0;

    Length_Rtrim := length(rtrim(P_II_Top_Component_Code, '0123456789')) + 1;

    if (Length_Rtrim is NULL) then
	Length_Rtrim := 1;
    end if;

/* Modified the select statement for fixing bug# 925562, propagated from
   Rel 11 - 896589. Replaced
    SUBSTR(MIN(component_code), Length_Rtrim),
    by  component_code,
*/

    INSERT INTO bom_config_explosions (
	  line_id,
	  session_id,
	  group_id,
	  component_code,
	  component_item_id,
	  component_quantity,
	  component_sequence_id,
	  extended_quantity,
	  organization_id,
	  primary_uom_code,
	  required_for_revenue,
	  so_transactions_flag,
	  top_bill_sequence_id,
	  bill_sequence_id,
	  plan_level,
	  sort_order,
	  explosion_type,
	  creation_date,
	  created_by	)
    SELECT
	  P_II_Line_Id,
	  P_II_Session_Id,
	  P_II_BOM_Explosion_Group_Id,
--	  SUBSTR(MIN(component_code), Length_Rtrim),
	  component_code,
	  MIN(inventory_item_id),
	  MIN(component_ratio),
	  MIN(component_sequence_id),
	  SUM(quantity),
	  MIN(warehouse_id),
	  MIN(unit_code),
	  MIN(Decode(required_for_revenue_flag, 'Y', 1, 2)),
	  MIN(transactable_flag),
	  0,
	  0,
	  0,
	  '0',
	  'INCLUDED',
	  SYSDATE,
	  0
    FROM so_line_details
    WHERE line_id = P_II_Line_Id
    AND included_item_flag = 'Y'
    GROUP BY component_code;

    Return;

  exception
    WHEN NO_DATA_FOUND THEN
	Return;

    WHEN OTHERS THEN
	OE_MSG.Internal_Exception('OE_SO_II_EXPLODE.Copy_Exploded_BOM',
					  'Copy_Exploded_BOM', 'INCLUDED_ITEM');
	P_Result := 'N';

  end Explode_Manually;


END OE_SO_II_EXPLODE;

/
