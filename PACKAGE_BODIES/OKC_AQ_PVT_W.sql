--------------------------------------------------------
--  DDL for Package Body OKC_AQ_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQ_PVT_W" as
  /* $Header: okc_aq_pvt_w_b.pls 120.0 2005/05/26 09:36:50 appldev noship $ */

  procedure rosetta_table_copy_in_p1(t out nocopy okc_aq_pvt.msg_tab_typ, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := okc_aq_pvt.msg_tab_typ();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := okc_aq_pvt.msg_tab_typ();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).element_name := a0(indx);
          t(ddindx).element_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;

  procedure rosetta_table_copy_out_p1(t okc_aq_pvt.msg_tab_typ, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).element_name;
          a1(indx) := t(ddindx).element_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

end okc_aq_pvt_w;

/
