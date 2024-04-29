--------------------------------------------------------
--  DDL for Package Body PON_CONTERMS_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CONTERMS_UTL_PVT" as
/* $Header: PONCTDPB.pls 120.6.12010000.3 2009/01/05 05:51:42 amundhra ship $ */

-- POC_ENABLED : Procurement Contracts Enabled
-- store the profile value in a global constant variable

g_contracts_installed_flag CONSTANT varchar2(1) :=  NVL(FND_PROFILE.VALUE('POC_ENABLED'),'N');

-- Read the profile option that enables/disables the debug log
-- store the profile value for logging in a global constant variable

g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- module prefix for logging
-- create a module name used for logging

g_module_prefix CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';

-- a few constants -- deliverables events
-- add constants for all deliverables events

DOCUMENT_PUBLISHED CONSTANT  varchar2(30) := 'SOURCING_DOCUMENT_PUBLISHED';
RESPONSE_RECEIVED  CONSTANT  varchar2(30) := 'RESPONSE_RECEIVED';
DOCUMENT_CLOSED    CONSTANT  varchar2(30) := 'SOURCING_DOCUMENT_CLOSED';

CONTRACT_SOURCE_ATTACHED CONSTANT varchar2(30) := 'ATTACHED';

PROCEDURE get_auction_header_id(
	p_contracts_doctype	IN VARCHAR2,
	p_contracts_doc_id	IN NUMBER,
	x_auction_header_id	OUT NOCOPY  pon_auction_headers_all.auction_header_id%type,
	x_return_status		OUT NOCOPY  VARCHAR2,
	x_msg_data		OUT NOCOPY  VARCHAR2,
	x_msg_count		OUT NOCOPY  NUMBER
) IS

BEGIN
  if (p_contracts_doctype = AUCTION or
      p_contracts_doctype = REQUEST_FOR_QUOTE or
      p_contracts_doctype = REQUEST_FOR_INFORMATION) then
    x_auction_header_id := p_contracts_doc_id;
  elsif (p_contracts_doctype = BID or
	   p_contracts_doctype = QUOTE or
	   p_contracts_doctype = RESPONSE) then
    begin
      select auction_header_id
      into x_auction_header_id
      from pon_bid_headers
      where bid_number = p_contracts_doc_id;

      x_return_status := fnd_api.g_ret_sts_success;
    exception
      when others then
        x_return_status := fnd_api.g_ret_sts_error;
	x_msg_data := 'Bad Bid Number ' || p_contracts_doc_id;
	x_msg_count := 1;
    end;
  else
    x_return_status := fnd_api.g_ret_sts_error;
    x_msg_data := 'Unknown doctype ' || p_contracts_doctype;
    x_msg_count := 1;
  end if;

  -- success!
  x_return_status := fnd_api.g_ret_sts_success;
END get_auction_header_id;


FUNCTION get_response_doc_type(p_doc_type_id IN NUMBER) RETURN VARCHAR2 IS
x_doctype_grp_name  pon_auc_doctypes.DOCTYPE_GROUP_NAME%type;
x_response_doc_name Varchar2(30);
BEGIN
       select DOCTYPE_GROUP_NAME
       into x_doctype_grp_name
       from pon_auc_doctypes
       where DOCTYPE_ID = p_doc_type_id;
	if(x_doctype_grp_name = SRC_AUCTION) then
		x_response_doc_name:= BID;
	elsif (x_doctype_grp_name = SRC_REQUEST_FOR_QUOTE) then
		x_response_doc_name:= QUOTE;
	elsif (x_doctype_grp_name = SRC_REQUEST_FOR_INFORMATION) then
		x_response_doc_name:= RESPONSE;
	end if;
   return(x_response_doc_name);

END get_response_doc_type;


FUNCTION get_negotiation_doc_type(p_doc_type_id IN NUMBER) RETURN VARCHAR2 IS
x_doctype_grp_name  pon_auc_doctypes.DOCTYPE_GROUP_NAME%type;
x_contract_doc_name Varchar2(30);
BEGIN
       select DOCTYPE_GROUP_NAME
       into x_doctype_grp_name
       from pon_auc_doctypes
       where DOCTYPE_ID = p_doc_type_id;
	if(x_doctype_grp_name = SRC_AUCTION) then
		x_contract_doc_name:= AUCTION;
	elsif (x_doctype_grp_name = SRC_REQUEST_FOR_QUOTE) then
		x_contract_doc_name:= REQUEST_FOR_QUOTE;
	elsif (x_doctype_grp_name = SRC_REQUEST_FOR_INFORMATION) then
		x_contract_doc_name:= REQUEST_FOR_INFORMATION;
	end if;
   return(x_contract_doc_name);

END get_negotiation_doc_type;

FUNCTION is_contracts_installed RETURN VARCHAR2 IS

BEGIN

-- read the global variable that stores the profile option.

        IF (g_contracts_installed_flag = 'Y') THEN
            RETURN FND_API.G_TRUE;
        ELSE
            RETURN FND_API.G_FALSE;
        END IF;

EXCEPTION
        WHEN OTHERS THEN
            RAISE;
END is_contracts_installed;

-- Contracts package will check the following.
    --   1. Whether Contracts 11.5.10+ is installed or not.
    --   2. Whether Contracts Terms is attached to the negotiation or not.
    --   3. Whether Contract Terms are attached/uploaded document or not.
FUNCTION is_deviations_enabled( p_document_type IN VARCHAR2,  p_document_id IN  NUMBER ) RETURN VARCHAR2 IS

l_api_name  CONSTANT   VARCHAR2(30) := 'is_deviations_enabled';
l_result    VARCHAR2(10);
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id             NUMBER;

BEGIN

        select org_id
        into l_org_id
        from pon_auction_headers_all
        where auction_header_id = p_document_id;

        --
        -- we only want to raise exception if we get zero or more
        -- than one records from the above sql
        --

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	        FND_LOG.string( log_level => FND_LOG.level_statement,
			    module    => g_module_prefix || l_api_name,
			    message   => 'Got ORG_ID for negotiation with the parameters : p_document_id = ' || p_document_id|| ' as:'||l_org_id );
            END IF;
        END IF;

        l_old_policy := mo_global.get_access_mode();
        l_old_org_id := mo_global.get_current_org_id();

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	        FND_LOG.string( log_level => FND_LOG.level_statement,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: Calling MO_GLOBAL.SET_POLICY_CONTEXT with the parameters : l_org_id = ' || l_org_id );
            END IF;
        END IF;

        --
        -- Set the connection policy context. Bug 5040821.
        --
        mo_global.set_policy_context('S', l_org_id);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	        FND_LOG.string( log_level => FND_LOG.level_statement,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: Calling OKC Package with the parameters : p_document_type = ' || p_document_type ||
                                         'p_document_id = ' || p_document_id);
            END IF;
        END IF;

        l_result := OKC_TERMS_UTIL_GRP.is_deviations_enabled( p_document_type => p_document_type, p_document_id => p_document_id );

        --
        -- Set the org context back
        --
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
	        FND_LOG.string( log_level => FND_LOG.level_statement,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: Calling MO_GLOBAL.SET_POLICY_CONTEXT with the parameters : l_org_id = ' || l_old_org_id || ', l_old_policy:'|| l_old_policy );
            END IF;
        END IF;

        mo_global.set_policy_context(l_old_policy, l_old_org_id);

        return l_result;

EXCEPTION
        WHEN OTHERS THEN
            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string( log_level => FND_LOG.level_procedure,
                              module    =>  g_module_prefix || l_api_name,
                              message   =>  'Exception occured while calling OKC_TERMS_UTIL_GRP.is_deviations_enabled function :'
                                            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
                END IF;
            END IF;
            RAISE;
END is_deviations_enabled;


FUNCTION get_concatenated_address(
	p_location_id	IN NUMBER)
RETURN VARCHAR2 IS
  v_address1	VARCHAR2(1000);
  v_address2	VARCHAR2(1000);

BEGIN
  BEGIN
    select
      hrl.address_line_1 || ' ' || hrl.address_line_2 || ' ' || hrl.address_line_3 || ' ' || hrl.town_or_city || ' ',
      hrl.region_1 || ' ' || hrl.region_2 || ' ' || hrl.region_3 || ' ' || hrl.postal_code || ' ' || nvl(ftl.territory_short_name, hrl.country)
    into
      v_address1,
      v_address2
    from
      hr_locations_all hrl,
      fnd_territories_tl ftl
    where
      hrl.location_id = p_location_id and
      ftl.territory_code(+) = hrl.country and
      ftl.territory_code(+) NOT IN ('ZR','FX','LX') and
      ftl.language(+) = userenv('LANG');
  EXCEPTION
    WHEN no_data_found THEN
      v_address1 := null;
      v_address2 := null;
  END;

  RETURN v_address1 || v_address2;
END get_concatenated_address;


/*==============================================================================================
 PROCEDURE : activateDeliverables   PUBLIC
   PARAMETERS:
   p_interface_id       IN              NUMBER          auction header id for negotiation
   p_new_bid_number     IN              NUMBER          new bid number for which deliverables are activated
   p_old_bid_number     IN              NUMBER          old bid number for which deliverables are canceled
   x_result             OUT     NOCOPY  VARCHAR2        result returned to called indicating SUCCESS or FAILURE
   x_error_code         OUT     NOCOPY  VARCHAR2        error code if x_result is FAILURE, NULL otherwise
   x_error_message      OUT     NOCOPY  VARCHAR2        error message if x_result is FAILURE, NULL otherwise
                                                        size is 250.

   COMMENT   :  activate deliverables for the newly placed active bid, cancel deliverables
                for the archived bid, This procedure is invoked from the bidding engine
                (pon_auction_headers_pkg)
   ==============================================================================================*/

PROCEDURE activateDeliverables (p_auction_id     IN NUMBER,
                                p_new_bid_number IN NUMBER,
                                p_old_bid_number IN NUMBER,
                                x_result         OUT NOCOPY VARCHAR2,
                                x_error_code     OUT NOCOPY VARCHAR2,
                                x_error_message  OUT NOCOPY VARCHAR2)

IS

l_api_name 	  CONSTANT 	VARCHAR2(30) := 'activateDeliverables';
l_api_version     CONSTANT	NUMBER       := 1.0;

l_init_msg_list   VARCHAR2(1)   := FND_API.G_FALSE;
l_doc_type_id     NUMBER;
l_bus_doc_type    VARCHAR2(30)  ;
l_open_date 	DATE;
l_close_date 	DATE;
-- out parameters for the contracts apis

l_msg_data                  VARCHAR2(250);
l_msg_count                 NUMBER;
l_return_status             VARCHAR2(1);

indx PLS_INTEGER := 0;

-- create a new table and record
l_bus_doc_dates_tbl  okc_manage_deliverables_grp.busdocdates_tbl_type;

l_new_bid_status VARCHAR2(30);
l_old_bid_status VARCHAR2(30);

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;


BEGIN

      x_result := FND_API.g_ret_sts_success;

      select doctype_id, open_bidding_date, close_bidding_date, org_id
      into l_doc_type_id, l_open_date, l_close_date, l_org_id
      from pon_auction_headers_all
      where auction_header_id = p_auction_id;

      l_bus_doc_type  := get_response_doc_type(l_doc_type_id);

      	select bid_status
	into l_new_bid_status
	from pon_bid_headers
	where bid_number = p_new_bid_number;

      if (p_old_bid_number <>-1) then
        select bid_status into l_old_bid_status from pon_bid_headers where bid_number = p_old_bid_number;
      end if;

      if (is_contracts_installed() = FND_API.G_TRUE) then

	begin
        --{
                        --
                        -- Get the current policy
                        --
                        l_old_policy := mo_global.get_access_mode();
                        l_old_org_id := mo_global.get_current_org_id();

                        --
                        -- Set the connection policy context. Bug 5040821.
                        --
                        mo_global.set_policy_context('S', l_org_id);


			-- bug 3608706 - new api to update the status history

			OKC_MANAGE_DELIVERABLES_GRP.postDelStatusChanges (
       				p_api_version  		=> 1.0,
       				p_init_msg_list 	=> FND_API.G_FALSE,
       				p_commit           	=> FND_API.G_FALSE,
       				p_bus_doc_id 		=> p_new_bid_number,
       				p_bus_doc_type 		=> l_bus_doc_type,
       				p_bus_doc_version 	=> -99,
                            	x_msg_data             	=> l_msg_data,
                            	x_msg_count          	=> l_msg_count,
                            	x_return_status      	=> l_return_status);

			 -- pass the remaining events and their dates
 			 l_bus_doc_dates_tbl(indx).EVENT_CODE := PON_CONTERMS_UTL_PVT.DOCUMENT_PUBLISHED;
                         l_bus_doc_dates_tbl(indx).EVENT_DATE := l_open_date;

			indx := indx + 1;

 			 l_bus_doc_dates_tbl(indx).EVENT_CODE := PON_CONTERMS_UTL_PVT.DOCUMENT_CLOSED;
                         l_bus_doc_dates_tbl(indx).EVENT_DATE := l_close_date;

                        -- activate deliverables for the new bid

                        OKC_MANAGE_DELIVERABLES_GRP.activateDeliverables (
                            p_api_version                 =>    1.0,
                            p_init_msg_list               =>    FND_API.G_FALSE,
			    p_commit			  =>    FND_API.G_FALSE,
                            p_bus_doc_id                  =>    p_new_bid_number,
                            p_bus_doc_type                =>    l_bus_doc_type,
                            p_bus_doc_version             =>    -99,
                            p_event_code                  =>    PON_CONTERMS_UTL_PVT.RESPONSE_RECEIVED,
                            p_event_date                  =>    SYSDATE,
                            p_bus_doc_date_events_tbl     =>    l_bus_doc_dates_tbl,
                            x_msg_data                    =>    l_msg_data,
                            x_msg_count                   =>    l_msg_count,
                            x_return_status               =>    l_return_status);

			-- keep logging

        		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
				x_result := FND_API.G_RET_STS_ERROR;
				x_error_code := '20001';
				x_error_message := 'ACTIVATE_FAILED';

            			IF (g_fnd_debug = 'Y') THEN
				    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN

               				FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE	,
                              			       module   => g_module_prefix || l_api_name,
                              			       message  => l_msg_data);
				    END IF;
           			END IF;
		        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        		END IF;

                        OKC_MANAGE_DELIVERABLES_GRP.enableNotifications(
                           p_api_version     => 1.0,
                           p_init_msg_list   => FND_API.G_FALSE,
                           p_commit          => FND_API.G_FALSE,
                           p_bus_doc_id      => p_new_bid_number,
                           p_bus_doc_type    => l_bus_doc_type,
                           p_bus_doc_version => -99,
                           x_msg_data        => l_msg_data,
                           x_msg_count       => l_msg_count,
                           x_return_status   => l_return_status);

               		IF (l_return_status < FND_API.G_RET_STS_SUCCESS) THEN
				x_result := FND_API.G_RET_STS_ERROR;
				x_error_code := '20002';
				x_error_message := 'ENABLE_NOTIF_FAILED';

                   	    IF (g_fnd_debug = 'Y') THEN

		     		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN

                      			FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE ,
                                     		       module    => g_module_prefix || l_api_name,
                                     		       message   => l_msg_data);
		     		END IF;

                   	    END IF;

               		END IF;

                         -- cancel deliverables for the archived bid

                	IF (p_old_bid_number <>-1 AND l_new_bid_status = 'ACTIVE') THEN

			    OKC_MANAGE_DELIVERABLES_GRP.cancelDeliverables (
                            p_api_version               =>      1.0,
                            p_init_msg_list             =>      FND_API.G_FALSE,
            		    p_commit		        =>	FND_API.G_FALSE,
                            p_bus_doc_id                =>      p_old_bid_number,
                            p_bus_doc_type              =>      l_bus_doc_type,
		            p_bus_doc_version		=>	-99,
                            x_msg_data                  =>      l_msg_data,
                            x_msg_count                 =>      l_msg_count,
                            x_return_status             =>      l_return_status);

        		        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

				    x_result := FND_API.G_RET_STS_ERROR;
				    x_error_code := '20003';
				    x_error_message := 'CANCEL_DELIV_FAILED';

            			    IF (g_fnd_debug = 'Y') THEN

				      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN

               			     	FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE	,
                                 	           module   => g_module_prefix || l_api_name,
                                		       message  => l_msg_data);
				      END IF;

           	    		    END IF;

		                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        		        END IF; -- IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)

                 	END IF; -- if (p_old_bid_number <>-1 AND l_new_bid_status = 'ACTIVE')
           --}
           exception
              when others then
                 --
                 -- Set the org context back
                 --
                 mo_global.set_policy_context(l_old_policy, l_old_org_id);
                 raise;
           end;
          end if;
END activateDeliverables;

/*==============================================================================================
 PROCEDURE : updateDeliverables   PUBLIC
   PARAMETERS:
   p_auction_header_id    IN              NUMBER       auction header id for negotiation
   p_doc_type_id          IN              NUMBER       doc type id for negotiation
   p_close_bidding_date   IN              NUMBER       new close bidding date for negotiation
   x_result             OUT     NOCOPY  VARCHAR2       result returned to called indicating SUCCESS or FAILURE
   x_error_code         OUT     NOCOPY  VARCHAR2       error code if x_result is FAILURE, NULL otherwise
   x_error_message      OUT     NOCOPY  VARCHAR2       error message if x_result is FAILURE, NULL otherwise
                                                       size is 250.
 COMMENT :  This procedure is to be called whenever there is a changed in close
bidding date of any negotiation.

==============================================================================================*/

PROCEDURE updateDeliverables (
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  p_close_bidding_date   IN  DATE,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
)
IS

  l_negotiation_doc_type     		VARCHAR2(30);
  l_response_doc_type        		VARCHAR2(30);
  l_bus_doc_dates_tbl 			okc_manage_deliverables_grp.busdocdates_tbl_type;
  l_return_status             		VARCHAR2(1);
  l_msg_data                  		VARCHAR2(250);
  l_api_name        			CONSTANT  VARCHAR2(30) := 'updateDeliverables';
  indx PLS_INTEGER := 0;

  --multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;


  /* get all the active and resubmission required bids in
     all the amendments (before/after) for the current auction
  */

  CURSOR active_bids IS
      SELECT bid_number
      FROM pon_bid_headers
      WHERE  auction_header_id in (select a.auction_header_id
				  from pon_auction_headers_all a,
				        pon_auction_headers_all b
				  where b.auction_header_id = p_auction_header_id
				  and   b.auction_header_id_orig_amend = a.auction_header_id_orig_amend)
      AND bid_status in ( 'ACTIVE', 'RESUBMISSION') ;

  /* get all the amendments (before/after) for the current
     auction.
  */

  CURSOR all_amendments is
      SELECT auction_header_id
      FROM   pon_auction_headers_all
      WHERE  auction_header_id in (select a.auction_header_id
				  from pon_auction_headers_all a,
				       pon_auction_headers_all b
				  where b.auction_header_id = p_auction_header_id
				  and   b.auction_header_id_orig_amend = a.auction_header_id_orig_amend);


 BEGIN

      if (is_contracts_installed() = FND_API.G_TRUE) then

	BEGIN

-- get the contract doc type depending on p_doc_type_id
  l_negotiation_doc_type := get_negotiation_doc_type(p_doc_type_id);
  l_response_doc_type 	 := get_response_doc_type(p_doc_type_id);

  -- populate the doc_date_based_events table
  l_bus_doc_dates_tbl(indx).EVENT_CODE := PON_CONTERMS_UTL_PVT.DOCUMENT_CLOSED;
  l_bus_doc_dates_tbl(indx).EVENT_DATE := p_close_bidding_date;

  indx := indx + 1;

  --
  -- Following sql will return the org_id of the negotiation chain as
  -- we can not change the org_id for amendment or new round
  --
  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

   -- Call Contracts API for updating negotiation first

   OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables(
                             	p_api_version		=> 1.0,
				p_init_msg_list 	=> FND_API.G_FALSE,
				p_commit 		=> FND_API.G_FALSE,
                             	p_bus_doc_id 		=> p_auction_header_id,
                             	p_bus_doc_type 		=> l_negotiation_doc_type,
				p_bus_doc_version	=> -99,
                             	p_bus_doc_date_events_tbl => l_bus_doc_dates_tbl,
                             	x_msg_data 		=> l_msg_data,
                             	x_msg_count 		=> x_msg_count,
                             	x_return_status 	=> l_return_status
                                                 );

      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
       END IF;

     FOR current_amendment in all_amendments LOOP

	-- special case for amendments
	-- if this auction has any new amendments, we
	-- need to update deliverables on them as well

	IF (current_amendment.auction_header_id <> p_auction_header_id) THEN

   		OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables(
                	             	p_api_version		=> 1.0,
					p_init_msg_list 	=> FND_API.G_FALSE,
					p_commit 		=> FND_API.G_FALSE,
	                             	p_bus_doc_id 		=> current_amendment.auction_header_id,
        	                     	p_bus_doc_type 		=> l_negotiation_doc_type,
					p_bus_doc_version	=> -99,
                        	     	p_bus_doc_date_events_tbl => l_bus_doc_dates_tbl,
	                             	x_msg_data 		=> l_msg_data,
        	                     	x_msg_count 		=> x_msg_count,
                	             	x_return_status 	=> l_return_status
                                                 );

	        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        	   IF (g_fnd_debug = 'Y') THEN
			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                	  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                        	         module   => g_module_prefix || l_api_name,
                                	 message  => l_msg_data);
			END IF;
           	   END IF;
       		END IF;

       END IF;

     END LOOP;


 -- Call Contracts API for updating Active Bids
 -- do we need to pass the close bidding date and response received date
 -- for each bid that we need to update?

     FOR active_bid IN active_bids LOOP

        OKC_MANAGE_DELIVERABLES_GRP.updateDeliverables(
                             p_api_version 		=> 1.0,
			     p_init_msg_list 		=> FND_API.G_FALSE,
			     p_commit 			=> FND_API.G_FALSE,
                             p_bus_doc_id 		=> active_bid.bid_number,
                             p_bus_doc_type 		=> l_response_doc_type,
			     p_bus_doc_version		=> -99,
                             p_bus_doc_date_events_tbl 	=> l_bus_doc_dates_tbl,
                             x_msg_data 		=> l_msg_data,
                             x_msg_count 		=> x_msg_count,
                             x_return_status 		=> l_return_status
                                                 );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
       END IF;
     END LOOP;

     --
     -- Set the org context back
     --
     mo_global.set_policy_context(l_old_policy, l_old_org_id);

EXCEPTION
    WHEN OTHERS THEN
      --
      -- Set the org context back
      --
      mo_global.set_policy_context(l_old_policy, l_old_org_id);
      -- ignore exception
end;
 END IF;

END updateDeliverables;

/*==============================================================================================
 PROCEDURE : cancelDeliverables   PUBLIC
   PARAMETERS:
   p_auction_header_id    IN              NUMBER          auction header id fornegotiation
   p_doc_type_id          IN              NUMBER          doc type id for negotiation
   x_result             OUT     NOCOPY  VARCHAR2        result returned to called indicating SUCCESS or FAILURE
   x_error_code         OUT     NOCOPY  VARCHAR2        error code if x_result is FAILURE, NULL otherwise
   x_error_message      OUT     NOCOPY  VARCHAR2        error message if x_result is FAILURE, NULL otherwise
                                                        size is 250.

 COMMENT :  This procedure is to be called whenever negotiation gets cancelled.

============================================================================================== */

PROCEDURE cancelDeliverables(
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
                            )
IS

  l_negotiation_doc_type     VARCHAR2(30);
  l_response_doc_type        VARCHAR2(30);
  l_return_status             VARCHAR2(1);
  l_msg_data                  VARCHAR2(250);
  l_api_name        CONSTANT  VARCHAR2(30) := 'cancelDeliverables';
  x_doctype_id     pon_auction_headers_all.doctype_id%type;


  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

   CURSOR active_bids IS
      SELECT bid_number
        FROM pon_bid_headers
       WHERE  auction_header_id = p_auction_header_id
         and   bid_status = 'ACTIVE';
BEGIN
  x_doctype_id :=p_doc_type_id;

     if (x_doctype_id =-1) then
        select doctype_id into x_doctype_id
        from pon_auction_headers_all
        where auction_header_id=p_auction_header_id;
    end if;

           if (is_contracts_installed() = FND_API.G_TRUE) then

BEGIN

   select org_id
   into l_org_id
   from pon_auction_headers_all
   where auction_header_id = p_auction_header_id;

   -- get the contract doc type depending on p_doc_type_id
   l_negotiation_doc_type := get_negotiation_doc_type(x_doctype_id);
   l_response_doc_type := get_response_doc_type(x_doctype_id);

   --
   -- Get the current policy
   --
   l_old_policy := mo_global.get_access_mode();
   l_old_org_id := mo_global.get_current_org_id();

   --
   -- Set the connection policy context. Bug 5040821.
   --
   mo_global.set_policy_context('S', l_org_id);

   -- Call Contracts API for cancelling negotiation 's delvierablesfirst
   OKC_MANAGE_DELIVERABLES_GRP.cancelDeliverables(
                                       p_api_version 		=> 1.0,
				       p_init_msg_list 		=> FND_API.G_FALSE,
				       p_commit	 		=> FND_API.G_FALSE,
                                       p_bus_doc_id 		=> p_auction_header_id,
                                       p_bus_doc_type 		=> l_negotiation_doc_type,
				       p_bus_doc_version 	=> -99,
                                       x_msg_data 		=> l_msg_data,
                                       x_msg_count 		=> x_msg_count,
                                       x_return_status 		=> l_return_status
                                                );


         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
       END IF;
 -- Call Contracts API for cancel Active Bids' deliverables
     FOR active_bid IN active_bids LOOP
        OKC_MANAGE_DELIVERABLES_GRP.cancelDeliverables(
                             p_api_version 		=> 1.0,
			     p_init_msg_list 		=> FND_API.G_FALSE,
			     p_commit	 		=> FND_API.G_FALSE,
                             p_bus_doc_id 		=> active_bid.bid_number,
                             p_bus_doc_type 		=> l_response_doc_type,
			     p_bus_doc_version		=> -99,
                             x_msg_data 		=> l_msg_data,
                             x_msg_count 		=> x_msg_count,
                             x_return_status 		=> l_return_status
                                                 );

         IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
       END IF;
     END LOOP;

     --
     -- Set the org context back
     --
     mo_global.set_policy_context(l_old_policy, l_old_org_id);

  EXCEPTION
    WHEN OTHERS THEN
       --
       -- Set the org context back
       --
       mo_global.set_policy_context(l_old_policy, l_old_org_id);
       -- ignore exception
end;
  END IF;

END cancelDeliverables;

/*===============================================================================================
 PROCEDURE : Delete_Doc   PUBLIC
   PARAMETERS:
   p_auction_header_id    IN              NUMBER          auction header id for negotiation
   p_doc_type_id          IN              NUMBER          doc type id for negotiation
   x_result             OUT     NOCOPY  VARCHAR2        result returned to called indicating SUCCESS or FAILURE
   x_error_code         OUT     NOCOPY  VARCHAR2        error code if x_result is FAILURE, NULL otherwise
   x_error_message      OUT     NOCOPY  VARCHAR2        error message if x_result is FAILURE, NULL otherwise
                                                        size is 250.

 COMMENT :  This procedure is to be called whenever negotiation gets deleted. As
 of now only draft negotiation is allowed to be deleted. Therefore this API
 should only be called for draft negotiation deletion only.

=============================================================================================== */

PROCEDURE Delete_Doc (
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
                     )
IS

  l_negotiation_doc_type     VARCHAR2(30);
  l_return_status             VARCHAR2(1);
  l_msg_data                  VARCHAR2(250);
  l_api_name        CONSTANT  VARCHAR2(30) := 'Delete_Doc';

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

BEGIN

            if (is_contracts_installed() = FND_API.G_TRUE) then

  BEGIN

   -- get the contract doc type depending on p_doc_type_id
   l_negotiation_doc_type := get_negotiation_doc_type(p_doc_type_id);

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = p_auction_header_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  OKC_TERMS_UTIL_GRP.Delete_Doc(
                             p_api_version => 1.0,
                             p_doc_id =>p_auction_header_id,
                             p_doc_type => l_negotiation_doc_type,
                             x_msg_data => l_msg_data,
                             x_msg_count => x_msg_count,
                             x_return_status => l_return_status
                             );
       IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
       END IF;
   --
   -- Set the org context back
   --
   mo_global.set_policy_context(l_old_policy, l_old_org_id);

   EXCEPTION
       WHEN OTHERS THEN
              --
              -- Set the org context back
              --
              mo_global.set_policy_context(l_old_policy, l_old_org_id);
              -- ignore exceptions
   End;
   END IF;

END Delete_Doc;

/* ===============================================================================================
 PROCEDURE : resolveDeliverables   PUBLIC
   PARAMETERS:
   p_auction_header_id    IN              NUMBER          auction header id for negotiation
   x_result             OUT     NOCOPY  VARCHAR2        result returned to called indicating SUCCESS or FAILURE
   x_error_code         OUT     NOCOPY  VARCHAR2        error code if x_result is FAILURE, NULL otherwise
   x_error_message      OUT     NOCOPY  VARCHAR2        error message if x_result is FAILURE, NULL otherwise
                                                        size is 250.

 COMMENT :  This procedure is to be called whenever negotiation is getting published.
 In OA Implementation, this should be called in beforeCommit method which publishes the negotiation.
=============================================================================================== */

PROCEDURE resolveDeliverables (
  p_auction_header_id    IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
  )

IS
  l_negotiation_doc_type     VARCHAR2(30);
  l_doc_type_id               NUMBER;
  l_view_by_date              DATE;
  l_open_date                 DATE;
  l_close_bidding_date        DATE;

  l_bus_doc_dates_tbl OKC_MANAGE_DELIVERABLES_GRP.BUSDOCDATES_TBL_TYPE;

  l_event_name               VARCHAR2(30);
  l_event_date               DATE;
  l_return_status             VARCHAR2(1);
  l_msg_data                  VARCHAR2(250);
  l_api_name        CONSTANT      VARCHAR2(30) := 'resolveDeliverables';

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;


  indx PLS_INTEGER := 0;

BEGIN

   if (is_contracts_installed() = FND_API.G_TRUE) then

    BEGIN

    SELECT doctype_id, view_by_Date, open_bidding_date, close_bidding_date, org_id
     INTO  l_doc_type_id, l_view_by_date, l_open_date, l_close_bidding_date, l_org_id
    FROM   pon_auction_headers_all
   WHERE   auction_header_id = p_auction_header_id;
   -- get the contract doc type depending on p_doc_type_id

   l_negotiation_doc_type := get_negotiation_doc_type(l_doc_type_id);

   -- event name and date
   l_event_name := PON_CONTERMS_UTL_PVT.DOCUMENT_PUBLISHED;
   l_event_date := l_open_date;

-- populate the doc_date_based_events table

   l_bus_doc_dates_tbl(indx).EVENT_CODE := PON_CONTERMS_UTL_PVT.DOCUMENT_CLOSED;
   l_bus_doc_dates_tbl(indx).EVENT_DATE := l_close_bidding_date;

   --
   -- Get the current policy
   --
   l_old_policy := mo_global.get_access_mode();
   l_old_org_id := mo_global.get_current_org_id();

   --
   -- Set the connection policy context. Bug 5040821.
   --
   mo_global.set_policy_context('S', l_org_id);

   OKC_MANAGE_DELIVERABLES_GRP.resolveDeliverables(
                             p_api_version 	=> 1.0,
			     p_init_msg_list  	=> FND_API.G_FALSE,
			     p_commit 		=> FND_API.G_FALSE,
                             p_bus_doc_id 	=> p_auction_header_id,
                             p_bus_doc_type 	=> l_negotiation_doc_type,
                             p_bus_doc_version 	=> -99,
                             p_event_code 	=> l_event_name,
                             p_event_date 	=> l_event_date,
                             p_bus_doc_date_events_tbl => l_bus_doc_dates_tbl,
                             x_msg_data 	=> x_msg_data,
                             x_msg_count 	=> x_msg_count,
                             x_return_status 	=> x_return_status
                             );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF (g_fnd_debug = 'Y') THEN
		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE     ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		END IF;
           END IF;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

   --
   -- Set the org context back
   --
   mo_global.set_policy_context(l_old_policy, l_old_org_id);
 EXCEPTION
       WHEN OTHERS THEN
              --
              -- Set the org context back
              --
              mo_global.set_policy_context(l_old_policy, l_old_org_id);
              -- ignore exceptions
  End;
 END IF;

END resolveDeliverables;

/*===============================================================================================
 PROCEDURE :  copyResponseDoc   PUBLIC
   PARAMETERS:
	p_source_bid_number  	IN 	NUMBER		bid number of the archived bid
	p_target_bid_number	IN 	NUMBER		bid number of the new active bid

 COMMENT :  This procedure is to be called whenever an active proxy bid is kicked in.
=============================================================================================== */

PROCEDURE copyResponseDoc (
	p_source_bid_number  	IN 	NUMBER,
	p_target_bid_number	IN 	NUMBER
)

IS

l_api_version		Number		:= 1.0;
l_init_msg_list		Varchar2(1) 	:= FND_API.G_FALSE ;
l_commit		Varchar2(1) 	:= FND_API.G_FALSE;

l_source_doc_type	Varchar2(30)	:= 'AUCTION_RESPONSE'; 	-- need to get the correct doc type
l_source_doc_id		Number		:= p_source_bid_number;

l_target_doc_type	Varchar2(30)	:= 'AUCTION_RESPONSE'; -- need to get the correct doc type
l_target_doc_id		Number		:= p_target_bid_number;

l_keep_version		Varchar2(1)	:= 'N';

l_article_effective_date Date		:= sysdate;

l_initializeStatus_yn	 Varchar2(1) 	:= 'N';
l_reset_fixed_date_yn	Varchar2(1)	:= 'N';

l_internal_party_id	Number		:= null; -- pon_auction_headers_all.trading_partner_id
l_internal_contact_id   Number		:= null; --
l_internal_contact_pid  Number      :=null;
l_contractualonly	Varchar2(1)	:= 'N';

l_external_party_id	Number		:= null; -- pon_bid_headers.trading_partner_id
l_external_contact_id 	Number 		:= null; -- pon_bid_headers.trading_partner_contact_id

l_copy_deliverables 	Varchar2(1)	:= 'Y';

l_document_number	Varchar2(250)	:=  null;

l_copy_for_amendment 	Varchar2(1) 	:= 'Y';

l_target_contractual_doctype Varchar2(25);

l_return_status		Varchar2(1);
l_msg_data		Varchar2(250);
l_msg_count		NUMBER;

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

BEGIN

        --
        -- org_id of the p_source_bid_number
        -- and p_target_bid_number will be very same. This is
        -- an assumption due to current functional
        -- design of sourcing
        --
        select h.org_id
        into l_org_id
        from pon_auction_headers_all h,
             pon_bid_headers b
        where b.bid_number = p_source_bid_number
        and h.auction_header_id = b.auction_header_id;

        --
        -- Get the current policy
        --
        l_old_policy := mo_global.get_access_mode();
        l_old_org_id := mo_global.get_current_org_id();

        --
        -- Set the connection policy context. Bug 5040821.
        --
        mo_global.set_policy_context('S', l_org_id);

	OKC_TERMS_COPY_GRP.COPY_RESPONSE_DOC(
		p_api_version 		=>	1.0			, --l_api_version	,
		p_init_msg_list		=>	FND_API.G_FALSE		, --l_init_msg_list	,
		p_commit		=>	FND_API.G_FALSE		, --l_commit		,
		p_source_doc_type	=>	l_source_doc_type	,
		p_source_doc_id		=>	l_source_doc_id		,
		p_target_doc_type	=>	l_target_doc_type	,
		p_target_doc_id		=>	l_target_doc_id		,
	        p_target_doc_number     =>	NULL			, -- not sure what this is used for ??
		p_keep_version		=>	'N'			, --l_keep_version	,
		p_article_effective_date =>	sysdate			, --l_article_effective_date,
		p_copy_doc_attachments  => 	'N'			, -- default 'N'
		p_allow_duplicate_terms =>	'N'			, -- default 'N'
		p_copy_attachments_by_ref =>	'N'			, -- default 'N'
/*
		p_initialize_status_yn 	=>	'N'			, --l_initializeStatus_yn,
		p_reset_fixed_date_yn	=>	'N'			, --l_reset_fixed_date_yn, -- new flag
		p_internal_party_id	=>	l_internal_party_id	,
		p_internal_contact_id	=>	l_internal_contact_id	,
		p_target_contractual_doctype 	=> l_target_contractual_doctype		,
		p_copy_del_attachments_yn	=> 'Y'			,
--		p_contractual_only	=>	'N'			, --l_contractualonly	,
		p_external_party_id 	=> 	l_external_party_id	,
		p_external_contact_id	=>	l_external_contact_id	,
		p_copy_deliverables	=>	'Y'			, --l_copy_deliverables	,
		p_document_number	=>	NULL			, --l_document_number	,
		p_copy_for_amendment	=>	'N'			, --l_copy_for_amendment,
*/
		x_return_status		=>	l_return_status		,
		x_msg_data		=>	l_msg_data		,
		x_msg_count		=>	l_msg_count		);


        --
        -- Set the org context back
        --
        mo_global.set_policy_context(l_old_policy, l_old_org_id);

EXCEPTION
   WHEN OTHERS THEN
       --
       -- Set the org context back
       --
       mo_global.set_policy_context(l_old_policy, l_old_org_id);
       -- raise the exception
       RAISE;
END copyResponseDoc;


/*===============================================================================================
 PROCEDURE :  disqualifyDeliverables   PUBLIC
   PARAMETERS:
	p_bid_number	IN 	NUMBER	bid number of the disqualified bid

 COMMENT :  This procedure is to be called whenever an active proxy bid is disqualified
=============================================================================================== */

PROCEDURE disqualifyDeliverables (
	p_bid_number	IN 	NUMBER
)

IS

l_api_version     NUMBER     := 1.0;
l_api_name	  CONSTANT	VARCHAR2(30) := 'disqualifyDeliverables';
l_bus_doc_id      NUMBER;
l_doc_type_id     NUMBER;
l_init_msg_list   VARCHAR2(1)   := FND_API.G_FALSE;
l_bus_doc_type    VARCHAR2(30);

l_event_name  VARCHAR2(30) := PON_CONTERMS_UTL_PVT.RESPONSE_RECEIVED;
l_event_date  DATE         := sysdate;

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

-- out parameters for the contracts apis

l_msg_data                  VARCHAR2(250);
l_msg_count                 NUMBER;
l_return_status             VARCHAR2(1);
l_commit		    VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

	select b.doctype_id ,
               a.org_id
        into l_doc_type_id,
             l_org_id
        from pon_bid_headers b,
             pon_auction_headers_all a
        where b.bid_number = p_bid_number
        and a.auction_header_id = b.auction_header_id;

	l_bus_doc_type := get_response_doc_type(l_doc_type_id);

        if (is_contracts_installed() = FND_API.G_TRUE) then

                begin
			-- note that we do not need to cancel all the deliverabls
			-- for all the archived bids that will get 'disqualified'
			-- as we will have already canceled the deliverables on them
			-- while archiving the bid.

                        -- cancel deliverables for the archived bid

                        --
                        -- Get the current policy
                        --
                        l_old_policy := mo_global.get_access_mode();
                        l_old_org_id := mo_global.get_current_org_id();

                        --
                        -- Set the connection policy context. Bug 5040821.
                        --
                        mo_global.set_policy_context('S', l_org_id);

                        OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables (
                            p_api_version               =>      1.0,
                            p_init_msg_list             =>      FND_API.G_FALSE,
			    p_commit			=>	FND_API.G_FALSE,
                            p_bus_doc_id                =>      p_bid_number,
                            p_bus_doc_type              =>      l_bus_doc_type,
			    p_bus_doc_version		=>	-99,
                            x_msg_data                  =>      l_msg_data,
                            x_msg_count                 =>      l_msg_count,
                            x_return_status             =>      l_return_status);

                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     IF (g_fnd_debug = 'Y') THEN
			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                          FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
			END IF;
                     END IF;
                    END IF;

                    --
                    -- Set the org context back
                    --
                    mo_global.set_policy_context(l_old_policy, l_old_org_id);

		exception
                   when others then
                     --
                     -- Set the org context back
                     --
                     mo_global.set_policy_context(l_old_policy, l_old_org_id);
                     -- raise the exception
                     RAISE;
                end;

           end if;

END disqualifyDeliverables;




PROCEDURE disableDeliverables(
  p_auction_number    IN  NUMBER,
  p_doc_type_id       IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2

                              )
IS
l_api_version     NUMBER     := 1.0;
l_bus_doc_id      NUMBER;

l_init_msg_list   VARCHAR2(1)   := FND_API.G_FALSE;

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

-- out parameters for the contracts apis
l_msg_data                  VARCHAR2(250);
l_msg_count                 NUMBER;
l_return_status             VARCHAR2(1);
l_commit                    VARCHAR2(1) := FND_API.G_FALSE;
l_response_doc_type         VARCHAR2(30);
l_api_name        CONSTANT      VARCHAR2(30) :='disableDeliverables';

 CURSOR active_bids IS
      SELECT bid_number
        FROM pon_bid_headers
       WHERE  auction_header_id =p_auction_number
         and   bid_status = 'ACTIVE';

BEGIN

  l_response_doc_type := get_response_doc_type(p_doc_type_id);
        if (is_contracts_installed() = FND_API.G_TRUE) then

                begin

                  select org_id
                  into l_org_id
                  from pon_auction_headers_all
                  where auction_header_id = p_auction_number;

                  --
                  -- Get the current policy
                  --
                  l_old_policy := mo_global.get_access_mode();
                  l_old_org_id := mo_global.get_current_org_id();

                  --
                  -- Set the connection policy context. Bug 5040821.
                  --
                  mo_global.set_policy_context('S', l_org_id);

                  FOR active_bid IN active_bids LOOP

                       OKC_MANAGE_DELIVERABLES_GRP.disableDeliverables(
                            p_api_version               =>      1.0,
                            p_init_msg_list             =>      FND_API.G_FALSE,
                            p_commit                    =>      FND_API.G_FALSE,
                            p_bus_doc_id                =>      active_bid.bid_number,
                            p_bus_doc_type              =>      l_response_doc_type,
                            p_bus_doc_version           =>      -99,
                            x_msg_data                  =>      l_msg_data,
                            x_msg_count                 =>      l_msg_count,
                            x_return_status             =>      l_return_status)
;
                    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                     IF (g_fnd_debug = 'Y') THEN
			IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
                         FND_LOG.string(log_level => FND_LOG.LEVEL_PROCEDURE ,
                                 module   => g_module_prefix || l_api_name,
                                 message  => l_msg_data);
		       END IF;
                     END IF;
                    END IF;
                  end loop;

                  --
                  -- Set the org context back
                  --
                  mo_global.set_policy_context(l_old_policy, l_old_org_id);

                end;
           end if;
 EXCEPTION
       WHEN OTHERS THEN
              --
              -- Set the org context back
              --
              mo_global.set_policy_context(l_old_policy, l_old_org_id);
              -- ignore exceptions

END disableDeliverables;


/*======================================================================
 FUNCTION :  contract_terms_exist    PUBLIC
 PARAMETERS:
  p_doc_type          IN  document type for contract
  p_doc_id            IN  document id

 COMMENT   : check if negotiation has contract terms
             used to set pon_auction_headers_all.conterms_exist_flag
======================================================================*/

FUNCTION contract_terms_exist(p_doc_type IN VARCHAR2,
                              p_doc_id   IN NUMBER) RETURN VARCHAR2 IS
	-- Bug 7409774 : Multi-org Related changes are not required here.
   -- multi-org related changes
  --   l_old_org_id             NUMBER;
  -- l_old_policy             VARCHAR2(2);
  -- l_org_id                 NUMBER;
   l_msg_data               VARCHAR2(250);
   l_msg_count              NUMBER;
   l_return_status          VARCHAR2(1);
   l_auction_header_id      pon_auction_headers_all.auction_header_id%type;

BEGIN

   get_auction_header_id(p_doc_type, p_doc_id, l_auction_header_id, l_return_status, l_msg_data, l_msg_count);

   if(l_return_status <> fnd_api.g_ret_sts_success) then
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string( fnd_log.level_statement,
                        'pon_conterms_utl_pvt',
                        'contract_terms_exist() failed for doc_id=' || p_doc_id || ', msg_data=' || l_msg_data
                      );
      end if;
      RETURN null;
   end if;

 --  select org_id
 --  into l_org_id
 --  from pon_auction_headers_all
 --  where auction_header_id = l_auction_header_id;

   --
   -- Get the current policy
   --
-- Bug 7409774 -- Commenting the multi-org related code. Not required here.
   -- l_old_policy := mo_global.get_access_mode();
   -- l_old_org_id := mo_global.get_current_org_id();

   --
   -- Set the connection policy context. Bug 5040821.
   --
   --   mo_global.set_policy_context('S', l_org_id);

   -- Refer the bug 4129274 for more details.
   return OKC_TERMS_UTIL_GRP.HAS_TERMS( p_document_type => p_doc_type,
                                        p_document_id   => p_doc_id
                                      );
   --
   -- Set the org context back
   --
   -- mo_global.set_policy_context(l_old_policy, l_old_org_id);


END contract_terms_exist;

/*
 is_article_attached()

 returns:
  error				= null
  G_ONLY_STANDARD_ART_EXIST	= ONLY_STANDARD
  G_NON_STANDARD_ART_EXIST	= NON_STANDARD
  G_NO_ARTICLE_EXIST		= NONE
*/
PROCEDURE is_article_attached(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;


BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  resultout := okc_terms_util_grp.is_article_exist(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_article_exist() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END is_article_attached;

/*
 is_article_amended()

 returns:
  error				= null
  G_ONLY_STANDARD_AMENDED	= ONLY_STANDARD
  G_NON_STANDARD_AMENDED	= NON_STANDARD
  G_NO_ARTICLE_AMENDED		= NONE
*/
PROCEDURE is_article_amended(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  resultout := okc_terms_util_grp.is_article_amended(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_article_amended() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END;

/*
 is_deliverable_amended()

 returns:
  error = null
  ALL
  NONE
  CONTRACTUAL
  INTERNAL
  SOURCING
  CONTRACTUAL_AND_INTERNAL
  CONTRACTUAL_AND_SOURCING
  SOURCING_AND_INTERNAL
*/
PROCEDURE is_deliverable_amended(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  resultout := okc_terms_util_grp.is_deliverable_amended(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_deliverable_amended() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END;

/*
 is_template_expired()

 returns:
  error			= null
  template expired	= T
  template not expired	= F
*/
PROCEDURE is_template_expired(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;


BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);


  resultout := okc_terms_util_grp.is_template_expired(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_template_expired() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END;

/*
 is_standard_contract()

 returns:
  error					= null
  G_NO_CHANGE				= NO_CHANGE
  G_ARTICLES_CHANGED			= ARTICLES_CHANGED
  G_DELIVERABLES_CHANGED 		= DELIVERABLES_CHANGED
  G_ART_AND_DELIV_CHANGED		= ALL_CHANGED
*/
PROCEDURE is_standard_contract(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  resultout := okc_terms_util_grp.deviation_from_standard(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_standard_contract() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END;

/*
 is_deliverable_attached()

 returns:
  error				= null
  No Deliverables		= NONE
  Contractual Only		= CONTRACTUAL
  Internal Only			= INTERNAL
  Contractual and Internal	= CONTRACTUAL_AND_INTERNAL
*/
PROCEDURE is_deliverable_attached(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
) IS
  v_return_status	varchar2(1);
  v_msg_data	   	varchar2(200);
  v_msg_count		number;
  v_doc_id		number;

  -- multi-org related changes
  l_old_org_id             NUMBER;
  l_old_policy             VARCHAR2(2);
  l_org_id                 NUMBER;

BEGIN
  -- get document id
  v_doc_id := wf_engine.getItemAttrNumber(itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'AUCTION_ID');

  select org_id
  into l_org_id
  from pon_auction_headers_all
  where auction_header_id = v_doc_id;

  --
  -- Get the current policy
  --
  l_old_policy := mo_global.get_access_mode();
  l_old_org_id := mo_global.get_current_org_id();

  --
  -- Set the connection policy context. Bug 5040821.
  --
  mo_global.set_policy_context('S', l_org_id);

  resultout := okc_terms_util_grp.is_deliverable_exist(
			p_api_version		=> 1.0,
			p_init_msg_list		=> fnd_api.g_false,
			x_return_status		=> v_return_status,
			x_msg_data		=> v_msg_data,
			x_msg_count		=> v_msg_count,
			p_doc_type		=> pon_conterms_utl_grp.get_contracts_document_type(v_doc_id, 'N'),
			p_doc_id		=> v_doc_id);

  if (v_return_status <> fnd_api.g_ret_sts_success) then
    resultout := null;

    if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
      fnd_log.string(fnd_log.level_statement,
		     'pon_conterms_utl_pvt',
		     'is_deliverable_attached() failed for doc_id=' || v_doc_id || ', msg_data=' || v_msg_data);
    end if;
  end if;

  --
  -- Set the org context back
  --
  mo_global.set_policy_context(l_old_policy, l_old_org_id);

END;




PROCEDURE updateDelivOnVendorMerge
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2
) IS

l_api_name  CONSTANT VARCHAR2(60) := 'updateDeliverablesOnVendorMerge';
-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);

BEGIN

      IF (is_contracts_installed() = FND_API.G_TRUE) THEN --{

	BEGIN
	  --{

                --
                -- Get the current policy
                --
                l_old_policy := mo_global.get_access_mode();
                l_old_org_id := mo_global.get_current_org_id();

                --
                -- Set the connection policy context. Bug 5040821.
                --
                mo_global.set_policy_context('M', null);

        	OKC_MANAGE_DELIVERABLES_GRP.updateExtPartyOnDeliverables
	        ( p_api_version                 => 1.0,
        	  p_init_msg_list               => FND_API.G_TRUE,
	          p_commit                      => FND_API.G_FALSE,
        	  p_document_class              => 'SOURCING',
	          p_from_external_party_id      => p_from_vendor_id,
        	  p_from_external_party_site_id => p_from_site_id,
	          p_to_external_party_id        => p_to_vendor_id,
        	  p_to_external_party_site_id   => p_to_site_id,
	          x_msg_data                    => x_msg_data,
        	  x_msg_count                   => x_msg_count,
	          x_return_status               => x_return_status
        	);

                --
                -- Set the org context back
                --
                mo_global.set_policy_context(l_old_policy, l_old_org_id);

		-- keep logging

        	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN --{

            		IF (g_fnd_debug = 'Y') THEN --{

			    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN

               			FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE	,
                              			module   => g_module_prefix || l_api_name,
                              		  	message  => 'UPDATE_DELIV_ON_VENDOR_MERGE_FAILED: '
                                                || 'p_from_external_party_id = ' || p_from_vendor_id
                                                || ' p_from_external_party_site_id=' || p_from_site_id
                                                || ' p_to_external_party_id=' || p_to_vendor_id
                                                || ' p_to_external_party_site_id=' || p_to_site_id);
			    END IF;

           		END IF; --}
		        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        	END IF; --}
	    END;--}
 	END IF;--}
EXCEPTION
	WHEN OTHERS THEN
		null;
END updateDelivOnVendorMerge;




/* ===============================================================================================
 PROCEDURE : updateDelivOnAmendment   PUBLIC
   PARAMETERS:
   p_auction_header_id_orig  	IN         	NUMBER          auction header id of the original amendment
   p_auction_header_id_prev  	IN		NUMBER		auction header id of the previous amendment
   p_doc_type_id		IN		NUMBER		doc-type-id for the current negotiation
   p_close_bidding_date 	IN		DATE		new close date for the new amendment
   p_close_date_changed 	IN		VARCHAR2	flag to indicate whether the close date was changed
   x_result             	OUT     NOCOPY  VARCHAR2        result returned to called indicating SUCCESS or FAILURE
   x_error_code         	OUT     NOCOPY  VARCHAR2        error code if x_result is FAILURE, NULL otherwise
   x_error_message      	OUT     NOCOPY  VARCHAR2        error message if x_result is FAILURE, NULL otherwise
                                                        	size is 250.

 COMMENT :  This procedure is to be called whenever amendment is getting published.
 In OA Implementation, this should be called in beforeCommit method which publishes the negotiation.
=============================================================================================== */

PROCEDURE updateDelivOnAmendment (
  p_auction_header_id_orig    	IN  NUMBER,
  p_auction_header_id_prev     	IN  NUMBER,
  p_doc_type_id		 	IN  NUMBER,
  p_close_bidding_date   	IN  DATE,
  x_result	             	OUT NOCOPY  VARCHAR2,
  x_error_code            	OUT NOCOPY  VARCHAR2,
  x_error_message        	OUT NOCOPY  VARCHAR2
  )

IS

l_old_close_date     DATE;
l_msg_code	     VARCHAR2(240);
l_api_name 	  CONSTANT 	VARCHAR2(30) := 'updateDelivOnAmendment';
l_api_version     CONSTANT	NUMBER       := 1.0;

-- out parameters for the contracts apis

l_msg_data                  VARCHAR2(250);
l_msg_count                 NUMBER;
l_return_status             VARCHAR2(1);

BEGIN

	select close_bidding_date into l_old_close_date
	from pon_auction_headers_all
	where auction_header_id = p_auction_header_id_prev;

	-- if the close date was changed during the amendment process
	-- then we need to update all the deliverables in the new and old
	-- amendments that are based upon the close date event

	IF( p_close_bidding_date <> l_old_close_date) THEN

		PON_CONTERMS_UTL_PVT.updateDeliverables(p_auction_header_id 	=> p_auction_header_id_orig,
							p_doc_type_id		=> p_doc_type_id,
							p_close_bidding_date 	=> p_close_bidding_date,
							x_msg_data		=> l_msg_data,
							x_msg_count		=> l_msg_count,
							x_return_status		=> l_return_status);


        	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

			x_result := FND_API.G_RET_STS_ERROR;
			x_error_code := 'UPDATE_DELIV_AMEND_FAILED';
			x_error_message := 'Unable to update deliverables for auction ' || p_auction_header_id_orig;

            		IF (g_fnd_debug = 'Y') THEN
			     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
               			FND_LOG.string(	log_level => FND_LOG.LEVEL_PROCEDURE	,
                              		       	module    => g_module_prefix || l_api_name,
                              		 	message   => l_msg_data || ' ' || x_error_code || ' ' ||  x_error_message);
			     END IF;
           		END IF;
		        --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        	END IF;
	END IF;

	-- finally call disabledeliverables on the previous amendment

	PON_CONTERMS_UTL_PVT.disableDeliverables(p_auction_number 	=> p_auction_header_id_prev,
						 p_doc_type_id		=> p_doc_type_id,
						 x_msg_data		=> l_msg_data,
						 x_msg_count		=> l_msg_count,
						 x_return_status	=> l_return_status);

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

		x_result := FND_API.G_RET_STS_ERROR;
		x_error_code := 'DISABLE_DELIV_AMEND_FAILED';
		x_error_message := 'Unable to disable deliverables for auction ' || p_auction_header_id_prev;

            	IF (g_fnd_debug = 'Y') THEN
		     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
               		FND_LOG.string(	log_level => FND_LOG.LEVEL_PROCEDURE	,
                              		module    => g_module_prefix || l_api_name,
                              		message   => l_msg_data || ' ' || x_error_code || ' ' ||  x_error_message);
		     END IF;
           	END IF;
		--RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


EXCEPTION

	WHEN OTHERS THEN

		x_result := FND_API.G_RET_STS_ERROR;
		x_error_code := 'UPDATE_DELIV_AMEND_FAILED_COMPLETELY - ' || SQLCODE;
		x_error_message := 'Unable to do anything with deliverables for auction ' || p_auction_header_id_prev || ' ' || SUBSTR(SQLERRM, 1, 100);

            	IF (g_fnd_debug = 'Y') THEN
		     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
               		FND_LOG.string(	log_level => FND_LOG.LEVEL_PROCEDURE	,
                              		module    => g_module_prefix || l_api_name,
                              		message   => l_msg_data || ' ' || x_error_code || ' ' ||  x_error_message);
		     END IF;
           	END IF;

END updateDelivOnAmendment;

/* ============================================================================
 * FUNCTION  : attachedDocumentExists PUBLIC
 * PARAMETERS:
 *             p_document_type IN VARCHAR2 - The document type:AUCTION, RFI, RFQ
 *             p_document_id  IN NUMBER - The document id
 * RETURNS   :
 *             FND_DOCUMENTS_TL.media_id of the Primary contract file for the
 *             current version of the document if it is non mergeable.
 *             0 if document is mergeable.
 *             -1 if no primary document exists.
  ============================================================================*/
FUNCTION attachedDocumentExists (
  p_document_type IN VARCHAR2,
  p_document_id   IN NUMBER)
  RETURN NUMBER

IS
l_api_name 	  CONSTANT 	VARCHAR2(30) := 'attachedDocumentExists';
l_primary_terms_doc_file_id NUMBER;

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

BEGIN

    select org_id
    into l_org_id
    from pon_auction_headers_all
    where auction_header_id = p_document_id;

    --
    -- Get the current policy
    --
    l_old_policy := mo_global.get_access_mode();
    l_old_org_id := mo_global.get_current_org_id();

    --
    -- Set the connection policy context. Bug 5040821.
    --
    mo_global.set_policy_context('S', l_org_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: p_document_type = ' || p_document_type ||
                                         'p_document_id = ' || p_document_id);
	END IF;
    END IF;

    l_primary_terms_doc_file_id := OKC_TERMS_UTIL_GRP.GET_PRIMARY_TERMS_DOC_FILE_ID(
				    p_document_type => p_document_type,
				    p_document_id => p_document_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'END: l_primary_terms_doc_file_id= ' || l_primary_terms_doc_file_id);
	END IF;
    END IF;

    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);


    RETURN l_primary_terms_doc_file_id;

EXCEPTION
  WHEN OTHERS THEN
    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string( log_level => FND_LOG.level_exception,
          module    =>  g_module_prefix || l_api_name,
          message   =>  'Exception occured while calling OKC_TERMS_UTIL_GRP.GET_PRIMARY_TERMS_DOC_FILE_ID function :'
          || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;
    END IF;
    RAISE;
END attachedDocumentExists;

/* =============================================================================
 * FUNCTION  : isDocumentMergeable PUBLIC
 * PARAMETERS:
 *             p_document_type IN VARCHAR2 - The document type:AUCTION, RFI, RFQ
 *             p_document_id  IN NUMBER - The document id
 * RETURNS   : 'Y' - Attached document is oracle generated and mergeable.
 *             'N' - Non recognised format, non mergeable.
 *             'E' - Error.
 *
 * ===========================================================================*/
FUNCTION isDocumentMergeable(
  p_document_type  IN VARCHAR2,
  p_document_id    IN NUMBER)
  RETURN VARCHAR2
IS
l_api_name 	  CONSTANT 	VARCHAR2(30) := 'isDocumentMergeable';
l_is_prm_trm_doc_mergeable VARCHAR2(1);

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

BEGIN

    select org_id
    into l_org_id
    from pon_auction_headers_all
    where auction_header_id = p_document_id;

    --
    -- Get the current policy
    --
    l_old_policy := mo_global.get_access_mode();
    l_old_org_id := mo_global.get_current_org_id();

    --
    -- Set the connection policy context. Bug 5040821.
    --
    mo_global.set_policy_context('S', l_org_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: p_document_type = ' || p_document_type ||
                                         'p_document_id = ' || p_document_id);
	END IF;
    END IF;

    l_is_prm_trm_doc_mergeable := OKC_TERMS_UTIL_GRP.IS_PRIMARY_TERMS_DOC_MERGEABLE(
				    p_document_type => p_document_type,
				    p_document_id => p_document_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'END: l_is_prm_trm_doc_mergeable= ' || l_is_prm_trm_doc_mergeable);
	END IF;
    END IF;

    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);


    RETURN l_is_prm_trm_doc_mergeable;

EXCEPTION
  WHEN OTHERS THEN
    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);

    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string( log_level => FND_LOG.level_exception,
          module    =>  g_module_prefix || l_api_name,
          message   =>  'Exception occured while calling OKC_TERMS_UTIL_GRP.IS_PRIMARY_TERMS_DOC_MERGEABLE function :'
          || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;
    END IF;
    RAISE;
END isDocumentMergeable;


/* =============================================================================
 * FUNCTION  : isAttachedDocument PUBLIC
 * PARAMETERS:
 *             p_document_type IN VARCHAR2 - The document type:AUCTION, RFI, RFQ
 *             p_document_id  IN NUMBER - The document id
 * RETURNS   : if the Contract terms are structured or not.
 *
 * ===========================================================================*/

FUNCTION isAttachedDocument(
           p_document_type IN VARCHAR2,
           p_document_id IN NUMBER)
     RETURN VARCHAR2
IS
l_api_name 	  CONSTANT 	VARCHAR2(30) := 'isAttachedDocument';
l_contract_source_code VARCHAR2(60);

-- multi-org related changes
l_old_org_id             NUMBER;
l_old_policy             VARCHAR2(2);
l_org_id                 NUMBER;

BEGIN

    select org_id
    into l_org_id
    from pon_auction_headers_all
    where auction_header_id = p_document_id;

    --
    -- Get the current policy
    --
    l_old_policy := mo_global.get_access_mode();
    l_old_org_id := mo_global.get_current_org_id();

    --
    -- Set the connection policy context. Bug 5040821.
    --
    mo_global.set_policy_context('S', l_org_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: p_document_type = ' || p_document_type ||
                                         'p_document_id = ' || p_document_id);
	END IF;
    END IF;

    l_contract_source_code := OKC_TERMS_UTIL_GRP.GET_CONTRACT_SOURCE_CODE (
				    p_document_type => p_document_type,
				    p_document_id => p_document_id);

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'END: l_contract_source_code = ' || l_contract_source_code);
	END IF;
    END IF;

    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);

    IF (l_contract_source_code = PON_CONTERMS_UTL_PVT.CONTRACT_SOURCE_ATTACHED) THEN
      RETURN 'Y';

    ELSE
      RETURN 'N';
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    --
    -- Set the org context back
    --
    mo_global.set_policy_context(l_old_policy, l_old_org_id);
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string( log_level => FND_LOG.level_exception,
          module    =>  g_module_prefix || l_api_name,
          message   =>  'Exception occured while calling OKC_TERMS_UTIL_GRP.GET_CONTRACT_SOURCE_CODE function :'
          || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;
    END IF;
    RAISE;
END isAttachedDocument;

/* =============================================================================
 * FUNCTION  : GET_LEGAL_ENTITY_ID PUBLIC
 * PARAMETERS:
 *             p_ORG_ID  IN NUMBER - The OU OR ORG-ID FOR CURRENT AUCTION/BID
 * RETURNS   : LEGAL_ENTITY_ID for the corresponding org
 * DESCRIPTION: Since the XLE schema has changed, we have introduced this new
 * 		wrapper function to retrieve the legal_entity_id for a org_id
 *
 * ===========================================================================*/

FUNCTION GET_LEGAL_ENTITY_ID(p_org_id 	IN	NUMBER) RETURN NUMBER IS

l_api_name 	  	CONSTANT 	VARCHAR2(30) := 'GET_LEGAL_ENTITY_ID';
l_legal_entity_id	NUMBER;

BEGIN

    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'BEGIN: p_org_id = ' || p_org_id);
	END IF;
    END IF;

    l_legal_entity_id :=  xle_utilities_grp.get_defaultlegalcontext_ou(p_org_id);


    IF (g_fnd_debug = 'Y') THEN
	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	    FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			    module    => g_module_prefix || l_api_name,
			    message   => 'END: p_org_id = ' || p_org_id || ' l_legal_entity_id = ' || l_legal_entity_id);
	END IF;
    END IF;

    return l_legal_entity_id;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_fnd_debug = 'Y') THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string( log_level => FND_LOG.level_exception,
          module    =>  g_module_prefix || l_api_name,
          message   =>  'Exception occured while calling xle_utilities_grp get_defaultlegalcontext_ou function with input org-id as :'
		|| p_org_id
          	|| ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
      END IF;
    END IF;
    RAISE;
END GET_LEGAL_ENTITY_ID;

 --bug 7592494, added fucntion to get the legal enity associated with an OU.

 /* =============================================================================
 * FUNCTION  : GET_LEGAL_ENTITY_NAME PUBLIC
 * PARAMETERS:
 *             p_ORG_ID  IN NUMBER - The OU OR ORG-ID FOR CURRENT AUCTION/BID
 * RETURNS   : LEGAL_ENTITY_NAME for the corresponding org
 *
 * ===========================================================================*/

 FUNCTION GET_LEGAL_ENTITY_NAME(p_org_id IN      NUMBER) RETURN VARCHAR2 IS

 l_api_name                CONSTANT         VARCHAR2(30) := 'GET_LEGAL_ENTITY_NAME';
 x_return_status       VARCHAR2(2);
 x_msg_data         VARCHAR2(100);
 x_msg_count NUMBER;

 LegalEntity_Rec  XLE_UTILITIES_GRP.LegalEntity_Rec;
 l_legal_entity_name VARCHAR2(200);

 BEGIN

     IF (g_fnd_debug = 'Y') THEN
	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	     FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			     module    => g_module_prefix || l_api_name,
			     message   => 'BEGIN: p_org_id = ' || p_org_id);
	 END IF;
     END IF;

    --call to XLE API to get the legal entity info.
    XLE_UTILITIES_GRP.Get_LegalEntity_Info (x_return_status,
					    x_msg_count,
					    x_msg_data,
					    NULL,
					    XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_org_id),
					    LegalEntity_Rec);

    l_legal_entity_name := LegalEntity_Rec.NAME;

    IF (g_fnd_debug = 'Y') THEN
	 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.g_current_runtime_level) THEN
	     FND_LOG.string( log_level => FND_LOG.LEVEL_PROCEDURE,
			     module    => g_module_prefix || l_api_name,
			     message   => 'END: p_org_id = ' || p_org_id || ' legal_entity_name = ' || l_legal_entity_name);
	 END IF;
     END IF;

     return l_legal_entity_name;

 EXCEPTION
   WHEN OTHERS THEN
     IF (g_fnd_debug = 'Y') THEN
       IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
	 FND_LOG.string( log_level => FND_LOG.level_exception,
	   module    =>  g_module_prefix || l_api_name,
	   message   =>  'Exception occured while calling xle_utilities_grp get_defaultlegalcontext_ou function with input org-id as :'
		 || p_org_id
		 || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
       END IF;
     END IF;
     RAISE;
 END GET_LEGAL_ENTITY_NAME;


END PON_CONTERMS_UTL_PVT;

/
