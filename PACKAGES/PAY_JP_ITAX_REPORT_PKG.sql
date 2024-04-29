--------------------------------------------------------
--  DDL for Package PAY_JP_ITAX_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ITAX_REPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpirep.pkh 120.5.12000000.3 2007/04/05 06:41:06 ttagawa noship $ */
--
procedure init(
	p_tax_year			in number   default null,
	p_itax_organization_id		in number   default null,
	p_exclude_ineligible_flag	in varchar2 default null,
	p_include_terminated_flag	in varchar2 default null,
	p_termination_date_from		in date     default null,
	p_termination_date_to		in date     default null,
	p_assignment_set_id		in number   default null,
	p_action_information_id1	in number   default null,
	p_action_information_id2	in number   default null,
	p_action_information_id3	in number   default null,
	p_action_information_id4	in number   default null,
	p_action_information_id5	in number   default null,
	p_action_information_id6	in number   default null,
	p_action_information_id7	in number   default null,
	p_action_information_id8	in number   default null,
	p_action_information_id9	in number   default null,
	p_action_information_id10	in number   default null,
	p_sort_order			in varchar2 default null,
	p_chunk_size			in number   default 100);
--
-- Check by clob.isEmpltyLob whether null or not.
--
function getXML return clob;
--
function getXML(p_action_information_id in number) return clob;
--
PROCEDURE  gen_bulk_xml(
	p_archive_id	in varchar2,
	p_xml		out nocopy clob);
--
PROCEDURE  gen_per_xml(
	p_archive_id	in varchar2,
	p_year		out nocopy number,
	p_xml		out nocopy clob);
--
END;

 

/
