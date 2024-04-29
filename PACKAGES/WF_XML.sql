--------------------------------------------------------
--  DDL for Package WF_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_XML" AUTHID CURRENT_USER as
/* $Header: wfmxmls.pls 120.6.12010000.5 2021/03/04 08:09:31 ksanka ship $ */
/*#
 * Provides APIs to access the Oracle Workflow XML message processing subsystem.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow XML Message Processing Subsystem
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY WF_NOTIFICATION
 * @rep:compatibility S
 */


/*===========================================================================

  PL*SQL TABLE NAME:	wf_xml_attr_rec_type

  DESCRIPTION:	Stores a list of element attribute/value pairs
============================================================================*/

   TYPE wf_xml_attr_rec_type IS RECORD
   (
      attribute           VARCHAR2(250), -- Name for the attribute,
      value               VARCHAR2(1000) -- Value that the attribute
                                         -- will take on
   );


   TYPE wf_xml_attr_table_type IS TABLE OF
       wf_xml_attr_rec_type INDEX BY BINARY_INTEGER;

   TYPE wf_response_rec_t IS RECORD
   (
    NAME     VARCHAR2(30),
    TYPE     VARCHAR2(8),
    FORMAT   VARCHAR2(240),
    VALUE    VARCHAR2(32000)
   );

   TYPE wf_responseList_t IS TABLE OF
     wf_response_rec_t
   INDEX BY BINARY_INTEGER;

   WF_NTF_REASIGN VARCHAR2(100) := 'oracle.apps.wf.notification.reassign';
   WF_NTF_CLOSE VARCHAR2(100) := 'oracle.apps.wf.notification.close';
   WF_NTF_CANCEL VARCHAR2(100) := 'oracle.apps.wf.notification.cancel';

   -- Part of the oracle.apps.wf.notification.send.group group
   WF_NTF_SEND_MESSAGE VARCHAR2(100) := 'oracle.apps.wf.notification.send';

   WF_NTF_SEND_QUESTION VARCHAR2(100) := 'oracle.apps.wf.notification.question';
   WF_NTF_SEND_ANSWER   VARCHAR2(100) := 'oracle.apps.wf.notification.answer';  -- As such there is no need for this

   WF_NTF_SEND_SUMMARY VARCHAR2(100) :=
                                'oracle.apps.wf.notification.summary.send';
   WF_NTF_SUMMARY VARCHAR2(100) := 'oracle.apps.fnd.wf.mailer.Mailer.notification.summary';

   -- Part of the oracle.apps.wf.notification.receive group
   WF_NTF_RECEIVE_ERROR VARCHAR2(100) :=
                                'oracle.apps.wf.notification.receive.error';
   WF_NTF_RECEIVE_MESSAGE VARCHAR2(100) :=
                                'oracle.apps.wf.notification.receive.message';
   WF_NTF_RECEIVE_SENDRETURN VARCHAR2(100) :=
                              'oracle.apps.wf.notification.receive.sendreturn';
   WF_NTF_RECEIVE_UNAVAIL VARCHAR2(100) :=
                                'oracle.apps.wf.notification.receive.unavail';

   -- GetTagValue - Obtain the value for a given TAG from within the
   --               Document Tree
   -- IN
   --    document as a CLOB
   --    TAG to find the value of
   --    The position to start looking for the TAG from
   -- OUT
   --    Value of the TAG. ie the value between the start and end TAGs
   --    The position in the CLOB after the find
   --    The list of attributes associated with the TAG (Not implemented as yet)
   procedure GetTagValue(p_doc in out NOCOPY CLOB, p_tag in varchar2,
                         p_value out NOCOPY varchar2,
                         p_pos in out NOCOPY integer,
                         p_attrlist in out NOCOPY wf_xml_attr_table_type);

   -- GetXMLMessage - Return a CLOB Document containing an XML encoded
   --                 version of the notification. No recipients list
   --                 will be populated. That will be the responsibility
   --                 of the calling procedure.
   --
   -- IN
   --     notification id
   --     Protocol for the message
   --     List of recipients to recieve the notification
   --     mailer node name
   --     Web Agent for the HTML attachments
   --     Reply to address for the final notification
   --     Language for the notification
   --     Territory for the notification
   -- OUT
   --     Prioirty
   --     A CLOB Containing the XML encoded message.
   procedure GetXMLMessage (p_nid       in  number,
                        p_protocol  in varchar2,
                        p_recipient_list in WF_DIRECTORY.wf_local_roles_tbl_type,
                        p_node      in  varchar2,
                        p_agent     in  varchar2,
                        p_replyto   in  varchar2,
                        p_nlang     in  varchar2,
                        p_nterr     in varchar2,
                        p_priority out NOCOPY number,
                        p_message in out NOCOPY CLOB);

   -- EnqueueNotification - To push a notification to the outbound notification
   --                       queue.
   -- IN
   --    Notification ID
   procedure EnqueueNotification(p_nid in number);


   -- DequeueMessage - Remove a notification from the queue
   -- IN
   --    Queue name to operate on
   --    Correlation for the message - NID in this implementation
   -- OUT
   --    The message that is obtained from the queue.
   --    Timeout to signal whether the queue is empty.

   procedure DequeueMessage(p_queue_name in varchar2,
                            p_correlation in varchar2 default NULL,
                            p_message   in out NOCOPY CLOB,
                            p_timeout out NOCOPY boolean);
   -- GetMessage - Get email message data
   -- IN
   --    Queue name to operate on
   -- OUT
   --    Notification ID
   --    Comma seperated list of the recipients of the notification
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetMessage(
       p_queue     in  number,
       p_nid          out NOCOPY number,
       p_receiverlist out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2);

   -- GetSortMessage - Get email message data
   -- IN
   --    Queue number to operate on
   -- OUT
   --    Notification ID
   --    Recipient
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetShortMessage(
       p_queue        in  number,
       p_nid          out NOCOPY number,
       p_recipient    out NOCOPY varchar2,
       p_status       out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2);

   -- GetExceptionMessage - Get email message data
   -- IN
   --    Queue number to operate on
   -- OUT
   --    Notification ID
   --    Recipient
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetExceptionMessage(
       p_queue     in  number,
       p_nid          out NOCOPY number,
       p_recipient out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY boolean,
       p_error_result in out NOCOPY varchar2);

   -- GetShortMessage - Get email message data
   -- IN
   --    Queue name to operate on
   -- OUT
   --    Notification ID
   --    Recipient
   --    Status of the notification - For the purpose of message templating
   --    Timout. Returns TRUE where the queue is empty.
   --    Error message
   procedure GetQueueMessage(
       p_queuename    in  varchar2,
       p_nid          out NOCOPY number,
       p_recipient out NOCOPY varchar2,
       p_status      out NOCOPY varchar2,
       p_timeout      out NOCOPY integer,
       p_error_result in out NOCOPY varchar2);

   -- RemoveNotification
   --     To remove all enqueues messages for a given notification.
   -- IN
   --    Notification ID of the message to locate and remove.
   -- NOTE
   --    This is a destructive procedure that's sole purpose is to purge the
   --    message from the queue. We only call this when we do not care for the
   --    content.
   procedure RemoveNotification(p_nid in number);

   -- setFistMessage
   --    To set the global variable g_first_message
   -- IN
   --    'Y' to set the flag to TRUE
   procedure setFirstMessage(p_first_message IN varchar2);


   -- Generate
   -- The generate function for the WF_NOTIFICATION_OUT queue. This
   -- will handle all oracle.apps.wf.notification.send.% events and
   -- generate an XML representation of the outbound notification.
   -- IN
   -- p_event_name - The VARCHAR2 event name
   -- p_event_key - The VARCHAR2 event key
   -- p_parameter_list - The wf_parameter_list_t containing the parameters
   --                    that were passed in with the event.
   -- OUT
   -- CLOB The XML representation of the outbound notification
   /*#
    * Generates the XML message content as the event data for events in the
    * Notification Send group (oracle.apps.wf.notification.send.group). The
    * send events are then ready to be placed on the WF_NOTIFICATION_OUT
    * agent to be processed by the notification mailer.
    *
    * @param p_event_name The internal name of the event
    * @paraminfo {rep:required}
    * @param p_event_key The event key that identifies the specific instance of the event
    * @paraminfo {rep:required}
    * @param p_parameter_list The list of additional parameters for the event
    * @paraminfo {@rep:innertype WF_PARAMETER_LIST_T} {rep:required}
    *
    * @return The XML message content to use as the event data payload
    *
    * @rep:displayname Generate Notification Content
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    */
   function Generate(p_event_name in varchar2,
                      p_event_key in varchar2,
                      p_parameter_list in wf_parameter_list_t default null)
                     return clob;

   function GetAttachment(p_nid in number,
                          p_doc in out NOCOPY CLOB,
                          p_agent in varchar2,
                          p_disposition in varchar2,
                          p_doc_type in varchar2,
                          p_pos in out NOCOPY integer) return integer;

   -- sendNotification
   -- This API is a wrapper to the wf_xml.enqueueNotification. It is provided
   -- as forward compatabilty for the original mailer since the call to
   -- wf_xml.enqueueNotification has been removed from
   -- wf_notification.sendSingle.
   -- To use the original mailer, one must enable the subscription that will
   --  call this rule function.
   -- IN
   -- p_subscription
   -- p_event
   -- RETURN
   -- varchar2 of the status
   /*#
    * Provides forward compatibility for the previous C-based Notification
    * Mailer that is now replaced by the Java-based Workflow Notification
    * Mailer. To use the C-based mailer, you must enable the subscription
    * to the oracle.apps.wf.notification.send.group event that calls this
    * rule function.
    *
    * @param p_subscription_guid The globally unique identifier of the subscription that calls this rule function
    * @paraminfo {@rep:required}
    * @param p_event The event message that triggers the subscription
    * @paraminfo {@rep:innertype WF_EVENT_T} {@rep:required}
    * @return  If succeed, returns 'SUCCESS' otherwise 'ERROR'
    *
    * @rep:displayname Legacy Send Notification Rule
    * @rep:scope public
    * @rep:lifecycle obsolete
    * @rep:compatibility N
    */
   function SendNotification (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2;

   -- receive
   -- Handle the notification receive events
   -- This will handle the processing of the inbound responses
   -- IN
   -- p_subscription_guid - The RAW GUID of the event subscription
   -- p_event - The WF_EVENT_T containing the event information
   function receive (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2;

   -- GetResponseDetails
   -- Gets the response details from the incoming XML Notifiction
   -- structure.
   --
   -- IN
   -- message - The XML Notification structure containing the
   --           inbound response
   procedure getResponseDetails(message in CLOB);

   procedure getResponseDetails(message in CLOB, node out NOCOPY varchar2,
                             version out NOCOPY integer,
                             fromRole out NOCOPY varchar2,
                             responses in out NOCOPY wf_responseList_t);

   -- SummaryRule
   -- To handle the summary notification request event
   -- and call the approapriate summary generate function for
   -- either the role or the member of the role.
   /*#
    * Launches summary notifications for each role that has open
    * notifications and a notification preference of SUMMARY or SUMHTML.
    * This function calls the appropriate APIs to generate the summary
    * content for each role and for each member of those roles.
    *
    * @param p_subscription_guid The globally unique identifier of the subscription that calls this rule function
    * @paraminfo {@rep:required}
    * @param p_event The event message that triggers the subscription
    * @paraminfo {@rep:innertype WF_EVENT_T} {@rep:required}
    * @return  If succeed, returns 'SUCCESS' otherwise 'ERROR'
    *
    * @rep:displayname Send Summary Notification Rule
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    */
   function SummaryRule (p_subscription_guid in raw,
                     p_event in out NOCOPY WF_EVENT_T) return varchar2;

   /*
   ** error_rule - dispatch functionality for error subscription processing
   **
   **   Identical to default_rule, but if an exception is caught we raise it
   **   up to cause a rollback.  We don't want messages processed off the
   **   error queue to be continually recycled back on to the error queue.
   **
   **   Returns SUCCESS or raises an exception
   **
   */
   /*#
    * Catches and raises internal exceptions in message processing to force
    * a rollback. This API helps prevent endless loops if failed messages
    * result in error messages that also fail.
    *
    * @param p_subscription_guid The globally unique identifier of the subscription that calls this rule function
    * @paraminfo {@rep:required}
    * @param p_event The event message that triggers the subscription
    * @paraminfo {@rep:innertype WF_EVENT_T} {@rep:required}
    * @return  If succeed, returns 'SUCCESS' otherwise 'ERROR'
    *
    * @rep:displayname Send Notification Error Rule
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    */
   FUNCTION error_rule(p_subscription_guid in raw,
                       p_event in out nocopy wf_event_t) return varchar2;

   -- Gets the LOB content for a PLSQLCLOB
   -- IN
   -- pAPI the API to call
   -- pDoc The LOB to take the document
   procedure getDocContent(pNid in NUMBER, pAPI in VARCHAR2,
                           pDoc in out nocopy CLOB);

   -- Gets the LOB content for a PLSQLCLOB
   -- IN
   -- pAPI the API to call
   -- pDoc The LOB to take the document
   procedure getBDocContent(pNid in NUMBER, pAPI in VARCHAR2,
                           pDoc in out nocopy BLOB);

   -- gets the size of the current LOB table
   function getLobTableSize return number;

   -- AddElementAttribute - Add an Element Attribute Value pair to the attribute
   --                       list.
   -- IN
   --    Name of the attribute
   --    Value for the attribute
   --    The attribute list to add the name/value pair to.
   procedure AddElementAttribute(p_attribute_name IN VARCHAR2,
                                 p_attribute_value IN VARCHAR2,
                                 p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type);

   -- NewLOBTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewLOBTag (p_doc in out NOCOPY CLOB,
                    p_pos in integer,
                    p_tag in varchar2,
                    p_data in varchar2,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
   return integer;

   -- SkipLOBTag - To move return a pointer past the nominated TAG
   --           starting from a given position in the document.
   -- IN
   --    document
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added
   -- RETURN
   --   New position past the </TAG>.
   function SkipLOBTag (p_doc in out NOCOPY CLOB,
                     p_tag in varchar2,
                     p_offset in out NOCOPY integer,
                     p_occurance in out NOCOPY integer)
   return integer;

   -- NewLOBTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewLOBTag (p_doc in out NOCOPY CLOB,
                    p_pos in integer,
                    p_tag in varchar2,
                    p_data in CLOB,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
   return integer;

   -- SkipTag - To move return a pointer past the nominated TAG
   --           starting from a given position in the document.
   -- IN
   --    document
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added
   -- RETURN
   --   New position past the </TAG>.
   function SkipTag (p_doc in out NOCOPY VARCHAR2,
                     p_tag in varchar2,
                     p_offset in out NOCOPY integer,
                     p_occurance in out NOCOPY integer)
   return integer;

   -- NewTag - Create a new TAG node and insert it into the
   --          Document Tree
   -- IN
   --    document as a CLOB
   --    Position to take the new Tag Node
   --    New Tag to be created
   --    Data to be added between the start and end TAGs
   --    Attribute list to be included in the opening TAG
   -- OUT
   --    The document containing the new TAG.
   function NewTag (p_doc in out NOCOPY VARCHAR2,
                    p_pos in integer ,
                    p_tag in varchar2,
                    p_data in varchar2,
                    p_attribute_list IN OUT NOCOPY wf_xml_attr_table_type)
   return integer;

   -- Send_Rule - This is the subscription rule function for the event group
   --             'oracle.apps.wf.notification.send.group'. If the message
   --             payload is not complete return 'SUCCESS' from here, hence
   --		  incomplete message payload/event will not be enqueued to
   --		  WF_NOTIFICATION_OUT AQ.
   -- IN
   --    p_subscription_guid Subscription GUID as a CLOB
   --    p_event Event Message
   -- OUT
   --    Status as ERROR, SUCCESS, WARNING
   function Send_Rule(p_subscription_guid in raw,
                  p_event in out nocopy wf_event_t)
   return varchar2;
   -- Bug 30681832 : code changes to validate the document association with notification.
    -- get_attachment_details based on notification id
    -- IN
    -- p_nid as notification id
    -- p_doc_id  as document id
    -- OUT
    -- p_doc_id  as document id associated to notification
    -- p_media_id as mediaid associated to attached document
  procedure get_attachment_details(p_nid in number,
                                  p_doc_id in out nocopy number,
                                  p_media_id out nocopy number);

end WF_XML;

/
