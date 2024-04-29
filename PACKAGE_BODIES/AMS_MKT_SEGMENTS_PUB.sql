--------------------------------------------------------
--  DDL for Package Body AMS_MKT_SEGMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MKT_SEGMENTS_PUB" AS
/* $Header: amspmktb.pls 115.5 2000/01/09 18:02:58 pkm ship   $ */

g_pkg_name  CONSTANT VARCHAR2(30):='AMS_MKT_SEGMENTS_PUB';
---------------------------------------------------------------------
-- function
--   Get_Mkt_Segments
--
-- HISTORY
--    10/14/99  abhola  Create.
---------------------------------------------------------------------

FUNCTION Get_Mkt_Segments ( p_party_id           ams_party_market_segments.party_id%TYPE := NULL ,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL)

  RETURN  AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp IS

  x_PartyMktSegTabTyp AMS_MKT_SEGMENTS_PVT.PartyMktSegTabTyp;


BEGIN

     x_PartyMktSegTabTyp := AMS_MKT_SEGMENTS_PVT.Get_Mkt_Segments( p_party_id => p_party_id,
	                                                               p_target_segment_id => p_target_segment_id);

	 RETURN ( x_PartyMktSegTabTyp);
END ;

END AMS_MKT_SEGMENTS_PUB;

/
