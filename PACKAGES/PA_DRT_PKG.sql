--------------------------------------------------------
--  DDL for Package PA_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: PADRTPS.pls 120.0.12010000.5 2018/06/18 07:38:25 kukonda noship $ */

  PROCEDURE pa_hr_drc
    (p_person_id   IN number
	,result_tbl  OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

  PROCEDURE pa_tca_drc
    (p_person_id   IN number
	,result_tbl  OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

  PROCEDURE pa_hr_pre
    (p_person_id   IN number);

  PROCEDURE pa_hr_post
    (p_person_id   IN number);

END PA_DRT_PKG;

/
