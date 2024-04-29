--------------------------------------------------------
--  DDL for Package Body CSD_RO_BULLETINS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_RO_BULLETINS_PVT_W" as
  /* $Header: csdwrobb.pls 120.0 2008/02/28 04:39:26 rfieldma noship $ */
  procedure rosetta_table_copy_in_p6(t out nocopy csd_ro_bulletins_pvt.csd_ro_sc_ids_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t csd_ro_bulletins_pvt.csd_ro_sc_ids_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p9(t out nocopy csd_ro_bulletins_pvt.ro_bulletin_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ro_bulletin_id := a0(indx);
          t(ddindx).repair_line_id := a1(indx);
          t(ddindx).bulletin_id := a2(indx);
          t(ddindx).last_viewed_date := a3(indx);
          t(ddindx).last_viewed_by := a4(indx);
          t(ddindx).source_type := a5(indx);
          t(ddindx).source_id := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).created_by := a8(indx);
          t(ddindx).creation_date := a9(indx);
          t(ddindx).last_updated_by := a10(indx);
          t(ddindx).last_update_date := a11(indx);
          t(ddindx).last_update_login := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t csd_ro_bulletins_pvt.ro_bulletin_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).ro_bulletin_id;
          a1(indx) := t(ddindx).repair_line_id;
          a2(indx) := t(ddindx).bulletin_id;
          a3(indx) := t(ddindx).last_viewed_date;
          a4(indx) := t(ddindx).last_viewed_by;
          a5(indx) := t(ddindx).source_type;
          a6(indx) := t(ddindx).source_id;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).created_by;
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := t(ddindx).last_updated_by;
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := t(ddindx).last_update_login;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure create_ro_bulletin(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  DATE
    , p4_a10  NUMBER
    , p4_a11  DATE
    , p4_a12  NUMBER
    , x_ro_bulletin_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ro_bulletin_rec csd_ro_bulletins_pvt.ro_bulletin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ro_bulletin_rec.ro_bulletin_id := p4_a0;
    ddp_ro_bulletin_rec.repair_line_id := p4_a1;
    ddp_ro_bulletin_rec.bulletin_id := p4_a2;
    ddp_ro_bulletin_rec.last_viewed_date := p4_a3;
    ddp_ro_bulletin_rec.last_viewed_by := p4_a4;
    ddp_ro_bulletin_rec.source_type := p4_a5;
    ddp_ro_bulletin_rec.source_id := p4_a6;
    ddp_ro_bulletin_rec.object_version_number := p4_a7;
    ddp_ro_bulletin_rec.created_by := p4_a8;
    ddp_ro_bulletin_rec.creation_date := p4_a9;
    ddp_ro_bulletin_rec.last_updated_by := p4_a10;
    ddp_ro_bulletin_rec.last_update_date := p4_a11;
    ddp_ro_bulletin_rec.last_update_login := p4_a12;





    -- here's the delegated call to the old PL/SQL routine
    csd_ro_bulletins_pvt.create_ro_bulletin(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ro_bulletin_rec,
      x_ro_bulletin_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ro_bulletin(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  DATE
    , p4_a10  NUMBER
    , p4_a11  DATE
    , p4_a12  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ro_bulletin_rec csd_ro_bulletins_pvt.ro_bulletin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ro_bulletin_rec.ro_bulletin_id := p4_a0;
    ddp_ro_bulletin_rec.repair_line_id := p4_a1;
    ddp_ro_bulletin_rec.bulletin_id := p4_a2;
    ddp_ro_bulletin_rec.last_viewed_date := p4_a3;
    ddp_ro_bulletin_rec.last_viewed_by := p4_a4;
    ddp_ro_bulletin_rec.source_type := p4_a5;
    ddp_ro_bulletin_rec.source_id := p4_a6;
    ddp_ro_bulletin_rec.object_version_number := p4_a7;
    ddp_ro_bulletin_rec.created_by := p4_a8;
    ddp_ro_bulletin_rec.creation_date := p4_a9;
    ddp_ro_bulletin_rec.last_updated_by := p4_a10;
    ddp_ro_bulletin_rec.last_update_date := p4_a11;
    ddp_ro_bulletin_rec.last_update_login := p4_a12;




    -- here's the delegated call to the old PL/SQL routine
    csd_ro_bulletins_pvt.update_ro_bulletin(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ro_bulletin_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure lock_ro_bulletin(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  NUMBER
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  DATE
    , p4_a10  NUMBER
    , p4_a11  DATE
    , p4_a12  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ro_bulletin_rec csd_ro_bulletins_pvt.ro_bulletin_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ro_bulletin_rec.ro_bulletin_id := p4_a0;
    ddp_ro_bulletin_rec.repair_line_id := p4_a1;
    ddp_ro_bulletin_rec.bulletin_id := p4_a2;
    ddp_ro_bulletin_rec.last_viewed_date := p4_a3;
    ddp_ro_bulletin_rec.last_viewed_by := p4_a4;
    ddp_ro_bulletin_rec.source_type := p4_a5;
    ddp_ro_bulletin_rec.source_id := p4_a6;
    ddp_ro_bulletin_rec.object_version_number := p4_a7;
    ddp_ro_bulletin_rec.created_by := p4_a8;
    ddp_ro_bulletin_rec.creation_date := p4_a9;
    ddp_ro_bulletin_rec.last_updated_by := p4_a10;
    ddp_ro_bulletin_rec.last_update_date := p4_a11;
    ddp_ro_bulletin_rec.last_update_login := p4_a12;




    -- here's the delegated call to the old PL/SQL routine
    csd_ro_bulletins_pvt.lock_ro_bulletin(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ro_bulletin_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure link_bulletins_to_ro(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_repair_line_id  NUMBER
    , px_ro_sc_ids_tbl in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_ro_sc_ids_tbl csd_ro_bulletins_pvt.csd_ro_sc_ids_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    csd_ro_bulletins_pvt_w.rosetta_table_copy_in_p6(ddpx_ro_sc_ids_tbl, px_ro_sc_ids_tbl);




    -- here's the delegated call to the old PL/SQL routine
    csd_ro_bulletins_pvt.link_bulletins_to_ro(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_repair_line_id,
      ddpx_ro_sc_ids_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    csd_ro_bulletins_pvt_w.rosetta_table_copy_out_p6(ddpx_ro_sc_ids_tbl, px_ro_sc_ids_tbl);



  end;

  procedure create_new_ro_bulletin_link(p_api_version_number  NUMBER
    , p_commit  VARCHAR2
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_repair_line_id  NUMBER
    , p_bulletin_id  NUMBER
    , p_rule_id  NUMBER
    , px_ro_sc_ids_tbl in out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpx_ro_sc_ids_tbl csd_ro_bulletins_pvt.csd_ro_sc_ids_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    csd_ro_bulletins_pvt_w.rosetta_table_copy_in_p6(ddpx_ro_sc_ids_tbl, px_ro_sc_ids_tbl);




    -- here's the delegated call to the old PL/SQL routine
    csd_ro_bulletins_pvt.create_new_ro_bulletin_link(p_api_version_number,
      p_commit,
      p_init_msg_list,
      p_validation_level,
      p_repair_line_id,
      p_bulletin_id,
      p_rule_id,
      ddpx_ro_sc_ids_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    csd_ro_bulletins_pvt_w.rosetta_table_copy_out_p6(ddpx_ro_sc_ids_tbl, px_ro_sc_ids_tbl);



  end;

end csd_ro_bulletins_pvt_w;

/
