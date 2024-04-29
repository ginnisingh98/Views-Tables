--------------------------------------------------------
--  DDL for Package IRC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_DRT_PKG" AUTHID CURRENT_USER as
/* $Header: ircdrtpg.pkh 120.0.12010000.4 2018/04/16 17:55:59 ktithy noship $ */
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

  PROCEDURE irc_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE irc_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE irc_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

FUNCTION overwrite_recruiter_full_name
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

FUNCTION overwrite_recruiter_email
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

FUNCTION overwrite_recruiter_work_phone
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

FUNCTION overwrite_manager_full_name
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

FUNCTION overwrite_manager_email
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

FUNCTION overwrite_manager_work_phone
    (rid         IN varchar2
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

END IRC_DRT_PKG;


/
