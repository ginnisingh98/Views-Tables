--------------------------------------------------------
--  DDL for Package CN_CREDIT_TYPE_CONV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CREDIT_TYPE_CONV_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvctcns.pls 115.1 2001/10/29 17:19:26 pkm ship      $*/

-- Start of comments
--    API name        : Create_Conversion
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
--                      p_from_credit_type    IN NUMBER       Required
--                      p_to_credit_type      IN NUMBER       Required
--                      p_conv_factor         IN NUMBER       Required
--                      p_start_date          IN DATE         Required
--                      p_end_date            IN DATE         Required
--    OUT             : x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count                     OUT     NUMBER
--                      x_msg_data                      OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : Note text
--
-- End of comments
PROCEDURE Create_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_from_credit_type    IN  number,
p_to_credit_type      IN  number,
p_conv_factor         IN  number,
p_start_date          IN  date,
p_end_date            IN  date,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2);

-- Start of comments
--      API name        : Update_Conversion
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
--                        p_object_version      IN NUMBER       Required
--                        p_conv_id             IN NUMBER       Required
--                        p_from_credit_type    IN NUMBER       Required
--                        p_to_credit_type      IN NUMBER       Required
--                        p_conv_factor         IN NUMBER       Required
--                        p_start_date          IN DATE         Required
--                        p_end_date            IN DATE         Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       x.x
--                              Changed....
--                        Previous version      y.y
--                              Changed....
--                        .
--                        .
--                        Previous version      2.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments
PROCEDURE Update_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_object_version      IN  number,
p_conv_id             IN  number,
p_from_credit_type    IN  number,
p_to_credit_type      IN  number,
p_conv_factor         IN  number,
p_start_date          IN  date,
p_end_date            IN  date,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2);

-- Start of comments
--      API name        : Delete_Conversion
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
--                        p_object_version    IN NUMBER       Required
--                        p_conv_id           IN NUMBER       Required
--      OUT             : x_return_status     OUT     VARCHAR2(1)
--                        x_msg_count         OUT     NUMBER
--                        x_msg_data          OUT     VARCHAR2(2000)
--      Version :         Current version       x.x
--                              Changed....
--                        Previous version      y.y
--                              Changed....
--                        .
--                        .
--                        Previous version      2.0
--                              Changed....
--                        Initial version       1.0
--
--      Notes           : Note text
--
-- End of comments
PROCEDURE Delete_Conversion
(p_api_version        IN  number,
 p_init_msg_list      IN  varchar2 := FND_API.G_FALSE,
p_commit              IN  varchar2 := FND_API.G_FALSE,
p_validation_level    IN  number  := FND_API.G_VALID_LEVEL_FULL,
p_object_version      IN  number,
p_conv_id             IN  number,
x_return_status       OUT varchar2,
x_msg_count           OUT number,
x_msg_data            OUT varchar2);

END CN_CREDIT_TYPE_CONV_PVT;

 

/
