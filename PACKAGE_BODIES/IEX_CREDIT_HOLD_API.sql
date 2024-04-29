--------------------------------------------------------
--  DDL for Package Body IEX_CREDIT_HOLD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CREDIT_HOLD_API" AS
/* $Header: iexvcdhb.pls 120.1 2005/10/12 14:49:51 acaraujo noship $ */

  G_PKG_NAME	  CONSTANT VARCHAR2(30) := 'IEX_CREDIT_HOLD_API';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'iexvcdhb.pls';

  G_APPL_ID       NUMBER ;
  G_LOGIN_ID      NUMBER ;
  G_PROGRAM_ID    NUMBER ;
  G_USER_ID       NUMBER ;
  G_REQUEST_ID    NUMBER ;

  PG_DEBUG NUMBER(2) ;

PROCEDURE UPDATE_CREDIT_HOLD
      (p_api_version      IN  NUMBER := 1.0,
       p_init_msg_list    IN  VARCHAR2 ,
       p_commit           IN  VARCHAR2 ,
       p_account_id       IN  NUMBER,
       p_site_id          IN  NUMBER,
       p_credit_hold      IN  VARCHAR2,
       x_return_status    OUT NOCOPY VARCHAR2,
       x_msg_count        OUT NOCOPY NUMBER,
       x_msg_data         OUT NOCOPY VARCHAR2)
  IS
    l_api_version     CONSTANT   NUMBER := 1.0;
    l_api_name        CONSTANT   VARCHAR2(30) := 'Update_Credit_Hold';
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_return          BOOLEAN;


  BEGIN
    SAVEPOINT	Update_Credit_Hold_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)    THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

	-- Check p_init_msg_list
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Begin - Andre Araujo - Bug#4662279 - Removed since the one in arp_cprof1_pkg has the same function

     --iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update:'||p_account_id||';'||p_site_id||';'||p_credit_hold);
     --iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update:update hz_customer_profiles');
     -- update hz_customer_profiles

     --l_return := arh_cprof1_pkg.update_credit_hold(
     --                p_account_id,
     --                p_site_id,
     --                p_credit_hold) ;

     --if (l_return) then
     --    iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update HZ_CUSTOMER_PROFILES=Y');
     --else
     --    FND_MESSAGE.Set_Name('IEX', 'IEX_CREDIT_HOLD_NOT_UPDATED');
     --    FND_MSG_PUB.Add;
     --    raise FND_API.G_EXC_ERROR;
     --    iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update HZ_CUSTOMER_PROFILES=N');
     --end if;

     --End - Andre Araujo - Bug#4662279 - Removed since the one in arp_cprof1_pkg has the same function

     iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update:update ar_customer_profiles');
     -- update ar_customer_profiles
     l_return := arp_cprof1_pkg.update_credit_hold(
                     p_account_id,
                     p_site_id,
                     p_credit_hold) ;

     if (l_return) then
         iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update HZ_CUSTOMER_PROFILES=Y');
     else
         FND_MESSAGE.Set_Name('IEX', 'IEX_CREDIT_HOLD_NOT_UPDATED');
         FND_MSG_PUB.Add;
         raise FND_API.G_EXC_ERROR;
         iex_dunning_pvt.WriteLog('iexvcdhb.pls:Update HZ_CUSTOMER_PROFILES=N');
     end if;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Credit_Hold_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Credit_Hold_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Update_Credit_Hold_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        iex_dunning_pvt.WriteLog('iexvcdhb.pls:other exception:'||SQLERRM);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END UPDATE_CREDIT_HOLD;


BEGIN
  G_APPL_ID        := FND_GLOBAL.Prog_Appl_Id;
  G_LOGIN_ID       := FND_GLOBAL.Conc_Login_Id;
  G_PROGRAM_ID     := FND_GLOBAL.Conc_Program_Id;
  G_USER_ID        := FND_GLOBAL.User_Id;
  G_REQUEST_ID     := FND_GLOBAL.Conc_Request_Id;

  PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END IEX_CREDIT_HOLD_API;

/
