--------------------------------------------------------
--  DDL for Package GHR_NON_SF52_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_NON_SF52_EXTRA_INFO" AUTHID CURRENT_USER AS
/* $Header: ghddfdef.pkh 120.0.12010000.3 2009/03/11 06:28:45 vmididho ship $ */

--------------------------------------------------------------------------------------------------------------
---------------------------------------< populate_noa_spec_extra_info > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--   To populate/ update the pa_request_extra_info table , based on the first, second noa, position , person ,
--    effective date
--   Also determine if there is a need to delete the existing extra info ,if it is not relevant to the
--   current changes in the pa_request
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

Procedure populate_noa_spec_extra_info
(p_pa_request_id        in   number,
 p_first_noa_id         in   number,
 p_second_noa_id        in   number,
 p_person_id      	in   per_people_f.person_id%type,
 p_assignment_id  	in   per_assignments_f.assignment_id%type,
 p_position_id    	in   per_positions.position_id%type,
 p_effective_date 	in   ghr_pa_requests.effective_date%type,
 p_refresh_flag         in   varchar2 default 'Y'
);
--

--------------------------------------------------------------------------------------------------------------
---------------------------------------< fetch_noa_spec_extra_info > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--   To fetch noa specific extra information for the specific noa code
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------


 Procedure fetch_noa_spec_extra_info
(p_pa_request_id        in   number,
 p_noa_id    		in   number,
 p_person_id      	in   per_people_f.person_id%type,
 p_assignment_id  	in   per_assignments_f.assignment_id%type,
 p_position_id    	in   per_positions.position_id%type,
 p_effective_date 	in   ghr_pa_requests.effective_date%type,
 p_refresh_flag         in   varchar2 default 'Y'
);

--------------------------------------------------------------------------------------------------------------
---------------------------------------< fetch_generic_extra_info > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--   To fetch noa generic extra information , dependent on the person
--    As of now, only 2 such info types are fetched
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------


Procedure fetch_generic_extra_info
(p_pa_request_id        in  number,
 p_person_id            in  number,
 p_assignment_id        in  number,
 p_effective_date       in  date,
 p_refresh_flag         in  varchar2 default 'Y'
);
--

--------------------------------------------------------------------------------------------------------------
---------------------------------------< get_information_type > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--  REturns the information type associated with the the given noa code
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------


Procedure get_information_type
(p_noa_id          in      ghr_nature_of_actions.nature_of_action_id%type,
 p_information_type  out NOCOPY ghr_pa_request_info_types.information_type%type
);
--

--------------------------------------------------------------------------------------------------------------
---------------------------------------< determine_operation > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--  To determine whether to create/ update / delete the pa request extra information
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------

Procedure determine_operation
(p_pa_request_id            in    ghr_pa_requests.pa_request_id%type,
 p_information_type         in    ghr_pa_request_info_types.information_type%type,
 p_update_rei               in    varchar2,
 p_rei_rec                  in    ghr_pa_request_extra_info%rowtype,
 p_operation_flag           out NOCOPY  varchar2,
 p_pa_request_extra_info_id out NOCOPY ghr_pa_request_extra_info.pa_request_extra_info_id%type,
 p_object_version_number    out NOCOPY ghr_pa_requests.object_version_number%type
 );
--

--------------------------------------------------------------------------------------------------------------
---------------------------------------< generic_populate_extra_info > --------------------------------------
--------------------------------------------------------------------------------------------------------------


-- {Start of Comments}
--
-- Description:
--   Perform Create/ update/ delete of pa_request_extra_info record depending on the flag value passed
--
-- Prerequisites:
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------


Procedure generic_populate_extra_info
(p_rei_rec           in    ghr_pa_request_extra_info%rowtype,
 p_org_rec           in    ghr_pa_request_ei_shadow%rowtype,
 p_flag              in    varchar2
);


Procedure set_ei
(p_original     in out NOCOPY varchar2,
 p_as_in_core   in     varchar2,
 p_as_in_ddf    in out NOCOPY varchar2,
 p_refresh_flag in     varchar2 default 'Y'
);

--6850492
procedure dual_extra_info_refresh(p_first_corr_pa_request_id in number,
                                  p_second_corr_pa_request_id in number,
			          p_first_noa_code in varchar2,
  			          p_second_noa_code in varchar2,
				  p_upd_info_type  in varchar2,
				  p_dual_corr_yn in varchar);
procedure set_dual_ei
                      (p_first_original     in     varchar2,
                       p_first_as_in_ddf    in     varchar2,
                       p_sec_original       in     varchar2,
                       p_sec_as_in_ddf      in out NOCOPY varchar2);

--6850492
end GHR_NON_SF52_EXTRA_INFO;

/
