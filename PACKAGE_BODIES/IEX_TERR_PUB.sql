--------------------------------------------------------
--  DDL for Package Body IEX_TERR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_TERR_PUB" AS
/* $Header: iexkterb.pls 120.5.12010000.5 2009/11/30 11:38:57 pnaveenk ship $ */


--
-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
-- Trace HZ: Turn On File Debug
---      HZ: API Debug File Directory
---      HZ: API Debug File Name
---
---   HZ_BUSINESS_EVENT_V2PVT check package of all events

FUNCTION isRefreshProgramsRunning RETURN BOOLEAN IS
CURSOR C1 IS
select request_id
from AR_CONC_PROCESS_REQUESTS
where CONCURRENT_PROGRAM_NAME in ('ARSUMREF','IEX_POPULATE_UWQ_SUM');
l_request_id  number;
BEGIN

OPEN C1;

  FETCH C1 INTO l_request_id;

  IF C1%NOTFOUND THEN
   return false;
  ELSE
   return true;
  END IF;

CLOSE C1;

END isRefreshProgramsRunning;

/** subscription function example
* oracle.apps.ar.hz.Party.create
**/

FUNCTION party_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2

is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_party_id          NUMBER;

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('party_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_party_id := p_event.GetValueForParameter('PARTY_ID');
logmessage ('party_check: ' || 'PARTY_ID =>'    || l_party_id);
--PG_DEBUG := 0;
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('party_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('party_check: ' || 'PARTY_ID =>'    || l_party_id);
END IF;

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage (' Start IEX Summarty Synchronization ');
END IF;

IF NOT isRefreshProgramsRunning THEN
      x_return_status := SYNC_TCA_SUMMARY(p_party_id =>l_party_id,p_level=>'PARTY');
      IF x_return_status <> 'S' THEN
	     RAISE EXC;
      END IF;
ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_TERR_PUB.party_check Skipped ' );
   END IF;
END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('exception exc party_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('party_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'party_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('exception others party_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'party_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END party_check;



/** subscription function example
* oracle.apps.ar.hz.PartySite.create
**/
FUNCTION partysite_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_partysite_id          NUMBER;

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('partysite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_partysite_id := p_event.GetValueForParameter('PARTY_SITE_ID');
logmessage ('partysite_check: ' || 'PARTY_SITE_ID =>'    || l_partysite_id);
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('partysite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('partysite_check: ' || 'PARTY_SITE_ID =>'    || l_partysite_id);
END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('exception exc partysite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('partysite_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'partysite_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('exception others partysite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'partysite_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END partysite_check;


/** subscription function example
* oracle.apps.ar.hz.PartySiteUse.create
**/
FUNCTION partysiteuse_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_partysiteuse_id          NUMBER;

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('partysiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_partysiteuse_id := p_event.GetValueForParameter('PARTY_SITE_USE_ID');
--PG_DEBUG := 0;

logmessage ('partysiteuse_check: ' || 'PARTY_SITE_USE_ID =>'    || l_partysiteuse_id);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('partysiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('partysiteuse_check: ' || 'PARTY_SITE_USE_ID =>'    || l_partysiteuse_id);
END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
      logmessage ('Exception exc partysiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('partysiteuse_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'partysiteuse_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('Exception Others partysiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'partysite_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END partysiteuse_check;


/** subscription function example
* oracle.apps.ar.hz.location.create
**/
FUNCTION location_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_location_id          NUMBER;

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('location_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_location_id := p_event.GetValueForParameter('LOCATION_ID');
--PG_DEBUG := 0;
logmessage ('location_check: ' || 'LOCATION_ID =>'    || l_location_id);

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('location_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('location_check: ' || 'PARTY_SITE_USE_ID =>'    || l_location_id);
END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
      logmessage ('Exception exc location_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('location_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'location_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('Exception Others location_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'location_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END location_check;

/** subscription function example
*   oracle.apps.ar.hz.CustAccount.create
**/
 FUNCTION account_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10);
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_custaccount_id          NUMBER;
l_profile_id              NUMBER;
l_prof_amt_id             VARCHAR2(100);
l_party_id				  NUMBER;
l_siteuse_id			  NUMBER;

 l_rowid                  ROWID;
 l_return_status          VARCHAR2(10);
 l_object_version_number  NUMBER;
 l_last_update_date       DATE;
 l_debug_level             NUMBER;
 l_debug                   VARCHAR2(1);

 x_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;
 l_trans_rec     JTY_ASSIGN_REALTIME_PUB.bulk_trans_id_type;
 l_count          NUMBER;
 l_rsc_name       VARCHAR2(240);
BEGIN
x_return_status := 'S';
l_debug_level := NVL(TO_NUMBER(FND_PROFILE.VALUE('IEX_DEBUG_LEVEL')),20);
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('Account Check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_custaccount_id  := p_event.GetValueForParameter('CUST_ACCOUNT_ID');
l_profile_id      := p_event.GetValueForParameter('CUST_ACCOUNT_PROFILE_ID');
l_prof_amt_id     := p_event.GetValueForParameter('P_CREATE_PROFILE_AMT');

BEGIN
 SELECT  party_id INTO l_party_id
 FROM hz_cust_accounts
 WHERE  cust_account_id = l_custaccount_id;
EXCEPTION WHEN OTHERS THEN
  logmessage('Error while selecting the Party_id' || SQLERRM);
END;

--PG_DEBUG := 0;
logmessage ('Account Check: ' || 'PARTY_ID =>'    || l_party_id);
logmessage ('Account Check: ' || 'CUST_ACCOUNT_ID =>'    || l_custAccount_id);
logmessage ('Account Check: ' || 'CUST_ACCOUNT_PROFILE_ID =>'    || l_profile_id);
logmessage ('Account Check: ' || 'P_CREATE_PROFILE_AMT =>'    ||l_prof_amt_id);


IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('account_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('account_check: ' || 'PARTY_ID  =>'    || l_party_id);
   iex_debug_pub.logmessage ('account_check: ' || 'CUST_ACCOUNT_ID =>'    || l_custaccount_id);
   iex_debug_pub.logmessage ('account_check: ' || 'CUST_ACCOUNT_PROFILE_ID =>'    || l_profile_id);
   iex_debug_pub.logmessage ('account_check: ' || 'P_CREATE_PROFILE_AMT =>'    ||l_prof_amt_id);
END IF;


   logmessage ('account_check: ' || ' custaccount_id = '|| l_custaccount_id  ||
            ', l_siteuse_id = ' || l_siteuse_id || ', party_id ' || l_party_id);


  IF NVL(FND_PROFILE.VALUE('IEX_ENABLE_CUST_ONLINE_TAP'),'N') <> 'Y' THEN
    BEGIN
      INSERT INTO IEX_CHANGED_ACCOUNTS_ALL
      (
      OBJECT_VERSION_NUMBER
      ,PARTY_ID
      ,ACCOUNT_ID
      ,SITE_USE_ID
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,CREATION_DATE
      ,CREATED_BY
      ,LAST_UPDATE_LOGIN
      ,CHANGE_TYPE
      ,PROCESSED_FLAG
      )
      VALUES
      (
      1
      ,l_party_id
      ,l_custaccount_id
      ,null
      ,sysdate
      ,FND_GLOBAL.user_id
      ,sysdate
      ,FND_GLOBAL.user_id
      ,FND_GLOBAL.login_id
      ,'ACCOUNT'
      ,'N'
      );
     -- COMMIT;  -- Commented for bug#7678917 by PNAVEENK on 5-1-2009
     EXCEPTION WHEN OTHERS THEN
       logmessage('Error while creating in IEX_CHANGED_ACCOUNTS_ALL') ;
     END;

   ELSE
   logmessage ('Account Check: ' ||  ' Calling Territory,  l_party_id = ' || l_party_id);
   IF (l_debug_level <=10) THEN
     l_debug := 'Y';
   ELSE
     l_debug := 'N';
   END IF;
   BEGIN
    l_trans_rec.trans_object_id1 := jtf_terr_number_list(l_party_id);
    l_trans_rec.trans_object_id2 := jtf_terr_number_list(l_custaccount_id);
    l_trans_rec.trans_object_id3 := jtf_terr_number_list(null);
    l_trans_rec.trans_object_id4 := jtf_terr_number_list(null);
    l_trans_rec.trans_object_id5 := jtf_terr_number_list(null);
    l_trans_rec.txn_date := jtf_terr_date_list(null);

    JTY_ASSIGN_REALTIME_PUB.get_winners(
     p_api_version_number       => 1.0,
     p_init_msg_list            => FND_API.G_FALSE,
     p_source_id                => -1600,
     p_trans_id                 => -1601,
     p_mode                     => 'REAL TIME:RESOURCE',
     p_param_passing_mechanism  => 'PBR',
     p_program_name             => 'COLLECTIONS/CUSTOMER PROGRAM',
     p_trans_rec                => l_trans_rec,
     p_name_value_pair          => null,
     p_role                     => null,
     p_resource_type            => null,
     x_return_status            => x_return_status,
     x_msg_count                => x_msg_count,
     x_msg_data                 => x_msg_data,
     x_winners_rec              => x_winners_rec
     );
     logmessage('Get Winners Returned with  Status : ' || x_return_status);
     EXCEPTION WHEN OTHERS THEN
       logmessage('Error while updating the profile ' || SQLERRM);
     END;
     BEGIN
      l_count := x_winners_rec.terr_id.COUNT;
      logmessage('Total Winners selected ' || l_count);
      IF (l_count > 0) THEN
      logmessage('Start updating the Customer Profiles Table' );

      FOR i IN x_winners_rec.terr_id.FIRST .. x_winners_rec.terr_id.LAST LOOP
       BEGIN
        UPDATE  HZ_CUSTOMER_PROFILES ACC
        SET object_version_number  =  nvl(object_version_number,0) + 1,
	    ACC.LAST_UPDATE_DATE       = SYSDATE,
 	    ACC.LAST_UPDATED_BY        = FND_GLOBAL.USER_ID,
	    ACC.LAST_UPDATE_LOGIN      = FND_GLOBAL.login_id ,
	    ACC.PROGRAM_APPLICATION_ID = FND_GLOBAL.PROG_APPL_ID,
	    ACC.PROGRAM_UPDATE_DATE    = SYSDATE,
            ACC.COLLECTOR_ID           = x_winners_rec.resource_id(i)
         WHERE  ACC.PARTY_ID           = x_winners_rec.trans_object_id(i)
      	 AND ACC.SITE_USE_ID           IS NULL
         AND ACC.CUST_ACCOUNT_ID       = l_custaccount_id
	 AND ACC.COLLECTOR_ID          <> x_winners_rec.resource_id(i);
        EXCEPTION WHEN OTHERS THEN
	  logmessage('Error occured while updating the customer profiles' || SQLERRM);
	END;
        BEGIN
         SELECT resource_name
	 INTO l_rsc_name
	 FROM jtf_rs_resource_extns_vl
	 WHERE resource_id = x_winners_rec.resource_id(i);
        EXCEPTION WHEN OTHERS THEN
	   NULL;
	 END;
         logmessage('Trans Object ID : ' || x_winners_rec.trans_object_id(i) ||
                             ' Trans Detail Object ID : ' || x_winners_rec.trans_detail_object_id(i) ||
                             ' Terr ID : ' || x_winners_rec.terr_id(i) || ' Terr Name : ' || x_winners_rec.terr_name(i) ||
                             ' Resource ID : ' || x_winners_rec.resource_id(i) || ' Resource Name : ' || l_rsc_name ||
                             ' Role ID : ' || x_winners_rec.role_id(i) || ' Resource Type : ' || x_winners_rec.resource_type(i) ||
                             ' Full Access Flag : ' || x_winners_rec.full_access_flag(i));
      END LOOP;
      ELSE
       logmessage('No Winners selected... No rows Updated');
      END IF;
     EXCEPTION WHEN OTHERS THEN
        logmessage('Error While updating the Customer Profiles Table' || SQLERRM);
     END;

   END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;

IF NOT isRefreshProgramsRunning THEN
    x_return_status := SYNC_TCA_SUMMARY(p_account_id => l_custaccount_id,p_level=>'ACCOUNT');

     IF x_return_status <> 'S' THEN
       RAISE EXC;
     END IF;
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_TERR_PUB.account_check Skipped ' );
   END IF;
  END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('Exception exc account_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('account_check: ' || 'raised exe error');
     END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'account_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('Exception Others account_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'account_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END account_check;

/** subscription function example
*
**/
 FUNCTION profile_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10):='S';
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

 l_profile_id             NUMBER;
 l_prof_amt               VARCHAR2(100);

 l_party_id               NUMBER;
 l_siteuse_id             NUMBER;
 l_custaccount_id            NUMBER;
 l_partysite_id           NUMBER;
 l_collector_id           NUMBER;
begin
l_profile_id      := p_event.GetValueForParameter('CUST_ACCOUNT_PROFILE_ID');

IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('profile_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('profile_check: ' || 'CUST_ACCOUNT_PROFILE_ID =>'    || l_profile_id);
END IF;

BEGIN
   IF NOT isRefreshProgramsRunning THEN

     SELECT cust_account_id, site_use_id, party_id,collector_id
     into l_custaccount_id, l_siteuse_id, l_party_id ,l_collector_id
	   from hz_customer_profiles  where  CUST_ACCOUNT_PROFILE_id = l_profile_id;


    x_return_status := SYNC_TCA_SUMMARY
        ( p_party_id     => l_party_id,
          p_account_id   => l_custaccount_id,
          p_site_use_id      => l_siteuse_id,
          p_collector_id => l_collector_id,
          p_level        => 'PROFILE');

     IF x_return_status <> 'S' THEN
       RAISE EXC;
     END IF;
  ELSE
  IF pg_debug <=10
    THEN
        iex_debug_pub.LogMessage('IEX_TERR_PUB.profile_check Skipped ' );
   END IF;
  END IF;


EXCEPTION
   WHEN others then
    iex_debug_pub.logmessage (' Error in profile_check: ' || 'P_CUST_ACCOUNT_PROFILE_ID =>'    ||l_profile_id);
    logmessage ('Exception occurred profile_check: ' || 'P_CUST_ACCOUNT_PROFILE_IDt  =>'|| l_profile_id);
END;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('exception in profile_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('profile_check: ' || 'raised exe error');
      END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'profile_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('exception others profile_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'profile_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END profile_check;

/** subscription function example
*   oracle.apps.ar.hz.CustProfileAmt.create
**/
FUNCTION profileamt_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_prof_amt             VARCHAR2(100);

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file
logmessage ('profileamt_check: ' || 'EVENT NAME  =>'||p_event.getEventName());

l_prof_amt := p_event.GetValueForParameter('CUST_ACCT_PROFILE_AMT_ID');
logmessage ('profileamt_check: ' || 'CUST_ACCT_PROFILE_AMT_ID  =>'|| l_prof_amt);

PG_DEBUG := 0;

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('profileamt_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('profileamt_check: ' || 'CUST_ACCT_PROFILE_AMT_ID  =>' || l_prof_amt);
END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;

RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('exception exc profileamt_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         iex_debug_pub.logmessage ('profileamt_check: ' || 'raised exe error');
     END IF;
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'profileamt_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('exception others profileamt_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_TERR_PUB', 'profileamt_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';


END profileamt_check;


/** subscription function example
*   for CustAcctSite.create
**/
 FUNCTION accountsite_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_acct_site_id            NUMBER;

begin
x_return_status := 'S';
-- this is just an example
-- writes into the log file
logmessage ('acctsite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_acct_site_id     := p_event.GetValueForParameter('CUST_ACCT_SITE_ID');
logmessage ('acctsite_check: ' || 'ACCOUNT_SITE_ID =>'    || l_acct_site_id);

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('acctsite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('acctsite_check: ' || 'ACCOUNT_SITE_ID =>'    || l_acct_site_id );
END IF;

IF x_return_status <> 'S' THEN
     RAISE EXC;
END IF;
RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
     logmessage ('Exception exc acctsite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
--    IF PG_DEBUG < 10  THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('acctsite_check: ' || 'raised exe error');
    END IF;
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'acctsite_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('Exception others acctsite_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'acctsite_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END accountsite_check;


/** subscription function example
*   for oracle.apps.ar.hz.CustAcctSiteUse.create
**/
 FUNCTION accountsiteuse_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10);
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

	l_acctsiteuse_id          NUMBER;
	l_profile_id              NUMBER;
	l_profile                 VARCHAR2(100);
	l_profile_amt             VARCHAR2(100);
	l_party_id                NUMBER;
	l_party_site_id			  NUMBER;
	l_cust_account_id         NUMBER;
        l_debug_level             NUMBER;
        l_debug                   VARCHAR2(1);

 l_rowid                  ROWID;
 l_return_status          VARCHAR2(10);
 l_object_version_number  NUMBER;
 l_last_update_date       DATE;
 l_msg_count              NUMBER;
 l_msg_data               VARCHAR2(200);



begin
x_return_status := 'S';
l_debug_level := NVL(TO_NUMBER(FND_PROFILE.VALUE('IEX_DEBUG_LEVEL')),20);
-- put custom code
-- this is just an example
-- writes into the log file

--        l_param.SetName( 'SITE_USE_ID' );
--        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );

--        l_param.SetName( 'P_CREATE_PROFILE' );
---        l_param.SetName( 'P_CREATE_PROFILE_AMT' );

	logmessage ('acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
	l_acctsiteuse_id := p_event.GetValueForParameter('SITE_USE_ID');
	l_profile_id     := p_event.GetValueForParameter('CUST_ACCOUNT_PROFILE_ID');
	l_profile        := p_event.GetValueForParameter('P_CREATE_PROFILE');
	l_profile_amt    := p_event.GetValueForParameter('P_CREATE_PROFILE_AMT');

	logmessage ('acctsiteuse_check: ' || 'SITE_USE_ID =>'    || l_acctsiteuse_id);
	logmessage ('acctsiteuse_check: ' || 'CUST_ACCOUNT_PROFILE_ID =>'    || l_profile_id);
	logmessage ('acctsiteuse_check: ' || 'P_CREATE_PROFILE =>' || l_profile);
	logmessage ('acctsiteuse_check: ' || 'P_CREATE_PROFILE_AMT =>' || l_profile_amt);


   logmessage ('acctsiteuse_check: ' || ' l_partysite_id = ' || l_party_site_id);

   /* Let us do site level, Territory Assignment */
   IF (l_debug_level <=10) THEN
     l_debug := 'Y';
   ELSE
     l_debug := 'N';
   END IF;
   --Bug4957592. Fix By LKKUMAR on 17-Jan-2006. Start.
   /*
   IEX_TERRITORY_ASSIGNMENT.ASSIGN_TERRITORY
   (p_api_version        => 1.0,
    p_calling_mode       => 'X',
    p_debug              => l_debug,
    p_filter_mode        => 'BILLTOSITE',
    p_selection_mode     => 'Specific',
    p_filter_id          => l_acctsiteuse_id,
    x_return_status      => l_return_status,
    x_msg_count          => l_msg_count,
    x_msg_data           => l_msg_data);
   */
   --Bug4957592. Fix By LKKUMAR on 17-Jan-2006. End.

   logmessage ('acctsiteuse_check: ' || ' x_return_status  => '|| l_return_status );
   logmessage ('acctsiteuse_check: ' || ' x_msg_count => ' || l_msg_count);
   logmessage ('acctsiteuse_check: ' || ' x_msg_data => ' || l_msg_data);

	--IF PG_DEBUG < 10  THEN
	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	   iex_debug_pub.logmessage ('acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
	   iex_debug_pub.logmessage ('acctsiteuse_check: ' || '_ID =>'    || l_acctsiteuse_id );
	END IF;

	IF x_return_status <> 'S' THEN
	     RAISE EXC;
	END IF;
	RETURN 'SUCCESS';

EXCEPTION
	WHEN EXC THEN
	    logmessage ('Exception exc acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
	--    IF PG_DEBUG < 10  THEN
	    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
	       iex_debug_pub.logmessage ('acctsiteuse_check: ' || 'raised exe error');
	    END IF;
	     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'acctsiteuse_check', p_event.getEventName(), p_subscription_guid);
	     WF_EVENT.setErrorInfo(p_event, 'ERROR');
	     RETURN 'ERROR';
	WHEN OTHERS THEN
	     logmessage ('Exception others acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
	     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'acctsiteuse_check', p_event.getEventName(), p_subscription_guid);
	     WF_EVENT.setErrorInfo(p_event, 'ERROR');
	     RETURN 'ERROR';

END accountsiteuse_check;

/** subscription function example
*   for oracle.apps.ar.hz.CustAcctSiteUse.create
**/
 FUNCTION finprofile_check
 ( p_subscription_guid      in raw,
   p_event                  in out NOCOPY wf_event_t)
 return varchar2
is
 l_key                    varchar2(240) := p_event.GetEventKey();
 x_return_status          VARCHAR2(10) ;
 x_msg_count              NUMBER;
 x_msg_data               VARCHAR2(2000);
 exc                      EXCEPTION;

l_finprofile_id              NUMBER;

begin
x_return_status := 'S';
-- put custom code
-- this is just an example
-- writes into the log file

--        l_param.SetName( 'SITE_USE_ID' );
--        l_param.SetName( 'CUST_ACCOUNT_PROFILE_ID' );

--        l_param.SetName( 'P_CREATE_PROFILE' );
---        l_param.SetName( 'P_CREATE_PROFILE_AMT' );

logmessage ('acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
l_finprofile_id     := p_event.GetValueForParameter('FINANCIAL_PROFILE_ID');
logmessage ('acctsiteuse_check: ' || 'FINANCIAL_PROFILE_ID =>'    || l_finprofile_id);

--IF PG_DEBUG < 10  THEN
IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
   iex_debug_pub.logmessage ('acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
   iex_debug_pub.logmessage ('acctsiteuse_check: ' || '_ID =>'    || l_finprofile_id );
END IF;

 IF x_return_status <> 'S' THEN
     RAISE EXC;
  END IF;
  RETURN 'SUCCESS';

EXCEPTION
 WHEN EXC THEN
    logmessage ('Exception exc acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       iex_debug_pub.logmessage ('finprofile_check: ' || 'raised exe error');
    END IF;
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'finprofile_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
 WHEN OTHERS THEN
     logmessage ('Exception others acctsiteuse_check: ' || 'EVENT NAME  =>'||p_event.getEventName());
     WF_CORE.CONTEXT('IEX_STRY_UTL_PUB', 'finprofile_check', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

END finprofile_check;

--IEX Summary Table Synchronization Start.
FUNCTION SYNC_TCA_SUMMARY(
 p_party_id     in number default null,
 p_account_id   in number default null,
 p_site_use_id      in number default null,
 p_collector_id in number default null,
 p_level        in varchar2)
     return varchar2 IS

l_sql    varchar2(3000);
l_where  varchar2(240);
Type refCur is Ref Cursor;
l_curs refCur;

l_party_name         hz_parties.party_name%type;
l_account_name       hz_cust_accounts.account_name%type;
l_address1           varchar2(240);
l_city               varchar2(240);
l_state	             varchar2(240);
l_county             varchar2(240);
l_country            varchar2(240);
l_province	     varchar2(240);
l_postal_code        varchar2(240);
l_phone_country_code varchar2(240);
l_phone_area_code    varchar2(240);
l_phone_number       varchar2(240);
l_phone_extension    varchar2(240);
l_party_id           number;

l_resource_id ar_collectors.resource_id%TYPE;
l_resource_type ar_collectors.resource_type%TYPE;
l_ieu_param_pk_col varchar2(20);   --Added for bug#6833110 by PNAVEENK on 29-Aug-2008


BEGIN
 IF p_level in ('PARTY','ACCOUNT') THEN
  l_sql := 'SELECT ' ||
         ' party.party_name party_name, ' ||
         ' acc.account_name account_name, ' ||
         ' party.address1 address1, ' ||
	 ' party.city city, ' ||
	 ' party.state state, ' ||
         ' party.county county, ' ||
	 ' fnd_terr.territory_short_name country, ' ||
	 ' party.province province, ' ||
	 ' party.postal_code postal_code, ' ||
 	 ' phone.phone_country_code phone_country_code, ' ||
	 ' phone.phone_area_code phone_area_code, ' ||
	 ' phone.phone_number phone_number, ' ||
	 ' phone.phone_extension phone_extension ' ||
	 ' FROM ' ||
	 ' hz_cust_accounts acc, ' ||
	 ' hz_parties party, ' ||
	 ' fnd_territories_tl fnd_terr, ' ||
	 ' hz_contact_points phone ' ||
	 ' WHERE ' ||
	 ' acc.party_id = party.party_id ' ||
	 ' AND phone.owner_table_id(+) = party.party_id ' ||
	 ' AND phone.owner_table_name(+) = ''HZ_PARTIES'' '  ||
	 ' AND phone.contact_point_type(+) = ''PHONE'' ' ||
	 ' AND phone.primary_by_purpose(+) = ''Y'' ' ||
	 ' AND phone.contact_point_purpose(+) = ''COLLECTIONS'' ' ||
	 ' AND phone.phone_line_type(+) NOT IN(''PAGER'',   ''FAX'') ' ||
	 ' AND phone.status(+) = ''A'' ' ||
	 ' AND nvl(phone.do_not_use_flag(+),   ''N'') = ''N'' ' ||
	 ' AND party.country = fnd_terr.territory_code(+) ' ||
	 ' AND fnd_terr.LANGUAGE(+) = userenv(''LANG'') ' ;

 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('Started TCA IEX Summarty Synchronization for  level ' || p_level);
 END IF;

 -- Bug #6251613 bibeura 11-Dec-2007 Used Bind Variables for Dynamic SQL to avoid performance problem
 IF (p_level = 'PARTY') THEN
   l_sql       := l_sql || ' AND party.party_id = :1 ';
   l_party_id  := p_party_id;
 ELSIF (p_level = 'ACCOUNT') THEN
   l_sql := l_sql || ' AND acc.cust_account_id = :1 ';  -- changed for bug 9106462 PNAVEENK

   BEGIN
    SELECT PARTY_ID INTO l_party_id from
    HZ_CUST_ACCOUNTS WHERE
    CUST_ACCOUNT_ID = p_party_id;
   EXCEPTION WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('IEX Summarty Synchronization , Error occurred in party_id select  ' || sqlerrm);
    END IF;
   END;

 END IF;
  IF (p_level = 'PARTY') THEN
	  OPEN l_curs FOR l_sql using p_party_id;
  ELSIF (p_level = 'ACCOUNT') THEN
	  OPEN l_curs FOR l_sql using p_account_id;
  END IF;

  LOOP
    FETCH l_curs INTO
    l_party_name,
    l_account_name,
    l_address1,
    l_city,
    l_state,
    l_county,
    l_country,
    l_province,
    l_postal_code,
    l_phone_country_code,
    l_phone_area_code,
    l_phone_number,
    l_phone_extension;
    EXIT;
   END LOOP;
   IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('IEX Summarty Synchronization , fetching values ' );
   END IF;

BEGIN
 UPDATE IEX_DLN_UWQ_SUMMARY SET
   party_name    =  l_party_name,
   account_name  =  l_account_name,
   address1      =  l_address1,
   city          =  l_city,
   state         =  l_state,
   county        =  l_county,
   country       =  l_country,
   province      =  l_province,
   postal_code   =  l_postal_code,
   phone_country_code =  l_phone_country_code,
   phone_area_code =  l_phone_area_code,
   phone_number =  l_phone_number,
   phone_extension =  l_phone_extension
   WHERE party_id = l_party_id;
  EXCEPTION WHEN OTHERS THEN
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('IEX Summarty Synchronization error occurred while updating ' || sqlerrm );
   END IF;
 END;

  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      iex_debug_pub.logmessage ('IEX Summary Synchronization , Completed Update. ' );
   END IF;

ELSE

  --Added for bug#6833110 by PNAVEENK on 29-Aug-2008
  -- start for bug 9034873 PNAVEENK
 /* IF p_level = 'PARTY' THEN
   l_ieu_param_pk_col := 'PARTY_ID';
  ELSIF p_level = 'ACCOUNT' THEN
   l_ieu_param_pk_col := 'CUST_ACCOUNT_ID';
  ELSIF p_level = 'BILL_TO' THEN
   l_ieu_param_pk_col := 'CUSTOMER_SITE_USE_ID';
  END IF; */
  --End for bug#6833110
  IF P_ACCOUNT_ID = -1 then
    l_ieu_param_pk_col := 'PARTY_ID';
  ELSIF P_SITE_USE_ID is null then
    l_ieu_param_pk_col := 'CUST_ACCOUNT_ID';
  ELSE
    l_ieu_param_pk_col := 'CUSTOMER_SITE_USE_ID';
  END IF;

  -- end for bug 9034873
  SELECT resource_id,resource_type
  INTO l_resource_id,l_resource_type
  FROM ar_collectors
  WHERE collector_id = p_collector_id;

 UPDATE IEX_DLN_UWQ_SUMMARY IDS
  SET   COLLECTOR_ID = P_COLLECTOR_ID,
        COLLECTOR_RESOURCE_ID = L_RESOURCE_ID ,
        COLLECTOR_RES_TYPE = L_RESOURCE_TYPE
  WHERE COLLECTOR_ID <> P_COLLECTOR_ID
    AND   IDS.PARTY_ID = P_PARTY_ID
    AND   NVL(IDS.CUST_ACCOUNT_ID,1) = NVL(P_ACCOUNT_ID,NVL(IDS.CUST_ACCOUNT_ID,1))
    AND   NVL(IDS.SITE_USE_ID,1)     = NVL(P_SITE_USE_ID,NVL(IDS.SITE_USE_ID,1))
    AND   IEU_PARAM_PK_COL = l_ieu_param_pk_col;    --Added for bug#6833110 by PNAVEENK on 29-Aug-2008

END IF;

--COMMIT;  -- Commented for bug#7678917 by PNAVEENK on 5-1-2009

RETURN 'S';

EXCEPTION WHEN OTHERS THEN
 IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    iex_debug_pub.logmessage ('IEX Summarty Synchronization error occurred' || sqlerrm );
 END IF;
 RETURN 'F';
END SYNC_TCA_SUMMARY;

--IEX Summary Table Synchronization End.

PROCEDURE logMessage (p_text in varchar2) IS
begin
    HZ_UTILITY_V2PUB.debug( 'IEX_TERR_PUB ' || p_text );
  --  insert into testMsg values(p_text, sysdate);
end;

BEGIN

  PG_DEBUG  := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
   -- Enter further code below as specified in the Package spec.
END;

/
