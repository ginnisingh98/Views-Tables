--------------------------------------------------------
--  DDL for Package Body FLM_SEQ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_SEQ_CUSTOM" AS
/* $Header: FLMSQCPB.pls 115.1 2004/05/21 00:55:12 sshi noship $  */

G_PKG_NAME		CONSTANT VARCHAR2(30) := 'FLM_SEQ_CUSTOM';

PROCEDURE Get_Attribute_Value (
                p_api_version_number    IN      NUMBER,
                p_org_id                IN      NUMBER,
                p_id                    IN      NUMBER,
                p_attribute_id          IN      NUMBER,
                p_attribute_type        IN      NUMBER,
                p_other_id              IN      NUMBER,
                p_other_name            IN      VARCHAR2,
                x_value_num             OUT     NOCOPY NUMBER,
                x_value_name            OUT     NOCOPY VARCHAR2,
                x_return_status         OUT     NOCOPY  VARCHAR2,
                x_msg_count             OUT     NOCOPY  NUMBER,
                x_msg_data              OUT     NOCOPY  VARCHAR2) IS

  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Get_Attribute';

BEGIN

  IF NOT FND_API.Compatible_API_Call
        (       l_api_version_number,
                p_api_version_number,
                l_api_name,
                G_PKG_NAME)
  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_value_num := -1;
  x_value_name := NULL;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Add code here */

  --  Get message count and data
  FND_MSG_PUB.Count_And_Get
  (   p_count   => x_msg_count,
      p_data    => x_msg_data
  );


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Attribute'
            );
    END IF;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

END Get_Attribute_Value;

PROCEDURE Post_Process_demand (
                p_api_version_number    IN      NUMBER,
                p_seq_task_id           IN      NUMBER,
                x_return_status         OUT     NOCOPY  VARCHAR2,
                x_msg_count             OUT     NOCOPY  NUMBER,
                x_msg_data              OUT     NOCOPY  VARCHAR2) IS

  l_api_version_number          CONSTANT NUMBER := 1.0;
  l_api_name                    CONSTANT VARCHAR2(30) := 'Post_Process_demand';

BEGIN

  IF NOT FND_API.Compatible_API_Call
        (       l_api_version_number,
                p_api_version_number,
                l_api_name,
                G_PKG_NAME)
  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Add code here */

  --  Get message count and data
  FND_MSG_PUB.Count_And_Get
  (   p_count   => x_msg_count,
      p_data    => x_msg_data
  );


EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Post_Process_demand'
            );
    END IF;

    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

END Post_Process_demand;


END FLM_SEQ_CUSTOM;

/
