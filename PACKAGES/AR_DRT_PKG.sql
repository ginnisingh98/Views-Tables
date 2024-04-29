--------------------------------------------------------
--  DDL for Package AR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ARDRTPKS.pls 120.0.12010000.2 2018/03/29 08:02:20 bibeura noship $ */

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
    ,msgtext      varchar2(2000));

  --
  --- Define PL/SQL table type based on record type process_record_type.
  --- Table type is defined in package header to allow teams defining their
  --- table with this table type.
  --

 TYPE result_tbl_type IS
    TABLE OF process_record_type INDEX BY binary_integer;
  --
  --- Implement AR Core specific DRC for Entity Type HR
  --

  --
  --- Add a warning/error record to the table
  --
  PROCEDURE add_to_results
    (  person_id     IN     number
	    ,entity_type	 IN			varchar2
	    ,status 		   IN			varchar2
     	,msgcode		   IN			varchar2
	    ,msgaplid		   IN			number
     ,result_tbl     IN OUT NOCOPY result_tbl_type);
*/

 PROCEDURE ar_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE ar_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE ar_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
END ar_drt_pkg;

/
