--------------------------------------------------------
--  DDL for Package Body CS_MULTIORG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_MULTIORG_PVT" as
/* $Header: csxvmoib.pls 120.6 2005/09/28 15:17:17 cnemalik noship $ */

/*********** Private Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_MultiOrg_PVT' ;

G_MAXERRLEN constant number := 512;
g_oraerrmsg varchar2(600);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Get_OrgId
--   Type    :  Private
--   Purpose :  This private API is to get the MutliOrg id.
--   Pre-Req :
--   Parameters:
--       p_api_version          IN                  NUMBER      Required
--       p_init_msg_list        IN                  VARCHAR2
--       p_commit               IN                  VARCHAR2
--       p_validation_level     IN                  NUMBER
--       x_return_status        OUT     NOCOPY      VARCHAR2
--       x_msg_count            OUT     NOCOPY      NUMBER
--       x_msg_data             OUT     NOCOPY      VARCHAR2
--       p_incident_id          IN                  NUMBER      Required
--       x_org_id			    OUT	    NOCOPY	    NUMBER,
--       x_profile			    OUT 	NOCOPY	    VARCHAR2

--   Version : Current version 1.0
--   End of Comments
--

PROCEDURE Get_OrgId (
    p_api_version		IN                  NUMBER,
    p_init_msg_list		IN 	            VARCHAR2,
    p_commit			IN		    VARCHAR2,
    p_validation_level	IN	                    NUMBER,
    x_return_status		OUT     NOCOPY 	    VARCHAR2,
    x_msg_count			OUT 	NOCOPY 	    NUMBER,
    x_msg_data			OUT 	NOCOPY 	    VARCHAR2,
    p_incident_id		IN	            NUMBER,
    x_org_id			OUT	NOCOPY	    NUMBER,
    x_profile			OUT 	NOCOPY	    VARCHAR2
)
IS
    l_api_name                  CONSTANT  VARCHAR2(30) := 'Get_OrgId' ;
    l_api_name_full             CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
    l_api_version               CONSTANT  NUMBER       := 1.0 ;

    l_debug     number      :=  ASO_DEBUG_PUB.G_DEBUG_LEVEL ;

    l_rel_type_code   csi_i_org_assignments.relationship_type_code%TYPE := 'SERVICED_BY';
    l_rule_code       cs_multi_org_rules.multi_org_rule_code%TYPE;
    l_rule_order      cs_multi_org_rules.multi_org_rule_order%TYPE;
    l_account_id      NUMBER;
    l_party_site_id   NUMBER;
    i                 NUMBER := 0;

    Cursor Cs_Mulorg is
    select multi_org_rule_code
        ,multi_org_rule_order
    from  cs_multi_org_rules
    order by multi_org_rule_order;

    CURSOR l_RC_csr IS
    SELECT b.authoring_org_id
    FROM   cs_incidents_all_b a,
           okc_k_headers_all_b b
    WHERE  a.incident_id = p_incident_id
    and    a.contract_id = b.id;

    CURSOR l_RIB_csr IS
    SELECT a.org_id
    FROM   cs_customer_products_all a,
         cs_incidents_all_b b
    WHERE b.incident_id = p_incident_id
    AND   a.customer_product_id = b.customer_product_id;

    CURSOR l_RSR_csr IS
    SELECT org_id
    FROM   cs_incidents_all_b
    WHERE  incident_id = p_incident_id;

    CURSOR l_get_tca_id IS
    SELECT bill_to_site_id
          ,bill_to_account_id
     FROM cs_incidents_all_b
    WHERE incident_id = p_incident_id;

   CURSOR l_get_org_from_prime_accsite(p_party_site_id  IN NUMBER
                                      ,p_account_id IN NUMBER) IS

   SELECT org_id
     FROM hz_cust_acct_sites_all
    WHERE party_site_id   = p_party_site_id
      AND cust_account_id = p_account_id
      AND bill_to_flag    = 'P';

   CURSOR l_get_org_from_accsite(p_party_site_id  IN NUMBER
                                 ,p_account_id IN NUMBER) IS

   SELECT org_id
     FROM hz_cust_acct_sites_all
    WHERE party_site_id   = p_party_site_id
      AND cust_account_id = p_account_id
      AND bill_to_flag    = 'Y';

BEGIN

    --  Standard Start of API Savepoint
    SAVEPOINT   CS_MultiOrg_PVT ;

    --  Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    if (l_debug > 0) then
        aso_debug_pub.add ('Private API: ' || l_api_name_full || ' start', 1, 'Y');
    end if;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- API body
    --
    -- Local Procedure
    if (l_debug > 0) then
        aso_debug_pub.add(l_api_name_full || ': Incident Id =' || p_incident_id, 1, 'Y');
    end if;

    -- Validate parameters
    IF (p_incident_id is null) THEN
        aso_debug_pub.add(l_api_name_full || ': invalid input parameter: p_incident_id', 1, 'Y');
        FND_MESSAGE.Set_Name('CS','CS_CHG_INVALID_SUBMIT_PARAMS');
        FND_MESSAGE.Set_Token('PARAM','p_incident_id');
        FND_MESSAGE.Set_Token('ROUTINE',l_api_name_full);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Incident is valid');

    --Open the cursor
    Open cs_mulorg;
    Loop
     Fetch cs_mulorg into l_rule_code, l_rule_order;
     Exit when cs_mulorg%notfound;

     --DBMS_OUTPUT.PUT_LINE('l_rule_code'||l_rule_code);
     If l_rule_order IS NOT Null then
       If l_rule_code = 'RULE_CONTRACT' then
         Open  l_RC_csr;
         Fetch l_RC_csr INTO x_org_id;
         Close l_RC_csr;
       Elsif l_rule_code = 'RULE_INSTALLED_BASE' then
         Open  l_RIB_csr;
         Fetch l_RIB_csr INTO x_org_id;
         Close l_RIB_csr;
       Elsif l_rule_code = 'RULE_PROFILE' then
         FND_PROFILE.get('CS_SR_ORG_ID',x_org_id);
       Elsif l_rule_code = 'RULE_SR' then
         Open  l_RSR_csr;
         Fetch l_RSR_csr INTO x_org_id;
         Close l_RSR_csr;
       -- Added for R12
       ELSIF l_rule_code = 'RULE_ACCT_SITE' then
         --operating unit will be derived from account_site,
         --which is derived from bill_to_party_site and account_number of the service request

         --DBMS_OUTPUT.PUT_LINE('In acct site elsif');

         OPEN l_get_tca_id;
         FETCH l_get_tca_id into l_party_site_id, l_account_id;
         CLOSE l_get_tca_id;

         --DBMS_OUTPUT.PUT_LINE('l_party_site_id'||l_party_site_id);
         --DBMS_OUTPUT.PUT_LINE('l_account_id'||l_account_id);

         IF l_account_id IS NOT NULL AND
            l_party_site_id IS NOT NULL THEN

            --DBMS_OUTPUT.PUT_LINE('both not null');

            --go to the primary bill to site and get the org
            FOR l_rec IN l_get_org_from_prime_accsite(l_party_site_id,l_account_id) LOOP
              i := i + 1;
              IF i = 1 THEN
                x_org_id := l_rec.org_id;
              ELSE
                x_org_id := null;
                exit;
              END IF;
            END LOOP;

            IF i = 0 THEN
              --no records were found for primary go to the second cursor to get the bill_to_site
              FOR l_rec IN l_get_org_from_accsite(l_party_site_id,l_account_id) LOOP
                i := i + 1;

                IF i = 1 THEN
                  x_org_id := l_rec.org_id;
                ELSE
                  x_org_id := null;
                  exit;
                END IF;
              END LOOP;
            END IF;

         ELSE
           --l_account_id IS NULL
           --l_party_site_id IS NULL
           --cannot default any org
           x_org_id := null;
         END IF;
       END IF;
       If x_org_id IS NOT NULL then
         Exit;
       End If;
     End if;
    End loop;
    close cs_mulorg;

    -- getting the profile option value yes or no  to update OU in charges
    Fnd_profile.Get('CS_CHARGE_OU_UPDATE',x_profile);

    -- End of API body
    --
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

    if (l_debug > 0) then
        aso_debug_pub.add ('Private API: ' || l_api_name_full || ' end', 1, 'Y');
    end if;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
        (   p_count     =>      x_msg_count,
            p_data      =>      x_msg_data
        );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CS_MultiOrg_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CS_MultiOrg_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );
    WHEN OTHERS THEN
        g_oraerrmsg := substrb(sqlerrm,1,G_MAXERRLEN);
        ROLLBACK TO CS_MultiOrg_PVT;
        fnd_message.set_name('CS','CS_CHG_Get_OrgId_FAILED');
        fnd_message.set_token('ROUTINE',l_api_name_full);
        fnd_message.set_token('REASON',g_oraerrmsg);
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
            (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME,
                    l_api_name
                );
        END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count     =>      x_msg_count,
                p_data      =>      x_msg_data
            );

  END Get_OrgId;

End CS_MultiOrg_PVT;

/
