--------------------------------------------------------
--  DDL for Package OTA_CPE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CPE_UTIL" AUTHID CURRENT_USER as
/* $Header: otcpewrs.pkh 120.19.12010000.5 2010/03/24 06:10:27 pekasi ship $ */

--  ---------------------------------------------------------------------------
--  |----------------------< chk_cert_prd_compl    >--------------------------|
--  ---------------------------------------------------------------------------
--

-- {Start Of Comments}
--
--  Description:
--
--  Prerequisites:
--
--
--  In Arguments:
--
--
--  Post Success:
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
Function chk_cert_prd_compl(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type)
return varchar2;

Procedure crt_comp_upd_succ_att(p_event_id in ota_events.event_id%type,
                                p_person_id in number
                               );

Function is_cert_success_complete(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
p_cert_period_start_date in ota_cert_prd_enrollments.cert_period_start_date%type,
p_cert_period_end_date in ota_cert_prd_enrollments.cert_period_start_date%type,
p_person_id in number)
return varchar2;

Procedure update_cpe_status(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type
                            ,p_certification_status_code OUT NOCOPY VARCHAR2
                            ,p_enroll_from in varchar2 default null
                            ,p_cert_period_end_date   in ota_cert_prd_enrollments.cert_period_end_date%type default null
                            ,p_child_update_flag      in varchar2 default 'Y'
                            ,p_completion_date in date default sysdate);

--  ---------------------------------------------------------------------------
--  |----------------------< is_period_renewable       >-------------------------|
--  ---------------------------------------------------------------------------
--  Returns whether a certification period is renewable or not

-- {Start Of Comments}
--
--  Description:
--
--  Prerequisites:
--
--
--  In Arguments:
-- p_cert_enrollment_id
--
--  Post Success:
--
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
function is_period_renewable(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type)
return varchar2;

--  ---------------------------------------------------------------------------
--  |----------------------< calc_cre_dates       >-------------------------|
--  ---------------------------------------------------------------------------
--  Returns the earliest enroll date and expiration date for the passed
--cert_enrollment_id and certification_id
--  Based on is_initial_flag would return first or next earliest enroll date
--and expiration date's

-- {Start Of Comments}
--
--  Description:
--
--  Prerequisites:
--
--
--  In Arguments:
-- p_cert_enrollment_id
-- p_certification_id
-- p_mode
--
--  Post Success:
-- p_earliest_enroll_date
-- p_expiration_date
--  Post Failure:
--
--
--  Access Status:
--    Internal Development Use Only.
--
-- {End Of Comments}
--  ---------------------------------------------------------------------------
PROCEDURE calc_cre_dates(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
                         p_certification_id  in ota_cert_enrollments.certification_id%type,
                         p_mode in varchar2,
                         p_earliest_enroll_date  OUT nocopy ota_cert_enrollments.earliest_enroll_date%type,
	                     p_expiration_date  OUT nocopy ota_cert_enrollments.expiration_date%type,
                         p_cert_period_start_date in date default sysdate);

Function get_next_prd_dur_days(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
                               p_cert_period_start_date in date default sysdate)
return varchar2;

FUNCTION get_cert_mbr_status (p_cert_mbr_id in ota_certification_members.certification_member_id%TYPE,
			      p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
			      p_code in number default 1)
RETURN varchar2;

FUNCTION get_cert_mbr_name (p_cert_mbr_id in ota_certification_members.certification_member_id%TYPE)
RETURN varchar2;

FUNCTION get_cre_status (p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%TYPE,
                         p_mode in varchar2 default 'm')
RETURN varchar2;

FUNCTION get_cpe_edit_enabled(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE)
RETURN varchar2;

FUNCTION chk_prd_end_date(p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%TYPE,
                          p_cert_period_end_date in ota_cert_prd_enrollments.cert_period_end_date%TYPE,
                          p_mass_update_flag in varchar2 default 'N') return varchar2;

procedure create_cpe_rec(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%type,
			 p_expiration_date in date,
			 p_cert_period_start_date in date default sysdate,
       		 p_cert_prd_enrollment_id OUT NOCOPY ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
       		 p_certification_status_code OUT NOCOPY VARCHAR2,
	         p_is_recert in varchar2 default 'N');

PROCEDURE delete_prd_cascade(p_cert_prd_enrollment_id IN ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                             p_return_code OUT NOCOPY varchar2);

procedure update_admin_changes(p_cert_enrollment_id in ota_cert_prd_enrollments.cert_enrollment_id%type,
			       p_cert_prd_enrollment_id in ota_cert_prd_enrollments.cert_prd_enrollment_id%type,
                               p_certification_status_code in ota_cert_enrollments.certification_status_code%type,
			       p_cert_period_end_date   in ota_cert_prd_enrollments.cert_period_end_date%type default null,
                               p_return_status out NOCOPY VARCHAR2,
                               p_cert_period_completion_date   in ota_cert_prd_enrollments.completion_date%type default trunc(sysdate) );

Procedure update_cert_status_to_expired(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2);

Procedure sync_cert_status_to_class_enrl(
      ERRBUF OUT NOCOPY  VARCHAR2,
      RETCODE OUT NOCOPY VARCHAR2);

FUNCTION get_latest_cpe_col(p_cert_enrollment_id in ota_cert_enrollments.cert_enrollment_id%TYPE,
                         p_col_name in varchar2 default 'Period_Status_Meaning') return varchar2;

function get_elapsed_due_date(p_certification_id in ota_certifications_b.certification_id%type) return date;

function check_active_periods(p_event_id in ota_events.event_id%type) return varchar2;

procedure sync_late_subsc_to_class;

END OTA_CPE_UTIL;


/
