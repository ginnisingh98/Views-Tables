--------------------------------------------------------
--  DDL for Package RLM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: RLMDRTPS.pls 120.0.12010000.2 2018/03/29 12:26:10 sunilku noship $*/

--
--- Procedure: RLM_TCA_DRC
--- For a given TCA Party, procedure subject it to pass the validation representing applicable constraint.
--- If the Party comes out of validation process successfully, then it can be MASK otherwise error will be raised.
---
  PROCEDURE RLM_TCA_DRC
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

END RLM_DRT_PKG;

/
