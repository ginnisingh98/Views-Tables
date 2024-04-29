--------------------------------------------------------
--  DDL for Package IEX_CUST_OVERVIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CUST_OVERVIEW_PVT" AUTHID CURRENT_USER AS
/* $Header: iexvcuos.pls 120.5 2005/02/09 19:35:38 jypark ship $ */

  TYPE Customer_Info_Rec_Type IS RECORD
  (
    PARTY_ID                        NUMBER,
    IDENTIFICATION_ID               VARCHAR2(100),
    CUSTOMER_SINCE                  DATE,
    COLLECTIONS_SCORE               VARCHAR2(100),
    NUMBER_OF_INVOICES              NUMBER,
    NUMBER_OF_DELINQUENCIES         NUMBER,
    INVOICES_OVERDUE                NUMBER,
    STATUS                          VARCHAR2(80),  -- fix bug #2165553 added by jypark 02/18/2002
    CASES_OVERDUE              	    NUMBER,
    NUMBER_OF_DEL_CASES             NUMBER,
    NUMBER_OF_OKL_INV               NUMBER
  );

  TYPE Customer_OKL_Info_Rec_Type IS RECORD
  (
    CASES_OVERDUE              	NUMBER,
    NUMBER_OF_DEL_CASES         NUMBER,
    NUMBER_OF_OKL_INV           NUMBER
  );

  TYPE Object_Info_Rec_Type IS RECORD
  (
    OBJECT_ID                       NUMBER,
    OBJECT_TYPE                     VARCHAR2(100),
    OBJECT_NUMBER                   VARCHAR2(100),
    AMOUNT_OVERDUE                  NUMBER,
    AMOUNT_OVERDUE_CURR             VARCHAR2(15),
    CURRENT_BALANCE                 NUMBER,
    CURRENT_BALANCE_CURR            VARCHAR2(100),
    DSO                             NUMBER,
    LAST_PAYMENT_DATE               DATE,
    LAST_PAYMENT_DUE_DATE           DATE,
    LAST_PAYMENT_AMOUNT             NUMBER,
    LAST_PAYMENT_CURR               VARCHAR2(100),
    LAST_PAYMENT_STATUS             VARCHAR2(80),
    LAST_PAYMENT_RECEIPT_NUMBER     VARCHAR2(30),
    LAST_PAYMENT_ID                 NUMBER,
    LAST_OKL_PAYMENT_DATE           DATE,
    LAST_OKL_PAYMENT_DUE_DATE       DATE,
    LAST_OKL_PAYMENT_AMOUNT         NUMBER,
    LAST_OKL_PAYMENT_CURR           VARCHAR2(100),
    LAST_OKL_PAYMENT_STATUS         VARCHAR2(80),
    LAST_OKL_PAYMENT_RECEIPT_NUM    VARCHAR2(30),
    LAST_OKL_PAYMENT_ID             NUMBER
  );

  TYPE Last_Pmt_Info_Rec_Type IS RECORD
  (
    CASH_RECEIPT_ID NUMBER,
    AMOUNT NUMBER,
    RECEIPT_DATE DATE,
    RECEIPT_NUMBER VARCHAR2(30),
    DUE_DATE DATE,
    STATUS VARCHAR2(80),
	CURRENCY_CODE VARCHAR2(3)
  );

  TYPE Last_OKL_Pmt_Info_Rec_Type IS RECORD
  (
	APPLY_DATE			DATE,
    RECEIVABLE_APPLICATION_ID	NUMBER,
    DUE_DATE			DATE,
    CASH_RECEIPT_ID		NUMBER,
    RECEIPT_NUMBER		VARCHAR2(30),
	AMOUNT_APPLIED		NUMBER,
    CURRENCY_CODE		VARCHAR2(3),
    RECEIPT_STATUS		VARCHAR2(80)
  );

  TYPE Contact_Point_Info_Rec_Type IS RECORD
  (
    PHONE_CONTACT_POINT_ID NUMBER,
    PHONE_COUNTRY_CODE VARCHAR2(10),
    PHONE_AREA_CODE VARCHAR2(10),
    PHONE_NUMBER VARCHAR2(40),
    PHONE_EXTENSION VARCHAR2(20),
    PHONE_LINE_TYPE VARCHAR2(80),
    PHONE_LINE_TYPE_MEANING VARCHAR2(80),
    EMAIL_CONTACT_POINT_ID NUMBER,
    EMAIL_ADDRESS VARCHAR2(2000)
  );

  TYPE Location_Info_Rec_Type IS RECORD
  (
    location_id NUMBER,
    address2 VARCHAR2(240),
    address3 VARCHAR2(240),
    address4 VARCHAR2(240),
    party_id NUMBER,
    address_lines_phonetic VARCHAR2(560),
    po_box_number VARCHAR2(50),
    house_number VARCHAR2(50),
    street_suffix VARCHAR2(50),
    street VARCHAR2(50),
    street_number VARCHAR2(50),
    floor VARCHAR2(50),
    suite VARCHAR2(50),
    time_zone VARCHAR2(80),
    time_zone_meaning VARCHAR2(80),
    timezone_id NUMBER,
    last_update_date DATE,
    creation_date DATE,
    created_by NUMBER,
    last_updated_by NUMBER,
    last_update_login NUMBER,
    site_last_update_date DATE,
    party_site_id NUMBER,
    party_site_number VARCHAR2(30),
    address1 VARCHAR2(240),
    city VARCHAR2(60),
    state VARCHAR2(60),
    province VARCHAR2(60),
    postal_code VARCHAR2(60),
    county VARCHAR2(60),
    country_name VARCHAR2(80),
    country_code VARCHAR2(60),
    object_version_number NUMBER,
    site_object_version_number NUMBER,
    created_by_module VARCHAR2(150),
    application_id  NUMBER);

  PROCEDURE Get_Customer_Info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_party_id         IN  NUMBER,
   p_object_source    IN  VARCHAR2,
   x_customer_info_rec OUT NOCOPY customer_info_rec_type);

  PROCEDURE Get_Object_Info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_object_id        IN  NUMBER,
   p_object_type      IN  VARCHAR2,
   p_object_source    IN  VARCHAR2,
   x_object_info_rec OUT NOCOPY object_info_rec_type);

  PROCEDURE Get_Last_Payment_Info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   x_last_pmt_info_rec OUT NOCOPY last_pmt_info_rec_type);

  PROCEDURE Get_Customer_OKL_Info
  	(p_api_version      		IN  NUMBER := 1.0,
  	p_init_msg_list    		IN  VARCHAR2,
   	p_commit           		IN  VARCHAR2,
   	p_validation_level 		IN  NUMBER,
   	x_return_status    		OUT NOCOPY VARCHAR2,
   	x_msg_count        		OUT NOCOPY NUMBER,
   	x_msg_data         		OUT NOCOPY VARCHAR2,
   	p_party_id         		IN  NUMBER,
   	x_customer_okl_info_rec OUT NOCOPY customer_okl_info_rec_type);

  PROCEDURE Get_Last_OKL_Payment_Info
      (p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       p_object_type      	IN  VARCHAR2,
       p_object_id        	IN  NUMBER,
       x_last_okl_pmt_info_rec  OUT NOCOPY last_okl_pmt_info_rec_type);

  PROCEDURE get_location_Info(
       p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       p_party_id        	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       x_location_info_rec  OUT NOCOPY location_info_rec_type);

  PROCEDURE get_contact_point_info(p_api_version      	IN  NUMBER := 1.0,
       p_init_msg_list    	IN  VARCHAR2,
       p_commit           	IN  VARCHAR2,
       p_validation_level 	IN  NUMBER,
       p_party_id        	IN  NUMBER,
       x_return_status    	OUT NOCOPY VARCHAR2,
       x_msg_count        	OUT NOCOPY NUMBER,
       x_msg_data         	OUT NOCOPY VARCHAR2,
       x_contact_point_info_rec     OUT NOCOPY contact_point_info_rec_type);

  PROCEDURE Get_header_info
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_party_type       IN  VARCHAR2,
   p_rel_party_id     IN  NUMBER,
   p_org_party_id     IN  NUMBER,
   p_person_party_id  IN  NUMBER,
   p_object_type      IN  VARCHAR2,
   p_object_id        IN  NUMBER,
   p_object_source    IN  VARCHAR2,
   x_customer_info_rec OUT NOCOPY customer_info_rec_type,
   x_object_info_rec OUT NOCOPY object_info_rec_type,
   x_contact_point_info_rec OUT NOCOPY contact_point_info_rec_type,
   x_location_info_rec OUT NOCOPY location_info_rec_type);

  PROCEDURE Create_Default_Contact
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2,
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_org_party_id     IN  NUMBER,
   p_person_party_id  IN  NUMBER,
   p_phone_contact_point_id IN  NUMBER,
   p_email_contact_point_id IN  NUMBER,
   p_type             IN  VARCHAR2,
   p_location_id      IN  NUMBER,
   x_relationship_id  OUT NOCOPY NUMBER,
   x_party_id         OUT NOCOPY NUMBER);


END;

 

/
