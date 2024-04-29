--------------------------------------------------------
--  DDL for Package POS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: POS_DRT_PKG.pls 120.0.12010000.2 2018/04/03 18:27:24 jburugul noship $ */

  -- DRC procedure for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs

    PROCEDURE pos_hr_drc (
        person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) ;

  -- DRC procedure for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs

    PROCEDURE pos_tca_drc (
        person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) ;

  -- DRC procedure for person type : FND
  -- Does validation if passed in FND Userid can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs

    PROCEDURE pos_fnd_drc (
        person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) ;

END pos_drt_pkg;

/
