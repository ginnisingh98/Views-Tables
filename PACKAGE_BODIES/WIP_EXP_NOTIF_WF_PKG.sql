--------------------------------------------------------
--  DDL for Package Body WIP_EXP_NOTIF_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_EXP_NOTIF_WF_PKG" AS
/* $Header: wipvexpb.pls 120.2 2005/07/05 03:55:50 amgarg noship $ */

PROCEDURE INVOKE_NOTIFICATION(p_exception_id  IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2)

IS

  l_seq         varchar2(10);
  l_ItemType    VARCHAR2(8);
  l_ItemKey     VARCHAR2(240) ;

  l_job_name    VARCHAR2(240);
  l_op_seq_num  NUMBER;
  l_res_name    VARCHAR2(10);
  l_comp_name   VARCHAR2(40);

  x_progress varchar2(4) := '000';

begin

    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_itemtype:='WIPEXPWK';

    select
      wen.wip_entity_name, we.operation_seq_num, br.resource_code, msi.concatenated_segments
    into
      l_job_name, l_op_seq_num, l_res_name, l_comp_name
    from
      wip_exceptions we, wip_entities wen, bom_resources br, mtl_system_items_vl msi
    where
      we.organization_id = wen.organization_id and
      we.wip_entity_id = wen.wip_entity_id and
      we.organization_id = br.organization_id(+) and
      we.resource_id = br.resource_id (+) and
      we.organization_id = msi.organization_id(+) and
      we.component_item_id = msi.inventory_item_id (+) and
      we.exception_id = p_exception_id;

    select to_char(WIP_EXP_NOTIF_WF_ITEMKEY_S.NEXTVAL)
      into l_seq from sys.dual;

    l_itemkey := to_char (p_exception_id)|| '-' || l_seq;

    wf_engine.createProcess     ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey,
                                  Process   => 'WIP_EXCEPTION_REPORT');

    wf_engine.SetItemAttrNumber ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'EXCEPTION_ID',
                                  avalue   => p_exception_id);

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'TO_RESPONSIBILITY',
                                  avalue   => 'FND_RESP|WIP|WIP_WS_SUPERVISOR|STANDARD');

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'FROM_RESPONSIBILITY',
                                  avalue   => 'FND_RESP|WIP|WIP_WS_OPERATOR|STANDARD');

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'JOB_NAME',
                                  avalue   => l_job_name);

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'OP_SEQ_NUM',
                                  avalue   => l_op_seq_num);

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'RESOURCE_NAME',
                                  avalue   => l_res_name);

    wf_engine.SetItemAttrText ( itemtype => l_itemtype,
                                  itemkey  => l_itemkey,
                                  aname    => 'COMPONENT_NAME',
                                  avalue   => l_comp_name);

    wf_engine.StartProcess      ( ItemType  => l_ItemType,
                                  ItemKey   => l_ItemKey );

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ('WIP_EXP_NOTIF_WF_PKG' ,'Invoke_Notification');
    END IF;
    FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);

    WF_CORE.context('WIP_EXP_NOTIF_WF_PKG' , 'InvokeNotification',
    x_progress);
    RAISE;

end INVOKE_NOTIFICATION;


---
procedure CHECK_EXCEPTION_TYPE   ( itemtype        in  varchar2,
                                  itemkey         in  varchar2,
                                  actid           in number,
                                  funcmode        in  varchar2,
                                  result          out nocopy varchar2    )
is

  x_progress          varchar2(3) := '000';

  l_exception_id      NUMBER;
  l_exception_type    NUMBER;

begin

  x_progress := '001';

  l_exception_id := wf_engine.GetItemAttrNumber (itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'EXCEPTION_ID');
  x_progress := '2';

  select exception_type into l_exception_type from wip_exceptions where exception_id = l_exception_id ;

   x_progress := '3';

  if (l_exception_type = 1) then
    result := 'COMPLETE:RESOURCE';
  elsif (l_exception_type = 2) then
    result := 'COMPLETE:COMPONENTS';
  elsif (l_exception_type = 3) then
    result := 'COMPLETE:PFA';
  else
    result := 'COMPLETE:OTHERS';
  end if;

   x_progress := '4';

exception

  WHEN OTHERS THEN
       wf_core.context('WIP_EXP_NOTIF_WF_PKG','CHECK_EXCEPTION_TYPE', x_progress);
       raise;

END CHECK_EXCEPTION_TYPE;

----

END WIP_EXP_NOTIF_WF_PKG;

/
