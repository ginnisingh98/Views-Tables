--------------------------------------------------------
--  DDL for Package Body AMS_LIST_ENTRIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_ENTRIES_PVT_W" as
  /* $Header: amswlieb.pls 120.1 2005/06/27 05:43:18 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_list_entries_pvt.list_entries_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_VARCHAR2_TABLE_100
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_NUMBER_TABLE
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_NUMBER_TABLE
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_VARCHAR2_TABLE_100
    , a45 JTF_VARCHAR2_TABLE_200
    , a46 JTF_VARCHAR2_TABLE_200
    , a47 JTF_VARCHAR2_TABLE_500
    , a48 JTF_VARCHAR2_TABLE_200
    , a49 JTF_VARCHAR2_TABLE_500
    , a50 JTF_VARCHAR2_TABLE_500
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_VARCHAR2_TABLE_100
    , a55 JTF_VARCHAR2_TABLE_200
    , a56 JTF_VARCHAR2_TABLE_200
    , a57 JTF_VARCHAR2_TABLE_500
    , a58 JTF_VARCHAR2_TABLE_500
    , a59 JTF_VARCHAR2_TABLE_500
    , a60 JTF_VARCHAR2_TABLE_500
    , a61 JTF_VARCHAR2_TABLE_500
    , a62 JTF_VARCHAR2_TABLE_500
    , a63 JTF_VARCHAR2_TABLE_500
    , a64 JTF_VARCHAR2_TABLE_500
    , a65 JTF_VARCHAR2_TABLE_500
    , a66 JTF_VARCHAR2_TABLE_500
    , a67 JTF_VARCHAR2_TABLE_500
    , a68 JTF_VARCHAR2_TABLE_500
    , a69 JTF_VARCHAR2_TABLE_500
    , a70 JTF_VARCHAR2_TABLE_500
    , a71 JTF_VARCHAR2_TABLE_500
    , a72 JTF_VARCHAR2_TABLE_500
    , a73 JTF_VARCHAR2_TABLE_500
    , a74 JTF_VARCHAR2_TABLE_500
    , a75 JTF_VARCHAR2_TABLE_500
    , a76 JTF_VARCHAR2_TABLE_500
    , a77 JTF_VARCHAR2_TABLE_500
    , a78 JTF_VARCHAR2_TABLE_500
    , a79 JTF_VARCHAR2_TABLE_500
    , a80 JTF_VARCHAR2_TABLE_500
    , a81 JTF_VARCHAR2_TABLE_500
    , a82 JTF_VARCHAR2_TABLE_500
    , a83 JTF_VARCHAR2_TABLE_500
    , a84 JTF_VARCHAR2_TABLE_500
    , a85 JTF_VARCHAR2_TABLE_500
    , a86 JTF_VARCHAR2_TABLE_500
    , a87 JTF_VARCHAR2_TABLE_500
    , a88 JTF_VARCHAR2_TABLE_500
    , a89 JTF_VARCHAR2_TABLE_500
    , a90 JTF_VARCHAR2_TABLE_500
    , a91 JTF_VARCHAR2_TABLE_500
    , a92 JTF_VARCHAR2_TABLE_500
    , a93 JTF_VARCHAR2_TABLE_500
    , a94 JTF_VARCHAR2_TABLE_500
    , a95 JTF_VARCHAR2_TABLE_500
    , a96 JTF_VARCHAR2_TABLE_500
    , a97 JTF_VARCHAR2_TABLE_500
    , a98 JTF_VARCHAR2_TABLE_500
    , a99 JTF_VARCHAR2_TABLE_500
    , a100 JTF_VARCHAR2_TABLE_500
    , a101 JTF_VARCHAR2_TABLE_500
    , a102 JTF_VARCHAR2_TABLE_500
    , a103 JTF_VARCHAR2_TABLE_500
    , a104 JTF_VARCHAR2_TABLE_500
    , a105 JTF_VARCHAR2_TABLE_500
    , a106 JTF_VARCHAR2_TABLE_500
    , a107 JTF_VARCHAR2_TABLE_500
    , a108 JTF_VARCHAR2_TABLE_500
    , a109 JTF_VARCHAR2_TABLE_500
    , a110 JTF_VARCHAR2_TABLE_500
    , a111 JTF_VARCHAR2_TABLE_500
    , a112 JTF_VARCHAR2_TABLE_500
    , a113 JTF_VARCHAR2_TABLE_500
    , a114 JTF_VARCHAR2_TABLE_500
    , a115 JTF_VARCHAR2_TABLE_500
    , a116 JTF_VARCHAR2_TABLE_500
    , a117 JTF_VARCHAR2_TABLE_500
    , a118 JTF_VARCHAR2_TABLE_500
    , a119 JTF_VARCHAR2_TABLE_500
    , a120 JTF_VARCHAR2_TABLE_500
    , a121 JTF_VARCHAR2_TABLE_500
    , a122 JTF_VARCHAR2_TABLE_500
    , a123 JTF_VARCHAR2_TABLE_500
    , a124 JTF_VARCHAR2_TABLE_500
    , a125 JTF_VARCHAR2_TABLE_500
    , a126 JTF_VARCHAR2_TABLE_500
    , a127 JTF_VARCHAR2_TABLE_500
    , a128 JTF_VARCHAR2_TABLE_500
    , a129 JTF_VARCHAR2_TABLE_500
    , a130 JTF_VARCHAR2_TABLE_500
    , a131 JTF_VARCHAR2_TABLE_500
    , a132 JTF_VARCHAR2_TABLE_500
    , a133 JTF_VARCHAR2_TABLE_500
    , a134 JTF_VARCHAR2_TABLE_500
    , a135 JTF_VARCHAR2_TABLE_500
    , a136 JTF_VARCHAR2_TABLE_500
    , a137 JTF_VARCHAR2_TABLE_500
    , a138 JTF_VARCHAR2_TABLE_500
    , a139 JTF_VARCHAR2_TABLE_500
    , a140 JTF_VARCHAR2_TABLE_500
    , a141 JTF_VARCHAR2_TABLE_500
    , a142 JTF_VARCHAR2_TABLE_500
    , a143 JTF_VARCHAR2_TABLE_500
    , a144 JTF_VARCHAR2_TABLE_500
    , a145 JTF_VARCHAR2_TABLE_500
    , a146 JTF_VARCHAR2_TABLE_500
    , a147 JTF_VARCHAR2_TABLE_500
    , a148 JTF_VARCHAR2_TABLE_500
    , a149 JTF_VARCHAR2_TABLE_500
    , a150 JTF_VARCHAR2_TABLE_500
    , a151 JTF_VARCHAR2_TABLE_500
    , a152 JTF_VARCHAR2_TABLE_500
    , a153 JTF_VARCHAR2_TABLE_500
    , a154 JTF_VARCHAR2_TABLE_500
    , a155 JTF_VARCHAR2_TABLE_500
    , a156 JTF_VARCHAR2_TABLE_500
    , a157 JTF_VARCHAR2_TABLE_500
    , a158 JTF_VARCHAR2_TABLE_500
    , a159 JTF_VARCHAR2_TABLE_500
    , a160 JTF_VARCHAR2_TABLE_500
    , a161 JTF_VARCHAR2_TABLE_500
    , a162 JTF_VARCHAR2_TABLE_500
    , a163 JTF_VARCHAR2_TABLE_500
    , a164 JTF_VARCHAR2_TABLE_500
    , a165 JTF_VARCHAR2_TABLE_500
    , a166 JTF_VARCHAR2_TABLE_500
    , a167 JTF_VARCHAR2_TABLE_500
    , a168 JTF_VARCHAR2_TABLE_500
    , a169 JTF_VARCHAR2_TABLE_500
    , a170 JTF_VARCHAR2_TABLE_500
    , a171 JTF_VARCHAR2_TABLE_500
    , a172 JTF_VARCHAR2_TABLE_500
    , a173 JTF_VARCHAR2_TABLE_500
    , a174 JTF_VARCHAR2_TABLE_500
    , a175 JTF_VARCHAR2_TABLE_500
    , a176 JTF_VARCHAR2_TABLE_500
    , a177 JTF_VARCHAR2_TABLE_500
    , a178 JTF_VARCHAR2_TABLE_500
    , a179 JTF_VARCHAR2_TABLE_500
    , a180 JTF_VARCHAR2_TABLE_500
    , a181 JTF_VARCHAR2_TABLE_500
    , a182 JTF_VARCHAR2_TABLE_500
    , a183 JTF_VARCHAR2_TABLE_500
    , a184 JTF_VARCHAR2_TABLE_500
    , a185 JTF_VARCHAR2_TABLE_500
    , a186 JTF_VARCHAR2_TABLE_500
    , a187 JTF_VARCHAR2_TABLE_500
    , a188 JTF_VARCHAR2_TABLE_500
    , a189 JTF_VARCHAR2_TABLE_500
    , a190 JTF_VARCHAR2_TABLE_500
    , a191 JTF_VARCHAR2_TABLE_500
    , a192 JTF_VARCHAR2_TABLE_500
    , a193 JTF_VARCHAR2_TABLE_500
    , a194 JTF_VARCHAR2_TABLE_500
    , a195 JTF_VARCHAR2_TABLE_500
    , a196 JTF_VARCHAR2_TABLE_500
    , a197 JTF_VARCHAR2_TABLE_500
    , a198 JTF_VARCHAR2_TABLE_500
    , a199 JTF_VARCHAR2_TABLE_500
    , a200 JTF_VARCHAR2_TABLE_500
    , a201 JTF_VARCHAR2_TABLE_500
    , a202 JTF_VARCHAR2_TABLE_500
    , a203 JTF_VARCHAR2_TABLE_500
    , a204 JTF_VARCHAR2_TABLE_500
    , a205 JTF_VARCHAR2_TABLE_500
    , a206 JTF_VARCHAR2_TABLE_500
    , a207 JTF_VARCHAR2_TABLE_500
    , a208 JTF_VARCHAR2_TABLE_500
    , a209 JTF_VARCHAR2_TABLE_500
    , a210 JTF_VARCHAR2_TABLE_500
    , a211 JTF_VARCHAR2_TABLE_500
    , a212 JTF_VARCHAR2_TABLE_500
    , a213 JTF_VARCHAR2_TABLE_500
    , a214 JTF_VARCHAR2_TABLE_500
    , a215 JTF_VARCHAR2_TABLE_500
    , a216 JTF_VARCHAR2_TABLE_500
    , a217 JTF_VARCHAR2_TABLE_500
    , a218 JTF_VARCHAR2_TABLE_500
    , a219 JTF_VARCHAR2_TABLE_500
    , a220 JTF_VARCHAR2_TABLE_500
    , a221 JTF_VARCHAR2_TABLE_500
    , a222 JTF_VARCHAR2_TABLE_500
    , a223 JTF_VARCHAR2_TABLE_500
    , a224 JTF_VARCHAR2_TABLE_500
    , a225 JTF_VARCHAR2_TABLE_500
    , a226 JTF_VARCHAR2_TABLE_500
    , a227 JTF_VARCHAR2_TABLE_500
    , a228 JTF_VARCHAR2_TABLE_500
    , a229 JTF_VARCHAR2_TABLE_500
    , a230 JTF_VARCHAR2_TABLE_500
    , a231 JTF_VARCHAR2_TABLE_500
    , a232 JTF_VARCHAR2_TABLE_500
    , a233 JTF_VARCHAR2_TABLE_500
    , a234 JTF_VARCHAR2_TABLE_500
    , a235 JTF_VARCHAR2_TABLE_500
    , a236 JTF_VARCHAR2_TABLE_500
    , a237 JTF_VARCHAR2_TABLE_500
    , a238 JTF_VARCHAR2_TABLE_500
    , a239 JTF_VARCHAR2_TABLE_500
    , a240 JTF_VARCHAR2_TABLE_500
    , a241 JTF_VARCHAR2_TABLE_500
    , a242 JTF_VARCHAR2_TABLE_500
    , a243 JTF_VARCHAR2_TABLE_500
    , a244 JTF_VARCHAR2_TABLE_500
    , a245 JTF_VARCHAR2_TABLE_500
    , a246 JTF_VARCHAR2_TABLE_500
    , a247 JTF_VARCHAR2_TABLE_500
    , a248 JTF_VARCHAR2_TABLE_500
    , a249 JTF_VARCHAR2_TABLE_500
    , a250 JTF_VARCHAR2_TABLE_500
    , a251 JTF_VARCHAR2_TABLE_500
    , a252 JTF_VARCHAR2_TABLE_500
    , a253 JTF_VARCHAR2_TABLE_500
    , a254 JTF_VARCHAR2_TABLE_500
    , a255 JTF_VARCHAR2_TABLE_500
    , a256 JTF_VARCHAR2_TABLE_500
    , a257 JTF_VARCHAR2_TABLE_500
    , a258 JTF_VARCHAR2_TABLE_500
    , a259 JTF_VARCHAR2_TABLE_500
    , a260 JTF_VARCHAR2_TABLE_500
    , a261 JTF_VARCHAR2_TABLE_500
    , a262 JTF_VARCHAR2_TABLE_500
    , a263 JTF_VARCHAR2_TABLE_500
    , a264 JTF_VARCHAR2_TABLE_500
    , a265 JTF_VARCHAR2_TABLE_500
    , a266 JTF_VARCHAR2_TABLE_500
    , a267 JTF_VARCHAR2_TABLE_500
    , a268 JTF_VARCHAR2_TABLE_500
    , a269 JTF_VARCHAR2_TABLE_500
    , a270 JTF_VARCHAR2_TABLE_500
    , a271 JTF_VARCHAR2_TABLE_500
    , a272 JTF_VARCHAR2_TABLE_500
    , a273 JTF_VARCHAR2_TABLE_500
    , a274 JTF_VARCHAR2_TABLE_500
    , a275 JTF_VARCHAR2_TABLE_500
    , a276 JTF_VARCHAR2_TABLE_500
    , a277 JTF_VARCHAR2_TABLE_500
    , a278 JTF_VARCHAR2_TABLE_500
    , a279 JTF_VARCHAR2_TABLE_500
    , a280 JTF_VARCHAR2_TABLE_500
    , a281 JTF_VARCHAR2_TABLE_500
    , a282 JTF_VARCHAR2_TABLE_500
    , a283 JTF_VARCHAR2_TABLE_500
    , a284 JTF_VARCHAR2_TABLE_500
    , a285 JTF_VARCHAR2_TABLE_500
    , a286 JTF_VARCHAR2_TABLE_500
    , a287 JTF_VARCHAR2_TABLE_500
    , a288 JTF_VARCHAR2_TABLE_500
    , a289 JTF_VARCHAR2_TABLE_500
    , a290 JTF_VARCHAR2_TABLE_500
    , a291 JTF_VARCHAR2_TABLE_500
    , a292 JTF_VARCHAR2_TABLE_500
    , a293 JTF_VARCHAR2_TABLE_500
    , a294 JTF_VARCHAR2_TABLE_500
    , a295 JTF_VARCHAR2_TABLE_500
    , a296 JTF_VARCHAR2_TABLE_500
    , a297 JTF_VARCHAR2_TABLE_500
    , a298 JTF_VARCHAR2_TABLE_4000
    , a299 JTF_VARCHAR2_TABLE_4000
    , a300 JTF_VARCHAR2_TABLE_4000
    , a301 JTF_VARCHAR2_TABLE_4000
    , a302 JTF_VARCHAR2_TABLE_4000
    , a303 JTF_VARCHAR2_TABLE_4000
    , a304 JTF_VARCHAR2_TABLE_4000
    , a305 JTF_VARCHAR2_TABLE_4000
    , a306 JTF_VARCHAR2_TABLE_4000
    , a307 JTF_VARCHAR2_TABLE_4000
    , a308 JTF_VARCHAR2_TABLE_500
    , a309 JTF_VARCHAR2_TABLE_500
    , a310 JTF_VARCHAR2_TABLE_500
    , a311 JTF_VARCHAR2_TABLE_500
    , a312 JTF_VARCHAR2_TABLE_500
    , a313 JTF_VARCHAR2_TABLE_500
    , a314 JTF_VARCHAR2_TABLE_500
    , a315 JTF_VARCHAR2_TABLE_500
    , a316 JTF_VARCHAR2_TABLE_500
    , a317 JTF_VARCHAR2_TABLE_500
    , a318 JTF_VARCHAR2_TABLE_500
    , a319 JTF_VARCHAR2_TABLE_500
    , a320 JTF_VARCHAR2_TABLE_500
    , a321 JTF_VARCHAR2_TABLE_500
    , a322 JTF_VARCHAR2_TABLE_500
    , a323 JTF_VARCHAR2_TABLE_500
    , a324 JTF_VARCHAR2_TABLE_500
    , a325 JTF_VARCHAR2_TABLE_500
    , a326 JTF_VARCHAR2_TABLE_500
    , a327 JTF_VARCHAR2_TABLE_500
    , a328 JTF_VARCHAR2_TABLE_500
    , a329 JTF_VARCHAR2_TABLE_500
    , a330 JTF_VARCHAR2_TABLE_500
    , a331 JTF_VARCHAR2_TABLE_500
    , a332 JTF_VARCHAR2_TABLE_500
    , a333 JTF_VARCHAR2_TABLE_500
    , a334 JTF_VARCHAR2_TABLE_500
    , a335 JTF_VARCHAR2_TABLE_500
    , a336 JTF_VARCHAR2_TABLE_500
    , a337 JTF_VARCHAR2_TABLE_500
    , a338 JTF_VARCHAR2_TABLE_500
    , a339 JTF_VARCHAR2_TABLE_500
    , a340 JTF_VARCHAR2_TABLE_500
    , a341 JTF_VARCHAR2_TABLE_500
    , a342 JTF_VARCHAR2_TABLE_500
    , a343 JTF_VARCHAR2_TABLE_500
    , a344 JTF_VARCHAR2_TABLE_500
    , a345 JTF_VARCHAR2_TABLE_500
    , a346 JTF_VARCHAR2_TABLE_500
    , a347 JTF_VARCHAR2_TABLE_500
    , a348 JTF_VARCHAR2_TABLE_500
    , a349 JTF_VARCHAR2_TABLE_500
    , a350 JTF_VARCHAR2_TABLE_500
    , a351 JTF_VARCHAR2_TABLE_500
    , a352 JTF_VARCHAR2_TABLE_500
    , a353 JTF_VARCHAR2_TABLE_500
    , a354 JTF_VARCHAR2_TABLE_500
    , a355 JTF_VARCHAR2_TABLE_500
    , a356 JTF_VARCHAR2_TABLE_500
    , a357 JTF_VARCHAR2_TABLE_500
    , a358 JTF_VARCHAR2_TABLE_100
    , a359 JTF_VARCHAR2_TABLE_100
    , a360 JTF_VARCHAR2_TABLE_100
    , a361 JTF_NUMBER_TABLE
    , a362 JTF_NUMBER_TABLE
    , a363 JTF_NUMBER_TABLE
    , a364 JTF_NUMBER_TABLE
    , a365 JTF_NUMBER_TABLE
    , a366 JTF_NUMBER_TABLE
    , a367 JTF_NUMBER_TABLE
    , a368 JTF_NUMBER_TABLE
    , a369 JTF_VARCHAR2_TABLE_100
    , a370 JTF_DATE_TABLE
    , a371 JTF_VARCHAR2_TABLE_100
    , a372 JTF_VARCHAR2_TABLE_100
    , a373 JTF_VARCHAR2_TABLE_100
    , a374 JTF_VARCHAR2_TABLE_100
    , a375 JTF_DATE_TABLE
    , a376 JTF_VARCHAR2_TABLE_100
    , a377 JTF_VARCHAR2_TABLE_100
    , a378 JTF_NUMBER_TABLE
    , a379 JTF_NUMBER_TABLE
    , a380 JTF_NUMBER_TABLE
    , a381 JTF_VARCHAR2_TABLE_4000
    , a382 JTF_VARCHAR2_TABLE_100
    , a383 JTF_VARCHAR2_TABLE_2000
    , a384 JTF_NUMBER_TABLE
    , a385 JTF_NUMBER_TABLE
    , a386 JTF_NUMBER_TABLE
    , a387 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).list_entry_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).list_header_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).list_select_action_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).arc_list_select_action_from := a9(indx);
          t(ddindx).list_select_action_from_name := a10(indx);
          t(ddindx).source_code := a11(indx);
          t(ddindx).arc_list_used_by_source := a12(indx);
          t(ddindx).source_code_for_id := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).pin_code := a14(indx);
          t(ddindx).list_entry_source_system_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).list_entry_source_system_type := a16(indx);
          t(ddindx).view_application_id := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).manually_entered_flag := a18(indx);
          t(ddindx).marked_as_duplicate_flag := a19(indx);
          t(ddindx).marked_as_random_flag := a20(indx);
          t(ddindx).part_of_control_group_flag := a21(indx);
          t(ddindx).exclude_in_triggered_list_flag := a22(indx);
          t(ddindx).enabled_flag := a23(indx);
          t(ddindx).cell_code := a24(indx);
          t(ddindx).dedupe_key := a25(indx);
          t(ddindx).randomly_generated_number := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).campaign_id := rosetta_g_miss_num_map(a27(indx));
          t(ddindx).media_id := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).channel_id := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).channel_schedule_id := rosetta_g_miss_num_map(a30(indx));
          t(ddindx).event_offer_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).customer_id := rosetta_g_miss_num_map(a32(indx));
          t(ddindx).market_segment_id := rosetta_g_miss_num_map(a33(indx));
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a34(indx));
          t(ddindx).transfer_flag := a35(indx);
          t(ddindx).transfer_status := a36(indx);
          t(ddindx).list_source := a37(indx);
          t(ddindx).duplicate_master_entry_id := rosetta_g_miss_num_map(a38(indx));
          t(ddindx).marked_flag := a39(indx);
          t(ddindx).lead_id := rosetta_g_miss_num_map(a40(indx));
          t(ddindx).letter_id := rosetta_g_miss_num_map(a41(indx));
          t(ddindx).picking_header_id := rosetta_g_miss_num_map(a42(indx));
          t(ddindx).batch_id := rosetta_g_miss_num_map(a43(indx));
          t(ddindx).suffix := a44(indx);
          t(ddindx).first_name := a45(indx);
          t(ddindx).last_name := a46(indx);
          t(ddindx).customer_name := a47(indx);
          t(ddindx).title := a48(indx);
          t(ddindx).address_line1 := a49(indx);
          t(ddindx).address_line2 := a50(indx);
          t(ddindx).city := a51(indx);
          t(ddindx).state := a52(indx);
          t(ddindx).zipcode := a53(indx);
          t(ddindx).country := a54(indx);
          t(ddindx).fax := a55(indx);
          t(ddindx).phone := a56(indx);
          t(ddindx).email_address := a57(indx);
          t(ddindx).col1 := a58(indx);
          t(ddindx).col2 := a59(indx);
          t(ddindx).col3 := a60(indx);
          t(ddindx).col4 := a61(indx);
          t(ddindx).col5 := a62(indx);
          t(ddindx).col6 := a63(indx);
          t(ddindx).col7 := a64(indx);
          t(ddindx).col8 := a65(indx);
          t(ddindx).col9 := a66(indx);
          t(ddindx).col10 := a67(indx);
          t(ddindx).col11 := a68(indx);
          t(ddindx).col12 := a69(indx);
          t(ddindx).col13 := a70(indx);
          t(ddindx).col14 := a71(indx);
          t(ddindx).col15 := a72(indx);
          t(ddindx).col16 := a73(indx);
          t(ddindx).col17 := a74(indx);
          t(ddindx).col18 := a75(indx);
          t(ddindx).col19 := a76(indx);
          t(ddindx).col20 := a77(indx);
          t(ddindx).col21 := a78(indx);
          t(ddindx).col22 := a79(indx);
          t(ddindx).col23 := a80(indx);
          t(ddindx).col24 := a81(indx);
          t(ddindx).col25 := a82(indx);
          t(ddindx).col26 := a83(indx);
          t(ddindx).col27 := a84(indx);
          t(ddindx).col28 := a85(indx);
          t(ddindx).col29 := a86(indx);
          t(ddindx).col30 := a87(indx);
          t(ddindx).col31 := a88(indx);
          t(ddindx).col32 := a89(indx);
          t(ddindx).col33 := a90(indx);
          t(ddindx).col34 := a91(indx);
          t(ddindx).col35 := a92(indx);
          t(ddindx).col36 := a93(indx);
          t(ddindx).col37 := a94(indx);
          t(ddindx).col38 := a95(indx);
          t(ddindx).col39 := a96(indx);
          t(ddindx).col40 := a97(indx);
          t(ddindx).col41 := a98(indx);
          t(ddindx).col42 := a99(indx);
          t(ddindx).col43 := a100(indx);
          t(ddindx).col44 := a101(indx);
          t(ddindx).col45 := a102(indx);
          t(ddindx).col46 := a103(indx);
          t(ddindx).col47 := a104(indx);
          t(ddindx).col48 := a105(indx);
          t(ddindx).col49 := a106(indx);
          t(ddindx).col50 := a107(indx);
          t(ddindx).col51 := a108(indx);
          t(ddindx).col52 := a109(indx);
          t(ddindx).col53 := a110(indx);
          t(ddindx).col54 := a111(indx);
          t(ddindx).col55 := a112(indx);
          t(ddindx).col56 := a113(indx);
          t(ddindx).col57 := a114(indx);
          t(ddindx).col58 := a115(indx);
          t(ddindx).col59 := a116(indx);
          t(ddindx).col60 := a117(indx);
          t(ddindx).col61 := a118(indx);
          t(ddindx).col62 := a119(indx);
          t(ddindx).col63 := a120(indx);
          t(ddindx).col64 := a121(indx);
          t(ddindx).col65 := a122(indx);
          t(ddindx).col66 := a123(indx);
          t(ddindx).col67 := a124(indx);
          t(ddindx).col68 := a125(indx);
          t(ddindx).col69 := a126(indx);
          t(ddindx).col70 := a127(indx);
          t(ddindx).col71 := a128(indx);
          t(ddindx).col72 := a129(indx);
          t(ddindx).col73 := a130(indx);
          t(ddindx).col74 := a131(indx);
          t(ddindx).col75 := a132(indx);
          t(ddindx).col76 := a133(indx);
          t(ddindx).col77 := a134(indx);
          t(ddindx).col78 := a135(indx);
          t(ddindx).col79 := a136(indx);
          t(ddindx).col80 := a137(indx);
          t(ddindx).col81 := a138(indx);
          t(ddindx).col82 := a139(indx);
          t(ddindx).col83 := a140(indx);
          t(ddindx).col84 := a141(indx);
          t(ddindx).col85 := a142(indx);
          t(ddindx).col86 := a143(indx);
          t(ddindx).col87 := a144(indx);
          t(ddindx).col88 := a145(indx);
          t(ddindx).col89 := a146(indx);
          t(ddindx).col90 := a147(indx);
          t(ddindx).col91 := a148(indx);
          t(ddindx).col92 := a149(indx);
          t(ddindx).col93 := a150(indx);
          t(ddindx).col94 := a151(indx);
          t(ddindx).col95 := a152(indx);
          t(ddindx).col96 := a153(indx);
          t(ddindx).col97 := a154(indx);
          t(ddindx).col98 := a155(indx);
          t(ddindx).col99 := a156(indx);
          t(ddindx).col100 := a157(indx);
          t(ddindx).col101 := a158(indx);
          t(ddindx).col102 := a159(indx);
          t(ddindx).col103 := a160(indx);
          t(ddindx).col104 := a161(indx);
          t(ddindx).col105 := a162(indx);
          t(ddindx).col106 := a163(indx);
          t(ddindx).col107 := a164(indx);
          t(ddindx).col108 := a165(indx);
          t(ddindx).col109 := a166(indx);
          t(ddindx).col110 := a167(indx);
          t(ddindx).col111 := a168(indx);
          t(ddindx).col112 := a169(indx);
          t(ddindx).col113 := a170(indx);
          t(ddindx).col114 := a171(indx);
          t(ddindx).col115 := a172(indx);
          t(ddindx).col116 := a173(indx);
          t(ddindx).col117 := a174(indx);
          t(ddindx).col118 := a175(indx);
          t(ddindx).col119 := a176(indx);
          t(ddindx).col120 := a177(indx);
          t(ddindx).col121 := a178(indx);
          t(ddindx).col122 := a179(indx);
          t(ddindx).col123 := a180(indx);
          t(ddindx).col124 := a181(indx);
          t(ddindx).col125 := a182(indx);
          t(ddindx).col126 := a183(indx);
          t(ddindx).col127 := a184(indx);
          t(ddindx).col128 := a185(indx);
          t(ddindx).col129 := a186(indx);
          t(ddindx).col130 := a187(indx);
          t(ddindx).col131 := a188(indx);
          t(ddindx).col132 := a189(indx);
          t(ddindx).col133 := a190(indx);
          t(ddindx).col134 := a191(indx);
          t(ddindx).col135 := a192(indx);
          t(ddindx).col136 := a193(indx);
          t(ddindx).col137 := a194(indx);
          t(ddindx).col138 := a195(indx);
          t(ddindx).col139 := a196(indx);
          t(ddindx).col140 := a197(indx);
          t(ddindx).col141 := a198(indx);
          t(ddindx).col142 := a199(indx);
          t(ddindx).col143 := a200(indx);
          t(ddindx).col144 := a201(indx);
          t(ddindx).col145 := a202(indx);
          t(ddindx).col146 := a203(indx);
          t(ddindx).col147 := a204(indx);
          t(ddindx).col148 := a205(indx);
          t(ddindx).col149 := a206(indx);
          t(ddindx).col150 := a207(indx);
          t(ddindx).col151 := a208(indx);
          t(ddindx).col152 := a209(indx);
          t(ddindx).col153 := a210(indx);
          t(ddindx).col154 := a211(indx);
          t(ddindx).col155 := a212(indx);
          t(ddindx).col156 := a213(indx);
          t(ddindx).col157 := a214(indx);
          t(ddindx).col158 := a215(indx);
          t(ddindx).col159 := a216(indx);
          t(ddindx).col160 := a217(indx);
          t(ddindx).col161 := a218(indx);
          t(ddindx).col162 := a219(indx);
          t(ddindx).col163 := a220(indx);
          t(ddindx).col164 := a221(indx);
          t(ddindx).col165 := a222(indx);
          t(ddindx).col166 := a223(indx);
          t(ddindx).col167 := a224(indx);
          t(ddindx).col168 := a225(indx);
          t(ddindx).col169 := a226(indx);
          t(ddindx).col170 := a227(indx);
          t(ddindx).col171 := a228(indx);
          t(ddindx).col172 := a229(indx);
          t(ddindx).col173 := a230(indx);
          t(ddindx).col174 := a231(indx);
          t(ddindx).col175 := a232(indx);
          t(ddindx).col176 := a233(indx);
          t(ddindx).col177 := a234(indx);
          t(ddindx).col178 := a235(indx);
          t(ddindx).col179 := a236(indx);
          t(ddindx).col180 := a237(indx);
          t(ddindx).col181 := a238(indx);
          t(ddindx).col182 := a239(indx);
          t(ddindx).col183 := a240(indx);
          t(ddindx).col184 := a241(indx);
          t(ddindx).col185 := a242(indx);
          t(ddindx).col186 := a243(indx);
          t(ddindx).col187 := a244(indx);
          t(ddindx).col188 := a245(indx);
          t(ddindx).col189 := a246(indx);
          t(ddindx).col190 := a247(indx);
          t(ddindx).col191 := a248(indx);
          t(ddindx).col192 := a249(indx);
          t(ddindx).col193 := a250(indx);
          t(ddindx).col194 := a251(indx);
          t(ddindx).col195 := a252(indx);
          t(ddindx).col196 := a253(indx);
          t(ddindx).col197 := a254(indx);
          t(ddindx).col198 := a255(indx);
          t(ddindx).col199 := a256(indx);
          t(ddindx).col200 := a257(indx);
          t(ddindx).col201 := a258(indx);
          t(ddindx).col202 := a259(indx);
          t(ddindx).col203 := a260(indx);
          t(ddindx).col204 := a261(indx);
          t(ddindx).col205 := a262(indx);
          t(ddindx).col206 := a263(indx);
          t(ddindx).col207 := a264(indx);
          t(ddindx).col208 := a265(indx);
          t(ddindx).col209 := a266(indx);
          t(ddindx).col210 := a267(indx);
          t(ddindx).col211 := a268(indx);
          t(ddindx).col212 := a269(indx);
          t(ddindx).col213 := a270(indx);
          t(ddindx).col214 := a271(indx);
          t(ddindx).col215 := a272(indx);
          t(ddindx).col216 := a273(indx);
          t(ddindx).col217 := a274(indx);
          t(ddindx).col218 := a275(indx);
          t(ddindx).col219 := a276(indx);
          t(ddindx).col220 := a277(indx);
          t(ddindx).col221 := a278(indx);
          t(ddindx).col222 := a279(indx);
          t(ddindx).col223 := a280(indx);
          t(ddindx).col224 := a281(indx);
          t(ddindx).col225 := a282(indx);
          t(ddindx).col226 := a283(indx);
          t(ddindx).col227 := a284(indx);
          t(ddindx).col228 := a285(indx);
          t(ddindx).col229 := a286(indx);
          t(ddindx).col230 := a287(indx);
          t(ddindx).col231 := a288(indx);
          t(ddindx).col232 := a289(indx);
          t(ddindx).col233 := a290(indx);
          t(ddindx).col234 := a291(indx);
          t(ddindx).col235 := a292(indx);
          t(ddindx).col236 := a293(indx);
          t(ddindx).col237 := a294(indx);
          t(ddindx).col238 := a295(indx);
          t(ddindx).col239 := a296(indx);
          t(ddindx).col240 := a297(indx);
          t(ddindx).col241 := a298(indx);
          t(ddindx).col242 := a299(indx);
          t(ddindx).col243 := a300(indx);
          t(ddindx).col244 := a301(indx);
          t(ddindx).col245 := a302(indx);
          t(ddindx).col246 := a303(indx);
          t(ddindx).col247 := a304(indx);
          t(ddindx).col248 := a305(indx);
          t(ddindx).col249 := a306(indx);
          t(ddindx).col250 := a307(indx);
          t(ddindx).col251 := a308(indx);
          t(ddindx).col252 := a309(indx);
          t(ddindx).col253 := a310(indx);
          t(ddindx).col254 := a311(indx);
          t(ddindx).col255 := a312(indx);
          t(ddindx).col256 := a313(indx);
          t(ddindx).col257 := a314(indx);
          t(ddindx).col258 := a315(indx);
          t(ddindx).col259 := a316(indx);
          t(ddindx).col260 := a317(indx);
          t(ddindx).col261 := a318(indx);
          t(ddindx).col262 := a319(indx);
          t(ddindx).col263 := a320(indx);
          t(ddindx).col264 := a321(indx);
          t(ddindx).col265 := a322(indx);
          t(ddindx).col266 := a323(indx);
          t(ddindx).col267 := a324(indx);
          t(ddindx).col268 := a325(indx);
          t(ddindx).col269 := a326(indx);
          t(ddindx).col270 := a327(indx);
          t(ddindx).col271 := a328(indx);
          t(ddindx).col272 := a329(indx);
          t(ddindx).col273 := a330(indx);
          t(ddindx).col274 := a331(indx);
          t(ddindx).col275 := a332(indx);
          t(ddindx).col276 := a333(indx);
          t(ddindx).col277 := a334(indx);
          t(ddindx).col278 := a335(indx);
          t(ddindx).col279 := a336(indx);
          t(ddindx).col280 := a337(indx);
          t(ddindx).col281 := a338(indx);
          t(ddindx).col282 := a339(indx);
          t(ddindx).col283 := a340(indx);
          t(ddindx).col284 := a341(indx);
          t(ddindx).col285 := a342(indx);
          t(ddindx).col286 := a343(indx);
          t(ddindx).col287 := a344(indx);
          t(ddindx).col288 := a345(indx);
          t(ddindx).col289 := a346(indx);
          t(ddindx).col290 := a347(indx);
          t(ddindx).col291 := a348(indx);
          t(ddindx).col292 := a349(indx);
          t(ddindx).col293 := a350(indx);
          t(ddindx).col294 := a351(indx);
          t(ddindx).col295 := a352(indx);
          t(ddindx).col296 := a353(indx);
          t(ddindx).col297 := a354(indx);
          t(ddindx).col298 := a355(indx);
          t(ddindx).col299 := a356(indx);
          t(ddindx).col300 := a357(indx);
          t(ddindx).curr_cp_country_code := a358(indx);
          t(ddindx).curr_cp_phone_number := a359(indx);
          t(ddindx).curr_cp_raw_phone_number := a360(indx);
          t(ddindx).curr_cp_area_code := rosetta_g_miss_num_map(a361(indx));
          t(ddindx).curr_cp_id := rosetta_g_miss_num_map(a362(indx));
          t(ddindx).curr_cp_index := rosetta_g_miss_num_map(a363(indx));
          t(ddindx).curr_cp_time_zone := rosetta_g_miss_num_map(a364(indx));
          t(ddindx).curr_cp_time_zone_aux := rosetta_g_miss_num_map(a365(indx));
          t(ddindx).party_id := rosetta_g_miss_num_map(a366(indx));
          t(ddindx).parent_party_id := rosetta_g_miss_num_map(a367(indx));
          t(ddindx).imp_source_line_id := rosetta_g_miss_num_map(a368(indx));
          t(ddindx).usage_restriction := a369(indx);
          t(ddindx).next_call_time := rosetta_g_miss_date_in_map(a370(indx));
          t(ddindx).callback_flag := a371(indx);
          t(ddindx).do_not_use_flag := a372(indx);
          t(ddindx).do_not_use_reason := a373(indx);
          t(ddindx).record_out_flag := a374(indx);
          t(ddindx).record_release_time := rosetta_g_miss_date_in_map(a375(indx));
          t(ddindx).group_code := a376(indx);
          t(ddindx).newly_updated_flag := a377(indx);
          t(ddindx).outcome_id := rosetta_g_miss_num_map(a378(indx));
          t(ddindx).result_id := rosetta_g_miss_num_map(a379(indx));
          t(ddindx).reason_id := rosetta_g_miss_num_map(a380(indx));
          t(ddindx).notes := a381(indx);
          t(ddindx).vehicle_response_code := a382(indx);
          t(ddindx).sales_agent_email_address := a383(indx);
          t(ddindx).resource_id := rosetta_g_miss_num_map(a384(indx));
          t(ddindx).location_id := rosetta_g_miss_num_map(a385(indx));
          t(ddindx).contact_point_id := rosetta_g_miss_num_map(a386(indx));
          t(ddindx).last_contacted_date := rosetta_g_miss_date_in_map(a387(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_list_entries_pvt.list_entries_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_DATE_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a19 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a20 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a21 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a22 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a23 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a24 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a25 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a26 OUT NOCOPY JTF_NUMBER_TABLE
    , a27 OUT NOCOPY JTF_NUMBER_TABLE
    , a28 OUT NOCOPY JTF_NUMBER_TABLE
    , a29 OUT NOCOPY JTF_NUMBER_TABLE
    , a30 OUT NOCOPY JTF_NUMBER_TABLE
    , a31 OUT NOCOPY JTF_NUMBER_TABLE
    , a32 OUT NOCOPY JTF_NUMBER_TABLE
    , a33 OUT NOCOPY JTF_NUMBER_TABLE
    , a34 OUT NOCOPY JTF_NUMBER_TABLE
    , a35 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a36 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a37 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a38 OUT NOCOPY JTF_NUMBER_TABLE
    , a39 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a40 OUT NOCOPY JTF_NUMBER_TABLE
    , a41 OUT NOCOPY JTF_NUMBER_TABLE
    , a42 OUT NOCOPY JTF_NUMBER_TABLE
    , a43 OUT NOCOPY JTF_NUMBER_TABLE
    , a44 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a45 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a46 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a47 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a48 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a49 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a50 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a51 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a52 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a53 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a54 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a55 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a56 OUT NOCOPY JTF_VARCHAR2_TABLE_200
    , a57 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a58 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a59 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a60 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a61 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a62 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a63 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a64 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a65 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a66 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a67 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a68 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a69 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a70 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a71 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a72 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a73 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a74 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a75 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a76 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a77 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a78 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a79 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a80 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a81 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a82 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a83 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a84 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a85 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a86 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a87 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a88 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a89 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a90 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a91 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a92 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a93 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a94 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a95 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a96 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a97 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a98 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a99 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a100 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a101 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a102 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a103 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a104 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a105 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a106 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a107 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a108 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a109 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a110 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a111 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a112 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a113 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a114 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a115 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a116 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a117 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a118 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a119 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a120 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a121 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a122 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a123 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a124 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a125 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a126 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a127 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a128 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a129 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a130 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a131 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a132 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a133 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a134 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a135 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a136 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a137 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a138 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a139 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a140 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a141 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a142 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a143 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a144 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a145 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a146 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a147 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a148 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a149 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a150 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a151 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a152 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a153 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a154 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a155 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a156 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a157 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a158 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a159 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a160 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a161 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a162 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a163 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a164 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a165 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a166 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a167 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a168 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a169 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a170 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a171 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a172 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a173 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a174 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a175 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a176 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a177 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a178 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a179 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a180 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a181 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a182 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a183 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a184 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a185 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a186 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a187 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a188 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a189 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a190 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a191 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a192 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a193 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a194 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a195 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a196 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a197 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a198 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a199 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a200 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a201 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a202 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a203 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a204 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a205 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a206 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a207 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a208 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a209 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a210 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a211 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a212 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a213 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a214 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a215 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a216 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a217 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a218 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a219 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a220 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a221 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a222 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a223 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a224 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a225 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a226 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a227 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a228 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a229 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a230 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a231 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a232 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a233 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a234 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a235 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a236 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a237 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a238 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a239 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a240 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a241 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a242 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a243 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a244 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a245 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a246 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a247 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a248 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a249 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a250 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a251 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a252 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a253 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a254 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a255 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a256 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a257 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a258 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a259 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a260 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a261 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a262 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a263 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a264 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a265 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a266 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a267 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a268 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a269 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a270 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a271 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a272 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a273 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a274 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a275 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a276 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a277 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a278 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a279 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a280 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a281 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a282 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a283 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a284 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a285 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a286 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a287 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a288 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a289 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a290 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a291 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a292 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a293 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a294 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a295 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a296 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a297 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a298 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a299 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a300 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a301 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a302 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a303 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a304 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a305 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a306 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a307 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a308 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a309 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a310 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a311 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a312 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a313 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a314 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a315 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a316 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a317 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a318 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a319 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a320 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a321 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a322 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a323 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a324 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a325 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a326 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a327 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a328 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a329 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a330 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a331 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a332 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a333 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a334 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a335 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a336 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a337 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a338 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a339 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a340 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a341 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a342 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a343 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a344 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a345 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a346 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a347 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a348 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a349 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a350 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a351 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a352 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a353 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a354 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a355 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a356 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a357 OUT NOCOPY JTF_VARCHAR2_TABLE_500
    , a358 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a359 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a360 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a361 OUT NOCOPY JTF_NUMBER_TABLE
    , a362 OUT NOCOPY JTF_NUMBER_TABLE
    , a363 OUT NOCOPY JTF_NUMBER_TABLE
    , a364 OUT NOCOPY JTF_NUMBER_TABLE
    , a365 OUT NOCOPY JTF_NUMBER_TABLE
    , a366 OUT NOCOPY JTF_NUMBER_TABLE
    , a367 OUT NOCOPY JTF_NUMBER_TABLE
    , a368 OUT NOCOPY JTF_NUMBER_TABLE
    , a369 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a370 OUT NOCOPY JTF_DATE_TABLE
    , a371 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a372 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a373 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a374 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a375 OUT NOCOPY JTF_DATE_TABLE
    , a376 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a377 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a378 OUT NOCOPY JTF_NUMBER_TABLE
    , a379 OUT NOCOPY JTF_NUMBER_TABLE
    , a380 OUT NOCOPY JTF_NUMBER_TABLE
    , a381 OUT NOCOPY JTF_VARCHAR2_TABLE_4000
    , a382 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a383 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a384 OUT NOCOPY JTF_NUMBER_TABLE
    , a385 OUT NOCOPY JTF_NUMBER_TABLE
    , a386 OUT NOCOPY JTF_NUMBER_TABLE
    , a387 OUT NOCOPY JTF_DATE_TABLE
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
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_VARCHAR2_TABLE_100();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_NUMBER_TABLE();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_NUMBER_TABLE();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_VARCHAR2_TABLE_100();
    a45 := JTF_VARCHAR2_TABLE_200();
    a46 := JTF_VARCHAR2_TABLE_200();
    a47 := JTF_VARCHAR2_TABLE_500();
    a48 := JTF_VARCHAR2_TABLE_200();
    a49 := JTF_VARCHAR2_TABLE_500();
    a50 := JTF_VARCHAR2_TABLE_500();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_VARCHAR2_TABLE_100();
    a55 := JTF_VARCHAR2_TABLE_200();
    a56 := JTF_VARCHAR2_TABLE_200();
    a57 := JTF_VARCHAR2_TABLE_500();
    a58 := JTF_VARCHAR2_TABLE_500();
    a59 := JTF_VARCHAR2_TABLE_500();
    a60 := JTF_VARCHAR2_TABLE_500();
    a61 := JTF_VARCHAR2_TABLE_500();
    a62 := JTF_VARCHAR2_TABLE_500();
    a63 := JTF_VARCHAR2_TABLE_500();
    a64 := JTF_VARCHAR2_TABLE_500();
    a65 := JTF_VARCHAR2_TABLE_500();
    a66 := JTF_VARCHAR2_TABLE_500();
    a67 := JTF_VARCHAR2_TABLE_500();
    a68 := JTF_VARCHAR2_TABLE_500();
    a69 := JTF_VARCHAR2_TABLE_500();
    a70 := JTF_VARCHAR2_TABLE_500();
    a71 := JTF_VARCHAR2_TABLE_500();
    a72 := JTF_VARCHAR2_TABLE_500();
    a73 := JTF_VARCHAR2_TABLE_500();
    a74 := JTF_VARCHAR2_TABLE_500();
    a75 := JTF_VARCHAR2_TABLE_500();
    a76 := JTF_VARCHAR2_TABLE_500();
    a77 := JTF_VARCHAR2_TABLE_500();
    a78 := JTF_VARCHAR2_TABLE_500();
    a79 := JTF_VARCHAR2_TABLE_500();
    a80 := JTF_VARCHAR2_TABLE_500();
    a81 := JTF_VARCHAR2_TABLE_500();
    a82 := JTF_VARCHAR2_TABLE_500();
    a83 := JTF_VARCHAR2_TABLE_500();
    a84 := JTF_VARCHAR2_TABLE_500();
    a85 := JTF_VARCHAR2_TABLE_500();
    a86 := JTF_VARCHAR2_TABLE_500();
    a87 := JTF_VARCHAR2_TABLE_500();
    a88 := JTF_VARCHAR2_TABLE_500();
    a89 := JTF_VARCHAR2_TABLE_500();
    a90 := JTF_VARCHAR2_TABLE_500();
    a91 := JTF_VARCHAR2_TABLE_500();
    a92 := JTF_VARCHAR2_TABLE_500();
    a93 := JTF_VARCHAR2_TABLE_500();
    a94 := JTF_VARCHAR2_TABLE_500();
    a95 := JTF_VARCHAR2_TABLE_500();
    a96 := JTF_VARCHAR2_TABLE_500();
    a97 := JTF_VARCHAR2_TABLE_500();
    a98 := JTF_VARCHAR2_TABLE_500();
    a99 := JTF_VARCHAR2_TABLE_500();
    a100 := JTF_VARCHAR2_TABLE_500();
    a101 := JTF_VARCHAR2_TABLE_500();
    a102 := JTF_VARCHAR2_TABLE_500();
    a103 := JTF_VARCHAR2_TABLE_500();
    a104 := JTF_VARCHAR2_TABLE_500();
    a105 := JTF_VARCHAR2_TABLE_500();
    a106 := JTF_VARCHAR2_TABLE_500();
    a107 := JTF_VARCHAR2_TABLE_500();
    a108 := JTF_VARCHAR2_TABLE_500();
    a109 := JTF_VARCHAR2_TABLE_500();
    a110 := JTF_VARCHAR2_TABLE_500();
    a111 := JTF_VARCHAR2_TABLE_500();
    a112 := JTF_VARCHAR2_TABLE_500();
    a113 := JTF_VARCHAR2_TABLE_500();
    a114 := JTF_VARCHAR2_TABLE_500();
    a115 := JTF_VARCHAR2_TABLE_500();
    a116 := JTF_VARCHAR2_TABLE_500();
    a117 := JTF_VARCHAR2_TABLE_500();
    a118 := JTF_VARCHAR2_TABLE_500();
    a119 := JTF_VARCHAR2_TABLE_500();
    a120 := JTF_VARCHAR2_TABLE_500();
    a121 := JTF_VARCHAR2_TABLE_500();
    a122 := JTF_VARCHAR2_TABLE_500();
    a123 := JTF_VARCHAR2_TABLE_500();
    a124 := JTF_VARCHAR2_TABLE_500();
    a125 := JTF_VARCHAR2_TABLE_500();
    a126 := JTF_VARCHAR2_TABLE_500();
    a127 := JTF_VARCHAR2_TABLE_500();
    a128 := JTF_VARCHAR2_TABLE_500();
    a129 := JTF_VARCHAR2_TABLE_500();
    a130 := JTF_VARCHAR2_TABLE_500();
    a131 := JTF_VARCHAR2_TABLE_500();
    a132 := JTF_VARCHAR2_TABLE_500();
    a133 := JTF_VARCHAR2_TABLE_500();
    a134 := JTF_VARCHAR2_TABLE_500();
    a135 := JTF_VARCHAR2_TABLE_500();
    a136 := JTF_VARCHAR2_TABLE_500();
    a137 := JTF_VARCHAR2_TABLE_500();
    a138 := JTF_VARCHAR2_TABLE_500();
    a139 := JTF_VARCHAR2_TABLE_500();
    a140 := JTF_VARCHAR2_TABLE_500();
    a141 := JTF_VARCHAR2_TABLE_500();
    a142 := JTF_VARCHAR2_TABLE_500();
    a143 := JTF_VARCHAR2_TABLE_500();
    a144 := JTF_VARCHAR2_TABLE_500();
    a145 := JTF_VARCHAR2_TABLE_500();
    a146 := JTF_VARCHAR2_TABLE_500();
    a147 := JTF_VARCHAR2_TABLE_500();
    a148 := JTF_VARCHAR2_TABLE_500();
    a149 := JTF_VARCHAR2_TABLE_500();
    a150 := JTF_VARCHAR2_TABLE_500();
    a151 := JTF_VARCHAR2_TABLE_500();
    a152 := JTF_VARCHAR2_TABLE_500();
    a153 := JTF_VARCHAR2_TABLE_500();
    a154 := JTF_VARCHAR2_TABLE_500();
    a155 := JTF_VARCHAR2_TABLE_500();
    a156 := JTF_VARCHAR2_TABLE_500();
    a157 := JTF_VARCHAR2_TABLE_500();
    a158 := JTF_VARCHAR2_TABLE_500();
    a159 := JTF_VARCHAR2_TABLE_500();
    a160 := JTF_VARCHAR2_TABLE_500();
    a161 := JTF_VARCHAR2_TABLE_500();
    a162 := JTF_VARCHAR2_TABLE_500();
    a163 := JTF_VARCHAR2_TABLE_500();
    a164 := JTF_VARCHAR2_TABLE_500();
    a165 := JTF_VARCHAR2_TABLE_500();
    a166 := JTF_VARCHAR2_TABLE_500();
    a167 := JTF_VARCHAR2_TABLE_500();
    a168 := JTF_VARCHAR2_TABLE_500();
    a169 := JTF_VARCHAR2_TABLE_500();
    a170 := JTF_VARCHAR2_TABLE_500();
    a171 := JTF_VARCHAR2_TABLE_500();
    a172 := JTF_VARCHAR2_TABLE_500();
    a173 := JTF_VARCHAR2_TABLE_500();
    a174 := JTF_VARCHAR2_TABLE_500();
    a175 := JTF_VARCHAR2_TABLE_500();
    a176 := JTF_VARCHAR2_TABLE_500();
    a177 := JTF_VARCHAR2_TABLE_500();
    a178 := JTF_VARCHAR2_TABLE_500();
    a179 := JTF_VARCHAR2_TABLE_500();
    a180 := JTF_VARCHAR2_TABLE_500();
    a181 := JTF_VARCHAR2_TABLE_500();
    a182 := JTF_VARCHAR2_TABLE_500();
    a183 := JTF_VARCHAR2_TABLE_500();
    a184 := JTF_VARCHAR2_TABLE_500();
    a185 := JTF_VARCHAR2_TABLE_500();
    a186 := JTF_VARCHAR2_TABLE_500();
    a187 := JTF_VARCHAR2_TABLE_500();
    a188 := JTF_VARCHAR2_TABLE_500();
    a189 := JTF_VARCHAR2_TABLE_500();
    a190 := JTF_VARCHAR2_TABLE_500();
    a191 := JTF_VARCHAR2_TABLE_500();
    a192 := JTF_VARCHAR2_TABLE_500();
    a193 := JTF_VARCHAR2_TABLE_500();
    a194 := JTF_VARCHAR2_TABLE_500();
    a195 := JTF_VARCHAR2_TABLE_500();
    a196 := JTF_VARCHAR2_TABLE_500();
    a197 := JTF_VARCHAR2_TABLE_500();
    a198 := JTF_VARCHAR2_TABLE_500();
    a199 := JTF_VARCHAR2_TABLE_500();
    a200 := JTF_VARCHAR2_TABLE_500();
    a201 := JTF_VARCHAR2_TABLE_500();
    a202 := JTF_VARCHAR2_TABLE_500();
    a203 := JTF_VARCHAR2_TABLE_500();
    a204 := JTF_VARCHAR2_TABLE_500();
    a205 := JTF_VARCHAR2_TABLE_500();
    a206 := JTF_VARCHAR2_TABLE_500();
    a207 := JTF_VARCHAR2_TABLE_500();
    a208 := JTF_VARCHAR2_TABLE_500();
    a209 := JTF_VARCHAR2_TABLE_500();
    a210 := JTF_VARCHAR2_TABLE_500();
    a211 := JTF_VARCHAR2_TABLE_500();
    a212 := JTF_VARCHAR2_TABLE_500();
    a213 := JTF_VARCHAR2_TABLE_500();
    a214 := JTF_VARCHAR2_TABLE_500();
    a215 := JTF_VARCHAR2_TABLE_500();
    a216 := JTF_VARCHAR2_TABLE_500();
    a217 := JTF_VARCHAR2_TABLE_500();
    a218 := JTF_VARCHAR2_TABLE_500();
    a219 := JTF_VARCHAR2_TABLE_500();
    a220 := JTF_VARCHAR2_TABLE_500();
    a221 := JTF_VARCHAR2_TABLE_500();
    a222 := JTF_VARCHAR2_TABLE_500();
    a223 := JTF_VARCHAR2_TABLE_500();
    a224 := JTF_VARCHAR2_TABLE_500();
    a225 := JTF_VARCHAR2_TABLE_500();
    a226 := JTF_VARCHAR2_TABLE_500();
    a227 := JTF_VARCHAR2_TABLE_500();
    a228 := JTF_VARCHAR2_TABLE_500();
    a229 := JTF_VARCHAR2_TABLE_500();
    a230 := JTF_VARCHAR2_TABLE_500();
    a231 := JTF_VARCHAR2_TABLE_500();
    a232 := JTF_VARCHAR2_TABLE_500();
    a233 := JTF_VARCHAR2_TABLE_500();
    a234 := JTF_VARCHAR2_TABLE_500();
    a235 := JTF_VARCHAR2_TABLE_500();
    a236 := JTF_VARCHAR2_TABLE_500();
    a237 := JTF_VARCHAR2_TABLE_500();
    a238 := JTF_VARCHAR2_TABLE_500();
    a239 := JTF_VARCHAR2_TABLE_500();
    a240 := JTF_VARCHAR2_TABLE_500();
    a241 := JTF_VARCHAR2_TABLE_500();
    a242 := JTF_VARCHAR2_TABLE_500();
    a243 := JTF_VARCHAR2_TABLE_500();
    a244 := JTF_VARCHAR2_TABLE_500();
    a245 := JTF_VARCHAR2_TABLE_500();
    a246 := JTF_VARCHAR2_TABLE_500();
    a247 := JTF_VARCHAR2_TABLE_500();
    a248 := JTF_VARCHAR2_TABLE_500();
    a249 := JTF_VARCHAR2_TABLE_500();
    a250 := JTF_VARCHAR2_TABLE_500();
    a251 := JTF_VARCHAR2_TABLE_500();
    a252 := JTF_VARCHAR2_TABLE_500();
    a253 := JTF_VARCHAR2_TABLE_500();
    a254 := JTF_VARCHAR2_TABLE_500();
    a255 := JTF_VARCHAR2_TABLE_500();
    a256 := JTF_VARCHAR2_TABLE_500();
    a257 := JTF_VARCHAR2_TABLE_500();
    a258 := JTF_VARCHAR2_TABLE_500();
    a259 := JTF_VARCHAR2_TABLE_500();
    a260 := JTF_VARCHAR2_TABLE_500();
    a261 := JTF_VARCHAR2_TABLE_500();
    a262 := JTF_VARCHAR2_TABLE_500();
    a263 := JTF_VARCHAR2_TABLE_500();
    a264 := JTF_VARCHAR2_TABLE_500();
    a265 := JTF_VARCHAR2_TABLE_500();
    a266 := JTF_VARCHAR2_TABLE_500();
    a267 := JTF_VARCHAR2_TABLE_500();
    a268 := JTF_VARCHAR2_TABLE_500();
    a269 := JTF_VARCHAR2_TABLE_500();
    a270 := JTF_VARCHAR2_TABLE_500();
    a271 := JTF_VARCHAR2_TABLE_500();
    a272 := JTF_VARCHAR2_TABLE_500();
    a273 := JTF_VARCHAR2_TABLE_500();
    a274 := JTF_VARCHAR2_TABLE_500();
    a275 := JTF_VARCHAR2_TABLE_500();
    a276 := JTF_VARCHAR2_TABLE_500();
    a277 := JTF_VARCHAR2_TABLE_500();
    a278 := JTF_VARCHAR2_TABLE_500();
    a279 := JTF_VARCHAR2_TABLE_500();
    a280 := JTF_VARCHAR2_TABLE_500();
    a281 := JTF_VARCHAR2_TABLE_500();
    a282 := JTF_VARCHAR2_TABLE_500();
    a283 := JTF_VARCHAR2_TABLE_500();
    a284 := JTF_VARCHAR2_TABLE_500();
    a285 := JTF_VARCHAR2_TABLE_500();
    a286 := JTF_VARCHAR2_TABLE_500();
    a287 := JTF_VARCHAR2_TABLE_500();
    a288 := JTF_VARCHAR2_TABLE_500();
    a289 := JTF_VARCHAR2_TABLE_500();
    a290 := JTF_VARCHAR2_TABLE_500();
    a291 := JTF_VARCHAR2_TABLE_500();
    a292 := JTF_VARCHAR2_TABLE_500();
    a293 := JTF_VARCHAR2_TABLE_500();
    a294 := JTF_VARCHAR2_TABLE_500();
    a295 := JTF_VARCHAR2_TABLE_500();
    a296 := JTF_VARCHAR2_TABLE_500();
    a297 := JTF_VARCHAR2_TABLE_500();
    a298 := JTF_VARCHAR2_TABLE_4000();
    a299 := JTF_VARCHAR2_TABLE_4000();
    a300 := JTF_VARCHAR2_TABLE_4000();
    a301 := JTF_VARCHAR2_TABLE_4000();
    a302 := JTF_VARCHAR2_TABLE_4000();
    a303 := JTF_VARCHAR2_TABLE_4000();
    a304 := JTF_VARCHAR2_TABLE_4000();
    a305 := JTF_VARCHAR2_TABLE_4000();
    a306 := JTF_VARCHAR2_TABLE_4000();
    a307 := JTF_VARCHAR2_TABLE_4000();
    a308 := JTF_VARCHAR2_TABLE_500();
    a309 := JTF_VARCHAR2_TABLE_500();
    a310 := JTF_VARCHAR2_TABLE_500();
    a311 := JTF_VARCHAR2_TABLE_500();
    a312 := JTF_VARCHAR2_TABLE_500();
    a313 := JTF_VARCHAR2_TABLE_500();
    a314 := JTF_VARCHAR2_TABLE_500();
    a315 := JTF_VARCHAR2_TABLE_500();
    a316 := JTF_VARCHAR2_TABLE_500();
    a317 := JTF_VARCHAR2_TABLE_500();
    a318 := JTF_VARCHAR2_TABLE_500();
    a319 := JTF_VARCHAR2_TABLE_500();
    a320 := JTF_VARCHAR2_TABLE_500();
    a321 := JTF_VARCHAR2_TABLE_500();
    a322 := JTF_VARCHAR2_TABLE_500();
    a323 := JTF_VARCHAR2_TABLE_500();
    a324 := JTF_VARCHAR2_TABLE_500();
    a325 := JTF_VARCHAR2_TABLE_500();
    a326 := JTF_VARCHAR2_TABLE_500();
    a327 := JTF_VARCHAR2_TABLE_500();
    a328 := JTF_VARCHAR2_TABLE_500();
    a329 := JTF_VARCHAR2_TABLE_500();
    a330 := JTF_VARCHAR2_TABLE_500();
    a331 := JTF_VARCHAR2_TABLE_500();
    a332 := JTF_VARCHAR2_TABLE_500();
    a333 := JTF_VARCHAR2_TABLE_500();
    a334 := JTF_VARCHAR2_TABLE_500();
    a335 := JTF_VARCHAR2_TABLE_500();
    a336 := JTF_VARCHAR2_TABLE_500();
    a337 := JTF_VARCHAR2_TABLE_500();
    a338 := JTF_VARCHAR2_TABLE_500();
    a339 := JTF_VARCHAR2_TABLE_500();
    a340 := JTF_VARCHAR2_TABLE_500();
    a341 := JTF_VARCHAR2_TABLE_500();
    a342 := JTF_VARCHAR2_TABLE_500();
    a343 := JTF_VARCHAR2_TABLE_500();
    a344 := JTF_VARCHAR2_TABLE_500();
    a345 := JTF_VARCHAR2_TABLE_500();
    a346 := JTF_VARCHAR2_TABLE_500();
    a347 := JTF_VARCHAR2_TABLE_500();
    a348 := JTF_VARCHAR2_TABLE_500();
    a349 := JTF_VARCHAR2_TABLE_500();
    a350 := JTF_VARCHAR2_TABLE_500();
    a351 := JTF_VARCHAR2_TABLE_500();
    a352 := JTF_VARCHAR2_TABLE_500();
    a353 := JTF_VARCHAR2_TABLE_500();
    a354 := JTF_VARCHAR2_TABLE_500();
    a355 := JTF_VARCHAR2_TABLE_500();
    a356 := JTF_VARCHAR2_TABLE_500();
    a357 := JTF_VARCHAR2_TABLE_500();
    a358 := JTF_VARCHAR2_TABLE_100();
    a359 := JTF_VARCHAR2_TABLE_100();
    a360 := JTF_VARCHAR2_TABLE_100();
    a361 := JTF_NUMBER_TABLE();
    a362 := JTF_NUMBER_TABLE();
    a363 := JTF_NUMBER_TABLE();
    a364 := JTF_NUMBER_TABLE();
    a365 := JTF_NUMBER_TABLE();
    a366 := JTF_NUMBER_TABLE();
    a367 := JTF_NUMBER_TABLE();
    a368 := JTF_NUMBER_TABLE();
    a369 := JTF_VARCHAR2_TABLE_100();
    a370 := JTF_DATE_TABLE();
    a371 := JTF_VARCHAR2_TABLE_100();
    a372 := JTF_VARCHAR2_TABLE_100();
    a373 := JTF_VARCHAR2_TABLE_100();
    a374 := JTF_VARCHAR2_TABLE_100();
    a375 := JTF_DATE_TABLE();
    a376 := JTF_VARCHAR2_TABLE_100();
    a377 := JTF_VARCHAR2_TABLE_100();
    a378 := JTF_NUMBER_TABLE();
    a379 := JTF_NUMBER_TABLE();
    a380 := JTF_NUMBER_TABLE();
    a381 := JTF_VARCHAR2_TABLE_4000();
    a382 := JTF_VARCHAR2_TABLE_100();
    a383 := JTF_VARCHAR2_TABLE_2000();
    a384 := JTF_NUMBER_TABLE();
    a385 := JTF_NUMBER_TABLE();
    a386 := JTF_NUMBER_TABLE();
    a387 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_VARCHAR2_TABLE_100();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_NUMBER_TABLE();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_NUMBER_TABLE();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_VARCHAR2_TABLE_100();
      a45 := JTF_VARCHAR2_TABLE_200();
      a46 := JTF_VARCHAR2_TABLE_200();
      a47 := JTF_VARCHAR2_TABLE_500();
      a48 := JTF_VARCHAR2_TABLE_200();
      a49 := JTF_VARCHAR2_TABLE_500();
      a50 := JTF_VARCHAR2_TABLE_500();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_VARCHAR2_TABLE_100();
      a55 := JTF_VARCHAR2_TABLE_200();
      a56 := JTF_VARCHAR2_TABLE_200();
      a57 := JTF_VARCHAR2_TABLE_500();
      a58 := JTF_VARCHAR2_TABLE_500();
      a59 := JTF_VARCHAR2_TABLE_500();
      a60 := JTF_VARCHAR2_TABLE_500();
      a61 := JTF_VARCHAR2_TABLE_500();
      a62 := JTF_VARCHAR2_TABLE_500();
      a63 := JTF_VARCHAR2_TABLE_500();
      a64 := JTF_VARCHAR2_TABLE_500();
      a65 := JTF_VARCHAR2_TABLE_500();
      a66 := JTF_VARCHAR2_TABLE_500();
      a67 := JTF_VARCHAR2_TABLE_500();
      a68 := JTF_VARCHAR2_TABLE_500();
      a69 := JTF_VARCHAR2_TABLE_500();
      a70 := JTF_VARCHAR2_TABLE_500();
      a71 := JTF_VARCHAR2_TABLE_500();
      a72 := JTF_VARCHAR2_TABLE_500();
      a73 := JTF_VARCHAR2_TABLE_500();
      a74 := JTF_VARCHAR2_TABLE_500();
      a75 := JTF_VARCHAR2_TABLE_500();
      a76 := JTF_VARCHAR2_TABLE_500();
      a77 := JTF_VARCHAR2_TABLE_500();
      a78 := JTF_VARCHAR2_TABLE_500();
      a79 := JTF_VARCHAR2_TABLE_500();
      a80 := JTF_VARCHAR2_TABLE_500();
      a81 := JTF_VARCHAR2_TABLE_500();
      a82 := JTF_VARCHAR2_TABLE_500();
      a83 := JTF_VARCHAR2_TABLE_500();
      a84 := JTF_VARCHAR2_TABLE_500();
      a85 := JTF_VARCHAR2_TABLE_500();
      a86 := JTF_VARCHAR2_TABLE_500();
      a87 := JTF_VARCHAR2_TABLE_500();
      a88 := JTF_VARCHAR2_TABLE_500();
      a89 := JTF_VARCHAR2_TABLE_500();
      a90 := JTF_VARCHAR2_TABLE_500();
      a91 := JTF_VARCHAR2_TABLE_500();
      a92 := JTF_VARCHAR2_TABLE_500();
      a93 := JTF_VARCHAR2_TABLE_500();
      a94 := JTF_VARCHAR2_TABLE_500();
      a95 := JTF_VARCHAR2_TABLE_500();
      a96 := JTF_VARCHAR2_TABLE_500();
      a97 := JTF_VARCHAR2_TABLE_500();
      a98 := JTF_VARCHAR2_TABLE_500();
      a99 := JTF_VARCHAR2_TABLE_500();
      a100 := JTF_VARCHAR2_TABLE_500();
      a101 := JTF_VARCHAR2_TABLE_500();
      a102 := JTF_VARCHAR2_TABLE_500();
      a103 := JTF_VARCHAR2_TABLE_500();
      a104 := JTF_VARCHAR2_TABLE_500();
      a105 := JTF_VARCHAR2_TABLE_500();
      a106 := JTF_VARCHAR2_TABLE_500();
      a107 := JTF_VARCHAR2_TABLE_500();
      a108 := JTF_VARCHAR2_TABLE_500();
      a109 := JTF_VARCHAR2_TABLE_500();
      a110 := JTF_VARCHAR2_TABLE_500();
      a111 := JTF_VARCHAR2_TABLE_500();
      a112 := JTF_VARCHAR2_TABLE_500();
      a113 := JTF_VARCHAR2_TABLE_500();
      a114 := JTF_VARCHAR2_TABLE_500();
      a115 := JTF_VARCHAR2_TABLE_500();
      a116 := JTF_VARCHAR2_TABLE_500();
      a117 := JTF_VARCHAR2_TABLE_500();
      a118 := JTF_VARCHAR2_TABLE_500();
      a119 := JTF_VARCHAR2_TABLE_500();
      a120 := JTF_VARCHAR2_TABLE_500();
      a121 := JTF_VARCHAR2_TABLE_500();
      a122 := JTF_VARCHAR2_TABLE_500();
      a123 := JTF_VARCHAR2_TABLE_500();
      a124 := JTF_VARCHAR2_TABLE_500();
      a125 := JTF_VARCHAR2_TABLE_500();
      a126 := JTF_VARCHAR2_TABLE_500();
      a127 := JTF_VARCHAR2_TABLE_500();
      a128 := JTF_VARCHAR2_TABLE_500();
      a129 := JTF_VARCHAR2_TABLE_500();
      a130 := JTF_VARCHAR2_TABLE_500();
      a131 := JTF_VARCHAR2_TABLE_500();
      a132 := JTF_VARCHAR2_TABLE_500();
      a133 := JTF_VARCHAR2_TABLE_500();
      a134 := JTF_VARCHAR2_TABLE_500();
      a135 := JTF_VARCHAR2_TABLE_500();
      a136 := JTF_VARCHAR2_TABLE_500();
      a137 := JTF_VARCHAR2_TABLE_500();
      a138 := JTF_VARCHAR2_TABLE_500();
      a139 := JTF_VARCHAR2_TABLE_500();
      a140 := JTF_VARCHAR2_TABLE_500();
      a141 := JTF_VARCHAR2_TABLE_500();
      a142 := JTF_VARCHAR2_TABLE_500();
      a143 := JTF_VARCHAR2_TABLE_500();
      a144 := JTF_VARCHAR2_TABLE_500();
      a145 := JTF_VARCHAR2_TABLE_500();
      a146 := JTF_VARCHAR2_TABLE_500();
      a147 := JTF_VARCHAR2_TABLE_500();
      a148 := JTF_VARCHAR2_TABLE_500();
      a149 := JTF_VARCHAR2_TABLE_500();
      a150 := JTF_VARCHAR2_TABLE_500();
      a151 := JTF_VARCHAR2_TABLE_500();
      a152 := JTF_VARCHAR2_TABLE_500();
      a153 := JTF_VARCHAR2_TABLE_500();
      a154 := JTF_VARCHAR2_TABLE_500();
      a155 := JTF_VARCHAR2_TABLE_500();
      a156 := JTF_VARCHAR2_TABLE_500();
      a157 := JTF_VARCHAR2_TABLE_500();
      a158 := JTF_VARCHAR2_TABLE_500();
      a159 := JTF_VARCHAR2_TABLE_500();
      a160 := JTF_VARCHAR2_TABLE_500();
      a161 := JTF_VARCHAR2_TABLE_500();
      a162 := JTF_VARCHAR2_TABLE_500();
      a163 := JTF_VARCHAR2_TABLE_500();
      a164 := JTF_VARCHAR2_TABLE_500();
      a165 := JTF_VARCHAR2_TABLE_500();
      a166 := JTF_VARCHAR2_TABLE_500();
      a167 := JTF_VARCHAR2_TABLE_500();
      a168 := JTF_VARCHAR2_TABLE_500();
      a169 := JTF_VARCHAR2_TABLE_500();
      a170 := JTF_VARCHAR2_TABLE_500();
      a171 := JTF_VARCHAR2_TABLE_500();
      a172 := JTF_VARCHAR2_TABLE_500();
      a173 := JTF_VARCHAR2_TABLE_500();
      a174 := JTF_VARCHAR2_TABLE_500();
      a175 := JTF_VARCHAR2_TABLE_500();
      a176 := JTF_VARCHAR2_TABLE_500();
      a177 := JTF_VARCHAR2_TABLE_500();
      a178 := JTF_VARCHAR2_TABLE_500();
      a179 := JTF_VARCHAR2_TABLE_500();
      a180 := JTF_VARCHAR2_TABLE_500();
      a181 := JTF_VARCHAR2_TABLE_500();
      a182 := JTF_VARCHAR2_TABLE_500();
      a183 := JTF_VARCHAR2_TABLE_500();
      a184 := JTF_VARCHAR2_TABLE_500();
      a185 := JTF_VARCHAR2_TABLE_500();
      a186 := JTF_VARCHAR2_TABLE_500();
      a187 := JTF_VARCHAR2_TABLE_500();
      a188 := JTF_VARCHAR2_TABLE_500();
      a189 := JTF_VARCHAR2_TABLE_500();
      a190 := JTF_VARCHAR2_TABLE_500();
      a191 := JTF_VARCHAR2_TABLE_500();
      a192 := JTF_VARCHAR2_TABLE_500();
      a193 := JTF_VARCHAR2_TABLE_500();
      a194 := JTF_VARCHAR2_TABLE_500();
      a195 := JTF_VARCHAR2_TABLE_500();
      a196 := JTF_VARCHAR2_TABLE_500();
      a197 := JTF_VARCHAR2_TABLE_500();
      a198 := JTF_VARCHAR2_TABLE_500();
      a199 := JTF_VARCHAR2_TABLE_500();
      a200 := JTF_VARCHAR2_TABLE_500();
      a201 := JTF_VARCHAR2_TABLE_500();
      a202 := JTF_VARCHAR2_TABLE_500();
      a203 := JTF_VARCHAR2_TABLE_500();
      a204 := JTF_VARCHAR2_TABLE_500();
      a205 := JTF_VARCHAR2_TABLE_500();
      a206 := JTF_VARCHAR2_TABLE_500();
      a207 := JTF_VARCHAR2_TABLE_500();
      a208 := JTF_VARCHAR2_TABLE_500();
      a209 := JTF_VARCHAR2_TABLE_500();
      a210 := JTF_VARCHAR2_TABLE_500();
      a211 := JTF_VARCHAR2_TABLE_500();
      a212 := JTF_VARCHAR2_TABLE_500();
      a213 := JTF_VARCHAR2_TABLE_500();
      a214 := JTF_VARCHAR2_TABLE_500();
      a215 := JTF_VARCHAR2_TABLE_500();
      a216 := JTF_VARCHAR2_TABLE_500();
      a217 := JTF_VARCHAR2_TABLE_500();
      a218 := JTF_VARCHAR2_TABLE_500();
      a219 := JTF_VARCHAR2_TABLE_500();
      a220 := JTF_VARCHAR2_TABLE_500();
      a221 := JTF_VARCHAR2_TABLE_500();
      a222 := JTF_VARCHAR2_TABLE_500();
      a223 := JTF_VARCHAR2_TABLE_500();
      a224 := JTF_VARCHAR2_TABLE_500();
      a225 := JTF_VARCHAR2_TABLE_500();
      a226 := JTF_VARCHAR2_TABLE_500();
      a227 := JTF_VARCHAR2_TABLE_500();
      a228 := JTF_VARCHAR2_TABLE_500();
      a229 := JTF_VARCHAR2_TABLE_500();
      a230 := JTF_VARCHAR2_TABLE_500();
      a231 := JTF_VARCHAR2_TABLE_500();
      a232 := JTF_VARCHAR2_TABLE_500();
      a233 := JTF_VARCHAR2_TABLE_500();
      a234 := JTF_VARCHAR2_TABLE_500();
      a235 := JTF_VARCHAR2_TABLE_500();
      a236 := JTF_VARCHAR2_TABLE_500();
      a237 := JTF_VARCHAR2_TABLE_500();
      a238 := JTF_VARCHAR2_TABLE_500();
      a239 := JTF_VARCHAR2_TABLE_500();
      a240 := JTF_VARCHAR2_TABLE_500();
      a241 := JTF_VARCHAR2_TABLE_500();
      a242 := JTF_VARCHAR2_TABLE_500();
      a243 := JTF_VARCHAR2_TABLE_500();
      a244 := JTF_VARCHAR2_TABLE_500();
      a245 := JTF_VARCHAR2_TABLE_500();
      a246 := JTF_VARCHAR2_TABLE_500();
      a247 := JTF_VARCHAR2_TABLE_500();
      a248 := JTF_VARCHAR2_TABLE_500();
      a249 := JTF_VARCHAR2_TABLE_500();
      a250 := JTF_VARCHAR2_TABLE_500();
      a251 := JTF_VARCHAR2_TABLE_500();
      a252 := JTF_VARCHAR2_TABLE_500();
      a253 := JTF_VARCHAR2_TABLE_500();
      a254 := JTF_VARCHAR2_TABLE_500();
      a255 := JTF_VARCHAR2_TABLE_500();
      a256 := JTF_VARCHAR2_TABLE_500();
      a257 := JTF_VARCHAR2_TABLE_500();
      a258 := JTF_VARCHAR2_TABLE_500();
      a259 := JTF_VARCHAR2_TABLE_500();
      a260 := JTF_VARCHAR2_TABLE_500();
      a261 := JTF_VARCHAR2_TABLE_500();
      a262 := JTF_VARCHAR2_TABLE_500();
      a263 := JTF_VARCHAR2_TABLE_500();
      a264 := JTF_VARCHAR2_TABLE_500();
      a265 := JTF_VARCHAR2_TABLE_500();
      a266 := JTF_VARCHAR2_TABLE_500();
      a267 := JTF_VARCHAR2_TABLE_500();
      a268 := JTF_VARCHAR2_TABLE_500();
      a269 := JTF_VARCHAR2_TABLE_500();
      a270 := JTF_VARCHAR2_TABLE_500();
      a271 := JTF_VARCHAR2_TABLE_500();
      a272 := JTF_VARCHAR2_TABLE_500();
      a273 := JTF_VARCHAR2_TABLE_500();
      a274 := JTF_VARCHAR2_TABLE_500();
      a275 := JTF_VARCHAR2_TABLE_500();
      a276 := JTF_VARCHAR2_TABLE_500();
      a277 := JTF_VARCHAR2_TABLE_500();
      a278 := JTF_VARCHAR2_TABLE_500();
      a279 := JTF_VARCHAR2_TABLE_500();
      a280 := JTF_VARCHAR2_TABLE_500();
      a281 := JTF_VARCHAR2_TABLE_500();
      a282 := JTF_VARCHAR2_TABLE_500();
      a283 := JTF_VARCHAR2_TABLE_500();
      a284 := JTF_VARCHAR2_TABLE_500();
      a285 := JTF_VARCHAR2_TABLE_500();
      a286 := JTF_VARCHAR2_TABLE_500();
      a287 := JTF_VARCHAR2_TABLE_500();
      a288 := JTF_VARCHAR2_TABLE_500();
      a289 := JTF_VARCHAR2_TABLE_500();
      a290 := JTF_VARCHAR2_TABLE_500();
      a291 := JTF_VARCHAR2_TABLE_500();
      a292 := JTF_VARCHAR2_TABLE_500();
      a293 := JTF_VARCHAR2_TABLE_500();
      a294 := JTF_VARCHAR2_TABLE_500();
      a295 := JTF_VARCHAR2_TABLE_500();
      a296 := JTF_VARCHAR2_TABLE_500();
      a297 := JTF_VARCHAR2_TABLE_500();
      a298 := JTF_VARCHAR2_TABLE_4000();
      a299 := JTF_VARCHAR2_TABLE_4000();
      a300 := JTF_VARCHAR2_TABLE_4000();
      a301 := JTF_VARCHAR2_TABLE_4000();
      a302 := JTF_VARCHAR2_TABLE_4000();
      a303 := JTF_VARCHAR2_TABLE_4000();
      a304 := JTF_VARCHAR2_TABLE_4000();
      a305 := JTF_VARCHAR2_TABLE_4000();
      a306 := JTF_VARCHAR2_TABLE_4000();
      a307 := JTF_VARCHAR2_TABLE_4000();
      a308 := JTF_VARCHAR2_TABLE_500();
      a309 := JTF_VARCHAR2_TABLE_500();
      a310 := JTF_VARCHAR2_TABLE_500();
      a311 := JTF_VARCHAR2_TABLE_500();
      a312 := JTF_VARCHAR2_TABLE_500();
      a313 := JTF_VARCHAR2_TABLE_500();
      a314 := JTF_VARCHAR2_TABLE_500();
      a315 := JTF_VARCHAR2_TABLE_500();
      a316 := JTF_VARCHAR2_TABLE_500();
      a317 := JTF_VARCHAR2_TABLE_500();
      a318 := JTF_VARCHAR2_TABLE_500();
      a319 := JTF_VARCHAR2_TABLE_500();
      a320 := JTF_VARCHAR2_TABLE_500();
      a321 := JTF_VARCHAR2_TABLE_500();
      a322 := JTF_VARCHAR2_TABLE_500();
      a323 := JTF_VARCHAR2_TABLE_500();
      a324 := JTF_VARCHAR2_TABLE_500();
      a325 := JTF_VARCHAR2_TABLE_500();
      a326 := JTF_VARCHAR2_TABLE_500();
      a327 := JTF_VARCHAR2_TABLE_500();
      a328 := JTF_VARCHAR2_TABLE_500();
      a329 := JTF_VARCHAR2_TABLE_500();
      a330 := JTF_VARCHAR2_TABLE_500();
      a331 := JTF_VARCHAR2_TABLE_500();
      a332 := JTF_VARCHAR2_TABLE_500();
      a333 := JTF_VARCHAR2_TABLE_500();
      a334 := JTF_VARCHAR2_TABLE_500();
      a335 := JTF_VARCHAR2_TABLE_500();
      a336 := JTF_VARCHAR2_TABLE_500();
      a337 := JTF_VARCHAR2_TABLE_500();
      a338 := JTF_VARCHAR2_TABLE_500();
      a339 := JTF_VARCHAR2_TABLE_500();
      a340 := JTF_VARCHAR2_TABLE_500();
      a341 := JTF_VARCHAR2_TABLE_500();
      a342 := JTF_VARCHAR2_TABLE_500();
      a343 := JTF_VARCHAR2_TABLE_500();
      a344 := JTF_VARCHAR2_TABLE_500();
      a345 := JTF_VARCHAR2_TABLE_500();
      a346 := JTF_VARCHAR2_TABLE_500();
      a347 := JTF_VARCHAR2_TABLE_500();
      a348 := JTF_VARCHAR2_TABLE_500();
      a349 := JTF_VARCHAR2_TABLE_500();
      a350 := JTF_VARCHAR2_TABLE_500();
      a351 := JTF_VARCHAR2_TABLE_500();
      a352 := JTF_VARCHAR2_TABLE_500();
      a353 := JTF_VARCHAR2_TABLE_500();
      a354 := JTF_VARCHAR2_TABLE_500();
      a355 := JTF_VARCHAR2_TABLE_500();
      a356 := JTF_VARCHAR2_TABLE_500();
      a357 := JTF_VARCHAR2_TABLE_500();
      a358 := JTF_VARCHAR2_TABLE_100();
      a359 := JTF_VARCHAR2_TABLE_100();
      a360 := JTF_VARCHAR2_TABLE_100();
      a361 := JTF_NUMBER_TABLE();
      a362 := JTF_NUMBER_TABLE();
      a363 := JTF_NUMBER_TABLE();
      a364 := JTF_NUMBER_TABLE();
      a365 := JTF_NUMBER_TABLE();
      a366 := JTF_NUMBER_TABLE();
      a367 := JTF_NUMBER_TABLE();
      a368 := JTF_NUMBER_TABLE();
      a369 := JTF_VARCHAR2_TABLE_100();
      a370 := JTF_DATE_TABLE();
      a371 := JTF_VARCHAR2_TABLE_100();
      a372 := JTF_VARCHAR2_TABLE_100();
      a373 := JTF_VARCHAR2_TABLE_100();
      a374 := JTF_VARCHAR2_TABLE_100();
      a375 := JTF_DATE_TABLE();
      a376 := JTF_VARCHAR2_TABLE_100();
      a377 := JTF_VARCHAR2_TABLE_100();
      a378 := JTF_NUMBER_TABLE();
      a379 := JTF_NUMBER_TABLE();
      a380 := JTF_NUMBER_TABLE();
      a381 := JTF_VARCHAR2_TABLE_4000();
      a382 := JTF_VARCHAR2_TABLE_100();
      a383 := JTF_VARCHAR2_TABLE_2000();
      a384 := JTF_NUMBER_TABLE();
      a385 := JTF_NUMBER_TABLE();
      a386 := JTF_NUMBER_TABLE();
      a387 := JTF_DATE_TABLE();
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
        a295.extend(t.count);
        a296.extend(t.count);
        a297.extend(t.count);
        a298.extend(t.count);
        a299.extend(t.count);
        a300.extend(t.count);
        a301.extend(t.count);
        a302.extend(t.count);
        a303.extend(t.count);
        a304.extend(t.count);
        a305.extend(t.count);
        a306.extend(t.count);
        a307.extend(t.count);
        a308.extend(t.count);
        a309.extend(t.count);
        a310.extend(t.count);
        a311.extend(t.count);
        a312.extend(t.count);
        a313.extend(t.count);
        a314.extend(t.count);
        a315.extend(t.count);
        a316.extend(t.count);
        a317.extend(t.count);
        a318.extend(t.count);
        a319.extend(t.count);
        a320.extend(t.count);
        a321.extend(t.count);
        a322.extend(t.count);
        a323.extend(t.count);
        a324.extend(t.count);
        a325.extend(t.count);
        a326.extend(t.count);
        a327.extend(t.count);
        a328.extend(t.count);
        a329.extend(t.count);
        a330.extend(t.count);
        a331.extend(t.count);
        a332.extend(t.count);
        a333.extend(t.count);
        a334.extend(t.count);
        a335.extend(t.count);
        a336.extend(t.count);
        a337.extend(t.count);
        a338.extend(t.count);
        a339.extend(t.count);
        a340.extend(t.count);
        a341.extend(t.count);
        a342.extend(t.count);
        a343.extend(t.count);
        a344.extend(t.count);
        a345.extend(t.count);
        a346.extend(t.count);
        a347.extend(t.count);
        a348.extend(t.count);
        a349.extend(t.count);
        a350.extend(t.count);
        a351.extend(t.count);
        a352.extend(t.count);
        a353.extend(t.count);
        a354.extend(t.count);
        a355.extend(t.count);
        a356.extend(t.count);
        a357.extend(t.count);
        a358.extend(t.count);
        a359.extend(t.count);
        a360.extend(t.count);
        a361.extend(t.count);
        a362.extend(t.count);
        a363.extend(t.count);
        a364.extend(t.count);
        a365.extend(t.count);
        a366.extend(t.count);
        a367.extend(t.count);
        a368.extend(t.count);
        a369.extend(t.count);
        a370.extend(t.count);
        a371.extend(t.count);
        a372.extend(t.count);
        a373.extend(t.count);
        a374.extend(t.count);
        a375.extend(t.count);
        a376.extend(t.count);
        a377.extend(t.count);
        a378.extend(t.count);
        a379.extend(t.count);
        a380.extend(t.count);
        a381.extend(t.count);
        a382.extend(t.count);
        a383.extend(t.count);
        a384.extend(t.count);
        a385.extend(t.count);
        a386.extend(t.count);
        a387.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).list_entry_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).list_header_id);
          a2(indx) := t(ddindx).last_update_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).list_select_action_id);
          a9(indx) := t(ddindx).arc_list_select_action_from;
          a10(indx) := t(ddindx).list_select_action_from_name;
          a11(indx) := t(ddindx).source_code;
          a12(indx) := t(ddindx).arc_list_used_by_source;
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).source_code_for_id);
          a14(indx) := t(ddindx).pin_code;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).list_entry_source_system_id);
          a16(indx) := t(ddindx).list_entry_source_system_type;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).view_application_id);
          a18(indx) := t(ddindx).manually_entered_flag;
          a19(indx) := t(ddindx).marked_as_duplicate_flag;
          a20(indx) := t(ddindx).marked_as_random_flag;
          a21(indx) := t(ddindx).part_of_control_group_flag;
          a22(indx) := t(ddindx).exclude_in_triggered_list_flag;
          a23(indx) := t(ddindx).enabled_flag;
          a24(indx) := t(ddindx).cell_code;
          a25(indx) := t(ddindx).dedupe_key;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).randomly_generated_number);
          a27(indx) := rosetta_g_miss_num_map(t(ddindx).campaign_id);
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).media_id);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).channel_id);
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).channel_schedule_id);
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).event_offer_id);
          a32(indx) := rosetta_g_miss_num_map(t(ddindx).customer_id);
          a33(indx) := rosetta_g_miss_num_map(t(ddindx).market_segment_id);
          a34(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a35(indx) := t(ddindx).transfer_flag;
          a36(indx) := t(ddindx).transfer_status;
          a37(indx) := t(ddindx).list_source;
          a38(indx) := rosetta_g_miss_num_map(t(ddindx).duplicate_master_entry_id);
          a39(indx) := t(ddindx).marked_flag;
          a40(indx) := rosetta_g_miss_num_map(t(ddindx).lead_id);
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).letter_id);
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).picking_header_id);
          a43(indx) := rosetta_g_miss_num_map(t(ddindx).batch_id);
          a44(indx) := t(ddindx).suffix;
          a45(indx) := t(ddindx).first_name;
          a46(indx) := t(ddindx).last_name;
          a47(indx) := t(ddindx).customer_name;
          a48(indx) := t(ddindx).title;
          a49(indx) := t(ddindx).address_line1;
          a50(indx) := t(ddindx).address_line2;
          a51(indx) := t(ddindx).city;
          a52(indx) := t(ddindx).state;
          a53(indx) := t(ddindx).zipcode;
          a54(indx) := t(ddindx).country;
          a55(indx) := t(ddindx).fax;
          a56(indx) := t(ddindx).phone;
          a57(indx) := t(ddindx).email_address;
          a58(indx) := t(ddindx).col1;
          a59(indx) := t(ddindx).col2;
          a60(indx) := t(ddindx).col3;
          a61(indx) := t(ddindx).col4;
          a62(indx) := t(ddindx).col5;
          a63(indx) := t(ddindx).col6;
          a64(indx) := t(ddindx).col7;
          a65(indx) := t(ddindx).col8;
          a66(indx) := t(ddindx).col9;
          a67(indx) := t(ddindx).col10;
          a68(indx) := t(ddindx).col11;
          a69(indx) := t(ddindx).col12;
          a70(indx) := t(ddindx).col13;
          a71(indx) := t(ddindx).col14;
          a72(indx) := t(ddindx).col15;
          a73(indx) := t(ddindx).col16;
          a74(indx) := t(ddindx).col17;
          a75(indx) := t(ddindx).col18;
          a76(indx) := t(ddindx).col19;
          a77(indx) := t(ddindx).col20;
          a78(indx) := t(ddindx).col21;
          a79(indx) := t(ddindx).col22;
          a80(indx) := t(ddindx).col23;
          a81(indx) := t(ddindx).col24;
          a82(indx) := t(ddindx).col25;
          a83(indx) := t(ddindx).col26;
          a84(indx) := t(ddindx).col27;
          a85(indx) := t(ddindx).col28;
          a86(indx) := t(ddindx).col29;
          a87(indx) := t(ddindx).col30;
          a88(indx) := t(ddindx).col31;
          a89(indx) := t(ddindx).col32;
          a90(indx) := t(ddindx).col33;
          a91(indx) := t(ddindx).col34;
          a92(indx) := t(ddindx).col35;
          a93(indx) := t(ddindx).col36;
          a94(indx) := t(ddindx).col37;
          a95(indx) := t(ddindx).col38;
          a96(indx) := t(ddindx).col39;
          a97(indx) := t(ddindx).col40;
          a98(indx) := t(ddindx).col41;
          a99(indx) := t(ddindx).col42;
          a100(indx) := t(ddindx).col43;
          a101(indx) := t(ddindx).col44;
          a102(indx) := t(ddindx).col45;
          a103(indx) := t(ddindx).col46;
          a104(indx) := t(ddindx).col47;
          a105(indx) := t(ddindx).col48;
          a106(indx) := t(ddindx).col49;
          a107(indx) := t(ddindx).col50;
          a108(indx) := t(ddindx).col51;
          a109(indx) := t(ddindx).col52;
          a110(indx) := t(ddindx).col53;
          a111(indx) := t(ddindx).col54;
          a112(indx) := t(ddindx).col55;
          a113(indx) := t(ddindx).col56;
          a114(indx) := t(ddindx).col57;
          a115(indx) := t(ddindx).col58;
          a116(indx) := t(ddindx).col59;
          a117(indx) := t(ddindx).col60;
          a118(indx) := t(ddindx).col61;
          a119(indx) := t(ddindx).col62;
          a120(indx) := t(ddindx).col63;
          a121(indx) := t(ddindx).col64;
          a122(indx) := t(ddindx).col65;
          a123(indx) := t(ddindx).col66;
          a124(indx) := t(ddindx).col67;
          a125(indx) := t(ddindx).col68;
          a126(indx) := t(ddindx).col69;
          a127(indx) := t(ddindx).col70;
          a128(indx) := t(ddindx).col71;
          a129(indx) := t(ddindx).col72;
          a130(indx) := t(ddindx).col73;
          a131(indx) := t(ddindx).col74;
          a132(indx) := t(ddindx).col75;
          a133(indx) := t(ddindx).col76;
          a134(indx) := t(ddindx).col77;
          a135(indx) := t(ddindx).col78;
          a136(indx) := t(ddindx).col79;
          a137(indx) := t(ddindx).col80;
          a138(indx) := t(ddindx).col81;
          a139(indx) := t(ddindx).col82;
          a140(indx) := t(ddindx).col83;
          a141(indx) := t(ddindx).col84;
          a142(indx) := t(ddindx).col85;
          a143(indx) := t(ddindx).col86;
          a144(indx) := t(ddindx).col87;
          a145(indx) := t(ddindx).col88;
          a146(indx) := t(ddindx).col89;
          a147(indx) := t(ddindx).col90;
          a148(indx) := t(ddindx).col91;
          a149(indx) := t(ddindx).col92;
          a150(indx) := t(ddindx).col93;
          a151(indx) := t(ddindx).col94;
          a152(indx) := t(ddindx).col95;
          a153(indx) := t(ddindx).col96;
          a154(indx) := t(ddindx).col97;
          a155(indx) := t(ddindx).col98;
          a156(indx) := t(ddindx).col99;
          a157(indx) := t(ddindx).col100;
          a158(indx) := t(ddindx).col101;
          a159(indx) := t(ddindx).col102;
          a160(indx) := t(ddindx).col103;
          a161(indx) := t(ddindx).col104;
          a162(indx) := t(ddindx).col105;
          a163(indx) := t(ddindx).col106;
          a164(indx) := t(ddindx).col107;
          a165(indx) := t(ddindx).col108;
          a166(indx) := t(ddindx).col109;
          a167(indx) := t(ddindx).col110;
          a168(indx) := t(ddindx).col111;
          a169(indx) := t(ddindx).col112;
          a170(indx) := t(ddindx).col113;
          a171(indx) := t(ddindx).col114;
          a172(indx) := t(ddindx).col115;
          a173(indx) := t(ddindx).col116;
          a174(indx) := t(ddindx).col117;
          a175(indx) := t(ddindx).col118;
          a176(indx) := t(ddindx).col119;
          a177(indx) := t(ddindx).col120;
          a178(indx) := t(ddindx).col121;
          a179(indx) := t(ddindx).col122;
          a180(indx) := t(ddindx).col123;
          a181(indx) := t(ddindx).col124;
          a182(indx) := t(ddindx).col125;
          a183(indx) := t(ddindx).col126;
          a184(indx) := t(ddindx).col127;
          a185(indx) := t(ddindx).col128;
          a186(indx) := t(ddindx).col129;
          a187(indx) := t(ddindx).col130;
          a188(indx) := t(ddindx).col131;
          a189(indx) := t(ddindx).col132;
          a190(indx) := t(ddindx).col133;
          a191(indx) := t(ddindx).col134;
          a192(indx) := t(ddindx).col135;
          a193(indx) := t(ddindx).col136;
          a194(indx) := t(ddindx).col137;
          a195(indx) := t(ddindx).col138;
          a196(indx) := t(ddindx).col139;
          a197(indx) := t(ddindx).col140;
          a198(indx) := t(ddindx).col141;
          a199(indx) := t(ddindx).col142;
          a200(indx) := t(ddindx).col143;
          a201(indx) := t(ddindx).col144;
          a202(indx) := t(ddindx).col145;
          a203(indx) := t(ddindx).col146;
          a204(indx) := t(ddindx).col147;
          a205(indx) := t(ddindx).col148;
          a206(indx) := t(ddindx).col149;
          a207(indx) := t(ddindx).col150;
          a208(indx) := t(ddindx).col151;
          a209(indx) := t(ddindx).col152;
          a210(indx) := t(ddindx).col153;
          a211(indx) := t(ddindx).col154;
          a212(indx) := t(ddindx).col155;
          a213(indx) := t(ddindx).col156;
          a214(indx) := t(ddindx).col157;
          a215(indx) := t(ddindx).col158;
          a216(indx) := t(ddindx).col159;
          a217(indx) := t(ddindx).col160;
          a218(indx) := t(ddindx).col161;
          a219(indx) := t(ddindx).col162;
          a220(indx) := t(ddindx).col163;
          a221(indx) := t(ddindx).col164;
          a222(indx) := t(ddindx).col165;
          a223(indx) := t(ddindx).col166;
          a224(indx) := t(ddindx).col167;
          a225(indx) := t(ddindx).col168;
          a226(indx) := t(ddindx).col169;
          a227(indx) := t(ddindx).col170;
          a228(indx) := t(ddindx).col171;
          a229(indx) := t(ddindx).col172;
          a230(indx) := t(ddindx).col173;
          a231(indx) := t(ddindx).col174;
          a232(indx) := t(ddindx).col175;
          a233(indx) := t(ddindx).col176;
          a234(indx) := t(ddindx).col177;
          a235(indx) := t(ddindx).col178;
          a236(indx) := t(ddindx).col179;
          a237(indx) := t(ddindx).col180;
          a238(indx) := t(ddindx).col181;
          a239(indx) := t(ddindx).col182;
          a240(indx) := t(ddindx).col183;
          a241(indx) := t(ddindx).col184;
          a242(indx) := t(ddindx).col185;
          a243(indx) := t(ddindx).col186;
          a244(indx) := t(ddindx).col187;
          a245(indx) := t(ddindx).col188;
          a246(indx) := t(ddindx).col189;
          a247(indx) := t(ddindx).col190;
          a248(indx) := t(ddindx).col191;
          a249(indx) := t(ddindx).col192;
          a250(indx) := t(ddindx).col193;
          a251(indx) := t(ddindx).col194;
          a252(indx) := t(ddindx).col195;
          a253(indx) := t(ddindx).col196;
          a254(indx) := t(ddindx).col197;
          a255(indx) := t(ddindx).col198;
          a256(indx) := t(ddindx).col199;
          a257(indx) := t(ddindx).col200;
          a258(indx) := t(ddindx).col201;
          a259(indx) := t(ddindx).col202;
          a260(indx) := t(ddindx).col203;
          a261(indx) := t(ddindx).col204;
          a262(indx) := t(ddindx).col205;
          a263(indx) := t(ddindx).col206;
          a264(indx) := t(ddindx).col207;
          a265(indx) := t(ddindx).col208;
          a266(indx) := t(ddindx).col209;
          a267(indx) := t(ddindx).col210;
          a268(indx) := t(ddindx).col211;
          a269(indx) := t(ddindx).col212;
          a270(indx) := t(ddindx).col213;
          a271(indx) := t(ddindx).col214;
          a272(indx) := t(ddindx).col215;
          a273(indx) := t(ddindx).col216;
          a274(indx) := t(ddindx).col217;
          a275(indx) := t(ddindx).col218;
          a276(indx) := t(ddindx).col219;
          a277(indx) := t(ddindx).col220;
          a278(indx) := t(ddindx).col221;
          a279(indx) := t(ddindx).col222;
          a280(indx) := t(ddindx).col223;
          a281(indx) := t(ddindx).col224;
          a282(indx) := t(ddindx).col225;
          a283(indx) := t(ddindx).col226;
          a284(indx) := t(ddindx).col227;
          a285(indx) := t(ddindx).col228;
          a286(indx) := t(ddindx).col229;
          a287(indx) := t(ddindx).col230;
          a288(indx) := t(ddindx).col231;
          a289(indx) := t(ddindx).col232;
          a290(indx) := t(ddindx).col233;
          a291(indx) := t(ddindx).col234;
          a292(indx) := t(ddindx).col235;
          a293(indx) := t(ddindx).col236;
          a294(indx) := t(ddindx).col237;
          a295(indx) := t(ddindx).col238;
          a296(indx) := t(ddindx).col239;
          a297(indx) := t(ddindx).col240;
          a298(indx) := t(ddindx).col241;
          a299(indx) := t(ddindx).col242;
          a300(indx) := t(ddindx).col243;
          a301(indx) := t(ddindx).col244;
          a302(indx) := t(ddindx).col245;
          a303(indx) := t(ddindx).col246;
          a304(indx) := t(ddindx).col247;
          a305(indx) := t(ddindx).col248;
          a306(indx) := t(ddindx).col249;
          a307(indx) := t(ddindx).col250;
          a308(indx) := t(ddindx).col251;
          a309(indx) := t(ddindx).col252;
          a310(indx) := t(ddindx).col253;
          a311(indx) := t(ddindx).col254;
          a312(indx) := t(ddindx).col255;
          a313(indx) := t(ddindx).col256;
          a314(indx) := t(ddindx).col257;
          a315(indx) := t(ddindx).col258;
          a316(indx) := t(ddindx).col259;
          a317(indx) := t(ddindx).col260;
          a318(indx) := t(ddindx).col261;
          a319(indx) := t(ddindx).col262;
          a320(indx) := t(ddindx).col263;
          a321(indx) := t(ddindx).col264;
          a322(indx) := t(ddindx).col265;
          a323(indx) := t(ddindx).col266;
          a324(indx) := t(ddindx).col267;
          a325(indx) := t(ddindx).col268;
          a326(indx) := t(ddindx).col269;
          a327(indx) := t(ddindx).col270;
          a328(indx) := t(ddindx).col271;
          a329(indx) := t(ddindx).col272;
          a330(indx) := t(ddindx).col273;
          a331(indx) := t(ddindx).col274;
          a332(indx) := t(ddindx).col275;
          a333(indx) := t(ddindx).col276;
          a334(indx) := t(ddindx).col277;
          a335(indx) := t(ddindx).col278;
          a336(indx) := t(ddindx).col279;
          a337(indx) := t(ddindx).col280;
          a338(indx) := t(ddindx).col281;
          a339(indx) := t(ddindx).col282;
          a340(indx) := t(ddindx).col283;
          a341(indx) := t(ddindx).col284;
          a342(indx) := t(ddindx).col285;
          a343(indx) := t(ddindx).col286;
          a344(indx) := t(ddindx).col287;
          a345(indx) := t(ddindx).col288;
          a346(indx) := t(ddindx).col289;
          a347(indx) := t(ddindx).col290;
          a348(indx) := t(ddindx).col291;
          a349(indx) := t(ddindx).col292;
          a350(indx) := t(ddindx).col293;
          a351(indx) := t(ddindx).col294;
          a352(indx) := t(ddindx).col295;
          a353(indx) := t(ddindx).col296;
          a354(indx) := t(ddindx).col297;
          a355(indx) := t(ddindx).col298;
          a356(indx) := t(ddindx).col299;
          a357(indx) := t(ddindx).col300;
          a358(indx) := t(ddindx).curr_cp_country_code;
          a359(indx) := t(ddindx).curr_cp_phone_number;
          a360(indx) := t(ddindx).curr_cp_raw_phone_number;
          a361(indx) := rosetta_g_miss_num_map(t(ddindx).curr_cp_area_code);
          a362(indx) := rosetta_g_miss_num_map(t(ddindx).curr_cp_id);
          a363(indx) := rosetta_g_miss_num_map(t(ddindx).curr_cp_index);
          a364(indx) := rosetta_g_miss_num_map(t(ddindx).curr_cp_time_zone);
          a365(indx) := rosetta_g_miss_num_map(t(ddindx).curr_cp_time_zone_aux);
          a366(indx) := rosetta_g_miss_num_map(t(ddindx).party_id);
          a367(indx) := rosetta_g_miss_num_map(t(ddindx).parent_party_id);
          a368(indx) := rosetta_g_miss_num_map(t(ddindx).imp_source_line_id);
          a369(indx) := t(ddindx).usage_restriction;
          a370(indx) := t(ddindx).next_call_time;
          a371(indx) := t(ddindx).callback_flag;
          a372(indx) := t(ddindx).do_not_use_flag;
          a373(indx) := t(ddindx).do_not_use_reason;
          a374(indx) := t(ddindx).record_out_flag;
          a375(indx) := t(ddindx).record_release_time;
          a376(indx) := t(ddindx).group_code;
          a377(indx) := t(ddindx).newly_updated_flag;
          a378(indx) := rosetta_g_miss_num_map(t(ddindx).outcome_id);
          a379(indx) := rosetta_g_miss_num_map(t(ddindx).result_id);
          a380(indx) := rosetta_g_miss_num_map(t(ddindx).reason_id);
          a381(indx) := t(ddindx).notes;
          a382(indx) := t(ddindx).vehicle_response_code;
          a383(indx) := t(ddindx).sales_agent_email_address;
          a384(indx) := rosetta_g_miss_num_map(t(ddindx).resource_id);
          a385(indx) := rosetta_g_miss_num_map(t(ddindx).location_id);
          a386(indx) := rosetta_g_miss_num_map(t(ddindx).contact_point_id);
          a387(indx) := t(ddindx).last_contacted_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_list_entries(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_list_entry_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
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
    , p7_a265  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a295  VARCHAR2 := fnd_api.g_miss_char
    , p7_a296  VARCHAR2 := fnd_api.g_miss_char
    , p7_a297  VARCHAR2 := fnd_api.g_miss_char
    , p7_a298  VARCHAR2 := fnd_api.g_miss_char
    , p7_a299  VARCHAR2 := fnd_api.g_miss_char
    , p7_a300  VARCHAR2 := fnd_api.g_miss_char
    , p7_a301  VARCHAR2 := fnd_api.g_miss_char
    , p7_a302  VARCHAR2 := fnd_api.g_miss_char
    , p7_a303  VARCHAR2 := fnd_api.g_miss_char
    , p7_a304  VARCHAR2 := fnd_api.g_miss_char
    , p7_a305  VARCHAR2 := fnd_api.g_miss_char
    , p7_a306  VARCHAR2 := fnd_api.g_miss_char
    , p7_a307  VARCHAR2 := fnd_api.g_miss_char
    , p7_a308  VARCHAR2 := fnd_api.g_miss_char
    , p7_a309  VARCHAR2 := fnd_api.g_miss_char
    , p7_a310  VARCHAR2 := fnd_api.g_miss_char
    , p7_a311  VARCHAR2 := fnd_api.g_miss_char
    , p7_a312  VARCHAR2 := fnd_api.g_miss_char
    , p7_a313  VARCHAR2 := fnd_api.g_miss_char
    , p7_a314  VARCHAR2 := fnd_api.g_miss_char
    , p7_a315  VARCHAR2 := fnd_api.g_miss_char
    , p7_a316  VARCHAR2 := fnd_api.g_miss_char
    , p7_a317  VARCHAR2 := fnd_api.g_miss_char
    , p7_a318  VARCHAR2 := fnd_api.g_miss_char
    , p7_a319  VARCHAR2 := fnd_api.g_miss_char
    , p7_a320  VARCHAR2 := fnd_api.g_miss_char
    , p7_a321  VARCHAR2 := fnd_api.g_miss_char
    , p7_a322  VARCHAR2 := fnd_api.g_miss_char
    , p7_a323  VARCHAR2 := fnd_api.g_miss_char
    , p7_a324  VARCHAR2 := fnd_api.g_miss_char
    , p7_a325  VARCHAR2 := fnd_api.g_miss_char
    , p7_a326  VARCHAR2 := fnd_api.g_miss_char
    , p7_a327  VARCHAR2 := fnd_api.g_miss_char
    , p7_a328  VARCHAR2 := fnd_api.g_miss_char
    , p7_a329  VARCHAR2 := fnd_api.g_miss_char
    , p7_a330  VARCHAR2 := fnd_api.g_miss_char
    , p7_a331  VARCHAR2 := fnd_api.g_miss_char
    , p7_a332  VARCHAR2 := fnd_api.g_miss_char
    , p7_a333  VARCHAR2 := fnd_api.g_miss_char
    , p7_a334  VARCHAR2 := fnd_api.g_miss_char
    , p7_a335  VARCHAR2 := fnd_api.g_miss_char
    , p7_a336  VARCHAR2 := fnd_api.g_miss_char
    , p7_a337  VARCHAR2 := fnd_api.g_miss_char
    , p7_a338  VARCHAR2 := fnd_api.g_miss_char
    , p7_a339  VARCHAR2 := fnd_api.g_miss_char
    , p7_a340  VARCHAR2 := fnd_api.g_miss_char
    , p7_a341  VARCHAR2 := fnd_api.g_miss_char
    , p7_a342  VARCHAR2 := fnd_api.g_miss_char
    , p7_a343  VARCHAR2 := fnd_api.g_miss_char
    , p7_a344  VARCHAR2 := fnd_api.g_miss_char
    , p7_a345  VARCHAR2 := fnd_api.g_miss_char
    , p7_a346  VARCHAR2 := fnd_api.g_miss_char
    , p7_a347  VARCHAR2 := fnd_api.g_miss_char
    , p7_a348  VARCHAR2 := fnd_api.g_miss_char
    , p7_a349  VARCHAR2 := fnd_api.g_miss_char
    , p7_a350  VARCHAR2 := fnd_api.g_miss_char
    , p7_a351  VARCHAR2 := fnd_api.g_miss_char
    , p7_a352  VARCHAR2 := fnd_api.g_miss_char
    , p7_a353  VARCHAR2 := fnd_api.g_miss_char
    , p7_a354  VARCHAR2 := fnd_api.g_miss_char
    , p7_a355  VARCHAR2 := fnd_api.g_miss_char
    , p7_a356  VARCHAR2 := fnd_api.g_miss_char
    , p7_a357  VARCHAR2 := fnd_api.g_miss_char
    , p7_a358  VARCHAR2 := fnd_api.g_miss_char
    , p7_a359  VARCHAR2 := fnd_api.g_miss_char
    , p7_a360  VARCHAR2 := fnd_api.g_miss_char
    , p7_a361  NUMBER := 0-1962.0724
    , p7_a362  NUMBER := 0-1962.0724
    , p7_a363  NUMBER := 0-1962.0724
    , p7_a364  NUMBER := 0-1962.0724
    , p7_a365  NUMBER := 0-1962.0724
    , p7_a366  NUMBER := 0-1962.0724
    , p7_a367  NUMBER := 0-1962.0724
    , p7_a368  NUMBER := 0-1962.0724
    , p7_a369  VARCHAR2 := fnd_api.g_miss_char
    , p7_a370  DATE := fnd_api.g_miss_date
    , p7_a371  VARCHAR2 := fnd_api.g_miss_char
    , p7_a372  VARCHAR2 := fnd_api.g_miss_char
    , p7_a373  VARCHAR2 := fnd_api.g_miss_char
    , p7_a374  VARCHAR2 := fnd_api.g_miss_char
    , p7_a375  DATE := fnd_api.g_miss_date
    , p7_a376  VARCHAR2 := fnd_api.g_miss_char
    , p7_a377  VARCHAR2 := fnd_api.g_miss_char
    , p7_a378  NUMBER := 0-1962.0724
    , p7_a379  NUMBER := 0-1962.0724
    , p7_a380  NUMBER := 0-1962.0724
    , p7_a381  VARCHAR2 := fnd_api.g_miss_char
    , p7_a382  VARCHAR2 := fnd_api.g_miss_char
    , p7_a383  VARCHAR2 := fnd_api.g_miss_char
    , p7_a384  NUMBER := 0-1962.0724
    , p7_a385  NUMBER := 0-1962.0724
    , p7_a386  NUMBER := 0-1962.0724
    , p7_a387  DATE := fnd_api.g_miss_date
  )
  as
    ddp_list_entries_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_entries_rec.list_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_entries_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_entries_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_list_entries_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_list_entries_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_list_entries_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_list_entries_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_list_entries_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_list_entries_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a8);
    ddp_list_entries_rec.arc_list_select_action_from := p7_a9;
    ddp_list_entries_rec.list_select_action_from_name := p7_a10;
    ddp_list_entries_rec.source_code := p7_a11;
    ddp_list_entries_rec.arc_list_used_by_source := p7_a12;
    ddp_list_entries_rec.source_code_for_id := rosetta_g_miss_num_map(p7_a13);
    ddp_list_entries_rec.pin_code := p7_a14;
    ddp_list_entries_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_list_entries_rec.list_entry_source_system_type := p7_a16;
    ddp_list_entries_rec.view_application_id := rosetta_g_miss_num_map(p7_a17);
    ddp_list_entries_rec.manually_entered_flag := p7_a18;
    ddp_list_entries_rec.marked_as_duplicate_flag := p7_a19;
    ddp_list_entries_rec.marked_as_random_flag := p7_a20;
    ddp_list_entries_rec.part_of_control_group_flag := p7_a21;
    ddp_list_entries_rec.exclude_in_triggered_list_flag := p7_a22;
    ddp_list_entries_rec.enabled_flag := p7_a23;
    ddp_list_entries_rec.cell_code := p7_a24;
    ddp_list_entries_rec.dedupe_key := p7_a25;
    ddp_list_entries_rec.randomly_generated_number := rosetta_g_miss_num_map(p7_a26);
    ddp_list_entries_rec.campaign_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_entries_rec.media_id := rosetta_g_miss_num_map(p7_a28);
    ddp_list_entries_rec.channel_id := rosetta_g_miss_num_map(p7_a29);
    ddp_list_entries_rec.channel_schedule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_list_entries_rec.event_offer_id := rosetta_g_miss_num_map(p7_a31);
    ddp_list_entries_rec.customer_id := rosetta_g_miss_num_map(p7_a32);
    ddp_list_entries_rec.market_segment_id := rosetta_g_miss_num_map(p7_a33);
    ddp_list_entries_rec.vendor_id := rosetta_g_miss_num_map(p7_a34);
    ddp_list_entries_rec.transfer_flag := p7_a35;
    ddp_list_entries_rec.transfer_status := p7_a36;
    ddp_list_entries_rec.list_source := p7_a37;
    ddp_list_entries_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p7_a38);
    ddp_list_entries_rec.marked_flag := p7_a39;
    ddp_list_entries_rec.lead_id := rosetta_g_miss_num_map(p7_a40);
    ddp_list_entries_rec.letter_id := rosetta_g_miss_num_map(p7_a41);
    ddp_list_entries_rec.picking_header_id := rosetta_g_miss_num_map(p7_a42);
    ddp_list_entries_rec.batch_id := rosetta_g_miss_num_map(p7_a43);
    ddp_list_entries_rec.suffix := p7_a44;
    ddp_list_entries_rec.first_name := p7_a45;
    ddp_list_entries_rec.last_name := p7_a46;
    ddp_list_entries_rec.customer_name := p7_a47;
    ddp_list_entries_rec.title := p7_a48;
    ddp_list_entries_rec.address_line1 := p7_a49;
    ddp_list_entries_rec.address_line2 := p7_a50;
    ddp_list_entries_rec.city := p7_a51;
    ddp_list_entries_rec.state := p7_a52;
    ddp_list_entries_rec.zipcode := p7_a53;
    ddp_list_entries_rec.country := p7_a54;
    ddp_list_entries_rec.fax := p7_a55;
    ddp_list_entries_rec.phone := p7_a56;
    ddp_list_entries_rec.email_address := p7_a57;
    ddp_list_entries_rec.col1 := p7_a58;
    ddp_list_entries_rec.col2 := p7_a59;
    ddp_list_entries_rec.col3 := p7_a60;
    ddp_list_entries_rec.col4 := p7_a61;
    ddp_list_entries_rec.col5 := p7_a62;
    ddp_list_entries_rec.col6 := p7_a63;
    ddp_list_entries_rec.col7 := p7_a64;
    ddp_list_entries_rec.col8 := p7_a65;
    ddp_list_entries_rec.col9 := p7_a66;
    ddp_list_entries_rec.col10 := p7_a67;
    ddp_list_entries_rec.col11 := p7_a68;
    ddp_list_entries_rec.col12 := p7_a69;
    ddp_list_entries_rec.col13 := p7_a70;
    ddp_list_entries_rec.col14 := p7_a71;
    ddp_list_entries_rec.col15 := p7_a72;
    ddp_list_entries_rec.col16 := p7_a73;
    ddp_list_entries_rec.col17 := p7_a74;
    ddp_list_entries_rec.col18 := p7_a75;
    ddp_list_entries_rec.col19 := p7_a76;
    ddp_list_entries_rec.col20 := p7_a77;
    ddp_list_entries_rec.col21 := p7_a78;
    ddp_list_entries_rec.col22 := p7_a79;
    ddp_list_entries_rec.col23 := p7_a80;
    ddp_list_entries_rec.col24 := p7_a81;
    ddp_list_entries_rec.col25 := p7_a82;
    ddp_list_entries_rec.col26 := p7_a83;
    ddp_list_entries_rec.col27 := p7_a84;
    ddp_list_entries_rec.col28 := p7_a85;
    ddp_list_entries_rec.col29 := p7_a86;
    ddp_list_entries_rec.col30 := p7_a87;
    ddp_list_entries_rec.col31 := p7_a88;
    ddp_list_entries_rec.col32 := p7_a89;
    ddp_list_entries_rec.col33 := p7_a90;
    ddp_list_entries_rec.col34 := p7_a91;
    ddp_list_entries_rec.col35 := p7_a92;
    ddp_list_entries_rec.col36 := p7_a93;
    ddp_list_entries_rec.col37 := p7_a94;
    ddp_list_entries_rec.col38 := p7_a95;
    ddp_list_entries_rec.col39 := p7_a96;
    ddp_list_entries_rec.col40 := p7_a97;
    ddp_list_entries_rec.col41 := p7_a98;
    ddp_list_entries_rec.col42 := p7_a99;
    ddp_list_entries_rec.col43 := p7_a100;
    ddp_list_entries_rec.col44 := p7_a101;
    ddp_list_entries_rec.col45 := p7_a102;
    ddp_list_entries_rec.col46 := p7_a103;
    ddp_list_entries_rec.col47 := p7_a104;
    ddp_list_entries_rec.col48 := p7_a105;
    ddp_list_entries_rec.col49 := p7_a106;
    ddp_list_entries_rec.col50 := p7_a107;
    ddp_list_entries_rec.col51 := p7_a108;
    ddp_list_entries_rec.col52 := p7_a109;
    ddp_list_entries_rec.col53 := p7_a110;
    ddp_list_entries_rec.col54 := p7_a111;
    ddp_list_entries_rec.col55 := p7_a112;
    ddp_list_entries_rec.col56 := p7_a113;
    ddp_list_entries_rec.col57 := p7_a114;
    ddp_list_entries_rec.col58 := p7_a115;
    ddp_list_entries_rec.col59 := p7_a116;
    ddp_list_entries_rec.col60 := p7_a117;
    ddp_list_entries_rec.col61 := p7_a118;
    ddp_list_entries_rec.col62 := p7_a119;
    ddp_list_entries_rec.col63 := p7_a120;
    ddp_list_entries_rec.col64 := p7_a121;
    ddp_list_entries_rec.col65 := p7_a122;
    ddp_list_entries_rec.col66 := p7_a123;
    ddp_list_entries_rec.col67 := p7_a124;
    ddp_list_entries_rec.col68 := p7_a125;
    ddp_list_entries_rec.col69 := p7_a126;
    ddp_list_entries_rec.col70 := p7_a127;
    ddp_list_entries_rec.col71 := p7_a128;
    ddp_list_entries_rec.col72 := p7_a129;
    ddp_list_entries_rec.col73 := p7_a130;
    ddp_list_entries_rec.col74 := p7_a131;
    ddp_list_entries_rec.col75 := p7_a132;
    ddp_list_entries_rec.col76 := p7_a133;
    ddp_list_entries_rec.col77 := p7_a134;
    ddp_list_entries_rec.col78 := p7_a135;
    ddp_list_entries_rec.col79 := p7_a136;
    ddp_list_entries_rec.col80 := p7_a137;
    ddp_list_entries_rec.col81 := p7_a138;
    ddp_list_entries_rec.col82 := p7_a139;
    ddp_list_entries_rec.col83 := p7_a140;
    ddp_list_entries_rec.col84 := p7_a141;
    ddp_list_entries_rec.col85 := p7_a142;
    ddp_list_entries_rec.col86 := p7_a143;
    ddp_list_entries_rec.col87 := p7_a144;
    ddp_list_entries_rec.col88 := p7_a145;
    ddp_list_entries_rec.col89 := p7_a146;
    ddp_list_entries_rec.col90 := p7_a147;
    ddp_list_entries_rec.col91 := p7_a148;
    ddp_list_entries_rec.col92 := p7_a149;
    ddp_list_entries_rec.col93 := p7_a150;
    ddp_list_entries_rec.col94 := p7_a151;
    ddp_list_entries_rec.col95 := p7_a152;
    ddp_list_entries_rec.col96 := p7_a153;
    ddp_list_entries_rec.col97 := p7_a154;
    ddp_list_entries_rec.col98 := p7_a155;
    ddp_list_entries_rec.col99 := p7_a156;
    ddp_list_entries_rec.col100 := p7_a157;
    ddp_list_entries_rec.col101 := p7_a158;
    ddp_list_entries_rec.col102 := p7_a159;
    ddp_list_entries_rec.col103 := p7_a160;
    ddp_list_entries_rec.col104 := p7_a161;
    ddp_list_entries_rec.col105 := p7_a162;
    ddp_list_entries_rec.col106 := p7_a163;
    ddp_list_entries_rec.col107 := p7_a164;
    ddp_list_entries_rec.col108 := p7_a165;
    ddp_list_entries_rec.col109 := p7_a166;
    ddp_list_entries_rec.col110 := p7_a167;
    ddp_list_entries_rec.col111 := p7_a168;
    ddp_list_entries_rec.col112 := p7_a169;
    ddp_list_entries_rec.col113 := p7_a170;
    ddp_list_entries_rec.col114 := p7_a171;
    ddp_list_entries_rec.col115 := p7_a172;
    ddp_list_entries_rec.col116 := p7_a173;
    ddp_list_entries_rec.col117 := p7_a174;
    ddp_list_entries_rec.col118 := p7_a175;
    ddp_list_entries_rec.col119 := p7_a176;
    ddp_list_entries_rec.col120 := p7_a177;
    ddp_list_entries_rec.col121 := p7_a178;
    ddp_list_entries_rec.col122 := p7_a179;
    ddp_list_entries_rec.col123 := p7_a180;
    ddp_list_entries_rec.col124 := p7_a181;
    ddp_list_entries_rec.col125 := p7_a182;
    ddp_list_entries_rec.col126 := p7_a183;
    ddp_list_entries_rec.col127 := p7_a184;
    ddp_list_entries_rec.col128 := p7_a185;
    ddp_list_entries_rec.col129 := p7_a186;
    ddp_list_entries_rec.col130 := p7_a187;
    ddp_list_entries_rec.col131 := p7_a188;
    ddp_list_entries_rec.col132 := p7_a189;
    ddp_list_entries_rec.col133 := p7_a190;
    ddp_list_entries_rec.col134 := p7_a191;
    ddp_list_entries_rec.col135 := p7_a192;
    ddp_list_entries_rec.col136 := p7_a193;
    ddp_list_entries_rec.col137 := p7_a194;
    ddp_list_entries_rec.col138 := p7_a195;
    ddp_list_entries_rec.col139 := p7_a196;
    ddp_list_entries_rec.col140 := p7_a197;
    ddp_list_entries_rec.col141 := p7_a198;
    ddp_list_entries_rec.col142 := p7_a199;
    ddp_list_entries_rec.col143 := p7_a200;
    ddp_list_entries_rec.col144 := p7_a201;
    ddp_list_entries_rec.col145 := p7_a202;
    ddp_list_entries_rec.col146 := p7_a203;
    ddp_list_entries_rec.col147 := p7_a204;
    ddp_list_entries_rec.col148 := p7_a205;
    ddp_list_entries_rec.col149 := p7_a206;
    ddp_list_entries_rec.col150 := p7_a207;
    ddp_list_entries_rec.col151 := p7_a208;
    ddp_list_entries_rec.col152 := p7_a209;
    ddp_list_entries_rec.col153 := p7_a210;
    ddp_list_entries_rec.col154 := p7_a211;
    ddp_list_entries_rec.col155 := p7_a212;
    ddp_list_entries_rec.col156 := p7_a213;
    ddp_list_entries_rec.col157 := p7_a214;
    ddp_list_entries_rec.col158 := p7_a215;
    ddp_list_entries_rec.col159 := p7_a216;
    ddp_list_entries_rec.col160 := p7_a217;
    ddp_list_entries_rec.col161 := p7_a218;
    ddp_list_entries_rec.col162 := p7_a219;
    ddp_list_entries_rec.col163 := p7_a220;
    ddp_list_entries_rec.col164 := p7_a221;
    ddp_list_entries_rec.col165 := p7_a222;
    ddp_list_entries_rec.col166 := p7_a223;
    ddp_list_entries_rec.col167 := p7_a224;
    ddp_list_entries_rec.col168 := p7_a225;
    ddp_list_entries_rec.col169 := p7_a226;
    ddp_list_entries_rec.col170 := p7_a227;
    ddp_list_entries_rec.col171 := p7_a228;
    ddp_list_entries_rec.col172 := p7_a229;
    ddp_list_entries_rec.col173 := p7_a230;
    ddp_list_entries_rec.col174 := p7_a231;
    ddp_list_entries_rec.col175 := p7_a232;
    ddp_list_entries_rec.col176 := p7_a233;
    ddp_list_entries_rec.col177 := p7_a234;
    ddp_list_entries_rec.col178 := p7_a235;
    ddp_list_entries_rec.col179 := p7_a236;
    ddp_list_entries_rec.col180 := p7_a237;
    ddp_list_entries_rec.col181 := p7_a238;
    ddp_list_entries_rec.col182 := p7_a239;
    ddp_list_entries_rec.col183 := p7_a240;
    ddp_list_entries_rec.col184 := p7_a241;
    ddp_list_entries_rec.col185 := p7_a242;
    ddp_list_entries_rec.col186 := p7_a243;
    ddp_list_entries_rec.col187 := p7_a244;
    ddp_list_entries_rec.col188 := p7_a245;
    ddp_list_entries_rec.col189 := p7_a246;
    ddp_list_entries_rec.col190 := p7_a247;
    ddp_list_entries_rec.col191 := p7_a248;
    ddp_list_entries_rec.col192 := p7_a249;
    ddp_list_entries_rec.col193 := p7_a250;
    ddp_list_entries_rec.col194 := p7_a251;
    ddp_list_entries_rec.col195 := p7_a252;
    ddp_list_entries_rec.col196 := p7_a253;
    ddp_list_entries_rec.col197 := p7_a254;
    ddp_list_entries_rec.col198 := p7_a255;
    ddp_list_entries_rec.col199 := p7_a256;
    ddp_list_entries_rec.col200 := p7_a257;
    ddp_list_entries_rec.col201 := p7_a258;
    ddp_list_entries_rec.col202 := p7_a259;
    ddp_list_entries_rec.col203 := p7_a260;
    ddp_list_entries_rec.col204 := p7_a261;
    ddp_list_entries_rec.col205 := p7_a262;
    ddp_list_entries_rec.col206 := p7_a263;
    ddp_list_entries_rec.col207 := p7_a264;
    ddp_list_entries_rec.col208 := p7_a265;
    ddp_list_entries_rec.col209 := p7_a266;
    ddp_list_entries_rec.col210 := p7_a267;
    ddp_list_entries_rec.col211 := p7_a268;
    ddp_list_entries_rec.col212 := p7_a269;
    ddp_list_entries_rec.col213 := p7_a270;
    ddp_list_entries_rec.col214 := p7_a271;
    ddp_list_entries_rec.col215 := p7_a272;
    ddp_list_entries_rec.col216 := p7_a273;
    ddp_list_entries_rec.col217 := p7_a274;
    ddp_list_entries_rec.col218 := p7_a275;
    ddp_list_entries_rec.col219 := p7_a276;
    ddp_list_entries_rec.col220 := p7_a277;
    ddp_list_entries_rec.col221 := p7_a278;
    ddp_list_entries_rec.col222 := p7_a279;
    ddp_list_entries_rec.col223 := p7_a280;
    ddp_list_entries_rec.col224 := p7_a281;
    ddp_list_entries_rec.col225 := p7_a282;
    ddp_list_entries_rec.col226 := p7_a283;
    ddp_list_entries_rec.col227 := p7_a284;
    ddp_list_entries_rec.col228 := p7_a285;
    ddp_list_entries_rec.col229 := p7_a286;
    ddp_list_entries_rec.col230 := p7_a287;
    ddp_list_entries_rec.col231 := p7_a288;
    ddp_list_entries_rec.col232 := p7_a289;
    ddp_list_entries_rec.col233 := p7_a290;
    ddp_list_entries_rec.col234 := p7_a291;
    ddp_list_entries_rec.col235 := p7_a292;
    ddp_list_entries_rec.col236 := p7_a293;
    ddp_list_entries_rec.col237 := p7_a294;
    ddp_list_entries_rec.col238 := p7_a295;
    ddp_list_entries_rec.col239 := p7_a296;
    ddp_list_entries_rec.col240 := p7_a297;
    ddp_list_entries_rec.col241 := p7_a298;
    ddp_list_entries_rec.col242 := p7_a299;
    ddp_list_entries_rec.col243 := p7_a300;
    ddp_list_entries_rec.col244 := p7_a301;
    ddp_list_entries_rec.col245 := p7_a302;
    ddp_list_entries_rec.col246 := p7_a303;
    ddp_list_entries_rec.col247 := p7_a304;
    ddp_list_entries_rec.col248 := p7_a305;
    ddp_list_entries_rec.col249 := p7_a306;
    ddp_list_entries_rec.col250 := p7_a307;
    ddp_list_entries_rec.col251 := p7_a308;
    ddp_list_entries_rec.col252 := p7_a309;
    ddp_list_entries_rec.col253 := p7_a310;
    ddp_list_entries_rec.col254 := p7_a311;
    ddp_list_entries_rec.col255 := p7_a312;
    ddp_list_entries_rec.col256 := p7_a313;
    ddp_list_entries_rec.col257 := p7_a314;
    ddp_list_entries_rec.col258 := p7_a315;
    ddp_list_entries_rec.col259 := p7_a316;
    ddp_list_entries_rec.col260 := p7_a317;
    ddp_list_entries_rec.col261 := p7_a318;
    ddp_list_entries_rec.col262 := p7_a319;
    ddp_list_entries_rec.col263 := p7_a320;
    ddp_list_entries_rec.col264 := p7_a321;
    ddp_list_entries_rec.col265 := p7_a322;
    ddp_list_entries_rec.col266 := p7_a323;
    ddp_list_entries_rec.col267 := p7_a324;
    ddp_list_entries_rec.col268 := p7_a325;
    ddp_list_entries_rec.col269 := p7_a326;
    ddp_list_entries_rec.col270 := p7_a327;
    ddp_list_entries_rec.col271 := p7_a328;
    ddp_list_entries_rec.col272 := p7_a329;
    ddp_list_entries_rec.col273 := p7_a330;
    ddp_list_entries_rec.col274 := p7_a331;
    ddp_list_entries_rec.col275 := p7_a332;
    ddp_list_entries_rec.col276 := p7_a333;
    ddp_list_entries_rec.col277 := p7_a334;
    ddp_list_entries_rec.col278 := p7_a335;
    ddp_list_entries_rec.col279 := p7_a336;
    ddp_list_entries_rec.col280 := p7_a337;
    ddp_list_entries_rec.col281 := p7_a338;
    ddp_list_entries_rec.col282 := p7_a339;
    ddp_list_entries_rec.col283 := p7_a340;
    ddp_list_entries_rec.col284 := p7_a341;
    ddp_list_entries_rec.col285 := p7_a342;
    ddp_list_entries_rec.col286 := p7_a343;
    ddp_list_entries_rec.col287 := p7_a344;
    ddp_list_entries_rec.col288 := p7_a345;
    ddp_list_entries_rec.col289 := p7_a346;
    ddp_list_entries_rec.col290 := p7_a347;
    ddp_list_entries_rec.col291 := p7_a348;
    ddp_list_entries_rec.col292 := p7_a349;
    ddp_list_entries_rec.col293 := p7_a350;
    ddp_list_entries_rec.col294 := p7_a351;
    ddp_list_entries_rec.col295 := p7_a352;
    ddp_list_entries_rec.col296 := p7_a353;
    ddp_list_entries_rec.col297 := p7_a354;
    ddp_list_entries_rec.col298 := p7_a355;
    ddp_list_entries_rec.col299 := p7_a356;
    ddp_list_entries_rec.col300 := p7_a357;
    ddp_list_entries_rec.curr_cp_country_code := p7_a358;
    ddp_list_entries_rec.curr_cp_phone_number := p7_a359;
    ddp_list_entries_rec.curr_cp_raw_phone_number := p7_a360;
    ddp_list_entries_rec.curr_cp_area_code := rosetta_g_miss_num_map(p7_a361);
    ddp_list_entries_rec.curr_cp_id := rosetta_g_miss_num_map(p7_a362);
    ddp_list_entries_rec.curr_cp_index := rosetta_g_miss_num_map(p7_a363);
    ddp_list_entries_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p7_a364);
    ddp_list_entries_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p7_a365);
    ddp_list_entries_rec.party_id := rosetta_g_miss_num_map(p7_a366);
    ddp_list_entries_rec.parent_party_id := rosetta_g_miss_num_map(p7_a367);
    ddp_list_entries_rec.imp_source_line_id := rosetta_g_miss_num_map(p7_a368);
    ddp_list_entries_rec.usage_restriction := p7_a369;
    ddp_list_entries_rec.next_call_time := rosetta_g_miss_date_in_map(p7_a370);
    ddp_list_entries_rec.callback_flag := p7_a371;
    ddp_list_entries_rec.do_not_use_flag := p7_a372;
    ddp_list_entries_rec.do_not_use_reason := p7_a373;
    ddp_list_entries_rec.record_out_flag := p7_a374;
    ddp_list_entries_rec.record_release_time := rosetta_g_miss_date_in_map(p7_a375);
    ddp_list_entries_rec.group_code := p7_a376;
    ddp_list_entries_rec.newly_updated_flag := p7_a377;
    ddp_list_entries_rec.outcome_id := rosetta_g_miss_num_map(p7_a378);
    ddp_list_entries_rec.result_id := rosetta_g_miss_num_map(p7_a379);
    ddp_list_entries_rec.reason_id := rosetta_g_miss_num_map(p7_a380);
    ddp_list_entries_rec.notes := p7_a381;
    ddp_list_entries_rec.vehicle_response_code := p7_a382;
    ddp_list_entries_rec.sales_agent_email_address := p7_a383;
    ddp_list_entries_rec.resource_id := rosetta_g_miss_num_map(p7_a384);
    ddp_list_entries_rec.location_id := rosetta_g_miss_num_map(p7_a385);
    ddp_list_entries_rec.contact_point_id := rosetta_g_miss_num_map(p7_a386);
    ddp_list_entries_rec.last_contacted_date := rosetta_g_miss_date_in_map(p7_a387);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.create_list_entries(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_entries_rec,
      x_list_entry_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_list_entries(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  VARCHAR2 := fnd_api.g_miss_char
    , p7_a26  NUMBER := 0-1962.0724
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  NUMBER := 0-1962.0724
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  VARCHAR2 := fnd_api.g_miss_char
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  NUMBER := 0-1962.0724
    , p7_a42  NUMBER := 0-1962.0724
    , p7_a43  NUMBER := 0-1962.0724
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
    , p7_a265  VARCHAR2 := fnd_api.g_miss_char
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
    , p7_a295  VARCHAR2 := fnd_api.g_miss_char
    , p7_a296  VARCHAR2 := fnd_api.g_miss_char
    , p7_a297  VARCHAR2 := fnd_api.g_miss_char
    , p7_a298  VARCHAR2 := fnd_api.g_miss_char
    , p7_a299  VARCHAR2 := fnd_api.g_miss_char
    , p7_a300  VARCHAR2 := fnd_api.g_miss_char
    , p7_a301  VARCHAR2 := fnd_api.g_miss_char
    , p7_a302  VARCHAR2 := fnd_api.g_miss_char
    , p7_a303  VARCHAR2 := fnd_api.g_miss_char
    , p7_a304  VARCHAR2 := fnd_api.g_miss_char
    , p7_a305  VARCHAR2 := fnd_api.g_miss_char
    , p7_a306  VARCHAR2 := fnd_api.g_miss_char
    , p7_a307  VARCHAR2 := fnd_api.g_miss_char
    , p7_a308  VARCHAR2 := fnd_api.g_miss_char
    , p7_a309  VARCHAR2 := fnd_api.g_miss_char
    , p7_a310  VARCHAR2 := fnd_api.g_miss_char
    , p7_a311  VARCHAR2 := fnd_api.g_miss_char
    , p7_a312  VARCHAR2 := fnd_api.g_miss_char
    , p7_a313  VARCHAR2 := fnd_api.g_miss_char
    , p7_a314  VARCHAR2 := fnd_api.g_miss_char
    , p7_a315  VARCHAR2 := fnd_api.g_miss_char
    , p7_a316  VARCHAR2 := fnd_api.g_miss_char
    , p7_a317  VARCHAR2 := fnd_api.g_miss_char
    , p7_a318  VARCHAR2 := fnd_api.g_miss_char
    , p7_a319  VARCHAR2 := fnd_api.g_miss_char
    , p7_a320  VARCHAR2 := fnd_api.g_miss_char
    , p7_a321  VARCHAR2 := fnd_api.g_miss_char
    , p7_a322  VARCHAR2 := fnd_api.g_miss_char
    , p7_a323  VARCHAR2 := fnd_api.g_miss_char
    , p7_a324  VARCHAR2 := fnd_api.g_miss_char
    , p7_a325  VARCHAR2 := fnd_api.g_miss_char
    , p7_a326  VARCHAR2 := fnd_api.g_miss_char
    , p7_a327  VARCHAR2 := fnd_api.g_miss_char
    , p7_a328  VARCHAR2 := fnd_api.g_miss_char
    , p7_a329  VARCHAR2 := fnd_api.g_miss_char
    , p7_a330  VARCHAR2 := fnd_api.g_miss_char
    , p7_a331  VARCHAR2 := fnd_api.g_miss_char
    , p7_a332  VARCHAR2 := fnd_api.g_miss_char
    , p7_a333  VARCHAR2 := fnd_api.g_miss_char
    , p7_a334  VARCHAR2 := fnd_api.g_miss_char
    , p7_a335  VARCHAR2 := fnd_api.g_miss_char
    , p7_a336  VARCHAR2 := fnd_api.g_miss_char
    , p7_a337  VARCHAR2 := fnd_api.g_miss_char
    , p7_a338  VARCHAR2 := fnd_api.g_miss_char
    , p7_a339  VARCHAR2 := fnd_api.g_miss_char
    , p7_a340  VARCHAR2 := fnd_api.g_miss_char
    , p7_a341  VARCHAR2 := fnd_api.g_miss_char
    , p7_a342  VARCHAR2 := fnd_api.g_miss_char
    , p7_a343  VARCHAR2 := fnd_api.g_miss_char
    , p7_a344  VARCHAR2 := fnd_api.g_miss_char
    , p7_a345  VARCHAR2 := fnd_api.g_miss_char
    , p7_a346  VARCHAR2 := fnd_api.g_miss_char
    , p7_a347  VARCHAR2 := fnd_api.g_miss_char
    , p7_a348  VARCHAR2 := fnd_api.g_miss_char
    , p7_a349  VARCHAR2 := fnd_api.g_miss_char
    , p7_a350  VARCHAR2 := fnd_api.g_miss_char
    , p7_a351  VARCHAR2 := fnd_api.g_miss_char
    , p7_a352  VARCHAR2 := fnd_api.g_miss_char
    , p7_a353  VARCHAR2 := fnd_api.g_miss_char
    , p7_a354  VARCHAR2 := fnd_api.g_miss_char
    , p7_a355  VARCHAR2 := fnd_api.g_miss_char
    , p7_a356  VARCHAR2 := fnd_api.g_miss_char
    , p7_a357  VARCHAR2 := fnd_api.g_miss_char
    , p7_a358  VARCHAR2 := fnd_api.g_miss_char
    , p7_a359  VARCHAR2 := fnd_api.g_miss_char
    , p7_a360  VARCHAR2 := fnd_api.g_miss_char
    , p7_a361  NUMBER := 0-1962.0724
    , p7_a362  NUMBER := 0-1962.0724
    , p7_a363  NUMBER := 0-1962.0724
    , p7_a364  NUMBER := 0-1962.0724
    , p7_a365  NUMBER := 0-1962.0724
    , p7_a366  NUMBER := 0-1962.0724
    , p7_a367  NUMBER := 0-1962.0724
    , p7_a368  NUMBER := 0-1962.0724
    , p7_a369  VARCHAR2 := fnd_api.g_miss_char
    , p7_a370  DATE := fnd_api.g_miss_date
    , p7_a371  VARCHAR2 := fnd_api.g_miss_char
    , p7_a372  VARCHAR2 := fnd_api.g_miss_char
    , p7_a373  VARCHAR2 := fnd_api.g_miss_char
    , p7_a374  VARCHAR2 := fnd_api.g_miss_char
    , p7_a375  DATE := fnd_api.g_miss_date
    , p7_a376  VARCHAR2 := fnd_api.g_miss_char
    , p7_a377  VARCHAR2 := fnd_api.g_miss_char
    , p7_a378  NUMBER := 0-1962.0724
    , p7_a379  NUMBER := 0-1962.0724
    , p7_a380  NUMBER := 0-1962.0724
    , p7_a381  VARCHAR2 := fnd_api.g_miss_char
    , p7_a382  VARCHAR2 := fnd_api.g_miss_char
    , p7_a383  VARCHAR2 := fnd_api.g_miss_char
    , p7_a384  NUMBER := 0-1962.0724
    , p7_a385  NUMBER := 0-1962.0724
    , p7_a386  NUMBER := 0-1962.0724
    , p7_a387  DATE := fnd_api.g_miss_date
  )
  as
    ddp_list_entries_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_list_entries_rec.list_entry_id := rosetta_g_miss_num_map(p7_a0);
    ddp_list_entries_rec.list_header_id := rosetta_g_miss_num_map(p7_a1);
    ddp_list_entries_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_list_entries_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_list_entries_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_list_entries_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_list_entries_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_list_entries_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_list_entries_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a8);
    ddp_list_entries_rec.arc_list_select_action_from := p7_a9;
    ddp_list_entries_rec.list_select_action_from_name := p7_a10;
    ddp_list_entries_rec.source_code := p7_a11;
    ddp_list_entries_rec.arc_list_used_by_source := p7_a12;
    ddp_list_entries_rec.source_code_for_id := rosetta_g_miss_num_map(p7_a13);
    ddp_list_entries_rec.pin_code := p7_a14;
    ddp_list_entries_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p7_a15);
    ddp_list_entries_rec.list_entry_source_system_type := p7_a16;
    ddp_list_entries_rec.view_application_id := rosetta_g_miss_num_map(p7_a17);
    ddp_list_entries_rec.manually_entered_flag := p7_a18;
    ddp_list_entries_rec.marked_as_duplicate_flag := p7_a19;
    ddp_list_entries_rec.marked_as_random_flag := p7_a20;
    ddp_list_entries_rec.part_of_control_group_flag := p7_a21;
    ddp_list_entries_rec.exclude_in_triggered_list_flag := p7_a22;
    ddp_list_entries_rec.enabled_flag := p7_a23;
    ddp_list_entries_rec.cell_code := p7_a24;
    ddp_list_entries_rec.dedupe_key := p7_a25;
    ddp_list_entries_rec.randomly_generated_number := rosetta_g_miss_num_map(p7_a26);
    ddp_list_entries_rec.campaign_id := rosetta_g_miss_num_map(p7_a27);
    ddp_list_entries_rec.media_id := rosetta_g_miss_num_map(p7_a28);
    ddp_list_entries_rec.channel_id := rosetta_g_miss_num_map(p7_a29);
    ddp_list_entries_rec.channel_schedule_id := rosetta_g_miss_num_map(p7_a30);
    ddp_list_entries_rec.event_offer_id := rosetta_g_miss_num_map(p7_a31);
    ddp_list_entries_rec.customer_id := rosetta_g_miss_num_map(p7_a32);
    ddp_list_entries_rec.market_segment_id := rosetta_g_miss_num_map(p7_a33);
    ddp_list_entries_rec.vendor_id := rosetta_g_miss_num_map(p7_a34);
    ddp_list_entries_rec.transfer_flag := p7_a35;
    ddp_list_entries_rec.transfer_status := p7_a36;
    ddp_list_entries_rec.list_source := p7_a37;
    ddp_list_entries_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p7_a38);
    ddp_list_entries_rec.marked_flag := p7_a39;
    ddp_list_entries_rec.lead_id := rosetta_g_miss_num_map(p7_a40);
    ddp_list_entries_rec.letter_id := rosetta_g_miss_num_map(p7_a41);
    ddp_list_entries_rec.picking_header_id := rosetta_g_miss_num_map(p7_a42);
    ddp_list_entries_rec.batch_id := rosetta_g_miss_num_map(p7_a43);
    ddp_list_entries_rec.suffix := p7_a44;
    ddp_list_entries_rec.first_name := p7_a45;
    ddp_list_entries_rec.last_name := p7_a46;
    ddp_list_entries_rec.customer_name := p7_a47;
    ddp_list_entries_rec.title := p7_a48;
    ddp_list_entries_rec.address_line1 := p7_a49;
    ddp_list_entries_rec.address_line2 := p7_a50;
    ddp_list_entries_rec.city := p7_a51;
    ddp_list_entries_rec.state := p7_a52;
    ddp_list_entries_rec.zipcode := p7_a53;
    ddp_list_entries_rec.country := p7_a54;
    ddp_list_entries_rec.fax := p7_a55;
    ddp_list_entries_rec.phone := p7_a56;
    ddp_list_entries_rec.email_address := p7_a57;
    ddp_list_entries_rec.col1 := p7_a58;
    ddp_list_entries_rec.col2 := p7_a59;
    ddp_list_entries_rec.col3 := p7_a60;
    ddp_list_entries_rec.col4 := p7_a61;
    ddp_list_entries_rec.col5 := p7_a62;
    ddp_list_entries_rec.col6 := p7_a63;
    ddp_list_entries_rec.col7 := p7_a64;
    ddp_list_entries_rec.col8 := p7_a65;
    ddp_list_entries_rec.col9 := p7_a66;
    ddp_list_entries_rec.col10 := p7_a67;
    ddp_list_entries_rec.col11 := p7_a68;
    ddp_list_entries_rec.col12 := p7_a69;
    ddp_list_entries_rec.col13 := p7_a70;
    ddp_list_entries_rec.col14 := p7_a71;
    ddp_list_entries_rec.col15 := p7_a72;
    ddp_list_entries_rec.col16 := p7_a73;
    ddp_list_entries_rec.col17 := p7_a74;
    ddp_list_entries_rec.col18 := p7_a75;
    ddp_list_entries_rec.col19 := p7_a76;
    ddp_list_entries_rec.col20 := p7_a77;
    ddp_list_entries_rec.col21 := p7_a78;
    ddp_list_entries_rec.col22 := p7_a79;
    ddp_list_entries_rec.col23 := p7_a80;
    ddp_list_entries_rec.col24 := p7_a81;
    ddp_list_entries_rec.col25 := p7_a82;
    ddp_list_entries_rec.col26 := p7_a83;
    ddp_list_entries_rec.col27 := p7_a84;
    ddp_list_entries_rec.col28 := p7_a85;
    ddp_list_entries_rec.col29 := p7_a86;
    ddp_list_entries_rec.col30 := p7_a87;
    ddp_list_entries_rec.col31 := p7_a88;
    ddp_list_entries_rec.col32 := p7_a89;
    ddp_list_entries_rec.col33 := p7_a90;
    ddp_list_entries_rec.col34 := p7_a91;
    ddp_list_entries_rec.col35 := p7_a92;
    ddp_list_entries_rec.col36 := p7_a93;
    ddp_list_entries_rec.col37 := p7_a94;
    ddp_list_entries_rec.col38 := p7_a95;
    ddp_list_entries_rec.col39 := p7_a96;
    ddp_list_entries_rec.col40 := p7_a97;
    ddp_list_entries_rec.col41 := p7_a98;
    ddp_list_entries_rec.col42 := p7_a99;
    ddp_list_entries_rec.col43 := p7_a100;
    ddp_list_entries_rec.col44 := p7_a101;
    ddp_list_entries_rec.col45 := p7_a102;
    ddp_list_entries_rec.col46 := p7_a103;
    ddp_list_entries_rec.col47 := p7_a104;
    ddp_list_entries_rec.col48 := p7_a105;
    ddp_list_entries_rec.col49 := p7_a106;
    ddp_list_entries_rec.col50 := p7_a107;
    ddp_list_entries_rec.col51 := p7_a108;
    ddp_list_entries_rec.col52 := p7_a109;
    ddp_list_entries_rec.col53 := p7_a110;
    ddp_list_entries_rec.col54 := p7_a111;
    ddp_list_entries_rec.col55 := p7_a112;
    ddp_list_entries_rec.col56 := p7_a113;
    ddp_list_entries_rec.col57 := p7_a114;
    ddp_list_entries_rec.col58 := p7_a115;
    ddp_list_entries_rec.col59 := p7_a116;
    ddp_list_entries_rec.col60 := p7_a117;
    ddp_list_entries_rec.col61 := p7_a118;
    ddp_list_entries_rec.col62 := p7_a119;
    ddp_list_entries_rec.col63 := p7_a120;
    ddp_list_entries_rec.col64 := p7_a121;
    ddp_list_entries_rec.col65 := p7_a122;
    ddp_list_entries_rec.col66 := p7_a123;
    ddp_list_entries_rec.col67 := p7_a124;
    ddp_list_entries_rec.col68 := p7_a125;
    ddp_list_entries_rec.col69 := p7_a126;
    ddp_list_entries_rec.col70 := p7_a127;
    ddp_list_entries_rec.col71 := p7_a128;
    ddp_list_entries_rec.col72 := p7_a129;
    ddp_list_entries_rec.col73 := p7_a130;
    ddp_list_entries_rec.col74 := p7_a131;
    ddp_list_entries_rec.col75 := p7_a132;
    ddp_list_entries_rec.col76 := p7_a133;
    ddp_list_entries_rec.col77 := p7_a134;
    ddp_list_entries_rec.col78 := p7_a135;
    ddp_list_entries_rec.col79 := p7_a136;
    ddp_list_entries_rec.col80 := p7_a137;
    ddp_list_entries_rec.col81 := p7_a138;
    ddp_list_entries_rec.col82 := p7_a139;
    ddp_list_entries_rec.col83 := p7_a140;
    ddp_list_entries_rec.col84 := p7_a141;
    ddp_list_entries_rec.col85 := p7_a142;
    ddp_list_entries_rec.col86 := p7_a143;
    ddp_list_entries_rec.col87 := p7_a144;
    ddp_list_entries_rec.col88 := p7_a145;
    ddp_list_entries_rec.col89 := p7_a146;
    ddp_list_entries_rec.col90 := p7_a147;
    ddp_list_entries_rec.col91 := p7_a148;
    ddp_list_entries_rec.col92 := p7_a149;
    ddp_list_entries_rec.col93 := p7_a150;
    ddp_list_entries_rec.col94 := p7_a151;
    ddp_list_entries_rec.col95 := p7_a152;
    ddp_list_entries_rec.col96 := p7_a153;
    ddp_list_entries_rec.col97 := p7_a154;
    ddp_list_entries_rec.col98 := p7_a155;
    ddp_list_entries_rec.col99 := p7_a156;
    ddp_list_entries_rec.col100 := p7_a157;
    ddp_list_entries_rec.col101 := p7_a158;
    ddp_list_entries_rec.col102 := p7_a159;
    ddp_list_entries_rec.col103 := p7_a160;
    ddp_list_entries_rec.col104 := p7_a161;
    ddp_list_entries_rec.col105 := p7_a162;
    ddp_list_entries_rec.col106 := p7_a163;
    ddp_list_entries_rec.col107 := p7_a164;
    ddp_list_entries_rec.col108 := p7_a165;
    ddp_list_entries_rec.col109 := p7_a166;
    ddp_list_entries_rec.col110 := p7_a167;
    ddp_list_entries_rec.col111 := p7_a168;
    ddp_list_entries_rec.col112 := p7_a169;
    ddp_list_entries_rec.col113 := p7_a170;
    ddp_list_entries_rec.col114 := p7_a171;
    ddp_list_entries_rec.col115 := p7_a172;
    ddp_list_entries_rec.col116 := p7_a173;
    ddp_list_entries_rec.col117 := p7_a174;
    ddp_list_entries_rec.col118 := p7_a175;
    ddp_list_entries_rec.col119 := p7_a176;
    ddp_list_entries_rec.col120 := p7_a177;
    ddp_list_entries_rec.col121 := p7_a178;
    ddp_list_entries_rec.col122 := p7_a179;
    ddp_list_entries_rec.col123 := p7_a180;
    ddp_list_entries_rec.col124 := p7_a181;
    ddp_list_entries_rec.col125 := p7_a182;
    ddp_list_entries_rec.col126 := p7_a183;
    ddp_list_entries_rec.col127 := p7_a184;
    ddp_list_entries_rec.col128 := p7_a185;
    ddp_list_entries_rec.col129 := p7_a186;
    ddp_list_entries_rec.col130 := p7_a187;
    ddp_list_entries_rec.col131 := p7_a188;
    ddp_list_entries_rec.col132 := p7_a189;
    ddp_list_entries_rec.col133 := p7_a190;
    ddp_list_entries_rec.col134 := p7_a191;
    ddp_list_entries_rec.col135 := p7_a192;
    ddp_list_entries_rec.col136 := p7_a193;
    ddp_list_entries_rec.col137 := p7_a194;
    ddp_list_entries_rec.col138 := p7_a195;
    ddp_list_entries_rec.col139 := p7_a196;
    ddp_list_entries_rec.col140 := p7_a197;
    ddp_list_entries_rec.col141 := p7_a198;
    ddp_list_entries_rec.col142 := p7_a199;
    ddp_list_entries_rec.col143 := p7_a200;
    ddp_list_entries_rec.col144 := p7_a201;
    ddp_list_entries_rec.col145 := p7_a202;
    ddp_list_entries_rec.col146 := p7_a203;
    ddp_list_entries_rec.col147 := p7_a204;
    ddp_list_entries_rec.col148 := p7_a205;
    ddp_list_entries_rec.col149 := p7_a206;
    ddp_list_entries_rec.col150 := p7_a207;
    ddp_list_entries_rec.col151 := p7_a208;
    ddp_list_entries_rec.col152 := p7_a209;
    ddp_list_entries_rec.col153 := p7_a210;
    ddp_list_entries_rec.col154 := p7_a211;
    ddp_list_entries_rec.col155 := p7_a212;
    ddp_list_entries_rec.col156 := p7_a213;
    ddp_list_entries_rec.col157 := p7_a214;
    ddp_list_entries_rec.col158 := p7_a215;
    ddp_list_entries_rec.col159 := p7_a216;
    ddp_list_entries_rec.col160 := p7_a217;
    ddp_list_entries_rec.col161 := p7_a218;
    ddp_list_entries_rec.col162 := p7_a219;
    ddp_list_entries_rec.col163 := p7_a220;
    ddp_list_entries_rec.col164 := p7_a221;
    ddp_list_entries_rec.col165 := p7_a222;
    ddp_list_entries_rec.col166 := p7_a223;
    ddp_list_entries_rec.col167 := p7_a224;
    ddp_list_entries_rec.col168 := p7_a225;
    ddp_list_entries_rec.col169 := p7_a226;
    ddp_list_entries_rec.col170 := p7_a227;
    ddp_list_entries_rec.col171 := p7_a228;
    ddp_list_entries_rec.col172 := p7_a229;
    ddp_list_entries_rec.col173 := p7_a230;
    ddp_list_entries_rec.col174 := p7_a231;
    ddp_list_entries_rec.col175 := p7_a232;
    ddp_list_entries_rec.col176 := p7_a233;
    ddp_list_entries_rec.col177 := p7_a234;
    ddp_list_entries_rec.col178 := p7_a235;
    ddp_list_entries_rec.col179 := p7_a236;
    ddp_list_entries_rec.col180 := p7_a237;
    ddp_list_entries_rec.col181 := p7_a238;
    ddp_list_entries_rec.col182 := p7_a239;
    ddp_list_entries_rec.col183 := p7_a240;
    ddp_list_entries_rec.col184 := p7_a241;
    ddp_list_entries_rec.col185 := p7_a242;
    ddp_list_entries_rec.col186 := p7_a243;
    ddp_list_entries_rec.col187 := p7_a244;
    ddp_list_entries_rec.col188 := p7_a245;
    ddp_list_entries_rec.col189 := p7_a246;
    ddp_list_entries_rec.col190 := p7_a247;
    ddp_list_entries_rec.col191 := p7_a248;
    ddp_list_entries_rec.col192 := p7_a249;
    ddp_list_entries_rec.col193 := p7_a250;
    ddp_list_entries_rec.col194 := p7_a251;
    ddp_list_entries_rec.col195 := p7_a252;
    ddp_list_entries_rec.col196 := p7_a253;
    ddp_list_entries_rec.col197 := p7_a254;
    ddp_list_entries_rec.col198 := p7_a255;
    ddp_list_entries_rec.col199 := p7_a256;
    ddp_list_entries_rec.col200 := p7_a257;
    ddp_list_entries_rec.col201 := p7_a258;
    ddp_list_entries_rec.col202 := p7_a259;
    ddp_list_entries_rec.col203 := p7_a260;
    ddp_list_entries_rec.col204 := p7_a261;
    ddp_list_entries_rec.col205 := p7_a262;
    ddp_list_entries_rec.col206 := p7_a263;
    ddp_list_entries_rec.col207 := p7_a264;
    ddp_list_entries_rec.col208 := p7_a265;
    ddp_list_entries_rec.col209 := p7_a266;
    ddp_list_entries_rec.col210 := p7_a267;
    ddp_list_entries_rec.col211 := p7_a268;
    ddp_list_entries_rec.col212 := p7_a269;
    ddp_list_entries_rec.col213 := p7_a270;
    ddp_list_entries_rec.col214 := p7_a271;
    ddp_list_entries_rec.col215 := p7_a272;
    ddp_list_entries_rec.col216 := p7_a273;
    ddp_list_entries_rec.col217 := p7_a274;
    ddp_list_entries_rec.col218 := p7_a275;
    ddp_list_entries_rec.col219 := p7_a276;
    ddp_list_entries_rec.col220 := p7_a277;
    ddp_list_entries_rec.col221 := p7_a278;
    ddp_list_entries_rec.col222 := p7_a279;
    ddp_list_entries_rec.col223 := p7_a280;
    ddp_list_entries_rec.col224 := p7_a281;
    ddp_list_entries_rec.col225 := p7_a282;
    ddp_list_entries_rec.col226 := p7_a283;
    ddp_list_entries_rec.col227 := p7_a284;
    ddp_list_entries_rec.col228 := p7_a285;
    ddp_list_entries_rec.col229 := p7_a286;
    ddp_list_entries_rec.col230 := p7_a287;
    ddp_list_entries_rec.col231 := p7_a288;
    ddp_list_entries_rec.col232 := p7_a289;
    ddp_list_entries_rec.col233 := p7_a290;
    ddp_list_entries_rec.col234 := p7_a291;
    ddp_list_entries_rec.col235 := p7_a292;
    ddp_list_entries_rec.col236 := p7_a293;
    ddp_list_entries_rec.col237 := p7_a294;
    ddp_list_entries_rec.col238 := p7_a295;
    ddp_list_entries_rec.col239 := p7_a296;
    ddp_list_entries_rec.col240 := p7_a297;
    ddp_list_entries_rec.col241 := p7_a298;
    ddp_list_entries_rec.col242 := p7_a299;
    ddp_list_entries_rec.col243 := p7_a300;
    ddp_list_entries_rec.col244 := p7_a301;
    ddp_list_entries_rec.col245 := p7_a302;
    ddp_list_entries_rec.col246 := p7_a303;
    ddp_list_entries_rec.col247 := p7_a304;
    ddp_list_entries_rec.col248 := p7_a305;
    ddp_list_entries_rec.col249 := p7_a306;
    ddp_list_entries_rec.col250 := p7_a307;
    ddp_list_entries_rec.col251 := p7_a308;
    ddp_list_entries_rec.col252 := p7_a309;
    ddp_list_entries_rec.col253 := p7_a310;
    ddp_list_entries_rec.col254 := p7_a311;
    ddp_list_entries_rec.col255 := p7_a312;
    ddp_list_entries_rec.col256 := p7_a313;
    ddp_list_entries_rec.col257 := p7_a314;
    ddp_list_entries_rec.col258 := p7_a315;
    ddp_list_entries_rec.col259 := p7_a316;
    ddp_list_entries_rec.col260 := p7_a317;
    ddp_list_entries_rec.col261 := p7_a318;
    ddp_list_entries_rec.col262 := p7_a319;
    ddp_list_entries_rec.col263 := p7_a320;
    ddp_list_entries_rec.col264 := p7_a321;
    ddp_list_entries_rec.col265 := p7_a322;
    ddp_list_entries_rec.col266 := p7_a323;
    ddp_list_entries_rec.col267 := p7_a324;
    ddp_list_entries_rec.col268 := p7_a325;
    ddp_list_entries_rec.col269 := p7_a326;
    ddp_list_entries_rec.col270 := p7_a327;
    ddp_list_entries_rec.col271 := p7_a328;
    ddp_list_entries_rec.col272 := p7_a329;
    ddp_list_entries_rec.col273 := p7_a330;
    ddp_list_entries_rec.col274 := p7_a331;
    ddp_list_entries_rec.col275 := p7_a332;
    ddp_list_entries_rec.col276 := p7_a333;
    ddp_list_entries_rec.col277 := p7_a334;
    ddp_list_entries_rec.col278 := p7_a335;
    ddp_list_entries_rec.col279 := p7_a336;
    ddp_list_entries_rec.col280 := p7_a337;
    ddp_list_entries_rec.col281 := p7_a338;
    ddp_list_entries_rec.col282 := p7_a339;
    ddp_list_entries_rec.col283 := p7_a340;
    ddp_list_entries_rec.col284 := p7_a341;
    ddp_list_entries_rec.col285 := p7_a342;
    ddp_list_entries_rec.col286 := p7_a343;
    ddp_list_entries_rec.col287 := p7_a344;
    ddp_list_entries_rec.col288 := p7_a345;
    ddp_list_entries_rec.col289 := p7_a346;
    ddp_list_entries_rec.col290 := p7_a347;
    ddp_list_entries_rec.col291 := p7_a348;
    ddp_list_entries_rec.col292 := p7_a349;
    ddp_list_entries_rec.col293 := p7_a350;
    ddp_list_entries_rec.col294 := p7_a351;
    ddp_list_entries_rec.col295 := p7_a352;
    ddp_list_entries_rec.col296 := p7_a353;
    ddp_list_entries_rec.col297 := p7_a354;
    ddp_list_entries_rec.col298 := p7_a355;
    ddp_list_entries_rec.col299 := p7_a356;
    ddp_list_entries_rec.col300 := p7_a357;
    ddp_list_entries_rec.curr_cp_country_code := p7_a358;
    ddp_list_entries_rec.curr_cp_phone_number := p7_a359;
    ddp_list_entries_rec.curr_cp_raw_phone_number := p7_a360;
    ddp_list_entries_rec.curr_cp_area_code := rosetta_g_miss_num_map(p7_a361);
    ddp_list_entries_rec.curr_cp_id := rosetta_g_miss_num_map(p7_a362);
    ddp_list_entries_rec.curr_cp_index := rosetta_g_miss_num_map(p7_a363);
    ddp_list_entries_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p7_a364);
    ddp_list_entries_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p7_a365);
    ddp_list_entries_rec.party_id := rosetta_g_miss_num_map(p7_a366);
    ddp_list_entries_rec.parent_party_id := rosetta_g_miss_num_map(p7_a367);
    ddp_list_entries_rec.imp_source_line_id := rosetta_g_miss_num_map(p7_a368);
    ddp_list_entries_rec.usage_restriction := p7_a369;
    ddp_list_entries_rec.next_call_time := rosetta_g_miss_date_in_map(p7_a370);
    ddp_list_entries_rec.callback_flag := p7_a371;
    ddp_list_entries_rec.do_not_use_flag := p7_a372;
    ddp_list_entries_rec.do_not_use_reason := p7_a373;
    ddp_list_entries_rec.record_out_flag := p7_a374;
    ddp_list_entries_rec.record_release_time := rosetta_g_miss_date_in_map(p7_a375);
    ddp_list_entries_rec.group_code := p7_a376;
    ddp_list_entries_rec.newly_updated_flag := p7_a377;
    ddp_list_entries_rec.outcome_id := rosetta_g_miss_num_map(p7_a378);
    ddp_list_entries_rec.result_id := rosetta_g_miss_num_map(p7_a379);
    ddp_list_entries_rec.reason_id := rosetta_g_miss_num_map(p7_a380);
    ddp_list_entries_rec.notes := p7_a381;
    ddp_list_entries_rec.vehicle_response_code := p7_a382;
    ddp_list_entries_rec.sales_agent_email_address := p7_a383;
    ddp_list_entries_rec.resource_id := rosetta_g_miss_num_map(p7_a384);
    ddp_list_entries_rec.location_id := rosetta_g_miss_num_map(p7_a385);
    ddp_list_entries_rec.contact_point_id := rosetta_g_miss_num_map(p7_a386);
    ddp_list_entries_rec.last_contacted_date := rosetta_g_miss_date_in_map(p7_a387);


    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.update_list_entries(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_entries_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_list_entries(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  NUMBER := 0-1962.0724
    , p4_a27  NUMBER := 0-1962.0724
    , p4_a28  NUMBER := 0-1962.0724
    , p4_a29  NUMBER := 0-1962.0724
    , p4_a30  NUMBER := 0-1962.0724
    , p4_a31  NUMBER := 0-1962.0724
    , p4_a32  NUMBER := 0-1962.0724
    , p4_a33  NUMBER := 0-1962.0724
    , p4_a34  NUMBER := 0-1962.0724
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  NUMBER := 0-1962.0724
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  NUMBER := 0-1962.0724
    , p4_a41  NUMBER := 0-1962.0724
    , p4_a42  NUMBER := 0-1962.0724
    , p4_a43  NUMBER := 0-1962.0724
    , p4_a44  VARCHAR2 := fnd_api.g_miss_char
    , p4_a45  VARCHAR2 := fnd_api.g_miss_char
    , p4_a46  VARCHAR2 := fnd_api.g_miss_char
    , p4_a47  VARCHAR2 := fnd_api.g_miss_char
    , p4_a48  VARCHAR2 := fnd_api.g_miss_char
    , p4_a49  VARCHAR2 := fnd_api.g_miss_char
    , p4_a50  VARCHAR2 := fnd_api.g_miss_char
    , p4_a51  VARCHAR2 := fnd_api.g_miss_char
    , p4_a52  VARCHAR2 := fnd_api.g_miss_char
    , p4_a53  VARCHAR2 := fnd_api.g_miss_char
    , p4_a54  VARCHAR2 := fnd_api.g_miss_char
    , p4_a55  VARCHAR2 := fnd_api.g_miss_char
    , p4_a56  VARCHAR2 := fnd_api.g_miss_char
    , p4_a57  VARCHAR2 := fnd_api.g_miss_char
    , p4_a58  VARCHAR2 := fnd_api.g_miss_char
    , p4_a59  VARCHAR2 := fnd_api.g_miss_char
    , p4_a60  VARCHAR2 := fnd_api.g_miss_char
    , p4_a61  VARCHAR2 := fnd_api.g_miss_char
    , p4_a62  VARCHAR2 := fnd_api.g_miss_char
    , p4_a63  VARCHAR2 := fnd_api.g_miss_char
    , p4_a64  VARCHAR2 := fnd_api.g_miss_char
    , p4_a65  VARCHAR2 := fnd_api.g_miss_char
    , p4_a66  VARCHAR2 := fnd_api.g_miss_char
    , p4_a67  VARCHAR2 := fnd_api.g_miss_char
    , p4_a68  VARCHAR2 := fnd_api.g_miss_char
    , p4_a69  VARCHAR2 := fnd_api.g_miss_char
    , p4_a70  VARCHAR2 := fnd_api.g_miss_char
    , p4_a71  VARCHAR2 := fnd_api.g_miss_char
    , p4_a72  VARCHAR2 := fnd_api.g_miss_char
    , p4_a73  VARCHAR2 := fnd_api.g_miss_char
    , p4_a74  VARCHAR2 := fnd_api.g_miss_char
    , p4_a75  VARCHAR2 := fnd_api.g_miss_char
    , p4_a76  VARCHAR2 := fnd_api.g_miss_char
    , p4_a77  VARCHAR2 := fnd_api.g_miss_char
    , p4_a78  VARCHAR2 := fnd_api.g_miss_char
    , p4_a79  VARCHAR2 := fnd_api.g_miss_char
    , p4_a80  VARCHAR2 := fnd_api.g_miss_char
    , p4_a81  VARCHAR2 := fnd_api.g_miss_char
    , p4_a82  VARCHAR2 := fnd_api.g_miss_char
    , p4_a83  VARCHAR2 := fnd_api.g_miss_char
    , p4_a84  VARCHAR2 := fnd_api.g_miss_char
    , p4_a85  VARCHAR2 := fnd_api.g_miss_char
    , p4_a86  VARCHAR2 := fnd_api.g_miss_char
    , p4_a87  VARCHAR2 := fnd_api.g_miss_char
    , p4_a88  VARCHAR2 := fnd_api.g_miss_char
    , p4_a89  VARCHAR2 := fnd_api.g_miss_char
    , p4_a90  VARCHAR2 := fnd_api.g_miss_char
    , p4_a91  VARCHAR2 := fnd_api.g_miss_char
    , p4_a92  VARCHAR2 := fnd_api.g_miss_char
    , p4_a93  VARCHAR2 := fnd_api.g_miss_char
    , p4_a94  VARCHAR2 := fnd_api.g_miss_char
    , p4_a95  VARCHAR2 := fnd_api.g_miss_char
    , p4_a96  VARCHAR2 := fnd_api.g_miss_char
    , p4_a97  VARCHAR2 := fnd_api.g_miss_char
    , p4_a98  VARCHAR2 := fnd_api.g_miss_char
    , p4_a99  VARCHAR2 := fnd_api.g_miss_char
    , p4_a100  VARCHAR2 := fnd_api.g_miss_char
    , p4_a101  VARCHAR2 := fnd_api.g_miss_char
    , p4_a102  VARCHAR2 := fnd_api.g_miss_char
    , p4_a103  VARCHAR2 := fnd_api.g_miss_char
    , p4_a104  VARCHAR2 := fnd_api.g_miss_char
    , p4_a105  VARCHAR2 := fnd_api.g_miss_char
    , p4_a106  VARCHAR2 := fnd_api.g_miss_char
    , p4_a107  VARCHAR2 := fnd_api.g_miss_char
    , p4_a108  VARCHAR2 := fnd_api.g_miss_char
    , p4_a109  VARCHAR2 := fnd_api.g_miss_char
    , p4_a110  VARCHAR2 := fnd_api.g_miss_char
    , p4_a111  VARCHAR2 := fnd_api.g_miss_char
    , p4_a112  VARCHAR2 := fnd_api.g_miss_char
    , p4_a113  VARCHAR2 := fnd_api.g_miss_char
    , p4_a114  VARCHAR2 := fnd_api.g_miss_char
    , p4_a115  VARCHAR2 := fnd_api.g_miss_char
    , p4_a116  VARCHAR2 := fnd_api.g_miss_char
    , p4_a117  VARCHAR2 := fnd_api.g_miss_char
    , p4_a118  VARCHAR2 := fnd_api.g_miss_char
    , p4_a119  VARCHAR2 := fnd_api.g_miss_char
    , p4_a120  VARCHAR2 := fnd_api.g_miss_char
    , p4_a121  VARCHAR2 := fnd_api.g_miss_char
    , p4_a122  VARCHAR2 := fnd_api.g_miss_char
    , p4_a123  VARCHAR2 := fnd_api.g_miss_char
    , p4_a124  VARCHAR2 := fnd_api.g_miss_char
    , p4_a125  VARCHAR2 := fnd_api.g_miss_char
    , p4_a126  VARCHAR2 := fnd_api.g_miss_char
    , p4_a127  VARCHAR2 := fnd_api.g_miss_char
    , p4_a128  VARCHAR2 := fnd_api.g_miss_char
    , p4_a129  VARCHAR2 := fnd_api.g_miss_char
    , p4_a130  VARCHAR2 := fnd_api.g_miss_char
    , p4_a131  VARCHAR2 := fnd_api.g_miss_char
    , p4_a132  VARCHAR2 := fnd_api.g_miss_char
    , p4_a133  VARCHAR2 := fnd_api.g_miss_char
    , p4_a134  VARCHAR2 := fnd_api.g_miss_char
    , p4_a135  VARCHAR2 := fnd_api.g_miss_char
    , p4_a136  VARCHAR2 := fnd_api.g_miss_char
    , p4_a137  VARCHAR2 := fnd_api.g_miss_char
    , p4_a138  VARCHAR2 := fnd_api.g_miss_char
    , p4_a139  VARCHAR2 := fnd_api.g_miss_char
    , p4_a140  VARCHAR2 := fnd_api.g_miss_char
    , p4_a141  VARCHAR2 := fnd_api.g_miss_char
    , p4_a142  VARCHAR2 := fnd_api.g_miss_char
    , p4_a143  VARCHAR2 := fnd_api.g_miss_char
    , p4_a144  VARCHAR2 := fnd_api.g_miss_char
    , p4_a145  VARCHAR2 := fnd_api.g_miss_char
    , p4_a146  VARCHAR2 := fnd_api.g_miss_char
    , p4_a147  VARCHAR2 := fnd_api.g_miss_char
    , p4_a148  VARCHAR2 := fnd_api.g_miss_char
    , p4_a149  VARCHAR2 := fnd_api.g_miss_char
    , p4_a150  VARCHAR2 := fnd_api.g_miss_char
    , p4_a151  VARCHAR2 := fnd_api.g_miss_char
    , p4_a152  VARCHAR2 := fnd_api.g_miss_char
    , p4_a153  VARCHAR2 := fnd_api.g_miss_char
    , p4_a154  VARCHAR2 := fnd_api.g_miss_char
    , p4_a155  VARCHAR2 := fnd_api.g_miss_char
    , p4_a156  VARCHAR2 := fnd_api.g_miss_char
    , p4_a157  VARCHAR2 := fnd_api.g_miss_char
    , p4_a158  VARCHAR2 := fnd_api.g_miss_char
    , p4_a159  VARCHAR2 := fnd_api.g_miss_char
    , p4_a160  VARCHAR2 := fnd_api.g_miss_char
    , p4_a161  VARCHAR2 := fnd_api.g_miss_char
    , p4_a162  VARCHAR2 := fnd_api.g_miss_char
    , p4_a163  VARCHAR2 := fnd_api.g_miss_char
    , p4_a164  VARCHAR2 := fnd_api.g_miss_char
    , p4_a165  VARCHAR2 := fnd_api.g_miss_char
    , p4_a166  VARCHAR2 := fnd_api.g_miss_char
    , p4_a167  VARCHAR2 := fnd_api.g_miss_char
    , p4_a168  VARCHAR2 := fnd_api.g_miss_char
    , p4_a169  VARCHAR2 := fnd_api.g_miss_char
    , p4_a170  VARCHAR2 := fnd_api.g_miss_char
    , p4_a171  VARCHAR2 := fnd_api.g_miss_char
    , p4_a172  VARCHAR2 := fnd_api.g_miss_char
    , p4_a173  VARCHAR2 := fnd_api.g_miss_char
    , p4_a174  VARCHAR2 := fnd_api.g_miss_char
    , p4_a175  VARCHAR2 := fnd_api.g_miss_char
    , p4_a176  VARCHAR2 := fnd_api.g_miss_char
    , p4_a177  VARCHAR2 := fnd_api.g_miss_char
    , p4_a178  VARCHAR2 := fnd_api.g_miss_char
    , p4_a179  VARCHAR2 := fnd_api.g_miss_char
    , p4_a180  VARCHAR2 := fnd_api.g_miss_char
    , p4_a181  VARCHAR2 := fnd_api.g_miss_char
    , p4_a182  VARCHAR2 := fnd_api.g_miss_char
    , p4_a183  VARCHAR2 := fnd_api.g_miss_char
    , p4_a184  VARCHAR2 := fnd_api.g_miss_char
    , p4_a185  VARCHAR2 := fnd_api.g_miss_char
    , p4_a186  VARCHAR2 := fnd_api.g_miss_char
    , p4_a187  VARCHAR2 := fnd_api.g_miss_char
    , p4_a188  VARCHAR2 := fnd_api.g_miss_char
    , p4_a189  VARCHAR2 := fnd_api.g_miss_char
    , p4_a190  VARCHAR2 := fnd_api.g_miss_char
    , p4_a191  VARCHAR2 := fnd_api.g_miss_char
    , p4_a192  VARCHAR2 := fnd_api.g_miss_char
    , p4_a193  VARCHAR2 := fnd_api.g_miss_char
    , p4_a194  VARCHAR2 := fnd_api.g_miss_char
    , p4_a195  VARCHAR2 := fnd_api.g_miss_char
    , p4_a196  VARCHAR2 := fnd_api.g_miss_char
    , p4_a197  VARCHAR2 := fnd_api.g_miss_char
    , p4_a198  VARCHAR2 := fnd_api.g_miss_char
    , p4_a199  VARCHAR2 := fnd_api.g_miss_char
    , p4_a200  VARCHAR2 := fnd_api.g_miss_char
    , p4_a201  VARCHAR2 := fnd_api.g_miss_char
    , p4_a202  VARCHAR2 := fnd_api.g_miss_char
    , p4_a203  VARCHAR2 := fnd_api.g_miss_char
    , p4_a204  VARCHAR2 := fnd_api.g_miss_char
    , p4_a205  VARCHAR2 := fnd_api.g_miss_char
    , p4_a206  VARCHAR2 := fnd_api.g_miss_char
    , p4_a207  VARCHAR2 := fnd_api.g_miss_char
    , p4_a208  VARCHAR2 := fnd_api.g_miss_char
    , p4_a209  VARCHAR2 := fnd_api.g_miss_char
    , p4_a210  VARCHAR2 := fnd_api.g_miss_char
    , p4_a211  VARCHAR2 := fnd_api.g_miss_char
    , p4_a212  VARCHAR2 := fnd_api.g_miss_char
    , p4_a213  VARCHAR2 := fnd_api.g_miss_char
    , p4_a214  VARCHAR2 := fnd_api.g_miss_char
    , p4_a215  VARCHAR2 := fnd_api.g_miss_char
    , p4_a216  VARCHAR2 := fnd_api.g_miss_char
    , p4_a217  VARCHAR2 := fnd_api.g_miss_char
    , p4_a218  VARCHAR2 := fnd_api.g_miss_char
    , p4_a219  VARCHAR2 := fnd_api.g_miss_char
    , p4_a220  VARCHAR2 := fnd_api.g_miss_char
    , p4_a221  VARCHAR2 := fnd_api.g_miss_char
    , p4_a222  VARCHAR2 := fnd_api.g_miss_char
    , p4_a223  VARCHAR2 := fnd_api.g_miss_char
    , p4_a224  VARCHAR2 := fnd_api.g_miss_char
    , p4_a225  VARCHAR2 := fnd_api.g_miss_char
    , p4_a226  VARCHAR2 := fnd_api.g_miss_char
    , p4_a227  VARCHAR2 := fnd_api.g_miss_char
    , p4_a228  VARCHAR2 := fnd_api.g_miss_char
    , p4_a229  VARCHAR2 := fnd_api.g_miss_char
    , p4_a230  VARCHAR2 := fnd_api.g_miss_char
    , p4_a231  VARCHAR2 := fnd_api.g_miss_char
    , p4_a232  VARCHAR2 := fnd_api.g_miss_char
    , p4_a233  VARCHAR2 := fnd_api.g_miss_char
    , p4_a234  VARCHAR2 := fnd_api.g_miss_char
    , p4_a235  VARCHAR2 := fnd_api.g_miss_char
    , p4_a236  VARCHAR2 := fnd_api.g_miss_char
    , p4_a237  VARCHAR2 := fnd_api.g_miss_char
    , p4_a238  VARCHAR2 := fnd_api.g_miss_char
    , p4_a239  VARCHAR2 := fnd_api.g_miss_char
    , p4_a240  VARCHAR2 := fnd_api.g_miss_char
    , p4_a241  VARCHAR2 := fnd_api.g_miss_char
    , p4_a242  VARCHAR2 := fnd_api.g_miss_char
    , p4_a243  VARCHAR2 := fnd_api.g_miss_char
    , p4_a244  VARCHAR2 := fnd_api.g_miss_char
    , p4_a245  VARCHAR2 := fnd_api.g_miss_char
    , p4_a246  VARCHAR2 := fnd_api.g_miss_char
    , p4_a247  VARCHAR2 := fnd_api.g_miss_char
    , p4_a248  VARCHAR2 := fnd_api.g_miss_char
    , p4_a249  VARCHAR2 := fnd_api.g_miss_char
    , p4_a250  VARCHAR2 := fnd_api.g_miss_char
    , p4_a251  VARCHAR2 := fnd_api.g_miss_char
    , p4_a252  VARCHAR2 := fnd_api.g_miss_char
    , p4_a253  VARCHAR2 := fnd_api.g_miss_char
    , p4_a254  VARCHAR2 := fnd_api.g_miss_char
    , p4_a255  VARCHAR2 := fnd_api.g_miss_char
    , p4_a256  VARCHAR2 := fnd_api.g_miss_char
    , p4_a257  VARCHAR2 := fnd_api.g_miss_char
    , p4_a258  VARCHAR2 := fnd_api.g_miss_char
    , p4_a259  VARCHAR2 := fnd_api.g_miss_char
    , p4_a260  VARCHAR2 := fnd_api.g_miss_char
    , p4_a261  VARCHAR2 := fnd_api.g_miss_char
    , p4_a262  VARCHAR2 := fnd_api.g_miss_char
    , p4_a263  VARCHAR2 := fnd_api.g_miss_char
    , p4_a264  VARCHAR2 := fnd_api.g_miss_char
    , p4_a265  VARCHAR2 := fnd_api.g_miss_char
    , p4_a266  VARCHAR2 := fnd_api.g_miss_char
    , p4_a267  VARCHAR2 := fnd_api.g_miss_char
    , p4_a268  VARCHAR2 := fnd_api.g_miss_char
    , p4_a269  VARCHAR2 := fnd_api.g_miss_char
    , p4_a270  VARCHAR2 := fnd_api.g_miss_char
    , p4_a271  VARCHAR2 := fnd_api.g_miss_char
    , p4_a272  VARCHAR2 := fnd_api.g_miss_char
    , p4_a273  VARCHAR2 := fnd_api.g_miss_char
    , p4_a274  VARCHAR2 := fnd_api.g_miss_char
    , p4_a275  VARCHAR2 := fnd_api.g_miss_char
    , p4_a276  VARCHAR2 := fnd_api.g_miss_char
    , p4_a277  VARCHAR2 := fnd_api.g_miss_char
    , p4_a278  VARCHAR2 := fnd_api.g_miss_char
    , p4_a279  VARCHAR2 := fnd_api.g_miss_char
    , p4_a280  VARCHAR2 := fnd_api.g_miss_char
    , p4_a281  VARCHAR2 := fnd_api.g_miss_char
    , p4_a282  VARCHAR2 := fnd_api.g_miss_char
    , p4_a283  VARCHAR2 := fnd_api.g_miss_char
    , p4_a284  VARCHAR2 := fnd_api.g_miss_char
    , p4_a285  VARCHAR2 := fnd_api.g_miss_char
    , p4_a286  VARCHAR2 := fnd_api.g_miss_char
    , p4_a287  VARCHAR2 := fnd_api.g_miss_char
    , p4_a288  VARCHAR2 := fnd_api.g_miss_char
    , p4_a289  VARCHAR2 := fnd_api.g_miss_char
    , p4_a290  VARCHAR2 := fnd_api.g_miss_char
    , p4_a291  VARCHAR2 := fnd_api.g_miss_char
    , p4_a292  VARCHAR2 := fnd_api.g_miss_char
    , p4_a293  VARCHAR2 := fnd_api.g_miss_char
    , p4_a294  VARCHAR2 := fnd_api.g_miss_char
    , p4_a295  VARCHAR2 := fnd_api.g_miss_char
    , p4_a296  VARCHAR2 := fnd_api.g_miss_char
    , p4_a297  VARCHAR2 := fnd_api.g_miss_char
    , p4_a298  VARCHAR2 := fnd_api.g_miss_char
    , p4_a299  VARCHAR2 := fnd_api.g_miss_char
    , p4_a300  VARCHAR2 := fnd_api.g_miss_char
    , p4_a301  VARCHAR2 := fnd_api.g_miss_char
    , p4_a302  VARCHAR2 := fnd_api.g_miss_char
    , p4_a303  VARCHAR2 := fnd_api.g_miss_char
    , p4_a304  VARCHAR2 := fnd_api.g_miss_char
    , p4_a305  VARCHAR2 := fnd_api.g_miss_char
    , p4_a306  VARCHAR2 := fnd_api.g_miss_char
    , p4_a307  VARCHAR2 := fnd_api.g_miss_char
    , p4_a308  VARCHAR2 := fnd_api.g_miss_char
    , p4_a309  VARCHAR2 := fnd_api.g_miss_char
    , p4_a310  VARCHAR2 := fnd_api.g_miss_char
    , p4_a311  VARCHAR2 := fnd_api.g_miss_char
    , p4_a312  VARCHAR2 := fnd_api.g_miss_char
    , p4_a313  VARCHAR2 := fnd_api.g_miss_char
    , p4_a314  VARCHAR2 := fnd_api.g_miss_char
    , p4_a315  VARCHAR2 := fnd_api.g_miss_char
    , p4_a316  VARCHAR2 := fnd_api.g_miss_char
    , p4_a317  VARCHAR2 := fnd_api.g_miss_char
    , p4_a318  VARCHAR2 := fnd_api.g_miss_char
    , p4_a319  VARCHAR2 := fnd_api.g_miss_char
    , p4_a320  VARCHAR2 := fnd_api.g_miss_char
    , p4_a321  VARCHAR2 := fnd_api.g_miss_char
    , p4_a322  VARCHAR2 := fnd_api.g_miss_char
    , p4_a323  VARCHAR2 := fnd_api.g_miss_char
    , p4_a324  VARCHAR2 := fnd_api.g_miss_char
    , p4_a325  VARCHAR2 := fnd_api.g_miss_char
    , p4_a326  VARCHAR2 := fnd_api.g_miss_char
    , p4_a327  VARCHAR2 := fnd_api.g_miss_char
    , p4_a328  VARCHAR2 := fnd_api.g_miss_char
    , p4_a329  VARCHAR2 := fnd_api.g_miss_char
    , p4_a330  VARCHAR2 := fnd_api.g_miss_char
    , p4_a331  VARCHAR2 := fnd_api.g_miss_char
    , p4_a332  VARCHAR2 := fnd_api.g_miss_char
    , p4_a333  VARCHAR2 := fnd_api.g_miss_char
    , p4_a334  VARCHAR2 := fnd_api.g_miss_char
    , p4_a335  VARCHAR2 := fnd_api.g_miss_char
    , p4_a336  VARCHAR2 := fnd_api.g_miss_char
    , p4_a337  VARCHAR2 := fnd_api.g_miss_char
    , p4_a338  VARCHAR2 := fnd_api.g_miss_char
    , p4_a339  VARCHAR2 := fnd_api.g_miss_char
    , p4_a340  VARCHAR2 := fnd_api.g_miss_char
    , p4_a341  VARCHAR2 := fnd_api.g_miss_char
    , p4_a342  VARCHAR2 := fnd_api.g_miss_char
    , p4_a343  VARCHAR2 := fnd_api.g_miss_char
    , p4_a344  VARCHAR2 := fnd_api.g_miss_char
    , p4_a345  VARCHAR2 := fnd_api.g_miss_char
    , p4_a346  VARCHAR2 := fnd_api.g_miss_char
    , p4_a347  VARCHAR2 := fnd_api.g_miss_char
    , p4_a348  VARCHAR2 := fnd_api.g_miss_char
    , p4_a349  VARCHAR2 := fnd_api.g_miss_char
    , p4_a350  VARCHAR2 := fnd_api.g_miss_char
    , p4_a351  VARCHAR2 := fnd_api.g_miss_char
    , p4_a352  VARCHAR2 := fnd_api.g_miss_char
    , p4_a353  VARCHAR2 := fnd_api.g_miss_char
    , p4_a354  VARCHAR2 := fnd_api.g_miss_char
    , p4_a355  VARCHAR2 := fnd_api.g_miss_char
    , p4_a356  VARCHAR2 := fnd_api.g_miss_char
    , p4_a357  VARCHAR2 := fnd_api.g_miss_char
    , p4_a358  VARCHAR2 := fnd_api.g_miss_char
    , p4_a359  VARCHAR2 := fnd_api.g_miss_char
    , p4_a360  VARCHAR2 := fnd_api.g_miss_char
    , p4_a361  NUMBER := 0-1962.0724
    , p4_a362  NUMBER := 0-1962.0724
    , p4_a363  NUMBER := 0-1962.0724
    , p4_a364  NUMBER := 0-1962.0724
    , p4_a365  NUMBER := 0-1962.0724
    , p4_a366  NUMBER := 0-1962.0724
    , p4_a367  NUMBER := 0-1962.0724
    , p4_a368  NUMBER := 0-1962.0724
    , p4_a369  VARCHAR2 := fnd_api.g_miss_char
    , p4_a370  DATE := fnd_api.g_miss_date
    , p4_a371  VARCHAR2 := fnd_api.g_miss_char
    , p4_a372  VARCHAR2 := fnd_api.g_miss_char
    , p4_a373  VARCHAR2 := fnd_api.g_miss_char
    , p4_a374  VARCHAR2 := fnd_api.g_miss_char
    , p4_a375  DATE := fnd_api.g_miss_date
    , p4_a376  VARCHAR2 := fnd_api.g_miss_char
    , p4_a377  VARCHAR2 := fnd_api.g_miss_char
    , p4_a378  NUMBER := 0-1962.0724
    , p4_a379  NUMBER := 0-1962.0724
    , p4_a380  NUMBER := 0-1962.0724
    , p4_a381  VARCHAR2 := fnd_api.g_miss_char
    , p4_a382  VARCHAR2 := fnd_api.g_miss_char
    , p4_a383  VARCHAR2 := fnd_api.g_miss_char
    , p4_a384  NUMBER := 0-1962.0724
    , p4_a385  NUMBER := 0-1962.0724
    , p4_a386  NUMBER := 0-1962.0724
    , p4_a387  DATE := fnd_api.g_miss_date
  )
  as
    ddp_list_entries_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_list_entries_rec.list_entry_id := rosetta_g_miss_num_map(p4_a0);
    ddp_list_entries_rec.list_header_id := rosetta_g_miss_num_map(p4_a1);
    ddp_list_entries_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a2);
    ddp_list_entries_rec.last_updated_by := rosetta_g_miss_num_map(p4_a3);
    ddp_list_entries_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_list_entries_rec.created_by := rosetta_g_miss_num_map(p4_a5);
    ddp_list_entries_rec.last_update_login := rosetta_g_miss_num_map(p4_a6);
    ddp_list_entries_rec.object_version_number := rosetta_g_miss_num_map(p4_a7);
    ddp_list_entries_rec.list_select_action_id := rosetta_g_miss_num_map(p4_a8);
    ddp_list_entries_rec.arc_list_select_action_from := p4_a9;
    ddp_list_entries_rec.list_select_action_from_name := p4_a10;
    ddp_list_entries_rec.source_code := p4_a11;
    ddp_list_entries_rec.arc_list_used_by_source := p4_a12;
    ddp_list_entries_rec.source_code_for_id := rosetta_g_miss_num_map(p4_a13);
    ddp_list_entries_rec.pin_code := p4_a14;
    ddp_list_entries_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p4_a15);
    ddp_list_entries_rec.list_entry_source_system_type := p4_a16;
    ddp_list_entries_rec.view_application_id := rosetta_g_miss_num_map(p4_a17);
    ddp_list_entries_rec.manually_entered_flag := p4_a18;
    ddp_list_entries_rec.marked_as_duplicate_flag := p4_a19;
    ddp_list_entries_rec.marked_as_random_flag := p4_a20;
    ddp_list_entries_rec.part_of_control_group_flag := p4_a21;
    ddp_list_entries_rec.exclude_in_triggered_list_flag := p4_a22;
    ddp_list_entries_rec.enabled_flag := p4_a23;
    ddp_list_entries_rec.cell_code := p4_a24;
    ddp_list_entries_rec.dedupe_key := p4_a25;
    ddp_list_entries_rec.randomly_generated_number := rosetta_g_miss_num_map(p4_a26);
    ddp_list_entries_rec.campaign_id := rosetta_g_miss_num_map(p4_a27);
    ddp_list_entries_rec.media_id := rosetta_g_miss_num_map(p4_a28);
    ddp_list_entries_rec.channel_id := rosetta_g_miss_num_map(p4_a29);
    ddp_list_entries_rec.channel_schedule_id := rosetta_g_miss_num_map(p4_a30);
    ddp_list_entries_rec.event_offer_id := rosetta_g_miss_num_map(p4_a31);
    ddp_list_entries_rec.customer_id := rosetta_g_miss_num_map(p4_a32);
    ddp_list_entries_rec.market_segment_id := rosetta_g_miss_num_map(p4_a33);
    ddp_list_entries_rec.vendor_id := rosetta_g_miss_num_map(p4_a34);
    ddp_list_entries_rec.transfer_flag := p4_a35;
    ddp_list_entries_rec.transfer_status := p4_a36;
    ddp_list_entries_rec.list_source := p4_a37;
    ddp_list_entries_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p4_a38);
    ddp_list_entries_rec.marked_flag := p4_a39;
    ddp_list_entries_rec.lead_id := rosetta_g_miss_num_map(p4_a40);
    ddp_list_entries_rec.letter_id := rosetta_g_miss_num_map(p4_a41);
    ddp_list_entries_rec.picking_header_id := rosetta_g_miss_num_map(p4_a42);
    ddp_list_entries_rec.batch_id := rosetta_g_miss_num_map(p4_a43);
    ddp_list_entries_rec.suffix := p4_a44;
    ddp_list_entries_rec.first_name := p4_a45;
    ddp_list_entries_rec.last_name := p4_a46;
    ddp_list_entries_rec.customer_name := p4_a47;
    ddp_list_entries_rec.title := p4_a48;
    ddp_list_entries_rec.address_line1 := p4_a49;
    ddp_list_entries_rec.address_line2 := p4_a50;
    ddp_list_entries_rec.city := p4_a51;
    ddp_list_entries_rec.state := p4_a52;
    ddp_list_entries_rec.zipcode := p4_a53;
    ddp_list_entries_rec.country := p4_a54;
    ddp_list_entries_rec.fax := p4_a55;
    ddp_list_entries_rec.phone := p4_a56;
    ddp_list_entries_rec.email_address := p4_a57;
    ddp_list_entries_rec.col1 := p4_a58;
    ddp_list_entries_rec.col2 := p4_a59;
    ddp_list_entries_rec.col3 := p4_a60;
    ddp_list_entries_rec.col4 := p4_a61;
    ddp_list_entries_rec.col5 := p4_a62;
    ddp_list_entries_rec.col6 := p4_a63;
    ddp_list_entries_rec.col7 := p4_a64;
    ddp_list_entries_rec.col8 := p4_a65;
    ddp_list_entries_rec.col9 := p4_a66;
    ddp_list_entries_rec.col10 := p4_a67;
    ddp_list_entries_rec.col11 := p4_a68;
    ddp_list_entries_rec.col12 := p4_a69;
    ddp_list_entries_rec.col13 := p4_a70;
    ddp_list_entries_rec.col14 := p4_a71;
    ddp_list_entries_rec.col15 := p4_a72;
    ddp_list_entries_rec.col16 := p4_a73;
    ddp_list_entries_rec.col17 := p4_a74;
    ddp_list_entries_rec.col18 := p4_a75;
    ddp_list_entries_rec.col19 := p4_a76;
    ddp_list_entries_rec.col20 := p4_a77;
    ddp_list_entries_rec.col21 := p4_a78;
    ddp_list_entries_rec.col22 := p4_a79;
    ddp_list_entries_rec.col23 := p4_a80;
    ddp_list_entries_rec.col24 := p4_a81;
    ddp_list_entries_rec.col25 := p4_a82;
    ddp_list_entries_rec.col26 := p4_a83;
    ddp_list_entries_rec.col27 := p4_a84;
    ddp_list_entries_rec.col28 := p4_a85;
    ddp_list_entries_rec.col29 := p4_a86;
    ddp_list_entries_rec.col30 := p4_a87;
    ddp_list_entries_rec.col31 := p4_a88;
    ddp_list_entries_rec.col32 := p4_a89;
    ddp_list_entries_rec.col33 := p4_a90;
    ddp_list_entries_rec.col34 := p4_a91;
    ddp_list_entries_rec.col35 := p4_a92;
    ddp_list_entries_rec.col36 := p4_a93;
    ddp_list_entries_rec.col37 := p4_a94;
    ddp_list_entries_rec.col38 := p4_a95;
    ddp_list_entries_rec.col39 := p4_a96;
    ddp_list_entries_rec.col40 := p4_a97;
    ddp_list_entries_rec.col41 := p4_a98;
    ddp_list_entries_rec.col42 := p4_a99;
    ddp_list_entries_rec.col43 := p4_a100;
    ddp_list_entries_rec.col44 := p4_a101;
    ddp_list_entries_rec.col45 := p4_a102;
    ddp_list_entries_rec.col46 := p4_a103;
    ddp_list_entries_rec.col47 := p4_a104;
    ddp_list_entries_rec.col48 := p4_a105;
    ddp_list_entries_rec.col49 := p4_a106;
    ddp_list_entries_rec.col50 := p4_a107;
    ddp_list_entries_rec.col51 := p4_a108;
    ddp_list_entries_rec.col52 := p4_a109;
    ddp_list_entries_rec.col53 := p4_a110;
    ddp_list_entries_rec.col54 := p4_a111;
    ddp_list_entries_rec.col55 := p4_a112;
    ddp_list_entries_rec.col56 := p4_a113;
    ddp_list_entries_rec.col57 := p4_a114;
    ddp_list_entries_rec.col58 := p4_a115;
    ddp_list_entries_rec.col59 := p4_a116;
    ddp_list_entries_rec.col60 := p4_a117;
    ddp_list_entries_rec.col61 := p4_a118;
    ddp_list_entries_rec.col62 := p4_a119;
    ddp_list_entries_rec.col63 := p4_a120;
    ddp_list_entries_rec.col64 := p4_a121;
    ddp_list_entries_rec.col65 := p4_a122;
    ddp_list_entries_rec.col66 := p4_a123;
    ddp_list_entries_rec.col67 := p4_a124;
    ddp_list_entries_rec.col68 := p4_a125;
    ddp_list_entries_rec.col69 := p4_a126;
    ddp_list_entries_rec.col70 := p4_a127;
    ddp_list_entries_rec.col71 := p4_a128;
    ddp_list_entries_rec.col72 := p4_a129;
    ddp_list_entries_rec.col73 := p4_a130;
    ddp_list_entries_rec.col74 := p4_a131;
    ddp_list_entries_rec.col75 := p4_a132;
    ddp_list_entries_rec.col76 := p4_a133;
    ddp_list_entries_rec.col77 := p4_a134;
    ddp_list_entries_rec.col78 := p4_a135;
    ddp_list_entries_rec.col79 := p4_a136;
    ddp_list_entries_rec.col80 := p4_a137;
    ddp_list_entries_rec.col81 := p4_a138;
    ddp_list_entries_rec.col82 := p4_a139;
    ddp_list_entries_rec.col83 := p4_a140;
    ddp_list_entries_rec.col84 := p4_a141;
    ddp_list_entries_rec.col85 := p4_a142;
    ddp_list_entries_rec.col86 := p4_a143;
    ddp_list_entries_rec.col87 := p4_a144;
    ddp_list_entries_rec.col88 := p4_a145;
    ddp_list_entries_rec.col89 := p4_a146;
    ddp_list_entries_rec.col90 := p4_a147;
    ddp_list_entries_rec.col91 := p4_a148;
    ddp_list_entries_rec.col92 := p4_a149;
    ddp_list_entries_rec.col93 := p4_a150;
    ddp_list_entries_rec.col94 := p4_a151;
    ddp_list_entries_rec.col95 := p4_a152;
    ddp_list_entries_rec.col96 := p4_a153;
    ddp_list_entries_rec.col97 := p4_a154;
    ddp_list_entries_rec.col98 := p4_a155;
    ddp_list_entries_rec.col99 := p4_a156;
    ddp_list_entries_rec.col100 := p4_a157;
    ddp_list_entries_rec.col101 := p4_a158;
    ddp_list_entries_rec.col102 := p4_a159;
    ddp_list_entries_rec.col103 := p4_a160;
    ddp_list_entries_rec.col104 := p4_a161;
    ddp_list_entries_rec.col105 := p4_a162;
    ddp_list_entries_rec.col106 := p4_a163;
    ddp_list_entries_rec.col107 := p4_a164;
    ddp_list_entries_rec.col108 := p4_a165;
    ddp_list_entries_rec.col109 := p4_a166;
    ddp_list_entries_rec.col110 := p4_a167;
    ddp_list_entries_rec.col111 := p4_a168;
    ddp_list_entries_rec.col112 := p4_a169;
    ddp_list_entries_rec.col113 := p4_a170;
    ddp_list_entries_rec.col114 := p4_a171;
    ddp_list_entries_rec.col115 := p4_a172;
    ddp_list_entries_rec.col116 := p4_a173;
    ddp_list_entries_rec.col117 := p4_a174;
    ddp_list_entries_rec.col118 := p4_a175;
    ddp_list_entries_rec.col119 := p4_a176;
    ddp_list_entries_rec.col120 := p4_a177;
    ddp_list_entries_rec.col121 := p4_a178;
    ddp_list_entries_rec.col122 := p4_a179;
    ddp_list_entries_rec.col123 := p4_a180;
    ddp_list_entries_rec.col124 := p4_a181;
    ddp_list_entries_rec.col125 := p4_a182;
    ddp_list_entries_rec.col126 := p4_a183;
    ddp_list_entries_rec.col127 := p4_a184;
    ddp_list_entries_rec.col128 := p4_a185;
    ddp_list_entries_rec.col129 := p4_a186;
    ddp_list_entries_rec.col130 := p4_a187;
    ddp_list_entries_rec.col131 := p4_a188;
    ddp_list_entries_rec.col132 := p4_a189;
    ddp_list_entries_rec.col133 := p4_a190;
    ddp_list_entries_rec.col134 := p4_a191;
    ddp_list_entries_rec.col135 := p4_a192;
    ddp_list_entries_rec.col136 := p4_a193;
    ddp_list_entries_rec.col137 := p4_a194;
    ddp_list_entries_rec.col138 := p4_a195;
    ddp_list_entries_rec.col139 := p4_a196;
    ddp_list_entries_rec.col140 := p4_a197;
    ddp_list_entries_rec.col141 := p4_a198;
    ddp_list_entries_rec.col142 := p4_a199;
    ddp_list_entries_rec.col143 := p4_a200;
    ddp_list_entries_rec.col144 := p4_a201;
    ddp_list_entries_rec.col145 := p4_a202;
    ddp_list_entries_rec.col146 := p4_a203;
    ddp_list_entries_rec.col147 := p4_a204;
    ddp_list_entries_rec.col148 := p4_a205;
    ddp_list_entries_rec.col149 := p4_a206;
    ddp_list_entries_rec.col150 := p4_a207;
    ddp_list_entries_rec.col151 := p4_a208;
    ddp_list_entries_rec.col152 := p4_a209;
    ddp_list_entries_rec.col153 := p4_a210;
    ddp_list_entries_rec.col154 := p4_a211;
    ddp_list_entries_rec.col155 := p4_a212;
    ddp_list_entries_rec.col156 := p4_a213;
    ddp_list_entries_rec.col157 := p4_a214;
    ddp_list_entries_rec.col158 := p4_a215;
    ddp_list_entries_rec.col159 := p4_a216;
    ddp_list_entries_rec.col160 := p4_a217;
    ddp_list_entries_rec.col161 := p4_a218;
    ddp_list_entries_rec.col162 := p4_a219;
    ddp_list_entries_rec.col163 := p4_a220;
    ddp_list_entries_rec.col164 := p4_a221;
    ddp_list_entries_rec.col165 := p4_a222;
    ddp_list_entries_rec.col166 := p4_a223;
    ddp_list_entries_rec.col167 := p4_a224;
    ddp_list_entries_rec.col168 := p4_a225;
    ddp_list_entries_rec.col169 := p4_a226;
    ddp_list_entries_rec.col170 := p4_a227;
    ddp_list_entries_rec.col171 := p4_a228;
    ddp_list_entries_rec.col172 := p4_a229;
    ddp_list_entries_rec.col173 := p4_a230;
    ddp_list_entries_rec.col174 := p4_a231;
    ddp_list_entries_rec.col175 := p4_a232;
    ddp_list_entries_rec.col176 := p4_a233;
    ddp_list_entries_rec.col177 := p4_a234;
    ddp_list_entries_rec.col178 := p4_a235;
    ddp_list_entries_rec.col179 := p4_a236;
    ddp_list_entries_rec.col180 := p4_a237;
    ddp_list_entries_rec.col181 := p4_a238;
    ddp_list_entries_rec.col182 := p4_a239;
    ddp_list_entries_rec.col183 := p4_a240;
    ddp_list_entries_rec.col184 := p4_a241;
    ddp_list_entries_rec.col185 := p4_a242;
    ddp_list_entries_rec.col186 := p4_a243;
    ddp_list_entries_rec.col187 := p4_a244;
    ddp_list_entries_rec.col188 := p4_a245;
    ddp_list_entries_rec.col189 := p4_a246;
    ddp_list_entries_rec.col190 := p4_a247;
    ddp_list_entries_rec.col191 := p4_a248;
    ddp_list_entries_rec.col192 := p4_a249;
    ddp_list_entries_rec.col193 := p4_a250;
    ddp_list_entries_rec.col194 := p4_a251;
    ddp_list_entries_rec.col195 := p4_a252;
    ddp_list_entries_rec.col196 := p4_a253;
    ddp_list_entries_rec.col197 := p4_a254;
    ddp_list_entries_rec.col198 := p4_a255;
    ddp_list_entries_rec.col199 := p4_a256;
    ddp_list_entries_rec.col200 := p4_a257;
    ddp_list_entries_rec.col201 := p4_a258;
    ddp_list_entries_rec.col202 := p4_a259;
    ddp_list_entries_rec.col203 := p4_a260;
    ddp_list_entries_rec.col204 := p4_a261;
    ddp_list_entries_rec.col205 := p4_a262;
    ddp_list_entries_rec.col206 := p4_a263;
    ddp_list_entries_rec.col207 := p4_a264;
    ddp_list_entries_rec.col208 := p4_a265;
    ddp_list_entries_rec.col209 := p4_a266;
    ddp_list_entries_rec.col210 := p4_a267;
    ddp_list_entries_rec.col211 := p4_a268;
    ddp_list_entries_rec.col212 := p4_a269;
    ddp_list_entries_rec.col213 := p4_a270;
    ddp_list_entries_rec.col214 := p4_a271;
    ddp_list_entries_rec.col215 := p4_a272;
    ddp_list_entries_rec.col216 := p4_a273;
    ddp_list_entries_rec.col217 := p4_a274;
    ddp_list_entries_rec.col218 := p4_a275;
    ddp_list_entries_rec.col219 := p4_a276;
    ddp_list_entries_rec.col220 := p4_a277;
    ddp_list_entries_rec.col221 := p4_a278;
    ddp_list_entries_rec.col222 := p4_a279;
    ddp_list_entries_rec.col223 := p4_a280;
    ddp_list_entries_rec.col224 := p4_a281;
    ddp_list_entries_rec.col225 := p4_a282;
    ddp_list_entries_rec.col226 := p4_a283;
    ddp_list_entries_rec.col227 := p4_a284;
    ddp_list_entries_rec.col228 := p4_a285;
    ddp_list_entries_rec.col229 := p4_a286;
    ddp_list_entries_rec.col230 := p4_a287;
    ddp_list_entries_rec.col231 := p4_a288;
    ddp_list_entries_rec.col232 := p4_a289;
    ddp_list_entries_rec.col233 := p4_a290;
    ddp_list_entries_rec.col234 := p4_a291;
    ddp_list_entries_rec.col235 := p4_a292;
    ddp_list_entries_rec.col236 := p4_a293;
    ddp_list_entries_rec.col237 := p4_a294;
    ddp_list_entries_rec.col238 := p4_a295;
    ddp_list_entries_rec.col239 := p4_a296;
    ddp_list_entries_rec.col240 := p4_a297;
    ddp_list_entries_rec.col241 := p4_a298;
    ddp_list_entries_rec.col242 := p4_a299;
    ddp_list_entries_rec.col243 := p4_a300;
    ddp_list_entries_rec.col244 := p4_a301;
    ddp_list_entries_rec.col245 := p4_a302;
    ddp_list_entries_rec.col246 := p4_a303;
    ddp_list_entries_rec.col247 := p4_a304;
    ddp_list_entries_rec.col248 := p4_a305;
    ddp_list_entries_rec.col249 := p4_a306;
    ddp_list_entries_rec.col250 := p4_a307;
    ddp_list_entries_rec.col251 := p4_a308;
    ddp_list_entries_rec.col252 := p4_a309;
    ddp_list_entries_rec.col253 := p4_a310;
    ddp_list_entries_rec.col254 := p4_a311;
    ddp_list_entries_rec.col255 := p4_a312;
    ddp_list_entries_rec.col256 := p4_a313;
    ddp_list_entries_rec.col257 := p4_a314;
    ddp_list_entries_rec.col258 := p4_a315;
    ddp_list_entries_rec.col259 := p4_a316;
    ddp_list_entries_rec.col260 := p4_a317;
    ddp_list_entries_rec.col261 := p4_a318;
    ddp_list_entries_rec.col262 := p4_a319;
    ddp_list_entries_rec.col263 := p4_a320;
    ddp_list_entries_rec.col264 := p4_a321;
    ddp_list_entries_rec.col265 := p4_a322;
    ddp_list_entries_rec.col266 := p4_a323;
    ddp_list_entries_rec.col267 := p4_a324;
    ddp_list_entries_rec.col268 := p4_a325;
    ddp_list_entries_rec.col269 := p4_a326;
    ddp_list_entries_rec.col270 := p4_a327;
    ddp_list_entries_rec.col271 := p4_a328;
    ddp_list_entries_rec.col272 := p4_a329;
    ddp_list_entries_rec.col273 := p4_a330;
    ddp_list_entries_rec.col274 := p4_a331;
    ddp_list_entries_rec.col275 := p4_a332;
    ddp_list_entries_rec.col276 := p4_a333;
    ddp_list_entries_rec.col277 := p4_a334;
    ddp_list_entries_rec.col278 := p4_a335;
    ddp_list_entries_rec.col279 := p4_a336;
    ddp_list_entries_rec.col280 := p4_a337;
    ddp_list_entries_rec.col281 := p4_a338;
    ddp_list_entries_rec.col282 := p4_a339;
    ddp_list_entries_rec.col283 := p4_a340;
    ddp_list_entries_rec.col284 := p4_a341;
    ddp_list_entries_rec.col285 := p4_a342;
    ddp_list_entries_rec.col286 := p4_a343;
    ddp_list_entries_rec.col287 := p4_a344;
    ddp_list_entries_rec.col288 := p4_a345;
    ddp_list_entries_rec.col289 := p4_a346;
    ddp_list_entries_rec.col290 := p4_a347;
    ddp_list_entries_rec.col291 := p4_a348;
    ddp_list_entries_rec.col292 := p4_a349;
    ddp_list_entries_rec.col293 := p4_a350;
    ddp_list_entries_rec.col294 := p4_a351;
    ddp_list_entries_rec.col295 := p4_a352;
    ddp_list_entries_rec.col296 := p4_a353;
    ddp_list_entries_rec.col297 := p4_a354;
    ddp_list_entries_rec.col298 := p4_a355;
    ddp_list_entries_rec.col299 := p4_a356;
    ddp_list_entries_rec.col300 := p4_a357;
    ddp_list_entries_rec.curr_cp_country_code := p4_a358;
    ddp_list_entries_rec.curr_cp_phone_number := p4_a359;
    ddp_list_entries_rec.curr_cp_raw_phone_number := p4_a360;
    ddp_list_entries_rec.curr_cp_area_code := rosetta_g_miss_num_map(p4_a361);
    ddp_list_entries_rec.curr_cp_id := rosetta_g_miss_num_map(p4_a362);
    ddp_list_entries_rec.curr_cp_index := rosetta_g_miss_num_map(p4_a363);
    ddp_list_entries_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p4_a364);
    ddp_list_entries_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p4_a365);
    ddp_list_entries_rec.party_id := rosetta_g_miss_num_map(p4_a366);
    ddp_list_entries_rec.parent_party_id := rosetta_g_miss_num_map(p4_a367);
    ddp_list_entries_rec.imp_source_line_id := rosetta_g_miss_num_map(p4_a368);
    ddp_list_entries_rec.usage_restriction := p4_a369;
    ddp_list_entries_rec.next_call_time := rosetta_g_miss_date_in_map(p4_a370);
    ddp_list_entries_rec.callback_flag := p4_a371;
    ddp_list_entries_rec.do_not_use_flag := p4_a372;
    ddp_list_entries_rec.do_not_use_reason := p4_a373;
    ddp_list_entries_rec.record_out_flag := p4_a374;
    ddp_list_entries_rec.record_release_time := rosetta_g_miss_date_in_map(p4_a375);
    ddp_list_entries_rec.group_code := p4_a376;
    ddp_list_entries_rec.newly_updated_flag := p4_a377;
    ddp_list_entries_rec.outcome_id := rosetta_g_miss_num_map(p4_a378);
    ddp_list_entries_rec.result_id := rosetta_g_miss_num_map(p4_a379);
    ddp_list_entries_rec.reason_id := rosetta_g_miss_num_map(p4_a380);
    ddp_list_entries_rec.notes := p4_a381;
    ddp_list_entries_rec.vehicle_response_code := p4_a382;
    ddp_list_entries_rec.sales_agent_email_address := p4_a383;
    ddp_list_entries_rec.resource_id := rosetta_g_miss_num_map(p4_a384);
    ddp_list_entries_rec.location_id := rosetta_g_miss_num_map(p4_a385);
    ddp_list_entries_rec.contact_point_id := rosetta_g_miss_num_map(p4_a386);
    ddp_list_entries_rec.last_contacted_date := rosetta_g_miss_date_in_map(p4_a387);




    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.validate_list_entries(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_list_entries_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_list_entries_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  VARCHAR2 := fnd_api.g_miss_char
    , p0_a20  VARCHAR2 := fnd_api.g_miss_char
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
    , p0_a22  VARCHAR2 := fnd_api.g_miss_char
    , p0_a23  VARCHAR2 := fnd_api.g_miss_char
    , p0_a24  VARCHAR2 := fnd_api.g_miss_char
    , p0_a25  VARCHAR2 := fnd_api.g_miss_char
    , p0_a26  NUMBER := 0-1962.0724
    , p0_a27  NUMBER := 0-1962.0724
    , p0_a28  NUMBER := 0-1962.0724
    , p0_a29  NUMBER := 0-1962.0724
    , p0_a30  NUMBER := 0-1962.0724
    , p0_a31  NUMBER := 0-1962.0724
    , p0_a32  NUMBER := 0-1962.0724
    , p0_a33  NUMBER := 0-1962.0724
    , p0_a34  NUMBER := 0-1962.0724
    , p0_a35  VARCHAR2 := fnd_api.g_miss_char
    , p0_a36  VARCHAR2 := fnd_api.g_miss_char
    , p0_a37  VARCHAR2 := fnd_api.g_miss_char
    , p0_a38  NUMBER := 0-1962.0724
    , p0_a39  VARCHAR2 := fnd_api.g_miss_char
    , p0_a40  NUMBER := 0-1962.0724
    , p0_a41  NUMBER := 0-1962.0724
    , p0_a42  NUMBER := 0-1962.0724
    , p0_a43  NUMBER := 0-1962.0724
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
    , p0_a265  VARCHAR2 := fnd_api.g_miss_char
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
    , p0_a295  VARCHAR2 := fnd_api.g_miss_char
    , p0_a296  VARCHAR2 := fnd_api.g_miss_char
    , p0_a297  VARCHAR2 := fnd_api.g_miss_char
    , p0_a298  VARCHAR2 := fnd_api.g_miss_char
    , p0_a299  VARCHAR2 := fnd_api.g_miss_char
    , p0_a300  VARCHAR2 := fnd_api.g_miss_char
    , p0_a301  VARCHAR2 := fnd_api.g_miss_char
    , p0_a302  VARCHAR2 := fnd_api.g_miss_char
    , p0_a303  VARCHAR2 := fnd_api.g_miss_char
    , p0_a304  VARCHAR2 := fnd_api.g_miss_char
    , p0_a305  VARCHAR2 := fnd_api.g_miss_char
    , p0_a306  VARCHAR2 := fnd_api.g_miss_char
    , p0_a307  VARCHAR2 := fnd_api.g_miss_char
    , p0_a308  VARCHAR2 := fnd_api.g_miss_char
    , p0_a309  VARCHAR2 := fnd_api.g_miss_char
    , p0_a310  VARCHAR2 := fnd_api.g_miss_char
    , p0_a311  VARCHAR2 := fnd_api.g_miss_char
    , p0_a312  VARCHAR2 := fnd_api.g_miss_char
    , p0_a313  VARCHAR2 := fnd_api.g_miss_char
    , p0_a314  VARCHAR2 := fnd_api.g_miss_char
    , p0_a315  VARCHAR2 := fnd_api.g_miss_char
    , p0_a316  VARCHAR2 := fnd_api.g_miss_char
    , p0_a317  VARCHAR2 := fnd_api.g_miss_char
    , p0_a318  VARCHAR2 := fnd_api.g_miss_char
    , p0_a319  VARCHAR2 := fnd_api.g_miss_char
    , p0_a320  VARCHAR2 := fnd_api.g_miss_char
    , p0_a321  VARCHAR2 := fnd_api.g_miss_char
    , p0_a322  VARCHAR2 := fnd_api.g_miss_char
    , p0_a323  VARCHAR2 := fnd_api.g_miss_char
    , p0_a324  VARCHAR2 := fnd_api.g_miss_char
    , p0_a325  VARCHAR2 := fnd_api.g_miss_char
    , p0_a326  VARCHAR2 := fnd_api.g_miss_char
    , p0_a327  VARCHAR2 := fnd_api.g_miss_char
    , p0_a328  VARCHAR2 := fnd_api.g_miss_char
    , p0_a329  VARCHAR2 := fnd_api.g_miss_char
    , p0_a330  VARCHAR2 := fnd_api.g_miss_char
    , p0_a331  VARCHAR2 := fnd_api.g_miss_char
    , p0_a332  VARCHAR2 := fnd_api.g_miss_char
    , p0_a333  VARCHAR2 := fnd_api.g_miss_char
    , p0_a334  VARCHAR2 := fnd_api.g_miss_char
    , p0_a335  VARCHAR2 := fnd_api.g_miss_char
    , p0_a336  VARCHAR2 := fnd_api.g_miss_char
    , p0_a337  VARCHAR2 := fnd_api.g_miss_char
    , p0_a338  VARCHAR2 := fnd_api.g_miss_char
    , p0_a339  VARCHAR2 := fnd_api.g_miss_char
    , p0_a340  VARCHAR2 := fnd_api.g_miss_char
    , p0_a341  VARCHAR2 := fnd_api.g_miss_char
    , p0_a342  VARCHAR2 := fnd_api.g_miss_char
    , p0_a343  VARCHAR2 := fnd_api.g_miss_char
    , p0_a344  VARCHAR2 := fnd_api.g_miss_char
    , p0_a345  VARCHAR2 := fnd_api.g_miss_char
    , p0_a346  VARCHAR2 := fnd_api.g_miss_char
    , p0_a347  VARCHAR2 := fnd_api.g_miss_char
    , p0_a348  VARCHAR2 := fnd_api.g_miss_char
    , p0_a349  VARCHAR2 := fnd_api.g_miss_char
    , p0_a350  VARCHAR2 := fnd_api.g_miss_char
    , p0_a351  VARCHAR2 := fnd_api.g_miss_char
    , p0_a352  VARCHAR2 := fnd_api.g_miss_char
    , p0_a353  VARCHAR2 := fnd_api.g_miss_char
    , p0_a354  VARCHAR2 := fnd_api.g_miss_char
    , p0_a355  VARCHAR2 := fnd_api.g_miss_char
    , p0_a356  VARCHAR2 := fnd_api.g_miss_char
    , p0_a357  VARCHAR2 := fnd_api.g_miss_char
    , p0_a358  VARCHAR2 := fnd_api.g_miss_char
    , p0_a359  VARCHAR2 := fnd_api.g_miss_char
    , p0_a360  VARCHAR2 := fnd_api.g_miss_char
    , p0_a361  NUMBER := 0-1962.0724
    , p0_a362  NUMBER := 0-1962.0724
    , p0_a363  NUMBER := 0-1962.0724
    , p0_a364  NUMBER := 0-1962.0724
    , p0_a365  NUMBER := 0-1962.0724
    , p0_a366  NUMBER := 0-1962.0724
    , p0_a367  NUMBER := 0-1962.0724
    , p0_a368  NUMBER := 0-1962.0724
    , p0_a369  VARCHAR2 := fnd_api.g_miss_char
    , p0_a370  DATE := fnd_api.g_miss_date
    , p0_a371  VARCHAR2 := fnd_api.g_miss_char
    , p0_a372  VARCHAR2 := fnd_api.g_miss_char
    , p0_a373  VARCHAR2 := fnd_api.g_miss_char
    , p0_a374  VARCHAR2 := fnd_api.g_miss_char
    , p0_a375  DATE := fnd_api.g_miss_date
    , p0_a376  VARCHAR2 := fnd_api.g_miss_char
    , p0_a377  VARCHAR2 := fnd_api.g_miss_char
    , p0_a378  NUMBER := 0-1962.0724
    , p0_a379  NUMBER := 0-1962.0724
    , p0_a380  NUMBER := 0-1962.0724
    , p0_a381  VARCHAR2 := fnd_api.g_miss_char
    , p0_a382  VARCHAR2 := fnd_api.g_miss_char
    , p0_a383  VARCHAR2 := fnd_api.g_miss_char
    , p0_a384  NUMBER := 0-1962.0724
    , p0_a385  NUMBER := 0-1962.0724
    , p0_a386  NUMBER := 0-1962.0724
    , p0_a387  DATE := fnd_api.g_miss_date
  )
  as
    ddp_list_entries_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_list_entries_rec.list_entry_id := rosetta_g_miss_num_map(p0_a0);
    ddp_list_entries_rec.list_header_id := rosetta_g_miss_num_map(p0_a1);
    ddp_list_entries_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_list_entries_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_list_entries_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_list_entries_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_list_entries_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_list_entries_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_list_entries_rec.list_select_action_id := rosetta_g_miss_num_map(p0_a8);
    ddp_list_entries_rec.arc_list_select_action_from := p0_a9;
    ddp_list_entries_rec.list_select_action_from_name := p0_a10;
    ddp_list_entries_rec.source_code := p0_a11;
    ddp_list_entries_rec.arc_list_used_by_source := p0_a12;
    ddp_list_entries_rec.source_code_for_id := rosetta_g_miss_num_map(p0_a13);
    ddp_list_entries_rec.pin_code := p0_a14;
    ddp_list_entries_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p0_a15);
    ddp_list_entries_rec.list_entry_source_system_type := p0_a16;
    ddp_list_entries_rec.view_application_id := rosetta_g_miss_num_map(p0_a17);
    ddp_list_entries_rec.manually_entered_flag := p0_a18;
    ddp_list_entries_rec.marked_as_duplicate_flag := p0_a19;
    ddp_list_entries_rec.marked_as_random_flag := p0_a20;
    ddp_list_entries_rec.part_of_control_group_flag := p0_a21;
    ddp_list_entries_rec.exclude_in_triggered_list_flag := p0_a22;
    ddp_list_entries_rec.enabled_flag := p0_a23;
    ddp_list_entries_rec.cell_code := p0_a24;
    ddp_list_entries_rec.dedupe_key := p0_a25;
    ddp_list_entries_rec.randomly_generated_number := rosetta_g_miss_num_map(p0_a26);
    ddp_list_entries_rec.campaign_id := rosetta_g_miss_num_map(p0_a27);
    ddp_list_entries_rec.media_id := rosetta_g_miss_num_map(p0_a28);
    ddp_list_entries_rec.channel_id := rosetta_g_miss_num_map(p0_a29);
    ddp_list_entries_rec.channel_schedule_id := rosetta_g_miss_num_map(p0_a30);
    ddp_list_entries_rec.event_offer_id := rosetta_g_miss_num_map(p0_a31);
    ddp_list_entries_rec.customer_id := rosetta_g_miss_num_map(p0_a32);
    ddp_list_entries_rec.market_segment_id := rosetta_g_miss_num_map(p0_a33);
    ddp_list_entries_rec.vendor_id := rosetta_g_miss_num_map(p0_a34);
    ddp_list_entries_rec.transfer_flag := p0_a35;
    ddp_list_entries_rec.transfer_status := p0_a36;
    ddp_list_entries_rec.list_source := p0_a37;
    ddp_list_entries_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p0_a38);
    ddp_list_entries_rec.marked_flag := p0_a39;
    ddp_list_entries_rec.lead_id := rosetta_g_miss_num_map(p0_a40);
    ddp_list_entries_rec.letter_id := rosetta_g_miss_num_map(p0_a41);
    ddp_list_entries_rec.picking_header_id := rosetta_g_miss_num_map(p0_a42);
    ddp_list_entries_rec.batch_id := rosetta_g_miss_num_map(p0_a43);
    ddp_list_entries_rec.suffix := p0_a44;
    ddp_list_entries_rec.first_name := p0_a45;
    ddp_list_entries_rec.last_name := p0_a46;
    ddp_list_entries_rec.customer_name := p0_a47;
    ddp_list_entries_rec.title := p0_a48;
    ddp_list_entries_rec.address_line1 := p0_a49;
    ddp_list_entries_rec.address_line2 := p0_a50;
    ddp_list_entries_rec.city := p0_a51;
    ddp_list_entries_rec.state := p0_a52;
    ddp_list_entries_rec.zipcode := p0_a53;
    ddp_list_entries_rec.country := p0_a54;
    ddp_list_entries_rec.fax := p0_a55;
    ddp_list_entries_rec.phone := p0_a56;
    ddp_list_entries_rec.email_address := p0_a57;
    ddp_list_entries_rec.col1 := p0_a58;
    ddp_list_entries_rec.col2 := p0_a59;
    ddp_list_entries_rec.col3 := p0_a60;
    ddp_list_entries_rec.col4 := p0_a61;
    ddp_list_entries_rec.col5 := p0_a62;
    ddp_list_entries_rec.col6 := p0_a63;
    ddp_list_entries_rec.col7 := p0_a64;
    ddp_list_entries_rec.col8 := p0_a65;
    ddp_list_entries_rec.col9 := p0_a66;
    ddp_list_entries_rec.col10 := p0_a67;
    ddp_list_entries_rec.col11 := p0_a68;
    ddp_list_entries_rec.col12 := p0_a69;
    ddp_list_entries_rec.col13 := p0_a70;
    ddp_list_entries_rec.col14 := p0_a71;
    ddp_list_entries_rec.col15 := p0_a72;
    ddp_list_entries_rec.col16 := p0_a73;
    ddp_list_entries_rec.col17 := p0_a74;
    ddp_list_entries_rec.col18 := p0_a75;
    ddp_list_entries_rec.col19 := p0_a76;
    ddp_list_entries_rec.col20 := p0_a77;
    ddp_list_entries_rec.col21 := p0_a78;
    ddp_list_entries_rec.col22 := p0_a79;
    ddp_list_entries_rec.col23 := p0_a80;
    ddp_list_entries_rec.col24 := p0_a81;
    ddp_list_entries_rec.col25 := p0_a82;
    ddp_list_entries_rec.col26 := p0_a83;
    ddp_list_entries_rec.col27 := p0_a84;
    ddp_list_entries_rec.col28 := p0_a85;
    ddp_list_entries_rec.col29 := p0_a86;
    ddp_list_entries_rec.col30 := p0_a87;
    ddp_list_entries_rec.col31 := p0_a88;
    ddp_list_entries_rec.col32 := p0_a89;
    ddp_list_entries_rec.col33 := p0_a90;
    ddp_list_entries_rec.col34 := p0_a91;
    ddp_list_entries_rec.col35 := p0_a92;
    ddp_list_entries_rec.col36 := p0_a93;
    ddp_list_entries_rec.col37 := p0_a94;
    ddp_list_entries_rec.col38 := p0_a95;
    ddp_list_entries_rec.col39 := p0_a96;
    ddp_list_entries_rec.col40 := p0_a97;
    ddp_list_entries_rec.col41 := p0_a98;
    ddp_list_entries_rec.col42 := p0_a99;
    ddp_list_entries_rec.col43 := p0_a100;
    ddp_list_entries_rec.col44 := p0_a101;
    ddp_list_entries_rec.col45 := p0_a102;
    ddp_list_entries_rec.col46 := p0_a103;
    ddp_list_entries_rec.col47 := p0_a104;
    ddp_list_entries_rec.col48 := p0_a105;
    ddp_list_entries_rec.col49 := p0_a106;
    ddp_list_entries_rec.col50 := p0_a107;
    ddp_list_entries_rec.col51 := p0_a108;
    ddp_list_entries_rec.col52 := p0_a109;
    ddp_list_entries_rec.col53 := p0_a110;
    ddp_list_entries_rec.col54 := p0_a111;
    ddp_list_entries_rec.col55 := p0_a112;
    ddp_list_entries_rec.col56 := p0_a113;
    ddp_list_entries_rec.col57 := p0_a114;
    ddp_list_entries_rec.col58 := p0_a115;
    ddp_list_entries_rec.col59 := p0_a116;
    ddp_list_entries_rec.col60 := p0_a117;
    ddp_list_entries_rec.col61 := p0_a118;
    ddp_list_entries_rec.col62 := p0_a119;
    ddp_list_entries_rec.col63 := p0_a120;
    ddp_list_entries_rec.col64 := p0_a121;
    ddp_list_entries_rec.col65 := p0_a122;
    ddp_list_entries_rec.col66 := p0_a123;
    ddp_list_entries_rec.col67 := p0_a124;
    ddp_list_entries_rec.col68 := p0_a125;
    ddp_list_entries_rec.col69 := p0_a126;
    ddp_list_entries_rec.col70 := p0_a127;
    ddp_list_entries_rec.col71 := p0_a128;
    ddp_list_entries_rec.col72 := p0_a129;
    ddp_list_entries_rec.col73 := p0_a130;
    ddp_list_entries_rec.col74 := p0_a131;
    ddp_list_entries_rec.col75 := p0_a132;
    ddp_list_entries_rec.col76 := p0_a133;
    ddp_list_entries_rec.col77 := p0_a134;
    ddp_list_entries_rec.col78 := p0_a135;
    ddp_list_entries_rec.col79 := p0_a136;
    ddp_list_entries_rec.col80 := p0_a137;
    ddp_list_entries_rec.col81 := p0_a138;
    ddp_list_entries_rec.col82 := p0_a139;
    ddp_list_entries_rec.col83 := p0_a140;
    ddp_list_entries_rec.col84 := p0_a141;
    ddp_list_entries_rec.col85 := p0_a142;
    ddp_list_entries_rec.col86 := p0_a143;
    ddp_list_entries_rec.col87 := p0_a144;
    ddp_list_entries_rec.col88 := p0_a145;
    ddp_list_entries_rec.col89 := p0_a146;
    ddp_list_entries_rec.col90 := p0_a147;
    ddp_list_entries_rec.col91 := p0_a148;
    ddp_list_entries_rec.col92 := p0_a149;
    ddp_list_entries_rec.col93 := p0_a150;
    ddp_list_entries_rec.col94 := p0_a151;
    ddp_list_entries_rec.col95 := p0_a152;
    ddp_list_entries_rec.col96 := p0_a153;
    ddp_list_entries_rec.col97 := p0_a154;
    ddp_list_entries_rec.col98 := p0_a155;
    ddp_list_entries_rec.col99 := p0_a156;
    ddp_list_entries_rec.col100 := p0_a157;
    ddp_list_entries_rec.col101 := p0_a158;
    ddp_list_entries_rec.col102 := p0_a159;
    ddp_list_entries_rec.col103 := p0_a160;
    ddp_list_entries_rec.col104 := p0_a161;
    ddp_list_entries_rec.col105 := p0_a162;
    ddp_list_entries_rec.col106 := p0_a163;
    ddp_list_entries_rec.col107 := p0_a164;
    ddp_list_entries_rec.col108 := p0_a165;
    ddp_list_entries_rec.col109 := p0_a166;
    ddp_list_entries_rec.col110 := p0_a167;
    ddp_list_entries_rec.col111 := p0_a168;
    ddp_list_entries_rec.col112 := p0_a169;
    ddp_list_entries_rec.col113 := p0_a170;
    ddp_list_entries_rec.col114 := p0_a171;
    ddp_list_entries_rec.col115 := p0_a172;
    ddp_list_entries_rec.col116 := p0_a173;
    ddp_list_entries_rec.col117 := p0_a174;
    ddp_list_entries_rec.col118 := p0_a175;
    ddp_list_entries_rec.col119 := p0_a176;
    ddp_list_entries_rec.col120 := p0_a177;
    ddp_list_entries_rec.col121 := p0_a178;
    ddp_list_entries_rec.col122 := p0_a179;
    ddp_list_entries_rec.col123 := p0_a180;
    ddp_list_entries_rec.col124 := p0_a181;
    ddp_list_entries_rec.col125 := p0_a182;
    ddp_list_entries_rec.col126 := p0_a183;
    ddp_list_entries_rec.col127 := p0_a184;
    ddp_list_entries_rec.col128 := p0_a185;
    ddp_list_entries_rec.col129 := p0_a186;
    ddp_list_entries_rec.col130 := p0_a187;
    ddp_list_entries_rec.col131 := p0_a188;
    ddp_list_entries_rec.col132 := p0_a189;
    ddp_list_entries_rec.col133 := p0_a190;
    ddp_list_entries_rec.col134 := p0_a191;
    ddp_list_entries_rec.col135 := p0_a192;
    ddp_list_entries_rec.col136 := p0_a193;
    ddp_list_entries_rec.col137 := p0_a194;
    ddp_list_entries_rec.col138 := p0_a195;
    ddp_list_entries_rec.col139 := p0_a196;
    ddp_list_entries_rec.col140 := p0_a197;
    ddp_list_entries_rec.col141 := p0_a198;
    ddp_list_entries_rec.col142 := p0_a199;
    ddp_list_entries_rec.col143 := p0_a200;
    ddp_list_entries_rec.col144 := p0_a201;
    ddp_list_entries_rec.col145 := p0_a202;
    ddp_list_entries_rec.col146 := p0_a203;
    ddp_list_entries_rec.col147 := p0_a204;
    ddp_list_entries_rec.col148 := p0_a205;
    ddp_list_entries_rec.col149 := p0_a206;
    ddp_list_entries_rec.col150 := p0_a207;
    ddp_list_entries_rec.col151 := p0_a208;
    ddp_list_entries_rec.col152 := p0_a209;
    ddp_list_entries_rec.col153 := p0_a210;
    ddp_list_entries_rec.col154 := p0_a211;
    ddp_list_entries_rec.col155 := p0_a212;
    ddp_list_entries_rec.col156 := p0_a213;
    ddp_list_entries_rec.col157 := p0_a214;
    ddp_list_entries_rec.col158 := p0_a215;
    ddp_list_entries_rec.col159 := p0_a216;
    ddp_list_entries_rec.col160 := p0_a217;
    ddp_list_entries_rec.col161 := p0_a218;
    ddp_list_entries_rec.col162 := p0_a219;
    ddp_list_entries_rec.col163 := p0_a220;
    ddp_list_entries_rec.col164 := p0_a221;
    ddp_list_entries_rec.col165 := p0_a222;
    ddp_list_entries_rec.col166 := p0_a223;
    ddp_list_entries_rec.col167 := p0_a224;
    ddp_list_entries_rec.col168 := p0_a225;
    ddp_list_entries_rec.col169 := p0_a226;
    ddp_list_entries_rec.col170 := p0_a227;
    ddp_list_entries_rec.col171 := p0_a228;
    ddp_list_entries_rec.col172 := p0_a229;
    ddp_list_entries_rec.col173 := p0_a230;
    ddp_list_entries_rec.col174 := p0_a231;
    ddp_list_entries_rec.col175 := p0_a232;
    ddp_list_entries_rec.col176 := p0_a233;
    ddp_list_entries_rec.col177 := p0_a234;
    ddp_list_entries_rec.col178 := p0_a235;
    ddp_list_entries_rec.col179 := p0_a236;
    ddp_list_entries_rec.col180 := p0_a237;
    ddp_list_entries_rec.col181 := p0_a238;
    ddp_list_entries_rec.col182 := p0_a239;
    ddp_list_entries_rec.col183 := p0_a240;
    ddp_list_entries_rec.col184 := p0_a241;
    ddp_list_entries_rec.col185 := p0_a242;
    ddp_list_entries_rec.col186 := p0_a243;
    ddp_list_entries_rec.col187 := p0_a244;
    ddp_list_entries_rec.col188 := p0_a245;
    ddp_list_entries_rec.col189 := p0_a246;
    ddp_list_entries_rec.col190 := p0_a247;
    ddp_list_entries_rec.col191 := p0_a248;
    ddp_list_entries_rec.col192 := p0_a249;
    ddp_list_entries_rec.col193 := p0_a250;
    ddp_list_entries_rec.col194 := p0_a251;
    ddp_list_entries_rec.col195 := p0_a252;
    ddp_list_entries_rec.col196 := p0_a253;
    ddp_list_entries_rec.col197 := p0_a254;
    ddp_list_entries_rec.col198 := p0_a255;
    ddp_list_entries_rec.col199 := p0_a256;
    ddp_list_entries_rec.col200 := p0_a257;
    ddp_list_entries_rec.col201 := p0_a258;
    ddp_list_entries_rec.col202 := p0_a259;
    ddp_list_entries_rec.col203 := p0_a260;
    ddp_list_entries_rec.col204 := p0_a261;
    ddp_list_entries_rec.col205 := p0_a262;
    ddp_list_entries_rec.col206 := p0_a263;
    ddp_list_entries_rec.col207 := p0_a264;
    ddp_list_entries_rec.col208 := p0_a265;
    ddp_list_entries_rec.col209 := p0_a266;
    ddp_list_entries_rec.col210 := p0_a267;
    ddp_list_entries_rec.col211 := p0_a268;
    ddp_list_entries_rec.col212 := p0_a269;
    ddp_list_entries_rec.col213 := p0_a270;
    ddp_list_entries_rec.col214 := p0_a271;
    ddp_list_entries_rec.col215 := p0_a272;
    ddp_list_entries_rec.col216 := p0_a273;
    ddp_list_entries_rec.col217 := p0_a274;
    ddp_list_entries_rec.col218 := p0_a275;
    ddp_list_entries_rec.col219 := p0_a276;
    ddp_list_entries_rec.col220 := p0_a277;
    ddp_list_entries_rec.col221 := p0_a278;
    ddp_list_entries_rec.col222 := p0_a279;
    ddp_list_entries_rec.col223 := p0_a280;
    ddp_list_entries_rec.col224 := p0_a281;
    ddp_list_entries_rec.col225 := p0_a282;
    ddp_list_entries_rec.col226 := p0_a283;
    ddp_list_entries_rec.col227 := p0_a284;
    ddp_list_entries_rec.col228 := p0_a285;
    ddp_list_entries_rec.col229 := p0_a286;
    ddp_list_entries_rec.col230 := p0_a287;
    ddp_list_entries_rec.col231 := p0_a288;
    ddp_list_entries_rec.col232 := p0_a289;
    ddp_list_entries_rec.col233 := p0_a290;
    ddp_list_entries_rec.col234 := p0_a291;
    ddp_list_entries_rec.col235 := p0_a292;
    ddp_list_entries_rec.col236 := p0_a293;
    ddp_list_entries_rec.col237 := p0_a294;
    ddp_list_entries_rec.col238 := p0_a295;
    ddp_list_entries_rec.col239 := p0_a296;
    ddp_list_entries_rec.col240 := p0_a297;
    ddp_list_entries_rec.col241 := p0_a298;
    ddp_list_entries_rec.col242 := p0_a299;
    ddp_list_entries_rec.col243 := p0_a300;
    ddp_list_entries_rec.col244 := p0_a301;
    ddp_list_entries_rec.col245 := p0_a302;
    ddp_list_entries_rec.col246 := p0_a303;
    ddp_list_entries_rec.col247 := p0_a304;
    ddp_list_entries_rec.col248 := p0_a305;
    ddp_list_entries_rec.col249 := p0_a306;
    ddp_list_entries_rec.col250 := p0_a307;
    ddp_list_entries_rec.col251 := p0_a308;
    ddp_list_entries_rec.col252 := p0_a309;
    ddp_list_entries_rec.col253 := p0_a310;
    ddp_list_entries_rec.col254 := p0_a311;
    ddp_list_entries_rec.col255 := p0_a312;
    ddp_list_entries_rec.col256 := p0_a313;
    ddp_list_entries_rec.col257 := p0_a314;
    ddp_list_entries_rec.col258 := p0_a315;
    ddp_list_entries_rec.col259 := p0_a316;
    ddp_list_entries_rec.col260 := p0_a317;
    ddp_list_entries_rec.col261 := p0_a318;
    ddp_list_entries_rec.col262 := p0_a319;
    ddp_list_entries_rec.col263 := p0_a320;
    ddp_list_entries_rec.col264 := p0_a321;
    ddp_list_entries_rec.col265 := p0_a322;
    ddp_list_entries_rec.col266 := p0_a323;
    ddp_list_entries_rec.col267 := p0_a324;
    ddp_list_entries_rec.col268 := p0_a325;
    ddp_list_entries_rec.col269 := p0_a326;
    ddp_list_entries_rec.col270 := p0_a327;
    ddp_list_entries_rec.col271 := p0_a328;
    ddp_list_entries_rec.col272 := p0_a329;
    ddp_list_entries_rec.col273 := p0_a330;
    ddp_list_entries_rec.col274 := p0_a331;
    ddp_list_entries_rec.col275 := p0_a332;
    ddp_list_entries_rec.col276 := p0_a333;
    ddp_list_entries_rec.col277 := p0_a334;
    ddp_list_entries_rec.col278 := p0_a335;
    ddp_list_entries_rec.col279 := p0_a336;
    ddp_list_entries_rec.col280 := p0_a337;
    ddp_list_entries_rec.col281 := p0_a338;
    ddp_list_entries_rec.col282 := p0_a339;
    ddp_list_entries_rec.col283 := p0_a340;
    ddp_list_entries_rec.col284 := p0_a341;
    ddp_list_entries_rec.col285 := p0_a342;
    ddp_list_entries_rec.col286 := p0_a343;
    ddp_list_entries_rec.col287 := p0_a344;
    ddp_list_entries_rec.col288 := p0_a345;
    ddp_list_entries_rec.col289 := p0_a346;
    ddp_list_entries_rec.col290 := p0_a347;
    ddp_list_entries_rec.col291 := p0_a348;
    ddp_list_entries_rec.col292 := p0_a349;
    ddp_list_entries_rec.col293 := p0_a350;
    ddp_list_entries_rec.col294 := p0_a351;
    ddp_list_entries_rec.col295 := p0_a352;
    ddp_list_entries_rec.col296 := p0_a353;
    ddp_list_entries_rec.col297 := p0_a354;
    ddp_list_entries_rec.col298 := p0_a355;
    ddp_list_entries_rec.col299 := p0_a356;
    ddp_list_entries_rec.col300 := p0_a357;
    ddp_list_entries_rec.curr_cp_country_code := p0_a358;
    ddp_list_entries_rec.curr_cp_phone_number := p0_a359;
    ddp_list_entries_rec.curr_cp_raw_phone_number := p0_a360;
    ddp_list_entries_rec.curr_cp_area_code := rosetta_g_miss_num_map(p0_a361);
    ddp_list_entries_rec.curr_cp_id := rosetta_g_miss_num_map(p0_a362);
    ddp_list_entries_rec.curr_cp_index := rosetta_g_miss_num_map(p0_a363);
    ddp_list_entries_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p0_a364);
    ddp_list_entries_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p0_a365);
    ddp_list_entries_rec.party_id := rosetta_g_miss_num_map(p0_a366);
    ddp_list_entries_rec.parent_party_id := rosetta_g_miss_num_map(p0_a367);
    ddp_list_entries_rec.imp_source_line_id := rosetta_g_miss_num_map(p0_a368);
    ddp_list_entries_rec.usage_restriction := p0_a369;
    ddp_list_entries_rec.next_call_time := rosetta_g_miss_date_in_map(p0_a370);
    ddp_list_entries_rec.callback_flag := p0_a371;
    ddp_list_entries_rec.do_not_use_flag := p0_a372;
    ddp_list_entries_rec.do_not_use_reason := p0_a373;
    ddp_list_entries_rec.record_out_flag := p0_a374;
    ddp_list_entries_rec.record_release_time := rosetta_g_miss_date_in_map(p0_a375);
    ddp_list_entries_rec.group_code := p0_a376;
    ddp_list_entries_rec.newly_updated_flag := p0_a377;
    ddp_list_entries_rec.outcome_id := rosetta_g_miss_num_map(p0_a378);
    ddp_list_entries_rec.result_id := rosetta_g_miss_num_map(p0_a379);
    ddp_list_entries_rec.reason_id := rosetta_g_miss_num_map(p0_a380);
    ddp_list_entries_rec.notes := p0_a381;
    ddp_list_entries_rec.vehicle_response_code := p0_a382;
    ddp_list_entries_rec.sales_agent_email_address := p0_a383;
    ddp_list_entries_rec.resource_id := rosetta_g_miss_num_map(p0_a384);
    ddp_list_entries_rec.location_id := rosetta_g_miss_num_map(p0_a385);
    ddp_list_entries_rec.contact_point_id := rosetta_g_miss_num_map(p0_a386);
    ddp_list_entries_rec.last_contacted_date := rosetta_g_miss_date_in_map(p0_a387);



    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.check_list_entries_items(ddp_list_entries_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_list_entries_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  NUMBER := 0-1962.0724
    , p5_a27  NUMBER := 0-1962.0724
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  NUMBER := 0-1962.0724
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  NUMBER := 0-1962.0724
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  NUMBER := 0-1962.0724
    , p5_a41  NUMBER := 0-1962.0724
    , p5_a42  NUMBER := 0-1962.0724
    , p5_a43  NUMBER := 0-1962.0724
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
    , p5_a265  VARCHAR2 := fnd_api.g_miss_char
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
    , p5_a295  VARCHAR2 := fnd_api.g_miss_char
    , p5_a296  VARCHAR2 := fnd_api.g_miss_char
    , p5_a297  VARCHAR2 := fnd_api.g_miss_char
    , p5_a298  VARCHAR2 := fnd_api.g_miss_char
    , p5_a299  VARCHAR2 := fnd_api.g_miss_char
    , p5_a300  VARCHAR2 := fnd_api.g_miss_char
    , p5_a301  VARCHAR2 := fnd_api.g_miss_char
    , p5_a302  VARCHAR2 := fnd_api.g_miss_char
    , p5_a303  VARCHAR2 := fnd_api.g_miss_char
    , p5_a304  VARCHAR2 := fnd_api.g_miss_char
    , p5_a305  VARCHAR2 := fnd_api.g_miss_char
    , p5_a306  VARCHAR2 := fnd_api.g_miss_char
    , p5_a307  VARCHAR2 := fnd_api.g_miss_char
    , p5_a308  VARCHAR2 := fnd_api.g_miss_char
    , p5_a309  VARCHAR2 := fnd_api.g_miss_char
    , p5_a310  VARCHAR2 := fnd_api.g_miss_char
    , p5_a311  VARCHAR2 := fnd_api.g_miss_char
    , p5_a312  VARCHAR2 := fnd_api.g_miss_char
    , p5_a313  VARCHAR2 := fnd_api.g_miss_char
    , p5_a314  VARCHAR2 := fnd_api.g_miss_char
    , p5_a315  VARCHAR2 := fnd_api.g_miss_char
    , p5_a316  VARCHAR2 := fnd_api.g_miss_char
    , p5_a317  VARCHAR2 := fnd_api.g_miss_char
    , p5_a318  VARCHAR2 := fnd_api.g_miss_char
    , p5_a319  VARCHAR2 := fnd_api.g_miss_char
    , p5_a320  VARCHAR2 := fnd_api.g_miss_char
    , p5_a321  VARCHAR2 := fnd_api.g_miss_char
    , p5_a322  VARCHAR2 := fnd_api.g_miss_char
    , p5_a323  VARCHAR2 := fnd_api.g_miss_char
    , p5_a324  VARCHAR2 := fnd_api.g_miss_char
    , p5_a325  VARCHAR2 := fnd_api.g_miss_char
    , p5_a326  VARCHAR2 := fnd_api.g_miss_char
    , p5_a327  VARCHAR2 := fnd_api.g_miss_char
    , p5_a328  VARCHAR2 := fnd_api.g_miss_char
    , p5_a329  VARCHAR2 := fnd_api.g_miss_char
    , p5_a330  VARCHAR2 := fnd_api.g_miss_char
    , p5_a331  VARCHAR2 := fnd_api.g_miss_char
    , p5_a332  VARCHAR2 := fnd_api.g_miss_char
    , p5_a333  VARCHAR2 := fnd_api.g_miss_char
    , p5_a334  VARCHAR2 := fnd_api.g_miss_char
    , p5_a335  VARCHAR2 := fnd_api.g_miss_char
    , p5_a336  VARCHAR2 := fnd_api.g_miss_char
    , p5_a337  VARCHAR2 := fnd_api.g_miss_char
    , p5_a338  VARCHAR2 := fnd_api.g_miss_char
    , p5_a339  VARCHAR2 := fnd_api.g_miss_char
    , p5_a340  VARCHAR2 := fnd_api.g_miss_char
    , p5_a341  VARCHAR2 := fnd_api.g_miss_char
    , p5_a342  VARCHAR2 := fnd_api.g_miss_char
    , p5_a343  VARCHAR2 := fnd_api.g_miss_char
    , p5_a344  VARCHAR2 := fnd_api.g_miss_char
    , p5_a345  VARCHAR2 := fnd_api.g_miss_char
    , p5_a346  VARCHAR2 := fnd_api.g_miss_char
    , p5_a347  VARCHAR2 := fnd_api.g_miss_char
    , p5_a348  VARCHAR2 := fnd_api.g_miss_char
    , p5_a349  VARCHAR2 := fnd_api.g_miss_char
    , p5_a350  VARCHAR2 := fnd_api.g_miss_char
    , p5_a351  VARCHAR2 := fnd_api.g_miss_char
    , p5_a352  VARCHAR2 := fnd_api.g_miss_char
    , p5_a353  VARCHAR2 := fnd_api.g_miss_char
    , p5_a354  VARCHAR2 := fnd_api.g_miss_char
    , p5_a355  VARCHAR2 := fnd_api.g_miss_char
    , p5_a356  VARCHAR2 := fnd_api.g_miss_char
    , p5_a357  VARCHAR2 := fnd_api.g_miss_char
    , p5_a358  VARCHAR2 := fnd_api.g_miss_char
    , p5_a359  VARCHAR2 := fnd_api.g_miss_char
    , p5_a360  VARCHAR2 := fnd_api.g_miss_char
    , p5_a361  NUMBER := 0-1962.0724
    , p5_a362  NUMBER := 0-1962.0724
    , p5_a363  NUMBER := 0-1962.0724
    , p5_a364  NUMBER := 0-1962.0724
    , p5_a365  NUMBER := 0-1962.0724
    , p5_a366  NUMBER := 0-1962.0724
    , p5_a367  NUMBER := 0-1962.0724
    , p5_a368  NUMBER := 0-1962.0724
    , p5_a369  VARCHAR2 := fnd_api.g_miss_char
    , p5_a370  DATE := fnd_api.g_miss_date
    , p5_a371  VARCHAR2 := fnd_api.g_miss_char
    , p5_a372  VARCHAR2 := fnd_api.g_miss_char
    , p5_a373  VARCHAR2 := fnd_api.g_miss_char
    , p5_a374  VARCHAR2 := fnd_api.g_miss_char
    , p5_a375  DATE := fnd_api.g_miss_date
    , p5_a376  VARCHAR2 := fnd_api.g_miss_char
    , p5_a377  VARCHAR2 := fnd_api.g_miss_char
    , p5_a378  NUMBER := 0-1962.0724
    , p5_a379  NUMBER := 0-1962.0724
    , p5_a380  NUMBER := 0-1962.0724
    , p5_a381  VARCHAR2 := fnd_api.g_miss_char
    , p5_a382  VARCHAR2 := fnd_api.g_miss_char
    , p5_a383  VARCHAR2 := fnd_api.g_miss_char
    , p5_a384  NUMBER := 0-1962.0724
    , p5_a385  NUMBER := 0-1962.0724
    , p5_a386  NUMBER := 0-1962.0724
    , p5_a387  DATE := fnd_api.g_miss_date
  )
  as
    ddp_list_entries_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_list_entries_rec.list_entry_id := rosetta_g_miss_num_map(p5_a0);
    ddp_list_entries_rec.list_header_id := rosetta_g_miss_num_map(p5_a1);
    ddp_list_entries_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_list_entries_rec.last_updated_by := rosetta_g_miss_num_map(p5_a3);
    ddp_list_entries_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_list_entries_rec.created_by := rosetta_g_miss_num_map(p5_a5);
    ddp_list_entries_rec.last_update_login := rosetta_g_miss_num_map(p5_a6);
    ddp_list_entries_rec.object_version_number := rosetta_g_miss_num_map(p5_a7);
    ddp_list_entries_rec.list_select_action_id := rosetta_g_miss_num_map(p5_a8);
    ddp_list_entries_rec.arc_list_select_action_from := p5_a9;
    ddp_list_entries_rec.list_select_action_from_name := p5_a10;
    ddp_list_entries_rec.source_code := p5_a11;
    ddp_list_entries_rec.arc_list_used_by_source := p5_a12;
    ddp_list_entries_rec.source_code_for_id := rosetta_g_miss_num_map(p5_a13);
    ddp_list_entries_rec.pin_code := p5_a14;
    ddp_list_entries_rec.list_entry_source_system_id := rosetta_g_miss_num_map(p5_a15);
    ddp_list_entries_rec.list_entry_source_system_type := p5_a16;
    ddp_list_entries_rec.view_application_id := rosetta_g_miss_num_map(p5_a17);
    ddp_list_entries_rec.manually_entered_flag := p5_a18;
    ddp_list_entries_rec.marked_as_duplicate_flag := p5_a19;
    ddp_list_entries_rec.marked_as_random_flag := p5_a20;
    ddp_list_entries_rec.part_of_control_group_flag := p5_a21;
    ddp_list_entries_rec.exclude_in_triggered_list_flag := p5_a22;
    ddp_list_entries_rec.enabled_flag := p5_a23;
    ddp_list_entries_rec.cell_code := p5_a24;
    ddp_list_entries_rec.dedupe_key := p5_a25;
    ddp_list_entries_rec.randomly_generated_number := rosetta_g_miss_num_map(p5_a26);
    ddp_list_entries_rec.campaign_id := rosetta_g_miss_num_map(p5_a27);
    ddp_list_entries_rec.media_id := rosetta_g_miss_num_map(p5_a28);
    ddp_list_entries_rec.channel_id := rosetta_g_miss_num_map(p5_a29);
    ddp_list_entries_rec.channel_schedule_id := rosetta_g_miss_num_map(p5_a30);
    ddp_list_entries_rec.event_offer_id := rosetta_g_miss_num_map(p5_a31);
    ddp_list_entries_rec.customer_id := rosetta_g_miss_num_map(p5_a32);
    ddp_list_entries_rec.market_segment_id := rosetta_g_miss_num_map(p5_a33);
    ddp_list_entries_rec.vendor_id := rosetta_g_miss_num_map(p5_a34);
    ddp_list_entries_rec.transfer_flag := p5_a35;
    ddp_list_entries_rec.transfer_status := p5_a36;
    ddp_list_entries_rec.list_source := p5_a37;
    ddp_list_entries_rec.duplicate_master_entry_id := rosetta_g_miss_num_map(p5_a38);
    ddp_list_entries_rec.marked_flag := p5_a39;
    ddp_list_entries_rec.lead_id := rosetta_g_miss_num_map(p5_a40);
    ddp_list_entries_rec.letter_id := rosetta_g_miss_num_map(p5_a41);
    ddp_list_entries_rec.picking_header_id := rosetta_g_miss_num_map(p5_a42);
    ddp_list_entries_rec.batch_id := rosetta_g_miss_num_map(p5_a43);
    ddp_list_entries_rec.suffix := p5_a44;
    ddp_list_entries_rec.first_name := p5_a45;
    ddp_list_entries_rec.last_name := p5_a46;
    ddp_list_entries_rec.customer_name := p5_a47;
    ddp_list_entries_rec.title := p5_a48;
    ddp_list_entries_rec.address_line1 := p5_a49;
    ddp_list_entries_rec.address_line2 := p5_a50;
    ddp_list_entries_rec.city := p5_a51;
    ddp_list_entries_rec.state := p5_a52;
    ddp_list_entries_rec.zipcode := p5_a53;
    ddp_list_entries_rec.country := p5_a54;
    ddp_list_entries_rec.fax := p5_a55;
    ddp_list_entries_rec.phone := p5_a56;
    ddp_list_entries_rec.email_address := p5_a57;
    ddp_list_entries_rec.col1 := p5_a58;
    ddp_list_entries_rec.col2 := p5_a59;
    ddp_list_entries_rec.col3 := p5_a60;
    ddp_list_entries_rec.col4 := p5_a61;
    ddp_list_entries_rec.col5 := p5_a62;
    ddp_list_entries_rec.col6 := p5_a63;
    ddp_list_entries_rec.col7 := p5_a64;
    ddp_list_entries_rec.col8 := p5_a65;
    ddp_list_entries_rec.col9 := p5_a66;
    ddp_list_entries_rec.col10 := p5_a67;
    ddp_list_entries_rec.col11 := p5_a68;
    ddp_list_entries_rec.col12 := p5_a69;
    ddp_list_entries_rec.col13 := p5_a70;
    ddp_list_entries_rec.col14 := p5_a71;
    ddp_list_entries_rec.col15 := p5_a72;
    ddp_list_entries_rec.col16 := p5_a73;
    ddp_list_entries_rec.col17 := p5_a74;
    ddp_list_entries_rec.col18 := p5_a75;
    ddp_list_entries_rec.col19 := p5_a76;
    ddp_list_entries_rec.col20 := p5_a77;
    ddp_list_entries_rec.col21 := p5_a78;
    ddp_list_entries_rec.col22 := p5_a79;
    ddp_list_entries_rec.col23 := p5_a80;
    ddp_list_entries_rec.col24 := p5_a81;
    ddp_list_entries_rec.col25 := p5_a82;
    ddp_list_entries_rec.col26 := p5_a83;
    ddp_list_entries_rec.col27 := p5_a84;
    ddp_list_entries_rec.col28 := p5_a85;
    ddp_list_entries_rec.col29 := p5_a86;
    ddp_list_entries_rec.col30 := p5_a87;
    ddp_list_entries_rec.col31 := p5_a88;
    ddp_list_entries_rec.col32 := p5_a89;
    ddp_list_entries_rec.col33 := p5_a90;
    ddp_list_entries_rec.col34 := p5_a91;
    ddp_list_entries_rec.col35 := p5_a92;
    ddp_list_entries_rec.col36 := p5_a93;
    ddp_list_entries_rec.col37 := p5_a94;
    ddp_list_entries_rec.col38 := p5_a95;
    ddp_list_entries_rec.col39 := p5_a96;
    ddp_list_entries_rec.col40 := p5_a97;
    ddp_list_entries_rec.col41 := p5_a98;
    ddp_list_entries_rec.col42 := p5_a99;
    ddp_list_entries_rec.col43 := p5_a100;
    ddp_list_entries_rec.col44 := p5_a101;
    ddp_list_entries_rec.col45 := p5_a102;
    ddp_list_entries_rec.col46 := p5_a103;
    ddp_list_entries_rec.col47 := p5_a104;
    ddp_list_entries_rec.col48 := p5_a105;
    ddp_list_entries_rec.col49 := p5_a106;
    ddp_list_entries_rec.col50 := p5_a107;
    ddp_list_entries_rec.col51 := p5_a108;
    ddp_list_entries_rec.col52 := p5_a109;
    ddp_list_entries_rec.col53 := p5_a110;
    ddp_list_entries_rec.col54 := p5_a111;
    ddp_list_entries_rec.col55 := p5_a112;
    ddp_list_entries_rec.col56 := p5_a113;
    ddp_list_entries_rec.col57 := p5_a114;
    ddp_list_entries_rec.col58 := p5_a115;
    ddp_list_entries_rec.col59 := p5_a116;
    ddp_list_entries_rec.col60 := p5_a117;
    ddp_list_entries_rec.col61 := p5_a118;
    ddp_list_entries_rec.col62 := p5_a119;
    ddp_list_entries_rec.col63 := p5_a120;
    ddp_list_entries_rec.col64 := p5_a121;
    ddp_list_entries_rec.col65 := p5_a122;
    ddp_list_entries_rec.col66 := p5_a123;
    ddp_list_entries_rec.col67 := p5_a124;
    ddp_list_entries_rec.col68 := p5_a125;
    ddp_list_entries_rec.col69 := p5_a126;
    ddp_list_entries_rec.col70 := p5_a127;
    ddp_list_entries_rec.col71 := p5_a128;
    ddp_list_entries_rec.col72 := p5_a129;
    ddp_list_entries_rec.col73 := p5_a130;
    ddp_list_entries_rec.col74 := p5_a131;
    ddp_list_entries_rec.col75 := p5_a132;
    ddp_list_entries_rec.col76 := p5_a133;
    ddp_list_entries_rec.col77 := p5_a134;
    ddp_list_entries_rec.col78 := p5_a135;
    ddp_list_entries_rec.col79 := p5_a136;
    ddp_list_entries_rec.col80 := p5_a137;
    ddp_list_entries_rec.col81 := p5_a138;
    ddp_list_entries_rec.col82 := p5_a139;
    ddp_list_entries_rec.col83 := p5_a140;
    ddp_list_entries_rec.col84 := p5_a141;
    ddp_list_entries_rec.col85 := p5_a142;
    ddp_list_entries_rec.col86 := p5_a143;
    ddp_list_entries_rec.col87 := p5_a144;
    ddp_list_entries_rec.col88 := p5_a145;
    ddp_list_entries_rec.col89 := p5_a146;
    ddp_list_entries_rec.col90 := p5_a147;
    ddp_list_entries_rec.col91 := p5_a148;
    ddp_list_entries_rec.col92 := p5_a149;
    ddp_list_entries_rec.col93 := p5_a150;
    ddp_list_entries_rec.col94 := p5_a151;
    ddp_list_entries_rec.col95 := p5_a152;
    ddp_list_entries_rec.col96 := p5_a153;
    ddp_list_entries_rec.col97 := p5_a154;
    ddp_list_entries_rec.col98 := p5_a155;
    ddp_list_entries_rec.col99 := p5_a156;
    ddp_list_entries_rec.col100 := p5_a157;
    ddp_list_entries_rec.col101 := p5_a158;
    ddp_list_entries_rec.col102 := p5_a159;
    ddp_list_entries_rec.col103 := p5_a160;
    ddp_list_entries_rec.col104 := p5_a161;
    ddp_list_entries_rec.col105 := p5_a162;
    ddp_list_entries_rec.col106 := p5_a163;
    ddp_list_entries_rec.col107 := p5_a164;
    ddp_list_entries_rec.col108 := p5_a165;
    ddp_list_entries_rec.col109 := p5_a166;
    ddp_list_entries_rec.col110 := p5_a167;
    ddp_list_entries_rec.col111 := p5_a168;
    ddp_list_entries_rec.col112 := p5_a169;
    ddp_list_entries_rec.col113 := p5_a170;
    ddp_list_entries_rec.col114 := p5_a171;
    ddp_list_entries_rec.col115 := p5_a172;
    ddp_list_entries_rec.col116 := p5_a173;
    ddp_list_entries_rec.col117 := p5_a174;
    ddp_list_entries_rec.col118 := p5_a175;
    ddp_list_entries_rec.col119 := p5_a176;
    ddp_list_entries_rec.col120 := p5_a177;
    ddp_list_entries_rec.col121 := p5_a178;
    ddp_list_entries_rec.col122 := p5_a179;
    ddp_list_entries_rec.col123 := p5_a180;
    ddp_list_entries_rec.col124 := p5_a181;
    ddp_list_entries_rec.col125 := p5_a182;
    ddp_list_entries_rec.col126 := p5_a183;
    ddp_list_entries_rec.col127 := p5_a184;
    ddp_list_entries_rec.col128 := p5_a185;
    ddp_list_entries_rec.col129 := p5_a186;
    ddp_list_entries_rec.col130 := p5_a187;
    ddp_list_entries_rec.col131 := p5_a188;
    ddp_list_entries_rec.col132 := p5_a189;
    ddp_list_entries_rec.col133 := p5_a190;
    ddp_list_entries_rec.col134 := p5_a191;
    ddp_list_entries_rec.col135 := p5_a192;
    ddp_list_entries_rec.col136 := p5_a193;
    ddp_list_entries_rec.col137 := p5_a194;
    ddp_list_entries_rec.col138 := p5_a195;
    ddp_list_entries_rec.col139 := p5_a196;
    ddp_list_entries_rec.col140 := p5_a197;
    ddp_list_entries_rec.col141 := p5_a198;
    ddp_list_entries_rec.col142 := p5_a199;
    ddp_list_entries_rec.col143 := p5_a200;
    ddp_list_entries_rec.col144 := p5_a201;
    ddp_list_entries_rec.col145 := p5_a202;
    ddp_list_entries_rec.col146 := p5_a203;
    ddp_list_entries_rec.col147 := p5_a204;
    ddp_list_entries_rec.col148 := p5_a205;
    ddp_list_entries_rec.col149 := p5_a206;
    ddp_list_entries_rec.col150 := p5_a207;
    ddp_list_entries_rec.col151 := p5_a208;
    ddp_list_entries_rec.col152 := p5_a209;
    ddp_list_entries_rec.col153 := p5_a210;
    ddp_list_entries_rec.col154 := p5_a211;
    ddp_list_entries_rec.col155 := p5_a212;
    ddp_list_entries_rec.col156 := p5_a213;
    ddp_list_entries_rec.col157 := p5_a214;
    ddp_list_entries_rec.col158 := p5_a215;
    ddp_list_entries_rec.col159 := p5_a216;
    ddp_list_entries_rec.col160 := p5_a217;
    ddp_list_entries_rec.col161 := p5_a218;
    ddp_list_entries_rec.col162 := p5_a219;
    ddp_list_entries_rec.col163 := p5_a220;
    ddp_list_entries_rec.col164 := p5_a221;
    ddp_list_entries_rec.col165 := p5_a222;
    ddp_list_entries_rec.col166 := p5_a223;
    ddp_list_entries_rec.col167 := p5_a224;
    ddp_list_entries_rec.col168 := p5_a225;
    ddp_list_entries_rec.col169 := p5_a226;
    ddp_list_entries_rec.col170 := p5_a227;
    ddp_list_entries_rec.col171 := p5_a228;
    ddp_list_entries_rec.col172 := p5_a229;
    ddp_list_entries_rec.col173 := p5_a230;
    ddp_list_entries_rec.col174 := p5_a231;
    ddp_list_entries_rec.col175 := p5_a232;
    ddp_list_entries_rec.col176 := p5_a233;
    ddp_list_entries_rec.col177 := p5_a234;
    ddp_list_entries_rec.col178 := p5_a235;
    ddp_list_entries_rec.col179 := p5_a236;
    ddp_list_entries_rec.col180 := p5_a237;
    ddp_list_entries_rec.col181 := p5_a238;
    ddp_list_entries_rec.col182 := p5_a239;
    ddp_list_entries_rec.col183 := p5_a240;
    ddp_list_entries_rec.col184 := p5_a241;
    ddp_list_entries_rec.col185 := p5_a242;
    ddp_list_entries_rec.col186 := p5_a243;
    ddp_list_entries_rec.col187 := p5_a244;
    ddp_list_entries_rec.col188 := p5_a245;
    ddp_list_entries_rec.col189 := p5_a246;
    ddp_list_entries_rec.col190 := p5_a247;
    ddp_list_entries_rec.col191 := p5_a248;
    ddp_list_entries_rec.col192 := p5_a249;
    ddp_list_entries_rec.col193 := p5_a250;
    ddp_list_entries_rec.col194 := p5_a251;
    ddp_list_entries_rec.col195 := p5_a252;
    ddp_list_entries_rec.col196 := p5_a253;
    ddp_list_entries_rec.col197 := p5_a254;
    ddp_list_entries_rec.col198 := p5_a255;
    ddp_list_entries_rec.col199 := p5_a256;
    ddp_list_entries_rec.col200 := p5_a257;
    ddp_list_entries_rec.col201 := p5_a258;
    ddp_list_entries_rec.col202 := p5_a259;
    ddp_list_entries_rec.col203 := p5_a260;
    ddp_list_entries_rec.col204 := p5_a261;
    ddp_list_entries_rec.col205 := p5_a262;
    ddp_list_entries_rec.col206 := p5_a263;
    ddp_list_entries_rec.col207 := p5_a264;
    ddp_list_entries_rec.col208 := p5_a265;
    ddp_list_entries_rec.col209 := p5_a266;
    ddp_list_entries_rec.col210 := p5_a267;
    ddp_list_entries_rec.col211 := p5_a268;
    ddp_list_entries_rec.col212 := p5_a269;
    ddp_list_entries_rec.col213 := p5_a270;
    ddp_list_entries_rec.col214 := p5_a271;
    ddp_list_entries_rec.col215 := p5_a272;
    ddp_list_entries_rec.col216 := p5_a273;
    ddp_list_entries_rec.col217 := p5_a274;
    ddp_list_entries_rec.col218 := p5_a275;
    ddp_list_entries_rec.col219 := p5_a276;
    ddp_list_entries_rec.col220 := p5_a277;
    ddp_list_entries_rec.col221 := p5_a278;
    ddp_list_entries_rec.col222 := p5_a279;
    ddp_list_entries_rec.col223 := p5_a280;
    ddp_list_entries_rec.col224 := p5_a281;
    ddp_list_entries_rec.col225 := p5_a282;
    ddp_list_entries_rec.col226 := p5_a283;
    ddp_list_entries_rec.col227 := p5_a284;
    ddp_list_entries_rec.col228 := p5_a285;
    ddp_list_entries_rec.col229 := p5_a286;
    ddp_list_entries_rec.col230 := p5_a287;
    ddp_list_entries_rec.col231 := p5_a288;
    ddp_list_entries_rec.col232 := p5_a289;
    ddp_list_entries_rec.col233 := p5_a290;
    ddp_list_entries_rec.col234 := p5_a291;
    ddp_list_entries_rec.col235 := p5_a292;
    ddp_list_entries_rec.col236 := p5_a293;
    ddp_list_entries_rec.col237 := p5_a294;
    ddp_list_entries_rec.col238 := p5_a295;
    ddp_list_entries_rec.col239 := p5_a296;
    ddp_list_entries_rec.col240 := p5_a297;
    ddp_list_entries_rec.col241 := p5_a298;
    ddp_list_entries_rec.col242 := p5_a299;
    ddp_list_entries_rec.col243 := p5_a300;
    ddp_list_entries_rec.col244 := p5_a301;
    ddp_list_entries_rec.col245 := p5_a302;
    ddp_list_entries_rec.col246 := p5_a303;
    ddp_list_entries_rec.col247 := p5_a304;
    ddp_list_entries_rec.col248 := p5_a305;
    ddp_list_entries_rec.col249 := p5_a306;
    ddp_list_entries_rec.col250 := p5_a307;
    ddp_list_entries_rec.col251 := p5_a308;
    ddp_list_entries_rec.col252 := p5_a309;
    ddp_list_entries_rec.col253 := p5_a310;
    ddp_list_entries_rec.col254 := p5_a311;
    ddp_list_entries_rec.col255 := p5_a312;
    ddp_list_entries_rec.col256 := p5_a313;
    ddp_list_entries_rec.col257 := p5_a314;
    ddp_list_entries_rec.col258 := p5_a315;
    ddp_list_entries_rec.col259 := p5_a316;
    ddp_list_entries_rec.col260 := p5_a317;
    ddp_list_entries_rec.col261 := p5_a318;
    ddp_list_entries_rec.col262 := p5_a319;
    ddp_list_entries_rec.col263 := p5_a320;
    ddp_list_entries_rec.col264 := p5_a321;
    ddp_list_entries_rec.col265 := p5_a322;
    ddp_list_entries_rec.col266 := p5_a323;
    ddp_list_entries_rec.col267 := p5_a324;
    ddp_list_entries_rec.col268 := p5_a325;
    ddp_list_entries_rec.col269 := p5_a326;
    ddp_list_entries_rec.col270 := p5_a327;
    ddp_list_entries_rec.col271 := p5_a328;
    ddp_list_entries_rec.col272 := p5_a329;
    ddp_list_entries_rec.col273 := p5_a330;
    ddp_list_entries_rec.col274 := p5_a331;
    ddp_list_entries_rec.col275 := p5_a332;
    ddp_list_entries_rec.col276 := p5_a333;
    ddp_list_entries_rec.col277 := p5_a334;
    ddp_list_entries_rec.col278 := p5_a335;
    ddp_list_entries_rec.col279 := p5_a336;
    ddp_list_entries_rec.col280 := p5_a337;
    ddp_list_entries_rec.col281 := p5_a338;
    ddp_list_entries_rec.col282 := p5_a339;
    ddp_list_entries_rec.col283 := p5_a340;
    ddp_list_entries_rec.col284 := p5_a341;
    ddp_list_entries_rec.col285 := p5_a342;
    ddp_list_entries_rec.col286 := p5_a343;
    ddp_list_entries_rec.col287 := p5_a344;
    ddp_list_entries_rec.col288 := p5_a345;
    ddp_list_entries_rec.col289 := p5_a346;
    ddp_list_entries_rec.col290 := p5_a347;
    ddp_list_entries_rec.col291 := p5_a348;
    ddp_list_entries_rec.col292 := p5_a349;
    ddp_list_entries_rec.col293 := p5_a350;
    ddp_list_entries_rec.col294 := p5_a351;
    ddp_list_entries_rec.col295 := p5_a352;
    ddp_list_entries_rec.col296 := p5_a353;
    ddp_list_entries_rec.col297 := p5_a354;
    ddp_list_entries_rec.col298 := p5_a355;
    ddp_list_entries_rec.col299 := p5_a356;
    ddp_list_entries_rec.col300 := p5_a357;
    ddp_list_entries_rec.curr_cp_country_code := p5_a358;
    ddp_list_entries_rec.curr_cp_phone_number := p5_a359;
    ddp_list_entries_rec.curr_cp_raw_phone_number := p5_a360;
    ddp_list_entries_rec.curr_cp_area_code := rosetta_g_miss_num_map(p5_a361);
    ddp_list_entries_rec.curr_cp_id := rosetta_g_miss_num_map(p5_a362);
    ddp_list_entries_rec.curr_cp_index := rosetta_g_miss_num_map(p5_a363);
    ddp_list_entries_rec.curr_cp_time_zone := rosetta_g_miss_num_map(p5_a364);
    ddp_list_entries_rec.curr_cp_time_zone_aux := rosetta_g_miss_num_map(p5_a365);
    ddp_list_entries_rec.party_id := rosetta_g_miss_num_map(p5_a366);
    ddp_list_entries_rec.parent_party_id := rosetta_g_miss_num_map(p5_a367);
    ddp_list_entries_rec.imp_source_line_id := rosetta_g_miss_num_map(p5_a368);
    ddp_list_entries_rec.usage_restriction := p5_a369;
    ddp_list_entries_rec.next_call_time := rosetta_g_miss_date_in_map(p5_a370);
    ddp_list_entries_rec.callback_flag := p5_a371;
    ddp_list_entries_rec.do_not_use_flag := p5_a372;
    ddp_list_entries_rec.do_not_use_reason := p5_a373;
    ddp_list_entries_rec.record_out_flag := p5_a374;
    ddp_list_entries_rec.record_release_time := rosetta_g_miss_date_in_map(p5_a375);
    ddp_list_entries_rec.group_code := p5_a376;
    ddp_list_entries_rec.newly_updated_flag := p5_a377;
    ddp_list_entries_rec.outcome_id := rosetta_g_miss_num_map(p5_a378);
    ddp_list_entries_rec.result_id := rosetta_g_miss_num_map(p5_a379);
    ddp_list_entries_rec.reason_id := rosetta_g_miss_num_map(p5_a380);
    ddp_list_entries_rec.notes := p5_a381;
    ddp_list_entries_rec.vehicle_response_code := p5_a382;
    ddp_list_entries_rec.sales_agent_email_address := p5_a383;
    ddp_list_entries_rec.resource_id := rosetta_g_miss_num_map(p5_a384);
    ddp_list_entries_rec.location_id := rosetta_g_miss_num_map(p5_a385);
    ddp_list_entries_rec.contact_point_id := rosetta_g_miss_num_map(p5_a386);
    ddp_list_entries_rec.last_contacted_date := rosetta_g_miss_date_in_map(p5_a387);

    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.validate_list_entries_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_list_entries_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure init_entry_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  NUMBER
    , p0_a2 OUT NOCOPY  DATE
    , p0_a3 OUT NOCOPY  NUMBER
    , p0_a4 OUT NOCOPY  DATE
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  VARCHAR2
    , p0_a11 OUT NOCOPY  VARCHAR2
    , p0_a12 OUT NOCOPY  VARCHAR2
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  NUMBER
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  NUMBER
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  VARCHAR2
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
    , p0_a26 OUT NOCOPY  NUMBER
    , p0_a27 OUT NOCOPY  NUMBER
    , p0_a28 OUT NOCOPY  NUMBER
    , p0_a29 OUT NOCOPY  NUMBER
    , p0_a30 OUT NOCOPY  NUMBER
    , p0_a31 OUT NOCOPY  NUMBER
    , p0_a32 OUT NOCOPY  NUMBER
    , p0_a33 OUT NOCOPY  NUMBER
    , p0_a34 OUT NOCOPY  NUMBER
    , p0_a35 OUT NOCOPY  VARCHAR2
    , p0_a36 OUT NOCOPY  VARCHAR2
    , p0_a37 OUT NOCOPY  VARCHAR2
    , p0_a38 OUT NOCOPY  NUMBER
    , p0_a39 OUT NOCOPY  VARCHAR2
    , p0_a40 OUT NOCOPY  NUMBER
    , p0_a41 OUT NOCOPY  NUMBER
    , p0_a42 OUT NOCOPY  NUMBER
    , p0_a43 OUT NOCOPY  NUMBER
    , p0_a44 OUT NOCOPY  VARCHAR2
    , p0_a45 OUT NOCOPY  VARCHAR2
    , p0_a46 OUT NOCOPY  VARCHAR2
    , p0_a47 OUT NOCOPY  VARCHAR2
    , p0_a48 OUT NOCOPY  VARCHAR2
    , p0_a49 OUT NOCOPY  VARCHAR2
    , p0_a50 OUT NOCOPY  VARCHAR2
    , p0_a51 OUT NOCOPY  VARCHAR2
    , p0_a52 OUT NOCOPY  VARCHAR2
    , p0_a53 OUT NOCOPY  VARCHAR2
    , p0_a54 OUT NOCOPY  VARCHAR2
    , p0_a55 OUT NOCOPY  VARCHAR2
    , p0_a56 OUT NOCOPY  VARCHAR2
    , p0_a57 OUT NOCOPY  VARCHAR2
    , p0_a58 OUT NOCOPY  VARCHAR2
    , p0_a59 OUT NOCOPY  VARCHAR2
    , p0_a60 OUT NOCOPY  VARCHAR2
    , p0_a61 OUT NOCOPY  VARCHAR2
    , p0_a62 OUT NOCOPY  VARCHAR2
    , p0_a63 OUT NOCOPY  VARCHAR2
    , p0_a64 OUT NOCOPY  VARCHAR2
    , p0_a65 OUT NOCOPY  VARCHAR2
    , p0_a66 OUT NOCOPY  VARCHAR2
    , p0_a67 OUT NOCOPY  VARCHAR2
    , p0_a68 OUT NOCOPY  VARCHAR2
    , p0_a69 OUT NOCOPY  VARCHAR2
    , p0_a70 OUT NOCOPY  VARCHAR2
    , p0_a71 OUT NOCOPY  VARCHAR2
    , p0_a72 OUT NOCOPY  VARCHAR2
    , p0_a73 OUT NOCOPY  VARCHAR2
    , p0_a74 OUT NOCOPY  VARCHAR2
    , p0_a75 OUT NOCOPY  VARCHAR2
    , p0_a76 OUT NOCOPY  VARCHAR2
    , p0_a77 OUT NOCOPY  VARCHAR2
    , p0_a78 OUT NOCOPY  VARCHAR2
    , p0_a79 OUT NOCOPY  VARCHAR2
    , p0_a80 OUT NOCOPY  VARCHAR2
    , p0_a81 OUT NOCOPY  VARCHAR2
    , p0_a82 OUT NOCOPY  VARCHAR2
    , p0_a83 OUT NOCOPY  VARCHAR2
    , p0_a84 OUT NOCOPY  VARCHAR2
    , p0_a85 OUT NOCOPY  VARCHAR2
    , p0_a86 OUT NOCOPY  VARCHAR2
    , p0_a87 OUT NOCOPY  VARCHAR2
    , p0_a88 OUT NOCOPY  VARCHAR2
    , p0_a89 OUT NOCOPY  VARCHAR2
    , p0_a90 OUT NOCOPY  VARCHAR2
    , p0_a91 OUT NOCOPY  VARCHAR2
    , p0_a92 OUT NOCOPY  VARCHAR2
    , p0_a93 OUT NOCOPY  VARCHAR2
    , p0_a94 OUT NOCOPY  VARCHAR2
    , p0_a95 OUT NOCOPY  VARCHAR2
    , p0_a96 OUT NOCOPY  VARCHAR2
    , p0_a97 OUT NOCOPY  VARCHAR2
    , p0_a98 OUT NOCOPY  VARCHAR2
    , p0_a99 OUT NOCOPY  VARCHAR2
    , p0_a100 OUT NOCOPY  VARCHAR2
    , p0_a101 OUT NOCOPY  VARCHAR2
    , p0_a102 OUT NOCOPY  VARCHAR2
    , p0_a103 OUT NOCOPY  VARCHAR2
    , p0_a104 OUT NOCOPY  VARCHAR2
    , p0_a105 OUT NOCOPY  VARCHAR2
    , p0_a106 OUT NOCOPY  VARCHAR2
    , p0_a107 OUT NOCOPY  VARCHAR2
    , p0_a108 OUT NOCOPY  VARCHAR2
    , p0_a109 OUT NOCOPY  VARCHAR2
    , p0_a110 OUT NOCOPY  VARCHAR2
    , p0_a111 OUT NOCOPY  VARCHAR2
    , p0_a112 OUT NOCOPY  VARCHAR2
    , p0_a113 OUT NOCOPY  VARCHAR2
    , p0_a114 OUT NOCOPY  VARCHAR2
    , p0_a115 OUT NOCOPY  VARCHAR2
    , p0_a116 OUT NOCOPY  VARCHAR2
    , p0_a117 OUT NOCOPY  VARCHAR2
    , p0_a118 OUT NOCOPY  VARCHAR2
    , p0_a119 OUT NOCOPY  VARCHAR2
    , p0_a120 OUT NOCOPY  VARCHAR2
    , p0_a121 OUT NOCOPY  VARCHAR2
    , p0_a122 OUT NOCOPY  VARCHAR2
    , p0_a123 OUT NOCOPY  VARCHAR2
    , p0_a124 OUT NOCOPY  VARCHAR2
    , p0_a125 OUT NOCOPY  VARCHAR2
    , p0_a126 OUT NOCOPY  VARCHAR2
    , p0_a127 OUT NOCOPY  VARCHAR2
    , p0_a128 OUT NOCOPY  VARCHAR2
    , p0_a129 OUT NOCOPY  VARCHAR2
    , p0_a130 OUT NOCOPY  VARCHAR2
    , p0_a131 OUT NOCOPY  VARCHAR2
    , p0_a132 OUT NOCOPY  VARCHAR2
    , p0_a133 OUT NOCOPY  VARCHAR2
    , p0_a134 OUT NOCOPY  VARCHAR2
    , p0_a135 OUT NOCOPY  VARCHAR2
    , p0_a136 OUT NOCOPY  VARCHAR2
    , p0_a137 OUT NOCOPY  VARCHAR2
    , p0_a138 OUT NOCOPY  VARCHAR2
    , p0_a139 OUT NOCOPY  VARCHAR2
    , p0_a140 OUT NOCOPY  VARCHAR2
    , p0_a141 OUT NOCOPY  VARCHAR2
    , p0_a142 OUT NOCOPY  VARCHAR2
    , p0_a143 OUT NOCOPY  VARCHAR2
    , p0_a144 OUT NOCOPY  VARCHAR2
    , p0_a145 OUT NOCOPY  VARCHAR2
    , p0_a146 OUT NOCOPY  VARCHAR2
    , p0_a147 OUT NOCOPY  VARCHAR2
    , p0_a148 OUT NOCOPY  VARCHAR2
    , p0_a149 OUT NOCOPY  VARCHAR2
    , p0_a150 OUT NOCOPY  VARCHAR2
    , p0_a151 OUT NOCOPY  VARCHAR2
    , p0_a152 OUT NOCOPY  VARCHAR2
    , p0_a153 OUT NOCOPY  VARCHAR2
    , p0_a154 OUT NOCOPY  VARCHAR2
    , p0_a155 OUT NOCOPY  VARCHAR2
    , p0_a156 OUT NOCOPY  VARCHAR2
    , p0_a157 OUT NOCOPY  VARCHAR2
    , p0_a158 OUT NOCOPY  VARCHAR2
    , p0_a159 OUT NOCOPY  VARCHAR2
    , p0_a160 OUT NOCOPY  VARCHAR2
    , p0_a161 OUT NOCOPY  VARCHAR2
    , p0_a162 OUT NOCOPY  VARCHAR2
    , p0_a163 OUT NOCOPY  VARCHAR2
    , p0_a164 OUT NOCOPY  VARCHAR2
    , p0_a165 OUT NOCOPY  VARCHAR2
    , p0_a166 OUT NOCOPY  VARCHAR2
    , p0_a167 OUT NOCOPY  VARCHAR2
    , p0_a168 OUT NOCOPY  VARCHAR2
    , p0_a169 OUT NOCOPY  VARCHAR2
    , p0_a170 OUT NOCOPY  VARCHAR2
    , p0_a171 OUT NOCOPY  VARCHAR2
    , p0_a172 OUT NOCOPY  VARCHAR2
    , p0_a173 OUT NOCOPY  VARCHAR2
    , p0_a174 OUT NOCOPY  VARCHAR2
    , p0_a175 OUT NOCOPY  VARCHAR2
    , p0_a176 OUT NOCOPY  VARCHAR2
    , p0_a177 OUT NOCOPY  VARCHAR2
    , p0_a178 OUT NOCOPY  VARCHAR2
    , p0_a179 OUT NOCOPY  VARCHAR2
    , p0_a180 OUT NOCOPY  VARCHAR2
    , p0_a181 OUT NOCOPY  VARCHAR2
    , p0_a182 OUT NOCOPY  VARCHAR2
    , p0_a183 OUT NOCOPY  VARCHAR2
    , p0_a184 OUT NOCOPY  VARCHAR2
    , p0_a185 OUT NOCOPY  VARCHAR2
    , p0_a186 OUT NOCOPY  VARCHAR2
    , p0_a187 OUT NOCOPY  VARCHAR2
    , p0_a188 OUT NOCOPY  VARCHAR2
    , p0_a189 OUT NOCOPY  VARCHAR2
    , p0_a190 OUT NOCOPY  VARCHAR2
    , p0_a191 OUT NOCOPY  VARCHAR2
    , p0_a192 OUT NOCOPY  VARCHAR2
    , p0_a193 OUT NOCOPY  VARCHAR2
    , p0_a194 OUT NOCOPY  VARCHAR2
    , p0_a195 OUT NOCOPY  VARCHAR2
    , p0_a196 OUT NOCOPY  VARCHAR2
    , p0_a197 OUT NOCOPY  VARCHAR2
    , p0_a198 OUT NOCOPY  VARCHAR2
    , p0_a199 OUT NOCOPY  VARCHAR2
    , p0_a200 OUT NOCOPY  VARCHAR2
    , p0_a201 OUT NOCOPY  VARCHAR2
    , p0_a202 OUT NOCOPY  VARCHAR2
    , p0_a203 OUT NOCOPY  VARCHAR2
    , p0_a204 OUT NOCOPY  VARCHAR2
    , p0_a205 OUT NOCOPY  VARCHAR2
    , p0_a206 OUT NOCOPY  VARCHAR2
    , p0_a207 OUT NOCOPY  VARCHAR2
    , p0_a208 OUT NOCOPY  VARCHAR2
    , p0_a209 OUT NOCOPY  VARCHAR2
    , p0_a210 OUT NOCOPY  VARCHAR2
    , p0_a211 OUT NOCOPY  VARCHAR2
    , p0_a212 OUT NOCOPY  VARCHAR2
    , p0_a213 OUT NOCOPY  VARCHAR2
    , p0_a214 OUT NOCOPY  VARCHAR2
    , p0_a215 OUT NOCOPY  VARCHAR2
    , p0_a216 OUT NOCOPY  VARCHAR2
    , p0_a217 OUT NOCOPY  VARCHAR2
    , p0_a218 OUT NOCOPY  VARCHAR2
    , p0_a219 OUT NOCOPY  VARCHAR2
    , p0_a220 OUT NOCOPY  VARCHAR2
    , p0_a221 OUT NOCOPY  VARCHAR2
    , p0_a222 OUT NOCOPY  VARCHAR2
    , p0_a223 OUT NOCOPY  VARCHAR2
    , p0_a224 OUT NOCOPY  VARCHAR2
    , p0_a225 OUT NOCOPY  VARCHAR2
    , p0_a226 OUT NOCOPY  VARCHAR2
    , p0_a227 OUT NOCOPY  VARCHAR2
    , p0_a228 OUT NOCOPY  VARCHAR2
    , p0_a229 OUT NOCOPY  VARCHAR2
    , p0_a230 OUT NOCOPY  VARCHAR2
    , p0_a231 OUT NOCOPY  VARCHAR2
    , p0_a232 OUT NOCOPY  VARCHAR2
    , p0_a233 OUT NOCOPY  VARCHAR2
    , p0_a234 OUT NOCOPY  VARCHAR2
    , p0_a235 OUT NOCOPY  VARCHAR2
    , p0_a236 OUT NOCOPY  VARCHAR2
    , p0_a237 OUT NOCOPY  VARCHAR2
    , p0_a238 OUT NOCOPY  VARCHAR2
    , p0_a239 OUT NOCOPY  VARCHAR2
    , p0_a240 OUT NOCOPY  VARCHAR2
    , p0_a241 OUT NOCOPY  VARCHAR2
    , p0_a242 OUT NOCOPY  VARCHAR2
    , p0_a243 OUT NOCOPY  VARCHAR2
    , p0_a244 OUT NOCOPY  VARCHAR2
    , p0_a245 OUT NOCOPY  VARCHAR2
    , p0_a246 OUT NOCOPY  VARCHAR2
    , p0_a247 OUT NOCOPY  VARCHAR2
    , p0_a248 OUT NOCOPY  VARCHAR2
    , p0_a249 OUT NOCOPY  VARCHAR2
    , p0_a250 OUT NOCOPY  VARCHAR2
    , p0_a251 OUT NOCOPY  VARCHAR2
    , p0_a252 OUT NOCOPY  VARCHAR2
    , p0_a253 OUT NOCOPY  VARCHAR2
    , p0_a254 OUT NOCOPY  VARCHAR2
    , p0_a255 OUT NOCOPY  VARCHAR2
    , p0_a256 OUT NOCOPY  VARCHAR2
    , p0_a257 OUT NOCOPY  VARCHAR2
    , p0_a258 OUT NOCOPY  VARCHAR2
    , p0_a259 OUT NOCOPY  VARCHAR2
    , p0_a260 OUT NOCOPY  VARCHAR2
    , p0_a261 OUT NOCOPY  VARCHAR2
    , p0_a262 OUT NOCOPY  VARCHAR2
    , p0_a263 OUT NOCOPY  VARCHAR2
    , p0_a264 OUT NOCOPY  VARCHAR2
    , p0_a265 OUT NOCOPY  VARCHAR2
    , p0_a266 OUT NOCOPY  VARCHAR2
    , p0_a267 OUT NOCOPY  VARCHAR2
    , p0_a268 OUT NOCOPY  VARCHAR2
    , p0_a269 OUT NOCOPY  VARCHAR2
    , p0_a270 OUT NOCOPY  VARCHAR2
    , p0_a271 OUT NOCOPY  VARCHAR2
    , p0_a272 OUT NOCOPY  VARCHAR2
    , p0_a273 OUT NOCOPY  VARCHAR2
    , p0_a274 OUT NOCOPY  VARCHAR2
    , p0_a275 OUT NOCOPY  VARCHAR2
    , p0_a276 OUT NOCOPY  VARCHAR2
    , p0_a277 OUT NOCOPY  VARCHAR2
    , p0_a278 OUT NOCOPY  VARCHAR2
    , p0_a279 OUT NOCOPY  VARCHAR2
    , p0_a280 OUT NOCOPY  VARCHAR2
    , p0_a281 OUT NOCOPY  VARCHAR2
    , p0_a282 OUT NOCOPY  VARCHAR2
    , p0_a283 OUT NOCOPY  VARCHAR2
    , p0_a284 OUT NOCOPY  VARCHAR2
    , p0_a285 OUT NOCOPY  VARCHAR2
    , p0_a286 OUT NOCOPY  VARCHAR2
    , p0_a287 OUT NOCOPY  VARCHAR2
    , p0_a288 OUT NOCOPY  VARCHAR2
    , p0_a289 OUT NOCOPY  VARCHAR2
    , p0_a290 OUT NOCOPY  VARCHAR2
    , p0_a291 OUT NOCOPY  VARCHAR2
    , p0_a292 OUT NOCOPY  VARCHAR2
    , p0_a293 OUT NOCOPY  VARCHAR2
    , p0_a294 OUT NOCOPY  VARCHAR2
    , p0_a295 OUT NOCOPY  VARCHAR2
    , p0_a296 OUT NOCOPY  VARCHAR2
    , p0_a297 OUT NOCOPY  VARCHAR2
    , p0_a298 OUT NOCOPY  VARCHAR2
    , p0_a299 OUT NOCOPY  VARCHAR2
    , p0_a300 OUT NOCOPY  VARCHAR2
    , p0_a301 OUT NOCOPY  VARCHAR2
    , p0_a302 OUT NOCOPY  VARCHAR2
    , p0_a303 OUT NOCOPY  VARCHAR2
    , p0_a304 OUT NOCOPY  VARCHAR2
    , p0_a305 OUT NOCOPY  VARCHAR2
    , p0_a306 OUT NOCOPY  VARCHAR2
    , p0_a307 OUT NOCOPY  VARCHAR2
    , p0_a308 OUT NOCOPY  VARCHAR2
    , p0_a309 OUT NOCOPY  VARCHAR2
    , p0_a310 OUT NOCOPY  VARCHAR2
    , p0_a311 OUT NOCOPY  VARCHAR2
    , p0_a312 OUT NOCOPY  VARCHAR2
    , p0_a313 OUT NOCOPY  VARCHAR2
    , p0_a314 OUT NOCOPY  VARCHAR2
    , p0_a315 OUT NOCOPY  VARCHAR2
    , p0_a316 OUT NOCOPY  VARCHAR2
    , p0_a317 OUT NOCOPY  VARCHAR2
    , p0_a318 OUT NOCOPY  VARCHAR2
    , p0_a319 OUT NOCOPY  VARCHAR2
    , p0_a320 OUT NOCOPY  VARCHAR2
    , p0_a321 OUT NOCOPY  VARCHAR2
    , p0_a322 OUT NOCOPY  VARCHAR2
    , p0_a323 OUT NOCOPY  VARCHAR2
    , p0_a324 OUT NOCOPY  VARCHAR2
    , p0_a325 OUT NOCOPY  VARCHAR2
    , p0_a326 OUT NOCOPY  VARCHAR2
    , p0_a327 OUT NOCOPY  VARCHAR2
    , p0_a328 OUT NOCOPY  VARCHAR2
    , p0_a329 OUT NOCOPY  VARCHAR2
    , p0_a330 OUT NOCOPY  VARCHAR2
    , p0_a331 OUT NOCOPY  VARCHAR2
    , p0_a332 OUT NOCOPY  VARCHAR2
    , p0_a333 OUT NOCOPY  VARCHAR2
    , p0_a334 OUT NOCOPY  VARCHAR2
    , p0_a335 OUT NOCOPY  VARCHAR2
    , p0_a336 OUT NOCOPY  VARCHAR2
    , p0_a337 OUT NOCOPY  VARCHAR2
    , p0_a338 OUT NOCOPY  VARCHAR2
    , p0_a339 OUT NOCOPY  VARCHAR2
    , p0_a340 OUT NOCOPY  VARCHAR2
    , p0_a341 OUT NOCOPY  VARCHAR2
    , p0_a342 OUT NOCOPY  VARCHAR2
    , p0_a343 OUT NOCOPY  VARCHAR2
    , p0_a344 OUT NOCOPY  VARCHAR2
    , p0_a345 OUT NOCOPY  VARCHAR2
    , p0_a346 OUT NOCOPY  VARCHAR2
    , p0_a347 OUT NOCOPY  VARCHAR2
    , p0_a348 OUT NOCOPY  VARCHAR2
    , p0_a349 OUT NOCOPY  VARCHAR2
    , p0_a350 OUT NOCOPY  VARCHAR2
    , p0_a351 OUT NOCOPY  VARCHAR2
    , p0_a352 OUT NOCOPY  VARCHAR2
    , p0_a353 OUT NOCOPY  VARCHAR2
    , p0_a354 OUT NOCOPY  VARCHAR2
    , p0_a355 OUT NOCOPY  VARCHAR2
    , p0_a356 OUT NOCOPY  VARCHAR2
    , p0_a357 OUT NOCOPY  VARCHAR2
    , p0_a358 OUT NOCOPY  VARCHAR2
    , p0_a359 OUT NOCOPY  VARCHAR2
    , p0_a360 OUT NOCOPY  VARCHAR2
    , p0_a361 OUT NOCOPY  NUMBER
    , p0_a362 OUT NOCOPY  NUMBER
    , p0_a363 OUT NOCOPY  NUMBER
    , p0_a364 OUT NOCOPY  NUMBER
    , p0_a365 OUT NOCOPY  NUMBER
    , p0_a366 OUT NOCOPY  NUMBER
    , p0_a367 OUT NOCOPY  NUMBER
    , p0_a368 OUT NOCOPY  NUMBER
    , p0_a369 OUT NOCOPY  VARCHAR2
    , p0_a370 OUT NOCOPY  DATE
    , p0_a371 OUT NOCOPY  VARCHAR2
    , p0_a372 OUT NOCOPY  VARCHAR2
    , p0_a373 OUT NOCOPY  VARCHAR2
    , p0_a374 OUT NOCOPY  VARCHAR2
    , p0_a375 OUT NOCOPY  DATE
    , p0_a376 OUT NOCOPY  VARCHAR2
    , p0_a377 OUT NOCOPY  VARCHAR2
    , p0_a378 OUT NOCOPY  NUMBER
    , p0_a379 OUT NOCOPY  NUMBER
    , p0_a380 OUT NOCOPY  NUMBER
    , p0_a381 OUT NOCOPY  VARCHAR2
    , p0_a382 OUT NOCOPY  VARCHAR2
    , p0_a383 OUT NOCOPY  VARCHAR2
    , p0_a384 OUT NOCOPY  NUMBER
    , p0_a385 OUT NOCOPY  NUMBER
    , p0_a386 OUT NOCOPY  NUMBER
    , p0_a387 OUT NOCOPY  DATE
  )
  as
    ddx_entry_rec ams_list_entries_pvt.list_entries_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_list_entries_pvt.init_entry_rec(ddx_entry_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_entry_rec.list_entry_id);
    p0_a1 := rosetta_g_miss_num_map(ddx_entry_rec.list_header_id);
    p0_a2 := ddx_entry_rec.last_update_date;
    p0_a3 := rosetta_g_miss_num_map(ddx_entry_rec.last_updated_by);
    p0_a4 := ddx_entry_rec.creation_date;
    p0_a5 := rosetta_g_miss_num_map(ddx_entry_rec.created_by);
    p0_a6 := rosetta_g_miss_num_map(ddx_entry_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_entry_rec.object_version_number);
    p0_a8 := rosetta_g_miss_num_map(ddx_entry_rec.list_select_action_id);
    p0_a9 := ddx_entry_rec.arc_list_select_action_from;
    p0_a10 := ddx_entry_rec.list_select_action_from_name;
    p0_a11 := ddx_entry_rec.source_code;
    p0_a12 := ddx_entry_rec.arc_list_used_by_source;
    p0_a13 := rosetta_g_miss_num_map(ddx_entry_rec.source_code_for_id);
    p0_a14 := ddx_entry_rec.pin_code;
    p0_a15 := rosetta_g_miss_num_map(ddx_entry_rec.list_entry_source_system_id);
    p0_a16 := ddx_entry_rec.list_entry_source_system_type;
    p0_a17 := rosetta_g_miss_num_map(ddx_entry_rec.view_application_id);
    p0_a18 := ddx_entry_rec.manually_entered_flag;
    p0_a19 := ddx_entry_rec.marked_as_duplicate_flag;
    p0_a20 := ddx_entry_rec.marked_as_random_flag;
    p0_a21 := ddx_entry_rec.part_of_control_group_flag;
    p0_a22 := ddx_entry_rec.exclude_in_triggered_list_flag;
    p0_a23 := ddx_entry_rec.enabled_flag;
    p0_a24 := ddx_entry_rec.cell_code;
    p0_a25 := ddx_entry_rec.dedupe_key;
    p0_a26 := rosetta_g_miss_num_map(ddx_entry_rec.randomly_generated_number);
    p0_a27 := rosetta_g_miss_num_map(ddx_entry_rec.campaign_id);
    p0_a28 := rosetta_g_miss_num_map(ddx_entry_rec.media_id);
    p0_a29 := rosetta_g_miss_num_map(ddx_entry_rec.channel_id);
    p0_a30 := rosetta_g_miss_num_map(ddx_entry_rec.channel_schedule_id);
    p0_a31 := rosetta_g_miss_num_map(ddx_entry_rec.event_offer_id);
    p0_a32 := rosetta_g_miss_num_map(ddx_entry_rec.customer_id);
    p0_a33 := rosetta_g_miss_num_map(ddx_entry_rec.market_segment_id);
    p0_a34 := rosetta_g_miss_num_map(ddx_entry_rec.vendor_id);
    p0_a35 := ddx_entry_rec.transfer_flag;
    p0_a36 := ddx_entry_rec.transfer_status;
    p0_a37 := ddx_entry_rec.list_source;
    p0_a38 := rosetta_g_miss_num_map(ddx_entry_rec.duplicate_master_entry_id);
    p0_a39 := ddx_entry_rec.marked_flag;
    p0_a40 := rosetta_g_miss_num_map(ddx_entry_rec.lead_id);
    p0_a41 := rosetta_g_miss_num_map(ddx_entry_rec.letter_id);
    p0_a42 := rosetta_g_miss_num_map(ddx_entry_rec.picking_header_id);
    p0_a43 := rosetta_g_miss_num_map(ddx_entry_rec.batch_id);
    p0_a44 := ddx_entry_rec.suffix;
    p0_a45 := ddx_entry_rec.first_name;
    p0_a46 := ddx_entry_rec.last_name;
    p0_a47 := ddx_entry_rec.customer_name;
    p0_a48 := ddx_entry_rec.title;
    p0_a49 := ddx_entry_rec.address_line1;
    p0_a50 := ddx_entry_rec.address_line2;
    p0_a51 := ddx_entry_rec.city;
    p0_a52 := ddx_entry_rec.state;
    p0_a53 := ddx_entry_rec.zipcode;
    p0_a54 := ddx_entry_rec.country;
    p0_a55 := ddx_entry_rec.fax;
    p0_a56 := ddx_entry_rec.phone;
    p0_a57 := ddx_entry_rec.email_address;
    p0_a58 := ddx_entry_rec.col1;
    p0_a59 := ddx_entry_rec.col2;
    p0_a60 := ddx_entry_rec.col3;
    p0_a61 := ddx_entry_rec.col4;
    p0_a62 := ddx_entry_rec.col5;
    p0_a63 := ddx_entry_rec.col6;
    p0_a64 := ddx_entry_rec.col7;
    p0_a65 := ddx_entry_rec.col8;
    p0_a66 := ddx_entry_rec.col9;
    p0_a67 := ddx_entry_rec.col10;
    p0_a68 := ddx_entry_rec.col11;
    p0_a69 := ddx_entry_rec.col12;
    p0_a70 := ddx_entry_rec.col13;
    p0_a71 := ddx_entry_rec.col14;
    p0_a72 := ddx_entry_rec.col15;
    p0_a73 := ddx_entry_rec.col16;
    p0_a74 := ddx_entry_rec.col17;
    p0_a75 := ddx_entry_rec.col18;
    p0_a76 := ddx_entry_rec.col19;
    p0_a77 := ddx_entry_rec.col20;
    p0_a78 := ddx_entry_rec.col21;
    p0_a79 := ddx_entry_rec.col22;
    p0_a80 := ddx_entry_rec.col23;
    p0_a81 := ddx_entry_rec.col24;
    p0_a82 := ddx_entry_rec.col25;
    p0_a83 := ddx_entry_rec.col26;
    p0_a84 := ddx_entry_rec.col27;
    p0_a85 := ddx_entry_rec.col28;
    p0_a86 := ddx_entry_rec.col29;
    p0_a87 := ddx_entry_rec.col30;
    p0_a88 := ddx_entry_rec.col31;
    p0_a89 := ddx_entry_rec.col32;
    p0_a90 := ddx_entry_rec.col33;
    p0_a91 := ddx_entry_rec.col34;
    p0_a92 := ddx_entry_rec.col35;
    p0_a93 := ddx_entry_rec.col36;
    p0_a94 := ddx_entry_rec.col37;
    p0_a95 := ddx_entry_rec.col38;
    p0_a96 := ddx_entry_rec.col39;
    p0_a97 := ddx_entry_rec.col40;
    p0_a98 := ddx_entry_rec.col41;
    p0_a99 := ddx_entry_rec.col42;
    p0_a100 := ddx_entry_rec.col43;
    p0_a101 := ddx_entry_rec.col44;
    p0_a102 := ddx_entry_rec.col45;
    p0_a103 := ddx_entry_rec.col46;
    p0_a104 := ddx_entry_rec.col47;
    p0_a105 := ddx_entry_rec.col48;
    p0_a106 := ddx_entry_rec.col49;
    p0_a107 := ddx_entry_rec.col50;
    p0_a108 := ddx_entry_rec.col51;
    p0_a109 := ddx_entry_rec.col52;
    p0_a110 := ddx_entry_rec.col53;
    p0_a111 := ddx_entry_rec.col54;
    p0_a112 := ddx_entry_rec.col55;
    p0_a113 := ddx_entry_rec.col56;
    p0_a114 := ddx_entry_rec.col57;
    p0_a115 := ddx_entry_rec.col58;
    p0_a116 := ddx_entry_rec.col59;
    p0_a117 := ddx_entry_rec.col60;
    p0_a118 := ddx_entry_rec.col61;
    p0_a119 := ddx_entry_rec.col62;
    p0_a120 := ddx_entry_rec.col63;
    p0_a121 := ddx_entry_rec.col64;
    p0_a122 := ddx_entry_rec.col65;
    p0_a123 := ddx_entry_rec.col66;
    p0_a124 := ddx_entry_rec.col67;
    p0_a125 := ddx_entry_rec.col68;
    p0_a126 := ddx_entry_rec.col69;
    p0_a127 := ddx_entry_rec.col70;
    p0_a128 := ddx_entry_rec.col71;
    p0_a129 := ddx_entry_rec.col72;
    p0_a130 := ddx_entry_rec.col73;
    p0_a131 := ddx_entry_rec.col74;
    p0_a132 := ddx_entry_rec.col75;
    p0_a133 := ddx_entry_rec.col76;
    p0_a134 := ddx_entry_rec.col77;
    p0_a135 := ddx_entry_rec.col78;
    p0_a136 := ddx_entry_rec.col79;
    p0_a137 := ddx_entry_rec.col80;
    p0_a138 := ddx_entry_rec.col81;
    p0_a139 := ddx_entry_rec.col82;
    p0_a140 := ddx_entry_rec.col83;
    p0_a141 := ddx_entry_rec.col84;
    p0_a142 := ddx_entry_rec.col85;
    p0_a143 := ddx_entry_rec.col86;
    p0_a144 := ddx_entry_rec.col87;
    p0_a145 := ddx_entry_rec.col88;
    p0_a146 := ddx_entry_rec.col89;
    p0_a147 := ddx_entry_rec.col90;
    p0_a148 := ddx_entry_rec.col91;
    p0_a149 := ddx_entry_rec.col92;
    p0_a150 := ddx_entry_rec.col93;
    p0_a151 := ddx_entry_rec.col94;
    p0_a152 := ddx_entry_rec.col95;
    p0_a153 := ddx_entry_rec.col96;
    p0_a154 := ddx_entry_rec.col97;
    p0_a155 := ddx_entry_rec.col98;
    p0_a156 := ddx_entry_rec.col99;
    p0_a157 := ddx_entry_rec.col100;
    p0_a158 := ddx_entry_rec.col101;
    p0_a159 := ddx_entry_rec.col102;
    p0_a160 := ddx_entry_rec.col103;
    p0_a161 := ddx_entry_rec.col104;
    p0_a162 := ddx_entry_rec.col105;
    p0_a163 := ddx_entry_rec.col106;
    p0_a164 := ddx_entry_rec.col107;
    p0_a165 := ddx_entry_rec.col108;
    p0_a166 := ddx_entry_rec.col109;
    p0_a167 := ddx_entry_rec.col110;
    p0_a168 := ddx_entry_rec.col111;
    p0_a169 := ddx_entry_rec.col112;
    p0_a170 := ddx_entry_rec.col113;
    p0_a171 := ddx_entry_rec.col114;
    p0_a172 := ddx_entry_rec.col115;
    p0_a173 := ddx_entry_rec.col116;
    p0_a174 := ddx_entry_rec.col117;
    p0_a175 := ddx_entry_rec.col118;
    p0_a176 := ddx_entry_rec.col119;
    p0_a177 := ddx_entry_rec.col120;
    p0_a178 := ddx_entry_rec.col121;
    p0_a179 := ddx_entry_rec.col122;
    p0_a180 := ddx_entry_rec.col123;
    p0_a181 := ddx_entry_rec.col124;
    p0_a182 := ddx_entry_rec.col125;
    p0_a183 := ddx_entry_rec.col126;
    p0_a184 := ddx_entry_rec.col127;
    p0_a185 := ddx_entry_rec.col128;
    p0_a186 := ddx_entry_rec.col129;
    p0_a187 := ddx_entry_rec.col130;
    p0_a188 := ddx_entry_rec.col131;
    p0_a189 := ddx_entry_rec.col132;
    p0_a190 := ddx_entry_rec.col133;
    p0_a191 := ddx_entry_rec.col134;
    p0_a192 := ddx_entry_rec.col135;
    p0_a193 := ddx_entry_rec.col136;
    p0_a194 := ddx_entry_rec.col137;
    p0_a195 := ddx_entry_rec.col138;
    p0_a196 := ddx_entry_rec.col139;
    p0_a197 := ddx_entry_rec.col140;
    p0_a198 := ddx_entry_rec.col141;
    p0_a199 := ddx_entry_rec.col142;
    p0_a200 := ddx_entry_rec.col143;
    p0_a201 := ddx_entry_rec.col144;
    p0_a202 := ddx_entry_rec.col145;
    p0_a203 := ddx_entry_rec.col146;
    p0_a204 := ddx_entry_rec.col147;
    p0_a205 := ddx_entry_rec.col148;
    p0_a206 := ddx_entry_rec.col149;
    p0_a207 := ddx_entry_rec.col150;
    p0_a208 := ddx_entry_rec.col151;
    p0_a209 := ddx_entry_rec.col152;
    p0_a210 := ddx_entry_rec.col153;
    p0_a211 := ddx_entry_rec.col154;
    p0_a212 := ddx_entry_rec.col155;
    p0_a213 := ddx_entry_rec.col156;
    p0_a214 := ddx_entry_rec.col157;
    p0_a215 := ddx_entry_rec.col158;
    p0_a216 := ddx_entry_rec.col159;
    p0_a217 := ddx_entry_rec.col160;
    p0_a218 := ddx_entry_rec.col161;
    p0_a219 := ddx_entry_rec.col162;
    p0_a220 := ddx_entry_rec.col163;
    p0_a221 := ddx_entry_rec.col164;
    p0_a222 := ddx_entry_rec.col165;
    p0_a223 := ddx_entry_rec.col166;
    p0_a224 := ddx_entry_rec.col167;
    p0_a225 := ddx_entry_rec.col168;
    p0_a226 := ddx_entry_rec.col169;
    p0_a227 := ddx_entry_rec.col170;
    p0_a228 := ddx_entry_rec.col171;
    p0_a229 := ddx_entry_rec.col172;
    p0_a230 := ddx_entry_rec.col173;
    p0_a231 := ddx_entry_rec.col174;
    p0_a232 := ddx_entry_rec.col175;
    p0_a233 := ddx_entry_rec.col176;
    p0_a234 := ddx_entry_rec.col177;
    p0_a235 := ddx_entry_rec.col178;
    p0_a236 := ddx_entry_rec.col179;
    p0_a237 := ddx_entry_rec.col180;
    p0_a238 := ddx_entry_rec.col181;
    p0_a239 := ddx_entry_rec.col182;
    p0_a240 := ddx_entry_rec.col183;
    p0_a241 := ddx_entry_rec.col184;
    p0_a242 := ddx_entry_rec.col185;
    p0_a243 := ddx_entry_rec.col186;
    p0_a244 := ddx_entry_rec.col187;
    p0_a245 := ddx_entry_rec.col188;
    p0_a246 := ddx_entry_rec.col189;
    p0_a247 := ddx_entry_rec.col190;
    p0_a248 := ddx_entry_rec.col191;
    p0_a249 := ddx_entry_rec.col192;
    p0_a250 := ddx_entry_rec.col193;
    p0_a251 := ddx_entry_rec.col194;
    p0_a252 := ddx_entry_rec.col195;
    p0_a253 := ddx_entry_rec.col196;
    p0_a254 := ddx_entry_rec.col197;
    p0_a255 := ddx_entry_rec.col198;
    p0_a256 := ddx_entry_rec.col199;
    p0_a257 := ddx_entry_rec.col200;
    p0_a258 := ddx_entry_rec.col201;
    p0_a259 := ddx_entry_rec.col202;
    p0_a260 := ddx_entry_rec.col203;
    p0_a261 := ddx_entry_rec.col204;
    p0_a262 := ddx_entry_rec.col205;
    p0_a263 := ddx_entry_rec.col206;
    p0_a264 := ddx_entry_rec.col207;
    p0_a265 := ddx_entry_rec.col208;
    p0_a266 := ddx_entry_rec.col209;
    p0_a267 := ddx_entry_rec.col210;
    p0_a268 := ddx_entry_rec.col211;
    p0_a269 := ddx_entry_rec.col212;
    p0_a270 := ddx_entry_rec.col213;
    p0_a271 := ddx_entry_rec.col214;
    p0_a272 := ddx_entry_rec.col215;
    p0_a273 := ddx_entry_rec.col216;
    p0_a274 := ddx_entry_rec.col217;
    p0_a275 := ddx_entry_rec.col218;
    p0_a276 := ddx_entry_rec.col219;
    p0_a277 := ddx_entry_rec.col220;
    p0_a278 := ddx_entry_rec.col221;
    p0_a279 := ddx_entry_rec.col222;
    p0_a280 := ddx_entry_rec.col223;
    p0_a281 := ddx_entry_rec.col224;
    p0_a282 := ddx_entry_rec.col225;
    p0_a283 := ddx_entry_rec.col226;
    p0_a284 := ddx_entry_rec.col227;
    p0_a285 := ddx_entry_rec.col228;
    p0_a286 := ddx_entry_rec.col229;
    p0_a287 := ddx_entry_rec.col230;
    p0_a288 := ddx_entry_rec.col231;
    p0_a289 := ddx_entry_rec.col232;
    p0_a290 := ddx_entry_rec.col233;
    p0_a291 := ddx_entry_rec.col234;
    p0_a292 := ddx_entry_rec.col235;
    p0_a293 := ddx_entry_rec.col236;
    p0_a294 := ddx_entry_rec.col237;
    p0_a295 := ddx_entry_rec.col238;
    p0_a296 := ddx_entry_rec.col239;
    p0_a297 := ddx_entry_rec.col240;
    p0_a298 := ddx_entry_rec.col241;
    p0_a299 := ddx_entry_rec.col242;
    p0_a300 := ddx_entry_rec.col243;
    p0_a301 := ddx_entry_rec.col244;
    p0_a302 := ddx_entry_rec.col245;
    p0_a303 := ddx_entry_rec.col246;
    p0_a304 := ddx_entry_rec.col247;
    p0_a305 := ddx_entry_rec.col248;
    p0_a306 := ddx_entry_rec.col249;
    p0_a307 := ddx_entry_rec.col250;
    p0_a308 := ddx_entry_rec.col251;
    p0_a309 := ddx_entry_rec.col252;
    p0_a310 := ddx_entry_rec.col253;
    p0_a311 := ddx_entry_rec.col254;
    p0_a312 := ddx_entry_rec.col255;
    p0_a313 := ddx_entry_rec.col256;
    p0_a314 := ddx_entry_rec.col257;
    p0_a315 := ddx_entry_rec.col258;
    p0_a316 := ddx_entry_rec.col259;
    p0_a317 := ddx_entry_rec.col260;
    p0_a318 := ddx_entry_rec.col261;
    p0_a319 := ddx_entry_rec.col262;
    p0_a320 := ddx_entry_rec.col263;
    p0_a321 := ddx_entry_rec.col264;
    p0_a322 := ddx_entry_rec.col265;
    p0_a323 := ddx_entry_rec.col266;
    p0_a324 := ddx_entry_rec.col267;
    p0_a325 := ddx_entry_rec.col268;
    p0_a326 := ddx_entry_rec.col269;
    p0_a327 := ddx_entry_rec.col270;
    p0_a328 := ddx_entry_rec.col271;
    p0_a329 := ddx_entry_rec.col272;
    p0_a330 := ddx_entry_rec.col273;
    p0_a331 := ddx_entry_rec.col274;
    p0_a332 := ddx_entry_rec.col275;
    p0_a333 := ddx_entry_rec.col276;
    p0_a334 := ddx_entry_rec.col277;
    p0_a335 := ddx_entry_rec.col278;
    p0_a336 := ddx_entry_rec.col279;
    p0_a337 := ddx_entry_rec.col280;
    p0_a338 := ddx_entry_rec.col281;
    p0_a339 := ddx_entry_rec.col282;
    p0_a340 := ddx_entry_rec.col283;
    p0_a341 := ddx_entry_rec.col284;
    p0_a342 := ddx_entry_rec.col285;
    p0_a343 := ddx_entry_rec.col286;
    p0_a344 := ddx_entry_rec.col287;
    p0_a345 := ddx_entry_rec.col288;
    p0_a346 := ddx_entry_rec.col289;
    p0_a347 := ddx_entry_rec.col290;
    p0_a348 := ddx_entry_rec.col291;
    p0_a349 := ddx_entry_rec.col292;
    p0_a350 := ddx_entry_rec.col293;
    p0_a351 := ddx_entry_rec.col294;
    p0_a352 := ddx_entry_rec.col295;
    p0_a353 := ddx_entry_rec.col296;
    p0_a354 := ddx_entry_rec.col297;
    p0_a355 := ddx_entry_rec.col298;
    p0_a356 := ddx_entry_rec.col299;
    p0_a357 := ddx_entry_rec.col300;
    p0_a358 := ddx_entry_rec.curr_cp_country_code;
    p0_a359 := ddx_entry_rec.curr_cp_phone_number;
    p0_a360 := ddx_entry_rec.curr_cp_raw_phone_number;
    p0_a361 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_area_code);
    p0_a362 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_id);
    p0_a363 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_index);
    p0_a364 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_time_zone);
    p0_a365 := rosetta_g_miss_num_map(ddx_entry_rec.curr_cp_time_zone_aux);
    p0_a366 := rosetta_g_miss_num_map(ddx_entry_rec.party_id);
    p0_a367 := rosetta_g_miss_num_map(ddx_entry_rec.parent_party_id);
    p0_a368 := rosetta_g_miss_num_map(ddx_entry_rec.imp_source_line_id);
    p0_a369 := ddx_entry_rec.usage_restriction;
    p0_a370 := ddx_entry_rec.next_call_time;
    p0_a371 := ddx_entry_rec.callback_flag;
    p0_a372 := ddx_entry_rec.do_not_use_flag;
    p0_a373 := ddx_entry_rec.do_not_use_reason;
    p0_a374 := ddx_entry_rec.record_out_flag;
    p0_a375 := ddx_entry_rec.record_release_time;
    p0_a376 := ddx_entry_rec.group_code;
    p0_a377 := ddx_entry_rec.newly_updated_flag;
    p0_a378 := rosetta_g_miss_num_map(ddx_entry_rec.outcome_id);
    p0_a379 := rosetta_g_miss_num_map(ddx_entry_rec.result_id);
    p0_a380 := rosetta_g_miss_num_map(ddx_entry_rec.reason_id);
    p0_a381 := ddx_entry_rec.notes;
    p0_a382 := ddx_entry_rec.vehicle_response_code;
    p0_a383 := ddx_entry_rec.sales_agent_email_address;
    p0_a384 := rosetta_g_miss_num_map(ddx_entry_rec.resource_id);
    p0_a385 := rosetta_g_miss_num_map(ddx_entry_rec.location_id);
    p0_a386 := rosetta_g_miss_num_map(ddx_entry_rec.contact_point_id);
    p0_a387 := ddx_entry_rec.last_contacted_date;
  end;

end ams_list_entries_pvt_w;

/
