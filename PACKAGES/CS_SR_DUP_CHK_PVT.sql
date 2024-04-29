--------------------------------------------------------
--  DDL for Package CS_SR_DUP_CHK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_DUP_CHK_PVT" AUTHID CURRENT_USER AS
/* $Header: csdpchks.pls 115.3 2003/10/17 18:14:47 aneemuch noship $ */

    TYPE CS_Extended_Attr_Rec IS RECORD
    (
    	incident_type_id	NUMBER,
    	sr_attribute_code	VARCHAR2(30),
    	sr_attribute_value	VARCHAR2(80)
    );

    TYPE CS_Extended_Attr_Tbl is TABLE OF CS_Extended_Attr_Rec INDEX BY BINARY_INTEGER;

    TYPE Sr_Dupl_Rec IS RECORD
    (	incident_id		NUMBER,
        reason_desc		VARCHAR2 (2000) );

    TYPE Sr_Dupl_Tbl is TABLE OF Sr_Dupl_Rec
    		INDEX BY BINARY_INTEGER;

    TYPE SR_Dupl_Link_Rec IS RECORD
    (	incident_id				NUMBER,
    	incident_link_id		NUMBER,
		incident_link_number	NUMBER,
        reason_desc				VARCHAR2 (2000) );

    TYPE SR_Dupl_Link_Tbl is TABLE OF SR_Dupl_Link_Rec
    		INDEX BY BINARY_INTEGER;

    TYPE CS_Incident_Address_Rec IS RECORD
    (
    	INCIDENT_ADDRESS 	cs_incidents_all_b.incident_address%type,
    	INCIDENT_CITY 		cs_incidents_all_b.incident_city%type,
        INCIDENT_STATE		cs_incidents_all_b.incident_state%type,
    	INCIDENT_COUNTRY	cs_incidents_all_b.incident_country%type,
        INCIDENT_PROVINCE	cs_incidents_all_b.incident_province%type,
    	INCIDENT_POSTAL_CODE	cs_incidents_all_b.incident_postal_code%type,
        INCIDENT_COUNTY		cs_incidents_all_b.incident_county%type
    );

	G_PKG_NAME		VARCHAR2(30) := 'TEST_AN_CS_SR_DUP_CHK_PVT';

	PROCEDURE Duplicate_Check
    (
    	p_api_version				IN 			NUMBER,
    	p_init_msg_list				IN			VARCHAR2	DEFAULT fnd_api.g_false,
    	p_commit					IN			VARCHAR2	DEFAULT fnd_api.g_false,
    	p_validation_level			IN			NUMBER	DEFAULT fnd_api.g_valid_level_full,
    	p_incident_id				IN			NUMBER,
    	p_incident_type_id			IN			NUMBER,
    	p_customer_product_id 		IN 			NUMBER,
		p_instance_serial_number 	IN 			VARCHAR2,
    	p_current_serial_number	 	IN			VARCHAR2,
		p_inv_item_serial_number 	IN 			VARCHAR2,
    	p_customer_id				IN 			NUMBER,
    	p_inventory_item_id			IN			NUMBER,
    	p_cs_extended_attr			IN			cs_extended_attr_tbl,
    	p_incident_address			IN			cs_incident_address_rec,
    	x_duplicate_flag			OUT NOCOPY 	VARCHAR2,
    	x_sr_dupl_rec				OUT NOCOPY	Sr_Dupl_Tbl,
		x_dup_found_at				OUT NOCOPY  VARCHAR2,
    	x_return_status				OUT NOCOPY	VARCHAR2,
    	x_msg_count					OUT NOCOPY	NUMBER,
    	x_msg_data					OUT NOCOPY	VARCHAR2
    );


	PROCEDURE Check_EA_Duplicate_Setup
	(
        p_incident_id				IN			NUMBER,
        p_incident_type_id			IN 			NUMBER,
        p_cs_extended_attr			IN			cs_extended_attr_tbl,
        p_incident_address			IN			cs_incident_address_rec,
        p_ea_attr_dup_flag 			IN OUT NOCOPY varchar2,
        p_cs_ea_dup_rec				OUT NOCOPY 	sr_dupl_tbl,
        p_ea_ia_dup					OUT NOCOPY 	VARCHAR2,
        p_ea_ea_dup					OUT NOCOPY 	VARCHAR2,
        p_return_status				OUT NOCOPY 	VARCHAR2
	);

	PROCEDURE Perform_EA_Duplicate
	(
        p_incident_id				IN			NUMBER,
        p_incident_type_id			IN 			NUMBER,
        p_cs_extended_attr			IN			cs_extended_attr_tbl,
        p_incident_address			IN			cs_incident_address_rec,
        p_ea_attr_dup_flag 			IN OUT NOCOPY	varchar2,
        p_cs_ea_dup_rec				OUT NOCOPY	sr_dupl_tbl,
        p_ea_ia_dup					OUT NOCOPY 	VARCHAR2,
        p_ea_ea_dup					OUT NOCOPY 	VARCHAR2,
        p_return_status				OUT NOCOPY 	VARCHAR2
	);


    PROCEDURE Perform_Dup_on_SR_field
    ( 	p_customer_product_id   	IN 			NUMBER,
        p_customer_id           	IN 			NUMBER,
        p_inventory_item_id     	IN 			NUMBER,
		p_instance_serial_number 	IN 			VARCHAR2,
    	p_current_serial_number	 	IN			VARCHAR2,
		p_inv_item_serial_number 	IN 			VARCHAR2,
        p_incident_id		  		IN 			NUMBER,
        p_cs_sr_dup_rec         	IN OUT NOCOPY SR_DUPL_TBL,
        p_cs_sr_dup_flag        	IN OUT NOCOPY VARCHAR2,
        p_dup_from		  			IN OUT NOCOPY NUMBER,
        p_return_status		  		OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Check_SR_Instance_Dup
    (
    	p_customer_product_id		IN 			NUMBER,
    	p_incident_id 				IN 			NUMBER,
    	p_cs_sr_dup_link_rec		IN OUT NOCOPY SR_Dupl_Link_Tbl,
    	p_cs_sr_dup_flag			IN OUT NOCOPY VARCHAR2,
    	p_return_status				OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Check_SR_SerialNum_Dup
    (
		p_instance_serial_number 	IN 			VARCHAR2,
    	p_current_serial_number	 	IN			VARCHAR2,
		p_inv_item_serial_number 	IN 			VARCHAR2,
        p_incident_id 				IN 			NUMBER,
        p_cs_sr_dup_link_rec		IN OUT NOCOPY SR_Dupl_Link_Tbl,
        p_cs_sr_dup_flag			IN OUT NOCOPY VARCHAR2,
        p_return_status				OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Check_SR_CustProd_Dup
    (
        p_customer_id         		IN 			NUMBER,
        p_inventory_item_id     	IN 			NUMBER,
        p_incident_id 				IN 			NUMBER,
        p_cs_sr_dup_link_rec		IN OUT NOCOPY SR_Dupl_Link_Tbl,
        p_cs_sr_dup_flag			IN OUT NOCOPY VARCHAR2,
        p_return_status				OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Check_SR_CustProdSerial_Dup
    (
        p_customer_id         		IN 			NUMBER,
        p_inventory_item_id     	IN 			NUMBER,
		p_instance_serial_number 	IN 			VARCHAR2,
    	p_current_serial_number	 	IN			VARCHAR2,
		p_inv_item_serial_number 	IN 			VARCHAR2,
        p_incident_id 				IN 			NUMBER,
        p_cs_sr_dup_link_rec		IN OUT NOCOPY SR_Dupl_Link_Tbl,
        p_cs_sr_dup_flag			IN OUT NOCOPY VARCHAR2,
        p_return_status				OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Construct_Unique_list_dup_sr
    (
        p_cs_ea_dup_rec     		IN 			Sr_Dupl_Tbl,
        p_ea_attr_dup_flag  		IN 			VARCHAR2,
        p_cs_sr_dup_rec     		IN 			Sr_Dupl_Tbl,
        p_cs_sr_dup_flag    		IN 			VARCHAR2,
        p_dup_from		 			IN 			NUMBER,
        p_ea_ea_dup		 			IN 			VARCHAR2,
        p_ea_ia_dup		 			IN 			VARCHAR2,
        p_sr_dup_rec        		IN OUT NOCOPY		Sr_Dupl_Tbl,
        p_duplicate_flag    		IN OUT NOCOPY		VARCHAR2,
		p_return_status				OUT NOCOPY 	VARCHAR2
    );


    PROCEDURE Check_Dup_SR_Link
    (
    	p_dup_found_tbl 			IN			Sr_Dupl_Link_Tbl,
    	p_dup_tbl 					IN OUT NOCOPY Sr_Dupl_Tbl,
    	p_return_status				OUT NOCOPY 	VARCHAR2
    );


     FUNCTION Check_if_already_in_list
     (
    	p_dup_tbl 			IN Sr_Dupl_Tbl,
    	p_sr_link_id 		IN NUMBER
     ) return varchar2;


     FUNCTION Get_Dup_Message
     (
		p_lookup_code		IN VARCHAR2
     ) return varchar2;


    PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME
    (
        p_incident_type_id 		IN NUMBER,
        p_duplicate_time_frame 	OUT NOCOPY DATE
    );


    PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME
    ( p_duplicate_time_frame OUT NOCOPY DATE);


END CS_SR_DUP_CHK_PVT;

 

/
