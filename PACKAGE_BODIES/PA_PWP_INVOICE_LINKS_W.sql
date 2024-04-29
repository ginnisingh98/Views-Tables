--------------------------------------------------------
--  DDL for Package Body PA_PWP_INVOICE_LINKS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PWP_INVOICE_LINKS_W" as
  /* $Header: painvlnb.pls 120.0.12010000.1 2008/11/14 13:03:37 svivaram noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy pa_pwp_invoice_links.link_tab, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).project_id := a0(indx);
          t(ddindx).draft_invoice_num := a1(indx);
          t(ddindx).ap_invoice_id := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t pa_pwp_invoice_links.link_tab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).project_id;
          a1(indx) := t(ddindx).draft_invoice_num;
          a2(indx) := t(ddindx).ap_invoice_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure del_invoice_link(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpa_link_tab pa_pwp_invoice_links.link_tab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_pwp_invoice_links_w.rosetta_table_copy_in_p1(ddpa_link_tab, p0_a0
      , p0_a1
      , p0_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    pa_pwp_invoice_links.del_invoice_link(ddpa_link_tab,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure add_invoice_link(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddpa_link_tab pa_pwp_invoice_links.link_tab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    pa_pwp_invoice_links_w.rosetta_table_copy_in_p1(ddpa_link_tab, p0_a0
      , p0_a1
      , p0_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    pa_pwp_invoice_links.add_invoice_link(ddpa_link_tab,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end pa_pwp_invoice_links_w;

/
