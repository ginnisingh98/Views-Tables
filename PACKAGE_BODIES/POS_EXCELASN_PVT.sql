--------------------------------------------------------
--  DDL for Package Body POS_EXCELASN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_EXCELASN_PVT" AS
/* $Header: POSVEXAB.pls 120.7.12010000.14 2014/04/17 11:05:17 ramkandu ship $ */


procedure InsertIntoRHI;
procedure InsertIntoRTI;

procedure CheckSecuringAtt(
			x_return_status out nocopy varchar2,
			x_user_vendor_id_tbl out nocopy vendor_id_tbl_type,
			x_secure_by_site out nocopy varchar2,
			x_secure_by_contact out nocopy varchar2,
			x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
			x_error_pointer in out nocopy number
			);
------------------------------------------------------------------

/*
* N: Not available
* P: Pending
* E: Completed with errors
* EP: Completed with errors (Error information is purged)
* S: Success
* U: Unknown
*/
function get_status(p_group_id in number) return varchar2
IS
cursor l_rhiError_csr(x_group_id in number)
is
select 1
from rcv_headers_interface
where group_id = x_group_id
and processing_status_code = 'ERROR';

cursor l_rtiError_csr(x_group_id in number)
is
select 1
from rcv_transactions_interface
where group_id = x_group_id
and (processing_status_code = 'ERROR' or transaction_status_code = 'ERROR');

cursor l_rhiPending_csr(x_group_id in number)
is
select 1
from rcv_headers_interface
where group_id = x_group_id
and processing_status_code in ('PENDING','RUNNING');

cursor l_rtiPending_csr(x_group_id in number)
is
select 1
from rcv_transactions_interface
where group_id = x_group_id
and (processing_status_code in ('PENDING','RUNNING') or transaction_status_code = 'ERROR');

cursor l_rhiExist_csr(x_group_id in number)
is
select 1
from rcv_headers_interface
where group_id = x_group_id;

cursor l_pieExist_csr(x_group_id in number)
is
select 1
from po_interface_errors pie1,
	rcv_headers_interface rhi
where rhi.group_id = x_group_id
and rhi.header_interface_id = pie1.interface_header_id
union all
select 1
from po_interface_errors pie2,
	rcv_transactions_interface rti
where rti.group_id = x_group_id
and rti.interface_transaction_id = pie2.interface_line_id;


l_rhi_exist number := null;
l_rti_exist number := null;
l_pie_exist number;
l_error_exp exception;
Begin
	begin
		--Check if Error at Header Level Occur
		open l_rhiError_csr(p_group_id);
		fetch l_rhiError_csr into l_rhi_exist;
		close l_rhiError_csr;

		if(l_rhi_exist = 1) then
			raise l_error_exp;
		end if;


		--Check if Pending,Running at Header Level Exist
		l_rhi_exist := null;
		open l_rhiPending_csr(p_group_id);
		fetch l_rhiPending_csr into l_rhi_exist;
		close l_rhiPending_csr;

		if(l_rhi_exist = 1) then
			return 'P';
		end if;

		--Check if Header Intf Record still exist
		l_rhi_exist := null;
		open l_rhiExist_csr(p_group_id);
		fetch l_rhiExist_csr into l_rhi_exist;
		CLOSE l_rhiExist_csr;

		if(l_rhi_exist is null) then
			return 'N';
		end if;

		--At this stage, all records in Header Interface table is in 'SUCCESS' status => Check Line Records
		--Check if Line Error Exist
		open l_rtiError_csr(p_group_id);
		fetch l_rtiError_csr into l_rti_exist;
		close l_rtiError_csr;

		if(l_rti_exist = 1) then
			raise l_error_exp;
		end if;

		--Check if Line Pending/Running Exist
		l_rti_exist := null;
		open l_rtiPending_csr(p_group_id);
		fetch l_rtiPending_csr into l_rti_exist;
		close l_rtiPending_csr;

		if(l_rti_exist = 1) then
			return 'P';
		end if;



	exception when l_error_exp then
		--At this stage, errors at Header or Line level occur. Need to check if PIE exist
		open l_pieExist_csr(p_group_id);
		fetch l_pieExist_csr into l_pie_exist;
		close l_pieExist_csr;

		if(l_pie_exist = 1) then
			return 'E';
		else
			return 'EP';
		end if;

	end;

	return 'S';

exception when others then
	return 'U';
end get_status;


procedure ValidateLls(x_return_status out nocopy varchar2,
										x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
										x_error_pointer in out NOCOPY number)
IS
cursor l_ParentQtyNull_csr
is
select plpn.line_number
from pos_exasn_lpns plpn
where parent_lpn is null
and quantity is null;


cursor l_LineVsLotQty_csr
is
select plnt.line_number
from pos_exasn_lines plnt, pos_exasn_lots plot
where plnt.line_id = plot.line_id
group by plnt.line_number, plnt.quantity
having plnt.quantity <> sum(plot.quantity)
and sum(plot.quantity) > 0;

cursor l_LineVsSerialQty_csr
is
select plnt.line_number
from pos_exasn_lines plnt, pos_exasn_serials pst
where plnt.line_id = pst.line_id
group by plnt.line_number, plnt.quantity
having plnt.quantity <> sum(pst.quantity)
and sum(pst.quantity) > 0;

cursor l_lineVsLpnQty_csr
is
select plnt.line_number
from pos_exasn_lines plnt, pos_exasn_lpns plpn
where plnt.line_id = plpn.line_id
group by plnt.line_number, plnt.quantity
having plnt.quantity <> sum(plpn.quantity)
and sum(plpn.quantity) > 0;

cursor l_lotVsSerialQty_csr
is
select plot.line_number
from pos_exasn_lots plot, pos_exasn_serials pst
where plot.lot_id = pst.lot_id
group by plot.line_number, plot.quantity
having plot.quantity <> sum(pst.quantity);

cursor l_checkLot_csr
is
select 	line_number, lot_number, license_plate_number, po_line_loc_id,
	lot_attribute_category, cattribute1, cattribute2, cattribute3,
	cattribute4, cattribute5, cattribute6, cattribute7, cattribute8,
	cattribute9, cattribute10, cattribute11, cattribute12, cattribute13,
	cattribute14, cattribute15, cattribute16, cattribute17, cattribute18,
	cattribute19, cattribute20,
	dattribute1, dattribute2, dattribute3, dattribute4, dattribute5,
	dattribute6, dattribute7, dattribute8, dattribute9, dattribute10,
	nattribute1, nattribute2, nattribute3, nattribute4, nattribute5,
	nattribute6, nattribute7, nattribute8, nattribute9, nattribute10,
	grade_code, origination_date, date_code, status_id, change_date,
	age, retest_date, maturity_date, item_size, color, volume,
	volume_uom, place_of_origin, best_by_date, length, length_uom,
	recycled_content, thickness, thickness_uom, width, width_uom,
	territory_code, supplier_lot_number, vendor_name
from pos_exasn_lots;

cursor l_checkSerial_csr
is
select line_number, from_serial, to_serial, quantity, license_plate_number, po_line_loc_id, lot_number
from pos_exasn_serials;

cursor l_checkLpn_csr
is
select line_number, license_plate_number, parent_lpn, po_line_loc_id
from pos_exasn_lpns;


l_error_ln number;
l_is_new_lot varchar2(60);
l_lot_ln number;
l_lot_number pos_exasn_lots.lot_number%type;
l_lpn pos_exasn_lpns.license_plate_number%type;
l_po_line_loc_id number;

l_lot_attribute_category varchar2(60);
l_cattribute1 varchar2(2000);
l_cattribute2 varchar2(2000);
l_cattribute3 varchar2(2000);
l_cattribute4 varchar2(2000);
l_cattribute5 varchar2(2000);
l_cattribute6 varchar2(2000);
l_cattribute7 varchar2(2000);
l_cattribute8 varchar2(2000);
l_cattribute9 varchar2(2000);
l_cattribute10 varchar2(2000);
l_cattribute11 varchar2(2000);
l_cattribute12 varchar2(2000);
l_cattribute13 varchar2(2000);
l_cattribute14 varchar2(2000);
l_cattribute15 varchar2(2000);
l_cattribute16 varchar2(2000);
l_cattribute17 varchar2(2000);
l_cattribute18 varchar2(2000);
l_cattribute19 varchar2(2000);
l_cattribute20 varchar2(2000);
l_dattribute1 date;
l_dattribute2 date;
l_dattribute3 date;
l_dattribute4 date;
l_dattribute5 date;
l_dattribute6 date;
l_dattribute7 date;
l_dattribute8 date;
l_dattribute9 date;
l_dattribute10 date;
l_nattribute1 number;
l_nattribute2 number;
l_nattribute3 number;
l_nattribute4 number;
l_nattribute5 number;
l_nattribute6 number;
l_nattribute7 number;
l_nattribute8 number;
l_nattribute9 number;
l_nattribute10 number;

l_c_attributes_tbl po_tbl_varchar2000 := po_tbl_varchar2000();
l_n_attributes_tbl po_tbl_number      := po_tbl_number();
l_d_attributes_tbl po_tbl_date        := po_tbl_date();

l_grade_code varchar2(2000);
l_origination_date date;
l_date_code varchar2(2000);
l_status_id number;
l_change_date date;
l_age number;
l_retest_date date;
l_maturity_date date;
l_item_size number;
l_color varchar2(2000);
l_volume number;
l_volume_uom varchar2(60);
l_place_of_origin varchar2(2000);
l_best_by_date date;
l_length number;
l_length_uom varchar2(60);
l_recycled_content number;
l_thickness number;
l_thickness_uom varchar2(60);
l_width number;
l_width_uom varchar2(60);
l_territory_code varchar2(60);
l_supplier_lot_number varchar2(2000);
l_vendor_name varchar2(2000);

l_lot_status varchar2(1);
l_lot_return_code varchar2(1);
l_lot_return_msg varchar2(2000);
l_ser_ln number;
l_ser_status varchar2(1);
l_ser_return_code varchar2(1);
l_ser_return_msg varchar2(2000);
l_lpn_status varchar2(1);
l_lpn_return_code varchar2(1);
l_lpn_return_msg varchar2(2000);
l_fm_serial pos_exasn_serials.from_serial%type;
l_to_serial pos_exasn_serials.to_serial%type;
l_ser_qty number;
l_lpn_ln number;
l_parent_lpn varchar2(60);
l_25errors exception;
BEGIN

	open l_ParentQtyNull_csr;
	loop
	fetch l_ParentQtyNull_csr into l_error_ln;
	exit when l_ParentQtyNull_csr%NOTFOUND;
	--Line LINE_NUM is invalid because both parent license plate number and quantity are empty
		fnd_message.set_name('POS','POS_EXASN_PLPNQTYNULL');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_ParentQtyNull_csr;

	open l_LineVsLotQty_csr;
	loop
	fetch l_LineVsLotQty_csr into l_error_ln;
	exit when l_LineVsLotQty_csr%NOTFOUND;
	--Total lot quantity is not equal to the shipment quantity at line LINE_NUM
		fnd_message.set_name('POS','POS_EXASN_LOT_NE_LN');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_LineVsLotQty_csr;


	open l_lineVsSerialQty_csr;
	loop
	fetch l_lineVsSerialQty_csr into l_error_ln;
	exit when l_lineVsSerialQty_csr%NOTFOUND;
	--Total serial quantity is not equal to the shipment quantity at line LINE_NUM
		fnd_message.set_name('POS','POS_EXASN_SER_NE_LN');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_lineVsSerialQty_csr;

	open l_lineVsLpnQty_csr;
	loop
	fetch l_lineVsLpnQty_csr into l_error_ln;
	exit when l_lineVsLpnQty_csr%NOTFOUND;
	--Total license plate number quantity is not equal to the shipment quantity at line LINE_NUM
		fnd_message.set_name('POS','POS_EXASN_LPN_NE_LN');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;

	end loop;
	close l_lineVsLpnQty_csr;

	open l_LotVsSerialQty_csr;
	loop
	fetch l_LotVsSerialQty_csr into l_error_ln;
	exit when l_LotVsSerialQty_csr%NOTFOUND;
	--Total serial quantity is not equal to the lot quanttiy at line LINE_NUM
		fnd_message.set_name('POS','POS_EXASN_SER_NE_LOT');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_LotVsSerialQty_csr;


	--Update lot info of Serial Records which are children of Lot Records
	update pos_exasn_serials pst
	set pst.lot_number = (select plot.lot_number
						from pos_exasn_lots plot
						where plot.header_id = pst.header_id
						and plot.line_id = pst.line_id
						and plot.lot_id = pst.lot_id);

	update pos_exasn_lpns plpn
	set (plpn.po_line_loc_id) = (select plnt.po_line_location_id
												from pos_exasn_lines plnt
												where plnt.header_id = plpn.header_id
												and plnt.line_id = plpn.line_id);

	update pos_exasn_lots plot
	set (plot.po_line_loc_id) = (select plnt.po_line_location_id
												from pos_exasn_lines plnt
												where plnt.header_id = plot.header_id
												and plnt.line_id = plot.line_id);
	update pos_exasn_serials pst
	set (pst.po_line_loc_id) = (select plnt.po_line_location_id
												from pos_exasn_lines plnt
												where plnt.header_id = pst.header_id
												and plnt.line_id = pst.line_id);

	open l_checkLot_csr;
	loop
	fetch l_checkLot_csr into
		l_lot_ln,
		l_lot_number,
		l_lpn,
		l_po_line_loc_id,
		l_lot_attribute_category,
		l_cattribute1,
		l_cattribute2,
		l_cattribute3,
		l_cattribute4,
		l_cattribute5,
		l_cattribute6,
		l_cattribute7,
		l_cattribute8,
		l_cattribute9,
		l_cattribute10,
		l_cattribute11,
		l_cattribute12,
		l_cattribute13,
		l_cattribute14,
		l_cattribute15,
		l_cattribute16,
		l_cattribute17,
		l_cattribute18,
		l_cattribute19,
		l_cattribute20,
		l_dattribute1,
		l_dattribute2,
		l_dattribute3,
		l_dattribute4,
		l_dattribute5,
		l_dattribute6,
		l_dattribute7,
		l_dattribute8,
		l_dattribute9,
		l_dattribute10,
		l_nattribute1,
		l_nattribute2,
		l_nattribute3,
		l_nattribute4,
		l_nattribute5,
		l_nattribute6,
		l_nattribute7,
		l_nattribute8,
		l_nattribute9,
		l_nattribute10,
		l_grade_code,
		l_origination_date,
		l_date_code,
		l_status_id,
		l_change_date,
		l_age,
		l_retest_date,
		l_maturity_date,
		l_item_size,
		l_color,
		l_volume,
		l_volume_uom,
		l_place_of_origin,
		l_best_by_date,
		l_length,
		l_length_uom,
		l_recycled_content,
		l_thickness,
		l_thickness_uom,
		l_width,
		l_width_uom,
		l_territory_code,
		l_supplier_lot_number,
		l_vendor_name;
	exit when l_checkLot_csr%NOTFOUND;

		l_c_attributes_tbl.extend(20);
		l_n_attributes_tbl.extend(10);
		l_d_attributes_tbl.extend(10);

                l_c_attributes_tbl(1)  := l_cattribute1;
                l_c_attributes_tbl(2)  := l_cattribute2;
                l_c_attributes_tbl(3)  := l_cattribute3;
                l_c_attributes_tbl(4)  := l_cattribute4;
                l_c_attributes_tbl(5)  := l_cattribute5;
                l_c_attributes_tbl(6)  := l_cattribute6;
                l_c_attributes_tbl(7)  := l_cattribute7;
                l_c_attributes_tbl(8)  := l_cattribute8;
                l_c_attributes_tbl(9)  := l_cattribute9;
                l_c_attributes_tbl(10) := l_cattribute10;
                l_c_attributes_tbl(11) := l_cattribute11;
                l_c_attributes_tbl(12) := l_cattribute12;
                l_c_attributes_tbl(13) := l_cattribute13;
                l_c_attributes_tbl(14) := l_cattribute14;
                l_c_attributes_tbl(15) := l_cattribute15;
                l_c_attributes_tbl(16) := l_cattribute16;
                l_c_attributes_tbl(17) := l_cattribute17;
                l_c_attributes_tbl(18) := l_cattribute18;
                l_c_attributes_tbl(19) := l_cattribute19;
                l_c_attributes_tbl(20) := l_cattribute20;
                l_d_attributes_tbl(1)  := l_dattribute1;
                l_d_attributes_tbl(2)  := l_dattribute2;
                l_d_attributes_tbl(3)  := l_dattribute3;
                l_d_attributes_tbl(4)  := l_dattribute4;
                l_d_attributes_tbl(5)  := l_dattribute5;
                l_d_attributes_tbl(6)  := l_dattribute6;
                l_d_attributes_tbl(7)  := l_dattribute7;
                l_d_attributes_tbl(8)  := l_dattribute8;
                l_d_attributes_tbl(9)  := l_dattribute9;
                l_d_attributes_tbl(10) := l_dattribute10;
                l_n_attributes_tbl(1)  := l_nattribute1;
                l_n_attributes_tbl(2)  := l_nattribute2;
                l_n_attributes_tbl(3)  := l_nattribute3;
                l_n_attributes_tbl(4)  := l_nattribute4;
                l_n_attributes_tbl(5)  := l_nattribute5;
                l_n_attributes_tbl(6)  := l_nattribute6;
                l_n_attributes_tbl(7)  := l_nattribute7;
                l_n_attributes_tbl(8)  := l_nattribute8;
                l_n_attributes_tbl(9)  := l_nattribute9;
                l_n_attributes_tbl(10) := l_nattribute10;


		POS_ASN_CREATE_PVT.ValidateLot(
   									p_api_version	=> 1
								   	, x_return_status   => l_lot_status
 									, p_validation_mode => inv_rcv_integration_apis.G_EXISTS_OR_CREATE
 									, x_is_new_lot => l_is_new_lot
								   	, p_lot_number => l_lot_number
								   	, p_line_loc_id => l_po_line_loc_id
									, p_lot_attribute_category => l_lot_attribute_category
                                                            		, p_c_attributes_tbl => l_c_attributes_tbl
                                                            		, p_n_attributes_tbl => l_n_attributes_tbl
                                                            		, p_d_attributes_tbl => l_d_attributes_tbl
                                                			, p_grade_code => l_grade_code
                                                			, p_origination_date => l_origination_date
                                                			, p_date_code => l_date_code
                                                			, p_status_id => l_status_id
                                                			, p_change_date => l_change_date
                                                			, p_age => l_age
                                                			, p_retest_date => l_retest_date
                                                			, p_maturity_date => l_maturity_date
                                                			, p_item_size => l_item_size
                                                			, p_color => l_color
                                                			, p_volume => l_volume
                                                			, p_volume_uom => l_volume_uom
                                                			, p_place_of_origin => l_place_of_origin
                                                			, p_best_by_date => l_best_by_date
                                                			, p_length => l_length
                                                			, p_length_uom => l_length_uom
                                               				, p_recycled_content => l_recycled_content
                                                			, p_thickness => l_thickness
                                                			, p_thickness_uom => l_thickness_uom
                                                			, p_width => l_width
                                                			, p_width_uom => l_width_uom
                                                			, p_territory_code => l_territory_code
                                               	 			, p_supplier_lot_number => l_supplier_lot_number
                                                			, p_vendor_name => l_vendor_name
								   	, x_return_code => l_lot_return_code
								   	, x_return_msg => l_lot_return_msg
									);

		if(l_lot_status= FND_API.G_RET_STS_SUCCESS AND l_lot_return_code= 'F')
		then

			--Lot LOT at line LINE_NUM is invalid: ERROR_MSG
			fnd_message.set_name('POS','POS_EXASN_INVALID_LOT');
			fnd_message.set_token('LOT',l_lot_number);
			fnd_message.set_token('LINE_NUM',l_lot_ln);
			fnd_message.set_token('ERROR_MSG',l_lot_return_msg);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		elsif(l_lot_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(x_error_tbl, 'Unexpected error when validating Lot Number at line: '||l_lot_ln||':'||l_lot_return_msg, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;

		if(l_lpn is not null) then
		   	POS_ASN_CREATE_PVT.ValidateLpn(
		   				p_api_version	=> 1.0
		   				, x_return_status => l_lpn_status
		   				, p_lpn     	=> l_lpn
		   				, p_line_loc_id => l_po_line_loc_id
		   				, x_return_code => l_lpn_return_code
		   				, x_return_msg => l_lpn_return_msg
		   			);

		   	if(l_lpn_status = FND_API.G_RET_STS_SUCCESS AND l_lpn_return_code = 'F')
		   	then
				--License plate number LPN at line LINE_NUM is invalid: ERROR_MSG
				fnd_message.set_name('POS','POS_EXASN_INVALID_LPN');
				fnd_message.set_token('LPN',l_lpn);
				fnd_message.set_token('LINE_NUM',l_lot_ln);
				fnd_message.set_token('ERROR_MSG',l_lpn_return_msg);
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;
			elsif(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
				if(InsertError(x_error_tbl, 'Error while validating License Plate Number at line: '||l_lpn_ln||':'||l_lpn_return_msg, x_error_pointer)=1) then
					raise l_25errors;
				end if;
		   	end if;
		end if;

		l_c_attributes_tbl.trim(20);
		l_d_attributes_tbl.trim(10);
		l_n_attributes_tbl.trim(10);

	end loop;
	close l_checkLot_csr;


	open l_checkSerial_csr;
	loop
	fetch l_checkSerial_csr into
		l_ser_ln,
		l_fm_serial,
		l_to_serial,
		l_ser_qty,
		l_lpn,
		l_po_line_loc_id,
		l_lot_number;
	exit when l_checkSerial_csr%NOTFOUND;
	   	POS_ASN_CREATE_PVT.ValidateSerialRange(
   		   										p_api_version	=> 1.0
   		   										, x_return_status => l_ser_status
   		   										, p_fm_serial_number => l_fm_serial
   		   										, p_to_serial_number => l_to_serial
   		   										, p_quantity => l_ser_qty
   		   										, p_lot_number	=> l_lot_number
   		   										, p_line_loc_id => l_po_line_loc_id
   		   										, x_return_code	=> l_ser_return_code
   		   										, x_return_msg	 => l_ser_return_msg);

	   	if(l_ser_status = FND_API.G_RET_STS_SUCCESS and l_ser_return_code = 'F')
	   	then
	   		--Serial range (From FMSERIAL to TOSERIAL with quantity QTY) at line LINE_NUM is invalid: ERROR_MSG
	   		fnd_message.set_name('POS','POS_EXASN_INVALID_SER');
			fnd_message.set_token('FMSERIAL',l_fm_serial);
			fnd_message.set_token('TOSERIAL',l_to_serial);
			fnd_message.set_token('QTY',l_ser_qty);
			fnd_message.set_token('LINE_NUM',l_ser_ln);
			fnd_message.set_token('ERROR_MSG',l_ser_return_msg);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		elsif(l_ser_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(x_error_tbl, 'Error while validating Serial Range/Quantity at line: '||l_ser_ln||':'||l_ser_return_msg, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;
		if(l_lpn is not null) then
		   	POS_ASN_CREATE_PVT.ValidateLpn(
		   				p_api_version	=> 1.0
		   				, x_return_status => l_lpn_status
		   				, p_lpn     	=> l_lpn
		   				, p_line_loc_id => l_po_line_loc_id
		   				, x_return_code => l_lpn_return_code
		   				, x_return_msg => l_lpn_return_msg
		   			);

		   	if(l_lpn_status = FND_API.G_RET_STS_SUCCESS AND l_lpn_return_code = 'F')
		   	then
				--License plate number LPN at line LINE_NUM is invalid: ERROR_MSG
				fnd_message.set_name('POS','POS_EXASN_INVALID_LPN');
				fnd_message.set_token('LPN',l_lpn);
				fnd_message.set_token('LINE_NUM',l_ser_ln);
				fnd_message.set_token('ERROR_MSG',l_lpn_return_msg);
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;
			elsif(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
				if(InsertError(x_error_tbl, 'Error while validating License Plate Number at line: '||l_lpn_ln||':'||l_lpn_return_msg, x_error_pointer)=1) then
					raise l_25errors;
				end if;
		   	end if;
		end if;



	end loop;
	close l_checkSerial_csr;

	open l_checkLpn_csr;
	loop
	fetch l_checkLpn_csr into
		l_lpn_ln,
		l_lpn,
		l_parent_lpn,
		l_po_line_loc_id;
	exit when l_checkLpn_csr%NOTFOUND;
	   	POS_ASN_CREATE_PVT.ValidateLpn(
	   				p_api_version	=> 1.0
	   				, x_return_status => l_lpn_status
	   				, p_lpn     	=> l_lpn
	   				, p_line_loc_id => l_po_line_loc_id
	   				, x_return_code => l_lpn_return_code
	   				, x_return_msg => l_lpn_return_msg
	   			);

	   	if(l_lpn_status = FND_API.G_RET_STS_SUCCESS AND l_lpn_return_code = 'F')
	   	then

			--License plate number LPN at line LINE_NUM is invalid: ERROR_MSG
			fnd_message.set_name('POS','POS_EXASN_INVALID_LPN');
			fnd_message.set_token('LPN',l_lpn);
			fnd_message.set_token('LINE_NUM',l_lpn_ln);
			fnd_message.set_token('ERROR_MSG',l_lpn_return_msg);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;

		elsif(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(x_error_tbl, 'Error while validating License Plate Number at line: '||l_lpn_ln||':'||l_lpn_return_msg, x_error_pointer)=1) then
				raise l_25errors;
			end if;
	   	end if;

	   	if(l_parent_lpn is not null) then
		   	POS_ASN_CREATE_PVT.ValidateLpn(
		   				p_api_version	=> 1.0
		   				, x_return_status => l_lpn_status
		   				, p_lpn     	=> l_parent_lpn
		   				, p_line_loc_id => l_po_line_loc_id
		   				, x_return_code => l_lpn_return_code
		   				, x_return_msg => l_lpn_return_msg
		   			);

		   	if(l_lpn_status = FND_API.G_RET_STS_SUCCESS AND l_lpn_return_code = 'F')
		   	then
				--Parent license plate number LPN at line LINE_NUM is invalid: ERROR_MSG
				fnd_message.set_name('POS','POS_EXASN_INVALID_PLPN');
				fnd_message.set_token('PLPN',l_parent_lpn);
				fnd_message.set_token('LINE_NUM',l_lpn_ln);
				fnd_message.set_token('ERROR_MSG',l_lpn_return_msg);
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;

			elsif(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
				if(InsertError(x_error_tbl, 'Error while validating Parent License Plate Number at line: '||l_lpn_ln||':'||l_lpn_return_msg, x_error_pointer)=1) then
					raise l_25errors;
				end if;
		   	end if;

	   	end if;

	end loop;
	close l_checkLpn_csr;
	x_return_status := 'S';
exception when l_25errors then
	x_return_status := 'E';
when others then
	x_return_status := 'U';
END ValidateLls;

procedure ValidateLines(x_return_status out nocopy varchar2,
										p_user_vendor_id_tbl in vendor_id_tbl_type,
										p_secure_by_site in varchar2,
										p_secure_by_contact in varchar2,
										x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
										x_error_pointer in out nocopy number)
IS

l_doc_num po_headers_all.segment1%type;
l_rel_num number;
l_revision_num number;
l_po_line number;
l_po_shipment number;
l_org_name hr_operating_units.name%type;
l_failSecure varchar2(1);
l_failPORelCheck varchar2(1);
l_vendor_id_not_secured varchar2(1);
l_vendor_id number;
l_ind_start number;
l_ind_end number;
l_vendor_ind number;

l_early_exp exception;
l_25errors exception;
l_error_ln number;
l_error_field varchar2(2000);
--L1: UOM
cursor l_checkUOM_csr
is
select plnt.line_number, plnt.uom
from pos_exasn_lines plnt
where not exists
(select 1 from por_unit_of_measure_lov_v puomv
where puomv.unit_of_measure = plnt.uom);

--L2: Country of Origin
cursor l_checkCountryOO_csr
is
select plnt.line_number, plnt.country_of_origin
from pos_exasn_lines plnt
where plnt.country_of_origin is not null
and not exists
(select 1 from fnd_territories_vl ftv
where ftv.territory_code = plnt.country_of_origin);


--L3/L4: Check for valid Organization Name and PO/Line/Shipment Number
cursor l_checkOrgName_csr
is
select line_number, operating_unit
from pos_exasn_lines
where org_id is null;

cursor l_checkPO_csr
is
select
	plnt.line_number,
	plnt.po_number,
	plnt.po_revision,
	plnt.po_line,
	plnt.po_shipment,
	plnt.operating_unit
from pos_exasn_lines plnt
where plnt.po_header_id is null
and plnt.po_release_num is null;

cursor l_checkREL_csr
is
select
	plnt.line_number,
	plnt.po_number,
	plnt.po_release_num,
	plnt.po_revision,
	plnt.po_shipment,
	plnt.operating_unit
from pos_exasn_lines plnt
where plnt.po_header_id is null
and plnt.po_release_num is not null;

--L5: Check for Securing Attributes
cursor l_vendors_csr
is
select line_number,vendor_id
from pos_exasn_lines;

cursor l_checkVendorSites_csr(x_user_id number)
is
select line_number
from pos_exasn_lines plnt
where not exists(
select 1
from ak_web_user_sec_attr_values
WHERE  web_user_id = x_user_id
AND    attribute_code = 'ICX_SUPPLIER_SITE_ID'
AND    attribute_application_id = 177
and number_value = plnt.vendor_site_id);

cursor l_checkVendorContacts_csr(x_user_id number)
is
select line_number
from pos_exasn_lines plnt
where not exists(
select 1
from ak_web_user_sec_attr_values
WHERE  web_user_id = x_user_id
AND    attribute_code = 'ICX_SUPPLIER_CONTACT_ID'
AND    attribute_application_id = 177
and number_value = plnt.vendor_contact_id);

--L6: Check Quantity
l_quantity number;
l_convQty number;

l_primary_qty number;
l_line_number number;
l_uom pos_exasn_lines.uom%type;
l_po_line_location_id number;
l_tolerableShipQty number;
l_item_id number;
cursor l_allLines_csr
is
select line_number, quantity, uom, po_line_location_id, item_id, header_id
from pos_exasn_lines;



--L7: Check for existing ASN with same Shipment Number
l_previous_sn pos_exasn_headers.shipment_number%type;
l_new_sn varchar2(1);
cursor l_checkExistAsn_csr
is
select line_number, shipment_number
from
(
select pht.line_number, pht.shipment_number
from pos_exasn_lines plnt,
	rcv_headers_interface rhi,
	pos_exasn_headers pht
where pht.header_id = plnt.header_id
and pht.shipment_number = rhi.shipment_num
and plnt.vendor_id = rhi.vendor_id
and nvl(plnt.vendor_site_id, -9999) = nvl(rhi.vendor_site_id, -9999)
union
select plnt.line_number, pht.shipment_number
from pos_exasn_lines plnt,
	rcv_shipment_headers rsh,
	pos_exasn_headers pht
where pht.header_id = plnt.header_id
and pht.shipment_number = rsh.shipment_num
and plnt.vendor_id = rsh.vendor_id
and nvl(plnt.vendor_site_id, -9999) = nvl(rsh.vendor_site_id, -9999))
order by line_number;



l_qty_rcv_exception_code po_line_locations_all.qty_rcv_exception_code%type;
l_header_id number;

--L8: Check for Expected Receipt Date Tolerance per PO Shipment
l_receipt_days_exception_code po_line_locations_all.receipt_days_exception_code%type;
l_exp_rec_date pos_exasn_headers.expected_receipt_date%type;

l_days_early po_line_locations_all.DAYS_EARLY_RECEIPT_ALLOWED%type;
l_days_late po_line_locations_all.DAYS_LATE_RECEIPT_ALLOWED%type;
l_due_date date;
l_header_line_number number;
l_outsourced_assembly po_line_locations_all.outsourced_assembly%type;

BEGIN
	--L1
	open l_checkUOM_csr;
	loop
	fetch l_checkUOM_csr into	l_error_ln, l_error_field;
	exit when l_checkUOM_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_QTYUOM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkUOM_csr;

	--L2
	open l_checkCountryOO_csr;
	loop
	fetch l_checkCountryOO_csr into	l_error_ln, l_error_field;
	exit when l_checkCountryOO_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_COORIGIN'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkCountryOO_csr;


	--L3: Organization Name
	update pos_exasn_lines plnt
	set plnt.org_id = (
				select hou.organization_id
				from hr_operating_units hou
				where hou.name = plnt.operating_unit);


	open l_checkOrgName_csr;
	loop
	fetch l_checkOrgName_csr into l_error_ln, l_error_field;
	exit when l_checkOrgName_csr%notfound;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_ORGUNIT'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkOrgName_csr;

	--L4: Valid Org/PO/Line/Shipment Number
	/*
	*  Bug 8390933 - removed the condition 'and pha.AUTHORIZATION_STATUS = 'APPROVED''
	*  and allows the shipments to be used to create ASN irrespective of PO status
	*  It also allows the shipments to be used for ASN, if the PO is in 'Requires Reapproval' status
	*/
	update pos_exasn_lines plnt
	set (
		po_header_id,
		po_line_id,
		po_line_location_id,
		vendor_id,
		vendor_site_id,
		vendor_contact_id,
		ship_to_org_id,
		vendor_name,
		vendor_site_code,
		rate_type,
		rate,
		rate_date,
		item_id,
		item_revision,
		unit_price,
		vendor_product_num,
		currency_code,
		primary_uom,
		ship_to_location_code,
		ship_to_location_id,
		item_description
		)
		=
		(
			select
				pha.po_header_id,
				pla.po_line_id,
				plla.line_location_id,
				pv.vendor_id,
				pvs.vendor_site_id,
				pha.vendor_contact_id,
				plla.ship_to_organization_id,
				pv.vendor_name,
				pvs.vendor_site_code,
				pha.rate_type,
				pha.rate,
				pha.rate_date,
				pla.item_id,
				pla.item_revision,
				pla.unit_price,
				pla.vendor_product_num,
				pha.currency_code,
				(SELECT MTL.PRIMARY_UNIT_OF_MEASURE
                                  FROM
				  MTL_SYSTEM_ITEMS MTL
				  WHERE
				  MTL.INVENTORY_ITEM_ID=PLA.ITEM_ID
				  AND MTL.ORGANIZATION_ID =PLLA.SHIP_TO_ORGANIZATION_ID
				),
				nvl(hrl.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,20)),
				plla.ship_to_location_id,
				pla.item_description

			from
				po_headers_all pha,
				po_lines_all pla,
				po_line_locations_all plla,
				po_vendors pv,
				po_vendor_sites_all pvs,
				hr_locations_all_tl hrl,
				hz_locations hz
			where pha.segment1 = plnt.po_number
			and pha.org_id = plnt.org_id
			and pha.revision_num = (SELECT pha.revision_num
 	                                                   FROM po_headers_archive_all phaa,po_headers_all pha
 	                                                  WHERE pha.segment1 = plnt.po_number
 	                                                    AND pha.po_header_id =phaa.po_header_id (+)
 	                                                    AND phaa.latest_external_flag(+) ='Y'
 	                                                    AND phaa.revision_num =plnt.po_revision
							    AND pha.org_id = plnt.org_id)
			and pha.po_header_id = pla.po_header_id
			and pla.line_num = plnt.po_line
			and pla.po_line_id = plla.po_line_id
			and plla.shipment_num = plnt.po_shipment
			and pv.vendor_id = pha.vendor_id
			and pvs.vendor_site_id = pha.vendor_site_id
			and hrl.location_id(+) = plla.ship_to_location_id
			and hrl.LANGUAGE(+) = USERENV('LANG')
			and hz.location_id(+) = plla.ship_to_location_id
			and pha.type_lookup_code = 'STANDARD'
			/* and pha.AUTHORIZATION_STATUS = 'APPROVED' */
			and NVL(plla.approved_flag, 'N') = 'Y'
			and NVL(plla.CANCEL_FLAG, 'N') = 'N'
			and NVL(pha.FROZEN_FLAG, 'N') = 'N'
			and NVL(pha.CONSIGNED_CONSUMPTION_FLAG, 'N') <> 'Y'
			and NVL(plla.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING', 'CANCELLED')
		)
	where org_id is not null
	and po_release_num is null;

	select count(1) into l_error_ln from pos_exasn_lines where po_line_location_id is null;


	update pos_exasn_lines plnt
	set (
		po_header_id,
		po_release_id,
		po_line_id,
		po_line_location_id,
		vendor_id,
		vendor_site_id,
		vendor_contact_id,
		ship_to_org_id,
		vendor_name,
		vendor_site_code,
		rate_type,
		rate,
		rate_date,
		item_id,
		item_revision,
		unit_price,
		vendor_product_num,
		currency_code,
		primary_uom,
		ship_to_location_code,
		ship_to_location_id,
		item_description
		)
		=
		(
			select
				pha.po_header_id,
				pra.po_release_id,
				pla.po_line_id,
				plla.line_location_id,
				pv.vendor_id,
				pvs.vendor_site_id,
				pha.vendor_contact_id,
				plla.ship_to_organization_id,
				pv.vendor_name,
				pvs.vendor_site_code,
				pha.rate_type,
				pha.rate,
				pha.rate_date,
				pla.item_id,
				pla.item_revision,
				pla.unit_price,
				pla.vendor_product_num,
				pha.currency_code,
				(SELECT MTL.PRIMARY_UNIT_OF_MEASURE
                                  FROM
				  MTL_SYSTEM_ITEMS MTL
				  WHERE
				  MTL.INVENTORY_ITEM_ID=PLA.ITEM_ID
				  AND MTL.ORGANIZATION_ID =PLLA.SHIP_TO_ORGANIZATION_ID
				),
				nvl(hrl.location_code, substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,20)),
				plla.ship_to_location_id,
				pla.item_description
			from
				po_headers_all pha,
				po_releases_all pra,
				po_lines_all pla,
				po_line_locations_all plla,
				po_vendors pv,
				po_vendor_sites_all pvs,
				hr_locations_all_tl hrl,
				hz_locations hz
			where pha.segment1 = plnt.po_number
			and pha.org_id = plnt.org_id
			and pha.po_header_id = pra.po_header_id
			and pra.release_num = plnt.po_release_num
			and pra.revision_num = (SELECT pra.revision_num
                                                  FROM po_releases_archive_all praa,
                                                       po_releases_all pra,
                                                       po_headers_all pha
                                                 WHERE pra.release_num = plnt.po_release_num
                                                   AND pra.po_release_id =praa.po_release_id (+)
                                                   AND praa.latest_external_flag(+) ='Y'
                                                   AND praa.revision_num =plnt.po_revision
                                                   AND pra.po_header_id=pha.po_header_id
                                                   AND pha.segment1=plnt.po_number
						   AND pha.org_id = plnt.org_id)
			and pra.po_release_id = plla.po_release_id
			and plla.shipment_num = plnt.po_shipment
			and pha.vendor_id = pv.vendor_id
			and pha.vendor_site_id = pvs.vendor_site_id
			and hrl.location_id(+) = plla.ship_to_location_id
			and hrl.LANGUAGE(+) = USERENV('LANG')
			and hz.location_id(+) = plla.ship_to_location_id
			and pla.po_line_id = plla.po_line_id
			/* and pra.AUTHORIZATION_STATUS = 'APPROVED' */
			and NVL(plla.approved_flag, 'N') = 'Y'
			and NVL(plla.CANCEL_FLAG, 'N') = 'N'
			and NVL(pra.FROZEN_FLAG, 'N') = 'N'
			and NVL(pra.CONSIGNED_CONSUMPTION_FLAG, 'N') <> 'Y'
			and NVL(plla.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING', 'CANCELLED')

		)
	where org_id is not null
	and po_release_num is not null;

        l_failPORelCheck := 'F';
	open l_checkPO_csr;
	loop
	fetch l_checkPO_csr into
		l_error_ln,
		l_doc_num,
		l_revision_num,
		l_po_line,
		l_po_shipment,
		l_org_name;
	exit when l_checkPO_csr%NOTFOUND;
                l_failPORelCheck := 'T';
		fnd_message.set_name('POS','POS_EXASN_PO_NOEXIST');
		fnd_message.set_token('DOC_NUM',l_doc_num);
		fnd_message.set_token('REV_NUM',l_revision_num);
		fnd_message.set_token('LINENUM',l_po_line);
		fnd_message.set_token('SHIP_NUM',l_po_shipment);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		fnd_message.set_token('OP_UNIT',l_org_name);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkPO_csr;

	open l_checkREL_csr;
	loop
	fetch l_checkREL_csr into
		l_error_ln,
		l_doc_num,
		l_rel_num,
		l_revision_num,
		l_po_shipment,
		l_org_name;
	exit when l_checkREL_csr%NOTFOUND;
                l_failPORelCheck := 'T';
		fnd_message.set_name('POS','POS_EXASN_REL_NO_EXIST');
                fnd_message.set_token('DOC_NUM',l_doc_num);
		fnd_message.set_token('REL_NUM',l_rel_num);
		fnd_message.set_token('REV_NUM',l_revision_num);
		fnd_message.set_token('SHIP_NUM',l_po_shipment);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		fnd_message.set_token('OP_UNIT',l_org_name);
		if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkREL_csr;

        if(l_failPORelCheck = 'T') then
          raise l_early_exp;
        end if;

	l_failSecure := 'F';

	--The following code segment validates all lines to make sure their vendor ids  --are in the set of all supplier defined secured attributes for org id,
  --ICX_SUPPLIER_ORG_ID

  --For each vendor id of each line, we check that against the retrieved set
  --of secured org id attributes to make sure it is in the set. Otherwise,
  --throw an error message
	OPEN l_vendors_csr;
	LOOP
		FETCH l_vendors_csr into l_error_ln, l_vendor_id;
		EXIT WHEN l_vendors_csr%NOTFOUND;

		  l_ind_start		:= p_user_vendor_id_tbl.first();
		  l_ind_end			:= p_user_vendor_id_tbl.last();
			l_vendor_id_not_secured := 'T';

      --make sure all vendor ids are secured
			FOR l_vendor_ind IN l_ind_start .. l_ind_end
			LOOP

				IF(l_vendor_id = p_user_vendor_id_tbl(l_vendor_ind)) THEN
          l_vendor_id_not_secured := 'F';
				END IF;

			END LOOP;

			IF(l_vendor_id_not_secured = 'T') THEN

				IF(FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
					FND_LOG.string( LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
													MODULE =>'pos.plsql.pos_asn_create_pvt.ValidateLines',
													MESSAGE => 'Line : ' || l_error_ln || 'Vendor Id: ' ||
                                     l_vendor_id||' is not secured');
				END IF;

				l_failSecure := 'T';
				fnd_message.set_name('POS','POS_EXASN_NOT_SEC');
				fnd_message.set_token('LINE_NUM',l_error_ln);
				IF(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) THEN
					raise l_25errors;
				END IF;
			END IF;

	END LOOP;
	CLOSE l_vendors_csr;


	if(p_secure_by_site = 'T') then
		open l_checkVendorSites_csr(fnd_global.user_id);
		loop
		fetch l_checkVendorSites_csr into l_error_ln;
		exit when l_checkVendorSites_csr%NOTFOUND;
			l_failSecure := 'T';
			fnd_message.set_name('POS','POS_EXASN_NOT_SEC');
			fnd_message.set_token('LINE_NUM',l_error_ln);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		end loop;
		close l_checkVendorSites_csr;
	end if;

	if(p_secure_by_contact = 'T') then
		open l_checkVendorContacts_csr(fnd_global.user_id);
		loop
		fetch l_checkVendorContacts_csr into l_error_ln;
		exit when l_checkVendorContacts_csr%NOTFOUND;
			l_failSecure := 'T';
			fnd_message.set_name('POS','POS_EXASN_NOT_SEC');
			fnd_message.set_token('LINE_NUM',l_error_ln);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		end loop;
		close l_checkVendorContacts_csr;
	end if;

	if(l_failSecure = 'T') then
		raise l_early_exp;
	end if;

	--L6+L8 (to be done before creating new Lines, because we cannot split up the shipments into multiple RTIs and then do validations

	open l_allLines_csr;
	loop
	fetch l_allLines_csr into
		l_line_number,
		l_quantity,
		l_uom,
		l_po_line_location_id,
		l_item_id,
		l_header_id;
	exit when l_allLines_csr%NOTFOUND;
		select
			PLL.qty_rcv_exception_code,
			PLL.receipt_days_exception_code,
			PLL.DAYS_EARLY_RECEIPT_ALLOWED,
			PLL.DAYS_LATE_RECEIPT_ALLOWED,
			NVL(PLL.PROMISED_DATE,PLL.NEED_BY_DATE),
            PLL.outsourced_assembly
		into
			l_qty_rcv_exception_code,
			l_receipt_days_exception_code,
			l_days_early,
			l_days_late,
			l_due_date,
            l_outsourced_assembly
		from po_line_locations_all PLL
		where line_location_id = l_po_line_location_id;

		if(l_qty_rcv_exception_code = 'REJECT') then

			l_primary_qty := getConvertedQuantity(l_po_line_location_id, l_quantity, l_uom);

			l_tolerableShipQty := POS_CREATE_ASN.getTolerableShipmentQuantity(l_po_line_location_id);

			if(l_primary_Qty = -1) then
	            fnd_message.set_name('POS','POS_EXASN_EXCEPT_UOM');
				--An exception occured when trying to validate the quantity at line LINE_NUM. Please make sure the UOM you provided on that line is valid for the corresponding item.
				fnd_message.set_token('LINE_NUM',l_line_number);
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;
			elsif(l_tolerableShipQty < l_primary_qty ) then

				fnd_message.set_name('POS','POS_EXASN_QTY_GRT_REM');
				fnd_message.set_token('QTY',l_quantity);
				fnd_message.set_token('LINE_NUM',l_line_number);
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;
			end if;
		end if;

		if(l_receipt_days_exception_code = 'REJECT') then
			select
				expected_receipt_date,
				line_number
			into
				l_exp_rec_date,
				l_header_line_number
			from pos_exasn_headers
			where header_id = l_header_id;

			if(l_exp_rec_date > l_due_date+l_days_late OR l_exp_rec_date < l_due_date-l_days_early) then
				fnd_message.set_name('POS','POS_EXASN_ERDATE_TOL');
				fnd_message.set_token('HDR_LINE_NUM',l_header_line_number);
				fnd_message.set_token('LINE_NUM',l_line_number);
				--the expected receipt date defined in line HDR_LINE_NUM will violate the tolerance for PO Shipment at line LINE_NUM
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
					raise l_25errors;
				end if;
			end if;
		end if;

        if ( l_outsourced_assembly = 1 ) then
                fnd_message.set_name('POS','POS_EXASN_ERR_SHIKYU');
                fnd_message.set_token('LINE_NUM',l_line_number);
                -- Shipments can not be created using Outsourced assembly items
                if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
                    raise l_25errors;
                end if;
         end if;
	end loop;
	close l_allLines_csr;

	--L7

	open l_checkExistAsn_csr;
	loop
	fetch l_checkExistAsn_csr into l_error_ln, l_error_field;
	exit when l_checkExistAsn_csr%NOTFOUND;

		if(l_previous_sn is null OR l_previous_sn <> l_error_field) then
			l_new_sn := 'T';
			l_previous_sn := l_error_field;
		else
			l_new_sn := 'F';
		end if;

		if(l_new_sn = 'T') then
	        fnd_message.set_name('POS','POS_EXASN_DUPE_SHIP');
			--Shipment number SHIP_NUM at line LINE_NUM is invalid because there is an existing shipment notice with the same vendor, vendor site, and shipment number.
			fnd_message.set_token('LINE_NUM',l_error_ln);
			fnd_message.set_token('SHIP_NUM',l_error_field);
			if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;

	end loop;
	close l_checkExistAsn_csr;

	x_return_status := 'S';
exception when l_early_exp then
	x_return_status := 'E';
when l_25errors then
	x_return_status := 'E';
when others then
	x_return_status := 'U';
END ValidateLines;


procedure ValidateHeaders(x_return_status out nocopy varchar2,
											p_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
											p_error_pointer in out nocopy number)
IS
l_error_ln number;
l_error_field varchar2(200);
l_25errors exception;


--H1: Freight Carrier Code (TO BE DONE IN FixHeadersAndLines, because we'll need pht.ship_to_org_id)

--H2: GROSS WEIGHT UOM
cursor l_checkGrossWtUOM_csr
is
select pht.line_number, pht.gross_weight_uom
from pos_exasn_headers pht
where pht.gross_weight_uom is not null
and not exists
(select 1 from por_unit_of_measure_lov_v puomv
where puomv.unit_of_measure = pht.gross_weight_uom);


--H3: NET WEIGHT UOM
cursor l_checkNetWtUOM_csr
is
select pht.line_number, pht.net_weight_uom
from pos_exasn_headers pht
where pht.net_weight_uom is not null
and not exists
(select 1 from por_unit_of_measure_lov_v puomv
where puomv.unit_of_measure = pht.net_weight_uom);

--H4: TAR WEIGHT UOM
cursor l_checkTarWtUOM_csr
is
select pht.line_number, pht.tar_weight_uom
from pos_exasn_headers pht
where pht.tar_weight_uom is not null
and not exists
(select 1 from por_unit_of_measure_lov_v puomv
where puomv.unit_of_measure = pht.tar_weight_uom);

--H5: FREIGHT TERMS
cursor l_checkFreightTerms_csr
is
select pht.line_number, pht.freight_terms
from pos_exasn_headers pht
where pht.freight_terms is not null
and not exists
(select 1 from po_lookup_codes plc
where plc.lookup_type = 'FREIGHT TERMS'and sysdate < nvl(plc.inactive_date, sysdate + 1)
and plc.lookup_code = pht.freight_terms);

--H7: SHIPMENT DATE has to be < SYSDATE
cursor l_checkShipDate_csr
is
select pht.line_number, shipment_date
from pos_exasn_headers pht
where shipment_date > sysdate;

--H8: INVOICE PAYMENT TERMS
cursor l_checkInvPT_csr
is
select pht.line_number, pht.payment_terms
from pos_exasn_headers pht
where pht.payment_terms is not null
and not exists
(select 1 from ap_terms_val_v av
where av.name = pht.payment_terms);

--H9: Bad if expected receipt Date is BEFORE Shipment Date
cursor l_checkER_Ship_csr
is
select pht.line_number
from pos_exasn_headers pht
where expected_receipt_date < shipment_date;



BEGIN

	--H2
	open l_checkGrossWtUOM_csr;
	loop
	fetch l_checkGrossWtUOM_csr into	l_error_ln, l_error_field;
	exit when l_checkGrossWtUOM_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_GWUOM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkGrossWtUOM_csr;

        --Convert Gross Weight UOM to code
        update pos_exasn_headers
        set gross_weight_uom  =
        (select puomv.uom_code
         from por_unit_of_measure_lov_v puomv
         where gross_weight_uom is not null
         and gross_weight_uom = puomv.unit_of_measure);

	--H3
	open l_checkNetWtUOM_csr;
	loop
	fetch l_checkNetWtUOM_csr into	l_error_ln, l_error_field;
	exit when l_checkNetWtUOM_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_NWUOM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkNetWtUOM_csr;

        --Convert Net Weight UOM to code
        update pos_exasn_headers
        set net_weight_uom  =
        (select puomv.uom_code
         from por_unit_of_measure_lov_v puomv
         where net_weight_uom is not null
         and net_weight_uom = puomv.unit_of_measure);

	--H4
	open l_checkTarWtUOM_csr;
	loop
	fetch l_checkTarWtUOM_csr into	l_error_ln, l_error_field;
	exit when l_checkTarWtUOM_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_TWUOM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkTarWtUOM_csr;

        --Convert Tar Weight UOM to code
        update pos_exasn_headers
        set tar_weight_uom  =
        (select puomv.uom_code
         from por_unit_of_measure_lov_v puomv
         where tar_weight_uom is not null
         and tar_weight_uom = puomv.unit_of_measure);


	--H5
	open l_checkFreightTerms_csr;
	loop
	fetch l_checkFreightTerms_csr into	l_error_ln, l_error_field;
	exit when l_checkFreightTerms_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_FRTERM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkFreightTerms_csr;

	--H7
	open l_checkShipDate_csr;
	loop
	fetch l_checkShipDate_csr into	l_error_ln, l_error_field;
	exit when l_checkShipDate_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_BAD_SHP_DATE');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkShipDate_csr;

	--H8
	open l_checkInvPT_csr;
	loop
	fetch l_checkInvPT_csr into	l_error_ln, l_error_field;
	exit when l_checkInvPT_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_PAYTERM'));
		fnd_message.set_token('LOV_VALUE',l_error_field);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkInvPT_csr;

	--H9
	open l_checkER_Ship_csr;
	loop
	fetch l_checkER_Ship_csr into	l_error_ln;
	exit when l_checkER_Ship_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_ERDATE_SDATE');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(p_error_tbl, fnd_message.get, p_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkER_Ship_csr;

	x_return_status := 'S';
exception when l_25errors then
	x_return_status := 'E';
when others then
	x_return_status := 'U';
end ValidateHeaders;


procedure UpdateLinesAndLls(x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
												l_error_pointer in out NOCOPY number)
IS
l_uom pos_exasn_lines.uom%type;
l_po_line_location_id number;
l_tolerableShipQty number;
l_item_id number;
l_quantity number;
l_convQty number;
l_primary_qty number;
l_line_number number;
l_line_id number;

cursor l_allLines_csr
is
select line_number, quantity, uom, po_line_location_id, item_id, line_id
from pos_exasn_lines;

BEGIN
	--  Update All lines with Primary Quantity and Invoiced Quantity
	open l_allLines_csr;
	loop
	fetch l_allLines_csr into l_line_number,
								l_quantity,
								l_uom,
								l_po_line_location_id,
								l_item_id,
								l_line_id;
	exit when l_allLines_csr%NOTFOUND;

		l_primary_qty := getConvertedQuantity(l_po_line_location_id, l_quantity, l_uom);

		if(l_primary_Qty = -1) then
			if(InsertError(x_error_tbl, 'Unexpected Error while finding primary quantity for new lines', l_error_pointer)=1) then
				null;
			end if;
		else

			update pos_exasn_lines
			set primary_quantity = l_primary_qty
			where line_id = l_line_id;

			update pos_exasn_lines
			set invoiced_quantity = POS_QUANTITIES_S.get_invoice_qty
						(l_po_line_location_id,
                             l_uom,
                             l_item_id,
                             l_quantity)
			where line_id = l_line_id;
		end if;
	end loop;
	close l_allLines_csr;



	update pos_exasn_lines plnt
	set lpn_group_id = (select pht.lpn_group_id
						from pos_exasn_headers pht
						where pht.header_id = plnt.header_id)
	where
	(
		plnt.lls_code in ('LAS','LOT')

		and exists(
		select 1 from pos_exasn_lots plot
		where plot.line_id = plnt.line_id
		and plot.license_plate_number is not null))
	or
	(
		plnt.lls_code = 'LPN'
		and exists(
		select 1 from pos_exasn_lpns plpn
		where plpn.line_id = plnt.line_id
		and plpn.quantity is not null))
	or
	(
		plnt.lls_code = 'SER'
		and exists(
		select 1 from pos_exasn_serials pst
		where pst.line_id = plnt.line_id
		and pst.license_plate_number is not null));



	update pos_exasn_lots plot
	set (plot.product_transaction_id, plot.uom) =(select plnt.interface_transaction_id, plnt.uom
												from pos_exasn_lines plnt
												where plnt.header_id = plot.header_id
												and plnt.line_id = plot.line_id);


	update pos_exasn_serials pst
	set (pst.product_transaction_id) = (select plnt.interface_transaction_id
												from pos_exasn_lines plnt
												where plnt.header_id = pst.header_id
												and plnt.line_id = pst.line_id);

END UpdateLinesAndLls;


procedure CreateRTI4Ser
is
cursor 	l_distinctLpn_ser_csr(x_header_id number, x_line_id number)
is
select
distinct
license_plate_number
from pos_exasn_serials
where header_id = x_header_id
and line_id = x_line_id
and lot_id = 0;
--assuming lot_id = 0 ==> SER items

cursor l_SerLines_csr
is
select
	plnt.header_id,
	plnt.line_id,
	plnt.quantity
from pos_exasn_lines plnt
where lls_code = 'SER';
/*
and (select count(distinct nvl(license_plate_number,'null'))
	from pos_exasn_serials pst
	where pst.line_id = plnt.line_id) >1;
*/
l_ln_header_id number;

l_first_ser varchar2(1);

l_ln_quantity number;
l_total_ser_qty number;
l_ser_lpn varchar2(60);
l_ser_lpn_sum number;
l_new_line number;
l_remain_qty number;

l_line_id number;

begin
	select max(line_id)+1 into l_new_line from pos_exasn_lines;

	open l_SerLines_csr;
	loop
	fetch l_SerLines_csr into
		l_ln_header_id,
		l_line_id,
		l_ln_quantity;
	exit when l_SerLines_csr%NOTFOUND;
		l_first_Ser := 'T';
		open l_distinctLpn_ser_csr(l_ln_header_id, l_line_id);
		loop
		fetch l_distinctLpn_ser_csr into
			l_ser_lpn;
		exit when l_distinctLpn_ser_csr%NOTFOUND;
			if(l_first_ser = 'T') then
				l_first_ser := 'F';
				update pos_exasn_lines
				set license_plate_number = l_ser_lpn
				where line_id = l_line_id;

 				if(l_ser_lpn is null) then
					update pos_exasn_lines plnt
					set plnt.quantity =
						(select sum(quantity)
						from pos_exasn_serials pst
						where pst.header_id = plnt.header_id
						and pst.line_id = plnt.line_id
						and pst.license_plate_number is null)
					where plnt.line_id = l_line_id;
				else
					update pos_exasn_lines plnt
					set plnt.quantity =
						(select sum(quantity)
						from pos_exasn_serials pst
						where pst.header_id = plnt.header_id
						and pst.line_id = plnt.line_id
						and pst.license_plate_number = l_ser_lpn)
					where plnt.line_id = l_line_id;
				end if;
			else
				if(l_ser_lpn is null) then
					select sum(quantity)
					into l_ser_lpn_sum
					from pos_exasn_serials
					where header_id = l_ln_header_id
					and line_id = l_line_id
					and license_plate_number is null;
				else
					select sum(quantity)
					into l_ser_lpn_sum
					from pos_exasn_serials
					where header_id = l_ln_header_id
					and line_id = l_line_id
					and license_plate_number = l_ser_lpn;
				end if;

				CreateNewLine(l_ser_lpn_sum, l_ser_lpn, l_new_line, l_line_id);

				if(l_ser_lpn is null) then
					update pos_exasn_serials
					set line_id = l_new_line
					where line_id = l_line_id
					and license_plate_number is null;
				else
					update pos_exasn_serials
					set line_id = l_new_line
					where line_id = l_line_id
					and license_plate_number = l_ser_lpn;
				end if;

				l_new_line := l_new_line + 1;

			end if;
		end loop;
		close l_distinctLpn_ser_csr;

		select sum(quantity)
		into l_total_ser_qty
		from pos_exasn_serials
		where header_id = l_ln_header_id
		and line_id >= l_line_id;

		if(l_total_ser_qty < l_ln_quantity) then
			l_remain_qty := l_ln_quantity - l_total_ser_qty;
			--Create Extra Line for the remaining Quantity with NO Serial information
			CreateNewLine(l_remain_qty, null, l_new_line, l_line_id);
			l_new_line := l_new_line + 1;
		end if;
	end loop;
	close l_SerLines_csr;
	/*
	update pos_exasn_lines plnt
	set license_plate_number = (select distinct pst2.license_plate_number
								from pos_exasn_serials pst2
								where pst2.line_id = plnt.line_id
								and pst2.license_plate_number is not null)
	where lls_code = 'SER'
	and (select count(distinct pst.license_plate_number)
		from pos_exasn_serials pst
		where pst.line_id = plnt.line_id
		and pst.license_plate_number is not null) = 1;
		*/
end CreateRTI4Ser;


procedure CreateRTI4Lpn
is
cursor 	l_distinctLpn_csr(x_header_id number, x_line_id number)
is
select
distinct
license_plate_number
from pos_exasn_lpns
where header_id = x_header_id
and line_id = x_line_id
and quantity is not null;

cursor l_LpnLines_ML_csr
is
select
	plnt.header_id,
	plnt.line_id,
	plnt.quantity
from pos_exasn_lines plnt
where lls_code = 'LPN';
/*
and (select count(distinct nvl(license_plate_number,'null'))
	from pos_exasn_lpns plpn
	where plpn.line_id = plnt.line_id
	and quantity is null) >1;
	*/
l_ln_header_id number;

l_first_lpn varchar2(1);

l_ln_quantity number;
l_total_lpn_qty number;
l_lpn varchar2(60);
l_lpn_sum number;
l_new_line number;
l_remain_qty number;

l_line_id number;

begin
	select max(line_id)+1 into l_new_line from pos_exasn_lines;

	open l_LpnLines_ML_csr;
	loop
	fetch l_LpnLines_ML_csr into
		l_ln_header_id,
		l_line_id,
		l_ln_quantity;
	exit when l_LpnLines_ML_csr%NOTFOUND;
		l_first_lpn := 'T';
		open l_distinctLpn_csr(l_ln_header_id, l_line_id);
		loop
		fetch l_distinctLpn_csr into
			l_lpn;
		exit when l_distinctLpn_csr%NOTFOUND;
			if(l_first_lpn = 'T') then
				l_first_lpn := 'F';
				update pos_exasn_lines
				set license_plate_number = l_lpn
				where line_id = l_line_id;

				update pos_exasn_lines plnt
				set plnt.quantity = (select plpn.quantity
								from pos_exasn_lpns plpn
								where plpn.header_id = plnt.header_id
								and plpn.line_id = plnt.line_id
								and plpn.license_plate_number = l_lpn
								and plpn.quantity is not null)
				where plnt.line_id = l_line_id;
			else

				--Get LPN quantity for the the new Line
				select plpn.quantity into l_lpn_sum
                                from pos_exasn_lpns plpn
                                where plpn.license_plate_number = l_lpn
                                and plpn.header_id = l_ln_header_id
                                and plpn.line_id = l_line_id
                                and plpn.quantity is not null;

				CreateNewLine(l_lpn_sum, l_lpn, l_new_line, l_line_id);

				update pos_exasn_lpns
				set line_id = l_new_line
				where line_id = l_line_id
				and license_plate_number = l_lpn;


				l_new_line := l_new_line + 1;

			end if;
		end loop;
		close l_distinctLpn_csr;

		select sum(quantity)
		into l_total_lpn_qty
		from pos_exasn_lpns
		where header_id = l_ln_header_id
		and line_id >= l_line_id;

		if(l_total_lpn_qty < l_ln_quantity) then
			l_remain_qty := l_ln_quantity - l_total_lpn_qty;
			--Create Extra Line for the remaining Quantity with NO Lpn information
			CreateNewLine(l_remain_qty, null, l_new_line, l_line_id);
			l_new_line := l_new_line + 1;
		end if;
	end loop;
	close l_LpnLines_ML_csr;
	/*
	update pos_exasn_lines plnt
	set license_plate_number = (select distinct plpn2.license_plate_number
								from pos_exasn_lpns plpn2
								where plpn2.line_id = plnt.line_id
								and plpn2.license_plate_number is not null)
	where lls_code = 'LPN'
	and (select count(distinct plpn.license_plate_number)
		from pos_exasn_lpns plpn
		where plpn.line_id = plnt.line_id
		and plpn.license_plate_number is not null) = 1;
*/
end CreateRTI4Lpn;


procedure CreateRTI4Lot
is
cursor 	l_distinctLpn_lot_csr(x_header_id number, x_line_id number)
is
select
distinct
license_plate_number
from pos_exasn_lots
where header_id = x_header_id
and line_id = x_line_id;

cursor l_LotLines_ML_csr
is
select
	plnt.header_id,
	plnt.line_id,
	plnt.quantity
from pos_exasn_lines plnt
where lls_code in ('LOT','LAS');
/*
and (select count(distinct nvl(license_plate_number,'null'))
	from pos_exasn_lots plot
	where plot.line_id = plnt.line_id) >1;
	*/
l_ln_header_id number;

l_first_lot varchar2(1);

l_ln_quantity number;
l_total_lot_qty number;
l_lot_lpn varchar2(60);
l_lot_lpn_sum number;
l_new_line number;
l_remain_qty number;

l_line_id number;

begin
	select max(line_id)+1 into l_new_line from pos_exasn_lines;

	open l_LotLines_ML_csr;
	loop
	fetch l_LotLines_ML_csr into
		l_ln_header_id,
		l_line_id,
		l_ln_quantity;
	exit when l_LotLines_ML_csr%NOTFOUND;
		l_first_lot := 'T';

		open l_distinctLpn_lot_csr(l_ln_header_id, l_line_id);
		loop
		fetch l_distinctLpn_lot_csr into
			l_lot_lpn;
		exit when l_distinctLpn_lot_csr%NOTFOUND;

			if(l_first_lot = 'T') then
				l_first_lot := 'F';

				update pos_exasn_lines
				set license_plate_number = l_lot_lpn
				where line_id = l_line_id;

				if(l_lot_lpn is null) then
					update pos_exasn_lines plnt
					set plnt.quantity =
						(select sum(quantity)
						from pos_exasn_lots plot
						where plot.header_id = plnt.header_id
						and plot.line_id = plnt.line_id
						and plot.license_plate_number is null)
					where plnt.line_id = l_line_id;
				else
					update pos_exasn_lines plnt
					set plnt.quantity =
						(select sum(quantity)
						from pos_exasn_lots plot
						where plot.header_id = plnt.header_id
						and plot.line_id = plnt.line_id
						and plot.license_plate_number = l_lot_lpn)
					where plnt.line_id = l_line_id;
				end if;
			else
				if(l_lot_lpn is null) then
					select sum(quantity)
					into l_lot_lpn_sum
					from pos_exasn_lots
					where header_id = l_ln_header_id
					and line_id = l_line_id
					and license_plate_number is null;
				else
					select sum(quantity)
					into l_lot_lpn_sum
					from pos_exasn_lots
					where header_id = l_ln_header_id
					and line_id = l_line_id
					and license_plate_number = l_lot_lpn;
				end if;

				CreateNewLine(l_lot_lpn_sum, l_lot_lpn, l_new_line, l_line_id);

				if(l_lot_lpn is null) then
					update pos_exasn_lots
					set line_id = l_new_line
					where line_id = l_line_id
					and license_plate_number is null;

					update pos_exasn_serials
					set line_id = l_new_line
					where lot_id in(select lot_id
									from pos_exasn_lots
									where line_id = l_new_line
									and license_plate_number is null);

				else
					update pos_exasn_lots
					set line_id = l_new_line
					where line_id = l_line_id
					and license_plate_number = l_lot_lpn;

					update pos_exasn_serials
					set line_id = l_new_line
					where lot_id in (select lot_id
									from pos_exasn_lots
									where line_id = l_new_line
									and license_plate_number = l_lot_lpn);
				end if;

				l_new_line := l_new_line + 1;

			end if;
		end loop;
		close l_distinctLpn_lot_csr;

		select sum(quantity)
		into l_total_lot_qty
		from pos_exasn_lots
		where header_id = l_ln_header_id
		and line_id >= l_line_id;--All lines created at this moment, with line_id > l_line_id is for l_line_id

		if(l_total_lot_qty < l_ln_quantity) then

			l_remain_qty := l_ln_quantity - l_total_lot_qty;
			--Create Extra Line for the remaining Quantity with NO Lot information

			CreateNewLine(l_remain_qty, null, l_new_line, l_line_id);
			l_new_line := l_new_line + 1;
		end if;
	end loop;
	close l_LotLines_ML_csr;
/*
	update pos_exasn_lines plnt
	set license_plate_number = (select distinct plot2.license_plate_number
								from pos_exasn_lots plot2
								where plot2.line_id = plnt.line_id
								and plot2.license_plate_number is not null)
	where lls_code = 'LOT'
	and (select count(distinct plot.license_plate_number)
		from pos_exasn_lots plot
		where plot.line_id = plnt.line_id
		and plot.license_plate_number is not null) = 1;
*/
end CreateRTI4Lot;

procedure InsertIntoLLS(x_return_status out nocopy varchar2,
						p_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
						p_error_pointer in out nocopy number)
is
cursor l_allLots_csr
is
select
	plot.lot_id,
	plot.transaction_interface_id,
	plot.lot_number,
	plot.quantity,
	plot.po_line_loc_id,
	plot.uom,
	plot.license_plate_number,
	plnt.lpn_group_id,
	plot.line_number,
	plot.product_transaction_id,
	plot.vendor_id,
	plot.grade_code,
	plot.origination_date,
	plot.date_code,
	plot.status_id,
	plot.change_date,
	plot.age,
	plot.retest_date,
	plot.maturity_date,
	plot.item_size,
	plot.color,
	plot.volume,
	plot.volume_uom,
	plot.place_of_origin,
	plot.best_by_date,
	plot.length,
	plot.length_uom,
	plot.recycled_content,
	plot.thickness,
	plot.thickness_uom,
	plot.width,
	plot.width_uom,
	plot.curl_wrinkle_fold,
	plot.supplier_lot_number,
	plot.territory_code,
	plot.vendor_name,
	plot.LOT_ATTRIBUTE_CATEGORY,
	plot.CATTRIBUTE1,
	plot.CATTRIBUTE2,
	plot.CATTRIBUTE3,
	plot.CATTRIBUTE4,
	plot.CATTRIBUTE5,
	plot.CATTRIBUTE6,
	plot.CATTRIBUTE7,
	plot.CATTRIBUTE8,
	plot.CATTRIBUTE9,
	plot.CATTRIBUTE10,
	plot.CATTRIBUTE11,
	plot.CATTRIBUTE12,
	plot.CATTRIBUTE13,
	plot.CATTRIBUTE14,
	plot.CATTRIBUTE15,
	plot.CATTRIBUTE16,
	plot.CATTRIBUTE17,
	plot.CATTRIBUTE18,
	plot.CATTRIBUTE19,
	plot.CATTRIBUTE20,
	plot.DATTRIBUTE1,
	plot.DATTRIBUTE2,
	plot.DATTRIBUTE3,
	plot.DATTRIBUTE4,
	plot.DATTRIBUTE5,
	plot.DATTRIBUTE6,
	plot.DATTRIBUTE7,
	plot.DATTRIBUTE8,
	plot.DATTRIBUTE9,
	plot.DATTRIBUTE10,
	plot.NATTRIBUTE1,
	plot.NATTRIBUTE2,
	plot.NATTRIBUTE3,
	plot.NATTRIBUTE4,
	plot.NATTRIBUTE5,
	plot.NATTRIBUTE6,
	plot.NATTRIBUTE7,
	plot.NATTRIBUTE8,
	plot.NATTRIBUTE9,
	plot.NATTRIBUTE10
from pos_exasn_lots plot,
	pos_exasn_lines plnt
where plot.line_id = plnt.line_id;

cursor l_allSerials_csr
is
select
	pst.from_serial,
	pst.to_serial,
	pst.po_line_loc_id,
	pst.transaction_interface_id,
	pst.license_plate_number,
	plnt.lpn_group_id,
	pst.line_number,
	pst.product_transaction_id,
	pst.origination_date,
	pst.status_id,
	pst.territory_code,
	pst.SERIAL_ATTRIBUTE_CATEGORY,
	pst.CATTRIBUTE1,
	pst.CATTRIBUTE2,
	pst.CATTRIBUTE3,
	pst.CATTRIBUTE4,
	pst.CATTRIBUTE5,
	pst.CATTRIBUTE6,
	pst.CATTRIBUTE7,
	pst.CATTRIBUTE8,
	pst.CATTRIBUTE9,
	pst.CATTRIBUTE10,
	pst.CATTRIBUTE11,
	pst.CATTRIBUTE12,
	pst.CATTRIBUTE13,
	pst.CATTRIBUTE14,
	pst.CATTRIBUTE15,
	pst.CATTRIBUTE16,
	pst.CATTRIBUTE17,
	pst.CATTRIBUTE18,
	pst.CATTRIBUTE19,
	pst.CATTRIBUTE20,
	pst.DATTRIBUTE1,
	pst.DATTRIBUTE2,
	pst.DATTRIBUTE3,
	pst.DATTRIBUTE4,
	pst.DATTRIBUTE5,
	pst.DATTRIBUTE6,
	pst.DATTRIBUTE7,
	pst.DATTRIBUTE8,
	pst.DATTRIBUTE9,
	pst.DATTRIBUTE10,
	pst.NATTRIBUTE1,
	pst.NATTRIBUTE2,
	pst.NATTRIBUTE3,
	pst.NATTRIBUTE4,
	pst.NATTRIBUTE5,
	pst.NATTRIBUTE6,
	pst.NATTRIBUTE7,
	pst.NATTRIBUTE8,
	pst.NATTRIBUTE9,
	pst.NATTRIBUTE10
from pos_exasn_serials pst,
	pos_exasn_lines plnt
where pst.line_id = plnt.line_id;


cursor l_allLpns_csr
is
select
	plpn.license_plate_number,
	plpn.po_line_loc_id,
	plpn.parent_lpn,
	plnt.lpn_group_id,
	plpn.line_number
from pos_exasn_lpns plpn,
	pos_exasn_lines plnt
where plnt.line_id = plpn.line_id;
l_txn_intf_id number;
l_ser_intf_id number;
l_lot_number pos_exasn_lots.lot_number%type;
l_vendor_id pos_exasn_lots.vendor_id%type;
l_grade_code pos_exasn_lots.grade_code%type;
l_origination_date pos_exasn_lots.origination_date%type;
l_date_code pos_exasn_lots.date_code%type;
l_status_id pos_exasn_lots.status_id%type;
l_change_date pos_exasn_lots.change_date%type;
l_age pos_exasn_lots.age%type;
l_retest_date pos_exasn_lots.retest_date%type;
l_maturity_date pos_exasn_lots.maturity_date%type;
l_item_size pos_exasn_lots.item_size%type;
l_color pos_exasn_lots.color%type;
l_volume pos_exasn_lots.volume%type;
l_volume_uom pos_exasn_lots.volume_uom%type;
l_place_of_origin pos_exasn_lots.place_of_origin%type;
l_best_by_date pos_exasn_lots.best_by_date%type;
l_length pos_exasn_lots.length%type;
l_length_uom pos_exasn_lots.length_uom%type;
l_recycled_content pos_exasn_lots.recycled_content%type;
l_thickness pos_exasn_lots.thickness%type;
l_thickness_uom pos_exasn_lots.thickness_uom%type;
l_width pos_exasn_lots.width%type;
l_width_uom pos_exasn_lots.width_uom%type;
l_curl_wrinkle_fold pos_exasn_lots.curl_wrinkle_fold%type;
l_supplier_lot_number pos_exasn_lots.supplier_lot_number%type;
l_territory_code pos_exasn_lots.territory_code%type;
l_vendor_name pos_exasn_lots.vendor_name%type;
l_qty number;
l_po_line_loc_id number;
l_pdt_txn_id number;
l_fm_serial pos_exasn_serials.from_serial%type;
l_to_serial pos_exasn_serials.to_serial%type;
l_ser_origination_date pos_exasn_serials.origination_date%type;
l_ser_status_id pos_exasn_serials.status_id%type;
l_ser_territory_code pos_exasn_serials.territory_code%type;
l_lpn pos_exasn_lpns.license_plate_number%type;
l_parent_lpn pos_exasn_lpns.parent_lpn%type;
l_lpn_Group_id number;

l_lot_status varchar2(1);
l_lot_msg_data varchar2(2000);
l_lot_msg_count number;

l_ser_status varchar2(1);
l_ser_msg_count number;
l_ser_msg_data varchar2(2000);

l_lpn_status varchar2(1);
l_lpn_msg_count number;
l_lpn_msg_data varchar2(2000);
l_serial_txn_temp_id number;
l_txn_uom pos_exasn_lots.uom%type;
l_lot_id number;

l_25errors exception;
l_lot_ln number;
l_lpn_ln number;
l_ser_ln number;
l_LOT_ATTRIBUTE_CATEGORY 		  VARCHAR2(60);
l_SERIAL_ATTRIBUTE_CATEGORY		  VARCHAR2(60);
l_CATTRIBUTE1				  VARCHAR2(2000);
l_CATTRIBUTE2				  VARCHAR2(2000);
l_CATTRIBUTE3				  VARCHAR2(2000);
l_CATTRIBUTE4				  VARCHAR2(2000);
l_CATTRIBUTE5				  VARCHAR2(2000);
l_CATTRIBUTE6				  VARCHAR2(2000);
l_CATTRIBUTE7				  VARCHAR2(2000);
l_CATTRIBUTE8				  VARCHAR2(2000);
l_CATTRIBUTE9				  VARCHAR2(2000);
l_CATTRIBUTE10				  VARCHAR2(2000);
l_CATTRIBUTE11				  VARCHAR2(2000);
l_CATTRIBUTE12				  VARCHAR2(2000);
l_CATTRIBUTE13				  VARCHAR2(2000);
l_CATTRIBUTE14				  VARCHAR2(2000);
l_CATTRIBUTE15				  VARCHAR2(2000);
l_CATTRIBUTE16				  VARCHAR2(2000);
l_CATTRIBUTE17				  VARCHAR2(2000);
l_CATTRIBUTE18				  VARCHAR2(2000);
l_CATTRIBUTE19				  VARCHAR2(2000);
l_CATTRIBUTE20				  VARCHAR2(2000);
l_DATTRIBUTE1				  DATE;
l_DATTRIBUTE2				  DATE;
l_DATTRIBUTE3				  DATE;
l_DATTRIBUTE4				  DATE;
l_DATTRIBUTE5				  DATE;
l_DATTRIBUTE6				  DATE;
l_DATTRIBUTE7				  DATE;
l_DATTRIBUTE8				  DATE;
l_DATTRIBUTE9				  DATE;
l_DATTRIBUTE10				  DATE;
l_NATTRIBUTE1				  NUMBER;
l_NATTRIBUTE2				  NUMBER;
l_NATTRIBUTE3				  NUMBER;
l_NATTRIBUTE4				  NUMBER;
l_NATTRIBUTE5				  NUMBER;
l_NATTRIBUTE6				  NUMBER;
l_NATTRIBUTE7				  NUMBER;
l_NATTRIBUTE8				  NUMBER;
l_NATTRIBUTE9				  NUMBER;
l_NATTRIBUTE10				  NUMBER;
begin

	open l_allLots_csr;
	loop
	fetch l_allLots_csr into
		l_lot_id,
		l_txn_intf_id,
		l_lot_number,
		l_qty,
		l_po_line_loc_id,
		l_txn_uom,
		l_lpn,
		l_lpn_group_id,
		l_lot_ln,
		l_pdt_txn_id,
		l_vendor_id,
		l_grade_code,
		l_origination_date,
		l_date_code,
      	l_status_id,
		l_change_date,
		l_age,
		l_retest_date,
		l_maturity_date,
		l_item_size,
		l_color,
		l_volume,
		l_volume_uom,
		l_place_of_origin,
		l_best_by_date,
		l_length,
		l_length_uom,
		l_recycled_content,
		l_thickness,
		l_thickness_uom,
		l_width,
		l_width_uom,
		l_curl_wrinkle_fold,
		l_supplier_lot_number,
		l_territory_code,
		l_vendor_name,
		l_LOT_ATTRIBUTE_CATEGORY,
		l_CATTRIBUTE1,
		l_CATTRIBUTE2,
		l_CATTRIBUTE3,
		l_CATTRIBUTE4,
		l_CATTRIBUTE5,
		l_CATTRIBUTE6,
		l_CATTRIBUTE7,
		l_CATTRIBUTE8,
		l_CATTRIBUTE9,
		l_CATTRIBUTE10,
		l_CATTRIBUTE11,
		l_CATTRIBUTE12,
		l_CATTRIBUTE13,
		l_CATTRIBUTE14,
		l_CATTRIBUTE15,
		l_CATTRIBUTE16,
		l_CATTRIBUTE17,
		l_CATTRIBUTE18,
		l_CATTRIBUTE19,
		l_CATTRIBUTE20,
		l_DATTRIBUTE1,
		l_DATTRIBUTE2,
		l_DATTRIBUTE3,
		l_DATTRIBUTE4,
		l_DATTRIBUTE5,
		l_DATTRIBUTE6,
		l_DATTRIBUTE7,
		l_DATTRIBUTE8,
		l_DATTRIBUTE9,
		l_DATTRIBUTE10,
		l_NATTRIBUTE1,
		l_NATTRIBUTE2,
		l_NATTRIBUTE3,
		l_NATTRIBUTE4,
		l_NATTRIBUTE5,
		l_NATTRIBUTE6,
		l_NATTRIBUTE7,
		l_NATTRIBUTE8,
		l_NATTRIBUTE9,
		l_NATTRIBUTE10;
	exit when l_allLots_csr%NOTFOUND;

		pos_asn_create_pvt.insert_mtli(
			p_api_version => 1.0
			, x_return_status => l_lot_status
			, x_msg_count => l_lot_msg_count
			, x_msg_data => l_lot_msg_data
			, p_transaction_interface_id => l_txn_intf_id
			, p_lot_number => l_lot_number
			, p_transaction_quantity => l_qty
			, p_transaction_uom => l_txn_uom
			, p_po_line_loc_id => l_po_line_loc_id
			, x_serial_transaction_temp_id => l_serial_txn_temp_id
			, p_product_transaction_id  => l_pdt_txn_id
			, p_vendor_id => l_vendor_id
		    	, p_grade_Code => l_grade_code
			, p_origination_date => l_origination_date
			, p_date_code => l_date_code
      		, p_status_id => l_status_id
			, p_change_date => l_change_date
			, p_age => l_age
			, p_retest_date => l_retest_date
			, p_maturity_date => l_maturity_date
			, p_item_size => l_item_size
			, p_color => l_color
			, p_volume => l_volume
			, p_volume_uom => l_volume_uom
			, p_place_of_origin => l_place_of_origin
			, p_best_by_date => l_best_by_date
			, p_length => l_length
			, p_length_uom => l_length_uom
			, p_recycled_content => l_recycled_content
			, p_thickness => l_thickness
			, p_thickness_uom => l_thickness_uom
			, p_width => l_width
			, p_width_uom => l_width_uom
			, p_curl_wrinkle_fold => l_curl_wrinkle_fold
			, p_supplier_lot_number => l_supplier_lot_number
			, p_territory_code => l_territory_code
			, p_vendor_name => l_vendor_name
			, p_lot_attribute_category => l_LOT_ATTRIBUTE_CATEGORY
			, p_c_attribute1 => l_CATTRIBUTE1
			, p_c_attribute2 => l_CATTRIBUTE2
			, p_c_attribute3 => l_CATTRIBUTE3
			, p_c_attribute4 => l_CATTRIBUTE4
			, p_c_attribute5 => l_CATTRIBUTE5
			, p_c_attribute6 => l_CATTRIBUTE6
			, p_c_attribute7 => l_CATTRIBUTE7
			, p_c_attribute8 => l_CATTRIBUTE8
			, p_c_attribute9 => l_CATTRIBUTE9
			, p_c_attribute10 => l_CATTRIBUTE10
			, p_c_attribute11 => l_CATTRIBUTE11
			, p_c_attribute12 => l_CATTRIBUTE12
			, p_c_attribute13 => l_CATTRIBUTE13
			, p_c_attribute14 => l_CATTRIBUTE14
			, p_c_attribute15 => l_CATTRIBUTE15
			, p_c_attribute16 => l_CATTRIBUTE16
			, p_c_attribute17 => l_CATTRIBUTE17
			, p_c_attribute18 => l_CATTRIBUTE18
			, p_c_attribute19 => l_CATTRIBUTE19
			, p_c_attribute20 => l_CATTRIBUTE20
			, p_d_attribute1 => l_DATTRIBUTE1
			, p_d_attribute2 => l_DATTRIBUTE2
			, p_d_attribute3 => l_DATTRIBUTE3
			, p_d_attribute4 => l_DATTRIBUTE4
			, p_d_attribute5 => l_DATTRIBUTE5
			, p_d_attribute6 => l_DATTRIBUTE6
			, p_d_attribute7 => l_DATTRIBUTE7
			, p_d_attribute8 => l_DATTRIBUTE8
			, p_d_attribute9 => l_DATTRIBUTE9
			, p_d_attribute10 => l_DATTRIBUTE10
			, p_n_attribute1 => l_NATTRIBUTE1
			, p_n_attribute2 => l_NATTRIBUTE2
			, p_n_attribute3 => l_NATTRIBUTE3
			, p_n_attribute4 => l_NATTRIBUTE4
			, p_n_attribute5 => l_NATTRIBUTE5
			, p_n_attribute6 => l_NATTRIBUTE6
			, p_n_attribute7 => l_NATTRIBUTE7
			, p_n_attribute8 => l_NATTRIBUTE8
			, p_n_attribute9 => l_NATTRIBUTE9
			, p_n_attribute10 => l_NATTRIBUTE10
			);

		if(l_lot_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(p_error_tbl, 'Error while inserting Lot at line '||l_lot_ln, p_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;


		update pos_exasn_lots
		set TRANSACTION_INTERFACE_ID = l_txn_intf_id, serial_transaction_temp_id = l_serial_txn_temp_id
		where lot_id = l_lot_id;

		if(l_lpn is not null) then
			pos_asn_create_pvt.insert_wlpni
			  (	p_api_version	=> 1.0
			   , x_return_status  => l_lpn_status
			   , x_msg_count      => l_lpn_msg_count
			   , x_msg_data       => l_lpn_msg_data
			   , p_po_line_loc_id     => l_po_line_loc_id
			   , p_license_plate_number  =>    l_lpn
			   , p_LPN_GROUP_ID  => l_lpn_group_id
			   , p_PARENT_LICENSE_PLATE_NUMBER => null
			  );
			if(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
				if(InsertError(p_error_tbl, 'Error while inserting LPN at line '||l_lot_ln, p_error_pointer)=1) then
					raise l_25errors;
				end if;
			end if;
		end if;



	end loop;
	close l_allLots_csr;

	--update
	update pos_exasn_serials pst
	set pst.transaction_interface_id =
		(select plot.serial_transaction_temp_id
		from pos_exasn_lots plot
		where plot.lot_id = pst.lot_id);



	open l_allSerials_csr;
	loop
	fetch l_allSerials_csr into
		l_fm_serial,
		l_to_serial,
		l_po_line_loc_id,
		l_ser_intf_id,
		l_lpn,
		l_lpn_group_id,
		l_ser_ln,
		l_pdt_txn_id,
		l_ser_origination_date,
		l_ser_status_id,
		l_ser_territory_code,
		l_SERIAL_ATTRIBUTE_CATEGORY,
		l_CATTRIBUTE1,
		l_CATTRIBUTE2,
		l_CATTRIBUTE3,
		l_CATTRIBUTE4,
		l_CATTRIBUTE5,
		l_CATTRIBUTE6,
		l_CATTRIBUTE7,
		l_CATTRIBUTE8,
		l_CATTRIBUTE9,
		l_CATTRIBUTE10,
		l_CATTRIBUTE11,
		l_CATTRIBUTE12,
		l_CATTRIBUTE13,
		l_CATTRIBUTE14,
		l_CATTRIBUTE15,
		l_CATTRIBUTE16,
		l_CATTRIBUTE17,
		l_CATTRIBUTE18,
		l_CATTRIBUTE19,
		l_CATTRIBUTE20,
		l_DATTRIBUTE1,
		l_DATTRIBUTE2,
		l_DATTRIBUTE3,
		l_DATTRIBUTE4,
		l_DATTRIBUTE5,
		l_DATTRIBUTE6,
		l_DATTRIBUTE7,
		l_DATTRIBUTE8,
		l_DATTRIBUTE9,
		l_DATTRIBUTE10,
		l_NATTRIBUTE1,
		l_NATTRIBUTE2,
		l_NATTRIBUTE3,
		l_NATTRIBUTE4,
		l_NATTRIBUTE5,
		l_NATTRIBUTE6,
		l_NATTRIBUTE7,
		l_NATTRIBUTE8,
		l_NATTRIBUTE9,
		l_NATTRIBUTE10;
	exit when l_allSerials_csr%NOTFOUND;


		pos_asn_create_pvt.insert_msni (
		      p_api_version => 1.0
		    , x_return_status              => l_ser_status
		    , x_msg_count                  => l_ser_msg_count
		    , x_msg_data                   => l_ser_msg_data
		    , p_transaction_interface_id   => l_ser_intf_id
		    , p_fm_serial_number           => l_fm_serial
		    , p_to_serial_number           => l_to_serial
		    , p_po_line_loc_id            => l_po_line_loc_id
		    , p_product_transaction_id    => l_pdt_txn_id
			, p_origination_date		  => l_ser_origination_date
			, p_status_id				  => l_ser_status_id
			, p_territory_code			  => l_ser_territory_code
			, p_serial_attribute_category => l_SERIAL_ATTRIBUTE_CATEGORY
			, p_c_attribute1 => l_CATTRIBUTE1
			, p_c_attribute2 => l_CATTRIBUTE2
			, p_c_attribute3 => l_CATTRIBUTE3
			, p_c_attribute4 => l_CATTRIBUTE4
			, p_c_attribute5 => l_CATTRIBUTE5
			, p_c_attribute6 => l_CATTRIBUTE6
			, p_c_attribute7 => l_CATTRIBUTE7
			, p_c_attribute8 => l_CATTRIBUTE8
			, p_c_attribute9 => l_CATTRIBUTE9
			, p_c_attribute10 => l_CATTRIBUTE10
			, p_c_attribute11 => l_CATTRIBUTE11
			, p_c_attribute12 => l_CATTRIBUTE12
			, p_c_attribute13 => l_CATTRIBUTE13
			, p_c_attribute14 => l_CATTRIBUTE14
			, p_c_attribute15 => l_CATTRIBUTE15
			, p_c_attribute16 => l_CATTRIBUTE16
			, p_c_attribute17 => l_CATTRIBUTE17
			, p_c_attribute18 => l_CATTRIBUTE18
			, p_c_attribute19 => l_CATTRIBUTE19
			, p_c_attribute20 => l_CATTRIBUTE20
			, p_d_attribute1 => l_DATTRIBUTE1
			, p_d_attribute2 => l_DATTRIBUTE2
			, p_d_attribute3 => l_DATTRIBUTE3
			, p_d_attribute4 => l_DATTRIBUTE4
			, p_d_attribute5 => l_DATTRIBUTE5
			, p_d_attribute6 => l_DATTRIBUTE6
			, p_d_attribute7 => l_DATTRIBUTE7
			, p_d_attribute8 => l_DATTRIBUTE8
			, p_d_attribute9 => l_DATTRIBUTE9
			, p_d_attribute10 => l_DATTRIBUTE10
			, p_n_attribute1 => l_NATTRIBUTE1
			, p_n_attribute2 => l_NATTRIBUTE2
			, p_n_attribute3 => l_NATTRIBUTE3
			, p_n_attribute4 => l_NATTRIBUTE4
			, p_n_attribute5 => l_NATTRIBUTE5
			, p_n_attribute6 => l_NATTRIBUTE6
			, p_n_attribute7 => l_NATTRIBUTE7
			, p_n_attribute8 => l_NATTRIBUTE8
			, p_n_attribute9 => l_NATTRIBUTE9
			, p_n_attribute10 => l_NATTRIBUTE10
		    );


		if(l_ser_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(p_error_tbl, 'Error while inserting Serial at line '||l_ser_ln, p_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;

		if(l_lpn is not null) then
			pos_asn_create_pvt.insert_wlpni
			  (	p_api_version	=> 1.0
			   , x_return_status  => l_lpn_status
			   , x_msg_count      => l_lpn_msg_count
			   , x_msg_data       => l_lpn_msg_data
			   , p_po_line_loc_id     => l_po_line_loc_id
			   , p_license_plate_number  =>    l_lpn
			   , p_LPN_GROUP_ID  => l_lpn_group_id
			   , p_PARENT_LICENSE_PLATE_NUMBER => null
			  );
			if(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
				if(InsertError(p_error_tbl, 'Error while inserting Lpn at line '||l_ser_ln, p_error_pointer)=1) then
					raise l_25errors;
				end if;
			end if;
		end if;
	end loop;
	close l_allSerials_csr;

	open l_allLpns_csr;
	loop
	fetch l_allLpns_csr into
		l_lpn,
		l_po_line_loc_id,
		l_parent_lpn,
		l_lpn_group_id,
		l_lpn_ln;
	exit when l_allLpns_csr%NOTFOUND;

		pos_asn_create_pvt.insert_wlpni
		  (	p_api_version	=> 1.0
		   , x_return_status  => l_lpn_status
		   , x_msg_count      => l_lpn_msg_count
		   , x_msg_data       => l_lpn_msg_data
		   , p_po_line_loc_id     => l_po_line_loc_id
		   , p_license_plate_number  =>    l_lpn
		   , p_LPN_GROUP_ID  => l_lpn_group_id
		   , p_PARENT_LICENSE_PLATE_NUMBER => l_parent_lpn
		  );

		if(l_lpn_status <> FND_API.G_RET_STS_SUCCESS) then
			if(InsertError(p_error_tbl, 'Error while inserting Lpn at line '||l_lpn_ln, p_error_pointer)=1) then
				raise l_25errors;
			end if;
		end if;

	end loop;
	close l_allLpns_csr;


exception when l_25errors then
	null;
when others then
	if(InsertError(p_error_tbl, 'Unexpected Error in InsertIntoLLS', p_error_pointer)=1) then
		null;
	end if;
end InsertIntoLLS;


function InsertError(p_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
										p_error_msg in varchar2,
										p_error_index in out NOCOPY number)
return number
is
begin
	p_error_tbl.extend(1);
	p_error_tbl(p_error_index) := p_error_msg;
	p_error_index := p_error_index + 1;

	if(p_error_index > 25) then
		return 1;
	else
		return 0;
	end if;
end InsertError;


procedure FixHeadersAndLines(x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
												l_error_pointer in out NOCOPY number)
is
l_asn_header_id number;
l_ex_header_id number;
l_ex_vendor_id number;
l_ex_vendor_site_id number;
l_ex_ship_to_org_id number;
l_ex_first varchar2(1);
l_ex_currency_code varchar2(15);


--CREATE EXTRA RHIs
cursor l_findExtraRhi_csr
is
select HEADER_ID from
(
	select
		count(1), pht.header_id HEADER_ID, pht.shipment_number SHIPMENT_NUMBER, plnt.vendor_id VENDOR_ID, plnt.ship_to_org_id SHIP_TO_ORG_ID, nvl(plnt.vendor_site_id, -9999) VENDOR_SITE_ID, plnt.currency_code
	from pos_exasn_headers pht,
		pos_exasn_lines plnt
	where pht.header_id = plnt.header_id
	group by pht.header_id, pht.shipment_number, plnt.vendor_id, plnt.ship_to_org_id, nvl(plnt.vendor_site_id, -9999), plnt.currency_code
)
group by HEADER_ID
having count(1) > 1;

cursor l_createExtraRhi_csr(x_header_id number) is
select distinct plnt.vendor_id VENDOR_ID, plnt.ship_to_org_id SHIP_TO_ORG_ID, nvl(plnt.vendor_site_id, -9999) VENDOR_SITE_ID, plnt.currency_code CURRENCY_CODE
from pos_exasn_lines plnt
where header_id = x_header_Id;

l_asn_asbn varchar2(10);
l_early_exit exception;
l_asbn_bad varchar2(1);
l_error_ln number;
cursor l_checkNotPaySite_csr is
select peh.line_number
from pos_exasn_headers peh,
	po_vendor_sites_all pvsa
where pvsa.vendor_site_id = peh.vendor_site_id
AND getvendorpaysiteid(peh.vendor_id,nvl(peh.vendor_site_id, -9999),peh.currency_code) IS null;
--Refer the bug7338353 for more details

--H1: Freight Carrier Code
l_fcc pos_exasn_headers.freight_carrier_code%type;
cursor l_checkFreightCC_csr
is
select pht.line_number, pht.freight_carrier_code
from pos_exasn_headers pht
where pht.freight_carrier_code is not null
and 0=
(select count(*)  from org_freight oft
where nvl(oft.disable_date, sysdate) >= sysdate
and oft.freight_code = pht.freight_carrier_code
and organization_id = pht.ship_to_org_id
);

--H10: Bad Ship From Location
l_ship_from_loc pos_exasn_headers.ship_from_location_code%type;
cursor l_shipFrom_Loc_csr is
select pht.line_number,pht.ship_from_location_code
from pos_exasn_headers pht
where pht.ship_from_location_code is not null
and not exists (
   select 1 from hz_party_sites ps,hz_party_site_uses psu,po_vendors pov
   where ps.party_site_id = psu.party_site_id
   and psu.site_use_type = 'SUPPLIER_SHIP_FROM'
   and ps.party_id = pov.party_id
   and pov.vendor_id= pht.vendor_id
   and substr(ps.party_site_number,1,instr(ps.party_site_number,'|')-1) = pht.ship_from_location_code);


begin

  l_asbn_bad := 'F';

	select max(header_id) into l_asn_header_id from pos_exasn_headers;

	select decode(count(1),0,'ASN','ASBN')
	into l_asn_asbn
	from pos_exasn_headers
	where invoice_number is not null;




	open l_findExtraRhi_csr;
	loop
	fetch l_findExtraRhi_csr into
		l_ex_header_id;
	exit when l_findExtraRhi_csr%NOTFOUND;
		l_ex_first := 'T';
		open l_createExtraRhi_csr(l_ex_header_id);
		loop
		fetch l_createExtraRhi_csr into
			l_ex_vendor_id,
			l_ex_ship_to_org_id,
			l_ex_vendor_site_id,
                        l_ex_currency_code;
		exit when l_createExtraRhi_csr%NOTFOUND;
			if(l_ex_vendor_site_id = -9999) then
				l_ex_vendor_site_id := null;
			end if;
			if(l_ex_first = 'T') then
				l_ex_first := 'F';
			else
				if(l_asn_asbn = 'ASBN') then
					l_asbn_bad := 'T';
					select line_number
					into l_error_ln
					from pos_exasn_headers
					where header_id = l_ex_header_id;

					fnd_message.set_name('POS','POS_EXASN_ASBN_XHDR');
					fnd_message.set_token('LINE_NUM',l_error_ln);
					if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
						raise l_early_exit;
					end if;
				end if;

				l_asn_header_id := l_asn_header_id + 1;
				CreateNewHeader(l_asn_header_id, l_ex_header_id, l_ex_vendor_id, l_ex_ship_to_org_id, l_ex_vendor_site_id );

				update pos_exasn_lines
				set header_id = l_asn_header_id
				where header_id = l_ex_header_id
				and vendor_id = l_ex_vendor_id
				and ship_to_org_id = l_ex_ship_to_org_id
				and vendor_site_id = l_ex_vendor_site_id;
			end if;
		end loop;
		close l_createExtraRhi_csr;
	end loop;
	close l_findExtraRhi_csr;

	if(l_asbn_bad = 'T') then
		raise l_early_exit;
	end if;

	update pos_exasn_headers pht
	set (
		pht.vendor_id,
		pht.ship_to_org_id,
		pht.vendor_site_id,
		pht.currency_code,
		pht.rate,
		pht.rate_type,
		pht.rate_date
		)
		=
		(select
			plnt.vendor_id,
			plnt.ship_to_org_id,
			plnt.vendor_site_id,
			plnt.currency_code,
			plnt.rate,
			plnt.rate_type,
			plnt.rate_date
		from pos_exasn_lines plnt
		where plnt.header_id = pht.header_id
		and plnt.line_id =
			(select min(plnt2.line_id)
			from pos_exasn_lines plnt2
			where plnt2.header_id = pht.header_id)
		);

	--H1 (Has to be done after PHT.SHIP_TO_ORG_ID is populated)
	open l_checkFreightCC_csr;
	loop
	fetch l_checkFreightCC_csr into	l_error_ln, l_fcc;
	exit when l_checkFreightCC_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
		fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_FCCODE'));
		fnd_message.set_token('LOV_VALUE',l_fcc);
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_early_exit;
		end if;
	end loop;
	close l_checkFreightCC_csr;

    --H10 ShipFromLocationCode Validation
    open l_shipFrom_Loc_csr;
    loop
    fetch l_shipFrom_Loc_csr into l_error_ln,l_ship_from_loc;
    exit when l_shipFrom_Loc_csr%NOTFOUND;
        fnd_message.set_name('POS','POS_EXASN_INVALID_LOV');
        fnd_message.set_token('LOV_NAME',fnd_message.get_string('POS','POS_EXASN_SHP_FROM'));
        fnd_message.set_token('LOV_VALUE',l_ship_from_loc);
        fnd_message.set_token('LINE_NUM',l_error_ln);
        if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
            raise l_early_exit;
        end if;
    end loop;
    close l_shipFrom_Loc_csr;



	--Check to make sure vendor_site_id is pay site
	if(l_asn_asbn = 'ASBN') then
		open l_checkNotPaySite_csr;
		loop
		fetch l_checkNotPaySite_csr into l_error_ln;
		exit when l_checkNotPaySite_csr%notfound;
			fnd_message.set_name('POS','POS_EXASN_NOTPAYSITE');
			fnd_message.set_token('LINE_NUM',l_error_ln);
			if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
				raise l_early_exit;
			end if;
		end loop;
		close l_checkNotPaySite_csr;
	end if;



	-- Update Payment Term ID, if any
	update pos_exasn_headers pht
	set payment_term_id =
		(select atv.term_id
		from ap_terms_val_v atv
		where atv.name = pht.payment_terms)
	where payment_terms is not null;
	-------------------




	update pos_exasn_lines plnt
	set (header_interface_id, group_id, expected_receipt_date) = (select pht.header_interface_id, pht.group_id, pht.expected_receipt_date
								from pos_exasn_headers pht
								where pht.header_id = plnt.header_id);
exception when l_early_exit then
	null;
end FixHeadersAndLines;

procedure CreateNewLine(p_qty in number, p_lpn in varchar2, p_line_id in number, p_old_ln in number)
is
l_intf_txn_id number;
begin
	insert into pos_exasn_lines(line_id, quantity, license_plate_number) values(p_line_id, p_qty, p_lpn );
	select RCV_TRANSACTIONS_INTERFACE_S.nextval into l_intf_txn_id from dual;
	update pos_exasn_lines
	set (
		 PRIMARY_UOM,
		 LPN_GROUP_ID,
		 EXPECTED_RECEIPT_DATE,
		 HEADER_INTERFACE_ID,
		 INTERFACE_TRANSACTION_ID,
		 GROUP_ID,
		 HEADER_ID,
		 OPERATING_UNIT,
		 PO_NUMBER,
		 PO_REVISION,
		 PO_RELEASE_NUM,
		 PO_LINE,
		 PO_SHIPMENT,
		 ORG_ID,
		 PO_HEADER_ID,
		 PO_RELEASE_ID,
		 PO_LINE_ID,
		 PO_LINE_LOCATION_ID,
		 VENDOR_ID,
		 VENDOR_SITE_ID,
		 VENDOR_CONTACT_ID,
		 SHIP_TO_ORG_ID,
		 VENDOR_NAME,
		 VENDOR_SITE_CODE,
		 RATE_TYPE,
		 RATE,
		 RATE_DATE,
		 ITEM_ID,
		 ITEM_REVISION,
		 UNIT_PRICE,
		 CURRENCY_CODE,
		 VENDOR_PRODUCT_NUM,
		 UOM,
		 BILL_OF_LADING,
		 PACKING_SLIP,
		 NUM_OF_CONTAINERS,
		 WAYBILL_NUM,
		 BARCODE_LABEL,
		 COUNTRY_OF_ORIGIN,
		 CONTAINER_NUMBER,
		 TRUCK_NUMBER,
		 VENDOR_LOT,
		 COMMENTS,
		 LINE_NUMBER,
	  	 ATTRIBUTE_CATEGORY,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 SH_ATTRIBUTE_CATEGORY,
		 SH_ATTRIBUTE1,
		 SH_ATTRIBUTE2,
		 SH_ATTRIBUTE3,
		 SH_ATTRIBUTE4,
		 SH_ATTRIBUTE5,
		 SH_ATTRIBUTE6,
		 SH_ATTRIBUTE7,
		 SH_ATTRIBUTE8,
		 SH_ATTRIBUTE9,
		 SH_ATTRIBUTE10,
		 SH_ATTRIBUTE11,
		 SH_ATTRIBUTE12,
		 SH_ATTRIBUTE13,
		 SH_ATTRIBUTE14,
		 SH_ATTRIBUTE15,
		 SL_ATTRIBUTE_CATEGORY,
		 SL_ATTRIBUTE1,
		 SL_ATTRIBUTE2,
		 SL_ATTRIBUTE3,
		 SL_ATTRIBUTE4,
		 SL_ATTRIBUTE5,
		 SL_ATTRIBUTE6,
		 SL_ATTRIBUTE7,
		 SL_ATTRIBUTE8,
		 SL_ATTRIBUTE9,
		 SL_ATTRIBUTE10,
		 SL_ATTRIBUTE11,
		 SL_ATTRIBUTE12,
		 SL_ATTRIBUTE13,
		 SL_ATTRIBUTE14,
		 SL_ATTRIBUTE15,
		 SHIP_TO_LOCATION_CODE,
		 SHIP_TO_LOCATION_ID,
		 LLS_CODE,
		 ITEM_DESCRIPTION
		 )
		 = (
		select
		 PRIMARY_UOM,
		 LPN_GROUP_ID,
		 EXPECTED_RECEIPT_DATE,
		 HEADER_INTERFACE_ID,
		 l_intf_txn_id,
		 GROUP_ID,
		 HEADER_ID,
		 OPERATING_UNIT,
		 PO_NUMBER,
		 PO_REVISION,
		 PO_RELEASE_NUM,
		 PO_LINE,
		 PO_SHIPMENT,
		 ORG_ID,
		 PO_HEADER_ID,
		 PO_RELEASE_ID,
		 PO_LINE_ID,
		 PO_LINE_LOCATION_ID,
		 VENDOR_ID,
		 VENDOR_SITE_ID,
		 VENDOR_CONTACT_ID,
		 SHIP_TO_ORG_ID,
		 VENDOR_NAME,
		 VENDOR_SITE_CODE,
		 RATE_TYPE,
		 RATE,
		 RATE_DATE,
		 ITEM_ID,
		 ITEM_REVISION,
		 UNIT_PRICE,
		 CURRENCY_CODE,
		 VENDOR_PRODUCT_NUM,
		 UOM,
		 BILL_OF_LADING,
		 PACKING_SLIP,
		 NUM_OF_CONTAINERS,
		 WAYBILL_NUM,
		 BARCODE_LABEL,
		 COUNTRY_OF_ORIGIN,
		 CONTAINER_NUMBER,
		 TRUCK_NUMBER,
		 VENDOR_LOT,
		 COMMENTS,
		 LINE_NUMBER,
	  	 ATTRIBUTE_CATEGORY,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15,
		 SH_ATTRIBUTE_CATEGORY,
		 SH_ATTRIBUTE1,
		 SH_ATTRIBUTE2,
		 SH_ATTRIBUTE3,
		 SH_ATTRIBUTE4,
		 SH_ATTRIBUTE5,
		 SH_ATTRIBUTE6,
		 SH_ATTRIBUTE7,
		 SH_ATTRIBUTE8,
		 SH_ATTRIBUTE9,
		 SH_ATTRIBUTE10,
		 SH_ATTRIBUTE11,
		 SH_ATTRIBUTE12,
		 SH_ATTRIBUTE13,
		 SH_ATTRIBUTE14,
		 SH_ATTRIBUTE15,
		 SL_ATTRIBUTE_CATEGORY,
		 SL_ATTRIBUTE1,
		 SL_ATTRIBUTE2,
		 SL_ATTRIBUTE3,
		 SL_ATTRIBUTE4,
		 SL_ATTRIBUTE5,
		 SL_ATTRIBUTE6,
		 SL_ATTRIBUTE7,
		 SL_ATTRIBUTE8,
		 SL_ATTRIBUTE9,
		 SL_ATTRIBUTE10,
		 SL_ATTRIBUTE11,
		 SL_ATTRIBUTE12,
		 SL_ATTRIBUTE13,
		 SL_ATTRIBUTE14,
		 SL_ATTRIBUTE15,
		 SHIP_TO_LOCATION_CODE,
		 SHIP_TO_LOCATION_ID,
		 LLS_CODE,
		 ITEM_DESCRIPTION
		from pos_exasn_lines
		where line_id = p_old_ln)
	where line_id = p_line_id;
end CreateNewLine;

procedure CreateNewHeader(p_asn_header_id in number, p_ex_header_id in number,
p_ex_vendor_id in number, p_ex_ship_to_org_id in number, p_ex_vendor_site_id in number)
IS
l_lpn_group_id number;
l_header_interface_id number;
BEGIN
	select rcv_interface_groups_s.nextval into l_lpn_group_id from dual;
	select rcv_headers_interface_s.nextval into l_header_interface_id from dual;

	insert into pos_exasn_headers(
		header_id,
		lpn_group_id,
		vendor_id,
		ship_to_org_id,
		vendor_site_id,
		header_interface_id
		)
	values(
		p_asn_header_id,
		l_lpn_group_id,
		p_ex_vendor_id,
		p_ex_ship_to_org_id,
		p_ex_vendor_site_id,
		l_header_interface_id);

	update pos_exasn_headers
	set (
		 PAYMENT_TERM_ID,
		 CURRENCY_CODE,
		 RATE,
		 RATE_TYPE,
		 RATE_DATE,
		 ASN_REQUEST_ID ,
		 GROUP_ID,
		 SHIPMENT_NUMBER,
		 SHIPMENT_DATE,
		 EXPECTED_RECEIPT_DATE,
		 BILL_OF_LADING,
		 PACKING_SLIP,
		 FREIGHT_CARRIER_CODE,
		 NUM_OF_CONTAINERS,
		 WAYBILL_NUM,
		 GROSS_WEIGHT_UOM,
		 GROSS_WEIGHT,
		 NET_WEIGHT_UOM,
		 NET_WEIGHT,
		 TAR_WEIGHT_UOM,
		 TAR_WEIGHT,
		 PACKAGING_CODE,
		 CARRIER_METHOD,
		 SPECIAL_HANDLING_CODE,
		 HAZARD_CODE,
		 HAZARD_CLASS,
		 FREIGHT_TERMS,
		 COMMENTS,
		 INVOICE_NUMBER,
		 INVOICE_DATE,
		 INVOICE_AMOUNT ,
		 TAX_AMOUNT,
		 FREIGHT_AMOUNT ,
		 PAYMENT_TERMS,
		 LINE_NUMBER,
		 ATTRIBUTE_CATEGORY,
         SHIP_FROM_LOCATION_CODE,
		 ATTRIBUTE1,
		 ATTRIBUTE2,
		 ATTRIBUTE3,
		 ATTRIBUTE4,
		 ATTRIBUTE5,
		 ATTRIBUTE6,
		 ATTRIBUTE7,
		 ATTRIBUTE8,
		 ATTRIBUTE9,
		 ATTRIBUTE10,
		 ATTRIBUTE11,
		 ATTRIBUTE12,
		 ATTRIBUTE13,
		 ATTRIBUTE14,
		 ATTRIBUTE15
		) = (select
					 PAYMENT_TERM_ID,
					 CURRENCY_CODE,
					 RATE,
					 RATE_TYPE,
					 RATE_DATE,
					 ASN_REQUEST_ID ,
					 GROUP_ID,
					 SHIPMENT_NUMBER,
					 SHIPMENT_DATE,
					 EXPECTED_RECEIPT_DATE,
					 BILL_OF_LADING,
					 PACKING_SLIP,
					 FREIGHT_CARRIER_CODE,
					 NUM_OF_CONTAINERS,
					 WAYBILL_NUM,
					 GROSS_WEIGHT_UOM,
					 GROSS_WEIGHT,
					 NET_WEIGHT_UOM,
					 NET_WEIGHT,
					 TAR_WEIGHT_UOM,
					 TAR_WEIGHT,
					 PACKAGING_CODE,
					 CARRIER_METHOD,
					 SPECIAL_HANDLING_CODE,
					 HAZARD_CODE,
					 HAZARD_CLASS,
					 FREIGHT_TERMS,
					 COMMENTS,
					 INVOICE_NUMBER,
					 INVOICE_DATE,
					 INVOICE_AMOUNT ,
					 TAX_AMOUNT,
					 FREIGHT_AMOUNT ,
					 PAYMENT_TERMS,
					 LINE_NUMBER,
					 ATTRIBUTE_CATEGORY,
                     SHIP_FROM_LOCATION_CODE,
					 ATTRIBUTE1,
					 ATTRIBUTE2,
					 ATTRIBUTE3,
					 ATTRIBUTE4,
					 ATTRIBUTE5,
					 ATTRIBUTE6,
					 ATTRIBUTE7,
					 ATTRIBUTE8,
					 ATTRIBUTE9,
					 ATTRIBUTE10,
					 ATTRIBUTE11,
					 ATTRIBUTE12,
					 ATTRIBUTE13,
					 ATTRIBUTE14,
					 ATTRIBUTE15
						from pos_exasn_headers
						where header_id = p_ex_header_id)
	where header_id = p_asn_header_id;


	--remember to have new lpn_group_id
END;


procedure CheckLlsControl(x_return_status out nocopy varchar2,
											x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
											l_error_pointer in out nocopy number)
IS
l_25errors exception;
l_error_ln number;
cursor l_checkLotControl_csr is
select distinct plnt.line_number
from pos_exasn_lines plnt,
	pos_exasn_lots plot
where plnt.lls_code not in ('LOT','LAS')
and plnt.line_id = plot.line_id;

cursor l_checkSerialControl_csr is
select distinct plnt.line_number
from pos_exasn_lines plnt,
	pos_exasn_serials pst
where plnt.lls_code not in ('SER','LAS')
and plnt.line_id = pst.line_id;

--To Check that for all the child-parent lpn relationship, the child lpn exists
--as either a parent in some other row, or as a lpn in the lot/serial/lpn row (with quantity specified)
l_lpn pos_exasn_lpns.license_plate_number%type;
cursor l_check_lpnref_csr
is
select
	LPN, LINE_NUM from
(
	select
		a1.license_plate_number LPN,
		a1.line_number LINE_NUM
	from
		pos_exasn_lpns a1,
		pos_exasn_lines ln
	where a1.line_id = ln.line_id
	and ln.lls_code in ('LOT','LAS')
	and not exists
		(	select 1
			from pos_exasn_lots t
			where t.line_id = a1.line_id
			and t.license_plate_number = a1.license_plate_number)
	and not exists
		(	select 1
			from pos_exasn_lpns a2
			where a2.line_id = a1.line_id
			and a2.parent_lpn = a1.license_plate_number)

	union all

	select
		a1.license_plate_number LPN,
		a1.line_number LINE_NUM
	from
		pos_exasn_lpns a1,
		pos_exasn_lines ln
	where a1.line_id = ln.line_id
	and ln.lls_code = 'SER'
	and not exists
		(	select 1
			from pos_exasn_serials s
			where s.line_id = a1.line_id
			and s.license_plate_number = a1.license_plate_number)
	and not exists
		(	select 1
			from pos_exasn_lpns a2
			where a2.line_id = a1.line_id
			and a2.parent_lpn = a1.license_plate_number)

	union all

	-- if there is quantity defined, the LPN must not be defined as parent on some other line
        select
                a1.license_plate_number LPN,
                a1.line_number LINE_NUM

        from
                pos_exasn_lpns a1,
                pos_exasn_lines ln
        where a1.line_id = ln.line_id
        and ln.lls_code = 'LPN'
        and a1.quantity is not null
        and exists (    select 1
                        from pos_exasn_lpns p
                        where p.line_id = a1.line_id
                        and a1.quantity is not null
                        and p.parent_lpn = a1.license_plate_number)

        union all

        --If there is no quantity defined, the LPN line must define child-parent relationship
        select
                a1.license_plate_number LPN,
                a1.line_number LINE_NUM
        from
                pos_exasn_lpns a1,
                pos_exasn_lines ln
        where a1.line_id = ln.line_id
        and ln.lls_code = 'LPN'
        and a1.quantity is null
        and not exists (        select 1
                                from pos_exasn_lpns a2
                                where a2.line_id = a1.line_id
                                and a1.quantity is null
                                and a2.parent_lpn = a1.license_plate_number)


);

BEGIN
	update pos_exasn_lines plnt
	set plnt.lls_Code = 'LAS'
	where exists(
	select /*+ INDEX (msi, mtl_system_items_b_u1) */
	  1 from mtl_system_items msi
	where msi.inventory_item_id = plnt.item_id
	and msi.organization_id = plnt.ship_to_org_id
	and msi.lot_control_code = 2
	and msi.serial_number_control_code in (2,5));

	update pos_exasn_lines plnt
	set plnt.lls_Code = 'LOT'
	where plnt.lls_code is null
	and exists(
	select /*+ INDEX (msi, mtl_system_items_b_u1) */
	  1 from mtl_system_items msi
	where msi.inventory_item_id = plnt.item_id
	and msi.organization_id = plnt.ship_to_org_id
	and msi.lot_control_code = 2
	and msi.serial_number_control_code not in (2,5));

	update pos_exasn_lines plnt
	set plnt.lls_Code = 'SER'
	where plnt.lls_code is null
	and exists(
	select /*+ INDEX (msi, mtl_system_items_b_u1) */
	  1 from mtl_system_items msi
	where msi.inventory_item_id = plnt.item_id
	and msi.organization_id = plnt.ship_to_org_id
	and msi.lot_control_code = 1
	and msi.serial_number_control_code in (2,5));

	update pos_exasn_lines plnt
	set plnt.lls_Code = 'LPN'
	where plnt.lls_code is null;




	--	CHECK THAT LOT INFO ONLY FOR LOT CONTROLLED, etc...
	open l_checkLotControl_csr;
	loop
	fetch l_checkLotControl_csr into l_error_ln;
	exit when l_checkLotControl_csr%NOTFOUND;
	--Item at line LINE_NUM is not lot controlled, therefore shall not have any lot information.
		fnd_message.set_name('POS','POS_EXASN_NT_LC');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkLotControl_csr;

	open l_checkSerialControl_csr;
	loop
	fetch l_checkSerialControl_csr into l_error_ln;
	exit when l_checkSerialControl_csr%NOTFOUND;
	--Item at line LINE_NUM is not serial controlled, therefore shall not have any serial information.
		fnd_message.set_name('POS','POS_EXASN_NT_SC');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkSerialControl_csr;

	open l_check_lpnref_csr;
	loop
	fetch l_check_lpnref_csr into l_lpn, l_error_ln;
	exit when l_check_lpnref_csr%NOTFOUND;
		--The license plate number (LPN) defined in line LINE_NUM is invalid. The license plate number has to be defined in the Lot/Serial section or defined as a "Contained in License Plate Number".
		fnd_message.set_name('POS','POS_EXASN_LPN_NOREF');
		fnd_message.set_token('LINE_NUM',l_error_ln);
		fnd_message.set_token('LPN',l_lpn);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_check_lpnref_csr;


	x_return_status := 'S';
exception when l_25errors then
	x_return_status := 'E';
when others then
	x_return_status := 'U';
END CheckLlsControl;


procedure InsertIntoRTI
is
begin

/* Bug 10191272 ,Inserting Ship_To_Org_Id also */

	     insert into rcv_transactions_interface
         ( INTERFACE_TRANSACTION_ID     ,
           HEADER_INTERFACE_ID          ,
           GROUP_ID                     ,
           TRANSACTION_TYPE             ,
           TRANSACTION_DATE             ,
           PROCESSING_STATUS_CODE       ,
           PROCESSING_MODE_CODE         ,
           TRANSACTION_STATUS_CODE      ,
           AUTO_TRANSACT_CODE           ,
           RECEIPT_SOURCE_CODE          ,
           SOURCE_DOCUMENT_CODE         ,
           PO_HEADER_ID                 ,
           PO_LINE_ID                   ,
           PO_LINE_LOCATION_ID          ,
           QUANTITY                     ,
           PRIMARY_QUANTITY             ,
           UNIT_OF_MEASURE              ,
           PRIMARY_UNIT_OF_MEASURE      ,
           LAST_UPDATE_DATE             ,
           LAST_UPDATED_BY              ,
           LAST_UPDATE_LOGIN            ,
           CREATION_DATE                ,
           CREATED_BY                   ,
           ITEM_ID                      ,
		   ITEM_REVISION		,
           EXPECTED_RECEIPT_DATE        ,
           COMMENTS                     ,
           BARCODE_LABEL                ,
           CONTAINER_NUM                ,
           COUNTRY_OF_ORIGIN_CODE       ,
           VENDOR_ITEM_NUM              ,
           VENDOR_LOT_NUM               ,
           TRUCK_NUM                    ,
           NUM_OF_CONTAINERS            ,
           PACKING_SLIP                 ,
           VALIDATION_FLAG              ,
           WIP_ENTITY_ID                ,
           WIP_LINE_ID                  ,
           WIP_OPERATION_SEQ_NUM        ,
           PO_DISTRIBUTION_ID           ,
           DOCUMENT_LINE_NUM            ,
           DOCUMENT_SHIPMENT_LINE_NUM   ,
           VENDOR_ID                    ,
           VENDOR_SITE_ID               ,
           QUANTITY_INVOICED            ,
           SHIP_TO_LOCATION_CODE        ,
           SHIP_TO_LOCATION_ID          ,
           PO_RELEASE_ID,
           license_plate_number,
           lpn_group_id,
           document_num,
           item_description,
	       to_organization_id,
		   ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
		   ATTRIBUTE2,
           ATTRIBUTE3,
		   ATTRIBUTE4,
	       ATTRIBUTE5,
		   ATTRIBUTE6,
		   ATTRIBUTE7,
		   ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           SHIP_HEAD_ATTRIBUTE_CATEGORY,
           SHIP_HEAD_ATTRIBUTE1,
           SHIP_HEAD_ATTRIBUTE2,
           SHIP_HEAD_ATTRIBUTE3,
           SHIP_HEAD_ATTRIBUTE4,
           SHIP_HEAD_ATTRIBUTE5,
           SHIP_HEAD_ATTRIBUTE6,
           SHIP_HEAD_ATTRIBUTE7,
           SHIP_HEAD_ATTRIBUTE8,
           SHIP_HEAD_ATTRIBUTE9,
           SHIP_HEAD_ATTRIBUTE10,
           SHIP_HEAD_ATTRIBUTE11,
           SHIP_HEAD_ATTRIBUTE12,
           SHIP_HEAD_ATTRIBUTE13,
           SHIP_HEAD_ATTRIBUTE14,
           SHIP_HEAD_ATTRIBUTE15,
           SHIP_LINE_ATTRIBUTE_CATEGORY,
           SHIP_LINE_ATTRIBUTE1,
           SHIP_LINE_ATTRIBUTE2,
           SHIP_LINE_ATTRIBUTE3,
           SHIP_LINE_ATTRIBUTE4,
           SHIP_LINE_ATTRIBUTE5,
           SHIP_LINE_ATTRIBUTE6,
           SHIP_LINE_ATTRIBUTE7,
           SHIP_LINE_ATTRIBUTE8,
           SHIP_LINE_ATTRIBUTE9,
           SHIP_LINE_ATTRIBUTE10,
           SHIP_LINE_ATTRIBUTE11,
           SHIP_LINE_ATTRIBUTE12,
           SHIP_LINE_ATTRIBUTE13,
           SHIP_LINE_ATTRIBUTE14,
           SHIP_LINE_ATTRIBUTE15		   )
	select
		interface_transaction_id,
		header_interface_id,
		group_id,
		'SHIP',
		sysdate,
		'PENDING',
		'BATCH',
		'PENDING',
		'SHIP',
		'VENDOR',
		'PO',
		po_header_id,
		po_line_id,
		po_line_location_id,
		quantity,
		primary_quantity,
		uom,
		primary_uom,
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		item_id,
		item_revision,
		expected_receipt_date,
		comments,
		barcode_label,
		container_number,
		country_of_origin,
		vendor_product_num,
		vendor_lot,
		truck_number,
		num_of_containers,
		packing_slip,
		'Y',
		null,--wip stuff ???
		null,--wip stuff
		null,--wip stuff
		null,--wip stuff
		po_line,
		po_shipment,
		vendor_id,
		vendor_site_id,
		null, -- invoiced amount???
		ship_to_location_code,
		ship_to_location_id,
		po_release_id,
		license_plate_number,
		lpn_group_id,
		po_number,
		item_description,
		SHIP_TO_ORG_ID,
        ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		SH_ATTRIBUTE_CATEGORY,
		SH_ATTRIBUTE1,
		SH_ATTRIBUTE2,
		SH_ATTRIBUTE3,
		SH_ATTRIBUTE4,
		SH_ATTRIBUTE5,
		SH_ATTRIBUTE6,
		SH_ATTRIBUTE7,
		SH_ATTRIBUTE8,
		SH_ATTRIBUTE9,
		SH_ATTRIBUTE10,
		SH_ATTRIBUTE11,
		SH_ATTRIBUTE12,
		SH_ATTRIBUTE13,
		SH_ATTRIBUTE14,
		SH_ATTRIBUTE15,
		SL_ATTRIBUTE_CATEGORY,
		SL_ATTRIBUTE1,
		SL_ATTRIBUTE2,
		SL_ATTRIBUTE3,
		SL_ATTRIBUTE4,
		SL_ATTRIBUTE5,
		SL_ATTRIBUTE6,
		SL_ATTRIBUTE7,
		SL_ATTRIBUTE8,
		SL_ATTRIBUTE9,
		SL_ATTRIBUTE10,
		SL_ATTRIBUTE11,
		SL_ATTRIBUTE12,
		SL_ATTRIBUTE13,
		SL_ATTRIBUTE14,
		SL_ATTRIBUTE15
	from pos_exasn_lines;

end InsertIntoRTI;



procedure InsertIntoRHI
is
begin
	insert into rcv_headers_interface
       (HEADER_INTERFACE_ID             ,
        GROUP_ID                        ,
        PROCESSING_STATUS_CODE          ,
        RECEIPT_SOURCE_CODE             ,
        TRANSACTION_TYPE                ,
        LAST_UPDATE_DATE                ,
        LAST_UPDATED_BY                 ,
        LAST_UPDATE_LOGIN               ,
        CREATION_DATE                   ,
        CREATED_BY                      ,
        SHIP_TO_ORGANIZATION_ID         ,
        VENDOR_ID                       ,
        VENDOR_SITE_ID                  ,
        SHIPPED_DATE                    ,
        ASN_TYPE                        ,
        SHIPMENT_NUM                    ,
        EXPECTED_RECEIPT_DATE           ,
        PACKING_SLIP                    ,
        WAYBILL_AIRBILL_NUM             ,
        BILL_OF_LADING                  ,
        FREIGHT_CARRIER_CODE            ,
        FREIGHT_TERMS                   ,
        NUM_OF_CONTAINERS               ,
        COMMENTS                        ,
        CARRIER_METHOD                  ,
        CARRIER_EQUIPMENT               ,
        PACKAGING_CODE                  ,
        SPECIAL_HANDLING_CODE           ,
        INVOICE_NUM                     ,
        INVOICE_DATE                    ,
        TOTAL_INVOICE_AMOUNT            ,
        FREIGHT_AMOUNT                  ,
        TAX_NAME                        ,
        TAX_AMOUNT                      ,
        CURRENCY_CODE                   ,
        CONVERSION_RATE_TYPE            ,
        CONVERSION_RATE                 ,
        CONVERSION_RATE_DATE            ,
        PAYMENT_TERMS_ID                ,
        PAYMENT_TERMS_NAME              ,
        VALIDATION_FLAG,
        GROSS_WEIGHT_UOM_CODE,
        GROSS_WEIGHT,
        TAR_WEIGHT_UOM_CODE,
        TAR_WEIGHT,
        NET_WEIGHT_UOM_CODE,
        NET_WEIGHT,
        REMIT_TO_SITE_ID,
        SHIP_FROM_LOCATION_CODE,
		ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
        )

	select
		header_interface_id,
		group_id,
		'PENDING',
		'VENDOR',
		'NEW',
		sysdate,
		fnd_global.user_id,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		ship_to_org_id,
		vendor_id,
		vendor_site_id,
		shipment_date,
		decode(INVOICE_NUMBER,null,'ASN','ASBN'),
		shipment_number,
		expected_receipt_date,
		packing_slip,
		waybill_num,
		bill_of_lading,
		freight_carrier_code,
		freight_terms,
		num_of_containers,
		comments,
		carrier_method,
		null,
		packaging_code,
		special_handling_code,
		invoice_number,
		invoice_date,
		invoice_amount,
		freight_amount,
		null,
		tax_amount,
		currency_code,
		rate_type,
		rate,
		rate_date,
		payment_term_id,
		payment_terms,
		'Y',
		gross_weight_uom,
		gross_weight,
		tar_weight_uom,
		tar_weight,
		net_weight_uom,
		net_weight,
		decode(invoice_number,null,null,getvendorpaysiteid(vendor_id,nvl(vendor_site_id,-9999),currency_code)),
        ship_from_location_code,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	from pos_exasn_headers;



end InsertIntoRHI;
procedure CheckSecuringAtt(
			x_return_status out nocopy varchar2,
			x_user_vendor_id_tbl out nocopy vendor_id_tbl_type,
			x_secure_by_site out nocopy varchar2,
			x_secure_by_contact out nocopy varchar2,
			x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
			x_error_pointer in out nocopy number
			)
IS
l_num number;
l_user_vendor_id number;
l_index	number;


cursor l_vendorId_csr is
SELECT NUMBER_VALUE
FROM   AK_WEB_USER_SEC_ATTR_VALUES
WHERE  WEB_USER_ID = FND_GLOBAL.USER_ID
AND    ATTRIBUTE_CODE = 'ICX_SUPPLIER_ORG_ID'
AND    ATTRIBUTE_APPLICATION_ID = 177;


cursor l_orgSecure_csr(p_resp_id number) is
select 1
from ak_resp_security_attributes arsa
WHERE  arsa.responsibility_id = p_resp_id
AND    arsa.attribute_application_id = 177
and arsa.attribute_code = 'ICX_SUPPLIER_ORG_ID';

cursor l_siteSecure_csr(p_resp_id number) is
select 1
from ak_resp_security_attributes arsa
WHERE  arsa.responsibility_id = p_resp_id
AND    arsa.attribute_application_id = 177
and arsa.attribute_code = 'ICX_SUPPLIER_SITE_ID';

cursor l_contactSecure_csr(p_resp_id number) is
select 1
from ak_resp_security_attributes arsa
WHERE  arsa.responsibility_id = p_resp_id
AND    arsa.attribute_application_id = 177
and arsa.attribute_code = 'ICX_SUPPLIER_CONTACT_ID';


cursor l_vendorSite_csr(p_user_id number) is
SELECT number_value
FROM   ak_web_user_sec_attr_values
WHERE  web_user_id = p_user_id
AND    attribute_code = 'ICX_SUPPLIER_SITE_ID'
AND    attribute_application_id = 177;

cursor l_vendorContact_csr(p_user_id number) is
SELECT number_value
FROM   ak_web_user_sec_attr_values
WHERE  web_user_id = p_user_id
AND    attribute_code = 'ICX_SUPPLIER_CONTACT_ID'
AND    attribute_application_id = 177;

BEGIN
	x_secure_by_site := 'F';
	x_secure_by_contact := 'F';
	open l_orgSecure_csr(fnd_global.resp_id);
	fetch l_orgSecure_csr into l_num;

	l_num := null;
	open l_siteSecure_csr(fnd_global.resp_id);
	fetch l_siteSecure_csr into l_num;
	if(l_num = 1) then
		x_secure_by_site := 'T';
	end if;

	l_num := null;
	open l_contactSecure_csr(fnd_global.resp_id);
	fetch l_contactSecure_csr into l_num;
	if(l_num = 1) then
		x_secure_by_contact := 'T';
	end if;


  --The following code segment retrieves and records all secured attributes
  --for org id, ICX_SUPPLIER_ORG_ID.  The recorded set of attributes will be
  --used in ValidateLines to check against the vendor ids of all the lines.
	BEGIN

		l_index := 1;

		OPEN l_vendorId_csr;
		LOOP
			FETCH l_vendorId_csr INTO l_user_vendor_id;
			EXIT WHEN l_vendorId_csr%NOTFOUND;

			x_user_vendor_id_tbl(l_index)	:= l_user_vendor_id;
			l_index := l_index+1;

			IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.string( LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                    MODULE => 'pos.plsql.pos_asn_create_pvt.CheckSecuringAtt',
                    MESSAGE => 'Retrieved Vendor Id ' || l_index || ':' ||
                               l_user_vendor_id);
			END IF;

		END LOOP;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.string( LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                    MODULE => 'pos.plsql.pos_asn_create_pvt.CheckSecuringAtt',
                    MESSAGE => 'No data found for cursor: l_vendorId_csr');
			END IF;

			fnd_message.set_name('POS','POS_EXASN_NOT_ORG_SEC');
			IF(InsertError(x_error_tbl, fnd_message.get, x_error_pointer)=1) THEN
				null;
			END IF;
			x_return_status := 'E';
	END;


	--Check Securing Attributes by Site
	if(x_secure_by_site = 'T') then
		l_num := null;
		begin
			--Find out if -9999 is defined for Site for user's responsibility
			SELECT number_value
			into l_num
     		FROM   AK_RESP_SECURITY_ATTR_VALUES
		    WHERE  responsibility_id = fnd_global.resp_id
     		AND    attribute_application_id = 177
     		AND    attribute_code = 'ICX_SUPPLIER_SITE_ID'
     		AND    number_value = -9999;

			l_num := null;
			--IF -9999 is defined, and user is not secured by Vendor_Site_id, then it is the same as not be secured by site
			open l_vendorSite_csr(fnd_global.user_id);
			fetch l_vendorSite_csr into l_num;
			close l_vendorSite_csr;
			if(l_num is null) then
				x_secure_by_site := 'F';
			end if;

		exception when others then
			--If -9999 is NOT defined, then user has to be secured by Site
			l_num := null;
			open l_vendorSite_csr(fnd_global.user_id);
			fetch l_vendorSite_csr into l_num;
			close l_vendorSite_csr;
			if(l_num is null) then
				fnd_message.set_name('POS','POS_EXASN_NOT_SITE_SEC');
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer) = 1) then
					null;
				end if;
				x_return_status := 'E';
			end if;
		end;
	end if;

	--Check Securing Attributes by Contact
	if(x_secure_by_contact = 'T') then
		l_num := null;
		begin
			--Find out if -9999 is defined for Site for user's responsibility
			SELECT number_value
			into l_num
     		FROM   AK_RESP_SECURITY_ATTR_VALUES
		    WHERE  responsibility_id = fnd_global.resp_id
     		AND    attribute_application_id = 177
     		AND    attribute_code = 'ICX_SUPPLIER_CONTACT_ID'
     		AND    number_value = -9999;

			l_num := null;
			--IF -9999 is defined, and user is not secured by Contact, then it is the same as not be secured by contact
			open l_vendorContact_csr(fnd_global.user_id);
			fetch l_vendorContact_csr into l_num;
			close l_vendorContact_csr;
			if(l_num is null) then
				x_secure_by_contact := 'F';
			end if;

		exception when others then
			--If -9999 is NOT defined, then user has to be secured by Contact
			open l_vendorContact_csr(fnd_global.user_id);
			fetch l_vendorContact_csr into l_num;
			close l_vendorContact_csr;
			if(l_num is null) then
				fnd_message.set_name('POS','POS_EXASN_NOT_CT_SEC');
				if(InsertError(x_error_tbl, fnd_message.get, x_error_pointer) = 1) then
					null;
				end if;
				x_return_status := 'E';

			end if;
		end;
	end if;
exception when others then
	x_return_status := 'E';
	if(InsertError(x_error_tbl, 'Unknown exception when checking Securing Attributes:'||sqlerrm, x_error_pointer) = 1) then
		null;
	end if;
END CheckSecuringAtt;




function getConvertedQuantity(p_line_location_id in number,
												p_quantity in number,
												p_uom in varchar2
												) return number
IS
l_converted_qty number;
BEGIN
			POS_CREATE_ASN.getConvertedQuantity ( 	p_line_location_id ,
			                                        p_quantity ,
               					                    p_uom ,
                                   					l_converted_qty );
	return l_converted_qty;
exception when others then
	return -1;
END;


procedure ProcessExcelAsn(p_api_version in number,
							x_return_status out nocopy varchar2,
							x_return_code out nocopy varchar2,
							x_return_msg out nocopy varchar2,
							x_error_tbl out NOCOPY POS_EXCELASN_ERROR_TABLE,
							x_user_vendor_id out nocopy number)
is
x_progress varchar2(10);
l_header_status varchar2(1);
l_line_status varchar2(1);
l_lls_status varchar2(1);
l_llsControl_status varchar2(1);
l_user_name varchar2(100);



-- MISC


l_invalOrg_ln number;
l_25errors exception;
l_early_exp exception;

l_error_pointer number := 1;
l_error_ln number;

--Securing Attributes
l_secure_by_site varchar2(1);
l_secure_by_contact varchar2(1);
l_secure_status varchar2(1);

l_insertlls_status varchar2(1);
l_error_ln2 number;

cursor l_checkLpnContra_csr
is
select plpn1.line_number, plpn2.line_number
from pos_exasn_lpns plpn1, pos_exasn_lpns plpn2,
	pos_exasn_lines plnt1, pos_exasn_lines plnt2
where plpn1.license_plate_number = plpn2.license_plate_number
and plpn1.parent_lpn <> plpn2.parent_lpn
and plnt1.line_id = plpn1.line_id
and plnt2.line_id = plpn2.line_id
and plnt1.org_id = plnt2.org_id ;

cursor l_checkDocAsn_csr
is
select SHIPMENT_NUMBER
from pos_Exasn_headers
group by SHIPMENT_NUMBER, nvl(VENDOR_ID,-9999), nvl(VENDOR_SITE_ID,-9999)
having count(1) > 1;


cursor l_buyerNotif_csr
is
select SHIPMENT_NUMBER, VENDOR_ID, VENDOR_SITE_ID
from pos_exasn_headers;

l_shipment_number pos_exasn_headers.shipment_number%type;
l_vendor_id pos_exasn_headers.vendor_id%type;
l_vendor_site_id pos_exasn_headers.vendor_site_id%type;
l_user_vendor_id_tbl vendor_id_tbl_type;

/* Inbound Logistics : Validate Ship From Location Code */
  Cursor l_shipFrom  is
   Select /*+ USE_NL(pht,plt,ps) LEADING(pht) */
          pht.header_id,
          plt.po_line_id,
          plt.po_line_location_id,
          pht.ship_from_location_code,
          ps.location_id as ship_from_location_id
   from   pos_exasn_headers pht,
          pos_exasn_lines plt,
          hz_party_sites ps
   where  pht.header_id = plt.header_id
   and    pht.ship_from_location_code is not null
   and    ps.party_site_number = pht.ship_from_location_code||'|'||pht.vendor_id
   order by pht.header_id;

  l_lineIdTbl         po_tbl_number    := po_tbl_number();
  l_lineLocIdTbl      po_tbl_number    := po_tbl_number();
  l_count NUMBER := 0;
  l_return_status VARCHAR2(2000);
  l_prev_header_id pos_exasn_headers.header_id%type := -1;
  l_prev_ship_from VARCHAR2(30) := '';
  l_header_id pos_exasn_headers.header_id%type;
  l_line_id pos_exasn_lines.po_line_id%type;
  l_line_location_id pos_exasn_lines.po_line_location_id%type;
  l_ship_from_location_code pos_exasn_headers.ship_from_location_code%type;
  --l_ship_from_location_id hz_party_sites.location_id%type;
  l_ship_from_location_id  number;
  l_err_tbl po_tbl_varchar2000 ;


begin

	x_progress := '000';
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_error_tbl := POS_EXCELASN_ERROR_TABLE();

  --x_user_vendor_id will no longer be retrieved from  the secured attribute,
  --ICX_SUPPLIER_ORG_ID
	SELECT FND_GLOBAL.USER_NAME INTO l_user_name FROM DUAL;
  x_user_vendor_id :=POS_VENDOR_UTIL_PKG.GET_PO_VENDOR_ID_FOR_USER(l_user_name);

	-- Check Securing Attributes

	CheckSecuringAtt(
			l_secure_status,
			l_user_vendor_id_tbl,
			l_secure_by_site,
			l_secure_by_contact,
			x_error_tbl,
			l_error_pointer);
	if(l_secure_status = 'E') then
		raise l_early_exp;
	end if;



	x_progress := '001';
	--Validate Headers
	ValidateHeaders(l_header_status, x_error_tbl, l_error_pointer);
	if(l_header_status <> 'S') then
		raise l_early_exp;
	end if;


	x_progress := '002';
	--Validate Lines
	ValidateLines(l_line_status, l_user_vendor_id_tbl, l_secure_by_site, l_secure_by_contact, x_error_tbl, l_error_pointer);
	if(l_line_status <> 'S') then
		raise l_early_exp;
	end if;

	x_progress := '003';
	FixHeadersAndLines(x_error_tbl,l_error_pointer);
	if(x_error_tbl.count > 0) then
		raise l_early_exp;
	end if;

	--Check for Duplicate Shipment Number in the Upload Document
	--Invalid if same shipment number for > 2 ASNs with the same vendor_id and vendor_site_id
	--This validations has to be done after FixHeadersAndLines, which will populate vendor_id and vendor_site_id at header level
	open l_checkDocAsn_csr;
	loop
	fetch l_checkDocAsn_csr into l_shipment_number;
	exit when l_checkDocAsn_csr%NOTFOUND;
		fnd_message.set_name('POS','POS_EXASN_NEW_DUPE_SHIP');
		--Shipment number SHIP_NUM is used more than once for shipments with the same vendor, vendor site.
		fnd_message.set_token('SHIP_NUM',l_shipment_number);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkDocAsn_csr;

    /*Inbound Logistics Project :  Ship From Location Validation */
    open l_shipFrom;
    loop
       fetch l_shipFrom into l_header_id,l_line_id,l_line_location_id,
           l_ship_from_location_code, l_ship_from_location_id;
       exit when l_shipFrom%NOTFOUND;

       if (l_prev_header_id <> -1 AND l_prev_header_id <> l_header_id) THEN
          -- the first time they are not equal, we dont need to do validations

             POS_ASN_CREATE_PVT.validate_ship_from
             (p_api_version_number  => 1.0,
              p_init_msg_list       => 'T',
              x_return_status  => l_return_status,
              p_ship_from_locationid=> l_ship_from_location_id,
              p_po_line_id_tbl       => l_lineIdTbl,
              p_po_line_loc_id_tbl   => l_lineLocIdTbl,
              x_out_invalid_tbl      => l_err_tbl
               );
          if (l_err_tbl.count() > 0) then
               if(InsertError(x_error_tbl,l_err_tbl(l_error_pointer), l_error_pointer)=1) then
                      raise l_25errors;
               end if;

          else
               -- empty the linelocid table and shiplocid table and prepare for new validation
                l_LineIdTbl    := po_tbl_number();
                l_LineLocIdTbl := po_tbl_number();
           end if;
        end if;
      l_lineIdTbl.EXTEND;
       l_lineLocIdTbl.EXTEND;
        l_count :=  l_count + 1;
        l_lineIdTbl(l_count) := l_line_id;
        l_lineLocIdTbl(l_count) := l_line_location_id;
        l_prev_header_id := l_header_id;
        l_prev_ship_From  := l_ship_from_location_code;
    end loop;
    close l_shipFrom;

	x_progress := '004';
	CheckLlsControl(l_llsControl_status, x_error_tbl, l_error_pointer);
	if(l_llsControl_status <> 'S') then
		raise l_early_exp;
	end if;



	x_progress := '005';
	-- CHECK LPN: No a-->b, a-->c
	open l_checkLpnContra_csr;
	loop
	fetch l_checkLpnContra_csr into
		l_error_ln,
		l_error_ln2;
	exit when l_checkLpnContra_csr%NOTFOUND;
		--The Parent-Child relationships for license plate number at line LINE_NUM1 and LINE_NUM2 contradict each other.
		fnd_message.set_name('POS','POS_EXASN_PLPN_CONTRA');
		fnd_message.set_token('LINE_NUM1',l_error_ln);
		fnd_message.set_token('LINE_NUM2',l_error_ln2);
		if(InsertError(x_error_tbl, fnd_message.get, l_error_pointer)=1) then
			raise l_25errors;
		end if;
	end loop;
	close l_checkLpnContra_csr;




	x_progress := '006';
	ValidateLls(l_lls_status, x_error_tbl, l_error_pointer);
	if(l_lls_status <> 'S') then
		raise l_early_exp;
	end if;



	if(x_error_tbl.count > 0) then
		raise l_early_exp;
	end if;

	--Create Extra RTI for Lot Lines
	x_progress := '007';
	CreateRTI4Lot;

	--Create Extra RTI for Serial Lines
	x_progress := '008';
	CreateRTI4Ser;

	--Create Extra RTI for Lpn Lines
	x_progress := '009';
	CreateRTI4Lpn;


	x_progress := '010';
	UpdateLinesAndLls(x_error_tbl,l_error_pointer);

	--For LAS, need to update Child Serial in many ways ==> CreateRTI4Lot



	if(x_error_tbl.count > 0) then
		raise l_early_exp;
	end if;

	x_progress := '011';
	InsertIntoRHI;
	x_progress := '012';
	InsertIntoRTI;


	x_progress := '013';
	InsertIntoLLS(l_insertlls_status, x_error_tbl, l_error_pointer);
	if(x_error_tbl.count > 0) then
		raise l_early_exp;
	end if;

        --Send Notifications to Buyer for each ASN Header
	open l_buyerNotif_csr;
	loop
	fetch l_buyerNotif_csr into
	      l_shipment_number, l_vendor_id, l_vendor_site_id;
	exit when l_buyerNotif_csr%NOTFOUND;

        POS_ASN_NOTIF.GENERATE_NOTIF ( p_shipment_num => l_shipment_number,
                                       p_notif_type => 'CREATE',
                                       p_vendor_id => l_vendor_id,
                                       p_vendor_site_id => l_vendor_site_id,
                                       p_user_id => fnd_global.user_id
                                     );
	end loop;
	close l_buyerNotif_csr;


exception when l_early_exp then
	x_return_status := FND_API.G_RET_STS_ERROR;

when l_25errors then
	x_return_status := FND_API.G_RET_STS_ERROR;

when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	x_return_msg := 'Unexpected error in ProcessExcelAsn:'||x_progress||':'||sqlerrm;
	if(InsertError(x_error_tbl, 'Unexpected error in ProcessExcelAsn:'||x_progress||':'||sqlerrm, l_error_pointer)=1) then
		null;
	end if;
end ProcessExcelAsn;

-------------------------------------------------------------------------------
--Start of Comments
--Name: getvendorpaysiteid
--Pre-reqs:
--  None.
--Function:
--  It returns the vendor site id depends on the Paysite Defaulting logic
--Function Usage:
--  This function is used for both paysite validation and defaulting the
--  value in Remit-To-Site of the ASBN that is being uploaded
--Logic Implemented:
--  Paysite Defaulting Logic:
--   1.Check whether the primary paysite is available or not for the vendor
--     If it is available, returns the vendor site id of the primary paysite
--     else go to step2
--   2.Check whether the purchasing site itself,is a paysite or not
--     If it is, returns the vendor site id of the purchasing paysite
--     else go to step3
--   3.Check whether the PO's purchasing site has any alternate paysite or not
--     If it has, returns the vendor site id of the Alternate paysite
--     else go to step4
--   4. check whether any paysites available for the vendor or not
--     If it has, returns the vendor site id of the first created paysite
--     else returns NULL
--Parameters:
--  Vendor id, Vendor Site id, Currency code
--IN:
--  p_vendor_id,p_vendor_site_id,p_currency_code
--OUT:
--  l_vendor_site_id
--Bug Number for reference:
--  Base Bug 6718930,7196781
--  Bug 7338353
--End of Comments
------------------------------------------------------------------------------

function getvendorpaysiteid(p_vendor_id in varchar2,p_vendor_site_id IN varchar2,p_currency_code IN varchar2) RETURN PO_VENDOR_SITES_ALL.vendor_site_id%type
IS
--Local Variable Declaration
l_vendor_site_id PO_VENDOR_SITES_ALL.vendor_site_id%type:=0;
l_DEFAULT_PAY_SITE_ID PO_VENDOR_SITES_ALL.default_pay_site_id%type;
l_org_id PO_VENDOR_SITES_ALL.default_pay_site_id%type;

BEGIN

        -- Getting the org id of the vendor site
        SELECT org_id
        INTO   l_org_id
        FROM   po_vendor_sites_all
        WHERE  vendor_site_id= p_vendor_site_id;

        -- Check for primary paysite exists
        BEGIN
                select vendor_site_id
                into l_vendor_site_id
                from PO_VENDOR_SITES_ALL PVS
                where
                SYSDATE < NVL(PVS.INACTIVE_DATE, SYSDATE+1)
                AND PVS.org_id = l_org_id
                AND PVS.vendor_id = p_vendor_id
                AND PVS.primary_pay_site_flag = 'Y'
                AND ROWNUM=1;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        --if no primary paysite exists, then check whether the purchasing site is paysite or not
                BEGIN

                        select vendor_site_id
                        into l_vendor_site_id
                        from PO_VENDOR_SITES_ALL PVS
                        WHERE
                        SYSDATE < NVL(PVS.INACTIVE_DATE, SYSDATE+1)
                        AND PVS.org_id = l_org_id
                        AND PVS.vendor_id = p_vendor_id
                        AND PVS.vendor_site_id = p_vendor_site_id
                        AND PVS.pay_site_flag = 'Y'
                        AND ROWNUM=1;

                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                BEGIN
                                --if the purchasing site is not a pay site, then check whether it has default pay site
                                select default_pay_site_id
                                into l_DEFAULT_PAY_SITE_ID
                                from PO_VENDOR_SITES_ALL PVS
                                where PVS.org_id = l_org_id
                                AND PVS.vendor_id = p_vendor_id
                                AND PVS.vendor_site_id = p_vendor_site_id
                                AND ROWNUM=1;

                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                                l_DEFAULT_PAY_SITE_ID :=0;
                END;

                        IF l_DEFAULT_PAY_SITE_ID > 0 then
                        BEGIN
                                --If it has default paysite, then check default paysite id is paysite or not
                                select vendor_site_id
                                into l_vendor_site_id
                                from PO_VENDOR_SITES_ALL PVS
                                where org_id = l_org_id
                                AND PVS.vendor_id = p_vendor_id
                                AND PVS.vendor_site_id = l_DEFAULT_PAY_SITE_ID
                                AND PVS.pay_site_flag = 'Y'
                                AND ROWNUM=1;
                        EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                        l_vendor_site_id :=0;
                        END;
                        End if;
                        WHEN too_many_rows then
                        null;
        end;
  END;
--If default paysite is not available for the purchasing site, then check whether it has any other paysites
--available for the particular Org and Vendor
                IF l_vendor_site_id =0 THEN

                                SELECT VENDOR_SITE_ID
                                into l_vendor_site_id
                                FROM (SELECT CURRENCY_CODE,
										PVS.VENDOR_ID,
										PVS.VENDOR_SITE_ID,
										PVS.VENDOR_SITE_CODE,
									   /*PVS.PAYMENT_METHOD_LOOKUP_CODE,*/
										Nvl(PRT.PAYMENT_METHOD_CODE, PAYEE.DEFAULT_PAYMENT_METHOD_CODE)
											PAYMENT_METHOD_LOOKUP_CODE,
										Nvl(PVS.ORG_ID, -99) ORG_ID
										FROM
										/* AP_BANK_ACCOUNT_USES_ALL ABAU,
										 AP_BANK_ACCOUNTS_ALL ABA,
										 AP_BANK_BRANCHES ABB,*/
										PO_VENDOR_SITES_ALL PVS
										/*Added for bug#13554162 */
										,
										ap_suppliers sup,
										IBY_EXTERNAL_PAYEES_ALL PAYEE,
										IBY_EXT_PARTY_PMT_MTHDS PRT,
										iby_pmt_instr_uses_all ipi,
										iby_ext_bank_accounts ieb,
										ce_bank_branches_v bankbranch
										WHERE
										  /* ABAU.EXTERNAL_BANK_ACCOUNT_ID = ABA.BANK_ACCOUNT_ID(+) AND
										   ABA.BANK_BRANCH_ID = ABB.BANK_BRANCH_ID(+) AND
										   ABAU.VENDOR_ID(+) = PVS.VENDOR_ID AND
										   ABAU.VENDOR_SITE_ID(+) = PVS.VENDOR_SITE_ID AND
										  (NVL(ABAU.PRIMARY_FLAG, 'N') = 'Y' OR ABAU.BANK_ACCOUNT_USES_ID is null) AND
										   PVS.PAYMENT_METHOD_LOOKUP_CODE = 'EFT' AND
										   SYSDATE < NVL(ABB.END_DATE, SYSDATE+1) AND
										   SYSDATE < NVL(ABA.INACTIVE_DATE, SYSDATE+1)*/
										  Nvl(PVS.PAY_SITE_FLAG, 'N') = 'Y'
										  AND
										  /*Added for bug#13554162*/
										  SYSDATE < Nvl(ipi.END_DATE, SYSDATE + 1)
										  AND Decode (PRT.PAYMENT_METHOD_CODE, NULL,
											  Nvl(PAYEE.DEFAULT_PAYMENT_METHOD_CODE, -1
												  ),
																			   PRT.PAYMENT_METHOD_CODE) = 'EFT'
										  AND pvs.vendor_id = sup.vendor_id
										  AND payee.payee_party_id = sup.party_id
										  AND payee.supplier_site_id = pvs.vendor_site_id
										  AND payee.org_id IS NOT NULL
										  AND payee.org_type IS NOT NULL
										  AND payee.payment_function = prt.payment_function(+)
										  AND payee.ext_payee_id = prt.ext_pmt_party_id(+)
										  AND prt.primary_flag(+) = 'Y'
										  AND PAYEE.ext_payee_id = ipi.ext_pmt_party_id
										  AND ipi.payment_flow = 'DISBURSEMENTS'
										  AND ipi.instrument_type = 'BANKACCOUNT'
										  AND ipi.payment_function = 'PAYABLES_DISB'
										  AND ipi.instrument_id = ieb.ext_bank_account_id
										  AND ieb.bank_id = bankbranch.bank_party_id
										  AND ieb.branch_id = bankbranch.branch_party_id
										UNION
										SELECT NULL                 CURRENCY_CODE,
											   PVS.VENDOR_ID,
											   PVS.VENDOR_SITE_ID,
											   PVS.VENDOR_SITE_CODE,
											   /*PVS.PAYMENT_METHOD_LOOKUP_CODE,*/
											   Nvl(PRT.PAYMENT_METHOD_CODE, PAYEE.DEFAULT_PAYMENT_METHOD_CODE)
																	PAYMENT_METHOD_LOOKUP_CODE,
											   Nvl(PVS.ORG_ID, -99) ORG_ID
										FROM   PO_VENDOR_SITES_ALL PVS,
											   ap_suppliers sup,
											   IBY_EXTERNAL_PAYEES_ALL PAYEE,
											   IBY_EXT_PARTY_PMT_MTHDS PRT
										WHERE  SYSDATE < Nvl(PVS.INACTIVE_DATE, SYSDATE + 1)
											   AND Nvl(PVS.PAY_SITE_FLAG, 'N') = 'Y'
											   AND
											   /*added for bug#13554162*/
											   Decode (PRT.PAYMENT_METHOD_CODE, NULL,
											   Nvl(PAYEE.DEFAULT_PAYMENT_METHOD_CODE, -1
											   ),
																				PRT.PAYMENT_METHOD_CODE) <> 'EFT'
											   AND pvs.vendor_id = sup.vendor_id
											   AND PAYEE.PAYEE_PARTY_ID = sup.party_id
											   AND PAYEE.supplier_site_id = PVS.VENDOR_SITE_ID
											   AND PAYEE.org_id IS NOT NULL
											   AND PAYEE.org_type IS NOT NULL
											   AND PAYEE.PAYMENT_FUNCTION = PRT.PAYMENT_FUNCTION(+)
											   AND PAYEE.EXT_PAYEE_ID = PRT.EXT_PMT_PARTY_ID(+)
											   AND PRT.PRIMARY_FLAG(+) = 'Y'  ) QRSLT  WHERE (ORG_ID = NVL(l_org_id, -99) AND VENDOR_ID = p_vendor_id AND
				  DECODE(PAYMENT_METHOD_LOOKUP_CODE, 'EFT', CURRENCY_CODE, p_currency_code) = p_currency_code AND ROWNUM=1);
                END IF;

 RETURN l_vendor_site_id;

END getvendorpaysiteid;


END Pos_ExcelAsn_PVT;

/
