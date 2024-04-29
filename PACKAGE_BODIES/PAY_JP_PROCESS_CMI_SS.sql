--------------------------------------------------------
--  DDL for Package Body PAY_JP_PROCESS_CMI_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_PROCESS_CMI_SS" as
/* $Header: pyjpcmis.pkb 120.1 2006/01/15 18:17 keyazawa noship $ */
--
  c_varchar2 varchar2(10) := 'VARCHAR2';
  c_date     varchar2(10) := 'DATE';
  c_number   varchar2(10) := 'NUMBER';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< calc_car_amount >----------------------------|
-- ----------------------------------------------------------------------------
procedure calc_car_amount
(
	p_business_group_id   in         number,
	p_assignment_id       in         number,
	p_effective_date      in         date,
	--
	p_attribute_category  in         varchar2 default null,
	p_attribute1          in         varchar2 default null,
	p_attribute2          in         varchar2 default null,
	p_attribute3          in         varchar2 default null,
	p_attribute4          in         varchar2 default null,
	p_attribute5          in         varchar2 default null,
	p_attribute6          in         varchar2 default null,
	p_attribute7          in         varchar2 default null,
	p_attribute8          in         varchar2 default null,
	p_attribute9          in         varchar2 default null,
	p_attribute10         in         varchar2 default null,
	p_attribute11         in         varchar2 default null,
	p_attribute12         in         varchar2 default null,
	p_attribute13         in         varchar2 default null,
	p_attribute14         in         varchar2 default null,
	p_attribute15         in         varchar2 default null,
	p_attribute16         in         varchar2 default null,
	p_attribute17         in         varchar2 default null,
	p_attribute18         in         varchar2 default null,
	p_attribute19         in         varchar2 default null,
	p_attribute20         in         varchar2 default null,
	--
	p_means_code          in         varchar2 default null,
	p_vehicle_info_id     in         number   default null,
	p_period_code         in         varchar2 default null,
	p_distance            in         number   default null,
	p_fuel_cost_code      in         varchar2 default null,
	p_amount              in         number   default null,
	p_parking_fees        in         number   default null,
	p_equivalent_cost     in         number   default null,
	p_pay_start_month     in         varchar2 default null,
	p_pay_end_month       in         varchar2 default null,
	p_si_start_month_code in         varchar2 default null,
	p_update_date         in         date     default null,
	p_update_reason_code  in         varchar2 default null,
	p_comments            in         varchar2 default null,
	--
	p_new_car_amount      out nocopy number,
	p_val_returned        out nocopy number,
	--
	p_error_message       out nocopy long
	--
) is
	--
	l_formula_id         number;
	--
	l_ev_rec_tbl         pay_jp_entries_pkg.ev_rec_tbl;
	l_attribute_tbl      pay_jp_entries_pkg.attribute_tbl;
	--
	l_new_car_amount     varchar2(255);
	l_val_returned       boolean;
	--
begin
	--
	l_formula_id :=
		to_number(per_jp_cma_utility_pkg.bg_cma_formula_id(p_business_group_id));
	--
	if l_formula_id is not null then
		--
		l_ev_rec_tbl(1).entry_value  := p_means_code;
		l_ev_rec_tbl(2).entry_value  := fnd_number.number_to_canonical(p_vehicle_info_id);
		l_ev_rec_tbl(3).entry_value  := p_period_code;
		l_ev_rec_tbl(4).entry_value  := fnd_number.number_to_canonical(p_distance);
		l_ev_rec_tbl(5).entry_value  := p_fuel_cost_code;
		l_ev_rec_tbl(6).entry_value  := fnd_number.number_to_canonical(p_amount);
		l_ev_rec_tbl(7).entry_value  := fnd_number.number_to_canonical(p_parking_fees);
		l_ev_rec_tbl(8).entry_value  := fnd_number.number_to_canonical(p_equivalent_cost);
		l_ev_rec_tbl(9).entry_value  := p_pay_start_month;
		l_ev_rec_tbl(10).entry_value := p_pay_end_month;
		l_ev_rec_tbl(11).entry_value := p_si_start_month_code;
		l_ev_rec_tbl(12).entry_value := fnd_date.date_to_canonical(p_update_date);
		l_ev_rec_tbl(13).entry_value := p_update_reason_code;
		l_ev_rec_tbl(14).entry_value := p_comments;
		l_ev_rec_tbl(15).entry_value := null;
		--
		l_attribute_tbl.attribute_category := p_attribute_category;
		l_attribute_tbl.attribute(1)  := p_attribute1;
		l_attribute_tbl.attribute(2)  := p_attribute2;
		l_attribute_tbl.attribute(3)  := p_attribute3;
		l_attribute_tbl.attribute(4)  := p_attribute4;
		l_attribute_tbl.attribute(5)  := p_attribute5;
		l_attribute_tbl.attribute(6)  := p_attribute6;
		l_attribute_tbl.attribute(7)  := p_attribute7;
		l_attribute_tbl.attribute(8)  := p_attribute8;
		l_attribute_tbl.attribute(9)  := p_attribute9;
		l_attribute_tbl.attribute(10) := p_attribute10;
		l_attribute_tbl.attribute(11) := p_attribute11;
		l_attribute_tbl.attribute(12) := p_attribute12;
		l_attribute_tbl.attribute(13) := p_attribute13;
		l_attribute_tbl.attribute(14) := p_attribute14;
		l_attribute_tbl.attribute(15) := p_attribute15;
		l_attribute_tbl.attribute(16) := p_attribute16;
		l_attribute_tbl.attribute(17) := p_attribute17;
		l_attribute_tbl.attribute(18) := p_attribute18;
		l_attribute_tbl.attribute(19) := p_attribute19;
		l_attribute_tbl.attribute(20) := p_attribute20;
		--
		per_jp_cma_utility_pkg.calc_car_amount
		(
			p_formula_id        => l_formula_id,
			p_business_group_id => p_business_group_id,
			p_assignment_id     => p_assignment_id,
			p_effective_date    => p_effective_date,
			p_ev_rec_tbl        => l_ev_rec_tbl,
			p_attribute_tbl     => l_attribute_tbl,
			p_outputs           => l_new_car_amount,
			p_val_returned      => l_val_returned
		);
		--
		if l_val_returned then
			p_new_car_amount := to_number(l_new_car_amount);
			p_val_returned   := 1;
		else
			p_new_car_amount := 0;
			p_val_returned   := 0;
		end if;
		--
	else
		p_new_car_amount := 0;
		p_val_returned   := 0;
	end if;
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end calc_car_amount;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_transaction_step >-------------------------|
-- ----------------------------------------------------------------------------
procedure set_transaction_step
(
	p_item_type             in         varchar2,
	p_item_key              in         varchar2,
	p_activity_id           in         number,
	p_login_person_id       in         number,
	--
	p_commutation_type      in         varchar2, -- 'TRAIN' or 'CAR'
	p_action_type           in         varchar2, -- 'INSERT' or 'UPDATE' or 'DELETE'
	p_effective_date        in         date     default null,
	p_date_track_option     in         varchar2 default null,
	p_element_entry_id      in         number   default null,
	p_business_group_id     in         number   default null,
	p_assignment_id         in         number   default null,
	p_element_link_id       in         number   default null,
	p_entry_type            in         varchar2 default null,
	p_object_version_number in         number   default null,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	p_input_value_id14      in         number   default null,
	p_input_value_id15      in         number   default null,
	--
	p_entry_value1          in         varchar2 default null,
	p_entry_value2          in         varchar2 default null,
	p_entry_value3          in         varchar2 default null,
	p_entry_value4          in         varchar2 default null,
	p_entry_value5          in         varchar2 default null,
	p_entry_value6          in         varchar2 default null,
	p_entry_value7          in         varchar2 default null,
	p_entry_value8          in         varchar2 default null,
	p_entry_value9          in         varchar2 default null,
	p_entry_value10         in         varchar2 default null,
	p_entry_value11         in         varchar2 default null,
	p_entry_value12         in         varchar2 default null,
	p_entry_value13         in         varchar2 default null,
	p_entry_value14         in         varchar2 default null,
	p_entry_value15         in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
) is
	--
	l_date_format         varchar2(10);
	l_api_name            varchar2(100);
	--
	l_transaction_table   hr_transaction_ss.transaction_table;
	l_count               number := 0;
	--
	l_transaction_step_id number;
	l_review_item_name    varchar2(50);
	--
begin
	--
	l_date_format := hr_transaction_ss.g_date_format;
	l_api_name    := 'PAY_JP_PROCESS_CMI_SS.PROCESS_API';
	--
	l_review_item_name :=
		wf_engine.GetActivityAttrText
		(
			itemtype => p_item_type,
			itemkey  => p_item_key,
			actid    => p_activity_id,
			aname    => 'HR_REVIEW_REGION_ITEM'
		);
	--
 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
 	l_transaction_table(l_count).param_value := l_review_item_name;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
 	l_transaction_table(l_count).param_value := p_activity_id;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_COMMUTATION_TYPE';
	l_transaction_table(l_count).param_value := p_commutation_type;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ACTION_TYPE';
	l_transaction_table(l_count).param_value := p_action_type;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
	l_transaction_table(l_count).param_value := to_char(p_effective_date, l_date_format);
	l_transaction_table(l_count).param_data_type := 'DATE';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_DATE_TRACK_OPTION';
	l_transaction_table(l_count).param_value := p_date_track_option;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ELEMENT_ENTRY_ID';
	l_transaction_table(l_count).param_value := p_element_entry_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
	l_transaction_table(l_count).param_value := p_business_group_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
	l_transaction_table(l_count).param_value := p_assignment_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ELEMENT_LINK_ID';
	l_transaction_table(l_count).param_value := p_element_link_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_TYPE';
	l_transaction_table(l_count).param_value := p_entry_type;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
	l_transaction_table(l_count).param_value := p_object_version_number;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
	l_transaction_table(l_count).param_value := p_attribute_category;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
	l_transaction_table(l_count).param_value := p_attribute1;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
	l_transaction_table(l_count).param_value := p_attribute2;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
	l_transaction_table(l_count).param_value := p_attribute3;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
	l_transaction_table(l_count).param_value := p_attribute4;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
	l_transaction_table(l_count).param_value := p_attribute5;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
	l_transaction_table(l_count).param_value := p_attribute6;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
	l_transaction_table(l_count).param_value := p_attribute7;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
	l_transaction_table(l_count).param_value := p_attribute8;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
	l_transaction_table(l_count).param_value := p_attribute9;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
	l_transaction_table(l_count).param_value := p_attribute10;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
	l_transaction_table(l_count).param_value := p_attribute11;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
	l_transaction_table(l_count).param_value := p_attribute12;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
	l_transaction_table(l_count).param_value := p_attribute13;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
	l_transaction_table(l_count).param_value := p_attribute14;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
	l_transaction_table(l_count).param_value := p_attribute15;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
	l_transaction_table(l_count).param_value := p_attribute16;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
	l_transaction_table(l_count).param_value := p_attribute17;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
	l_transaction_table(l_count).param_value := p_attribute18;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
	l_transaction_table(l_count).param_value := p_attribute19;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
	l_transaction_table(l_count).param_value := p_attribute20;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID1';
	l_transaction_table(l_count).param_value := p_input_value_id1;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID2';
	l_transaction_table(l_count).param_value := p_input_value_id2;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID3';
	l_transaction_table(l_count).param_value := p_input_value_id3;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID4';
	l_transaction_table(l_count).param_value := p_input_value_id4;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID5';
	l_transaction_table(l_count).param_value := p_input_value_id5;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID6';
	l_transaction_table(l_count).param_value := p_input_value_id6;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID7';
	l_transaction_table(l_count).param_value := p_input_value_id7;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID8';
	l_transaction_table(l_count).param_value := p_input_value_id8;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID9';
	l_transaction_table(l_count).param_value := p_input_value_id9;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID10';
	l_transaction_table(l_count).param_value := p_input_value_id10;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID11';
	l_transaction_table(l_count).param_value := p_input_value_id11;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID12';
	l_transaction_table(l_count).param_value := p_input_value_id12;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID13';
	l_transaction_table(l_count).param_value := p_input_value_id13;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID14';
	l_transaction_table(l_count).param_value := p_input_value_id14;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INPUT_VALUE_ID15';
	l_transaction_table(l_count).param_value := p_input_value_id15;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE1';
	l_transaction_table(l_count).param_value := p_entry_value1;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE2';
	l_transaction_table(l_count).param_value := p_entry_value2;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE3';
	l_transaction_table(l_count).param_value := p_entry_value3;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE4';
	l_transaction_table(l_count).param_value := p_entry_value4;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE5';
	l_transaction_table(l_count).param_value := p_entry_value5;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE6';
	l_transaction_table(l_count).param_value := p_entry_value6;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE7';
	l_transaction_table(l_count).param_value := p_entry_value7;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE8';
	l_transaction_table(l_count).param_value := p_entry_value8;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE9';
	l_transaction_table(l_count).param_value := p_entry_value9;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE10';
	l_transaction_table(l_count).param_value := p_entry_value10;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE11';
	l_transaction_table(l_count).param_value := p_entry_value11;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE12';
	l_transaction_table(l_count).param_value := p_entry_value12;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE13';
	l_transaction_table(l_count).param_value := p_entry_value13;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE14';
	l_transaction_table(l_count).param_value := p_entry_value14;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ENTRY_VALUE15';
	l_transaction_table(l_count).param_value := p_entry_value15;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
	--
	hr_transaction_ss.save_transaction_step
	(
		p_item_type           => p_item_type,
		p_item_key            => p_item_key,
		p_actid               => p_activity_id,
		p_login_person_id     => p_login_person_id,
		p_transaction_step_id => l_transaction_step_id,
		p_api_name            => l_api_name,
		p_transaction_data    => l_transaction_table
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end set_transaction_step;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< set_train_transaction_step >----------------------|
-- ----------------------------------------------------------------------------
procedure set_train_transaction_step
(
	--
	p_item_type             in         varchar2,
	p_item_key              in         varchar2,
	p_activity_id           in         number,
	p_login_person_id       in         number,
	--
	p_action_type           in         varchar2,
	p_effective_date        in         date     default null,
	p_date_track_option     in         varchar2 default null,
	p_element_entry_id      in         number   default null,
	p_business_group_id     in         number   default null,
	p_assignment_id         in         number   default null,
	p_element_link_id       in         number   default null,
	p_entry_type            in         varchar2 default null,
	p_object_version_number in         number   default null,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_departure_place       in         varchar2 default null,
	p_arrival_place         in         varchar2 default null,
	p_via                   in         varchar2 default null,
	p_period_code           in         varchar2 default null,
	p_payment_option_code   in         varchar2 default null,
	p_amount                in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
) is
begin
	--
	set_transaction_step
	(
		--
		p_item_type             => p_item_type,
		p_item_key              => p_item_key,
		p_activity_id           => p_activity_id,
		p_login_person_id       => p_login_person_id,
		--
		p_commutation_type      => 'TRAIN',
		p_action_type           => p_action_type,
		p_effective_date        => p_effective_date,
		p_date_track_option     => p_date_track_option,
		p_element_entry_id      => p_element_entry_id,
		p_business_group_id     => p_business_group_id,
		p_assignment_id         => p_assignment_id,
		p_element_link_id       => p_element_link_id,
		p_entry_type            => p_entry_type,
		p_object_version_number => p_object_version_number,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1,
		p_input_value_id2       => p_input_value_id2,
		p_input_value_id3       => p_input_value_id3,
		p_input_value_id4       => p_input_value_id4,
		p_input_value_id5       => p_input_value_id5,
		p_input_value_id6       => p_input_value_id6,
		p_input_value_id7       => p_input_value_id7,
		p_input_value_id8       => p_input_value_id8,
		p_input_value_id9       => p_input_value_id9,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => null,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => p_departure_place,
		p_entry_value3          => p_arrival_place,
		p_entry_value4          => p_via,
		p_entry_value5          => p_period_code,
		p_entry_value6          => p_payment_option_code,
		p_entry_value7          => fnd_number.number_to_canonical(p_amount),
		p_entry_value8          => p_pay_start_month,
		p_entry_value9          => p_pay_end_month,
		p_entry_value10         => p_si_start_month_code,
		p_entry_value11         => fnd_date.date_to_canonical(p_update_date),
		p_entry_value12         => p_update_reason_code,
		p_entry_value13         => p_comments,
		p_entry_value14         => null,
		p_entry_value15         => null,
		--
		p_error_message         => p_error_message
		--
	);
	--
end set_train_transaction_step;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_car_transaction_step >-----------------------|
-- ----------------------------------------------------------------------------
procedure set_car_transaction_step
(
	--
	p_item_type             in         varchar2,
	p_item_key              in         varchar2,
	p_activity_id           in         number,
	p_login_person_id       in         number,
	--
	p_action_type           in         varchar2,
	p_effective_date        in         date     default null,
	p_date_track_option     in         varchar2 default null,
	p_element_entry_id      in         number   default null,
	p_business_group_id     in         number   default null,
	p_assignment_id         in         number   default null,
	p_element_link_id       in         number   default null,
	p_entry_type            in         varchar2 default null,
	p_object_version_number in         number   default null,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	p_input_value_id14      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_vehicle_info_id       in         number   default null,
	p_period_code           in         varchar2 default null,
	p_distance              in         number   default null,
	p_fuel_cost_code        in         varchar2 default null,
	p_amount                in         number   default null,
	p_parking_fees          in         number   default null,
	p_equivalent_cost       in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
) is
begin
	--
	set_transaction_step
	(
		p_item_type             => p_item_type,
		p_item_key              => p_item_key,
		p_activity_id           => p_activity_id,
		p_login_person_id       => p_login_person_id,
		--
		p_commutation_type      => 'CAR',
		p_action_type           => p_action_type,
		p_effective_date        => p_effective_date,
		p_date_track_option     => p_date_track_option,
		p_element_entry_id      => p_element_entry_id,
		p_business_group_id     => p_business_group_id,
		p_assignment_id         => p_assignment_id,
		p_element_link_id       => p_element_link_id,
		p_entry_type            => p_entry_type,
		p_object_version_number => p_object_version_number,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1,
		p_input_value_id2       => p_input_value_id2,
		p_input_value_id3       => p_input_value_id3,
		p_input_value_id4       => p_input_value_id4,
		p_input_value_id5       => p_input_value_id5,
		p_input_value_id6       => p_input_value_id6,
		p_input_value_id7       => p_input_value_id7,
		p_input_value_id8       => p_input_value_id8,
		p_input_value_id9       => p_input_value_id9,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => p_input_value_id14,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => fnd_number.number_to_canonical(p_vehicle_info_id),
		p_entry_value3          => p_period_code,
		p_entry_value4          => fnd_number.number_to_canonical(p_distance),
		p_entry_value5          => p_fuel_cost_code,
		p_entry_value6          => fnd_number.number_to_canonical(p_amount),
		p_entry_value7          => fnd_number.number_to_canonical(p_parking_fees),
		p_entry_value8          => fnd_number.number_to_canonical(p_equivalent_cost),
		p_entry_value9          => p_pay_start_month,
		p_entry_value10         => p_pay_end_month,
		p_entry_value11         => p_si_start_month_code,
		p_entry_value12         => fnd_date.date_to_canonical(p_update_date),
		p_entry_value13         => p_update_reason_code,
		p_entry_value14         => p_comments,
		p_entry_value15         => null,
		--
		p_error_message         => p_error_message
		--
	);
	--
end set_car_transaction_step;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_train_entry >--------------------------|
-- ----------------------------------------------------------------------------
procedure create_train_entry
(
	--
	p_validate              in         number   default 0,
	--
	p_effective_date        in         date,
	p_business_group_id     in         number,
	p_assignment_id         in         number,
	p_element_link_id       in         number,
	p_entry_type            in         varchar2,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_departure_place       in         varchar2 default null,
	p_arrival_place         in         varchar2 default null,
	p_via                   in         varchar2 default null,
	p_period_code           in         varchar2 default null,
	p_payment_option_code   in         varchar2 default null,
	p_amount                in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
)is
	--
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	l_element_entry_id      pay_element_entries_f.element_entry_id%type;
	l_object_version_number pay_element_entries_f.object_version_number%type;
	--
	l_create_warning        boolean;
	--
begin
	--
	pay_element_entry_api.create_element_entry
	(
		--
		p_validate              => hr_java_conv_util_ss.get_boolean(p_validate),
		--
		p_effective_date        => p_effective_date,
		p_business_group_id     => p_business_group_id,
		p_assignment_id         => p_assignment_id,
		p_element_link_id       => p_element_link_id,
		p_entry_type            => p_entry_type,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1 ,
		p_input_value_id2       => p_input_value_id2 ,
		p_input_value_id3       => p_input_value_id3 ,
		p_input_value_id4       => p_input_value_id4 ,
		p_input_value_id5       => p_input_value_id5 ,
		p_input_value_id6       => p_input_value_id6 ,
		p_input_value_id7       => p_input_value_id7 ,
		p_input_value_id8       => p_input_value_id8 ,
		p_input_value_id9       => p_input_value_id9 ,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => null,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => p_departure_place,
		p_entry_value3          => p_arrival_place,
		p_entry_value4          => p_via,
		p_entry_value5          => p_period_code,
		p_entry_value6          => p_payment_option_code,
		p_entry_value7          => fnd_number.number_to_canonical(p_amount),
		p_entry_value8          => p_pay_start_month,
		p_entry_value9          => p_pay_end_month,
		p_entry_value10         => p_si_start_month_code,
		-- canonical date format is not acceptable for this api
		p_entry_value11         => fnd_date.date_to_displaydate(p_update_date),
		p_entry_value12         => p_update_reason_code,
		p_entry_value13         => p_comments,
		p_entry_value14         => null,
		p_entry_value15         => null,
		--
		p_effective_start_date  => l_effective_start_date,
		p_effective_end_date    => l_effective_end_date,
		p_element_entry_id      => l_element_entry_id,
		p_object_version_number => l_object_version_number,
		--
		p_create_warning        => l_create_warning
		--
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end create_train_entry;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_train_entry >--------------------------|
-- ----------------------------------------------------------------------------
procedure update_train_entry
(
	p_validate              in            number   default 0,
	--
	p_datetrack_update_mode in            varchar2,
	p_effective_date        in            date,
	p_business_group_id     in            number,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_attribute_category    in            varchar2 default null,
	p_attribute1            in            varchar2 default null,
	p_attribute2            in            varchar2 default null,
	p_attribute3            in            varchar2 default null,
	p_attribute4            in            varchar2 default null,
	p_attribute5            in            varchar2 default null,
	p_attribute6            in            varchar2 default null,
	p_attribute7            in            varchar2 default null,
	p_attribute8            in            varchar2 default null,
	p_attribute9            in            varchar2 default null,
	p_attribute10           in            varchar2 default null,
	p_attribute11           in            varchar2 default null,
	p_attribute12           in            varchar2 default null,
	p_attribute13           in            varchar2 default null,
	p_attribute14           in            varchar2 default null,
	p_attribute15           in            varchar2 default null,
	p_attribute16           in            varchar2 default null,
	p_attribute17           in            varchar2 default null,
	p_attribute18           in            varchar2 default null,
	p_attribute19           in            varchar2 default null,
	p_attribute20           in            varchar2 default null,
	--
	p_input_value_id1       in            number   default null,
	p_input_value_id2       in            number   default null,
	p_input_value_id3       in            number   default null,
	p_input_value_id4       in            number   default null,
	p_input_value_id5       in            number   default null,
	p_input_value_id6       in            number   default null,
	p_input_value_id7       in            number   default null,
	p_input_value_id8       in            number   default null,
	p_input_value_id9       in            number   default null,
	p_input_value_id10      in            number   default null,
	p_input_value_id11      in            number   default null,
	p_input_value_id12      in            number   default null,
	p_input_value_id13      in            number   default null,
	--
	p_means_code            in            varchar2 default null,
	p_departure_place       in            varchar2 default null,
	p_arrival_place         in            varchar2 default null,
	p_via                   in            varchar2 default null,
	p_period_code           in            varchar2 default null,
	p_payment_option_code   in            varchar2 default null,
	p_amount                in            number   default null,
	p_pay_start_month       in            varchar2 default null,
	p_pay_end_month         in            varchar2 default null,
	p_si_start_month_code   in            varchar2 default null,
	p_update_date           in            date     default null,
	p_update_reason_code    in            varchar2 default null,
	p_comments              in            varchar2 default null,
	--
	p_error_message         out nocopy    long
	--
)is
	--
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	--
	l_update_warning        boolean;
	--
begin
	--
	pay_element_entry_api.update_element_entry
	(
		--
		p_validate              => hr_java_conv_util_ss.get_boolean(p_validate),
		--
		p_datetrack_update_mode => p_datetrack_update_mode,
		p_effective_date        => p_effective_date,
		p_business_group_id     => p_business_group_id,
		p_element_entry_id      => p_element_entry_id,
		p_object_version_number => p_object_version_number,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1 ,
		p_input_value_id2       => p_input_value_id2 ,
		p_input_value_id3       => p_input_value_id3 ,
		p_input_value_id4       => p_input_value_id4 ,
		p_input_value_id5       => p_input_value_id5 ,
		p_input_value_id6       => p_input_value_id6 ,
		p_input_value_id7       => p_input_value_id7 ,
		p_input_value_id8       => p_input_value_id8 ,
		p_input_value_id9       => p_input_value_id9 ,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => null,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => p_departure_place,
		p_entry_value3          => p_arrival_place,
		p_entry_value4          => p_via,
		p_entry_value5          => p_period_code,
		p_entry_value6          => p_payment_option_code,
		p_entry_value7          => fnd_number.number_to_canonical(p_amount),
		p_entry_value8          => p_pay_start_month,
		p_entry_value9          => p_pay_end_month,
		p_entry_value10         => p_si_start_month_code,
		-- canonical date format is not acceptable for this api
		p_entry_value11         => fnd_date.date_to_displaydate(p_update_date),
		p_entry_value12         => p_update_reason_code,
		p_entry_value13         => p_comments,
		p_entry_value14         => null,
		p_entry_value15         => null,
		--
		p_effective_start_date  => l_effective_start_date,
		p_effective_end_date    => l_effective_end_date,
		--
		p_update_warning        => l_update_warning
		--
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end update_train_entry;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_car_entry >---------------------------|
-- ----------------------------------------------------------------------------
procedure create_car_entry
(
	--
	p_validate              in         number   default 0,
	--
	p_effective_date        in         date,
	p_business_group_id     in         number,
	p_assignment_id         in         number,
	p_element_link_id       in         number,
	p_entry_type            in         varchar2,
	--
	p_attribute_category    in         varchar2 default null,
	p_attribute1            in         varchar2 default null,
	p_attribute2            in         varchar2 default null,
	p_attribute3            in         varchar2 default null,
	p_attribute4            in         varchar2 default null,
	p_attribute5            in         varchar2 default null,
	p_attribute6            in         varchar2 default null,
	p_attribute7            in         varchar2 default null,
	p_attribute8            in         varchar2 default null,
	p_attribute9            in         varchar2 default null,
	p_attribute10           in         varchar2 default null,
	p_attribute11           in         varchar2 default null,
	p_attribute12           in         varchar2 default null,
	p_attribute13           in         varchar2 default null,
	p_attribute14           in         varchar2 default null,
	p_attribute15           in         varchar2 default null,
	p_attribute16           in         varchar2 default null,
	p_attribute17           in         varchar2 default null,
	p_attribute18           in         varchar2 default null,
	p_attribute19           in         varchar2 default null,
	p_attribute20           in         varchar2 default null,
	--
	p_input_value_id1       in         number   default null,
	p_input_value_id2       in         number   default null,
	p_input_value_id3       in         number   default null,
	p_input_value_id4       in         number   default null,
	p_input_value_id5       in         number   default null,
	p_input_value_id6       in         number   default null,
	p_input_value_id7       in         number   default null,
	p_input_value_id8       in         number   default null,
	p_input_value_id9       in         number   default null,
	p_input_value_id10      in         number   default null,
	p_input_value_id11      in         number   default null,
	p_input_value_id12      in         number   default null,
	p_input_value_id13      in         number   default null,
	p_input_value_id14      in         number   default null,
	--
	p_means_code            in         varchar2 default null,
	p_vehicle_info_id       in         number   default null,
	p_period_code           in         varchar2 default null,
	p_distance              in         number   default null,
	p_fuel_cost_code        in         varchar2 default null,
	p_amount                in         number   default null,
	p_parking_fees          in         number   default null,
	p_equivalent_cost       in         number   default null,
	p_pay_start_month       in         varchar2 default null,
	p_pay_end_month         in         varchar2 default null,
	p_si_start_month_code   in         varchar2 default null,
	p_update_date           in         date     default null,
	p_update_reason_code    in         varchar2 default null,
	p_comments              in         varchar2 default null,
	--
	p_error_message         out nocopy long
	--
)is
	--
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	l_element_entry_id      pay_element_entries_f.element_entry_id%type;
	l_object_version_number pay_element_entries_f.object_version_number%type;
	--
	l_create_warning        boolean;
	--
begin
	--
	pay_element_entry_api.create_element_entry
	(
		--
		p_validate              => hr_java_conv_util_ss.get_boolean(p_validate),
		--
		p_effective_date        => p_effective_date,
		p_business_group_id     => p_business_group_id,
		p_assignment_id         => p_assignment_id,
		p_element_link_id       => p_element_link_id,
		p_entry_type            => p_entry_type,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1 ,
		p_input_value_id2       => p_input_value_id2 ,
		p_input_value_id3       => p_input_value_id3 ,
		p_input_value_id4       => p_input_value_id4 ,
		p_input_value_id5       => p_input_value_id5 ,
		p_input_value_id6       => p_input_value_id6 ,
		p_input_value_id7       => p_input_value_id7 ,
		p_input_value_id8       => p_input_value_id8 ,
		p_input_value_id9       => p_input_value_id9 ,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => p_input_value_id14,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => fnd_number.number_to_canonical(p_vehicle_info_id),
		p_entry_value3          => p_period_code,
		p_entry_value4          => fnd_number.number_to_canonical(p_distance),
		p_entry_value5          => p_fuel_cost_code,
		p_entry_value6          => fnd_number.number_to_canonical(p_amount),
		p_entry_value7          => fnd_number.number_to_canonical(p_parking_fees),
		p_entry_value8          => fnd_number.number_to_canonical(p_equivalent_cost),
		p_entry_value9          => p_pay_start_month,
		p_entry_value10         => p_pay_end_month,
		p_entry_value11         => p_si_start_month_code,
		-- canonical date format is not acceptable for this api
		p_entry_value12         => fnd_date.date_to_displaydate(p_update_date),
		p_entry_value13         => p_update_reason_code,
		p_entry_value14         => p_comments,
		p_entry_value15         => null,
		--
		p_effective_start_date  => l_effective_start_date,
		p_effective_end_date    => l_effective_end_date,
		p_element_entry_id      => l_element_entry_id,
		p_object_version_number => l_object_version_number,
		--
		p_create_warning        => l_create_warning
		--
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end create_car_entry;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_car_entry >---------------------------|
-- ----------------------------------------------------------------------------
procedure update_car_entry
(
	--
	p_validate              in            number   default 0,
	--
	p_datetrack_update_mode in            varchar2,
	p_effective_date        in            date,
	p_business_group_id     in            number,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_attribute_category    in            varchar2 default null,
	p_attribute1            in            varchar2 default null,
	p_attribute2            in            varchar2 default null,
	p_attribute3            in            varchar2 default null,
	p_attribute4            in            varchar2 default null,
	p_attribute5            in            varchar2 default null,
	p_attribute6            in            varchar2 default null,
	p_attribute7            in            varchar2 default null,
	p_attribute8            in            varchar2 default null,
	p_attribute9            in            varchar2 default null,
	p_attribute10           in            varchar2 default null,
	p_attribute11           in            varchar2 default null,
	p_attribute12           in            varchar2 default null,
	p_attribute13           in            varchar2 default null,
	p_attribute14           in            varchar2 default null,
	p_attribute15           in            varchar2 default null,
	p_attribute16           in            varchar2 default null,
	p_attribute17           in            varchar2 default null,
	p_attribute18           in            varchar2 default null,
	p_attribute19           in            varchar2 default null,
	p_attribute20           in            varchar2 default null,
	--
	p_input_value_id1       in            number   default null,
	p_input_value_id2       in            number   default null,
	p_input_value_id3       in            number   default null,
	p_input_value_id4       in            number   default null,
	p_input_value_id5       in            number   default null,
	p_input_value_id6       in            number   default null,
	p_input_value_id7       in            number   default null,
	p_input_value_id8       in            number   default null,
	p_input_value_id9       in            number   default null,
	p_input_value_id10      in            number   default null,
	p_input_value_id11      in            number   default null,
	p_input_value_id12      in            number   default null,
	p_input_value_id13      in            number   default null,
	p_input_value_id14      in            number   default null,
	--
	p_means_code            in            varchar2 default null,
	p_vehicle_info_id       in            number   default null,
	p_period_code           in            varchar2 default null,
	p_distance              in            number   default null,
	p_fuel_cost_code        in            varchar2 default null,
	p_amount                in            number   default null,
	p_parking_fees          in            number   default null,
	p_equivalent_cost       in            number   default null,
	p_pay_start_month       in            varchar2 default null,
	p_pay_end_month         in            varchar2 default null,
	p_si_start_month_code   in            varchar2 default null,
	p_update_date           in            date     default null,
	p_update_reason_code    in            varchar2 default null,
	p_comments              in            varchar2 default null,
	--
	p_error_message         out nocopy    long
	--
)is
	--
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	--
	l_update_warning        boolean;
	--
begin
	--
	pay_element_entry_api.update_element_entry
	(
		--
		p_validate              => hr_java_conv_util_ss.get_boolean(p_validate),
		--
		p_datetrack_update_mode => p_datetrack_update_mode,
		p_effective_date        => p_effective_date,
		p_business_group_id     => p_business_group_id,
		p_element_entry_id      => p_element_entry_id,
		p_object_version_number => p_object_version_number,
		--
		p_attribute_category    => p_attribute_category,
		p_attribute1            => p_attribute1,
		p_attribute2            => p_attribute2,
		p_attribute3            => p_attribute3,
		p_attribute4            => p_attribute4,
		p_attribute5            => p_attribute5,
		p_attribute6            => p_attribute6,
		p_attribute7            => p_attribute7,
		p_attribute8            => p_attribute8,
		p_attribute9            => p_attribute9,
		p_attribute10           => p_attribute10,
		p_attribute11           => p_attribute11,
		p_attribute12           => p_attribute12,
		p_attribute13           => p_attribute13,
		p_attribute14           => p_attribute14,
		p_attribute15           => p_attribute15,
		p_attribute16           => p_attribute16,
		p_attribute17           => p_attribute17,
		p_attribute18           => p_attribute18,
		p_attribute19           => p_attribute19,
		p_attribute20           => p_attribute20,
		--
		p_input_value_id1       => p_input_value_id1 ,
		p_input_value_id2       => p_input_value_id2 ,
		p_input_value_id3       => p_input_value_id3 ,
		p_input_value_id4       => p_input_value_id4 ,
		p_input_value_id5       => p_input_value_id5 ,
		p_input_value_id6       => p_input_value_id6 ,
		p_input_value_id7       => p_input_value_id7 ,
		p_input_value_id8       => p_input_value_id8 ,
		p_input_value_id9       => p_input_value_id9 ,
		p_input_value_id10      => p_input_value_id10,
		p_input_value_id11      => p_input_value_id11,
		p_input_value_id12      => p_input_value_id12,
		p_input_value_id13      => p_input_value_id13,
		p_input_value_id14      => p_input_value_id14,
		p_input_value_id15      => null,
		--
		p_entry_value1          => p_means_code,
		p_entry_value2          => fnd_number.number_to_canonical(p_vehicle_info_id),
		p_entry_value3          => p_period_code,
		p_entry_value4          => fnd_number.number_to_canonical(p_distance),
		p_entry_value5          => p_fuel_cost_code,
		p_entry_value6          => fnd_number.number_to_canonical(p_amount),
		p_entry_value7          => fnd_number.number_to_canonical(p_parking_fees),
		p_entry_value8          => fnd_number.number_to_canonical(p_equivalent_cost),
		p_entry_value9          => p_pay_start_month,
		p_entry_value10         => p_pay_end_month,
		p_entry_value11         => p_si_start_month_code,
		-- canonical date format is not acceptable for this api
		p_entry_value12         => fnd_date.date_to_displaydate(p_update_date),
		p_entry_value13         => p_update_reason_code,
		p_entry_value14         => p_comments,
		p_entry_value15         => null,
		--
		p_effective_start_date  => l_effective_start_date,
		p_effective_end_date    => l_effective_end_date,
		--
		p_update_warning        => l_update_warning
		--
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end update_car_entry;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_entry >-----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_entry
(
	--
	p_validate              in            number   default 0,
	--
	p_datetrack_delete_mode in            varchar2,
	p_effective_date        in            date,
	p_element_entry_id      in            number,
	p_object_version_number in out nocopy number,
	--
	p_error_message         out nocopy    long
	--
)is
	--
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	--
	l_warning               boolean;
	--
begin
	--
	pay_element_entry_api.delete_element_entry
	(
		--
		p_validate              => hr_java_conv_util_ss.get_boolean(p_validate),
		--
		p_datetrack_delete_mode => p_datetrack_delete_mode,
		p_effective_date        => p_effective_date,
		p_element_entry_id      => p_element_entry_id,
		p_object_version_number => p_object_version_number,
		--
		p_effective_start_date  => l_effective_start_date,
		p_effective_end_date    => l_effective_end_date,
		--
		p_delete_warning        => l_warning
	);
	--
exception
	--
	when others then
		p_error_message :=
			hr_java_conv_util_ss.get_formatted_error_message;
	--
end delete_entry;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< process_api >-----------------------------|
-- ----------------------------------------------------------------------------
procedure process_api
(
	--
	p_validate            in boolean  default false,
	p_transaction_step_id in number   default null,
	p_effective_date      in varchar2 default null
	--
) is
	--
	l_tran_tab              hr_transaction_ss.transaction_data;
	--
	-- for return values from out parameters
	l_element_entry_id      pay_element_entries_f.element_entry_id%type;
	l_object_version_number pay_element_entries_f.object_version_number%type;
	l_effective_start_date  pay_element_entries_f.effective_start_date%type;
	l_effective_end_date    pay_element_entries_f.effective_end_date%type;
	--
	type tran_rec is record
	(
		commutation_type      varchar2(30), -- 'TRAIN' or 'CAR'
		action_type           varchar2(30), -- 'INSERT' or 'UPDATE' or 'DELETE'
		effective_date        date,
		date_track_option     varchar2(30),
		--
		element_entry_id      pay_element_entries_f.element_entry_id%type,
		business_group_id     pay_element_links_f.business_group_id%type,
		assignment_id         pay_element_entries_f.assignment_id%type,
		element_link_id       pay_element_entries_f.element_link_id%type,
		entry_type            pay_element_entries_f.entry_type%type,
		object_version_number pay_element_entries_f.object_version_number%type,
		--
		attribute_category    pay_element_entries_f.attribute_category%type,
		attribute1            pay_element_entries_f.attribute1%type,
		attribute2            pay_element_entries_f.attribute2%type,
		attribute3            pay_element_entries_f.attribute3%type,
		attribute4            pay_element_entries_f.attribute4%type,
		attribute5            pay_element_entries_f.attribute5%type,
		attribute6            pay_element_entries_f.attribute6%type,
		attribute7            pay_element_entries_f.attribute7%type,
		attribute8            pay_element_entries_f.attribute8%type,
		attribute9            pay_element_entries_f.attribute9%type,
		attribute10           pay_element_entries_f.attribute10%type,
		attribute11           pay_element_entries_f.attribute11%type,
		attribute12           pay_element_entries_f.attribute12%type,
		attribute13           pay_element_entries_f.attribute13%type,
		attribute14           pay_element_entries_f.attribute14%type,
		attribute15           pay_element_entries_f.attribute15%type,
		attribute16           pay_element_entries_f.attribute16%type,
		attribute17           pay_element_entries_f.attribute17%type,
		attribute18           pay_element_entries_f.attribute18%type,
		attribute19           pay_element_entries_f.attribute19%type,
		attribute20           pay_element_entries_f.attribute20%type,
		--
		input_value_id1       pay_element_entry_values_f.input_value_id%type,
		input_value_id2       pay_element_entry_values_f.input_value_id%type,
		input_value_id3       pay_element_entry_values_f.input_value_id%type,
		input_value_id4       pay_element_entry_values_f.input_value_id%type,
		input_value_id5       pay_element_entry_values_f.input_value_id%type,
		input_value_id6       pay_element_entry_values_f.input_value_id%type,
		input_value_id7       pay_element_entry_values_f.input_value_id%type,
		input_value_id8       pay_element_entry_values_f.input_value_id%type,
		input_value_id9       pay_element_entry_values_f.input_value_id%type,
		input_value_id10      pay_element_entry_values_f.input_value_id%type,
		input_value_id11      pay_element_entry_values_f.input_value_id%type,
		input_value_id12      pay_element_entry_values_f.input_value_id%type,
		input_value_id13      pay_element_entry_values_f.input_value_id%type,
		input_value_id14      pay_element_entry_values_f.input_value_id%type,
		input_value_id15      pay_element_entry_values_f.input_value_id%type,
		--
		entry_value1          pay_element_entry_values_f.screen_entry_value%type,
		entry_value2          pay_element_entry_values_f.screen_entry_value%type,
		entry_value3          pay_element_entry_values_f.screen_entry_value%type,
		entry_value4          pay_element_entry_values_f.screen_entry_value%type,
		entry_value5          pay_element_entry_values_f.screen_entry_value%type,
		entry_value6          pay_element_entry_values_f.screen_entry_value%type,
		entry_value7          pay_element_entry_values_f.screen_entry_value%type,
		entry_value8          pay_element_entry_values_f.screen_entry_value%type,
		entry_value9          pay_element_entry_values_f.screen_entry_value%type,
		entry_value10         pay_element_entry_values_f.screen_entry_value%type,
		entry_value11         pay_element_entry_values_f.screen_entry_value%type,
		entry_value12         pay_element_entry_values_f.screen_entry_value%type,
		entry_value13         pay_element_entry_values_f.screen_entry_value%type,
		entry_value14         pay_element_entry_values_f.screen_entry_value%type,
		entry_value15         pay_element_entry_values_f.screen_entry_value%type
	);
	--
	l_tran_rec tran_rec;
	--
	i          number;
	l_warning  boolean;
	--
begin
	--
	-- get taransaction data
	hr_transaction_ss.get_transaction_data
	(
		p_transaction_step_id => p_transaction_step_id,
		p_transaction_data    => l_tran_tab
	);
	--
	i := l_tran_tab.name.first;
	--
	loop
		exit when not(l_tran_tab.name.exists(i));
		if l_tran_tab.name(i) in ('P_REVIEW_PROC_CALL', 'P_REVIEW_ACTID') then
			null;
		elsif l_tran_tab.name(i) = 'P_COMMUTATION_TYPE' then
			l_tran_rec.commutation_type := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ACTION_TYPE' then
			l_tran_rec.action_type := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_EFFECTIVE_DATE' then
			l_tran_rec.effective_date := l_tran_tab.date_value(i);
		elsif l_tran_tab.name(i) = 'P_DATE_TRACK_OPTION' then
			l_tran_rec.date_track_option := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ELEMENT_ENTRY_ID' then
			l_tran_rec.element_entry_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_BUSINESS_GROUP_ID' then
			l_tran_rec.business_group_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_ASSIGNMENT_ID' then
			l_tran_rec.assignment_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_ELEMENT_LINK_ID' then
			l_tran_rec.element_link_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_TYPE' then
			l_tran_rec.entry_type := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_OBJECT_VERSION_NUMBER' then
			l_tran_rec.object_version_number := l_tran_tab.number_value(i);
		--
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE_CATEGORY' then
			l_tran_rec.attribute_category := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE1' then
			l_tran_rec.attribute1 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE2' then
			l_tran_rec.attribute2 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE3' then
			l_tran_rec.attribute3 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE4' then
			l_tran_rec.attribute4 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE5' then
			l_tran_rec.attribute5 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE6' then
			l_tran_rec.attribute6 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE7' then
			l_tran_rec.attribute7 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE8' then
			l_tran_rec.attribute8 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE9' then
			l_tran_rec.attribute9 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE10' then
			l_tran_rec.attribute10 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE11' then
			l_tran_rec.attribute11 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE12' then
			l_tran_rec.attribute12 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE13' then
			l_tran_rec.attribute13 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE14' then
			l_tran_rec.attribute14 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE15' then
			l_tran_rec.attribute15 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE16' then
			l_tran_rec.attribute16 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE17' then
			l_tran_rec.attribute17 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE18' then
			l_tran_rec.attribute18 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE19' then
			l_tran_rec.attribute19 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE20' then
			l_tran_rec.attribute20 := l_tran_tab.varchar2_value(i);
		--
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID1' then
			l_tran_rec.input_value_id1 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID2' then
			l_tran_rec.input_value_id2 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID3' then
			l_tran_rec.input_value_id3 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID4' then
			l_tran_rec.input_value_id4 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID5' then
			l_tran_rec.input_value_id5 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID6' then
			l_tran_rec.input_value_id6 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID7' then
			l_tran_rec.input_value_id7 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID8' then
			l_tran_rec.input_value_id8 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID9' then
			l_tran_rec.input_value_id9 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID10' then
			l_tran_rec.input_value_id10 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID11' then
			l_tran_rec.input_value_id11 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID12' then
			l_tran_rec.input_value_id12 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID13' then
			l_tran_rec.input_value_id13 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID14' then
			l_tran_rec.input_value_id14 := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INPUT_VALUE_ID15' then
			l_tran_rec.input_value_id15 := l_tran_tab.number_value(i);
		--
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE1' then
			l_tran_rec.entry_value1 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE2' then
			l_tran_rec.entry_value2 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE3' then
			l_tran_rec.entry_value3 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE4' then
			l_tran_rec.entry_value4 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE5' then
			l_tran_rec.entry_value5 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE6' then
			l_tran_rec.entry_value6 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE7' then
			l_tran_rec.entry_value7 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE8' then
			l_tran_rec.entry_value8 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE9' then
			l_tran_rec.entry_value9 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE10' then
			l_tran_rec.entry_value10 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE11' then
			l_tran_rec.entry_value11 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE12' then
			l_tran_rec.entry_value12 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE13' then
			l_tran_rec.entry_value13 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE14' then
			l_tran_rec.entry_value14 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ENTRY_VALUE15' then
			l_tran_rec.entry_value15 := l_tran_tab.varchar2_value(i);
		end if;
		i := i + 1;
	end loop;
	--
	-- for update date input values
	-- pay_element_entry_api.create_element_entry and update_element_entry don't accept canonical date format
	-- canonical date format must be converted to display date format
	-- if the api will be fixed in the future, following lines can be removed
	if l_tran_rec.commutation_type = 'TRAIN' and l_tran_rec.entry_value11 is not null then
		l_tran_rec.entry_value11 := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_tran_rec.entry_value11));
	elsif l_tran_rec.commutation_type = 'CAR' and l_tran_rec.entry_value12 is not null then
		l_tran_rec.entry_value12 := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_tran_rec.entry_value12));
	end if;
	--
	-- Some flex fields use the session values
	hr_util_misc_web.insert_session_row(l_tran_rec.effective_date);
	--
	if l_tran_rec.action_type = 'INSERT' then
		--
		pay_element_entry_api.create_element_entry
		(
			p_validate              => p_validate,
			p_effective_date        => l_tran_rec.effective_date,
			p_business_group_id     => l_tran_rec.business_group_id,
			p_assignment_id         => l_tran_rec.assignment_id,
			p_element_link_id       => l_tran_rec.element_link_id,
			p_entry_type            => l_tran_rec.entry_type,
			p_attribute_category    => l_tran_rec.attribute_category,
			p_attribute1            => l_tran_rec.attribute1,
			p_attribute2            => l_tran_rec.attribute2,
			p_attribute3            => l_tran_rec.attribute3,
			p_attribute4            => l_tran_rec.attribute4,
			p_attribute5            => l_tran_rec.attribute5,
			p_attribute6            => l_tran_rec.attribute6,
			p_attribute7            => l_tran_rec.attribute7,
			p_attribute8            => l_tran_rec.attribute8,
			p_attribute9            => l_tran_rec.attribute9,
			p_attribute10           => l_tran_rec.attribute10,
			p_attribute11           => l_tran_rec.attribute11,
			p_attribute12           => l_tran_rec.attribute12,
			p_attribute13           => l_tran_rec.attribute13,
			p_attribute14           => l_tran_rec.attribute14,
			p_attribute15           => l_tran_rec.attribute15,
			p_attribute16           => l_tran_rec.attribute16,
			p_attribute17           => l_tran_rec.attribute17,
			p_attribute18           => l_tran_rec.attribute18,
			p_attribute19           => l_tran_rec.attribute19,
			p_attribute20           => l_tran_rec.attribute20,
			p_input_value_id1       => l_tran_rec.input_value_id1,
			p_input_value_id2       => l_tran_rec.input_value_id2,
			p_input_value_id3       => l_tran_rec.input_value_id3,
			p_input_value_id4       => l_tran_rec.input_value_id4,
			p_input_value_id5       => l_tran_rec.input_value_id5,
			p_input_value_id6       => l_tran_rec.input_value_id6,
			p_input_value_id7       => l_tran_rec.input_value_id7,
			p_input_value_id8       => l_tran_rec.input_value_id8,
			p_input_value_id9       => l_tran_rec.input_value_id9,
			p_input_value_id10      => l_tran_rec.input_value_id10,
			p_input_value_id11      => l_tran_rec.input_value_id11,
			p_input_value_id12      => l_tran_rec.input_value_id12,
			p_input_value_id13      => l_tran_rec.input_value_id13,
			p_input_value_id14      => l_tran_rec.input_value_id14,
			p_input_value_id15      => l_tran_rec.input_value_id15,
			p_entry_value1          => l_tran_rec.entry_value1,
			p_entry_value2          => l_tran_rec.entry_value2,
			p_entry_value3          => l_tran_rec.entry_value3,
			p_entry_value4          => l_tran_rec.entry_value4,
			p_entry_value5          => l_tran_rec.entry_value5,
			p_entry_value6          => l_tran_rec.entry_value6,
			p_entry_value7          => l_tran_rec.entry_value7,
			p_entry_value8          => l_tran_rec.entry_value8,
			p_entry_value9          => l_tran_rec.entry_value9,
			p_entry_value10         => l_tran_rec.entry_value10,
			p_entry_value11         => l_tran_rec.entry_value11,
			p_entry_value12         => l_tran_rec.entry_value12,
			p_entry_value13         => l_tran_rec.entry_value13,
			p_entry_value14         => l_tran_rec.entry_value14,
			p_entry_value15         => l_tran_rec.entry_value15,
			p_effective_start_date  => l_effective_start_date,
			p_effective_end_date    => l_effective_end_date,
			p_element_entry_id      => l_element_entry_id,
			p_object_version_number => l_object_version_number,
			p_create_warning        => l_warning
		);
		--
	elsif l_tran_rec.action_type = 'UPDATE' then
		--
		l_object_version_number := l_tran_rec.object_version_number;
		--
		pay_element_entry_api.update_element_entry
		(
			p_validate              => p_validate,
			p_datetrack_update_mode => l_tran_rec.date_track_option,
			p_effective_date        => l_tran_rec.effective_date,
			p_business_group_id     => l_tran_rec.business_group_id,
			p_element_entry_id      => l_tran_rec.element_entry_id,
			p_object_version_number => l_object_version_number,
			p_attribute_category    => l_tran_rec.attribute_category,
			p_attribute1            => l_tran_rec.attribute1,
			p_attribute2            => l_tran_rec.attribute2,
			p_attribute3            => l_tran_rec.attribute3,
			p_attribute4            => l_tran_rec.attribute4,
			p_attribute5            => l_tran_rec.attribute5,
			p_attribute6            => l_tran_rec.attribute6,
			p_attribute7            => l_tran_rec.attribute7,
			p_attribute8            => l_tran_rec.attribute8,
			p_attribute9            => l_tran_rec.attribute9,
			p_attribute10           => l_tran_rec.attribute10,
			p_attribute11           => l_tran_rec.attribute11,
			p_attribute12           => l_tran_rec.attribute12,
			p_attribute13           => l_tran_rec.attribute13,
			p_attribute14           => l_tran_rec.attribute14,
			p_attribute15           => l_tran_rec.attribute15,
			p_attribute16           => l_tran_rec.attribute16,
			p_attribute17           => l_tran_rec.attribute17,
			p_attribute18           => l_tran_rec.attribute18,
			p_attribute19           => l_tran_rec.attribute19,
			p_attribute20           => l_tran_rec.attribute20,
			p_input_value_id1       => l_tran_rec.input_value_id1,
			p_input_value_id2       => l_tran_rec.input_value_id2,
			p_input_value_id3       => l_tran_rec.input_value_id3,
			p_input_value_id4       => l_tran_rec.input_value_id4,
			p_input_value_id5       => l_tran_rec.input_value_id5,
			p_input_value_id6       => l_tran_rec.input_value_id6,
			p_input_value_id7       => l_tran_rec.input_value_id7,
			p_input_value_id8       => l_tran_rec.input_value_id8,
			p_input_value_id9       => l_tran_rec.input_value_id9,
			p_input_value_id10      => l_tran_rec.input_value_id10,
			p_input_value_id11      => l_tran_rec.input_value_id11,
			p_input_value_id12      => l_tran_rec.input_value_id12,
			p_input_value_id13      => l_tran_rec.input_value_id13,
			p_input_value_id14      => l_tran_rec.input_value_id14,
			p_input_value_id15      => l_tran_rec.input_value_id15,
			p_entry_value1          => l_tran_rec.entry_value1,
			p_entry_value2          => l_tran_rec.entry_value2,
			p_entry_value3          => l_tran_rec.entry_value3,
			p_entry_value4          => l_tran_rec.entry_value4,
			p_entry_value5          => l_tran_rec.entry_value5,
			p_entry_value6          => l_tran_rec.entry_value6,
			p_entry_value7          => l_tran_rec.entry_value7,
			p_entry_value8          => l_tran_rec.entry_value8,
			p_entry_value9          => l_tran_rec.entry_value9,
			p_entry_value10         => l_tran_rec.entry_value10,
			p_entry_value11         => l_tran_rec.entry_value11,
			p_entry_value12         => l_tran_rec.entry_value12,
			p_entry_value13         => l_tran_rec.entry_value13,
			p_entry_value14         => l_tran_rec.entry_value14,
			p_entry_value15         => l_tran_rec.entry_value15,
			p_effective_start_date  => l_effective_start_date,
			p_effective_end_date    => l_effective_end_date,
			p_update_warning        => l_warning
		);
		--
	elsif l_tran_rec.action_type = 'DELETE' then
		--
		l_object_version_number := l_tran_rec.object_version_number;
		--
		pay_element_entry_api.delete_element_entry
		(
			p_validate              => p_validate,
			p_datetrack_delete_mode => l_tran_rec.date_track_option,
			p_effective_date        => l_tran_rec.effective_date,
			p_element_entry_id      => l_tran_rec.element_entry_id,
			p_object_version_number => l_object_version_number,
			p_effective_start_date  => l_effective_start_date,
			p_effective_end_date    => l_effective_end_date,
			p_delete_warning        => l_warning
		);
		--
	end if;
	--
end process_api;
--
procedure get_txn_value(
  p_transaction_step_id in number,
  p_name                in varchar2,
  p_varchar2_value      out nocopy varchar2,
  p_date_value          out nocopy date,
  p_number_value        out nocopy number)
--
is
--
  cursor csr_txn_value
  is
  select name,
         datatype,
         varchar2_value,
         date_value,
         number_value
  from   hr_api_transaction_values
  where  transaction_step_id = p_transaction_step_id;
--
  l_txn_value_tbl_cnt number := 0;
--
begin
--
  p_varchar2_value := null;
  p_date_value := null;
  p_number_value := null;
--
  if nvl(g_transaction_step_id,-1) <> p_transaction_step_id
     or g_txn_value_tbl.count = 0 then
  --
    g_txn_value_tbl.delete;
  --
    -- #2243411 bulk collect bug fix is available from 9.2
    open csr_txn_value;
    -- fetch csr_txn_value bulk collect into l_txn_value_tbl;
    loop
    --
      fetch csr_txn_value into g_txn_value_tbl(l_txn_value_tbl_cnt);
      exit when csr_txn_value%notfound;
    --
      l_txn_value_tbl_cnt := l_txn_value_tbl_cnt + 1;
    --
    end loop;
    --
    close csr_txn_value;
  --
    g_transaction_step_id := p_transaction_step_id;
  --
  end if;
  --
  if g_txn_value_tbl.count > 0 then
  --
    <<txn_value_loop>>
    for txn_value_cnt in g_txn_value_tbl.first..g_txn_value_tbl.last loop
    --
      if g_txn_value_tbl(txn_value_cnt).name = p_name then
      --
        if g_txn_value_tbl(txn_value_cnt).datatype = c_varchar2 then
        --
          p_varchar2_value := g_txn_value_tbl(txn_value_cnt).varchar2_value;
        --
        elsif g_txn_value_tbl(txn_value_cnt).datatype = c_date then
        --
          p_date_value := g_txn_value_tbl(txn_value_cnt).date_value;
        --
        elsif g_txn_value_tbl(txn_value_cnt).datatype = c_number then
        --
          p_number_value := g_txn_value_tbl(txn_value_cnt).number_value;
        --
        end if;
      --
        exit txn_value_loop;
      --
      end if;
    --
    end loop;
  --
  end if;
--
end get_txn_value;
--
function get_txn_value_char(
  p_transaction_step_id in number,
  p_name                in varchar2)
return varchar2
is
--
  l_value_char hr_api_transaction_values.varchar2_value%type;
  l_value_date hr_api_transaction_values.date_value%type;
  l_value_number hr_api_transaction_values.number_value%type;
--
begin
--
  get_txn_value(
    p_transaction_step_id => p_transaction_step_id,
    p_name                => p_name,
    p_varchar2_value      => l_value_char,
    p_date_value          => l_value_date,
    p_number_value        => l_value_number);
--
  return l_value_char;
--
end get_txn_value_char;
--
function get_txn_value_date(
  p_transaction_step_id in number,
  p_name                in varchar2)
return date
is
--
  l_value_char hr_api_transaction_values.varchar2_value%type;
  l_value_date hr_api_transaction_values.date_value%type;
  l_value_number hr_api_transaction_values.number_value%type;
--
begin
--
  get_txn_value(
    p_transaction_step_id => p_transaction_step_id,
    p_name                => p_name,
    p_varchar2_value      => l_value_char,
    p_date_value          => l_value_date,
    p_number_value        => l_value_number);
--
  return l_value_date;
--
end get_txn_value_date;
--
function get_txn_value_number(
  p_transaction_step_id in number,
  p_name                in varchar2)
return number
is
--
  l_value_char hr_api_transaction_values.varchar2_value%type;
  l_value_date hr_api_transaction_values.date_value%type;
  l_value_number hr_api_transaction_values.number_value%type;
--
begin
--
  get_txn_value(
    p_transaction_step_id => p_transaction_step_id,
    p_name                => p_name,
    p_varchar2_value      => l_value_char,
    p_date_value          => l_value_date,
    p_number_value        => l_value_number);
--
  return l_value_number;
--
end get_txn_value_number;
--
end pay_jp_process_cmi_ss;

/
