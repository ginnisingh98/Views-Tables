--------------------------------------------------------
--  DDL for Package Body OKL_INV_FORMAT_DELETE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INV_FORMAT_DELETE_PVT_W" as
  /* $Header: OKLEIFDB.pls 120.1 2005/07/11 12:50:11 dkagrawa noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy okl_inv_format_delete_pvt.inf_del_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).ilt_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).name := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).contract_level_yn := a4(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_inv_format_delete_pvt.inf_del_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).ilt_id);
          a2(indx) := t(ddindx).name;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).contract_level_yn;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure delete_format(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
  )

  as
    ddp_inf_del_rec okl_inv_format_delete_pvt.inf_del_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_inf_del_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_inf_del_rec.ilt_id := rosetta_g_miss_num_map(p5_a1);
    ddp_inf_del_rec.name := p5_a2;
    ddp_inf_del_rec.description := p5_a3;
    ddp_inf_del_rec.contract_level_yn := p5_a4;
    ddp_inf_del_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_inf_del_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);

    -- here's the delegated call to the old PL/SQL routine
    okl_inv_format_delete_pvt.delete_format(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_inf_del_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_format(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_200
    , p5_a3 JTF_VARCHAR2_TABLE_2000
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_DATE_TABLE
  )

  as
    ddp_inf_del_tbl okl_inv_format_delete_pvt.inf_del_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_inv_format_delete_pvt_w.rosetta_table_copy_in_p1(ddp_inf_del_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_inv_format_delete_pvt.delete_format(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_inf_del_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_inv_format_delete_pvt_w;

/
