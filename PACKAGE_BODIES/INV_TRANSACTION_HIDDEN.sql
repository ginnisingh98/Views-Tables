--------------------------------------------------------
--  DDL for Package Body INV_TRANSACTION_HIDDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TRANSACTION_HIDDEN" AS
/* $Header: INVMWAHB.pls 120.1 2005/07/01 12:38:40 appldev ship $ */





FUNCTION IS_SERIAL_HIDDEN(p_Serial_Number_Control_Code IN NUMBER)
			RETURN VARCHAR2
IS
BEGIN

IF p_Serial_Number_Control_Code = 2 OR p_Serial_Number_Control_Code = 5 THEN

	RETURN 'F';
ELSE
	RETURN 'T';

END IF;
END IS_SERIAL_HIDDEN;



FUNCTION IS_SER_TRIG_ISSUE(p_Transaction_Action_Id IN NUMBER,
			   p_Serial_Number_Control_Code IN NUMBER)
			RETURN VARCHAR2
IS

BEGIN

IF p_Transaction_Action_Id = 1 OR p_Transaction_Action_Id = 2 OR p_Transaction_Action_Id = 3 THEN

	IF p_Serial_Number_Control_Code = 2 OR p_Serial_Number_Control_Code = 5 THEN

		RETURN 'T';
	ELSE
		RETURN 'F';
	END IF;

ELSE
	RETURN 'F';
END IF;

END IS_SER_TRIG_ISSUE;


FUNCTION IS_ACCT_HIDDEN(p_Transaction_Source_Type_Id IN NUMBER,
			p_Transaction_Action_Id IN NUMBER)
				RETURN VARCHAR2
IS
l_return VARCHAR2(1);
BEGIN
	IF p_Transaction_Action_Id = 2 OR p_Transaction_Action_Id = 3 THEN
		RETURN 'T';
	ELSE

		IF p_Transaction_Source_Type_Id = 6 THEN
			l_return := 'T';
		ELSE
			l_return := 'F';
		END IF;
	END IF;
return l_return;
END IS_ACCT_HIDDEN;



FUNCTION IS_ACCT_ALIAS_HIDDEN(p_Transaction_Source_Type_Id IN NUMBER,
			      p_Transaction_Action_Id IN NUMBER)
					RETURN VARCHAR2

IS
l_return VARCHAR2(1);
BEGIN

IF p_Transaction_Action_Id = 2 OR p_Transaction_Action_Id = 3 THEN
	RETURN 'T';
ELSE
	IF p_Transaction_Source_Type_Id = 13 THEN
		l_return := 'T';

	ELSE
		l_return := 'F';

	END IF;
END IF;
return l_return;
END IS_ACCT_ALIAS_HIDDEN;



FUNCTION IS_SUB_HIDDEN(p_Transaction_Action_Id IN NUMBER,
		       p_Serial_Number_Control_Code IN NUMBER)
			RETURN VARCHAR2

IS
l_return VARCHAR2(1);
BEGIN

l_return := IS_SER_TRIG_ISSUE(p_Transaction_Action_Id,
			      p_Serial_Number_Control_Code);

RETURN l_return;

END IS_SUB_HIDDEN;





FUNCTION IS_LOCATOR_HIDDEN(p_Location_Control_Code IN NUMBER,
			   p_Organization_Id IN NUMBER,
			   p_Subinventory_Code IN VARCHAR2)
			   RETURN VARCHAR2
IS

l_org_level  NUMBER;
l_sub_level  NUMBER;
l_return VARCHAR2(1);

BEGIN


SELECT stock_locator_control_code INTO l_org_level
FROM mtl_parameters WHERE organization_id = p_Organization_Id;

SELECT locator_type INTO l_sub_level
FROM mtl_secondary_inventories WHERE organization_id = p_Organization_Id
AND secondary_inventory_name = p_Subinventory_Code;


--Now check through the hierarchy: Org->Sub->Item

IF l_org_level = 1 THEN l_return := 'T';

ELSIF l_org_level =2 or l_org_level =3 THEN l_return := 'F';

ELSIF l_org_level = 4 and l_sub_level = 1 THEN l_return := 'T';

ELSIF (l_org_level = 4 and l_sub_level = 2) or (l_org_level = 4 and l_sub_level = 3) THEN
	l_return := 'F';

ELSIF (l_org_level = 4 and l_sub_level = 5 and p_Location_Control_Code = 1) THEN
	l_return := 'T';

ELSIF (l_org_level = 4 and l_sub_level = 5 and p_Location_Control_Code = 2) OR
      (l_org_level = 4 and l_sub_level = 5 and p_Location_Control_Code = 3) THEN
       l_return := 'F';

ELSE
l_return := 'T';
END IF;

RETURN l_return;

EXCEPTION
	WHEN NO_DATA_FOUND THEN  --This means that the sub has not yet been defined
				 --No problem... Location remains hidden
	l_return := 'T';
	return l_return;

END IS_LOCATOR_HIDDEN;

FUNCTION IS_FROM_LOCATOR_HIDDEN(p_Transaction_Action_Id IN NUMBER,
			   p_Serial_Number_Control_Code IN NUMBER,
			   p_Location_Control_Code IN NUMBER,
			   p_Organization_Id IN NUMBER,
			   p_Subinventory_Code IN VARCHAR2)
			   RETURN VARCHAR2
IS
l_return VARCHAR2(1);
BEGIN

l_return := IS_SER_TRIG_ISSUE(p_Transaction_Action_Id,p_Serial_Number_Control_Code);

IF l_return = 'T' THEN
	RETURN l_return;
ELSE

l_return := IS_LOCATOR_HIDDEN(p_Location_Control_Code,
			      p_Organization_Id,
			      p_Subinventory_Code);

RETURN l_return;
END IF;

END IS_FROM_LOCATOR_HIDDEN;


FUNCTION IS_REVISION_HIDDEN(p_Transaction_Action_Id IN NUMBER,
			    p_Serial_Number_Control_Code IN NUMBER,
			    p_Revision_Qty_Control_Code IN NUMBER)
			    RETURN VARCHAR2

IS
l_return VARCHAR2(1);
BEGIN
l_return := IS_SER_TRIG_ISSUE(p_Transaction_Action_Id,p_Serial_Number_Control_Code);

IF l_return = 'T' THEN
 	RETURN l_return;
ELSE

IF p_Revision_Qty_Control_Code = 2 THEN
	l_return := 'F';

ELSE l_return := 'T';

END IF;
return l_return;
END IF;
END IS_REVISION_HIDDEN;



--The is lot hidden function will be used for both lot and expiration date fields.

FUNCTION IS_LOT_HIDDEN(p_Transaction_Action_Id IN NUMBER,
		       p_Serial_Number_Control_Code IN NUMBER,
			p_Lot_Control_Code IN NUMBER)
		      RETURN VARCHAR2

IS
l_return VARCHAR2(1);

BEGIN
l_return := IS_SER_TRIG_ISSUE(p_Transaction_Action_Id,p_Serial_Number_Control_Code);
IF l_return = 'T' THEN
	RETURN l_return;
ELSE
IF p_Lot_Control_Code = 2 THEN
	l_return := 'F';
ELSE
	l_return := 'T';

END IF;
END IF;
RETURN l_return;

END IS_LOT_HIDDEN;





FUNCTION IS_TO_ORG_HIDDEN(p_Transaction_Action_Id IN NUMBER)
				  RETURN VARCHAR2

--This is only necessary when performing direct org transfers.
IS

BEGIN
	IF p_Transaction_Action_Id = 3 THEN
		RETURN 'F';
	ELSE
		RETURN 'T';
	END IF;
END IS_TO_ORG_HIDDEN;


	FUNCTION IS_TO_LOC_HIDDEN(p_Location_Control_Code IN NUMBER,
				  p_Organization_Id IN NUMBER,
				  p_Subinventory_Code IN VARCHAR2,
				  p_Transaction_Action_Id IN NUMBER,
				  p_To_Organization_Id IN NUMBER,
				  p_Inventory_Item_Id IN NUMBER)
				  RETURN VARCHAR2
	IS
	l_result VARCHAR2(1);
	l_org NUMBER;
	l_Location_Control_Code NUMBER;
	BEGIN
	IF p_Transaction_Action_Id = 2 THEN l_org := p_Organization_Id;
	l_Location_Control_Code := p_Location_Control_Code;
	ELSIF p_Transaction_Action_Id = 3 THEN
	l_org := p_To_Organization_Id;
	select location_control_code into l_Location_Control_Code from
	mtl_system_items where
	inventory_item_id = p_Inventory_Item_Id and
	organization_id = l_org;
	ELSE
	l_org := p_Organization_Id;
	l_Location_Control_Code := p_Location_Control_Code;
	END IF;



	IF p_Transaction_Action_Id = 2 OR p_Transaction_Action_Id = 3 THEN

		l_result := IS_LOCATOR_HIDDEN(l_Location_Control_Code,
				      l_org,
				      p_Subinventory_Code);
		RETURN l_result;

	ELSE
		RETURN 'T';
	END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN

	l_result := 'T';
	return l_result;


END IS_TO_LOC_HIDDEN;


	FUNCTION IS_TO_SUB_HIDDEN(p_Transaction_Action_Id IN NUMBER,
				  p_done IN VARCHAR2)
				  RETURN VARCHAR2
IS
BEGIN

	IF p_done = 'T' THEN
	IF p_Transaction_Action_Id = 2 or p_Transaction_Action_Id = 3 THEN
	RETURN 'F';
	ELSE
	RETURN 'T';
	END IF;
        ELSE
	RETURN 'T';
	END IF;

END IS_TO_SUB_HIDDEN;


	FUNCTION IS_PROCESS_HIDDEN(p_Process_Flag IN VARCHAR2)
				  RETURN VARCHAR2
IS
BEGIN

IF p_Process_Flag = 'T' THEN
	RETURN 'F';
ELSE
	RETURN 'T';
END IF;

END IS_PROCESS_HIDDEN;

END INV_TRANSACTION_HIDDEN;

/
