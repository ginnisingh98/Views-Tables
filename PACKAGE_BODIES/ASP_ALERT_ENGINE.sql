--------------------------------------------------------
--  DDL for Package Body ASP_ALERT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_ALERT_ENGINE" as
/* $Header: aspaengb.pls 120.4 2006/01/18 14:00 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERT_ENGINE
---------------------------------------------------------------------------
-- Description:
--   Core Alert Engine Package for Sales Alerts Backend Workflow Processing.
--   This package is used by the workflow activity nodes.
--
-- Procedures:
--   (see the specification for details)
--
-- History:
--   08-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             Private Constants
 *-------------------------------------------------------------------------*/
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASP_ALERT_ENGINE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'aspaengb.pls';
G_MODULE    CONSTANT VARCHAR2(250) := 'asp.plsql.'||G_PKG_NAME||'.';

G_ORDER_ENTITY CONSTANT VARCHAR2(30) := 'ORDER';
G_SVCCONTRACT_ENTITY CONSTANT VARCHAR2(30) := 'SERVICE_CONTRACT';
G_INVOICE_ENTITY CONSTANT VARCHAR2(30) := 'INVOICE';
G_SERVICE_ENTITY CONSTANT VARCHAR2(30) := 'SERVICE_REQUEST';

G_ORDER_ALERT_AGENT CONSTANT VARCHAR2(30) := 'ORDER_ALERT_AGENT';
G_SVCCONTRACT_ALERT_AGENT CONSTANT VARCHAR2(30) := 'SVCCONTRACT_ALERT_AGENT';
G_INVOICE_ALERT_AGENT CONSTANT VARCHAR2(30) := 'INVOICE_ALERT_AGENT';
G_SERVICE_ALERT_AGENT CONSTANT VARCHAR2(30) := 'SERVICE_ALERT_AGENT';
G_CUSTOM_ALERT_AGENT CONSTANT VARCHAR2(30) := 'CUSTOM';

G_ORDER_CONTENT_PROVIDER CONSTANT VARCHAR2(30) := 'ORDER_CONTENT_PROVIDER';
G_SVCCONTRACT_CONTENT_PROVIDER CONSTANT VARCHAR2(30) := 'SVCCONTRACT_CONTENT_PROVIDER';
G_INVOICE_CONTENT_PROVIDER CONSTANT VARCHAR2(30) := 'INVOICE_CONTENT_PROVIDER';
G_SERVICE_CONTENT_PROVIDER CONSTANT VARCHAR2(30) := 'SERVICE_CONTENT_PROVIDER';
G_CUSTOM_CONTENT_PROVIDER CONSTANT VARCHAR2(30) := 'CUSTOM';

G_ASP_DELIVERY_AGENT CONSTANT VARCHAR2(30) := 'ASP_DELIVERY_AGENT';
G_CUSTOM_DELIVERY_AGENT CONSTANT VARCHAR2(30) := 'CUSTOM';



/*-------------------------------------------------------------------------*
 |                             Private Datatypes
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Variables
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Private Routines Specification
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             Public Routines
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
-- Procedure: Get_Alert_Agent
--   This is a factory method, which produces appropriate agents based on the
--   Alert Types.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Alert_Agent(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2)
IS
  l_event_entity varchar2(100);
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

BEGIN
  l_api_name := 'Get_Alert_Agent';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
    end if;
    If l_event_entity = G_ORDER_ENTITY Then
       resultout := G_ORDER_ALERT_AGENT;
    ElsIf l_event_entity = G_SVCCONTRACT_ENTITY Then
       resultout := G_SVCCONTRACT_ALERT_AGENT;
    ElsIf l_event_entity = G_INVOICE_ENTITY Then
       resultout := G_INVOICE_ALERT_AGENT;
    ElsIf l_event_entity = G_SERVICE_ENTITY Then
       resultout := G_SERVICE_ALERT_AGENT;
    Else
       resultout:= G_CUSTOM_ALERT_AGENT;
    End If;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'resultout '||resultout);
    end if;
    return;
  End If;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := '';
  return;

EXCEPTION
  When no_data_found Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':NO_DATA_FOUND:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

END Get_Alert_Agent;


--------------------------------------------------------------------------------
-- Procedure: Get_Content_Provider
--   This is a factory method, which produces appropriate providers based on the
--   Alert Types.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Content_Provider(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2)
IS
  l_event_entity varchar2(100);
  l_use_custom_content varchar2(10);
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);
BEGIN
  l_api_name := 'Get_Content_Provider';
  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;

  If(funcmode = 'RUN') Then
    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');

    begin
    l_use_custom_content := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                            itemkey =>itemkey,
                                            aname =>'USE_CUSTOM_CONTENT_AGENT');
    exception
    when others then
     l_use_custom_content := 'NO';
    end;

    If (l_event_entity = G_ORDER_ENTITY) AND (l_use_custom_content <> 'YES') Then
       resultout := G_ORDER_CONTENT_PROVIDER;
    ElsIf (l_event_entity = G_SVCCONTRACT_ENTITY) AND (l_use_custom_content <> 'YES') Then
       resultout := G_SVCCONTRACT_CONTENT_PROVIDER;
    ElsIf (l_event_entity = G_INVOICE_ENTITY) AND (l_use_custom_content <> 'YES') Then
       resultout := G_INVOICE_CONTENT_PROVIDER;
    ElsIf (l_event_entity = G_SERVICE_ENTITY) AND (l_use_custom_content <> 'YES') Then
       resultout := G_SERVICE_CONTENT_PROVIDER;
    Else
       resultout:= G_CUSTOM_CONTENT_PROVIDER;
    End If;
    return;
  End If;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := '';
  return;

EXCEPTION
  When no_data_found Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':NO_DATA_FOUND:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

END Get_Content_Provider;


--------------------------------------------------------------------------------
-- Procedure: Get_Alert_Agent
--   This is a factory method, which produces appropriate agents based on the
--   Alert Types.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Delivery_Agent(
  itemtype  in VARCHAR2,
  itemkey   in VARCHAR2,
  actid     in NUMBER,
  funcmode  in VARCHAR2,
  resultout in out NOCOPY VARCHAR2)
IS
  l_event_entity varchar2(100);
  l_use_custom_delivery varchar2(10);
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);
  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

BEGIN
  l_api_name := 'Get_Delivery_Agent';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  If(funcmode = 'RUN') Then
    l_event_entity := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                                itemkey =>itemkey,
                                                aname =>'ALERT_SOURCE_OBJECT_CODE');
    begin
    l_use_custom_delivery := wf_engine.GetItemAttrText( itemtype =>itemtype,
                                            itemkey =>itemkey,
                                            aname =>'USE_CUSTOM_DELIVERY_AGENT');
    exception
    when others then
     l_use_custom_delivery := 'NO';
    end;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_event_entity '||l_event_entity);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_use_custom_delivery '||l_use_custom_delivery);
    end if;

    If(
       l_event_entity in (G_ORDER_ENTITY, G_SVCCONTRACT_ENTITY, G_INVOICE_ENTITY, G_SERVICE_ENTITY,'CUSTOM')
       AND (l_use_custom_delivery <> 'YES')
      ) Then
       resultout := G_ASP_DELIVERY_AGENT;
    Else
       resultout:= G_CUSTOM_DELIVERY_AGENT;
    End If;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'resultout '||resultout);
    end if;
    return;
  End If;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  resultout := '';
  return;

EXCEPTION
  When no_data_found Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':NO_DATA_FOUND:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

  When others Then
    wf_core.context(G_PKG_NAME, l_api_name, itemtype, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');

END Get_Delivery_Agent;


PROCEDURE NOOP(itemtype   in varchar2,
               itemkey    in varchar2,
               actid      in number,
               funcmode   in varchar2,
               resultout  in out nocopy varchar2)
IS
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);
  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

BEGIN
  l_api_name := 'NOOP';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;

  resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;
EXCEPTION
  When others Then
    Wf_Core.Context(G_PKG_NAME, 'Noop', l_api_name, itemkey, to_char(actid), funcmode);
    l_debug_msg := l_qualified_api_name||':OTHERS:'||to_char(SQLCODE)||':'||substr(SQLERRM,1,500);
    wf_core.token('ORA_ERROR',l_debug_msg);
    wf_core.raise('WF_ORA');
END NOOP;

------------------------------------------------------------------------------
-- Alerts_Selector
--   This procedure sets up the responsibility and organization context for
--   multi-org sensitive code.
------------------------------------------------------------------------------

PROCEDURE Alerts_Selector(
  itemtype      IN      VARCHAR2,
  itemkey       IN      VARCHAR2,
  actid         IN      NUMBER,
  funcmode      IN      VARCHAR2,
  resultout     OUT     NOCOPY VARCHAR2)
IS
  l_user_id             NUMBER;
  l_resp_id             NUMBER;
  l_resp_appl_id        NUMBER;
  l_api_name varchar2(100);
  l_qualified_api_name varchar2(200);
  l_debug_msg varchar2(1000);

  l_debug_runtime number;
  l_debug_exception number;
  l_debug_procedure number;
  l_debug_statment number;

BEGIN
  l_api_name := 'Alerts_Selector';
  l_debug_runtime := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_debug_exception := FND_LOG.LEVEL_EXCEPTION;
  l_debug_procedure := FND_LOG.LEVEL_PROCEDURE;
  l_debug_statment := FND_LOG.LEVEL_STATEMENT;

  l_qualified_api_name := G_PKG_NAME||'.'||l_api_name;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'Entered '||G_PKG_NAME||'.'||l_api_name);
  end if;
  if(l_debug_procedure >= l_debug_runtime) then
    fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'funcmode '||funcmode);
  end if;

  IF (funcmode = 'RUN') THEN
    resultout := 'COMPLETE';

  -- Engine calls SET_CTX just before activity execution
  ELSIF (funcmode = 'SET_CTX') THEN

    -- First get the user id, resp id, and appl id
    l_user_id := WF_ENGINE.GetItemAttrNumber
                   ( itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'USER_ID'
                   );

    l_resp_id := WF_ENGINE.GetItemAttrNumber
                   ( itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'RESPONSIBILITY_ID'
                   );
    l_resp_appl_id := WF_ENGINE.GetItemAttrNumber
                        ( itemtype      => itemtype,
                          itemkey       => itemkey,
                          aname         => 'APPLICATION_ID'
                        );

    -- Set the database session context
    begin
     if( l_user_id is not null and  l_resp_id is not null  and l_resp_appl_id is not null) then
       FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
      if(l_debug_procedure >= l_debug_runtime) then
        fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'FND_GLOBAL.Apps_Initialize called ');
      end if;

     end if;
    exception
    when others then
     null;
    end;
    if(l_debug_procedure >= l_debug_runtime) then
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_user_id '||l_user_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_resp_id '||l_resp_id);
      fnd_log.string(l_debug_procedure, G_MODULE||l_api_name, 'l_resp_appl_id '||l_resp_appl_id);
    end if;

    MO_GLOBAL.set_policy_context ('A', null);

    resultout := 'COMPLETE';

  -- Notification Viewer form calls TEST_CTX just before launching a form
  ELSIF (funcmode = 'TEST_CTX') THEN
    resultout := 'COMPLETE';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.Context('ASP_ALERT_ENGINE', 'Alerts_Selector',
                    itemtype, itemkey, actid, funcmode);
    RAISE;
END Alerts_Selector;



END ASP_ALERT_ENGINE;

/
