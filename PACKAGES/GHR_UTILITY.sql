--------------------------------------------------------
--  DDL for Package GHR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_UTILITY" AUTHID CURRENT_USER AS
/* $Header: ghutils.pkh 120.10 2005/12/09 04:29:48 sumarimu noship $ */
--
g_position_being_deleted BOOLEAN;
--
FUNCTION is_ghr RETURN VARCHAR2;

FUNCTION is_ghr_ben RETURN VARCHAR2;

FUNCTION is_ghr_ben_fehb RETURN VARCHAR2;

FUNCTION is_ghr_ben_tsp RETURN VARCHAR2;

FUNCTION is_ghr_nfc RETURN VARCHAR2;

PROCEDURE set_client_info
( p_person_id  in per_all_people_f.person_id%type default null,
  p_position_id in hr_all_positions_f.position_id%type default null,
  p_assignment_id in per_all_assignments_f.assignment_id%type default null);

FUNCTION get_noa_code (p_nature_of_action_id IN NUMBER)
         RETURN VARCHAR2;
-- Sundar NFC Changes
FUNCTION get_flex_num(p_flex_code fnd_id_flex_structures_tl.id_flex_code%TYPE,
		       p_struct_name fnd_id_flex_structures_tl.id_flex_structure_name%TYPE) RETURN NUMBER;

FUNCTION get_pos_flex_num(p_bus_org_id hr_all_organization_units.business_group_id%type) RETURN NUMBER;

FUNCTION get_flex_delimiter(p_flex_code fnd_id_flex_segments_vl.id_flex_code%type,
			    p_flex_num fnd_id_flex_structures_vl.id_flex_num%type) RETURN VARCHAR2;

TYPE t_flex_recs IS TABLE OF FND_ID_FLEX_SEGMENTS_VL%ROWTYPE INDEX BY BINARY_INTEGER;
l_flex_recs t_flex_recs;

FUNCTION get_segments(p_flex_num fnd_id_flex_structures_tl.id_flex_num%type,
                      p_flex_code fnd_id_flex_segments_vl.id_flex_code%type) RETURN t_flex_recs;


FUNCTION return_pos_name(l_pos_title per_position_definitions.segment1%type,
			 l_pos_desc per_position_definitions.segment1%type,
			 l_seq_no per_position_definitions.segment1%type,
			 l_agency_code per_position_definitions.segment1%type,
			 l_po_id per_position_definitions.segment1%type,
			 l_grade per_position_definitions.segment1%type,
			 l_nfc_agency_code  per_position_definitions.segment1%type,
			 l_full_title hr_positions_f.name%type)
			 RETURN VARCHAR2;

FUNCTION return_nfc_pos_name(l_pos_title per_position_definitions.segment1%type,
			 l_pos_desc per_position_definitions.segment1%type,
			 l_seq_no per_position_definitions.segment1%type,
			 l_agency_code per_position_definitions.segment1%type,
			 l_po_id per_position_definitions.segment1%type,
			 l_grade per_position_definitions.segment1%type,
			 l_nfc_agency_code  per_position_definitions.segment1%type,
			 l_full_title hr_positions_f.name%type)
			 RETURN VARCHAR2;

-- End NFC Changes

PROCEDURE validate_nfc(
P_POSITION_ID in NUMBER
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2 );

PROCEDURE update_nfc_eit(
P_POSITION_ID in NUMBER
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2);


PROCEDURE validate_create_nfc(
 P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2 );

PROCEDURE validate_delete_nfc(
P_POSITION_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
);


procedure process_nfc_auth_date(
p_effective_date in ghr_pa_requests.effective_date%type,
p_pa_request_id in ghr_pa_requests.pa_request_id%type);

function get_nfc_prev_noa(
p_person_id       in per_people_f.person_id%type,
p_pa_notification_id in ghr_pa_requests.pa_notification_id%type,
p_effective_date  in ghr_pa_requests.effective_date%type)
RETURN VARCHAR2;

procedure get_nfc_auth_codes(
p_person_id       in per_people_f.person_id%type,
p_pa_notification_id in ghr_pa_requests.pa_notification_id%type,
p_effective_date  in ghr_pa_requests.effective_date%type,
p_first_auth_code out nocopy  ghr_pa_requests.FIRST_ACTION_LA_CODE1%type,
p_second_auth_code out  nocopy ghr_pa_requests.FIRST_ACTION_LA_CODE1%type);

function get_nfc_conv_action_code(
p_pa_request_id   in ghr_pa_requests.pa_request_id%type)
RETURN NUMBER;

end ghr_utility;

 

/
