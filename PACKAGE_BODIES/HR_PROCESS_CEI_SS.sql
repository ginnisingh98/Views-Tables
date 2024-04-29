--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_CEI_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_CEI_SS" as
/* $Header: hrceiwrs.pkb 120.0 2005/05/30 23:10 appldev noship $ */

function get_row_status
(
	p_contact_extra_info_id in number,
	p_effective_date        in date
) return varchar2 is
	--
	l_row_status         varchar2(20);
	l_dummy              varchar2(1);
	l_effective_end_date date;
	--
begin
	--
	l_dummy := 'N';
	--
	begin
		--
		select
			effective_end_date
		into
			l_effective_end_date
		from
			per_contact_extra_info_f
		where
			contact_extra_info_id = p_contact_extra_info_id
			and
			p_effective_date
				between
					effective_start_date
					and
					effective_end_date
			and
			effective_end_date <> to_date('31/12/4712', 'DD/MM/YYYY');
		--
		begin
			--
			select
				'Y'
			into
				l_dummy
			from
				per_contact_extra_info_f
			where
				contact_extra_info_id = p_contact_extra_info_id
				and
				l_effective_end_date + 1
					between
						effective_start_date
						and
						effective_end_date;
			--
			l_row_status := 'FUTURE_CHANGE_ROW';
			--
		exception
			when no_data_found then
				l_row_status := 'FUTURE_DELETE_ROW';
		end;
		--
	exception
		when no_data_found then
			l_row_status := 'DB_ROW';
	end;
	--
	return l_row_status;
	--
end get_row_status;

procedure set_transaction_step
(
	p_item_type               in         varchar2,
	p_item_key                in         varchar2,
	p_activity_id             in         number,
	p_login_person_id         in         number,
	p_action                  in         varchar2, -- 'INSERT' or 'UPDATE' or 'DELETE'
	p_effective_date          in         date     default null,
	p_date_track_option       in         varchar2 default null,
	p_contact_extra_info_id   in         number   default null,
	p_contact_relationship_id in         number   default null,
	p_information_type        in         varchar2 default null,
	p_object_version_number   in         number   default null,
	p_information_category    in         varchar2 default null,
	p_information1            in         varchar2 default null,
	p_information2            in         varchar2 default null,
	p_information3            in         varchar2 default null,
	p_information4            in         varchar2 default null,
	p_information5            in         varchar2 default null,
	p_information6            in         varchar2 default null,
	p_information7            in         varchar2 default null,
	p_information8            in         varchar2 default null,
	p_information9            in         varchar2 default null,
	p_information10           in         varchar2 default null,
	p_information11           in         varchar2 default null,
	p_information12           in         varchar2 default null,
	p_information13           in         varchar2 default null,
	p_information14           in         varchar2 default null,
	p_information15           in         varchar2 default null,
	p_information16           in         varchar2 default null,
	p_information17           in         varchar2 default null,
	p_information18           in         varchar2 default null,
	p_information19           in         varchar2 default null,
	p_information20           in         varchar2 default null,
	p_information21           in         varchar2 default null,
	p_information22           in         varchar2 default null,
	p_information23           in         varchar2 default null,
	p_information24           in         varchar2 default null,
	p_information25           in         varchar2 default null,
	p_information26           in         varchar2 default null,
	p_information27           in         varchar2 default null,
	p_information28           in         varchar2 default null,
	p_information29           in         varchar2 default null,
	p_information30           in         varchar2 default null,
	p_attribute_category      in         varchar2 default null,
	p_attribute1              in         varchar2 default null,
	p_attribute2              in         varchar2 default null,
	p_attribute3              in         varchar2 default null,
	p_attribute4              in         varchar2 default null,
	p_attribute5              in         varchar2 default null,
	p_attribute6              in         varchar2 default null,
	p_attribute7              in         varchar2 default null,
	p_attribute8              in         varchar2 default null,
	p_attribute9              in         varchar2 default null,
	p_attribute10             in         varchar2 default null,
	p_attribute11             in         varchar2 default null,
	p_attribute12             in         varchar2 default null,
	p_attribute13             in         varchar2 default null,
	p_attribute14             in         varchar2 default null,
	p_attribute15             in         varchar2 default null,
	p_attribute16             in         varchar2 default null,
	p_attribute17             in         varchar2 default null,
	p_attribute18             in         varchar2 default null,
	p_attribute19             in         varchar2 default null,
	p_attribute20             in         varchar2 default null
) is

	l_date_format         varchar2(10);
	l_api_name            varchar2(100);

	l_transaction_table   hr_transaction_ss.transaction_table;
	l_count               number := 0;

	l_transaction_step_id number;
	l_review_item_name    varchar2(50);

begin

	l_date_format := hr_transaction_ss.g_date_format;
	l_api_name    := 'HR_PROCESS_CEI_SS.PROCESS_API';

	l_review_item_name :=
		wf_engine.GetActivityAttrText
		(
			itemtype => p_item_type,
			itemkey  => p_item_key,
			actid    => p_activity_id,
			aname    => 'HR_REVIEW_REGION_ITEM'
		);

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
 	l_transaction_table(l_count).param_value := l_review_item_name;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
 	l_transaction_table(l_count).param_value := p_activity_id;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';
/*
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_VALIDATE';
	l_transaction_table(l_count).param_value := 0;
	l_transaction_table(l_count).param_data_type := 'NUMBER';
*/
	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ACTION';
	l_transaction_table(l_count).param_value := p_action;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
	l_transaction_table(l_count).param_value := to_char(p_effective_date, l_date_format);
	l_transaction_table(l_count).param_data_type := 'DATE';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_DATE_TRACK_OPTION';
	l_transaction_table(l_count).param_value := p_date_track_option;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_EXTRA_INFO_ID';
	l_transaction_table(l_count).param_value := p_contact_extra_info_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_CONTACT_RELATIONSHIP_ID';
	l_transaction_table(l_count).param_value := p_contact_relationship_id;
	l_transaction_table(l_count).param_data_type := 'NUMBER';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION_TYPE';
	l_transaction_table(l_count).param_value := p_information_type;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
	l_transaction_table(l_count).param_value := p_object_version_number;
	l_transaction_table(l_count).param_data_type := 'NUMBER';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION_CATEGORY';
	l_transaction_table(l_count).param_value := p_information_category;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION1';
	l_transaction_table(l_count).param_value := p_information1;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION2';
	l_transaction_table(l_count).param_value := p_information2;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION3';
	l_transaction_table(l_count).param_value := p_information3;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION4';
	l_transaction_table(l_count).param_value := p_information4;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION5';
	l_transaction_table(l_count).param_value := p_information5;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION6';
	l_transaction_table(l_count).param_value := p_information6;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION7';
	l_transaction_table(l_count).param_value := p_information7;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION8';
	l_transaction_table(l_count).param_value := p_information8;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION9';
	l_transaction_table(l_count).param_value := p_information9;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION10';
	l_transaction_table(l_count).param_value := p_information10;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION11';
	l_transaction_table(l_count).param_value := p_information11;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION12';
	l_transaction_table(l_count).param_value := p_information12;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION13';
	l_transaction_table(l_count).param_value := p_information13;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION14';
	l_transaction_table(l_count).param_value := p_information14;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION15';
	l_transaction_table(l_count).param_value := p_information15;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION16';
	l_transaction_table(l_count).param_value := p_information16;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION17';
	l_transaction_table(l_count).param_value := p_information17;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION18';
	l_transaction_table(l_count).param_value := p_information18;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION19';
	l_transaction_table(l_count).param_value := p_information19;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION20';
	l_transaction_table(l_count).param_value := p_information20;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION21';
	l_transaction_table(l_count).param_value := p_information21;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION22';
	l_transaction_table(l_count).param_value := p_information22;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION23';
	l_transaction_table(l_count).param_value := p_information23;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION24';
	l_transaction_table(l_count).param_value := p_information24;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION25';
	l_transaction_table(l_count).param_value := p_information25;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION26';
	l_transaction_table(l_count).param_value := p_information26;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION27';
	l_transaction_table(l_count).param_value := p_information27;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION28';
	l_transaction_table(l_count).param_value := p_information28;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION29';
	l_transaction_table(l_count).param_value := p_information29;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_INFORMATION30';
	l_transaction_table(l_count).param_value := p_information30;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
	l_transaction_table(l_count).param_value := p_attribute_category;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
	l_transaction_table(l_count).param_value := p_attribute1;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
	l_transaction_table(l_count).param_value := p_attribute2;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
	l_transaction_table(l_count).param_value := p_attribute3;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
	l_transaction_table(l_count).param_value := p_attribute4;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
	l_transaction_table(l_count).param_value := p_attribute5;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
	l_transaction_table(l_count).param_value := p_attribute6;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
	l_transaction_table(l_count).param_value := p_attribute7;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
	l_transaction_table(l_count).param_value := p_attribute8;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
	l_transaction_table(l_count).param_value := p_attribute9;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
	l_transaction_table(l_count).param_value := p_attribute10;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
	l_transaction_table(l_count).param_value := p_attribute11;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
	l_transaction_table(l_count).param_value := p_attribute12;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
	l_transaction_table(l_count).param_value := p_attribute13;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
	l_transaction_table(l_count).param_value := p_attribute14;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
	l_transaction_table(l_count).param_value := p_attribute15;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
	l_transaction_table(l_count).param_value := p_attribute16;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
	l_transaction_table(l_count).param_value := p_attribute17;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
	l_transaction_table(l_count).param_value := p_attribute18;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
	l_transaction_table(l_count).param_value := p_attribute19;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
	l_transaction_table(l_count).param_value := p_attribute20;
	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

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

end set_transaction_step;

/*
-- ----------------------------------------------------------------------------
-- |-----------------------< del_transaction_data >---------------------------|
-- Wrapper Package for API hr_process_sit_ss.
--
-- Description:
--  This Function dels the transaction data for the given item type, item key
--  and activity id.
-- ----------------------------------------------------------------------------
procedure del_transaction_data
(
	p_item_type       in varchar2,
	p_item_key        in varchar2,
	p_activity_id     in varchar2,
	p_login_person_id in varchar2,
) is

begin

	hr_transaction_ss.delete_transaction_steps
	(
		p_item_type       => p_item_type,
		p_item_key        => p_item_key,
		p_actid           => p_activity_id,
		p_login_person_id => p_login_person_id
	);

end del_transaction_data;
*/

procedure process_api
(
	p_validate            in boolean  default false,
	p_transaction_step_id in number   default null,
	p_effective_date      in varchar2 default null
) is

	-- for return values from out parameters
	l_contact_extra_info_id number;
	l_object_version_number number;
	l_effective_start_date  date;
	l_effective_end_date    date;

	l_action                varchar2(30);
	l_effective_date        date;
	l_date_track_option     varchar2(30);

	l_tran_tab              hr_transaction_ss.transaction_data;
	l_tran_rec              per_contact_extra_info_f%rowtype;

	i                       number;

begin

	-- get taransaction data
	hr_transaction_ss.get_transaction_data
	(
		p_transaction_step_id => p_transaction_step_id,
		p_transaction_data    => l_tran_tab
	);

	i := l_tran_tab.name.first;

	loop
		exit when not(l_tran_tab.name.exists(i));
		if l_tran_tab.name(i) in ('P_REVIEW_PROC_CALL', 'P_REVIEW_ACTID') then
			null;
		elsif l_tran_tab.name(i) = 'P_ACTION' then
			l_action := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_EFFECTIVE_DATE' then
			l_effective_date := l_tran_tab.date_value(i);
		elsif l_tran_tab.name(i) = 'P_DATE_TRACK_OPTION' then
			l_date_track_option := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_EXTRA_INFO_ID' then
			l_tran_rec.contact_extra_info_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_CONTACT_RELATIONSHIP_ID' then
			l_tran_rec.contact_relationship_id := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION_TYPE' then
			l_tran_rec.information_type := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_OBJECT_VERSION_NUMBER' then
			l_tran_rec.object_version_number := l_tran_tab.number_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION_CATEGORY' then
			l_tran_rec.cei_information_category := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION1' then
			l_tran_rec.cei_information1 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION2' then
			l_tran_rec.cei_information2 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION3' then
			l_tran_rec.cei_information3 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION4' then
			l_tran_rec.cei_information4 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION5' then
			l_tran_rec.cei_information5 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION6' then
			l_tran_rec.cei_information6 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION7' then
			l_tran_rec.cei_information7 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION8' then
			l_tran_rec.cei_information8 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION9' then
			l_tran_rec.cei_information9 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION10' then
			l_tran_rec.cei_information10 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION11' then
			l_tran_rec.cei_information11 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION12' then
			l_tran_rec.cei_information12 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION13' then
			l_tran_rec.cei_information13 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION14' then
			l_tran_rec.cei_information14 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION15' then
			l_tran_rec.cei_information15 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION16' then
			l_tran_rec.cei_information16 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION17' then
			l_tran_rec.cei_information17 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION18' then
			l_tran_rec.cei_information18 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION19' then
			l_tran_rec.cei_information19 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION20' then
			l_tran_rec.cei_information20 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION21' then
			l_tran_rec.cei_information21 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION22' then
			l_tran_rec.cei_information22 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION23' then
			l_tran_rec.cei_information23 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION24' then
			l_tran_rec.cei_information24 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION25' then
			l_tran_rec.cei_information25 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION26' then
			l_tran_rec.cei_information26 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION27' then
			l_tran_rec.cei_information27 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION28' then
			l_tran_rec.cei_information28 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION29' then
			l_tran_rec.cei_information29 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_INFORMATION30' then
			l_tran_rec.cei_information30 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE_CATEGORY' then
			l_tran_rec.cei_attribute_category := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE1' then
			l_tran_rec.cei_attribute1 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE2' then
			l_tran_rec.cei_attribute2 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE3' then
			l_tran_rec.cei_attribute3 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE4' then
			l_tran_rec.cei_attribute4 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE5' then
			l_tran_rec.cei_attribute5 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE6' then
			l_tran_rec.cei_attribute6 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE7' then
			l_tran_rec.cei_attribute7 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE8' then
			l_tran_rec.cei_attribute8 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE9' then
			l_tran_rec.cei_attribute9 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE10' then
			l_tran_rec.cei_attribute10 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE11' then
			l_tran_rec.cei_attribute11 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE12' then
			l_tran_rec.cei_attribute12 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE13' then
			l_tran_rec.cei_attribute13 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE14' then
			l_tran_rec.cei_attribute14 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE15' then
			l_tran_rec.cei_attribute15 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE16' then
			l_tran_rec.cei_attribute16 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE17' then
			l_tran_rec.cei_attribute17 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE18' then
			l_tran_rec.cei_attribute18 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE19' then
			l_tran_rec.cei_attribute19 := l_tran_tab.varchar2_value(i);
		elsif l_tran_tab.name(i) = 'P_ATTRIBUTE20' then
			l_tran_rec.cei_attribute20 := l_tran_tab.varchar2_value(i);
		end if;
		i := i + 1;
	end loop;

    hr_util_misc_web.insert_session_row(l_effective_date);

	if l_action = 'INSERT' then

		hr_contact_extra_info_api.create_contact_extra_info
		(
			p_validate                 => p_validate,
			p_effective_date           => l_effective_date,
			p_contact_relationship_id  => l_tran_rec.contact_relationship_id,
			p_information_type         => l_tran_rec.information_type,
			p_cei_information_category => l_tran_rec.cei_information_category,
			p_cei_information1         => l_tran_rec.cei_information1,
			p_cei_information2         => l_tran_rec.cei_information2,
			p_cei_information3         => l_tran_rec.cei_information3,
			p_cei_information4         => l_tran_rec.cei_information4,
			p_cei_information5         => l_tran_rec.cei_information5,
			p_cei_information6         => l_tran_rec.cei_information6,
			p_cei_information7         => l_tran_rec.cei_information7,
			p_cei_information8         => l_tran_rec.cei_information8,
			p_cei_information9         => l_tran_rec.cei_information9,
			p_cei_information10        => l_tran_rec.cei_information10,
			p_cei_information11        => l_tran_rec.cei_information11,
			p_cei_information12        => l_tran_rec.cei_information12,
			p_cei_information13        => l_tran_rec.cei_information13,
			p_cei_information14        => l_tran_rec.cei_information14,
			p_cei_information15        => l_tran_rec.cei_information15,
			p_cei_information16        => l_tran_rec.cei_information16,
			p_cei_information17        => l_tran_rec.cei_information17,
			p_cei_information18        => l_tran_rec.cei_information18,
			p_cei_information19        => l_tran_rec.cei_information19,
			p_cei_information20        => l_tran_rec.cei_information20,
			p_cei_information21        => l_tran_rec.cei_information21,
			p_cei_information22        => l_tran_rec.cei_information22,
			p_cei_information23        => l_tran_rec.cei_information23,
			p_cei_information24        => l_tran_rec.cei_information24,
			p_cei_information25        => l_tran_rec.cei_information25,
			p_cei_information26        => l_tran_rec.cei_information26,
			p_cei_information27        => l_tran_rec.cei_information27,
			p_cei_information28        => l_tran_rec.cei_information28,
			p_cei_information29        => l_tran_rec.cei_information29,
			p_cei_information30        => l_tran_rec.cei_information30,
			p_cei_attribute_category   => l_tran_rec.cei_attribute_category,
			p_cei_attribute1           => l_tran_rec.cei_attribute1,
			p_cei_attribute2           => l_tran_rec.cei_attribute2,
			p_cei_attribute3           => l_tran_rec.cei_attribute3,
			p_cei_attribute4           => l_tran_rec.cei_attribute4,
			p_cei_attribute5           => l_tran_rec.cei_attribute5,
			p_cei_attribute6           => l_tran_rec.cei_attribute6,
			p_cei_attribute7           => l_tran_rec.cei_attribute7,
			p_cei_attribute8           => l_tran_rec.cei_attribute8,
			p_cei_attribute9           => l_tran_rec.cei_attribute9,
			p_cei_attribute10          => l_tran_rec.cei_attribute10,
			p_cei_attribute11          => l_tran_rec.cei_attribute11,
			p_cei_attribute12          => l_tran_rec.cei_attribute12,
			p_cei_attribute13          => l_tran_rec.cei_attribute13,
			p_cei_attribute14          => l_tran_rec.cei_attribute14,
			p_cei_attribute15          => l_tran_rec.cei_attribute15,
			p_cei_attribute16          => l_tran_rec.cei_attribute16,
			p_cei_attribute17          => l_tran_rec.cei_attribute17,
			p_cei_attribute18          => l_tran_rec.cei_attribute18,
			p_cei_attribute19          => l_tran_rec.cei_attribute19,
			p_cei_attribute20          => l_tran_rec.cei_attribute20,
			p_contact_extra_info_id    => l_contact_extra_info_id,
			p_object_version_number    => l_object_version_number,
			p_effective_start_date     => l_effective_start_date,
			p_effective_end_date       => l_effective_end_date
		);

	elsif l_action = 'UPDATE' then

		hr_contact_extra_info_api.update_contact_extra_info
		(
			p_validate                 => p_validate,
			p_effective_date           => l_effective_date,
			p_datetrack_update_mode    => l_date_track_option,
			p_contact_extra_info_id    => l_tran_rec.contact_extra_info_id,
			p_contact_relationship_id  => l_tran_rec.contact_relationship_id,
			p_information_type         => l_tran_rec.information_type,
			p_object_version_number    => l_tran_rec.object_version_number,
			p_cei_information_category => l_tran_rec.cei_information_category,
			p_cei_information1         => l_tran_rec.cei_information1,
			p_cei_information2         => l_tran_rec.cei_information2,
			p_cei_information3         => l_tran_rec.cei_information3,
			p_cei_information4         => l_tran_rec.cei_information4,
			p_cei_information5         => l_tran_rec.cei_information5,
			p_cei_information6         => l_tran_rec.cei_information6,
			p_cei_information7         => l_tran_rec.cei_information7,
			p_cei_information8         => l_tran_rec.cei_information8,
			p_cei_information9         => l_tran_rec.cei_information9,
			p_cei_information10        => l_tran_rec.cei_information10,
			p_cei_information11        => l_tran_rec.cei_information11,
			p_cei_information12        => l_tran_rec.cei_information12,
			p_cei_information13        => l_tran_rec.cei_information13,
			p_cei_information14        => l_tran_rec.cei_information14,
			p_cei_information15        => l_tran_rec.cei_information15,
			p_cei_information16        => l_tran_rec.cei_information16,
			p_cei_information17        => l_tran_rec.cei_information17,
			p_cei_information18        => l_tran_rec.cei_information18,
			p_cei_information19        => l_tran_rec.cei_information19,
			p_cei_information20        => l_tran_rec.cei_information20,
			p_cei_information21        => l_tran_rec.cei_information21,
			p_cei_information22        => l_tran_rec.cei_information22,
			p_cei_information23        => l_tran_rec.cei_information23,
			p_cei_information24        => l_tran_rec.cei_information24,
			p_cei_information25        => l_tran_rec.cei_information25,
			p_cei_information26        => l_tran_rec.cei_information26,
			p_cei_information27        => l_tran_rec.cei_information27,
			p_cei_information28        => l_tran_rec.cei_information28,
			p_cei_information29        => l_tran_rec.cei_information29,
			p_cei_information30        => l_tran_rec.cei_information30,
			p_cei_attribute_category   => l_tran_rec.cei_attribute_category,
			p_cei_attribute1           => l_tran_rec.cei_attribute1,
			p_cei_attribute2           => l_tran_rec.cei_attribute2,
			p_cei_attribute3           => l_tran_rec.cei_attribute3,
			p_cei_attribute4           => l_tran_rec.cei_attribute4,
			p_cei_attribute5           => l_tran_rec.cei_attribute5,
			p_cei_attribute6           => l_tran_rec.cei_attribute6,
			p_cei_attribute7           => l_tran_rec.cei_attribute7,
			p_cei_attribute8           => l_tran_rec.cei_attribute8,
			p_cei_attribute9           => l_tran_rec.cei_attribute9,
			p_cei_attribute10          => l_tran_rec.cei_attribute10,
			p_cei_attribute11          => l_tran_rec.cei_attribute11,
			p_cei_attribute12          => l_tran_rec.cei_attribute12,
			p_cei_attribute13          => l_tran_rec.cei_attribute13,
			p_cei_attribute14          => l_tran_rec.cei_attribute14,
			p_cei_attribute15          => l_tran_rec.cei_attribute15,
			p_cei_attribute16          => l_tran_rec.cei_attribute16,
			p_cei_attribute17          => l_tran_rec.cei_attribute17,
			p_cei_attribute18          => l_tran_rec.cei_attribute18,
			p_cei_attribute19          => l_tran_rec.cei_attribute19,
			p_cei_attribute20          => l_tran_rec.cei_attribute20,
			p_effective_start_date     => l_effective_start_date,
			p_effective_end_date       => l_effective_end_date
		);

	elsif l_action = 'DELETE' then

		hr_contact_extra_info_api.delete_contact_extra_info
		(
			p_validate              => p_validate,
			p_effective_date        => l_effective_date,
			p_datetrack_delete_mode => l_date_track_option,
			p_contact_extra_info_id => l_tran_rec.contact_extra_info_id,
			p_object_version_number => l_tran_rec.object_version_number,
			p_effective_start_date  => l_effective_start_date,
			p_effective_end_date    => l_effective_end_date
		);

	end if;

end process_api;

end hr_process_cei_ss;

/
