--------------------------------------------------------
--  DDL for Package Body OE_PRICE_ORDER_PVT_W_OBSOLETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_ORDER_PVT_W_OBSOLETE" as
  /* $Header: OERVPROB.pls 115.2 2004/05/19 21:38:12 lchen noship $ */
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

  procedure rosetta_table_copy_in_p3(t out oe_price_order_pvt.price_att_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).header_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).line_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).flex_title := a2(indx);
          t(ddindx).pricing_context := a3(indx);
          t(ddindx).pricing_attribute := a4(indx);
          t(ddindx).pricing_attr_value := a5(indx);
          t(ddindx).override_flag := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t oe_price_order_pvt.price_att_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).header_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).line_id);
          a2(indx) := t(ddindx).flex_title;
          a3(indx) := t(ddindx).pricing_context;
          a4(indx) := t(ddindx).pricing_attribute;
          a5(indx) := t(ddindx).pricing_attr_value;
          a6(indx) := t(ddindx).override_flag;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure price_order(p0_a0 in out  NUMBER
    , p0_a1 in out  NUMBER
    , p0_a2 in out  VARCHAR2
    , p0_a3 in out  VARCHAR2
    , p0_a4 in out  VARCHAR2
    , p0_a5 in out  VARCHAR2
    , p0_a6 in out  VARCHAR2
    , p0_a7 in out  VARCHAR2
    , p0_a8 in out  VARCHAR2
    , p0_a9 in out  VARCHAR2
    , p0_a10 in out  VARCHAR2
    , p0_a11 in out  VARCHAR2
    , p0_a12 in out  VARCHAR2
    , p0_a13 in out  VARCHAR2
    , p0_a14 in out  VARCHAR2
    , p0_a15 in out  VARCHAR2
    , p0_a16 in out  VARCHAR2
    , p0_a17 in out  VARCHAR2
    , p0_a18 in out  VARCHAR2
    , p0_a19 in out  VARCHAR2
    , p0_a20 in out  VARCHAR2
    , p0_a21 in out  VARCHAR2
    , p0_a22 in out  VARCHAR2
    , p0_a23 in out  VARCHAR2
    , p0_a24 in out  VARCHAR2
    , p0_a25 in out  NUMBER
    , p0_a26 in out  DATE
    , p0_a27 in out  VARCHAR2
    , p0_a28 in out  VARCHAR2
    , p0_a29 in out  NUMBER
    , p0_a30 in out  DATE
    , p0_a31 in out  VARCHAR2
    , p0_a32 in out  NUMBER
    , p0_a33 in out  NUMBER
    , p0_a34 in out  VARCHAR2
    , p0_a35 in out  NUMBER
    , p0_a36 in out  DATE
    , p0_a37 in out  VARCHAR2
    , p0_a38 in out  VARCHAR2
    , p0_a39 in out  VARCHAR2
    , p0_a40 in out  VARCHAR2
    , p0_a41 in out  VARCHAR2
    , p0_a42 in out  VARCHAR2
    , p0_a43 in out  VARCHAR2
    , p0_a44 in out  VARCHAR2
    , p0_a45 in out  VARCHAR2
    , p0_a46 in out  VARCHAR2
    , p0_a47 in out  VARCHAR2
    , p0_a48 in out  VARCHAR2
    , p0_a49 in out  VARCHAR2
    , p0_a50 in out  VARCHAR2
    , p0_a51 in out  VARCHAR2
    , p0_a52 in out  VARCHAR2
    , p0_a53 in out  VARCHAR2
    , p0_a54 in out  VARCHAR2
    , p0_a55 in out  VARCHAR2
    , p0_a56 in out  VARCHAR2
    , p0_a57 in out  VARCHAR2
    , p0_a58 in out  VARCHAR2
    , p0_a59 in out  VARCHAR2
    , p0_a60 in out  VARCHAR2
    , p0_a61 in out  VARCHAR2
    , p0_a62 in out  VARCHAR2
    , p0_a63 in out  VARCHAR2
    , p0_a64 in out  VARCHAR2
    , p0_a65 in out  VARCHAR2
    , p0_a66 in out  VARCHAR2
    , p0_a67 in out  VARCHAR2
    , p0_a68 in out  VARCHAR2
    , p0_a69 in out  VARCHAR2
    , p0_a70 in out  VARCHAR2
    , p0_a71 in out  VARCHAR2
    , p0_a72 in out  VARCHAR2
    , p0_a73 in out  VARCHAR2
    , p0_a74 in out  VARCHAR2
    , p0_a75 in out  VARCHAR2
    , p0_a76 in out  VARCHAR2
    , p0_a77 in out  NUMBER
    , p0_a78 in out  NUMBER
    , p0_a79 in out  NUMBER
    , p0_a80 in out  NUMBER
    , p0_a81 in out  NUMBER
    , p0_a82 in out  DATE
    , p0_a83 in out  NUMBER
    , p0_a84 in out  NUMBER
    , p0_a85 in out  VARCHAR2
    , p0_a86 in out  VARCHAR2
    , p0_a87 in out  DATE
    , p0_a88 in out  VARCHAR2
    , p0_a89 in out  NUMBER
    , p0_a90 in out  NUMBER
    , p0_a91 in out  NUMBER
    , p0_a92 in out  NUMBER
    , p0_a93 in out  VARCHAR2
    , p0_a94 in out  VARCHAR2
    , p0_a95 in out  NUMBER
    , p0_a96 in out  NUMBER
    , p0_a97 in out  VARCHAR2
    , p0_a98 in out  DATE
    , p0_a99 in out  NUMBER
    , p0_a100 in out  NUMBER
    , p0_a101 in out  DATE
    , p0_a102 in out  DATE
    , p0_a103 in out  NUMBER
    , p0_a104 in out  VARCHAR2
    , p0_a105 in out  NUMBER
    , p0_a106 in out  VARCHAR2
    , p0_a107 in out  VARCHAR2
    , p0_a108 in out  VARCHAR2
    , p0_a109 in out  NUMBER
    , p0_a110 in out  NUMBER
    , p0_a111 in out  NUMBER
    , p0_a112 in out  NUMBER
    , p0_a113 in out  NUMBER
    , p0_a114 in out  NUMBER
    , p0_a115 in out  NUMBER
    , p0_a116 in out  NUMBER
    , p0_a117 in out  NUMBER
    , p0_a118 in out  NUMBER
    , p0_a119 in out  NUMBER
    , p0_a120 in out  VARCHAR2
    , p0_a121 in out  VARCHAR2
    , p0_a122 in out  VARCHAR2
    , p0_a123 in out  VARCHAR2
    , p0_a124 in out  VARCHAR2
    , p0_a125 in out  NUMBER
    , p0_a126 in out  VARCHAR2
    , p0_a127 in out  VARCHAR2
    , p0_a128 in out  VARCHAR2
    , p0_a129 in out  VARCHAR2
    , p0_a130 in out  DATE
    , p0_a131 in out  VARCHAR2
    , p0_a132 in out  DATE
    , p0_a133 in out  VARCHAR2
    , p0_a134 in out  VARCHAR2
    , p0_a135 in out  VARCHAR2
    , p0_a136 in out  VARCHAR2
    , p0_a137 in out  VARCHAR2
    , p0_a138 in out  VARCHAR2
    , p0_a139 in out  VARCHAR2
    , p0_a140 in out  VARCHAR2
    , p0_a141 in out  NUMBER
    , p0_a142 in out  VARCHAR2
    , p0_a143 in out  NUMBER
    , p0_a144 in out  VARCHAR2
    , p0_a145 in out  VARCHAR2
    , p0_a146 in out  VARCHAR2
    , p0_a147 in out  VARCHAR2
    , p0_a148 in out  DATE
    , p0_a149 in out  VARCHAR2
    , p0_a150 in out  DATE
    , p0_a151 in out  VARCHAR2
    , p0_a152 in out  VARCHAR2
    , p0_a153 in out  VARCHAR2
    , p0_a154 in out  DATE
    , p0_a155 in out  NUMBER
    , p0_a156 in out  VARCHAR2
    , p0_a157 in out  NUMBER
    , p0_a158 in out  VARCHAR2
    , p0_a159 in out  VARCHAR2
    , p0_a160 in out  VARCHAR2
    , p0_a161 in out  VARCHAR2
    , p0_a162 in out  NUMBER
    , p0_a163 in out  NUMBER
    , p0_a164 in out  NUMBER
    , p0_a165 in out  NUMBER
    , p0_a166 in out  VARCHAR2
    , p0_a167 in out  NUMBER
    , p0_a168 in out  NUMBER
    , p0_a169 in out  NUMBER
    , p0_a170 in out  NUMBER
    , p0_a171 in out  NUMBER
    , p0_a172 in out  VARCHAR2
    , p0_a173 in out  NUMBER
    , p0_a174 in out  VARCHAR2
    , p0_a175 in out  VARCHAR2
    , p0_a176 in out  VARCHAR2
    , p0_a177 in out  DATE
    , p0_a178 in out  NUMBER
    , p0_a179 in out  VARCHAR2
    , p0_a180 in out  VARCHAR2
    , p0_a181 in out  VARCHAR2
    , p0_a182 in out  VARCHAR2
    , p0_a183 in out  NUMBER
    , p0_a184 in out  NUMBER
    , p0_a185 in out  NUMBER
    , p0_a186 in out  VARCHAR2
    , p0_a187 in out  VARCHAR2
    , p0_a188 in out  VARCHAR2
    , p0_a189 in out  NUMBER
    , p0_a190 in out  NUMBER
    , p0_a191 in out  NUMBER
    , p0_a192 in out  VARCHAR2
    , p0_a193 in out  DATE
    , p0_a194 in out  VARCHAR2
    , p0_a195 in out  DATE
    , p0_a196 in out  NUMBER
    , p0_a197 in out  NUMBER
    , p0_a198 in out  NUMBER
    , p0_a199 in out  NUMBER
    , p0_a200 in out  NUMBER
    , p0_a201 in out  NUMBER
    , p0_a202 in out  NUMBER
    , p0_a203 in out  NUMBER
    , p0_a204 in out  NUMBER
    , p0_a205 in out  NUMBER
    , p0_a206 in out  NUMBER
    , p0_a207 in out  NUMBER
    , p0_a208 in out  NUMBER
    , p0_a209 in out  NUMBER
    , p0_a210 in out  NUMBER
    , p0_a211 in out  NUMBER
    , p0_a212 in out  NUMBER
    , p0_a213 in out  NUMBER
    , p0_a214 in out  VARCHAR2
    , p0_a215 in out  NUMBER
    , p1_a0 in out  NUMBER
    , p1_a1 in out  DATE
    , p1_a2 in out  DATE
    , p1_a3 in out  NUMBER
    , p1_a4 in out  NUMBER
    , p1_a5 in out  NUMBER
    , p1_a6 in out  VARCHAR2
    , p1_a7 in out  NUMBER
    , p1_a8 in out  VARCHAR2
    , p1_a9 in out  VARCHAR2
    , p1_a10 in out  NUMBER
    , p1_a11 in out  NUMBER
    , p1_a12 in out  NUMBER
    , p1_a13 in out  VARCHAR2
    , p1_a14 in out  NUMBER
    , p1_a15 in out  NUMBER
    , p1_a16 in out  NUMBER
    , p1_a17 in out  NUMBER
    , p1_a18 in out  NUMBER
    , p1_a19 in out  NUMBER
    , p1_a20 in out  VARCHAR2
    , p1_a21 in out  NUMBER
    , p1_a22 in out  DATE
    , p1_a23 in out  NUMBER
    , p1_a24 in out  VARCHAR2
    , p1_a25 in out  VARCHAR2
    , p1_a26 in out  VARCHAR2
    , p1_a27 in out  NUMBER
    , p1_a28 in out  VARCHAR2
    , p1_a29 in out  VARCHAR2
    , p1_a30 in out  VARCHAR2
    , p1_a31 in out  NUMBER
    , p1_a32 in out  NUMBER
    , p1_a33 in out  NUMBER
    , p1_a34 in out  VARCHAR2
    , p1_a35 in out  VARCHAR2
    , p1_a36 in out  VARCHAR2
    , p1_a37 in out  DATE
    , p1_a38 in out  VARCHAR2
    , p1_a39 in out  DATE
    , p1_a40 in out  VARCHAR2
    , p1_a41 in out  VARCHAR2
    , p1_a42 in out  VARCHAR2
    , p1_a43 in out  NUMBER
    , p1_a44 in out  NUMBER
    , p1_a45 in out  NUMBER
    , p1_a46 in out  NUMBER
    , p1_a47 in out  NUMBER
    , p1_a48 in out  NUMBER
    , p1_a49 in out  VARCHAR2
    , p1_a50 in out  NUMBER
    , p1_a51 in out  NUMBER
    , p1_a52 in out  NUMBER
    , p1_a53 in out  VARCHAR2
    , p1_a54 in out  VARCHAR2
    , p1_a55 in out  VARCHAR2
    , p1_a56 in out  NUMBER
    , p1_a57 in out  DATE
    , p1_a58 in out  NUMBER
    , p1_a59 in out  DATE
    , p1_a60 in out  VARCHAR2
    , p1_a61 in out  NUMBER
    , p1_a62 in out  NUMBER
    , p1_a63 in out  NUMBER
    , p1_a64 in out  VARCHAR2
    , p1_a65 in out  NUMBER
    , p1_a66 in out  NUMBER
    , p1_a67 in out  NUMBER
    , p1_a68 in out  NUMBER
    , p1_a69 in out  NUMBER
    , p1_a70 in out  VARCHAR2
    , p1_a71 in out  VARCHAR2
    , p1_a72 in out  NUMBER
    , p1_a73 in out  NUMBER
    , p1_a74 in out  NUMBER
    , p1_a75 in out  VARCHAR2
    , p1_a76 in out  VARCHAR2
    , p1_a77 in out  NUMBER
    , p1_a78 in out  VARCHAR2
    , p1_a79 in out  VARCHAR2
    , p1_a80 in out  VARCHAR2
    , p1_a81 in out  VARCHAR2
    , p1_a82 in out  NUMBER
    , p1_a83 in out  NUMBER
    , p1_a84 in out  VARCHAR2
    , p1_a85 in out  NUMBER
    , p1_a86 in out  VARCHAR2
    , p1_a87 in out  DATE
    , p1_a88 in out  NUMBER
    , p1_a89 in out  VARCHAR2
    , p1_a90 in out  NUMBER
    , p1_a91 in out  NUMBER
    , p1_a92 in out  DATE
    , p1_a93 in out  NUMBER
    , p1_a94 in out  DATE
    , p1_a95 in out  VARCHAR2
    , p1_a96 in out  NUMBER
    , p1_a97 in out  NUMBER
    , p1_a98 in out  NUMBER
    , p1_a99 in out  VARCHAR2
    , p1_a100 in out  DATE
    , p1_a101 in out  NUMBER
    , p1_a102 in out  NUMBER
    , p1_a103 in out  VARCHAR2
    , p1_a104 in out  VARCHAR2
    , p1_a105 in out  NUMBER
    , p1_a106 in out  DATE
    , p1_a107 in out  DATE
    , p1_a108 in out  VARCHAR2
    , p1_a109 in out  VARCHAR2
    , p1_a110 in out  NUMBER
    , p1_a111 in out  VARCHAR2
    , p1_a112 in out  NUMBER
    , p1_a113 in out  NUMBER
    , p1_a114 in out  VARCHAR2
    , p1_a115 in out  VARCHAR2
    , p1_a116 in out  NUMBER
    , p1_a117 in out  NUMBER
    , p1_a118 in out  VARCHAR2
    , p1_a119 in out  VARCHAR2
    , p1_a120 in out  NUMBER
    , p1_a121 in out  VARCHAR2
    , p1_a122 in out  NUMBER
    , p1_a123 in out  NUMBER
    , p1_a124 in out  NUMBER
    , p1_a125 in out  NUMBER
    , p1_a126 in out  NUMBER
    , p1_a127 in out  NUMBER
    , p1_a128 in out  NUMBER
    , p1_a129 in out  NUMBER
    , p1_a130 in out  VARCHAR2
    , p1_a131 in out  NUMBER
    , p1_a132 in out  NUMBER
    , p1_a133 in out  NUMBER
    , p1_a134 in out  VARCHAR2
    , p1_a135 in out  NUMBER
    , p1_a136 in out  NUMBER
    , p1_a137 in out  VARCHAR2
    , p1_a138 in out  DATE
    , p1_a139 in out  VARCHAR2
    , p1_a140 in out  VARCHAR2
    , p1_a141 in out  VARCHAR2
    , p1_a142 in out  VARCHAR2
    , p1_a143 in out  NUMBER
    , p1_a144 in out  NUMBER
    , p1_a145 in out  VARCHAR2
    , p1_a146 in out  NUMBER
    , p1_a147 in out  NUMBER
    , p1_a148 in out  NUMBER
    , p1_a149 in out  NUMBER
    , p1_a150 in out  NUMBER
    , p1_a151 in out  NUMBER
    , p1_a152 in out  NUMBER
    , p1_a153 in out  VARCHAR2
    , p1_a154 in out  VARCHAR2
    , p1_a155 in out  VARCHAR2
    , p1_a156 in out  VARCHAR2
    , p1_a157 in out  VARCHAR2
    , p1_a158 in out  DATE
    , p1_a159 in out  VARCHAR2
    , p1_a160 in out  DATE
    , p1_a161 in out  VARCHAR2
    , p1_a162 in out  VARCHAR2
    , p1_a163 in out  VARCHAR2
    , p1_a164 in out  VARCHAR2
    , p1_a165 in out  VARCHAR2
    , p1_a166 in out  NUMBER
    , p1_a167 in out  VARCHAR2
    , p1_a168 in out  VARCHAR2
    , p1_a169 in out  VARCHAR2
    , p1_a170 in out  VARCHAR2
    , p1_a171 in out  VARCHAR2
    , p1_a172 in out  VARCHAR2
    , p1_a173 in out  VARCHAR2
    , p1_a174 in out  NUMBER
    , p1_a175 in out  NUMBER
    , p1_a176 in out  NUMBER
    , p1_a177 in out  VARCHAR2
    , p1_a178 in out  VARCHAR2
    , p1_a179 in out  VARCHAR2
    , p1_a180 in out  VARCHAR2
    , p1_a181 in out  NUMBER
    , p1_a182 in out  VARCHAR2
    , p1_a183 in out  VARCHAR2
    , p1_a184 in out  NUMBER
    , p1_a185 in out  VARCHAR2
    , p1_a186 in out  DATE
    , p1_a187 in out  DATE
    , p1_a188 in out  VARCHAR2
    , p1_a189 in out  NUMBER
    , p1_a190 in out  NUMBER
    , p1_a191 in out  NUMBER
    , p1_a192 in out  NUMBER
    , p1_a193 in out  VARCHAR2
    , p1_a194 in out  NUMBER
    , p1_a195 in out  NUMBER
    , p1_a196 in out  NUMBER
    , p1_a197 in out  NUMBER
    , p1_a198 in out  VARCHAR2
    , p1_a199 in out  VARCHAR2
    , p1_a200 in out  VARCHAR2
    , p1_a201 in out  NUMBER
    , p1_a202 in out  NUMBER
    , p1_a203 in out  NUMBER
    , p1_a204 in out  NUMBER
    , p1_a205 in out  VARCHAR2
    , p1_a206 in out  VARCHAR2
    , p1_a207 in out  VARCHAR2
    , p1_a208 in out  VARCHAR2
    , p1_a209 in out  VARCHAR2
    , p1_a210 in out  VARCHAR2
    , p1_a211 in out  VARCHAR2
    , p1_a212 in out  NUMBER
    , p1_a213 in out  NUMBER
    , p1_a214 in out  DATE
    , p1_a215 in out  NUMBER
    , p1_a216 in out  VARCHAR2
    , p1_a217 in out  NUMBER
    , p1_a218 in out  VARCHAR2
    , p1_a219 in out  VARCHAR2
    , p1_a220 in out  VARCHAR2
    , p1_a221 in out  VARCHAR2
    , p1_a222 in out  VARCHAR2
    , p1_a223 in out  VARCHAR2
    , p1_a224 in out  NUMBER
    , p1_a225 in out  NUMBER
    , p1_a226 in out  NUMBER
    , p1_a227 in out  NUMBER
    , p1_a228 in out  VARCHAR2
    , p1_a229 in out  NUMBER
    , p1_a230 in out  VARCHAR2
    , p1_a231 in out  NUMBER
    , p1_a232 in out  VARCHAR2
    , p1_a233 in out  VARCHAR2
    , p1_a234 in out  NUMBER
    , p1_a235 in out  VARCHAR2
    , p1_a236 in out  NUMBER
    , p1_a237 in out  NUMBER
    , p1_a238 in out  NUMBER
    , p1_a239 in out  NUMBER
    , p1_a240 in out  NUMBER
    , p1_a241 in out  VARCHAR2
    , p1_a242 in out  VARCHAR2
    , p1_a243 in out  NUMBER
    , p1_a244 in out  NUMBER
    , p1_a245 in out  NUMBER
    , p1_a246 in out  NUMBER
    , p1_a247 in out  VARCHAR2
    , p1_a248 in out  VARCHAR2
    , p1_a249 in out  DATE
    , p1_a250 in out  VARCHAR2
    , p1_a251 in out  NUMBER
    , p1_a252 in out  NUMBER
    , p1_a253 in out  VARCHAR2
    , p1_a254 in out  VARCHAR2
    , p1_a255 in out  VARCHAR2
    , p1_a256 in out  NUMBER
    , p1_a257 in out  NUMBER
    , p1_a258 in out  NUMBER
    , p1_a259 in out  VARCHAR2
    , p1_a260 in out  DATE
    , p1_a261 in out  VARCHAR2
    , p1_a262 in out  DATE
    , p1_a263 in out  NUMBER
    , p1_a264 in out  NUMBER
    , p1_a265 in out  NUMBER
    , p1_a266 in out  NUMBER
    , p1_a267 in out  NUMBER
    , p1_a268 in out  NUMBER
    , p1_a269 in out  NUMBER
    , p1_a270 in out  NUMBER
    , p1_a271 in out  NUMBER
    , p1_a272 in out  NUMBER
    , p1_a273 in out  NUMBER
    , p1_a274 in out  NUMBER
    , p1_a275 in out  NUMBER
    , p1_a276 in out  NUMBER
    , p1_a277 in out  NUMBER
    , p1_a278 in out  NUMBER
    , p1_a279 in out  NUMBER
    , p1_a280 in out  NUMBER
    , p2_a0 in out JTF_VARCHAR2_TABLE_300
    , p2_a1 in out JTF_VARCHAR2_TABLE_300
    , p2_a2 in out JTF_VARCHAR2_TABLE_300
    , p2_a3 in out JTF_VARCHAR2_TABLE_300
    , p2_a4 in out JTF_VARCHAR2_TABLE_300
    , p2_a5 in out JTF_VARCHAR2_TABLE_300
    , p2_a6 in out JTF_VARCHAR2_TABLE_300
    , p2_a7 in out JTF_VARCHAR2_TABLE_300
    , p2_a8 in out JTF_VARCHAR2_TABLE_300
    , p2_a9 in out JTF_VARCHAR2_TABLE_300
    , p2_a10 in out JTF_VARCHAR2_TABLE_300
    , p2_a11 in out JTF_VARCHAR2_TABLE_300
    , p2_a12 in out JTF_VARCHAR2_TABLE_300
    , p2_a13 in out JTF_VARCHAR2_TABLE_300
    , p2_a14 in out JTF_VARCHAR2_TABLE_300
    , p2_a15 in out JTF_VARCHAR2_TABLE_100
    , p2_a16 in out JTF_VARCHAR2_TABLE_100
    , p2_a17 in out JTF_NUMBER_TABLE
    , p2_a18 in out JTF_DATE_TABLE
    , p2_a19 in out JTF_NUMBER_TABLE
    , p2_a20 in out JTF_NUMBER_TABLE
    , p2_a21 in out JTF_NUMBER_TABLE
    , p2_a22 in out JTF_NUMBER_TABLE
    , p2_a23 in out JTF_DATE_TABLE
    , p2_a24 in out JTF_NUMBER_TABLE
    , p2_a25 in out JTF_NUMBER_TABLE
    , p2_a26 in out JTF_NUMBER_TABLE
    , p2_a27 in out JTF_NUMBER_TABLE
    , p2_a28 in out JTF_NUMBER_TABLE
    , p2_a29 in out JTF_NUMBER_TABLE
    , p2_a30 in out JTF_DATE_TABLE
    , p2_a31 in out JTF_NUMBER_TABLE
    , p2_a32 in out JTF_VARCHAR2_TABLE_100
    , p2_a33 in out JTF_VARCHAR2_TABLE_100
    , p2_a34 in out JTF_VARCHAR2_TABLE_100
    , p2_a35 in out JTF_NUMBER_TABLE
    , p2_a36 in out JTF_VARCHAR2_TABLE_100
    , p2_a37 in out JTF_VARCHAR2_TABLE_100
    , p2_a38 in out JTF_VARCHAR2_TABLE_100
    , p2_a39 in out JTF_NUMBER_TABLE
    , p2_a40 in out JTF_NUMBER_TABLE
    , p2_a41 in out JTF_VARCHAR2_TABLE_100
    , p2_a42 in out JTF_VARCHAR2_TABLE_100
    , p2_a43 in out JTF_VARCHAR2_TABLE_300
    , p2_a44 in out JTF_VARCHAR2_TABLE_300
    , p2_a45 in out JTF_VARCHAR2_TABLE_100
    , p2_a46 in out JTF_VARCHAR2_TABLE_100
    , p2_a47 in out JTF_VARCHAR2_TABLE_100
    , p2_a48 in out JTF_VARCHAR2_TABLE_100
    , p2_a49 in out JTF_VARCHAR2_TABLE_2000
    , p2_a50 in out JTF_NUMBER_TABLE
    , p2_a51 in out JTF_NUMBER_TABLE
    , p2_a52 in out JTF_VARCHAR2_TABLE_100
    , p2_a53 in out JTF_NUMBER_TABLE
    , p2_a54 in out JTF_VARCHAR2_TABLE_100
    , p2_a55 in out JTF_VARCHAR2_TABLE_100
    , p2_a56 in out JTF_VARCHAR2_TABLE_100
    , p2_a57 in out JTF_VARCHAR2_TABLE_100
    , p2_a58 in out JTF_NUMBER_TABLE
    , p2_a59 in out JTF_VARCHAR2_TABLE_100
    , p2_a60 in out JTF_VARCHAR2_TABLE_100
    , p2_a61 in out JTF_VARCHAR2_TABLE_100
    , p2_a62 in out JTF_VARCHAR2_TABLE_100
    , p2_a63 in out JTF_NUMBER_TABLE
    , p2_a64 in out JTF_NUMBER_TABLE
    , p2_a65 in out JTF_NUMBER_TABLE
    , p2_a66 in out JTF_VARCHAR2_TABLE_100
    , p2_a67 in out JTF_VARCHAR2_TABLE_100
    , p2_a68 in out JTF_VARCHAR2_TABLE_300
    , p2_a69 in out JTF_VARCHAR2_TABLE_100
    , p2_a70 in out JTF_NUMBER_TABLE
    , p2_a71 in out JTF_VARCHAR2_TABLE_100
    , p2_a72 in out JTF_VARCHAR2_TABLE_100
    , p2_a73 in out JTF_DATE_TABLE
    , p2_a74 in out JTF_VARCHAR2_TABLE_100
    , p2_a75 in out JTF_VARCHAR2_TABLE_100
    , p2_a76 in out JTF_VARCHAR2_TABLE_100
    , p2_a77 in out JTF_DATE_TABLE
    , p2_a78 in out JTF_VARCHAR2_TABLE_100
    , p2_a79 in out JTF_VARCHAR2_TABLE_100
    , p2_a80 in out JTF_NUMBER_TABLE
    , p2_a81 in out JTF_NUMBER_TABLE
    , p2_a82 in out JTF_NUMBER_TABLE
    , p2_a83 in out JTF_VARCHAR2_TABLE_100
    , p2_a84 in out JTF_VARCHAR2_TABLE_100
    , p2_a85 in out JTF_VARCHAR2_TABLE_100
    , p2_a86 in out JTF_VARCHAR2_TABLE_100
    , p2_a87 in out JTF_VARCHAR2_TABLE_100
    , p2_a88 in out JTF_VARCHAR2_TABLE_100
    , p2_a89 in out JTF_VARCHAR2_TABLE_300
    , p2_a90 in out JTF_VARCHAR2_TABLE_300
    , p2_a91 in out JTF_VARCHAR2_TABLE_300
    , p2_a92 in out JTF_VARCHAR2_TABLE_300
    , p2_a93 in out JTF_VARCHAR2_TABLE_300
    , p2_a94 in out JTF_VARCHAR2_TABLE_300
    , p2_a95 in out JTF_VARCHAR2_TABLE_300
    , p2_a96 in out JTF_VARCHAR2_TABLE_300
    , p2_a97 in out JTF_VARCHAR2_TABLE_300
    , p2_a98 in out JTF_VARCHAR2_TABLE_300
    , p2_a99 in out JTF_VARCHAR2_TABLE_300
    , p2_a100 in out JTF_VARCHAR2_TABLE_300
    , p2_a101 in out JTF_VARCHAR2_TABLE_300
    , p2_a102 in out JTF_VARCHAR2_TABLE_300
    , p2_a103 in out JTF_VARCHAR2_TABLE_300
    , p2_a104 in out JTF_VARCHAR2_TABLE_200
    , p2_a105 in out JTF_NUMBER_TABLE
    , p2_a106 in out JTF_NUMBER_TABLE
    , p2_a107 in out JTF_NUMBER_TABLE
    , p2_a108 in out JTF_NUMBER_TABLE
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_VARCHAR2_TABLE_100
    , p3_a3 JTF_VARCHAR2_TABLE_100
    , p3_a4 JTF_VARCHAR2_TABLE_100
    , p3_a5 JTF_VARCHAR2_TABLE_300
    , p3_a6 JTF_VARCHAR2_TABLE_100
    , p_action_code  VARCHAR2
    , p_pricing_events  VARCHAR2
    , p_simulation_flag  VARCHAR2
    , p_get_freight_flag  VARCHAR2
    , x_return_status out  VARCHAR2
  )

  as
    ddpx_header_rec oe_order_pub.header_rec_type;
    ddpx_line_rec oe_order_pub.line_rec_type;
    ddpx_line_adj_tbl oe_order_pub.line_adj_tbl_type;
    ddp_line_price_att_tbl oe_price_order_pvt.price_att_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddpx_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddpx_header_rec.agreement_id := rosetta_g_miss_num_map(p0_a1);
    ddpx_header_rec.attribute1 := p0_a2;
    ddpx_header_rec.attribute10 := p0_a3;
    ddpx_header_rec.attribute11 := p0_a4;
    ddpx_header_rec.attribute12 := p0_a5;
    ddpx_header_rec.attribute13 := p0_a6;
    ddpx_header_rec.attribute14 := p0_a7;
    ddpx_header_rec.attribute15 := p0_a8;
    ddpx_header_rec.attribute16 := p0_a9;
    ddpx_header_rec.attribute17 := p0_a10;
    ddpx_header_rec.attribute18 := p0_a11;
    ddpx_header_rec.attribute19 := p0_a12;
    ddpx_header_rec.attribute2 := p0_a13;
    ddpx_header_rec.attribute20 := p0_a14;
    ddpx_header_rec.attribute3 := p0_a15;
    ddpx_header_rec.attribute4 := p0_a16;
    ddpx_header_rec.attribute5 := p0_a17;
    ddpx_header_rec.attribute6 := p0_a18;
    ddpx_header_rec.attribute7 := p0_a19;
    ddpx_header_rec.attribute8 := p0_a20;
    ddpx_header_rec.attribute9 := p0_a21;
    ddpx_header_rec.booked_flag := p0_a22;
    ddpx_header_rec.cancelled_flag := p0_a23;
    ddpx_header_rec.context := p0_a24;
    ddpx_header_rec.conversion_rate := rosetta_g_miss_num_map(p0_a25);
    ddpx_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p0_a26);
    ddpx_header_rec.conversion_type_code := p0_a27;
    ddpx_header_rec.customer_preference_set_code := p0_a28;
    ddpx_header_rec.created_by := rosetta_g_miss_num_map(p0_a29);
    ddpx_header_rec.creation_date := rosetta_g_miss_date_in_map(p0_a30);
    ddpx_header_rec.cust_po_number := p0_a31;
    ddpx_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p0_a32);
    ddpx_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p0_a33);
    ddpx_header_rec.demand_class_code := p0_a34;
    ddpx_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p0_a35);
    ddpx_header_rec.expiration_date := rosetta_g_miss_date_in_map(p0_a36);
    ddpx_header_rec.fob_point_code := p0_a37;
    ddpx_header_rec.freight_carrier_code := p0_a38;
    ddpx_header_rec.freight_terms_code := p0_a39;
    ddpx_header_rec.global_attribute1 := p0_a40;
    ddpx_header_rec.global_attribute10 := p0_a41;
    ddpx_header_rec.global_attribute11 := p0_a42;
    ddpx_header_rec.global_attribute12 := p0_a43;
    ddpx_header_rec.global_attribute13 := p0_a44;
    ddpx_header_rec.global_attribute14 := p0_a45;
    ddpx_header_rec.global_attribute15 := p0_a46;
    ddpx_header_rec.global_attribute16 := p0_a47;
    ddpx_header_rec.global_attribute17 := p0_a48;
    ddpx_header_rec.global_attribute18 := p0_a49;
    ddpx_header_rec.global_attribute19 := p0_a50;
    ddpx_header_rec.global_attribute2 := p0_a51;
    ddpx_header_rec.global_attribute20 := p0_a52;
    ddpx_header_rec.global_attribute3 := p0_a53;
    ddpx_header_rec.global_attribute4 := p0_a54;
    ddpx_header_rec.global_attribute5 := p0_a55;
    ddpx_header_rec.global_attribute6 := p0_a56;
    ddpx_header_rec.global_attribute7 := p0_a57;
    ddpx_header_rec.global_attribute8 := p0_a58;
    ddpx_header_rec.global_attribute9 := p0_a59;
    ddpx_header_rec.global_attribute_category := p0_a60;
    ddpx_header_rec.tp_context := p0_a61;
    ddpx_header_rec.tp_attribute1 := p0_a62;
    ddpx_header_rec.tp_attribute2 := p0_a63;
    ddpx_header_rec.tp_attribute3 := p0_a64;
    ddpx_header_rec.tp_attribute4 := p0_a65;
    ddpx_header_rec.tp_attribute5 := p0_a66;
    ddpx_header_rec.tp_attribute6 := p0_a67;
    ddpx_header_rec.tp_attribute7 := p0_a68;
    ddpx_header_rec.tp_attribute8 := p0_a69;
    ddpx_header_rec.tp_attribute9 := p0_a70;
    ddpx_header_rec.tp_attribute10 := p0_a71;
    ddpx_header_rec.tp_attribute11 := p0_a72;
    ddpx_header_rec.tp_attribute12 := p0_a73;
    ddpx_header_rec.tp_attribute13 := p0_a74;
    ddpx_header_rec.tp_attribute14 := p0_a75;
    ddpx_header_rec.tp_attribute15 := p0_a76;
    ddpx_header_rec.header_id := rosetta_g_miss_num_map(p0_a77);
    ddpx_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p0_a78);
    ddpx_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p0_a79);
    ddpx_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p0_a80);
    ddpx_header_rec.last_updated_by := rosetta_g_miss_num_map(p0_a81);
    ddpx_header_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a82);
    ddpx_header_rec.last_update_login := rosetta_g_miss_num_map(p0_a83);
    ddpx_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p0_a84);
    ddpx_header_rec.open_flag := p0_a85;
    ddpx_header_rec.order_category_code := p0_a86;
    ddpx_header_rec.ordered_date := rosetta_g_miss_date_in_map(p0_a87);
    ddpx_header_rec.order_date_type_code := p0_a88;
    ddpx_header_rec.order_number := rosetta_g_miss_num_map(p0_a89);
    ddpx_header_rec.order_source_id := rosetta_g_miss_num_map(p0_a90);
    ddpx_header_rec.order_type_id := rosetta_g_miss_num_map(p0_a91);
    ddpx_header_rec.org_id := rosetta_g_miss_num_map(p0_a92);
    ddpx_header_rec.orig_sys_document_ref := p0_a93;
    ddpx_header_rec.partial_shipments_allowed := p0_a94;
    ddpx_header_rec.payment_term_id := rosetta_g_miss_num_map(p0_a95);
    ddpx_header_rec.price_list_id := rosetta_g_miss_num_map(p0_a96);
    ddpx_header_rec.price_request_code := p0_a97;
    ddpx_header_rec.pricing_date := rosetta_g_miss_date_in_map(p0_a98);
    ddpx_header_rec.program_application_id := rosetta_g_miss_num_map(p0_a99);
    ddpx_header_rec.program_id := rosetta_g_miss_num_map(p0_a100);
    ddpx_header_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a101);
    ddpx_header_rec.request_date := rosetta_g_miss_date_in_map(p0_a102);
    ddpx_header_rec.request_id := rosetta_g_miss_num_map(p0_a103);
    ddpx_header_rec.return_reason_code := p0_a104;
    ddpx_header_rec.salesrep_id := rosetta_g_miss_num_map(p0_a105);
    ddpx_header_rec.sales_channel_code := p0_a106;
    ddpx_header_rec.shipment_priority_code := p0_a107;
    ddpx_header_rec.shipping_method_code := p0_a108;
    ddpx_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p0_a109);
    ddpx_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p0_a110);
    ddpx_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p0_a111);
    ddpx_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p0_a112);
    ddpx_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p0_a113);
    ddpx_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p0_a114);
    ddpx_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p0_a115);
    ddpx_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p0_a116);
    ddpx_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p0_a117);
    ddpx_header_rec.source_document_id := rosetta_g_miss_num_map(p0_a118);
    ddpx_header_rec.source_document_type_id := rosetta_g_miss_num_map(p0_a119);
    ddpx_header_rec.tax_exempt_flag := p0_a120;
    ddpx_header_rec.tax_exempt_number := p0_a121;
    ddpx_header_rec.tax_exempt_reason_code := p0_a122;
    ddpx_header_rec.tax_point_code := p0_a123;
    ddpx_header_rec.transactional_curr_code := p0_a124;
    ddpx_header_rec.version_number := rosetta_g_miss_num_map(p0_a125);
    ddpx_header_rec.return_status := p0_a126;
    ddpx_header_rec.db_flag := p0_a127;
    ddpx_header_rec.operation := p0_a128;
    ddpx_header_rec.first_ack_code := p0_a129;
    ddpx_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p0_a130);
    ddpx_header_rec.last_ack_code := p0_a131;
    ddpx_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p0_a132);
    ddpx_header_rec.change_reason := p0_a133;
    ddpx_header_rec.change_comments := p0_a134;
    ddpx_header_rec.change_sequence := p0_a135;
    ddpx_header_rec.change_request_code := p0_a136;
    ddpx_header_rec.ready_flag := p0_a137;
    ddpx_header_rec.status_flag := p0_a138;
    ddpx_header_rec.force_apply_flag := p0_a139;
    ddpx_header_rec.drop_ship_flag := p0_a140;
    ddpx_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p0_a141);
    ddpx_header_rec.payment_type_code := p0_a142;
    ddpx_header_rec.payment_amount := rosetta_g_miss_num_map(p0_a143);
    ddpx_header_rec.check_number := p0_a144;
    ddpx_header_rec.credit_card_code := p0_a145;
    ddpx_header_rec.credit_card_holder_name := p0_a146;
    ddpx_header_rec.credit_card_number := p0_a147;
    ddpx_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p0_a148);
    ddpx_header_rec.credit_card_approval_code := p0_a149;
    ddpx_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p0_a150);
    ddpx_header_rec.shipping_instructions := p0_a151;
    ddpx_header_rec.packing_instructions := p0_a152;
    ddpx_header_rec.flow_status_code := p0_a153;
    ddpx_header_rec.booked_date := rosetta_g_miss_date_in_map(p0_a154);
    ddpx_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p0_a155);
    ddpx_header_rec.upgraded_flag := p0_a156;
    ddpx_header_rec.lock_control := rosetta_g_miss_num_map(p0_a157);
    ddpx_header_rec.ship_to_edi_location_code := p0_a158;
    ddpx_header_rec.sold_to_edi_location_code := p0_a159;
    ddpx_header_rec.bill_to_edi_location_code := p0_a160;
    ddpx_header_rec.ship_from_edi_location_code := p0_a161;
    ddpx_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p0_a162);
    ddpx_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p0_a163);
    ddpx_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p0_a164);
    ddpx_header_rec.invoice_address_id := rosetta_g_miss_num_map(p0_a165);
    ddpx_header_rec.ship_to_address_code := p0_a166;
    ddpx_header_rec.xml_message_id := rosetta_g_miss_num_map(p0_a167);
    ddpx_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p0_a168);
    ddpx_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p0_a169);
    ddpx_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p0_a170);
    ddpx_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p0_a171);
    ddpx_header_rec.xml_transaction_type_code := p0_a172;
    ddpx_header_rec.blanket_number := rosetta_g_miss_num_map(p0_a173);
    ddpx_header_rec.line_set_name := p0_a174;
    ddpx_header_rec.fulfillment_set_name := p0_a175;
    ddpx_header_rec.default_fulfillment_set := p0_a176;
    ddpx_header_rec.quote_date := rosetta_g_miss_date_in_map(p0_a177);
    ddpx_header_rec.quote_number := rosetta_g_miss_num_map(p0_a178);
    ddpx_header_rec.sales_document_name := p0_a179;
    ddpx_header_rec.transaction_phase_code := p0_a180;
    ddpx_header_rec.user_status_code := p0_a181;
    ddpx_header_rec.draft_submitted_flag := p0_a182;
    ddpx_header_rec.source_document_version_number := rosetta_g_miss_num_map(p0_a183);
    ddpx_header_rec.sold_to_site_use_id := rosetta_g_miss_num_map(p0_a184);
    ddpx_header_rec.minisite_id := rosetta_g_miss_num_map(p0_a185);
    ddpx_header_rec.ib_owner := p0_a186;
    ddpx_header_rec.ib_installed_at_location := p0_a187;
    ddpx_header_rec.ib_current_location := p0_a188;
    ddpx_header_rec.end_customer_id := rosetta_g_miss_num_map(p0_a189);
    ddpx_header_rec.end_customer_contact_id := rosetta_g_miss_num_map(p0_a190);
    ddpx_header_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p0_a191);
    ddpx_header_rec.supplier_signature := p0_a192;
    ddpx_header_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p0_a193);
    ddpx_header_rec.customer_signature := p0_a194;
    ddpx_header_rec.customer_signature_date := rosetta_g_miss_date_in_map(p0_a195);
    ddpx_header_rec.sold_to_party_id := rosetta_g_miss_num_map(p0_a196);
    ddpx_header_rec.sold_to_org_contact_id := rosetta_g_miss_num_map(p0_a197);
    ddpx_header_rec.ship_to_party_id := rosetta_g_miss_num_map(p0_a198);
    ddpx_header_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p0_a199);
    ddpx_header_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p0_a200);
    ddpx_header_rec.deliver_to_party_id := rosetta_g_miss_num_map(p0_a201);
    ddpx_header_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p0_a202);
    ddpx_header_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p0_a203);
    ddpx_header_rec.invoice_to_party_id := rosetta_g_miss_num_map(p0_a204);
    ddpx_header_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p0_a205);
    ddpx_header_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p0_a206);
    ddpx_header_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p0_a207);
    ddpx_header_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p0_a208);
    ddpx_header_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p0_a209);
    ddpx_header_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p0_a210);
    ddpx_header_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p0_a211);
    ddpx_header_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p0_a212);
    ddpx_header_rec.contract_template_id := rosetta_g_miss_num_map(p0_a213);
    ddpx_header_rec.contract_source_doc_type_code := p0_a214;
    ddpx_header_rec.contract_source_document_id := rosetta_g_miss_num_map(p0_a215);

    ddpx_line_rec.accounting_rule_id := rosetta_g_miss_num_map(p1_a0);
    ddpx_line_rec.actual_arrival_date := rosetta_g_miss_date_in_map(p1_a1);
    ddpx_line_rec.actual_shipment_date := rosetta_g_miss_date_in_map(p1_a2);
    ddpx_line_rec.agreement_id := rosetta_g_miss_num_map(p1_a3);
    ddpx_line_rec.arrival_set_id := rosetta_g_miss_num_map(p1_a4);
    ddpx_line_rec.ato_line_id := rosetta_g_miss_num_map(p1_a5);
    ddpx_line_rec.authorized_to_ship_flag := p1_a6;
    ddpx_line_rec.auto_selected_quantity := rosetta_g_miss_num_map(p1_a7);
    ddpx_line_rec.booked_flag := p1_a8;
    ddpx_line_rec.cancelled_flag := p1_a9;
    ddpx_line_rec.cancelled_quantity := rosetta_g_miss_num_map(p1_a10);
    ddpx_line_rec.cancelled_quantity2 := rosetta_g_miss_num_map(p1_a11);
    ddpx_line_rec.commitment_id := rosetta_g_miss_num_map(p1_a12);
    ddpx_line_rec.component_code := p1_a13;
    ddpx_line_rec.component_number := rosetta_g_miss_num_map(p1_a14);
    ddpx_line_rec.component_sequence_id := rosetta_g_miss_num_map(p1_a15);
    ddpx_line_rec.config_header_id := rosetta_g_miss_num_map(p1_a16);
    ddpx_line_rec.config_rev_nbr := rosetta_g_miss_num_map(p1_a17);
    ddpx_line_rec.config_display_sequence := rosetta_g_miss_num_map(p1_a18);
    ddpx_line_rec.configuration_id := rosetta_g_miss_num_map(p1_a19);
    ddpx_line_rec.context := p1_a20;
    ddpx_line_rec.created_by := rosetta_g_miss_num_map(p1_a21);
    ddpx_line_rec.creation_date := rosetta_g_miss_date_in_map(p1_a22);
    ddpx_line_rec.credit_invoice_line_id := rosetta_g_miss_num_map(p1_a23);
    ddpx_line_rec.customer_dock_code := p1_a24;
    ddpx_line_rec.customer_job := p1_a25;
    ddpx_line_rec.customer_production_line := p1_a26;
    ddpx_line_rec.customer_trx_line_id := rosetta_g_miss_num_map(p1_a27);
    ddpx_line_rec.cust_model_serial_number := p1_a28;
    ddpx_line_rec.cust_po_number := p1_a29;
    ddpx_line_rec.cust_production_seq_num := p1_a30;
    ddpx_line_rec.delivery_lead_time := rosetta_g_miss_num_map(p1_a31);
    ddpx_line_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p1_a32);
    ddpx_line_rec.deliver_to_org_id := rosetta_g_miss_num_map(p1_a33);
    ddpx_line_rec.demand_bucket_type_code := p1_a34;
    ddpx_line_rec.demand_class_code := p1_a35;
    ddpx_line_rec.dep_plan_required_flag := p1_a36;
    ddpx_line_rec.earliest_acceptable_date := rosetta_g_miss_date_in_map(p1_a37);
    ddpx_line_rec.end_item_unit_number := p1_a38;
    ddpx_line_rec.explosion_date := rosetta_g_miss_date_in_map(p1_a39);
    ddpx_line_rec.fob_point_code := p1_a40;
    ddpx_line_rec.freight_carrier_code := p1_a41;
    ddpx_line_rec.freight_terms_code := p1_a42;
    ddpx_line_rec.fulfilled_quantity := rosetta_g_miss_num_map(p1_a43);
    ddpx_line_rec.fulfilled_quantity2 := rosetta_g_miss_num_map(p1_a44);
    ddpx_line_rec.header_id := rosetta_g_miss_num_map(p1_a45);
    ddpx_line_rec.intermed_ship_to_org_id := rosetta_g_miss_num_map(p1_a46);
    ddpx_line_rec.intermed_ship_to_contact_id := rosetta_g_miss_num_map(p1_a47);
    ddpx_line_rec.inventory_item_id := rosetta_g_miss_num_map(p1_a48);
    ddpx_line_rec.invoice_interface_status_code := p1_a49;
    ddpx_line_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p1_a50);
    ddpx_line_rec.invoice_to_org_id := rosetta_g_miss_num_map(p1_a51);
    ddpx_line_rec.invoicing_rule_id := rosetta_g_miss_num_map(p1_a52);
    ddpx_line_rec.ordered_item := p1_a53;
    ddpx_line_rec.item_revision := p1_a54;
    ddpx_line_rec.item_type_code := p1_a55;
    ddpx_line_rec.last_updated_by := rosetta_g_miss_num_map(p1_a56);
    ddpx_line_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a57);
    ddpx_line_rec.last_update_login := rosetta_g_miss_num_map(p1_a58);
    ddpx_line_rec.latest_acceptable_date := rosetta_g_miss_date_in_map(p1_a59);
    ddpx_line_rec.line_category_code := p1_a60;
    ddpx_line_rec.line_id := rosetta_g_miss_num_map(p1_a61);
    ddpx_line_rec.line_number := rosetta_g_miss_num_map(p1_a62);
    ddpx_line_rec.line_type_id := rosetta_g_miss_num_map(p1_a63);
    ddpx_line_rec.link_to_line_ref := p1_a64;
    ddpx_line_rec.link_to_line_id := rosetta_g_miss_num_map(p1_a65);
    ddpx_line_rec.link_to_line_index := rosetta_g_miss_num_map(p1_a66);
    ddpx_line_rec.model_group_number := rosetta_g_miss_num_map(p1_a67);
    ddpx_line_rec.mfg_component_sequence_id := rosetta_g_miss_num_map(p1_a68);
    ddpx_line_rec.mfg_lead_time := rosetta_g_miss_num_map(p1_a69);
    ddpx_line_rec.open_flag := p1_a70;
    ddpx_line_rec.option_flag := p1_a71;
    ddpx_line_rec.option_number := rosetta_g_miss_num_map(p1_a72);
    ddpx_line_rec.ordered_quantity := rosetta_g_miss_num_map(p1_a73);
    ddpx_line_rec.ordered_quantity2 := rosetta_g_miss_num_map(p1_a74);
    ddpx_line_rec.order_quantity_uom := p1_a75;
    ddpx_line_rec.ordered_quantity_uom2 := p1_a76;
    ddpx_line_rec.org_id := rosetta_g_miss_num_map(p1_a77);
    ddpx_line_rec.orig_sys_document_ref := p1_a78;
    ddpx_line_rec.orig_sys_line_ref := p1_a79;
    ddpx_line_rec.over_ship_reason_code := p1_a80;
    ddpx_line_rec.over_ship_resolved_flag := p1_a81;
    ddpx_line_rec.payment_term_id := rosetta_g_miss_num_map(p1_a82);
    ddpx_line_rec.planning_priority := rosetta_g_miss_num_map(p1_a83);
    ddpx_line_rec.preferred_grade := p1_a84;
    ddpx_line_rec.price_list_id := rosetta_g_miss_num_map(p1_a85);
    ddpx_line_rec.price_request_code := p1_a86;
    ddpx_line_rec.pricing_date := rosetta_g_miss_date_in_map(p1_a87);
    ddpx_line_rec.pricing_quantity := rosetta_g_miss_num_map(p1_a88);
    ddpx_line_rec.pricing_quantity_uom := p1_a89;
    ddpx_line_rec.program_application_id := rosetta_g_miss_num_map(p1_a90);
    ddpx_line_rec.program_id := rosetta_g_miss_num_map(p1_a91);
    ddpx_line_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a92);
    ddpx_line_rec.project_id := rosetta_g_miss_num_map(p1_a93);
    ddpx_line_rec.promise_date := rosetta_g_miss_date_in_map(p1_a94);
    ddpx_line_rec.re_source_flag := p1_a95;
    ddpx_line_rec.reference_customer_trx_line_id := rosetta_g_miss_num_map(p1_a96);
    ddpx_line_rec.reference_header_id := rosetta_g_miss_num_map(p1_a97);
    ddpx_line_rec.reference_line_id := rosetta_g_miss_num_map(p1_a98);
    ddpx_line_rec.reference_type := p1_a99;
    ddpx_line_rec.request_date := rosetta_g_miss_date_in_map(p1_a100);
    ddpx_line_rec.request_id := rosetta_g_miss_num_map(p1_a101);
    ddpx_line_rec.reserved_quantity := rosetta_g_miss_num_map(p1_a102);
    ddpx_line_rec.return_reason_code := p1_a103;
    ddpx_line_rec.rla_schedule_type_code := p1_a104;
    ddpx_line_rec.salesrep_id := rosetta_g_miss_num_map(p1_a105);
    ddpx_line_rec.schedule_arrival_date := rosetta_g_miss_date_in_map(p1_a106);
    ddpx_line_rec.schedule_ship_date := rosetta_g_miss_date_in_map(p1_a107);
    ddpx_line_rec.schedule_action_code := p1_a108;
    ddpx_line_rec.schedule_status_code := p1_a109;
    ddpx_line_rec.shipment_number := rosetta_g_miss_num_map(p1_a110);
    ddpx_line_rec.shipment_priority_code := p1_a111;
    ddpx_line_rec.shipped_quantity := rosetta_g_miss_num_map(p1_a112);
    ddpx_line_rec.shipped_quantity2 := rosetta_g_miss_num_map(p1_a113);
    ddpx_line_rec.shipping_interfaced_flag := p1_a114;
    ddpx_line_rec.shipping_method_code := p1_a115;
    ddpx_line_rec.shipping_quantity := rosetta_g_miss_num_map(p1_a116);
    ddpx_line_rec.shipping_quantity2 := rosetta_g_miss_num_map(p1_a117);
    ddpx_line_rec.shipping_quantity_uom := p1_a118;
    ddpx_line_rec.shipping_quantity_uom2 := p1_a119;
    ddpx_line_rec.ship_from_org_id := rosetta_g_miss_num_map(p1_a120);
    ddpx_line_rec.ship_model_complete_flag := p1_a121;
    ddpx_line_rec.ship_set_id := rosetta_g_miss_num_map(p1_a122);
    ddpx_line_rec.fulfillment_set_id := rosetta_g_miss_num_map(p1_a123);
    ddpx_line_rec.ship_tolerance_above := rosetta_g_miss_num_map(p1_a124);
    ddpx_line_rec.ship_tolerance_below := rosetta_g_miss_num_map(p1_a125);
    ddpx_line_rec.ship_to_contact_id := rosetta_g_miss_num_map(p1_a126);
    ddpx_line_rec.ship_to_org_id := rosetta_g_miss_num_map(p1_a127);
    ddpx_line_rec.sold_to_org_id := rosetta_g_miss_num_map(p1_a128);
    ddpx_line_rec.sold_from_org_id := rosetta_g_miss_num_map(p1_a129);
    ddpx_line_rec.sort_order := p1_a130;
    ddpx_line_rec.source_document_id := rosetta_g_miss_num_map(p1_a131);
    ddpx_line_rec.source_document_line_id := rosetta_g_miss_num_map(p1_a132);
    ddpx_line_rec.source_document_type_id := rosetta_g_miss_num_map(p1_a133);
    ddpx_line_rec.source_type_code := p1_a134;
    ddpx_line_rec.split_from_line_id := rosetta_g_miss_num_map(p1_a135);
    ddpx_line_rec.task_id := rosetta_g_miss_num_map(p1_a136);
    ddpx_line_rec.tax_code := p1_a137;
    ddpx_line_rec.tax_date := rosetta_g_miss_date_in_map(p1_a138);
    ddpx_line_rec.tax_exempt_flag := p1_a139;
    ddpx_line_rec.tax_exempt_number := p1_a140;
    ddpx_line_rec.tax_exempt_reason_code := p1_a141;
    ddpx_line_rec.tax_point_code := p1_a142;
    ddpx_line_rec.tax_rate := rosetta_g_miss_num_map(p1_a143);
    ddpx_line_rec.tax_value := rosetta_g_miss_num_map(p1_a144);
    ddpx_line_rec.top_model_line_ref := p1_a145;
    ddpx_line_rec.top_model_line_id := rosetta_g_miss_num_map(p1_a146);
    ddpx_line_rec.top_model_line_index := rosetta_g_miss_num_map(p1_a147);
    ddpx_line_rec.unit_list_price := rosetta_g_miss_num_map(p1_a148);
    ddpx_line_rec.unit_list_price_per_pqty := rosetta_g_miss_num_map(p1_a149);
    ddpx_line_rec.unit_selling_price := rosetta_g_miss_num_map(p1_a150);
    ddpx_line_rec.unit_selling_price_per_pqty := rosetta_g_miss_num_map(p1_a151);
    ddpx_line_rec.veh_cus_item_cum_key_id := rosetta_g_miss_num_map(p1_a152);
    ddpx_line_rec.visible_demand_flag := p1_a153;
    ddpx_line_rec.return_status := p1_a154;
    ddpx_line_rec.db_flag := p1_a155;
    ddpx_line_rec.operation := p1_a156;
    ddpx_line_rec.first_ack_code := p1_a157;
    ddpx_line_rec.first_ack_date := rosetta_g_miss_date_in_map(p1_a158);
    ddpx_line_rec.last_ack_code := p1_a159;
    ddpx_line_rec.last_ack_date := rosetta_g_miss_date_in_map(p1_a160);
    ddpx_line_rec.change_reason := p1_a161;
    ddpx_line_rec.change_comments := p1_a162;
    ddpx_line_rec.arrival_set := p1_a163;
    ddpx_line_rec.ship_set := p1_a164;
    ddpx_line_rec.fulfillment_set := p1_a165;
    ddpx_line_rec.order_source_id := rosetta_g_miss_num_map(p1_a166);
    ddpx_line_rec.orig_sys_shipment_ref := p1_a167;
    ddpx_line_rec.change_sequence := p1_a168;
    ddpx_line_rec.change_request_code := p1_a169;
    ddpx_line_rec.status_flag := p1_a170;
    ddpx_line_rec.drop_ship_flag := p1_a171;
    ddpx_line_rec.customer_line_number := p1_a172;
    ddpx_line_rec.customer_shipment_number := p1_a173;
    ddpx_line_rec.customer_item_net_price := rosetta_g_miss_num_map(p1_a174);
    ddpx_line_rec.customer_payment_term_id := rosetta_g_miss_num_map(p1_a175);
    ddpx_line_rec.ordered_item_id := rosetta_g_miss_num_map(p1_a176);
    ddpx_line_rec.item_identifier_type := p1_a177;
    ddpx_line_rec.shipping_instructions := p1_a178;
    ddpx_line_rec.packing_instructions := p1_a179;
    ddpx_line_rec.calculate_price_flag := p1_a180;
    ddpx_line_rec.invoiced_quantity := rosetta_g_miss_num_map(p1_a181);
    ddpx_line_rec.service_txn_reason_code := p1_a182;
    ddpx_line_rec.service_txn_comments := p1_a183;
    ddpx_line_rec.service_duration := rosetta_g_miss_num_map(p1_a184);
    ddpx_line_rec.service_period := p1_a185;
    ddpx_line_rec.service_start_date := rosetta_g_miss_date_in_map(p1_a186);
    ddpx_line_rec.service_end_date := rosetta_g_miss_date_in_map(p1_a187);
    ddpx_line_rec.service_coterminate_flag := p1_a188;
    ddpx_line_rec.unit_list_percent := rosetta_g_miss_num_map(p1_a189);
    ddpx_line_rec.unit_selling_percent := rosetta_g_miss_num_map(p1_a190);
    ddpx_line_rec.unit_percent_base_price := rosetta_g_miss_num_map(p1_a191);
    ddpx_line_rec.service_number := rosetta_g_miss_num_map(p1_a192);
    ddpx_line_rec.service_reference_type_code := p1_a193;
    ddpx_line_rec.service_reference_line_id := rosetta_g_miss_num_map(p1_a194);
    ddpx_line_rec.service_reference_system_id := rosetta_g_miss_num_map(p1_a195);
    ddpx_line_rec.service_ref_order_number := rosetta_g_miss_num_map(p1_a196);
    ddpx_line_rec.service_ref_line_number := rosetta_g_miss_num_map(p1_a197);
    ddpx_line_rec.service_reference_order := p1_a198;
    ddpx_line_rec.service_reference_line := p1_a199;
    ddpx_line_rec.service_reference_system := p1_a200;
    ddpx_line_rec.service_ref_shipment_number := rosetta_g_miss_num_map(p1_a201);
    ddpx_line_rec.service_ref_option_number := rosetta_g_miss_num_map(p1_a202);
    ddpx_line_rec.service_line_index := rosetta_g_miss_num_map(p1_a203);
    ddpx_line_rec.line_set_id := rosetta_g_miss_num_map(p1_a204);
    ddpx_line_rec.split_by := p1_a205;
    ddpx_line_rec.split_action_code := p1_a206;
    ddpx_line_rec.shippable_flag := p1_a207;
    ddpx_line_rec.model_remnant_flag := p1_a208;
    ddpx_line_rec.flow_status_code := p1_a209;
    ddpx_line_rec.fulfilled_flag := p1_a210;
    ddpx_line_rec.fulfillment_method_code := p1_a211;
    ddpx_line_rec.revenue_amount := rosetta_g_miss_num_map(p1_a212);
    ddpx_line_rec.marketing_source_code_id := rosetta_g_miss_num_map(p1_a213);
    ddpx_line_rec.fulfillment_date := rosetta_g_miss_date_in_map(p1_a214);
    if p1_a215 is null
      then ddpx_line_rec.semi_processed_flag := null;
    elsif p1_a215 = 0
      then ddpx_line_rec.semi_processed_flag := false;
    else ddpx_line_rec.semi_processed_flag := true;
    end if;
    ddpx_line_rec.upgraded_flag := p1_a216;
    ddpx_line_rec.lock_control := rosetta_g_miss_num_map(p1_a217);
    ddpx_line_rec.subinventory := p1_a218;
    ddpx_line_rec.split_from_line_ref := p1_a219;
    ddpx_line_rec.split_from_shipment_ref := p1_a220;
    ddpx_line_rec.ship_to_edi_location_code := p1_a221;
    ddpx_line_rec.bill_to_edi_location_code := p1_a222;
    ddpx_line_rec.ship_from_edi_location_code := p1_a223;
    ddpx_line_rec.ship_from_address_id := rosetta_g_miss_num_map(p1_a224);
    ddpx_line_rec.sold_to_address_id := rosetta_g_miss_num_map(p1_a225);
    ddpx_line_rec.ship_to_address_id := rosetta_g_miss_num_map(p1_a226);
    ddpx_line_rec.invoice_address_id := rosetta_g_miss_num_map(p1_a227);
    ddpx_line_rec.ship_to_address_code := p1_a228;
    ddpx_line_rec.original_inventory_item_id := rosetta_g_miss_num_map(p1_a229);
    ddpx_line_rec.original_item_identifier_type := p1_a230;
    ddpx_line_rec.original_ordered_item_id := rosetta_g_miss_num_map(p1_a231);
    ddpx_line_rec.original_ordered_item := p1_a232;
    ddpx_line_rec.item_substitution_type_code := p1_a233;
    ddpx_line_rec.late_demand_penalty_factor := rosetta_g_miss_num_map(p1_a234);
    ddpx_line_rec.override_atp_date_code := p1_a235;
    ddpx_line_rec.ship_to_customer_id := rosetta_g_miss_num_map(p1_a236);
    ddpx_line_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p1_a237);
    ddpx_line_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p1_a238);
    ddpx_line_rec.accounting_rule_duration := rosetta_g_miss_num_map(p1_a239);
    ddpx_line_rec.unit_cost := rosetta_g_miss_num_map(p1_a240);
    ddpx_line_rec.user_item_description := p1_a241;
    ddpx_line_rec.xml_transaction_type_code := p1_a242;
    ddpx_line_rec.item_relationship_type := rosetta_g_miss_num_map(p1_a243);
    ddpx_line_rec.blanket_number := rosetta_g_miss_num_map(p1_a244);
    ddpx_line_rec.blanket_line_number := rosetta_g_miss_num_map(p1_a245);
    ddpx_line_rec.blanket_version_number := rosetta_g_miss_num_map(p1_a246);
    ddpx_line_rec.cso_response_flag := p1_a247;
    ddpx_line_rec.firm_demand_flag := p1_a248;
    ddpx_line_rec.earliest_ship_date := rosetta_g_miss_date_in_map(p1_a249);
    ddpx_line_rec.transaction_phase_code := p1_a250;
    ddpx_line_rec.source_document_version_number := rosetta_g_miss_num_map(p1_a251);
    ddpx_line_rec.minisite_id := rosetta_g_miss_num_map(p1_a252);
    ddpx_line_rec.ib_owner := p1_a253;
    ddpx_line_rec.ib_installed_at_location := p1_a254;
    ddpx_line_rec.ib_current_location := p1_a255;
    ddpx_line_rec.end_customer_id := rosetta_g_miss_num_map(p1_a256);
    ddpx_line_rec.end_customer_contact_id := rosetta_g_miss_num_map(p1_a257);
    ddpx_line_rec.end_customer_site_use_id := rosetta_g_miss_num_map(p1_a258);
    ddpx_line_rec.supplier_signature := p1_a259;
    ddpx_line_rec.supplier_signature_date := rosetta_g_miss_date_in_map(p1_a260);
    ddpx_line_rec.customer_signature := p1_a261;
    ddpx_line_rec.customer_signature_date := rosetta_g_miss_date_in_map(p1_a262);
    ddpx_line_rec.ship_to_party_id := rosetta_g_miss_num_map(p1_a263);
    ddpx_line_rec.ship_to_party_site_id := rosetta_g_miss_num_map(p1_a264);
    ddpx_line_rec.ship_to_party_site_use_id := rosetta_g_miss_num_map(p1_a265);
    ddpx_line_rec.deliver_to_party_id := rosetta_g_miss_num_map(p1_a266);
    ddpx_line_rec.deliver_to_party_site_id := rosetta_g_miss_num_map(p1_a267);
    ddpx_line_rec.deliver_to_party_site_use_id := rosetta_g_miss_num_map(p1_a268);
    ddpx_line_rec.invoice_to_party_id := rosetta_g_miss_num_map(p1_a269);
    ddpx_line_rec.invoice_to_party_site_id := rosetta_g_miss_num_map(p1_a270);
    ddpx_line_rec.invoice_to_party_site_use_id := rosetta_g_miss_num_map(p1_a271);
    ddpx_line_rec.ship_to_customer_party_id := rosetta_g_miss_num_map(p1_a272);
    ddpx_line_rec.deliver_to_customer_party_id := rosetta_g_miss_num_map(p1_a273);
    ddpx_line_rec.invoice_to_customer_party_id := rosetta_g_miss_num_map(p1_a274);
    ddpx_line_rec.ship_to_org_contact_id := rosetta_g_miss_num_map(p1_a275);
    ddpx_line_rec.deliver_to_org_contact_id := rosetta_g_miss_num_map(p1_a276);
    ddpx_line_rec.invoice_to_org_contact_id := rosetta_g_miss_num_map(p1_a277);
    ddpx_line_rec.retrobill_request_id := rosetta_g_miss_num_map(p1_a278);
    ddpx_line_rec.original_list_price := rosetta_g_miss_num_map(p1_a279);
    ddpx_line_rec.commitment_applied_amount := rosetta_g_miss_num_map(p1_a280);

    oe_order_pub_w.rosetta_table_copy_in_p23(ddpx_line_adj_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      , p2_a32
      , p2_a33
      , p2_a34
      , p2_a35
      , p2_a36
      , p2_a37
      , p2_a38
      , p2_a39
      , p2_a40
      , p2_a41
      , p2_a42
      , p2_a43
      , p2_a44
      , p2_a45
      , p2_a46
      , p2_a47
      , p2_a48
      , p2_a49
      , p2_a50
      , p2_a51
      , p2_a52
      , p2_a53
      , p2_a54
      , p2_a55
      , p2_a56
      , p2_a57
      , p2_a58
      , p2_a59
      , p2_a60
      , p2_a61
      , p2_a62
      , p2_a63
      , p2_a64
      , p2_a65
      , p2_a66
      , p2_a67
      , p2_a68
      , p2_a69
      , p2_a70
      , p2_a71
      , p2_a72
      , p2_a73
      , p2_a74
      , p2_a75
      , p2_a76
      , p2_a77
      , p2_a78
      , p2_a79
      , p2_a80
      , p2_a81
      , p2_a82
      , p2_a83
      , p2_a84
      , p2_a85
      , p2_a86
      , p2_a87
      , p2_a88
      , p2_a89
      , p2_a90
      , p2_a91
      , p2_a92
      , p2_a93
      , p2_a94
      , p2_a95
      , p2_a96
      , p2_a97
      , p2_a98
      , p2_a99
      , p2_a100
      , p2_a101
      , p2_a102
      , p2_a103
      , p2_a104
      , p2_a105
      , p2_a106
      , p2_a107
      , p2_a108
      );

    oe_price_order_pvt_w_obsolete.rosetta_table_copy_in_p3(ddp_line_price_att_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      );






    -- here's the delegated call to the old PL/SQL routine
    oe_price_order_pvt.price_order(ddpx_header_rec,
      ddpx_line_rec,
      ddpx_line_adj_tbl,
      ddp_line_price_att_tbl,
      p_action_code,
      p_pricing_events,
      p_simulation_flag,
      p_get_freight_flag,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddpx_header_rec.accounting_rule_id);
    p0_a1 := rosetta_g_miss_num_map(ddpx_header_rec.agreement_id);
    p0_a2 := ddpx_header_rec.attribute1;
    p0_a3 := ddpx_header_rec.attribute10;
    p0_a4 := ddpx_header_rec.attribute11;
    p0_a5 := ddpx_header_rec.attribute12;
    p0_a6 := ddpx_header_rec.attribute13;
    p0_a7 := ddpx_header_rec.attribute14;
    p0_a8 := ddpx_header_rec.attribute15;
    p0_a9 := ddpx_header_rec.attribute16;
    p0_a10 := ddpx_header_rec.attribute17;
    p0_a11 := ddpx_header_rec.attribute18;
    p0_a12 := ddpx_header_rec.attribute19;
    p0_a13 := ddpx_header_rec.attribute2;
    p0_a14 := ddpx_header_rec.attribute20;
    p0_a15 := ddpx_header_rec.attribute3;
    p0_a16 := ddpx_header_rec.attribute4;
    p0_a17 := ddpx_header_rec.attribute5;
    p0_a18 := ddpx_header_rec.attribute6;
    p0_a19 := ddpx_header_rec.attribute7;
    p0_a20 := ddpx_header_rec.attribute8;
    p0_a21 := ddpx_header_rec.attribute9;
    p0_a22 := ddpx_header_rec.booked_flag;
    p0_a23 := ddpx_header_rec.cancelled_flag;
    p0_a24 := ddpx_header_rec.context;
    p0_a25 := rosetta_g_miss_num_map(ddpx_header_rec.conversion_rate);
    p0_a26 := ddpx_header_rec.conversion_rate_date;
    p0_a27 := ddpx_header_rec.conversion_type_code;
    p0_a28 := ddpx_header_rec.customer_preference_set_code;
    p0_a29 := rosetta_g_miss_num_map(ddpx_header_rec.created_by);
    p0_a30 := ddpx_header_rec.creation_date;
    p0_a31 := ddpx_header_rec.cust_po_number;
    p0_a32 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_contact_id);
    p0_a33 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_org_id);
    p0_a34 := ddpx_header_rec.demand_class_code;
    p0_a35 := rosetta_g_miss_num_map(ddpx_header_rec.earliest_schedule_limit);
    p0_a36 := ddpx_header_rec.expiration_date;
    p0_a37 := ddpx_header_rec.fob_point_code;
    p0_a38 := ddpx_header_rec.freight_carrier_code;
    p0_a39 := ddpx_header_rec.freight_terms_code;
    p0_a40 := ddpx_header_rec.global_attribute1;
    p0_a41 := ddpx_header_rec.global_attribute10;
    p0_a42 := ddpx_header_rec.global_attribute11;
    p0_a43 := ddpx_header_rec.global_attribute12;
    p0_a44 := ddpx_header_rec.global_attribute13;
    p0_a45 := ddpx_header_rec.global_attribute14;
    p0_a46 := ddpx_header_rec.global_attribute15;
    p0_a47 := ddpx_header_rec.global_attribute16;
    p0_a48 := ddpx_header_rec.global_attribute17;
    p0_a49 := ddpx_header_rec.global_attribute18;
    p0_a50 := ddpx_header_rec.global_attribute19;
    p0_a51 := ddpx_header_rec.global_attribute2;
    p0_a52 := ddpx_header_rec.global_attribute20;
    p0_a53 := ddpx_header_rec.global_attribute3;
    p0_a54 := ddpx_header_rec.global_attribute4;
    p0_a55 := ddpx_header_rec.global_attribute5;
    p0_a56 := ddpx_header_rec.global_attribute6;
    p0_a57 := ddpx_header_rec.global_attribute7;
    p0_a58 := ddpx_header_rec.global_attribute8;
    p0_a59 := ddpx_header_rec.global_attribute9;
    p0_a60 := ddpx_header_rec.global_attribute_category;
    p0_a61 := ddpx_header_rec.tp_context;
    p0_a62 := ddpx_header_rec.tp_attribute1;
    p0_a63 := ddpx_header_rec.tp_attribute2;
    p0_a64 := ddpx_header_rec.tp_attribute3;
    p0_a65 := ddpx_header_rec.tp_attribute4;
    p0_a66 := ddpx_header_rec.tp_attribute5;
    p0_a67 := ddpx_header_rec.tp_attribute6;
    p0_a68 := ddpx_header_rec.tp_attribute7;
    p0_a69 := ddpx_header_rec.tp_attribute8;
    p0_a70 := ddpx_header_rec.tp_attribute9;
    p0_a71 := ddpx_header_rec.tp_attribute10;
    p0_a72 := ddpx_header_rec.tp_attribute11;
    p0_a73 := ddpx_header_rec.tp_attribute12;
    p0_a74 := ddpx_header_rec.tp_attribute13;
    p0_a75 := ddpx_header_rec.tp_attribute14;
    p0_a76 := ddpx_header_rec.tp_attribute15;
    p0_a77 := rosetta_g_miss_num_map(ddpx_header_rec.header_id);
    p0_a78 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_contact_id);
    p0_a79 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_org_id);
    p0_a80 := rosetta_g_miss_num_map(ddpx_header_rec.invoicing_rule_id);
    p0_a81 := rosetta_g_miss_num_map(ddpx_header_rec.last_updated_by);
    p0_a82 := ddpx_header_rec.last_update_date;
    p0_a83 := rosetta_g_miss_num_map(ddpx_header_rec.last_update_login);
    p0_a84 := rosetta_g_miss_num_map(ddpx_header_rec.latest_schedule_limit);
    p0_a85 := ddpx_header_rec.open_flag;
    p0_a86 := ddpx_header_rec.order_category_code;
    p0_a87 := ddpx_header_rec.ordered_date;
    p0_a88 := ddpx_header_rec.order_date_type_code;
    p0_a89 := rosetta_g_miss_num_map(ddpx_header_rec.order_number);
    p0_a90 := rosetta_g_miss_num_map(ddpx_header_rec.order_source_id);
    p0_a91 := rosetta_g_miss_num_map(ddpx_header_rec.order_type_id);
    p0_a92 := rosetta_g_miss_num_map(ddpx_header_rec.org_id);
    p0_a93 := ddpx_header_rec.orig_sys_document_ref;
    p0_a94 := ddpx_header_rec.partial_shipments_allowed;
    p0_a95 := rosetta_g_miss_num_map(ddpx_header_rec.payment_term_id);
    p0_a96 := rosetta_g_miss_num_map(ddpx_header_rec.price_list_id);
    p0_a97 := ddpx_header_rec.price_request_code;
    p0_a98 := ddpx_header_rec.pricing_date;
    p0_a99 := rosetta_g_miss_num_map(ddpx_header_rec.program_application_id);
    p0_a100 := rosetta_g_miss_num_map(ddpx_header_rec.program_id);
    p0_a101 := ddpx_header_rec.program_update_date;
    p0_a102 := ddpx_header_rec.request_date;
    p0_a103 := rosetta_g_miss_num_map(ddpx_header_rec.request_id);
    p0_a104 := ddpx_header_rec.return_reason_code;
    p0_a105 := rosetta_g_miss_num_map(ddpx_header_rec.salesrep_id);
    p0_a106 := ddpx_header_rec.sales_channel_code;
    p0_a107 := ddpx_header_rec.shipment_priority_code;
    p0_a108 := ddpx_header_rec.shipping_method_code;
    p0_a109 := rosetta_g_miss_num_map(ddpx_header_rec.ship_from_org_id);
    p0_a110 := rosetta_g_miss_num_map(ddpx_header_rec.ship_tolerance_above);
    p0_a111 := rosetta_g_miss_num_map(ddpx_header_rec.ship_tolerance_below);
    p0_a112 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_contact_id);
    p0_a113 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_org_id);
    p0_a114 := rosetta_g_miss_num_map(ddpx_header_rec.sold_from_org_id);
    p0_a115 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_contact_id);
    p0_a116 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_org_id);
    p0_a117 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_phone_id);
    p0_a118 := rosetta_g_miss_num_map(ddpx_header_rec.source_document_id);
    p0_a119 := rosetta_g_miss_num_map(ddpx_header_rec.source_document_type_id);
    p0_a120 := ddpx_header_rec.tax_exempt_flag;
    p0_a121 := ddpx_header_rec.tax_exempt_number;
    p0_a122 := ddpx_header_rec.tax_exempt_reason_code;
    p0_a123 := ddpx_header_rec.tax_point_code;
    p0_a124 := ddpx_header_rec.transactional_curr_code;
    p0_a125 := rosetta_g_miss_num_map(ddpx_header_rec.version_number);
    p0_a126 := ddpx_header_rec.return_status;
    p0_a127 := ddpx_header_rec.db_flag;
    p0_a128 := ddpx_header_rec.operation;
    p0_a129 := ddpx_header_rec.first_ack_code;
    p0_a130 := ddpx_header_rec.first_ack_date;
    p0_a131 := ddpx_header_rec.last_ack_code;
    p0_a132 := ddpx_header_rec.last_ack_date;
    p0_a133 := ddpx_header_rec.change_reason;
    p0_a134 := ddpx_header_rec.change_comments;
    p0_a135 := ddpx_header_rec.change_sequence;
    p0_a136 := ddpx_header_rec.change_request_code;
    p0_a137 := ddpx_header_rec.ready_flag;
    p0_a138 := ddpx_header_rec.status_flag;
    p0_a139 := ddpx_header_rec.force_apply_flag;
    p0_a140 := ddpx_header_rec.drop_ship_flag;
    p0_a141 := rosetta_g_miss_num_map(ddpx_header_rec.customer_payment_term_id);
    p0_a142 := ddpx_header_rec.payment_type_code;
    p0_a143 := rosetta_g_miss_num_map(ddpx_header_rec.payment_amount);
    p0_a144 := ddpx_header_rec.check_number;
    p0_a145 := ddpx_header_rec.credit_card_code;
    p0_a146 := ddpx_header_rec.credit_card_holder_name;
    p0_a147 := ddpx_header_rec.credit_card_number;
    p0_a148 := ddpx_header_rec.credit_card_expiration_date;
    p0_a149 := ddpx_header_rec.credit_card_approval_code;
    p0_a150 := ddpx_header_rec.credit_card_approval_date;
    p0_a151 := ddpx_header_rec.shipping_instructions;
    p0_a152 := ddpx_header_rec.packing_instructions;
    p0_a153 := ddpx_header_rec.flow_status_code;
    p0_a154 := ddpx_header_rec.booked_date;
    p0_a155 := rosetta_g_miss_num_map(ddpx_header_rec.marketing_source_code_id);
    p0_a156 := ddpx_header_rec.upgraded_flag;
    p0_a157 := rosetta_g_miss_num_map(ddpx_header_rec.lock_control);
    p0_a158 := ddpx_header_rec.ship_to_edi_location_code;
    p0_a159 := ddpx_header_rec.sold_to_edi_location_code;
    p0_a160 := ddpx_header_rec.bill_to_edi_location_code;
    p0_a161 := ddpx_header_rec.ship_from_edi_location_code;
    p0_a162 := rosetta_g_miss_num_map(ddpx_header_rec.ship_from_address_id);
    p0_a163 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_address_id);
    p0_a164 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_address_id);
    p0_a165 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_address_id);
    p0_a166 := ddpx_header_rec.ship_to_address_code;
    p0_a167 := rosetta_g_miss_num_map(ddpx_header_rec.xml_message_id);
    p0_a168 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_customer_id);
    p0_a169 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_customer_id);
    p0_a170 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_customer_id);
    p0_a171 := rosetta_g_miss_num_map(ddpx_header_rec.accounting_rule_duration);
    p0_a172 := ddpx_header_rec.xml_transaction_type_code;
    p0_a173 := rosetta_g_miss_num_map(ddpx_header_rec.blanket_number);
    p0_a174 := ddpx_header_rec.line_set_name;
    p0_a175 := ddpx_header_rec.fulfillment_set_name;
    p0_a176 := ddpx_header_rec.default_fulfillment_set;
    p0_a177 := ddpx_header_rec.quote_date;
    p0_a178 := rosetta_g_miss_num_map(ddpx_header_rec.quote_number);
    p0_a179 := ddpx_header_rec.sales_document_name;
    p0_a180 := ddpx_header_rec.transaction_phase_code;
    p0_a181 := ddpx_header_rec.user_status_code;
    p0_a182 := ddpx_header_rec.draft_submitted_flag;
    p0_a183 := rosetta_g_miss_num_map(ddpx_header_rec.source_document_version_number);
    p0_a184 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_site_use_id);
    p0_a185 := rosetta_g_miss_num_map(ddpx_header_rec.minisite_id);
    p0_a186 := ddpx_header_rec.ib_owner;
    p0_a187 := ddpx_header_rec.ib_installed_at_location;
    p0_a188 := ddpx_header_rec.ib_current_location;
    p0_a189 := rosetta_g_miss_num_map(ddpx_header_rec.end_customer_id);
    p0_a190 := rosetta_g_miss_num_map(ddpx_header_rec.end_customer_contact_id);
    p0_a191 := rosetta_g_miss_num_map(ddpx_header_rec.end_customer_site_use_id);
    p0_a192 := ddpx_header_rec.supplier_signature;
    p0_a193 := ddpx_header_rec.supplier_signature_date;
    p0_a194 := ddpx_header_rec.customer_signature;
    p0_a195 := ddpx_header_rec.customer_signature_date;
    p0_a196 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_party_id);
    p0_a197 := rosetta_g_miss_num_map(ddpx_header_rec.sold_to_org_contact_id);
    p0_a198 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_party_id);
    p0_a199 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_party_site_id);
    p0_a200 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_party_site_use_id);
    p0_a201 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_party_id);
    p0_a202 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_party_site_id);
    p0_a203 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_party_site_use_id);
    p0_a204 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_party_id);
    p0_a205 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_party_site_id);
    p0_a206 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_party_site_use_id);
    p0_a207 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_customer_party_id);
    p0_a208 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_customer_party_id);
    p0_a209 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_customer_party_id);
    p0_a210 := rosetta_g_miss_num_map(ddpx_header_rec.ship_to_org_contact_id);
    p0_a211 := rosetta_g_miss_num_map(ddpx_header_rec.deliver_to_org_contact_id);
    p0_a212 := rosetta_g_miss_num_map(ddpx_header_rec.invoice_to_org_contact_id);
    p0_a213 := rosetta_g_miss_num_map(ddpx_header_rec.contract_template_id);
    p0_a214 := ddpx_header_rec.contract_source_doc_type_code;
    p0_a215 := rosetta_g_miss_num_map(ddpx_header_rec.contract_source_document_id);

    p1_a0 := rosetta_g_miss_num_map(ddpx_line_rec.accounting_rule_id);
    p1_a1 := ddpx_line_rec.actual_arrival_date;
    p1_a2 := ddpx_line_rec.actual_shipment_date;
    p1_a3 := rosetta_g_miss_num_map(ddpx_line_rec.agreement_id);
    p1_a4 := rosetta_g_miss_num_map(ddpx_line_rec.arrival_set_id);
    p1_a5 := rosetta_g_miss_num_map(ddpx_line_rec.ato_line_id);
    p1_a6 := ddpx_line_rec.authorized_to_ship_flag;
    p1_a7 := rosetta_g_miss_num_map(ddpx_line_rec.auto_selected_quantity);
    p1_a8 := ddpx_line_rec.booked_flag;
    p1_a9 := ddpx_line_rec.cancelled_flag;
    p1_a10 := rosetta_g_miss_num_map(ddpx_line_rec.cancelled_quantity);
    p1_a11 := rosetta_g_miss_num_map(ddpx_line_rec.cancelled_quantity2);
    p1_a12 := rosetta_g_miss_num_map(ddpx_line_rec.commitment_id);
    p1_a13 := ddpx_line_rec.component_code;
    p1_a14 := rosetta_g_miss_num_map(ddpx_line_rec.component_number);
    p1_a15 := rosetta_g_miss_num_map(ddpx_line_rec.component_sequence_id);
    p1_a16 := rosetta_g_miss_num_map(ddpx_line_rec.config_header_id);
    p1_a17 := rosetta_g_miss_num_map(ddpx_line_rec.config_rev_nbr);
    p1_a18 := rosetta_g_miss_num_map(ddpx_line_rec.config_display_sequence);
    p1_a19 := rosetta_g_miss_num_map(ddpx_line_rec.configuration_id);
    p1_a20 := ddpx_line_rec.context;
    p1_a21 := rosetta_g_miss_num_map(ddpx_line_rec.created_by);
    p1_a22 := ddpx_line_rec.creation_date;
    p1_a23 := rosetta_g_miss_num_map(ddpx_line_rec.credit_invoice_line_id);
    p1_a24 := ddpx_line_rec.customer_dock_code;
    p1_a25 := ddpx_line_rec.customer_job;
    p1_a26 := ddpx_line_rec.customer_production_line;
    p1_a27 := rosetta_g_miss_num_map(ddpx_line_rec.customer_trx_line_id);
    p1_a28 := ddpx_line_rec.cust_model_serial_number;
    p1_a29 := ddpx_line_rec.cust_po_number;
    p1_a30 := ddpx_line_rec.cust_production_seq_num;
    p1_a31 := rosetta_g_miss_num_map(ddpx_line_rec.delivery_lead_time);
    p1_a32 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_contact_id);
    p1_a33 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_org_id);
    p1_a34 := ddpx_line_rec.demand_bucket_type_code;
    p1_a35 := ddpx_line_rec.demand_class_code;
    p1_a36 := ddpx_line_rec.dep_plan_required_flag;
    p1_a37 := ddpx_line_rec.earliest_acceptable_date;
    p1_a38 := ddpx_line_rec.end_item_unit_number;
    p1_a39 := ddpx_line_rec.explosion_date;
    p1_a40 := ddpx_line_rec.fob_point_code;
    p1_a41 := ddpx_line_rec.freight_carrier_code;
    p1_a42 := ddpx_line_rec.freight_terms_code;
    p1_a43 := rosetta_g_miss_num_map(ddpx_line_rec.fulfilled_quantity);
    p1_a44 := rosetta_g_miss_num_map(ddpx_line_rec.fulfilled_quantity2);
    p1_a45 := rosetta_g_miss_num_map(ddpx_line_rec.header_id);
    p1_a46 := rosetta_g_miss_num_map(ddpx_line_rec.intermed_ship_to_org_id);
    p1_a47 := rosetta_g_miss_num_map(ddpx_line_rec.intermed_ship_to_contact_id);
    p1_a48 := rosetta_g_miss_num_map(ddpx_line_rec.inventory_item_id);
    p1_a49 := ddpx_line_rec.invoice_interface_status_code;
    p1_a50 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_contact_id);
    p1_a51 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_org_id);
    p1_a52 := rosetta_g_miss_num_map(ddpx_line_rec.invoicing_rule_id);
    p1_a53 := ddpx_line_rec.ordered_item;
    p1_a54 := ddpx_line_rec.item_revision;
    p1_a55 := ddpx_line_rec.item_type_code;
    p1_a56 := rosetta_g_miss_num_map(ddpx_line_rec.last_updated_by);
    p1_a57 := ddpx_line_rec.last_update_date;
    p1_a58 := rosetta_g_miss_num_map(ddpx_line_rec.last_update_login);
    p1_a59 := ddpx_line_rec.latest_acceptable_date;
    p1_a60 := ddpx_line_rec.line_category_code;
    p1_a61 := rosetta_g_miss_num_map(ddpx_line_rec.line_id);
    p1_a62 := rosetta_g_miss_num_map(ddpx_line_rec.line_number);
    p1_a63 := rosetta_g_miss_num_map(ddpx_line_rec.line_type_id);
    p1_a64 := ddpx_line_rec.link_to_line_ref;
    p1_a65 := rosetta_g_miss_num_map(ddpx_line_rec.link_to_line_id);
    p1_a66 := rosetta_g_miss_num_map(ddpx_line_rec.link_to_line_index);
    p1_a67 := rosetta_g_miss_num_map(ddpx_line_rec.model_group_number);
    p1_a68 := rosetta_g_miss_num_map(ddpx_line_rec.mfg_component_sequence_id);
    p1_a69 := rosetta_g_miss_num_map(ddpx_line_rec.mfg_lead_time);
    p1_a70 := ddpx_line_rec.open_flag;
    p1_a71 := ddpx_line_rec.option_flag;
    p1_a72 := rosetta_g_miss_num_map(ddpx_line_rec.option_number);
    p1_a73 := rosetta_g_miss_num_map(ddpx_line_rec.ordered_quantity);
    p1_a74 := rosetta_g_miss_num_map(ddpx_line_rec.ordered_quantity2);
    p1_a75 := ddpx_line_rec.order_quantity_uom;
    p1_a76 := ddpx_line_rec.ordered_quantity_uom2;
    p1_a77 := rosetta_g_miss_num_map(ddpx_line_rec.org_id);
    p1_a78 := ddpx_line_rec.orig_sys_document_ref;
    p1_a79 := ddpx_line_rec.orig_sys_line_ref;
    p1_a80 := ddpx_line_rec.over_ship_reason_code;
    p1_a81 := ddpx_line_rec.over_ship_resolved_flag;
    p1_a82 := rosetta_g_miss_num_map(ddpx_line_rec.payment_term_id);
    p1_a83 := rosetta_g_miss_num_map(ddpx_line_rec.planning_priority);
    p1_a84 := ddpx_line_rec.preferred_grade;
    p1_a85 := rosetta_g_miss_num_map(ddpx_line_rec.price_list_id);
    p1_a86 := ddpx_line_rec.price_request_code;
    p1_a87 := ddpx_line_rec.pricing_date;
    p1_a88 := rosetta_g_miss_num_map(ddpx_line_rec.pricing_quantity);
    p1_a89 := ddpx_line_rec.pricing_quantity_uom;
    p1_a90 := rosetta_g_miss_num_map(ddpx_line_rec.program_application_id);
    p1_a91 := rosetta_g_miss_num_map(ddpx_line_rec.program_id);
    p1_a92 := ddpx_line_rec.program_update_date;
    p1_a93 := rosetta_g_miss_num_map(ddpx_line_rec.project_id);
    p1_a94 := ddpx_line_rec.promise_date;
    p1_a95 := ddpx_line_rec.re_source_flag;
    p1_a96 := rosetta_g_miss_num_map(ddpx_line_rec.reference_customer_trx_line_id);
    p1_a97 := rosetta_g_miss_num_map(ddpx_line_rec.reference_header_id);
    p1_a98 := rosetta_g_miss_num_map(ddpx_line_rec.reference_line_id);
    p1_a99 := ddpx_line_rec.reference_type;
    p1_a100 := ddpx_line_rec.request_date;
    p1_a101 := rosetta_g_miss_num_map(ddpx_line_rec.request_id);
    p1_a102 := rosetta_g_miss_num_map(ddpx_line_rec.reserved_quantity);
    p1_a103 := ddpx_line_rec.return_reason_code;
    p1_a104 := ddpx_line_rec.rla_schedule_type_code;
    p1_a105 := rosetta_g_miss_num_map(ddpx_line_rec.salesrep_id);
    p1_a106 := ddpx_line_rec.schedule_arrival_date;
    p1_a107 := ddpx_line_rec.schedule_ship_date;
    p1_a108 := ddpx_line_rec.schedule_action_code;
    p1_a109 := ddpx_line_rec.schedule_status_code;
    p1_a110 := rosetta_g_miss_num_map(ddpx_line_rec.shipment_number);
    p1_a111 := ddpx_line_rec.shipment_priority_code;
    p1_a112 := rosetta_g_miss_num_map(ddpx_line_rec.shipped_quantity);
    p1_a113 := rosetta_g_miss_num_map(ddpx_line_rec.shipped_quantity2);
    p1_a114 := ddpx_line_rec.shipping_interfaced_flag;
    p1_a115 := ddpx_line_rec.shipping_method_code;
    p1_a116 := rosetta_g_miss_num_map(ddpx_line_rec.shipping_quantity);
    p1_a117 := rosetta_g_miss_num_map(ddpx_line_rec.shipping_quantity2);
    p1_a118 := ddpx_line_rec.shipping_quantity_uom;
    p1_a119 := ddpx_line_rec.shipping_quantity_uom2;
    p1_a120 := rosetta_g_miss_num_map(ddpx_line_rec.ship_from_org_id);
    p1_a121 := ddpx_line_rec.ship_model_complete_flag;
    p1_a122 := rosetta_g_miss_num_map(ddpx_line_rec.ship_set_id);
    p1_a123 := rosetta_g_miss_num_map(ddpx_line_rec.fulfillment_set_id);
    p1_a124 := rosetta_g_miss_num_map(ddpx_line_rec.ship_tolerance_above);
    p1_a125 := rosetta_g_miss_num_map(ddpx_line_rec.ship_tolerance_below);
    p1_a126 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_contact_id);
    p1_a127 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_org_id);
    p1_a128 := rosetta_g_miss_num_map(ddpx_line_rec.sold_to_org_id);
    p1_a129 := rosetta_g_miss_num_map(ddpx_line_rec.sold_from_org_id);
    p1_a130 := ddpx_line_rec.sort_order;
    p1_a131 := rosetta_g_miss_num_map(ddpx_line_rec.source_document_id);
    p1_a132 := rosetta_g_miss_num_map(ddpx_line_rec.source_document_line_id);
    p1_a133 := rosetta_g_miss_num_map(ddpx_line_rec.source_document_type_id);
    p1_a134 := ddpx_line_rec.source_type_code;
    p1_a135 := rosetta_g_miss_num_map(ddpx_line_rec.split_from_line_id);
    p1_a136 := rosetta_g_miss_num_map(ddpx_line_rec.task_id);
    p1_a137 := ddpx_line_rec.tax_code;
    p1_a138 := ddpx_line_rec.tax_date;
    p1_a139 := ddpx_line_rec.tax_exempt_flag;
    p1_a140 := ddpx_line_rec.tax_exempt_number;
    p1_a141 := ddpx_line_rec.tax_exempt_reason_code;
    p1_a142 := ddpx_line_rec.tax_point_code;
    p1_a143 := rosetta_g_miss_num_map(ddpx_line_rec.tax_rate);
    p1_a144 := rosetta_g_miss_num_map(ddpx_line_rec.tax_value);
    p1_a145 := ddpx_line_rec.top_model_line_ref;
    p1_a146 := rosetta_g_miss_num_map(ddpx_line_rec.top_model_line_id);
    p1_a147 := rosetta_g_miss_num_map(ddpx_line_rec.top_model_line_index);
    p1_a148 := rosetta_g_miss_num_map(ddpx_line_rec.unit_list_price);
    p1_a149 := rosetta_g_miss_num_map(ddpx_line_rec.unit_list_price_per_pqty);
    p1_a150 := rosetta_g_miss_num_map(ddpx_line_rec.unit_selling_price);
    p1_a151 := rosetta_g_miss_num_map(ddpx_line_rec.unit_selling_price_per_pqty);
    p1_a152 := rosetta_g_miss_num_map(ddpx_line_rec.veh_cus_item_cum_key_id);
    p1_a153 := ddpx_line_rec.visible_demand_flag;
    p1_a154 := ddpx_line_rec.return_status;
    p1_a155 := ddpx_line_rec.db_flag;
    p1_a156 := ddpx_line_rec.operation;
    p1_a157 := ddpx_line_rec.first_ack_code;
    p1_a158 := ddpx_line_rec.first_ack_date;
    p1_a159 := ddpx_line_rec.last_ack_code;
    p1_a160 := ddpx_line_rec.last_ack_date;
    p1_a161 := ddpx_line_rec.change_reason;
    p1_a162 := ddpx_line_rec.change_comments;
    p1_a163 := ddpx_line_rec.arrival_set;
    p1_a164 := ddpx_line_rec.ship_set;
    p1_a165 := ddpx_line_rec.fulfillment_set;
    p1_a166 := rosetta_g_miss_num_map(ddpx_line_rec.order_source_id);
    p1_a167 := ddpx_line_rec.orig_sys_shipment_ref;
    p1_a168 := ddpx_line_rec.change_sequence;
    p1_a169 := ddpx_line_rec.change_request_code;
    p1_a170 := ddpx_line_rec.status_flag;
    p1_a171 := ddpx_line_rec.drop_ship_flag;
    p1_a172 := ddpx_line_rec.customer_line_number;
    p1_a173 := ddpx_line_rec.customer_shipment_number;
    p1_a174 := rosetta_g_miss_num_map(ddpx_line_rec.customer_item_net_price);
    p1_a175 := rosetta_g_miss_num_map(ddpx_line_rec.customer_payment_term_id);
    p1_a176 := rosetta_g_miss_num_map(ddpx_line_rec.ordered_item_id);
    p1_a177 := ddpx_line_rec.item_identifier_type;
    p1_a178 := ddpx_line_rec.shipping_instructions;
    p1_a179 := ddpx_line_rec.packing_instructions;
    p1_a180 := ddpx_line_rec.calculate_price_flag;
    p1_a181 := rosetta_g_miss_num_map(ddpx_line_rec.invoiced_quantity);
    p1_a182 := ddpx_line_rec.service_txn_reason_code;
    p1_a183 := ddpx_line_rec.service_txn_comments;
    p1_a184 := rosetta_g_miss_num_map(ddpx_line_rec.service_duration);
    p1_a185 := ddpx_line_rec.service_period;
    p1_a186 := ddpx_line_rec.service_start_date;
    p1_a187 := ddpx_line_rec.service_end_date;
    p1_a188 := ddpx_line_rec.service_coterminate_flag;
    p1_a189 := rosetta_g_miss_num_map(ddpx_line_rec.unit_list_percent);
    p1_a190 := rosetta_g_miss_num_map(ddpx_line_rec.unit_selling_percent);
    p1_a191 := rosetta_g_miss_num_map(ddpx_line_rec.unit_percent_base_price);
    p1_a192 := rosetta_g_miss_num_map(ddpx_line_rec.service_number);
    p1_a193 := ddpx_line_rec.service_reference_type_code;
    p1_a194 := rosetta_g_miss_num_map(ddpx_line_rec.service_reference_line_id);
    p1_a195 := rosetta_g_miss_num_map(ddpx_line_rec.service_reference_system_id);
    p1_a196 := rosetta_g_miss_num_map(ddpx_line_rec.service_ref_order_number);
    p1_a197 := rosetta_g_miss_num_map(ddpx_line_rec.service_ref_line_number);
    p1_a198 := ddpx_line_rec.service_reference_order;
    p1_a199 := ddpx_line_rec.service_reference_line;
    p1_a200 := ddpx_line_rec.service_reference_system;
    p1_a201 := rosetta_g_miss_num_map(ddpx_line_rec.service_ref_shipment_number);
    p1_a202 := rosetta_g_miss_num_map(ddpx_line_rec.service_ref_option_number);
    p1_a203 := rosetta_g_miss_num_map(ddpx_line_rec.service_line_index);
    p1_a204 := rosetta_g_miss_num_map(ddpx_line_rec.line_set_id);
    p1_a205 := ddpx_line_rec.split_by;
    p1_a206 := ddpx_line_rec.split_action_code;
    p1_a207 := ddpx_line_rec.shippable_flag;
    p1_a208 := ddpx_line_rec.model_remnant_flag;
    p1_a209 := ddpx_line_rec.flow_status_code;
    p1_a210 := ddpx_line_rec.fulfilled_flag;
    p1_a211 := ddpx_line_rec.fulfillment_method_code;
    p1_a212 := rosetta_g_miss_num_map(ddpx_line_rec.revenue_amount);
    p1_a213 := rosetta_g_miss_num_map(ddpx_line_rec.marketing_source_code_id);
    p1_a214 := ddpx_line_rec.fulfillment_date;
    if ddpx_line_rec.semi_processed_flag is null
      then p1_a215 := null;
    elsif ddpx_line_rec.semi_processed_flag
      then p1_a215 := 1;
    else p1_a215 := 0;
    end if;
    p1_a216 := ddpx_line_rec.upgraded_flag;
    p1_a217 := rosetta_g_miss_num_map(ddpx_line_rec.lock_control);
    p1_a218 := ddpx_line_rec.subinventory;
    p1_a219 := ddpx_line_rec.split_from_line_ref;
    p1_a220 := ddpx_line_rec.split_from_shipment_ref;
    p1_a221 := ddpx_line_rec.ship_to_edi_location_code;
    p1_a222 := ddpx_line_rec.bill_to_edi_location_code;
    p1_a223 := ddpx_line_rec.ship_from_edi_location_code;
    p1_a224 := rosetta_g_miss_num_map(ddpx_line_rec.ship_from_address_id);
    p1_a225 := rosetta_g_miss_num_map(ddpx_line_rec.sold_to_address_id);
    p1_a226 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_address_id);
    p1_a227 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_address_id);
    p1_a228 := ddpx_line_rec.ship_to_address_code;
    p1_a229 := rosetta_g_miss_num_map(ddpx_line_rec.original_inventory_item_id);
    p1_a230 := ddpx_line_rec.original_item_identifier_type;
    p1_a231 := rosetta_g_miss_num_map(ddpx_line_rec.original_ordered_item_id);
    p1_a232 := ddpx_line_rec.original_ordered_item;
    p1_a233 := ddpx_line_rec.item_substitution_type_code;
    p1_a234 := rosetta_g_miss_num_map(ddpx_line_rec.late_demand_penalty_factor);
    p1_a235 := ddpx_line_rec.override_atp_date_code;
    p1_a236 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_customer_id);
    p1_a237 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_customer_id);
    p1_a238 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_customer_id);
    p1_a239 := rosetta_g_miss_num_map(ddpx_line_rec.accounting_rule_duration);
    p1_a240 := rosetta_g_miss_num_map(ddpx_line_rec.unit_cost);
    p1_a241 := ddpx_line_rec.user_item_description;
    p1_a242 := ddpx_line_rec.xml_transaction_type_code;
    p1_a243 := rosetta_g_miss_num_map(ddpx_line_rec.item_relationship_type);
    p1_a244 := rosetta_g_miss_num_map(ddpx_line_rec.blanket_number);
    p1_a245 := rosetta_g_miss_num_map(ddpx_line_rec.blanket_line_number);
    p1_a246 := rosetta_g_miss_num_map(ddpx_line_rec.blanket_version_number);
    p1_a247 := ddpx_line_rec.cso_response_flag;
    p1_a248 := ddpx_line_rec.firm_demand_flag;
    p1_a249 := ddpx_line_rec.earliest_ship_date;
    p1_a250 := ddpx_line_rec.transaction_phase_code;
    p1_a251 := rosetta_g_miss_num_map(ddpx_line_rec.source_document_version_number);
    p1_a252 := rosetta_g_miss_num_map(ddpx_line_rec.minisite_id);
    p1_a253 := ddpx_line_rec.ib_owner;
    p1_a254 := ddpx_line_rec.ib_installed_at_location;
    p1_a255 := ddpx_line_rec.ib_current_location;
    p1_a256 := rosetta_g_miss_num_map(ddpx_line_rec.end_customer_id);
    p1_a257 := rosetta_g_miss_num_map(ddpx_line_rec.end_customer_contact_id);
    p1_a258 := rosetta_g_miss_num_map(ddpx_line_rec.end_customer_site_use_id);
    p1_a259 := ddpx_line_rec.supplier_signature;
    p1_a260 := ddpx_line_rec.supplier_signature_date;
    p1_a261 := ddpx_line_rec.customer_signature;
    p1_a262 := ddpx_line_rec.customer_signature_date;
    p1_a263 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_party_id);
    p1_a264 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_party_site_id);
    p1_a265 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_party_site_use_id);
    p1_a266 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_party_id);
    p1_a267 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_party_site_id);
    p1_a268 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_party_site_use_id);
    p1_a269 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_party_id);
    p1_a270 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_party_site_id);
    p1_a271 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_party_site_use_id);
    p1_a272 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_customer_party_id);
    p1_a273 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_customer_party_id);
    p1_a274 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_customer_party_id);
    p1_a275 := rosetta_g_miss_num_map(ddpx_line_rec.ship_to_org_contact_id);
    p1_a276 := rosetta_g_miss_num_map(ddpx_line_rec.deliver_to_org_contact_id);
    p1_a277 := rosetta_g_miss_num_map(ddpx_line_rec.invoice_to_org_contact_id);
    p1_a278 := rosetta_g_miss_num_map(ddpx_line_rec.retrobill_request_id);
    p1_a279 := rosetta_g_miss_num_map(ddpx_line_rec.original_list_price);
    p1_a280 := rosetta_g_miss_num_map(ddpx_line_rec.commitment_applied_amount);

    oe_order_pub_w.rosetta_table_copy_out_p23(ddpx_line_adj_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      , p2_a32
      , p2_a33
      , p2_a34
      , p2_a35
      , p2_a36
      , p2_a37
      , p2_a38
      , p2_a39
      , p2_a40
      , p2_a41
      , p2_a42
      , p2_a43
      , p2_a44
      , p2_a45
      , p2_a46
      , p2_a47
      , p2_a48
      , p2_a49
      , p2_a50
      , p2_a51
      , p2_a52
      , p2_a53
      , p2_a54
      , p2_a55
      , p2_a56
      , p2_a57
      , p2_a58
      , p2_a59
      , p2_a60
      , p2_a61
      , p2_a62
      , p2_a63
      , p2_a64
      , p2_a65
      , p2_a66
      , p2_a67
      , p2_a68
      , p2_a69
      , p2_a70
      , p2_a71
      , p2_a72
      , p2_a73
      , p2_a74
      , p2_a75
      , p2_a76
      , p2_a77
      , p2_a78
      , p2_a79
      , p2_a80
      , p2_a81
      , p2_a82
      , p2_a83
      , p2_a84
      , p2_a85
      , p2_a86
      , p2_a87
      , p2_a88
      , p2_a89
      , p2_a90
      , p2_a91
      , p2_a92
      , p2_a93
      , p2_a94
      , p2_a95
      , p2_a96
      , p2_a97
      , p2_a98
      , p2_a99
      , p2_a100
      , p2_a101
      , p2_a102
      , p2_a103
      , p2_a104
      , p2_a105
      , p2_a106
      , p2_a107
      , p2_a108
      );






  end;

end oe_price_order_pvt_w_obsolete;

/
