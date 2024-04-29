--------------------------------------------------------
--  DDL for Package PO_BUSINESSEVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_BUSINESSEVENT_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRBES.pls 120.1 2007/02/15 20:46:14 dedelgad ship $ */

-- <R12 OTM INTEGRATION START>
-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  raise_event
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Generic private procedure to raise PO business event.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_event_name
--  Business Event name
--p_param_list
-- The list of parameters that should be attached to the business event.
--p_deferred
-- Determines if we should defer the event or not
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE raise_event (
  p_api_version      IN            NUMBER
, p_event_name       IN            VARCHAR2
, p_param_list       IN            PO_EVENT_PARAMS_TYPE
, p_deferred         IN            BOOLEAN DEFAULT FALSE
, x_return_status    IN OUT NOCOPY VARCHAR2
);
-- <R12 OTM INTEGRATION END>

-------------------------------------------------------------------------------
--Start of Comments
--Name:
--  raise_event
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Generic private procedure to rasie PO business event.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_event_name
--  Business Event name
--p_entity_name
--  Business Event entity name.
--p_entity_id
--  Entity primary key.
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count:
--  Indicates the number of messages.
--x_msg_data:
--  Message body.
--Testing:
--  Need to integrate FTE to implement the testing.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE raise_event
(
    p_api_version      IN            NUMBER,
    x_return_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count        IN OUT NOCOPY NUMBER,
    x_msg_data         IN OUT NOCOPY VARCHAR2,
    p_event_name       IN            VARCHAR2,
    p_entity_name      IN            VARCHAR2,
    p_entity_id        IN            NUMBER
);

END PO_BUSINESSEVENT_PVT;

/
