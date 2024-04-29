--------------------------------------------------------
--  DDL for Package PAY_BALANCE_DIMENSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_DIMENSION_API" AUTHID CURRENT_USER AS
/* $Header: pybldapi.pkh 120.2 2005/11/02 06:35:51 sgottipa noship $ */
/*#
 * This package contains Balance Dimension APIs.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Balance Dimension
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_balance_dimension >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to create a new Balance Dimension.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * If this balance dimension to be used only within a business group then a
 * valid business group should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance dimension will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * dimension is not created.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_dimension_id Primary Key If p_validate is true then this
 * will be set to null.
 * @param p_business_group_id Business group of the Balance Dimension.
 * @param p_legislation_code Legislation of the Balance Dimension.
 * @param p_route_id Route Id of the Balance Dimension.
 * @param p_database_item_suffix {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DATABASE_ITEM_SUFFIX}
 * @param p_dimension_name Name of the Balance Dimension.
 * @param p_dimension_type {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DIMENSION_TYPE}
 * @param p_description User Description of the Balance Dimension.
 * @param p_feed_checking_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.FEED_CHECKING_CODE}
 * @param p_legislation_subgroup Identifies the legislation of the predefined
 * data for the element.
 * @param p_payments_flag {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.PAYMENTS_FLAG}
 * @param p_expiry_checking_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.EXPIRY_CHECKING_CODE}
 * @param p_expiry_checking_level Indicates the balance dimension expiry
 * checking level.
 * @param p_feed_checking_type Indicates whether the latest balance should
 * expire and if so, at what level (i.e., Payroll Action, Assignment Action
 * or Date Expiry Level).
 * @param p_dimension_level {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DIMENSION_LEVEL}
 * @param p_period_type {@rep:casecolumn PAY_BALANCE_DIMENSIONS.PERIOD_TYPE}
 * @param p_asg_action_balance_dim_id {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.ASG_ACTION_BALANCE_DIM_ID}
 * @param p_database_item_function {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DATABASE_ITEM_FUNCTION}
 * @param p_save_run_balance_enabled {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.SAVE_RUN_BALANCE_ENABLED}
 * @param p_start_date_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.START_DATE_CODE}
 * @rep:displayname Create Balance Dimension
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_balance_dimension
  (p_validate                            in         boolean default FALSE,
   p_balance_dimension_id	     out nocopy	   NUMBER,
   p_business_group_id            in         NUMBER,
   p_legislation_code                in         VARCHAR2,
   p_route_id  			     in	   NUMBER,
   p_database_item_suffix        in         VARCHAR2,
   p_dimension_name             in         VARCHAR2,
   p_dimension_type               in         VARCHAR2,
   p_description                      in         VARCHAR2,
   p_feed_checking_code         in         VARCHAR2,
   p_legislation_subgroup       in         VARCHAR2,
   p_payments_flag                in         VARCHAR2,
   p_expiry_checking_code       in         VARCHAR2,
   p_expiry_checking_level      in         VARCHAR2,
   p_feed_checking_type         in         VARCHAR2,
   p_dimension_level            in         VARCHAR2,
   p_period_type                in         VARCHAR2,
   p_asg_action_balance_dim_id  in         NUMBER,
   p_database_item_function     in         VARCHAR2,
   p_save_run_balance_enabled   in         VARCHAR2,
   p_start_date_code            in         VARCHAR2
  ) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_balance_dimension >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to update Balance Dimension.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The balance dimension to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance dimension will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * dimension is not updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_dimension_id primary key.
 * @param p_business_group_id Business group of the Balance Dimension.
 * @param p_legislation_code Legislation of the Balance Dimension.
 * @param p_route_id Route Id of the Balance Dimension.
 * @param p_database_item_suffix {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DATABASE_ITEM_SUFFIX}
 * @param p_dimension_name Name of the Balance Dimension.
 * @param p_dimension_type {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DIMENSION_TYPE}
 * @param p_description User Description of the Balance Dimension.
 * @param p_feed_checking_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.FEED_CHECKING_CODE}
 * @param p_legislation_subgroup Identifies the legislation of the predefined
 * data for the element.
 * @param p_payments_flag {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.PAYMENTS_FLAG}
 * @param p_expiry_checking_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.EXPIRY_CHECKING_CODE}
 * @param p_expiry_checking_level Indicates the balance dimension expiry
 * checking level.
 * @param p_feed_checking_type Indicates whether the latest balance should
 * expire and if so, at what level (i.e., Payroll Action, Assignment Action
 * or Date Expiry Level).
 * @param p_dimension_level {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DIMENSION_LEVEL}
 * @param p_period_type {@rep:casecolumn PAY_BALANCE_DIMENSIONS.PERIOD_TYPE}
 * @param p_asg_action_balance_dim_id {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.ASG_ACTION_BALANCE_DIM_ID}
 * @param p_database_item_function {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.DATABASE_ITEM_FUNCTION}
 * @param p_save_run_balance_enabled {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.SAVE_RUN_BALANCE_ENABLED}
 * @param p_start_date_code {@rep:casecolumn
 * PAY_BALANCE_DIMENSIONS.START_DATE_CODE}
 * @rep:displayname Update Balance Dimension
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_balance_dimension
  (p_validate                   in         boolean default FALSE,
   p_balance_dimension_id	in	   NUMBER,
   p_business_group_id          in         NUMBER,
   p_legislation_code           in         VARCHAR2,
   p_route_id  			in	   NUMBER,
   p_database_item_suffix       in         VARCHAR2,
   p_dimension_name             in         VARCHAR2,
   p_dimension_type             in         VARCHAR2,
   p_description                in         VARCHAR2,
   p_feed_checking_code         in         VARCHAR2,
   p_legislation_subgroup       in         VARCHAR2,
   p_payments_flag              in         VARCHAR2,
   p_expiry_checking_code       in         VARCHAR2,
   p_expiry_checking_level      in         VARCHAR2,
   p_feed_checking_type         in         VARCHAR2,
   p_dimension_level            in         VARCHAR2,
   p_period_type                in         VARCHAR2,
   p_asg_action_balance_dim_id  in         NUMBER,
   p_database_item_function     in         VARCHAR2,
   p_save_run_balance_enabled   in         VARCHAR2,
   p_start_date_code            in         VARCHAR2
  ) ;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_balance_dimension >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to delete Balance Dimension.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The balance dimension to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * The balance dimension will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the balance
 * dimension is not updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_balance_dimension_id primary key.
 * @rep:displayname Delete Balance Dimension
 * @rep:category BUSINESS_ENTITY PAY_BALANCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure delete_balance_dimension
  (p_validate                      in     boolean  default false,
   p_balance_dimension_id   in NUMBER
  );

  function return_dml_status return boolean;

--
-- ----------------------------------------------------------------------------
-- |                     Package Header Variable                              |
-- ----------------------------------------------------------------------------
--
g_dml_status boolean:= FALSE;  -- Global package variable
--
END PAY_BALANCE_DIMENSION_API ;


 

/
