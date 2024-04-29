--------------------------------------------------------
--  DDL for Package PQH_NR_ALIEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_NR_ALIEN_PKG" AUTHID CURRENT_USER as
/* $Header: pqhnrinf.pkh 115.1 2002/04/23 13:15:11 pkm ship        $ */

function get_count_nr_alien(
			p_person_id 	number,
			p_report_date   date)
		return varchar2;
end;

 

/
