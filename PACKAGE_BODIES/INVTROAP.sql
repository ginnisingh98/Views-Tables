--------------------------------------------------------
--  DDL for Package Body INVTROAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVTROAP" as
/* $Header: INVWFTOB.pls 120.4.12010000.3 2010/03/03 18:09:59 kdong ship $ */

Procedure Start_TO_Approval(  To_Header_Id  in number,
                              Item_Type     in varchar2,
                              Item_Key      in varchar2 ) IS

l_ItemType 		varchar2(100) := nvl(Item_Type,'INVTROAP');
l_ItemKey 		varchar2(100) := Item_Key;
l_process_int_name      varchar2(100) := 'APPROVE_TRANSFER_ORDER';
x_requestor_username    varchar2(30);
x_requestor_disp_name   varchar2(80);
l_requestor_id          number;
l_requestor_name        varchar2(60);
l_wf_item_exists 	boolean;
l_trohdr_rec 		INV_Move_Order_PUB.Trohdr_Rec_Type;
l_trolin_tbl          	INV_Move_Order_PUB.Trolin_Tbl_Type;
l_timeout_period	number;
l_timeout_action	number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

/* To Defer the process from the start */

--  wf_engine.threshold := -1;


/* To check weather the current item already exist for approval */

l_trohdr_rec := INV_Trohdr_Util.Query_row( To_Header_Id );

 if ( l_trohdr_rec.header_status <> INV_Globals.G_TO_STATUS_INCOMPLETE ) then
                FND_MESSAGE.SET_NAME('INV','INV_TO_INVALID_FOR_APPROVAL');
                FND_MESSAGE.SET_TOKEN('ENTITY', To_Header_Id);
                FND_MSG_PUB.Add;
          RETURN;
 else
    Select nvl(TXN_APPROVAL_TIMEOUT_PERIOD,0)
      Into l_timeout_period
      From MTL_PARAMETERS
      Where organization_id = l_trohdr_rec.organization_id;

    if ( l_timeout_period = 0 ) then
        Select nvl(MO_APPROVAL_TIMEOUT_ACTION,1)
          Into l_timeout_action
          From MTL_PARAMETERS
          Where organization_id = l_trohdr_rec.organization_id;

        if( l_timeout_action = 1 ) then
            Inv_trohdr_Util.Update_Row_Status(To_Header_Id,
                                Inv_Globals.G_TO_STATUS_APPROVED);

            l_trolin_tbl := INV_trolin_util.Get_Lines( To_Header_Id );
            For l_line_count in 1..l_trolin_tbl.count  Loop

               /*    bug 2345192  */
               --Bug #5462193, commented the code below
               -- Changing the if condition to compare with INCOMPLETE.

               /*
               if(l_trolin_tbl(l_line_count).Line_Status=6) then
                 Inv_trolin_Util.Update_Row_Status(l_trolin_tbl(l_line_count).Line_id,
                                              INV_Globals.G_TO_STATUS_CANCELLED);
               */

	             if (l_trolin_tbl(l_line_count).Line_Status = INV_GLOBALS.G_TO_STATUS_INCOMPLETE) then
                  Inv_trolin_Util.Update_Row_Status(l_trolin_tbl(l_line_count).Line_id,
                                              INV_Globals.G_TO_STATUS_APPROVED);
               end if;
            end Loop;
        else
            Inv_trohdr_Util.Update_Row_Status(To_Header_Id,
                                Inv_Globals.G_TO_STATUS_REJECTED);

            l_trolin_tbl := INV_trolin_util.Get_Lines( To_Header_Id );
            For l_line_count in 1..l_trolin_tbl.count  Loop

               --Bug #5462193, added the if condition
	             if (l_trolin_tbl(l_line_count).Line_Status = INV_GLOBALS.G_TO_STATUS_INCOMPLETE) then
                 Inv_trolin_Util.Update_Row_Status(l_trolin_tbl(l_line_count).Line_id,
                                              INV_Globals.G_TO_STATUS_REJECTED);
               end if;
            end Loop;
        end if;
        Return;
    else
        Inv_trohdr_Util.Update_Row_Status(To_Header_Id,
                                Inv_Globals.G_TO_STATUS_PENDING_APPROVAL);
    end if;

 end if;

l_wf_item_exists := wf_item.item_exist( itemtype => l_ItemType,
                                        itemkey =>  l_ItemKey );
 if ( l_wf_item_exists ) then
--     inv_Debug.message('item exists');
                FND_MESSAGE.SET_NAME('INV','INV_ALREADY_EXISTS');
                FND_MESSAGE.SET_TOKEN('ENTITY','Approval Process');
                FND_MSG_PUB.Add;
 else
--Inv_debug.message(' creating the process');
  wf_engine.createprocess( itemtype => l_ItemType,
                           itemkey  => l_ItemKey,
                           process  => l_process_int_name );
--Inv_debug.message(' created the process');

  l_requestor_name := FND_GLOBAL.USER_NAME;

--l_requestor_name := 'OPERATIONS';

  select ORIG_SYSTEM_ID
  into   l_requestor_id
  from   WF_USERS
  where  NAME = l_requestor_name;

  wf_directory.GetUserName( p_orig_system    => 'PER',
                            p_orig_system_id => l_requestor_id,
                            p_name           => x_requestor_username,
                            p_display_name   => x_requestor_disp_name);

  wf_engine.SetItemOwner( itemtype => l_ItemType,
                          itemkey  => l_ItemKey,
                          owner    => l_requestor_name );

--inv_debug.message('Starting to set attributes' );

  wf_engine.setitemattrNumber( itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'TO_HEADER_ID',
                               avalue   => To_Header_Id );
  wf_engine.setitemattrNumber( itemtype =>   l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'ORG_ID',
                               avalue   => l_trohdr_rec.organization_id );


  wf_engine.setitemattrtext( itemtype => l_ItemType,
                             itemkey  => l_ItemKey,
                             aname    => 'REQUESTOR_USERNAME',
                             avalue   => x_requestor_username );

  wf_engine.setitemattrtext( itemtype => l_ItemType,
                             itemkey  => l_ItemKey,
                             aname    => 'REQUESTOR_DISPLAY_NAME',
                             avalue   => x_requestor_disp_name );

  wf_engine.setitemattrNumber( itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'REQUESTOR_ID',
                               avalue   => l_requestor_id );

  wf_engine.setitemattrtext( itemtype => l_ItemType,
                             itemkey  => l_ItemKey,
                             aname    => 'FORWARD_FROM_USERNAME',
                             avalue   => x_requestor_username );

  wf_engine.setitemattrtext( itemtype => l_ItemType,
                             itemkey  => l_ItemKey,
                             aname    => 'FORWARD_FROM_DISPLAY_NAME',
                             avalue   => x_requestor_disp_name );

  wf_engine.setitemattrNumber( itemtype => l_ItemType,
                               itemkey  => l_ItemKey,
                               aname    => 'FORWARD_FROM_ID',
                               avalue   => l_requestor_id );


--inv_debug.message('completed  setting attributes' );
--inv_debug.message('Itemtype='||l_ItemType );
--inv_debug.message('Itemkey='||l_Itemkey );

--Inv_Debug.Message('Starting the process' );

  wf_engine.startprocess( itemtype => l_ItemType,
                           itemkey  => l_ItemKey );

--inv_debug.message('Started the process' );
                FND_MESSAGE.SET_NAME('INV','INV_APPROVAL_LAUNCHED');
                FND_MSG_PUB.Add;
end if;

Exception
     When Others then
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   'INVTROAP'
            ,   'Start_TO_Approval'
            );
        END IF;
           wf_core.context('INVTROAP','Start_TO_Approval',l_itemtype,l_itemkey);
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;

End Start_TO_Approval;


Procedure Check_TO_Status( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
p_header_id  Number;
l_trohdr_rec INV_Move_Order_PUB.Trohdr_Rec_Type;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then

        p_header_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                      		                     itemkey   => itemkey,
						     aname  => 'TO_HEADER_ID');
        l_trohdr_rec := INV_Trohdr_Util.Query_row( p_header_id );

        if ( l_trohdr_rec.header_status  IN
                         ( INV_Globals.G_TO_STATUS_PENDING_APPROVAL,
                           INV_Globals.G_TO_STATUS_APPROVED )        )  then

  wf_engine.setitemattrtext( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_NUMBER',
                             avalue   => l_trohdr_rec.request_number );

  wf_engine.setitemattrtext( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_DESCRIPTION',
                             avalue   => l_trohdr_rec.description );

  wf_engine.setitemattrdate( itemtype => itemtype,
	                     itemkey  => itemkey,
        	             aname    => 'DATE_REQUIRED',
                	     avalue   => l_trohdr_rec.date_required );

            result := 'COMPLETE:PENDING_APPROVAL';
        else
            result := 'COMPLETE';
        end if;

       return;
    end if;

    if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
    else
       result := '';
    end if;

Exception
       When others then
           wf_core.context('INVTROAP','Check_TO_Status',itemtype,
			    itemkey, to_char(actid),funcmode);
           raise;

End Check_TO_Status;


Procedure Spawn_TO_Lines( itemtype in  varchar2,
                          itemkey  in  varchar2,
                          actid    in  number,
                          funcmode in  varchar2,
                          result   out nocopy varchar2 ) is

l_to_number             varchar2(30);
l_to_desc               varchar2(100);
l_header_id    		Number;
l_requestor_id 		Number;
l_line_count   		Number := 0;
l_child_itemtype      	varchar2(100) := itemtype;
l_child_itemkey       	varchar2(100);
l_trolin_tbl          	INV_Move_Order_PUB.Trolin_Tbl_Type;
l_requestor_username    varchar2(30);
l_requestor_disp_name   varchar2(80);
From_locator_value      varchar2(200);
to_locator_value        varchar2(200);


    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
   if (funcmode = 'RUN') then

       l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname     => 'TO_HEADER_ID');

       l_to_number := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname     => 'TO_NUMBER');

       l_to_desc := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'TO_DESCRIPTION');

       l_requestor_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname     => 'REQUESTOR_ID');

       l_requestor_username := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                             itemkey   => itemkey,
                                             aname     => 'REQUESTOR_USERNAME');

       l_requestor_disp_name := wf_engine.GetItemAttrtext( itemtype  => itemtype,
                                            itemkey   => itemkey,
                                            aname     => 'REQUESTOR_DISPLAY_NAME');


-- call TO API for loading line pl/sql table.

       l_trolin_tbl := INV_trolin_util.Get_Lines( l_header_id );

       For l_line_count in 1..l_trolin_tbl.count  Loop

         -- Bug #5462193, Cancelled lines should not go for approval.
         IF l_trolin_tbl(l_line_count).line_status = INV_GLOBALS.G_TO_STATUS_INCOMPLETE THEN

           l_child_itemkey := to_char(l_header_id)||'-'||
                        to_char(l_trolin_tbl(l_line_count).line_id);

           wf_engine.createprocess( itemtype    => l_child_itemtype,
                                 itemkey     => l_child_itemkey,
                                 process     => 'TO_LINE_APPROVE');

           wf_engine.SetItemOwner( itemtype => l_child_itemtype,
				                           itemkey  => l_child_itemkey,
                                   owner    => l_requestor_username );

           /* Set the item attributes here */

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'TO_NUMBER',
                        avalue   => l_to_number );

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'TO_HEADER_ID',
                        avalue   => l_header_id );

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'TO_DESCRIPTION',
                        avalue   => l_to_desc );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'LINE_NUMBER',
                        avalue   => l_trolin_tbl(l_line_count).line_number );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'LINE_QUANTITY',
                        avalue   => l_trolin_tbl(l_line_count).quantity );

--INVCONV
           wf_engine.setitemattrNumber( itemtype => itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'SEC_LINE_QTY',
                        avalue   => l_trolin_tbl(l_line_count).secondary_quantity );

           wf_engine.setitemattrtext( itemtype => itemtype,
                           itemkey  => l_child_itemkey,
                           aname    => 'SEC_UOM',
                           avalue   => l_trolin_tbl(l_line_count).secondary_uom );
--INVCONV

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'FROM_SUBINVENTORY',
                        avalue   => l_trolin_tbl(l_line_count).from_subinventory_code );

           from_locator_value := INV_UTILITIES.get_conc_segments(l_trolin_tbl(l_line_count).organization_id,
                                                      l_trolin_tbl(l_line_count).from_locator_id);

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'FROM_LOCATOR',
                        avalue   => from_locator_value);

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'TO_SUBINVENTORY',
                        avalue   =>
                           l_trolin_tbl(l_line_count).to_subinventory_code );

           to_locator_value := INV_UTILITIES.get_conc_segments(l_trolin_tbl(l_line_count).organization_id,
                                                    l_trolin_tbl(l_line_count).to_locator_id);

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'TO_LOCATOR',
                        avalue   => to_locator_value);

           wf_engine.setitemattrtext( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'UOM',
                        avalue   => l_trolin_tbl(l_line_count).uom_code );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                        itemkey  => l_child_itemkey,
                        aname    => 'LINE_ID',
                        avalue   => l_trolin_tbl(l_line_count).line_id );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                   itemkey  => l_child_itemkey,
                   aname    => 'ITEM_ID',
                   avalue   => l_trolin_tbl(l_line_count).inventory_item_id );

           wf_engine.setitemattrdate( itemtype => l_child_itemtype,
                    itemkey  => l_child_itemkey,
                    aname    => 'DATE_REQUIRED',
                    avalue   => l_trolin_tbl(l_line_count).date_required );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                      itemkey  => l_child_itemkey,
                      aname    => 'ORG_ID',
                      avalue   => l_trolin_tbl(l_line_count).organization_id );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                      itemkey  => l_child_itemkey,
                      aname    => 'REQUESTOR_ID',
                      avalue   => l_requestor_id  );

           wf_engine.setitemattrtext( itemtype => l_child_ItemType,
                      itemkey  => l_child_ItemKey,
                      aname    => 'REQUESTOR_USERNAME',
                      avalue   => l_requestor_username );

           wf_engine.setitemattrtext( itemtype => l_child_ItemType,
                      itemkey  => l_child_ItemKey,
                      aname    => 'REQUESTOR_DISPLAY_NAME',
                      avalue   => l_requestor_disp_name );

           wf_engine.setitemattrNumber( itemtype => l_child_itemtype,
                      itemkey  => l_child_itemkey,
                      aname    => 'FORWARD_FROM_ID',
                      avalue   => l_requestor_id  );

	         wf_engine.setitemattrtext( itemtype => l_child_ItemType,
                      itemkey  => l_child_ItemKey,
                      aname    => 'FORWARD_FROM_USERNAME',
                      avalue   => l_requestor_username );

           wf_engine.setitemattrtext( itemtype => l_child_ItemType,
                      itemkey  => l_child_ItemKey,
                      aname    => 'FORWARD_FROM_DISPLAY_NAME',
                      avalue   => l_requestor_disp_name );

           wf_engine.setitemparent(     itemtype => l_child_itemtype,
                      itemkey  => l_child_itemkey,
                      parent_itemtype => itemtype,
                      parent_itemkey  => itemkey,
                      parent_context  => NULL  );

       END IF;
    End loop;

    For l_line_count in 1..l_trolin_tbl.count  Loop

         -- Bug #5462193, Only incomplete lines should go for approval.
         IF l_trolin_tbl(l_line_count).line_status = INV_GLOBALS.G_TO_STATUS_INCOMPLETE THEN

           l_child_itemkey := to_char(l_header_id)||'-'||
                           to_char(l_trolin_tbl(l_line_count).line_id);

           Inv_trolin_Util.Update_Row_Status(l_trolin_tbl(l_line_count).Line_id ,
                                   INV_Globals.G_TO_STATUS_PENDING_APPROVAL);

           wf_engine.startprocess( itemtype    => l_child_itemtype,
                                itemkey     => l_child_itemkey );
         END IF;
    End loop;

    result := 'COMPLETE';
    return;

 end if;

 if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
 else
       result := '';
       return;
 end if;

 Exception
        when others then
           wf_core.context('INVTROAP','Spawn_TO_Lines',itemtype,itemkey,
                            actid,funcmode);
           raise;

End Spawn_TO_Lines;

Procedure Evaluate_TO_Status( itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2 ) is
l_header_id  	      Number;
l_trolin_tbl          INV_Move_Order_PUB.Trolin_Tbl_Type;
l_lines_approved      Number := 0;
l_lines_rejected      Number := 0;
l_total_lines	      Number := 0;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin

 if ( funcmode = 'RUN') then

   l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                               itemkey   => itemkey,
                                               aname     => 'TO_HEADER_ID');

   l_trolin_tbl := INV_trolin_util.Get_Lines( l_header_id );
   l_total_lines := l_trolin_tbl.count;

   For l_row_count in 1..l_trolin_tbl.count  Loop

     if ( l_trolin_tbl(l_row_count).line_status <>
                                 INV_Globals.G_TO_STATUS_APPROVED ) then
       l_lines_rejected := l_lines_rejected + 1;
     else
       l_lines_approved := l_lines_approved + 1;
     end if;

   End Loop;

   if    ( l_lines_rejected = 0 ) then
     result := 'COMPLETE:APPROVED';
   elsif  ( l_lines_rejected < l_total_lines ) then
     result := 'COMPLETE:PART_APPROVE';
   else
     result := 'COMPLETE:REJECTED';
   end if;

   return;

 end if;

  if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
  else
       result := '';
       return;

  end if;
 Exception
        when others then
           wf_core.context('INVTROAP','Get_TO_Approval_Status',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Evaluate_TO_Status;


Procedure Upd_TO_Approved( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
l_header_id   Number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then
        l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'TO_HEADER_ID');
        Inv_trohdr_Util.Update_Row_Status(l_header_id,
				  Inv_Globals.G_TO_STATUS_APPROVED);
        result := 'COMPLETE';
        return;
     end if;

     if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
     else
       result := '';
       return;
     end if;

 exception
        when others then
           wf_core.context('INVTROAP','Upd_TO_Approved',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;

End Upd_TO_Approved;


Procedure Upd_TO_Part_Approved( itemtype in  varchar2,
                     	        itemkey  in  varchar2,
                       	        actid    in  number,
                       	        funcmode in  varchar2,
                                result   out nocopy varchar2 ) is
  l_header_id   Number;
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then
        l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'TO_HEADER_ID');
     Inv_trohdr_Util.Update_Row_Status(l_header_id,
				Inv_Globals.G_TO_STATUS_PART_APPROVED);
        result := 'COMPLETE';
        return;
    end if;

     if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
     else
       result := '';
       return;

    end if;

 exception
        when others then
           wf_core.context('INVTROAP','Upd_TO_Part_Approved',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;

End Upd_TO_Part_Approved;



Procedure Upd_TO_Rejected( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
  l_header_id 	Number;
  l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then

	l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'TO_HEADER_ID');
     Inv_trohdr_Util.Update_Row_Status(l_header_id,
                                       Inv_Globals.G_TO_STATUS_REJECTED);
       result := 'COMPLETE';
       return;

     end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Upd_TO_Rejected',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Upd_TO_Rejected;


Procedure Check_Null_Planner( itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   out nocopy varchar2 ) is

l_item_id  	   Number ;
l_org_id  	   Number;
l_planner_code     Varchar2(10);
--l_item_name        Varchar2(40);
l_item_name        Varchar2(4000);  --changed the size to 4000 for holding Concatenetaed Segments for Bug# 6936609
l_item_description MTL_SYSTEM_ITEMS_B.DESCRIPTION%TYPE;  -- Added for Bug# 4148672

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
  if (funcmode = 'RUN') then

      l_item_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
               		                         itemkey   => itemkey,
			        		 aname  => 'ITEM_ID');
      l_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
               		                        itemkey   => itemkey,
			        	        aname  => 'ORG_ID');

	/* Commented the select statement from MTL_SYSTEM_ITEMS_KFV AND
	   Selected the values of item name, planner code and description
	   from MTL_SYSTEM_ITEMS_VL which supports MLS.
	   Select Concatenated_segments , planner_code, description -- Description added for Bug# 4148672
             into   l_item_name , l_planner_code, l_item_description -- l_item_description added for Bug# 4148672
             from  MTL_SYSTEM_ITEMS_KFV
             where organization_id = l_org_id and
                   inventory_item_id = l_item_id;*/

	Select
            --segment1,                                --commented segment1 for Bug# 6936609
            CONCATENATED_SEGMENTS,                     --and added CONCATENATED_SEGMENTS for Bug# 6936609
            planner_code, description                  -- Description added for Bug# 4148672
             into   l_item_name , l_planner_code, l_item_description -- l_item_description added for Bug# 4148672
             from  MTL_SYSTEM_ITEMS_VL                  -- Modified the view to MTL_SYSTEM_ITEMS_FVL for Bug# 4148672
             where organization_id = l_org_id and
                   inventory_item_id = l_item_id;


        wf_engine.setitemattrtext( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ITEM_NAME',
                                   avalue   => l_item_name );

        wf_engine.setitemattrtext( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PLANNER_CODE',
                                   avalue   => l_planner_code );
        --
        -- Begin Fix for Bug#4148672
        -- Passing the value of item description to workflow engine to
        -- print the item description in the notification sent to the
        -- planner of the item.
        --
        wf_engine.setitemattrtext( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ITEM_DESC',
                                   avalue   => l_item_description );

        --
        -- End Fix for Bug#4148672
        --
       if ( l_planner_code IS NULL ) then
          result := 'COMPLETE:Y';
       else
          result := 'COMPLETE:N';
       end if;

    return;
   end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
      result := '';
      return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Null_Planner',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Check_Null_Planner;


Procedure Requestor_Is_Planner( itemtype in  varchar2,
                        	itemkey  in  varchar2,
                        	actid    in  number,
                     		funcmode in  varchar2,
                       		result   out nocopy varchar2 ) is
l_requestor_id  Number;
l_planner_code  Varchar2(10);
l_org_id        Number;
l_planner_id    Number;
x_planner_username    varchar2(30);
x_planner_disp_name   varchar2(80);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then

      l_requestor_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname  => 'REQUESTOR_ID');

      l_planner_code :=  wf_engine.GetItemAttrText( itemtype  => itemtype,
                                                    itemkey   => itemkey,
                                                    aname  => 'PLANNER_CODE');

      l_org_id :=  	wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                      itemkey   => itemkey,
                                                      aname  => 'ORG_ID');

          select employee_id
          into l_planner_id
          from MTL_PLANNERS
          where planner_code = l_planner_code and
                organization_id = l_org_id;

       wf_engine.setitemattrNumber(  itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname     => 'PLANNER_ID',
                                     avalue    => l_planner_id );

       /* Bug #2416309
        * Populate the Forward To User Id, Forward To Username and Forward To Display Name
        * irrespective of whether the requestor is the planner. This is done so that
        * the From Role of the "Line Approved" message is set to the Planner's user name
        * and display name. This value is displayed as "From" in the "Move Order Line
        * Approved" notification
        */
  	wf_directory.GetUserName( p_orig_system    => 'PER',
                            p_orig_system_id => l_planner_id,
                            p_name           => x_planner_username,
                            p_display_name   => x_planner_disp_name);

        wf_engine.setitemattrNumber( itemtype => itemtype,
                      itemkey  => itemkey,
                      aname    => 'FORWARD_TO_ID',
                      avalue   => l_planner_id  );

	wf_engine.setitemattrtext( itemtype => ItemType,
                      itemkey  => ItemKey,
                      aname    => 'FORWARD_TO_USERNAME',
                      avalue   => x_planner_username);

	wf_engine.setitemattrtext( itemtype => ItemType,
                      itemkey  => ItemKey,
                      aname    => 'FORWARD_TO_DISPLAY_NAME',
                      avalue   => x_planner_disp_name );

        IF (l_planner_id = l_requestor_id) THEN
          result := 'COMPLETE:Y';
        ELSE
          result := 'COMPLETE:N';
        END IF;

   return;
  end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Requestor_Is_Planner',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Requestor_Is_Planner;


Procedure Timeout_Action( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
l_org_id  	 Number;
l_timeout_action Number;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then
         l_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname  => 'ORG_ID');
         Select nvl(MO_APPROVAL_tIMEOUT_ACTION,1)
         Into l_timeout_action
         From MTL_PARAMETERS
         Where organization_id = l_org_id;

      	 if ( l_timeout_action = 1 ) then
      		result := 'COMPLETE:APPROVED';
		return;
      	 else
       		result := 'COMPLETE:REJECTED';
		return;
         end if;
     end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','TimeOut_Action',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;
End TimeOut_Action;


Procedure Upd_Line_Approve( itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2 ) is
    l_Line_id   Number;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_line_status NUMBER;

Begin
     if (funcmode = 'RUN') then

       l_line_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname  => 'LINE_ID');

       -- Bug #5462193, added the code below so that cancelled line is not approved
       select line_status
         into l_line_status
         from mtl_txn_request_lines
         where line_id = l_line_id;


       IF l_line_status = INV_GLOBALS.G_TO_STATUS_PENDING_APPROVAL THEN
         Inv_trolin_Util.Update_Row_Status(l_Line_id ,
                                       INV_Globals.G_TO_STATUS_APPROVED);
       END IF;
       result := 'COMPLETE';
       return;
    end if;

     if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
     else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Upd_Line_Approve',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Upd_Line_Approve;

Procedure Upd_Line_Reject( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
    l_Line_id  Number ;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
    l_line_status NUMBER;
Begin
     if (funcmode = 'RUN') then

       l_line_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                 itemkey   => itemkey,
                                                 aname  => 'LINE_ID');

       -- Bug #5462193, added the code below so that cancelled line is not approved
       select line_status
         into l_line_status
         from mtl_txn_request_lines
         where line_id = l_line_id;

       IF l_line_status = INV_GLOBALS.G_TO_STATUS_PENDING_APPROVAL THEN
         Inv_trolin_Util.Update_Row_Status(l_Line_id ,
                                       INV_Globals.G_TO_STATUS_REJECTED);
       END IF;
       result := 'COMPLETE';

     end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Upd_Line_Reject',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Upd_Line_Reject;

Procedure Compute_Timeout( itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2 ) is
l_org_id  Number;
l_timeout_period Number;
l_mfg_cal_date   Date;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
     if (funcmode = 'RUN') then

      l_org_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname  => 'ORG_ID');
      Select nvl(TXN_APPROVAL_TIMEOUT_PERIOD,0)
      Into l_timeout_period
      From MTL_PARAMETERS
      Where
      organization_id = l_org_id;

      Select c1.calendar_date
      into l_mfg_cal_date
      from mtl_parameters o,
           bom_calendar_dates c1,
           bom_calendar_dates c
        where o.organization_id   = l_org_id
        and   c1.calendar_code    = c.calendar_code
        and   c1.exception_set_id = c.exception_set_id
        and   c1.seq_num          = (nvl(c.seq_num,c.next_seq_num) + l_timeout_period)
        and   c.calendar_code     = o.CALENDAR_CODE
        and   c.exception_set_id  = o.CALENDAR_EXCEPTION_SET_ID
        and   c.calendar_date     = trunc(sysdate);


      l_timeout_period := trunc(l_mfg_cal_date) - trunc(sysdate);

      wf_engine.setitemattrNumber( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'APPROVAL_TIMEOUT',
                                   avalue   => l_timeout_period  );
       result := 'COMPLETE';

     end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
       result := '';
       return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Compute_Timeout',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;
End Compute_Timeout;


Procedure More_TO_Lines( itemtype in  varchar2,
                         itemkey  in  varchar2,
                         actid    in  number,
                         funcmode in  varchar2,
                         result   out nocopy varchar2 ) is

l_header_id    		Number;
l_current_line  	Number := 0;
l_total_lines           Number := 0;
l_from_notify_role      Varchar2(20);
l_to_notify_role        Varchar2(20);
l_org_id                Number;
l_trolin_tbl          	INV_Move_Order_PUB.Trolin_Tbl_Type;
From_locator_value      Varchar2(200);
To_locator_value        Varchar2(200);
l_planner_code          Varchar2(10); --bug9315598

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
 if (funcmode = 'RUN') then

       l_header_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname  => 'TO_HEADER_ID');

       l_org_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                itemkey   => itemkey,
                                                aname  => 'ORG_ID');

    l_trolin_tbl := INV_trolin_util.Get_Lines( l_header_id );
    l_total_lines := l_trolin_tbl.count;


    wf_engine.setItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'TOTAL_LINES',
                                 avalue   => l_total_lines );

    l_current_line := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
                                                   itemkey   => itemkey,
                                                   aname  => 'CURRENT_LINE');

    l_current_line := nvl(l_current_line,0) + 1;

    if ( ( l_current_line <= l_total_lines ) AND
         ( l_trolin_tbl(l_current_line).line_status =
                                 INV_Globals.G_TO_STATUS_APPROVED ) ) then
        wf_engine.setitemattrNumber( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'LINE_NUMBER',
                        avalue   => l_trolin_tbl(l_current_line).line_number );

        wf_engine.setitemattrNumber( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'LINE_QUANTITY',
                        avalue   => l_trolin_tbl(l_current_line).quantity );
--INVCONV
      	wf_engine.setitemattrNumber( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'SEC_LINE_QTY',
                        avalue   => l_trolin_tbl(l_current_line).secondary_quantity );

        wf_engine.setitemattrtext( itemtype => itemtype,
                           itemkey  => itemkey,
                           aname    => 'SEC_UOM',
                           avalue   => l_trolin_tbl(l_current_line).secondary_uom );
--INVCONV

        wf_engine.setitemattrtext( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'FROM_SUBINVENTORY',
                        avalue   =>
                         l_trolin_tbl(l_current_line).from_subinventory_code );

        from_locator_value := INV_UTILITIES.get_conc_segments(l_org_id,l_trolin_tbl(l_current_line).from_locator_id);

        wf_engine.setitemattrtext( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'FROM_LOCATOR',
                        avalue   => from_locator_value);

        wf_engine.setitemattrtext( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'TO_SUBINVENTORY',
                        avalue   =>
                           l_trolin_tbl(l_current_line).to_subinventory_code );

        to_locator_value := INV_UTILITIES.get_conc_segments(l_org_id,l_trolin_tbl(l_current_line).to_locator_id);

         wf_engine.setitemattrtext( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'TO_LOCATOR',
                        avalue   => to_locator_value);

         wf_engine.setitemattrtext( itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'UOM',
                        avalue   => l_trolin_tbl(l_current_line).uom_code );

        wf_engine.setitemattrNumber( itemtype => itemtype,
                   itemkey  => itemkey,
                   aname    => 'ITEM_ID',
                   avalue   => l_trolin_tbl(l_current_line).inventory_item_id );

        wf_engine.setitemattrdate( itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'DATE_REQUIRED',
                    avalue   => l_trolin_tbl(l_current_line).date_required );

        wf_engine.setItemAttrNumber( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'CURRENT_LINE',
                                     avalue   => l_current_line );
      Begin
        select  NOTIFY_LIST
        into    l_to_notify_role
        from    mtl_secondary_inventories_fk_v
        where   SECONDARY_INVENTORY_NAME =
                         l_trolin_tbl(l_current_line).to_subinventory_code and
                organization_id = l_org_id;
     Exception
        when others then
             l_to_notify_role := NULL;
     End;

        wf_engine.setItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'TO_NOTIFY_ROLE',
                                   avalue   => l_to_notify_role );

      Begin
        select  NOTIFY_LIST
        into    l_from_notify_role
        from    mtl_secondary_inventories_fk_v
        where   SECONDARY_INVENTORY_NAME =
                       l_trolin_tbl(l_current_line).from_subinventory_code and
                organization_id = l_org_id;
      Exception
        when Others then
             l_from_notify_role := Null;
      End;

        wf_engine.setItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'FROM_NOTIFY_ROLE',
                                   avalue   => l_from_notify_role );

        --bug9315598 add planner_code to line level, to make sure approver name appears in line approved notification
        Select planner_code
             into   l_planner_code
             from  MTL_SYSTEM_ITEMS_KFV
             where organization_id = l_org_id and
                   inventory_item_id = l_trolin_tbl(l_current_line).inventory_item_id;

        wf_engine.setitemattrtext( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'PLANNER_CODE',
                                   avalue   => l_planner_code );
        --end9315598


         result := 'COMPLETE:Y';
     else
         result := 'COMPLETE:N';
     end if;
   return;
 end if;

  if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
  else
       result := '';
       return;

  end if;

exception
   when others then
        wf_core.context('INVTROAP','More_TO_Lines',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;
End More_TO_Lines;


Procedure Check_To_Sub_Roles( itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2 ) is

l_sub_role  Varchar2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
  if (funcmode = 'RUN') then

      l_sub_role :=  wf_engine.GetItemAttrText( itemtype  => itemtype,
               		                        itemkey   => itemkey,
			        	 	aname  => 'TO_NOTIFY_ROLE');

       if ( l_sub_role IS NULL ) then
          result := 'COMPLETE:Y';
       else
          result := 'COMPLETE:N';
       end if;

    return;
   end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
      result := '';
      return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Check_To_Sub_Roles',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Check_To_Sub_Roles;

Procedure Check_From_Sub_Roles( itemtype in  varchar2,
                                itemkey  in  varchar2,
                                actid    in  number,
                                funcmode in  varchar2,
                                result   out nocopy varchar2 ) is

l_sub_role  Varchar2(100);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
  if (funcmode = 'RUN') then

      l_sub_role :=  wf_engine.GetItemAttrText( itemtype  => itemtype,
               		                        itemkey   => itemkey,
			        	 	aname  => 'FROM_NOTIFY_ROLE');

       if ( l_sub_role IS NULL ) then
          result := 'COMPLETE:Y';
       else
          result := 'COMPLETE:N';
       end if;

    return;
   end if;

    if ( funcmode = 'CANCEL') then

       result := 'COMPLETE';
       return;
    else
      result := '';
      return;

    end if;

    exception
        when others then
           wf_core.context('INVTROAP','Check_From_Sub_Roles',itemtype,itemkey,
                            to_char(actid),funcmode);
           raise;

End Check_From_Sub_Roles;


Procedure Selector( itemtype in  varchar2,
                    itemkey  in  varchar2,
                    actid    in  number,
                    command  in  varchar2,
                    result   out nocopy varchar2 ) is
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
Begin
      If ( command = 'RUN' ) then
         result := 'APPROVE_TRANSFER_ORDER';
         return;
      end if;

Exception
      When Others then
         WF_CORE.CONTEXT('INVTROAP','Selector',itemtype,itemkey,
                          to_char(actid),command);
        raise;
End Selector;


END INVTROAP;

/
