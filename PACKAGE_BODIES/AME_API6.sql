--------------------------------------------------------
--  DDL for Package Body AME_API6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_API6" as
/* $Header: ameeapi6.pkb 120.1.12010000.6 2011/11/14 14:54:23 kkananth ship $ */
  ambiguousApproverException exception;
  ambiguousApproverMessage constant ame_util.longestStringType :=
    ame_util.getMessage(applicationShortNameIn =>'PER',
    messageNameIn => 'AME_400812_NULL_APPR_REC_NAME');
    procedure getApproverDetails(nameIn                in varchar2
                                 ,validityOut          out NOCOPY varchar2
                                 ,displayNameOut       out NOCOPY varchar2
                                 ,origSystemIdOut      out NOCOPY integer
                                 ,origSystemOut        out NOCOPY varchar2 ) as
    begin
      validityOut := 'INVALID';
      select
        display_name,
        orig_system,
        orig_system_id
        into
          displayNameOut,
          origSystemOut,
          origSystemIdOut
        from wf_roles
        where
          name = nameIn and
          status = 'ACTIVE' and
          (expiration_date is null or
            sysdate < expiration_date) and
          rownum < 2;
        validityOut := 'VALID';
      exception
        when no_data_found then
          begin
            select
              display_name,
              orig_system,
              orig_system_id
              into
                displayNameOut,
                origSystemOut,
                origSystemIdOut
              from wf_local_roles
              where
                name = nameIn and
                rownum < 2;
            validityOut := 'INACTIVE';
            exception
              when no_data_found then
                displayNameOut := nameIn;
                origSystemOut  := 'PER';
          end;
    end getApproverDetails;
  procedure getApprovers(applicationIdIn   in number
                        ,transactionTypeIn in varchar2
                        ,transactionIdIn   in varchar2
                        ,approversOut     out nocopy ame_util.approversTable2) as
    ameApplicationId integer;
    tempIndex        integer;
    l_valid varchar2(50);
    l_display_name varchar2(200);
    cursor approversCursor (applicationIdIn in integer
                           ,transactionIdIn in varchar2) is
      select atah.row_timestamp row_timestamp
            ,atah.item_class item_class
            ,atah.item_id item_id
            ,atah.name name
            ,atah.order_number order_number
            ,atah.approver_category category
            ,atah.user_comments user_comment
            ,atah.status status
            ,atah.authority
            ,atah.occurrence
            ,atah.action_type_id
            ,atah.group_or_chain_id
            ,atah.api_insertion
            ,atah.member_order_number
       from ame_trans_approval_history atah
      where atah.date_cleared is null
        and atah.transaction_id   = transactionIdIn
        and atah.application_id   = applicationIdIn
        and atah.row_timestamp =
             (
              select max(b.row_timestamp)
                from ame_trans_approval_history b
               where atah.transaction_id     = b.transaction_id
                 and atah.application_id     = b.application_id
                 and atah.name               = b.name
                 and atah.approver_category  = b.approver_category
                 and atah.item_class         = b.item_class
                 and atah.item_id            = b.item_id
                 and atah.action_type_id     = b.action_type_id
                 and atah.authority          = b.authority
                 and atah.group_or_chain_id  = b.group_or_chain_id
                 and atah.occurrence         = b.occurrence
                 and b.date_cleared is null);
    begin
      --+
      -- get the ame application id.
      --+
      tempIndex := 0;
      ameApplicationId :=
          ame_admin_pkg.getApplicationId
                            (fndAppIdIn          => applicationIdIn
                            ,transactionTypeIdIn => transactionTypeIn);
      for approver in approversCursor(applicationIdIn => ameApplicationId
                                     ,transactionIdIn => transactionIdIn) loop
        tempIndex := tempIndex + 1;
        approversOut(tempIndex).name := approver.name;
        approversOut(tempIndex).display_name := ame_approver_type_pkg.getApproverDisplayName4(nameIn => approver.name);
        approversOut(tempIndex).item_class := approver.item_class;
        approversOut(tempIndex).item_id    := approver.item_id;
        approversOut(tempIndex).approver_category := approver.category;
        approversOut(tempIndex).authority := approver.authority;
        approversOut(tempIndex).approval_status := approver.status;
        approversOut(tempIndex).action_type_id := approver.action_type_id;
        approversOut(tempIndex).group_or_chain_id := approver.group_or_chain_id;
        approversOut(tempIndex).occurrence := approver.occurrence;
        approversOut(tempIndex).approver_order_number := approver.order_number;
        approversOut(tempIndex).api_insertion := approver.api_insertion;
        approversOut(tempIndex).member_order_number := approver.member_order_number;
        begin
          ame_approver_type_pkg.getApproverOrigSystemAndId
             (nameIn          => approver.name
             ,origSystemOut   => approversOut(tempIndex).orig_system
             ,origSystemIdOut => approversOut(tempIndex).orig_system_id);
        /*
          The old approver list does not maintain source.  Calling applications requiring
          source data must get it by calling getNextApprover or getAllApprovers.
        */
        exception
          when others then
             getApproverDetails(nameIn => approver.name
                                 ,validityOut     => l_valid
                                 ,displayNameOut  => l_display_name
                                 ,origSystemIdOut => approversOut(tempIndex).orig_system_id
                                 ,origSystemOut   => approversOut(tempIndex).orig_system);
            if l_valid = 'INVALID' then
              approversOut(tempIndex).orig_system_id := null;
              approversOut(tempIndex).orig_system := null;
            end if;
        end;
        approversOut(tempIndex).source := null;
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api6',
                                  routineNameIn => 'getApprovers',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        approversOut.delete;
        raise;
    end getApprovers;
      procedure updateApprovalStatus(applicationIdIn in number,
                                 transactionTypeIn in varchar2,
                                 transactionIdIn in varchar2,
                                 approverIn in ame_util.approverRecord2,
                                 notificationIn in ame_util2.notificationRecord
                                          default ame_util2.emptyNotificationRecord,
                                 forwardeeIn in ame_util.approverRecord2 default
                                             ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) as
     errorCode integer;
    errorMessage ame_util.longStringType;
    begin
      /* Validate the input approver. */
      if(approverIn.name is null) then
        raise ambiguousApproverException;
      end if;
      ame_engine.updateApprovalStatus(applicationIdIn => applicationIdIn,
                                 transactionTypeIn => transactionTypeIn,
                                 transactionIdIn => transactionIdIn,
                                 approverIn => approverIn,
                                 notificationIn => notificationIn,
                                 forwardeeIn => forwardeeIn,
                                 updateItemIn => updateItemIn);
      exception
        when ambiguousApproverException then
          errorCode := -20310;
          errorMessage := ambiguousApproverMessage;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus;
  procedure updateApprovalStatus2(applicationIdIn in number,
                                  transactionTypeIn in varchar2,
                                  transactionIdIn in varchar2,
                                  approvalStatusIn in varchar2,
                                  approverNameIn in varchar2,
                                  itemClassIn in varchar2 default null,
                                  itemIdIn in varchar2 default null,
                                  actionTypeIdIn in number default null,
                                  groupOrChainIdIn in number default null,
                                  occurrenceIn in number default null,
                                  notificationIn in ame_util2.notificationRecord
                                        default ame_util2.emptyNotificationRecord,
                                  forwardeeIn in ame_util.approverRecord2
                                        default ame_util.emptyApproverRecord2,
                                 updateItemIn in boolean default false) as
    approver ame_util.approverRecord2;
    errorCode integer;
    errorMessage ame_util.longStringType;
    nullApproverException exception;
    l_error_code number;
    begin
      /* No locking needed here as it is done in updateApprovalStatus */
      if  approverNameIn is not null  then
        approver.name := approverNameIn;
      else
        raise nullApproverException;
      end if;
      approver.item_class := itemClassIn ;
      approver.item_id := itemIdIn ;
      approver.approval_status := approvalStatusIn;
      approver.action_type_id :=actionTypeIdIn ;
      approver.group_or_chain_id := groupOrChainIdIn;
      approver.occurrence := occurrenceIn;
      begin
       ame_approver_type_pkg.getOrigSystemIdAndDisplayName(nameIn =>approver.name,
                                          origSystemOut => approver.orig_system,
                                          origSystemIdOut => approver.orig_system_id,
                                          displayNameOut => approver.display_name);
      exception
        when others then
          l_error_code := sqlcode;
          if l_error_code = -20213 then
          errorCode := -20224;
          errorMessage := ame_util.getMessage(applicationShortNameIn =>'PER',
                                              messageNameIn => 'AME_400837_INV_APR_FOUND',
                                              tokenNameOneIn  => 'PROCESS_NAME',
                                              tokenValueOneIn => 'ame_api6.updateApprovalStatus2',
                                              tokenNameTwoIn => 'NAME',
                                              tokenValueTwoIn => approver.name);
          raise_application_error(errorCode,errorMessage);
          end if;
          raise;
      end;
      ame_engine.updateApprovalStatus(applicationIdIn => applicationIdIn,
                           transactionIdIn => transactionIdIn,
                           approverIn => approver,
                           transactionTypeIn => transactionTypeIn,
                           notificationIn => notificationIn,
                           forwardeeIn => forwardeeIn,
                           updateItemIn => updateItemIn);
      exception
        when nullApproverException then
          errorCode := -20309;
          errorMessage := ambiguousApproverMessage;
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus2',
                                    exceptionNumberIn => errorCode,
                                    exceptionStringIn => errorMessage);
          raise_application_error(errorCode,
                                  errorMessage);
        when others then
          ame_util.runtimeException(packageNameIn => 'ame_api2',
                                    routineNameIn => 'updateApprovalStatus2',
                                    exceptionNumberIn => sqlcode,
                                    exceptionStringIn => sqlerrm);
          raise;
    end updateApprovalStatus2;

procedure getApprovers2(applicationIdIn   in number
                        ,transactionTypeIn in varchar2
                        ,transactionIdIn   in varchar2
                        ,approversOut     out nocopy ame_util.approversTable2) as
    ameApplicationId integer;
    tempIndex        integer;
    l_valid varchar2(50);
    l_display_name varchar2(200);
    cursor approversCursor  is
				SELECT   ol.name
				        ,ame_approver_type_pkg.getapproverdisplayname4 (ol.name) display_name
								,ol.approval_status
								,ol.approver_category
							  ,ol.authority
								,ol.action_type_id
								,ol.group_or_chain_id
								,ol.item_class
								,ol.item_id
				FROM    ame_temp_old_approver_lists ol
				       ,ame_trans_approval_history h
				       ,fnd_lookups lookup
				       ,fnd_lookups lookup2
				       ,fnd_lookups lookup3
				       ,ame_approval_groups_vl apg
				WHERE   ol.transaction_id = h.transaction_id
				AND     ol.application_id = h.application_id
				AND     ol.name = h.name
				AND     ol.item_class = h.item_class
				AND     ol.item_id = h.item_id
				AND     ol.api_insertion = h.api_insertion
				AND     ol.action_type_id = h.action_type_id
				AND     ol.authority = h.authority
				AND     ol.occurrence = h.occurrence
				AND     lookup.lookup_type (+) = 'AME_APPROVAL_STATUS'
				AND     lookup.lookup_code (+) = h.status
				AND     apg.approval_group_id (+) = ol.group_or_chain_id
				AND     (
				                h.status IS NULL
				        OR      h.status = 'APPROVE AND FORWARD'
				        OR      h.status = 'APPROVE'
				        OR      h.status = 'BEAT BY FIRST RESPONDER'
				        OR      h.status = 'FORWARD'
				        OR      h.status = 'NO RESPONSE'
				        OR      h.status = 'NOTIFIED'
				        OR      h.status = 'REJECT'
				        )
				AND     (
				                ol.approval_status IS NULL
				        OR      ol.approval_status = 'APPROVE AND FORWARD'
				        OR      ol.approval_status = 'APPROVE'
				        OR      ol.approval_status = 'BEAT BY FIRST RESPONDER'
				        OR      ol.approval_status = 'FORWARD'
				        OR      ol.approval_status = 'NO RESPONSE'
				        OR      ol.approval_status = 'NOTIFIED'
				        OR      ol.approval_status = 'REJECT'
				        )
				AND     h.date_cleared IS NULL
				AND     lookup2.lookup_type = 'AME_APPROVER_CATEGORY'
				AND     ol.approver_category = lookup2.lookup_code
				AND     h.transaction_id = transactionIdIn
				AND     h.application_id =
				        (
				        SELECT  application_id
				        FROM    ame_calling_apps
				        WHERE   SYSDATE BETWEEN start_date
				                        AND     nvl (end_date
				                                    ,SYSDATE)
				        AND     fnd_application_id = applicationIdIn
				        AND     transaction_type_id = transactionTypeIn
				        )
				AND     lookup3.lookup_type (+) = 'FND_WF_ORIG_SYSTEMS'
				AND     lookup3.lookup_code (+) = ame_approver_type_pkg.getapproverorigsystem3 (ol.name)
				AND     h.row_timestamp =
				        (
				        SELECT  max (b.row_timestamp)
				        FROM    ame_trans_approval_history b
				        WHERE   h.transaction_id = b.transaction_id
				        AND     h.application_id = b.application_id
				        AND     h.name = b.name
				        AND     h.approver_category = b.approver_category
				        AND     h.item_class = b.item_class
				        AND     h.item_id = b.item_id
				        AND     h.action_type_id = b.action_type_id
				        AND     h.authority = b.authority
				        AND     h.group_or_chain_id = b.group_or_chain_id
				        AND     h.occurrence = b.occurrence
				        AND     b.date_cleared IS NULL
				        )
				UNION
				SELECT  ol.name
				        ,ame_approver_type_pkg.getapproverdisplayname4 (ol.name) display_name
								,ol.approval_status
								,ol.approver_category
							  ,ol.authority
								,ol.action_type_id
								,ol.group_or_chain_id
								,ol.item_class
								,ol.item_id
				FROM    ame_temp_old_approver_lists ol
				       ,fnd_lookups lookup
				       ,fnd_lookups lookup2
				       ,fnd_lookups lookup3
				       ,ame_approval_groups_vl apg
				WHERE   NOT EXISTS
				        (
				        SELECT  x.transaction_id
				               ,x.application_id
				        FROM    ame_trans_approval_history x
				        WHERE   ol.transaction_id = x.transaction_id
				        AND     ol.name = x.name
				        AND     ol.application_id = x.application_id
				        AND     ol.item_class = x.item_class
				        AND     ol.item_id = x.item_id
				        AND     ol.api_insertion = x.api_insertion
				        AND     ol.action_type_id = x.action_type_id
				        AND     ol.authority = x.authority
				        AND     ol.occurrence = x.occurrence
				        )
				AND     ol.transaction_id = transactionIdIn
				AND     ol.application_id =
				        (
				        SELECT  application_id
				        FROM    ame_calling_apps
				        WHERE   SYSDATE BETWEEN start_date
				                        AND     nvl (end_date
				                                    ,SYSDATE)
				        AND     fnd_application_id = applicationIdIn
				        AND     transaction_type_id = transactionTypeIn
				        )
				AND     lookup.lookup_type (+) = 'AME_APPROVAL_STATUS'
				AND     lookup.lookup_code (+) = ol.approval_status
				AND     lookup2.lookup_type = 'AME_APPROVER_CATEGORY'
				AND     ol.approver_category = lookup2.lookup_code
				AND     apg.approval_group_id (+) = ol.group_or_chain_id
				AND     lookup3.lookup_type (+) = 'FND_WF_ORIG_SYSTEMS'
				AND     lookup3.lookup_code (+) = ame_approver_type_pkg.getapproverorigsystem3 (ol.name)
				AND     (
				                ol.approval_status IS NULL
				        OR      ol.approval_status = 'APPROVE AND FORWARD'
				        OR      ol.approval_status = 'APPROVE'
				        OR      ol.approval_status = 'BEAT BY FIRST RESPONDER'
				        OR      ol.approval_status = 'FORWARD'
				        OR      ol.approval_status = 'NO RESPONSE'
				        OR      ol.approval_status = 'NOTIFIED'
				        OR      ol.approval_status = 'REJECT'
				        );

    begin
      --+
      -- get the ame application id.
      --+
      tempIndex := 0;
      ameApplicationId :=
          ame_admin_pkg.getApplicationId
                            (fndAppIdIn          => applicationIdIn
                            ,transactionTypeIdIn => transactionTypeIn);

      for approver in approversCursor loop
        tempIndex := tempIndex + 1;
        approversOut(tempIndex).name := approver.name;
        approversOut(tempIndex).display_name := approver.display_name;
        approversOut(tempIndex).item_class := approver.item_class;
        approversOut(tempIndex).item_id    := approver.item_id;
        approversOut(tempIndex).approver_category := approver.approver_category;
        approversOut(tempIndex).authority := approver.authority;
        approversOut(tempIndex).approval_status := approver.approval_status;
        approversOut(tempIndex).action_type_id := approver.action_type_id;
        approversOut(tempIndex).group_or_chain_id := approver.group_or_chain_id;

        begin
          ame_approver_type_pkg.getApproverOrigSystemAndId
             (nameIn          => approver.name
             ,origSystemOut   => approversOut(tempIndex).orig_system
             ,origSystemIdOut => approversOut(tempIndex).orig_system_id);
        /*
          The old approver list does not maintain source.  Calling applications requiring
          source data must get it by calling getNextApprover or getAllApprovers.
        */
        exception
          when others then
             getApproverDetails(nameIn => approver.name
                                 ,validityOut     => l_valid
                                 ,displayNameOut  => l_display_name
                                 ,origSystemIdOut => approversOut(tempIndex).orig_system_id
                                 ,origSystemOut   => approversOut(tempIndex).orig_system);
            if l_valid = 'INVALID' then
              approversOut(tempIndex).orig_system_id := null;
              approversOut(tempIndex).orig_system := null;
            end if;
        end;
        approversOut(tempIndex).source := null;
      end loop;
    exception
      when others then
        ame_util.runtimeException(packageNameIn => 'ame_api6',
                                  routineNameIn => 'getApprovers2',
                                  exceptionNumberIn => sqlcode,
                                  exceptionStringIn => sqlerrm);
        approversOut.delete;
        raise;
    end getApprovers2;

end ame_api6;

/
