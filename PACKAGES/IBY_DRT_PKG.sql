--------------------------------------------------------
--  DDL for Package IBY_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ibydrtpks.pls 120.0.12010000.1 2018/04/30 12:04:23 earao noship $ */
  --
  --- Wrapper around FND_LOG package to write into log file (when debugging is on)
  --
    PROCEDURE write_log
      (message       IN         varchar2
	  ,stage		 IN					varchar2);

  --
  --- Define record structure
  --
 /* TYPE process_record_type IS RECORD
    (person_id    number(15)
    ,entity_type  varchar2(3)
    ,status       varchar2(1)
    ,msgcode      varchar2(30)
    ,msgaplid      number(15));

  --
  --- Define PL/SQL table type based on record type process_record_type.
  --- Table type is defined in package header to allow teams defining their
  --- table with this table type.
  --
TYPE process_tbl_type IS
    TABLE OF process_record_type INDEX BY binary_integer;

 TYPE result_tbl_type IS
    TABLE OF process_record_type INDEX BY binary_integer;
*/


  --
  --- Add a warning/error record to the table
  --
/*  PROCEDURE add_to_results
    (person_id       IN         number
	,entity_type	 IN			varchar2
	,status 		 IN			varchar2
	,msgcode		 IN			varchar2
	,msgaplid		 IN			number
    ,result_tbl    	 IN OUT NOCOPY ap_drt_pkg.result_tbl_type);
*/

  --
  --- Implement AP Core specific DRC for Entity Type TCA
  --

  PROCEDURE iby_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

END iby_drt_pkg;

/
