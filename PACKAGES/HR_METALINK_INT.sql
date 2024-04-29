--------------------------------------------------------
--  DDL for Package HR_METALINK_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_METALINK_INT" AUTHID CURRENT_USER as
/* $Header: hrmtlint.pkh 115.0 2003/01/07 17:29:16 menderby noship $ */


FUNCTION get_url (p_note_id IN VARCHAR2)
  RETURN VARCHAR2;


END hr_metalink_int;

 

/
