--------------------------------------------------------
--  DDL for Package Body CSICUMPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSICUMPI_PUB" AS
/* $Header: CSICUMPB.pls 115.6 2002/11/12 00:12:24 rmamidip noship $ */

FUNCTION get_non_primary_party_list(p_account_number VARCHAR2,
					 p_org_id         NUMBER) RETURN VARCHAR2 IS

  CURSOR c1(l_account_number VARCHAR2) is
     SELECT hzpty.party_name
	FROM   hz_cust_accounts hzacct,
		  hz_cust_account_roles hzrole,
		  hz_parties hzpty
     WHERE  hzacct.account_number = l_account_number
	AND    hzrole.cust_account_id = hzacct.cust_account_id
	AND    hzpty.party_id = hzrole.party_id;


  party_list            VARCHAR2(32767) := '';
  current_party_name    VARCHAR2(100) := '';
  x_msg_data            VARCHAR2(2000);
  x_msg_count           NUMBER;

BEGIN

  FOR c1_rec in c1(p_account_number) LOOP
	 IF (party_list IS NULL) THEN
         party_list := c1_rec.party_name;
	 ELSE
         party_list := party_list || ', ' || c1_rec.party_name;
	 END IF;
  END LOOP;
  return party_list;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  return party_list;
 WHEN OTHERS THEN
 fnd_msg_pub.count_and_get(p_count => x_msg_count,
					  p_data  => x_msg_data,
					  p_encoded => fnd_api.g_false);


 return party_list;

END get_non_primary_party_list;

FUNCTION get_Root_information(p_customer_product_id NUMBER)
               RETURN VARCHAR2 IS
 l_Instance_Id NUMBER;
 l_Product VARCHAR2(250);
 l_Description VARCHAR2(250);
 l_Serial VARCHAR2(30);
 l_Lot VARCHAR2(30);
 l_Reference VARCHAR2(30);
 l_Result_String VARCHAR2(2000);
 l_Token CONSTANT VARCHAR2(4) := '@$?!';
 CURSOR Root_Cur (P_Object_ID IN NUMBER) IS
 SELECT CIR.OBJECT_ID
 FROM CSI_II_RELATIONSHIPS CIR
 START WITH Object_Id = P_Object_ID
 CONNECT BY PRIOR OBJECT_ID = SUBJECT_ID
 ORDER BY OBJECT_ID;
 CURSOR Instance_Cur (P_Instance_ID IN NUMBER) IS
 SELECT CII.INSTANCE_NUMBER REFERENCE,
        CII.SERIAL_NUMBER SERIAL,
        CII.LOT_NUMBER LOT,
        MSIK.CONCATENATED_SEGMENTS PRODUCT,
        MSIK.DESCRIPTION DESCRIPTION
 FROM   CSI_ITEM_INSTANCES CII,
        MTL_SYSTEM_ITEMS_KFV MSIK
 WHERE  MSIK.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
 AND    CII.INSTANCE_ID = P_INSTANCE_ID
 AND    MSIK.ORGANIZATION_ID = CII.INV_MASTER_ORGANIZATION_ID;

BEGIN
   OPEN Root_Cur(P_Customer_Product_ID);
   FETCH Root_Cur INTO l_Instance_Id;
   CLOSE Root_Cur;
   IF l_Instance_ID IS NULL
   THEN l_Instance_Id := P_Customer_Product_ID;
   END IF;
   OPEN Instance_Cur(l_Instance_Id);
   FETCH Instance_Cur INTO
        l_reference,
        l_serial,
        l_lot,
        l_Product,
        l_Description;
   IF (Instance_Cur%NOTFOUND) THEN
      l_result_string := '';
   ELSE
      l_result_string := l_product||l_token ||
                         l_description|| l_token ||
                         l_reference || l_token ||
                         l_serial|| l_token ||
                         l_lot;

   END IF;
   CLOSE Instance_Cur;
   return l_result_string;

END GET_Root_INFORMATION;

FUNCTION GET_Part_Information(p_customer_product_id NUMBER)
           RETURN VARCHAR2 IS
 CURSOR Part_Info_Cur IS
 SELECT MSIK.Concatenated_Segments,
        MSIK.DESCRIPTION,
        CII.Instance_Number,
        CII.Serial_Number,
        CII.Lot_Number
 FROM  CSI_Item_Instances CII,
       MTL_SYSTEM_ITEMS_KFV MSIK
 WHERE CII.Instance_Id = P_Customer_Product_Id
 AND   CII.Inventory_Item_Id = MSIK.Inventory_Item_ID
 AND   CII.Inv_Master_Organization_Id = MSIK.Organization_Id;

 l_Product VARCHAR2(250);
 l_Description VARCHAR2(250);
 l_Serial VARCHAR2(30);
 l_Lot VARCHAR2(30);
 l_Reference VARCHAR2(30);
 l_Result_String VARCHAR2(2000);
 l_Token CONSTANT VARCHAR2(4) := '@$?!';
BEGIN
 OPEN Part_Info_Cur;
 FETCH Part_Info_Cur INTO
             l_Product,
             l_Description,
             l_Reference,
             l_Serial,
             l_Lot;
   IF (Part_Info_Cur%NOTFOUND) THEN
      l_result_string := '';
   ELSE
      l_result_string := l_product||l_token ||
                         l_description|| l_token ||
                         l_reference || l_token ||
                         l_serial|| l_token ||
                         l_lot;

   END IF;
   CLOSE Part_Info_Cur;
   return l_result_string;

END Get_Part_Information;
FUNCTION GET_CHILDREN_FLAG(p_customer_product_id NUMBER)
           RETURN VARCHAR2 IS

  CURSOR c1 IS
  SELECT Subject_ID
  FROM CSI_II_RELATIONSHIPS
  WHERE OBJECT_ID = P_Customer_Product_Id
  AND  ACTIVE_END_DATE IS NULL;

   l_cp_id           NUMBER;
   l_value           VARCHAR2(1);

BEGIN

    OPEN c1;
       FETCH c1 INTO l_cp_id;
    IF (c1%NOTFOUND) THEN
       l_value := 'N';
    ELSE
          l_value := 'Y';
    END IF;
       CLOSE c1;
    RETURN l_value;

END GET_CHILDREN_FLAG;
/*
PROCEDURE Get_Configuration
	(p_cp_id			IN	NUMBER,
	p_config_type			IN	VARCHAR2	DEFAULT NULL,
	p_as_of_date			IN	DATE		DEFAULT sysdate,
	x_config_tbl		 OUT NOCOPY Config_Tbl_Type,
	x_config_tbl_count	 OUT NOCOPY NUMBER
) IS
	l_cp_id				NUMBER;
	l_config_type			VARCHAR2(30);
	l_as_of_date			DATE;

	l_config_tbl			Config_Tbl_Type;
	l_config_tbl_count		NUMBER	:= 0;

	CURSOR comp_csr IS
                SELECT CII.Instance_Id,
                       CIIR.OBJECT_ID,
                       CIIR.RELATIONSHIP_TYPE_CODE,
                       CII.OWNER_PARTY_ACCOUNT_ID,
                       CII.INVENTORY_ITEM_ID,
                       CII.SERIAL_NUMBER,
                       CII.LOT_NUMBER
                FROM   CSI_ITEM_INSTANCES CII,
                       CSI_II_RELATIONSHIPS CIIR
                WHERE  CII.INSTANCE_ID = CIIR.SUBJECT_ID
                AND    l_AS_OF_DATE BETWEEN NVL(CIIR.ACTIVE_START_DATE,l_As_Of_Date-1) AND NVL(CIIR.ACTIVE_END_DATE,l_As_Of_Date+1)
                CONNECT BY PRIOR CIIR.SUBJECT_ID = CIIR.OBJECT_ID;

		l_counter				NUMBER	:= 0;
		l_reference_number		NUMBER;
		l_curr_serial_number	VARCHAR2(30);

	FUNCTION IsOrphan
	(
		p_parent_id			IN	NUMBER,
		p_num_of_recs_to_srch	IN	NUMBER
	) RETURN BOOLEAN IS
		l_c1					NUMBER;
		l_parent_found			BOOLEAN	:= FALSE;
		l_parent_id			NUMBER	:= p_parent_id;
		l_num_of_recs_to_srch	NUMBER	:= p_num_of_recs_to_srch;

	 BEGIN
		IF l_num_of_recs_to_srch <= 0 THEN
			RETURN(FALSE);
		END IF;

		FOR l_c1 IN 0..l_num_of_recs_to_srch LOOP
			IF (l_parent_id = l_config_tbl(l_c1).config_cp_id) THEN
				l_parent_found := TRUE;
				EXIT;
			END IF;
		END LOOP;

		RETURN(NOT(l_parent_found));

	END IsOrphan;


BEGIN
	l_cp_id := p_cp_id;
	l_config_type := p_config_type;
	l_as_of_date := NVL(p_as_of_date,sysdate);

	FOR c1 IN comp_csr LOOP
		IF NVL(l_config_type,NVL(c1.config_type,'X')) = NVL(c1.config_type,'X') THEN

			IF IsOrphan(c1.config_parent_id,l_config_tbl_count) THEN

			SELECT Instance_Number,
			       serial_number
			INTO   l_reference_number,
			       l_curr_serial_number
			FROM   csi_Item_Instances
			WHERE  Instance_id = c1.customer_product_id;

				l_config_tbl.DELETE;
				l_config_tbl_count := 0;
			END IF;
			l_config_tbl(l_counter).config_cp_id := c1.customer_product_id;
			l_config_tbl(l_counter).config_parent_cp_id := c1.config_parent_id;
			l_config_tbl(l_counter).config_type := c1.config_type;
			l_config_tbl(l_counter).customer_id := c1.customer_id;
			l_config_tbl(l_counter).inventory_item_id := c1.inventory_item_id;
			l_config_tbl(l_counter).serial_number := c1.current_serial_number;
			l_config_tbl(l_counter).lot_number := c1.lot_number;
			l_config_tbl_count := l_config_tbl_count + 1;
			l_counter := l_counter + 1;

		ELSE

			SELECT Instance_Number,
			       serial_number
			INTO   l_reference_number,
			       l_curr_serial_number
			FROM   csi_Item_Instances
			WHERE  Instance_id = c1.customer_product_id;

			l_config_tbl.DELETE;
			l_config_tbl_count := 0;
                END IF;
	END LOOP;

	x_config_tbl		:= l_config_tbl;
	x_config_tbl_count	:= l_config_tbl_count;

END Get_Configuration;
*/
FUNCTION Get_Root_Id(P_Customer_Product_Id IN NUMBER)
 RETURN NUMBER IS

 CURSOR Root_Cur (P_Object_ID IN NUMBER) IS
 SELECT CIR.OBJECT_ID
 FROM CSI_II_RELATIONSHIPS CIR
 START WITH Object_Id = P_Object_ID
 CONNECT BY PRIOR OBJECT_ID = SUBJECT_ID
 ORDER BY OBJECT_ID;
 l_Root_Id NUMBER;

BEGIN
   OPEN Root_Cur(P_Customer_Product_ID);
   FETCH Root_Cur INTO l_root_Id;
   CLOSE Root_Cur;
 IF l_Root_Id IS NULL
 THEN l_Root_Id := P_Customer_Product_ID;
 END IF;
 RETURN l_Root_ID;
EXCEPTION
 WHEN OTHERS
 THEN RETURN NULL;
END Get_RooT_Id;
END CSICUMPI_PUB;

/
