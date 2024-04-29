--------------------------------------------------------
--  DDL for Package BOMPBCMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPBCMP" AUTHID CURRENT_USER AS
/* $Header: BOMBCMPS.pls 120.1 2005/06/21 04:21:55 appldev ship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMBCMPS.pls                                               |
| DESCRIPTION  :                                                            |
|                This file creates a packaged procedure that populates a    |
|                temporary table with the results of a bill of material     |
|                comparison.  It is called from both the bill of material   |
|                comparison inquiry and report.                             |
+==========================================================================*/

  PROCEDURE BOM_BILL_COMPARE
   (SEQ_ID                      IN      NUMBER,
    BILL_SEQ_ID1                IN      NUMBER,
    BILL_SEQ_ID2                IN      NUMBER,
    IMPLEMENTED_CODE1           IN      NUMBER,
    IMPLEMENTED_CODE2           IN      NUMBER,
    DISPLAY_CODE1               IN      NUMBER,
    DISPLAY_CODE2               IN      NUMBER,
    CUTOFF_DATE1                IN      DATE,
    CUTOFF_DATE2                IN      DATE,
    ITEM_NUM_CODE               IN      NUMBER,
    OP_SEQ_CODE                 IN      NUMBER,
    EFF_DATE_CODE               IN      NUMBER,
    DIS_DATE_CODE               IN      NUMBER,
    IMPL_CODE                   IN      NUMBER,
    QUANTITY_CODE               IN      NUMBER,
    OPTIONAL_CODE               IN      NUMBER,
    PLAN_FACT_CODE              IN      NUMBER,
    DIFF_CODE                   IN      NUMBER,
    RETURN_CODE                 IN OUT NOCOPY /* file.sql.39 change */     NUMBER);

END BOMPBCMP;

 

/
