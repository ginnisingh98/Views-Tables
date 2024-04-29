--------------------------------------------------------
--  DDL for Package EC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EC_DRT_PKG" AUTHID CURRENT_USER AS
  /* $Header: ecedrtpkgs.pls 120.0.12010000.1 2018/04/03 07:58:25 saurabja noship $ */

  PROCEDURE EC_TCA_DRC(PERSON_ID  IN NUMBER,
                       RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

END EC_DRT_PKG;

/
