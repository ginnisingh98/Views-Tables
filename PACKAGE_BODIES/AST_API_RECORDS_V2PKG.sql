--------------------------------------------------------
--  DDL for Package Body AST_API_RECORDS_V2PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_API_RECORDS_V2PKG" AS
 /* $Header: astcuirb.pls 115.8 2003/08/27 08:04:19 sssomesw ship $ */

  -- *****************************************************
  FUNCTION INIT_HZ_PARTY_SITE_REC RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE IS
    l_return_rec HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;

  --*******************************************************
   FUNCTION INIT_HZ_PARTY_SITE_USE_REC_V2 RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE IS
         l_return_rec HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
   BEGIN
       RETURN l_return_rec;
   END;
    -- *****************************************************
  FUNCTION INIT_HZ_LOCATION_REC RETURN HZ_LOCATION_V2PUB.LOCATION_REC_TYPE IS
    l_return_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
    -- *****************************************************
 FUNCTION INIT_HZ_ADDRESS_REC RETURN AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE IS
 l_return_rec AST_API_RECORDS_V2PKG.ADDRESS_REC_TYPE;
 BEGIN
  RETURN l_return_rec;
 END INIT_HZ_ADDRESS_REC;

    -- *****************************************************

  FUNCTION INIT_HZ_PERSON_REC_V2 RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE IS
    l_return_rec HZ_PARTY_V2PUB.PERSON_REC_TYPE;
  BEGIN
    RETURN l_return_rec ;
  END;
   -- *****************************************************

	FUNCTION INIT_HZ_ORG_REC_V2 RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE IS
	  l_return_rec HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
	  BEGIN
	    RETURN l_return_rec ;
      END;

   -- *****************************************************

     FUNCTION INIT_HZ_PARTY_REC_V2 RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE IS
       l_return_rec HZ_PARTY_V2PUB.PARTY_REC_TYPE;
       BEGIN
         RETURN l_return_rec ;
      END;

   --*******************************************************

    FUNCTION INIT_HZ_CONTACT_POINTS_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE IS
        l_return_rec HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    BEGIN
       RETURN l_return_rec;
    END;

   -- ********************************************************
     FUNCTION INIT_HZ_EDI_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE IS
       l_return_rec HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE ;
    BEGIN
       RETURN l_return_rec;
    END;

   -- ********************************************************
     FUNCTION INIT_HZ_PHONE_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE IS
        l_return_rec HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
     BEGIN
       RETURN l_return_rec;
    END;

   -- ********************************************************
      FUNCTION INIT_HZ_EMAIL_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE IS
       l_return_rec  HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;

     BEGIN
       RETURN l_return_rec;
    END;
   -- ********************************************************

   FUNCTION INIT_HZ_TELEX_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE IS
     l_return_rec HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    BEGIN
       RETURN l_return_rec;
    END;

   --*********************************************************
    FUNCTION INIT_HZ_WEB_REC_V2 RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE IS
       l_return_rec HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
   BEGIN
       RETURN l_return_rec;
    END;

   --*********************************************************
  FUNCTION INIT_HZ_ORG_CONTACT_REC_V2 RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE IS
    l_return_rec HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;

   BEGIN
       RETURN l_return_rec;
    END;

   --*********************************************************

    FUNCTION INIT_HZ_ORG_CONT_ROLE_REC_V2 RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE IS
       l_return_rec HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_ROLE_REC_TYPE;
   BEGIN
       RETURN l_return_rec;
    END;

   --*********************************************************

   FUNCTION INIT_HZ_PARTY_REL_REC_TYPE_V2 RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE IS
       l_return_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
   BEGIN
       RETURN l_return_rec;
    END;


--*********************************************************

 FUNCTION INIT_CUST_ACCT_ROLE_REC_V2 RETURN HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE IS
     l_return_rec HZ_CUST_ACCOUNT_ROLE_V2PUB.CUST_ACCOUNT_ROLE_REC_TYPE;
 BEGIN
     RETURN l_return_rec;
 END;

--*********************************************************

 FUNCTION INIT_CUST_ACCT_SITE_REC_V2 RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE IS
     l_return_rec HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
 BEGIN
     RETURN l_return_rec;
 END;
--*********************************************************

 FUNCTION INIT_CUST_PROFILE_REC_V2 RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE IS
     l_return_rec HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
 BEGIN
     RETURN l_return_rec;
 END;
 --*********************************************************

 FUNCTION INIT_CUST_ACCT_RELATE_REC_V2 RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE IS
     l_return_rec HZ_CUST_ACCOUNT_V2PUB.CUST_ACCT_RELATE_REC_TYPE ;
 BEGIN
     RETURN l_return_rec;
 END;
--*********************************************************

 FUNCTION INIT_CUST_ACCOUNT_REC_V2 RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE IS
   l_return_rec  HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************

 FUNCTION INIT_HZ_LANGUAGE_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE IS
    l_return_rec HZ_PERSON_INFO_V2PUB.PERSON_LANGUAGE_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************

--*********************************************************

 FUNCTION INIT_HZ_CODE_ASSIGNMENT_REC_V2 RETURN HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE IS
    l_return_rec HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************

--*********************************************************

 FUNCTION INIT_CUST_ACCT_SITE_USE_REC_V2 RETURN HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE IS
    l_return_rec HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************

--*********************************************************

 FUNCTION INIT_HZ_CONTACT_PREFER_REC_V2 RETURN HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE IS
    l_return_rec HZ_CONTACT_PREFERENCE_V2PUB.CONTACT_PREFERENCE_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************


-- Added for 11.5.10 HZ.K Changes --
--*********************************************************

 FUNCTION INIT_HZ_EMP_HISTORY_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE  IS
    l_return_rec HZ_PERSON_INFO_V2PUB.EMPLOYMENT_HISTORY_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************
--*********************************************************

 FUNCTION INIT_HZ_INTEREST_REC_V2 RETURN HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE IS
    l_return_rec HZ_PERSON_INFO_V2PUB.PERSON_INTEREST_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************
--*********************************************************

 FUNCTION INIT_HZ_EDUCATION_REC_V2 RETURN  HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE  IS
    l_return_rec  HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
 BEGIN
    RETURN l_return_rec;
 END;

--*********************************************************
END AST_API_RECORDS_V2PKG;

/
