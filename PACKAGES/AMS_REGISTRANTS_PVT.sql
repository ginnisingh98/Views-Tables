--------------------------------------------------------
--  DDL for Package AMS_REGISTRANTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_REGISTRANTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvevrs.pls 115.6 2002/11/22 23:37:10 dbiswas ship $ */
-- PACKAGE
--   AMS_Registrants_PVT
--
-- HISTORY
-- 12-MAR-2002    dcastlem     Added support for general Public API
--                             (AMS_Registrants_PUB)
-- 18-MAR-2002    dcastlem     Cleaned up some code in B2B and added
--                             org party id as an out parameter
-- 05-APR-2002    dcastlem     Rewrote party_detail_rec_type to include all fields

/*
TYPE party_detail_rec_type IS RECORD(
	PERSON_FIRST_NAME  VARCHAR2(150):= FND_API.G_MISS_CHAR,
	PERSON_MIDDLE_NAME VARCHAR2(60) := FND_API.G_MISS_CHAR,
	PERSON_LAST_NAME VARCHAR2(150):= FND_API.G_MISS_CHAR,
	PERSON_NAME_SUFFIX VARCHAR2(30) := FND_API.G_MISS_CHAR,
	PERSON_TITLE    VARCHAR2(60) :=  FND_API.G_MISS_CHAR,
	PRE_NAME_ADJUNCT   VARCHAR2(30) := FND_API.G_MISS_CHAR,
	SALUTATION   VARCHAR2(60) := FND_API.G_MISS_CHAR,

	JOB_TITLE   VARCHAR2(100) := FND_API.G_MISS_CHAR,
	DECISION_MAKER_FLAG   VARCHAR2(1) := FND_API.G_MISS_CHAR,
	DEPARTMENT   VARCHAR2(30) := FND_API.G_MISS_CHAR,
	PARTY_NAME   VARCHAR2(360) := FND_API.G_MISS_CHAR,
	ORGANIZATION_NAME_PHONETIC  VARCHAR2(320) := FND_API.G_MISS_CHAR,

	BEST_TIME_CONTACT_BEGIN  DATE := FND_API.G_MISS_DATE,
	BEST_TIME_CONTACT_END  DATE := FND_API.G_MISS_DATE,
	COUNTRY  VARCHAR2(60) := FND_API.G_MISS_CHAR,
	ADDRESS1  VARCHAR2(240) := FND_API.G_MISS_CHAR,
	ADDRESS2  VARCHAR2(240) := FND_API.G_MISS_CHAR,
	CITY  VARCHAR2(60) := FND_API.G_MISS_CHAR,
	COUNTY   VARCHAR2(60) := FND_API.G_MISS_CHAR,
	STATE   VARCHAR2(60) := FND_API.G_MISS_CHAR,
	PROVINCE   VARCHAR2(60) := FND_API.G_MISS_CHAR,
	POSTAL_CODE  VARCHAR2(60):= FND_API.G_MISS_CHAR,
	TIME_ZONE  VARCHAR2(50) := FND_API.G_MISS_CHAR,
	ADDRESS3    VARCHAR2(240) := FND_API.G_MISS_CHAR,
	ADDRESS4   VARCHAR2(240) := FND_API.G_MISS_CHAR,
	ADDRESS_LINES_PHONETIC  VARCHAR2(560) := FND_API.G_MISS_CHAR ,
	APARTMENT_FLAG    VARCHAR2(1):= FND_API.G_MISS_CHAR ,
	PO_BOX_NUMBER    VARCHAR2(50) := FND_API.G_MISS_CHAR,
	HOUSE_NUMBER      VARCHAR2(50) := FND_API.G_MISS_CHAR,
	STREET_SUFFIX    VARCHAR2(50):= FND_API.G_MISS_CHAR,
	SECONDARY_SUFFIX_ELEMENT   VARCHAR2(240) := FND_API.G_MISS_CHAR,
	STREET       VARCHAR2(50) := FND_API.G_MISS_CHAR,
	RURAL_ROUTE_TYPE  VARCHAR2(50) := FND_API.G_MISS_CHAR,
	RURAL_ROUTE_NUMBER    VARCHAR2(50) := FND_API.G_MISS_CHAR,
	STREET_NUMBER     VARCHAR2(50):= FND_API.G_MISS_CHAR,
	FLOOR        VARCHAR2(50):= FND_API.G_MISS_CHAR,
	SUITE          VARCHAR2(50) := FND_API.G_MISS_CHAR,
	POSTAL_PLUS4_CODE  VARCHAR2(10) := FND_API.G_MISS_CHAR,
	OVERSEAS_ADDRESS_FLAG VARCHAR2(1) := FND_API.G_MISS_CHAR,
	EMAIL_ADDRESS VARCHAR2(2000) := FND_API.G_MISS_CHAR ,
	PHONE_COUNTRY_CODE  VARCHAR2(10) := FND_API.G_MISS_CHAR,
	PHONE_AREA_CODE  VARCHAR2(10) := FND_API.G_MISS_CHAR,
	PHONE_NUMBER VARCHAR2(40):= FND_API.G_MISS_CHAR,
	PHONE_EXTENTION   VARCHAR2(20) := FND_API.G_MISS_CHAR
);
*/
TYPE party_detail_rec_type IS RECORD(
   party_id                       NUMBER,
   party_type                     VARCHAR2(30),
   contact_id                     NUMBER,
   party_name                     VARCHAR2(360),
   title                          VARCHAR2(30),
   first_name                     VARCHAR2(150),
   middle_name                    VARCHAR2(60),
   last_name                      VARCHAR2(150),
   address1                       VARCHAR2(240),
   address2                       VARCHAR2(240),
   address3                       VARCHAR2(240),
   address4                       VARCHAR2(240),
   gender                         VARCHAR2(30),
   address_line_phonetic          VARCHAR2(360),
   analysis_fy                    VARCHAR2(5),
   apt_flag                       VARCHAR2(1),
   best_time_contact_begin        DATE,
   best_time_contact_end          DATE,
   category_code                  VARCHAR2(30),
   ceo_name                       VARCHAR2(360),
   city                           VARCHAR2(60),
   country                        VARCHAR2(60),
   county                         VARCHAR2(60),
   current_fy_potential_rev       NUMBER,
   next_fy_potential_rev          NUMBER,
   household_income               NUMBER,
   decision_maker_flag            VARCHAR2(1),
   department                     VARCHAR2(360),
   dun_no_c                       VARCHAR2(30),
   email_address                  VARCHAR2(2000),
   employee_total                 NUMBER,
   fy_end_month                   VARCHAR2(30),
   floor                          VARCHAR2(50),
   gsa_indicator_flag             VARCHAR2(30),
   house_number                   NUMBER,
   identifying_address_flag       VARCHAR2(1),
   jgzz_fiscal_code               VARCHAR2(20),
   job_title                      VARCHAR2(100),
   last_order_date                DATE,
   org_legal_status               VARCHAR2(30),
   line_of_business               VARCHAR2(240),
   mission_statement              VARCHAR2(2000),
   org_name_phonetic              VARCHAR2(320),
   overseas_address_flag          VARCHAR2(1),
   name_suffix                    VARCHAR2(30),
   phone_area_code                VARCHAR2(10),
   phone_country_code             VARCHAR2(10),
   phone_extension                VARCHAR2(20),
   phone_number                   VARCHAR2(40),
   postal_code                    VARCHAR2(60),
   postal_plus4_code              VARCHAR2(4),
   po_box_no                      VARCHAR2(50),
   province                       VARCHAR2(60),
   rural_route_no                 VARCHAR2(50),
   rural_route_type               VARCHAR2(30),
   secondary_suffix_element       VARCHAR2(30),
   sic_code                       VARCHAR2(30),
   sic_code_type                  VARCHAR2(30),
   site_use_code                  VARCHAR2(30),
   state                          VARCHAR2(60),
   street                         VARCHAR2(50),
   street_number                  VARCHAR2(50),
   street_suffix                  VARCHAR2(50),
   suite                          VARCHAR2(50),
   tax_name                       VARCHAR2(30),
   tax_reference                  VARCHAR2(50),
   timezone                       NUMBER,
   total_no_of_orders             NUMBER,
   total_order_amount             NUMBER,
   year_established                NUMBER,
   url                            VARCHAR2(2000),
   survey_notes                   VARCHAR2(240),
   contact_me_flag                VARCHAR2(1),
   email_ok_flag                  VARCHAR2(1)

/*
   PERSON_FIRST_NAME  VARCHAR2(150),
   PERSON_MIDDLE_NAME VARCHAR2(60) ,
   PERSON_LAST_NAME VARCHAR2(150),
   PERSON_NAME_SUFFIX VARCHAR2(30) ,
   PERSON_TITLE    VARCHAR2(60) ,
   PRE_NAME_ADJUNCT   VARCHAR2(30) ,
   SALUTATION   VARCHAR2(60),

   JOB_TITLE   VARCHAR2(100),
   DECISION_MAKER_FLAG   VARCHAR2(1),
   DEPARTMENT   VARCHAR2(30),
   PARTY_NAME   VARCHAR2(360) ,
   ORGANIZATION_NAME_PHONETIC VARCHAR2(320) ,

   BEST_TIME_CONTACT_BEGIN  DATE ,
   BEST_TIME_CONTACT_END  DATE ,
   COUNTRY  VARCHAR2(60),
   ADDRESS1  VARCHAR2(240) ,
   ADDRESS2  VARCHAR2(240) ,
   CITY  VARCHAR2(60) ,
   COUNTY   VARCHAR2(60) ,
   STATE   VARCHAR2(60) ,
   PROVINCE   VARCHAR2(60) ,
   POSTAL_CODE  VARCHAR2(60),
   TIME_ZONE  VARCHAR2(50) ,
   ADDRESS3    VARCHAR2(240) ,
   ADDRESS4   VARCHAR2(240),
   ADDRESS_LINES_PHONETIC  VARCHAR2(560) ,
   APARTMENT_FLAG    VARCHAR2(1),
   PO_BOX_NUMBER    VARCHAR2(50) ,
   HOUSE_NUMBER      VARCHAR2(50),
   STREET_SUFFIX    VARCHAR2(50),
   SECONDARY_SUFFIX_ELEMENT   VARCHAR2(240) ,
   STREET       VARCHAR2(50) ,
   RURAL_ROUTE_TYPE  VARCHAR2(50) ,
   RURAL_ROUTE_NUMBER    VARCHAR2(50),
   STREET_NUMBER     VARCHAR2(50),
   FLOOR        VARCHAR2(50),
   SUITE          VARCHAR2(50) ,
   POSTAL_PLUS4_CODE  VARCHAR2(10),
   OVERSEAS_ADDRESS_FLAG VARCHAR2(1),
   EMAIL_ADDRESS VARCHAR2(2000) ,
   PHONE_COUNTRY_CODE  VARCHAR2(10) ,
   PHONE_AREA_CODE  VARCHAR2(10) ,
   PHONE_NUMBER VARCHAR2(40),
   PHONE_EXTENTION   VARCHAR2(20)
   */
);

---------------------------------------------------------------------
-- PROCEDURE
--    find_a_party
--
-- PURPOSE
--    Find the  party id of a party
--
-- PARAMETERS
--    p_party_rec: the new record contains parameter for a party
--    x_party_id: return the event_offer_id of the new event offer
--
-- NOTES

---------------------------------------------------------------------

PROCEDURE find_a_party(
	p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
	p_rec		           IN  party_detail_rec_type,
	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,
	x_party_id          OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    create_party
--
-- PURPOSE
--    Find the  party id of a party
--
-- PARAMETERS
--    p_party_rec: the new record contains parameter for a party
--    x_party_id: return the event_offer_id of the new event offer
--
-- NOTES

---------------------------------------------------------------------

PROCEDURE create_registrant_party(
	p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
	p_commit            IN  VARCHAR2  := FND_API.g_false,
	p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
	p_rec               IN  party_detail_rec_type,

	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,

	x_new_party_id      OUT NOCOPY NUMBER,
   x_new_org_party_id  OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    get_party_id
--
-- PURPOSE
--    get the  party id of a party
--
-- PARAMETERS
--    p_party_rec: the new record contains parameter for a party
--    x_party_id: return the event_offer_id of the new event offer
--
-- NOTES

---------------------------------------------------------------------

PROCEDURE get_party_id(
	p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
	p_commit            IN  VARCHAR2  := FND_API.g_false,
	p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
	p_rec               IN  party_detail_rec_type,

	x_return_status     OUT NOCOPY VARCHAR2,
	x_msg_count         OUT NOCOPY NUMBER,
	x_msg_data          OUT NOCOPY VARCHAR2,

	x_new_party_id      OUT NOCOPY NUMBER,
   x_new_org_party_id  OUT NOCOPY NUMBER
);

--=================================================================================
--Function
--   Get_Event_Det
--
--Purpose
--   Function will return the Event id for the source code passed.
--
-- History
--   24-Feb-2002   ptendulk   Created
--
--=================================================================================
FUNCTION Get_Event_Det(p_source_code   IN VARCHAR2)
RETURN NUMBER ;

END AMS_Registrants_PVT;

 

/
