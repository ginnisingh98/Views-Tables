--------------------------------------------------------
--  DDL for Package Body ARW_SEARCH_CUSTOMERS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARW_SEARCH_CUSTOMERS_W" as
  /* $Header: ARWCUSWB.pls 120.0.12010000.2 2008/11/21 15:26:54 avepati noship $ */

procedure rosetta_table_copy_in_p1(t out nocopy arw_search_customers.custsite_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customerid := a0(indx);
          t(ddindx).siteuseid := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t arw_search_customers.custsite_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
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
          a0(indx) := t(ddindx).customerid;
          a1(indx) := t(ddindx).siteuseid;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure initialize_account_sites(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p_party_id  NUMBER
    , p_session_id  NUMBER
    , p_user_id  NUMBER
    , p_org_id  NUMBER
    , p_is_internal_user  VARCHAR2
  )

  as
    ddp_custsite_rec_tbl arw_search_customers.custsite_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    arw_search_customers_w.rosetta_table_copy_in_p1(ddp_custsite_rec_tbl, p0_a0
      , p0_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    arw_search_customers.initialize_account_sites(ddp_custsite_rec_tbl,
      p_party_id,
      p_session_id,
      p_user_id,
      p_org_id,
      p_is_internal_user);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
end;
end arw_search_customers_w;

/
