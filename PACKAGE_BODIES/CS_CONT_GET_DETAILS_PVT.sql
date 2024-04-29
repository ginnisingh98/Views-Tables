--------------------------------------------------------
--  DDL for Package Body CS_CONT_GET_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CONT_GET_DETAILS_PVT" AS
/* $Header: csvscgdb.pls 120.0.12010000.4 2010/04/14 06:22:41 bkanimoz ship $ */


/*********************************************************************

  API                 :   Get_contract_lines
  Version             :
  Type                :   Private
  Function            :   Get the service coverage level lines based on the
			  input values given by the user

  Parameters          :

  IN                  :
                           p_api_version            NUMBER    Required
                           p_init_msg_list          VARCHAR2  Required
                           P_CONTRACT_NUMBER        VARCHAR2
                           P_SERVICE_LINE_ID        NUMBER
                           P_CUSTOMER_ID            NUMBER
                           P_SITE_ID                NUMBER
                           P_CUSTOMER_ACCOUNT_ID    NUMBER
                           P_SYSTEM_ID              NUMBER
                           P_INVENTORY_ITEM_ID      NUMBER
                           P_CUSTOMER_PRODUCT_ID    NUMBER
			   P_REQUEST_DATE           DATE       	Required
			   P_BUSINESS_PROCESS_ID    IN         	NUMBER DEFAULT NULL,
			   P_SEVERITY_ID            IN      	NUMBER DEFAULT NULL,
			   P_TIME_ZONE_ID           IN      	NUMBER DEFAULT NULL,
			   P_CALC_RESPTIME_FLAG     IN      	VARCHAR2 DEFAULT NULL,
			   P_VALIDATE_FLAG          VARCHAR2   Required

  OUT                 :

                           X_ ENT_CONTRACTS OUT     TABLE OF RECORDS
                           x_return_status          VARCHAR2
                           x_msg_count              NUMBER
                           x_msg_data               VARCHAR2

*********************************************************************/


PROCEDURE GET_CONTRACT_LINES( P_API_VERSION            IN      NUMBER ,
                              P_INIT_MSG_LIST          IN      VARCHAR2,
                              P_CONTRACT_NUMBER        IN      OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE,
                              P_SERVICE_LINE_ID        IN      NUMBER,
                              P_CUSTOMER_ID            IN      NUMBER,
                              P_SITE_ID                IN      NUMBER,
                              P_CUSTOMER_ACCOUNT_ID    IN      NUMBER,
                              P_SYSTEM_ID              IN      NUMBER,
                              P_INVENTORY_ITEM_ID      IN      NUMBER,
                              P_CUSTOMER_PRODUCT_ID    IN      NUMBER,
			      P_REQUEST_DATE           IN      DATE,
			      P_BUSINESS_PROCESS_ID    IN      NUMBER DEFAULT NULL,
			      P_SEVERITY_ID            IN      NUMBER DEFAULT NULL,
			      P_TIME_ZONE_ID           IN      NUMBER DEFAULT NULL,
			      P_CALC_RESPTIME_FLAG     IN      VARCHAR2 DEFAULT NULL,
			      P_VALIDATE_FLAG          IN      VARCHAR2,
                              P_DATES_IN_INPUT_TZ      IN      VARCHAR2 DEFAULT 'N',
                              P_INCIDENT_DATE          IN      DATE DEFAULT NULL,
			      P_CUST_SITE_ID           IN      NUMBER DEFAULT NULL,--added for Access Hour project
			      P_CUST_LOC_ID	       IN      NUMBER DEFAULT NULL,--added for Access Hour project
                              X_ENT_CONTRACTS          OUT     NOCOPY ENT_CONTRACT_TAB,
                              X_RETURN_STATUS          OUT     NOCOPY VARCHAR2,
                              X_MSG_COUNT              OUT     NOCOPY NUMBER,
                              X_MSG_DATA               OUT     NOCOPY VARCHAR2)


IS

  l_return_status      varchar2(1);
  l_api_name           varchar2(30) := 'GET_CONTRACT_LINES';
  --l_inp_rec            OKS_ENTITLEMENTS_PUB.inp_cont_rec;
  l_inp_rec            OKS_ENTITLEMENTS_PUB.get_contin_rec;
  l_org_id             number;
  l_organization_id     number := NULL;
 BEGIN

   SAVEPOINT Get_contract_lines;

   -- Since the Entitlements API expects input parameters as a record
   -- copy all the input parameter values into a record before passing
   -- it to the API

   l_inp_rec.contract_number := p_contract_number;
   --l_inp_rec.coverage_level_line_id := p_coverage_level_line_id;
   l_inp_rec.service_line_id := p_service_line_id;
   l_inp_rec.party_id := p_customer_id;
   l_inp_rec.site_id := p_site_id;
   l_inp_rec.cust_acct_id := p_customer_account_id;
   l_inp_rec.system_id := p_system_id;
   l_inp_rec.item_id := p_inventory_item_id;
   l_inp_rec.product_id := p_customer_product_id;
   l_inp_rec.request_date := p_request_date;
   l_inp_rec.business_process_id := p_business_process_id;
   l_inp_rec.severity_id := p_severity_id;
   l_inp_rec.time_zone_id := p_time_zone_id;
   l_inp_rec.calc_resptime_flag := nvl(p_calc_resptime_flag,'N');
   l_inp_rec.validate_flag := p_validate_flag;
   l_inp_rec.dates_in_input_tz := p_dates_in_input_tz;
   l_inp_rec.incident_date := p_incident_date ;


   --Added for Access Hour project
   l_inp_rec.cust_site_id  := p_cust_site_id ;
   l_inp_rec.cust_loc_id   := p_cust_loc_id ;
   l_inp_rec.cust_id       := p_customer_id;


--Bug 7132754
/*
The value set in this profile option will be passed to the contracts API to
return the contract lines sorted based on Reaction Rime(RCN)/ Resolution Time(RSN)/
Importance Level(COVTYP_IMP).
Default value: Resolution time (to be backward compatible)
*/

   l_inp_rec.sort_key:= fnd_profile.value('CS_SR_CONTRACT_SORT_ORDER');
   if  l_inp_rec.sort_key is null then
      l_inp_rec.sort_key:= 'RSN';
   end if;

  -- Multi-org change. Get Org_id for Customer Product Id passed
  -- to the API if it is not null. Get Organization Id from
  -- the profile MO_OPERATING_UNIT
/*******************
This SQL is not needed as we are not setting Organization Context.The contracts
should be retrieved irrespective of the organization.

  if p_customer_product_id is not null then
    select org_id into l_org_id
	 from cs_customer_products_all
	 where customer_product_id = p_customer_product_id;
  else
    l_org_id := NULL;
  end if;

**************/
--  fnd_profile.get('MO_OPERATING_UNIT',l_organization_id);

  -- Set the Multi-org context before calling Entitlements API
-- commenting the org context as per instructions from contracts
-- 12 30 2000
   --okc_context.set_okc_org_context(l_org_id, l_organization_id);

  -- If the validate_flag is 'Y' then only the valid contracts as of
  -- 'request_date' is returned. If the validate_flag is 'N' then
  -- all the contract lines - valid and invalid- are returned.

   OKS_ENTITLEMENTS_PUB.GET_CONTRACTS( p_api_version => p_api_version,
			               p_init_msg_list => p_init_msg_list,
			               p_inp_rec => l_inp_rec,
	                               x_return_status => l_return_status,
			               x_msg_count => x_msg_count,
			               x_msg_data => x_msg_data,
			               x_ent_contracts => x_ent_contracts);

   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR ;
   ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;
   x_return_status := l_return_status;

 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO  Get_contract_lines;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO  Get_contract_lines;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN OTHERS THEN
     ROLLBACK TO  Get_contract_lines;
     x_return_status := FND_API.G_RET_STS_unexp_error ;
     IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
     END IF;
     fnd_msg_pub.count_and_get ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );


 END;

/*********************************************************************

  API                 :    Get_Reaction_time
  Version             :
  Type                :    Private
  Function            :    Get the time within which the Customer call should
                           be returned.

  Parameters          :

  IN                  :
                           p_api_version              NUMBER    Required
                           p_init_msg_list            VARCHAR2  Required
                           P_START_TZ_ID              NUMBER    Required
                           P_SR_SEVERITY              NUMBER    Required
                           P_BUSINESS_PROCESS_ID      NUMBER    Required
                           P_REQUEST_DATE             DATE      Required
                           P_SERVICE_LINE_ID   	      NUMBER    Required

  OUT                 :

                           X_ REACT_BY_DATE        DATE
                           x_return_status         VARCHAR2
                           x_msg_count             NUMBER
                           x_msg_data              VARCHAR2

*********************************************************************/


PROCEDURE GET_REACTION_TIME( P_API_VERSION             IN      NUMBER ,
                             P_INIT_MSG_LIST           IN      VARCHAR2,
                             P_START_TZ_ID             IN      NUMBER,
                             P_SR_SEVERITY             IN      NUMBER,
                             P_BUSINESS_PROCESS_ID     IN      NUMBER,
                             P_REQUEST_DATE            IN      DATE,
                             P_DATES_IN_INPUT_TZ       IN      VARCHAR2 DEFAULT 'N',
                             P_SERVICE_LINE_ID         IN      NUMBER,
			     P_CUST_ID		       IN      NUMBER,
			     P_CUST_SITE_ID            IN      NUMBER,
			     P_CUST_LOC_ID             IN      NUMBER,
                             X_REACT_BY_DATE           OUT     NOCOPY DATE,
                             X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT     NOCOPY NUMBER,
                             X_MSG_DATA                OUT     NOCOPY VARCHAR2)

 IS

 l_api_version     number := 1.0;
 l_return_status   varchar2(1);
 l_msg_count       number;
 l_msg_data        varchar2(100);
 l_react_within    number;
 l_react_tuom      varchar2(64);
 l_react_by_date   date;
 l_api_name        varchar2(30) := 'GET_REACTION_TIME';



 BEGIN

   SAVEPOINT check_reaction_times;

   -- Reaction time for a coverage line is calculated based on the
   -- severity of the SR, business process id, sr time zone and the
   -- date on which the SR is created. l_react_by_date is based on the
   -- SR timezone.

   OKS_ENTITLEMENTS_PUB.CHECK_REACTION_TIMES(p_api_version,
				             p_init_msg_list,
					     p_business_process_id,
					     p_request_date,
					     p_sr_severity,
					     p_start_tz_id,
                                             p_dates_in_input_tz,
					     p_service_line_id,
                                             l_return_status,
                                             l_msg_count,
                                             l_msg_data,
                                             l_react_within,
                                             l_react_tuom,
                                             l_react_by_date,
					     p_cust_id,--access hour project
					     p_cust_site_id,--access hour project
					     p_cust_loc_id);--access hour project


   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR ;
   ELSIF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   x_react_by_date   :=  l_react_by_date;
   x_return_status   :=  l_return_status;
   x_msg_count       :=  l_msg_count;
   x_msg_data        :=  l_msg_data;

 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO check_reaction_times;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count   =>x_msg_count ,
                                 p_data    => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO check_reaction_times;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count   =>x_msg_count ,
                                 p_data    => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN OTHERS THEN
     ROLLBACK TO check_reaction_times;
     x_return_status := FND_API.G_RET_STS_unexp_error ;
     IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
     END IF;
     fnd_msg_pub.count_and_get ( p_count   =>x_msg_count ,
                                 p_data    => x_msg_data ,
                                 p_encoded => fnd_api.g_false );


 END;



/*********************************************************************

  API                 :    Validate_contact
  Version             :
  Type                :    Private
  Function            :    Validate a Contact against the Contact tied to a
                           Coverage level  Line

  Parameters          :

  IN                  :
                           p_api_version               NUMBER    Required
                           p_init_msg_list             VARCHAR2  Required
                           P_CONTACT_ID                NUMBER    Required
                           P_CONTRACT_ID               NUMBER    Required
                           P_SERVICE_LINE_ID    NUMBER    Required

  OUT                 :

                           X_VALID_CONTACT         VARCHAR2
                           x_return_status         VARCHAR2
                           x_msg_count             NUMBER
                           x_msg_data              VARCHAR2

*********************************************************************/

PROCEDURE VALIDATE_CONTACT ( P_API_VERSION             IN      NUMBER,
                             P_INIT_MSG_LIST           IN      VARCHAR2,
                             P_CONTACT_ID              IN      NUMBER,
                             P_CONTRACT_ID             IN      NUMBER,
                             P_SERVICE_LINE_ID  IN      NUMBER,
                             X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT     NOCOPY NUMBER,
                             X_MSG_DATA                OUT     NOCOPY VARCHAR2,
                             X_VALID_CONTACT           OUT     NOCOPY VARCHAR2)

 IS


 l_api_version    number := 1.0;
 l_return_status  varchar2(1);
 l_msg_count      number;
 l_msg_data       varchar2(100);
 l_valid_contact  varchar2(1) :='N';
 l_rec_count      number :=1;
 l_ent_contacts   Ent_contact_tab;
 l_contact_id     number;
 l_api_name       varchar2(30) := 'VALIDATE_CONTACT';

 BEGIN

   l_contact_id := p_contact_id;

   SAVEPOINT validate_contact;

   -- This API returns a list of valid contacts tied to the coverage
   -- level line id.

   OKS_ENTITLEMENTS_PUB.GET_CONTACTS (p_api_version => p_api_version,
                                      p_init_msg_list  =>p_init_msg_list,
                                      p_contract_id => p_contract_id,
                                      p_contract_line_id =>p_service_line_id,
                                      x_return_status => l_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data =>l_msg_data,
                                      x_ent_contacts=>l_ent_contacts);


   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR ;
   ELSIF     ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   -- If  p_contact_id is one of the valid contacts then l_valid_contact
   -- flag is set to 'Y' else 'N' is returned.

   WHILE l_ent_contacts.exists(l_rec_count)
   LOOP
     IF  (l_ent_contacts(l_rec_count).contact_id  = l_contact_id) THEN
       l_valid_contact := 'Y';
       exit;
     ELSE
       l_rec_count := l_rec_count + 1;
     END IF;
   END LOOP;

   x_valid_contact := l_valid_contact;

 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN OTHERS THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_unexp_error ;
     IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
     END IF;
     fnd_msg_pub.count_and_get ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

 END;

/*********************************************************************

  API                 :    Validate_contact
  Version             :
  Type                :    Private
  Function            :    Validate Contacts against the Contacts tied to a
                           Coverage level  Line

  Parameters          :

  IN                  :
                           p_api_version               NUMBER    Required
                           p_init_msg_list             VARCHAR2  Required
                           P_CONTRACT_ID               NUMBER    Required
                           P_SERVICE_LINE_ID           NUMBER    Required

  OUT                 :

                           X_VALID_CONTACT      VARCHAR2
                           x_return_status      VARCHAR2
                           x_msg_count          NUMBER
                           x_msg_data           VARCHAR2
  IN OUT              :

                           P_CONTACT_TAB       ENT_CONTACT_TAB    Required
*********************************************************************/

PROCEDURE VALIDATE_CONTACT ( P_API_VERSION             IN      NUMBER,
                             P_INIT_MSG_LIST           IN      VARCHAR2,
                             P_CONTACT_TAB             IN OUT  NOCOPY INC_CONTACT_TAB,
                             P_CONTRACT_ID             IN      NUMBER,
                             P_SERVICE_LINE_ID         IN      NUMBER,
                             X_RETURN_STATUS           OUT     NOCOPY VARCHAR2,
                             X_MSG_COUNT               OUT     NOCOPY NUMBER,
                             X_MSG_DATA                OUT     NOCOPY VARCHAR2)

 IS


 l_api_version    number := 1.0;
 l_return_status  varchar2(1);
 l_msg_count      number;
 l_msg_data       varchar2(100);
 l_valid_contact  varchar2(1) :='N';
 l_rec_count      number;
 l_cont_count     number;
 l_ent_contacts   Ent_contact_tab;
 l_contact_id     number;
 l_api_name       varchar2(30) := 'VALIDATE_CONTACT';

 BEGIN


   SAVEPOINT validate_contact;

   -- This API returns a list of valid contacts tied to the coverage
   -- level line id.

   OKS_ENTITLEMENTS_PUB.GET_CONTACTS (p_api_version => p_api_version,
                                      p_init_msg_list  =>p_init_msg_list,
                                      p_contract_id => p_contract_id,
                                      p_contract_line_id =>p_service_line_id,
                                      x_return_status => l_return_status,
                                      x_msg_count => l_msg_count,
                                      x_msg_data =>l_msg_data,
                                      x_ent_contacts=>l_ent_contacts);


   IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
     RAISE FND_API.G_EXC_ERROR ;
   ELSIF     ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;

   -- If  p_contact_id is one of the valid contacts then l_valid_contact
   -- flag is set to 'Y' else 'N' is returned.
      l_cont_count := p_contact_tab.FIRST;

   WHILE l_cont_count is not null
   LOOP
     l_contact_id := p_contact_tab(l_cont_count).contact_id;
     l_rec_count := l_ent_contacts.FIRST;
     WHILE l_rec_count is not null
     LOOP
       IF  (l_ent_contacts(l_rec_count).contact_id  = l_contact_id) THEN
         p_contact_tab(l_cont_count).valid_contact := 'Y';
         exit;
       ELSE
         l_rec_count := l_ent_contacts.NEXT(l_rec_count);
       END IF;
     END LOOP;
     IF l_rec_count is null THEN
        p_contact_tab(l_cont_count).valid_contact := 'N';
     END IF;
     l_cont_count := p_contact_tab.NEXT(l_cont_count);

   END LOOP;


 EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.COUNT_AND_GET ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

   WHEN OTHERS THEN
     ROLLBACK TO validate_contact;
     x_return_status := FND_API.G_RET_STS_unexp_error ;
     IF fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error ) THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name ) ;
     END IF;
     fnd_msg_pub.count_and_get ( p_count =>x_msg_count ,
                                 p_data => x_msg_data ,
                                 p_encoded => fnd_api.g_false );

 END;

END CS_CONT_GET_DETAILS_PVT;

/
