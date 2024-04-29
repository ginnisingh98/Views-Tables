--------------------------------------------------------
--  DDL for Package CN_PAY_ELEMENT_INPUTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_ELEMENT_INPUTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvqpis.pls 115.4 2002/02/05 00:27:12 pkm ship      $ */

--
-- Record type for Pay Element Inputs
--
TYPE pay_element_input_rec_type IS RECORD
   ( pay_element_name       pay_element_types.element_name%TYPE
			   := CN_API.G_MISS_CHAR,
     start_date		    pay_element_types.effective_start_date%TYPE,
     end_date		    pay_element_types.effective_end_date%TYPE,
     table_name		   cn_objects.name%TYPE
 			   := CN_API.G_MISS_CHAR,
     column_name		   cn_objects.name%TYPE
 			   := CN_API.G_MISS_CHAR,
    pay_input_name         pay_input_values.name%TYPE
                           := CN_API.G_MISS_CHAR,
    line_number            pay_input_values.display_sequence%TYPE,
    pay_element_input_id   cn_pay_element_inputs.pay_element_input_id%TYPE,
    quota_pay_element_id   cn_pay_element_inputs.quota_pay_element_id%TYPE,
    element_input_id       cn_pay_element_inputs.element_input_id%TYPE,
    element_type_id        cn_pay_element_inputs.element_type_id%TYPE,
    tab_object_id	   cn_objects.object_id%TYPE,
    col_object_id	   cn_objects.object_id%TYPE,
    ATTRIBUTE_CATEGORY      cn_pay_element_inputs.attribute_category%TYPE
                           := CN_API.G_MISS_CHAR,
    ATTRIBUTE1              cn_pay_element_inputs.attribute1%TYPE
                           := CN_API.G_MISS_CHAR,
    ATTRIBUTE2              cn_pay_element_inputs.attribute2%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE3              cn_pay_element_inputs.attribute3%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE4              cn_pay_element_inputs.attribute4%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE5              cn_pay_element_inputs.attribute5%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE6              cn_pay_element_inputs.attribute6%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE7              cn_pay_element_inputs.attribute7%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE8              cn_pay_element_inputs.attribute8%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE9              cn_pay_element_inputs.attribute9%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE10             cn_pay_element_inputs.attribute10%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE11             cn_pay_element_inputs.attribute11%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE12             cn_pay_element_inputs.attribute12%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE13             cn_pay_element_inputs.attribute13%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE14             cn_pay_element_inputs.attribute14%TYPE
                            := CN_API.G_MISS_CHAR,
    ATTRIBUTE15             cn_pay_element_inputs.attribute15%TYPE
                            := CN_API.G_MISS_CHAR
  );

-- Global variable that represent missing values.
  G_MISS_PAY_ELEMENT_INPUT_REC pay_element_input_rec_type;

--
-- Table Record Type for pay_element_input_rec_type
--
TYPE pay_element_input_tbl_type IS TABLE OF pay_element_input_rec_type
  INDEX BY BINARY_INTEGER;

-- global  variables that represent missing values
G_MISS_QPI_TBL_LIST  pay_element_input_tbl_type;

-- user for getting and displaying in the jsp page.
TYPE pay_element_input_out_rec_type IS RECORD
  (  pay_element_input_id    cn_pay_element_inputs.pay_element_input_id%TYPE,
     quota_pay_element_id    cn_pay_element_inputs.quota_pay_element_id%TYPE,
     element_input_id        cn_pay_element_inputs.element_input_id%TYPE,
     element_type_id         cn_pay_element_inputs.element_type_id%TYPE,
     table_name		     cn_objects.name%TYPE,
     column_name             cn_objects.name%TYPE,
     start_date		     cn_pay_element_inputs.start_date%TYPE,
     end_date		     cn_pay_element_inputs.end_date%TYPE,
     pay_element_name        pay_element_types.element_name%TYPE,
     pay_input_name          pay_input_values.name%TYPE,
     line_number             cn_pay_element_inputs.line_number%TYPE,
     tab_object_id           cn_objects.object_id%TYPE,
     col_object_id           cn_objects.object_id%TYPE
     );

TYPE pay_element_input_out_tbl_type IS TABLE OF
     pay_element_input_out_rec_type INDEX BY BINARY_INTEGER;

--============================================================================
-- Start of comments
-- API name 	: Create_pay_Element_input
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to create a new Pay element inputs
-- Desc 	: Procedure to create a new pay element input
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 		   p_pay_element_input_rec   IN      pay_element_input_rec_type
--                 Required input :
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
PROCEDURE Create_pay_element_input
  (
   p_api_version           IN    NUMBER,
   p_init_msg_list         IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	           IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level      IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT   VARCHAR2,
   x_msg_count	           OUT   NUMBER,
   x_msg_data	           OUT   VARCHAR2,
   p_pay_element_input_rec IN   pay_element_input_rec_type
                              := G_MISS_PAY_ELEMENT_INPUT_REC,
   x_pay_element_input_id  OUT  NUMBER,
   x_loading_status        OUT   VARCHAR2
);
--============================================================================
-- Start of comments
-- API name 	: Update_pay_element_input
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to update pay element input
-- Desc 	: Procedure to update pay element input
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 	           p_pay_element_input_rec   IN         pay_element_input_rec_type
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
 PROCEDURE Update_pay_element_input
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   VARCHAR2,
   x_msg_count	        OUT   NUMBER,
   x_msg_data	        OUT   VARCHAR2,
   po_pay_element_input_rec IN  pay_element_input_rec_type
                              := g_miss_pay_element_input_rec,
   p_pay_element_input_rec  IN  pay_element_input_rec_type
                              := G_MISS_pay_element_input_rec,
   x_loading_status     OUT   VARCHAR2
);
--============================================================================
-- Start of comments
-- API name 	: Delete_pay_element_input
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
--                    pay_element_input_id
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Delete pay element mapping
--
-- End of comments
--============================================================================
 PROCEDURE Delete_pay_element_input
  (
   p_api_version          IN  NUMBER,
   p_init_msg_list        IN  VARCHAR2 := CN_API.G_FALSE,
   p_commit	          IN  VARCHAR2 := CN_API.G_FALSE,
   p_validation_level     IN  NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status        OUT VARCHAR2,
   x_msg_count	          OUT NUMBER,
   x_msg_data	          OUT VARCHAR2,
   p_pay_element_input_id IN  NUMBER,
   x_loading_status       OUT VARCHAR2
);

--============================================================================
-- Start of Comments
--
-- API name    : Get_pay_element_input
-- Type        : Private.
-- Pre-reqs    : None.
-- Usage  : To get a pay element input
-- Desc   : Procedure to get pay element
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
-- IN          :  p_pay_element, p_start_date, p_end_date
-- OUT         :  x_loading_status    OUT
--                 Detailed Error Message
-- Version     : Current version   1.0
--          Initial version   1.0
--
-- End of comments
--============================================================================
    PROCEDURE  Get_pay_element_input
   ( p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2,
     p_commit                IN   VARCHAR2,
     p_validation_level      IN   NUMBER,
     x_return_status         OUT  VARCHAR2,
     x_msg_count             OUT  NUMBER,
     x_msg_data              OUT  VARCHAR2,
     p_element_type_id        IN   cn_pay_element_inputs.element_type_id%TYPE,
     p_start_record          IN   NUMBER,
     p_increment_count       IN   NUMBER,
     p_order_by              IN   VARCHAR2,
     x_pay_element_input_tbl OUT  pay_element_input_out_tbl_type,
     x_total_records         OUT  NUMBER,
     x_status                OUT  VARCHAR2,
     x_loading_status        OUT  VARCHAR2
     );

END CN_PAY_ELEMENT_INPUTS_PVT;

 

/
