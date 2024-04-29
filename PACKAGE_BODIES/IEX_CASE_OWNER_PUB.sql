--------------------------------------------------------
--  DDL for Package Body IEX_CASE_OWNER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_OWNER_PUB" AS
/* $Header: iexpcalb.pls 120.4.12000000.1 2007/01/17 23:20:23 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_CASE_OWNER_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpcalb.pls';

/* this will be the outside wrapper for the concurrent program to call the "creation" in batch
 */
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

PROCEDURE IEX_CASE_OWNER_CONCUR(ERRBUF      OUT NOCOPY     VARCHAR2,
                                RETCODE     OUT NOCOPY     VARCHAR2,
                                p_list_name IN VARCHAR2)

IS

    l_api_version   NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_list_name     VARCHAR2(50) := p_list_name;

BEGIN

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.LogMessage ('Starting IEX_CASE_OWNER_CONCUR');
    END IF;

    IF p_list_name IS NULL THEN

--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.LogMessage ('IEX_CASE_OWNER_CONCUR: ' || 'p_list_name is null and calling RUN_LOAD_BALANCE');
    END IF;

        IEX_CASE_OWNER_PUB.Run_Load_Balance(p_api_version   => 1.0,
                             p_commit        => FND_API.G_TRUE,
                             p_init_msg_list => FND_API.G_FALSE,
                             x_return_status => l_return_status,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data);
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.LogMessage ('IEX_CASE_OWNER_CONCUR: ' || 'after RUN_LOAD_BALANCE:return_status=' || l_return_status);
    END IF;

    END IF;

    RETCODE := l_return_status;

END IEX_CASE_OWNER_CONCUR;

/* this procedure will run load balance on table iex_cases_all_b
 */
PROCEDURE Run_Load_Balance(p_api_version   IN  NUMBER,
                           p_commit        IN VARCHAR2,
                           p_init_msg_list IN  VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2)
IS
  l_api_name                    VARCHAR2(50)  := 'Run_Load_Balance';
  l_RETURN_STATUS               VARCHAR2(30) ;
  l_MSG_COUNT                   NUMBER      ;
  l_MSG_DATA                    VARCHAR2(100) ;
  l_api_version                 NUMBER := 1.0;

  l_login  number:= fnd_global.login_id;
  l_user   NUMBER := FND_GLOBAL.USER_ID;

  CURSOR c_parties IS
    SELECT DISTINCT party_id
	FROM iex_cases_all_b;

  --Begin bug#5246309 schekuri 29-Jun-2006
  --Changed the query to get the resource from hz_customer_profiles
  CURSOR c_party_resource(p_party_id NUMBER) IS
	SELECT ac.resource_id,0
	FROM  hz_customer_profiles hp, jtf_rs_resource_extns rs,ar_collectors ac
	WHERE hp.party_id = p_party_id
	and rs.resource_id = ac.resource_id
	and hp.collector_id = ac.collector_id
	and hp.cust_account_id=-1
	and hp.site_use_id is null
	and trunc(nvl(rs.end_date_active,sysdate)) >= trunc(sysdate)
	and rs.user_id is not null
	and ac.employee_id is not null
	and trunc(nvl(ac.inactive_date,sysdate)) >= trunc(sysdate)
	and nvl(ac.status,'A') = 'A'
	and nvl(hp.status,'A') = 'A'
	group by ac.resource_id;

  /*CURSOR c_party_resource(p_party_id NUMBER) IS
	SELECT DISTINCT rs.resource_id, 0
	FROM as_rpt_managers_v m, as_accesses acc, jtf_rs_resource_extns rs
	WHERE m.person_id = acc.person_id
	AND m.manager_person_id = rs.source_id
	AND acc.customer_id = p_party_id
        AND rs.start_date_active <= sysdate
        AND rs.end_date_active > sysdate;*/

   --End bug#5246309 schekuri 29-Jun-2006

  CURSOR c_party_case_count(p_party_id NUMBER) IS
    SELECT count(1)
	FROM iex_cases_all_b
	WHERE party_id = p_party_id;

  CURSOR c_party_case_id(p_party_id NUMBER) IS
    SELECT cas_id
	FROM iex_cases_all_b
	WHERE party_id = p_party_id;

  TYPE number_tab_type IS TABLE OF NUMBER;
  l_p_rs_id_tab number_tab_type;
  l_p_rs_cnt_tab number_tab_type;
  l_p_case_id_tab number_tab_type;
  l_p_case_cnt NUMBER;

  l_idx NUMBER := 0;
  l_avg_cnt NUMBER := 0;

  l_errmsg varchar2(1000);
  l_count number;
BEGIN

--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage ('starting RUN_LOAD_BALANCE');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Run_Load_Balance_PVT;


  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME)
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize API return status to SUCCESS
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Api body
  --

  FOR r_party IN c_parties LOOP
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'in C_PARTIES LOOP:party_id=' || r_party.party_id);
    END IF;


    OPEN c_party_resource(r_party.party_id);
	FETCH c_party_resource BULK COLLECT INTO l_p_rs_id_tab, l_p_rs_cnt_tab;

    l_count := l_p_rs_id_tab.count;
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after fetch:c_party_resource:count=' || l_count);
    END IF;

	CLOSE c_party_resource;
    IF l_p_rs_id_tab.count > 0 THEN
  	  OPEN c_party_case_count(r_party.party_id);
  	  FETCH c_party_case_count INTO l_p_case_cnt;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after fetch of c_party_case_count:count=' || l_p_case_cnt);
      END IF;

  	  CLOSE c_party_case_count;

      OPEN c_party_case_id(r_party.party_id);

  	  l_avg_cnt := trunc(l_p_case_cnt / l_p_rs_id_tab.count);
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'average count=' || l_avg_cnt);
      END IF;


  	  l_idx := 1;
  	  FETCH c_party_case_id BULK COLLECT INTO l_p_case_id_tab;
	  CLOSE c_party_case_id;

      l_count := l_p_case_id_tab.count;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after fetch c_party_case_id:count=' || l_count);
      END IF;

  	  IF l_p_case_id_tab.count > 0 THEN
--        IF PG_DEBUG < 10  THEN
        IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
           iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'c_party_case_id found');
        END IF;

        FOR i in 1..l_p_case_cnt LOOP
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'before update:index_of_resource=' || l_idx || ':resource=' || l_p_rs_id_tab(l_idx)
		      || ':assigned_count=' || l_p_rs_cnt_tab(l_idx)
		      || ':case_id=' || l_p_case_id_tab(i));
          END IF;

  	      UPDATE iex_cases_all_b
  	      SET owner_resource_id = l_p_rs_id_tab(l_idx)
  	      WHERE cas_id = l_p_case_id_tab(i);

  	      l_p_rs_cnt_tab(l_idx) := l_p_rs_cnt_tab(l_idx) + 1;

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after update:index_of_resource=' || l_idx || ':resource=' || l_p_rs_id_tab(l_idx)
		      || ':assigned_count=' || l_p_rs_cnt_tab(l_idx)
		      || ':case_id=' || l_p_case_id_tab(i));
          END IF;

  	      IF l_p_rs_cnt_tab(l_idx) >= l_avg_cnt THEN
  		    l_idx := l_idx + 1;
--			IF PG_DEBUG < 10  THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			   iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after increase index:idx=' || l_idx);
			END IF;
  	      END IF;

  	      IF l_idx > l_p_rs_cnt_tab.count THEN
  	        l_idx := 1;
  		    l_avg_cnt := l_avg_cnt + 1;
--			IF PG_DEBUG < 10  THEN
			IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
			   iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'after reset index:idx=' || l_idx || ':average_count=' || l_avg_cnt);
			END IF;
  	      END IF;

  	    END LOOP;  -- FOR i
  	  END IF;
	END IF;
  END LOOP; -- FOR r_party

  --
  -- End of API body.
  --

  -- Standard check for p_commit
  IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
  END IF;

  x_return_status := l_return_status ;
  x_msg_Count     := l_msg_count ;
  x_msg_data      := l_msg_data ;


--  IF PG_DEBUG < 10  THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     iex_debug_pub.LogMessage ('end of RUN_LOAD_BALANCE main block');
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
  (  p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
  );

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
          l_errmsg := SQLERRM;
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'EXCEPTION:FND_API.G_EXC_ERROR:' || l_errmsg);
          END IF;

          AS_UTILITY_PVT.HANDLE_EXCEPTIONS(P_API_NAME         => L_API_NAME
                                          ,P_PKG_NAME         => G_PKG_NAME
                                          ,P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR
                                          ,P_PACKAGE_TYPE     => AS_UTILITY_PVT.G_PVT
                                          ,X_MSG_COUNT        => X_MSG_COUNT
                                          ,X_MSG_DATA         => X_MSG_DATA
                                          ,X_RETURN_STATUS    => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         l_errmsg := SQLERRM;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'EXCEPTION:FND_API.G_EXC_UNEXPECTED_ERROR:' || l_errmsg);
         END IF;

         AS_UTILITY_PVT.HANDLE_EXCEPTIONS(P_API_NAME         => L_API_NAME
                                          ,P_PKG_NAME         => G_PKG_NAME
                                          ,P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                                          ,P_PACKAGE_TYPE     => AS_UTILITY_PVT.G_PVT
                                          ,X_MSG_COUNT        => X_MSG_COUNT
                                          ,X_MSG_DATA         => X_MSG_DATA
                                          ,X_RETURN_STATUS    => X_RETURN_STATUS);
      WHEN OTHERS THEN
         l_errmsg := SQLERRM;
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            iex_debug_pub.LogMessage('Run_Load_Balance: ' || 'EXCEPTION:OTHERS:' || l_errmsg);
         END IF;

         AS_UTILITY_PVT.HANDLE_EXCEPTIONS(P_API_NAME         => L_API_NAME
                                          ,P_PKG_NAME         => G_PKG_NAME
                                          ,P_EXCEPTION_LEVEL  => AS_UTILITY_PVT.G_EXC_OTHERS
                                          ,P_PACKAGE_TYPE     => AS_UTILITY_PVT.G_PVT
                                          ,X_MSG_COUNT        => X_MSG_COUNT
                                          ,X_MSG_DATA         => X_MSG_DATA
                                          ,X_RETURN_STATUS    => X_RETURN_STATUS);

END Run_Load_Balance;

END IEX_CASE_OWNER_PUB;

/
