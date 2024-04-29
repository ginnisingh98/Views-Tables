--------------------------------------------------------
--  DDL for Package PAY_GARN_LIMIT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GARN_LIMIT_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pyglr01t.pkh 115.0 99/07/17 06:08:46 porting ship $ */

  PROCEDURE pre_insert( x_limit_rule_id      IN OUT NUMBER);

  PROCEDURE post_query( x_state_code                     VARCHAR2,
                        x_garn_category                  VARCHAR2,
                        x_state_name             IN OUT  VARCHAR2,
                        x_garn_category_name     IN OUT  VARCHAR2);
  PROCEDURE Check_Unique( X_State_Code                     VARCHAR2,
                          X_Garn_Category                  VARCHAR2);

END;

 

/
