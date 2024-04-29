--------------------------------------------------------
--  DDL for Package Body GHR_WF_PD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_WF_PD_PKG" AS
/* $Header: ghwfpd.pkb 115.8 2004/02/12 15:49:48 vravikan ship $ */
--
-- Procedure
--	StartPDProcess
--
-- Description
--	Start the PD workflow process for the given p_position_description_id
--
PROCEDURE StartPDProcess
(	p_position_description_id in number,
      p_item_key in varchar2,
	p_forward_to_name in varchar2
) is
--
l_ItemType                    varchar2(30)  := 'OF8';
l_ItemKey                     ghr_pd_routing_history.item_key%TYPE := p_item_key ;
l_from_name                   varchar2(500);
l_forward_from_display_name	varchar2(100);
l_load_form				varchar2(100);
l_load_pdrh				varchar2(100);
l_category				ghr_position_descriptions.category%TYPE;
l_occupational_code		ghr_pd_classifications.occupational_code%TYPE;
l_grade_level			ghr_pd_classifications.grade_level%TYPE;
l_official_title			ghr_pd_classifications.official_title%TYPE;

--
l_pay_plan                    ghr_pd_classifications.pay_plan%TYPE;
l_current_status              ghr_pd_routing_history.action_taken%TYPE;
l_date_initiated              varchar2(15);
l_date_received               varchar2(15);
l_routing_group               varchar2(500);
--
begin
	-- Creates a new runtime process for an application item (OF8)
	--
	wf_engine.createProcess( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey,
					 process  => 'OF8' );
	--
	--
	wf_engine.SetItemAttrText  ( itemtype	=> l_ItemType,
			      		itemkey  	=> l_Itemkey,
  		 	      		aname 	=> 'PD_ID',
			      		avalue	=> p_position_description_id );
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
				     		itemkey  => l_itemkey,
				     		aname    => 'FWD_NAME',
				     		avalue   => p_forward_to_name );
	l_load_form := 'GHRWSPDI:p_position_description_id=' || p_position_description_id
                      || ' p_inbox_query_only="NO"';
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LOAD_PD',
			     			avalue   => l_load_form
					 );
	l_load_pdrh := 'GHRWSPDH:p_position_description_id =' || p_position_description_id;
	wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'LOAD_PDRH',
			     			avalue   => l_load_pdrh
					 );
      --
   		ghr_wf_pd_pkg.SetDestinationDetails (
                                                p_position_description_id  => p_position_description_id,
						p_from_name                => l_from_name,
								p_category          => l_category,
								p_occupational_code => l_occupational_code,
								p_grade_level       => l_grade_level,
								p_official_title    => l_official_title,
                                                p_current_status    => l_current_status,
                                                p_pay_plan          => l_pay_plan,
                                                p_routing_group     => l_routing_group,
                                                p_date_inititated   => l_date_initiated,
                                                p_date_received     => l_date_received
					    		      );
--
--
--
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'FROM_NAME',
			     			avalue   => l_from_name
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'CATEGORY',
			     			avalue   => l_category
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'OCCUPATIONAL_CODE',
			     			avalue   => l_occupational_code
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'GRADE_LEVEL',
			     			avalue   => l_grade_level
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'OFFICIAL_TITLE',
			     			avalue   => l_official_title
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'PAY_PLAN',
			     			avalue   => l_pay_plan
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'ROUTING_GROUP',
			     			avalue   => l_routing_group
						 );

            l_date_initiated := fnd_date.date_to_displaydate(sysdate);
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'DATE_INITIATED',
			     			avalue   => l_date_initiated
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'DATE_RECEIVED',
			     			avalue   => l_date_received || ' / ' || l_date_initiated
						 );
		wf_engine.SetItemAttrText(  	itemtype => l_itemtype,
			     			itemkey  => l_itemkey,
			     			aname    => 'CURRENT_STATUS',
			     			avalue   => l_current_status
						 );
--
--
	-- Start the PD workflow process for Position Description WF process
	--
	wf_engine.StartProcess ( ItemType => l_ItemType,
					 ItemKey  => l_ItemKey );
	--
	--
	--
end StartPDProcess;
--
--
PROCEDURE UpdateRHistoryProcess( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in OUT NOCOPY varchar2) is
--
--
l_position_description_id     ghr_position_descriptions.position_description_id%TYPE;
l_result VARCHAR2(4000);
--
begin
	-- NOCOPY Changes
	l_result := result;
	if funcmode = 'RUN' then
            l_position_description_id := wf_engine.GetItemAttrText (
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'PD_ID');
		ghr_pdh_api.upd_date_notif_sent (
                                             p_position_description_id => l_position_description_id,
							   p_date_notification_sent => sysdate
						        );
		-- no result needed
	      result := 'COMPLETE';
		return;
     end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    result := l_result;
    wf_core.context('OF8', 'ghr_wf_pd_pkg.UpdateRHistoryProcess',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end UpdateRHistoryProcess;
--
--
--
procedure FindDestination( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in OUT NOCOPY varchar2	) is
--
--
l_user_name        		ghr_pd_routing_history.user_name%TYPE;
l_from_name                     VARCHAR2(500);
l_action_taken			ghr_pd_routing_history.action_taken%TYPE;
l_groupbox_name        		ghr_groupboxes.name%TYPE;
l_category				ghr_position_descriptions.category%TYPE;
l_occupational_code		ghr_pd_classifications.occupational_code%TYPE;
l_official_title			ghr_pd_classifications.official_title%TYPE;
l_grade_level			ghr_pd_classifications.grade_level%TYPE;
--

l_pay_plan                    ghr_pd_classifications.pay_plan%TYPE;
l_current_status              ghr_pd_routing_history.action_taken%TYPE;
l_date_initiated             varchar2(15);
l_date_received               varchar2(15);
l_routing_group               varchar2(500);
l_position_description_id     ghr_position_descriptions.position_description_id%TYPE;
l_result                      Varchar2(4000);
--
begin
--
--
-- NOCOPY CHANGES
l_result := result;
if funcmode = 'RUN' then
--
            l_position_description_id := wf_engine.GetItemAttrText (
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'PD_ID');
		ghr_wf_pd_pkg.SetDestinationDetails (
                                                p_position_description_id  => l_position_description_id,
						p_from_name                => l_from_name,
								p_category          => l_category,
								p_occupational_code => l_occupational_code,
								p_grade_level       => l_grade_level,
								p_official_title    => l_official_title,
                                                p_current_status    => l_current_status,
                                                p_pay_plan          => l_pay_plan,
                                                p_routing_group     => l_routing_group,
                                                p_date_inititated   => l_date_initiated,
                                                p_date_received     => l_date_received
					    		      );

		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'FROM_NAME',
			     			avalue   => l_from_name
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'CATEGORY',
			     			avalue   => l_category
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'OCCUPATIONAL_CODE',
			     			avalue   => l_occupational_code
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'GRADE_LEVEL',
			     			avalue   => l_grade_level
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'OFFICIAL_TITLE',
			     			avalue   => l_official_title
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'PAY_PLAN',
			     			avalue   => l_pay_plan
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'ROUTING_GROUP',
			     			avalue   => l_routing_group
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'DATE_INITIATED',
			     			avalue   => l_date_initiated
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'DATE_RECEIVED',
			     			avalue   => l_date_received
						 );
		wf_engine.SetItemAttrText(  	itemtype => itemtype,
			     			itemkey  => itemkey,
			     			aname    => 'CURRENT_STATUS',
			     			avalue   => l_current_status
						 );
--
--
		ghr_wf_pd_pkg.GetDestinationDetails (
                                                p_position_description_id  => l_position_description_id,
							  	p_action_taken => l_action_taken,
                        		       	p_user_name => l_user_name,
							  	p_groupbox_name => l_groupbox_name
					    		   );
		if l_action_taken in ('CANCELED') then
			result  := 'COMPLETE:CANCELLED';
			return;
		elsif l_action_taken in ('CLASSIFIED','RECLASSIFIED') then
			result := 'COMPLETE:CLASSIFIED';
			return;
		else
			--
			if l_user_name Is Not Null then
				wf_engine.SetItemAttrText(  	itemtype => Itemtype,
							     		itemkey  => Itemkey,
							     		aname    => 'FWD_NAME',
							     		avalue   => l_user_name );
				result := 'COMPLETE:CONTINUE';
				return;
			else

				wf_engine.SetItemAttrText(  	itemtype => Itemtype,
							     		itemkey  => Itemkey,
							     		aname    => 'FWD_NAME',
							     		avalue   => l_groupbox_name );
				result := 'COMPLETE:CONTINUE';
				return;
			end if;
			--
		end if;
--
--
end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
--
--
exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    result := l_result;
    wf_core.context('OF8', 'ghr_wf_pd_pkg.FindDestination',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end FindDestination;
--
--
PROCEDURE GetDestinationDetails (
					  p_position_description_id  in NUMBER,
					  p_action_taken OUT NOCOPY varchar2,
                                          p_user_name OUT NOCOPY varchar2,
					  p_groupbox_name OUT NOCOPY varchar2
					  ) IS

-- Local variables
l_pd_routing_history_id        ghr_pd_routing_history.pd_routing_history_id%TYPE;
l_user_name        		 ghr_pd_routing_history.user_name%TYPE;
l_groupbox_id        		 ghr_pd_routing_history.groupbox_id%TYPE;
l_action_taken			 ghr_pd_routing_history.action_taken%TYPE;
l_groupbox_name        		 ghr_groupboxes.name%TYPE;
--
 cursor csr_pd_routing_history is
        SELECT  max(pd_routing_history_id)
        FROM    ghr_pd_routing_history
        WHERE   position_description_id = p_position_description_id;
--
 cursor csr_pd_routing_details is
	  SELECT action_taken, user_name, groupbox_id
        FROM   ghr_pd_routing_history
        WHERE  pd_routing_history_id = l_pd_routing_history_id;
 cursor csr_groupbox_details is
			SELECT name
			FROM GHR_GROUPBOXES
			WHERE GROUPBOX_ID = l_groupbox_id;
--
--
begin
-- This function will select from routing history table based User/ Groupbox Name which happens.
-- to be the next destination.
--
	  open csr_pd_routing_history;
	  fetch csr_pd_routing_history into l_pd_routing_history_id;
	  if csr_pd_routing_history%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_pd_routing_history;
	  --
	  --  Get Routing Details
	  open csr_pd_routing_details;
	  fetch csr_pd_routing_details into l_action_taken, l_user_name, l_groupbox_id;
	  if csr_pd_routing_details%notfound then
		null;
	      --  ?? Check with ****
		--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
		--          hr_utility.raise_error;
	  end if;
        close csr_pd_routing_details;
--
--
--
    	  if l_action_taken not in ('CANCELED','CLASSIFIED','RECLASSIFIED')
                         or l_action_taken Is Null then
	  	if l_user_name is not null then
			p_user_name	   := l_user_name;
		else
		      open csr_groupbox_details;
		      fetch csr_groupbox_details into l_groupbox_name;
			p_groupbox_name  := l_groupbox_name;
		  if csr_groupbox_details%notfound then
			null;
	      	--  ?? Check with ****
			--		hr_utility.set_message(8301,'GHR_38211_NOA_FAMILY_NOTFOUND');
			--          hr_utility.raise_error;
		  end if;
	        close csr_groupbox_details;
		end if;
	  elsif l_action_taken in ('CANCELED','CLASSIFIED','RECLASSIFIED') then
			p_action_taken := l_action_taken;
	  else
			p_action_taken := null;
	  end if;
--
--
EXCEPTION
    WHEN OTHERS THEN
         p_action_taken  := NULL;
         p_user_name     := NULL;
         p_groupbox_name := NULL;
END GetDestinationDetails;
--
PROCEDURE SetDestinationDetails (
					  p_position_description_id  in NUMBER,
					  p_from_name OUT NOCOPY VARCHAR2,
					  p_category OUT NOCOPY varchar2,
					  p_occupational_code OUT NOCOPY varchar2,
					  p_grade_level OUT NOCOPY varchar2,
					  p_official_title OUT NOCOPY varchar2,
                                p_current_status OUT NOCOPY varchar2,
                                p_pay_plan OUT NOCOPY varchar2,
                                p_routing_group OUT NOCOPY varchar2,
                                p_date_inititated OUT NOCOPY varchar2,
                                p_date_received OUT NOCOPY varchar2
					  ) is
-- Local variables
l_category				ghr_position_descriptions.category%TYPE;
l_pd_routing_history_id       ghr_pd_routing_history.pd_routing_history_id%TYPE;
l_occupational_code		ghr_pd_classifications.occupational_code%TYPE;
l_grade_level			ghr_pd_classifications.grade_level%TYPE;
l_pd_classification_id		ghr_pd_classifications.pd_classification_id%TYPE;
l_full_name				per_people_f.full_name%TYPE;
l_description			ghr_routing_groups.description%TYPE;
l_name		     		varchar2(240);
l_official_title			ghr_pd_classifications.official_title%TYPE;
--
l_pay_plan                    ghr_pd_classifications.pay_plan%TYPE;
l_action_taken                ghr_pd_routing_history.action_taken%TYPE;
l_date_initiated              ghr_pd_routing_history.date_notification_sent%TYPE;
l_date_received               ghr_pd_routing_history.date_notification_sent%TYPE;
l_date_notification_sent      ghr_pd_routing_history.date_notification_sent%TYPE;
--
l_routing_group_id            ghr_position_descriptions.routing_group_id%TYPE;
l_routing_group_name          ghr_routing_groups.name%TYPE;
l_count                       integer;
--
--
 cursor csr_pd_details is
	SELECT category, routing_group_id
	FROM ghr_position_descriptions
	WHERE position_description_id = p_position_description_id;
--
 cursor csr_pdc is
		SELECT count(*)
		FROM ghr_pd_classifications
		WHERE position_description_id = p_position_description_id;
--
 cursor csr_pd_classification_details (l_class_grade_by in varchar2) is
		SELECT occupational_code, grade_level, official_title, pay_plan
		FROM ghr_pd_classifications
		WHERE position_description_id = p_position_description_id
            and   class_grade_by = l_class_grade_by;
--
--
 cursor csr_rgps is
            SELECT name, description
            FROM ghr_routing_groups
            WHERE routing_group_id = l_routing_group_id;
--
cursor csr_get_routing_details is
            SELECT action_taken, date_notification_sent from  ghr_pd_routing_history
            where position_description_id = p_position_description_id
            order by  pd_routing_history_id desc;
--
begin
-- This function will set the Workflow notification message attributes at each hop
--
-- Get from the category from PD table

      open csr_pd_details;
	fetch csr_pd_details into l_category, l_routing_group_id;
	if csr_pd_details%notfound then
          hr_utility.set_message(8301,'GHR_PD_ID_PRIMARY_KEY_INVALID');
          hr_utility.raise_error;
	end if;
      close csr_pd_details;
      if l_routing_group_id Is Not Null then
          open csr_rgps;
          fetch csr_rgps into l_routing_group_name, l_description;
          if csr_rgps%notfound then
              hr_utility.set_message(8301,'GHR_38050_INV_ROUTING_GROUP');
              hr_utility.raise_error;
          end if;
          close csr_rgps;
      end if;
      open csr_pdc;
      fetch csr_pdc into l_count;
      if (not (csr_pdc%notfound)) and (l_count >= 1 ) then
        --
        -- Office of Personnel Management
	  open csr_pd_classification_details ('01');
        fetch csr_pd_classification_details into
             l_occupational_code, l_grade_level, l_official_title, l_pay_plan;
        --
             if csr_pd_classification_details%notfound then
                -- Department, Agency, or Establishment
                close csr_pd_classification_details;
                open csr_pd_classification_details ('25');
                fetch csr_pd_classification_details into
                     l_occupational_code, l_grade_level, l_official_title, l_pay_plan;
                --
                if csr_pd_classification_details%notfound then
                  -- Second Level Review
                  close csr_pd_classification_details;
                  open csr_pd_classification_details ('50');
                  fetch csr_pd_classification_details into
                        l_occupational_code, l_grade_level, l_official_title, l_pay_plan;
                  --
                  if csr_pd_classification_details%notfound then
                    -- First Level Review
                    close csr_pd_classification_details;
                    open csr_pd_classification_details ('75');
                    fetch csr_pd_classification_details into
                          l_occupational_code, l_grade_level, l_official_title, l_pay_plan;
                    --
                    if csr_pd_classification_details%notfound then
                      -- Recommended by Supervisor or Initiating Office
                      close csr_pd_classification_details;
                      open csr_pd_classification_details ('99');
                      fetch csr_pd_classification_details into
                            l_occupational_code, l_grade_level, l_official_title, l_pay_plan;
                    end if;
                    --
                  end if;
                --
                end if;
              --
              end if;
              -- Close cursor this assumes that there is atleast one PDC record
              close csr_pd_classification_details;
              close csr_pdc;
    end if;
    --
    --
    -- Set out params
    p_from_name     := FND_GLOBAL.USER_NAME();
    p_routing_group := l_routing_group_name || ' - ' || l_description;
    p_category      := l_category;
    p_occupational_code := l_occupational_code;
    p_grade_level := l_grade_level;
    p_official_title := l_official_title;
    p_pay_plan := l_pay_plan;
    -- Get Routing Details
    l_count := 0;
    -- Open cursor
    open csr_get_routing_details;
    loop
          fetch csr_get_routing_details into l_action_taken, l_date_notification_sent;
          exit when csr_get_routing_details%NOTFOUND;
          if l_count = 0 then
             p_current_status := l_action_taken;
             p_date_received  := fnd_date.date_to_displaydate(sysdate);
             l_count := 1;
          end if;
          --
          if l_count = 1 and l_action_taken Is Not Null then
              p_current_status := l_action_taken;
              l_count := 2;
          end if;
          --
          if l_action_taken in ('REOPENED','INITIATED') then
             if l_date_notification_sent Is Not Null then
                p_date_inititated := fnd_date.date_to_displaydate(l_date_notification_sent);
                exit;
             end if;
          end if;
   end loop;
   close csr_get_routing_details;
--
EXCEPTION
    WHEN OTHERS THEN
           p_from_name         := NULL;
 	   p_category          := NULL;
	   p_occupational_code := NULL;
	   p_grade_level       := NULL;
	   p_official_title    := NULL;
           p_current_status    := NULL;
           p_pay_plan          := NULL;
           p_routing_group     := NULL;
           p_date_inititated   := NULL;
           p_date_received     := NULL;
END SetDestinationDetails;
--
--
procedure CompleteBlockingOfPD ( p_position_description_id in Number) is
--
--
l_Item_Key      ghr_pd_routing_history.item_key%TYPE;
--
 cursor csr_pdh is
        SELECT  max(to_number(item_key))
        FROM    ghr_pd_routing_history
        WHERE   position_description_id = p_position_description_id;
--
begin
	  open csr_pdh;
	  fetch csr_pdh into l_item_key;
	  if csr_pdh%notfound then
		hr_utility.set_message(8301,'GHR_PD_ID_PRIMARY_KEY_INVALID');
		hr_utility.raise_error;
        else
	      wf_engine.CompleteActivity('OF8', l_item_key, 'GH_NOTIFY_PD','COMPLETE');
        end if;
        close csr_pdh;
--
end;
--
--
PROCEDURE get_routing_group_details (
                                    p_user_name          IN     fnd_user.user_name%TYPE
                                   ,p_position_description_id IN
                                      ghr_position_descriptions.position_description_id%TYPE
                                   ,p_routing_group_id   IN OUT NOCOPY NUMBER
                                   ,p_initiator_flag     IN OUT NOCOPY VARCHAR2
                                   ,p_requester_flag     IN OUT NOCOPY VARCHAR2
                                   ,p_authorizer_flag    IN OUT NOCOPY VARCHAR2
                                   ,p_personnelist_flag  IN OUT NOCOPY VARCHAR2
                                   ,p_approver_flag      IN OUT NOCOPY VARCHAR2
                                   ,p_reviewer_flag      IN OUT NOCOPY VARCHAR2) IS
CURSOR cur_rgr IS
-- Routing Group details
  SELECT pei.pei_information3 routing_group_id
        ,pei.pei_information4 initiator_flag
        ,pei.pei_information5 requester_flag
        ,pei.pei_information6 authorizer_flag
        ,pei.pei_information7 personnelist_flag
        ,pei.pei_information8 approver_flag
        ,pei.pei_information9 reviewer_flag
  FROM   per_people_extra_info  pei
        ,fnd_user               use
  WHERE use.user_name = p_user_name
  AND   pei.person_id = use.employee_id
  AND   pei.information_type = 'GHR_US_PER_WF_ROUTING_GROUPS'
  AND   pei.pei_information3  = (SELECT routing_group_id from
                                 GHR_POSITION_DESCRIPTIONS
                                 WHERE position_description_id = p_position_description_id);

-- NOCOPY CHANGES
l_routing_group_id    NUMBER(20);
l_initiator_flag      VARCHAR2(100);
l_requester_flag      VARCHAR2(100);
l_authorizer_flag     VARCHAR2(100);
l_personnelist_flag   VARCHAR2(100);
l_approver_flag       VARCHAR2(100);
l_reviewer_flag       VARCHAR2(100);

BEGIN
   -- NOCOPY CHANGES
   l_routing_group_id    := p_routing_group_id;
   l_initiator_flag      := p_initiator_flag;
   l_requester_flag      := p_requester_flag;
   l_authorizer_flag     := p_authorizer_flag;
   l_personnelist_flag   := p_personnelist_flag;
   l_approver_flag       := p_approver_flag;
   l_reviewer_flag       := p_reviewer_flag;

  -- while we are here we may as well get the personal roles even though this maybe overwriten
  -- by the group box roles later
  FOR cur_rgr_rec IN cur_rgr LOOP
    p_routing_group_id   := cur_rgr_rec.routing_group_id;
    p_initiator_flag     := cur_rgr_rec.initiator_flag;
    p_requester_flag     := cur_rgr_rec.requester_flag;
    p_authorizer_flag    := cur_rgr_rec.authorizer_flag;
    p_personnelist_flag  := cur_rgr_rec.personnelist_flag;
    p_approver_flag      := cur_rgr_rec.approver_flag;
    p_reviewer_flag      := cur_rgr_rec.reviewer_flag;
  END LOOP;
EXCEPTION
         -- NOCOPY CHANGES
   WHEN OTHERS THEN
           p_routing_group_id    := l_routing_group_id;
	   p_initiator_flag      := l_initiator_flag;
	   p_requester_flag      := l_requester_flag;
	   p_authorizer_flag     := l_authorizer_flag;
	   P_personnelist_flag   := l_personnelist_flag;
	   p_approver_flag       := l_approver_flag;
	   p_reviewer_flag       := l_reviewer_flag;

END get_routing_group_details;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< item_attribute_exists >------------------------|
-- ----------------------------------------------------------------------------
function item_attribute_exists
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_name      in wf_item_attributes_tl.name%type)
  return boolean is
  -- --------------------------------------------------------------------------
  -- declare local variables
  -- --------------------------------------------------------------------------
  l_dummy  number(1);
  l_return boolean := TRUE;
  -- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;
--
  --
begin
  -- open the cursor
  open csr_wiav;
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    -- item attribute does not exist so return false
    l_return := FALSE;
  end if;
  close csr_wiav;
  return(l_return);
end item_attribute_exists;
--
--
PROCEDURE CheckIfPDWfEnd ( itemtype	in varchar2,
				   itemkey  in varchar2,
				   actid	in number,
				   funcmode	in varchar2,
				   result	in OUT NOCOPY varchar2) is
--
--
l_action_taken			 ghr_pd_routing_history.action_taken%TYPE;
l_position_description_id     ghr_position_descriptions.position_description_id%TYPE;
l_load_form				varchar2(100);
l_result                       VARCHAR2(4000);
--
 cursor csr_pdh is
        SELECT  action_taken
        FROM    ghr_pd_routing_history
        WHERE   position_description_id = l_position_description_id
        order by  pd_routing_history_id desc;
--
begin
        -- NOCOPY CHANGES
        l_result := result;
	if funcmode = 'RUN' then
        l_position_description_id := wf_engine.GetItemAttrText (
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'PD_ID');
	  open csr_pdh;
	  fetch csr_pdh into l_action_taken;
	  if csr_pdh%notfound then
		hr_utility.set_message(8301,'GHR_PD_ID_PRIMARY_KEY_INVALID');
		hr_utility.raise_error;
	  end if;
        close csr_pdh;
        l_load_form := 'GHRWSPDI:p_position_description_id=' || l_position_description_id
                      || ' p_inbox_query_only="YES"';
        wf_engine.SetItemAttrText(     itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'PD_FORM_RO',
                                       avalue   => l_load_form
                                  );
        --
	  if l_action_taken in ('CLASSIFIED','RECLASSIFIED') then
			result  := 'COMPLETE:YES';
			return;
        else
			result  := 'COMPLETE:NO';
			return;
        end if;
     end if;
  --
  -- Other execution modes may be created in the future.
  -- Activity indicates that it does not implement a mode
  -- by returning null
  --
  result := '';
  return;
exception
  when others then
    result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OF8', 'ghr_wf_pd_pkg.CheckIfPDWfEnd',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end CheckIfPDWfEnd;
--
--
--
PROCEDURE EndPDProcess( itemtype	in varchar2,
				  itemkey  	in varchar2,
				  actid	in number,
				  funcmode	in varchar2,
				  result	in OUT NOCOPY varchar2) is
l_result VARCHAR2(4000);
begin
    -- NOCOPY CHANGES
    l_result := result;
    if funcmode = 'RUN' then
        result := 'COMPLETE:COMPLETED';
        return;
    end if;
      --
      -- Other execution modes may be created in the future.
      -- Activity indicates that it does not implement a mode
      -- by returning null
      --
      result := '';
      return;
--
exception
  when others then
      result := l_result;
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OF8', 'ghr_wf_pd_pkg.EndPDProcess',itemtype, itemkey, to_char(actid), funcmode);
    raise;
--
end EndPDProcess;
--
--
end ghr_wf_pd_pkg;

/
