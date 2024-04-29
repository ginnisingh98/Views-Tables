--------------------------------------------------------
--  DDL for Package ONT_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: OEDRTUPS.pls 120.0.12010000.1 2018/03/29 20:19:10 gabhatia noship $*/
  --
  --- Wrapper aroun FND_LOG package to write into log file (when debugging is on)
  --
    PROCEDURE write_log
      (message       IN         varchar2
      ,stage		 IN                		varchar2);

  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE ont_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE ont_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  --
  --- Implement HR Core specific DRC for Entity Type HR
  --
  PROCEDURE ont_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE ont_fnd_pre
    (person_id       IN         number );

  PROCEDURE ont_hr_pre
    (person_id       IN         number   );

END ont_drt_pkg;

/
