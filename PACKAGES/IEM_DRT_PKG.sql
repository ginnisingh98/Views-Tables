--------------------------------------------------------
--  DDL for Package IEM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: iemdrtps.pls 120.0.12010000.2 2018/04/03 06:52:48 ygandrot noship $*/
  --
  --- Wrapper aroun FND_LOG package to write into log file (when debugging is on)
  --
    PROCEDURE write_log
      (message       IN         varchar2
      ,stage         IN                 varchar2);
  --
  --- Add a warning/error record to the table
  --
 /* PROCEDURE add_to_results
    (person_id       IN         number
    ,entity_type     IN         varchar2
    ,status          IN         varchar2
    ,msgcode         IN         varchar2
    ,msgaplid        IN         number
    ,result_tbl      IN OUT NOCOPY per_drt_pkg.result_tbl_type);
	*/
  --
  --- Define record structure
  --
  --
  PROCEDURE iem_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE iem_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE iem_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
END iem_drt_pkg;

/
