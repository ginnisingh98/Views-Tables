--------------------------------------------------------
--  DDL for Package Body PO_OTM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_OTM_INTEGRATION_GRP" AS
/* $Header: POXGOTMB.pls 120.0.12000000.1 2007/03/27 21:53:13 dedelgad noship $ */

-- Debugging booleans used to bypass logging when turned off
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- Logging constants
g_pkg_name CONSTANT VARCHAR2(30) := 'PO_OTM_INTEGRATION_GRP';
g_module_prefix CONSTANT VARCHAR2(100) := 'po.plsql.' || g_pkg_name || '.';

PROCEDURE is_inbound_logistics_enabled (
  p_api_version            IN NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
, x_logistics_enabled_flag OUT NOCOPY VARCHAR2
)
IS

l_api_name     CONSTANT VARCHAR2(30) := 'IS_INBOUND_LOGISTICS_ENABLED';
l_api_version  CONSTANT NUMBER := 1.0;

d_progress     VARCHAR2(3);
d_module       CONSTANT VARCHAR2(100) := g_module_prefix || l_api_name;

BEGIN

  d_progress := '000';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, d_progress, 'p_api_version', p_api_version);
  END IF;

  d_progress := '010';

  x_return_status := FND_API.g_ret_sts_success;

  -- Standard call to check for call compatibility.
  IF (NOT FND_API.compatible_api_call (
            p_current_version_number => l_api_version
          , p_caller_version_number  => p_api_version
          , p_api_name               => l_api_name
          , p_pkg_name               => g_pkg_name))
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  d_progress := '020';

  -- Check Inbound Logistics status
  IF (PO_OTM_INTEGRATION_PVT.is_inbound_logistics_enabled()) THEN
    d_progress := '100';
    x_logistics_enabled_flag := 'Y';
  ELSE
    d_progress := '150';
    x_logistics_enabled_flag := 'N';
  END IF;

  d_progress := '200';

  IF (g_debug_stmt) THEN
    PO_DEBUG.debug_var(d_module, d_progress, 'x_return_status', x_return_status);
    PO_DEBUG.debug_var(d_module, d_progress, 'x_logistics_enabled_flag', x_logistics_enabled_flag);
    PO_DEBUG.debug_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (g_debug_unexp) THEN
      PO_DEBUG.debug_unexp(d_module, d_progress, 'Exception occurred');
    END IF;

END is_inbound_logistics_enabled;


END;

/
