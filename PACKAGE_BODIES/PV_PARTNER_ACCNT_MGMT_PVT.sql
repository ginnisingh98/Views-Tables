--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ACCNT_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ACCNT_MGMT_PVT" as
/* $Header: pvxvpamb.pls 120.4 2005/11/28 13:32:17 dgottlie ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_PARTNER_ACCNT_MGMT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpamb.pls';

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Customer_Account(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,P_partner_party_id  IN  NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_acct_id           OUT NOCOPY NUMBER
 )
 IS
  l_api_version CONSTANT  NUMBER       := 1.0;
  l_api_name    CONSTANT  VARCHAR2(45) := 'Create_Customer_Account';
  l_full_name   CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


  CURSOR C_party_info (l_party_id NUMBER) IS
    SELECT party_name, party_number
    FROM  hz_parties
    WHERE party_id = l_party_id
    AND   party_type = 'ORGANIZATION';

   account_rec	      HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
   organization_rec   HZ_PARTY_V2PUB.organization_rec_type;
   cust_profile_rec   HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
   p_party_rec        HZ_PARTY_V2PUB.party_rec_type;


   l_party_number      VARCHAR2(30);
   l_party_name        VARCHAR2(240);
   l_gen_cust_num      VARCHAR2(3);
   l_account_number    VARCHAR2(30);
   l_party_id          NUMBER;
   l_profile_id	       NUMBER;

    BEGIN
---- Initialize---------------------

   SAVEPOINT CREATE_CUSTOMER_ACCOUNT;

   x_return_status := FND_API.g_ret_sts_success;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

  IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

    -- figure out if the party type and party_name. party_type has to be an organization
     OPEN C_party_info(p_partner_party_id);
       FETCH C_party_info INTO l_party_name, l_party_number;
          IF (C_party_info%NOTFOUND) THEN
              FND_MESSAGE.Set_Name('PV', 'PV_INVALID_PARTNER_PARTY_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'PARTY ID', FALSE);
              FND_MSG_PUB.ADD;
	      raise FND_API.G_EXC_ERROR;
          END IF;
       CLOSE C_party_info;


    account_rec.Created_by_Module := 'PV';
    organization_rec.Created_by_Module := 'PV';
    cust_profile_rec.Created_by_Module := 'PV';

  -- if needed generate account_number.
    SELECT generate_customer_number INTO l_gen_cust_num FROM ar_system_parameters;

   -- typically should be set to 'Y' if no we will try to create a new one.
   -- however, this could error out
   -- Is this needed????

      IF l_gen_cust_num = 'N' THEN
           account_rec.account_number := 'PV'|| l_party_number;
      END IF;

    account_rec.account_name := l_party_name;
    organization_rec.party_rec := p_party_rec;
    organization_rec.party_rec.party_id := p_partner_party_id;

      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
      p_init_msg_list                         => FND_API.G_FALSE,
      p_cust_account_rec                      => account_rec,
      p_organization_rec                      => organization_rec,
      p_customer_profile_rec                  => cust_profile_rec,
      p_create_profile_amt                    => 'Y',
      x_cust_account_id                       => x_acct_id,
      x_account_number                        => l_account_number,
      x_party_id                              => l_party_id	,
      x_party_number                          => l_party_number,
      x_profile_id                            => l_profile_id,
      x_return_status                         => x_return_status,
      x_msg_count                             => x_msg_count,
      x_msg_data                              => x_msg_data  );

      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('create cust_acct: l_acct_id '||x_acct_id);
      PVX_UTILITY_PVT.debug_message('create cust_acct: x_return_status '||x_return_status);

      END IF;


      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
      END IF;


    FND_MSG_PUB.Count_And_Get
      (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

    IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
    END IF;


    EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO CREATE_CUSTOMER_ACCOUNT;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO CREATE_CUSTOMER_ACCOUNT;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO CREATE_CUSTOMER_ACCOUNT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

 END Create_Customer_Account;


 PROCEDURE Create_ACCT_SITE (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_Cust_Account_Id NUMBER
  ,p_Party_Site_Id NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_customer_site_id  OUT NOCOPY NUMBER
  )
  IS

  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(45) := 'Create_ACCT_SITE';

  -- acct site need not be verified
  CURSOR C_acct_site (l_account_id NUMBER, l_site_id NUMBER) IS
     SELECT cust_acct_site_id
     FROM hz_cust_acct_sites
     WHERE cust_account_id = l_Account_Id
     AND party_site_id    = l_Site_Id;

   p_acct_site_Rec           HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;

  BEGIN
   ---- Initialize---------------------
   SAVEPOINT CREATE_ACCT_SITE;

   x_return_status := FND_API.g_ret_sts_success;


   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;


    Open C_acct_site (p_cust_account_id, p_party_site_id);
    Fetch C_acct_site into x_customer_site_id;
    IF (C_acct_site%NOTFOUND) THEN
      p_acct_site_rec.cust_account_id := P_cust_account_id;
      p_acct_site_rec.party_site_id   := P_party_site_id;
      --p_acct_site_rec.status	      := 'A';
      p_acct_site_Rec.created_by_module := 'PV';
      p_acct_site_Rec.org_id := mo_global.get_current_org_id;


      HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
        p_init_msg_list                         => FND_API.G_FALSE,
        p_cust_acct_site_rec                    => p_acct_site_rec,
        x_cust_acct_site_id                     => x_customer_site_id,
        x_return_status                         => x_return_status,
        x_msg_count                             => x_msg_count,
        x_msg_data                              => x_msg_data  );

      IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('create acct_site: x_return_status '||x_return_status);
      END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

   Close C_acct_site;
   PVX_UTILITY_PVT.debug_message('create acct_site:after create_site:x_customer_site_id '||x_customer_site_id);

   FND_MSG_PUB.Count_And_Get
   (  p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

    IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;


   EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO CREATE_ACCT_SITE;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO CREATE_ACCT_SITE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO CREATE_ACCT_SITE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

  END Create_acct_site;



PROCEDURE Create_Party_Site_Use(
    p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.g_false,
    p_commit               IN   VARCHAR2  := FND_API.g_false,
    p_party_site_id	   IN	NUMBER,
    p_party_site_use_type  IN   VARCHAR2,
    x_party_site_use_id	   OUT NOCOPY NUMBER,
    x_return_status	   OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY  NUMBER,
    x_msg_data             OUT NOCOPY  VARCHAR2)
IS

    l_api_name              CONSTANT VARCHAR2(45) := 'Create_Party_Site_Use';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_party_site_use_rec    HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;

BEGIN
    SAVEPOINT CREATE_PARTY_SITE_USE;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
        l_api_version,
        p_api_version,
        l_api_name,
        g_pkg_name
    ) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;


   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('create_pty_site_use: p_party_site_id ' || p_party_site_id);
   PVX_UTILITY_PVT.debug_message('create_pty_site_use: p_party_site_use_type ' || p_party_site_use_type);
   END IF;

   l_party_site_use_rec.party_site_id := p_party_site_id;
   l_party_site_use_rec.site_use_type := p_party_site_use_type;
   l_party_site_use_rec.Created_by_Module := 'PV';

    HZ_PARTY_SITE_V2PUB.create_party_site_use (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_party_site_use_rec            => l_party_site_use_rec,
    x_party_site_use_id             => x_party_site_use_id,
    x_return_status                 => x_return_status,
    x_msg_count                     => x_msg_count,
    x_msg_data                      => x_msg_data  );



   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('create_pty_site_use: x_party_site_use_id ' || x_party_site_use_id);
   PVX_UTILITY_PVT.debug_message('create_pty_site_use: x_return_status ' || x_return_status);
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
   END IF;

   FND_MSG_PUB.Count_And_Get
   (      p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
    );


   IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;


   EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO CREATE_PARTY_SITE_USE;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO CREATE_PARTY_SITE_USE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO CREATE_PARTY_SITE_USE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


END Create_Party_Site_Use;

/* R12 Changes
 * Added out parameter x_cust_acct_site_id since we plan
 * on passing this value around
*/
PROCEDURE Create_ACCT_SITE_USES (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,P_Cust_Account_Id   IN  NUMBER
  ,P_Party_Site_Id     IN  NUMBER
  ,P_Acct_Site_type    IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_site_use_id  OUT NOCOPY NUMBER
  ,x_cust_acct_site_id OUT NOCOPY NUMBER
  )
     IS
       CURSOR C_site_use(l_acct_site_id NUMBER, l_site_type VARCHAR2) IS
         SELECT site_use_id
         FROM hz_cust_site_uses
         WHERE cust_acct_site_id = l_acct_site_id
         AND site_use_code = l_site_type;

       CURSOR party_site_use(l_party_site_id NUMBER, l_site_type VARCHAR2) IS
         SELECT party_site_use_id
         FROM hz_party_site_uses
         WHERE party_site_id = l_party_site_id
         AND site_use_type = l_Site_type;

       CURSOR C_location(l_party_site_id NUMBER) IS
        Select hzl.city
        From hz_locations hzl,hz_party_sites hps
        Where hps.party_site_id = l_party_site_id
        And hzl.location_id = hps.location_id;


        l_api_version CONSTANT NUMBER       := 1.0;
        l_api_name    CONSTANT VARCHAR2(45) := 'Create_ACCT_SITE_USES';

        l_location          VARCHAR2(60);
        l_profile varchar2(1);
        l_party_site_use_id number;

        p_acct_site_uses_Rec  HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
        p_cust_profile_rec    HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;



    BEGIN

        ---- Initialize---------------------

     SAVEPOINT CREATE_ACCT_SITE_USES;

     x_return_status := FND_API.g_ret_sts_success;

     IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
     ) THEN
      RAISE FND_API.g_exc_unexpected_error;
     END IF;


   -- Intializing created_by_module as required in version 2 api for the record structure

     IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message('create acct_site_use:l_cust_account_id '||p_cust_account_id);

    END IF;


        Create_ACCT_SITE(p_api_version       => 1.0
                        ,p_Cust_Account_Id  => p_cust_account_id
                        ,p_Party_Site_Id => p_party_site_id
                        ,x_return_status => x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      =>   x_msg_data
                        ,x_customer_site_id  => x_cust_acct_site_id
                        );


    IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message('create acct_site_use:after create_site:x_return_status '||x_return_status);
    PVX_UTILITY_PVT.debug_message('create acct_site_use:after create_site:x_cust_acct_site_id '||x_cust_acct_site_id);


    END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;


    Open C_site_use(x_cust_acct_site_id, p_acct_site_type);
       Fetch C_site_use into x_site_use_id;
       IF (C_site_use%NOTFOUND) THEN

        OPEN C_location(p_party_site_id);
        FETCH C_location into l_location;
        IF (C_location%NOTFOUND) THEN
          l_location := 'NO_LOCATION';
        END IF;
        CLOSE C_location;

        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('create acct_site_use:l_location '||l_location);

        END IF;

        SELECT AUTO_SITE_NUMBERING INTO l_profile FROM AR_SYSTEM_PARAMETERS;

        IF l_profile = 'N' then
           p_acct_site_uses_Rec.location := substr(p_acct_Site_type ||' ' ||
								    l_location ||' ' ||
					 to_char(x_cust_acct_site_id), 1, 40) ;
        END IF;

            p_acct_site_uses_Rec.cust_acct_site_id := x_cust_acct_site_id;
            p_acct_site_uses_Rec.site_use_code    := p_acct_site_type ;
	    p_acct_site_uses_Rec.org_id := mo_global.get_current_org_id;
            p_acct_site_uses_Rec.created_by_module := 'PV';
            p_cust_profile_rec.created_by_module := 'PV';

         HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
           p_init_msg_list                         => FND_API.G_FALSE,
           p_cust_site_use_rec                     => p_acct_site_uses_rec,
           p_customer_profile_rec                  => p_cust_profile_rec,
           p_create_profile                        => FND_API.G_TRUE,
           p_create_profile_amt                    => FND_API.G_TRUE,
           x_site_use_id                           => x_site_use_id,
           x_return_status                         => x_return_status,
           x_msg_count                             => x_msg_count,
           x_msg_data                              => x_msg_data  );

        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('create acct_site_use:create_acct_site_use:x_return_status '||x_return_status );

        PVX_UTILITY_PVT.debug_message('create acct_site_use:create_acct_site_use:x_site_use_id '||x_site_use_id);
        END IF;

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF; -- x_site_use not null


     Close C_site_use;

     IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('create acct_site_use:x_site_use_id '||x_site_use_id);
     END IF;



     IF (p_party_site_id IS NOT NULL AND p_party_site_id <> FND_API.G_MISS_NUM) AND
        (p_acct_site_type IS NOT NULL AND p_acct_site_type <> FND_API.G_MISS_CHAR) THEN

           OPEN party_site_use(p_party_site_id,p_acct_site_type);
           FETCH party_site_use into l_party_site_use_id;
           CLOSE party_site_use;

          IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('create acct_site_use:create_party_site_use:l_party_site_use_id '||l_party_site_use_id);
          END IF;

           IF l_party_site_use_id = NULL  then
              Create_Party_Site_Use(
                p_api_version          => 1.0,
            	p_party_site_id	       => p_party_site_id,
                p_party_site_use_type  => p_acct_site_type,
		 x_party_site_use_id =>  l_party_site_use_id,
               	x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data);

             IF (PV_DEBUG_HIGH_ON) THEN

               PVX_UTILITY_PVT.debug_message('create acct_site_use: create_party_site_use: x_return_status '|| x_return_status);
             END IF;
           END IF;

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;---End of Party Site conditions



    FND_MSG_PUB.Count_And_Get
      (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

       IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;

     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO  CREATE_ACCT_SITE_USES;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO  CREATE_ACCT_SITE_USES;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO  CREATE_ACCT_SITE_USES;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   END Create_acct_site_uses;



PROCEDURE Create_Contact_Role ( p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_party_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_Cust_account_id     IN  NUMBER
  ,p_cust_account_site_id IN NUMBER  := FND_API.G_MISS_NUM
  ,p_Role_type           IN       VARCHAR2 := 'CONTACT'
  ,p_responsibility_type IN VARCHAR2 := FND_API.G_MISS_CHAR
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,x_cust_account_role_id OUT NOCOPY NUMBER
)
IS
  l_api_version CONSTANT NUMBER       := 1.0;
  l_api_name    CONSTANT VARCHAR2(45) := 'Create_Contact_Role';

  p_cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;
  p_role_resp_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;
  l_responsibility_id NUMBER;

  CURSOR C_Get_Resp(role_id NUMBER, resp_type VARCHAR2) IS
   SELECT responsibility_id
   FROM hz_role_responsibility
   WHERE cust_account_role_id = role_id
   AND responsibility_type = resp_type;

 BEGIN
    SAVEPOINT CREATE_CONTACT_ROLE;

      x_return_status := FND_API.g_ret_sts_success;

    IF FND_API.to_boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;



   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('create_contact_role: p_party_id: '||p_party_id);
   PVX_UTILITY_PVT.debug_message('create_contact_role: p_cust_account_id: '||p_cust_account_id);
   PVX_UTILITY_PVT.debug_message('create_contact_role: p_cust_account_site_id: '||p_cust_account_site_id);
   PVX_UTILITY_PVT.debug_message('create_contact_role: p_role_type: '||p_role_type);
   END IF;

   p_cust_acct_roles_rec.party_id        := p_party_id;
   p_cust_acct_roles_rec.cust_account_id := p_cust_account_id;
   p_cust_acct_roles_rec.role_type       := p_role_type;
   p_cust_acct_roles_rec.cust_acct_site_id := p_cust_account_site_id;
   p_cust_acct_roles_rec.Created_by_Module := 'PV';
   p_role_resp_rec.Created_by_Module := 'PV';


   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('before create cust acct roles');
   END IF;

    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_account_role_rec                 => p_cust_acct_roles_rec,
    x_cust_account_role_id                  => x_cust_account_role_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );

    IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message('create_contact_role:after create_cust_acct_role: x_return_status: '||x_return_status);

    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

 IF(p_responsibility_type IS NOT NULL and p_responsibility_type <> FND_API.G_MISS_CHAR) THEN
 OPEN C_Get_Resp(x_cust_account_role_id, p_responsibility_type);
 FETCH C_Get_Resp INTO l_responsibility_id;

 IF C_Get_Resp%NOTFOUND THEN

   IF p_cust_account_site_id is not NULL AND
      p_cust_account_site_id <>  FND_API.G_MISS_NUM THEN
      p_role_resp_rec.cust_account_role_id := x_cust_account_role_id;
      p_role_resp_rec.responsibility_type := p_responsibility_type;

    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
    p_init_msg_list                         =>  FND_API.G_FALSE,
    p_role_responsibility_rec               => p_role_resp_rec,
    x_responsibility_id                     => l_responsibility_id,
    x_return_status                         => x_return_status,
    x_msg_count                             => x_msg_count,
    x_msg_data                              => x_msg_data  );


    IF (PV_DEBUG_HIGH_ON) THEN
    PVX_UTILITY_PVT.debug_message('create_contact_role:after create_role_resp: x_return_status: '||x_return_status);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
    END IF;

   END IF; --Cust_account_site_id is not null
 END IF;--C_Get_Resp%NOTFOUND
 CLOSE C_Get_Resp;
 END IF; --p_responsibility_type is not null

   FND_MSG_PUB.Count_And_Get
   (  p_encoded => FND_API.G_FALSE ,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

    IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;

EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO  CREATE_CONTACT_ROLE;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO  CREATE_CONTACT_ROLE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO  CREATE_CONTACT_ROLE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
          -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

END Create_Contact_Role;




PROCEDURE Get_Partner_Accnt_Id(
   p_Partner_Party_Id  IN  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_Cust_Acct_Id  OUT NOCOPY NUMBER
)
 IS

   CURSOR C_get_partner_accnt_id(l_Party_Id NUMBER) IS
     SELECT cust_account_id
     FROM hz_cust_accounts
     WHERE party_id = l_Party_Id
     and status = 'A';

 l_msg_count        number;
 l_msg_data         varchar2(200);

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;


IF (p_partner_party_id = FND_API.G_MISS_NUM or p_partner_party_id IS NULL) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_PARTNER_PARTY_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
END IF;


OPEN C_get_partner_accnt_id(p_partner_Party_Id);
LOOP
  FETCH C_get_partner_accnt_id INTO x_Cust_Acct_Id;
  IF x_Cust_Acct_Id IS NOT NULL and x_Cust_Acct_Id <> FND_API.G_MISS_NUM  THEN
   exit;
  END IF;
  EXIT WHEN C_get_partner_accnt_id%NOTFOUND;
END LOOP;
CLOSE C_get_partner_accnt_id;

IF x_Cust_Acct_Id IS NULL OR x_Cust_Acct_Id = FND_API.G_MISS_NUM THEN
       Create_Customer_Account(
               p_api_version      => 1.0
              ,P_partner_party_id => p_partner_party_id
              ,x_return_status    => x_return_status
              ,x_msg_count        => l_msg_count
              ,x_msg_data         => l_msg_data
              ,x_acct_id          => x_Cust_Acct_Id
              );

      IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('x_return_status from Create_customer_account :  ' || x_return_status);
      END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;
END IF;

END Get_Partner_Accnt_Id;


/* R12 Changes
 * Added out parameter x_cust_acct_site_id which
 * will be passed to calls to get_cust_acct_roles
 * throughout procedeure, any reference to
 * l_cust_acct_site_id is a result of this R12 change
 * Removed references to cursor party_cur since the same
 * functionality will be taken care of before this procedure
 * is ever called
 * parameter p_partner_party_id changed to p_partner_id since
 * in R12, this procedure can be called using either an organization
 * or contact address
*/
PROCEDURE  get_acct_site_uses(
  p_party_site_id IN NUMBER,
  p_acct_site_type IN VARCHAR2,
  p_cust_account_id IN NUMBER,
  p_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_site_use_id OUT NOCOPY number,
  x_cust_acct_site_id OUT NOCOPY NUMBER
)
IS

 CURSOR site_use_cur IS
  select a.site_use_id, a.cust_acct_site_id
  from hz_cust_site_uses a, hz_cust_acct_sites b
  where b.cust_account_id = p_cust_account_id
  and b.party_site_id = p_party_site_id
  and a.cust_acct_site_id = b.cust_acct_site_id
  and a.site_use_code = p_acct_site_type
  and a.status = 'A'
  and b.status = 'A';

  l_msg_count        number;
  l_msg_data         varchar2(200);

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message('site use in get_acct_site_uses = ' || p_acct_site_type);

  END IF;

  OPEN site_use_cur;
  FETCH site_use_cur INTO x_site_use_id, x_cust_acct_site_id;

  IF (site_use_cur%NOTFOUND) THEN

      Create_ACCT_SITE_USES(
               p_api_version      => 1.0
              ,P_Cust_Account_Id  =>  p_cust_account_id
              ,P_Party_Site_Id    => p_party_site_id
 	          ,P_Acct_Site_type   =>  p_acct_site_type
              ,x_return_status     => x_return_status
	       ,x_msg_count        => l_msg_count
              ,x_msg_data         => l_msg_data
              ,x_site_use_id       => x_site_use_id
	          ,x_cust_acct_site_id => x_cust_acct_site_id
              );

           IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('x_return_status from Create_ACCT_SITE_USES :  ' || x_return_status);
	   END IF;

           IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

  END IF;
  close site_use_cur;

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('site_use_id in get_acct_site_uses = ' || x_site_use_id);
   END IF;

END get_acct_site_uses;

/* R12 Changes
 * p_cust_account_site_id is no longer null as we will start passing
 * this value in as per OM
 * Removed paramter p_acct_site_type and any references to it in the procedure
 * Removed reference to hz_role_responsibility from cursor cust_role
 * Removed reference to cursor cust_role_wo_party_site
*/
PROCEDURE get_cust_acct_roles(
  p_contact_party_id IN NUMBER,
  p_cust_account_site_id IN NUMBER,
  p_cust_account_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_cust_account_role_id OUT NOCOPY number
)
IS


CURSOR cust_role IS
 select a.cust_account_role_id
 from hz_cust_account_roles a,  hz_cust_acct_sites c
 where a.role_type = 'CONTACT'
 and a.party_id = p_contact_party_id
 and a.cust_account_id = p_cust_account_id
 and a.cust_acct_site_id = c.cust_acct_site_id
 and c.cust_acct_site_id = p_cust_account_site_id
 and a.cust_account_id = c.cust_account_id
 and c.status = 'A'
 and a.status = 'A';

  l_msg_count        number;
 l_msg_data         varchar2(200);


begin

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('p_contact_party_id = ' || p_contact_party_id);
 END IF;


 IF (p_cust_account_site_id IS NULL and p_cust_account_site_id <> FND_API.G_MISS_NUM) THEN
         FND_MESSAGE.Set_Name('PV', 'PV_CUST_ACCOUNT_ROLE_ERROR');
         FND_MESSAGE.Set_Token('ID', to_char( p_contact_party_id), FALSE);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

   OPEN cust_role;
   FETCH cust_role INTO x_cust_account_role_id;

   IF (cust_role%NOTFOUND) THEN

     Create_Contact_Role (
        p_api_version         =>   1.0
       ,p_party_id            => p_contact_party_id
       ,p_Cust_account_id     =>  p_cust_account_id
       ,p_cust_account_site_id => p_cust_account_site_id
       ,p_Role_type          => 'CONTACT'
       ,p_responsibility_type => NULL
       ,x_return_status     => x_return_status
       ,x_msg_count        => l_msg_count
       ,x_msg_data         => l_msg_data
       ,x_cust_account_role_id => x_cust_account_role_id
      );

  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message('x_return_status from get_cust_acct_roles = '|| x_return_status);

  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

END IF;
CLOSE cust_role;
IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message('x_cust_account_role_id in get_cust_acct_roles = '|| x_cust_account_role_id);

END IF;


END get_cust_acct_roles;


PROCEDURE Create_Party_Site(
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
        p_commit            IN  VARCHAR2  := FND_API.g_false,
        p_party_site_rec        IN      PARTY_SITE_REC_TYPE,
        x_return_status         OUT NOCOPY     VARCHAR2,
	x_party_site_id         OUT NOCOPY     NUMBER,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
)
IS

   /* CURSOR c_site_use_type(p_type_name VARCHAR2) IS
        SELECT site_use_type_id FROM HZ_SITE_USE_TYPES
        WHERE name = p_type_name;*/

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name                  VARCHAR2(40) := 'Create_Party_Site';
    l_site_use_type_id          NUMBER;
    l_location_rec              HZ_LOCATION_V2PUB.Location_Rec_Type;
    l_location_id               NUMBER;
    l_party_site_rec            HZ_PARTY_SITE_V2PUB.Party_Site_Rec_Type;
    l_party_site_use_rec        HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;
    l_party_site_use_id         NUMBER;
    l_party_site_number         NUMBER;

BEGIN
    SAVEPOINT CREATE_PARTY_SITE;

    IF FND_API.to_boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
    ) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    l_party_site_rec.Created_by_Module := 'PV';
    l_party_site_use_rec.Created_by_Module := 'PV';
    l_location_rec.Created_by_Module := 'PV';


    l_location_rec.address1 := p_party_site_rec.location.address1;
    l_location_rec.address2 := p_party_site_rec.location.address2;
    l_location_rec.address3 := p_party_site_rec.location.address3;
    l_location_rec.address4 := p_party_site_rec.location.address4;
    l_location_rec.country      := p_party_site_rec.location.country;
    l_location_rec.city        := p_party_site_rec.location.city;
    l_location_rec.postal_code := p_party_site_rec.location.postal_code;
    l_location_rec.state       := p_party_site_rec.location.state;
    l_location_rec.province    := p_party_site_rec.location.province;
    l_location_rec.county      := p_party_site_rec.location.county;


    l_location_rec.ORIG_SYSTEM_REFERENCE := -1;
    l_location_rec.CONTENT_SOURCE_TYPE := 'USER_ENTERED';

    HZ_LOCATION_V2PUB.create_location (
    p_init_msg_list                    =>  FND_API.G_FALSE,
    p_location_rec                      => l_location_rec,
    x_location_id                       => l_location_id,
    x_return_status                    => x_return_status,
    x_msg_count                        => x_msg_count ,
    x_msg_data                          => x_msg_data );


   IF (PV_DEBUG_HIGH_ON) THEN
   PVX_UTILITY_PVT.debug_message('create_party_site:after create_loc:l_location_id '||l_location_id);
   PVX_UTILITY_PVT.debug_message('create_party_site:after create_loc:x_return_status '||x_return_status);
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
   END IF;

        l_party_site_rec.party_id := p_party_site_rec.party_id;
        l_party_site_rec.location_id := l_location_id;
        l_party_site_rec.identifying_address_flag := p_party_site_rec.primary_flag;

     HZ_PARTY_SITE_V2PUB.create_party_site (
       p_init_msg_list                 => FND_API.G_FALSE,
       p_party_site_rec                => l_party_site_rec,
       x_party_site_id                 => x_party_site_id,
       x_party_site_number             => l_party_site_number,
       x_return_status                 => x_return_status,
       x_msg_count                     => x_msg_count,
       x_msg_data                      => x_msg_data );


     IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('create_party_site:after create_site:x_party_site_id '||x_party_site_id);

     PVX_UTILITY_PVT.debug_message('create_party_site:after create_site:x_return_status '||x_return_status);
     END IF;

IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

         l_party_site_use_rec.party_site_id := x_party_site_id;
         l_party_site_use_rec.site_use_type := p_party_site_rec.party_site_use_type;


        HZ_PARTY_SITE_V2PUB.create_party_site_use (
          p_init_msg_list                 => FND_API.G_FALSE,
          p_party_site_use_rec            => l_party_site_use_rec,
          x_party_site_use_id             => l_party_site_use_id,
          x_return_status                 => x_return_status,
          x_msg_count                     => x_msg_count,
          x_msg_data                      => x_msg_data );



      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('create_party_site:after create_site_use:x_return_status '||x_return_status);

      PVX_UTILITY_PVT.debug_message('create_party_site:after create_site_use:l_party_site_use_id '||l_party_site_use_id);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    FND_MSG_PUB.Count_And_Get
    (    p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
    );

     IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;

    EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO  CREATE_PARTY_SITE;
         x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO  CREATE_PARTY_SITE;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
	  );

        WHEN OTHERS THEN
          ROLLBACK TO  CREATE_PARTY_SITE;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
	  -- Standard call to get message count and if count=1, get the message
          FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

END Create_Party_Site;


END PV_PARTNER_ACCNT_MGMT_PVT;

/
