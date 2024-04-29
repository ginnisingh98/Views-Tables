--------------------------------------------------------
--  DDL for Package M4U_XML_GENPROCESS_OUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_XML_GENPROCESS_OUT" AUTHID CURRENT_USER AS
/* $Header: M4UOUTWS.pls 120.0 2005/05/24 16:20:56 appldev noship $ */
/*#
 * This package contains the private APIs which are invoked by the M4USTD/Generic XML Outbound Workflow
 * @rep:scope private
 * @rep:product CLN
 * @rep:displayname M4U Generic XML Outbound workflow private APIs.
 * @rep:category BUSINESS_ENTITY EGO_ITEM
 */

        -- Name
        --      create_collab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      creates new SCTC collaboration based on M4USTD WF item-attributes
        /*#
         * This procedure creates collaboration based on XMLGateway, CLN parameters with are set as item-attributes of the workflow.
         * @param itemtype WF activity itemtype parameter
         * @param itemkey WF activity itemkey parameter
         * @param actid WF activity actid parameter
         * @param funcmode WF activity funcmode parameter
         * @param resultout WF activity resultout parameter
         * @rep:scope private
         * @rep:displayname Creates collaboration based on XMLGateway, CLN parameters
        */
        PROCEDURE create_collab_setattr(
                                                itemtype   IN VARCHAR2,
                                                itemkey    IN VARCHAR2,
                                                actid      IN NUMBER,
                                                funcmode   IN VARCHAR2,
                                                resultout  IN OUT NOCOPY VARCHAR2
                                       );


        -- Name
        --      update_collab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      updates SCTC collaboration based on M4USTD WF item-attributes
        /*#
         * This procedure updates the collaboration history for item-batch with the progress made by the workflow or any other errors encountered by the workflow.
         * @param itemtype WF activity itemtype parameter
         * @param itemkey WF activity itemkey parameter
         * @param actid WF activity actid parameter
         * @param funcmode WF activity funcmode parameter
         * @param resultout WF activity resultout parameter
         * @rep:scope private
         * @rep:displayname Updates collaboration history with progress in workflow.
        */
        PROCEDURE update_collab_setattr(
                                                itemtype   IN VARCHAR2,
                                                itemkey    IN VARCHAR2,
                                                actid      IN NUMBER,
                                                funcmode   IN VARCHAR2,
                                                resultout  IN OUT NOCOPY VARCHAR2
                                        );


        -- Name
        --      create_batchcollab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      creates multiple SCTC collaboration based on M4USTD WF item-attributes
        /*#
         * This procedure creates multiple collaborations for an item batch.
         * @param itemtype WF activity itemtype parameter
         * @param itemkey WF activity itemkey parameter
         * @param actid WF activity actid parameter
         * @param funcmode WF activity funcmode parameter
         * @param resultout WF activity resultout parameter
         * @rep:scope private
         * @rep:displayname Creates multiple collaborations for an item batch.
        */
        PROCEDURE create_batchcollab_setattr(
                                                itemtype   IN VARCHAR2,
                                                itemkey    IN VARCHAR2,
                                                actid      IN NUMBER,
                                                funcmode   IN VARCHAR2,
                                                resultout  IN OUT NOCOPY VARCHAR2
                                        );

        -- Name
        --      update_batchcollab_setattr
        -- Purpose
        --
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      updates multiple SCTC collaboration based on M4USTD WF item-attributes
        /*#
         * The procedure updates the collaboration history for an item-batch with the progress made by the workflow or any other errors encountered by the workflow.
         * @param itemtype WF activity itemtype parameter
         * @param itemkey WF activity itemkey parameter
         * @param actid WF activity actid parameter
         * @param funcmode WF activity funcmode parameter
         * @param resultout WF activity resultout parameter
         * @rep:scope private
         * @rep:displayname Updates multiple collaborations for an item-batch with progress in workflow.
        */
        PROCEDURE update_batchcollab_setattr(
                                                itemtype   IN VARCHAR2,
                                                itemkey    IN VARCHAR2,
                                                actid      IN NUMBER,
                                                funcmode   IN VARCHAR2,
                                                resultout  IN OUT NOCOPY VARCHAR2
                                        );


        -- Name
        --      set_aq_correlation
        -- Purpose
        --      sets the PROTOCOL_TYPE event attribute in the ECX_EVENT_MESSAGE item attribute
        --      This is in-turn used to set AQ correlation-id by the queue-handler
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      none
        /*#
         * Sets value of event attribute 'AQ correlation id', of the ECX_EVENT_MESSAGE item-attribute to UCC:HTTP or UCC:AS2
         * based on the value of the profile M4U_USE_HTTP_ADAPTER. If any errors encountered previously in the workflow, the correlation-id
         * is set to 'UCC:ERROR'.
         * @param itemtype Workflow itemtype parameter
         * @param itemkey Workflow itemkey parameter
         * @param actid  Workflow actid parameter
         * @param funcmode Workflow funcmode parameter
         * @param resultout Workflow resultout parameter
         * @rep:scope private
         * @rep:displayname Set AQ colleration-id of XML message event.
        */
        PROCEDURE set_aq_correlation(
             itemtype   IN VARCHAR2,
             itemkey    IN VARCHAR2,
             actid      IN NUMBER,
             funcmode   IN VARCHAR2,
             resultout  IN OUT NOCOPY VARCHAR2);



        -- Name
        --      check_send_method
        -- Purpose
        --      returns send_method to be used
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.
        /*#
         * This M4USTD/Send XML Payload workflow branches to select the correct adapter to be
         * used for transporting the XML message to UCCnet registry.
         * @param itemtype Workflow itemtype parameter
         * @param itemkey Workflow itemkey parameter
         * @param actid  Workflow actid parameter
         * @param funcmode Workflow funcmode parameter
         * @param resultout Workflow resultout parameter, possible values are UCC:HTTP, UCC:AS2, UCC:ERROR
         * @rep:scope private
         * @rep:displayname Check send method.
        */
        PROCEDURE check_send_method(
             itemtype   IN VARCHAR2,
             itemkey    IN VARCHAR2,
             actid      IN NUMBER,
             funcmode   IN VARCHAR2,
             resultout  IN OUT NOCOPY VARCHAR2) ;



        -- Name
        --      dequeue_ucc_message
        -- Purpose
        --      dequeues payload from AQ when correlation is UCC:ERROR|UCC:HTTP
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      Need to make a modification to set QueueName to be used in dequeue
        /*#
         * Dequeues the generated XML messages from the ECX outqueue, when the UCCnet HTTP Adapter
         * is used for transporting the XML message payload to UCCnet.
         * @param itemtype Workflow itemtype parameter
         * @param itemkey Workflow itemkey parameter
         * @param actid  Workflow actid parameter
         * @param funcmode Workflow funcmode parameter
         * @param resultout Workflow resultout parameter
         * @rep:scope private
         * @rep:displayname Dequeue UCCnet XML message from ECX AQ.
        */
        PROCEDURE dequeue_ucc_message(
             itemtype   IN VARCHAR2,
             itemkey    IN VARCHAR2,
             actid      IN NUMBER,
             funcmode   IN VARCHAR2,
             resultout  IN OUT NOCOPY VARCHAR2);


        -- Name
        --      raise_payload_event
        -- Purpose
        --      Code workaround since raiseEvent is not propogating the event payload to
        --      JAVA Business Event Subscriptions
        -- Arguments
        --      itemtype                => WF item type
        --      itemkey                 => WF item key
        --      actid                   => WF act id
        --      funcmode                => WF func mode
        --      resultout               => result param
        -- Notes
        --      None.
        /*#
         * Raises a business event, whose name is supplied as an activity-attribute
         * with the generated XML message as event data.
         * @param itemtype Workflow itemtype parameter
         * @param itemkey Workflow itemkey parameter
         * @param actid  Workflow actid parameter
         * @param funcmode Workflow funcmode parameter
         * @param resultout Workflow resultout parameter
         * @rep:scope private
         * @rep:displayname Raise business event with XML payaload.
        */
        PROCEDURE raise_payload_event(
                itemtype   IN VARCHAR2,
                itemkey    IN VARCHAR2,
                actid      IN NUMBER,
                funcmode   IN VARCHAR2,
                resultout  IN OUT NOCOPY VARCHAR2);


END m4u_xml_genprocess_out;

 

/
