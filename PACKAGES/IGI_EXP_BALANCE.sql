--------------------------------------------------------
--  DDL for Package IGI_EXP_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_BALANCE" AUTHID CURRENT_USER AS
-- $Header: igistpes.pls 120.4 2007/08/01 11:13:31 gkumares ship $
FUNCTION AR_BALANCE_WARNING (P_MODE                      IN     VARCHAR2,
                              P_CHECKRUN_NAME            IN     VARCHAR2,
                              P_TRANSMISSION_UNIT_ID     IN     NUMBER,
                              P_DIALOGUE_UNIT_ID         IN     NUMBER,
                              P_CUSTOMER_ID              IN     NUMBER,
                              p_CUSTOMER_NAME            OUT NOCOPY    VARCHAR2)
                              return BOOLEAN;


END IGI_EXP_BALANCE;

/
