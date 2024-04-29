--------------------------------------------------------
--  DDL for Package Body ASO_VALIDATE_CFG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_VALIDATE_CFG_PVT" as
/* $Header: asovcfgb.pls 120.0.12010000.4 2015/08/17 07:58:25 rassharm noship $ */

 G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_VALIDATE_CFG_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovcfgb.pls';


 /*----------------------------------------------------------------------
PROCEDURE      : Validate_configuration
Description    : Checks if the configuration is complete and valid.
                 Returns success/error as status. It calls
                 Create_header_xml     : To create the CZ batch validation header xml message
                 ASO_CFG_INT.Send_input_xml     : Sends the xml message created by Create_header_xml to the
                                      CZ configurator along with a pl/sql table which has options
                                      that are updated and deleted from the model.
                 ASO_CFG_INT.Parse_output_xml   : parses the CZ output xml message to see if the configuration
                                      is valid and complete.
                 ASO_CFG_INT.Get_config_details : To save options along with the model line in ASO_QUOTE_LINES_ALL
                                      , ASO_QUOTE_LINE_DETAILS and ASO_LINE_RELATIONSHIPS
-----------------------------------------------------------------------*/

PROCEDURE Validate_Configuration
    (P_Api_Version_Number              IN             NUMBER ,
     P_Init_Msg_List                   IN             VARCHAR2  := FND_API.G_FALSE,
     P_Commit                          IN             VARCHAR2  := FND_API.G_FALSE,
     p_control_rec                     IN             aso_quote_pub.control_rec_type
                                                      := aso_quote_pub.G_MISS_control_rec,
     P_model_line_id                   IN             NUMBER,
     P_Qte_Line_Tbl                    IN             ASO_QUOTE_PUB.Qte_Line_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL,
     P_Qte_Line_Dtl_Tbl	              IN             ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
    					                             := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL,
    P_UPDATE_QUOTE                   IN   VARCHAR2     := FND_API.G_FALSE,
     P_EFFECTIVE_DATE		     IN   Date  := FND_API.G_MISS_DATE,
    P_model_lookup_DATE   IN   Date  := FND_API.G_MISS_DATE,
     X_config_header_id               OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_config_revision_num            OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_valid_configuration_flag       OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_complete_configuration_flag    OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
      X_config_changed                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_return_status                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
     X_msg_count                      OUT NOCOPY /* file.sql.39 change */       NUMBER,
     X_msg_data                       OUT NOCOPY /* file.sql.39 change */       VARCHAR2
     )
IS
  l_api_name             CONSTANT VARCHAR2(30) := 'Validate_Configuration' ;
  l_api_version_number   CONSTANT NUMBER       := 1.0;

  l_model_line_id          NUMBER := p_model_line_id;
  l_qte_header_rec         aso_quote_pub.qte_header_rec_type  := aso_quote_pub.g_miss_qte_header_rec;
  l_model_line_rec         ASO_QUOTE_PUB.Qte_Line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
  l_model_line_dtl_tbl     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_DTL_TBL;

  l_config_header_id       NUMBER;
  l_config_revision_num    NUMBER;
  l_valid_configuration_flag    VARCHAR2(1);
  l_complete_configuration_flag VARCHAR2(1);
  l_config_changed_flag              VARCHAR2(1);
  --l_model_qty              NUMBER;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_result_out             VARCHAR2(30);

  -- input xml message
  l_xml_message            LONG   := NULL;
  l_xml_hdr                VARCHAR2(2000);

  -- upgrade stuff
  l_upgraded_flag          VARCHAR2(1);

  -- cz's delete return value
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_delete_config      VARCHAR2(1) := fnd_api.g_false;
  l_old_config_hdr_id  NUMBER;
   l_new_config_hdr_id number;

  CURSOR c_config_exist_in_cz (p_config_hdr_id number, p_config_rev_nbr number) IS
    select config_hdr_id
    from cz_config_details_v
    where config_hdr_id = p_config_hdr_id
    and config_rev_nbr = p_config_rev_nbr;

BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('ASO_VALIDATE_CFG_PVT: Validate_Configuration Begins', 1, 'Y');
    END IF;

     IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
		 		                         p_api_version_number,
					                     l_api_name,
					                     G_PKG_NAME) THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.to_Boolean( p_init_msg_list ) THEN
	     FND_MSG_PUB.initialize;
    END IF;

    -- Get model line info
    l_model_line_rec := ASO_UTILITY_PVT.Query_Qte_Line_Row(p_model_line_id);
    l_model_line_dtl_tbl := ASO_UTILITY_PVT.Query_Line_Dtl_Rows(p_model_line_id);

    -- Call Create_header_xml to create the input header XML message
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Validate_Configuration: Before call to Create_header_xml.');
	aso_debug_pub.add('Validate_Configuration: Before call to Create_header_xml. P_EFFECTIVE_DATE'||P_EFFECTIVE_DATE);
	aso_debug_pub.add('Validate_Configuration: Before call to Create_header_xml. P_model_lookup_DATE'||P_model_lookup_DATE);
    END IF;

--  dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT before create header xml');
  /*aso_cfg_int.create_hdr_xml(P_model_line_id   =>  P_model_line_id,
                                                       X_xml_hdr         =>  l_xml_hdr,
                                                          X_return_status   =>  l_return_status );*/
   Create_header_xml ( P_model_line_id   =>  P_model_line_id,
                                           P_EFFECTIVE_DATE	=> 	P_EFFECTIVE_DATE,
    				           P_model_lookup_DATE =>    P_model_lookup_DATE,
                      X_xml_hdr         =>  l_xml_hdr,
                     X_return_status   =>  l_return_status );

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('Validate_Configuration: After call to Create_header_xml l_return_status: '||l_return_status);
        aso_debug_pub.add('Validate_Configuration: After call to Create_header_xml Length of l_xml_hdr : '||length(l_xml_hdr));
        --aso_debug_pub.add('ASO_CFG_INT: Validate_Configuration: Before call to Send_input_xml'||l_xml_hdr);
    END IF;

--    dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT before send input  xml'||l_return_status);
--    dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT before send input  xml'||l_xml_hdr);

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- Call Send_Input_Xml to call CZ batch validate procedure and get the output XML message

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('ASO_CFG_INT: Validate_Configuration: Before call to Send_input_xml');
        END IF;

       ASO_CFG_INT.Send_input_xml( P_Qte_Line_Tbl      =>  P_Qte_Line_Tbl,
                        P_Qte_Line_Dtl_Tbl  =>  P_Qte_Line_Dtl_Tbl,
                        P_xml_hdr           =>  l_xml_hdr,
                        X_out_xml_msg       =>  l_xml_message,
                        X_config_changed     =>   l_config_changed_flag,
                        X_return_status     =>  l_return_status,
                        X_msg_count         =>  l_msg_count,
                        X_msg_data          =>  l_msg_data
                      );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After call to Send_input_xml');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
        END IF;

--dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT after send input xml'||l_return_status);
--dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT after send input xml'||l_config_changed_flag);

        -- extract data from xml message.

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      l_delete_config := fnd_api.g_true;
        END IF;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
		  aso_debug_pub.add('Validate_Configuration: Before Call to Parse_Output_xml',1,'N');
            aso_debug_pub.add('Validate_Configuration: l_delete_config: '||l_delete_config);
        END IF;

--dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT before parse header xml'||l_return_status);

        ASO_CFG_INT.Parse_output_xml
                   (  p_xml_msg                      => l_xml_message,
                      x_valid_configuration_flag     => l_valid_configuration_flag,
                      x_complete_configuration_flag  => l_complete_configuration_flag,
                      x_config_header_id             => l_config_header_id,
                      x_config_revision_num          => l_config_revision_num,
                      x_return_status                => l_return_status,
                      x_msg_count                    => l_msg_count,
                      x_msg_data                     => l_msg_data
                   );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After call to Parse_output_xml');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
        END IF;

    END IF;
--dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT after  parse header xml'||l_return_status);

       IF ((l_return_status =FND_API.G_RET_STS_SUCCESS) and (p_update_quote=fnd_api.g_false) and (l_delete_config=fnd_api.g_false))THEN

             --dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT p_update_quote is false');
               open c_config_exist_in_cz(l_config_header_id, l_config_revision_num);
               fetch c_config_exist_in_cz into l_new_config_hdr_id;

               if c_config_exist_in_cz%found then

                   close c_config_exist_in_cz;

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Update Quote: A higher version exist for this configuration so deleting it from CZ');
                   END IF;

                   ASO_CFG_INT.DELETE_CONFIGURATION_AUTO( P_API_VERSION_NUMBER  => 1.0,
                                                          P_INIT_MSG_LIST       => FND_API.G_FALSE,
                                                          P_CONFIG_HDR_ID       => l_config_header_id,
                                                          P_CONFIG_REV_NBR      => l_config_revision_num,
                                                          X_RETURN_STATUS       => x_return_status,
                                                          X_MSG_COUNT           => x_msg_count,
                                                          X_MSG_DATA            => x_msg_data);

                   IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('After call to ASO_CFG_INT.DELETE_CONFIGURATION_AUTO: x_Return_Status: ' || x_Return_Status);
                   END IF;

                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                          FND_MESSAGE.Set_Name('ASO', 'ASO_DELETE');
                          FND_MESSAGE.Set_Token('OBJECT', 'CONFIGURATION', FALSE);
                          FND_MSG_PUB.ADD;
                       END IF;

                       RAISE FND_API.G_EXC_ERROR;

                   END IF;

               else
                   close c_config_exist_in_cz;
               end if;

          -- END IF;

    elsif (l_return_status = FND_API.G_RET_STS_SUCCESS) and (l_delete_config = fnd_api.g_false) and (p_update_quote = fnd_api.g_true)THEN

        -- Call GET_CONFIG_DETAILS to update the existing configuration
        -- Set the Call_batch_validation_flag to FND_API.G_FALSE to avoid recursive call to update_quote
        --dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT p_update_quote is true');
        l_model_line_dtl_tbl(1).valid_configuration_flag    := l_valid_configuration_flag;
        l_model_line_dtl_tbl(1).complete_configuration_flag := l_complete_configuration_flag;

	   l_qte_header_rec.quote_header_id  :=  l_model_line_rec.quote_header_id;


	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: Before Call to ASO_CFG_INT.Get_config_details');
        END IF;

        ASO_CFG_INT.Get_config_details(
              p_api_version_number         => 1.0,
              p_init_msg_list              => FND_API.G_FALSE,
              p_commit                     => FND_API.G_FALSE,
              p_control_rec                => p_control_rec,
		    p_qte_header_rec             => l_qte_header_rec,
              p_model_line_rec             => l_model_line_rec,
              p_config_rec                 => l_model_line_dtl_tbl(1),
              p_config_hdr_id              => l_config_header_id,
              p_config_rev_nbr             => l_config_revision_num,
              x_return_status              => l_return_status,
              x_msg_count                  => l_msg_count,
              x_msg_data                   => l_msg_data );

	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: After Call to Get_config_details');
            aso_debug_pub.add('Validate_Configuration: l_return_status: '||l_return_status);
	   END IF;

    ELSE
          --dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT l_delete_config is true');
	   l_delete_config := fnd_api.g_true;
	   IF aso_debug_pub.g_debug_flag = 'Y' THEN
            aso_debug_pub.add('Validate_Configuration: l_delete_config: '||l_delete_config);
	   END IF;

    END IF;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN

        aso_debug_pub.add('End of procedure Validate_Configuration');
        aso_debug_pub.add('l_return_status:               '|| l_return_status);
        aso_debug_pub.add('l_valid_configuration_flag:    '|| l_valid_configuration_flag);
        aso_debug_pub.add('l_complete_configuration_flag: '|| l_complete_configuration_flag);
        aso_debug_pub.add('l_config_changed_flag: '|| l_config_changed_flag);
    END IF;

    x_config_header_id             := l_config_header_id;
    x_config_revision_num          := l_config_revision_num;
    x_valid_configuration_flag     := l_valid_configuration_flag;
    x_complete_configuration_flag  := l_complete_configuration_flag;
    X_config_changed                        := l_config_changed_flag;
    x_return_status                := l_return_status;
    x_msg_count                    := l_msg_count;
    x_msg_data                     := l_msg_data;

    if l_delete_config = fnd_api.g_true then

         x_return_status := FND_API.G_RET_STS_ERROR;

    end if;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('End of Validate_Configuration', 1, 'N');
    END IF;

    EXCEPTION

       WHEN OTHERS THEN

		  IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Validate_Configuration: Inside WHEN OTHERS EXCEPTION', 1, 'Y');
		  END IF;

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Configuration;

/*-------------------------------------------------------------------------
Procedure Name : Create_header_xml
Description    : creates a batch validation header message with effective dates
--------------------------------------------------------------------------*/

PROCEDURE Create_header_xml
( p_model_line_id       IN       NUMBER,
P_EFFECTIVE_DATE		     IN   Date  := FND_API.G_MISS_DATE,
 P_model_lookup_DATE   IN   Date  := FND_API.G_MISS_DATE,
  x_xml_hdr             OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
  x_return_status       OUT NOCOPY /* file.sql.39 change */      VARCHAR2 )
IS

      Cursor C_org_id (p_quote_header_id NUMBER) is
      select org_id from aso_quote_headers_all
      where quote_header_id = p_quote_header_id;

      Cursor c_inv_org_id (p_quote_line_id NUMBER) is
	 select organization_id from aso_quote_lines_all
	 where quote_line_id = p_quote_line_id;

      TYPE param_name_type IS TABLE OF VARCHAR2(25)
      INDEX BY BINARY_INTEGER;

      TYPE param_value_type IS TABLE OF VARCHAR2(255)
      INDEX BY BINARY_INTEGER;

      param_name  param_name_type;
      param_value param_value_type;

      l_rec_index BINARY_INTEGER;

      l_model_line_rec                  ASO_QUOTE_PUB.Qte_Line_Rec_Type;
      l_model_line_dtl_tbl              ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;
      l_org_id                          NUMBER;

      --Configurator specific params
      l_calling_application_id          VARCHAR2(30);
      l_responsibility_id               VARCHAR2(30);
      l_database_id                     VARCHAR2(255);
      l_read_only                       VARCHAR2(30)   :=  null;
      l_save_config_behavior            VARCHAR2(30)   :=  'new_revision';
      l_ui_type                         VARCHAR2(30)   :=  null;
      l_msg_behavior                    VARCHAR2(30)   :=  'brief';
      l_icx_session_ticket              VARCHAR2(200);

      --Order Capture specific parameters
      l_context_org_id                  VARCHAR2(30);
      l_config_creation_date            VARCHAR2(30);
      l_inventory_item_id               VARCHAR2(30);
      l_config_header_id                VARCHAR2(30);
      l_config_rev_nbr                  VARCHAR2(30);
      l_model_quantity                  VARCHAR2(30);
      l_count                           NUMBER;
      --l_validation_org_id             NUMBER;

      --message related
      l_xml_hdr                         VARCHAR2(2000):= '<initialize>';
      l_dummy                           VARCHAR2(500) := NULL;


      -- ER  ER 3177722
      l_config_effective_date_prof   VARCHAR2(1):=nvl(fnd_profile.value('ASO_CONFIG_EFFECTIVE_DATE'),'X');
      l_current_date                              VARCHAR2(30);
      l_effective_date                            DATE;   -- bug 20752067
      x_config_effective_date             DATE;
      x_config_lookup_date               DATE;

  BEGIN
	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('ASO_VALIDATE_CFG_PVT Create_header_xml Begins.', 1, 'Y');
      END IF;

     --dbms_output.put_line('Entered ASO_VALIDATE_CFG_PVT rassharm create header xml');
      --Initialize API return status to SUCCESS
      x_return_status  := FND_API.G_RET_STS_SUCCESS;

      l_model_line_rec := aso_utility_pvt.Query_Qte_Line_Row( P_Qte_Line_Id  => p_model_line_id );

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_header_xml: After call to aso_utility_pvt.Query_Qte_Line_Row');
      END IF;

      l_model_line_dtl_tbl := aso_utility_pvt.Query_Line_Dtl_Rows( P_Qte_Line_Id => p_model_line_id );

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_header_xml: After call to aso_utility_pvt.Query_Line_Dtl_Rows');
      END IF;

      /*  Fix for bug 3998564 */
      --OPEN  C_org_id( l_model_line_rec.quote_header_id);
      --FETCH C_org_id INTO l_org_id;
      --CLOSE C_org_id;
        OPEN  c_inv_org_id( l_model_line_rec.quote_line_id);
	   FETCH c_inv_org_id INTO l_org_id;
	   CLOSE c_inv_org_id;
      /* End of fix for bug 3998564 */

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_header_xml: After C_org_id cursor: l_org_id: '|| l_org_id, 1, 'N');
      END IF;

      IF l_org_id IS NULL THEN

       --Commented Code Start Yogeshwar(MOAC)
         /* IF SUBSTRB(USERENV('CLIENT_INFO'),1 ,1) = ' ' THEN
              l_org_id := NULL;
          ELSE
              l_org_id := TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1,10));
          END IF;
         */
       --Commented Code End Yogeshwar (MOAC)

        L_org_id := l_model_line_rec.org_id;   --New Code Yogeshwar MOAC

      END IF;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('Create_header_xml: After Defaulting from client info. l_org_id: '|| l_org_id);
      END IF;

      --Set the values from model_line_rec, model_line_dtl_tbl and org_id
      l_context_org_id        := to_char(l_org_id);
      l_inventory_item_id     := to_char(l_model_line_rec.inventory_item_id);

      /* Added by Arul */

      If l_model_line_dtl_tbl.count = 0 then
         l_config_header_id      := NULL;
         l_config_rev_nbr        := NULL;
      Else
         l_config_header_id      := to_char(l_model_line_dtl_tbl(1).config_header_id);
         l_config_rev_nbr        := to_char(l_model_line_dtl_tbl(1).config_revision_num);
      End if;
/* End Added by Arul */

--      l_config_header_id      := to_char(l_model_line_dtl_tbl(1).config_header_id);
--      l_config_rev_nbr        := to_char(l_model_line_dtl_tbl(1).config_revision_num);
      l_config_creation_date  := to_char(l_model_line_rec.creation_date,'MM-DD-YYYY-HH24-MI-SS');
      l_model_quantity        := to_char(l_model_line_rec.quantity);
      l_current_date:=  to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_header_xml: l_context_org_id      :' || l_context_org_id);
          aso_debug_pub.add('Create_header_xml: l_inventory_item_id   :' || l_inventory_item_id);
          aso_debug_pub.add('Create_header_xml: l_config_header_id    :' || l_config_header_id);
          aso_debug_pub.add('Create_header_xml: l_config_rev_nbr      :' || l_config_rev_nbr);
          aso_debug_pub.add('Create_header_xml: l_config_creation_date:' || l_config_creation_date);
          aso_debug_pub.add('Create_header_xml: l_model_quantity      :' || l_model_quantity);
	  aso_debug_pub.add('Create_header_xml: l_current_date:' || l_current_date);

      END IF;

      -- Set values from profiles and env. variables.
      l_calling_application_id := fnd_global.resp_appl_id;
      l_responsibility_id      :=  fnd_global.resp_id;
      l_database_id            := fnd_web_config.database_id;
      l_icx_session_ticket     := cz_cf_api.icx_session_ticket;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_header_xml: l_calling_application_id:' || l_calling_application_id);
          aso_debug_pub.add('Create_header_xml: l_responsibility_id     :' || l_responsibility_id);
          aso_debug_pub.add('Create_header_xml: l_database_id           :' || l_database_id);
          aso_debug_pub.add('Create_header_xml: l_icx_session_ticket    :' || l_icx_session_ticket);
	   aso_debug_pub.add('Create_header_xml:  profile value:'|| l_config_effective_date_prof);

      END IF;

      -- set param_names
      param_name(1)  := 'database_id';
      param_name(2)  := 'context_org_id';
      param_name(3)  := 'config_creation_date';
      param_name(4)  := 'calling_application_id';
      param_name(5)  := 'responsibility_id';
      param_name(6)  := 'model_id';
      param_name(7)  := 'config_header_id';
      param_name(8)  := 'config_rev_nbr';
      param_name(9)  := 'read_only';
      param_name(10) := 'save_config_behavior';
      --param_name(11) := 'ui_type';
      --param_name(12) := 'validation_org_id';
      param_name(11) := 'terminate_msg_behavior';
      param_name(12) := 'model_quantity';
      param_name(13) := 'icx_session_ticket';

      -- Added extra parameters for config effective and lookup date ER 3177722
      param_name(14) := 'config_effective_date';
      param_name(15) := 'config_model_lookup_date';
      l_count := 15;
      --l_count := 13;

      -- set parameter values

      param_value(1)  := l_database_id;
      param_value(2)  := l_context_org_id;
      param_value(3)  := l_config_creation_date;
      param_value(4)  := l_calling_application_id;
      param_value(5)  := l_responsibility_id;
      param_value(6)  := l_inventory_item_id;
      param_value(7)  := l_config_header_id;
      param_value(8)  := l_config_rev_nbr;
      param_value(9)  := l_read_only;
      param_value(10) := l_save_config_behavior;
      --param_value(11) := l_ui_type;
      --param_value(12) := l_validation_org_id;
      param_value(11) := l_msg_behavior;
      param_value(12) := l_model_quantity;
      param_value(13) := l_icx_session_ticket;

      if (p_effective_date<>fnd_API.G_MISS_DATE) then
         aso_debug_pub.add('Create_header_xml: Effective date provided ');
         param_value(14) := to_char(p_effective_date,'MM-DD-YYYY-HH24-MI-SS');
         param_value(15) :=to_char(P_model_lookup_DATE,'MM-DD-YYYY-HH24-MI-SS');
    else
     aso_debug_pub.add('Create_header_xml: Effective date not provided, use profile instead ');
     -- Added extra parameters for config effective and lookup date ER 3177722 and setting the value based on new profile ASO : Configuration Effective Date
     if  l_config_effective_date_prof='C' then  -- set to creation date
          param_value(14) := l_config_creation_date;
          param_value(15) := l_config_creation_date;
      elsif   l_config_effective_date_prof='S'  then  -- set to current date
           param_value(14) :=  to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');
           param_value(15) := to_char(sysdate,'MM-DD-YYYY-HH24-MI-SS');
     elsif  l_config_effective_date_prof='F'  then  -- set to callback function Add code for callback function
          ASO_QUOTE_HOOK.Get_Model_Configuration_Date
	  ( p_quote_header_id=>l_model_line_rec.quote_header_id,
	    P_QUOTE_LINE_ID=> l_model_line_rec.quote_line_id,
	    X_CONFIG_EFFECTIVE_DATE=> x_config_effective_date,
           X_CONFIG_MODEL_LOOKUP_DATE=> x_config_lookup_date
	  );
	    param_value(14) := to_char(x_config_effective_date,'MM-DD-YYYY-HH24-MI-SS');
           param_value(15) := to_char(x_config_lookup_date,'MM-DD-YYYY-HH24-MI-SS');

      elsif  l_config_effective_date_prof='E'  then -- bug 20752067
       BEGIN
	select effective_date into l_effective_date
	from cz_config_hdrs
	where config_hdr_id=l_config_header_id
	and config_rev_nbr = l_config_rev_nbr;

	Exception
	when no_data_found then
		IF aso_debug_pub.g_debug_flag = 'Y' THEN
		aso_debug_pub.add('In ASO_VALIDATE_CFG_PVT: Create_hdr_xml l_effective_date Exception block no_data_found ');

		END IF;
       When others then
          IF aso_debug_pub.g_debug_flag = 'Y' THEN
	  aso_debug_pub.add('In ASO_VALIDATE_CFG_PVT: Create_hdr_xml l_effective_date Exception block OTHERS ');

	END IF;
       END;


	IF aso_debug_pub.g_debug_flag = 'Y' THEN
         aso_debug_pub.add('In ASO_VALIDATE_CFG_PVT: Create_hdr_xml l_effective_date:  '|| l_effective_date);
	END IF;

 -- bug 21578214, added date format
	 param_value(14) := to_char(l_effective_date,'MM-DD-YYYY-HH24-MI-SS');
         param_value(15) := to_char(l_effective_date,'MM-DD-YYYY-HH24-MI-SS');


      else  -- profile not set
          param_value(14) := null;
          param_value(15) := null;
      end if;
  end if; --  p_effective_date

      l_rec_index := 1;
     --  aso_debug_pub.add('Create_header_xml: before forming xml loop ');
      LOOP
         -- ex : <param name="config_header_id">1890</param>

         IF (param_value(l_rec_index) IS NOT NULL) THEN

             l_dummy :=  '<param name=' ||
                         '"' || param_name(l_rec_index) || '"'
                         ||'>'|| param_value(l_rec_index) ||
                         '</param>';
        --   aso_debug_pub.add('Create_header_xml: before forming xml loop '||length(l_dummy));
         -- aso_debug_pub.add('Create_header_xml: before forming xml loop '||l_dummy);
         --aso_debug_pub.add('Create_header_xml: before forming xml loop '||length(l_xml_hdr));
             l_xml_hdr := l_xml_hdr || l_dummy;

          END IF;

          l_dummy := NULL;

          l_rec_index := l_rec_index + 1;
          EXIT WHEN l_rec_index > l_count;

      END LOOP;

      -- add termination tags

      l_xml_hdr := l_xml_hdr || '</initialize>';
      l_xml_hdr := REPLACE(l_xml_hdr, ' ' , '+');

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN

          aso_debug_pub.add('Create_header_xml: Length of l_xml_hdr mesg: '||length(l_xml_hdr));
          aso_debug_pub.add('Create_header_xml: 1st Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr,   1, 100));
          aso_debug_pub.add('Create_header_xml: 2nd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 101, 100));
          aso_debug_pub.add('Create_header_xml: 3rd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 201, 100));
          aso_debug_pub.add('Create_header_xml: 4th Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 301, 100));
          aso_debug_pub.add('Create_header_xml: 5st Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 401, 100));
          aso_debug_pub.add('Create_header_xml: 6nd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 501, 100));
          aso_debug_pub.add('Create_header_xml: 7rd Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 601, 100));
          aso_debug_pub.add('Create_header_xml: 8th Part of l_xml_hdr is: '||SUBSTR(l_xml_hdr, 701, 100));

      END IF;

      x_xml_hdr := l_xml_hdr;

	 IF aso_debug_pub.g_debug_flag = 'Y' THEN
          aso_debug_pub.add('End of Create_header_xml.', 1, 'Y');
      END IF;


      EXCEPTION

          when others then

              x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;

              IF aso_debug_pub.g_debug_flag = 'Y' THEN
                  aso_debug_pub.add('Create_header_xml: Inside When Others Exception: x_return_status: '||x_return_status, 1, 'N');
              END IF;

END Create_header_xml;



end ASO_VALIDATE_CFG_PVT;

/
