--------------------------------------------------------
--  DDL for Package Body IBE_CUSTOMER_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CUSTOMER_ACCT_PVT" AS
/* $Header: IBEVCACB.pls 120.4.12010000.3 2014/12/16 06:46:43 kdosapat ship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_CUSTOMER_ACCT_PVT';
 l_true VARCHAR2(1)                := FND_API.G_TRUE;

 PROCEDURE GetPartySiteId(
                         p_api_version_number IN  NUMBER,
                         p_init_msg_list      IN  VARCHAR2,
                         p_commit             IN  VARCHAR2,
                         p_party_id           IN  NUMBER,
                         p_site_use_type      IN  VARCHAR2,
                         x_party_site_id      OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2)
 IS

  l_hr_type         VARCHAR2(30) := ' ';

  --l_orgId1          number := SUBSTRB(USERENV('CLIENT_INFO'),1,1);
  --l_orgId2          number := SUBSTRB(USERENV('CLIENT_INFO'),1,10);

  l_return_values    varchar2(2000);
  l_api_version      NUMBER := 1.0;
  l_api_name         VARCHAR2(30) := 'CUSTACCT_GETPARTYSITEID';

-- 14763493 INTERMITTENTLY SHIP-TO ERROR WHILE CREATING RMA
  /*CURSOR c_getOrgId
  IS
   SELECT  NVL(TO_NUMBER(DECODE(l_orgId1,' ',NULL,l_orgId2)),-99) orgId from dual;
   */

  l_orgId NUMBER;

  -- 4922991. CHECK FOR HZ_CUST_SITE_USES.STATUS='I' MAY NOT BE CORRECT IN SOME CASES
  -- added site_use_type condition check in where clause for bug 20140806 fix
  CURSOR C_address(c_party_id      NUMBER,
                   c_site_use_type VARCHAR2,
                   c_hr_type       VARCHAR2,
                   c_org_id        NUMBER)
  IS
  SELECT  DECODE(site_use_type, c_site_use_type, 1, 2)  first_orderby,
          DECODE(primary_per_type,'Y', 1, 2)            second_orderby,
          party_site_id,
          site_use_type,
          primary_per_type
  FROM (
      SELECT party_site_id, ps.site_use_type, ps.primary_per_type
      FROM   hz_party_sites_v ps, hr_organization_information hr
      WHERE ps.party_id = c_party_id
      AND   ps.status = 'A'
      AND   ps.site_use_type = c_site_use_type
      AND   nvl(ps.end_date_active, sysdate + 1) > sysdate
      AND   hr.organization_id = c_org_id
      AND   hr.org_information_context = c_hr_type
      AND   hr.org_information1 = ps.country
      UNION
      SELECT party_site_id, ps.site_use_type, ps.primary_per_type
      FROM hz_party_sites_v ps
      WHERE ps.party_id = c_party_id
      AND   ps.status = 'A'
      AND   ps.site_use_type = c_site_use_type
      AND   nvl(ps.end_date_active,sysdate + 1) > sysdate
      AND   NOT EXISTS (
            SELECT 1
            FROM   hr_organization_information hr
            WHERE  hr.organization_id = c_org_id
            AND    hr.org_information_context = c_hr_type
            AND    rownum = 1
            )
  ) o
  WHERE  ( NOT EXISTS (SELECT 1 FROM hz_party_site_uses psu
	                WHERE psu.party_site_id = o.party_site_id
                         AND  psu.site_use_type = o.site_use_type
	               )   OR
	        EXISTS (SELECT 1 FROM hz_party_site_uses psu
			 WHERE psu.party_site_id = o.party_site_id
			   AND psu.site_use_type = o.site_use_type
		           AND psu.status = 'A')
         )
  AND   ( NOT EXISTS (SELECT 1 FROM hz_cust_acct_sites cas
	                   WHERE cas.party_site_id = o.party_site_id
	                 )   OR
	                 (EXISTS (SELECT 1 FROM hz_cust_acct_sites cas
			           where cas.party_site_id = o.party_site_id
				         and cas.status = 'A')
				         AND
			         ( NOT EXISTS (SELECT 1 FROM hz_cust_acct_sites cas, hz_cust_site_uses_all csu
			                 WHERE csu.cust_acct_site_id = cas.cust_acct_site_id
                                           AND cas.party_site_id = o.party_site_id
                                           AND cas.org_id =  csu.org_id
                                           AND csu.site_use_code = o.site_use_type)
					   OR
			           EXISTS ( SELECT 1
                                              FROM hz_cust_acct_sites_all cas, hz_cust_site_uses_all csu
                                             WHERE cas.party_site_id = o.party_site_id
					       AND cas.org_id =  csu.org_id
					       AND  csu.cust_acct_site_id  = cas.cust_acct_site_id
					       AND  csu.status = 'A'
					       AND  csu.site_use_code= o.site_use_type
					   )
			           )
			  )
	   )
 ORDER BY 1,2;


 l_address C_address%ROWTYPE;

BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_Util.debug('Begin IBE_CUSTOMER_ACCT_PVT:GetPartySiteId');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT  CUSTACCT_GETPARTYSITEID;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

  IF (p_site_use_type = 'SHIP_TO') THEN
     l_hr_type      := 'SHIP_TO_COUNTRY';
  END IF;
  IF (p_site_use_type = 'BILL_TO') THEN
     l_hr_type      := 'BILL_TO_COUNTRY';
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_Util.debug('Modified C_address for bug 20140806 ');
    Ibe_Util.debug('before calling c_address p_site_use_type:' || p_site_use_type);
    Ibe_Util.debug('p_party_id:' || p_party_id);
    Ibe_Util.debug('l_hr_type:' || l_hr_type);
    Ibe_Util.debug('l_orgId:' || l_orgId);
  END IF;

  OPEN C_address(p_party_id, p_site_use_type, l_hr_type, l_orgId);
  FETCH C_address INTO l_address;
  x_party_site_id := l_address.party_site_id;
  IF C_address%NOTFOUND THEN
      x_party_site_id := -1;
  END IF;
  CLOSE C_address;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_Util.debug('End IBE_CUSTOMER_ACCT_PVT:GetPartySiteId');
   END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_GETPARTYSITEID;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:GetPartySiteId()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_GETPARTYSITEID;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:GetPartySiteId()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_GETPARTYSITEID;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;
       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:GetPartySiteId' || sqlerrm);
        END IF;

END GetPartySiteId;

/*
PROCEDURE Create_Party_Site_Use(
                         p_api_version_number     IN  NUMBER,
                         p_init_msg_list          IN  VARCHAR2,
                         p_commit                 IN  VARCHAR2,
                         p_party_site_id          IN  NUMBER,
                         p_party_site_use_type    IN  VARCHAR2,
                         x_party_site_use_id      OUT NOCOPY NUMBER,
                         x_return_status          OUT NOCOPY VARCHAR2,
                         x_msg_count              OUT NOCOPY NUMBER,
                         x_msg_data               OUT NOCOPY VARCHAR2
                         )
IS

    l_party_site_use_rec  HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;
    --##    l_party_site_use_rec HZ_PARTY_PUB.Party_Site_Use_Rec_Type;
    l_return_status       VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
    l_party_site_use_id   NUMBER;

    l_return_values    varchar2(2000);
    l_api_version      NUMBER := 1.0;
    l_api_name         VARCHAR2(30) := 'CUSTACCT_CREATEPARTYSITEUSE';

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_Util.debug('Begin IBE_CUSTOMER_ACCT_PVT:Create_Party_Site_Use');
   Ibe_Util.debug('create_pty_site_use:before create_pty_site_use:p_party_site_id: ' || p_party_site_id);
   Ibe_Util.debug('create_pty_site_use:before create_pty_site_use:p_party_site_use_type: ' || p_party_site_use_type);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT    CUSTACCT_CREATEPARTYSITEUSE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

  l_party_site_use_rec.party_site_id := p_party_site_id;
  l_party_site_use_rec.site_use_type := p_party_site_use_type;

   HZ_PARTY_SITE_V2PUB.create_party_site_use (
    p_init_msg_list                 => FND_API.G_FALSE,
    p_party_site_use_rec            => l_party_site_use_rec,
    x_party_site_use_id             => l_party_site_use_id,
    x_return_status                 => x_return_status,
    x_msg_count                     => x_msg_count,
    x_msg_data                      => x_msg_data  );


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_Util.debug('create_pty_site_use:after create_pty_site_use:x_party_site_use_id: ' || x_party_site_use_id);
     Ibe_Util.debug('create_pty_site_use:after create_pty_site_use:x_return_status: ' || x_return_status);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      x_party_site_use_id := l_party_site_use_id;
    ELSE
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       Ibe_Util.debug('Exception in Hz Create_Party_Site_Use: '|| x_msg_data);
      ENd IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_Util.debug('End IBE_CUSTOMER_ACCT_PVT:Create_Party_Site_Use');
   ENd IF;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATEPARTYSITEUSE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:Create_Party_Site_Use'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATEPARTYSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:Create_Party_Site_Use' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CREATEPARTYSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;
       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:Create_Party_Site_Use' || sqlerrm);
       END IF;
END Create_Party_Site_Use;
*/

PROCEDURE create_cust_account_role(
                         p_api_version_number   IN  NUMBER,
                         p_init_msg_list        IN  VARCHAR2,
                         p_commit               IN  VARCHAR2,
                         p_party_id             IN  NUMBER,
                         p_cust_acct_id         IN  NUMBER,
                         p_cust_acct_site_id    IN  NUMBER,
                         p_role_type            IN  VARCHAR2, -- this is only for gettting the respid.
                         x_cust_acct_role_id    OUT NOCOPY NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2
                        )
IS

 --## p_cust_acct_roles_rec  hz_customer_accounts_pub.cust_acct_roles_rec_type;
 --## p_role_resp_rec       hz_customer_accounts_pub.role_resp_rec_type;

 -- The below two record definitions are for V2 APIs
  p_cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;
  p_role_resp_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.role_responsibility_rec_type;

 l_responsibility_id NUMBER;

 CURSOR C_Get_Resp(role_id NUMBER, role_type VARCHAR2) IS
   SELECT responsibility_id
   FROM hz_role_responsibility
   WHERE cust_account_role_id = role_id
   AND responsibility_type = role_type;

 l_return_status    VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
 l_msg_count        NUMBER :=0;
 l_msg_data         VARCHAR2(2000):='';
 l_api_version      NUMBER := 1.0;
 l_api_name         VARCHAR2(30) := 'CUSTACCT_CREATCUSTACCTROLE';


BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_Util.debug('BEgin IBE_CUSTOMER_ACCT_PVT:create_cust_account_role');
 END IF;

  -- Standard Start of API savepoint
  SAVEPOINT CUSTACCT_CREATCUSTACCTROLE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
    FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Start OF API body --

   p_cust_acct_roles_rec.party_id          := p_party_id;
   p_cust_acct_roles_rec.cust_account_id   := p_cust_acct_id;
   p_cust_acct_roles_rec.role_type         := 'CONTACT'; -- it should be always contact
   p_cust_acct_roles_rec.cust_acct_site_id := p_cust_acct_site_id;
   -- Initializing the created_by_module column for all the records as per
   -- changes in version 2 api's.
   p_cust_acct_roles_rec.Created_by_Module := 'IBE_CUSTOMER_DATA';

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('before create cust acct roles');
  END IF;


  -- old TCA API call
  --  hz_customer_accounts_pub.create_cust_acct_roles.


    HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
    p_init_msg_list                         => FND_API.G_FALSE,
    p_cust_account_role_rec                 => p_cust_acct_roles_rec,
    x_cust_account_role_id                  => x_cust_acct_role_id,
    x_return_status                         => l_return_status,
    x_msg_count                             => l_msg_count,
    x_msg_data                              => l_msg_data  );


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('create_contact_role:after create_cust_acct_role: x_return_status: '||l_return_status);
  END IF;

  IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.debug('Exception in HZ create_cust_account_role: '||l_msg_data);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Setting Responsibility id for newly created role id.

 IF (x_cust_acct_role_id is not null AND
    x_cust_acct_role_id <> FND_API.G_MISS_NUM)
 THEN

   OPEN C_Get_Resp(x_cust_acct_role_id, p_role_type);
   FETCH C_Get_Resp INTO l_responsibility_id;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('create_contact_role l_responsibility_id: '||l_responsibility_id);
   END IF;
   IF C_Get_Resp%NOTFOUND THEN

     IF p_cust_acct_site_id is not NULL AND
         p_cust_acct_site_id <>  FND_API.G_MISS_NUM
     THEN
       p_role_resp_rec.cust_account_role_id := x_cust_acct_role_id;
       p_role_resp_rec.responsibility_type  := p_role_type;
       p_role_resp_rec.Created_by_Module    := 'IBE_CUSTOMER_DATA';

      -- old TCA API call
      -- HZ_CUSTOMER_ACCOUNTS_PUB.create_role_resp.

       -- version 2 API
       HZ_CUST_ACCOUNT_ROLE_V2PUB.create_role_responsibility (
       p_init_msg_list                         =>  FND_API.G_FALSE,
       p_role_responsibility_rec               => p_role_resp_rec,
       x_responsibility_id                     => l_responsibility_id,
       x_return_status                         => l_return_status,
       x_msg_count                             => l_msg_count,
       x_msg_data                              => l_msg_data  );



       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.debug('create_contact_role:after create_role_resp: x_return_status: '||l_return_status);
       END IF;

       IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.debug('Exception in HZ create_role_responsibility: '||l_msg_data);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

     END IF; --if p_cust_account_site_id is not NULL
   END IF; -- IF C_Get_Resp%NOTFOUND THEN
   CLOSE C_Get_Resp;
  END IF;

  --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.debug('End IBE_CUSTOMER_ACCT_PVT:create_cust_account_role');
  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTROLE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:create_cust_account_role()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTROLE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:create_cust_account_role' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTROLE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:create_cust_account_role)' || sqlerrm);
       END IF;

ENd create_cust_account_role;


PROCEDURE Create_Cust_Acct_Site(
                         p_api_version_number IN  NUMBER
                        ,p_init_msg_list      IN  VARCHAR2
                        ,p_commit             IN  VARCHAR2
                        ,p_partysite_id       IN  NUMBER
                        ,p_custacct_id        IN  NUMBER
                        ,p_custacct_type      IN  VARCHAR2
                        ,x_custacct_site_id   OUT NOCOPY NUMBER
                        ,x_return_status      OUT NOCOPY VARCHAR2
                        ,x_msg_count          OUT NOCOPY NUMBER
                        ,x_msg_data           OUT NOCOPY VARCHAR2
                        )
 IS

      CURSOR c_acct_site (account_id NUMBER, site_id NUMBER) IS
           SELECT cust_acct_site_id
           FROM hz_cust_acct_sites
           WHERE cust_account_id = account_id
           AND party_site_id    = site_id;

     p_acct_site_rec   HZ_CUST_ACCOUNT_SITE_V2PUB.cust_acct_site_rec_type;
     -- ## p_acct_site_rec      hz_customer_accounts_pub.acct_site_rec_type;
     l_customer_site_id   NUMBER := NULL;
     l_return_status      VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
     l_msg_count          NUMBER :=0;
     l_msg_data           VARCHAR2(2000):='';
     l_api_version      NUMBER := 1.0;
     l_api_name         VARCHAR2(30) := 'CUSTACCT_CREATCUSTACCTSITE';


BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Begin IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site ');
     IBE_Util.debug('Create_Cust_Acct_Site: '||p_custacct_type||' : ' ||p_partysite_id);
   END IF;

  -- Standard Start of API savepoint
  SAVEPOINT  CUSTACCT_CREATCUSTACCTSITE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Start OF API body --

  Open c_acct_site (p_custacct_id, p_partysite_id);
  Fetch c_acct_site into l_customer_site_id;
  IF (c_acct_site%NOTFOUND) THEN
    l_customer_site_id := null;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.debug('Create_Cust_Acct_Site l_customer_site_id: '||l_customer_site_id);
  END IF;
  Close c_acct_site;

   IF l_customer_site_id is not NULL THEN
      x_custacct_site_id :=  l_customer_site_id ;
   ELSE
      p_acct_site_rec.cust_account_id   := p_custacct_id;
      p_acct_site_rec.party_site_id     := p_partysite_id;
      -- Intializing created_by_module as required in version 2 api for the record structure
      p_acct_site_rec.created_by_module := 'IBE_CUSTOMER_DATA';

       -- old TCA API call
       --hz_customer_accounts_pub.create_account_site

       HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_acct_site (
                     p_init_msg_list       => FND_API.G_FALSE,
                     p_cust_acct_site_rec  => p_acct_site_rec,
                     x_cust_acct_site_id   => l_customer_site_id,
                     x_return_status       => l_return_status,
                     x_msg_count           => l_msg_count,
                     x_msg_data            => l_msg_data  );

   END IF;

   IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     x_custacct_site_id :=  l_customer_site_id ;
   else
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.debug('Exception in HZ create_cust_acct_site: '||l_msg_data);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   end if;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('End IBE_CUSTOMER_ACCT_PVT: Create_Cust_Acct_Site custacct_site_id: '||x_custacct_site_id);
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT: Create_Cust_Acct_Site()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT: Create_Cust_Acct_Site()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT: Create_Cust_Acct_Site()' || sqlerrm);
       END IF;

END Create_Cust_Acct_Site;


PROCEDURE Create_Cust_Acct_Site_Use (
                         p_api_version_number   IN  NUMBER
                        ,p_init_msg_list        IN  VARCHAR2
                        ,p_commit               IN  VARCHAR2
                        ,p_cust_account_Id      IN  NUMBER
                        ,p_party_site_Id        IN  NUMBER
                        ,p_cust_acct_site_id    IN  NUMBER
                        ,p_acct_site_type       IN  VARCHAR2
                        ,x_cust_acct_site_id    OUT NOCOPY NUMBER
                        ,x_custacct_site_use_id OUT NOCOPY NUMBER
                        ,x_return_status        OUT NOCOPY VARCHAR2
,x_msg_count            OUT NOCOPY NUMBER
                        ,x_msg_data             OUT NOCOPY VARCHAR2
                        )
IS

    l_acctsite_uses_rec        HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
    -- ## l_acctsite_uses_rec  hz_customer_accounts_pub.acct_site_uses_rec_type;
    l_cust_profile_rec         HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
    -- ## l_cust_profile_rec   hz_customer_accounts_pub.cust_profile_rec_type;
    l_custacct_site_use_id     NUMBER := NULL;
    l_cust_acct_site_id        NUMBER := NULL;
    l_profile                  varchar2(1):= '';
    l_location                 VARCHAR2(40):= '';
    l_return_status            VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;

    l_party_site_use           NUMBER := null;
    l_party_site_id            NUMBER := null;
    lx_party_site_use_id       NUMBER;
    l_return_values            varchar2(2000);
    l_api_version              NUMBER := 1.0;
    l_api_name                 VARCHAR2(30) := 'CUSTACCT_CREATCUSTACCTSITEUSE';

    CURSOR c_site_use(acct_site_id NUMBER, Site_type VARCHAR2) IS
       SELECT site_use_id
       FROM hz_cust_site_uses
       WHERE cust_acct_site_id = acct_site_id
       AND site_use_code = Site_type;

    CURSOR c_party_site_use(l_party_site_id NUMBER, Site_type VARCHAR2) IS
       SELECT party_site_use_id
       FROM hz_party_site_uses
       WHERE party_site_id = l_party_site_id
       AND site_use_type = Site_type;

    CURSOR c_location(l_party_site_id NUMBER) IS
        Select hzl.city
        From hz_locations hzl,hz_party_sites hps
        Where hps.party_site_id = p_party_site_id
        And hzl.location_id = hps.location_id;


BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Begin IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site_Use ' );
     Ibe_util.Debug('p_acct_site_type: ' || p_acct_site_type);
   END IF;


  -- Standard Start of API savepoint
  SAVEPOINT  CUSTACCT_CREATCUSTACCTSITEUSE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

   l_cust_acct_site_id := p_cust_acct_site_id;
   l_acctsite_uses_rec.cust_acct_site_id := l_cust_acct_site_id;
   x_cust_acct_site_id := l_cust_acct_site_id;

   l_acctsite_uses_rec.site_use_code    := p_acct_site_type;

   Open c_site_use(l_cust_acct_site_id,p_acct_site_type);
   Fetch c_site_use into l_custacct_site_use_id;
   IF (c_site_use%NOTFOUND) THEN
     l_custacct_site_use_id := null;
   END IF;
   Close c_site_use;

   IF l_custacct_site_use_id is not NULL then
     x_custacct_site_use_id := l_custacct_site_use_id  ;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('x_custacct_site_use_id: ' || x_custacct_site_use_id);
     END IF;
   ELSE

     OPEN c_location(p_party_site_id);
     FETCH c_location into l_location;
     IF (c_location%NOTFOUND) THEN
       l_location := 'NO_LOCATION';
     END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('l_location: ' || l_location);
     END IF;
     CLOSE c_location;

      L_profile :=  HZ_MO_GLOBAL_CACHE.get_auto_site_numbering(MO_GLOBAL.get_current_org_id());



     IF l_profile = 'N' then
       l_acctsite_uses_rec.location := p_acct_site_type ||' ' || l_location ||' '
                                          ||to_char(l_acctsite_uses_rec.cust_acct_site_id) ;
     END IF;

     -- Intializing created_by_module as required in version 2 api for the record structure

     l_acctsite_uses_rec.created_by_module := 'IBE_CUSTOMER_DATA';
     l_cust_profile_rec.created_by_module  := 'IBE_CUSTOMER_DATA';


     -- old TCA API call
     -- hz_customer_accounts_pub.create_acct_site_uses


     HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
        p_init_msg_list                         => FND_API.G_FALSE,
        p_cust_site_use_rec                     => l_acctsite_uses_rec,
        p_customer_profile_rec                  => l_cust_profile_rec,
        p_create_profile                        => FND_API.G_TRUE,
        p_create_profile_amt                    => FND_API.G_TRUE,
        x_site_use_id                           => l_custacct_site_use_id,
        x_return_status                         => x_return_status,
        x_msg_count                             => x_msg_count,
        x_msg_data                              => x_msg_data  );


     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_Util.debug('create_acct_site_use: x_return_status: '|| l_return_status);
      Ibe_Util.debug('create_acct_site_use: l_custacct_site_use_id: '||l_custacct_site_use_id);
     END IF;

     IF l_Return_Status = FND_API.G_RET_STS_SUCCESS THEN
        x_custacct_site_use_id := l_custacct_site_use_id;
     ELSE
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('Exception in HZ create_cust_site_use: '|| x_msg_data);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF; -- IF x_site_use is null



   /*
     -- This call is commented out because create_cust_acct_site_use call to HZ API
     -- takes care of creating realted party_site_use also.

     OPEN c_party_site_use(p_party_site_Id,p_acct_site_type);
     FETCH c_party_site_use into l_party_site_use;
     CLOSE c_party_site_use;

     IF (l_party_site_use = NULL OR l_party_site_use = FND_API.G_MISS_NUM)
     then

       Create_Party_Site_Use(p_party_site_id       => l_party_site_id,
                             p_party_site_use_type => p_acct_site_type,
                             x_party_site_use_id   => lx_party_site_use_id,
                             x_return_status       => l_return_status,
     x_msg_count           => x_msg_count,
                             x_msg_data            => x_msg_data
                            );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           Ibe_util.Debug('Exception in HZ Create_Party_Site_Use: '|| x_msg_data);
         END IF;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

  */

    --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);


     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       Ibe_util.Debug('End IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site_Use');
     END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITEUSE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site_Use()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site_Use()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CREATCUSTACCTSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:Create_Cust_Acct_Site_Use()' || sqlerrm);
         END IF;

END Create_Cust_Acct_Site_Use ;


PROCEDURE  Get_Cust_Account_Site_Use(
                      p_api_version_number IN  NUMBER
                     ,p_init_msg_list      IN  VARCHAR2
                     ,p_commit             IN  VARCHAR2
                     ,p_cust_acct_id       IN  NUMBER
                     ,p_party_id           IN  NUMBER
                     ,p_siteuse_type       IN  VARCHAR2
                     ,p_partysite_id       IN  NUMBER
                     ,x_siteuse_id         OUT NOCOPY NUMBER
                     ,x_return_status      OUT NOCOPY VARCHAR2
                     ,x_msg_count          OUT NOCOPY NUMBER
                     ,x_msg_data           OUT NOCOPY VARCHAR2
                      )
IS

    CURSOR c_get_cust_site(c_cust_acct_id NUMBER,
                           c_party_site_id NUMBER)
    IS

    select cust_acct_site_id,status
    from hz_cust_acct_sites
    where cust_account_id = c_cust_acct_id
    AND party_site_id = c_party_site_id;

    -- changed for bug 4922991
    CURSOR c_get_custsite_use(c_acct_site_id NUMBER,c_acct_site_type VARCHAR2) IS
            select * from
                    ( select site_use_id, status
                        from  hz_cust_site_uses
                       where  cust_acct_site_id = c_acct_site_id and site_use_code = c_acct_site_type
                     order by status)
            where rownum <2 ;


    l_ship_to_org_id          NUMBER := NULL;
    l_invoice_to_org_id       NUMBER := NULL;
    l_cust_acct_site_id       NUMBER := NULL;
    lx_party_site_id          NUMBER := NULL;
    l_cust_acct_site_status   VARCHAR2(10) := '';
    l_site_use_id             NUMBER := NULL;
    l_custsite_use_status     VARCHAR2(10) := '';
    lx_cust_acct_site_id      NUMBER := NULL;
    l_cust_siteid_notavl      VARCHAR2(10) := FND_API.G_FALSE;
    l_cust_siteuseid_flow     VARCHAR2(10) := FND_API.G_FALSE;
    l_return_status           VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;

    l_return_values    varchar2(2000);
    l_api_version      NUMBER := 1.0;
    l_api_name         VARCHAR2(30) := 'CUSTACCT_CUSTACCTSITEUSE';

BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('Begin IBE_CUSTOMER_ACCT_PVT:Get_Cust_Account_Site_Use: ' || p_partysite_id );
   END IF;

   -- Standard Start of API savepoint
  SAVEPOINT    CUSTACCT_CUSTACCTSITEUSE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

   --  PART I party site id fetching
   IF (p_partysite_id is null OR p_partysite_id = FND_API.G_MISS_NUM) THEN

     /***   Use GetPartySiteId to use the Address rule.(primary, non primary or any valid address)  ***/

     GetPartySiteId(p_party_id       => p_party_id
                   ,p_site_use_type  => p_siteuse_type
                   ,x_party_site_id  => lx_party_site_id
                   ,x_return_status  => x_return_status
                   ,x_msg_count      => x_msg_count
                   ,x_msg_data       => x_msg_data);

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Get_Cust_Account_Site_Use p_party_id: ' || p_party_id );
     Ibe_util.Debug('Get_Cust_Account_Site_Use p_siteuse_type: ' || p_siteuse_type );
      Ibe_util.Debug('Get_Cust_Account_Site_Use lx_party_site_id: ' || lx_party_site_id );
     END IF;

   ELSE

     -- This else part will be reached for B2C user, when he tries to
     -- change the address at header level in UI
      lx_party_site_id := p_partysite_id;

   END IF;

   IF (lx_party_site_id <> -1) THEN

     -- PART II
     -- ** cust acct site id fetching **
     -- Use the party Site ID returned above
     -- and find the cust_acct_site_id

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       Ibe_util.Debug('retrieved val: ' || p_cust_acct_id||'::'||lx_party_site_id);
     END IF;

     OPEN c_get_cust_site(p_cust_acct_id, lx_party_site_id);
     FETCH c_get_cust_site INTO l_cust_acct_site_id, l_cust_acct_site_status;
     IF (c_get_cust_site%NOTFOUND) THEN
       l_cust_siteid_notavl := FND_API.G_TRUE;
     END IF;
     CLOSE c_get_cust_site;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('cust_acct_site_id: ' || l_cust_acct_site_id);
      Ibe_util.Debug('cust_acct_site_status: ' || l_cust_acct_site_status||' : '||l_cust_siteid_notavl);
     END IF;

     IF FND_API.to_Boolean(l_cust_siteid_notavl) THEN

        -- No Valid Cust Acct Site Id is present
        -- so try to create one
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Trying to create custacctsiteId');
        END IF;
        Create_Cust_Acct_Site(p_partysite_id     =>  lx_party_site_Id
                             ,p_custacct_id      => p_cust_acct_Id
                             ,p_custacct_type    => p_siteuse_type
                             ,x_custacct_site_id => l_cust_acct_site_id
                             ,x_return_status    => l_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
                             );

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Create_Cust_Acct_Site returned id : ' || l_cust_acct_site_id);
        END IF;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS OR
          (l_cust_acct_site_id is null OR l_cust_acct_site_id = FND_API.G_MISS_NUM))
        THEN
          -- Creation Failed.
          FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
          FND_Msg_Pub.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

     ELSIF (l_cust_acct_site_status <> 'A') THEN -- IF c_get_cust_site%NOTFOUND

       -- cust acct site id presents but invalid
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('Inside Invalid CustAcctSiteId Flow - Raise Exception');
       END IF;

       IF p_siteuse_type = 'BILL_TO' THEN
         FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_BILLTO_ADDR');  -- need error message
       ELSE
         FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_SHIPTO_ADDR');  -- need error message
       END IF;
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;

    END IF; -- c_get_cust_site%NOTFOUND


  -- PART III cust_acct_siteuse_id fetching

  -- Use the cust_account_site_id returned above and find the cust_acct_site_use_id.

    OPEN c_get_custsite_use(l_cust_acct_site_id,p_siteuse_type);
    FETCH c_get_custsite_use INTO l_site_use_id, l_custsite_use_status;
    IF (c_get_custsite_use%NOTFOUND) THEN
      l_cust_siteuseid_flow := FND_API.G_TRUE;   -- custacctsiteuseid not present.
    END IF;
    CLOSE c_get_custsite_use;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           Ibe_util.Debug('In l_site_use_id :' || l_site_use_id);
           Ibe_util.Debug('In l_custsite_use_status :' || l_custsite_use_status );
       END IF;

    IF (FND_API.to_Boolean(l_cust_siteuseid_flow)) THEN

        --  No valid Cust Acct Site Use Id present, so Create One.
        Create_Cust_Acct_Site_Use (p_Cust_Account_Id       => p_cust_acct_id
                                    ,P_Party_Site_Id       => lx_party_site_id
                                    ,P_cust_acct_site_id   => l_cust_acct_site_id
                                    ,P_Acct_Site_type      => p_siteuse_type
                                    ,x_cust_acct_site_id   => lx_cust_acct_site_id
                                    ,x_custacct_site_use_id => l_site_use_id
                                    ,x_return_status        => l_return_status
    ,x_msg_count            => x_msg_count
    ,x_msg_data             => x_msg_data
                                   );


      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS OR
           (l_cust_acct_site_id is null OR l_cust_acct_site_id = FND_API.G_MISS_NUM))
         THEN
          -- Creation Failed.
           FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
           FND_Msg_Pub.Add;
           RAISE FND_API.G_EXC_ERROR;
         ELSE
           x_siteuse_id := l_site_use_id;
         END IF;


    ELSIF (l_custsite_use_status <> 'A') THEN

          -- cust acct siteuse id present but invalid, so raise exception
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('Inside Invalid CustAcctSiteUseId Flow - Raise Exception');
         Ibe_util.Debug('nproc1  Inside Invalid CustAcctSiteUseId Flow - Raise Exception;' || l_site_use_id);
         Ibe_util.Debug('nproc1  Inside Invalid CustAcctSiteUseId Flow - Raise Exception:' || l_custsite_use_status);
      END IF;

      IF p_siteuse_type = 'BILL_TO' THEN
        FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_BILLTO_ADDR');  -- need error message
      ELSE
        FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_SHIPTO_ADDR');  -- need error message
      END IF;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    ELSE
        -- valid cust_acct_site_use_id available, so use it
        x_siteuse_id := l_site_use_id;
    END IF; --l_cust_siteuseid_flow

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('x_siteuse_id: ' || x_siteuse_id);
    END IF;

  ELSE    --party_site_id =-1
    l_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       Ibe_util.Debug('End IBE_CUSTOMER_ACCT_PVT:Get_Cust_Account_Site_Use');
    END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:Get_Cust_Account_Site_Use()'|| sqlerrm);
        END IF;

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('UnexError IBE_CUSTOMER_ACCT_PVT:Get_Cust_Account_Site_Use()'|| sqlerrm);
        END IF;

        WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count   => x_msg_count,
                                  p_data    => x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Others IBE_CUSTOMER_ACCT_PVT:Get_Cust_Account_Site_Use()'|| sqlerrm);
        END IF;

END Get_Cust_Account_Site_Use;

PROCEDURE Get_Cust_Acct_Role(
                      p_api_version_number   IN NUMBER
                     ,p_init_msg_list        IN VARCHAR2
                     ,p_commit               IN VARCHAR2
                     ,p_party_id             IN NUMBER
                     ,p_acctsite_type        IN VARCHAR2
                     ,p_sold_to_orgid        IN NUMBER
                     ,p_custacct_siteuse_id  IN NUMBER
                     ,x_cust_acct_role_id    OUT NOCOPY NUMBER
                     ,x_return_status        OUT NOCOPY VARCHAR2
                     ,x_msg_count            OUT NOCOPY NUMBER
                     ,x_msg_data             OUT NOCOPY VARCHAR2
                        )
IS

cursor c_cust_acct_id (lin_custacct_siteuse_id number, lin_siteuse_type varchar2)
is
  select hca.cust_acct_site_id, hca.cust_account_id,hps.party_id
  from hz_cust_acct_sites hca,hz_cust_site_uses hcu,hz_party_sites hps
  where
  hcu.site_use_id = lin_custacct_siteuse_id
  and hcu.site_use_code = lin_siteuse_type
  and hcu.cust_acct_site_id = hca.cust_acct_site_id
  and hca.party_site_id     = hps.party_site_id;


cursor c_cust_role(lin_party_id number,lin_custacct_site_id number,lin_custacct_id number) is
  select a.cust_account_role_id, a.status
  from hz_cust_account_roles a
  --,  hz_cust_acct_sites_all c
  where
  a.role_type = 'CONTACT'
  and a.party_id = lin_party_id
  and a.cust_account_id = lin_custacct_id
  and a.cust_acct_site_id = lin_custacct_site_id;

l_cust_role           c_cust_role%rowtype;
l_custacctrole_status VARCHAR2(10) := '';
l_cust_acct_role_id   NUMBER;
l_party_site_id       NUMBER;
l_custacct_site_id    NUMBER;
l_cust_acct_id        NUMBER;
l_party_id            NUMBER;
 l_return_values    varchar2(2000);
  l_api_version      NUMBER := 1.0;
  l_api_name         VARCHAR2(30) := 'CUSTACCT_GETCUSTACCTRLE';


BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Begin IBE_CUSTOMER_ACCT_PVT:Get_Cust_Acct_Role');
     Ibe_util.Debug('Get_Cust_Acct_Role partyId, soldtoorgid: '||p_party_id||' : '|| p_sold_to_orgid);
     Ibe_util.Debug('Get_Cust_Acct_Role custacct siteuse id: '||p_custacct_siteuse_id);
 END IF;

    -- Standard Start of API savepoint
  SAVEPOINT    CUSTACCT_GETCUSTACCTRLE;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

      --for the available site_use_id fetch cust_acct_id.

  open c_cust_acct_id(p_custacct_siteuse_id,p_acctsite_type);
  fetch c_cust_acct_id into l_custacct_site_id,l_cust_acct_id,l_party_id;
  close c_cust_acct_id;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('db cust_acct_id: '||l_cust_acct_id);
 END IF;

 -- if(l_cust_acct_id = p_sold_to_orgid AND l_party_id = p_party_id) then

    open c_cust_role(p_party_id,l_custacct_site_id,l_cust_acct_id);
    fetch c_cust_role into l_cust_role;

    if(c_cust_role%notfound) then
      l_cust_acct_role_id:= NULL;
    elsif l_cust_role.status <> 'A'
    then
       x_cust_acct_role_id := NULL;
       return;
    else
       l_cust_acct_role_id := l_cust_role.cust_account_role_id;
    end if;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('Get_Cust_Acct_Role cust_acct_role_id: '||l_cust_acct_role_id);
    end if;

    IF (l_cust_acct_role_id IS NULL or l_cust_acct_role_id = FND_API.G_MISS_NUM)
    THEN
      create_cust_account_role(p_party_id          => p_party_id
                              ,p_cust_acct_id      => p_sold_to_orgid
                              ,p_cust_acct_site_id => l_custacct_site_id
                              ,p_role_type         => 'BILL_TO'
                              ,x_cust_acct_role_id => l_cust_acct_role_id
                              ,x_return_status     => x_return_status
                              ,x_msg_count         => x_msg_count
                              ,x_msg_data          => x_msg_data
                             );
    END IF;

--  else
--     l_cust_acct_role_id := NULL;
--  end if;
   x_cust_acct_role_id := l_cust_acct_role_id;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('End IBE_CUSTOMER_ACCT_PVT:Get_Cust_Acct_Role: '||x_cust_acct_role_id);
   end if;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CUSTACCTSITEUSE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:Get_Cust_Acct_Role()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CUSTACCTSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:Get_Cust_Acct_Role()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CUSTACCTSITEUSE;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:Get_Cust_Acct_Role()' || sqlerrm);
         END IF;

 END Get_Cust_Acct_Role;

 PROCEDURE GetCustomerAcctData(
                         p_api_version_number    IN  NUMBER   := 1
                        ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_TRUE
                        ,p_commit                IN  VARCHAR2 := FND_API.G_FALSE
                        ,p_invoice_to_org_id     IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_invoice_to_contact_id IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_contact_party_id      IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_cust_account_id       IN  NUMBER   := FND_API.G_MISS_NUM
                        ,x_cust_account_id       OUT NOCOPY NUMBER
                        ,x_cust_party_name       OUT NOCOPY VARCHAR2
                        ,x_cust_party_id         OUT NOCOPY NUMBER
                        ,x_cust_party_type       OUT NOCOPY VARCHAR2
                        ,x_contact_party_id      OUT NOCOPY NUMBER
                        ,x_contact_party_name    OUT NOCOPY VARCHAR2
                        ,x_contact_phone         OUT NOCOPY VARCHAR2
                        ,x_contact_email         OUT NOCOPY VARCHAR2
                        ,x_party_site_id         OUT NOCOPY NUMBER
                        ,x_partysite_status      OUT NOCOPY VARCHAR2
                        ,x_return_status         OUT NOCOPY VARCHAR2
                        ,x_msg_count             OUT NOCOPY NUMBER
                        ,x_msg_data              OUT NOCOPY VARCHAR2)

IS

CURSOR c_cust_acct_det(lc_inv_to_org_id NUMBER) IS
 select hca.cust_account_id, hca.party_site_id, hcs.status
   from hz_cust_site_uses hcs,hz_cust_acct_sites hca
     where hcs.site_use_id = lc_inv_to_org_id and
           hcs.cust_acct_site_id = hca.cust_acct_site_id;

lc_cust_acct_det c_cust_acct_det%rowtype;

CURSOR c_customer_details(lc_cust_acct_id NUMBER) IS
  select a.party_id, a.party_name,a.party_type
    from hz_parties a, hz_cust_accounts b
      where b.party_id = a.party_id
            and b.cust_account_id = lc_cust_acct_id;

lc_customer_details c_customer_details%rowtype;

CURSOR c_contact_partyid(lc_inv_to_cntct_id NUMBER) IS
  Select Party_id
    from HZ_CUST_ACCOUNT_ROLES
       where cust_account_role_id = lc_inv_to_cntct_id;

lc_contact_partyid c_contact_partyid%rowtype;

CURSOR c_contact_partyname(lc_cntct_partyid NUMBER) IS
 Select party_name from HZ_PARTIES
  where party_type = 'PERSON' and party_id = lc_cntct_partyid
 union
 select party_name from HZ_PARTIES
   where party_id =
         (select subject_id from HZ_RELATIONSHIPS
                 where party_id = lc_cntct_partyid and
                 subject_type = 'PERSON' and object_type = 'ORGANIZATION');

lc_contact_partyname c_contact_partyname%rowtype;

CURSOR c_contact_details(lc_cntct_prtyId number) IS
      select contact_point_type, primary_flag,phone_line_type,
      IBE_UTIL.format_phone(phone_country_code,phone_area_code,phone_number,phone_extension)phone_number,
      email_address
  from hz_contact_points
  where contact_point_type in ('PHONE','EMAIL') and
       NVL(status, 'A') = 'A' and owner_table_name = 'HZ_PARTIES'
      and owner_table_id = lc_cntct_prtyId
      and primary_flag='Y';

lc_contact_details c_contact_details%rowtype;

l_cntct_partyid       NUMBER         := null;
l_cntct_party_name    VARCHAR2(360)  := '';
l_cntct_phone         VARCHAR2(100)  := '';
l_cntct_email         VARCHAR2(2000) := '';
l_cust_account_id     NUMBER;
l_partysite_id        NUMBER;
l_partysite_stat      VARCHAR2(1)    := '';

l_api_version         NUMBER         := 1.0;
l_api_name            VARCHAR2(30)   := 'CUSTACCT_CUSTOMERDATA';

BEGIN

 -- Standard Start of API savepoint
  SAVEPOINT    CUSTACCT_CUSTOMERDATA;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --


   -- PART I
   -- If InvoiceToOrgId is passed from UI Retrieve Cust_Acct_Id of the Order
   -- and Fetch the related Customer Details.
   -- Else if cust_acct_id is passed from UI the fetch the details directly
   -- CustomerName, CutsAcctId,PartySiteId would be sent back.
   -- If CustAcctId is coming IN then PartySiteId would not be sent back.

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('IBE_CUSTOMER_ACCT_PVT:GetCustomerAcctData() -Begin');
     IBE_Util.Debug('p_invoice_to_org_id: ' || p_invoice_to_org_id);
     IBE_Util.Debug('p_invoice_to_contact_id: '||p_invoice_to_contact_id);
     IBE_Util.Debug('p_contact_party_id: '|| p_contact_party_id);
     IBE_Util.Debug('p_cust_account_id: '|| p_cust_account_id);

  END IF;

  if(p_invoice_to_org_id is not null AND p_invoice_to_org_id <> FND_API.G_MISS_NUM) then
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Inside invoiceToorg id IF loop');
    END IF;
   open c_cust_acct_det(p_invoice_to_org_id);
   fetch c_cust_acct_det into lc_cust_acct_det;
   if(c_cust_acct_det%notfound) then
    FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_CUST'); --need err msg
    FND_Msg_Pub.Add;
    RAISE FND_API.G_EXC_ERROR;
   else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Customer details available');
    END IF;
    l_cust_account_id := lc_cust_acct_det.cust_account_id;
    l_partysite_id    := lc_cust_acct_det.party_site_id;
    l_partysite_stat  := lc_cust_acct_det.status;
   end if;
   close c_cust_acct_det;
  elsif(p_cust_account_id is not null AND p_cust_account_id <> FND_API.G_MISS_NUM) then
     -- this flow would be reached for Contact/ Address getting changed in UI.
     l_cust_account_id  := p_cust_account_id;
     l_partysite_id     := null;
     l_partysite_stat   := '';
  end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('l_cust_account_id: '||l_cust_account_id);
     IBE_Util.Debug('l_partysite_id: '|| l_partysite_id);
     IBE_Util.Debug('l_partysite_stat: '|| l_partysite_stat);

  END IF;
    x_cust_account_id   := l_cust_account_id;
    x_party_site_id     := l_partysite_id;
    x_partysite_status  := l_partysite_stat;

    open c_customer_details(l_cust_account_id);
    fetch c_customer_details into lc_customer_details;
    if(c_customer_details%notfound) then
      FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_CUST'); --need err msg
      FND_Msg_Pub.Add;
      RAISE FND_API.G_EXC_ERROR;
    else
      x_cust_party_id   := lc_customer_details.party_id;
      x_cust_party_name := lc_customer_details.party_name;
      x_cust_party_type := lc_customer_details.party_type;
    end if;

    close c_customer_details;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('x_cust_party_id: '|| x_cust_party_id);
     IBE_Util.Debug('x_cust_party_name: '|| x_cust_party_name);
  END IF;
   --  PART II
   -- Send the Party_site_Id and its status fetched above.


   -- PART III
   -- If InvoiceToContactId is passed Retrieve the ContactPartyId and fetch the related Contact details.
   -- Else if ConatctPartyId is directly passed from UI then fetch the related details.
   -- ContactName, phone and email would be sent back.

   if (p_invoice_to_contact_id is not null AND p_invoice_to_contact_id <> FND_API.G_MISS_NUM) then
    open  c_contact_partyid(p_invoice_to_contact_id);
    fetch c_contact_partyid into l_cntct_partyid;
    CLOSE c_contact_partyid;

   elsif(p_contact_party_id is not null AND p_contact_party_id <> FND_API.G_MISS_NUM) then
     l_cntct_partyid := p_contact_party_id;
   end if; -- (p_invoice_to_contact_id <> FND_API.G_MISS_NUM

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('l_cntct_partyid: '|| l_cntct_partyid);
  END IF;


  if (l_cntct_partyid is null OR l_cntct_partyid = FND_API.G_MISS_NUM) then
    x_contact_party_id    := null;
    x_contact_party_name  := '';
    x_contact_phone       := '';
    x_contact_email       := '';

  else
    -- Now fetch the PARTYNAME for this contactpartyId.
    for lc_contact_partyname in c_contact_partyname(l_cntct_partyid)
    loop
      l_cntct_party_name    := lc_contact_partyname.party_name;
    end loop;

    -- Contact's Phone number And Email.
    -- If Primary Phone and Email is available that is fetched.
    -- Otherwise, non-primary Active phone and email would be fetched.

      -- FETCH EMAIL and Phone
   open c_contact_details(l_cntct_partyid);
    loop
      fetch c_contact_details into lc_contact_details;
      Exit When c_contact_details%notfound;
      IF lc_contact_details.CONTACT_POINT_TYPE = 'EMAIL' THEN
        l_cntct_email := lc_contact_details.EMAIL_ADDRESS;
      ELSE
        IF (lc_contact_details.CONTACT_POINT_TYPE = 'PHONE') THEN
           l_cntct_phone := lc_contact_details.PHONE_NUMBER;
        END IF;
      END IF;
    end loop;
   close c_contact_details;

    x_contact_party_id    := l_cntct_partyid;
    x_contact_party_name  := l_cntct_party_name;
    x_contact_phone       := l_cntct_phone;
    x_contact_email       := l_cntct_email;
  end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('l_cntct_party_name: '|| l_cntct_party_name);
   IBE_Util.Debug('l_cntct_phone: '|| l_cntct_phone);
   IBE_Util.Debug('l_cntct_email: '|| l_cntct_email);
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('IBE_CUSTOMER_ACCT_PVT:GetCustomerAcctData() -END');
  END If;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CUSTACCT_CUSTOMERDATA;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_CUSTOMER_ACCT_PVT:GetCustomerAcctData()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CUSTACCT_CUSTOMERDATA;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_CUSTOMER_ACCT_PVT:GetCustomerAcctData()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO CUSTACCT_CUSTOMERDATA;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('OtherExc IBE_CUSTOMER_ACCT_PVT:GetCustomerAcctData()' || sqlerrm);
         END IF;

END GetCustomerAcctData;


END IBE_CUSTOMER_ACCT_PVT;

/
