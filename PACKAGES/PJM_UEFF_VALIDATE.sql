--------------------------------------------------------
--  DDL for Package PJM_UEFF_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_UEFF_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: PJMUEVLS.pls 115.2 99/07/16 01:05:06 porting s $ */
--
--  Name          : Validate_Demand
--  Pre-reqs      : None
--  Function      : This function provides custom validation for
--                  Unit Effective Demand
--
--  Parameters    :
--  IN            : X_order_category                VARCHAR2
--                  X_unit_number                   VARCHAR2
--                  X_item_id                       NUMBER
--                  X_organization_id               NUMBER
--
--  OUT           : None
--
--  Returns       : Y/N
--
FUNCTION Validate_Demand
( X_order_category                 IN     VARCHAR2 DEFAULT 'R'
, X_unit_number                    IN     VARCHAR2
, X_item_id                        IN     NUMBER
, X_organization_id                IN     NUMBER
) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (Validate_Demand, WNDS, WNPS);


END;

 

/
