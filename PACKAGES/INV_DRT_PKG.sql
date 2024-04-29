--------------------------------------------------------
--  DDL for Package INV_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: INVDRTPS.pls 120.0.12010000.5 2018/03/29 08:48:09 ppulloor noship $ */

---
--- Procedure: INV_HR_DRC
--- For a given HR Person, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Person comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE INV_HR_DRC
  (person_id       IN         varchar2
  ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);


---
--- Procedure: INV_TCA_DRC
--- For a given TCA Party, procedure subject it to pass through number of validation representing applicable constraints.
--- If the Party comes out of validation process successfully, then it can be deleted otherwise error will be raised.
---
PROCEDURE INV_TCA_DRC
  (person_id       IN         varchar2
  ,result_tbl      OUT NOCOPY per_drt_pkg.result_tbl_type);

END INV_DRT_PKG;

/
