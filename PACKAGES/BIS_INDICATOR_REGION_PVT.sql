--------------------------------------------------------
--  DDL for Package BIS_INDICATOR_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_INDICATOR_REGION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVREGS.pls 115.19 2003/01/30 09:11:26 sugopal noship $ */

TYPE User_Label_Rec_Type IS RECORD(
  Ind_Selection_ID             NUMBER ,
  Plug_ID                      NUMBER ,
  User_ID                      NUMBER ,
  Label                        VARCHAR2(30) );

TYPE User_Label_Tbl_Type IS TABLE OF User_Label_Rec_Type
  INDEX BY BINARY_INTEGER;

e_InvalidEventException EXCEPTION;

Procedure Create_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER ,
        p_user_name             IN VARCHAR2 ,
        p_plug_id               IN NUMBER ,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Retrieve_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_all_info              IN VARCHAR2 Default FND_API.G_TRUE,
        p_Target_level_id       IN NUMBER,
        x_Indicator_Region_Tbl
          OUT NOCOPY BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Update_User_Ind_Selection(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER ,
        p_Indicator_Region_Rec
          IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);


Procedure Delete_User_Ind_Selections(
        p_api_version           IN NUMBER,
        p_user_id               IN NUMBER Default BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name             IN VARCHAR2 Default BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id               IN NUMBER,
        x_return_status	        OUT NOCOPY VARCHAR2,
        x_error_Tbl             OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type);

Procedure Retrieve_User_Labels(
        p_user_id             IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM,
        p_user_name           IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR,
        p_plug_id             IN NUMBER,
        x_label_tbl           OUT NOCOPY BIS_INDICATOR_REGION_PVT.User_Label_Tbl_Type,
        x_return_status	      OUT NOCOPY VARCHAR2);

Procedure Validate_User_Ind_Selection(
      p_api_version           IN NUMBER,
      p_event                 IN VARCHAR2,
      p_user_id               IN NUMBER,
      p_Indicator_Region_Rec
        IN BIS_INDICATOR_REGION_PUB.Indicator_Region_Rec_Type,
      x_return_status	      OUT NOCOPY VARCHAR2);

Procedure Validate_Required_Fields(
        p_event                IN VARCHAR2,
        p_user_id              IN NUMBER,
        p_Indicator_Region_Rec
          IN BIS_Indicator_Region_PUB.Indicator_Region_Rec_Type,
        x_return_status        OUT NOCOPY VARCHAR2);


END BIS_INDICATOR_REGION_PVT;

 

/
