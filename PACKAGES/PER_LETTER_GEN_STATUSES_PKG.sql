--------------------------------------------------------
--  DDL for Package PER_LETTER_GEN_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_LETTER_GEN_STATUSES_PKG" AUTHID CURRENT_USER as
/* $Header: pelts01t.pkh 115.0 99/07/18 14:01:57 porting ship $ */

PROCEDURE ASSIGNMENT_STATUS_NOT_UNIQUE(p_business_group_id       in number,
			             p_assignment_status_type_id in number,
				     p_letter_type_id            in number,
				     p_letter_gen_status_id      in number);
--
PROCEDURE get_next_sequence(p_letter_gen_status_id     in out number);
--
PROCEDURE get_assignment_status(p_assignment_status_type_id in number,
                                p_assignment_status in out varchar2);
--
END PER_LETTER_GEN_STATUSES_PKG;

 

/
