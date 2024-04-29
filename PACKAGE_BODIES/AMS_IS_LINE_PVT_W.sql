--------------------------------------------------------
--  DDL for Package Body AMS_IS_LINE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IS_LINE_PVT_W" as
  /* $Header: amswislb.pls 120.2 2005/10/18 03:02 rmbhanda ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_is_line_pvt.is_line_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_4000
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_2000
    , a18 JTF_VARCHAR2_TABLE_2000
    , a19 JTF_VARCHAR2_TABLE_2000
    , a20 JTF_VARCHAR2_TABLE_2000
    , a21 JTF_VARCHAR2_TABLE_2000
    , a22 JTF_VARCHAR2_TABLE_2000
    , a23 JTF_VARCHAR2_TABLE_2000
    , a24 JTF_VARCHAR2_TABLE_2000
    , a25 JTF_VARCHAR2_TABLE_2000
    , a26 JTF_VARCHAR2_TABLE_2000
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_VARCHAR2_TABLE_2000
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_VARCHAR2_TABLE_2000
    , a31 JTF_VARCHAR2_TABLE_2000
    , a32 JTF_VARCHAR2_TABLE_2000
    , a33 JTF_VARCHAR2_TABLE_2000
    , a34 JTF_VARCHAR2_TABLE_2000
    , a35 JTF_VARCHAR2_TABLE_2000
    , a36 JTF_VARCHAR2_TABLE_2000
    , a37 JTF_VARCHAR2_TABLE_2000
    , a38 JTF_VARCHAR2_TABLE_2000
    , a39 JTF_VARCHAR2_TABLE_2000
    , a40 JTF_VARCHAR2_TABLE_2000
    , a41 JTF_VARCHAR2_TABLE_2000
    , a42 JTF_VARCHAR2_TABLE_2000
    , a43 JTF_VARCHAR2_TABLE_2000
    , a44 JTF_VARCHAR2_TABLE_2000
    , a45 JTF_VARCHAR2_TABLE_2000
    , a46 JTF_VARCHAR2_TABLE_2000
    , a47 JTF_VARCHAR2_TABLE_2000
    , a48 JTF_VARCHAR2_TABLE_2000
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_VARCHAR2_TABLE_2000
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_VARCHAR2_TABLE_2000
    , a54 JTF_VARCHAR2_TABLE_2000
    , a55 JTF_VARCHAR2_TABLE_2000
    , a56 JTF_VARCHAR2_TABLE_2000
    , a57 JTF_VARCHAR2_TABLE_2000
    , a58 JTF_VARCHAR2_TABLE_2000
    , a59 JTF_VARCHAR2_TABLE_2000
    , a60 JTF_VARCHAR2_TABLE_2000
    , a61 JTF_VARCHAR2_TABLE_2000
    , a62 JTF_VARCHAR2_TABLE_2000
    , a63 JTF_VARCHAR2_TABLE_2000
    , a64 JTF_VARCHAR2_TABLE_2000
    , a65 JTF_VARCHAR2_TABLE_2000
    , a66 JTF_VARCHAR2_TABLE_2000
    , a67 JTF_VARCHAR2_TABLE_2000
    , a68 JTF_VARCHAR2_TABLE_2000
    , a69 JTF_VARCHAR2_TABLE_2000
    , a70 JTF_VARCHAR2_TABLE_2000
    , a71 JTF_VARCHAR2_TABLE_2000
    , a72 JTF_VARCHAR2_TABLE_2000
    , a73 JTF_VARCHAR2_TABLE_2000
    , a74 JTF_VARCHAR2_TABLE_2000
    , a75 JTF_VARCHAR2_TABLE_2000
    , a76 JTF_VARCHAR2_TABLE_2000
    , a77 JTF_VARCHAR2_TABLE_2000
    , a78 JTF_VARCHAR2_TABLE_2000
    , a79 JTF_VARCHAR2_TABLE_2000
    , a80 JTF_VARCHAR2_TABLE_2000
    , a81 JTF_VARCHAR2_TABLE_2000
    , a82 JTF_VARCHAR2_TABLE_2000
    , a83 JTF_VARCHAR2_TABLE_2000
    , a84 JTF_VARCHAR2_TABLE_2000
    , a85 JTF_VARCHAR2_TABLE_2000
    , a86 JTF_VARCHAR2_TABLE_2000
    , a87 JTF_VARCHAR2_TABLE_2000
    , a88 JTF_VARCHAR2_TABLE_2000
    , a89 JTF_VARCHAR2_TABLE_2000
    , a90 JTF_VARCHAR2_TABLE_2000
    , a91 JTF_VARCHAR2_TABLE_2000
    , a92 JTF_VARCHAR2_TABLE_2000
    , a93 JTF_VARCHAR2_TABLE_2000
    , a94 JTF_VARCHAR2_TABLE_2000
    , a95 JTF_VARCHAR2_TABLE_2000
    , a96 JTF_VARCHAR2_TABLE_2000
    , a97 JTF_VARCHAR2_TABLE_2000
    , a98 JTF_VARCHAR2_TABLE_2000
    , a99 JTF_VARCHAR2_TABLE_2000
    , a100 JTF_VARCHAR2_TABLE_2000
    , a101 JTF_VARCHAR2_TABLE_2000
    , a102 JTF_VARCHAR2_TABLE_2000
    , a103 JTF_VARCHAR2_TABLE_2000
    , a104 JTF_VARCHAR2_TABLE_2000
    , a105 JTF_VARCHAR2_TABLE_2000
    , a106 JTF_VARCHAR2_TABLE_2000
    , a107 JTF_VARCHAR2_TABLE_2000
    , a108 JTF_VARCHAR2_TABLE_2000
    , a109 JTF_VARCHAR2_TABLE_2000
    , a110 JTF_VARCHAR2_TABLE_2000
    , a111 JTF_VARCHAR2_TABLE_2000
    , a112 JTF_VARCHAR2_TABLE_2000
    , a113 JTF_VARCHAR2_TABLE_2000
    , a114 JTF_VARCHAR2_TABLE_2000
    , a115 JTF_VARCHAR2_TABLE_2000
    , a116 JTF_VARCHAR2_TABLE_2000
    , a117 JTF_VARCHAR2_TABLE_2000
    , a118 JTF_VARCHAR2_TABLE_2000
    , a119 JTF_VARCHAR2_TABLE_2000
    , a120 JTF_VARCHAR2_TABLE_2000
    , a121 JTF_VARCHAR2_TABLE_2000
    , a122 JTF_VARCHAR2_TABLE_2000
    , a123 JTF_VARCHAR2_TABLE_2000
    , a124 JTF_VARCHAR2_TABLE_2000
    , a125 JTF_VARCHAR2_TABLE_2000
    , a126 JTF_VARCHAR2_TABLE_2000
    , a127 JTF_VARCHAR2_TABLE_2000
    , a128 JTF_VARCHAR2_TABLE_2000
    , a129 JTF_VARCHAR2_TABLE_2000
    , a130 JTF_VARCHAR2_TABLE_2000
    , a131 JTF_VARCHAR2_TABLE_2000
    , a132 JTF_VARCHAR2_TABLE_2000
    , a133 JTF_VARCHAR2_TABLE_2000
    , a134 JTF_VARCHAR2_TABLE_2000
    , a135 JTF_VARCHAR2_TABLE_2000
    , a136 JTF_VARCHAR2_TABLE_2000
    , a137 JTF_VARCHAR2_TABLE_2000
    , a138 JTF_VARCHAR2_TABLE_2000
    , a139 JTF_VARCHAR2_TABLE_2000
    , a140 JTF_VARCHAR2_TABLE_2000
    , a141 JTF_VARCHAR2_TABLE_2000
    , a142 JTF_VARCHAR2_TABLE_2000
    , a143 JTF_VARCHAR2_TABLE_2000
    , a144 JTF_VARCHAR2_TABLE_2000
    , a145 JTF_VARCHAR2_TABLE_2000
    , a146 JTF_VARCHAR2_TABLE_2000
    , a147 JTF_VARCHAR2_TABLE_2000
    , a148 JTF_VARCHAR2_TABLE_2000
    , a149 JTF_VARCHAR2_TABLE_2000
    , a150 JTF_VARCHAR2_TABLE_2000
    , a151 JTF_VARCHAR2_TABLE_2000
    , a152 JTF_VARCHAR2_TABLE_2000
    , a153 JTF_VARCHAR2_TABLE_2000
    , a154 JTF_VARCHAR2_TABLE_2000
    , a155 JTF_VARCHAR2_TABLE_2000
    , a156 JTF_VARCHAR2_TABLE_2000
    , a157 JTF_VARCHAR2_TABLE_2000
    , a158 JTF_VARCHAR2_TABLE_2000
    , a159 JTF_VARCHAR2_TABLE_2000
    , a160 JTF_VARCHAR2_TABLE_2000
    , a161 JTF_VARCHAR2_TABLE_2000
    , a162 JTF_VARCHAR2_TABLE_2000
    , a163 JTF_VARCHAR2_TABLE_2000
    , a164 JTF_VARCHAR2_TABLE_2000
    , a165 JTF_VARCHAR2_TABLE_2000
    , a166 JTF_VARCHAR2_TABLE_2000
    , a167 JTF_VARCHAR2_TABLE_2000
    , a168 JTF_VARCHAR2_TABLE_2000
    , a169 JTF_VARCHAR2_TABLE_2000
    , a170 JTF_VARCHAR2_TABLE_2000
    , a171 JTF_VARCHAR2_TABLE_2000
    , a172 JTF_VARCHAR2_TABLE_2000
    , a173 JTF_VARCHAR2_TABLE_2000
    , a174 JTF_VARCHAR2_TABLE_2000
    , a175 JTF_VARCHAR2_TABLE_2000
    , a176 JTF_VARCHAR2_TABLE_2000
    , a177 JTF_VARCHAR2_TABLE_2000
    , a178 JTF_VARCHAR2_TABLE_2000
    , a179 JTF_VARCHAR2_TABLE_2000
    , a180 JTF_VARCHAR2_TABLE_2000
    , a181 JTF_VARCHAR2_TABLE_2000
    , a182 JTF_VARCHAR2_TABLE_2000
    , a183 JTF_VARCHAR2_TABLE_2000
    , a184 JTF_VARCHAR2_TABLE_2000
    , a185 JTF_VARCHAR2_TABLE_2000
    , a186 JTF_VARCHAR2_TABLE_2000
    , a187 JTF_VARCHAR2_TABLE_2000
    , a188 JTF_VARCHAR2_TABLE_2000
    , a189 JTF_VARCHAR2_TABLE_2000
    , a190 JTF_VARCHAR2_TABLE_2000
    , a191 JTF_VARCHAR2_TABLE_2000
    , a192 JTF_VARCHAR2_TABLE_2000
    , a193 JTF_VARCHAR2_TABLE_2000
    , a194 JTF_VARCHAR2_TABLE_2000
    , a195 JTF_VARCHAR2_TABLE_2000
    , a196 JTF_VARCHAR2_TABLE_2000
    , a197 JTF_VARCHAR2_TABLE_2000
    , a198 JTF_VARCHAR2_TABLE_2000
    , a199 JTF_VARCHAR2_TABLE_2000
    , a200 JTF_VARCHAR2_TABLE_2000
    , a201 JTF_VARCHAR2_TABLE_2000
    , a202 JTF_VARCHAR2_TABLE_2000
    , a203 JTF_VARCHAR2_TABLE_2000
    , a204 JTF_VARCHAR2_TABLE_2000
    , a205 JTF_VARCHAR2_TABLE_2000
    , a206 JTF_VARCHAR2_TABLE_2000
    , a207 JTF_VARCHAR2_TABLE_2000
    , a208 JTF_VARCHAR2_TABLE_2000
    , a209 JTF_VARCHAR2_TABLE_2000
    , a210 JTF_VARCHAR2_TABLE_2000
    , a211 JTF_VARCHAR2_TABLE_2000
    , a212 JTF_VARCHAR2_TABLE_2000
    , a213 JTF_VARCHAR2_TABLE_2000
    , a214 JTF_VARCHAR2_TABLE_2000
    , a215 JTF_VARCHAR2_TABLE_2000
    , a216 JTF_VARCHAR2_TABLE_2000
    , a217 JTF_VARCHAR2_TABLE_2000
    , a218 JTF_VARCHAR2_TABLE_2000
    , a219 JTF_VARCHAR2_TABLE_2000
    , a220 JTF_VARCHAR2_TABLE_2000
    , a221 JTF_VARCHAR2_TABLE_2000
    , a222 JTF_VARCHAR2_TABLE_2000
    , a223 JTF_VARCHAR2_TABLE_2000
    , a224 JTF_VARCHAR2_TABLE_2000
    , a225 JTF_VARCHAR2_TABLE_2000
    , a226 JTF_VARCHAR2_TABLE_2000
    , a227 JTF_VARCHAR2_TABLE_2000
    , a228 JTF_VARCHAR2_TABLE_2000
    , a229 JTF_VARCHAR2_TABLE_2000
    , a230 JTF_VARCHAR2_TABLE_2000
    , a231 JTF_VARCHAR2_TABLE_2000
    , a232 JTF_VARCHAR2_TABLE_2000
    , a233 JTF_VARCHAR2_TABLE_2000
    , a234 JTF_VARCHAR2_TABLE_2000
    , a235 JTF_VARCHAR2_TABLE_2000
    , a236 JTF_VARCHAR2_TABLE_2000
    , a237 JTF_VARCHAR2_TABLE_2000
    , a238 JTF_VARCHAR2_TABLE_2000
    , a239 JTF_VARCHAR2_TABLE_2000
    , a240 JTF_VARCHAR2_TABLE_2000
    , a241 JTF_VARCHAR2_TABLE_2000
    , a242 JTF_VARCHAR2_TABLE_2000
    , a243 JTF_VARCHAR2_TABLE_2000
    , a244 JTF_VARCHAR2_TABLE_2000
    , a245 JTF_VARCHAR2_TABLE_2000
    , a246 JTF_VARCHAR2_TABLE_2000
    , a247 JTF_VARCHAR2_TABLE_2000
    , a248 JTF_VARCHAR2_TABLE_2000
    , a249 JTF_VARCHAR2_TABLE_2000
    , a250 JTF_VARCHAR2_TABLE_2000
    , a251 JTF_VARCHAR2_TABLE_2000
    , a252 JTF_VARCHAR2_TABLE_2000
    , a253 JTF_VARCHAR2_TABLE_2000
    , a254 JTF_VARCHAR2_TABLE_4000
    , a255 JTF_VARCHAR2_TABLE_4000
    , a256 JTF_VARCHAR2_TABLE_4000
    , a257 JTF_VARCHAR2_TABLE_4000
    , a258 JTF_VARCHAR2_TABLE_4000
    , a259 JTF_VARCHAR2_TABLE_4000
    , a260 JTF_VARCHAR2_TABLE_4000
    , a261 JTF_VARCHAR2_TABLE_4000
    , a262 JTF_VARCHAR2_TABLE_4000
    , a263 JTF_VARCHAR2_TABLE_4000
    , a264 JTF_VARCHAR2_TABLE_100
    , a265 JTF_NUMBER_TABLE
    , a266 JTF_VARCHAR2_TABLE_100
    , a267 JTF_VARCHAR2_TABLE_4000
    , a268 JTF_VARCHAR2_TABLE_2000
    , a269 JTF_VARCHAR2_TABLE_100
    , a270 JTF_VARCHAR2_TABLE_2000
    , a271 JTF_VARCHAR2_TABLE_2000
    , a272 JTF_VARCHAR2_TABLE_2000
    , a273 JTF_VARCHAR2_TABLE_2000
    , a274 JTF_VARCHAR2_TABLE_2000
    , a275 JTF_VARCHAR2_TABLE_2000
    , a276 JTF_VARCHAR2_TABLE_2000
    , a277 JTF_VARCHAR2_TABLE_2000
    , a278 JTF_VARCHAR2_TABLE_2000
    , a279 JTF_VARCHAR2_TABLE_2000
    , a280 JTF_VARCHAR2_TABLE_2000
    , a281 JTF_VARCHAR2_TABLE_2000
    , a282 JTF_VARCHAR2_TABLE_2000
    , a283 JTF_VARCHAR2_TABLE_2000
    , a284 JTF_VARCHAR2_TABLE_2000
    , a285 JTF_VARCHAR2_TABLE_2000
    , a286 JTF_VARCHAR2_TABLE_2000
    , a287 JTF_VARCHAR2_TABLE_2000
    , a288 JTF_VARCHAR2_TABLE_2000
    , a289 JTF_VARCHAR2_TABLE_2000
    , a290 JTF_VARCHAR2_TABLE_2000
    , a291 JTF_VARCHAR2_TABLE_2000
    , a292 JTF_VARCHAR2_TABLE_2000
    , a293 JTF_VARCHAR2_TABLE_2000
    , a294 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).import_source_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).import_list_header_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).import_successful_flag := a8(indx);
          t(ddindx).enabled_flag := a9(indx);
          t(ddindx).import_failure_reason := a10(indx);
          t(ddindx).re_import_last_done_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).party_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).dedupe_key := a13(indx);
          t(ddindx).col1 := a14(indx);
          t(ddindx).col2 := a15(indx);
          t(ddindx).col3 := a16(indx);
          t(ddindx).col4 := a17(indx);
          t(ddindx).col5 := a18(indx);
          t(ddindx).col6 := a19(indx);
          t(ddindx).col7 := a20(indx);
          t(ddindx).col8 := a21(indx);
          t(ddindx).col9 := a22(indx);
          t(ddindx).col10 := a23(indx);
          t(ddindx).col11 := a24(indx);
          t(ddindx).col12 := a25(indx);
          t(ddindx).col13 := a26(indx);
          t(ddindx).col14 := a27(indx);
          t(ddindx).col15 := a28(indx);
          t(ddindx).col16 := a29(indx);
          t(ddindx).col17 := a30(indx);
          t(ddindx).col18 := a31(indx);
          t(ddindx).col19 := a32(indx);
          t(ddindx).col20 := a33(indx);
          t(ddindx).col21 := a34(indx);
          t(ddindx).col22 := a35(indx);
          t(ddindx).col23 := a36(indx);
          t(ddindx).col24 := a37(indx);
          t(ddindx).col25 := a38(indx);
          t(ddindx).col26 := a39(indx);
          t(ddindx).col27 := a40(indx);
          t(ddindx).col28 := a41(indx);
          t(ddindx).col29 := a42(indx);
          t(ddindx).col30 := a43(indx);
          t(ddindx).col31 := a44(indx);
          t(ddindx).col32 := a45(indx);
          t(ddindx).col33 := a46(indx);
          t(ddindx).col34 := a47(indx);
          t(ddindx).col35 := a48(indx);
          t(ddindx).col36 := a49(indx);
          t(ddindx).col37 := a50(indx);
          t(ddindx).col38 := a51(indx);
          t(ddindx).col39 := a52(indx);
          t(ddindx).col40 := a53(indx);
          t(ddindx).col41 := a54(indx);
          t(ddindx).col42 := a55(indx);
          t(ddindx).col43 := a56(indx);
          t(ddindx).col44 := a57(indx);
          t(ddindx).col45 := a58(indx);
          t(ddindx).col46 := a59(indx);
          t(ddindx).col47 := a60(indx);
          t(ddindx).col48 := a61(indx);
          t(ddindx).col49 := a62(indx);
          t(ddindx).col50 := a63(indx);
          t(ddindx).col51 := a64(indx);
          t(ddindx).col52 := a65(indx);
          t(ddindx).col53 := a66(indx);
          t(ddindx).col54 := a67(indx);
          t(ddindx).col55 := a68(indx);
          t(ddindx).col56 := a69(indx);
          t(ddindx).col57 := a70(indx);
          t(ddindx).col58 := a71(indx);
          t(ddindx).col59 := a72(indx);
          t(ddindx).col60 := a73(indx);
          t(ddindx).col61 := a74(indx);
          t(ddindx).col62 := a75(indx);
          t(ddindx).col63 := a76(indx);
          t(ddindx).col64 := a77(indx);
          t(ddindx).col65 := a78(indx);
          t(ddindx).col66 := a79(indx);
          t(ddindx).col67 := a80(indx);
          t(ddindx).col68 := a81(indx);
          t(ddindx).col69 := a82(indx);
          t(ddindx).col70 := a83(indx);
          t(ddindx).col71 := a84(indx);
          t(ddindx).col72 := a85(indx);
          t(ddindx).col73 := a86(indx);
          t(ddindx).col74 := a87(indx);
          t(ddindx).col75 := a88(indx);
          t(ddindx).col76 := a89(indx);
          t(ddindx).col77 := a90(indx);
          t(ddindx).col78 := a91(indx);
          t(ddindx).col79 := a92(indx);
          t(ddindx).col80 := a93(indx);
          t(ddindx).col81 := a94(indx);
          t(ddindx).col82 := a95(indx);
          t(ddindx).col83 := a96(indx);
          t(ddindx).col84 := a97(indx);
          t(ddindx).col85 := a98(indx);
          t(ddindx).col86 := a99(indx);
          t(ddindx).col87 := a100(indx);
          t(ddindx).col88 := a101(indx);
          t(ddindx).col89 := a102(indx);
          t(ddindx).col90 := a103(indx);
          t(ddindx).col91 := a104(indx);
          t(ddindx).col92 := a105(indx);
          t(ddindx).col93 := a106(indx);
          t(ddindx).col94 := a107(indx);
          t(ddindx).col95 := a108(indx);
          t(ddindx).col96 := a109(indx);
          t(ddindx).col97 := a110(indx);
          t(ddindx).col98 := a111(indx);
          t(ddindx).col99 := a112(indx);
          t(ddindx).col100 := a113(indx);
          t(ddindx).col101 := a114(indx);
          t(ddindx).col102 := a115(indx);
          t(ddindx).col103 := a116(indx);
          t(ddindx).col104 := a117(indx);
          t(ddindx).col105 := a118(indx);
          t(ddindx).col106 := a119(indx);
          t(ddindx).col107 := a120(indx);
          t(ddindx).col108 := a121(indx);
          t(ddindx).col109 := a122(indx);
          t(ddindx).col110 := a123(indx);
          t(ddindx).col111 := a124(indx);
          t(ddindx).col112 := a125(indx);
          t(ddindx).col113 := a126(indx);
          t(ddindx).col114 := a127(indx);
          t(ddindx).col115 := a128(indx);
          t(ddindx).col116 := a129(indx);
          t(ddindx).col117 := a130(indx);
          t(ddindx).col118 := a131(indx);
          t(ddindx).col119 := a132(indx);
          t(ddindx).col120 := a133(indx);
          t(ddindx).col121 := a134(indx);
          t(ddindx).col122 := a135(indx);
          t(ddindx).col123 := a136(indx);
          t(ddindx).col124 := a137(indx);
          t(ddindx).col125 := a138(indx);
          t(ddindx).col126 := a139(indx);
          t(ddindx).col127 := a140(indx);
          t(ddindx).col128 := a141(indx);
          t(ddindx).col129 := a142(indx);
          t(ddindx).col130 := a143(indx);
          t(ddindx).col131 := a144(indx);
          t(ddindx).col132 := a145(indx);
          t(ddindx).col133 := a146(indx);
          t(ddindx).col134 := a147(indx);
          t(ddindx).col135 := a148(indx);
          t(ddindx).col136 := a149(indx);
          t(ddindx).col137 := a150(indx);
          t(ddindx).col138 := a151(indx);
          t(ddindx).col139 := a152(indx);
          t(ddindx).col140 := a153(indx);
          t(ddindx).col141 := a154(indx);
          t(ddindx).col142 := a155(indx);
          t(ddindx).col143 := a156(indx);
          t(ddindx).col144 := a157(indx);
          t(ddindx).col145 := a158(indx);
          t(ddindx).col146 := a159(indx);
          t(ddindx).col147 := a160(indx);
          t(ddindx).col148 := a161(indx);
          t(ddindx).col149 := a162(indx);
          t(ddindx).col150 := a163(indx);
          t(ddindx).col151 := a164(indx);
          t(ddindx).col152 := a165(indx);
          t(ddindx).col153 := a166(indx);
          t(ddindx).col154 := a167(indx);
          t(ddindx).col155 := a168(indx);
          t(ddindx).col156 := a169(indx);
          t(ddindx).col157 := a170(indx);
          t(ddindx).col158 := a171(indx);
          t(ddindx).col159 := a172(indx);
          t(ddindx).col160 := a173(indx);
          t(ddindx).col161 := a174(indx);
          t(ddindx).col162 := a175(indx);
          t(ddindx).col163 := a176(indx);
          t(ddindx).col164 := a177(indx);
          t(ddindx).col165 := a178(indx);
          t(ddindx).col166 := a179(indx);
          t(ddindx).col167 := a180(indx);
          t(ddindx).col168 := a181(indx);
          t(ddindx).col169 := a182(indx);
          t(ddindx).col170 := a183(indx);
          t(ddindx).col171 := a184(indx);
          t(ddindx).col172 := a185(indx);
          t(ddindx).col173 := a186(indx);
          t(ddindx).col174 := a187(indx);
          t(ddindx).col175 := a188(indx);
          t(ddindx).col176 := a189(indx);
          t(ddindx).col177 := a190(indx);
          t(ddindx).col178 := a191(indx);
          t(ddindx).col179 := a192(indx);
          t(ddindx).col180 := a193(indx);
          t(ddindx).col181 := a194(indx);
          t(ddindx).col182 := a195(indx);
          t(ddindx).col183 := a196(indx);
          t(ddindx).col184 := a197(indx);
          t(ddindx).col185 := a198(indx);
          t(ddindx).col186 := a199(indx);
          t(ddindx).col187 := a200(indx);
          t(ddindx).col188 := a201(indx);
          t(ddindx).col189 := a202(indx);
          t(ddindx).col190 := a203(indx);
          t(ddindx).col191 := a204(indx);
          t(ddindx).col192 := a205(indx);
          t(ddindx).col193 := a206(indx);
          t(ddindx).col194 := a207(indx);
          t(ddindx).col195 := a208(indx);
          t(ddindx).col196 := a209(indx);
          t(ddindx).col197 := a210(indx);
          t(ddindx).col198 := a211(indx);
          t(ddindx).col199 := a212(indx);
          t(ddindx).col200 := a213(indx);
          t(ddindx).col201 := a214(indx);
          t(ddindx).col202 := a215(indx);
          t(ddindx).col203 := a216(indx);
          t(ddindx).col204 := a217(indx);
          t(ddindx).col205 := a218(indx);
          t(ddindx).col206 := a219(indx);
          t(ddindx).col207 := a220(indx);
          t(ddindx).col208 := a221(indx);
          t(ddindx).col209 := a222(indx);
          t(ddindx).col210 := a223(indx);
          t(ddindx).col211 := a224(indx);
          t(ddindx).col212 := a225(indx);
          t(ddindx).col213 := a226(indx);
          t(ddindx).col214 := a227(indx);
          t(ddindx).col215 := a228(indx);
          t(ddindx).col216 := a229(indx);
          t(ddindx).col217 := a230(indx);
          t(ddindx).col218 := a231(indx);
          t(ddindx).col219 := a232(indx);
          t(ddindx).col220 := a233(indx);
          t(ddindx).col221 := a234(indx);
          t(ddindx).col222 := a235(indx);
          t(ddindx).col223 := a236(indx);
          t(ddindx).col224 := a237(indx);
          t(ddindx).col225 := a238(indx);
          t(ddindx).col226 := a239(indx);
          t(ddindx).col227 := a240(indx);
          t(ddindx).col228 := a241(indx);
          t(ddindx).col229 := a242(indx);
          t(ddindx).col230 := a243(indx);
          t(ddindx).col231 := a244(indx);
          t(ddindx).col232 := a245(indx);
          t(ddindx).col233 := a246(indx);
          t(ddindx).col234 := a247(indx);
          t(ddindx).col235 := a248(indx);
          t(ddindx).col236 := a249(indx);
          t(ddindx).col237 := a250(indx);
          t(ddindx).col238 := a251(indx);
          t(ddindx).col239 := a252(indx);
          t(ddindx).col240 := a253(indx);
          t(ddindx).col241 := a254(indx);
          t(ddindx).col242 := a255(indx);
          t(ddindx).col243 := a256(indx);
          t(ddindx).col244 := a257(indx);
          t(ddindx).col245 := a258(indx);
          t(ddindx).col246 := a259(indx);
          t(ddindx).col247 := a260(indx);
          t(ddindx).col248 := a261(indx);
          t(ddindx).col249 := a262(indx);
          t(ddindx).col250 := a263(indx);
          t(ddindx).duplicate_flag := a264(indx);
          t(ddindx).current_usage := rosetta_g_miss_num_map(a265(indx));
          t(ddindx).load_status := a266(indx);
          t(ddindx).notes := a267(indx);
          t(ddindx).sales_agent_email_address := a268(indx);
          t(ddindx).vehicle_response_code := a269(indx);
          t(ddindx).custom_column1 := a270(indx);
          t(ddindx).custom_column2 := a271(indx);
          t(ddindx).custom_column3 := a272(indx);
          t(ddindx).custom_column4 := a273(indx);
          t(ddindx).custom_column5 := a274(indx);
          t(ddindx).custom_column6 := a275(indx);
          t(ddindx).custom_column7 := a276(indx);
          t(ddindx).custom_column8 := a277(indx);
          t(ddindx).custom_column9 := a278(indx);
          t(ddindx).custom_column10 := a279(indx);
          t(ddindx).custom_column11 := a280(indx);
          t(ddindx).custom_column12 := a281(indx);
          t(ddindx).custom_column13 := a282(indx);
          t(ddindx).custom_column14 := a283(indx);
          t(ddindx).custom_column15 := a284(indx);
          t(ddindx).custom_column16 := a285(indx);
          t(ddindx).custom_column17 := a286(indx);
          t(ddindx).custom_column18 := a287(indx);
          t(ddindx).custom_column19 := a288(indx);
          t(ddindx).custom_column20 := a289(indx);
          t(ddindx).custom_column21 := a290(indx);
          t(ddindx).custom_column22 := a291(indx);
          t(ddindx).custom_column23 := a292(indx);
          t(ddindx).custom_column24 := a293(indx);
          t(ddindx).custom_column25 := a294(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_is_line_pvt.is_line_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_4000
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_2000
    , a18 out nocopy JTF_VARCHAR2_TABLE_2000
    , a19 out nocopy JTF_VARCHAR2_TABLE_2000
    , a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , a21 out nocopy JTF_VARCHAR2_TABLE_2000
    , a22 out nocopy JTF_VARCHAR2_TABLE_2000
    , a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , a24 out nocopy JTF_VARCHAR2_TABLE_2000
    , a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_VARCHAR2_TABLE_2000
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    , a31 out nocopy JTF_VARCHAR2_TABLE_2000
    , a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , a34 out nocopy JTF_VARCHAR2_TABLE_2000
    , a35 out nocopy JTF_VARCHAR2_TABLE_2000
    , a36 out nocopy JTF_VARCHAR2_TABLE_2000
    , a37 out nocopy JTF_VARCHAR2_TABLE_2000
    , a38 out nocopy JTF_VARCHAR2_TABLE_2000
    , a39 out nocopy JTF_VARCHAR2_TABLE_2000
    , a40 out nocopy JTF_VARCHAR2_TABLE_2000
    , a41 out nocopy JTF_VARCHAR2_TABLE_2000
    , a42 out nocopy JTF_VARCHAR2_TABLE_2000
    , a43 out nocopy JTF_VARCHAR2_TABLE_2000
    , a44 out nocopy JTF_VARCHAR2_TABLE_2000
    , a45 out nocopy JTF_VARCHAR2_TABLE_2000
    , a46 out nocopy JTF_VARCHAR2_TABLE_2000
    , a47 out nocopy JTF_VARCHAR2_TABLE_2000
    , a48 out nocopy JTF_VARCHAR2_TABLE_2000
    , a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_VARCHAR2_TABLE_2000
    , a54 out nocopy JTF_VARCHAR2_TABLE_2000
    , a55 out nocopy JTF_VARCHAR2_TABLE_2000
    , a56 out nocopy JTF_VARCHAR2_TABLE_2000
    , a57 out nocopy JTF_VARCHAR2_TABLE_2000
    , a58 out nocopy JTF_VARCHAR2_TABLE_2000
    , a59 out nocopy JTF_VARCHAR2_TABLE_2000
    , a60 out nocopy JTF_VARCHAR2_TABLE_2000
    , a61 out nocopy JTF_VARCHAR2_TABLE_2000
    , a62 out nocopy JTF_VARCHAR2_TABLE_2000
    , a63 out nocopy JTF_VARCHAR2_TABLE_2000
    , a64 out nocopy JTF_VARCHAR2_TABLE_2000
    , a65 out nocopy JTF_VARCHAR2_TABLE_2000
    , a66 out nocopy JTF_VARCHAR2_TABLE_2000
    , a67 out nocopy JTF_VARCHAR2_TABLE_2000
    , a68 out nocopy JTF_VARCHAR2_TABLE_2000
    , a69 out nocopy JTF_VARCHAR2_TABLE_2000
    , a70 out nocopy JTF_VARCHAR2_TABLE_2000
    , a71 out nocopy JTF_VARCHAR2_TABLE_2000
    , a72 out nocopy JTF_VARCHAR2_TABLE_2000
    , a73 out nocopy JTF_VARCHAR2_TABLE_2000
    , a74 out nocopy JTF_VARCHAR2_TABLE_2000
    , a75 out nocopy JTF_VARCHAR2_TABLE_2000
    , a76 out nocopy JTF_VARCHAR2_TABLE_2000
    , a77 out nocopy JTF_VARCHAR2_TABLE_2000
    , a78 out nocopy JTF_VARCHAR2_TABLE_2000
    , a79 out nocopy JTF_VARCHAR2_TABLE_2000
    , a80 out nocopy JTF_VARCHAR2_TABLE_2000
    , a81 out nocopy JTF_VARCHAR2_TABLE_2000
    , a82 out nocopy JTF_VARCHAR2_TABLE_2000
    , a83 out nocopy JTF_VARCHAR2_TABLE_2000
    , a84 out nocopy JTF_VARCHAR2_TABLE_2000
    , a85 out nocopy JTF_VARCHAR2_TABLE_2000
    , a86 out nocopy JTF_VARCHAR2_TABLE_2000
    , a87 out nocopy JTF_VARCHAR2_TABLE_2000
    , a88 out nocopy JTF_VARCHAR2_TABLE_2000
    , a89 out nocopy JTF_VARCHAR2_TABLE_2000
    , a90 out nocopy JTF_VARCHAR2_TABLE_2000
    , a91 out nocopy JTF_VARCHAR2_TABLE_2000
    , a92 out nocopy JTF_VARCHAR2_TABLE_2000
    , a93 out nocopy JTF_VARCHAR2_TABLE_2000
    , a94 out nocopy JTF_VARCHAR2_TABLE_2000
    , a95 out nocopy JTF_VARCHAR2_TABLE_2000
    , a96 out nocopy JTF_VARCHAR2_TABLE_2000
    , a97 out nocopy JTF_VARCHAR2_TABLE_2000
    , a98 out nocopy JTF_VARCHAR2_TABLE_2000
    , a99 out nocopy JTF_VARCHAR2_TABLE_2000
    , a100 out nocopy JTF_VARCHAR2_TABLE_2000
    , a101 out nocopy JTF_VARCHAR2_TABLE_2000
    , a102 out nocopy JTF_VARCHAR2_TABLE_2000
    , a103 out nocopy JTF_VARCHAR2_TABLE_2000
    , a104 out nocopy JTF_VARCHAR2_TABLE_2000
    , a105 out nocopy JTF_VARCHAR2_TABLE_2000
    , a106 out nocopy JTF_VARCHAR2_TABLE_2000
    , a107 out nocopy JTF_VARCHAR2_TABLE_2000
    , a108 out nocopy JTF_VARCHAR2_TABLE_2000
    , a109 out nocopy JTF_VARCHAR2_TABLE_2000
    , a110 out nocopy JTF_VARCHAR2_TABLE_2000
    , a111 out nocopy JTF_VARCHAR2_TABLE_2000
    , a112 out nocopy JTF_VARCHAR2_TABLE_2000
    , a113 out nocopy JTF_VARCHAR2_TABLE_2000
    , a114 out nocopy JTF_VARCHAR2_TABLE_2000
    , a115 out nocopy JTF_VARCHAR2_TABLE_2000
    , a116 out nocopy JTF_VARCHAR2_TABLE_2000
    , a117 out nocopy JTF_VARCHAR2_TABLE_2000
    , a118 out nocopy JTF_VARCHAR2_TABLE_2000
    , a119 out nocopy JTF_VARCHAR2_TABLE_2000
    , a120 out nocopy JTF_VARCHAR2_TABLE_2000
    , a121 out nocopy JTF_VARCHAR2_TABLE_2000
    , a122 out nocopy JTF_VARCHAR2_TABLE_2000
    , a123 out nocopy JTF_VARCHAR2_TABLE_2000
    , a124 out nocopy JTF_VARCHAR2_TABLE_2000
    , a125 out nocopy JTF_VARCHAR2_TABLE_2000
    , a126 out nocopy JTF_VARCHAR2_TABLE_2000
    , a127 out nocopy JTF_VARCHAR2_TABLE_2000
    , a128 out nocopy JTF_VARCHAR2_TABLE_2000
    , a129 out nocopy JTF_VARCHAR2_TABLE_2000
    , a130 out nocopy JTF_VARCHAR2_TABLE_2000
    , a131 out nocopy JTF_VARCHAR2_TABLE_2000
    , a132 out nocopy JTF_VARCHAR2_TABLE_2000
    , a133 out nocopy JTF_VARCHAR2_TABLE_2000
    , a134 out nocopy JTF_VARCHAR2_TABLE_2000
    , a135 out nocopy JTF_VARCHAR2_TABLE_2000
    , a136 out nocopy JTF_VARCHAR2_TABLE_2000
    , a137 out nocopy JTF_VARCHAR2_TABLE_2000
    , a138 out nocopy JTF_VARCHAR2_TABLE_2000
    , a139 out nocopy JTF_VARCHAR2_TABLE_2000
    , a140 out nocopy JTF_VARCHAR2_TABLE_2000
    , a141 out nocopy JTF_VARCHAR2_TABLE_2000
    , a142 out nocopy JTF_VARCHAR2_TABLE_2000
    , a143 out nocopy JTF_VARCHAR2_TABLE_2000
    , a144 out nocopy JTF_VARCHAR2_TABLE_2000
    , a145 out nocopy JTF_VARCHAR2_TABLE_2000
    , a146 out nocopy JTF_VARCHAR2_TABLE_2000
    , a147 out nocopy JTF_VARCHAR2_TABLE_2000
    , a148 out nocopy JTF_VARCHAR2_TABLE_2000
    , a149 out nocopy JTF_VARCHAR2_TABLE_2000
    , a150 out nocopy JTF_VARCHAR2_TABLE_2000
    , a151 out nocopy JTF_VARCHAR2_TABLE_2000
    , a152 out nocopy JTF_VARCHAR2_TABLE_2000
    , a153 out nocopy JTF_VARCHAR2_TABLE_2000
    , a154 out nocopy JTF_VARCHAR2_TABLE_2000
    , a155 out nocopy JTF_VARCHAR2_TABLE_2000
    , a156 out nocopy JTF_VARCHAR2_TABLE_2000
    , a157 out nocopy JTF_VARCHAR2_TABLE_2000
    , a158 out nocopy JTF_VARCHAR2_TABLE_2000
    , a159 out nocopy JTF_VARCHAR2_TABLE_2000
    , a160 out nocopy JTF_VARCHAR2_TABLE_2000
    , a161 out nocopy JTF_VARCHAR2_TABLE_2000
    , a162 out nocopy JTF_VARCHAR2_TABLE_2000
    , a163 out nocopy JTF_VARCHAR2_TABLE_2000
    , a164 out nocopy JTF_VARCHAR2_TABLE_2000
    , a165 out nocopy JTF_VARCHAR2_TABLE_2000
    , a166 out nocopy JTF_VARCHAR2_TABLE_2000
    , a167 out nocopy JTF_VARCHAR2_TABLE_2000
    , a168 out nocopy JTF_VARCHAR2_TABLE_2000
    , a169 out nocopy JTF_VARCHAR2_TABLE_2000
    , a170 out nocopy JTF_VARCHAR2_TABLE_2000
    , a171 out nocopy JTF_VARCHAR2_TABLE_2000
    , a172 out nocopy JTF_VARCHAR2_TABLE_2000
    , a173 out nocopy JTF_VARCHAR2_TABLE_2000
    , a174 out nocopy JTF_VARCHAR2_TABLE_2000
    , a175 out nocopy JTF_VARCHAR2_TABLE_2000
    , a176 out nocopy JTF_VARCHAR2_TABLE_2000
    , a177 out nocopy JTF_VARCHAR2_TABLE_2000
    , a178 out nocopy JTF_VARCHAR2_TABLE_2000
    , a179 out nocopy JTF_VARCHAR2_TABLE_2000
    , a180 out nocopy JTF_VARCHAR2_TABLE_2000
    , a181 out nocopy JTF_VARCHAR2_TABLE_2000
    , a182 out nocopy JTF_VARCHAR2_TABLE_2000
    , a183 out nocopy JTF_VARCHAR2_TABLE_2000
    , a184 out nocopy JTF_VARCHAR2_TABLE_2000
    , a185 out nocopy JTF_VARCHAR2_TABLE_2000
    , a186 out nocopy JTF_VARCHAR2_TABLE_2000
    , a187 out nocopy JTF_VARCHAR2_TABLE_2000
    , a188 out nocopy JTF_VARCHAR2_TABLE_2000
    , a189 out nocopy JTF_VARCHAR2_TABLE_2000
    , a190 out nocopy JTF_VARCHAR2_TABLE_2000
    , a191 out nocopy JTF_VARCHAR2_TABLE_2000
    , a192 out nocopy JTF_VARCHAR2_TABLE_2000
    , a193 out nocopy JTF_VARCHAR2_TABLE_2000
    , a194 out nocopy JTF_VARCHAR2_TABLE_2000
    , a195 out nocopy JTF_VARCHAR2_TABLE_2000
    , a196 out nocopy JTF_VARCHAR2_TABLE_2000
    , a197 out nocopy JTF_VARCHAR2_TABLE_2000
    , a198 out nocopy JTF_VARCHAR2_TABLE_2000
    , a199 out nocopy JTF_VARCHAR2_TABLE_2000
    , a200 out nocopy JTF_VARCHAR2_TABLE_2000
    , a201 out nocopy JTF_VARCHAR2_TABLE_2000
    , a202 out nocopy JTF_VARCHAR2_TABLE_2000
    , a203 out nocopy JTF_VARCHAR2_TABLE_2000
    , a204 out nocopy JTF_VARCHAR2_TABLE_2000
    , a205 out nocopy JTF_VARCHAR2_TABLE_2000
    , a206 out nocopy JTF_VARCHAR2_TABLE_2000
    , a207 out nocopy JTF_VARCHAR2_TABLE_2000
    , a208 out nocopy JTF_VARCHAR2_TABLE_2000
    , a209 out nocopy JTF_VARCHAR2_TABLE_2000
    , a210 out nocopy JTF_VARCHAR2_TABLE_2000
    , a211 out nocopy JTF_VARCHAR2_TABLE_2000
    , a212 out nocopy JTF_VARCHAR2_TABLE_2000
    , a213 out nocopy JTF_VARCHAR2_TABLE_2000
    , a214 out nocopy JTF_VARCHAR2_TABLE_2000
    , a215 out nocopy JTF_VARCHAR2_TABLE_2000
    , a216 out nocopy JTF_VARCHAR2_TABLE_2000
    , a217 out nocopy JTF_VARCHAR2_TABLE_2000
    , a218 out nocopy JTF_VARCHAR2_TABLE_2000
    , a219 out nocopy JTF_VARCHAR2_TABLE_2000
    , a220 out nocopy JTF_VARCHAR2_TABLE_2000
    , a221 out nocopy JTF_VARCHAR2_TABLE_2000
    , a222 out nocopy JTF_VARCHAR2_TABLE_2000
    , a223 out nocopy JTF_VARCHAR2_TABLE_2000
    , a224 out nocopy JTF_VARCHAR2_TABLE_2000
    , a225 out nocopy JTF_VARCHAR2_TABLE_2000
    , a226 out nocopy JTF_VARCHAR2_TABLE_2000
    , a227 out nocopy JTF_VARCHAR2_TABLE_2000
    , a228 out nocopy JTF_VARCHAR2_TABLE_2000
    , a229 out nocopy JTF_VARCHAR2_TABLE_2000
    , a230 out nocopy JTF_VARCHAR2_TABLE_2000
    , a231 out nocopy JTF_VARCHAR2_TABLE_2000
    , a232 out nocopy JTF_VARCHAR2_TABLE_2000
    , a233 out nocopy JTF_VARCHAR2_TABLE_2000
    , a234 out nocopy JTF_VARCHAR2_TABLE_2000
    , a235 out nocopy JTF_VARCHAR2_TABLE_2000
    , a236 out nocopy JTF_VARCHAR2_TABLE_2000
    , a237 out nocopy JTF_VARCHAR2_TABLE_2000
    , a238 out nocopy JTF_VARCHAR2_TABLE_2000
    , a239 out nocopy JTF_VARCHAR2_TABLE_2000
    , a240 out nocopy JTF_VARCHAR2_TABLE_2000
    , a241 out nocopy JTF_VARCHAR2_TABLE_2000
    , a242 out nocopy JTF_VARCHAR2_TABLE_2000
    , a243 out nocopy JTF_VARCHAR2_TABLE_2000
    , a244 out nocopy JTF_VARCHAR2_TABLE_2000
    , a245 out nocopy JTF_VARCHAR2_TABLE_2000
    , a246 out nocopy JTF_VARCHAR2_TABLE_2000
    , a247 out nocopy JTF_VARCHAR2_TABLE_2000
    , a248 out nocopy JTF_VARCHAR2_TABLE_2000
    , a249 out nocopy JTF_VARCHAR2_TABLE_2000
    , a250 out nocopy JTF_VARCHAR2_TABLE_2000
    , a251 out nocopy JTF_VARCHAR2_TABLE_2000
    , a252 out nocopy JTF_VARCHAR2_TABLE_2000
    , a253 out nocopy JTF_VARCHAR2_TABLE_2000
    , a254 out nocopy JTF_VARCHAR2_TABLE_4000
    , a255 out nocopy JTF_VARCHAR2_TABLE_4000
    , a256 out nocopy JTF_VARCHAR2_TABLE_4000
    , a257 out nocopy JTF_VARCHAR2_TABLE_4000
    , a258 out nocopy JTF_VARCHAR2_TABLE_4000
    , a259 out nocopy JTF_VARCHAR2_TABLE_4000
    , a260 out nocopy JTF_VARCHAR2_TABLE_4000
    , a261 out nocopy JTF_VARCHAR2_TABLE_4000
    , a262 out nocopy JTF_VARCHAR2_TABLE_4000
    , a263 out nocopy JTF_VARCHAR2_TABLE_4000
    , a264 out nocopy JTF_VARCHAR2_TABLE_100
    , a265 out nocopy JTF_NUMBER_TABLE
    , a266 out nocopy JTF_VARCHAR2_TABLE_100
    , a267 out nocopy JTF_VARCHAR2_TABLE_4000
    , a268 out nocopy JTF_VARCHAR2_TABLE_2000
    , a269 out nocopy JTF_VARCHAR2_TABLE_100
    , a270 out nocopy JTF_VARCHAR2_TABLE_2000
    , a271 out nocopy JTF_VARCHAR2_TABLE_2000
    , a272 out nocopy JTF_VARCHAR2_TABLE_2000
    , a273 out nocopy JTF_VARCHAR2_TABLE_2000
    , a274 out nocopy JTF_VARCHAR2_TABLE_2000
    , a275 out nocopy JTF_VARCHAR2_TABLE_2000
    , a276 out nocopy JTF_VARCHAR2_TABLE_2000
    , a277 out nocopy JTF_VARCHAR2_TABLE_2000
    , a278 out nocopy JTF_VARCHAR2_TABLE_2000
    , a279 out nocopy JTF_VARCHAR2_TABLE_2000
    , a280 out nocopy JTF_VARCHAR2_TABLE_2000
    , a281 out nocopy JTF_VARCHAR2_TABLE_2000
    , a282 out nocopy JTF_VARCHAR2_TABLE_2000
    , a283 out nocopy JTF_VARCHAR2_TABLE_2000
    , a284 out nocopy JTF_VARCHAR2_TABLE_2000
    , a285 out nocopy JTF_VARCHAR2_TABLE_2000
    , a286 out nocopy JTF_VARCHAR2_TABLE_2000
    , a287 out nocopy JTF_VARCHAR2_TABLE_2000
    , a288 out nocopy JTF_VARCHAR2_TABLE_2000
    , a289 out nocopy JTF_VARCHAR2_TABLE_2000
    , a290 out nocopy JTF_VARCHAR2_TABLE_2000
    , a291 out nocopy JTF_VARCHAR2_TABLE_2000
    , a292 out nocopy JTF_VARCHAR2_TABLE_2000
    , a293 out nocopy JTF_VARCHAR2_TABLE_2000
    , a294 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_4000();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_2000();
    a18 := JTF_VARCHAR2_TABLE_2000();
    a19 := JTF_VARCHAR2_TABLE_2000();
    a20 := JTF_VARCHAR2_TABLE_2000();
    a21 := JTF_VARCHAR2_TABLE_2000();
    a22 := JTF_VARCHAR2_TABLE_2000();
    a23 := JTF_VARCHAR2_TABLE_2000();
    a24 := JTF_VARCHAR2_TABLE_2000();
    a25 := JTF_VARCHAR2_TABLE_2000();
    a26 := JTF_VARCHAR2_TABLE_2000();
    a27 := JTF_VARCHAR2_TABLE_2000();
    a28 := JTF_VARCHAR2_TABLE_2000();
    a29 := JTF_VARCHAR2_TABLE_2000();
    a30 := JTF_VARCHAR2_TABLE_2000();
    a31 := JTF_VARCHAR2_TABLE_2000();
    a32 := JTF_VARCHAR2_TABLE_2000();
    a33 := JTF_VARCHAR2_TABLE_2000();
    a34 := JTF_VARCHAR2_TABLE_2000();
    a35 := JTF_VARCHAR2_TABLE_2000();
    a36 := JTF_VARCHAR2_TABLE_2000();
    a37 := JTF_VARCHAR2_TABLE_2000();
    a38 := JTF_VARCHAR2_TABLE_2000();
    a39 := JTF_VARCHAR2_TABLE_2000();
    a40 := JTF_VARCHAR2_TABLE_2000();
    a41 := JTF_VARCHAR2_TABLE_2000();
    a42 := JTF_VARCHAR2_TABLE_2000();
    a43 := JTF_VARCHAR2_TABLE_2000();
    a44 := JTF_VARCHAR2_TABLE_2000();
    a45 := JTF_VARCHAR2_TABLE_2000();
    a46 := JTF_VARCHAR2_TABLE_2000();
    a47 := JTF_VARCHAR2_TABLE_2000();
    a48 := JTF_VARCHAR2_TABLE_2000();
    a49 := JTF_VARCHAR2_TABLE_2000();
    a50 := JTF_VARCHAR2_TABLE_2000();
    a51 := JTF_VARCHAR2_TABLE_2000();
    a52 := JTF_VARCHAR2_TABLE_2000();
    a53 := JTF_VARCHAR2_TABLE_2000();
    a54 := JTF_VARCHAR2_TABLE_2000();
    a55 := JTF_VARCHAR2_TABLE_2000();
    a56 := JTF_VARCHAR2_TABLE_2000();
    a57 := JTF_VARCHAR2_TABLE_2000();
    a58 := JTF_VARCHAR2_TABLE_2000();
    a59 := JTF_VARCHAR2_TABLE_2000();
    a60 := JTF_VARCHAR2_TABLE_2000();
    a61 := JTF_VARCHAR2_TABLE_2000();
    a62 := JTF_VARCHAR2_TABLE_2000();
    a63 := JTF_VARCHAR2_TABLE_2000();
    a64 := JTF_VARCHAR2_TABLE_2000();
    a65 := JTF_VARCHAR2_TABLE_2000();
    a66 := JTF_VARCHAR2_TABLE_2000();
    a67 := JTF_VARCHAR2_TABLE_2000();
    a68 := JTF_VARCHAR2_TABLE_2000();
    a69 := JTF_VARCHAR2_TABLE_2000();
    a70 := JTF_VARCHAR2_TABLE_2000();
    a71 := JTF_VARCHAR2_TABLE_2000();
    a72 := JTF_VARCHAR2_TABLE_2000();
    a73 := JTF_VARCHAR2_TABLE_2000();
    a74 := JTF_VARCHAR2_TABLE_2000();
    a75 := JTF_VARCHAR2_TABLE_2000();
    a76 := JTF_VARCHAR2_TABLE_2000();
    a77 := JTF_VARCHAR2_TABLE_2000();
    a78 := JTF_VARCHAR2_TABLE_2000();
    a79 := JTF_VARCHAR2_TABLE_2000();
    a80 := JTF_VARCHAR2_TABLE_2000();
    a81 := JTF_VARCHAR2_TABLE_2000();
    a82 := JTF_VARCHAR2_TABLE_2000();
    a83 := JTF_VARCHAR2_TABLE_2000();
    a84 := JTF_VARCHAR2_TABLE_2000();
    a85 := JTF_VARCHAR2_TABLE_2000();
    a86 := JTF_VARCHAR2_TABLE_2000();
    a87 := JTF_VARCHAR2_TABLE_2000();
    a88 := JTF_VARCHAR2_TABLE_2000();
    a89 := JTF_VARCHAR2_TABLE_2000();
    a90 := JTF_VARCHAR2_TABLE_2000();
    a91 := JTF_VARCHAR2_TABLE_2000();
    a92 := JTF_VARCHAR2_TABLE_2000();
    a93 := JTF_VARCHAR2_TABLE_2000();
    a94 := JTF_VARCHAR2_TABLE_2000();
    a95 := JTF_VARCHAR2_TABLE_2000();
    a96 := JTF_VARCHAR2_TABLE_2000();
    a97 := JTF_VARCHAR2_TABLE_2000();
    a98 := JTF_VARCHAR2_TABLE_2000();
    a99 := JTF_VARCHAR2_TABLE_2000();
    a100 := JTF_VARCHAR2_TABLE_2000();
    a101 := JTF_VARCHAR2_TABLE_2000();
    a102 := JTF_VARCHAR2_TABLE_2000();
    a103 := JTF_VARCHAR2_TABLE_2000();
    a104 := JTF_VARCHAR2_TABLE_2000();
    a105 := JTF_VARCHAR2_TABLE_2000();
    a106 := JTF_VARCHAR2_TABLE_2000();
    a107 := JTF_VARCHAR2_TABLE_2000();
    a108 := JTF_VARCHAR2_TABLE_2000();
    a109 := JTF_VARCHAR2_TABLE_2000();
    a110 := JTF_VARCHAR2_TABLE_2000();
    a111 := JTF_VARCHAR2_TABLE_2000();
    a112 := JTF_VARCHAR2_TABLE_2000();
    a113 := JTF_VARCHAR2_TABLE_2000();
    a114 := JTF_VARCHAR2_TABLE_2000();
    a115 := JTF_VARCHAR2_TABLE_2000();
    a116 := JTF_VARCHAR2_TABLE_2000();
    a117 := JTF_VARCHAR2_TABLE_2000();
    a118 := JTF_VARCHAR2_TABLE_2000();
    a119 := JTF_VARCHAR2_TABLE_2000();
    a120 := JTF_VARCHAR2_TABLE_2000();
    a121 := JTF_VARCHAR2_TABLE_2000();
    a122 := JTF_VARCHAR2_TABLE_2000();
    a123 := JTF_VARCHAR2_TABLE_2000();
    a124 := JTF_VARCHAR2_TABLE_2000();
    a125 := JTF_VARCHAR2_TABLE_2000();
    a126 := JTF_VARCHAR2_TABLE_2000();
    a127 := JTF_VARCHAR2_TABLE_2000();
    a128 := JTF_VARCHAR2_TABLE_2000();
    a129 := JTF_VARCHAR2_TABLE_2000();
    a130 := JTF_VARCHAR2_TABLE_2000();
    a131 := JTF_VARCHAR2_TABLE_2000();
    a132 := JTF_VARCHAR2_TABLE_2000();
    a133 := JTF_VARCHAR2_TABLE_2000();
    a134 := JTF_VARCHAR2_TABLE_2000();
    a135 := JTF_VARCHAR2_TABLE_2000();
    a136 := JTF_VARCHAR2_TABLE_2000();
    a137 := JTF_VARCHAR2_TABLE_2000();
    a138 := JTF_VARCHAR2_TABLE_2000();
    a139 := JTF_VARCHAR2_TABLE_2000();
    a140 := JTF_VARCHAR2_TABLE_2000();
    a141 := JTF_VARCHAR2_TABLE_2000();
    a142 := JTF_VARCHAR2_TABLE_2000();
    a143 := JTF_VARCHAR2_TABLE_2000();
    a144 := JTF_VARCHAR2_TABLE_2000();
    a145 := JTF_VARCHAR2_TABLE_2000();
    a146 := JTF_VARCHAR2_TABLE_2000();
    a147 := JTF_VARCHAR2_TABLE_2000();
    a148 := JTF_VARCHAR2_TABLE_2000();
    a149 := JTF_VARCHAR2_TABLE_2000();
    a150 := JTF_VARCHAR2_TABLE_2000();
    a151 := JTF_VARCHAR2_TABLE_2000();
    a152 := JTF_VARCHAR2_TABLE_2000();
    a153 := JTF_VARCHAR2_TABLE_2000();
    a154 := JTF_VARCHAR2_TABLE_2000();
    a155 := JTF_VARCHAR2_TABLE_2000();
    a156 := JTF_VARCHAR2_TABLE_2000();
    a157 := JTF_VARCHAR2_TABLE_2000();
    a158 := JTF_VARCHAR2_TABLE_2000();
    a159 := JTF_VARCHAR2_TABLE_2000();
    a160 := JTF_VARCHAR2_TABLE_2000();
    a161 := JTF_VARCHAR2_TABLE_2000();
    a162 := JTF_VARCHAR2_TABLE_2000();
    a163 := JTF_VARCHAR2_TABLE_2000();
    a164 := JTF_VARCHAR2_TABLE_2000();
    a165 := JTF_VARCHAR2_TABLE_2000();
    a166 := JTF_VARCHAR2_TABLE_2000();
    a167 := JTF_VARCHAR2_TABLE_2000();
    a168 := JTF_VARCHAR2_TABLE_2000();
    a169 := JTF_VARCHAR2_TABLE_2000();
    a170 := JTF_VARCHAR2_TABLE_2000();
    a171 := JTF_VARCHAR2_TABLE_2000();
    a172 := JTF_VARCHAR2_TABLE_2000();
    a173 := JTF_VARCHAR2_TABLE_2000();
    a174 := JTF_VARCHAR2_TABLE_2000();
    a175 := JTF_VARCHAR2_TABLE_2000();
    a176 := JTF_VARCHAR2_TABLE_2000();
    a177 := JTF_VARCHAR2_TABLE_2000();
    a178 := JTF_VARCHAR2_TABLE_2000();
    a179 := JTF_VARCHAR2_TABLE_2000();
    a180 := JTF_VARCHAR2_TABLE_2000();
    a181 := JTF_VARCHAR2_TABLE_2000();
    a182 := JTF_VARCHAR2_TABLE_2000();
    a183 := JTF_VARCHAR2_TABLE_2000();
    a184 := JTF_VARCHAR2_TABLE_2000();
    a185 := JTF_VARCHAR2_TABLE_2000();
    a186 := JTF_VARCHAR2_TABLE_2000();
    a187 := JTF_VARCHAR2_TABLE_2000();
    a188 := JTF_VARCHAR2_TABLE_2000();
    a189 := JTF_VARCHAR2_TABLE_2000();
    a190 := JTF_VARCHAR2_TABLE_2000();
    a191 := JTF_VARCHAR2_TABLE_2000();
    a192 := JTF_VARCHAR2_TABLE_2000();
    a193 := JTF_VARCHAR2_TABLE_2000();
    a194 := JTF_VARCHAR2_TABLE_2000();
    a195 := JTF_VARCHAR2_TABLE_2000();
    a196 := JTF_VARCHAR2_TABLE_2000();
    a197 := JTF_VARCHAR2_TABLE_2000();
    a198 := JTF_VARCHAR2_TABLE_2000();
    a199 := JTF_VARCHAR2_TABLE_2000();
    a200 := JTF_VARCHAR2_TABLE_2000();
    a201 := JTF_VARCHAR2_TABLE_2000();
    a202 := JTF_VARCHAR2_TABLE_2000();
    a203 := JTF_VARCHAR2_TABLE_2000();
    a204 := JTF_VARCHAR2_TABLE_2000();
    a205 := JTF_VARCHAR2_TABLE_2000();
    a206 := JTF_VARCHAR2_TABLE_2000();
    a207 := JTF_VARCHAR2_TABLE_2000();
    a208 := JTF_VARCHAR2_TABLE_2000();
    a209 := JTF_VARCHAR2_TABLE_2000();
    a210 := JTF_VARCHAR2_TABLE_2000();
    a211 := JTF_VARCHAR2_TABLE_2000();
    a212 := JTF_VARCHAR2_TABLE_2000();
    a213 := JTF_VARCHAR2_TABLE_2000();
    a214 := JTF_VARCHAR2_TABLE_2000();
    a215 := JTF_VARCHAR2_TABLE_2000();
    a216 := JTF_VARCHAR2_TABLE_2000();
    a217 := JTF_VARCHAR2_TABLE_2000();
    a218 := JTF_VARCHAR2_TABLE_2000();
    a219 := JTF_VARCHAR2_TABLE_2000();
    a220 := JTF_VARCHAR2_TABLE_2000();
    a221 := JTF_VARCHAR2_TABLE_2000();
    a222 := JTF_VARCHAR2_TABLE_2000();
    a223 := JTF_VARCHAR2_TABLE_2000();
    a224 := JTF_VARCHAR2_TABLE_2000();
    a225 := JTF_VARCHAR2_TABLE_2000();
    a226 := JTF_VARCHAR2_TABLE_2000();
    a227 := JTF_VARCHAR2_TABLE_2000();
    a228 := JTF_VARCHAR2_TABLE_2000();
    a229 := JTF_VARCHAR2_TABLE_2000();
    a230 := JTF_VARCHAR2_TABLE_2000();
    a231 := JTF_VARCHAR2_TABLE_2000();
    a232 := JTF_VARCHAR2_TABLE_2000();
    a233 := JTF_VARCHAR2_TABLE_2000();
    a234 := JTF_VARCHAR2_TABLE_2000();
    a235 := JTF_VARCHAR2_TABLE_2000();
    a236 := JTF_VARCHAR2_TABLE_2000();
    a237 := JTF_VARCHAR2_TABLE_2000();
    a238 := JTF_VARCHAR2_TABLE_2000();
    a239 := JTF_VARCHAR2_TABLE_2000();
    a240 := JTF_VARCHAR2_TABLE_2000();
    a241 := JTF_VARCHAR2_TABLE_2000();
    a242 := JTF_VARCHAR2_TABLE_2000();
    a243 := JTF_VARCHAR2_TABLE_2000();
    a244 := JTF_VARCHAR2_TABLE_2000();
    a245 := JTF_VARCHAR2_TABLE_2000();
    a246 := JTF_VARCHAR2_TABLE_2000();
    a247 := JTF_VARCHAR2_TABLE_2000();
    a248 := JTF_VARCHAR2_TABLE_2000();
    a249 := JTF_VARCHAR2_TABLE_2000();
    a250 := JTF_VARCHAR2_TABLE_2000();
    a251 := JTF_VARCHAR2_TABLE_2000();
    a252 := JTF_VARCHAR2_TABLE_2000();
    a253 := JTF_VARCHAR2_TABLE_2000();
    a254 := JTF_VARCHAR2_TABLE_4000();
    a255 := JTF_VARCHAR2_TABLE_4000();
    a256 := JTF_VARCHAR2_TABLE_4000();
    a257 := JTF_VARCHAR2_TABLE_4000();
    a258 := JTF_VARCHAR2_TABLE_4000();
    a259 := JTF_VARCHAR2_TABLE_4000();
    a260 := JTF_VARCHAR2_TABLE_4000();
    a261 := JTF_VARCHAR2_TABLE_4000();
    a262 := JTF_VARCHAR2_TABLE_4000();
    a263 := JTF_VARCHAR2_TABLE_4000();
    a264 := JTF_VARCHAR2_TABLE_100();
    a265 := JTF_NUMBER_TABLE();
    a266 := JTF_VARCHAR2_TABLE_100();
    a267 := JTF_VARCHAR2_TABLE_4000();
    a268 := JTF_VARCHAR2_TABLE_2000();
    a269 := JTF_VARCHAR2_TABLE_100();
    a270 := JTF_VARCHAR2_TABLE_2000();
    a271 := JTF_VARCHAR2_TABLE_2000();
    a272 := JTF_VARCHAR2_TABLE_2000();
    a273 := JTF_VARCHAR2_TABLE_2000();
    a274 := JTF_VARCHAR2_TABLE_2000();
    a275 := JTF_VARCHAR2_TABLE_2000();
    a276 := JTF_VARCHAR2_TABLE_2000();
    a277 := JTF_VARCHAR2_TABLE_2000();
    a278 := JTF_VARCHAR2_TABLE_2000();
    a279 := JTF_VARCHAR2_TABLE_2000();
    a280 := JTF_VARCHAR2_TABLE_2000();
    a281 := JTF_VARCHAR2_TABLE_2000();
    a282 := JTF_VARCHAR2_TABLE_2000();
    a283 := JTF_VARCHAR2_TABLE_2000();
    a284 := JTF_VARCHAR2_TABLE_2000();
    a285 := JTF_VARCHAR2_TABLE_2000();
    a286 := JTF_VARCHAR2_TABLE_2000();
    a287 := JTF_VARCHAR2_TABLE_2000();
    a288 := JTF_VARCHAR2_TABLE_2000();
    a289 := JTF_VARCHAR2_TABLE_2000();
    a290 := JTF_VARCHAR2_TABLE_2000();
    a291 := JTF_VARCHAR2_TABLE_2000();
    a292 := JTF_VARCHAR2_TABLE_2000();
    a293 := JTF_VARCHAR2_TABLE_2000();
    a294 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_4000();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_2000();
      a18 := JTF_VARCHAR2_TABLE_2000();
      a19 := JTF_VARCHAR2_TABLE_2000();
      a20 := JTF_VARCHAR2_TABLE_2000();
      a21 := JTF_VARCHAR2_TABLE_2000();
      a22 := JTF_VARCHAR2_TABLE_2000();
      a23 := JTF_VARCHAR2_TABLE_2000();
      a24 := JTF_VARCHAR2_TABLE_2000();
      a25 := JTF_VARCHAR2_TABLE_2000();
      a26 := JTF_VARCHAR2_TABLE_2000();
      a27 := JTF_VARCHAR2_TABLE_2000();
      a28 := JTF_VARCHAR2_TABLE_2000();
      a29 := JTF_VARCHAR2_TABLE_2000();
      a30 := JTF_VARCHAR2_TABLE_2000();
      a31 := JTF_VARCHAR2_TABLE_2000();
      a32 := JTF_VARCHAR2_TABLE_2000();
      a33 := JTF_VARCHAR2_TABLE_2000();
      a34 := JTF_VARCHAR2_TABLE_2000();
      a35 := JTF_VARCHAR2_TABLE_2000();
      a36 := JTF_VARCHAR2_TABLE_2000();
      a37 := JTF_VARCHAR2_TABLE_2000();
      a38 := JTF_VARCHAR2_TABLE_2000();
      a39 := JTF_VARCHAR2_TABLE_2000();
      a40 := JTF_VARCHAR2_TABLE_2000();
      a41 := JTF_VARCHAR2_TABLE_2000();
      a42 := JTF_VARCHAR2_TABLE_2000();
      a43 := JTF_VARCHAR2_TABLE_2000();
      a44 := JTF_VARCHAR2_TABLE_2000();
      a45 := JTF_VARCHAR2_TABLE_2000();
      a46 := JTF_VARCHAR2_TABLE_2000();
      a47 := JTF_VARCHAR2_TABLE_2000();
      a48 := JTF_VARCHAR2_TABLE_2000();
      a49 := JTF_VARCHAR2_TABLE_2000();
      a50 := JTF_VARCHAR2_TABLE_2000();
      a51 := JTF_VARCHAR2_TABLE_2000();
      a52 := JTF_VARCHAR2_TABLE_2000();
      a53 := JTF_VARCHAR2_TABLE_2000();
      a54 := JTF_VARCHAR2_TABLE_2000();
      a55 := JTF_VARCHAR2_TABLE_2000();
      a56 := JTF_VARCHAR2_TABLE_2000();
      a57 := JTF_VARCHAR2_TABLE_2000();
      a58 := JTF_VARCHAR2_TABLE_2000();
      a59 := JTF_VARCHAR2_TABLE_2000();
      a60 := JTF_VARCHAR2_TABLE_2000();
      a61 := JTF_VARCHAR2_TABLE_2000();
      a62 := JTF_VARCHAR2_TABLE_2000();
      a63 := JTF_VARCHAR2_TABLE_2000();
      a64 := JTF_VARCHAR2_TABLE_2000();
      a65 := JTF_VARCHAR2_TABLE_2000();
      a66 := JTF_VARCHAR2_TABLE_2000();
      a67 := JTF_VARCHAR2_TABLE_2000();
      a68 := JTF_VARCHAR2_TABLE_2000();
      a69 := JTF_VARCHAR2_TABLE_2000();
      a70 := JTF_VARCHAR2_TABLE_2000();
      a71 := JTF_VARCHAR2_TABLE_2000();
      a72 := JTF_VARCHAR2_TABLE_2000();
      a73 := JTF_VARCHAR2_TABLE_2000();
      a74 := JTF_VARCHAR2_TABLE_2000();
      a75 := JTF_VARCHAR2_TABLE_2000();
      a76 := JTF_VARCHAR2_TABLE_2000();
      a77 := JTF_VARCHAR2_TABLE_2000();
      a78 := JTF_VARCHAR2_TABLE_2000();
      a79 := JTF_VARCHAR2_TABLE_2000();
      a80 := JTF_VARCHAR2_TABLE_2000();
      a81 := JTF_VARCHAR2_TABLE_2000();
      a82 := JTF_VARCHAR2_TABLE_2000();
      a83 := JTF_VARCHAR2_TABLE_2000();
      a84 := JTF_VARCHAR2_TABLE_2000();
      a85 := JTF_VARCHAR2_TABLE_2000();
      a86 := JTF_VARCHAR2_TABLE_2000();
      a87 := JTF_VARCHAR2_TABLE_2000();
      a88 := JTF_VARCHAR2_TABLE_2000();
      a89 := JTF_VARCHAR2_TABLE_2000();
      a90 := JTF_VARCHAR2_TABLE_2000();
      a91 := JTF_VARCHAR2_TABLE_2000();
      a92 := JTF_VARCHAR2_TABLE_2000();
      a93 := JTF_VARCHAR2_TABLE_2000();
      a94 := JTF_VARCHAR2_TABLE_2000();
      a95 := JTF_VARCHAR2_TABLE_2000();
      a96 := JTF_VARCHAR2_TABLE_2000();
      a97 := JTF_VARCHAR2_TABLE_2000();
      a98 := JTF_VARCHAR2_TABLE_2000();
      a99 := JTF_VARCHAR2_TABLE_2000();
      a100 := JTF_VARCHAR2_TABLE_2000();
      a101 := JTF_VARCHAR2_TABLE_2000();
      a102 := JTF_VARCHAR2_TABLE_2000();
      a103 := JTF_VARCHAR2_TABLE_2000();
      a104 := JTF_VARCHAR2_TABLE_2000();
      a105 := JTF_VARCHAR2_TABLE_2000();
      a106 := JTF_VARCHAR2_TABLE_2000();
      a107 := JTF_VARCHAR2_TABLE_2000();
      a108 := JTF_VARCHAR2_TABLE_2000();
      a109 := JTF_VARCHAR2_TABLE_2000();
      a110 := JTF_VARCHAR2_TABLE_2000();
      a111 := JTF_VARCHAR2_TABLE_2000();
      a112 := JTF_VARCHAR2_TABLE_2000();
      a113 := JTF_VARCHAR2_TABLE_2000();
      a114 := JTF_VARCHAR2_TABLE_2000();
      a115 := JTF_VARCHAR2_TABLE_2000();
      a116 := JTF_VARCHAR2_TABLE_2000();
      a117 := JTF_VARCHAR2_TABLE_2000();
      a118 := JTF_VARCHAR2_TABLE_2000();
      a119 := JTF_VARCHAR2_TABLE_2000();
      a120 := JTF_VARCHAR2_TABLE_2000();
      a121 := JTF_VARCHAR2_TABLE_2000();
      a122 := JTF_VARCHAR2_TABLE_2000();
      a123 := JTF_VARCHAR2_TABLE_2000();
      a124 := JTF_VARCHAR2_TABLE_2000();
      a125 := JTF_VARCHAR2_TABLE_2000();
      a126 := JTF_VARCHAR2_TABLE_2000();
      a127 := JTF_VARCHAR2_TABLE_2000();
      a128 := JTF_VARCHAR2_TABLE_2000();
      a129 := JTF_VARCHAR2_TABLE_2000();
      a130 := JTF_VARCHAR2_TABLE_2000();
      a131 := JTF_VARCHAR2_TABLE_2000();
      a132 := JTF_VARCHAR2_TABLE_2000();
      a133 := JTF_VARCHAR2_TABLE_2000();
      a134 := JTF_VARCHAR2_TABLE_2000();
      a135 := JTF_VARCHAR2_TABLE_2000();
      a136 := JTF_VARCHAR2_TABLE_2000();
      a137 := JTF_VARCHAR2_TABLE_2000();
      a138 := JTF_VARCHAR2_TABLE_2000();
      a139 := JTF_VARCHAR2_TABLE_2000();
      a140 := JTF_VARCHAR2_TABLE_2000();
      a141 := JTF_VARCHAR2_TABLE_2000();
      a142 := JTF_VARCHAR2_TABLE_2000();
      a143 := JTF_VARCHAR2_TABLE_2000();
      a144 := JTF_VARCHAR2_TABLE_2000();
      a145 := JTF_VARCHAR2_TABLE_2000();
      a146 := JTF_VARCHAR2_TABLE_2000();
      a147 := JTF_VARCHAR2_TABLE_2000();
      a148 := JTF_VARCHAR2_TABLE_2000();
      a149 := JTF_VARCHAR2_TABLE_2000();
      a150 := JTF_VARCHAR2_TABLE_2000();
      a151 := JTF_VARCHAR2_TABLE_2000();
      a152 := JTF_VARCHAR2_TABLE_2000();
      a153 := JTF_VARCHAR2_TABLE_2000();
      a154 := JTF_VARCHAR2_TABLE_2000();
      a155 := JTF_VARCHAR2_TABLE_2000();
      a156 := JTF_VARCHAR2_TABLE_2000();
      a157 := JTF_VARCHAR2_TABLE_2000();
      a158 := JTF_VARCHAR2_TABLE_2000();
      a159 := JTF_VARCHAR2_TABLE_2000();
      a160 := JTF_VARCHAR2_TABLE_2000();
      a161 := JTF_VARCHAR2_TABLE_2000();
      a162 := JTF_VARCHAR2_TABLE_2000();
      a163 := JTF_VARCHAR2_TABLE_2000();
      a164 := JTF_VARCHAR2_TABLE_2000();
      a165 := JTF_VARCHAR2_TABLE_2000();
      a166 := JTF_VARCHAR2_TABLE_2000();
      a167 := JTF_VARCHAR2_TABLE_2000();
      a168 := JTF_VARCHAR2_TABLE_2000();
      a169 := JTF_VARCHAR2_TABLE_2000();
      a170 := JTF_VARCHAR2_TABLE_2000();
      a171 := JTF_VARCHAR2_TABLE_2000();
      a172 := JTF_VARCHAR2_TABLE_2000();
      a173 := JTF_VARCHAR2_TABLE_2000();
      a174 := JTF_VARCHAR2_TABLE_2000();
      a175 := JTF_VARCHAR2_TABLE_2000();
      a176 := JTF_VARCHAR2_TABLE_2000();
      a177 := JTF_VARCHAR2_TABLE_2000();
      a178 := JTF_VARCHAR2_TABLE_2000();
      a179 := JTF_VARCHAR2_TABLE_2000();
      a180 := JTF_VARCHAR2_TABLE_2000();
      a181 := JTF_VARCHAR2_TABLE_2000();
      a182 := JTF_VARCHAR2_TABLE_2000();
      a183 := JTF_VARCHAR2_TABLE_2000();
      a184 := JTF_VARCHAR2_TABLE_2000();
      a185 := JTF_VARCHAR2_TABLE_2000();
      a186 := JTF_VARCHAR2_TABLE_2000();
      a187 := JTF_VARCHAR2_TABLE_2000();
      a188 := JTF_VARCHAR2_TABLE_2000();
      a189 := JTF_VARCHAR2_TABLE_2000();
      a190 := JTF_VARCHAR2_TABLE_2000();
      a191 := JTF_VARCHAR2_TABLE_2000();
      a192 := JTF_VARCHAR2_TABLE_2000();
      a193 := JTF_VARCHAR2_TABLE_2000();
      a194 := JTF_VARCHAR2_TABLE_2000();
      a195 := JTF_VARCHAR2_TABLE_2000();
      a196 := JTF_VARCHAR2_TABLE_2000();
      a197 := JTF_VARCHAR2_TABLE_2000();
      a198 := JTF_VARCHAR2_TABLE_2000();
      a199 := JTF_VARCHAR2_TABLE_2000();
      a200 := JTF_VARCHAR2_TABLE_2000();
      a201 := JTF_VARCHAR2_TABLE_2000();
      a202 := JTF_VARCHAR2_TABLE_2000();
      a203 := JTF_VARCHAR2_TABLE_2000();
      a204 := JTF_VARCHAR2_TABLE_2000();
      a205 := JTF_VARCHAR2_TABLE_2000();
      a206 := JTF_VARCHAR2_TABLE_2000();
      a207 := JTF_VARCHAR2_TABLE_2000();
      a208 := JTF_VARCHAR2_TABLE_2000();
      a209 := JTF_VARCHAR2_TABLE_2000();
      a210 := JTF_VARCHAR2_TABLE_2000();
      a211 := JTF_VARCHAR2_TABLE_2000();
      a212 := JTF_VARCHAR2_TABLE_2000();
      a213 := JTF_VARCHAR2_TABLE_2000();
      a214 := JTF_VARCHAR2_TABLE_2000();
      a215 := JTF_VARCHAR2_TABLE_2000();
      a216 := JTF_VARCHAR2_TABLE_2000();
      a217 := JTF_VARCHAR2_TABLE_2000();
      a218 := JTF_VARCHAR2_TABLE_2000();
      a219 := JTF_VARCHAR2_TABLE_2000();
      a220 := JTF_VARCHAR2_TABLE_2000();
      a221 := JTF_VARCHAR2_TABLE_2000();
      a222 := JTF_VARCHAR2_TABLE_2000();
      a223 := JTF_VARCHAR2_TABLE_2000();
      a224 := JTF_VARCHAR2_TABLE_2000();
      a225 := JTF_VARCHAR2_TABLE_2000();
      a226 := JTF_VARCHAR2_TABLE_2000();
      a227 := JTF_VARCHAR2_TABLE_2000();
      a228 := JTF_VARCHAR2_TABLE_2000();
      a229 := JTF_VARCHAR2_TABLE_2000();
      a230 := JTF_VARCHAR2_TABLE_2000();
      a231 := JTF_VARCHAR2_TABLE_2000();
      a232 := JTF_VARCHAR2_TABLE_2000();
      a233 := JTF_VARCHAR2_TABLE_2000();
      a234 := JTF_VARCHAR2_TABLE_2000();
      a235 := JTF_VARCHAR2_TABLE_2000();
      a236 := JTF_VARCHAR2_TABLE_2000();
      a237 := JTF_VARCHAR2_TABLE_2000();
      a238 := JTF_VARCHAR2_TABLE_2000();
      a239 := JTF_VARCHAR2_TABLE_2000();
      a240 := JTF_VARCHAR2_TABLE_2000();
      a241 := JTF_VARCHAR2_TABLE_2000();
      a242 := JTF_VARCHAR2_TABLE_2000();
      a243 := JTF_VARCHAR2_TABLE_2000();
      a244 := JTF_VARCHAR2_TABLE_2000();
      a245 := JTF_VARCHAR2_TABLE_2000();
      a246 := JTF_VARCHAR2_TABLE_2000();
      a247 := JTF_VARCHAR2_TABLE_2000();
      a248 := JTF_VARCHAR2_TABLE_2000();
      a249 := JTF_VARCHAR2_TABLE_2000();
      a250 := JTF_VARCHAR2_TABLE_2000();
      a251 := JTF_VARCHAR2_TABLE_2000();
      a252 := JTF_VARCHAR2_TABLE_2000();
      a253 := JTF_VARCHAR2_TABLE_2000();
      a254 := JTF_VARCHAR2_TABLE_4000();
      a255 := JTF_VARCHAR2_TABLE_4000();
      a256 := JTF_VARCHAR2_TABLE_4000();
      a257 := JTF_VARCHAR2_TABLE_4000();
      a258 := JTF_VARCHAR2_TABLE_4000();
      a259 := JTF_VARCHAR2_TABLE_4000();
      a260 := JTF_VARCHAR2_TABLE_4000();
      a261 := JTF_VARCHAR2_TABLE_4000();
      a262 := JTF_VARCHAR2_TABLE_4000();
      a263 := JTF_VARCHAR2_TABLE_4000();
      a264 := JTF_VARCHAR2_TABLE_100();
      a265 := JTF_NUMBER_TABLE();
      a266 := JTF_VARCHAR2_TABLE_100();
      a267 := JTF_VARCHAR2_TABLE_4000();
      a268 := JTF_VARCHAR2_TABLE_2000();
      a269 := JTF_VARCHAR2_TABLE_100();
      a270 := JTF_VARCHAR2_TABLE_2000();
      a271 := JTF_VARCHAR2_TABLE_2000();
      a272 := JTF_VARCHAR2_TABLE_2000();
      a273 := JTF_VARCHAR2_TABLE_2000();
      a274 := JTF_VARCHAR2_TABLE_2000();
      a275 := JTF_VARCHAR2_TABLE_2000();
      a276 := JTF_VARCHAR2_TABLE_2000();
      a277 := JTF_VARCHAR2_TABLE_2000();
      a278 := JTF_VARCHAR2_TABLE_2000();
      a279 := JTF_VARCHAR2_TABLE_2000();
      a280 := JTF_VARCHAR2_TABLE_2000();
      a281 := JTF_VARCHAR2_TABLE_2000();
      a282 := JTF_VARCHAR2_TABLE_2000();
      a283 := JTF_VARCHAR2_TABLE_2000();
      a284 := JTF_VARCHAR2_TABLE_2000();
      a285 := JTF_VARCHAR2_TABLE_2000();
      a286 := JTF_VARCHAR2_TABLE_2000();
      a287 := JTF_VARCHAR2_TABLE_2000();
      a288 := JTF_VARCHAR2_TABLE_2000();
      a289 := JTF_VARCHAR2_TABLE_2000();
      a290 := JTF_VARCHAR2_TABLE_2000();
      a291 := JTF_VARCHAR2_TABLE_2000();
      a292 := JTF_VARCHAR2_TABLE_2000();
      a293 := JTF_VARCHAR2_TABLE_2000();
      a294 := JTF_VARCHAR2_TABLE_2000();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        a55.extend(t.count);
        a56.extend(t.count);
        a57.extend(t.count);
        a58.extend(t.count);
        a59.extend(t.count);
        a60.extend(t.count);
        a61.extend(t.count);
        a62.extend(t.count);
        a63.extend(t.count);
        a64.extend(t.count);
        a65.extend(t.count);
        a66.extend(t.count);
        a67.extend(t.count);
        a68.extend(t.count);
        a69.extend(t.count);
        a70.extend(t.count);
        a71.extend(t.count);
        a72.extend(t.count);
        a73.extend(t.count);
        a74.extend(t.count);
        a75.extend(t.count);
        a76.extend(t.count);
        a77.extend(t.count);
        a78.extend(t.count);
        a79.extend(t.count);
        a80.extend(t.count);
        a81.extend(t.count);
        a82.extend(t.count);
        a83.extend(t.count);
        a84.extend(t.count);
        a85.extend(t.count);
        a86.extend(t.count);
        a87.extend(t.count);
        a88.extend(t.count);
        a89.extend(t.count);
        a90.extend(t.count);
        a91.extend(t.count);
        a92.extend(t.count);
        a93.extend(t.count);
        a94.extend(t.count);
        a95.extend(t.count);
        a96.extend(t.count);
        a97.extend(t.count);
        a98.extend(t.count);
        a99.extend(t.count);
        a100.extend(t.count);
        a101.extend(t.count);
        a102.extend(t.count);
        a103.extend(t.count);
        a104.extend(t.count);
        a105.extend(t.count);
        a106.extend(t.count);
        a107.extend(t.count);
        a108.extend(t.count);
        a109.extend(t.count);
        a110.extend(t.count);
        a111.extend(t.count);
        a112.extend(t.count);
        a113.extend(t.count);
        a114.extend(t.count);
        a115.extend(t.count);
        a116.extend(t.count);
        a117.extend(t.count);
        a118.extend(t.count);
        a119.extend(t.count);
        a120.extend(t.count);
        a121.extend(t.count);
        a122.extend(t.count);
        a123.extend(t.count);
        a124.extend(t.count);
        a125.extend(t.count);
        a126.extend(t.count);
        a127.extend(t.count);
        a128.extend(t.count);
        a129.extend(t.count);
        a130.extend(t.count);
        a131.extend(t.count);
        a132.extend(t.count);
        a133.extend(t.count);
        a134.extend(t.count);
        a135.extend(t.count);
        a136.extend(t.count);
        a137.extend(t.count);
        a138.extend(t.count);
        a139.extend(t.count);
        a140.extend(t.count);
        a141.extend(t.count);
        a142.extend(t.count);
        a143.extend(t.count);
        a144.extend(t.count);
        a145.extend(t.count);
        a146.extend(t.count);
        a147.extend(t.count);
        a148.extend(t.count);
        a149.extend(t.count);
        a150.extend(t.count);
        a151.extend(t.count);
        a152.extend(t.count);
        a153.extend(t.count);
        a154.extend(t.count);
        a155.extend(t.count);
        a156.extend(t.count);
        a157.extend(t.count);
        a158.extend(t.count);
        a159.extend(t.count);
        a160.extend(t.count);
        a161.extend(t.count);
        a162.extend(t.count);
        a163.extend(t.count);
        a164.extend(t.count);
        a165.extend(t.count);
        a166.extend(t.count);
        a167.extend(t.count);
        a168.extend(t.count);
        a169.extend(t.count);
        a170.extend(t.count);
        a171.extend(t.count);
        a172.extend(t.count);
        a173.extend(t.count);
        a174.extend(t.count);
        a175.extend(t.count);
        a176.extend(t.count);
        a177.extend(t.count);
        a178.extend(t.count);
        a179.extend(t.count);
        a180.extend(t.count);
        a181.extend(t.count);
        a182.extend(t.count);
        a183.extend(t.count);
        a184.extend(t.count);
        a185.extend(t.count);
        a186.extend(t.count);
        a187.extend(t.count);
        a188.extend(t.count);
        a189.extend(t.count);
        a190.extend(t.count);
        a191.extend(t.count);
        a192.extend(t.count);
        a193.extend(t.count);
        a194.extend(t.count);
        a195.extend(t.count);
        a196.extend(t.count);
        a197.extend(t.count);
        a198.extend(t.count);
        a199.extend(t.count);
        a200.extend(t.count);
        a201.extend(t.count);
        a202.extend(t.count);
        a203.extend(t.count);
        a204.extend(t.count);
        a205.extend(t.count);
        a206.extend(t.count);
        a207.extend(t.count);
        a208.extend(t.count);
        a209.extend(t.count);
        a210.extend(t.count);
        a211.extend(t.count);
        a212.extend(t.count);
        a213.extend(t.count);
        a214.extend(t.count);
        a215.extend(t.count);
        a216.extend(t.count);
        a217.extend(t.count);
        a218.extend(t.count);
        a219.extend(t.count);
        a220.extend(t.count);
        a221.extend(t.count);
        a222.extend(t.count);
        a223.extend(t.count);
        a224.extend(t.count);
        a225.extend(t.count);
        a226.extend(t.count);
        a227.extend(t.count);
        a228.extend(t.count);
        a229.extend(t.count);
        a230.extend(t.count);
        a231.extend(t.count);
        a232.extend(t.count);
        a233.extend(t.count);
        a234.extend(t.count);
        a235.extend(t.count);
        a236.extend(t.count);
        a237.extend(t.count);
        a238.extend(t.count);
        a239.extend(t.count);
        a240.extend(t.count);
        a241.extend(t.count);
        a242.extend(t.count);
        a243.extend(t.count);
        a244.extend(t.count);
        a245.extend(t.count);
        a246.extend(t.count);
        a247.extend(t.count);
        a248.extend(t.count);
        a249.extend(t.count);
        a250.extend(t.count);
        a251.extend(t.count);
        a252.extend(t.count);
        a253.extend(t.count);
        a254.extend(t.count);
        a255.extend(t.count);
        a256.extend(t.count);
        a257.extend(t.count);
        a258.extend(t.count);
        a259.extend(t.count);
        a260.extend(t.count);
        a261.extend(t.count);
        a262.extend(t.count);
        a263.extend(t.count);
        a264.extend(t.count);
        a265.extend(t.count);
        a266.extend(t.count);
        a267.extend(t.count);
        a268.extend(t.count);
        a269.extend(t.count);
        a270.extend(t.count);
        a271.extend(t.count);
        a272.extend(t.count);
        a273.extend(t.count);
        a274.extend(t.count);
        a275.extend(t.count);
        a276.extend(t.count);
        a277.extend(t.count);
        a278.extend(t.count);
        a279.extend(t.count);
        a280.extend(t.count);
        a281.extend(t.count);
        a282.extend(t.count);
        a283.extend(t.count);
        a284.extend(t.count);
        a285.extend(t.count);
        a286.extend(t.count);
        a287.extend(t.count);
        a288.extend(t.count);
        a289.extend(t.count);
        a290.extend(t.count);
        a291.extend(t.count);
        a292.extend(t.count);
        a293.extend(t.count);
        a294.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).import_source_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).import_list_header_id);
          a8(indx) := t(ddindx).import_successful_flag;
          a9(indx) := t(ddindx).enabled_flag;
          a10(indx) := t(ddindx).import_failure_reason;
          a11(indx) := t(ddindx).re_import_last_done_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a13(indx) := t(ddindx).dedupe_key;
          a14(indx) := t(ddindx).col1;
          a15(indx) := t(ddindx).col2;
          a16(indx) := t(ddindx).col3;
          a17(indx) := t(ddindx).col4;
          a18(indx) := t(ddindx).col5;
          a19(indx) := t(ddindx).col6;
          a20(indx) := t(ddindx).col7;
          a21(indx) := t(ddindx).col8;
          a22(indx) := t(ddindx).col9;
          a23(indx) := t(ddindx).col10;
          a24(indx) := t(ddindx).col11;
          a25(indx) := t(ddindx).col12;
          a26(indx) := t(ddindx).col13;
          a27(indx) := t(ddindx).col14;
          a28(indx) := t(ddindx).col15;
          a29(indx) := t(ddindx).col16;
          a30(indx) := t(ddindx).col17;
          a31(indx) := t(ddindx).col18;
          a32(indx) := t(ddindx).col19;
          a33(indx) := t(ddindx).col20;
          a34(indx) := t(ddindx).col21;
          a35(indx) := t(ddindx).col22;
          a36(indx) := t(ddindx).col23;
          a37(indx) := t(ddindx).col24;
          a38(indx) := t(ddindx).col25;
          a39(indx) := t(ddindx).col26;
          a40(indx) := t(ddindx).col27;
          a41(indx) := t(ddindx).col28;
          a42(indx) := t(ddindx).col29;
          a43(indx) := t(ddindx).col30;
          a44(indx) := t(ddindx).col31;
          a45(indx) := t(ddindx).col32;
          a46(indx) := t(ddindx).col33;
          a47(indx) := t(ddindx).col34;
          a48(indx) := t(ddindx).col35;
          a49(indx) := t(ddindx).col36;
          a50(indx) := t(ddindx).col37;
          a51(indx) := t(ddindx).col38;
          a52(indx) := t(ddindx).col39;
          a53(indx) := t(ddindx).col40;
          a54(indx) := t(ddindx).col41;
          a55(indx) := t(ddindx).col42;
          a56(indx) := t(ddindx).col43;
          a57(indx) := t(ddindx).col44;
          a58(indx) := t(ddindx).col45;
          a59(indx) := t(ddindx).col46;
          a60(indx) := t(ddindx).col47;
          a61(indx) := t(ddindx).col48;
          a62(indx) := t(ddindx).col49;
          a63(indx) := t(ddindx).col50;
          a64(indx) := t(ddindx).col51;
          a65(indx) := t(ddindx).col52;
          a66(indx) := t(ddindx).col53;
          a67(indx) := t(ddindx).col54;
          a68(indx) := t(ddindx).col55;
          a69(indx) := t(ddindx).col56;
          a70(indx) := t(ddindx).col57;
          a71(indx) := t(ddindx).col58;
          a72(indx) := t(ddindx).col59;
          a73(indx) := t(ddindx).col60;
          a74(indx) := t(ddindx).col61;
          a75(indx) := t(ddindx).col62;
          a76(indx) := t(ddindx).col63;
          a77(indx) := t(ddindx).col64;
          a78(indx) := t(ddindx).col65;
          a79(indx) := t(ddindx).col66;
          a80(indx) := t(ddindx).col67;
          a81(indx) := t(ddindx).col68;
          a82(indx) := t(ddindx).col69;
          a83(indx) := t(ddindx).col70;
          a84(indx) := t(ddindx).col71;
          a85(indx) := t(ddindx).col72;
          a86(indx) := t(ddindx).col73;
          a87(indx) := t(ddindx).col74;
          a88(indx) := t(ddindx).col75;
          a89(indx) := t(ddindx).col76;
          a90(indx) := t(ddindx).col77;
          a91(indx) := t(ddindx).col78;
          a92(indx) := t(ddindx).col79;
          a93(indx) := t(ddindx).col80;
          a94(indx) := t(ddindx).col81;
          a95(indx) := t(ddindx).col82;
          a96(indx) := t(ddindx).col83;
          a97(indx) := t(ddindx).col84;
          a98(indx) := t(ddindx).col85;
          a99(indx) := t(ddindx).col86;
          a100(indx) := t(ddindx).col87;
          a101(indx) := t(ddindx).col88;
          a102(indx) := t(ddindx).col89;
          a103(indx) := t(ddindx).col90;
          a104(indx) := t(ddindx).col91;
          a105(indx) := t(ddindx).col92;
          a106(indx) := t(ddindx).col93;
          a107(indx) := t(ddindx).col94;
          a108(indx) := t(ddindx).col95;
          a109(indx) := t(ddindx).col96;
          a110(indx) := t(ddindx).col97;
          a111(indx) := t(ddindx).col98;
          a112(indx) := t(ddindx).col99;
          a113(indx) := t(ddindx).col100;
          a114(indx) := t(ddindx).col101;
          a115(indx) := t(ddindx).col102;
          a116(indx) := t(ddindx).col103;
          a117(indx) := t(ddindx).col104;
          a118(indx) := t(ddindx).col105;
          a119(indx) := t(ddindx).col106;
          a120(indx) := t(ddindx).col107;
          a121(indx) := t(ddindx).col108;
          a122(indx) := t(ddindx).col109;
          a123(indx) := t(ddindx).col110;
          a124(indx) := t(ddindx).col111;
          a125(indx) := t(ddindx).col112;
          a126(indx) := t(ddindx).col113;
          a127(indx) := t(ddindx).col114;
          a128(indx) := t(ddindx).col115;
          a129(indx) := t(ddindx).col116;
          a130(indx) := t(ddindx).col117;
          a131(indx) := t(ddindx).col118;
          a132(indx) := t(ddindx).col119;
          a133(indx) := t(ddindx).col120;
          a134(indx) := t(ddindx).col121;
          a135(indx) := t(ddindx).col122;
          a136(indx) := t(ddindx).col123;
          a137(indx) := t(ddindx).col124;
          a138(indx) := t(ddindx).col125;
          a139(indx) := t(ddindx).col126;
          a140(indx) := t(ddindx).col127;
          a141(indx) := t(ddindx).col128;
          a142(indx) := t(ddindx).col129;
          a143(indx) := t(ddindx).col130;
          a144(indx) := t(ddindx).col131;
          a145(indx) := t(ddindx).col132;
          a146(indx) := t(ddindx).col133;
          a147(indx) := t(ddindx).col134;
          a148(indx) := t(ddindx).col135;
          a149(indx) := t(ddindx).col136;
          a150(indx) := t(ddindx).col137;
          a151(indx) := t(ddindx).col138;
          a152(indx) := t(ddindx).col139;
          a153(indx) := t(ddindx).col140;
          a154(indx) := t(ddindx).col141;
          a155(indx) := t(ddindx).col142;
          a156(indx) := t(ddindx).col143;
          a157(indx) := t(ddindx).col144;
          a158(indx) := t(ddindx).col145;
          a159(indx) := t(ddindx).col146;
          a160(indx) := t(ddindx).col147;
          a161(indx) := t(ddindx).col148;
          a162(indx) := t(ddindx).col149;
          a163(indx) := t(ddindx).col150;
          a164(indx) := t(ddindx).col151;
          a165(indx) := t(ddindx).col152;
          a166(indx) := t(ddindx).col153;
          a167(indx) := t(ddindx).col154;
          a168(indx) := t(ddindx).col155;
          a169(indx) := t(ddindx).col156;
          a170(indx) := t(ddindx).col157;
          a171(indx) := t(ddindx).col158;
          a172(indx) := t(ddindx).col159;
          a173(indx) := t(ddindx).col160;
          a174(indx) := t(ddindx).col161;
          a175(indx) := t(ddindx).col162;
          a176(indx) := t(ddindx).col163;
          a177(indx) := t(ddindx).col164;
          a178(indx) := t(ddindx).col165;
          a179(indx) := t(ddindx).col166;
          a180(indx) := t(ddindx).col167;
          a181(indx) := t(ddindx).col168;
          a182(indx) := t(ddindx).col169;
          a183(indx) := t(ddindx).col170;
          a184(indx) := t(ddindx).col171;
          a185(indx) := t(ddindx).col172;
          a186(indx) := t(ddindx).col173;
          a187(indx) := t(ddindx).col174;
          a188(indx) := t(ddindx).col175;
          a189(indx) := t(ddindx).col176;
          a190(indx) := t(ddindx).col177;
          a191(indx) := t(ddindx).col178;
          a192(indx) := t(ddindx).col179;
          a193(indx) := t(ddindx).col180;
          a194(indx) := t(ddindx).col181;
          a195(indx) := t(ddindx).col182;
          a196(indx) := t(ddindx).col183;
          a197(indx) := t(ddindx).col184;
          a198(indx) := t(ddindx).col185;
          a199(indx) := t(ddindx).col186;
          a200(indx) := t(ddindx).col187;
          a201(indx) := t(ddindx).col188;
          a202(indx) := t(ddindx).col189;
          a203(indx) := t(ddindx).col190;
          a204(indx) := t(ddindx).col191;
          a205(indx) := t(ddindx).col192;
          a206(indx) := t(ddindx).col193;
          a207(indx) := t(ddindx).col194;
          a208(indx) := t(ddindx).col195;
          a209(indx) := t(ddindx).col196;
          a210(indx) := t(ddindx).col197;
          a211(indx) := t(ddindx).col198;
          a212(indx) := t(ddindx).col199;
          a213(indx) := t(ddindx).col200;
          a214(indx) := t(ddindx).col201;
          a215(indx) := t(ddindx).col202;
          a216(indx) := t(ddindx).col203;
          a217(indx) := t(ddindx).col204;
          a218(indx) := t(ddindx).col205;
          a219(indx) := t(ddindx).col206;
          a220(indx) := t(ddindx).col207;
          a221(indx) := t(ddindx).col208;
          a222(indx) := t(ddindx).col209;
          a223(indx) := t(ddindx).col210;
          a224(indx) := t(ddindx).col211;
          a225(indx) := t(ddindx).col212;
          a226(indx) := t(ddindx).col213;
          a227(indx) := t(ddindx).col214;
          a228(indx) := t(ddindx).col215;
          a229(indx) := t(ddindx).col216;
          a230(indx) := t(ddindx).col217;
          a231(indx) := t(ddindx).col218;
          a232(indx) := t(ddindx).col219;
          a233(indx) := t(ddindx).col220;
          a234(indx) := t(ddindx).col221;
          a235(indx) := t(ddindx).col222;
          a236(indx) := t(ddindx).col223;
          a237(indx) := t(ddindx).col224;
          a238(indx) := t(ddindx).col225;
          a239(indx) := t(ddindx).col226;
          a240(indx) := t(ddindx).col227;
          a241(indx) := t(ddindx).col228;
          a242(indx) := t(ddindx).col229;
          a243(indx) := t(ddindx).col230;
          a244(indx) := t(ddindx).col231;
          a245(indx) := t(ddindx).col232;
          a246(indx) := t(ddindx).col233;
          a247(indx) := t(ddindx).col234;
          a248(indx) := t(ddindx).col235;
          a249(indx) := t(ddindx).col236;
          a250(indx) := t(ddindx).col237;
          a251(indx) := t(ddindx).col238;
          a252(indx) := t(ddindx).col239;
          a253(indx) := t(ddindx).col240;
          a254(indx) := t(ddindx).col241;
          a255(indx) := t(ddindx).col242;
          a256(indx) := t(ddindx).col243;
          a257(indx) := t(ddindx).col244;
          a258(indx) := t(ddindx).col245;
          a259(indx) := t(ddindx).col246;
          a260(indx) := t(ddindx).col247;
          a261(indx) := t(ddindx).col248;
          a262(indx) := t(ddindx).col249;
          a263(indx) := t(ddindx).col250;
          a264(indx) := t(ddindx).duplicate_flag;
          a265(indx) := rosetta_g_miss_num_map(t(ddindx).current_usage);
          a266(indx) := t(ddindx).load_status;
          a267(indx) := t(ddindx).notes;
          a268(indx) := t(ddindx).sales_agent_email_address;
          a269(indx) := t(ddindx).vehicle_response_code;
          a270(indx) := t(ddindx).custom_column1;
          a271(indx) := t(ddindx).custom_column2;
          a272(indx) := t(ddindx).custom_column3;
          a273(indx) := t(ddindx).custom_column4;
          a274(indx) := t(ddindx).custom_column5;
          a275(indx) := t(ddindx).custom_column6;
          a276(indx) := t(ddindx).custom_column7;
          a277(indx) := t(ddindx).custom_column8;
          a278(indx) := t(ddindx).custom_column9;
          a279(indx) := t(ddindx).custom_column10;
          a280(indx) := t(ddindx).custom_column11;
          a281(indx) := t(ddindx).custom_column12;
          a282(indx) := t(ddindx).custom_column13;
          a283(indx) := t(ddindx).custom_column14;
          a284(indx) := t(ddindx).custom_column15;
          a285(indx) := t(ddindx).custom_column16;
          a286(indx) := t(ddindx).custom_column17;
          a287(indx) := t(ddindx).custom_column18;
          a288(indx) := t(ddindx).custom_column19;
          a289(indx) := t(ddindx).custom_column20;
          a290(indx) := t(ddindx).custom_column21;
          a291(indx) := t(ddindx).custom_column22;
          a292(indx) := t(ddindx).custom_column23;
          a293(indx) := t(ddindx).custom_column24;
          a294(indx) := t(ddindx).custom_column25;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_import_source_line_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  NUMBER := 0-1962.0724
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_is_line_rec ams_is_line_pvt.is_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_is_line_rec.import_source_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_is_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_is_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_is_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_is_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_is_line_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_is_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_is_line_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_is_line_rec.import_successful_flag := p7_a8;
    ddp_is_line_rec.enabled_flag := p7_a9;
    ddp_is_line_rec.import_failure_reason := p7_a10;
    ddp_is_line_rec.re_import_last_done_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_is_line_rec.party_id := rosetta_g_miss_num_map(p7_a12);
    ddp_is_line_rec.dedupe_key := p7_a13;
    ddp_is_line_rec.col1 := p7_a14;
    ddp_is_line_rec.col2 := p7_a15;
    ddp_is_line_rec.col3 := p7_a16;
    ddp_is_line_rec.col4 := p7_a17;
    ddp_is_line_rec.col5 := p7_a18;
    ddp_is_line_rec.col6 := p7_a19;
    ddp_is_line_rec.col7 := p7_a20;
    ddp_is_line_rec.col8 := p7_a21;
    ddp_is_line_rec.col9 := p7_a22;
    ddp_is_line_rec.col10 := p7_a23;
    ddp_is_line_rec.col11 := p7_a24;
    ddp_is_line_rec.col12 := p7_a25;
    ddp_is_line_rec.col13 := p7_a26;
    ddp_is_line_rec.col14 := p7_a27;
    ddp_is_line_rec.col15 := p7_a28;
    ddp_is_line_rec.col16 := p7_a29;
    ddp_is_line_rec.col17 := p7_a30;
    ddp_is_line_rec.col18 := p7_a31;
    ddp_is_line_rec.col19 := p7_a32;
    ddp_is_line_rec.col20 := p7_a33;
    ddp_is_line_rec.col21 := p7_a34;
    ddp_is_line_rec.col22 := p7_a35;
    ddp_is_line_rec.col23 := p7_a36;
    ddp_is_line_rec.col24 := p7_a37;
    ddp_is_line_rec.col25 := p7_a38;
    ddp_is_line_rec.col26 := p7_a39;
    ddp_is_line_rec.col27 := p7_a40;
    ddp_is_line_rec.col28 := p7_a41;
    ddp_is_line_rec.col29 := p7_a42;
    ddp_is_line_rec.col30 := p7_a43;
    ddp_is_line_rec.col31 := p7_a44;
    ddp_is_line_rec.col32 := p7_a45;
    ddp_is_line_rec.col33 := p7_a46;
    ddp_is_line_rec.col34 := p7_a47;
    ddp_is_line_rec.col35 := p7_a48;
    ddp_is_line_rec.col36 := p7_a49;
    ddp_is_line_rec.col37 := p7_a50;
    ddp_is_line_rec.col38 := p7_a51;
    ddp_is_line_rec.col39 := p7_a52;
    ddp_is_line_rec.col40 := p7_a53;
    ddp_is_line_rec.col41 := p7_a54;
    ddp_is_line_rec.col42 := p7_a55;
    ddp_is_line_rec.col43 := p7_a56;
    ddp_is_line_rec.col44 := p7_a57;
    ddp_is_line_rec.col45 := p7_a58;
    ddp_is_line_rec.col46 := p7_a59;
    ddp_is_line_rec.col47 := p7_a60;
    ddp_is_line_rec.col48 := p7_a61;
    ddp_is_line_rec.col49 := p7_a62;
    ddp_is_line_rec.col50 := p7_a63;
    ddp_is_line_rec.col51 := p7_a64;
    ddp_is_line_rec.col52 := p7_a65;
    ddp_is_line_rec.col53 := p7_a66;
    ddp_is_line_rec.col54 := p7_a67;
    ddp_is_line_rec.col55 := p7_a68;
    ddp_is_line_rec.col56 := p7_a69;
    ddp_is_line_rec.col57 := p7_a70;
    ddp_is_line_rec.col58 := p7_a71;
    ddp_is_line_rec.col59 := p7_a72;
    ddp_is_line_rec.col60 := p7_a73;
    ddp_is_line_rec.col61 := p7_a74;
    ddp_is_line_rec.col62 := p7_a75;
    ddp_is_line_rec.col63 := p7_a76;
    ddp_is_line_rec.col64 := p7_a77;
    ddp_is_line_rec.col65 := p7_a78;
    ddp_is_line_rec.col66 := p7_a79;
    ddp_is_line_rec.col67 := p7_a80;
    ddp_is_line_rec.col68 := p7_a81;
    ddp_is_line_rec.col69 := p7_a82;
    ddp_is_line_rec.col70 := p7_a83;
    ddp_is_line_rec.col71 := p7_a84;
    ddp_is_line_rec.col72 := p7_a85;
    ddp_is_line_rec.col73 := p7_a86;
    ddp_is_line_rec.col74 := p7_a87;
    ddp_is_line_rec.col75 := p7_a88;
    ddp_is_line_rec.col76 := p7_a89;
    ddp_is_line_rec.col77 := p7_a90;
    ddp_is_line_rec.col78 := p7_a91;
    ddp_is_line_rec.col79 := p7_a92;
    ddp_is_line_rec.col80 := p7_a93;
    ddp_is_line_rec.col81 := p7_a94;
    ddp_is_line_rec.col82 := p7_a95;
    ddp_is_line_rec.col83 := p7_a96;
    ddp_is_line_rec.col84 := p7_a97;
    ddp_is_line_rec.col85 := p7_a98;
    ddp_is_line_rec.col86 := p7_a99;
    ddp_is_line_rec.col87 := p7_a100;
    ddp_is_line_rec.col88 := p7_a101;
    ddp_is_line_rec.col89 := p7_a102;
    ddp_is_line_rec.col90 := p7_a103;
    ddp_is_line_rec.col91 := p7_a104;
    ddp_is_line_rec.col92 := p7_a105;
    ddp_is_line_rec.col93 := p7_a106;
    ddp_is_line_rec.col94 := p7_a107;
    ddp_is_line_rec.col95 := p7_a108;
    ddp_is_line_rec.col96 := p7_a109;
    ddp_is_line_rec.col97 := p7_a110;
    ddp_is_line_rec.col98 := p7_a111;
    ddp_is_line_rec.col99 := p7_a112;
    ddp_is_line_rec.col100 := p7_a113;
    ddp_is_line_rec.col101 := p7_a114;
    ddp_is_line_rec.col102 := p7_a115;
    ddp_is_line_rec.col103 := p7_a116;
    ddp_is_line_rec.col104 := p7_a117;
    ddp_is_line_rec.col105 := p7_a118;
    ddp_is_line_rec.col106 := p7_a119;
    ddp_is_line_rec.col107 := p7_a120;
    ddp_is_line_rec.col108 := p7_a121;
    ddp_is_line_rec.col109 := p7_a122;
    ddp_is_line_rec.col110 := p7_a123;
    ddp_is_line_rec.col111 := p7_a124;
    ddp_is_line_rec.col112 := p7_a125;
    ddp_is_line_rec.col113 := p7_a126;
    ddp_is_line_rec.col114 := p7_a127;
    ddp_is_line_rec.col115 := p7_a128;
    ddp_is_line_rec.col116 := p7_a129;
    ddp_is_line_rec.col117 := p7_a130;
    ddp_is_line_rec.col118 := p7_a131;
    ddp_is_line_rec.col119 := p7_a132;
    ddp_is_line_rec.col120 := p7_a133;
    ddp_is_line_rec.col121 := p7_a134;
    ddp_is_line_rec.col122 := p7_a135;
    ddp_is_line_rec.col123 := p7_a136;
    ddp_is_line_rec.col124 := p7_a137;
    ddp_is_line_rec.col125 := p7_a138;
    ddp_is_line_rec.col126 := p7_a139;
    ddp_is_line_rec.col127 := p7_a140;
    ddp_is_line_rec.col128 := p7_a141;
    ddp_is_line_rec.col129 := p7_a142;
    ddp_is_line_rec.col130 := p7_a143;
    ddp_is_line_rec.col131 := p7_a144;
    ddp_is_line_rec.col132 := p7_a145;
    ddp_is_line_rec.col133 := p7_a146;
    ddp_is_line_rec.col134 := p7_a147;
    ddp_is_line_rec.col135 := p7_a148;
    ddp_is_line_rec.col136 := p7_a149;
    ddp_is_line_rec.col137 := p7_a150;
    ddp_is_line_rec.col138 := p7_a151;
    ddp_is_line_rec.col139 := p7_a152;
    ddp_is_line_rec.col140 := p7_a153;
    ddp_is_line_rec.col141 := p7_a154;
    ddp_is_line_rec.col142 := p7_a155;
    ddp_is_line_rec.col143 := p7_a156;
    ddp_is_line_rec.col144 := p7_a157;
    ddp_is_line_rec.col145 := p7_a158;
    ddp_is_line_rec.col146 := p7_a159;
    ddp_is_line_rec.col147 := p7_a160;
    ddp_is_line_rec.col148 := p7_a161;
    ddp_is_line_rec.col149 := p7_a162;
    ddp_is_line_rec.col150 := p7_a163;
    ddp_is_line_rec.col151 := p7_a164;
    ddp_is_line_rec.col152 := p7_a165;
    ddp_is_line_rec.col153 := p7_a166;
    ddp_is_line_rec.col154 := p7_a167;
    ddp_is_line_rec.col155 := p7_a168;
    ddp_is_line_rec.col156 := p7_a169;
    ddp_is_line_rec.col157 := p7_a170;
    ddp_is_line_rec.col158 := p7_a171;
    ddp_is_line_rec.col159 := p7_a172;
    ddp_is_line_rec.col160 := p7_a173;
    ddp_is_line_rec.col161 := p7_a174;
    ddp_is_line_rec.col162 := p7_a175;
    ddp_is_line_rec.col163 := p7_a176;
    ddp_is_line_rec.col164 := p7_a177;
    ddp_is_line_rec.col165 := p7_a178;
    ddp_is_line_rec.col166 := p7_a179;
    ddp_is_line_rec.col167 := p7_a180;
    ddp_is_line_rec.col168 := p7_a181;
    ddp_is_line_rec.col169 := p7_a182;
    ddp_is_line_rec.col170 := p7_a183;
    ddp_is_line_rec.col171 := p7_a184;
    ddp_is_line_rec.col172 := p7_a185;
    ddp_is_line_rec.col173 := p7_a186;
    ddp_is_line_rec.col174 := p7_a187;
    ddp_is_line_rec.col175 := p7_a188;
    ddp_is_line_rec.col176 := p7_a189;
    ddp_is_line_rec.col177 := p7_a190;
    ddp_is_line_rec.col178 := p7_a191;
    ddp_is_line_rec.col179 := p7_a192;
    ddp_is_line_rec.col180 := p7_a193;
    ddp_is_line_rec.col181 := p7_a194;
    ddp_is_line_rec.col182 := p7_a195;
    ddp_is_line_rec.col183 := p7_a196;
    ddp_is_line_rec.col184 := p7_a197;
    ddp_is_line_rec.col185 := p7_a198;
    ddp_is_line_rec.col186 := p7_a199;
    ddp_is_line_rec.col187 := p7_a200;
    ddp_is_line_rec.col188 := p7_a201;
    ddp_is_line_rec.col189 := p7_a202;
    ddp_is_line_rec.col190 := p7_a203;
    ddp_is_line_rec.col191 := p7_a204;
    ddp_is_line_rec.col192 := p7_a205;
    ddp_is_line_rec.col193 := p7_a206;
    ddp_is_line_rec.col194 := p7_a207;
    ddp_is_line_rec.col195 := p7_a208;
    ddp_is_line_rec.col196 := p7_a209;
    ddp_is_line_rec.col197 := p7_a210;
    ddp_is_line_rec.col198 := p7_a211;
    ddp_is_line_rec.col199 := p7_a212;
    ddp_is_line_rec.col200 := p7_a213;
    ddp_is_line_rec.col201 := p7_a214;
    ddp_is_line_rec.col202 := p7_a215;
    ddp_is_line_rec.col203 := p7_a216;
    ddp_is_line_rec.col204 := p7_a217;
    ddp_is_line_rec.col205 := p7_a218;
    ddp_is_line_rec.col206 := p7_a219;
    ddp_is_line_rec.col207 := p7_a220;
    ddp_is_line_rec.col208 := p7_a221;
    ddp_is_line_rec.col209 := p7_a222;
    ddp_is_line_rec.col210 := p7_a223;
    ddp_is_line_rec.col211 := p7_a224;
    ddp_is_line_rec.col212 := p7_a225;
    ddp_is_line_rec.col213 := p7_a226;
    ddp_is_line_rec.col214 := p7_a227;
    ddp_is_line_rec.col215 := p7_a228;
    ddp_is_line_rec.col216 := p7_a229;
    ddp_is_line_rec.col217 := p7_a230;
    ddp_is_line_rec.col218 := p7_a231;
    ddp_is_line_rec.col219 := p7_a232;
    ddp_is_line_rec.col220 := p7_a233;
    ddp_is_line_rec.col221 := p7_a234;
    ddp_is_line_rec.col222 := p7_a235;
    ddp_is_line_rec.col223 := p7_a236;
    ddp_is_line_rec.col224 := p7_a237;
    ddp_is_line_rec.col225 := p7_a238;
    ddp_is_line_rec.col226 := p7_a239;
    ddp_is_line_rec.col227 := p7_a240;
    ddp_is_line_rec.col228 := p7_a241;
    ddp_is_line_rec.col229 := p7_a242;
    ddp_is_line_rec.col230 := p7_a243;
    ddp_is_line_rec.col231 := p7_a244;
    ddp_is_line_rec.col232 := p7_a245;
    ddp_is_line_rec.col233 := p7_a246;
    ddp_is_line_rec.col234 := p7_a247;
    ddp_is_line_rec.col235 := p7_a248;
    ddp_is_line_rec.col236 := p7_a249;
    ddp_is_line_rec.col237 := p7_a250;
    ddp_is_line_rec.col238 := p7_a251;
    ddp_is_line_rec.col239 := p7_a252;
    ddp_is_line_rec.col240 := p7_a253;
    ddp_is_line_rec.col241 := p7_a254;
    ddp_is_line_rec.col242 := p7_a255;
    ddp_is_line_rec.col243 := p7_a256;
    ddp_is_line_rec.col244 := p7_a257;
    ddp_is_line_rec.col245 := p7_a258;
    ddp_is_line_rec.col246 := p7_a259;
    ddp_is_line_rec.col247 := p7_a260;
    ddp_is_line_rec.col248 := p7_a261;
    ddp_is_line_rec.col249 := p7_a262;
    ddp_is_line_rec.col250 := p7_a263;
    ddp_is_line_rec.duplicate_flag := p7_a264;
    ddp_is_line_rec.current_usage := rosetta_g_miss_num_map(p7_a265);
    ddp_is_line_rec.load_status := p7_a266;
    ddp_is_line_rec.notes := p7_a267;
    ddp_is_line_rec.sales_agent_email_address := p7_a268;
    ddp_is_line_rec.vehicle_response_code := p7_a269;
    ddp_is_line_rec.custom_column1 := p7_a270;
    ddp_is_line_rec.custom_column2 := p7_a271;
    ddp_is_line_rec.custom_column3 := p7_a272;
    ddp_is_line_rec.custom_column4 := p7_a273;
    ddp_is_line_rec.custom_column5 := p7_a274;
    ddp_is_line_rec.custom_column6 := p7_a275;
    ddp_is_line_rec.custom_column7 := p7_a276;
    ddp_is_line_rec.custom_column8 := p7_a277;
    ddp_is_line_rec.custom_column9 := p7_a278;
    ddp_is_line_rec.custom_column10 := p7_a279;
    ddp_is_line_rec.custom_column11 := p7_a280;
    ddp_is_line_rec.custom_column12 := p7_a281;
    ddp_is_line_rec.custom_column13 := p7_a282;
    ddp_is_line_rec.custom_column14 := p7_a283;
    ddp_is_line_rec.custom_column15 := p7_a284;
    ddp_is_line_rec.custom_column16 := p7_a285;
    ddp_is_line_rec.custom_column17 := p7_a286;
    ddp_is_line_rec.custom_column18 := p7_a287;
    ddp_is_line_rec.custom_column19 := p7_a288;
    ddp_is_line_rec.custom_column20 := p7_a289;
    ddp_is_line_rec.custom_column21 := p7_a290;
    ddp_is_line_rec.custom_column22 := p7_a291;
    ddp_is_line_rec.custom_column23 := p7_a292;
    ddp_is_line_rec.custom_column24 := p7_a293;
    ddp_is_line_rec.custom_column25 := p7_a294;


    -- here's the delegated call to the old PL/SQL routine
    ams_is_line_pvt.create_is_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_is_line_rec,
      x_import_source_line_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_object_version_number out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  DATE := fnd_api.g_miss_date
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  VARCHAR2 := fnd_api.g_miss_char
    , p7_a29  VARCHAR2 := fnd_api.g_miss_char
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  VARCHAR2 := fnd_api.g_miss_char
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  VARCHAR2 := fnd_api.g_miss_char
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  VARCHAR2 := fnd_api.g_miss_char
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  VARCHAR2 := fnd_api.g_miss_char
    , p7_a85  VARCHAR2 := fnd_api.g_miss_char
    , p7_a86  VARCHAR2 := fnd_api.g_miss_char
    , p7_a87  VARCHAR2 := fnd_api.g_miss_char
    , p7_a88  VARCHAR2 := fnd_api.g_miss_char
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  VARCHAR2 := fnd_api.g_miss_char
    , p7_a95  VARCHAR2 := fnd_api.g_miss_char
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  VARCHAR2 := fnd_api.g_miss_char
    , p7_a99  VARCHAR2 := fnd_api.g_miss_char
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  VARCHAR2 := fnd_api.g_miss_char
    , p7_a102  VARCHAR2 := fnd_api.g_miss_char
    , p7_a103  VARCHAR2 := fnd_api.g_miss_char
    , p7_a104  VARCHAR2 := fnd_api.g_miss_char
    , p7_a105  VARCHAR2 := fnd_api.g_miss_char
    , p7_a106  VARCHAR2 := fnd_api.g_miss_char
    , p7_a107  VARCHAR2 := fnd_api.g_miss_char
    , p7_a108  VARCHAR2 := fnd_api.g_miss_char
    , p7_a109  VARCHAR2 := fnd_api.g_miss_char
    , p7_a110  VARCHAR2 := fnd_api.g_miss_char
    , p7_a111  VARCHAR2 := fnd_api.g_miss_char
    , p7_a112  VARCHAR2 := fnd_api.g_miss_char
    , p7_a113  VARCHAR2 := fnd_api.g_miss_char
    , p7_a114  VARCHAR2 := fnd_api.g_miss_char
    , p7_a115  VARCHAR2 := fnd_api.g_miss_char
    , p7_a116  VARCHAR2 := fnd_api.g_miss_char
    , p7_a117  VARCHAR2 := fnd_api.g_miss_char
    , p7_a118  VARCHAR2 := fnd_api.g_miss_char
    , p7_a119  VARCHAR2 := fnd_api.g_miss_char
    , p7_a120  VARCHAR2 := fnd_api.g_miss_char
    , p7_a121  VARCHAR2 := fnd_api.g_miss_char
    , p7_a122  VARCHAR2 := fnd_api.g_miss_char
    , p7_a123  VARCHAR2 := fnd_api.g_miss_char
    , p7_a124  VARCHAR2 := fnd_api.g_miss_char
    , p7_a125  VARCHAR2 := fnd_api.g_miss_char
    , p7_a126  VARCHAR2 := fnd_api.g_miss_char
    , p7_a127  VARCHAR2 := fnd_api.g_miss_char
    , p7_a128  VARCHAR2 := fnd_api.g_miss_char
    , p7_a129  VARCHAR2 := fnd_api.g_miss_char
    , p7_a130  VARCHAR2 := fnd_api.g_miss_char
    , p7_a131  VARCHAR2 := fnd_api.g_miss_char
    , p7_a132  VARCHAR2 := fnd_api.g_miss_char
    , p7_a133  VARCHAR2 := fnd_api.g_miss_char
    , p7_a134  VARCHAR2 := fnd_api.g_miss_char
    , p7_a135  VARCHAR2 := fnd_api.g_miss_char
    , p7_a136  VARCHAR2 := fnd_api.g_miss_char
    , p7_a137  VARCHAR2 := fnd_api.g_miss_char
    , p7_a138  VARCHAR2 := fnd_api.g_miss_char
    , p7_a139  VARCHAR2 := fnd_api.g_miss_char
    , p7_a140  VARCHAR2 := fnd_api.g_miss_char
    , p7_a141  VARCHAR2 := fnd_api.g_miss_char
    , p7_a142  VARCHAR2 := fnd_api.g_miss_char
    , p7_a143  VARCHAR2 := fnd_api.g_miss_char
    , p7_a144  VARCHAR2 := fnd_api.g_miss_char
    , p7_a145  VARCHAR2 := fnd_api.g_miss_char
    , p7_a146  VARCHAR2 := fnd_api.g_miss_char
    , p7_a147  VARCHAR2 := fnd_api.g_miss_char
    , p7_a148  VARCHAR2 := fnd_api.g_miss_char
    , p7_a149  VARCHAR2 := fnd_api.g_miss_char
    , p7_a150  VARCHAR2 := fnd_api.g_miss_char
    , p7_a151  VARCHAR2 := fnd_api.g_miss_char
    , p7_a152  VARCHAR2 := fnd_api.g_miss_char
    , p7_a153  VARCHAR2 := fnd_api.g_miss_char
    , p7_a154  VARCHAR2 := fnd_api.g_miss_char
    , p7_a155  VARCHAR2 := fnd_api.g_miss_char
    , p7_a156  VARCHAR2 := fnd_api.g_miss_char
    , p7_a157  VARCHAR2 := fnd_api.g_miss_char
    , p7_a158  VARCHAR2 := fnd_api.g_miss_char
    , p7_a159  VARCHAR2 := fnd_api.g_miss_char
    , p7_a160  VARCHAR2 := fnd_api.g_miss_char
    , p7_a161  VARCHAR2 := fnd_api.g_miss_char
    , p7_a162  VARCHAR2 := fnd_api.g_miss_char
    , p7_a163  VARCHAR2 := fnd_api.g_miss_char
    , p7_a164  VARCHAR2 := fnd_api.g_miss_char
    , p7_a165  VARCHAR2 := fnd_api.g_miss_char
    , p7_a166  VARCHAR2 := fnd_api.g_miss_char
    , p7_a167  VARCHAR2 := fnd_api.g_miss_char
    , p7_a168  VARCHAR2 := fnd_api.g_miss_char
    , p7_a169  VARCHAR2 := fnd_api.g_miss_char
    , p7_a170  VARCHAR2 := fnd_api.g_miss_char
    , p7_a171  VARCHAR2 := fnd_api.g_miss_char
    , p7_a172  VARCHAR2 := fnd_api.g_miss_char
    , p7_a173  VARCHAR2 := fnd_api.g_miss_char
    , p7_a174  VARCHAR2 := fnd_api.g_miss_char
    , p7_a175  VARCHAR2 := fnd_api.g_miss_char
    , p7_a176  VARCHAR2 := fnd_api.g_miss_char
    , p7_a177  VARCHAR2 := fnd_api.g_miss_char
    , p7_a178  VARCHAR2 := fnd_api.g_miss_char
    , p7_a179  VARCHAR2 := fnd_api.g_miss_char
    , p7_a180  VARCHAR2 := fnd_api.g_miss_char
    , p7_a181  VARCHAR2 := fnd_api.g_miss_char
    , p7_a182  VARCHAR2 := fnd_api.g_miss_char
    , p7_a183  VARCHAR2 := fnd_api.g_miss_char
    , p7_a184  VARCHAR2 := fnd_api.g_miss_char
    , p7_a185  VARCHAR2 := fnd_api.g_miss_char
    , p7_a186  VARCHAR2 := fnd_api.g_miss_char
    , p7_a187  VARCHAR2 := fnd_api.g_miss_char
    , p7_a188  VARCHAR2 := fnd_api.g_miss_char
    , p7_a189  VARCHAR2 := fnd_api.g_miss_char
    , p7_a190  VARCHAR2 := fnd_api.g_miss_char
    , p7_a191  VARCHAR2 := fnd_api.g_miss_char
    , p7_a192  VARCHAR2 := fnd_api.g_miss_char
    , p7_a193  VARCHAR2 := fnd_api.g_miss_char
    , p7_a194  VARCHAR2 := fnd_api.g_miss_char
    , p7_a195  VARCHAR2 := fnd_api.g_miss_char
    , p7_a196  VARCHAR2 := fnd_api.g_miss_char
    , p7_a197  VARCHAR2 := fnd_api.g_miss_char
    , p7_a198  VARCHAR2 := fnd_api.g_miss_char
    , p7_a199  VARCHAR2 := fnd_api.g_miss_char
    , p7_a200  VARCHAR2 := fnd_api.g_miss_char
    , p7_a201  VARCHAR2 := fnd_api.g_miss_char
    , p7_a202  VARCHAR2 := fnd_api.g_miss_char
    , p7_a203  VARCHAR2 := fnd_api.g_miss_char
    , p7_a204  VARCHAR2 := fnd_api.g_miss_char
    , p7_a205  VARCHAR2 := fnd_api.g_miss_char
    , p7_a206  VARCHAR2 := fnd_api.g_miss_char
    , p7_a207  VARCHAR2 := fnd_api.g_miss_char
    , p7_a208  VARCHAR2 := fnd_api.g_miss_char
    , p7_a209  VARCHAR2 := fnd_api.g_miss_char
    , p7_a210  VARCHAR2 := fnd_api.g_miss_char
    , p7_a211  VARCHAR2 := fnd_api.g_miss_char
    , p7_a212  VARCHAR2 := fnd_api.g_miss_char
    , p7_a213  VARCHAR2 := fnd_api.g_miss_char
    , p7_a214  VARCHAR2 := fnd_api.g_miss_char
    , p7_a215  VARCHAR2 := fnd_api.g_miss_char
    , p7_a216  VARCHAR2 := fnd_api.g_miss_char
    , p7_a217  VARCHAR2 := fnd_api.g_miss_char
    , p7_a218  VARCHAR2 := fnd_api.g_miss_char
    , p7_a219  VARCHAR2 := fnd_api.g_miss_char
    , p7_a220  VARCHAR2 := fnd_api.g_miss_char
    , p7_a221  VARCHAR2 := fnd_api.g_miss_char
    , p7_a222  VARCHAR2 := fnd_api.g_miss_char
    , p7_a223  VARCHAR2 := fnd_api.g_miss_char
    , p7_a224  VARCHAR2 := fnd_api.g_miss_char
    , p7_a225  VARCHAR2 := fnd_api.g_miss_char
    , p7_a226  VARCHAR2 := fnd_api.g_miss_char
    , p7_a227  VARCHAR2 := fnd_api.g_miss_char
    , p7_a228  VARCHAR2 := fnd_api.g_miss_char
    , p7_a229  VARCHAR2 := fnd_api.g_miss_char
    , p7_a230  VARCHAR2 := fnd_api.g_miss_char
    , p7_a231  VARCHAR2 := fnd_api.g_miss_char
    , p7_a232  VARCHAR2 := fnd_api.g_miss_char
    , p7_a233  VARCHAR2 := fnd_api.g_miss_char
    , p7_a234  VARCHAR2 := fnd_api.g_miss_char
    , p7_a235  VARCHAR2 := fnd_api.g_miss_char
    , p7_a236  VARCHAR2 := fnd_api.g_miss_char
    , p7_a237  VARCHAR2 := fnd_api.g_miss_char
    , p7_a238  VARCHAR2 := fnd_api.g_miss_char
    , p7_a239  VARCHAR2 := fnd_api.g_miss_char
    , p7_a240  VARCHAR2 := fnd_api.g_miss_char
    , p7_a241  VARCHAR2 := fnd_api.g_miss_char
    , p7_a242  VARCHAR2 := fnd_api.g_miss_char
    , p7_a243  VARCHAR2 := fnd_api.g_miss_char
    , p7_a244  VARCHAR2 := fnd_api.g_miss_char
    , p7_a245  VARCHAR2 := fnd_api.g_miss_char
    , p7_a246  VARCHAR2 := fnd_api.g_miss_char
    , p7_a247  VARCHAR2 := fnd_api.g_miss_char
    , p7_a248  VARCHAR2 := fnd_api.g_miss_char
    , p7_a249  VARCHAR2 := fnd_api.g_miss_char
    , p7_a250  VARCHAR2 := fnd_api.g_miss_char
    , p7_a251  VARCHAR2 := fnd_api.g_miss_char
    , p7_a252  VARCHAR2 := fnd_api.g_miss_char
    , p7_a253  VARCHAR2 := fnd_api.g_miss_char
    , p7_a254  VARCHAR2 := fnd_api.g_miss_char
    , p7_a255  VARCHAR2 := fnd_api.g_miss_char
    , p7_a256  VARCHAR2 := fnd_api.g_miss_char
    , p7_a257  VARCHAR2 := fnd_api.g_miss_char
    , p7_a258  VARCHAR2 := fnd_api.g_miss_char
    , p7_a259  VARCHAR2 := fnd_api.g_miss_char
    , p7_a260  VARCHAR2 := fnd_api.g_miss_char
    , p7_a261  VARCHAR2 := fnd_api.g_miss_char
    , p7_a262  VARCHAR2 := fnd_api.g_miss_char
    , p7_a263  VARCHAR2 := fnd_api.g_miss_char
    , p7_a264  VARCHAR2 := fnd_api.g_miss_char
    , p7_a265  NUMBER := 0-1962.0724
    , p7_a266  VARCHAR2 := fnd_api.g_miss_char
    , p7_a267  VARCHAR2 := fnd_api.g_miss_char
    , p7_a268  VARCHAR2 := fnd_api.g_miss_char
    , p7_a269  VARCHAR2 := fnd_api.g_miss_char
    , p7_a270  VARCHAR2 := fnd_api.g_miss_char
    , p7_a271  VARCHAR2 := fnd_api.g_miss_char
    , p7_a272  VARCHAR2 := fnd_api.g_miss_char
    , p7_a273  VARCHAR2 := fnd_api.g_miss_char
    , p7_a274  VARCHAR2 := fnd_api.g_miss_char
    , p7_a275  VARCHAR2 := fnd_api.g_miss_char
    , p7_a276  VARCHAR2 := fnd_api.g_miss_char
    , p7_a277  VARCHAR2 := fnd_api.g_miss_char
    , p7_a278  VARCHAR2 := fnd_api.g_miss_char
    , p7_a279  VARCHAR2 := fnd_api.g_miss_char
    , p7_a280  VARCHAR2 := fnd_api.g_miss_char
    , p7_a281  VARCHAR2 := fnd_api.g_miss_char
    , p7_a282  VARCHAR2 := fnd_api.g_miss_char
    , p7_a283  VARCHAR2 := fnd_api.g_miss_char
    , p7_a284  VARCHAR2 := fnd_api.g_miss_char
    , p7_a285  VARCHAR2 := fnd_api.g_miss_char
    , p7_a286  VARCHAR2 := fnd_api.g_miss_char
    , p7_a287  VARCHAR2 := fnd_api.g_miss_char
    , p7_a288  VARCHAR2 := fnd_api.g_miss_char
    , p7_a289  VARCHAR2 := fnd_api.g_miss_char
    , p7_a290  VARCHAR2 := fnd_api.g_miss_char
    , p7_a291  VARCHAR2 := fnd_api.g_miss_char
    , p7_a292  VARCHAR2 := fnd_api.g_miss_char
    , p7_a293  VARCHAR2 := fnd_api.g_miss_char
    , p7_a294  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_is_line_rec ams_is_line_pvt.is_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_is_line_rec.import_source_line_id := rosetta_g_miss_num_map(p7_a0);
    ddp_is_line_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_is_line_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_is_line_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_is_line_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_is_line_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_is_line_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_is_line_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_is_line_rec.import_successful_flag := p7_a8;
    ddp_is_line_rec.enabled_flag := p7_a9;
    ddp_is_line_rec.import_failure_reason := p7_a10;
    ddp_is_line_rec.re_import_last_done_date := rosetta_g_miss_date_in_map(p7_a11);
    ddp_is_line_rec.party_id := rosetta_g_miss_num_map(p7_a12);
    ddp_is_line_rec.dedupe_key := p7_a13;
    ddp_is_line_rec.col1 := p7_a14;
    ddp_is_line_rec.col2 := p7_a15;
    ddp_is_line_rec.col3 := p7_a16;
    ddp_is_line_rec.col4 := p7_a17;
    ddp_is_line_rec.col5 := p7_a18;
    ddp_is_line_rec.col6 := p7_a19;
    ddp_is_line_rec.col7 := p7_a20;
    ddp_is_line_rec.col8 := p7_a21;
    ddp_is_line_rec.col9 := p7_a22;
    ddp_is_line_rec.col10 := p7_a23;
    ddp_is_line_rec.col11 := p7_a24;
    ddp_is_line_rec.col12 := p7_a25;
    ddp_is_line_rec.col13 := p7_a26;
    ddp_is_line_rec.col14 := p7_a27;
    ddp_is_line_rec.col15 := p7_a28;
    ddp_is_line_rec.col16 := p7_a29;
    ddp_is_line_rec.col17 := p7_a30;
    ddp_is_line_rec.col18 := p7_a31;
    ddp_is_line_rec.col19 := p7_a32;
    ddp_is_line_rec.col20 := p7_a33;
    ddp_is_line_rec.col21 := p7_a34;
    ddp_is_line_rec.col22 := p7_a35;
    ddp_is_line_rec.col23 := p7_a36;
    ddp_is_line_rec.col24 := p7_a37;
    ddp_is_line_rec.col25 := p7_a38;
    ddp_is_line_rec.col26 := p7_a39;
    ddp_is_line_rec.col27 := p7_a40;
    ddp_is_line_rec.col28 := p7_a41;
    ddp_is_line_rec.col29 := p7_a42;
    ddp_is_line_rec.col30 := p7_a43;
    ddp_is_line_rec.col31 := p7_a44;
    ddp_is_line_rec.col32 := p7_a45;
    ddp_is_line_rec.col33 := p7_a46;
    ddp_is_line_rec.col34 := p7_a47;
    ddp_is_line_rec.col35 := p7_a48;
    ddp_is_line_rec.col36 := p7_a49;
    ddp_is_line_rec.col37 := p7_a50;
    ddp_is_line_rec.col38 := p7_a51;
    ddp_is_line_rec.col39 := p7_a52;
    ddp_is_line_rec.col40 := p7_a53;
    ddp_is_line_rec.col41 := p7_a54;
    ddp_is_line_rec.col42 := p7_a55;
    ddp_is_line_rec.col43 := p7_a56;
    ddp_is_line_rec.col44 := p7_a57;
    ddp_is_line_rec.col45 := p7_a58;
    ddp_is_line_rec.col46 := p7_a59;
    ddp_is_line_rec.col47 := p7_a60;
    ddp_is_line_rec.col48 := p7_a61;
    ddp_is_line_rec.col49 := p7_a62;
    ddp_is_line_rec.col50 := p7_a63;
    ddp_is_line_rec.col51 := p7_a64;
    ddp_is_line_rec.col52 := p7_a65;
    ddp_is_line_rec.col53 := p7_a66;
    ddp_is_line_rec.col54 := p7_a67;
    ddp_is_line_rec.col55 := p7_a68;
    ddp_is_line_rec.col56 := p7_a69;
    ddp_is_line_rec.col57 := p7_a70;
    ddp_is_line_rec.col58 := p7_a71;
    ddp_is_line_rec.col59 := p7_a72;
    ddp_is_line_rec.col60 := p7_a73;
    ddp_is_line_rec.col61 := p7_a74;
    ddp_is_line_rec.col62 := p7_a75;
    ddp_is_line_rec.col63 := p7_a76;
    ddp_is_line_rec.col64 := p7_a77;
    ddp_is_line_rec.col65 := p7_a78;
    ddp_is_line_rec.col66 := p7_a79;
    ddp_is_line_rec.col67 := p7_a80;
    ddp_is_line_rec.col68 := p7_a81;
    ddp_is_line_rec.col69 := p7_a82;
    ddp_is_line_rec.col70 := p7_a83;
    ddp_is_line_rec.col71 := p7_a84;
    ddp_is_line_rec.col72 := p7_a85;
    ddp_is_line_rec.col73 := p7_a86;
    ddp_is_line_rec.col74 := p7_a87;
    ddp_is_line_rec.col75 := p7_a88;
    ddp_is_line_rec.col76 := p7_a89;
    ddp_is_line_rec.col77 := p7_a90;
    ddp_is_line_rec.col78 := p7_a91;
    ddp_is_line_rec.col79 := p7_a92;
    ddp_is_line_rec.col80 := p7_a93;
    ddp_is_line_rec.col81 := p7_a94;
    ddp_is_line_rec.col82 := p7_a95;
    ddp_is_line_rec.col83 := p7_a96;
    ddp_is_line_rec.col84 := p7_a97;
    ddp_is_line_rec.col85 := p7_a98;
    ddp_is_line_rec.col86 := p7_a99;
    ddp_is_line_rec.col87 := p7_a100;
    ddp_is_line_rec.col88 := p7_a101;
    ddp_is_line_rec.col89 := p7_a102;
    ddp_is_line_rec.col90 := p7_a103;
    ddp_is_line_rec.col91 := p7_a104;
    ddp_is_line_rec.col92 := p7_a105;
    ddp_is_line_rec.col93 := p7_a106;
    ddp_is_line_rec.col94 := p7_a107;
    ddp_is_line_rec.col95 := p7_a108;
    ddp_is_line_rec.col96 := p7_a109;
    ddp_is_line_rec.col97 := p7_a110;
    ddp_is_line_rec.col98 := p7_a111;
    ddp_is_line_rec.col99 := p7_a112;
    ddp_is_line_rec.col100 := p7_a113;
    ddp_is_line_rec.col101 := p7_a114;
    ddp_is_line_rec.col102 := p7_a115;
    ddp_is_line_rec.col103 := p7_a116;
    ddp_is_line_rec.col104 := p7_a117;
    ddp_is_line_rec.col105 := p7_a118;
    ddp_is_line_rec.col106 := p7_a119;
    ddp_is_line_rec.col107 := p7_a120;
    ddp_is_line_rec.col108 := p7_a121;
    ddp_is_line_rec.col109 := p7_a122;
    ddp_is_line_rec.col110 := p7_a123;
    ddp_is_line_rec.col111 := p7_a124;
    ddp_is_line_rec.col112 := p7_a125;
    ddp_is_line_rec.col113 := p7_a126;
    ddp_is_line_rec.col114 := p7_a127;
    ddp_is_line_rec.col115 := p7_a128;
    ddp_is_line_rec.col116 := p7_a129;
    ddp_is_line_rec.col117 := p7_a130;
    ddp_is_line_rec.col118 := p7_a131;
    ddp_is_line_rec.col119 := p7_a132;
    ddp_is_line_rec.col120 := p7_a133;
    ddp_is_line_rec.col121 := p7_a134;
    ddp_is_line_rec.col122 := p7_a135;
    ddp_is_line_rec.col123 := p7_a136;
    ddp_is_line_rec.col124 := p7_a137;
    ddp_is_line_rec.col125 := p7_a138;
    ddp_is_line_rec.col126 := p7_a139;
    ddp_is_line_rec.col127 := p7_a140;
    ddp_is_line_rec.col128 := p7_a141;
    ddp_is_line_rec.col129 := p7_a142;
    ddp_is_line_rec.col130 := p7_a143;
    ddp_is_line_rec.col131 := p7_a144;
    ddp_is_line_rec.col132 := p7_a145;
    ddp_is_line_rec.col133 := p7_a146;
    ddp_is_line_rec.col134 := p7_a147;
    ddp_is_line_rec.col135 := p7_a148;
    ddp_is_line_rec.col136 := p7_a149;
    ddp_is_line_rec.col137 := p7_a150;
    ddp_is_line_rec.col138 := p7_a151;
    ddp_is_line_rec.col139 := p7_a152;
    ddp_is_line_rec.col140 := p7_a153;
    ddp_is_line_rec.col141 := p7_a154;
    ddp_is_line_rec.col142 := p7_a155;
    ddp_is_line_rec.col143 := p7_a156;
    ddp_is_line_rec.col144 := p7_a157;
    ddp_is_line_rec.col145 := p7_a158;
    ddp_is_line_rec.col146 := p7_a159;
    ddp_is_line_rec.col147 := p7_a160;
    ddp_is_line_rec.col148 := p7_a161;
    ddp_is_line_rec.col149 := p7_a162;
    ddp_is_line_rec.col150 := p7_a163;
    ddp_is_line_rec.col151 := p7_a164;
    ddp_is_line_rec.col152 := p7_a165;
    ddp_is_line_rec.col153 := p7_a166;
    ddp_is_line_rec.col154 := p7_a167;
    ddp_is_line_rec.col155 := p7_a168;
    ddp_is_line_rec.col156 := p7_a169;
    ddp_is_line_rec.col157 := p7_a170;
    ddp_is_line_rec.col158 := p7_a171;
    ddp_is_line_rec.col159 := p7_a172;
    ddp_is_line_rec.col160 := p7_a173;
    ddp_is_line_rec.col161 := p7_a174;
    ddp_is_line_rec.col162 := p7_a175;
    ddp_is_line_rec.col163 := p7_a176;
    ddp_is_line_rec.col164 := p7_a177;
    ddp_is_line_rec.col165 := p7_a178;
    ddp_is_line_rec.col166 := p7_a179;
    ddp_is_line_rec.col167 := p7_a180;
    ddp_is_line_rec.col168 := p7_a181;
    ddp_is_line_rec.col169 := p7_a182;
    ddp_is_line_rec.col170 := p7_a183;
    ddp_is_line_rec.col171 := p7_a184;
    ddp_is_line_rec.col172 := p7_a185;
    ddp_is_line_rec.col173 := p7_a186;
    ddp_is_line_rec.col174 := p7_a187;
    ddp_is_line_rec.col175 := p7_a188;
    ddp_is_line_rec.col176 := p7_a189;
    ddp_is_line_rec.col177 := p7_a190;
    ddp_is_line_rec.col178 := p7_a191;
    ddp_is_line_rec.col179 := p7_a192;
    ddp_is_line_rec.col180 := p7_a193;
    ddp_is_line_rec.col181 := p7_a194;
    ddp_is_line_rec.col182 := p7_a195;
    ddp_is_line_rec.col183 := p7_a196;
    ddp_is_line_rec.col184 := p7_a197;
    ddp_is_line_rec.col185 := p7_a198;
    ddp_is_line_rec.col186 := p7_a199;
    ddp_is_line_rec.col187 := p7_a200;
    ddp_is_line_rec.col188 := p7_a201;
    ddp_is_line_rec.col189 := p7_a202;
    ddp_is_line_rec.col190 := p7_a203;
    ddp_is_line_rec.col191 := p7_a204;
    ddp_is_line_rec.col192 := p7_a205;
    ddp_is_line_rec.col193 := p7_a206;
    ddp_is_line_rec.col194 := p7_a207;
    ddp_is_line_rec.col195 := p7_a208;
    ddp_is_line_rec.col196 := p7_a209;
    ddp_is_line_rec.col197 := p7_a210;
    ddp_is_line_rec.col198 := p7_a211;
    ddp_is_line_rec.col199 := p7_a212;
    ddp_is_line_rec.col200 := p7_a213;
    ddp_is_line_rec.col201 := p7_a214;
    ddp_is_line_rec.col202 := p7_a215;
    ddp_is_line_rec.col203 := p7_a216;
    ddp_is_line_rec.col204 := p7_a217;
    ddp_is_line_rec.col205 := p7_a218;
    ddp_is_line_rec.col206 := p7_a219;
    ddp_is_line_rec.col207 := p7_a220;
    ddp_is_line_rec.col208 := p7_a221;
    ddp_is_line_rec.col209 := p7_a222;
    ddp_is_line_rec.col210 := p7_a223;
    ddp_is_line_rec.col211 := p7_a224;
    ddp_is_line_rec.col212 := p7_a225;
    ddp_is_line_rec.col213 := p7_a226;
    ddp_is_line_rec.col214 := p7_a227;
    ddp_is_line_rec.col215 := p7_a228;
    ddp_is_line_rec.col216 := p7_a229;
    ddp_is_line_rec.col217 := p7_a230;
    ddp_is_line_rec.col218 := p7_a231;
    ddp_is_line_rec.col219 := p7_a232;
    ddp_is_line_rec.col220 := p7_a233;
    ddp_is_line_rec.col221 := p7_a234;
    ddp_is_line_rec.col222 := p7_a235;
    ddp_is_line_rec.col223 := p7_a236;
    ddp_is_line_rec.col224 := p7_a237;
    ddp_is_line_rec.col225 := p7_a238;
    ddp_is_line_rec.col226 := p7_a239;
    ddp_is_line_rec.col227 := p7_a240;
    ddp_is_line_rec.col228 := p7_a241;
    ddp_is_line_rec.col229 := p7_a242;
    ddp_is_line_rec.col230 := p7_a243;
    ddp_is_line_rec.col231 := p7_a244;
    ddp_is_line_rec.col232 := p7_a245;
    ddp_is_line_rec.col233 := p7_a246;
    ddp_is_line_rec.col234 := p7_a247;
    ddp_is_line_rec.col235 := p7_a248;
    ddp_is_line_rec.col236 := p7_a249;
    ddp_is_line_rec.col237 := p7_a250;
    ddp_is_line_rec.col238 := p7_a251;
    ddp_is_line_rec.col239 := p7_a252;
    ddp_is_line_rec.col240 := p7_a253;
    ddp_is_line_rec.col241 := p7_a254;
    ddp_is_line_rec.col242 := p7_a255;
    ddp_is_line_rec.col243 := p7_a256;
    ddp_is_line_rec.col244 := p7_a257;
    ddp_is_line_rec.col245 := p7_a258;
    ddp_is_line_rec.col246 := p7_a259;
    ddp_is_line_rec.col247 := p7_a260;
    ddp_is_line_rec.col248 := p7_a261;
    ddp_is_line_rec.col249 := p7_a262;
    ddp_is_line_rec.col250 := p7_a263;
    ddp_is_line_rec.duplicate_flag := p7_a264;
    ddp_is_line_rec.current_usage := rosetta_g_miss_num_map(p7_a265);
    ddp_is_line_rec.load_status := p7_a266;
    ddp_is_line_rec.notes := p7_a267;
    ddp_is_line_rec.sales_agent_email_address := p7_a268;
    ddp_is_line_rec.vehicle_response_code := p7_a269;
    ddp_is_line_rec.custom_column1 := p7_a270;
    ddp_is_line_rec.custom_column2 := p7_a271;
    ddp_is_line_rec.custom_column3 := p7_a272;
    ddp_is_line_rec.custom_column4 := p7_a273;
    ddp_is_line_rec.custom_column5 := p7_a274;
    ddp_is_line_rec.custom_column6 := p7_a275;
    ddp_is_line_rec.custom_column7 := p7_a276;
    ddp_is_line_rec.custom_column8 := p7_a277;
    ddp_is_line_rec.custom_column9 := p7_a278;
    ddp_is_line_rec.custom_column10 := p7_a279;
    ddp_is_line_rec.custom_column11 := p7_a280;
    ddp_is_line_rec.custom_column12 := p7_a281;
    ddp_is_line_rec.custom_column13 := p7_a282;
    ddp_is_line_rec.custom_column14 := p7_a283;
    ddp_is_line_rec.custom_column15 := p7_a284;
    ddp_is_line_rec.custom_column16 := p7_a285;
    ddp_is_line_rec.custom_column17 := p7_a286;
    ddp_is_line_rec.custom_column18 := p7_a287;
    ddp_is_line_rec.custom_column19 := p7_a288;
    ddp_is_line_rec.custom_column20 := p7_a289;
    ddp_is_line_rec.custom_column21 := p7_a290;
    ddp_is_line_rec.custom_column22 := p7_a291;
    ddp_is_line_rec.custom_column23 := p7_a292;
    ddp_is_line_rec.custom_column24 := p7_a293;
    ddp_is_line_rec.custom_column25 := p7_a294;


    -- here's the delegated call to the old PL/SQL routine
    ams_is_line_pvt.update_is_line(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_is_line_rec,
      x_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure validate_is_line(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  DATE := fnd_api.g_miss_date
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  DATE := fnd_api.g_miss_date
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
    , p3_a16  VARCHAR2 := fnd_api.g_miss_char
    , p3_a17  VARCHAR2 := fnd_api.g_miss_char
    , p3_a18  VARCHAR2 := fnd_api.g_miss_char
    , p3_a19  VARCHAR2 := fnd_api.g_miss_char
    , p3_a20  VARCHAR2 := fnd_api.g_miss_char
    , p3_a21  VARCHAR2 := fnd_api.g_miss_char
    , p3_a22  VARCHAR2 := fnd_api.g_miss_char
    , p3_a23  VARCHAR2 := fnd_api.g_miss_char
    , p3_a24  VARCHAR2 := fnd_api.g_miss_char
    , p3_a25  VARCHAR2 := fnd_api.g_miss_char
    , p3_a26  VARCHAR2 := fnd_api.g_miss_char
    , p3_a27  VARCHAR2 := fnd_api.g_miss_char
    , p3_a28  VARCHAR2 := fnd_api.g_miss_char
    , p3_a29  VARCHAR2 := fnd_api.g_miss_char
    , p3_a30  VARCHAR2 := fnd_api.g_miss_char
    , p3_a31  VARCHAR2 := fnd_api.g_miss_char
    , p3_a32  VARCHAR2 := fnd_api.g_miss_char
    , p3_a33  VARCHAR2 := fnd_api.g_miss_char
    , p3_a34  VARCHAR2 := fnd_api.g_miss_char
    , p3_a35  VARCHAR2 := fnd_api.g_miss_char
    , p3_a36  VARCHAR2 := fnd_api.g_miss_char
    , p3_a37  VARCHAR2 := fnd_api.g_miss_char
    , p3_a38  VARCHAR2 := fnd_api.g_miss_char
    , p3_a39  VARCHAR2 := fnd_api.g_miss_char
    , p3_a40  VARCHAR2 := fnd_api.g_miss_char
    , p3_a41  VARCHAR2 := fnd_api.g_miss_char
    , p3_a42  VARCHAR2 := fnd_api.g_miss_char
    , p3_a43  VARCHAR2 := fnd_api.g_miss_char
    , p3_a44  VARCHAR2 := fnd_api.g_miss_char
    , p3_a45  VARCHAR2 := fnd_api.g_miss_char
    , p3_a46  VARCHAR2 := fnd_api.g_miss_char
    , p3_a47  VARCHAR2 := fnd_api.g_miss_char
    , p3_a48  VARCHAR2 := fnd_api.g_miss_char
    , p3_a49  VARCHAR2 := fnd_api.g_miss_char
    , p3_a50  VARCHAR2 := fnd_api.g_miss_char
    , p3_a51  VARCHAR2 := fnd_api.g_miss_char
    , p3_a52  VARCHAR2 := fnd_api.g_miss_char
    , p3_a53  VARCHAR2 := fnd_api.g_miss_char
    , p3_a54  VARCHAR2 := fnd_api.g_miss_char
    , p3_a55  VARCHAR2 := fnd_api.g_miss_char
    , p3_a56  VARCHAR2 := fnd_api.g_miss_char
    , p3_a57  VARCHAR2 := fnd_api.g_miss_char
    , p3_a58  VARCHAR2 := fnd_api.g_miss_char
    , p3_a59  VARCHAR2 := fnd_api.g_miss_char
    , p3_a60  VARCHAR2 := fnd_api.g_miss_char
    , p3_a61  VARCHAR2 := fnd_api.g_miss_char
    , p3_a62  VARCHAR2 := fnd_api.g_miss_char
    , p3_a63  VARCHAR2 := fnd_api.g_miss_char
    , p3_a64  VARCHAR2 := fnd_api.g_miss_char
    , p3_a65  VARCHAR2 := fnd_api.g_miss_char
    , p3_a66  VARCHAR2 := fnd_api.g_miss_char
    , p3_a67  VARCHAR2 := fnd_api.g_miss_char
    , p3_a68  VARCHAR2 := fnd_api.g_miss_char
    , p3_a69  VARCHAR2 := fnd_api.g_miss_char
    , p3_a70  VARCHAR2 := fnd_api.g_miss_char
    , p3_a71  VARCHAR2 := fnd_api.g_miss_char
    , p3_a72  VARCHAR2 := fnd_api.g_miss_char
    , p3_a73  VARCHAR2 := fnd_api.g_miss_char
    , p3_a74  VARCHAR2 := fnd_api.g_miss_char
    , p3_a75  VARCHAR2 := fnd_api.g_miss_char
    , p3_a76  VARCHAR2 := fnd_api.g_miss_char
    , p3_a77  VARCHAR2 := fnd_api.g_miss_char
    , p3_a78  VARCHAR2 := fnd_api.g_miss_char
    , p3_a79  VARCHAR2 := fnd_api.g_miss_char
    , p3_a80  VARCHAR2 := fnd_api.g_miss_char
    , p3_a81  VARCHAR2 := fnd_api.g_miss_char
    , p3_a82  VARCHAR2 := fnd_api.g_miss_char
    , p3_a83  VARCHAR2 := fnd_api.g_miss_char
    , p3_a84  VARCHAR2 := fnd_api.g_miss_char
    , p3_a85  VARCHAR2 := fnd_api.g_miss_char
    , p3_a86  VARCHAR2 := fnd_api.g_miss_char
    , p3_a87  VARCHAR2 := fnd_api.g_miss_char
    , p3_a88  VARCHAR2 := fnd_api.g_miss_char
    , p3_a89  VARCHAR2 := fnd_api.g_miss_char
    , p3_a90  VARCHAR2 := fnd_api.g_miss_char
    , p3_a91  VARCHAR2 := fnd_api.g_miss_char
    , p3_a92  VARCHAR2 := fnd_api.g_miss_char
    , p3_a93  VARCHAR2 := fnd_api.g_miss_char
    , p3_a94  VARCHAR2 := fnd_api.g_miss_char
    , p3_a95  VARCHAR2 := fnd_api.g_miss_char
    , p3_a96  VARCHAR2 := fnd_api.g_miss_char
    , p3_a97  VARCHAR2 := fnd_api.g_miss_char
    , p3_a98  VARCHAR2 := fnd_api.g_miss_char
    , p3_a99  VARCHAR2 := fnd_api.g_miss_char
    , p3_a100  VARCHAR2 := fnd_api.g_miss_char
    , p3_a101  VARCHAR2 := fnd_api.g_miss_char
    , p3_a102  VARCHAR2 := fnd_api.g_miss_char
    , p3_a103  VARCHAR2 := fnd_api.g_miss_char
    , p3_a104  VARCHAR2 := fnd_api.g_miss_char
    , p3_a105  VARCHAR2 := fnd_api.g_miss_char
    , p3_a106  VARCHAR2 := fnd_api.g_miss_char
    , p3_a107  VARCHAR2 := fnd_api.g_miss_char
    , p3_a108  VARCHAR2 := fnd_api.g_miss_char
    , p3_a109  VARCHAR2 := fnd_api.g_miss_char
    , p3_a110  VARCHAR2 := fnd_api.g_miss_char
    , p3_a111  VARCHAR2 := fnd_api.g_miss_char
    , p3_a112  VARCHAR2 := fnd_api.g_miss_char
    , p3_a113  VARCHAR2 := fnd_api.g_miss_char
    , p3_a114  VARCHAR2 := fnd_api.g_miss_char
    , p3_a115  VARCHAR2 := fnd_api.g_miss_char
    , p3_a116  VARCHAR2 := fnd_api.g_miss_char
    , p3_a117  VARCHAR2 := fnd_api.g_miss_char
    , p3_a118  VARCHAR2 := fnd_api.g_miss_char
    , p3_a119  VARCHAR2 := fnd_api.g_miss_char
    , p3_a120  VARCHAR2 := fnd_api.g_miss_char
    , p3_a121  VARCHAR2 := fnd_api.g_miss_char
    , p3_a122  VARCHAR2 := fnd_api.g_miss_char
    , p3_a123  VARCHAR2 := fnd_api.g_miss_char
    , p3_a124  VARCHAR2 := fnd_api.g_miss_char
    , p3_a125  VARCHAR2 := fnd_api.g_miss_char
    , p3_a126  VARCHAR2 := fnd_api.g_miss_char
    , p3_a127  VARCHAR2 := fnd_api.g_miss_char
    , p3_a128  VARCHAR2 := fnd_api.g_miss_char
    , p3_a129  VARCHAR2 := fnd_api.g_miss_char
    , p3_a130  VARCHAR2 := fnd_api.g_miss_char
    , p3_a131  VARCHAR2 := fnd_api.g_miss_char
    , p3_a132  VARCHAR2 := fnd_api.g_miss_char
    , p3_a133  VARCHAR2 := fnd_api.g_miss_char
    , p3_a134  VARCHAR2 := fnd_api.g_miss_char
    , p3_a135  VARCHAR2 := fnd_api.g_miss_char
    , p3_a136  VARCHAR2 := fnd_api.g_miss_char
    , p3_a137  VARCHAR2 := fnd_api.g_miss_char
    , p3_a138  VARCHAR2 := fnd_api.g_miss_char
    , p3_a139  VARCHAR2 := fnd_api.g_miss_char
    , p3_a140  VARCHAR2 := fnd_api.g_miss_char
    , p3_a141  VARCHAR2 := fnd_api.g_miss_char
    , p3_a142  VARCHAR2 := fnd_api.g_miss_char
    , p3_a143  VARCHAR2 := fnd_api.g_miss_char
    , p3_a144  VARCHAR2 := fnd_api.g_miss_char
    , p3_a145  VARCHAR2 := fnd_api.g_miss_char
    , p3_a146  VARCHAR2 := fnd_api.g_miss_char
    , p3_a147  VARCHAR2 := fnd_api.g_miss_char
    , p3_a148  VARCHAR2 := fnd_api.g_miss_char
    , p3_a149  VARCHAR2 := fnd_api.g_miss_char
    , p3_a150  VARCHAR2 := fnd_api.g_miss_char
    , p3_a151  VARCHAR2 := fnd_api.g_miss_char
    , p3_a152  VARCHAR2 := fnd_api.g_miss_char
    , p3_a153  VARCHAR2 := fnd_api.g_miss_char
    , p3_a154  VARCHAR2 := fnd_api.g_miss_char
    , p3_a155  VARCHAR2 := fnd_api.g_miss_char
    , p3_a156  VARCHAR2 := fnd_api.g_miss_char
    , p3_a157  VARCHAR2 := fnd_api.g_miss_char
    , p3_a158  VARCHAR2 := fnd_api.g_miss_char
    , p3_a159  VARCHAR2 := fnd_api.g_miss_char
    , p3_a160  VARCHAR2 := fnd_api.g_miss_char
    , p3_a161  VARCHAR2 := fnd_api.g_miss_char
    , p3_a162  VARCHAR2 := fnd_api.g_miss_char
    , p3_a163  VARCHAR2 := fnd_api.g_miss_char
    , p3_a164  VARCHAR2 := fnd_api.g_miss_char
    , p3_a165  VARCHAR2 := fnd_api.g_miss_char
    , p3_a166  VARCHAR2 := fnd_api.g_miss_char
    , p3_a167  VARCHAR2 := fnd_api.g_miss_char
    , p3_a168  VARCHAR2 := fnd_api.g_miss_char
    , p3_a169  VARCHAR2 := fnd_api.g_miss_char
    , p3_a170  VARCHAR2 := fnd_api.g_miss_char
    , p3_a171  VARCHAR2 := fnd_api.g_miss_char
    , p3_a172  VARCHAR2 := fnd_api.g_miss_char
    , p3_a173  VARCHAR2 := fnd_api.g_miss_char
    , p3_a174  VARCHAR2 := fnd_api.g_miss_char
    , p3_a175  VARCHAR2 := fnd_api.g_miss_char
    , p3_a176  VARCHAR2 := fnd_api.g_miss_char
    , p3_a177  VARCHAR2 := fnd_api.g_miss_char
    , p3_a178  VARCHAR2 := fnd_api.g_miss_char
    , p3_a179  VARCHAR2 := fnd_api.g_miss_char
    , p3_a180  VARCHAR2 := fnd_api.g_miss_char
    , p3_a181  VARCHAR2 := fnd_api.g_miss_char
    , p3_a182  VARCHAR2 := fnd_api.g_miss_char
    , p3_a183  VARCHAR2 := fnd_api.g_miss_char
    , p3_a184  VARCHAR2 := fnd_api.g_miss_char
    , p3_a185  VARCHAR2 := fnd_api.g_miss_char
    , p3_a186  VARCHAR2 := fnd_api.g_miss_char
    , p3_a187  VARCHAR2 := fnd_api.g_miss_char
    , p3_a188  VARCHAR2 := fnd_api.g_miss_char
    , p3_a189  VARCHAR2 := fnd_api.g_miss_char
    , p3_a190  VARCHAR2 := fnd_api.g_miss_char
    , p3_a191  VARCHAR2 := fnd_api.g_miss_char
    , p3_a192  VARCHAR2 := fnd_api.g_miss_char
    , p3_a193  VARCHAR2 := fnd_api.g_miss_char
    , p3_a194  VARCHAR2 := fnd_api.g_miss_char
    , p3_a195  VARCHAR2 := fnd_api.g_miss_char
    , p3_a196  VARCHAR2 := fnd_api.g_miss_char
    , p3_a197  VARCHAR2 := fnd_api.g_miss_char
    , p3_a198  VARCHAR2 := fnd_api.g_miss_char
    , p3_a199  VARCHAR2 := fnd_api.g_miss_char
    , p3_a200  VARCHAR2 := fnd_api.g_miss_char
    , p3_a201  VARCHAR2 := fnd_api.g_miss_char
    , p3_a202  VARCHAR2 := fnd_api.g_miss_char
    , p3_a203  VARCHAR2 := fnd_api.g_miss_char
    , p3_a204  VARCHAR2 := fnd_api.g_miss_char
    , p3_a205  VARCHAR2 := fnd_api.g_miss_char
    , p3_a206  VARCHAR2 := fnd_api.g_miss_char
    , p3_a207  VARCHAR2 := fnd_api.g_miss_char
    , p3_a208  VARCHAR2 := fnd_api.g_miss_char
    , p3_a209  VARCHAR2 := fnd_api.g_miss_char
    , p3_a210  VARCHAR2 := fnd_api.g_miss_char
    , p3_a211  VARCHAR2 := fnd_api.g_miss_char
    , p3_a212  VARCHAR2 := fnd_api.g_miss_char
    , p3_a213  VARCHAR2 := fnd_api.g_miss_char
    , p3_a214  VARCHAR2 := fnd_api.g_miss_char
    , p3_a215  VARCHAR2 := fnd_api.g_miss_char
    , p3_a216  VARCHAR2 := fnd_api.g_miss_char
    , p3_a217  VARCHAR2 := fnd_api.g_miss_char
    , p3_a218  VARCHAR2 := fnd_api.g_miss_char
    , p3_a219  VARCHAR2 := fnd_api.g_miss_char
    , p3_a220  VARCHAR2 := fnd_api.g_miss_char
    , p3_a221  VARCHAR2 := fnd_api.g_miss_char
    , p3_a222  VARCHAR2 := fnd_api.g_miss_char
    , p3_a223  VARCHAR2 := fnd_api.g_miss_char
    , p3_a224  VARCHAR2 := fnd_api.g_miss_char
    , p3_a225  VARCHAR2 := fnd_api.g_miss_char
    , p3_a226  VARCHAR2 := fnd_api.g_miss_char
    , p3_a227  VARCHAR2 := fnd_api.g_miss_char
    , p3_a228  VARCHAR2 := fnd_api.g_miss_char
    , p3_a229  VARCHAR2 := fnd_api.g_miss_char
    , p3_a230  VARCHAR2 := fnd_api.g_miss_char
    , p3_a231  VARCHAR2 := fnd_api.g_miss_char
    , p3_a232  VARCHAR2 := fnd_api.g_miss_char
    , p3_a233  VARCHAR2 := fnd_api.g_miss_char
    , p3_a234  VARCHAR2 := fnd_api.g_miss_char
    , p3_a235  VARCHAR2 := fnd_api.g_miss_char
    , p3_a236  VARCHAR2 := fnd_api.g_miss_char
    , p3_a237  VARCHAR2 := fnd_api.g_miss_char
    , p3_a238  VARCHAR2 := fnd_api.g_miss_char
    , p3_a239  VARCHAR2 := fnd_api.g_miss_char
    , p3_a240  VARCHAR2 := fnd_api.g_miss_char
    , p3_a241  VARCHAR2 := fnd_api.g_miss_char
    , p3_a242  VARCHAR2 := fnd_api.g_miss_char
    , p3_a243  VARCHAR2 := fnd_api.g_miss_char
    , p3_a244  VARCHAR2 := fnd_api.g_miss_char
    , p3_a245  VARCHAR2 := fnd_api.g_miss_char
    , p3_a246  VARCHAR2 := fnd_api.g_miss_char
    , p3_a247  VARCHAR2 := fnd_api.g_miss_char
    , p3_a248  VARCHAR2 := fnd_api.g_miss_char
    , p3_a249  VARCHAR2 := fnd_api.g_miss_char
    , p3_a250  VARCHAR2 := fnd_api.g_miss_char
    , p3_a251  VARCHAR2 := fnd_api.g_miss_char
    , p3_a252  VARCHAR2 := fnd_api.g_miss_char
    , p3_a253  VARCHAR2 := fnd_api.g_miss_char
    , p3_a254  VARCHAR2 := fnd_api.g_miss_char
    , p3_a255  VARCHAR2 := fnd_api.g_miss_char
    , p3_a256  VARCHAR2 := fnd_api.g_miss_char
    , p3_a257  VARCHAR2 := fnd_api.g_miss_char
    , p3_a258  VARCHAR2 := fnd_api.g_miss_char
    , p3_a259  VARCHAR2 := fnd_api.g_miss_char
    , p3_a260  VARCHAR2 := fnd_api.g_miss_char
    , p3_a261  VARCHAR2 := fnd_api.g_miss_char
    , p3_a262  VARCHAR2 := fnd_api.g_miss_char
    , p3_a263  VARCHAR2 := fnd_api.g_miss_char
    , p3_a264  VARCHAR2 := fnd_api.g_miss_char
    , p3_a265  NUMBER := 0-1962.0724
    , p3_a266  VARCHAR2 := fnd_api.g_miss_char
    , p3_a267  VARCHAR2 := fnd_api.g_miss_char
    , p3_a268  VARCHAR2 := fnd_api.g_miss_char
    , p3_a269  VARCHAR2 := fnd_api.g_miss_char
    , p3_a270  VARCHAR2 := fnd_api.g_miss_char
    , p3_a271  VARCHAR2 := fnd_api.g_miss_char
    , p3_a272  VARCHAR2 := fnd_api.g_miss_char
    , p3_a273  VARCHAR2 := fnd_api.g_miss_char
    , p3_a274  VARCHAR2 := fnd_api.g_miss_char
    , p3_a275  VARCHAR2 := fnd_api.g_miss_char
    , p3_a276  VARCHAR2 := fnd_api.g_miss_char
    , p3_a277  VARCHAR2 := fnd_api.g_miss_char
    , p3_a278  VARCHAR2 := fnd_api.g_miss_char
    , p3_a279  VARCHAR2 := fnd_api.g_miss_char
    , p3_a280  VARCHAR2 := fnd_api.g_miss_char
    , p3_a281  VARCHAR2 := fnd_api.g_miss_char
    , p3_a282  VARCHAR2 := fnd_api.g_miss_char
    , p3_a283  VARCHAR2 := fnd_api.g_miss_char
    , p3_a284  VARCHAR2 := fnd_api.g_miss_char
    , p3_a285  VARCHAR2 := fnd_api.g_miss_char
    , p3_a286  VARCHAR2 := fnd_api.g_miss_char
    , p3_a287  VARCHAR2 := fnd_api.g_miss_char
    , p3_a288  VARCHAR2 := fnd_api.g_miss_char
    , p3_a289  VARCHAR2 := fnd_api.g_miss_char
    , p3_a290  VARCHAR2 := fnd_api.g_miss_char
    , p3_a291  VARCHAR2 := fnd_api.g_miss_char
    , p3_a292  VARCHAR2 := fnd_api.g_miss_char
    , p3_a293  VARCHAR2 := fnd_api.g_miss_char
    , p3_a294  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_is_line_rec ams_is_line_pvt.is_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_is_line_rec.import_source_line_id := rosetta_g_miss_num_map(p3_a0);
    ddp_is_line_rec.object_version_number := rosetta_g_miss_num_map(p3_a1);
    ddp_is_line_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a2);
    ddp_is_line_rec.last_updated_by := rosetta_g_miss_num_map(p3_a3);
    ddp_is_line_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_is_line_rec.created_by := rosetta_g_miss_num_map(p3_a5);
    ddp_is_line_rec.last_update_login := rosetta_g_miss_num_map(p3_a6);
    ddp_is_line_rec.import_list_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_is_line_rec.import_successful_flag := p3_a8;
    ddp_is_line_rec.enabled_flag := p3_a9;
    ddp_is_line_rec.import_failure_reason := p3_a10;
    ddp_is_line_rec.re_import_last_done_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_is_line_rec.party_id := rosetta_g_miss_num_map(p3_a12);
    ddp_is_line_rec.dedupe_key := p3_a13;
    ddp_is_line_rec.col1 := p3_a14;
    ddp_is_line_rec.col2 := p3_a15;
    ddp_is_line_rec.col3 := p3_a16;
    ddp_is_line_rec.col4 := p3_a17;
    ddp_is_line_rec.col5 := p3_a18;
    ddp_is_line_rec.col6 := p3_a19;
    ddp_is_line_rec.col7 := p3_a20;
    ddp_is_line_rec.col8 := p3_a21;
    ddp_is_line_rec.col9 := p3_a22;
    ddp_is_line_rec.col10 := p3_a23;
    ddp_is_line_rec.col11 := p3_a24;
    ddp_is_line_rec.col12 := p3_a25;
    ddp_is_line_rec.col13 := p3_a26;
    ddp_is_line_rec.col14 := p3_a27;
    ddp_is_line_rec.col15 := p3_a28;
    ddp_is_line_rec.col16 := p3_a29;
    ddp_is_line_rec.col17 := p3_a30;
    ddp_is_line_rec.col18 := p3_a31;
    ddp_is_line_rec.col19 := p3_a32;
    ddp_is_line_rec.col20 := p3_a33;
    ddp_is_line_rec.col21 := p3_a34;
    ddp_is_line_rec.col22 := p3_a35;
    ddp_is_line_rec.col23 := p3_a36;
    ddp_is_line_rec.col24 := p3_a37;
    ddp_is_line_rec.col25 := p3_a38;
    ddp_is_line_rec.col26 := p3_a39;
    ddp_is_line_rec.col27 := p3_a40;
    ddp_is_line_rec.col28 := p3_a41;
    ddp_is_line_rec.col29 := p3_a42;
    ddp_is_line_rec.col30 := p3_a43;
    ddp_is_line_rec.col31 := p3_a44;
    ddp_is_line_rec.col32 := p3_a45;
    ddp_is_line_rec.col33 := p3_a46;
    ddp_is_line_rec.col34 := p3_a47;
    ddp_is_line_rec.col35 := p3_a48;
    ddp_is_line_rec.col36 := p3_a49;
    ddp_is_line_rec.col37 := p3_a50;
    ddp_is_line_rec.col38 := p3_a51;
    ddp_is_line_rec.col39 := p3_a52;
    ddp_is_line_rec.col40 := p3_a53;
    ddp_is_line_rec.col41 := p3_a54;
    ddp_is_line_rec.col42 := p3_a55;
    ddp_is_line_rec.col43 := p3_a56;
    ddp_is_line_rec.col44 := p3_a57;
    ddp_is_line_rec.col45 := p3_a58;
    ddp_is_line_rec.col46 := p3_a59;
    ddp_is_line_rec.col47 := p3_a60;
    ddp_is_line_rec.col48 := p3_a61;
    ddp_is_line_rec.col49 := p3_a62;
    ddp_is_line_rec.col50 := p3_a63;
    ddp_is_line_rec.col51 := p3_a64;
    ddp_is_line_rec.col52 := p3_a65;
    ddp_is_line_rec.col53 := p3_a66;
    ddp_is_line_rec.col54 := p3_a67;
    ddp_is_line_rec.col55 := p3_a68;
    ddp_is_line_rec.col56 := p3_a69;
    ddp_is_line_rec.col57 := p3_a70;
    ddp_is_line_rec.col58 := p3_a71;
    ddp_is_line_rec.col59 := p3_a72;
    ddp_is_line_rec.col60 := p3_a73;
    ddp_is_line_rec.col61 := p3_a74;
    ddp_is_line_rec.col62 := p3_a75;
    ddp_is_line_rec.col63 := p3_a76;
    ddp_is_line_rec.col64 := p3_a77;
    ddp_is_line_rec.col65 := p3_a78;
    ddp_is_line_rec.col66 := p3_a79;
    ddp_is_line_rec.col67 := p3_a80;
    ddp_is_line_rec.col68 := p3_a81;
    ddp_is_line_rec.col69 := p3_a82;
    ddp_is_line_rec.col70 := p3_a83;
    ddp_is_line_rec.col71 := p3_a84;
    ddp_is_line_rec.col72 := p3_a85;
    ddp_is_line_rec.col73 := p3_a86;
    ddp_is_line_rec.col74 := p3_a87;
    ddp_is_line_rec.col75 := p3_a88;
    ddp_is_line_rec.col76 := p3_a89;
    ddp_is_line_rec.col77 := p3_a90;
    ddp_is_line_rec.col78 := p3_a91;
    ddp_is_line_rec.col79 := p3_a92;
    ddp_is_line_rec.col80 := p3_a93;
    ddp_is_line_rec.col81 := p3_a94;
    ddp_is_line_rec.col82 := p3_a95;
    ddp_is_line_rec.col83 := p3_a96;
    ddp_is_line_rec.col84 := p3_a97;
    ddp_is_line_rec.col85 := p3_a98;
    ddp_is_line_rec.col86 := p3_a99;
    ddp_is_line_rec.col87 := p3_a100;
    ddp_is_line_rec.col88 := p3_a101;
    ddp_is_line_rec.col89 := p3_a102;
    ddp_is_line_rec.col90 := p3_a103;
    ddp_is_line_rec.col91 := p3_a104;
    ddp_is_line_rec.col92 := p3_a105;
    ddp_is_line_rec.col93 := p3_a106;
    ddp_is_line_rec.col94 := p3_a107;
    ddp_is_line_rec.col95 := p3_a108;
    ddp_is_line_rec.col96 := p3_a109;
    ddp_is_line_rec.col97 := p3_a110;
    ddp_is_line_rec.col98 := p3_a111;
    ddp_is_line_rec.col99 := p3_a112;
    ddp_is_line_rec.col100 := p3_a113;
    ddp_is_line_rec.col101 := p3_a114;
    ddp_is_line_rec.col102 := p3_a115;
    ddp_is_line_rec.col103 := p3_a116;
    ddp_is_line_rec.col104 := p3_a117;
    ddp_is_line_rec.col105 := p3_a118;
    ddp_is_line_rec.col106 := p3_a119;
    ddp_is_line_rec.col107 := p3_a120;
    ddp_is_line_rec.col108 := p3_a121;
    ddp_is_line_rec.col109 := p3_a122;
    ddp_is_line_rec.col110 := p3_a123;
    ddp_is_line_rec.col111 := p3_a124;
    ddp_is_line_rec.col112 := p3_a125;
    ddp_is_line_rec.col113 := p3_a126;
    ddp_is_line_rec.col114 := p3_a127;
    ddp_is_line_rec.col115 := p3_a128;
    ddp_is_line_rec.col116 := p3_a129;
    ddp_is_line_rec.col117 := p3_a130;
    ddp_is_line_rec.col118 := p3_a131;
    ddp_is_line_rec.col119 := p3_a132;
    ddp_is_line_rec.col120 := p3_a133;
    ddp_is_line_rec.col121 := p3_a134;
    ddp_is_line_rec.col122 := p3_a135;
    ddp_is_line_rec.col123 := p3_a136;
    ddp_is_line_rec.col124 := p3_a137;
    ddp_is_line_rec.col125 := p3_a138;
    ddp_is_line_rec.col126 := p3_a139;
    ddp_is_line_rec.col127 := p3_a140;
    ddp_is_line_rec.col128 := p3_a141;
    ddp_is_line_rec.col129 := p3_a142;
    ddp_is_line_rec.col130 := p3_a143;
    ddp_is_line_rec.col131 := p3_a144;
    ddp_is_line_rec.col132 := p3_a145;
    ddp_is_line_rec.col133 := p3_a146;
    ddp_is_line_rec.col134 := p3_a147;
    ddp_is_line_rec.col135 := p3_a148;
    ddp_is_line_rec.col136 := p3_a149;
    ddp_is_line_rec.col137 := p3_a150;
    ddp_is_line_rec.col138 := p3_a151;
    ddp_is_line_rec.col139 := p3_a152;
    ddp_is_line_rec.col140 := p3_a153;
    ddp_is_line_rec.col141 := p3_a154;
    ddp_is_line_rec.col142 := p3_a155;
    ddp_is_line_rec.col143 := p3_a156;
    ddp_is_line_rec.col144 := p3_a157;
    ddp_is_line_rec.col145 := p3_a158;
    ddp_is_line_rec.col146 := p3_a159;
    ddp_is_line_rec.col147 := p3_a160;
    ddp_is_line_rec.col148 := p3_a161;
    ddp_is_line_rec.col149 := p3_a162;
    ddp_is_line_rec.col150 := p3_a163;
    ddp_is_line_rec.col151 := p3_a164;
    ddp_is_line_rec.col152 := p3_a165;
    ddp_is_line_rec.col153 := p3_a166;
    ddp_is_line_rec.col154 := p3_a167;
    ddp_is_line_rec.col155 := p3_a168;
    ddp_is_line_rec.col156 := p3_a169;
    ddp_is_line_rec.col157 := p3_a170;
    ddp_is_line_rec.col158 := p3_a171;
    ddp_is_line_rec.col159 := p3_a172;
    ddp_is_line_rec.col160 := p3_a173;
    ddp_is_line_rec.col161 := p3_a174;
    ddp_is_line_rec.col162 := p3_a175;
    ddp_is_line_rec.col163 := p3_a176;
    ddp_is_line_rec.col164 := p3_a177;
    ddp_is_line_rec.col165 := p3_a178;
    ddp_is_line_rec.col166 := p3_a179;
    ddp_is_line_rec.col167 := p3_a180;
    ddp_is_line_rec.col168 := p3_a181;
    ddp_is_line_rec.col169 := p3_a182;
    ddp_is_line_rec.col170 := p3_a183;
    ddp_is_line_rec.col171 := p3_a184;
    ddp_is_line_rec.col172 := p3_a185;
    ddp_is_line_rec.col173 := p3_a186;
    ddp_is_line_rec.col174 := p3_a187;
    ddp_is_line_rec.col175 := p3_a188;
    ddp_is_line_rec.col176 := p3_a189;
    ddp_is_line_rec.col177 := p3_a190;
    ddp_is_line_rec.col178 := p3_a191;
    ddp_is_line_rec.col179 := p3_a192;
    ddp_is_line_rec.col180 := p3_a193;
    ddp_is_line_rec.col181 := p3_a194;
    ddp_is_line_rec.col182 := p3_a195;
    ddp_is_line_rec.col183 := p3_a196;
    ddp_is_line_rec.col184 := p3_a197;
    ddp_is_line_rec.col185 := p3_a198;
    ddp_is_line_rec.col186 := p3_a199;
    ddp_is_line_rec.col187 := p3_a200;
    ddp_is_line_rec.col188 := p3_a201;
    ddp_is_line_rec.col189 := p3_a202;
    ddp_is_line_rec.col190 := p3_a203;
    ddp_is_line_rec.col191 := p3_a204;
    ddp_is_line_rec.col192 := p3_a205;
    ddp_is_line_rec.col193 := p3_a206;
    ddp_is_line_rec.col194 := p3_a207;
    ddp_is_line_rec.col195 := p3_a208;
    ddp_is_line_rec.col196 := p3_a209;
    ddp_is_line_rec.col197 := p3_a210;
    ddp_is_line_rec.col198 := p3_a211;
    ddp_is_line_rec.col199 := p3_a212;
    ddp_is_line_rec.col200 := p3_a213;
    ddp_is_line_rec.col201 := p3_a214;
    ddp_is_line_rec.col202 := p3_a215;
    ddp_is_line_rec.col203 := p3_a216;
    ddp_is_line_rec.col204 := p3_a217;
    ddp_is_line_rec.col205 := p3_a218;
    ddp_is_line_rec.col206 := p3_a219;
    ddp_is_line_rec.col207 := p3_a220;
    ddp_is_line_rec.col208 := p3_a221;
    ddp_is_line_rec.col209 := p3_a222;
    ddp_is_line_rec.col210 := p3_a223;
    ddp_is_line_rec.col211 := p3_a224;
    ddp_is_line_rec.col212 := p3_a225;
    ddp_is_line_rec.col213 := p3_a226;
    ddp_is_line_rec.col214 := p3_a227;
    ddp_is_line_rec.col215 := p3_a228;
    ddp_is_line_rec.col216 := p3_a229;
    ddp_is_line_rec.col217 := p3_a230;
    ddp_is_line_rec.col218 := p3_a231;
    ddp_is_line_rec.col219 := p3_a232;
    ddp_is_line_rec.col220 := p3_a233;
    ddp_is_line_rec.col221 := p3_a234;
    ddp_is_line_rec.col222 := p3_a235;
    ddp_is_line_rec.col223 := p3_a236;
    ddp_is_line_rec.col224 := p3_a237;
    ddp_is_line_rec.col225 := p3_a238;
    ddp_is_line_rec.col226 := p3_a239;
    ddp_is_line_rec.col227 := p3_a240;
    ddp_is_line_rec.col228 := p3_a241;
    ddp_is_line_rec.col229 := p3_a242;
    ddp_is_line_rec.col230 := p3_a243;
    ddp_is_line_rec.col231 := p3_a244;
    ddp_is_line_rec.col232 := p3_a245;
    ddp_is_line_rec.col233 := p3_a246;
    ddp_is_line_rec.col234 := p3_a247;
    ddp_is_line_rec.col235 := p3_a248;
    ddp_is_line_rec.col236 := p3_a249;
    ddp_is_line_rec.col237 := p3_a250;
    ddp_is_line_rec.col238 := p3_a251;
    ddp_is_line_rec.col239 := p3_a252;
    ddp_is_line_rec.col240 := p3_a253;
    ddp_is_line_rec.col241 := p3_a254;
    ddp_is_line_rec.col242 := p3_a255;
    ddp_is_line_rec.col243 := p3_a256;
    ddp_is_line_rec.col244 := p3_a257;
    ddp_is_line_rec.col245 := p3_a258;
    ddp_is_line_rec.col246 := p3_a259;
    ddp_is_line_rec.col247 := p3_a260;
    ddp_is_line_rec.col248 := p3_a261;
    ddp_is_line_rec.col249 := p3_a262;
    ddp_is_line_rec.col250 := p3_a263;
    ddp_is_line_rec.duplicate_flag := p3_a264;
    ddp_is_line_rec.current_usage := rosetta_g_miss_num_map(p3_a265);
    ddp_is_line_rec.load_status := p3_a266;
    ddp_is_line_rec.notes := p3_a267;
    ddp_is_line_rec.sales_agent_email_address := p3_a268;
    ddp_is_line_rec.vehicle_response_code := p3_a269;
    ddp_is_line_rec.custom_column1 := p3_a270;
    ddp_is_line_rec.custom_column2 := p3_a271;
    ddp_is_line_rec.custom_column3 := p3_a272;
    ddp_is_line_rec.custom_column4 := p3_a273;
    ddp_is_line_rec.custom_column5 := p3_a274;
    ddp_is_line_rec.custom_column6 := p3_a275;
    ddp_is_line_rec.custom_column7 := p3_a276;
    ddp_is_line_rec.custom_column8 := p3_a277;
    ddp_is_line_rec.custom_column9 := p3_a278;
    ddp_is_line_rec.custom_column10 := p3_a279;
    ddp_is_line_rec.custom_column11 := p3_a280;
    ddp_is_line_rec.custom_column12 := p3_a281;
    ddp_is_line_rec.custom_column13 := p3_a282;
    ddp_is_line_rec.custom_column14 := p3_a283;
    ddp_is_line_rec.custom_column15 := p3_a284;
    ddp_is_line_rec.custom_column16 := p3_a285;
    ddp_is_line_rec.custom_column17 := p3_a286;
    ddp_is_line_rec.custom_column18 := p3_a287;
    ddp_is_line_rec.custom_column19 := p3_a288;
    ddp_is_line_rec.custom_column20 := p3_a289;
    ddp_is_line_rec.custom_column21 := p3_a290;
    ddp_is_line_rec.custom_column22 := p3_a291;
    ddp_is_line_rec.custom_column23 := p3_a292;
    ddp_is_line_rec.custom_column24 := p3_a293;
    ddp_is_line_rec.custom_column25 := p3_a294;




    -- here's the delegated call to the old PL/SQL routine
    ams_is_line_pvt.validate_is_line(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_is_line_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_is_line_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  DATE := fnd_api.g_miss_date
    , p0_a12  NUMBER := 0-1962.0724
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
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  VARCHAR2 := fnd_api.g_miss_char
    , p0_a27  VARCHAR2 := fnd_api.g_miss_char
    , p0_a28  VARCHAR2 := fnd_api.g_miss_char
    , p0_a29  VARCHAR2 := fnd_api.g_miss_char
    , p0_a30  VARCHAR2 := fnd_api.g_miss_char
    , p0_a31  VARCHAR2 := fnd_api.g_miss_char
    , p0_a32  VARCHAR2 := fnd_api.g_miss_char
    , p0_a33  VARCHAR2 := fnd_api.g_miss_char
    , p0_a34  VARCHAR2 := fnd_api.g_miss_char
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a77  VARCHAR2 := fnd_api.g_miss_char
    , p0_a78  VARCHAR2 := fnd_api.g_miss_char
    , p0_a79  VARCHAR2 := fnd_api.g_miss_char
    , p0_a80  VARCHAR2 := fnd_api.g_miss_char
    , p0_a81  VARCHAR2 := fnd_api.g_miss_char
    , p0_a82  VARCHAR2 := fnd_api.g_miss_char
    , p0_a83  VARCHAR2 := fnd_api.g_miss_char
    , p0_a84  VARCHAR2 := fnd_api.g_miss_char
    , p0_a85  VARCHAR2 := fnd_api.g_miss_char
    , p0_a86  VARCHAR2 := fnd_api.g_miss_char
    , p0_a87  VARCHAR2 := fnd_api.g_miss_char
    , p0_a88  VARCHAR2 := fnd_api.g_miss_char
    , p0_a89  VARCHAR2 := fnd_api.g_miss_char
    , p0_a90  VARCHAR2 := fnd_api.g_miss_char
    , p0_a91  VARCHAR2 := fnd_api.g_miss_char
    , p0_a92  VARCHAR2 := fnd_api.g_miss_char
    , p0_a93  VARCHAR2 := fnd_api.g_miss_char
    , p0_a94  VARCHAR2 := fnd_api.g_miss_char
    , p0_a95  VARCHAR2 := fnd_api.g_miss_char
    , p0_a96  VARCHAR2 := fnd_api.g_miss_char
    , p0_a97  VARCHAR2 := fnd_api.g_miss_char
    , p0_a98  VARCHAR2 := fnd_api.g_miss_char
    , p0_a99  VARCHAR2 := fnd_api.g_miss_char
    , p0_a100  VARCHAR2 := fnd_api.g_miss_char
    , p0_a101  VARCHAR2 := fnd_api.g_miss_char
    , p0_a102  VARCHAR2 := fnd_api.g_miss_char
    , p0_a103  VARCHAR2 := fnd_api.g_miss_char
    , p0_a104  VARCHAR2 := fnd_api.g_miss_char
    , p0_a105  VARCHAR2 := fnd_api.g_miss_char
    , p0_a106  VARCHAR2 := fnd_api.g_miss_char
    , p0_a107  VARCHAR2 := fnd_api.g_miss_char
    , p0_a108  VARCHAR2 := fnd_api.g_miss_char
    , p0_a109  VARCHAR2 := fnd_api.g_miss_char
    , p0_a110  VARCHAR2 := fnd_api.g_miss_char
    , p0_a111  VARCHAR2 := fnd_api.g_miss_char
    , p0_a112  VARCHAR2 := fnd_api.g_miss_char
    , p0_a113  VARCHAR2 := fnd_api.g_miss_char
    , p0_a114  VARCHAR2 := fnd_api.g_miss_char
    , p0_a115  VARCHAR2 := fnd_api.g_miss_char
    , p0_a116  VARCHAR2 := fnd_api.g_miss_char
    , p0_a117  VARCHAR2 := fnd_api.g_miss_char
    , p0_a118  VARCHAR2 := fnd_api.g_miss_char
    , p0_a119  VARCHAR2 := fnd_api.g_miss_char
    , p0_a120  VARCHAR2 := fnd_api.g_miss_char
    , p0_a121  VARCHAR2 := fnd_api.g_miss_char
    , p0_a122  VARCHAR2 := fnd_api.g_miss_char
    , p0_a123  VARCHAR2 := fnd_api.g_miss_char
    , p0_a124  VARCHAR2 := fnd_api.g_miss_char
    , p0_a125  VARCHAR2 := fnd_api.g_miss_char
    , p0_a126  VARCHAR2 := fnd_api.g_miss_char
    , p0_a127  VARCHAR2 := fnd_api.g_miss_char
    , p0_a128  VARCHAR2 := fnd_api.g_miss_char
    , p0_a129  VARCHAR2 := fnd_api.g_miss_char
    , p0_a130  VARCHAR2 := fnd_api.g_miss_char
    , p0_a131  VARCHAR2 := fnd_api.g_miss_char
    , p0_a132  VARCHAR2 := fnd_api.g_miss_char
    , p0_a133  VARCHAR2 := fnd_api.g_miss_char
    , p0_a134  VARCHAR2 := fnd_api.g_miss_char
    , p0_a135  VARCHAR2 := fnd_api.g_miss_char
    , p0_a136  VARCHAR2 := fnd_api.g_miss_char
    , p0_a137  VARCHAR2 := fnd_api.g_miss_char
    , p0_a138  VARCHAR2 := fnd_api.g_miss_char
    , p0_a139  VARCHAR2 := fnd_api.g_miss_char
    , p0_a140  VARCHAR2 := fnd_api.g_miss_char
    , p0_a141  VARCHAR2 := fnd_api.g_miss_char
    , p0_a142  VARCHAR2 := fnd_api.g_miss_char
    , p0_a143  VARCHAR2 := fnd_api.g_miss_char
    , p0_a144  VARCHAR2 := fnd_api.g_miss_char
    , p0_a145  VARCHAR2 := fnd_api.g_miss_char
    , p0_a146  VARCHAR2 := fnd_api.g_miss_char
    , p0_a147  VARCHAR2 := fnd_api.g_miss_char
    , p0_a148  VARCHAR2 := fnd_api.g_miss_char
    , p0_a149  VARCHAR2 := fnd_api.g_miss_char
    , p0_a150  VARCHAR2 := fnd_api.g_miss_char
    , p0_a151  VARCHAR2 := fnd_api.g_miss_char
    , p0_a152  VARCHAR2 := fnd_api.g_miss_char
    , p0_a153  VARCHAR2 := fnd_api.g_miss_char
    , p0_a154  VARCHAR2 := fnd_api.g_miss_char
    , p0_a155  VARCHAR2 := fnd_api.g_miss_char
    , p0_a156  VARCHAR2 := fnd_api.g_miss_char
    , p0_a157  VARCHAR2 := fnd_api.g_miss_char
    , p0_a158  VARCHAR2 := fnd_api.g_miss_char
    , p0_a159  VARCHAR2 := fnd_api.g_miss_char
    , p0_a160  VARCHAR2 := fnd_api.g_miss_char
    , p0_a161  VARCHAR2 := fnd_api.g_miss_char
    , p0_a162  VARCHAR2 := fnd_api.g_miss_char
    , p0_a163  VARCHAR2 := fnd_api.g_miss_char
    , p0_a164  VARCHAR2 := fnd_api.g_miss_char
    , p0_a165  VARCHAR2 := fnd_api.g_miss_char
    , p0_a166  VARCHAR2 := fnd_api.g_miss_char
    , p0_a167  VARCHAR2 := fnd_api.g_miss_char
    , p0_a168  VARCHAR2 := fnd_api.g_miss_char
    , p0_a169  VARCHAR2 := fnd_api.g_miss_char
    , p0_a170  VARCHAR2 := fnd_api.g_miss_char
    , p0_a171  VARCHAR2 := fnd_api.g_miss_char
    , p0_a172  VARCHAR2 := fnd_api.g_miss_char
    , p0_a173  VARCHAR2 := fnd_api.g_miss_char
    , p0_a174  VARCHAR2 := fnd_api.g_miss_char
    , p0_a175  VARCHAR2 := fnd_api.g_miss_char
    , p0_a176  VARCHAR2 := fnd_api.g_miss_char
    , p0_a177  VARCHAR2 := fnd_api.g_miss_char
    , p0_a178  VARCHAR2 := fnd_api.g_miss_char
    , p0_a179  VARCHAR2 := fnd_api.g_miss_char
    , p0_a180  VARCHAR2 := fnd_api.g_miss_char
    , p0_a181  VARCHAR2 := fnd_api.g_miss_char
    , p0_a182  VARCHAR2 := fnd_api.g_miss_char
    , p0_a183  VARCHAR2 := fnd_api.g_miss_char
    , p0_a184  VARCHAR2 := fnd_api.g_miss_char
    , p0_a185  VARCHAR2 := fnd_api.g_miss_char
    , p0_a186  VARCHAR2 := fnd_api.g_miss_char
    , p0_a187  VARCHAR2 := fnd_api.g_miss_char
    , p0_a188  VARCHAR2 := fnd_api.g_miss_char
    , p0_a189  VARCHAR2 := fnd_api.g_miss_char
    , p0_a190  VARCHAR2 := fnd_api.g_miss_char
    , p0_a191  VARCHAR2 := fnd_api.g_miss_char
    , p0_a192  VARCHAR2 := fnd_api.g_miss_char
    , p0_a193  VARCHAR2 := fnd_api.g_miss_char
    , p0_a194  VARCHAR2 := fnd_api.g_miss_char
    , p0_a195  VARCHAR2 := fnd_api.g_miss_char
    , p0_a196  VARCHAR2 := fnd_api.g_miss_char
    , p0_a197  VARCHAR2 := fnd_api.g_miss_char
    , p0_a198  VARCHAR2 := fnd_api.g_miss_char
    , p0_a199  VARCHAR2 := fnd_api.g_miss_char
    , p0_a200  VARCHAR2 := fnd_api.g_miss_char
    , p0_a201  VARCHAR2 := fnd_api.g_miss_char
    , p0_a202  VARCHAR2 := fnd_api.g_miss_char
    , p0_a203  VARCHAR2 := fnd_api.g_miss_char
    , p0_a204  VARCHAR2 := fnd_api.g_miss_char
    , p0_a205  VARCHAR2 := fnd_api.g_miss_char
    , p0_a206  VARCHAR2 := fnd_api.g_miss_char
    , p0_a207  VARCHAR2 := fnd_api.g_miss_char
    , p0_a208  VARCHAR2 := fnd_api.g_miss_char
    , p0_a209  VARCHAR2 := fnd_api.g_miss_char
    , p0_a210  VARCHAR2 := fnd_api.g_miss_char
    , p0_a211  VARCHAR2 := fnd_api.g_miss_char
    , p0_a212  VARCHAR2 := fnd_api.g_miss_char
    , p0_a213  VARCHAR2 := fnd_api.g_miss_char
    , p0_a214  VARCHAR2 := fnd_api.g_miss_char
    , p0_a215  VARCHAR2 := fnd_api.g_miss_char
    , p0_a216  VARCHAR2 := fnd_api.g_miss_char
    , p0_a217  VARCHAR2 := fnd_api.g_miss_char
    , p0_a218  VARCHAR2 := fnd_api.g_miss_char
    , p0_a219  VARCHAR2 := fnd_api.g_miss_char
    , p0_a220  VARCHAR2 := fnd_api.g_miss_char
    , p0_a221  VARCHAR2 := fnd_api.g_miss_char
    , p0_a222  VARCHAR2 := fnd_api.g_miss_char
    , p0_a223  VARCHAR2 := fnd_api.g_miss_char
    , p0_a224  VARCHAR2 := fnd_api.g_miss_char
    , p0_a225  VARCHAR2 := fnd_api.g_miss_char
    , p0_a226  VARCHAR2 := fnd_api.g_miss_char
    , p0_a227  VARCHAR2 := fnd_api.g_miss_char
    , p0_a228  VARCHAR2 := fnd_api.g_miss_char
    , p0_a229  VARCHAR2 := fnd_api.g_miss_char
    , p0_a230  VARCHAR2 := fnd_api.g_miss_char
    , p0_a231  VARCHAR2 := fnd_api.g_miss_char
    , p0_a232  VARCHAR2 := fnd_api.g_miss_char
    , p0_a233  VARCHAR2 := fnd_api.g_miss_char
    , p0_a234  VARCHAR2 := fnd_api.g_miss_char
    , p0_a235  VARCHAR2 := fnd_api.g_miss_char
    , p0_a236  VARCHAR2 := fnd_api.g_miss_char
    , p0_a237  VARCHAR2 := fnd_api.g_miss_char
    , p0_a238  VARCHAR2 := fnd_api.g_miss_char
    , p0_a239  VARCHAR2 := fnd_api.g_miss_char
    , p0_a240  VARCHAR2 := fnd_api.g_miss_char
    , p0_a241  VARCHAR2 := fnd_api.g_miss_char
    , p0_a242  VARCHAR2 := fnd_api.g_miss_char
    , p0_a243  VARCHAR2 := fnd_api.g_miss_char
    , p0_a244  VARCHAR2 := fnd_api.g_miss_char
    , p0_a245  VARCHAR2 := fnd_api.g_miss_char
    , p0_a246  VARCHAR2 := fnd_api.g_miss_char
    , p0_a247  VARCHAR2 := fnd_api.g_miss_char
    , p0_a248  VARCHAR2 := fnd_api.g_miss_char
    , p0_a249  VARCHAR2 := fnd_api.g_miss_char
    , p0_a250  VARCHAR2 := fnd_api.g_miss_char
    , p0_a251  VARCHAR2 := fnd_api.g_miss_char
    , p0_a252  VARCHAR2 := fnd_api.g_miss_char
    , p0_a253  VARCHAR2 := fnd_api.g_miss_char
    , p0_a254  VARCHAR2 := fnd_api.g_miss_char
    , p0_a255  VARCHAR2 := fnd_api.g_miss_char
    , p0_a256  VARCHAR2 := fnd_api.g_miss_char
    , p0_a257  VARCHAR2 := fnd_api.g_miss_char
    , p0_a258  VARCHAR2 := fnd_api.g_miss_char
    , p0_a259  VARCHAR2 := fnd_api.g_miss_char
    , p0_a260  VARCHAR2 := fnd_api.g_miss_char
    , p0_a261  VARCHAR2 := fnd_api.g_miss_char
    , p0_a262  VARCHAR2 := fnd_api.g_miss_char
    , p0_a263  VARCHAR2 := fnd_api.g_miss_char
    , p0_a264  VARCHAR2 := fnd_api.g_miss_char
    , p0_a265  NUMBER := 0-1962.0724
    , p0_a266  VARCHAR2 := fnd_api.g_miss_char
    , p0_a267  VARCHAR2 := fnd_api.g_miss_char
    , p0_a268  VARCHAR2 := fnd_api.g_miss_char
    , p0_a269  VARCHAR2 := fnd_api.g_miss_char
    , p0_a270  VARCHAR2 := fnd_api.g_miss_char
    , p0_a271  VARCHAR2 := fnd_api.g_miss_char
    , p0_a272  VARCHAR2 := fnd_api.g_miss_char
    , p0_a273  VARCHAR2 := fnd_api.g_miss_char
    , p0_a274  VARCHAR2 := fnd_api.g_miss_char
    , p0_a275  VARCHAR2 := fnd_api.g_miss_char
    , p0_a276  VARCHAR2 := fnd_api.g_miss_char
    , p0_a277  VARCHAR2 := fnd_api.g_miss_char
    , p0_a278  VARCHAR2 := fnd_api.g_miss_char
    , p0_a279  VARCHAR2 := fnd_api.g_miss_char
    , p0_a280  VARCHAR2 := fnd_api.g_miss_char
    , p0_a281  VARCHAR2 := fnd_api.g_miss_char
    , p0_a282  VARCHAR2 := fnd_api.g_miss_char
    , p0_a283  VARCHAR2 := fnd_api.g_miss_char
    , p0_a284  VARCHAR2 := fnd_api.g_miss_char
    , p0_a285  VARCHAR2 := fnd_api.g_miss_char
    , p0_a286  VARCHAR2 := fnd_api.g_miss_char
    , p0_a287  VARCHAR2 := fnd_api.g_miss_char
    , p0_a288  VARCHAR2 := fnd_api.g_miss_char
    , p0_a289  VARCHAR2 := fnd_api.g_miss_char
    , p0_a290  VARCHAR2 := fnd_api.g_miss_char
    , p0_a291  VARCHAR2 := fnd_api.g_miss_char
    , p0_a292  VARCHAR2 := fnd_api.g_miss_char
    , p0_a293  VARCHAR2 := fnd_api.g_miss_char
    , p0_a294  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_is_line_rec ams_is_line_pvt.is_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_is_line_rec.import_source_line_id := rosetta_g_miss_num_map(p0_a0);
    ddp_is_line_rec.object_version_number := rosetta_g_miss_num_map(p0_a1);
    ddp_is_line_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_is_line_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_is_line_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_is_line_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_is_line_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_is_line_rec.import_list_header_id := rosetta_g_miss_num_map(p0_a7);
    ddp_is_line_rec.import_successful_flag := p0_a8;
    ddp_is_line_rec.enabled_flag := p0_a9;
    ddp_is_line_rec.import_failure_reason := p0_a10;
    ddp_is_line_rec.re_import_last_done_date := rosetta_g_miss_date_in_map(p0_a11);
    ddp_is_line_rec.party_id := rosetta_g_miss_num_map(p0_a12);
    ddp_is_line_rec.dedupe_key := p0_a13;
    ddp_is_line_rec.col1 := p0_a14;
    ddp_is_line_rec.col2 := p0_a15;
    ddp_is_line_rec.col3 := p0_a16;
    ddp_is_line_rec.col4 := p0_a17;
    ddp_is_line_rec.col5 := p0_a18;
    ddp_is_line_rec.col6 := p0_a19;
    ddp_is_line_rec.col7 := p0_a20;
    ddp_is_line_rec.col8 := p0_a21;
    ddp_is_line_rec.col9 := p0_a22;
    ddp_is_line_rec.col10 := p0_a23;
    ddp_is_line_rec.col11 := p0_a24;
    ddp_is_line_rec.col12 := p0_a25;
    ddp_is_line_rec.col13 := p0_a26;
    ddp_is_line_rec.col14 := p0_a27;
    ddp_is_line_rec.col15 := p0_a28;
    ddp_is_line_rec.col16 := p0_a29;
    ddp_is_line_rec.col17 := p0_a30;
    ddp_is_line_rec.col18 := p0_a31;
    ddp_is_line_rec.col19 := p0_a32;
    ddp_is_line_rec.col20 := p0_a33;
    ddp_is_line_rec.col21 := p0_a34;
    ddp_is_line_rec.col22 := p0_a35;
    ddp_is_line_rec.col23 := p0_a36;
    ddp_is_line_rec.col24 := p0_a37;
    ddp_is_line_rec.col25 := p0_a38;
    ddp_is_line_rec.col26 := p0_a39;
    ddp_is_line_rec.col27 := p0_a40;
    ddp_is_line_rec.col28 := p0_a41;
    ddp_is_line_rec.col29 := p0_a42;
    ddp_is_line_rec.col30 := p0_a43;
    ddp_is_line_rec.col31 := p0_a44;
    ddp_is_line_rec.col32 := p0_a45;
    ddp_is_line_rec.col33 := p0_a46;
    ddp_is_line_rec.col34 := p0_a47;
    ddp_is_line_rec.col35 := p0_a48;
    ddp_is_line_rec.col36 := p0_a49;
    ddp_is_line_rec.col37 := p0_a50;
    ddp_is_line_rec.col38 := p0_a51;
    ddp_is_line_rec.col39 := p0_a52;
    ddp_is_line_rec.col40 := p0_a53;
    ddp_is_line_rec.col41 := p0_a54;
    ddp_is_line_rec.col42 := p0_a55;
    ddp_is_line_rec.col43 := p0_a56;
    ddp_is_line_rec.col44 := p0_a57;
    ddp_is_line_rec.col45 := p0_a58;
    ddp_is_line_rec.col46 := p0_a59;
    ddp_is_line_rec.col47 := p0_a60;
    ddp_is_line_rec.col48 := p0_a61;
    ddp_is_line_rec.col49 := p0_a62;
    ddp_is_line_rec.col50 := p0_a63;
    ddp_is_line_rec.col51 := p0_a64;
    ddp_is_line_rec.col52 := p0_a65;
    ddp_is_line_rec.col53 := p0_a66;
    ddp_is_line_rec.col54 := p0_a67;
    ddp_is_line_rec.col55 := p0_a68;
    ddp_is_line_rec.col56 := p0_a69;
    ddp_is_line_rec.col57 := p0_a70;
    ddp_is_line_rec.col58 := p0_a71;
    ddp_is_line_rec.col59 := p0_a72;
    ddp_is_line_rec.col60 := p0_a73;
    ddp_is_line_rec.col61 := p0_a74;
    ddp_is_line_rec.col62 := p0_a75;
    ddp_is_line_rec.col63 := p0_a76;
    ddp_is_line_rec.col64 := p0_a77;
    ddp_is_line_rec.col65 := p0_a78;
    ddp_is_line_rec.col66 := p0_a79;
    ddp_is_line_rec.col67 := p0_a80;
    ddp_is_line_rec.col68 := p0_a81;
    ddp_is_line_rec.col69 := p0_a82;
    ddp_is_line_rec.col70 := p0_a83;
    ddp_is_line_rec.col71 := p0_a84;
    ddp_is_line_rec.col72 := p0_a85;
    ddp_is_line_rec.col73 := p0_a86;
    ddp_is_line_rec.col74 := p0_a87;
    ddp_is_line_rec.col75 := p0_a88;
    ddp_is_line_rec.col76 := p0_a89;
    ddp_is_line_rec.col77 := p0_a90;
    ddp_is_line_rec.col78 := p0_a91;
    ddp_is_line_rec.col79 := p0_a92;
    ddp_is_line_rec.col80 := p0_a93;
    ddp_is_line_rec.col81 := p0_a94;
    ddp_is_line_rec.col82 := p0_a95;
    ddp_is_line_rec.col83 := p0_a96;
    ddp_is_line_rec.col84 := p0_a97;
    ddp_is_line_rec.col85 := p0_a98;
    ddp_is_line_rec.col86 := p0_a99;
    ddp_is_line_rec.col87 := p0_a100;
    ddp_is_line_rec.col88 := p0_a101;
    ddp_is_line_rec.col89 := p0_a102;
    ddp_is_line_rec.col90 := p0_a103;
    ddp_is_line_rec.col91 := p0_a104;
    ddp_is_line_rec.col92 := p0_a105;
    ddp_is_line_rec.col93 := p0_a106;
    ddp_is_line_rec.col94 := p0_a107;
    ddp_is_line_rec.col95 := p0_a108;
    ddp_is_line_rec.col96 := p0_a109;
    ddp_is_line_rec.col97 := p0_a110;
    ddp_is_line_rec.col98 := p0_a111;
    ddp_is_line_rec.col99 := p0_a112;
    ddp_is_line_rec.col100 := p0_a113;
    ddp_is_line_rec.col101 := p0_a114;
    ddp_is_line_rec.col102 := p0_a115;
    ddp_is_line_rec.col103 := p0_a116;
    ddp_is_line_rec.col104 := p0_a117;
    ddp_is_line_rec.col105 := p0_a118;
    ddp_is_line_rec.col106 := p0_a119;
    ddp_is_line_rec.col107 := p0_a120;
    ddp_is_line_rec.col108 := p0_a121;
    ddp_is_line_rec.col109 := p0_a122;
    ddp_is_line_rec.col110 := p0_a123;
    ddp_is_line_rec.col111 := p0_a124;
    ddp_is_line_rec.col112 := p0_a125;
    ddp_is_line_rec.col113 := p0_a126;
    ddp_is_line_rec.col114 := p0_a127;
    ddp_is_line_rec.col115 := p0_a128;
    ddp_is_line_rec.col116 := p0_a129;
    ddp_is_line_rec.col117 := p0_a130;
    ddp_is_line_rec.col118 := p0_a131;
    ddp_is_line_rec.col119 := p0_a132;
    ddp_is_line_rec.col120 := p0_a133;
    ddp_is_line_rec.col121 := p0_a134;
    ddp_is_line_rec.col122 := p0_a135;
    ddp_is_line_rec.col123 := p0_a136;
    ddp_is_line_rec.col124 := p0_a137;
    ddp_is_line_rec.col125 := p0_a138;
    ddp_is_line_rec.col126 := p0_a139;
    ddp_is_line_rec.col127 := p0_a140;
    ddp_is_line_rec.col128 := p0_a141;
    ddp_is_line_rec.col129 := p0_a142;
    ddp_is_line_rec.col130 := p0_a143;
    ddp_is_line_rec.col131 := p0_a144;
    ddp_is_line_rec.col132 := p0_a145;
    ddp_is_line_rec.col133 := p0_a146;
    ddp_is_line_rec.col134 := p0_a147;
    ddp_is_line_rec.col135 := p0_a148;
    ddp_is_line_rec.col136 := p0_a149;
    ddp_is_line_rec.col137 := p0_a150;
    ddp_is_line_rec.col138 := p0_a151;
    ddp_is_line_rec.col139 := p0_a152;
    ddp_is_line_rec.col140 := p0_a153;
    ddp_is_line_rec.col141 := p0_a154;
    ddp_is_line_rec.col142 := p0_a155;
    ddp_is_line_rec.col143 := p0_a156;
    ddp_is_line_rec.col144 := p0_a157;
    ddp_is_line_rec.col145 := p0_a158;
    ddp_is_line_rec.col146 := p0_a159;
    ddp_is_line_rec.col147 := p0_a160;
    ddp_is_line_rec.col148 := p0_a161;
    ddp_is_line_rec.col149 := p0_a162;
    ddp_is_line_rec.col150 := p0_a163;
    ddp_is_line_rec.col151 := p0_a164;
    ddp_is_line_rec.col152 := p0_a165;
    ddp_is_line_rec.col153 := p0_a166;
    ddp_is_line_rec.col154 := p0_a167;
    ddp_is_line_rec.col155 := p0_a168;
    ddp_is_line_rec.col156 := p0_a169;
    ddp_is_line_rec.col157 := p0_a170;
    ddp_is_line_rec.col158 := p0_a171;
    ddp_is_line_rec.col159 := p0_a172;
    ddp_is_line_rec.col160 := p0_a173;
    ddp_is_line_rec.col161 := p0_a174;
    ddp_is_line_rec.col162 := p0_a175;
    ddp_is_line_rec.col163 := p0_a176;
    ddp_is_line_rec.col164 := p0_a177;
    ddp_is_line_rec.col165 := p0_a178;
    ddp_is_line_rec.col166 := p0_a179;
    ddp_is_line_rec.col167 := p0_a180;
    ddp_is_line_rec.col168 := p0_a181;
    ddp_is_line_rec.col169 := p0_a182;
    ddp_is_line_rec.col170 := p0_a183;
    ddp_is_line_rec.col171 := p0_a184;
    ddp_is_line_rec.col172 := p0_a185;
    ddp_is_line_rec.col173 := p0_a186;
    ddp_is_line_rec.col174 := p0_a187;
    ddp_is_line_rec.col175 := p0_a188;
    ddp_is_line_rec.col176 := p0_a189;
    ddp_is_line_rec.col177 := p0_a190;
    ddp_is_line_rec.col178 := p0_a191;
    ddp_is_line_rec.col179 := p0_a192;
    ddp_is_line_rec.col180 := p0_a193;
    ddp_is_line_rec.col181 := p0_a194;
    ddp_is_line_rec.col182 := p0_a195;
    ddp_is_line_rec.col183 := p0_a196;
    ddp_is_line_rec.col184 := p0_a197;
    ddp_is_line_rec.col185 := p0_a198;
    ddp_is_line_rec.col186 := p0_a199;
    ddp_is_line_rec.col187 := p0_a200;
    ddp_is_line_rec.col188 := p0_a201;
    ddp_is_line_rec.col189 := p0_a202;
    ddp_is_line_rec.col190 := p0_a203;
    ddp_is_line_rec.col191 := p0_a204;
    ddp_is_line_rec.col192 := p0_a205;
    ddp_is_line_rec.col193 := p0_a206;
    ddp_is_line_rec.col194 := p0_a207;
    ddp_is_line_rec.col195 := p0_a208;
    ddp_is_line_rec.col196 := p0_a209;
    ddp_is_line_rec.col197 := p0_a210;
    ddp_is_line_rec.col198 := p0_a211;
    ddp_is_line_rec.col199 := p0_a212;
    ddp_is_line_rec.col200 := p0_a213;
    ddp_is_line_rec.col201 := p0_a214;
    ddp_is_line_rec.col202 := p0_a215;
    ddp_is_line_rec.col203 := p0_a216;
    ddp_is_line_rec.col204 := p0_a217;
    ddp_is_line_rec.col205 := p0_a218;
    ddp_is_line_rec.col206 := p0_a219;
    ddp_is_line_rec.col207 := p0_a220;
    ddp_is_line_rec.col208 := p0_a221;
    ddp_is_line_rec.col209 := p0_a222;
    ddp_is_line_rec.col210 := p0_a223;
    ddp_is_line_rec.col211 := p0_a224;
    ddp_is_line_rec.col212 := p0_a225;
    ddp_is_line_rec.col213 := p0_a226;
    ddp_is_line_rec.col214 := p0_a227;
    ddp_is_line_rec.col215 := p0_a228;
    ddp_is_line_rec.col216 := p0_a229;
    ddp_is_line_rec.col217 := p0_a230;
    ddp_is_line_rec.col218 := p0_a231;
    ddp_is_line_rec.col219 := p0_a232;
    ddp_is_line_rec.col220 := p0_a233;
    ddp_is_line_rec.col221 := p0_a234;
    ddp_is_line_rec.col222 := p0_a235;
    ddp_is_line_rec.col223 := p0_a236;
    ddp_is_line_rec.col224 := p0_a237;
    ddp_is_line_rec.col225 := p0_a238;
    ddp_is_line_rec.col226 := p0_a239;
    ddp_is_line_rec.col227 := p0_a240;
    ddp_is_line_rec.col228 := p0_a241;
    ddp_is_line_rec.col229 := p0_a242;
    ddp_is_line_rec.col230 := p0_a243;
    ddp_is_line_rec.col231 := p0_a244;
    ddp_is_line_rec.col232 := p0_a245;
    ddp_is_line_rec.col233 := p0_a246;
    ddp_is_line_rec.col234 := p0_a247;
    ddp_is_line_rec.col235 := p0_a248;
    ddp_is_line_rec.col236 := p0_a249;
    ddp_is_line_rec.col237 := p0_a250;
    ddp_is_line_rec.col238 := p0_a251;
    ddp_is_line_rec.col239 := p0_a252;
    ddp_is_line_rec.col240 := p0_a253;
    ddp_is_line_rec.col241 := p0_a254;
    ddp_is_line_rec.col242 := p0_a255;
    ddp_is_line_rec.col243 := p0_a256;
    ddp_is_line_rec.col244 := p0_a257;
    ddp_is_line_rec.col245 := p0_a258;
    ddp_is_line_rec.col246 := p0_a259;
    ddp_is_line_rec.col247 := p0_a260;
    ddp_is_line_rec.col248 := p0_a261;
    ddp_is_line_rec.col249 := p0_a262;
    ddp_is_line_rec.col250 := p0_a263;
    ddp_is_line_rec.duplicate_flag := p0_a264;
    ddp_is_line_rec.current_usage := rosetta_g_miss_num_map(p0_a265);
    ddp_is_line_rec.load_status := p0_a266;
    ddp_is_line_rec.notes := p0_a267;
    ddp_is_line_rec.sales_agent_email_address := p0_a268;
    ddp_is_line_rec.vehicle_response_code := p0_a269;
    ddp_is_line_rec.custom_column1 := p0_a270;
    ddp_is_line_rec.custom_column2 := p0_a271;
    ddp_is_line_rec.custom_column3 := p0_a272;
    ddp_is_line_rec.custom_column4 := p0_a273;
    ddp_is_line_rec.custom_column5 := p0_a274;
    ddp_is_line_rec.custom_column6 := p0_a275;
    ddp_is_line_rec.custom_column7 := p0_a276;
    ddp_is_line_rec.custom_column8 := p0_a277;
    ddp_is_line_rec.custom_column9 := p0_a278;
    ddp_is_line_rec.custom_column10 := p0_a279;
    ddp_is_line_rec.custom_column11 := p0_a280;
    ddp_is_line_rec.custom_column12 := p0_a281;
    ddp_is_line_rec.custom_column13 := p0_a282;
    ddp_is_line_rec.custom_column14 := p0_a283;
    ddp_is_line_rec.custom_column15 := p0_a284;
    ddp_is_line_rec.custom_column16 := p0_a285;
    ddp_is_line_rec.custom_column17 := p0_a286;
    ddp_is_line_rec.custom_column18 := p0_a287;
    ddp_is_line_rec.custom_column19 := p0_a288;
    ddp_is_line_rec.custom_column20 := p0_a289;
    ddp_is_line_rec.custom_column21 := p0_a290;
    ddp_is_line_rec.custom_column22 := p0_a291;
    ddp_is_line_rec.custom_column23 := p0_a292;
    ddp_is_line_rec.custom_column24 := p0_a293;
    ddp_is_line_rec.custom_column25 := p0_a294;



    -- here's the delegated call to the old PL/SQL routine
    ams_is_line_pvt.check_is_line_items(ddp_is_line_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_is_line_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  VARCHAR2 := fnd_api.g_miss_char
    , p5_a55  VARCHAR2 := fnd_api.g_miss_char
    , p5_a56  VARCHAR2 := fnd_api.g_miss_char
    , p5_a57  VARCHAR2 := fnd_api.g_miss_char
    , p5_a58  VARCHAR2 := fnd_api.g_miss_char
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
    , p5_a63  VARCHAR2 := fnd_api.g_miss_char
    , p5_a64  VARCHAR2 := fnd_api.g_miss_char
    , p5_a65  VARCHAR2 := fnd_api.g_miss_char
    , p5_a66  VARCHAR2 := fnd_api.g_miss_char
    , p5_a67  VARCHAR2 := fnd_api.g_miss_char
    , p5_a68  VARCHAR2 := fnd_api.g_miss_char
    , p5_a69  VARCHAR2 := fnd_api.g_miss_char
    , p5_a70  VARCHAR2 := fnd_api.g_miss_char
    , p5_a71  VARCHAR2 := fnd_api.g_miss_char
    , p5_a72  VARCHAR2 := fnd_api.g_miss_char
    , p5_a73  VARCHAR2 := fnd_api.g_miss_char
    , p5_a74  VARCHAR2 := fnd_api.g_miss_char
    , p5_a75  VARCHAR2 := fnd_api.g_miss_char
    , p5_a76  VARCHAR2 := fnd_api.g_miss_char
    , p5_a77  VARCHAR2 := fnd_api.g_miss_char
    , p5_a78  VARCHAR2 := fnd_api.g_miss_char
    , p5_a79  VARCHAR2 := fnd_api.g_miss_char
    , p5_a80  VARCHAR2 := fnd_api.g_miss_char
    , p5_a81  VARCHAR2 := fnd_api.g_miss_char
    , p5_a82  VARCHAR2 := fnd_api.g_miss_char
    , p5_a83  VARCHAR2 := fnd_api.g_miss_char
    , p5_a84  VARCHAR2 := fnd_api.g_miss_char
    , p5_a85  VARCHAR2 := fnd_api.g_miss_char
    , p5_a86  VARCHAR2 := fnd_api.g_miss_char
    , p5_a87  VARCHAR2 := fnd_api.g_miss_char
    , p5_a88  VARCHAR2 := fnd_api.g_miss_char
    , p5_a89  VARCHAR2 := fnd_api.g_miss_char
    , p5_a90  VARCHAR2 := fnd_api.g_miss_char
    , p5_a91  VARCHAR2 := fnd_api.g_miss_char
    , p5_a92  VARCHAR2 := fnd_api.g_miss_char
    , p5_a93  VARCHAR2 := fnd_api.g_miss_char
    , p5_a94  VARCHAR2 := fnd_api.g_miss_char
    , p5_a95  VARCHAR2 := fnd_api.g_miss_char
    , p5_a96  VARCHAR2 := fnd_api.g_miss_char
    , p5_a97  VARCHAR2 := fnd_api.g_miss_char
    , p5_a98  VARCHAR2 := fnd_api.g_miss_char
    , p5_a99  VARCHAR2 := fnd_api.g_miss_char
    , p5_a100  VARCHAR2 := fnd_api.g_miss_char
    , p5_a101  VARCHAR2 := fnd_api.g_miss_char
    , p5_a102  VARCHAR2 := fnd_api.g_miss_char
    , p5_a103  VARCHAR2 := fnd_api.g_miss_char
    , p5_a104  VARCHAR2 := fnd_api.g_miss_char
    , p5_a105  VARCHAR2 := fnd_api.g_miss_char
    , p5_a106  VARCHAR2 := fnd_api.g_miss_char
    , p5_a107  VARCHAR2 := fnd_api.g_miss_char
    , p5_a108  VARCHAR2 := fnd_api.g_miss_char
    , p5_a109  VARCHAR2 := fnd_api.g_miss_char
    , p5_a110  VARCHAR2 := fnd_api.g_miss_char
    , p5_a111  VARCHAR2 := fnd_api.g_miss_char
    , p5_a112  VARCHAR2 := fnd_api.g_miss_char
    , p5_a113  VARCHAR2 := fnd_api.g_miss_char
    , p5_a114  VARCHAR2 := fnd_api.g_miss_char
    , p5_a115  VARCHAR2 := fnd_api.g_miss_char
    , p5_a116  VARCHAR2 := fnd_api.g_miss_char
    , p5_a117  VARCHAR2 := fnd_api.g_miss_char
    , p5_a118  VARCHAR2 := fnd_api.g_miss_char
    , p5_a119  VARCHAR2 := fnd_api.g_miss_char
    , p5_a120  VARCHAR2 := fnd_api.g_miss_char
    , p5_a121  VARCHAR2 := fnd_api.g_miss_char
    , p5_a122  VARCHAR2 := fnd_api.g_miss_char
    , p5_a123  VARCHAR2 := fnd_api.g_miss_char
    , p5_a124  VARCHAR2 := fnd_api.g_miss_char
    , p5_a125  VARCHAR2 := fnd_api.g_miss_char
    , p5_a126  VARCHAR2 := fnd_api.g_miss_char
    , p5_a127  VARCHAR2 := fnd_api.g_miss_char
    , p5_a128  VARCHAR2 := fnd_api.g_miss_char
    , p5_a129  VARCHAR2 := fnd_api.g_miss_char
    , p5_a130  VARCHAR2 := fnd_api.g_miss_char
    , p5_a131  VARCHAR2 := fnd_api.g_miss_char
    , p5_a132  VARCHAR2 := fnd_api.g_miss_char
    , p5_a133  VARCHAR2 := fnd_api.g_miss_char
    , p5_a134  VARCHAR2 := fnd_api.g_miss_char
    , p5_a135  VARCHAR2 := fnd_api.g_miss_char
    , p5_a136  VARCHAR2 := fnd_api.g_miss_char
    , p5_a137  VARCHAR2 := fnd_api.g_miss_char
    , p5_a138  VARCHAR2 := fnd_api.g_miss_char
    , p5_a139  VARCHAR2 := fnd_api.g_miss_char
    , p5_a140  VARCHAR2 := fnd_api.g_miss_char
    , p5_a141  VARCHAR2 := fnd_api.g_miss_char
    , p5_a142  VARCHAR2 := fnd_api.g_miss_char
    , p5_a143  VARCHAR2 := fnd_api.g_miss_char
    , p5_a144  VARCHAR2 := fnd_api.g_miss_char
    , p5_a145  VARCHAR2 := fnd_api.g_miss_char
    , p5_a146  VARCHAR2 := fnd_api.g_miss_char
    , p5_a147  VARCHAR2 := fnd_api.g_miss_char
    , p5_a148  VARCHAR2 := fnd_api.g_miss_char
    , p5_a149  VARCHAR2 := fnd_api.g_miss_char
    , p5_a150  VARCHAR2 := fnd_api.g_miss_char
    , p5_a151  VARCHAR2 := fnd_api.g_miss_char
    , p5_a152  VARCHAR2 := fnd_api.g_miss_char
    , p5_a153  VARCHAR2 := fnd_api.g_miss_char
    , p5_a154  VARCHAR2 := fnd_api.g_miss_char
    , p5_a155  VARCHAR2 := fnd_api.g_miss_char
    , p5_a156  VARCHAR2 := fnd_api.g_miss_char
    , p5_a157  VARCHAR2 := fnd_api.g_miss_char
    , p5_a158  VARCHAR2 := fnd_api.g_miss_char
    , p5_a159  VARCHAR2 := fnd_api.g_miss_char
    , p5_a160  VARCHAR2 := fnd_api.g_miss_char
    , p5_a161  VARCHAR2 := fnd_api.g_miss_char
    , p5_a162  VARCHAR2 := fnd_api.g_miss_char
    , p5_a163  VARCHAR2 := fnd_api.g_miss_char
    , p5_a164  VARCHAR2 := fnd_api.g_miss_char
    , p5_a165  VARCHAR2 := fnd_api.g_miss_char
    , p5_a166  VARCHAR2 := fnd_api.g_miss_char
    , p5_a167  VARCHAR2 := fnd_api.g_miss_char
    , p5_a168  VARCHAR2 := fnd_api.g_miss_char
    , p5_a169  VARCHAR2 := fnd_api.g_miss_char
    , p5_a170  VARCHAR2 := fnd_api.g_miss_char
    , p5_a171  VARCHAR2 := fnd_api.g_miss_char
    , p5_a172  VARCHAR2 := fnd_api.g_miss_char
    , p5_a173  VARCHAR2 := fnd_api.g_miss_char
    , p5_a174  VARCHAR2 := fnd_api.g_miss_char
    , p5_a175  VARCHAR2 := fnd_api.g_miss_char
    , p5_a176  VARCHAR2 := fnd_api.g_miss_char
    , p5_a177  VARCHAR2 := fnd_api.g_miss_char
    , p5_a178  VARCHAR2 := fnd_api.g_miss_char
    , p5_a179  VARCHAR2 := fnd_api.g_miss_char
    , p5_a180  VARCHAR2 := fnd_api.g_miss_char
    , p5_a181  VARCHAR2 := fnd_api.g_miss_char
    , p5_a182  VARCHAR2 := fnd_api.g_miss_char
    , p5_a183  VARCHAR2 := fnd_api.g_miss_char
    , p5_a184  VARCHAR2 := fnd_api.g_miss_char
    , p5_a185  VARCHAR2 := fnd_api.g_miss_char
    , p5_a186  VARCHAR2 := fnd_api.g_miss_char
    , p5_a187  VARCHAR2 := fnd_api.g_miss_char
    , p5_a188  VARCHAR2 := fnd_api.g_miss_char
    , p5_a189  VARCHAR2 := fnd_api.g_miss_char
    , p5_a190  VARCHAR2 := fnd_api.g_miss_char
    , p5_a191  VARCHAR2 := fnd_api.g_miss_char
    , p5_a192  VARCHAR2 := fnd_api.g_miss_char
    , p5_a193  VARCHAR2 := fnd_api.g_miss_char
    , p5_a194  VARCHAR2 := fnd_api.g_miss_char
    , p5_a195  VARCHAR2 := fnd_api.g_miss_char
    , p5_a196  VARCHAR2 := fnd_api.g_miss_char
    , p5_a197  VARCHAR2 := fnd_api.g_miss_char
    , p5_a198  VARCHAR2 := fnd_api.g_miss_char
    , p5_a199  VARCHAR2 := fnd_api.g_miss_char
    , p5_a200  VARCHAR2 := fnd_api.g_miss_char
    , p5_a201  VARCHAR2 := fnd_api.g_miss_char
    , p5_a202  VARCHAR2 := fnd_api.g_miss_char
    , p5_a203  VARCHAR2 := fnd_api.g_miss_char
    , p5_a204  VARCHAR2 := fnd_api.g_miss_char
    , p5_a205  VARCHAR2 := fnd_api.g_miss_char
    , p5_a206  VARCHAR2 := fnd_api.g_miss_char
    , p5_a207  VARCHAR2 := fnd_api.g_miss_char
    , p5_a208  VARCHAR2 := fnd_api.g_miss_char
    , p5_a209  VARCHAR2 := fnd_api.g_miss_char
    , p5_a210  VARCHAR2 := fnd_api.g_miss_char
    , p5_a211  VARCHAR2 := fnd_api.g_miss_char
    , p5_a212  VARCHAR2 := fnd_api.g_miss_char
    , p5_a213  VARCHAR2 := fnd_api.g_miss_char
    , p5_a214  VARCHAR2 := fnd_api.g_miss_char
    , p5_a215  VARCHAR2 := fnd_api.g_miss_char
    , p5_a216  VARCHAR2 := fnd_api.g_miss_char
    , p5_a217  VARCHAR2 := fnd_api.g_miss_char
    , p5_a218  VARCHAR2 := fnd_api.g_miss_char
    , p5_a219  VARCHAR2 := fnd_api.g_miss_char
    , p5_a220  VARCHAR2 := fnd_api.g_miss_char
    , p5_a221  VARCHAR2 := fnd_api.g_miss_char
    , p5_a222  VARCHAR2 := fnd_api.g_miss_char
    , p5_a223  VARCHAR2 := fnd_api.g_miss_char
    , p5_a224  VARCHAR2 := fnd_api.g_miss_char
    , p5_a225  VARCHAR2 := fnd_api.g_miss_char
    , p5_a226  VARCHAR2 := fnd_api.g_miss_char
    , p5_a227  VARCHAR2 := fnd_api.g_miss_char
    , p5_a228  VARCHAR2 := fnd_api.g_miss_char
    , p5_a229  VARCHAR2 := fnd_api.g_miss_char
    , p5_a230  VARCHAR2 := fnd_api.g_miss_char
    , p5_a231  VARCHAR2 := fnd_api.g_miss_char
    , p5_a232  VARCHAR2 := fnd_api.g_miss_char
    , p5_a233  VARCHAR2 := fnd_api.g_miss_char
    , p5_a234  VARCHAR2 := fnd_api.g_miss_char
    , p5_a235  VARCHAR2 := fnd_api.g_miss_char
    , p5_a236  VARCHAR2 := fnd_api.g_miss_char
    , p5_a237  VARCHAR2 := fnd_api.g_miss_char
    , p5_a238  VARCHAR2 := fnd_api.g_miss_char
    , p5_a239  VARCHAR2 := fnd_api.g_miss_char
    , p5_a240  VARCHAR2 := fnd_api.g_miss_char
    , p5_a241  VARCHAR2 := fnd_api.g_miss_char
    , p5_a242  VARCHAR2 := fnd_api.g_miss_char
    , p5_a243  VARCHAR2 := fnd_api.g_miss_char
    , p5_a244  VARCHAR2 := fnd_api.g_miss_char
    , p5_a245  VARCHAR2 := fnd_api.g_miss_char
    , p5_a246  VARCHAR2 := fnd_api.g_miss_char
    , p5_a247  VARCHAR2 := fnd_api.g_miss_char
    , p5_a248  VARCHAR2 := fnd_api.g_miss_char
    , p5_a249  VARCHAR2 := fnd_api.g_miss_char
    , p5_a250  VARCHAR2 := fnd_api.g_miss_char
    , p5_a251  VARCHAR2 := fnd_api.g_miss_char
    , p5_a252  VARCHAR2 := fnd_api.g_miss_char
    , p5_a253  VARCHAR2 := fnd_api.g_miss_char
    , p5_a254  VARCHAR2 := fnd_api.g_miss_char
    , p5_a255  VARCHAR2 := fnd_api.g_miss_char
    , p5_a256  VARCHAR2 := fnd_api.g_miss_char
    , p5_a257  VARCHAR2 := fnd_api.g_miss_char
    , p5_a258  VARCHAR2 := fnd_api.g_miss_char
    , p5_a259  VARCHAR2 := fnd_api.g_miss_char
    , p5_a260  VARCHAR2 := fnd_api.g_miss_char
    , p5_a261  VARCHAR2 := fnd_api.g_miss_char
    , p5_a262  VARCHAR2 := fnd_api.g_miss_char
    , p5_a263  VARCHAR2 := fnd_api.g_miss_char
    , p5_a264  VARCHAR2 := fnd_api.g_miss_char
    , p5_a265  NUMBER := 0-1962.0724
    , p5_a266  VARCHAR2 := fnd_api.g_miss_char
    , p5_a267  VARCHAR2 := fnd_api.g_miss_char
    , p5_a268  VARCHAR2 := fnd_api.g_miss_char
    , p5_a269  VARCHAR2 := fnd_api.g_miss_char
    , p5_a270  VARCHAR2 := fnd_api.g_miss_char
    , p5_a271  VARCHAR2 := fnd_api.g_miss_char
    , p5_a272  VARCHAR2 := fnd_api.g_miss_char
    , p5_a273  VARCHAR2 := fnd_api.g_miss_char
    , p5_a274  VARCHAR2 := fnd_api.g_miss_char
    , p5_a275  VARCHAR2 := fnd_api.g_miss_char
    , p5_a276  VARCHAR2 := fnd_api.g_miss_char
    , p5_a277  VARCHAR2 := fnd_api.g_miss_char
    , p5_a278  VARCHAR2 := fnd_api.g_miss_char
    , p5_a279  VARCHAR2 := fnd_api.g_miss_char
    , p5_a280  VARCHAR2 := fnd_api.g_miss_char
    , p5_a281  VARCHAR2 := fnd_api.g_miss_char
    , p5_a282  VARCHAR2 := fnd_api.g_miss_char
    , p5_a283  VARCHAR2 := fnd_api.g_miss_char
    , p5_a284  VARCHAR2 := fnd_api.g_miss_char
    , p5_a285  VARCHAR2 := fnd_api.g_miss_char
    , p5_a286  VARCHAR2 := fnd_api.g_miss_char
    , p5_a287  VARCHAR2 := fnd_api.g_miss_char
    , p5_a288  VARCHAR2 := fnd_api.g_miss_char
    , p5_a289  VARCHAR2 := fnd_api.g_miss_char
    , p5_a290  VARCHAR2 := fnd_api.g_miss_char
    , p5_a291  VARCHAR2 := fnd_api.g_miss_char
    , p5_a292  VARCHAR2 := fnd_api.g_miss_char
    , p5_a293  VARCHAR2 := fnd_api.g_miss_char
    , p5_a294  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_is_line_rec ams_is_line_pvt.is_line_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_is_line_rec.import_source_line_id := rosetta_g_miss_num_map(p5_a0);
    ddp_is_line_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_is_line_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_is_line_rec.last_updated_by := rosetta_g_miss_num_map(p5_a3);
    ddp_is_line_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_is_line_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_is_line_rec.last_update_login := rosetta_g_miss_num_map(p5_a6);
    ddp_is_line_rec.import_list_header_id := rosetta_g_miss_num_map(p5_a7);
    ddp_is_line_rec.import_successful_flag := p5_a8;
    ddp_is_line_rec.enabled_flag := p5_a9;
    ddp_is_line_rec.import_failure_reason := p5_a10;
    ddp_is_line_rec.re_import_last_done_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_is_line_rec.party_id := rosetta_g_miss_num_map(p5_a12);
    ddp_is_line_rec.dedupe_key := p5_a13;
    ddp_is_line_rec.col1 := p5_a14;
    ddp_is_line_rec.col2 := p5_a15;
    ddp_is_line_rec.col3 := p5_a16;
    ddp_is_line_rec.col4 := p5_a17;
    ddp_is_line_rec.col5 := p5_a18;
    ddp_is_line_rec.col6 := p5_a19;
    ddp_is_line_rec.col7 := p5_a20;
    ddp_is_line_rec.col8 := p5_a21;
    ddp_is_line_rec.col9 := p5_a22;
    ddp_is_line_rec.col10 := p5_a23;
    ddp_is_line_rec.col11 := p5_a24;
    ddp_is_line_rec.col12 := p5_a25;
    ddp_is_line_rec.col13 := p5_a26;
    ddp_is_line_rec.col14 := p5_a27;
    ddp_is_line_rec.col15 := p5_a28;
    ddp_is_line_rec.col16 := p5_a29;
    ddp_is_line_rec.col17 := p5_a30;
    ddp_is_line_rec.col18 := p5_a31;
    ddp_is_line_rec.col19 := p5_a32;
    ddp_is_line_rec.col20 := p5_a33;
    ddp_is_line_rec.col21 := p5_a34;
    ddp_is_line_rec.col22 := p5_a35;
    ddp_is_line_rec.col23 := p5_a36;
    ddp_is_line_rec.col24 := p5_a37;
    ddp_is_line_rec.col25 := p5_a38;
    ddp_is_line_rec.col26 := p5_a39;
    ddp_is_line_rec.col27 := p5_a40;
    ddp_is_line_rec.col28 := p5_a41;
    ddp_is_line_rec.col29 := p5_a42;
    ddp_is_line_rec.col30 := p5_a43;
    ddp_is_line_rec.col31 := p5_a44;
    ddp_is_line_rec.col32 := p5_a45;
    ddp_is_line_rec.col33 := p5_a46;
    ddp_is_line_rec.col34 := p5_a47;
    ddp_is_line_rec.col35 := p5_a48;
    ddp_is_line_rec.col36 := p5_a49;
    ddp_is_line_rec.col37 := p5_a50;
    ddp_is_line_rec.col38 := p5_a51;
    ddp_is_line_rec.col39 := p5_a52;
    ddp_is_line_rec.col40 := p5_a53;
    ddp_is_line_rec.col41 := p5_a54;
    ddp_is_line_rec.col42 := p5_a55;
    ddp_is_line_rec.col43 := p5_a56;
    ddp_is_line_rec.col44 := p5_a57;
    ddp_is_line_rec.col45 := p5_a58;
    ddp_is_line_rec.col46 := p5_a59;
    ddp_is_line_rec.col47 := p5_a60;
    ddp_is_line_rec.col48 := p5_a61;
    ddp_is_line_rec.col49 := p5_a62;
    ddp_is_line_rec.col50 := p5_a63;
    ddp_is_line_rec.col51 := p5_a64;
    ddp_is_line_rec.col52 := p5_a65;
    ddp_is_line_rec.col53 := p5_a66;
    ddp_is_line_rec.col54 := p5_a67;
    ddp_is_line_rec.col55 := p5_a68;
    ddp_is_line_rec.col56 := p5_a69;
    ddp_is_line_rec.col57 := p5_a70;
    ddp_is_line_rec.col58 := p5_a71;
    ddp_is_line_rec.col59 := p5_a72;
    ddp_is_line_rec.col60 := p5_a73;
    ddp_is_line_rec.col61 := p5_a74;
    ddp_is_line_rec.col62 := p5_a75;
    ddp_is_line_rec.col63 := p5_a76;
    ddp_is_line_rec.col64 := p5_a77;
    ddp_is_line_rec.col65 := p5_a78;
    ddp_is_line_rec.col66 := p5_a79;
    ddp_is_line_rec.col67 := p5_a80;
    ddp_is_line_rec.col68 := p5_a81;
    ddp_is_line_rec.col69 := p5_a82;
    ddp_is_line_rec.col70 := p5_a83;
    ddp_is_line_rec.col71 := p5_a84;
    ddp_is_line_rec.col72 := p5_a85;
    ddp_is_line_rec.col73 := p5_a86;
    ddp_is_line_rec.col74 := p5_a87;
    ddp_is_line_rec.col75 := p5_a88;
    ddp_is_line_rec.col76 := p5_a89;
    ddp_is_line_rec.col77 := p5_a90;
    ddp_is_line_rec.col78 := p5_a91;
    ddp_is_line_rec.col79 := p5_a92;
    ddp_is_line_rec.col80 := p5_a93;
    ddp_is_line_rec.col81 := p5_a94;
    ddp_is_line_rec.col82 := p5_a95;
    ddp_is_line_rec.col83 := p5_a96;
    ddp_is_line_rec.col84 := p5_a97;
    ddp_is_line_rec.col85 := p5_a98;
    ddp_is_line_rec.col86 := p5_a99;
    ddp_is_line_rec.col87 := p5_a100;
    ddp_is_line_rec.col88 := p5_a101;
    ddp_is_line_rec.col89 := p5_a102;
    ddp_is_line_rec.col90 := p5_a103;
    ddp_is_line_rec.col91 := p5_a104;
    ddp_is_line_rec.col92 := p5_a105;
    ddp_is_line_rec.col93 := p5_a106;
    ddp_is_line_rec.col94 := p5_a107;
    ddp_is_line_rec.col95 := p5_a108;
    ddp_is_line_rec.col96 := p5_a109;
    ddp_is_line_rec.col97 := p5_a110;
    ddp_is_line_rec.col98 := p5_a111;
    ddp_is_line_rec.col99 := p5_a112;
    ddp_is_line_rec.col100 := p5_a113;
    ddp_is_line_rec.col101 := p5_a114;
    ddp_is_line_rec.col102 := p5_a115;
    ddp_is_line_rec.col103 := p5_a116;
    ddp_is_line_rec.col104 := p5_a117;
    ddp_is_line_rec.col105 := p5_a118;
    ddp_is_line_rec.col106 := p5_a119;
    ddp_is_line_rec.col107 := p5_a120;
    ddp_is_line_rec.col108 := p5_a121;
    ddp_is_line_rec.col109 := p5_a122;
    ddp_is_line_rec.col110 := p5_a123;
    ddp_is_line_rec.col111 := p5_a124;
    ddp_is_line_rec.col112 := p5_a125;
    ddp_is_line_rec.col113 := p5_a126;
    ddp_is_line_rec.col114 := p5_a127;
    ddp_is_line_rec.col115 := p5_a128;
    ddp_is_line_rec.col116 := p5_a129;
    ddp_is_line_rec.col117 := p5_a130;
    ddp_is_line_rec.col118 := p5_a131;
    ddp_is_line_rec.col119 := p5_a132;
    ddp_is_line_rec.col120 := p5_a133;
    ddp_is_line_rec.col121 := p5_a134;
    ddp_is_line_rec.col122 := p5_a135;
    ddp_is_line_rec.col123 := p5_a136;
    ddp_is_line_rec.col124 := p5_a137;
    ddp_is_line_rec.col125 := p5_a138;
    ddp_is_line_rec.col126 := p5_a139;
    ddp_is_line_rec.col127 := p5_a140;
    ddp_is_line_rec.col128 := p5_a141;
    ddp_is_line_rec.col129 := p5_a142;
    ddp_is_line_rec.col130 := p5_a143;
    ddp_is_line_rec.col131 := p5_a144;
    ddp_is_line_rec.col132 := p5_a145;
    ddp_is_line_rec.col133 := p5_a146;
    ddp_is_line_rec.col134 := p5_a147;
    ddp_is_line_rec.col135 := p5_a148;
    ddp_is_line_rec.col136 := p5_a149;
    ddp_is_line_rec.col137 := p5_a150;
    ddp_is_line_rec.col138 := p5_a151;
    ddp_is_line_rec.col139 := p5_a152;
    ddp_is_line_rec.col140 := p5_a153;
    ddp_is_line_rec.col141 := p5_a154;
    ddp_is_line_rec.col142 := p5_a155;
    ddp_is_line_rec.col143 := p5_a156;
    ddp_is_line_rec.col144 := p5_a157;
    ddp_is_line_rec.col145 := p5_a158;
    ddp_is_line_rec.col146 := p5_a159;
    ddp_is_line_rec.col147 := p5_a160;
    ddp_is_line_rec.col148 := p5_a161;
    ddp_is_line_rec.col149 := p5_a162;
    ddp_is_line_rec.col150 := p5_a163;
    ddp_is_line_rec.col151 := p5_a164;
    ddp_is_line_rec.col152 := p5_a165;
    ddp_is_line_rec.col153 := p5_a166;
    ddp_is_line_rec.col154 := p5_a167;
    ddp_is_line_rec.col155 := p5_a168;
    ddp_is_line_rec.col156 := p5_a169;
    ddp_is_line_rec.col157 := p5_a170;
    ddp_is_line_rec.col158 := p5_a171;
    ddp_is_line_rec.col159 := p5_a172;
    ddp_is_line_rec.col160 := p5_a173;
    ddp_is_line_rec.col161 := p5_a174;
    ddp_is_line_rec.col162 := p5_a175;
    ddp_is_line_rec.col163 := p5_a176;
    ddp_is_line_rec.col164 := p5_a177;
    ddp_is_line_rec.col165 := p5_a178;
    ddp_is_line_rec.col166 := p5_a179;
    ddp_is_line_rec.col167 := p5_a180;
    ddp_is_line_rec.col168 := p5_a181;
    ddp_is_line_rec.col169 := p5_a182;
    ddp_is_line_rec.col170 := p5_a183;
    ddp_is_line_rec.col171 := p5_a184;
    ddp_is_line_rec.col172 := p5_a185;
    ddp_is_line_rec.col173 := p5_a186;
    ddp_is_line_rec.col174 := p5_a187;
    ddp_is_line_rec.col175 := p5_a188;
    ddp_is_line_rec.col176 := p5_a189;
    ddp_is_line_rec.col177 := p5_a190;
    ddp_is_line_rec.col178 := p5_a191;
    ddp_is_line_rec.col179 := p5_a192;
    ddp_is_line_rec.col180 := p5_a193;
    ddp_is_line_rec.col181 := p5_a194;
    ddp_is_line_rec.col182 := p5_a195;
    ddp_is_line_rec.col183 := p5_a196;
    ddp_is_line_rec.col184 := p5_a197;
    ddp_is_line_rec.col185 := p5_a198;
    ddp_is_line_rec.col186 := p5_a199;
    ddp_is_line_rec.col187 := p5_a200;
    ddp_is_line_rec.col188 := p5_a201;
    ddp_is_line_rec.col189 := p5_a202;
    ddp_is_line_rec.col190 := p5_a203;
    ddp_is_line_rec.col191 := p5_a204;
    ddp_is_line_rec.col192 := p5_a205;
    ddp_is_line_rec.col193 := p5_a206;
    ddp_is_line_rec.col194 := p5_a207;
    ddp_is_line_rec.col195 := p5_a208;
    ddp_is_line_rec.col196 := p5_a209;
    ddp_is_line_rec.col197 := p5_a210;
    ddp_is_line_rec.col198 := p5_a211;
    ddp_is_line_rec.col199 := p5_a212;
    ddp_is_line_rec.col200 := p5_a213;
    ddp_is_line_rec.col201 := p5_a214;
    ddp_is_line_rec.col202 := p5_a215;
    ddp_is_line_rec.col203 := p5_a216;
    ddp_is_line_rec.col204 := p5_a217;
    ddp_is_line_rec.col205 := p5_a218;
    ddp_is_line_rec.col206 := p5_a219;
    ddp_is_line_rec.col207 := p5_a220;
    ddp_is_line_rec.col208 := p5_a221;
    ddp_is_line_rec.col209 := p5_a222;
    ddp_is_line_rec.col210 := p5_a223;
    ddp_is_line_rec.col211 := p5_a224;
    ddp_is_line_rec.col212 := p5_a225;
    ddp_is_line_rec.col213 := p5_a226;
    ddp_is_line_rec.col214 := p5_a227;
    ddp_is_line_rec.col215 := p5_a228;
    ddp_is_line_rec.col216 := p5_a229;
    ddp_is_line_rec.col217 := p5_a230;
    ddp_is_line_rec.col218 := p5_a231;
    ddp_is_line_rec.col219 := p5_a232;
    ddp_is_line_rec.col220 := p5_a233;
    ddp_is_line_rec.col221 := p5_a234;
    ddp_is_line_rec.col222 := p5_a235;
    ddp_is_line_rec.col223 := p5_a236;
    ddp_is_line_rec.col224 := p5_a237;
    ddp_is_line_rec.col225 := p5_a238;
    ddp_is_line_rec.col226 := p5_a239;
    ddp_is_line_rec.col227 := p5_a240;
    ddp_is_line_rec.col228 := p5_a241;
    ddp_is_line_rec.col229 := p5_a242;
    ddp_is_line_rec.col230 := p5_a243;
    ddp_is_line_rec.col231 := p5_a244;
    ddp_is_line_rec.col232 := p5_a245;
    ddp_is_line_rec.col233 := p5_a246;
    ddp_is_line_rec.col234 := p5_a247;
    ddp_is_line_rec.col235 := p5_a248;
    ddp_is_line_rec.col236 := p5_a249;
    ddp_is_line_rec.col237 := p5_a250;
    ddp_is_line_rec.col238 := p5_a251;
    ddp_is_line_rec.col239 := p5_a252;
    ddp_is_line_rec.col240 := p5_a253;
    ddp_is_line_rec.col241 := p5_a254;
    ddp_is_line_rec.col242 := p5_a255;
    ddp_is_line_rec.col243 := p5_a256;
    ddp_is_line_rec.col244 := p5_a257;
    ddp_is_line_rec.col245 := p5_a258;
    ddp_is_line_rec.col246 := p5_a259;
    ddp_is_line_rec.col247 := p5_a260;
    ddp_is_line_rec.col248 := p5_a261;
    ddp_is_line_rec.col249 := p5_a262;
    ddp_is_line_rec.col250 := p5_a263;
    ddp_is_line_rec.duplicate_flag := p5_a264;
    ddp_is_line_rec.current_usage := rosetta_g_miss_num_map(p5_a265);
    ddp_is_line_rec.load_status := p5_a266;
    ddp_is_line_rec.notes := p5_a267;
    ddp_is_line_rec.sales_agent_email_address := p5_a268;
    ddp_is_line_rec.vehicle_response_code := p5_a269;
    ddp_is_line_rec.custom_column1 := p5_a270;
    ddp_is_line_rec.custom_column2 := p5_a271;
    ddp_is_line_rec.custom_column3 := p5_a272;
    ddp_is_line_rec.custom_column4 := p5_a273;
    ddp_is_line_rec.custom_column5 := p5_a274;
    ddp_is_line_rec.custom_column6 := p5_a275;
    ddp_is_line_rec.custom_column7 := p5_a276;
    ddp_is_line_rec.custom_column8 := p5_a277;
    ddp_is_line_rec.custom_column9 := p5_a278;
    ddp_is_line_rec.custom_column10 := p5_a279;
    ddp_is_line_rec.custom_column11 := p5_a280;
    ddp_is_line_rec.custom_column12 := p5_a281;
    ddp_is_line_rec.custom_column13 := p5_a282;
    ddp_is_line_rec.custom_column14 := p5_a283;
    ddp_is_line_rec.custom_column15 := p5_a284;
    ddp_is_line_rec.custom_column16 := p5_a285;
    ddp_is_line_rec.custom_column17 := p5_a286;
    ddp_is_line_rec.custom_column18 := p5_a287;
    ddp_is_line_rec.custom_column19 := p5_a288;
    ddp_is_line_rec.custom_column20 := p5_a289;
    ddp_is_line_rec.custom_column21 := p5_a290;
    ddp_is_line_rec.custom_column22 := p5_a291;
    ddp_is_line_rec.custom_column23 := p5_a292;
    ddp_is_line_rec.custom_column24 := p5_a293;
    ddp_is_line_rec.custom_column25 := p5_a294;

    -- here's the delegated call to the old PL/SQL routine
    ams_is_line_pvt.validate_is_line_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_is_line_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ams_is_line_pvt_w;

/
