--------------------------------------------------------
--  DDL for Package Body PO_BUSINESSEVENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_BUSINESSEVENT_PVT" AS
/* $Header: POXVRBEB.pls 120.1 2007/02/15 20:44:17 dedelgad ship $ */

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
)
IS

l_package_name      CONSTANT VARCHAR2(30) := 'PO_BUSINESS_EVENT';
l_api_name          CONSTANT VARCHAR2(30) := 'raise_event';
l_api_version       CONSTANT NUMBER       := 1.0;

l_param_list        PO_EVENT_PARAMS_TYPE;
l_wf_param_list     WF_PARAMETER_LIST_T;
l_event_key         VARCHAR2(240);

BEGIN
  -- Initialize API return status to success
  x_return_status := FND_API.g_ret_sts_success;

  -- Standard Start of API savepoint
  SAVEPOINT raise_event;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call (
            p_current_version_number => l_api_version
          , p_caller_version_number  => p_api_version
          , p_api_name               => l_api_name
          , p_pkg_name               => l_package_name))
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  -- calculate the event key
  l_event_key := 'oracle.apps.po.event.' || p_event_name || '_'
                  || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS:FF');

  l_param_list := p_param_list;

  l_param_list.add_param (
    p_param_name    => 'Q_CORRELATION_ID'
  , p_param_value   => p_event_name );

  -- get the WF param list
  l_wf_param_list := l_param_list.get_wf_parameter_list();

  -- defer event if necessary
  IF (p_deferred) THEN
    WF_EVENT.setdispatchmode('ASYNC');
  END IF;

  -- raise event
  WF_EVENT.raise (
    p_event_name =>  p_event_name
  , p_event_key  =>  l_event_key
  , p_parameters =>  l_wf_param_list);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    ROLLBACK TO raise_event;
    FND_MSG_PUB.add_exc_msg (
      p_pkg_name       => l_package_name
    , p_procedure_name => l_api_name
    , p_error_text     => 'Failed to raise business event');
END raise_event;

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
) IS

l_org_id            NUMBER;
l_user_id           NUMBER;
l_resp_id           NUMBER;
l_resp_appl_id      NUMBER;

l_param_list        PO_EVENT_PARAMS_TYPE; --<R12 OTM INTEGRATION>

BEGIN
    -- Get the db session context
    l_org_id       := PO_MOAC_UTILS_PVT.get_current_org_id ;  --<R12 MOAC>
    l_user_id      := fnd_profile.value( NAME => 'USER_ID');
    l_resp_id      := fnd_profile.value( NAME => 'RESP_ID');
    l_resp_appl_id := fnd_profile.value( NAME => 'RESP_APPL_ID');

    --<R12 OTM INTEGRATION START> Modified this procedure to call the more generic signature.

    -- construct parameter list
    l_param_list := PO_EVENT_PARAMS_TYPE.new_instance();

    l_param_list.add_param (
      p_param_name  => 'org_id'
    , p_param_value => l_org_id);

    l_param_list.add_param (
      p_param_name  => 'user_id'
    , p_param_value => l_user_id);

    l_param_list.add_param (
      p_param_name  => 'resp_id'
    , p_param_value => l_resp_id);

    l_param_list.add_param (
      p_param_name  => 'resp_appl_id'
    , p_param_value => l_resp_appl_id);

    l_param_list.add_param (
      p_param_name  => 'entity_name'
    , p_param_value => p_entity_name);

    l_param_list.add_param (
      p_param_name  => 'entity_id'
    , p_param_value => p_entity_id);

    -- raise event
    PO_BUSINESSEVENT_PVT.raise_event (
      p_api_version    => p_api_version
    , p_event_name     => p_event_name
    , p_param_list     => l_param_list
    , p_deferred       => FALSE
    , x_return_status  => x_return_status);

    --<R12 OTM INTEGRATION END>

END raise_event;

END PO_BUSINESSEVENT_PVT;

/
