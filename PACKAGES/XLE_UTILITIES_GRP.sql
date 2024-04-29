--------------------------------------------------------
--  DDL for Package XLE_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_UTILITIES_GRP" AUTHID CURRENT_USER AS
/* $Header: xlegfpts.pls 120.42 2006/01/27 19:55:36 shnaraya ship $*/


--G_PKG_NAME CONSTANT VARCHAR2(30):=' XLE_UTILITIES_GRP';
-- TYPE RegNum_tbl_type IS TABLE OF XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE  INDEX BY BINARY_INTEGER;

TYPE RegNum_Rec IS RECORD (
 registration_number XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
 legislative_cat_code XLE_JURISDICTIONS_VL.LEGISLATIVE_CAT_CODE%TYPE
);
TYPE RegNum_tbl_type IS TABLE OF RegNum_Rec INDEX BY BINARY_INTEGER;

TYPE PartyClass_Rec IS RECORD (
 class_category XLE_LOOKUPS.LOOKUP_TYPE%TYPE,
 class_code XLE_LOOKUPS.LOOKUP_CODE%TYPE,
 meaning    XLE_LOOKUPS.meaning%TYPE
);

TYPE PartyClass_tbl_type IS TABLE OF PartyClass_Rec INDEX BY BINARY_INTEGER;

TYPE PartyID_tbl_type IS TABLE OF HR_ALL_ORGANIZATION_UNITS.PARTY_ID%TYPE INDEX BY BINARY_INTEGER;

TYPE CountryCode_Rec IS RECORD (
 country_code HZ_GEOGRAPHIES.COUNTRY_CODE%TYPE
);

TYPE CountryCode_tbl_type IS TABLE OF CountryCode_Rec INDEX BY BINARY_INTEGER;

TYPE LegalEntity_tbl_type IS TABLE OF XLE_ENTITY_PROFILES.legal_entity_id%TYPE;

TYPE History_Rec IS RECORD (
 SOURCE_TABLE XLE_HISTORIES.SOURCE_TABLE%TYPE,
 SOURCE_ID XLE_HISTORIES.SOURCE_ID%TYPE,
 SOURCE_COLUMN_NAME XLE_HISTORIES.SOURCE_COLUMN_NAME%TYPE,
 SOURCE_COLUMN_VALUE XLE_HISTORIES.SOURCE_COLUMN_VALUE%TYPE,
 EFFECTIVE_FROM XLE_HISTORIES.EFFECTIVE_FROM%TYPE,
 EFFECTIVE_TO XLE_HISTORIES.EFFECTIVE_TO%TYPE,
 COMMENTS XLE_HISTORIES.COMMENTS%TYPE
);

TYPE History_Tbl_Type IS TABLE OF History_Rec INDEX BY BINARY_INTEGER;



-- Start of comments
--      API name      : Get_LegalEntityID_OU (Stamping API)
--      Type          : Group
--      Function      : Used for Stamping Transactions with Legal Entity ID
--      Pre-reqs      : None.
--      Parameters    :
--      IN            :  p_api_version       IN NUMBER      Required
--                       p_init_msg_list     IN VARCHAR2       Optional
--                                          Default = FND_API.G_FALSE
--                       p_commit            IN VARCHAR2      Optional
--                                           Default = FND_API.G_FALSE
--
--                       p_operating_unit    IN      NUMBER ,
--
--
--      OUT            : x_return_status     OUT      VARCHAR2(1)
--                       x_msg_count         OUT      NUMBER
--                       x_msg_data          OUT      VARCHAR2(2000)
--                       x_LegalEntity_tbl   OUT     LegalEntity_tbl_type
--
--      Version      : Current version      1.0
--                        Changed....
--                    previous version      1.0
--                        Changed....
--
--                    Initial version       1.0
--
--      Notes            :  Requesting Team : Legal Entity
--
-- End of comments




TYPE Registration_Rec IS RECORD (
   PARTY_ID XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   ENTITY_ID XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
   ENTITY_NAME XLE_ENTITY_PROFILES.NAME%TYPE,
   ENTITY_TYPE VARCHAR2(100),
   REGISTRATION_NUMBER XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   REGISTERED_NAME XLE_REGISTRATIONS.registered_name%TYPE,
   ALTERNATE_REGISTERED_NAME XLE_REGISTRATIONS.alternate_registered_name%TYPE,
   identifying_flag XLE_REGISTRATIONS.IDENTIFYING_FLAG%TYPE,
   LEGISLATIVE_CATEGORY XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   LEGALAUTH_NAME HZ_PARTIES.PARTY_NAME%TYPE,
   LEGALAUTH_ADDRESS VARCHAR2(1000),
   EFFECTIVE_FROM XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   LOCATION_ID XLE_REGISTRATIONS.location_id%TYPE,
   ADDRESS_LINE_1 HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY HR_LOCATIONS_ALL.COUNTRY%TYPE
   );

TYPE Registration_Tbl_Type IS TABLE OF Registration_Rec INDEX BY BINARY_INTEGER;


TYPE Establishment_Rec IS RECORD (
   ESTABLISHMENT_ID XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
   ESTABLISHMENT_NAME XLE_ETB_PROFILES.NAME%TYPE,
   PARTY_ID XLE_ETB_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_ID XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
   MAIN_ESTABLISHMENT_FLAG XLE_ETB_PROFILES.MAIN_ESTABLISHMENT_FLAG%TYPE,
   ACTIVITY_CODE XLE_ETB_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code XLE_ETB_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company XLE_ETB_PROFILES.type_of_company%TYPE,
   ETB_EFFECTIVE_FROM XLE_ETB_PROFILES.EFFECTIVE_FROM%TYPE,
   ETB_EFFECTIVE_TO XLE_ETB_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   identifying_flag XLE_REGISTRATIONS.IDENTIFYING_FLAG%TYPE,
   LEGISLATIVE_CATEGORY XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   LOCATION_ID XLE_REGISTRATIONS.location_id%TYPE,
   ADDRESS_LINE_1 HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY HR_LOCATIONS_ALL.COUNTRY%TYPE
   );

TYPE Establishment_Tbl_Type IS TABLE OF Establishment_Rec INDEX BY BINARY_INTEGER;

TYPE LegalEntity_Rec IS RECORD (
   LEGAL_ENTITY_ID XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
   NAME XLE_ENTITY_PROFILES.NAME%TYPE,
   PARTY_ID XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
   LEGAL_ENTITY_IDENTIFIER XLE_ENTITY_PROFILES.LEGAL_ENTITY_IDENTIFIER%TYPE,
   TRANSACTING_ENTITY_FLAG XLE_ENTITY_PROFILES.TRANSACTING_ENTITY_FLAG%TYPE,
   ACTIVITY_CODE XLE_ENTITY_PROFILES.ACTIVITY_CODE%TYPE,
   sub_activity_code XLE_ENTITY_PROFILES.SUB_ACTIVITY_CODE%TYPE,
   type_of_company XLE_ENTITY_PROFILES.type_of_company%TYPE,
   LE_EFFECTIVE_FROM XLE_ENTITY_PROFILES.EFFECTIVE_FROM%TYPE,
   LE_EFFECTIVE_TO XLE_ENTITY_PROFILES.EFFECTIVE_TO%TYPE,
   REGISTRATION_NUMBER XLE_REGISTRATIONS.REGISTRATION_NUMBER%TYPE,
   identifying_flag XLE_REGISTRATIONS.IDENTIFYING_FLAG%TYPE,
   LEGISLATIVE_CATEGORY XLE_JURISDICTIONS_VL.legislative_cat_code%TYPE,
   EFFECTIVE_FROM XLE_REGISTRATIONS.EFFECTIVE_FROM%TYPE,
   EFFECTIVE_TO XLE_REGISTRATIONS.EFFECTIVE_TO%TYPE,
   LOCATION_ID XLE_REGISTRATIONS.location_id%TYPE,
   ADDRESS_LINE_1 HR_LOCATIONS_ALL.ADDRESS_LINE_1%TYPE,
   ADDRESS_LINE_2 HR_LOCATIONS_ALL.ADDRESS_LINE_2%TYPE,
   ADDRESS_LINE_3 HR_LOCATIONS_ALL.ADDRESS_LINE_3%TYPE,
   TOWN_OR_CITY HR_LOCATIONS_ALL.TOWN_OR_CITY%TYPE,
   REGION_1 HR_LOCATIONS_ALL.REGION_1%TYPE,
   REGION_2 HR_LOCATIONS_ALL.REGION_2%TYPE,
   REGION_3 HR_LOCATIONS_ALL.REGION_3%TYPE,
   POSTAL_CODE HR_LOCATIONS_ALL.POSTAL_CODE%TYPE,
   COUNTRY HR_LOCATIONS_ALL.COUNTRY%TYPE
   );

TYPE Legal_Entity_Tbl_Type IS TABLE OF LegalEntity_Rec INDEX BY BINARY_INTEGER;

PROCEDURE Get_Registration_Info(
          x_return_status         OUT NOCOPY  VARCHAR2     ,
          x_msg_count             OUT NOCOPY NUMBER   ,
          x_msg_data              OUT NOCOPY VARCHAR2,
          P_PARTY_ID              IN XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
          P_ENTITY_ID             IN XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
          P_ENTITY_TYPE           IN VARCHAR2,
          P_identifying_flag      IN VARCHAR2,
          P_LEGISLATIVE_CATEGORY  IN VARCHAR2,
          X_REGISTRATION_INFO     OUT NOCOPY Registration_Tbl_Type);


PROCEDURE Get_Establishment_Info(
          x_return_status      OUT NOCOPY VARCHAR2 ,
          x_msg_count          OUT NOCOPY NUMBER ,
          x_msg_data           OUT NOCOPY VARCHAR2 ,
          P_PARTY_ID           IN  XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
          P_ESTABLISHMENT_ID   IN  XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
          p_legalentity_id     IN  XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
	  p_etb_reg            IN  VARCHAR2 default 'Y',
          X_ESTABLISHMENT_INFO OUT NOCOPY Establishment_Tbl_Type);

PROCEDURE Get_LegalEntity_Info(
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER,
          x_msg_data         OUT NOCOPY VARCHAR2,
          P_PARTY_ID         IN  XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
          P_LegalEntity_ID   IN  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
          X_LEGALENTITY_INFO OUT NOCOPY LegalEntity_Rec);


PROCEDURE Get_History_Info(
          x_return_status   OUT NOCOPY  VARCHAR2,
          x_msg_count       OUT NOCOPY NUMBER,
          x_msg_data        OUT NOCOPY VARCHAR2,
          P_ENTITY_ID       IN  XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
          P_ENTITY_TYPE     IN  VARCHAR2,
          P_EFFECTIVE_DATE  IN  VARCHAR2,
          X_HISTORY_INFO    OUT NOCOPY History_Tbl_Type);



PROCEDURE Get_LegalEntityID_OU(
          p_api_version     IN  NUMBER,
          p_init_msg_list   IN  VARCHAR2,
          p_commit          IN  VARCHAR2,
          x_return_status   OUT NOCOPY  VARCHAR2,
          x_msg_count       OUT NOCOPY NUMBER,
          x_msg_data        OUT NOCOPY VARCHAR2,
          p_operating_unit  IN  NUMBER,
          x_LegalEntity_tbl OUT NOCOPY LegalEntity_tbl_type);
-- Start of comments
--      API name      : Get_LegalEntityName_PID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version      IN i NUMBER     Required
--                      p_init_msg_list    IN  VARCHAR2    Optional
--                                                   Default = FND_API.G_FALSE
--                      p_commit           IN   VARCHAR2   Optional
--                                                   Default = FND_API.G_FALSE
--
--                      p_party_id         IN   NUMBER ,
--
--
--      OUT           : x_return_status     OUT VARCHAR2(1)
--                      x_msg_count         OUT NUMBER
--                      x_msg_data          OUT VARCHAR2(2000)
--                      x_Legal_entity_name OUT NOCOPY VARCHAR2
--      Version      : Current version      1.0
--                        Changed....
--                    previous version      1.0
--                        Changed....
--
--                    Initial version       1.0
--
--      Notes         :  Requesting Team : Legal Entity
--
-- End of comments
PROCEDURE Get_LegalEntityName_PID(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2,
        p_commit            IN  VARCHAR2,
        x_return_status     OUT NOCOPY VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_party_id          IN  NUMBER,
        x_legal_entity_name OUT NOCOPY VARCHAR2) ;

-- Start of comments
--      API name      : Get_CountryCode_LID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            :  p_api_version          IN NUMBER     Required
--                       p_init_msg_list        IN VARCHAR2   Optional
--                                                  Default = FND_API.G_FALSE
--                       p_commit               IN VARCHAR2   Optional
--                                                  Default = FND_API.G_FALSE
--
--                       p_ledger_id            IN  NUMBER,
--
--
--      OUT           :  x_return_status        OUT VARCHAR2(1)
--                       x_msg_count            OUT NUMBER
--                       x_msg_data             OUT VARCHAR2(2000)
--                       x_register_country_tbl OUT NOCOPY CountryCode_tbl_type
--      Version      : Current version              1.0
--                        Changed....
--                    previous version      1.0
--                        Changed....
--
--                    Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments

  PROCEDURE Get_FP_CountryCode_LID(
        p_api_version          IN  NUMBER ,
        p_init_msg_list        IN  VARCHAR2,
        p_commit               IN  VARCHAR2,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER ,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ledger_id            IN  NUMBER,
        x_register_country_tbl OUT NOCOPY CountryCode_tbl_type) ;




-- Start of comments
--      API name      : Get_CountryCode_OU
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version          IN NUMBER    Required
--                      p_init_msg_list        IN VARCHAR2  Optional
--                                                  Default = FND_API.G_FALSE
--                      p_commit               IN VARCHAR2   Optional
--                                                  Default = FND_API.G_FALSE
--
--                      p_operating_unit       IN NUMBER
--
--
--      OUT           : x_return_status        OUT VARCHAR2(1)
--                      x_msg_count            OUT NUMBER
--                      x_msg_data             OUT VARCHAR2(2000)
--                      x_register_country_tbl OUT NOCOPY CountryCode_tbl_type
--      Version      :               Current version              1.0
--                        Changed....
--                    previous version      1.0
--                        Changed....
--
--                    Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments

  PROCEDURE Get_FP_CountryCode_OU(
        p_api_version     IN  NUMBER,
        p_init_msg_list   IN  VARCHAR2,
        p_commit          IN  VARCHAR2,
        x_return_status   OUT NOCOPY  VARCHAR2,
        x_msg_count       OUT NOCOPY NUMBER ,
        x_msg_data        OUT NOCOPY VARCHAR2 ,
        p_operating_unit  IN  NUMBER,
        x_country_code    OUT NOCOPY VARCHAR2) ;

-- Start of comments
--      API name      : IsEstablishment_PID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version    IN NUMBER     Required
--                      p_init_msg_list  IN VARCHAR2   Optional
--                                              Default = FND_API.G_FALSE
--                      p_commit         IN VARCHAR2   Optional
--                                              Default = FND_API.G_FALSE
--
--                      p_party_id       IN  NUMBER
--
--
--      OUT           : x_return_status OUT VARCHAR2(1)
--                      x_msg_count     OUT NUMBER
--                      x_msg_data      OUT VARCHAR2(2000)
--                      x_establishment OUT NOCOPY VARCHAR2
--      Version      : Current version              1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments

   PROCEDURE IsEstablishment_PID(
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2,
        p_commit        IN  VARCHAR2,
        x_return_status OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_party_id      IN  NUMBER ,
        x_establishment OUT NOCOPY VARCHAR2 )  ;

-- Start of comments
--      API name      : IsTransEntity_PID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version   IN NUMBER    Required
--                      p_init_msg_list IN VARCHAR2  Optional
--                                           Default = FND_API.G_FALSE
--                      p_commit        IN VARCHAR2  Optional
--                                           Default = FND_API.G_FALSE
--
--                      p_party_id      IN  NUMBER
--
--
--      OUT           : x_return_status OUT VARCHAR2(1)
--                      x_msg_count     OUT NUMBER
--                      x_msg_data      OUT VARCHAR2(2000)
--                      x_TransEntity   OUT NOCOPY VARCHAR2
--      Version      : Current version              1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments
   PROCEDURE IsTransEntity_PID (
        p_api_version   IN  NUMBER,
        p_init_msg_list IN  VARCHAR2,
        p_commit        IN  VARCHAR2,
        x_return_status OUT NOCOPY  VARCHAR2 ,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data      OUT NOCOPY VARCHAR2,
        p_party_id      IN  NUMBER ,
        x_TransEntity   OUT NOCOPY VARCHAR2) ;

-- Start of comments
--      API name      : Get_PartyID_OU
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version    IN NUMBER    Required
--                      p_init_msg_list  IN VARCHAR2  Optional
--                                         Default = FND_API.G_FALSE
--                      p_commit         IN VARCHAR2  Optional
--                                          Default = FND_API.G_FALSE
--
--                      p_operating_unit IN   NUMBER
--
--
--      OUT           : x_return_status  OUT  VARCHAR2(1)
--                      x_msg_count      OUT  NUMBER
--                      x_msg_data       OUT  VARCHAR2(2000)
--                      x_party_tbl      OUT  NOCOPY PartyID_tbl_type
--      Version    :  Current version     1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments
  PROCEDURE Get_PartyID_OU(
        p_api_version    IN   NUMBER ,
        p_init_msg_list  IN   VARCHAR2,
        p_commit         IN   VARCHAR2,
        x_return_status  OUT  NOCOPY  VARCHAR2 ,
        x_msg_count      OUT  NOCOPY NUMBER,
        x_msg_data       OUT  NOCOPY VARCHAR2 ,
        p_operating_unit IN   NUMBER,
        x_party_tbl      OUT  NOCOPY PartyID_tbl_type) ;

-- Start of comments
--      API name      : Is_Intercompany_LEID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version      IN NUMBER   Required
--                      p_init_msg_list    IN VARCHAR2 Optional
--                                            Default = FND_API.G_FALSE
--                      p_commit           IN VARCHAR2 Optional
--                                            Default = FND_API.G_FALSE
--                      p_legal_entity_id1 IN VARCHAR2                        ,
--                      p_legal_entity_id2 IN VARCHAR2
--
--
--
--      OUT          :   x_return_status OUT  VARCHAR2(1)
--                       x_msg_count     OUT  NUMBER
--                       x_msg_data      OUT  VARCHAR2(2000)
--                       x_Intercompany  OUT  NOCOPY VARCHAR2
--      Version      :  Current version           1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments


    PROCEDURE Is_Intercompany_LEID(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2,
        p_commit            IN  VARCHAR2,
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_count         OUT NOCOPY NUMBER,
        x_msg_data          OUT NOCOPY VARCHAR2 ,
        p_legal_entity_id1  IN  VARCHAR2 ,
        p_legal_entity_id2  IN  VARCHAR2,
        x_Intercompany      OUT NOCOPY VARCHAR2) ;


-- Start of comments
--      API name      : Get_ME_PARTYID_LEID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER   Required
--                      p_init_msg_list     IN VARCHAR2 Optional
--                                Default = FND_API.G_FALSE
--                      p_commit           IN VARCHAR2 Optional
--                                Default = FND_API.G_FALSE
--                      p_legal_entity_id  IN VARCHAR2,
--                      p_legal_entity_id2 IN VARCHAR2
--
--
--
--
--      OUT           :  x_return_status    OUT  VARCHAR2(1)
--                       x_msg_count        OUT  NUMBER
--                       x_msg_data         OUT  VARCHAR2(2000)
--                       x_me_party_id      OUT  NOCOPY VARCHAR2
--      Version      : Current version            1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team : ETax
--
-- End of comments

PROCEDURE Get_ME_PARTYID_LEID(
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2,
        p_commit           IN  VARCHAR2,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        x_msg_data         OUT NOCOPY VARCHAR2,
        p_legal_entity_id  IN  VARCHAR2,
        x_me_party_id      OUT NOCOPY VARCHAR2);


-- Start of comments
--      API name      : Get_RegisterNumber_PID
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version   IN NUMBER    Required
--                      p_init_msg_list IN VARCHAR2  Optional
--                                Default = FND_API.G_FALSE
--                      p_commit        IN VARCHAR2  Optional
--                                Default = FND_API.G_FALSE
--                      p_party_id      IN  NUMBER
--
--
--
--
--      OUT           : x_return_status OUT VARCHAR2(1)
--                      x_msg_count     OUT NUMBER
--                      x_msg_data      OUT VARCHAR2(2000)
--                      x_regnum_tbl    OUT NOCOPY RegNum_tbl_type
--      Version      :  Current version           1.0
--                        Changed....
--                          previous version      1.0
--                        Changed....
--
--                          Initial version       1.0
--
--      Notes            :  Requesting Team :
--
-- End of comments

  PROCEDURE Get_RegisterNumber_PID(
        p_api_version    IN   NUMBER,
        p_init_msg_list  IN   VARCHAR2,
        p_commit         IN   VARCHAR2,
        x_return_status  OUT  NOCOPY  VARCHAR2,
        x_msg_count      OUT  NOCOPY NUMBER,
        x_msg_data       OUT  NOCOPY VARCHAR2 ,
        p_party_id       IN   NUMBER,
        x_regnum_tbl     OUT  NOCOPY RegNum_tbl_type );


-- Start of comments
--      API name      : Get_LegalEntity_LGER_BSV
--      Type          : Group
--      Function      :
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_api_version       IN NUMBER     Required
--                      p_init_msg_list     IN VARCHAR2   Optional
--                                        Default = FND_API.G_FALSE
--                      p_commit            IN VARCHAR2   Optional
--                                        Default = FND_API.G_FALSE
--
--                      p_ledger_id         IN  NUMBER    Required ,
--                      p_bsv               IN  VARCHAR2       Required ,
--
--
--      OUT          :  x_return_status     OUT VARCHAR2(1)
--                      x_msg_count         OUT NUMBER
--                      x_msg_data          OUT VARCHAR2(2000)
--                      x_legal_entity_id   OUT NUMBER,
--                      x_legal_entity_name OUT VARCHAR2
--
--      Version     : Current version       1.0
--                        Changed....
--                    previous version      1.0
--                        Changed....
--
--                    Initial version       1.0
--
--      Notes            :  Requesting Team : Legal Entity
--
-- End of comments
PROCEDURE Get_LegalEntity_LGER_BSV(
      p_api_version       IN   NUMBER ,
      p_init_msg_list     IN   VARCHAR2,
      p_commit            IN   VARCHAR2,
      x_return_status     OUT  NOCOPY  VARCHAR2,
      x_msg_count         OUT  NOCOPY NUMBER,
      x_msg_data          OUT  NOCOPY VARCHAR2,
      p_ledger_id         IN   NUMBER ,
      p_bsv               IN   VARCHAR2,
      x_legal_entity_id   OUT  NOCOPY  NUMBER,
      x_legal_entity_name OUT  NOCOPY  VARCHAR2);

Procedure Get_FP_VATRegistration_LEID(
     p_api_version         IN  NUMBER,
     p_init_msg_list       IN  VARCHAR2,
     p_commit              IN  VARCHAR2,
     p_effective_date      IN  zx_registrations.effective_from%Type,
     x_return_status       OUT NOCOPY  VARCHAR2,
     x_msg_count           OUT NOCOPY NUMBER,
     x_msg_data            OUT NOCOPY VARCHAR2,
     p_legal_entity_id     IN  NUMBER,
     x_registration_number OUT NOCOPY  VARCHAR2);

 PROCEDURE Get_LE_Interface(
     x_return_status OUT NOCOPY  VARCHAR2,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data	     OUT NOCOPY VARCHAR2,
     P_INTERFACE_ATTRIBUTE    	IN  VARCHAR2,
     P_INTERFACE_VALUE		IN  VARCHAR2,
     X_LEGAL_ENTITY_ID   OUT NOCOPY XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE
);

function GET_DefaultLegalContext_OU(
      p_operating_unit        IN  NUMBER  )
      RETURN NUMBER;

function Get_DLC_LE_OU RETURN VARCHAR2;

PROCEDURE IsLegalEntity_LEID(
      	x_return_status  OUT NOCOPY  VARCHAR2,
    	x_msg_data	 OUT NOCOPY VARCHAR2,
        p_legal_entity_id IN  NUMBER,
        x_legal_entity    OUT NOCOPY VARCHAR2
  );

PROCEDURE Check_IC_Invoice_required(
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT     NOCOPY VARCHAR2,
        p_legal_entity_id   IN  NUMBER,
        p_party_id          IN  NUMBER,
        x_intercompany_inv  OUT NOCOPY VARCHAR2);

END;
 

/
