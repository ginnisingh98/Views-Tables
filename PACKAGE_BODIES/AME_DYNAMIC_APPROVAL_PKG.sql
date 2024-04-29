--------------------------------------------------------
--  DDL for Package Body AME_DYNAMIC_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_DYNAMIC_APPROVAL_PKG" as
/* $Header: amedapkg.pkb 120.2.12010000.2 2009/03/11 11:32:23 prasashe ship $ */

  /* procedures */

function  getApproverGroup(p_group_id in number)
 return varchar2 as
-- Cursor approver group name
CURSOR c_approver_group_name (
    p_group_id  IN number
  )
  IS
  select name from ame_approval_groups where
    approval_group_id = p_group_id;

ln_group_name varchar2(240) := null;
begin
    OPEN  c_approver_group_name ( p_group_id=>p_group_id);
    FETCH c_approver_group_name INTO ln_group_name;
      IF c_approver_group_name%NOTFOUND THEN
        return null;
      END IF ;
    CLOSE c_approver_group_name;
    return ln_group_name;
end;


PROCEDURE insert_ame_approver(
           p_application_id in number,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_approverIn in ame_approver_record2_table_ss,
           p_positionIn in number,
           p_insertionIn in ame_insertion_record2_table_ss,
           p_warning_msg_name     OUT NOCOPY varchar2,
           p_error_msg_text       OUT NOCOPY varchar2
    ) as

PRAGMA AUTONOMOUS_TRANSACTION;
--local variables
l_proc constant varchar2(100) := 'insert_ame_approver';

c_approver_rec2 ame_util.approverRecord2;
c_insertion_record2 ame_util.insertionRecord2;
lv_parameter varchar2(650);
BEGIN

  hr_utility.set_location('Entering: insert_ame_approver', 1);
  hr_utility.trace('p_application_id=' || p_application_id);
  hr_utility.trace('p_transaction_type=' || p_transaction_type);
  hr_utility.trace('p_transaction_id=' || p_transaction_id);
  hr_utility.trace('inserting approver ' || p_approverIn(1).name);
  hr_utility.trace('inserting approver id= ' || p_approverIn(1).orig_system_id);

  --Copy details from p_approverIn/p_insertionIn to c_approver_rec2
  c_approver_rec2.name := p_approverIn(1).name;
  c_approver_rec2.orig_system := p_approverIn(1).orig_system ;
  c_approver_rec2.orig_system_id := p_approverIn(1).orig_system_id ;
  c_approver_rec2.approver_category := p_approverIn(1).approver_category;
  c_approver_rec2.approval_status := null;
  c_approver_rec2.item_class := p_insertionIn(1).item_class;
  c_approver_rec2.item_id := p_insertionIn(1).item_id;
  c_approver_rec2.action_type_id := p_insertionIn(1).action_type_id;
  c_approver_rec2.group_or_chain_id := p_insertionIn(1).group_or_chain_id;
  c_approver_rec2.api_insertion := p_insertionIn(1).api_insertion;
  c_approver_rec2.authority := p_insertionIn(1).authority;

  -- Copy details from p_insertionIn to c_insertion_record2
  c_insertion_record2.item_class := p_insertionIn(1).item_class;
  c_insertion_record2.item_id := p_insertionIn(1).item_id;
  c_insertion_record2.action_type_id := p_insertionIn(1).action_type_id;
  c_insertion_record2.group_or_chain_id := p_insertionIn(1).group_or_chain_id;
  c_insertion_record2.api_insertion := p_insertionIn(1).api_insertion;
  c_insertion_record2.authority := p_insertionIn(1).authority;
  c_insertion_record2.order_type := p_insertionIn(1).order_type;
  -- to take care of '\v' special character not passivated,
  -- so replacing with another special charater which will be
  -- passivated.
  lv_parameter := p_insertionIn(1).parameter;
  lv_parameter :=  replace(lv_parameter,'^',ame_util.fieldDelimiter);
  c_insertion_record2.parameter := lv_parameter;

  c_insertion_record2.description := p_insertionIn(1).description;

  if (ame_util.firstAuthority = c_insertion_record2.order_type) then
   begin
    -- for now, we are not inserting COA first Authoriry approvers
    -- setFirstAuthority is accepting only Authority Insertion, but
    -- getAvailableOption returning 'Y'
    c_approver_rec2.api_insertion := 'A';
    ame_api2.setFirstAuthorityApprover(applicationIdIn =>p_application_id,
                               transactionIdIn =>p_transaction_id,
                               approverIn =>c_approver_rec2,
                               clearChainStatusYNIn => 'N',
                               transactionTypeIn=>p_transaction_type );
   end;
  else
   begin
      -- These parameters need to be null for adhoc approvers
      c_insertion_record2.action_type_id := ame_util.nullInsertionActionTypeId;
      c_insertion_record2.group_or_chain_id := ame_util.nullInsertionGroupOrChainId;

      c_approver_rec2.action_type_id := ame_util.nullInsertionActionTypeId;
      c_approver_rec2.group_or_chain_id := ame_util.nullInsertionGroupOrChainId;

      ame_api3.insertApprover(applicationIdIn =>p_application_id,
                               transactionIdIn =>p_transaction_id,
                               approverIn =>c_approver_rec2,
                               positionIn => p_positionIn,
                               insertionIn =>c_insertion_record2,
                               transactionTypeIn=>p_transaction_type );
   end;
  end if;

  hr_utility.set_location('Leaving: insert_ame_approver', 2);
  commit;
 EXCEPTION
    WHEN OTHERS THEN
     rollback;
     raise;
END insert_ame_approver;



PROCEDURE delete_ame_approver(
           p_application_id in number,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_approverIn in ame_approver_record2_table_ss,
           p_warning_msg_name     OUT NOCOPY varchar2,
           p_error_msg_text       OUT NOCOPY varchar2

    )

as
PRAGMA AUTONOMOUS_TRANSACTION;
--local variables
l_proc constant varchar2(100) :=  'delete_ame_approver';
c_approver_rec2 ame_util.approverRecord2;
BEGIN

  hr_utility.set_location('Entering: delete_ame_approver', 1);
  hr_utility.trace('p_application_id=' || p_application_id);
  hr_utility.trace('p_transaction_type=' || p_transaction_type);
  hr_utility.trace('p_transaction_id=' || p_transaction_id);
  hr_utility.trace('deleting approver ' || p_approverIn(1).name);

  --  copy details from p_approverIn to c_approver_rec2
  c_approver_rec2.name := p_approverIn(1).name;
  c_approver_rec2.item_class := p_approverIn(1).item_class;
  c_approver_rec2.item_id := p_approverIn(1).item_id;
  c_approver_rec2.action_type_id := p_approverIn(1).action_type_id;
  c_approver_rec2.group_or_chain_id := p_approverIn(1).group_or_chain_id;
  c_approver_rec2.api_insertion := p_approverIn(1).api_insertion;
  c_approver_rec2.occurrence := p_approverIn(1).occurrence;


  if(p_approverIn(1).api_Insertion = ame_util.apiInsertion) then
    begin
     -- API Inserrted Adhoc approver, so call clearInsertion
     ame_api3.clearInsertion(applicationIdIn =>p_application_id,
                               transactionTypeIn => p_transaction_type,
                               transactionIdIn =>p_transaction_id,
                               approverIn =>c_approver_rec2
                            );

    end;
  else
   begin
     -- AME genereated approver, so call supressApprover
     ame_api3.suppressApprover(applicationIdIn =>p_application_id,
                               transactionTypeIn => p_transaction_type,
                               transactionIdIn =>p_transaction_id,
                               approverIn =>c_approver_rec2
                             );

   end;
  end if;
  hr_utility.set_location('Leaving: delete_ame_approver', 2);
  commit;
 EXCEPTION
    WHEN OTHERS THEN
    rollback;
    raise;
END delete_ame_approver;



PROCEDURE get_ame_apprs_and_ins_list(
           p_application_id in integer,
           p_transaction_type in varchar2,
           p_transaction_id in varchar2,
           p_apprs_view_type in varchar2 default 'Active',
           p_coa_insertions_flag in varchar2 default 'N',
           p_ame_approvers_list OUT NOCOPY ame_approver_record2_table_ss,
           p_ame_order_type_list OUT NOCOPY ame_insertion_record2_table_ss,
           -- We need this value to add "Append to list" option
           p_all_approvers_count out  NOCOPY varchar2,
           p_warning_msg_name     OUT NOCOPY varchar2,
           p_error_msg_text       OUT NOCOPY varchar2

)
is

--local variables

l_proc constant varchar2(100) :=  'get_ame_apprs_and_ins_list';
lv_parameter             varchar2(650);
    errString ame_util.longestStringType;
CURSOR c_active_order_type_name (
    p_order_type  IN varchar2
  )
  IS
    select description
      from fnd_lookups
     where lookup_type like 'AME_DA_ACTIVE_ORDER_TYPE' and lookup_code = p_order_type;


CURSOR c_order_type_name (
    p_order_type  IN varchar2
  )
  IS
    select meaning
      from fnd_lookups
     where lookup_type like 'AME_APPR_INSERTION_ORDER_TYPE' and lookup_code = p_order_type;

CURSOR c_apr_status (
    p_status  IN varchar2
  )
  IS
    select meaning
      from fnd_lookups
     where lookup_type like 'AME_APPROVAL_STATUS' and lookup_code = p_status;

CURSOR c_apr_category (
    p_category  IN varchar2
  )
  IS
    select meaning
      from fnd_lookups
     where lookup_type like 'AME_APPROVER_CATEGORY' and lookup_code = p_category;


l_default_approvers_list    ame_approver_record2_table_ss := ame_approver_record2_table_ss();
l_default_approver          ame_approver_record2_ss;
l_default_insertions_list   ame_insertion_record2_table_ss := ame_insertion_record2_table_ss();
l_default_insertion         ame_insertion_record2_ss;
ln_approver_index           NUMBER;
c_all_approvers             ame_util.approversTable2;
c_all_insertions            ame_util2.insertionsTable3;
ln_approver_list_cnt      NUMBER ;
ln_insertions_index         NUMBER;
ln_insertion_record2_num    number;
lv_approval_status          varchar2(10);
ln_approver_group_name      varchar2(240);
bactiveApproversYNIn        varchar2(1);
allowDeletingOamApprovers   ame_util.attributeValueType;
ruleIdList                  ame_util.idList;
sourceDescription           ame_util.stringType;
allow_delete                varchar2(30);
ln_order_type_name          ame_temp_insertions.description%type;
active_apr_index            number;
last_active_apr_name        varchar2(100);
ln_apr_status               varchar2(80);
ln_apr_category             varchar2(80);
tempIndex                   integer;


BEGIN

  hr_utility.set_location('Entering: get_ame_apprs_and_ins_list', 1);
  hr_utility.trace('p_application_id=' || p_application_id);
  hr_utility.trace('p_transaction_type=' || p_transaction_type);
  hr_utility.trace('p_transaction_id=' || p_transaction_id);

  -- set flag based on user selection for Active or All Approvers
  -- zero means active approver
  if(p_apprs_view_type = '0' or p_apprs_view_type is null) then
    bactiveApproversYNIn := ame_util.booleanTrue;
  else
    bactiveApproversYNIn := ame_util.booleanFalse;
  end if;

  -- get Active/All AME Approvers
  ame_api5.getAllApproversAndInsertions(applicationIdIn =>p_application_id,
                              transactionIdIn=>p_transaction_id,
                              transactionTypeIn =>p_transaction_type,
                              activeApproversYNIn => bactiveApproversYNIn,
                              -- currently not getting COA approvers
                              coaInsertionsYNIN => ame_util.booleanFalse,
                              approvalProcessCompleteYNOut =>lv_approval_status,
                              approversOut=>c_all_approvers,
                              availableInsertionsOut => c_all_insertions);


   -- populate the p_ame_approvers_list and p_aprs_aval_insr_list
   ln_insertion_record2_num := 0;
   ln_approver_list_cnt :=0;

   -- iterate through approvers list
   tempIndex := c_all_approvers.first;
   while(tempIndex is not null) loop
     begin
      -- count for approvers
      ln_approver_list_cnt:= ln_approver_list_cnt + 1;
      -- parse the source to see if the approver was inserted.
      ame_util.parseSourceValue(sourceValueIn => c_all_approvers(tempIndex).source,
                                sourceDescriptionOut => sourceDescription,
                                ruleIdListOut => ruleIdList);

      -- If the approver was OAM generated, check whether deleting OAM-generated approvers
      -- is allowed or not.  If so, record the deletion.
      allow_delete := 'AMEDeleteEnabled';
      if(c_all_approvers(tempIndex).api_insertion = ame_util.oamGenerated or
         sourceDescription = ame_util.ruleGeneratedSource )  then
        begin
          allowDeletingOamApprovers :=
            ame_engine.getHeaderAttValue2(attributeNameIn => ame_util.allowDeletingOamApprovers);
          if(allowDeletingOamApprovers <> ame_util.booleanAttributeTrue) then
            begin
                 allow_delete := 'AMEDeleteDisabled';
            end;
          end if;
         end;
      end if;

      -- if approver already responded then disable delete button
      if (c_all_approvers(tempIndex).approval_status is not null and
          c_all_approvers(tempIndex).approval_status in
               (ame_util.approveAndForwardStatus
               ,ame_util.approvedStatus
               ,ame_util.notifiedStatus
               ,ame_util.notifiedByRepeatedStatus
               ,ame_util.approvedByRepeatedStatus
               ,ame_util.rejectedByRepeatedStatus
               ,ame_util.suppressedStatus)) then
       begin
            allow_delete := 'AMEDeleteDisabled';
       end;
      end if;

      --  get Approver Group
      ln_approver_group_name := getApproverGroup(c_all_approvers(tempIndex).group_or_chain_id);

      --  get approver status
      ln_apr_status := null;
      if (c_all_approvers(tempIndex).approval_status is not null) then
       begin
          OPEN  c_apr_status ( p_status=>trim(c_all_approvers(tempIndex).approval_status));
          FETCH c_apr_status INTO ln_apr_status;
         CLOSE c_apr_status;
       end;
      end if;

      --  get approver category lookup value
      OPEN  c_apr_category ( p_category=>trim(c_all_approvers(tempIndex).approver_category));
      FETCH c_apr_category INTO ln_apr_category;
      CLOSE c_apr_category;


      -- create the out ame_approver_record2_ss
      l_default_approver := ame_approver_record2_ss(
                                       tempIndex, -- approver line no
                                       c_all_approvers(tempIndex).name,  -- name
                                       c_all_approvers(tempIndex).orig_system,
                                       c_all_approvers(tempIndex).orig_system_id,
                                       c_all_approvers(tempIndex).display_name,  -- display name
                                       ln_apr_category, --c_all_approvers(i).approver_category,
                                       c_all_approvers(tempIndex).api_insertion,
                                       c_all_approvers(tempIndex).authority, -- authority
                                       ln_apr_status, --c_all_approvers(i).approval_status,
                                       c_all_approvers(tempIndex).action_type_id,
                                       c_all_approvers(tempIndex).group_or_chain_id,  -- group_or_chain_id
                                       c_all_approvers(tempIndex).occurrence,  -- occurrence
                                       null,   -- source
                                       c_all_approvers(tempIndex).item_class,  -- item_class
                                       c_all_approvers(tempIndex).item_id,  -- item_id
                                       c_all_approvers(tempIndex).approver_order_number,
                                       allow_delete, -- allow detele
                                       ln_approver_group_name -- approver_group_name
                    );


     -- add new row to the approvers list
     l_default_approvers_list.EXTEND;
     -- add to list
     l_default_approvers_list(ln_approver_list_cnt) := l_default_approver;

     -- get next approver record from sparse array
     tempIndex := c_all_approvers.next(tempIndex);
   end;
 END LOOP; -- approvers loop




ln_insertions_index := c_all_insertions.count;

-- get all approvers count by subtracting one from last insertion record position value
ln_approver_index :=   c_all_insertions(ln_insertions_index).position;
ln_approver_index := ln_approver_index - 1;
p_all_approvers_count := ln_approver_index  || '';


-- iterate through all insertion records to pass only active insertions and
-- and substitute "Order" , "After Approver Name" and "Before Approver Name"
active_apr_index := 1;
FOR J IN 1..ln_insertions_index LOOP

    -- increment the active_approver_index once we are done with current position
    if( active_apr_index = 0 or ((active_apr_index < ln_approver_list_cnt+1)
       and c_all_insertions(j).position >  l_default_approvers_list(active_apr_index).line_no))
    then
     begin
       active_apr_index := active_apr_index + 1;
     end;
    end if;

    -- Copy the records for last approver and active approver index position inserion records
    if( (ln_approver_index+1 = c_all_insertions(j).position)
       or ((active_apr_index < ln_approver_list_cnt+1)
          and
          c_all_insertions(j).position =
             l_default_approvers_list(active_apr_index).line_no))
    then
     begin


       -- getting lookup values based on active or all approvers mode
       if( bactiveApproversYNIn = 'Y' and c_all_insertions(j).order_type
            in ('absolute order','before approver','after approver')
       ) then
        begin
           OPEN  c_active_order_type_name ( p_order_type=>upper(c_all_insertions(j).order_type));
           FETCH c_active_order_type_name INTO ln_order_type_name;
           CLOSE c_active_order_type_name;
        end;
      else
       begin
         OPEN  c_order_type_name ( p_order_type=>upper(c_all_insertions(j).order_type));
         FETCH c_order_type_name INTO ln_order_type_name;
         CLOSE c_order_type_name;
       end;
      end if;

      -- append approver names or order number to based on order types to display in
      -- in the poplist
      -- append order number
      if( c_all_insertions(j).order_type = 'absolute order') then
         ln_order_type_name := ln_order_type_name || ' : ' || active_apr_index;
      end if;
      -- append before approver name
      if ( c_all_insertions(j).order_type = 'after approver' ) then
       begin
         -- in case of first approver and order_type='after approver'
         -- skip this insertion order type for end user
         if(active_apr_index <= 1)then  goto End_of_Insertions_Loop;  end if;

         ln_order_type_name := ln_order_type_name || ' : '
            || l_default_approvers_list(active_apr_index-1).display_name;
       end;
      end if;
      -- append before approver name
      if  ( c_all_insertions(j).order_type = 'before approver') then
           ln_order_type_name := ln_order_type_name || ' : '
                              || l_default_approvers_list(active_apr_index).display_name;
      end if;

      -- to take care of '\v' special character not passivated,
      -- so replacing with another special charater which will be
      -- passivated.
      lv_parameter := c_all_insertions(j).parameter;
      lv_parameter := replace(lv_parameter,ame_util.fieldDelimiter,'^');

      l_default_insertion := ame_insertion_record2_ss(
                                     c_all_insertions(j).position, -- position index
                                     c_all_insertions(j).item_class, -- item_class
                                     c_all_insertions(j).item_id, -- item_id
                                     c_all_insertions(j).action_type_id, -- null for adhoc
                                     c_all_insertions(j).group_or_chain_id, --  null for adhoc
                                     c_all_insertions(j).order_type,  -- order_type
                                     lv_parameter, -- parameter
                                     c_all_insertions(j).api_Insertion,
                                     c_all_insertions(j).authority, -- authority
                                      ln_order_type_name -- appended order type
                                    );
       -- add new row to insertion list
       l_default_insertions_list.EXTEND;
       ln_insertion_record2_num := ln_insertion_record2_num + 1;
       -- add to list
       l_default_insertions_list(ln_insertion_record2_num) := l_default_insertion ;
     end;
   end if;

<<End_of_Insertions_Loop>>
     -- this statement included just for above End_of_Insertions_Loop label
     hr_utility.trace('end of insertion records for loop');
END LOOP; -- insertions loop
--  end of the reading insertion records

-- set out parameters for approvers and insertion records
p_ame_order_type_list := l_default_insertions_list;
p_ame_approvers_list := l_default_approvers_list;

hr_utility.set_location('Leaving: get_ame_apprs_and_ins_list', 2);

EXCEPTION
    WHEN OTHERS THEN
       ame_util.runtimeException(packageNameIn => 'ame_dynamic_approval_pkg',
                                  routineNameIn => 'get_ame_apprs_and_ins_list',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        if sqlcode = -20001 then
          errString :=  sqlerrm;
          errString:= substr(errString,11);
        else
          fnd_message.set_name('PER','AME_400692_ENGINE_ERROR');
          errString := fnd_message.get;
        end if;
      p_warning_msg_name := errString;
END get_ame_apprs_and_ins_list;


end ame_dynamic_approval_pkg;

/
