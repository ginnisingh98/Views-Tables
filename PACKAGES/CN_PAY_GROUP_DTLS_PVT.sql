--------------------------------------------------------
--  DDL for Package CN_PAY_GROUP_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_GROUP_DTLS_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvpgdts.pls 115.4 2002/11/27 05:31:00 pramadas ship $*/

TYPE pay_group_dtls_rec_type IS RECORD
  (
    PAY_GROUP_ID           CN_PAY_GROUPS.PAY_GROUP_ID%TYPE := CN_API.G_MISS_ID,
    NAME	               CN_PAY_GROUPS.NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_SET_NAME        CN_PERIOD_SETS.PERIOD_SET_NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_TYPE            CN_PAY_GROUPS.PERIOD_TYPE%TYPE := FND_API.G_MISS_CHAR,

    PERIOD_NAME            CN_PERIOD_STATUSES.PERIOD_NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_YEAR            CN_PERIOD_STATUSES.PERIOD_YEAR%TYPE := CN_API.G_MISS_ID,
    QUARTER_NUM            CN_PERIOD_STATUSES.QUARTER_NUM%TYPE := CN_API.G_MISS_ID,
    START_DATE		       CN_PERIOD_STATUSES.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		       CN_PERIOD_STATUSES.END_DATE%TYPE := FND_API.G_MISS_DATE
    ) ;

TYPE pay_group_sales_rec_type IS RECORD
  (
    PAY_GROUP_ID           CN_PAY_GROUPS.PAY_GROUP_ID%TYPE := CN_API.G_MISS_ID,
    NAME	               CN_PAY_GROUPS.NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_SET_NAME        CN_PERIOD_SETS.PERIOD_SET_NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_TYPE            CN_PAY_GROUPS.PERIOD_TYPE%TYPE := FND_API.G_MISS_CHAR,

    SALESREP_NAME          CN_SALESREPS.NAME%TYPE := FND_API.G_MISS_CHAR,
    EMPLOYEE_NUMBER        CN_SALESREPS.EMPLOYEE_NUMBER%TYPE := FND_API.G_MISS_CHAR,

    START_DATE		       CN_SRP_PAY_GROUPS.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		       CN_SRP_PAY_GROUPS.END_DATE%TYPE := FND_API.G_MISS_DATE
    ) ;

 TYPE pay_group_roles_rec_type IS RECORD
  (
    PAY_GROUP_ID           CN_PAY_GROUPS.PAY_GROUP_ID%TYPE := CN_API.G_MISS_ID,
    NAME	               CN_PAY_GROUPS.NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_SET_NAME        CN_PERIOD_SETS.PERIOD_SET_NAME%TYPE := FND_API.G_MISS_CHAR,
    PERIOD_TYPE            CN_PAY_GROUPS.PERIOD_TYPE%TYPE := FND_API.G_MISS_CHAR,

    ROLE_NAME              CN_ROLES.NAME%TYPE := FND_API.G_MISS_CHAR,
    ROLE_ID                CN_ROLES.ROLE_ID%TYPE := CN_API.G_MISS_ID,

    START_DATE		     CN_ROLE_PAY_GROUPS.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		     CN_ROLE_PAY_GROUPS.END_DATE%TYPE := FND_API.G_MISS_DATE
    ) ;



TYPE pay_group_dtls_tbl_type IS
   TABLE OF pay_group_dtls_rec_type INDEX BY BINARY_INTEGER ;

TYPE pay_group_sales_tbl_type IS
   TABLE OF pay_group_sales_rec_type INDEX BY BINARY_INTEGER ;
TYPE pay_group_roles_tbl_type IS
   TABLE OF pay_group_roles_rec_type INDEX BY BINARY_INTEGER ;




-- Global variable that represent missing values.

G_MISS_PAY_GROUP_DTLS_REC  pay_group_dtls_rec_type;
G_MISS_PAY_GROUP_DTLS_REC_TB  pay_group_dtls_tbl_type;
G_MISS_PAY_GROUP_DTLS_REC_RL  pay_group_roles_tbl_type;

G_MISS_PAY_GROUP_SALES_REC  pay_group_sales_rec_type;
G_MISS_PAY_GROUP_SALES_REC_TB  pay_group_sales_tbl_type;
G_MISS_PAY_GROUP_ROLES_REC  pay_group_roles_rec_type;


PROCEDURE Get_Pay_Group_Dtls
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,


   x_pay_group_dtls              OUT NOCOPY    pay_group_dtls_tbl_type,

   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


PROCEDURE Get_Pay_Group_Sales
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,
   x_pay_group_sales              OUT NOCOPY     pay_group_sales_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

PROCEDURE Get_Pay_Group_Roles
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_pay_group_id                IN      NUMBER,
   x_pay_group_roles             OUT  NOCOPY   pay_group_roles_tbl_type,
   x_total_record                OUT  NOCOPY   NUMBER,
   x_return_status               OUT  NOCOPY   VARCHAR2,
   x_msg_count                   OUT  NOCOPY   NUMBER,
   x_msg_data                    OUT  NOCOPY   VARCHAR2);






END CN_PAY_GROUP_DTLS_PVT;


 

/
