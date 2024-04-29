--------------------------------------------------------
--  DDL for Package Body HR_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPROVAL_WF" as
/* $Header: hrapprwf.pkb 120.0 2005/05/30 22:44:37 appldev noship $ */
-- ---------------------------------------------------------------------------
-- private package global declarations
-- ---------------------------------------------------------------------------
  g_package                 constant varchar2(31) := 'hr_approval_wf.';

  --
  -- returns the supervisor id for the person id passed into the cursor.
  cursor g_csr_pa(l_effective_date in date
               ,l_in_person_id   in per_people_f.person_id%type) is
  select  ppf.person_id
    from    per_assignments_f paf
           ,per_people_f      ppf
    where   paf.person_id             = l_in_person_id
    and     paf.primary_flag          = 'Y'
    and     (paf.assignment_type = 'E' and ppf.current_employee_flag = 'Y'
          or paf.assignment_type = 'C' and ppf.current_npw_flag = 'Y')
    and     sysdate
    between paf.effective_start_date
    and     paf.effective_end_date
    and     ppf.person_id             = paf.supervisor_id
    and     sysdate
    between ppf.effective_start_date
    and     ppf.effective_end_date;

  -- returns a email address for the person id passed into the cursor.
  CURSOR g_csr_email_address(l_effective_date in date
                ,p_person_id in per_people_f.person_id%type) IS
    SELECT  email_address
    FROM    per_people_f pp
    WHERE   pp.person_id = p_person_id
    AND     l_effective_date
    between pp.effective_start_date
    and     pp.effective_end_date;
  --
  -- returns vacancy info
  CURSOR g_csr_vacancies(p_vacancy_id in number) IS
    SELECT recruiter_id,job_id
    FROM   per_vacancies pv
    WHERE  pv.vacancy_id = p_vacancy_id;

  --
  g_vacancies       g_csr_vacancies%rowtype;
--
--
-- ---------------------------------------------------------------------------
-- private procedure declarations
-- ---------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |------------------------------< set_custom_wf_globals >-------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure sets the customized global variables with the standard wf
-- values
--
procedure set_custom_wf_globals
  (p_itemtype in varchar2
  ,p_itemkey  in varchar2) is
begin
  hr_approval_custom.g_itemtype := p_itemtype;
  hr_approval_custom.g_itemkey  := p_itemkey;
end set_custom_wf_globals;
--
-- --------------------------------------------------------------------
-- |------------------------< Set_Routing_Details >--------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attributes
--  APPROVAL_ROUTING_PERSON_ID<p_router_index>
--  APPROVAL_ROUTING_USERNAME<p_router_index>
--  APPROVAL_ROUTING_DISPLAY_NAME<p_router_index>
--  for a given p_routerr_index
--
procedure Set_Routing_Details
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_approval_routing_id   in per_people_f.person_id%type
    ,p_router_index in number) is
--
l_approval_routing_username wf_users.name%type;
l_approval_routing_disp_name    wf_users.display_name%type;
--
begin
--
    wf_directory.GetUserName(p_orig_system      => 'PER'
                ,p_orig_system_id   => p_approval_routing_id
                ,p_name         => l_approval_routing_username
                ,p_display_name     => l_approval_routing_disp_name);
    --
    wf_engine.SetItemAttrNumber (itemtype   => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'APPROVAL_ROUTING_PERSON_ID'||p_router_index,
                avalue      => p_approval_routing_id ) ;


    wf_engine.SetItemAttrText (itemtype => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'APPROVAL_ROUTING_USERNAME'||p_router_index,
                avalue      => l_approval_routing_username );
    --
    wf_engine.SetItemAttrText (itemtype => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'APPROVAL_ROUTING_DISPLAY_NAME'
                                   ||p_router_index,
                avalue      => l_approval_routing_disp_name );
    --
--
end Set_Routing_Details;
-- ------------------------------------------------------------------------
-- |------------------------------< Set_URL >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  This procedure will set the item attribute
--  APPROVAL_URL<p_url_index> for a given p_url_index
--  with a given p_url
--
--
procedure Set_URL
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_url       in     varchar2
    ,p_url_index in number) is
--

begin
--
    --
    -- Set item attributes for the URL
    --
    wf_engine.SetItemAttrText(itemtype  => p_item_type,
                    itemkey     => p_item_key,
                    aname       => 'APPROVAL_URL'||p_url_index,
                    avalue      => p_url);
--
end  Set_URL;
--
-- --------------------------------------------------------------------
-- |--------------------< create_item_attrib_if_notexist >---------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure checks to see if an item attribute exists. If it does
--  not the one is created
--
procedure create_item_attrib_if_notexist
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_name      in     varchar2) is
--
    l_dummy  number(1);
  -- cursor determines if an attribute exists
  cursor csr_wiav is
    select 1
    from   wf_item_attribute_values wiav
    where  wiav.item_type = p_item_type
    and    wiav.item_key  = p_item_key
    and    wiav.name      = p_name;
  --
begin
  -- open the cursor to determine if the a
  open csr_wiav;
  fetch csr_wiav into l_dummy;
  if csr_wiav%notfound then
    --
    -- item attribute does not exist so create it
      wf_engine.additemattr
        (itemtype => p_item_type
        ,itemkey  => p_item_key
        ,aname    => p_name);
  end if;
  close csr_wiav;
  --
end create_item_attrib_if_notexist;
--
--
-- ---------------------------------------------------------------------------
-- public procedure declarations
-- ---------------------------------------------------------------------------
--
--
-- ---------------------------------------------------------------------------
-- |-------------------------< intialize_item_attributes >--------------------|
-- ---------------------------------------------------------------------------
procedure initialize_item_attributes
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name           varchar2(61) := g_package||'initialise_item_attributes';
  l_person_id               per_people_f.person_id%type;
  l_creator_person_id       per_people_f.person_id%type;
  l_creator_username        wf_users.name%type;
  l_creator_disp_name       wf_users.display_name%type;
  l_candidate_assignment_id per_assignments_f.assignment_id%type;
  l_candidate_person_id     per_people_f.person_id%type;
  l_candidate_disp_name     wf_users.display_name%type;
  l_candidate_appl_number   per_people_f.applicant_number%type;
  l_fwd_from_username       wf_users.name%type;
  l_fwd_from_disp_name      wf_users.display_name%type;
  l_url_index               number default 1;
  l_max_urls                number default 20;
--
begin
  -- check the workflow funmode value
  if funmode = 'RUN' then
    -- workflow is RUNing this procedure
    --
    --
    -- Test that all attributes exist and if they don't create them
    --
        -- APPROVAL_COMMENT
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_COMMENT');
    --
-- Comment by vtakru for MEE process as approval comments set
-- during the mee processes were being reset
--   wf_engine.SetItemAttrText
--     ( itemtype    => itemtype,
--        itemkey     => itemkey,
--        aname       => 'APPROVAL_COMMENT',
--        avalue      => '' );
    --
        -- APPROVAL_COMMENT_COPY
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_COMMENT_COPY');
    --
    --wf_engine.SetItemAttrText
    --  ( itemtype    => itemtype,
    --    itemkey     => itemkey,
    --    aname       => 'APPROVAL_COMMENT_COPY',
    --    avalue      => '' );
    --
        -- FORWARD_FROM_USERNAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_FROM_USERNAME');
    --
        -- FORWARD_FROM_PERSON_ID
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_FROM_PERSON_ID');
    --
        -- FORWARD_FROM_DISPLAY_NAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_FROM_DISPLAY_NAME');
    --
        -- FORWARD_TO_USERNAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_TO_USERNAME');
    --
        -- FORWARD_TO_PERSON_ID
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_TO_PERSON_ID');
    --
        -- FORWARD_TO_DISPLAY_NAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'FORWARD_TO_DISPLAY_NAME');
    --
        -- APPROVAL_CREATOR_USERNAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_CREATOR_USERNAME');
    --
        -- APPROVAL_CREATOR_PERSON_ID
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_CREATOR_PERSON_ID');
    --
        -- APPROVAL_CREATOR_DISPLAY_NAME
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_CREATOR_DISPLAY_NAME');
    --
        -- APPROVAL_ROUTING_USERNAME1
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_USERNAME1');
    --
        -- APPROVAL_ROUTING_PERSON_ID1
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_PERSON_ID1');
    --
        -- APPROVAL_ROUTING_DISPLAY_NAME1
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_DISPLAY_NAME1');
    --
        -- APPROVAL_ROUTING_USERNAME2
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_USERNAME2');
    --
        -- APPROVAL_ROUTING_PERSON_ID2
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_PERSON_ID2');
    --
        -- APPROVAL_ROUTING_DISPLAY_NAME2
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_DISPLAY_NAME2');
    --
        -- APPROVAL_ROUTING_USERNAME3
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_USERNAME3');
    --
        -- APPROVAL_ROUTING_PERSON_ID3
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_PERSON_ID3');
    --
        -- APPROVAL_ROUTING_DISPLAY_NAME3
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_DISPLAY_NAME3');
    --
        -- APPROVAL_ROUTING_USERNAME4
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_USERNAME4');
    --
        -- APPROVAL_ROUTING_PERSON_ID4
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_PERSON_ID4');
    --
        -- APPROVAL_ROUTING_DISPLAY_NAME4
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_DISPLAY_NAME4');
    --
        -- APPROVAL_ROUTING_USERNAME5
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_USERNAME5');
    --
        -- APPROVAL_ROUTING_PERSON_ID5
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_PERSON_ID5');
    --
        -- APPROVAL_ROUTING_DISPLAY_NAME5
    create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_ROUTING_DISPLAY_NAME5');
    --
        -- APPROVAL_URL1 to APPROVAL_URL20
    loop
      exit when l_url_index > l_max_urls;
      create_item_attrib_if_notexist
      (p_item_type  => itemtype
      ,p_item_key   => itemkey
      ,p_name   => 'APPROVAL_URL'||to_char(l_url_index));
      l_url_index := l_url_index + 1;
    end loop;
        --

    -- Set the creator, forward to and forward from attributes
    --
    l_creator_person_id := wf_engine.GetItemAttrNumber
                (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'CREATOR_PERSON_ID' );
    --
    wf_engine.SetItemAttrNumber ( itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname       => 'APPROVAL_CREATOR_PERSON_ID',
                        avalue      => l_creator_person_id );
    --
    wf_directory.GetUserName(   p_orig_system    => 'PER',
                    p_orig_system_id => l_creator_person_id,
                    p_name       => l_creator_username,
                    p_display_name   => l_creator_disp_name );
    --
    wf_engine.SetItemAttrText ( itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'APPROVAL_CREATOR_USERNAME',
                    avalue      => l_creator_username );
    --
    wf_engine.SetItemAttrText ( itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'APPROVAL_CREATOR_DISPLAY_NAME',
                    avalue      => l_creator_disp_name );
    --
    -- Set forward to = creator in case this is the only person in
      -- approval chain.
    --
    --
/*

    wf_engine.SetItemAttrText ( itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'FORWARD_TO_USERNAME',
                    avalue      => l_creator_username );
    --
    wf_engine.SetItemAttrText ( itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'FORWARD_TO_DISPLAY_NAME',
                    avalue      => l_creator_disp_name );
    --
    wf_engine.SetItemAttrNumber (   itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'FORWARD_TO_PERSON_ID',
                    avalue      =>  l_creator_person_id) ;
*/
   -- fix for bug#2677648
     -- FORWARD_TO_DISPLAY_NAME
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => itemtype ,
                               itemkey  => itemkey,
                               aname => 'FORWARD_TO_DISPLAY_NAME',
                               avalue=>null);
     -- FORWARD_TO_USERNAME
     -- set the attribute value to null
        wf_engine.SetItemAttrText(itemtype => itemtype ,
                               itemkey  => itemkey,
                               aname => 'FORWARD_TO_USERNAME',
                               avalue=>null);
     -- FORWARD_TO_PERSON_ID
     -- set the attribute value to null
        wf_engine.SetItemAttrNumber(itemtype => itemtype ,
                               itemkey  => itemkey,
                               aname => 'FORWARD_TO_PERSON_ID',
                               avalue=>null);

    --
    -- Set forward from = creator.  If this creator has no
      -- supervisor, we won't ever call get_next_approver, so we have to
      -- set all the variables for 'forward from'.
    --
    wf_engine.SetItemAttrNumber (   itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'FORWARD_FROM_PERSON_ID',
                    avalue      =>  l_creator_person_id) ;
    --
    wf_engine.SetItemAttrText(      itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'FORWARD_FROM_USERNAME',
                        avalue   => l_creator_username);
    --
    wf_engine.SetItemAttrText(  itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => 'FORWARD_FROM_DISPLAY_NAME',
                        avalue   => l_creator_disp_name );

    -- commented rajayara
    -- Set the APPROVAL_COMMENT_COPY and APPROVAL_COMMENT attribute
    -- to NULL
    --
    -- wf_engine.SetItemAttrText ( itemtype    => itemtype,
    --                     itemkey     => itemkey,
    --                     aname       => 'APPROVAL_COMMENT_COPY',
    --                 avalue      => NULL);
    --
    wf_engine.SetItemAttrText ( itemtype    => itemtype,
                        itemkey     => itemkey,
                        aname       => 'APPROVAL_COMMENT',
                    avalue      => NULL);
    --
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
    --
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    null;
  end if;
end initialize_item_attributes;
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details1 >------------------|
-- --------------------------------------------------------------------
procedure set_routing_details1(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name               varchar2(61) := g_package||'set_routing_details1';
l_creator_person_id         per_people_f.person_id%type;
l_approval_routing_id       per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    l_creator_person_id :=
        wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname   => 'CREATOR_PERSON_ID' );
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the routing id
    --
    l_approval_routing_id := hr_approval_custom.get_routing_details1
           (p_person_id => l_creator_person_id);
    --
    -- Set the routing details
    set_routing_details
        (p_item_type        => itemtype
        ,p_item_key     => itemkey
        ,p_approval_routing_id   => l_approval_routing_id
        ,p_router_index => 1);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_routing_details1;
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details2 >------------------|
-- --------------------------------------------------------------------
procedure set_routing_details2(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name               varchar2(61) := g_package||'set_routing_details2';
l_creator_person_id         per_people_f.person_id%type;
l_approval_routing_id       per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    l_creator_person_id :=
        wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname   => 'CREATOR_PERSON_ID' );
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the routing id
    --
    l_approval_routing_id := hr_approval_custom.get_routing_details2
           (p_person_id => l_creator_person_id);
    --
    -- Set the routing details
    set_routing_details
        (p_item_type        => itemtype
        ,p_item_key     => itemkey
        ,p_approval_routing_id   => l_approval_routing_id
        ,p_router_index => 2);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_routing_details2;
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details3 >------------------|
--  Recruiter - used by Apply for a Job
-- --------------------------------------------------------------------
procedure set_routing_details3(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                 varchar2(61) := g_package||'set_routing_details3';
  l_creator_person_id         per_people_f.person_id%type;
  l_approval_routing_id       per_people_f.person_id%type;
  l_vacancy_id                per_vacancies.vacancy_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    l_creator_person_id :=
        wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname   => 'CREATOR_PERSON_ID' );
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the routing id
    --
    l_approval_routing_id := hr_approval_custom.get_routing_details3
           (p_person_id => l_creator_person_id);
    -- Set the routing details
    set_routing_details
        (p_item_type        => itemtype
        ,p_item_key     => itemkey
        ,p_approval_routing_id   => l_approval_routing_id
        ,p_router_index => 3);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_routing_details3;
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details4 >------------------|
-- --------------------------------------------------------------------
--
-- This routing id is used for the Training Administrator in the
-- Signup for Class workflow notifications.
-- Note if set_routing_details4 changes, set_URL13 should change.
--
--
procedure set_routing_details4(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name               varchar2(61) := g_package||'set_routing_details4';
l_creator_person_id         per_people_f.person_id%type;
l_approval_routing_id       per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    l_creator_person_id :=
        wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname   => 'CREATOR_PERSON_ID' );
        --
        -- get the routing id
        --
    l_approval_routing_id := hr_approval_custom.get_routing_details4
           (p_person_id => l_creator_person_id);
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the routing id
    --
    set_routing_details
        (p_item_type        => itemtype
        ,p_item_key     => itemkey
        ,p_approval_routing_id   => l_approval_routing_id
        ,p_router_index => 4);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_routing_details4;
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details5 >------------------|
-- --------------------------------------------------------------------
procedure set_routing_details5(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                 varchar2(61) := g_package||'set_routing_details5';
  l_creator_person_id         per_people_f.person_id%type;
  l_approval_routing_id       per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    l_creator_person_id :=
        wf_engine.GetItemAttrNumber(itemtype    => itemtype,
                            itemkey     => itemkey,
                            aname   => 'CREATOR_PERSON_ID' );
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the routing id
    --
    l_approval_routing_id := hr_approval_custom.get_routing_details5
           (p_person_id => l_creator_person_id);
    --
    -- Set the routing details
    set_routing_details
        (p_item_type        => itemtype
        ,p_item_key     => itemkey
        ,p_approval_routing_id   => l_approval_routing_id
            ,p_router_index => 5);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_routing_details5;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL1 >---------------------------|
-- --------------------------------------------------------------------
procedure set_URL1(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL1';
  l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL1;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 1);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL1;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL2 >---------------------------|
-- --------------------------------------------------------------------
procedure set_URL2(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL2';
  l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL2;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 2);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL2;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL3 >---------------------------|
-- --------------------------------------------------------------------
procedure set_URL3(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL3';
  l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL3;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 3);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL3;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL4 >---------------------------|
-- --------------------------------------------------------------------
procedure set_URL4(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL4';
l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL4;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 4);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL4;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL5 >---------------------------|
--  View Employee Details - called by Apply for a Job
-- --------------------------------------------------------------------
procedure set_URL5(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL5';
  l_url               varchar2(2000);
  l_person_id       per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL5;
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 5);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL5;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL6 >---------------------------|
--  View Vacancy Details - called by Apply for a Job
-- --------------------------------------------------------------------
procedure set_URL6(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL6';
  l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL6;
    if l_url is null then
      l_url := icx_sec.jumpintofunction
             (p_application_id => 800
             ,p_function_code  => 'PER_CALL_ON_FLOW_FUN'
             ,p_parameter1     => '800*PER_VACANCY_APPLICATION_F*' ||
                                  '800*PER_EMPK_VACANCIES_FP*' ||
                                  '800*PER_EMPK_VACANCIES_R*'||
                      '800*PER_EMPK_VACANCY_DETAILS1_FP*PER_CURVAC_VACID_PK1*]'
             ,p_parameter2     => wf_engine.getitemattrtext
                                    (itemtype   => itemtype,
                                    itemkey    => itemkey,
                                    aname      =>'PARAMETER1') );
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 6);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL6;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL7 >---------------------------|
--  View Job Details - called by Apply for a job
-- --------------------------------------------------------------------
procedure set_URL7(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL7';
  l_url               varchar2(2000);
  l_vacancy_id        per_vacancies.vacancy_id%type;
  l_job_id            per_vacancies.job_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL7;
    if l_url is null then
      l_vacancy_id := to_number(wf_engine.getitemattrtext
                    (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      =>'PARAMETER1'));
      open g_csr_vacancies(l_vacancy_id);
      fetch g_csr_vacancies into g_vacancies;
      close g_csr_vacancies;
      l_url := icx_sec.jumpintofunction
            (p_application_id => 800
            ,p_function_code  => 'PER_CALL_ON_FLOW_FUN'
            ,p_parameter1     => '800*PER_VACANCY_APPLICATION_F*' ||
                                '800*PER_EMPK_VACANCY)_DETAILS_FP*' ||
                                '800*PER_EMPK_VACANCY_DETAILS_R*' ||
                      '800*PER_EMPK_JOB_DETAILS_FP*PER_CURVAC_JOBID_PK2*]'
            ,p_parameter2     => to_char(g_vacancies.job_id));
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 7);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL7;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL8 >---------------------------|
--  Recruiter email - called by Apply for a Job
-- --------------------------------------------------------------------
procedure set_URL8(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL8';
  l_url               varchar2(2000);
  l_email_address     per_people_f.email_address%type;
  l_person_id         per_vacancies.vacancy_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL8;
    if l_url is null then
      l_person_id := wf_engine.getitemattrnumber
                    (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      =>'APPROVAL_ROUTING_PERSON_ID3');
      open g_csr_email_address(trunc(sysdate),l_person_id);
      fetch g_csr_email_address into l_email_address;
      close g_csr_email_address;
      l_url := 'mailto:'||l_email_address;

    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 8);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL8;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL9 >---------------------------|
--  Employee's supervisor email - called by Apply for a Job
-- --------------------------------------------------------------------
procedure set_URL9(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL9';
  l_url               varchar2(2000);
  l_out_person_id     per_people_f.person_id%type default null;
  l_person_id         per_people_f.person_id%type default null;
  l_email_address     per_people_f.email_address%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL9;
    if l_url is null then
      l_person_id := wf_engine.GetItemAttrNumber
                    (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'CREATOR_PERSON_ID' );
      open g_csr_pa(trunc(sysdate), l_person_id);
      fetch g_csr_pa into l_out_person_id;
      if g_csr_pa%found then
        open g_csr_email_address(trunc(sysdate),l_out_person_id);
        fetch g_csr_email_address into l_email_address;
        close g_csr_email_address;
        l_url := 'mailto:'||l_email_address;
      end if;
      close g_csr_pa;
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 9);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL9;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL10 >---------------------------|
--  Employee email - called by Apply for a Job
-- --------------------------------------------------------------------
procedure set_URL10(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL10';
  l_url               varchar2(2000);
  l_person_id         per_people_f.person_id%type default null;
  l_email_address     per_people_f.email_address%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL10;
    if l_url is null then
      l_person_id := wf_engine.GetItemAttrNumber
                    (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'CREATOR_PERSON_ID' );
      open g_csr_email_address(trunc(sysdate),l_person_id);
      fetch g_csr_email_address into l_email_address;
      close g_csr_email_address;
      l_url := 'mailto:'||l_email_address;
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 10);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL10;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL11 >---------------------------|
-- --------------------------------------------------------------------
-- This URL is used for Class (event) details from the Signup for Class
-- workflow notifications.
--
procedure set_URL11(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name         varchar2(61) := g_package||'set_URL11';
  l_url               varchar2(2000);
  l_event_id          ota_events.event_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL11;
    if l_url is null then
      l_event_id := to_number(wf_engine.getitemattrtext
                    (itemtype   => itemtype
                              ,itemkey    => itemkey
                          ,aname      =>'PARAMETER1'));

      -- this is the same URL to link to pages that have the
      -- 'signup' button, except that link has DETAIL instead of DETAIL1
      l_url := icx_sec.jumpintofunction
    (p_application_id  => 800
    ,p_function_code   => 'PER_CALL_ON_FLOW_FUN'
    ,p_parameter1      => '810*OTA_TRAINING_ADMINISTRATION_F*'        ||
                              '810*OTA_SCHEDULED_EVENTS_FP*' ||
                              '810*OTA_SCHEDULED_EVENTS_R*' ||
                              '810*OTA_SCHEDULED_EVENT_DETAIL1_FP*'      ||
                              'OTA_SEV_EVID_PK1*]'
      ,p_parameter2      => to_char(l_event_id)          );
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 11);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL11;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL12 >---------------------------|
-- --------------------------------------------------------------------
--
-- This url is to be used for transitioning to an employee's transcript.
-- It is used in the Signup for Class workflow notifications
--
procedure set_URL12(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name         varchar2(61) := g_package||'set_URL12';
  l_url               varchar2(2000);
  l_person_id         per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL12;
    if l_url is null then
       l_person_id := wf_engine.GetItemAttrNumber
                     (itemtype      => itemtype
                     ,itemkey       => itemkey
                     ,aname         => 'CREATOR_PERSON_ID');

      l_url := icx_sec.jumpintofunction
    (p_application_id  => 800
    ,p_function_code   => 'PER_CALL_ON_FLOW_FUN'
    ,p_parameter1      => '800*PER_HUMAN_RESOURCES_F*'        ||
                              '800*PER_EMPLOYEE_DETAIL_LINKS_FP*' ||
                              '800*PER_EMPLOYEE_DETAILS_LINK3_R*' ||
                              '800*PER_TRAINING_HISTORY_FP*'      ||
                              'PER_PERDET_PER_FK1*]'
      ,p_parameter2      => to_char(l_person_id)          );
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 12);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL12;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL13 >---------------------------|
-- --------------------------------------------------------------------
--
-- This url is used to allow a user to send an email to the Training
-- Administrator.  The default logic should work fine, since the Routing
-- ID4 is what we assume is loaded with the Training Administrator's Id.
-- This is used in the Signup for Class workflow notifications.
-- Note if set_routing_details4 changes, set_URL13 should change.
--
procedure set_URL13(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name          varchar2(61) := g_package||'set_URL13';
  l_url                varchar2(2000);
  l_person_id          per_people_f.person_id%type;
  l_email_address      per_people_f.email_address%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL13;
    if l_url is null then
      l_person_id := wf_engine.GetItemAttrNumber
                    (itemtype   => itemtype,
                     itemkey    => itemkey,
                     aname      => 'APPROVAL_ROUTING_PERSON_ID4');
      open g_csr_email_address(trunc(sysdate),l_person_id);
      fetch g_csr_email_address into l_email_address;
      close g_csr_email_address;
      l_url := 'mailto:'||l_email_address;
    end if;
    --
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 13);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL13;
-- --------------------------------------------------------------------
-- |----------------------------< set_URL14 >---------------------------|
-- --------------------------------------------------------------------
--
-- This URL is used in the Enroll in a Class workflow process.It is the Response
-- URL that the Training Administrator uses to navigate to the Training
-- Administrator Update page.
-- This code does not need to be modified by the customer unless they
-- change which pl/sql procedure is used to call this update page.
--
procedure set_URL14(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name                   varchar2(61) := g_package||'set_URL14';
  l_url               varchar2(2000);
--
begin
--
if ( funmode = 'RUN' ) then
    --
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- get the url
    --
    l_url := hr_approval_custom.get_URL14;
    --
    if l_url is null then
         l_url  :=
    'ota_class_signup_wf.url?'||
    hr_util_web.prepare_parameter
      (p_name   => 'p_item_type'
      ,p_value  => itemtype
      ,p_prefix => FALSE)||
    hr_util_web.prepare_parameter
      (p_name   => 'p_item_key'
      ,p_value  => itemkey);

    end if;
    -- Set the routing details
    set_URL
        (p_item_type    => itemtype
        ,p_item_key => itemkey
        ,p_url      => l_url
        ,p_url_index    => 14);
    -- -----------------------------------------------------------------------
    -- set workflow activity to the SUCCESS state to end workflow
    -- -----------------------------------------------------------------------
    result := 'COMPLETE:SUCCESS';
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
    --
end if;
--
end set_URL14;

-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
procedure Check_Final_Approver( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     ) is
--
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name             varchar2(61) := g_package||'check_final_approver';
l_creator_person_id       per_people_f.person_id%type;
l_forward_to_person_id              per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    --
    --
    l_creator_person_id := wf_engine.GetItemAttrNumber
                     (itemtype      => itemtype
                         ,itemkey       => itemkey
                         ,aname         => 'CREATOR_PERSON_ID');
    --
    l_forward_to_person_id := wf_engine.GetItemAttrNumber
                    (itemtype       => itemtype
                        ,itemkey        => itemkey
                        ,aname          => 'FORWARD_TO_PERSON_ID');
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
      --
      -- call a custom check final approver. Returns a 'Yes', 'No' or 'Error'
      --
      result := 'COMPLETE:'||
                hr_approval_custom.Check_Final_approver
                  (p_forward_to_person_id       => nvl(l_forward_to_person_id,l_creator_person_id)
                  ,p_person_id                  => l_creator_person_id );
    --
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
end if;
end Check_Final_Approver;
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     ) is
--
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_creator_person_id     per_people_f.person_id%type;
  l_forward_from_person_id    per_people_f.person_id%type;
  l_forward_from_username     wf_users.name%type;
  l_forward_from_disp_name    wf_users.display_name%type;
  l_forward_to_person_id      per_people_f.person_id%type;
  l_forward_to_username       wf_users.name%type;
  l_forward_to_disp_name      wf_users.display_name%type;
  l_proc_name                 varchar2(61) := g_package||'get_next_approver';
  l_current_forward_to_id     per_people_f.person_id%type;
  l_current_forward_from_id   per_people_f.person_id%type;
--
begin
--
if ( funmode = 'RUN' ) then
    -- get the current forward from person
    l_current_forward_from_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'FORWARD_FROM_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));
    -- get the current forward to person
    l_current_forward_to_id :=
      nvl(wf_engine.GetItemAttrNumber
            (itemtype => itemtype
            ,itemkey  => itemkey
            ,aname    => 'FORWARD_TO_PERSON_ID'),
          wf_engine.GetItemAttrNumber
            (itemtype   => itemtype
            ,itemkey    => itemkey
            ,aname      => 'CREATOR_PERSON_ID'));
    -- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- set the next forward to
    --
    l_forward_to_person_id :=
      hr_approval_custom.Get_Next_Approver
        (p_person_id => l_current_forward_to_id);
    --
    if ( l_forward_to_person_id is null ) then
        --
        result := 'COMPLETE:F';
        --
    else
        --
        wf_directory.GetUserName
          (p_orig_system    => 'PER'
          ,p_orig_system_id => l_forward_to_person_id
          ,p_name           => l_forward_to_username
          ,p_display_name   => l_forward_to_disp_name);
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'FORWARD_TO_PERSON_ID'
          ,avalue      => l_forward_to_person_id);
        --
        wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_USERNAME'
          ,avalue   => l_forward_to_username);
        --
        Wf_engine.SetItemAttrText
          (itemtype => itemtype
          ,itemkey  => itemkey
          ,aname    => 'FORWARD_TO_DISPLAY_NAME'
          ,avalue   => l_forward_to_disp_name);
        --
        -- set forward from to old forward to
        --
        wf_engine.SetItemAttrNumber
          (itemtype    => itemtype
          ,itemkey     => itemkey
          ,aname       => 'FORWARD_FROM_PERSON_ID'
          ,avalue      => l_current_forward_to_id);
       --
       -- Get the username and display name for forward from person
       -- and save to item attributes
       --
       wf_directory.GetUserName
         (p_orig_system       => 'PER'
         ,p_orig_system_id    => l_current_forward_to_id
         ,p_name              => l_forward_from_username
         ,p_display_name      => l_forward_from_disp_name);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_USERNAME'
        ,avalue   => l_forward_from_username);
      --
      wf_engine.SetItemAttrText
        (itemtype => itemtype
        ,itemkey  => itemkey
        ,aname    => 'FORWARD_FROM_DISPLAY_NAME'
        ,avalue   => l_forward_from_disp_name);
        --
        result := 'COMPLETE:T';
        --
    end if;
    --
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
end if;
--
end Get_next_approver;
-- ------------------------------------------------------------------------
-- |-------------------------< copy_approval_comment >---------------------|
-- ------------------------------------------------------------------------
procedure copy_approval_comment(    itemtype    in varchar2,
                    itemkey     in varchar2,
                    actid       in number,
                    funmode     in varchar2,
                    result      out nocopy varchar2    ) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name           varchar2(61) := g_package||'copy_approval_comment';
begin
--
if ( funmode = 'RUN' ) then
    --
    wf_engine.SetItemAttrText
      (itemtype => itemtype,
       itemkey      => itemkey,
       aname    => 'APPROVAL_COMMENT_COPY',
       avalue   => wf_engine.GetItemAttrText
                 (itemtype      => itemtype,
                  itemkey       => itemkey,
                  aname         => 'APPROVAL_COMMENT'));
    --
elsif ( funmode = 'CANCEL' ) then
    --
    null;
    --
end if;
--
end copy_approval_comment;
-- ---------------------------------------------------------------------------
-- |-------------------------< set_current_person_to_creator >----------------|
-- ---------------------------------------------------------------------------
procedure set_current_person_to_creator
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_proc_name  varchar2(61) := g_package||'set_current_person_to_creator';
--
begin
  -- check the workflow funmode value
  if funmode = 'RUN' then
    -- workflow is RUNing this procedure
    --
        --
    -- Set the current_person_id to the creator_person_id
    --
    wf_engine.SetItemAttrText
        (itemtype   => itemtype,
             itemkey    => itemkey,
             aname      => 'CURRENT_PERSON_ID',
         avalue     =>  wf_engine.GetItemAttrNumber
                      (itemtype     => itemtype,
                           itemkey      => itemkey,
                           aname        => 'CREATOR_PERSON_ID' ));
    --
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    null;
  end if;
end set_current_person_to_creator;
-- ---------------------------------------------------------------------------
-- |-------------------------< set_training_admin_person >-------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  gets the value of the training administrator
--
--
procedure set_training_admin_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
begin
  -- check the workflow funmode value
  if funmode = 'RUN' then
    -- workflow is RUNing this procedure
    --
    -- Set the current_person_id to the creator_person_id
    --
    hr_workflow_service.create_hr_directory_services
     (p_item_type         => itemtype
     ,p_item_key          => itemkey
     ,p_service_name      => 'TRAINING_ADMIN'
     ,p_service_person_id => hr_offer_custom.set_training_admin_person);
    --
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    null;
  end if;
end set_training_admin_person;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< set_supervisor_id >-------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  gets the value of the supervisor id
--
--
procedure set_supervisor_id
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
begin
  -- check the workflow funmode value
  if funmode = 'RUN' then
    -- workflow is RUNing this procedure
    --
    -- Set the current_person_id to the creator_person_id
    --
    hr_workflow_service.create_hr_directory_services
      (p_item_type         => itemtype
      ,p_item_key          => itemkey
      ,p_service_name      => 'SUPERVISOR'
      ,p_service_person_id => hr_offer_custom.set_supervisor_id
                            (wf_engine.getitemattrnumber
                               (itemtype
                               ,itemkey
                               ,'CURRENT_PERSON_ID')));


    --
  elsif funmode = 'CANCEL' then
    -- workflow is calling in cancel mode (performing a loop reset) so ignore
    null;
  end if;
end set_supervisor_id;

procedure set_forward_to
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2) is
begin
  -- check the workflow funmode value
  if funmode = 'RUN' then
    -- workflow is RUNing this procedure
    --
    -- Set the current_person_id to the creator_person_id
    --
  wf_engine.SetItemAttrText (itemtype   => itemtype,
                 itemkey     => itemkey,
                 aname       => 'FORWARD_TO_DISPLAY_NAME',
                 avalue      =>  wf_engine.getitemattrtext
                                (itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      =>'RECRUITER_DISPLAY_NAME') );

  wf_engine.SetItemAttrText (itemtype   => itemtype,
                 itemkey     => itemkey,
                 aname       => 'FORWARD_TO_USERNAME',
                 avalue      =>  wf_engine.getitemattrtext
                                (itemtype   => itemtype,
                                 itemkey    => itemkey,
                                 aname      =>'RECRUITER_USERNAME') );

 elsif funmode = 'CANCEL' then
   -- workflow is calling in cancel mode (performing a loop reset) so ignore
   null;
 end if;
end set_forward_to;



--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--  Overloaded method returns the person id of the next approver in the chain
--  or null if no approver exists.
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                                itemkey     in varchar2,
                                currentapproverid in per_people_f.person_id%type,
                                personid      out nocopy per_people_f.person_id%type) is
  -- -------------------------------------------------------------------------
  -- local variables
  -- -------------------------------------------------------------------------
  l_creator_person_id     per_people_f.person_id%type;
BEGIN

-- -----------------------------------------------------------------------
    -- expose the wf control variables to the custom package
    -- -----------------------------------------------------------------------
    set_custom_wf_globals
      (p_itemtype => itemtype
      ,p_itemkey  => itemkey);
    --
    -- set the next forward to
    --
    personid :=
      hr_approval_custom.Get_Next_Approver
        (p_person_id => currentapproverid);

EXCEPTION
WHEN OTHERS THEN
     RAISE;
END Get_Next_Approver;



--
end hr_approval_wf;

/
