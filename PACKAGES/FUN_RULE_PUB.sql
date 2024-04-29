--------------------------------------------------------
--  DDL for Package FUN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RULE_PUB" AUTHID CURRENT_USER AS
/*$Header: FUNXTMRULENGINS.pls 120.8 2006/04/22 11:14:35 ammishra noship $ */
/*#
* Evaluate rules.
* The following is an example of how procedures and functions in this package
* should be used...<br>
* <code>FUN_RULE_PKG.init_parameter_list;
* FUN_RULE_PKG.add_parameter('EXPENSE_DATE', sysdate);
* FUN_RULE_PKG.add_parameter('EMPLOYEE_NUM', 'JP1234');
* FUN_RULE_PKG.add_parameter(... for all your parameters ...);
* result := FUN_RULE_PKG.apply_rule('SQLAP','MY_CUSTOMIZED_OBJECT_NAME');</code>
* @rep:scope internal
* @rep:product fun
* @rep:displayname Rule Engine
* @rep:category BUSINESS_ENTITY FUN_RULE
*/


m_ruleDetailId		NUMBER(15) ;
m_resultApplicationId	NUMBER(15)  ;
m_ruleName		VARCHAR2(80);
m_resultValue           VARCHAR2(4000);
m_resultValueDataType   VARCHAR2(30);
m_attributeCategory     VARCHAR2(150);
m_multiRuleResultFlag   VARCHAR2(1);
m_useDefaultValueFlag   VARCHAR2(1);
m_noRulesSatisfied      BOOLEAN;
m_attribute1		VARCHAR2(150);
m_attribute2            VARCHAR2(150);
m_attribute3            VARCHAR2(150);
m_attribute4            VARCHAR2(150);
m_attribute5            VARCHAR2(150);
m_attribute6            VARCHAR2(150);
m_attribute7            VARCHAR2(150);
m_attribute8            VARCHAR2(150);
m_attribute9            VARCHAR2(150);
m_attribute10           VARCHAR2(150);
m_attribute11           VARCHAR2(150);
m_attribute12           VARCHAR2(150);
m_attribute13           VARCHAR2(150);
m_attribute14           VARCHAR2(150);
m_attribute15           VARCHAR2(150);

m_ruleObjectType        VARCHAR2(15);
m_ruleObjectId          NUMBER;
m_flexFieldName         VARCHAR2(80);
m_flexFieldAppShortName VARCHAR2(10);

--------------------------------------
-- public procedures and functions
--------------------------------------

  /**
   * Initialize the parameter list that is used for rule evaluation.
   *
   * @rep:displayname Initialize Parameter List
   */
  PROCEDURE init_parameter_list;

  /**
   * This procedure sets the instance context for the Rule Object Instance.
   * Once set, the rule object id will be derived from the Rule Object Instance
   * and will be used throughout.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @param p_instance_label   Instance label of rule object
   * @rep:displayname Rule Evaluation
   * @rep:displayname sets the rule object instance context.
   */
  PROCEDURE set_instance_context(p_rule_object_name IN VARCHAR2, p_application_short_name IN VARCHAR2,
               p_instance_label  IN VARCHAR2 , p_org_id  IN NUMBER);

  /**
   * Add a string parameter value used for rule evaluation.
   *
   * @param name Name of the parameter
   * @param value String value for the parameter
   * @rep:displayname Add parameter
   * @rep:primaryinstance
   */
  PROCEDURE add_parameter(name VARCHAR2, value VARCHAR2);

  /**
   * Add a date parameter value used for rule evaluation.
   *
   * @param name Name of the parameter
   * @param value Date value for the parameter
   * @rep:displayname Add parameter
   */
  PROCEDURE add_parameter(name VARCHAR2, value DATE);

  /**
   * Add a number parameter value used for rule evaluation.
   *
   * @param name Name of the parameter
   * @param value Number value for the parameter
   * @rep:displayname Add parameter
   */
  PROCEDURE add_parameter(name VARCHAR2, value NUMBER);

  /**
   * Evaluate rules based on the input parameters,
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @rep:displayname Rule Evaluation
   */
   PROCEDURE apply_rule(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2);

  /**
   * Evaluate rules based on the input parameters,
   * and return true or false.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Boolean value
   * @rep:displayname Rule Evaluation
   */

   FUNCTION apply_rule(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2)
   RETURN BOOLEAN;

  /**
   * Evaluate rules based on the input parameters,
   * and return a numeric value 1 or 0 based on returning value of TRUE or FALSE.
   * This version is used to call This Rule Engine from Java Layer.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Boolean value
   * @rep:displayname Rule Evaluation
   */

   FUNCTION apply_rule_wrapper(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2)
   RETURN NUMBER;

  /**
   * Evaluate rules based on the PARAM TABLE or View for Bulk Evaluation,
   * and populates the result value in a Global temporary table
   * called FUN_RULE_BULK_RESULTS_GT.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return String value of result
   * @rep:displayname Rule Evaluation
   */
   PROCEDURE apply_rule_bulk(p_application_short_name  IN VARCHAR2,
                             p_rule_object_name        IN VARCHAR2,
                             p_param_view_name         IN VARCHAR2,
			     p_additional_where_clause IN VARCHAR2,
 		             p_primary_key_column_name IN VARCHAR2 DEFAULT 'ID');



  /**
   * Evaluate rules based on the input parameters,
   * and return true or false based on any rule is satisfied or not.
   * If any Rule is matched successfully it returns TRUE else returns FALSE.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Bollean value true or false.
   * @rep:displayname Rule Evaluation
   */

   FUNCTION get_string RETURN VARCHAR2;

  /**
   * Evaluate rules based on the input parameters,
   * and return the number result value.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Number value of result
   * @rep:displayname Rule Evaluation
   */


   FUNCTION get_number RETURN VARCHAR2;

  /**
   * Evaluate rules based on the input parameters,
   * and return the date result value.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Date value of result
   * @rep:displayname Rule Evaluation
   */

   FUNCTION get_date RETURN VARCHAR2;

  /**
   * Evaluate rules based on the input parameters,
   * and return the number result value.
   *
   * @param p_application_short_name Application Short Name
   * @param p_rule_object_name Name of rule object
   * @return Number value of result
   * @rep:displayname Rule Evaluation
   */


  FUNCTION get_rule_detail_id RETURN NUMBER;

  /**
  * Returns the Result Application Id
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Result Application Id
  */

  FUNCTION get_result_application_id RETURN NUMBER;

  /**
  * Returns the Rule Name
  * <P>
  * Note: apply_rule() must have been called already.
  * <P>
  * @param
  * @return Rule Name that matches all conditions first.
  */


  FUNCTION get_rule_name RETURN VARCHAR2;

  /**
  * Returns the Attribute Category
  * <P>
  * Note: apply_rule() must have been called already.
  * <P>
  * @param
  * @return Attribute Category for DFF Rule Object Type
  */

  FUNCTION get_attribute_category RETURN VARCHAR2;


  /**
  * Returns the Attribute1 Value
  * <P>
  * Note: apply_rule() must have been called already.
  * <P>
  * @param
  * @return Attribute1 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute1  RETURN VARCHAR2;


  /**
  * Returns the Attribute2 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute2 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute2  RETURN VARCHAR2;

  /**
  * Returns the Attribute3 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute3 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute3  RETURN VARCHAR2;

  /**
  * Returns the Attribute4 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute4 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute4  RETURN VARCHAR2;

  /**
  * Returns the Attribute5 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute5 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute5  RETURN VARCHAR2;

  /**
  * Returns the Attribute6 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute6 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute6  RETURN VARCHAR2;

  /**
  * Returns the Attribute7 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute7 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute7  RETURN VARCHAR2;

  /**
  * Returns the Attribute8 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute8 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute8  RETURN VARCHAR2;

  /**
  * Returns the Attribute9 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute9 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute9  RETURN VARCHAR2;

  /**
  * Returns the Attribute10 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute10 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute10  RETURN VARCHAR2;

  /**
  * Returns the Attribute11 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute11 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute11 RETURN VARCHAR2;

  /**
  * Returns the Attribute12 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute12 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute12  RETURN VARCHAR2;

  /**
  * Returns the Attribute13 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute13 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute13  RETURN VARCHAR2;

  /**
  * Returns the Attribute14 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute14 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute14  RETURN VARCHAR2;

  /**
  * Returns the Attribute15 Value
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return Attribute15 Value for DFF Rule Object Type
  */

  FUNCTION get_attribute15  RETURN VARCHAR2;

  /**
  * Returns the Attribute Value for an index
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param  p_Index NUMBER
  * @return Attribute Value at any index between 1 to 15 for DFF Rule Object Type
  */

 FUNCTION get_attribute_at_index(p_Index IN NUMBER) RETURN VARCHAR2;

 /**
  * Returns the Application Short Name for the Message
  * <P>
  * Note: applyRule() must have been called already.
  * <P>
  * @param
  * @return the Application Short Name for the Message
  */

 FUNCTION get_message_app_name RETURN VARCHAR2;

 /**
  * Returns the RuleResults Objects Array
  * <P>
  * Note: applyRule() must have been called already.
  * Usage:
  * <P>
  * @since  12.0+
  * @param
  * @return RuleResults Objects Array
  */

 FUNCTION GET_MULTI_RULE_RESULTS_TABLE RETURN fun_rule_results_table;


 /**
  * Returns the Concatenated All Rule Names returned by Rule Engine.
  * <P>
  * Note: applyRule() must have been called already.
  * Usage:
  * <P>
  * @since  12.0+
  * @param
  * @return Concatenated Rule Names.
  */

 FUNCTION GET_ALL_RULE_NAMES  RETURN VARCHAR2;


END FUN_RULE_PUB;

 

/
