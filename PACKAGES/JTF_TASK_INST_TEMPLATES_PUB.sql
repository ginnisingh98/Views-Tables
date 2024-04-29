--------------------------------------------------------
--  DDL for Package JTF_TASK_INST_TEMPLATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_INST_TEMPLATES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpttms.pls 120.4 2006/07/24 13:31:35 sbarat ship $ */
/*#
 * A public interface to create Tasks by using Task Template.
 * Tasks can be standalone tasks or tasks associated with a specific
 * business entity such as Opportunity, Service Request, Customer, etc.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task From Template
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

  TYPE task_details_rec IS RECORD (
      task_id                       NUMBER,
      task_template_id              NUMBER
   );

   TYPE task_details_tbl IS TABLE OF task_details_rec
      INDEX BY BINARY_INTEGER;

   TYPE task_contact_points_rec IS RECORD (
      task_template_id              NUMBER,
      phone_id                      NUMBER,
      primary_key                   VARCHAR2(1)
   );

   TYPE task_contact_points_tbl IS TABLE OF task_contact_points_rec
      INDEX BY BINARY_INTEGER;

   TYPE task_template_group_info IS RECORD (
      task_template_group_id        NUMBER,
      owner_type_code               VARCHAR2(30),
      owner_id                      NUMBER,
      source_object_id              NUMBER,
      source_object_name            VARCHAR2(80),
      assigned_by_id                NUMBER,
      cust_account_id               NUMBER,
      customer_id                   NUMBER,
      address_id                    NUMBER,
      actual_start_date             DATE,
      actual_end_date               DATE,
      planned_start_date            DATE,
      planned_end_date              DATE,
      scheduled_start_date          DATE,
      scheduled_end_date            DATE,
      palm_flag                     VARCHAR2(1),
      wince_flag                    VARCHAR2(1),
      laptop_flag                   VARCHAR2(1),
      device1_flag                  VARCHAR2(1),
      device2_flag                  VARCHAR2(1),
      device3_flag                  VARCHAR2(1),
      parent_task_id                NUMBER,
      percentage_complete           NUMBER,
      timezone_id                   NUMBER,
      actual_effort                 NUMBER,
      actual_effort_uom             VARCHAR2(3),
      reason_code                   VARCHAR2(30),
      bound_mode_code               VARCHAR2(30),
      soft_bound_flag               VARCHAR2(1),
      workflow_process_id           NUMBER,
      owner_territory_id            NUMBER,
      costs                         NUMBER,
      currency_code                 VARCHAR2(150),
      attribute1                    VARCHAR2(150),
      attribute2                    VARCHAR2(150),
      attribute3                    VARCHAR2(150),
      attribute4                    VARCHAR2(150),
      attribute5                    VARCHAR2(150),
      attribute6                    VARCHAR2(150),
      attribute7                    VARCHAR2(150),
      attribute8                    VARCHAR2(150),
      attribute9                    VARCHAR2(150),
      attribute10                   VARCHAR2(150),
      attribute11                   VARCHAR2(150),
      attribute12                   VARCHAR2(150),
      attribute13                   VARCHAR2(150),
      attribute14                   VARCHAR2(150),
      attribute15                   VARCHAR2(150),
      attribute_category            VARCHAR2(30),
      date_selected                 VARCHAR2(1),
      show_on_calendar              VARCHAR2(1),
      location_id                   NUMBER
   );

   TYPE task_template_info IS RECORD (
      task_template_id              NUMBER,
      task_name                     VARCHAR2(80),
      description                   VARCHAR2(4000),
      task_type_id                  NUMBER,
      task_status_id                NUMBER,
      task_priority_id              NUMBER,
      owner_type_code               VARCHAR2(30),
      owner_id                      NUMBER,
      planned_start_date            DATE,
      planned_end_date              DATE,
      scheduled_start_date          DATE,
      scheduled_end_date            DATE,
      actual_start_date             DATE,
      actual_end_date               DATE,
      p_date_selected               VARCHAR2(1),
      timezone_id                   NUMBER,
      duration                      NUMBER,
      duration_uom                  VARCHAR2(3),
      planned_effort                NUMBER,
      planned_effort_uom            VARCHAR2(3),
      private_flag                  VARCHAR2(1),
      restrict_closure_flag         VARCHAR2(1),
      palm_flag                     VARCHAR2(1),
      wince_flag                    VARCHAR2(1),
      laptop_flag                   VARCHAR2(1),
      device1_flag                  VARCHAR2(1),
      device2_flag                  VARCHAR2(1),
      device3_flag                  VARCHAR2(1),
      show_on_calendar              VARCHAR2(1),
      enable_workflow               VARCHAR2(1),
      attribute1                    VARCHAR2(150),
      attribute2                    VARCHAR2(150),
      attribute3                    VARCHAR2(150),
      attribute4                    VARCHAR2(150),
      attribute5                    VARCHAR2(150),
      attribute6                    VARCHAR2(150),
      attribute7                    VARCHAR2(150),
      attribute8                    VARCHAR2(150),
      attribute9                    VARCHAR2(150),
      attribute10                   VARCHAR2(150),
      attribute11                   VARCHAR2(150),
      attribute12                   VARCHAR2(150),
      attribute13                   VARCHAR2(150),
      attribute14                   VARCHAR2(150),
      attribute15                   VARCHAR2(150),
      attribute_category            VARCHAR2(30),
      task_confirmation_status      VARCHAR2(1)
   );

   TYPE task_template_info_tbl IS TABLE OF task_template_info
      INDEX BY BINARY_INTEGER;

/*#
   * Creates a Task by using the Task Template.
   *
   * @param p_api_version The standard API version number.
   * @param p_init_msg_list The standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_commit The standard API flag is used by API callers to ask
   * the API to commit on their behalf after performing its function.
   * By default, the commit will not be performed.
   * @param x_return_status Returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>.
   * @param x_msg_count Returns the number of messages in the API message list.
   * @param x_msg_data Returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   * @param x_task_details_tbl Returns the Task Ids of the tasks created.
   * @param p_task_template_group_info Table of task template group records.
   * @param p_task_templates_tbl Table of task template records.
   * @param p_task_contact_points_tbl Table of task contact-point records.
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Create Task From Template
   * @rep:compatibility N
   */
   PROCEDURE create_task_from_template (
      p_api_version IN NUMBER,
      p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit IN VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_template_group_info IN task_template_group_info,
      p_task_templates_tbl IN task_template_info_tbl,
      p_task_contact_points_tbl IN task_contact_points_tbl,
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_count OUT NOCOPY NUMBER,
      x_msg_data OUT NOCOPY VARCHAR2,
      x_task_details_tbl OUT NOCOPY task_details_tbl
   );
END;

 

/
