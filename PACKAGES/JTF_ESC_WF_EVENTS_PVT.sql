--------------------------------------------------------
--  DDL for Package JTF_ESC_WF_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ESC_WF_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfecbes.pls 120.1 2005/07/02 00:41:03 appldev noship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This Interface is used for raising a BES event in Escalation
 * Management, for Create / Update / Delete of Escaltion and its
 * references.
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

/*#
* Raises the Create Escalation Event
*
* @param p_esc_rec the escalation attributes used when raising a create event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Create Escalation Event
* @rep:compatibility S
*/
  PROCEDURE publish_create_esc (
     P_ESC_REC         IN      jtf_ec_pvt.Esc_Rec_type
  );

/*#
* Raises the Update Escalation Event
*
* @param p_esc_rec the escalation attributes used when raising a update event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Update Escalation Event
* @rep:compatibility S
*/
   PROCEDURE publish_update_esc (
      P_ESC_REC         IN      jtf_ec_pvt.Esc_Rec_type
     );

/*#
* Raises the Delete Escalation Event
*
* @param p_esc_rec the escalation attributes used when raising a delete event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Delete Escalation Event
* @rep:compatibility S
*/
   PROCEDURE publish_delete_esc (
     P_ESC_REC         IN      jtf_ec_pvt.Esc_Rec_type
   );


/*#
* Raises the Create Escalation References Event
*
* @param p_esc_ref_rec the escalation references attributes used when raising a create escalation reference event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Create Escalation References Event
* @rep:compatibility S
*/
   PROCEDURE publish_create_escref (
     P_ESC_REF_REC         IN      Jtf_ec_references_pvt.Esc_Ref_rec

   );

/*#
* Raises the Update Escalation References Event
*
* @param p_esc_ref_rec_old the old escalation references attributes, existing values
* @param p_esc_ref_rec_new the new escalation references attributes, changed values
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Update Escalation References Event
* @rep:compatibility S
*/
   PROCEDURE publish_update_escref (
     P_ESC_REF_REC_OLD      IN     Jtf_ec_references_pvt.Esc_Ref_rec,
     P_ESC_REF_REC_NEW      IN     Jtf_ec_references_pvt.Esc_Ref_rec
       );

/*#
* Raises the Delete Escalation References Event
*
* @param p_esc_ref_rec the escalation references attributes used when raising a delete escalation reference event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Raise Delete Escalation References Event
* @rep:compatibility S
*/
   PROCEDURE publish_delete_escref (
     P_ESC_REF_REC         IN      Jtf_ec_references_pvt.Esc_Ref_rec
   );

/*#
* Retrieves the item key for the Business Event
*
* @param p_event_name the name of the Busines Event
* @return the item key for the Business Event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Item Key
* @rep:compatibility S

*/
  FUNCTION get_item_key(p_event_name IN VARCHAR2)
  RETURN VARCHAR2;


/*#
* Sets the values for the Parameters and add to the WF parameter list while publishing an Event
* This is an overloaded procedure used when attribute values are Text
*
* @param p_attribute_name the attribute used for the Busines Event
* @param p_old_value the old value for the attribute - used during update event
* @param p_new_value the new value for the attribute - used for all events
* @param p_action the parameter to determine the nature of event - Create or Update or Delete
* @param p_list the wf parameter list type used to store BES attributes with their values
* @param publish_if_change the flag to determine publishing old and new values on an Update Event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Attributes to List
* @rep:compatibility S
*/
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN VARCHAR2,
    P_NEW_VALUE IN VARCHAR2,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );

/*#
* Sets the values for the Parameters and add to the WF parameter list while publishing an Event
* This is an overloaded procedure used when attribute values are Numeric
*
* @param p_attribute_name the attribute used for the Busines Event
* @param p_old_value the old value for the attribute - used for update event
* @param p_new_value the new value for the attribute - used for all events
* @param p_action the parameter to determine the nature of event - Create or Update or Delete
* @param p_list the wf parameter list type used to store BES attributes with their values
* @param publish_if_change the flag to determine publishing old and new values on an Update Event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Attributes to List
* @rep:compatibility S
*/
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN NUMBER,
    P_NEW_VALUE IN NUMBER,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );

/*#
* Sets the values for the Parameters and add to the WF parameter list while publishing an Event
* This is an overloaded procedure used when attribute values are Dates
*
* @param p_attribute_name the attribute used for the Busines Event
* @param p_old_value the old value for the attribute - used for update event
* @param p_new_value the new value for the attribute - used for all events
* @param p_action the parameter to determine the nature of event - Create or Update or Delete
* @param p_list the wf parameter list type used to store BES attributes with their values
* @param publish_if_change the flag to determine publishing old and new values on an Update Event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Attributes to List
* @rep:compatibility S
*/
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN DATE,
    P_NEW_VALUE IN DATE,
    P_ACTION    IN VARCHAR2,
    P_LIST      IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  );


END;

 

/
