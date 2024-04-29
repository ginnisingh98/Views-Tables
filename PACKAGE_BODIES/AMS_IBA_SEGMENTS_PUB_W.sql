--------------------------------------------------------
--  DDL for Package Body AMS_IBA_SEGMENTS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_SEGMENTS_PUB_W" as
  /* $Header: ibatsegb.pls 115.3 2000/03/07 13:53:02 pkm ship      $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out ams_mkt_segments_pvt.partymktsegtabtyp, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).target_segment_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).campaign_id := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_mkt_segments_pvt.partymktsegtabtyp, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).target_segment_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).campaign_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;
  procedure get_mkt_segments_w(p_party_id  NUMBER
    , p_target_segment_id  NUMBER
    , p2_a0 out JTF_NUMBER_TABLE
    , p2_a1 out JTF_NUMBER_TABLE
  )
  as
    ddp_segtabtyp ams_mkt_segments_pvt.partymktsegtabtyp;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    ams_iba_segments_pub.get_mkt_segments_w(p_party_id,
      p_target_segment_id,
      ddp_segtabtyp);

    -- copy data back from the local OUT or IN-OUT args, if any


    rosetta_table_copy_out_p1(ddp_segtabtyp, p2_a0
      , p2_a1
      );
  end;

end ams_iba_segments_pub_w;

/
