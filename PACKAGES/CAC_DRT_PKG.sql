--------------------------------------------------------
--  DDL for Package CAC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: cacdrtps.pls 120.0.12010000.1 2018/06/14 09:30:35 nmetta noship $*/
  --
  --- FND_LOG package to write into log file
  --
    PROCEDURE write_log
      (message       IN         varchar2
      ,stage         IN         varchar2);

  --- Implement Common Application Calendar Core specific DRC for Entity Type HR

  PROCEDURE cac_hr_drc
    (person_id       IN         number
    ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);
  --
  --- Implement Common Application Calendar Core specific DRC for Entity Type TCA
  --
  PROCEDURE cac_tca_drc
    (person_id       IN         number
    ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);
  --
  --- Implement Common Application Calendar Core specific DRC for Entity Type FND
  --
  PROCEDURE cac_fnd_drc
    (person_id       IN         number
    ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);
END cac_drt_pkg;

/
