--------------------------------------------------------
--  DDL for Package Body MRP_MSC_EXP_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_MSC_EXP_WF" AS
/*$Header: MRPAPWFB.pls 120.0.12010000.1 2008/07/28 04:46:56 appldev ship $ */

PROCEDURE CheckUser(itemtype  in varchar2,
                             itemkey   in varchar2,
                             actid     in number,
                             funcmode  in varchar2,
                             resultout out NOCOPY varchar2) is

  l_user_type     varchar2(20) :=
    wf_engine.GetActivityAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 actid    => actid,
                                 aname    => 'USER_TYPE');
  l_planner  varchar2(50) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'PLANNER');

-- skanta
  l_salesrep varchar2(30) :=
              wf_engine.GetItemAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'SALESREP');
  l_order_type          number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_TYPE_CODE');

  l_exception_type    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EXCEPTION_TYPE_ID');

  l_salesrep_name varchar2(320);
  l_user_name varchar2(50);
  l_msg varchar2(30);

  CURSOR c_salesrep is
    select a.name
    from wf_roles a,
         jtf_rs_salesreps b
    where a.orig_system = 'PER'
    and  a.orig_system_id = b.person_id
    and  b.salesrep_id = to_number(l_salesrep)
    and  a.status = 'ACTIVE'
    and  rownum = 1;
--
BEGIN
  if (funcmode = 'RUN') then
     l_user_name    :=
       wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => l_user_type);

     if (l_user_name is null) then
        resultout := 'COMPLETE:NOT_FOUND';
        return;
     else
 -- skanta
       IF (l_exception_type in (13,15,24,25,49,70)) then
          IF (l_salesrep is not null) then
            OPEN c_salesrep;
            FETCH c_salesrep INTO l_salesrep_name;
            CLOSE c_salesrep;

             IF l_salesrep_name is NOT NULL THEN
                wf_engine.SetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'SALESREP',
                               avalue   => l_salesrep_name);
             END IF;
          END IF;
       END IF;
       l_msg := GetMessageName(l_exception_type,
                            l_order_type,
                            l_user_type);
       wf_engine.SetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'MESSAGE_NAME',
                               avalue   => l_msg);

        resultout := 'COMPLETE:FOUND';
        return;
     end if;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;
EXCEPTION
  when others then
    wf_core.context('MRP_MSC_EXP_WF', 'CheckUser', itemtype, itemkey, actid, funcmode);
    raise;
END CheckUser;

PROCEDURE CheckPartner(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_partner_type     varchar2(20) :=
    wf_engine.GetActivityAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 actid    => actid,
                                 aname    => 'PARTNER_TYPE');

  l_order_type          number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'ORDER_TYPE_CODE');

  l_exception_type    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EXCEPTION_TYPE_ID');

  l_msg varchar2(30);
  l_partner_name varchar2(50);
BEGIN
  if (funcmode = 'RUN') then
     l_partner_name :=
       wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => l_partner_type);

     if (l_partner_name is null) then
        resultout := 'COMPLETE:NOT_FOUND';
        return;
     else
        l_msg := GetMessageName(l_exception_type,
                            l_order_type,
                            l_partner_type);
        wf_engine.SetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'MESSAGE_NAME',
                               avalue   => l_msg);
        resultout := 'COMPLETE:FOUND';
        return;
     end if;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;
EXCEPTION
  when others then
    wf_core.context('MRP_MSC_EXP_WF', 'CheckPartner', itemtype, itemkey, actid, funcmode);
    raise;
END CheckPartner;

PROCEDURE IsType19( itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2) is

  l_exception_type      number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'EXCEPTION_TYPE_ID');

BEGIN
  if (funcmode = 'RUN') then
    if (l_exception_type = 19) then
      resultout := 'COMPLETE:Y';
    else
      resultout := 'COMPLETE:N';
    end if;
    return;
  end if;

  if (funcmode = 'CANCEL') then
    resultout := 'COMPLETE:';
    return;
  end if;

  if (funcmode = 'TIMEOUT') then
    resultout := 'COMPLETE:';
    return;
  end if;
EXCEPTION
  when others then
    wf_core.context('MRP_MSC_EXP_WF', 'IsType19', itemtype, itemkey, actid, funcmode);
    raise;
END IsType19;


-- call back a wf process at destition instance for completion
PROCEDURE CallbackDestWF(itemtype  in varchar2,
                       itemkey   in varchar2,
                       actid     in number,
                       funcmode  in varchar2,
                       resultout out NOCOPY varchar2) is

  l_result     varchar2(20) :=
    wf_engine.GetActivityAttrText( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 actid    => actid,
                                 aname    => 'SR_RESULT');

  l_db_link     varchar2(30) :=
    wf_engine.GetItemAttrText( itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'APPS_PS_DBLINK');

  l_exception_type    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'EXCEPTION_TYPE_ID');

  l_transaction_id    number :=
    wf_engine.GetItemAttrNumber( itemtype => itemtype,
				 itemkey  => itemkey,
			         aname    => 'TRANSACTION_ID');

  l_dest_item_type varchar2(50) := 'MSCEXPWF';
  l_dest_item_key varchar2(100);
  l_dest_process varchar2(50);
  l_text varchar2(200);
  l_numb number;
  l_date Date;
  sql_stmt varchar2(2000);
  p_request_id number :=0;
BEGIN
  if (funcmode = 'RUN') then
     l_dest_item_key := substr(itemkey,1,instr(itemkey,'-',-2)-1)
                         || '-CALLBACK';

     -- now find out call back process, and start it.
     if (l_exception_type in (1, 2, 3, 12, 14, 16, 20, 26, 27)) then
            l_dest_process := 'EXCEPTION_PROCESS1';
     elsif (l_exception_type in (28, 37)) then
            l_dest_process := 'EXCEPTION_PROCESS5';
     elsif (l_exception_type in (6, 7, 8, 9, 10)) then
            l_dest_process := 'EXCEPTION_PROCESS2';
     elsif (l_exception_type in (13, 15, 24, 25)) then
            l_dest_process := 'EXCEPTION_PROCESS3';
     elsif (l_exception_type in (17, 18, 19)) then
            l_dest_process := 'EXCEPTION_PROCESS4';
     end if;
     sql_stmt := 'begin wf_engine.CreateProcess' || l_db_link ||
                  '( itemtype => :l_itemtype,' ||
                  'itemkey  => :l_itemkey, ' ||
                  'process   => :l_process);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type, l_dest_item_key,
                                       l_dest_process;

     -- now copy attributes to destination wf process
     -- we could only copy those insterested attributes,
     -- but we copy all for debug purpose.

     -- SR_RESULT.
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SR_RESULT'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_result;

     -- EXCEPTION_TYPE_ID.
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_TYPE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_exception_type;

     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TRANSACTION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_transaction_id;

     -- APPS_PS_DBLINK
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''APPS_PS_DBLINK'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_db_link;

     --BUYER. we don't need to set back BUYER, set it for debug
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'BUYER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''BUYER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- we don't need to set back CUSTCNT, for debug only
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTCNT');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTCNT'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- customer_name
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTOMER_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTOMER_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- customer_ID.
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CUSTOMER_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CUSTOMER_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- Days_compressed
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DAYS_COMPRESSED');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DAYS_COMPRESSED'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- DB_LINK. we may not need.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DB_LINK');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DB_LINK'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- DEPARTMENT_LINE_CODE.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DEPARTMENT_LINE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DEPARTMENT_LINE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- due_date.
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'DUE_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''DUE_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_date;

     -- end_item_display_name.
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ITEM_DISPLAY_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ITEM_DISPLAY_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

   -- end_item_description

   l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ITEM_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ITEM_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;


     --END_ORDER_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'END_ORDER_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''END_ORDER_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- EXCEPTION_DESCRIPTION
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXCEPTION_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     --EXCEPTION_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'EXCEPTION_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''EXCEPTION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- FROM_DATE
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'FROM_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''FROM_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_date;

     -- FROM_PRJ_MGR
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'FROM_PRJ_MGR');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''FROM_PRJ_MGR'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     --INSTANCE_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'INSTANCE_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''INSTANCE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     --INVENTORY_ITEM_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'INVENTORY_ITEM_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''INVENTORY_ITEM_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     --IS_CALL_BACK
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''IS_CALL_BACK'',' ||
              ' avalue   => ''Y'');end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key;

     -- ITEM_DISPLAY_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ITEM_DISPLAY_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ITEM_DISPLAY_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

   -- ITEM_DESCRIPTION
   l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ITEM_DESCRIPTION');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ITEM_DESCRIPTION'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- LOT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'LOT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''LOT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- ORDER_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORDER_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORDER_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- ORDER_TYPE_CODE
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORDER_TYPE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORDER_TYPE_CODE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- ORGANIZATION_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORGANIZATION_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORGANIZATION_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     --ORGANIZATION_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'ORGANIZATION_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''ORGANIZATION_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     --PLAN_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLAN_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- PLAN_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLAN_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLAN_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- PLANNER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLANNER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLANNER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- PLANNING_GROUP
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PLANNING_GROUP');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PLANNING_GROUP'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- PROJECT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PROJECT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PROJECT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

   --PRE_PROCESSING_LEAD_TIME
   l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PRE_PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PRE_PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

   -- PROCESSING_LEAD_TIME
   l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

  -- POST_PROCESSING_LEAD_TIME
  l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'POST_PRSNG_LEAD_TIME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''POST_PRSNG_LEAD_TIME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;


     -- QUANTITY
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''QUANTITY'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- RESOURCE_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'RESOURCE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''RESOURCE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- SUPCNT
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPCNT');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPCNT'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     --SUPPLIER_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- SUPPLIER_NAME
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_NAME');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_NAME'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- SUPPLIER_SITE_CODE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_SITE_CODE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_SITE_CODE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     --SUPPLIER_SITE_ID
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLIER_SITE_ID');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLIER_SITE_ID'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

     -- SUPPLY_TYPE
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'SUPPLY_TYPE');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''SUPPLY_TYPE'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- TASK_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TASK_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TASK_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- TO_DATE
     l_date :=  wf_engine.GetItemAttrDate( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_DATE');
     sql_stmt := 'begin wf_engine.SetItemAttrDate' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_DATE'',' ||
              ' avalue   => :l_date);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_date;

     -- TO_PRJ_MGR
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_PRJ_MGR');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_PRJ_MGR'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- TO_PROJECT_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_PROJECT_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_PROJECT_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- TO_TASK_NUMBER
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'TO_TASK_NUMBER');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''TO_TASK_NUMBER'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- URL1
     l_text :=  wf_engine.GetItemAttrText( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'URL1');
     sql_stmt := 'begin wf_engine.SetItemAttrText' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''URL1'',' ||
              ' avalue   => :l_text);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_text;

     -- UTILIZATION_RATE
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'UTILIZATION_RATE');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''UTILIZATION_RATE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

      -- CAPACITY_REQUIREMENT
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'CAPACITY_REQUIREMENT');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''CAPACITY_REQUIREMENT'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

      -- REQUIRED_QUANTITY
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'REQUIRED_QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''REQUIRED_QUANTITY'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

      -- PROJECTED_AVAILABLE_BALANCE
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'PROJECTED_AVAILABLE_BALANCE');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''PROJECTED_AVAILABLE_BALANCE'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

      -- AVAILABLE_QUANTITY
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'AVAILABLE_QUANTITY');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''AVAILABLE_QUANTITY'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

      -- QTY_RELATED_VALUES
     l_numb :=  wf_engine.GetItemAttrNumber( itemtype => itemtype,
                             itemkey  => itemkey,
                             aname    => 'QTY_RELATED_VALUES');
     sql_stmt := 'begin wf_engine.SetItemAttrNumber' || l_db_link ||
              '(itemtype => :item_type,' ||
              ' itemkey  => :item_key,'  ||
              ' aname    => ''QTY_RELATED_VALUES'',' ||
              ' avalue   => :l_numb);end;';
     EXECUTE IMMEDIATE sql_stmt USING l_dest_item_type,l_dest_item_key,l_numb;

  wf_engine.SetItemAttrNumber( itemtype => itemtype,
			       itemkey  => itemkey,
			       aname    => 'REQUEST_ID',
			       avalue   => p_request_id);

     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  IF (funcmode = 'CANCEL') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;

  IF (funcmode = 'TIMEOUT') THEN
     resultout := 'COMPLETE:';
     RETURN;
  END IF;
EXCEPTION
  when others then
    wf_core.context('MSC_EXP_WF', 'StartSrWF', itemtype, itemkey, actid, funcmode);
    raise;
END CallbackDestWF;

FUNCTION GetMessageName(p_exception_type in number,
                        p_order_type     in number,
                        p_recipient      in varchar2) RETURN varchar2 IS
BEGIN
  if (p_recipient = 'BUYER') then
    if (p_exception_type = 6) then
      if (p_order_type = 1) then
        return 'MSG_6_PO';
      elsif (p_order_type = 2) then
        return 'MSG_6_REQ';
      end if;
    elsif (p_exception_type = 7) then
      if (p_order_type = 1) then
         return 'MSG_7_PO';
      elsif (p_order_type = 2) then
         return 'MSG_7_REQ';
      end if;
    elsif (p_exception_type = 8) then
      if (p_order_type = 1) then
        return 'MSG_8_PO';
      elsif (p_order_type = 2) then
        return 'MSG_8_REQ';
      end if;
    elsif (p_exception_type =10) then
       return 'MSG_10';
    elsif (p_exception_type =37) then
        return 'MSG_37';
    elsif (p_exception_type =28) then
        return 'MSG_28';
    elsif (p_exception_type = 9) then
      if (p_order_type = 1) then
         return  'MSG_9_PO';
      elsif (p_order_type = 2) then
         return 'MSG_9_REQ';
      end if;
    end if;
  elsif (p_recipient = 'SUPCNT') then
    if (p_exception_type = 6) then
      return 'MSG_RESCHEDULE_6_PO';
    elsif (p_exception_type = 7) then
      return 'MSG_RESCHEDULE_7_PO';
    elsif (p_exception_type = 8) then
      return 'MSG_RESCHEDULE_8_PO';
    elsif (p_exception_type = 9) then
      return 'MSG_RESCHEDULE_9_PO';
    elsif (p_exception_type = 10) then
      return 'MSG_RESCHEDULE_10';
    elsif (p_exception_type in (28, 37)) then
      return 'MSG_37_CHANGE';
    end if;
  elsif (p_recipient = 'SALESREP' or p_recipient = 'CUSTCNT') then
    if (p_exception_type = 13) then
      return 'MSG_13';
    elsif (p_exception_type in (15,24,25)) then
      return 'MSG_15';
    elsif (p_exception_type = 49) then
       if (p_order_type=30) then
        return 'MSG_49_SO';
       elsif (p_order_type=29) then
       return 'MSG_49_FORECAST';
       end if;
    elsif (p_exception_type = 70) then
       if (p_order_type=-30) then -- release sales order
          return 'MSG_RL_SO';
       else
          return 'MSG_70';
       end if;
    end if;
  elsif (p_recipient = 'FROM_PRJ_MGR' or p_recipient = 'TO_PRJ_MGR') then
    if (p_exception_type = 17) then
      return 'MSG_17';
    elsif (p_exception_type = 18) then
      return 'MSG_18';
    elsif (p_exception_type = 19) then
      return 'MSG_19';
    end if;
  end if;
EXCEPTION

  when others then
    wf_core.context('MSC_EXP_WF', 'GetMessageName', to_char(p_exception_type),
         to_char(p_order_type));
    raise;

END GetMessageName;

PROCEDURE DeleteActivities( arg_plan_id in number) IS

    TYPE DelExpType is REF CURSOR;
  delete_activities_c DelExpType;
l_item_key		varchar2(240);
  sql_stmt              varchar2(500);
  l_item_type           varchar2(20);
BEGIN

    l_item_type := 'MRPEXWFS';
     sql_stmt := ' SELECT item_key ' ||
                ' FROM wf_items' ||
                ' WHERE item_type = :l_item_type' ||
                ' AND   item_key like '''|| to_char(arg_plan_id) || '-%''';

    OPEN delete_activities_c for sql_stmt using l_item_type;
    LOOP

        FETCH DELETE_ACTIVITIES_C INTO l_item_key;
        EXIT WHEN DELETE_ACTIVITIES_C%NOTFOUND;

        -- Later on, add logic to first check if the exception is on
        -- other instances before doing this, by exception type or
        -- other api
        update wf_notifications
         set    end_date = sysdate
         where  group_id in
          (select notification_id
          from wf_item_activity_statuses
          where item_type = 'MRPEXWFS'
          and item_key = l_item_key
          union
          select notification_id
          from wf_item_activity_statuses_h
          where item_type = 'MRPEXWFS'
          and item_key = l_item_key);

        update wf_items
         set end_date = sysdate
         where item_type = 'MRPEXWFS'
         and item_key = l_item_key;

        update wf_item_activity_statuses
         set end_date = sysdate
         where item_type = 'MRPEXWFS'
         and item_key = l_item_key;

        update wf_item_activity_statuses_h
         set end_date = sysdate
         where item_type = 'MRPEXWFS'
         and item_key = l_item_key;

        wf_purge.total('MRPEXWFS',l_item_key,sysdate);

      END LOOP;
      CLOSE delete_activities_c;
  return;

EXCEPTION
  when others then
    msc_util.msc_debug('Error in delete activities:'|| to_char(sqlcode) || ':'
    || substr(sqlerrm,1,100));

      return;
END DeleteActivities;

Procedure launch_background_program(p_planner in varchar2,
                                    p_item_type in varchar2,
                                    p_item_key in varchar2,
                                    p_request_id out NOCOPY number) IS
  p_result boolean;
  p_user_id number;
  p_resp_id number;
  p_app_id number;

Begin

     select user_id
       into p_user_id
       from fnd_user
      where user_name = p_planner;

      SELECT APPLICATION_ID
        INTO p_app_id
        FROM FND_APPLICATION_VL
       WHERE APPLICATION_NAME = 'Oracle Manufacturing' ;

      SELECT responsibility_id
        INTO p_resp_id
        FROM FND_responsibility_vl
        where application_Id = p_app_id
          and rownum = 1;
   fnd_global.apps_initialize(p_user_id, p_resp_id, p_app_id);

    p_result := fnd_request.set_mode(true);

   -- this will call start_deferred_activity
    p_request_id := fnd_request.submit_request(
                         'MSC',
                         'MSCWFBG',
                         null,
                         null,
                         false,
                         p_item_type,
                         p_item_key);

exception when others then
 p_request_id :=0;
 raise;
End launch_background_program;

Procedure start_deferred_activity(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                           p_item_type varchar2,
                           p_item_key varchar2) IS
BEGIN
      FND_FILE.PUT_LINE(FND_FILE.LOG,
           'start workflow process for '||p_item_type);

      FND_FILE.PUT_LINE(FND_FILE.LOG,
           'key='||p_item_key);

    wf_engine.StartProcess( itemtype => p_item_type,
			    itemkey  => p_item_key);

      FND_FILE.PUT_LINE(FND_FILE.LOG,
           'done for'||p_item_type);
END start_deferred_activity;
PROCEDURE start_substitute_workflow(from_item varchar2,
                         substitute_item varchar2,
                         order_number varchar2,
                         line_number varchar2,
                         org_code varchar2,
                         substitute_org varchar2,
                         quantity number,
                         substitute_qty number,
                         sales_rep varchar2,
                         customer_contact varchar2) IS
  l_process varchar2(50) := 'MSC_SO_SR_PROCESS';
  item_type varchar2(50) :='MRPEXWFS';
  item_key varchar2(50);
  p_text varchar2(80) := 'ATP:Demand satisfied by substituting end items';
BEGIN

  select to_char(mrp_form_query_s.nextval)
    into item_key
   from dual;

  wf_engine.CreateProcess( itemtype => item_type,
			    itemkey  => item_key,
                             process => l_process);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'EXCEPTION_TYPE_ID',
			       avalue   => 49);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ORGANIZATION_CODE',
			     avalue   => org_code);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'ITEM_DISPLAY_NAME',
			     avalue   => from_item);
  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'EXCEPTION_DESCRIPTION',
			     avalue   => p_text);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'QUANTITY',
			     avalue   => quantity);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ITEM_DISPLAY_NAME',
			     avalue   => substitute_item);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'END_ORDER_NUMBER',
			     avalue   => order_number);

  wf_engine.SetItemAttrText( itemtype => item_type,
			     itemkey  => item_key,
			     aname    => 'RESOURCE_CODE',
			     avalue   => substitute_org);

  wf_engine.SetItemAttrNumber( itemtype => item_type,
			       itemkey  => item_key,
			       aname    => 'UTILIZATION_RATE',
			       avalue   => substitute_qty);

  wf_engine.setItemAttrText( itemtype => item_type,
                                       itemkey => item_key,
                                       aname => 'CUSTCNT',
                                       avalue => customer_contact);

  wf_engine.setItemAttrText( itemtype => item_type,
                                       itemkey => item_key,
                                       aname => 'SALESREP',
                                       avalue => sales_rep);

    wf_engine.StartProcess( itemtype => item_type,
			    itemkey  => item_key);


END start_substitute_workflow;


END mrp_msc_exp_wf;

/
