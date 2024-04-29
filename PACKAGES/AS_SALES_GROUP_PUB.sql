--------------------------------------------------------
--  DDL for Package AS_SALES_GROUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_GROUP_PUB" AUTHID CURRENT_USER as
/* $Header: asxpsgrs.pls 115.4 2002/11/06 00:46:32 appldev ship $ */

-- Start of Comments
--
-- NAME
--   AS_SALES_GROUP_PUB
--
-- PURPOSE
--   This package is a public API for Sales Group related api's
--

--
-- HISTORY
--   7/31/98        ALHUNG            created
--
-- End of Comments

-- Sales Member Record : SALES_GROUP_rec_type
--
-- Parameters:
--  sales_group_id            Sales_group identifier (PK for salesgroup)
--  Name                      Sales group name
--  Start_Date_Active         The first day this sales group is active
--  Enabled_Flag              Flag indicating whether sales group is active
--  Description               description of the sales group
--  Parent_Sales_Group_id     Parent Sales group identifier
--  Manager_Person_Id         Identifier of the group's manager
--  Manager_Salesforce_Id     Salesforce identifier of the manager
--  End_Date_Active           The last day this sales group is active
--  Accounting_Code           Cost Center Code


TYPE SALES_GROUP_rec_type IS RECORD (
     sales_group_id           Number            :=FND_API.G_MISS_NUM
    ,Name                     Varchar2(60)      :=FND_API.G_MISS_CHAR
    ,Start_Date_Active        Date              :=FND_API.G_MISS_DATE
--    ,Enabled_Flag             Varchar2(1)       :=FND_API.G_MISS_CHAR
    ,Description              Varchar2(240)     :=FND_API.G_MISS_CHAR
    ,Parent_Sales_Group_id    Number            :=FND_API.G_MISS_NUM
    ,Manager_Person_Id        Number            :=FND_API.G_MISS_NUM
    ,Manager_Salesforce_Id    Number            :=FND_API.G_MISS_NUM
    ,End_Date_Active          Date              :=FND_API.G_MISS_DATE
    ,Accounting_Code          Varchar2(80)      :=FND_API.G_MISS_CHAR

    );

G_MISS_SALES_GROUP_REC SALES_GROUP_rec_type;

TYPE SALES_GROUP_tbl_type is TABLE OF SALES_GROUP_rec_type
                              INDEX BY BINARY_INTEGER;





END AS_SALES_GROUP_PUB;


 

/
