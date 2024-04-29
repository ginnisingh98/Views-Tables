--------------------------------------------------------
--  DDL for Package Body CN_COMMISSION_CALC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMMISSION_CALC_PUB" AS
-- $Header: cnpprcmb.pls 120.1 2005/09/08 00:21:31 rarajara noship $
G_PKG_NAME  VARCHAR2(30) := 'CN_COMMISSION_CALC_PUB';

Procedure calculate_Commission
(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
  x_inc_plnr_disclaimer   OUT NOCOPY  cn_repositories.income_planner_disclaimer%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'calculate_Commission';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_inc_plnr_disclaimer   cn_repositories.income_planner_disclaimer%TYPE ;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER := 0;
  l_msg_data        VARCHAR2(2000) := FND_API.G_MISS_CHAR;

 BEGIN
  null;
End calculate_Commission;

Procedure calculate_Commission
(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
  p_org_id            IN NUMBER,
  x_inc_plnr_disclaimer   OUT NOCOPY  cn_repositories.income_planner_disclaimer%TYPE,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2
) IS
  l_api_name        CONSTANT VARCHAR2(30) := 'calculate_Commission';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_inc_plnr_disclaimer   cn_repositories.income_planner_disclaimer%TYPE ;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER := 0;
  l_msg_data        VARCHAR2(2000) := FND_API.G_MISS_CHAR;

 BEGIN

     SAVEPOINT calculate_Commission;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  -- API body
  --

CN_COMMISSION_CALC_PVT.calculate_Commission(    p_api_version         =>  p_api_version   ,
                                                p_init_msg_list       =>  p_init_msg_list ,
                                                p_org_id              =>  p_org_id,
                                                x_inc_plnr_disclaimer =>  l_inc_plnr_disclaimer   ,
                                                x_return_status       =>  l_return_status ,
                                                x_msg_count           =>  l_msg_count     ,
                                                x_msg_data            =>  l_msg_data
);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    x_inc_plnr_disclaimer := l_inc_plnr_disclaimer;
  END IF;

  --
  -- End of API body
  --
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                      p_data       =>      x_msg_data,
                                      p_encoded    =>      FND_API.G_FALSE );
	l_inc_plnr_disclaimer := FND_API.G_MISS_CHAR;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                      p_data       =>      x_msg_data,
                                      p_encoded    =>      FND_API.G_FALSE );
	l_inc_plnr_disclaimer := FND_API.G_MISS_CHAR;

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.count_and_get(p_count      =>      x_msg_count,
                                      p_data       =>      x_msg_data,
                                      p_encoded    =>      FND_API.G_FALSE );
	l_inc_plnr_disclaimer := FND_API.G_MISS_CHAR;

End calculate_Commission;

END CN_COMMISSION_CALC_PUB;

/
