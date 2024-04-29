--------------------------------------------------------
--  DDL for Package Body BOM_TEST_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_TEST_SUBSCR_PKG" as
/* $Header: BOMTSUBB.pls 120.4 2006/01/10 17:37 seradhak noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMTSUBB.pls
--
--  DESCRIPTION
--
--      Body of package Bom_Test_Subscr_PKG
--
--  NOTES
--
--
--
--  HISTORY
--
-- 24-Oct-2005    Selva Radhakrishnan   Initial Creation
--
--
Bom_Test_Subscr_PKG.bom_test_subscription
***************************************************************************/

FUNCTION bom_test_subscription (p_subscription_guid IN RAW,
                                 p_event IN OUT NOCOPY wf_event_t)
RETURN VARCHAR2 IS
    l_param_name     VARCHAR2(240);
    l_param_value    VARCHAR2(2000);
    l_event_name     VARCHAR2(2000);
    l_event_key      VARCHAR2(2000);
    l_err_text       VARCHAR2(3000);
    l_param_list     WF_PARAMETER_LIST_T ;

    l_debug_file_dir VARCHAR2(512);
    l_log_file       VARCHAR2(240);
    l_log_return_status VARCHAR2(1);
    l_errbuff        VARCHAR2(3000);
    l_error          VARCHAR2(30);

BEGIN
    SELECT VALUE INTO l_debug_file_dir FROM V$PARAMETER WHERE  NAME = 'utl_file_dir';
    IF INSTR(l_debug_file_dir,',') <> 0 THEN
        l_debug_file_dir := SUBSTR(l_debug_file_dir, 1, INSTR(l_debug_file_dir, ',') - 1);
    END IF;
    l_log_file := 'BOM_TEST_SUBSCR'||'_'||TO_CHAR(SYSDATE, 'DDMONYYYY_HH24MISS')||'.err';

    Error_Handler.initialize();
    Error_Handler.Set_Debug('Y');
    Error_Handler.Open_Debug_Session(
          p_debug_filename   => l_log_file
         ,p_output_dir       => l_debug_file_dir
         ,x_return_status    => l_log_return_status
         ,x_error_mesg       => l_errbuff
         );

   l_event_name := p_event.getEventName();
   l_event_key  := p_event.GetEventKey();
   Error_HandLer.Write_Debug(p_debug_message  => 'Event Name'|| ' = '||l_event_name );
   Error_HandLer.Write_Debug(p_debug_message  => 'Event Key '|| ' = '||l_event_key );

   l_param_list := p_event.getparameterlist;
   IF l_param_list IS NOT NULL THEN
     FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP
        l_param_name  :=  l_param_list(i).getname;
        l_param_value :=  l_param_list(i).getvalue;
        Error_HandLer.Write_Debug(p_debug_message  => l_param_name|| ' = '||l_param_value );
     END LOOP;
   END IF;
   Error_Handler.Close_Debug_Session;
   RETURN 'SUCCESS';
   EXCEPTION WHEN OTHERS THEN
     l_error := SQLERRM;
     l_err_text := 'Error : '||TO_CHAR(SQLCODE)||'---'||l_err_text;
     Error_Handler.Add_Error_Message( p_message_text => l_err_text, p_message_type => 'E');
     Error_Handler.Close_Debug_Session;
   RETURN 'ERROR';
END bom_test_subscription;

PROCEDURE SET_BOM_EVENT_INFO
(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    result    in out NOCOPY varchar2
)
IS
    l_text_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_text_attr_value_tbl  WF_ENGINE.TextTabTyp;
    I PLS_INTEGER ;
    l_event_t wf_event_t;
    l_param_name            VARCHAR2(240);
    l_param_value           VARCHAR2(1000);
    l_param_list            WF_PARAMETER_LIST_T ;
    l_concat_param_value    VARCHAR2(1000) := '';
BEGIN
  if (funcmode = 'RUN') then

       --
       -- Get the Event Item Attribute
       --
       l_event_t := WF_ENGINE.GetItemAttrEvent(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              name           => 'EVENT_MESSAGE' );

       l_param_list := l_event_t.getparameterlist;
       IF l_param_list IS NOT NULL THEN
	 FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP
	     l_param_name  :=  l_param_list(i).getname;
	     l_param_value :=  l_param_list(i).getvalue;
	     l_concat_param_value := l_concat_param_value ||'{' ||l_param_list(i).getname ||'==>'||l_param_list(i).getvalue||'}';
	 END LOOP;
       END IF;

      -- Text Item Attributes
      -- Using SetItemAttrTextArray():
      I := 0 ;

      -- Change Object Number
      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'ITEMTYPE' ;
      l_text_attr_value_tbl(I) := itemtype ;

      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'ITEMKEY' ;
      l_text_attr_value_tbl(I) := itemkey ;

      I := I + 1  ;
      l_text_attr_name_tbl(I)  := 'PARAMS' ;
      l_text_attr_value_tbl(I) := l_concat_param_value ;



      WF_ENGINE.SetItemAttrTextArray
      ( itemtype     => itemtype
      , itemkey      => itemkey
      , aname        => l_text_attr_name_tbl
      , avalue       => l_text_attr_value_tbl
      ) ;

      result  :=  'COMPLETE';
      return;
  end if ; -- funcmode : RUN
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


END SET_BOM_EVENT_INFO;

END Bom_Test_Subscr_PKG;

/
