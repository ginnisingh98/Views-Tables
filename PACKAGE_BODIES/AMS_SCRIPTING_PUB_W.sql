--------------------------------------------------------
--  DDL for Package Body AMS_SCRIPTING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_SCRIPTING_PUB_W" as
  /* $Header: amswscrb.pls 115.4 2002/12/27 15:48:06 mayjain noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy ams_scripting_pub.ams_party_tbl_type, a0 JTF_VARCHAR2_TABLE_400
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_2000
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
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).organization := a0(indx);
          t(ddindx).country := a1(indx);
          t(ddindx).address1 := a2(indx);
          t(ddindx).address2 := a3(indx);
          t(ddindx).address3 := a4(indx);
          t(ddindx).address4 := a5(indx);
          t(ddindx).city := a6(indx);
          t(ddindx).county := a7(indx);
          t(ddindx).state := a8(indx);
          t(ddindx).postal_code := a9(indx);
          t(ddindx).firstname := a10(indx);
          t(ddindx).middlename := a11(indx);
          t(ddindx).lastname := a12(indx);
          t(ddindx).email := a13(indx);
          t(ddindx).dayareacode := a14(indx);
          t(ddindx).daycountrycode := a15(indx);
          t(ddindx).daynumber := a16(indx);
          t(ddindx).dayextension := a17(indx);
          t(ddindx).eveningareacode := a18(indx);
          t(ddindx).eveningcountrycode := a19(indx);
          t(ddindx).eveningnumber := a20(indx);
          t(ddindx).eveningextension := a21(indx);
          t(ddindx).faxareacode := a22(indx);
          t(ddindx).faxcountrycode := a23(indx);
          t(ddindx).faxnumber := a24(indx);
          t(ddindx).faxextension := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_scripting_pub.ams_party_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_400
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_2000
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_VARCHAR2_TABLE_100
    , a25 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_400();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_2000();
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
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_400();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_2000();
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
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).organization;
          a1(indx) := t(ddindx).country;
          a2(indx) := t(ddindx).address1;
          a3(indx) := t(ddindx).address2;
          a4(indx) := t(ddindx).address3;
          a5(indx) := t(ddindx).address4;
          a6(indx) := t(ddindx).city;
          a7(indx) := t(ddindx).county;
          a8(indx) := t(ddindx).state;
          a9(indx) := t(ddindx).postal_code;
          a10(indx) := t(ddindx).firstname;
          a11(indx) := t(ddindx).middlename;
          a12(indx) := t(ddindx).lastname;
          a13(indx) := t(ddindx).email;
          a14(indx) := t(ddindx).dayareacode;
          a15(indx) := t(ddindx).daycountrycode;
          a16(indx) := t(ddindx).daynumber;
          a17(indx) := t(ddindx).dayextension;
          a18(indx) := t(ddindx).eveningareacode;
          a19(indx) := t(ddindx).eveningcountrycode;
          a20(indx) := t(ddindx).eveningnumber;
          a21(indx) := t(ddindx).eveningextension;
          a22(indx) := t(ddindx).faxareacode;
          a23(indx) := t(ddindx).faxcountrycode;
          a24(indx) := t(ddindx).faxnumber;
          a25(indx) := t(ddindx).faxextension;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p6(t out nocopy ams_scripting_pub.ams_person_profile_tbl_type, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).date_of_birth := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).place_of_birth := a1(indx);
          t(ddindx).gender := a2(indx);
          t(ddindx).marital_status := a3(indx);
          t(ddindx).marital_status_effective_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).personal_income := a5(indx);
          t(ddindx).head_of_household_flag := a6(indx);
          t(ddindx).household_income := a7(indx);
          t(ddindx).household_size := a8(indx);
          t(ddindx).rent_own_ind := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t ams_scripting_pub.ams_person_profile_tbl_type, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).date_of_birth;
          a1(indx) := t(ddindx).place_of_birth;
          a2(indx) := t(ddindx).gender;
          a3(indx) := t(ddindx).marital_status;
          a4(indx) := t(ddindx).marital_status_effective_date;
          a5(indx) := t(ddindx).personal_income;
          a6(indx) := t(ddindx).head_of_household_flag;
          a7(indx) := t(ddindx).household_income;
          a8(indx) := t(ddindx).household_size;
          a9(indx) := t(ddindx).rent_own_ind;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure create_customer(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_party_id in out nocopy  NUMBER
    , p_b2b_flag  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p10_a0  VARCHAR2
    , p10_a1  VARCHAR2
    , p10_a2  VARCHAR2
    , p10_a3  VARCHAR2
    , p10_a4  VARCHAR2
    , p10_a5  VARCHAR2
    , p10_a6  VARCHAR2
    , p10_a7  VARCHAR2
    , p10_a8  VARCHAR2
    , p10_a9  VARCHAR2
    , p10_a10  VARCHAR2
    , p10_a11  VARCHAR2
    , p10_a12  VARCHAR2
    , p10_a13  VARCHAR2
    , p10_a14  VARCHAR2
    , p10_a15  VARCHAR2
    , p10_a16  VARCHAR2
    , p10_a17  VARCHAR2
    , p10_a18  VARCHAR2
    , p10_a19  VARCHAR2
    , p10_a20  VARCHAR2
    , p10_a21  VARCHAR2
    , p10_a22  VARCHAR2
    , p10_a23  VARCHAR2
    , p10_a24  VARCHAR2
    , p10_a25  VARCHAR2
    , x_new_party out nocopy  VARCHAR2
    , p_component_name out nocopy  VARCHAR2
  )

  as
    ddp_ams_party_rec ams_scripting_pub.ams_party_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_ams_party_rec.organization := p10_a0;
    ddp_ams_party_rec.country := p10_a1;
    ddp_ams_party_rec.address1 := p10_a2;
    ddp_ams_party_rec.address2 := p10_a3;
    ddp_ams_party_rec.address3 := p10_a4;
    ddp_ams_party_rec.address4 := p10_a5;
    ddp_ams_party_rec.city := p10_a6;
    ddp_ams_party_rec.county := p10_a7;
    ddp_ams_party_rec.state := p10_a8;
    ddp_ams_party_rec.postal_code := p10_a9;
    ddp_ams_party_rec.firstname := p10_a10;
    ddp_ams_party_rec.middlename := p10_a11;
    ddp_ams_party_rec.lastname := p10_a12;
    ddp_ams_party_rec.email := p10_a13;
    ddp_ams_party_rec.dayareacode := p10_a14;
    ddp_ams_party_rec.daycountrycode := p10_a15;
    ddp_ams_party_rec.daynumber := p10_a16;
    ddp_ams_party_rec.dayextension := p10_a17;
    ddp_ams_party_rec.eveningareacode := p10_a18;
    ddp_ams_party_rec.eveningcountrycode := p10_a19;
    ddp_ams_party_rec.eveningnumber := p10_a20;
    ddp_ams_party_rec.eveningextension := p10_a21;
    ddp_ams_party_rec.faxareacode := p10_a22;
    ddp_ams_party_rec.faxcountrycode := p10_a23;
    ddp_ams_party_rec.faxnumber := p10_a24;
    ddp_ams_party_rec.faxextension := p10_a25;



    -- here's the delegated call to the old PL/SQL routine
    ams_scripting_pub.create_customer(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_party_id,
      p_b2b_flag,
      p_import_list_header_id,
      ddp_ams_party_rec,
      x_new_party,
      p_component_name);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure update_person_profile(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_party_id  NUMBER
    , p_profile_id in out nocopy  NUMBER
    , p9_a0  DATE
    , p9_a1  VARCHAR2
    , p9_a2  VARCHAR2
    , p9_a3  VARCHAR2
    , p9_a4  DATE
    , p9_a5  NUMBER
    , p9_a6  VARCHAR2
    , p9_a7  NUMBER
    , p9_a8  NUMBER
    , p9_a9  VARCHAR2
    , p_party_object_version_number in out nocopy  NUMBER
  )

  as
    ddp_person_profile_rec ams_scripting_pub.ams_person_profile_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_person_profile_rec.date_of_birth := rosetta_g_miss_date_in_map(p9_a0);
    ddp_person_profile_rec.place_of_birth := p9_a1;
    ddp_person_profile_rec.gender := p9_a2;
    ddp_person_profile_rec.marital_status := p9_a3;
    ddp_person_profile_rec.marital_status_effective_date := rosetta_g_miss_date_in_map(p9_a4);
    ddp_person_profile_rec.personal_income := p9_a5;
    ddp_person_profile_rec.head_of_household_flag := p9_a6;
    ddp_person_profile_rec.household_income := p9_a7;
    ddp_person_profile_rec.household_size := p9_a8;
    ddp_person_profile_rec.rent_own_ind := p9_a9;


    -- here's the delegated call to the old PL/SQL routine
    ams_scripting_pub.update_person_profile(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_party_id,
      p_profile_id,
      ddp_person_profile_rec,
      p_party_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ams_scripting_pub_w;

/
