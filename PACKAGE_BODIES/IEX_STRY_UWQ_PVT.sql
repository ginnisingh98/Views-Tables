--------------------------------------------------------
--  DDL for Package Body IEX_STRY_UWQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRY_UWQ_PVT" as
/* $Header: iexvuwqb.pls 120.0 2004/01/24 03:29:52 appldev noship $ */
-- Start of Comments
-- Package name     : IEX_STRY_UWQ_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT    VARCHAR2(100):=  'IEX_STRY_UWQ_PVT ';
G_FILE_NAME     CONSTANT    VARCHAR2(50) := 'iexvuwqb.pls';


PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

procedure Create_uwq_item(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_work_item_id            IN NUMBER,
    P_strategy_work_item_Rec  IN  IEX_STRATEGY_WORK_ITEMS_PVT.strategy_work_item_Rec_Type ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2) IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


END  Create_Uwq_item;

procedure Update_uwq_item(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_work_item_id            IN NUMBER,
    P_strategy_work_item_Rec  IN  IEX_STRATEGY_WORK_ITEMS_PVT.strategy_work_item_Rec_Type ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2) IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

END  Update_Uwq_item;

END IEX_STRY_UWQ_PVT ;


/
