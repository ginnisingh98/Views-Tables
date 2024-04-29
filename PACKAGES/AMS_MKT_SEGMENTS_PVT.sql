--------------------------------------------------------
--  DDL for Package AMS_MKT_SEGMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MKT_SEGMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmkts.pls 115.9 2001/12/14 16:27:28 pkm ship    $ */
  TYPE PartyMktSegRecTyp IS RECORD (
     target_segment_id ams_act_market_segments.market_segment_id%TYPE,
	 campaign_id       ams_act_market_segments.ACT_MARKET_SEGMENT_USED_BY_ID%TYPE );

  TYPE PartyMktSegTabTyp IS TABLE OF PartyMktSegRecTyp
     INDEX BY BINARY_INTEGER;

FUNCTION Get_Mkt_Segments ( p_party_id           ams_party_market_segments.party_id%TYPE := NULL,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL)
     RETURN  PartyMktSegTabTyp;

END AMS_MKT_SEGMENTS_PVT;

 

/
