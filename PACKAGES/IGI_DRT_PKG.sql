--------------------------------------------------------
--  DDL for Package IGI_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: igidrtapi.pkh 120.0.12010000.2 2018/03/27 11:42:44 sthatich noship $ */
  PROCEDURE igi_tca_drc
  (
    person_id IN NUMBER,
    result_tbl OUT nocopy per_drt_pkg.result_tbl_type
  );
END igi_drt_pkg;

/
