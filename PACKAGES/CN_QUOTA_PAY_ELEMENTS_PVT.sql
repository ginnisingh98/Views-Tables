--------------------------------------------------------
--  DDL for Package CN_QUOTA_PAY_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_PAY_ELEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvqpes.pls 115.4 2002/02/05 00:27:09 pkm ship      $ */

--
-- Record type for quota Pay Element
--
TYPE quota_pay_element_rec_type IS RECORD
   (quota_pay_element_id   cn_quota_pay_elements.quota_pay_element_id%TYPE,
    quota_name      	   cn_quotas.name%TYPE,
    pay_element_name       pay_element_types.element_name%TYPE,
    pay_start_date	   pay_element_types.effective_start_date%TYPE
				         := CN_API.G_MISS_DATE,
    pay_end_date           pay_element_types.effective_end_date%TYPE
				 	:= CN_API.G_MISS_DATE,
    status 		   cn_quota_pay_elements.status%TYPE
                           := CN_API.G_MISS_CHAR,
    quota_id		   cn_quotas.quota_id%TYPE,
    pay_element_type_id    cn_quota_pay_elements.pay_element_type_id%TYPE,
    START_DATE             cn_quota_pay_elements.start_date%TYPE
                                       := CN_API.G_MISS_DATE,
   END_DATE                cn_quota_pay_elements.end_date%TYPE
                                       := CN_API.G_MISS_DATE,
   ATTRIBUTE_CATEGORY      cn_quota_pay_elements.attribute_category%TYPE
                           := CN_API.G_MISS_CHAR,
   ATTRIBUTE1              cn_quota_pay_elements.attribute1%TYPE
                           := CN_API.G_MISS_CHAR,
   ATTRIBUTE2              cn_quota_pay_elements.attribute2%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE3              cn_quota_pay_elements.attribute3%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE4              cn_quota_pay_elements.attribute4%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE5              cn_quota_pay_elements.attribute5%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE6              cn_quota_pay_elements.attribute6%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE7              cn_quota_pay_elements.attribute7%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE8              cn_quota_pay_elements.attribute8%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE9              cn_quota_pay_elements.attribute9%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE10             cn_quota_pay_elements.attribute10%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE11             cn_quota_pay_elements.attribute11%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE12             cn_quota_pay_elements.attribute12%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE13             cn_quota_pay_elements.attribute13%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE14             cn_quota_pay_elements.attribute14%TYPE
                            := CN_API.G_MISS_CHAR,
   ATTRIBUTE15             cn_quota_pay_elements.attribute15%TYPE
                            := CN_API.G_MISS_CHAR
  );

-- Global variable that represent missing values.
  G_MISS_QUOTA_PAY_ELEMENT_REC quota_pay_element_rec_type;

--
-- Table Record Type for quota_pay_element_rec_type
--
TYPE quota_pay_element_tbl_type IS TABLE OF quota_pay_element_rec_type
  INDEX BY BINARY_INTEGER;

-- global  variables that represent missing values
G_MISS_QPE_TBL_LIST  quota_pay_element_tbl_type;

-- user for getting and displaying in the jsp page.
TYPE quota_pay_element_out_rec_type IS RECORD
  (  quota_pay_element_id  cn_quota_pay_elements.quota_pay_element_id%TYPE,
     quota_id               cn_quota_pay_elements.quota_id%TYPE,
     pay_element_type_id    cn_quota_pay_elements.pay_element_type_id%TYPE,
     status                 cn_quota_pay_elements.status%TYPE,
     start_date             cn_quota_pay_elements.start_date%TYPE,
     end_date               cn_quota_pay_elements.end_date%TYPE,
     quota_name             cn_quotas.name%TYPE,
     pay_element_name       pay_element_types.element_name%TYPE,
     pay_start_date         cn_quota_pay_elements.start_date%TYPE,
     pay_end_date           cn_quota_pay_elements.end_date%TYPE
     );

TYPE quota_pay_element_out_tbl_type IS TABLE OF
     quota_pay_element_out_rec_type INDEX BY BINARY_INTEGER;

--============================================================================
-- Start of comments
-- API name 	: Create_quota_pay_Element
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to create a new quota Pay element mapping
-- Desc 	: Procedure to create a new quota pay element mapping
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 		   p_quota_pay_elements_rec   IN      quota_pay_elements_rec_type
--                 Required input :
--                    quota_id               quota id
--                    pay_element_input_id
--		      status
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Default Action for this procedure :
-- if nothing is passed for the status default is not active, which is same as
-- cn_salesreps default value
--
-- End of comments
--============================================================================
PROCEDURE Create_quota_pay_element
  (
   p_api_version           IN    NUMBER,
   p_init_msg_list         IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	           IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level      IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT   VARCHAR2,
   x_msg_count	           OUT   NUMBER,
   x_msg_data	           OUT   VARCHAR2,
   p_quota_pay_element_rec IN   quota_pay_element_rec_type
                              := G_MISS_QUOTA_PAY_ELEMENT_REC,
   x_quota_pay_element_id  OUT  NUMBER,
   x_loading_status     OUT   VARCHAR2
);
--============================================================================
-- Start of comments
-- API name 	: Update_quota_pay_element
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to update quota pay element mapping
-- Desc 	: Procedure to update quota pay element mapping
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 	           p_quota_pay_element_rec   IN         quota_pay_element_rec_type
--                 Required input :
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
--
-- End of comments
--============================================================================
 PROCEDURE Update_quota_pay_element
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   VARCHAR2,
   x_msg_count	        OUT   NUMBER,
   x_msg_data	        OUT   VARCHAR2,
   po_quota_pay_element_rec IN  quota_pay_element_rec_type
                              := G_MISS_quota_pay_element_rec,
   p_quota_pay_element_rec  IN  quota_pay_element_rec_type
                              := G_MISS_quota_pay_element_rec,
   x_loading_status     OUT   VARCHAR2
);
--============================================================================
-- Start of comments
-- API name 	: Delete_quota_pay_element
-- Type		: Private
-- Pre-reqs	: None.
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
--                 Required input :
--                    quota_pay_element_id
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Delete quota pay element mapping
--
-- End of comments
--============================================================================
 PROCEDURE Delete_quota_pay_element
  (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 := CN_API.G_FALSE,
   p_commit	          IN  VARCHAR2 := CN_API.G_FALSE,
   p_validation_level     IN  NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT VARCHAR2,
   x_msg_count	          OUT NUMBER,
   x_msg_data	          OUT VARCHAR2,
   p_quota_pay_element_id IN  NUMBER,
   x_loading_status       OUT VARCHAR2
);

--============================================================================
-- Start of Comments
--
-- API name    : Get_quota_pay_element
-- Type        : Private.
-- Pre-reqs    : None.
-- Usage  : To get a quota pay element
-- Desc   : Procedure to get quot pay element
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Require
--                p_init_msg_list     IN VARCHAR2    Optional
--                              Default = FND_API.G_FALSE
--                p_commit           IN VARCHAR2    Optional
--                              Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     OUT          VARCHAR2(1)
--                x_msg_count        OUT           NUMBER
--                x_msg_data         OUT           VARCHAR2(2000)
-- IN          :  p_pay_element, p_quota_name
-- OUT         :  x_loading_status    OUT
--                 Detailed Error Message
-- Version     : Current version   1.0
--          Initial version   1.0
--
-- End of comments
--============================================================================
    PROCEDURE  Get_quota_pay_element
   ( p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2,
     p_commit                IN   VARCHAR2,
     p_validation_level      IN   NUMBER,
     x_return_status         OUT  VARCHAR2,
     x_msg_count             OUT  NUMBER,
     x_msg_data              OUT  VARCHAR2,
     p_quota_name            IN   cn_quotas.name%TYPE,
     p_pay_element_name      IN   pay_element_types.element_name%TYPE,
     p_start_record          IN   NUMBER,
     p_increment_count       IN   NUMBER,
     p_order_by              IN   VARCHAR2,
     x_quota_pay_element_tbl OUT  quota_pay_element_out_tbl_type,
     x_total_records         OUT  NUMBER,
     x_status                OUT  VARCHAR2,
     x_loading_status        OUT  VARCHAR2
     );

END CN_QUOTA_PAY_ELEMENTS_PVT;

 

/
