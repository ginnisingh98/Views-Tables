--------------------------------------------------------
--  DDL for Package ARP_DUAL_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DUAL_CURRENCY" AUTHID CURRENT_USER AS
/* $Header: ARPLDUCS.pls 120.1 2004/12/03 01:46:10 orashid ship $ */
--
    PROCEDURE DualCurrency( p_PostingControlId          NUMBER,
                    p_DualCurr                  VARCHAR2,
                    p_GlDateFrom                DATE,
                    p_GlDateTo                  DATE,
                    p_SetOfBooksId              NUMBER,
                    p_UserSource                VARCHAR2 );
--
END;

 

/
