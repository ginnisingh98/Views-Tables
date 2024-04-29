--------------------------------------------------------
--  DDL for Package Body FTE_TRACKING_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TRACKING_WRAPPER" as
/* $Header: FTETKWRB.pls 120.6 2006/02/13 16:05:22 schennal noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TRACKING_WRAPPER';

--========================================================================
-- PROCEDURE : populate_child_delivery_legs    FTE Tracking wrapper
--
-- COMMENT   : Populate the child legs when Tracking information is
--             sent for the parent_delivery i.e Populate FTE_SHIPMENT_
--             STATUS_HEADERS, FTE_SHIPMENT_STATUS_DETAIL, FTE_DELIVERY_PROOF
--========================================================================

PROCEDURE  populate_child_delivery_legs
 (
 p_init_msg_list          IN   VARCHAR2,
 p_delivery_leg_id IN NUMBER,
 p_transaction_id IN NUMBER,
 p_carrier_id  IN NUMBER,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count             OUT NOCOPY NUMBER,
 x_msg_data              OUT NOCOPY VARCHAR2
 ) is

	cursor c_child_delivery_leg (c_parent_delivery_leg_id NUMBER) is
	select delivery_leg_id, delivery_id from
	wsh_Delivery_legs where parent_delivery_leg_id = c_parent_delivery_leg_id;


	l_transaction_id_s number ;
	l_activity_id_s  number;
	l_address_to_id  number;
	l_content_details_id  number;
	l_content_pod_id  number;
	l_message_partner_id  number;
	l_content_exceptions_id  number;

	l_delivery_leg_id number;
	l_delivery_id number;


	--Added for Funtional workflow
	l_organization_id          NUMBER;
	l_parameter_list           wf_parameter_list_t;
        l_delivery_id_tk           NUMBER;
	l_return_statuswf 	   VARCHAR2(1);

	l_received_date  DATE;
	l_flag number;

	--Declaration to handle out parameter
	l_exception_message        VARCHAR2(2000);
	l_return_status            NUMBER;
        l_error_token_text         NUMBER;
	l_error_id                 NUMBER;
	l_sql_error_code           VARCHAR2(2000);
	l_sql_error_msg            VARCHAR2(2000);
	l_procedure_name           VARCHAR2(240) := 'FTE_TRACKING_WRAPPER.populate_child_delivery_legs';

	 cursor get_org_delivery_info ( c_delivery_leg_id NUMBER) IS
	SELECT wnd.delivery_id, wnd.organization_id FROM
	wsh_delivery_legs wdl, wsh_new_deliveries wnd
	WHERE wdl.delivery_id = wnd.delivery_id AND
	wdl.delivery_leg_id = c_delivery_leg_id;

	BEGIN
	SAVEPOINT POPULATE_CHILD_LEGS_PUB;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;
	--
	--
	--  Initialize API return status to success
	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= '';



	OPEN c_child_delivery_leg(p_delivery_leg_id);
	LOOP
		FETCH c_child_delivery_leg into l_delivery_leg_id,l_delivery_id;
		EXIT when c_child_delivery_leg%NOTFOUND;


		--Create a new Transaction id for  records in headers/detail/proof
		select FTE_TRACKING_TRANSACTION_S.nextval into l_transaction_id_s from dual;


		--Create a new Activity Id to record the activity in Activities table
		select WSH_DELIVERY_LEG_ACTIVITIES_S.nextval into l_activity_id_s from dual;


		--Insert into Activities table
		insert into wsh_delivery_leg_activities
		(activity_id, delivery_leg_id, activity_date, activity_type,
		creation_date, created_by, last_update_date, last_updated_by)
		values
		(l_activity_id_s, l_delivery_leg_id, sysdate, 'TRACKING',
		sysdate, p_carrier_id, sysdate, p_carrier_id);
		begin
		 --Insert into Headers table
		insert into fte_shipment_status_headers(
				 TRANSACTION_ID, delivery_leg_id, delivery_id, MESSAGE_TYPE, SHIPMENT_STATUS_ID,
				 CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
				 CARRIER_NAME,  GENERATION_DATE , STATUS , TRACKING_ID, TRACKING_ID_TYPE,
				 BILL_OF_LADING , CARRIER_SERVICE_LEVEL,  CONTAINER_ID ,  CONTAINER_SEAL ,
				 ARRIVAL_DATE,  RECEIVED_DATE , DELIVERY_SCHEDULED_DATE , DEPARTURE_DATE,
				 ESTIMATED_ARRIVAL_DATE,   ESTIMATED_DEPARTURE_DATE,  BEGIN_LOADING_DATE,
				 END_LOADING_DATE , PROMISED_SHIPMENT_DATE , PROMISED_DELIVERY_DATE ,
				 SHIPPED_DATE,  EXPECTED_SHIPMENT_DATE,  BEGIN_UNLOADING_DATE,  END_UNLOADING_DATE ,
				 DESCRIPTION ,   FREIGHT_CLASS, HAZARDOUS_MATERIAL, LOAD_POINT, NOTES1,NOTES2 ,  NOTES3,
				 NOTES4 ,NOTES5,  NOTES6, NOTES7 , NOTES8 , NOTES9,
				 SHIP_UNIT_QUANTITY,  SHIP_UNIT_UOM, VOLUME , VOLUME_UOM  ,
				 WEIGHT,  WEIGHT_UOM,  ROUTE_ID , ROUTE_TYPE,
				 SHIP_NOTES, SHIPPER_NUMBER , SHIP_POINT, SPECIAL_HANDLING,
				 STOP_NUMBER, SHIPPING_METHOD, SHIP_FROM_PARTNER, SHIP_TO_PARTNER,
				 CARRIER_PARTNER,  BILL_TO_PARTNER,  NOTIFY_PARTNER,   HOLD_AT_PARTNER,  RETURN_TO_PARTNER, MARK_FOR_PARTNER,
				 IMPORTER_PARTNER,  EXPORTER_PARTNER,  DELIVERY_DETAIL_ID,  LICENSE_PLATE_NUMBER,  REASON_CODE,
				 ACTIVITY_ID
				 )
			       select
				 l_transaction_id_s, l_delivery_leg_id,l_delivery_id,
				 MESSAGE_TYPE, FTE_TRACKING_STATUS_S.nextval,
				 CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN,
				 CARRIER_NAME,  GENERATION_DATE , STATUS , TRACKING_ID, TRACKING_ID_TYPE,
				 BILL_OF_LADING , CARRIER_SERVICE_LEVEL,  CONTAINER_ID ,  CONTAINER_SEAL ,
				 ARRIVAL_DATE,  RECEIVED_DATE , DELIVERY_SCHEDULED_DATE , DEPARTURE_DATE,
				 ESTIMATED_ARRIVAL_DATE,   ESTIMATED_DEPARTURE_DATE,  BEGIN_LOADING_DATE,
				 END_LOADING_DATE , PROMISED_SHIPMENT_DATE , PROMISED_DELIVERY_DATE ,
				 SHIPPED_DATE,  EXPECTED_SHIPMENT_DATE,  BEGIN_UNLOADING_DATE,  END_UNLOADING_DATE ,
				 DESCRIPTION ,   FREIGHT_CLASS, HAZARDOUS_MATERIAL, LOAD_POINT, NOTES1,NOTES2 ,  NOTES3,
				 NOTES4 ,NOTES5,  NOTES6, NOTES7 , NOTES8 , NOTES9,
				 SHIP_UNIT_QUANTITY,  SHIP_UNIT_UOM, VOLUME , VOLUME_UOM  ,
				 WEIGHT,  WEIGHT_UOM,  ROUTE_ID , ROUTE_TYPE,
				 SHIP_NOTES, SHIPPER_NUMBER , SHIP_POINT, SPECIAL_HANDLING,
				 STOP_NUMBER, SHIPPING_METHOD, SHIP_FROM_PARTNER, SHIP_TO_PARTNER,
				 CARRIER_PARTNER,  BILL_TO_PARTNER,  NOTIFY_PARTNER,   HOLD_AT_PARTNER,  RETURN_TO_PARTNER, MARK_FOR_PARTNER,
				 IMPORTER_PARTNER,  EXPORTER_PARTNER,  DELIVERY_DETAIL_ID,  LICENSE_PLATE_NUMBER,  REASON_CODE,
				 l_activity_id_s
				from fte_shipment_status_headers where transaction_id  = p_transaction_id;
		EXCEPTION
			WHEN OTHERS THEN
			null;

		 END ;
		-- Insert into details table
		 BEGIN

			select fte_tracking_status_s.nextval into l_content_details_id from dual;
			insert into fte_shipment_status_details(
				SHIPMENT_STATUS_DETAIL_ID,
				DELIVERY_LEG_ID,
				TRANSACTION_ID,
				REPORT_DATE,
				SHIPMENT_STATUS,
				CHANGED_STATUS_DATE,
				DESCRIPTION,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				SHIP_UNIT_SEQ,
				SHIP_UNIT_TOTAL,
				TRACKING_ID,
				TRACKING_ID_TYPE)
				SELECT
				l_content_details_id,
				l_delivery_leg_id,
				l_transaction_id_s,
				REPORT_DATE,
				SHIPMENT_STATUS,
				CHANGED_STATUS_DATE,
				DESCRIPTION,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				SHIP_UNIT_SEQ,
				SHIP_UNIT_TOTAL,
				TRACKING_ID,
				TRACKING_ID_TYPE
				FROM fte_shipment_status_details WHERE transaction_id = p_transaction_id;

		EXCEPTION
			WHEN OTHERS THEN
				NULL; --No records in FTE_SHIPMENT_STATUS_DETAILS
		 END ;
		-- Insert into delivery proof table
		 BEGIN
			select  fte_tracking_status_s.nextval into l_content_pod_id from dual;
			insert into fte_delivery_proof(
				ID,
				TRANSACTION_ID,
				RECEIVED_DATE,
				--NAME1, -- to fix Bug#5031206
				SHIP_UNIT_QUANTITY,
				SHIP_UNIT_UOM,
				NOTES1,
				NOTES2,
				NOTES3,
				NOTES4,
				NOTES5,
				NOTES6,
				NOTES7,
				NOTES8,
				NOTES9,
				SHIP_UNIT_SEQ,
				SHIP_UNIT_TOTAL,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				TRACKING_ID,
				TRACKING_ID_TYPE,
				CONSIGNEE_NAME,
				STATUS,
				SHIPMENT_WEIGHT,
				SHIPMENT_VOLUME,
				LOCATION
				)
				SELECT
				l_content_pod_id,
				l_transaction_id_s,
				RECEIVED_DATE,
				--NAME1,  --To fix bug#5031206
				SHIP_UNIT_QUANTITY,
				SHIP_UNIT_UOM,
				NOTES1,
				NOTES2,
				NOTES3,
				NOTES4,
				NOTES5,
				NOTES6,
				NOTES7,
				NOTES8,
				NOTES9,
				SHIP_UNIT_SEQ,
				SHIP_UNIT_TOTAL,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,

				TRACKING_ID,
				TRACKING_ID_TYPE,
				CONSIGNEE_NAME,
				STATUS,
				SHIPMENT_WEIGHT,
				SHIPMENT_VOLUME,
				LOCATION
				FROM fte_delivery_proof WHERE transaction_id = p_transaction_id;
		EXCEPTION
			WHEN OTHERS THEN
				NULL; --No records in FTE_DELIVERY_PROOF table
		 END ;


		--Inserting into fte_message partner as per FTEFSSI XGM to content
		BEGIN

		select fte_tracking_status_s.nextval into l_address_to_id  from dual;
		INSERT INTO
		FTE_MESSAGE_PARTNER (
			 ID,
			 NAME1        ,
			 NAME2        ,
			 NAME3        ,
			 NAME4        ,
			 NAME5        ,
			 NAME6       ,
			 NAME7       ,
			 NAME8       ,
			 NAME9       ,
			 ONETIME     ,
			 PARTNER_ID  ,
			 PARTNER_TYPE ,
			 ACTIVE       ,
			 CURRENCY     ,
			 DESCRIPTION  ,
			 DUNS_NUMBER  ,
			 GL_ENTITIES  ,
			 PARENT_ID     ,
			 PARTNER_ID_X  ,
			 PARTNER_RATING,
			 PARTNER_ROLE  ,
			 PAYMENT_METHOD,
			 TAX_EXEMPT    ,
			 TAX_ID       ,
			 TERM_ID      ,
			 CREATED_BY   ,
			 CREATION_DATE   ,
			 LAST_UPDATED_BY ,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN  ,
			 SHIPPER_ACCOUNT_NUMBER,
			 TRANSACTION_ID)
			SELECT
			 l_address_to_id,
			 NAME1        ,
			 NAME2        ,
			 NAME3        ,
			 NAME4        ,
			 NAME5        ,
			 NAME6       ,
			 NAME7       ,
			 NAME8       ,
			 NAME9       ,
			 ONETIME     ,
			 PARTNER_ID  ,
			 PARTNER_TYPE ,
			 ACTIVE       ,
			 CURRENCY     ,
			 DESCRIPTION  ,
			 DUNS_NUMBER  ,
			 GL_ENTITIES  ,
			 PARENT_ID     ,
			 PARTNER_ID_X  ,
			 PARTNER_RATING,
			 PARTNER_ROLE  ,
			 PAYMENT_METHOD,
			 TAX_EXEMPT    ,
			 TAX_ID       ,
			 TERM_ID      ,
			 CREATED_BY   ,
			 CREATION_DATE   ,
			 LAST_UPDATED_BY ,
			 LAST_UPDATE_DATE,
			 LAST_UPDATE_LOGIN  ,
			 SHIPPER_ACCOUNT_NUMBER,
			 l_transaction_id_s from
			 fte_message_partner WHERE TRANSACTION_ID = l_transaction_id_s ;


			BEGIN
				INSERT INTO
				FTE_MESSAGE_CONTACT(
				 CONTACT_ID     ,
				 PARTNER_ID     ,
				 NAME1          ,
				 NAME2          ,
				 NAME3          ,
				 NAME4          ,
				 NAME5          ,
				 NAME6          ,
				 NAME7          ,
				 NAME8          ,
				 NAME9          ,
				 CONTACT_TYPE   ,
				 DESCRIPTION    ,
				 EMAIL          ,
				 FAX1           ,
				 FAX2           ,
				 FAX3           ,
				 FAX4           ,
				 FAX5           ,
				 FAX6           ,
				 FAX7           ,
				 FAX8           ,
				 FAX9           ,
				 TELEPHONE1     ,
				 TELEPHONE2     ,
				 TELEPHONE3     ,
				 TELEPHONE4     ,
				 TELEPHONE5     ,
				 TELEPHONE6     ,
				 TELEPHONE7     ,
				 TELEPHONE8     ,
				 TELEPHONE9     ,
				 CREATED_BY     ,
				 CREATION_DATE  ,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN,
				 TRANSACTION_ID
				 )
				SELECT
				 fte_tracking_status_s.nextval,
				 l_address_to_id,
				 NAME1          ,
				 NAME2          ,
				 NAME3          ,
				 NAME4          ,
				 NAME5          ,
				 NAME6          ,
				 NAME7          ,
				 NAME8          ,
				 NAME9          ,
				 CONTACT_TYPE   ,
				 DESCRIPTION    ,
				 EMAIL          ,
				 FAX1           ,
				 FAX2           ,
				 FAX3           ,
				 FAX4           ,
				 FAX5           ,
				 FAX6           ,
				 FAX7           ,
				 FAX8           ,
				 FAX9           ,
				 TELEPHONE1     ,
				 TELEPHONE2     ,
				 TELEPHONE3     ,
				 TELEPHONE4     ,
				 TELEPHONE5     ,
				 TELEPHONE6     ,
				 TELEPHONE7     ,
				 TELEPHONE8     ,
				 TELEPHONE9     ,
				 CREATED_BY     ,
				 CREATION_DATE  ,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATE_LOGIN,
				 l_transaction_id_s
				 FROM
				 FTE_MESSAGE_CONTACT WHERE
				 TRANSACTION_ID = p_transaction_id;
			 EXCEPTION
				WHEN OTHERS THEN
				null;
			END ;


		EXCEPTION
			WHEN OTHERS THEN
			null;
		END ;


		BEGIN
		INSERT INTO FTE_MESSAGE_LOCATION (
			 location_to_id,
			 ID                             ,
			 DESCRIPTION                    ,
			 GEOCOORDINATES                 ,
			 GEOCOORDINATES_TYPE            ,
			 LOCATION_ID                    ,
			 LOCATION_ID_TYPE               ,
			 SITELEVEL1                     ,
			 SITELEVEL2                     ,
			 SITELEVEL3                     ,
			 SITELEVEL4                     ,
			 SITELEVEL5                     ,
			 SITELEVEL6                     ,
			 SITELEVEL7                     ,
			 SITELEVEL8                     ,
			 SITELEVEL9                     ,
			 ADDRESS_ID                     ,
			 CREATED_BY                     ,
			 CREATION_DATE                  ,
			 LAST_UPDATED_BY                ,
			 LAST_UPDATE_DATE               ,
			 LAST_UPDATE_LOGIN              ,
			 TRANSACTION_ID                 ,
			 LOCATION_TO_TABLE
			)
			SELECT
			 DECODE(location_to_table,'FTE_DELIVERY_PROOF',l_content_pod_id,l_content_details_id),
			 fte_tracking_status_s.nextval,
			 DESCRIPTION                    ,
			 GEOCOORDINATES                 ,
			 GEOCOORDINATES_TYPE            ,
			 LOCATION_ID                    ,
			 LOCATION_ID_TYPE               ,
			 SITELEVEL1                     ,
			 SITELEVEL2                     ,
			 SITELEVEL3                     ,
			 SITELEVEL4                     ,
			 SITELEVEL5                     ,
			 SITELEVEL6                     ,
			 SITELEVEL7                     ,
			 SITELEVEL8                     ,
			 SITELEVEL9                     ,
			 ADDRESS_ID                     ,
			 CREATED_BY                     ,
			 CREATION_DATE                  ,
			 LAST_UPDATED_BY                ,
			 LAST_UPDATE_DATE               ,
			 LAST_UPDATE_LOGIN              ,
			 l_transaction_id_s             ,
			 LOCATION_TO_TABLE
			from
			  FTE_MESSAGE_LOCATION
			  where transaction_id = p_transaction_id;
		EXCEPTION
			WHEN OTHERS THEN
			null;
		END ;


		BEGIN
		INSERT INTO
		FTE_MESSAGE_ADDRESS(
			 ADDRESS_TO_ID,ID  ,
			 TRANSACTION_ID ,
			 ADDRESS_TO_TABLE    ,
			 ADDR_LINE1  ,
			 ADDR_LINE2  ,
			 ADDR_LINE3  ,
			 ADDR_LINE4  ,
			 ADDR_LINE5  ,
			 ADDR_LINE6  ,
			 ADDR_LINE7  ,
			 ADDR_LINE8  ,
			 ADDR_LINE9  ,
			 ADDR_TYPE   ,
			 ADDR_CITY   ,
			 ADDR_COUNTY ,
			 ADDR_COUNTRY   ,
			 ADDR_DESCRIPTION  ,
			 ADDR_POSTAL_CODE  ,
			 ADDR_REGION       ,
			 ADDR_STATE        ,
			 ADDR_TAX_JURISDICTION                   ,
			 ADDR_URL                                ,
			 FAX1                                    ,
			 FAX2                                    ,
			 FAX3                                    ,
			 FAX4                                    ,
			 FAX5                                    ,
			 FAX6                                    ,
			 FAX7                                    ,
			 FAX8                                    ,
			 FAX9                                    ,
			 TELEPHONE1                              ,
			 TELEPHONE2                              ,
			 TELEPHONE3                              ,
			 TELEPHONE4                              ,
			 TELEPHONE5                              ,
			 TELEPHONE6                              ,
			 TELEPHONE7                              ,
			 TELEPHONE8                              ,
			 TELEPHONE9                              ,
			 CREATED_BY                              ,
			 CREATION_DATE                          ,
			 LAST_UPDATED_BY                        ,
			 LAST_UPDATE_DATE                       ,
			 LAST_UPDATE_LOGIN   )
			SELECT
			 decode (ADDRESS_TO_TABLE,'FTE_MESSAGE_PARTNER',
						   l_address_to_id,
						   (select id from fte_message_location where
						    location_to_table =( SELECT fl.location_to_table
									 FROM  fte_message_location fl WHERE fl.id= fa.address_to_id
									 AND transaction_id = p_transaction_id ) and
						    transaction_id = l_transaction_id_s
						   )
				),
			 fte_tracking_status_s.nextval,
			 l_transaction_id_s ,
			 ADDRESS_TO_TABLE                      ,
			 ADDR_LINE1  ,
			 ADDR_LINE2  ,
			 ADDR_LINE3  ,
			 ADDR_LINE4  ,
			 ADDR_LINE5  ,
			 ADDR_LINE6  ,
			 ADDR_LINE7  ,
			 ADDR_LINE8  ,
			 ADDR_LINE9  ,
			 ADDR_TYPE   ,
			 ADDR_CITY   ,
			 ADDR_COUNTY ,
			 ADDR_COUNTRY   ,
			 ADDR_DESCRIPTION  ,
			 ADDR_POSTAL_CODE  ,
			 ADDR_REGION       ,
			 ADDR_STATE        ,
			 ADDR_TAX_JURISDICTION                   ,
			 ADDR_URL                                ,
			 FAX1                                    ,
			 FAX2                                    ,
			 FAX3                                    ,
			 FAX4                                    ,
			 FAX5                                    ,
			 FAX6                                    ,
			 FAX7                                    ,
			 FAX8                                    ,
			 FAX9                                    ,
			 TELEPHONE1                              ,
			 TELEPHONE2                              ,
			 TELEPHONE3                              ,
			 TELEPHONE4                              ,
			 TELEPHONE5                              ,
			 TELEPHONE6                              ,
			 TELEPHONE7                              ,
			 TELEPHONE8                              ,
			 TELEPHONE9                              ,
			 CREATED_BY                              ,
			 CREATION_DATE                          ,
			 LAST_UPDATED_BY                        ,
			 LAST_UPDATE_DATE                       ,
			 LAST_UPDATE_LOGIN
			 from fte_message_address fa
			 where transaction_id =p_transaction_id ;
		EXCEPTION
			WHEN OTHERS THEN
			l_exception_message := substr(SQLERRM,1,100);

		END ;

		BEGIN
			INSERT INTO FTE_SHIPMENT_STATUS_EXCEPTIONS
			(
			 DETAIL_ID                 ,
			 EXCEPTION_ID              ,
			 EXCEPTION_DATE            ,
			 DESCRIPTION               ,
			 REASON_CODE               ,
			 CREATED_BY                ,
			 CREATION_DATE             ,
			 LAST_UPDATED_BY           ,
			 LAST_UPDATE_DATE          ,
			 LAST_UPDATE_LOGIN         ,
			 LADING_QUANTITY           ,
			 LADING_QUANTITY_UOM       ,
			 TRANSACTION_ID
			)
			SELECT
			 l_content_details_id,
			 fte_tracking_status_s.nextval,
			 EXCEPTION_DATE            ,
			 DESCRIPTION               ,
			 REASON_CODE               ,
			 CREATED_BY                ,
			 CREATION_DATE             ,
			 LAST_UPDATED_BY           ,
			 LAST_UPDATE_DATE          ,
			 LAST_UPDATE_LOGIN         ,
			 LADING_QUANTITY           ,
			 LADING_QUANTITY_UOM       ,
			 l_transaction_id_s
			FROM  FTE_SHIPMENT_STATUS_EXCEPTIONS
			 WHERE TRANSACTION_ID = P_TRANSACTION_ID ;

			 select fte_tracking_status_s.currval into l_content_exceptions_id from dual;
		EXCEPTION
			WHEN OTHERS THEN
			null;
		END ;

		BEGIN
			INSERT INTO WSH_MESSAGE_ATTACHMENT
			(
			 ATTACHMENT_ID              ,
			 ATTACH_TO_ID               ,
			 ATTACH_TO_TABLE            ,
			 DESCRIPTION                ,
			 FILETYPE                   ,
			 TITLE                      ,
			 FILE_CREATION_DATE         ,
			 FILESIZE                   ,
			 FILESIZE_UOM               ,
			 FILENAME                   ,
			 URI                        ,
			 COMPRESSION_TYPE           ,
			 COMPRESSION_ID             ,
			 NOTES1                     ,
			 NOTES2                     ,
			 NOTES3                     ,
			 NOTES4                     ,
			 NOTES5                     ,
			 NOTES6                     ,
			 NOTES7                     ,
			 NOTES8                     ,
			 NOTES9                     ,
			 CREATED_BY                 ,
			 CREATION_DATE              ,
			 LAST_UPDATED_BY            ,
			 LAST_UPDATE_DATE           ,
			 LAST_UPDATE_LOGIN          ,
			 TRANSACTION_ID
			)
			SELECT
			 fte_tracking_status_s.nextval ,
			 DECODE(ATTACH_TO_TABLE,'FTE_MESSAGE_PARTNER',l_address_to_id,
						'FTE_SHIPMENT_STATUS_DETAILS',l_content_details_id,
						'FTE_SHIPMENT_STATUS_EXCEPTIONS',l_content_exceptions_id,
						l_content_pod_id),
			 ATTACH_TO_TABLE            ,
			 DESCRIPTION                ,
			 FILETYPE                   ,
			 TITLE                      ,
			 FILE_CREATION_DATE         ,
			 FILESIZE                   ,
			 FILESIZE_UOM               ,
			 FILENAME                   ,
			 URI                        ,
			 COMPRESSION_TYPE           ,
			 COMPRESSION_ID             ,
			 NOTES1                     ,
			 NOTES2                     ,
			 NOTES3                     ,
			 NOTES4                     ,
			 NOTES5                     ,
			 NOTES6                     ,
			 NOTES7                     ,
			 NOTES8                     ,
			 NOTES9                     ,
			 CREATED_BY                 ,
			 CREATION_DATE              ,
			 LAST_UPDATED_BY            ,
			 LAST_UPDATE_DATE           ,
			 LAST_UPDATE_LOGIN          ,
			 l_transaction_id_s
			 FROM
			WSH_MESSAGE_ATTACHMENT WHERE TRANSACTION_ID  = P_TRANSACTION_ID ;
		EXCEPTION
			WHEN OTHERS THEN
			null;
		END ;



		--To ensure that only one record exist in details and in delivery proof for
		--every transaction_id

		--     Call  the procedure get_delivery_details to delete all the
		--     details and POD information for a delivery leg and retain only the
		--     last detail and POD information

		FTE_TRACKING_WRAPPER.get_delivery_details ( l_transaction_id_s, p_carrier_id,
							     l_exception_message,
							     l_return_status, l_error_token_text);


		-- To update the recieced date for the last leg of a delivery when POD is received
		BEGIN
			select received_date,1 into l_received_date,l_flag
			from fte_delivery_proof where transaction_id= l_transaction_id_s;
		EXCEPTION
			WHEN OTHERS THEN
				NULL; --No records in FTE_DELIVERY_PROOF table
		 END ;

			IF l_flag= 1 THEN
				FTE_TRACKING_WRAPPER.call_last_delivery_leg(l_delivery_leg_id,l_received_date);
			ELSE
				--Added by shravisa for Release 12
				--Raise Workflow Tracking Event when ever Tracking information comes for any
				--Functional Workflow

			       OPEN get_org_delivery_info(l_delivery_leg_id);
			       FETCH get_org_delivery_info into l_delivery_id_tk,l_organization_id;
			       CLOSE get_org_delivery_info;



				wf_event.AddParameterToList(
					 p_name=>'ORGANIZATION_ID',
					 p_value  => l_organization_id,
					 p_parameterlist=> l_parameter_list);


				--Do not handle the Return status from this method
				WSH_WF_STD.raise_event(
					p_entity_type		=> 'DELIVERY',
					p_entity_id		=> TO_CHAR(l_delivery_id_tk),
					p_event			=> 'oracle.apps.fte.delivery.trk.matchtrackingadvice',
					p_parameters            => l_parameter_list,
					p_organization_id	=> l_organization_id,
					x_return_status		=> l_return_statuswf);
			END IF;


	END LOOP;
	CLOSE c_child_delivery_leg;


	EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		 ROLLBACK TO populate_child_legs_pub;
	                         select wsh_interface_errors_s.nextval into l_error_id
	                         from dual;

	                         FTE_TRACKING_WRAPPER.insert_error_status
	                         (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
	                          p_transaction_id,  3, 'ERROR', 'NO CHILD DELIVERY FOUND',
	                          p_carrier_id);

			        x_return_status     := FND_API.G_RET_STS_ERROR ;
				FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TRACKING_INFO');
		                FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_And_Get
				  (
				     p_count  => x_msg_count,
				     p_data  =>  x_msg_data,
				     p_encoded => FND_API.G_FALSE
				  );
 	WHEN OTHERS THEN
		ROLLBACK TO populate_child_legs_pub;
		select wsh_interface_errors_s.nextval into l_error_id
	                        from dual;

	                        FTE_TRACKING_WRAPPER.insert_error_status
	                        (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
	                         p_transaction_id,  5, 'ERROR', 'OTHER EXCEPTION',
	                         p_carrier_id);

	                         l_sql_error_code := to_char(SQLCODE);
	                         l_sql_error_msg  := substr(SQLERRM,1,2000);
	                         IF (l_exception_message IS NULL) THEN
	                         l_exception_message  :=
	                                                 (l_sql_error_code||':'||l_sql_error_msg||' : '
	                          ||' : '||l_procedure_name);
	                         END IF;
			         x_return_status     := FND_API.G_RET_STS_ERROR ;
				FND_MESSAGE.SET_NAME('FTE','FTE_INVALID_TRACKING_INFO');
		                FND_MSG_PUB.ADD;
				FND_MSG_PUB.Count_And_Get
				  (
				     p_count  => x_msg_count,
				     p_data  =>  x_msg_data,
				     p_encoded => FND_API.G_FALSE
				  );
END populate_child_delivery_legs;


--========================================================================
-- PROCEDURE : Get Location       FTE Tracking wrapper
--
-- COMMENT   : Get the city,state and country information from the
--             fte_message_address and populate the location cloumn of
--             fte_delivery_proof table using address_to_id as the foreign
--             key for fte_message_location .
--========================================================================

FUNCTION  GET_LOCATION(p_location_id IN NUMBER)
RETURN VARCHAR2
IS
        l_addr_state VARCHAR2(1000);
        l_addr_city VARCHAR2(1000);
        l_addr_country  VARCHAR2(1000);
        l_loca_csc      VARCHAR2(1000) ;
        CURSOR C_GET_CSC(p_loc_id NUMBER) IS
                SELECT  ADDR_CITY,
                        ADDR_STATE,
                        ADDR_COUNTRY
                FROM
                        FTE_MESSAGE_ADDRESS
                WHERE
                        ADDRESS_TO_ID=P_LOC_ID;
BEGIN

        --GET VALLUES FROM FTE_MESSAGE_ADDRESS
        OPEN  C_GET_CSC(p_location_id);
        FETCH C_GET_CSC INTO L_addr_CITY,L_addr_STATE,L_addr_COUNTRY;
        CLOSE C_GET_CSC;

        --CHECK FOR NULL AND CONCAT
        IF l_addr_city IS NOT  NULL THEN
                l_loca_csc := l_loca_csc || l_addr_city || ', ';
        END IF;
        IF l_addr_state IS NOT  NULL THEN
                l_loca_csc := l_loca_csc || l_ADDR_state || ', ';
        END IF;
        IF l_addr_country IS NOT NULL THEN
                l_loca_csc := l_loca_csc || l_addr_country;
        END IF;

        RETURN (l_loca_csc);
END GET_LOCATION;

--========================================================================
-- PROCEDURE : Insert_delete_delivery       FTE Tracking wrapper
--
-- COMMENT   : Insert the data from the header interface table to
--             wsh_delivery_leg_activities and wsh_delivery_leg_details.
--             Delete the record from the detail interface table if they are
--             repeated.
--========================================================================
PROCEDURE get_delivery_or_container(
                           p_transaction_id    IN  NUMBER,
                           x_exception_message OUT NOCOPY VARCHAR2,
                           x_return_status     OUT NOCOPY NUMBER,
                           x_error_token_text  OUT NOCOPY NUMBER)   IS
        l_delivery_id              NUMBER;
	l_delivery_id_tk              NUMBER;
        l_delivery_leg_id          NUMBER;
        l_delivery_detail_id       NUMBER;
        l_message_type             VARCHAR2(10);
        l_carrier_name             VARCHAR2(30);
        l_carrier_id               NUMBER;
        l_shipment_status          VARCHAR2(30);
        l_activity_date            DATE;
        l_arrival_date             DATE;
        l_departure_date           DATE;
        l_estimated_arrival_date   DATE;
        l_estimated_departure_date DATE;
        l_end_loading_date         DATE;
        l_begin_loading_date       DATE;
        l_end_unloading_date       DATE;
        l_begin_unloading_date     DATE;
        l_notes                    VARCHAR2(1000);
        l_description              VARCHAR2(1000);
        l_tracking_id              VARCHAR2(30);
        l_tracking_id_type         VARCHAR2(30);

	--Added for Funtional workflow
	l_organization_id          NUMBER;
	l_parameter_list     wf_parameter_list_t;

        -- Added for Bug
        l_received_date            DATE;

        l_waybill                  VARCHAR2(30);
        l_booking_number           VARCHAR2(30);
        l_container_name           VARCHAR2(30);
        l_seal_code                VARCHAR2(30);
        l_tracking_number          VARCHAR2(30);

        l_exception_message        VARCHAR2(2000);
        l_return_status            NUMBER;
        l_error_token_text         NUMBER;

        l_sql_error_code           VARCHAR2(2000);
        l_sql_error_msg            VARCHAR2(2000);
        l_procedure_name           VARCHAR2(240) := 'FTE_TRACKING_WRAPPER.get_delivery_or_container';

        invalid_carrier            EXCEPTION;
        no_license_plate           EXCEPTION;
        invalid_tracking_id_type   EXCEPTION;
        l_error_id                 NUMBER;
        l_location_id              NUMBER;
        l_location_code            VARCHAR2(100);
        l_address                  VARCHAR2(1000);
	l_flag                     NUMBER;
	l_msg_data		   VARCHAR2(2000);
	l_msg_count		   NUMBER;
	l_return_statusp 	   VARCHAR2(1);
	l_return_statuswf 	   VARCHAR2(1);

	cursor get_org_delivery_info ( c_delivery_leg_id NUMBER) IS
	SELECT wnd.delivery_id, wnd.organization_id FROM
	wsh_delivery_legs wdl, wsh_new_deliveries wnd
	WHERE wdl.delivery_id = wnd.delivery_id AND
	wdl.delivery_leg_id = c_delivery_leg_id;



   BEGIN



         --
         -- Set the return Status Flag
         --
         x_return_status     := 0;
         x_exception_message := null;
         x_error_token_text  := 0;
         -- Select header information for the transaction just entered
         SELECT tracking_id, tracking_id_type, carrier_name, status, arrival_date,
                departure_date, estimated_arrival_date, estimated_departure_date,
                end_loading_date, begin_loading_date, end_unloading_date,
                begin_unloading_date,
                (notes1||notes2||notes3||notes4||notes5||notes6||notes7||notes8||notes9) as notes,
                description
         INTO   l_tracking_id, l_tracking_id_type, l_carrier_name, l_shipment_status,
                l_arrival_date, l_departure_date, l_estimated_arrival_date, l_estimated_departure_date,
                l_end_loading_date, l_begin_loading_date, l_end_unloading_date, l_begin_unloading_date,
                l_notes, l_description
         FROM   fte_shipment_status_headers
         WHERE  transaction_id = p_transaction_id;



         SELECT carrier_name INTO l_carrier_name
         FROM fte_shipment_status_headers WHERE transaction_id = p_transaction_id;

         -- Select the carrier id for the carrier name passed through the XML
         --  inner exception handling
         BEGIN
           --select party_id into l_carrier_id from hz_parties where party_name = l_carrier_name;
           SELECT h.party_id INTO l_carrier_id
           FROM hz_parties h, wsh_carriers w
           WHERE h.party_id = w.carrier_id
                 AND party_name = l_carrier_name;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             RAISE invalid_carrier;
         END;


         ---- Update fte_shipment_status_header,fte_shipment_status_details and fte_delivery_proof
          --  Based on the tracking id type
         IF (UPPER(l_tracking_id_type) = 'WAYBILL') THEN


           SELECT /*+ first_rows  ordered */
           wsh_delivery_legs.delivery_id, wsh_trips.carrier_id, wsh_new_deliveries.waybill,
                  wsh_delivery_legs.delivery_leg_id
           INTO   l_delivery_id, l_carrier_id, l_waybill, l_delivery_leg_id
           FROM   wsh_trips,  wsh_trip_stops, wsh_delivery_legs , wsh_new_deliveries
           WHERE        wsh_delivery_legs.delivery_id = wsh_new_deliveries.delivery_id
                AND     wsh_delivery_legs.pick_up_stop_id = wsh_trip_stops.stop_id
                AND     wsh_trip_stops.trip_id = wsh_trips.trip_id
                AND     wsh_trips.carrier_id = l_carrier_id
                AND     wsh_new_deliveries.waybill = l_tracking_id
          	AND     wsh_delivery_legs.parent_delivery_leg_id is null;--Rel 12 MDC Changes



            INSERT INTO wsh_delivery_leg_activities
            (activity_id, delivery_leg_id, activity_date, activity_type,
             creation_date, created_by, last_update_date, last_updated_by)
            VALUES
            (WSH_DELIVERY_LEG_ACTIVITIES_S.NEXTVAL, l_delivery_leg_id, sysdate, 'TRACKING',
            sysdate, l_carrier_id, sysdate, l_carrier_id);




	  UPDATE fte_shipment_status_headers
           SET delivery_id     = l_delivery_id,
               delivery_leg_id = l_delivery_leg_id,
               message_type    = 'DELIVERY',
               creation_date   = sysdate,
               created_by      = FND_GLOBAL.USER_ID,
               last_update_date= sysdate,
               last_updated_by =FND_GLOBAL.USER_ID,
               last_update_login=FND_GLOBAL.USER_ID,
               activity_id      = WSH_DELIVERY_LEG_ACTIVITIES_S.CURRVAL
           WHERE transaction_id = p_transaction_id;

           BEGIN
           UPDATE fte_shipment_status_details
           SET delivery_leg_id = l_delivery_leg_id,
               creation_date   = sysdate,
               created_by      = FND_GLOBAL.USER_ID,
              last_update_date = sysdate,
              last_updated_by  = FND_GLOBAL.USER_ID,
              last_update_login=FND_GLOBAL.USER_ID
           WHERE transaction_id  = p_transaction_id;
	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;

	   BEGIN
           --Get the location inforamtion for the POD from the fte_message_address for the location id
		SELECT id INTO l_location_id
		FROM fte_message_location
		WHERE transaction_id=p_transaction_id
		and  location_to_table = 'FTE_DELIVERY_PROOF';
		l_address:=get_location(l_location_id);


	  -- Update the POD information
	  UPDATE fte_delivery_proof
	  SET creation_date = sysdate,
	      created_by    =FND_GLOBAL.USER_ID,
	      last_update_date=sysdate,
	      last_updated_by  =FND_GLOBAL.USER_ID,
	      last_update_login=FND_GLOBAL.USER_ID,
	      location         =l_address
	  WHERE transaction_id= p_transaction_id;

	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;




	-- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);



          ELSIF (upper(l_tracking_id_type) = 'BOOKING NUMBER')
          THEN
            SELECT /*+ first_rows  ordered */
            wsh_delivery_legs.delivery_id, wsh_trips.carrier_id,
                   wsh_delivery_legs.booking_number, wsh_delivery_legs.delivery_leg_id
            INTO   l_delivery_id, l_carrier_id, l_booking_number, l_delivery_leg_id
            FROM   wsh_trips,  wsh_trip_stops, wsh_delivery_legs , wsh_new_deliveries
            WHERE  wsh_delivery_legs.delivery_id = wsh_new_deliveries.delivery_id
            AND    wsh_delivery_legs.pick_up_stop_id = wsh_trip_stops.stop_id
            AND    wsh_trip_stops.trip_id = wsh_trips.trip_id
            AND    wsh_trips.carrier_id = l_carrier_id
            AND    wsh_delivery_legs.booking_number = l_tracking_id
            AND    wsh_delivery_legs.parent_delivery_leg_id is null;--Rel 12 MDC Changes



            insert into wsh_delivery_leg_activities
            (activity_id, delivery_leg_id, activity_date, activity_type,
             creation_date, created_by, last_update_date, last_updated_by)
            values
            (WSH_DELIVERY_LEG_ACTIVITIES_S.nextval, l_delivery_leg_id, sysdate, 'TRACKING',
             sysdate, l_carrier_id, sysdate, l_carrier_id);



             update fte_shipment_status_headers
            set delivery_id     = l_delivery_id,
                delivery_leg_id = l_delivery_leg_id,
                message_type    = 'DELIVERY',
                creation_date   = sysdate,
                created_by      =FND_GLOBAL.USER_ID,
                last_update_date=sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID,
                activity_id     = WSH_DELIVERY_LEG_ACTIVITIES_S.currval
            where transaction_id = p_transaction_id;

	   BEGIN
            update fte_shipment_status_details
            set delivery_leg_id = l_delivery_leg_id,
                creation_date   = sysdate,
                created_by      =FND_GLOBAL.USER_ID,
                last_update_date= sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID
            where transaction_id  = p_transaction_id;
    	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;

          BEGIN
	   --Get the location inforamtion for the POD from the fte_message_address for the location id
                select id into l_location_id
                from fte_message_location
                where transaction_id=p_transaction_id
		 and  location_to_table = 'FTE_DELIVERY_PROOF';

                 l_address :=GET_LOCATION(l_location_id);



         -- Update the POD information
          update fte_delivery_proof
            set creation_date=sysdate,
                created_by   =FND_GLOBAL.USER_ID,
                last_update_date=sysdate,
                last_updated_by=FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID,
                location         = l_address
            where transaction_id= p_transaction_id;
	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;


	    -- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);


          elsif (upper(l_tracking_id_type) = 'BILL OF LADING')
          then
            select wsh_new_deliveries.delivery_id, wsh_delivery_legs.delivery_leg_id,
                   wsh_trips.carrier_id
            into   l_delivery_id, l_delivery_leg_id, l_carrier_id
            from   wsh_new_deliveries, wsh_bols_rd_v, wsh_delivery_legs, wsh_trips,  wsh_trip_stops
            where  wsh_bols_rd_v.delivery_leg_id = wsh_delivery_legs.delivery_leg_id
            and    wsh_delivery_legs.delivery_id = wsh_new_deliveries.delivery_id
            and    wsh_delivery_legs.pick_up_stop_id = wsh_trip_stops.stop_id
            and    wsh_trip_stops.trip_Id = wsh_trips.trip_id
            and    wsh_trips.carrier_id = l_carrier_id
            and    wsh_bols_rd_v.bill_of_lading_number = l_tracking_id
            and    wsh_delivery_legs.parent_delivery_leg_id is null;--Rel 12 MDC Changes


            insert into wsh_delivery_leg_activities
            (activity_id, delivery_leg_id, activity_date, activity_type,
             creation_date, created_by, last_update_date, last_updated_by)
            values
            (WSH_DELIVERY_LEG_ACTIVITIES_S.nextval, l_delivery_leg_id, sysdate, 'TRACKING',
             sysdate, l_carrier_id, sysdate, l_carrier_id);



            update fte_shipment_status_headers
            set delivery_id     = l_delivery_id,
                delivery_leg_id = l_delivery_leg_id,
                message_type    = 'DELIVERY',
                creation_date   = sysdate,
                created_by      = FND_GLOBAL.USER_ID,
                last_update_date= sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID,
                activity_id     = WSH_DELIVERY_LEG_ACTIVITIES_S.currval
            where transaction_id = p_transaction_id;

	   BEGIN
            update fte_shipment_status_details
            set delivery_leg_id = l_delivery_leg_id,
                creation_date   = sysdate,
                created_by      = FND_GLOBAL.USER_ID,
                last_update_date= sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID
             where transaction_id  = p_transaction_id;
	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;

          --Get the location inforamtion for the POD from the fte_message_address for the location id

          BEGIN
		select id into l_location_id
                from fte_message_location
                where transaction_id=p_transaction_id
		        and  location_to_table = 'FTE_DELIVERY_PROOF';

                l_address :=GET_LOCATION(l_location_id);


                 -- Update the POD information

            update fte_delivery_proof
            set creation_date = sysdate,
                created_by    = FND_GLOBAL.USER_ID,
                last_update_date=sysdate,
                last_updated_by=FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID,
                location         = l_address
             where transaction_id= p_transaction_id;
	   EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	   END ;

     	   -- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);


         -- Since Consol delivery does not have Detials attached to it, it is not possible to
	 -- send 'LICENSE PLATE NUMBER' information for Content delivery. Hence populate_child_delivery_legs
	 -- method will not be called.

          elsif (upper(l_tracking_id_type) = 'LICENSE PLATE NUMBER')
           then  -- license plate number is only used by container
             select wsh_new_deliveries.delivery_id, wsh_delivery_legs.delivery_leg_id,
                    wsh_trips.carrier_id, wsh_delivery_details.container_name,
                    wsh_delivery_details.delivery_detail_id
             into   l_delivery_id, l_delivery_leg_id, l_carrier_id, l_container_name,
                    l_delivery_detail_id
             from   wsh_new_deliveries, wsh_delivery_legs, wsh_trips, wsh_trip_stops,
                    wsh_delivery_details, wsh_delivery_assignments
             where  wsh_delivery_assignments.DELIVERY_ID = wsh_new_deliveries.DELIVERY_ID
             and    wsh_delivery_assignments.DELIVERY_DETAIL_ID =
                    wsh_delivery_details.DELIVERY_DETAIL_ID
             and    wsh_delivery_legs.delivery_id = wsh_new_deliveries.delivery_id
             and    wsh_delivery_legs.pick_up_stop_id = wsh_trip_stops.stop_id
             and    wsh_trip_stops.trip_Id = wsh_trips.trip_id
             and    wsh_trips.carrier_id = l_carrier_id
             and    wsh_delivery_details.container_name = l_tracking_id
             and    wsh_delivery_legs.parent_delivery_leg_id is null;--Rel 12 MDC Changes



             insert into wsh_delivery_leg_activities
             (activity_id, delivery_leg_id, activity_date, activity_type,
              creation_date, created_by, last_update_date, last_updated_by)
             values
             (WSH_DELIVERY_LEG_ACTIVITIES_S.nextval, l_delivery_leg_id, sysdate, 'TRACKING',
             sysdate, l_carrier_id, sysdate, l_carrier_id);



             update fte_shipment_status_headers
             set delivery_id          = l_delivery_id,
                 delivery_leg_id      = l_delivery_leg_id,
                 delivery_detail_id   = l_delivery_detail_id,
                 license_plate_number = l_container_name,
                 message_type         = 'CONTAINER',
                 creation_date        = sysdate,
                 activity_id     = WSH_DELIVERY_LEG_ACTIVITIES_S.currval
             where transaction_id   = p_transaction_id;

	    BEGIN
             update fte_shipment_status_details
             set delivery_leg_id = l_delivery_leg_id,
                 creation_date   = sysdate
             where transaction_id  = p_transaction_id;
	     EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	     END ;

		-- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);

          elsif (upper(l_tracking_id_type) = 'SEAL IDENTIFIER')
           then  -- seal code is only used by container

	  select /*+ORDERED INDEX(wdl WSH_DELIVERY_LEGS_N2)*/
	  wnd.delivery_id,
	  wdl.delivery_leg_id,
	  wt.carrier_id,
	  wdd.seal_code,
	  wdd.delivery_detail_id
	  into   l_delivery_id, l_delivery_leg_id, l_carrier_id, l_seal_code,
	         l_delivery_detail_id
	  from
	   wsh_trips wt,
	   wsh_trip_stops wts,
	   wsh_delivery_legs wdl,
	   wsh_new_deliveries wnd,
	   wsh_delivery_assignments wda,
	   wsh_delivery_details wdd
	  where        wda.DELIVERY_ID = wnd.DELIVERY_ID
		     and    wda.DELIVERY_DETAIL_ID = wdd.DELIVERY_DETAIL_ID
		     and    wdl.delivery_id = wnd.delivery_id
		     and    wdl.pick_up_stop_id = wts.stop_id
		     and    wts.trip_Id = wt.trip_id
		     and    wt.carrier_id = l_carrier_id
		     and    wdd.seal_code = l_tracking_id
                     and    wdl.parent_delivery_leg_id is null;--Rel 12 MDC Changes




              insert into wsh_delivery_leg_activities
             (activity_id, delivery_leg_id, activity_date, activity_type,
              creation_date, created_by, last_update_date, last_updated_by)
              values
             (WSH_DELIVERY_LEG_ACTIVITIES_S.nextval, l_delivery_leg_id, sysdate, 'TRACKING',
              sysdate, l_carrier_id, sysdate, l_carrier_id);

             begin
               select container_name into l_container_name from wsh_delivery_details
               where delivery_detail_id = l_delivery_detail_id;


              exception
               WHEN NO_DATA_FOUND THEN
                 raise no_license_plate;

             end;


             update fte_shipment_status_headers
             set delivery_id        = l_delivery_id,
                 delivery_leg_id    = l_delivery_leg_id,
                 delivery_detail_id = l_delivery_detail_id,
                 container_seal     = l_seal_code,
                 message_type       = 'CONTAINER',
                 creation_date      = sysdate,
                 activity_id        = WSH_DELIVERY_LEG_ACTIVITIES_S.currval,
                 license_plate_number = l_container_name
             where transaction_id   = p_transaction_id;

             BEGIN
	     update fte_shipment_status_details
             set delivery_leg_id = l_delivery_leg_id,
                 creation_date   = sysdate
             where transaction_id  = p_transaction_id;
	        EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	     END ;

		-- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);



        elsif (upper(l_tracking_id_type) = 'CARRIER REFERENCE NUMBER')
           then   -- tracking number is only used for container.
                  -- It is only in wsh_delivery_details level,
                  -- not in wsh_new_deliveries level


             select wsh_new_deliveries.delivery_id, wsh_delivery_legs.delivery_leg_id,
                    wsh_trips.carrier_id, wsh_delivery_details.tracking_number,
                    wsh_delivery_details.delivery_detail_id
             into   l_delivery_id, l_delivery_leg_id, l_carrier_id, l_tracking_number,
                    l_delivery_detail_id
             from   wsh_new_deliveries, wsh_delivery_legs, wsh_trips,
                    wsh_trip_stops, wsh_delivery_details, wsh_delivery_assignments
             where  wsh_delivery_assignments.DELIVERY_ID = wsh_new_deliveries.DELIVERY_ID
             and    wsh_delivery_assignments.DELIVERY_DETAIL_ID =
                    wsh_delivery_details.DELIVERY_DETAIL_ID
             and    wsh_delivery_legs.delivery_id = wsh_new_deliveries.delivery_id
             and    wsh_delivery_legs.pick_up_stop_id = wsh_trip_stops.stop_id
             and    wsh_trip_stops.trip_Id = wsh_trips.trip_id
             and    wsh_trips.carrier_id = l_carrier_id
             and    wsh_delivery_details.tracking_number = l_tracking_id
	     and    wsh_delivery_legs.parent_delivery_leg_id is null;--Rel 12 MDC Changes



              insert into wsh_delivery_leg_activities
             (activity_id, delivery_leg_id, activity_date, activity_type,
              creation_date, created_by, last_update_date, last_updated_by)
              values
             (WSH_DELIVERY_LEG_ACTIVITIES_S.nextval, l_delivery_leg_id, sysdate, 'TRACKING',
              sysdate, l_carrier_id, sysdate, l_carrier_id);

              begin
                select container_name into l_container_name from wsh_delivery_details
                where delivery_detail_id = l_delivery_detail_id;
              exception
               WHEN NO_DATA_FOUND THEN
                raise no_license_plate;
               end;


             update fte_shipment_status_headers
             set delivery_id        = l_delivery_id,
                 delivery_leg_id    = l_delivery_leg_id,
                 delivery_detail_id = l_delivery_detail_id,
                 message_type       = 'CONTAINER',
                 creation_date      = sysdate,
                 activity_id        = WSH_DELIVERY_LEG_ACTIVITIES_S.currval,
                 license_plate_number = l_container_name
             where transaction_id   = p_transaction_id;

             BEGIN
	     update fte_shipment_status_details
             set delivery_leg_id = l_delivery_leg_id,
                 creation_date   = sysdate
             where transaction_id  = p_transaction_id;
             EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	     END ;

             --Get the location inforamtion for the POD from the fte_message_address for the location id

	    BEGIN
            select id into l_location_id
            from fte_message_location
            where transaction_id=p_transaction_id
            and  location_to_table = 'FTE_DELIVERY_PROOF';

            l_address :=GET_LOCATION(l_location_id);


             -- Update the POD information

            update fte_delivery_proof
            set creation_date = sysdate,
                created_by    = FND_GLOBAL.USER_ID,
                last_update_date=sysdate,
                last_updated_by=FND_GLOBAL.USER_ID,
                last_update_login=FND_GLOBAL.USER_ID,
                location         = l_address
             where transaction_id= p_transaction_id;
	     EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	     END ;

		-- populate child legs if any
		populate_child_delivery_legs
		(
		 p_init_msg_list => FND_API.G_TRUE,
		 p_delivery_leg_id => l_delivery_leg_id,
		 p_transaction_id => p_transaction_id,
		 p_carrier_id => l_carrier_id,
		 x_return_status => l_return_statusp,
		 x_msg_count =>   l_msg_count,
		 x_msg_data =>  l_msg_data
		);


          else

              raise invalid_tracking_id_type;

          end if;



          update wsh_trip_stops
          set actual_departure_date       = l_departure_date,
              carrier_est_departure_date  = l_estimated_departure_date,
              loading_start_datetime      = l_begin_loading_date,
              loading_end_datetime        = l_end_loading_date
          where wsh_trip_stops.stop_id    =
                (select pick_up_stop_id
                from    wsh_delivery_legs
                where   delivery_leg_id = l_delivery_leg_id);

          update wsh_trip_stops
          set actual_arrival_date         = l_arrival_date,
              carrier_est_arrival_date    = l_estimated_arrival_date,
              unloading_start_datetime    = l_begin_unloading_date,
              unloading_end_datetime      = l_end_unloading_date
          where wsh_trip_stops.stop_id    =
                (select drop_off_stop_id
                from   wsh_delivery_legs
                where  delivery_leg_id   = l_delivery_leg_id);

   --     Call  the procedure get_delivery_details to delete all the
   --     details and POD information for a delivery leg and retain only the
   --     last detail and POD information


          FTE_TRACKING_WRAPPER.get_delivery_details (p_transaction_id, l_carrier_id,
                                                     l_exception_message,
                                                     l_return_status, l_error_token_text);





	begin
	select received_date,1 into l_received_date,l_flag
	from
	fte_delivery_proof where transaction_id= p_transaction_id;
	EXCEPTION
		WHEN OTHERS THEN
			NULL; --No records in FTE_DELIVERY_PROOF table
	END ;

	if l_flag= 1 then
        	FTE_TRACKING_WRAPPER.call_last_delivery_leg(l_delivery_leg_id,l_received_date);
	else
		--Added by shravisa for Release 12
		--Raise Workflow Tracking Event when ever Tracking information comes for any
		--Functional Workflow

	       OPEN get_org_delivery_info(l_delivery_leg_id);
	       FETCH get_org_delivery_info into l_delivery_id_tk,l_organization_id;
	       CLOSE get_org_delivery_info;



		wf_event.AddParameterToList(
			 p_name=>'ORGANIZATION_ID',
			 p_value  => l_organization_id,
			 p_parameterlist=> l_parameter_list);


		--Do not handle the Return status from this method
		WSH_WF_STD.raise_event(
			p_entity_type		=> 'DELIVERY',
			p_entity_id		=> TO_CHAR(l_delivery_id_tk),
			p_event			=> 'oracle.apps.fte.delivery.trk.matchtrackingadvice',
			p_parameters            => l_parameter_list,
			p_organization_id	=> l_organization_id,
			x_return_status		=> l_return_statuswf);
	END IF;


          EXCEPTION
                 WHEN INVALID_CARRIER THEN
                         select wsh_interface_errors_s.nextval into l_error_id
                         from dual;

                         FTE_TRACKING_WRAPPER.insert_error_status
                         (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
                          p_transaction_id,  1, 'ERROR', 'INVALID CARRIER',
                         0);
                         x_error_token_text  :=  1;
                         x_exception_message :=  'Invalid carrier name. ';
                         x_return_status     :=   1;
                WHEN NO_LICENSE_PLATE THEN
                         select wsh_interface_errors_s.nextval into l_error_id
                         from dual;

                         FTE_TRACKING_WRAPPER.insert_error_status
                         (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
                          p_transaction_id,  2, 'ERROR', 'NO LICENSE PLATE NUMBER',
                          0);
                         x_error_token_text  :=  2;
                         x_exception_message :=  'No license plate number. ';
                         x_return_status     :=   2;
               WHEN NO_DATA_FOUND THEN
                         select wsh_interface_errors_s.nextval into l_error_id
                         from dual;

                        FTE_TRACKING_WRAPPER.insert_error_status
                         (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
                          p_transaction_id,  3, 'ERROR', 'NO DELIVERY FOUND',
                          l_carrier_id);
                         x_error_token_text  :=  3;
                         x_exception_message :=  'Unable to determine delivery. ';
                         x_return_status     :=  3;
                WHEN INVALID_TRACKING_ID_TYPE THEN
                         select wsh_interface_errors_s.nextval into l_error_id
                         from dual;

                        FTE_TRACKING_WRAPPER.insert_error_status
                        (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
                         p_transaction_id,  4, 'ERROR', 'INVALID TRACKING ID TYPE',
                         l_carrier_id);
                         x_return_status     := 4 ;
                         x_exception_message := 'Invalid tracking id type';
                         x_error_token_text  := 4;
               WHEN OTHERS THEN
                         select wsh_interface_errors_s.nextval into l_error_id
                         from dual;

                        FTE_TRACKING_WRAPPER.insert_error_status
                        (l_error_id, 'FTE_SHIPMEMT_STATUS_HEADERS',
                         p_transaction_id,  5, 'ERROR', 'OTHER EXCEPTION',
                         l_carrier_id);

                         l_sql_error_code := to_char(SQLCODE);
                         l_sql_error_msg  := substr(SQLERRM,1,2000);

                         IF (l_exception_message IS NULL) THEN
                             l_exception_message  :=
                                                    (l_sql_error_code||':'||l_sql_error_msg||' : '
                                                     ||' : '||l_procedure_name);
                         END IF;
                         x_return_status     := 5 ;
                         x_exception_message := l_exception_message;
                         x_error_token_text  := 5;


END get_delivery_or_container;



PROCEDURE get_delivery_details(
                           p_transaction_id    IN  NUMBER,
                           p_carrier_id        IN  NUMBER,
                           x_exception_message OUT NOCOPY VARCHAR2,
                           x_return_status     OUT NOCOPY NUMBER,
                           x_error_token_text  OUT NOCOPY NUMBER)   IS

        l_creation_date            DATE;
        l_delivery_leg_id          NUMBER;
        l_rows                     NUMBER;

        l_tracking_id              VARCHAR2(30);
        l_message_type             VARCHAR2(30);
        l_previous_transaction_id  NUMBER;

        l_exception_message        VARCHAR2(2000);
        l_return_status            NUMBER;
        l_error_token_text         VARCHAR2(240);

        l_sql_error_code           VARCHAR2(2000);
        l_sql_error_msg            VARCHAR2(2000);
        l_cursor_name              VARCHAR2(2000);
        l_procedure_name           VARCHAR2(240) := 'FTE_TRACKING_WRAPPER.get_delivery_details';

        INVALID_TRANSACTION_ID     EXCEPTION;

        l_error_id                 NUMBER;

        CURSOR c1 is

             select delivery_leg_id, creation_date
             from fte_shipment_status_headers
             where transaction_id = p_transaction_id;

	Cursor c_get_prev (c_transaction_id number, c_delivery_leg_id number) is
	SELECT
	  fh.transaction_id
	FROM
	  fte_shipment_status_headers fh,
	  fte_shipment_status_details fs
	WHERE
	fh.transaction_id = fs.transaction_id and
	fh.transaction_id <> c_transaction_id and
	fh.delivery_leg_id = c_delivery_leg_id
	UNION
	SELECT
	  fp.transaction_id
	FROM
 	   fte_shipment_status_headers fh,
	   fte_delivery_proof fp
	WHERE
	fh.transaction_id = fp.transaction_id  and
	fh.transaction_id <> c_transaction_id and
	fh.delivery_leg_id = c_delivery_leg_id;

  BEGIN

       begin
       select tracking_id, message_type
       into l_tracking_id, l_message_type
       from fte_shipment_status_headers
       where transaction_id = p_transaction_id;

       exception
         when others then
            raise INVALID_TRANSACTION_ID;
       end;



       OPEN c1;
       LOOP
            FETCH c1 into
            l_delivery_leg_id, l_creation_date;



        if (upper(l_message_type) = 'DELIVERY')
        then


	open c_get_prev(p_transaction_id, l_delivery_leg_id);
	FETCH c_get_prev into l_previous_transaction_id;
	CLOSE c_get_prev;



          DECLARE
                 l_shipment_detail_id    NUMBER;

                 CURSOR  c2 is

                    select shipment_status_detail_id
                    from fte_shipment_status_details
                    where delivery_leg_id =  l_delivery_leg_id
                    and   transaction_id  <> p_transaction_id;

           BEGIN
                    OPEN c2;
                    LOOP
                    FETCH c2 into
                         l_shipment_detail_id;


                    delete from fte_shipment_status_exceptions
                    where detail_id = l_shipment_detail_id;


                  EXIT when c2%NOTFOUND;
                  END LOOP;
                  CLOSE c2;

            END;

          select count (*)
          into l_rows
          from fte_shipment_status_details
          where  transaction_id  = l_previous_transaction_id;


          delete
          from   fte_shipment_status_details
          where  transaction_id  = l_previous_transaction_id;


          delete
          from fte_delivery_proof where
          transaction_id =l_previous_transaction_id;


        elsif (upper(l_message_type) = 'CONTAINER')
        then
          select tracking_id, message_type
          into   l_tracking_id, l_message_type
          from   fte_shipment_status_headers
          where  transaction_id = p_transaction_id;

	  OPEN c_get_prev(p_transaction_id, l_delivery_leg_id);
	  FETCH c_get_prev into l_previous_transaction_id;
	  CLOSE c_get_prev;

          select count (*)
          into   l_rows
          from   fte_shipment_status_details
          where  transaction_id  = l_previous_transaction_id;


          DECLARE
                 l_shipment_detail_id    NUMBER;

                 CURSOR  c2 is

                    select shipment_status_detail_id
                    from fte_shipment_status_details
                    where delivery_leg_id =  l_delivery_leg_id
                    and   transaction_id  =  l_previous_transaction_id;

           BEGIN
                    OPEN c2;
                    LOOP
                    FETCH c2 into
                         l_shipment_detail_id;


                    delete from fte_shipment_status_exceptions
                    where detail_id = l_shipment_detail_id;


                  EXIT when c2%NOTFOUND;
                  END LOOP;
                  CLOSE c2;

            END;


          delete
          from   fte_shipment_status_details
          where  transaction_id  = l_previous_transaction_id;



          delete
          from fte_delivery_proof where
          transaction_id =l_previous_transaction_id;

        end if;


        EXIT when c1%NOTFOUND;
        END LOOP;
        CLOSE c1;


        EXCEPTION
          WHEN INVALID_TRANSACTION_ID THEN

                l_sql_error_code := 1;
                l_sql_error_msg  := 'Invalid transaction id';
                l_exception_message := 'Invalid transaction id';

          WHEN OTHERS THEN

                      select wsh_interface_errors_s.nextval into l_error_id
                      from dual;

                      FTE_TRACKING_WRAPPER.insert_error_status
                      (l_error_id, 'FTE_SHIPMEMT_STATUS_DETAILS',
                       p_transaction_id,  2, 'ERROR', 'NO DELIVERY DETAILS FOUND',
                       p_carrier_id);

                      l_sql_error_code := to_char(SQLCODE);
                      l_sql_error_msg  := substr(SQLERRM,1,2000);

                      IF (l_exception_message IS NULL) THEN
                          l_exception_message  :=
                                                (l_sql_error_code||':'||l_sql_error_msg||' : '
                                                ||l_cursor_name||' : '||l_procedure_name);
                      END IF;

                      x_return_status     := 2 ;
                      x_exception_message := l_exception_message;
                      x_error_token_text  := 2;


  END get_delivery_details;


 PROCEDURE insert_error_status
          (
                  p_interface_error_id              IN      NUMBER,
                  p_interface_table_name            IN      VARCHAR2,
                  p_interface_id                    IN      NUMBER,
                  p_message_code                    IN      NUMBER,
                  p_message_name                    IN      VARCHAR2,
                  p_error_message                   IN      VARCHAR2,
                  p_carrier_id                      IN      NUMBER
          )
          IS
          BEGIN

-- message_code 0 = completed with success, 1 = completed with error
                  INSERT INTO WSH_INTERFACE_ERRORS
                  (INTERFACE_ERROR_ID, INTERFACE_ERROR_GROUP_ID, INTERFACE_TABLE_NAME,
                   INTERFACE_ID, MESSAGE_CODE, MESSAGE_NAME, ERROR_MESSAGE,
                   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY)
                  VALUES (p_interface_error_id, 1, p_interface_table_name,
                          p_interface_id, p_message_code, p_message_name, p_error_message,
                          sysdate, p_carrier_id, sysdate, p_carrier_id);
                  commit;

 END insert_error_status;

PROCEDURE call_last_delivery_leg(p_delivery_leg_id IN NUMBER,
					p_received_date IN DATE)
IS

l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(32767);


BEGIN

		CALL_LAST_DELIVERY_LEG(p_api_version_number => 1,
				p_init_msg_list  => FND_API.G_FALSE ,
				x_return_status  => l_return_status,
				x_msg_count      => l_msg_count,
				x_msg_data       => l_msg_data,
				p_delivery_leg_id => p_delivery_leg_id,
				p_received_date  => p_received_date);


END call_last_delivery_leg;


PROCEDURE CALL_LAST_DELIVERY_LEG(
				p_api_version_number    IN NUMBER,
				p_init_msg_list         IN VARCHAR2,
				x_return_status         OUT NOCOPY VARCHAR2,
				x_msg_count             OUT NOCOPY NUMBER,
				x_msg_data              OUT NOCOPY VARCHAR2,
				p_delivery_leg_id 	IN NUMBER,
				p_received_date 	IN DATE)
IS
l_leg_Tab               WSH_DELIVERY_LEGS_GRP.dlvy_leg_tab_type;
l_in_rec                WSH_DELIVERY_LEGS_GRP.action_parameters_rectype;
l_out_rec               WSH_DELIVERY_LEGS_GRP.action_out_rec_type;

-- Return values
l_return_status         VARCHAR2(10);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(32767);
l_number_of_warnings	NUMBER;
l_number_of_errors	NUMBER;
l_out_action_rec	FTE_ACTION_OUT_REC;

--Return values for AR Call
l_ar_return_status         VARCHAR2(10);
l_ar_msg_count             NUMBER;
l_ar_msg_data              VARCHAR2(32767);


-- local variables

l_last_delivery_leg     NUMBER;
l_last_stop_id		NUMBER;
l_last_stop_status	VARCHAR(2);
l_dlvy_ud_location_id 	NUMBER;
l_last_stop_location_id	NUMBER;
l_organization_id	NUMBER;
l_delivery_id		NUMBER;

--Added for Funtional Tracking workflow
l_organization_id_tk          NUMBER;
l_parameter_list_tk           wf_parameter_list_t;
l_delivery_id_tk              NUMBER;
l_return_statuswf 	      VARCHAR2(1);

l_stop_id_tab           FTE_ID_TAB_TYPE;
l_stop_action_params	FTE_STOP_ACTION_PARAM_REC;


x_stop_out_rec WSH_TRIP_STOPS_GRP.stopActionOutRecType;

p_action_prms WSH_TRIP_STOPS_GRP.action_parameters_rectype;
p_entity_id_tab WSH_UTIL_CORE.id_tab_type;

--For Workflow Impact on ITM
l_parameter_list     wf_parameter_list_t;

	l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
	--
	l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'call_last_delivery_leg';


-- [HBHAGAVA: 10+ Modfied for bug 3952734
--Modified for rel 12 Workflow Impact on ITM
cursor get_last_delivery_leg(l_delivery_leg_id NUMBER) IS
                SELECT
                          DELIVERY_LEG_ID, DROP_OFF_STOP_ID,
                          WTL.STATUS_CODE,WND.ULTIMATE_DROPOFF_LOCATION_ID,
                          WTL.STOP_LOCATION_ID, WND.ORGANIZATION_ID, WND.DELIVERY_ID
                FROM
                          WSH_DELIVERY_LEGS WDL ,
                          WSH_NEW_DELIVERIES WND,
                          WSH_TRIP_STOPS WTL
                WHERE
                          WND.DELIVERY_ID= WDL.DELIVERY_ID AND
                          WDL.DROP_OFF_STOP_ID=WTL.STOP_ID AND
                          WDL.delivery_leg_id = l_delivery_leg_id;

cursor get_org_delivery_info ( c_delivery_leg_id NUMBER) IS
	SELECT wnd.delivery_id, wnd.organization_id FROM
	wsh_delivery_legs wdl, wsh_new_deliveries wnd
	WHERE wdl.delivery_id = wnd.delivery_id AND
	wdl.delivery_leg_id = c_delivery_leg_id;

BEGIN

	SAVEPOINT	CALL_LAST_DELIVERY_LEG_PUB;


	IF l_debug_on THEN
	      wsh_debug_sv.push(l_module_name);
	END IF;


	-- Initialize message list if p_init_msg_list is set to TRUE.
	--
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;


	x_return_status       	:= WSH_UTIL_CORE.G_RET_STS_SUCCESS;
	x_msg_count		:= 0;
	x_msg_data		:= 0;
	l_number_of_warnings	:= 0;
	l_number_of_errors	:= 0;


	--Raise Workflow Tracking Event when ever POD information comes in irrespective of the delivery leg position
	--Functional Workflow

       OPEN get_org_delivery_info(p_delivery_leg_id);
       FETCH get_org_delivery_info into l_delivery_id_tk,l_organization_id_tk;
       CLOSE get_org_delivery_info;



	wf_event.AddParameterToList(
		 p_name=>'ORGANIZATION_ID',
		 p_value  => l_organization_id_tk,
		 p_parameterlist=> l_parameter_list_tk);


	--Do not handle the Return status from this method
	WSH_WF_STD.raise_event(
		p_entity_type		=> 'DELIVERY',
		p_entity_id		=> TO_CHAR(l_delivery_id_tk),
		p_event			=> 'oracle.apps.fte.delivery.trk.matchtrackingadvice',
		p_parameters            => l_parameter_list_tk,
		p_organization_id	=> l_organization_id_tk,
		x_return_status		=> l_return_statuswf);


       OPEN get_last_delivery_leg(p_delivery_leg_id);
       FETCH get_last_delivery_leg into
		l_last_delivery_leg,l_last_stop_id,l_last_stop_status,
		l_dlvy_ud_location_id,
		l_last_stop_location_id,l_organization_id,l_delivery_id;
       CLOSE get_last_delivery_leg;

	IF l_debug_on THEN

		WSH_DEBUG_SV.logmsg(l_module_name,' Stop Id ' || l_last_stop_id);
		WSH_DEBUG_SV.logmsg(l_module_name,' Stop status ' || l_last_stop_status);
		WSH_DEBUG_SV.logmsg(l_module_name,' Last dleg id ' || l_last_delivery_leg);
		WSH_DEBUG_SV.logmsg(l_module_name,' Dlvy UD LocatioId ' || l_dlvy_ud_location_id);
		WSH_DEBUG_SV.logmsg(l_module_name,' Stop Location Id ' || l_last_stop_location_id);
	END IF;

       IF l_last_delivery_leg IS NOT NULL THEN

       		--[HBHAGAVA 10+]
       		-- If deliveries ultimate dropoff location is not same as
       		-- stop's location then the stop is not the last delivery leg
       		-- so no need to update pod flag
		IF (l_last_stop_location_id = l_dlvy_ud_location_id) THEN

			l_in_rec.action_code := 'UPDATE';
			l_in_rec.caller := 'FTE';
			l_leg_Tab(1).delivery_leg_id := p_delivery_leg_id;
			l_leg_Tab(1).pod_flag := 'Y';
			l_leg_Tab(1).pod_date := p_received_date;


			WSH_INTERFACE_GRP.Update_Delivery_Leg(
				p_api_version_number     => 1.0,
				p_init_msg_list          => FND_API.G_TRUE,
				p_commit                 => NULL,
				p_delivery_leg_tab       => l_leg_Tab,
				p_in_rec                 => l_in_rec,
				x_out_rec                => l_out_rec,
				x_return_status          => l_return_status,
				x_msg_count              => l_msg_count,
				x_msg_data               => l_msg_data);

			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);



			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			ELSIF l_number_of_warnings > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;

			--Release 12 WF Impact on POD
			--Raise POD received event for Tracking workflow

			wf_event.AddParameterToList(
                         p_name=>'ORGANIZATION_ID',
                         p_value  => l_organization_id,
                         p_parameterlist=> l_parameter_list);

			--Do not handle the Return status from this method
			WSH_WF_STD.raise_event(
				p_entity_type		=> 'DELIVERY',
				p_entity_id		=> l_delivery_id,
				p_event			=> 'oracle.apps.fte.delivery.pod.podreceived',
				p_parameters            => l_parameter_list,
				p_organization_id	=> l_organization_id,
				x_return_status		=> x_return_status);

			--call To AR events for Revenue Recognition of a System
			--Do not handle the status
			ar_deferral_reasons_grp.record_proof_of_delivery
			(
			  p_api_version    => 1.0,
			  p_init_msg_list  => FND_API.G_FALSE,
			  p_commit         => FND_API.G_FALSE,
			  p_delivery_id	   =>l_delivery_id,
			  p_pod_date	   => p_received_date,
			  x_return_status  => l_ar_return_status,
			  x_msg_count      => l_ar_msg_count,
			  x_msg_data       => l_ar_msg_data
			 );

			END IF;


		IF (l_last_stop_status = 'CL') THEN
			IF l_debug_on THEN

				WSH_DEBUG_SV.logmsg(l_module_name,' Stop is closed nothing to update ' || l_last_stop_id);
				WSH_DEBUG_SV.pop(l_module_name);
			END IF;

			RETURN;
		ELSE


			IF l_debug_on THEN

				WSH_DEBUG_SV.logmsg(l_module_name,' Calling stop action with ARRIVE ' || l_last_stop_id);
			END IF;


			p_entity_id_tab(1):= l_last_stop_id;
			p_action_prms.action_code := 'UPDATE-STATUS';
			p_action_prms.stop_action := 'ARRIVE';
			p_action_prms.phase:=NULL;
			p_action_prms.caller:='FTE_MLS_WRAPPER';
			p_action_prms.actual_date:=p_received_date;


			WSH_INTERFACE_GRP.Stop_Action
			   ( p_api_version_number =>   p_api_version_number,
			    p_init_msg_list      =>    FND_API.G_FALSE,
			    p_commit		 =>    'F',
			    p_entity_id_tab	 =>    p_entity_id_tab,
			    p_action_prms	 =>    p_action_prms,
			    x_stop_out_rec 	 =>    x_stop_out_rec,
			    x_return_status      =>    l_return_status ,
			    x_msg_count          =>    l_msg_count,
			    x_msg_data           =>    l_msg_data

			   );

			IF l_debug_on THEN
				WSH_DEBUG_SV.logmsg(l_module_name,'After calling stop action');
				WSH_DEBUG_SV.logmsg(l_module_name,'l_return_status:' || l_return_status);
				WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_count);
				WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_data);

			END IF;


			wsh_util_core.api_post_call(
			      p_return_status    =>l_return_status,
			      x_num_warnings     =>l_number_of_warnings,
			      x_num_errors       =>l_number_of_errors,
			      p_msg_data	 =>l_msg_data);



			IF l_number_of_errors > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
			ELSIF l_number_of_warnings > 0
			THEN
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
			ELSE
			    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
			END IF;


		END IF;



       END IF;

	IF l_debug_on THEN
		WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
		WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
		WSH_DEBUG_SV.logmsg(l_module_name,'l_msg_count:' || l_msg_data);

	END IF;


	IF l_debug_on THEN
		WSH_DEBUG_SV.pop(l_module_name);
	END IF;
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CALL_LAST_DELIVERY_LEG_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CALL_LAST_DELIVERY_LEG_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status:' || x_return_status);
			WSH_DEBUG_SV.logmsg(l_module_name,'x_msg_count:' || x_msg_count);
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
	WHEN OTHERS THEN
		ROLLBACK TO CALL_LAST_DELIVERY_LEG_PUB;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		x_msg_data := substr(sqlerrm,1,200);
		IF l_debug_on THEN
		        wsh_debug_sv.log (l_module_name,'Error',substr(sqlerrm,1,200));
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;

		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );

END call_last_delivery_leg;

END FTE_TRACKING_WRAPPER;

/
