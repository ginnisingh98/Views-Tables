--------------------------------------------------------
--  DDL for Package OKS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: oksdrtapis.pls 120.0.12010000.4 2018/05/22 05:22:21 skuchima noship $ */

-- DRC function for person type : HR
  -- Does validation if passed in HR person can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

PROCEDURE OKS_HR_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    );

-- DRC function for person type : TCA
  -- Does validation if passed in TCA Party ID can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE OKS_tca_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) ;

-- DRC function for person type : FND
  -- Does validation if passed in FND User can be masked by validating all
  -- rules and return 'S' for Success, 'W' for Warning and 'E' for Error

    PROCEDURE OKS_fnd_drc (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    ) ;

-- Pre Processing function to handle attribute masking for TCA Person
  PROCEDURE oks_tca_pre( person_id IN NUMBER );

END OKS_DRT_PKG;

/
