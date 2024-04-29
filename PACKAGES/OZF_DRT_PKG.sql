--------------------------------------------------------
--  DDL for Package OZF_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: ozfvdrts.pls 120.0.12010000.1 2018/04/13 05:36:25 snsarava noship $ */
  --
  --- Implement OZF specific DRC for Entity Type TCA
  --

 PROCEDURE ozf_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);


PROCEDURE ozf_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);

END OZF_DRT_PKG;

/
