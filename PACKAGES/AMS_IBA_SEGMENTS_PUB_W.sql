--------------------------------------------------------
--  DDL for Package AMS_IBA_SEGMENTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_SEGMENTS_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ibatsegs.pls 115.3 2000/03/07 13:53:05 pkm ship      $ */

  procedure rosetta_table_copy_in_p1(t out ams_mkt_segments_pvt.partymktsegtabtyp, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_out_p1(t ams_mkt_segments_pvt.partymktsegtabtyp, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    );

  procedure get_mkt_segments_w(p_party_id  NUMBER
    , p_target_segment_id  NUMBER
    , p2_a0 out JTF_NUMBER_TABLE
    , p2_a1 out JTF_NUMBER_TABLE
  );
end ams_iba_segments_pub_w;

 

/
