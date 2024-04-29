--------------------------------------------------------
--  DDL for Package AS_SALES_MEMBER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_MEMBER_PUB" AUTHID CURRENT_USER as
/* $Header: asxpsmbs.pls 120.1 2005/06/05 22:52:30 appldev  $ */

-- Start of Comments
--
-- NAME
--   AS_SALES_MEMBER_PUB
--
-- PURPOSE
--   This package is a public API for Sales Member related api's
--

--
-- HISTORY
--   6/19/98        ALHUNG            created
--
-- End of Comments

-- Sales Member Record : sales_member_rec_type
--
-- Parameters:
--  salesforce_id             Salesforce identifier (PK for salesrep)
--  Type                      Sales Member Type: Employee or sales partner
--  Start_date_active         Start active date of sales member
--  End_Date_active           End active date of sales member
--  Employee_Person_Id        Employee identifier
--  Sales_Group_Id            Salesgroup identifier
--  Partner_Customer_Id       Partner identifier
--  Partner_Address_Id        Address identifier of the partner
--  Partner_Contact_Id        Contact identifier of the partner
--  Last_name                 Sales Member First name if employee
--  First_name                Sales Member Last name if employee
--  Full_name                 Sales Member Full name if employee
--  Email_address             Sales Member Email Address if employee
--  Job_title                 Job title of Salesrep
--  Sales_Group_Name          Name of the sales group this member belongs to
--  Customer_name             Partner Name if partner
--  City                      Partner City if partner
--  State                     Partner State if partner
--  Address                   Partner Address if partner
--  User_id                   Fnd User identifier.  Only used as criteria

G_EMPLOYEE_SALES_MEMBER CONSTANT VARCHAR2(30) := 'EMPLOYEE';
G_PARTNER_SALES_MEMBER CONSTANT VARCHAR2(30) := 'PARTNER';
G_OTHER_SALES_MEMBER CONSTANT VARCHAR2(30) := 'OTHERS';

TYPE sales_member_rec_type IS RECORD (
     salesforce_id            Number            :=FND_API.G_MISS_NUM
    ,Type                     Varchar2(30)      :=FND_API.G_MISS_CHAR
    ,Start_date_active        DATE              :=FND_API.G_MISS_DATE
    ,End_date_active          DATE              :=FND_API.G_MISS_DATE
    ,Employee_Person_Id       Number            :=FND_API.G_MISS_NUM
    ,Sales_Group_Id           Number            :=FND_API.G_MISS_NUM
    ,Partner_Address_Id       Number            :=FND_API.G_MISS_NUM
    ,Partner_Customer_Id      Number            :=FND_API.G_MISS_NUM
    ,Partner_Contact_Id       Number            :=FND_API.G_MISS_NUM
    ,Last_name                Varchar2(40)      :=FND_API.G_MISS_CHAR
    ,First_name               Varchar2(20)      :=FND_API.G_MISS_CHAR
    ,Full_name                Varchar2(240)     :=FND_API.G_MISS_CHAR
    ,Email_address            Varchar2(240)     :=FND_API.G_MISS_CHAR
    ,Job_title                Varchar2(240)     :=FND_API.G_MISS_CHAR
    ,Sales_Group_Name         Varchar2(60)      :=FND_API.G_MISS_CHAR
    ,Customer_name            Varchar2(50)      :=FND_API.G_MISS_CHAR
    ,City                     Varchar2(60)      :=FND_API.G_MISS_CHAR
    ,State                    Varchar2(60)      :=FND_API.G_MISS_CHAR
    ,Address                  Varchar2(240)     :=FND_API.G_MISS_CHAR
    ,user_id                  Number            :=FND_API.G_MISS_NUM
    ,managing_sales_grp_id    Number            :=FND_API.G_MISS_NUM
    ,managing_sales_grp_name  Varchar2(60)      :=FND_API.G_MISS_CHAR
    );

G_MISS_SALES_MEMBER_REC sales_member_rec_type;

TYPE sales_member_tbl_type is TABLE OF sales_member_rec_type
                              INDEX BY BINARY_INTEGER;


-- Start of Comments
--
--    API name    : Convert_SFID_to_Values
--    Type        : Public
--    Function    : Return sales member record with values given
--                  salesforce_id
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number                IN NUMBER                    Required
--            p_identity_salesforce_id            IN NUMBER                    Required
--            p_init_msg_list                     IN VARCHAR2                  Optional
--                Default = :=FND_API.G_FALSE
--
--    OUT NOCOPY /* file.sql.39 change */        :
--            x_return_status                     OUT NOCOPY /* file.sql.39 change */    VARCHAR2(1)
--            x_msg_count                         OUT NOCOPY /* file.sql.39 change */    NUMBER
--            x_msg_data                          OUT NOCOPY /* file.sql.39 change */    VARCHAR2(2000)
--            x_sales_member_rec                  OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type
--
--    Version    :    Current version    1.0
--                    Initial version    1.0
--
--    Business Rules: This procedure use p_salesforce_id to identify a sales member.
--                    If the member is a sales person, the person's last_name, first_name
--                    etc are looked up.  If the member is a sales partner, customer_name,
--                    address, city, etc are looked up.
--    Notes:

PROCEDURE Convert_SFID_to_Values
(   p_api_version_number                   IN     NUMBER,
    p_init_msg_list                        IN     VARCHAR2
                                := FND_API.G_FALSE,
    p_salesforce_id                        IN     NUMBER,

    x_return_status                        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_msg_count                            OUT NOCOPY /* file.sql.39 change */    NUMBER,
    x_msg_data                             OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
    x_sales_member_rec                     OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type
);


-- Start of Comments
--
--    API name    : Convert_Partner_to_ID
--    Type        : Public
--    Function    : Return sales member record with values given
--                  salesforce_id
--
--    Pre-reqs    : None
--    Paramaeters    :
--    IN        :
--            p_api_version_number                IN NUMBER                    Required
--            p_partner_customer_id               IN NUMBER                    Required
--            p_partner_address_id                IN NUMBER                    Required
--            p_init_msg_list                     IN VARCHAR2                  Optional
--                Default = :=FND_API.G_FALSE
--
--    OUT NOCOPY /* file.sql.39 change */        :
--            x_return_status                     OUT NOCOPY /* file.sql.39 change */    VARCHAR2(1)
--            x_msg_count                         OUT NOCOPY /* file.sql.39 change */    NUMBER
--            x_msg_data                          OUT NOCOPY /* file.sql.39 change */    VARCHAR2(2000)
--            x_sales_member_rec                  OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type
--
--    Version    :    Current version    1.0
--                    Initial version    1.0
--
--    Business Rules:
--    Notes:

Procedure Convert_Partner_to_ID( p_api_version_number   IN     NUMBER
                                ,p_init_msg_list        IN     VARCHAR2
                                        := FND_API.G_FALSE
                                ,p_partner_customer_id  IN     Number
                                ,p_partner_address_id   IN     Number
                                ,x_return_status        OUT NOCOPY /* file.sql.39 change */    Varchar2
                                ,x_msg_count            OUT NOCOPY /* file.sql.39 change */    NUMBER
                                ,x_msg_data             OUT NOCOPY /* file.sql.39 change */    VARCHAR2
                                ,x_sales_member_rec     OUT NOCOPY /* file.sql.39 change */    Sales_Member_Rec_Type  );




END AS_SALES_MEMBER_PUB;


 

/
