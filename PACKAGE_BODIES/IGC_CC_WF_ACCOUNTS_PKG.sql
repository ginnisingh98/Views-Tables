--------------------------------------------------------
--  DDL for Package Body IGC_CC_WF_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_WF_ACCOUNTS_PKG" AS
/* $Header: IGCCWFCB.pls 120.2.12000000.1 2007/08/20 12:15:10 mbremkum ship $ */
--
-- is_encumbrance_on
--

procedure is_encumbrance_on   ( itemtype        in  varchar2,
                                itemkey         in  varchar2,
                                actid           in number,
                                funcmode        in  varchar2,
                                result          out NOCOPY varchar2    )
is
        cc_encumbrance_flag     varchar2(4);
        l_error_msg             varchar2(200);
begin

  l_error_msg := 'IGC_CC_WF_ACCOUNTS_PKG.is_encumbrance_on: 01';

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode = 'CANCEL') then

      null;
      return;

  end if;

  if (funcmode = 'TIMEOUT') then

      null;
      return;

  end if;

  if (funcmode = 'RUN') then

  cc_encumbrance_flag   :=  wf_engine.GetItemAttrText (  itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'CC_ENCUMBRANCE_FLAG');

  if (cc_encumbrance_flag = 'Y' ) then
        result := 'COMPLETE:TRUE';
  else
        result := 'COMPLETE:FALSE';
  end if;

  l_error_msg := 'IGC_CC_WF_ACCOUNTS_PKG.is_encumbrance_on: result = ' || result;

  end if;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('IGC_CC_WF_ACCOUNTS_PKG','is_encumbrace_on', l_error_msg);
        raise;

end is_encumbrance_on;

-- * **************************************************** *

--
-- is_cc_project_related
--
-- This is a dummy function that should be replaced by the customized function
-- activity in the workflow that return TRUE or FALSE based on whether you want to
-- use the default CC charge account generation rules or use "CUSTOMIZED"
-- project accounting rules.

procedure is_cc_project_related      (  itemtype        in  varchar2,
                                        itemkey         in  varchar2,
                                        actid           in number,
                                        funcmode        in  varchar2,
                                        result          out NOCOPY varchar2    )
is

cc_project_id	Number;

begin

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode = 'CANCEL') then

      null;
      return;

  end if;

  if (funcmode = 'TIMEOUT') then

      null;
      return;

  end if;

  if (funcmode = 'RUN') then

  cc_project_id   :=  wf_engine.GetItemAttrNumber (      itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                         aname    => 'PROJECT_ID');
    If (cc_project_id IS NOT NULL ) Then

        result := 'COMPLETE:TRUE';
    Else
        result := 'COMPLETE:FALSE';

    End If;

  end if;

        return;

end is_cc_project_related;

--
--
procedure   get_charge_account       (  itemtype        in  varchar2,
                                        itemkey         in  varchar2,
                                        actid           in number,
                                        funcmode        in  varchar2,
                                        result          out NOCOPY varchar2    )
is
        l_ccid          NUMBER;
        l_error_msg     varchar2(100);
begin

  -- get code_combination_id from item attribute

  l_ccid      := wf_engine.GetItemAttrNumber ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CHARGE_ACCOUNT_ID');

  if (l_ccid IS NOT NULL) then

        wf_engine.SetItemAttrNumber ( itemtype=>itemtype,
                                      itemkey=>itemkey,
                                      aname=>'TEMP_ACCOUNT_ID',
                                      avalue=>l_ccid );

        result := 'COMPLETE:SUCCESS';
  else
        result := 'COMPLETE:FAILURE';
  end if;

  l_error_msg := 'IGC_CC_WF_ACCOUNTS_PKG.get_charge_account : result = ' || result;

  return;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('IGC_CC_WF_ACCOUNTS_PKG','get_charge_account',l_error_msg);
        raise;
end get_charge_account;

----
--
-- This API is called from the CC default account generator process. This
-- API simply returns an error message specifying that the default process is
-- being used without proper customization.
--

procedure No_Process_Defined (    itemtype      IN  VARCHAR2,
                                  itemkey       IN  VARCHAR2,
                                  actid         IN  NUMBER,
                                  funcmode      IN  VARCHAR2,
                                  result        OUT NOCOPY VARCHAR2 )
IS
  --
  l_error_msg         VARCHAR2(2000);
  --
BEGIN

  IF funcmode <> 'RUN' THEN
    result := null;
    RETURN;
  END IF;

  fnd_message.set_name('IGC', 'IGC_NO_AG_PROCESS_DEFINED') ;
  l_error_msg := fnd_message.get_encoded ;

  wf_engine.SetItemAttrText( itemtype     => itemtype,
                             itemkey      => itemkey,
                             aname        => 'ERROR_MESSAGE',
                             avalue       => l_error_msg
                           );

  result := 'COMPLETE:FAILURE';
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('IGC_CC_WF_ACCOUNTS_PKG','No_Process_Defined', l_error_msg);
        raise;

END No_Process_Defined ;


END IGC_CC_WF_ACCOUNTS_PKG;

/
