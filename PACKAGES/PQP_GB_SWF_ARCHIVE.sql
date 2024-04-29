--------------------------------------------------------
--  DDL for Package PQP_GB_SWF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_SWF_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pqpgbswfar.pkh 120.0.12010000.2 2010/02/03 08:58:26 dwkrishn noship $ */

-- public procedure which archives the payroll information, then returns a
-- varchar2 defining a sql statement to select all the people that may be
-- eligible for swf processing.
-- the archiver uses this cursor to split the people into chunks for parallel
-- processing.
procedure range_cursor     (pactid  in number,
                            sqlstr  out nocopy varchar2);
-- checks if an assignment action is created for given payroll_acion_id and assignment_id


procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number) ;
--
procedure archive_code (p_assactid         in   number,
                        p_effective_date   in   date);
--
procedure deinit_code(pactid in number);

procedure archinit(p_payroll_action_id in number);

end pqp_gb_swf_archive;

/
