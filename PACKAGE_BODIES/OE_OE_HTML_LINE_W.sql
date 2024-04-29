--------------------------------------------------------
--  DDL for Package Body OE_OE_HTML_LINE_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OE_HTML_LINE_W" as
  /* $Header: ONTRLINB.pls 120.0 2005/06/01 02:38:04 appldev noship $ */
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

  procedure rosetta_table_copy_in_p0(t out NOCOPY /* file.sql.39 change */ oe_oe_html_line.number_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p0(t oe_oe_html_line.number_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE) as
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

  procedure rosetta_table_copy_in_p1(t out NOCOPY /* file.sql.39 change */ oe_oe_html_line.varchar2_tbl_type, a0 JTF_VARCHAR2_TABLE_2000) as
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
  procedure rosetta_table_copy_out_p1(t oe_oe_html_line.varchar2_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000) as
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
    , p_header_id  NUMBER
    , p4_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a2 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a3 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a4 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a5 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p4_a27 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a30 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a31 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a34 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a36 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a37 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a38 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a39 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a41 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a42 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a43 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a47 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a51 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a52 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a53 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a57 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a59 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a63 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a64 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p4_a86 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p4_a100 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a101 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a102 in out NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p4_a134 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a135 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a136 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a138 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a139 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a140 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a143 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a144 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a145 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a146 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a147 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a148 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a149 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a150 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a151 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a153 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a154 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a156 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a160 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a161 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a163 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a164 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a167 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a168 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a169 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a177 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a178 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a183 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a184 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a185 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a186 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a187 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a191 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a192 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a195 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a198 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a199 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a202 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a203 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a204 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a205 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a206 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a207 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a208 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a209 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a210 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a211 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a212 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a213 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a215 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a216 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a217 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a218 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a219 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a220 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a221 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a222 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a223 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a224 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a225 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a226 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a227 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a228 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a229 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a230 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a231 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a232 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a233 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a234 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a235 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a236 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a237 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a238 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a239 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a240 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a241 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a242 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a243 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a244 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a245 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a246 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a247 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a248 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a249 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a250 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a251 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a252 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a253 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a254 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a255 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a256 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a257 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a258 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a259 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a260 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a261 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a262 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a263 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a264 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a265 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a266 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a267 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a268 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a269 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a270 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a271 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a272 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a273 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a274 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a275 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a276 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a277 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a278 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a279 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a280 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a281 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a282 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a283 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a284 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a285 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a286 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a287 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a288 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a289 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a290 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a291 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a292 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a293 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a294 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a295 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a296 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a297 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a298 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a299 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a300 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a301 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a302 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a303 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a304 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a305 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a306 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a307 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a308 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a309 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a310 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a311 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a312 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a313 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a314 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a315 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a316 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a317 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a318 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a319 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a320 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a321 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a322 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a323 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a324 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a325 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a326 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a327 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a328 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a329 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a330 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a331 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a332 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a333 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a334 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a335 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a336 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a337 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a338 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a339 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a340 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a341 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a342 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a343 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a344 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a345 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a346 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a347 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a348 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a349 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a350 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a351 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a352 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a353 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a354 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a355 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a356 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a357 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a358 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a359 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a360 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a361 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a362 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a363 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a364 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a365 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a366 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a367 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a368 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a369 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a370 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a371 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a372 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a373 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a374 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a375 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a376 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a377 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a378 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a379 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a380 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a381 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a382 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a383 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a384 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a385 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a386 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a387 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a388 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a389 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a390 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a391 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a392 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a393 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a394 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a395 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a3 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p5_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p5_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p5_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p5_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR
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
    , p5_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a97 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a98 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a100 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a102 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a143 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p6_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a36 in out NOCOPY /* file.sql.39 change */  DATE
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
    , p6_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
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
    , p6_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a177 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a178 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a183 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a184 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a185 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a186 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a187 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a191 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a192 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a195 in out NOCOPY /* file.sql.39 change */  DATE
    , p6_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a198 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a199 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a202 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a203 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a204 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a205 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a206 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a207 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a208 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a209 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a210 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a211 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a212 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a213 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p6_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a215 in out NOCOPY /* file.sql.39 change */  NUMBER
  )

  as
    ddx_line_rec oe_order_pub.line_rec_type;
    ddx_line_val_rec oe_order_pub.line_val_rec_type;
    ddp_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddx_line_rec.accounting_rule_id := rosetta_g_miss_num_map(p4_a0);
    ddx_line_rec.actual_arrival_date := rosetta_g_miss_date_in_map(p4_a1);
    ddx_line_rec.actual_shipment_date := rosetta_g_miss_date_in_map(p4_a2);
    ddx_line_rec.agreement_id := rosetta_g_miss_num_map(p4_a3);
    ddx_line_rec.arrival_set_id := rosetta_g_miss_num_map(p4_a4);
    ddx_line_rec.ato_line_id := rosetta_g_miss_num_map(p4_a5);
    ddx_line_rec.attribute1 := p4_a6;
    ddx_line_rec.attribute10 := p4_a7;
    ddx_line_rec.attribute11 := p4_a8;
    ddx_line_rec.attribute12 := p4_a9;
    ddx_line_rec.attribute13 := p4_a10;
    ddx_line_rec.attribute14 := p4_a11;
    ddx_line_rec.attribute15 := p4_a12;
    ddx_line_rec.attribute16 := p4_a13;
    ddx_line_rec.attribute17 := p4_a14;
    ddx_line_rec.attribute18 := p4_a15;
    ddx_line_rec.attribute19 := p4_a16;
    ddx_line_rec.attribute2 := p4_a17;
    ddx_line_rec.attribute20 := p4_a18;
    ddx_line_rec.attribute3 := p4_a19;
    ddx_line_rec.attribute4 := p4_a20;
    ddx_line_rec.attribute5 := p4_a21;
    ddx_line_rec.attribute6 := p4_a22;
    ddx_line_rec.attribute7 := p4_a23;
    ddx_line_rec.attribute8 := p4_a24;
    ddx_line_rec.attribute9 := p4_a25;
    ddx_line_rec.authorized_to_ship_flag := p4_a26;
    ddx_line_rec.auto_selected_quantity := rosetta_g_miss_num_map(p4_a27);
    ddx_line_rec.booked_flag := p4_a28;
    ddx_line_rec.cancelled_flag := p4_a29;
    ddx_line_rec.cancelled_quantity := rosetta_g_miss_num_map(p4_a30);
    ddx_line_rec.cancelled_quantity2 := rosetta_g_miss_num_map(p4_a31);
    ddx_line_rec.commitment_id := rosetta_g_miss_num_map(p4_a32);
    ddx_line_rec.component_code := p4_a33;
    ddx_line_rec.component_number := rosetta_g_miss_num_map(p4_a34);
    ddx_line_rec.component_sequence_id := rosetta_g_miss_num_map(p4_a35);
    ddx_line_rec.config_header_id := rosetta_g_miss_num_map(p4_a36);
    ddx_line_rec.config_rev_nbr := rosetta_g_miss_num_map(p4_a37);
    ddx_line_rec.config_display_sequence := rosetta_g_miss_num_map(p4_a38);
    ddx_line_rec.configuration_id := rosetta_g_miss_num_map(p4_a39);
    ddx_line_rec.context := p4_a40;
    ddx_line_rec.created_by := rosetta_g_miss_num_map(p4_a41);
    ddx_line_rec.creation_date := rosetta_g_miss_date_in_map(p4_a42);
    ddx_line_rec.credit_invoice_line_id := rosetta_g_miss_num_map(p4_a43);
    ddx_line_rec.customer_dock_code := p4_a44;
    ddx_line_rec.customer_job := p4_a45;
    ddx_line_rec.customer_production_line := p4_a46;
    ddx_line_rec.customer_trx_line_id := rosetta_g_miss_num_map(p4_a47);
    ddx_line_rec.cust_model_serial_number := p4_a48;
    ddx_line_rec.cust_po_number := p4_a49;
    ddx_line_rec.cust_production_seq_num := p4_a50;
    ddx_line_rec.delivery_lead_time := rosetta_g_miss_num_map(p4_a51);
    ddx_line_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p4_a52);
    ddx_line_rec.deliver_to_org_id := rosetta_g_miss_num_map(p4_a53);
    ddx_line_rec.demand_bucket_type_code := p4_a54;
    ddx_line_rec.demand_class_code := p4_a55;
    ddx_line_rec.dep_plan_required_flag := p4_a56;
    ddx_line_rec.earliest_acceptable_date := rosetta_g_miss_date_in_map(p4_a57);
    ddx_line_rec.end_item_unit_number := p4_a58;
    ddx_line_rec.explosion_date := rosetta_g_miss_date_in_map(p4_a59);
    ddx_line_rec.fob_point_code := p4_a60;
    ddx_line_rec.freight_carrier_code := p4_a61;
    ddx_line_rec.freight_terms_code := p4_a62;
    ddx_line_rec.fulfilled_quantity := rosetta_g_miss_num_map(p4_a63);
    ddx_line_rec.fulfilled_quantity2 := rosetta_g_miss_num_map(p4_a64);
    ddx_line_rec.global_attribute1 := p4_a65;
    ddx_line_rec.global_attribute10 := p4_a66;
    ddx_line_rec.global_attribute11 := p4_a67;
    ddx_line_rec.global_attribute12 := p4_a68;
    ddx_line_rec.global_attribute13 := p4_a69;
    ddx_line_rec.global_attribute14 := p4_a70;
    ddx_line_rec.global_attribute15 := p4_a71;
    ddx_line_rec.global_attribute16 := p4_a72;
    ddx_line_rec.global_attribute17 := p4_a73;
    ddx_line_rec.global_attribute18 := p4_a74;
    ddx_line_rec.global_attribute19 := p4_a75;
    ddx_line_rec.global_attribute2 := p4_a76;
    ddx_line_rec.global_attribute20 := p4_a77;
    ddx_line_rec.global_attribute3 := p4_a78;
    ddx_line_rec.global_attribute4 := p4_a79;
    ddx_line_rec.global_attribute5 := p4_a80;
    ddx_line_rec.global_attribute6 := p4_a81;
    ddx_line_rec.global_attribute7 := p4_a82;
    ddx_line_rec.global_attribute8 := p4_a83;
    ddx_line_rec.global_attribute9 := p4_a84;
    ddx_line_rec.global_attribute_category := p4_a85;
    ddx_line_rec.header_id := rosetta_g_miss_num_map(p4_a86);
    ddx_line_rec.industry_attribute1 := p4_a87;
    ddx_line_rec.industry_attribute10 := p4_a88;
    ddx_line_rec.industry_attribute11 := p4_a89;
    ddx_line_rec.industry_attribute12 := p4_a90;
    ddx_line_rec.industry_attribute13 := p4_a91;
    ddx_line_rec.industry_attribute14 := p4_a92;
    ddx_line_rec.industry_attribute15 := p4_a93;
    ddx_line_rec.industry_attribute16 := p4_a94;
    ddx_line_rec.industry_attribute17 := p4_a95;
    ddx_line_rec.industry_attribute18 := p4_a96;
    ddx_line_rec.industry_attribute19 := p4_a97;
    ddx_line_rec.industry_attribute20 := p4_a98;
    ddx_line_rec.industry_attribute21 := p4_a99;
    ddx_line_rec.industry_attribute22 := p4_a100;
    ddx_line_rec.industry_attribute23 := p4_a101;
    ddx_line_rec.industry_attribute24 := p4_a102;
    ddx_line_rec.industry_attribute25 := p4_a103;
    ddx_line_rec.industry_attribute26 := p4_a104;
    ddx_line_rec.industry_attribute27 := p4_a105;
    ddx_line_rec.industry_attribute28 := p4_a106;
    ddx_line_rec.industry_attribute29 := p4_a107;
    ddx_line_rec.industry_attribute30 := p4_a108;
    ddx_line_rec.industry_attribute2 := p4_a109;
    ddx_line_rec.industry_attribute3 := p4_a110;
    ddx_line_rec.industry_attribute4 := p4_a111;
    ddx_line_rec.industry_attribute5 := p4_a112;
    ddx_line_rec.industry_attribute6 := p4_a113;
    ddx_line_rec.industry_attribute7 := p4_a114;
    ddx_line_rec.industry_attribute8 := p4_a115;
    ddx_line_rec.industry_attribute9 := p4_a116;
    ddx_line_rec.industry_context := p4_a117;
    ddx_line_rec.tp_context := p4_a118;
    ddx_line_rec.tp_attribute1 := p4_a119;
    ddx_line_rec.tp_attribute2 := p4_a120;
    ddx_line_rec.tp_attribute3 := p4_a121;
    ddx_line_rec.tp_attribute4 := p4_a122;
    ddx_line_rec.tp_attribute5 := p4_a123;
    ddx_line_rec.tp_attribute6 := p4_a124;
    ddx_line_rec.tp_attribute7 := p4_a125;
    ddx_line_rec.tp_attribute8 := p4_a126;
    ddx_line_rec.tp_attribute9 := p4_a127;
    ddx_line_rec.tp_attribute10 := p4_a128;
    ddx_line_rec.tp_attribute11 := p4_a129;
    ddx_line_rec.tp_attribute12 := p4_a130;
    ddx_line_rec.tp_attribute13 := p4_a131;
    ddx_line_rec.tp_attribute14 := p4_a132;
    ddx_line_rec.tp_attribute15 := p4_a133;
    ddx_line_rec.intermed_ship_to_org_id := rosetta_g_miss_num_map(p4_a134);
    ddx_line_rec.intermed_ship_to_contact_id := rosetta_g_miss_num_map(p4_a135);
    ddx_line_rec.inventory_item_id := rosetta_g_miss_num_map(p4_a136);
    ddx_line_rec.invoice_interface_status_code := p4_a137;
    ddx_line_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p4_a138);
    ddx_line_rec.invoice_to_org_id := rosetta_g_miss_num_map(p4_a139);
    ddx_line_rec.invoicing_rule_id := rosetta_g_miss_num_map(p4_a140);
    ddx_line_rec.ordered_item := p4_a141;
    ddx_line_rec.item_revision := p4_a142;
    ddx_line_rec.item_type_code := p4_a143;
    ddx_line_rec.last_updated_by := rosetta_g_miss_num_map(p4_a144);
    ddx_line_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a145);
    ddx_line_rec.last_update_login := rosetta_g_miss_num_map(p4_a146);
    ddx_line_rec.latest_acceptable_date := rosetta_g_miss_date_in_map(p4_a147);
    ddx_line_rec.line_category_code := p4_a148;
    ddx_line_rec.line_id := rosetta_g_miss_num_map(p4_a149);
    ddx_line_rec.line_number := rosetta_g_miss_num_map(p4_a150);
    ddx_line_rec.line_type_id := rosetta_g_miss_num_map(p4_a151);
    ddx_line_rec.link_to_line_ref := p4_a152;
    ddx_line_rec.link_to_line_id := rosetta_g_miss_num_map(p4_a153);
    ddx_line_rec.link_to_line_index := rosetta_g_miss_num_map(p4_a154);
    ddx_line_rec.model_group_number := rosetta_g_miss_num_map(p4_a155);
    ddx_line_rec.mfg_component_sequence_id := rosetta_g_miss_num_map(p4_a156);
    ddx_line_rec.mfg_lead_time := rosetta_g_miss_num_map(p4_a157);
    ddx_line_rec.open_flag := p4_a158;
    ddx_line_rec.option_flag := p4_a159;
    ddx_line_rec.option_number := rosetta_g_miss_num_map(p4_a160);
    ddx_line_rec.ordered_quantity := rosetta_g_miss_num_map(p4_a161);
    ddx_line_rec.ordered_quantity2 := rosetta_g_miss_num_map(p4_a162);
    ddx_line_rec.order_quantity_uom := p4_a163;
    ddx_line_rec.ordered_quantity_uom2 := p4_a164;
    ddx_line_rec.org_id := rosetta_g_miss_num_map(p4_a165);
    ddx_line_rec.orig_sys_document_ref := p4_a166;
    ddx_line_rec.orig_sys_line_ref := p4_a167;
    ddx_line_rec.over_ship_reason_code := p4_a168;
    ddx_line_rec.over_ship_resolved_flag := p4_a169;
    ddx_line_rec.payment_term_id := rosetta_g_miss_num_map(p4_a170);
    ddx_line_rec.planning_priority := rosetta_g_miss_num_map(p4_a171);
    ddx_line_rec.preferred_grade := p4_a172;
    ddx_line_rec.price_list_id := rosetta_g_miss_num_map(p4_a173);
    ddx_line_rec.price_request_code := p4_a174;
    ddx_line_rec.pricing_attribute1 := p4_a175;
    ddx_line_rec.pricing_attribute10 := p4_a176;
    ddx_line_rec.pricing_attribute2 := p4_a177;
    ddx_line_rec.pricing_attribute3 := p4_a178;
    ddx_line_rec.pricing_attribute4 := p4_a179;
    ddx_line_rec.pricing_attribute5 := p4_a180;
    ddx_line_rec.pricing_attribute6 := p4_a181;
    ddx_line_rec.pricing_attribute7 := p4_a182;
    ddx_line_rec.pricing_attribute8 := p4_a183;
    ddx_line_rec.pricing_attribute9 := p4_a184;
    ddx_line_rec.pricing_context := p4_a185;
    ddx_line_rec.pricing_date := rosetta_g_miss_date_in_map(p4_a186);
    ddx_line_rec.pricing_quantity := rosetta_g_miss_num_map(p4_a187);
    ddx_line_rec.pricing_quantity_uom := p4_a188;
    ddx_line_rec.program_application_id := rosetta_g_miss_num_map(p4_a189);
    ddx_line_rec.program_id := rosetta_g_miss_num_map(p4_a190);
    ddx_line_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a191);
    ddx_line_rec.project_id := rosetta_g_miss_num_map(p4_a192);
    ddx_line_rec.promise_date := rosetta_g_miss_date_in_map(p4_a193);
    ddx_line_rec.re_source_flag := p4_a194;
    ddx_line_rec.reference_customer_trx_line_id := rosetta_g_miss_num_map(p4_a195);
    ddx_line_rec.reference_header_id := rosetta_g_miss_num_map(p4_a196);
    ddx_line_rec.reference_line_id := rosetta_g_miss_num_map(p4_a197);
    ddx_line_rec.reference_type := p4_a198;
    ddx_line_rec.request_date := rosetta_g_miss_date_in_map(p4_a199);
    ddx_line_rec.request_id := rosetta_g_miss_num_map(p4_a200);
    ddx_line_rec.reserved_quantity := rosetta_g_miss_num_map(p4_a201);
    ddx_line_rec.return_attribute1 := p4_a202;
    ddx_line_rec.return_attribute10 := p4_a203;
    ddx_line_rec.return_attribute11 := p4_a204;
    ddx_line_rec.return_attribute12 := p4_a205;
    ddx_line_rec.return_attribute13 := p4_a206;
    ddx_line_rec.return_attribute14 := p4_a207;
    ddx_line_rec.return_attribute15 := p4_a208;
    ddx_line_rec.return_attribute2 := p4_a209;
    ddx_line_rec.return_attribute3 := p4_a210;
    ddx_line_rec.return_attribute4 := p4_a211;
    ddx_line_rec.return_attribute5 := p4_a212;
    ddx_line_rec.return_attribute6 := p4_a213;
    ddx_line_rec.return_attribute7 := p4_a214;
    ddx_line_rec.return_attribute8 := p4_a215;
    ddx_line_rec.return_attribute9 := p4_a216;
    ddx_line_rec.return_context := p4_a217;
    ddx_line_rec.return_reason_code := p4_a218;
    ddx_line_rec.rla_schedule_type_code := p4_a219;
    ddx_line_rec.salesrep_id := rosetta_g_miss_num_map(p4_a220);
    ddx_line_rec.schedule_arrival_date := rosetta_g_miss_date_in_map(p4_a221);
    ddx_line_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p4_a222);
    ddx_line_rec.schedule_action_code := p4_a223;
    ddx_line_rec.schedule_status_code := p4_a224;
    ddx_line_rec.shipment_number := rosetta_g_miss_num_map(p4_a225);
    ddx_line_rec.shipment_priority_code := p4_a226;
    ddx_line_rec.shipped_quantity := rosetta_g_miss_num_map(p4_a227);
    ddx_line_rec.shipped_quantity2 := rosetta_g_miss_num_map(p4_a228);
    ddx_line_rec.shipping_interfaced_flag := p4_a229;
    ddx_line_rec.shipping_method_code := p4_a230;
    ddx_line_rec.shipping_quantity := rosetta_g_miss_num_map(p4_a231);
    ddx_line_rec.shipping_quantity2 := rosetta_g_miss_num_map(p4_a232);
    ddx_line_rec.shipping_quantity_uom := p4_a233;
    ddx_line_rec.shipping_quantity_uom2 := p4_a234;
    ddx_line_rec.ship_from_org_id := rosetta_g_miss_num_map(p4_a235);
    ddx_line_rec.ship_model_complete_flag := p4_a236;
    ddx_line_rec.ship_set_id := rosetta_g_miss_num_map(p4_a237);
    ddx_line_rec.fulfillment_set_id := rosetta_g_miss_num_map(p4_a238);
    ddx_line_rec.ship_tolerance_above := rosetta_g_miss_num_map(p4_a239);
    ddx_line_rec.ship_tolerance_below := rosetta_g_miss_num_map(p4_a240);
    ddx_line_rec.ship_to_contact_id := rosetta_g_miss_num_map(p4_a241);
    ddx_line_rec.ship_to_org_id := rosetta_g_miss_num_map(p4_a242);
    ddx_line_rec.sold_to_org_id := rosetta_g_miss_num_map(p4_a243);
    ddx_line_rec.sold_from_org_id := rosetta_g_miss_num_map(p4_a244);
    ddx_line_rec.sort_order := p4_a245;
    ddx_line_rec.source_document_id := rosetta_g_miss_num_map(p4_a246);
    ddx_line_rec.source_document_line_id := rosetta_g_miss_num_map(p4_a247);
    ddx_line_rec.source_document_type_id := rosetta_g_miss_num_map(p4_a248);
    ddx_line_rec.source_type_code := p4_a249;
    ddx_line_rec.split_from_line_id := rosetta_g_miss_num_map(p4_a250);
    ddx_line_rec.task_id := rosetta_g_miss_num_map(p4_a251);
    ddx_line_rec.tax_code := p4_a252;
    ddx_line_rec.tax_date := rosetta_g_miss_date_in_map(p4_a253);
    ddx_line_rec.tax_exempt_flag := p4_a254;
    ddx_line_rec.tax_exempt_number := p4_a255;
    ddx_line_rec.tax_exempt_reason_code := p4_a256;
    ddx_line_rec.tax_point_code := p4_a257;
    ddx_line_rec.tax_rate := rosetta_g_miss_num_map(p4_a258);
    ddx_line_rec.tax_value := rosetta_g_miss_num_map(p4_a259);
    ddx_line_rec.top_model_line_ref := p4_a260;
    ddx_line_rec.top_model_line_id := rosetta_g_miss_num_map(p4_a261);
    ddx_line_rec.top_model_line_index := rosetta_g_miss_num_map(p4_a262);
    ddx_line_rec.unit_list_price := rosetta_g_miss_num_map(p4_a263);
    ddx_line_rec.unit_list_price_per_pqty := rosetta_g_miss_num_map(p4_a264);
    ddx_line_rec.unit_selling_price := rosetta_g_miss_num_map(p4_a265);
    ddx_line_rec.unit_selling_price_per_pqty := rosetta_g_miss_num_map(p4_a266);
    ddx_line_rec.veh_cus_item_cum_key_id := rosetta_g_miss_num_map(p4_a267);
    ddx_line_rec.visible_demand_flag := p4_a268;
    ddx_line_rec.return_status := p4_a269;
    ddx_line_rec.db_flag := p4_a270;
    ddx_line_rec.operation := p4_a271;
    ddx_line_rec.first_ack_code := p4_a272;
    ddx_line_rec.first_ack_date := rosetta_g_miss_date_in_map(p4_a273);
    ddx_line_rec.last_ack_code := p4_a274;
    ddx_line_rec.last_ack_date := rosetta_g_miss_date_in_map(p4_a275);
    ddx_line_rec.change_reason := p4_a276;
    ddx_line_rec.change_comments := p4_a277;
    ddx_line_rec.arrival_set := p4_a278;
    ddx_line_rec.ship_set := p4_a279;
    ddx_line_rec.fulfillment_set := p4_a280;
    ddx_line_rec.order_source_id := rosetta_g_miss_num_map(p4_a281);
    ddx_line_rec.orig_sys_shipment_ref := p4_a282;
    ddx_line_rec.change_sequence := p4_a283;
    ddx_line_rec.change_request_code := p4_a284;
    ddx_line_rec.status_flag := p4_a285;
    ddx_line_rec.drop_ship_flag := p4_a286;
    ddx_line_rec.customer_line_number := p4_a287;
    ddx_line_rec.customer_shipment_number := p4_a288;
    ddx_line_rec.customer_item_net_price := rosetta_g_miss_num_map(p4_a289);
    ddx_line_rec.customer_payment_term_id := rosetta_g_miss_num_map(p4_a290);
    ddx_line_rec.ordered_item_id := rosetta_g_miss_num_map(p4_a291);
    ddx_line_rec.item_identifier_type := p4_a292;
    ddx_line_rec.shipping_instructions := p4_a293;
    ddx_line_rec.packing_instructions := p4_a294;
    ddx_line_rec.calculate_price_flag := p4_a295;
    ddx_line_rec.invoiced_quantity := rosetta_g_miss_num_map(p4_a296);
    ddx_line_rec.service_txn_reason_code := p4_a297;
    ddx_line_rec.service_txn_comments := p4_a298;
    ddx_line_rec.service_duration := rosetta_g_miss_num_map(p4_a299);
    ddx_line_rec.service_period := p4_a300;
    ddx_line_rec.service_start_date := rosetta_g_miss_date_in_map(p4_a301);
    ddx_line_rec.service_end_date := rosetta_g_miss_date_in_map(p4_a302);
    ddx_line_rec.service_coterminate_flag := p4_a303;
    ddx_line_rec.unit_list_percent := rosetta_g_miss_num_map(p4_a304);
    ddx_line_rec.unit_selling_percent := rosetta_g_miss_num_map(p4_a305);
    ddx_line_rec.unit_percent_base_price := rosetta_g_miss_num_map(p4_a306);
    ddx_line_rec.service_number := rosetta_g_miss_num_map(p4_a307);
    ddx_line_rec.service_reference_type_code := p4_a308;
    ddx_line_rec.service_reference_line_id := rosetta_g_miss_num_map(p4_a309);
    ddx_line_rec.service_reference_system_id := rosetta_g_miss_num_map(p4_a310);
    ddx_line_rec.service_ref_order_number := rosetta_g_miss_num_map(p4_a311);
    ddx_line_rec.service_ref_line_number := rosetta_g_miss_num_map(p4_a312);
    ddx_line_rec.service_reference_order := p4_a313;
    ddx_line_rec.service_reference_line := p4_a314;
    ddx_line_rec.service_reference_system := p4_a315;
    ddx_line_rec.service_ref_shipment_number := rosetta_g_miss_num_map(p4_a316);
    ddx_line_rec.service_ref_option_number := rosetta_g_miss_num_map(p4_a317);
    ddx_line_rec.service_line_index := rosetta_g_miss_num_map(p4_a318);
    ddx_line_rec.line_set_id := rosetta_g_miss_num_map(p4_a319);
    ddx_line_rec.split_by := p4_a320;
    ddx_line_rec.split_action_code := p4_a321;
    ddx_line_rec.shippable_flag := p4_a322;
    ddx_line_rec.model_remnant_flag := p4_a323;
    ddx_line_rec.flow_status_code := p4_a324;
    ddx_line_rec.fulfilled_flag := p4_a325;
    ddx_line_rec.fulfillment_method_code := p4_a326;
    ddx_line_rec.revenue_amount := rosetta_g_miss_num_map(p4_a327);
    ddx_line_rec.marketing_source_code_id := rosetta_g_miss_num_map(p4_a328);
    ddx_line_rec.fulfillment_date := rosetta_g_miss_date_in_map(p4_a329);
    if p4_a330 is null
      then ddx_line_rec.semi_processed_flag := null;
    elsif p4_a330 = 0
      then ddx_line_rec.semi_processed_flag := false;
    else ddx_line_rec.semi_processed_flag := true;
    end if;
    ddx_line_rec.upgraded_flag := p4_a331;
    ddx_line_rec.lock_control := rosetta_g_miss_num_map(p4_a332);
    ddx_line_rec.subinventory := p4_a333;
    ddx_line_rec.split_from_line_ref := p4_a334;
    ddx_line_rec.split_from_shipment_ref := p4_a335;
    ddx_line_rec.ship_to_edi_location_code := p4_a336;
    ddx_line_rec.bill_to_edi_location_code := p4_a337;
    ddx_line_rec.ship_from_edi_location_code := p4_a338;
    ddx_line_rec.ship_from_address_id := rosetta_g_miss_num_map(p4_a339);
    ddx_line_rec.sold_to_address_id := rosetta_g_miss_num_map(p4_a340);
    ddx_line_rec.ship_to_address_id := rosetta_g_miss_num_map(p4_a341);
    ddx_line_rec.invoice_address_id := rosetta_g_miss_num_map(p4_a342);
    ddx_line_rec.ship_to_address_code := p4_a343;
    ddx_line_rec.original_inventory_item_id := rosetta_g_miss_num_map(p4_a344);
    ddx_line_rec.original_item_identifier_type := p4_a345;
    ddx_line_rec.original_ordered_item_id := rosetta_g_miss_num_map(p4_a346);
    ddx_line_rec.original_ordered_item := p4_a347;
    ddx_line_rec.item_substitution_type_code := p4_a348;
    ddx_line_rec.late_demand_penalty_factor := rosetta_g_miss_num_map(p4_a349);
    ddx_line_rec.override_atp_date_code := p4_a350;
    ddx_line_rec.ship_to_customer_id := rosetta_g_miss_num_map(p4_a351);
    ddx_line_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p4_a352);
    ddx_line_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p4_a353);
    ddx_line_rec.accounting_rule_duration := rosetta_g_miss_num_map(p4_a354);
    ddx_line_rec.unit_cost := rosetta_g_miss_num_map(p4_a355);
    ddx_line_rec.user_item_description := p4_a356;
    ddx_line_rec.xml_transaction_type_code := p4_a357;
    ddx_line_rec.item_relationship_type := rosetta_g_miss_num_map(p4_a358);
    ddx_line_rec.blanket_number := rosetta_g_miss_num_map(p4_a359);
    ddx_line_rec.blanket_line_number := rosetta_g_miss_num_map(p4_a360);
    ddx_line_rec.blanket_version_number := rosetta_g_miss_num_map(p4_a361);
    ddx_line_rec.cso_response_flag := p4_a362;
    ddx_line_rec.firm_demand_flag := p4_a363;
    ddx_line_rec.earliest_ship_date := rosetta_g_miss_date_in_map(p4_a364);
    ddx_line_rec.transaction_phase_code := p4_a365;
    ddx_line_rec.source_document_version_number := rosetta_g_miss_num_map(p4_a366);
    ddx_line_rec.minisite_id := rosetta_g_miss_num_map(p4_a367);
    ddx_line_rec.ib_owner := p4_a368;
    ddx_line_rec.ib_installed_at_location := p4_a369;
    ddx_line_rec.ib_current_location := p4_a370;
    ddx_line_rec.end_customer_id := rosetta_g_miss_num_map(p4_a371);
    ddx_line_rec.end_customer_contact_id := rosetta_g_miss_num_map(p4_a372);
    ddx_line_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p4_a373);
    ddx_line_rec.supplier_signature := p4_a374;
    ddx_line_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p4_a375);
    ddx_line_rec.customer_signature := p4_a376;
    ddx_line_rec.customer_signature_date := rosetta_g_miss_date_in_map(p4_a377);
    ddx_line_rec.ship_to_party_id := rosetta_g_miss_num_map(p4_a378);
    ddx_line_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p4_a379);
    ddx_line_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p4_a380);
    ddx_line_rec.deliver_to_party_id := rosetta_g_miss_num_map(p4_a381);
    ddx_line_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p4_a382);
    ddx_line_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p4_a383);
    ddx_line_rec.invoice_to_party_id := rosetta_g_miss_num_map(p4_a384);
    ddx_line_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p4_a385);
    ddx_line_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p4_a386);
    ddx_line_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p4_a387);
    ddx_line_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p4_a388);
    ddx_line_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p4_a389);
    ddx_line_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p4_a390);
    ddx_line_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p4_a391);
    ddx_line_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p4_a392);
    ddx_line_rec.retrobill_request_id := rosetta_g_miss_num_map(p4_a393);
    ddx_line_rec.original_list_price := rosetta_g_miss_num_map(p4_a394);
    ddx_line_rec.commitment_applied_amount := rosetta_g_miss_num_map(p4_a395);

    ddx_line_val_rec.accounting_rule := p5_a0;
    ddx_line_val_rec.agreement := p5_a1;
    ddx_line_val_rec.commitment := p5_a2;
    ddx_line_val_rec.commitment_applied_amount := rosetta_g_miss_num_map(p5_a3);
    ddx_line_val_rec.deliver_to_address1 := p5_a4;
    ddx_line_val_rec.deliver_to_address2 := p5_a5;
    ddx_line_val_rec.deliver_to_address3 := p5_a6;
    ddx_line_val_rec.deliver_to_address4 := p5_a7;
    ddx_line_val_rec.deliver_to_contact := p5_a8;
    ddx_line_val_rec.deliver_to_location := p5_a9;
    ddx_line_val_rec.deliver_to_org := p5_a10;
    ddx_line_val_rec.deliver_to_state := p5_a11;
    ddx_line_val_rec.deliver_to_city := p5_a12;
    ddx_line_val_rec.deliver_to_zip := p5_a13;
    ddx_line_val_rec.deliver_to_country := p5_a14;
    ddx_line_val_rec.deliver_to_county := p5_a15;
    ddx_line_val_rec.deliver_to_province := p5_a16;
    ddx_line_val_rec.demand_class := p5_a17;
    ddx_line_val_rec.demand_bucket_type := p5_a18;
    ddx_line_val_rec.fob_point := p5_a19;
    ddx_line_val_rec.freight_terms := p5_a20;
    ddx_line_val_rec.inventory_item := p5_a21;
    ddx_line_val_rec.invoice_to_address1 := p5_a22;
    ddx_line_val_rec.invoice_to_address2 := p5_a23;
    ddx_line_val_rec.invoice_to_address3 := p5_a24;
    ddx_line_val_rec.invoice_to_address4 := p5_a25;
    ddx_line_val_rec.invoice_to_contact := p5_a26;
    ddx_line_val_rec.invoice_to_location := p5_a27;
    ddx_line_val_rec.invoice_to_org := p5_a28;
    ddx_line_val_rec.invoice_to_state := p5_a29;
    ddx_line_val_rec.invoice_to_city := p5_a30;
    ddx_line_val_rec.invoice_to_zip := p5_a31;
    ddx_line_val_rec.invoice_to_country := p5_a32;
    ddx_line_val_rec.invoice_to_county := p5_a33;
    ddx_line_val_rec.invoice_to_province := p5_a34;
    ddx_line_val_rec.invoicing_rule := p5_a35;
    ddx_line_val_rec.item_type := p5_a36;
    ddx_line_val_rec.line_type := p5_a37;
    ddx_line_val_rec.over_ship_reason := p5_a38;
    ddx_line_val_rec.payment_term := p5_a39;
    ddx_line_val_rec.price_list := p5_a40;
    ddx_line_val_rec.project := p5_a41;
    ddx_line_val_rec.return_reason := p5_a42;
    ddx_line_val_rec.rla_schedule_type := p5_a43;
    ddx_line_val_rec.salesrep := p5_a44;
    ddx_line_val_rec.shipment_priority := p5_a45;
    ddx_line_val_rec.ship_from_address1 := p5_a46;
    ddx_line_val_rec.ship_from_address2 := p5_a47;
    ddx_line_val_rec.ship_from_address3 := p5_a48;
    ddx_line_val_rec.ship_from_address4 := p5_a49;
    ddx_line_val_rec.ship_from_location := p5_a50;
    ddx_line_val_rec.ship_from_city := p5_a51;
    ddx_line_val_rec.ship_from_postal_code := p5_a52;
    ddx_line_val_rec.ship_from_country := p5_a53;
    ddx_line_val_rec.ship_from_region1 := p5_a54;
    ddx_line_val_rec.ship_from_region2 := p5_a55;
    ddx_line_val_rec.ship_from_region3 := p5_a56;
    ddx_line_val_rec.ship_from_org := p5_a57;
    ddx_line_val_rec.ship_to_address1 := p5_a58;
    ddx_line_val_rec.ship_to_address2 := p5_a59;
    ddx_line_val_rec.ship_to_address3 := p5_a60;
    ddx_line_val_rec.ship_to_address4 := p5_a61;
    ddx_line_val_rec.ship_to_state := p5_a62;
    ddx_line_val_rec.ship_to_country := p5_a63;
    ddx_line_val_rec.ship_to_zip := p5_a64;
    ddx_line_val_rec.ship_to_county := p5_a65;
    ddx_line_val_rec.ship_to_province := p5_a66;
    ddx_line_val_rec.ship_to_city := p5_a67;
    ddx_line_val_rec.ship_to_contact := p5_a68;
    ddx_line_val_rec.ship_to_contact_last_name := p5_a69;
    ddx_line_val_rec.ship_to_contact_first_name := p5_a70;
    ddx_line_val_rec.ship_to_location := p5_a71;
    ddx_line_val_rec.ship_to_org := p5_a72;
    ddx_line_val_rec.source_type := p5_a73;
    ddx_line_val_rec.intermed_ship_to_address1 := p5_a74;
    ddx_line_val_rec.intermed_ship_to_address2 := p5_a75;
    ddx_line_val_rec.intermed_ship_to_address3 := p5_a76;
    ddx_line_val_rec.intermed_ship_to_address4 := p5_a77;
    ddx_line_val_rec.intermed_ship_to_contact := p5_a78;
    ddx_line_val_rec.intermed_ship_to_location := p5_a79;
    ddx_line_val_rec.intermed_ship_to_org := p5_a80;
    ddx_line_val_rec.intermed_ship_to_state := p5_a81;
    ddx_line_val_rec.intermed_ship_to_city := p5_a82;
    ddx_line_val_rec.intermed_ship_to_zip := p5_a83;
    ddx_line_val_rec.intermed_ship_to_country := p5_a84;
    ddx_line_val_rec.intermed_ship_to_county := p5_a85;
    ddx_line_val_rec.intermed_ship_to_province := p5_a86;
    ddx_line_val_rec.sold_to_org := p5_a87;
    ddx_line_val_rec.sold_from_org := p5_a88;
    ddx_line_val_rec.task := p5_a89;
    ddx_line_val_rec.tax_exempt := p5_a90;
    ddx_line_val_rec.tax_exempt_reason := p5_a91;
    ddx_line_val_rec.tax_point := p5_a92;
    ddx_line_val_rec.veh_cus_item_cum_key := p5_a93;
    ddx_line_val_rec.visible_demand := p5_a94;
    ddx_line_val_rec.customer_payment_term := p5_a95;
    ddx_line_val_rec.ref_order_number := rosetta_g_miss_num_map(p5_a96);
    ddx_line_val_rec.ref_line_number := rosetta_g_miss_num_map(p5_a97);
    ddx_line_val_rec.ref_shipment_number := rosetta_g_miss_num_map(p5_a98);
    ddx_line_val_rec.ref_option_number := rosetta_g_miss_num_map(p5_a99);
    ddx_line_val_rec.ref_invoice_number := p5_a100;
    ddx_line_val_rec.ref_invoice_line_number := rosetta_g_miss_num_map(p5_a101);
    ddx_line_val_rec.credit_invoice_number := p5_a102;
    ddx_line_val_rec.tax_group := p5_a103;
    ddx_line_val_rec.status := p5_a104;
    ddx_line_val_rec.freight_carrier := p5_a105;
    ddx_line_val_rec.shipping_method := p5_a106;
    ddx_line_val_rec.calculate_price_descr := p5_a107;
    ddx_line_val_rec.ship_to_customer_name := p5_a108;
    ddx_line_val_rec.invoice_to_customer_name := p5_a109;
    ddx_line_val_rec.ship_to_customer_number := p5_a110;
    ddx_line_val_rec.invoice_to_customer_number := p5_a111;
    ddx_line_val_rec.ship_to_customer_id := rosetta_g_miss_num_map(p5_a112);
    ddx_line_val_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p5_a113);
    ddx_line_val_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p5_a114);
    ddx_line_val_rec.deliver_to_customer_number := p5_a115;
    ddx_line_val_rec.deliver_to_customer_name := p5_a116;
    ddx_line_val_rec.original_ordered_item := p5_a117;
    ddx_line_val_rec.original_inventory_item := p5_a118;
    ddx_line_val_rec.original_item_identifier_type := p5_a119;
    ddx_line_val_rec.deliver_to_customer_number_oi := p5_a120;
    ddx_line_val_rec.deliver_to_customer_name_oi := p5_a121;
    ddx_line_val_rec.ship_to_customer_number_oi := p5_a122;
    ddx_line_val_rec.ship_to_customer_name_oi := p5_a123;
    ddx_line_val_rec.invoice_to_customer_number_oi := p5_a124;
    ddx_line_val_rec.invoice_to_customer_name_oi := p5_a125;
    ddx_line_val_rec.item_relationship_type_dsp := p5_a126;
    ddx_line_val_rec.transaction_phase := p5_a127;
    ddx_line_val_rec.end_customer_name := p5_a128;
    ddx_line_val_rec.end_customer_number := p5_a129;
    ddx_line_val_rec.end_customer_contact := p5_a130;
    ddx_line_val_rec.end_cust_contact_last_name := p5_a131;
    ddx_line_val_rec.end_cust_contact_first_name := p5_a132;
    ddx_line_val_rec.end_customer_site_address1 := p5_a133;
    ddx_line_val_rec.end_customer_site_address2 := p5_a134;
    ddx_line_val_rec.end_customer_site_address3 := p5_a135;
    ddx_line_val_rec.end_customer_site_address4 := p5_a136;
    ddx_line_val_rec.end_customer_site_location := p5_a137;
    ddx_line_val_rec.end_customer_site_state := p5_a138;
    ddx_line_val_rec.end_customer_site_country := p5_a139;
    ddx_line_val_rec.end_customer_site_zip := p5_a140;
    ddx_line_val_rec.end_customer_site_county := p5_a141;
    ddx_line_val_rec.end_customer_site_province := p5_a142;
    ddx_line_val_rec.end_customer_site_city := p5_a143;
    ddx_line_val_rec.end_customer_site_postal_code := p5_a144;
    ddx_line_val_rec.blanket_agreement_name := p5_a145;

    ddp_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p6_a0);
    ddp_header_rec.agreement_id := rosetta_g_miss_num_map(p6_a1);
    ddp_header_rec.attribute1 := p6_a2;
    ddp_header_rec.attribute10 := p6_a3;
    ddp_header_rec.attribute11 := p6_a4;
    ddp_header_rec.attribute12 := p6_a5;
    ddp_header_rec.attribute13 := p6_a6;
    ddp_header_rec.attribute14 := p6_a7;
    ddp_header_rec.attribute15 := p6_a8;
    ddp_header_rec.attribute16 := p6_a9;
    ddp_header_rec.attribute17 := p6_a10;
    ddp_header_rec.attribute18 := p6_a11;
    ddp_header_rec.attribute19 := p6_a12;
    ddp_header_rec.attribute2 := p6_a13;
    ddp_header_rec.attribute20 := p6_a14;
    ddp_header_rec.attribute3 := p6_a15;
    ddp_header_rec.attribute4 := p6_a16;
    ddp_header_rec.attribute5 := p6_a17;
    ddp_header_rec.attribute6 := p6_a18;
    ddp_header_rec.attribute7 := p6_a19;
    ddp_header_rec.attribute8 := p6_a20;
    ddp_header_rec.attribute9 := p6_a21;
    ddp_header_rec.booked_flag := p6_a22;
    ddp_header_rec.cancelled_flag := p6_a23;
    ddp_header_rec.context := p6_a24;
    ddp_header_rec.conversion_rate := rosetta_g_miss_num_map(p6_a25);
    ddp_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p6_a26);
    ddp_header_rec.conversion_type_code := p6_a27;
    ddp_header_rec.customer_preference_set_code := p6_a28;
    ddp_header_rec.created_by := rosetta_g_miss_num_map(p6_a29);
    ddp_header_rec.creation_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_header_rec.cust_po_number := p6_a31;
    ddp_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p6_a32);
    ddp_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p6_a33);
    ddp_header_rec.demand_class_code := p6_a34;
    ddp_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p6_a35);
    ddp_header_rec.expiration_date := rosetta_g_miss_date_in_map(p6_a36);
    ddp_header_rec.fob_point_code := p6_a37;
    ddp_header_rec.freight_carrier_code := p6_a38;
    ddp_header_rec.freight_terms_code := p6_a39;
    ddp_header_rec.global_attribute1 := p6_a40;
    ddp_header_rec.global_attribute10 := p6_a41;
    ddp_header_rec.global_attribute11 := p6_a42;
    ddp_header_rec.global_attribute12 := p6_a43;
    ddp_header_rec.global_attribute13 := p6_a44;
    ddp_header_rec.global_attribute14 := p6_a45;
    ddp_header_rec.global_attribute15 := p6_a46;
    ddp_header_rec.global_attribute16 := p6_a47;
    ddp_header_rec.global_attribute17 := p6_a48;
    ddp_header_rec.global_attribute18 := p6_a49;
    ddp_header_rec.global_attribute19 := p6_a50;
    ddp_header_rec.global_attribute2 := p6_a51;
    ddp_header_rec.global_attribute20 := p6_a52;
    ddp_header_rec.global_attribute3 := p6_a53;
    ddp_header_rec.global_attribute4 := p6_a54;
    ddp_header_rec.global_attribute5 := p6_a55;
    ddp_header_rec.global_attribute6 := p6_a56;
    ddp_header_rec.global_attribute7 := p6_a57;
    ddp_header_rec.global_attribute8 := p6_a58;
    ddp_header_rec.global_attribute9 := p6_a59;
    ddp_header_rec.global_attribute_category := p6_a60;
    ddp_header_rec.tp_context := p6_a61;
    ddp_header_rec.tp_attribute1 := p6_a62;
    ddp_header_rec.tp_attribute2 := p6_a63;
    ddp_header_rec.tp_attribute3 := p6_a64;
    ddp_header_rec.tp_attribute4 := p6_a65;
    ddp_header_rec.tp_attribute5 := p6_a66;
    ddp_header_rec.tp_attribute6 := p6_a67;
    ddp_header_rec.tp_attribute7 := p6_a68;
    ddp_header_rec.tp_attribute8 := p6_a69;
    ddp_header_rec.tp_attribute9 := p6_a70;
    ddp_header_rec.tp_attribute10 := p6_a71;
    ddp_header_rec.tp_attribute11 := p6_a72;
    ddp_header_rec.tp_attribute12 := p6_a73;
    ddp_header_rec.tp_attribute13 := p6_a74;
    ddp_header_rec.tp_attribute14 := p6_a75;
    ddp_header_rec.tp_attribute15 := p6_a76;
    ddp_header_rec.header_id := rosetta_g_miss_num_map(p6_a77);
    ddp_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p6_a78);
    ddp_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p6_a79);
    ddp_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p6_a80);
    ddp_header_rec.last_updated_by := rosetta_g_miss_num_map(p6_a81);
    ddp_header_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a82);
    ddp_header_rec.last_update_login := rosetta_g_miss_num_map(p6_a83);
    ddp_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p6_a84);
    ddp_header_rec.open_flag := p6_a85;
    ddp_header_rec.order_category_code := p6_a86;
    ddp_header_rec.ordered_date := rosetta_g_miss_date_in_map(p6_a87);
    ddp_header_rec.order_date_type_code := p6_a88;
    ddp_header_rec.order_number := rosetta_g_miss_num_map(p6_a89);
    ddp_header_rec.order_source_id := rosetta_g_miss_num_map(p6_a90);
    ddp_header_rec.order_type_id := rosetta_g_miss_num_map(p6_a91);
    ddp_header_rec.org_id := rosetta_g_miss_num_map(p6_a92);
    ddp_header_rec.orig_sys_document_ref := p6_a93;
    ddp_header_rec.partial_shipments_allowed := p6_a94;
    ddp_header_rec.payment_term_id := rosetta_g_miss_num_map(p6_a95);
    ddp_header_rec.price_list_id := rosetta_g_miss_num_map(p6_a96);
    ddp_header_rec.price_request_code := p6_a97;
    ddp_header_rec.pricing_date := rosetta_g_miss_date_in_map(p6_a98);
    ddp_header_rec.program_application_id := rosetta_g_miss_num_map(p6_a99);
    ddp_header_rec.program_id := rosetta_g_miss_num_map(p6_a100);
    ddp_header_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a101);
    ddp_header_rec.request_date := rosetta_g_miss_date_in_map(p6_a102);
    ddp_header_rec.request_id := rosetta_g_miss_num_map(p6_a103);
    ddp_header_rec.return_reason_code := p6_a104;
    ddp_header_rec.salesrep_id := rosetta_g_miss_num_map(p6_a105);
    ddp_header_rec.sales_channel_code := p6_a106;
    ddp_header_rec.shipment_priority_code := p6_a107;
    ddp_header_rec.shipping_method_code := p6_a108;
    ddp_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p6_a109);
    ddp_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p6_a110);
    ddp_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p6_a111);
    ddp_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p6_a112);
    ddp_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p6_a113);
    ddp_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p6_a114);
    ddp_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p6_a115);
    ddp_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p6_a116);
    ddp_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p6_a117);
    ddp_header_rec.source_document_id := rosetta_g_miss_num_map(p6_a118);
    ddp_header_rec.source_document_type_id := rosetta_g_miss_num_map(p6_a119);
    ddp_header_rec.tax_exempt_flag := p6_a120;
    ddp_header_rec.tax_exempt_number := p6_a121;
    ddp_header_rec.tax_exempt_reason_code := p6_a122;
    ddp_header_rec.tax_point_code := p6_a123;
    ddp_header_rec.transactional_curr_code := p6_a124;
    ddp_header_rec.version_number := rosetta_g_miss_num_map(p6_a125);
    ddp_header_rec.return_status := p6_a126;
    ddp_header_rec.db_flag := p6_a127;
    ddp_header_rec.operation := p6_a128;
    ddp_header_rec.first_ack_code := p6_a129;
    ddp_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p6_a130);
    ddp_header_rec.last_ack_code := p6_a131;
    ddp_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p6_a132);
    ddp_header_rec.change_reason := p6_a133;
    ddp_header_rec.change_comments := p6_a134;
    ddp_header_rec.change_sequence := p6_a135;
    ddp_header_rec.change_request_code := p6_a136;
    ddp_header_rec.ready_flag := p6_a137;
    ddp_header_rec.status_flag := p6_a138;
    ddp_header_rec.force_apply_flag := p6_a139;
    ddp_header_rec.drop_ship_flag := p6_a140;
    ddp_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p6_a141);
    ddp_header_rec.payment_type_code := p6_a142;
    ddp_header_rec.payment_amount := rosetta_g_miss_num_map(p6_a143);
    ddp_header_rec.check_number := p6_a144;
    ddp_header_rec.credit_card_code := p6_a145;
    ddp_header_rec.credit_card_holder_name := p6_a146;
    ddp_header_rec.credit_card_number := p6_a147;
    ddp_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p6_a148);
    ddp_header_rec.credit_card_approval_code := p6_a149;
    ddp_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p6_a150);
    ddp_header_rec.shipping_instructions := p6_a151;
    ddp_header_rec.packing_instructions := p6_a152;
    ddp_header_rec.flow_status_code := p6_a153;
    ddp_header_rec.booked_date := rosetta_g_miss_date_in_map(p6_a154);
    ddp_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p6_a155);
    ddp_header_rec.upgraded_flag := p6_a156;
    ddp_header_rec.lock_control := rosetta_g_miss_num_map(p6_a157);
    ddp_header_rec.ship_to_edi_location_code := p6_a158;
    ddp_header_rec.sold_to_edi_location_code := p6_a159;
    ddp_header_rec.bill_to_edi_location_code := p6_a160;
    ddp_header_rec.ship_from_edi_location_code := p6_a161;
    ddp_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p6_a162);
    ddp_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p6_a163);
    ddp_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p6_a164);
    ddp_header_rec.invoice_address_id := rosetta_g_miss_num_map(p6_a165);
    ddp_header_rec.ship_to_address_code := p6_a166;
    ddp_header_rec.xml_message_id := rosetta_g_miss_num_map(p6_a167);
    ddp_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p6_a168);
    ddp_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p6_a169);
    ddp_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p6_a170);
    ddp_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p6_a171);
    ddp_header_rec.xml_transaction_type_code := p6_a172;
    ddp_header_rec.blanket_number := rosetta_g_miss_num_map(p6_a173);
    ddp_header_rec.line_set_name := p6_a174;
    ddp_header_rec.fulfillment_set_name := p6_a175;
    ddp_header_rec.default_fulfillment_set := p6_a176;
    ddp_header_rec.quote_date := rosetta_g_miss_date_in_map(p6_a177);
    ddp_header_rec.quote_number := rosetta_g_miss_num_map(p6_a178);
    ddp_header_rec.sales_document_name := p6_a179;
    ddp_header_rec.transaction_phase_code := p6_a180;
    ddp_header_rec.user_status_code := p6_a181;
    ddp_header_rec.draft_submitted_flag := p6_a182;
    ddp_header_rec.source_document_version_number := rosetta_g_miss_num_map(p6_a183);
    ddp_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p6_a184);
    ddp_header_rec.minisite_id := rosetta_g_miss_num_map(p6_a185);
    ddp_header_rec.ib_owner := p6_a186;
    ddp_header_rec.ib_installed_at_location := p6_a187;
    ddp_header_rec.ib_current_location := p6_a188;
    ddp_header_rec.end_customer_id := rosetta_g_miss_num_map(p6_a189);
    ddp_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p6_a190);
    ddp_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p6_a191);
    ddp_header_rec.supplier_signature := p6_a192;
    ddp_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p6_a193);
    ddp_header_rec.customer_signature := p6_a194;
    ddp_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p6_a195);
    ddp_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p6_a196);
    ddp_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p6_a197);
    ddp_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p6_a198);
    ddp_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p6_a199);
    ddp_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p6_a200);
    ddp_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p6_a201);
    ddp_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p6_a202);
    ddp_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p6_a203);
    ddp_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p6_a204);
    ddp_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p6_a205);
    ddp_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p6_a206);
    ddp_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p6_a207);
    ddp_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p6_a208);
    ddp_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p6_a209);
    ddp_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p6_a210);
    ddp_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p6_a211);
    ddp_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p6_a212);
    ddp_header_rec.contract_template_id := rosetta_g_miss_num_map(p6_a213);
    ddp_header_rec.contract_source_doc_type_code := p6_a214;
    ddp_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p6_a215);

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_line.default_attributes(x_return_status,
      x_msg_count,
      x_msg_data,
      p_header_id,
      ddx_line_rec,
      ddx_line_val_rec,
      ddp_header_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_id);
    p4_a1 := ddx_line_rec.actual_arrival_date;
    p4_a2 := ddx_line_rec.actual_shipment_date;
    p4_a3 := rosetta_g_miss_num_map(ddx_line_rec.agreement_id);
    p4_a4 := rosetta_g_miss_num_map(ddx_line_rec.arrival_set_id);
    p4_a5 := rosetta_g_miss_num_map(ddx_line_rec.ato_line_id);
    p4_a6 := ddx_line_rec.attribute1;
    p4_a7 := ddx_line_rec.attribute10;
    p4_a8 := ddx_line_rec.attribute11;
    p4_a9 := ddx_line_rec.attribute12;
    p4_a10 := ddx_line_rec.attribute13;
    p4_a11 := ddx_line_rec.attribute14;
    p4_a12 := ddx_line_rec.attribute15;
    p4_a13 := ddx_line_rec.attribute16;
    p4_a14 := ddx_line_rec.attribute17;
    p4_a15 := ddx_line_rec.attribute18;
    p4_a16 := ddx_line_rec.attribute19;
    p4_a17 := ddx_line_rec.attribute2;
    p4_a18 := ddx_line_rec.attribute20;
    p4_a19 := ddx_line_rec.attribute3;
    p4_a20 := ddx_line_rec.attribute4;
    p4_a21 := ddx_line_rec.attribute5;
    p4_a22 := ddx_line_rec.attribute6;
    p4_a23 := ddx_line_rec.attribute7;
    p4_a24 := ddx_line_rec.attribute8;
    p4_a25 := ddx_line_rec.attribute9;
    p4_a26 := ddx_line_rec.authorized_to_ship_flag;
    p4_a27 := rosetta_g_miss_num_map(ddx_line_rec.auto_selected_quantity);
    p4_a28 := ddx_line_rec.booked_flag;
    p4_a29 := ddx_line_rec.cancelled_flag;
    p4_a30 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity);
    p4_a31 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity2);
    p4_a32 := rosetta_g_miss_num_map(ddx_line_rec.commitment_id);
    p4_a33 := ddx_line_rec.component_code;
    p4_a34 := rosetta_g_miss_num_map(ddx_line_rec.component_number);
    p4_a35 := rosetta_g_miss_num_map(ddx_line_rec.component_sequence_id);
    p4_a36 := rosetta_g_miss_num_map(ddx_line_rec.config_header_id);
    p4_a37 := rosetta_g_miss_num_map(ddx_line_rec.config_rev_nbr);
    p4_a38 := rosetta_g_miss_num_map(ddx_line_rec.config_display_sequence);
    p4_a39 := rosetta_g_miss_num_map(ddx_line_rec.configuration_id);
    p4_a40 := ddx_line_rec.context;
    p4_a41 := rosetta_g_miss_num_map(ddx_line_rec.created_by);
    p4_a42 := ddx_line_rec.creation_date;
    p4_a43 := rosetta_g_miss_num_map(ddx_line_rec.credit_invoice_line_id);
    p4_a44 := ddx_line_rec.customer_dock_code;
    p4_a45 := ddx_line_rec.customer_job;
    p4_a46 := ddx_line_rec.customer_production_line;
    p4_a47 := rosetta_g_miss_num_map(ddx_line_rec.customer_trx_line_id);
    p4_a48 := ddx_line_rec.cust_model_serial_number;
    p4_a49 := ddx_line_rec.cust_po_number;
    p4_a50 := ddx_line_rec.cust_production_seq_num;
    p4_a51 := rosetta_g_miss_num_map(ddx_line_rec.delivery_lead_time);
    p4_a52 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_contact_id);
    p4_a53 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_id);
    p4_a54 := ddx_line_rec.demand_bucket_type_code;
    p4_a55 := ddx_line_rec.demand_class_code;
    p4_a56 := ddx_line_rec.dep_plan_required_flag;
    p4_a57 := ddx_line_rec.earliest_acceptable_date;
    p4_a58 := ddx_line_rec.end_item_unit_number;
    p4_a59 := ddx_line_rec.explosion_date;
    p4_a60 := ddx_line_rec.fob_point_code;
    p4_a61 := ddx_line_rec.freight_carrier_code;
    p4_a62 := ddx_line_rec.freight_terms_code;
    p4_a63 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity);
    p4_a64 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity2);
    p4_a65 := ddx_line_rec.global_attribute1;
    p4_a66 := ddx_line_rec.global_attribute10;
    p4_a67 := ddx_line_rec.global_attribute11;
    p4_a68 := ddx_line_rec.global_attribute12;
    p4_a69 := ddx_line_rec.global_attribute13;
    p4_a70 := ddx_line_rec.global_attribute14;
    p4_a71 := ddx_line_rec.global_attribute15;
    p4_a72 := ddx_line_rec.global_attribute16;
    p4_a73 := ddx_line_rec.global_attribute17;
    p4_a74 := ddx_line_rec.global_attribute18;
    p4_a75 := ddx_line_rec.global_attribute19;
    p4_a76 := ddx_line_rec.global_attribute2;
    p4_a77 := ddx_line_rec.global_attribute20;
    p4_a78 := ddx_line_rec.global_attribute3;
    p4_a79 := ddx_line_rec.global_attribute4;
    p4_a80 := ddx_line_rec.global_attribute5;
    p4_a81 := ddx_line_rec.global_attribute6;
    p4_a82 := ddx_line_rec.global_attribute7;
    p4_a83 := ddx_line_rec.global_attribute8;
    p4_a84 := ddx_line_rec.global_attribute9;
    p4_a85 := ddx_line_rec.global_attribute_category;
    p4_a86 := rosetta_g_miss_num_map(ddx_line_rec.header_id);
    p4_a87 := ddx_line_rec.industry_attribute1;
    p4_a88 := ddx_line_rec.industry_attribute10;
    p4_a89 := ddx_line_rec.industry_attribute11;
    p4_a90 := ddx_line_rec.industry_attribute12;
    p4_a91 := ddx_line_rec.industry_attribute13;
    p4_a92 := ddx_line_rec.industry_attribute14;
    p4_a93 := ddx_line_rec.industry_attribute15;
    p4_a94 := ddx_line_rec.industry_attribute16;
    p4_a95 := ddx_line_rec.industry_attribute17;
    p4_a96 := ddx_line_rec.industry_attribute18;
    p4_a97 := ddx_line_rec.industry_attribute19;
    p4_a98 := ddx_line_rec.industry_attribute20;
    p4_a99 := ddx_line_rec.industry_attribute21;
    p4_a100 := ddx_line_rec.industry_attribute22;
    p4_a101 := ddx_line_rec.industry_attribute23;
    p4_a102 := ddx_line_rec.industry_attribute24;
    p4_a103 := ddx_line_rec.industry_attribute25;
    p4_a104 := ddx_line_rec.industry_attribute26;
    p4_a105 := ddx_line_rec.industry_attribute27;
    p4_a106 := ddx_line_rec.industry_attribute28;
    p4_a107 := ddx_line_rec.industry_attribute29;
    p4_a108 := ddx_line_rec.industry_attribute30;
    p4_a109 := ddx_line_rec.industry_attribute2;
    p4_a110 := ddx_line_rec.industry_attribute3;
    p4_a111 := ddx_line_rec.industry_attribute4;
    p4_a112 := ddx_line_rec.industry_attribute5;
    p4_a113 := ddx_line_rec.industry_attribute6;
    p4_a114 := ddx_line_rec.industry_attribute7;
    p4_a115 := ddx_line_rec.industry_attribute8;
    p4_a116 := ddx_line_rec.industry_attribute9;
    p4_a117 := ddx_line_rec.industry_context;
    p4_a118 := ddx_line_rec.tp_context;
    p4_a119 := ddx_line_rec.tp_attribute1;
    p4_a120 := ddx_line_rec.tp_attribute2;
    p4_a121 := ddx_line_rec.tp_attribute3;
    p4_a122 := ddx_line_rec.tp_attribute4;
    p4_a123 := ddx_line_rec.tp_attribute5;
    p4_a124 := ddx_line_rec.tp_attribute6;
    p4_a125 := ddx_line_rec.tp_attribute7;
    p4_a126 := ddx_line_rec.tp_attribute8;
    p4_a127 := ddx_line_rec.tp_attribute9;
    p4_a128 := ddx_line_rec.tp_attribute10;
    p4_a129 := ddx_line_rec.tp_attribute11;
    p4_a130 := ddx_line_rec.tp_attribute12;
    p4_a131 := ddx_line_rec.tp_attribute13;
    p4_a132 := ddx_line_rec.tp_attribute14;
    p4_a133 := ddx_line_rec.tp_attribute15;
    p4_a134 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_org_id);
    p4_a135 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_contact_id);
    p4_a136 := rosetta_g_miss_num_map(ddx_line_rec.inventory_item_id);
    p4_a137 := ddx_line_rec.invoice_interface_status_code;
    p4_a138 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_contact_id);
    p4_a139 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_id);
    p4_a140 := rosetta_g_miss_num_map(ddx_line_rec.invoicing_rule_id);
    p4_a141 := ddx_line_rec.ordered_item;
    p4_a142 := ddx_line_rec.item_revision;
    p4_a143 := ddx_line_rec.item_type_code;
    p4_a144 := rosetta_g_miss_num_map(ddx_line_rec.last_updated_by);
    p4_a145 := ddx_line_rec.last_update_date;
    p4_a146 := rosetta_g_miss_num_map(ddx_line_rec.last_update_login);
    p4_a147 := ddx_line_rec.latest_acceptable_date;
    p4_a148 := ddx_line_rec.line_category_code;
    p4_a149 := rosetta_g_miss_num_map(ddx_line_rec.line_id);
    p4_a150 := rosetta_g_miss_num_map(ddx_line_rec.line_number);
    p4_a151 := rosetta_g_miss_num_map(ddx_line_rec.line_type_id);
    p4_a152 := ddx_line_rec.link_to_line_ref;
    p4_a153 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_id);
    p4_a154 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_index);
    p4_a155 := rosetta_g_miss_num_map(ddx_line_rec.model_group_number);
    p4_a156 := rosetta_g_miss_num_map(ddx_line_rec.mfg_component_sequence_id);
    p4_a157 := rosetta_g_miss_num_map(ddx_line_rec.mfg_lead_time);
    p4_a158 := ddx_line_rec.open_flag;
    p4_a159 := ddx_line_rec.option_flag;
    p4_a160 := rosetta_g_miss_num_map(ddx_line_rec.option_number);
    p4_a161 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity);
    p4_a162 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity2);
    p4_a163 := ddx_line_rec.order_quantity_uom;
    p4_a164 := ddx_line_rec.ordered_quantity_uom2;
    p4_a165 := rosetta_g_miss_num_map(ddx_line_rec.org_id);
    p4_a166 := ddx_line_rec.orig_sys_document_ref;
    p4_a167 := ddx_line_rec.orig_sys_line_ref;
    p4_a168 := ddx_line_rec.over_ship_reason_code;
    p4_a169 := ddx_line_rec.over_ship_resolved_flag;
    p4_a170 := rosetta_g_miss_num_map(ddx_line_rec.payment_term_id);
    p4_a171 := rosetta_g_miss_num_map(ddx_line_rec.planning_priority);
    p4_a172 := ddx_line_rec.preferred_grade;
    p4_a173 := rosetta_g_miss_num_map(ddx_line_rec.price_list_id);
    p4_a174 := ddx_line_rec.price_request_code;
    p4_a175 := ddx_line_rec.pricing_attribute1;
    p4_a176 := ddx_line_rec.pricing_attribute10;
    p4_a177 := ddx_line_rec.pricing_attribute2;
    p4_a178 := ddx_line_rec.pricing_attribute3;
    p4_a179 := ddx_line_rec.pricing_attribute4;
    p4_a180 := ddx_line_rec.pricing_attribute5;
    p4_a181 := ddx_line_rec.pricing_attribute6;
    p4_a182 := ddx_line_rec.pricing_attribute7;
    p4_a183 := ddx_line_rec.pricing_attribute8;
    p4_a184 := ddx_line_rec.pricing_attribute9;
    p4_a185 := ddx_line_rec.pricing_context;
    p4_a186 := ddx_line_rec.pricing_date;
    p4_a187 := rosetta_g_miss_num_map(ddx_line_rec.pricing_quantity);
    p4_a188 := ddx_line_rec.pricing_quantity_uom;
    p4_a189 := rosetta_g_miss_num_map(ddx_line_rec.program_application_id);
    p4_a190 := rosetta_g_miss_num_map(ddx_line_rec.program_id);
    p4_a191 := ddx_line_rec.program_update_date;
    p4_a192 := rosetta_g_miss_num_map(ddx_line_rec.project_id);
    p4_a193 := ddx_line_rec.promise_date;
    p4_a194 := ddx_line_rec.re_source_flag;
    p4_a195 := rosetta_g_miss_num_map(ddx_line_rec.reference_customer_trx_line_id);
    p4_a196 := rosetta_g_miss_num_map(ddx_line_rec.reference_header_id);
    p4_a197 := rosetta_g_miss_num_map(ddx_line_rec.reference_line_id);
    p4_a198 := ddx_line_rec.reference_type;
    p4_a199 := ddx_line_rec.request_date;
    p4_a200 := rosetta_g_miss_num_map(ddx_line_rec.request_id);
    p4_a201 := rosetta_g_miss_num_map(ddx_line_rec.reserved_quantity);
    p4_a202 := ddx_line_rec.return_attribute1;
    p4_a203 := ddx_line_rec.return_attribute10;
    p4_a204 := ddx_line_rec.return_attribute11;
    p4_a205 := ddx_line_rec.return_attribute12;
    p4_a206 := ddx_line_rec.return_attribute13;
    p4_a207 := ddx_line_rec.return_attribute14;
    p4_a208 := ddx_line_rec.return_attribute15;
    p4_a209 := ddx_line_rec.return_attribute2;
    p4_a210 := ddx_line_rec.return_attribute3;
    p4_a211 := ddx_line_rec.return_attribute4;
    p4_a212 := ddx_line_rec.return_attribute5;
    p4_a213 := ddx_line_rec.return_attribute6;
    p4_a214 := ddx_line_rec.return_attribute7;
    p4_a215 := ddx_line_rec.return_attribute8;
    p4_a216 := ddx_line_rec.return_attribute9;
    p4_a217 := ddx_line_rec.return_context;
    p4_a218 := ddx_line_rec.return_reason_code;
    p4_a219 := ddx_line_rec.rla_schedule_type_code;
    p4_a220 := rosetta_g_miss_num_map(ddx_line_rec.salesrep_id);
    p4_a221 := ddx_line_rec.schedule_arrival_date;
    p4_a222 := ddx_line_rec.schedule_ship_date;
    p4_a223 := ddx_line_rec.schedule_action_code;
    p4_a224 := ddx_line_rec.schedule_status_code;
    p4_a225 := rosetta_g_miss_num_map(ddx_line_rec.shipment_number);
    p4_a226 := ddx_line_rec.shipment_priority_code;
    p4_a227 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity);
    p4_a228 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity2);
    p4_a229 := ddx_line_rec.shipping_interfaced_flag;
    p4_a230 := ddx_line_rec.shipping_method_code;
    p4_a231 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity);
    p4_a232 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity2);
    p4_a233 := ddx_line_rec.shipping_quantity_uom;
    p4_a234 := ddx_line_rec.shipping_quantity_uom2;
    p4_a235 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_org_id);
    p4_a236 := ddx_line_rec.ship_model_complete_flag;
    p4_a237 := rosetta_g_miss_num_map(ddx_line_rec.ship_set_id);
    p4_a238 := rosetta_g_miss_num_map(ddx_line_rec.fulfillment_set_id);
    p4_a239 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_above);
    p4_a240 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_below);
    p4_a241 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_contact_id);
    p4_a242 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_id);
    p4_a243 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_org_id);
    p4_a244 := rosetta_g_miss_num_map(ddx_line_rec.sold_from_org_id);
    p4_a245 := ddx_line_rec.sort_order;
    p4_a246 := rosetta_g_miss_num_map(ddx_line_rec.source_document_id);
    p4_a247 := rosetta_g_miss_num_map(ddx_line_rec.source_document_line_id);
    p4_a248 := rosetta_g_miss_num_map(ddx_line_rec.source_document_type_id);
    p4_a249 := ddx_line_rec.source_type_code;
    p4_a250 := rosetta_g_miss_num_map(ddx_line_rec.split_from_line_id);
    p4_a251 := rosetta_g_miss_num_map(ddx_line_rec.task_id);
    p4_a252 := ddx_line_rec.tax_code;
    p4_a253 := ddx_line_rec.tax_date;
    p4_a254 := ddx_line_rec.tax_exempt_flag;
    p4_a255 := ddx_line_rec.tax_exempt_number;
    p4_a256 := ddx_line_rec.tax_exempt_reason_code;
    p4_a257 := ddx_line_rec.tax_point_code;
    p4_a258 := rosetta_g_miss_num_map(ddx_line_rec.tax_rate);
    p4_a259 := rosetta_g_miss_num_map(ddx_line_rec.tax_value);
    p4_a260 := ddx_line_rec.top_model_line_ref;
    p4_a261 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_id);
    p4_a262 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_index);
    p4_a263 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price);
    p4_a264 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price_per_pqty);
    p4_a265 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price);
    p4_a266 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price_per_pqty);
    p4_a267 := rosetta_g_miss_num_map(ddx_line_rec.veh_cus_item_cum_key_id);
    p4_a268 := ddx_line_rec.visible_demand_flag;
    p4_a269 := ddx_line_rec.return_status;
    p4_a270 := ddx_line_rec.db_flag;
    p4_a271 := ddx_line_rec.operation;
    p4_a272 := ddx_line_rec.first_ack_code;
    p4_a273 := ddx_line_rec.first_ack_date;
    p4_a274 := ddx_line_rec.last_ack_code;
    p4_a275 := ddx_line_rec.last_ack_date;
    p4_a276 := ddx_line_rec.change_reason;
    p4_a277 := ddx_line_rec.change_comments;
    p4_a278 := ddx_line_rec.arrival_set;
    p4_a279 := ddx_line_rec.ship_set;
    p4_a280 := ddx_line_rec.fulfillment_set;
    p4_a281 := rosetta_g_miss_num_map(ddx_line_rec.order_source_id);
    p4_a282 := ddx_line_rec.orig_sys_shipment_ref;
    p4_a283 := ddx_line_rec.change_sequence;
    p4_a284 := ddx_line_rec.change_request_code;
    p4_a285 := ddx_line_rec.status_flag;
    p4_a286 := ddx_line_rec.drop_ship_flag;
    p4_a287 := ddx_line_rec.customer_line_number;
    p4_a288 := ddx_line_rec.customer_shipment_number;
    p4_a289 := rosetta_g_miss_num_map(ddx_line_rec.customer_item_net_price);
    p4_a290 := rosetta_g_miss_num_map(ddx_line_rec.customer_payment_term_id);
    p4_a291 := rosetta_g_miss_num_map(ddx_line_rec.ordered_item_id);
    p4_a292 := ddx_line_rec.item_identifier_type;
    p4_a293 := ddx_line_rec.shipping_instructions;
    p4_a294 := ddx_line_rec.packing_instructions;
    p4_a295 := ddx_line_rec.calculate_price_flag;
    p4_a296 := rosetta_g_miss_num_map(ddx_line_rec.invoiced_quantity);
    p4_a297 := ddx_line_rec.service_txn_reason_code;
    p4_a298 := ddx_line_rec.service_txn_comments;
    p4_a299 := rosetta_g_miss_num_map(ddx_line_rec.service_duration);
    p4_a300 := ddx_line_rec.service_period;
    p4_a301 := ddx_line_rec.service_start_date;
    p4_a302 := ddx_line_rec.service_end_date;
    p4_a303 := ddx_line_rec.service_coterminate_flag;
    p4_a304 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_percent);
    p4_a305 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_percent);
    p4_a306 := rosetta_g_miss_num_map(ddx_line_rec.unit_percent_base_price);
    p4_a307 := rosetta_g_miss_num_map(ddx_line_rec.service_number);
    p4_a308 := ddx_line_rec.service_reference_type_code;
    p4_a309 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_line_id);
    p4_a310 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_system_id);
    p4_a311 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_order_number);
    p4_a312 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_line_number);
    p4_a313 := ddx_line_rec.service_reference_order;
    p4_a314 := ddx_line_rec.service_reference_line;
    p4_a315 := ddx_line_rec.service_reference_system;
    p4_a316 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_shipment_number);
    p4_a317 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_option_number);
    p4_a318 := rosetta_g_miss_num_map(ddx_line_rec.service_line_index);
    p4_a319 := rosetta_g_miss_num_map(ddx_line_rec.line_set_id);
    p4_a320 := ddx_line_rec.split_by;
    p4_a321 := ddx_line_rec.split_action_code;
    p4_a322 := ddx_line_rec.shippable_flag;
    p4_a323 := ddx_line_rec.model_remnant_flag;
    p4_a324 := ddx_line_rec.flow_status_code;
    p4_a325 := ddx_line_rec.fulfilled_flag;
    p4_a326 := ddx_line_rec.fulfillment_method_code;
    p4_a327 := rosetta_g_miss_num_map(ddx_line_rec.revenue_amount);
    p4_a328 := rosetta_g_miss_num_map(ddx_line_rec.marketing_source_code_id);
    p4_a329 := ddx_line_rec.fulfillment_date;
    if ddx_line_rec.semi_processed_flag is null
      then p4_a330 := null;
    elsif ddx_line_rec.semi_processed_flag
      then p4_a330 := 1;
    else p4_a330 := 0;
    end if;
    p4_a331 := ddx_line_rec.upgraded_flag;
    p4_a332 := rosetta_g_miss_num_map(ddx_line_rec.lock_control);
    p4_a333 := ddx_line_rec.subinventory;
    p4_a334 := ddx_line_rec.split_from_line_ref;
    p4_a335 := ddx_line_rec.split_from_shipment_ref;
    p4_a336 := ddx_line_rec.ship_to_edi_location_code;
    p4_a337 := ddx_line_rec.bill_to_edi_location_code;
    p4_a338 := ddx_line_rec.ship_from_edi_location_code;
    p4_a339 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_address_id);
    p4_a340 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_address_id);
    p4_a341 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_address_id);
    p4_a342 := rosetta_g_miss_num_map(ddx_line_rec.invoice_address_id);
    p4_a343 := ddx_line_rec.ship_to_address_code;
    p4_a344 := rosetta_g_miss_num_map(ddx_line_rec.original_inventory_item_id);
    p4_a345 := ddx_line_rec.original_item_identifier_type;
    p4_a346 := rosetta_g_miss_num_map(ddx_line_rec.original_ordered_item_id);
    p4_a347 := ddx_line_rec.original_ordered_item;
    p4_a348 := ddx_line_rec.item_substitution_type_code;
    p4_a349 := rosetta_g_miss_num_map(ddx_line_rec.late_demand_penalty_factor);
    p4_a350 := ddx_line_rec.override_atp_date_code;
    p4_a351 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_id);
    p4_a352 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_id);
    p4_a353 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_id);
    p4_a354 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_duration);
    p4_a355 := rosetta_g_miss_num_map(ddx_line_rec.unit_cost);
    p4_a356 := ddx_line_rec.user_item_description;
    p4_a357 := ddx_line_rec.xml_transaction_type_code;
    p4_a358 := rosetta_g_miss_num_map(ddx_line_rec.item_relationship_type);
    p4_a359 := rosetta_g_miss_num_map(ddx_line_rec.blanket_number);
    p4_a360 := rosetta_g_miss_num_map(ddx_line_rec.blanket_line_number);
    p4_a361 := rosetta_g_miss_num_map(ddx_line_rec.blanket_version_number);
    p4_a362 := ddx_line_rec.cso_response_flag;
    p4_a363 := ddx_line_rec.firm_demand_flag;
    p4_a364 := ddx_line_rec.earliest_ship_date;
    p4_a365 := ddx_line_rec.transaction_phase_code;
    p4_a366 := rosetta_g_miss_num_map(ddx_line_rec.source_document_version_number);
    p4_a367 := rosetta_g_miss_num_map(ddx_line_rec.minisite_id);
    p4_a368 := ddx_line_rec.ib_owner;
    p4_a369 := ddx_line_rec.ib_installed_at_location;
    p4_a370 := ddx_line_rec.ib_current_location;
    p4_a371 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_id);
    p4_a372 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_contact_id);
    p4_a373 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_site_use_id);
    p4_a374 := ddx_line_rec.supplier_signature;
    p4_a375 := ddx_line_rec.supplier_signature_date;
    p4_a376 := ddx_line_rec.customer_signature;
    p4_a377 := ddx_line_rec.customer_signature_date;
    p4_a378 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_id);
    p4_a379 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_id);
    p4_a380 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_use_id);
    p4_a381 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_id);
    p4_a382 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_id);
    p4_a383 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_use_id);
    p4_a384 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_id);
    p4_a385 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_id);
    p4_a386 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_use_id);
    p4_a387 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_party_id);
    p4_a388 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_party_id);
    p4_a389 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_party_id);
    p4_a390 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_contact_id);
    p4_a391 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_contact_id);
    p4_a392 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_contact_id);
    p4_a393 := rosetta_g_miss_num_map(ddx_line_rec.retrobill_request_id);
    p4_a394 := rosetta_g_miss_num_map(ddx_line_rec.original_list_price);
    p4_a395 := rosetta_g_miss_num_map(ddx_line_rec.commitment_applied_amount);

    p5_a0 := ddx_line_val_rec.accounting_rule;
    p5_a1 := ddx_line_val_rec.agreement;
    p5_a2 := ddx_line_val_rec.commitment;
    p5_a3 := rosetta_g_miss_num_map(ddx_line_val_rec.commitment_applied_amount);
    p5_a4 := ddx_line_val_rec.deliver_to_address1;
    p5_a5 := ddx_line_val_rec.deliver_to_address2;
    p5_a6 := ddx_line_val_rec.deliver_to_address3;
    p5_a7 := ddx_line_val_rec.deliver_to_address4;
    p5_a8 := ddx_line_val_rec.deliver_to_contact;
    p5_a9 := ddx_line_val_rec.deliver_to_location;
    p5_a10 := ddx_line_val_rec.deliver_to_org;
    p5_a11 := ddx_line_val_rec.deliver_to_state;
    p5_a12 := ddx_line_val_rec.deliver_to_city;
    p5_a13 := ddx_line_val_rec.deliver_to_zip;
    p5_a14 := ddx_line_val_rec.deliver_to_country;
    p5_a15 := ddx_line_val_rec.deliver_to_county;
    p5_a16 := ddx_line_val_rec.deliver_to_province;
    p5_a17 := ddx_line_val_rec.demand_class;
    p5_a18 := ddx_line_val_rec.demand_bucket_type;
    p5_a19 := ddx_line_val_rec.fob_point;
    p5_a20 := ddx_line_val_rec.freight_terms;
    p5_a21 := ddx_line_val_rec.inventory_item;
    p5_a22 := ddx_line_val_rec.invoice_to_address1;
    p5_a23 := ddx_line_val_rec.invoice_to_address2;
    p5_a24 := ddx_line_val_rec.invoice_to_address3;
    p5_a25 := ddx_line_val_rec.invoice_to_address4;
    p5_a26 := ddx_line_val_rec.invoice_to_contact;
    p5_a27 := ddx_line_val_rec.invoice_to_location;
    p5_a28 := ddx_line_val_rec.invoice_to_org;
    p5_a29 := ddx_line_val_rec.invoice_to_state;
    p5_a30 := ddx_line_val_rec.invoice_to_city;
    p5_a31 := ddx_line_val_rec.invoice_to_zip;
    p5_a32 := ddx_line_val_rec.invoice_to_country;
    p5_a33 := ddx_line_val_rec.invoice_to_county;
    p5_a34 := ddx_line_val_rec.invoice_to_province;
    p5_a35 := ddx_line_val_rec.invoicing_rule;
    p5_a36 := ddx_line_val_rec.item_type;
    p5_a37 := ddx_line_val_rec.line_type;
    p5_a38 := ddx_line_val_rec.over_ship_reason;
    p5_a39 := ddx_line_val_rec.payment_term;
    p5_a40 := ddx_line_val_rec.price_list;
    p5_a41 := ddx_line_val_rec.project;
    p5_a42 := ddx_line_val_rec.return_reason;
    p5_a43 := ddx_line_val_rec.rla_schedule_type;
    p5_a44 := ddx_line_val_rec.salesrep;
    p5_a45 := ddx_line_val_rec.shipment_priority;
    p5_a46 := ddx_line_val_rec.ship_from_address1;
    p5_a47 := ddx_line_val_rec.ship_from_address2;
    p5_a48 := ddx_line_val_rec.ship_from_address3;
    p5_a49 := ddx_line_val_rec.ship_from_address4;
    p5_a50 := ddx_line_val_rec.ship_from_location;
    p5_a51 := ddx_line_val_rec.ship_from_city;
    p5_a52 := ddx_line_val_rec.ship_from_postal_code;
    p5_a53 := ddx_line_val_rec.ship_from_country;
    p5_a54 := ddx_line_val_rec.ship_from_region1;
    p5_a55 := ddx_line_val_rec.ship_from_region2;
    p5_a56 := ddx_line_val_rec.ship_from_region3;
    p5_a57 := ddx_line_val_rec.ship_from_org;
    p5_a58 := ddx_line_val_rec.ship_to_address1;
    p5_a59 := ddx_line_val_rec.ship_to_address2;
    p5_a60 := ddx_line_val_rec.ship_to_address3;
    p5_a61 := ddx_line_val_rec.ship_to_address4;
    p5_a62 := ddx_line_val_rec.ship_to_state;
    p5_a63 := ddx_line_val_rec.ship_to_country;
    p5_a64 := ddx_line_val_rec.ship_to_zip;
    p5_a65 := ddx_line_val_rec.ship_to_county;
    p5_a66 := ddx_line_val_rec.ship_to_province;
    p5_a67 := ddx_line_val_rec.ship_to_city;
    p5_a68 := ddx_line_val_rec.ship_to_contact;
    p5_a69 := ddx_line_val_rec.ship_to_contact_last_name;
    p5_a70 := ddx_line_val_rec.ship_to_contact_first_name;
    p5_a71 := ddx_line_val_rec.ship_to_location;
    p5_a72 := ddx_line_val_rec.ship_to_org;
    p5_a73 := ddx_line_val_rec.source_type;
    p5_a74 := ddx_line_val_rec.intermed_ship_to_address1;
    p5_a75 := ddx_line_val_rec.intermed_ship_to_address2;
    p5_a76 := ddx_line_val_rec.intermed_ship_to_address3;
    p5_a77 := ddx_line_val_rec.intermed_ship_to_address4;
    p5_a78 := ddx_line_val_rec.intermed_ship_to_contact;
    p5_a79 := ddx_line_val_rec.intermed_ship_to_location;
    p5_a80 := ddx_line_val_rec.intermed_ship_to_org;
    p5_a81 := ddx_line_val_rec.intermed_ship_to_state;
    p5_a82 := ddx_line_val_rec.intermed_ship_to_city;
    p5_a83 := ddx_line_val_rec.intermed_ship_to_zip;
    p5_a84 := ddx_line_val_rec.intermed_ship_to_country;
    p5_a85 := ddx_line_val_rec.intermed_ship_to_county;
    p5_a86 := ddx_line_val_rec.intermed_ship_to_province;
    p5_a87 := ddx_line_val_rec.sold_to_org;
    p5_a88 := ddx_line_val_rec.sold_from_org;
    p5_a89 := ddx_line_val_rec.task;
    p5_a90 := ddx_line_val_rec.tax_exempt;
    p5_a91 := ddx_line_val_rec.tax_exempt_reason;
    p5_a92 := ddx_line_val_rec.tax_point;
    p5_a93 := ddx_line_val_rec.veh_cus_item_cum_key;
    p5_a94 := ddx_line_val_rec.visible_demand;
    p5_a95 := ddx_line_val_rec.customer_payment_term;
    p5_a96 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_order_number);
    p5_a97 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_line_number);
    p5_a98 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_shipment_number);
    p5_a99 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_option_number);
    p5_a100 := ddx_line_val_rec.ref_invoice_number;
    p5_a101 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_invoice_line_number);
    p5_a102 := ddx_line_val_rec.credit_invoice_number;
    p5_a103 := ddx_line_val_rec.tax_group;
    p5_a104 := ddx_line_val_rec.status;
    p5_a105 := ddx_line_val_rec.freight_carrier;
    p5_a106 := ddx_line_val_rec.shipping_method;
    p5_a107 := ddx_line_val_rec.calculate_price_descr;
    p5_a108 := ddx_line_val_rec.ship_to_customer_name;
    p5_a109 := ddx_line_val_rec.invoice_to_customer_name;
    p5_a110 := ddx_line_val_rec.ship_to_customer_number;
    p5_a111 := ddx_line_val_rec.invoice_to_customer_number;
    p5_a112 := rosetta_g_miss_num_map(ddx_line_val_rec.ship_to_customer_id);
    p5_a113 := rosetta_g_miss_num_map(ddx_line_val_rec.invoice_to_customer_id);
    p5_a114 := rosetta_g_miss_num_map(ddx_line_val_rec.deliver_to_customer_id);
    p5_a115 := ddx_line_val_rec.deliver_to_customer_number;
    p5_a116 := ddx_line_val_rec.deliver_to_customer_name;
    p5_a117 := ddx_line_val_rec.original_ordered_item;
    p5_a118 := ddx_line_val_rec.original_inventory_item;
    p5_a119 := ddx_line_val_rec.original_item_identifier_type;
    p5_a120 := ddx_line_val_rec.deliver_to_customer_number_oi;
    p5_a121 := ddx_line_val_rec.deliver_to_customer_name_oi;
    p5_a122 := ddx_line_val_rec.ship_to_customer_number_oi;
    p5_a123 := ddx_line_val_rec.ship_to_customer_name_oi;
    p5_a124 := ddx_line_val_rec.invoice_to_customer_number_oi;
    p5_a125 := ddx_line_val_rec.invoice_to_customer_name_oi;
    p5_a126 := ddx_line_val_rec.item_relationship_type_dsp;
    p5_a127 := ddx_line_val_rec.transaction_phase;
    p5_a128 := ddx_line_val_rec.end_customer_name;
    p5_a129 := ddx_line_val_rec.end_customer_number;
    p5_a130 := ddx_line_val_rec.end_customer_contact;
    p5_a131 := ddx_line_val_rec.end_cust_contact_last_name;
    p5_a132 := ddx_line_val_rec.end_cust_contact_first_name;
    p5_a133 := ddx_line_val_rec.end_customer_site_address1;
    p5_a134 := ddx_line_val_rec.end_customer_site_address2;
    p5_a135 := ddx_line_val_rec.end_customer_site_address3;
    p5_a136 := ddx_line_val_rec.end_customer_site_address4;
    p5_a137 := ddx_line_val_rec.end_customer_site_location;
    p5_a138 := ddx_line_val_rec.end_customer_site_state;
    p5_a139 := ddx_line_val_rec.end_customer_site_country;
    p5_a140 := ddx_line_val_rec.end_customer_site_zip;
    p5_a141 := ddx_line_val_rec.end_customer_site_county;
    p5_a142 := ddx_line_val_rec.end_customer_site_province;
    p5_a143 := ddx_line_val_rec.end_customer_site_city;
    p5_a144 := ddx_line_val_rec.end_customer_site_postal_code;
    p5_a145 := ddx_line_val_rec.blanket_agreement_name;

    p6_a0 := rosetta_g_miss_num_map(ddp_header_rec.accounting_rule_id);
    p6_a1 := rosetta_g_miss_num_map(ddp_header_rec.agreement_id);
    p6_a2 := ddp_header_rec.attribute1;
    p6_a3 := ddp_header_rec.attribute10;
    p6_a4 := ddp_header_rec.attribute11;
    p6_a5 := ddp_header_rec.attribute12;
    p6_a6 := ddp_header_rec.attribute13;
    p6_a7 := ddp_header_rec.attribute14;
    p6_a8 := ddp_header_rec.attribute15;
    p6_a9 := ddp_header_rec.attribute16;
    p6_a10 := ddp_header_rec.attribute17;
    p6_a11 := ddp_header_rec.attribute18;
    p6_a12 := ddp_header_rec.attribute19;
    p6_a13 := ddp_header_rec.attribute2;
    p6_a14 := ddp_header_rec.attribute20;
    p6_a15 := ddp_header_rec.attribute3;
    p6_a16 := ddp_header_rec.attribute4;
    p6_a17 := ddp_header_rec.attribute5;
    p6_a18 := ddp_header_rec.attribute6;
    p6_a19 := ddp_header_rec.attribute7;
    p6_a20 := ddp_header_rec.attribute8;
    p6_a21 := ddp_header_rec.attribute9;
    p6_a22 := ddp_header_rec.booked_flag;
    p6_a23 := ddp_header_rec.cancelled_flag;
    p6_a24 := ddp_header_rec.context;
    p6_a25 := rosetta_g_miss_num_map(ddp_header_rec.conversion_rate);
    p6_a26 := ddp_header_rec.conversion_rate_date;
    p6_a27 := ddp_header_rec.conversion_type_code;
    p6_a28 := ddp_header_rec.customer_preference_set_code;
    p6_a29 := rosetta_g_miss_num_map(ddp_header_rec.created_by);
    p6_a30 := ddp_header_rec.creation_date;
    p6_a31 := ddp_header_rec.cust_po_number;
    p6_a32 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_contact_id);
    p6_a33 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_org_id);
    p6_a34 := ddp_header_rec.demand_class_code;
    p6_a35 := rosetta_g_miss_num_map(ddp_header_rec.earliest_schedule_limit);
    p6_a36 := ddp_header_rec.expiration_date;
    p6_a37 := ddp_header_rec.fob_point_code;
    p6_a38 := ddp_header_rec.freight_carrier_code;
    p6_a39 := ddp_header_rec.freight_terms_code;
    p6_a40 := ddp_header_rec.global_attribute1;
    p6_a41 := ddp_header_rec.global_attribute10;
    p6_a42 := ddp_header_rec.global_attribute11;
    p6_a43 := ddp_header_rec.global_attribute12;
    p6_a44 := ddp_header_rec.global_attribute13;
    p6_a45 := ddp_header_rec.global_attribute14;
    p6_a46 := ddp_header_rec.global_attribute15;
    p6_a47 := ddp_header_rec.global_attribute16;
    p6_a48 := ddp_header_rec.global_attribute17;
    p6_a49 := ddp_header_rec.global_attribute18;
    p6_a50 := ddp_header_rec.global_attribute19;
    p6_a51 := ddp_header_rec.global_attribute2;
    p6_a52 := ddp_header_rec.global_attribute20;
    p6_a53 := ddp_header_rec.global_attribute3;
    p6_a54 := ddp_header_rec.global_attribute4;
    p6_a55 := ddp_header_rec.global_attribute5;
    p6_a56 := ddp_header_rec.global_attribute6;
    p6_a57 := ddp_header_rec.global_attribute7;
    p6_a58 := ddp_header_rec.global_attribute8;
    p6_a59 := ddp_header_rec.global_attribute9;
    p6_a60 := ddp_header_rec.global_attribute_category;
    p6_a61 := ddp_header_rec.tp_context;
    p6_a62 := ddp_header_rec.tp_attribute1;
    p6_a63 := ddp_header_rec.tp_attribute2;
    p6_a64 := ddp_header_rec.tp_attribute3;
    p6_a65 := ddp_header_rec.tp_attribute4;
    p6_a66 := ddp_header_rec.tp_attribute5;
    p6_a67 := ddp_header_rec.tp_attribute6;
    p6_a68 := ddp_header_rec.tp_attribute7;
    p6_a69 := ddp_header_rec.tp_attribute8;
    p6_a70 := ddp_header_rec.tp_attribute9;
    p6_a71 := ddp_header_rec.tp_attribute10;
    p6_a72 := ddp_header_rec.tp_attribute11;
    p6_a73 := ddp_header_rec.tp_attribute12;
    p6_a74 := ddp_header_rec.tp_attribute13;
    p6_a75 := ddp_header_rec.tp_attribute14;
    p6_a76 := ddp_header_rec.tp_attribute15;
    p6_a77 := rosetta_g_miss_num_map(ddp_header_rec.header_id);
    p6_a78 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_contact_id);
    p6_a79 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_org_id);
    p6_a80 := rosetta_g_miss_num_map(ddp_header_rec.invoicing_rule_id);
    p6_a81 := rosetta_g_miss_num_map(ddp_header_rec.last_updated_by);
    p6_a82 := ddp_header_rec.last_update_date;
    p6_a83 := rosetta_g_miss_num_map(ddp_header_rec.last_update_login);
    p6_a84 := rosetta_g_miss_num_map(ddp_header_rec.latest_schedule_limit);
    p6_a85 := ddp_header_rec.open_flag;
    p6_a86 := ddp_header_rec.order_category_code;
    p6_a87 := ddp_header_rec.ordered_date;
    p6_a88 := ddp_header_rec.order_date_type_code;
    p6_a89 := rosetta_g_miss_num_map(ddp_header_rec.order_number);
    p6_a90 := rosetta_g_miss_num_map(ddp_header_rec.order_source_id);
    p6_a91 := rosetta_g_miss_num_map(ddp_header_rec.order_type_id);
    p6_a92 := rosetta_g_miss_num_map(ddp_header_rec.org_id);
    p6_a93 := ddp_header_rec.orig_sys_document_ref;
    p6_a94 := ddp_header_rec.partial_shipments_allowed;
    p6_a95 := rosetta_g_miss_num_map(ddp_header_rec.payment_term_id);
    p6_a96 := rosetta_g_miss_num_map(ddp_header_rec.price_list_id);
    p6_a97 := ddp_header_rec.price_request_code;
    p6_a98 := ddp_header_rec.pricing_date;
    p6_a99 := rosetta_g_miss_num_map(ddp_header_rec.program_application_id);
    p6_a100 := rosetta_g_miss_num_map(ddp_header_rec.program_id);
    p6_a101 := ddp_header_rec.program_update_date;
    p6_a102 := ddp_header_rec.request_date;
    p6_a103 := rosetta_g_miss_num_map(ddp_header_rec.request_id);
    p6_a104 := ddp_header_rec.return_reason_code;
    p6_a105 := rosetta_g_miss_num_map(ddp_header_rec.salesrep_id);
    p6_a106 := ddp_header_rec.sales_channel_code;
    p6_a107 := ddp_header_rec.shipment_priority_code;
    p6_a108 := ddp_header_rec.shipping_method_code;
    p6_a109 := rosetta_g_miss_num_map(ddp_header_rec.ship_from_org_id);
    p6_a110 := rosetta_g_miss_num_map(ddp_header_rec.ship_tolerance_above);
    p6_a111 := rosetta_g_miss_num_map(ddp_header_rec.ship_tolerance_below);
    p6_a112 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_contact_id);
    p6_a113 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_org_id);
    p6_a114 := rosetta_g_miss_num_map(ddp_header_rec.sold_from_org_id);
    p6_a115 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_contact_id);
    p6_a116 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_org_id);
    p6_a117 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_phone_id);
    p6_a118 := rosetta_g_miss_num_map(ddp_header_rec.source_document_id);
    p6_a119 := rosetta_g_miss_num_map(ddp_header_rec.source_document_type_id);
    p6_a120 := ddp_header_rec.tax_exempt_flag;
    p6_a121 := ddp_header_rec.tax_exempt_number;
    p6_a122 := ddp_header_rec.tax_exempt_reason_code;
    p6_a123 := ddp_header_rec.tax_point_code;
    p6_a124 := ddp_header_rec.transactional_curr_code;
    p6_a125 := rosetta_g_miss_num_map(ddp_header_rec.version_number);
    p6_a126 := ddp_header_rec.return_status;
    p6_a127 := ddp_header_rec.db_flag;
    p6_a128 := ddp_header_rec.operation;
    p6_a129 := ddp_header_rec.first_ack_code;
    p6_a130 := ddp_header_rec.first_ack_date;
    p6_a131 := ddp_header_rec.last_ack_code;
    p6_a132 := ddp_header_rec.last_ack_date;
    p6_a133 := ddp_header_rec.change_reason;
    p6_a134 := ddp_header_rec.change_comments;
    p6_a135 := ddp_header_rec.change_sequence;
    p6_a136 := ddp_header_rec.change_request_code;
    p6_a137 := ddp_header_rec.ready_flag;
    p6_a138 := ddp_header_rec.status_flag;
    p6_a139 := ddp_header_rec.force_apply_flag;
    p6_a140 := ddp_header_rec.drop_ship_flag;
    p6_a141 := rosetta_g_miss_num_map(ddp_header_rec.customer_payment_term_id);
    p6_a142 := ddp_header_rec.payment_type_code;
    p6_a143 := rosetta_g_miss_num_map(ddp_header_rec.payment_amount);
    p6_a144 := ddp_header_rec.check_number;
    p6_a145 := ddp_header_rec.credit_card_code;
    p6_a146 := ddp_header_rec.credit_card_holder_name;
    p6_a147 := ddp_header_rec.credit_card_number;
    p6_a148 := ddp_header_rec.credit_card_expiration_date;
    p6_a149 := ddp_header_rec.credit_card_approval_code;
    p6_a150 := ddp_header_rec.credit_card_approval_date;
    p6_a151 := ddp_header_rec.shipping_instructions;
    p6_a152 := ddp_header_rec.packing_instructions;
    p6_a153 := ddp_header_rec.flow_status_code;
    p6_a154 := ddp_header_rec.booked_date;
    p6_a155 := rosetta_g_miss_num_map(ddp_header_rec.marketing_source_code_id);
    p6_a156 := ddp_header_rec.upgraded_flag;
    p6_a157 := rosetta_g_miss_num_map(ddp_header_rec.lock_control);
    p6_a158 := ddp_header_rec.ship_to_edi_location_code;
    p6_a159 := ddp_header_rec.sold_to_edi_location_code;
    p6_a160 := ddp_header_rec.bill_to_edi_location_code;
    p6_a161 := ddp_header_rec.ship_from_edi_location_code;
    p6_a162 := rosetta_g_miss_num_map(ddp_header_rec.ship_from_address_id);
    p6_a163 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_address_id);
    p6_a164 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_address_id);
    p6_a165 := rosetta_g_miss_num_map(ddp_header_rec.invoice_address_id);
    p6_a166 := ddp_header_rec.ship_to_address_code;
    p6_a167 := rosetta_g_miss_num_map(ddp_header_rec.xml_message_id);
    p6_a168 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_customer_id);
    p6_a169 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_customer_id);
    p6_a170 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_customer_id);
    p6_a171 := rosetta_g_miss_num_map(ddp_header_rec.accounting_rule_duration);
    p6_a172 := ddp_header_rec.xml_transaction_type_code;
    p6_a173 := rosetta_g_miss_num_map(ddp_header_rec.blanket_number);
    p6_a174 := ddp_header_rec.line_set_name;
    p6_a175 := ddp_header_rec.fulfillment_set_name;
    p6_a176 := ddp_header_rec.default_fulfillment_set;
    p6_a177 := ddp_header_rec.quote_date;
    p6_a178 := rosetta_g_miss_num_map(ddp_header_rec.quote_number);
    p6_a179 := ddp_header_rec.sales_document_name;
    p6_a180 := ddp_header_rec.transaction_phase_code;
    p6_a181 := ddp_header_rec.user_status_code;
    p6_a182 := ddp_header_rec.draft_submitted_flag;
    p6_a183 := rosetta_g_miss_num_map(ddp_header_rec.source_document_version_number);
    p6_a184 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_site_use_id);
    p6_a185 := rosetta_g_miss_num_map(ddp_header_rec.minisite_id);
    p6_a186 := ddp_header_rec.ib_owner;
    p6_a187 := ddp_header_rec.ib_installed_at_location;
    p6_a188 := ddp_header_rec.ib_current_location;
    p6_a189 := rosetta_g_miss_num_map(ddp_header_rec.end_customer_id);
    p6_a190 := rosetta_g_miss_num_map(ddp_header_rec.end_customer_contact_id);
    p6_a191 := rosetta_g_miss_num_map(ddp_header_rec.end_customer_site_use_id);
    p6_a192 := ddp_header_rec.supplier_signature;
    p6_a193 := ddp_header_rec.supplier_signature_date;
    p6_a194 := ddp_header_rec.customer_signature;
    p6_a195 := ddp_header_rec.customer_signature_date;
    p6_a196 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_party_id);
    p6_a197 := rosetta_g_miss_num_map(ddp_header_rec.sold_to_org_contact_id);
    p6_a198 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_party_id);
    p6_a199 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_party_site_id);
    p6_a200 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_party_site_use_id);
    p6_a201 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_party_id);
    p6_a202 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_party_site_id);
    p6_a203 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_party_site_use_id);
    p6_a204 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_party_id);
    p6_a205 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_party_site_id);
    p6_a206 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_party_site_use_id);
    p6_a207 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_customer_party_id);
    p6_a208 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_customer_party_id);
    p6_a209 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_customer_party_id);
    p6_a210 := rosetta_g_miss_num_map(ddp_header_rec.ship_to_org_contact_id);
    p6_a211 := rosetta_g_miss_num_map(ddp_header_rec.deliver_to_org_contact_id);
    p6_a212 := rosetta_g_miss_num_map(ddp_header_rec.invoice_to_org_contact_id);
    p6_a213 := rosetta_g_miss_num_map(ddp_header_rec.contract_template_id);
    p6_a214 := ddp_header_rec.contract_source_doc_type_code;
    p6_a215 := rosetta_g_miss_num_map(ddp_header_rec.contract_source_document_id);
  end;

  procedure change_attribute(x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_msg_count out NOCOPY /* file.sql.39 change */  NUMBER
    , x_msg_data out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p_line_id  NUMBER
    , p_attr_id  NUMBER
    , p_attr_value  VARCHAR2
    , p_attr_id_tbl JTF_NUMBER_TABLE
    , p_attr_value_tbl JTF_VARCHAR2_TABLE_2000
    , p_reason  VARCHAR2
    , p_comments  VARCHAR2
    , p10_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a1 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a2 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a3 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a4 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a5 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p10_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a27 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a30 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a31 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a34 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a36 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a37 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a38 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a39 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a41 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a42 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a43 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a47 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a51 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a52 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a53 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a57 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a59 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a63 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a64 in out NOCOPY /* file.sql.39 change */  NUMBER
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
    , p10_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a86 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a100 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a101 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a102 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a134 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a135 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a136 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a138 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a139 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a140 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a143 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a144 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a145 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a146 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a147 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a148 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a149 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a150 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a151 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a153 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a154 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a156 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a160 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a161 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a163 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a164 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a167 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a168 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a169 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a177 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a178 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a183 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a184 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a185 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a186 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a187 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a191 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a192 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a195 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a198 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a199 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a202 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a203 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a204 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a205 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a206 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a207 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a208 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a209 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a210 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a211 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a212 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a213 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a215 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a216 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a217 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a218 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a219 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a220 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a221 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a222 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a223 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a224 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a225 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a226 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a227 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a228 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a229 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a230 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a231 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a232 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a233 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a234 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a235 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a236 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a237 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a238 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a239 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a240 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a241 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a242 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a243 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a244 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a245 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a246 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a247 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a248 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a249 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a250 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a251 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a252 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a253 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a254 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a255 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a256 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a257 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a258 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a259 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a260 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a261 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a262 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a263 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a264 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a265 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a266 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a267 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a268 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a269 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a270 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a271 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a272 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a273 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a274 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a275 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a276 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a277 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a278 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a279 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a280 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a281 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a282 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a283 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a284 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a285 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a286 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a287 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a288 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a289 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a290 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a291 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a292 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a293 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a294 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a295 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a296 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a297 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a298 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a299 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a300 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a301 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a302 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a303 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a304 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a305 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a306 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a307 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a308 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a309 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a310 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a311 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a312 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a313 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a314 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a315 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a316 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a317 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a318 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a319 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a320 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a321 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a322 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a323 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a324 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a325 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a326 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a327 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a328 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a329 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a330 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a331 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a332 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a333 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a334 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a335 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a336 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a337 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a338 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a339 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a340 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a341 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a342 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a343 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a344 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a345 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a346 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a347 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a348 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a349 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a350 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a351 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a352 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a353 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a354 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a355 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a356 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a357 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a358 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a359 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a360 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a361 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a362 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a363 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a364 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a365 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a366 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a367 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a368 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a369 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a370 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a371 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a372 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a373 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a374 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a375 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a376 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p10_a377 in out NOCOPY /* file.sql.39 change */  DATE
    , p10_a378 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a379 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a380 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a381 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a382 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a383 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a384 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a385 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a386 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a387 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a388 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a389 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a390 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a391 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a392 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a393 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a394 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p10_a395 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a1 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a2 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a3 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a4 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a5 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a27 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a30 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a31 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a34 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a36 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a37 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a38 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a39 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a41 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a42 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a43 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a47 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a51 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a52 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a53 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a57 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a59 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a63 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a64 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a86 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a96 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a98 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a99 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a100 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a101 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a102 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a112 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a113 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a114 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a134 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a135 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a136 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a138 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a139 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a140 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a143 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a144 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a145 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a146 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a147 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a148 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a149 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a150 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a151 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a153 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a154 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a156 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a160 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a161 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a163 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a164 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a167 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a168 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a169 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a177 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a178 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a179 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a180 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a181 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a182 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a183 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a184 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a185 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a186 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a187 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a188 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a189 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a190 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a191 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a192 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a193 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a194 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a195 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a196 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a197 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a198 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a199 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a200 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a201 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a202 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a203 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a204 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a205 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a206 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a207 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a208 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a209 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a210 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a211 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a212 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a213 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a214 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a215 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a216 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a217 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a218 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a219 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a220 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a221 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a222 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a223 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a224 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a225 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a226 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a227 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a228 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a229 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a230 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a231 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a232 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a233 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a234 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a235 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a236 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a237 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a238 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a239 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a240 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a241 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a242 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a243 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a244 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a245 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a246 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a247 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a248 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a249 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a250 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a251 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a252 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a253 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a254 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a255 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a256 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a257 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a258 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a259 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a260 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a261 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a262 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a263 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a264 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a265 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a266 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a267 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a268 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a269 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a270 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a271 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a272 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a273 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a274 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a275 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a276 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a277 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a278 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a279 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a280 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a281 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a282 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a283 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a284 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a285 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a286 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a287 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a288 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a289 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a290 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a291 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a292 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a293 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a294 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a295 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a296 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a297 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a298 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a299 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a300 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a301 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a302 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a303 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a304 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a305 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a306 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a307 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a308 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a309 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a310 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a311 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a312 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a313 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a314 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a315 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a316 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a317 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a318 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a319 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a320 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a321 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a322 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a323 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a324 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a325 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a326 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a327 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a328 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a329 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a330 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a331 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a332 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a333 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a334 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a335 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a336 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a337 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a338 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a339 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a340 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a341 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a342 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a343 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a344 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a345 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a346 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a347 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a348 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a349 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a350 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a351 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a352 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a353 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a354 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a355 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a356 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a357 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a358 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a359 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a360 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a361 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a362 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a363 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a364 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a365 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a366 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a367 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a368 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a369 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a370 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a371 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a372 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a373 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a374 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a375 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a376 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p11_a377 in out NOCOPY /* file.sql.39 change */  DATE
    , p11_a378 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a379 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a380 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a381 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a382 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a383 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a384 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a385 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a386 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a387 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a388 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a389 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a390 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a391 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a392 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a393 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a394 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p11_a395 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a0 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a1 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a3 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a25 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a26 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a29 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a30 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a32 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a33 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a35 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a36 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p12_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p12_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR
    , p12_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a77 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a78 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a79 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a80 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a81 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a82 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a83 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a84 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a87 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a89 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a90 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a91 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a92 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a95 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a97 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a98 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a100 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a101 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a102 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a103 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a105 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a109 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a110 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a111 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p12_a115 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a116 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a117 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a118 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a119 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a125 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a130 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a132 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a141 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a143 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p12_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_attr_id_tbl oe_oe_html_line.number_tbl_type;
    ddp_attr_value_tbl oe_oe_html_line.varchar2_tbl_type;
    ddx_line_rec oe_order_pub.line_rec_type;
    ddx_old_line_rec oe_order_pub.line_rec_type;
    ddx_line_val_rec oe_order_pub.line_val_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    oe_oe_html_line_w.rosetta_table_copy_in_p0(ddp_attr_id_tbl, p_attr_id_tbl);

    oe_oe_html_line_w.rosetta_table_copy_in_p1(ddp_attr_value_tbl, p_attr_value_tbl);



    ddx_line_rec.accounting_rule_id := rosetta_g_miss_num_map(p10_a0);
    ddx_line_rec.actual_arrival_date := rosetta_g_miss_date_in_map(p10_a1);
    ddx_line_rec.actual_shipment_date := rosetta_g_miss_date_in_map(p10_a2);
    ddx_line_rec.agreement_id := rosetta_g_miss_num_map(p10_a3);
    ddx_line_rec.arrival_set_id := rosetta_g_miss_num_map(p10_a4);
    ddx_line_rec.ato_line_id := rosetta_g_miss_num_map(p10_a5);
    ddx_line_rec.attribute1 := p10_a6;
    ddx_line_rec.attribute10 := p10_a7;
    ddx_line_rec.attribute11 := p10_a8;
    ddx_line_rec.attribute12 := p10_a9;
    ddx_line_rec.attribute13 := p10_a10;
    ddx_line_rec.attribute14 := p10_a11;
    ddx_line_rec.attribute15 := p10_a12;
    ddx_line_rec.attribute16 := p10_a13;
    ddx_line_rec.attribute17 := p10_a14;
    ddx_line_rec.attribute18 := p10_a15;
    ddx_line_rec.attribute19 := p10_a16;
    ddx_line_rec.attribute2 := p10_a17;
    ddx_line_rec.attribute20 := p10_a18;
    ddx_line_rec.attribute3 := p10_a19;
    ddx_line_rec.attribute4 := p10_a20;
    ddx_line_rec.attribute5 := p10_a21;
    ddx_line_rec.attribute6 := p10_a22;
    ddx_line_rec.attribute7 := p10_a23;
    ddx_line_rec.attribute8 := p10_a24;
    ddx_line_rec.attribute9 := p10_a25;
    ddx_line_rec.authorized_to_ship_flag := p10_a26;
    ddx_line_rec.auto_selected_quantity := rosetta_g_miss_num_map(p10_a27);
    ddx_line_rec.booked_flag := p10_a28;
    ddx_line_rec.cancelled_flag := p10_a29;
    ddx_line_rec.cancelled_quantity := rosetta_g_miss_num_map(p10_a30);
    ddx_line_rec.cancelled_quantity2 := rosetta_g_miss_num_map(p10_a31);
    ddx_line_rec.commitment_id := rosetta_g_miss_num_map(p10_a32);
    ddx_line_rec.component_code := p10_a33;
    ddx_line_rec.component_number := rosetta_g_miss_num_map(p10_a34);
    ddx_line_rec.component_sequence_id := rosetta_g_miss_num_map(p10_a35);
    ddx_line_rec.config_header_id := rosetta_g_miss_num_map(p10_a36);
    ddx_line_rec.config_rev_nbr := rosetta_g_miss_num_map(p10_a37);
    ddx_line_rec.config_display_sequence := rosetta_g_miss_num_map(p10_a38);
    ddx_line_rec.configuration_id := rosetta_g_miss_num_map(p10_a39);
    ddx_line_rec.context := p10_a40;
    ddx_line_rec.created_by := rosetta_g_miss_num_map(p10_a41);
    ddx_line_rec.creation_date := rosetta_g_miss_date_in_map(p10_a42);
    ddx_line_rec.credit_invoice_line_id := rosetta_g_miss_num_map(p10_a43);
    ddx_line_rec.customer_dock_code := p10_a44;
    ddx_line_rec.customer_job := p10_a45;
    ddx_line_rec.customer_production_line := p10_a46;
    ddx_line_rec.customer_trx_line_id := rosetta_g_miss_num_map(p10_a47);
    ddx_line_rec.cust_model_serial_number := p10_a48;
    ddx_line_rec.cust_po_number := p10_a49;
    ddx_line_rec.cust_production_seq_num := p10_a50;
    ddx_line_rec.delivery_lead_time := rosetta_g_miss_num_map(p10_a51);
    ddx_line_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p10_a52);
    ddx_line_rec.deliver_to_org_id := rosetta_g_miss_num_map(p10_a53);
    ddx_line_rec.demand_bucket_type_code := p10_a54;
    ddx_line_rec.demand_class_code := p10_a55;
    ddx_line_rec.dep_plan_required_flag := p10_a56;
    ddx_line_rec.earliest_acceptable_date := rosetta_g_miss_date_in_map(p10_a57);
    ddx_line_rec.end_item_unit_number := p10_a58;
    ddx_line_rec.explosion_date := rosetta_g_miss_date_in_map(p10_a59);
    ddx_line_rec.fob_point_code := p10_a60;
    ddx_line_rec.freight_carrier_code := p10_a61;
    ddx_line_rec.freight_terms_code := p10_a62;
    ddx_line_rec.fulfilled_quantity := rosetta_g_miss_num_map(p10_a63);
    ddx_line_rec.fulfilled_quantity2 := rosetta_g_miss_num_map(p10_a64);
    ddx_line_rec.global_attribute1 := p10_a65;
    ddx_line_rec.global_attribute10 := p10_a66;
    ddx_line_rec.global_attribute11 := p10_a67;
    ddx_line_rec.global_attribute12 := p10_a68;
    ddx_line_rec.global_attribute13 := p10_a69;
    ddx_line_rec.global_attribute14 := p10_a70;
    ddx_line_rec.global_attribute15 := p10_a71;
    ddx_line_rec.global_attribute16 := p10_a72;
    ddx_line_rec.global_attribute17 := p10_a73;
    ddx_line_rec.global_attribute18 := p10_a74;
    ddx_line_rec.global_attribute19 := p10_a75;
    ddx_line_rec.global_attribute2 := p10_a76;
    ddx_line_rec.global_attribute20 := p10_a77;
    ddx_line_rec.global_attribute3 := p10_a78;
    ddx_line_rec.global_attribute4 := p10_a79;
    ddx_line_rec.global_attribute5 := p10_a80;
    ddx_line_rec.global_attribute6 := p10_a81;
    ddx_line_rec.global_attribute7 := p10_a82;
    ddx_line_rec.global_attribute8 := p10_a83;
    ddx_line_rec.global_attribute9 := p10_a84;
    ddx_line_rec.global_attribute_category := p10_a85;
    ddx_line_rec.header_id := rosetta_g_miss_num_map(p10_a86);
    ddx_line_rec.industry_attribute1 := p10_a87;
    ddx_line_rec.industry_attribute10 := p10_a88;
    ddx_line_rec.industry_attribute11 := p10_a89;
    ddx_line_rec.industry_attribute12 := p10_a90;
    ddx_line_rec.industry_attribute13 := p10_a91;
    ddx_line_rec.industry_attribute14 := p10_a92;
    ddx_line_rec.industry_attribute15 := p10_a93;
    ddx_line_rec.industry_attribute16 := p10_a94;
    ddx_line_rec.industry_attribute17 := p10_a95;
    ddx_line_rec.industry_attribute18 := p10_a96;
    ddx_line_rec.industry_attribute19 := p10_a97;
    ddx_line_rec.industry_attribute20 := p10_a98;
    ddx_line_rec.industry_attribute21 := p10_a99;
    ddx_line_rec.industry_attribute22 := p10_a100;
    ddx_line_rec.industry_attribute23 := p10_a101;
    ddx_line_rec.industry_attribute24 := p10_a102;
    ddx_line_rec.industry_attribute25 := p10_a103;
    ddx_line_rec.industry_attribute26 := p10_a104;
    ddx_line_rec.industry_attribute27 := p10_a105;
    ddx_line_rec.industry_attribute28 := p10_a106;
    ddx_line_rec.industry_attribute29 := p10_a107;
    ddx_line_rec.industry_attribute30 := p10_a108;
    ddx_line_rec.industry_attribute2 := p10_a109;
    ddx_line_rec.industry_attribute3 := p10_a110;
    ddx_line_rec.industry_attribute4 := p10_a111;
    ddx_line_rec.industry_attribute5 := p10_a112;
    ddx_line_rec.industry_attribute6 := p10_a113;
    ddx_line_rec.industry_attribute7 := p10_a114;
    ddx_line_rec.industry_attribute8 := p10_a115;
    ddx_line_rec.industry_attribute9 := p10_a116;
    ddx_line_rec.industry_context := p10_a117;
    ddx_line_rec.tp_context := p10_a118;
    ddx_line_rec.tp_attribute1 := p10_a119;
    ddx_line_rec.tp_attribute2 := p10_a120;
    ddx_line_rec.tp_attribute3 := p10_a121;
    ddx_line_rec.tp_attribute4 := p10_a122;
    ddx_line_rec.tp_attribute5 := p10_a123;
    ddx_line_rec.tp_attribute6 := p10_a124;
    ddx_line_rec.tp_attribute7 := p10_a125;
    ddx_line_rec.tp_attribute8 := p10_a126;
    ddx_line_rec.tp_attribute9 := p10_a127;
    ddx_line_rec.tp_attribute10 := p10_a128;
    ddx_line_rec.tp_attribute11 := p10_a129;
    ddx_line_rec.tp_attribute12 := p10_a130;
    ddx_line_rec.tp_attribute13 := p10_a131;
    ddx_line_rec.tp_attribute14 := p10_a132;
    ddx_line_rec.tp_attribute15 := p10_a133;
    ddx_line_rec.intermed_ship_to_org_id := rosetta_g_miss_num_map(p10_a134);
    ddx_line_rec.intermed_ship_to_contact_id := rosetta_g_miss_num_map(p10_a135);
    ddx_line_rec.inventory_item_id := rosetta_g_miss_num_map(p10_a136);
    ddx_line_rec.invoice_interface_status_code := p10_a137;
    ddx_line_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p10_a138);
    ddx_line_rec.invoice_to_org_id := rosetta_g_miss_num_map(p10_a139);
    ddx_line_rec.invoicing_rule_id := rosetta_g_miss_num_map(p10_a140);
    ddx_line_rec.ordered_item := p10_a141;
    ddx_line_rec.item_revision := p10_a142;
    ddx_line_rec.item_type_code := p10_a143;
    ddx_line_rec.last_updated_by := rosetta_g_miss_num_map(p10_a144);
    ddx_line_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a145);
    ddx_line_rec.last_update_login := rosetta_g_miss_num_map(p10_a146);
    ddx_line_rec.latest_acceptable_date := rosetta_g_miss_date_in_map(p10_a147);
    ddx_line_rec.line_category_code := p10_a148;
    ddx_line_rec.line_id := rosetta_g_miss_num_map(p10_a149);
    ddx_line_rec.line_number := rosetta_g_miss_num_map(p10_a150);
    ddx_line_rec.line_type_id := rosetta_g_miss_num_map(p10_a151);
    ddx_line_rec.link_to_line_ref := p10_a152;
    ddx_line_rec.link_to_line_id := rosetta_g_miss_num_map(p10_a153);
    ddx_line_rec.link_to_line_index := rosetta_g_miss_num_map(p10_a154);
    ddx_line_rec.model_group_number := rosetta_g_miss_num_map(p10_a155);
    ddx_line_rec.mfg_component_sequence_id := rosetta_g_miss_num_map(p10_a156);
    ddx_line_rec.mfg_lead_time := rosetta_g_miss_num_map(p10_a157);
    ddx_line_rec.open_flag := p10_a158;
    ddx_line_rec.option_flag := p10_a159;
    ddx_line_rec.option_number := rosetta_g_miss_num_map(p10_a160);
    ddx_line_rec.ordered_quantity := rosetta_g_miss_num_map(p10_a161);
    ddx_line_rec.ordered_quantity2 := rosetta_g_miss_num_map(p10_a162);
    ddx_line_rec.order_quantity_uom := p10_a163;
    ddx_line_rec.ordered_quantity_uom2 := p10_a164;
    ddx_line_rec.org_id := rosetta_g_miss_num_map(p10_a165);
    ddx_line_rec.orig_sys_document_ref := p10_a166;
    ddx_line_rec.orig_sys_line_ref := p10_a167;
    ddx_line_rec.over_ship_reason_code := p10_a168;
    ddx_line_rec.over_ship_resolved_flag := p10_a169;
    ddx_line_rec.payment_term_id := rosetta_g_miss_num_map(p10_a170);
    ddx_line_rec.planning_priority := rosetta_g_miss_num_map(p10_a171);
    ddx_line_rec.preferred_grade := p10_a172;
    ddx_line_rec.price_list_id := rosetta_g_miss_num_map(p10_a173);
    ddx_line_rec.price_request_code := p10_a174;
    ddx_line_rec.pricing_attribute1 := p10_a175;
    ddx_line_rec.pricing_attribute10 := p10_a176;
    ddx_line_rec.pricing_attribute2 := p10_a177;
    ddx_line_rec.pricing_attribute3 := p10_a178;
    ddx_line_rec.pricing_attribute4 := p10_a179;
    ddx_line_rec.pricing_attribute5 := p10_a180;
    ddx_line_rec.pricing_attribute6 := p10_a181;
    ddx_line_rec.pricing_attribute7 := p10_a182;
    ddx_line_rec.pricing_attribute8 := p10_a183;
    ddx_line_rec.pricing_attribute9 := p10_a184;
    ddx_line_rec.pricing_context := p10_a185;
    ddx_line_rec.pricing_date := rosetta_g_miss_date_in_map(p10_a186);
    ddx_line_rec.pricing_quantity := rosetta_g_miss_num_map(p10_a187);
    ddx_line_rec.pricing_quantity_uom := p10_a188;
    ddx_line_rec.program_application_id := rosetta_g_miss_num_map(p10_a189);
    ddx_line_rec.program_id := rosetta_g_miss_num_map(p10_a190);
    ddx_line_rec.program_update_date := rosetta_g_miss_date_in_map(p10_a191);
    ddx_line_rec.project_id := rosetta_g_miss_num_map(p10_a192);
    ddx_line_rec.promise_date := rosetta_g_miss_date_in_map(p10_a193);
    ddx_line_rec.re_source_flag := p10_a194;
    ddx_line_rec.reference_customer_trx_line_id := rosetta_g_miss_num_map(p10_a195);
    ddx_line_rec.reference_header_id := rosetta_g_miss_num_map(p10_a196);
    ddx_line_rec.reference_line_id := rosetta_g_miss_num_map(p10_a197);
    ddx_line_rec.reference_type := p10_a198;
    ddx_line_rec.request_date := rosetta_g_miss_date_in_map(p10_a199);
    ddx_line_rec.request_id := rosetta_g_miss_num_map(p10_a200);
    ddx_line_rec.reserved_quantity := rosetta_g_miss_num_map(p10_a201);
    ddx_line_rec.return_attribute1 := p10_a202;
    ddx_line_rec.return_attribute10 := p10_a203;
    ddx_line_rec.return_attribute11 := p10_a204;
    ddx_line_rec.return_attribute12 := p10_a205;
    ddx_line_rec.return_attribute13 := p10_a206;
    ddx_line_rec.return_attribute14 := p10_a207;
    ddx_line_rec.return_attribute15 := p10_a208;
    ddx_line_rec.return_attribute2 := p10_a209;
    ddx_line_rec.return_attribute3 := p10_a210;
    ddx_line_rec.return_attribute4 := p10_a211;
    ddx_line_rec.return_attribute5 := p10_a212;
    ddx_line_rec.return_attribute6 := p10_a213;
    ddx_line_rec.return_attribute7 := p10_a214;
    ddx_line_rec.return_attribute8 := p10_a215;
    ddx_line_rec.return_attribute9 := p10_a216;
    ddx_line_rec.return_context := p10_a217;
    ddx_line_rec.return_reason_code := p10_a218;
    ddx_line_rec.rla_schedule_type_code := p10_a219;
    ddx_line_rec.salesrep_id := rosetta_g_miss_num_map(p10_a220);
    ddx_line_rec.schedule_arrival_date := rosetta_g_miss_date_in_map(p10_a221);
    ddx_line_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p10_a222);
    ddx_line_rec.schedule_action_code := p10_a223;
    ddx_line_rec.schedule_status_code := p10_a224;
    ddx_line_rec.shipment_number := rosetta_g_miss_num_map(p10_a225);
    ddx_line_rec.shipment_priority_code := p10_a226;
    ddx_line_rec.shipped_quantity := rosetta_g_miss_num_map(p10_a227);
    ddx_line_rec.shipped_quantity2 := rosetta_g_miss_num_map(p10_a228);
    ddx_line_rec.shipping_interfaced_flag := p10_a229;
    ddx_line_rec.shipping_method_code := p10_a230;
    ddx_line_rec.shipping_quantity := rosetta_g_miss_num_map(p10_a231);
    ddx_line_rec.shipping_quantity2 := rosetta_g_miss_num_map(p10_a232);
    ddx_line_rec.shipping_quantity_uom := p10_a233;
    ddx_line_rec.shipping_quantity_uom2 := p10_a234;
    ddx_line_rec.ship_from_org_id := rosetta_g_miss_num_map(p10_a235);
    ddx_line_rec.ship_model_complete_flag := p10_a236;
    ddx_line_rec.ship_set_id := rosetta_g_miss_num_map(p10_a237);
    ddx_line_rec.fulfillment_set_id := rosetta_g_miss_num_map(p10_a238);
    ddx_line_rec.ship_tolerance_above := rosetta_g_miss_num_map(p10_a239);
    ddx_line_rec.ship_tolerance_below := rosetta_g_miss_num_map(p10_a240);
    ddx_line_rec.ship_to_contact_id := rosetta_g_miss_num_map(p10_a241);
    ddx_line_rec.ship_to_org_id := rosetta_g_miss_num_map(p10_a242);
    ddx_line_rec.sold_to_org_id := rosetta_g_miss_num_map(p10_a243);
    ddx_line_rec.sold_from_org_id := rosetta_g_miss_num_map(p10_a244);
    ddx_line_rec.sort_order := p10_a245;
    ddx_line_rec.source_document_id := rosetta_g_miss_num_map(p10_a246);
    ddx_line_rec.source_document_line_id := rosetta_g_miss_num_map(p10_a247);
    ddx_line_rec.source_document_type_id := rosetta_g_miss_num_map(p10_a248);
    ddx_line_rec.source_type_code := p10_a249;
    ddx_line_rec.split_from_line_id := rosetta_g_miss_num_map(p10_a250);
    ddx_line_rec.task_id := rosetta_g_miss_num_map(p10_a251);
    ddx_line_rec.tax_code := p10_a252;
    ddx_line_rec.tax_date := rosetta_g_miss_date_in_map(p10_a253);
    ddx_line_rec.tax_exempt_flag := p10_a254;
    ddx_line_rec.tax_exempt_number := p10_a255;
    ddx_line_rec.tax_exempt_reason_code := p10_a256;
    ddx_line_rec.tax_point_code := p10_a257;
    ddx_line_rec.tax_rate := rosetta_g_miss_num_map(p10_a258);
    ddx_line_rec.tax_value := rosetta_g_miss_num_map(p10_a259);
    ddx_line_rec.top_model_line_ref := p10_a260;
    ddx_line_rec.top_model_line_id := rosetta_g_miss_num_map(p10_a261);
    ddx_line_rec.top_model_line_index := rosetta_g_miss_num_map(p10_a262);
    ddx_line_rec.unit_list_price := rosetta_g_miss_num_map(p10_a263);
    ddx_line_rec.unit_list_price_per_pqty := rosetta_g_miss_num_map(p10_a264);
    ddx_line_rec.unit_selling_price := rosetta_g_miss_num_map(p10_a265);
    ddx_line_rec.unit_selling_price_per_pqty := rosetta_g_miss_num_map(p10_a266);
    ddx_line_rec.veh_cus_item_cum_key_id := rosetta_g_miss_num_map(p10_a267);
    ddx_line_rec.visible_demand_flag := p10_a268;
    ddx_line_rec.return_status := p10_a269;
    ddx_line_rec.db_flag := p10_a270;
    ddx_line_rec.operation := p10_a271;
    ddx_line_rec.first_ack_code := p10_a272;
    ddx_line_rec.first_ack_date := rosetta_g_miss_date_in_map(p10_a273);
    ddx_line_rec.last_ack_code := p10_a274;
    ddx_line_rec.last_ack_date := rosetta_g_miss_date_in_map(p10_a275);
    ddx_line_rec.change_reason := p10_a276;
    ddx_line_rec.change_comments := p10_a277;
    ddx_line_rec.arrival_set := p10_a278;
    ddx_line_rec.ship_set := p10_a279;
    ddx_line_rec.fulfillment_set := p10_a280;
    ddx_line_rec.order_source_id := rosetta_g_miss_num_map(p10_a281);
    ddx_line_rec.orig_sys_shipment_ref := p10_a282;
    ddx_line_rec.change_sequence := p10_a283;
    ddx_line_rec.change_request_code := p10_a284;
    ddx_line_rec.status_flag := p10_a285;
    ddx_line_rec.drop_ship_flag := p10_a286;
    ddx_line_rec.customer_line_number := p10_a287;
    ddx_line_rec.customer_shipment_number := p10_a288;
    ddx_line_rec.customer_item_net_price := rosetta_g_miss_num_map(p10_a289);
    ddx_line_rec.customer_payment_term_id := rosetta_g_miss_num_map(p10_a290);
    ddx_line_rec.ordered_item_id := rosetta_g_miss_num_map(p10_a291);
    ddx_line_rec.item_identifier_type := p10_a292;
    ddx_line_rec.shipping_instructions := p10_a293;
    ddx_line_rec.packing_instructions := p10_a294;
    ddx_line_rec.calculate_price_flag := p10_a295;
    ddx_line_rec.invoiced_quantity := rosetta_g_miss_num_map(p10_a296);
    ddx_line_rec.service_txn_reason_code := p10_a297;
    ddx_line_rec.service_txn_comments := p10_a298;
    ddx_line_rec.service_duration := rosetta_g_miss_num_map(p10_a299);
    ddx_line_rec.service_period := p10_a300;
    ddx_line_rec.service_start_date := rosetta_g_miss_date_in_map(p10_a301);
    ddx_line_rec.service_end_date := rosetta_g_miss_date_in_map(p10_a302);
    ddx_line_rec.service_coterminate_flag := p10_a303;
    ddx_line_rec.unit_list_percent := rosetta_g_miss_num_map(p10_a304);
    ddx_line_rec.unit_selling_percent := rosetta_g_miss_num_map(p10_a305);
    ddx_line_rec.unit_percent_base_price := rosetta_g_miss_num_map(p10_a306);
    ddx_line_rec.service_number := rosetta_g_miss_num_map(p10_a307);
    ddx_line_rec.service_reference_type_code := p10_a308;
    ddx_line_rec.service_reference_line_id := rosetta_g_miss_num_map(p10_a309);
    ddx_line_rec.service_reference_system_id := rosetta_g_miss_num_map(p10_a310);
    ddx_line_rec.service_ref_order_number := rosetta_g_miss_num_map(p10_a311);
    ddx_line_rec.service_ref_line_number := rosetta_g_miss_num_map(p10_a312);
    ddx_line_rec.service_reference_order := p10_a313;
    ddx_line_rec.service_reference_line := p10_a314;
    ddx_line_rec.service_reference_system := p10_a315;
    ddx_line_rec.service_ref_shipment_number := rosetta_g_miss_num_map(p10_a316);
    ddx_line_rec.service_ref_option_number := rosetta_g_miss_num_map(p10_a317);
    ddx_line_rec.service_line_index := rosetta_g_miss_num_map(p10_a318);
    ddx_line_rec.line_set_id := rosetta_g_miss_num_map(p10_a319);
    ddx_line_rec.split_by := p10_a320;
    ddx_line_rec.split_action_code := p10_a321;
    ddx_line_rec.shippable_flag := p10_a322;
    ddx_line_rec.model_remnant_flag := p10_a323;
    ddx_line_rec.flow_status_code := p10_a324;
    ddx_line_rec.fulfilled_flag := p10_a325;
    ddx_line_rec.fulfillment_method_code := p10_a326;
    ddx_line_rec.revenue_amount := rosetta_g_miss_num_map(p10_a327);
    ddx_line_rec.marketing_source_code_id := rosetta_g_miss_num_map(p10_a328);
    ddx_line_rec.fulfillment_date := rosetta_g_miss_date_in_map(p10_a329);
    if p10_a330 is null
      then ddx_line_rec.semi_processed_flag := null;
    elsif p10_a330 = 0
      then ddx_line_rec.semi_processed_flag := false;
    else ddx_line_rec.semi_processed_flag := true;
    end if;
    ddx_line_rec.upgraded_flag := p10_a331;
    ddx_line_rec.lock_control := rosetta_g_miss_num_map(p10_a332);
    ddx_line_rec.subinventory := p10_a333;
    ddx_line_rec.split_from_line_ref := p10_a334;
    ddx_line_rec.split_from_shipment_ref := p10_a335;
    ddx_line_rec.ship_to_edi_location_code := p10_a336;
    ddx_line_rec.bill_to_edi_location_code := p10_a337;
    ddx_line_rec.ship_from_edi_location_code := p10_a338;
    ddx_line_rec.ship_from_address_id := rosetta_g_miss_num_map(p10_a339);
    ddx_line_rec.sold_to_address_id := rosetta_g_miss_num_map(p10_a340);
    ddx_line_rec.ship_to_address_id := rosetta_g_miss_num_map(p10_a341);
    ddx_line_rec.invoice_address_id := rosetta_g_miss_num_map(p10_a342);
    ddx_line_rec.ship_to_address_code := p10_a343;
    ddx_line_rec.original_inventory_item_id := rosetta_g_miss_num_map(p10_a344);
    ddx_line_rec.original_item_identifier_type := p10_a345;
    ddx_line_rec.original_ordered_item_id := rosetta_g_miss_num_map(p10_a346);
    ddx_line_rec.original_ordered_item := p10_a347;
    ddx_line_rec.item_substitution_type_code := p10_a348;
    ddx_line_rec.late_demand_penalty_factor := rosetta_g_miss_num_map(p10_a349);
    ddx_line_rec.override_atp_date_code := p10_a350;
    ddx_line_rec.ship_to_customer_id := rosetta_g_miss_num_map(p10_a351);
    ddx_line_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p10_a352);
    ddx_line_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p10_a353);
    ddx_line_rec.accounting_rule_duration := rosetta_g_miss_num_map(p10_a354);
    ddx_line_rec.unit_cost := rosetta_g_miss_num_map(p10_a355);
    ddx_line_rec.user_item_description := p10_a356;
    ddx_line_rec.xml_transaction_type_code := p10_a357;
    ddx_line_rec.item_relationship_type := rosetta_g_miss_num_map(p10_a358);
    ddx_line_rec.blanket_number := rosetta_g_miss_num_map(p10_a359);
    ddx_line_rec.blanket_line_number := rosetta_g_miss_num_map(p10_a360);
    ddx_line_rec.blanket_version_number := rosetta_g_miss_num_map(p10_a361);
    ddx_line_rec.cso_response_flag := p10_a362;
    ddx_line_rec.firm_demand_flag := p10_a363;
    ddx_line_rec.earliest_ship_date := rosetta_g_miss_date_in_map(p10_a364);
    ddx_line_rec.transaction_phase_code := p10_a365;
    ddx_line_rec.source_document_version_number := rosetta_g_miss_num_map(p10_a366);
    ddx_line_rec.minisite_id := rosetta_g_miss_num_map(p10_a367);
    ddx_line_rec.ib_owner := p10_a368;
    ddx_line_rec.ib_installed_at_location := p10_a369;
    ddx_line_rec.ib_current_location := p10_a370;
    ddx_line_rec.end_customer_id := rosetta_g_miss_num_map(p10_a371);
    ddx_line_rec.end_customer_contact_id := rosetta_g_miss_num_map(p10_a372);
    ddx_line_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p10_a373);
    ddx_line_rec.supplier_signature := p10_a374;
    ddx_line_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p10_a375);
    ddx_line_rec.customer_signature := p10_a376;
    ddx_line_rec.customer_signature_date := rosetta_g_miss_date_in_map(p10_a377);
    ddx_line_rec.ship_to_party_id := rosetta_g_miss_num_map(p10_a378);
    ddx_line_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p10_a379);
    ddx_line_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p10_a380);
    ddx_line_rec.deliver_to_party_id := rosetta_g_miss_num_map(p10_a381);
    ddx_line_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p10_a382);
    ddx_line_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p10_a383);
    ddx_line_rec.invoice_to_party_id := rosetta_g_miss_num_map(p10_a384);
    ddx_line_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p10_a385);
    ddx_line_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p10_a386);
    ddx_line_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p10_a387);
    ddx_line_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p10_a388);
    ddx_line_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p10_a389);
    ddx_line_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p10_a390);
    ddx_line_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p10_a391);
    ddx_line_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p10_a392);
    ddx_line_rec.retrobill_request_id := rosetta_g_miss_num_map(p10_a393);
    ddx_line_rec.original_list_price := rosetta_g_miss_num_map(p10_a394);
    ddx_line_rec.commitment_applied_amount := rosetta_g_miss_num_map(p10_a395);

    ddx_old_line_rec.accounting_rule_id := rosetta_g_miss_num_map(p11_a0);
    ddx_old_line_rec.actual_arrival_date := rosetta_g_miss_date_in_map(p11_a1);
    ddx_old_line_rec.actual_shipment_date := rosetta_g_miss_date_in_map(p11_a2);
    ddx_old_line_rec.agreement_id := rosetta_g_miss_num_map(p11_a3);
    ddx_old_line_rec.arrival_set_id := rosetta_g_miss_num_map(p11_a4);
    ddx_old_line_rec.ato_line_id := rosetta_g_miss_num_map(p11_a5);
    ddx_old_line_rec.attribute1 := p11_a6;
    ddx_old_line_rec.attribute10 := p11_a7;
    ddx_old_line_rec.attribute11 := p11_a8;
    ddx_old_line_rec.attribute12 := p11_a9;
    ddx_old_line_rec.attribute13 := p11_a10;
    ddx_old_line_rec.attribute14 := p11_a11;
    ddx_old_line_rec.attribute15 := p11_a12;
    ddx_old_line_rec.attribute16 := p11_a13;
    ddx_old_line_rec.attribute17 := p11_a14;
    ddx_old_line_rec.attribute18 := p11_a15;
    ddx_old_line_rec.attribute19 := p11_a16;
    ddx_old_line_rec.attribute2 := p11_a17;
    ddx_old_line_rec.attribute20 := p11_a18;
    ddx_old_line_rec.attribute3 := p11_a19;
    ddx_old_line_rec.attribute4 := p11_a20;
    ddx_old_line_rec.attribute5 := p11_a21;
    ddx_old_line_rec.attribute6 := p11_a22;
    ddx_old_line_rec.attribute7 := p11_a23;
    ddx_old_line_rec.attribute8 := p11_a24;
    ddx_old_line_rec.attribute9 := p11_a25;
    ddx_old_line_rec.authorized_to_ship_flag := p11_a26;
    ddx_old_line_rec.auto_selected_quantity := rosetta_g_miss_num_map(p11_a27);
    ddx_old_line_rec.booked_flag := p11_a28;
    ddx_old_line_rec.cancelled_flag := p11_a29;
    ddx_old_line_rec.cancelled_quantity := rosetta_g_miss_num_map(p11_a30);
    ddx_old_line_rec.cancelled_quantity2 := rosetta_g_miss_num_map(p11_a31);
    ddx_old_line_rec.commitment_id := rosetta_g_miss_num_map(p11_a32);
    ddx_old_line_rec.component_code := p11_a33;
    ddx_old_line_rec.component_number := rosetta_g_miss_num_map(p11_a34);
    ddx_old_line_rec.component_sequence_id := rosetta_g_miss_num_map(p11_a35);
    ddx_old_line_rec.config_header_id := rosetta_g_miss_num_map(p11_a36);
    ddx_old_line_rec.config_rev_nbr := rosetta_g_miss_num_map(p11_a37);
    ddx_old_line_rec.config_display_sequence := rosetta_g_miss_num_map(p11_a38);
    ddx_old_line_rec.configuration_id := rosetta_g_miss_num_map(p11_a39);
    ddx_old_line_rec.context := p11_a40;
    ddx_old_line_rec.created_by := rosetta_g_miss_num_map(p11_a41);
    ddx_old_line_rec.creation_date := rosetta_g_miss_date_in_map(p11_a42);
    ddx_old_line_rec.credit_invoice_line_id := rosetta_g_miss_num_map(p11_a43);
    ddx_old_line_rec.customer_dock_code := p11_a44;
    ddx_old_line_rec.customer_job := p11_a45;
    ddx_old_line_rec.customer_production_line := p11_a46;
    ddx_old_line_rec.customer_trx_line_id := rosetta_g_miss_num_map(p11_a47);
    ddx_old_line_rec.cust_model_serial_number := p11_a48;
    ddx_old_line_rec.cust_po_number := p11_a49;
    ddx_old_line_rec.cust_production_seq_num := p11_a50;
    ddx_old_line_rec.delivery_lead_time := rosetta_g_miss_num_map(p11_a51);
    ddx_old_line_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p11_a52);
    ddx_old_line_rec.deliver_to_org_id := rosetta_g_miss_num_map(p11_a53);
    ddx_old_line_rec.demand_bucket_type_code := p11_a54;
    ddx_old_line_rec.demand_class_code := p11_a55;
    ddx_old_line_rec.dep_plan_required_flag := p11_a56;
    ddx_old_line_rec.earliest_acceptable_date := rosetta_g_miss_date_in_map(p11_a57);
    ddx_old_line_rec.end_item_unit_number := p11_a58;
    ddx_old_line_rec.explosion_date := rosetta_g_miss_date_in_map(p11_a59);
    ddx_old_line_rec.fob_point_code := p11_a60;
    ddx_old_line_rec.freight_carrier_code := p11_a61;
    ddx_old_line_rec.freight_terms_code := p11_a62;
    ddx_old_line_rec.fulfilled_quantity := rosetta_g_miss_num_map(p11_a63);
    ddx_old_line_rec.fulfilled_quantity2 := rosetta_g_miss_num_map(p11_a64);
    ddx_old_line_rec.global_attribute1 := p11_a65;
    ddx_old_line_rec.global_attribute10 := p11_a66;
    ddx_old_line_rec.global_attribute11 := p11_a67;
    ddx_old_line_rec.global_attribute12 := p11_a68;
    ddx_old_line_rec.global_attribute13 := p11_a69;
    ddx_old_line_rec.global_attribute14 := p11_a70;
    ddx_old_line_rec.global_attribute15 := p11_a71;
    ddx_old_line_rec.global_attribute16 := p11_a72;
    ddx_old_line_rec.global_attribute17 := p11_a73;
    ddx_old_line_rec.global_attribute18 := p11_a74;
    ddx_old_line_rec.global_attribute19 := p11_a75;
    ddx_old_line_rec.global_attribute2 := p11_a76;
    ddx_old_line_rec.global_attribute20 := p11_a77;
    ddx_old_line_rec.global_attribute3 := p11_a78;
    ddx_old_line_rec.global_attribute4 := p11_a79;
    ddx_old_line_rec.global_attribute5 := p11_a80;
    ddx_old_line_rec.global_attribute6 := p11_a81;
    ddx_old_line_rec.global_attribute7 := p11_a82;
    ddx_old_line_rec.global_attribute8 := p11_a83;
    ddx_old_line_rec.global_attribute9 := p11_a84;
    ddx_old_line_rec.global_attribute_category := p11_a85;
    ddx_old_line_rec.header_id := rosetta_g_miss_num_map(p11_a86);
    ddx_old_line_rec.industry_attribute1 := p11_a87;
    ddx_old_line_rec.industry_attribute10 := p11_a88;
    ddx_old_line_rec.industry_attribute11 := p11_a89;
    ddx_old_line_rec.industry_attribute12 := p11_a90;
    ddx_old_line_rec.industry_attribute13 := p11_a91;
    ddx_old_line_rec.industry_attribute14 := p11_a92;
    ddx_old_line_rec.industry_attribute15 := p11_a93;
    ddx_old_line_rec.industry_attribute16 := p11_a94;
    ddx_old_line_rec.industry_attribute17 := p11_a95;
    ddx_old_line_rec.industry_attribute18 := p11_a96;
    ddx_old_line_rec.industry_attribute19 := p11_a97;
    ddx_old_line_rec.industry_attribute20 := p11_a98;
    ddx_old_line_rec.industry_attribute21 := p11_a99;
    ddx_old_line_rec.industry_attribute22 := p11_a100;
    ddx_old_line_rec.industry_attribute23 := p11_a101;
    ddx_old_line_rec.industry_attribute24 := p11_a102;
    ddx_old_line_rec.industry_attribute25 := p11_a103;
    ddx_old_line_rec.industry_attribute26 := p11_a104;
    ddx_old_line_rec.industry_attribute27 := p11_a105;
    ddx_old_line_rec.industry_attribute28 := p11_a106;
    ddx_old_line_rec.industry_attribute29 := p11_a107;
    ddx_old_line_rec.industry_attribute30 := p11_a108;
    ddx_old_line_rec.industry_attribute2 := p11_a109;
    ddx_old_line_rec.industry_attribute3 := p11_a110;
    ddx_old_line_rec.industry_attribute4 := p11_a111;
    ddx_old_line_rec.industry_attribute5 := p11_a112;
    ddx_old_line_rec.industry_attribute6 := p11_a113;
    ddx_old_line_rec.industry_attribute7 := p11_a114;
    ddx_old_line_rec.industry_attribute8 := p11_a115;
    ddx_old_line_rec.industry_attribute9 := p11_a116;
    ddx_old_line_rec.industry_context := p11_a117;
    ddx_old_line_rec.tp_context := p11_a118;
    ddx_old_line_rec.tp_attribute1 := p11_a119;
    ddx_old_line_rec.tp_attribute2 := p11_a120;
    ddx_old_line_rec.tp_attribute3 := p11_a121;
    ddx_old_line_rec.tp_attribute4 := p11_a122;
    ddx_old_line_rec.tp_attribute5 := p11_a123;
    ddx_old_line_rec.tp_attribute6 := p11_a124;
    ddx_old_line_rec.tp_attribute7 := p11_a125;
    ddx_old_line_rec.tp_attribute8 := p11_a126;
    ddx_old_line_rec.tp_attribute9 := p11_a127;
    ddx_old_line_rec.tp_attribute10 := p11_a128;
    ddx_old_line_rec.tp_attribute11 := p11_a129;
    ddx_old_line_rec.tp_attribute12 := p11_a130;
    ddx_old_line_rec.tp_attribute13 := p11_a131;
    ddx_old_line_rec.tp_attribute14 := p11_a132;
    ddx_old_line_rec.tp_attribute15 := p11_a133;
    ddx_old_line_rec.intermed_ship_to_org_id := rosetta_g_miss_num_map(p11_a134);
    ddx_old_line_rec.intermed_ship_to_contact_id := rosetta_g_miss_num_map(p11_a135);
    ddx_old_line_rec.inventory_item_id := rosetta_g_miss_num_map(p11_a136);
    ddx_old_line_rec.invoice_interface_status_code := p11_a137;
    ddx_old_line_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p11_a138);
    ddx_old_line_rec.invoice_to_org_id := rosetta_g_miss_num_map(p11_a139);
    ddx_old_line_rec.invoicing_rule_id := rosetta_g_miss_num_map(p11_a140);
    ddx_old_line_rec.ordered_item := p11_a141;
    ddx_old_line_rec.item_revision := p11_a142;
    ddx_old_line_rec.item_type_code := p11_a143;
    ddx_old_line_rec.last_updated_by := rosetta_g_miss_num_map(p11_a144);
    ddx_old_line_rec.last_update_date := rosetta_g_miss_date_in_map(p11_a145);
    ddx_old_line_rec.last_update_login := rosetta_g_miss_num_map(p11_a146);
    ddx_old_line_rec.latest_acceptable_date := rosetta_g_miss_date_in_map(p11_a147);
    ddx_old_line_rec.line_category_code := p11_a148;
    ddx_old_line_rec.line_id := rosetta_g_miss_num_map(p11_a149);
    ddx_old_line_rec.line_number := rosetta_g_miss_num_map(p11_a150);
    ddx_old_line_rec.line_type_id := rosetta_g_miss_num_map(p11_a151);
    ddx_old_line_rec.link_to_line_ref := p11_a152;
    ddx_old_line_rec.link_to_line_id := rosetta_g_miss_num_map(p11_a153);
    ddx_old_line_rec.link_to_line_index := rosetta_g_miss_num_map(p11_a154);
    ddx_old_line_rec.model_group_number := rosetta_g_miss_num_map(p11_a155);
    ddx_old_line_rec.mfg_component_sequence_id := rosetta_g_miss_num_map(p11_a156);
    ddx_old_line_rec.mfg_lead_time := rosetta_g_miss_num_map(p11_a157);
    ddx_old_line_rec.open_flag := p11_a158;
    ddx_old_line_rec.option_flag := p11_a159;
    ddx_old_line_rec.option_number := rosetta_g_miss_num_map(p11_a160);
    ddx_old_line_rec.ordered_quantity := rosetta_g_miss_num_map(p11_a161);
    ddx_old_line_rec.ordered_quantity2 := rosetta_g_miss_num_map(p11_a162);
    ddx_old_line_rec.order_quantity_uom := p11_a163;
    ddx_old_line_rec.ordered_quantity_uom2 := p11_a164;
    ddx_old_line_rec.org_id := rosetta_g_miss_num_map(p11_a165);
    ddx_old_line_rec.orig_sys_document_ref := p11_a166;
    ddx_old_line_rec.orig_sys_line_ref := p11_a167;
    ddx_old_line_rec.over_ship_reason_code := p11_a168;
    ddx_old_line_rec.over_ship_resolved_flag := p11_a169;
    ddx_old_line_rec.payment_term_id := rosetta_g_miss_num_map(p11_a170);
    ddx_old_line_rec.planning_priority := rosetta_g_miss_num_map(p11_a171);
    ddx_old_line_rec.preferred_grade := p11_a172;
    ddx_old_line_rec.price_list_id := rosetta_g_miss_num_map(p11_a173);
    ddx_old_line_rec.price_request_code := p11_a174;
    ddx_old_line_rec.pricing_attribute1 := p11_a175;
    ddx_old_line_rec.pricing_attribute10 := p11_a176;
    ddx_old_line_rec.pricing_attribute2 := p11_a177;
    ddx_old_line_rec.pricing_attribute3 := p11_a178;
    ddx_old_line_rec.pricing_attribute4 := p11_a179;
    ddx_old_line_rec.pricing_attribute5 := p11_a180;
    ddx_old_line_rec.pricing_attribute6 := p11_a181;
    ddx_old_line_rec.pricing_attribute7 := p11_a182;
    ddx_old_line_rec.pricing_attribute8 := p11_a183;
    ddx_old_line_rec.pricing_attribute9 := p11_a184;
    ddx_old_line_rec.pricing_context := p11_a185;
    ddx_old_line_rec.pricing_date := rosetta_g_miss_date_in_map(p11_a186);
    ddx_old_line_rec.pricing_quantity := rosetta_g_miss_num_map(p11_a187);
    ddx_old_line_rec.pricing_quantity_uom := p11_a188;
    ddx_old_line_rec.program_application_id := rosetta_g_miss_num_map(p11_a189);
    ddx_old_line_rec.program_id := rosetta_g_miss_num_map(p11_a190);
    ddx_old_line_rec.program_update_date := rosetta_g_miss_date_in_map(p11_a191);
    ddx_old_line_rec.project_id := rosetta_g_miss_num_map(p11_a192);
    ddx_old_line_rec.promise_date := rosetta_g_miss_date_in_map(p11_a193);
    ddx_old_line_rec.re_source_flag := p11_a194;
    ddx_old_line_rec.reference_customer_trx_line_id := rosetta_g_miss_num_map(p11_a195);
    ddx_old_line_rec.reference_header_id := rosetta_g_miss_num_map(p11_a196);
    ddx_old_line_rec.reference_line_id := rosetta_g_miss_num_map(p11_a197);
    ddx_old_line_rec.reference_type := p11_a198;
    ddx_old_line_rec.request_date := rosetta_g_miss_date_in_map(p11_a199);
    ddx_old_line_rec.request_id := rosetta_g_miss_num_map(p11_a200);
    ddx_old_line_rec.reserved_quantity := rosetta_g_miss_num_map(p11_a201);
    ddx_old_line_rec.return_attribute1 := p11_a202;
    ddx_old_line_rec.return_attribute10 := p11_a203;
    ddx_old_line_rec.return_attribute11 := p11_a204;
    ddx_old_line_rec.return_attribute12 := p11_a205;
    ddx_old_line_rec.return_attribute13 := p11_a206;
    ddx_old_line_rec.return_attribute14 := p11_a207;
    ddx_old_line_rec.return_attribute15 := p11_a208;
    ddx_old_line_rec.return_attribute2 := p11_a209;
    ddx_old_line_rec.return_attribute3 := p11_a210;
    ddx_old_line_rec.return_attribute4 := p11_a211;
    ddx_old_line_rec.return_attribute5 := p11_a212;
    ddx_old_line_rec.return_attribute6 := p11_a213;
    ddx_old_line_rec.return_attribute7 := p11_a214;
    ddx_old_line_rec.return_attribute8 := p11_a215;
    ddx_old_line_rec.return_attribute9 := p11_a216;
    ddx_old_line_rec.return_context := p11_a217;
    ddx_old_line_rec.return_reason_code := p11_a218;
    ddx_old_line_rec.rla_schedule_type_code := p11_a219;
    ddx_old_line_rec.salesrep_id := rosetta_g_miss_num_map(p11_a220);
    ddx_old_line_rec.schedule_arrival_date := rosetta_g_miss_date_in_map(p11_a221);
    ddx_old_line_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p11_a222);
    ddx_old_line_rec.schedule_action_code := p11_a223;
    ddx_old_line_rec.schedule_status_code := p11_a224;
    ddx_old_line_rec.shipment_number := rosetta_g_miss_num_map(p11_a225);
    ddx_old_line_rec.shipment_priority_code := p11_a226;
    ddx_old_line_rec.shipped_quantity := rosetta_g_miss_num_map(p11_a227);
    ddx_old_line_rec.shipped_quantity2 := rosetta_g_miss_num_map(p11_a228);
    ddx_old_line_rec.shipping_interfaced_flag := p11_a229;
    ddx_old_line_rec.shipping_method_code := p11_a230;
    ddx_old_line_rec.shipping_quantity := rosetta_g_miss_num_map(p11_a231);
    ddx_old_line_rec.shipping_quantity2 := rosetta_g_miss_num_map(p11_a232);
    ddx_old_line_rec.shipping_quantity_uom := p11_a233;
    ddx_old_line_rec.shipping_quantity_uom2 := p11_a234;
    ddx_old_line_rec.ship_from_org_id := rosetta_g_miss_num_map(p11_a235);
    ddx_old_line_rec.ship_model_complete_flag := p11_a236;
    ddx_old_line_rec.ship_set_id := rosetta_g_miss_num_map(p11_a237);
    ddx_old_line_rec.fulfillment_set_id := rosetta_g_miss_num_map(p11_a238);
    ddx_old_line_rec.ship_tolerance_above := rosetta_g_miss_num_map(p11_a239);
    ddx_old_line_rec.ship_tolerance_below := rosetta_g_miss_num_map(p11_a240);
    ddx_old_line_rec.ship_to_contact_id := rosetta_g_miss_num_map(p11_a241);
    ddx_old_line_rec.ship_to_org_id := rosetta_g_miss_num_map(p11_a242);
    ddx_old_line_rec.sold_to_org_id := rosetta_g_miss_num_map(p11_a243);
    ddx_old_line_rec.sold_from_org_id := rosetta_g_miss_num_map(p11_a244);
    ddx_old_line_rec.sort_order := p11_a245;
    ddx_old_line_rec.source_document_id := rosetta_g_miss_num_map(p11_a246);
    ddx_old_line_rec.source_document_line_id := rosetta_g_miss_num_map(p11_a247);
    ddx_old_line_rec.source_document_type_id := rosetta_g_miss_num_map(p11_a248);
    ddx_old_line_rec.source_type_code := p11_a249;
    ddx_old_line_rec.split_from_line_id := rosetta_g_miss_num_map(p11_a250);
    ddx_old_line_rec.task_id := rosetta_g_miss_num_map(p11_a251);
    ddx_old_line_rec.tax_code := p11_a252;
    ddx_old_line_rec.tax_date := rosetta_g_miss_date_in_map(p11_a253);
    ddx_old_line_rec.tax_exempt_flag := p11_a254;
    ddx_old_line_rec.tax_exempt_number := p11_a255;
    ddx_old_line_rec.tax_exempt_reason_code := p11_a256;
    ddx_old_line_rec.tax_point_code := p11_a257;
    ddx_old_line_rec.tax_rate := rosetta_g_miss_num_map(p11_a258);
    ddx_old_line_rec.tax_value := rosetta_g_miss_num_map(p11_a259);
    ddx_old_line_rec.top_model_line_ref := p11_a260;
    ddx_old_line_rec.top_model_line_id := rosetta_g_miss_num_map(p11_a261);
    ddx_old_line_rec.top_model_line_index := rosetta_g_miss_num_map(p11_a262);
    ddx_old_line_rec.unit_list_price := rosetta_g_miss_num_map(p11_a263);
    ddx_old_line_rec.unit_list_price_per_pqty := rosetta_g_miss_num_map(p11_a264);
    ddx_old_line_rec.unit_selling_price := rosetta_g_miss_num_map(p11_a265);
    ddx_old_line_rec.unit_selling_price_per_pqty := rosetta_g_miss_num_map(p11_a266);
    ddx_old_line_rec.veh_cus_item_cum_key_id := rosetta_g_miss_num_map(p11_a267);
    ddx_old_line_rec.visible_demand_flag := p11_a268;
    ddx_old_line_rec.return_status := p11_a269;
    ddx_old_line_rec.db_flag := p11_a270;
    ddx_old_line_rec.operation := p11_a271;
    ddx_old_line_rec.first_ack_code := p11_a272;
    ddx_old_line_rec.first_ack_date := rosetta_g_miss_date_in_map(p11_a273);
    ddx_old_line_rec.last_ack_code := p11_a274;
    ddx_old_line_rec.last_ack_date := rosetta_g_miss_date_in_map(p11_a275);
    ddx_old_line_rec.change_reason := p11_a276;
    ddx_old_line_rec.change_comments := p11_a277;
    ddx_old_line_rec.arrival_set := p11_a278;
    ddx_old_line_rec.ship_set := p11_a279;
    ddx_old_line_rec.fulfillment_set := p11_a280;
    ddx_old_line_rec.order_source_id := rosetta_g_miss_num_map(p11_a281);
    ddx_old_line_rec.orig_sys_shipment_ref := p11_a282;
    ddx_old_line_rec.change_sequence := p11_a283;
    ddx_old_line_rec.change_request_code := p11_a284;
    ddx_old_line_rec.status_flag := p11_a285;
    ddx_old_line_rec.drop_ship_flag := p11_a286;
    ddx_old_line_rec.customer_line_number := p11_a287;
    ddx_old_line_rec.customer_shipment_number := p11_a288;
    ddx_old_line_rec.customer_item_net_price := rosetta_g_miss_num_map(p11_a289);
    ddx_old_line_rec.customer_payment_term_id := rosetta_g_miss_num_map(p11_a290);
    ddx_old_line_rec.ordered_item_id := rosetta_g_miss_num_map(p11_a291);
    ddx_old_line_rec.item_identifier_type := p11_a292;
    ddx_old_line_rec.shipping_instructions := p11_a293;
    ddx_old_line_rec.packing_instructions := p11_a294;
    ddx_old_line_rec.calculate_price_flag := p11_a295;
    ddx_old_line_rec.invoiced_quantity := rosetta_g_miss_num_map(p11_a296);
    ddx_old_line_rec.service_txn_reason_code := p11_a297;
    ddx_old_line_rec.service_txn_comments := p11_a298;
    ddx_old_line_rec.service_duration := rosetta_g_miss_num_map(p11_a299);
    ddx_old_line_rec.service_period := p11_a300;
    ddx_old_line_rec.service_start_date := rosetta_g_miss_date_in_map(p11_a301);
    ddx_old_line_rec.service_end_date := rosetta_g_miss_date_in_map(p11_a302);
    ddx_old_line_rec.service_coterminate_flag := p11_a303;
    ddx_old_line_rec.unit_list_percent := rosetta_g_miss_num_map(p11_a304);
    ddx_old_line_rec.unit_selling_percent := rosetta_g_miss_num_map(p11_a305);
    ddx_old_line_rec.unit_percent_base_price := rosetta_g_miss_num_map(p11_a306);
    ddx_old_line_rec.service_number := rosetta_g_miss_num_map(p11_a307);
    ddx_old_line_rec.service_reference_type_code := p11_a308;
    ddx_old_line_rec.service_reference_line_id := rosetta_g_miss_num_map(p11_a309);
    ddx_old_line_rec.service_reference_system_id := rosetta_g_miss_num_map(p11_a310);
    ddx_old_line_rec.service_ref_order_number := rosetta_g_miss_num_map(p11_a311);
    ddx_old_line_rec.service_ref_line_number := rosetta_g_miss_num_map(p11_a312);
    ddx_old_line_rec.service_reference_order := p11_a313;
    ddx_old_line_rec.service_reference_line := p11_a314;
    ddx_old_line_rec.service_reference_system := p11_a315;
    ddx_old_line_rec.service_ref_shipment_number := rosetta_g_miss_num_map(p11_a316);
    ddx_old_line_rec.service_ref_option_number := rosetta_g_miss_num_map(p11_a317);
    ddx_old_line_rec.service_line_index := rosetta_g_miss_num_map(p11_a318);
    ddx_old_line_rec.line_set_id := rosetta_g_miss_num_map(p11_a319);
    ddx_old_line_rec.split_by := p11_a320;
    ddx_old_line_rec.split_action_code := p11_a321;
    ddx_old_line_rec.shippable_flag := p11_a322;
    ddx_old_line_rec.model_remnant_flag := p11_a323;
    ddx_old_line_rec.flow_status_code := p11_a324;
    ddx_old_line_rec.fulfilled_flag := p11_a325;
    ddx_old_line_rec.fulfillment_method_code := p11_a326;
    ddx_old_line_rec.revenue_amount := rosetta_g_miss_num_map(p11_a327);
    ddx_old_line_rec.marketing_source_code_id := rosetta_g_miss_num_map(p11_a328);
    ddx_old_line_rec.fulfillment_date := rosetta_g_miss_date_in_map(p11_a329);
    if p11_a330 is null
      then ddx_old_line_rec.semi_processed_flag := null;
    elsif p11_a330 = 0
      then ddx_old_line_rec.semi_processed_flag := false;
    else ddx_old_line_rec.semi_processed_flag := true;
    end if;
    ddx_old_line_rec.upgraded_flag := p11_a331;
    ddx_old_line_rec.lock_control := rosetta_g_miss_num_map(p11_a332);
    ddx_old_line_rec.subinventory := p11_a333;
    ddx_old_line_rec.split_from_line_ref := p11_a334;
    ddx_old_line_rec.split_from_shipment_ref := p11_a335;
    ddx_old_line_rec.ship_to_edi_location_code := p11_a336;
    ddx_old_line_rec.bill_to_edi_location_code := p11_a337;
    ddx_old_line_rec.ship_from_edi_location_code := p11_a338;
    ddx_old_line_rec.ship_from_address_id := rosetta_g_miss_num_map(p11_a339);
    ddx_old_line_rec.sold_to_address_id := rosetta_g_miss_num_map(p11_a340);
    ddx_old_line_rec.ship_to_address_id := rosetta_g_miss_num_map(p11_a341);
    ddx_old_line_rec.invoice_address_id := rosetta_g_miss_num_map(p11_a342);
    ddx_old_line_rec.ship_to_address_code := p11_a343;
    ddx_old_line_rec.original_inventory_item_id := rosetta_g_miss_num_map(p11_a344);
    ddx_old_line_rec.original_item_identifier_type := p11_a345;
    ddx_old_line_rec.original_ordered_item_id := rosetta_g_miss_num_map(p11_a346);
    ddx_old_line_rec.original_ordered_item := p11_a347;
    ddx_old_line_rec.item_substitution_type_code := p11_a348;
    ddx_old_line_rec.late_demand_penalty_factor := rosetta_g_miss_num_map(p11_a349);
    ddx_old_line_rec.override_atp_date_code := p11_a350;
    ddx_old_line_rec.ship_to_customer_id := rosetta_g_miss_num_map(p11_a351);
    ddx_old_line_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p11_a352);
    ddx_old_line_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p11_a353);
    ddx_old_line_rec.accounting_rule_duration := rosetta_g_miss_num_map(p11_a354);
    ddx_old_line_rec.unit_cost := rosetta_g_miss_num_map(p11_a355);
    ddx_old_line_rec.user_item_description := p11_a356;
    ddx_old_line_rec.xml_transaction_type_code := p11_a357;
    ddx_old_line_rec.item_relationship_type := rosetta_g_miss_num_map(p11_a358);
    ddx_old_line_rec.blanket_number := rosetta_g_miss_num_map(p11_a359);
    ddx_old_line_rec.blanket_line_number := rosetta_g_miss_num_map(p11_a360);
    ddx_old_line_rec.blanket_version_number := rosetta_g_miss_num_map(p11_a361);
    ddx_old_line_rec.cso_response_flag := p11_a362;
    ddx_old_line_rec.firm_demand_flag := p11_a363;
    ddx_old_line_rec.earliest_ship_date := rosetta_g_miss_date_in_map(p11_a364);
    ddx_old_line_rec.transaction_phase_code := p11_a365;
    ddx_old_line_rec.source_document_version_number := rosetta_g_miss_num_map(p11_a366);
    ddx_old_line_rec.minisite_id := rosetta_g_miss_num_map(p11_a367);
    ddx_old_line_rec.ib_owner := p11_a368;
    ddx_old_line_rec.ib_installed_at_location := p11_a369;
    ddx_old_line_rec.ib_current_location := p11_a370;
    ddx_old_line_rec.end_customer_id := rosetta_g_miss_num_map(p11_a371);
    ddx_old_line_rec.end_customer_contact_id := rosetta_g_miss_num_map(p11_a372);
    ddx_old_line_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p11_a373);
    ddx_old_line_rec.supplier_signature := p11_a374;
    ddx_old_line_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p11_a375);
    ddx_old_line_rec.customer_signature := p11_a376;
    ddx_old_line_rec.customer_signature_date := rosetta_g_miss_date_in_map(p11_a377);
    ddx_old_line_rec.ship_to_party_id := rosetta_g_miss_num_map(p11_a378);
    ddx_old_line_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p11_a379);
    ddx_old_line_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p11_a380);
    ddx_old_line_rec.deliver_to_party_id := rosetta_g_miss_num_map(p11_a381);
    ddx_old_line_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p11_a382);
    ddx_old_line_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p11_a383);
    ddx_old_line_rec.invoice_to_party_id := rosetta_g_miss_num_map(p11_a384);
    ddx_old_line_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p11_a385);
    ddx_old_line_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p11_a386);
    ddx_old_line_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p11_a387);
    ddx_old_line_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p11_a388);
    ddx_old_line_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p11_a389);
    ddx_old_line_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p11_a390);
    ddx_old_line_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p11_a391);
    ddx_old_line_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p11_a392);
    ddx_old_line_rec.retrobill_request_id := rosetta_g_miss_num_map(p11_a393);
    ddx_old_line_rec.original_list_price := rosetta_g_miss_num_map(p11_a394);
    ddx_old_line_rec.commitment_applied_amount := rosetta_g_miss_num_map(p11_a395);

    ddx_line_val_rec.accounting_rule := p12_a0;
    ddx_line_val_rec.agreement := p12_a1;
    ddx_line_val_rec.commitment := p12_a2;
    ddx_line_val_rec.commitment_applied_amount := rosetta_g_miss_num_map(p12_a3);
    ddx_line_val_rec.deliver_to_address1 := p12_a4;
    ddx_line_val_rec.deliver_to_address2 := p12_a5;
    ddx_line_val_rec.deliver_to_address3 := p12_a6;
    ddx_line_val_rec.deliver_to_address4 := p12_a7;
    ddx_line_val_rec.deliver_to_contact := p12_a8;
    ddx_line_val_rec.deliver_to_location := p12_a9;
    ddx_line_val_rec.deliver_to_org := p12_a10;
    ddx_line_val_rec.deliver_to_state := p12_a11;
    ddx_line_val_rec.deliver_to_city := p12_a12;
    ddx_line_val_rec.deliver_to_zip := p12_a13;
    ddx_line_val_rec.deliver_to_country := p12_a14;
    ddx_line_val_rec.deliver_to_county := p12_a15;
    ddx_line_val_rec.deliver_to_province := p12_a16;
    ddx_line_val_rec.demand_class := p12_a17;
    ddx_line_val_rec.demand_bucket_type := p12_a18;
    ddx_line_val_rec.fob_point := p12_a19;
    ddx_line_val_rec.freight_terms := p12_a20;
    ddx_line_val_rec.inventory_item := p12_a21;
    ddx_line_val_rec.invoice_to_address1 := p12_a22;
    ddx_line_val_rec.invoice_to_address2 := p12_a23;
    ddx_line_val_rec.invoice_to_address3 := p12_a24;
    ddx_line_val_rec.invoice_to_address4 := p12_a25;
    ddx_line_val_rec.invoice_to_contact := p12_a26;
    ddx_line_val_rec.invoice_to_location := p12_a27;
    ddx_line_val_rec.invoice_to_org := p12_a28;
    ddx_line_val_rec.invoice_to_state := p12_a29;
    ddx_line_val_rec.invoice_to_city := p12_a30;
    ddx_line_val_rec.invoice_to_zip := p12_a31;
    ddx_line_val_rec.invoice_to_country := p12_a32;
    ddx_line_val_rec.invoice_to_county := p12_a33;
    ddx_line_val_rec.invoice_to_province := p12_a34;
    ddx_line_val_rec.invoicing_rule := p12_a35;
    ddx_line_val_rec.item_type := p12_a36;
    ddx_line_val_rec.line_type := p12_a37;
    ddx_line_val_rec.over_ship_reason := p12_a38;
    ddx_line_val_rec.payment_term := p12_a39;
    ddx_line_val_rec.price_list := p12_a40;
    ddx_line_val_rec.project := p12_a41;
    ddx_line_val_rec.return_reason := p12_a42;
    ddx_line_val_rec.rla_schedule_type := p12_a43;
    ddx_line_val_rec.salesrep := p12_a44;
    ddx_line_val_rec.shipment_priority := p12_a45;
    ddx_line_val_rec.ship_from_address1 := p12_a46;
    ddx_line_val_rec.ship_from_address2 := p12_a47;
    ddx_line_val_rec.ship_from_address3 := p12_a48;
    ddx_line_val_rec.ship_from_address4 := p12_a49;
    ddx_line_val_rec.ship_from_location := p12_a50;
    ddx_line_val_rec.ship_from_city := p12_a51;
    ddx_line_val_rec.ship_from_postal_code := p12_a52;
    ddx_line_val_rec.ship_from_country := p12_a53;
    ddx_line_val_rec.ship_from_region1 := p12_a54;
    ddx_line_val_rec.ship_from_region2 := p12_a55;
    ddx_line_val_rec.ship_from_region3 := p12_a56;
    ddx_line_val_rec.ship_from_org := p12_a57;
    ddx_line_val_rec.ship_to_address1 := p12_a58;
    ddx_line_val_rec.ship_to_address2 := p12_a59;
    ddx_line_val_rec.ship_to_address3 := p12_a60;
    ddx_line_val_rec.ship_to_address4 := p12_a61;
    ddx_line_val_rec.ship_to_state := p12_a62;
    ddx_line_val_rec.ship_to_country := p12_a63;
    ddx_line_val_rec.ship_to_zip := p12_a64;
    ddx_line_val_rec.ship_to_county := p12_a65;
    ddx_line_val_rec.ship_to_province := p12_a66;
    ddx_line_val_rec.ship_to_city := p12_a67;
    ddx_line_val_rec.ship_to_contact := p12_a68;
    ddx_line_val_rec.ship_to_contact_last_name := p12_a69;
    ddx_line_val_rec.ship_to_contact_first_name := p12_a70;
    ddx_line_val_rec.ship_to_location := p12_a71;
    ddx_line_val_rec.ship_to_org := p12_a72;
    ddx_line_val_rec.source_type := p12_a73;
    ddx_line_val_rec.intermed_ship_to_address1 := p12_a74;
    ddx_line_val_rec.intermed_ship_to_address2 := p12_a75;
    ddx_line_val_rec.intermed_ship_to_address3 := p12_a76;
    ddx_line_val_rec.intermed_ship_to_address4 := p12_a77;
    ddx_line_val_rec.intermed_ship_to_contact := p12_a78;
    ddx_line_val_rec.intermed_ship_to_location := p12_a79;
    ddx_line_val_rec.intermed_ship_to_org := p12_a80;
    ddx_line_val_rec.intermed_ship_to_state := p12_a81;
    ddx_line_val_rec.intermed_ship_to_city := p12_a82;
    ddx_line_val_rec.intermed_ship_to_zip := p12_a83;
    ddx_line_val_rec.intermed_ship_to_country := p12_a84;
    ddx_line_val_rec.intermed_ship_to_county := p12_a85;
    ddx_line_val_rec.intermed_ship_to_province := p12_a86;
    ddx_line_val_rec.sold_to_org := p12_a87;
    ddx_line_val_rec.sold_from_org := p12_a88;
    ddx_line_val_rec.task := p12_a89;
    ddx_line_val_rec.tax_exempt := p12_a90;
    ddx_line_val_rec.tax_exempt_reason := p12_a91;
    ddx_line_val_rec.tax_point := p12_a92;
    ddx_line_val_rec.veh_cus_item_cum_key := p12_a93;
    ddx_line_val_rec.visible_demand := p12_a94;
    ddx_line_val_rec.customer_payment_term := p12_a95;
    ddx_line_val_rec.ref_order_number := rosetta_g_miss_num_map(p12_a96);
    ddx_line_val_rec.ref_line_number := rosetta_g_miss_num_map(p12_a97);
    ddx_line_val_rec.ref_shipment_number := rosetta_g_miss_num_map(p12_a98);
    ddx_line_val_rec.ref_option_number := rosetta_g_miss_num_map(p12_a99);
    ddx_line_val_rec.ref_invoice_number := p12_a100;
    ddx_line_val_rec.ref_invoice_line_number := rosetta_g_miss_num_map(p12_a101);
    ddx_line_val_rec.credit_invoice_number := p12_a102;
    ddx_line_val_rec.tax_group := p12_a103;
    ddx_line_val_rec.status := p12_a104;
    ddx_line_val_rec.freight_carrier := p12_a105;
    ddx_line_val_rec.shipping_method := p12_a106;
    ddx_line_val_rec.calculate_price_descr := p12_a107;
    ddx_line_val_rec.ship_to_customer_name := p12_a108;
    ddx_line_val_rec.invoice_to_customer_name := p12_a109;
    ddx_line_val_rec.ship_to_customer_number := p12_a110;
    ddx_line_val_rec.invoice_to_customer_number := p12_a111;
    ddx_line_val_rec.ship_to_customer_id := rosetta_g_miss_num_map(p12_a112);
    ddx_line_val_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p12_a113);
    ddx_line_val_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p12_a114);
    ddx_line_val_rec.deliver_to_customer_number := p12_a115;
    ddx_line_val_rec.deliver_to_customer_name := p12_a116;
    ddx_line_val_rec.original_ordered_item := p12_a117;
    ddx_line_val_rec.original_inventory_item := p12_a118;
    ddx_line_val_rec.original_item_identifier_type := p12_a119;
    ddx_line_val_rec.deliver_to_customer_number_oi := p12_a120;
    ddx_line_val_rec.deliver_to_customer_name_oi := p12_a121;
    ddx_line_val_rec.ship_to_customer_number_oi := p12_a122;
    ddx_line_val_rec.ship_to_customer_name_oi := p12_a123;
    ddx_line_val_rec.invoice_to_customer_number_oi := p12_a124;
    ddx_line_val_rec.invoice_to_customer_name_oi := p12_a125;
    ddx_line_val_rec.item_relationship_type_dsp := p12_a126;
    ddx_line_val_rec.transaction_phase := p12_a127;
    ddx_line_val_rec.end_customer_name := p12_a128;
    ddx_line_val_rec.end_customer_number := p12_a129;
    ddx_line_val_rec.end_customer_contact := p12_a130;
    ddx_line_val_rec.end_cust_contact_last_name := p12_a131;
    ddx_line_val_rec.end_cust_contact_first_name := p12_a132;
    ddx_line_val_rec.end_customer_site_address1 := p12_a133;
    ddx_line_val_rec.end_customer_site_address2 := p12_a134;
    ddx_line_val_rec.end_customer_site_address3 := p12_a135;
    ddx_line_val_rec.end_customer_site_address4 := p12_a136;
    ddx_line_val_rec.end_customer_site_location := p12_a137;
    ddx_line_val_rec.end_customer_site_state := p12_a138;
    ddx_line_val_rec.end_customer_site_country := p12_a139;
    ddx_line_val_rec.end_customer_site_zip := p12_a140;
    ddx_line_val_rec.end_customer_site_county := p12_a141;
    ddx_line_val_rec.end_customer_site_province := p12_a142;
    ddx_line_val_rec.end_customer_site_city := p12_a143;
    ddx_line_val_rec.end_customer_site_postal_code := p12_a144;
    ddx_line_val_rec.blanket_agreement_name := p12_a145;

    -- here's the delegated call to the old PL/SQL routine
    oe_oe_html_line.change_attribute(x_return_status,
      x_msg_count,
      x_msg_data,
      p_line_id,
      p_attr_id,
      p_attr_value,
      ddp_attr_id_tbl,
      ddp_attr_value_tbl,
      p_reason,
      p_comments,
      ddx_line_rec,
      ddx_old_line_rec,
      ddx_line_val_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    p10_a0 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_id);
    p10_a1 := ddx_line_rec.actual_arrival_date;
    p10_a2 := ddx_line_rec.actual_shipment_date;
    p10_a3 := rosetta_g_miss_num_map(ddx_line_rec.agreement_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_line_rec.arrival_set_id);
    p10_a5 := rosetta_g_miss_num_map(ddx_line_rec.ato_line_id);
    p10_a6 := ddx_line_rec.attribute1;
    p10_a7 := ddx_line_rec.attribute10;
    p10_a8 := ddx_line_rec.attribute11;
    p10_a9 := ddx_line_rec.attribute12;
    p10_a10 := ddx_line_rec.attribute13;
    p10_a11 := ddx_line_rec.attribute14;
    p10_a12 := ddx_line_rec.attribute15;
    p10_a13 := ddx_line_rec.attribute16;
    p10_a14 := ddx_line_rec.attribute17;
    p10_a15 := ddx_line_rec.attribute18;
    p10_a16 := ddx_line_rec.attribute19;
    p10_a17 := ddx_line_rec.attribute2;
    p10_a18 := ddx_line_rec.attribute20;
    p10_a19 := ddx_line_rec.attribute3;
    p10_a20 := ddx_line_rec.attribute4;
    p10_a21 := ddx_line_rec.attribute5;
    p10_a22 := ddx_line_rec.attribute6;
    p10_a23 := ddx_line_rec.attribute7;
    p10_a24 := ddx_line_rec.attribute8;
    p10_a25 := ddx_line_rec.attribute9;
    p10_a26 := ddx_line_rec.authorized_to_ship_flag;
    p10_a27 := rosetta_g_miss_num_map(ddx_line_rec.auto_selected_quantity);
    p10_a28 := ddx_line_rec.booked_flag;
    p10_a29 := ddx_line_rec.cancelled_flag;
    p10_a30 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity);
    p10_a31 := rosetta_g_miss_num_map(ddx_line_rec.cancelled_quantity2);
    p10_a32 := rosetta_g_miss_num_map(ddx_line_rec.commitment_id);
    p10_a33 := ddx_line_rec.component_code;
    p10_a34 := rosetta_g_miss_num_map(ddx_line_rec.component_number);
    p10_a35 := rosetta_g_miss_num_map(ddx_line_rec.component_sequence_id);
    p10_a36 := rosetta_g_miss_num_map(ddx_line_rec.config_header_id);
    p10_a37 := rosetta_g_miss_num_map(ddx_line_rec.config_rev_nbr);
    p10_a38 := rosetta_g_miss_num_map(ddx_line_rec.config_display_sequence);
    p10_a39 := rosetta_g_miss_num_map(ddx_line_rec.configuration_id);
    p10_a40 := ddx_line_rec.context;
    p10_a41 := rosetta_g_miss_num_map(ddx_line_rec.created_by);
    p10_a42 := ddx_line_rec.creation_date;
    p10_a43 := rosetta_g_miss_num_map(ddx_line_rec.credit_invoice_line_id);
    p10_a44 := ddx_line_rec.customer_dock_code;
    p10_a45 := ddx_line_rec.customer_job;
    p10_a46 := ddx_line_rec.customer_production_line;
    p10_a47 := rosetta_g_miss_num_map(ddx_line_rec.customer_trx_line_id);
    p10_a48 := ddx_line_rec.cust_model_serial_number;
    p10_a49 := ddx_line_rec.cust_po_number;
    p10_a50 := ddx_line_rec.cust_production_seq_num;
    p10_a51 := rosetta_g_miss_num_map(ddx_line_rec.delivery_lead_time);
    p10_a52 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_contact_id);
    p10_a53 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_id);
    p10_a54 := ddx_line_rec.demand_bucket_type_code;
    p10_a55 := ddx_line_rec.demand_class_code;
    p10_a56 := ddx_line_rec.dep_plan_required_flag;
    p10_a57 := ddx_line_rec.earliest_acceptable_date;
    p10_a58 := ddx_line_rec.end_item_unit_number;
    p10_a59 := ddx_line_rec.explosion_date;
    p10_a60 := ddx_line_rec.fob_point_code;
    p10_a61 := ddx_line_rec.freight_carrier_code;
    p10_a62 := ddx_line_rec.freight_terms_code;
    p10_a63 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity);
    p10_a64 := rosetta_g_miss_num_map(ddx_line_rec.fulfilled_quantity2);
    p10_a65 := ddx_line_rec.global_attribute1;
    p10_a66 := ddx_line_rec.global_attribute10;
    p10_a67 := ddx_line_rec.global_attribute11;
    p10_a68 := ddx_line_rec.global_attribute12;
    p10_a69 := ddx_line_rec.global_attribute13;
    p10_a70 := ddx_line_rec.global_attribute14;
    p10_a71 := ddx_line_rec.global_attribute15;
    p10_a72 := ddx_line_rec.global_attribute16;
    p10_a73 := ddx_line_rec.global_attribute17;
    p10_a74 := ddx_line_rec.global_attribute18;
    p10_a75 := ddx_line_rec.global_attribute19;
    p10_a76 := ddx_line_rec.global_attribute2;
    p10_a77 := ddx_line_rec.global_attribute20;
    p10_a78 := ddx_line_rec.global_attribute3;
    p10_a79 := ddx_line_rec.global_attribute4;
    p10_a80 := ddx_line_rec.global_attribute5;
    p10_a81 := ddx_line_rec.global_attribute6;
    p10_a82 := ddx_line_rec.global_attribute7;
    p10_a83 := ddx_line_rec.global_attribute8;
    p10_a84 := ddx_line_rec.global_attribute9;
    p10_a85 := ddx_line_rec.global_attribute_category;
    p10_a86 := rosetta_g_miss_num_map(ddx_line_rec.header_id);
    p10_a87 := ddx_line_rec.industry_attribute1;
    p10_a88 := ddx_line_rec.industry_attribute10;
    p10_a89 := ddx_line_rec.industry_attribute11;
    p10_a90 := ddx_line_rec.industry_attribute12;
    p10_a91 := ddx_line_rec.industry_attribute13;
    p10_a92 := ddx_line_rec.industry_attribute14;
    p10_a93 := ddx_line_rec.industry_attribute15;
    p10_a94 := ddx_line_rec.industry_attribute16;
    p10_a95 := ddx_line_rec.industry_attribute17;
    p10_a96 := ddx_line_rec.industry_attribute18;
    p10_a97 := ddx_line_rec.industry_attribute19;
    p10_a98 := ddx_line_rec.industry_attribute20;
    p10_a99 := ddx_line_rec.industry_attribute21;
    p10_a100 := ddx_line_rec.industry_attribute22;
    p10_a101 := ddx_line_rec.industry_attribute23;
    p10_a102 := ddx_line_rec.industry_attribute24;
    p10_a103 := ddx_line_rec.industry_attribute25;
    p10_a104 := ddx_line_rec.industry_attribute26;
    p10_a105 := ddx_line_rec.industry_attribute27;
    p10_a106 := ddx_line_rec.industry_attribute28;
    p10_a107 := ddx_line_rec.industry_attribute29;
    p10_a108 := ddx_line_rec.industry_attribute30;
    p10_a109 := ddx_line_rec.industry_attribute2;
    p10_a110 := ddx_line_rec.industry_attribute3;
    p10_a111 := ddx_line_rec.industry_attribute4;
    p10_a112 := ddx_line_rec.industry_attribute5;
    p10_a113 := ddx_line_rec.industry_attribute6;
    p10_a114 := ddx_line_rec.industry_attribute7;
    p10_a115 := ddx_line_rec.industry_attribute8;
    p10_a116 := ddx_line_rec.industry_attribute9;
    p10_a117 := ddx_line_rec.industry_context;
    p10_a118 := ddx_line_rec.tp_context;
    p10_a119 := ddx_line_rec.tp_attribute1;
    p10_a120 := ddx_line_rec.tp_attribute2;
    p10_a121 := ddx_line_rec.tp_attribute3;
    p10_a122 := ddx_line_rec.tp_attribute4;
    p10_a123 := ddx_line_rec.tp_attribute5;
    p10_a124 := ddx_line_rec.tp_attribute6;
    p10_a125 := ddx_line_rec.tp_attribute7;
    p10_a126 := ddx_line_rec.tp_attribute8;
    p10_a127 := ddx_line_rec.tp_attribute9;
    p10_a128 := ddx_line_rec.tp_attribute10;
    p10_a129 := ddx_line_rec.tp_attribute11;
    p10_a130 := ddx_line_rec.tp_attribute12;
    p10_a131 := ddx_line_rec.tp_attribute13;
    p10_a132 := ddx_line_rec.tp_attribute14;
    p10_a133 := ddx_line_rec.tp_attribute15;
    p10_a134 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_org_id);
    p10_a135 := rosetta_g_miss_num_map(ddx_line_rec.intermed_ship_to_contact_id);
    p10_a136 := rosetta_g_miss_num_map(ddx_line_rec.inventory_item_id);
    p10_a137 := ddx_line_rec.invoice_interface_status_code;
    p10_a138 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_contact_id);
    p10_a139 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_id);
    p10_a140 := rosetta_g_miss_num_map(ddx_line_rec.invoicing_rule_id);
    p10_a141 := ddx_line_rec.ordered_item;
    p10_a142 := ddx_line_rec.item_revision;
    p10_a143 := ddx_line_rec.item_type_code;
    p10_a144 := rosetta_g_miss_num_map(ddx_line_rec.last_updated_by);
    p10_a145 := ddx_line_rec.last_update_date;
    p10_a146 := rosetta_g_miss_num_map(ddx_line_rec.last_update_login);
    p10_a147 := ddx_line_rec.latest_acceptable_date;
    p10_a148 := ddx_line_rec.line_category_code;
    p10_a149 := rosetta_g_miss_num_map(ddx_line_rec.line_id);
    p10_a150 := rosetta_g_miss_num_map(ddx_line_rec.line_number);
    p10_a151 := rosetta_g_miss_num_map(ddx_line_rec.line_type_id);
    p10_a152 := ddx_line_rec.link_to_line_ref;
    p10_a153 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_id);
    p10_a154 := rosetta_g_miss_num_map(ddx_line_rec.link_to_line_index);
    p10_a155 := rosetta_g_miss_num_map(ddx_line_rec.model_group_number);
    p10_a156 := rosetta_g_miss_num_map(ddx_line_rec.mfg_component_sequence_id);
    p10_a157 := rosetta_g_miss_num_map(ddx_line_rec.mfg_lead_time);
    p10_a158 := ddx_line_rec.open_flag;
    p10_a159 := ddx_line_rec.option_flag;
    p10_a160 := rosetta_g_miss_num_map(ddx_line_rec.option_number);
    p10_a161 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity);
    p10_a162 := rosetta_g_miss_num_map(ddx_line_rec.ordered_quantity2);
    p10_a163 := ddx_line_rec.order_quantity_uom;
    p10_a164 := ddx_line_rec.ordered_quantity_uom2;
    p10_a165 := rosetta_g_miss_num_map(ddx_line_rec.org_id);
    p10_a166 := ddx_line_rec.orig_sys_document_ref;
    p10_a167 := ddx_line_rec.orig_sys_line_ref;
    p10_a168 := ddx_line_rec.over_ship_reason_code;
    p10_a169 := ddx_line_rec.over_ship_resolved_flag;
    p10_a170 := rosetta_g_miss_num_map(ddx_line_rec.payment_term_id);
    p10_a171 := rosetta_g_miss_num_map(ddx_line_rec.planning_priority);
    p10_a172 := ddx_line_rec.preferred_grade;
    p10_a173 := rosetta_g_miss_num_map(ddx_line_rec.price_list_id);
    p10_a174 := ddx_line_rec.price_request_code;
    p10_a175 := ddx_line_rec.pricing_attribute1;
    p10_a176 := ddx_line_rec.pricing_attribute10;
    p10_a177 := ddx_line_rec.pricing_attribute2;
    p10_a178 := ddx_line_rec.pricing_attribute3;
    p10_a179 := ddx_line_rec.pricing_attribute4;
    p10_a180 := ddx_line_rec.pricing_attribute5;
    p10_a181 := ddx_line_rec.pricing_attribute6;
    p10_a182 := ddx_line_rec.pricing_attribute7;
    p10_a183 := ddx_line_rec.pricing_attribute8;
    p10_a184 := ddx_line_rec.pricing_attribute9;
    p10_a185 := ddx_line_rec.pricing_context;
    p10_a186 := ddx_line_rec.pricing_date;
    p10_a187 := rosetta_g_miss_num_map(ddx_line_rec.pricing_quantity);
    p10_a188 := ddx_line_rec.pricing_quantity_uom;
    p10_a189 := rosetta_g_miss_num_map(ddx_line_rec.program_application_id);
    p10_a190 := rosetta_g_miss_num_map(ddx_line_rec.program_id);
    p10_a191 := ddx_line_rec.program_update_date;
    p10_a192 := rosetta_g_miss_num_map(ddx_line_rec.project_id);
    p10_a193 := ddx_line_rec.promise_date;
    p10_a194 := ddx_line_rec.re_source_flag;
    p10_a195 := rosetta_g_miss_num_map(ddx_line_rec.reference_customer_trx_line_id);
    p10_a196 := rosetta_g_miss_num_map(ddx_line_rec.reference_header_id);
    p10_a197 := rosetta_g_miss_num_map(ddx_line_rec.reference_line_id);
    p10_a198 := ddx_line_rec.reference_type;
    p10_a199 := ddx_line_rec.request_date;
    p10_a200 := rosetta_g_miss_num_map(ddx_line_rec.request_id);
    p10_a201 := rosetta_g_miss_num_map(ddx_line_rec.reserved_quantity);
    p10_a202 := ddx_line_rec.return_attribute1;
    p10_a203 := ddx_line_rec.return_attribute10;
    p10_a204 := ddx_line_rec.return_attribute11;
    p10_a205 := ddx_line_rec.return_attribute12;
    p10_a206 := ddx_line_rec.return_attribute13;
    p10_a207 := ddx_line_rec.return_attribute14;
    p10_a208 := ddx_line_rec.return_attribute15;
    p10_a209 := ddx_line_rec.return_attribute2;
    p10_a210 := ddx_line_rec.return_attribute3;
    p10_a211 := ddx_line_rec.return_attribute4;
    p10_a212 := ddx_line_rec.return_attribute5;
    p10_a213 := ddx_line_rec.return_attribute6;
    p10_a214 := ddx_line_rec.return_attribute7;
    p10_a215 := ddx_line_rec.return_attribute8;
    p10_a216 := ddx_line_rec.return_attribute9;
    p10_a217 := ddx_line_rec.return_context;
    p10_a218 := ddx_line_rec.return_reason_code;
    p10_a219 := ddx_line_rec.rla_schedule_type_code;
    p10_a220 := rosetta_g_miss_num_map(ddx_line_rec.salesrep_id);
    p10_a221 := ddx_line_rec.schedule_arrival_date;
    p10_a222 := ddx_line_rec.schedule_ship_date;
    p10_a223 := ddx_line_rec.schedule_action_code;
    p10_a224 := ddx_line_rec.schedule_status_code;
    p10_a225 := rosetta_g_miss_num_map(ddx_line_rec.shipment_number);
    p10_a226 := ddx_line_rec.shipment_priority_code;
    p10_a227 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity);
    p10_a228 := rosetta_g_miss_num_map(ddx_line_rec.shipped_quantity2);
    p10_a229 := ddx_line_rec.shipping_interfaced_flag;
    p10_a230 := ddx_line_rec.shipping_method_code;
    p10_a231 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity);
    p10_a232 := rosetta_g_miss_num_map(ddx_line_rec.shipping_quantity2);
    p10_a233 := ddx_line_rec.shipping_quantity_uom;
    p10_a234 := ddx_line_rec.shipping_quantity_uom2;
    p10_a235 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_org_id);
    p10_a236 := ddx_line_rec.ship_model_complete_flag;
    p10_a237 := rosetta_g_miss_num_map(ddx_line_rec.ship_set_id);
    p10_a238 := rosetta_g_miss_num_map(ddx_line_rec.fulfillment_set_id);
    p10_a239 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_above);
    p10_a240 := rosetta_g_miss_num_map(ddx_line_rec.ship_tolerance_below);
    p10_a241 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_contact_id);
    p10_a242 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_id);
    p10_a243 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_org_id);
    p10_a244 := rosetta_g_miss_num_map(ddx_line_rec.sold_from_org_id);
    p10_a245 := ddx_line_rec.sort_order;
    p10_a246 := rosetta_g_miss_num_map(ddx_line_rec.source_document_id);
    p10_a247 := rosetta_g_miss_num_map(ddx_line_rec.source_document_line_id);
    p10_a248 := rosetta_g_miss_num_map(ddx_line_rec.source_document_type_id);
    p10_a249 := ddx_line_rec.source_type_code;
    p10_a250 := rosetta_g_miss_num_map(ddx_line_rec.split_from_line_id);
    p10_a251 := rosetta_g_miss_num_map(ddx_line_rec.task_id);
    p10_a252 := ddx_line_rec.tax_code;
    p10_a253 := ddx_line_rec.tax_date;
    p10_a254 := ddx_line_rec.tax_exempt_flag;
    p10_a255 := ddx_line_rec.tax_exempt_number;
    p10_a256 := ddx_line_rec.tax_exempt_reason_code;
    p10_a257 := ddx_line_rec.tax_point_code;
    p10_a258 := rosetta_g_miss_num_map(ddx_line_rec.tax_rate);
    p10_a259 := rosetta_g_miss_num_map(ddx_line_rec.tax_value);
    p10_a260 := ddx_line_rec.top_model_line_ref;
    p10_a261 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_id);
    p10_a262 := rosetta_g_miss_num_map(ddx_line_rec.top_model_line_index);
    p10_a263 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price);
    p10_a264 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_price_per_pqty);
    p10_a265 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price);
    p10_a266 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_price_per_pqty);
    p10_a267 := rosetta_g_miss_num_map(ddx_line_rec.veh_cus_item_cum_key_id);
    p10_a268 := ddx_line_rec.visible_demand_flag;
    p10_a269 := ddx_line_rec.return_status;
    p10_a270 := ddx_line_rec.db_flag;
    p10_a271 := ddx_line_rec.operation;
    p10_a272 := ddx_line_rec.first_ack_code;
    p10_a273 := ddx_line_rec.first_ack_date;
    p10_a274 := ddx_line_rec.last_ack_code;
    p10_a275 := ddx_line_rec.last_ack_date;
    p10_a276 := ddx_line_rec.change_reason;
    p10_a277 := ddx_line_rec.change_comments;
    p10_a278 := ddx_line_rec.arrival_set;
    p10_a279 := ddx_line_rec.ship_set;
    p10_a280 := ddx_line_rec.fulfillment_set;
    p10_a281 := rosetta_g_miss_num_map(ddx_line_rec.order_source_id);
    p10_a282 := ddx_line_rec.orig_sys_shipment_ref;
    p10_a283 := ddx_line_rec.change_sequence;
    p10_a284 := ddx_line_rec.change_request_code;
    p10_a285 := ddx_line_rec.status_flag;
    p10_a286 := ddx_line_rec.drop_ship_flag;
    p10_a287 := ddx_line_rec.customer_line_number;
    p10_a288 := ddx_line_rec.customer_shipment_number;
    p10_a289 := rosetta_g_miss_num_map(ddx_line_rec.customer_item_net_price);
    p10_a290 := rosetta_g_miss_num_map(ddx_line_rec.customer_payment_term_id);
    p10_a291 := rosetta_g_miss_num_map(ddx_line_rec.ordered_item_id);
    p10_a292 := ddx_line_rec.item_identifier_type;
    p10_a293 := ddx_line_rec.shipping_instructions;
    p10_a294 := ddx_line_rec.packing_instructions;
    p10_a295 := ddx_line_rec.calculate_price_flag;
    p10_a296 := rosetta_g_miss_num_map(ddx_line_rec.invoiced_quantity);
    p10_a297 := ddx_line_rec.service_txn_reason_code;
    p10_a298 := ddx_line_rec.service_txn_comments;
    p10_a299 := rosetta_g_miss_num_map(ddx_line_rec.service_duration);
    p10_a300 := ddx_line_rec.service_period;
    p10_a301 := ddx_line_rec.service_start_date;
    p10_a302 := ddx_line_rec.service_end_date;
    p10_a303 := ddx_line_rec.service_coterminate_flag;
    p10_a304 := rosetta_g_miss_num_map(ddx_line_rec.unit_list_percent);
    p10_a305 := rosetta_g_miss_num_map(ddx_line_rec.unit_selling_percent);
    p10_a306 := rosetta_g_miss_num_map(ddx_line_rec.unit_percent_base_price);
    p10_a307 := rosetta_g_miss_num_map(ddx_line_rec.service_number);
    p10_a308 := ddx_line_rec.service_reference_type_code;
    p10_a309 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_line_id);
    p10_a310 := rosetta_g_miss_num_map(ddx_line_rec.service_reference_system_id);
    p10_a311 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_order_number);
    p10_a312 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_line_number);
    p10_a313 := ddx_line_rec.service_reference_order;
    p10_a314 := ddx_line_rec.service_reference_line;
    p10_a315 := ddx_line_rec.service_reference_system;
    p10_a316 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_shipment_number);
    p10_a317 := rosetta_g_miss_num_map(ddx_line_rec.service_ref_option_number);
    p10_a318 := rosetta_g_miss_num_map(ddx_line_rec.service_line_index);
    p10_a319 := rosetta_g_miss_num_map(ddx_line_rec.line_set_id);
    p10_a320 := ddx_line_rec.split_by;
    p10_a321 := ddx_line_rec.split_action_code;
    p10_a322 := ddx_line_rec.shippable_flag;
    p10_a323 := ddx_line_rec.model_remnant_flag;
    p10_a324 := ddx_line_rec.flow_status_code;
    p10_a325 := ddx_line_rec.fulfilled_flag;
    p10_a326 := ddx_line_rec.fulfillment_method_code;
    p10_a327 := rosetta_g_miss_num_map(ddx_line_rec.revenue_amount);
    p10_a328 := rosetta_g_miss_num_map(ddx_line_rec.marketing_source_code_id);
    p10_a329 := ddx_line_rec.fulfillment_date;
    if ddx_line_rec.semi_processed_flag is null
      then p10_a330 := null;
    elsif ddx_line_rec.semi_processed_flag
      then p10_a330 := 1;
    else p10_a330 := 0;
    end if;
    p10_a331 := ddx_line_rec.upgraded_flag;
    p10_a332 := rosetta_g_miss_num_map(ddx_line_rec.lock_control);
    p10_a333 := ddx_line_rec.subinventory;
    p10_a334 := ddx_line_rec.split_from_line_ref;
    p10_a335 := ddx_line_rec.split_from_shipment_ref;
    p10_a336 := ddx_line_rec.ship_to_edi_location_code;
    p10_a337 := ddx_line_rec.bill_to_edi_location_code;
    p10_a338 := ddx_line_rec.ship_from_edi_location_code;
    p10_a339 := rosetta_g_miss_num_map(ddx_line_rec.ship_from_address_id);
    p10_a340 := rosetta_g_miss_num_map(ddx_line_rec.sold_to_address_id);
    p10_a341 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_address_id);
    p10_a342 := rosetta_g_miss_num_map(ddx_line_rec.invoice_address_id);
    p10_a343 := ddx_line_rec.ship_to_address_code;
    p10_a344 := rosetta_g_miss_num_map(ddx_line_rec.original_inventory_item_id);
    p10_a345 := ddx_line_rec.original_item_identifier_type;
    p10_a346 := rosetta_g_miss_num_map(ddx_line_rec.original_ordered_item_id);
    p10_a347 := ddx_line_rec.original_ordered_item;
    p10_a348 := ddx_line_rec.item_substitution_type_code;
    p10_a349 := rosetta_g_miss_num_map(ddx_line_rec.late_demand_penalty_factor);
    p10_a350 := ddx_line_rec.override_atp_date_code;
    p10_a351 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_id);
    p10_a352 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_id);
    p10_a353 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_id);
    p10_a354 := rosetta_g_miss_num_map(ddx_line_rec.accounting_rule_duration);
    p10_a355 := rosetta_g_miss_num_map(ddx_line_rec.unit_cost);
    p10_a356 := ddx_line_rec.user_item_description;
    p10_a357 := ddx_line_rec.xml_transaction_type_code;
    p10_a358 := rosetta_g_miss_num_map(ddx_line_rec.item_relationship_type);
    p10_a359 := rosetta_g_miss_num_map(ddx_line_rec.blanket_number);
    p10_a360 := rosetta_g_miss_num_map(ddx_line_rec.blanket_line_number);
    p10_a361 := rosetta_g_miss_num_map(ddx_line_rec.blanket_version_number);
    p10_a362 := ddx_line_rec.cso_response_flag;
    p10_a363 := ddx_line_rec.firm_demand_flag;
    p10_a364 := ddx_line_rec.earliest_ship_date;
    p10_a365 := ddx_line_rec.transaction_phase_code;
    p10_a366 := rosetta_g_miss_num_map(ddx_line_rec.source_document_version_number);
    p10_a367 := rosetta_g_miss_num_map(ddx_line_rec.minisite_id);
    p10_a368 := ddx_line_rec.ib_owner;
    p10_a369 := ddx_line_rec.ib_installed_at_location;
    p10_a370 := ddx_line_rec.ib_current_location;
    p10_a371 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_id);
    p10_a372 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_contact_id);
    p10_a373 := rosetta_g_miss_num_map(ddx_line_rec.end_customer_site_use_id);
    p10_a374 := ddx_line_rec.supplier_signature;
    p10_a375 := ddx_line_rec.supplier_signature_date;
    p10_a376 := ddx_line_rec.customer_signature;
    p10_a377 := ddx_line_rec.customer_signature_date;
    p10_a378 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_id);
    p10_a379 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_id);
    p10_a380 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_party_site_use_id);
    p10_a381 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_id);
    p10_a382 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_id);
    p10_a383 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_party_site_use_id);
    p10_a384 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_id);
    p10_a385 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_id);
    p10_a386 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_party_site_use_id);
    p10_a387 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_customer_party_id);
    p10_a388 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_customer_party_id);
    p10_a389 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_customer_party_id);
    p10_a390 := rosetta_g_miss_num_map(ddx_line_rec.ship_to_org_contact_id);
    p10_a391 := rosetta_g_miss_num_map(ddx_line_rec.deliver_to_org_contact_id);
    p10_a392 := rosetta_g_miss_num_map(ddx_line_rec.invoice_to_org_contact_id);
    p10_a393 := rosetta_g_miss_num_map(ddx_line_rec.retrobill_request_id);
    p10_a394 := rosetta_g_miss_num_map(ddx_line_rec.original_list_price);
    p10_a395 := rosetta_g_miss_num_map(ddx_line_rec.commitment_applied_amount);

    p11_a0 := rosetta_g_miss_num_map(ddx_old_line_rec.accounting_rule_id);
    p11_a1 := ddx_old_line_rec.actual_arrival_date;
    p11_a2 := ddx_old_line_rec.actual_shipment_date;
    p11_a3 := rosetta_g_miss_num_map(ddx_old_line_rec.agreement_id);
    p11_a4 := rosetta_g_miss_num_map(ddx_old_line_rec.arrival_set_id);
    p11_a5 := rosetta_g_miss_num_map(ddx_old_line_rec.ato_line_id);
    p11_a6 := ddx_old_line_rec.attribute1;
    p11_a7 := ddx_old_line_rec.attribute10;
    p11_a8 := ddx_old_line_rec.attribute11;
    p11_a9 := ddx_old_line_rec.attribute12;
    p11_a10 := ddx_old_line_rec.attribute13;
    p11_a11 := ddx_old_line_rec.attribute14;
    p11_a12 := ddx_old_line_rec.attribute15;
    p11_a13 := ddx_old_line_rec.attribute16;
    p11_a14 := ddx_old_line_rec.attribute17;
    p11_a15 := ddx_old_line_rec.attribute18;
    p11_a16 := ddx_old_line_rec.attribute19;
    p11_a17 := ddx_old_line_rec.attribute2;
    p11_a18 := ddx_old_line_rec.attribute20;
    p11_a19 := ddx_old_line_rec.attribute3;
    p11_a20 := ddx_old_line_rec.attribute4;
    p11_a21 := ddx_old_line_rec.attribute5;
    p11_a22 := ddx_old_line_rec.attribute6;
    p11_a23 := ddx_old_line_rec.attribute7;
    p11_a24 := ddx_old_line_rec.attribute8;
    p11_a25 := ddx_old_line_rec.attribute9;
    p11_a26 := ddx_old_line_rec.authorized_to_ship_flag;
    p11_a27 := rosetta_g_miss_num_map(ddx_old_line_rec.auto_selected_quantity);
    p11_a28 := ddx_old_line_rec.booked_flag;
    p11_a29 := ddx_old_line_rec.cancelled_flag;
    p11_a30 := rosetta_g_miss_num_map(ddx_old_line_rec.cancelled_quantity);
    p11_a31 := rosetta_g_miss_num_map(ddx_old_line_rec.cancelled_quantity2);
    p11_a32 := rosetta_g_miss_num_map(ddx_old_line_rec.commitment_id);
    p11_a33 := ddx_old_line_rec.component_code;
    p11_a34 := rosetta_g_miss_num_map(ddx_old_line_rec.component_number);
    p11_a35 := rosetta_g_miss_num_map(ddx_old_line_rec.component_sequence_id);
    p11_a36 := rosetta_g_miss_num_map(ddx_old_line_rec.config_header_id);
    p11_a37 := rosetta_g_miss_num_map(ddx_old_line_rec.config_rev_nbr);
    p11_a38 := rosetta_g_miss_num_map(ddx_old_line_rec.config_display_sequence);
    p11_a39 := rosetta_g_miss_num_map(ddx_old_line_rec.configuration_id);
    p11_a40 := ddx_old_line_rec.context;
    p11_a41 := rosetta_g_miss_num_map(ddx_old_line_rec.created_by);
    p11_a42 := ddx_old_line_rec.creation_date;
    p11_a43 := rosetta_g_miss_num_map(ddx_old_line_rec.credit_invoice_line_id);
    p11_a44 := ddx_old_line_rec.customer_dock_code;
    p11_a45 := ddx_old_line_rec.customer_job;
    p11_a46 := ddx_old_line_rec.customer_production_line;
    p11_a47 := rosetta_g_miss_num_map(ddx_old_line_rec.customer_trx_line_id);
    p11_a48 := ddx_old_line_rec.cust_model_serial_number;
    p11_a49 := ddx_old_line_rec.cust_po_number;
    p11_a50 := ddx_old_line_rec.cust_production_seq_num;
    p11_a51 := rosetta_g_miss_num_map(ddx_old_line_rec.delivery_lead_time);
    p11_a52 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_contact_id);
    p11_a53 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_org_id);
    p11_a54 := ddx_old_line_rec.demand_bucket_type_code;
    p11_a55 := ddx_old_line_rec.demand_class_code;
    p11_a56 := ddx_old_line_rec.dep_plan_required_flag;
    p11_a57 := ddx_old_line_rec.earliest_acceptable_date;
    p11_a58 := ddx_old_line_rec.end_item_unit_number;
    p11_a59 := ddx_old_line_rec.explosion_date;
    p11_a60 := ddx_old_line_rec.fob_point_code;
    p11_a61 := ddx_old_line_rec.freight_carrier_code;
    p11_a62 := ddx_old_line_rec.freight_terms_code;
    p11_a63 := rosetta_g_miss_num_map(ddx_old_line_rec.fulfilled_quantity);
    p11_a64 := rosetta_g_miss_num_map(ddx_old_line_rec.fulfilled_quantity2);
    p11_a65 := ddx_old_line_rec.global_attribute1;
    p11_a66 := ddx_old_line_rec.global_attribute10;
    p11_a67 := ddx_old_line_rec.global_attribute11;
    p11_a68 := ddx_old_line_rec.global_attribute12;
    p11_a69 := ddx_old_line_rec.global_attribute13;
    p11_a70 := ddx_old_line_rec.global_attribute14;
    p11_a71 := ddx_old_line_rec.global_attribute15;
    p11_a72 := ddx_old_line_rec.global_attribute16;
    p11_a73 := ddx_old_line_rec.global_attribute17;
    p11_a74 := ddx_old_line_rec.global_attribute18;
    p11_a75 := ddx_old_line_rec.global_attribute19;
    p11_a76 := ddx_old_line_rec.global_attribute2;
    p11_a77 := ddx_old_line_rec.global_attribute20;
    p11_a78 := ddx_old_line_rec.global_attribute3;
    p11_a79 := ddx_old_line_rec.global_attribute4;
    p11_a80 := ddx_old_line_rec.global_attribute5;
    p11_a81 := ddx_old_line_rec.global_attribute6;
    p11_a82 := ddx_old_line_rec.global_attribute7;
    p11_a83 := ddx_old_line_rec.global_attribute8;
    p11_a84 := ddx_old_line_rec.global_attribute9;
    p11_a85 := ddx_old_line_rec.global_attribute_category;
    p11_a86 := rosetta_g_miss_num_map(ddx_old_line_rec.header_id);
    p11_a87 := ddx_old_line_rec.industry_attribute1;
    p11_a88 := ddx_old_line_rec.industry_attribute10;
    p11_a89 := ddx_old_line_rec.industry_attribute11;
    p11_a90 := ddx_old_line_rec.industry_attribute12;
    p11_a91 := ddx_old_line_rec.industry_attribute13;
    p11_a92 := ddx_old_line_rec.industry_attribute14;
    p11_a93 := ddx_old_line_rec.industry_attribute15;
    p11_a94 := ddx_old_line_rec.industry_attribute16;
    p11_a95 := ddx_old_line_rec.industry_attribute17;
    p11_a96 := ddx_old_line_rec.industry_attribute18;
    p11_a97 := ddx_old_line_rec.industry_attribute19;
    p11_a98 := ddx_old_line_rec.industry_attribute20;
    p11_a99 := ddx_old_line_rec.industry_attribute21;
    p11_a100 := ddx_old_line_rec.industry_attribute22;
    p11_a101 := ddx_old_line_rec.industry_attribute23;
    p11_a102 := ddx_old_line_rec.industry_attribute24;
    p11_a103 := ddx_old_line_rec.industry_attribute25;
    p11_a104 := ddx_old_line_rec.industry_attribute26;
    p11_a105 := ddx_old_line_rec.industry_attribute27;
    p11_a106 := ddx_old_line_rec.industry_attribute28;
    p11_a107 := ddx_old_line_rec.industry_attribute29;
    p11_a108 := ddx_old_line_rec.industry_attribute30;
    p11_a109 := ddx_old_line_rec.industry_attribute2;
    p11_a110 := ddx_old_line_rec.industry_attribute3;
    p11_a111 := ddx_old_line_rec.industry_attribute4;
    p11_a112 := ddx_old_line_rec.industry_attribute5;
    p11_a113 := ddx_old_line_rec.industry_attribute6;
    p11_a114 := ddx_old_line_rec.industry_attribute7;
    p11_a115 := ddx_old_line_rec.industry_attribute8;
    p11_a116 := ddx_old_line_rec.industry_attribute9;
    p11_a117 := ddx_old_line_rec.industry_context;
    p11_a118 := ddx_old_line_rec.tp_context;
    p11_a119 := ddx_old_line_rec.tp_attribute1;
    p11_a120 := ddx_old_line_rec.tp_attribute2;
    p11_a121 := ddx_old_line_rec.tp_attribute3;
    p11_a122 := ddx_old_line_rec.tp_attribute4;
    p11_a123 := ddx_old_line_rec.tp_attribute5;
    p11_a124 := ddx_old_line_rec.tp_attribute6;
    p11_a125 := ddx_old_line_rec.tp_attribute7;
    p11_a126 := ddx_old_line_rec.tp_attribute8;
    p11_a127 := ddx_old_line_rec.tp_attribute9;
    p11_a128 := ddx_old_line_rec.tp_attribute10;
    p11_a129 := ddx_old_line_rec.tp_attribute11;
    p11_a130 := ddx_old_line_rec.tp_attribute12;
    p11_a131 := ddx_old_line_rec.tp_attribute13;
    p11_a132 := ddx_old_line_rec.tp_attribute14;
    p11_a133 := ddx_old_line_rec.tp_attribute15;
    p11_a134 := rosetta_g_miss_num_map(ddx_old_line_rec.intermed_ship_to_org_id);
    p11_a135 := rosetta_g_miss_num_map(ddx_old_line_rec.intermed_ship_to_contact_id);
    p11_a136 := rosetta_g_miss_num_map(ddx_old_line_rec.inventory_item_id);
    p11_a137 := ddx_old_line_rec.invoice_interface_status_code;
    p11_a138 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_contact_id);
    p11_a139 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_org_id);
    p11_a140 := rosetta_g_miss_num_map(ddx_old_line_rec.invoicing_rule_id);
    p11_a141 := ddx_old_line_rec.ordered_item;
    p11_a142 := ddx_old_line_rec.item_revision;
    p11_a143 := ddx_old_line_rec.item_type_code;
    p11_a144 := rosetta_g_miss_num_map(ddx_old_line_rec.last_updated_by);
    p11_a145 := ddx_old_line_rec.last_update_date;
    p11_a146 := rosetta_g_miss_num_map(ddx_old_line_rec.last_update_login);
    p11_a147 := ddx_old_line_rec.latest_acceptable_date;
    p11_a148 := ddx_old_line_rec.line_category_code;
    p11_a149 := rosetta_g_miss_num_map(ddx_old_line_rec.line_id);
    p11_a150 := rosetta_g_miss_num_map(ddx_old_line_rec.line_number);
    p11_a151 := rosetta_g_miss_num_map(ddx_old_line_rec.line_type_id);
    p11_a152 := ddx_old_line_rec.link_to_line_ref;
    p11_a153 := rosetta_g_miss_num_map(ddx_old_line_rec.link_to_line_id);
    p11_a154 := rosetta_g_miss_num_map(ddx_old_line_rec.link_to_line_index);
    p11_a155 := rosetta_g_miss_num_map(ddx_old_line_rec.model_group_number);
    p11_a156 := rosetta_g_miss_num_map(ddx_old_line_rec.mfg_component_sequence_id);
    p11_a157 := rosetta_g_miss_num_map(ddx_old_line_rec.mfg_lead_time);
    p11_a158 := ddx_old_line_rec.open_flag;
    p11_a159 := ddx_old_line_rec.option_flag;
    p11_a160 := rosetta_g_miss_num_map(ddx_old_line_rec.option_number);
    p11_a161 := rosetta_g_miss_num_map(ddx_old_line_rec.ordered_quantity);
    p11_a162 := rosetta_g_miss_num_map(ddx_old_line_rec.ordered_quantity2);
    p11_a163 := ddx_old_line_rec.order_quantity_uom;
    p11_a164 := ddx_old_line_rec.ordered_quantity_uom2;
    p11_a165 := rosetta_g_miss_num_map(ddx_old_line_rec.org_id);
    p11_a166 := ddx_old_line_rec.orig_sys_document_ref;
    p11_a167 := ddx_old_line_rec.orig_sys_line_ref;
    p11_a168 := ddx_old_line_rec.over_ship_reason_code;
    p11_a169 := ddx_old_line_rec.over_ship_resolved_flag;
    p11_a170 := rosetta_g_miss_num_map(ddx_old_line_rec.payment_term_id);
    p11_a171 := rosetta_g_miss_num_map(ddx_old_line_rec.planning_priority);
    p11_a172 := ddx_old_line_rec.preferred_grade;
    p11_a173 := rosetta_g_miss_num_map(ddx_old_line_rec.price_list_id);
    p11_a174 := ddx_old_line_rec.price_request_code;
    p11_a175 := ddx_old_line_rec.pricing_attribute1;
    p11_a176 := ddx_old_line_rec.pricing_attribute10;
    p11_a177 := ddx_old_line_rec.pricing_attribute2;
    p11_a178 := ddx_old_line_rec.pricing_attribute3;
    p11_a179 := ddx_old_line_rec.pricing_attribute4;
    p11_a180 := ddx_old_line_rec.pricing_attribute5;
    p11_a181 := ddx_old_line_rec.pricing_attribute6;
    p11_a182 := ddx_old_line_rec.pricing_attribute7;
    p11_a183 := ddx_old_line_rec.pricing_attribute8;
    p11_a184 := ddx_old_line_rec.pricing_attribute9;
    p11_a185 := ddx_old_line_rec.pricing_context;
    p11_a186 := ddx_old_line_rec.pricing_date;
    p11_a187 := rosetta_g_miss_num_map(ddx_old_line_rec.pricing_quantity);
    p11_a188 := ddx_old_line_rec.pricing_quantity_uom;
    p11_a189 := rosetta_g_miss_num_map(ddx_old_line_rec.program_application_id);
    p11_a190 := rosetta_g_miss_num_map(ddx_old_line_rec.program_id);
    p11_a191 := ddx_old_line_rec.program_update_date;
    p11_a192 := rosetta_g_miss_num_map(ddx_old_line_rec.project_id);
    p11_a193 := ddx_old_line_rec.promise_date;
    p11_a194 := ddx_old_line_rec.re_source_flag;
    p11_a195 := rosetta_g_miss_num_map(ddx_old_line_rec.reference_customer_trx_line_id);
    p11_a196 := rosetta_g_miss_num_map(ddx_old_line_rec.reference_header_id);
    p11_a197 := rosetta_g_miss_num_map(ddx_old_line_rec.reference_line_id);
    p11_a198 := ddx_old_line_rec.reference_type;
    p11_a199 := ddx_old_line_rec.request_date;
    p11_a200 := rosetta_g_miss_num_map(ddx_old_line_rec.request_id);
    p11_a201 := rosetta_g_miss_num_map(ddx_old_line_rec.reserved_quantity);
    p11_a202 := ddx_old_line_rec.return_attribute1;
    p11_a203 := ddx_old_line_rec.return_attribute10;
    p11_a204 := ddx_old_line_rec.return_attribute11;
    p11_a205 := ddx_old_line_rec.return_attribute12;
    p11_a206 := ddx_old_line_rec.return_attribute13;
    p11_a207 := ddx_old_line_rec.return_attribute14;
    p11_a208 := ddx_old_line_rec.return_attribute15;
    p11_a209 := ddx_old_line_rec.return_attribute2;
    p11_a210 := ddx_old_line_rec.return_attribute3;
    p11_a211 := ddx_old_line_rec.return_attribute4;
    p11_a212 := ddx_old_line_rec.return_attribute5;
    p11_a213 := ddx_old_line_rec.return_attribute6;
    p11_a214 := ddx_old_line_rec.return_attribute7;
    p11_a215 := ddx_old_line_rec.return_attribute8;
    p11_a216 := ddx_old_line_rec.return_attribute9;
    p11_a217 := ddx_old_line_rec.return_context;
    p11_a218 := ddx_old_line_rec.return_reason_code;
    p11_a219 := ddx_old_line_rec.rla_schedule_type_code;
    p11_a220 := rosetta_g_miss_num_map(ddx_old_line_rec.salesrep_id);
    p11_a221 := ddx_old_line_rec.schedule_arrival_date;
    p11_a222 := ddx_old_line_rec.schedule_ship_date;
    p11_a223 := ddx_old_line_rec.schedule_action_code;
    p11_a224 := ddx_old_line_rec.schedule_status_code;
    p11_a225 := rosetta_g_miss_num_map(ddx_old_line_rec.shipment_number);
    p11_a226 := ddx_old_line_rec.shipment_priority_code;
    p11_a227 := rosetta_g_miss_num_map(ddx_old_line_rec.shipped_quantity);
    p11_a228 := rosetta_g_miss_num_map(ddx_old_line_rec.shipped_quantity2);
    p11_a229 := ddx_old_line_rec.shipping_interfaced_flag;
    p11_a230 := ddx_old_line_rec.shipping_method_code;
    p11_a231 := rosetta_g_miss_num_map(ddx_old_line_rec.shipping_quantity);
    p11_a232 := rosetta_g_miss_num_map(ddx_old_line_rec.shipping_quantity2);
    p11_a233 := ddx_old_line_rec.shipping_quantity_uom;
    p11_a234 := ddx_old_line_rec.shipping_quantity_uom2;
    p11_a235 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_from_org_id);
    p11_a236 := ddx_old_line_rec.ship_model_complete_flag;
    p11_a237 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_set_id);
    p11_a238 := rosetta_g_miss_num_map(ddx_old_line_rec.fulfillment_set_id);
    p11_a239 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_tolerance_above);
    p11_a240 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_tolerance_below);
    p11_a241 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_contact_id);
    p11_a242 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_org_id);
    p11_a243 := rosetta_g_miss_num_map(ddx_old_line_rec.sold_to_org_id);
    p11_a244 := rosetta_g_miss_num_map(ddx_old_line_rec.sold_from_org_id);
    p11_a245 := ddx_old_line_rec.sort_order;
    p11_a246 := rosetta_g_miss_num_map(ddx_old_line_rec.source_document_id);
    p11_a247 := rosetta_g_miss_num_map(ddx_old_line_rec.source_document_line_id);
    p11_a248 := rosetta_g_miss_num_map(ddx_old_line_rec.source_document_type_id);
    p11_a249 := ddx_old_line_rec.source_type_code;
    p11_a250 := rosetta_g_miss_num_map(ddx_old_line_rec.split_from_line_id);
    p11_a251 := rosetta_g_miss_num_map(ddx_old_line_rec.task_id);
    p11_a252 := ddx_old_line_rec.tax_code;
    p11_a253 := ddx_old_line_rec.tax_date;
    p11_a254 := ddx_old_line_rec.tax_exempt_flag;
    p11_a255 := ddx_old_line_rec.tax_exempt_number;
    p11_a256 := ddx_old_line_rec.tax_exempt_reason_code;
    p11_a257 := ddx_old_line_rec.tax_point_code;
    p11_a258 := rosetta_g_miss_num_map(ddx_old_line_rec.tax_rate);
    p11_a259 := rosetta_g_miss_num_map(ddx_old_line_rec.tax_value);
    p11_a260 := ddx_old_line_rec.top_model_line_ref;
    p11_a261 := rosetta_g_miss_num_map(ddx_old_line_rec.top_model_line_id);
    p11_a262 := rosetta_g_miss_num_map(ddx_old_line_rec.top_model_line_index);
    p11_a263 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_list_price);
    p11_a264 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_list_price_per_pqty);
    p11_a265 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_selling_price);
    p11_a266 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_selling_price_per_pqty);
    p11_a267 := rosetta_g_miss_num_map(ddx_old_line_rec.veh_cus_item_cum_key_id);
    p11_a268 := ddx_old_line_rec.visible_demand_flag;
    p11_a269 := ddx_old_line_rec.return_status;
    p11_a270 := ddx_old_line_rec.db_flag;
    p11_a271 := ddx_old_line_rec.operation;
    p11_a272 := ddx_old_line_rec.first_ack_code;
    p11_a273 := ddx_old_line_rec.first_ack_date;
    p11_a274 := ddx_old_line_rec.last_ack_code;
    p11_a275 := ddx_old_line_rec.last_ack_date;
    p11_a276 := ddx_old_line_rec.change_reason;
    p11_a277 := ddx_old_line_rec.change_comments;
    p11_a278 := ddx_old_line_rec.arrival_set;
    p11_a279 := ddx_old_line_rec.ship_set;
    p11_a280 := ddx_old_line_rec.fulfillment_set;
    p11_a281 := rosetta_g_miss_num_map(ddx_old_line_rec.order_source_id);
    p11_a282 := ddx_old_line_rec.orig_sys_shipment_ref;
    p11_a283 := ddx_old_line_rec.change_sequence;
    p11_a284 := ddx_old_line_rec.change_request_code;
    p11_a285 := ddx_old_line_rec.status_flag;
    p11_a286 := ddx_old_line_rec.drop_ship_flag;
    p11_a287 := ddx_old_line_rec.customer_line_number;
    p11_a288 := ddx_old_line_rec.customer_shipment_number;
    p11_a289 := rosetta_g_miss_num_map(ddx_old_line_rec.customer_item_net_price);
    p11_a290 := rosetta_g_miss_num_map(ddx_old_line_rec.customer_payment_term_id);
    p11_a291 := rosetta_g_miss_num_map(ddx_old_line_rec.ordered_item_id);
    p11_a292 := ddx_old_line_rec.item_identifier_type;
    p11_a293 := ddx_old_line_rec.shipping_instructions;
    p11_a294 := ddx_old_line_rec.packing_instructions;
    p11_a295 := ddx_old_line_rec.calculate_price_flag;
    p11_a296 := rosetta_g_miss_num_map(ddx_old_line_rec.invoiced_quantity);
    p11_a297 := ddx_old_line_rec.service_txn_reason_code;
    p11_a298 := ddx_old_line_rec.service_txn_comments;
    p11_a299 := rosetta_g_miss_num_map(ddx_old_line_rec.service_duration);
    p11_a300 := ddx_old_line_rec.service_period;
    p11_a301 := ddx_old_line_rec.service_start_date;
    p11_a302 := ddx_old_line_rec.service_end_date;
    p11_a303 := ddx_old_line_rec.service_coterminate_flag;
    p11_a304 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_list_percent);
    p11_a305 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_selling_percent);
    p11_a306 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_percent_base_price);
    p11_a307 := rosetta_g_miss_num_map(ddx_old_line_rec.service_number);
    p11_a308 := ddx_old_line_rec.service_reference_type_code;
    p11_a309 := rosetta_g_miss_num_map(ddx_old_line_rec.service_reference_line_id);
    p11_a310 := rosetta_g_miss_num_map(ddx_old_line_rec.service_reference_system_id);
    p11_a311 := rosetta_g_miss_num_map(ddx_old_line_rec.service_ref_order_number);
    p11_a312 := rosetta_g_miss_num_map(ddx_old_line_rec.service_ref_line_number);
    p11_a313 := ddx_old_line_rec.service_reference_order;
    p11_a314 := ddx_old_line_rec.service_reference_line;
    p11_a315 := ddx_old_line_rec.service_reference_system;
    p11_a316 := rosetta_g_miss_num_map(ddx_old_line_rec.service_ref_shipment_number);
    p11_a317 := rosetta_g_miss_num_map(ddx_old_line_rec.service_ref_option_number);
    p11_a318 := rosetta_g_miss_num_map(ddx_old_line_rec.service_line_index);
    p11_a319 := rosetta_g_miss_num_map(ddx_old_line_rec.line_set_id);
    p11_a320 := ddx_old_line_rec.split_by;
    p11_a321 := ddx_old_line_rec.split_action_code;
    p11_a322 := ddx_old_line_rec.shippable_flag;
    p11_a323 := ddx_old_line_rec.model_remnant_flag;
    p11_a324 := ddx_old_line_rec.flow_status_code;
    p11_a325 := ddx_old_line_rec.fulfilled_flag;
    p11_a326 := ddx_old_line_rec.fulfillment_method_code;
    p11_a327 := rosetta_g_miss_num_map(ddx_old_line_rec.revenue_amount);
    p11_a328 := rosetta_g_miss_num_map(ddx_old_line_rec.marketing_source_code_id);
    p11_a329 := ddx_old_line_rec.fulfillment_date;
    if ddx_old_line_rec.semi_processed_flag is null
      then p11_a330 := null;
    elsif ddx_old_line_rec.semi_processed_flag
      then p11_a330 := 1;
    else p11_a330 := 0;
    end if;
    p11_a331 := ddx_old_line_rec.upgraded_flag;
    p11_a332 := rosetta_g_miss_num_map(ddx_old_line_rec.lock_control);
    p11_a333 := ddx_old_line_rec.subinventory;
    p11_a334 := ddx_old_line_rec.split_from_line_ref;
    p11_a335 := ddx_old_line_rec.split_from_shipment_ref;
    p11_a336 := ddx_old_line_rec.ship_to_edi_location_code;
    p11_a337 := ddx_old_line_rec.bill_to_edi_location_code;
    p11_a338 := ddx_old_line_rec.ship_from_edi_location_code;
    p11_a339 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_from_address_id);
    p11_a340 := rosetta_g_miss_num_map(ddx_old_line_rec.sold_to_address_id);
    p11_a341 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_address_id);
    p11_a342 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_address_id);
    p11_a343 := ddx_old_line_rec.ship_to_address_code;
    p11_a344 := rosetta_g_miss_num_map(ddx_old_line_rec.original_inventory_item_id);
    p11_a345 := ddx_old_line_rec.original_item_identifier_type;
    p11_a346 := rosetta_g_miss_num_map(ddx_old_line_rec.original_ordered_item_id);
    p11_a347 := ddx_old_line_rec.original_ordered_item;
    p11_a348 := ddx_old_line_rec.item_substitution_type_code;
    p11_a349 := rosetta_g_miss_num_map(ddx_old_line_rec.late_demand_penalty_factor);
    p11_a350 := ddx_old_line_rec.override_atp_date_code;
    p11_a351 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_customer_id);
    p11_a352 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_customer_id);
    p11_a353 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_customer_id);
    p11_a354 := rosetta_g_miss_num_map(ddx_old_line_rec.accounting_rule_duration);
    p11_a355 := rosetta_g_miss_num_map(ddx_old_line_rec.unit_cost);
    p11_a356 := ddx_old_line_rec.user_item_description;
    p11_a357 := ddx_old_line_rec.xml_transaction_type_code;
    p11_a358 := rosetta_g_miss_num_map(ddx_old_line_rec.item_relationship_type);
    p11_a359 := rosetta_g_miss_num_map(ddx_old_line_rec.blanket_number);
    p11_a360 := rosetta_g_miss_num_map(ddx_old_line_rec.blanket_line_number);
    p11_a361 := rosetta_g_miss_num_map(ddx_old_line_rec.blanket_version_number);
    p11_a362 := ddx_old_line_rec.cso_response_flag;
    p11_a363 := ddx_old_line_rec.firm_demand_flag;
    p11_a364 := ddx_old_line_rec.earliest_ship_date;
    p11_a365 := ddx_old_line_rec.transaction_phase_code;
    p11_a366 := rosetta_g_miss_num_map(ddx_old_line_rec.source_document_version_number);
    p11_a367 := rosetta_g_miss_num_map(ddx_old_line_rec.minisite_id);
    p11_a368 := ddx_old_line_rec.ib_owner;
    p11_a369 := ddx_old_line_rec.ib_installed_at_location;
    p11_a370 := ddx_old_line_rec.ib_current_location;
    p11_a371 := rosetta_g_miss_num_map(ddx_old_line_rec.end_customer_id);
    p11_a372 := rosetta_g_miss_num_map(ddx_old_line_rec.end_customer_contact_id);
    p11_a373 := rosetta_g_miss_num_map(ddx_old_line_rec.end_customer_site_use_id);
    p11_a374 := ddx_old_line_rec.supplier_signature;
    p11_a375 := ddx_old_line_rec.supplier_signature_date;
    p11_a376 := ddx_old_line_rec.customer_signature;
    p11_a377 := ddx_old_line_rec.customer_signature_date;
    p11_a378 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_party_id);
    p11_a379 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_party_site_id);
    p11_a380 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_party_site_use_id);
    p11_a381 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_party_id);
    p11_a382 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_party_site_id);
    p11_a383 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_party_site_use_id);
    p11_a384 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_party_id);
    p11_a385 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_party_site_id);
    p11_a386 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_party_site_use_id);
    p11_a387 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_customer_party_id);
    p11_a388 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_customer_party_id);
    p11_a389 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_customer_party_id);
    p11_a390 := rosetta_g_miss_num_map(ddx_old_line_rec.ship_to_org_contact_id);
    p11_a391 := rosetta_g_miss_num_map(ddx_old_line_rec.deliver_to_org_contact_id);
    p11_a392 := rosetta_g_miss_num_map(ddx_old_line_rec.invoice_to_org_contact_id);
    p11_a393 := rosetta_g_miss_num_map(ddx_old_line_rec.retrobill_request_id);
    p11_a394 := rosetta_g_miss_num_map(ddx_old_line_rec.original_list_price);
    p11_a395 := rosetta_g_miss_num_map(ddx_old_line_rec.commitment_applied_amount);

    p12_a0 := ddx_line_val_rec.accounting_rule;
    p12_a1 := ddx_line_val_rec.agreement;
    p12_a2 := ddx_line_val_rec.commitment;
    p12_a3 := rosetta_g_miss_num_map(ddx_line_val_rec.commitment_applied_amount);
    p12_a4 := ddx_line_val_rec.deliver_to_address1;
    p12_a5 := ddx_line_val_rec.deliver_to_address2;
    p12_a6 := ddx_line_val_rec.deliver_to_address3;
    p12_a7 := ddx_line_val_rec.deliver_to_address4;
    p12_a8 := ddx_line_val_rec.deliver_to_contact;
    p12_a9 := ddx_line_val_rec.deliver_to_location;
    p12_a10 := ddx_line_val_rec.deliver_to_org;
    p12_a11 := ddx_line_val_rec.deliver_to_state;
    p12_a12 := ddx_line_val_rec.deliver_to_city;
    p12_a13 := ddx_line_val_rec.deliver_to_zip;
    p12_a14 := ddx_line_val_rec.deliver_to_country;
    p12_a15 := ddx_line_val_rec.deliver_to_county;
    p12_a16 := ddx_line_val_rec.deliver_to_province;
    p12_a17 := ddx_line_val_rec.demand_class;
    p12_a18 := ddx_line_val_rec.demand_bucket_type;
    p12_a19 := ddx_line_val_rec.fob_point;
    p12_a20 := ddx_line_val_rec.freight_terms;
    p12_a21 := ddx_line_val_rec.inventory_item;
    p12_a22 := ddx_line_val_rec.invoice_to_address1;
    p12_a23 := ddx_line_val_rec.invoice_to_address2;
    p12_a24 := ddx_line_val_rec.invoice_to_address3;
    p12_a25 := ddx_line_val_rec.invoice_to_address4;
    p12_a26 := ddx_line_val_rec.invoice_to_contact;
    p12_a27 := ddx_line_val_rec.invoice_to_location;
    p12_a28 := ddx_line_val_rec.invoice_to_org;
    p12_a29 := ddx_line_val_rec.invoice_to_state;
    p12_a30 := ddx_line_val_rec.invoice_to_city;
    p12_a31 := ddx_line_val_rec.invoice_to_zip;
    p12_a32 := ddx_line_val_rec.invoice_to_country;
    p12_a33 := ddx_line_val_rec.invoice_to_county;
    p12_a34 := ddx_line_val_rec.invoice_to_province;
    p12_a35 := ddx_line_val_rec.invoicing_rule;
    p12_a36 := ddx_line_val_rec.item_type;
    p12_a37 := ddx_line_val_rec.line_type;
    p12_a38 := ddx_line_val_rec.over_ship_reason;
    p12_a39 := ddx_line_val_rec.payment_term;
    p12_a40 := ddx_line_val_rec.price_list;
    p12_a41 := ddx_line_val_rec.project;
    p12_a42 := ddx_line_val_rec.return_reason;
    p12_a43 := ddx_line_val_rec.rla_schedule_type;
    p12_a44 := ddx_line_val_rec.salesrep;
    p12_a45 := ddx_line_val_rec.shipment_priority;
    p12_a46 := ddx_line_val_rec.ship_from_address1;
    p12_a47 := ddx_line_val_rec.ship_from_address2;
    p12_a48 := ddx_line_val_rec.ship_from_address3;
    p12_a49 := ddx_line_val_rec.ship_from_address4;
    p12_a50 := ddx_line_val_rec.ship_from_location;
    p12_a51 := ddx_line_val_rec.ship_from_city;
    p12_a52 := ddx_line_val_rec.ship_from_postal_code;
    p12_a53 := ddx_line_val_rec.ship_from_country;
    p12_a54 := ddx_line_val_rec.ship_from_region1;
    p12_a55 := ddx_line_val_rec.ship_from_region2;
    p12_a56 := ddx_line_val_rec.ship_from_region3;
    p12_a57 := ddx_line_val_rec.ship_from_org;
    p12_a58 := ddx_line_val_rec.ship_to_address1;
    p12_a59 := ddx_line_val_rec.ship_to_address2;
    p12_a60 := ddx_line_val_rec.ship_to_address3;
    p12_a61 := ddx_line_val_rec.ship_to_address4;
    p12_a62 := ddx_line_val_rec.ship_to_state;
    p12_a63 := ddx_line_val_rec.ship_to_country;
    p12_a64 := ddx_line_val_rec.ship_to_zip;
    p12_a65 := ddx_line_val_rec.ship_to_county;
    p12_a66 := ddx_line_val_rec.ship_to_province;
    p12_a67 := ddx_line_val_rec.ship_to_city;
    p12_a68 := ddx_line_val_rec.ship_to_contact;
    p12_a69 := ddx_line_val_rec.ship_to_contact_last_name;
    p12_a70 := ddx_line_val_rec.ship_to_contact_first_name;
    p12_a71 := ddx_line_val_rec.ship_to_location;
    p12_a72 := ddx_line_val_rec.ship_to_org;
    p12_a73 := ddx_line_val_rec.source_type;
    p12_a74 := ddx_line_val_rec.intermed_ship_to_address1;
    p12_a75 := ddx_line_val_rec.intermed_ship_to_address2;
    p12_a76 := ddx_line_val_rec.intermed_ship_to_address3;
    p12_a77 := ddx_line_val_rec.intermed_ship_to_address4;
    p12_a78 := ddx_line_val_rec.intermed_ship_to_contact;
    p12_a79 := ddx_line_val_rec.intermed_ship_to_location;
    p12_a80 := ddx_line_val_rec.intermed_ship_to_org;
    p12_a81 := ddx_line_val_rec.intermed_ship_to_state;
    p12_a82 := ddx_line_val_rec.intermed_ship_to_city;
    p12_a83 := ddx_line_val_rec.intermed_ship_to_zip;
    p12_a84 := ddx_line_val_rec.intermed_ship_to_country;
    p12_a85 := ddx_line_val_rec.intermed_ship_to_county;
    p12_a86 := ddx_line_val_rec.intermed_ship_to_province;
    p12_a87 := ddx_line_val_rec.sold_to_org;
    p12_a88 := ddx_line_val_rec.sold_from_org;
    p12_a89 := ddx_line_val_rec.task;
    p12_a90 := ddx_line_val_rec.tax_exempt;
    p12_a91 := ddx_line_val_rec.tax_exempt_reason;
    p12_a92 := ddx_line_val_rec.tax_point;
    p12_a93 := ddx_line_val_rec.veh_cus_item_cum_key;
    p12_a94 := ddx_line_val_rec.visible_demand;
    p12_a95 := ddx_line_val_rec.customer_payment_term;
    p12_a96 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_order_number);
    p12_a97 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_line_number);
    p12_a98 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_shipment_number);
    p12_a99 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_option_number);
    p12_a100 := ddx_line_val_rec.ref_invoice_number;
    p12_a101 := rosetta_g_miss_num_map(ddx_line_val_rec.ref_invoice_line_number);
    p12_a102 := ddx_line_val_rec.credit_invoice_number;
    p12_a103 := ddx_line_val_rec.tax_group;
    p12_a104 := ddx_line_val_rec.status;
    p12_a105 := ddx_line_val_rec.freight_carrier;
    p12_a106 := ddx_line_val_rec.shipping_method;
    p12_a107 := ddx_line_val_rec.calculate_price_descr;
    p12_a108 := ddx_line_val_rec.ship_to_customer_name;
    p12_a109 := ddx_line_val_rec.invoice_to_customer_name;
    p12_a110 := ddx_line_val_rec.ship_to_customer_number;
    p12_a111 := ddx_line_val_rec.invoice_to_customer_number;
    p12_a112 := rosetta_g_miss_num_map(ddx_line_val_rec.ship_to_customer_id);
    p12_a113 := rosetta_g_miss_num_map(ddx_line_val_rec.invoice_to_customer_id);
    p12_a114 := rosetta_g_miss_num_map(ddx_line_val_rec.deliver_to_customer_id);
    p12_a115 := ddx_line_val_rec.deliver_to_customer_number;
    p12_a116 := ddx_line_val_rec.deliver_to_customer_name;
    p12_a117 := ddx_line_val_rec.original_ordered_item;
    p12_a118 := ddx_line_val_rec.original_inventory_item;
    p12_a119 := ddx_line_val_rec.original_item_identifier_type;
    p12_a120 := ddx_line_val_rec.deliver_to_customer_number_oi;
    p12_a121 := ddx_line_val_rec.deliver_to_customer_name_oi;
    p12_a122 := ddx_line_val_rec.ship_to_customer_number_oi;
    p12_a123 := ddx_line_val_rec.ship_to_customer_name_oi;
    p12_a124 := ddx_line_val_rec.invoice_to_customer_number_oi;
    p12_a125 := ddx_line_val_rec.invoice_to_customer_name_oi;
    p12_a126 := ddx_line_val_rec.item_relationship_type_dsp;
    p12_a127 := ddx_line_val_rec.transaction_phase;
    p12_a128 := ddx_line_val_rec.end_customer_name;
    p12_a129 := ddx_line_val_rec.end_customer_number;
    p12_a130 := ddx_line_val_rec.end_customer_contact;
    p12_a131 := ddx_line_val_rec.end_cust_contact_last_name;
    p12_a132 := ddx_line_val_rec.end_cust_contact_first_name;
    p12_a133 := ddx_line_val_rec.end_customer_site_address1;
    p12_a134 := ddx_line_val_rec.end_customer_site_address2;
    p12_a135 := ddx_line_val_rec.end_customer_site_address3;
    p12_a136 := ddx_line_val_rec.end_customer_site_address4;
    p12_a137 := ddx_line_val_rec.end_customer_site_location;
    p12_a138 := ddx_line_val_rec.end_customer_site_state;
    p12_a139 := ddx_line_val_rec.end_customer_site_country;
    p12_a140 := ddx_line_val_rec.end_customer_site_zip;
    p12_a141 := ddx_line_val_rec.end_customer_site_county;
    p12_a142 := ddx_line_val_rec.end_customer_site_province;
    p12_a143 := ddx_line_val_rec.end_customer_site_city;
    p12_a144 := ddx_line_val_rec.end_customer_site_postal_code;
    p12_a145 := ddx_line_val_rec.blanket_agreement_name;
  end;

end oe_oe_html_line_w;

/
