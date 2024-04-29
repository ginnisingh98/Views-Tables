--------------------------------------------------------
--  DDL for Package PAY_APAC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_APAC_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: pyapacdrt.pkh 120.0.12010000.4 2018/04/12 04:52:13 mdubasi noship $ */
  --
PROCEDURE write_log
    (message IN varchar2
    ,stage   IN varchar2);

PROCEDURE add_to_results
	  (person_id   IN            number
	  ,entity_type IN            varchar2
	  ,status      IN            varchar2
	  ,msgcode     IN            varchar2
	  ,msgaplid    IN            number
	  ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type);

PROCEDURE PAY_APAC_HR_DRC
    (person_id       IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

PROCEDURE PAY_APAC_HR_POST
  (p_person_id IN number);

END PAY_APAC_DRT_PKG;

/
