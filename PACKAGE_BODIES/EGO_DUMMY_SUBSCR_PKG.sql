--------------------------------------------------------
--  DDL for Package Body EGO_DUMMY_SUBSCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DUMMY_SUBSCR_PKG" AS
   /* $Header: EGOSBSCRB.pls 120.4 2006/06/30 13:36:52 vkeerthi noship $ */
/*  FUNCTION dummy_subscription (P_SUBSCRIPTION_GUID IN RAW,
                               P_EVENT IN OUT NOCOPY wf_event_t)
  RETURN VARCHAR2 IS
    l_param_name    VARCHAR2(240);
    l_param_value   VARCHAR2(2000);
    l_param_list    WF_PARAMETER_LIST_T ;
    l_name_val VARCHAR2(4000);
    l_error         VARCHAR2(4000);
  BEGIN
    l_param_list := p_event.getparameterlist;
    l_name_val   := ' ';
    IF l_param_list IS NOT NULL THEN
      FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP
        l_param_name  :=  l_param_list(i).getname;
        l_param_value :=  l_param_list(i).getvalue;
        IF l_param_name NOT IN ('BES_PAYLOAD_OBJECT','BES_PRIORITY','#MSG_ID')
THEN
          l_name_val    :=  l_name_val ||' '||l_param_name||  ' = '
||l_param_value || ',' ;
        END IF;
      END LOOP;
      INSERT INTO EVENT_SUBSCRIPTION(
        event_name,
        event_key,
        pname_value,
        dt)
      VALUES(
        p_event.getEventName(),
        p_event.GetEventKey(),
        l_name_val,
        sysdate);
    ELSE
      INSERT INTO EVENT_SUBSCRIPTION(
        event_name,
        event_key,
        pNAME_value,
        error_msg,
        dt)
      VALUES (
        p_event.getEventName(),
        p_event.GetEventKey(),
        null,
        'Parameter list is empty',
        sysdate);
    END IF;
  COMMIT;
  RETURN 'SUCCESS';
  EXCEPTION WHEN OTHERS THEN
    l_error := SQLERRM;
    INSERT INTO EVENT_SUBSCRIPTION(
      event_name,
      event_key,
      pname_value,
      error_msg,
      dt)
    VALUES (
      p_event.getEventName(),
      p_event.GetEventKey(),
      null,
      'Unexpected Error: '||l_error,
      sysdate);
    COMMIT;
    RETURN 'ERROR';
  END dummy_subscription;
*/


PROCEDURE SET_EGO_EVENT_INFO(
          itemtype  IN VARCHAR2,
          itemkey   IN VARCHAR2,
          actid     IN NUMBER,
          funcmode  IN VARCHAR2,
          result    IN OUT NOCOPY VARCHAR2
) IS

    l_text_attr_name_tbl   WF_ENGINE.NameTabTyp;
    l_text_attr_value_tbl  WF_ENGINE.TextTabTyp;
    I PLS_INTEGER ;
    l_event_t wf_event_t;
    l_param_name            VARCHAR2(240);
    l_param_value           VARCHAR2(1000);
    l_param_list    wf_parameter_list_t ;
    l_concat_param_value    VARCHAR2(1000) := '';

    l_event_key             VARCHAR2(200);
    l_event_name            VARCHAR2(200);
BEGIN
     IF (funcmode = 'RUN') THEN
       l_event_t := WF_ENGINE.GetItemAttrEvent(
                              itemtype        => itemtype,
                              itemkey         => itemkey,
                              name            => 'EVENT_MESSAGE' );
      l_event_key := WF_ENGINE.GetItemAttrText( itemtype
                                                 , itemkey
                                                 , 'EVENT_KEY');

      l_event_name := WF_ENGINE.GetItemAttrText( itemtype
                                                 , itemkey
                                                 , 'EVENT_NAME');
       l_param_list := l_event_t.getparameterlist;
       IF l_param_list IS NOT NULL THEN

         FOR i IN l_param_list.FIRST..l_param_list.LAST LOOP
          l_param_name  :=  l_param_list(i).getname;
          l_param_value :=  l_param_list(i).getvalue;
          --Removing all the unnecessary params and taking onl the user-defined attrs.
            IF (l_param_name NOT IN ('REQUEST_ID','DML_TYPE','ORGANIZATION_ID',
                'ORGANIZATION_CODE','INVENTORY_ITEM_ID','MAIL_TO','SUB_GUID',
                'CATALOG_ID','CATEGORY_ID','CATEGORY_NAME','CATEGORY_SET_ID',
                'CROSS_REFERENCE_TYPE','CROSS_REFERENCE','MANUFACTURER_ID',
                'MFG_PART_NUM','ROLE_ID','PARTY_TYPE','PARTY_ID','START_DATE',
                'ATTR_GROUP_NAME','EXTENSION_ID')) THEN
              l_concat_param_value := l_concat_param_value ||'{' ||l_param_list(i).getname ||'==>'||l_param_list(i).getvalue||'}';
            END IF;
          END LOOP;
       END IF;

       I := 0;

       I := I + 1;
       l_text_attr_name_tbl(I)  := 'ITEM_TYPE' ;
       l_text_attr_value_tbl(I) := itemtype ;

       I := I + 1;
       l_text_attr_name_tbl(I)  := 'ITEM_KEY' ;
       l_text_attr_value_tbl(I) := itemkey ;

       I := I + 1;
       l_text_attr_name_tbl(I) := 'EVENT_NAME';
       l_text_attr_value_tbl(I) := l_event_name;

       I := I + 1;
       l_text_attr_name_tbl(I) := 'EVENT_KEY';
       l_text_attr_value_tbl(I) := l_event_key;

       --IF l_param_list IS NOT NULL THEN
          I := I + 1;
          l_text_attr_name_tbl(I)  := 'PARAM' ;
          l_text_attr_value_tbl(I) := l_concat_param_value ;
       --END IF;
       WF_ENGINE.SetItemAttrTextArray
       ( itemtype     => itemtype
       , itemkey      => itemkey
       , aname        => l_text_attr_name_tbl
       , avalue       => l_text_attr_value_tbl
       ) ;
       result  :=  'COMPLETE';
       RETURN;
     END IF;
     IF (funcmode = 'CANCEL') then

    -- your cancel code goes here
       NULL;

    -- no result needed
       result := 'COMPLETE';
       RETURN;
     END IF;
  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  result := '';
  RETURN;


END;


  END ego_dummy_subscr_pkg;

/
