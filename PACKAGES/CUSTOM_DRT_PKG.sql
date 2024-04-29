--------------------------------------------------------
--  DDL for Package CUSTOM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUSTOM_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: pecusdrt.pkh 120.0.12010000.1 2018/04/20 08:01:09 jaakhtar noship $ */

  PROCEDURE cus_hr_pre
    (person_id       IN         number);

  PROCEDURE cus_tca_pre
    (person_id       IN         number);

  PROCEDURE cus_fnd_pre
    (person_id       IN         number);

  PROCEDURE cus_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE cus_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE cus_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE cus_hr_post
    (person_id       IN         number);

  PROCEDURE cus_tca_post
    (person_id       IN         number);

  PROCEDURE cus_fnd_post
    (person_id       IN         number);

end custom_drt_pkg;

/
