--------------------------------------------------------
--  DDL for Package EAM_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: eamdrtps.pls 120.0.12010000.2 2018/03/29 01:30:17 shengywa noship $ */

  ENTITY_TYPE_HR  CONSTANT VARCHAR2(3) := 'HR';
  ENTITY_TYPE_FND CONSTANT VARCHAR2(3) := 'FND';
  ENTITY_TYPE_TCA CONSTANT VARCHAR2(3) := 'TCA';
  EAM_APPL_ID     NUMBER               := 426;
  EAM_APPL_CODE   VARCHAR2(10)         := 'EAM';

  PROCEDURE EAM_HR_DRC(PERSON_ID  IN NUMBER,
                       RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

  PROCEDURE EAM_FND_DRC(PERSON_ID  IN NUMBER,
                        RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

END EAM_DRT_PKG;

/
