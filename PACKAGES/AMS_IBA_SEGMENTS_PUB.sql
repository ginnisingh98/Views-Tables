--------------------------------------------------------
--  DDL for Package AMS_IBA_SEGMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_SEGMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: ibavsegs.pls 115.1 2000/03/07 13:53:09 pkm ship      $ */
---------------------------------------------------------------------

Procedure Get_Mkt_Segments_w ( p_party_id  ams_party_market_segments.party_id%TYPE := NULL,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL,
				    x_PartyMktSegTabTyp out AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp);

END AMS_IBA_SEGMENTS_PUB;

 

/
