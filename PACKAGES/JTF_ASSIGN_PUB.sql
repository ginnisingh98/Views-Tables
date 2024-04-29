--------------------------------------------------------
--  DDL for Package JTF_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ASSIGN_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfamprs.pls 120.3.12010000.3 2009/04/24 19:34:44 vakulkar ship $ */



-- *******************************************************************************

-- Start of comments

--      Functions       : These functions are to get the FND_API
--                        default values.

-- End of comments

-- *******************************************************************************


  FUNCTION am_miss_num         RETURN NUMBER;

  FUNCTION am_miss_char        RETURN VARCHAR2;

  FUNCTION am_miss_date        RETURN DATE;

  FUNCTION am_false            RETURN VARCHAR2;

  FUNCTION am_true             RETURN VARCHAR2;

  FUNCTION am_valid_level_full RETURN VARCHAR2;

  FUNCTION resource_type_change(p_res_type VARCHAR2) RETURN VARCHAR2;



-- ********************************************************************************

-- Start of Comments

--     	Package Name	: JTF_ASSIGN_PUB
--	Purpose		: Joint Task Force Core Foundation Assignment Manager
--                        Public APIs. This package is for finding the
--                        a resource based on the customer preferences
--                        or territory preferences and the availability of
--                        the resource in the specified time frame.
--	Procedures	: (See below for specification)
--	Notes		: This package is publicly available for use
--	History		: 11/02/99 ** VVUYYURU ** Vijay Vuyyuru ** created
--

-- End of Comments

-- *******************************************************************************
-- This record type and global variable will be used for Complex Work Assignments.
-- This will be used to populate the multiple available slots for a resource
-- The unique keys will be resource_id, resource_type, start_date and end_date
  TYPE Resource_avail_type      IS RECORD
    (
      RESOURCE_ID                    NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      RESOURCE_TYPE                  VARCHAR2(30) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      START_DATE                     DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      END_DATE                       DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      SHIFT_CONSTRUCT_ID             NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM);

  TYPE Avail_tbl_type                IS TABLE OF Resource_avail_type
                                     INDEX BY BINARY_INTEGER;

  g_resource_avail                   Avail_tbl_type;

  -- Defining this function (repuri 02/04) for 'Complex Work Assignment' Enhancement
  -- To access the above global variable 'g_resource_avail' in Forms.

  --FUNCTION get_g_resource_avail RETURN Avail_tbl_type;

  TYPE AssignResources_rec_type      IS RECORD
    (
      TERR_RSC_ID                    NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      RESOURCE_ID                    NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      RESOURCE_TYPE                  VARCHAR2(30) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      ROLE                           VARCHAR2(30) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      START_DATE                     DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      END_DATE                       DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      SHIFT_CONSTRUCT_ID             NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      TERR_ID                        NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      TERR_NAME                      VARCHAR2(240):= JTF_ASSIGN_PUB.AM_MISS_CHAR,
      TERR_RANK                      NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      TRAVEL_TIME                    NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      TRAVEL_UOM                     VARCHAR2(10) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      PREFERENCE_TYPE                VARCHAR2(05) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      PRIMARY_CONTACT_FLAG           VARCHAR2(01) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      FULL_ACCESS_FLAG               VARCHAR2(01) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      GROUP_ID                       NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      LOCATION                       VARCHAR2(60) := JTF_ASSIGN_PUB.AM_MISS_CHAR,
      TRANS_OBJECT_ID                NUMBER       := JTF_ASSIGN_PUB.AM_MISS_NUM,
      RESOURCE_SOURCE                VARCHAR2(30) := NULL,
      SOURCE_START_DATE		     DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      SOURCE_END_DATE		     DATE         := JTF_ASSIGN_PUB.AM_MISS_DATE,
      SUPPORT_SITE_ID                NUMBER       := NULL,
      SUPPORT_SITE_NAME              VARCHAR2(150):= NULL,
      WEB_AVAILABILITY_FLAG          VARCHAR2(01) := NULL,
      SKILL_LEVEL                    NUMBER       := NULL,
      SKILL_NAME                     VARCHAR2(60) := NULL,
      PRIMARY_FLAG                   VARCHAR2(10) := NULL
  );

  TYPE AssignResources_tbl_type      IS TABLE OF AssignResources_rec_type
                                     INDEX BY BINARY_INTEGER;



  TYPE JTF_Serv_Req_rec_type         IS RECORD
    (
      SERVICE_REQUEST_ID             NUMBER,
      PARTY_ID                       NUMBER,
      COUNTRY                        VARCHAR2(60),
      PARTY_SITE_ID                  NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      AREA_CODE                      VARCHAR2(10),
      COUNTY                         VARCHAR2(60),
      COMP_NAME_RANGE                VARCHAR2(360),
      PROVINCE                       VARCHAR2(60),
      NUM_OF_EMPLOYEES               NUMBER,
      INCIDENT_TYPE_ID               NUMBER,
      INCIDENT_SEVERITY_ID           NUMBER,
      INCIDENT_URGENCY_ID            NUMBER,
      PROBLEM_CODE                   VARCHAR2(60),
      INCIDENT_STATUS_ID             NUMBER,
      PLATFORM_ID                    NUMBER,
      SUPPORT_SITE_ID                NUMBER,
      CUSTOMER_SITE_ID               NUMBER,
      SR_CREATION_CHANNEL            VARCHAR2(150),
      INVENTORY_ITEM_ID              NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORGANIZATION_ID                NUMBER,
      SQUAL_NUM12                    NUMBER, --INVENTORY ITEM ID / SR PLATFORM
      SQUAL_NUM13                    NUMBER, --ORGANIZATION ID   / SR PLATFORM
      SQUAL_NUM14                    NUMBER, --CATEGORY ID       / SR PRODUCT
      SQUAL_NUM15                    NUMBER, --INVENTORY ITEM ID / SR PRODUCT
      SQUAL_NUM16                    NUMBER, --ORGANIZATION ID   / SR PRODUCT
      SQUAL_NUM17                    NUMBER, --SR GROUP OWNER
      SQUAL_NUM18                    NUMBER, --INVENTORY ITEM ID / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM19                    NUMBER, --ORGANIZATION ID   / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM30                    NUMBER, --SR LANGUAGE ... should use squal_char20 instead
      SQUAL_CHAR11                   VARCHAR2(360), --VIP CUSTOMERS
      SQUAL_CHAR12                   VARCHAR2(360), --SR PROBLEM CODE
      SQUAL_CHAR13                   VARCHAR2(360),  --SR CUSTOMER CONTACT PREFERENCE
      SQUAL_CHAR20                   VARCHAR2(360),  --SR LANGUAGE ID for TERR REQ
      SQUAL_CHAR21                   VARCHAR2(360),   --SR Service Contract Coverage
      DAY_OF_WEEK                    VARCHAR2(360) ,
      TIME_OF_DAY                    VARCHAR2(360) ,
      ITEM_COMPONENT                 NUMBER,        -- Added by SBARAT on 10/01/2005 for Enh 4112155
      ITEM_SUBCOMPONENT              NUMBER         -- Added by SBARAT on 10/01/2005 for Enh 4112155
    );

  pkg_sr_rec JTF_Serv_Req_rec_type;



  TYPE JTF_Srv_Task_rec_type         IS RECORD
    (
      TASK_ID                        NUMBER,
      SERVICE_REQUEST_ID             NUMBER,
      PARTY_ID                       NUMBER,
      COUNTRY                        VARCHAR2(60),
      PARTY_SITE_ID                  NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      AREA_CODE                      VARCHAR2(10),
      COUNTY                         VARCHAR2(60),
      COMP_NAME_RANGE                VARCHAR2(360),
      PROVINCE                       VARCHAR2(60),
      NUM_OF_EMPLOYEES               NUMBER,
      TASK_TYPE_ID                   NUMBER,
      TASK_STATUS_ID                 NUMBER,
      TASK_PRIORITY_ID               NUMBER,
      INCIDENT_TYPE_ID               NUMBER,
      INCIDENT_SEVERITY_ID           NUMBER,
      INCIDENT_URGENCY_ID            NUMBER,
      PROBLEM_CODE                   VARCHAR2(60),
      INCIDENT_STATUS_ID             NUMBER,
      PLATFORM_ID                    NUMBER,
      SUPPORT_SITE_ID                NUMBER,
      CUSTOMER_SITE_ID               NUMBER,
      SR_CREATION_CHANNEL            VARCHAR2(150),
      INVENTORY_ITEM_ID              NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORGANIZATION_ID                NUMBER,
      SQUAL_NUM12                    NUMBER, --INVENTORY ITEM ID / SR PLATFORM
      SQUAL_NUM13                    NUMBER, --ORGANIZATION ID   / SR PLATFORM
      SQUAL_NUM14                    NUMBER, --CATEGORY ID       / SR PRODUCT
      SQUAL_NUM15                    NUMBER, --INVENTORY ITEM ID / SR PRODUCT
      SQUAL_NUM16                    NUMBER, --ORGANIZATION ID   / SR PRODUCT
      SQUAL_NUM17                    NUMBER, --SR GROUP OWNER
      SQUAL_NUM18                    NUMBER, --INVENTORY ITEM ID / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM19                    NUMBER, --ORGANIZATION ID   / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM30                    NUMBER, --SR LANGUAGE ... should use squal_char20 instead
      SQUAL_CHAR11                   VARCHAR2(360), --VIP CUSTOMERS
      SQUAL_CHAR12                   VARCHAR2(360), --SR PROBLEM CODE
      SQUAL_CHAR13                   VARCHAR2(360), --SR CUSTOMER CONTACT PREFERENCE
      SQUAL_CHAR20                   VARCHAR2(360),  --SR LANGUAGE ID for TERR REQ
      SQUAL_CHAR21                   VARCHAR2(360),   --SR Service Contract Coverage
      DAY_OF_WEEK                    VARCHAR2(360) ,
      TIME_OF_DAY                    VARCHAR2(360) ,
      ITEM_COMPONENT                 NUMBER,        -- Added by SBARAT on 10/01/2005 for Enh 4112155
      ITEM_SUBCOMPONENT              NUMBER         -- Added by SBARAT on 10/01/2005 for Enh 4112155
    );

  pkg_sr_task_rec JTF_Srv_Task_rec_type;

 /********** Added by SBARAT on 01/11/2004 for Enh-3919046 *********/

  TYPE JTF_DR_rec_type         IS RECORD
    (
      TASK_ID                        NUMBER,
      SERVICE_REQUEST_ID             NUMBER,
      PARTY_ID                       NUMBER,
      COUNTRY                        VARCHAR2(60),
      PARTY_SITE_ID                  NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      AREA_CODE                      VARCHAR2(10),
      COUNTY                         VARCHAR2(60),
      COMP_NAME_RANGE                VARCHAR2(360),
      PROVINCE                       VARCHAR2(60),
      NUM_OF_EMPLOYEES               NUMBER,
      TASK_TYPE_ID                   NUMBER,
      TASK_STATUS_ID                 NUMBER,
      TASK_PRIORITY_ID               NUMBER,
      INCIDENT_TYPE_ID               NUMBER,
      INCIDENT_SEVERITY_ID           NUMBER,
      INCIDENT_URGENCY_ID            NUMBER,
      PROBLEM_CODE                   VARCHAR2(60),
      INCIDENT_STATUS_ID             NUMBER,
      PLATFORM_ID                    NUMBER,
      SUPPORT_SITE_ID                NUMBER,
      CUSTOMER_SITE_ID               NUMBER,
      SR_CREATION_CHANNEL            VARCHAR2(150),
      INVENTORY_ITEM_ID              NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORGANIZATION_ID                NUMBER,
      SQUAL_NUM12                    NUMBER, --INVENTORY ITEM ID / SR PLATFORM
      SQUAL_NUM13                    NUMBER, --ORGANIZATION ID   / SR PLATFORM
      SQUAL_NUM14                    NUMBER, --CATEGORY ID       / SR PRODUCT
      SQUAL_NUM15                    NUMBER, --INVENTORY ITEM ID / SR PRODUCT
      SQUAL_NUM16                    NUMBER, --ORGANIZATION ID   / SR PRODUCT
      SQUAL_NUM17                    NUMBER, --DR GROUP OWNER
      SQUAL_NUM18                    NUMBER, --INVENTORY ITEM ID / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM19                    NUMBER, --ORGANIZATION ID   / CONTRACT SUPPORT SERVICE ITEM
      SQUAL_NUM30                    NUMBER, --DR LANGUAGE ... should use squal_char20 instead
      SQUAL_CHAR11                   VARCHAR2(360), --VIP CUSTOMERS
      SQUAL_CHAR12                   VARCHAR2(360), --DR PROBLEM CODE
      SQUAL_CHAR13                   VARCHAR2(360), --DR CUSTOMER CONTACT PREFERENCE
      SQUAL_CHAR20                   VARCHAR2(360),  --DR LANGUAGE ID for TERR REQ
      SQUAL_CHAR21                   VARCHAR2(360)   --DR Service Contract Coverage
    );

   pkg_dr_rec JTF_DR_rec_type;

  /********* End of addition by SBARAT on 01/11/2004 for Enh-3919046 *********/


  /*
  TYPE JTF_Def_Mgmt_rec_type         IS RECORD
    (
      DEFECT_ID                      NUMBER,
      PARTY_ID                       NUMBER,
      COUNTRY                        VARCHAR2(60),
      PARTY_SITE_ID                  NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      AREA_CODE                      VARCHAR2(10),
      COUNTY                         VARCHAR2(60),
      COMP_NAME_RANGE                VARCHAR2(360),
      PROVINCE                       VARCHAR2(60),
      NUM_OF_EMPLOYEES               NUMBER,
      PROBLEM_TYPE_ID                NUMBER,
      PHASE_ID                       NUMBER,
      SEVERITY_ID                    NUMBER,
      PRIORITY_ID                    NUMBER,
      TIER_CODE                      VARCHAR2(30),
      UI_DEFECT_FLAG                 VARCHAR2(1),
      FUNC_DEFECT_FLAG               VARCHAR2(1),
      PLATFORM_SPECIFIC_FLAG         VARCHAR2(1),
      ERROR_CODE_ID                  NUMBER,
      LANGUAGE_CODE_ID               NUMBER,
      PLATFORM_ID                    NUMBER,
      PRODUCT_ID                     NUMBER,
      COMPONENT_ID                   NUMBER,
      SUB_COMPONENT_ID               NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150)
    );
  */


  TYPE JTF_DEF_MGMT_rec_type         IS RECORD
    (
      SQUAL_CHAR01                   VARCHAR2(360),
      SQUAL_CHAR02                   VARCHAR2(360),
      SQUAL_CHAR03                   VARCHAR2(360),
      SQUAL_CHAR04                   VARCHAR2(360),
      SQUAL_CHAR05                   VARCHAR2(360),
      SQUAL_CHAR06                   VARCHAR2(360),
      SQUAL_CHAR07                   VARCHAR2(360),
      SQUAL_CHAR08                   VARCHAR2(360),
      SQUAL_CHAR09                   VARCHAR2(360),
      SQUAL_CHAR10                   VARCHAR2(360),
      SQUAL_CHAR11                   VARCHAR2(360),
      SQUAL_CHAR12                   VARCHAR2(360),
      SQUAL_CHAR13                   VARCHAR2(360),
      SQUAL_CHAR14                   VARCHAR2(360),
      SQUAL_CHAR15                   VARCHAR2(360),
      SQUAL_CHAR16                   VARCHAR2(360),
      SQUAL_CHAR17                   VARCHAR2(360),
      SQUAL_CHAR18                   VARCHAR2(360),
      SQUAL_CHAR19                   VARCHAR2(360),
      SQUAL_CHAR20                   VARCHAR2(360),
      SQUAL_CHAR21                   VARCHAR2(360),
      SQUAL_CHAR22                   VARCHAR2(360),
      SQUAL_CHAR23                   VARCHAR2(360),
      SQUAL_CHAR24                   VARCHAR2(360),
      SQUAL_CHAR25                   VARCHAR2(360),
      SQUAL_NUM01                    NUMBER,
      SQUAL_NUM02                    NUMBER,
      SQUAL_NUM03                    NUMBER,
      SQUAL_NUM04                    NUMBER,
      SQUAL_NUM05                    NUMBER,
      SQUAL_NUM06                    NUMBER,
      SQUAL_NUM07                    NUMBER,
      SQUAL_NUM08                    NUMBER,
      SQUAL_NUM09                    NUMBER,
      SQUAL_NUM10                    NUMBER,
      SQUAL_NUM11                    NUMBER,
      SQUAL_NUM12                    NUMBER,
      SQUAL_NUM13                    NUMBER,
      SQUAL_NUM14                    NUMBER,
      SQUAL_NUM15                    NUMBER,
      SQUAL_NUM16                    NUMBER,
      SQUAL_NUM17                    NUMBER,
      SQUAL_NUM18                    NUMBER,
      SQUAL_NUM19                    NUMBER,
      SQUAL_NUM20                    NUMBER,
      SQUAL_NUM21                    NUMBER,
      SQUAL_NUM22                    NUMBER,
      SQUAL_NUM23                    NUMBER,
      SQUAL_NUM24                    NUMBER,
      SQUAL_NUM25                    NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150)
    );

  pkg_defect_rec JTF_Def_Mgmt_rec_type;



  TYPE JTF_Oppor_rec_type            IS RECORD
    (
      LEAD_ID                        NUMBER,
      LEAD_LINE_ID                   NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      PROVINCE                       VARCHAR2(60),
      COUNTY                         VARCHAR2(60),
      COUNTRY                        VARCHAR2(60),
      INTEREST_TYPE_ID               NUMBER,
      PRIMARY_INTEREST_ID            NUMBER,
      SECONDARY_INTEREST_ID          NUMBER,
      CONTACT_INTEREST_TYPE_ID       NUMBER,
      CONTACT_PRIMARY_INTEREST_ID    NUMBER,
      CONTACT_SECONDARY_INTEREST_ID  NUMBER,
      PARTY_SITE_ID                  NUMBER,
      AREA_CODE                      VARCHAR2(10),
      PARTY_ID                       NUMBER,
      COMP_NAME_RANGE                VARCHAR2(360),
      PARTNER_ID                     NUMBER,
      NUM_OF_EMPLOYEES               NUMBER,
      CATEGORY_CODE                  VARCHAR2(30),
      PARTY_RELATIONSHIP_ID          NUMBER,
      SIC_CODE                       VARCHAR2(60),
      TARGET_SEGMENT_CURRENT         VARCHAR2(25),
      TOTAL_AMOUNT                   NUMBER,
      CURRENCY_CODE                  VARCHAR2(15),
      PRICING_DATE                   DATE,
      CHANNEL_CODE                   VARCHAR2(25),
      INVENTORY_ITEM_ID              NUMBER,
      OPP_INTEREST_TYPE_ID           NUMBER,
      OPP_PRIMARY_INTEREST_ID        NUMBER,
      OPP_SECONDARY_INTEREST_ID      NUMBER,
      OPCLSS_INTEREST_TYPE_ID        NUMBER,
      OPCLSS_PRIMARY_INTEREST_ID     NUMBER,
      OPCLSS_SECONDARY_INTEREST_ID   NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORG_ID                         NUMBER
    );



  TYPE JTF_Lead_rec_type             IS RECORD
    (
      SALES_LEAD_ID                  NUMBER,
      SALES_LEAD_LINE_ID             NUMBER,
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      PROVINCE                       VARCHAR2(60),
      COUNTY                         VARCHAR2(60),
      COUNTRY                        VARCHAR2(60),
      INTEREST_TYPE_ID               NUMBER,
      PRIMARY_INTEREST_ID            NUMBER,
      SECONDARY_INTEREST_ID          NUMBER,
      CONTACT_INTEREST_TYPE_ID       NUMBER,
      CONTACT_PRIMARY_INTEREST_ID    NUMBER,
      CONTACT_SECONDARY_INTEREST_ID  NUMBER,
      PARTY_SITE_ID                  NUMBER,
      AREA_CODE                      VARCHAR2(10),
      PARTY_ID                       NUMBER,
      COMP_NAME_RANGE                VARCHAR2(360),
      PARTNER_ID                     NUMBER,
      NUM_OF_EMPLOYEES               NUMBER,
      CATEGORY_CODE                  VARCHAR2(30),
      PARTY_RELATIONSHIP_ID          NUMBER,
      SIC_CODE                       VARCHAR2(60),
      BUDGET_AMOUNT                  NUMBER,
      CURRENCY_CODE                  VARCHAR2(15),
      PRICING_DATE                   DATE,
      SOURCE_PROMOTION_ID            NUMBER,
      INVENTORY_ITEM_ID              NUMBER,
      LEAD_INTEREST_TYPE_ID          NUMBER,
      LEAD_PRIMARY_INTEREST_ID       NUMBER,
      LEAD_SECONDARY_INTEREST_ID     NUMBER,
      PURCHASE_AMOUNT                NUMBER,
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORG_ID                         NUMBER
    );



  TYPE JTF_Account_rec_type          IS RECORD
    (
      CITY                           VARCHAR2(60),
      POSTAL_CODE                    VARCHAR2(60),
      STATE                          VARCHAR2(60),
      PROVINCE                       VARCHAR2(60),
      COUNTY                         VARCHAR2(60),
      COUNTRY                        VARCHAR2(60),
      INTEREST_TYPE_ID               NUMBER,
      PRIMARY_INTEREST_ID            NUMBER,
      SECONDARY_INTEREST_ID          NUMBER,
      CONTACT_INTEREST_TYPE_ID       NUMBER,
      CONTACT_PRIMARY_INTEREST_ID    NUMBER,
      CONTACT_SECONDARY_INTEREST_ID  NUMBER,
      PARTY_SITE_ID                  NUMBER,
      AREA_CODE                      VARCHAR2(10),
      PARTY_ID                       NUMBER,
      COMP_NAME_RANGE                VARCHAR2(360),
      PARTNER_ID                     NUMBER,
      NUM_OF_EMPLOYEES               NUMBER,
      CATEGORY_CODE                  VARCHAR2(30),
      PARTY_RELATIONSHIP_ID          NUMBER,
      SIC_CODE                       VARCHAR2(60),
      ATTRIBUTE1                     VARCHAR2(150),
      ATTRIBUTE2                     VARCHAR2(150),
      ATTRIBUTE3                     VARCHAR2(150),
      ATTRIBUTE4                     VARCHAR2(150),
      ATTRIBUTE5                     VARCHAR2(150),
      ATTRIBUTE6                     VARCHAR2(150),
      ATTRIBUTE7                     VARCHAR2(150),
      ATTRIBUTE8                     VARCHAR2(150),
      ATTRIBUTE9                     VARCHAR2(150),
      ATTRIBUTE10                    VARCHAR2(150),
      ATTRIBUTE11                    VARCHAR2(150),
      ATTRIBUTE12                    VARCHAR2(150),
      ATTRIBUTE13                    VARCHAR2(150),
      ATTRIBUTE14                    VARCHAR2(150),
      ATTRIBUTE15                    VARCHAR2(150),
      ORG_ID                         NUMBER
    );



  TYPE Prfeng_rec_type IS RECORD
    (
      ENGINEER_ID                    NUMBER        := NULL,
      RESOURCE_TYPE                  VARCHAR2(30)  := NULL,
      PRIMARY_FLAG                   VARCHAR2(30)  := NULL,
      PREFERRED_FLAG                 VARCHAR2(30)  := NULL,
      RESOURCE_CLASS                 VARCHAR2(30)  := NULL
    );

  TYPE Prfeng_tbl_type               IS TABLE OF Prfeng_rec_type
                                     INDEX BY BINARY_INTEGER;


  TYPE Preferred_Engineers_rec_type  IS RECORD
    (
      ENGINEER_ID                    NUMBER        := NULL,
      RESOURCE_TYPE                  VARCHAR2(30)  := NULL,
      PREFERENCE_TYPE                VARCHAR2(5)   := NULL,
      PRIMARY_FLAG                   VARCHAR2(30)  := NULL
    );

  TYPE Preferred_Engineers_tbl_type  IS TABLE OF Preferred_Engineers_rec_type
                                     INDEX BY BINARY_INTEGER;


  TYPE Escalations_rec_type IS RECORD
    (
      SOURCE_OBJECT_ID               NUMBER        := JTF_ASSIGN_PUB.AM_MISS_NUM,
      SOURCE_OBJECT_TYPE             VARCHAR2(30)  := JTF_ASSIGN_PUB.AM_MISS_CHAR
    );

  TYPE Escalations_tbl_type          IS TABLE OF Escalations_rec_type
                                     INDEX BY BINARY_INTEGER;


  -- created a new record typr for use of Exckuded Resources
  TYPE excluded_rec_type IS RECORD
    (
      RESOURCE_ID                    NUMBER        := NULL,
      RESOURCE_TYPE                  VARCHAR2(30)  := NULL
    );

  TYPE excluded_tbl_type               IS TABLE OF excluded_rec_type
                                       INDEX BY BINARY_INTEGER;


   -- global parameter for workflow
   g_assign_resources_tbl                JTF_ASSIGN_PUB.AssignResources_tbl_type;

   -- global record type for component/subcomponent issue
   -- to overcome build dependancy on Territory manager
   -- for newly added two fields in territory record types
   -- squal_num23, squal_num24
   -- Added by SBARAT on 10/01/2004 for Enh 4112155

   G_Terr_Serv_Req_Rec_Type              JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type;
   G_Terr_Srv_Task_Rec_Type              JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type;



-- *******************************************************************************

-- Start of comments

--	API name 	: GET_ASSIGN_RESOURCES
--	Type		: Public
--	Function	: Determine the resources based on the customer
--                        preferences or territory preferences and the
--                        availability.
--	Pre-reqs	: None

--	Parameters	:

--	IN		: p_api_version   	IN 	NUMBER	Required
--			  p_init_msg_list 	IN 	VARCHAR2 Optional
--					      	DEFAULT JTF_ASSIGN_PUB.AM_FALSE
--                        p_commit              IN      VARCHAR2 optional
--					      	DEFAULT JTF_ASSIGN_PUB.AM_FALSE

--     Assignment Manager Specific Parameters

--     This determines the Resource, Resource Type
--     and Resource Role required by the calling document
--     p_resource_id                            NUMBER
--     p_resource_type                          VARCHAR2(30)
--     p_role                                   VARCHAR2(30)

--     This determines the number of resources required
--     by the calling document
--     Defaulted to 1
--     p_no_of_resources                        NUMBER,

--     This is for sending out the qualified resource directly
--     to the calling form.
--     Defaulted to 'Y'(Profile Value)
--     p_auto_select_flag                       VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of CONTRACTS PREFERRED ENGINEERS
--     Defaulted to 'N'(Profile Value)
--     p_contracts_preferred_engineer           VARCHAR2(1)
--                                              : value of  Y or N

--     This is to set the preference of INSTALL BASE PREFERRED ENGINEERS
--     Defaulted to 'N'(Profile Value)
--     p_ib_preferred_engineer                  VARCHAR2(1)
--                                              : value of  Y or N

--     This is to fetch the CONTRACTS PREFERRED ENGINEERS
--     p_contract_id                            NUMBER

--     This is to fetch the INSTALL BASE PREFERRED ENGINEERS
--     p_customer_product_id                    NUMBER

--     The Effort required is determined by these two parameters
--     p_effort_duration                        NUMBER
--     p_effort_uom                             VARCHAR2(10)

--     The Dates in which the resource is required, is determined
--     by these two parameters
--     p_start_date                             DATE
--     p_end_date                               DATE


--     The Territory Manager is accessed based on the value set
--     Defaulted to Y
--     p_territory_flag                         VARCHAR2(1)
--                                              : value of  Y or N

--     The Resource Availability is checked based on the value set
--     Defaulted to Y
--     p_calendar_flag                          VARCHAR2(1)
--                                              : value of  Y or N

--     This parameter contains the Calling Document ID
--     which could be a TASK_ID etc.
--     p_calling_doc_id                         NUMBER
--     REQUIRED for TASKS

--     This parameter contains the Calling Document Type
--     which could be :
--        'TASK' when the calling doc is TASK
--     or 'SR'   when the calling doc is SERVICE REQUEST
--     or 'OPPR' when the calling doc is OPPORTUNITIES
--     or 'DEF'  when the calling doc is DEFECT MANAGEMENT
--     It is mandatory to enter a value for this parameter
--     to find proper qualified resources
--     p_calling_doc_type                       VARCHAR2

--     This parameter contains list of qualifier columns from the
--     UI which have been selected to re-query the resources.
--     Strictly for the use of User Interface of Assignment Manager.
--     p_column_list                             VARCHAR2

--     These parameters contain the Qualifier Values for
--     the Calling Document
--     p_sr_rec                                  JTF_ASSIGN_PUB.
--                                               JTF_Serv_Req_rec_type
--     p_sr_task_rec                             JTF_ASSIGN_PUB.
--                                               JTF_Srv_Task_rec_type
--     p_defect_rec                              JTF_ASSIGN_PUB.
--                                               JTF_Def_Mgmt_rec_type

--     OUT              : x_return_status        OUT     VARCHAR2(1)
--			  x_msg_count            OUT     NUMBER
--			  x_msg_data             OUT     VARCHAR2(2000)
--                        x_assign_resources_tbl OUT     JTF_ASSIGN_PUB.
--                                                       AssignResources_tbl_type


--     Version          : Current version        1.0
--                        Initial version        1.0
--
--     Notes            :
--

-- End of comments

-- *********************************************************************************


      /*  Package variables */

      G_PKG_NAME   CONSTANT VARCHAR2(30):= 'JTF_ASSIGN_PUB';


--    Main Procedure definition with the parameters
--    This procedure in turn calls the relevant procedure to
--    process the requests for assignment of resources


  PROCEDURE GET_ASSIGN_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_commit                              IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_resource_id                         IN  NUMBER   DEFAULT NULL,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_contracts_preferred_engineer        IN  VARCHAR2 DEFAULT NULL,
        p_ib_preferred_engineer               IN  VARCHAR2 DEFAULT NULL,
        p_contract_id                         IN  NUMBER   DEFAULT NULL,
        p_customer_product_id                 IN  NUMBER   DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL,
        --p_breakdown_uom                       IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_web_availability_flag               IN  VARCHAR2 DEFAULT NULL,
        p_category_id                         IN  NUMBER   DEFAULT NULL,
        p_inventory_item_id                   IN  NUMBER   DEFAULT NULL,
        p_inventory_org_id                    IN  NUMBER   DEFAULT NULL,
	p_problem_code                        IN  VARCHAR2 DEFAULT NULL,
        p_calling_doc_id                      IN  NUMBER,
        p_calling_doc_type                    IN  VARCHAR2,
        p_column_list                         IN  VARCHAR2 DEFAULT NULL,
        p_sr_rec                              IN  JTF_ASSIGN_PUB.JTF_Serv_Req_rec_type DEFAULT pkg_sr_rec,
        p_sr_task_rec                         IN  JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type DEFAULT pkg_sr_task_rec,
        p_defect_rec                          IN  JTF_ASSIGN_PUB.JTF_Def_Mgmt_rec_type DEFAULT pkg_defect_rec,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        p_filter_excluded_resource            IN  VARCHAR2 DEFAULT 'N',
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5386560
	p_inventory_component_id              IN  NUMBER   DEFAULT NULL,
	--Added for Bug # 5386560 Ends here
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    );





--      Procedure definition with the parameters when the
--      Source Document is TASK

  PROCEDURE GET_ASSIGN_TASK_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_contracts_preferred_engineer        IN  VARCHAR2,
        p_ib_preferred_engineer               IN  VARCHAR2,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_web_availability_flag               IN  VARCHAR2,
        p_task_id                             IN  JTF_TASKS_VL.TASK_ID%TYPE,
        p_column_list                         IN  VARCHAR2,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        p_filter_excluded_resource            IN  VARCHAR2 DEFAULT 'N',
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    );




--      Procedure definition with the parameters when the
--      Source Document is SERVICE REQUEST

  PROCEDURE GET_ASSIGN_SR_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_contracts_preferred_engineer        IN  VARCHAR2,
        p_ib_preferred_engineer               IN  VARCHAR2,
        p_contract_id                         IN  NUMBER,
        p_customer_product_id                 IN  NUMBER,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_web_availability_flag               IN  VARCHAR2,
        p_category_id                         IN  NUMBER,
        p_inventory_item_id                   IN  NUMBER,
        p_inventory_org_id                    IN  NUMBER,
	p_problem_code                        IN  VARCHAR2,
        p_sr_id                               IN  NUMBER,
        p_sr_rec                              IN  JTF_TERRITORY_PUB.JTF_Serv_Req_rec_type,
        p_sr_task_rec                         IN  JTF_TERRITORY_PUB.JTF_Srv_Task_rec_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        p_filter_excluded_resource            IN  VARCHAR2 DEFAULT 'N',
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5386560
	p_inventory_component_id              IN  NUMBER   DEFAULT NULL,
        --Added for Bug # 5386560 Ends here
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    );


  /************ Added by SBARAT on 01/11/2004 for Enh-3919046 **********/

--      Procedure definition with the parameters when the
--      Source Document is DEPOT REPAIR

  PROCEDURE GET_ASSIGN_DR_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 ,
        p_resource_type                       IN  VARCHAR2 ,
        p_role                                IN  VARCHAR2 ,
        p_no_of_resources                     IN  NUMBER   ,
        p_auto_select_flag                    IN  VARCHAR2 ,
        p_contracts_preferred_engineer        IN  VARCHAR2 ,
        p_ib_preferred_engineer               IN  VARCHAR2 ,
        p_contract_id                         IN  NUMBER   ,
        p_customer_product_id                 IN  NUMBER   ,
        p_effort_duration                     IN  NUMBER   ,
        p_effort_uom                          IN  VARCHAR2 ,
        p_start_date                          IN  DATE     ,
        p_end_date                            IN  DATE     ,
        p_territory_flag                      IN  VARCHAR2 ,
        p_calendar_flag                       IN  VARCHAR2 ,
        p_web_availability_flag               IN  VARCHAR2 ,
        p_category_id                         IN  NUMBER   ,
        p_inventory_item_id                   IN  NUMBER   ,
        p_inventory_org_id                    IN  NUMBER   ,
        p_problem_code                        IN  VARCHAR2 ,
        p_dr_id                               IN  NUMBER,
        p_column_list                         IN  VARCHAR2 ,
        p_dr_rec                              IN  JTF_ASSIGN_PUB.JTF_DR_rec_type ,
        p_business_process_id                 IN  NUMBER,
        p_business_process_date               IN  DATE,
        p_filter_excluded_resource            IN  VARCHAR2,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2,
	--Added for Bug # 5573916
	p_calendar_check                IN  VARCHAR2 DEFAULT 'Y'
	--Added for Bug # 5573916 Ends here
    );

  /*********** End of addition by SBARAT on 01/11/2004 for Enh-3919046 *********/


--      Procedure definition with the parameters when the
--      Source Document is OPPORTUNITIES

  PROCEDURE GET_ASSIGN_OPPR_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.am_false,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_opportunity_rec                     IN  JTF_ASSIGN_PUB.JTF_Oppor_rec_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE     DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );



--      Procedure definition with the parameters when the
--      Source Document is LEADS  (For BULK Record)

  PROCEDURE GET_ASSIGN_LEAD_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.am_false,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_lead_rec                            IN  JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type,
        --x_assign_resources_bulk_rec         OUT NOCOPY JTF_TERRITORY_PUB.WINNING_BULK_REC_TYPE,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );



--      Procedure definition with the parameters when the
--      Source Document is LEADS (For SINGLE Record)

  PROCEDURE GET_ASSIGN_LEAD_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.am_false,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_lead_rec                            IN  JTF_ASSIGN_PUB.JTF_Lead_rec_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );



--      Procedure definition with the parameters when the
--      Source Document is ACCOUNTS


  PROCEDURE GET_ASSIGN_ACCOUNT_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.am_false,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_account_rec                         IN  JTF_ASSIGN_PUB.JTF_Account_rec_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );



--      Procedure definition with the parameters when the
--      Source Document is DEFECT MANAGEMENT SYSTEM

  PROCEDURE GET_ASSIGN_DEFECT_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2,
        p_resource_type                       IN  VARCHAR2,
        p_role                                IN  VARCHAR2,
        p_no_of_resources                     IN  NUMBER,
        p_auto_select_flag                    IN  VARCHAR2,
        p_effort_duration                     IN  NUMBER,
        p_effort_uom                          IN  VARCHAR2,
        p_start_date                          IN  DATE,
        p_end_date                            IN  DATE,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2,
        p_calendar_flag                       IN  VARCHAR2,
        p_defect_rec                          IN  JTF_TERRITORY_PUB.JTF_Def_Mgmt_rec_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );



--      Procedure definition with the parameters when the
--      Source Document is ESCALATIONS

  PROCEDURE GET_ASSIGN_ESC_RESOURCES
    (
        p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_resource_type                       IN  VARCHAR2 DEFAULT NULL,
        p_role                                IN  VARCHAR2 DEFAULT NULL,
        p_no_of_resources                     IN  NUMBER   DEFAULT 1,
        p_auto_select_flag                    IN  VARCHAR2 DEFAULT NULL,
        p_effort_duration                     IN  NUMBER   DEFAULT NULL,
        p_effort_uom                          IN  VARCHAR2 DEFAULT NULL,
        p_start_date                          IN  DATE     DEFAULT NULL,
        p_end_date                            IN  DATE     DEFAULT NULL,
        --p_breakdown                           IN  NUMBER   DEFAULT NULL ,
        --p_breakdown_uom                       IN  VARCHAR2  DEFAULT NULL,
        p_territory_flag                      IN  VARCHAR2 DEFAULT 'Y',
        p_calendar_flag                       IN  VARCHAR2 DEFAULT 'Y',
        p_web_availability_flag               IN  VARCHAR2 DEFAULT NULL,
        p_esc_tbl                             IN  JTF_ASSIGN_PUB.Escalations_tbl_type,
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_assign_resources_tbl                OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );


 -- this is a procedure added on 2nd July 2002 to get the Excluded Resources for the AM UI
 -- when working in assisted Mode
  PROCEDURE GET_EXCLUDED_RESOURCES
    (   p_api_version                         IN  NUMBER,
        p_init_msg_list                       IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_commit                              IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
        p_contract_id                         IN  NUMBER   DEFAULT NULL,
        p_customer_product_id                 IN  NUMBER   DEFAULT NULL,
        p_calling_doc_id                      IN  NUMBER,
        p_calling_doc_type                    IN  VARCHAR2,
        p_sr_rec                              IN  JTF_ASSIGN_PUB.JTF_Serv_Req_rec_type DEFAULT pkg_sr_rec,
        p_sr_task_rec                         IN  JTF_ASSIGN_PUB.JTF_Srv_Task_rec_type DEFAULT pkg_sr_task_rec,
        p_dr_rec                              IN  JTF_ASSIGN_PUB.JTF_DR_rec_type DEFAULT pkg_dr_rec, -- Added by SBARAT on 01/11/2004 for Enh-3919046
        p_business_process_id                 IN  NUMBER   DEFAULT NULL,
        p_business_process_date               IN  DATE   DEFAULT NULL,
        x_excluded_resouurce_tbl              OUT NOCOPY JTF_ASSIGN_PUB.excluded_tbl_type,
        x_return_status                       OUT NOCOPY VARCHAR2,
        x_msg_count                           OUT NOCOPY NUMBER,
        x_msg_data                            OUT NOCOPY VARCHAR2
    );

 -- this is a wrapper for get_available_resource
 -- this is to be used only from AM UI to get the available slots for the resources fetched in
 -- Unassisted mode
 PROCEDURE GET_RESOURCE_AVAILABILITY
            ( p_api_version                   IN  NUMBER,
              p_init_msg_list                 IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
              p_commit                        IN  VARCHAR2 DEFAULT JTF_ASSIGN_PUB.AM_FALSE,
              p_calendar_flag                 IN  VARCHAR2,
              p_effort_duration               IN  NUMBER,
              p_effort_uom                    IN  VARCHAR2,
              p_breakdown                     IN  NUMBER,
              p_breakdown_uom                 IN  VARCHAR2,
              p_planned_start_date            IN  DATE,
              p_planned_end_date              IN  DATE,
              p_continuous_task               IN  VARCHAR2 DEFAULT 'N',
              x_return_status                 IN  OUT NOCOPY VARCHAR2,
              x_msg_count                     IN  OUT NOCOPY NUMBER,
              x_msg_data                      IN  OUT NOCOPY VARCHAR2,
              x_assign_resources_tbl          IN  OUT NOCOPY JTF_ASSIGN_PUB.AssignResources_tbl_type
            );

END JTF_ASSIGN_PUB;

/
