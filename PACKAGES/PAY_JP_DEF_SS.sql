--------------------------------------------------------
--  DDL for Package PAY_JP_DEF_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_DEF_SS" AUTHID CURRENT_USER as
/* $Header: pyjpdefs.pkh 120.2.12010000.3 2009/10/14 13:32:10 keyazawa ship $ */
--
g_business_group_id number;
--
-- Private procedures for debugging purpose
--
/*
function ee_datetrack_update_mode(
	p_element_entry_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2;
function cei_datetrack_update_mode(
	p_contact_extra_info_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2;
function cei_datetrack_delete_mode(
	p_contact_extra_info_id		in number,
	p_effective_start_date		in date,
	p_effective_end_date		in date,
	p_effective_date		in date) return varchar2;
function full_name(
	p_person_id			in number,
	p_effective_date		in date) return varchar2;
procedure insert_session(p_effective_date in date);
procedure delete_session;
function changed(
	value1		in varchar2,
	value2		in varchar2) return boolean;
function get_sqlerrm return varchar2;
*/
function check_submission_period(p_action_information_id in number) return date;
procedure check_submission_period(p_action_information_id in number);
--
-- Web Interface Procedures
--
-- |---------------------------------------------------------------------------|
-- |--------------------------------< do_init >--------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_init(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number);
procedure do_init(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_finalize >------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_finalize(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_user_comments			in varchar2);
procedure do_finalize(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_user_comments			in varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_reject >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_reject(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2);
procedure do_reject(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_return >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_return(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2);
procedure do_return(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_admin_comments		in varchar2,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_approve >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_approve(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number);
procedure do_approve(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2);
--
procedure do_approve(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2);
-- |---------------------------------------------------------------------------|
-- |------------------------------< do_transfer >------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_create_session		in boolean default true);
procedure do_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2);
--
procedure do_transfer(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2);
-- |---------------------------------------------------------------------------|
-- |---------------------------< rollback_transfer >---------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_create_session		in boolean default true);
procedure rollback_transfer(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |-------------------------------< do_expire >-------------------------------|
-- |---------------------------------------------------------------------------|
procedure do_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_expiry_date			in date);
procedure do_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_expiry_date			in date,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |----------------------------< rollback_expire >----------------------------|
-- |---------------------------------------------------------------------------|
procedure rollback_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number);
procedure rollback_expire(
	p_action_information_id		in number,
	p_object_version_number		in out nocopy number,
	p_return_status			out nocopy varchar2);
-- |---------------------------------------------------------------------------|
-- |--------------------------< delete_unfinalized >---------------------------|
-- |---------------------------------------------------------------------------|
procedure delete_unfinalized(
	errbuf				out nocopy varchar2,
	retcode				out nocopy varchar2,
	p_payroll_action_id		in varchar2);
--
end pay_jp_def_ss;

/
