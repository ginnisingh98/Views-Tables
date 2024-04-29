--------------------------------------------------------
--  DDL for Package AME_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: amedrtpg.pkh 120.0.12010000.4 2018/04/17 06:34:00 demodak noship $ */
  TYPE process_record_type IS RECORD (person_id    number(15)
                                     ,entity_type  varchar2(3)
                                     ,status       varchar2(1)
                                     ,msgcode      varchar2(30)
                                     ,msgaplid     number(15));

  TYPE result_tbl_type IS TABLE OF process_record_type INDEX BY binary_integer;

  g_process_tbl result_tbl_type;

  PROCEDURE write_log
    (message       IN         varchar2
		,stage		 IN					varchar2);

  PROCEDURE add_to_results
    (person_id       IN         number
		,entity_type		 IN					varchar2
		,status 				 IN					varchar2
		,msgcode				 IN					varchar2
		,msgaplid				 IN					number
     ,result_tbl    	 IN OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ame_hr_drc
    (person_id       IN         number
   ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ame_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ame_fnd_drc
    (person_id       IN         number
     ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

 end ame_drt_pkg;

/
