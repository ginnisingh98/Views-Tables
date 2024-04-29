--------------------------------------------------------
--  DDL for Package AMS_MKT_SEGMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_MKT_SEGMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: amspmkts.pls 120.0 2005/05/31 14:25:55 appldev noship $ */
---------------------------------------------------------------------

FUNCTION Get_Mkt_Segments ( p_party_id           ams_party_market_segments.party_id%TYPE := NULL,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL)
 RETURN  AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp;

END AMS_MKT_SEGMENTS_PUB;

 

/
