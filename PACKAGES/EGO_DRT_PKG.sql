--------------------------------------------------------
--  DDL for Package EGO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: EGODRTPS.pls 120.0.12010000.1 2018/03/28 05:43:58 icyu noship $ */

---
--- Procedure: EGO_TCA_DRC
--- For a given TCA Party, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Party comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE EGO_TCA_DRC
  (person_id       IN         varchar2
  ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);

END EGO_DRT_PKG;


/
