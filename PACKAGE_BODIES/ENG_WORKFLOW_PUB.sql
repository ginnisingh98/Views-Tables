--------------------------------------------------------
--  DDL for Package Body ENG_WORKFLOW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_WORKFLOW_PUB" AS
/* $Header: ENGBWKFB.pls 120.7 2006/04/11 18:00:48 mkimizuk noship $ */


-- PROCEDURE CHECK_HEADER_OR_LINE
PROCEDURE CHECK_HEADER_OR_LINE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY  varchar2)
IS

    l_change_id      NUMBER ;
    l_change_line_id NUMBER ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    -- Get Chagne Line Id
    Eng_Workflow_Util.GetChangeLineObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_line_id => l_change_line_id
    ) ;


    IF  NVL(l_change_line_id,0) > 0 THEN

        -- set result
        result  := 'COMPLETE:N';
        return;

    ELSIF  NVL(l_change_id,0) > 0 AND NVL(l_change_line_id,0) <= 0  THEN

        -- set result
        result  := 'COMPLETE:Y';
        return;


    ELSIF NVL(l_change_id,0)  <= 0 AND NVL(l_change_line_id,0) <= 0 THEN
        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_HEADER_OR_LINE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_HEADER_OR_LINE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_HEADER_OR_LINE ;



-- PROCEDURE SELECT_ADHOC_PARTY
PROCEDURE SELECT_ADHOC_PARTY(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_action_id           NUMBER ;
    l_adhoc_party_list    VARCHAR2(2000) ;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


    CURSOR c_action_attr ( p_action_id  NUMBER )
    IS
        SELECT  party_id_list adhoc_party_list
              , TRUNC(response_by_date)            response_by_date
              , sysdate
        FROM    ENG_CHANGE_ACTIONS
        WHERE  action_id = p_action_id ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Adhoc Party List
    l_adhoc_party_list := WF_ENGINE.GetItemAttrText( itemtype
                                                   , itemkey
                                                   , 'ADHOC_PARTY_LIST');

    IF l_adhoc_party_list IS NULL THEN

        -- Get Action Id
        Eng_Workflow_Util.GetActionId
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_action_id         => l_action_id
        ) ;


       -- Get party list from action table
       FOR i IN c_action_attr (p_action_id => l_action_id )
       LOOP

          l_adhoc_party_list := i.adhoc_party_list ;

          WF_ENGINE.SetItemAttrText( itemtype
                                   , itemkey
                                   , 'ADHOC_PARTY_LIST'
                                   , l_adhoc_party_list );


       END LOOP ;

    END IF ;


    IF l_adhoc_party_list IS NULL THEN
          result  := 'COMPLETE:NONE';
          return;
    END IF ;

    -- Set Adhoc Party Role
    Eng_Workflow_Util.SetAdhocPartyRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_adhoc_party_list  => l_adhoc_party_list
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ADHOC_PARTY',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ADHOC_PARTY',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_ADHOC_PARTY ;



PROCEDURE SELECT_ASSIGNEE (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;
    l_debug_filename  VARCHAR2(30) ;  -- 'SelectAssignee.log' ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;


    -- Set Adhoc Party Role
    Eng_Workflow_Util.SetAssigneeRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ASSIGNEE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ASSIGNEE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_ASSIGNEE ;


-- PROCEDURE SELECT_STD_REVIEWERS
PROCEDURE SELECT_STD_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Set Reviewers Role
    Eng_Workflow_Util.SetReviewersRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_reviewer_type     => 'STD'
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STD_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STD_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_STD_REVIEWERS;


-- PROCEDURE SELECT_REVIEWERS
PROCEDURE SELECT_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Set Reviewers Role
    Eng_Workflow_Util.SetReviewersRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_reviewer_type     => 'NO_ASSIGNEE'
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_REVIEWERS;


PROCEDURE SELECT_LINE_ASSIGNEE (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_debug_flag      BOOLEAN      := FALSE ;  -- For Debug: TRUE;
    l_output_dir      VARCHAR2(80) ;
    l_debug_filename  VARCHAR2(30) ;  -- 'SelectLineAssignee.log' ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;

    -- Set Adhoc Party Role
    Eng_Workflow_Util.SetLineAssigneeRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_LINE_ASSIGNEE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_LINE_ASSIGNEE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_LINE_ASSIGNEE ;


-- PROCEDURE SELECT_STD_LINE_REVIEWERS
PROCEDURE SELECT_STD_LINE_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_debug_flag      BOOLEAN      := FALSE ;
    l_output_dir      VARCHAR2(80) ;
    l_debug_filename  VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN

   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;

    -- Set Reviewers Role
    Eng_Workflow_Util.SetLineReviewersRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_reviewer_type     => 'STD'
    ) ;



    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;


        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;


        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STD_LINE_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STD_LINE_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_STD_LINE_REVIEWERS;


-- PROCEDURE SELECT_LINE_REVIEWERS
PROCEDURE SELECT_LINE_REVIEWERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Set Reviewers Role
    Eng_Workflow_Util.SetLineReviewersRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_reviewer_type     => 'NO_ASSIGNEE'
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_LINE_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_LINE_REVIEWERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_LINE_REVIEWERS;

-- INITIATE_LINES
PROCEDURE INITIATE_LINES(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_change_id           NUMBER ;
    l_wf_user_id          NUMBER ;
    l_host_url            VARCHAR2(256) ;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;

    -- Get Host URL
    Eng_Workflow_Util.GetHostURL
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_host_url          => l_host_url
    ) ;

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;



    -- Start Change Lines Initiate Change Workflows
    -- ENGCLACT:INITIATE_CHANGE
    Eng_Workflow_Util.StartAllLineWorkflows
    (   x_return_status     => l_return_status
     ,  x_msg_count         => l_msg_count
     ,  x_msg_data          => l_msg_data
     ,  p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  p_change_id         => l_change_id
     ,  p_wf_user_id        => l_wf_user_id
     ,  p_host_url          => l_host_url
     ,  p_line_item_type    => Eng_Workflow_Util.G_CHANGE_LINE_ACTION_ITEM_TYPE
     ,  p_line_process_name => Eng_Workflow_Util.G_CL_INITIATE_CHANGE_PROC
    ) ;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;

  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'INITIATE_LINES',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'INITIATE_LINES',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END INITIATE_LINES;


-- PROCEDURE SELECT_ROUTE_PEOPLE
PROCEDURE SELECT_ROUTE_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Set Adhoc Party Role
    Eng_Workflow_Util.SetRoutePeopleRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ROUTE_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_ROUTE_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_ROUTE_PEOPLE ;


-- PROCEDURE SELECT_STEP_PEOPLE
PROCEDURE SELECT_STEP_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Set Adhoc Party Role
    Eng_Workflow_Util.SetStepPeopleRole
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        -- set result
        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STEP_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SELECT_STEP_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SELECT_STEP_PEOPLE;



PROCEDURE DELETE_ADHOC_ROLES_AND_USERS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Delete Workflow Adhoc Role and Local Users
    Eng_Workflow_Util.DeleteAdhocRolesAndUsers
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'DELETE_ADHOC_ROLES_AND_USERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'DELETE_ADHOC_ROLES_AND_USERS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END DELETE_ADHOC_ROLES_AND_USERS ;


PROCEDURE SET_REQUEST_OPTIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_action_id           NUMBER ;
    l_timeout_min         NUMBER ;
    l_response_by_date    DATE ;

    CURSOR c_action_attr ( p_action_id  NUMBER )
    IS
        SELECT TRUNC(response_by_date)            response_by_date
        FROM    ENG_CHANGE_ACTIONS
        WHERE   action_id = p_action_id ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Response Timeout Min
    Eng_Workflow_Util.GetNtfResponseTimeOut
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  x_timeout_min       => l_timeout_min
    ) ;

    IF l_timeout_min IS NULL
    THEN
        -- Get Action Id
        Eng_Workflow_Util.GetActionId
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_action_id         => l_action_id
        ) ;

        -- Get Response By Date from action table
        FOR i IN c_action_attr (p_action_id => l_action_id )
        LOOP

            l_response_by_date := i.response_by_date ;

        END LOOP ;

        -- 115.10
        -- The Response By Date is still null for Reqeust Comment Action
        -- This call is just for fugure reference
        -- Set Response Timeout Min
        Eng_Workflow_Util.SetNtfResponseTimeOut
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  p_response_by_date  => l_response_by_date
        ) ;


    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_REQUEST_OPTIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_REQUEST_OPTIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


END SET_REQUEST_OPTIONS ;


PROCEDURE SET_STEP_ACT_OPTIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_route_step_id          NUMBER ;
    l_timeout_min            NUMBER ;
    l_required_relative_days NUMBER ;
    l_response_by_date       DATE ;
    l_condition_type_code    VARCHAR2(30) ;

    CURSOR c_step_act( p_step_id  NUMBER )
    IS
        SELECT  TRUNC(required_date)   response_by_date
              , condition_type_code
              , required_relative_days required_relative_days
        FROM    ENG_CHANGE_ROUTE_STEPS
        WHERE   step_id = p_step_id ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

     -- Get Route Step Id
     Eng_Workflow_Util.GetRouteStepId
     (   p_item_type         => itemtype
      ,  p_item_key          => itemkey
      ,  x_route_step_id     => l_route_step_id
     ) ;

     -- Get Step Activity Options
     FOR i IN c_step_act (p_step_id => l_route_step_id )
     LOOP

         l_response_by_date       := i.response_by_date ;
         l_condition_type_code    := i.condition_type_code ;
         l_required_relative_days := i.required_relative_days ;

     END LOOP ;

     -- Set Step Action Voting Option based on step condition type
     -- code
     Eng_Workflow_Util.SetStepActVotingOption
     (   p_item_type           => itemtype
      ,  p_item_key            => itemkey
      ,  p_condition_type_code => l_condition_type_code
     ) ;

     -- Get Response Timeout Min
     Eng_Workflow_Util.GetNtfResponseTimeOut
     (   p_item_type         => itemtype
      ,  p_item_key          => itemkey
      ,  x_timeout_min       => l_timeout_min
     ) ;


    IF l_timeout_min IS NULL
    THEN
        --
        -- Comment out for reminder notification
        -- We disabled time out functionality
        --
        -- Set Response Timeout Min
        -- Eng_Workflow_Util.SetNtfResponseTimeOut
        -- (   p_item_type         => itemtype
        -- ,  p_item_key          => itemkey
        -- ,  p_response_by_date  => l_response_by_date
        -- ) ;
        --

        -- Use the number of days to set Response TimeOut
        -- Set Response Timeout Min
        Eng_Workflow_Util.SetNtfResponseTimeOut
        (  p_item_type         => itemtype
        ,  p_item_key          => itemkey
        ,  p_required_relative_days => l_required_relative_days
        ) ;



    END IF ;




  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_STEP_ACT_OPTIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_STEP_ACT_OPTIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


END SET_STEP_ACT_OPTIONS ;



PROCEDURE RESPOND_TO_COMMENT_REQUEST (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_action_id           NUMBER ;
    l_timeout_min         NUMBER ;
    l_response_code       VARCHAR2(30) ;
    l_response_by_date    DATE ;
    l_sysdate             DATE ;

    l_created_action_id   NUMBER ;
    l_child_item_type     VARCHAR2(8) ;
    l_child_item_key      VARCHAR2(240) ;


    CURSOR c_action_attr ( p_action_id  NUMBER )
    IS
        SELECT TRUNC(response_by_date)            response_by_date
              , sysdate
        FROM    ENG_CHANGE_ACTIONS
        WHERE   action_id = p_action_id ;


    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;
    l_debug_filename  VARCHAR2(30) ;



BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , 'RUN:RESPOND_TO_COMMENT_REQUEST-' || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;


    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN


  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;



    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    -- Record Action
    Eng_Workflow_Util.CreateAction
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_action_type           =>  Eng_Workflow_Util.G_ACT_REPLIED
    , x_action_id             =>  l_created_action_id
    , p_raise_event_flag      =>  FND_API.G_TRUE -- R12
    ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.CreateAction: Return: ' ||  l_return_status  ) ;
END IF ;


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;



   -- Send Reponse FYI notification to original requestor of
   -- the comment request from Response FYI process
   Eng_Workflow_Util.START_RESPONSE_FYI_PROCESS
    ( p_itemtype                => itemtype
    , p_itemkey                 => itemkey
    , p_orig_response_option    => NULL
    , p_responded_ntf_id        => WF_ENGINE.context_nid
    , p_responded_comment_id    => l_created_action_id
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , x_return_status           => l_return_status
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if;


  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
     -- Future Enh
     NULL ;
  end if;



  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_COMMENT_REQUEST',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_COMMENT_REQUEST',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_COMMENT_REQUEST ;


PROCEDURE RESPOND_TO_ROUTE_APPROVAL_REQ (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;   -- := '/sqlcom/log/plm115d' ;
    l_debug_filename  VARCHAR2(30) ;     --  'ResToRouteAppr' ;



BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || '-' || funcmode || '-' || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;


    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('itemtype: ' || itemtype ) ;
   Eng_Workflow_Util.Write_Debug('itemkey: ' || itemkey ) ;
   Eng_Workflow_Util.Write_Debug('actid: ' || actid ) ;
   Eng_Workflow_Util.Write_Debug('funcmode: ' || funcmode ) ;
   Eng_Workflow_Util.Write_Debug('result: ' || result ) ;
END IF ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN

  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


-- Eng_Workflow_Util.Get_Debug_Mode
-- (itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
    Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                        , l_debug_filename || actid ) ;
END IF ;

    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    -- Record Route Response
    Eng_Workflow_Util.SetRouteResponse
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_response_code         =>  l_response_code
    , p_actid                 =>  actid
    , p_funcmode              =>  funcmode
    ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.SetRouteResponse: Return: ' ||  l_return_status  ) ;
END IF ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if;



  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
    Eng_Workflow_Util.reassignRoutePeople(  x_return_status         =>  l_return_status
                                          , x_msg_count             =>  l_msg_count
                                          , x_msg_data              =>  l_msg_data
                                          , p_item_type             =>  itemtype
                                          , p_item_key              =>  itemkey
                                          , p_notification_id       =>  WF_ENGINE.context_nid
                                          , p_reassign_mode         =>  funcmode);
    result := 'COMPLETE';
    return;

  end if;


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_APPROVAL_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_APPROVAL_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_APPROVAL_REQ ;



PROCEDURE RESPOND_TO_ROUTE_COMMENT_REQ (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : TRUE ;
    l_output_dir      VARCHAR2(80) ; -- '/appslog/bis_top/utl/plm115dv/log' ;
    l_debug_filename  VARCHAR2(30) ; -- 'RespRtComReq.log'



BEGIN


  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;

    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN


  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;



    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    -- Record Route Response
    Eng_Workflow_Util.SetRouteResponse
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_response_code         =>  Eng_Workflow_Util.G_RT_REPLIED
    , p_actid                 =>  actid
    , p_funcmode              =>  funcmode
    ) ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.SetRouteResponse: Return: ' ||  l_return_status  ) ;
END IF ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;


        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


/*
   -- Send Reponse FYI notification to original requestor of
   -- the comment request from Response FYI process
   Eng_Workflow_Util.START_RESPONSE_FYI_PROCESS
    ( p_itemtype                => itemtype
    , p_itemkey                 => itemkey
    , p_orig_response_option    => NULL
    , p_responded_ntf_id        => WF_ENGINE.context_nid
    , p_responded_comment_id    => l_created_action_id
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , x_return_status           => l_return_status
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;
*/

  end if;

  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
    Eng_Workflow_Util.reassignRoutePeople(  x_return_status         =>  l_return_status
                                          , x_msg_count             =>  l_msg_count
                                          , x_msg_data              =>  l_msg_data
                                          , p_item_type             =>  itemtype
                                          , p_item_key              =>  itemkey
                                          , p_notification_id       =>  WF_ENGINE.context_nid
                                          , p_reassign_mode         =>  funcmode);
    result := 'COMPLETE';
    return;

  end if;



  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_COMMENT_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_COMMENT_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_COMMENT_REQ ;


PROCEDURE RESPOND_TO_ROUTE_DEF_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;   -- := '/sqlcom/log/plm115d' ;
    l_debug_filename  VARCHAR2(30) ;     --  'ResToRouteDef' ;

    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;
    l_wf_user_id          NUMBER ;
    l_host_url            VARCHAR2(256) ;
    l_val_def_item_key    VARCHAR2(240) ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || '-' || funcmode || '-' || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;


    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('itemtype: ' || itemtype ) ;
   Eng_Workflow_Util.Write_Debug('itemkey: ' || itemkey ) ;
   Eng_Workflow_Util.Write_Debug('actid: ' || actid ) ;
   Eng_Workflow_Util.Write_Debug('funcmode: ' || funcmode ) ;
   Eng_Workflow_Util.Write_Debug('result: ' || result ) ;
END IF ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN

  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
    Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                        , l_debug_filename || actid ) ;
END IF ;

    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    -- Record Route Response
    Eng_Workflow_Util.SetRouteResponse
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_response_code         =>  l_response_code
    , p_actid                 =>  actid
    , p_funcmode              =>  funcmode
    ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.SetRouteResponse: Return: ' ||  l_return_status  ) ;
END IF ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


    -- Get Host URL
    Eng_Workflow_Util.GetHostURL
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_host_url          => l_host_url
    ) ;

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_route_id     => l_route_id
    ) ;

    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;


    --
    -- Decided not to start Validation Def process which
    -- is place folder for customization
    -- Starting a place folder def process with no validation
    -- per each response does not seem to be right
    -- Also we don't document this yet
    -- Start Workflow to validate definitions
    -- Eng_Workflow_Util.StartValidateDefProcess
    -- ( x_msg_count               => l_msg_count
    -- , x_msg_data                => l_msg_data
    -- , x_return_status           => l_return_status
    -- , x_val_def_item_key        => l_val_def_item_key
    -- , p_step_item_type          => itemtype
    --  , p_step_item_key           => itemkey
    -- , p_responded_ntf_id        => WF_ENGINE.context_nid
    -- , p_route_id                => l_route_id
    -- , p_route_step_id           => l_route_step_id
    -- , p_val_def_item_type       => Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
    -- , p_val_def_process_name    => Eng_Workflow_Util.G_VALIDATE_DEFINITION_PROC
    -- , p_host_url                => l_host_url
    -- , p_orig_response           => l_response_code
    -- ) ;
    --

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if;



  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
    Eng_Workflow_Util.reassignRoutePeople(  x_return_status         =>  l_return_status
                                          , x_msg_count             =>  l_msg_count
                                          , x_msg_data              =>  l_msg_data
                                          , p_item_type             =>  itemtype
                                          , p_item_key              =>  itemkey
                                          , p_notification_id       =>  WF_ENGINE.context_nid
                                          , p_reassign_mode         =>  funcmode);
    result := 'COMPLETE';
    return;

  end if;

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;



EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_DEF_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_DEF_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_DEF_REQ ;


PROCEDURE RESPOND_TO_ROUTE_DEF_APPR_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;   -- := '/sqlcom/log/plm115d' ;
    l_debug_filename  VARCHAR2(30) ;     --  'ResToRouteDefAppr' ;


    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;
    l_wf_user_id          NUMBER ;
    l_host_url            VARCHAR2(256) ;
    l_val_def_item_key    VARCHAR2(240) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || '-' || funcmode || '-' || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;


    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('itemtype: ' || itemtype ) ;
   Eng_Workflow_Util.Write_Debug('itemkey: ' || itemkey ) ;
   Eng_Workflow_Util.Write_Debug('actid: ' || actid ) ;
   Eng_Workflow_Util.Write_Debug('funcmode: ' || funcmode ) ;
   Eng_Workflow_Util.Write_Debug('result: ' || result ) ;
END IF ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN

  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
    Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                        , l_debug_filename || actid ) ;
END IF ;

    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    -- Record Route Response
    Eng_Workflow_Util.SetRouteResponse
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_response_code         =>  l_response_code
    , p_actid                 =>  actid
    , p_funcmode              =>  funcmode
    ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.SetRouteResponse: Return: ' ||  l_return_status  ) ;
END IF ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


    -- Need to call validation workflow only in case that response is Approved
    IF l_response_code = Eng_Workflow_Util.G_RT_APPROVED
    THEN


        -- Get Host URL
        Eng_Workflow_Util.GetHostURL
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_host_url          => l_host_url
        ) ;

        -- Get WF User Id
        Eng_Workflow_Util.GetWFUserId
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_wf_user_id        => l_wf_user_id
        ) ;

        -- Get Route Id
        Eng_Workflow_Util.GetRouteId
        (   p_item_type    => itemtype
         ,  p_item_key     => itemkey
         ,  x_route_id     => l_route_id
        ) ;

        -- Get Route Step Id
        Eng_Workflow_Util.GetRouteStepId
        (   p_item_type         => itemtype
         ,  p_item_key          => itemkey
         ,  x_route_step_id     => l_route_step_id
        ) ;


        --
        -- Decided not to start Validation Def process which
        -- is place folder for customization
        -- Starting a place folder def process with no validation
        -- per each response does not seem to be right
        -- Also we don't document this yet
        -- Start Workflow to validate definitions
        -- Eng_Workflow_Util.StartValidateDefProcess
        -- ( x_msg_count               => l_msg_count
        -- , x_msg_data                => l_msg_data
        -- , x_return_status           => l_return_status
        -- , x_val_def_item_key        => l_val_def_item_key
        -- , p_step_item_type          => itemtype
        -- , p_step_item_key           => itemkey
        -- , p_responded_ntf_id        => WF_ENGINE.context_nid
        -- , p_route_id                => l_route_id
        -- , p_route_step_id           => l_route_step_id
        -- , p_val_def_item_type       => Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE
        -- , p_val_def_process_name    => Eng_Workflow_Util.G_VALIDATE_DEFINITION_PROC
        -- , p_host_url                => l_host_url
        -- , p_orig_response           => l_response_code
        -- ) ;
        --
        --


    END IF ;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if;


  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
    Eng_Workflow_Util.reassignRoutePeople(  x_return_status         =>  l_return_status
                                          , x_msg_count             =>  l_msg_count
                                          , x_msg_data              =>  l_msg_data
                                          , p_item_type             =>  itemtype
                                          , p_item_key              =>  itemkey
                                          , p_notification_id       =>  WF_ENGINE.context_nid
                                          , p_reassign_mode         =>  funcmode);
    result := 'COMPLETE';
    return;

  end if;


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_DEF_APPR_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_DEF_APPR_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_DEF_APPR_REQ ;


-- RESPOND_TO_ROUTE_CORRECT_REQ
PROCEDURE RESPOND_TO_ROUTE_CORRECT_REQ(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;
    l_debug_filename  VARCHAR2(30) ; -- 'RespToRtCorrectReq.log' ;



BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;

    /* Bug2885157
    WF_STANDARD.VoteForResultType ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;
    */

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN


  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;


    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );


    l_return_status := FND_API.G_RET_STS_SUCCESS  ;

    --
    -- Put business logic here in future
    --


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;


        return;

    ELSE
        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if;

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_CORRECT_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_CORRECT_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_CORRECT_REQ ;


--
-- R12B
-- PROCEDURE RESPOND_TO_ROUTE_RESPONSE_REQ
--
PROCEDURE RESPOND_TO_ROUTE_RESPONSE_REQ (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_response_code       VARCHAR2(30) ;

    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : TRUE ;
    l_output_dir      VARCHAR2(80) ; -- '/appslog/bis_top/utl/plm115dv/log' ;
    l_debug_filename  VARCHAR2(30) ; -- 'RespRtComReq.log'



BEGIN


  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);



-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling VoteForReuslt. . . ' ) ;
END IF ;

    Eng_Workflow_Util.RouteStepVoteForResultType
                                 ( itemtype
                                  , itemkey
                                  , actid
                                  , funcmode
                                  , result ) ;


IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    return;

  end if ; -- funcmode : RUN


  --
  -- RESPOND mode -
  --
  -- Notificaction Response
  --
  if (funcmode = 'RESPOND') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
END IF ;



    l_response_code := WF_NOTIFICATION.GetAttrText
                         ( nid    => WF_ENGINE.context_nid
                         , aname  => 'RESULT'
                         );

    --
    -- R12B Modified to support AUTO_REVOKE_RESPONSE NTF Attribute
    -- If the response is the value specified in AUTO_REVOKE_RESPONSE NTF Attribute
    -- we will revoke roles on this wf assignee
    -- Record Route Response
    Eng_Workflow_Util.SetRouteResponse
    ( x_return_status         =>  l_return_status
    , x_msg_count             =>  l_msg_count
    , x_msg_data              =>  l_msg_data
    , p_item_type             =>  itemtype
    , p_item_key              =>  itemkey
    , p_notification_id       =>  WF_ENGINE.context_nid
    , p_response_code         =>  l_response_code
    , p_actid                 =>  actid
    , p_funcmode              =>  funcmode
    ) ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('After call Eng_Workflow_Util.SetRouteResponse: Return: ' ||  l_return_status  ) ;
END IF ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;


        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


/*
   -- Send Reponse FYI notification to original requestor of
   -- the comment request from Response FYI process
   Eng_Workflow_Util.START_RESPONSE_FYI_PROCESS
    ( p_itemtype                => itemtype
    , p_itemkey                 => itemkey
    , p_orig_response_option    => NULL
    , p_responded_ntf_id        => WF_ENGINE.context_nid
    , p_responded_comment_id    => l_created_action_id
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , x_return_status           => l_return_status
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;
*/

  end if;

  --
  -- TRANSFER or FORWARD mode -
  --
  -- Notificaction Reassignment
  --
  if (funcmode = 'TRANSFER' OR funcmode = 'FORWARD' )
  then
    Eng_Workflow_Util.reassignRoutePeople(  x_return_status         =>  l_return_status
                                          , x_msg_count             =>  l_msg_count
                                          , x_msg_data              =>  l_msg_data
                                          , p_item_type             =>  itemtype
                                          , p_item_key              =>  itemkey
                                          , p_notification_id       =>  WF_ENGINE.context_nid
                                          , p_reassign_mode         =>  funcmode);
    result := 'COMPLETE';
    return;

  end if;



  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_RESPONSE_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'RESPOND_TO_ROUTE_RESPONSE_REQ',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END RESPOND_TO_ROUTE_RESPONSE_REQ ;






-- PROCEDURE START_ROUTE_STEP
PROCEDURE START_ROUTE_STEP(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_route_id            NUMBER ;
    l_action_id           NUMBER ;
    l_change_id           NUMBER ;
    l_change_line_id      NUMBER ;
    l_wf_user_id          NUMBER ;
    l_host_url            VARCHAR2(256) ;
    l_route_step_id       NUMBER ;
    l_step_item_type      VARCHAR2(8) ;
    l_step_item_key       VARCHAR2(240) ;

    l_debug_flag          BOOLEAN := FALSE ;  -- For TEST : TRUE;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('In START_ROUTE_STEP . . . ' ) ;
END IF ;

    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    -- Get Chagne Line Id
    Eng_Workflow_Util.GetChangeLineObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_line_id => l_change_line_id
    ) ;

    -- Get Host URL
    Eng_Workflow_Util.GetHostURL
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_host_url          => l_host_url
    ) ;

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_route_id     => l_route_id
    ) ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('calling Eng_Workflow_Util.StartNextRouteStep. . . ' ) ;
END IF ;


    -- Get Action Id for Parent Route to record
    -- Individual User Response for the Step into Action log
    -- as a child of Parent Action correctly
    Eng_Workflow_Util.GetActionId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_action_id         => l_action_id
    ) ;


    -- Start Next Route Step Workflow
    Eng_Workflow_Util.StartNextRouteStep
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_route_item_type   => itemtype
    ,  p_route_item_key    => itemkey
    ,  p_route_id          => l_route_id
    ,  p_route_action_id   => l_action_id
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_host_url          => l_host_url
    ,  x_step_id           => l_route_step_id
    ,  x_step_item_type    => l_step_item_type
    ,  x_step_item_key     => l_step_item_key
    ) ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('after calling Eng_Workflow_Util.StartNextRouteStep. . . ' ) ;
END IF ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN


IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('Set route step id. ' || to_char(l_route_step_id)  ) ;
END IF ;

        -- Set started Step Id as current step id
        Eng_Workflow_Util.SetRouteStepId
        (   p_item_type    => itemtype
         ,  p_item_key     => itemkey
         ,  p_route_step_id  =>l_route_step_id
        ) ;

        result  :=  'COMPLETE';
        return;

    -- None
    ELSIF l_return_status = Eng_Workflow_Util.G_RET_STS_NONE THEN

        result  := 'COMPLETE:NONE';
        return;
    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'START_ROUTE_STEP',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'START_ROUTE_STEP',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END START_ROUTE_STEP ;


PROCEDURE CHECK_STEP_RESULT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_route_step_id       NUMBER ;
    l_step_status_code    VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;

    -- Get Route Step Status
    Eng_Workflow_Util.GetRouteStepStatus
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  p_route_step_id     => l_route_step_id
     ,  x_status_code       => l_step_status_code
    ) ;

    -- set result
    result  :=  'COMPLETE:' || l_step_status_code ;
    return;


  end if ; -- funcmode : RUN


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_STEP_RESULT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_STEP_RESULT ;


-- PROCEDURE CHECK_LINE_APPROVALS
PROCEDURE CHECK_LINE_APPROVALS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS
    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER ;
    l_msg_data             VARCHAR2(200);
    l_change_id            NUMBER ;
    l_line_approval_status NUMBER ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    Eng_Workflow_Util.CheckAllLineApproved
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_change_id         => l_change_id
    ,  x_line_approval_status => l_line_approval_status
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE:' || l_line_approval_status ;
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_LINE_APPROVALS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_LINE_APPROVALS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_LINE_APPROVALS ;


-- FIND_WAITING_STEP
PROCEDURE FIND_WAITING_STEP (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;
    l_step_item_type      VARCHAR2(8) ;
    l_step_process_name   VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;


    -- Find Next Route Step Workflow
    Eng_Workflow_Util.FindNextRouteStep
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_route_id          => l_route_id
    ,  x_step_id           => l_route_step_id
    ,  x_step_item_type    => l_step_item_type
    ,  x_step_process_name => l_step_process_name
    ) ;



    IF l_route_step_id IS NOT NULL AND
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

        -- set result
        result  :=  'COMPLETE:' || FND_API.G_TRUE;
        return;

    ELSIF l_route_step_id IS NULL AND
          l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN

        -- set result
        result  :=  'COMPLETE:' || FND_API.G_FALSE;
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'FIND_WAITING_STEP',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'FIND_WAITING_STEP',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END FIND_WAITING_STEP ;

-- ROUTE_APPROVE_CHANGE
PROCEDURE ROUTE_APPROVE_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_wf_user_id          NUMBER ;
    l_change_id           NUMBER ;
    l_change_line_id      NUMBER ;
    l_change_notice       VARCHAR2(10) ;
    l_organization_id     NUMBER ;
    l_route_id            NUMBER ;
    l_route_type_code     VARCHAR2(30) ;
    l_route_compl_status_code VARCHAR2(30) ;
    l_action_id           NUMBER ;
    l_action_type         VARCHAR2(30) ;
    l_parent_action_id    NUMBER ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_change_id         => l_change_id
    ) ;

    -- Get Chagne Line Id
    Eng_Workflow_Util.GetChangeLineObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_line_id => l_change_line_id
    ) ;


    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;

    -- Get Route Type Code
    Eng_Workflow_Util.GetRouteTypeCode
    (  p_route_id          => l_route_id
    ,  x_route_type_code   => l_route_type_code
    ) ;


    -- Get Route Status Completion Code
    Eng_Workflow_Util.GetRouteComplStatusCode
    (  p_route_id                  => l_route_id
    ,  p_route_type_code           => l_route_type_code
    ,  x_route_compl_status_code   => l_route_compl_status_code
    ) ;


    -- Set Route Status
    Eng_Workflow_Util.SetRouteStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_new_status_code   => l_route_compl_status_code
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id   -- Added in R12B
    ) ;


    -- In case that Route Object is Change Object
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        -- Get Action Id and set this as parent action id
        Eng_Workflow_Util.GetActionId
        (  p_item_type         => itemtype
        ,  p_item_key          => itemkey
        ,  x_action_id         => l_parent_action_id
        ) ;


        /*************************************************
        --  in 115.10, Workflow Routing will not update
        -- Approval Status of Change Object
        -- Set Approval Status
        -- Eng_Workflow_Util.SetChangeApprovalStatus
        -- (  x_return_status        => l_return_status
        -- ,  x_msg_count            => l_msg_count
        -- ,  x_msg_data             => l_msg_data
        -- ,  p_item_type            => itemtype
        -- ,  p_item_key             => itemkey
        -- ,  p_change_id            => l_change_id
        -- ,  p_change_line_id       => l_change_line_id
        -- ,  p_wf_user_id           => l_wf_user_id
        -- ,  p_sync_lines           => 1  -- Set sync mode: True
        -- ,  p_new_appr_status_type => Eng_Workflow_Util.G_APPROVED
        -- ) ;

        -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            -- Unexpected Exception
            -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        -- END IF ;
        **************************************************/


        l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code => l_route_compl_status_code
                         , p_convert_type      =>  'WF_PROCESS' ) ;

        Eng_Workflow_Util.CreateRouteAction
        (  x_return_status        => l_return_status
        ,  x_msg_count            => l_msg_count
        ,  x_msg_data             => l_msg_data
        ,  p_change_id            => l_change_id
        ,  p_change_line_id       => l_change_line_id
        ,  p_action_type          => l_action_type
        ,  p_user_id              => Eng_Workflow_Util.G_ACT_SYSTEM_USER_ID
        ,  p_parent_action_id     => l_parent_action_id
        ,  p_route_id             => l_route_id
        ,  p_comment              => NULL
        ,  x_action_id            => l_action_id
        ) ;


        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            -- set result
            result  :=  'COMPLETE';
            return;

        ELSE

            -- Unexpected Exception
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        END IF ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_APPROVE_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_APPROVE_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END ROUTE_APPROVE_CHANGE ;

-- ROUTE_REJECT_CHANGE
PROCEDURE ROUTE_REJECT_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_wf_user_id          NUMBER ;
    l_change_id           NUMBER ;
    l_change_line_id      NUMBER ;
    l_route_id            NUMBER ;
    l_action_id           NUMBER ;
    l_parent_action_id    NUMBER ;
    l_action_type         VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;


    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_change_id         => l_change_id
    ) ;

    -- Get Chagne Line Id
    Eng_Workflow_Util.GetChangeLineObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_line_id => l_change_line_id
    ) ;

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;


    -- Set Route Status
    Eng_Workflow_Util.SetRouteStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_REJECTED
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id   -- Added in R12B
    ) ;



    -- In case that Route Object is Change Object
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        /*************************************************
        --  in 115.10, Workflow Routing will not update
        -- Approval Status of Change Object
        -- Set Approval Status
        -- Eng_Workflow_Util.SetChangeApprovalStatus
        -- (  x_return_status        => l_return_status
        -- ,  x_msg_count            => l_msg_count
        -- ,  x_msg_data             => l_msg_data
        -- ,  p_item_type            => itemtype
        -- ,  p_item_key             => itemkey
        -- ,  p_change_id            => l_change_id
        -- ,  p_change_line_id       => l_change_line_id
        -- ,  p_wf_user_id           => l_wf_user_id
        -- ,  p_new_appr_status_type => Eng_Workflow_Util.G_REJECTED
        -- ) ;


        -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            -- Unexpected Exception
            -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        -- END IF ;
        *************************************************/


        -- Get Action Id and set this as parent action id
        Eng_Workflow_Util.GetActionId
        (  p_item_type         => itemtype
        ,  p_item_key          => itemkey
        ,  x_action_id         => l_parent_action_id
        ) ;

        l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  Eng_Workflow_Util.G_RT_REJECTED
                         , p_convert_type      =>  'WF_PROCESS' ) ;


        Eng_Workflow_Util.CreateRouteAction
        (  x_return_status        => l_return_status
        ,  x_msg_count            => l_msg_count
        ,  x_msg_data             => l_msg_data
        ,  p_change_id            => l_change_id
        ,  p_change_line_id       => l_change_line_id
        ,  p_action_type          => l_action_type
        ,  p_user_id              => Eng_Workflow_Util.G_ACT_SYSTEM_USER_ID
        ,  p_parent_action_id     => l_parent_action_id
        ,  p_route_id             => l_route_id
        ,  p_comment              => NULL
        ,  x_action_id            => l_action_id
        ) ;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            -- set result
            result  :=  'COMPLETE';
            return;

        ELSE

            -- Unexpected Exception
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        END IF ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_REJECT_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_REJECT_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END ROUTE_REJECT_CHANGE ;

-- ROUTE_SET_TIMEOUT
PROCEDURE ROUTE_SET_TIMEOUT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_wf_user_id          NUMBER ;
    l_change_id           NUMBER ;
    l_change_line_id      NUMBER ;
    l_route_id            NUMBER ;
    l_action_id           NUMBER ;
    l_parent_action_id    NUMBER ;
    l_action_type         VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;


    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_change_id         => l_change_id
    ) ;

    -- Get Chagne Line Id
    Eng_Workflow_Util.GetChangeLineObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_line_id => l_change_line_id
    ) ;


    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;


    -- Set Route Status
    Eng_Workflow_Util.SetRouteStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_TIME_OUT
    ,  p_change_id         => l_change_id
    ,  p_change_line_id    => l_change_line_id   -- Added in R12B
    ) ;


    -- In case that Route Object is Change Object
    IF l_change_id IS NOT NULL AND l_change_id > 0
    THEN

        /*************************************************
        --  in 115.10, Workflow Routing will not update
        -- Approval Status of Change Object
        -- Set Approval Status
        -- Eng_Workflow_Util.SetChangeApprovalStatus
        -- (  x_return_status        => l_return_status
        -- ,  x_msg_count            => l_msg_count
        -- ,  x_msg_data             => l_msg_data
        -- ,  p_item_type            => itemtype
        -- ,  p_item_key             => itemkey
        -- ,  p_change_id            => l_change_id
        -- ,  p_change_line_id       => l_change_line_id
        -- ,  p_wf_user_id           => l_wf_user_id
        -- ,  p_new_appr_status_type => Eng_Workflow_Util.G_TIME_OUT
        -- ) ;

        -- IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

            -- Unexpected Exception
            -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        -- END IF ;
        *************************************************/


        -- Get Action Id and set this as parent action id
        Eng_Workflow_Util.GetActionId
        (  p_item_type         => itemtype
        ,  p_item_key          => itemkey
        ,  x_action_id         => l_parent_action_id
        ) ;


        l_action_type := Eng_Workflow_Util.ConvertRouteStatusToActionType
                         ( p_route_status_code =>  Eng_Workflow_Util.G_RT_TIME_OUT
                         , p_convert_type      =>  'WF_PROCESS' ) ;


        Eng_Workflow_Util.CreateRouteAction
        (  x_return_status        => l_return_status
        ,  x_msg_count            => l_msg_count
        ,  x_msg_data             => l_msg_data
        ,  p_change_id            => l_change_id
        ,  p_change_line_id       => l_change_line_id
        ,  p_action_type          => l_action_type
        ,  p_user_id              => Eng_Workflow_Util.G_ACT_SYSTEM_USER_ID
        ,  p_parent_action_id     => l_parent_action_id
        ,  p_route_id             => l_route_id
        ,  p_comment              => NULL
        ,  x_action_id            => l_action_id
        ) ;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            -- set result
            result  :=  'COMPLETE';
            return;

        ELSE

            -- Unexpected Exception
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

        END IF ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_SET_TIMEOUT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'ROUTE_SET_TIMEOUT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END ROUTE_SET_TIMEOUT ;



-- STEP_COMPLETE_ACTIVITY
PROCEDURE STEP_COMPLETE_ACTIVITY (
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_wf_user_id          NUMBER ;
    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;


    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;


    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;

    -- Set Route Step Status
    Eng_Workflow_Util.SetRouteStepStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_route_step_id     => l_route_step_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_COMPLETED
    ) ;

    -- set result
    result  :=  'COMPLETE';
    return;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'STEP_COMPLETE_ACTIVITY',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


END STEP_COMPLETE_ACTIVITY ;

-- STEP_APPROVE_CHANGE
PROCEDURE STEP_APPROVE_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_wf_user_id          NUMBER ;
    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;


    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;


    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;

    -- Set Route Step Status
    Eng_Workflow_Util.SetRouteStepStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_route_step_id     => l_route_step_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_APPROVED
    ) ;

    -- set result
    result  :=  'COMPLETE';
    return;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'STEP_APPROVE_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STEP_APPROVE_CHANGE ;

-- STEP_REJECT_CHANGE
PROCEDURE STEP_REJECT_CHANGE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS
    l_wf_user_id          NUMBER ;
    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;

    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;

    -- Set Route Step Status
    Eng_Workflow_Util.SetRouteStepStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_route_step_id     => l_route_step_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_REJECTED
    ) ;

    -- set result
    result  :=  'COMPLETE';
    return;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'STEP_REJECT_CHANGE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STEP_REJECT_CHANGE ;


-- STEP_SET_TIMEOUT
PROCEDURE STEP_SET_TIMEOUT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_wf_user_id          NUMBER ;
    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_id          => l_route_id
    ) ;

    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;

    -- Set Route Step Status
    Eng_Workflow_Util.SetRouteStepStatus
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_wf_user_id        => l_wf_user_id
    ,  p_route_id          => l_route_id
    ,  p_route_step_id     => l_route_step_id
    ,  p_new_status_code   => Eng_Workflow_Util.G_RT_TIME_OUT
    ) ;

    -- set result
    result  :=  'COMPLETE';
    return;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'STEP_SET_TIMEOUT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END STEP_SET_TIMEOUT ;

--  GRANT_ROLE_TO_STEP_PEOPLE
PROCEDURE GRANT_ROLE_TO_STEP_PEOPLE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_change_id           NUMBER ;
    l_route_step_id       NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;

    -- Get Route Step Id
    Eng_Workflow_Util.GetRouteStepId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_route_step_id     => l_route_step_id
    ) ;


    -- Grant Role to Step People
    Eng_Workflow_Util.GrantChangeRoleToStepPeople
    (  x_return_status     => l_return_status
    ,  x_msg_count         => l_msg_count
    ,  x_msg_data          => l_msg_data
    ,  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  p_change_id         => l_change_id
    ,  p_step_id           => l_route_step_id
    ) ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'GRANT_ROLE_TO_STEP_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'GRANT_ROLE_TO_STEP_PEOPLE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END GRANT_ROLE_TO_STEP_PEOPLE ;


-- CHECK_DEFINITIONS
PROCEDURE CHECK_DEFINITIONS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_route_id            NUMBER ;
    l_route_step_id       NUMBER ;
    l_step_item_type      VARCHAR2(8) ;
    l_step_process_name   VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Route Step Id
    -- Eng_Workflow_Util.GetRouteStepId
    -- (   p_item_type         => itemtype
    --  ,  p_item_key          => itemkey
    --  ,  x_route_step_id     => l_route_step_id
    -- ) ;


    --
    -- Check Definitions
    --

    -- By default alyways set result
    result  :=  'COMPLETE:' || FND_API.G_TRUE;
    return;

    -- Based on your result, you can launch another workflow
    -- and make this activity DEFFERED
    -- result := wf_engine.eng_notified ||':'||
    --                  wf_engine.eng_null ||':'||
    --                  wf_engine.eng_null;
    --
    -- Then your another workflow, continue to this activity
    -- using wf_engine.CompleteActivity api
    --
    -- Or just return False
    -- set result
    -- result  :=  'COMPLETE:' || FND_API.G_FALSE;
    -- return;
    -- In this case you need to modify transition in  workflow definition
    --
    --

    -- For unexpeced exception
    -- Unexpected Exception
    -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_DEFINITIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_DEFINITIONS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_DEFINITIONS ;


-- CHECK_ROUTE_OBJECT
PROCEDURE CHECK_ROUTE_OBJECT(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_route_object         VARCHAR2(30) ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Route Object
    Eng_Workflow_Util.GetRouteObject
    (  p_item_type         => itemtype
    ,  p_item_key          => itemkey
    ,  x_route_object      => l_route_object
    ) ;


    -- By default alyways set result
    result  :=  'COMPLETE:' || l_route_object ;
    return;

  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_ROUTE_OBJECT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_ROUTE_OBJECT',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_ROUTE_OBJECT ;



--
-- SYNC_CHANGE_LC_PHASE
PROCEDURE SYNC_CHANGE_LC_PHASE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_route_id            NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_route_id     => l_route_id
    ) ;


    -- Call Sync Change Lifecycle Phase API
    Eng_Workflow_Util.SyncChangeLCPhase
    (  x_return_status        => l_return_status
    ,  x_msg_count            => l_msg_count
    ,  x_msg_data             => l_msg_data
    ,  p_route_id             => l_route_id
    ,  p_api_caller           => Eng_Workflow_Util.G_WF_CALL
    ) ;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SYNC_CHANGE_LC_PHASE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SYNC_CHANGE_LC_PHASE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SYNC_CHANGE_LC_PHASE ;






--
-- PROCEDURE CHECK_CHANGE_APPR_STATUS
--
--   result
--       - COMPLETE[:<ENG_ECN_APPROVAL_STATUS lookup codes>] or NULL
--           activity has completed with the step result
PROCEDURE CHECK_CHANGE_APPR_STATUS(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_change_id           NUMBER ;
    l_appr_status         NUMBER ;


    CURSOR c_chg_appr ( c_change_id  NUMBER )
    IS
        SELECT  approval_status_type
        FROM    ENG_ENGINEERING_CHANGES
        WHERE  change_id = c_change_id ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    -- Get Approval Status
    OPEN c_chg_appr(c_change_id => l_change_id) ;
    FETCH c_chg_appr into l_appr_status ;
    IF (c_chg_appr%notfound) THEN
        CLOSE c_chg_appr;
    END IF;

    IF (c_chg_appr%ISOPEN) THEN
       CLOSE c_chg_appr;
    END IF;

    -- no result needed
    result := 'COMPLETE:' || to_char(l_appr_status) ;
    return;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_CHANGE_APPR_STATUS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_CHANGE_APPR_STATUS',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_CHANGE_APPR_STATUS ;


--
-- PROCEDURE CHECK_BASE_CM_TYPE_CODE
--
--   Check Approval Status
--   Bug5136260
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--   result
--       - COMPLETE[:<ENG_BASE_CM_TYPE_CODES lookup codes>] or NULL
--           activity has completed with the step result
PROCEDURE CHECK_BASE_CM_TYPE_CODE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
)
IS

    l_change_id           NUMBER ;
    l_base_cm_type_code   VARCHAR2(30) ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;

    -- Get Base CM Type code
    l_base_cm_type_code := Eng_Workflow_Util.GetBaseChangeMgmtTypeCode(l_change_id) ;

    -- no result needed
    result := 'COMPLETE:' || l_base_cm_type_code ;
    return;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_BASE_CM_TYPE_CODE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CHECK_BASE_CM_TYPE_CODE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CHECK_BASE_CM_TYPE_CODE ;




--
-- PROCEDURE SET_CO_MRP_FLAG_ACTIVE
--
PROCEDURE SET_CO_MRP_FLAG_ACTIVE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_change_id           NUMBER ;
    l_wf_user_id          NUMBER ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;

    -- Call SetChangeOrderMRPFlag
    Eng_Workflow_Util.SetChangeOrderMRPFlag
    (  x_return_status        => l_return_status
    ,  x_msg_count            => l_msg_count
    ,  x_msg_data             => l_msg_data
    ,  p_change_id            => l_change_id
    ,  p_mrp_flag             => Eng_Workflow_Util.G_MRP_FLAG_YES
    ,  p_wf_user_id           => l_wf_user_id
    ,  p_api_caller           => Eng_Workflow_Util.G_WF_CALL
    ) ;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_CO_MRP_FLAG_ACTIVE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_CO_MRP_FLAG_ACTIVE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SET_CO_MRP_FLAG_ACTIVE ;



--
-- PROCEDURE SET_CO_MRP_FLAG_INACTIVE
--
PROCEDURE SET_CO_MRP_FLAG_INACTIVE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_change_id           NUMBER ;
    l_wf_user_id          NUMBER ;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    -- Get Chagne Id
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type    => itemtype
     ,  p_item_key     => itemkey
     ,  x_change_id    => l_change_id
    ) ;


    -- Get WF User Id
    Eng_Workflow_Util.GetWFUserId
    (   p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  x_wf_user_id        => l_wf_user_id
    ) ;


    -- Call SetChangeOrderMRPFlag
    Eng_Workflow_Util.SetChangeOrderMRPFlag
    (  x_return_status        => l_return_status
    ,  x_msg_count            => l_msg_count
    ,  x_msg_data             => l_msg_data
    ,  p_change_id            => l_change_id
    ,  p_mrp_flag             => Eng_Workflow_Util.G_MRP_FLAG_NO
    ,  p_wf_user_id           => l_wf_user_id
    ,  p_api_caller           => Eng_Workflow_Util.G_WF_CALL
    ) ;

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_CO_MRP_FLAG_INACTIVE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_CO_MRP_FLAG_INACTIVE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SET_CO_MRP_FLAG_INACTIVE ;



--
-- PROCEDURE SET_ADMIN_STATUS_MONITOR_URL
--
--   Set WF Admin Status Monigor URL to Item Attribute: STATUS_MONITOR_URL
--   Called from ENGWFSTD/TEST_CM_EVENT Process
--
PROCEDURE SET_ADMIN_STATUS_MONITOR_URL(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)

IS
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_url                 VARCHAR2(2000);

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then



    -- Get WF Admin Statuss Monigor URL
    Eng_Workflow_Util.GetWorkflowMonitorURL
    (   p_api_version       => 1.0
     ,  p_init_msg_list     => FND_API.G_FALSE
     ,  p_commit            => FND_API.G_FALSE
     ,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
     ,  x_return_status     => l_return_status
     ,  x_msg_count         => l_msg_count
     ,  x_msg_data          => l_msg_data
     ,  p_item_type         => itemtype
     ,  p_item_key          => itemkey
     ,  p_url_type          => Eng_Workflow_Util.G_MONITOR_ADVANCED_ENVELOPE
     ,  p_admin_mode        => FND_API.G_TRUE
     -- ,  p_admin_mode        => FND_API.G_FALSE
     ,  p_option            => 'ALL'
     ,  x_url               => l_url
    )  ;


    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        -- for Notification
        WF_ENGINE.SetItemAttrText( itemtype
                             , itemkey
                             , 'STATUS_MONITOR_URL'
                             , l_url);


        -- set result
        result  :=  'COMPLETE';
        return;

    ELSE

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_ADMIN_STATUS_MONITOR_URL',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_ADMIN_STATUS_MONITOR_URL',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SET_ADMIN_STATUS_MONITOR_URL ;



--
-- PROCEDURE SET_EVENT_CHANGE_OBJECT_INFO
--
--   Set Event and Change Object info for CM Event
--   Called from ENGWFSTD/TEST_CM_EVENT Process
--
PROCEDURE SET_EVENT_CHANGE_OBJECT_INFO
(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
)
IS
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(200);

    l_text_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_text_attr_value_tbl  WF_ENGINE.TextTabTyp;

    l_num_attr_name_tbl    WF_ENGINE.NameTabTyp;
    l_num_attr_value_tbl   WF_ENGINE.NumTabTyp;

    l_date_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_date_attr_value_tbl  WF_ENGINE.DateTabTyp;

    I PLS_INTEGER ;

    l_event_name                VARCHAR2(200) ;
    l_event_key                 VARCHAR2(200) ;
    l_change_id                 NUMBER ;
    l_change_notice             VARCHAR2(10) ;
    l_organization_id           NUMBER ;
    l_organization_code         VARCHAR2(3) ;
    l_change_managemtent_type   VARCHAR2(80) ;
    l_base_cm_type_code         VARCHAR2(30) ;
    l_change_name               VARCHAR2(240) ;
    l_description               VARCHAR2(2000) ;
    l_change_order_type         VARCHAR2(80) ;
    l_organization_name         VARCHAR2(60) ;
    l_eco_department            VARCHAR2(60) ;
    l_change_status             VARCHAR2(80) ;
    l_change_lc_phase           VARCHAR2(80) ;
    l_approval_status           VARCHAR2(80) ;
    l_priority                  VARCHAR2(50) ;
    l_reason                    VARCHAR2(50) ;
    l_assignee                  VARCHAR2(360) ;
    l_assignee_company          VARCHAR2(360) ;

    l_batch_id                  NUMBER ;

    l_event_t             wf_event_t;
    l_subscription        RAW(16);
    l_url                 varchar2(4000);
    l_eventdataurl        varchar2(4000);
    l_source              varchar2(8);


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then



      -- Get Adhoc Party List
      l_event_key := WF_ENGINE.GetItemAttrText( itemtype
                                                 , itemkey
                                                 , 'EVENT_KEY');

      l_event_name := WF_ENGINE.GetItemAttrText( itemtype
                                                 , itemkey
                                                 , 'EVENT_NAME');


      --
      -- Get the Event Item Attribute
      --
      l_event_t := WF_ENGINE.GetItemAttrEvent(
                                     itemtype        => itemtype,
                                     itemkey         => itemkey,
                                     name           => 'EVENT_MESSAGE' );



      -- Generate the URL
      l_eventdataurl := wf_oam_util.GetViewXMLURL(p_eventattribute => 'EVENT_MESSAGE',
                                                    p_itemtype => itemtype,
                                                    p_itemkey => itemkey);


      IF l_event_name = ENG_CHANGE_BES_UTIL.G_CMBE_IMPORT_COMPLETE
      THEN
         l_batch_id := TO_NUMBER(l_event_key) ;
      ELSE
          l_change_id := TO_NUMBER(l_event_key) ;
      END IF ;

      BEGIN

          IF l_change_id IS NOT NULL
          THEN

              -- Get Change Object Info
              Eng_Workflow_Util.GetChangeObjectInfo
              ( p_change_id               => l_change_id
              , x_change_notice           => l_change_notice
              , x_organization_id         => l_organization_id
              , x_change_name             => l_change_name
              , x_description             => l_description
              , x_change_status           => l_change_status
              , x_change_lc_phase         => l_change_lc_phase
              , x_approval_status         => l_approval_status
              , x_priority                => l_priority
              , x_reason                  => l_reason
              , x_change_managemtent_type => l_change_managemtent_type
              , x_change_order_type       => l_change_order_type
              , x_eco_department          => l_eco_department
              , x_assignee                => l_assignee
              , x_assignee_company        => l_assignee_company
              ) ;


              -- Get Organization Info
              Eng_Workflow_Util.GetOrgInfo
              ( p_organization_id   => l_organization_id
              , x_organization_code => l_organization_code
              , x_organization_name => l_organization_name ) ;

         END IF ;

      EXCEPTION
           WHEN OTHERS THEN
              NULL ;
      END ;

      -- Set Dummy values for Wf Messages
      IF l_change_id IS NULL
      THEN
         l_change_notice := 'na' ;
         l_organization_code := 'na' ;
      END IF ;

      -- Text Item Attributes
      -- Using SetItemAttrTextArray():
      I := 0 ;

      -- Change Object Number
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'ITEMTYPE' ;
      l_text_attr_value_tbl(I) := itemtype ;

      -- Change Object Number
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'ITEMKEY' ;
      l_text_attr_value_tbl(I) := itemkey ;

      -- Change Object Number
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'CHANGE_NOTICE' ;
      l_text_attr_value_tbl(I) := l_change_notice ;

      -- Change Object Name
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'CHANGE_NAME' ;
      l_text_attr_value_tbl(I) := l_change_name ;

      -- Organization Code
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'ORGANIZATION_CODE' ;
      l_text_attr_value_tbl(I) := l_organization_code ;

      -- Organization Name
      -- I := I + 1  ;
      -- l_text_attr_name_tbl(I)  := 'ORGANIZATION_NAME' ;
      -- l_text_attr_value_tbl(I) := l_organization_name ;

      -- Change Management Type
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'CHANGE_MANAGEMENT_TYPE' ;
      l_text_attr_value_tbl(I) := l_change_managemtent_type ;


      -- Set the PL/SQL Document for the Event Details
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'EVENT_DETAILS' ;
      l_text_attr_value_tbl(I) := 'PLSQL:WF_STANDARD.EVENTDETAILS/'||ItemType||':'||ItemKey ;


      -- Set the Value for the Event Data URL
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'EVENT_DATA_URL' ;
      l_text_attr_value_tbl(I) := l_eventdataurl ;



      IF l_change_id IS NOT NULL
      THEN

          -- Change Detail Page URL
          I := I + 1  ;
          l_text_attr_name_tbl(I)  := 'CHANGE_DETAIL_PAGE_URL' ;
          l_text_attr_value_tbl(I) := 'JSP:/OA_HTML/OA.jsp?OAFunc=ENG_CHANGE_DETAIL_PAGE'
                                     || '&changeId=-&CHANGE_ID-' ;
      END IF ;

      -- Set Text Attributes
      WF_ENGINE.SetItemAttrTextArray
      ( itemtype     => itemtype
      , itemkey      => itemkey
      , aname        => l_text_attr_name_tbl
      , avalue       => l_text_attr_value_tbl
      ) ;

      -- Number Item Attributes
      -- Using SetItemAttrNumberArray():
      I := 0 ;

      -- Change Id
      I := I + 1  ;
      l_num_attr_name_tbl(I)  := 'CHANGE_ID' ;
      l_num_attr_value_tbl(I) := l_change_id ;

      -- Organization Id
      I := I + 1  ;
      l_num_attr_name_tbl(I)  := 'ORGANIZATION_ID' ;
      l_num_attr_value_tbl(I) := l_organization_id  ;

      -- Batch Id
      I := I + 1  ;
      l_num_attr_name_tbl(I)  := 'BATCH_ID' ;
      l_num_attr_value_tbl(I) := l_batch_id ;

      -- Set Number Attributes
      WF_ENGINE.SetItemAttrNumberArray
      ( itemtype     => itemtype
      , itemkey      => itemkey
      , aname        => l_num_attr_name_tbl
      , avalue       => l_num_attr_value_tbl
      ) ;

      -- set result
      result  :=  'COMPLETE';
      return;


  end if ; -- funcmode : RUN

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_EVENT_CHANGE_OBJECT_INFO',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'SET_EVENT_CHANGE_OBJECT_INFO',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END SET_EVENT_CHANGE_OBJECT_INFO ;





/****************************************************
-- Not Supported in 115.10
-- CONTINUE_HEADER_ROUTE
PROCEDURE CONTINUE_HEADER_ROUTE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)

IS

    l_return_status        VARCHAR2(1);
    l_msg_count            NUMBER ;
    l_msg_data             VARCHAR2(200);

    l_waiting_activity      VARCHAR2(30);
    l_waiting_flow_type     VARCHAR2(30);


    l_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
    l_output_dir      VARCHAR2(80) ;   --  '/sqlcom/log/plm115d' ;
    l_debug_filename  VARCHAR2(30) ;   --  'ContinueHdrRoute' ;


BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


Eng_Workflow_Util.Get_Debug_Mode
(itemtype, itemkey, l_debug_flag, l_output_dir , l_debug_filename);

-- For Test/Debug
IF l_debug_flag THEN
   Eng_Workflow_Util.Open_Debug_Session( l_output_dir
                                       , l_debug_filename || actid ) ;
   Eng_Workflow_Util.Write_Debug('Get activity params . . . ' ) ;
END IF ;


    l_waiting_activity := UPPER(Wf_Engine.GetActivityAttrText(
                                itemtype, itemkey, actid,'WAITING_ACTIVITY'));
    l_waiting_flow_type := UPPER(Wf_Engine.GetActivityAttrText(
                              itemtype, itemkey, actid,'WAITING_FLOW_TYPE'));

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('WAITING_ACTIVITY : ' || l_waiting_activity ) ;
   Eng_Workflow_Util.Write_Debug('WAITING_FLOW_TYPE : ' || l_waiting_flow_type ) ;
END IF ;


    -- Currently we are supporting only for Header Route Approval Flow.
    -- e.g. seeded WAITING_FLOW value is 'APPROVAL'
    -- In future, we may need to support other type of flow
    --
    -- if ( l_waiting_flow = 'APPROVAL' ) then
    --   Eng_Workflow_Util.WaitForLineApprovalFlow . . .
    -- elsif ( l_waiting_flow = 'XXXX' ) then
        -- null
    -- else
        -- raise exception ;
        -- call WF_STANDARD.WaitForFlow
    -- end if;
    --

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('Calling Eng_Workflow_Util.ContinueHeaderRoute. . . ' ) ;
END IF ;


    Eng_Workflow_Util.ContinueHeaderRoute
    (   x_return_status           => l_return_status
     ,  x_msg_count               => l_msg_count
     ,  x_msg_data                => l_msg_data
     ,  p_item_type               => itemtype
     ,  p_item_key                => itemkey
     ,  p_actid                   => actid
     ,  p_waiting_activity        => l_waiting_activity
     ,  p_waiting_flow_type       => NVL(l_waiting_flow_type, 'APPROVAL')
     ,  x_resultout               => result
    ) ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Write_Debug('Return Status : ' || l_return_status ) ;
   Eng_Workflow_Util.Write_Debug('Result : ' || result ) ;
END IF ;


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- result is set by ContinueHeaderRoute util api
    return;


  end if ; -- funcmode : RUN


  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := 'COMPLETE';
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN OTHERS THEN

IF l_debug_flag THEN
   Eng_Workflow_Util.Close_Debug_Session ;
END IF ;

    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'CONTINUE_HEADER_ROUTE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END CONTINUE_HEADER_ROUTE ;


-- PROCEDURE WAIT_FOR_LINE_ROUTE
PROCEDURE WAIT_FOR_LINE_ROUTE(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2)
IS

    l_continuation_activity  VARCHAR2(30);
    l_continuation_flow_type VARCHAR2(30);

    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER ;
    l_msg_data               VARCHAR2(200);

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then


    l_continuation_activity := UPPER(WF_ENGINE.GETACTIVITYATTRTEXT(
                                         itemtype, itemkey, actid,
                                         'CONTINUATION_ACTIVITY'));


    l_continuation_flow_type := UPPER(WF_ENGINE.GetActivityAttrText(
                                         itemtype,itemkey,actid,
                                           'CONTINUATION_FLOW_TYPE'));

    -- Currently we are supporting only for Line Route Approval Flow.
    -- e.g. seeded CONTINUATION_FLOW value is 'APPROVAL'
    -- In future, we may need to support other type of flow
    --
    -- if ( l_continuation_flow_type = 'APPROVAL' ) then
    --   Eng_Workflow_Util.WaitForLineApprovalFlow . . .
    -- elsif ( l_continuation_flow_type = 'XXXX' ) then
        -- null
    -- else
        -- call ContinueFlow.WaitForFlow
    -- end if;
    --

    Eng_Workflow_Util.WaitForLineRoute
    (   x_return_status           => l_return_status
     ,  x_msg_count               => l_msg_count
     ,  x_msg_data                => l_msg_data
     ,  p_item_type               => itemtype
     ,  p_item_key                => itemkey
     ,  p_actid                   => actid
     ,  p_continuation_activity   => l_continuation_activity
     ,  p_continuation_flow_type  => NVL(l_continuation_flow_type, 'APPROVAL')
     ,  x_resultout               => result
    ) ;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        -- Unexpected Exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;

    END IF ;

    -- result is set by WaitForLineRoute util api
    return;

  end if ; -- funcmode : RUN


  --
  -- This is in the event that the activity must be undone,
  -- for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    result := wf_engine.eng_null ;
    return;
  end if;

  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'WAIT_FOR_LINE_ROUTE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;


  WHEN OTHERS THEN
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('Eng_Workflow_Pub', 'WAIT_FOR_LINE_ROUTE',
                    itemtype, itemkey, to_char(actid), funcmode);
    raise;

END WAIT_FOR_LINE_ROUTE ;
-- Not Supported in 115.10
*****************************************************/




END Eng_Workflow_Pub ;

/
