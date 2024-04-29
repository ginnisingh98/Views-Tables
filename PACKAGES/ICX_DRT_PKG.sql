--------------------------------------------------------
--  DDL for Package ICX_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ICX_DRT_PKG.pls 120.0.12010000.2 2018/04/03 09:05:11 krsethur noship $ */
  -- Post Processing function to handle attribute masking for HR Person
  -- This is workaround as we can't have multiple where conditions in
  -- excel metadata from HR.
  PROCEDURE icx_hr_post(
      person_id IN NUMBER );
  -- Post Processing function to handle attribute masking for TCA Person
  -- This is workaround as we can't have multiple where conditions in
  -- excel metadata from HR.
  PROCEDURE icx_tca_post(
      person_id IN NUMBER );
  -- DRC procedure for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
  PROCEDURE icx_hr_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type ) ;
  -- DRC procedure for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
  PROCEDURE icx_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );
  -- DRC procedure for person type : FND
  -- Does validation if passed in FND Userid can be masked by validating all
  -- rules and passes back the out variable p_process_tbl which contains a
  -- table of record of errors/warnings/successs
  PROCEDURE icx_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );
END icx_drt_pkg;

/
