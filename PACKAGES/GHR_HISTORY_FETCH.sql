--------------------------------------------------------
--  DDL for Package GHR_HISTORY_FETCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_HISTORY_FETCH" AUTHID CURRENT_USER as
/* $Header: ghhisfet.pkh 120.0.12010000.4 2009/06/04 07:37:29 vmididho ship $ */

g_info_type    per_position_extra_info.information_type%type := NULL;
g_cascad_eff_date  ghr_pa_history.effective_date%type;

	Procedure fetch_people (
		p_person_id					in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_people_data				out nocopy 	per_all_people_f%rowtype,
		p_result_code				out nocopy 	varchar2);

	Procedure fetch_asgei (
		p_assignment_extra_info_id		in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
            p_get_ovn_flag                      in    varchar2    default 'N',
		p_asgei_data				out nocopy 	per_assignment_extra_info%rowtype,
		p_result_code				out nocopy 	varchar2) ;

     Procedure fetch_asgei (
     		p_assignment_id                     in    number,
            p_information_type                  in    varchar2,
            p_date_effective      			in  	date,
            p_asg_ei_data                       out nocopy    per_assignment_extra_info%rowtype);

     Procedure get_date_eff_eleevl(
		p_element_entry_value_id	in	number,
		p_date_effective			in 	date,
		p_element_entry_data		out nocopy 	pay_element_entry_values_f%rowtype,
		p_result_code			out nocopy 	varchar2,
		p_pa_history_id			out nocopy 	number);

	Procedure fetch_assignment (
		p_assignment_id				in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_assignment_data				out nocopy 	per_all_assignments_f%rowtype,
		p_result_code				out nocopy 	varchar2);

	Procedure fetch_peopleei (
		p_person_extra_info_id			in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
            p_get_ovn_flag                      in    varchar2    default 'N',
		p_peopleei_data				in out nocopy 	per_people_extra_info%rowtype,
		p_result_code				out nocopy 	varchar2);

     Procedure fetch_peopleei(
     		p_person_id           in  number,
            p_information_type    in  varchar2,
            p_date_effective      in  date,
            p_per_ei_data         in out nocopy  per_people_extra_info%rowtype);

     Procedure fetch_positionei (
		p_position_extra_info_id		in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
            p_get_ovn_flag                      in    varchar2    default 'N',
		p_posei_data				out nocopy 	per_position_extra_info%rowtype,
		p_result_code				out nocopy 	varchar2 ) ;

	Procedure fetch_positionei(
		p_position_id     in  number,
            p_information_type    in  varchar2,
            p_date_effective      in  date,
            p_pos_ei_data         out nocopy  per_position_extra_info%rowtype
      ) ;

     Procedure fetch_position (
		p_position_id			in	number	default null,
		p_date_effective			in	date		default null,
		p_altered_pa_request_id		in	number	default null,
		p_noa_id_corrected		in	number	default null,
		p_rowid				in	rowid		default null,
		p_pa_history_id			in	number	default null,
            p_get_ovn_flag                in    varchar2    default 'N',
		p_position_data			out nocopy 	hr_all_positions_f%rowtype,
		p_result_code			out nocopy 	varchar2 ) ;

	Procedure fetch_element_entries (
		p_element_entry_id			in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_element_entry_data			out nocopy 	pay_element_entries_f%rowtype,
		p_result_code				out nocopy 	varchar2 );

	Procedure fetch_element_entry_value (
		p_element_entry_value_id		in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_element_entry_data			out nocopy 	pay_element_entry_values_f%rowtype,
		p_result_code				out nocopy 	varchar2 );

	Procedure fetch_element_entry_value(
		p_element_name              in   pay_element_types_f.element_name%type,
	      p_input_value_name          in   pay_input_values_f.name%type,
	      p_assignment_id             in   per_assignments_f.assignment_id%type,
  		p_date_effective            in   date,
            p_screen_entry_value        out nocopy   pay_element_entry_values_f.screen_entry_value%type );


      Procedure fetch_element_info_cor (
		p_element_name      		in     pay_element_types_f.element_name%type
		,p_input_value_name  		in     pay_input_values_f.name%type
		,p_assignment_id     		in     pay_element_entries_f.assignment_id%type
		,p_effective_date    		in     date
		,p_element_link_id      	out nocopy  pay_element_links_f.element_link_id%type
		,p_input_value_id       	out nocopy  pay_input_values_f.input_value_id%type
		,p_element_entry_id     	out nocopy  pay_element_entries_f.element_entry_id%type
		,p_value                	out nocopy  pay_element_entry_values_f.screen_entry_value%type
		,p_object_version_number 	out nocopy  pay_element_entries_f.object_version_number%type  );


	Procedure fetch_person_analyses (
		p_person_analysis_id			in	number	default null,
		p_date_effective				in	date		default null,
		p_altered_pa_request_id			in	number	default null,
		p_noa_id_corrected			in	number	default null,
		p_rowid					in	rowid		default null,
		p_pa_history_id				in	number	default null,
		p_peranalyses_data			out nocopy 	per_person_analyses%rowtype,
		p_result_code				out nocopy 	varchar2 );


	Procedure fetch_positionei (
		p_position_extra_info_id     in out nocopy     number
		,p_date_effective             in out nocopy     date
		,p_position_id                  out nocopy      number
		,p_information_type             out nocopy      varchar2
		,p_request_id                   out nocopy      number
		,p_program_application_id       out nocopy      number
		,p_program_id                   out nocopy      number
		,p_program_update_date          out nocopy      date
		,p_poei_attribute_category      out nocopy      varchar2
		,p_poei_attribute1              out nocopy      varchar2
		,p_poei_attribute2              out nocopy      varchar2
		,p_poei_attribute3              out nocopy      varchar2
		,p_poei_attribute4              out nocopy      varchar2
		,p_poei_attribute5              out nocopy      varchar2
		,p_poei_attribute6              out nocopy      varchar2
		,p_poei_attribute7              out nocopy      varchar2
		,p_poei_attribute8              out nocopy      varchar2
		,p_poei_attribute9              out nocopy      varchar2
		,p_poei_attribute10             out nocopy      varchar2
		,p_poei_attribute11             out nocopy      varchar2
		,p_poei_attribute12             out nocopy      varchar2
		,p_poei_attribute13             out nocopy      varchar2
		,p_poei_attribute14             out nocopy      varchar2
		,p_poei_attribute15             out nocopy      varchar2
		,p_poei_attribute16             out nocopy      varchar2
		,p_poei_attribute17             out nocopy      varchar2
		,p_poei_attribute18             out nocopy      varchar2
		,p_poei_attribute19             out nocopy      varchar2
		,p_poei_attribute20             out nocopy      varchar2
		,p_poei_information_category    out nocopy      varchar2
		,p_poei_information1            out nocopy      varchar2
		,p_poei_information2            out nocopy      varchar2
		,p_poei_information3            out nocopy      varchar2
		,p_poei_information4            out nocopy      varchar2
		,p_poei_information5            out nocopy      varchar2
		,p_poei_information6            out nocopy      varchar2
		,p_poei_information7            out nocopy      varchar2
		,p_poei_information8            out nocopy      varchar2
		,p_poei_information9            out nocopy      varchar2
		,p_poei_information10           out nocopy      varchar2
		,p_poei_information11           out nocopy      varchar2
		,p_poei_information12           out nocopy      varchar2
		,p_poei_information13           out nocopy      varchar2
		,p_poei_information14           out nocopy      varchar2
		,p_poei_information15           out nocopy      varchar2
		,p_poei_information16           out nocopy      varchar2
		,p_poei_information17           out nocopy      varchar2
		,p_poei_information18           out nocopy      varchar2
		,p_poei_information19           out nocopy      varchar2
		,p_poei_information20           out nocopy      varchar2
		,p_poei_information21           out nocopy      varchar2
		,p_poei_information22           out nocopy      varchar2
		,p_poei_information23           out nocopy      varchar2
		,p_poei_information24           out nocopy      varchar2
		,p_poei_information25           out nocopy      varchar2
		,p_poei_information26           out nocopy      varchar2
		,p_poei_information27           out nocopy      varchar2
		,p_poei_information28           out nocopy      varchar2
		,p_poei_information29           out nocopy      varchar2
		,p_poei_information30           out nocopy      varchar2
		,p_object_version_number        out nocopy      number
		,p_last_update_date             out nocopy      date
		,p_last_updated_by              out nocopy      number
		,p_last_update_login            out nocopy      number
		,p_created_by                   out nocopy      number
		,p_creation_date                out nocopy      date
		,p_result_code                  out nocopy      varchar2
		);

	Procedure fetch_peopleei (
		 p_person_extra_info_id       in out nocopy     number
		,p_date_effective             in out nocopy     date
		,p_person_id                    out nocopy      number
		,p_information_type             out nocopy      varchar2
		,p_request_id                   out nocopy      number
		,p_program_application_id       out nocopy      number
		,p_program_id                   out nocopy      number
		,p_program_update_date          out nocopy      date
		,p_pei_attribute_category       out nocopy      varchar2
		,p_pei_attribute1               out nocopy      varchar2
		,p_pei_attribute2               out nocopy      varchar2
		,p_pei_attribute3               out nocopy      varchar2
		,p_pei_attribute4               out nocopy      varchar2
		,p_pei_attribute5               out nocopy      varchar2
		,p_pei_attribute6               out nocopy      varchar2
		,p_pei_attribute7               out nocopy      varchar2
		,p_pei_attribute8               out nocopy      varchar2
		,p_pei_attribute9               out nocopy      varchar2
		,p_pei_attribute10              out nocopy      varchar2
		,p_pei_attribute11              out nocopy      varchar2
		,p_pei_attribute12              out nocopy      varchar2
		,p_pei_attribute13              out nocopy      varchar2
		,p_pei_attribute14              out nocopy      varchar2
		,p_pei_attribute15              out nocopy      varchar2
		,p_pei_attribute16              out nocopy      varchar2
		,p_pei_attribute17              out nocopy      varchar2
		,p_pei_attribute18              out nocopy      varchar2
		,p_pei_attribute19              out nocopy      varchar2
		,p_pei_attribute20              out nocopy      varchar2
		,p_pei_information_category     out nocopy      varchar2
		,p_pei_information1             out nocopy      varchar2
		,p_pei_information2             out nocopy      varchar2
		,p_pei_information3             out nocopy      varchar2
		,p_pei_information4             out nocopy      varchar2
		,p_pei_information5             out nocopy      varchar2
		,p_pei_information6             out nocopy      varchar2
		,p_pei_information7             out nocopy      varchar2
		,p_pei_information8             out nocopy      varchar2
		,p_pei_information9             out nocopy      varchar2
		,p_pei_information10            out nocopy      varchar2
		,p_pei_information11            out nocopy      varchar2
		,p_pei_information12            out nocopy      varchar2
		,p_pei_information13            out nocopy      varchar2
		,p_pei_information14            out nocopy      varchar2
		,p_pei_information15            out nocopy      varchar2
		,p_pei_information16            out nocopy      varchar2
		,p_pei_information17            out nocopy      varchar2
		,p_pei_information18            out nocopy      varchar2
		,p_pei_information19            out nocopy      varchar2
		,p_pei_information20            out nocopy      varchar2
		,p_pei_information21            out nocopy      varchar2
		,p_pei_information22            out nocopy      varchar2
		,p_pei_information23            out nocopy      varchar2
		,p_pei_information24            out nocopy      varchar2
		,p_pei_information25            out nocopy      varchar2
		,p_pei_information26            out nocopy      varchar2
		,p_pei_information27            out nocopy      varchar2
		,p_pei_information28            out nocopy      varchar2
		,p_pei_information29            out nocopy      varchar2
		,p_pei_information30            out nocopy      varchar2
		,p_object_version_number        out nocopy      number
		,p_last_update_date             out nocopy      date
		,p_last_updated_by              out nocopy      number
		,p_last_update_login            out nocopy      number
		,p_created_by                   out nocopy      number
		,p_creation_date                out nocopy      date
		,p_result_code                  out nocopy      varchar2
	);

	Procedure fetch_asgei (
		 p_assignment_extra_info_id  in out nocopy     number
		,p_date_effective            in out nocopy     date
		,p_assignment_id                out nocopy      number
		,p_information_type             out nocopy      varchar2
		,p_request_id                   out nocopy      number
		,p_program_application_id       out nocopy      number
		,p_program_id                   out nocopy      number
		,p_program_update_date          out nocopy      date
		,p_aei_attribute_category       out nocopy      varchar2
		,p_aei_attribute1               out nocopy      varchar2
		,p_aei_attribute2               out nocopy      varchar2
		,p_aei_attribute3               out nocopy      varchar2
		,p_aei_attribute4               out nocopy      varchar2
		,p_aei_attribute5               out nocopy      varchar2
		,p_aei_attribute6               out nocopy      varchar2
		,p_aei_attribute7               out nocopy      varchar2
		,p_aei_attribute8               out nocopy      varchar2
		,p_aei_attribute9               out nocopy      varchar2
		,p_aei_attribute10              out nocopy      varchar2
		,p_aei_attribute11              out nocopy      varchar2
		,p_aei_attribute12              out nocopy      varchar2
		,p_aei_attribute13              out nocopy      varchar2
		,p_aei_attribute14              out nocopy      varchar2
		,p_aei_attribute15              out nocopy      varchar2
		,p_aei_attribute16              out nocopy      varchar2
		,p_aei_attribute17              out nocopy      varchar2
		,p_aei_attribute18              out nocopy      varchar2
		,p_aei_attribute19              out nocopy      varchar2
		,p_aei_attribute20              out nocopy      varchar2
		,p_aei_information_category     out nocopy      varchar2
		,p_aei_information1             out nocopy      varchar2
		,p_aei_information2             out nocopy      varchar2
		,p_aei_information3             out nocopy      varchar2
		,p_aei_information4             out nocopy      varchar2
		,p_aei_information5             out nocopy      varchar2
		,p_aei_information6             out nocopy      varchar2
		,p_aei_information7             out nocopy      varchar2
		,p_aei_information8             out nocopy      varchar2
		,p_aei_information9             out nocopy      varchar2
		,p_aei_information10            out nocopy      varchar2
		,p_aei_information11            out nocopy      varchar2
		,p_aei_information12            out nocopy      varchar2
		,p_aei_information13            out nocopy      varchar2
		,p_aei_information14            out nocopy      varchar2
		,p_aei_information15            out nocopy      varchar2
		,p_aei_information16            out nocopy      varchar2
		,p_aei_information17            out nocopy      varchar2
		,p_aei_information18            out nocopy      varchar2
		,p_aei_information19            out nocopy      varchar2
		,p_aei_information20            out nocopy      varchar2
		,p_aei_information21            out nocopy      varchar2
		,p_aei_information22            out nocopy      varchar2
		,p_aei_information23            out nocopy      varchar2
		,p_aei_information24            out nocopy      varchar2
		,p_aei_information25            out nocopy      varchar2
		,p_aei_information26            out nocopy      varchar2
		,p_aei_information27            out nocopy      varchar2
		,p_aei_information28            out nocopy      varchar2
		,p_aei_information29            out nocopy      varchar2
		,p_aei_information30            out nocopy      varchar2
		,p_object_version_number        out nocopy      number
		,p_last_update_date             out nocopy      date
		,p_last_updated_by              out nocopy      number
		,p_last_update_login            out nocopy      number
		,p_created_by                   out nocopy      number
		,p_creation_date                out nocopy      date
		,p_result_code                  out nocopy      varchar2
	);

Procedure fetch_address (
	p_address_id				in	number	default null,
	p_date_effective				in	date		default null,
	p_altered_pa_request_id			in	number	default null,
	p_noa_id_corrected			in	number	default null,
	p_rowid					in	rowid		default null,
	p_pa_history_id				in	number	default null,
	p_address_data				out nocopy 	per_addresses%rowtype,
	p_result_code				out nocopy 	varchar2 );

-- ---------------------------------------------------------------------------
-- |--------------------------< return_special_information >----------------|
-- --------------------------------------------------------------------------

Procedure return_special_information(
	p_person_id       in  number,
	p_structure_name  in  varchar2,
	p_effective_date  in  date,
	p_special_info    out nocopy  ghr_api.special_information_type
);

Procedure Fetch_ASGEI_prior_root_sf50(
	p_assignment_id			in	number  ,
	p_information_type		in	varchar2,
	p_altered_pa_request_id		in	number  ,
	p_noa_id_corrected		in	number  ,
	p_date_effective		in	date		default null,
        p_get_ovn_flag                  in      varchar2    default 'N'	,
  	p_asgei_data			out nocopy 	per_assignment_extra_info%rowtype);


Procedure Fetch_asgn_prior_root_sf50(
	p_assignment_id			in	number  ,
	p_altered_pa_request_id		in	number  ,
	p_noa_id_corrected		in	number  ,
	p_date_effective		in	date		default null,
--        p_get_ovn_flag                  in      varchar2    default 'N'	,
  	p_assignment_data			out nocopy 	per_all_assignments_f%rowtype);

End GHR_HISTORY_FETCH;

/
