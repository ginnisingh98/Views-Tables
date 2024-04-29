--------------------------------------------------------
--  DDL for Package Body INV_CUSTOMER_ITEM_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CUSTOMER_ITEM_GRP" as
/* $Header: INVICSDB.pls 120.6.12010000.3 2012/08/02 07:21:22 zewhuang ship $ */

PROCEDURE CI_Attribute_Value(
	Z_Customer_Item_Id		IN	Number 	DEFAULT NULL,
	Z_Customer_Id			IN	Number 	DEFAULT NULL,
	Z_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
	Z_Address_Id			IN	Number	DEFAULT NULL,
	Z_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
	Z_Inventory_Item_Id		IN	Number	DEFAULT NULL,
	Z_Organization_Id		IN	Number	DEFAULT NULL,
	Attribute_Name			IN	Varchar2	DEFAULT NULL,
	Error_Code			OUT	NOCOPY Varchar2,
	Error_Flag			OUT	NOCOPY Varchar2,
	Error_Message			OUT	NOCOPY Varchar2,
        Attribute_Value      OUT  NOCOPY Varchar2,
        Z_Line_Category_Code IN   VARCHAR2 DEFAULT 'ORDER' -- bug 13718740
	) IS
	X_Customer_Item_Id		Number		:=	NULL;
	X_Customer_Id			Number		:=	NULL;
	X_Customer_Category_Code	Varchar2(30)	:=	NULL;
	X_Address_Id			Number		:=	NULL;
	X_Customer_Item_Number		Varchar2(50)	:=	NULL;
	X_Item_Definition_Level		Varchar2(1)	:=	NULL;
	X_Customer_Item_Desc		Varchar2(240)	:=	NULL;
	X_Model_Customer_Item_Id	Number		:=	NULL;
	X_Commodity_Code_Id		Number		:=	NULL;
	X_Master_Container_Item_Id	Number		:=	NULL;
	X_Container_Item_Org_Id		Number		:=	NULL;
	X_Detail_Container_Item_Id	Number		:=	NULL;
	X_Min_Fill_Percentage		Number		:=	NULL;
	X_Dep_Plan_Required_Flag	Varchar2(1)	:=	NULL;
	X_Dep_Plan_Prior_Bld_Flag	Varchar2(1)	:=	NULL;
	X_Demand_Tolerance_Positive	Number		:=	NULL;
	X_Demand_Tolerance_Negative	Number		:=	NULL;
	X_Attribute_Category		Varchar2(30)	:=	NULL;
	X_Attribute1			Varchar2(150)	:=	NULL;
	X_Attribute2			Varchar2(150)	:=	NULL;
	X_Attribute3			Varchar2(150)	:=	NULL;
	X_Attribute4			Varchar2(150)	:=	NULL;
	X_Attribute5			Varchar2(150)	:=	NULL;
	X_Attribute6			Varchar2(150)	:=	NULL;
	X_Attribute7			Varchar2(150)	:=	NULL;
	X_Attribute8			Varchar2(150)	:=	NULL;
	X_Attribute9			Varchar2(150)	:=	NULL;
	X_Attribute10			Varchar2(150)	:=	NULL;
	X_Attribute11			Varchar2(150)	:=	NULL;
	X_Attribute12			Varchar2(150)	:=	NULL;
	X_Attribute13			Varchar2(150)	:=	NULL;
	X_Attribute14			Varchar2(150)	:=	NULL;
	X_Attribute15			Varchar2(150)	:=	NULL;
	X_Inventory_Item_Id		Number		:=	NULL;
	X_Master_Organization_Id	Number		:=	NULL;
	X_Preference_Number		Number		:=	NULL;
	X_Error_Code			Varchar2(9)	:=	NULL;
	X_Error_Flag			Varchar2(1)	:=	NULL;
	X_Error_Message			Varchar2(2000)	:=	NULL;
	Attribute_Variable		Varchar2(2000)	:=	NULL;
BEGIN

   IF ((Z_Customer_Id IS NOT NULL)
-- rdevakum, fix for bug 466738, address id may not be required from now on.
-- AND (Z_Address_Id IS NOT NULL)
	  AND (Z_Organization_Id IS NOT NULL) AND (Attribute_Name IS NOT NULL)
	  AND ((Z_Customer_Item_Id IS NOT NULL) OR
		(Z_Customer_Item_Number IS NOT NULL))) THEN

	IF UPPER(Attribute_Name) IN (
		'CUSTOMER_ITEM_ID', 		'CUSTOMER_ID',
		'CUSTOMER_CATEGORY_CODE',	'ADDRESS_ID',
		'CUSTOMER_ITEM_NUMBER', 	'ITEM_DEFINITION_LEVEL',
		'CUSTOMER_ITEM_DESC', 		'MODEL_CUSTOMER_ITEM_ID',
		'COMMODITY_CODE_ID',		'MASTER_CONTAINER_ITEM_ID',
		'CONTAINER_ITEM_ORG_ID', 	'DETAIL_CONTAINER_ITEM_ID',
		'MIN_FILL_PERCENTAGE', 		'DEP_PLAN_REQUIRED_FLAG',
		'DEP_PLAN_PRIOR_BLD_FLAG',	'DEMAND_TOLERANCE_POSITIVE',
		'DEMAND_TOLERANCE_NEGATIVE', 	'ATTRIBUTE_CATEGORY',
		'ATTRIBUTE1', 			'ATTRIBUTE2',
		'ATTRIBUTE3',			'ATTRIBUTE4',
		'ATTRIBUTE5',			'ATTRIBUTE6',
		'ATTRIBUTE7', 			'ATTRIBUTE8',
		'ATTRIBUTE9', 			'ATTRIBUTE10',
		'ATTRIBUTE11', 			'ATTRIBUTE12',
		'ATTRIBUTE13', 			'ATTRIBUTE14',
		'ATTRIBUTE15',			'INVENTORY_ITEM_ID',
		'MASTER_ORGANIZATION_ID', 	'PREFERENCE_NUMBER'	) THEN

		Fetch_Attributes(
			Z_Address_Id, 		Z_Customer_Category_Code,
			Z_Customer_Id,  	Z_Customer_Item_Number,
			Z_Organization_Id, 	Z_Customer_Item_Id,
			Z_Inventory_Item_Id, 	X_Customer_Item_Id,
			X_Customer_Id, 		X_Customer_Category_Code,
			X_Address_Id, 		X_Customer_Item_Number,
			X_Item_Definition_Level,    X_Customer_Item_Desc,
			X_Model_Customer_Item_Id,   X_Commodity_Code_Id,
			X_Master_Container_Item_Id, X_Container_Item_Org_Id,
			X_Detail_Container_Item_Id, X_Min_Fill_Percentage,
			X_Dep_Plan_Required_Flag,   X_Dep_Plan_Prior_Bld_Flag,
			X_Demand_Tolerance_Positive,
			X_Demand_Tolerance_Negative,
			X_Attribute_Category, 		X_Attribute1,
			X_Attribute2, 			X_Attribute3,
			X_Attribute4, 			X_Attribute5,
			X_Attribute6, 			X_Attribute7,
			X_Attribute8, 			X_Attribute9,
			X_Attribute10, 			X_Attribute11,
			X_Attribute12, 			X_Attribute13,
			X_Attribute14, 			X_Attribute15,
			X_Inventory_Item_Id, 	X_Master_Organization_Id,
			X_Preference_Number, 	X_Error_Code,
                        X_Error_Flag,     X_Error_Message,
                        Z_Line_Category_Code); -- bug 13718740



/*		Attribute_Variable := DECODE(
			UPPER(Attribute_Name),
			'CUSTOMER_ITEM_ID',	to_char(X_Customer_Item_Id),
			'CUSTOMER_ID',		to_char(X_Customer_Id),
			'CUSTOMER_CATEGORY_CODE' X_Customer_Category_Code,
	 		'ADDRESS_ID',		 to_char(X_Address_Id),
			'CUSTOMER_ITEM_NUMBER',	 X_Customer_Item_Number,
			'ITEM_DEFINITION_LEVEL', X_Item_Definition_Level,
			'CUSTOMER_ITEM_DESC',	 X_Customer_Item_Desc,
			'MODEL_CUSTOMER_ITEM_ID',
					to_char(X_Model_Customer_Item_Id),
			'COMMODITY_CODE_ID',
					to_char(X_Commodity_Code_Id),
			'MASTER_CONTAINER_ITEM_ID',
					to_char(X_Master_Container_Item_Id),
			'CONTAINER_ITEM_ORG_ID',
					to_char(X_Container_Item_Org_Id),
			'DETAIL_CONTAINER_ITEM_ID',
					to_char(X_Detail_Container_Item_Id),
			'MIN_FILL_PERCENTAGE',
					to_char(X_Min_Fill_Percentage),
			'DEP_PLAN_REQUIRED_FLAG',   X_Dep_Plan_Required_Flag,
			'DEP_PLAN_PRIOR_BLD_FLAG',  X_Dep_Plan_Prior_Bld_Flag,
			'DEMAND_TOLERANCE_POSITIVE',
					to_char(X_Demand_Tolerance_Positive),
			'DEMAND_TOLERANCE_NEGATIVE',
					to_char(X_Demand_Tolerance_Negative),
			'ATTRIBUTE_CATEGORY',		X_Attribute_Category,
			'ATTRIBUTE1',			X_Attribute1,
			'ATTRIBUTE2',			X_Attribute2,
			'ATTRIBUTE3',			X_Attribute3,
			'ATTRIBUTE4',			X_Attribute4,
			'ATTRIBUTE5',			X_Attribute5,
			'ATTRIBUTE6',			X_Attribute6,
			'ATTRIBUTE7',			X_Attribute7,
			'ATTRIBUTE8',			X_Attribute8,
			'ATTRIBUTE9',			X_Attribute9,
			'ATTRIBUTE10',			X_Attribute10,
			'ATTRIBUTE11',			X_Attribute11,
			'ATTRIBUTE12',			X_Attribute12,
			'ATTRIBUTE13',			X_Attribute13,
			'ATTRIBUTE14',			X_Attribute14,
			'ATTRIBUTE15',			X_Attribute15,
			'INVENTORY_ITEM_ID',
					to_char(X_Inventory_Item_Id),
			'MASTER_ORGANIZATION_ID',
					to_char(X_Master_Organization_Id),
			'PREFERENCE_NUMBER',
					to_char(X_Preference_Number)	);
*/

	if UPPER(Attribute_Name) = 'CUSTOMER_ITEM_ID' then
		Attribute_Variable := to_char(X_Customer_Item_Id);
	elsif UPPER(Attribute_Name) = 'CUSTOMER_ID' then
		Attribute_Variable := to_char(X_Customer_Id);
	elsif UPPER(Attribute_Name) = 'CUSTOMER_CATEGORY_CODE' then
		Attribute_Variable := X_Customer_Category_Code;
	elsif UPPER(Attribute_Name) = 'ADDRESS_ID' then
		Attribute_Variable := to_char(X_Address_Id);
	elsif UPPER(Attribute_Name) = 'CUSTOMER_ITEM_NUMBER' then
		Attribute_Variable := X_Customer_Item_Number;
	elsif UPPER(Attribute_Name) = 'ITEM_DEFINITION_LEVEL' then
		Attribute_Variable := X_Item_Definition_Level;
	elsif UPPER(Attribute_Name) = 'CUSTOMER_ITEM_DESC' then
		Attribute_Variable := X_Customer_Item_Desc;
	elsif UPPER(Attribute_Name) = 'MODEL_CUSTOMER_ITEM_ID' then
		Attribute_Variable := to_char(X_Model_Customer_Item_Id);
	elsif UPPER(Attribute_Name) = 'COMMODITY_CODE_ID' then
		Attribute_Variable := to_char(X_Commodity_Code_Id);
	elsif UPPER(Attribute_Name) = 'MASTER_CONTAINER_ITEM_ID' then
		Attribute_Variable := to_char(X_Master_Container_Item_Id);
	elsif UPPER(Attribute_Name) = 'CONTAINER_ITEM_ORG_ID' then
		Attribute_Variable := to_char(X_Container_Item_Org_Id);
	elsif UPPER(Attribute_Name) = 'DETAIL_CONTAINER_ITEM_ID' then
		Attribute_Variable := to_char(X_Detail_Container_Item_Id);
	elsif UPPER(Attribute_Name) = 'MIN_FILL_PERCENTAGE' then
		Attribute_Variable := to_char(X_Min_Fill_Percentage);
	elsif UPPER(Attribute_Name) = 'DEP_PLAN_REQUIRED_FLAG' then
		Attribute_Variable := X_Dep_Plan_Required_Flag;
	elsif UPPER(Attribute_Name) = 'DEP_PLAN_PRIOR_BLD_FLAG' then
		Attribute_Variable := X_Dep_Plan_Prior_Bld_Flag;
	elsif UPPER(Attribute_Name) = 'DEMAND_TOLERANCE_POSITIVE' then
		Attribute_Variable := to_char(X_Demand_Tolerance_Positive);
	elsif UPPER(Attribute_Name) = 'DEMAND_TOLERANCE_NEGATIVE' then
		Attribute_Variable := to_char(X_Demand_Tolerance_Negative);
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE_CATEGORY' then
		Attribute_Variable := X_Attribute_Category;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE1' then
		Attribute_Variable := X_Attribute1;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE2' then
		Attribute_Variable := X_Attribute2;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE3' then
		Attribute_Variable := X_Attribute3;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE4' then
		Attribute_Variable := X_Attribute4;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE5' then
		Attribute_Variable := X_Attribute5;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE6' then
		Attribute_Variable := X_Attribute6;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE7' then
		Attribute_Variable := X_Attribute7;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE8' then
		Attribute_Variable := X_Attribute8;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE9' then
		Attribute_Variable := X_Attribute9;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE10' then
		Attribute_Variable := X_Attribute10;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE11' then
		Attribute_Variable := X_Attribute11;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE12' then
		Attribute_Variable := X_Attribute12;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE13' then
		Attribute_Variable := X_Attribute13;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE14' then
		Attribute_Variable := X_Attribute14;
	elsif UPPER(Attribute_Name) = 'ATTRIBUTE15' then
		Attribute_Variable := X_Attribute15;
	elsif UPPER(Attribute_Name) = 'INVENTORY_ITEM_ID' then
		Attribute_Variable := to_char(X_Inventory_Item_Id);
	elsif UPPER(Attribute_Name) = 'MASTER_ORGANIZATION_ID' then
		Attribute_Variable := to_char(X_Master_Organization_Id);
	elsif UPPER(Attribute_Name) = 'PREFERENCE_NUMBER' then
		Attribute_Variable := to_char(X_Preference_Number);
	end if;

			Error_Code		:=	X_Error_Code;
			Error_Flag		:=	X_Error_Flag;
			Error_Message	:=	X_Error_Message;

   		IF ((X_Error_Code = 'APP-00000') AND
		    (Attribute_Variable IS NULL)) THEN

			FND_MESSAGE.Set_Name('INV',
				'INV_NULL_ATTRIBUTE_VALUE');
			Error_Code		:=	'APP-43041';
			Error_Flag		:=	'W';
			Error_Message	:=	FND_MESSAGE.Get;
			RETURN;
		ELSE
			Attribute_Value := Attribute_Variable;

		END IF;

	ELSE
		FND_MESSAGE.Set_Name('INV', 'INV_INVALID_COLUMN_NAME');
			Error_Code := 'APP-43043';
			Error_Flag := 'Y';
			Error_Message := FND_MESSAGE.Get;
			RETURN;
	END IF;

   ELSE

		FND_MESSAGE.Set_Name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
		Error_Code := 'APP-43042';
		Error_Flag := 'Y';
		Error_Message := FND_MESSAGE.Get;
		RETURN;
   END IF;

EXCEPTION

	WHEN NO_DATA_FOUND THEN

		FND_MESSAGE.Set_Name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
		Error_Code := 'APP-43042';
		Error_Flag := 'Y';
		Error_Message := FND_MESSAGE.Get;
		RETURN;

	WHEN OTHERS THEN

		Error_Code :=	SQLCODE;
		Error_Flag :=	'Y';
		Error_Message := SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 240);
		RETURN;

END CI_Attribute_Value;


PROCEDURE Fetch_Attributes(
	Y_Address_Id	 		IN	Number	DEFAULT NULL,
	Y_Customer_Category_Code	IN	Varchar2	DEFAULT NULL,
	Y_Customer_Id			IN	Number 	DEFAULT NULL,
	Y_Customer_Item_Number		IN	Varchar2	DEFAULT NULL,
	Y_Organization_Id		IN	Number 	DEFAULT NULL,
	Y_Customer_Item_Id		IN	Number 	DEFAULT NULL,
	Y_Inventory_Item_Id		IN	Number 	DEFAULT NULL,
	X_Customer_Item_Id		OUT	NOCOPY Number,
	X_Customer_Id			OUT	NOCOPY Number,
	X_Customer_Category_Code	OUT	NOCOPY Varchar2,
	X_Address_Id			OUT	NOCOPY Number,
	X_Customer_Item_Number		OUT	NOCOPY Varchar2,
	X_Item_Definition_Level		OUT	NOCOPY Varchar2,
	X_Customer_Item_Desc		OUT	NOCOPY Varchar2,
	X_Model_Customer_Item_Id	OUT	NOCOPY Number,
	X_Commodity_Code_Id		OUT	NOCOPY Number,
	X_Master_Container_Item_Id	OUT	NOCOPY Number,
	X_Container_Item_Org_Id		OUT	NOCOPY Number,
	X_Detail_Container_Item_Id	OUT	NOCOPY Number,
	X_Min_Fill_Percentage		OUT	NOCOPY Number,
	X_Dep_Plan_Required_Flag	OUT	NOCOPY Varchar2,
	X_Dep_Plan_Prior_Bld_Flag	OUT	NOCOPY Varchar2,
	X_Demand_Tolerance_Positive	OUT	NOCOPY Number,
	X_Demand_Tolerance_Negative	OUT	NOCOPY Number,
	X_Attribute_Category		OUT	NOCOPY Varchar2,
	X_Attribute1			OUT	NOCOPY Varchar2,
	X_Attribute2			OUT	NOCOPY Varchar2,
	X_Attribute3			OUT	NOCOPY Varchar2,
	X_Attribute4			OUT	NOCOPY Varchar2,
	X_Attribute5			OUT	NOCOPY Varchar2,
	X_Attribute6			OUT	NOCOPY Varchar2,
	X_Attribute7			OUT	NOCOPY Varchar2,
	X_Attribute8			OUT	NOCOPY Varchar2,
	X_Attribute9			OUT	NOCOPY Varchar2,
	X_Attribute10			OUT	NOCOPY Varchar2,
	X_Attribute11			OUT	NOCOPY Varchar2,
	X_Attribute12			OUT	NOCOPY Varchar2,
	X_Attribute13			OUT     NOCOPY Varchar2,
	X_Attribute14			OUT	NOCOPY Varchar2,
	X_Attribute15			OUT	NOCOPY Varchar2,
	X_Inventory_Item_Id		OUT	NOCOPY Number,
	X_Master_Organization_Id	OUT	NOCOPY Number,
	X_Preference_Number		OUT	NOCOPY Number,
	X_Error_Code			OUT	NOCOPY Varchar2,
	X_Error_Flag			OUT	NOCOPY Varchar2,
        X_Error_Message      OUT  NOCOPY Varchar2,
        Y_Line_Category_Code IN   VARCHAR2 DEFAULT 'RETURN' -- bug 13718740, 14394021
	) IS

	Temp_Customer_Item_Id		Number		:=	NULL;
	Temp_Master_Organization_Id	Number		:=	NULL;
	Temp_Inventory_Item_Id		Number		:=	NULL;
	Temp_Inactive_Flag		Varchar2(1)	:=	NULL;
	Temp_Address_Id			Number		:=	NULL;
	Temp_Item_Definition_Level	Varchar2(1)	:=	NULL;
	Temp_Customer_Category_Code	Varchar2(30)	:=	NULL;
	RA_Address_Category		Varchar2(30)	:=	NULL;

	l_Customer_Id		NUMBER;

--rdevakum, fix for bug 466738
        Temp_Level_1                    Number          :=      1;
        Temp_Level_2                    Number          :=      2;
        Temp_Level_3                    Number          :=      3;

--rdevakum, fix for bug 466738, added where clause on
--item_definition_level. if addr id is passed null, consider
--customer level only.
	CURSOR	CI_Cur (v_Customer_Id IN NUMBER) IS
	SELECT	Customer_Item_Id, Address_Id, Customer_Category_Code,
		Inactive_Flag, Item_Definition_Level
	FROM	MTL_CUSTOMER_ITEMS
	WHERE	Customer_Id = v_Customer_Id
        AND     Item_Definition_Level in
                (Temp_level_1, Temp_level_2, Temp_level_3)
	AND 	( (Y_Customer_Item_Id is NULL AND
		   Customer_Item_Number = Y_Customer_Item_Number)
	           OR	Customer_Item_Id = Y_Customer_Item_Id)
	ORDER BY Item_Definition_Level DESC;

	CURSOR	CI_XREF_Cur (TmpCustItemId NUMBER) IS
	SELECT	Master_Organization_Id, Inventory_Item_Id, Inactive_Flag
	FROM	MTL_CUSTOMER_ITEM_XREFS
	WHERE	Customer_Item_Id = TmpCustItemId
	AND	Inventory_Item_Id =
			NVL(Y_Inventory_Item_Id, Inventory_Item_Id)
	AND	Master_Organization_Id	=
			(SELECT	Master_Organization_Id
			 FROM	MTL_PARAMETERS
			 WHERE	Organization_Id	= Y_Organization_Id)
	ORDER BY  Preference_Number ASC;


	CURSOR	CI_ATTR_VAL_Cur (
			TmpCustItemId NUMBER,
			TmpInvItemId NUMBER, TmpMstrOrgId NUMBER) IS
	SELECT	MCIXRF.Customer_Item_Id,
			MCI.Customer_Item_Number,
			MCI.Customer_Category_Code,
			MCI.Customer_Id,
			MCI.Address_Id,
			MCI.Item_Definition_Level,
			MCI.Customer_Item_Desc,
			MCI.Model_Customer_Item_Id,
			MCI.Commodity_Code_Id,
			MCI.Master_Container_Item_Id,
			MCI.Container_Item_Org_Id,
			MCI.Detail_Container_Item_Id,
			MCI.Min_Fill_Percentage,
			MCI.Dep_Plan_Required_Flag,
			MCI.Dep_Plan_Prior_Bld_Flag,
			MCI.Demand_Tolerance_Positive,
			MCI.Demand_Tolerance_Negative,
			MCIXRF.Inventory_Item_Id,
			MCIXRF.Master_Organization_Id,
			MCIXRF.Preference_Number,
			MCI.Attribute_Category,
			MCI.Attribute1,
			MCI.Attribute2,
			MCI.Attribute3,
			MCI.Attribute4,
			MCI.Attribute5,
			MCI.Attribute6,
			MCI.Attribute7,
			MCI.Attribute8,
			MCI.Attribute9,
			MCI.Attribute10,
			MCI.Attribute11,
			MCI.Attribute12,
			MCI.Attribute13,
			MCI.Attribute14,
			MCI.Attribute15
	FROM		MTL_SYSTEM_ITEMS MSI,
			MTL_CUSTOMER_ITEM_XREFS	MCIXRF,
			MTL_CUSTOMER_ITEMS	MCI
	WHERE		MCIXRF.Customer_Item_Id	 =	TmpCustItemId
	AND		MCIXRF.Inventory_Item_Id =	TmpInvItemId
	AND		MCIXRF.Master_Organization_Id =	TmpMstrOrgId
	AND		MCI.Customer_Item_Id	= MCIXRF.Customer_item_Id
	AND		MSI.Inventory_Item_Id	= MCIXRF.Inventory_Item_Id
	AND 		MSI.Organization_id = MCIXRF.Master_Organization_Id;

	Recinfo CI_ATTR_VAL_Cur%ROWTYPE;


	CURSOR	RA_Addresses_Cur (v_Address_Id IN NUMBER) IS

      /* RA_ADDRESSES has been scrapped - re-writing cursor def -Anmurali
	  SELECT  CUSTOMER_ID
	    FROM  RA_ADDRESSES
	    WHERE ADDRESS_ID = v_Address_Id; */

       /* SELECT ACCT_SITE.CUST_ACCOUNT_ID
	       FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
             HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
        WHERE ACCT_SITE.CUST_ACCT_SITE_ID = v_Address_Id
	  AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
	  AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
          AND NVL(ACCT_SITE.ORG_ID, NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
	                                                 SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)) =
	      NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ', NULL,
	                                                 SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99);*/
     SELECT ACCT_SITE.CUST_ACCOUNT_ID
     FROM HZ_CUST_ACCT_SITES_ALL ACCT_SITE
     WHERE ACCT_SITE.CUST_ACCT_SITE_ID = v_Address_Id;

BEGIN

   IF ( (Y_Customer_Id IS NULL)
	OR (Y_Organization_Id IS NULL)
	OR ( (Y_Customer_Item_Id IS NULL) AND
	     (Y_Customer_Item_Number IS NULL) ) ) THEN
	FND_MESSAGE.Set_Name('INV', 'INV_MISSING_REQUIRED_PARAMETER');
	X_Error_Flag := 'Y';
	X_Error_Code := 'APP-43042';
	X_Error_Message := FND_MESSAGE.Get;
	RETURN;
   END IF;

--rdevakum, fix for bug 466738. variables for item definition level.
--setting values accordingly will control the fetch set of CI_Cur.
        If Y_Address_Id is null then
            Temp_Level_2 := 1;
            Temp_Level_3 := 1;
        End If;

   l_Customer_Id := Y_Customer_Id ;

   IF ( Y_Address_Id IS NOT NULL ) THEN
      OPEN RA_Addresses_Cur (Y_Address_Id);
      FETCH RA_Addresses_Cur
       INTO l_Customer_Id;
      IF ( RA_Addresses_Cur%NOTFOUND ) THEN
         FND_MESSAGE.Set_Name('INV', 'INV_INVALID_CUST_ADDRESS');
         X_Error_Flag := 'Y';
         X_Error_Code := 'APP-43099';
         X_Error_Message := FND_MESSAGE.Get;
         CLOSE RA_Addresses_Cur;
         RETURN;
      END IF;
      CLOSE RA_Addresses_Cur;
   END IF;

	OPEN CI_Cur (l_Customer_Id);
	LOOP
		<<next_customer_item>>

		FETCH CI_Cur INTO Temp_Customer_Item_Id, Temp_Address_Id,
				  Temp_Customer_Category_Code,
				  Temp_Inactive_Flag,
				  Temp_Item_Definition_Level;

		IF ((CI_Cur%NOTFOUND) AND (CI_Cur%ROWCOUNT = 0)) THEN

			FND_MESSAGE.Set_Name('INV', 'INV_NO_CUSTOMER_ITEM');
			X_Error_Code	:=	'APP-43037';
			X_Error_Flag	:=	'Y';
			X_Error_Message	:=	FND_MESSAGE.Get;
			RETURN;
	    END if;

	   IF Y_Line_Category_Code = 'ORDER' THEN -- bug 13718740

	    IF ((Temp_Item_Definition_Level = '3') AND
		   (Temp_Inactive_Flag = 'N') AND
		   (Temp_Address_Id = Y_Address_Id)) THEN

	      GOTO get_cross_reference;

	    ELSIF (Temp_Item_Definition_Level = '2') AND
		   (Temp_Inactive_Flag = 'N')

	     THEN

		       /* Changing the query as RA_ADDRESSES has been scrapped -Anmurali

	      SELECT  Customer_Category_Code
	      INTO  RA_Address_Category
	      FROM  RA_ADDRESSES
	      WHERE  Address_Id = Y_Address_Id;

		 SELECT ACCT_SITE.CUSTOMER_CATEGORY_CODE
		INTO  RA_Address_Category
		 FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
			      HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
			 WHERE ACCT_SITE.CUST_ACCT_SITE_ID = Y_Address_Id
		     AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
		     AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
			   AND NVL(ACCT_SITE.ORG_ID,
		     NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
							      SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)) =
			   NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ', NULL,
							SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99);
		   5064537 */
		  SELECT ACCT_SITE.CUSTOMER_CATEGORY_CODE
		  INTO  RA_Address_Category
		  FROM HZ_CUST_ACCT_SITES_ALL ACCT_SITE
		  WHERE ACCT_SITE.CUST_ACCT_SITE_ID = Y_Address_Id;

	      IF (Temp_Customer_Category_Code =
		RA_Address_Category) THEN

		GOTO get_cross_reference;
	/*      ELSE
		GOTO next_customer_item;
	*/
	      END IF;


	    ELSIF (Temp_Item_Definition_Level = '1') AND
		   (Temp_Inactive_Flag = 'N')  THEN

	      GOTO get_cross_reference;

	    ELSE
	      IF ((Temp_Inactive_Flag = 'Y') AND
		  (CI_Cur%NOTFOUND) AND (CI_Cur%ROWCOUNT > 0)) THEN

		FND_MESSAGE.Set_Name('INV',
		  'INV_INACTIVE_CUSTOMER_ITEM');
		X_Error_Code :=  'APP-43039';
		X_Error_Flag :=  'Y';
		X_Error_Message  := FND_MESSAGE.Get;
		Temp_Inactive_Flag := NULL;
		RETURN;
	      ELSIF ((Temp_Item_Definition_Level = '3') AND
		     (Temp_Address_Id <> Y_Address_Id) AND
		  (CI_Cur%NOTFOUND) AND (CI_Cur%ROWCOUNT > 0)) THEN

		FND_MESSAGE.Set_Name('INV',
		  'INV_INVALID_CUST_ADDRESS');
		X_Error_Code :=  'APP-43099';
		X_Error_Flag :=  'Y';
		X_Error_Message  := FND_MESSAGE.Get;
		Temp_Inactive_Flag := NULL;
		RETURN;

	      END IF;

	/*      GOTO next_customer_item;
	*/
	    END IF;

	   ELSIF Y_Line_Category_Code = 'RETURN' THEN     -- bug 13718740

			--Bug: 5157639 Removed validations based on Inactive flag
	    IF ((Temp_Item_Definition_Level = '3') AND -- bug 13718740
			       --(Temp_Inactive_Flag = 'N') AND
			       (Temp_Address_Id = Y_Address_Id)) THEN

				GOTO get_cross_reference;

			ELSIF (Temp_Item_Definition_Level = '2') --AND
			       --(Temp_Inactive_Flag = 'N'))
			 THEN

		       /* Changing the query as RA_ADDRESSES has been scrapped -Anmurali

				SELECT	Customer_Category_Code
				INTO	RA_Address_Category
				FROM	RA_ADDRESSES
				WHERE	Address_Id = Y_Address_Id;

		       SELECT ACCT_SITE.CUSTOMER_CATEGORY_CODE
			    INTO	RA_Address_Category
		       FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
			      HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
			 WHERE ACCT_SITE.CUST_ACCT_SITE_ID = Y_Address_Id
			   AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
			   AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)
			   AND NVL(ACCT_SITE.ORG_ID,
				 NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ',NULL,
									  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99)) =
				 NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1),' ', NULL,
									  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),- 99);
		   5064537 */
		  SELECT ACCT_SITE.CUSTOMER_CATEGORY_CODE
		  INTO	RA_Address_Category
		  FROM HZ_CUST_ACCT_SITES_ALL ACCT_SITE
		  WHERE ACCT_SITE.CUST_ACCT_SITE_ID = Y_Address_Id;

				IF (Temp_Customer_Category_Code =
					RA_Address_Category) THEN

					GOTO get_cross_reference;
	/*			ELSE
					GOTO next_customer_item;
	*/
				END IF;


			ELSIF (Temp_Item_Definition_Level = '1') THEN --AND
			       --(Temp_Inactive_Flag = 'N'))  THEN

				GOTO get_cross_reference;

			ELSE
				IF ((Temp_Inactive_Flag = 'Y') AND
				    (CI_Cur%NOTFOUND) AND (CI_Cur%ROWCOUNT > 0)) THEN

					FND_MESSAGE.Set_Name('INV',
						'INV_INACTIVE_CUSTOMER_ITEM');
					X_Error_Code :=	'APP-43039';
					X_Error_Flag :=	'Y';
					X_Error_Message	:= FND_MESSAGE.Get;
					Temp_Inactive_Flag := NULL;
					RETURN;
				ELSIF ((Temp_Item_Definition_Level = '3') AND
				       (Temp_Address_Id <> Y_Address_Id) AND
				    (CI_Cur%NOTFOUND) AND (CI_Cur%ROWCOUNT > 0)) THEN

					FND_MESSAGE.Set_Name('INV',
						'INV_INVALID_CUST_ADDRESS');
					X_Error_Code :=	'APP-43099';
					X_Error_Flag :=	'Y';
					X_Error_Message	:= FND_MESSAGE.Get;
					Temp_Inactive_Flag := NULL;
					RETURN;

				END IF;

	/*			GOTO next_customer_item;
	*/
			END IF;

	   END IF;  -- bug 13718740


	EXIT WHEN CI_Cur%NOTFOUND;

	END LOOP;

			<<get_cross_reference>>

		BEGIN

			OPEN CI_XREF_Cur (Temp_Customer_Item_Id);
			FETCH CI_XREF_Cur INTO Temp_Master_Organization_Id,
					       Temp_Inventory_Item_Id,
					       Temp_Inactive_Flag;

			IF (CI_XREF_Cur%NOTFOUND) THEN

				FND_MESSAGE.Set_Name('INV',
					'INV_NO_CUSTOMER_ITEM_XREF');
				X_Error_Code :=	'APP-43038';
				X_Error_Flag :=	'Y';
				X_Error_Message	:= FND_MESSAGE.Get;
				RETURN;
                --Bug: 5157639 Commented out this code to remove validation based on Incative flag
      ELSIF (Y_Line_Category_Code = 'ORDER' AND Temp_Inactive_Flag = 'Y') THEN -- bug 13718740

        LOOP  -- bug 13718740

					FETCH CI_XREF_Cur INTO
						Temp_Master_Organization_Id,
						Temp_Inventory_Item_Id,
						Temp_Inactive_Flag;

					IF (CI_XREF_Cur%NOTFOUND) THEN

						FND_MESSAGE.Set_Name('INV',
							'INV_INACTIVE_CI_XREF');
						X_Error_Code :=	'APP-43040';
						X_Error_Flag :=	'Y';
						X_Error_Message :=
							FND_MESSAGE.Get;
						Temp_Inactive_Flag := NULL;
						RETURN;

					ELSIF (Temp_Inactive_Flag = 'N') THEN

					   OPEN CI_ATTR_VAL_Cur (
						Temp_Customer_Item_Id,
						Temp_Inventory_Item_Id,
						Temp_Master_Organization_Id);

					   FETCH CI_ATTR_VAL_Cur INTO Recinfo;

					END IF;

				EXIT WHEN ((CI_XREF_Cur%NOTFOUND) OR
					   (Temp_Inactive_Flag = 'N'));

        END LOOP;

			ELSE

				OPEN CI_ATTR_VAL_Cur (
					Temp_Customer_Item_Id,
					Temp_Inventory_Item_Id,
					Temp_Master_Organization_Id);

				FETCH CI_ATTR_VAL_Cur INTO Recinfo;

			END IF;

		X_Customer_Item_Id := Recinfo.Customer_Item_Id;
		X_Customer_Id := Recinfo.Customer_Id;
		X_Customer_Category_Code := Recinfo.Customer_Category_Code;
		X_Address_Id :=	Recinfo.Address_Id;
		X_Customer_Item_Number := Recinfo.Customer_Item_Number;
		X_Item_Definition_Level	:= Recinfo.Item_Definition_Level;
		X_Customer_Item_Desc :=	Recinfo.Customer_Item_Desc;
		X_Model_Customer_Item_Id := Recinfo.Model_Customer_Item_Id;
		X_Commodity_Code_Id := Recinfo.Commodity_Code_Id;
		X_Master_Container_Item_Id := Recinfo.Master_Container_Item_Id;
		X_Container_Item_Org_Id	:= Recinfo.Container_Item_Org_Id;
		X_Detail_Container_Item_Id := Recinfo.Detail_Container_Item_Id;
		X_Min_Fill_Percentage := Recinfo.Min_Fill_Percentage;
		X_Dep_Plan_Required_Flag := Recinfo.Dep_Plan_Required_Flag;
		X_Dep_Plan_Prior_Bld_Flag := Recinfo.Dep_Plan_Prior_Bld_Flag;
		X_Demand_Tolerance_Positive :=
				Recinfo.Demand_Tolerance_Positive;
		X_Demand_Tolerance_Negative :=
				Recinfo.Demand_Tolerance_Negative;
		X_Attribute_Category :=	Recinfo.Attribute_Category;
		X_Attribute1 :=	Recinfo.Attribute1;
		X_Attribute2 :=	Recinfo.Attribute2;
		X_Attribute3 :=	Recinfo.Attribute3;
		X_Attribute4 :=	Recinfo.Attribute4;
		X_Attribute5 :=	Recinfo.Attribute5;
		X_Attribute6 :=	Recinfo.Attribute6;
		X_Attribute7 :=	Recinfo.Attribute7;
		X_Attribute8 :=	Recinfo.Attribute8;
		X_Attribute9 :=	Recinfo.Attribute9;
		X_Attribute10 := Recinfo.Attribute10;
		X_Attribute11 := Recinfo.Attribute11;
		X_Attribute12 := Recinfo.Attribute12;
		X_Attribute13 := Recinfo.Attribute13;
		X_Attribute14 := Recinfo.Attribute14;
		X_Attribute15 := Recinfo.Attribute15;
		X_Inventory_Item_Id := Recinfo.Inventory_Item_Id;
		X_Master_Organization_Id := Recinfo.Master_Organization_Id;
		X_Preference_Number := Recinfo.Preference_Number;
		X_Error_Code := 'APP-00000';
		X_Error_Flag :=	'N';
		X_Error_Message := NULL;

		RETURN;

	END;

	CLOSE CI_Cur;
	CLOSE CI_XREF_Cur;
	CLOSE CI_ATTR_VAL_Cur;

EXCEPTION

	WHEN OTHERS THEN

		X_Error_Code	:=	SQLCODE;
		X_Error_Flag	:=	'Y';
		X_Error_Message	:=	SQLCODE || ' - ' ||
					SUBSTR(SQLERRM, 1, 240);
		RETURN;

END Fetch_Attributes;


END INV_CUSTOMER_ITEM_GRP;


/
