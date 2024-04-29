--------------------------------------------------------
--  DDL for Package GMF_BURDENDETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_BURDENDETAILS_PVT" AUTHID CURRENT_USER AS
/* $Header: GMFVBRDS.pls 120.3.12000000.1 2007/01/17 16:53:34 appldev ship $ */
TYPE Burden_factor_Rec_Type IS RECORD
(
  burden_factor NUMBER
);

TYPE Burden_factor_Tbl_Type IS TABLE OF Burden_factor_Rec_Type
                        INDEX BY BINARY_INTEGER;

PROCEDURE Create_Burden_Details
(
  p_api_version                 IN  NUMBER                      ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,
  p_dtl_tbl                     IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type           ,
  p_user_id                     IN  fnd_user.user_id%TYPE       ,
  p_burden_factor_tbl           IN  Burden_factor_Tbl_Type      ,

  x_burdenline_ids              OUT NOCOPY GMF_BurdenDetails_PUB.Burdenline_Ids_Tbl_Type
);

PROCEDURE Update_Burden_Details
(
  p_api_version                 IN  NUMBER                      ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,
  p_dtl_tbl                     IN  GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type           ,
  p_user_id                     IN  fnd_user.user_id%TYPE       ,
  p_burden_factor_tbl           IN  Burden_factor_Tbl_Type
);

PROCEDURE Get_Burden_Details
(
  p_api_version                 IN  NUMBER                      ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  GMF_BurdenDetails_PUB.Burden_Header_Rec_Type        ,

  x_dtl_tbl                     OUT NOCOPY GMF_BurdenDetails_PUB.Burden_Dtl_Tbl_Type
);

END GMF_BurdenDetails_PVT ;

 

/
