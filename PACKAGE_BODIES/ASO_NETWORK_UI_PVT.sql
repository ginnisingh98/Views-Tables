--------------------------------------------------------
--  DDL for Package Body ASO_NETWORK_UI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_NETWORK_UI_PVT" as
/* $Header: asovnetb.pls 120.1 2005/06/29 12:42:13 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_NETWORK_UI_PVT
-- Purpose          : This is a wrapper, to make the CZ API Calls for MACD Functionality in Quoting Forms UI
-- History          :
-- NOTE             :
-- End of Comments

-----------------------------------------------------------------------------
-- API name:  is_container
-- API type:  public
-- Function:  Checks if a model specified by the top inventory_item_id and
--            organization_id is a network container model.

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'ASO_NETWORK_UI_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ASOVNETB.PLS';

procedure aso_is_container(p_api_version    IN   NUMBER
                          ,p_inventory_item_id  IN   NUMBER
                          ,p_organization_id    IN   NUMBER
                          ,p_appl_param_rec     IN   ASO_NETWORK_UI_PVT.aso_appl_param_rec_type
                          ,x_return_value       OUT NOCOPY  VARCHAR2
                          ,x_return_status      OUT NOCOPY  VARCHAR2
                          ,x_msg_count          OUT NOCOPY  NUMBER
                          ,x_msg_data           OUT NOCOPY  VARCHAR2
                          )
IS
   l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;


  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'aso_is_container';

  l_model_id NUMBER;
  l_msg_data VARCHAR2(2000);
  l_sqlerrm  VARCHAR2(2000);

BEGIN
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_NETWORK_UI_PVT.Aso_Is_Container BEGIN');
    END IF;

    l_appl_param_rec.calling_application_id := P_appl_param_rec.calling_application_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Call TO CZ_NETWORK_API_PUB.Is_Container ');
    END IF;

    CZ_NETWORK_API_PUB.Is_Container
				 (p_api_version       => p_api_version,
                      p_inventory_item_id => p_inventory_item_id,
				  p_organization_id   => p_organization_id,
				  p_appl_param_rec    => l_appl_param_rec,
				  x_return_value      => x_return_value,
				  x_return_status     => x_return_status,
				  x_msg_count         => x_msg_count,
				  x_msg_data          => x_msg_data
				 );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('X_Return_value from Cz_NETWORK_API_Pub.Is_Container '||x_return_value);
       aso_debug_pub.add('X_Return_Status from Cz_NETWORK_API_Pub.Is_Container '||X_Return_Status);
       aso_debug_pub.add('ASO_NETWORK_UI_PVT.Aso_Is_Container END');
    END IF;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
END Aso_Is_Container;

-----------------------------------------------------------------------------
-- API name:  aso_get_contained_models
-- API type:  private
-- Function:  Retrieves all possible enclosed trackable child models for the network
--            container model specified by the input inventory_item_id and
--            organization_id

procedure aso_get_contained_models(p_api_version            IN          NUMBER
                                  ,p_inventory_item_id      IN          NUMBER
                                  ,p_organization_id        IN          NUMBER
                                  ,p_appl_param_rec         IN          ASO_NETWORK_UI_PVT.aso_appl_param_rec_type
                                  ,x_model_tbl              OUT NOCOPY  ASO_NETWORK_UI_PVT.aso_number_tbl_type
                                  ,x_return_status          OUT NOCOPY  VARCHAR2
                                  ,x_msg_count              OUT NOCOPY  NUMBER
                                  ,x_msg_data               OUT NOCOPY  VARCHAR2
                                  )
IS
  l_api_name     CONSTANT VARCHAR2(30) := 'aso_get_contained_models';

  l_inventory_item_id_tbl  CZ_API_PUB.number_tbl_type := cz_api_pub.NUMBER_TBL_TYPE();
  l_msg_data               VARCHAR2(2000);
  l_appl_param_rec         CZ_API_PUB.appl_param_rec_type;

  lx_model_tbl      CZ_API_PUB.number_tbl_type;
 BEGIN
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_NETWORK_UI_PVT.Aso_Get_Contained_Models BEGIN');
    END IF;

   --x_model_tbl := ASO_NETWORK_UI_PVT.aso_number_tbl_type();

    l_appl_param_rec.calling_application_id := P_appl_param_rec.calling_application_id;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Call to CZ_NETWORK_API_PUB.Get_Contained_Models ');
    END IF;

    CZ_NETWORK_API_PUB.Get_Contained_Models(
	                                p_api_version       => p_api_version,
					p_inventory_item_id => p_inventory_item_id,
					p_organization_id   => p_organization_id,
					p_appl_param_rec    => l_appl_param_rec,
					x_model_tbl         => lx_model_tbl,
					x_return_status     => x_return_status,
					x_msg_count         => x_msg_count,
					x_msg_data          => x_msg_data
					);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('return CZ_NETWORK_API_PUB.Get_Contained_Models '||X_Return_Status);
    END IF;

   IF lx_model_tbl.COUNT > 0 THEN
     --x_model_tbl.extend(lx_model_tbl.COUNT);
   For i IN lx_Model_Tbl.FIRST..lx_Model_Tbl.LAST
      Loop
        X_Model_Tbl(i) := Lx_Model_Tbl(i);
      End Loop;

   End If;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('ASO_NETWORK_UI_PVT.Aso_Get_Contained_Models END');
    END IF;

   EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

   WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
      );
    END IF;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END Aso_Get_Contained_Models;
--------------------------------------
PROCEDURE aso_config_operations(
    P_Api_Version_Number  	 IN	  NUMBER,
    P_Init_Msg_List   		 IN	  VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		 IN	  VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN	  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		 IN	  ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		 IN       ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_qte_line_tbl               IN	  ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl ,
    P_instance_tbl               IN       ASO_NETWORK_UI_PVT.Aso_Instance_Tbl_Type,
    p_operation_code             IN       VARCHAR2,
    x_Qte_Header_Rec             OUT NOCOPY /* file.sql.39 change */      ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
    X_Msg_Count    	         OUT NOCOPY /* file.sql.39 change */      NUMBER,
    X_Msg_Data    	         OUT NOCOPY /* file.sql.39 change */      VARCHAR2
)is

l_api_name               CONSTANT VARCHAR2(30) := 'aso_config_operations';
l_instance_tbl           ASO_QUOTE_HEADERS_PVT.Instance_tbl_type;

Begin
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');
   IF P_Instance_tbl.COUNT > 0 THEN
   For i IN P_Instance_Tbl.FIRST..P_Instance_Tbl.LAST
      Loop
        l_Instance_Tbl(i).Instance_Id := P_Instance_Tbl(i).Instance_Id;
      End Loop;

   End If;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Call TO ASO_NETWORK_UI_PVT.Aso_Config_Operations Begin ');
    END IF;

    Aso_Config_Operations_Int.Config_Operations(
   	  p_api_version_number => p_api_version_number,
	  p_init_msg_list      => p_init_msg_list,
	  p_commit             => p_commit,
	  p_validation_level   => p_validation_level,
	  p_control_rec        => P_control_rec,
	  p_qte_header_rec     => P_qte_header_rec,
	  p_qte_line_tbl       => P_qte_line_tbl,
	  p_instance_tbl       => l_instance_tbl,
          p_operation_code     => p_operation_code,
	  x_Qte_Header_Rec     => x_Qte_Header_Rec,
	  x_return_status      => x_return_status,
	  x_msg_count          => x_msg_count,
	  x_msg_data           => x_msg_data);

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('return ASO_NETWORK_UI_PVT.Aso_Config_Operations '||X_Return_Status);
       aso_debug_pub.add('ASO_NETWORK_UI_PVT.Aso_Config_Operations END');
    END IF;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
  );
  END IF;

  FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );
END Aso_Config_Operations;

PROCEDURE Aso_Get_config_details(
    P_Api_Version_Number         IN   NUMBER    := FND_API.G_MISS_NUM,
    P_Init_Msg_List              IN   VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2  := FND_API.G_FALSE,
    p_control_rec                IN   aso_quote_pub.control_rec_type := aso_quote_pub.G_MISS_control_rec,
    p_config_rec                 IN   aso_quote_pub.qte_line_dtl_rec_type,
    p_model_line_rec             IN   aso_quote_pub.qte_line_rec_type,
    p_config_hdr_id              IN   NUMBER ,
    p_config_rev_nbr             IN   NUMBER,
    p_qte_header_rec             IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    x_return_status              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    x_msg_count                  OUT NOCOPY /* file.sql.39 change */  NUMBER,
    x_msg_data                   OUT NOCOPY /* file.sql.39 change */  VARCHAR2) IS

    l_api_name               CONSTANT VARCHAR2(30) := 'aso_get_config_details';

BEGIN
    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('Call to Aso_Get_Config_Details');
    END IF;

    ASO_CFG_INT.Get_Config_Details(
      p_api_version_number 	=> p_api_version_number,
      p_init_msg_list 		=> p_init_msg_list,
      p_commit 		        => p_commit,
      p_control_rec		=> p_control_rec,
      p_config_rec 	        => p_config_rec,
      p_model_line_rec 		=> p_model_line_rec,
      p_config_hdr_id 		=> p_config_hdr_id,
      p_config_rev_nbr  	=> p_config_rev_nbr,
      p_qte_header_rec		=> p_qte_header_rec,
      x_return_status 		=> x_return_status,
      x_msg_count  	        => x_msg_count,
      x_msg_data    		=> x_msg_data
   );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
       aso_debug_pub.add('x_return_status, ASO Get_Config_Details '||x_return_status);
       aso_debug_pub.add('Aso_get_config_details END');
   END IF;


  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
   );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(
        G_PKG_NAME,
        l_api_name
  );
  END IF;

  FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );

END Aso_Get_config_details;

End ASO_NETWORK_UI_PVT;


/
