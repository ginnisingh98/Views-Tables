--------------------------------------------------------
--  DDL for Package Body ASO_INSTBASE_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_INSTBASE_INT" as
/* $Header: asoicsib.pls 120.2 2006/03/23 18:24:01 skulkarn ship $ */
-- Start of Comments
-- Package name     : ASO_InstBase_INT
-- Purpose          :
-- History          :
--         04/07/03 hyang - bug 2860045, performance fix.
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_InstBase_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoicsib.pls';

G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


-- global variables


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Installation_Details
--  Type       : Public
--  Function   : This API is used to delete Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      := FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2(2000)
--
--  Delete_Installation_Details IN Parameters:
--  p_line_inst_dtl_id        NUMBER                   Required

--  Delete_Installation_Details OUT NOCOPY /* file.sql.39 change */ Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_Installation_Detail
(
	p_api_version_number    IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */      NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */      VARCHAR2,
	p_line_inst_dtl_id      IN      NUMBER
)
IS

  l_api_version_number NUMBER := 1.0;
  l_api_name VARCHAR2(50)     := 'Delete_Installation_Detail';

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Delete_Installation_detail_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                     	           p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
      FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF NOT (CSI_utility_grp.ib_active())
  then
  -- old ib module.
   null;
  ELSE
  -- new ib module.
    CSI_T_Txn_Details_GRP.Delete_Transaction_Dtls(
      p_api_version         => 1.0,
      p_init_msg_list       => p_init_msg_list,
      p_commit              => p_commit,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_transaction_line_id    => p_line_inst_dtl_id
    );

  END IF;


  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


  --
  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
      COMMIT WORK;
  END IF;


  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
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
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_Installation_Detail;



-- PROCEDURE Update_Inst_Details_ORDER
-- USAGE     updates the installation detail to include the order line id.
-- NEED
-- 1. installation details need to be linked to an order. when creating installation details from OC the order line id does not exist. this procedure is called after the quote is converted to an order.


PROCEDURE Update_Inst_Details_ORDER
(
  p_api_version_number			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
	p_commit	  IN	VARCHAR2  := FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	p_quote_line_shipment_id		IN	NUMBER,
	p_order_line_id		IN	NUMBER
)
IS

  -- hyang, bug 2860045, performance fix.

  CURSOR C_quote_line(quote_line_shipment_id number)
  IS
    SELECT quote_line_id
    FROM aso_shipments
    WHERE shipment_id = quote_line_shipment_id;

  CURSOR c_csi_details(quote_line_id number)
  IS
   select transaction_line_id
   from csi_t_transaction_lines
   where source_transaction_id = quote_line_id
   and source_transaction_table = 'ASO_QUOTE_LINES_ALL';


  l_api_version_number        number := 1.0;
  l_api_name           VARCHAR2(240) := 'UPDATE_INST_DETAILS_ORDER';
  l_src_txn_line_rec    csi_t_datastructures_grp.txn_line_rec;
  lx_new_txn_line_rec   csi_t_datastructures_grp.txn_line_rec;
  l_quote_line_id   NUMBER;


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Update_Inst_details_ORder_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                   	           p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if NOT (CSI_utility_grp.ib_active())
  then
  -- old ib module.
    null;
  ELSE
  -- new ib module.

    -- get quote_line_id by shipment_id.
    Open C_quote_line(p_quote_line_shipment_id);
    FETCH C_quote_line into l_src_txn_line_rec.source_transaction_id;

    If ( C_quote_line%NOTFOUND) Then
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('ASO', 'API_MISSING_UPDATE_TARGET');
        FND_MESSAGE.Set_Token ('INFO', 'quote', FALSE);
        FND_MSG_PUB.Add;
      END IF;
      Close C_quote_line;
      raise FND_API.G_EXC_ERROR;
    END IF;
    Close C_quote_line;

    Open c_csi_details(l_src_txn_line_rec.source_transaction_id);
    FETCH c_csi_details into l_quote_line_id;
    IF (c_csi_details%found) THEN

      l_src_txn_line_rec.source_transaction_table := 'ASO_QUOTE_LINES_ALL';
      lx_new_txn_line_rec.source_transaction_table := 'OE_ORDER_LINES_ALL';
      lx_new_txn_line_rec.source_transaction_id := p_order_line_id;

      l_src_txn_line_rec.source_transaction_type_id := 56;
      lx_new_txn_line_rec.source_transaction_type_id := 51;

      CSI_T_Txn_Details_GRP.Copy_Transaction_Dtls(
        p_api_version         => 1.0,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_src_txn_line_rec    => l_src_txn_line_rec,
        px_new_txn_line_rec   => lx_new_txn_line_rec
      );
    END IF;
    Close C_csi_details;

  END IF;

  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;


  -- Debug Message
  ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
   p_data           =>   x_msg_data
  );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
             P_API_NAME => L_API_NAME
            ,P_PKG_NAME => G_PKG_NAME
            ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
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
            ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
            ,X_MSG_COUNT => X_MSG_COUNT
            ,X_MSG_DATA => X_MSG_DATA
            ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Inst_Details_ORDER;



-- FUNCTION Get_top_model_line_id
-- USAGE    Returns the quote line id for the model/top parent for a given quote line id.
-- NEED
-- 1. The form passes the model quote line id for child items in the hierarchy string when calling the Installation Details form.  This takes place when accessing Installation Details from the Action menu.


FUNCTION Get_top_model_line_id(p_qte_line_id NUMBER)
RETURN NUMBER
IS

     x_top_model_line_id NUMBER;
     lv_quote_line_id NUMBER;
     x_inventory_item_id NUMBER;

     CURSOR C_top_model_line_id(l_quote_line_id NUMBER) IS
     select  quote_line_id
     from aso_line_relationships  aso_rel
     where aso_rel.related_quote_line_id = l_quote_line_id;

     CURSOR C_item_id IS
     select inventory_item_id
     from aso_quote_lines_all
     where quote_line_id = x_top_model_line_id;


BEGIN

	-- initialize G_Debug_Flag
	ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Get_top_model_line_id -  Begin  ',1,'Y');
	   aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_qte_line_id),'null'),1,'N');
      END IF;

	 x_top_model_line_id := p_qte_line_id;

      OPEN C_top_model_line_id(x_top_model_line_id);
      FETCH C_top_model_line_id INTO lv_quote_line_id;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Before loop - lv_quote_line_id: '||nvl(to_char(lv_quote_line_id),'null'),1,'N');
      END IF;

      IF (C_top_model_line_id%NOTFOUND) THEN
          CLOSE C_top_model_line_id;
		return null;
      END IF;
	 x_top_model_line_id := lv_quote_line_id;
      CLOSE C_top_model_line_id;

      Loop
          OPEN C_top_model_line_id(x_top_model_line_id);
          FETCH C_top_model_line_id INTO lv_quote_line_id;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('Inside Loop - lv_quote_line_id: '||nvl(to_char(lv_quote_line_id),'null'),1,'N');
          END IF;

          IF (C_top_model_line_id%NOTFOUND) THEN
             CLOSE C_top_model_line_id;
             EXIT;
          END IF;

          CLOSE C_top_model_line_id;
          x_top_model_line_id := lv_quote_line_id;
      End Loop;

      return x_top_model_line_id ;

       EXCEPTION
			  WHEN OTHERS THEN
					    RETURN NULL;

END Get_top_model_line_id ;

END ASO_instbase_INT;

/
