--------------------------------------------------------
--  DDL for Package Body AST_AMS_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_AMS_SOURCE_PKG" AS
/* $Header: astmsrcb.pls 115.2 2002/02/05 18:03:48 pkm ship      $ */
-- Start of Comments
-- Package name     : ast_ams_source_pkg
-- Purpose          : Function to provide source code name in AST_AMS_SOURCE_CODES_V view
-- History          :
-- NOTE             :
-- End of Comments
function fetch_source_code_name (
	p_source_code_type IN VARCHAR2,
	p_source_code IN VARCHAR2)
	return VARCHAR2
	is

	cursor c_campaign(a_source_code VARCHAR2)
	is
	    SELECT campaign_name
	    FROM AMS_CAMPAIGNS_VL
	    WHERE source_code=a_source_code;

	cursor c_campaign_sched(a_source_code VARCHAR2)
	is
		SELECT schedule_name
		FROM AMS_CAMPAIGN_SCHEDULES_VL
	     WHERE source_code=a_source_code;

	CURSOR c_event_hdr(a_source_code VARCHAR2)
	is
		SELECT event_header_name
		FROM AMS_EVENT_HEADERS_VL
		WHERE source_code=a_source_code;

     CURSOR c_event_ofr(a_source_code VARCHAR2)
	is
		SELECT event_offer_name
		FROM AMS_EVENT_OFFERS_VL
		WHERE source_code=a_source_code;

	l_source_code_name                      VARCHAR2(240);

BEGIN
   IF (p_source_code_type='CAMP') THEN
   	OPEN c_campaign(p_source_code);
     FETCH c_campaign INTO l_source_code_name;
     CLOSE c_campaign;
   ELSIF (p_source_code_type='CSCH') THEN
	OPEN c_campaign_sched(p_source_code);
	FETCH c_campaign_sched INTO l_source_code_name;
	CLOSE c_campaign_sched;
   ELSIF (p_source_code_type='EVEH') THEN
   	OPEN c_event_hdr(p_source_code);
     FETCH c_event_hdr INTO l_source_code_name;
     CLOSE c_event_hdr;
   ELSIF (p_source_code_type='EVEO') THEN
   	OPEN c_event_ofr(p_source_code);
     FETCH c_event_ofr INTO l_source_code_name;
     CLOSE c_event_ofr;
  END IF;
RETURN l_source_code_name;
END fetch_source_code_name;
END ast_ams_source_pkg;

/
