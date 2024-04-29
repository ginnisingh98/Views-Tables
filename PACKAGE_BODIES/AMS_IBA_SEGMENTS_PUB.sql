--------------------------------------------------------
--  DDL for Package Body AMS_IBA_SEGMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_SEGMENTS_PUB" AS
/* $Header: ibavsegb.pls 115.1 2000/03/07 13:53:07 pkm ship      $ */

g_pkg_name  CONSTANT VARCHAR2(30):='AMS_IBA_SEGMENTS_PUB';
---------------------------------------------------------------------
-- function
--   Get_Mkt_Segments_W
--
-- HISTORY
--    01/16/00  ryedator  Create.
---------------------------------------------------------------------

PROCEDURE Get_Mkt_Segments_W ( p_party_id  ams_party_market_segments.party_id%TYPE := NULL ,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL,
				x_PartyMktSegTabTyp OUT AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp) IS
--  RETURN  AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp IS

--  x_PartyMktSegTabTyp AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp;


BEGIN

     x_PartyMktSegTabTyp := AMS_MKT_SEGMENTS_PUB.Get_Mkt_Segments( p_party_id => p_party_id,
	                                                               p_target_segment_id => p_target_segment_id);

--	 RETURN ( x_PartyMktSegTabTyp);
END ;

END AMS_IBA_SEGMENTS_PUB;

/
