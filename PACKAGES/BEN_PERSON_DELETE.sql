--------------------------------------------------------
--  DDL for Package BEN_PERSON_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_DELETE" AUTHID CURRENT_USER as
/* $Header: bepedchk.pkh 120.0 2005/05/28 10:33:11 appldev noship $ */
 procedure perform_ri_check(p_person_id in number);
procedure  delete_ben_rows(p_person_id NUMBER);
procedure  check_ben_rows_before_delete(p_person_id number ,
                                        p_effective_date date
                                        ) ;
end ben_person_delete;

 

/
