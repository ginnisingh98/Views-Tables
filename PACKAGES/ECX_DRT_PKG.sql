--------------------------------------------------------
--  DDL for Package ECX_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: ecxdrtpkgs.pls 120.0.12010000.3 2018/05/13 06:06:00 saurabja noship $ */

  PROCEDURE ECX_TCA_DRC(PERSON_ID  IN NUMBER,
                       RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

END ECX_DRT_PKG;

/
