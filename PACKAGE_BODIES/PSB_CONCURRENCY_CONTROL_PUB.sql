--------------------------------------------------------
--  DDL for Package Body PSB_CONCURRENCY_CONTROL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_CONCURRENCY_CONTROL_PUB" AS
/* $Header: PSBPCCLB.pls 120.2 2005/07/13 11:22:36 shtripat ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_CONCURRENCY_CONTROL_PUB';

/* ----------------------------------------------------------------------- */

PROCEDURE Enforce_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2 := 'MAINTENANCE',
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
) IS

  l_api_name                 CONSTANT VARCHAR2(30)   := 'Enforce_Concurrency_Control';
  l_api_version              CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_concurrency_class => p_concurrency_class,
      p_concurrency_entity_name => p_concurrency_entity_name,
      p_concurrency_entity_id => p_concurrency_entity_id);


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Enforce_Concurrency_Control;

--Added Release Concurrency Control procedure

PROCEDURE Release_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_msg_count                OUT  NOCOPY  NUMBER,
  p_msg_data                 OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2 := 'MAINTENANCE',
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
) IS

  l_api_name                 CONSTANT VARCHAR2(30)   := 'Release_Concurrency_Control';
  l_api_version              CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_concurrency_class => p_concurrency_class,
      p_concurrency_entity_name => p_concurrency_entity_name,
      p_concurrency_entity_id => p_concurrency_entity_id);

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Release_Concurrency_Control;


/* ----------------------------------------------------------------------- */

END PSB_CONCURRENCY_CONTROL_PUB;

/
