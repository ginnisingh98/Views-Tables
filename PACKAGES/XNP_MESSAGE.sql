--------------------------------------------------------
--  DDL for Package XNP_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_MESSAGE" AUTHID CURRENT_USER AS
/* $Header: XNPMSGPS.pls 120.1.12010000.2 2008/09/25 05:18:29 mpathani ship $ */

-- Record type for message header
TYPE Msg_Header_Rec_Type IS RECORD
(
	message_id        NUMBER ,
	message_code      VARCHAR2(20),
	reference_id      VARCHAR2(1024),
	opp_reference_id  VARCHAR2(40),
	creation_date     DATE,
	sender_name       VARCHAR2(300),  -- increased the size from 40 to 300 for 6880763
	recipient_name    VARCHAR2(40),
	version           NUMBER ,
	direction_indr    VARCHAR2(1),
	order_id          NUMBER,
	wi_instance_id    NUMBER,
	fa_instance_id    NUMBER
) ;


-- Timeout variable for dequeing a message from the queue. Used by POP()
-- and has a intialized value of one second.
--
pop_timeout		INTEGER := 1 ;
current_version         NUMBER := 1 ;
-- Constant visible on commit to the dequeue process
C_ON_COMMIT       CONSTANT NUMBER := 1 ;
-- Constant visible immediate to the dequeue process
C_IMMEDIATE       CONSTANT NUMBER := 2 ;

--
-- pre and suffixes that are used to generate user defined packages for
-- sending, publish messages.
-- used by XNPMSGP, XNPSTAC, XNPMBLP packages
-- By Anping Wang, bug refer. 1650015
-- 02/19/2001
g_pkg_prefix CONSTANT VARCHAR2(80) := 'XNP_' ;
g_pkg_suffix CONSTANT VARCHAR2(80) := '_U' ;

--  Define Exceptions
    stop_processing exception;

--
-- Retrieves a comma separated subscriber list for the message
--
PROCEDURE get_subscriber_list
(
	p_msg_code IN VARCHAR2
	,x_subscriber_list OUT NOCOPY VARCHAR2
 );

-- Retrieves a message for the specified message ID
--
PROCEDURE get
(
	p_msg_id IN NUMBER
	,x_msg_text OUT NOCOPY VARCHAR2
);

-- Retrieves a message  and the header for the specified message ID
-- Overloaded.
-- adabholk 03/2001
-- performance fix

PROCEDURE get
(
	p_msg_id IN NUMBER
	,x_msg_header OUT NOCOPY MSG_HEADER_REC_TYPE
	,x_msg_text OUT NOCOPY VARCHAR2
);

-- Notifies message processing failures of the event manager to FMC
--
PROCEDURE notify_fmc
(
	p_msg_id in NUMBER
	,p_error_desc IN VARCHAR2
) ;

-- Retrieves the header for a message, given the message ID
--
PROCEDURE get_header
(
	p_msg_id IN NUMBER
	,x_msg_header OUT NOCOPY msg_header_rec_type
);

--
--
-- Wrapper procedure for executing the processing logic
-- of a message.
--
PROCEDURE process
(
	p_msg_header IN msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,p_process_reference IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Wrapper for executing default processing logic
--
PROCEDURE default_process
(
	p_msg_header IN msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Validates a message of type XNP_MESSAGE
--
PROCEDURE validate
(
	p_msg_header IN OUT NOCOPY msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
);

-- Gets the next sequence for the Message
--
PROCEDURE get_sequence
(
	x_msg_id OUT NOCOPY NUMBER
);

--
--  Enqueues a message on the ORACLE Queue. Set the commit mode
--  to C_IMMEDIATE if an immediate commit is required.
--
PROCEDURE push
(
	p_msg_header IN msg_header_rec_type
	,p_body_text IN VARCHAR2
	,p_queue_name IN VARCHAR2
	,p_recipient_list IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_priority IN INTEGER DEFAULT 1
	,p_commit_mode IN NUMBER DEFAULT c_on_commit
	,p_delay IN NUMBER DEFAULT DBMS_AQ.NO_DELAY
	,p_fe_name IN VARCHAR2 DEFAULT NULL
	,p_adapter_name IN VARCHAR2 DEFAULT NULL
);

-- overloaded version of PUSH
--
PROCEDURE push
(
	p_message_id IN NUMBER
	,p_message_code IN VARCHAR2
	,p_reference_id IN VARCHAR2
	,p_opp_reference_id IN VARCHAR2
	,p_direction_indr IN VARCHAR2
	,p_creation_date IN DATE
	,p_sender_name IN VARCHAR2
	,p_recipient_name IN VARCHAR2
	,p_version OUT NOCOPY VARCHAR2
	,p_order_id IN NUMBER
	,p_wi_instance_id IN NUMBER
	,p_fa_instance_id IN NUMBER
	,p_body_text IN VARCHAR2
	,p_queue_name IN VARCHAR2
	,p_recipient_list IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_priority IN INTEGER DEFAULT 1
	,p_commit_mode IN NUMBER DEFAULT c_on_commit
);

-- Overloaded PUSH for Adapters
--
PROCEDURE push
(
	p_qname IN VARCHAR2
	,p_msg_text IN VARCHAR2
	,p_fe_name IN VARCHAR2
	,p_adapter_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_commit_mode IN NUMBER DEFAULT C_IMMEDIATE
) ;

-- Overloaded PUSH for Adapters that returns message id
--
PROCEDURE push
(
        P_QNAME IN VARCHAR2
        ,P_MSG_TEXT IN VARCHAR2
        ,P_FE_NAME IN VARCHAR2
        ,P_ADAPTER_NAME IN VARCHAR2
        ,X_MSG_ID OUT NOCOPY NUMBER
        ,X_ERROR_CODE OUT NOCOPY NUMBER
        ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
	,p_commit_mode IN NUMBER DEFAULT C_IMMEDIATE
);

--  Dequeues a message from the ORACLE Queue.
--
PROCEDURE pop
(
	p_queue_name IN VARCHAR2
	,x_msg_header OUT NOCOPY msg_header_rec_type
	,x_body_text OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_consumer_name IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
	,p_commit_mode IN NUMBER DEFAULT c_on_commit
	,p_msg_id IN RAW DEFAULT NULL
) ;

-- Overloaded POP()
--
PROCEDURE pop
(
	p_queue_name IN VARCHAR2
	,x_message_id OUT NOCOPY NUMBER
	,x_message_code OUT NOCOPY VARCHAR2
	,x_reference_id OUT NOCOPY VARCHAR2
	,x_opp_reference_id OUT NOCOPY VARCHAR2
	,x_body_text OUT NOCOPY VARCHAR2
	,x_creation_date OUT NOCOPY DATE
	,x_sender_name OUT NOCOPY VARCHAR2
	,x_recipient_name OUT NOCOPY VARCHAR2
	,x_version OUT NOCOPY VARCHAR2
	,x_order_id OUT NOCOPY NUMBER
	,x_wi_instance_id OUT NOCOPY NUMBER
	,x_fa_instance_id OUT NOCOPY NUMBER
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,p_consumer_name IN VARCHAR2 DEFAULT NULL
	,p_correlation_id IN VARCHAR2 DEFAULT NULL
) ;

-- Overloaded POP()
--
PROCEDURE pop
(
	p_queue_name IN VARCHAR2
	,p_consumer_name IN VARCHAR2
	,x_msg_text OUT NOCOPY VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_msg OUT NOCOPY VARCHAR2
	,p_timeout IN NUMBER DEFAULT 1
) ;

-- Updates the status of the message given the ID.
-- Messages can either be in a READY or PROCESSES state
--
PROCEDURE update_status
(
	p_msg_id IN NUMBER
	,p_status IN VARCHAR2
	,p_error_desc IN VARCHAR2 DEFAULT NULL
	,p_order_id IN NUMBER DEFAULT NULL
	,p_wi_instance_id IN NUMBER DEFAULT NULL
	,p_fa_instance_id IN NUMBER DEFAULT NULL
) ;

-- Gets the status of the message given the ID
--
PROCEDURE get_status
(
	p_msg_id IN NUMBER
	,x_status OUT NOCOPY VARCHAR2
 ) ;

--
--Inserts 'XNP_MESSAGE' and the new message as two additional elements
--into XNP_MSG_ELEMENTS table.
--
PROCEDURE xnp_mte_insert_element
(
	p_msg_code IN VARCHAR2
	,p_msg_type IN VARCHAR2
);

--
--Resets the message status to 'READY' and enqueues the message
--into the inbound queue for processing.
--
PROCEDURE fix
(
	p_msg_id IN NUMBER
);

-- Deletes the message from the System.
-- Ensures there is no runtime data in XNP_MSGS, XNP_TIMER_REGISTRY
-- and XNP_CALLBACK_EVENTS
--
PROCEDURE delete
(
	p_msg_code IN VARCHAR2
) ;

--   Enqueues the message and message body  on a user defined queue .

PROCEDURE PUSH_WF(
         p_msg_header      IN msg_header_rec_type
        ,p_body_text       IN VARCHAR2
        ,p_queue_name      IN VARCHAR2
        ,p_correlation_id  IN VARCHAR2 DEFAULT NULL
        ,p_priority        IN INTEGER DEFAULT 1
        ,p_commit_mode     IN NUMBER DEFAULT c_on_commit
        ,p_delay           IN NUMBER DEFAULT DBMS_AQ.NO_DELAY );


END xnp_message;

/
