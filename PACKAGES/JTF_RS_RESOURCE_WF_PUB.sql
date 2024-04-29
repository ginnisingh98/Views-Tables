--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_WF_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrswrs.pls 120.0 2005/05/11 08:23:29 appldev ship $ */
/*#
 * Resource Workflow API
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Resource Workflow API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/

  /* Procedure to start the update resource workflow */

/*#
 * Start Update Resource API
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_category Category of the Resource
 * @param p_resource_number Resource Number
 * @param p_resource_name Name of the Resource
 * @param p_address_id Resource address
 * @param p_source_email Source Email
 * @param p_source_phone Source Phone
 * @param p_source_office Source Office
 * @param p_source_location Source Location
 * @param p_source_mailstop Source Mailstop
 * @param p_time_zone Time zone, this value must be a valid time zone as defined in table HZ_TIMEZONES.
 * @param p_support_site_id Value used by the Service applications.
 * @param p_primary_language The resource's primary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_secondary_language The resource's secondary language. This value must be a valid NLS language as defined in table FND_LANGUAGES
 * @param p_cost_per_hr The salary cost per hour for this resource.
 * @param p_attribute_access_level Attribute access Level
 * @param p_object_version_number The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param p_wf_process Workflow Process
 * @param p_wf_item_type Workflow Item Type
 * @param p_source_mobile_phone Source Mobile Phone
 * @param p_source_pager Source Pager
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Start Update Resource API
*/
   PROCEDURE start_update_resource_wf (
      p_api_version            IN       NUMBER,
      p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_resource_id            IN       jtf_rs_resource_extns.resource_id%type,
      p_category               IN       jtf_rs_resource_extns.category%type,
      p_resource_number        IN       jtf_rs_resource_extns.resource_number%type,
      p_resource_name          IN       jtf_rs_resource_extns_vl.resource_name%type default fnd_api.g_miss_char,
      p_address_id             IN       jtf_rs_resource_extns.address_id%type default fnd_api.g_miss_num,
      p_source_email           IN       jtf_rs_resource_extns.source_email%type default fnd_api.g_miss_char,
      p_source_phone           IN       jtf_rs_resource_extns.source_phone%type default fnd_api.g_miss_char,
      p_source_office          IN       jtf_rs_resource_extns.source_office%type default fnd_api.g_miss_char,
      p_source_location        IN       jtf_rs_resource_extns.source_location%type default fnd_api.g_miss_char,
      p_source_mailstop        IN       jtf_rs_resource_extns.source_mailstop%type default fnd_api.g_miss_char,
      p_time_zone              IN       jtf_rs_resource_extns.time_zone%type default fnd_api.g_miss_num,
      p_support_site_id        IN       jtf_rs_resource_extns.support_site_id%type default fnd_api.g_miss_num,
      p_primary_language       IN       jtf_rs_resource_extns.primary_language%type default fnd_api.g_miss_char,
      p_secondary_language     IN       jtf_rs_resource_extns.secondary_language%type default fnd_api.g_miss_char,
      p_cost_per_hr            IN       jtf_rs_resource_extns.cost_per_hr%type default fnd_api.g_miss_num,
      p_attribute_access_level IN       jtf_rs_table_attributes_b.attribute_access_level%type,
      p_object_version_number  IN       jtf_rs_resource_extns.object_version_number%type,
      --p_wf_display_name      IN       VARCHAR2 DEFAULT NULL,
      p_wf_process             IN       VARCHAR2 DEFAULT 'EMP_UPDATE_PROCESS',
      p_wf_item_type           IN       VARCHAR2 DEFAULT 'EMP_TYPE',
      x_return_status          OUT NOCOPY      VARCHAR2,
      x_msg_count              OUT NOCOPY      NUMBER,
      x_msg_data               OUT NOCOPY      VARCHAR2,
      p_source_mobile_phone    IN       jtf_rs_resource_extns.source_mobile_phone%type default fnd_api.g_miss_char,
      p_source_pager           IN       jtf_rs_resource_extns.source_pager%type default fnd_api.g_miss_char
   );

/*#
 * Check Attribute access level API
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity Id
 * @param funcmode Function Mode
 * @param resultout Out Parameter for Result
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Attribute access level API
*/
   PROCEDURE check_attr_access_level (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   );

/*#
 * Call to Resource Update API
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity Id
 * @param funcmode Function Mode
 * @param resultout Out Parameter for Result
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Call Update Resource API
*/
   PROCEDURE call_update_resource_api (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   );

/*#
 * Check Error Flag API
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity Id
 * @param funcmode Function Mode
 * @param resultout Out Parameter for Result
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Check Error Flag API
*/
   PROCEDURE check_error_flag (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY     VARCHAR2
   );

END JTF_RS_RESOURCE_WF_PUB;

 

/
