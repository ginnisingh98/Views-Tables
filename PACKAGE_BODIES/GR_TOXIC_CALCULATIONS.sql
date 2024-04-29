--------------------------------------------------------
--  DDL for Package Body GR_TOXIC_CALCULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_TOXIC_CALCULATIONS" AS
/*  $Header: GRTXCALB.pls 120.1 2005/09/06 14:45:12 pbamb noship $    */

/*===========================================================================
--  FUNCTION:
--    calculate_toxic_value
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to calculate a products toxicity value
--    based upon the toxicity values of its ingredients.
--
--  PARAMETERS:
--    p_item_code IN  VARCHAR2       - Item code of product
--    p_rollup_type IN  NUMBER       - The type of toxic calculation
--    p_label_code  IN VARCHAR2      - The toxicity calculation label code
--    x_ingred_value_tbl OUT GR_TOXIC_CALCULATIONS.t_ingredient_values
--                                   - Table of values used in calculation
--    x_error_message OUT VARCHAR2   - If there is an error, send back the approriate message
--    x_return_status OUT VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    l_prod_tox := calculate_toxic_value(l_item_code,l_rollup_type,l_label_code,l_table
--                            l_err_message,l_return_status);
--
--  HISTORY
--    Melanie Grosser 18-Mar-2002  BUG 1323951 - Modified return statement
--                                 to round the return value to 9 decimal
--                                 places.
--    Melanie Grosser 11-Apr-2002  BUG 1323951 - Changed cursors to select
--                                 toxicity_reporting_level instead of
--                                 exposure_reporting_level
--    Melanie Grosser 23-Apr-2002  BUG 1323951 - Modified code to use
--                                 ingredients with a value greater than OR
--                                 equal to the disclosure value
--=========================================================================== */
FUNCTION calculate_toxic_value (p_item_code IN  VARCHAR2,
                                p_rollup_type IN  NUMBER,
                                p_label_code  IN VARCHAR2,
                                x_ingred_value_tbl OUT NOCOPY GR_TOXIC_CALCULATIONS.t_ingredient_values,
                                x_error_message OUT NOCOPY VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2
                                )  RETURN NUMBER IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 RETURN 0;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
       RETURN 0;


  END calculate_toxic_value;



END gr_toxic_calculations;


/
