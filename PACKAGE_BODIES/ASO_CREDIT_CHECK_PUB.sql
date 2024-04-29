--------------------------------------------------------
--  DDL for Package Body ASO_CREDIT_CHECK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_CREDIT_CHECK_PUB" as
/* $Header: asopqccb.pls 120.1 2005/06/29 12:37:24 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_CREDIT_CHECK_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_CREDIT_CHECK_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asopqccb.pls';

--subha  madapusi - quote credit check call.

PROCEDURE CREDIT_CHECK(
  P_API_VERSION		    IN	NUMBER,
  P_INIT_MSG_LIST	    IN	VARCHAR2  := FND_API.G_FALSE,
  P_COMMIT		    IN 	VARCHAR2  := FND_API.G_FALSE,
  P_QTE_HEADER_REC          IN  ASO_QUOTE_PUB.Qte_Header_Rec_Type,
  X_RESULT_OUT              OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  X_CC_HOLD_COMMENT         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  X_RETURN_STATUS	    OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2,
  X_MSG_COUNT		    OUT NOCOPY /* file.sql.39 change */ 	NUMBER,
  X_MSG_DATA		    OUT NOCOPY /* file.sql.39 change */ 	VARCHAR2
)
IS

  l_api_version             NUMBER        := 1.0;
  l_api_name                VARCHAR2(50)  := 'Credit_Check';

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Credit_Check_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                     	                 p_api_version,
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


  -- Initializing Global Debug Variable.
  aso_debug_pub.g_debug_flag := NVL(FND_PROFILE.VALUE('ASO_ENABLE_DEBUG'),'N');

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- API body
  --

  --  call user hooks - Pre processing

  -- customer pre processing

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_CUHK: Before Customer Pre Hook................. ', 1, 'Y');
  END IF;

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C')) THEN
    ASO_CREDIT_CHECK_CUHK.credit_check_PRE(
    P_API_VERSION		=> 1.0,
    P_INIT_MSG_LIST	        => FND_API.G_FALSE,
    p_commit                  	=> FND_API.G_FALSE,
    p_qte_header_rec		=> p_qte_header_rec,
    X_RETURN_STATUS	        => x_return_status,
    X_MSG_COUNT		        => x_msg_count,
    X_MSG_DATA		        => x_msg_data
    );
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('Credit_Check_CUHK: after CREDIT_CHECK_CUHK Pre hook return_status: '||x_return_status, 1, 'Y');
  END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('PKG_NAME', 'ASO_CREDIT_CHECK_CUHK', FALSE);
		  FND_MESSAGE.Set_Token('API_NAME', 'Credit_Check_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
     END IF;
  END IF; -- customer hook

  -- vertical pre hook
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_VUHK: Before Vertical Pre Hook................. ', 1, 'Y');
  END IF;

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'V')) THEN
    ASO_CREDIT_CHECK_VUHK.Credit_Check_PRE(
    P_API_VERSION		=> 1.0,
    P_INIT_MSG_LIST	        => FND_API.G_FALSE,
    p_commit                  	=> FND_API.G_FALSE,
    p_qte_header_rec		=> p_qte_header_rec,
    X_RETURN_STATUS	        => x_return_status,
    X_MSG_COUNT		        => x_msg_count,
    X_MSG_DATA		        => x_msg_data
    );
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_VUHK: after CREDIT_CHECK_VUHK Pre hook return_status: '||x_return_status, 1, 'Y');
  END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
		  FND_MESSAGE.Set_Token('PKG_NAME', 'ASO_CREDIT_CHECK_VUHK', FALSE);
		  FND_MESSAGE.Set_Token('API_NAME', 'Credit_Check_PRE', FALSE);
		  FND_MSG_PUB.ADD;
             END IF;
             IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                    RAISE FND_API.G_EXC_ERROR;
             END IF;
    END IF;
  END IF;

  -- Public API Call.
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_PUB: Before CREDIT_CHECK................. ', 1, 'Y');
  END IF;

  ASO_CREDIT_CHECK_PVT.CREDIT_CHECK(
    P_API_VERSION		=> 1.0,
    P_INIT_MSG_LIST	        => FND_API.G_FALSE,
    p_commit                  	=> FND_API.G_FALSE,
    p_qte_header_rec		=> p_qte_header_rec,
    X_result_out                => x_result_out,
    X_cc_hold_comment      	=> x_cc_hold_comment,
    X_RETURN_STATUS	        => x_return_status,
    X_MSG_COUNT		        => x_msg_count,
    X_MSG_DATA		        => x_msg_data
  );

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_PUB: after CREDIT_CHECK return_status: '||x_return_status, 1, 'Y');
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --  call user hooks - Post Processing.

  -- customer post processing
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_CUHK: Before Customer Post Hook................. ', 1, 'Y');
  END IF;

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C')) THEN
    ASO_CREDIT_CHECK_CUHK.Credit_Check_POST(
    P_API_VERSION		=> 1.0,
    P_INIT_MSG_LIST	        => FND_API.G_FALSE,
    p_commit                  	=> FND_API.G_FALSE,
    p_qte_header_rec		=> p_qte_header_rec,
    p_result_out                => x_result_out,
    p_cc_hold_comment           => x_cc_hold_comment,
    X_RETURN_STATUS	        => x_return_status,
    X_MSG_COUNT		        => x_msg_count,
    X_MSG_DATA		        => x_msg_data
    );
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_CUHK: after CREDIT_CHECK_CUHK Post hook return_status: '||x_return_status, 1, 'Y');
  END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
		FND_MESSAGE.Set_Token('PKG_NAME', 'ASO_CREDIT_CHECK_CUHK', FALSE);
		FND_MESSAGE.Set_Token('API_NAME', 'Credit_Check_POST', FALSE);
		FND_MSG_PUB.ADD;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
  END IF; -- customer hook

  -- vertical post hook

  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_VUHK: Before Vertical Post Hook................. ', 1, 'Y');
  END IF;

  IF (JTF_USR_HKS.ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V')) THEN
    ASO_CREDIT_CHECK_VUHK.Credit_check_POST(
    P_API_VERSION		=> 1.0,
    P_INIT_MSG_LIST	        => FND_API.G_FALSE,
    p_commit                  	=> FND_API.G_FALSE,
    p_qte_header_rec		=> p_qte_header_rec,
    p_result_out                => x_result_out,
    p_cc_hold_comment           => x_cc_hold_comment,
    X_RETURN_STATUS	        => x_return_status,
    X_MSG_COUNT		        => x_msg_count,
    X_MSG_DATA		        => x_msg_data
    );
  IF aso_debug_pub.g_debug_flag = 'Y' THEN
     aso_debug_pub.add('Credit_Check_VUHK: after CREDIT_CHECK_VUHK Post hook return_status: '||x_return_status, 1, 'Y');
  END IF;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.Set_Name('ASO', 'ASO_ERROR_RETURNED');
		FND_MESSAGE.Set_Token('PKG_NAME', 'ASO_CREDIT_CHECK_VUHK', FALSE);
		FND_MESSAGE.Set_Token('API_NAME', 'Credit_check_POST', FALSE);
		FND_MSG_PUB.ADD;
       END IF;
       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
  END IF; -- vertical hook

  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean( p_commit )
  THEN
    COMMIT WORK;
  END IF;




  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,P_SQLCODE => SQLCODE
              ,P_SQLERRM => SQLERRM
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,P_SQLCODE => SQLCODE
              ,P_SQLERRM => SQLERRM
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
          ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
              ,P_PKG_NAME => G_PKG_NAME
              ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
              ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
              ,P_SQLCODE => SQLCODE
              ,P_SQLERRM => SQLERRM
              ,X_MSG_COUNT => X_MSG_COUNT
              ,X_MSG_DATA => X_MSG_DATA
              ,X_RETURN_STATUS => X_RETURN_STATUS);
END Credit_Check;
-- subha madapusi - quote credit check end.

END ASO_CREDIT_CHECK_PUB;

/
