--------------------------------------------------------
--  DDL for Package HR_AUTH_BRIDGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AUTH_BRIDGE" AUTHID CURRENT_USER as
/* $Header: hrathbrd.pkh 115.1 2002/05/29 05:43:27 pkm ship       $ */

FUNCTION get_coverage
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_acty_typ_cd       in varchar2,
  p_type              in varchar2
  )
  RETURN varchar2;

FUNCTION get_beneficiaries
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_prmry_cntngnt_cd in varchar2
  )
  RETURN varchar2;

FUNCTION get_beneficiaries
  (
  p_prtt_enrt_rslt_id in number,
  p_per_in_ler_id     in number,
  p_prmry_cntngnt_cd  in varchar2,
  p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_primary_care_providers
  (
  p_prtt_enrt_rslt_id in number,
  p_business_group_id in number
  )
  RETURN varchar2;

FUNCTION get_primary_care_providers
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number,
   p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_interim_flag
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number
  )
  RETURN varchar2;

FUNCTION get_interim_flag
  (
   p_prtt_enrt_rslt_id in number,
   p_business_group_id in number,
   p_effective_date in date
  )
  RETURN varchar2;

FUNCTION get_contact_relationships
  (
   p_person_id         in number,
   p_contact_person_id in number
  )
  RETURN varchar2;

FUNCTION get_contact_relationships
  (
   p_person_id         in number,
   p_contact_person_id in number,
   p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_proposed_salary
  (
   p_assignment_id     in number
  )
  RETURN varchar2;

FUNCTION get_proposed_salary
  (
   p_assignment_id     in number,
   p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_salary_change_date
  (
   p_assignment_id     in number
  )
  RETURN varchar2;

FUNCTION get_salary_change_date
  (
   p_assignment_id     in number,
   p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_performance_rating
  (
   p_person_id     in number
  )
  RETURN varchar2;

FUNCTION get_performance_rating
  (
   p_person_id         in number,
   p_effective_date    in date
  )
  RETURN varchar2;

FUNCTION get_person_start_date
  (
   p_person_id                in number,
   p_period_of_service_id     in number,
   p_paf_effective_start_date in date,
   p_assignment_type          in varchar2
  )
  RETURN date;

FUNCTION get_person_start_date
  (
   p_person_id                 in number,
   p_period_of_service_id      in number,
   p_paf_effective_start_date  in date,
   p_assignment_type           in varchar2,
   p_effective_date            in date
  )
  RETURN date;

FUNCTION get_person_end_date
  (
   p_person_id              in number,
   p_period_of_service_id   in number,
   p_paf_effective_end_date in date,
   p_assignment_type        in varchar2
  )
  RETURN date;

FUNCTION get_person_end_date
  (
   p_person_id                 in number,
   p_period_of_service_id      in number,
   p_paf_effective_end_date    in date,
   p_assignment_type           in varchar2,
   p_effective_date            in date
  )
  RETURN date;

FUNCTION get_per_system_status
  (
   p_assignment_status_type_id in number
  )
  RETURN varchar2;

FUNCTION get_assignment_id
  (
  p_person_id in number
  )
RETURN number;

END hr_auth_bridge;

 

/
