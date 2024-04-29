--------------------------------------------------------
--  DDL for Package Body PAAP_PWP_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAAP_PWP_PKG_W" as
  /* $Header: parlhldb.pls 120.0.12010000.2 2009/07/21 14:33:51 anuragar noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy paap_pwp_pkg.invoiceid, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t paap_pwp_pkg.invoiceid, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure paap_release_hold(p_inv_tbl JTF_NUMBER_TABLE
    , p_rel_option  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_inv_tbl paap_pwp_pkg.invoiceid;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    paap_pwp_pkg_w.rosetta_table_copy_in_p0(ddp_inv_tbl, p_inv_tbl);




    -- here's the delegated call to the old PL/SQL routine
    paap_pwp_pkg.paap_release_hold(ddp_inv_tbl,
      p_rel_option,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure paap_apply_hold(p_inv_tbl JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_inv_tbl paap_pwp_pkg.invoiceid;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    paap_pwp_pkg_w.rosetta_table_copy_in_p0(ddp_inv_tbl, p_inv_tbl);




    -- here's the delegated call to the old PL/SQL routine
    paap_pwp_pkg.paap_apply_hold(ddp_inv_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end paap_pwp_pkg_w;

/
