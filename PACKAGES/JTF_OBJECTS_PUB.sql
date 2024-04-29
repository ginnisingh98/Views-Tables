--------------------------------------------------------
--  DDL for Package JTF_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_OBJECTS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkos.pls 120.3 2006/09/29 22:23:48 twan ship $ */
/*#
 * This is the public interface to the Comon Applications Calendar business metadata.
 * It allows various meta-data manipulation. It is also known as JTF Objects
 *
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Object Metadata
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_BUSINESS_OBJECT_META_DATA
 */

  /*#
   * Creates the query statement for given metadata.
   * The metadata are coming from the table <code>JTF_OBJECTS_B<code>.
   * This method returns null if the SQL statement cannot be created
   * (for example, the parameter from_table is null).
   *
   * @param select_id the source id to be queried
   * @param select_name the source name to be queried
   * @param select_details the additional source details to be queried
   * @param from_table the table name to be queried from
   * @param where_clause the selection criteria to be applied to the query
   * @param p_inactive_clause the additional exclusion criteria to be applied to the query
   * @param order_by_clause the sorting criteria to be applied to the query result
   * @return the query statement
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Create Select Statement
   * @rep:compatibility N
   */
   FUNCTION jtf_obj_select_stmt (
      select_id         IN   jtf_objects_b.select_id%TYPE       DEFAULT NULL,
      select_name       IN   jtf_objects_b.select_name%TYPE     DEFAULT NULL,
      select_details    IN   jtf_objects_b.select_details%TYPE  DEFAULT NULL,
      from_table        IN   jtf_objects_b.from_table%TYPE      DEFAULT NULL,
      where_clause      IN   jtf_objects_b.where_clause%TYPE    DEFAULT NULL,
      p_inactive_clause IN   jtf_objects_b.inactive_clause%TYPE DEFAULT NULL,
      order_by_clause   IN   jtf_objects_b.order_by_clause%TYPE DEFAULT NULL
   )  RETURN VARCHAR2;

  /*#
   * Creates the query statement for given metadata. It also checks syntax
   * of the formed query and throws an error for an invalid query.
   * @see #jtf_obj_select_stmt
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
   * @param p_commit the standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
   * @param x_return_status returns the result of all the operations performed by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if <code>x_msg_count</code> returns number one.
   * @param p_select_id the id to be queried
   * @param p_select_name the name to be queried
   * @param p_select_details the additional details to be queried
   * @param p_from_table the table name to be queried from
   * @param p_where_clause the selection criteria to be applied to the query
   * @param p_inactive_clause the additional exclusion criteria to be applied to the query
   * @param p_order_by_clause the sorting criteria to be applied to the result
   * @param x_sql_statement returns the query statement or null
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Create and Check Select Statement
   * @rep:compatibility S
   */
   PROCEDURE check_syntax (
      p_api_version       IN NUMBER,
      p_init_msg_list     IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_select_id         IN jtf_objects_b.select_id%TYPE       DEFAULT NULL,
      p_select_name       IN jtf_objects_b.select_name%TYPE     DEFAULT NULL,
      p_select_details    IN jtf_objects_b.select_details%TYPE  DEFAULT NULL,
      p_from_table        IN jtf_objects_b.from_table%TYPE      DEFAULT NULL,
      p_where_clause      IN jtf_objects_b.where_clause%TYPE    DEFAULT NULL,
      p_inactive_clause   IN jtf_objects_b.inactive_clause%TYPE DEFAULT NULL,
      p_order_by_clause   IN jtf_objects_b.order_by_clause%TYPE DEFAULT NULL,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_sql_statement     OUT NOCOPY VARCHAR2
   );

   --
   -- Input record structure
   --
   TYPE PG_INPUT_REC IS RECORD
   (
     ENTITY                    VARCHAR2(30),
     OBJECT_CODE               VARCHAR2(30),
     SOURCE_OBJECT_ID          NUMBER,
     TASK_ID                   NUMBER,
     TASK_ASSIGNMENT_ID        NUMBER,
     CAL_ITEM_ID               NUMBER,
     SCHEDULE_ID               NUMBER,
     HR_CAL_EVENT_ID           NUMBER
   );

  /*#
   * Initializes the cache for objects page and parameters
   *
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Get JTF Objects Page drilldown
   * @rep:compatibility S
   */
   PROCEDURE initialize_cache;

  /*#
   * Determines the page and parameters for any entity
   *
   * @param p_input_rec the input structure used for fetching data
   * @param x_pg_function returns the page function
   * @param x_pg_parameters returns the page parameters in the format param1=valu1&param2=value2
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope private
   * @rep:lifecycle active
   * @rep:displayname Get JTF Objects Page drilldown
   * @rep:compatibility S
   */
   PROCEDURE get_drilldown_page (
      p_input_rec         IN PG_INPUT_REC,
      x_pg_function       OUT NOCOPY VARCHAR2,
      x_pg_parameters     OUT NOCOPY VARCHAR2
   );

END jtf_objects_pub;

 

/
