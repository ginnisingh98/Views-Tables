--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_NODES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_NODES_API" AUTHID CURRENT_USER as
/* $Header: pqrmnapi.pkh 120.4 2006/03/14 11:27:29 srajakum noship $ */
/*#
 * This package contains rate matrix node APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate matrix node
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <create_rate_matrix_node >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a new rate matrix node.
 *
 * The API adds the new rate matrix node within the rate matrix hierarchy. The
 * hierarchy of a node is identified by its level number. Each node except the node
 * with level number of 1 has a parent node. The API attaches an eligibility profile
 * to the node. A person is eligible for the rate defined for the node only if they
 * satisfy the eligibility profile associated with that node.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria and eligibility profile attached to the rate matrix node must exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node is created.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node will not be created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_matrix_node_id If p_validate is false, then this uniquely identifies
 * the rate matrix node created. If p_validate is true, then set to null.
 * @param p_short_code Uniquely identifies a rate matrix node within the rate matrix.
 * @param p_pl_id Rate matrix plan to which the rate matrix node belongs to.
 * @param p_level_number The level of the rate matrix node in the rate matrix hierarchy.
 * @param p_criteria_short_code Identifies the criteria attached to this node.
 * @param p_node_name Node name.
 * @param p_parent_node_id Parent node to the current node in the rate matrix hierarchy.
 * @param p_eligy_prfl_id Eligibility profile attached to the rate matrix node.
 * @param p_business_group_id Business group of the rate matrix node.
 * @param p_legislation_code Legislation of the rate matrix node.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created rate matrix node. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create rate matrix node
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rate_matrix_node
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_rate_matrix_node_id            out nocopy   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2 default null
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number   default null
  ,p_eligy_prfl_id                  in   number   default null
  ,p_business_group_id              in   number   default null
  ,p_legislation_code               in   varchar2 default null
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <update_rate_matrix_node >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates a rate matrix node details.
 *
 * The API validates that each rate matrix node has a unique name and short_code.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria and eligibility profile attached to the rate matrix node must exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node details are sucessfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node is updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_matrix_node_id If p_validate is false, then this uniquely identifies
 * the rate matrix node created. If p_validate is true, then set to null.
 * @param p_short_code Uniquely identifies a rate matrix node within the rate matrix.
 * @param p_pl_id Rate matrix plan to which the rate matrix node belongs to.
 * @param p_level_number The level of the rate matrix node in the rate matrix hierarchy.
 * @param p_criteria_short_code Identifies the criteria attached to this node.
 * @param p_node_name Node name.
 * @param p_parent_node_id Parent node to the current node in the rate matrix hierarchy.
 * @param p_eligy_prfl_id Eligibility profile attached to the rate matrix node.
 * @param p_business_group_id Business group of the rate matrix node.
 * @param p_legislation_code Legislation of the rate matrix node.
 * @param p_object_version_number Pass in the current version number of the rate matrix
 * node to be updated. When the API completes if p_validate is false, will be set to the
 * new version number of the updated rate matrix node. If p_validate is true will be set to
 * the same value which was passed in.
 * @rep:displayname Update rate matrix node
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rate_matrix_node
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_rate_matrix_node_id            in   number
  ,p_short_code                     in   varchar2
  ,p_pl_id                          in   number
  ,p_level_number                   in   number
  ,p_criteria_short_code            in   varchar2 default null
  ,p_node_name                      in   varchar2
  ,p_parent_node_id                 in   number   default null
  ,p_eligy_prfl_id                  in   number   default null
  ,p_business_group_id              in   number   default null
  ,p_legislation_code               in   varchar2 default null
  ,p_object_version_number          in   out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <delete_rate_matrix_node >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes a rate matrix node.
 *
 * All child rate matrix nodes must be deleted before the current rate matrix node is
 * to maintain the rate matrix hierarchy.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The node values and node rates defined for a rate matrix node must be deleted
 * before a rate matrix node can be deleted.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node is successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_matrix_node_id Identifies the rate matrix node to be deleted.
 * @param p_object_version_number Current version number of the rate matrix
 * node to be deleted.
 * @rep:displayname Delete rate matrix node
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rate_matrix_node
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_RATE_MATRIX_NODE_ID  	   in     number
  ,p_object_version_number         in     number
  );
--
end PQH_RATE_MATRIX_NODES_API;

 

/
