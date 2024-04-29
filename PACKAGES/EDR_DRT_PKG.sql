--------------------------------------------------------
--  DDL for Package EDR_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: EDRDRCS.pls 120.0.12010000.2 2018/03/26 08:44:40 maychen noship $ */
    PROCEDURE edr_fnd_drc (
        person_id    IN NUMBER,
        result_tbl   OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE
    );
    PROCEDURE edr_hr_drc (
        person_id    IN NUMBER,
        result_tbl   OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE
    );
END edr_drt_pkg;

/
