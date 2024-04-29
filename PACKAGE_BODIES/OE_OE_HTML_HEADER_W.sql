--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_HEADER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_HEADER_W" as
  /* $Header: ONTRHDRB.pls 120.0 2005/06/01 00:25:16 appldev noship $ */
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

  procedure rosetta_table_copy_in_p0(t out NOCOPY /* file.sql.39 change */ oe_oe_html_header.number_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t oe_oe_html_header.number_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_oe_html_header.varchar2_tbl_type, a0 JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t oe_oe_html_header.varchar2_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
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
  end rosetta_table_copy_out_p1;

  procedure default_attributes(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p4_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_transaction_phase_code  VARCHAR2
  )

  as
    ddx_header_rec oe_order_pub.header_rec_type;
    ddx_header_val_rec oe_order_pub.header_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddx_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddx_header_rec.agreement_id := rosetta_g_miss_num_map(p3_a1);
    ddx_header_rec.attribute1 := p3_a2;
    ddx_header_rec.attribute10 := p3_a3;
    ddx_header_rec.attribute11 := p3_a4;
    ddx_header_rec.attribute12 := p3_a5;
    ddx_header_rec.attribute13 := p3_a6;
    ddx_header_rec.attribute14 := p3_a7;
    ddx_header_rec.attribute15 := p3_a8;
    ddx_header_rec.attribute16 := p3_a9;
    ddx_header_rec.attribute17 := p3_a10;
    ddx_header_rec.attribute18 := p3_a11;
    ddx_header_rec.attribute19 := p3_a12;
    ddx_header_rec.attribute2 := p3_a13;
    ddx_header_rec.attribute20 := p3_a14;
    ddx_header_rec.attribute3 := p3_a15;
    ddx_header_rec.attribute4 := p3_a16;
    ddx_header_rec.attribute5 := p3_a17;
    ddx_header_rec.attribute6 := p3_a18;
    ddx_header_rec.attribute7 := p3_a19;
    ddx_header_rec.attribute8 := p3_a20;
    ddx_header_rec.attribute9 := p3_a21;
    ddx_header_rec.booked_flag := p3_a22;
    ddx_header_rec.cancelled_flag := p3_a23;
    ddx_header_rec.context := p3_a24;
    ddx_header_rec.conversion_rate := rosetta_g_miss_num_map(p3_a25);
    ddx_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p3_a26);
    ddx_header_rec.conversion_type_code := p3_a27;
    ddx_header_rec.customer_preference_set_code := p3_a28;
    ddx_header_rec.created_by := rosetta_g_miss_num_map(p3_a29);
    ddx_header_rec.creation_date := rosetta_g_miss_date_in_map(p3_a30);
    ddx_header_rec.cust_po_number := p3_a31;
    ddx_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p3_a32);
    ddx_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p3_a33);
    ddx_header_rec.demand_class_code := p3_a34;
    ddx_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p3_a35);
    ddx_header_rec.expiration_date := rosetta_g_miss_date_in_map(p3_a36);
    ddx_header_rec.fob_point_code := p3_a37;
    ddx_header_rec.freight_carrier_code := p3_a38;
    ddx_header_rec.freight_terms_code := p3_a39;
    ddx_header_rec.global_attribute1 := p3_a40;
    ddx_header_rec.global_attribute10 := p3_a41;
    ddx_header_rec.global_attribute11 := p3_a42;
    ddx_header_rec.global_attribute12 := p3_a43;
    ddx_header_rec.global_attribute13 := p3_a44;
    ddx_header_rec.global_attribute14 := p3_a45;
    ddx_header_rec.global_attribute15 := p3_a46;
    ddx_header_rec.global_attribute16 := p3_a47;
    ddx_header_rec.global_attribute17 := p3_a48;
    ddx_header_rec.global_attribute18 := p3_a49;
    ddx_header_rec.global_attribute19 := p3_a50;
    ddx_header_rec.global_attribute2 := p3_a51;
    ddx_header_rec.global_attribute20 := p3_a52;
    ddx_header_rec.global_attribute3 := p3_a53;
    ddx_header_rec.global_attribute4 := p3_a54;
    ddx_header_rec.global_attribute5 := p3_a55;
    ddx_header_rec.global_attribute6 := p3_a56;
    ddx_header_rec.global_attribute7 := p3_a57;
    ddx_header_rec.global_attribute8 := p3_a58;
    ddx_header_rec.global_attribute9 := p3_a59;
    ddx_header_rec.global_attribute_category := p3_a60;
    ddx_header_rec.tp_context := p3_a61;
    ddx_header_rec.tp_attribute1 := p3_a62;
    ddx_header_rec.tp_attribute2 := p3_a63;
    ddx_header_rec.tp_attribute3 := p3_a64;
    ddx_header_rec.tp_attribute4 := p3_a65;
    ddx_header_rec.tp_attribute5 := p3_a66;
    ddx_header_rec.tp_attribute6 := p3_a67;
    ddx_header_rec.tp_attribute7 := p3_a68;
    ddx_header_rec.tp_attribute8 := p3_a69;
    ddx_header_rec.tp_attribute9 := p3_a70;
    ddx_header_rec.tp_attribute10 := p3_a71;
    ddx_header_rec.tp_attribute11 := p3_a72;
    ddx_header_rec.tp_attribute12 := p3_a73;
    ddx_header_rec.tp_attribute13 := p3_a74;
    ddx_header_rec.tp_attribute14 := p3_a75;
    ddx_header_rec.tp_attribute15 := p3_a76;
    ddx_header_rec.header_id := rosetta_g_miss_num_map(p3_a77);
    ddx_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p3_a78);
    ddx_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p3_a79);
    ddx_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p3_a80);
    ddx_header_rec.last_updated_by := rosetta_g_miss_num_map(p3_a81);
    ddx_header_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a82);
    ddx_header_rec.last_update_login := rosetta_g_miss_num_map(p3_a83);
    ddx_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p3_a84);
    ddx_header_rec.open_flag := p3_a85;
    ddx_header_rec.order_category_code := p3_a86;
    ddx_header_rec.ordered_date := rosetta_g_miss_date_in_map(p3_a87);
    ddx_header_rec.order_date_type_code := p3_a88;
    ddx_header_rec.order_number := rosetta_g_miss_num_map(p3_a89);
    ddx_header_rec.order_source_id := rosetta_g_miss_num_map(p3_a90);
    ddx_header_rec.order_type_id := rosetta_g_miss_num_map(p3_a91);
    ddx_header_rec.org_id := rosetta_g_miss_num_map(p3_a92);
    ddx_header_rec.orig_sys_document_ref := p3_a93;
    ddx_header_rec.partial_shipments_allowed := p3_a94;
    ddx_header_rec.payment_term_id := rosetta_g_miss_num_map(p3_a95);
    ddx_header_rec.price_list_id := rosetta_g_miss_num_map(p3_a96);
    ddx_header_rec.price_request_code := p3_a97;
    ddx_header_rec.pricing_date := rosetta_g_miss_date_in_map(p3_a98);
    ddx_header_rec.program_application_id := rosetta_g_miss_num_map(p3_a99);
    ddx_header_rec.program_id := rosetta_g_miss_num_map(p3_a100);
    ddx_header_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a101);
    ddx_header_rec.request_date := rosetta_g_miss_date_in_map(p3_a102);
    ddx_header_rec.request_id := rosetta_g_miss_num_map(p3_a103);
    ddx_header_rec.return_reason_code := p3_a104;
    ddx_header_rec.salesrep_id := rosetta_g_miss_num_map(p3_a105);
    ddx_header_rec.sales_channel_code := p3_a106;
    ddx_header_rec.shipment_priority_code := p3_a107;
    ddx_header_rec.shipping_method_code := p3_a108;
    ddx_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p3_a109);
    ddx_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p3_a110);
    ddx_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p3_a111);
    ddx_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p3_a112);
    ddx_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p3_a113);
    ddx_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p3_a114);
    ddx_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p3_a115);
    ddx_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p3_a116);
    ddx_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p3_a117);
    ddx_header_rec.source_document_id := rosetta_g_miss_num_map(p3_a118);
    ddx_header_rec.source_document_type_id := rosetta_g_miss_num_map(p3_a119);
    ddx_header_rec.tax_exempt_flag := p3_a120;
    ddx_header_rec.tax_exempt_number := p3_a121;
    ddx_header_rec.tax_exempt_reason_code := p3_a122;
    ddx_header_rec.tax_point_code := p3_a123;
    ddx_header_rec.transactional_curr_code := p3_a124;
    ddx_header_rec.version_number := rosetta_g_miss_num_map(p3_a125);
    ddx_header_rec.return_status := p3_a126;
    ddx_header_rec.db_flag := p3_a127;
    ddx_header_rec.operation := p3_a128;
    ddx_header_rec.first_ack_code := p3_a129;
    ddx_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p3_a130);
    ddx_header_rec.last_ack_code := p3_a131;
    ddx_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p3_a132);
    ddx_header_rec.change_reason := p3_a133;
    ddx_header_rec.change_comments := p3_a134;
    ddx_header_rec.change_sequence := p3_a135;
    ddx_header_rec.change_request_code := p3_a136;
    ddx_header_rec.ready_flag := p3_a137;
    ddx_header_rec.status_flag := p3_a138;
    ddx_header_rec.force_apply_flag := p3_a139;
    ddx_header_rec.drop_ship_flag := p3_a140;
    ddx_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p3_a141);
    ddx_header_rec.payment_type_code := p3_a142;
    ddx_header_rec.payment_amount := rosetta_g_miss_num_map(p3_a143);
    ddx_header_rec.check_number := p3_a144;
    ddx_header_rec.credit_card_code := p3_a145;
    ddx_header_rec.credit_card_holder_name := p3_a146;
    ddx_header_rec.credit_card_number := p3_a147;
    ddx_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p3_a148);
    ddx_header_rec.credit_card_approval_code := p3_a149;
    ddx_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p3_a150);
    ddx_header_rec.shipping_instructions := p3_a151;
    ddx_header_rec.packing_instructions := p3_a152;
    ddx_header_rec.flow_status_code := p3_a153;
    ddx_header_rec.booked_date := rosetta_g_miss_date_in_map(p3_a154);
    ddx_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p3_a155);
    ddx_header_rec.upgraded_flag := p3_a156;
    ddx_header_rec.lock_control := rosetta_g_miss_num_map(p3_a157);
    ddx_header_rec.ship_to_edi_location_code := p3_a158;
    ddx_header_rec.sold_to_edi_location_code := p3_a159;
    ddx_header_rec.bill_to_edi_location_code := p3_a160;
    ddx_header_rec.ship_from_edi_location_code := p3_a161;
    ddx_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p3_a162);
    ddx_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p3_a163);
    ddx_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p3_a164);
    ddx_header_rec.invoice_address_id := rosetta_g_miss_num_map(p3_a165);
    ddx_header_rec.ship_to_address_code := p3_a166;
    ddx_header_rec.xml_message_id := rosetta_g_miss_num_map(p3_a167);
    ddx_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p3_a168);
    ddx_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p3_a169);
    ddx_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p3_a170);
    ddx_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p3_a171);
    ddx_header_rec.xml_transaction_type_code := p3_a172;
    ddx_header_rec.blanket_number := rosetta_g_miss_num_map(p3_a173);
    ddx_header_rec.line_set_name := p3_a174;
    ddx_header_rec.fulfillment_set_name := p3_a175;
    ddx_header_rec.default_fulfillment_set := p3_a176;
    ddx_header_rec.quote_date := rosetta_g_miss_date_in_map(p3_a177);
    ddx_header_rec.quote_number := rosetta_g_miss_num_map(p3_a178);
    ddx_header_rec.sales_document_name := p3_a179;
    ddx_header_rec.transaction_phase_code := p3_a180;
    ddx_header_rec.user_status_code := p3_a181;
    ddx_header_rec.draft_submitted_flag := p3_a182;
    ddx_header_rec.source_document_version_number := rosetta_g_miss_num_map(p3_a183);
    ddx_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p3_a184);
    ddx_header_rec.minisite_id := rosetta_g_miss_num_map(p3_a185);
    ddx_header_rec.ib_owner := p3_a186;
    ddx_header_rec.ib_installed_at_location := p3_a187;
    ddx_header_rec.ib_current_location := p3_a188;
    ddx_header_rec.end_customer_id := rosetta_g_miss_num_map(p3_a189);
    ddx_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p3_a190);
    ddx_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p3_a191);
    ddx_header_rec.supplier_signature := p3_a192;
    ddx_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p3_a193);
    ddx_header_rec.customer_signature := p3_a194;
    ddx_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p3_a195);
    ddx_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p3_a196);
    ddx_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p3_a197);
    ddx_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p3_a198);
    ddx_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p3_a199);
    ddx_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p3_a200);
    ddx_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p3_a201);
    ddx_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p3_a202);
    ddx_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p3_a203);
    ddx_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p3_a204);
    ddx_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p3_a205);
    ddx_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p3_a206);
    ddx_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p3_a207);
    ddx_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p3_a208);
    ddx_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p3_a209);
    ddx_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p3_a210);
    ddx_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p3_a211);
    ddx_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p3_a212);
    ddx_header_rec.contract_template_id := rosetta_g_miss_num_map(p3_a213);
    ddx_header_rec.contract_source_doc_type_code := p3_a214;
    ddx_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p3_a215);

    ddx_header_val_rec.accounting_rule := p4_a0;
    ddx_header_val_rec.agreement := p4_a1;
    ddx_header_val_rec.conversion_type := p4_a2;
    ddx_header_val_rec.deliver_to_address1 := p4_a3;
    ddx_header_val_rec.deliver_to_address2 := p4_a4;
    ddx_header_val_rec.deliver_to_address3 := p4_a5;
    ddx_header_val_rec.deliver_to_address4 := p4_a6;
    ddx_header_val_rec.deliver_to_contact := p4_a7;
    ddx_header_val_rec.deliver_to_location := p4_a8;
    ddx_header_val_rec.deliver_to_org := p4_a9;
    ddx_header_val_rec.deliver_to_state := p4_a10;
    ddx_header_val_rec.deliver_to_city := p4_a11;
    ddx_header_val_rec.deliver_to_zip := p4_a12;
    ddx_header_val_rec.deliver_to_country := p4_a13;
    ddx_header_val_rec.deliver_to_county := p4_a14;
    ddx_header_val_rec.deliver_to_province := p4_a15;
    ddx_header_val_rec.demand_class := p4_a16;
    ddx_header_val_rec.fob_point := p4_a17;
    ddx_header_val_rec.freight_terms := p4_a18;
    ddx_header_val_rec.invoice_to_address1 := p4_a19;
    ddx_header_val_rec.invoice_to_address2 := p4_a20;
    ddx_header_val_rec.invoice_to_address3 := p4_a21;
    ddx_header_val_rec.invoice_to_address4 := p4_a22;
    ddx_header_val_rec.invoice_to_state := p4_a23;
    ddx_header_val_rec.invoice_to_city := p4_a24;
    ddx_header_val_rec.invoice_to_zip := p4_a25;
    ddx_header_val_rec.invoice_to_country := p4_a26;
    ddx_header_val_rec.invoice_to_county := p4_a27;
    ddx_header_val_rec.invoice_to_province := p4_a28;
    ddx_header_val_rec.invoice_to_contact := p4_a29;
    ddx_header_val_rec.invoice_to_contact_first_name := p4_a30;
    ddx_header_val_rec.invoice_to_contact_last_name := p4_a31;
    ddx_header_val_rec.invoice_to_location := p4_a32;
    ddx_header_val_rec.invoice_to_org := p4_a33;
    ddx_header_val_rec.invoicing_rule := p4_a34;
    ddx_header_val_rec.order_source := p4_a35;
    ddx_header_val_rec.order_type := p4_a36;
    ddx_header_val_rec.payment_term := p4_a37;
    ddx_header_val_rec.price_list := p4_a38;
    ddx_header_val_rec.return_reason := p4_a39;
    ddx_header_val_rec.salesrep := p4_a40;
    ddx_header_val_rec.shipment_priority := p4_a41;
    ddx_header_val_rec.ship_from_address1 := p4_a42;
    ddx_header_val_rec.ship_from_address2 := p4_a43;
    ddx_header_val_rec.ship_from_address3 := p4_a44;
    ddx_header_val_rec.ship_from_address4 := p4_a45;
    ddx_header_val_rec.ship_from_location := p4_a46;
    ddx_header_val_rec.ship_from_city := p4_a47;
    ddx_header_val_rec.ship_from_postal_code := p4_a48;
    ddx_header_val_rec.ship_from_country := p4_a49;
    ddx_header_val_rec.ship_from_region1 := p4_a50;
    ddx_header_val_rec.ship_from_region2 := p4_a51;
    ddx_header_val_rec.ship_from_region3 := p4_a52;
    ddx_header_val_rec.ship_from_org := p4_a53;
    ddx_header_val_rec.sold_to_address1 := p4_a54;
    ddx_header_val_rec.sold_to_address2 := p4_a55;
    ddx_header_val_rec.sold_to_address3 := p4_a56;
    ddx_header_val_rec.sold_to_address4 := p4_a57;
    ddx_header_val_rec.sold_to_state := p4_a58;
    ddx_header_val_rec.sold_to_country := p4_a59;
    ddx_header_val_rec.sold_to_zip := p4_a60;
    ddx_header_val_rec.sold_to_county := p4_a61;
    ddx_header_val_rec.sold_to_province := p4_a62;
    ddx_header_val_rec.sold_to_city := p4_a63;
    ddx_header_val_rec.sold_to_contact_last_name := p4_a64;
    ddx_header_val_rec.sold_to_contact_first_name := p4_a65;
    ddx_header_val_rec.ship_to_address1 := p4_a66;
    ddx_header_val_rec.ship_to_address2 := p4_a67;
    ddx_header_val_rec.ship_to_address3 := p4_a68;
    ddx_header_val_rec.ship_to_address4 := p4_a69;
    ddx_header_val_rec.ship_to_state := p4_a70;
    ddx_header_val_rec.ship_to_country := p4_a71;
    ddx_header_val_rec.ship_to_zip := p4_a72;
    ddx_header_val_rec.ship_to_county := p4_a73;
    ddx_header_val_rec.ship_to_province := p4_a74;
    ddx_header_val_rec.ship_to_city := p4_a75;
    ddx_header_val_rec.ship_to_contact := p4_a76;
    ddx_header_val_rec.ship_to_contact_last_name := p4_a77;
    ddx_header_val_rec.ship_to_contact_first_name := p4_a78;
    ddx_header_val_rec.ship_to_location := p4_a79;
    ddx_header_val_rec.ship_to_org := p4_a80;
    ddx_header_val_rec.sold_to_contact := p4_a81;
    ddx_header_val_rec.sold_to_org := p4_a82;
    ddx_header_val_rec.sold_from_org := p4_a83;
    ddx_header_val_rec.tax_exempt := p4_a84;
    ddx_header_val_rec.tax_exempt_reason := p4_a85;
    ddx_header_val_rec.tax_point := p4_a86;
    ddx_header_val_rec.customer_payment_term := p4_a87;
    ddx_header_val_rec.payment_type := p4_a88;
    ddx_header_val_rec.credit_card := p4_a89;
    ddx_header_val_rec.status := p4_a90;
    ddx_header_val_rec.freight_carrier := p4_a91;
    ddx_header_val_rec.shipping_method := p4_a92;
    ddx_header_val_rec.order_date_type := p4_a93;
    ddx_header_val_rec.customer_number := p4_a94;
    ddx_header_val_rec.ship_to_customer_name := p4_a95;
    ddx_header_val_rec.invoice_to_customer_name := p4_a96;
    ddx_header_val_rec.sales_channel := p4_a97;
    ddx_header_val_rec.ship_to_customer_number := p4_a98;
    ddx_header_val_rec.invoice_to_customer_number := p4_a99;
    ddx_header_val_rec.ship_to_customer_id := rosetta_g_miss_num_map(p4_a100);
    ddx_header_val_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p4_a101);
    ddx_header_val_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p4_a102);
    ddx_header_val_rec.deliver_to_customer_number := p4_a103;
    ddx_header_val_rec.deliver_to_customer_name := p4_a104;
    ddx_header_val_rec.deliver_to_customer_number_oi := p4_a105;
    ddx_header_val_rec.deliver_to_customer_name_oi := p4_a106;
    ddx_header_val_rec.ship_to_customer_number_oi := p4_a107;
    ddx_header_val_rec.ship_to_customer_name_oi := p4_a108;
    ddx_header_val_rec.invoice_to_customer_number_oi := p4_a109;
    ddx_header_val_rec.invoice_to_customer_name_oi := p4_a110;
    ddx_header_val_rec.user_status := p4_a111;
    ddx_header_val_rec.transaction_phase := p4_a112;
    ddx_header_val_rec.sold_to_location_address1 := p4_a113;
    ddx_header_val_rec.sold_to_location_address2 := p4_a114;
    ddx_header_val_rec.sold_to_location_address3 := p4_a115;
    ddx_header_val_rec.sold_to_location_address4 := p4_a116;
    ddx_header_val_rec.sold_to_location := p4_a117;
    ddx_header_val_rec.sold_to_location_city := p4_a118;
    ddx_header_val_rec.sold_to_location_state := p4_a119;
    ddx_header_val_rec.sold_to_location_postal := p4_a120;
    ddx_header_val_rec.sold_to_location_country := p4_a121;
    ddx_header_val_rec.sold_to_location_county := p4_a122;
    ddx_header_val_rec.sold_to_location_province := p4_a123;
    ddx_header_val_rec.end_customer_name := p4_a124;
    ddx_header_val_rec.end_customer_number := p4_a125;
    ddx_header_val_rec.end_customer_contact := p4_a126;
    ddx_header_val_rec.end_cust_contact_last_name := p4_a127;
    ddx_header_val_rec.end_cust_contact_first_name := p4_a128;
    ddx_header_val_rec.end_customer_site_address1 := p4_a129;
    ddx_header_val_rec.end_customer_site_address2 := p4_a130;
    ddx_header_val_rec.end_customer_site_address3 := p4_a131;
    ddx_header_val_rec.end_customer_site_address4 := p4_a132;
    ddx_header_val_rec.end_customer_site_state := p4_a133;
    ddx_header_val_rec.end_customer_site_country := p4_a134;
    ddx_header_val_rec.end_customer_site_location := p4_a135;
    ddx_header_val_rec.end_customer_site_zip := p4_a136;
    ddx_header_val_rec.end_customer_site_county := p4_a137;
    ddx_header_val_rec.end_customer_site_province := p4_a138;
    ddx_header_val_rec.end_customer_site_city := p4_a139;
    ddx_header_val_rec.end_customer_site_postal_code := p4_a140;
    ddx_header_val_rec.blanket_agreement_name := p4_a141;


    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_header.default_attributes(x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_header_rec,
      ddx_header_val_rec,
      p_transaction_phase_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_id);
    p3_a1 := rosetta_g_miss_num_map(ddx_header_rec.agreement_id);
    p3_a2 := ddx_header_rec.attribute1;
    p3_a3 := ddx_header_rec.attribute10;
    p3_a4 := ddx_header_rec.attribute11;
    p3_a5 := ddx_header_rec.attribute12;
    p3_a6 := ddx_header_rec.attribute13;
    p3_a7 := ddx_header_rec.attribute14;
    p3_a8 := ddx_header_rec.attribute15;
    p3_a9 := ddx_header_rec.attribute16;
    p3_a10 := ddx_header_rec.attribute17;
    p3_a11 := ddx_header_rec.attribute18;
    p3_a12 := ddx_header_rec.attribute19;
    p3_a13 := ddx_header_rec.attribute2;
    p3_a14 := ddx_header_rec.attribute20;
    p3_a15 := ddx_header_rec.attribute3;
    p3_a16 := ddx_header_rec.attribute4;
    p3_a17 := ddx_header_rec.attribute5;
    p3_a18 := ddx_header_rec.attribute6;
    p3_a19 := ddx_header_rec.attribute7;
    p3_a20 := ddx_header_rec.attribute8;
    p3_a21 := ddx_header_rec.attribute9;
    p3_a22 := ddx_header_rec.booked_flag;
    p3_a23 := ddx_header_rec.cancelled_flag;
    p3_a24 := ddx_header_rec.context;
    p3_a25 := rosetta_g_miss_num_map(ddx_header_rec.conversion_rate);
    p3_a26 := ddx_header_rec.conversion_rate_date;
    p3_a27 := ddx_header_rec.conversion_type_code;
    p3_a28 := ddx_header_rec.customer_preference_set_code;
    p3_a29 := rosetta_g_miss_num_map(ddx_header_rec.created_by);
    p3_a30 := ddx_header_rec.creation_date;
    p3_a31 := ddx_header_rec.cust_po_number;
    p3_a32 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_contact_id);
    p3_a33 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_id);
    p3_a34 := ddx_header_rec.demand_class_code;
    p3_a35 := rosetta_g_miss_num_map(ddx_header_rec.earliest_schedule_limit);
    p3_a36 := ddx_header_rec.expiration_date;
    p3_a37 := ddx_header_rec.fob_point_code;
    p3_a38 := ddx_header_rec.freight_carrier_code;
    p3_a39 := ddx_header_rec.freight_terms_code;
    p3_a40 := ddx_header_rec.global_attribute1;
    p3_a41 := ddx_header_rec.global_attribute10;
    p3_a42 := ddx_header_rec.global_attribute11;
    p3_a43 := ddx_header_rec.global_attribute12;
    p3_a44 := ddx_header_rec.global_attribute13;
    p3_a45 := ddx_header_rec.global_attribute14;
    p3_a46 := ddx_header_rec.global_attribute15;
    p3_a47 := ddx_header_rec.global_attribute16;
    p3_a48 := ddx_header_rec.global_attribute17;
    p3_a49 := ddx_header_rec.global_attribute18;
    p3_a50 := ddx_header_rec.global_attribute19;
    p3_a51 := ddx_header_rec.global_attribute2;
    p3_a52 := ddx_header_rec.global_attribute20;
    p3_a53 := ddx_header_rec.global_attribute3;
    p3_a54 := ddx_header_rec.global_attribute4;
    p3_a55 := ddx_header_rec.global_attribute5;
    p3_a56 := ddx_header_rec.global_attribute6;
    p3_a57 := ddx_header_rec.global_attribute7;
    p3_a58 := ddx_header_rec.global_attribute8;
    p3_a59 := ddx_header_rec.global_attribute9;
    p3_a60 := ddx_header_rec.global_attribute_category;
    p3_a61 := ddx_header_rec.tp_context;
    p3_a62 := ddx_header_rec.tp_attribute1;
    p3_a63 := ddx_header_rec.tp_attribute2;
    p3_a64 := ddx_header_rec.tp_attribute3;
    p3_a65 := ddx_header_rec.tp_attribute4;
    p3_a66 := ddx_header_rec.tp_attribute5;
    p3_a67 := ddx_header_rec.tp_attribute6;
    p3_a68 := ddx_header_rec.tp_attribute7;
    p3_a69 := ddx_header_rec.tp_attribute8;
    p3_a70 := ddx_header_rec.tp_attribute9;
    p3_a71 := ddx_header_rec.tp_attribute10;
    p3_a72 := ddx_header_rec.tp_attribute11;
    p3_a73 := ddx_header_rec.tp_attribute12;
    p3_a74 := ddx_header_rec.tp_attribute13;
    p3_a75 := ddx_header_rec.tp_attribute14;
    p3_a76 := ddx_header_rec.tp_attribute15;
    p3_a77 := rosetta_g_miss_num_map(ddx_header_rec.header_id);
    p3_a78 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_contact_id);
    p3_a79 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_id);
    p3_a80 := rosetta_g_miss_num_map(ddx_header_rec.invoicing_rule_id);
    p3_a81 := rosetta_g_miss_num_map(ddx_header_rec.last_updated_by);
    p3_a82 := ddx_header_rec.last_update_date;
    p3_a83 := rosetta_g_miss_num_map(ddx_header_rec.last_update_login);
    p3_a84 := rosetta_g_miss_num_map(ddx_header_rec.latest_schedule_limit);
    p3_a85 := ddx_header_rec.open_flag;
    p3_a86 := ddx_header_rec.order_category_code;
    p3_a87 := ddx_header_rec.ordered_date;
    p3_a88 := ddx_header_rec.order_date_type_code;
    p3_a89 := rosetta_g_miss_num_map(ddx_header_rec.order_number);
    p3_a90 := rosetta_g_miss_num_map(ddx_header_rec.order_source_id);
    p3_a91 := rosetta_g_miss_num_map(ddx_header_rec.order_type_id);
    p3_a92 := rosetta_g_miss_num_map(ddx_header_rec.org_id);
    p3_a93 := ddx_header_rec.orig_sys_document_ref;
    p3_a94 := ddx_header_rec.partial_shipments_allowed;
    p3_a95 := rosetta_g_miss_num_map(ddx_header_rec.payment_term_id);
    p3_a96 := rosetta_g_miss_num_map(ddx_header_rec.price_list_id);
    p3_a97 := ddx_header_rec.price_request_code;
    p3_a98 := ddx_header_rec.pricing_date;
    p3_a99 := rosetta_g_miss_num_map(ddx_header_rec.program_application_id);
    p3_a100 := rosetta_g_miss_num_map(ddx_header_rec.program_id);
    p3_a101 := ddx_header_rec.program_update_date;
    p3_a102 := ddx_header_rec.request_date;
    p3_a103 := rosetta_g_miss_num_map(ddx_header_rec.request_id);
    p3_a104 := ddx_header_rec.return_reason_code;
    p3_a105 := rosetta_g_miss_num_map(ddx_header_rec.salesrep_id);
    p3_a106 := ddx_header_rec.sales_channel_code;
    p3_a107 := ddx_header_rec.shipment_priority_code;
    p3_a108 := ddx_header_rec.shipping_method_code;
    p3_a109 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_org_id);
    p3_a110 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_above);
    p3_a111 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_below);
    p3_a112 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_contact_id);
    p3_a113 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_id);
    p3_a114 := rosetta_g_miss_num_map(ddx_header_rec.sold_from_org_id);
    p3_a115 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_contact_id);
    p3_a116 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_id);
    p3_a117 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_phone_id);
    p3_a118 := rosetta_g_miss_num_map(ddx_header_rec.source_document_id);
    p3_a119 := rosetta_g_miss_num_map(ddx_header_rec.source_document_type_id);
    p3_a120 := ddx_header_rec.tax_exempt_flag;
    p3_a121 := ddx_header_rec.tax_exempt_number;
    p3_a122 := ddx_header_rec.tax_exempt_reason_code;
    p3_a123 := ddx_header_rec.tax_point_code;
    p3_a124 := ddx_header_rec.transactional_curr_code;
    p3_a125 := rosetta_g_miss_num_map(ddx_header_rec.version_number);
    p3_a126 := ddx_header_rec.return_status;
    p3_a127 := ddx_header_rec.db_flag;
    p3_a128 := ddx_header_rec.operation;
    p3_a129 := ddx_header_rec.first_ack_code;
    p3_a130 := ddx_header_rec.first_ack_date;
    p3_a131 := ddx_header_rec.last_ack_code;
    p3_a132 := ddx_header_rec.last_ack_date;
    p3_a133 := ddx_header_rec.change_reason;
    p3_a134 := ddx_header_rec.change_comments;
    p3_a135 := ddx_header_rec.change_sequence;
    p3_a136 := ddx_header_rec.change_request_code;
    p3_a137 := ddx_header_rec.ready_flag;
    p3_a138 := ddx_header_rec.status_flag;
    p3_a139 := ddx_header_rec.force_apply_flag;
    p3_a140 := ddx_header_rec.drop_ship_flag;
    p3_a141 := rosetta_g_miss_num_map(ddx_header_rec.customer_payment_term_id);
    p3_a142 := ddx_header_rec.payment_type_code;
    p3_a143 := rosetta_g_miss_num_map(ddx_header_rec.payment_amount);
    p3_a144 := ddx_header_rec.check_number;
    p3_a145 := ddx_header_rec.credit_card_code;
    p3_a146 := ddx_header_rec.credit_card_holder_name;
    p3_a147 := ddx_header_rec.credit_card_number;
    p3_a148 := ddx_header_rec.credit_card_expiration_date;
    p3_a149 := ddx_header_rec.credit_card_approval_code;
    p3_a150 := ddx_header_rec.credit_card_approval_date;
    p3_a151 := ddx_header_rec.shipping_instructions;
    p3_a152 := ddx_header_rec.packing_instructions;
    p3_a153 := ddx_header_rec.flow_status_code;
    p3_a154 := ddx_header_rec.booked_date;
    p3_a155 := rosetta_g_miss_num_map(ddx_header_rec.marketing_source_code_id);
    p3_a156 := ddx_header_rec.upgraded_flag;
    p3_a157 := rosetta_g_miss_num_map(ddx_header_rec.lock_control);
    p3_a158 := ddx_header_rec.ship_to_edi_location_code;
    p3_a159 := ddx_header_rec.sold_to_edi_location_code;
    p3_a160 := ddx_header_rec.bill_to_edi_location_code;
    p3_a161 := ddx_header_rec.ship_from_edi_location_code;
    p3_a162 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_address_id);
    p3_a163 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_address_id);
    p3_a164 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_address_id);
    p3_a165 := rosetta_g_miss_num_map(ddx_header_rec.invoice_address_id);
    p3_a166 := ddx_header_rec.ship_to_address_code;
    p3_a167 := rosetta_g_miss_num_map(ddx_header_rec.xml_message_id);
    p3_a168 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_id);
    p3_a169 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_id);
    p3_a170 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_id);
    p3_a171 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_duration);
    p3_a172 := ddx_header_rec.xml_transaction_type_code;
    p3_a173 := rosetta_g_miss_num_map(ddx_header_rec.blanket_number);
    p3_a174 := ddx_header_rec.line_set_name;
    p3_a175 := ddx_header_rec.fulfillment_set_name;
    p3_a176 := ddx_header_rec.default_fulfillment_set;
    p3_a177 := ddx_header_rec.quote_date;
    p3_a178 := rosetta_g_miss_num_map(ddx_header_rec.quote_number);
    p3_a179 := ddx_header_rec.sales_document_name;
    p3_a180 := ddx_header_rec.transaction_phase_code;
    p3_a181 := ddx_header_rec.user_status_code;
    p3_a182 := ddx_header_rec.draft_submitted_flag;
    p3_a183 := rosetta_g_miss_num_map(ddx_header_rec.source_document_version_number);
    p3_a184 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_site_use_id);
    p3_a185 := rosetta_g_miss_num_map(ddx_header_rec.minisite_id);
    p3_a186 := ddx_header_rec.ib_owner;
    p3_a187 := ddx_header_rec.ib_installed_at_location;
    p3_a188 := ddx_header_rec.ib_current_location;
    p3_a189 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_id);
    p3_a190 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_contact_id);
    p3_a191 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_site_use_id);
    p3_a192 := ddx_header_rec.supplier_signature;
    p3_a193 := ddx_header_rec.supplier_signature_date;
    p3_a194 := ddx_header_rec.customer_signature;
    p3_a195 := ddx_header_rec.customer_signature_date;
    p3_a196 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_party_id);
    p3_a197 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_contact_id);
    p3_a198 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_id);
    p3_a199 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_id);
    p3_a200 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_use_id);
    p3_a201 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_id);
    p3_a202 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_id);
    p3_a203 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_use_id);
    p3_a204 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_id);
    p3_a205 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_id);
    p3_a206 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_use_id);
    p3_a207 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_party_id);
    p3_a208 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_party_id);
    p3_a209 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_party_id);
    p3_a210 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_contact_id);
    p3_a211 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_contact_id);
    p3_a212 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_contact_id);
    p3_a213 := rosetta_g_miss_num_map(ddx_header_rec.contract_template_id);
    p3_a214 := ddx_header_rec.contract_source_doc_type_code;
    p3_a215 := rosetta_g_miss_num_map(ddx_header_rec.contract_source_document_id);

    p4_a0 := ddx_header_val_rec.accounting_rule;
    p4_a1 := ddx_header_val_rec.agreement;
    p4_a2 := ddx_header_val_rec.conversion_type;
    p4_a3 := ddx_header_val_rec.deliver_to_address1;
    p4_a4 := ddx_header_val_rec.deliver_to_address2;
    p4_a5 := ddx_header_val_rec.deliver_to_address3;
    p4_a6 := ddx_header_val_rec.deliver_to_address4;
    p4_a7 := ddx_header_val_rec.deliver_to_contact;
    p4_a8 := ddx_header_val_rec.deliver_to_location;
    p4_a9 := ddx_header_val_rec.deliver_to_org;
    p4_a10 := ddx_header_val_rec.deliver_to_state;
    p4_a11 := ddx_header_val_rec.deliver_to_city;
    p4_a12 := ddx_header_val_rec.deliver_to_zip;
    p4_a13 := ddx_header_val_rec.deliver_to_country;
    p4_a14 := ddx_header_val_rec.deliver_to_county;
    p4_a15 := ddx_header_val_rec.deliver_to_province;
    p4_a16 := ddx_header_val_rec.demand_class;
    p4_a17 := ddx_header_val_rec.fob_point;
    p4_a18 := ddx_header_val_rec.freight_terms;
    p4_a19 := ddx_header_val_rec.invoice_to_address1;
    p4_a20 := ddx_header_val_rec.invoice_to_address2;
    p4_a21 := ddx_header_val_rec.invoice_to_address3;
    p4_a22 := ddx_header_val_rec.invoice_to_address4;
    p4_a23 := ddx_header_val_rec.invoice_to_state;
    p4_a24 := ddx_header_val_rec.invoice_to_city;
    p4_a25 := ddx_header_val_rec.invoice_to_zip;
    p4_a26 := ddx_header_val_rec.invoice_to_country;
    p4_a27 := ddx_header_val_rec.invoice_to_county;
    p4_a28 := ddx_header_val_rec.invoice_to_province;
    p4_a29 := ddx_header_val_rec.invoice_to_contact;
    p4_a30 := ddx_header_val_rec.invoice_to_contact_first_name;
    p4_a31 := ddx_header_val_rec.invoice_to_contact_last_name;
    p4_a32 := ddx_header_val_rec.invoice_to_location;
    p4_a33 := ddx_header_val_rec.invoice_to_org;
    p4_a34 := ddx_header_val_rec.invoicing_rule;
    p4_a35 := ddx_header_val_rec.order_source;
    p4_a36 := ddx_header_val_rec.order_type;
    p4_a37 := ddx_header_val_rec.payment_term;
    p4_a38 := ddx_header_val_rec.price_list;
    p4_a39 := ddx_header_val_rec.return_reason;
    p4_a40 := ddx_header_val_rec.salesrep;
    p4_a41 := ddx_header_val_rec.shipment_priority;
    p4_a42 := ddx_header_val_rec.ship_from_address1;
    p4_a43 := ddx_header_val_rec.ship_from_address2;
    p4_a44 := ddx_header_val_rec.ship_from_address3;
    p4_a45 := ddx_header_val_rec.ship_from_address4;
    p4_a46 := ddx_header_val_rec.ship_from_location;
    p4_a47 := ddx_header_val_rec.ship_from_city;
    p4_a48 := ddx_header_val_rec.ship_from_postal_code;
    p4_a49 := ddx_header_val_rec.ship_from_country;
    p4_a50 := ddx_header_val_rec.ship_from_region1;
    p4_a51 := ddx_header_val_rec.ship_from_region2;
    p4_a52 := ddx_header_val_rec.ship_from_region3;
    p4_a53 := ddx_header_val_rec.ship_from_org;
    p4_a54 := ddx_header_val_rec.sold_to_address1;
    p4_a55 := ddx_header_val_rec.sold_to_address2;
    p4_a56 := ddx_header_val_rec.sold_to_address3;
    p4_a57 := ddx_header_val_rec.sold_to_address4;
    p4_a58 := ddx_header_val_rec.sold_to_state;
    p4_a59 := ddx_header_val_rec.sold_to_country;
    p4_a60 := ddx_header_val_rec.sold_to_zip;
    p4_a61 := ddx_header_val_rec.sold_to_county;
    p4_a62 := ddx_header_val_rec.sold_to_province;
    p4_a63 := ddx_header_val_rec.sold_to_city;
    p4_a64 := ddx_header_val_rec.sold_to_contact_last_name;
    p4_a65 := ddx_header_val_rec.sold_to_contact_first_name;
    p4_a66 := ddx_header_val_rec.ship_to_address1;
    p4_a67 := ddx_header_val_rec.ship_to_address2;
    p4_a68 := ddx_header_val_rec.ship_to_address3;
    p4_a69 := ddx_header_val_rec.ship_to_address4;
    p4_a70 := ddx_header_val_rec.ship_to_state;
    p4_a71 := ddx_header_val_rec.ship_to_country;
    p4_a72 := ddx_header_val_rec.ship_to_zip;
    p4_a73 := ddx_header_val_rec.ship_to_county;
    p4_a74 := ddx_header_val_rec.ship_to_province;
    p4_a75 := ddx_header_val_rec.ship_to_city;
    p4_a76 := ddx_header_val_rec.ship_to_contact;
    p4_a77 := ddx_header_val_rec.ship_to_contact_last_name;
    p4_a78 := ddx_header_val_rec.ship_to_contact_first_name;
    p4_a79 := ddx_header_val_rec.ship_to_location;
    p4_a80 := ddx_header_val_rec.ship_to_org;
    p4_a81 := ddx_header_val_rec.sold_to_contact;
    p4_a82 := ddx_header_val_rec.sold_to_org;
    p4_a83 := ddx_header_val_rec.sold_from_org;
    p4_a84 := ddx_header_val_rec.tax_exempt;
    p4_a85 := ddx_header_val_rec.tax_exempt_reason;
    p4_a86 := ddx_header_val_rec.tax_point;
    p4_a87 := ddx_header_val_rec.customer_payment_term;
    p4_a88 := ddx_header_val_rec.payment_type;
    p4_a89 := ddx_header_val_rec.credit_card;
    p4_a90 := ddx_header_val_rec.status;
    p4_a91 := ddx_header_val_rec.freight_carrier;
    p4_a92 := ddx_header_val_rec.shipping_method;
    p4_a93 := ddx_header_val_rec.order_date_type;
    p4_a94 := ddx_header_val_rec.customer_number;
    p4_a95 := ddx_header_val_rec.ship_to_customer_name;
    p4_a96 := ddx_header_val_rec.invoice_to_customer_name;
    p4_a97 := ddx_header_val_rec.sales_channel;
    p4_a98 := ddx_header_val_rec.ship_to_customer_number;
    p4_a99 := ddx_header_val_rec.invoice_to_customer_number;
    p4_a100 := rosetta_g_miss_num_map(ddx_header_val_rec.ship_to_customer_id);
    p4_a101 := rosetta_g_miss_num_map(ddx_header_val_rec.invoice_to_customer_id);
    p4_a102 := rosetta_g_miss_num_map(ddx_header_val_rec.deliver_to_customer_id);
    p4_a103 := ddx_header_val_rec.deliver_to_customer_number;
    p4_a104 := ddx_header_val_rec.deliver_to_customer_name;
    p4_a105 := ddx_header_val_rec.deliver_to_customer_number_oi;
    p4_a106 := ddx_header_val_rec.deliver_to_customer_name_oi;
    p4_a107 := ddx_header_val_rec.ship_to_customer_number_oi;
    p4_a108 := ddx_header_val_rec.ship_to_customer_name_oi;
    p4_a109 := ddx_header_val_rec.invoice_to_customer_number_oi;
    p4_a110 := ddx_header_val_rec.invoice_to_customer_name_oi;
    p4_a111 := ddx_header_val_rec.user_status;
    p4_a112 := ddx_header_val_rec.transaction_phase;
    p4_a113 := ddx_header_val_rec.sold_to_location_address1;
    p4_a114 := ddx_header_val_rec.sold_to_location_address2;
    p4_a115 := ddx_header_val_rec.sold_to_location_address3;
    p4_a116 := ddx_header_val_rec.sold_to_location_address4;
    p4_a117 := ddx_header_val_rec.sold_to_location;
    p4_a118 := ddx_header_val_rec.sold_to_location_city;
    p4_a119 := ddx_header_val_rec.sold_to_location_state;
    p4_a120 := ddx_header_val_rec.sold_to_location_postal;
    p4_a121 := ddx_header_val_rec.sold_to_location_country;
    p4_a122 := ddx_header_val_rec.sold_to_location_county;
    p4_a123 := ddx_header_val_rec.sold_to_location_province;
    p4_a124 := ddx_header_val_rec.end_customer_name;
    p4_a125 := ddx_header_val_rec.end_customer_number;
    p4_a126 := ddx_header_val_rec.end_customer_contact;
    p4_a127 := ddx_header_val_rec.end_cust_contact_last_name;
    p4_a128 := ddx_header_val_rec.end_cust_contact_first_name;
    p4_a129 := ddx_header_val_rec.end_customer_site_address1;
    p4_a130 := ddx_header_val_rec.end_customer_site_address2;
    p4_a131 := ddx_header_val_rec.end_customer_site_address3;
    p4_a132 := ddx_header_val_rec.end_customer_site_address4;
    p4_a133 := ddx_header_val_rec.end_customer_site_state;
    p4_a134 := ddx_header_val_rec.end_customer_site_country;
    p4_a135 := ddx_header_val_rec.end_customer_site_location;
    p4_a136 := ddx_header_val_rec.end_customer_site_zip;
    p4_a137 := ddx_header_val_rec.end_customer_site_county;
    p4_a138 := ddx_header_val_rec.end_customer_site_province;
    p4_a139 := ddx_header_val_rec.end_customer_site_city;
    p4_a140 := ddx_header_val_rec.end_customer_site_postal_code;
    p4_a141 := ddx_header_val_rec.blanket_agreement_name;

  end;

  procedure change_attribute(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_header_id  NUMBER
    , p_attr_id  NUMBER
    , p_attr_value  VARCHAR2
    , p_attr_id_tbl JTF_NUMBER_TABLE
    , p_attr_value_tbl JTF_VARCHAR2_TABLE_2000
    , p8_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p8_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p8_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p8_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p9_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p9_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p9_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
  )

  as
    ddp_attr_id_tbl oe_oe_html_header.number_tbl_type;
    ddp_attr_value_tbl oe_oe_html_header.varchar2_tbl_type;
    ddx_header_rec oe_order_pub.header_rec_type;
    ddx_header_val_rec oe_order_pub.header_val_rec_type;
    ddx_old_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    oe_oe_html_header_w.rosetta_table_copy_in_p0(ddp_attr_id_tbl, p_attr_id_tbl);

    oe_oe_html_header_w.rosetta_table_copy_in_p1(ddp_attr_value_tbl, p_attr_value_tbl);

    ddx_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p8_a0);
    ddx_header_rec.agreement_id := rosetta_g_miss_num_map(p8_a1);
    ddx_header_rec.attribute1 := p8_a2;
    ddx_header_rec.attribute10 := p8_a3;
    ddx_header_rec.attribute11 := p8_a4;
    ddx_header_rec.attribute12 := p8_a5;
    ddx_header_rec.attribute13 := p8_a6;
    ddx_header_rec.attribute14 := p8_a7;
    ddx_header_rec.attribute15 := p8_a8;
    ddx_header_rec.attribute16 := p8_a9;
    ddx_header_rec.attribute17 := p8_a10;
    ddx_header_rec.attribute18 := p8_a11;
    ddx_header_rec.attribute19 := p8_a12;
    ddx_header_rec.attribute2 := p8_a13;
    ddx_header_rec.attribute20 := p8_a14;
    ddx_header_rec.attribute3 := p8_a15;
    ddx_header_rec.attribute4 := p8_a16;
    ddx_header_rec.attribute5 := p8_a17;
    ddx_header_rec.attribute6 := p8_a18;
    ddx_header_rec.attribute7 := p8_a19;
    ddx_header_rec.attribute8 := p8_a20;
    ddx_header_rec.attribute9 := p8_a21;
    ddx_header_rec.booked_flag := p8_a22;
    ddx_header_rec.cancelled_flag := p8_a23;
    ddx_header_rec.context := p8_a24;
    ddx_header_rec.conversion_rate := rosetta_g_miss_num_map(p8_a25);
    ddx_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p8_a26);
    ddx_header_rec.conversion_type_code := p8_a27;
    ddx_header_rec.customer_preference_set_code := p8_a28;
    ddx_header_rec.created_by := rosetta_g_miss_num_map(p8_a29);
    ddx_header_rec.creation_date := rosetta_g_miss_date_in_map(p8_a30);
    ddx_header_rec.cust_po_number := p8_a31;
    ddx_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p8_a32);
    ddx_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p8_a33);
    ddx_header_rec.demand_class_code := p8_a34;
    ddx_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p8_a35);
    ddx_header_rec.expiration_date := rosetta_g_miss_date_in_map(p8_a36);
    ddx_header_rec.fob_point_code := p8_a37;
    ddx_header_rec.freight_carrier_code := p8_a38;
    ddx_header_rec.freight_terms_code := p8_a39;
    ddx_header_rec.global_attribute1 := p8_a40;
    ddx_header_rec.global_attribute10 := p8_a41;
    ddx_header_rec.global_attribute11 := p8_a42;
    ddx_header_rec.global_attribute12 := p8_a43;
    ddx_header_rec.global_attribute13 := p8_a44;
    ddx_header_rec.global_attribute14 := p8_a45;
    ddx_header_rec.global_attribute15 := p8_a46;
    ddx_header_rec.global_attribute16 := p8_a47;
    ddx_header_rec.global_attribute17 := p8_a48;
    ddx_header_rec.global_attribute18 := p8_a49;
    ddx_header_rec.global_attribute19 := p8_a50;
    ddx_header_rec.global_attribute2 := p8_a51;
    ddx_header_rec.global_attribute20 := p8_a52;
    ddx_header_rec.global_attribute3 := p8_a53;
    ddx_header_rec.global_attribute4 := p8_a54;
    ddx_header_rec.global_attribute5 := p8_a55;
    ddx_header_rec.global_attribute6 := p8_a56;
    ddx_header_rec.global_attribute7 := p8_a57;
    ddx_header_rec.global_attribute8 := p8_a58;
    ddx_header_rec.global_attribute9 := p8_a59;
    ddx_header_rec.global_attribute_category := p8_a60;
    ddx_header_rec.tp_context := p8_a61;
    ddx_header_rec.tp_attribute1 := p8_a62;
    ddx_header_rec.tp_attribute2 := p8_a63;
    ddx_header_rec.tp_attribute3 := p8_a64;
    ddx_header_rec.tp_attribute4 := p8_a65;
    ddx_header_rec.tp_attribute5 := p8_a66;
    ddx_header_rec.tp_attribute6 := p8_a67;
    ddx_header_rec.tp_attribute7 := p8_a68;
    ddx_header_rec.tp_attribute8 := p8_a69;
    ddx_header_rec.tp_attribute9 := p8_a70;
    ddx_header_rec.tp_attribute10 := p8_a71;
    ddx_header_rec.tp_attribute11 := p8_a72;
    ddx_header_rec.tp_attribute12 := p8_a73;
    ddx_header_rec.tp_attribute13 := p8_a74;
    ddx_header_rec.tp_attribute14 := p8_a75;
    ddx_header_rec.tp_attribute15 := p8_a76;
    ddx_header_rec.header_id := rosetta_g_miss_num_map(p8_a77);
    ddx_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p8_a78);
    ddx_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p8_a79);
    ddx_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p8_a80);
    ddx_header_rec.last_updated_by := rosetta_g_miss_num_map(p8_a81);
    ddx_header_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a82);
    ddx_header_rec.last_update_login := rosetta_g_miss_num_map(p8_a83);
    ddx_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p8_a84);
    ddx_header_rec.open_flag := p8_a85;
    ddx_header_rec.order_category_code := p8_a86;
    ddx_header_rec.ordered_date := rosetta_g_miss_date_in_map(p8_a87);
    ddx_header_rec.order_date_type_code := p8_a88;
    ddx_header_rec.order_number := rosetta_g_miss_num_map(p8_a89);
    ddx_header_rec.order_source_id := rosetta_g_miss_num_map(p8_a90);
    ddx_header_rec.order_type_id := rosetta_g_miss_num_map(p8_a91);
    ddx_header_rec.org_id := rosetta_g_miss_num_map(p8_a92);
    ddx_header_rec.orig_sys_document_ref := p8_a93;
    ddx_header_rec.partial_shipments_allowed := p8_a94;
    ddx_header_rec.payment_term_id := rosetta_g_miss_num_map(p8_a95);
    ddx_header_rec.price_list_id := rosetta_g_miss_num_map(p8_a96);
    ddx_header_rec.price_request_code := p8_a97;
    ddx_header_rec.pricing_date := rosetta_g_miss_date_in_map(p8_a98);
    ddx_header_rec.program_application_id := rosetta_g_miss_num_map(p8_a99);
    ddx_header_rec.program_id := rosetta_g_miss_num_map(p8_a100);
    ddx_header_rec.program_update_date := rosetta_g_miss_date_in_map(p8_a101);
    ddx_header_rec.request_date := rosetta_g_miss_date_in_map(p8_a102);
    ddx_header_rec.request_id := rosetta_g_miss_num_map(p8_a103);
    ddx_header_rec.return_reason_code := p8_a104;
    ddx_header_rec.salesrep_id := rosetta_g_miss_num_map(p8_a105);
    ddx_header_rec.sales_channel_code := p8_a106;
    ddx_header_rec.shipment_priority_code := p8_a107;
    ddx_header_rec.shipping_method_code := p8_a108;
    ddx_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p8_a109);
    ddx_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p8_a110);
    ddx_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p8_a111);
    ddx_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p8_a112);
    ddx_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p8_a113);
    ddx_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p8_a114);
    ddx_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p8_a115);
    ddx_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p8_a116);
    ddx_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p8_a117);
    ddx_header_rec.source_document_id := rosetta_g_miss_num_map(p8_a118);
    ddx_header_rec.source_document_type_id := rosetta_g_miss_num_map(p8_a119);
    ddx_header_rec.tax_exempt_flag := p8_a120;
    ddx_header_rec.tax_exempt_number := p8_a121;
    ddx_header_rec.tax_exempt_reason_code := p8_a122;
    ddx_header_rec.tax_point_code := p8_a123;
    ddx_header_rec.transactional_curr_code := p8_a124;
    ddx_header_rec.version_number := rosetta_g_miss_num_map(p8_a125);
    ddx_header_rec.return_status := p8_a126;
    ddx_header_rec.db_flag := p8_a127;
    ddx_header_rec.operation := p8_a128;
    ddx_header_rec.first_ack_code := p8_a129;
    ddx_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p8_a130);
    ddx_header_rec.last_ack_code := p8_a131;
    ddx_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p8_a132);
    ddx_header_rec.change_reason := p8_a133;
    ddx_header_rec.change_comments := p8_a134;
    ddx_header_rec.change_sequence := p8_a135;
    ddx_header_rec.change_request_code := p8_a136;
    ddx_header_rec.ready_flag := p8_a137;
    ddx_header_rec.status_flag := p8_a138;
    ddx_header_rec.force_apply_flag := p8_a139;
    ddx_header_rec.drop_ship_flag := p8_a140;
    ddx_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p8_a141);
    ddx_header_rec.payment_type_code := p8_a142;
    ddx_header_rec.payment_amount := rosetta_g_miss_num_map(p8_a143);
    ddx_header_rec.check_number := p8_a144;
    ddx_header_rec.credit_card_code := p8_a145;
    ddx_header_rec.credit_card_holder_name := p8_a146;
    ddx_header_rec.credit_card_number := p8_a147;
    ddx_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p8_a148);
    ddx_header_rec.credit_card_approval_code := p8_a149;
    ddx_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p8_a150);
    ddx_header_rec.shipping_instructions := p8_a151;
    ddx_header_rec.packing_instructions := p8_a152;
    ddx_header_rec.flow_status_code := p8_a153;
    ddx_header_rec.booked_date := rosetta_g_miss_date_in_map(p8_a154);
    ddx_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p8_a155);
    ddx_header_rec.upgraded_flag := p8_a156;
    ddx_header_rec.lock_control := rosetta_g_miss_num_map(p8_a157);
    ddx_header_rec.ship_to_edi_location_code := p8_a158;
    ddx_header_rec.sold_to_edi_location_code := p8_a159;
    ddx_header_rec.bill_to_edi_location_code := p8_a160;
    ddx_header_rec.ship_from_edi_location_code := p8_a161;
    ddx_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p8_a162);
    ddx_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p8_a163);
    ddx_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p8_a164);
    ddx_header_rec.invoice_address_id := rosetta_g_miss_num_map(p8_a165);
    ddx_header_rec.ship_to_address_code := p8_a166;
    ddx_header_rec.xml_message_id := rosetta_g_miss_num_map(p8_a167);
    ddx_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p8_a168);
    ddx_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p8_a169);
    ddx_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p8_a170);
    ddx_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p8_a171);
    ddx_header_rec.xml_transaction_type_code := p8_a172;
    ddx_header_rec.blanket_number := rosetta_g_miss_num_map(p8_a173);
    ddx_header_rec.line_set_name := p8_a174;
    ddx_header_rec.fulfillment_set_name := p8_a175;
    ddx_header_rec.default_fulfillment_set := p8_a176;
    ddx_header_rec.quote_date := rosetta_g_miss_date_in_map(p8_a177);
    ddx_header_rec.quote_number := rosetta_g_miss_num_map(p8_a178);
    ddx_header_rec.sales_document_name := p8_a179;
    ddx_header_rec.transaction_phase_code := p8_a180;
    ddx_header_rec.user_status_code := p8_a181;
    ddx_header_rec.draft_submitted_flag := p8_a182;
    ddx_header_rec.source_document_version_number := rosetta_g_miss_num_map(p8_a183);
    ddx_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p8_a184);
    ddx_header_rec.minisite_id := rosetta_g_miss_num_map(p8_a185);
    ddx_header_rec.ib_owner := p8_a186;
    ddx_header_rec.ib_installed_at_location := p8_a187;
    ddx_header_rec.ib_current_location := p8_a188;
    ddx_header_rec.end_customer_id := rosetta_g_miss_num_map(p8_a189);
    ddx_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p8_a190);
    ddx_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p8_a191);
    ddx_header_rec.supplier_signature := p8_a192;
    ddx_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p8_a193);
    ddx_header_rec.customer_signature := p8_a194;
    ddx_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p8_a195);
    ddx_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p8_a196);
    ddx_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p8_a197);
    ddx_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p8_a198);
    ddx_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p8_a199);
    ddx_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p8_a200);
    ddx_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p8_a201);
    ddx_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p8_a202);
    ddx_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p8_a203);
    ddx_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p8_a204);
    ddx_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p8_a205);
    ddx_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p8_a206);
    ddx_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p8_a207);
    ddx_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p8_a208);
    ddx_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p8_a209);
    ddx_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p8_a210);
    ddx_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p8_a211);
    ddx_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p8_a212);
    ddx_header_rec.contract_template_id := rosetta_g_miss_num_map(p8_a213);
    ddx_header_rec.contract_source_doc_type_code := p8_a214;
    ddx_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p8_a215);

    ddx_header_val_rec.accounting_rule := p9_a0;
    ddx_header_val_rec.agreement := p9_a1;
    ddx_header_val_rec.conversion_type := p9_a2;
    ddx_header_val_rec.deliver_to_address1 := p9_a3;
    ddx_header_val_rec.deliver_to_address2 := p9_a4;
    ddx_header_val_rec.deliver_to_address3 := p9_a5;
    ddx_header_val_rec.deliver_to_address4 := p9_a6;
    ddx_header_val_rec.deliver_to_contact := p9_a7;
    ddx_header_val_rec.deliver_to_location := p9_a8;
    ddx_header_val_rec.deliver_to_org := p9_a9;
    ddx_header_val_rec.deliver_to_state := p9_a10;
    ddx_header_val_rec.deliver_to_city := p9_a11;
    ddx_header_val_rec.deliver_to_zip := p9_a12;
    ddx_header_val_rec.deliver_to_country := p9_a13;
    ddx_header_val_rec.deliver_to_county := p9_a14;
    ddx_header_val_rec.deliver_to_province := p9_a15;
    ddx_header_val_rec.demand_class := p9_a16;
    ddx_header_val_rec.fob_point := p9_a17;
    ddx_header_val_rec.freight_terms := p9_a18;
    ddx_header_val_rec.invoice_to_address1 := p9_a19;
    ddx_header_val_rec.invoice_to_address2 := p9_a20;
    ddx_header_val_rec.invoice_to_address3 := p9_a21;
    ddx_header_val_rec.invoice_to_address4 := p9_a22;
    ddx_header_val_rec.invoice_to_state := p9_a23;
    ddx_header_val_rec.invoice_to_city := p9_a24;
    ddx_header_val_rec.invoice_to_zip := p9_a25;
    ddx_header_val_rec.invoice_to_country := p9_a26;
    ddx_header_val_rec.invoice_to_county := p9_a27;
    ddx_header_val_rec.invoice_to_province := p9_a28;
    ddx_header_val_rec.invoice_to_contact := p9_a29;
    ddx_header_val_rec.invoice_to_contact_first_name := p9_a30;
    ddx_header_val_rec.invoice_to_contact_last_name := p9_a31;
    ddx_header_val_rec.invoice_to_location := p9_a32;
    ddx_header_val_rec.invoice_to_org := p9_a33;
    ddx_header_val_rec.invoicing_rule := p9_a34;
    ddx_header_val_rec.order_source := p9_a35;
    ddx_header_val_rec.order_type := p9_a36;
    ddx_header_val_rec.payment_term := p9_a37;
    ddx_header_val_rec.price_list := p9_a38;
    ddx_header_val_rec.return_reason := p9_a39;
    ddx_header_val_rec.salesrep := p9_a40;
    ddx_header_val_rec.shipment_priority := p9_a41;
    ddx_header_val_rec.ship_from_address1 := p9_a42;
    ddx_header_val_rec.ship_from_address2 := p9_a43;
    ddx_header_val_rec.ship_from_address3 := p9_a44;
    ddx_header_val_rec.ship_from_address4 := p9_a45;
    ddx_header_val_rec.ship_from_location := p9_a46;
    ddx_header_val_rec.ship_from_city := p9_a47;
    ddx_header_val_rec.ship_from_postal_code := p9_a48;
    ddx_header_val_rec.ship_from_country := p9_a49;
    ddx_header_val_rec.ship_from_region1 := p9_a50;
    ddx_header_val_rec.ship_from_region2 := p9_a51;
    ddx_header_val_rec.ship_from_region3 := p9_a52;
    ddx_header_val_rec.ship_from_org := p9_a53;
    ddx_header_val_rec.sold_to_address1 := p9_a54;
    ddx_header_val_rec.sold_to_address2 := p9_a55;
    ddx_header_val_rec.sold_to_address3 := p9_a56;
    ddx_header_val_rec.sold_to_address4 := p9_a57;
    ddx_header_val_rec.sold_to_state := p9_a58;
    ddx_header_val_rec.sold_to_country := p9_a59;
    ddx_header_val_rec.sold_to_zip := p9_a60;
    ddx_header_val_rec.sold_to_county := p9_a61;
    ddx_header_val_rec.sold_to_province := p9_a62;
    ddx_header_val_rec.sold_to_city := p9_a63;
    ddx_header_val_rec.sold_to_contact_last_name := p9_a64;
    ddx_header_val_rec.sold_to_contact_first_name := p9_a65;
    ddx_header_val_rec.ship_to_address1 := p9_a66;
    ddx_header_val_rec.ship_to_address2 := p9_a67;
    ddx_header_val_rec.ship_to_address3 := p9_a68;
    ddx_header_val_rec.ship_to_address4 := p9_a69;
    ddx_header_val_rec.ship_to_state := p9_a70;
    ddx_header_val_rec.ship_to_country := p9_a71;
    ddx_header_val_rec.ship_to_zip := p9_a72;
    ddx_header_val_rec.ship_to_county := p9_a73;
    ddx_header_val_rec.ship_to_province := p9_a74;
    ddx_header_val_rec.ship_to_city := p9_a75;
    ddx_header_val_rec.ship_to_contact := p9_a76;
    ddx_header_val_rec.ship_to_contact_last_name := p9_a77;
    ddx_header_val_rec.ship_to_contact_first_name := p9_a78;
    ddx_header_val_rec.ship_to_location := p9_a79;
    ddx_header_val_rec.ship_to_org := p9_a80;
    ddx_header_val_rec.sold_to_contact := p9_a81;
    ddx_header_val_rec.sold_to_org := p9_a82;
    ddx_header_val_rec.sold_from_org := p9_a83;
    ddx_header_val_rec.tax_exempt := p9_a84;
    ddx_header_val_rec.tax_exempt_reason := p9_a85;
    ddx_header_val_rec.tax_point := p9_a86;
    ddx_header_val_rec.customer_payment_term := p9_a87;
    ddx_header_val_rec.payment_type := p9_a88;
    ddx_header_val_rec.credit_card := p9_a89;
    ddx_header_val_rec.status := p9_a90;
    ddx_header_val_rec.freight_carrier := p9_a91;
    ddx_header_val_rec.shipping_method := p9_a92;
    ddx_header_val_rec.order_date_type := p9_a93;
    ddx_header_val_rec.customer_number := p9_a94;
    ddx_header_val_rec.ship_to_customer_name := p9_a95;
    ddx_header_val_rec.invoice_to_customer_name := p9_a96;
    ddx_header_val_rec.sales_channel := p9_a97;
    ddx_header_val_rec.ship_to_customer_number := p9_a98;
    ddx_header_val_rec.invoice_to_customer_number := p9_a99;
    ddx_header_val_rec.ship_to_customer_id := rosetta_g_miss_num_map(p9_a100);
    ddx_header_val_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p9_a101);
    ddx_header_val_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p9_a102);
    ddx_header_val_rec.deliver_to_customer_number := p9_a103;
    ddx_header_val_rec.deliver_to_customer_name := p9_a104;
    ddx_header_val_rec.deliver_to_customer_number_oi := p9_a105;
    ddx_header_val_rec.deliver_to_customer_name_oi := p9_a106;
    ddx_header_val_rec.ship_to_customer_number_oi := p9_a107;
    ddx_header_val_rec.ship_to_customer_name_oi := p9_a108;
    ddx_header_val_rec.invoice_to_customer_number_oi := p9_a109;
    ddx_header_val_rec.invoice_to_customer_name_oi := p9_a110;
    ddx_header_val_rec.user_status := p9_a111;
    ddx_header_val_rec.transaction_phase := p9_a112;
    ddx_header_val_rec.sold_to_location_address1 := p9_a113;
    ddx_header_val_rec.sold_to_location_address2 := p9_a114;
    ddx_header_val_rec.sold_to_location_address3 := p9_a115;
    ddx_header_val_rec.sold_to_location_address4 := p9_a116;
    ddx_header_val_rec.sold_to_location := p9_a117;
    ddx_header_val_rec.sold_to_location_city := p9_a118;
    ddx_header_val_rec.sold_to_location_state := p9_a119;
    ddx_header_val_rec.sold_to_location_postal := p9_a120;
    ddx_header_val_rec.sold_to_location_country := p9_a121;
    ddx_header_val_rec.sold_to_location_county := p9_a122;
    ddx_header_val_rec.sold_to_location_province := p9_a123;
    ddx_header_val_rec.end_customer_name := p9_a124;
    ddx_header_val_rec.end_customer_number := p9_a125;
    ddx_header_val_rec.end_customer_contact := p9_a126;
    ddx_header_val_rec.end_cust_contact_last_name := p9_a127;
    ddx_header_val_rec.end_cust_contact_first_name := p9_a128;
    ddx_header_val_rec.end_customer_site_address1 := p9_a129;
    ddx_header_val_rec.end_customer_site_address2 := p9_a130;
    ddx_header_val_rec.end_customer_site_address3 := p9_a131;
    ddx_header_val_rec.end_customer_site_address4 := p9_a132;
    ddx_header_val_rec.end_customer_site_state := p9_a133;
    ddx_header_val_rec.end_customer_site_country := p9_a134;
    ddx_header_val_rec.end_customer_site_location := p9_a135;
    ddx_header_val_rec.end_customer_site_zip := p9_a136;
    ddx_header_val_rec.end_customer_site_county := p9_a137;
    ddx_header_val_rec.end_customer_site_province := p9_a138;
    ddx_header_val_rec.end_customer_site_city := p9_a139;
    ddx_header_val_rec.end_customer_site_postal_code := p9_a140;
    ddx_header_val_rec.blanket_agreement_name := p9_a141;

    ddx_old_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p10_a0);
    ddx_old_header_rec.agreement_id := rosetta_g_miss_num_map(p10_a1);
    ddx_old_header_rec.attribute1 := p10_a2;
    ddx_old_header_rec.attribute10 := p10_a3;
    ddx_old_header_rec.attribute11 := p10_a4;
    ddx_old_header_rec.attribute12 := p10_a5;
    ddx_old_header_rec.attribute13 := p10_a6;
    ddx_old_header_rec.attribute14 := p10_a7;
    ddx_old_header_rec.attribute15 := p10_a8;
    ddx_old_header_rec.attribute16 := p10_a9;
    ddx_old_header_rec.attribute17 := p10_a10;
    ddx_old_header_rec.attribute18 := p10_a11;
    ddx_old_header_rec.attribute19 := p10_a12;
    ddx_old_header_rec.attribute2 := p10_a13;
    ddx_old_header_rec.attribute20 := p10_a14;
    ddx_old_header_rec.attribute3 := p10_a15;
    ddx_old_header_rec.attribute4 := p10_a16;
    ddx_old_header_rec.attribute5 := p10_a17;
    ddx_old_header_rec.attribute6 := p10_a18;
    ddx_old_header_rec.attribute7 := p10_a19;
    ddx_old_header_rec.attribute8 := p10_a20;
    ddx_old_header_rec.attribute9 := p10_a21;
    ddx_old_header_rec.booked_flag := p10_a22;
    ddx_old_header_rec.cancelled_flag := p10_a23;
    ddx_old_header_rec.context := p10_a24;
    ddx_old_header_rec.conversion_rate := rosetta_g_miss_num_map(p10_a25);
    ddx_old_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p10_a26);
    ddx_old_header_rec.conversion_type_code := p10_a27;
    ddx_old_header_rec.customer_preference_set_code := p10_a28;
    ddx_old_header_rec.created_by := rosetta_g_miss_num_map(p10_a29);
    ddx_old_header_rec.creation_date := rosetta_g_miss_date_in_map(p10_a30);
    ddx_old_header_rec.cust_po_number := p10_a31;
    ddx_old_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p10_a32);
    ddx_old_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p10_a33);
    ddx_old_header_rec.demand_class_code := p10_a34;
    ddx_old_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p10_a35);
    ddx_old_header_rec.expiration_date := rosetta_g_miss_date_in_map(p10_a36);
    ddx_old_header_rec.fob_point_code := p10_a37;
    ddx_old_header_rec.freight_carrier_code := p10_a38;
    ddx_old_header_rec.freight_terms_code := p10_a39;
    ddx_old_header_rec.global_attribute1 := p10_a40;
    ddx_old_header_rec.global_attribute10 := p10_a41;
    ddx_old_header_rec.global_attribute11 := p10_a42;
    ddx_old_header_rec.global_attribute12 := p10_a43;
    ddx_old_header_rec.global_attribute13 := p10_a44;
    ddx_old_header_rec.global_attribute14 := p10_a45;
    ddx_old_header_rec.global_attribute15 := p10_a46;
    ddx_old_header_rec.global_attribute16 := p10_a47;
    ddx_old_header_rec.global_attribute17 := p10_a48;
    ddx_old_header_rec.global_attribute18 := p10_a49;
    ddx_old_header_rec.global_attribute19 := p10_a50;
    ddx_old_header_rec.global_attribute2 := p10_a51;
    ddx_old_header_rec.global_attribute20 := p10_a52;
    ddx_old_header_rec.global_attribute3 := p10_a53;
    ddx_old_header_rec.global_attribute4 := p10_a54;
    ddx_old_header_rec.global_attribute5 := p10_a55;
    ddx_old_header_rec.global_attribute6 := p10_a56;
    ddx_old_header_rec.global_attribute7 := p10_a57;
    ddx_old_header_rec.global_attribute8 := p10_a58;
    ddx_old_header_rec.global_attribute9 := p10_a59;
    ddx_old_header_rec.global_attribute_category := p10_a60;
    ddx_old_header_rec.tp_context := p10_a61;
    ddx_old_header_rec.tp_attribute1 := p10_a62;
    ddx_old_header_rec.tp_attribute2 := p10_a63;
    ddx_old_header_rec.tp_attribute3 := p10_a64;
    ddx_old_header_rec.tp_attribute4 := p10_a65;
    ddx_old_header_rec.tp_attribute5 := p10_a66;
    ddx_old_header_rec.tp_attribute6 := p10_a67;
    ddx_old_header_rec.tp_attribute7 := p10_a68;
    ddx_old_header_rec.tp_attribute8 := p10_a69;
    ddx_old_header_rec.tp_attribute9 := p10_a70;
    ddx_old_header_rec.tp_attribute10 := p10_a71;
    ddx_old_header_rec.tp_attribute11 := p10_a72;
    ddx_old_header_rec.tp_attribute12 := p10_a73;
    ddx_old_header_rec.tp_attribute13 := p10_a74;
    ddx_old_header_rec.tp_attribute14 := p10_a75;
    ddx_old_header_rec.tp_attribute15 := p10_a76;
    ddx_old_header_rec.header_id := rosetta_g_miss_num_map(p10_a77);
    ddx_old_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p10_a78);
    ddx_old_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p10_a79);
    ddx_old_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p10_a80);
    ddx_old_header_rec.last_updated_by := rosetta_g_miss_num_map(p10_a81);
    ddx_old_header_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a82);
    ddx_old_header_rec.last_update_login := rosetta_g_miss_num_map(p10_a83);
    ddx_old_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p10_a84);
    ddx_old_header_rec.open_flag := p10_a85;
    ddx_old_header_rec.order_category_code := p10_a86;
    ddx_old_header_rec.ordered_date := rosetta_g_miss_date_in_map(p10_a87);
    ddx_old_header_rec.order_date_type_code := p10_a88;
    ddx_old_header_rec.order_number := rosetta_g_miss_num_map(p10_a89);
    ddx_old_header_rec.order_source_id := rosetta_g_miss_num_map(p10_a90);
    ddx_old_header_rec.order_type_id := rosetta_g_miss_num_map(p10_a91);
    ddx_old_header_rec.org_id := rosetta_g_miss_num_map(p10_a92);
    ddx_old_header_rec.orig_sys_document_ref := p10_a93;
    ddx_old_header_rec.partial_shipments_allowed := p10_a94;
    ddx_old_header_rec.payment_term_id := rosetta_g_miss_num_map(p10_a95);
    ddx_old_header_rec.price_list_id := rosetta_g_miss_num_map(p10_a96);
    ddx_old_header_rec.price_request_code := p10_a97;
    ddx_old_header_rec.pricing_date := rosetta_g_miss_date_in_map(p10_a98);
    ddx_old_header_rec.program_application_id := rosetta_g_miss_num_map(p10_a99);
    ddx_old_header_rec.program_id := rosetta_g_miss_num_map(p10_a100);
    ddx_old_header_rec.program_update_date := rosetta_g_miss_date_in_map(p10_a101);
    ddx_old_header_rec.request_date := rosetta_g_miss_date_in_map(p10_a102);
    ddx_old_header_rec.request_id := rosetta_g_miss_num_map(p10_a103);
    ddx_old_header_rec.return_reason_code := p10_a104;
    ddx_old_header_rec.salesrep_id := rosetta_g_miss_num_map(p10_a105);
    ddx_old_header_rec.sales_channel_code := p10_a106;
    ddx_old_header_rec.shipment_priority_code := p10_a107;
    ddx_old_header_rec.shipping_method_code := p10_a108;
    ddx_old_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p10_a109);
    ddx_old_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p10_a110);
    ddx_old_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p10_a111);
    ddx_old_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p10_a112);
    ddx_old_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p10_a113);
    ddx_old_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p10_a114);
    ddx_old_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p10_a115);
    ddx_old_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p10_a116);
    ddx_old_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p10_a117);
    ddx_old_header_rec.source_document_id := rosetta_g_miss_num_map(p10_a118);
    ddx_old_header_rec.source_document_type_id := rosetta_g_miss_num_map(p10_a119);
    ddx_old_header_rec.tax_exempt_flag := p10_a120;
    ddx_old_header_rec.tax_exempt_number := p10_a121;
    ddx_old_header_rec.tax_exempt_reason_code := p10_a122;
    ddx_old_header_rec.tax_point_code := p10_a123;
    ddx_old_header_rec.transactional_curr_code := p10_a124;
    ddx_old_header_rec.version_number := rosetta_g_miss_num_map(p10_a125);
    ddx_old_header_rec.return_status := p10_a126;
    ddx_old_header_rec.db_flag := p10_a127;
    ddx_old_header_rec.operation := p10_a128;
    ddx_old_header_rec.first_ack_code := p10_a129;
    ddx_old_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p10_a130);
    ddx_old_header_rec.last_ack_code := p10_a131;
    ddx_old_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p10_a132);
    ddx_old_header_rec.change_reason := p10_a133;
    ddx_old_header_rec.change_comments := p10_a134;
    ddx_old_header_rec.change_sequence := p10_a135;
    ddx_old_header_rec.change_request_code := p10_a136;
    ddx_old_header_rec.ready_flag := p10_a137;
    ddx_old_header_rec.status_flag := p10_a138;
    ddx_old_header_rec.force_apply_flag := p10_a139;
    ddx_old_header_rec.drop_ship_flag := p10_a140;
    ddx_old_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p10_a141);
    ddx_old_header_rec.payment_type_code := p10_a142;
    ddx_old_header_rec.payment_amount := rosetta_g_miss_num_map(p10_a143);
    ddx_old_header_rec.check_number := p10_a144;
    ddx_old_header_rec.credit_card_code := p10_a145;
    ddx_old_header_rec.credit_card_holder_name := p10_a146;
    ddx_old_header_rec.credit_card_number := p10_a147;
    ddx_old_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p10_a148);
    ddx_old_header_rec.credit_card_approval_code := p10_a149;
    ddx_old_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p10_a150);
    ddx_old_header_rec.shipping_instructions := p10_a151;
    ddx_old_header_rec.packing_instructions := p10_a152;
    ddx_old_header_rec.flow_status_code := p10_a153;
    ddx_old_header_rec.booked_date := rosetta_g_miss_date_in_map(p10_a154);
    ddx_old_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p10_a155);
    ddx_old_header_rec.upgraded_flag := p10_a156;
    ddx_old_header_rec.lock_control := rosetta_g_miss_num_map(p10_a157);
    ddx_old_header_rec.ship_to_edi_location_code := p10_a158;
    ddx_old_header_rec.sold_to_edi_location_code := p10_a159;
    ddx_old_header_rec.bill_to_edi_location_code := p10_a160;
    ddx_old_header_rec.ship_from_edi_location_code := p10_a161;
    ddx_old_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p10_a162);
    ddx_old_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p10_a163);
    ddx_old_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p10_a164);
    ddx_old_header_rec.invoice_address_id := rosetta_g_miss_num_map(p10_a165);
    ddx_old_header_rec.ship_to_address_code := p10_a166;
    ddx_old_header_rec.xml_message_id := rosetta_g_miss_num_map(p10_a167);
    ddx_old_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p10_a168);
    ddx_old_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p10_a169);
    ddx_old_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p10_a170);
    ddx_old_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p10_a171);
    ddx_old_header_rec.xml_transaction_type_code := p10_a172;
    ddx_old_header_rec.blanket_number := rosetta_g_miss_num_map(p10_a173);
    ddx_old_header_rec.line_set_name := p10_a174;
    ddx_old_header_rec.fulfillment_set_name := p10_a175;
    ddx_old_header_rec.default_fulfillment_set := p10_a176;
    ddx_old_header_rec.quote_date := rosetta_g_miss_date_in_map(p10_a177);
    ddx_old_header_rec.quote_number := rosetta_g_miss_num_map(p10_a178);
    ddx_old_header_rec.sales_document_name := p10_a179;
    ddx_old_header_rec.transaction_phase_code := p10_a180;
    ddx_old_header_rec.user_status_code := p10_a181;
    ddx_old_header_rec.draft_submitted_flag := p10_a182;
    ddx_old_header_rec.source_document_version_number := rosetta_g_miss_num_map(p10_a183);
    ddx_old_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p10_a184);
    ddx_old_header_rec.minisite_id := rosetta_g_miss_num_map(p10_a185);
    ddx_old_header_rec.ib_owner := p10_a186;
    ddx_old_header_rec.ib_installed_at_location := p10_a187;
    ddx_old_header_rec.ib_current_location := p10_a188;
    ddx_old_header_rec.end_customer_id := rosetta_g_miss_num_map(p10_a189);
    ddx_old_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p10_a190);
    ddx_old_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p10_a191);
    ddx_old_header_rec.supplier_signature := p10_a192;
    ddx_old_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p10_a193);
    ddx_old_header_rec.customer_signature := p10_a194;
    ddx_old_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p10_a195);
    ddx_old_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p10_a196);
    ddx_old_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p10_a197);
    ddx_old_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p10_a198);
    ddx_old_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p10_a199);
    ddx_old_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p10_a200);
    ddx_old_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p10_a201);
    ddx_old_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p10_a202);
    ddx_old_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p10_a203);
    ddx_old_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p10_a204);
    ddx_old_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p10_a205);
    ddx_old_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p10_a206);
    ddx_old_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p10_a207);
    ddx_old_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p10_a208);
    ddx_old_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p10_a209);
    ddx_old_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p10_a210);
    ddx_old_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p10_a211);
    ddx_old_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p10_a212);
    ddx_old_header_rec.contract_template_id := rosetta_g_miss_num_map(p10_a213);
    ddx_old_header_rec.contract_source_doc_type_code := p10_a214;
    ddx_old_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p10_a215);

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_header.change_attribute(x_return_status,
      x_msg_count,
      x_msg_data,
      p_header_id,
      p_attr_id,
      p_attr_value,
      ddp_attr_id_tbl,
      ddp_attr_value_tbl,
      ddx_header_rec,
      ddx_header_val_rec,
      ddx_old_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_id);
    p8_a1 := rosetta_g_miss_num_map(ddx_header_rec.agreement_id);
    p8_a2 := ddx_header_rec.attribute1;
    p8_a3 := ddx_header_rec.attribute10;
    p8_a4 := ddx_header_rec.attribute11;
    p8_a5 := ddx_header_rec.attribute12;
    p8_a6 := ddx_header_rec.attribute13;
    p8_a7 := ddx_header_rec.attribute14;
    p8_a8 := ddx_header_rec.attribute15;
    p8_a9 := ddx_header_rec.attribute16;
    p8_a10 := ddx_header_rec.attribute17;
    p8_a11 := ddx_header_rec.attribute18;
    p8_a12 := ddx_header_rec.attribute19;
    p8_a13 := ddx_header_rec.attribute2;
    p8_a14 := ddx_header_rec.attribute20;
    p8_a15 := ddx_header_rec.attribute3;
    p8_a16 := ddx_header_rec.attribute4;
    p8_a17 := ddx_header_rec.attribute5;
    p8_a18 := ddx_header_rec.attribute6;
    p8_a19 := ddx_header_rec.attribute7;
    p8_a20 := ddx_header_rec.attribute8;
    p8_a21 := ddx_header_rec.attribute9;
    p8_a22 := ddx_header_rec.booked_flag;
    p8_a23 := ddx_header_rec.cancelled_flag;
    p8_a24 := ddx_header_rec.context;
    p8_a25 := rosetta_g_miss_num_map(ddx_header_rec.conversion_rate);
    p8_a26 := ddx_header_rec.conversion_rate_date;
    p8_a27 := ddx_header_rec.conversion_type_code;
    p8_a28 := ddx_header_rec.customer_preference_set_code;
    p8_a29 := rosetta_g_miss_num_map(ddx_header_rec.created_by);
    p8_a30 := ddx_header_rec.creation_date;
    p8_a31 := ddx_header_rec.cust_po_number;
    p8_a32 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_contact_id);
    p8_a33 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_id);
    p8_a34 := ddx_header_rec.demand_class_code;
    p8_a35 := rosetta_g_miss_num_map(ddx_header_rec.earliest_schedule_limit);
    p8_a36 := ddx_header_rec.expiration_date;
    p8_a37 := ddx_header_rec.fob_point_code;
    p8_a38 := ddx_header_rec.freight_carrier_code;
    p8_a39 := ddx_header_rec.freight_terms_code;
    p8_a40 := ddx_header_rec.global_attribute1;
    p8_a41 := ddx_header_rec.global_attribute10;
    p8_a42 := ddx_header_rec.global_attribute11;
    p8_a43 := ddx_header_rec.global_attribute12;
    p8_a44 := ddx_header_rec.global_attribute13;
    p8_a45 := ddx_header_rec.global_attribute14;
    p8_a46 := ddx_header_rec.global_attribute15;
    p8_a47 := ddx_header_rec.global_attribute16;
    p8_a48 := ddx_header_rec.global_attribute17;
    p8_a49 := ddx_header_rec.global_attribute18;
    p8_a50 := ddx_header_rec.global_attribute19;
    p8_a51 := ddx_header_rec.global_attribute2;
    p8_a52 := ddx_header_rec.global_attribute20;
    p8_a53 := ddx_header_rec.global_attribute3;
    p8_a54 := ddx_header_rec.global_attribute4;
    p8_a55 := ddx_header_rec.global_attribute5;
    p8_a56 := ddx_header_rec.global_attribute6;
    p8_a57 := ddx_header_rec.global_attribute7;
    p8_a58 := ddx_header_rec.global_attribute8;
    p8_a59 := ddx_header_rec.global_attribute9;
    p8_a60 := ddx_header_rec.global_attribute_category;
    p8_a61 := ddx_header_rec.tp_context;
    p8_a62 := ddx_header_rec.tp_attribute1;
    p8_a63 := ddx_header_rec.tp_attribute2;
    p8_a64 := ddx_header_rec.tp_attribute3;
    p8_a65 := ddx_header_rec.tp_attribute4;
    p8_a66 := ddx_header_rec.tp_attribute5;
    p8_a67 := ddx_header_rec.tp_attribute6;
    p8_a68 := ddx_header_rec.tp_attribute7;
    p8_a69 := ddx_header_rec.tp_attribute8;
    p8_a70 := ddx_header_rec.tp_attribute9;
    p8_a71 := ddx_header_rec.tp_attribute10;
    p8_a72 := ddx_header_rec.tp_attribute11;
    p8_a73 := ddx_header_rec.tp_attribute12;
    p8_a74 := ddx_header_rec.tp_attribute13;
    p8_a75 := ddx_header_rec.tp_attribute14;
    p8_a76 := ddx_header_rec.tp_attribute15;
    p8_a77 := rosetta_g_miss_num_map(ddx_header_rec.header_id);
    p8_a78 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_contact_id);
    p8_a79 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_id);
    p8_a80 := rosetta_g_miss_num_map(ddx_header_rec.invoicing_rule_id);
    p8_a81 := rosetta_g_miss_num_map(ddx_header_rec.last_updated_by);
    p8_a82 := ddx_header_rec.last_update_date;
    p8_a83 := rosetta_g_miss_num_map(ddx_header_rec.last_update_login);
    p8_a84 := rosetta_g_miss_num_map(ddx_header_rec.latest_schedule_limit);
    p8_a85 := ddx_header_rec.open_flag;
    p8_a86 := ddx_header_rec.order_category_code;
    p8_a87 := ddx_header_rec.ordered_date;
    p8_a88 := ddx_header_rec.order_date_type_code;
    p8_a89 := rosetta_g_miss_num_map(ddx_header_rec.order_number);
    p8_a90 := rosetta_g_miss_num_map(ddx_header_rec.order_source_id);
    p8_a91 := rosetta_g_miss_num_map(ddx_header_rec.order_type_id);
    p8_a92 := rosetta_g_miss_num_map(ddx_header_rec.org_id);
    p8_a93 := ddx_header_rec.orig_sys_document_ref;
    p8_a94 := ddx_header_rec.partial_shipments_allowed;
    p8_a95 := rosetta_g_miss_num_map(ddx_header_rec.payment_term_id);
    p8_a96 := rosetta_g_miss_num_map(ddx_header_rec.price_list_id);
    p8_a97 := ddx_header_rec.price_request_code;
    p8_a98 := ddx_header_rec.pricing_date;
    p8_a99 := rosetta_g_miss_num_map(ddx_header_rec.program_application_id);
    p8_a100 := rosetta_g_miss_num_map(ddx_header_rec.program_id);
    p8_a101 := ddx_header_rec.program_update_date;
    p8_a102 := ddx_header_rec.request_date;
    p8_a103 := rosetta_g_miss_num_map(ddx_header_rec.request_id);
    p8_a104 := ddx_header_rec.return_reason_code;
    p8_a105 := rosetta_g_miss_num_map(ddx_header_rec.salesrep_id);
    p8_a106 := ddx_header_rec.sales_channel_code;
    p8_a107 := ddx_header_rec.shipment_priority_code;
    p8_a108 := ddx_header_rec.shipping_method_code;
    p8_a109 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_org_id);
    p8_a110 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_above);
    p8_a111 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_below);
    p8_a112 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_contact_id);
    p8_a113 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_id);
    p8_a114 := rosetta_g_miss_num_map(ddx_header_rec.sold_from_org_id);
    p8_a115 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_contact_id);
    p8_a116 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_id);
    p8_a117 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_phone_id);
    p8_a118 := rosetta_g_miss_num_map(ddx_header_rec.source_document_id);
    p8_a119 := rosetta_g_miss_num_map(ddx_header_rec.source_document_type_id);
    p8_a120 := ddx_header_rec.tax_exempt_flag;
    p8_a121 := ddx_header_rec.tax_exempt_number;
    p8_a122 := ddx_header_rec.tax_exempt_reason_code;
    p8_a123 := ddx_header_rec.tax_point_code;
    p8_a124 := ddx_header_rec.transactional_curr_code;
    p8_a125 := rosetta_g_miss_num_map(ddx_header_rec.version_number);
    p8_a126 := ddx_header_rec.return_status;
    p8_a127 := ddx_header_rec.db_flag;
    p8_a128 := ddx_header_rec.operation;
    p8_a129 := ddx_header_rec.first_ack_code;
    p8_a130 := ddx_header_rec.first_ack_date;
    p8_a131 := ddx_header_rec.last_ack_code;
    p8_a132 := ddx_header_rec.last_ack_date;
    p8_a133 := ddx_header_rec.change_reason;
    p8_a134 := ddx_header_rec.change_comments;
    p8_a135 := ddx_header_rec.change_sequence;
    p8_a136 := ddx_header_rec.change_request_code;
    p8_a137 := ddx_header_rec.ready_flag;
    p8_a138 := ddx_header_rec.status_flag;
    p8_a139 := ddx_header_rec.force_apply_flag;
    p8_a140 := ddx_header_rec.drop_ship_flag;
    p8_a141 := rosetta_g_miss_num_map(ddx_header_rec.customer_payment_term_id);
    p8_a142 := ddx_header_rec.payment_type_code;
    p8_a143 := rosetta_g_miss_num_map(ddx_header_rec.payment_amount);
    p8_a144 := ddx_header_rec.check_number;
    p8_a145 := ddx_header_rec.credit_card_code;
    p8_a146 := ddx_header_rec.credit_card_holder_name;
    p8_a147 := ddx_header_rec.credit_card_number;
    p8_a148 := ddx_header_rec.credit_card_expiration_date;
    p8_a149 := ddx_header_rec.credit_card_approval_code;
    p8_a150 := ddx_header_rec.credit_card_approval_date;
    p8_a151 := ddx_header_rec.shipping_instructions;
    p8_a152 := ddx_header_rec.packing_instructions;
    p8_a153 := ddx_header_rec.flow_status_code;
    p8_a154 := ddx_header_rec.booked_date;
    p8_a155 := rosetta_g_miss_num_map(ddx_header_rec.marketing_source_code_id);
    p8_a156 := ddx_header_rec.upgraded_flag;
    p8_a157 := rosetta_g_miss_num_map(ddx_header_rec.lock_control);
    p8_a158 := ddx_header_rec.ship_to_edi_location_code;
    p8_a159 := ddx_header_rec.sold_to_edi_location_code;
    p8_a160 := ddx_header_rec.bill_to_edi_location_code;
    p8_a161 := ddx_header_rec.ship_from_edi_location_code;
    p8_a162 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_address_id);
    p8_a163 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_address_id);
    p8_a164 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_address_id);
    p8_a165 := rosetta_g_miss_num_map(ddx_header_rec.invoice_address_id);
    p8_a166 := ddx_header_rec.ship_to_address_code;
    p8_a167 := rosetta_g_miss_num_map(ddx_header_rec.xml_message_id);
    p8_a168 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_id);
    p8_a169 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_id);
    p8_a170 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_id);
    p8_a171 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_duration);
    p8_a172 := ddx_header_rec.xml_transaction_type_code;
    p8_a173 := rosetta_g_miss_num_map(ddx_header_rec.blanket_number);
    p8_a174 := ddx_header_rec.line_set_name;
    p8_a175 := ddx_header_rec.fulfillment_set_name;
    p8_a176 := ddx_header_rec.default_fulfillment_set;
    p8_a177 := ddx_header_rec.quote_date;
    p8_a178 := rosetta_g_miss_num_map(ddx_header_rec.quote_number);
    p8_a179 := ddx_header_rec.sales_document_name;
    p8_a180 := ddx_header_rec.transaction_phase_code;
    p8_a181 := ddx_header_rec.user_status_code;
    p8_a182 := ddx_header_rec.draft_submitted_flag;
    p8_a183 := rosetta_g_miss_num_map(ddx_header_rec.source_document_version_number);
    p8_a184 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_site_use_id);
    p8_a185 := rosetta_g_miss_num_map(ddx_header_rec.minisite_id);
    p8_a186 := ddx_header_rec.ib_owner;
    p8_a187 := ddx_header_rec.ib_installed_at_location;
    p8_a188 := ddx_header_rec.ib_current_location;
    p8_a189 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_id);
    p8_a190 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_contact_id);
    p8_a191 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_site_use_id);
    p8_a192 := ddx_header_rec.supplier_signature;
    p8_a193 := ddx_header_rec.supplier_signature_date;
    p8_a194 := ddx_header_rec.customer_signature;
    p8_a195 := ddx_header_rec.customer_signature_date;
    p8_a196 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_party_id);
    p8_a197 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_contact_id);
    p8_a198 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_id);
    p8_a199 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_id);
    p8_a200 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_use_id);
    p8_a201 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_id);
    p8_a202 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_id);
    p8_a203 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_use_id);
    p8_a204 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_id);
    p8_a205 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_id);
    p8_a206 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_use_id);
    p8_a207 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_party_id);
    p8_a208 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_party_id);
    p8_a209 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_party_id);
    p8_a210 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_contact_id);
    p8_a211 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_contact_id);
    p8_a212 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_contact_id);
    p8_a213 := rosetta_g_miss_num_map(ddx_header_rec.contract_template_id);
    p8_a214 := ddx_header_rec.contract_source_doc_type_code;
    p8_a215 := rosetta_g_miss_num_map(ddx_header_rec.contract_source_document_id);

    p9_a0 := ddx_header_val_rec.accounting_rule;
    p9_a1 := ddx_header_val_rec.agreement;
    p9_a2 := ddx_header_val_rec.conversion_type;
    p9_a3 := ddx_header_val_rec.deliver_to_address1;
    p9_a4 := ddx_header_val_rec.deliver_to_address2;
    p9_a5 := ddx_header_val_rec.deliver_to_address3;
    p9_a6 := ddx_header_val_rec.deliver_to_address4;
    p9_a7 := ddx_header_val_rec.deliver_to_contact;
    p9_a8 := ddx_header_val_rec.deliver_to_location;
    p9_a9 := ddx_header_val_rec.deliver_to_org;
    p9_a10 := ddx_header_val_rec.deliver_to_state;
    p9_a11 := ddx_header_val_rec.deliver_to_city;
    p9_a12 := ddx_header_val_rec.deliver_to_zip;
    p9_a13 := ddx_header_val_rec.deliver_to_country;
    p9_a14 := ddx_header_val_rec.deliver_to_county;
    p9_a15 := ddx_header_val_rec.deliver_to_province;
    p9_a16 := ddx_header_val_rec.demand_class;
    p9_a17 := ddx_header_val_rec.fob_point;
    p9_a18 := ddx_header_val_rec.freight_terms;
    p9_a19 := ddx_header_val_rec.invoice_to_address1;
    p9_a20 := ddx_header_val_rec.invoice_to_address2;
    p9_a21 := ddx_header_val_rec.invoice_to_address3;
    p9_a22 := ddx_header_val_rec.invoice_to_address4;
    p9_a23 := ddx_header_val_rec.invoice_to_state;
    p9_a24 := ddx_header_val_rec.invoice_to_city;
    p9_a25 := ddx_header_val_rec.invoice_to_zip;
    p9_a26 := ddx_header_val_rec.invoice_to_country;
    p9_a27 := ddx_header_val_rec.invoice_to_county;
    p9_a28 := ddx_header_val_rec.invoice_to_province;
    p9_a29 := ddx_header_val_rec.invoice_to_contact;
    p9_a30 := ddx_header_val_rec.invoice_to_contact_first_name;
    p9_a31 := ddx_header_val_rec.invoice_to_contact_last_name;
    p9_a32 := ddx_header_val_rec.invoice_to_location;
    p9_a33 := ddx_header_val_rec.invoice_to_org;
    p9_a34 := ddx_header_val_rec.invoicing_rule;
    p9_a35 := ddx_header_val_rec.order_source;
    p9_a36 := ddx_header_val_rec.order_type;
    p9_a37 := ddx_header_val_rec.payment_term;
    p9_a38 := ddx_header_val_rec.price_list;
    p9_a39 := ddx_header_val_rec.return_reason;
    p9_a40 := ddx_header_val_rec.salesrep;
    p9_a41 := ddx_header_val_rec.shipment_priority;
    p9_a42 := ddx_header_val_rec.ship_from_address1;
    p9_a43 := ddx_header_val_rec.ship_from_address2;
    p9_a44 := ddx_header_val_rec.ship_from_address3;
    p9_a45 := ddx_header_val_rec.ship_from_address4;
    p9_a46 := ddx_header_val_rec.ship_from_location;
    p9_a47 := ddx_header_val_rec.ship_from_city;
    p9_a48 := ddx_header_val_rec.ship_from_postal_code;
    p9_a49 := ddx_header_val_rec.ship_from_country;
    p9_a50 := ddx_header_val_rec.ship_from_region1;
    p9_a51 := ddx_header_val_rec.ship_from_region2;
    p9_a52 := ddx_header_val_rec.ship_from_region3;
    p9_a53 := ddx_header_val_rec.ship_from_org;
    p9_a54 := ddx_header_val_rec.sold_to_address1;
    p9_a55 := ddx_header_val_rec.sold_to_address2;
    p9_a56 := ddx_header_val_rec.sold_to_address3;
    p9_a57 := ddx_header_val_rec.sold_to_address4;
    p9_a58 := ddx_header_val_rec.sold_to_state;
    p9_a59 := ddx_header_val_rec.sold_to_country;
    p9_a60 := ddx_header_val_rec.sold_to_zip;
    p9_a61 := ddx_header_val_rec.sold_to_county;
    p9_a62 := ddx_header_val_rec.sold_to_province;
    p9_a63 := ddx_header_val_rec.sold_to_city;
    p9_a64 := ddx_header_val_rec.sold_to_contact_last_name;
    p9_a65 := ddx_header_val_rec.sold_to_contact_first_name;
    p9_a66 := ddx_header_val_rec.ship_to_address1;
    p9_a67 := ddx_header_val_rec.ship_to_address2;
    p9_a68 := ddx_header_val_rec.ship_to_address3;
    p9_a69 := ddx_header_val_rec.ship_to_address4;
    p9_a70 := ddx_header_val_rec.ship_to_state;
    p9_a71 := ddx_header_val_rec.ship_to_country;
    p9_a72 := ddx_header_val_rec.ship_to_zip;
    p9_a73 := ddx_header_val_rec.ship_to_county;
    p9_a74 := ddx_header_val_rec.ship_to_province;
    p9_a75 := ddx_header_val_rec.ship_to_city;
    p9_a76 := ddx_header_val_rec.ship_to_contact;
    p9_a77 := ddx_header_val_rec.ship_to_contact_last_name;
    p9_a78 := ddx_header_val_rec.ship_to_contact_first_name;
    p9_a79 := ddx_header_val_rec.ship_to_location;
    p9_a80 := ddx_header_val_rec.ship_to_org;
    p9_a81 := ddx_header_val_rec.sold_to_contact;
    p9_a82 := ddx_header_val_rec.sold_to_org;
    p9_a83 := ddx_header_val_rec.sold_from_org;
    p9_a84 := ddx_header_val_rec.tax_exempt;
    p9_a85 := ddx_header_val_rec.tax_exempt_reason;
    p9_a86 := ddx_header_val_rec.tax_point;
    p9_a87 := ddx_header_val_rec.customer_payment_term;
    p9_a88 := ddx_header_val_rec.payment_type;
    p9_a89 := ddx_header_val_rec.credit_card;
    p9_a90 := ddx_header_val_rec.status;
    p9_a91 := ddx_header_val_rec.freight_carrier;
    p9_a92 := ddx_header_val_rec.shipping_method;
    p9_a93 := ddx_header_val_rec.order_date_type;
    p9_a94 := ddx_header_val_rec.customer_number;
    p9_a95 := ddx_header_val_rec.ship_to_customer_name;
    p9_a96 := ddx_header_val_rec.invoice_to_customer_name;
    p9_a97 := ddx_header_val_rec.sales_channel;
    p9_a98 := ddx_header_val_rec.ship_to_customer_number;
    p9_a99 := ddx_header_val_rec.invoice_to_customer_number;
    p9_a100 := rosetta_g_miss_num_map(ddx_header_val_rec.ship_to_customer_id);
    p9_a101 := rosetta_g_miss_num_map(ddx_header_val_rec.invoice_to_customer_id);
    p9_a102 := rosetta_g_miss_num_map(ddx_header_val_rec.deliver_to_customer_id);
    p9_a103 := ddx_header_val_rec.deliver_to_customer_number;
    p9_a104 := ddx_header_val_rec.deliver_to_customer_name;
    p9_a105 := ddx_header_val_rec.deliver_to_customer_number_oi;
    p9_a106 := ddx_header_val_rec.deliver_to_customer_name_oi;
    p9_a107 := ddx_header_val_rec.ship_to_customer_number_oi;
    p9_a108 := ddx_header_val_rec.ship_to_customer_name_oi;
    p9_a109 := ddx_header_val_rec.invoice_to_customer_number_oi;
    p9_a110 := ddx_header_val_rec.invoice_to_customer_name_oi;
    p9_a111 := ddx_header_val_rec.user_status;
    p9_a112 := ddx_header_val_rec.transaction_phase;
    p9_a113 := ddx_header_val_rec.sold_to_location_address1;
    p9_a114 := ddx_header_val_rec.sold_to_location_address2;
    p9_a115 := ddx_header_val_rec.sold_to_location_address3;
    p9_a116 := ddx_header_val_rec.sold_to_location_address4;
    p9_a117 := ddx_header_val_rec.sold_to_location;
    p9_a118 := ddx_header_val_rec.sold_to_location_city;
    p9_a119 := ddx_header_val_rec.sold_to_location_state;
    p9_a120 := ddx_header_val_rec.sold_to_location_postal;
    p9_a121 := ddx_header_val_rec.sold_to_location_country;
    p9_a122 := ddx_header_val_rec.sold_to_location_county;
    p9_a123 := ddx_header_val_rec.sold_to_location_province;
    p9_a124 := ddx_header_val_rec.end_customer_name;
    p9_a125 := ddx_header_val_rec.end_customer_number;
    p9_a126 := ddx_header_val_rec.end_customer_contact;
    p9_a127 := ddx_header_val_rec.end_cust_contact_last_name;
    p9_a128 := ddx_header_val_rec.end_cust_contact_first_name;
    p9_a129 := ddx_header_val_rec.end_customer_site_address1;
    p9_a130 := ddx_header_val_rec.end_customer_site_address2;
    p9_a131 := ddx_header_val_rec.end_customer_site_address3;
    p9_a132 := ddx_header_val_rec.end_customer_site_address4;
    p9_a133 := ddx_header_val_rec.end_customer_site_state;
    p9_a134 := ddx_header_val_rec.end_customer_site_country;
    p9_a135 := ddx_header_val_rec.end_customer_site_location;
    p9_a136 := ddx_header_val_rec.end_customer_site_zip;
    p9_a137 := ddx_header_val_rec.end_customer_site_county;
    p9_a138 := ddx_header_val_rec.end_customer_site_province;
    p9_a139 := ddx_header_val_rec.end_customer_site_city;
    p9_a140 := ddx_header_val_rec.end_customer_site_postal_code;
    p9_a141 := ddx_header_val_rec.blanket_agreement_name;

    p10_a0 := rosetta_g_miss_num_map(ddx_old_header_rec.accounting_rule_id);
    p10_a1 := rosetta_g_miss_num_map(ddx_old_header_rec.agreement_id);
    p10_a2 := ddx_old_header_rec.attribute1;
    p10_a3 := ddx_old_header_rec.attribute10;
    p10_a4 := ddx_old_header_rec.attribute11;
    p10_a5 := ddx_old_header_rec.attribute12;
    p10_a6 := ddx_old_header_rec.attribute13;
    p10_a7 := ddx_old_header_rec.attribute14;
    p10_a8 := ddx_old_header_rec.attribute15;
    p10_a9 := ddx_old_header_rec.attribute16;
    p10_a10 := ddx_old_header_rec.attribute17;
    p10_a11 := ddx_old_header_rec.attribute18;
    p10_a12 := ddx_old_header_rec.attribute19;
    p10_a13 := ddx_old_header_rec.attribute2;
    p10_a14 := ddx_old_header_rec.attribute20;
    p10_a15 := ddx_old_header_rec.attribute3;
    p10_a16 := ddx_old_header_rec.attribute4;
    p10_a17 := ddx_old_header_rec.attribute5;
    p10_a18 := ddx_old_header_rec.attribute6;
    p10_a19 := ddx_old_header_rec.attribute7;
    p10_a20 := ddx_old_header_rec.attribute8;
    p10_a21 := ddx_old_header_rec.attribute9;
    p10_a22 := ddx_old_header_rec.booked_flag;
    p10_a23 := ddx_old_header_rec.cancelled_flag;
    p10_a24 := ddx_old_header_rec.context;
    p10_a25 := rosetta_g_miss_num_map(ddx_old_header_rec.conversion_rate);
    p10_a26 := ddx_old_header_rec.conversion_rate_date;
    p10_a27 := ddx_old_header_rec.conversion_type_code;
    p10_a28 := ddx_old_header_rec.customer_preference_set_code;
    p10_a29 := rosetta_g_miss_num_map(ddx_old_header_rec.created_by);
    p10_a30 := ddx_old_header_rec.creation_date;
    p10_a31 := ddx_old_header_rec.cust_po_number;
    p10_a32 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_contact_id);
    p10_a33 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_org_id);
    p10_a34 := ddx_old_header_rec.demand_class_code;
    p10_a35 := rosetta_g_miss_num_map(ddx_old_header_rec.earliest_schedule_limit);
    p10_a36 := ddx_old_header_rec.expiration_date;
    p10_a37 := ddx_old_header_rec.fob_point_code;
    p10_a38 := ddx_old_header_rec.freight_carrier_code;
    p10_a39 := ddx_old_header_rec.freight_terms_code;
    p10_a40 := ddx_old_header_rec.global_attribute1;
    p10_a41 := ddx_old_header_rec.global_attribute10;
    p10_a42 := ddx_old_header_rec.global_attribute11;
    p10_a43 := ddx_old_header_rec.global_attribute12;
    p10_a44 := ddx_old_header_rec.global_attribute13;
    p10_a45 := ddx_old_header_rec.global_attribute14;
    p10_a46 := ddx_old_header_rec.global_attribute15;
    p10_a47 := ddx_old_header_rec.global_attribute16;
    p10_a48 := ddx_old_header_rec.global_attribute17;
    p10_a49 := ddx_old_header_rec.global_attribute18;
    p10_a50 := ddx_old_header_rec.global_attribute19;
    p10_a51 := ddx_old_header_rec.global_attribute2;
    p10_a52 := ddx_old_header_rec.global_attribute20;
    p10_a53 := ddx_old_header_rec.global_attribute3;
    p10_a54 := ddx_old_header_rec.global_attribute4;
    p10_a55 := ddx_old_header_rec.global_attribute5;
    p10_a56 := ddx_old_header_rec.global_attribute6;
    p10_a57 := ddx_old_header_rec.global_attribute7;
    p10_a58 := ddx_old_header_rec.global_attribute8;
    p10_a59 := ddx_old_header_rec.global_attribute9;
    p10_a60 := ddx_old_header_rec.global_attribute_category;
    p10_a61 := ddx_old_header_rec.tp_context;
    p10_a62 := ddx_old_header_rec.tp_attribute1;
    p10_a63 := ddx_old_header_rec.tp_attribute2;
    p10_a64 := ddx_old_header_rec.tp_attribute3;
    p10_a65 := ddx_old_header_rec.tp_attribute4;
    p10_a66 := ddx_old_header_rec.tp_attribute5;
    p10_a67 := ddx_old_header_rec.tp_attribute6;
    p10_a68 := ddx_old_header_rec.tp_attribute7;
    p10_a69 := ddx_old_header_rec.tp_attribute8;
    p10_a70 := ddx_old_header_rec.tp_attribute9;
    p10_a71 := ddx_old_header_rec.tp_attribute10;
    p10_a72 := ddx_old_header_rec.tp_attribute11;
    p10_a73 := ddx_old_header_rec.tp_attribute12;
    p10_a74 := ddx_old_header_rec.tp_attribute13;
    p10_a75 := ddx_old_header_rec.tp_attribute14;
    p10_a76 := ddx_old_header_rec.tp_attribute15;
    p10_a77 := rosetta_g_miss_num_map(ddx_old_header_rec.header_id);
    p10_a78 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_contact_id);
    p10_a79 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_org_id);
    p10_a80 := rosetta_g_miss_num_map(ddx_old_header_rec.invoicing_rule_id);
    p10_a81 := rosetta_g_miss_num_map(ddx_old_header_rec.last_updated_by);
    p10_a82 := ddx_old_header_rec.last_update_date;
    p10_a83 := rosetta_g_miss_num_map(ddx_old_header_rec.last_update_login);
    p10_a84 := rosetta_g_miss_num_map(ddx_old_header_rec.latest_schedule_limit);
    p10_a85 := ddx_old_header_rec.open_flag;
    p10_a86 := ddx_old_header_rec.order_category_code;
    p10_a87 := ddx_old_header_rec.ordered_date;
    p10_a88 := ddx_old_header_rec.order_date_type_code;
    p10_a89 := rosetta_g_miss_num_map(ddx_old_header_rec.order_number);
    p10_a90 := rosetta_g_miss_num_map(ddx_old_header_rec.order_source_id);
    p10_a91 := rosetta_g_miss_num_map(ddx_old_header_rec.order_type_id);
    p10_a92 := rosetta_g_miss_num_map(ddx_old_header_rec.org_id);
    p10_a93 := ddx_old_header_rec.orig_sys_document_ref;
    p10_a94 := ddx_old_header_rec.partial_shipments_allowed;
    p10_a95 := rosetta_g_miss_num_map(ddx_old_header_rec.payment_term_id);
    p10_a96 := rosetta_g_miss_num_map(ddx_old_header_rec.price_list_id);
    p10_a97 := ddx_old_header_rec.price_request_code;
    p10_a98 := ddx_old_header_rec.pricing_date;
    p10_a99 := rosetta_g_miss_num_map(ddx_old_header_rec.program_application_id);
    p10_a100 := rosetta_g_miss_num_map(ddx_old_header_rec.program_id);
    p10_a101 := ddx_old_header_rec.program_update_date;
    p10_a102 := ddx_old_header_rec.request_date;
    p10_a103 := rosetta_g_miss_num_map(ddx_old_header_rec.request_id);
    p10_a104 := ddx_old_header_rec.return_reason_code;
    p10_a105 := rosetta_g_miss_num_map(ddx_old_header_rec.salesrep_id);
    p10_a106 := ddx_old_header_rec.sales_channel_code;
    p10_a107 := ddx_old_header_rec.shipment_priority_code;
    p10_a108 := ddx_old_header_rec.shipping_method_code;
    p10_a109 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_from_org_id);
    p10_a110 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_tolerance_above);
    p10_a111 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_tolerance_below);
    p10_a112 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_contact_id);
    p10_a113 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_org_id);
    p10_a114 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_from_org_id);
    p10_a115 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_contact_id);
    p10_a116 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_org_id);
    p10_a117 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_phone_id);
    p10_a118 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_id);
    p10_a119 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_type_id);
    p10_a120 := ddx_old_header_rec.tax_exempt_flag;
    p10_a121 := ddx_old_header_rec.tax_exempt_number;
    p10_a122 := ddx_old_header_rec.tax_exempt_reason_code;
    p10_a123 := ddx_old_header_rec.tax_point_code;
    p10_a124 := ddx_old_header_rec.transactional_curr_code;
    p10_a125 := rosetta_g_miss_num_map(ddx_old_header_rec.version_number);
    p10_a126 := ddx_old_header_rec.return_status;
    p10_a127 := ddx_old_header_rec.db_flag;
    p10_a128 := ddx_old_header_rec.operation;
    p10_a129 := ddx_old_header_rec.first_ack_code;
    p10_a130 := ddx_old_header_rec.first_ack_date;
    p10_a131 := ddx_old_header_rec.last_ack_code;
    p10_a132 := ddx_old_header_rec.last_ack_date;
    p10_a133 := ddx_old_header_rec.change_reason;
    p10_a134 := ddx_old_header_rec.change_comments;
    p10_a135 := ddx_old_header_rec.change_sequence;
    p10_a136 := ddx_old_header_rec.change_request_code;
    p10_a137 := ddx_old_header_rec.ready_flag;
    p10_a138 := ddx_old_header_rec.status_flag;
    p10_a139 := ddx_old_header_rec.force_apply_flag;
    p10_a140 := ddx_old_header_rec.drop_ship_flag;
    p10_a141 := rosetta_g_miss_num_map(ddx_old_header_rec.customer_payment_term_id);
    p10_a142 := ddx_old_header_rec.payment_type_code;
    p10_a143 := rosetta_g_miss_num_map(ddx_old_header_rec.payment_amount);
    p10_a144 := ddx_old_header_rec.check_number;
    p10_a145 := ddx_old_header_rec.credit_card_code;
    p10_a146 := ddx_old_header_rec.credit_card_holder_name;
    p10_a147 := ddx_old_header_rec.credit_card_number;
    p10_a148 := ddx_old_header_rec.credit_card_expiration_date;
    p10_a149 := ddx_old_header_rec.credit_card_approval_code;
    p10_a150 := ddx_old_header_rec.credit_card_approval_date;
    p10_a151 := ddx_old_header_rec.shipping_instructions;
    p10_a152 := ddx_old_header_rec.packing_instructions;
    p10_a153 := ddx_old_header_rec.flow_status_code;
    p10_a154 := ddx_old_header_rec.booked_date;
    p10_a155 := rosetta_g_miss_num_map(ddx_old_header_rec.marketing_source_code_id);
    p10_a156 := ddx_old_header_rec.upgraded_flag;
    p10_a157 := rosetta_g_miss_num_map(ddx_old_header_rec.lock_control);
    p10_a158 := ddx_old_header_rec.ship_to_edi_location_code;
    p10_a159 := ddx_old_header_rec.sold_to_edi_location_code;
    p10_a160 := ddx_old_header_rec.bill_to_edi_location_code;
    p10_a161 := ddx_old_header_rec.ship_from_edi_location_code;
    p10_a162 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_from_address_id);
    p10_a163 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_address_id);
    p10_a164 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_address_id);
    p10_a165 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_address_id);
    p10_a166 := ddx_old_header_rec.ship_to_address_code;
    p10_a167 := rosetta_g_miss_num_map(ddx_old_header_rec.xml_message_id);
    p10_a168 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_customer_id);
    p10_a169 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_customer_id);
    p10_a170 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_customer_id);
    p10_a171 := rosetta_g_miss_num_map(ddx_old_header_rec.accounting_rule_duration);
    p10_a172 := ddx_old_header_rec.xml_transaction_type_code;
    p10_a173 := rosetta_g_miss_num_map(ddx_old_header_rec.blanket_number);
    p10_a174 := ddx_old_header_rec.line_set_name;
    p10_a175 := ddx_old_header_rec.fulfillment_set_name;
    p10_a176 := ddx_old_header_rec.default_fulfillment_set;
    p10_a177 := ddx_old_header_rec.quote_date;
    p10_a178 := rosetta_g_miss_num_map(ddx_old_header_rec.quote_number);
    p10_a179 := ddx_old_header_rec.sales_document_name;
    p10_a180 := ddx_old_header_rec.transaction_phase_code;
    p10_a181 := ddx_old_header_rec.user_status_code;
    p10_a182 := ddx_old_header_rec.draft_submitted_flag;
    p10_a183 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_version_number);
    p10_a184 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_site_use_id);
    p10_a185 := rosetta_g_miss_num_map(ddx_old_header_rec.minisite_id);
    p10_a186 := ddx_old_header_rec.ib_owner;
    p10_a187 := ddx_old_header_rec.ib_installed_at_location;
    p10_a188 := ddx_old_header_rec.ib_current_location;
    p10_a189 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_id);
    p10_a190 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_contact_id);
    p10_a191 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_site_use_id);
    p10_a192 := ddx_old_header_rec.supplier_signature;
    p10_a193 := ddx_old_header_rec.supplier_signature_date;
    p10_a194 := ddx_old_header_rec.customer_signature;
    p10_a195 := ddx_old_header_rec.customer_signature_date;
    p10_a196 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_party_id);
    p10_a197 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_org_contact_id);
    p10_a198 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_id);
    p10_a199 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_site_id);
    p10_a200 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_site_use_id);
    p10_a201 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_id);
    p10_a202 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_site_id);
    p10_a203 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_site_use_id);
    p10_a204 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_id);
    p10_a205 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_site_id);
    p10_a206 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_site_use_id);
    p10_a207 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_customer_party_id);
    p10_a208 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_customer_party_id);
    p10_a209 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_customer_party_id);
    p10_a210 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_org_contact_id);
    p10_a211 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_org_contact_id);
    p10_a212 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_org_contact_id);
    p10_a213 := rosetta_g_miss_num_map(ddx_old_header_rec.contract_template_id);
    p10_a214 := ddx_old_header_rec.contract_source_doc_type_code;
    p10_a215 := rosetta_g_miss_num_map(ddx_old_header_rec.contract_source_document_id);
  end;

  procedure save_header(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_header_id  NUMBER
    , p_process  number
    , p5_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p5_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p6_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a102 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p7_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p7_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p7_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
  )

  as
    ddp_process boolean;
    ddx_header_rec oe_order_pub.header_rec_type;
    ddx_header_val_rec oe_order_pub.header_val_rec_type;
    ddx_old_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    if p_process is null
      then ddp_process := null;
    elsif p_process = 0
      then ddp_process := false;
    else ddp_process := true;
    end if;

    ddx_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddx_header_rec.agreement_id := rosetta_g_miss_num_map(p5_a1);
    ddx_header_rec.attribute1 := p5_a2;
    ddx_header_rec.attribute10 := p5_a3;
    ddx_header_rec.attribute11 := p5_a4;
    ddx_header_rec.attribute12 := p5_a5;
    ddx_header_rec.attribute13 := p5_a6;
    ddx_header_rec.attribute14 := p5_a7;
    ddx_header_rec.attribute15 := p5_a8;
    ddx_header_rec.attribute16 := p5_a9;
    ddx_header_rec.attribute17 := p5_a10;
    ddx_header_rec.attribute18 := p5_a11;
    ddx_header_rec.attribute19 := p5_a12;
    ddx_header_rec.attribute2 := p5_a13;
    ddx_header_rec.attribute20 := p5_a14;
    ddx_header_rec.attribute3 := p5_a15;
    ddx_header_rec.attribute4 := p5_a16;
    ddx_header_rec.attribute5 := p5_a17;
    ddx_header_rec.attribute6 := p5_a18;
    ddx_header_rec.attribute7 := p5_a19;
    ddx_header_rec.attribute8 := p5_a20;
    ddx_header_rec.attribute9 := p5_a21;
    ddx_header_rec.booked_flag := p5_a22;
    ddx_header_rec.cancelled_flag := p5_a23;
    ddx_header_rec.context := p5_a24;
    ddx_header_rec.conversion_rate := rosetta_g_miss_num_map(p5_a25);
    ddx_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p5_a26);
    ddx_header_rec.conversion_type_code := p5_a27;
    ddx_header_rec.customer_preference_set_code := p5_a28;
    ddx_header_rec.created_by := rosetta_g_miss_num_map(p5_a29);
    ddx_header_rec.creation_date := rosetta_g_miss_date_in_map(p5_a30);
    ddx_header_rec.cust_po_number := p5_a31;
    ddx_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p5_a32);
    ddx_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p5_a33);
    ddx_header_rec.demand_class_code := p5_a34;
    ddx_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p5_a35);
    ddx_header_rec.expiration_date := rosetta_g_miss_date_in_map(p5_a36);
    ddx_header_rec.fob_point_code := p5_a37;
    ddx_header_rec.freight_carrier_code := p5_a38;
    ddx_header_rec.freight_terms_code := p5_a39;
    ddx_header_rec.global_attribute1 := p5_a40;
    ddx_header_rec.global_attribute10 := p5_a41;
    ddx_header_rec.global_attribute11 := p5_a42;
    ddx_header_rec.global_attribute12 := p5_a43;
    ddx_header_rec.global_attribute13 := p5_a44;
    ddx_header_rec.global_attribute14 := p5_a45;
    ddx_header_rec.global_attribute15 := p5_a46;
    ddx_header_rec.global_attribute16 := p5_a47;
    ddx_header_rec.global_attribute17 := p5_a48;
    ddx_header_rec.global_attribute18 := p5_a49;
    ddx_header_rec.global_attribute19 := p5_a50;
    ddx_header_rec.global_attribute2 := p5_a51;
    ddx_header_rec.global_attribute20 := p5_a52;
    ddx_header_rec.global_attribute3 := p5_a53;
    ddx_header_rec.global_attribute4 := p5_a54;
    ddx_header_rec.global_attribute5 := p5_a55;
    ddx_header_rec.global_attribute6 := p5_a56;
    ddx_header_rec.global_attribute7 := p5_a57;
    ddx_header_rec.global_attribute8 := p5_a58;
    ddx_header_rec.global_attribute9 := p5_a59;
    ddx_header_rec.global_attribute_category := p5_a60;
    ddx_header_rec.tp_context := p5_a61;
    ddx_header_rec.tp_attribute1 := p5_a62;
    ddx_header_rec.tp_attribute2 := p5_a63;
    ddx_header_rec.tp_attribute3 := p5_a64;
    ddx_header_rec.tp_attribute4 := p5_a65;
    ddx_header_rec.tp_attribute5 := p5_a66;
    ddx_header_rec.tp_attribute6 := p5_a67;
    ddx_header_rec.tp_attribute7 := p5_a68;
    ddx_header_rec.tp_attribute8 := p5_a69;
    ddx_header_rec.tp_attribute9 := p5_a70;
    ddx_header_rec.tp_attribute10 := p5_a71;
    ddx_header_rec.tp_attribute11 := p5_a72;
    ddx_header_rec.tp_attribute12 := p5_a73;
    ddx_header_rec.tp_attribute13 := p5_a74;
    ddx_header_rec.tp_attribute14 := p5_a75;
    ddx_header_rec.tp_attribute15 := p5_a76;
    ddx_header_rec.header_id := rosetta_g_miss_num_map(p5_a77);
    ddx_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p5_a78);
    ddx_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p5_a79);
    ddx_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p5_a80);
    ddx_header_rec.last_updated_by := rosetta_g_miss_num_map(p5_a81);
    ddx_header_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a82);
    ddx_header_rec.last_update_login := rosetta_g_miss_num_map(p5_a83);
    ddx_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p5_a84);
    ddx_header_rec.open_flag := p5_a85;
    ddx_header_rec.order_category_code := p5_a86;
    ddx_header_rec.ordered_date := rosetta_g_miss_date_in_map(p5_a87);
    ddx_header_rec.order_date_type_code := p5_a88;
    ddx_header_rec.order_number := rosetta_g_miss_num_map(p5_a89);
    ddx_header_rec.order_source_id := rosetta_g_miss_num_map(p5_a90);
    ddx_header_rec.order_type_id := rosetta_g_miss_num_map(p5_a91);
    ddx_header_rec.org_id := rosetta_g_miss_num_map(p5_a92);
    ddx_header_rec.orig_sys_document_ref := p5_a93;
    ddx_header_rec.partial_shipments_allowed := p5_a94;
    ddx_header_rec.payment_term_id := rosetta_g_miss_num_map(p5_a95);
    ddx_header_rec.price_list_id := rosetta_g_miss_num_map(p5_a96);
    ddx_header_rec.price_request_code := p5_a97;
    ddx_header_rec.pricing_date := rosetta_g_miss_date_in_map(p5_a98);
    ddx_header_rec.program_application_id := rosetta_g_miss_num_map(p5_a99);
    ddx_header_rec.program_id := rosetta_g_miss_num_map(p5_a100);
    ddx_header_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a101);
    ddx_header_rec.request_date := rosetta_g_miss_date_in_map(p5_a102);
    ddx_header_rec.request_id := rosetta_g_miss_num_map(p5_a103);
    ddx_header_rec.return_reason_code := p5_a104;
    ddx_header_rec.salesrep_id := rosetta_g_miss_num_map(p5_a105);
    ddx_header_rec.sales_channel_code := p5_a106;
    ddx_header_rec.shipment_priority_code := p5_a107;
    ddx_header_rec.shipping_method_code := p5_a108;
    ddx_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p5_a109);
    ddx_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p5_a110);
    ddx_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p5_a111);
    ddx_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p5_a112);
    ddx_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p5_a113);
    ddx_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p5_a114);
    ddx_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p5_a115);
    ddx_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p5_a116);
    ddx_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p5_a117);
    ddx_header_rec.source_document_id := rosetta_g_miss_num_map(p5_a118);
    ddx_header_rec.source_document_type_id := rosetta_g_miss_num_map(p5_a119);
    ddx_header_rec.tax_exempt_flag := p5_a120;
    ddx_header_rec.tax_exempt_number := p5_a121;
    ddx_header_rec.tax_exempt_reason_code := p5_a122;
    ddx_header_rec.tax_point_code := p5_a123;
    ddx_header_rec.transactional_curr_code := p5_a124;
    ddx_header_rec.version_number := rosetta_g_miss_num_map(p5_a125);
    ddx_header_rec.return_status := p5_a126;
    ddx_header_rec.db_flag := p5_a127;
    ddx_header_rec.operation := p5_a128;
    ddx_header_rec.first_ack_code := p5_a129;
    ddx_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p5_a130);
    ddx_header_rec.last_ack_code := p5_a131;
    ddx_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p5_a132);
    ddx_header_rec.change_reason := p5_a133;
    ddx_header_rec.change_comments := p5_a134;
    ddx_header_rec.change_sequence := p5_a135;
    ddx_header_rec.change_request_code := p5_a136;
    ddx_header_rec.ready_flag := p5_a137;
    ddx_header_rec.status_flag := p5_a138;
    ddx_header_rec.force_apply_flag := p5_a139;
    ddx_header_rec.drop_ship_flag := p5_a140;
    ddx_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p5_a141);
    ddx_header_rec.payment_type_code := p5_a142;
    ddx_header_rec.payment_amount := rosetta_g_miss_num_map(p5_a143);
    ddx_header_rec.check_number := p5_a144;
    ddx_header_rec.credit_card_code := p5_a145;
    ddx_header_rec.credit_card_holder_name := p5_a146;
    ddx_header_rec.credit_card_number := p5_a147;
    ddx_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p5_a148);
    ddx_header_rec.credit_card_approval_code := p5_a149;
    ddx_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p5_a150);
    ddx_header_rec.shipping_instructions := p5_a151;
    ddx_header_rec.packing_instructions := p5_a152;
    ddx_header_rec.flow_status_code := p5_a153;
    ddx_header_rec.booked_date := rosetta_g_miss_date_in_map(p5_a154);
    ddx_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p5_a155);
    ddx_header_rec.upgraded_flag := p5_a156;
    ddx_header_rec.lock_control := rosetta_g_miss_num_map(p5_a157);
    ddx_header_rec.ship_to_edi_location_code := p5_a158;
    ddx_header_rec.sold_to_edi_location_code := p5_a159;
    ddx_header_rec.bill_to_edi_location_code := p5_a160;
    ddx_header_rec.ship_from_edi_location_code := p5_a161;
    ddx_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p5_a162);
    ddx_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p5_a163);
    ddx_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p5_a164);
    ddx_header_rec.invoice_address_id := rosetta_g_miss_num_map(p5_a165);
    ddx_header_rec.ship_to_address_code := p5_a166;
    ddx_header_rec.xml_message_id := rosetta_g_miss_num_map(p5_a167);
    ddx_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p5_a168);
    ddx_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p5_a169);
    ddx_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p5_a170);
    ddx_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p5_a171);
    ddx_header_rec.xml_transaction_type_code := p5_a172;
    ddx_header_rec.blanket_number := rosetta_g_miss_num_map(p5_a173);
    ddx_header_rec.line_set_name := p5_a174;
    ddx_header_rec.fulfillment_set_name := p5_a175;
    ddx_header_rec.default_fulfillment_set := p5_a176;
    ddx_header_rec.quote_date := rosetta_g_miss_date_in_map(p5_a177);
    ddx_header_rec.quote_number := rosetta_g_miss_num_map(p5_a178);
    ddx_header_rec.sales_document_name := p5_a179;
    ddx_header_rec.transaction_phase_code := p5_a180;
    ddx_header_rec.user_status_code := p5_a181;
    ddx_header_rec.draft_submitted_flag := p5_a182;
    ddx_header_rec.source_document_version_number := rosetta_g_miss_num_map(p5_a183);
    ddx_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p5_a184);
    ddx_header_rec.minisite_id := rosetta_g_miss_num_map(p5_a185);
    ddx_header_rec.ib_owner := p5_a186;
    ddx_header_rec.ib_installed_at_location := p5_a187;
    ddx_header_rec.ib_current_location := p5_a188;
    ddx_header_rec.end_customer_id := rosetta_g_miss_num_map(p5_a189);
    ddx_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p5_a190);
    ddx_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p5_a191);
    ddx_header_rec.supplier_signature := p5_a192;
    ddx_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p5_a193);
    ddx_header_rec.customer_signature := p5_a194;
    ddx_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p5_a195);
    ddx_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p5_a196);
    ddx_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p5_a197);
    ddx_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p5_a198);
    ddx_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p5_a199);
    ddx_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p5_a200);
    ddx_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p5_a201);
    ddx_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p5_a202);
    ddx_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p5_a203);
    ddx_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p5_a204);
    ddx_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p5_a205);
    ddx_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p5_a206);
    ddx_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p5_a207);
    ddx_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p5_a208);
    ddx_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p5_a209);
    ddx_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p5_a210);
    ddx_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p5_a211);
    ddx_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p5_a212);
    ddx_header_rec.contract_template_id := rosetta_g_miss_num_map(p5_a213);
    ddx_header_rec.contract_source_doc_type_code := p5_a214;
    ddx_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p5_a215);

    ddx_header_val_rec.accounting_rule := p6_a0;
    ddx_header_val_rec.agreement := p6_a1;
    ddx_header_val_rec.conversion_type := p6_a2;
    ddx_header_val_rec.deliver_to_address1 := p6_a3;
    ddx_header_val_rec.deliver_to_address2 := p6_a4;
    ddx_header_val_rec.deliver_to_address3 := p6_a5;
    ddx_header_val_rec.deliver_to_address4 := p6_a6;
    ddx_header_val_rec.deliver_to_contact := p6_a7;
    ddx_header_val_rec.deliver_to_location := p6_a8;
    ddx_header_val_rec.deliver_to_org := p6_a9;
    ddx_header_val_rec.deliver_to_state := p6_a10;
    ddx_header_val_rec.deliver_to_city := p6_a11;
    ddx_header_val_rec.deliver_to_zip := p6_a12;
    ddx_header_val_rec.deliver_to_country := p6_a13;
    ddx_header_val_rec.deliver_to_county := p6_a14;
    ddx_header_val_rec.deliver_to_province := p6_a15;
    ddx_header_val_rec.demand_class := p6_a16;
    ddx_header_val_rec.fob_point := p6_a17;
    ddx_header_val_rec.freight_terms := p6_a18;
    ddx_header_val_rec.invoice_to_address1 := p6_a19;
    ddx_header_val_rec.invoice_to_address2 := p6_a20;
    ddx_header_val_rec.invoice_to_address3 := p6_a21;
    ddx_header_val_rec.invoice_to_address4 := p6_a22;
    ddx_header_val_rec.invoice_to_state := p6_a23;
    ddx_header_val_rec.invoice_to_city := p6_a24;
    ddx_header_val_rec.invoice_to_zip := p6_a25;
    ddx_header_val_rec.invoice_to_country := p6_a26;
    ddx_header_val_rec.invoice_to_county := p6_a27;
    ddx_header_val_rec.invoice_to_province := p6_a28;
    ddx_header_val_rec.invoice_to_contact := p6_a29;
    ddx_header_val_rec.invoice_to_contact_first_name := p6_a30;
    ddx_header_val_rec.invoice_to_contact_last_name := p6_a31;
    ddx_header_val_rec.invoice_to_location := p6_a32;
    ddx_header_val_rec.invoice_to_org := p6_a33;
    ddx_header_val_rec.invoicing_rule := p6_a34;
    ddx_header_val_rec.order_source := p6_a35;
    ddx_header_val_rec.order_type := p6_a36;
    ddx_header_val_rec.payment_term := p6_a37;
    ddx_header_val_rec.price_list := p6_a38;
    ddx_header_val_rec.return_reason := p6_a39;
    ddx_header_val_rec.salesrep := p6_a40;
    ddx_header_val_rec.shipment_priority := p6_a41;
    ddx_header_val_rec.ship_from_address1 := p6_a42;
    ddx_header_val_rec.ship_from_address2 := p6_a43;
    ddx_header_val_rec.ship_from_address3 := p6_a44;
    ddx_header_val_rec.ship_from_address4 := p6_a45;
    ddx_header_val_rec.ship_from_location := p6_a46;
    ddx_header_val_rec.ship_from_city := p6_a47;
    ddx_header_val_rec.ship_from_postal_code := p6_a48;
    ddx_header_val_rec.ship_from_country := p6_a49;
    ddx_header_val_rec.ship_from_region1 := p6_a50;
    ddx_header_val_rec.ship_from_region2 := p6_a51;
    ddx_header_val_rec.ship_from_region3 := p6_a52;
    ddx_header_val_rec.ship_from_org := p6_a53;
    ddx_header_val_rec.sold_to_address1 := p6_a54;
    ddx_header_val_rec.sold_to_address2 := p6_a55;
    ddx_header_val_rec.sold_to_address3 := p6_a56;
    ddx_header_val_rec.sold_to_address4 := p6_a57;
    ddx_header_val_rec.sold_to_state := p6_a58;
    ddx_header_val_rec.sold_to_country := p6_a59;
    ddx_header_val_rec.sold_to_zip := p6_a60;
    ddx_header_val_rec.sold_to_county := p6_a61;
    ddx_header_val_rec.sold_to_province := p6_a62;
    ddx_header_val_rec.sold_to_city := p6_a63;
    ddx_header_val_rec.sold_to_contact_last_name := p6_a64;
    ddx_header_val_rec.sold_to_contact_first_name := p6_a65;
    ddx_header_val_rec.ship_to_address1 := p6_a66;
    ddx_header_val_rec.ship_to_address2 := p6_a67;
    ddx_header_val_rec.ship_to_address3 := p6_a68;
    ddx_header_val_rec.ship_to_address4 := p6_a69;
    ddx_header_val_rec.ship_to_state := p6_a70;
    ddx_header_val_rec.ship_to_country := p6_a71;
    ddx_header_val_rec.ship_to_zip := p6_a72;
    ddx_header_val_rec.ship_to_county := p6_a73;
    ddx_header_val_rec.ship_to_province := p6_a74;
    ddx_header_val_rec.ship_to_city := p6_a75;
    ddx_header_val_rec.ship_to_contact := p6_a76;
    ddx_header_val_rec.ship_to_contact_last_name := p6_a77;
    ddx_header_val_rec.ship_to_contact_first_name := p6_a78;
    ddx_header_val_rec.ship_to_location := p6_a79;
    ddx_header_val_rec.ship_to_org := p6_a80;
    ddx_header_val_rec.sold_to_contact := p6_a81;
    ddx_header_val_rec.sold_to_org := p6_a82;
    ddx_header_val_rec.sold_from_org := p6_a83;
    ddx_header_val_rec.tax_exempt := p6_a84;
    ddx_header_val_rec.tax_exempt_reason := p6_a85;
    ddx_header_val_rec.tax_point := p6_a86;
    ddx_header_val_rec.customer_payment_term := p6_a87;
    ddx_header_val_rec.payment_type := p6_a88;
    ddx_header_val_rec.credit_card := p6_a89;
    ddx_header_val_rec.status := p6_a90;
    ddx_header_val_rec.freight_carrier := p6_a91;
    ddx_header_val_rec.shipping_method := p6_a92;
    ddx_header_val_rec.order_date_type := p6_a93;
    ddx_header_val_rec.customer_number := p6_a94;
    ddx_header_val_rec.ship_to_customer_name := p6_a95;
    ddx_header_val_rec.invoice_to_customer_name := p6_a96;
    ddx_header_val_rec.sales_channel := p6_a97;
    ddx_header_val_rec.ship_to_customer_number := p6_a98;
    ddx_header_val_rec.invoice_to_customer_number := p6_a99;
    ddx_header_val_rec.ship_to_customer_id := rosetta_g_miss_num_map(p6_a100);
    ddx_header_val_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p6_a101);
    ddx_header_val_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p6_a102);
    ddx_header_val_rec.deliver_to_customer_number := p6_a103;
    ddx_header_val_rec.deliver_to_customer_name := p6_a104;
    ddx_header_val_rec.deliver_to_customer_number_oi := p6_a105;
    ddx_header_val_rec.deliver_to_customer_name_oi := p6_a106;
    ddx_header_val_rec.ship_to_customer_number_oi := p6_a107;
    ddx_header_val_rec.ship_to_customer_name_oi := p6_a108;
    ddx_header_val_rec.invoice_to_customer_number_oi := p6_a109;
    ddx_header_val_rec.invoice_to_customer_name_oi := p6_a110;
    ddx_header_val_rec.user_status := p6_a111;
    ddx_header_val_rec.transaction_phase := p6_a112;
    ddx_header_val_rec.sold_to_location_address1 := p6_a113;
    ddx_header_val_rec.sold_to_location_address2 := p6_a114;
    ddx_header_val_rec.sold_to_location_address3 := p6_a115;
    ddx_header_val_rec.sold_to_location_address4 := p6_a116;
    ddx_header_val_rec.sold_to_location := p6_a117;
    ddx_header_val_rec.sold_to_location_city := p6_a118;
    ddx_header_val_rec.sold_to_location_state := p6_a119;
    ddx_header_val_rec.sold_to_location_postal := p6_a120;
    ddx_header_val_rec.sold_to_location_country := p6_a121;
    ddx_header_val_rec.sold_to_location_county := p6_a122;
    ddx_header_val_rec.sold_to_location_province := p6_a123;
    ddx_header_val_rec.end_customer_name := p6_a124;
    ddx_header_val_rec.end_customer_number := p6_a125;
    ddx_header_val_rec.end_customer_contact := p6_a126;
    ddx_header_val_rec.end_cust_contact_last_name := p6_a127;
    ddx_header_val_rec.end_cust_contact_first_name := p6_a128;
    ddx_header_val_rec.end_customer_site_address1 := p6_a129;
    ddx_header_val_rec.end_customer_site_address2 := p6_a130;
    ddx_header_val_rec.end_customer_site_address3 := p6_a131;
    ddx_header_val_rec.end_customer_site_address4 := p6_a132;
    ddx_header_val_rec.end_customer_site_state := p6_a133;
    ddx_header_val_rec.end_customer_site_country := p6_a134;
    ddx_header_val_rec.end_customer_site_location := p6_a135;
    ddx_header_val_rec.end_customer_site_zip := p6_a136;
    ddx_header_val_rec.end_customer_site_county := p6_a137;
    ddx_header_val_rec.end_customer_site_province := p6_a138;
    ddx_header_val_rec.end_customer_site_city := p6_a139;
    ddx_header_val_rec.end_customer_site_postal_code := p6_a140;
    ddx_header_val_rec.blanket_agreement_name := p6_a141;

    ddx_old_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddx_old_header_rec.agreement_id := rosetta_g_miss_num_map(p7_a1);
    ddx_old_header_rec.attribute1 := p7_a2;
    ddx_old_header_rec.attribute10 := p7_a3;
    ddx_old_header_rec.attribute11 := p7_a4;
    ddx_old_header_rec.attribute12 := p7_a5;
    ddx_old_header_rec.attribute13 := p7_a6;
    ddx_old_header_rec.attribute14 := p7_a7;
    ddx_old_header_rec.attribute15 := p7_a8;
    ddx_old_header_rec.attribute16 := p7_a9;
    ddx_old_header_rec.attribute17 := p7_a10;
    ddx_old_header_rec.attribute18 := p7_a11;
    ddx_old_header_rec.attribute19 := p7_a12;
    ddx_old_header_rec.attribute2 := p7_a13;
    ddx_old_header_rec.attribute20 := p7_a14;
    ddx_old_header_rec.attribute3 := p7_a15;
    ddx_old_header_rec.attribute4 := p7_a16;
    ddx_old_header_rec.attribute5 := p7_a17;
    ddx_old_header_rec.attribute6 := p7_a18;
    ddx_old_header_rec.attribute7 := p7_a19;
    ddx_old_header_rec.attribute8 := p7_a20;
    ddx_old_header_rec.attribute9 := p7_a21;
    ddx_old_header_rec.booked_flag := p7_a22;
    ddx_old_header_rec.cancelled_flag := p7_a23;
    ddx_old_header_rec.context := p7_a24;
    ddx_old_header_rec.conversion_rate := rosetta_g_miss_num_map(p7_a25);
    ddx_old_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p7_a26);
    ddx_old_header_rec.conversion_type_code := p7_a27;
    ddx_old_header_rec.customer_preference_set_code := p7_a28;
    ddx_old_header_rec.created_by := rosetta_g_miss_num_map(p7_a29);
    ddx_old_header_rec.creation_date := rosetta_g_miss_date_in_map(p7_a30);
    ddx_old_header_rec.cust_po_number := p7_a31;
    ddx_old_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p7_a32);
    ddx_old_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p7_a33);
    ddx_old_header_rec.demand_class_code := p7_a34;
    ddx_old_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p7_a35);
    ddx_old_header_rec.expiration_date := rosetta_g_miss_date_in_map(p7_a36);
    ddx_old_header_rec.fob_point_code := p7_a37;
    ddx_old_header_rec.freight_carrier_code := p7_a38;
    ddx_old_header_rec.freight_terms_code := p7_a39;
    ddx_old_header_rec.global_attribute1 := p7_a40;
    ddx_old_header_rec.global_attribute10 := p7_a41;
    ddx_old_header_rec.global_attribute11 := p7_a42;
    ddx_old_header_rec.global_attribute12 := p7_a43;
    ddx_old_header_rec.global_attribute13 := p7_a44;
    ddx_old_header_rec.global_attribute14 := p7_a45;
    ddx_old_header_rec.global_attribute15 := p7_a46;
    ddx_old_header_rec.global_attribute16 := p7_a47;
    ddx_old_header_rec.global_attribute17 := p7_a48;
    ddx_old_header_rec.global_attribute18 := p7_a49;
    ddx_old_header_rec.global_attribute19 := p7_a50;
    ddx_old_header_rec.global_attribute2 := p7_a51;
    ddx_old_header_rec.global_attribute20 := p7_a52;
    ddx_old_header_rec.global_attribute3 := p7_a53;
    ddx_old_header_rec.global_attribute4 := p7_a54;
    ddx_old_header_rec.global_attribute5 := p7_a55;
    ddx_old_header_rec.global_attribute6 := p7_a56;
    ddx_old_header_rec.global_attribute7 := p7_a57;
    ddx_old_header_rec.global_attribute8 := p7_a58;
    ddx_old_header_rec.global_attribute9 := p7_a59;
    ddx_old_header_rec.global_attribute_category := p7_a60;
    ddx_old_header_rec.tp_context := p7_a61;
    ddx_old_header_rec.tp_attribute1 := p7_a62;
    ddx_old_header_rec.tp_attribute2 := p7_a63;
    ddx_old_header_rec.tp_attribute3 := p7_a64;
    ddx_old_header_rec.tp_attribute4 := p7_a65;
    ddx_old_header_rec.tp_attribute5 := p7_a66;
    ddx_old_header_rec.tp_attribute6 := p7_a67;
    ddx_old_header_rec.tp_attribute7 := p7_a68;
    ddx_old_header_rec.tp_attribute8 := p7_a69;
    ddx_old_header_rec.tp_attribute9 := p7_a70;
    ddx_old_header_rec.tp_attribute10 := p7_a71;
    ddx_old_header_rec.tp_attribute11 := p7_a72;
    ddx_old_header_rec.tp_attribute12 := p7_a73;
    ddx_old_header_rec.tp_attribute13 := p7_a74;
    ddx_old_header_rec.tp_attribute14 := p7_a75;
    ddx_old_header_rec.tp_attribute15 := p7_a76;
    ddx_old_header_rec.header_id := rosetta_g_miss_num_map(p7_a77);
    ddx_old_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p7_a78);
    ddx_old_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p7_a79);
    ddx_old_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p7_a80);
    ddx_old_header_rec.last_updated_by := rosetta_g_miss_num_map(p7_a81);
    ddx_old_header_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a82);
    ddx_old_header_rec.last_update_login := rosetta_g_miss_num_map(p7_a83);
    ddx_old_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p7_a84);
    ddx_old_header_rec.open_flag := p7_a85;
    ddx_old_header_rec.order_category_code := p7_a86;
    ddx_old_header_rec.ordered_date := rosetta_g_miss_date_in_map(p7_a87);
    ddx_old_header_rec.order_date_type_code := p7_a88;
    ddx_old_header_rec.order_number := rosetta_g_miss_num_map(p7_a89);
    ddx_old_header_rec.order_source_id := rosetta_g_miss_num_map(p7_a90);
    ddx_old_header_rec.order_type_id := rosetta_g_miss_num_map(p7_a91);
    ddx_old_header_rec.org_id := rosetta_g_miss_num_map(p7_a92);
    ddx_old_header_rec.orig_sys_document_ref := p7_a93;
    ddx_old_header_rec.partial_shipments_allowed := p7_a94;
    ddx_old_header_rec.payment_term_id := rosetta_g_miss_num_map(p7_a95);
    ddx_old_header_rec.price_list_id := rosetta_g_miss_num_map(p7_a96);
    ddx_old_header_rec.price_request_code := p7_a97;
    ddx_old_header_rec.pricing_date := rosetta_g_miss_date_in_map(p7_a98);
    ddx_old_header_rec.program_application_id := rosetta_g_miss_num_map(p7_a99);
    ddx_old_header_rec.program_id := rosetta_g_miss_num_map(p7_a100);
    ddx_old_header_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a101);
    ddx_old_header_rec.request_date := rosetta_g_miss_date_in_map(p7_a102);
    ddx_old_header_rec.request_id := rosetta_g_miss_num_map(p7_a103);
    ddx_old_header_rec.return_reason_code := p7_a104;
    ddx_old_header_rec.salesrep_id := rosetta_g_miss_num_map(p7_a105);
    ddx_old_header_rec.sales_channel_code := p7_a106;
    ddx_old_header_rec.shipment_priority_code := p7_a107;
    ddx_old_header_rec.shipping_method_code := p7_a108;
    ddx_old_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p7_a109);
    ddx_old_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p7_a110);
    ddx_old_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p7_a111);
    ddx_old_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p7_a112);
    ddx_old_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p7_a113);
    ddx_old_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p7_a114);
    ddx_old_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p7_a115);
    ddx_old_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p7_a116);
    ddx_old_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p7_a117);
    ddx_old_header_rec.source_document_id := rosetta_g_miss_num_map(p7_a118);
    ddx_old_header_rec.source_document_type_id := rosetta_g_miss_num_map(p7_a119);
    ddx_old_header_rec.tax_exempt_flag := p7_a120;
    ddx_old_header_rec.tax_exempt_number := p7_a121;
    ddx_old_header_rec.tax_exempt_reason_code := p7_a122;
    ddx_old_header_rec.tax_point_code := p7_a123;
    ddx_old_header_rec.transactional_curr_code := p7_a124;
    ddx_old_header_rec.version_number := rosetta_g_miss_num_map(p7_a125);
    ddx_old_header_rec.return_status := p7_a126;
    ddx_old_header_rec.db_flag := p7_a127;
    ddx_old_header_rec.operation := p7_a128;
    ddx_old_header_rec.first_ack_code := p7_a129;
    ddx_old_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p7_a130);
    ddx_old_header_rec.last_ack_code := p7_a131;
    ddx_old_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p7_a132);
    ddx_old_header_rec.change_reason := p7_a133;
    ddx_old_header_rec.change_comments := p7_a134;
    ddx_old_header_rec.change_sequence := p7_a135;
    ddx_old_header_rec.change_request_code := p7_a136;
    ddx_old_header_rec.ready_flag := p7_a137;
    ddx_old_header_rec.status_flag := p7_a138;
    ddx_old_header_rec.force_apply_flag := p7_a139;
    ddx_old_header_rec.drop_ship_flag := p7_a140;
    ddx_old_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p7_a141);
    ddx_old_header_rec.payment_type_code := p7_a142;
    ddx_old_header_rec.payment_amount := rosetta_g_miss_num_map(p7_a143);
    ddx_old_header_rec.check_number := p7_a144;
    ddx_old_header_rec.credit_card_code := p7_a145;
    ddx_old_header_rec.credit_card_holder_name := p7_a146;
    ddx_old_header_rec.credit_card_number := p7_a147;
    ddx_old_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p7_a148);
    ddx_old_header_rec.credit_card_approval_code := p7_a149;
    ddx_old_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p7_a150);
    ddx_old_header_rec.shipping_instructions := p7_a151;
    ddx_old_header_rec.packing_instructions := p7_a152;
    ddx_old_header_rec.flow_status_code := p7_a153;
    ddx_old_header_rec.booked_date := rosetta_g_miss_date_in_map(p7_a154);
    ddx_old_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p7_a155);
    ddx_old_header_rec.upgraded_flag := p7_a156;
    ddx_old_header_rec.lock_control := rosetta_g_miss_num_map(p7_a157);
    ddx_old_header_rec.ship_to_edi_location_code := p7_a158;
    ddx_old_header_rec.sold_to_edi_location_code := p7_a159;
    ddx_old_header_rec.bill_to_edi_location_code := p7_a160;
    ddx_old_header_rec.ship_from_edi_location_code := p7_a161;
    ddx_old_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p7_a162);
    ddx_old_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p7_a163);
    ddx_old_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p7_a164);
    ddx_old_header_rec.invoice_address_id := rosetta_g_miss_num_map(p7_a165);
    ddx_old_header_rec.ship_to_address_code := p7_a166;
    ddx_old_header_rec.xml_message_id := rosetta_g_miss_num_map(p7_a167);
    ddx_old_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p7_a168);
    ddx_old_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p7_a169);
    ddx_old_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p7_a170);
    ddx_old_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p7_a171);
    ddx_old_header_rec.xml_transaction_type_code := p7_a172;
    ddx_old_header_rec.blanket_number := rosetta_g_miss_num_map(p7_a173);
    ddx_old_header_rec.line_set_name := p7_a174;
    ddx_old_header_rec.fulfillment_set_name := p7_a175;
    ddx_old_header_rec.default_fulfillment_set := p7_a176;
    ddx_old_header_rec.quote_date := rosetta_g_miss_date_in_map(p7_a177);
    ddx_old_header_rec.quote_number := rosetta_g_miss_num_map(p7_a178);
    ddx_old_header_rec.sales_document_name := p7_a179;
    ddx_old_header_rec.transaction_phase_code := p7_a180;
    ddx_old_header_rec.user_status_code := p7_a181;
    ddx_old_header_rec.draft_submitted_flag := p7_a182;
    ddx_old_header_rec.source_document_version_number := rosetta_g_miss_num_map(p7_a183);
    ddx_old_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p7_a184);
    ddx_old_header_rec.minisite_id := rosetta_g_miss_num_map(p7_a185);
    ddx_old_header_rec.ib_owner := p7_a186;
    ddx_old_header_rec.ib_installed_at_location := p7_a187;
    ddx_old_header_rec.ib_current_location := p7_a188;
    ddx_old_header_rec.end_customer_id := rosetta_g_miss_num_map(p7_a189);
    ddx_old_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p7_a190);
    ddx_old_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p7_a191);
    ddx_old_header_rec.supplier_signature := p7_a192;
    ddx_old_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p7_a193);
    ddx_old_header_rec.customer_signature := p7_a194;
    ddx_old_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p7_a195);
    ddx_old_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p7_a196);
    ddx_old_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p7_a197);
    ddx_old_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p7_a198);
    ddx_old_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p7_a199);
    ddx_old_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p7_a200);
    ddx_old_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p7_a201);
    ddx_old_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p7_a202);
    ddx_old_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p7_a203);
    ddx_old_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p7_a204);
    ddx_old_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p7_a205);
    ddx_old_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p7_a206);
    ddx_old_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p7_a207);
    ddx_old_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p7_a208);
    ddx_old_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p7_a209);
    ddx_old_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p7_a210);
    ddx_old_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p7_a211);
    ddx_old_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p7_a212);
    ddx_old_header_rec.contract_template_id := rosetta_g_miss_num_map(p7_a213);
    ddx_old_header_rec.contract_source_doc_type_code := p7_a214;
    ddx_old_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p7_a215);

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_header.save_header(x_return_status,
      x_msg_count,
      x_msg_data,
      p_header_id,
      ddp_process,
      ddx_header_rec,
      ddx_header_val_rec,
      ddx_old_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    p5_a0 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_id);
    p5_a1 := rosetta_g_miss_num_map(ddx_header_rec.agreement_id);
    p5_a2 := ddx_header_rec.attribute1;
    p5_a3 := ddx_header_rec.attribute10;
    p5_a4 := ddx_header_rec.attribute11;
    p5_a5 := ddx_header_rec.attribute12;
    p5_a6 := ddx_header_rec.attribute13;
    p5_a7 := ddx_header_rec.attribute14;
    p5_a8 := ddx_header_rec.attribute15;
    p5_a9 := ddx_header_rec.attribute16;
    p5_a10 := ddx_header_rec.attribute17;
    p5_a11 := ddx_header_rec.attribute18;
    p5_a12 := ddx_header_rec.attribute19;
    p5_a13 := ddx_header_rec.attribute2;
    p5_a14 := ddx_header_rec.attribute20;
    p5_a15 := ddx_header_rec.attribute3;
    p5_a16 := ddx_header_rec.attribute4;
    p5_a17 := ddx_header_rec.attribute5;
    p5_a18 := ddx_header_rec.attribute6;
    p5_a19 := ddx_header_rec.attribute7;
    p5_a20 := ddx_header_rec.attribute8;
    p5_a21 := ddx_header_rec.attribute9;
    p5_a22 := ddx_header_rec.booked_flag;
    p5_a23 := ddx_header_rec.cancelled_flag;
    p5_a24 := ddx_header_rec.context;
    p5_a25 := rosetta_g_miss_num_map(ddx_header_rec.conversion_rate);
    p5_a26 := ddx_header_rec.conversion_rate_date;
    p5_a27 := ddx_header_rec.conversion_type_code;
    p5_a28 := ddx_header_rec.customer_preference_set_code;
    p5_a29 := rosetta_g_miss_num_map(ddx_header_rec.created_by);
    p5_a30 := ddx_header_rec.creation_date;
    p5_a31 := ddx_header_rec.cust_po_number;
    p5_a32 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_contact_id);
    p5_a33 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_id);
    p5_a34 := ddx_header_rec.demand_class_code;
    p5_a35 := rosetta_g_miss_num_map(ddx_header_rec.earliest_schedule_limit);
    p5_a36 := ddx_header_rec.expiration_date;
    p5_a37 := ddx_header_rec.fob_point_code;
    p5_a38 := ddx_header_rec.freight_carrier_code;
    p5_a39 := ddx_header_rec.freight_terms_code;
    p5_a40 := ddx_header_rec.global_attribute1;
    p5_a41 := ddx_header_rec.global_attribute10;
    p5_a42 := ddx_header_rec.global_attribute11;
    p5_a43 := ddx_header_rec.global_attribute12;
    p5_a44 := ddx_header_rec.global_attribute13;
    p5_a45 := ddx_header_rec.global_attribute14;
    p5_a46 := ddx_header_rec.global_attribute15;
    p5_a47 := ddx_header_rec.global_attribute16;
    p5_a48 := ddx_header_rec.global_attribute17;
    p5_a49 := ddx_header_rec.global_attribute18;
    p5_a50 := ddx_header_rec.global_attribute19;
    p5_a51 := ddx_header_rec.global_attribute2;
    p5_a52 := ddx_header_rec.global_attribute20;
    p5_a53 := ddx_header_rec.global_attribute3;
    p5_a54 := ddx_header_rec.global_attribute4;
    p5_a55 := ddx_header_rec.global_attribute5;
    p5_a56 := ddx_header_rec.global_attribute6;
    p5_a57 := ddx_header_rec.global_attribute7;
    p5_a58 := ddx_header_rec.global_attribute8;
    p5_a59 := ddx_header_rec.global_attribute9;
    p5_a60 := ddx_header_rec.global_attribute_category;
    p5_a61 := ddx_header_rec.tp_context;
    p5_a62 := ddx_header_rec.tp_attribute1;
    p5_a63 := ddx_header_rec.tp_attribute2;
    p5_a64 := ddx_header_rec.tp_attribute3;
    p5_a65 := ddx_header_rec.tp_attribute4;
    p5_a66 := ddx_header_rec.tp_attribute5;
    p5_a67 := ddx_header_rec.tp_attribute6;
    p5_a68 := ddx_header_rec.tp_attribute7;
    p5_a69 := ddx_header_rec.tp_attribute8;
    p5_a70 := ddx_header_rec.tp_attribute9;
    p5_a71 := ddx_header_rec.tp_attribute10;
    p5_a72 := ddx_header_rec.tp_attribute11;
    p5_a73 := ddx_header_rec.tp_attribute12;
    p5_a74 := ddx_header_rec.tp_attribute13;
    p5_a75 := ddx_header_rec.tp_attribute14;
    p5_a76 := ddx_header_rec.tp_attribute15;
    p5_a77 := rosetta_g_miss_num_map(ddx_header_rec.header_id);
    p5_a78 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_contact_id);
    p5_a79 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_id);
    p5_a80 := rosetta_g_miss_num_map(ddx_header_rec.invoicing_rule_id);
    p5_a81 := rosetta_g_miss_num_map(ddx_header_rec.last_updated_by);
    p5_a82 := ddx_header_rec.last_update_date;
    p5_a83 := rosetta_g_miss_num_map(ddx_header_rec.last_update_login);
    p5_a84 := rosetta_g_miss_num_map(ddx_header_rec.latest_schedule_limit);
    p5_a85 := ddx_header_rec.open_flag;
    p5_a86 := ddx_header_rec.order_category_code;
    p5_a87 := ddx_header_rec.ordered_date;
    p5_a88 := ddx_header_rec.order_date_type_code;
    p5_a89 := rosetta_g_miss_num_map(ddx_header_rec.order_number);
    p5_a90 := rosetta_g_miss_num_map(ddx_header_rec.order_source_id);
    p5_a91 := rosetta_g_miss_num_map(ddx_header_rec.order_type_id);
    p5_a92 := rosetta_g_miss_num_map(ddx_header_rec.org_id);
    p5_a93 := ddx_header_rec.orig_sys_document_ref;
    p5_a94 := ddx_header_rec.partial_shipments_allowed;
    p5_a95 := rosetta_g_miss_num_map(ddx_header_rec.payment_term_id);
    p5_a96 := rosetta_g_miss_num_map(ddx_header_rec.price_list_id);
    p5_a97 := ddx_header_rec.price_request_code;
    p5_a98 := ddx_header_rec.pricing_date;
    p5_a99 := rosetta_g_miss_num_map(ddx_header_rec.program_application_id);
    p5_a100 := rosetta_g_miss_num_map(ddx_header_rec.program_id);
    p5_a101 := ddx_header_rec.program_update_date;
    p5_a102 := ddx_header_rec.request_date;
    p5_a103 := rosetta_g_miss_num_map(ddx_header_rec.request_id);
    p5_a104 := ddx_header_rec.return_reason_code;
    p5_a105 := rosetta_g_miss_num_map(ddx_header_rec.salesrep_id);
    p5_a106 := ddx_header_rec.sales_channel_code;
    p5_a107 := ddx_header_rec.shipment_priority_code;
    p5_a108 := ddx_header_rec.shipping_method_code;
    p5_a109 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_org_id);
    p5_a110 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_above);
    p5_a111 := rosetta_g_miss_num_map(ddx_header_rec.ship_tolerance_below);
    p5_a112 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_contact_id);
    p5_a113 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_id);
    p5_a114 := rosetta_g_miss_num_map(ddx_header_rec.sold_from_org_id);
    p5_a115 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_contact_id);
    p5_a116 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_id);
    p5_a117 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_phone_id);
    p5_a118 := rosetta_g_miss_num_map(ddx_header_rec.source_document_id);
    p5_a119 := rosetta_g_miss_num_map(ddx_header_rec.source_document_type_id);
    p5_a120 := ddx_header_rec.tax_exempt_flag;
    p5_a121 := ddx_header_rec.tax_exempt_number;
    p5_a122 := ddx_header_rec.tax_exempt_reason_code;
    p5_a123 := ddx_header_rec.tax_point_code;
    p5_a124 := ddx_header_rec.transactional_curr_code;
    p5_a125 := rosetta_g_miss_num_map(ddx_header_rec.version_number);
    p5_a126 := ddx_header_rec.return_status;
    p5_a127 := ddx_header_rec.db_flag;
    p5_a128 := ddx_header_rec.operation;
    p5_a129 := ddx_header_rec.first_ack_code;
    p5_a130 := ddx_header_rec.first_ack_date;
    p5_a131 := ddx_header_rec.last_ack_code;
    p5_a132 := ddx_header_rec.last_ack_date;
    p5_a133 := ddx_header_rec.change_reason;
    p5_a134 := ddx_header_rec.change_comments;
    p5_a135 := ddx_header_rec.change_sequence;
    p5_a136 := ddx_header_rec.change_request_code;
    p5_a137 := ddx_header_rec.ready_flag;
    p5_a138 := ddx_header_rec.status_flag;
    p5_a139 := ddx_header_rec.force_apply_flag;
    p5_a140 := ddx_header_rec.drop_ship_flag;
    p5_a141 := rosetta_g_miss_num_map(ddx_header_rec.customer_payment_term_id);
    p5_a142 := ddx_header_rec.payment_type_code;
    p5_a143 := rosetta_g_miss_num_map(ddx_header_rec.payment_amount);
    p5_a144 := ddx_header_rec.check_number;
    p5_a145 := ddx_header_rec.credit_card_code;
    p5_a146 := ddx_header_rec.credit_card_holder_name;
    p5_a147 := ddx_header_rec.credit_card_number;
    p5_a148 := ddx_header_rec.credit_card_expiration_date;
    p5_a149 := ddx_header_rec.credit_card_approval_code;
    p5_a150 := ddx_header_rec.credit_card_approval_date;
    p5_a151 := ddx_header_rec.shipping_instructions;
    p5_a152 := ddx_header_rec.packing_instructions;
    p5_a153 := ddx_header_rec.flow_status_code;
    p5_a154 := ddx_header_rec.booked_date;
    p5_a155 := rosetta_g_miss_num_map(ddx_header_rec.marketing_source_code_id);
    p5_a156 := ddx_header_rec.upgraded_flag;
    p5_a157 := rosetta_g_miss_num_map(ddx_header_rec.lock_control);
    p5_a158 := ddx_header_rec.ship_to_edi_location_code;
    p5_a159 := ddx_header_rec.sold_to_edi_location_code;
    p5_a160 := ddx_header_rec.bill_to_edi_location_code;
    p5_a161 := ddx_header_rec.ship_from_edi_location_code;
    p5_a162 := rosetta_g_miss_num_map(ddx_header_rec.ship_from_address_id);
    p5_a163 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_address_id);
    p5_a164 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_address_id);
    p5_a165 := rosetta_g_miss_num_map(ddx_header_rec.invoice_address_id);
    p5_a166 := ddx_header_rec.ship_to_address_code;
    p5_a167 := rosetta_g_miss_num_map(ddx_header_rec.xml_message_id);
    p5_a168 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_id);
    p5_a169 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_id);
    p5_a170 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_id);
    p5_a171 := rosetta_g_miss_num_map(ddx_header_rec.accounting_rule_duration);
    p5_a172 := ddx_header_rec.xml_transaction_type_code;
    p5_a173 := rosetta_g_miss_num_map(ddx_header_rec.blanket_number);
    p5_a174 := ddx_header_rec.line_set_name;
    p5_a175 := ddx_header_rec.fulfillment_set_name;
    p5_a176 := ddx_header_rec.default_fulfillment_set;
    p5_a177 := ddx_header_rec.quote_date;
    p5_a178 := rosetta_g_miss_num_map(ddx_header_rec.quote_number);
    p5_a179 := ddx_header_rec.sales_document_name;
    p5_a180 := ddx_header_rec.transaction_phase_code;
    p5_a181 := ddx_header_rec.user_status_code;
    p5_a182 := ddx_header_rec.draft_submitted_flag;
    p5_a183 := rosetta_g_miss_num_map(ddx_header_rec.source_document_version_number);
    p5_a184 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_site_use_id);
    p5_a185 := rosetta_g_miss_num_map(ddx_header_rec.minisite_id);
    p5_a186 := ddx_header_rec.ib_owner;
    p5_a187 := ddx_header_rec.ib_installed_at_location;
    p5_a188 := ddx_header_rec.ib_current_location;
    p5_a189 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_id);
    p5_a190 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_contact_id);
    p5_a191 := rosetta_g_miss_num_map(ddx_header_rec.end_customer_site_use_id);
    p5_a192 := ddx_header_rec.supplier_signature;
    p5_a193 := ddx_header_rec.supplier_signature_date;
    p5_a194 := ddx_header_rec.customer_signature;
    p5_a195 := ddx_header_rec.customer_signature_date;
    p5_a196 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_party_id);
    p5_a197 := rosetta_g_miss_num_map(ddx_header_rec.sold_to_org_contact_id);
    p5_a198 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_id);
    p5_a199 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_id);
    p5_a200 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_party_site_use_id);
    p5_a201 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_id);
    p5_a202 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_id);
    p5_a203 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_party_site_use_id);
    p5_a204 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_id);
    p5_a205 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_id);
    p5_a206 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_party_site_use_id);
    p5_a207 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_customer_party_id);
    p5_a208 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_customer_party_id);
    p5_a209 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_customer_party_id);
    p5_a210 := rosetta_g_miss_num_map(ddx_header_rec.ship_to_org_contact_id);
    p5_a211 := rosetta_g_miss_num_map(ddx_header_rec.deliver_to_org_contact_id);
    p5_a212 := rosetta_g_miss_num_map(ddx_header_rec.invoice_to_org_contact_id);
    p5_a213 := rosetta_g_miss_num_map(ddx_header_rec.contract_template_id);
    p5_a214 := ddx_header_rec.contract_source_doc_type_code;
    p5_a215 := rosetta_g_miss_num_map(ddx_header_rec.contract_source_document_id);

    p6_a0 := ddx_header_val_rec.accounting_rule;
    p6_a1 := ddx_header_val_rec.agreement;
    p6_a2 := ddx_header_val_rec.conversion_type;
    p6_a3 := ddx_header_val_rec.deliver_to_address1;
    p6_a4 := ddx_header_val_rec.deliver_to_address2;
    p6_a5 := ddx_header_val_rec.deliver_to_address3;
    p6_a6 := ddx_header_val_rec.deliver_to_address4;
    p6_a7 := ddx_header_val_rec.deliver_to_contact;
    p6_a8 := ddx_header_val_rec.deliver_to_location;
    p6_a9 := ddx_header_val_rec.deliver_to_org;
    p6_a10 := ddx_header_val_rec.deliver_to_state;
    p6_a11 := ddx_header_val_rec.deliver_to_city;
    p6_a12 := ddx_header_val_rec.deliver_to_zip;
    p6_a13 := ddx_header_val_rec.deliver_to_country;
    p6_a14 := ddx_header_val_rec.deliver_to_county;
    p6_a15 := ddx_header_val_rec.deliver_to_province;
    p6_a16 := ddx_header_val_rec.demand_class;
    p6_a17 := ddx_header_val_rec.fob_point;
    p6_a18 := ddx_header_val_rec.freight_terms;
    p6_a19 := ddx_header_val_rec.invoice_to_address1;
    p6_a20 := ddx_header_val_rec.invoice_to_address2;
    p6_a21 := ddx_header_val_rec.invoice_to_address3;
    p6_a22 := ddx_header_val_rec.invoice_to_address4;
    p6_a23 := ddx_header_val_rec.invoice_to_state;
    p6_a24 := ddx_header_val_rec.invoice_to_city;
    p6_a25 := ddx_header_val_rec.invoice_to_zip;
    p6_a26 := ddx_header_val_rec.invoice_to_country;
    p6_a27 := ddx_header_val_rec.invoice_to_county;
    p6_a28 := ddx_header_val_rec.invoice_to_province;
    p6_a29 := ddx_header_val_rec.invoice_to_contact;
    p6_a30 := ddx_header_val_rec.invoice_to_contact_first_name;
    p6_a31 := ddx_header_val_rec.invoice_to_contact_last_name;
    p6_a32 := ddx_header_val_rec.invoice_to_location;
    p6_a33 := ddx_header_val_rec.invoice_to_org;
    p6_a34 := ddx_header_val_rec.invoicing_rule;
    p6_a35 := ddx_header_val_rec.order_source;
    p6_a36 := ddx_header_val_rec.order_type;
    p6_a37 := ddx_header_val_rec.payment_term;
    p6_a38 := ddx_header_val_rec.price_list;
    p6_a39 := ddx_header_val_rec.return_reason;
    p6_a40 := ddx_header_val_rec.salesrep;
    p6_a41 := ddx_header_val_rec.shipment_priority;
    p6_a42 := ddx_header_val_rec.ship_from_address1;
    p6_a43 := ddx_header_val_rec.ship_from_address2;
    p6_a44 := ddx_header_val_rec.ship_from_address3;
    p6_a45 := ddx_header_val_rec.ship_from_address4;
    p6_a46 := ddx_header_val_rec.ship_from_location;
    p6_a47 := ddx_header_val_rec.ship_from_city;
    p6_a48 := ddx_header_val_rec.ship_from_postal_code;
    p6_a49 := ddx_header_val_rec.ship_from_country;
    p6_a50 := ddx_header_val_rec.ship_from_region1;
    p6_a51 := ddx_header_val_rec.ship_from_region2;
    p6_a52 := ddx_header_val_rec.ship_from_region3;
    p6_a53 := ddx_header_val_rec.ship_from_org;
    p6_a54 := ddx_header_val_rec.sold_to_address1;
    p6_a55 := ddx_header_val_rec.sold_to_address2;
    p6_a56 := ddx_header_val_rec.sold_to_address3;
    p6_a57 := ddx_header_val_rec.sold_to_address4;
    p6_a58 := ddx_header_val_rec.sold_to_state;
    p6_a59 := ddx_header_val_rec.sold_to_country;
    p6_a60 := ddx_header_val_rec.sold_to_zip;
    p6_a61 := ddx_header_val_rec.sold_to_county;
    p6_a62 := ddx_header_val_rec.sold_to_province;
    p6_a63 := ddx_header_val_rec.sold_to_city;
    p6_a64 := ddx_header_val_rec.sold_to_contact_last_name;
    p6_a65 := ddx_header_val_rec.sold_to_contact_first_name;
    p6_a66 := ddx_header_val_rec.ship_to_address1;
    p6_a67 := ddx_header_val_rec.ship_to_address2;
    p6_a68 := ddx_header_val_rec.ship_to_address3;
    p6_a69 := ddx_header_val_rec.ship_to_address4;
    p6_a70 := ddx_header_val_rec.ship_to_state;
    p6_a71 := ddx_header_val_rec.ship_to_country;
    p6_a72 := ddx_header_val_rec.ship_to_zip;
    p6_a73 := ddx_header_val_rec.ship_to_county;
    p6_a74 := ddx_header_val_rec.ship_to_province;
    p6_a75 := ddx_header_val_rec.ship_to_city;
    p6_a76 := ddx_header_val_rec.ship_to_contact;
    p6_a77 := ddx_header_val_rec.ship_to_contact_last_name;
    p6_a78 := ddx_header_val_rec.ship_to_contact_first_name;
    p6_a79 := ddx_header_val_rec.ship_to_location;
    p6_a80 := ddx_header_val_rec.ship_to_org;
    p6_a81 := ddx_header_val_rec.sold_to_contact;
    p6_a82 := ddx_header_val_rec.sold_to_org;
    p6_a83 := ddx_header_val_rec.sold_from_org;
    p6_a84 := ddx_header_val_rec.tax_exempt;
    p6_a85 := ddx_header_val_rec.tax_exempt_reason;
    p6_a86 := ddx_header_val_rec.tax_point;
    p6_a87 := ddx_header_val_rec.customer_payment_term;
    p6_a88 := ddx_header_val_rec.payment_type;
    p6_a89 := ddx_header_val_rec.credit_card;
    p6_a90 := ddx_header_val_rec.status;
    p6_a91 := ddx_header_val_rec.freight_carrier;
    p6_a92 := ddx_header_val_rec.shipping_method;
    p6_a93 := ddx_header_val_rec.order_date_type;
    p6_a94 := ddx_header_val_rec.customer_number;
    p6_a95 := ddx_header_val_rec.ship_to_customer_name;
    p6_a96 := ddx_header_val_rec.invoice_to_customer_name;
    p6_a97 := ddx_header_val_rec.sales_channel;
    p6_a98 := ddx_header_val_rec.ship_to_customer_number;
    p6_a99 := ddx_header_val_rec.invoice_to_customer_number;
    p6_a100 := rosetta_g_miss_num_map(ddx_header_val_rec.ship_to_customer_id);
    p6_a101 := rosetta_g_miss_num_map(ddx_header_val_rec.invoice_to_customer_id);
    p6_a102 := rosetta_g_miss_num_map(ddx_header_val_rec.deliver_to_customer_id);
    p6_a103 := ddx_header_val_rec.deliver_to_customer_number;
    p6_a104 := ddx_header_val_rec.deliver_to_customer_name;
    p6_a105 := ddx_header_val_rec.deliver_to_customer_number_oi;
    p6_a106 := ddx_header_val_rec.deliver_to_customer_name_oi;
    p6_a107 := ddx_header_val_rec.ship_to_customer_number_oi;
    p6_a108 := ddx_header_val_rec.ship_to_customer_name_oi;
    p6_a109 := ddx_header_val_rec.invoice_to_customer_number_oi;
    p6_a110 := ddx_header_val_rec.invoice_to_customer_name_oi;
    p6_a111 := ddx_header_val_rec.user_status;
    p6_a112 := ddx_header_val_rec.transaction_phase;
    p6_a113 := ddx_header_val_rec.sold_to_location_address1;
    p6_a114 := ddx_header_val_rec.sold_to_location_address2;
    p6_a115 := ddx_header_val_rec.sold_to_location_address3;
    p6_a116 := ddx_header_val_rec.sold_to_location_address4;
    p6_a117 := ddx_header_val_rec.sold_to_location;
    p6_a118 := ddx_header_val_rec.sold_to_location_city;
    p6_a119 := ddx_header_val_rec.sold_to_location_state;
    p6_a120 := ddx_header_val_rec.sold_to_location_postal;
    p6_a121 := ddx_header_val_rec.sold_to_location_country;
    p6_a122 := ddx_header_val_rec.sold_to_location_county;
    p6_a123 := ddx_header_val_rec.sold_to_location_province;
    p6_a124 := ddx_header_val_rec.end_customer_name;
    p6_a125 := ddx_header_val_rec.end_customer_number;
    p6_a126 := ddx_header_val_rec.end_customer_contact;
    p6_a127 := ddx_header_val_rec.end_cust_contact_last_name;
    p6_a128 := ddx_header_val_rec.end_cust_contact_first_name;
    p6_a129 := ddx_header_val_rec.end_customer_site_address1;
    p6_a130 := ddx_header_val_rec.end_customer_site_address2;
    p6_a131 := ddx_header_val_rec.end_customer_site_address3;
    p6_a132 := ddx_header_val_rec.end_customer_site_address4;
    p6_a133 := ddx_header_val_rec.end_customer_site_state;
    p6_a134 := ddx_header_val_rec.end_customer_site_country;
    p6_a135 := ddx_header_val_rec.end_customer_site_location;
    p6_a136 := ddx_header_val_rec.end_customer_site_zip;
    p6_a137 := ddx_header_val_rec.end_customer_site_county;
    p6_a138 := ddx_header_val_rec.end_customer_site_province;
    p6_a139 := ddx_header_val_rec.end_customer_site_city;
    p6_a140 := ddx_header_val_rec.end_customer_site_postal_code;
    p6_a141 := ddx_header_val_rec.blanket_agreement_name;

    p7_a0 := rosetta_g_miss_num_map(ddx_old_header_rec.accounting_rule_id);
    p7_a1 := rosetta_g_miss_num_map(ddx_old_header_rec.agreement_id);
    p7_a2 := ddx_old_header_rec.attribute1;
    p7_a3 := ddx_old_header_rec.attribute10;
    p7_a4 := ddx_old_header_rec.attribute11;
    p7_a5 := ddx_old_header_rec.attribute12;
    p7_a6 := ddx_old_header_rec.attribute13;
    p7_a7 := ddx_old_header_rec.attribute14;
    p7_a8 := ddx_old_header_rec.attribute15;
    p7_a9 := ddx_old_header_rec.attribute16;
    p7_a10 := ddx_old_header_rec.attribute17;
    p7_a11 := ddx_old_header_rec.attribute18;
    p7_a12 := ddx_old_header_rec.attribute19;
    p7_a13 := ddx_old_header_rec.attribute2;
    p7_a14 := ddx_old_header_rec.attribute20;
    p7_a15 := ddx_old_header_rec.attribute3;
    p7_a16 := ddx_old_header_rec.attribute4;
    p7_a17 := ddx_old_header_rec.attribute5;
    p7_a18 := ddx_old_header_rec.attribute6;
    p7_a19 := ddx_old_header_rec.attribute7;
    p7_a20 := ddx_old_header_rec.attribute8;
    p7_a21 := ddx_old_header_rec.attribute9;
    p7_a22 := ddx_old_header_rec.booked_flag;
    p7_a23 := ddx_old_header_rec.cancelled_flag;
    p7_a24 := ddx_old_header_rec.context;
    p7_a25 := rosetta_g_miss_num_map(ddx_old_header_rec.conversion_rate);
    p7_a26 := ddx_old_header_rec.conversion_rate_date;
    p7_a27 := ddx_old_header_rec.conversion_type_code;
    p7_a28 := ddx_old_header_rec.customer_preference_set_code;
    p7_a29 := rosetta_g_miss_num_map(ddx_old_header_rec.created_by);
    p7_a30 := ddx_old_header_rec.creation_date;
    p7_a31 := ddx_old_header_rec.cust_po_number;
    p7_a32 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_contact_id);
    p7_a33 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_org_id);
    p7_a34 := ddx_old_header_rec.demand_class_code;
    p7_a35 := rosetta_g_miss_num_map(ddx_old_header_rec.earliest_schedule_limit);
    p7_a36 := ddx_old_header_rec.expiration_date;
    p7_a37 := ddx_old_header_rec.fob_point_code;
    p7_a38 := ddx_old_header_rec.freight_carrier_code;
    p7_a39 := ddx_old_header_rec.freight_terms_code;
    p7_a40 := ddx_old_header_rec.global_attribute1;
    p7_a41 := ddx_old_header_rec.global_attribute10;
    p7_a42 := ddx_old_header_rec.global_attribute11;
    p7_a43 := ddx_old_header_rec.global_attribute12;
    p7_a44 := ddx_old_header_rec.global_attribute13;
    p7_a45 := ddx_old_header_rec.global_attribute14;
    p7_a46 := ddx_old_header_rec.global_attribute15;
    p7_a47 := ddx_old_header_rec.global_attribute16;
    p7_a48 := ddx_old_header_rec.global_attribute17;
    p7_a49 := ddx_old_header_rec.global_attribute18;
    p7_a50 := ddx_old_header_rec.global_attribute19;
    p7_a51 := ddx_old_header_rec.global_attribute2;
    p7_a52 := ddx_old_header_rec.global_attribute20;
    p7_a53 := ddx_old_header_rec.global_attribute3;
    p7_a54 := ddx_old_header_rec.global_attribute4;
    p7_a55 := ddx_old_header_rec.global_attribute5;
    p7_a56 := ddx_old_header_rec.global_attribute6;
    p7_a57 := ddx_old_header_rec.global_attribute7;
    p7_a58 := ddx_old_header_rec.global_attribute8;
    p7_a59 := ddx_old_header_rec.global_attribute9;
    p7_a60 := ddx_old_header_rec.global_attribute_category;
    p7_a61 := ddx_old_header_rec.tp_context;
    p7_a62 := ddx_old_header_rec.tp_attribute1;
    p7_a63 := ddx_old_header_rec.tp_attribute2;
    p7_a64 := ddx_old_header_rec.tp_attribute3;
    p7_a65 := ddx_old_header_rec.tp_attribute4;
    p7_a66 := ddx_old_header_rec.tp_attribute5;
    p7_a67 := ddx_old_header_rec.tp_attribute6;
    p7_a68 := ddx_old_header_rec.tp_attribute7;
    p7_a69 := ddx_old_header_rec.tp_attribute8;
    p7_a70 := ddx_old_header_rec.tp_attribute9;
    p7_a71 := ddx_old_header_rec.tp_attribute10;
    p7_a72 := ddx_old_header_rec.tp_attribute11;
    p7_a73 := ddx_old_header_rec.tp_attribute12;
    p7_a74 := ddx_old_header_rec.tp_attribute13;
    p7_a75 := ddx_old_header_rec.tp_attribute14;
    p7_a76 := ddx_old_header_rec.tp_attribute15;
    p7_a77 := rosetta_g_miss_num_map(ddx_old_header_rec.header_id);
    p7_a78 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_contact_id);
    p7_a79 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_org_id);
    p7_a80 := rosetta_g_miss_num_map(ddx_old_header_rec.invoicing_rule_id);
    p7_a81 := rosetta_g_miss_num_map(ddx_old_header_rec.last_updated_by);
    p7_a82 := ddx_old_header_rec.last_update_date;
    p7_a83 := rosetta_g_miss_num_map(ddx_old_header_rec.last_update_login);
    p7_a84 := rosetta_g_miss_num_map(ddx_old_header_rec.latest_schedule_limit);
    p7_a85 := ddx_old_header_rec.open_flag;
    p7_a86 := ddx_old_header_rec.order_category_code;
    p7_a87 := ddx_old_header_rec.ordered_date;
    p7_a88 := ddx_old_header_rec.order_date_type_code;
    p7_a89 := rosetta_g_miss_num_map(ddx_old_header_rec.order_number);
    p7_a90 := rosetta_g_miss_num_map(ddx_old_header_rec.order_source_id);
    p7_a91 := rosetta_g_miss_num_map(ddx_old_header_rec.order_type_id);
    p7_a92 := rosetta_g_miss_num_map(ddx_old_header_rec.org_id);
    p7_a93 := ddx_old_header_rec.orig_sys_document_ref;
    p7_a94 := ddx_old_header_rec.partial_shipments_allowed;
    p7_a95 := rosetta_g_miss_num_map(ddx_old_header_rec.payment_term_id);
    p7_a96 := rosetta_g_miss_num_map(ddx_old_header_rec.price_list_id);
    p7_a97 := ddx_old_header_rec.price_request_code;
    p7_a98 := ddx_old_header_rec.pricing_date;
    p7_a99 := rosetta_g_miss_num_map(ddx_old_header_rec.program_application_id);
    p7_a100 := rosetta_g_miss_num_map(ddx_old_header_rec.program_id);
    p7_a101 := ddx_old_header_rec.program_update_date;
    p7_a102 := ddx_old_header_rec.request_date;
    p7_a103 := rosetta_g_miss_num_map(ddx_old_header_rec.request_id);
    p7_a104 := ddx_old_header_rec.return_reason_code;
    p7_a105 := rosetta_g_miss_num_map(ddx_old_header_rec.salesrep_id);
    p7_a106 := ddx_old_header_rec.sales_channel_code;
    p7_a107 := ddx_old_header_rec.shipment_priority_code;
    p7_a108 := ddx_old_header_rec.shipping_method_code;
    p7_a109 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_from_org_id);
    p7_a110 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_tolerance_above);
    p7_a111 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_tolerance_below);
    p7_a112 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_contact_id);
    p7_a113 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_org_id);
    p7_a114 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_from_org_id);
    p7_a115 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_contact_id);
    p7_a116 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_org_id);
    p7_a117 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_phone_id);
    p7_a118 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_id);
    p7_a119 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_type_id);
    p7_a120 := ddx_old_header_rec.tax_exempt_flag;
    p7_a121 := ddx_old_header_rec.tax_exempt_number;
    p7_a122 := ddx_old_header_rec.tax_exempt_reason_code;
    p7_a123 := ddx_old_header_rec.tax_point_code;
    p7_a124 := ddx_old_header_rec.transactional_curr_code;
    p7_a125 := rosetta_g_miss_num_map(ddx_old_header_rec.version_number);
    p7_a126 := ddx_old_header_rec.return_status;
    p7_a127 := ddx_old_header_rec.db_flag;
    p7_a128 := ddx_old_header_rec.operation;
    p7_a129 := ddx_old_header_rec.first_ack_code;
    p7_a130 := ddx_old_header_rec.first_ack_date;
    p7_a131 := ddx_old_header_rec.last_ack_code;
    p7_a132 := ddx_old_header_rec.last_ack_date;
    p7_a133 := ddx_old_header_rec.change_reason;
    p7_a134 := ddx_old_header_rec.change_comments;
    p7_a135 := ddx_old_header_rec.change_sequence;
    p7_a136 := ddx_old_header_rec.change_request_code;
    p7_a137 := ddx_old_header_rec.ready_flag;
    p7_a138 := ddx_old_header_rec.status_flag;
    p7_a139 := ddx_old_header_rec.force_apply_flag;
    p7_a140 := ddx_old_header_rec.drop_ship_flag;
    p7_a141 := rosetta_g_miss_num_map(ddx_old_header_rec.customer_payment_term_id);
    p7_a142 := ddx_old_header_rec.payment_type_code;
    p7_a143 := rosetta_g_miss_num_map(ddx_old_header_rec.payment_amount);
    p7_a144 := ddx_old_header_rec.check_number;
    p7_a145 := ddx_old_header_rec.credit_card_code;
    p7_a146 := ddx_old_header_rec.credit_card_holder_name;
    p7_a147 := ddx_old_header_rec.credit_card_number;
    p7_a148 := ddx_old_header_rec.credit_card_expiration_date;
    p7_a149 := ddx_old_header_rec.credit_card_approval_code;
    p7_a150 := ddx_old_header_rec.credit_card_approval_date;
    p7_a151 := ddx_old_header_rec.shipping_instructions;
    p7_a152 := ddx_old_header_rec.packing_instructions;
    p7_a153 := ddx_old_header_rec.flow_status_code;
    p7_a154 := ddx_old_header_rec.booked_date;
    p7_a155 := rosetta_g_miss_num_map(ddx_old_header_rec.marketing_source_code_id);
    p7_a156 := ddx_old_header_rec.upgraded_flag;
    p7_a157 := rosetta_g_miss_num_map(ddx_old_header_rec.lock_control);
    p7_a158 := ddx_old_header_rec.ship_to_edi_location_code;
    p7_a159 := ddx_old_header_rec.sold_to_edi_location_code;
    p7_a160 := ddx_old_header_rec.bill_to_edi_location_code;
    p7_a161 := ddx_old_header_rec.ship_from_edi_location_code;
    p7_a162 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_from_address_id);
    p7_a163 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_address_id);
    p7_a164 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_address_id);
    p7_a165 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_address_id);
    p7_a166 := ddx_old_header_rec.ship_to_address_code;
    p7_a167 := rosetta_g_miss_num_map(ddx_old_header_rec.xml_message_id);
    p7_a168 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_customer_id);
    p7_a169 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_customer_id);
    p7_a170 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_customer_id);
    p7_a171 := rosetta_g_miss_num_map(ddx_old_header_rec.accounting_rule_duration);
    p7_a172 := ddx_old_header_rec.xml_transaction_type_code;
    p7_a173 := rosetta_g_miss_num_map(ddx_old_header_rec.blanket_number);
    p7_a174 := ddx_old_header_rec.line_set_name;
    p7_a175 := ddx_old_header_rec.fulfillment_set_name;
    p7_a176 := ddx_old_header_rec.default_fulfillment_set;
    p7_a177 := ddx_old_header_rec.quote_date;
    p7_a178 := rosetta_g_miss_num_map(ddx_old_header_rec.quote_number);
    p7_a179 := ddx_old_header_rec.sales_document_name;
    p7_a180 := ddx_old_header_rec.transaction_phase_code;
    p7_a181 := ddx_old_header_rec.user_status_code;
    p7_a182 := ddx_old_header_rec.draft_submitted_flag;
    p7_a183 := rosetta_g_miss_num_map(ddx_old_header_rec.source_document_version_number);
    p7_a184 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_site_use_id);
    p7_a185 := rosetta_g_miss_num_map(ddx_old_header_rec.minisite_id);
    p7_a186 := ddx_old_header_rec.ib_owner;
    p7_a187 := ddx_old_header_rec.ib_installed_at_location;
    p7_a188 := ddx_old_header_rec.ib_current_location;
    p7_a189 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_id);
    p7_a190 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_contact_id);
    p7_a191 := rosetta_g_miss_num_map(ddx_old_header_rec.end_customer_site_use_id);
    p7_a192 := ddx_old_header_rec.supplier_signature;
    p7_a193 := ddx_old_header_rec.supplier_signature_date;
    p7_a194 := ddx_old_header_rec.customer_signature;
    p7_a195 := ddx_old_header_rec.customer_signature_date;
    p7_a196 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_party_id);
    p7_a197 := rosetta_g_miss_num_map(ddx_old_header_rec.sold_to_org_contact_id);
    p7_a198 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_id);
    p7_a199 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_site_id);
    p7_a200 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_party_site_use_id);
    p7_a201 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_id);
    p7_a202 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_site_id);
    p7_a203 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_party_site_use_id);
    p7_a204 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_id);
    p7_a205 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_site_id);
    p7_a206 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_party_site_use_id);
    p7_a207 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_customer_party_id);
    p7_a208 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_customer_party_id);
    p7_a209 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_customer_party_id);
    p7_a210 := rosetta_g_miss_num_map(ddx_old_header_rec.ship_to_org_contact_id);
    p7_a211 := rosetta_g_miss_num_map(ddx_old_header_rec.deliver_to_org_contact_id);
    p7_a212 := rosetta_g_miss_num_map(ddx_old_header_rec.invoice_to_org_contact_id);
    p7_a213 := rosetta_g_miss_num_map(ddx_old_header_rec.contract_template_id);
    p7_a214 := ddx_old_header_rec.contract_source_doc_type_code;
    p7_a215 := rosetta_g_miss_num_map(ddx_old_header_rec.contract_source_document_id);
  end;

  procedure process_object(p_init_msg_list  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_cascade_flag out NOCOPY /* file.sql.39 change */  number
  )

  as
    ddx_cascade_flag boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_header.process_object(p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_cascade_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  if ddx_cascade_flag is null
    then x_cascade_flag := null;
  elsif ddx_cascade_flag
    then x_cascade_flag := 1;
  else x_cascade_flag := 0;
  end if;
  end;

  procedure populate_transient_attributes(p1_a0 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a1 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a2 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a3 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a4 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a5 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a6 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a7 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a8 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a9 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a10 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a11 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a12 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a13 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a14 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a15 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a16 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a17 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a18 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a19 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a20 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a21 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a22 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a23 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a24 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a25 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a26 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a27 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a28 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a29 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a30 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a31 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a32 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a33 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a34 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a35 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a36 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a37 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a38 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a39 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a40 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a41 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a42 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a43 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a44 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a45 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a46 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a47 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a48 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a49 out NOCOPY /* file.sql.39 change */  VARCHAR
    , p1_a50 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a51 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a52 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a53 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a54 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a55 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a56 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a57 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a58 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a59 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a60 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a61 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a62 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a63 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a64 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a65 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a66 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a67 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a68 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a69 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a70 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a71 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a72 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a73 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a74 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a75 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a76 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a77 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a78 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a79 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a80 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a81 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a82 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a83 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a84 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a85 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a86 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a87 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a88 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a89 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a90 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a91 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a92 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a93 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a94 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a95 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a96 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a97 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a98 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a99 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a100 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a101 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a102 out NOCOPY /* file.sql.39 change */  NUMBER
    , p1_a103 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a104 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a105 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a106 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a107 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a108 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a109 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a110 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a111 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a112 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a113 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a114 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a115 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a116 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a117 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a118 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a119 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a120 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a121 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a122 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a123 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a124 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a125 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a126 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a127 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a128 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a129 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a130 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a131 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a132 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a133 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a134 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a135 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a136 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a137 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a138 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a139 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a140 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p1_a141 out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  VARCHAR2 := fnd_api.g_miss_char
    , p0_a5  VARCHAR2 := fnd_api.g_miss_char
    , p0_a6  VARCHAR2 := fnd_api.g_miss_char
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  NUMBER := 0-1962.0724
    , p0_a26  DATE := fnd_api.g_miss_date
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  DATE := fnd_api.g_miss_date
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  NUMBER := 0-1962.0724
    , p0_a36  DATE := fnd_api.g_miss_date
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  VARCHAR2 := fnd_api.g_miss_char
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  VARCHAR2 := fnd_api.g_miss_char
    , p0_a41  VARCHAR2 := fnd_api.g_miss_char
    , p0_a42  VARCHAR2 := fnd_api.g_miss_char
    , p0_a43  VARCHAR2 := fnd_api.g_miss_char
    , p0_a44  VARCHAR2 := fnd_api.g_miss_char
    , p0_a45  VARCHAR2 := fnd_api.g_miss_char
    , p0_a46  VARCHAR2 := fnd_api.g_miss_char
    , p0_a47  VARCHAR2 := fnd_api.g_miss_char
    , p0_a48  VARCHAR2 := fnd_api.g_miss_char
    , p0_a49  VARCHAR2 := fnd_api.g_miss_char
    , p0_a50  VARCHAR2 := fnd_api.g_miss_char
    , p0_a51  VARCHAR2 := fnd_api.g_miss_char
    , p0_a52  VARCHAR2 := fnd_api.g_miss_char
    , p0_a53  VARCHAR2 := fnd_api.g_miss_char
    , p0_a54  VARCHAR2 := fnd_api.g_miss_char
    , p0_a55  VARCHAR2 := fnd_api.g_miss_char
    , p0_a56  VARCHAR2 := fnd_api.g_miss_char
    , p0_a57  VARCHAR2 := fnd_api.g_miss_char
    , p0_a58  VARCHAR2 := fnd_api.g_miss_char
    , p0_a59  VARCHAR2 := fnd_api.g_miss_char
    , p0_a60  VARCHAR2 := fnd_api.g_miss_char
    , p0_a61  VARCHAR2 := fnd_api.g_miss_char
    , p0_a62  VARCHAR2 := fnd_api.g_miss_char
    , p0_a63  VARCHAR2 := fnd_api.g_miss_char
    , p0_a64  VARCHAR2 := fnd_api.g_miss_char
    , p0_a65  VARCHAR2 := fnd_api.g_miss_char
    , p0_a66  VARCHAR2 := fnd_api.g_miss_char
    , p0_a67  VARCHAR2 := fnd_api.g_miss_char
    , p0_a68  VARCHAR2 := fnd_api.g_miss_char
    , p0_a69  VARCHAR2 := fnd_api.g_miss_char
    , p0_a70  VARCHAR2 := fnd_api.g_miss_char
    , p0_a71  VARCHAR2 := fnd_api.g_miss_char
    , p0_a72  VARCHAR2 := fnd_api.g_miss_char
    , p0_a73  VARCHAR2 := fnd_api.g_miss_char
    , p0_a74  VARCHAR2 := fnd_api.g_miss_char
    , p0_a75  VARCHAR2 := fnd_api.g_miss_char
    , p0_a76  VARCHAR2 := fnd_api.g_miss_char
    , p0_a77  NUMBER := 0-1962.0724
    , p0_a78  NUMBER := 0-1962.0724
    , p0_a79  NUMBER := 0-1962.0724
    , p0_a80  NUMBER := 0-1962.0724
    , p0_a81  NUMBER := 0-1962.0724
    , p0_a82  DATE := fnd_api.g_miss_date
    , p0_a83  NUMBER := 0-1962.0724
    , p0_a84  NUMBER := 0-1962.0724
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  DATE := fnd_api.g_miss_date
    , p0_a88  VARCHAR2 := fnd_api.g_miss_char
    , p0_a89  NUMBER := 0-1962.0724
    , p0_a90  NUMBER := 0-1962.0724
    , p0_a91  NUMBER := 0-1962.0724
    , p0_a92  NUMBER := 0-1962.0724
    , p0_a93  VARCHAR2 := fnd_api.g_miss_char
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  NUMBER := 0-1962.0724
    , p0_a96  NUMBER := 0-1962.0724
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  DATE := fnd_api.g_miss_date
    , p0_a99  NUMBER := 0-1962.0724
    , p0_a100  NUMBER := 0-1962.0724
    , p0_a101  DATE := fnd_api.g_miss_date
    , p0_a102  DATE := fnd_api.g_miss_date
    , p0_a103  NUMBER := 0-1962.0724
    , p0_a104  VARCHAR2 := fnd_api.g_miss_char
    , p0_a105  NUMBER := 0-1962.0724
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  VARCHAR2 := fnd_api.g_miss_char
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p0_a109  NUMBER := 0-1962.0724
    , p0_a110  NUMBER := 0-1962.0724
    , p0_a111  NUMBER := 0-1962.0724
    , p0_a112  NUMBER := 0-1962.0724
    , p0_a113  NUMBER := 0-1962.0724
    , p0_a114  NUMBER := 0-1962.0724
    , p0_a115  NUMBER := 0-1962.0724
    , p0_a116  NUMBER := 0-1962.0724
    , p0_a117  NUMBER := 0-1962.0724
    , p0_a118  NUMBER := 0-1962.0724
    , p0_a119  NUMBER := 0-1962.0724
    , p0_a120  VARCHAR2 := fnd_api.g_miss_char
    , p0_a121  VARCHAR2 := fnd_api.g_miss_char
    , p0_a122  VARCHAR2 := fnd_api.g_miss_char
    , p0_a123  VARCHAR2 := fnd_api.g_miss_char
    , p0_a124  VARCHAR2 := fnd_api.g_miss_char
    , p0_a125  NUMBER := 0-1962.0724
    , p0_a126  VARCHAR2 := fnd_api.g_miss_char
    , p0_a127  VARCHAR2 := fnd_api.g_miss_char
    , p0_a128  VARCHAR2 := fnd_api.g_miss_char
    , p0_a129  VARCHAR2 := fnd_api.g_miss_char
    , p0_a130  DATE := fnd_api.g_miss_date
    , p0_a131  VARCHAR2 := fnd_api.g_miss_char
    , p0_a132  DATE := fnd_api.g_miss_date
    , p0_a133  VARCHAR2 := fnd_api.g_miss_char
    , p0_a134  VARCHAR2 := fnd_api.g_miss_char
    , p0_a135  VARCHAR2 := fnd_api.g_miss_char
    , p0_a136  VARCHAR2 := fnd_api.g_miss_char
    , p0_a137  VARCHAR2 := fnd_api.g_miss_char
    , p0_a138  VARCHAR2 := fnd_api.g_miss_char
    , p0_a139  VARCHAR2 := fnd_api.g_miss_char
    , p0_a140  VARCHAR2 := fnd_api.g_miss_char
    , p0_a141  NUMBER := 0-1962.0724
    , p0_a142  VARCHAR2 := fnd_api.g_miss_char
    , p0_a143  NUMBER := 0-1962.0724
    , p0_a144  VARCHAR2 := fnd_api.g_miss_char
    , p0_a145  VARCHAR2 := fnd_api.g_miss_char
    , p0_a146  VARCHAR2 := fnd_api.g_miss_char
    , p0_a147  VARCHAR2 := fnd_api.g_miss_char
    , p0_a148  DATE := fnd_api.g_miss_date
    , p0_a149  VARCHAR2 := fnd_api.g_miss_char
    , p0_a150  DATE := fnd_api.g_miss_date
    , p0_a151  VARCHAR2 := fnd_api.g_miss_char
    , p0_a152  VARCHAR2 := fnd_api.g_miss_char
    , p0_a153  VARCHAR2 := fnd_api.g_miss_char
    , p0_a154  DATE := fnd_api.g_miss_date
    , p0_a155  NUMBER := 0-1962.0724
    , p0_a156  VARCHAR2 := fnd_api.g_miss_char
    , p0_a157  NUMBER := 0-1962.0724
    , p0_a158  VARCHAR2 := fnd_api.g_miss_char
    , p0_a159  VARCHAR2 := fnd_api.g_miss_char
    , p0_a160  VARCHAR2 := fnd_api.g_miss_char
    , p0_a161  VARCHAR2 := fnd_api.g_miss_char
    , p0_a162  NUMBER := 0-1962.0724
    , p0_a163  NUMBER := 0-1962.0724
    , p0_a164  NUMBER := 0-1962.0724
    , p0_a165  NUMBER := 0-1962.0724
    , p0_a166  VARCHAR2 := fnd_api.g_miss_char
    , p0_a167  NUMBER := 0-1962.0724
    , p0_a168  NUMBER := 0-1962.0724
    , p0_a169  NUMBER := 0-1962.0724
    , p0_a170  NUMBER := 0-1962.0724
    , p0_a171  NUMBER := 0-1962.0724
    , p0_a172  VARCHAR2 := fnd_api.g_miss_char
    , p0_a173  NUMBER := 0-1962.0724
    , p0_a174  VARCHAR2 := fnd_api.g_miss_char
    , p0_a175  VARCHAR2 := fnd_api.g_miss_char
    , p0_a176  VARCHAR2 := fnd_api.g_miss_char
    , p0_a177  DATE := fnd_api.g_miss_date
    , p0_a178  NUMBER := 0-1962.0724
    , p0_a179  VARCHAR2 := fnd_api.g_miss_char
    , p0_a180  VARCHAR2 := fnd_api.g_miss_char
    , p0_a181  VARCHAR2 := fnd_api.g_miss_char
    , p0_a182  VARCHAR2 := fnd_api.g_miss_char
    , p0_a183  NUMBER := 0-1962.0724
    , p0_a184  NUMBER := 0-1962.0724
    , p0_a185  NUMBER := 0-1962.0724
    , p0_a186  VARCHAR2 := fnd_api.g_miss_char
    , p0_a187  VARCHAR2 := fnd_api.g_miss_char
    , p0_a188  VARCHAR2 := fnd_api.g_miss_char
    , p0_a189  NUMBER := 0-1962.0724
    , p0_a190  NUMBER := 0-1962.0724
    , p0_a191  NUMBER := 0-1962.0724
    , p0_a192  VARCHAR2 := fnd_api.g_miss_char
    , p0_a193  DATE := fnd_api.g_miss_date
    , p0_a194  VARCHAR2 := fnd_api.g_miss_char
    , p0_a195  DATE := fnd_api.g_miss_date
    , p0_a196  NUMBER := 0-1962.0724
    , p0_a197  NUMBER := 0-1962.0724
    , p0_a198  NUMBER := 0-1962.0724
    , p0_a199  NUMBER := 0-1962.0724
    , p0_a200  NUMBER := 0-1962.0724
    , p0_a201  NUMBER := 0-1962.0724
    , p0_a202  NUMBER := 0-1962.0724
    , p0_a203  NUMBER := 0-1962.0724
    , p0_a204  NUMBER := 0-1962.0724
    , p0_a205  NUMBER := 0-1962.0724
    , p0_a206  NUMBER := 0-1962.0724
    , p0_a207  NUMBER := 0-1962.0724
    , p0_a208  NUMBER := 0-1962.0724
    , p0_a209  NUMBER := 0-1962.0724
    , p0_a210  NUMBER := 0-1962.0724
    , p0_a211  NUMBER := 0-1962.0724
    , p0_a212  NUMBER := 0-1962.0724
    , p0_a213  NUMBER := 0-1962.0724
    , p0_a214  VARCHAR2 := fnd_api.g_miss_char
    , p0_a215  NUMBER := 0-1962.0724
  )

  as
    ddp_header_rec oe_order_pub.header_rec_type;
    ddx_header_val_rec oe_order_pub.header_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_header_rec.agreement_id := rosetta_g_miss_num_map(p0_a1);
    ddp_header_rec.attribute1 := p0_a2;
    ddp_header_rec.attribute10 := p0_a3;
    ddp_header_rec.attribute11 := p0_a4;
    ddp_header_rec.attribute12 := p0_a5;
    ddp_header_rec.attribute13 := p0_a6;
    ddp_header_rec.attribute14 := p0_a7;
    ddp_header_rec.attribute15 := p0_a8;
    ddp_header_rec.attribute16 := p0_a9;
    ddp_header_rec.attribute17 := p0_a10;
    ddp_header_rec.attribute18 := p0_a11;
    ddp_header_rec.attribute19 := p0_a12;
    ddp_header_rec.attribute2 := p0_a13;
    ddp_header_rec.attribute20 := p0_a14;
    ddp_header_rec.attribute3 := p0_a15;
    ddp_header_rec.attribute4 := p0_a16;
    ddp_header_rec.attribute5 := p0_a17;
    ddp_header_rec.attribute6 := p0_a18;
    ddp_header_rec.attribute7 := p0_a19;
    ddp_header_rec.attribute8 := p0_a20;
    ddp_header_rec.attribute9 := p0_a21;
    ddp_header_rec.booked_flag := p0_a22;
    ddp_header_rec.cancelled_flag := p0_a23;
    ddp_header_rec.context := p0_a24;
    ddp_header_rec.conversion_rate := rosetta_g_miss_num_map(p0_a25);
    ddp_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p0_a26);
    ddp_header_rec.conversion_type_code := p0_a27;
    ddp_header_rec.customer_preference_set_code := p0_a28;
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p0_a29);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p0_a30);
    ddp_header_rec.cust_po_number := p0_a31;
    ddp_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p0_a32);
    ddp_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p0_a33);
    ddp_header_rec.demand_class_code := p0_a34;
    ddp_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p0_a35);
    ddp_header_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a36);
    ddp_header_rec.fob_point_code := p0_a37;
    ddp_header_rec.freight_carrier_code := p0_a38;
    ddp_header_rec.freight_terms_code := p0_a39;
    ddp_header_rec.global_attribute1 := p0_a40;
    ddp_header_rec.global_attribute10 := p0_a41;
    ddp_header_rec.global_attribute11 := p0_a42;
    ddp_header_rec.global_attribute12 := p0_a43;
    ddp_header_rec.global_attribute13 := p0_a44;
    ddp_header_rec.global_attribute14 := p0_a45;
    ddp_header_rec.global_attribute15 := p0_a46;
    ddp_header_rec.global_attribute16 := p0_a47;
    ddp_header_rec.global_attribute17 := p0_a48;
    ddp_header_rec.global_attribute18 := p0_a49;
    ddp_header_rec.global_attribute19 := p0_a50;
    ddp_header_rec.global_attribute2 := p0_a51;
    ddp_header_rec.global_attribute20 := p0_a52;
    ddp_header_rec.global_attribute3 := p0_a53;
    ddp_header_rec.global_attribute4 := p0_a54;
    ddp_header_rec.global_attribute5 := p0_a55;
    ddp_header_rec.global_attribute6 := p0_a56;
    ddp_header_rec.global_attribute7 := p0_a57;
    ddp_header_rec.global_attribute8 := p0_a58;
    ddp_header_rec.global_attribute9 := p0_a59;
    ddp_header_rec.global_attribute_category := p0_a60;
    ddp_header_rec.tp_context := p0_a61;
    ddp_header_rec.tp_attribute1 := p0_a62;
    ddp_header_rec.tp_attribute2 := p0_a63;
    ddp_header_rec.tp_attribute3 := p0_a64;
    ddp_header_rec.tp_attribute4 := p0_a65;
    ddp_header_rec.tp_attribute5 := p0_a66;
    ddp_header_rec.tp_attribute6 := p0_a67;
    ddp_header_rec.tp_attribute7 := p0_a68;
    ddp_header_rec.tp_attribute8 := p0_a69;
    ddp_header_rec.tp_attribute9 := p0_a70;
    ddp_header_rec.tp_attribute10 := p0_a71;
    ddp_header_rec.tp_attribute11 := p0_a72;
    ddp_header_rec.tp_attribute12 := p0_a73;
    ddp_header_rec.tp_attribute13 := p0_a74;
    ddp_header_rec.tp_attribute14 := p0_a75;
    ddp_header_rec.tp_attribute15 := p0_a76;
    ddp_header_rec.header_id := rosetta_g_miss_num_map(p0_a77);
    ddp_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p0_a78);
    ddp_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p0_a79);
    ddp_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p0_a80);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p0_a81);
    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a82);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p0_a83);
    ddp_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p0_a84);
    ddp_header_rec.open_flag := p0_a85;
    ddp_header_rec.order_category_code := p0_a86;
    ddp_header_rec.ordered_date := rosetta_g_miss_date_in_map(p0_a87);
    ddp_header_rec.order_date_type_code := p0_a88;
    ddp_header_rec.order_number := rosetta_g_miss_num_map(p0_a89);
    ddp_header_rec.order_source_id := rosetta_g_miss_num_map(p0_a90);
    ddp_header_rec.order_type_id := rosetta_g_miss_num_map(p0_a91);
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p0_a92);
    ddp_header_rec.orig_sys_document_ref := p0_a93;
    ddp_header_rec.partial_shipments_allowed := p0_a94;
    ddp_header_rec.payment_term_id := rosetta_g_miss_num_map(p0_a95);
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p0_a96);
    ddp_header_rec.price_request_code := p0_a97;
    ddp_header_rec.pricing_date := rosetta_g_miss_date_in_map(p0_a98);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p0_a99);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p0_a100);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a101);
    ddp_header_rec.request_date := rosetta_g_miss_date_in_map(p0_a102);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p0_a103);
    ddp_header_rec.return_reason_code := p0_a104;
    ddp_header_rec.salesrep_id := rosetta_g_miss_num_map(p0_a105);
    ddp_header_rec.sales_channel_code := p0_a106;
    ddp_header_rec.shipment_priority_code := p0_a107;
    ddp_header_rec.shipping_method_code := p0_a108;
    ddp_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p0_a109);
    ddp_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p0_a110);
    ddp_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p0_a111);
    ddp_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p0_a112);
    ddp_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p0_a113);
    ddp_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p0_a114);
    ddp_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p0_a115);
    ddp_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p0_a116);
    ddp_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p0_a117);
    ddp_header_rec.source_document_id := rosetta_g_miss_num_map(p0_a118);
    ddp_header_rec.source_document_type_id := rosetta_g_miss_num_map(p0_a119);
    ddp_header_rec.tax_exempt_flag := p0_a120;
    ddp_header_rec.tax_exempt_number := p0_a121;
    ddp_header_rec.tax_exempt_reason_code := p0_a122;
    ddp_header_rec.tax_point_code := p0_a123;
    ddp_header_rec.transactional_curr_code := p0_a124;
    ddp_header_rec.version_number := rosetta_g_miss_num_map(p0_a125);
    ddp_header_rec.return_status := p0_a126;
    ddp_header_rec.db_flag := p0_a127;
    ddp_header_rec.operation := p0_a128;
    ddp_header_rec.first_ack_code := p0_a129;
    ddp_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p0_a130);
    ddp_header_rec.last_ack_code := p0_a131;
    ddp_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p0_a132);
    ddp_header_rec.change_reason := p0_a133;
    ddp_header_rec.change_comments := p0_a134;
    ddp_header_rec.change_sequence := p0_a135;
    ddp_header_rec.change_request_code := p0_a136;
    ddp_header_rec.ready_flag := p0_a137;
    ddp_header_rec.status_flag := p0_a138;
    ddp_header_rec.force_apply_flag := p0_a139;
    ddp_header_rec.drop_ship_flag := p0_a140;
    ddp_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p0_a141);
    ddp_header_rec.payment_type_code := p0_a142;
    ddp_header_rec.payment_amount := rosetta_g_miss_num_map(p0_a143);
    ddp_header_rec.check_number := p0_a144;
    ddp_header_rec.credit_card_code := p0_a145;
    ddp_header_rec.credit_card_holder_name := p0_a146;
    ddp_header_rec.credit_card_number := p0_a147;
    ddp_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p0_a148);
    ddp_header_rec.credit_card_approval_code := p0_a149;
    ddp_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p0_a150);
    ddp_header_rec.shipping_instructions := p0_a151;
    ddp_header_rec.packing_instructions := p0_a152;
    ddp_header_rec.flow_status_code := p0_a153;
    ddp_header_rec.booked_date := rosetta_g_miss_date_in_map(p0_a154);
    ddp_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p0_a155);
    ddp_header_rec.upgraded_flag := p0_a156;
    ddp_header_rec.lock_control := rosetta_g_miss_num_map(p0_a157);
    ddp_header_rec.ship_to_edi_location_code := p0_a158;
    ddp_header_rec.sold_to_edi_location_code := p0_a159;
    ddp_header_rec.bill_to_edi_location_code := p0_a160;
    ddp_header_rec.ship_from_edi_location_code := p0_a161;
    ddp_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p0_a162);
    ddp_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p0_a163);
    ddp_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p0_a164);
    ddp_header_rec.invoice_address_id := rosetta_g_miss_num_map(p0_a165);
    ddp_header_rec.ship_to_address_code := p0_a166;
    ddp_header_rec.xml_message_id := rosetta_g_miss_num_map(p0_a167);
    ddp_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p0_a168);
    ddp_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p0_a169);
    ddp_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p0_a170);
    ddp_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p0_a171);
    ddp_header_rec.xml_transaction_type_code := p0_a172;
    ddp_header_rec.blanket_number := rosetta_g_miss_num_map(p0_a173);
    ddp_header_rec.line_set_name := p0_a174;
    ddp_header_rec.fulfillment_set_name := p0_a175;
    ddp_header_rec.default_fulfillment_set := p0_a176;
    ddp_header_rec.quote_date := rosetta_g_miss_date_in_map(p0_a177);
    ddp_header_rec.quote_number := rosetta_g_miss_num_map(p0_a178);
    ddp_header_rec.sales_document_name := p0_a179;
    ddp_header_rec.transaction_phase_code := p0_a180;
    ddp_header_rec.user_status_code := p0_a181;
    ddp_header_rec.draft_submitted_flag := p0_a182;
    ddp_header_rec.source_document_version_number := rosetta_g_miss_num_map(p0_a183);
    ddp_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p0_a184);
    ddp_header_rec.minisite_id := rosetta_g_miss_num_map(p0_a185);
    ddp_header_rec.ib_owner := p0_a186;
    ddp_header_rec.ib_installed_at_location := p0_a187;
    ddp_header_rec.ib_current_location := p0_a188;
    ddp_header_rec.end_customer_id := rosetta_g_miss_num_map(p0_a189);
    ddp_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p0_a190);
    ddp_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p0_a191);
    ddp_header_rec.supplier_signature := p0_a192;
    ddp_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p0_a193);
    ddp_header_rec.customer_signature := p0_a194;
    ddp_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p0_a195);
    ddp_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p0_a196);
    ddp_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p0_a197);
    ddp_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p0_a198);
    ddp_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p0_a199);
    ddp_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p0_a200);
    ddp_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p0_a201);
    ddp_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p0_a202);
    ddp_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p0_a203);
    ddp_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p0_a204);
    ddp_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p0_a205);
    ddp_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p0_a206);
    ddp_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p0_a207);
    ddp_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p0_a208);
    ddp_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p0_a209);
    ddp_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p0_a210);
    ddp_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p0_a211);
    ddp_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p0_a212);
    ddp_header_rec.contract_template_id := rosetta_g_miss_num_map(p0_a213);
    ddp_header_rec.contract_source_doc_type_code := p0_a214;
    ddp_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p0_a215);





    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_header.populate_transient_attributes(ddp_header_rec,
      ddx_header_val_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_header_val_rec.accounting_rule;
    p1_a1 := ddx_header_val_rec.agreement;
    p1_a2 := ddx_header_val_rec.conversion_type;
    p1_a3 := ddx_header_val_rec.deliver_to_address1;
    p1_a4 := ddx_header_val_rec.deliver_to_address2;
    p1_a5 := ddx_header_val_rec.deliver_to_address3;
    p1_a6 := ddx_header_val_rec.deliver_to_address4;
    p1_a7 := ddx_header_val_rec.deliver_to_contact;
    p1_a8 := ddx_header_val_rec.deliver_to_location;
    p1_a9 := ddx_header_val_rec.deliver_to_org;
    p1_a10 := ddx_header_val_rec.deliver_to_state;
    p1_a11 := ddx_header_val_rec.deliver_to_city;
    p1_a12 := ddx_header_val_rec.deliver_to_zip;
    p1_a13 := ddx_header_val_rec.deliver_to_country;
    p1_a14 := ddx_header_val_rec.deliver_to_county;
    p1_a15 := ddx_header_val_rec.deliver_to_province;
    p1_a16 := ddx_header_val_rec.demand_class;
    p1_a17 := ddx_header_val_rec.fob_point;
    p1_a18 := ddx_header_val_rec.freight_terms;
    p1_a19 := ddx_header_val_rec.invoice_to_address1;
    p1_a20 := ddx_header_val_rec.invoice_to_address2;
    p1_a21 := ddx_header_val_rec.invoice_to_address3;
    p1_a22 := ddx_header_val_rec.invoice_to_address4;
    p1_a23 := ddx_header_val_rec.invoice_to_state;
    p1_a24 := ddx_header_val_rec.invoice_to_city;
    p1_a25 := ddx_header_val_rec.invoice_to_zip;
    p1_a26 := ddx_header_val_rec.invoice_to_country;
    p1_a27 := ddx_header_val_rec.invoice_to_county;
    p1_a28 := ddx_header_val_rec.invoice_to_province;
    p1_a29 := ddx_header_val_rec.invoice_to_contact;
    p1_a30 := ddx_header_val_rec.invoice_to_contact_first_name;
    p1_a31 := ddx_header_val_rec.invoice_to_contact_last_name;
    p1_a32 := ddx_header_val_rec.invoice_to_location;
    p1_a33 := ddx_header_val_rec.invoice_to_org;
    p1_a34 := ddx_header_val_rec.invoicing_rule;
    p1_a35 := ddx_header_val_rec.order_source;
    p1_a36 := ddx_header_val_rec.order_type;
    p1_a37 := ddx_header_val_rec.payment_term;
    p1_a38 := ddx_header_val_rec.price_list;
    p1_a39 := ddx_header_val_rec.return_reason;
    p1_a40 := ddx_header_val_rec.salesrep;
    p1_a41 := ddx_header_val_rec.shipment_priority;
    p1_a42 := ddx_header_val_rec.ship_from_address1;
    p1_a43 := ddx_header_val_rec.ship_from_address2;
    p1_a44 := ddx_header_val_rec.ship_from_address3;
    p1_a45 := ddx_header_val_rec.ship_from_address4;
    p1_a46 := ddx_header_val_rec.ship_from_location;
    p1_a47 := ddx_header_val_rec.ship_from_city;
    p1_a48 := ddx_header_val_rec.ship_from_postal_code;
    p1_a49 := ddx_header_val_rec.ship_from_country;
    p1_a50 := ddx_header_val_rec.ship_from_region1;
    p1_a51 := ddx_header_val_rec.ship_from_region2;
    p1_a52 := ddx_header_val_rec.ship_from_region3;
    p1_a53 := ddx_header_val_rec.ship_from_org;
    p1_a54 := ddx_header_val_rec.sold_to_address1;
    p1_a55 := ddx_header_val_rec.sold_to_address2;
    p1_a56 := ddx_header_val_rec.sold_to_address3;
    p1_a57 := ddx_header_val_rec.sold_to_address4;
    p1_a58 := ddx_header_val_rec.sold_to_state;
    p1_a59 := ddx_header_val_rec.sold_to_country;
    p1_a60 := ddx_header_val_rec.sold_to_zip;
    p1_a61 := ddx_header_val_rec.sold_to_county;
    p1_a62 := ddx_header_val_rec.sold_to_province;
    p1_a63 := ddx_header_val_rec.sold_to_city;
    p1_a64 := ddx_header_val_rec.sold_to_contact_last_name;
    p1_a65 := ddx_header_val_rec.sold_to_contact_first_name;
    p1_a66 := ddx_header_val_rec.ship_to_address1;
    p1_a67 := ddx_header_val_rec.ship_to_address2;
    p1_a68 := ddx_header_val_rec.ship_to_address3;
    p1_a69 := ddx_header_val_rec.ship_to_address4;
    p1_a70 := ddx_header_val_rec.ship_to_state;
    p1_a71 := ddx_header_val_rec.ship_to_country;
    p1_a72 := ddx_header_val_rec.ship_to_zip;
    p1_a73 := ddx_header_val_rec.ship_to_county;
    p1_a74 := ddx_header_val_rec.ship_to_province;
    p1_a75 := ddx_header_val_rec.ship_to_city;
    p1_a76 := ddx_header_val_rec.ship_to_contact;
    p1_a77 := ddx_header_val_rec.ship_to_contact_last_name;
    p1_a78 := ddx_header_val_rec.ship_to_contact_first_name;
    p1_a79 := ddx_header_val_rec.ship_to_location;
    p1_a80 := ddx_header_val_rec.ship_to_org;
    p1_a81 := ddx_header_val_rec.sold_to_contact;
    p1_a82 := ddx_header_val_rec.sold_to_org;
    p1_a83 := ddx_header_val_rec.sold_from_org;
    p1_a84 := ddx_header_val_rec.tax_exempt;
    p1_a85 := ddx_header_val_rec.tax_exempt_reason;
    p1_a86 := ddx_header_val_rec.tax_point;
    p1_a87 := ddx_header_val_rec.customer_payment_term;
    p1_a88 := ddx_header_val_rec.payment_type;
    p1_a89 := ddx_header_val_rec.credit_card;
    p1_a90 := ddx_header_val_rec.status;
    p1_a91 := ddx_header_val_rec.freight_carrier;
    p1_a92 := ddx_header_val_rec.shipping_method;
    p1_a93 := ddx_header_val_rec.order_date_type;
    p1_a94 := ddx_header_val_rec.customer_number;
    p1_a95 := ddx_header_val_rec.ship_to_customer_name;
    p1_a96 := ddx_header_val_rec.invoice_to_customer_name;
    p1_a97 := ddx_header_val_rec.sales_channel;
    p1_a98 := ddx_header_val_rec.ship_to_customer_number;
    p1_a99 := ddx_header_val_rec.invoice_to_customer_number;
    p1_a100 := rosetta_g_miss_num_map(ddx_header_val_rec.ship_to_customer_id);
    p1_a101 := rosetta_g_miss_num_map(ddx_header_val_rec.invoice_to_customer_id);
    p1_a102 := rosetta_g_miss_num_map(ddx_header_val_rec.deliver_to_customer_id);
    p1_a103 := ddx_header_val_rec.deliver_to_customer_number;
    p1_a104 := ddx_header_val_rec.deliver_to_customer_name;
    p1_a105 := ddx_header_val_rec.deliver_to_customer_number_oi;
    p1_a106 := ddx_header_val_rec.deliver_to_customer_name_oi;
    p1_a107 := ddx_header_val_rec.ship_to_customer_number_oi;
    p1_a108 := ddx_header_val_rec.ship_to_customer_name_oi;
    p1_a109 := ddx_header_val_rec.invoice_to_customer_number_oi;
    p1_a110 := ddx_header_val_rec.invoice_to_customer_name_oi;
    p1_a111 := ddx_header_val_rec.user_status;
    p1_a112 := ddx_header_val_rec.transaction_phase;
    p1_a113 := ddx_header_val_rec.sold_to_location_address1;
    p1_a114 := ddx_header_val_rec.sold_to_location_address2;
    p1_a115 := ddx_header_val_rec.sold_to_location_address3;
    p1_a116 := ddx_header_val_rec.sold_to_location_address4;
    p1_a117 := ddx_header_val_rec.sold_to_location;
    p1_a118 := ddx_header_val_rec.sold_to_location_city;
    p1_a119 := ddx_header_val_rec.sold_to_location_state;
    p1_a120 := ddx_header_val_rec.sold_to_location_postal;
    p1_a121 := ddx_header_val_rec.sold_to_location_country;
    p1_a122 := ddx_header_val_rec.sold_to_location_county;
    p1_a123 := ddx_header_val_rec.sold_to_location_province;
    p1_a124 := ddx_header_val_rec.end_customer_name;
    p1_a125 := ddx_header_val_rec.end_customer_number;
    p1_a126 := ddx_header_val_rec.end_customer_contact;
    p1_a127 := ddx_header_val_rec.end_cust_contact_last_name;
    p1_a128 := ddx_header_val_rec.end_cust_contact_first_name;
    p1_a129 := ddx_header_val_rec.end_customer_site_address1;
    p1_a130 := ddx_header_val_rec.end_customer_site_address2;
    p1_a131 := ddx_header_val_rec.end_customer_site_address3;
    p1_a132 := ddx_header_val_rec.end_customer_site_address4;
    p1_a133 := ddx_header_val_rec.end_customer_site_state;
    p1_a134 := ddx_header_val_rec.end_customer_site_country;
    p1_a135 := ddx_header_val_rec.end_customer_site_location;
    p1_a136 := ddx_header_val_rec.end_customer_site_zip;
    p1_a137 := ddx_header_val_rec.end_customer_site_county;
    p1_a138 := ddx_header_val_rec.end_customer_site_province;
    p1_a139 := ddx_header_val_rec.end_customer_site_city;
    p1_a140 := ddx_header_val_rec.end_customer_site_postal_code;
    p1_a141 := ddx_header_val_rec.blanket_agreement_name;



  end;

end oe_oe_html_header_w;

/
