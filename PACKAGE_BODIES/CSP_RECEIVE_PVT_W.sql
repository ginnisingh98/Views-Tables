--------------------------------------------------------
--  DDL for Package Body CSP_RECEIVE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RECEIVE_PVT_W" as
  /* $Header: cspwrcvb.pls 115.7 2004/03/17 18:19:07 sunarasi noship $ */
  procedure rosetta_table_copy_in_p5(t out nocopy csp_receive_pvt.rcv_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_100
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_NUMBER_TABLE
    , a31 JTF_VARCHAR2_TABLE_100
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_NUMBER_TABLE
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_VARCHAR2_TABLE_100
    , a49 JTF_VARCHAR2_TABLE_300
    , a50 JTF_NUMBER_TABLE
    , a51 JTF_VARCHAR2_TABLE_100
    , a52 JTF_VARCHAR2_TABLE_100
    , a53 JTF_VARCHAR2_TABLE_100
    , a54 JTF_NUMBER_TABLE
    , a55 JTF_VARCHAR2_TABLE_100
    , a56 JTF_VARCHAR2_TABLE_100
    , a57 JTF_NUMBER_TABLE
    , a58 JTF_VARCHAR2_TABLE_100
    , a59 JTF_DATE_TABLE
    , a60 JTF_DATE_TABLE
    , a61 JTF_NUMBER_TABLE
    , a62 JTF_VARCHAR2_TABLE_100
    , a63 JTF_VARCHAR2_TABLE_100
    , a64 JTF_VARCHAR2_TABLE_100
    , a65 JTF_VARCHAR2_TABLE_100
    , a66 JTF_VARCHAR2_TABLE_100
    , a67 JTF_VARCHAR2_TABLE_100
    , a68 JTF_VARCHAR2_TABLE_100
    , a69 JTF_NUMBER_TABLE
    , a70 JTF_VARCHAR2_TABLE_100
    , a71 JTF_VARCHAR2_TABLE_100
    , a72 JTF_DATE_TABLE
    , a73 JTF_NUMBER_TABLE
    , a74 JTF_VARCHAR2_TABLE_300
    , a75 JTF_VARCHAR2_TABLE_100
    , a76 JTF_NUMBER_TABLE
    , a77 JTF_NUMBER_TABLE
    , a78 JTF_VARCHAR2_TABLE_100
    , a79 JTF_VARCHAR2_TABLE_100
    , a80 JTF_VARCHAR2_TABLE_300
    , a81 JTF_VARCHAR2_TABLE_300
    , a82 JTF_VARCHAR2_TABLE_300
    , a83 JTF_VARCHAR2_TABLE_300
    , a84 JTF_VARCHAR2_TABLE_300
    , a85 JTF_VARCHAR2_TABLE_300
    , a86 JTF_VARCHAR2_TABLE_300
    , a87 JTF_VARCHAR2_TABLE_300
    , a88 JTF_VARCHAR2_TABLE_300
    , a89 JTF_VARCHAR2_TABLE_300
    , a90 JTF_VARCHAR2_TABLE_300
    , a91 JTF_VARCHAR2_TABLE_300
    , a92 JTF_VARCHAR2_TABLE_300
    , a93 JTF_VARCHAR2_TABLE_300
    , a94 JTF_VARCHAR2_TABLE_300
    , a95 JTF_VARCHAR2_TABLE_100
    , a96 JTF_VARCHAR2_TABLE_100
    , a97 JTF_VARCHAR2_TABLE_100
    , a98 JTF_DATE_TABLE
    , a99 JTF_VARCHAR2_TABLE_100
    , a100 JTF_VARCHAR2_TABLE_100
    , a101 JTF_VARCHAR2_TABLE_100
    , a102 JTF_VARCHAR2_TABLE_100
    , a103 JTF_VARCHAR2_TABLE_100
    , a104 JTF_VARCHAR2_TABLE_100
    , a105 JTF_VARCHAR2_TABLE_100
    , a106 JTF_VARCHAR2_TABLE_100
    , a107 JTF_VARCHAR2_TABLE_100
    , a108 JTF_VARCHAR2_TABLE_100
    , a109 JTF_NUMBER_TABLE
    , a110 JTF_NUMBER_TABLE
    , a111 JTF_NUMBER_TABLE
    , a112 JTF_NUMBER_TABLE
    , a113 JTF_NUMBER_TABLE
    , a114 JTF_NUMBER_TABLE
    , a115 JTF_VARCHAR2_TABLE_100
    , a116 JTF_VARCHAR2_TABLE_300
    , a117 JTF_NUMBER_TABLE
    , a118 JTF_NUMBER_TABLE
    , a119 JTF_NUMBER_TABLE
    , a120 JTF_NUMBER_TABLE
    , a121 JTF_NUMBER_TABLE
    , a122 JTF_NUMBER_TABLE
    , a123 JTF_NUMBER_TABLE
    , a124 JTF_NUMBER_TABLE
    , a125 JTF_VARCHAR2_TABLE_100
    , a126 JTF_VARCHAR2_TABLE_100
    , a127 JTF_NUMBER_TABLE
    , a128 JTF_DATE_TABLE
    , a129 JTF_NUMBER_TABLE
    , a130 JTF_NUMBER_TABLE
    , a131 JTF_NUMBER_TABLE
    , a132 JTF_NUMBER_TABLE
    , a133 JTF_VARCHAR2_TABLE_100
    , a134 JTF_NUMBER_TABLE
    , a135 JTF_VARCHAR2_TABLE_100
    , a136 JTF_NUMBER_TABLE
    , a137 JTF_NUMBER_TABLE
    , a138 JTF_NUMBER_TABLE
    , a139 JTF_DATE_TABLE
    , a140 JTF_NUMBER_TABLE
    , a141 JTF_NUMBER_TABLE
    , a142 JTF_VARCHAR2_TABLE_100
    , a143 JTF_VARCHAR2_TABLE_100
    , a144 JTF_VARCHAR2_TABLE_100
    , a145 JTF_VARCHAR2_TABLE_300
    , a146 JTF_VARCHAR2_TABLE_300
    , a147 JTF_VARCHAR2_TABLE_200
    , a148 JTF_DATE_TABLE
    , a149 JTF_VARCHAR2_TABLE_200
    , a150 JTF_VARCHAR2_TABLE_200
    , a151 JTF_DATE_TABLE
    , a152 JTF_DATE_TABLE
    , a153 JTF_DATE_TABLE
    , a154 JTF_NUMBER_TABLE
    , a155 JTF_NUMBER_TABLE
    , a156 JTF_VARCHAR2_TABLE_200
    , a157 JTF_NUMBER_TABLE
    , a158 JTF_VARCHAR2_TABLE_100
    , a159 JTF_VARCHAR2_TABLE_200
    , a160 JTF_DATE_TABLE
    , a161 JTF_NUMBER_TABLE
    , a162 JTF_VARCHAR2_TABLE_100
    , a163 JTF_NUMBER_TABLE
    , a164 JTF_NUMBER_TABLE
    , a165 JTF_VARCHAR2_TABLE_100
    , a166 JTF_NUMBER_TABLE
    , a167 JTF_VARCHAR2_TABLE_100
    , a168 JTF_VARCHAR2_TABLE_200
    , a169 JTF_VARCHAR2_TABLE_100
    , a170 JTF_VARCHAR2_TABLE_100
    , a171 JTF_VARCHAR2_TABLE_100
    , a172 JTF_VARCHAR2_TABLE_100
    , a173 JTF_VARCHAR2_TABLE_100
    , a174 JTF_VARCHAR2_TABLE_100
    , a175 JTF_VARCHAR2_TABLE_100
    , a176 JTF_NUMBER_TABLE
    , a177 JTF_NUMBER_TABLE
    , a178 JTF_NUMBER_TABLE
    , a179 JTF_NUMBER_TABLE
    , a180 JTF_NUMBER_TABLE
    , a181 JTF_NUMBER_TABLE
    , a182 JTF_NUMBER_TABLE
    , a183 JTF_NUMBER_TABLE
    , a184 JTF_NUMBER_TABLE
    , a185 JTF_NUMBER_TABLE
    , a186 JTF_NUMBER_TABLE
    , a187 JTF_NUMBER_TABLE
    , a188 JTF_NUMBER_TABLE
    , a189 JTF_VARCHAR2_TABLE_100
    , a190 JTF_VARCHAR2_TABLE_100
    , a191 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).interface_transaction_id := a0(indx);
          t(ddindx).transaction_interface_id := a1(indx);
          t(ddindx).header_interface_id := a2(indx);
          t(ddindx).group_id := a3(indx);
          t(ddindx).inv_loc_assignment_id := a4(indx);
          t(ddindx).source_type_code := a5(indx);
          t(ddindx).receipt_source_code := a6(indx);
          t(ddindx).order_type_code := a7(indx);
          t(ddindx).order_type := a8(indx);
          t(ddindx).po_header_id := a9(indx);
          t(ddindx).po_number := a10(indx);
          t(ddindx).po_line_id := a11(indx);
          t(ddindx).po_line_number := a12(indx);
          t(ddindx).po_line_location_id := a13(indx);
          t(ddindx).po_shipment_number := a14(indx);
          t(ddindx).po_release_id := a15(indx);
          t(ddindx).po_release_number := a16(indx);
          t(ddindx).req_header_id := a17(indx);
          t(ddindx).req_number := a18(indx);
          t(ddindx).req_line_id := a19(indx);
          t(ddindx).req_line := a20(indx);
          t(ddindx).req_distribution_id := a21(indx);
          t(ddindx).rcv_shipment_header_id := a22(indx);
          t(ddindx).rcv_shipment_number := a23(indx);
          t(ddindx).rcv_shipment_line_id := a24(indx);
          t(ddindx).rcv_line_number := a25(indx);
          t(ddindx).from_organization_id := a26(indx);
          t(ddindx).to_organization_id := a27(indx);
          t(ddindx).vendor_id := a28(indx);
          t(ddindx).source := a29(indx);
          t(ddindx).vendor_site_id := a30(indx);
          t(ddindx).outside_operation_flag := a31(indx);
          t(ddindx).receipt_exception := a32(indx);
          t(ddindx).item_id := a33(indx);
          t(ddindx).uom_code := a34(indx);
          t(ddindx).primary_uom := a35(indx);
          t(ddindx).primary_uom_class := a36(indx);
          t(ddindx).item_allowed_units_lookup_code := a37(indx);
          t(ddindx).item_locator_control := a38(indx);
          t(ddindx).restrict_locators_code := a39(indx);
          t(ddindx).restrict_subinventories_code := a40(indx);
          t(ddindx).shelf_life_code := a41(indx);
          t(ddindx).shelf_life_days := a42(indx);
          t(ddindx).serial_number_control_code := a43(indx);
          t(ddindx).lot_control_code := a44(indx);
          t(ddindx).item_rev_control_flag_to := a45(indx);
          t(ddindx).item_rev_control_flag_from := a46(indx);
          t(ddindx).item_number := a47(indx);
          t(ddindx).item_revision := a48(indx);
          t(ddindx).item_description := a49(indx);
          t(ddindx).item_category_id := a50(indx);
          t(ddindx).hazard_class := a51(indx);
          t(ddindx).un_number := a52(indx);
          t(ddindx).vendor_item_number := a53(indx);
          t(ddindx).ship_to_location_id := a54(indx);
          t(ddindx).ship_to_location := a55(indx);
          t(ddindx).packing_slip := a56(indx);
          t(ddindx).routing_id := a57(indx);
          t(ddindx).routing_name := a58(indx);
          t(ddindx).need_by_date := a59(indx);
          t(ddindx).expected_receipt_date := a60(indx);
          t(ddindx).ordered_qty := a61(indx);
          t(ddindx).ordered_uom := a62(indx);
          t(ddindx).ussgl_transaction_code := a63(indx);
          t(ddindx).government_context := a64(indx);
          t(ddindx).inspection_required_flag := a65(indx);
          t(ddindx).receipt_required_flag := a66(indx);
          t(ddindx).enforce_ship_to_location_code := a67(indx);
          t(ddindx).substitute_receipt := a68(indx);
          t(ddindx).unit_price := a69(indx);
          t(ddindx).currency_code := a70(indx);
          t(ddindx).currency_conversion_type := a71(indx);
          t(ddindx).currency_conversion_date := a72(indx);
          t(ddindx).currency_conversion_rate := a73(indx);
          t(ddindx).note_to_receiver := a74(indx);
          t(ddindx).destination_type_code := a75(indx);
          t(ddindx).deliver_to_person_id := a76(indx);
          t(ddindx).deliver_to_location_id := a77(indx);
          t(ddindx).destination_subinventory := a78(indx);
          t(ddindx).attribute_category := a79(indx);
          t(ddindx).attribute1 := a80(indx);
          t(ddindx).attribute2 := a81(indx);
          t(ddindx).attribute3 := a82(indx);
          t(ddindx).attribute4 := a83(indx);
          t(ddindx).attribute5 := a84(indx);
          t(ddindx).attribute6 := a85(indx);
          t(ddindx).attribute7 := a86(indx);
          t(ddindx).attribute8 := a87(indx);
          t(ddindx).attribute9 := a88(indx);
          t(ddindx).attribute10 := a89(indx);
          t(ddindx).attribute11 := a90(indx);
          t(ddindx).attribute12 := a91(indx);
          t(ddindx).attribute13 := a92(indx);
          t(ddindx).attribute14 := a93(indx);
          t(ddindx).attribute15 := a94(indx);
          t(ddindx).closed_code := a95(indx);
          t(ddindx).asn_type := a96(indx);
          t(ddindx).bill_of_lading := a97(indx);
          t(ddindx).shipped_date := a98(indx);
          t(ddindx).freight_carrier_code := a99(indx);
          t(ddindx).waybill_airbill_num := a100(indx);
          t(ddindx).freight_bill_num := a101(indx);
          t(ddindx).vendor_lot_num := a102(indx);
          t(ddindx).container_num := a103(indx);
          t(ddindx).truck_num := a104(indx);
          t(ddindx).bar_code_label := a105(indx);
          t(ddindx).rate_type_display := a106(indx);
          t(ddindx).match_option := a107(indx);
          t(ddindx).country_of_origin_code := a108(indx);
          t(ddindx).oe_order_header_id := a109(indx);
          t(ddindx).oe_order_num := a110(indx);
          t(ddindx).oe_order_line_id := a111(indx);
          t(ddindx).oe_order_line_num := a112(indx);
          t(ddindx).customer_id := a113(indx);
          t(ddindx).customer_site_id := a114(indx);
          t(ddindx).customer_item_num := a115(indx);
          t(ddindx).pll_note_to_receiver := a116(indx);
          t(ddindx).po_distribution_id := a117(indx);
          t(ddindx).qty_ordered := a118(indx);
          t(ddindx).wip_entity_id := a119(indx);
          t(ddindx).wip_operation_seq_num := a120(indx);
          t(ddindx).wip_resource_seq_num := a121(indx);
          t(ddindx).wip_repetitive_schedule_id := a122(indx);
          t(ddindx).wip_line_id := a123(indx);
          t(ddindx).bom_resource_id := a124(indx);
          t(ddindx).destination_type := a125(indx);
          t(ddindx).location := a126(indx);
          t(ddindx).currency_conversion_rate_pod := a127(indx);
          t(ddindx).currency_conversion_date_pod := a128(indx);
          t(ddindx).project_id := a129(indx);
          t(ddindx).task_id := a130(indx);
          t(ddindx).locator_id := a131(indx);
          t(ddindx).employee_id := a132(indx);
          t(ddindx).lot_number := a133(indx);
          t(ddindx).transaction_quantity := a134(indx);
          t(ddindx).transaction_uom := a135(indx);
          t(ddindx).primary_quantity := a136(indx);
          t(ddindx).lot_quantity := a137(indx);
          t(ddindx).lot_primary_quantity := a138(indx);
          t(ddindx).expiration_date := a139(indx);
          t(ddindx).status_id := a140(indx);
          t(ddindx).product_transaction_id := a141(indx);
          t(ddindx).product_code := a142(indx);
          t(ddindx).att_exist := a143(indx);
          t(ddindx).update_mln := a144(indx);
          t(ddindx).description := a145(indx);
          t(ddindx).vendor_name := a146(indx);
          t(ddindx).supplier_lot_number := a147(indx);
          t(ddindx).origination_date := a148(indx);
          t(ddindx).date_code := a149(indx);
          t(ddindx).grade_code := a150(indx);
          t(ddindx).change_date := a151(indx);
          t(ddindx).maturity_date := a152(indx);
          t(ddindx).retest_date := a153(indx);
          t(ddindx).age := a154(indx);
          t(ddindx).item_size := a155(indx);
          t(ddindx).color := a156(indx);
          t(ddindx).volume := a157(indx);
          t(ddindx).volume_uom := a158(indx);
          t(ddindx).place_of_origin := a159(indx);
          t(ddindx).best_by_date := a160(indx);
          t(ddindx).length := a161(indx);
          t(ddindx).length_uom := a162(indx);
          t(ddindx).recycled_content := a163(indx);
          t(ddindx).thickness := a164(indx);
          t(ddindx).thickness_uom := a165(indx);
          t(ddindx).width := a166(indx);
          t(ddindx).width_uom := a167(indx);
          t(ddindx).curl_wrinkle_fold := a168(indx);
          t(ddindx).territory_code := a169(indx);
          t(ddindx).fm_serial_number := a170(indx);
          t(ddindx).to_serial_number := a171(indx);
          t(ddindx).update_msn := a172(indx);
          t(ddindx).vendor_serial_number := a173(indx);
          t(ddindx).vendor_lot_number := a174(indx);
          t(ddindx).parent_serial_number := a175(indx);
          t(ddindx).time_since_new := a176(indx);
          t(ddindx).cycles_since_new := a177(indx);
          t(ddindx).time_since_overhaul := a178(indx);
          t(ddindx).cycles_since_overhaul := a179(indx);
          t(ddindx).time_since_repair := a180(indx);
          t(ddindx).cycles_since_repair := a181(indx);
          t(ddindx).time_since_visit := a182(indx);
          t(ddindx).cycles_since_visit := a183(indx);
          t(ddindx).time_since_mark := a184(indx);
          t(ddindx).cycles_since_mark := a185(indx);
          t(ddindx).number_of_repairs := a186(indx);
          t(ddindx).set_of_books_id_sob := a187(indx);
          t(ddindx).reason_id := a188(indx);
          t(ddindx).currency_code_sob := a189(indx);
          t(ddindx).department_code := a190(indx);
          t(ddindx).comments := a191(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t csp_receive_pvt.rcv_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_100
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_NUMBER_TABLE
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_NUMBER_TABLE
    , a31 out nocopy JTF_VARCHAR2_TABLE_100
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_NUMBER_TABLE
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_VARCHAR2_TABLE_100
    , a40 out nocopy JTF_VARCHAR2_TABLE_100
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_VARCHAR2_TABLE_100
    , a49 out nocopy JTF_VARCHAR2_TABLE_300
    , a50 out nocopy JTF_NUMBER_TABLE
    , a51 out nocopy JTF_VARCHAR2_TABLE_100
    , a52 out nocopy JTF_VARCHAR2_TABLE_100
    , a53 out nocopy JTF_VARCHAR2_TABLE_100
    , a54 out nocopy JTF_NUMBER_TABLE
    , a55 out nocopy JTF_VARCHAR2_TABLE_100
    , a56 out nocopy JTF_VARCHAR2_TABLE_100
    , a57 out nocopy JTF_NUMBER_TABLE
    , a58 out nocopy JTF_VARCHAR2_TABLE_100
    , a59 out nocopy JTF_DATE_TABLE
    , a60 out nocopy JTF_DATE_TABLE
    , a61 out nocopy JTF_NUMBER_TABLE
    , a62 out nocopy JTF_VARCHAR2_TABLE_100
    , a63 out nocopy JTF_VARCHAR2_TABLE_100
    , a64 out nocopy JTF_VARCHAR2_TABLE_100
    , a65 out nocopy JTF_VARCHAR2_TABLE_100
    , a66 out nocopy JTF_VARCHAR2_TABLE_100
    , a67 out nocopy JTF_VARCHAR2_TABLE_100
    , a68 out nocopy JTF_VARCHAR2_TABLE_100
    , a69 out nocopy JTF_NUMBER_TABLE
    , a70 out nocopy JTF_VARCHAR2_TABLE_100
    , a71 out nocopy JTF_VARCHAR2_TABLE_100
    , a72 out nocopy JTF_DATE_TABLE
    , a73 out nocopy JTF_NUMBER_TABLE
    , a74 out nocopy JTF_VARCHAR2_TABLE_300
    , a75 out nocopy JTF_VARCHAR2_TABLE_100
    , a76 out nocopy JTF_NUMBER_TABLE
    , a77 out nocopy JTF_NUMBER_TABLE
    , a78 out nocopy JTF_VARCHAR2_TABLE_100
    , a79 out nocopy JTF_VARCHAR2_TABLE_100
    , a80 out nocopy JTF_VARCHAR2_TABLE_300
    , a81 out nocopy JTF_VARCHAR2_TABLE_300
    , a82 out nocopy JTF_VARCHAR2_TABLE_300
    , a83 out nocopy JTF_VARCHAR2_TABLE_300
    , a84 out nocopy JTF_VARCHAR2_TABLE_300
    , a85 out nocopy JTF_VARCHAR2_TABLE_300
    , a86 out nocopy JTF_VARCHAR2_TABLE_300
    , a87 out nocopy JTF_VARCHAR2_TABLE_300
    , a88 out nocopy JTF_VARCHAR2_TABLE_300
    , a89 out nocopy JTF_VARCHAR2_TABLE_300
    , a90 out nocopy JTF_VARCHAR2_TABLE_300
    , a91 out nocopy JTF_VARCHAR2_TABLE_300
    , a92 out nocopy JTF_VARCHAR2_TABLE_300
    , a93 out nocopy JTF_VARCHAR2_TABLE_300
    , a94 out nocopy JTF_VARCHAR2_TABLE_300
    , a95 out nocopy JTF_VARCHAR2_TABLE_100
    , a96 out nocopy JTF_VARCHAR2_TABLE_100
    , a97 out nocopy JTF_VARCHAR2_TABLE_100
    , a98 out nocopy JTF_DATE_TABLE
    , a99 out nocopy JTF_VARCHAR2_TABLE_100
    , a100 out nocopy JTF_VARCHAR2_TABLE_100
    , a101 out nocopy JTF_VARCHAR2_TABLE_100
    , a102 out nocopy JTF_VARCHAR2_TABLE_100
    , a103 out nocopy JTF_VARCHAR2_TABLE_100
    , a104 out nocopy JTF_VARCHAR2_TABLE_100
    , a105 out nocopy JTF_VARCHAR2_TABLE_100
    , a106 out nocopy JTF_VARCHAR2_TABLE_100
    , a107 out nocopy JTF_VARCHAR2_TABLE_100
    , a108 out nocopy JTF_VARCHAR2_TABLE_100
    , a109 out nocopy JTF_NUMBER_TABLE
    , a110 out nocopy JTF_NUMBER_TABLE
    , a111 out nocopy JTF_NUMBER_TABLE
    , a112 out nocopy JTF_NUMBER_TABLE
    , a113 out nocopy JTF_NUMBER_TABLE
    , a114 out nocopy JTF_NUMBER_TABLE
    , a115 out nocopy JTF_VARCHAR2_TABLE_100
    , a116 out nocopy JTF_VARCHAR2_TABLE_300
    , a117 out nocopy JTF_NUMBER_TABLE
    , a118 out nocopy JTF_NUMBER_TABLE
    , a119 out nocopy JTF_NUMBER_TABLE
    , a120 out nocopy JTF_NUMBER_TABLE
    , a121 out nocopy JTF_NUMBER_TABLE
    , a122 out nocopy JTF_NUMBER_TABLE
    , a123 out nocopy JTF_NUMBER_TABLE
    , a124 out nocopy JTF_NUMBER_TABLE
    , a125 out nocopy JTF_VARCHAR2_TABLE_100
    , a126 out nocopy JTF_VARCHAR2_TABLE_100
    , a127 out nocopy JTF_NUMBER_TABLE
    , a128 out nocopy JTF_DATE_TABLE
    , a129 out nocopy JTF_NUMBER_TABLE
    , a130 out nocopy JTF_NUMBER_TABLE
    , a131 out nocopy JTF_NUMBER_TABLE
    , a132 out nocopy JTF_NUMBER_TABLE
    , a133 out nocopy JTF_VARCHAR2_TABLE_100
    , a134 out nocopy JTF_NUMBER_TABLE
    , a135 out nocopy JTF_VARCHAR2_TABLE_100
    , a136 out nocopy JTF_NUMBER_TABLE
    , a137 out nocopy JTF_NUMBER_TABLE
    , a138 out nocopy JTF_NUMBER_TABLE
    , a139 out nocopy JTF_DATE_TABLE
    , a140 out nocopy JTF_NUMBER_TABLE
    , a141 out nocopy JTF_NUMBER_TABLE
    , a142 out nocopy JTF_VARCHAR2_TABLE_100
    , a143 out nocopy JTF_VARCHAR2_TABLE_100
    , a144 out nocopy JTF_VARCHAR2_TABLE_100
    , a145 out nocopy JTF_VARCHAR2_TABLE_300
    , a146 out nocopy JTF_VARCHAR2_TABLE_300
    , a147 out nocopy JTF_VARCHAR2_TABLE_200
    , a148 out nocopy JTF_DATE_TABLE
    , a149 out nocopy JTF_VARCHAR2_TABLE_200
    , a150 out nocopy JTF_VARCHAR2_TABLE_200
    , a151 out nocopy JTF_DATE_TABLE
    , a152 out nocopy JTF_DATE_TABLE
    , a153 out nocopy JTF_DATE_TABLE
    , a154 out nocopy JTF_NUMBER_TABLE
    , a155 out nocopy JTF_NUMBER_TABLE
    , a156 out nocopy JTF_VARCHAR2_TABLE_200
    , a157 out nocopy JTF_NUMBER_TABLE
    , a158 out nocopy JTF_VARCHAR2_TABLE_100
    , a159 out nocopy JTF_VARCHAR2_TABLE_200
    , a160 out nocopy JTF_DATE_TABLE
    , a161 out nocopy JTF_NUMBER_TABLE
    , a162 out nocopy JTF_VARCHAR2_TABLE_100
    , a163 out nocopy JTF_NUMBER_TABLE
    , a164 out nocopy JTF_NUMBER_TABLE
    , a165 out nocopy JTF_VARCHAR2_TABLE_100
    , a166 out nocopy JTF_NUMBER_TABLE
    , a167 out nocopy JTF_VARCHAR2_TABLE_100
    , a168 out nocopy JTF_VARCHAR2_TABLE_200
    , a169 out nocopy JTF_VARCHAR2_TABLE_100
    , a170 out nocopy JTF_VARCHAR2_TABLE_100
    , a171 out nocopy JTF_VARCHAR2_TABLE_100
    , a172 out nocopy JTF_VARCHAR2_TABLE_100
    , a173 out nocopy JTF_VARCHAR2_TABLE_100
    , a174 out nocopy JTF_VARCHAR2_TABLE_100
    , a175 out nocopy JTF_VARCHAR2_TABLE_100
    , a176 out nocopy JTF_NUMBER_TABLE
    , a177 out nocopy JTF_NUMBER_TABLE
    , a178 out nocopy JTF_NUMBER_TABLE
    , a179 out nocopy JTF_NUMBER_TABLE
    , a180 out nocopy JTF_NUMBER_TABLE
    , a181 out nocopy JTF_NUMBER_TABLE
    , a182 out nocopy JTF_NUMBER_TABLE
    , a183 out nocopy JTF_NUMBER_TABLE
    , a184 out nocopy JTF_NUMBER_TABLE
    , a185 out nocopy JTF_NUMBER_TABLE
    , a186 out nocopy JTF_NUMBER_TABLE
    , a187 out nocopy JTF_NUMBER_TABLE
    , a188 out nocopy JTF_NUMBER_TABLE
    , a189 out nocopy JTF_VARCHAR2_TABLE_100
    , a190 out nocopy JTF_VARCHAR2_TABLE_100
    , a191 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_100();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_NUMBER_TABLE();
    a31 := JTF_VARCHAR2_TABLE_100();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_NUMBER_TABLE();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_VARCHAR2_TABLE_100();
    a49 := JTF_VARCHAR2_TABLE_300();
    a50 := JTF_NUMBER_TABLE();
    a51 := JTF_VARCHAR2_TABLE_100();
    a52 := JTF_VARCHAR2_TABLE_100();
    a53 := JTF_VARCHAR2_TABLE_100();
    a54 := JTF_NUMBER_TABLE();
    a55 := JTF_VARCHAR2_TABLE_100();
    a56 := JTF_VARCHAR2_TABLE_100();
    a57 := JTF_NUMBER_TABLE();
    a58 := JTF_VARCHAR2_TABLE_100();
    a59 := JTF_DATE_TABLE();
    a60 := JTF_DATE_TABLE();
    a61 := JTF_NUMBER_TABLE();
    a62 := JTF_VARCHAR2_TABLE_100();
    a63 := JTF_VARCHAR2_TABLE_100();
    a64 := JTF_VARCHAR2_TABLE_100();
    a65 := JTF_VARCHAR2_TABLE_100();
    a66 := JTF_VARCHAR2_TABLE_100();
    a67 := JTF_VARCHAR2_TABLE_100();
    a68 := JTF_VARCHAR2_TABLE_100();
    a69 := JTF_NUMBER_TABLE();
    a70 := JTF_VARCHAR2_TABLE_100();
    a71 := JTF_VARCHAR2_TABLE_100();
    a72 := JTF_DATE_TABLE();
    a73 := JTF_NUMBER_TABLE();
    a74 := JTF_VARCHAR2_TABLE_300();
    a75 := JTF_VARCHAR2_TABLE_100();
    a76 := JTF_NUMBER_TABLE();
    a77 := JTF_NUMBER_TABLE();
    a78 := JTF_VARCHAR2_TABLE_100();
    a79 := JTF_VARCHAR2_TABLE_100();
    a80 := JTF_VARCHAR2_TABLE_300();
    a81 := JTF_VARCHAR2_TABLE_300();
    a82 := JTF_VARCHAR2_TABLE_300();
    a83 := JTF_VARCHAR2_TABLE_300();
    a84 := JTF_VARCHAR2_TABLE_300();
    a85 := JTF_VARCHAR2_TABLE_300();
    a86 := JTF_VARCHAR2_TABLE_300();
    a87 := JTF_VARCHAR2_TABLE_300();
    a88 := JTF_VARCHAR2_TABLE_300();
    a89 := JTF_VARCHAR2_TABLE_300();
    a90 := JTF_VARCHAR2_TABLE_300();
    a91 := JTF_VARCHAR2_TABLE_300();
    a92 := JTF_VARCHAR2_TABLE_300();
    a93 := JTF_VARCHAR2_TABLE_300();
    a94 := JTF_VARCHAR2_TABLE_300();
    a95 := JTF_VARCHAR2_TABLE_100();
    a96 := JTF_VARCHAR2_TABLE_100();
    a97 := JTF_VARCHAR2_TABLE_100();
    a98 := JTF_DATE_TABLE();
    a99 := JTF_VARCHAR2_TABLE_100();
    a100 := JTF_VARCHAR2_TABLE_100();
    a101 := JTF_VARCHAR2_TABLE_100();
    a102 := JTF_VARCHAR2_TABLE_100();
    a103 := JTF_VARCHAR2_TABLE_100();
    a104 := JTF_VARCHAR2_TABLE_100();
    a105 := JTF_VARCHAR2_TABLE_100();
    a106 := JTF_VARCHAR2_TABLE_100();
    a107 := JTF_VARCHAR2_TABLE_100();
    a108 := JTF_VARCHAR2_TABLE_100();
    a109 := JTF_NUMBER_TABLE();
    a110 := JTF_NUMBER_TABLE();
    a111 := JTF_NUMBER_TABLE();
    a112 := JTF_NUMBER_TABLE();
    a113 := JTF_NUMBER_TABLE();
    a114 := JTF_NUMBER_TABLE();
    a115 := JTF_VARCHAR2_TABLE_100();
    a116 := JTF_VARCHAR2_TABLE_300();
    a117 := JTF_NUMBER_TABLE();
    a118 := JTF_NUMBER_TABLE();
    a119 := JTF_NUMBER_TABLE();
    a120 := JTF_NUMBER_TABLE();
    a121 := JTF_NUMBER_TABLE();
    a122 := JTF_NUMBER_TABLE();
    a123 := JTF_NUMBER_TABLE();
    a124 := JTF_NUMBER_TABLE();
    a125 := JTF_VARCHAR2_TABLE_100();
    a126 := JTF_VARCHAR2_TABLE_100();
    a127 := JTF_NUMBER_TABLE();
    a128 := JTF_DATE_TABLE();
    a129 := JTF_NUMBER_TABLE();
    a130 := JTF_NUMBER_TABLE();
    a131 := JTF_NUMBER_TABLE();
    a132 := JTF_NUMBER_TABLE();
    a133 := JTF_VARCHAR2_TABLE_100();
    a134 := JTF_NUMBER_TABLE();
    a135 := JTF_VARCHAR2_TABLE_100();
    a136 := JTF_NUMBER_TABLE();
    a137 := JTF_NUMBER_TABLE();
    a138 := JTF_NUMBER_TABLE();
    a139 := JTF_DATE_TABLE();
    a140 := JTF_NUMBER_TABLE();
    a141 := JTF_NUMBER_TABLE();
    a142 := JTF_VARCHAR2_TABLE_100();
    a143 := JTF_VARCHAR2_TABLE_100();
    a144 := JTF_VARCHAR2_TABLE_100();
    a145 := JTF_VARCHAR2_TABLE_300();
    a146 := JTF_VARCHAR2_TABLE_300();
    a147 := JTF_VARCHAR2_TABLE_200();
    a148 := JTF_DATE_TABLE();
    a149 := JTF_VARCHAR2_TABLE_200();
    a150 := JTF_VARCHAR2_TABLE_200();
    a151 := JTF_DATE_TABLE();
    a152 := JTF_DATE_TABLE();
    a153 := JTF_DATE_TABLE();
    a154 := JTF_NUMBER_TABLE();
    a155 := JTF_NUMBER_TABLE();
    a156 := JTF_VARCHAR2_TABLE_200();
    a157 := JTF_NUMBER_TABLE();
    a158 := JTF_VARCHAR2_TABLE_100();
    a159 := JTF_VARCHAR2_TABLE_200();
    a160 := JTF_DATE_TABLE();
    a161 := JTF_NUMBER_TABLE();
    a162 := JTF_VARCHAR2_TABLE_100();
    a163 := JTF_NUMBER_TABLE();
    a164 := JTF_NUMBER_TABLE();
    a165 := JTF_VARCHAR2_TABLE_100();
    a166 := JTF_NUMBER_TABLE();
    a167 := JTF_VARCHAR2_TABLE_100();
    a168 := JTF_VARCHAR2_TABLE_200();
    a169 := JTF_VARCHAR2_TABLE_100();
    a170 := JTF_VARCHAR2_TABLE_100();
    a171 := JTF_VARCHAR2_TABLE_100();
    a172 := JTF_VARCHAR2_TABLE_100();
    a173 := JTF_VARCHAR2_TABLE_100();
    a174 := JTF_VARCHAR2_TABLE_100();
    a175 := JTF_VARCHAR2_TABLE_100();
    a176 := JTF_NUMBER_TABLE();
    a177 := JTF_NUMBER_TABLE();
    a178 := JTF_NUMBER_TABLE();
    a179 := JTF_NUMBER_TABLE();
    a180 := JTF_NUMBER_TABLE();
    a181 := JTF_NUMBER_TABLE();
    a182 := JTF_NUMBER_TABLE();
    a183 := JTF_NUMBER_TABLE();
    a184 := JTF_NUMBER_TABLE();
    a185 := JTF_NUMBER_TABLE();
    a186 := JTF_NUMBER_TABLE();
    a187 := JTF_NUMBER_TABLE();
    a188 := JTF_NUMBER_TABLE();
    a189 := JTF_VARCHAR2_TABLE_100();
    a190 := JTF_VARCHAR2_TABLE_100();
    a191 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_100();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_NUMBER_TABLE();
      a31 := JTF_VARCHAR2_TABLE_100();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_NUMBER_TABLE();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_VARCHAR2_TABLE_100();
      a49 := JTF_VARCHAR2_TABLE_300();
      a50 := JTF_NUMBER_TABLE();
      a51 := JTF_VARCHAR2_TABLE_100();
      a52 := JTF_VARCHAR2_TABLE_100();
      a53 := JTF_VARCHAR2_TABLE_100();
      a54 := JTF_NUMBER_TABLE();
      a55 := JTF_VARCHAR2_TABLE_100();
      a56 := JTF_VARCHAR2_TABLE_100();
      a57 := JTF_NUMBER_TABLE();
      a58 := JTF_VARCHAR2_TABLE_100();
      a59 := JTF_DATE_TABLE();
      a60 := JTF_DATE_TABLE();
      a61 := JTF_NUMBER_TABLE();
      a62 := JTF_VARCHAR2_TABLE_100();
      a63 := JTF_VARCHAR2_TABLE_100();
      a64 := JTF_VARCHAR2_TABLE_100();
      a65 := JTF_VARCHAR2_TABLE_100();
      a66 := JTF_VARCHAR2_TABLE_100();
      a67 := JTF_VARCHAR2_TABLE_100();
      a68 := JTF_VARCHAR2_TABLE_100();
      a69 := JTF_NUMBER_TABLE();
      a70 := JTF_VARCHAR2_TABLE_100();
      a71 := JTF_VARCHAR2_TABLE_100();
      a72 := JTF_DATE_TABLE();
      a73 := JTF_NUMBER_TABLE();
      a74 := JTF_VARCHAR2_TABLE_300();
      a75 := JTF_VARCHAR2_TABLE_100();
      a76 := JTF_NUMBER_TABLE();
      a77 := JTF_NUMBER_TABLE();
      a78 := JTF_VARCHAR2_TABLE_100();
      a79 := JTF_VARCHAR2_TABLE_100();
      a80 := JTF_VARCHAR2_TABLE_300();
      a81 := JTF_VARCHAR2_TABLE_300();
      a82 := JTF_VARCHAR2_TABLE_300();
      a83 := JTF_VARCHAR2_TABLE_300();
      a84 := JTF_VARCHAR2_TABLE_300();
      a85 := JTF_VARCHAR2_TABLE_300();
      a86 := JTF_VARCHAR2_TABLE_300();
      a87 := JTF_VARCHAR2_TABLE_300();
      a88 := JTF_VARCHAR2_TABLE_300();
      a89 := JTF_VARCHAR2_TABLE_300();
      a90 := JTF_VARCHAR2_TABLE_300();
      a91 := JTF_VARCHAR2_TABLE_300();
      a92 := JTF_VARCHAR2_TABLE_300();
      a93 := JTF_VARCHAR2_TABLE_300();
      a94 := JTF_VARCHAR2_TABLE_300();
      a95 := JTF_VARCHAR2_TABLE_100();
      a96 := JTF_VARCHAR2_TABLE_100();
      a97 := JTF_VARCHAR2_TABLE_100();
      a98 := JTF_DATE_TABLE();
      a99 := JTF_VARCHAR2_TABLE_100();
      a100 := JTF_VARCHAR2_TABLE_100();
      a101 := JTF_VARCHAR2_TABLE_100();
      a102 := JTF_VARCHAR2_TABLE_100();
      a103 := JTF_VARCHAR2_TABLE_100();
      a104 := JTF_VARCHAR2_TABLE_100();
      a105 := JTF_VARCHAR2_TABLE_100();
      a106 := JTF_VARCHAR2_TABLE_100();
      a107 := JTF_VARCHAR2_TABLE_100();
      a108 := JTF_VARCHAR2_TABLE_100();
      a109 := JTF_NUMBER_TABLE();
      a110 := JTF_NUMBER_TABLE();
      a111 := JTF_NUMBER_TABLE();
      a112 := JTF_NUMBER_TABLE();
      a113 := JTF_NUMBER_TABLE();
      a114 := JTF_NUMBER_TABLE();
      a115 := JTF_VARCHAR2_TABLE_100();
      a116 := JTF_VARCHAR2_TABLE_300();
      a117 := JTF_NUMBER_TABLE();
      a118 := JTF_NUMBER_TABLE();
      a119 := JTF_NUMBER_TABLE();
      a120 := JTF_NUMBER_TABLE();
      a121 := JTF_NUMBER_TABLE();
      a122 := JTF_NUMBER_TABLE();
      a123 := JTF_NUMBER_TABLE();
      a124 := JTF_NUMBER_TABLE();
      a125 := JTF_VARCHAR2_TABLE_100();
      a126 := JTF_VARCHAR2_TABLE_100();
      a127 := JTF_NUMBER_TABLE();
      a128 := JTF_DATE_TABLE();
      a129 := JTF_NUMBER_TABLE();
      a130 := JTF_NUMBER_TABLE();
      a131 := JTF_NUMBER_TABLE();
      a132 := JTF_NUMBER_TABLE();
      a133 := JTF_VARCHAR2_TABLE_100();
      a134 := JTF_NUMBER_TABLE();
      a135 := JTF_VARCHAR2_TABLE_100();
      a136 := JTF_NUMBER_TABLE();
      a137 := JTF_NUMBER_TABLE();
      a138 := JTF_NUMBER_TABLE();
      a139 := JTF_DATE_TABLE();
      a140 := JTF_NUMBER_TABLE();
      a141 := JTF_NUMBER_TABLE();
      a142 := JTF_VARCHAR2_TABLE_100();
      a143 := JTF_VARCHAR2_TABLE_100();
      a144 := JTF_VARCHAR2_TABLE_100();
      a145 := JTF_VARCHAR2_TABLE_300();
      a146 := JTF_VARCHAR2_TABLE_300();
      a147 := JTF_VARCHAR2_TABLE_200();
      a148 := JTF_DATE_TABLE();
      a149 := JTF_VARCHAR2_TABLE_200();
      a150 := JTF_VARCHAR2_TABLE_200();
      a151 := JTF_DATE_TABLE();
      a152 := JTF_DATE_TABLE();
      a153 := JTF_DATE_TABLE();
      a154 := JTF_NUMBER_TABLE();
      a155 := JTF_NUMBER_TABLE();
      a156 := JTF_VARCHAR2_TABLE_200();
      a157 := JTF_NUMBER_TABLE();
      a158 := JTF_VARCHAR2_TABLE_100();
      a159 := JTF_VARCHAR2_TABLE_200();
      a160 := JTF_DATE_TABLE();
      a161 := JTF_NUMBER_TABLE();
      a162 := JTF_VARCHAR2_TABLE_100();
      a163 := JTF_NUMBER_TABLE();
      a164 := JTF_NUMBER_TABLE();
      a165 := JTF_VARCHAR2_TABLE_100();
      a166 := JTF_NUMBER_TABLE();
      a167 := JTF_VARCHAR2_TABLE_100();
      a168 := JTF_VARCHAR2_TABLE_200();
      a169 := JTF_VARCHAR2_TABLE_100();
      a170 := JTF_VARCHAR2_TABLE_100();
      a171 := JTF_VARCHAR2_TABLE_100();
      a172 := JTF_VARCHAR2_TABLE_100();
      a173 := JTF_VARCHAR2_TABLE_100();
      a174 := JTF_VARCHAR2_TABLE_100();
      a175 := JTF_VARCHAR2_TABLE_100();
      a176 := JTF_NUMBER_TABLE();
      a177 := JTF_NUMBER_TABLE();
      a178 := JTF_NUMBER_TABLE();
      a179 := JTF_NUMBER_TABLE();
      a180 := JTF_NUMBER_TABLE();
      a181 := JTF_NUMBER_TABLE();
      a182 := JTF_NUMBER_TABLE();
      a183 := JTF_NUMBER_TABLE();
      a184 := JTF_NUMBER_TABLE();
      a185 := JTF_NUMBER_TABLE();
      a186 := JTF_NUMBER_TABLE();
      a187 := JTF_NUMBER_TABLE();
      a188 := JTF_NUMBER_TABLE();
      a189 := JTF_VARCHAR2_TABLE_100();
      a190 := JTF_VARCHAR2_TABLE_100();
      a191 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).interface_transaction_id;
          a1(indx) := t(ddindx).transaction_interface_id;
          a2(indx) := t(ddindx).header_interface_id;
          a3(indx) := t(ddindx).group_id;
          a4(indx) := t(ddindx).inv_loc_assignment_id;
          a5(indx) := t(ddindx).source_type_code;
          a6(indx) := t(ddindx).receipt_source_code;
          a7(indx) := t(ddindx).order_type_code;
          a8(indx) := t(ddindx).order_type;
          a9(indx) := t(ddindx).po_header_id;
          a10(indx) := t(ddindx).po_number;
          a11(indx) := t(ddindx).po_line_id;
          a12(indx) := t(ddindx).po_line_number;
          a13(indx) := t(ddindx).po_line_location_id;
          a14(indx) := t(ddindx).po_shipment_number;
          a15(indx) := t(ddindx).po_release_id;
          a16(indx) := t(ddindx).po_release_number;
          a17(indx) := t(ddindx).req_header_id;
          a18(indx) := t(ddindx).req_number;
          a19(indx) := t(ddindx).req_line_id;
          a20(indx) := t(ddindx).req_line;
          a21(indx) := t(ddindx).req_distribution_id;
          a22(indx) := t(ddindx).rcv_shipment_header_id;
          a23(indx) := t(ddindx).rcv_shipment_number;
          a24(indx) := t(ddindx).rcv_shipment_line_id;
          a25(indx) := t(ddindx).rcv_line_number;
          a26(indx) := t(ddindx).from_organization_id;
          a27(indx) := t(ddindx).to_organization_id;
          a28(indx) := t(ddindx).vendor_id;
          a29(indx) := t(ddindx).source;
          a30(indx) := t(ddindx).vendor_site_id;
          a31(indx) := t(ddindx).outside_operation_flag;
          a32(indx) := t(ddindx).receipt_exception;
          a33(indx) := t(ddindx).item_id;
          a34(indx) := t(ddindx).uom_code;
          a35(indx) := t(ddindx).primary_uom;
          a36(indx) := t(ddindx).primary_uom_class;
          a37(indx) := t(ddindx).item_allowed_units_lookup_code;
          a38(indx) := t(ddindx).item_locator_control;
          a39(indx) := t(ddindx).restrict_locators_code;
          a40(indx) := t(ddindx).restrict_subinventories_code;
          a41(indx) := t(ddindx).shelf_life_code;
          a42(indx) := t(ddindx).shelf_life_days;
          a43(indx) := t(ddindx).serial_number_control_code;
          a44(indx) := t(ddindx).lot_control_code;
          a45(indx) := t(ddindx).item_rev_control_flag_to;
          a46(indx) := t(ddindx).item_rev_control_flag_from;
          a47(indx) := t(ddindx).item_number;
          a48(indx) := t(ddindx).item_revision;
          a49(indx) := t(ddindx).item_description;
          a50(indx) := t(ddindx).item_category_id;
          a51(indx) := t(ddindx).hazard_class;
          a52(indx) := t(ddindx).un_number;
          a53(indx) := t(ddindx).vendor_item_number;
          a54(indx) := t(ddindx).ship_to_location_id;
          a55(indx) := t(ddindx).ship_to_location;
          a56(indx) := t(ddindx).packing_slip;
          a57(indx) := t(ddindx).routing_id;
          a58(indx) := t(ddindx).routing_name;
          a59(indx) := t(ddindx).need_by_date;
          a60(indx) := t(ddindx).expected_receipt_date;
          a61(indx) := t(ddindx).ordered_qty;
          a62(indx) := t(ddindx).ordered_uom;
          a63(indx) := t(ddindx).ussgl_transaction_code;
          a64(indx) := t(ddindx).government_context;
          a65(indx) := t(ddindx).inspection_required_flag;
          a66(indx) := t(ddindx).receipt_required_flag;
          a67(indx) := t(ddindx).enforce_ship_to_location_code;
          a68(indx) := t(ddindx).substitute_receipt;
          a69(indx) := t(ddindx).unit_price;
          a70(indx) := t(ddindx).currency_code;
          a71(indx) := t(ddindx).currency_conversion_type;
          a72(indx) := t(ddindx).currency_conversion_date;
          a73(indx) := t(ddindx).currency_conversion_rate;
          a74(indx) := t(ddindx).note_to_receiver;
          a75(indx) := t(ddindx).destination_type_code;
          a76(indx) := t(ddindx).deliver_to_person_id;
          a77(indx) := t(ddindx).deliver_to_location_id;
          a78(indx) := t(ddindx).destination_subinventory;
          a79(indx) := t(ddindx).attribute_category;
          a80(indx) := t(ddindx).attribute1;
          a81(indx) := t(ddindx).attribute2;
          a82(indx) := t(ddindx).attribute3;
          a83(indx) := t(ddindx).attribute4;
          a84(indx) := t(ddindx).attribute5;
          a85(indx) := t(ddindx).attribute6;
          a86(indx) := t(ddindx).attribute7;
          a87(indx) := t(ddindx).attribute8;
          a88(indx) := t(ddindx).attribute9;
          a89(indx) := t(ddindx).attribute10;
          a90(indx) := t(ddindx).attribute11;
          a91(indx) := t(ddindx).attribute12;
          a92(indx) := t(ddindx).attribute13;
          a93(indx) := t(ddindx).attribute14;
          a94(indx) := t(ddindx).attribute15;
          a95(indx) := t(ddindx).closed_code;
          a96(indx) := t(ddindx).asn_type;
          a97(indx) := t(ddindx).bill_of_lading;
          a98(indx) := t(ddindx).shipped_date;
          a99(indx) := t(ddindx).freight_carrier_code;
          a100(indx) := t(ddindx).waybill_airbill_num;
          a101(indx) := t(ddindx).freight_bill_num;
          a102(indx) := t(ddindx).vendor_lot_num;
          a103(indx) := t(ddindx).container_num;
          a104(indx) := t(ddindx).truck_num;
          a105(indx) := t(ddindx).bar_code_label;
          a106(indx) := t(ddindx).rate_type_display;
          a107(indx) := t(ddindx).match_option;
          a108(indx) := t(ddindx).country_of_origin_code;
          a109(indx) := t(ddindx).oe_order_header_id;
          a110(indx) := t(ddindx).oe_order_num;
          a111(indx) := t(ddindx).oe_order_line_id;
          a112(indx) := t(ddindx).oe_order_line_num;
          a113(indx) := t(ddindx).customer_id;
          a114(indx) := t(ddindx).customer_site_id;
          a115(indx) := t(ddindx).customer_item_num;
          a116(indx) := t(ddindx).pll_note_to_receiver;
          a117(indx) := t(ddindx).po_distribution_id;
          a118(indx) := t(ddindx).qty_ordered;
          a119(indx) := t(ddindx).wip_entity_id;
          a120(indx) := t(ddindx).wip_operation_seq_num;
          a121(indx) := t(ddindx).wip_resource_seq_num;
          a122(indx) := t(ddindx).wip_repetitive_schedule_id;
          a123(indx) := t(ddindx).wip_line_id;
          a124(indx) := t(ddindx).bom_resource_id;
          a125(indx) := t(ddindx).destination_type;
          a126(indx) := t(ddindx).location;
          a127(indx) := t(ddindx).currency_conversion_rate_pod;
          a128(indx) := t(ddindx).currency_conversion_date_pod;
          a129(indx) := t(ddindx).project_id;
          a130(indx) := t(ddindx).task_id;
          a131(indx) := t(ddindx).locator_id;
          a132(indx) := t(ddindx).employee_id;
          a133(indx) := t(ddindx).lot_number;
          a134(indx) := t(ddindx).transaction_quantity;
          a135(indx) := t(ddindx).transaction_uom;
          a136(indx) := t(ddindx).primary_quantity;
          a137(indx) := t(ddindx).lot_quantity;
          a138(indx) := t(ddindx).lot_primary_quantity;
          a139(indx) := t(ddindx).expiration_date;
          a140(indx) := t(ddindx).status_id;
          a141(indx) := t(ddindx).product_transaction_id;
          a142(indx) := t(ddindx).product_code;
          a143(indx) := t(ddindx).att_exist;
          a144(indx) := t(ddindx).update_mln;
          a145(indx) := t(ddindx).description;
          a146(indx) := t(ddindx).vendor_name;
          a147(indx) := t(ddindx).supplier_lot_number;
          a148(indx) := t(ddindx).origination_date;
          a149(indx) := t(ddindx).date_code;
          a150(indx) := t(ddindx).grade_code;
          a151(indx) := t(ddindx).change_date;
          a152(indx) := t(ddindx).maturity_date;
          a153(indx) := t(ddindx).retest_date;
          a154(indx) := t(ddindx).age;
          a155(indx) := t(ddindx).item_size;
          a156(indx) := t(ddindx).color;
          a157(indx) := t(ddindx).volume;
          a158(indx) := t(ddindx).volume_uom;
          a159(indx) := t(ddindx).place_of_origin;
          a160(indx) := t(ddindx).best_by_date;
          a161(indx) := t(ddindx).length;
          a162(indx) := t(ddindx).length_uom;
          a163(indx) := t(ddindx).recycled_content;
          a164(indx) := t(ddindx).thickness;
          a165(indx) := t(ddindx).thickness_uom;
          a166(indx) := t(ddindx).width;
          a167(indx) := t(ddindx).width_uom;
          a168(indx) := t(ddindx).curl_wrinkle_fold;
          a169(indx) := t(ddindx).territory_code;
          a170(indx) := t(ddindx).fm_serial_number;
          a171(indx) := t(ddindx).to_serial_number;
          a172(indx) := t(ddindx).update_msn;
          a173(indx) := t(ddindx).vendor_serial_number;
          a174(indx) := t(ddindx).vendor_lot_number;
          a175(indx) := t(ddindx).parent_serial_number;
          a176(indx) := t(ddindx).time_since_new;
          a177(indx) := t(ddindx).cycles_since_new;
          a178(indx) := t(ddindx).time_since_overhaul;
          a179(indx) := t(ddindx).cycles_since_overhaul;
          a180(indx) := t(ddindx).time_since_repair;
          a181(indx) := t(ddindx).cycles_since_repair;
          a182(indx) := t(ddindx).time_since_visit;
          a183(indx) := t(ddindx).cycles_since_visit;
          a184(indx) := t(ddindx).time_since_mark;
          a185(indx) := t(ddindx).cycles_since_mark;
          a186(indx) := t(ddindx).number_of_repairs;
          a187(indx) := t(ddindx).set_of_books_id_sob;
          a188(indx) := t(ddindx).reason_id;
          a189(indx) := t(ddindx).currency_code_sob;
          a190(indx) := t(ddindx).department_code;
          a191(indx) := t(ddindx).comments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure receive_shipments(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  NUMBER
    , p4_a7  VARCHAR2
    , p4_a8  NUMBER
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  DATE
    , p4_a13  VARCHAR2
    , p4_a14  DATE
    , p4_a15  NUMBER
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  NUMBER
    , p4_a19  NUMBER
    , p4_a20  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_NUMBER_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_VARCHAR2_TABLE_300
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_100
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_VARCHAR2_TABLE_100
    , p5_a35 JTF_VARCHAR2_TABLE_100
    , p5_a36 JTF_VARCHAR2_TABLE_100
    , p5_a37 JTF_NUMBER_TABLE
    , p5_a38 JTF_NUMBER_TABLE
    , p5_a39 JTF_VARCHAR2_TABLE_100
    , p5_a40 JTF_VARCHAR2_TABLE_100
    , p5_a41 JTF_NUMBER_TABLE
    , p5_a42 JTF_NUMBER_TABLE
    , p5_a43 JTF_NUMBER_TABLE
    , p5_a44 JTF_NUMBER_TABLE
    , p5_a45 JTF_VARCHAR2_TABLE_100
    , p5_a46 JTF_VARCHAR2_TABLE_100
    , p5_a47 JTF_VARCHAR2_TABLE_100
    , p5_a48 JTF_VARCHAR2_TABLE_100
    , p5_a49 JTF_VARCHAR2_TABLE_300
    , p5_a50 JTF_NUMBER_TABLE
    , p5_a51 JTF_VARCHAR2_TABLE_100
    , p5_a52 JTF_VARCHAR2_TABLE_100
    , p5_a53 JTF_VARCHAR2_TABLE_100
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_VARCHAR2_TABLE_100
    , p5_a56 JTF_VARCHAR2_TABLE_100
    , p5_a57 JTF_NUMBER_TABLE
    , p5_a58 JTF_VARCHAR2_TABLE_100
    , p5_a59 JTF_DATE_TABLE
    , p5_a60 JTF_DATE_TABLE
    , p5_a61 JTF_NUMBER_TABLE
    , p5_a62 JTF_VARCHAR2_TABLE_100
    , p5_a63 JTF_VARCHAR2_TABLE_100
    , p5_a64 JTF_VARCHAR2_TABLE_100
    , p5_a65 JTF_VARCHAR2_TABLE_100
    , p5_a66 JTF_VARCHAR2_TABLE_100
    , p5_a67 JTF_VARCHAR2_TABLE_100
    , p5_a68 JTF_VARCHAR2_TABLE_100
    , p5_a69 JTF_NUMBER_TABLE
    , p5_a70 JTF_VARCHAR2_TABLE_100
    , p5_a71 JTF_VARCHAR2_TABLE_100
    , p5_a72 JTF_DATE_TABLE
    , p5_a73 JTF_NUMBER_TABLE
    , p5_a74 JTF_VARCHAR2_TABLE_300
    , p5_a75 JTF_VARCHAR2_TABLE_100
    , p5_a76 JTF_NUMBER_TABLE
    , p5_a77 JTF_NUMBER_TABLE
    , p5_a78 JTF_VARCHAR2_TABLE_100
    , p5_a79 JTF_VARCHAR2_TABLE_100
    , p5_a80 JTF_VARCHAR2_TABLE_300
    , p5_a81 JTF_VARCHAR2_TABLE_300
    , p5_a82 JTF_VARCHAR2_TABLE_300
    , p5_a83 JTF_VARCHAR2_TABLE_300
    , p5_a84 JTF_VARCHAR2_TABLE_300
    , p5_a85 JTF_VARCHAR2_TABLE_300
    , p5_a86 JTF_VARCHAR2_TABLE_300
    , p5_a87 JTF_VARCHAR2_TABLE_300
    , p5_a88 JTF_VARCHAR2_TABLE_300
    , p5_a89 JTF_VARCHAR2_TABLE_300
    , p5_a90 JTF_VARCHAR2_TABLE_300
    , p5_a91 JTF_VARCHAR2_TABLE_300
    , p5_a92 JTF_VARCHAR2_TABLE_300
    , p5_a93 JTF_VARCHAR2_TABLE_300
    , p5_a94 JTF_VARCHAR2_TABLE_300
    , p5_a95 JTF_VARCHAR2_TABLE_100
    , p5_a96 JTF_VARCHAR2_TABLE_100
    , p5_a97 JTF_VARCHAR2_TABLE_100
    , p5_a98 JTF_DATE_TABLE
    , p5_a99 JTF_VARCHAR2_TABLE_100
    , p5_a100 JTF_VARCHAR2_TABLE_100
    , p5_a101 JTF_VARCHAR2_TABLE_100
    , p5_a102 JTF_VARCHAR2_TABLE_100
    , p5_a103 JTF_VARCHAR2_TABLE_100
    , p5_a104 JTF_VARCHAR2_TABLE_100
    , p5_a105 JTF_VARCHAR2_TABLE_100
    , p5_a106 JTF_VARCHAR2_TABLE_100
    , p5_a107 JTF_VARCHAR2_TABLE_100
    , p5_a108 JTF_VARCHAR2_TABLE_100
    , p5_a109 JTF_NUMBER_TABLE
    , p5_a110 JTF_NUMBER_TABLE
    , p5_a111 JTF_NUMBER_TABLE
    , p5_a112 JTF_NUMBER_TABLE
    , p5_a113 JTF_NUMBER_TABLE
    , p5_a114 JTF_NUMBER_TABLE
    , p5_a115 JTF_VARCHAR2_TABLE_100
    , p5_a116 JTF_VARCHAR2_TABLE_300
    , p5_a117 JTF_NUMBER_TABLE
    , p5_a118 JTF_NUMBER_TABLE
    , p5_a119 JTF_NUMBER_TABLE
    , p5_a120 JTF_NUMBER_TABLE
    , p5_a121 JTF_NUMBER_TABLE
    , p5_a122 JTF_NUMBER_TABLE
    , p5_a123 JTF_NUMBER_TABLE
    , p5_a124 JTF_NUMBER_TABLE
    , p5_a125 JTF_VARCHAR2_TABLE_100
    , p5_a126 JTF_VARCHAR2_TABLE_100
    , p5_a127 JTF_NUMBER_TABLE
    , p5_a128 JTF_DATE_TABLE
    , p5_a129 JTF_NUMBER_TABLE
    , p5_a130 JTF_NUMBER_TABLE
    , p5_a131 JTF_NUMBER_TABLE
    , p5_a132 JTF_NUMBER_TABLE
    , p5_a133 JTF_VARCHAR2_TABLE_100
    , p5_a134 JTF_NUMBER_TABLE
    , p5_a135 JTF_VARCHAR2_TABLE_100
    , p5_a136 JTF_NUMBER_TABLE
    , p5_a137 JTF_NUMBER_TABLE
    , p5_a138 JTF_NUMBER_TABLE
    , p5_a139 JTF_DATE_TABLE
    , p5_a140 JTF_NUMBER_TABLE
    , p5_a141 JTF_NUMBER_TABLE
    , p5_a142 JTF_VARCHAR2_TABLE_100
    , p5_a143 JTF_VARCHAR2_TABLE_100
    , p5_a144 JTF_VARCHAR2_TABLE_100
    , p5_a145 JTF_VARCHAR2_TABLE_300
    , p5_a146 JTF_VARCHAR2_TABLE_300
    , p5_a147 JTF_VARCHAR2_TABLE_200
    , p5_a148 JTF_DATE_TABLE
    , p5_a149 JTF_VARCHAR2_TABLE_200
    , p5_a150 JTF_VARCHAR2_TABLE_200
    , p5_a151 JTF_DATE_TABLE
    , p5_a152 JTF_DATE_TABLE
    , p5_a153 JTF_DATE_TABLE
    , p5_a154 JTF_NUMBER_TABLE
    , p5_a155 JTF_NUMBER_TABLE
    , p5_a156 JTF_VARCHAR2_TABLE_200
    , p5_a157 JTF_NUMBER_TABLE
    , p5_a158 JTF_VARCHAR2_TABLE_100
    , p5_a159 JTF_VARCHAR2_TABLE_200
    , p5_a160 JTF_DATE_TABLE
    , p5_a161 JTF_NUMBER_TABLE
    , p5_a162 JTF_VARCHAR2_TABLE_100
    , p5_a163 JTF_NUMBER_TABLE
    , p5_a164 JTF_NUMBER_TABLE
    , p5_a165 JTF_VARCHAR2_TABLE_100
    , p5_a166 JTF_NUMBER_TABLE
    , p5_a167 JTF_VARCHAR2_TABLE_100
    , p5_a168 JTF_VARCHAR2_TABLE_200
    , p5_a169 JTF_VARCHAR2_TABLE_100
    , p5_a170 JTF_VARCHAR2_TABLE_100
    , p5_a171 JTF_VARCHAR2_TABLE_100
    , p5_a172 JTF_VARCHAR2_TABLE_100
    , p5_a173 JTF_VARCHAR2_TABLE_100
    , p5_a174 JTF_VARCHAR2_TABLE_100
    , p5_a175 JTF_VARCHAR2_TABLE_100
    , p5_a176 JTF_NUMBER_TABLE
    , p5_a177 JTF_NUMBER_TABLE
    , p5_a178 JTF_NUMBER_TABLE
    , p5_a179 JTF_NUMBER_TABLE
    , p5_a180 JTF_NUMBER_TABLE
    , p5_a181 JTF_NUMBER_TABLE
    , p5_a182 JTF_NUMBER_TABLE
    , p5_a183 JTF_NUMBER_TABLE
    , p5_a184 JTF_NUMBER_TABLE
    , p5_a185 JTF_NUMBER_TABLE
    , p5_a186 JTF_NUMBER_TABLE
    , p5_a187 JTF_NUMBER_TABLE
    , p5_a188 JTF_NUMBER_TABLE
    , p5_a189 JTF_VARCHAR2_TABLE_100
    , p5_a190 JTF_VARCHAR2_TABLE_100
    , p5_a191 JTF_VARCHAR2_TABLE_300
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_receive_hdr_rec csp_receive_pvt.rcv_hdr_rec_type;
    ddp_receive_rec_tbl csp_receive_pvt.rcv_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_receive_hdr_rec.header_interface_id := p4_a0;
    ddp_receive_hdr_rec.group_id := p4_a1;
    ddp_receive_hdr_rec.vendor_id := p4_a2;
    ddp_receive_hdr_rec.vendor_site_id := p4_a3;
    ddp_receive_hdr_rec.source_type_code := p4_a4;
    ddp_receive_hdr_rec.receipt_source_code := p4_a5;
    ddp_receive_hdr_rec.ship_to_org_id := p4_a6;
    ddp_receive_hdr_rec.rcv_shipment_num := p4_a7;
    ddp_receive_hdr_rec.receipt_header_id := p4_a8;
    ddp_receive_hdr_rec.receipt_num := p4_a9;
    ddp_receive_hdr_rec.bill_of_lading := p4_a10;
    ddp_receive_hdr_rec.packing_slip := p4_a11;
    ddp_receive_hdr_rec.shipped_date := p4_a12;
    ddp_receive_hdr_rec.freight_carrier_code := p4_a13;
    ddp_receive_hdr_rec.expected_receipt_date := p4_a14;
    ddp_receive_hdr_rec.employee_id := p4_a15;
    ddp_receive_hdr_rec.waybill_airbill_num := p4_a16;
    ddp_receive_hdr_rec.usggl_transaction_code := p4_a17;
    ddp_receive_hdr_rec.processing_request_id := p4_a18;
    ddp_receive_hdr_rec.customer_id := p4_a19;
    ddp_receive_hdr_rec.customer_site_id := p4_a20;

    csp_receive_pvt_w.rosetta_table_copy_in_p5(ddp_receive_rec_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      , p5_a63
      , p5_a64
      , p5_a65
      , p5_a66
      , p5_a67
      , p5_a68
      , p5_a69
      , p5_a70
      , p5_a71
      , p5_a72
      , p5_a73
      , p5_a74
      , p5_a75
      , p5_a76
      , p5_a77
      , p5_a78
      , p5_a79
      , p5_a80
      , p5_a81
      , p5_a82
      , p5_a83
      , p5_a84
      , p5_a85
      , p5_a86
      , p5_a87
      , p5_a88
      , p5_a89
      , p5_a90
      , p5_a91
      , p5_a92
      , p5_a93
      , p5_a94
      , p5_a95
      , p5_a96
      , p5_a97
      , p5_a98
      , p5_a99
      , p5_a100
      , p5_a101
      , p5_a102
      , p5_a103
      , p5_a104
      , p5_a105
      , p5_a106
      , p5_a107
      , p5_a108
      , p5_a109
      , p5_a110
      , p5_a111
      , p5_a112
      , p5_a113
      , p5_a114
      , p5_a115
      , p5_a116
      , p5_a117
      , p5_a118
      , p5_a119
      , p5_a120
      , p5_a121
      , p5_a122
      , p5_a123
      , p5_a124
      , p5_a125
      , p5_a126
      , p5_a127
      , p5_a128
      , p5_a129
      , p5_a130
      , p5_a131
      , p5_a132
      , p5_a133
      , p5_a134
      , p5_a135
      , p5_a136
      , p5_a137
      , p5_a138
      , p5_a139
      , p5_a140
      , p5_a141
      , p5_a142
      , p5_a143
      , p5_a144
      , p5_a145
      , p5_a146
      , p5_a147
      , p5_a148
      , p5_a149
      , p5_a150
      , p5_a151
      , p5_a152
      , p5_a153
      , p5_a154
      , p5_a155
      , p5_a156
      , p5_a157
      , p5_a158
      , p5_a159
      , p5_a160
      , p5_a161
      , p5_a162
      , p5_a163
      , p5_a164
      , p5_a165
      , p5_a166
      , p5_a167
      , p5_a168
      , p5_a169
      , p5_a170
      , p5_a171
      , p5_a172
      , p5_a173
      , p5_a174
      , p5_a175
      , p5_a176
      , p5_a177
      , p5_a178
      , p5_a179
      , p5_a180
      , p5_a181
      , p5_a182
      , p5_a183
      , p5_a184
      , p5_a185
      , p5_a186
      , p5_a187
      , p5_a188
      , p5_a189
      , p5_a190
      , p5_a191
      );




    -- here's the delegated call to the old PL/SQL routine
    csp_receive_pvt.receive_shipments(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_receive_hdr_rec,
      ddp_receive_rec_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure insert_rcv_txn_interface(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_interface_transaction_id out nocopy  NUMBER
    , p8_a0  NUMBER
    , p8_a1  NUMBER
    , p8_a2  NUMBER
    , p8_a3  NUMBER
    , p8_a4  NUMBER
    , p8_a5  VARCHAR2
    , p8_a6  VARCHAR2
    , p8_a7  VARCHAR2
    , p8_a8  VARCHAR2
    , p8_a9  NUMBER
    , p8_a10  VARCHAR2
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  NUMBER
    , p8_a14  NUMBER
    , p8_a15  NUMBER
    , p8_a16  NUMBER
    , p8_a17  NUMBER
    , p8_a18  VARCHAR2
    , p8_a19  NUMBER
    , p8_a20  NUMBER
    , p8_a21  NUMBER
    , p8_a22  NUMBER
    , p8_a23  VARCHAR2
    , p8_a24  NUMBER
    , p8_a25  NUMBER
    , p8_a26  NUMBER
    , p8_a27  NUMBER
    , p8_a28  NUMBER
    , p8_a29  VARCHAR2
    , p8_a30  NUMBER
    , p8_a31  VARCHAR2
    , p8_a32  VARCHAR2
    , p8_a33  NUMBER
    , p8_a34  VARCHAR2
    , p8_a35  VARCHAR2
    , p8_a36  VARCHAR2
    , p8_a37  NUMBER
    , p8_a38  NUMBER
    , p8_a39  VARCHAR2
    , p8_a40  VARCHAR2
    , p8_a41  NUMBER
    , p8_a42  NUMBER
    , p8_a43  NUMBER
    , p8_a44  NUMBER
    , p8_a45  VARCHAR2
    , p8_a46  VARCHAR2
    , p8_a47  VARCHAR2
    , p8_a48  VARCHAR2
    , p8_a49  VARCHAR2
    , p8_a50  NUMBER
    , p8_a51  VARCHAR2
    , p8_a52  VARCHAR2
    , p8_a53  VARCHAR2
    , p8_a54  NUMBER
    , p8_a55  VARCHAR2
    , p8_a56  VARCHAR2
    , p8_a57  NUMBER
    , p8_a58  VARCHAR2
    , p8_a59  DATE
    , p8_a60  DATE
    , p8_a61  NUMBER
    , p8_a62  VARCHAR2
    , p8_a63  VARCHAR2
    , p8_a64  VARCHAR2
    , p8_a65  VARCHAR2
    , p8_a66  VARCHAR2
    , p8_a67  VARCHAR2
    , p8_a68  VARCHAR2
    , p8_a69  NUMBER
    , p8_a70  VARCHAR2
    , p8_a71  VARCHAR2
    , p8_a72  DATE
    , p8_a73  NUMBER
    , p8_a74  VARCHAR2
    , p8_a75  VARCHAR2
    , p8_a76  NUMBER
    , p8_a77  NUMBER
    , p8_a78  VARCHAR2
    , p8_a79  VARCHAR2
    , p8_a80  VARCHAR2
    , p8_a81  VARCHAR2
    , p8_a82  VARCHAR2
    , p8_a83  VARCHAR2
    , p8_a84  VARCHAR2
    , p8_a85  VARCHAR2
    , p8_a86  VARCHAR2
    , p8_a87  VARCHAR2
    , p8_a88  VARCHAR2
    , p8_a89  VARCHAR2
    , p8_a90  VARCHAR2
    , p8_a91  VARCHAR2
    , p8_a92  VARCHAR2
    , p8_a93  VARCHAR2
    , p8_a94  VARCHAR2
    , p8_a95  VARCHAR2
    , p8_a96  VARCHAR2
    , p8_a97  VARCHAR2
    , p8_a98  DATE
    , p8_a99  VARCHAR2
    , p8_a100  VARCHAR2
    , p8_a101  VARCHAR2
    , p8_a102  VARCHAR2
    , p8_a103  VARCHAR2
    , p8_a104  VARCHAR2
    , p8_a105  VARCHAR2
    , p8_a106  VARCHAR2
    , p8_a107  VARCHAR2
    , p8_a108  VARCHAR2
    , p8_a109  NUMBER
    , p8_a110  NUMBER
    , p8_a111  NUMBER
    , p8_a112  NUMBER
    , p8_a113  NUMBER
    , p8_a114  NUMBER
    , p8_a115  VARCHAR2
    , p8_a116  VARCHAR2
    , p8_a117  NUMBER
    , p8_a118  NUMBER
    , p8_a119  NUMBER
    , p8_a120  NUMBER
    , p8_a121  NUMBER
    , p8_a122  NUMBER
    , p8_a123  NUMBER
    , p8_a124  NUMBER
    , p8_a125  VARCHAR2
    , p8_a126  VARCHAR2
    , p8_a127  NUMBER
    , p8_a128  DATE
    , p8_a129  NUMBER
    , p8_a130  NUMBER
    , p8_a131  NUMBER
    , p8_a132  NUMBER
    , p8_a133  VARCHAR2
    , p8_a134  NUMBER
    , p8_a135  VARCHAR2
    , p8_a136  NUMBER
    , p8_a137  NUMBER
    , p8_a138  NUMBER
    , p8_a139  DATE
    , p8_a140  NUMBER
    , p8_a141  NUMBER
    , p8_a142  VARCHAR2
    , p8_a143  VARCHAR2
    , p8_a144  VARCHAR2
    , p8_a145  VARCHAR2
    , p8_a146  VARCHAR2
    , p8_a147  VARCHAR2
    , p8_a148  DATE
    , p8_a149  VARCHAR2
    , p8_a150  VARCHAR2
    , p8_a151  DATE
    , p8_a152  DATE
    , p8_a153  DATE
    , p8_a154  NUMBER
    , p8_a155  NUMBER
    , p8_a156  VARCHAR2
    , p8_a157  NUMBER
    , p8_a158  VARCHAR2
    , p8_a159  VARCHAR2
    , p8_a160  DATE
    , p8_a161  NUMBER
    , p8_a162  VARCHAR2
    , p8_a163  NUMBER
    , p8_a164  NUMBER
    , p8_a165  VARCHAR2
    , p8_a166  NUMBER
    , p8_a167  VARCHAR2
    , p8_a168  VARCHAR2
    , p8_a169  VARCHAR2
    , p8_a170  VARCHAR2
    , p8_a171  VARCHAR2
    , p8_a172  VARCHAR2
    , p8_a173  VARCHAR2
    , p8_a174  VARCHAR2
    , p8_a175  VARCHAR2
    , p8_a176  NUMBER
    , p8_a177  NUMBER
    , p8_a178  NUMBER
    , p8_a179  NUMBER
    , p8_a180  NUMBER
    , p8_a181  NUMBER
    , p8_a182  NUMBER
    , p8_a183  NUMBER
    , p8_a184  NUMBER
    , p8_a185  NUMBER
    , p8_a186  NUMBER
    , p8_a187  NUMBER
    , p8_a188  NUMBER
    , p8_a189  VARCHAR2
    , p8_a190  VARCHAR2
    , p8_a191  VARCHAR2
  )

  as
    ddp_receive_rec csp_receive_pvt.rcv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_receive_rec.interface_transaction_id := p8_a0;
    ddp_receive_rec.transaction_interface_id := p8_a1;
    ddp_receive_rec.header_interface_id := p8_a2;
    ddp_receive_rec.group_id := p8_a3;
    ddp_receive_rec.inv_loc_assignment_id := p8_a4;
    ddp_receive_rec.source_type_code := p8_a5;
    ddp_receive_rec.receipt_source_code := p8_a6;
    ddp_receive_rec.order_type_code := p8_a7;
    ddp_receive_rec.order_type := p8_a8;
    ddp_receive_rec.po_header_id := p8_a9;
    ddp_receive_rec.po_number := p8_a10;
    ddp_receive_rec.po_line_id := p8_a11;
    ddp_receive_rec.po_line_number := p8_a12;
    ddp_receive_rec.po_line_location_id := p8_a13;
    ddp_receive_rec.po_shipment_number := p8_a14;
    ddp_receive_rec.po_release_id := p8_a15;
    ddp_receive_rec.po_release_number := p8_a16;
    ddp_receive_rec.req_header_id := p8_a17;
    ddp_receive_rec.req_number := p8_a18;
    ddp_receive_rec.req_line_id := p8_a19;
    ddp_receive_rec.req_line := p8_a20;
    ddp_receive_rec.req_distribution_id := p8_a21;
    ddp_receive_rec.rcv_shipment_header_id := p8_a22;
    ddp_receive_rec.rcv_shipment_number := p8_a23;
    ddp_receive_rec.rcv_shipment_line_id := p8_a24;
    ddp_receive_rec.rcv_line_number := p8_a25;
    ddp_receive_rec.from_organization_id := p8_a26;
    ddp_receive_rec.to_organization_id := p8_a27;
    ddp_receive_rec.vendor_id := p8_a28;
    ddp_receive_rec.source := p8_a29;
    ddp_receive_rec.vendor_site_id := p8_a30;
    ddp_receive_rec.outside_operation_flag := p8_a31;
    ddp_receive_rec.receipt_exception := p8_a32;
    ddp_receive_rec.item_id := p8_a33;
    ddp_receive_rec.uom_code := p8_a34;
    ddp_receive_rec.primary_uom := p8_a35;
    ddp_receive_rec.primary_uom_class := p8_a36;
    ddp_receive_rec.item_allowed_units_lookup_code := p8_a37;
    ddp_receive_rec.item_locator_control := p8_a38;
    ddp_receive_rec.restrict_locators_code := p8_a39;
    ddp_receive_rec.restrict_subinventories_code := p8_a40;
    ddp_receive_rec.shelf_life_code := p8_a41;
    ddp_receive_rec.shelf_life_days := p8_a42;
    ddp_receive_rec.serial_number_control_code := p8_a43;
    ddp_receive_rec.lot_control_code := p8_a44;
    ddp_receive_rec.item_rev_control_flag_to := p8_a45;
    ddp_receive_rec.item_rev_control_flag_from := p8_a46;
    ddp_receive_rec.item_number := p8_a47;
    ddp_receive_rec.item_revision := p8_a48;
    ddp_receive_rec.item_description := p8_a49;
    ddp_receive_rec.item_category_id := p8_a50;
    ddp_receive_rec.hazard_class := p8_a51;
    ddp_receive_rec.un_number := p8_a52;
    ddp_receive_rec.vendor_item_number := p8_a53;
    ddp_receive_rec.ship_to_location_id := p8_a54;
    ddp_receive_rec.ship_to_location := p8_a55;
    ddp_receive_rec.packing_slip := p8_a56;
    ddp_receive_rec.routing_id := p8_a57;
    ddp_receive_rec.routing_name := p8_a58;
    ddp_receive_rec.need_by_date := p8_a59;
    ddp_receive_rec.expected_receipt_date := p8_a60;
    ddp_receive_rec.ordered_qty := p8_a61;
    ddp_receive_rec.ordered_uom := p8_a62;
    ddp_receive_rec.ussgl_transaction_code := p8_a63;
    ddp_receive_rec.government_context := p8_a64;
    ddp_receive_rec.inspection_required_flag := p8_a65;
    ddp_receive_rec.receipt_required_flag := p8_a66;
    ddp_receive_rec.enforce_ship_to_location_code := p8_a67;
    ddp_receive_rec.substitute_receipt := p8_a68;
    ddp_receive_rec.unit_price := p8_a69;
    ddp_receive_rec.currency_code := p8_a70;
    ddp_receive_rec.currency_conversion_type := p8_a71;
    ddp_receive_rec.currency_conversion_date := p8_a72;
    ddp_receive_rec.currency_conversion_rate := p8_a73;
    ddp_receive_rec.note_to_receiver := p8_a74;
    ddp_receive_rec.destination_type_code := p8_a75;
    ddp_receive_rec.deliver_to_person_id := p8_a76;
    ddp_receive_rec.deliver_to_location_id := p8_a77;
    ddp_receive_rec.destination_subinventory := p8_a78;
    ddp_receive_rec.attribute_category := p8_a79;
    ddp_receive_rec.attribute1 := p8_a80;
    ddp_receive_rec.attribute2 := p8_a81;
    ddp_receive_rec.attribute3 := p8_a82;
    ddp_receive_rec.attribute4 := p8_a83;
    ddp_receive_rec.attribute5 := p8_a84;
    ddp_receive_rec.attribute6 := p8_a85;
    ddp_receive_rec.attribute7 := p8_a86;
    ddp_receive_rec.attribute8 := p8_a87;
    ddp_receive_rec.attribute9 := p8_a88;
    ddp_receive_rec.attribute10 := p8_a89;
    ddp_receive_rec.attribute11 := p8_a90;
    ddp_receive_rec.attribute12 := p8_a91;
    ddp_receive_rec.attribute13 := p8_a92;
    ddp_receive_rec.attribute14 := p8_a93;
    ddp_receive_rec.attribute15 := p8_a94;
    ddp_receive_rec.closed_code := p8_a95;
    ddp_receive_rec.asn_type := p8_a96;
    ddp_receive_rec.bill_of_lading := p8_a97;
    ddp_receive_rec.shipped_date := p8_a98;
    ddp_receive_rec.freight_carrier_code := p8_a99;
    ddp_receive_rec.waybill_airbill_num := p8_a100;
    ddp_receive_rec.freight_bill_num := p8_a101;
    ddp_receive_rec.vendor_lot_num := p8_a102;
    ddp_receive_rec.container_num := p8_a103;
    ddp_receive_rec.truck_num := p8_a104;
    ddp_receive_rec.bar_code_label := p8_a105;
    ddp_receive_rec.rate_type_display := p8_a106;
    ddp_receive_rec.match_option := p8_a107;
    ddp_receive_rec.country_of_origin_code := p8_a108;
    ddp_receive_rec.oe_order_header_id := p8_a109;
    ddp_receive_rec.oe_order_num := p8_a110;
    ddp_receive_rec.oe_order_line_id := p8_a111;
    ddp_receive_rec.oe_order_line_num := p8_a112;
    ddp_receive_rec.customer_id := p8_a113;
    ddp_receive_rec.customer_site_id := p8_a114;
    ddp_receive_rec.customer_item_num := p8_a115;
    ddp_receive_rec.pll_note_to_receiver := p8_a116;
    ddp_receive_rec.po_distribution_id := p8_a117;
    ddp_receive_rec.qty_ordered := p8_a118;
    ddp_receive_rec.wip_entity_id := p8_a119;
    ddp_receive_rec.wip_operation_seq_num := p8_a120;
    ddp_receive_rec.wip_resource_seq_num := p8_a121;
    ddp_receive_rec.wip_repetitive_schedule_id := p8_a122;
    ddp_receive_rec.wip_line_id := p8_a123;
    ddp_receive_rec.bom_resource_id := p8_a124;
    ddp_receive_rec.destination_type := p8_a125;
    ddp_receive_rec.location := p8_a126;
    ddp_receive_rec.currency_conversion_rate_pod := p8_a127;
    ddp_receive_rec.currency_conversion_date_pod := p8_a128;
    ddp_receive_rec.project_id := p8_a129;
    ddp_receive_rec.task_id := p8_a130;
    ddp_receive_rec.locator_id := p8_a131;
    ddp_receive_rec.employee_id := p8_a132;
    ddp_receive_rec.lot_number := p8_a133;
    ddp_receive_rec.transaction_quantity := p8_a134;
    ddp_receive_rec.transaction_uom := p8_a135;
    ddp_receive_rec.primary_quantity := p8_a136;
    ddp_receive_rec.lot_quantity := p8_a137;
    ddp_receive_rec.lot_primary_quantity := p8_a138;
    ddp_receive_rec.expiration_date := p8_a139;
    ddp_receive_rec.status_id := p8_a140;
    ddp_receive_rec.product_transaction_id := p8_a141;
    ddp_receive_rec.product_code := p8_a142;
    ddp_receive_rec.att_exist := p8_a143;
    ddp_receive_rec.update_mln := p8_a144;
    ddp_receive_rec.description := p8_a145;
    ddp_receive_rec.vendor_name := p8_a146;
    ddp_receive_rec.supplier_lot_number := p8_a147;
    ddp_receive_rec.origination_date := p8_a148;
    ddp_receive_rec.date_code := p8_a149;
    ddp_receive_rec.grade_code := p8_a150;
    ddp_receive_rec.change_date := p8_a151;
    ddp_receive_rec.maturity_date := p8_a152;
    ddp_receive_rec.retest_date := p8_a153;
    ddp_receive_rec.age := p8_a154;
    ddp_receive_rec.item_size := p8_a155;
    ddp_receive_rec.color := p8_a156;
    ddp_receive_rec.volume := p8_a157;
    ddp_receive_rec.volume_uom := p8_a158;
    ddp_receive_rec.place_of_origin := p8_a159;
    ddp_receive_rec.best_by_date := p8_a160;
    ddp_receive_rec.length := p8_a161;
    ddp_receive_rec.length_uom := p8_a162;
    ddp_receive_rec.recycled_content := p8_a163;
    ddp_receive_rec.thickness := p8_a164;
    ddp_receive_rec.thickness_uom := p8_a165;
    ddp_receive_rec.width := p8_a166;
    ddp_receive_rec.width_uom := p8_a167;
    ddp_receive_rec.curl_wrinkle_fold := p8_a168;
    ddp_receive_rec.territory_code := p8_a169;
    ddp_receive_rec.fm_serial_number := p8_a170;
    ddp_receive_rec.to_serial_number := p8_a171;
    ddp_receive_rec.update_msn := p8_a172;
    ddp_receive_rec.vendor_serial_number := p8_a173;
    ddp_receive_rec.vendor_lot_number := p8_a174;
    ddp_receive_rec.parent_serial_number := p8_a175;
    ddp_receive_rec.time_since_new := p8_a176;
    ddp_receive_rec.cycles_since_new := p8_a177;
    ddp_receive_rec.time_since_overhaul := p8_a178;
    ddp_receive_rec.cycles_since_overhaul := p8_a179;
    ddp_receive_rec.time_since_repair := p8_a180;
    ddp_receive_rec.cycles_since_repair := p8_a181;
    ddp_receive_rec.time_since_visit := p8_a182;
    ddp_receive_rec.cycles_since_visit := p8_a183;
    ddp_receive_rec.time_since_mark := p8_a184;
    ddp_receive_rec.cycles_since_mark := p8_a185;
    ddp_receive_rec.number_of_repairs := p8_a186;
    ddp_receive_rec.set_of_books_id_sob := p8_a187;
    ddp_receive_rec.reason_id := p8_a188;
    ddp_receive_rec.currency_code_sob := p8_a189;
    ddp_receive_rec.department_code := p8_a190;
    ddp_receive_rec.comments := p8_a191;

    -- here's the delegated call to the old PL/SQL routine
    csp_receive_pvt.insert_rcv_txn_interface(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_interface_transaction_id,
      ddp_receive_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end csp_receive_pvt_w;

/
