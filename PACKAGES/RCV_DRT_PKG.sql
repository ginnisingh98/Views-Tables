--------------------------------------------------------
--  DDL for Package RCV_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVDRTPS.pls 120.0.12010000.1 2018/03/29 08:06:25 gke noship $ */

  ---
  --- Procedure: RCV_HR_DRC
  --- For a given HR Person, this procedure will do several validations for receiving tables.
  --- If any validation fails, it will add result to result_tbl with warning / error message.
  --- Otherwise, it will return nothing and the person record can be removed / disabled.
  ---
  PROCEDURE RCV_HR_DRC
    (person_id IN NUMBER,
     result_tbl OUT nocopy per_drt_pkg.result_tbl_type);


  ---
  --- Procedure: RCV_HR_DRC
  --- For a given TCA party, this procedure will do several validations for receiving tables.
  --- If any validation fails, it will add result to result_tbl with warning / error message.
  --- Otherwise, it will return nothing and the TCA party record can be removed / disabled.
  ---
  PROCEDURE RCV_TCA_DRC
    (person_id IN NUMBER,
    result_tbl OUT nocopy per_drt_pkg.result_tbl_type);

END RCV_DRT_PKG;

/
