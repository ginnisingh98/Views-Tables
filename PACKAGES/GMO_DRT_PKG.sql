--------------------------------------------------------
--  DDL for Package GMO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMODRCS.pls 120.0.12010000.1 2018/03/26 09:16:20 maychen noship $ */

PROCEDURE GMO_FND_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL      OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);
END GMO_DRT_PKG;

/
