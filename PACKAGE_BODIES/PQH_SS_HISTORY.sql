--------------------------------------------------------
--  DDL for Package Body PQH_SS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SS_HISTORY" as
/* $Header: pqhstswi.pkb 120.2 2005/10/04 12:24:09 snachuri noship $*/


g_package  constant varchar2(25) := 'pqh_ss_history.';
g_debug  boolean ;

procedure getRoleOrigSysInfo(p_item_type in varchar2,
                             p_item_key  in varchar2,
                             p_wf_ref_attr in varchar2,
                             p_wf_ref_type in varchar2,
                             p_user_name  in out nocopy varchar2,
                             p_orig_system  out nocopy varchar2,
                             p_orig_system_id  out nocopy number) is
  --local variables
   c_proc constant varchar2(30) := 'getRoleOrigSysInfo';
   lv_disp_name  wf_users.display_name%type;
   lt_userRoles wf_directory.wf_local_roles_tbl_type;
begin
g_debug := hr_utility.debug_enabled;

  if g_debug then
       hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);
  end if;

  if(p_wf_ref_attr is not null) then
     if(p_wf_ref_type='VARCHAR') then
       -- get the orig_system and system id details
       -- currently we have only two use cases
       if(p_wf_ref_attr='FORWARD_TO_USERNAME') then
         -- p_orig_system_id
            p_orig_system_id := wf_engine.getitemattrnumber(
                                             p_item_type,
                                             p_item_key,
                                             'FORWARD_TO_PERSON_ID',
                                             true);
         --p_orig_system
           p_orig_system := nvl(wf_engine.getitemattrtext(
                                             p_item_type,
                                             p_item_key,
                                             'FORWARD_TO_ORIG_SYS_ATTR',
                                             true),'PER');
       elsif(p_wf_ref_attr='CREATOR_PERSON_USERNAME') then
          -- p_orig_system_id
            p_orig_system_id := wf_engine.getitemattrnumber(
                                             p_item_type,
                                             p_item_key,
                                             'CREATOR_PERSON_ID',
                                             true);
           -- need to revisit with the role based support is enhanced.
            p_orig_system :='PER';

       end if;

       -- get the role name from wf_directory services
         wf_directory.GetRoleName
         (p_orig_system       => p_orig_system
         ,p_orig_system_id    => p_orig_system_id
         ,p_name              => p_user_name
         ,p_display_name      => lv_disp_name);

         if(p_orig_system not in ('FND_USR','PER')) then
           -- need to check if we have equivalent PER or FND_USR role
           p_user_name:=null;
           -- need to revisit to populate  the details based on
           -- context user approving the transaction.
         end if;

         -- trim the user name as this needs to be in
         -- same size as fnd_user.user_name
         p_user_name:= substrb(p_user_name,1,100);


     end if;
  else
    p_user_name:=null;
    p_orig_system:=null;
    p_orig_system_id:=null;

  end if;

  if (g_debug ) then
      hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 10);
     end if;
exception
  when others then
    if g_debug then
       hr_utility.set_location('Error in  getRoleOrigSysInfo SQLERRM' ||' '||to_char(SQLCODE),20);
      end if;

    raise;

end getRoleOrigSysInfo;

-- Local procedure to insert into transaction history table

procedure   insert_transaction_history (
  p_transaction_history_id in number,
  p_creator_person_id      in number,
  p_assignment_id          in number,
  p_selected_person_id     in number,
  p_process_name           in varchar2,
  p_item_type              in varchar2,
  p_item_key               in varchar2,
  p_function_id            in number,
  p_rptg_grp_id            in number,
  p_plan_id                in number,
  p_created_by             in number,
  p_creation_date          in date,
  p_last_update_date       in date,
  p_last_updated_by        in number,
  p_last_update_login      in number) is
begin
  insert into pqh_ss_transaction_history (
  transaction_history_id ,
  creator_person_id      ,
  assignment_id          ,
  selected_person_id     ,
  process_name           ,
  item_type              ,
  item_key               ,
  function_id            ,
  rptg_grp_id            ,
  plan_id                ,
  created_by             ,
  creation_date          ,
  last_update_date       ,
  last_updated_by        ,
  last_update_login      )
  values
 (p_transaction_history_id ,
  p_creator_person_id      ,
  p_assignment_id          ,
  p_selected_person_id     ,
  p_process_name           ,
  p_item_type              ,
  p_item_key               ,
  p_function_id            ,
  p_rptg_grp_id            ,
  p_plan_id                ,
  p_created_by             ,
  p_creation_date          ,
  p_last_update_date       ,
  p_last_updated_by        ,
  p_last_update_login      );

end insert_transaction_history;

procedure insert_approval_history (
  p_approval_history_id        in number,
  p_transaction_history_id     in number,
  p_transaction_effective_date in date,
  p_action                     in varchar2,
  p_user_name                  in varchar2,
  p_transaction_item_type      in varchar2,
  p_transaction_item_key       in varchar2,
  p_created_by                 in number,
  p_creation_date              in date,
  p_last_update_date           in date,
  p_last_updated_by            in number,
  p_last_update_login          in number,
  p_orig_system                in varchar2 default null,
  p_orig_system_id             in number default null) is

begin
  insert into pqh_ss_approval_history (
  approval_history_id        ,
  transaction_history_id     ,
  transaction_effective_date ,
  action                     ,
  user_name                  ,
  orig_system                ,
  orig_system_id             ,
  transaction_item_type      ,
  transaction_item_key       ,
  created_by                 ,
  creation_date              ,
  last_update_date           ,
  last_updated_by            ,
  last_update_login          )
  values
  (  p_approval_history_id     ,
  p_transaction_history_id     ,
  p_transaction_effective_date ,
  p_action                     ,
  p_user_name                  ,
  p_orig_system                ,
  p_orig_system_id             ,
  p_transaction_item_type      ,
  p_transaction_item_key       ,
  p_created_by                 ,
  p_creation_date              ,
  p_last_update_date           ,
  p_last_updated_by            ,
  p_last_update_login          );

end insert_approval_history;

procedure  insert_step_history (
   p_step_history_id          in  number,
   p_approval_history_id      in  number,
   p_transaction_history_id   in  number,
   p_api_name                 in  varchar2,
   p_api_display_name         in  varchar2,
   p_processing_order         in  varchar2,
   p_item_type                in  varchar2,
   p_item_key                 in  varchar2,
   p_activity_id              in  number,
   p_created_by               in  number,
   p_creation_date            in  date,
   p_last_update_date         in  date,
   p_last_updated_by          in  number,
   p_last_update_login        in  number) is
begin
  insert into pqh_ss_step_history
  (step_history_id            ,
   approval_history_id        ,
   transaction_history_id     ,
   api_name                   ,
   api_display_name           ,
   processing_order           ,
   item_type                  ,
   item_key                   ,
   activity_id                ,
   created_by                 ,
   creation_date              ,
   last_update_date           ,
   last_updated_by            ,
   last_update_login          )
   values (
   p_step_history_id          ,
   p_approval_history_id      ,
   p_transaction_history_id   ,
   p_api_name                 ,
   p_api_display_name         ,
   p_processing_order         ,
   p_item_type                ,
   p_item_key                 ,
   p_activity_id              ,
   p_created_by               ,
   p_creation_date            ,
   p_last_update_date         ,
   p_last_updated_by          ,
   p_last_update_login        );

end insert_step_history;

Procedure insert_value_history (
        p_transaction_value_id    in number,
        p_step_history_id         in number,
        p_approval_history_id     in number,
        p_datatype                in varchar2,
        p_name                    in varchar2,
        p_value                   in varchar2,
        p_created_by              in number,
        p_creation_date           in date,
        p_last_update_date        in date,
        p_last_updated_by         in number,
        p_last_update_login       in number) is
begin
       insert into pqh_ss_value_history
       (transaction_value_id       ,
        step_history_id            ,
        approval_history_id        ,
        datatype                   ,
        name                       ,
        value                      ,
        created_by                 ,
        creation_date              ,
        last_update_date           ,
        last_updated_by            ,
        last_update_login          )
       values (
        p_transaction_value_id       ,
        p_step_history_id            ,
        p_approval_history_id        ,
        p_datatype                   ,
        p_name                       ,
        p_value                      ,
        p_created_by                 ,
        p_creation_date              ,
        p_last_update_date           ,
        p_last_updated_by            ,
        p_last_update_login          );

end insert_value_history;
--
--

PROCEDURE transfer_action_to_history (
      p_itemType        IN     VARCHAR2
    , p_itemKey         IN     VARCHAR2
    , p_action          IN     VARCHAR2 ) IS

    l_txnItemType       VARCHAR2(10);
    l_txnItemKey        VARCHAR2(240);
    l_dummyProcess      VARCHAR2(200);
    l_username          VARCHAR2(320);
    l_transactionId     NUMBER(15);
    l_orig_system       wf_users.orig_system%type;
    l_orig_system_id    wf_users.orig_system_id%type;
 BEGIN
   /* l_username  :=
          wf_engine.GetItemAttrText(
              itemtype => p_itemType,
              itemkey  => p_itemKey,
              aname    => 'FORWARD_TO_USERNAME');*/
          getRoleOrigSysInfo(p_item_type=>p_itemType,
                             p_item_key=>p_itemKey,
                             p_wf_ref_attr=>'FORWARD_TO_USERNAME',
                             p_wf_ref_type=>'VARCHAR',
                             p_user_name=>l_username,
                             p_orig_system=>l_orig_system,
                             p_orig_system_id =>l_orig_system_id);


   l_transactionId  :=
    pqh_ss_workflow.get_transaction_id (
            p_itemType  => p_itemType
           ,p_itemKey   => p_itemKey);

 /*
     pqh_workflow_web_pkg.get_txn_wf_from_appr_wf (
        p_apprItemType      => p_itemType
       ,p_apprItemKey       => p_itemKey
       ,p_itemType          => l_txnItemType
       ,p_itemKey           => l_txnItemKey
       ,p_processName       => l_dummyProcess );
   */
    transfer_to_history (
        p_itemType      => p_itemType
       ,p_itemKey       => p_itemKey
       ,p_action        => p_action
       ,p_username      => l_username
       ,p_transactionId => l_transactionId
       ,p_orig_system   => l_orig_system
       ,p_orig_system_id => l_orig_system_id);

 END;


 --Called from approval workflow
 PROCEDURE transfer_submit_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS
  --
  l_username          VARCHAR2(320);
  l_transactionId     NUMBER(15);
  l_orig_system       wf_users.orig_system%type;
  l_orig_system_id    wf_users.orig_system_id%type;
  --
 BEGIN
    if ( funmode = 'RUN' ) THEN
       /* l_username  :=
          wf_engine.GetItemAttrText(
              itemtype => itemType,
              itemkey  => itemKey,
              aname    => 'CREATOR_PERSON_USERNAME');*/
        getRoleOrigSysInfo(p_item_type=>itemtype,
                             p_item_key=>itemkey,
                             p_wf_ref_attr=>'CREATOR_PERSON_USERNAME',
                             p_wf_ref_type=>'VARCHAR',
                             p_user_name=>l_username,
                             p_orig_system=>l_orig_system,
                             p_orig_system_id =>l_orig_system_id);

        l_transactionId  :=
        pqh_ss_workflow.get_transaction_id (
              p_itemType  => itemtype
             ,p_itemKey   => itemkey);

      transfer_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => 'SUBMIT'
       ,p_username      => l_username
       ,p_transactionId => l_transactionId
       ,p_orig_system   => l_orig_system
       ,p_orig_system_id => l_orig_system_id);

    end if;
    result  := 'COMPLETE:SUCCESS';
 END;


--Called from approval workflow
 PROCEDURE transfer_approval_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS
   l_action     VARCHAR2(25)  := 'APPROVED';
   l_transactionId NUMBER(15);
 BEGIN
    if ( funmode = 'RUN' ) THEN
      -- Check if package variable is set to indicate that
      -- Transaction was edited before submit. If yes

      IF ( pqh_ss_history.G_ACTION = '_EDIT') THEN
         -- reset the variable and
         -- Change the action appropriately
         l_action  := l_action||pqh_ss_history.G_ACTION ;
         pqh_ss_history.G_ACTION  := '';

         l_transactionId  :=
            pqh_ss_workflow.get_transaction_id (
                p_itemType  => itemType
               ,p_itemKey   => itemKey);

         track_original_value
          ( p_ItemType        => itemType
          , p_itemKey         => itemKey
          , p_action          => 'SFL'
          , p_username        => null
          , p_transactionId   => l_transactionId);

      END IF;

      transfer_action_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => l_action );
    end if;
    result  := 'COMPLETE:SUCCESS';
 END;
--Called from approval workflow
 PROCEDURE transfer_reject_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS

 BEGIN
    if ( funmode = 'RUN' ) THEN
      transfer_action_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => 'REJECTED' );
    end if;
    result  := 'COMPLETE:SUCCESS';
 END;


--Called from approval workflow
 PROCEDURE transfer_delete_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS

    l_txnItemType       VARCHAR2(10);
    l_txnItemKey        VARCHAR2(240);
    l_dummyProcess      VARCHAR2(200);
 BEGIN
    if ( funmode = 'RUN' ) THEN
      transfer_action_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => 'DELETED' );
    end if;
    result  := 'COMPLETE:SUCCESS';
 END;
 --Called from approval workflow
  PROCEDURE transfer_startover_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS

    l_txnItemType       VARCHAR2(10);
    l_txnItemKey        VARCHAR2(240);
    l_dummyProcess      VARCHAR2(200);
 BEGIN
    if ( funmode = 'RUN' ) THEN
      transfer_action_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => 'STARTOVER' );
    end if;
    result  := 'COMPLETE:SUCCESS';
 END;
  --Called from approval workflow
  PROCEDURE transfer_rfc_to_history (
      itemtype        IN     VARCHAR2,
      itemkey         IN     VARCHAR2,
      actid           IN     NUMBER,
      funmode         IN     VARCHAR2,
      result          OUT NOCOPY  VARCHAR2 ) IS

    l_txnItemType       VARCHAR2(10);
    l_txnItemKey        VARCHAR2(240);
    l_dummyProcess      VARCHAR2(200);
 BEGIN
    if ( funmode = 'RUN' ) THEN
      transfer_action_to_history (
        p_itemType      => itemType
       ,p_itemKey       => itemKey
       ,p_action        => 'RFC' );
    end if;
    result  := 'COMPLETE:SUCCESS';
 END;

--Called from pqh_workflow_web_pkg.start_approval_wf_process procedure
--Accepts Transaction Item Type and Key
procedure transfer_to_history
    ( p_ItemType             in varchar2
    , p_itemKey              in varchar2
    , p_action               in varchar2
    , p_username             in varchar2
    , p_transactionId        in number
    , p_orig_system          in varchar2 default null
    , p_orig_system_id       in number default null) IS

    l_transactionId  NUMBER          := p_transactionId;
    l_username       VARCHAR2(320)   := p_username;
    l_c1             varchar2(30);
--
cursor c_th_txn (c_txn_id in number) is
  select *
  from   hr_api_transactions
  where  transaction_id = c_txn_id;
--
cursor c_th_txn_h (c_txn_id in number) is
  select null
  from   pqh_ss_transaction_history
  where  transaction_history_id = c_txn_id ;
--
cursor c_th_appr_h (c_txn_id in number) is
  select nvl(max(approval_history_id),0)+1 approval_history_id
  from   pqh_ss_approval_history
  where  transaction_history_id = c_txn_id
    and  approval_history_id    > 0 ;
--
cursor c_th_step (c_txn_id in number) is
  select *
  from   hr_api_transaction_steps s
  where  transaction_id = c_txn_id
  and    exists (select null
                 from   hr_api_transaction_values v
                 where  v.transaction_step_id = s.transaction_step_id );
--
cursor c_th_value (c_step_id in number) is
  select  transaction_value_id ,
          datatype             ,
          name                 ,
          decode( datatype, 'VARCHAR2', varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(date_value),
                            'NUMBER'  , to_char(number_value)  , '' ) value ,
          decode( datatype, 'VARCHAR2', original_varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(original_date_value),
                            'NUMBER'  , to_char(original_number_value)  , '' ) original_value ,
          created_by           ,
          creation_date        ,
          last_update_date     ,
          last_updated_by      ,
          last_update_login
  from   hr_api_transaction_values
  where  transaction_step_id  =  c_step_id;
--
BEGIN
   -- new code to support the archive api's
   if(p_transactionId is not null and p_itemKey is not null) then
     if(p_action='SUBMIT') then
       hr_trans_history_api.archive_submit(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'APPROVAL_COMMENT_COPY'));

     elsif(p_action='RESUBMIT') then
       hr_trans_history_api.archive_resubmit(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'APPROVAL_COMMENT_COPY'));
     elsif(p_action='APPROVED') then
             hr_trans_history_api.archive_approve(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'WF_NOTE'));
     elsif(p_action='REJECTED') then
            hr_trans_history_api.archive_reject(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'WF_NOTE'));
     elsif(p_action='DELETED') then
            hr_trans_history_api.archive_delete(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'WF_NOTE'));
     elsif(p_action='RFC') then
           hr_trans_history_api.archive_rfc(p_transactionId,
                                           null,
                                           p_username,
                                           wf_engine.getitemattrtext(p_ItemType,
                                                                     p_itemKey,
                                                                     'NOTE_FROM_APPR',true));
     end if;
   end if;
  -- end new code changes

end;

procedure update_approval_history (
  p_approval_history_id        in number,
  p_transaction_history_id     in number,
  p_transaction_effective_date in date,
  p_action                     in varchar2,
  p_user_name                  in varchar2,
  p_transaction_item_type      in varchar2,
  p_transaction_item_key       in varchar2,
  p_created_by                 in number,
  p_creation_date              in date,
  p_last_update_date           in date,
  p_last_updated_by            in number,
  p_last_update_login          in number,
  p_orig_system                in varchar2 default null,
  p_orig_system_id             in number default null) is

begin
  update pqh_ss_approval_history
    set transaction_effective_date = p_transaction_effective_date ,
        user_name = p_user_name,
        orig_system = p_orig_system,
        orig_system_id = p_orig_system_id
  where transaction_history_id = p_transaction_history_id
    and approval_history_id = p_approval_history_id;

exception when no_data_found then
  insert_approval_history (
  p_approval_history_id        => p_approval_history_id,
  p_transaction_history_id     => p_transaction_history_id,
  p_transaction_effective_date => p_transaction_effective_date,
  p_action                     => p_action,
  p_user_name                  => p_user_name,
  p_transaction_item_type      => p_transaction_item_type,
  p_transaction_item_key       => p_transaction_item_key,
  p_created_by                 => p_created_by,
  p_creation_date              => p_creation_date,
  p_last_update_date           => p_last_update_date,
  p_last_updated_by            => p_last_updated_by,
  p_last_update_login          => p_last_update_login,
  p_orig_system                => p_orig_system,
  p_orig_system_id             => p_orig_system_id);

end update_approval_history;

procedure  update_step_history (
   p_step_history_id          in  number,
   p_approval_history_id      in  number,
   p_transaction_history_id   in  number,
   p_api_name                 in  varchar2,
   p_api_display_name         in  varchar2,
   p_processing_order         in  varchar2,
   p_item_type                in  varchar2,
   p_item_key                 in  varchar2,
   p_activity_id              in  varchar2,
   p_created_by               in  number,
   p_creation_date            in  date,
   p_last_update_date         in  date,
   p_last_updated_by          in  number,
   p_last_update_login        in  number) is

  l_var varchar2(20);
begin
   select null
     into l_var
     from pqh_ss_step_history
    where transaction_history_id = p_transaction_history_id
      and approval_history_id = p_approval_history_id
      and step_history_id = p_step_history_id;

exception when no_data_found then
  insert_step_history
  (p_step_history_id            => p_step_history_id,
   p_approval_history_id        => p_approval_history_id,
   p_transaction_history_id     => p_transaction_history_id,
   p_api_name                   => p_api_name,
   p_api_display_name           => p_api_display_name,
   p_processing_order           => p_processing_order,
   p_item_type                  => p_item_type,
   p_item_key                   => p_item_key,
   p_activity_id                => p_activity_id,
   p_created_by                 => p_created_by,
   p_creation_date              => p_creation_date,
   p_last_update_date           => p_last_update_date,
   p_last_updated_by            => p_last_updated_by,
   p_last_update_login          => p_last_update_login);

end update_step_history;

Procedure update_value_history (
        p_transaction_value_id    in number,
        p_step_history_id         in number,
        p_approval_history_id     in number,
        p_datatype                in varchar2,
        p_name                    in varchar2,
        p_value                   in varchar2,
        p_created_by              in number,
        p_creation_date           in date,
        p_last_update_date        in date,
        p_last_updated_by         in number,
        p_last_update_login       in number) is
begin
  update pqh_ss_value_history
     set value = p_value
   where transaction_value_id = p_transaction_value_id
     and step_history_id = p_step_history_id
     and approval_history_id = p_approval_history_id
     and name = p_name;

exception when no_data_found then
       insert_value_history (
        p_transaction_value_id      => p_transaction_value_id,
        p_step_history_id           => p_step_history_id,
        p_approval_history_id       => p_approval_history_id,
        p_datatype                  => p_datatype,
        p_name                      => p_name,
        p_value                     => p_value,
        p_created_by                => p_created_by,
        p_creation_date             => p_creation_date,
        p_last_update_date          => p_last_update_date,
        p_last_updated_by           => p_last_updated_by,
        p_last_update_login         => p_last_update_login);

end update_value_history;


procedure track_original_value
    ( p_ItemType             in varchar2
    , p_itemKey              in varchar2
    , p_action               in varchar2
    , p_username             in varchar2
    , p_transactionId        in number
    , p_orig_system          in varchar2 default null
    , p_orig_system_id       in number default null) IS

    l_transactionId  NUMBER := p_transactionId;
    l_username       VARCHAR2(320)   := p_username;
    l_c              VARCHAR2(30) ;
    l_new_history    BOOLEAN := TRUE;

cursor c_ov_apr_h (v_transactionId in number)is
      select null from pqh_ss_approval_history
      where transaction_history_id = v_transactionId
        and approval_history_id = 0;
--
cursor c_ov_txn (c_txn_id in number) is
  select *
  from   hr_api_transactions
  where  transaction_id = c_txn_id;
--
cursor c_ov_txn_h (c_txn_id in number) is
  select null
  from   pqh_ss_transaction_history
  where  transaction_history_id = c_txn_id ;
--
cursor c_ov_step (c_txn_id in number) is
  select *
  from   hr_api_transaction_steps s
  where  transaction_id = c_txn_id
  and    exists (select null
                 from   hr_api_transaction_values v
                 where  v.transaction_step_id = s.transaction_step_id );
--
cursor c_ov_value (c_step_id in number) is
  select  transaction_value_id ,
          datatype             ,
          name                 ,
          decode( datatype, 'VARCHAR2', varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(date_value),
                            'NUMBER'  , to_char(number_value)  , '' ) value ,
          decode( datatype, 'VARCHAR2', original_varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(original_date_value),
                            'NUMBER'  , to_char(original_number_value)  , '' ) original_value ,
          created_by           ,
          creation_date        ,
          last_update_date     ,
          last_updated_by      ,
          last_update_login
  from   hr_api_transaction_values
  where  transaction_step_id  =  c_step_id;
--
begin
  for apr in c_ov_apr_h (l_transactionId) loop
     l_new_history := FALSE;
  end loop; --c_ov_apr_h

  for tn in c_ov_txn (l_transactionId) loop

   if l_new_history then

       if c_ov_txn_h%ISOPEN then
           close c_ov_txn_h ;
       end if; --ISOPEN
       open c_ov_txn_h (l_transactionId);
       fetch c_ov_txn_h into l_c;

       if c_ov_txn_h%notfound then
         insert_transaction_history (
         p_transaction_history_id => tn.transaction_id,
         p_creator_person_id      => tn.creator_person_id,
         p_assignment_id          => tn.assignment_id,
         p_selected_person_id     => tn.selected_person_id,
         p_process_name           => tn.process_name,
         p_item_type              => p_itemType,
         p_item_key               => p_itemKey,
         p_function_id            => tn.function_id,
         p_rptg_grp_id            => tn.rptg_grp_id,
         p_plan_id                => tn.plan_id,
         p_created_by             => tn.created_by,
         p_creation_date          => tn.creation_date,
         p_last_update_date       => tn.last_update_date,
         p_last_updated_by        => tn.last_updated_by,
         p_last_update_login      => tn.last_update_login);
       end if; --c_ov_txn_h%notfound
       close c_ov_txn_h;

       insert_approval_history (
           p_approval_history_id        => 0,
           p_transaction_history_id     => l_transactionId,
           p_transaction_effective_date => tn.transaction_effective_date,
           p_action                     => 'LATEST_ORIGINAL_VALUE',
           p_user_name                  => l_username,
	   p_orig_system                => p_orig_system,
           p_orig_system_id             => p_orig_system_id,
           p_transaction_item_type      => tn.item_type,
           p_transaction_item_key       => tn.item_key,
           p_created_by                 => tn.created_by,
           p_creation_date              => tn.creation_date,
           p_last_update_date           => tn.last_update_date,
           p_last_updated_by            => tn.last_updated_by,
           p_last_update_login          => tn.last_update_login);

     for stp in c_ov_step(l_transactionId) loop

     insert_step_history
     (p_step_history_id            => stp.transaction_step_id,
      p_approval_history_id        => 0 ,
      p_transaction_history_id     => l_transactionId,
      p_api_name                   => stp.api_name,
      p_api_display_name           => stp.api_display_name,
      p_processing_order           => stp.processing_order,
      p_item_type                  => stp.item_type,
      p_item_key                   => stp.item_key,
      p_activity_id                => stp.activity_id,
      p_created_by                 => stp.created_by,
      p_creation_date              => stp.creation_date,
      p_last_update_date           => stp.last_update_date,
      p_last_updated_by            => stp.last_updated_by,
      p_last_update_login          => stp.last_update_login);

       for vlue in c_ov_value (stp.transaction_step_id) loop

          insert_value_history (
           p_transaction_value_id      => vlue.transaction_value_id,
           p_step_history_id           => stp.transaction_step_id,
           p_approval_history_id       => 0 ,
           p_datatype                  => vlue.datatype,
           p_name                      => vlue.name,
           p_value                     => vlue.original_value,
           p_created_by                => vlue.created_by,
           p_creation_date             => vlue.creation_date,
           p_last_update_date          => vlue.last_update_date,
           p_last_updated_by           => vlue.last_updated_by,
           p_last_update_login         => vlue.last_update_login);

       end loop; -- c_ov_value
     end loop; -- c_ov_step


   else -- l_new_history is false

     update_approval_history (
           p_approval_history_id        => 0,
           p_transaction_history_id     => l_transactionId,
           p_transaction_effective_date => tn.transaction_effective_date,
           p_action                     => 'LATEST_ORIGINAL_VALUE',
           p_user_name                  => l_username,
	       p_orig_system                => p_orig_system,
           p_orig_system_id             => p_orig_system_id,
           p_transaction_item_type      => tn.item_type,
           p_transaction_item_key       => tn.item_key,
           p_created_by                 => tn.created_by,
           p_creation_date              => tn.creation_date,
           p_last_update_date           => tn.last_update_date,
           p_last_updated_by            => tn.last_updated_by,
           p_last_update_login          => tn.last_update_login);

     for stp in c_ov_step(l_transactionId) loop

     update_step_history
     (p_step_history_id            => stp.transaction_step_id,
      p_approval_history_id        => 0 ,
      p_transaction_history_id     => l_transactionId,
      p_api_name                   => stp.api_name,
      p_api_display_name           => stp.api_display_name,
      p_processing_order           => stp.processing_order,
      p_item_type                  => stp.item_type,
      p_item_key                   => stp.item_key,
      p_activity_id                => stp.activity_id,
      p_created_by                 => stp.created_by,
      p_creation_date              => stp.creation_date,
      p_last_update_date           => stp.last_update_date,
      p_last_updated_by            => stp.last_updated_by,
      p_last_update_login          => stp.last_update_login);

       for vlue in c_ov_value (stp.transaction_step_id) loop
          update_value_history (
           p_transaction_value_id      => vlue.transaction_value_id,
           p_step_history_id           => stp.transaction_step_id,
           p_approval_history_id       => 0 ,
           p_datatype                  => vlue.datatype,
           p_name                      => vlue.name,
           p_value                     => vlue.original_value,
           p_created_by                => vlue.created_by,
           p_creation_date             => vlue.creation_date,
           p_last_update_date          => vlue.last_update_date,
           p_last_updated_by           => vlue.last_updated_by,
           p_last_update_login         => vlue.last_update_login);

       end loop; -- c_ov_value

     end loop; -- c_ov_step

   end if; -- appr.approval_history_id = 1

  end loop; --c_ov_txn

commit;
end track_original_value;

PROCEDURE copy_value_to_history (
        p_txnId        IN NUMBER ) IS
--
--
CURSOR c_vt_sup_step(c_txn_id in number, c_api_name in varchar2 default null)  IS
SELECT *
FROM   hr_api_transaction_steps
WHERE  transaction_id = c_txn_id
AND    ( (c_api_name is null AND api_name in (
                         'HR_PAY_RATE_SS.PROCESS_API'
                        ,'HR_SUPERVISOR_SS.PROCESS_API'
                        ,'HR_PROCESS_SIT_SS.PROCESS_API'
                        ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                        ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                        ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                        ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                        ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                        ,'HR_COMP_PROFILE_SS.PROCESS_API'))
         OR   api_name = c_api_name);
--
cursor c_vt_txn (c_txn_id in number) is
  select *
  from   hr_api_transactions
  where  transaction_id = c_txn_id;
--
cursor c_vt_txn_h (c_txn_id in number) is
  select null
  from   pqh_ss_transaction_history
  where  transaction_history_id = c_txn_id ;
--
dummy  varchar2(10);
tn     c_vt_txn%ROWTYPE;
--
BEGIN
--
hr_utility.set_location('Entering: copy_value to history -'||p_txnId, 5);
--
  delete from pqh_ss_value_history
  where approval_history_id    = -1
  and   step_history_id in     (
        select step_history_id from pqh_ss_step_history
	where transaction_history_id = p_txnId
	and   approval_history_id    = -1);
  --
     hr_utility.set_location('delete value history done', 45);
  delete from pqh_ss_step_history
  where transaction_history_id = p_txnId
  and   approval_history_id    = -1;

for r_supStep in c_vt_sup_step(p_txnId) loop

   hr_utility.set_location('step_id'||r_supStep.transaction_step_id, 10);
   --
   --Check to see if transaction history record already exists
   if c_vt_txn_h%ISOPEN then
       close c_vt_txn_h ;
   end if; --ISOPEN
   --
   OPEN  c_vt_txn_h (p_txnId);
   FETCH c_vt_txn_h INTO  dummy;

     -- Create a new record if txn history does not exist
     IF c_vt_txn_h%NOTFOUND THEN
         hr_utility.set_location('Transaction history not found', 15);
         if c_vt_txn%ISOPEN then
             close c_vt_txn ;
         end if; --ISOPEN
         open  c_vt_txn (p_txnId);
         fetch c_vt_txn into tn;
         close c_vt_txn;

         hr_utility.set_location('Calling insert', 15);
         -- create approval history if it does not exist.
         insert_transaction_history (
         p_transaction_history_id => tn.transaction_id,
         p_creator_person_id      => tn.creator_person_id,
         p_assignment_id          => tn.assignment_id,
         p_selected_person_id     => tn.selected_person_id,
         p_process_name           => tn.process_name,
         p_item_type              => tn.item_Type,
         p_item_key               => tn.item_Key,
         p_function_id            => tn.function_id,
         p_rptg_grp_id            => tn.rptg_grp_id,
         p_plan_id                => tn.plan_id,
         p_created_by             => tn.created_by,
         p_creation_date          => tn.creation_date,
         p_last_update_date       => tn.last_update_date,
         p_last_updated_by        => tn.last_updated_by,
         p_last_update_login      => tn.last_update_login);

         hr_utility.set_location('Insert history complete', 20);

     END IF;
   CLOSE c_vt_txn_h;
  --
 hr_utility.set_location('delete step history done', 55);

  insert_step_history
  (p_step_history_id            => r_supStep.transaction_step_id,
   p_approval_history_id        => -1,
   p_transaction_history_id     => p_txnId,
   p_api_name                   => r_supStep.api_name,
   p_api_display_name           => r_supStep.api_display_name,
   p_processing_order           => r_supStep.processing_order,
   p_item_type                  => r_supStep.item_type,
   p_item_key                   => r_supStep.item_key,
   p_activity_id                => r_supStep.activity_id,
   p_created_by                 => r_supStep.created_by,
   p_creation_date              => r_supStep.creation_date,
   p_last_update_date           => r_supStep.last_update_date,
   p_last_updated_by            => r_supStep.last_updated_by,
   p_last_update_login          => r_supStep.last_update_login);

 hr_utility.set_location('insert step history done', 65);

   insert into pqh_ss_value_history (
          transaction_value_id  ,
          step_history_id       ,
          approval_history_id   ,
          datatype              ,
          name                  ,
          value                 ,
          original_value        ,
          created_by            ,
          creation_date         ,
          last_update_date      ,
          last_updated_by       ,
          last_update_login )
  select  transaction_value_id ,
          transaction_step_id  ,
          -1                   ,
          datatype             ,
          name                 ,
          decode( datatype, 'VARCHAR2', varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(date_value),
                            'NUMBER'  , number_value  , '' ) value ,
          decode( datatype, 'VARCHAR2', original_varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(original_date_value),
                            'NUMBER'  , original_number_value  , '' ) original_value ,
          created_by           ,
          creation_date        ,
          last_update_date     ,
          last_updated_by      ,
          last_update_login
  from   hr_api_transaction_values
  where  transaction_step_id       =  r_supStep.transaction_step_id ;
--
  hr_utility.set_location('Leaving: copy_value to history', 75);
end loop ; --c_vt_sup_step

END copy_value_to_history;

PROCEDURE copy_value_from_history (
        p_txnId        IN NUMBER ) IS
--
CURSOR c_vf_sup_step(c_txn_id in number, c_api_name in varchar2 default null)  IS
SELECT *
FROM   hr_api_transaction_steps
WHERE  transaction_id = c_txn_id
AND    ( (c_api_name is null AND api_name in (
                         'HR_SUPERVISOR_SS.PROCESS_API'
                        ,'HR_PROCESS_SIT_SS.PROCESS_API'
                        ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                        ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                        ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                        ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                        ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                        ,'HR_COMP_PROFILE_SS.PROCESS_API'))
         OR   api_name = c_api_name);
--
CURSOR c_vf_sup_step_h (c_txn_id in number) IS
SELECT *
FROM   pqh_ss_step_history
WHERE  transaction_history_id = c_txn_id
AND    approval_history_id    = -1
AND    api_name      in ('HR_SUPERVISOR_SS.PROCESS_API'
                        ,'HR_PROCESS_SIT_SS.PROCESS_API'
                        ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                        ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                        ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                        ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                        ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                        ,'HR_COMP_PROFILE_SS.PROCESS_API'
                        )
order by api_name;
--
r_supStep  c_vf_sup_step%ROWTYPE;
--
l_temp_api_name varchar2(80);
l_step_id       number ;
--
BEGIN
--
-- Remove values and step which are not part of history.
--
delete from hr_api_transaction_values v
where v.transaction_step_id in (select s.transaction_step_id from  hr_api_transaction_steps s
                                where  s.transaction_id = p_txnId
                                and    s.api_name not in (select h.api_name from pqh_ss_step_history h
                                                      where transaction_history_id = p_txnId
                                                      and approval_history_id      = -1 )
                                and  s.api_name in (
                                     'HR_PAY_RATE_SS.PROCESS_API'
                                    ,'HR_SUPERVISOR_SS.PROCESS_API'
                                    ,'HR_PROCESS_SIT_SS.PROCESS_API'
                                    ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
                                    ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
                                    ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
                                    ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
                                    ,'HR_PROCESS_PERSON_SS.PROCESS_API'
                                    ,'HR_COMP_PROFILE_SS.PROCESS_API' ));
--
delete from  hr_api_transaction_steps s
where  s.transaction_id = p_txnId
and    s.api_name not in (select h.api_name from pqh_ss_step_history h
                        where transaction_history_id = p_txnId
                          and approval_history_id    = -1 )
  and  s.api_name in (
       'HR_PAY_RATE_SS.PROCESS_API'
      ,'HR_SUPERVISOR_SS.PROCESS_API'
      ,'HR_PROCESS_SIT_SS.PROCESS_API'
      ,'HR_QUA_AWARDS_UTIL_SS.PROCESS_API'
      ,'HR_PROCESS_PHONE_NUMBERS_SS.PROCESS_API'
      ,'HR_PROCESS_ADDRESS_SS.PROCESS_API'
      ,'HR_PROCESS_CONTACT_SS.PROCESS_API'
      ,'HR_PROCESS_PERSON_SS.PROCESS_API'
      ,'HR_COMP_PROFILE_SS.PROCESS_API' );
--
-- Simply return if there is no history record
for r_supStep_h in c_vf_sup_step_h (p_txnId) loop
   --
   if l_temp_api_name is null then
      --
      if c_vf_sup_step%ISOPEN then
         close c_vf_sup_step ;
      end if; --ISOPEN
      --
      open  c_vf_sup_step (p_txnId, r_supStep_h.api_name );
      --
      l_temp_api_name := r_supStep_h.api_name ;
      --
   elsif l_temp_api_name <> r_supStep_h.api_name then
      loop
      --
         fetch c_vf_sup_step INTO r_supStep;
         --
         if c_vf_sup_step%NOTFOUND then
            exit; -- exit loop, when no further records are found
            --
         else
            --
            delete from hr_api_transaction_values
            where  transaction_step_id = r_supStep.transaction_step_id;
            --
            delete from  hr_api_transaction_steps
            where  transaction_step_id = r_supStep.transaction_step_id;
            --
         end if; --  c_vf_sup_step%FOUND
         --
      end loop; -- step loop
      --
      if c_vf_sup_step%ISOPEN then
         close c_vf_sup_step ;
      end if; --ISOPEN
      --
      open  c_vf_sup_step (p_txnId, r_supStep_h.api_name );
      --
      l_temp_api_name := r_supStep_h.api_name ;
      --
   end if;
   --
   fetch c_vf_sup_step INTO r_supStep;
   --
   if c_vf_sup_step%NOTFOUND then
   --
   select hr_api_transaction_steps_s.nextval
   into l_step_id
   from dual;

   insert into hr_api_transaction_steps(
	   transaction_step_id        ,
	   transaction_id             ,
	   api_name                   ,
	   api_display_name           ,
	   processing_order           ,
       item_type                  ,
       item_key                   ,
       activity_id                ,
       creator_person_id          ,
       object_version_number      ,
	   created_by                 ,
	   creation_date              ,
	   last_update_date           ,
	   last_updated_by            ,
	   last_update_login          )
   values (
       l_step_id                              ,
       r_supStep_h.transaction_history_id     ,
	   r_supStep_h.api_name                   ,
	   r_supStep_h.api_display_name           ,
	   r_supStep_h.processing_order           ,
       r_supStep_h.item_type                  ,
       r_supStep_h.item_key                   ,
       r_supStep_h.activity_id                ,
       0,0,
	   r_supStep_h.created_by                 ,
	   r_supStep_h.creation_date              ,
	   r_supStep_h.last_update_date           ,
	   r_supStep_h.last_updated_by            ,
	   r_supStep_h.last_update_login          );
    --
   else
      l_step_id := r_supStep.transaction_step_id ;

      delete from hr_api_transaction_values
      where  transaction_step_id = r_supStep.transaction_step_id;
   end if; -- c_sup_step%NOTFOUND


   insert into hr_api_transaction_values (
          transaction_value_id,
          transaction_step_id,
          datatype,
          name,
          varchar2_value,
          number_value,
          date_value,
          original_varchar2_value,
          original_number_value,
          original_date_value,
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login )
  select  hr_api_transaction_values_s.nextval ,
          l_step_id, -- nvl( r_supStep.transaction_step_id, step_history_id) step_history_id,
          datatype,
          name,
          decode(datatype,'VARCHAR2',value),
          decode(datatype,'NUMBER',to_number(value)),
          decode(datatype,'DATE',fnd_date.canonical_to_date(value)),
          decode(datatype,'VARCHAR2',original_value),
          decode(datatype,'NUMBER',to_number(original_value)),
          decode(datatype,'DATE',fnd_date.canonical_to_date(original_value)),
          created_by,
          creation_date,
          last_update_date,
          last_updated_by,
          last_update_login
   from   pqh_ss_value_history vh
   where  vh.approval_history_id    = -1
   and    vh.step_history_id        = r_supStep_h.step_history_id;

end loop; -- c_vf_supStep_h
--
if c_vf_sup_step%ISOPEN then
--
loop
   fetch c_vf_sup_step INTO r_supStep;
   --
   if c_vf_sup_step%NOTFOUND then
      exit; -- exit loop, when no further records are found
      --
   else
      delete from hr_api_transaction_values
      where  transaction_step_id = r_supStep.transaction_step_id;
      --
      delete from  hr_api_transaction_steps
      where  transaction_step_id = r_supStep.transaction_step_id;
      --
   end if; --  c_vf_sup_step%FOUND
   --
end loop; -- step loop
--
close c_vf_sup_step;
end if; --  c_vf_sup_step%ISOPEN
--
END;


end pqh_ss_history;

/
