--------------------------------------------------------
--  DDL for Package Body HXC_SEEDED_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_SEEDED_APPROVAL_WF" AS
/* $Header: hxcseedaw.pkb 120.2 2005/09/23 06:27:25 nissharm noship $ */

g_pkg constant varchar2(30) := 'hxc_seeded_approval_wf';

g_debug boolean := hr_utility.debug_enabled;

procedure do_approval_logic(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc  varchar2(61);
begin
    g_debug := hr_utility.debug_enabled;

    if g_debug then
    	l_proc := g_pkg || '.' || 'do_approval_logic';
    	hr_utility.set_location(l_proc, 10);
    	hr_utility.trace('p_funcmode is >' || p_funcmode || '<');
    	hr_utility.trace('p_itemtype is >' || p_itemtype || '<');
    	hr_utility.trace('p_itemkey is >' || p_itemkey || '<');
    end if;
    --
    -- p_result := 'APPROVED';
    --
    p_result := 'REJECTED';
    --
    if g_debug then
    	hr_utility.set_location(l_proc, 90);
    end if;
exception
    when others then
        if g_debug then
        	hr_utility.trace('sqlcode>' || sqlcode || '<');
        	hr_utility.trace('sqlerrm>' || sqlerrm || '<');
        end if;
        --
        -- record this function call in the error system in case of an exception
        --
        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
            p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end do_approval_logic;


procedure approved(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc  varchar2(61);
    l_item_type         hxc_approval_comps.wf_item_type%type;
    l_item_key          number;
begin
    g_debug := hr_utility.debug_enabled;

    if g_debug then
    	l_proc := g_pkg || '.' || 'approved';
    	hr_utility.set_location(l_proc, 10);
    	hr_utility.trace('p_funcmode is >' || p_funcmode || '<');
    end if;

    l_item_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'PARENT_ITEM_TYPE');

    l_item_key := wf_engine.GetItemAttrText( itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'PARENT_ITEM_KEY');

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'WF_APPROVAL_RESULT',
                              avalue   => 'APPROVED');

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'APR_REJ_REASON',
                              avalue   => 'Approved by Seeded Workflow');

    p_result := 'COMPLETE';

    if g_debug then
    	hr_utility.set_location(l_proc, 90);
    end if;
exception
    when others then
        if g_debug then
        	hr_utility.trace('sqlcode>' || sqlcode || '<');
        	hr_utility.trace('sqlerrm>' || sqlerrm || '<');
        end if;
        --
        -- record this function call in the error system in case of an exception
        --
        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
            p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end approved;

procedure rejected(
    p_itemtype in     varchar2,
    p_itemkey  in     varchar2,
    p_actid    in     number,
    p_funcmode in     varchar2,
    p_result   in out nocopy varchar2)
is
    l_proc  varchar2(61);
    l_item_type         hxc_approval_comps.wf_item_type%type;
    l_item_key          number;
begin
    g_debug := hr_utility.debug_enabled;

    if g_debug then
    	l_proc := g_pkg || '.' || 'rejected';
    	hr_utility.set_location(l_proc, 10);
    	hr_utility.trace('p_funcmode is >' || p_funcmode || '<');
    end if;

    l_item_type := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'PARENT_ITEM_TYPE');

    l_item_key := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                            itemkey  => p_itemkey,
                                            aname    => 'PARENT_ITEM_KEY');

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'WF_APPROVAL_RESULT',
                              avalue   => 'REJECTED');

    wf_engine.SetItemAttrText(itemtype => l_item_type,
                              itemkey  => l_item_key,
                              aname    => 'APR_REJ_REASON',
                              avalue   => 'Rejected by Seeded Workflow');

    p_result := 'COMPLETE';
    --
    if g_debug then
    	hr_utility.set_location(l_proc, 90);
    end if;
exception
    when others then
        if g_debug then
        	hr_utility.trace('sqlcode>' || sqlcode || '<');
        	hr_utility.trace('sqlerrm>' || sqlerrm || '<');
        end if;
        --
        -- record this function call in the error system in case of an exception
        --
        wf_core.context(g_pkg, substr(l_proc, instr(l_proc, '.') + 1),
            p_itemtype, p_itemkey, to_char(p_actid), p_funcmode);
        raise;
end rejected;

end hxc_seeded_approval_wf;

/
