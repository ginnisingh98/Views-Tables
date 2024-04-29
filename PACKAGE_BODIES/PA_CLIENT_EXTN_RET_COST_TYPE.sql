--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_RET_COST_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_RET_COST_TYPE" AS
-- $Header: PACCXRCB.pls 120.0 2005/05/30 03:07:24 appldev noship $

FUNCTION RETIREMENT_COST_TYPE
                          (p_expenditure_item_id    IN      NUMBER,
                           p_cdl_line_number        IN      NUMBER,
                           p_expenditure_type       IN      VARCHAR2) RETURN VARCHAR2 IS


v_retirement_cost_type  VARCHAR2(30) := 'COR';
v_count                 NUMBER := 0;

BEGIN
 /* This is a client extension function called by the GENERATE_RET_ASSET_LINES procedure,
    in order to determine the Retirement Cost Type of each expenditure item.  Retirement
    Cost Type can either be 'COR' for Costs of Removal or 'POS' for Proceeds of Sale. This
    function must return one of those two values, or downstream processing errors will result.

    The intended use of this extension is to provide clients with the ability to modify
    or override the standard logic for determining Retirement Cost Type, based on their own
    business rules.  The standard application logic, located in this function, checks to see
    if the expenditure type of the EI exists in the PROCEEDS_OF_SALE_EXP_TYPES
    Lookup Set.  If so, the function will return 'POS', otherwise it will return 'COR'.

    One example of a customer business rule may be to derive the Retirement Cost Type based
    on the Task Service Type, or some other task indicator.  Customer logic may be inserted
    into the function where indicated below.

 */

    --Determine if the current Expenditure Type occurs in the POS Exp Types Lookup Set
    SELECT  COUNT(*)
    INTO    v_count
    FROM    pa_lookups
    WHERE   lookup_type = 'PROCEEDS_OF_SALE_EXP_TYPES'
      AND   lookup_code = upper(p_expenditure_type); -- Adding upper() for Bug3290556
/*    AND     lookup_code = p_expenditure_type;*/ -- Commenting out for Bug3290556

    IF v_count > 0 THEN
        v_retirement_cost_type := 'POS';
    ELSE
        v_retirement_cost_type := 'COR';
    END IF;

    /* If customers wish to modify or override the determination of Retirement Cost Type, they may do so HERE */

    RETURN(v_retirement_cost_type);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;

END;

/
