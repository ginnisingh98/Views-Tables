--------------------------------------------------------
--  DDL for Package PAY_FR_SETTLEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_SETTLEMENT" AUTHID CURRENT_USER AS
/* $Header: pyfrsett.pkh 115.3 2003/07/08 16:16:12 sfmorris noship $ */

function get_payment(p_assignment_id number,
                     p_effective_date date) return number;
--
function format_address(p_complement varchar2,
                        p_road varchar2,
                        p_small_town varchar2,
                        p_postal_code varchar2,
                        p_town_or_city varchar2) return varchar2;
--
function format_full_name(p_title varchar2,
                          p_first_name varchar2,
                          p_last_name varchar2) return varchar2;
--
/*
Procedure process(errbuf              OUT NOCOPY VARCHAR2,
                  retcode             OUT NOCOPY NUMBER,
 	   	  p_start_date	      IN DATE,
		  p_end_date 	      IN DATE,
                  p_set_or_asg        IN VARCHAR2,
		  p_dummy             IN VARCHAR2,
                  p_dummy1            IN VARCHAR2,
                  p_assignment_set_id IN NUMBER,
		  p_assignment_id     IN NUMBER,
                  p_separator         IN VARCHAR2);

*/
end PAY_FR_SETTLEMENT;

 

/
