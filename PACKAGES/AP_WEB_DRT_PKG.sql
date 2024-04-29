--------------------------------------------------------
--  DDL for Package AP_WEB_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxdrts.pls 120.2.12010000.3 2018/06/22 06:55:34 abonthu noship $ */
  --
  --- Wrapper around FND_LOG package to write into log file (when debugging is on)
  --
    PROCEDURE write_log
      (message       IN         varchar2
	  ,stage		 IN					varchar2);


  PROCEDURE oie_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
PROCEDURE oie_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
PROCEDURE oie_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
END ap_web_drt_pkg;

/
