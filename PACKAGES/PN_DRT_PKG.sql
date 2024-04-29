--------------------------------------------------------
--  DDL for Package PN_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: PNDRTPS.pls 120.0.12010000.1 2018/03/30 16:50:46 kmaddi noship $ */

  PROCEDURE pn_hr_drc
    (p_person_id   IN number
	,result_tbl  OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

  PROCEDURE pn_tca_drc
    (p_person_id   IN number
	,result_tbl  OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

END PN_DRT_PKG;

/
