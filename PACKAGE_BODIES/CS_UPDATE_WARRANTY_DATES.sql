--------------------------------------------------------
--  DDL for Package Body CS_UPDATE_WARRANTY_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_UPDATE_WARRANTY_DATES" as
/* $Header: csxsvuwb.pls 115.0 99/07/16 09:09:24 porting ship $ */
  Procedure Update_Warranty_Dates (
			X_Customer_Product_ID		NUMBER,
			X_Start_Date			DATE,
			X_Day_UOM			VARCHAR2
			) IS

  CURSOR CP_Service_Cursor IS
    SELECT srv.service_inventory_item_id         item_id,
           srv_item.service_duration             duration_quantity,
	   srv_item.service_duration_period_code duration_uom
    FROM CS_CP_SERVICES srv, MTL_SYSTEM_ITEMS srv_item
    WHERE srv.customer_product_id = X_Customer_Product_ID
      AND srv.warranty_flag = 'Y'
      AND srv.service_inventory_item_id = srv_item.inventory_item_id (+)
    FOR UPDATE OF srv.start_date_active,
		  srv.end_date_active;

  service_duration_days NUMBER;

  BEGIN
    FOR CP_Service_Rec IN CP_Service_Cursor LOOP
      IF (CP_Service_Rec.duration_quantity IS NOT NULL) AND
         (CP_Service_Rec.duration_uom IS NOT NULL)      THEN
        service_duration_days := inv_convert.inv_um_convert(
	  				CP_Service_Rec.item_id,
					NULL,
					CP_Service_Rec.duration_quantity,
					CP_Service_Rec.duration_uom,
					X_Day_UOM,
					NULL,
					NULL);

        UPDATE CS_CP_SERVICES
          SET Start_Date_Active = X_Start_Date,
              End_Date_Active   = Round(X_Start_Date + service_duration_days)
          WHERE CURRENT OF CP_Service_Cursor;
      END IF;
    END LOOP;
  END Update_Warranty_Dates;

END CS_UPDATE_WARRANTY_DATES;

/
