--------------------------------------------------------
--  DDL for Package PON_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: PON_DRT_PKG.pls 120.0.12010000.2 2018/04/05 06:05:40 vinnaray noship $*/
  /*=======================================================================+
  | FILENAME
  |   PON_DRT_PKG.pls
  |
  | DESCRIPTION
  |   PL/SQL body for package:  PON_DRT_PKG
  |
  | NOTES
  *=======================================================================*/

PROCEDURE pon_hr_post(
    person_id IN NUMBER) ;

PROCEDURE PON_TCA_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    );

PROCEDURE PON_FND_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    );

PROCEDURE PON_HR_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    );

END;

/
