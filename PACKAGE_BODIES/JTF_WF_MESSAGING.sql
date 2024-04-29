--------------------------------------------------------
--  DDL for Package Body JTF_WF_MESSAGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_WF_MESSAGING" as
/* $Header: JTFWFMGB.pls 120.2 2005/10/25 05:08:39 psanyal ship $ */

----------------------------------------------------------------------------

 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_WF_MESSAGING';


Procedure   GenMsg(	itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   OUT NOCOPY /* file.sql.39 change */ varchar2 ) is

l_prod_code	Varchar2(5);
l_bus_obj_code	Varchar2(10);
l_bus_obj_name	Varchar2(100);
l_action_code	varchar2(5);
l_correlation	varchar2(50);
l_return_code	varchar2(1);
l_bind_data_id	number;

Begin

If (funcmode = 'RUN') then


       l_bind_data_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname  => 'BIND_DATA_ID');

	l_prod_code := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                  itemkey   => itemkey,
                                                  aname  => 'PRODUCT_CODE');

	l_bus_obj_code := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname  => 'BUS_OBJ_CODE');

	l_bus_obj_name := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                     itemkey   => itemkey,
                                                     aname  => 'BUS_OBJ_NAME');

	l_action_code := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'ACTION_CODE');

	l_correlation := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'CORRELATION');

       /*  call generate_message   */
	JTF_USR_HKS.Generate_Message( p_prod_code => l_prod_code,
				      p_bus_obj_code => l_bus_obj_code,
				      p_bus_obj_name => l_bus_obj_name,
				      p_action_code  => l_action_code,
				      p_correlation  => l_correlation,
				      p_bind_data_id => l_bind_data_id,
				      x_return_code  => l_return_code );

        result := 'COMPLETE';
	return;
End if;

If  ( funcmode = 'CANCEL' ) then

	result := 'COMPLETE';
	return;
Else
	result := '';
	return;
End if;

Exception
	When  OTHERS then
           wf_core.context('JTF_WF_MESSAGING','GenMsg',itemtype,itemkey,
                            to_char(actid),funcmode);

End GenMsg;


END jtf_wf_messaging;

/
