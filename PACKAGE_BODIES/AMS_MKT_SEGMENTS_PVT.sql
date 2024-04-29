--------------------------------------------------------
--  DDL for Package Body AMS_MKT_SEGMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_MKT_SEGMENTS_PVT" AS
/* $Header: amsvmktb.pls 115.9 2001/12/14 16:27:26 pkm ship    $ */
---------------------------------------------------------------------
-- function
--   Get_Mkt_Segments
--
-- HISTORY
--    10/14/99  abhola  Create.
---------------------------------------------------------------------

FUNCTION Get_Mkt_Segments ( p_party_id           ams_party_market_segments.party_id%TYPE := NULL ,
                            p_target_segment_id  ams_party_market_segments.market_segment_id%TYPE := NULL)

  RETURN  PartyMktSegTabTyp IS

  x_PartyMktSegTabTyp PartyMktSegTabTyp;
  i BINARY_INTEGER := 0;

  CURSOR c_party (c_party_id IN ams_party_market_segments.party_id%TYPE)
      IS
  SELECT a.market_segment_id, a.act_market_segment_used_by_id
    FROM ams_act_market_segments a,
	     ams_party_market_segments b
   WHERE b.party_id = c_party_id
     AND b.market_segment_id = a.market_segment_id
	 -- AND b.market_segment_flag = 'N'
	 AND a.arc_act_market_segment_used_by = 'CAMP';

  CURSOR c_target ( c_target_id IN ams_party_market_segments.market_segment_id%TYPE)
       IS
   SELECT a.market_segment_id, a.act_market_segment_used_by_id
     FROM ams_act_market_segments a
	WHERE a.market_segment_id = c_target_id
	  AND a.arc_act_market_segment_used_by = 'CAMP';

  CURSOR c_party_target ( c_party_id IN ams_party_market_segments.party_id%TYPE,
                          c_target_id IN ams_party_market_segments.market_segment_id%TYPE )
      IS
  SELECT a.market_segment_id, a.act_market_segment_used_by_id
    FROM ams_act_market_segments a,
	     ams_party_market_segments b
   WHERE b.party_id = c_party_id
     AND b.market_segment_id = c_target_id
	 AND b.market_segment_id = a.market_segment_id
	 -- AND b.market_segment_flag = 'N'
     AND a.arc_act_market_segment_used_by = 'CAMP';

  BEGIN
    if (p_party_id IS NOT NULL) AND
	   ( p_target_segment_id IS NULL ) then
      OPEN c_party (p_party_id);
	  LOOP
	     i := i + 1;
		 FETCH c_party INTO x_PartyMktSegTabTyp(i);
		 EXIT WHEN c_party%NOTFOUND;
	  END LOOP;
	  CLOSE c_party;

	  return( x_PartyMktSegTabTyp );

    elsif (p_party_id IS NULL) AND
	      (p_target_segment_id IS NOT NULL ) then

	  OPEN c_target (p_target_segment_id);
	  LOOP
	     i := i + 1;
		 FETCH c_target INTO x_PartyMktSegTabTyp(i);
		 EXIT WHEN c_target%NOTFOUND;
	  END LOOP;
	  CLOSE c_target;

	  return( x_PartyMktSegTabTyp );

	elsif (p_party_id IS NOT NULL) AND
	      (p_target_segment_id IS NOT NULL ) then
	  OPEN c_party_target (p_party_id,p_target_segment_id);
	  LOOP
	     i := i + 1;
		 FETCH c_party_target INTO x_PartyMktSegTabTyp(i);
		 EXIT WHEN c_party_target%NOTFOUND;
	  END LOOP;
	  CLOSE c_party_target;

	  return( x_PartyMktSegTabTyp );
	else
	  return( x_PartyMktSegTabTyp );
     end if;
  END Get_Mkt_Segments;

END AMS_MKT_SEGMENTS_PVT;

/
