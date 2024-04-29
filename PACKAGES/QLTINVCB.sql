--------------------------------------------------------
--  DDL for Package QLTINVCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTINVCB" AUTHID CURRENT_USER as
/* $Header: qltinvcb.pls 115.2 2002/11/27 19:26:43 jezheng ship $ */
-- 5/20/96 - created
-- Paul Mishkin

FUNCTION NO_NEG_BALANCE(RESTRICT_FLAG NUMBER,
                        NEG_FLAG NUMBER,
                        ACTION NUMBER) RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES(no_neg_balance, WNDS, WNPS);

FUNCTION CONTROL (ORG_CONTROL NUMBER DEFAULT NULL,
                  SUB_CONTROL NUMBER DEFAULT NULL,
                  ITEM_CONTROL NUMBER DEFAULT NULL,
                  RESTRICT_FLAG NUMBER DEFAULT NULL,
                  NEG_FLAG NUMBER DEFAULT NULL,
                  ACTION NUMBER DEFAULT NULL) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(control, WNDS, WNPS);

END QLTINVCB;


 

/
