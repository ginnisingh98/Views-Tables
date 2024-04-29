--------------------------------------------------------
--  DDL for Package WIP_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: wipdrcons.pls 120.0.12010000.1 2018/03/28 08:09:24 sisankar noship $ */

  procedure WIP_HR_DRC
    (person_id     IN NUMBER
    ,result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type
    );

  procedure WIP_FND_DRC
    (person_id     IN NUMBER
    ,result_tbl    OUT NOCOPY PER_DRT_PKG.result_tbl_type
    );

END WIP_DRT_PKG;

/
