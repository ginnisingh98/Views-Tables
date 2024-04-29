--------------------------------------------------------
--  DDL for Package CN_COMP_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLAN_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvcmpns.pls 120.5.12010000.3 2009/07/29 01:33:46 rnagaraj ship $*/

-- comp plan
TYPE comp_plan_rec_type IS RECORD
  (
    COMP_PLAN_ID        CN_COMP_PLANS.COMP_PLAN_ID%TYPE := CN_API.G_MISS_ID,
    NAME		CN_COMP_PLANS.NAME%TYPE := FND_API.G_MISS_CHAR,
    VERSION		CN_COMP_PLANS.VERSION%TYPE := FND_API.G_MISS_CHAR,
    DESCRIPTION	        CN_COMP_PLANS.DESCRIPTION%TYPE := FND_API.G_MISS_CHAR,
    STATUS_CODE		CN_COMP_PLANS.STATUS_CODE%TYPE := FND_API.G_MISS_CHAR,
    COMPLETE_FLAG	CN_COMP_PLANS.COMPLETE_FLAG%TYPE := FND_API.G_MISS_CHAR,
    ON_QUOTA_DATE	CN_COMP_PLANS.ON_QUOTA_DATE%TYPE := FND_API.G_MISS_DATE,
    ALLOW_REV_CLASS_OVERLAP   CN_COMP_PLANS.ALLOW_REV_CLASS_OVERLAP%TYPE := FND_API.G_MISS_CHAR,
    SUM_TRX_FLAG              CN_COMP_PLANS.SUM_TRX_FLAG%TYPE :=  FND_API.G_MISS_CHAR,
    START_DATE		CN_COMP_PLANS.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		CN_COMP_PLANS.END_DATE%TYPE := FND_API.G_MISS_DATE,
    ATTRIBUTE_CATEGORY	CN_COMP_PLANS.ATTRIBUTE_CATEGORY%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE1		CN_COMP_PLANS.ATTRIBUTE1%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE2		CN_COMP_PLANS.ATTRIBUTE2%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE3		CN_COMP_PLANS.ATTRIBUTE3%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE4		CN_COMP_PLANS.ATTRIBUTE4%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE5		CN_COMP_PLANS.ATTRIBUTE5%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE6		CN_COMP_PLANS.ATTRIBUTE6%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE7		CN_COMP_PLANS.ATTRIBUTE7%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE8		CN_COMP_PLANS.ATTRIBUTE8%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE9		CN_COMP_PLANS.ATTRIBUTE9%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE10		CN_COMP_PLANS.ATTRIBUTE10%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE11		CN_COMP_PLANS.ATTRIBUTE11%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE12		CN_COMP_PLANS.ATTRIBUTE12%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE13		CN_COMP_PLANS.ATTRIBUTE13%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE14		CN_COMP_PLANS.ATTRIBUTE14%TYPE := FND_API.G_MISS_CHAR,
    ATTRIBUTE15		CN_COMP_PLANS.ATTRIBUTE15%TYPE := FND_API.G_MISS_CHAR,
    OBJECT_VERSION_NUMBER   CN_COMP_PLANS.OBJECT_VERSION_NUMBER%TYPE := NULL,
    ORG_ID                 CN_COMP_PLANS.ORG_ID%TYPE := NULL  /* ADDED OAFWK */
    ) ;

TYPE comp_plan_tbl_type IS
   TABLE OF comp_plan_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

G_MISS_COMP_PLAN_REC  comp_plan_rec_type;
G_MISS_COMP_PLAN_REC_TB  comp_plan_tbl_type;

-- sales role
TYPE sales_role_rec_type IS RECORD
  (
    ROLE_PLAN_ID        CN_ROLE_PLANS.ROLE_PLAN_ID%TYPE := CN_API.G_MISS_ID,
    ROLE_ID             CN_ROLE_PLANS.ROLE_ID%TYPE := CN_API.G_MISS_ID,
    COMP_PLAN_ID        CN_ROLE_PLANS.COMP_PLAN_ID%TYPE := CN_API.G_MISS_ID,
    NAME		CN_ROLES.NAME%TYPE := FND_API.G_MISS_CHAR,
    DESCRIPTION	        CN_ROLES.DESCRIPTION%TYPE := FND_API.G_MISS_CHAR,
    START_DATE		CN_ROLE_PLANS.START_DATE%TYPE := FND_API.G_MISS_DATE,
    END_DATE		CN_ROLE_PLANS.END_DATE%TYPE := FND_API.G_MISS_DATE,
    OBJECT_VERSION_NUMBER   CN_ROLE_PLANS.OBJECT_VERSION_NUMBER%TYPE := NULL
    ) ;

TYPE sales_role_tbl_type IS
   TABLE OF sales_role_rec_type INDEX BY BINARY_INTEGER ;

-- salespeople assigned
TYPE srp_plan_assign_rec_type IS RECORD
  (srp_plan_assign_id  CN_SRP_PLAN_ASSIGNS.SRP_PLAN_ASSIGN_ID%TYPE,
   salesrep_id         CN_SRP_PLAN_ASSIGNS.SALESREP_ID%TYPE,
   role_id             CN_SRP_PLAN_ASSIGNS.ROLE_ID%TYPE,
   role_name           CN_ROLES.NAME%TYPE,
   salesrep_name       CN_SALESREPS.NAME%TYPE,
   employee_number     CN_SALESREPS.EMPLOYEE_NUMBER%TYPE,
   start_date          CN_SRP_PLAN_ASSIGNS.START_DATE%TYPE,
   end_date            CN_SRP_PLAN_ASSIGNS.END_DATE%TYPE);

TYPE srp_plan_assign_tbl_type IS
   TABLE OF srp_plan_assign_rec_type INDEX BY BINARY_INTEGER;

-- Global variable that represent missing values.

G_MISS_SALES_ROLE_REC  sales_role_rec_type;
G_MISS_SALES_ROLE_REC_TB  sales_role_tbl_type;

-- Start of comments
--    API name        : Create_Comp_Plan
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN NUMBER       Required
--                      p_init_msg_list       IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN VARCHAR2     Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN NUMBER       Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_comp_plan	      IN  comp_plan_rec_type
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--                      x_comp_plan_id        OUT     NUMBER
--    Version :         Current version       1.0
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Comp_Plan
  (p_api_version                IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan                  IN OUT NOCOPY comp_plan_rec_type,
   x_comp_plan_id               OUT NOCOPY     NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Update_Comp_Plan
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan         IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Comp_Plan
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan                   IN OUT NOCOPY comp_plan_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2 );

-- Start of comments
--      API name        : Delete_Comp_Plan
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan       IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Comp_Plan
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan                   IN OUT NOCOPY  comp_plan_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Get_Comp_Plan_Sum
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_start_record      IN      NUMBER
--                          Default = -1
--                        p_fetch_size        IN      NUMBER
--                          Default = -1
--                        p_search_name       IN      VARCHAR2
--                          Default = '%'
--                        p_search_date       IN      DATE
--                          Default = FND_API.G_MISS_DATE
--                        p_search_status     IN      VARCHAR2
--                          Default = FND_API.G_MISS_CHAR
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_comp_plan         OUT     comp_plan_tbl_type
--                        x_total_record      OUT     NUMBER
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Comp_Plan_Sum
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
   p_start_record                IN      NUMBER := -1,
   p_fetch_size                  IN      NUMBER := -1,
   p_search_name                 IN      VARCHAR2 := '%',
   p_search_date                 IN      DATE := FND_API.G_MISS_DATE,
   p_search_status               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
   x_comp_plan                   OUT NOCOPY     comp_plan_tbl_type,
   x_total_record                OUT NOCOPY     NUMBER,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Comp_Plan_Dtl
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_comp_plan         OUT     comp_plan_rec_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Comp_Plan_Dtl
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan_id                IN      NUMBER,
   x_comp_plan                   OUT NOCOPY     comp_plan_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);


-- Start of comments
--      API name        : Get_Sales_Role
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan_id      IN NUMBER
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--                        x_sales_role        OUT     sales_role_rec_type
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Get_Sales_Role
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan_id                IN      NUMBER,
   x_sales_role                  OUT NOCOPY     sales_role_tbl_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

-- Start of comments
--      API name        : Validate_Comp_Plan
--      Type            : Private.
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_api_version       IN NUMBER       Required
--                        p_init_msg_list     IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_commit            IN VARCHAR2     Optional
--                          Default = FND_API.G_FALSE
--                        p_validation_level  IN NUMBER       Optional
--                          Default = FND_API.G_VALID_LEVEL_FULL
--                        p_comp_plan       IN comp_plan_rec_type
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version     1.0
--      Notes           : Note text
--
-- End of comments
PROCEDURE Validate_Comp_Plan
  (p_api_version                 IN      NUMBER,
   p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level            IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   p_comp_plan                   IN      comp_plan_rec_type,
   x_return_status               OUT NOCOPY     VARCHAR2,
   x_msg_count                   OUT NOCOPY     NUMBER,
   x_msg_data                    OUT NOCOPY     VARCHAR2);

--| ---------------------------------------------------------------------+
--| Procedure Name : check_revenue_class_overlap
--| Desc : Pass in Comp  Plan ID
--|        pass in Comp Plan Name
--|        pass in p_loading_status
--|        out     x_loading_status
--|        out     x_return_status
--| ---------------------------------------------------------------------+
PROCEDURE  check_revenue_class_overlap
  (
   p_comp_plan_id   IN NUMBER,
   p_rc_overlap     IN VARCHAR2,
   p_sum_trx_flag   IN VARCHAR2,
   p_loading_status IN VARCHAR2,
   x_loading_status OUT NOCOPY VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2 );

-- Get salespeople assigned to the plan
PROCEDURE Get_Assigned_Salesreps
  (p_comp_plan_id                IN      NUMBER,
   p_range_low                   IN      NUMBER,
   p_range_high                  IN      NUMBER,
   x_total_rows                  OUT NOCOPY     NUMBER,
   x_result_tbl                  OUT NOCOPY     srp_plan_assign_tbl_type);

-- =====================================================
-- || Procedure: Duplicate_Comp_plan
-- || Description: This Procedure creates a copy of Compplan
-- || in the same Instance and Operating Unit.
-- || This is a Shallow Copy means Children components
-- || are not copied. Children components from the
-- || original Compplan will point to this new
-- || Compplan.
-- =====================================================
   PROCEDURE duplicate_comp_plan  (
     	p_api_version       	IN  NUMBER,
      	p_init_msg_list     	IN  VARCHAR2 := FND_API.G_FALSE,
      	p_commit            	IN  VARCHAR2 := FND_API.G_FALSE,
      	p_validation_level  	IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      	p_comp_plan_id   		IN  CN_COMP_PLANS.COMP_PLAN_ID%TYPE,
      	p_org_id                IN  NUMBER,
      	x_return_status         OUT NOCOPY VARCHAR2,
      	x_msg_count             OUT NOCOPY NUMBER,
      	x_msg_data              OUT NOCOPY VARCHAR2,
      	x_comp_plan_id          OUT NOCOPY CN_COMP_PLANS.COMP_PLAN_ID%TYPE);

END CN_COMP_PLAN_PVT;

/
