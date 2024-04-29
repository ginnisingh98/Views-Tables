--------------------------------------------------------
--  DDL for Package Body OKL_VP_STS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_STS_PUB_W" as
  /* $Header: OKLUSSCB.pls 120.2 2005/08/04 03:07:35 manumanu noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy okl_vp_sts_pub.vp_sts_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).status := a0(indx);
          t(ddindx).status_code := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_vp_sts_pub.vp_sts_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).status;
          a1(indx) := t(ddindx).status_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_listof_new_statuses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_ste_code  VARCHAR2
    , p_sts_code  VARCHAR2
    , p_start_date  DATE
    , p_end_date  DATE
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_sts_tbl okl_vp_sts_pub.sts_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okl_vp_sts_pub.get_listof_new_statuses(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_ste_code,
      p_sts_code,
      p_start_date,
      p_end_date,
      ddx_sts_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okl_vp_sts_pvt_w.rosetta_table_copy_out_p1(ddx_sts_tbl, p9_a0
      , p9_a1
      );
  end;

end okl_vp_sts_pub_w;

/
