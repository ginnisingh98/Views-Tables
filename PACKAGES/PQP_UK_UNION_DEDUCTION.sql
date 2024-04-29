--------------------------------------------------------
--  DDL for Package PQP_UK_UNION_DEDUCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_UK_UNION_DEDUCTION" AUTHID CURRENT_USER As
/* $Header: pqgbundf.pkh 115.4 2003/02/14 19:19:50 tmehra noship $ */

/*=======================================================================
 *                     GET_UNION_ELE_EXTRA_INFO
 *
 * Formula Funtion, uses the context of element_type_id
 *
 * Extracts element type extra information for a give (union) element
 * with an infomation type of PQP_UK_UNION_INFORMATION
 *
 *=======================================================================*/

FUNCTION get_uk_union_ele_extra_info
           (p_element_type_id           IN   NUMBER    -- Context
           ,p_union_organization_id     OUT NOCOPY  NUMBER
           ,p_union_level_balance_name  OUT NOCOPY  VARCHAR2
           ,p_pension_rate_type_name    OUT NOCOPY  VARCHAR2
           ,p_fund_list                 OUT NOCOPY  VARCHAR2
           ,p_ERROR_MESSAGE	 OUT NOCOPY  VARCHAR2
           )
  RETURN NUMBER; -- Error code


/*=======================================================================
 *                     GET_UK_UNION_ORG_INFO
 *
 * Formula Function
 *
 * Extracts Organization Information (type GB_TRADE_UNION_INFO) for a
 * given Union type organization.
 *
 *=======================================================================*/

--
FUNCTION get_uk_union_org_info
           (p_union_organization_id     IN   NUMBER
           ,p_union_rates_table_id      OUT NOCOPY  NUMBER
           ,p_union_rates_table_name    OUT NOCOPY  VARCHAR2
           ,p_union_rates_table_type    OUT NOCOPY  VARCHAR2
           ,p_union_recalculation_date  OUT NOCOPY  VARCHAR2
           ,p_ERROR_MESSAGE             OUT NOCOPY  VARCHAR2
           )
   RETURN NUMBER;

/*=======================================================================
 *                     GET_UK_UNION_ORGINFO_FNDDATE
 *
 * Formula Function :
 *
 * Extracts Organization Information (type 'GB_TRADE_UNION_INFO') for a
 * given Union type organization.This function return p_union_recalculation_date
 * as a date field. This function will now be used for all Union elements created
 * using the deducation template.
 *=======================================================================*/

FUNCTION get_uk_union_orginfo_fnddate
           (p_union_organization_id     IN   NUMBER
           ,p_union_rates_table_id      OUT NOCOPY  NUMBER
           ,p_union_rates_table_name    OUT NOCOPY  VARCHAR2
           ,p_union_rates_table_type    OUT NOCOPY  VARCHAR2
           ,p_union_recalculation_date  OUT NOCOPY  date --Returned fnd_canonical_date
           ,p_ERROR_MESSAGE             OUT NOCOPY  VARCHAR2
           )
   RETURN NUMBER;

/*=======================================================================
 *                     CHK_UK_UNION_FUND_SELECTED
 *
 * Formula Function
 *
 * Validates that the given union fund name exists as a column on the
 * given union rate table.
 *
 *=======================================================================*/

FUNCTION chk_uk_union_fund_selected
          (p_union_rates_column_name IN   VARCHAR2
          ,p_union_rates_table_name  IN   VARCHAR2
          ,p_ERROR_MESSAGE           IN OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER;


/*=======================================================================
 *                     GET_UK_UNION_RATES_TABLE_ROW
 *
 * Formula Function
 *
 * Returns the row value for a 'M'atch type union rates table.
 * Additionally it validates that there must be exactly one and only
 * one row in the table.
 *
 *======================================================================*/


FUNCTION get_uk_union_rates_table_row
          (p_union_rates_table_name IN   VARCHAR2
          ,p_union_rates_row_value  OUT NOCOPY  VARCHAR2
          ,p_ERROR_MESSAGE          OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER; -- error code, 0 is successful , -1 on Error.

/*=======================================================================
 *                     GET_UK_UNION_RATES
 *
 * Formula Function
 *
 * Package wrapped call to Formula Function GET_TABLE_VALUE to handle
 * potential exceptions (NO_DATA_FOUND and TOO_MANY_ROWS) and return
 * appropriate user error messages.
 *
 *=======================================================================*/
FUNCTION get_uk_union_rates
          (p_bus_group_id            IN   NUMBER   -- Context
          ,p_union_rates_table_name  IN   VARCHAR2
          ,p_union_rates_column_name IN   VARCHAR2
          ,p_union_rates_row_value   IN   VARCHAR2
          ,p_effective_date          IN   DATE     DEFAULT NULL -- Sess Date
          ,p_Union_Deduction_Value   OUT NOCOPY  NUMBER
          ,p_ERROR_MESSAGE           OUT NOCOPY  VARCHAR2
          )
  RETURN NUMBER;

/*=======================================================================*/

END pqp_uk_union_deduction;

 

/
