--------------------------------------------------------
--  DDL for Package XLE_THIRDPARTY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_THIRDPARTY" AUTHID CURRENT_USER AS
/* $Header: xlethpas.pls 120.5 2005/09/22 06:07:33 rbasker ship $ */

  TYPE LegalInformation_Rec IS RECORD (
  legal_name		XLE_ENTITY_PROFILES.NAME%TYPE,
  registration_number	XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
  date_of_birth		PO_VENDORS.GLOBAL_ATTRIBUTE2%TYPE,
  place_of_birth	PO_VENDORS.GLOBAL_ATTRIBUTE3%TYPE,
  company_activity_code PO_VENDORS.STANDARD_INDUSTRY_CLASS%TYPE,
  address_line1		HR_LOCATIONS.ADDRESS_LINE_1%TYPE,
  address_line2		HR_LOCATIONS.ADDRESS_LINE_2%TYPE,
  address_line3     	HR_LOCATIONS.ADDRESS_LINE_3%TYPE,
  city              	HR_LOCATIONS.TOWN_OR_CITY%TYPE,
  zip               	HR_LOCATIONS.REGION_3%TYPE,
  province          	HR_LOCATIONS.REGION_1%TYPE,
  country           	HR_LOCATIONS.COUNTRY%TYPE,
  state             	HR_LOCATIONS.REGION_2%TYPE);




PROCEDURE Get_LegalInformation(

	--   *****  Standard API parameters *****
 	p_api_version           	IN	NUMBER,
  	p_init_msg_list	        	IN	VARCHAR2,
  	p_commit			IN	VARCHAR2,
  	x_return_status         	OUT     NOCOPY  VARCHAR2,
  	x_msg_count	        	OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,

	--   *****  Business Entity information parameters *****
	p_business_entity_type          IN      VARCHAR2,
	p_business_entity_id            IN      NUMBER,
	p_business_entity_site_id       IN      NUMBER,
	p_country               	IN      VARCHAR2,
	p_legal_function	        IN      VARCHAR2,
        p_legislative_category          IN      VARCHAR2,
	x_legal_information_rec		OUT     NOCOPY LegalInformation_Rec);


Procedure Get_TP_VATRegistration_PTY
   (
    p_api_version           	IN	NUMBER,
  	p_init_msg_list	     	IN	VARCHAR2,
  	p_commit		IN	VARCHAR2,
  	p_effective_date        IN  zx_registrations.effective_from%Type,
  	x_return_status         OUT NOCOPY  VARCHAR2,
  	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_party_id       	IN  NUMBER,
	p_party_type            IN  VARCHAR2,
	x_registration_number   OUT NOCOPY  NUMBER
   );



END;

 

/
