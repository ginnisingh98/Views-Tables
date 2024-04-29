--------------------------------------------------------
--  DDL for Package OKC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: OKCDRTPS.pls 120.0.12010000.3 2018/04/04 09:12:45 kkolukul noship $ */

  -- DRC procedure for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
  PROCEDURE okc_hr_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type ) ;

  -- DRC procedure for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
PROCEDURE okc_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );

  -- DRC procedure for person type : FND
  -- Does validation if passed in FND Userid can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
  PROCEDURE okc_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );
END okc_drt_pkg;

/
