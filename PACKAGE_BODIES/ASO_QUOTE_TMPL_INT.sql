--------------------------------------------------------
--  DDL for Package Body ASO_QUOTE_TMPL_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_QUOTE_TMPL_INT" AS
/* $Header: asoiqtmb.pls 120.1 2005/06/29 12:35:26 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_QUOTE_TMPL_INT
-- Purpose          :
-- End of Comments



G_PKG_NAME           CONSTANT    VARCHAR2(30)                             := 'ASO_QUOTE_TMPL_INT';
G_FILE_NAME          CONSTANT    VARCHAR2(12)                             := 'asoiqtmb.pls';

PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_TEMPLATE_ID_TBL       IN   LIST_TEMPLATE_TBL_TYPE,
    P_QUOTE_HEADER_ID       IN   NUMBER,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    P_LAST_UPDATE_DATE      IN   DATE,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS

l_QTE_HEADER_REC             ASO_QUOTE_PUB.Qte_Header_Rec_Type:=ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec;

Begin

l_qte_header_rec    := ASO_UTILITY_PVT.Query_Header_Row(p_quote_header_id);

Add_Template_To_Quote(
    P_API_VERSION_NUMBER  => 1.0,
    P_INIT_MSG_LIST       => FND_API.G_FALSE,
    P_COMMIT              => FND_API.G_FALSE,
    P_VALIDATION_LEVEL    => FND_API.G_VALID_LEVEL_FULL,
    P_TEMPLATE_ID_TBL     => p_template_id_tbl,
    P_qte_header_rec      => l_QTE_HEADER_REC,
    P_CONTROL_REC         => p_control_rec,
    X_RETURN_STATUS       => x_return_status,
    X_MSG_COUNT           => x_msg_count,
    X_MSG_DATA            => x_msg_data
);

End Add_Template_To_Quote;


PROCEDURE Add_Template_To_Quote(
    P_API_VERSION_NUMBER    IN   NUMBER,
    P_INIT_MSG_LIST         IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_COMMIT                IN   VARCHAR2                                 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL      IN   NUMBER                                   := FND_API.G_VALID_LEVEL_FULL,
    P_TEMPLATE_ID_TBL       IN   LIST_TEMPLATE_TBL_TYPE,
    P_QTE_HEADER_REC        IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type := ASO_QUOTE_PUB.G_Miss_Qte_Header_Rec,
    P_CONTROL_REC           IN   ASO_QUOTE_PUB.CONTROL_REC_TYPE           := ASO_QUOTE_PUB.G_MISS_control_REC,
    X_RETURN_STATUS         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    X_MSG_COUNT             OUT NOCOPY /* file.sql.39 change */     NUMBER,
    X_MSG_DATA              OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS
x_Qte_Line_Tbl         ASO_QUOTE_PUB.Qte_Line_Tbl_Type := ASO_QUOTE_PUB.G_MISS_QTE_LINE_TBL;
x_Qte_Line_Dtl_Tbl     ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type := ASO_QUOTE_PUB.G_MISS_Qte_Line_Dtl_TBL;
    G_USER_ID                    NUMBER                                   := FND_GLOBAL.USER_ID;
    G_LOGIN_ID                   NUMBER                                   := FND_GLOBAL.CONC_LOGIN_ID;

    L_API_NAME                   VARCHAR2(50)                             := 'Add_Template_To_Quote';
    L_API_VERSION    CONSTANT    NUMBER                                   := 1.0;


BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Add_Template_To_Quote_INT;

    aso_debug_pub.g_debug_flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** Start of Add_Template_To_Quote API ******', 1, 'Y');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
        L_API_VERSION       ,
        P_API_VERSION_NUMBER,
        L_API_NAME          ,
        G_PKG_NAME
    ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    ASO_QUOTE_TMPL_PVT.Add_Template_To_Quote(
    P_API_VERSION_NUMBER    => 1.0,
    P_INIT_MSG_LIST         =>  FND_API.G_FALSE,
    P_COMMIT                =>  FND_API.G_FALSE,
    P_VALIDATION_LEVEL      =>  FND_API.G_VALID_LEVEL_FULL,
    P_UPDATE_FLAG           => 'Y',
    P_TEMPLATE_ID_TBL       => P_TEMPLATE_ID_TBL,
    P_QTE_HEADER_REC        => P_QTE_HEADER_REC,
    P_CONTROL_REC           => P_CONTROL_REC,
    x_Qte_Line_Tbl          => x_Qte_Line_Tbl,
    x_Qte_Line_Dtl_Tbl      => x_Qte_Line_Dtl_Tbl,
    X_RETURN_STATUS         => X_RETURN_STATUS,
    X_MSG_COUNT             => X_MSG_COUNT,
    X_MSG_DATA              => X_MSG_DATA
    );


    -- End of API body
    IF aso_debug_pub.g_debug_flag = 'Y' THEN
    aso_debug_pub.add('****** End of Add_Template_To_Quote API ******', 1, 'Y');
    END IF;

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

        WHEN OTHERS THEN
            ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                P_API_NAME        => L_API_NAME,
                P_PKG_NAME        => G_PKG_NAME,
                P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS,
                P_PACKAGE_TYPE    => ASO_UTILITY_PVT.G_INT,
                P_SQLCODE         => SQLCODE,
                P_SQLERRM         => SQLERRM,
                X_MSG_COUNT       => X_MSG_COUNT,
                X_MSG_DATA        => X_MSG_DATA,
                X_RETURN_STATUS   => X_RETURN_STATUS
            );

END Add_Template_To_Quote;


END ASO_QUOTE_TMPL_INT;


/
