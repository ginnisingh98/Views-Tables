--------------------------------------------------------
--  DDL for Package OKE_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: okedrtapis.pls 120.0.12010000.2 2018/04/04 10:24:34 skuchima noship $ */

PROCEDURE OKE_HR_DRC (
        p_person_id IN NUMBER,
        result_tbl OUT nocopy PER_DRT_PKG.RESULT_TBL_TYPE
    );


END OKE_DRT_PKG;

/
