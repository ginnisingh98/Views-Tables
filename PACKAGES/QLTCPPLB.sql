--------------------------------------------------------
--  DDL for Package QLTCPPLB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTCPPLB" AUTHID CURRENT_USER AS
/* $Header: qltcpplb.pls 120.1 2006/03/31 05:23:55 saugupta noship $ */
-- Insert rows for copying plans
-- 2/5/96
-- Jacqueline Chang

  PROCEDURE insert_plan_chars (X_PLAN_ID NUMBER,
		X_COPY_PLAN_ID NUMBER,
		X_USER_ID NUMBER,
        X_DISABLED_INDEXED_ELEMENTS OUT NOCOPY VARCHAR2
		);
        --
        -- Bug 3926150.  Added out variable to return a comma
        -- separated list of collection element names in case
        -- of function based indexes being disabled due to this
        -- Copy Elements action.
        -- bso Wed Dec  1 16:59:55 PST 2004
        --

END QLTCPPLB;


 

/
