--------------------------------------------------------
--  DDL for Package PAY_EMEA_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EMEA_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: pydrtemea.pkh 120.0.12010000.5 2018/04/11 14:06:36 simarsin noship $ */
  --
/*
  TYPE process_record_type IS RECORD (person_id    number(15)
                                     ,entity_type  varchar2(3)
                                     ,status       varchar2(1)
                                     ,msgcode      varchar2(30)
                                     ,msgaplid     number(15));

TYPE result_tbl_type IS TABLE OF process_record_type INDEX BY binary_integer;
*/
g_process_tbl per_drt_pkg.result_tbl_type;

PROCEDURE add_to_results
	  (person_id   IN            number
	  ,entity_type IN            varchar2
	  ,status      IN            varchar2
	  ,msgcode     IN            varchar2
	  ,msgaplid    IN            number
	  ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type);

PROCEDURE pay_emea_hr_drc
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

PROCEDURE pay_final_process_check
    (p_person_id       IN         number
    ,p_legislation_code IN varchar2
    ,p_constraint_months IN number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

PROCEDURE pay_emea_hr_post
  (p_person_id IN number);

END PAY_EMEA_DRT_PKG;

/
