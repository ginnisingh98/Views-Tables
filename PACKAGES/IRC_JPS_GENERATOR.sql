--------------------------------------------------------
--  DDL for Package IRC_JPS_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JPS_GENERATOR" AUTHID CURRENT_USER as
/* $Header: irjpsgen.pkh 120.0.12010000.1 2008/07/28 12:47:35 appldev ship $ */
function generateJPS(p_person_id in number
                    ,p_stylesheet varchar2 default null) return clob;
procedure show_resume(p number,s varchar2);
procedure save_candidate_resume(p_person_id in number
                               ,p_stylesheet in varchar2
                               ,p_assignment_id in number default null
                               ,p_overwrite boolean default true);
end;

/
