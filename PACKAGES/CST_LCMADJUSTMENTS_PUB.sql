--------------------------------------------------------
--  DDL for Package CST_LCMADJUSTMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_LCMADJUSTMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: CSTLCAMS.pls 120.0.12010000.2 2008/11/12 13:43:10 mpuranik noship $ */

TYPE rowid_tbl_typ IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

--------------------------------------- -------------------------------------
-- PROCEDURE    :   Launch_Workers
-- DESCRIPTION  :
--
--
-----------------------------------------------------------------------------
PROCEDURE Launch_Workers
(
    errbuf                          OUT     NOCOPY VARCHAR2,
    retcode                         OUT     NOCOPY NUMBER
);

END CST_LcmAdjustments_PUB;

/
