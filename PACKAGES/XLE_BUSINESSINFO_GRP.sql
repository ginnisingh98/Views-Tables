--------------------------------------------------------
--  DDL for Package XLE_BUSINESSINFO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_BUSINESSINFO_GRP" AUTHID CURRENT_USER AS
/* $Header: xlegbuis.pls 120.22 2005/10/21 15:31:58 spasupun ship $*/


TYPE BG_LE_Rec IS RECORD (
 Business_group_id  	HR_OPERATING_UNITS.business_group_id%TYPE,
 LEGAL_ENTITY_ID  	XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
 PARTY_ID    		XLE_ENTITY_PROFILES.party_id%TYPE
);


TYPE BG_LE_Tbl_Type IS TABLE OF BG_LE_Rec INDEX BY BINARY_INTEGER;


PROCEDURE Get_BusinessGroup_Info(
    	x_return_status      OUT NOCOPY  VARCHAR2,
    	x_msg_count          OUT NOCOPY NUMBER,
    	x_msg_data    	     OUT NOCOPY VARCHAR2,
    	P_LegalEntity_ID     IN  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
        P_party_id   	     IN  XLE_ENTITY_PROFILES.party_id%TYPE,
        p_businessgroup_id   IN   hr_operating_units.business_group_id%type,
        x_businessgroup_info OUT NOCOPY BG_LE_Tbl_Type
    );



TYPE LE_Ledger_Rec IS RECORD (
   Ledger_ID               gl_ledgers.ledger_id%TYPE,
   bal_seg_value           gl_ledger_norm_seg_vals.segment_value%type,
   LEGAL_ENTITY_ID         XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME                    XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID                XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE           XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code       XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company         XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM       XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO         XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER     XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY    XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM          XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO            XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_LINE_1          HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2          HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3          HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY            HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 		   HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 		   HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 		   HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE 	 	   HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY 		   HR_LOCATIONS_ALL.COUNTRY%TYPE

);

TYPE LE_Ledger_Rec_Type IS TABLE OF LE_Ledger_Rec INDEX BY BINARY_INTEGER;

TYPE inv_org_Rec IS RECORD (
   Inv_org_id                 org_organization_definitions.organization_id%type,
   LEGAL_ENTITY_ID  		XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME 			XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID 			XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER    XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG    XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE 		XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code 		XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company 		XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM 		XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO 		XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER 		XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY 	XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM 		XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO 		XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_LINE_1 		HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 		HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 		HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY 		HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 			HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 			HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 			HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE 			HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY 			HR_LOCATIONS_ALL.COUNTRY%TYPE

);

TYPE inv_org_Rec_Type IS TABLE OF inv_org_Rec INDEX BY BINARY_INTEGER;


TYPE OU_LE_Rec IS RECORD (
   Operating_Unit_ID  		NUMBER,
   LEGAL_ENTITY_ID  		XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME 			XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID 			XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER     XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG     XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE 		XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code 		XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company 		XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM 		XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO 		XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER 		XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY 	XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM 		XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO 		XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_LINE_1 		HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 		HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 		HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY		 	HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 			HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 			HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 			HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE 			HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY 			HR_LOCATIONS_ALL.COUNTRY%TYPE
);

TYPE OU_LE_Tbl_Type IS TABLE OF OU_LE_Rec INDEX BY BINARY_INTEGER;


PROCEDURE Get_Ledger_Info(
                      x_return_status   OUT  NOCOPY VARCHAR2,
                      x_msg_data    	OUT  NOCOPY VARCHAR2,
                      P_Ledger_ID    	IN   NUMBER,
                      x_Ledger_info 	OUT  NOCOPY LE_Ledger_Rec_Type
    );

PROCEDURE Get_Ledger_Info(
                      x_return_status   OUT NOCOPY VARCHAR2,
                      x_msg_data    	OUT NOCOPY VARCHAR2,
                      P_Ledger_ID    	IN  NUMBER,
                      P_BSV    		IN  Varchar2,
                      x_Ledger_info 	OUT NOCOPY LE_Ledger_Rec_Type
    );
/*
PROCEDURE Get_Ledger_Info(
                      x_return_status         OUT VARCHAR2,
                      x_msg_data    OUT  VARCHAR2,
                      p_party_id    IN NUMBER,
                      p_LegalEntity_ID IN Number,
                      x_Ledger_info OUT LE_Ledger_Rec_Type
    );

   */

PROCEDURE Get_OperatingUnit_Info(
                      x_return_status         OUT NOCOPY VARCHAR2,
                      x_msg_data    OUT  NOCOPY VARCHAR2,
                      p_operating_unit    IN NUMBER,
                      p_legal_entity_id   IN NUMBER,
                      p_party_id   IN NUMBER,
                      x_ou_le_info OUT NOCOPY OU_LE_Tbl_Type
    );


PROCEDURE Get_InvOrg_Info(
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_data       OUT  NOCOPY VARCHAR2,
                      P_InvOrg_ID      IN NUMBER,
		      P_Le_ID          IN NUMBER,
		      P_Party_ID       IN NUMBER,
                      x_Inv_Le_info OUT NOCOPY inv_org_Rec_Type
    );


FUNCTION Get_Le_Id_Mfg(p_operating_unit   IN NUMBER,
                       p_transaction_type IN NUMBER,
                       p_customer_account IN NUMBER)
RETURN NUMBER;

TYPE ccid_le_Rec IS RECORD (
   Ledger_ID  			gl_ledgers.ledger_id%TYPE,
   ccid 			gl_code_combinations.code_combination_id%type,
   LEGAL_ENTITY_ID  		XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME 			XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID 			XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER    XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG    XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE 		XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code 		XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company 		XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM 		XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO	 	XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER 		XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY 	XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM 		XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO 		XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_STYLE 		HR_LOCATIONS_ALL.STYLE%TYPE,
   ADDRESS_LINE_1 		HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2	 	HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 		HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY 		HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 			HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 			HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 			HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE 			HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY 			HR_LOCATIONS_ALL.COUNTRY%TYPE,
   ATTRIBUTE1 			HR_LOCATIONS_ALL.ATTRIBUTE1%TYPE,
   ATTRIBUTE2 			HR_LOCATIONS_ALL.ATTRIBUTE2%TYPE,
   ATTRIBUTE3 			HR_LOCATIONS_ALL.ATTRIBUTE3%TYPE,
   ATTRIBUTE4 			HR_LOCATIONS_ALL.ATTRIBUTE4%TYPE,
   ATTRIBUTE5 			HR_LOCATIONS_ALL.ATTRIBUTE5%TYPE,
   ATTRIBUTE6 			HR_LOCATIONS_ALL.ATTRIBUTE6%TYPE,
   ATTRIBUTE7 			HR_LOCATIONS_ALL.ATTRIBUTE7%TYPE,
   ATTRIBUTE8 			HR_LOCATIONS_ALL.ATTRIBUTE8%TYPE,
   ATTRIBUTE9 			HR_LOCATIONS_ALL.ATTRIBUTE9%TYPE,
   ATTRIBUTE10 			HR_LOCATIONS_ALL.ATTRIBUTE10%TYPE,
   ATTRIBUTE11 			HR_LOCATIONS_ALL.ATTRIBUTE11%TYPE,
   ATTRIBUTE12 			HR_LOCATIONS_ALL.ATTRIBUTE12%TYPE,
   ATTRIBUTE13 			HR_LOCATIONS_ALL.ATTRIBUTE13%TYPE,
   ATTRIBUTE14 			HR_LOCATIONS_ALL.ATTRIBUTE14%TYPE,
   ATTRIBUTE15 			HR_LOCATIONS_ALL.ATTRIBUTE15%TYPE,
   ATTRIBUTE16 			HR_LOCATIONS_ALL.ATTRIBUTE16%TYPE,
   ATTRIBUTE17 			HR_LOCATIONS_ALL.ATTRIBUTE17%TYPE,
   ATTRIBUTE18 			HR_LOCATIONS_ALL.ATTRIBUTE18%TYPE,
   ATTRIBUTE19 			HR_LOCATIONS_ALL.ATTRIBUTE19%TYPE,
   ATTRIBUTE20 			HR_LOCATIONS_ALL.ATTRIBUTE20%TYPE
);

TYPE ccid_le_Rec_Type IS TABLE OF ccid_le_Rec INDEX BY BINARY_INTEGER;

PROCEDURE Get_CCID_Info(
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_data    OUT NOCOPY VARCHAR2,
                P_operating_unit_ID    IN NUMBER,
                P_code_combination_id    IN Number,
                x_ccid_le_info OUT NOCOPY XLE_BUSINESSINFO_GRP.ccid_le_Rec_Type
    ) ;

TYPE ptop_le_Rec IS RECORD (
   LEGAL_ENTITY_ID  	   XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME                    XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID                XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE           XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code       XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company         XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM       XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO         XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER     XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY    XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM          XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO            XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_LINE_1          HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2          HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 	   HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY            HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1                HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 		   HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 		   HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE   	   HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY    		   HR_LOCATIONS_ALL.COUNTRY%TYPE
);

PROCEDURE Get_PurchasetoPay_Info(
                  x_return_status  	OUT NOCOPY VARCHAR2,
                  x_msg_data       	OUT  NOCOPY VARCHAR2,
                  P_registration_code   IN VARCHAR2 DEFAULT NULL,
                  P_registration_number IN VARCHAR2 DEFAULT NULL,
                  P_location_id 	IN NUMBER DEFAULT NULL,
                  P_code_combination_id IN NUMBER DEFAULT NULL,
                  P_operating_unit_id 	IN NUMBER,
                  x_ptop_Le_info OUT NOCOPY XLE_BUSINESSINFO_GRP.ptop_le_rec);

TYPE otoc_le_rec IS RECORD (
   LEGAL_ENTITY_ID  		XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
   NAME 			XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID 			XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE 		XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code 		XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company 		XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM 		XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO 		XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER 		XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   LEGISLATIVE_CATEGORY 	XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM 		XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO 		XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   ADDRESS_STYLE 		HR_LOCATIONS_ALL.STYLE%TYPE,
   ADDRESS_LINE_1 		HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 		HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 		HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY 		HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 			HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 			HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 			HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE 			HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY 			HR_LOCATIONS_ALL.COUNTRY%TYPE,
   ATTRIBUTE1 HR_LOCATIONS_ALL.ATTRIBUTE1%TYPE,
   ATTRIBUTE2 HR_LOCATIONS_ALL.ATTRIBUTE2%TYPE,
   ATTRIBUTE3 HR_LOCATIONS_ALL.ATTRIBUTE3%TYPE,
   ATTRIBUTE4 HR_LOCATIONS_ALL.ATTRIBUTE4%TYPE,
   ATTRIBUTE5 HR_LOCATIONS_ALL.ATTRIBUTE5%TYPE,
   ATTRIBUTE6 HR_LOCATIONS_ALL.ATTRIBUTE6%TYPE,
   ATTRIBUTE7 HR_LOCATIONS_ALL.ATTRIBUTE7%TYPE,
   ATTRIBUTE8 HR_LOCATIONS_ALL.ATTRIBUTE8%TYPE,
   ATTRIBUTE9 HR_LOCATIONS_ALL.ATTRIBUTE9%TYPE,
   ATTRIBUTE10 HR_LOCATIONS_ALL.ATTRIBUTE10%TYPE,
   ATTRIBUTE11 HR_LOCATIONS_ALL.ATTRIBUTE11%TYPE,
   ATTRIBUTE12 HR_LOCATIONS_ALL.ATTRIBUTE12%TYPE,
   ATTRIBUTE13 HR_LOCATIONS_ALL.ATTRIBUTE13%TYPE,
   ATTRIBUTE14 HR_LOCATIONS_ALL.ATTRIBUTE14%TYPE,
   ATTRIBUTE15 HR_LOCATIONS_ALL.ATTRIBUTE15%TYPE,
   ATTRIBUTE16 HR_LOCATIONS_ALL.ATTRIBUTE16%TYPE,
   ATTRIBUTE17 HR_LOCATIONS_ALL.ATTRIBUTE17%TYPE,
   ATTRIBUTE18 HR_LOCATIONS_ALL.ATTRIBUTE18%TYPE,
   ATTRIBUTE19 HR_LOCATIONS_ALL.ATTRIBUTE19%TYPE,
   ATTRIBUTE20 HR_LOCATIONS_ALL.ATTRIBUTE20%TYPE
);

PROCEDURE Get_OrdertoCash_Info(
             x_return_status       OUT NOCOPY VARCHAR2,
             x_msg_data            OUT  NOCOPY VARCHAR2,
             P_customer_type       IN VARCHAR2 DEFAULT NULL,
             P_customer_id         IN NUMBER DEFAULT NULL,
             P_transaction_type_id IN NUMBER DEFAULT NULL,
             P_batch_source_id     IN  NUMBER DEFAULT NULL,
             P_operating_unit_id   IN NUMBER ,
             x_otoc_Le_info        OUT NOCOPY XLE_BUSINESSINFO_GRP.otoc_le_rec);

FUNCTION Get_OrdertoCash_Info(
                      P_customer_type 		IN VARCHAR2 DEFAULT NULL,
                      P_customer_id 		IN NUMBER DEFAULT NULL,
                      P_transaction_type_id     IN NUMBER DEFAULT NULL,
                      P_batch_source_id 	IN  NUMBER DEFAULT NULL,
                      P_operating_unit_id 	IN NUMBER
                      )
RETURN NUMBER;

FUNCTION Get_OrdertoCash_Info(
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_data       OUT  NOCOPY VARCHAR2,
                      P_customer_type IN VARCHAR2 DEFAULT NULL,
                      P_customer_id IN NUMBER DEFAULT NULL,
                      P_transaction_type_id     IN NUMBER DEFAULT NULL,
                      P_batch_source_id IN  NUMBER DEFAULT NULL,
                      P_operating_unit_id IN NUMBER
                      )
RETURN NUMBER;

END;
 

/
