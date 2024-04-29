--------------------------------------------------------
--  DDL for Package Body IEX_DUNNING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_DUNNING_PUB" AS
/* $Header: iexpdunb.pls 120.11.12010000.27 2010/06/16 14:37:56 gnramasa ship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_DUNNING_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpdunb.pls';
G_Batch_Size NUMBER := to_number(nvl(fnd_profile.value('IEX_BATCH_SIZE'), '100000'));

--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

Procedure WriteLog  ( p_msg IN VARCHAR2)
IS
BEGIN

     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
        iex_debug_pub.LogMessage (p_msg);
     END IF;

END WriteLog;



Procedure Create_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_TBL          IN IEX_DUNNING_PUB.AG_DN_XREF_TBL_TYPE  ,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_AG_DN_XREF_ID_TBL       OUT NOCOPY IEX_DUNNING_PUB.AG_DN_XREF_ID_TBL_TYPE)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_AG_DN_XREF';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    errmsg                        VARCHAR2(32767);
    l_AG_DN_XREF_rec              IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE;
    x_ag_dn_xref_id               NUMBER;
    l_AG_DN_XREF_ID_TBL           IEX_DUNNING_PUB.AG_DN_XREF_ID_TBL_TYPE;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_AG_DN_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      -- added by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateAgDn: start ');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      for i in 1..p_ag_dn_xref_tbl.count
      loop
         l_ag_dn_xref_rec := p_ag_dn_xref_tbl(i);

         IEX_DUNNING_PVT.Create_AG_DN_XREF(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_ag_dn_xref_rec           => l_ag_dn_xref_rec
          , x_ag_dn_xref_id            => x_ag_dn_Xref_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

         IF x_return_status = FND_API.G_RET_STS_ERROR then
               raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_ag_dn_xref_id_tbl(i) := x_ag_dn_xref_id;

      END LOOP;

      x_ag_dn_xref_id_tbl := l_ag_dn_xref_id_tbl;


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- added by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CreateAgDn: End ');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ROLLBACK TO Create_Ag_Dn_PUB;
              -- added by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Create_Ag_Dn_PUB;
              -- added by gnramasa for bug 5661324 14-Mar-07
	      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Create_Ag_Dn_PUB;
	      -- added by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              WriteLog('iexpdunb:CreateAgDn:Exc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END CREATE_AG_DN_XREF;



Procedure Update_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_TBL          IN IEX_DUNNING_PUB.AG_DN_XREF_TBL_TYPE ,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_AG_DN_XREF';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    errmsg                        VARCHAR2(32767);
    l_AG_DN_XREF_rec              IEX_DUNNING_PUB.AG_DN_XREF_REC_TYPE ;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_AG_DN_PUB;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      -- added by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn: Start ');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      for i in 1..p_ag_dn_xref_tbl.count
      loop
         l_ag_dn_xref_rec := p_ag_dn_xref_tbl(i);

         IEX_DUNNING_PVT.Update_AG_DN_XREF(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_ag_dn_xref_rec           => l_ag_dn_xref_rec
          , p_ag_dn_xref_id            => l_ag_dn_xref_rec.ag_dn_Xref_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

         IF x_return_status = FND_API.G_RET_STS_ERROR then
               raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END LOOP;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Changed by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn: end ');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ROLLBACK TO Update_Ag_Dn_PUB;
              -- Changed by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:error='||errmsg);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Update_Ag_Dn_PUB;
              -- Changed by gnramasa for bug 5661324 14-Mar-07
	      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:error='||errmsg);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Update_Ag_Dn_PUB;
	      -- Changed by gnramasa for bug 5661324 14-Mar-07
	      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:Exc Exception');
              errmsg := SQLERRM;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:error='||errmsg);
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - UpdateAgDn:Exc Exception');
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Update_AG_DN_XREF;



Procedure Delete_AG_DN_XREF
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_AG_DN_XREF_ID           IN NUMBER,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS

    l_AG_DN_XREF_id         NUMBER ;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_AG_DN_XREF';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_AG_DN_PUB;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      -- Changed by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start ');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      IEX_DUNNING_PVT.Delete_AG_DN_XREF(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_AG_DN_XREF_id            => p_AG_DN_XREF_id
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data
            );

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      -- Changed by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End ');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ROLLBACK TO Delete_Ag_Dn_PUB;
              -- Changed by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Delete_Ag_Dn_PUB;
	      -- Changed by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Delete_Ag_Dn_PUB;
	      -- Changed by gnramasa for bug 5661324 14-Mar-07
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Delete_AG_DN_XREF;


Procedure custom_where_clause
           (p_running_level           IN VARCHAR2,
	    p_customer_name_low       IN VARCHAR2,
	    p_customer_name_high      IN VARCHAR2,
	    p_account_number_low      IN VARCHAR2,
	    p_account_number_high     IN VARCHAR2,
	    p_billto_location_low     IN VARCHAR2,
	    p_billto_location_high    IN VARCHAR2,
	    p_custom_select           OUT NOCOPY VARCHAR2)
IS
l_custom_select   varchar2(2000);
l_api_name       varchar2(50) := 'custom_where_clause';
BEGIN

WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start ');
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_running_level : '||p_running_level);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_low : '||p_customer_name_low);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_high : '||p_customer_name_high);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_low : '||p_account_number_low);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_high : '||p_account_number_high);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_low : '||p_billto_location_low);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_high : '||p_billto_location_high);

if p_running_level <> 'DELINQUENCY' then
	l_custom_select := ' SELECT p.party_name ' ||
			' From hz_cust_acct_sites_all acct_sites, ' ||
			'   hz_party_sites party_site, ' ||
			'   hz_cust_accounts ca, ' ||
			'   hz_cust_site_uses_all site_uses, ' ||
			'   hz_parties p ' ||
			' WHERE acct_sites.cust_account_id = ca.cust_account_id ' ||
			'  AND acct_sites.party_site_id = party_site.party_site_id ' ||
			'  AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id ' ||
			'  AND site_uses.site_use_code = ''BILL_TO'' ' ||
			'  AND ca.party_id = p.party_id ';
else
	l_custom_select := 'SELECT p.party_name ' ||
			' From hz_cust_acct_sites_all acct_sites, ' ||
			'   hz_party_sites party_site, ' ||
			'   hz_cust_accounts ca, ' ||
			'   hz_cust_site_uses_all site_uses, ' ||
			'   hz_parties p,' ||
			'   iex_delinquencies_all delin ' ||
			' WHERE acct_sites.cust_account_id = ca.cust_account_id ' ||
			'  AND acct_sites.party_site_id = party_site.party_site_id ' ||
			'  AND acct_sites.cust_acct_site_id = site_uses.cust_acct_site_id ' ||
			'  AND site_uses.site_use_code = ''BILL_TO'' ' ||
			'  AND ca.party_id = p.party_id ' ||
			'  AND delin.customer_site_use_id = site_uses.site_use_id ';
end if;

-- start for bug 9232261 PNAVEENK
if p_customer_name_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(p.party_name) >= upper(''' || replace(p_customer_name_low,'''','''''') || ''') ';
end if;

if p_customer_name_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(p.party_name) <= upper(''' || replace(p_customer_name_high,'''','''''') || ''') ';
end if;

if p_account_number_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(ca.account_number) >= upper(''' || replace(p_account_number_low,'''','''''') || ''') ';
end if;

if p_account_number_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(ca.account_number) <= upper(''' || replace(p_account_number_high,'''','''''') || ''') ';
end if;

if p_billto_location_low IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(site_uses.location) >= upper(''' || replace(p_billto_location_low,'''','''''') || ''') ';
end if;

if p_billto_location_high IS NOT NULL then
	l_custom_select := l_custom_select || ' AND upper(site_uses.location) <= upper(''' || replace(p_billto_location_high,'''','''''') || ''') ';
end if;
-- end for bug 9232261

if p_running_level = 'CUSTOMER' then
	l_custom_select := l_custom_select || ' AND p.party_id ';
elsif p_running_level = 'ACCOUNT' then
	l_custom_select := l_custom_select || ' AND ca.cust_account_id ';
elsif p_running_level = 'BILL_TO' then
	l_custom_select := l_custom_select || ' AND site_uses.site_use_id ';
else
	l_custom_select := l_custom_select || ' AND delin.delinquency_id ';
end if;

p_custom_select := l_custom_select;
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_custom_select : '||l_custom_select);
WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End ');

END custom_where_clause;

/*=================================================
 * clchang added new level 'BILL_TO' in 11.5.10.
*=================================================*/
Procedure Send_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_running_level           IN VARCHAR2 ,
	    p_parent_request_id       IN NUMBER,  -- added by gnramasa for bug 5661324 14-Mar-07
            p_dunning_plan_id         in number,
	    p_correspondence_date     IN DATE,
	    p_dunning_mode	      IN VARCHAR2,     -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_rec_only    IN   VARCHAR2,   -- added by gnramasa for bug 8489610 14-May-09
	    p_no_of_workers           IN number := 1,  -- added by gnramasa for bug 8489610 14-May-09
	    p_single_staged_letter    IN VARCHAR2 DEFAULT 'N',    -- added by gnramasa for bug stageddunning 28-Dec-09
	    p_customer_name_low       IN VARCHAR2,
	    p_customer_name_high      IN VARCHAR2,
	    p_account_number_low      IN VARCHAR2,
	    p_account_number_high     IN VARCHAR2,
	    p_billto_location_low     IN VARCHAR2,
	    p_billto_location_high    IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    /*
    CURSOR C_GET_DEL (p_dunning_plan_id number) IS
      SELECT delinquency_ID,
             Party_cust_id,
             cust_account_id,
             customer_site_use_id,
             score_value
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
        WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id;
         --AND DUNN_YN = 'Y';
     */
    --
    -- Changed by gnramasa for bug 5661324 14-Mar-07
    /* CURSOR C_GET_CUSTOMER (p_dunning_plan_id number) IS
      SELECT distinct party_cust_id
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
         --AND DUNN_YN = 'Y'
    order by party_cust_id;
    --
    CURSOR C_GET_CUSTOMER_DEL( in_party_id NUMBER, p_dunning_plan_id number) IS
      SELECT party_cust_id, cust_account_id, customer_site_use_id, delinquency_ID
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
         AND party_cust_id = in_party_id
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
         --AND DUNN_YN = 'Y'
    ORDER BY cust_account_id, delinquency_id;
    --
    CURSOR C_GET_ACCOUNT (p_dunning_plan_id number) IS
      SELECT distinct cust_account_id
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
         --AND DUNN_YN = 'Y'
    ORDER BY cust_account_id;
    --
    CURSOR C_GET_ACCOUNT_DEL(IN_ACCOUNT_ID NUMBER, p_dunning_plan_id number) IS
      SELECT party_cust_id, cust_account_id, customer_site_use_id, delinquency_ID
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
         --AND DUNN_YN = 'Y'
         AND cust_account_id = in_account_id
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
    ORDER BY cust_account_id, delinquency_id;
    --
    CURSOR C_GET_SITE (p_dunning_plan_id number) IS
      SELECT distinct customer_site_use_id
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
    ORDER BY customer_site_use_id;
    --
    CURSOR C_GET_SITE_DEL(IN_SITE_ID NUMBER, p_dunning_plan_id number) IS
      SELECT party_cust_id, cust_account_id, customer_site_use_id,delinquency_ID
        FROM IEX_DELINQUENCIES
             , iex_dunning_plans_vl
       WHERE STATUS in ('DELINQUENT', 'PREDELINQUENT')
         AND customer_site_use_id = in_site_id
             and iex_dunning_plans_vl.dunning_plan_id = p_dunning_plan_id
             -- begin bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
             -- and iex_delinquencies.score_id = iex_dunning_plans_vl.score_id
             -- end bug 4914799 ctlee 12/30/2005, party/account/site level dunning does not have score in delinquency
    ORDER BY customer_site_use_id, delinquency_id;
    */
    --
    CURSOR C_GET_BUCKET (p_dunning_plan_id number) IS
      select aging_bucket_id from iex_dunning_plans_vl
      where dunning_plan_id = p_dunning_plan_id;
    -- CURSOR C_GET_BUCKET IS
      -- SELECT preference_value
        -- FROM IEX_APP_PREFERENCES_VL
       --WHERE upper(PREFERENCE_NAME) = 'COLLECTIONS AGING BUCKET';
       -- WHERE upper(PREFERENCE_NAME) = 'DUNNING PLAN AGING BUCKET';
    --
    l_api_name              CONSTANT VARCHAR2(30) := 'Send_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(10);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    l_del_id                NUMBER;
    l_party_id              NUMBER;
    l_account_id            NUMBER;
    l_customer_site_use_id  NUMBER;
    l_score                 NUMBER;
    l_delinquencies_tbl     IEX_DELINQUENCY_PUB.DELINQUENCY_TBL_TYPE;
    l_delinquency_rec       IEX_DELINQUENCY_PUB.DELINQUENCY_REC_TYPE;
    l_bucket                VARCHAR2(100);
    nIdx                    NUMBER;
    nDelIdx                 NUMBER;
    errmsg                  VARCHAR2(32767);
    l_error                 NUMBER := 0;

    l_repeat                boolean := true;

    -- added by gnramasa for bug 5661324 14-Mar-07
    l_object_id             NUMBER;
    i                       number;
    Type refCur             is Ref Cursor;
    sql_cur                 refCur;
    sql_cur2                refCur;
    sql_cur3                refCur;
    sql_cur4                refCur;
    sql_cur5                refCur;
    sql_cur6                refCur;
    vPLSQL                  VARCHAR2(2000);
    vPLSQL2                 VARCHAR2(5000);
    vPLSQL3                 VARCHAR2(5000);
    vPLSQL4                 VARCHAR2(5000);
    vPLSQL5                 VARCHAR2(5000);
    vPLSQL6                 VARCHAR2(5000);
    vSelectColumn           varchar2(25);

     cursor c_scoring_engine(p_dunning_plan_id number) is
      select sc.score_id
          ,sc.score_name
      from iex_dunning_plans_vl d
         ,iex_scores sc
      where d.dunning_plan_id = p_dunning_plan_id
      and sc.score_id = d.score_id;

		l_score_engine_id       number;
		l_score_engine_name     varchar2(60);
      --Start  bug 7197038 gnramasa 9th july 08
      cursor c_filter_object(p_dunning_plan_id number) is
      select iof.select_column, iof.entity_name
	from IEX_OBJECT_FILTERS iof,iex_dunning_plans_vl ipd, IEX_SCORES isc
	where ipd.dunning_plan_id = p_dunning_plan_id
	and ipd.score_id=isc.score_id
	and isc.score_id=iof.object_id;

      l_select_column     varchar2(50);
      l_entity_name       varchar2(50);

      --Start adding for bug 8489610 by gnramasa 14-May-09
      l_req_id            number;

      l_dunning_rec_upd       IEX_DUNNING_PUB.DUNNING_REC_TYPE;
      l_submit_request_id     NUMBER;
      l_xml_request_id        NUMBER;
      l_conf_mode             varchar2(10);
      l_status                varchar2(10);
      l_no_of_workers         number;

      /*
      cursor c_dunning_ids (p_req_id number) is
       select dunning_id, dunning_object_id, dunning_level
       from iex_dunnings
       where request_id = p_req_id;

      cursor c_xml_request_ids (p_req_id number) is
       select xml_request_id
       from iex_xml_request_histories
       where conc_request_id = p_req_id;
       */

      --End adding for bug 8489610 by gnramasa 14-May-09
      l_custom_select			varchar2(2000);
      l_dunning_id			number;
      l_dunning_object_id		number;
      l_dunning_level			varchar2(20);
      l_atleast_one_rec			boolean;
      l_no_init_successful_rec		number;
      l_no_final_successful_rec		number;
      l_no_init_successful_inv_rec	number;
      l_no_final_successful_inv_rec	number;
      l_diff_bw_init_fi_su_rec		number;
      l_diff_bw_init_fi_su_inv_rec	number;
      l_confirmation_mode		varchar2(15);
      l_req_mode			varchar2(15);
      l_no_rec_conf			number;
      l_no_err_dunn_rec			number;
      l_con_update_re_st		boolean;
      l_update_cp_as_err		boolean := FALSE;
      l_err_message			varchar2(200);
      l_con_proc_mode			varchar2(10);
      l_no_of_rec_prc			number;
      l_no_of_succ_rec			number;
      l_no_of_fail_rec			number;
      l_no_of_rec_prc_bylastrun		number;
      l_no_of_succ_rec_bylastrun	number;
      l_no_of_fail_rec_bylastrun	number;
      l_process_err_rec_only            varchar2(3);
      l_dunning_type			varchar2(20);
      l_ag_dn_xref_id                   number;
      l_dunn_invoice_ct                 NUMBER := 0;
      l_object_type			varchar2(20);

      cursor c_req_dunn_mode (p_req_id number) is
      select dunning_mode
      from iex_dunnings
      where request_id = p_req_id;

      cursor c_req_is_confirmed (p_req_id number) is
      select count(1)
      from iex_dunnings
      where request_id = p_req_id
      and confirmation_mode = 'CONFIRMED';

      cursor c_no_err_dunn_rec (p_req_id number) is
      select count(1)
      from iex_dunnings id
      where id.request_id = p_req_id
      and id.delivery_status is not null
      and id.object_type <> 'IEX_INVOICES'
      and id.dunning_id = (select max(d.dunning_id) from iex_dunnings d
                        where d.dunning_object_id = id.dunning_object_id
		        and d.dunning_level = id.dunning_level and d.request_id = id.request_id
			and d.object_type <> 'IEX_INVOICES');

      cursor c_no_success_dunn_rec (p_req_id number) is
      select count(1)
      from iex_dunnings id
      where id.request_id = p_req_id
      and id.delivery_status is null
      and id.object_type <> 'IEX_INVOICES'
      and id.dunning_id = (select max(d.dunning_id) from iex_dunnings d
                        where d.dunning_object_id = id.dunning_object_id
		        and d.dunning_level = id.dunning_level and d.request_id = id.request_id
			and d.object_type <> 'IEX_INVOICES');

      cursor c_no_success_inv_rec (p_req_id number) is
      select count(1)
      from iex_dunnings id
      where id.request_id = p_req_id
      and id.delivery_status is null
      and id.object_type = 'IEX_INVOICES'
      and id.dunning_id = (select max(d.dunning_id) from iex_dunnings d
                        where d.dunning_object_id = id.dunning_object_id
		        and d.dunning_level = id.dunning_level and d.request_id = id.request_id
			and d.object_type = 'IEX_INVOICES');

      cursor c_get_invoice_ct (p_conc_req_id number) is
      select count(idt.cust_trx_id)
      from iex_dunning_transactions idt,
      iex_dunnings dunn,
      iex_ag_dn_xref xref,
      ra_customer_trx trx
      where idt.dunning_id = dunn.dunning_id
      and dunn.request_id = p_conc_req_id
      and dunn.ag_dn_xref_id = xref.ag_dn_xref_id
      and xref.invoice_copies = 'Y'
      and idt.cust_trx_id is not null
      and trx.customer_trx_id = idt.cust_trx_id
      and trx.printing_option = 'PRI';

      cursor c_get_inv_count_in_errmode (p_conc_req_id number, p_max_dunn_trx_id number) is
      select count(idt.cust_trx_id)
      from iex_dunning_transactions idt,
      iex_dunnings dunn,
      iex_ag_dn_xref xref,
      ra_customer_trx trx
      where idt.dunning_id = dunn.dunning_id
      and dunn.request_id = p_conc_req_id
      and dunn.ag_dn_xref_id = xref.ag_dn_xref_id
      and xref.invoice_copies = 'Y'
      and idt.cust_trx_id is not null
      and idt.dunning_trx_id > p_max_dunn_trx_id
      and trx.customer_trx_id = idt.cust_trx_id
      and trx.printing_option = 'PRI';

      cursor c_max_dunning_trx_id (p_conc_req_id number) is
      select max(idt.dunning_trx_id)
      from iex_dunning_transactions idt,
      iex_dunnings dunn
      where idt.dunning_id = dunn.dunning_id
      and dunn.request_id = p_conc_req_id;

      cursor c_object_type (p_req_id number) is
      select object_type
      from iex_dunnings
      where request_id = p_req_id
      order by dunning_id;

      l_payment_schedule_id	number;
      l_stage_number		number;
      l_max_dunning_trx_id	number;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT SEND_DUNNING_PUB;

      -- Changed by gnramasa for bug 5661324 14-Mar-07
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start ');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level = '||p_running_level);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_parent_request_id '||p_parent_request_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning_plan_id '||p_dunning_plan_id);

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message

      if (p_dunning_plan_id is null)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      select nvl(dunning_type,'DAYS_OVERDUE')
      into l_dunning_type
      from IEX_DUNNING_PLANS_B
      where dunning_plan_id = p_dunning_plan_id;
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_type ' || l_dunning_type);

      if l_dunning_type <> 'STAGED_DUNNING' then
	    Open C_Get_BUCKET (p_dunning_plan_id);
	    Fetch C_Get_Bucket into l_bucket;
	    If ( C_GET_Bucket%NOTFOUND ) Then
		 -- Changed by gnramasa for bug 5661324 14-Mar-07
		 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NO Bucket');
		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Bucket');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 RAISE FND_API.G_EXC_ERROR;
	    end if;
	    CLOSE C_GET_Bucket;
	    -- Changed by gnramasa for bug 5661324 14-Mar-07
	    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Bucket='||l_bucket);
	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Current Bucket='||l_bucket);
     end if;
    --
    -- Commented by gnramasa for bug 5661324 14-Mar-07
    /*
    IF (l_error = 0) THEN

      WriteLog('iexpdunb:SEND_DUNN: open Cursor');
      nIdx := 0;
      nDelIdx := 0;
      --
      if (p_running_level = 'CUSTOMER') then
      --
        Open C_Get_CUSTOMER(p_dunning_plan_id);
        LOOP
            Fetch C_Get_CUSTOMER
             into l_party_id;

            If ( C_GET_CUSTOMER%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog('iexpdunb:SEND_DUNN: NO PARTY');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Party');
              end if;
              WriteLog('iexpdunb:SEND_DUNN:NODATA');
              --WriteLog('***iexpdunb:SEND_DUNN:PARTY_ID='||l_party_id);
              exit;
            else
              nIdx := nIdx + 1;
              WriteLog('***iexpdunb:SEND_DUNN:nIdx='||nIdx);
              WriteLog('***iexpdunb:SEND_DUNN:PARTY_ID='||l_party_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG, '*****Party Id='||l_party_id||'*****');
              nDelIdx := 0;
              Open C_Get_CUSTOMER_DEL(l_party_id, p_dunning_plan_id);
              LOOP
                 Fetch C_Get_CUSTOMER_DEL
                  into l_party_id, l_account_id, l_customer_site_use_id, l_del_id;
                 --
                 If ( C_GET_CUSTOMER_DEL%NOTFOUND ) Then
                     if (nDelIdx = 0) then
                         WriteLog('iexpdunb:SEND_DUNN: NO DEL');
                     end if;
                     WriteLog('iexpdunb:SEND_DUNN:NODEL-END');
                     exit;
                 else
                     nDelIdx := nDelIdx + 1;
                     WriteLog('***iexpdunb:SEND_DUNN:delid='||l_del_id);
                     l_delinquency_rec.delinquency_id := l_del_id;
                     l_delinquency_rec.party_cust_id := l_party_id;
                     l_delinquency_rec.cust_account_id := l_account_id;
                     l_delinquency_rec.customer_site_use_id := l_customer_site_use_id;
                     l_delinquencies_Tbl(nDelIdx) := l_delinquency_rec;

                     --clchang updated to fix the gscc warning 10/28/04
                     --l_delinquency_rec := IEX_DELINQUENCY_PUB.G_MISS_DELINQUENCY_REC;  -- clear rec
                     l_delinquency_rec := null; -- clear rec
                     --WriteLog('***iexpdunb:SEND_DUNN:save data');
                 end if;
              END LOOP;
              Close C_Get_CUSTOMER_DEL;

              -- init return msg for each customer
              l_return_status := FND_API.G_RET_STS_SUCCESS;
              l_msg_count := 0;
              l_msg_data := '';

              WriteLog('***iexpdunb:SEND_DUNN:delCnt='||nDelIdx);
              WriteLog('***iexpdunb:SEND_DUNN:Call PVT');
              IEX_DUNNING_PVT.Send_Level_Dunning(
                      p_api_version              => p_api_version
                    , p_init_msg_list            => p_init_msg_list
                    , p_commit                   => p_commit
                    , p_running_level            => p_running_level
                    , p_dunning_plan_id          => p_dunning_plan_id
                    , p_delinquencies_tbl        => l_delinquencies_tbl
                    , x_return_status            => l_return_status
                    , x_msg_count                => l_msg_count
                    , x_msg_data                 => l_msg_data
               );

               WriteLog('***iexpdunb:SEND_DUNN:PVT status='||l_return_status);

               IF l_return_status = 'SKIP' then
                 WriteLog('iexpdunb:SEND_DUNN:skip this party');
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
							 elsif l_return_status = 'X' then

									  if l_repeat then
								        WriteLog('get scoring engine');
												open c_scoring_engine(p_dunning_plan_id);
												fetch c_scoring_engine into l_score_engine_id, l_score_engine_name;
												close c_scoring_engine;
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Validate correct scoring engine was run for this dunning plan.');
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine Name: ' || l_score_engine_name);
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine ID:   ' || l_score_engine_id);
												l_repeat := false;
										else
			                 l_return_status := FND_API.G_RET_STS_SUCCESS;
										end if;

               ELSIF l_return_status = FND_API.G_RET_STS_ERROR then
                 raise FND_API.G_EXC_ERROR;
               elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

            END IF;

        END LOOP;
        Close C_Get_CUSTOMER;
        --WriteLog('iexpdunb:SEND_DUNN:Close Cursor');
      --
      --
      elsif (p_running_level = 'ACCOUNT') then

        Open C_Get_ACCOUNT(p_dunning_plan_id);
        LOOP
            Fetch C_Get_ACCOUNT
             into l_account_id;

            If ( C_GET_ACCOUNT%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog('iexpdunb:SEND_DUNN: NO ACCOUNT');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Account');
                  --msg
                  -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
                  */
		  /*
                  IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                    P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                    P_Procedure_name        => 'IEX_DUNNING_PUB.SEND_DUNNING',
                    P_MESSAGE               => 'NO Delinquencies');
                  */
                  -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
		  /*
              end if;
              WriteLog('iexpdunb:SEND_DUNN:NODATA');
              exit;
            else
              nIdx := nIdx + 1;
              WriteLog('***iexpdunb:SEND_DUNN:nIdx='||nIdx);
              WriteLog('***iexpdunb:SEND_DUNN:ACCOUNT_ID='||l_account_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG, '*****Account Id='||l_account_id||'*****');
              nDelIdx := 0;
              Open C_Get_ACCOUNT_DEL(l_account_id, p_dunning_plan_id);
              LOOP
                 Fetch C_Get_ACCOUNT_DEL
                  into l_party_id, l_account_id, l_customer_site_use_id,l_del_id;
                 --
                 If ( C_GET_ACCOUNT_DEL%NOTFOUND ) Then
                     if (nDelIdx = 0) then
                         WriteLog('iexpdunb:SEND_DUNN: NO DEL');
                     end if;
                     WriteLog('iexpdunb:SEND_DUNN:NODEL-END');
                     exit;
                 else
                     nDelIdx := nDelIdx + 1;
                     --WriteLog('***iexpdunb:SEND_DUNN:nDelIdx='||nDelIdx);
                     --WriteLog('***iexpdunb:SEND_DUNN:partyid='||l_party_id);
                     --WriteLog('***iexpdunb:SEND_DUNN:accntid='||l_account_id);
                     WriteLog('***iexpdunb:SEND_DUNN:delid='||l_del_id);
                     l_delinquency_rec.delinquency_id := l_del_id;
                     l_delinquency_rec.party_cust_id := l_party_id;
                     l_delinquency_rec.cust_account_id := l_account_id;
                     l_delinquency_rec.customer_site_use_id := l_customer_site_use_id;
                     l_delinquencies_Tbl(nDelIdx) := l_delinquency_rec;
                     --clchang updated to fix the gscc warning 10/28/04
                     --l_delinquency_rec := IEX_DELINQUENCY_PUB.G_MISS_DELINQUENCY_REC;  -- clear rec
                     l_delinquency_rec := null;  -- clear rec
                 end if;
              END LOOP;
              Close C_Get_ACCOUNT_DEL;

              -- init return msg for each account
              l_return_status := FND_API.G_RET_STS_SUCCESS;
              l_msg_count := 0;
              l_msg_data := '';

              WriteLog('***iexpdunb:SEND_DUNN:delCnt='||nDelIdx);
              WriteLog('***iexpdunb:SEND_DUNN:Call PVT');
              IEX_DUNNING_PVT.Send_Level_Dunning(
                      p_api_version              => p_api_version
                    , p_init_msg_list            => p_init_msg_list
                    , p_commit                   => p_commit
                    , p_running_level            => p_running_level
                    , p_dunning_plan_id          => p_dunning_plan_id
                    , p_delinquencies_tbl        => l_delinquencies_tbl
                    , x_return_status            => l_return_status
                    , x_msg_count                => l_msg_count
                    , x_msg_data                 => l_msg_data
               );

               WriteLog('***iexpdunb:SEND_DUNN:PVT status='||l_return_status);

               IF l_return_status = 'SKIP' then
                 WriteLog('iexpdunb:SEND_DUNN:skip this account');
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
							 elsif l_return_status = 'X' then

									  if l_repeat then
								        WriteLog('get scoring engine');
												open c_scoring_engine(p_dunning_plan_id);
												fetch c_scoring_engine into l_score_engine_id, l_score_engine_name;
												close c_scoring_engine;
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Validate correct scoring engine was run for this dunning plan.');
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine Name: ' || l_score_engine_name);
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine ID:   ' || l_score_engine_id);
												l_repeat := false;
										else
			                 l_return_status := FND_API.G_RET_STS_SUCCESS;
										end if;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR then
                 raise FND_API.G_EXC_ERROR;
               elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

        END LOOP;
        Close C_Get_ACCOUNT;
        --WriteLog('iexpdunb:SEND_DUNN:Close Cursor');
      --
      -- clchang added for new level 'BILL_TO' (11.5.10)
      elsif (p_running_level = 'BILL_TO') then

        Open C_Get_SITE(p_dunning_plan_id);
        LOOP
            Fetch C_Get_SITE
             into l_customer_site_use_id;

            If ( C_GET_SITE%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog('iexpdunb:SEND_DUNN: NO BILL TO');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Bill To');
              end if;
              WriteLog('iexpdunb:SEND_DUNN:NODATA');
              exit;
            else
              nIdx := nIdx + 1;
              WriteLog('***iexpdunb:SEND_DUNN:nIdx='||nIdx);
              WriteLog('***iexpdunb:SEND_DUNN:Customer_Site_use_id='||l_customer_site_use_id);
              FND_FILE.PUT_LINE(FND_FILE.LOG, '*****customer_site_use_id ='||l_customer_site_use_id||'*****');
              nDelIdx := 0;
              Open C_Get_SITE_DEL(l_customer_site_use_id, p_dunning_plan_id);
              LOOP
                 Fetch C_Get_SITE_DEL
                  into l_party_id, l_account_id, l_customer_site_use_id,l_del_id;
                 --
                 If ( C_GET_SITE_DEL%NOTFOUND ) Then
                     if (nDelIdx = 0) then
                         WriteLog('iexpdunb:SEND_DUNN: NO DEL');
                     end if;
                     WriteLog('iexpdunb:SEND_DUNN:NODEL-END');
                     exit;
                 else
                     nDelIdx := nDelIdx + 1;
                     --WriteLog('***iexpdunb:SEND_DUNN:nDelIdx='||nDelIdx);
                     --WriteLog('***iexpdunb:SEND_DUNN:partyid='||l_party_id);
                     --WriteLog('***iexpdunb:SEND_DUNN:accntid='||l_account_id);
                     WriteLog('***iexpdunb:SEND_DUNN:delid='||l_del_id);
                     l_delinquency_rec.delinquency_id := l_del_id;
                     l_delinquency_rec.party_cust_id := l_party_id;
                     l_delinquency_rec.cust_account_id := l_account_id;
                     l_delinquency_rec.customer_site_use_id := l_customer_site_use_id;
                     l_delinquencies_Tbl(nDelIdx) := l_delinquency_rec;
                     --l_delinquency_rec := IEX_DELINQUENCY_PUB.G_MISS_DELINQUENCY_REC;  -- clear rec
                     l_delinquency_rec := null;  -- clear rec
                 end if;
              END LOOP;
              Close C_Get_SITE_DEL;

              -- init return msg for each account
              l_return_status := FND_API.G_RET_STS_SUCCESS;
              l_msg_count := 0;
              l_msg_data := '';

              WriteLog('***iexpdunb:SEND_DUNN:delCnt='||nDelIdx);
              WriteLog('***iexpdunb:SEND_DUNN:Call PVT');
              IEX_DUNNING_PVT.Send_Level_Dunning(
                      p_api_version              => p_api_version
                    , p_init_msg_list            => p_init_msg_list
                    , p_commit                   => p_commit
                    , p_running_level            => p_running_level
                    , p_dunning_plan_id          => p_dunning_plan_id
                    , p_delinquencies_tbl        => l_delinquencies_tbl
                    , x_return_status            => l_return_status
                    , x_msg_count                => l_msg_count
                    , x_msg_data                 => l_msg_data
               );

               WriteLog('***iexpdunb:SEND_DUNN:PVT status='||l_return_status);

               IF l_return_status = 'SKIP' then
                 WriteLog('iexpdunb:SEND_DUNN:skip this site');
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
							 elsif l_return_status = 'X' then

									  if l_repeat then
								        WriteLog('get scoring engine');
												open c_scoring_engine(p_dunning_plan_id);
												fetch c_scoring_engine into l_score_engine_id, l_score_engine_name;
												close c_scoring_engine;
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Validate correct scoring engine was run for this dunning plan.');
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine Name: ' || l_score_engine_name);
												FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine ID:   ' || l_score_engine_id);
												l_repeat := false;
										else
			                 l_return_status := FND_API.G_RET_STS_SUCCESS;
										end if;
               ELSIF l_return_status = FND_API.G_RET_STS_ERROR then
                 raise FND_API.G_EXC_ERROR;
               elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;

        END LOOP;
        Close C_Get_SITE;
        --WriteLog('iexpdunb:SEND_DUNN:Close Cursor');
      --
      -- end of adding for BILL_TO
      --
      else
        --
        Open C_Get_DEL(p_dunning_plan_id);
        LOOP
            Fetch C_Get_DEL
             into l_del_id, l_party_id, l_account_id, l_customer_site_use_id,l_score;

            If ( C_GET_DEL%NOTFOUND ) Then
              if (nIdx = 0) then
                  WriteLog('iexpdunb:SEND_DUNN: NO Del');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Delinquency');
                  x_return_status := FND_API.G_RET_STS_ERROR;
              end if;
              exit;
            else
              nIdx := nIdx + 1;
              WriteLog('***iexpdunb:SEND_DUNN:nIdx='||nIdx);
              WriteLog('***iexpdunb:SEND_DUNN:delid='||l_del_id);
              l_delinquency_rec.delinquency_id := l_del_id;
              l_delinquency_rec.party_cust_id := l_party_id;
              l_delinquency_rec.cust_account_id := l_account_id;
              l_delinquency_rec.customer_site_use_id := l_customer_site_use_id;
              l_delinquency_rec.score_value := l_score;
              l_delinquencies_Tbl(nIdx) := l_delinquency_rec;
              --l_delinquency_rec := IEX_DELINQUENCY_PUB.G_MISS_DELINQUENCY_REC;  -- clear rec
              l_delinquency_rec := null;  -- clear rec
            end if;

        END LOOP;
        Close C_Get_DEL;
        WriteLog('iexpdunb:SEND_DUNN:Close Cursor');

        WriteLog('iexpdunb:SEND_DUNN:Call Pvt');

          IEX_DUNNING_PVT.Send_Dunning(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_dunning_plan_id          => p_dunning_plan_id
            , p_delinquencies_tbl        => l_delinquencies_tbl
            , x_return_status            => l_return_status
            , x_msg_count                => l_msg_count
            , x_msg_data                 => l_msg_data
            );

        WriteLog('iexpdunb:SEND_DUNN:Afer Call Pvt: Status='||l_return_status);

          IF l_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
          elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      end if; -- end of if (p_running_level);

   END IF; -- end of if (l_error)
   */ -- Up to here

-- added by gnramasa for bug 5661324 14-Mar-07
-- next get all the IDs we need to fill into array to pass to send_level_dunning OR send dunning
   Open c_filter_object (p_dunning_plan_id);
    Fetch c_filter_object into l_select_column,l_entity_name;
    If ( c_filter_object%NOTFOUND ) Then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - NO filter object');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'No filter object');
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    end if;
    CLOSE c_filter_object;
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_select_column: '|| l_select_column);
    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_entity_name: '||l_entity_name);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_select_column: '|| l_select_column);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_entity_name: '||l_entity_name);

    if (p_customer_name_low IS NOT NULL OR p_customer_name_high IS NOT NULL OR p_account_number_low IS NOT NULL OR
    p_account_number_high IS NOT NULL OR p_billto_location_low IS NOT NULL OR p_billto_location_high IS NOT NULL) then
	    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Calling custom_where_clause ');
	    --Call the procedure custom_where_clause to construct the SQL based on the cp input parameters.
	    custom_where_clause
		   (p_running_level           => p_running_level,
		    p_customer_name_low       => p_customer_name_low,
		    p_customer_name_high      => p_customer_name_high,
		    p_account_number_low      => p_account_number_low,
		    p_account_number_high     => p_account_number_high,
		    p_billto_location_low     => p_billto_location_low,
		    p_billto_location_high    => p_billto_location_high,
		    p_custom_select           => l_custom_select);

	     WriteLog(G_PKG_NAME || ' ' || l_api_name ||  'After call custom_where_clause :' || l_custom_select);
    end if;

     if p_running_level = 'CUSTOMER' then
         vSelectColumn := 'party_cust_id';
         vPLSQL2 := '    select                       ' ||
                    '  par_site.party_id              ' ||
                    ' ,acct_site.cust_account_id      ' ||
                    ' ,site_use.site_use_id           ' ||
                    ' ,decode(site_use.site_use_code, ' ||
                    '   ''DUN'', 1,                   ' ||
                    ' ''BILL_TO'', decode(site_use.primary_flag, ''Y'', 2, 3)) Display_Order ' ||
                    'from  HZ_CUST_SITE_USES site_use     ' ||
                    '     ,HZ_CUST_ACCT_SITES acct_site   ' ||
                    '     ,hz_party_sites par_site        ' ||
		    '     ,iex_dunning_plans_vl           ' ||
                    'where                                ' ||
                    '      par_site.party_id = :1 and     ' ||
                    '      par_site.status = ''A'' and    ' ||
                    '      par_site.party_site_id = acct_site.party_site_id and          ' ||
                    '      acct_site.status = ''A'' and   ' ||
                    '      acct_site.cust_acct_site_id = site_use.cust_acct_site_id and  ' ||
                    '      site_use.status = ''A'' and        ' ||
		    '      iex_dunning_plans_vl.dunning_plan_id = :p_dunning_plan_id and' ||
		    '      exists (select ' || l_select_column || ' from ' || l_entity_name || ' where '|| l_select_column ||' = par_site.party_id) ' ;
		    if l_custom_select IS NOT NULL then
			vPLSQL2 := vPLSQL2 || ' and exists ( ' || l_custom_select ||' = par_site.party_id) ' ;
		    end if;
                    vPLSQL2 := vPLSQL2 || '     order by Display_Order ';

     elsif p_running_level = 'ACCOUNT' then
         vSelectColumn := 'cust_account_id';
         vPLSQL2 := '    select                       ' ||
                    '  par_site.party_id              ' ||
                    ' ,acct_site.cust_account_id      ' ||
                    ' ,site_use.site_use_id           ' ||
                    ' ,decode(site_use.site_use_code, ' ||
                    '   ''DUN'', 1,                   ' ||
                    ' ''BILL_TO'', decode(site_use.primary_flag, ''Y'', 2, 3)) Display_Order ' ||
                    'from  HZ_CUST_SITE_USES site_use     ' ||
                    '     ,HZ_CUST_ACCT_SITES acct_site   ' ||
                    '     ,hz_party_sites par_site        ' ||
		    '     ,iex_dunning_plans_vl           ' ||
                    'where                                ' ||
                    '      acct_site.cust_account_id = :1 and ' ||
                    '      par_site.status = ''A'' and    ' ||
                    '      par_site.party_site_id = acct_site.party_site_id and          ' ||
                    '      acct_site.status = ''A'' and   ' ||
                    '      acct_site.cust_acct_site_id = site_use.cust_acct_site_id and  ' ||
                    '      site_use.status = ''A''   and  ' ||
		    '      iex_dunning_plans_vl.dunning_plan_id = :p_dunning_plan_id and' ||
		    '      exists (select ' || l_select_column || ' from ' || l_entity_name || ' where '|| l_select_column ||' = acct_site.cust_account_id) ';
		    if l_custom_select IS NOT NULL then
    			vPLSQL2 := vPLSQL2 || ' and exists ( ' || l_custom_select ||' = acct_site.cust_account_id) ';
		    end if;
                    vPLSQL2 := vPLSQL2 || '     order by Display_Order ';

     elsif p_running_level = 'BILL_TO' then
         vSelectColumn := 'customer_site_use_id';
         vPLSQL2 := '    select                       ' ||
                    '  par_site.party_id              ' ||
                    ' ,acct_site.cust_account_id      ' ||
                    ' ,site_use.site_use_id           ' ||
                    ' ,decode(site_use.site_use_code, ' ||
                    '   ''DUN'', 1,                   ' ||
                    ' ''BILL_TO'', decode(site_use.primary_flag, ''Y'', 2, 3)) Display_Order ' ||
                    'from  HZ_CUST_SITE_USES site_use     ' ||
                    '     ,HZ_CUST_ACCT_SITES acct_site   ' ||
                    '     ,hz_party_sites par_site        ' ||
		    '     ,iex_dunning_plans_vl           ' ||
                    'where                                ' ||
                    '      site_use.site_use_id = :1 and  ' ||
                    '      par_site.status = ''A'' and    ' ||
                    '      par_site.party_site_id = acct_site.party_site_id and          ' ||
                    '      acct_site.status = ''A'' and   ' ||
                    '      acct_site.cust_acct_site_id = site_use.cust_acct_site_id and  ' ||
                    '      site_use.status = ''A''  and   ' ||
		    '      iex_dunning_plans_vl.dunning_plan_id = :p_dunning_plan_id and' ||
		    '      exists (select ' || l_select_column || ' from ' || l_entity_name || ' where '|| l_select_column ||' = site_use.site_use_id) ';
		    if l_custom_select IS NOT NULL then
			vPLSQL2 := vPLSQL2 || ' and exists ( ' || l_custom_select ||' = site_use.site_use_id) ';
		    end if;
                    vPLSQL2 := vPLSQL2 || '     order by Display_Order ';

     else -- we are running at delinquency level
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delinquency Level');
         vSelectColumn := 'delinquency_id';
         vPLSQL2 := 'SELECT delinquency_ID '        ||
	            '      ,party_cust_id '      ||
                    '      ,cust_account_id '      ||
                    '      ,customer_site_use_id ' ||
                    '      ,score_value '       ||
                    '  FROM IEX_DELINQUENCIES del'      ||
		    '     ,iex_dunning_plans_vl    ' ||
                    ' WHERE STATUS in (''DELINQUENT'', ''PREDELINQUENT'') ' ||
                    '   AND DELINQUENCY_ID = :1  ' ||
		    '   AND iex_dunning_plans_vl.dunning_plan_id = :p_dunning_plan_id ' ||
		    '   AND del.score_id = iex_dunning_plans_vl.score_id' ;
		    --'   AND exists (select ' || l_select_column || ' from ' || l_entity_name || ' where '|| l_select_column ||' = del.DELINQUENCY_ID) ';
		    if l_custom_select IS NOT NULL then
			vPLSQL2 := vPLSQL2 || ' and exists ( ' || l_custom_select ||' = del.DELINQUENCY_ID) ';
		    end if;

                    --'ORDER BY  ' || vSelectColumn || ' ,delinquency_id';
     end if;

     -- fetch the party/account/site_use/delinquency from iex_delinquencies table
     if p_parent_request_id is null then
         vPLSQL := '  SELECT distinct ' || vSelectColumn ||
                   '    FROM IEX_DELINQUENCIES ' ||
		   ', IEX_DUNNING_PLANS_VL '||
                   '   WHERE STATUS in (''DELINQUENT'', ''PREDELINQUENT'') ' ||
                   ' AND iex_dunning_plans_vl.dunning_plan_id = :p_dunning_plan_id ' ||
		   ' order by ' || vSelectColumn;
     else
         vPLSQL := '  SELECT distinct object_id ' ||
                   '    FROM IEX_DUNNINGS  ID     ' ||
                   --'   WHERE DELIVERY_STATUS = ''ERROR'' ' ||
		   '   WHERE DELIVERY_STATUS IS NOT NULL ' ||
                   --'     AND STATUS = ''OPEN''  ' ||
                   '     AND REQUEST_ID = :1    ' ||
                   '     AND DUNNING_LEVEL = :2 ' ||
		   '     AND ID.object_type <> ''IEX_INVOICES'' ' ||
		   '     AND dunning_id = (select max(d.dunning_id) from iex_dunnings d ' ||
                   '                       where d.dunning_object_id = id.dunning_object_id ' ||
		   '                       and d.dunning_level=id.dunning_level and d.request_id = id.request_id ' ||
		   '                       and d.object_type <> ''IEX_INVOICES'' )';
     end if;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL ' || vPLSQL);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL2 ' || vPLSQL2);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - open Cursor');

     if p_parent_request_id is null then
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - no bind ');
       open sql_cur for vPLSQL using p_dunning_plan_id;

     else
       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - binding with ' || p_parent_request_id || ' and ' || p_running_level);
       open sql_cur for vPLSQL using p_parent_request_id, p_running_level;

     end if;

     if p_process_err_rec_only = 'Y' then
	open c_no_err_dunn_rec(p_parent_request_id);
	fetch c_no_err_dunn_rec into l_no_of_rec_prc_bylastrun;
	close c_no_err_dunn_rec;
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_of_rec_prc_bylastrun: '||l_no_of_rec_prc_bylastrun);

	open c_max_dunning_trx_id (p_parent_request_id);
	fetch c_max_dunning_trx_id into l_max_dunning_trx_id;
	close c_max_dunning_trx_id;
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_max_dunning_trx_id: '||l_max_dunning_trx_id);
     end if;

	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Deciding the request id ');
	if p_parent_request_id is not null then
		l_req_id := p_parent_request_id;
	else
		l_req_id := FND_GLOBAL.Conc_Request_Id;
	end if;
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_req_id: '||l_req_id);

        open c_no_success_dunn_rec(l_req_id);
	fetch c_no_success_dunn_rec into l_no_init_successful_rec;
	close c_no_success_dunn_rec;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_init_successful_rec : '|| l_no_init_successful_rec);

	open c_no_success_inv_rec(l_req_id);
	fetch c_no_success_inv_rec into l_no_init_successful_inv_rec;
	close c_no_success_inv_rec;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_init_successful_inv_rec : '|| l_no_init_successful_inv_rec);

     --deciding the confirmation mode
    /* if p_dunning_mode = 'DRAFT' then
	l_confirmation_mode := NULL;
	else
	l_confirmation_mode := 'CONFIRM';
     end if;
    */

     open c_req_dunn_mode(l_req_id);
     fetch c_req_dunn_mode into l_req_mode;
     close c_req_dunn_mode;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_req_mode: '||l_req_mode);

     if (l_req_mode = 'DRAFT') and (p_parent_request_id IS NOT NULL) and (p_dunning_mode = 'FINAL') then
	l_confirmation_mode := 'CONFIRM';
     else
        l_confirmation_mode := NULL;
     end if;
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_confirmation_mode: '||l_confirmation_mode);

     if l_req_mode = 'FINAL' and p_dunning_mode = 'DRAFT' then
	l_con_proc_mode := 'FINALDRAFT';
	l_update_cp_as_err := TRUE;
	goto end_loop;
     end if;

     open c_req_is_confirmed(l_req_id);
     fetch c_req_is_confirmed into l_no_rec_conf;
     close c_req_is_confirmed;

     if l_req_mode = 'DRAFT' and p_dunning_mode = 'DRAFT' and l_no_rec_conf > 0 then
	l_con_proc_mode := 'DRAFTDRAFT';
	l_update_cp_as_err := TRUE;
	goto end_loop;
     end if;
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_rec_conf: '||l_no_rec_conf);

   --Start adding for bug 8489610 by gnramasa 14-May-09

     if (p_parent_request_id is NULL OR p_process_err_rec_only = 'Y') then
	     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' p_running_level : ' || p_running_level);
	     if p_running_level <> 'DELINQUENCY' then

	       LOOP
		   fetch sql_cur into l_object_id;
	       exit when sql_cur%NOTFOUND;
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fetched ' || l_object_id);
		   --open sql_cur2 for vPLSQL2 using l_object_id,p_dunning_plan_id,l_select_column,l_entity_name,l_select_column;
		   open sql_cur2 for vPLSQL2 using l_object_id,p_dunning_plan_id;
		   fetch sql_cur2 into l_party_id, l_account_id, l_customer_site_use_id, l_del_id;
			if sql_cur2%FOUND then
			   --l_atleast_one_rec := TRUE;
			   l_delinquencies_Tbl(1).party_cust_id        := l_party_id;
			   l_delinquencies_Tbl(1).cust_account_id      := l_account_id;
			   l_delinquencies_Tbl(1).customer_site_use_id := l_customer_site_use_id;
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_party_id ' || l_delinquencies_Tbl(1).party_cust_id);
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_account_id ' || l_delinquencies_Tbl(1).cust_account_id);
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_customer_site_use_id ' || l_delinquencies_Tbl(1).customer_site_use_id);

				--if l_confirmation_mode is NULL  then

				   if l_dunning_type = 'STAGED_DUNNING' then
					   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - calling Send_Level_Staged_Dunning');
					   IEX_DUNNING_PVT.Send_Level_Staged_Dunning(p_api_version       => p_api_version
									     ,p_init_msg_list            => p_init_msg_list
									     ,p_commit                   => p_commit
									     ,p_running_level            => p_running_level
									     ,p_dunning_plan_id          => p_dunning_plan_id
									     ,p_correspondence_date      => p_correspondence_date
									     ,p_delinquencies_tbl        => l_delinquencies_tbl
									     ,p_parent_request_id        => p_parent_request_id
									     ,p_dunning_mode	         => p_dunning_mode
									     ,p_single_staged_letter     => p_single_staged_letter    -- added by gnramasa for bug stageddunning 28-Dec-09
									     ,p_confirmation_mode	 => l_confirmation_mode
									     ,x_return_status            => l_return_status
									     ,x_msg_count                => l_msg_count
									     ,x_msg_data                 => l_msg_data);
				   else
					   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - calling send_level_dunning');
					   IEX_DUNNING_PVT.Send_Level_Dunning(p_api_version              => p_api_version
									     ,p_init_msg_list            => p_init_msg_list
									     ,p_commit                   => p_commit
									     ,p_running_level            => p_running_level
									     ,p_dunning_plan_id          => p_dunning_plan_id
									     ,p_delinquencies_tbl        => l_delinquencies_tbl
									     ,p_parent_request_id        => p_parent_request_id
									     ,p_dunning_mode	         => p_dunning_mode
									     ,p_confirmation_mode	 => l_confirmation_mode
									     ,x_return_status            => l_return_status
									     ,x_msg_count                => l_msg_count
									     ,x_msg_data                 => l_msg_data);
				   end if;

				   IF l_return_status = 'SKIP' then
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - skip this account');
				     l_return_status := FND_API.G_RET_STS_SUCCESS;

					elsif l_return_status = 'X' then
						if l_repeat then
							WriteLog('get scoring engine');
							open c_scoring_engine(p_dunning_plan_id);
							fetch c_scoring_engine into l_score_engine_id, l_score_engine_name;
							close c_scoring_engine;
							FND_FILE.PUT_LINE(FND_FILE.LOG,'Validate correct scoring engine was run for this dunning plan.');
							FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine Name: ' || l_score_engine_name);
							FND_FILE.PUT_LINE(FND_FILE.LOG,'Scoring Engine ID:   ' || l_score_engine_id);
							l_repeat := false;
						else
							l_return_status := FND_API.G_RET_STS_SUCCESS;
						end if;

				   ELSIF l_return_status = FND_API.G_RET_STS_ERROR then
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - send_level_Failed - CONTINUE');
				   elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
				     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - send_level_Failed - CONTINUE');
				   END IF;

				--end if;  --if l_confirmation_mode is NULL then
			else
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_object_id: '||l_object_id || ' does not exist in filter object :' ||l_entity_name || ' so skipping');
			   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_object_id: '||l_object_id || ' does not exist in filter object :' ||l_entity_name || ' so skipping');
			end if;
	       close sql_cur2 ;
	       end loop; -- sql_cur
	       close sql_cur;

	     else -- we are running at delinquency level

	       i := 0;
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fetching delinquencies');
	       /*
	       Open C_Get_DEL (p_dunning_plan_id);
	       LOOP
		   Fetch C_Get_DEL into l_del_id, l_party_id, l_account_id, l_customer_site_use_id, l_score;

		   --If ( C_GET_DEL%NOTFOUND ) Then
		   --    FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Delinquency');
		   --      x_return_status := FND_API.G_RET_STS_ERROR;
		   --end if;

		   exit when C_GET_DEL%NOTFOUND;
		   */
		LOOP
		   fetch sql_cur into l_object_id;
	        exit when sql_cur%NOTFOUND;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fetched ' || l_object_id);
			open sql_cur2 for vPLSQL2 using l_object_id,p_dunning_plan_id;
			   fetch sql_cur2 into l_del_id, l_party_id, l_account_id, l_customer_site_use_id, l_score;
			   if SQL_CUR2%FOUND then
				   --l_atleast_one_rec := TRUE;
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_del_id' || l_del_id);
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_party_id ' || l_party_id);
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_account_id ' || l_account_id);
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_customer_site_use_id ' || l_customer_site_use_id);
				   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_score ' || l_score);

				   i := i + 1;
				   l_delinquencies_Tbl(i).delinquency_id       := l_del_id;
				   l_delinquencies_Tbl(i).party_cust_id        := l_party_id;
				   l_delinquencies_Tbl(i).cust_account_id      := l_account_id;
				   l_delinquencies_Tbl(i).customer_site_use_id := l_customer_site_use_id;
				   l_delinquencies_Tbl(i).score_value          := l_score;
			   end if;

		       Close sql_cur2;
		end loop; -- sql_cur
		close sql_cur;

	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - fetched ' || l_delinquencies_Tbl.count || ' delinquencies');
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Delinquency Level');

	       --if l_confirmation_mode is NULL  then
	       if l_dunning_type = 'STAGED_DUNNING' then
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - calling Send_Staged_Dunning');
			   IEX_DUNNING_PVT.Send_Staged_Dunning(p_api_version             => p_api_version
							     ,p_init_msg_list            => p_init_msg_list
							     ,p_commit                   => p_commit
							     ,p_dunning_plan_id          => p_dunning_plan_id
							     ,p_correspondence_date      => p_correspondence_date
							     ,p_delinquencies_tbl        => l_delinquencies_tbl
							     ,p_parent_request_id        => p_parent_request_id
							     ,p_dunning_mode	         => p_dunning_mode
							     ,p_single_staged_letter     => p_single_staged_letter    -- added by gnramasa for bug stageddunning 28-Dec-09
							     ,p_confirmation_mode	 => l_confirmation_mode
							     ,x_return_status            => l_return_status
							     ,x_msg_count                => l_msg_count
							     ,x_msg_data                 => l_msg_data);
	       else
		       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - calling Send_Dunning');
		       IEX_DUNNING_PVT.Send_Dunning(p_api_version              => p_api_version
						   ,p_init_msg_list            => p_init_msg_list
						   ,p_commit                   => p_commit
						   ,p_dunning_plan_id          => p_dunning_plan_id
						   ,p_delinquencies_tbl        => l_delinquencies_tbl
						   ,p_parent_request_id        => p_parent_request_id
						   ,p_dunning_mode	       => p_dunning_mode
						   ,p_confirmation_mode        => l_confirmation_mode
						   ,x_return_status            => l_return_status
						   ,x_msg_count                => l_msg_count
						   ,x_msg_data                 => l_msg_data);

		end if;
		--end if;  --if l_confirmation_mode is NULL then
	     end if;  --if p_running_level <> 'DELINQUENCY'
	end if; --if (p_parent_request_id is NULL OR p_process_err_rec_only = 'Y')

	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' checking whether to span the IEX: Bulk xml manager or not');
	if (p_dunning_mode = 'FINAL' and l_confirmation_mode is not null) then

		vPLSQL3 := 'select dun.dunning_id, dun.dunning_object_id, dun.dunning_level, dun.ag_dn_xref_id ' ||
			   'from iex_dunnings dun ' ||
                           'where dun.request_id = :1 ' ||
			   ' and dun.delivery_status IS NULL ' ||
			   ' and dun.confirmation_mode is null ';
		if l_custom_select IS NOT NULL then
                           --Start for bug 9818696 gnramasa 16th June 10
			   --vPLSQL3 := vPLSQL3 || ' and exists ( ' || l_custom_select ||' = dun.object_id) ';
			   vPLSQL3 := vPLSQL3 || ' and exists ( ' || l_custom_select ||' = dun.dunning_object_id) ';
		end if;

	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL3 ' || vPLSQL3);
	       open sql_cur3 for vPLSQL3 using p_parent_request_id;

	       LOOP
		   fetch sql_cur3 into l_dunning_id, l_dunning_object_id, l_dunning_level, l_ag_dn_xref_id;
	       exit when sql_cur3%NOTFOUND;
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_id :' || l_dunning_id);
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_object_id :' || l_dunning_object_id);
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_level :' || l_dunning_level);
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_ag_dn_xref_id :' || l_ag_dn_xref_id);

		--for c_dunn_req in c_dunning_ids(p_parent_request_id) loop
		--	l_dunning_rec_upd.dunning_id := c_dunn_req.dunning_id;
		l_dunning_rec_upd.dunning_id := l_dunning_id;

			if l_confirmation_mode = 'CONFIRM' then
				l_dunning_rec_upd.confirmation_mode := 'CONFIRMED';
				if (l_dunning_level = 'CUSTOMER') then
				  l_delinquencies_Tbl(1).party_cust_id := l_dunning_object_id;
				elsif (l_dunning_level = 'ACCOUNT') THEN
				  l_delinquencies_Tbl(1).cust_account_id := l_dunning_object_id;
				elsif (l_dunning_level = 'BILL_TO') THEN
				  l_delinquencies_Tbl(1).customer_site_use_id := l_dunning_object_id;
				else
				  l_delinquencies_Tbl(1).delinquency_id := l_dunning_object_id;
				end if;

				if l_dunning_type = 'STAGED_DUNNING' then
					   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - calling iex_dunning_pvt.Close_Staged_Dunning');
					   iex_dunning_pvt.Close_Staged_Dunning(
						p_api_version              => p_api_version
					      , p_init_msg_list            => p_init_msg_list
					      , p_commit                   => p_commit
					      , p_delinquencies_tbl        => l_delinquencies_Tbl
					      , p_ag_dn_xref_id	           => l_ag_dn_xref_id
					      , p_running_level            => p_running_level
					      --, p_status                   => l_status
					      , x_return_status            => l_return_status
					      , x_msg_count                => x_msg_count
					      , x_msg_data                 => x_msg_data);
				else
					WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning');

					  iex_dunning_pvt.Close_DUNNING(
						p_api_version              => p_api_version
					      , p_init_msg_list            => p_init_msg_list
					      , p_commit                   => p_commit
					      , p_delinquencies_tbl        => l_delinquencies_Tbl
					      --, p_dunning_id               => l_dunning_id   --c_dunn_req.dunning_id
					      --, p_status                   => 'CLOSE'
					      , p_running_level            => p_running_level
					      , x_return_status            => l_return_status
					      , x_msg_count                => x_msg_count
					      , x_msg_data                 => x_msg_data);
				end if;

				  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CloseDunning status='|| l_return_status);

				  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot Close Dunning');
					FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot Close Dunning');
					l_return_status := FND_API.G_RET_STS_ERROR;
				  END IF;

			--elsif l_confirmation_mode = 'REJECT' then
			--	l_dunning_rec_upd.confirmation_mode := 'REJECTED';
			--	l_dunning_rec_upd.status := 'CLOSE';
			end if;

			l_dunning_rec_upd.status := 'OPEN';

			IEX_DUNNING_PVT.Update_DUNNING(
							p_api_version              => 1.0
							, p_init_msg_list            => FND_API.G_FALSE
							, p_commit                   => FND_API.G_TRUE
							, p_dunning_rec              => l_dunning_rec_upd
							, x_return_status            => l_return_status
							, x_msg_count                => l_msg_count
							, x_msg_data                 => l_msg_data
						    );
		end loop;
		close sql_cur3;

		vPLSQL4 := 'select xml.xml_request_id ' ||
			   'from iex_dunnings dun, iex_xml_request_histories xml ' ||
                           'where xml.conc_request_id = :1 ' ||
			   ' and xml.xml_request_id = dun.xml_request_id ' ||
			   ' and xml.confirmation_mode is null ';
		if l_custom_select IS NOT NULL then
                           --vPLSQL4 := vPLSQL4 || ' and exists ( ' || l_custom_select ||' = dun.object_id) ';
			   vPLSQL4 := vPLSQL4 || ' and exists ( ' || l_custom_select ||' = dun.dunning_object_id) ';
		end if;


	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL4 ' || vPLSQL4);
	       open sql_cur4 for vPLSQL4 using p_parent_request_id;

	       LOOP
		   fetch sql_cur4 into l_xml_request_id;
	       exit when sql_cur4%NOTFOUND;
	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_xml_request_id :' || l_xml_request_id);
	       --l_atleast_one_rec := TRUE;

		--for c_xml_req in c_xml_request_ids(p_parent_request_id) loop
		--	l_xml_request_id := c_xml_req.xml_request_id;
			if l_confirmation_mode = 'CONFIRM' then
				l_conf_mode := 'CONFIRMED';
			--elsif l_confirmation_mode = 'REJECT' then
			--	l_conf_mode := 'REJECTED';
			--	l_status := 'CANCELLED';
			end if;

			IEX_XML_PKG.update_row(
						p_xml_request_id      => l_xml_request_id
						, p_status            => l_status
						, p_confirmation_mode => l_conf_mode
					      );
		end loop;
		close sql_cur4;

		if l_dunning_type = 'STAGED_DUNNING' then
			vPLSQL6 := 'select xml.xml_request_id ' ||
					   'from iex_dunnings dun, iex_xml_request_histories xml ' ||
					   'where xml.conc_request_id = :1 ' ||
					   ' and xml.xml_request_id = dun.xml_request_id ' ||
					   ' and xml.confirmation_mode is null ' ||
					   ' and dun.object_type = ''INX_INVOICES'' ';
				if l_custom_select IS NOT NULL then
					   --vPLSQL6 := vPLSQL6 || ' and exists ( ' || l_custom_select ||' = dun.object_id) ';
					   vPLSQL6 := vPLSQL6 || ' and exists ( ' || l_custom_select ||' = dun.dunning_object_id) ';
				end if;


			       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL6 ' || vPLSQL6);
			       open sql_cur6 for vPLSQL6 using p_parent_request_id;

			       LOOP
				   fetch sql_cur6 into l_xml_request_id;
			       exit when sql_cur6%NOTFOUND;
			       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_xml_request_id :' || l_xml_request_id);
				if l_confirmation_mode = 'CONFIRM' then
					l_conf_mode := 'CONFIRMED';
				end if;

				IEX_XML_PKG.update_row(
							p_xml_request_id      => l_xml_request_id
							, p_status            => l_status
							, p_confirmation_mode => l_conf_mode
						      );
				end loop;
				close sql_cur6;

		end if; --if l_dunning_type = 'STAGED_DUNNING' then

	end if;  --if (p_dunning_mode = 'FINAL' and l_confirmation_mode is not null) then

	if p_dunning_mode = 'FINAL' and l_dunning_type = 'STAGED_DUNNING' then
		vPLSQL5 := 'select iet.payment_schedule_id, iet.stage_number ' ||
			   'from iex_dunnings dun, iex_dunning_transactions iet ' ||
			   'where dun.request_id = :1 ' ||
			   ' and dun.dunning_id = iet.dunning_id ' ||
			   ' and dun.delivery_status is null ' ||
			   ' and iet.cust_trx_id is not null ' ||
			   ' and iet.stage_number is not null ' ||
			   ' and dun.object_type <> ''INX_INVOICES'' ';
		if l_custom_select IS NOT NULL then
			   --vPLSQL5 := vPLSQL5 || ' and exists ( ' || l_custom_select ||' = dun.object_id) ';
			   vPLSQL5 := vPLSQL5 || ' and exists ( ' || l_custom_select ||' = dun.dunning_object_id) ';
			   --End for bug 9818696 gnramasa 16th June 10
		end if;
		vPLSQL5 := vPLSQL5 || ' order by iet.dunning_trx_id ';


	       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - vPLSQL5 ' || vPLSQL5);
	       open sql_cur5 for vPLSQL5 using l_req_id;

	       LOOP
		   fetch sql_cur5 into l_payment_schedule_id, l_stage_number;
		   exit when sql_cur5%NOTFOUND;
	           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_payment_schedule_id :' || l_payment_schedule_id);
	           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_stage_number :' || l_stage_number);

		   update iex_delinquencies_all
		   set staged_dunning_level = l_stage_number
		   where payment_schedule_id = l_payment_schedule_id;
	       end loop;
	       close sql_cur5;
	       commit;
	end if;

	--if (p_dunning_mode = 'DRAFT') or (p_dunning_mode = 'FINAL' and l_confirmation_mode ='CONFIRM')
	--   or (p_dunning_mode='FINAL' and l_confirmation_mode is NULL) then

	open c_no_success_dunn_rec(l_req_id);
	fetch c_no_success_dunn_rec into l_no_final_successful_rec;
	close c_no_success_dunn_rec;
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_final_successful_rec : '|| l_no_final_successful_rec);

	if ((l_req_mode = 'DRAFT') and (p_parent_request_id IS NOT NULL) and (p_dunning_mode = 'FINAL') and (p_process_err_rec_only <> 'Y')) then
		WriteLog(G_PKG_NAME || ' ' || l_api_name || 'in DRAFT records delivery mode');
		l_diff_bw_init_fi_su_rec	:= l_no_init_successful_rec;
	else
		l_diff_bw_init_fi_su_rec	:= l_no_final_successful_rec - l_no_init_successful_rec;
	end if;
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_diff_bw_init_fi_su_rec : '|| l_diff_bw_init_fi_su_rec);

		l_no_of_workers := nvl(p_no_of_workers,1);
		--if not (p_dunning_mode = 'FINAL' and l_confirmation_mode is not null) then

			if ( l_diff_bw_init_fi_su_rec > 0)  then

				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Atleast one dunning record processed successfully. So spawning the IEX: XML bulk manager for delivery');
				FND_FILE.put_line( FND_FILE.LOG,'Atleast one dunning record processed successfully. So spawning the IEX: XML bulk manager for delivery');

				open c_object_type (l_req_id);
				fetch c_object_type into l_object_type;
				close c_object_type;

				--span bulk xml delivery
				l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
							      APPLICATION       => 'IEX',
							      PROGRAM           => 'IEX_BULK_XML_DELIVERY',
							      DESCRIPTION       => 'Oracle Collections Delivery XML Process',
							      START_TIME        => sysdate,
							      SUB_REQUEST       => false,
							      ARGUMENT1         => l_no_of_workers,
							      ARGUMENT2         => null,
							      ARGUMENT3         => null,
							      ARGUMENT4         => l_req_id,
							      ARGUMENT5         => p_dunning_mode,
							      ARGUMENT6         => null,
							      ARGUMENT7         => l_object_type);

				WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Submitted the Bulk XML delivery, l_submit_request_id='||l_submit_request_id);
			else
				WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Not even one dunning record processed successfully. So no need to spawn the IEX: XML bulk manager for delivery');
				FND_FILE.put_line( FND_FILE.LOG,'');
				FND_FILE.put_line( FND_FILE.LOG,'*******************************************************************************************************************************');
				FND_FILE.put_line( FND_FILE.LOG,'*  WARNING: Not even one dunning record processed successfully. So no need to spawn the IEX: XML bulk manager for delivery    *');
				FND_FILE.put_line( FND_FILE.LOG,'*******************************************************************************************************************************');
				FND_FILE.put_line( FND_FILE.LOG,'');
			end if;

		--end if;
	--end if;

   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' status='||l_return_status);

   if l_dunning_type = 'STAGED_DUNNING' then
	   if p_process_err_rec_only = 'Y' then
		open c_get_inv_count_in_errmode (l_req_id, l_max_dunning_trx_id);
		fetch c_get_inv_count_in_errmode into l_dunn_invoice_ct;
		close c_get_inv_count_in_errmode;
	   else
		open c_get_invoice_ct (l_req_id)  ;
		fetch c_get_invoice_ct into l_dunn_invoice_ct;
		close c_get_invoice_ct;
	   end if;

	   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Dunning invoices count = '||l_dunn_invoice_ct);

	   IF (l_dunn_invoice_ct is null or l_dunn_invoice_ct = 0) then
		   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No stage dunning invoice');
		   FND_FILE.PUT_LINE(FND_FILE.LOG, 'No stage dunning invoice');
		   goto end_loop;
	   ELSE
		 -- Now, COLLECTIONS STAGE DUNNING INVOICE is not null;

		 FND_FILE.PUT_LINE(FND_FILE.LOG, 'COLLECTIONS STAGE DUNNING INVOICE='||l_dunn_invoice_ct);
		 IF (p_parent_request_id is NULL OR p_process_err_rec_only = 'Y') THEN
			 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start calling IEX_DUNNING_PVT.stage_dunning_inv_copy');
			 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start stage_dunning_inv_copy');

			 IEX_DUNNING_PVT.stage_dunning_inv_copy(
			      p_api_version              => 1.0
			    , p_init_msg_list            => FND_API.G_FALSE
			    , p_commit                   => FND_API.G_TRUE
			    , p_no_of_workers            => l_no_of_workers
			    , p_process_err_rec_only     => p_process_err_rec_only
			    , p_request_id               => l_req_id
			    , p_dunning_mode	         => p_dunning_mode
			    , p_confirmation_mode	 => l_confirmation_mode
			    , p_running_level            => p_running_level
			    , p_correspondence_date      => p_correspondence_date
			    , p_max_dunning_trx_id       => l_max_dunning_trx_id
			    , x_return_status            => l_return_status
			    , x_msg_count                => l_msg_count
			    , x_msg_data                 => l_msg_data
			    );

			FND_FILE.PUT_LINE(FND_FILE.LOG, 'Return status of IEX_DUNNING_PVT.stage_dunning_inv_copy='||l_return_status);
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Return status of IEX_DUNNING_PVT.stage_dunning_inv_copy='||l_return_status);

			IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Cannot create invoice copy');
			   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot create invoice copy');
			   l_return_status := FND_API.G_RET_STS_ERROR;
			END IF;
		END IF;
	   END IF;  --IF (l_dunn_invoice_ct is null or l_dunn_invoice_ct = 0) then

	   open c_no_success_inv_rec(l_req_id);
	   fetch c_no_success_inv_rec into l_no_final_successful_inv_rec;
	   close c_no_success_inv_rec;
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_no_final_successful_inv_rec : '|| l_no_final_successful_inv_rec);

	   if ((l_req_mode = 'DRAFT') and (p_parent_request_id IS NOT NULL) and (p_dunning_mode = 'FINAL') and (p_process_err_rec_only <> 'Y')) then
			WriteLog(G_PKG_NAME || ' ' || l_api_name || 'in DRAFT records Invoice delivery mode');
			l_diff_bw_init_fi_su_inv_rec	:= l_no_init_successful_inv_rec;
	   else
			l_diff_bw_init_fi_su_inv_rec	:= l_no_final_successful_inv_rec - l_no_init_successful_inv_rec;
	   end if;
	   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_diff_bw_init_fi_su_inv_rec : '|| l_diff_bw_init_fi_su_inv_rec);

	   if ( l_diff_bw_init_fi_su_inv_rec > 0)  then
			WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Atleast one invoice is satisfied to send invoice copy. So spawning the IEX: XML bulk manager for delivery');
			FND_FILE.put_line( FND_FILE.LOG,'Atleast one invoice is satisfied to send invoice copy. So spawning the IEX: XML bulk manager for delivery');

			l_no_of_workers := nvl(p_no_of_workers,1);
			--span bulk xml delivery
			l_submit_request_id := FND_REQUEST.SUBMIT_REQUEST(
						      APPLICATION       => 'IEX',
						      PROGRAM           => 'IEX_BULK_XML_DELIVERY',
						      DESCRIPTION       => 'Oracle Collections Staged Dunning Invoice Copy',
						      START_TIME        => sysdate,
						      SUB_REQUEST       => false,
						      ARGUMENT1         => l_no_of_workers,
						      ARGUMENT2         => null,
						      ARGUMENT3         => null,
						      ARGUMENT4         => l_req_id,
						      ARGUMENT5         => p_dunning_mode,
						      ARGUMENT6         => null,
						      ARGUMENT7         => 'IEX_INVOICES');

			WriteLog(G_PKG_NAME || ' ' || l_api_name || 'Submitted the Bulk XML delivery, l_submit_request_id='||l_submit_request_id);
	   end if;

   end if; --if l_dunning_type = 'STAGED_DUNNING' then
--*/
-- Start bug 5924158 05/06/07 by gnramasa
   /*   x_return_status := l_return_status;
      IF l_return_status = FND_API.G_RET_STS_ERROR then
         raise FND_API.G_EXC_ERROR;
      elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   */
-- End bug 5924158 05/06/07 by gnramasa
      --
      -- End of API body
      --

   <<end_loop>>
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - commit');
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


     if p_process_err_rec_only = 'Y' then
	open c_no_err_dunn_rec(p_parent_request_id);
        fetch c_no_err_dunn_rec into l_no_of_fail_rec_bylastrun;
        close c_no_err_dunn_rec;
	l_no_of_succ_rec_bylastrun := (l_no_of_rec_prc_bylastrun - l_no_of_fail_rec_bylastrun);
     end if;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - before alling iex_dunning_pvt.gen_xml_data_dunning');

     if l_con_proc_mode in ('FINALDRAFT','DRAFTDRAFT') then
	l_process_err_rec_only := 'N';
     else
	l_process_err_rec_only := p_process_err_rec_only;
     end if;

     iex_dunning_pvt.gen_xml_data_dunning( p_request_id			=> l_req_id,
                                            p_running_level		=> p_running_level,
					    p_dunning_plan_id		=> p_dunning_plan_id,
					    p_dunning_mode		=> p_dunning_mode,
					    p_confirmation_mode		=> l_confirmation_mode,
					    p_process_err_rec_only      => l_process_err_rec_only,
					    p_no_of_rec_prc_bylastrun   => l_no_of_rec_prc_bylastrun,
					    p_no_of_succ_rec_bylastrun	=> l_no_of_succ_rec_bylastrun,
					    p_no_of_fail_rec_bylastrun	=> l_no_of_fail_rec_bylastrun,
					    x_no_of_rec_prc		=> l_no_of_rec_prc,
					    x_no_of_succ_rec		=> l_no_of_succ_rec,
				            x_no_of_fail_rec		=> l_no_of_fail_rec
					    );

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - After alling iex_dunning_pvt.gen_xml_data_dunning');
     --End adding for bug 8489610 by gnramasa 14-May-09

     --Set the iex: send dunning cp to WARNING status if at least one dunning record is failed to process
     open c_no_err_dunn_rec (l_req_id);
     fetch c_no_err_dunn_rec into l_no_err_dunn_rec;
     close c_no_err_dunn_rec;

     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_no_err_dunn_rec: '||l_no_err_dunn_rec);

     if l_update_cp_as_err then
	if l_con_proc_mode = 'FINALDRAFT' then
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, because request has been created in direct FINAL mode.');
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Run this in FINAL mode with process errors Y to process the errored records.');
		FND_FILE.put_line( FND_FILE.LOG,'');
		FND_FILE.put_line( FND_FILE.LOG,'***************************************************************************************************************************');
		FND_FILE.PUT_LINE( FND_FILE.LOG,'*  ERROR: You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, because request has been created in direct FINAL mode.  *');
		FND_FILE.PUT_LINE( FND_FILE.LOG,'*  Run this in FINAL mode with process errors Y to process the errored records.                                           *');
		FND_FILE.put_line( FND_FILE.LOG,'***************************************************************************************************************************');
		FND_FILE.put_line( FND_FILE.LOG,'');
		l_err_message := 'ERROR: You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, because request has been created in direct FINAL mode. Run this in FINAL mode with process errors Y to process the errored records.';
	elsif l_con_proc_mode = 'DRAFTDRAFT' then
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, as this request has been already submitted in FINAL mode.');
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Run this in FINAL mode with process errors Y to process the errored records.');
		FND_FILE.put_line( FND_FILE.LOG,'');
		FND_FILE.put_line( FND_FILE.LOG,'*******************************************************************************************************************************');
		FND_FILE.PUT_LINE( FND_FILE.LOG,'*   ERROR: You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, as this request has been already submitted in FINAL mode.  *');
		FND_FILE.PUT_LINE( FND_FILE.LOG,'*   Run this in FINAL mode with process errors Y to process the errored records.                                              *');
		FND_FILE.put_line( FND_FILE.LOG,'*******************************************************************************************************************************');
		FND_FILE.put_line( FND_FILE.LOG,'');
		l_err_message := 'ERROR: You can''t run this request id: ' || p_parent_request_id || ' in PREVIEW mode, as this request has been already submitted in FINAL mode. Run this in FINAL mode with process errors Y to process the errored records.';
	end if;
	l_con_update_re_st := fnd_concurrent.set_completion_status (status  => 'ERROR',
	                                      message => l_err_message);
	goto proc_end;
     elsif l_no_err_dunn_rec > 0 then
	WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Set the iex: send dunning cp to WARNING status as at least one dunning record is failed to process');
	FND_FILE.put_line( FND_FILE.LOG,'');
	FND_FILE.put_line( FND_FILE.LOG, '**********************************************************************************************************');
	FND_FILE.put_line( FND_FILE.LOG, '*  WARNING: Concurrent program ended in WARNING, as at least one dunning record is failed to process     *');
	FND_FILE.put_line( FND_FILE.LOG, '**********************************************************************************************************');
	FND_FILE.put_line( FND_FILE.LOG,'');
	l_con_update_re_st := fnd_concurrent.set_completion_status (status  => 'WARNING',
	                                      message => 'At least one dunning record is failed to process');
     end if;

     FND_FILE.put_line( FND_FILE.LOG,'');
     FND_FILE.put_line( FND_FILE.LOG, '*************************************************************************');
     FND_FILE.put_line( FND_FILE.LOG, '*   Number of record(s) processed 	: ' || l_no_of_rec_prc || '                            *');
     FND_FILE.put_line( FND_FILE.LOG, '*   Number of successful record(s)	: ' || l_no_of_succ_rec || '                            *');
     FND_FILE.put_line( FND_FILE.LOG, '*   Number of failed record(s)    	: ' || l_no_of_fail_rec || '                            *');
     FND_FILE.put_line( FND_FILE.LOG, '*************************************************************************');
     FND_FILE.put_line( FND_FILE.LOG,'');

     if p_process_err_rec_only = 'Y' then
	     FND_FILE.put_line( FND_FILE.LOG,'');
	     FND_FILE.put_line( FND_FILE.LOG, '*************************************************************************');
	     FND_FILE.put_line( FND_FILE.LOG, '*   In Error mode:                                                      *');
	     FND_FILE.put_line( FND_FILE.LOG, '*   --------------                                                      *');
	     FND_FILE.put_line( FND_FILE.LOG, '*   Number of errored record(s) processed by this run	: ' || l_no_of_rec_prc_bylastrun || '            *');
	     FND_FILE.put_line( FND_FILE.LOG, '*   Number of successful record(s) by this run		: ' || l_no_of_succ_rec_bylastrun || '             *');
	     FND_FILE.put_line( FND_FILE.LOG, '*   Number of failed record(s) by this run   		: ' || l_no_of_fail_rec_bylastrun || '            *');
	     FND_FILE.put_line( FND_FILE.LOG, '*************************************************************************');
	     FND_FILE.put_line( FND_FILE.LOG,'');
     end if;

     <<proc_end>>
      -- Debug Message
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);
     WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - END');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ROLLBACK TO Send_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Send_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO Send_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Send_Dunning;

Procedure Daily_Dunning
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            --p_dunning_tbl             IN IEX_DUNNING_PUB.DUNNING_TBL_TYPE,
            p_running_level           IN VARCHAR2 ,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Daily_Dunning';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);
    errmsg                  VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DAILY_DUNNING_PUB;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Start');
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running_level='||p_running_level);

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Calling PVT');

      IEX_DUNNING_PVT.Daily_Dunning(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_running_level            => p_running_level
            --, p_dunning_tbl              => p_dunning_tbl
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data
            );

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - return status='||x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         IF x_return_status = FND_API.G_RET_STS_ERROR then
            raise FND_API.G_EXC_ERROR;
         else
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - end ');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ROLLBACK TO DAILY_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO DAILY_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK TO DAILY_DUNNING_PUB;
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - error='||SQLERRM);
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data );

END Daily_Dunning;



PROCEDURE CALLBACK_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
	    P_ORG_ID    IN NUMBER DEFAULT NULL) --Added for MOAC
is
    CURSOR C_GET_LEVEL IS
      SELECT preference_value
        FROM IEX_APP_PREFERENCES_VL
       WHERE upper(PREFERENCE_NAME) = 'COLLECTIONS DUNNING LEVEL';
  --
  l_api_version       NUMBER := 1.0;
  l_msg_data          VARCHAR2(4000) default NULL;
  l_msg_count         NUMBER;
  l_default_rs_id     number := 0;
  l_running_level     VARCHAR2(20);
  l_error             NUMBER := 0;
  errmsg              VARCHAR2(4000) default NULL;
  l_api_name          varchar2(25);

BEGIN

  l_api_name := 'callback_concur';
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Callback_Concur');
  WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - starting CALLBACK_CONCUR');

  --Start MOAC
  mo_global.init('IEX');
  IF p_org_id IS NULL THEN
	mo_global.set_policy_context('M',NULL);
  ELSE
	mo_global.set_policy_context('S',p_org_id);
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Operating Unit: '|| nvl(mo_global.get_ou_name(mo_global.get_current_org_id), 'All'));
  --End MOAC

  l_default_rs_id := fnd_profile.value('IEX_STRY_DEFAULT_RESOURCE');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Default Resource Id = '||l_default_rs_id);
  WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - default_rs_id='||l_default_rs_id);

  if (l_default_rs_id = 0 or l_default_rs_id is null) then
      WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - CALLBACK_CONCUR:no rs_id');
      FND_MESSAGE.Set_Name('IEX', 'IEX_CANNOT_GET_PROFILE');
      FND_MESSAGE.Set_Token ('PROFILE', 'IEX_STRY_DEFAULT_RESOURCE', FALSE);
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   l_msg_count,
         p_data           =>   l_msg_data
      );

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'no default resource_id');
      errbuf := l_msg_data;
      retcode := '2'; --FND_API.G_RET_STS_ERROR;
      --retcode := FND_API.G_RET_STS_ERROR;
      WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);

      for i in 1..l_msg_count loop
          errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                    p_encoded => 'F');
          FND_FILE.PUT_LINE(FND_FILE.LOG, errmsg);
          WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
      end loop;

  --
  else
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - rs_id='||l_default_rs_id);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Daily_Dunning');

      OPEN C_Get_Level ;
      FETCH C_Get_Level INTO l_running_level;

      IF (C_Get_Level%NOTFOUND)
      THEN
          l_error := 1;
      END IF;
      CLOSE C_GET_LEVEL;

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - running level='||l_running_level);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dunning Running Level = '||l_running_level);
      IF (l_running_level is null or l_error = 1) then
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - no running level');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'No Dunning Running Level');
         FND_MESSAGE.Set_Name('IEX', 'IEX_NO_VALUE');
         FND_MESSAGE.Set_Token('COLUMN', 'COLLECTIONS DUNNING LEVEL', FALSE);
         FND_MSG_PUB.Add;

         FND_MSG_PUB.Count_And_Get
         (  p_count          =>   l_msg_count,
            p_data           =>   l_msg_data
         );

         errbuf := l_msg_data;
         retcode := '2'; --FND_API.G_RET_STS_ERROR;
         WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);

         for i in 1..l_msg_count loop
             errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                       p_encoded => 'F');
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Calback_Concur errmsg =' ||errmsg);
         end loop;
     --
     else
        FND_FILE.PUT_LINE(FND_FILE.LOG, '>>>>>Process Dunning Callbacks');
        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - starting Daily_Dunning');
        IEX_DUNNING_PUB.Daily_Dunning(
          p_api_version            => l_api_version
        , p_init_msg_list          => FND_API.G_TRUE
        , p_commit                 => FND_API.G_TRUE
        , p_running_level          => l_running_level
        , x_return_status          => RETCODE
        , x_msg_count              => l_msg_count
        , x_msg_data               => ERRBUF
        );

        WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Daily_Dunning status='||retcode);
        FND_FILE.PUT_LINE(FND_FILE.LOG, '>>>>>End of Process Dunning Callbacks');
     end if;
     --
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ProcessPromiseCallbacks');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '>>>>>Process Promise Callbacks');

      IEX_PROMISES_BATCH_PUB.PROCESS_PROMISE_CALLBACKS(
         p_api_version            => l_api_version
       , p_init_msg_list          => FND_API.G_TRUE
       , p_commit                 => FND_API.G_TRUE
       , x_return_status          => RETCODE
       , x_msg_count              => ERRBUF
       , x_msg_data               => l_msg_data);

      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - ProcessPromiseCallbacks status='||retcode);
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End ProcessPromiseCallbacks');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '>>>>>End of Process Promise Callbacks');

  end if;

  EXCEPTION
     WHEN OTHERS THEN
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exception');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Callback_Concur Exception');
          errbuf := SQLERRM;
          retcode := '2';
	  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Callback_Concur errbuf:'||errbuf);

END CALLBACK_CONCUR;



PROCEDURE SEND_DUNNING_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
            DUNNING_PLAN_ID IN         NUMBER,
	    p_staged_dunning_dummy  IN   VARCHAR2,
	    p_correspondence_date   IN   VARCHAR2,
	    p_parent_request_id     IN   NUMBER,
	    p_dunning_mode          IN   VARCHAR2 DEFAULT 'FINAL',  -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_dummy     IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 14-May-09
	    p_process_err_rec_only  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 14-May-09
	    p_no_of_workers         IN   number := 1,               -- added by gnramasa for bug 8489610 14-May-09
	    p_single_staged_letter  IN   VARCHAR2 DEFAULT 'N',      -- added by gnramasa for bug stageddunning 28-Dec-09
	    p_coll_bus_level_dummy  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_customer_name_low     IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_customer_name_high    IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    --p_account_number_dummy  IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_account_number_low    IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_account_number_high   IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_dummy IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_low   IN   VARCHAR2,                  -- added by gnramasa for bug 8489610 28-May-09
	    p_billto_location_high  IN   VARCHAR2)                  -- added by gnramasa for bug 8489610 28-May-09
is
    CURSOR C_GET_LEVEL (iex_dunning_plan_id number) IS
      select dunning_level from iex_dunning_plans_vl
      where dunning_plan_id = iex_dunning_plan_id;
      -- 12.0 ctlee, get it from the dunning_plan
      -- SELECT preference_value
      --   FROM IEX_APP_PREFERENCES_VL
      --  WHERE upper(PREFERENCE_NAME) = 'COLLECTIONS DUNNING LEVEL';
    --
    CURSOR C_GET_BUCKET (iex_dunning_plan_id number) IS
      select aging_bucket_id from iex_dunning_plans_vl
      where dunning_plan_id = iex_dunning_plan_id;
      -- 12.0 ctlee, get it from the dunning_plan
      -- SELECT preference_value
        -- FROM IEX_APP_PREFERENCES_VL
       --WHERE upper(PREFERENCE_NAME) = 'COLLECTIONS AGING BUCKET';
       -- WHERE upper(PREFERENCE_NAME) = 'DUNNING PLAN AGING BUCKET';
    --
  l_api_version       NUMBER := 1.0;
  l_msg_count         NUMBER ;
  l_msg_data          VARCHAR2(4000) default NULL;
  l_running_level     VARCHAR2(20);
  l_bucket            VARCHAR2(100);
  l_error             NUMBER := 0;
  errmsg              VARCHAR2(4000) default NULL;
  l_api_name          varchar2(25);
  l_correspondence_date	date;
  l_dunning_type      varchar2(20);

  cursor c_dunning_type (p_dunn_plan_id number) is
  select nvl(dunning_type,'DAYS_OVERDUE')
   from IEX_DUNNING_PLANS_B
   where dunning_plan_id = p_dunn_plan_id;

BEGIN

   l_api_name := 'SEND_DUNNING_CONCUR';

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'SEND_DUNNING_CONCUR dunning_plan_id = ' || dunning_plan_id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CORRESPONDENCE DATE         : ' || p_correspondence_date);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'PARENT REQUEST ID           : ' || p_parent_request_id);
   --Start adding for bug 8489610 by gnramasa 14-May-09
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'DUNNING MODE                : ' || p_dunning_mode);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'SINGLE STAGED LETTER        : ' || p_single_staged_letter);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'PROCESS ERRORED RECORD ONLY : ' || p_process_err_rec_only);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'NUMBER OF WORKERS           : ' || p_no_of_workers);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUSTOMER NAME LOW           : ' || p_customer_name_low);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUSTOMER NAME HIGH          : ' || p_customer_name_high);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNT NUMBER LOW		: ' || p_account_number_low);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACCOUNT NUMBER HIGH		: ' || p_account_number_high);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'BILLTO LOCATION LOW		: ' || p_billto_location_low);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'BILLTO LOCATION HIGH	: ' || p_billto_location_high);

   WriteLog('iexpdunb:starting SEND_DUNNING_CONCUR; dunning_plan_id		: ' || dunning_plan_id);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start');
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - correspondence date		:' || p_correspondence_date);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - parent request id		:' || p_parent_request_id);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - dunning mode			:' || p_dunning_mode);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - single staged letter		:' || p_single_staged_letter);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - process errored rec only	:' || p_process_err_rec_only);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_no_of_workers		:' || p_no_of_workers);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_low		:' || p_customer_name_low);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_customer_name_high		:' || p_customer_name_high);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_low		:' || p_account_number_low);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_account_number_high	:' || p_account_number_high);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_low	:' || p_billto_location_low);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - p_billto_location_high	:' || p_billto_location_high);

   --End adding for bug 8489610 by gnramasa 14-May-09

   --Start MOAC
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Org Id:'|| mo_global.get_current_org_id);
   --End MOAC

   retcode := FND_API.G_RET_STS_SUCCESS;
   --
   open c_dunning_type (dunning_plan_id);
   fetch c_dunning_type into l_dunning_type;
   close c_dunning_type;
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_type ' || l_dunning_type);

   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'chk bucket');
   OPEN C_Get_Level (dunning_plan_id);
   FETCH C_Get_Level INTO l_running_level;

   IF (C_Get_Level%NOTFOUND)
   THEN
       l_error := 1;
   END IF;
   CLOSE C_GET_LEVEL;

   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'running level='||l_running_level);
   WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - running level='||l_running_level);

   if (l_running_level is null or l_error = 1) then
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - no running level');
      END IF;
      FND_MESSAGE.Set_Name('IEX', 'IEX_NO_VALUE');
      FND_MESSAGE.Set_Token('COLUMN', 'COLLECTIONS DUNNING LEVEL', FALSE);
      FND_MSG_PUB.Add;

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   l_msg_count,
         p_data           =>   l_msg_data
      );

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'no running level');
      errbuf := l_msg_data;
      retcode := '2';
      WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);

      for i in 1..l_msg_count loop
          errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                    p_encoded => 'F');
          FND_FILE.PUT_LINE(FND_FILE.LOG, errmsg);
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
      end loop;
  --
  else

     --FND_FILE.PUT_LINE(FND_FILE.LOG, 'running level='||l_running_level);
     --FND_FILE.PUT_LINE(FND_FILE.LOG, 'chk bucket');
     OPEN C_Get_Bucket (dunning_plan_id)  ;
     FETCH C_Get_Bucket INTO l_bucket;

     IF (C_Get_Bucket%NOTFOUND) THEN
         l_error := 1;
     END IF;
     CLOSE C_GET_Bucket;

     --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Aging Bucket='||l_bucket);
     WriteLog('Send_Dunning: ' || G_PKG_NAME || ' ' || l_api_name || ' - bucket='||l_bucket);

     IF (l_bucket is null or l_error = 1) and (l_dunning_type <> 'STAGED_DUNNING') then
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - no bucket');
           FND_MESSAGE.Set_Name('IEX', 'IEX_NO_VALUE');
           --FND_MESSAGE.Set_Token('COLUMN', 'COLLECTIONS AGING BUCKET', FALSE);
           FND_MESSAGE.Set_Token('COLUMN', 'DUNNING PLAN AGING BUCKET', FALSE);
           FND_MSG_PUB.Add;

           FND_MSG_PUB.Count_And_Get
           (  p_count          =>   l_msg_count,
              p_data           =>   l_msg_data
           );

           FND_FILE.PUT_LINE(FND_FILE.LOG, 'no bucket');
           errbuf := l_msg_data;
           retcode := '2';
           WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);

           for i in 1..l_msg_count loop
              errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                        p_encoded => 'F');
              FND_FILE.PUT_LINE(FND_FILE.LOG, errmsg);
              WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
           end loop;

     --
     ELSE
         -- Now, RunningLevel and Bucket are not null;

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dunning Running Level='||l_running_level);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Dunning Aging Bucket='||l_bucket);
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start Send_Dunning');
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - runninglevel='||l_running_level);
           iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - bucket='||l_bucket);
           iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - starting Send_Dunning');
         END IF;
	 --l_correspondence_date	:= nvl(p_correspondence_date, trunc(sysdate));
	 l_correspondence_date	:= trunc(nvl(to_date(substr(p_correspondence_date, 1, 10), 'YYYY/MM/DD'),to_date(to_char(sysdate,'YYYY/MM/DD'),'YYYY/MM/DD')));

         IEX_DUNNING_PUB.SEND_DUNNING(
           p_api_version            => l_api_version
         , p_init_msg_list          => FND_API.G_TRUE
         , p_commit                 => FND_API.G_TRUE
         , p_running_level          => l_running_level
	 , p_parent_request_id      => p_parent_request_id
         , p_dunning_plan_id        => dunning_plan_id
	 , p_correspondence_date    => l_correspondence_date
	 , p_dunning_mode	    => p_dunning_mode        -- added by gnramasa for bug 8489610 14-May-09
	 , p_process_err_rec_only   => p_process_err_rec_only
	 , p_no_of_workers          => p_no_of_workers       -- added by gnramasa for bug 8489610 14-May-09
	 , p_single_staged_letter   => nvl(p_single_staged_letter,'N')      -- added by gnramasa for bug stageddunning 28-Dec-09
	 , p_customer_name_low      => p_customer_name_low
	 , p_customer_name_high     => p_customer_name_high
	 , p_account_number_low     => p_account_number_low
	 , p_account_number_high    => p_account_number_high
	 , p_billto_location_low    => p_billto_location_low
	 , p_billto_location_high   => p_billto_location_high
         , x_return_status          => RETCODE
         , x_msg_count              => l_msg_count
         , x_msg_data               => ERRBUF
         );

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'return_status='||retcode);
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.LogMessage(G_PKG_NAME || ' ' || l_api_name || ' - status='||retcode);
        END IF;

        IF (retcode <> FND_API.G_RET_STS_SUCCESS) THEN
           FND_MSG_PUB.Count_And_Get
           (  p_count          =>   l_msg_count,
              p_data           =>   l_msg_data
           );

           errbuf := l_msg_data;
           retcode := '2';
	   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||errbuf);

           for i in 1..l_msg_count loop
             errmsg := FND_MSG_PUB.Get(p_msg_index => i,
                                       p_encoded => 'F');
             FND_FILE.PUT_LINE(FND_FILE.LOG, errmsg);
             WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errmsg='||errmsg);
           end loop;
        END IF;

     END IF; -- END OF CHK Bucket

  End if; -- END of Chk RunningLevel

  EXCEPTION
     WHEN OTHERS THEN
          retcode := '2'; --FND_API.G_RET_STS_UNEXP_ERROR;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||SQLERRM);
          FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);

END SEND_DUNNING_CONCUR;

--Start for bug 9582646 gnramasa 5th May 10
PROCEDURE STG_DUNNING_MIG_CONCUR(
            ERRBUF      OUT NOCOPY     VARCHAR2,
            RETCODE     OUT NOCOPY     VARCHAR2,
            p_migration_mode   IN   VARCHAR2 DEFAULT 'FINAL')
is

  l_api_version			NUMBER := 1.0;
  l_msg_count			NUMBER ;
  l_msg_data			VARCHAR2(4000) default NULL;
  l_running_level		VARCHAR2(20);
  l_bucket			VARCHAR2(100);
  l_error			NUMBER := 0;
  errmsg			VARCHAR2(4000) default NULL;
  l_api_name			varchar2(25);
  l_dunning_plan_id		number;
  l_ag_dn_xref_id		number;
  l_include_current		varchar2(3) := 'N';
  l_template_id			number;
  TYPE number_list is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  l_staged_dunning_level	number_list;
  l_payment_schedule_id		number_list;
  l_return			BOOLEAN;
  l_dunning_letter_set_id       number;
  l_migrated_data		varchar2(10);
  l_business_level		varchar2(20);
  l_score_id			number;
  l_output_string		varchar2(1000);
  l_no_updated_rows		number := 0;
  l_migration_mode		varchar2(20);
  l_rec_exists			varchar2(1) := 'N';
  l_con_update_re_st		boolean;

  cursor c_dunning_letter_sets is
  select dunning_letter_set_id,
         name,
	 description,
	 status,
	 grace_days,
	 dun_disputed_items,
	 include_unused_payments_flag,
	 dunning_type,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login
  from ar_dunning_letter_sets
  where dunning_type = 'STAGED_DUNNING';

  cursor c_migrated_dunn_letter_sets is
  select dnb.dunning_plan_id dunning_plan_id,
	dnb.dunning_level dunning_level,
	dntl.name name,
	dntl.description description,
	dnb.mig_dunning_letter_set_id mig_dunning_letter_set_id
  from iex_dunning_plans_b dnb,
  iex_dunning_plans_tl dntl
  where dnb.dunning_plan_id = dntl.dunning_plan_id
  and dntl.language = userenv('LANG')
  and dnb.dunning_type = 'STAGED_DUNNING'
  and dnb.mig_dunning_letter_set_id is not null
  and dnb.enabled_flag = 'Y'
  and dnb.end_date is null
  order by dnb.dunning_plan_id;

  cursor c_dunning_letter_set_lines (p_dunn_letter_set_id number) is
  select dunning_letter_set_id,
	 dunning_line_num,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date,
	 dunning_letter_id,
	 include_current,
	 invoice_copies,
	 range_of_dunning_level_from,
	 range_of_dunning_level_to,
	 min_days_between_dunning
  from AR_DUNNING_LETTER_SET_LINES
  where dunning_letter_set_id = p_dunn_letter_set_id;

  cursor c_template_id is
  select template_id
  from xdo_templates_vl
  where template_code = 'IEXSTGDN';

  cursor c_staged_dunning_level is
  select ar.staged_dunning_level,
         ar.payment_schedule_id
  from iex_delinquencies_all iex,
       ar_payment_schedules_all ar
  where iex.payment_schedule_id = ar.payment_schedule_id
  and ar.staged_dunning_level is not null
  and iex.staged_dunning_level is null
  and iex.status in ('DELINQUENT','PREDELINQUENT')
  and ar.status = 'OP';

  cursor c_business_level is
  select business_level
  from iex_questionnaire_items
  where questionnaire_item_id = 1;

BEGIN

   l_api_name := 'STG_DUNNING_MIG_CONCUR';
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - start');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'SEND_DUNNING_CONCUR p_migration_mode = ' || p_migration_mode);
   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' p_migration_mode		: ' || p_migration_mode);
   l_migration_mode	:= nvl(p_migration_mode,'FINAL');

   l_migrated_data	:= nvl(fnd_profile.value('AR_DUNNING_TO_IEXDUNNING_MIGRATED'), 'Y');

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'SEND_DUNNING_CONCUR l_migrated_data = ' || l_migrated_data);

   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_migrated_data		: ' || l_migrated_data);

   open c_business_level;
   fetch c_business_level into l_business_level;
   close c_business_level;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'SEND_DUNNING_CONCUR l_business_level = ' || l_business_level);

   WriteLog(G_PKG_NAME || ' ' || l_api_name || ' l_business_level		: ' || l_business_level);

   if l_business_level = 'CUSTOMER' then
	l_score_id	:= 1;
   elsif l_business_level = 'ACCOUNT' then
	l_score_id	:= 6;
   elsif l_business_level = 'BILL_TO' then
	l_score_id	:= 7;
   elsif l_business_level = 'DELINQUENCY' then
	l_score_id	:= 2;
   end if;

   retcode := FND_API.G_RET_STS_SUCCESS;

   open c_template_id;
   fetch c_template_id into l_template_id;
   close c_template_id;

	if l_migration_mode = 'FINAL' then
		WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - CP submitted in FINAL mode. So records will be migrated.');
		if l_migrated_data = 'N' then

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile ''IEX: AR Dunning to IEX Dunning Migrated?'' value is No. So data will get migrated.                                               *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');

			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - End dating the previously migrated dunning letter sets.');
			UPDATE IEX_DUNNING_PLANS_B
			SET LAST_UPDATE_DATE = sysdate,
			LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
			LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID,
			END_DATE = nvl(END_DATE,sysdate),
			ENABLED_FLAG = 'N'
			WHERE MIG_DUNNING_LETTER_SET_ID is not null
			AND (ENABLED_FLAG = 'Y' OR END_DATE IS NULL);

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '1. End dated the previously migrated dunning letter sets.');

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '2. Following Dunning letter sets are migrated as Dunning plans from AR to Advanced Collections');
			begin
			for dunn_letter_set_rec in c_dunning_letter_sets
			loop
				l_rec_exists	:= 'Y'; --at least one record exists
				l_dunning_letter_set_id	:= dunn_letter_set_rec.dunning_letter_set_id;
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_letter_set_id= ' || l_dunning_letter_set_id);
				--Start bug 9725204 gnramasa 19th May 10
				--l_dunning_plan_id	:= IEX_DUNNING_PLANS_S.nextval;
					select IEX_DUNNING_PLANS_S.nextval
					into l_dunning_plan_id
					from dual;
				--End bug 9725204 gnramasa 19th May 10
				l_include_current	:= 'N';
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_dunning_plan_id= ' || l_dunning_plan_id);

				INSERT INTO IEX_DUNNING_PLANS_B
					(DUNNING_PLAN_ID,
					START_DATE,
					ENABLED_FLAG,
					AGING_BUCKET_ID,
					SCORE_ID,
					DUNNING_LEVEL,
					OBJECT_VERSION_NUMBER,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					DUNNING_TYPE,
					DUN_DISPUTED_ITEMS,
					GRACE_DAYS,
					INCLUDE_UNUSED_PAYMENTS_FLAG,
					DUNNING_LETTER_SET_ID,
					MIG_DUNNING_LETTER_SET_ID)
				VALUES
					(l_dunning_plan_id,
					sysdate,
					decode(dunn_letter_set_rec.status,'A','Y','N'),
					null,
					l_score_id,
					l_business_level,
					1,
					dunn_letter_set_rec.creation_date,
					dunn_letter_set_rec.created_by,
					dunn_letter_set_rec.last_update_date,
					dunn_letter_set_rec.last_updated_by,
					dunn_letter_set_rec.last_update_login,
					dunn_letter_set_rec.dunning_type,
					dunn_letter_set_rec.dun_disputed_items,
					dunn_letter_set_rec.grace_days,
					dunn_letter_set_rec.include_unused_payments_flag,
					dunn_letter_set_rec.dunning_letter_set_id,
					dunn_letter_set_rec.dunning_letter_set_id);

				INSERT INTO IEX_DUNNING_PLANS_TL
					(DUNNING_PLAN_ID,
					NAME,
					DESCRIPTION,
					LANGUAGE,
					SOURCE_LANG,
					CREATED_BY,
					CREATION_DATE,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN)
				VALUES
					(l_dunning_plan_id,
					dunn_letter_set_rec.name,
					dunn_letter_set_rec.description,
					'US',
					'US',
					dunn_letter_set_rec.created_by,
					dunn_letter_set_rec.creation_date,
					dunn_letter_set_rec.last_update_date,
					dunn_letter_set_rec.last_updated_by,
					dunn_letter_set_rec.last_update_login);

				l_output_string	:= '	Dunning_plan_id : ' || rpad(l_dunning_plan_id, 20, ' ') || '  Name: ' || rpad(dunn_letter_set_rec.name, 30, ' ') || '  Description: ' || rpad(dunn_letter_set_rec.description, 50, ' ');
				FND_FILE.PUT_LINE(FND_FILE.LOG, l_output_string);

				for dunn_letter_set_lines_rec in c_dunning_letter_set_lines (l_dunning_letter_set_id)
				loop
					 --Start bug 9725204 gnramasa 19th May 10
					 --l_ag_dn_xref_id	:= IEX_AG_DN_XREF_S.nextval;
						select IEX_AG_DN_XREF_S.nextval
						into l_ag_dn_xref_id
						from dual;
					 --End bug 9725204 gnramasa 19th May 10
					 WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - l_ag_dn_xref_id= ' || l_ag_dn_xref_id);

					 INSERT INTO IEX_AG_DN_XREF
						(AG_DN_XREF_ID,
						LAST_UPDATE_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						CREATED_BY,
						CREATION_DATE,
						OBJECT_VERSION_NUMBER,
						CALLBACK_FLAG,
						CALLBACK_DAYS,
						FM_METHOD,
						SCORE_RANGE_LOW,
						SCORE_RANGE_HIGH,
						TEMPLATE_ID,
						DUNNING_LEVEL,
						XDO_TEMPLATE_ID,
						DUNNING_PLAN_ID,
						INVOICE_COPIES,
						MIN_DAYS_BETWEEN_DUNNING,
						RANGE_OF_DUNNING_LEVEL_FROM,
						RANGE_OF_DUNNING_LEVEL_TO)
					VALUES
						(l_ag_dn_xref_id,
						dunn_letter_set_lines_rec.last_update_date,
						dunn_letter_set_lines_rec.last_updated_by,
						dunn_letter_set_lines_rec.last_update_login,
						dunn_letter_set_lines_rec.created_by,
						dunn_letter_set_lines_rec.creation_date,
						1,
						'N',
						null,
						'PRINTER',
						1,
						100,
						l_template_id,
						l_business_level,
						l_template_id,
						l_dunning_plan_id,
						dunn_letter_set_lines_rec.invoice_copies,
						dunn_letter_set_lines_rec.min_days_between_dunning,
						dunn_letter_set_lines_rec.range_of_dunning_level_from,
						dunn_letter_set_lines_rec.range_of_dunning_level_to);

					if (dunn_letter_set_lines_rec.include_current = 'Y' and l_include_current <> 'Y') then
						l_include_current	:= 'Y';
					end if;
				end loop;

				 UPDATE IEX_DUNNING_PLANS_B
				 SET INCLUDE_CURRENT = l_include_current
				 WHERE
				 DUNNING_PLAN_ID = l_dunning_plan_id;

			end loop;

			exception
			WHEN OTHERS THEN
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||SQLERRM);
				FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
			end ;
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

			l_staged_dunning_level.delete;
			l_payment_schedule_id.delete;
			--Copy the Staged level of an Invoice from AR_PAYMENT_SCHEDULES_ALL table to IEX_DELINQUENCIES_ALL table.
			--It will update only the records that have staged_dunning_level as NULL
			BEGIN
			OPEN c_staged_dunning_level;
			 LOOP
			  FETCH c_staged_dunning_level BULK COLLECT INTO
			    l_staged_dunning_level,
			    l_payment_schedule_id
			    LIMIT G_BATCH_SIZE;
			  IF l_staged_dunning_level.count =  0 THEN

			       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - No of rows updated in iex_delinquencies_all is: ' || l_no_updated_rows);
			       WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Exit after Updating iex_delinquencies_all staged_dunning_level...');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '3. Copied Transaction''s stage level from AR to Advanced Collections. No of rows updated in iex_delinquencies_all table is: ' || l_no_updated_rows);
			       FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '  Used the following SQL to copy the Transaction''s stage level from AR to Advanced Collections.');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '  UPDATE IEX_DELINQUENCIES_ALL IEX ');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '   SET STAGED_DUNNING_LEVEL = l_staged_dunning_level (I) ');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '   WHERE PAYMENT_SCHEDULE_ID = l_payment_schedule_id(I); ');
			       FND_FILE.PUT_LINE(FND_FILE.LOG, '  ');

			    CLOSE c_staged_dunning_level;
			    EXIT;
			  ELSE
			   FORALL I IN l_staged_dunning_level.first..l_staged_dunning_level.last
			    UPDATE IEX_DELINQUENCIES_ALL IEX
			    SET STAGED_DUNNING_LEVEL = l_staged_dunning_level (I)
			    WHERE PAYMENT_SCHEDULE_ID = l_payment_schedule_id(I);

			    l_no_updated_rows	:= l_no_updated_rows + l_staged_dunning_level.count;

			    l_staged_dunning_level.delete;
			    l_payment_schedule_id.delete;

			    commit;

			    WriteLog(G_PKG_NAME || ' ' || l_api_name || ' Rows updated in iex_delinquencies_all staged_dunning_level...');
			    FND_FILE.PUT_LINE(FND_FILE.LOG, '3. Copied Transactions stage level from AR to Advanced Collections');
			    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

			   END IF;
			 END LOOP;
			EXCEPTION
			WHEN OTHERS THEN
			  WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||SQLERRM);
			  FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
			END;

			--Update dunning_type as 'DAYS_OVERDUE' for existing records in IEX_DUNNING_PLANS_B table.
			update iex_dunning_plans_b
			set dunning_type = 'DAYS_OVERDUE'
			where dunning_type is null
			and aging_bucket_id is not null;
			WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Updated dunning_type as DAYS_OVERDUE for existing records in IEX_DUNNING_PLANS_B table.');

			--Set the Profile 'IEX: IPP Printer Name' as 'NOPRINT'.
			l_return := fnd_profile.save(x_name => 'IEX_PRT_IPP_PRINTER_NAME',
				      x_value => 'NOPRINT',
				      x_level_name => 'SITE',
				      x_level_value => null,
				      x_level_value_app_id => '',
				      x_level_value2 => null);
			if l_return then
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Profile IEX: IPP Printer Name value updated with NOPRINT ');
			else
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Profile IEX: IPP Printer Name updated failed ');
			end if;

			--Set the Profile IEX: AR Dunning to IEX Dunning Migrated? as 'Y' i.e Yes.
			l_return := fnd_profile.save(x_name => 'AR_DUNNING_TO_IEXDUNNING_MIGRATED',
				      x_value => 'Y',
				      x_level_name => 'SITE',
				      x_level_value => null,
				      x_level_value_app_id => '',
				      x_level_value2 => null);
			if l_return then
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Profile IEX: AR Dunning to IEX Dunning Migrated? value updated with Y ');
				FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
				FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Dunning letter sets are migrated successfully and assigned Profile ''IEX: AR Dunning to IEX Dunning Migrated?'' with value Yes.            *');
				FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
				FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			else
				WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - Profile IEX: AR Dunning to IEX Dunning Migrated? updated failed ');
			end if;

		else
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile ''IEX: AR Dunning to IEX Dunning Migrated?'' value is Yes. So data will not get migrated.                                          *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '1. Following Dunning letter sets are already migrated as Dunning plans from AR to Advanced Collections');

			for v_c_migrated_dunn_letter_sets in c_migrated_dunn_letter_sets
			loop
				l_rec_exists	:= 'Y'; --at least one record exists
				l_output_string	:= '	Dunning_plan_id : ' || rpad(v_c_migrated_dunn_letter_sets.dunning_plan_id, 12, ' ')|| '  Business level: ' || rpad(v_c_migrated_dunn_letter_sets.dunning_level, 11, ' ');
				l_output_string := l_output_string || '  Name: ' || rpad(v_c_migrated_dunn_letter_sets.name, 30, ' ') || '  Description: ' || rpad(v_c_migrated_dunn_letter_sets.description, 50, ' ') ;
				l_output_string := l_output_string || '  Dunning_letter_set_id: ' || rpad(v_c_migrated_dunn_letter_sets.mig_dunning_letter_set_id, 20, ' ');
				FND_FILE.PUT_LINE(FND_FILE.LOG, l_output_string);
			end loop;

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile IEX: AR Dunning to IEX Dunning Migrated? value is Yes. So data will not get migrated.                                            *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Set Profile value as No at Site level and run the concurrent program again to re-migrate the dunning letter sets.                        *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
		end if;
	else  --DRAFT mode
		if l_migrated_data = 'N' then
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile ''IEX: AR Dunning to IEX Dunning Migrated?'' value is No.                                                                          *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Concurrent program has been submitted in DRAFT mode. So data will not get migrated.                                                      *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Following dunning letter sets will get migrated by running the concurrent program in FINAL mode.                                         *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			--FND_FILE.PUT_LINE(FND_FILE.LOG, '1. Following Dunning letter sets will be picked for data migration.');

			for v_c_dunning_letter_sets in c_dunning_letter_sets
			loop
				l_rec_exists	:= 'Y'; --at least one record exists
				l_output_string	:= '      Dunning_letter_set_id: ' || rpad(v_c_dunning_letter_sets.dunning_letter_set_id, 12, ' ') || '  Name: ' || rpad(v_c_dunning_letter_sets.name, 30, ' ') ;
				l_output_string	:= l_output_string || '  Description: ' || rpad(v_c_dunning_letter_sets.description, 50, ' ');
				FND_FILE.PUT_LINE(FND_FILE.LOG, l_output_string);
			end loop;
		else
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile ''IEX: AR Dunning to IEX Dunning Migrated?'' value is Yes.                                                                         *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '1. Following Dunning letter sets are already migrated as Dunning plans from AR to Advanced Collections');

			for v_c_migrated_dunn_letter_sets in c_migrated_dunn_letter_sets
			loop
				l_rec_exists	:= 'Y'; --at least one record exists
				l_output_string	:= '	Dunning_plan_id : ' || rpad(v_c_migrated_dunn_letter_sets.dunning_plan_id, 12, ' ')|| '  Business level: ' || rpad(v_c_migrated_dunn_letter_sets.dunning_level, 11, ' ') || '  Name: ';
				l_output_string	:= l_output_string || rpad(v_c_migrated_dunn_letter_sets.name, 30, ' ') || '  Description: ' || rpad(v_c_migrated_dunn_letter_sets.description, 50, ' ') || '  Dunning_letter_set_id: ' ;
				l_output_string	:= l_output_string || rpad(v_c_migrated_dunn_letter_sets.mig_dunning_letter_set_id, 20, ' ');
				FND_FILE.PUT_LINE(FND_FILE.LOG, l_output_string);
			end loop;

			FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Concurrent program has been submitted in DRAFT mode.                                                                                     *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Profile IEX: AR Dunning to IEX Dunning Migrated? value is Yes. So data will not get migrated.                                            *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*  Set Profile value as No at Site level and run the concurrent program again in DRAFT mode to see, what are the records will get migrated. *');
			FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
		end if;
	end if;  --if l_migration_mode = 'FINAL' then
	if l_rec_exists	= 'N' then
		FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
		FND_FILE.PUT_LINE(FND_FILE.LOG, '*  NO RECORDS FOUND     *');
		FND_FILE.PUT_LINE(FND_FILE.LOG, '*********************************************************************************************************************************************');
		FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
	end if;

	if l_migrated_data = 'Y' then
		l_con_update_re_st := fnd_concurrent.set_completion_status (status  => 'WARNING',
	                                      message => 'Set Profile IEX: AR Dunning to IEX Dunning Migrated? value to No and then run the cp.');
	end if;

  EXCEPTION
     WHEN OTHERS THEN
          retcode := '2'; --FND_API.G_RET_STS_UNEXP_ERROR;
          WriteLog(G_PKG_NAME || ' ' || l_api_name || ' - errbuf='||SQLERRM);
          FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);

END STG_DUNNING_MIG_CONCUR;
--End for bug 9582646 gnramasa 5th May 10

--clchang 10/28/04 added to fix the gscc warning
BEGIN

  PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


END IEX_DUNNING_PUB;

/
