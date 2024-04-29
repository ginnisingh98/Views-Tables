--------------------------------------------------------
--  DDL for Package Body XNP_WF_TIMERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_WF_TIMERS" AS
/* $Header: XNPWFTMB.pls 120.1 2005/06/17 03:42:34 appldev  $ */

PROCEDURE FireDefaultJeopardyTimer ( itemtype IN VARCHAR2
                                    ,itemkey IN VARCHAR2 );
PROCEDURE fire
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 l_fa_instance_id NUMBER;
 l_order_id NUMBER;
 l_reference_id NUMBER;
 l_timer_code VARCHAR2(80);
 l_callback_ref_id VARCHAR2(1024);
 l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 e_FIRE	EXCEPTION;
BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

     BEGIN
     l_fa_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_fa_instance_id := 0;
	l_fa_instance_id := NULL;
     END;

    BEGIN
    l_order_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );
    EXCEPTION
    WHEN OTHERS THEN
        wf_core.clear;
--	l_order_id := 0;
	l_order_id := NULL;
    END;

    -- Get the event type to publish
    l_timer_code :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid	=> actid
      ,aname   => 'TIMER_NAME'
      );

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    XNP_TIMER_STANDARD.FIRE
     (p_order_id => l_order_id
     ,p_workitem_instance_id => l_workitem_instance_id
     ,p_fa_instance_id => l_fa_instance_id
     ,p_timer_code => l_timer_code
     ,p_callback_ref_id => l_callback_ref_id
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
     );

  	IF l_error_code <> 0
	THEN
		raise e_FIRE;
	END IF;

  -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    RETURN;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */

     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.FIRE');

     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'FIRE'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);
    RAISE;

END FIRE;

PROCEDURE get_timer_status
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_reference_id VARCHAR2(80);
 l_timer_code VARCHAR2(20);
 l_status VARCHAR2(20);
 l_callback_ref_id VARCHAR2(1024);
 l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
 l_timer_id NUMBER := NULL;
 l_workitem_instance_id NUMBER;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 e_GET_TIMER_STATUS	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

    -- Get the event type to publish
    l_timer_code :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'TIMER_NAME'
      );

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    XNP_TIMER_STANDARD.GET_TIMER_STATUS
    (p_reference_id => l_callback_ref_id
     ,p_timer_message_code => l_timer_code
     ,x_timer_id => l_timer_id
     ,x_status => l_status
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
     );

	-- If Timer is not found, it can be interpreted as
	-- it is INACTIVE. Specifically in case of Timers with
	-- delay, it is more appropriate to call such timers
	-- to be INACTIVE rather than giving NOT FOUND ERROR.
	-- Bug # 1552348

	IF l_error_code = xnp_errors.g_timer_not_found THEN
		resultout := 'COMPLETE:' || 'INACTIVE';
		return;
	END IF;

	-- Changed till this point.

    IF l_error_code <> 0
    THEN
       RAISE e_GET_TIMER_STATUS;
    END IF;
    -- Completion
    resultout := 'COMPLETE:' || l_status;
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.GET_TIMER_STATUS');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_STANDARD'
        , 'GET_TIMER_STATUS'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);
      RAISE;

END get_timer_status;

PROCEDURE start_related_timers
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_message_code VARCHAR2(20);
 l_callback_ref_id VARCHAR2(1024);
 l_tmp_callback_ref_id VARCHAR2(2000) := NULL;
 l_order_id NUMBER;
 l_workitem_instance_id NUMBER;
 l_fa_instance_id NUMBER;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 e_START_RELATED_TIMERS	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

    BEGIN
    l_fa_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'FA_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_fa_instance_id := 0;
	l_fa_instance_id := NULL;
     END;

    BEGIN
    l_order_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_order_id := 0;
	l_order_id := NULL;
     END;

    -- Get the event type to publish
    l_message_code :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'MESSAGE_CODE'
      );

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    XNP_TIMER_STANDARD.START_RELATED_TIMERS
    (
	p_message_code => l_message_code
	,p_callback_ref_id => l_callback_ref_id
	,x_error_code => l_error_code
	,x_error_message => l_error_message
	,p_order_id => l_order_id
	,p_workitem_instance_id => l_workitem_instance_id
	,p_fa_instance_id => l_fa_instance_id
     );

    IF l_error_code <> 0
    THEN
	raise e_START_RELATED_TIMERS;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.START_RELATED_TIMERS');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'START_RELATED_TIMERS'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END start_related_timers;

PROCEDURE restart_all
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_callback_ref_id VARCHAR2(1024);
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 e_RESTART_ALL	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

    -- Get the event type to publish

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    XNP_TIMER_STANDARD.RESTART_ALL
    (
     p_reference_id => l_callback_ref_id
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
     );

    IF l_error_code <> 0
    THEN
	raise e_RESTART_ALL;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.RESTART_ALL');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'RESTART_ALL'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END restart_all;

PROCEDURE recalculate_all
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_callback_ref_id VARCHAR2(1024);
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 e_RECALCULATE_ALL	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

    -- Get the event type to publish

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    XNP_TIMER_STANDARD.RECALCULATE_ALL
    (
     p_reference_id => l_callback_ref_id
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
    );

    IF l_error_code <> 0
    THEN
	raise e_RECALCULATE_ALL;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.RECALCULATE_ALL');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'RECALCULATE_ALL'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END recalculate_all;

PROCEDURE remove
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_callback_ref_id VARCHAR2(1024);
 l_timer_code VARCHAR2(1024);
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 e_REMOVE	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    -- The run code
    BEGIN
    l_workitem_instance_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'WORKITEM_INSTANCE_ID'
      );
     EXCEPTION
     WHEN OTHERS THEN
        wf_core.clear;
--	l_workitem_instance_id := 0;
	l_workitem_instance_id := NULL;
     END;

    -- Get the event type to publish

    -- Get the callback reference id
    XNP_UTILS.CHECK_TO_GET_REF_ID
    (p_itemtype       => itemtype
    ,p_itemkey        => itemkey
    ,p_actid          => actid
    ,p_workitem_instance_id => l_workitem_instance_id
    ,x_reference_id  => l_callback_ref_id
    );

    l_timer_code :=
     wf_engine.GetActivityAttrText
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,actid => actid
      ,aname   => 'TIMER_NAME'
      );

    XNP_TIMER_STANDARD.REMOVE
    (
     p_reference_id => l_callback_ref_id
     ,p_timer_message_code => l_timer_code
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
    );

    IF l_error_code <> 0
    THEN
	raise e_REMOVE;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null


  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.REMOVE');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'REMOVE'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END remove;

PROCEDURE deregister
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_order_id	NUMBER;
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 e_DEREGISTER	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    l_order_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    -- The run code

    -- Get the event type to publish

    XNP_TIMER_STANDARD.DEREGISTER
    (
     p_order_id => l_order_id
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
    );

    IF l_error_code <> 0
    THEN
	raise e_DEREGISTER;
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.DEREGISTER');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'DEREGISTER'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END deregister;

-----------------------------------------------------------------------
----- API Name   : Get Jeopardy Flag
----- Type       : Public
----- Purpose    : Retrieves the jeopardy flag for the given order id
----- Parameters : ITEMTYPE
-----              ITEMKEY
-----              ACTID
-----              FUNCMODE
-----              RESULTOUT
------------------------------------------------------------------------
PROCEDURE GET_JEOPARDY_FLAG
 (ITEMTYPE IN VARCHAR2
 ,ITEMKEY IN VARCHAR2
 ,ACTID IN NUMBER
 ,FUNCMODE IN VARCHAR2
 ,RESULTOUT OUT NOCOPY VARCHAR2
 )
IS
 x_progress VARCHAR2(2000);
 l_order_id	NUMBER;
 l_flag		VARCHAR2(1);
 l_error_code NUMBER := 0;
 l_error_message VARCHAR2(2000);
 l_workitem_instance_id NUMBER;
 e_get_jeopardy_flag	EXCEPTION;

BEGIN

  --
  -- RUN mode - normal process execution
  --

  IF (funcmode = 'RUN') THEN

    l_order_id :=
      wf_engine.GetItemAttrNumber
      (itemtype => itemtype
      ,itemkey  => itemkey
      ,aname   => 'ORDER_ID'
      );

    -- The run code

    -- Get the event type to publish

    XNP_TIMER_STANDARD.get_jeopardy_flag
    (
     p_order_id => l_order_id
     ,x_flag => l_flag
     ,x_error_code => l_error_code
     ,x_error_message => l_error_message
    );

    IF l_error_code <> 0
    THEN
	raise e_get_jeopardy_flag;
    END IF;

    IF( l_flag = 'Y' ) THEN
      FireDefaultJeopardyTimer( GET_JEOPARDY_FLAG.ITEMTYPE,
                                GET_JEOPARDY_FLAG.ITEMKEY );
    END IF;

    -- Completion
    resultout := 'COMPLETE';
    return;

  END IF;
  --
  -- CANCEL mode
  --
  -- This is in the event that the activity must be undone.
  --
  IF (funcmode = 'CANCEL' ) THEN
    -- The cancel code

    null;
    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

  -- For other execution modes: return null

  resultout := '';
  return;

  EXCEPTION
    WHEN OTHERS THEN
    /* Record this function call in the error
     * system in case of an exception
     */
     fnd_message.set_name('XNP','STD_ERROR');
     fnd_message.set_token(
       'ERROR_LOCN','XNP_WF_TIMERS.GET_JEOPARDY_FLAG');
     if(l_error_code <> 0) then
		fnd_message.set_token('ERROR_TEXT',
       ':'||to_char(l_error_code)||':'||l_error_message);
     else
       fnd_message.set_token('ERROR_TEXT',
         ':'||to_char(SQLCODE)||':'||SQLERRM);
     end if;
     x_progress := fnd_message.get;
     wf_core.context(
        'XNP_WF_TIMERS'
        , 'GET_JEOPARDY_FLAG'
        , itemtype
        , itemkey
        , to_char(actid)
        , funcmode
        , x_progress);

      RAISE;

END GET_JEOPARDY_FLAG;

PROCEDURE FireDefaultJeopardyTimer ( itemtype IN VARCHAR2
                                    ,itemkey IN VARCHAR2 )
IS
  l_timer_id   NUMBER;
  l_timer_contents   VARCHAR2(200);
  l_error_code NUMBER;
  l_error_message VARCHAR2(200);
  p_sender_name VARCHAR2(200);
  p_recipient_list VARCHAR2(200);
  p_version NUMBER;
  l_reference_id VARCHAR2(200);
  l_opp_reference_id VARCHAR2(200);
  l_order_id NUMBER;
  p_wi_instance_id NUMBER;
  p_fa_instance_id  NUMBER;

  timerException exception;
BEGIN

  l_order_id := wf_engine.GetItemAttrNumber(itemtype => FireDefaultJeopardyTimer.itemtype,
                                          itemkey => FireDefaultJeopardyTimer.itemkey,
                                          aname => 'ORDER_ID');

  l_reference_id := to_char( l_order_id );
  l_opp_reference_id := l_reference_id;

  XNP_T_DEF_JEOPARDY_TMR_U.FIRE( x_timer_id => l_timer_id,
                                 x_timer_contents => l_timer_contents,
				 x_error_code => l_error_code,
                                 x_error_message => l_error_message,
				 p_reference_id => l_reference_id,
				 p_opp_reference_id => l_opp_reference_id,
				 p_order_id => l_order_id);

  IF( l_error_code <> 0 ) THEN
     raise timerException;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
     wf_core.context(  'XNP_WF_TIMERS'  , 'FireDefaultJeopardyTimer'  , itemtype  , itemkey, l_error_message );

END FireDefaultJeopardyTimer;

END XNP_WF_TIMERS;

/
