--------------------------------------------------------
--  DDL for Package Body AMS_GENERIC_NTFY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_GENERIC_NTFY_PVT" as
/* $Header: amsvgntb.pls 120.1 2005/06/15 02:03:32 appldev  $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'ams_generic_ntfy_pvt';
G_ITEMTYPE     CONSTANT varchar2(30) := 'AMSGAPP';


PROCEDURE StartProcess
           (p_activity_type          IN   VARCHAR2,
            p_activity_id            IN   NUMBER,
            p_item_key_suffix        IN   NUMBER,
            p_workflowprocess        IN   VARCHAR2   DEFAULT NULL,
            p_item_type              IN   VARCHAR2   DEFAULT NULL,
            p_subject                IN   VARCHAR2,
            p_send_by                IN   VARCHAR2   DEFAULT NULL,
            p_sent_to                IN   VARCHAR2   DEFAULT NULL
             )
IS
  itemtype              VARCHAR2(30) := nvl(p_item_type,'AMSGAPP');
  itemkey               VARCHAR2(30) := p_activity_type||to_char(p_activity_id)||':'||to_char(p_item_key_suffix);
  itemuserkey           VARCHAR2(80) := p_activity_type||p_activity_id;

  l_requester_role         VARCHAR2(100) ;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(4000);
  l_error_msg              VARCHAR2(4000);
  x_resource_id            NUMBER;
  l_index                  NUMBER;
  l_save_threshold         NUMBER := wf_engine.threshold;
  l_x_data                 VARCHAR2(4000);

BEGIN
  FND_MSG_PUB.initialize();

  AMS_Utility_PVT.debug_message('Start :Item Type : '||itemtype
                         ||' Item key : '||itemkey);

    -- wf_engine.threshold := -1;
  WF_ENGINE.CreateProcess (itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            process    =>   p_workflowprocess);

  WF_ENGINE.SetItemUserkey(itemtype   =>   itemtype,
                            itemkey    =>   itemkey ,
                            userkey    =>   itemuserkey);


   /*****************************************************************
      Initialize Workflow Item Attributes
   *****************************************************************/
  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_ACTIVITY_TYPE',
                             avalue     =>   p_activity_type  );

   -- Activity ID  (primary Id of Activity Object)
  WF_ENGINE.SetItemAttrNumber(itemtype  =>  itemtype ,
                               itemkey   =>  itemkey,
                               aname     =>  'AMS_ACTIVITY_ID',
                               avalue    =>  p_activity_id  );

  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_SENT_BY',
                             avalue     =>   p_send_by  );

  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'AMS_SEND_TO',
                             avalue     =>   p_sent_to  );

  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'GEN_SUBJECT',
                             avalue     =>   p_subject  );

/*
l_x_data:=icx_sec.createRFURL( p_function_name          => 'AMS_EVENTS',
                      p_function_id            =>1005958,
                      p_application_id         =>531,
                      p_responsibility_id      =>21706,
                      p_security_group_id      =>NULL,
                      p_session_id             =>NULL
                      );
WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'LAUNCH_URL',
                             avalue     =>   l_x_data  );
*/

/*  WF_ENGINE.SetItemAttrText(itemtype    =>  itemtype,
                            itemkey     =>  itemkey,
                            aname       =>  'AMS_GEN_NTF_APPROVER',
                            avalue      =>  'CHOANG'  );
*/

  WF_ENGINE.SetItemAttrText(itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'AMS_DOCUMENT_ID',
          avalue   => ItemType||':'||ItemKey);

/*
wf_engine.SetItemAttrText(itemtype => itemtype,
          itemkey  => itemkey,
          aname    => 'AMS_GEN_DOCUMENT',
          avalue   => 'PLSQL:AMS_GENERIC_NTFY_PVT.AMS_GENERIC_NOTIFICATION/'||ItemType||':'||ItemKey);
*/
  WF_ENGINE.SetItemOwner(itemtype    => itemtype,
                          itemkey     => itemkey,
                          owner       => p_send_by);


   -- Start the Process
  WF_ENGINE.StartProcess (itemtype       => itemtype,
                            itemkey       => itemkey);


    -- wf_engine.threshold := l_save_threshold ;
EXCEPTION
  WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
    FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);


    IF (l_msg_count > 0) THEN
      FOR I in 1 .. l_msg_count LOOP
        fnd_msg_pub.Get
          (p_msg_index      => FND_MSG_PUB.G_NEXT,
          p_encoded        => FND_API.G_FALSE,
          p_data           => l_msg_data,
          p_msg_index_out  =>       l_index);
       --dbms_output.put_line('message :'||l_msg_data);
      END LOOP;
    END IF;
    RAISE;
END StartProcess;


--------------------------------------------------------------------------------
--
-- Procedure
--   Ntf_Approval(document_id      in  varchar2,
--                display_type     in  varchar2,
--                document         in out varchar2,
--                document_type    in out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Ams_Generic_Notification(document_id    in  varchar2,
                                   display_type   in  varchar2,
                                   document       in OUT NOCOPY  varchar2,
                                   document_type  in OUT NOCOPY varchar2)
IS
l_pkg_name  varchar2(80);
l_proc_name varchar2(80);
l_return_stat       varchar2(1);
l_activity_type    varchar2(80);
l_approval_type varchar2(80);
l_msg_data              VARCHAR2(4000);
l_msg_count          number;
l_error_msg             VARCHAR2(4000);
l_index                  NUMBER;
dml_str  varchar2(2000);
ItemType varchar2(80);
ItemKey varchar2(80);
BEGIN

  ItemType := nvl(substr(document_id, 1,instr(document_id,':')-1),'AMSGAPP');
  ItemKey  := substr(document_id, instr(document_id,':')+1);


  l_activity_type      := wf_engine.GetItemAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'AMS_ACTIVITY_TYPE' );
  IF l_activity_type is NULL THEN
    RAISE FND_API.G_EXC_ERROR;
    FND_MESSAGE.Set_Name('AMS','AMS_APPR_NO_ACTIVITY_TYPE');
    FND_MSG_PUB.Add;
  END IF;
  ams_gen_approval_pvt.Get_Api_Name('WORKFLOW', l_activity_type, 'GEN_NOTIFY',l_approval_type, l_pkg_name, l_proc_name,l_return_stat);
  IF (l_return_stat = 'S') THEN
    dml_str := 'BEGIN ' ||  l_pkg_name||'.'||l_proc_name||'(:document_id,:display_type,:document,:document_type); END;';
    EXECUTE IMMEDIATE dml_str USING IN document_id,IN display_type,IN OUT document,IN OUT document_type;
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;
/*
if (display_type = 'text/plain') then
 document := document|| 'Requisition approval requested for:';
 document := document|| chr(10)|| '        Number: '||ItemKey;
 document_type := 'text/plain';
  return;
  end if;

  if (display_type = 'text/html') then
 document := document|| 'Requisition approval requested for:';
 document := document|| chr(10)|| '        Number: '||ItemKey;
 document_type := 'text/html';
  return;
  end if;
*/
EXCEPTION
  WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
    FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);


    IF(l_msg_count > 0) THEN
      FOR I in 1 .. l_msg_count LOOP
        fnd_msg_pub.Get
          (p_msg_index      => FND_MSG_PUB.G_NEXT,
          p_encoded        => FND_API.G_FALSE,
          p_data           => l_msg_data,
          p_msg_index_out  =>       l_index);
      -- dbms_output.put_line('message :'||l_msg_data);
      END LOOP;
    END IF;
    RAISE;

END Ams_Generic_Notification;

-------------------------------------------------------------------------------
--
-- Procedure
--   Updat_staus(itemtype        in  varchar2,
--                itemkey         in  varchar2,
--                actid           in  number,
--                funcmode        in  varchar2,
--                resultout       out varchar2    )
---------------------------------------------------------------------------------
PROCEDURE Update_Gen_Status(itemtype IN varchar2,
                        itemkey  IN varchar2,
                        actid           in  number,
                        funcmode        in  varchar2,
                        resultout       OUT NOCOPY varchar2    )
IS
l_stat      varchar2(80);

l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_error_msg              VARCHAR2(4000);
l_index                  NUMBER;

BEGIN
  l_stat      := wf_engine.GetActivityAttrText(
                                 itemtype => itemtype,
                                 itemkey  => itemkey,
                                 actid  => actid,
                                 aname    => 'UPDATE_STATUS' );
  IF(l_stat is NULL) THEN
    l_stat:='Value is NULL';
  END IF;

  WF_ENGINE.SetItemAttrText(itemtype   =>  itemtype ,
                             itemkey    =>  itemkey,
                             aname      =>  'UPDATE_GEN_STATUS',
                             avalue     =>   l_stat  );

EXCEPTION
  WHEN OTHERS THEN
        -- wf_engine.threshold := l_save_threshold ;
    FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => l_msg_count,
               p_data    => l_msg_data);

  IF (l_msg_count > 0) THEN
    FOR I in 1 .. l_msg_count LOOP
      fnd_msg_pub.Get
      (p_msg_index      => FND_MSG_PUB.G_NEXT,
       p_encoded        => FND_API.G_FALSE,
       p_data           => l_msg_data,
       p_msg_index_out  =>       l_index);
      -- dbms_output.put_line('message :'||l_msg_data);
    END LOOP;
  END IF;
  RAISE;

END Update_Gen_Status;

END ams_generic_ntfy_pvt;

/
