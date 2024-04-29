--------------------------------------------------------
--  DDL for Package HZ_IMP_ADDRESS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_ADDRESS_VAL_PKG" AUTHID CURRENT_USER as
/*$Header: ARHADRVS.pls 120.8 2005/10/30 04:16:57 appldev noship $*/

-----------------------------------------------------------------------
-- The procedure,address_validation_main will be called by
-- UI Console wrapper concurrent program for each batch.
-- This procedure will intern call address_validation_child cp
--
------------------------------------------------------------------------
 procedure address_validation_main(
 	Errbuf     	OUT NOCOPY VARCHAR2,
	Retcode    	OUT NOCOPY VARCHAR2,
	p_batch_id  	IN NUMBER);


-----------------------------------------------------------------------
-- The procedure,address_validation_child will be called by
-- address_validation_main  procedure for each batch.
-- This procedure will intern call 'oracle.apps.ar.hz.import.outboundxml'
-- event subscription.
------------------------------------------------------------------------
 procedure address_validation_child(
  	Errbuf     			OUT NOCOPY VARCHAR2,
	Retcode    			OUT NOCOPY VARCHAR2,
  	p_batch_id  			IN  NUMBER,
  	P_VAL_SUBSET_ID		 	IN  NUMBER DEFAULT NULL,
  	p_country_code    		IN  VARCHAR2 DEFAULT NULL,
  	p_module          		IN  VARCHAR2 DEFAULT NULL,
  	p_module_id       		IN  NUMBER DEFAULT NULL ,
	P_OVERWRITE_THRESHOLD   	IN  VARCHAR2 DEFAULT NULL ,
	P_ORIG_SYSTEM			IN  VARCHAR2 DEFAULT NULL,
	P_ADAPTER_ID			IN  NUMBER DEFAULT NULL);

-----------------------------------------------------------------------
-- This function will be called by update_validated_address procedure,
-- to compare the threshold and validated status code.
--
------------------------------------------------------------------------
function compare_treshhold(p_value1 varchar2, p_value2 varchar2)	return varchar2;

-----------------------------------------------------------------------
-- This procedure will be called by xml gateway through mapcode,
-- as a procedure call.
--
------------------------------------------------------------------------
Procedure update_validated_address(
  p_SITE_ORIG_SYSTEM_REFERENCE  in VARCHAR2 ,
  p_SITE_ORIG_SYSTEM	 	in VARCHAR2 ,
  p_batch_id	 		in NUMBER,
  p_Address1	 		in VARCHAR2 DEFAULT NULL,
  p_Address2	 		in VARCHAR2 DEFAULT NULL,
  p_Address3	 		in VARCHAR2 DEFAULT NULL,
  p_Address4	 		in VARCHAR2 DEFAULT NULL,
  p_city	 		in VARCHAR2 DEFAULT NULL,
  p_county	 		in VARCHAR2 DEFAULT NULL,
  p_CountrySubEntity 		in VARCHAR2 DEFAULT NULL,
  p_country	 		in VARCHAR2 DEFAULT NULL,
  p_postal_code	 		in VARCHAR2 DEFAULT NULL,
  p_status		 	in VARCHAR2 DEFAULT NULL,
  P_OVERWRITE_THRESHOLD 	in VARCHAR2 DEFAULT NULL);

-----------------------------------------------------------------------
-- Folowing Rule Function will be called from event subscription,
--'oracle.apps.ar.hz.import.outboundxml' which is raised by
-- address_validation_child Concurrent Program.
--
-- This function rule will do the following
-- 1) Get the generated xml doc by ecx_standard.generate
-- 2) Pass the xml doc to HZ_LOCATION_SERVICES_PUB.submit_addrval_doc
-- 3) Get returned validated xml doc, raise another wf event to parse
--    the validated addresses.
------------------------------------------------------------------------
function outboundxml_rule(
                        p_subscription_guid in	   raw,
                        p_event		   in out nocopy wf_event_t
                      ) return varchar2;

-----------------------------------------------------------------------
-- Folowing Rule Function will be called from event subscription,
--'oracle.apps.ar.hz.import.inboundxml' which is raised by
-- another rule function outboundxml_rule.
--
-- This function rule will process the inbound xml doc and update
-- the hz_imp_addresses_int table with validated address components.
------------------------------------------------------------------------
FUNCTION inboundxml_rule(p_subscription_guid   IN RAW,
                         p_event               in out nocopy wf_event_t
			) RETURN VARCHAR2;
end;
 

/
