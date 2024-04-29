--------------------------------------------------------
--  DDL for Package Body JTF_TERR_LOOKUP_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_LOOKUP_PUB_W" as
  /* $Header: jtftlkwb.pls 120.0 2005/06/02 18:21:17 appldev ship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY jtf_terr_lookup_pub.org_name_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_400
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).party_id := a0(indx);
          t(ddindx).location_id := a1(indx);
          t(ddindx).party_site_id := a2(indx);
          t(ddindx).party_site_use_id := a3(indx);
          t(ddindx).party_name := a4(indx);
          t(ddindx).address := a5(indx);
          t(ddindx).city := a6(indx);
          t(ddindx).state := a7(indx);
          t(ddindx).province := a8(indx);
          t(ddindx).postal_code := a9(indx);
          t(ddindx).area_code := a10(indx);
          t(ddindx).county := a11(indx);
          t(ddindx).country := a12(indx);
          t(ddindx).employees_total := a13(indx);
          t(ddindx).category_code := a14(indx);
          t(ddindx).sic_code := a15(indx);
          t(ddindx).primary_flag := a16(indx);
          t(ddindx).status := a17(indx);
          t(ddindx).address_type := a18(indx);
          t(ddindx).property1 := a19(indx);
          t(ddindx).property2 := a20(indx);
          t(ddindx).property3 := a21(indx);
          t(ddindx).property4 := a22(indx);
          t(ddindx).property5 := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_terr_lookup_pub.org_name_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a5 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_400();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_400();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).party_id;
          a1(indx) := t(ddindx).location_id;
          a2(indx) := t(ddindx).party_site_id;
          a3(indx) := t(ddindx).party_site_use_id;
          a4(indx) := t(ddindx).party_name;
          a5(indx) := t(ddindx).address;
          a6(indx) := t(ddindx).city;
          a7(indx) := t(ddindx).state;
          a8(indx) := t(ddindx).province;
          a9(indx) := t(ddindx).postal_code;
          a10(indx) := t(ddindx).area_code;
          a11(indx) := t(ddindx).county;
          a12(indx) := t(ddindx).country;
          a13(indx) := t(ddindx).employees_total;
          a14(indx) := t(ddindx).category_code;
          a15(indx) := t(ddindx).sic_code;
          a16(indx) := t(ddindx).primary_flag;
          a17(indx) := t(ddindx).status;
          a18(indx) := t(ddindx).address_type;
          a19(indx) := t(ddindx).property1;
          a20(indx) := t(ddindx).property2;
          a21(indx) := t(ddindx).property3;
          a22(indx) := t(ddindx).property4;
          a23(indx) := t(ddindx).property5;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY jtf_terr_lookup_pub.win_rsc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resource_id := a0(indx);
          t(ddindx).terr_id := a1(indx);
          t(ddindx).resource_name := a2(indx);
          t(ddindx).resource_phone := a3(indx);
          t(ddindx).resource_job_title := a4(indx);
          t(ddindx).resource_email := a5(indx);
          t(ddindx).resource_mgr_name := a6(indx);
          t(ddindx).resource_mgr_phone := a7(indx);
          t(ddindx).resource_mgr_email := a8(indx);
          t(ddindx).resource_property1 := a9(indx);
          t(ddindx).resource_property2 := a10(indx);
          t(ddindx).resource_property3 := a11(indx);
          t(ddindx).resource_property4 := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jtf_terr_lookup_pub.win_rsc_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a4 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a5 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a6 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resource_id;
          a1(indx) := t(ddindx).terr_id;
          a2(indx) := t(ddindx).resource_name;
          a3(indx) := t(ddindx).resource_phone;
          a4(indx) := t(ddindx).resource_job_title;
          a5(indx) := t(ddindx).resource_email;
          a6(indx) := t(ddindx).resource_mgr_name;
          a7(indx) := t(ddindx).resource_mgr_phone;
          a8(indx) := t(ddindx).resource_mgr_email;
          a9(indx) := t(ddindx).resource_property1;
          a10(indx) := t(ddindx).resource_property2;
          a11(indx) := t(ddindx).resource_property3;
          a12(indx) := t(ddindx).resource_property4;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t OUT NOCOPY jtf_terr_lookup_pub.winners_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_400
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_400
    , a14 JTF_VARCHAR2_TABLE_400
    , a15 JTF_VARCHAR2_TABLE_400
    , a16 JTF_VARCHAR2_TABLE_400
    , a17 JTF_VARCHAR2_TABLE_400
    , a18 JTF_VARCHAR2_TABLE_400
    , a19 JTF_VARCHAR2_TABLE_400
    , a20 JTF_VARCHAR2_TABLE_400
    , a21 JTF_VARCHAR2_TABLE_400
    , a22 JTF_VARCHAR2_TABLE_400
    , a23 JTF_VARCHAR2_TABLE_400
    , a24 JTF_VARCHAR2_TABLE_400
    , a25 JTF_VARCHAR2_TABLE_400
    , a26 JTF_VARCHAR2_TABLE_400
    , a27 JTF_VARCHAR2_TABLE_400
    , a28 JTF_VARCHAR2_TABLE_400
    , a29 JTF_VARCHAR2_TABLE_400
    , a30 JTF_VARCHAR2_TABLE_400
    , a31 JTF_VARCHAR2_TABLE_400
    , a32 JTF_VARCHAR2_TABLE_400
    , a33 JTF_VARCHAR2_TABLE_400
    , a34 JTF_VARCHAR2_TABLE_400
    , a35 JTF_VARCHAR2_TABLE_400
    , a36 JTF_VARCHAR2_TABLE_400
    , a37 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).use_type := a0(indx);
          t(ddindx).source_id := a1(indx);
          t(ddindx).transaction_id := a2(indx);
          t(ddindx).trans_object_id := a3(indx);
          t(ddindx).trans_detail_object_id := a4(indx);
          t(ddindx).terr_id := a5(indx);
          t(ddindx).terr_rsc_id := a6(indx);
          t(ddindx).terr_name := a7(indx);
          t(ddindx).top_level_terr_id := a8(indx);
          t(ddindx).absolute_rank := a9(indx);
          t(ddindx).resource_id := a10(indx);
          t(ddindx).resource_type := a11(indx);
          t(ddindx).group_id := a12(indx);
          t(ddindx).role := a13(indx);
          t(ddindx).full_access_flag := a14(indx);
          t(ddindx).primary_contact_flag := a15(indx);
          t(ddindx).resource_name := a16(indx);
          t(ddindx).resource_job_title := a17(indx);
          t(ddindx).resource_phone := a18(indx);
          t(ddindx).resource_email := a19(indx);
          t(ddindx).resource_mgr_name := a20(indx);
          t(ddindx).resource_mgr_phone := a21(indx);
          t(ddindx).resource_mgr_email := a22(indx);
          t(ddindx).property1 := a23(indx);
          t(ddindx).property2 := a24(indx);
          t(ddindx).property3 := a25(indx);
          t(ddindx).property4 := a26(indx);
          t(ddindx).property5 := a27(indx);
          t(ddindx).property6 := a28(indx);
          t(ddindx).property7 := a29(indx);
          t(ddindx).property8 := a30(indx);
          t(ddindx).property9 := a31(indx);
          t(ddindx).property10 := a32(indx);
          t(ddindx).property11 := a33(indx);
          t(ddindx).property12 := a34(indx);
          t(ddindx).property13 := a35(indx);
          t(ddindx).property14 := a36(indx);
          t(ddindx).property15 := a37(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t jtf_terr_lookup_pub.winners_tbl_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a17 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a26 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a27 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a28 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a29 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a30 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a31 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a32 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a33 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a34 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a35 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a36 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_400();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_400();
    a14 := JTF_VARCHAR2_TABLE_400();
    a15 := JTF_VARCHAR2_TABLE_400();
    a16 := JTF_VARCHAR2_TABLE_400();
    a17 := JTF_VARCHAR2_TABLE_400();
    a18 := JTF_VARCHAR2_TABLE_400();
    a19 := JTF_VARCHAR2_TABLE_400();
    a20 := JTF_VARCHAR2_TABLE_400();
    a21 := JTF_VARCHAR2_TABLE_400();
    a22 := JTF_VARCHAR2_TABLE_400();
    a23 := JTF_VARCHAR2_TABLE_400();
    a24 := JTF_VARCHAR2_TABLE_400();
    a25 := JTF_VARCHAR2_TABLE_400();
    a26 := JTF_VARCHAR2_TABLE_400();
    a27 := JTF_VARCHAR2_TABLE_400();
    a28 := JTF_VARCHAR2_TABLE_400();
    a29 := JTF_VARCHAR2_TABLE_400();
    a30 := JTF_VARCHAR2_TABLE_400();
    a31 := JTF_VARCHAR2_TABLE_400();
    a32 := JTF_VARCHAR2_TABLE_400();
    a33 := JTF_VARCHAR2_TABLE_400();
    a34 := JTF_VARCHAR2_TABLE_400();
    a35 := JTF_VARCHAR2_TABLE_400();
    a36 := JTF_VARCHAR2_TABLE_400();
    a37 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_400();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_400();
      a14 := JTF_VARCHAR2_TABLE_400();
      a15 := JTF_VARCHAR2_TABLE_400();
      a16 := JTF_VARCHAR2_TABLE_400();
      a17 := JTF_VARCHAR2_TABLE_400();
      a18 := JTF_VARCHAR2_TABLE_400();
      a19 := JTF_VARCHAR2_TABLE_400();
      a20 := JTF_VARCHAR2_TABLE_400();
      a21 := JTF_VARCHAR2_TABLE_400();
      a22 := JTF_VARCHAR2_TABLE_400();
      a23 := JTF_VARCHAR2_TABLE_400();
      a24 := JTF_VARCHAR2_TABLE_400();
      a25 := JTF_VARCHAR2_TABLE_400();
      a26 := JTF_VARCHAR2_TABLE_400();
      a27 := JTF_VARCHAR2_TABLE_400();
      a28 := JTF_VARCHAR2_TABLE_400();
      a29 := JTF_VARCHAR2_TABLE_400();
      a30 := JTF_VARCHAR2_TABLE_400();
      a31 := JTF_VARCHAR2_TABLE_400();
      a32 := JTF_VARCHAR2_TABLE_400();
      a33 := JTF_VARCHAR2_TABLE_400();
      a34 := JTF_VARCHAR2_TABLE_400();
      a35 := JTF_VARCHAR2_TABLE_400();
      a36 := JTF_VARCHAR2_TABLE_400();
      a37 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        a10.extend(t.count);
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).use_type;
          a1(indx) := t(ddindx).source_id;
          a2(indx) := t(ddindx).transaction_id;
          a3(indx) := t(ddindx).trans_object_id;
          a4(indx) := t(ddindx).trans_detail_object_id;
          a5(indx) := t(ddindx).terr_id;
          a6(indx) := t(ddindx).terr_rsc_id;
          a7(indx) := t(ddindx).terr_name;
          a8(indx) := t(ddindx).top_level_terr_id;
          a9(indx) := t(ddindx).absolute_rank;
          a10(indx) := t(ddindx).resource_id;
          a11(indx) := t(ddindx).resource_type;
          a12(indx) := t(ddindx).group_id;
          a13(indx) := t(ddindx).role;
          a14(indx) := t(ddindx).full_access_flag;
          a15(indx) := t(ddindx).primary_contact_flag;
          a16(indx) := t(ddindx).resource_name;
          a17(indx) := t(ddindx).resource_job_title;
          a18(indx) := t(ddindx).resource_phone;
          a19(indx) := t(ddindx).resource_email;
          a20(indx) := t(ddindx).resource_mgr_name;
          a21(indx) := t(ddindx).resource_mgr_phone;
          a22(indx) := t(ddindx).resource_mgr_email;
          a23(indx) := t(ddindx).property1;
          a24(indx) := t(ddindx).property2;
          a25(indx) := t(ddindx).property3;
          a26(indx) := t(ddindx).property4;
          a27(indx) := t(ddindx).property5;
          a28(indx) := t(ddindx).property6;
          a29(indx) := t(ddindx).property7;
          a30(indx) := t(ddindx).property8;
          a31(indx) := t(ddindx).property9;
          a32(indx) := t(ddindx).property10;
          a33(indx) := t(ddindx).property11;
          a34(indx) := t(ddindx).property12;
          a35(indx) := t(ddindx).property13;
          a36(indx) := t(ddindx).property14;
          a37(indx) := t(ddindx).property15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure get_org_contacts(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_search_name  VARCHAR2
    , p_state  VARCHAR2
    , p_country  VARCHAR2
    , p_postal_code  VARCHAR2
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , x_total_rows OUT NOCOPY  NUMBER
    , p22_a0 OUT NOCOPY JTF_NUMBER_TABLE
    , p22_a1 OUT NOCOPY JTF_NUMBER_TABLE
    , p22_a2 OUT NOCOPY JTF_NUMBER_TABLE
    , p22_a3 OUT NOCOPY JTF_NUMBER_TABLE
    , p22_a4 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p22_a5 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , p22_a6 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a13 OUT NOCOPY JTF_NUMBER_TABLE
    , p22_a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a15 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a17 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p22_a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
  )
  as
    ddx_result_tbl jtf_terr_lookup_pub.org_name_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT NOCOPY args, if any























    -- here's the delegated call to the old PL/SQL routine
    jtf_terr_lookup_pub.get_org_contacts(p_range_low,
      p_range_high,
      p_search_name,
      p_state,
      p_country,
      p_postal_code,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      x_total_rows,
      ddx_result_tbl);

    -- copy data back from the local OUT NOCOPY or IN-OUT NOCOPY args, if any






















    jtf_terr_lookup_pub_w.rosetta_table_copy_out_p3(ddx_result_tbl, p22_a0
      , p22_a1
      , p22_a2
      , p22_a3
      , p22_a4
      , p22_a5
      , p22_a6
      , p22_a7
      , p22_a8
      , p22_a9
      , p22_a10
      , p22_a11
      , p22_a12
      , p22_a13
      , p22_a14
      , p22_a15
      , p22_a16
      , p22_a17
      , p22_a18
      , p22_a19
      , p22_a20
      , p22_a21
      , p22_a22
      , p22_a23
      );
  end;

  procedure get_winners(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0  VARCHAR2
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  VARCHAR2
    , p2_a6  VARCHAR2
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  VARCHAR2
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  VARCHAR2
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  VARCHAR2
    , p2_a51  VARCHAR2
    , p2_a52  VARCHAR2
    , p2_a53  VARCHAR2
    , p2_a54  VARCHAR2
    , p2_a55  NUMBER
    , p2_a56  NUMBER
    , p2_a57  NUMBER
    , p2_a58  NUMBER
    , p2_a59  NUMBER
    , p2_a60  NUMBER
    , p2_a61  NUMBER
    , p2_a62  NUMBER
    , p2_a63  NUMBER
    , p2_a64  NUMBER
    , p2_a65  NUMBER
    , p2_a66  NUMBER
    , p2_a67  NUMBER
    , p2_a68  NUMBER
    , p2_a69  NUMBER
    , p2_a70  NUMBER
    , p2_a71  NUMBER
    , p2_a72  NUMBER
    , p2_a73  NUMBER
    , p2_a74  NUMBER
    , p2_a75  NUMBER
    , p2_a76  NUMBER
    , p2_a77  NUMBER
    , p2_a78  NUMBER
    , p2_a79  NUMBER
    , p2_a80  NUMBER
    , p2_a81  NUMBER
    , p2_a82  NUMBER
    , p2_a83  NUMBER
    , p2_a84  NUMBER
    , p2_a85  NUMBER
    , p2_a86  NUMBER
    , p2_a87  NUMBER
    , p2_a88  NUMBER
    , p2_a89  NUMBER
    , p2_a90  NUMBER
    , p2_a91  NUMBER
    , p2_a92  NUMBER
    , p2_a93  NUMBER
    , p2_a94  NUMBER
    , p2_a95  NUMBER
    , p2_a96  NUMBER
    , p2_a97  NUMBER
    , p2_a98  NUMBER
    , p2_a99  NUMBER
    , p2_a100  NUMBER
    , p2_a101  NUMBER
    , p2_a102  NUMBER
    , p2_a103  NUMBER
    , p2_a104  NUMBER
    , p_source_id  NUMBER
    , p_trans_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_role  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p10_a0 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , p10_a1 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a2 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a3 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a4 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a5 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a6 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a7 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a8 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a9 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a10 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a11 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a12 OUT NOCOPY JTF_NUMBER_TABLE
    , p10_a13 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a14 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a15 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a16 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a17 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a18 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a19 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a20 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a21 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a22 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a23 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a24 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a25 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a26 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a27 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a28 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a29 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a30 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a31 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a32 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a33 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a34 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a35 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a36 OUT NOCOPY JTF_VARCHAR2_TABLE_400
    , p10_a37 OUT NOCOPY JTF_VARCHAR2_TABLE_400
  )
  as
    ddp_trans_rec jtf_terr_lookup_pub.trans_rec_type;
    ddx_winners_tbl jtf_terr_lookup_pub.winners_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT NOCOPY args, if any


    ddp_trans_rec.use_type := p2_a0;
    ddp_trans_rec.source_id := p2_a1;
    ddp_trans_rec.transaction_id := p2_a2;
    ddp_trans_rec.trans_object_id := p2_a3;
    ddp_trans_rec.trans_detail_object_id := p2_a4;
    ddp_trans_rec.squal_char01 := p2_a5;
    ddp_trans_rec.squal_char02 := p2_a6;
    ddp_trans_rec.squal_char03 := p2_a7;
    ddp_trans_rec.squal_char04 := p2_a8;
    ddp_trans_rec.squal_char05 := p2_a9;
    ddp_trans_rec.squal_char06 := p2_a10;
    ddp_trans_rec.squal_char07 := p2_a11;
    ddp_trans_rec.squal_char08 := p2_a12;
    ddp_trans_rec.squal_char09 := p2_a13;
    ddp_trans_rec.squal_char10 := p2_a14;
    ddp_trans_rec.squal_char11 := p2_a15;
    ddp_trans_rec.squal_char12 := p2_a16;
    ddp_trans_rec.squal_char13 := p2_a17;
    ddp_trans_rec.squal_char14 := p2_a18;
    ddp_trans_rec.squal_char15 := p2_a19;
    ddp_trans_rec.squal_char16 := p2_a20;
    ddp_trans_rec.squal_char17 := p2_a21;
    ddp_trans_rec.squal_char18 := p2_a22;
    ddp_trans_rec.squal_char19 := p2_a23;
    ddp_trans_rec.squal_char20 := p2_a24;
    ddp_trans_rec.squal_char21 := p2_a25;
    ddp_trans_rec.squal_char22 := p2_a26;
    ddp_trans_rec.squal_char23 := p2_a27;
    ddp_trans_rec.squal_char24 := p2_a28;
    ddp_trans_rec.squal_char25 := p2_a29;
    ddp_trans_rec.squal_char26 := p2_a30;
    ddp_trans_rec.squal_char27 := p2_a31;
    ddp_trans_rec.squal_char28 := p2_a32;
    ddp_trans_rec.squal_char29 := p2_a33;
    ddp_trans_rec.squal_char30 := p2_a34;
    ddp_trans_rec.squal_char31 := p2_a35;
    ddp_trans_rec.squal_char32 := p2_a36;
    ddp_trans_rec.squal_char33 := p2_a37;
    ddp_trans_rec.squal_char34 := p2_a38;
    ddp_trans_rec.squal_char35 := p2_a39;
    ddp_trans_rec.squal_char36 := p2_a40;
    ddp_trans_rec.squal_char37 := p2_a41;
    ddp_trans_rec.squal_char38 := p2_a42;
    ddp_trans_rec.squal_char39 := p2_a43;
    ddp_trans_rec.squal_char40 := p2_a44;
    ddp_trans_rec.squal_char41 := p2_a45;
    ddp_trans_rec.squal_char42 := p2_a46;
    ddp_trans_rec.squal_char43 := p2_a47;
    ddp_trans_rec.squal_char44 := p2_a48;
    ddp_trans_rec.squal_char45 := p2_a49;
    ddp_trans_rec.squal_char46 := p2_a50;
    ddp_trans_rec.squal_char47 := p2_a51;
    ddp_trans_rec.squal_char48 := p2_a52;
    ddp_trans_rec.squal_char49 := p2_a53;
    ddp_trans_rec.squal_char50 := p2_a54;
    ddp_trans_rec.squal_num01 := p2_a55;
    ddp_trans_rec.squal_num02 := p2_a56;
    ddp_trans_rec.squal_num03 := p2_a57;
    ddp_trans_rec.squal_num04 := p2_a58;
    ddp_trans_rec.squal_num05 := p2_a59;
    ddp_trans_rec.squal_num06 := p2_a60;
    ddp_trans_rec.squal_num07 := p2_a61;
    ddp_trans_rec.squal_num08 := p2_a62;
    ddp_trans_rec.squal_num09 := p2_a63;
    ddp_trans_rec.squal_num10 := p2_a64;
    ddp_trans_rec.squal_num11 := p2_a65;
    ddp_trans_rec.squal_num12 := p2_a66;
    ddp_trans_rec.squal_num13 := p2_a67;
    ddp_trans_rec.squal_num14 := p2_a68;
    ddp_trans_rec.squal_num15 := p2_a69;
    ddp_trans_rec.squal_num16 := p2_a70;
    ddp_trans_rec.squal_num17 := p2_a71;
    ddp_trans_rec.squal_num18 := p2_a72;
    ddp_trans_rec.squal_num19 := p2_a73;
    ddp_trans_rec.squal_num20 := p2_a74;
    ddp_trans_rec.squal_num21 := p2_a75;
    ddp_trans_rec.squal_num22 := p2_a76;
    ddp_trans_rec.squal_num23 := p2_a77;
    ddp_trans_rec.squal_num24 := p2_a78;
    ddp_trans_rec.squal_num25 := p2_a79;
    ddp_trans_rec.squal_num26 := p2_a80;
    ddp_trans_rec.squal_num27 := p2_a81;
    ddp_trans_rec.squal_num28 := p2_a82;
    ddp_trans_rec.squal_num29 := p2_a83;
    ddp_trans_rec.squal_num30 := p2_a84;
    ddp_trans_rec.squal_num31 := p2_a85;
    ddp_trans_rec.squal_num32 := p2_a86;
    ddp_trans_rec.squal_num33 := p2_a87;
    ddp_trans_rec.squal_num34 := p2_a88;
    ddp_trans_rec.squal_num35 := p2_a89;
    ddp_trans_rec.squal_num36 := p2_a90;
    ddp_trans_rec.squal_num37 := p2_a91;
    ddp_trans_rec.squal_num38 := p2_a92;
    ddp_trans_rec.squal_num39 := p2_a93;
    ddp_trans_rec.squal_num40 := p2_a94;
    ddp_trans_rec.squal_num41 := p2_a95;
    ddp_trans_rec.squal_num42 := p2_a96;
    ddp_trans_rec.squal_num43 := p2_a97;
    ddp_trans_rec.squal_num44 := p2_a98;
    ddp_trans_rec.squal_num45 := p2_a99;
    ddp_trans_rec.squal_num46 := p2_a100;
    ddp_trans_rec.squal_num47 := p2_a101;
    ddp_trans_rec.squal_num48 := p2_a102;
    ddp_trans_rec.squal_num49 := p2_a103;
    ddp_trans_rec.squal_num50 := p2_a104;









    -- here's the delegated call to the old PL/SQL routine
    jtf_terr_lookup_pub.get_winners(p_api_version_number,
      p_init_msg_list,
      ddp_trans_rec,
      p_source_id,
      p_trans_id,
      p_resource_type,
      p_role,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_winners_tbl);

    -- copy data back from the local OUT NOCOPY or IN-OUT NOCOPY args, if any










    jtf_terr_lookup_pub_w.rosetta_table_copy_out_p7(ddx_winners_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      );
  end;

end jtf_terr_lookup_pub_w;


/
