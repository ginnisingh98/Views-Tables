--------------------------------------------------------
--  DDL for Package Body MRP_EXPL_STD_MANDATORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_EXPL_STD_MANDATORY" AS
/* $Header: MRPDSODB.pls 120.7 2007/12/07 11:54:34 rsyadav ship $ */

 G_MRP_BACKWARD_PRF    varchar2(1) := nvl(FND_PROFILE.VALUE('MRP_NEW_PLANNER_BACK_COMPATIBILITY'),'Y');
 G_BOM_GREATER_THAN_EQUAL_J     NUMBER := 1;

FUNCTION explode_line(pLineId                 in number,
                      p_wip_demand_exists    in number,
                      pLRN                    in number,
		      pITEM_TYPE_CODE         in varchar2,
                      xErrorMessage out NOCOPY varchar2,
                      xMessageName  out NOCOPY varchar2,
                      xTableName    out NOCOPY varchar2)
       RETURN INTEGER IS
         lStatus      integer;
         i            number;

         temp         number  := null;
         temp1        date    := null;
         l_component_ship_date  date;

         p_atp_table             MRP_ATP_PUB.ATP_Rec_Typ;
         l_smc_table             MRP_ATP_PUB.ATP_Rec_Typ;

         lv_temp_sql_stmt          VARCHAR2(2000);
         lv_wip_demand_exists_flag NUMBER;

       BEGIN
          SELECT
           oel.inventory_item_id,
           oel.ship_from_org_id,
           oel.org_id,
           oel.line_id,
           oel.header_id,
	   oel.ordered_quantity, /* Always explode using ordered quantity, use lv_wip_demand_exists to manipulate quantities*/
           oel.order_quantity_uom,
           nvl(oel.schedule_ship_date,oel.request_date),
           oel.demand_class_code,
           temp,      -- calling module
           temp,      -- customer_id
           temp,      -- customer_site_id
           temp,      -- destination_time_zone
           oel.schedule_arrival_date,
           temp1,     -- latest acceptable_date
           oel.delivery_lead_time ,  -- delivery lead time
           temp,      -- Freight_Carrier
           temp,      -- Ship_Method
           temp,      --Ship_Set_Name
           temp,      -- Arrival_Set_Name
           1,         -- Override_Flag
           temp,      -- Action
           temp1,     -- Ship_date
           temp,      -- available_quantity
           temp,      -- requested_date_quantity
           temp1,     -- group_ship_date
           temp1,     -- group_arrival_date
           temp,      -- vendor_id
           temp,      -- vendor_site_id
           temp,      -- insert_flag
           temp,      -- error_code
           temp       -- Message
        BULK COLLECT INTO
           p_atp_table.Inventory_Item_Id       ,
           p_atp_table.Source_Organization_Id  ,
           p_atp_table.Organization_id         ,
           p_atp_table.Identifier              ,
           p_atp_table.Demand_Source_Header_Id ,
           p_atp_table.Quantity_Ordered        ,
           p_atp_table.Quantity_UOM            ,
           p_atp_table.Requested_Ship_Date     ,
           p_atp_table.Demand_Class            ,
           p_atp_table.Calling_Module          ,
           p_atp_table.Customer_Id             ,
           p_atp_table.Customer_Site_Id        ,
           p_atp_table.Destination_Time_Zone   ,
           p_atp_table.Requested_Arrival_Date  ,
           p_atp_table.Latest_Acceptable_Date  ,
           p_atp_table.Delivery_Lead_Time      ,
           p_atp_table.Freight_Carrier         ,
           p_atp_table.Ship_Method             ,
           p_atp_table.Ship_Set_Name           ,
           p_atp_table.Arrival_Set_Name        ,
           p_atp_table.Override_Flag           ,
           p_atp_table.Action                  ,
           p_atp_table.Ship_Date               ,
           p_atp_table.Available_Quantity      ,
           p_atp_table.Requested_Date_Quantity ,
           p_atp_table.Group_Ship_Date         ,
           p_atp_table.Group_Arrival_Date      ,
           p_atp_table.Vendor_Id               ,
           p_atp_table.Vendor_Site_Id          ,
           p_atp_table.Insert_Flag             ,
           p_atp_table.Error_Code              ,
           p_atp_table.Message
   FROM  oe_order_lines_all  oel
   WHERE oel.line_id = pLineId;


/* Passing NULL for source_organization_id and inventory_item_id so that CTO
   determines the BOMs, if any, for the Model and it's option Class(es) and
   explodes them */

     lstatus := CTO_CONFIG_ITEM_PK.Get_Mandatory_Components(
                    p_atp_table, --p_ship_set in MRP_ATP_PUB.ATP_Rec_Typ
                    NULL,
                    NULL,
                    l_smc_table, --p_sm_rec out MRP_ATP_PUB.ATP_Rec_Typ
                    xErrorMessage,
                    xMessageName,
                    xTableName );

    IF lstatus = 0 THEN
            return (0);
    END IF;

    lv_wip_demand_exists_flag := 0;  --initialize it to 0 every time

    IF l_smc_table.inventory_item_id.EXISTS(1) THEN
        l_component_ship_date := MRP_CALENDAR.date_offset(
                                 p_atp_table.Source_Organization_id(1),
                                 1,/* Daily Bucket */
                                 p_atp_table.Requested_Ship_Date(1),
                                 -(NVL(l_smc_table.atp_lead_time(1),0)));


       /* Bug 2550996 - Check if component demand exists for component in wip...if it
              does we will set the primary qty to 0 in mrp_derived_so_demands -- Removed this code*/

		   /*---------------------------------------------------------------------------------------+
		    |   If the job for the config Item exists, get that the value of wip_job_demand existsr |
	            |         from the arguments passed                                                     |
                    |	For Models lv_wip_demand_exists_flag will be always taken as 0                      |
		    +---------------------------------------------------------------------------------------*/
    IF (p_wip_demand_exists <> -1) THEN
        lv_wip_demand_exists_flag :=   p_wip_demand_exists;
    END IF;

    FORALL i in l_smc_table.inventory_item_id.FIRST .. l_smc_table.inventory_item_id.LAST
          INSERT INTO MRP_DERIVED_SO_DEMANDS
               (INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                PRIMARY_UOM_QUANTITY,
                RESERVATION_TYPE,
                RESERVATION_QUANTITY,
                DEMAND_SOURCE_TYPE,
                DEMAND_HEADER_ID,
                COMPLETED_QUANTITY,
                SUBINVENTORY,
                DEMAND_CLASS,
                REQUIREMENT_DATE,
                DEMAND_SOURCE_LINE,
                DEMAND_SOURCE_DELIVERY,
                PARENT_DEMAND_ID,
                DEMAND_ID,
                SALES_CONTACT,
                REFRESH_NUMBER
               )
               VALUES(
                l_smc_table.inventory_item_id(i),
                  p_atp_table.Source_Organization_Id(1),
                DECODE(lv_wip_demand_exists_flag,0,
		      decode(pITEM_TYPE_CODE,'MODEL',
                           NVL(inv_decimals_pub.get_primary_quantity(
                                     p_atp_table.Source_Organization_Id(1),
                                     l_smc_table.inventory_item_id(i),
                                     p_atp_table.Quantity_UOM(1),
                                     l_smc_table.quantity_ordered(i)),
                                     l_smc_table.quantity_ordered(i)),
                        decode(to_number(l_smc_table.attribute_01(i)),6,
		         decode(G_MRP_BACKWARD_PRF,'N',0,
			   NVL(inv_decimals_pub.get_primary_quantity(
                                     p_atp_table.Source_Organization_Id(1),
                                     l_smc_table.inventory_item_id(i),
                                     p_atp_table.Quantity_UOM(1),
                                     l_smc_table.quantity_ordered(i)),
                                     l_smc_table.quantity_ordered(i))),
                         NVL(inv_decimals_pub.get_primary_quantity(
                                     p_atp_table.Source_Organization_Id(1),
                                     l_smc_table.inventory_item_id(i),
                                     p_atp_table.Quantity_UOM(1),
                                     l_smc_table.quantity_ordered(i)),
                                     l_smc_table.quantity_ordered(i))
				     )),
                         0),
                1,              /*Reservation Type*/
                0,              /*Reservation Quantity*/
                2,              /*DEMAND_SOURCE_TYPE*/
                p_atp_table.Demand_Source_Header_Id(1),
                0,              /*Completed Quantity*/
                TO_CHAR(NULL),  /*subinventory*/
                p_atp_table.Demand_Class(1),
                l_component_ship_date,
                TO_CHAR(l_smc_table.identifier(i)),
                TO_CHAR(NULL),         /*demand source delivery*/
                TO_NUMBER(NULL),       /*parent demand id*/
                l_smc_table.identifier(i),               /*demand id */
                to_char(null),         /* Sales_rep */
                pLRN                 /* Refresh number, -1 means complete refresh */
                );
      END IF;

      COMMIT;
      return(1);

      exception
        when others then
          return (0);

END explode_line;


FUNCTION Explode_ATO_SM_COMPS(p_lrn IN NUMBER) RETURN INTEGER IS

        lErrorMessage varchar2(100);
        lMessageName  varchar2(100);
        lTableName    varchar2(100);

        pLineId                 number;
        temp                    number;

        p_get_oe_record         GET_OE_Rec_Typ;

	lv_offset_ship_date     date;
        lv_wip_demand_exists    number;
        lv_item_id              number;
        lv_organization_id      number;
        lv_wip_supply_type      number := 0;
        lv_lrn                  number;
	lv_ato_item_shipped     number;

        pATOLineID              number;
	pItemCode               varchar2(10);

        lv_cursor_stmt          VARCHAR2(5000);
        lv_sql_stmt             VARCHAR2(2000);
        lv_sql_stmt1            VARCHAR2(2000);
        lv_mrp_schema           VARCHAR2(30);

        TYPE CurTyp IS          REF CURSOR;
        Order_Line_Cur          CurTyp;
        lv_config               number := 0;
        CTO_BOM_NOT_FOUND       EXCEPTION;

        lv_bom_version 		NUMBER;
        lv_bom_table 		VARCHAR2(30);
        lv_comp_table 		VARCHAR2(30);

BEGIN

    SELECT a.oracle_username
      INTO lv_mrp_schema
      FROM FND_ORACLE_USERID a, FND_PRODUCT_INSTALLATIONS b
     WHERE a.oracle_id = b.oracle_id
       and b.application_id= 704;

      lv_sql_stmt:= 'select MRP_CL_FUNCTION.CHECK_BOM_VER from dual';

      EXECUTE IMMEDIATE lv_sql_stmt
      INTO lv_bom_version;

      IF lv_bom_version = G_BOM_GREATER_THAN_EQUAL_J THEN
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '11510 or greater source');
         lv_comp_table:='bom_components_b';
         lv_bom_table:='bom_structures_b';
      ELSE
         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Pre 11510 source');
         lv_comp_table:='bom_inventory_components';
         lv_bom_table:='bom_bill_of_materials';
      END IF;

      BEGIN
         lv_sql_stmt:= 'TRUNCATE TABLE '||lv_mrp_schema||'.MRP_DERIVED_SO_DEMANDS';
         EXECUTE IMMEDIATE lv_sql_stmt;

         MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Value of p_lrn is :'||p_lrn);

      EXCEPTION
         WHEN OTHERS THEN
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, sqlerrm);
      END;

      IF (p_lrn <> -1) THEN       --- net change collection of Sales orders
        lv_cursor_stmt :=
              '    SELECT /*+ index(oel oe_odr_lines_sn_n1) */ oel.LINE_ID , oel.ATO_LINE_ID ,oel.ITEM_TYPE_CODE,oel.RN, '
            ||'    oel.INVENTORY_ITEM_ID, oel.organization_id '
            ||'    FROM MRP_SN_ODR_LINES oel '
            ||'    WHERE  ato_line_id is not null'
            ||'     AND item_type_code in (''MODEL'',''STANDARD'',''CONFIG'')  '
            ||'    AND ( oel.rn > :p_lrn ) '
            ||' UNION ALL'
            ||'    SELECT /*+ index(mr mtl_reservations_sn_n1) */ oel.LINE_ID , oel.ATO_LINE_ID ,oel.ITEM_TYPE_CODE,oel.RN, '
            ||'    oel.INVENTORY_ITEM_ID, oel.organization_id '
            ||'    FROM MRP_SN_ODR_LINES oel, '
            ||'         MRP_SN_MTL_RESERVATIONS mr '
            ||'    WHERE  ato_line_id is not null'
            ||'     AND item_type_code in (''MODEL'',''STANDARD'',''CONFIG'')  '
            ||'     AND mr.DEMAND_SOURCE_LINE_ID = oel.LINE_ID  '
            ||'    AND ( mr.RN > :p_lrn AND oel.RN <= :p_lrn) '
	        ||'    ORDER BY organization_id ';

        OPEN Order_Line_Cur for lv_cursor_stmt USING p_lrn, p_lrn, p_lrn;

      ELSE
		---Complete refresh of the Sales Orders
        lv_cursor_stmt :=
              '    SELECT UNIQUE oel.LINE_ID , oel.ATO_LINE_ID ,oel.ITEM_TYPE_CODE,oel.RN, oel.INVENTORY_ITEM_ID, oel.organization_id '
            ||'    FROM MRP_SN_ODR_LINES oel '
            ||'    WHERE  ato_line_id is not null'
            ||'      AND ordered_quantity > NVL(shipped_quantity,0) '
            ||'      AND item_type_code in (''MODEL'',''STANDARD'',''CONFIG'')   '
	        ||'    ORDER BY oel.organization_id ';

        OPEN Order_Line_Cur for lv_cursor_stmt;

      END IF;

  LOOP
    FETCH Order_Line_Cur INTO
           pLineId ,pATOLineId, pItemCode,lv_lrn,lv_item_id,lv_organization_id;
    EXIT WHEN Order_Line_Cur%NOTFOUND;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Value of p_lrn is :'||p_lrn);
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Value of lv_lrn is :'||lv_lrn);
    IF (p_lrn = -1) THEN
        lv_lrn := 0;
    END IF;

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Value of lv_lrn is :'||lv_lrn);

      lv_wip_demand_exists := 0;

      BEGIN

        lv_sql_stmt1 := ' SELECT 1 '
                      ||' FROM  mtl_reservations '
                      ||' WHERE demand_source_line_id = :pLineId  '
                      ||' AND SUPPLY_SOURCE_TYPE_ID in (5,13)  '
	              ||' AND rownum = 1 ';

	EXECUTE IMMEDIATE lv_sql_stmt1
	             INTO lv_wip_demand_exists
		     USING pLineId;

	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, ' Job Exists for line id :'||pLineId );

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 NULL;
         WHEN OTHERS THEN
                 NULL;
      END;

   IF lv_wip_demand_exists = 0 THEN

      BEGIN

        lv_sql_stmt1 := ' SELECT 1 '
                      ||' FROM  WIP_FLOW_SCHEDULES '
                      ||' WHERE demand_source_line = to_char(:pLineId)  '
                      ||' AND SCHEDULED_FLAG = 1 '
                      ||' AND (STATUS = 1 OR (STATUS = 2 AND QUANTITY_COMPLETED > 0)) '
                      ||' AND rownum = 1 ';

        EXECUTE IMMEDIATE lv_sql_stmt1
                     INTO lv_wip_demand_exists
                     USING pLineId;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 NULL;
         WHEN OTHERS THEN
                 NULL;
      END;

   END IF;


    IF (pItemCode = 'CONFIG') THEN

        SELECT
              oel.inventory_item_id,
              oel.ship_from_org_id,
              oel.org_id,
              oel.line_id,
              oel.header_id,
	      decode(NVL(oel.shipped_quantity,0),0,oel.ordered_quantity,0),
              oel.order_quantity_uom,
              nvl(oel.schedule_ship_date,oel.request_date),
              oel.demand_class_code,
	      nvl(oel.mfg_lead_time,0),
	      oel.ITEM_TYPE_CODE
        BULK COLLECT INTO
              p_get_oe_record.Inventory_Item_Id       ,
              p_get_oe_record.Source_Organization_Id  ,
              p_get_oe_record.Organization_id         ,
              p_get_oe_record.Identifier              ,
              p_get_oe_record.Demand_Source_Header_Id ,
              p_get_oe_record.Quantity_Ordered        ,
              p_get_oe_record.Quantity_UOM            ,
              p_get_oe_record.Requested_Ship_Date     ,
              p_get_oe_record.Demand_Class           ,
	      p_get_oe_record.mfg_lead_time,
	      p_get_oe_record.ITEM_TYPE_CODE
        FROM  oe_order_lines_all  oel
        WHERE oel.ato_line_id = pATOLineId
          AND oel.line_id <> pLineId;

    IF p_get_oe_record.inventory_item_id.EXISTS(1) THEN

    BEGIN

     FOR i in p_get_oe_record.inventory_item_id.FIRST..p_get_oe_record.inventory_item_id.LAST  LOOP

      IF p_get_oe_record.ITEM_TYPE_CODE(i) = 'OPTION' THEN

       BEGIN

          lv_sql_stmt1 := 'select NVL(bic.wip_supply_type, msi.wip_supply_type) '
          ||' from ' || lv_comp_table || ' bic, ' || lv_bom_table || ' bbom '
          ||', mtl_system_items msi'
          ||' where  bbom.assembly_item_id = :lv_item_id '
          ||' and    bbom.organization_id = :Source_Organization_Id '
          ||' and    bbom.alternate_bom_designator IS NULL '
          ||' and    bic.bill_sequence_id = bbom.common_bill_sequence_id '
          ||' and    bic.component_item_id = :Inventory_Item_Id '
          ||' and    msi.inventory_item_id = bic.component_item_id '
          ||' and    msi.organization_id = bbom.organization_id '
          ||' and    rownum = 1 ';

	  MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'sql statement : ' || lv_sql_stmt1);

	  EXECUTE IMMEDIATE lv_sql_stmt1
		INTO lv_wip_supply_type
                USING lv_item_id,
                      p_get_oe_record.Source_Organization_Id(i), p_get_oe_record.Inventory_Item_Id(i);

       EXCEPTION
         WHEN NO_DATA_FOUND THEN

              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '========================================');
              FND_MESSAGE.SET_NAME('MSC', 'MSC_CONFIG_BOM_ORG_ERR');
              FND_MESSAGE.SET_TOKEN('ITEM_ID', to_char(lv_item_id));
              FND_MESSAGE.SET_TOKEN('ORG_ID', to_char(p_get_oe_record.Source_Organization_Id(i)));
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, FND_MESSAGE.GET);
              MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, '========================================');
              RAISE CTO_BOM_NOT_FOUND;

         WHEN OTHERS THEN
                 NULL;
      END;

       END IF;

       lv_offset_ship_date := MRP_CALENDAR.date_offset(
                                 p_get_oe_record.Source_Organization_id(1),
                                 1,/* Daily Bucket */
                                 p_get_oe_record.Requested_Ship_Date(1),
                                 -(p_get_oe_record.mfg_lead_time(i) ) );

      -- BUG 5211838
      -- We no longer the derive the sales order demand for ATO Model and
      -- Option Class on which a Configured Item is based.
      -- This removes the double demand for ATO model/Option Class after
      -- a configured item is created.
      -- This helps an user doing ATP on ATO Model/ Option Class.
      -- The user should ensure that he runs the source MPS plan before
      -- data collection.

          INSERT INTO MRP_DERIVED_SO_DEMANDS
               (INVENTORY_ITEM_ID,
                ORGANIZATION_ID,
                PRIMARY_UOM_QUANTITY,
                RESERVATION_TYPE,
                RESERVATION_QUANTITY,
                DEMAND_SOURCE_TYPE,
                DEMAND_HEADER_ID,
                COMPLETED_QUANTITY,
                SUBINVENTORY,
                DEMAND_CLASS,
                REQUIREMENT_DATE,
                DEMAND_SOURCE_LINE,
                DEMAND_SOURCE_DELIVERY,
                PARENT_DEMAND_ID,
                DEMAND_ID,
                SALES_CONTACT,
                REFRESH_NUMBER
               )
           VALUES(
		   p_get_oe_record.inventory_item_id(i),
		   p_get_oe_record.Source_Organization_Id(i),
		   decode(lv_wip_demand_exists,0,
					  decode(p_get_oe_record.ITEM_TYPE_CODE(i),
							 'MODEL', 0,
							 'CLASS', 0,
							 decode(lv_wip_supply_type,
									6, decode(G_MRP_BACKWARD_PRF,
											  'N',0,
											  NVL(inv_decimals_pub.get_primary_quantity(
																     p_get_oe_record.Source_Organization_Id(i),
																     p_get_oe_record.inventory_item_id(i),
																     p_get_oe_record.Quantity_UOM(i),
																     p_get_oe_record.quantity_ordered(i)),
												                                     p_get_oe_record.quantity_ordered(i))),
									NVL(inv_decimals_pub.get_primary_quantity(
														  p_get_oe_record.Source_Organization_Id(i),
														  p_get_oe_record.inventory_item_id(i),
														  p_get_oe_record.Quantity_UOM(i),
														  p_get_oe_record.quantity_ordered(i)),
										                                  p_get_oe_record.quantity_ordered(i)))),
							 0),
		1,              /*Reservation Type*/
		0,              /*Reservation Quantity*/
		2,              /*DEMAND_SOURCE_TYPE*/
		p_get_oe_record.Demand_Source_Header_Id(i),
		0,              /*Completed Quantity*/
		TO_CHAR(NULL),  /*subinventory*/
		p_get_oe_record.Demand_Class(i),
		lv_offset_ship_date,
		TO_CHAR(p_get_oe_record.Identifier(i)),
		TO_CHAR(NULL),         /*demand source delivery*/
		TO_NUMBER(NULL),       /*parent demand id*/
		p_get_oe_record.Identifier(i),               /*demand id */
		to_char(null),         /* Sales_rep */
		lv_lrn        /* Refresh number, -1 means complete refresh */
		);

        lv_wip_supply_type := 0; /* re-setting value */

        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Inserting row for :' || p_get_oe_record.Identifier(i) );

                      /* explode the model from the Config */
        IF (p_get_oe_record.ITEM_TYPE_CODE(i) = 'MODEL') THEN

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Exploding the model of the config');
            /* If the wip job of the Config has been created,
                explode the model and bring all the SMC's under it as quantity = 0 (including phantom)  .
		 Also if the S.O has been shipped get the SMC's with qty = 0 */
            /* lv_wip_demand_exists controls the quantity in the explode_line function , if 1 then quantities go as 0*/
            IF (p_get_oe_record.quantity_ordered(i) = 0 ) THEN
	       lv_wip_demand_exists := 1;
            END IF;

                temp:= explode_line(p_get_oe_record.Identifier(i),
				    lv_wip_demand_exists,
                                    lv_lrn,
				    pItemCode,
                                    lErrorMessage,
				    lMessageName,
				    lTableName);

                MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Exploding the model for the config is completed.');
	END IF;

        END LOOP;

        EXCEPTION
         WHEN CTO_BOM_NOT_FOUND THEN
            lv_config := 1;
         WHEN OTHERS THEN
                 NULL;

         END;

       END IF;

    ELSIF (pItemCode = 'STANDARD' ) THEN
       /* Explode the ATO Item to get the SMC's under it*/
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1, 'Exploding the ATO Item: Line_id = '||pLineId);

       /* If the ATO item is shipped, get 1 into lv_ato_item_shipped,
	  else get the value of 0 */
       SELECT decode(NVL(oel.shipped_quantity,0),0,0,1)
         INTO lv_ato_item_shipped
         FROM oe_order_lines_all  oel
        WHERE oel.line_id = pLineId;

         /* If the ATO item is shipped then get the SMC's qty = 0 */
         IF (lv_ato_item_shipped = 1) THEN
	     lv_wip_demand_exists := 1;
         END IF;

       temp:= explode_line(pLineId,
			   lv_wip_demand_exists,
                           lv_lrn,
			   pItemCode,
                           lErrorMessage,
			   lMessageName,
			   lTableName);

    ELSIF (pItemCode = 'MODEL' ) THEN

      lv_wip_demand_exists := -1;
     /* Explode the Regular ATO Model to get the SMC's under it*/
        temp:= explode_line(pLineId,
			    lv_wip_demand_exists,
                            lv_lrn,
			    pItemCode,
                            lErrorMessage,
			    lMessageName,
			    lTableName);

    END IF;

   END LOOP;

  CLOSE Order_Line_Cur;

   if lv_config <> 0 then
     return (2);
   else
     return(0);
   end if;

   exception
     when others then
        MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_DEBUG_1,  SQLERRM);
        return(1);

END Explode_ATO_SM_COMPS;

   PROCEDURE LOG_ERROR(pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

	-- add a line of text to the log file if MRP:Debug profile is set
	IF (G_MRP_DEBUG = 'Y') THEN
	      FND_FILE.PUT_LINE(FND_FILE.LOG, pBUFF);
	END IF;

   END LOG_ERROR;


END MRP_EXPL_STD_MANDATORY;

/
