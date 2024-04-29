--------------------------------------------------------
--  DDL for Package Body ASO_CONFIG_OPERATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CONFIG_OPERATIONS_PVT" as
/* $Header: asovcfob.pls 120.6 2006/11/02 23:51:49 skulkarn ship $ */

G_PKG_NAME CONSTANT     VARCHAR2(30) := 'ASO_CONFIG_OPERATIONS_PVT';

PROCEDURE Add_to_Container_from_IB(
   	P_Api_Version_Number  	IN	NUMBER,
    P_Init_Msg_List   		IN	VARCHAR2 := FND_API.G_FALSE,
    P_Commit    		    IN	VARCHAR2 := FND_API.G_FALSE,
   	p_validation_level   	IN	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    P_Control_Rec  		    IN	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
    P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Quote_line_Id		    IN	NUMBER,
    P_instance_tbl          IN	ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
    x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)is

/******************************************************************************
Cursor to retrieve Config header Id and Config rev number for a given instance
*******************************************************************************/

Cursor  c_item_csr(p_instance_id Number) is
Select config_inst_hdr_id,config_inst_rev_num
from csi_item_instances
where instance_id = p_instance_id;

/****************************************************************
Cursor to find item details from Quote line containing Model Item
****************************************************************/

Cursor c_mdl_item_details_csr(p_quote_line_id Number) is
Select a.quote_header_id, a.uom_code, a.quantity, a.inventory_item_id, a.organization_id
from
ASO_QUOTE_LINES_ALL a
where a.quote_line_id = p_quote_line_id;

/***************************************************************************************
Cursor to find  complete configuration and valid configuration info from CZ_CONFIG_HDRS
*****************************************************************************************/
Cursor c_configuration_details_csr(p_config_header_id Number,p_config_rev_number Number) is
Select Decode (has_failures,'0','Y','N'), decode (config_status,'2','Y','N')
from CZ_CONFIG_HDRS
where config_hdr_id = p_config_header_id
and config_rev_nbr = p_config_rev_number;

 Cursor c_last_update_date_csr(p_qte_header_id Number) is
 SELECT last_update_date
 FROM ASO_QUOTE_HEADERS_ALL
 WHERE quote_header_id = p_qte_header_id;



l_api_name               CONSTANT VARCHAR2(30) := 'Add_to_Container_from_IB';
l_api_version	         CONSTANT NUMBER := 1.0;
l_ins_config_hdr_tbl   CZ_API_PUB.CONFIG_TBL_TYPE;
l_hdr_id Number;
l_rev_nbr Number;
l_complete_configuration_flag VARCHAR2(1);
l_valid_configuration_flag  VARCHAR2(1);
l_config_hdr_id Number;
l_config_rev_nbr  Number;
l_quote_header_id Number;
l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;
l_config_rec aso_quote_pub.qte_line_dtl_rec_type;
l_model_line_rec aso_quote_pub.qte_line_rec_type;
lx_config_tree_rec CZ_API_PUB.config_model_rec_type;
l_last_update_date Date;
l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;

Begin

     SAVEPOINT Add_to_Container_from_ib_pvt;

        -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version_Number,
					l_api_name,
					G_PKG_NAME )
     THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
	 IF FND_API.to_Boolean( p_init_msg_list ) THEN
		   FND_MSG_PUB.initialize;
	 END IF;


     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/**************************************************************
 Create Config Instance header table
**************************************************************/
For  i  IN 1.. P_Instance_tbl.count Loop
	For c_item_rec  IN c_item_csr(P_Instance_tbl(i).instance_id) LOOP

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Add_to_Container_from_IB:Config Header Id:'||c_item_rec.config_inst_hdr_id,1,'N');
      aso_debug_pub.add('Add_to_Container_from_IB:Config Rev Num:'||c_item_rec.config_inst_rev_num,1,'N');
    END IF;

		l_ins_config_hdr_tbl(i).config_hdr_id := c_item_rec.config_inst_hdr_id;
		l_ins_config_hdr_tbl(i).config_rev_nbr:= c_item_rec.config_inst_rev_num;
	END LOOP;
END LOOP;

/*******************************************************************
Find Config Header Id and Config rev number for the container model
********************************************************************/
Begin
Select a. config_header_id , a.config_revision_num
into l_hdr_id , l_rev_nbr
from
ASO_QUOTE_LINE_DETAILS a
where a.quote_line_id = p_quote_line_id;

Exception
WHEN NO_DATA_FOUND then
l_hdr_id := null;
l_rev_nbr:= null;
end;

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Add_to_Container_from_IB: Config Header Id:'||l_hdr_id,1,'N');
   aso_debug_pub.add('Add_to_Container_from_IB: Config Rev Number:'||l_rev_nbr,1,'N');
END IF;

/**************************************************************
Find item details from Quote line containing Model Item
***************************************************************/

For c_mdl_item_details_rec  IN c_mdl_item_details_csr(p_quote_line_id) LOOP

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_to_Container_from_IB:Inventory Item Id:'||c_mdl_item_details_rec.inventory_item_id,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Organization Id'||c_mdl_item_details_rec.organization_id,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Quantity:'||c_mdl_item_details_rec.quantity,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:UOM Code:'||c_mdl_item_details_rec.uom_code,1,'N');
END IF;

/**************************************************************
Create Applicability parameter record
***************************************************************/
--l_appl_param_rec.calling_application_id:= fnd_profile.value('JTF_PROFILE_DEFAULT_APPLICATION');


l_appl_param_rec.calling_application_id:= fnd_global.RESP_APPL_ID;
/**************************************************************
Add Instances to container model
**************************************************************/
if l_hdr_id is not null then

CZ_NETWORK_API_PUB.ADD_TO_CONFIG_TREE(
		p_api_version	    =>	1.0,
        p_inventory_item_id =>	c_mdl_item_details_rec.inventory_item_id,
        p_organization_id	=>	c_mdl_item_details_rec.organization_id,
        p_config_hdr_id 	=> 	l_hdr_id,
        p_config_rev_nbr	=>	l_rev_nbr,
        p_instance_tbl 	    =>	l_ins_config_hdr_tbl,
        p_tree_copy_mode	=>	'R',
		p_appl_param_rec	=>	l_appl_param_rec,
		p_validation_context=>	CZ_API_PUB.G_INSTALLED,
        x_config_model_rec	=>	lx_config_tree_rec,
        x_return_status	    =>	x_return_status,
        x_msg_count	        =>	x_msg_count,
        x_msg_data	        =>	x_msg_data);

  else

/**************************************************************
CZ call using model id  and  Instance header Ids
**************************************************************/

CZ_NETWORK_API_PUB.ADD_TO_CONFIG_TREE(
		p_api_version	    =>	1.0,
        p_inventory_item_id =>	c_mdl_item_details_rec.inventory_item_id,
        p_organization_id	=>	c_mdl_item_details_rec.organization_id,
        p_config_hdr_id 	=> 	null,
        p_config_rev_nbr	=>	null,
        p_instance_tbl 	    =>	l_ins_config_hdr_tbl,
        p_tree_copy_mode	=>	'R',
		p_appl_param_rec	=>	l_appl_param_rec,
		p_validation_context=>	CZ_API_PUB.G_INSTALLED,
        x_config_model_rec	=>	lx_config_tree_rec,
        x_return_status	    =>	x_return_status,
        x_msg_count	        =>	x_msg_count,
        x_msg_data	        =>	x_msg_data);

end if;

IF aso_debug_pub.g_debug_flag = 'Y' THEN

aso_debug_pub.add('Add_to_Container_from_IB:Add_to_config_tree:Return status:'||x_return_status,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Add_to_config_tree:Msg count:'||x_msg_count,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Add_to_config_tree:Config Header Id:'||lx_config_tree_rec.config_hdr_id,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Add_to_config_tree:Config Rev Number:'||lx_config_tree_rec.config_rev_nbr,1,'N');

END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/****************************************************************************
Get complete configuration and valid configuration info from CZ_CONFIG_HDRS
****************************************************************************/
Open c_configuration_details_csr(lx_config_tree_rec.config_hdr_id,lx_config_tree_rec.config_rev_nbr);

     fetch c_configuration_details_csr into l_valid_configuration_flag,l_complete_configuration_flag;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Add_to_Container_from_IB:Config Valid Info:'||l_complete_configuration_flag,1,'N');
     aso_debug_pub.add('Add_to_Container_from_IB:Config Complete Info:'||l_valid_configuration_flag,1,'N');
	END IF;

            IF c_configuration_details_csr%NOTFOUND THEN
                     CLOSE c_configuration_details_csr;
			         x_return_status := FND_API.G_RET_STS_ERROR;
        		          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               			      FND_MESSAGE.Set_Name('ASO', 'ASO_CFG_DETAILS_NOT_FOUND');
               			      FND_MSG_PUB.Add;
        		          END IF;
       		 	     raise FND_API.G_EXC_ERROR;
            END IF;

     Close c_configuration_details_csr;

/**************************************************************
Copy  config data from CZ_CONFIG_DETAILS_V
***************************************************************/

l_config_rec.quote_line_id := p_quote_line_id;
l_config_rec.complete_configuration_flag := l_complete_configuration_flag;
l_config_rec.valid_configuration_flag := l_valid_configuration_flag;
l_config_rec.config_header_id := l_hdr_id;
l_config_rec.config_revision_num := l_rev_nbr;

l_model_line_rec.quote_line_id := p_quote_line_id;
l_model_line_rec.quantity := c_mdl_item_details_rec.quantity;
l_model_line_rec.uom_code := c_mdl_item_details_rec.uom_code;

l_config_hdr_id 	:= lx_config_tree_rec.config_hdr_id ;
l_config_rev_nbr 	:= lx_config_tree_rec.config_rev_nbr;

l_quote_header_id   := c_mdl_item_details_rec.quote_header_id;

   Open c_last_update_date_csr(P_QTE_HEADER_REC.quote_header_id);

     fetch c_last_update_date_csr into l_last_update_date;

     IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Add_to_Container_from_IB:Last Update date:'||l_last_update_date,1,'N');
     END IF;

            IF c_last_update_date_csr%NOTFOUND THEN
                CLOSE c_last_update_date_csr;
                    x_return_status := FND_API.G_RET_STS_ERROR;
                            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
                                    FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                                    FND_MSG_PUB.ADD;
                            END IF;
                 raise FND_API.G_EXC_ERROR;

            END IF;

   Close c_last_update_date_csr;

   l_qte_header_rec := p_qte_header_rec;

   l_QTE_HEADER_REC.last_update_date  := l_last_update_date;

ASO_CFG_PUB.Get_config_details(
    		P_Api_Version_Number    	=>1.0,
    		P_Init_Msg_List     		=> FND_API.g_false,
    		p_commit            		=> FND_API.g_false,
            p_control_rec		        => p_control_rec,
    		p_config_rec       		    => l_config_rec,
    		p_model_line_rec   		    => l_model_line_rec,
    		p_config_hdr_id     		=> l_config_hdr_id,
    		p_config_rev_nbr    		=> l_config_rev_nbr ,
    		p_qte_header_rec   		    => l_qte_header_rec,
    		x_return_status     		=> x_return_status ,
    		x_msg_count         		=> x_msg_count ,
    		x_msg_data          		=> x_msg_data
);


IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Add_to_Container_from_IB:Get_config_details:Return status:'||x_return_status,1,'N');
aso_debug_pub.add('Add_to_Container_from_IB:Get_config_details:Msg count:'||x_msg_count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

x_qte_header_rec    := ASO_UTILITY_PVT.Query_Header_Row(l_quote_header_id);

-- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('****** End of add to container API ******', 1, 'Y');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count    ,
        p_data    => x_msg_data
    );

END LOOP;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_SQLERRM  => sqlerrm
            ,P_SQLCODE  => sqlcode
            ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

END Add_to_Container_from_IB;


PROCEDURE Reconfigure_from_IB(
   	    P_Api_Version_Number  	IN	NUMBER,
    	P_Init_Msg_List   		IN	VARCHAR2  := FND_API.G_FALSE,
    	P_Commit    		    IN	VARCHAR2  := FND_API.G_FALSE,
   	    p_validation_level   	IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        P_Control_Rec  		    IN	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
        P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    	P_instance_tbl          IN	ASO_QUOTE_HEADERS_PVT.Instance_Tbl_Type,
        x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    	X_Return_Status   	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    	X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */ NUMBER,
    	X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)IS

/************************************************************************************
Cursor to retrieve config header Id and Config revision number  for a given instance
*************************************************************************************/

Cursor  c_item_csr(p_instance_id Number) is
Select config_inst_hdr_id , config_inst_rev_num from csi_item_instances
where instance_id = p_instance_id;

/************************************************************************************
Cursor to retrieve UOM and quantity for a config header Id and Config revision number
*************************************************************************************/

Cursor  c_uom_qty_csr(p_config_hdr_id Number,p_config_rev_nbr Number,p_config_item_id Number) is
Select  a.uom_code, a.quantity
from
cz_config_details_v a
where a.config_hdr_id =  p_config_hdr_id
and a.config_rev_nbr = p_config_rev_nbr
and a.config_item_id = p_config_item_id;

/***************************************************************************************
Cursor to find  complete configuration and valid configuration info from CZ_CONFIG_HDRS
*****************************************************************************************/
Cursor c_configuration_details_csr(p_config_header_id Number,p_config_rev_number Number) is
Select Decode (has_failures,'0','Y','N'), decode (config_status,'2','Y','N')
from CZ_CONFIG_HDRS
where config_hdr_id = p_config_header_id
and config_rev_nbr = p_config_rev_number;

/****************************************************************
Cursor to find item details from Quote line containing Model Item
****************************************************************/

Cursor c_mdl_item_details_csr(p_quote_line_id Number) is
Select a.quantity, a.uom_code
from aso_quote_lines_all a
where a.quote_line_id = p_quote_line_id;

/****************************************************************
Cursor to find last update date for quote
****************************************************************/

 Cursor c_last_update_date_csr(p_qte_header_id Number) is
 SELECT last_update_date
 FROM ASO_QUOTE_HEADERS_ALL
 WHERE quote_header_id = p_qte_header_id;

l_api_name               CONSTANT VARCHAR2(30) := 'Reconfigure_from_IB';
l_api_version	         CONSTANT NUMBER := 1.0;
l_ins_config_hdr_tbl   CZ_API_PUB.CONFIG_TBL_TYPE;
l_uom VARCHAR2(3);
l_quantity Number;
l_complete_configuration_flag VARCHAR2(1);
l_valid_configuration_flag  VARCHAR2(1);
l_config_hdr_id Number;
l_config_rev_nbr  Number;
l_last_update_date Date;
l_appl_param_rec  CZ_API_PUB.appl_param_rec_type;

l_config_rec aso_quote_pub.qte_line_dtl_rec_type;
l_model_line_rec aso_quote_pub.qte_line_rec_type;
l_QTE_LINE_TBL ASO_QUOTE_PUB.Qte_Line_Tbl_Type :=ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;

lx_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
lx_QTE_LINE_TBL ASO_QUOTE_PUB.Qte_Line_Tbl_Type;
lx_Qte_Line_Dtl_Tbl ASO_QUOTE_PUB.Qte_Line_dtl_Tbl_Type;
lx_out_config_tree_tbl CZ_API_PUB.config_model_tbl_type;
lx_hd_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_hd_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_hd_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_hd_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_hd_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;
lX_hd_Attr_Ext_Tbl        ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_Line_Attr_Ext_Tbl      ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;
lx_line_rltship_tbl       ASO_QUOTE_PUB.Line_Rltship_Tbl_Type;
lx_Price_Adjustment_Tbl   ASO_QUOTE_PUB.Price_Adj_Tbl_Type;
lx_Price_Adj_Attr_Tbl     ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;
lx_price_adj_rltship_tbl  ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;
lx_hd_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lx_Quote_Party_Tbl        ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lX_Ln_Sales_Credit_Tbl    ASO_QUOTE_PUB.Sales_Credit_Tbl_Type;
lX_Ln_Quote_Party_Tbl     ASO_QUOTE_PUB.Quote_Party_Tbl_Type;
lx_ln_Price_Attr_Tbl      ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;
lx_ln_payment_tbl         ASO_QUOTE_PUB.Payment_Tbl_Type;
lx_ln_shipment_tbl        ASO_QUOTE_PUB.Shipment_Tbl_Type;
lx_ln_freight_charge_tbl  ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;
lx_ln_tax_detail_tbl      ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;


Begin

     SAVEPOINT Reconfigure_from_IB_pvt;

        -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version_Number,
					l_api_name,
					G_PKG_NAME )
     THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
	 IF FND_API.to_Boolean( p_init_msg_list ) THEN
		   FND_MSG_PUB.initialize;
	 END IF;


     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


/*********************************************************************
Create  table of Config header Ids
**********************************************************************/

    For  i  IN 1.. P_Instance_tbl.count Loop
	   For c_item_rec  IN c_item_csr(P_Instance_tbl(i).instance_id) LOOP
		l_ins_config_hdr_tbl(i).config_hdr_id   := c_item_rec.config_inst_hdr_id;
		l_ins_config_hdr_tbl(i).config_rev_nbr := c_item_rec.config_inst_rev_num;

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Reconfigure_from_IB:Config Header Id:'||c_item_rec.config_inst_hdr_id,1,'N');
      aso_debug_pub.add('Reconfigure_from_IB:Config Rev Num:'||c_item_rec.config_inst_rev_num,1,'N');
    END IF;

	   END LOOP;
    END LOOP;

/**************************************************************
Create Applicability parameter record
***************************************************************/
--l_appl_param_rec.calling_application_id:= fnd_profile.value('JTF_PROFILE_DEFAULT_APPLICATION');

l_appl_param_rec.calling_application_id:= fnd_global.RESP_APPL_ID;
/**************************************************************
Call  CZ API to return config tree
**************************************************************/

CZ_NETWORK_API_PUB.Generate_config_trees(
		p_api_version	      =>	1.0,
        p_config_tbl	      =>	l_ins_config_hdr_tbl,
        p_tree_copy_mode	  =>	'R',
		p_appl_param_rec	  => 	l_appl_param_rec,
		p_validation_context  =>	CZ_API_PUB.G_INSTALLED,
		x_config_model_tbl	  =>	lx_out_config_tree_tbl,
        x_return_status	      => 	x_return_status,
		x_msg_count	          => 	x_msg_count,
        x_msg_data	          => 	x_msg_data);


IF aso_debug_pub.g_debug_flag = 'Y' THEN
  aso_debug_pub.add('Reconfigure_from_IB:Generate_config_trees:Return status:'||x_return_status,1,'N');
  aso_debug_pub.add('Reconfigure_from_IB:Generate_config_trees:Msg count:'||x_msg_count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          	raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          	raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/**************************************************************
Call  Update Quote for creating Quote lines
**************************************************************/

For  j  IN 1.. lx_out_config_tree_tbl.count Loop

Open c_uom_qty_csr(lx_out_config_tree_tbl(j).config_hdr_id,lx_out_config_tree_tbl(j).config_rev_nbr,lx_out_config_tree_tbl(j).config_item_id);

     fetch c_uom_qty_csr into l_uom, l_quantity;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Reconfigure_from_IB:UOM:'||l_uom,1,'N');
        aso_debug_pub.add('Reconfigure_from_IB:Quantity:'||l_quantity,1,'N');
     END IF;

            IF c_uom_qty_csr%NOTFOUND THEN
                   CLOSE c_uom_qty_csr;
			         x_return_status := FND_API.G_RET_STS_ERROR;
        		          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               			      FND_MESSAGE.Set_Name('ASO', 'ASO_UOM_QTY_NOT_FOUND');
               			      FND_MSG_PUB.Add;
        		          END IF;
       		 	     raise FND_API.G_EXC_ERROR;
            END IF;

                l_Qte_Line_tbl(j).QUANTITY := l_quantity;
                l_Qte_Line_tbl(j).UOM_CODE := l_uom;

    Close c_uom_qty_csr;

l_Qte_Line_tbl(j).quote_header_id := P_QTE_HEADER_REC.quote_header_id;
l_Qte_Line_tbl(j).OPERATION_CODE :='CREATE';
l_Qte_Line_tbl(j).ORGANIZATION_ID := lx_out_config_tree_tbl(j).organization_id;
l_Qte_Line_tbl(j).INVENTORY_ITEM_ID := lx_out_config_tree_tbl(j).inventory_item_id;
l_Qte_Line_tbl(j).LINE_CATEGORY_CODE := 'ORDER';

END LOOP;

   Open c_last_update_date_csr(P_QTE_HEADER_REC.quote_header_id);

     fetch c_last_update_date_csr into l_last_update_date;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('Reconfigure_from_IB:Last Update date:'||l_last_update_date,1,'N');
     END IF;

            IF c_last_update_date_csr%NOTFOUND THEN
                CLOSE c_configuration_details_csr;
				x_return_status := FND_API.G_RET_STS_ERROR;
	                       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	                               FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
	                               FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
	                               FND_MSG_PUB.ADD;
	                       END IF;
	            raise FND_API.G_EXC_ERROR;

            END IF;

   Close c_last_update_date_csr;

   l_qte_header_rec := p_qte_header_rec;

   l_QTE_HEADER_REC.last_update_date  := l_last_update_date;

   ASO_QUOTE_PUB.Update_Quote(
          p_api_version_number     => 1.0,
          p_init_msg_list          => p_init_msg_list,
          p_commit                 => p_commit,
          p_control_rec            => p_control_rec,
          p_qte_header_rec         => l_qte_header_rec,
          P_Qte_Line_Tbl           => l_Qte_Line_Tbl,
          X_Qte_Header_Rec         => lx_qte_header_rec,
          X_Qte_Line_Tbl           => lx_Qte_Line_Tbl,
          X_Qte_Line_Dtl_Tbl       => lx_Qte_Line_Dtl_Tbl,
          X_hd_Price_Attributes_Tbl => lx_hd_Price_Attr_Tbl,
          X_hd_Payment_Tbl         => lx_hd_Payment_Tbl,
          X_hd_Shipment_Tbl        => lx_hd_Shipment_Tbl,
          X_hd_Freight_Charge_Tbl  => lx_hd_Freight_Charge_Tbl,
          X_hd_Tax_Detail_Tbl      => lx_hd_Tax_Detail_Tbl,
          X_hd_Attr_Ext_Tbl        => lX_hd_Attr_Ext_Tbl,
          X_hd_Sales_Credit_Tbl    => lx_hd_Sales_Credit_Tbl,
          X_hd_Quote_Party_Tbl     => lx_Quote_Party_Tbl,
          X_Line_Attr_Ext_Tbl      => lx_Line_Attr_Ext_Tbl,
          X_line_rltship_tbl       => lx_line_rltship_tbl,
          X_Price_Adjustment_Tbl   => lx_Price_Adjustment_Tbl,
          X_Price_Adj_Attr_Tbl     => lx_Price_Adj_Attr_Tbl,
          X_Price_Adj_Rltship_Tbl  => lx_Price_Adj_Rltship_Tbl,
          X_ln_Price_Attributes_Tbl=> lx_ln_Price_Attr_Tbl,
          X_ln_Payment_Tbl         => lx_ln_Payment_Tbl,
          X_ln_Shipment_Tbl        => lx_ln_Shipment_Tbl,
          X_ln_Freight_Charge_Tbl  => lx_ln_Freight_Charge_Tbl,
          X_ln_Tax_Detail_Tbl      => lx_ln_Tax_Detail_Tbl,
          X_Ln_Sales_Credit_Tbl    => lX_Ln_Sales_Credit_Tbl,
          X_Ln_Quote_Party_Tbl     => lX_Ln_Quote_Party_Tbl,
          X_Return_Status          => x_Return_Status,
          X_Msg_Count              => x_Msg_Count,
          X_Msg_Data               => x_Msg_Data);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
aso_debug_pub.add('Reconfigure_from_IB:update_Quote:Return status:'||x_return_status,1,'N');
aso_debug_pub.add('Reconfigure_from_IB:update_Quote:Msg count:'||x_msg_count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


/**************************************************************
Copy  config data from CZ_CONFIG_DETAILS_V
**************************************************************/

For  k  IN 1.. lx_out_config_tree_tbl.count Loop

/****************************************************************************
Get complete configuration and valid configuration info from CZ_CONFIG_HDRS
****************************************************************************/
Open c_configuration_details_csr(lx_out_config_tree_tbl(k).config_hdr_id,lx_out_config_tree_tbl(k).config_rev_nbr);

     fetch c_configuration_details_csr into l_valid_configuration_flag,l_complete_configuration_flag;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Reconfigure_from_IB:Config Valid Info:'||l_complete_configuration_flag,1,'N');
     aso_debug_pub.add('Reconfigure_from_IB:Config Complete Info:'||l_valid_configuration_flag,1,'N');
	END IF;

            IF c_configuration_details_csr%NOTFOUND THEN
                CLOSE c_configuration_details_csr;
				x_return_status := FND_API.G_RET_STS_ERROR;
	                 	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				  FND_MESSAGE.Set_Name('ASO', 'ASO_CFG_DETAILS_NOT_FOUND');
               			      FND_MSG_PUB.Add;
        		          END IF;
				 raise FND_API.G_EXC_ERROR;

            END IF;

 Close c_configuration_details_csr;


l_config_rec.quote_line_id := lx_Qte_Line_Tbl(k).quote_line_id;
l_config_rec.complete_configuration_flag := l_complete_configuration_flag;
l_config_rec.valid_configuration_flag := l_valid_configuration_flag;
l_config_rec.config_header_id := lx_out_config_tree_tbl(k).config_hdr_id;
l_config_rec.config_revision_num :=lx_out_config_tree_tbl(k).config_rev_nbr;


Open c_mdl_item_details_csr(lx_Qte_Line_Tbl(k).quote_line_id);

     fetch c_mdl_item_details_csr into l_quantity, l_uom;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Reconfigure_from_IB:Config Valid Info:'||l_complete_configuration_flag,1,'N');
     aso_debug_pub.add('Reconfigure_from_IB:Config Complete Info:'||l_valid_configuration_flag,1,'N');
	END IF;

            IF c_mdl_item_details_csr%NOTFOUND THEN
                   CLOSE c_mdl_item_details_csr;
				x_return_status := FND_API.G_RET_STS_ERROR;
	                 	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				  FND_MESSAGE.Set_Name('ASO', 'ASO_MDL_DETAILS_NOT_FOUND');
               			      FND_MSG_PUB.Add;
        		          END IF;
				 raise FND_API.G_EXC_ERROR;
            END IF;

     Close c_mdl_item_details_csr;

l_model_line_rec.quote_line_id := lx_Qte_Line_Tbl(k).quote_line_id;
l_model_line_rec.quantity := l_quantity;
l_model_line_rec.uom_code := l_uom;

l_config_hdr_id 	:= lx_out_config_tree_tbl(k).config_hdr_id ;
l_config_rev_nbr 	:= lx_out_config_tree_tbl(k).config_rev_nbr ;

ASO_CFG_PUB.Get_config_details(
    		P_Api_Version_Number    	=> 1.0,
    		P_Init_Msg_List     		=> FND_API.g_false,
    		p_commit            		=> FND_API.g_false,
            p_control_rec		        => p_control_rec,
    		p_config_rec       		    => l_config_rec,
    		p_model_line_rec   		    => l_model_line_rec,
    		p_config_hdr_id     		=> l_config_hdr_id,
    		p_config_rev_nbr    		=> l_config_rev_nbr ,
    		p_qte_header_rec   		    => lx_qte_header_rec,
    		x_return_status     		=> x_return_status ,
    		x_msg_count         		=> x_msg_count ,
    		x_msg_data          		=> x_msg_data
);

IF aso_debug_pub.g_debug_flag = 'Y' THEN
   aso_debug_pub.add('Reconfigure_from_IB:Get_config_details:Return status:'||x_return_status,1,'N');
   aso_debug_pub.add('Reconfigure_from_IB:Get_config_details:Msg count:'||x_msg_count,1,'N');
END IF;

IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END LOOP;

x_qte_header_rec    := ASO_UTILITY_PVT.Query_Header_Row(P_QTE_HEADER_REC.quote_header_id);

-- End of API body

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
        aso_debug_pub.add('****** End of Reconfigure API ******', 1, 'Y');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data
    );


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_SQLERRM  => sqlerrm
            ,P_SQLCODE  => sqlcode
            ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

END Reconfigure_from_IB;


PROCEDURE Deactivate_from_quote(
   	P_Api_Version_Number  	IN	NUMBER,
    P_Init_Msg_List   		IN	VARCHAR2    := FND_API.G_FALSE,
    P_Commit    		    IN	VARCHAR2 := FND_API.G_FALSE,
   	p_validation_level   	IN	NUMBER    := FND_API.G_VALID_LEVEL_FULL,
	P_Qte_Header_Rec   		IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_Control_Rec  		    IN	ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec,
	P_qte_line_tbl          IN	ASO_QUOTE_PUB.Qte_line_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl,
	p_delete_flag            IN  VARCHAR2 := FND_API.G_TRUE,
    x_Qte_Header_Rec	 OUT NOCOPY /* file.sql.39 change */ ASO_QUOTE_PUB.Qte_Header_Rec_Type,
    X_Return_Status   	    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
    X_Msg_Count    		    OUT NOCOPY /* file.sql.39 change */ NUMBER,
    X_Msg_Data    		    OUT NOCOPY /* file.sql.39 change */ VARCHAR2
) IS

/*******************************************************************
  Cursor to check if item can be deactivated
********************************************************************/

Cursor  c_deactivate_item_csr(p_quote_line_id Number) is
Select a.config_header_id, a.config_revision_num, a.config_item_id,a.config_delta
from aso_quote_line_details  a
where a.quote_line_id =p_quote_line_id;

/*******************************************************************
  Cursor to find all items in a quote that can be deactivated
********************************************************************/

Cursor  c_deactivate_all_item_csr(p_quote_header_id Number) is
Select b.quote_line_id from aso_quote_line_details a,aso_quote_lines_all b
where b.quote_header_id = p_quote_header_id
and a.quote_line_id = b.quote_line_id
and a.config_delta = 0
and not exists(Select null from aso_quote_line_details c
where c.quote_line_id = a.ref_line_id
and c.config_delta = 0
);

/****************************************************************************
Cursor to Check if  the quote line contains the top model
*****************************************************************************/
Cursor c_chk_qte_line_mdl_csr(p_quote_line_id Number) is
Select b.config_header_id,b.config_revision_num
from
ASO_QUOTE_LINE_DETAILS b
where b.quote_line_id = P_quote_line_id
and b.ref_type_code ='CONFIG'
and b.ref_line_id is null;

/**************************************************************
Cursor to find the quote line containing the top model
***************************************************************/

Cursor c_top_mdl_csr(p_config_header_id Number,p_config_revision_num Number) is
Select b.config_item_id
from
ASO_QUOTE_LINE_DETAILS b
where b.config_header_id = p_config_header_id
and b.config_revision_num = p_config_revision_num
and b.ref_type_code ='CONFIG'
and b.ref_line_id is null;

/**************************************************************
Cursor to find the quote line details containing the top model
***************************************************************/
Cursor c_top_mdl_details_csr(p_config_header_id Number,p_config_revision_num Number,p_config_item_id Number) is
Select a.quote_line_id,a.quantity, a.uom_code,
b.complete_configuration_flag, b.valid_configuration_flag
from
ASO_QUOTE_LINES_ALL a, ASO_QUOTE_LINE_DETAILS b
where a.quote_line_id = b.quote_line_id
and b.config_header_id = p_config_header_id
and b.config_revision_num   = p_config_revision_num
and b.config_item_id   = p_config_item_id;

Cursor c_check_for_macd( p_qte_line_id number) is
select config_model_type
from aso_quote_lines_all
where quote_line_id = p_qte_line_id;

 Cursor c_last_update_date_csr(p_qte_header_id Number) is
 SELECT last_update_date,object_version_number
 FROM ASO_QUOTE_HEADERS_ALL
 WHERE quote_header_id = p_qte_header_id;


l_count Number := 0;
i Number;
l_api_name               CONSTANT VARCHAR2(30) := 'Deactivate_from_quote';
l_api_version	         CONSTANT NUMBER := 1.0;
l_qte_line_tbl     ASO_QUOTE_PUB.QTE_LINE_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl;
l_macd_qte_line_tbl ASO_QUOTE_PUB.QTE_LINE_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_line_tbl;
l_qte_line_rec ASO_QUOTE_PUB.qte_line_Rec_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
l_quote_line_id Number;
l_quantity  Number;
l_uom_code VARCHAR2(10);
l_order_line_type_id Number;
l_complete_configuration_flag VARCHAR2(1);
l_valid_configuration_flag  VARCHAR2(1);
l_rev_num Number;
l_config_item_id  Number;
l_config_header_id Number;
l_config_rev_nbr  Number;
l_config_rec aso_quote_pub.qte_line_dtl_rec_type;
l_model_line_rec aso_quote_pub.qte_line_rec_type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_REC;
l_line_count Number :=0;
l_copy_conf_mdl_Tbl aso_quote_pub.qte_line_dtl_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_TBL;
l_deactivate_mdl_Tbl  aso_quote_pub.qte_line_dtl_tbl_type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_TBL;
x boolean := FALSE;
k Number;
l_macd_flag  varchar2(30);

l_last_update_date Date;
l_qte_header_rec ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;
l_obj_version_number number;

Begin

     SAVEPOINT Deactivate_from_quote_pvt;

        -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call (
					l_api_version,
					p_api_version_Number,
					l_api_name,
					G_PKG_NAME )
     THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
	 IF FND_API.to_Boolean( p_init_msg_list ) THEN
		   FND_MSG_PUB.initialize;
	 END IF;


     -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

/********************************************************************************
  Construct "Deactivate quote line table" if  "Deactivate flag" is set to 'True".
********************************************************************************/
 IF (P_Control_Rec.deactivate_all = FND_API.G_TRUE)THEN
 	For c_deactivate_all_item_rec IN c_deactivate_all_item_csr(P_Qte_Header_Rec.quote_header_id) LOOP
	           l_line_count := l_line_count + 1;

			IF aso_debug_pub.g_debug_flag = 'Y' THEN
               aso_debug_pub.add('Deactivate_from_quote:quote_line_id:'||c_deactivate_all_item_rec.quote_line_id,1,'N');
			END IF;

		       l_qte_line_tbl(l_line_count).quote_line_id := c_deactivate_all_item_rec.quote_line_id;
	END LOOP;
 else
               l_qte_line_tbl := p_qte_line_tbl;
 END IF;

 -- fix for bug 4900023, if quote has non-MACD lines then igonore those lines
 for i in 1..l_qte_line_tbl.count loop
   open c_check_for_macd(l_qte_line_tbl(i).quote_line_id);
   fetch c_check_for_macd into l_macd_flag;
   close c_check_for_macd;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Deactivate_from_quote:quote_line_id: '|| l_qte_line_tbl(i).quote_line_id ,1,'N');
      aso_debug_pub.add('Deactivate_from_quote:l_macd_flag:   '|| l_macd_flag ,1,'N');
   END IF;

   if nvl(l_macd_flag,'X') = 'N' then
    l_macd_qte_line_tbl(l_macd_qte_line_tbl.count + 1).quote_line_id := l_qte_line_tbl(i).quote_line_id;
   end if;

   -- reset the flag
   l_macd_flag := null;

 end loop;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Deactivate_from_quote:l_macd_qte_line_tbl.count: '|| l_macd_qte_line_tbl.count,1,'N');
      aso_debug_pub.add('Deactivate_from_quote:ORIGINAL l_qte_line_tbl.count: '|| l_qte_line_tbl.count,1,'N');
   END IF;

  -- reset the qte line tbl to have only MACD Lines
  l_qte_line_tbl := l_macd_qte_line_tbl;

   IF aso_debug_pub.g_debug_flag = 'Y' THEN
      aso_debug_pub.add('Deactivate_from_quote:MODIFIED l_qte_line_tbl.count: '|| l_qte_line_tbl.count,1,'N');
   END IF;

-- end of fox for bug 4900023

/*******************************************************************
  Deactivate the items  by calling CZ API
********************************************************************/

 For  i  IN 1..l_qte_line_tbl.count Loop

    IF (P_Control_Rec.deactivate_all = FND_API.G_FALSE)THEN

	   For c_de_item_rec IN c_deactivate_item_csr(l_qte_line_tbl(i).quote_line_id) LOOP
			if c_de_item_rec.config_delta  > 0 then
				x_return_status := FND_API.G_RET_STS_ERROR;
	                 	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               				  FND_MESSAGE.Set_Name('ASO', 'ASO_ITEM_CANT_BE_DEACTIVATED');
               			      FND_MSG_PUB.Add;
        		          END IF;
				 raise FND_API.G_EXC_ERROR;

			end if;
	   END LOOP;
     end if;

     /*******************************************************************
      Check quote line for model
     ********************************************************************/

     Open c_chk_qte_line_mdl_csr(l_qte_line_tbl(i).quote_line_id);

     fetch c_chk_qte_line_mdl_csr into l_config_header_id, l_rev_num;

	IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Deactivate_from_quote:Config header Id:'||l_config_header_id,1,'N');
     aso_debug_pub.add('Deactivate_from_quote:Config Rev num:'||l_rev_num,1,'N');
	END IF;

            IF c_chk_qte_line_mdl_csr%NOTFOUND THEN
                l_config_header_id := null;
            END IF;

     Close c_chk_qte_line_mdl_csr;

     If l_config_header_id is not null and p_delete_flag = fnd_api.g_true then

        /*******************************************************************
        Delete Quote line
        ********************************************************************/
        l_qte_line_rec.operation_code := 'DELETE';
        l_qte_line_rec.quote_line_id  := l_qte_line_tbl(i).quote_line_id;

        ASO_QUOTE_LINES_PVT.Delete_Quote_Line (
			P_Api_Version_Number	 => 1.0,
			p_control_rec		     => p_control_rec,
			p_update_header_flag	 => FND_API.G_FALSE,
			P_qte_Line_Rec		     => l_qte_line_rec,
			X_Return_Status 		 => x_return_status,
			X_Msg_Count		         => x_msg_count,
			X_Msg_Data		         => x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR then
         		raise FND_API.G_EXC_ERROR;
        elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          		raise FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

     else

	   For c_deactivate_item_rec IN c_deactivate_item_csr(l_qte_line_tbl(i).quote_line_id) LOOP

             CZ_NETWORK_API_PUB.ext_deactivate_item(
                         P_Api_version          => 1.0,
		               P_config_hdr_id	   => c_deactivate_item_rec.config_header_id,
		               p_config_rev_nbr	   => c_deactivate_item_rec.config_revision_num,
                         p_config_item_id	   => c_deactivate_item_rec.config_item_id,
		               x_return_status	   => x_return_status,
		               x_msg_count		   => x_msg_count,
		               x_msg_data		   => x_msg_data );

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Deactivate_from_quote:ext_deactivate_item: Return status:'||x_return_status,1,'N');
                aso_debug_pub.add('Deactivate_from_quote:ext_deactivate_item: Msg count:'||x_msg_count,1,'N');
             END IF;

             IF x_return_status = FND_API.G_RET_STS_ERROR then
         		raise FND_API.G_EXC_ERROR;
             elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        		raise FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             /**************************************************************
             Find the quote line containing the top model
             ***************************************************************/
             Open c_top_mdl_csr(c_deactivate_item_rec.config_header_id,c_deactivate_item_rec.config_revision_num);

             fetch c_top_mdl_csr into l_config_item_id;

	        IF aso_debug_pub.g_debug_flag = 'Y' THEN
                aso_debug_pub.add('Deactivate_from_quote:Config Valid Info:'||l_complete_configuration_flag,1,'N');
                aso_debug_pub.add('Deactivate_from_quote:Config Complete Info:'||l_valid_configuration_flag,1,'N');
	        END IF;

             IF c_top_mdl_csr%FOUND THEN
                 l_copy_conf_mdl_Tbl(i).config_item_id := l_config_item_id;
                 l_copy_conf_mdl_Tbl(i).config_header_id := c_deactivate_item_rec.config_header_id;
                 l_copy_conf_mdl_Tbl(i).config_revision_num := c_deactivate_item_rec.config_revision_num;
             END IF;

             Close c_top_mdl_csr;

        END LOOP;

     End if;

END LOOP;



If  (l_copy_conf_mdl_Tbl.count > 0) then

    For  j IN 1..l_copy_conf_mdl_Tbl.count Loop

             k := 1;
             x := FALSE;
             While (x = FALSE AND k <= l_deactivate_mdl_Tbl.count) Loop

	          	         if ((l_copy_conf_mdl_Tbl(j).config_item_id) =(l_deactivate_mdl_Tbl(k).config_item_id)) AND
	             	        ((l_copy_conf_mdl_Tbl(j).config_header_id) =(l_deactivate_mdl_Tbl(k).config_header_id) ) AND
	              	        ((l_copy_conf_mdl_Tbl(j).config_revision_num) = (l_deactivate_mdl_Tbl(k).config_revision_num))
                            then
                             x := TRUE;
                        END IF;

                        k := k + 1;
            END LOOP;

            If x = FALSE then
                    l_count := l_count + 1;

                    /**************************************************************
                    Find the quote line details containing the top model
                    ***************************************************************/

                    Open c_top_mdl_details_csr(l_copy_conf_mdl_Tbl(j).config_header_id,l_copy_conf_mdl_Tbl(j).config_revision_num,l_copy_conf_mdl_Tbl(j).config_item_id);

                    fetch c_top_mdl_details_csr into l_quote_line_id,l_quantity, l_uom_code,l_complete_configuration_flag,
                    l_valid_configuration_flag;

	                IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Deactivate_from_quote:Config Valid Info:'||l_complete_configuration_flag,1,'N');
                        aso_debug_pub.add('Deactivate_from_quote:Config Complete Info:'||l_valid_configuration_flag,1,'N');
	                END IF;

                    IF c_top_mdl_details_csr%NOTFOUND THEN
                        null;-- No Action
                    END IF;

                    Close c_top_mdl_details_csr;

                    /**************************************************************
                    Copy  config data from CZ_CONFIG_DETAILS_V
                    **************************************************************/
                    l_config_rec.quote_line_id := l_quote_line_id;
                    l_config_rec.complete_configuration_flag := l_complete_configuration_flag;
                    l_config_rec.valid_configuration_flag := l_valid_configuration_flag;
                    l_config_rec.config_header_id := l_copy_conf_mdl_Tbl(j).config_header_id;
                    l_config_rec.config_revision_num := l_copy_conf_mdl_Tbl(j).config_revision_num;

                    l_model_line_rec.quote_line_id := l_quote_line_id;
                    l_model_line_rec.quantity := l_quantity;
                    l_model_line_rec.uom_code := l_uom_code;

                    Open c_last_update_date_csr(P_QTE_HEADER_REC.quote_header_id);
                    fetch c_last_update_date_csr into l_last_update_date,l_obj_version_number;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                       aso_debug_pub.add('Deactivate_from_quote:Last Update date:'||l_last_update_date,1,'N');
                       aso_debug_pub.add('Deactivate_from_quote:Object Version Number:'||l_obj_version_number,1,'N');
                    END IF;

                    IF c_last_update_date_csr%NOTFOUND THEN
                       CLOSE c_last_update_date_csr;
                       x_return_status := FND_API.G_RET_STS_ERROR;
                            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                                    FND_MESSAGE.Set_Name('ASO', 'ASO_API_MISSING_COLUMN');
                                    FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date', FALSE);
                                    FND_MSG_PUB.ADD;
                            END IF;
                       raise FND_API.G_EXC_ERROR;

                    END IF;

                    Close c_last_update_date_csr;

                    l_qte_header_rec := p_qte_header_rec;

                    l_QTE_HEADER_REC.last_update_date  := l_last_update_date;
                    l_QTE_HEADER_REC.object_version_number  := l_obj_version_number;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Deactivate_from_quote:Before calling get_config_details ', 1, 'N');
                        aso_debug_pub.add('Deactivate_from_quote:l_config_rec.config_header_id: '||l_config_rec.config_header_id, 1, 'N');
                        aso_debug_pub.add('Deactivate_from_quote:l_config_rec.config_revision_num: '||l_config_rec.config_revision_num, 1, 'N');
                        aso_debug_pub.add('Deactivate_from_quote:l_copy_conf_mdl_Tbl.config_header_id: '||l_copy_conf_mdl_Tbl(j).config_header_id, 1, 'N');
                        aso_debug_pub.add('Deactivate_from_quote:l_copy_conf_mdl_Tbl.config_revision_num: '||l_copy_conf_mdl_Tbl(j).config_revision_num, 1, 'N');
                    END IF;



				ASO_CFG_PUB.Get_config_details(
    		          P_Api_Version_Number    	=> P_Api_Version_Number,
    		          P_Init_Msg_List     		=> FND_API.G_FALSE,
    		          p_commit            		=> FND_API.G_FALSE,
    		          p_config_rec       		    => l_config_rec,
		              p_control_rec		        => p_control_rec,
    		          p_model_line_rec   		    => l_model_line_rec,
    		          p_config_hdr_id     		=> l_copy_conf_mdl_Tbl(j).config_header_id,
    		          p_config_rev_nbr    		=> l_copy_conf_mdl_Tbl(j).config_revision_num,
    		          p_qte_header_rec   		    => l_qte_header_rec,
    		          x_return_status     		=> x_return_status ,
    		          x_msg_count         		=> x_msg_count ,
    		          x_msg_data          		=> x_msg_data
                    );

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Deactivate_from_quote:Get_config_details:x_return_status'||x_return_status, 1, 'N');
                        aso_debug_pub.add('Deactivate_from_quote:Get_config_details:x_return_status'||x_msg_count, 1, 'N');
                    END IF;

                    IF x_return_status = FND_API.G_RET_STS_ERROR then
          			   raise FND_API.G_EXC_ERROR;
                    elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          			   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Deactivate_from_quote:Write to l_deactivate_mdl_Tbl', 1, 'N');
                    END IF;

                    l_deactivate_mdl_Tbl(l_count).config_item_id := l_copy_conf_mdl_Tbl(j).config_item_id;
                    l_deactivate_mdl_Tbl(l_count).config_header_id := l_copy_conf_mdl_Tbl(j).config_header_id;
                    l_deactivate_mdl_Tbl(l_count).config_revision_num := l_copy_conf_mdl_Tbl(j).config_revision_num;

	     End if;

   END LOOP;
end if;

                    IF aso_debug_pub.g_debug_flag = 'Y' THEN
                        aso_debug_pub.add('Deactivate_from_quote:Query Quote Header Rec', 1, 'N');
                    END IF;

x_qte_header_rec    := ASO_UTILITY_PVT.Query_Header_Row(P_QTE_HEADER_REC.quote_header_id);

-- End of API body

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** End of Deactivate from quote API ******', 1, 'Y');
    END IF;

    -- Standard check of p_commit
    IF FND_API.To_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    FND_Msg_Pub.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_SQLERRM  => sqlerrm
            ,P_SQLCODE  => sqlcode
            ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

END Deactivate_from_quote;

END ASO_CONFIG_OPERATIONS_PVT;


/
