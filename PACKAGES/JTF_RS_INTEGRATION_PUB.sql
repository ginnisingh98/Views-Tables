--------------------------------------------------------
--  DDL for Package JTF_RS_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_INTEGRATION_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrspxs.pls 120.0 2005/05/11 08:21:30 appldev noship $ */
/*#
 * Resource Integration API
 * This API contains common procedures and functions that can be called from other oracle products.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Integration API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/

  /*****************************************************************************************
   ******************************************************************************************/

/*#
 * Get primary group for salesperson
 * Function to fetch primary group for salesperson.
 * @param p_salesrep_id Salesrep Id
 * @param p_org_id Organization Id for Salesperson
 * @param p_date Date for which primary group is to be fetched
 * @return Group Id
 * @rep:scope internal
 * @rep:displayname Get Primary Group For Salesperson
*/

 FUNCTION get_default_sales_group
    (p_salesrep_id    IN NUMBER,
     p_org_id         IN NUMBER,
     p_date           IN DATE DEFAULT SYSDATE)
 RETURN NUMBER;

TYPE Resource_Rec_type IS RECORD
              (RESOURCE_ID      JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE);

TYPE Resource_table_type IS TABLE OF Resource_Rec_type INDEX BY BINARY_INTEGER;

/* Procedure to get resources based on Skill (Platform,Product,Component,ProblemCode,Level combination) */

/*#
 * Get get resources based on Skill (Platform,Product,Component,ProblemCode,Level combination)
 * Procedure to get resources based on Skill
 * @param p_category_id Category Id
 * @param p_subcategory Sub Category
 * @param p_product_id Product Id
 * @param p_product_org_id Organization Id for Product
 * @param p_component_id Component Id
 * @param p_subcomponent_id Sub Component Id
 * @param p_platform_id Platform Id
 * @param p_platform_org_id Organization Id for Platform
 * @param p_problem_code Problem Code
 * @param p_skill_level_id Skill Level Id
 * @param x_get_resources_tbl Output table which contains the list of resources based on the input parameters
 * @param x_return_status Output parameter for return status
 * @rep:scope internal
 * @rep:displayname Get resources based on skill
*/

 PROCEDURE  get_resources_by_skill
  (p_category_id       IN jtf_rs_resource_skills.category_id%TYPE,
   p_subcategory       IN jtf_rs_resource_skills.subcategory%TYPE,
   p_product_id        IN jtf_rs_resource_skills.product_id%TYPE,
   p_product_org_id    IN jtf_rs_resource_skills.product_org_id%TYPE,
   p_component_id      IN jtf_rs_resource_skills.component_id%TYPE,
   p_subcomponent_id   IN jtf_rs_resource_skills.subcomponent_id%TYPE,
   p_platform_id       IN jtf_rs_resource_skills.platform_id%TYPE,
   p_platform_org_id   IN jtf_rs_resource_skills.platform_org_id%TYPE,
   p_problem_code      IN jtf_rs_resource_skills.problem_code%TYPE,
   p_skill_level_id    IN jtf_rs_resource_skills.skill_level_id%TYPE,
   x_get_resources_tbl OUT NOCOPY jtf_rs_integration_pub.Resource_table_type,
   x_return_status     OUT NOCOPY VARCHAR2
 );

END jtf_rs_integration_pub;

 

/
