--------------------------------------------------------
--  DDL for Package ENG_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ENGDRTS.pls 120.0.12010000.5 2018/03/27 11:56:15 nlingamp noship $ */
  --
  --- Implement ENG specific DRC for Entity Type HR
  --
 PROCEDURE eng_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  --
  --- Implement ENG specific DRC for Entity Type TCA
  --
  PROCEDURE eng_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

END eng_drt_pkg;

/
