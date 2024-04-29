--------------------------------------------------------
--  DDL for Package JTF_FM_AQ_WRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_AQ_WRAPPER_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvaqs.pls 115.3 2003/09/23 17:40:07 sxkrishn ship $*/

---------------------------------------------------------------------
-- PROCEDURE
--    Enqueue
--
-- PURPOSE
--    A wrapper procedure for doing enqueuing.
--
-- PARAMETERS
--    queue_name - a queue name
--    message_in - enqueued message
--    priority   - message priority
--    message_handle - message id of enqueuing
--
-- NOTES
---------------------------------------------------------------------

PROCEDURE Enqueue
(
    queue_name 	   IN VARCHAR2,
    message_in     IN RAW,
    priority       IN NUMBER,
    message_handle OUT NOCOPY RAW
);

---------------------------------------------------------------------
-- PROCEDURE
--    Dequeue
--
-- PURPOSE
--    A wrapper procedure for doing dequeuing.
--
-- PARAMETERS
--    queue_name     - a queue name
--    message_handle - message id of enqueuing
--    message_out    - dequeued message
--
-- NOTES
---------------------------------------------------------------------

PROCEDURE Dequeue
(
    queue_name     IN VARCHAR2,
    waiting_time   IN NUMBER,
    message_handle IN RAW,
    message_out    OUT NOCOPY RAW
);



---------------------------------------------------------------------
-- PROCEDURE
--    Enqueue_Segment
--
-- PURPOSE
--    A wrapper procedure for doing enqueuing.
--
-- PARAMETERS
--    queue_name - a queue name
--    message_in - enqueued message
--    priority   - message priority
--    message_handle - message id of enqueuing
--    request_id  - request id  of this segment
--
-- NOTES -- Added by SK on July 10, 2003
---------------------------------------------------------------------

PROCEDURE Enqueue_Segment
(
    queue_name 	   IN VARCHAR2,
    message_in     IN RAW,
    priority       IN NUMBER,
    message_handle OUT NOCOPY RAW,
	request_id     IN NUMBER
);

END JTF_FM_AQ_WRAPPER_PVT;

 

/
