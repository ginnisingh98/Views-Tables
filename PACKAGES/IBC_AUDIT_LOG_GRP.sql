--------------------------------------------------------
--  DDL for Package IBC_AUDIT_LOG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBC_AUDIT_LOG_GRP" AUTHID CURRENT_USER as
/* $Header: ibcalogs.pls 120.1 2005/05/31 23:17:26 appldev  $ */
 /*#
   * This is the private API for OCM Audit Log (History) functionality.
   * Some of these methods are exposed as Java APIs in AuditLog.class
   * @rep:scope private
   * @rep:product IBC
   * @rep:displayname Oracle Content Manager Audit Log API
   * @rep:category BUSINESS_ENTITY IBC_AUDIT_LOG
   */


  G_API_VERSION_DEFAULT CONSTANT NUMBER := 1.0;

  -- audit object constants
  G_CONTENT_TYPE        CONSTANT VARCHAR2(30) := 'CTYPE';
  G_CONTENT_ITEM        CONSTANT VARCHAR2(30) := 'CITEM';
  G_CITEM_VERSION       CONSTANT VARCHAR2(30) := 'CIVERSION';
  G_ATTRIBUTE_BUNDLE    CONSTANT VARCHAR2(30) := 'ABUNDLE';
  G_ASSOCIATION         CONSTANT VARCHAR2(30) := 'ASSOC';
  G_COMPONENT           CONSTANT VARCHAR2(30) := 'COMP';
  G_LABEL               CONSTANT VARCHAR2(30) := 'LABEL';
  G_DIRECTORY_NODE      CONSTANT VARCHAR2(30) := 'DIRNODE';

  -- Extra Information Types
  G_EI_CONSTANT         CONSTANT VARCHAR2(30) := 'CONSTANT';
  G_EI_LOOKUP           CONSTANT VARCHAR2(30) := 'LOOKUP';
  G_EI_MESSAGE          CONSTANT VARCHAR2(30) := 'MESSAGE';
  G_EI_CS_LOOKUP        CONSTANT VARCHAR2(30) := 'CS_LOOKUP'; -- Comma Separated Lookups

  /*#
   *  Procedure to store an audit log
   *
   *  @param p_activity             Activity Code
   *  @param p_object_type          Object Type
   *  @param p_object_value1        Primary Key for object being audited
   *  @param p_object_value2        Primary Key for object being audited
   *  @param p_object_value3        Primary Key for object being audited
   *  @param p_object_value4        Primary Key for object being audited
   *  @param p_object_value5        Primary Key for object being audited
   *  @param p_parent_value         Parent Value
   *  @param p_message_application  Application owner of audit message
   *  @param p_message_name         Message Name (FND_MESSAGES)
   *  @param p_extra_info1_type     Extra Information segment type
   *                                i.e. CONSTANT, LOOKUP, CS_LOOKUP or MESSAGE
   *  @param p_extra_info1_ref_type Lookup Type (in case of LOOKUP, CS_LOOKUP)
   *  @param p_extra_info1_value    Value (Constant, lookup code or
   *                                message name).
   *  @param p_extra_info2_type     Extra Information segment type
   *                                i.e. CONSTANT, LOOKUP, CS_LOOKUP or MESSAGE
   *  @param p_extra_info2_ref_type Lookup Type (in case of LOOKUP, CS_LOOKUP)
   *  @param p_extra_info2_value    Value (Constant, lookup code or
   *                                message name).
   *  @param p_extra_info3_type     Extra Information segment type
   *                                i.e. CONSTANT, LOOKUP, CS_LOOKUP or MESSAGE
   *  @param p_extra_info3_ref_type Lookup Type (in case of LOOKUP, CS_LOOKUP)
   *  @param p_extra_info3_value    Value (Constant, lookup code or
   *                                message name).
   *  @param p_extra_info4_type     Extra Information segment type
   *                                i.e. CONSTANT, LOOKUP, CS_LOOKUP or MESSAGE
   *  @param p_extra_info4_ref_type Lookup Type (in case of LOOKUP, CS_LOOKUP)
   *  @param p_extra_info4_value    Value (Constant, lookup code or
   *                                message name).
   *  @param p_extra_info5_type     Extra Information segment type
   *                                i.e. CONSTANT, LOOKUP, CS_LOOKUP or MESSAGE
   *  @param p_extra_info5_ref_type Lookup Type (in case of LOOKUP, CS_LOOKUP)
   *  @param p_extra_info5_value    Value (Constant, lookup code or
   *                                message name).
   *  @param p_commit               standard parm - Commit flag
   *  @param p_api_version          standard parm - API Version
   *  @param p_init_msg_list        standard parm - Initialize message list
   *  @param x_return_status        standard parm - Return Status
   *  @param x_msg_count            standard parm - Message Count
   *  @param x_msg_data             standard parm - Message Data
   *
   *  @rep:displayname log_action
   *
   */
  PROCEDURE log_action(
    p_activity              IN VARCHAR2
    ,p_object_type          IN VARCHAR2
    ,p_object_value1        IN VARCHAR2
    ,p_object_value2        IN VARCHAR2 DEFAULT NULL
    ,p_object_value3        IN VARCHAR2 DEFAULT NULL
    ,p_object_value4        IN VARCHAR2 DEFAULT NULL
    ,p_object_value5        IN VARCHAR2 DEFAULT NULL
    ,p_parent_value         IN VARCHAR2 DEFAULT NULL
    ,p_message_application  IN VARCHAR2 DEFAULT NULL
    ,p_message_name         IN VARCHAR2 DEFAULT 'IBC_DFLT_AUDIT_MSG'
    ,p_extra_info1_type     IN VARCHAR2 DEFAULT NULL
    ,p_extra_info1_ref_type IN VARCHAR2 DEFAULT NULL
    ,p_extra_info1_value    IN VARCHAR2 DEFAULT NULL
    ,p_extra_info2_type     IN VARCHAR2 DEFAULT NULL
    ,p_extra_info2_ref_type IN VARCHAR2 DEFAULT NULL
    ,p_extra_info2_value    IN VARCHAR2 DEFAULT NULL
    ,p_extra_info3_type     IN VARCHAR2 DEFAULT NULL
    ,p_extra_info3_ref_type IN VARCHAR2 DEFAULT NULL
    ,p_extra_info3_value    IN VARCHAR2 DEFAULT NULL
    ,p_extra_info4_type     IN VARCHAR2 DEFAULT NULL
    ,p_extra_info4_ref_type IN VARCHAR2 DEFAULT NULL
    ,p_extra_info4_value    IN VARCHAR2 DEFAULT NULL
    ,p_extra_info5_type     IN VARCHAR2 DEFAULT NULL
    ,p_extra_info5_ref_type IN VARCHAR2 DEFAULT NULL
    ,p_extra_info5_value    IN VARCHAR2 DEFAULT NULL
  -- Standard API parms
    ,p_commit               IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version          IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list        IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status	    OUT NOCOPY VARCHAR2
    ,x_msg_count	    OUT NOCOPY NUMBER
    ,x_msg_data	            OUT NOCOPY VARCHAR2
  );

  /*#
   *  Given an Audit Log Id it resolves the appropriate message
   *  (replacing tokens, etc.)
   *
   *  @param p_audit_log_id      Audit Log Id
   *  @return Audit Message
   *
   *  @rep:displayname get_audit_message
   *
   */
  FUNCTION get_audit_message(
     p_audit_log_id IN NUMBER
  ) RETURN VARCHAR2;
  pragma restrict_references(get_audit_message, WNDS);

  /*#
   *  Given an Audit Log Id it returns the extra information segment
   *  (based on p_info_number).
   *
   *  @param p_audit_log_id      Audit Log Id
   *  @param p_info_number       Indicates which segment to return
   *  @return Extra information message
   *
   *  @rep:displayname get_extra_info
   *
   */
  FUNCTION get_extra_info(
     p_audit_log_id IN NUMBER
     ,p_info_number IN NUMBER
  ) RETURN VARCHAR2;
  pragma restrict_references(get_extra_info, WNDS);

END IBC_AUDIT_LOG_GRP;

 

/
