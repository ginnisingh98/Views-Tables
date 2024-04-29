--------------------------------------------------------
--  DDL for Package Body PSB_DE_CLIENT_EXTENSIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_DE_CLIENT_EXTENSIONS_PUB" AS
/*$Header: PSBVCLEB.pls 120.1 2003/03/28 20:28:04 krajagop noship $*/

  G_PKG_NAME CONSTANT          VARCHAR2(30):= 'PSB_DE_Client_Extensions_Pub';

/*===========================================================================+
 |                         PROCEDURE Run_Client_Extension_Pub                          |
 +===========================================================================*/
--
-- This is the placeholder API and does nothing. If required, the clients
-- will implement this API to provide desired customization.
--
PROCEDURE Run_Client_Extension_Pub
(
  p_api_version                IN    NUMBER,
  p_init_msg_list              IN    VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN    VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY   VARCHAR2,
  x_msg_count                  OUT NOCOPY   NUMBER,
  x_msg_data                   OUT NOCOPY   VARCHAR2,
  --
  p_data_extract_id            IN    NUMBER,
  p_mode                       IN    VARCHAR2
)
IS
  --
  l_api_name            CONSTANT   VARCHAR2(30) := 'Run_Client_Extension_Pub';
  l_api_version         CONSTANT   NUMBER       :=  1.0;
  --
  l_return_status                    VARCHAR2(1);
  l_msg_count                        NUMBER;
  l_msg_data                         VARCHAR2(2000);
  --

BEGIN

  --
  -- Begin standard API section.
  --

  SAVEPOINT Run_Client_Extension ;
  --
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
				       p_api_version,
				       l_api_name,
				       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  --

  --
  -- End standard API section.
  --

  --
  -- Begin client extension.
  --
  --
  -- End client extension.
  --

  --
  -- Down below are again the standard end and exception sections of the API.
  --

  --
  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;
  --
  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
			      p_data  => x_msg_data );
  --
EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK TO Run_Client_Extension ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --
    ROLLBACK TO Run_Client_Extension ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
  --
  WHEN OTHERS THEN
    --
    ROLLBACK TO Run_Client_Extension ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
				l_api_name);
    END if;
    --
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				p_data  => x_msg_data );
   --
END Run_Client_Extension_Pub ;
/*---------------------------------------------------------------------------*/


END PSB_DE_Client_Extensions_Pub ;

/
