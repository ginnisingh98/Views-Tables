--------------------------------------------------------
--  DDL for Package FND_CP_OPP_IPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_OPP_IPC" AUTHID CURRENT_USER AS
/* $Header: AFCPOPIS.pls 120.3 2006/09/15 17:07:36 pferguso noship $ */


-- Message types
-- these values must be kept in sync with OPPMessage.java
COMMAND_TYPE     constant number := 0;
REQUEST_TYPE     constant number := 1;
RETURN_TYPE      constant number := 2;


TYPE subscriber_list is table of varchar2(30);

--------------------------------------------------------------------------------


-- =========================================================
-- Subscription procedures
-- =========================================================

--
-- Subscribe to the OPP AQ
--
procedure Subscribe(subscriber in Varchar2);


--
-- Subscribe to the OPP AQ using a particular group
--
-- Subscribers will only receive messages targeted to this group,
-- i.e. where payload.message_group matches the subscriber's group
--
-- The OPP service will subscribe using the node name (or APPL_TOP name)
-- as its group id.
--
procedure Subscribe_to_group(subscriber in varchar2, groupid in varchar2);


--
-- Unsubscribe a single subscriber from the OPP AQ
--
procedure Unsubscribe(subscriber in Varchar2);


--
-- Return a count of how many subscribers are currently subscribed to the AQ
-- for a particular group.
--
function check_group_subscribers(groupid  in varchar2) return number ;


--
-- Select a random OPP AQ subscriber out of all the current subscribers.
-- Returns the subscriber name.
--
function select_random_subscriber return varchar2;


--
-- Remove all subscribers of the OPP AQ
--
procedure remove_all_subscribers;


--
-- Return a list of all subscribers
--
function list_subscribers return subscriber_list;





-- =========================================================
-- Message sending procedures
-- =========================================================



--
-- Generic send message procedure
-- Send a message of any type to one or more recipients
--
procedure send_message (recipients in subscriber_list,
                        sender     in Varchar2,
                        type       in Number,
                        message    in Varchar2,
                        Parameters in Varchar2);


--
-- Send a message of any type to a specific process
--
procedure send_targeted_message (recipient   in Varchar2,
                                 sender      in Varchar2,
                                 type        in Number,
                                 message     in Varchar2,
                                 Parameters  in Varchar2,
								 correlation in Varchar2 default null);


--
-- Send a message to a group to post-process a request
--
procedure send_request (groupid       in Varchar2,
                        sender        in Varchar2,
                        request_id    in number,
                        Parameters    in Varchar2);


--
-- Send a message to a specific process to post-process a request
--
procedure send_targeted_request ( recipient  in Varchar2,
                                  sender     in Varchar2,
                                  request_id in number,
                                  parameters in Varchar2);


--
-- Send an OPP command to a specific process
--
procedure send_command ( recipient  in Varchar2,
                         sender     in Varchar2,
                         command    in Varchar2,
                         parameters in Varchar2);







-- =========================================================
-- Receiving messages
-- =========================================================


--
-- Dequeue a message from the OPP AQ
--
-- INPUT:
--   Handle               - Used as the consumer name
--   Message_Wait_Timeout - Timeout in seconds
--
-- OUTPUT:
--   Success_Flag   - Y if received message, T if timeout, N if error
--   Message_Type   - Type of message
--   Message_group  - Group message was sent to
--   Message        - Message contents
--   Parameters     - Message payload
--   Sender         - Sender of message
--
-- If an exception occurs, success_flag will contain 'N', and
-- Message will contain the error message.
--

Procedure Get_Message ( Handle               in Varchar2,
                        Success_Flag         OUT NOCOPY  Varchar2,
                        Message_Type         OUT NOCOPY  Number,
                        Message_group        OUT NOCOPY  Varchar2,
                        Message              OUT NOCOPY  Varchar2,
                        Parameters           OUT NOCOPY  Varchar2,
                        Sender               OUT NOCOPY  Varchar2,
                        Message_Wait_Timeout IN          Number   default 60,
                        Correlation          IN          Varchar2 default null);

END fnd_cp_opp_ipc;

 

/
