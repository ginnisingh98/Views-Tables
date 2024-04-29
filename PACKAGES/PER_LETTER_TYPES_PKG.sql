--------------------------------------------------------
--  DDL for Package PER_LETTER_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_LETTER_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: peltt01t.pkh 115.0 99/07/18 14:02:03 porting ship $ */

PROCEDURE LETTER_TYPE_NOT_UNIQUE(p_letter_type       IN  VARCHAR2,
				 p_business_group_id in  number,
				 p_letter_type_id    in  number);
--
PROCEDURE check_delete_letter_type(p_letter_type_id       IN  NUMBER);
--
PROCEDURE get_next_sequence(p_letter_type_id     in out number);
--
PROCEDURE get_concurrent_program(p_concurrent_program_id in number,
		                 p_concurrent_program_name in out varchar2);
--
END PER_LETTER_TYPES_PKG;

 

/
