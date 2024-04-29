--------------------------------------------------------
--  DDL for Package IEX_STRY_UWQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRY_UWQ_PVT" AUTHID CURRENT_USER as
/* $Header: iexvuwqs.pls 120.0 2004/01/24 03:29:54 appldev noship $ */


/**
 * will call UWQ package
 **/

procedure Create_uwq_item(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_Work_item_id            IN  number,
    P_strategy_work_item_Rec  IN  IEX_STRATEGY_WORK_ITEMS_PVT.strategy_work_item_Rec_Type ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);


procedure Update_uwq_item(
    p_api_version             IN  NUMBER := 1.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_Work_item_id            IN  number,
    P_strategy_work_item_Rec  IN  IEX_STRATEGY_WORK_ITEMS_PVT.strategy_work_item_Rec_Type ,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

END IEX_STRY_UWQ_PVT;

 

/
