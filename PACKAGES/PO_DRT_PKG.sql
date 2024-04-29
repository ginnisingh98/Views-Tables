--------------------------------------------------------
--  DDL for Package PO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: PO_DRT_PKG.pls 120.0.12010000.6 2018/04/27 10:02:41 adevadul noship $ */


  -- DRC procedure for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
  PROCEDURE po_hr_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type ) ;


  -- DRC procedure for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
  PROCEDURE po_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );


  -- DRC procedure for person type : FND
  -- Does validation if passed in FND Userid can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
  PROCEDURE po_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type );



  -- Post Processing procedure to handle attribute masking for HR Person
  PROCEDURE PO_HR_POST(person_id IN NUMBER);

  -- Post Processing procedure to handle attribute masking for FND User
  PROCEDURE PO_FND_POST(person_id IN NUMBER);

  -- Post Processing procedure to handle attribute masking for TCA Person
  PROCEDURE PO_TCA_POST(person_id IN NUMBER);

END po_drt_pkg;

/
