--------------------------------------------------------
--  DDL for Package Body ASO_APR_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_APR_WF_PVT" AS
  /*   $Header: asovwapb.pls 120.9.12010000.12 2017/01/10 07:02:28 rassharm ship $ */
  g_user_id                     NUMBER:= FND_GLOBAL.USER_ID;

  PROCEDURE start_aso_approvals (
    P_Object_approval_id  IN  NUMBER,
    P_itemtype_name       IN  VARCHAR2,
    P_sender_name         IN  VARCHAR2
  ) IS
    l_itemkey                     VARCHAR2 (30);
    l_itemtype                    VARCHAR2 (30);
    l_requestor_display_name      VARCHAR2 (240);
    l_object_approval_id          NUMBER;
    l_requestor_name              VARCHAR2 (240);
    l_quote_header_id number;

     CURSOR C_get_appr_id IS
     SELECT min(object_approval_id)
     FROM aso_apr_obj_approvals
     WHERE object_id = (SELECT object_id
                           FROM aso_apr_obj_approvals
                           WHERE object_approval_id = P_Object_approval_id)
     AND approval_status = 'PEND';

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin ASO_APR_WF_PVT package ',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Starting Approval Process for approval id ' || P_Object_approval_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Starting Approval Process for sender_name ' || P_sender_name,
        1,
        'N'
      );
    END IF;

    OPEN C_get_appr_id;
    FETCH C_get_appr_id INTO l_object_approval_id;
    CLOSE C_get_appr_id;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.ADD('l_object_approval_id: '|| l_object_approval_id,1,'N');
    END IF;

  IF (P_Object_approval_id  = l_object_approval_id) THEN

    l_itemtype                := P_itemtype_name;  --'ASOAPPRV';
    l_itemkey                 := TO_CHAR (
                                   P_Object_approval_id
                                 ) || 'HED';
    wf_engine.createprocess (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      process                      => 'STARTAPPROVALS'
    );
    wf_engine.setitemowner (
      l_itemtype, --'ASOAPPRV',
      l_itemkey,
      P_sender_name
    );
    wf_engine.setitemuserkey (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      userkey                      => l_itemkey
    );
    wf_engine.setitemattrtext (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      aname                        => 'REQUESTOR_USERNAME',
      avalue                       => P_sender_name
    );
    wf_engine.setitemattrnumber (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      aname                        => 'APPROVALID',
      avalue                       => P_Object_approval_id
    );

    wf_engine.setitemattrtext (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      aname                        => 'NEWPROCESSFLAG',
      avalue                       =>'Y'
    );


  l_requestor_display_name  := wf_directory.getroledisplayname (
                                   P_sender_name
                                 );

  -- Start : Code change done for Bug 18288445
  If l_requestor_display_name Is not null then
     EscapeString(l_requestor_display_name);
  End If;
  -- End : Code change done for Bug 18288445

    wf_engine.setitemattrtext (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey,
      aname                        => 'REQUESTOR_DISPLAYNAME',
      avalue                       => l_requestor_display_name
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Requester DisplayName is :' || l_requestor_display_name,
        1,
        'N'
      );
    END IF;

    wf_engine.startprocess (
      itemtype                     => l_itemtype,
      itemkey                      => l_itemkey
    );



   ELSE -- approval_id and obj_approval_id are not the same

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.ADD('Skipping the create approval workflow',1,'N');
       aso_debug_pub.ADD('***** NOTE: APPROVAL WORKFLOW PROCESS HAS NOT BEEN STARTED',1,'N');
      END IF;
   END IF;



    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of Start_ASO_Approvals ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Start_ASO_Approvals Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASO_APPROVE',
        'Start_ASO_Approvals',
        P_Object_approval_id,
        P_sender_name
      );
      RAISE;
  END start_aso_approvals;

  PROCEDURE submit_approval (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    next_seq                      NUMBER := -99;
    l_itemkey                     VARCHAR2 (30);
    l_approval_id                 NUMBER;
    l_requestor_name              VARCHAR2 (240);
    l_requestor_displayname       VARCHAR2 (240);
    l_forward_user_name           VARCHAR2 (240);
    l_forward_displayname         VARCHAR2 (240);
    l_quote_header_id number;
    l_qte_total       varchar2(500);
    l_user_id number;

    CURSOR LIST (
      c_approval_id                        NUMBER
    ) IS
      SELECT approval_det_id, approver_sequence, approver_person_id,
             approver_user_id
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_approval_id
            AND approver_status = 'NOSUBMIT'
      ORDER BY approver_sequence;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Sumbit_Approval Process',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      l_approval_id            := wf_engine.getitemattrnumber (
                                    itemtype,
                                    itemkey,
                                    'APPROVALID'
                                  );
      l_requestor_name         := wf_engine.getitemattrtext (
                                    itemtype,
                                    itemkey,
                                    'REQUESTOR_USERNAME'
                                  );
      l_requestor_displayname  :=
                              wf_engine.getitemattrtext (
                                itemtype,
                                itemkey,
                                'REQUESTOR_DISPLAYNAME'
                              );

      -- Start : Code change done for Bug 18288445
      If l_requestor_displayname Is not null then
         EscapeString(l_requestor_displayname);
      End If;
      -- End : Code change done for Bug 18288445

	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Object Approval ID is ' || l_approval_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Requester UserName is  ' || l_requestor_name,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Requester DisplayName is :' || l_requestor_displayname,
          1,
          'N'
        );
      END IF;

      FOR i IN LIST (
                 l_approval_id
               )
      LOOP
        IF (next_seq = -99)
        THEN
          next_seq  := i.approver_sequence;
        ELSIF next_seq = i.approver_sequence
        THEN
          NULL;
        ELSE
          EXIT;
        END IF;

        l_itemkey              := TO_CHAR (
                                    i.approval_det_id
                                  ) || 'DET';

        IF (i.approver_person_id IS NULL)
        THEN
          wf_directory.getrolename (
            'FND_USR',
            i.approver_user_id,
            l_forward_user_name,
            l_forward_displayname
          );
        ELSE
          wf_directory.getrolename (
            'PER',
            i.approver_person_id,
            l_forward_user_name,
            l_forward_displayname
          );
        END IF;

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Sumbit_Approval: RECEIVER USERNAME : ' || l_forward_user_name,
            1,
            'N'
          );
          aso_debug_pub.ADD (
            'Sumbit_Approval: RECEIVER_DISPLAYNAME : ' || l_forward_displayname,
            1,
            'N'
          );
          aso_debug_pub.ADD (
            'Sumbit_Approval: Creating Individual_approval Process for Itemkey'
            || l_itemkey,
            1,
            'N'
          );
        END IF;
        wf_engine.createprocess (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          process                      => 'INDIVIDUAL_APPROVAL'
        );
        wf_engine.setitemuserkey (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          userkey                      => l_itemkey
        );
        wf_engine.setitemattrnumber (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          aname                        => 'APPROVAL_DET_ID',
          avalue                       => i.approval_det_id
        );
        wf_engine.setitemattrtext (
          itemtype                     => itemtype, --'ASOAPPRV',
          itemkey                      => l_itemkey,
          aname                        => 'REQUESTOR_DISPLAYNAME',
          avalue                       => l_requestor_displayname
        );
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          aname                        => 'RECEIVER_USERNAME',
          avalue                       => l_forward_user_name
        );

       wf_engine.setitemattrtext (
         itemtype                     => itemtype,
         itemkey                      => itemkey,
         aname                        => 'NEWPROCESSFLAG',
         avalue                       =>'Y'
        );

        l_forward_displayname  :=
                             wf_directory.getroledisplayname (
                               l_forward_user_name
                             );
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          aname                        => 'RECEIVER_DISPLAYNAME',
          avalue                       => l_forward_displayname
        );
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,  --'ASOAPPRV',
          itemkey                      => l_itemkey,
          aname                        => 'REQUESTOR_USERNAME',
          avalue                       => l_requestor_name
        );
        wf_engine.setitemattrnumber (
          itemtype                     => itemtype,  --'ASOAPPRV',
          itemkey                      => l_itemkey,
          aname                        => 'APPROVALID',
          avalue                       => l_approval_id
        );
        -- Set the mesage name to copy submitter (FYI) message

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting the message name to OA_FYI_TO_REQUESTER',
            1,
            'N'
          );
        END IF;
        wf_engine.setitemattrtext (
          itemtype                     => itemtype, --'ASOAPPRV',
          itemkey                      => l_itemkey,
          aname                        => 'MESSAGE',
          avalue                       => 'OA_FYI_TO_REQUESTER'
        );
        -- define the parent child relationship

        wf_engine.setitemparent (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          parent_itemtype              => itemtype,
          parent_itemkey               => itemkey,
          parent_context               => NULL
        );

       select user_id into l_user_id
	from fnd_user
	where user_name like l_requestor_name;

         -- bug 23203161
	 SELECT object_id into l_quote_header_id
         FROM aso_apr_obj_approvals
         WHERE object_approval_id = l_approval_id;

	get_quote_total(p_quote_header_id => l_Quote_header_id ,
	p_user_id    => l_user_id,
	xquote_total  => l_qte_total);

	  wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey,
          aname                        => 'QUOTE_TOTAL',
          avalue                       => l_qte_total
        );
        wf_engine.startprocess (
          itemtype                     => itemtype,
          itemkey                      => l_itemkey
        );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Updating the approver status to PEND for object approval id :'
            || l_approval_id,
            1,
            'N'
          );
        END IF;



        UPDATE aso_apr_approval_details
        SET approver_status = 'PEND',
            date_sent = SYSDATE,
            last_update_date = SYSDATE,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.user_id
        WHERE object_approval_id = l_approval_id
              AND approver_sequence = next_seq;
      END LOOP;

      resultout                := 'COMPLETE' || ':' || wf_engine.eng_null;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End Sumbit_Approval Process',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of Sumbit_Approval Process',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of Sumbit_Approval Process',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Submit_Approvals Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'Submit_Approvals',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END submit_approval;

  PROCEDURE submit_next_batch (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_count                       NUMBER;
    l_approval_id                 NUMBER;
    l_approval_det_id             NUMBER;
    l_max_seq                     NUMBER;
    l_status                      VARCHAR2 (30);
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2 (10000);
    l_new_process_flag            VARCHAR2(1);


    CURSOR get_pend_sbmt_approvers (
      c_approval_id                        NUMBER
    ) IS
      SELECT COUNT (
               *
             )
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_approval_id
            AND approver_status = 'NOSUBMIT';

    CURSOR get_max_approver_seq (
      c_approval_id                        NUMBER
    ) IS
      SELECT MAX (
               approver_sequence
             )
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_approval_id;

    CURSOR get_tout_approvers (
      c_approval_id                        NUMBER,
      c_max_seq                            NUMBER
    ) IS
      SELECT COUNT (
               *
             )
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_approval_id
            AND approver_status = 'TOUT'
            AND approver_sequence = c_max_seq;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Sumbit_Next_Batch Process',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      l_approval_id      := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'APPROVALID'
                            );
      l_approval_det_id  := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'APPROVAL_DET_ID'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approval ID is ' || l_approval_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Approval Detail ID is ' || l_approval_det_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling the update approver list procedure ',
          1,
          'N'
        );
      END IF;
      -- Update the approver list if any rules have changed
      aso_apr_wf_pvt.update_approver_list (
        l_approval_id
      );
      OPEN get_pend_sbmt_approvers (
        l_approval_id
      );
      FETCH get_pend_sbmt_approvers INTO l_count;
      CLOSE get_pend_sbmt_approvers;

      IF l_count > 0
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Number of approvers who are in pending status are : ' || l_count,
            1,
            'N'
          );
        END IF;
        resultout  := 'COMPLETE:T';
      ELSE
        -- Checking whether Last Approver timed OUT NOCOPY /* file.sql.39 change */ if so treated as rejected
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'NO approvers in pending status',
            1,
            'N'
          );
        END IF;
        OPEN get_max_approver_seq (
          l_approval_id
        );
        FETCH get_max_approver_seq INTO l_max_seq;
        CLOSE get_max_approver_seq;
        OPEN get_tout_approvers (
          l_approval_id,
          l_max_seq
        );
        FETCH get_tout_approvers INTO l_count;
        CLOSE get_tout_approvers;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Number of approvers who have timed OUT NOCOPY /* file.sql.39 change */ are : ' || l_count,
            1,
            'N'
          );
        END IF;

        IF l_count > 0
        THEN
          -- Generate new list
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Calling procedure last approver timeout check ',
              1,
              'N'
            );
          END IF;
	  -- Commented for bug 16560286
       /*   aso_apr_wf_pvt.last_approver_timeout_check (
            l_approval_id
          );*/
          OPEN get_pend_sbmt_approvers (
            l_approval_id
          );
          FETCH get_pend_sbmt_approvers INTO l_count;
          CLOSE get_pend_sbmt_approvers;
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Number of approvers who are in pending status are : ' || l_count,
              1,
              'N'
            );
          END IF;

          IF l_count > 0
          THEN
            resultout  := 'COMPLETE:T';
            RETURN;
          ELSE
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.ADD (
                'Seting the status to rejected',
                1,
                'N'
              );
            END IF;
            l_status  := 'REJ';
            -- set the message name to that of final rejection  message

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.ADD (
                'Setting message name to OA_REQUEST_REJECTED',
                1,
                'N'
              );
            END IF;
            wf_engine.setitemattrtext (
              itemtype                     => itemtype,
              itemkey                      => itemkey,
              aname                        => 'MESSAGE',
              avalue                       => 'OA_REQUEST_REJECTED'
            );
          END IF;
        ELSE
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Seting the status to approved',
              1,
              'N'
            );
          END IF;
          l_status  := 'APPR';
          -- set the message name to that of final approval message
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Setting message name to OA_REQ_APPR_BY_ALL_APPR',
              1,
              'N'
            );
          END IF;
          wf_engine.setitemattrtext (
            itemtype                     => itemtype,
            itemkey                      => itemkey,
            aname                        => 'MESSAGE',
            avalue                       => 'OA_REQ_APPR_BY_ALL_APPR'
          );
        END IF;

       -- Update the approval table to to proper status
        aso_apr_wf_pvt.update_approval_status (
          p_update_header_or_detail_flag => 'HEADER',
          p_object_approval_id           => l_approval_id,
          p_approval_det_id              => null,
          p_status                       => l_status,
          note                           => null);


      /* For backward compatibility */
      BEGIN
      l_new_process_flag := wf_engine.getitemattrnumber (
                                    itemtype,
                                    itemkey,
                                    'NEWPROCESSFLAG'
                                  );

      exception
      when others then
      l_new_process_flag := 'N';
      END;

      IF l_new_process_flag = 'N' THEN
        -- Calling the procedure to update the quote status
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Calling update entity  procedure ',
            1,
            'N'
          );
        END IF;
          aso_apr_wf_pvt.update_entity (
          itemtype ,
          itemkey ,
          actid   ,
          funcmode,
          resultout
          );
      END IF;

       resultout  := 'COMPLETE:F';
   END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of Sumbit_Next_Batch Process',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of Sumbit_Next_Batch Process',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of Sumbit_Next_Batch Process',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Submit_next_batch Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.count_and_get (
        p_encoded                    => 'F',
        p_count                      => x_msg_count,
        p_data                       => x_msg_data
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'no. of FND messages :' || x_msg_count,
          1,
          'N'
        );
      END IF;

      FOR k IN 1 .. x_msg_count
      LOOP
        x_msg_data  := fnd_msg_pub.get (
                         p_msg_index                  => k,
                         p_encoded                    => 'F'
                       );
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Msg Data is' || x_msg_data,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SUBMIT_NEXT_BATCH ' || x_msg_data,
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END submit_next_batch;

  PROCEDURE check_rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_count                       NUMBER;
    l_approval_id                 NUMBER;
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2 (10000);
    l_new_process_flag            VARCHAR2(1);


    CURSOR get_rej_approver_count (
      c_approval_id                        NUMBER
    ) IS
      SELECT COUNT (
               *
             )
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_approval_id
            AND approver_status = 'REJ';
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin CHECK_REJECTED Procedure ',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      l_approval_id  := wf_engine.getitemattrnumber (
                          itemtype,
                          itemkey,
                          'APPROVALID'
                        );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approval ID is ' || l_approval_id,
          1,
          'N'
        );
      END IF;
      OPEN get_rej_approver_count (
        l_approval_id
      );
      FETCH get_rej_approver_count INTO l_count;
      CLOSE get_rej_approver_count;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Number of approvers who are in rejected status are : ' || l_count,
          1,
          'N'
        );
      END IF;

      IF l_count > 0
      THEN
        -- Calling the procedure to update the quote status
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Calling update quote procedure with status = REJ and approval id = '
            || l_approval_id,
            1,
            'N'
          );
        END IF;
        -- Set the message name to Final Rejection
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting message name to OA_REQUEST_REJECTED',
            1,
            'N'
          );
        END IF;
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => itemkey,
          aname                        => 'MESSAGE',
          avalue                       => 'OA_REQUEST_REJECTED'
        );


       aso_apr_wf_pvt.update_approval_status (
          p_update_header_or_detail_flag => 'HEADER',
          p_object_approval_id           => l_approval_id,
          p_approval_det_id              => null,
          p_status                       => 'REJ',
          note                           => null);


      /* For backward compatibility */
      BEGIN
      l_new_process_flag := wf_engine.getitemattrnumber (
                                    itemtype,
                                    itemkey,
                                    'NEWPROCESSFLAG'
                                  );

      exception
      when others then
      l_new_process_flag := 'N';
      END;

      IF l_new_process_flag = 'N' THEN
        -- Calling the procedure to update the quote status
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Calling update entity  procedure ',
            1,
            'N'
          );
        END IF;
          aso_apr_wf_pvt.update_entity (
          itemtype ,
          itemkey ,
          actid   ,
          funcmode,
          resultout
          );
      END IF;

        resultout  := 'COMPLETE:T';
      ELSE
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting message name to OA_REQ_APPR_BY_ALL_APPR',
            1,
            'N'
          );
        END IF;
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => itemkey,
          aname                        => 'MESSAGE',
          avalue                       => 'OA_REQ_APPR_BY_ALL_APPR'
        );
        resultout  := 'COMPLETE:F';
      END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of CHECK_REJECTED Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of CHECK_REJECTED Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of CHECK_REJECTED Procedure',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Check_rejected Procedure SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.count_and_get (
        p_encoded                    => 'F',
        p_count                      => x_msg_count,
        p_data                       => x_msg_data
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'no. of FND messages :' || x_msg_count,
          1,
          'N'
        );
      END IF;

      FOR k IN 1 .. x_msg_count
      LOOP
        x_msg_data  := fnd_msg_pub.get (
                         p_msg_index                  => k,
                         p_encoded                    => 'F'
                       );
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Msg Data is' || x_msg_data,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'CHECK_REJECTED  ' || x_msg_data,
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END check_rejected;

  PROCEDURE approved (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_approval_det_id             NUMBER;
    l_note                        VARCHAR2 (4000);
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin APPROVED Procedure ',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Seting message name to OA_REQUEST_APPROVED_FYI',
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'MESSAGE',
        avalue                       => 'OA_REQUEST_APPROVED_FYI'
      );
      l_approval_det_id  := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'APPROVAL_DET_ID'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approval detail ID is : ' || l_approval_det_id,
          1,
          'N'
        );
      END IF;
      l_note             := wf_engine.getitemattrtext (
                              itemtype,
                              itemkey,
                              'NOTE'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approver comments are: ' || SUBSTR (
                                         l_note,
                                         1,
                                         32
                                       ),
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling the update table procedure setting approver status to APPR',
          1,
          'N'
        );
      END IF;
     aso_apr_wf_pvt.update_approval_status (
         p_update_header_or_detail_flag => 'DETAIL' ,
         p_object_approval_id           => null,
         p_approval_det_id              =>l_approval_det_id,
         p_status                       => 'APPR',
         note                           => l_note);


      resultout          := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of APPROVED Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of APPROVED Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of APPROVED Procedure',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Approved Procedure SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'APPROVED',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END approved;

  PROCEDURE rejected (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_approval_det_id             NUMBER;
    l_note                        VARCHAR2 (4000);
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of REJECTED Procedure',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Seting message name to OA_REQUEST_REJECTED_FYI',
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'MESSAGE',
        avalue                       => 'OA_REQUEST_REJECTED_FYI'
      );
      l_approval_det_id  := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'APPROVAL_DET_ID'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approval detail ID is : ' || l_approval_det_id,
          1,
          'N'
        );
      END IF;
      l_note             := wf_engine.getitemattrtext (
                              itemtype,
                              itemkey,
                              'NOTE'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approver comments are: ' || SUBSTR (
                                         l_note,
                                         1,
                                         32
                                       ),
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling the update table procedure setting approver status to REJ',
          1,
          'N'
        );
      END IF;
     aso_apr_wf_pvt.update_approval_status (
         p_update_header_or_detail_flag => 'DETAIL' ,
         p_object_approval_id           => null,
         p_approval_det_id              =>l_approval_det_id,
         p_status                       => 'REJ',
         note                           => l_note);



      resultout          := 'COMPLETE';
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of REJECTED Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of REJECTED Procedure',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Rejected Procedure SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'REJECTED',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END rejected;

  PROCEDURE timedout (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_approval_det_id             NUMBER;
    l_note                        VARCHAR2 (4000);
    l_notification_id             NUMBER;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'begin TIMEDOUT Procedure',
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      l_notification_id  := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'NOTIFICATION_ID'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Cancelling notification for notification ID : ' || l_notification_id,
          1,
          'N'
        );
      END IF;
      wf_notification.CANCEL (
        nid                          => l_notification_id,
        cancel_comment               => 'TIMEOUT'
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Seting message name to OA_REQUEST_TIMEDOUT_FYI',
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'MESSAGE',
        avalue                       => 'OA_REQUEST_TIMEDOUT_FYI'
      );
      l_approval_det_id  := wf_engine.getitemattrnumber (
                              itemtype,
                              itemkey,
                              'APPROVAL_DET_ID'
                            );
      l_note             := wf_engine.getitemattrtext (
                              itemtype,
                              itemkey,
                              'NOTE'
                            );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Approver comments are: ' || SUBSTR (
                                         l_note,
                                         1,
                                         32
                                       ),
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Calling the update table procedure setting approver status to TOUT',
          1,
          'N'
        );
      END IF;
     aso_apr_wf_pvt.update_approval_status (
         p_update_header_or_detail_flag => 'DETAIL' ,
         p_object_approval_id           => null,
         p_approval_det_id              =>l_approval_det_id,
         p_status                       => 'TOUT',
         note                           => l_note);

      resultout          := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of TIMEDOUT Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of TIMEDOUT Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of TIMEDOUT Procedure',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Approved Procedure SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'TIMEDOUT',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END timedout;

  PROCEDURE cancelapproval (
    approval_id                 IN       NUMBER,
    p_itemtype                  IN       VARCHAR2,
    p_user_id                   IN       NUMBER
  ) IS
    l_approval_id                 NUMBER;
    l_itemkey                     VARCHAR2 (30);
    l_itemtype                    VARCHAR2 (30);
    l_requestor_name              VARCHAR2 (240);
    l_requestor_displayname       VARCHAR2 (240);
    l_timeout                     NUMBER;
    l_forward_user_name           VARCHAR2 (240);
    l_forward_displayname         VARCHAR2 (240);
    x_msg_data                    VARCHAR2 (10000);
    x_msg_count                   NUMBER;
    l_approval_object             VARCHAR2 (4000);
    l_cancellor_displayname       VARCHAR2 (240);
    l_cancellor_username          VARCHAR2 (240);

    CURSOR LIST (
      l_approval_id                        NUMBER
    ) IS
      SELECT approval_det_id, approver_sequence, approver_person_id,
             approver_user_id
      FROM aso_apr_approval_details
      WHERE object_approval_id = l_approval_id
            AND approver_status = 'PEND'
      ORDER BY approver_sequence;

    CURSOR get_requestor (
      l_approval_id                        NUMBER
    ) IS
      SELECT aoa.requester_userid, fu.employee_id
      FROM aso_apr_obj_approvals aoa, fnd_user fu
      WHERE object_approval_id = l_approval_id
            AND aoa.requester_userid = fu.user_id
            AND SYSDATE BETWEEN fu.start_date AND NVL (
                                                    fu.end_date,
                                                    SYSDATE
                                                  );
    CURSOR get_username(l_user_id NUMBER) IS
    SELECT user_name
    FROM fnd_user
    WHERE user_id = l_user_id;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin CancelApproval Procedure',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Aborting process for approval ID :' || approval_id,
        1,
        'N'
      );
    END IF;
    -- Updating the approval obj table status
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Updating table aso_apr_obj_approvals, status is CAN and approval id :'
        || approval_id,
        1,
        'N'
      );
    END IF;

  aso_apr_wf_pvt.update_approval_status (
    p_update_header_or_detail_flag => 'HEADER' ,
    p_object_approval_id           => approval_id,
    p_approval_det_id              =>null,
    p_status                       => 'CAN',
    note                           => null);

    wf_engine.abortprocess (
      itemtype                     => p_itemtype, --'ASOAPPRV',
      itemkey                      => TO_CHAR (
                                        approval_id
                                      ) || 'HED',
      process                      => '',
      result                       => 'CANCELLED'
    );
    l_approval_id            := approval_id;
    l_itemtype               := p_itemtype; --'ASOAPPRV';
    l_itemkey                := TO_CHAR (
                                  approval_id
                                ) || 'CAN';

    FOR i IN get_requestor (
               l_approval_id
             )
    LOOP
      IF i.employee_id IS NOT NULL
      THEN
        wf_directory.getrolename (
          'PER',
          i.employee_id,
          l_requestor_name,
          l_requestor_displayname
        );
      ELSE
        wf_directory.getrolename (
          'FND_USR',
          i.requester_userid,
          l_requestor_name,
          l_requestor_displayname
        );
      END IF;

      l_requestor_displayname  :=
                                wf_directory.getroledisplayname (
                                  l_requestor_name
                                );

      -- Start : Code change done for Bug 18288445
      If l_requestor_displayname Is not null then
          EscapeString(l_requestor_displayname);
      End If;
      -- End : Code change done for Bug 18288445

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Requester Displayname is :' || l_requestor_displayname,
          1,
          'N'
        );
      END IF;
    END LOOP;

    -- Get the display name of the request cancellor

    OPEN get_username(p_user_id);
    FETCH get_username INTO l_cancellor_username;
    CLOSE get_username;

    l_cancellor_displayname  :=
                            wf_directory.getroledisplayname (
                              l_cancellor_username
                            );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Cancellor  Displayname is :' || l_cancellor_displayname,
        1,
        'N'
      );
    END IF;

    FOR i IN LIST (
               l_approval_id
             )
    LOOP
      IF (i.approver_person_id IS NULL)
      THEN
        wf_directory.getrolename (
          'FND_USR',
          i.approver_user_id,
          l_forward_user_name,
          l_forward_displayname
        );
      ELSE
        wf_directory.getrolename (
          'PER',
          i.approver_person_id,
          l_forward_user_name,
          l_forward_displayname
        );
      END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Completing Activity Notify Approve Requisition for approval detail ID :'
          || i.approval_det_id,
          1,
          'N'
        );
      END IF;

	 -- fix for bug 3130487
	 BEGIN
	 wf_engine.completeactivityinternalname (
        p_itemtype, --'ASOAPPRV',
        TO_CHAR (
          i.approval_det_id
        ) || 'DET',
        'NOTIFY_APPROVE_REQUISITION',
        'CANCELLED'
      );

	 EXCEPTION
	 WHEN OTHERS THEN
        aso_debug_pub.ADD (
          SQLERRM,
          1,
          'N'
        );
	 END;

	 -- end fix for  bug 3130487

	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Aborting process for approval detail ID :' || i.approval_det_id,
          1,
          'N'
        );
      END IF;
      wf_engine.abortprocess (
        itemtype                     => p_itemtype, --'ASOAPPRV',
        itemkey                      => TO_CHAR (
                                          i.approval_det_id
                                        ) || 'DET',
        process                      => '',
        result                       => 'CANCELLED'
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Starting  process CANCEL_REQUISITION itemtype is '
          || l_itemtype
          || ' and itemkey is '
          || l_itemkey,
          1,
          'N'
        );
      END IF;
      wf_engine.createprocess (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        process                      => 'CANCEL_REQUISITION'
      );
      wf_engine.setitemuserkey (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        userkey                      => l_itemkey
      );
      wf_engine.setitemattrnumber (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        aname                        => 'APPROVAL_DET_ID',
        avalue                       => i.approval_det_id
      );
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype, --'ASOAPPRV',
        itemkey                      => l_itemkey,
        aname                        => 'REQUESTOR_DISPLAYNAME',
        avalue                       => l_requestor_displayname
      );
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype, --'ASOAPPRV',
        itemkey                      => l_itemkey,
        aname                        => 'REQUESTOR_USERNAME',
        avalue                       => l_requestor_name
      );
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        aname                        => 'RECEIVER_USERNAME',
        avalue                       => l_forward_user_name
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Receiver username is ' || l_forward_user_name,
          1,
          'N'
        );
      END IF;
      l_forward_displayname  :=
                             wf_directory.getroledisplayname (
                               l_forward_user_name
                             );
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        aname                        => 'RECEIVER_DISPLAYNAME',
        avalue                       => l_forward_displayname
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Receiver displayname  is ' || l_forward_displayname,
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        aname                        => 'REQUEST_CANCELLOR_USERNAME',
        avalue                       => l_cancellor_username
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Cancellor username  is ' || l_cancellor_username,
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey,
        aname                        => 'REQUEST_CANCELLOR_DISPLAYNAME',
        avalue                       => l_cancellor_displayname
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Cancellor displayname  is ' || l_cancellor_displayname,
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrnumber (
        itemtype                     => l_itemtype, --'ASOAPPRV',
        itemkey                      => l_itemkey,
        aname                        => 'APPROVALID',
        avalue                       => l_approval_id
      );

      wf_engine.startprocess (
        itemtype                     => l_itemtype,
        itemkey                      => l_itemkey
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Updating detail table setting approver status to cancelled where det id :'
          || i.approval_det_id,
          1,
          'N'
        );
      END IF;

      UPDATE aso_apr_approval_details
      SET approver_status = 'CAN',
          date_sent = SYSDATE,
          last_update_date = SYSDATE,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.user_id
      WHERE approval_det_id = i.approval_det_id;
    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of CancelApproval Procedure',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in CancelApproval SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.count_and_get (
        p_encoded                    => 'F',
        p_count                      => x_msg_count,
        p_data                       => x_msg_data
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'no. of FND messages :' || x_msg_count,
          1,
          'N'
        );
      END IF;

      FOR k IN 1 .. x_msg_count
      LOOP
        x_msg_data  := fnd_msg_pub.get (
                         p_msg_index                  => k,
                         p_encoded                    => 'F'
                       );
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Msg Data is' || x_msg_data,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'CancelApproval ' || x_msg_data,
        approval_id
      );
      RAISE;
  END cancelapproval;

  PROCEDURE send_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_requestor_display_name      VARCHAR2 (240);
    l_message                     VARCHAR2 (240);
    l_notification_id             NUMBER := 0;
    l_first_colon_pos             NUMBER := 0;
    l_second_colon_pos            NUMBER := 0;
    v_new_resultout               VARCHAR2 (100);
    l_notifenabled                VARCHAR2 (3) := 'Y';
    l_orgid                       NUMBER := NULL;
    l_approval_id                 NUMBER;
    x_return_status               VARCHAR2 (240);
    x_msg_count                   NUMBER;
    --x_msg_data                    VARCHAR2 (240);
    x_msg_data                    VARCHAR2 (2000); -- bug 13508417
    l_msgenabled                  VARCHAR2 (3) := 'Y';
    l_notifname                   VARCHAR2 (240);
    get_message_error             EXCEPTION;
    notif_not_enabled_error       EXCEPTION;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start of SEND NOTIFICATION Procedure',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'actid is ' || TO_CHAR (
                         actid
                       ),
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      --  Please note that the notification event name is same as message name
      l_notifname     := wf_engine.getitemattrtext (
                           itemtype,
                           itemkey,
                           'MESSAGE'
                         );
      l_message       := l_notifname;
      l_notifname     := 'ASO_' || l_notifname;
      -- Check if the notification is enabled for that event

      l_notifenabled  := ibe_wf_notif_setup_pvt.check_notif_enabled (
                           l_notifname
                         );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Notification Name: ' || l_notifname || ' Enabled: ' || l_notifenabled,
          1,
          'N'
        );
      END IF;

      IF l_notifenabled = 'Y'
      THEN
        -- Get the approval id
        l_approval_id  := wf_engine.getitemattrnumber (
                            itemtype,
                            itemkey,
                            'APPROVALID'
                          );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Approval ID :' || l_approval_id,
            1,
            'N'
          );
        END IF;
        -- get the org id
        /*OPEN get_org_id (
          l_approval_id
        );
        FETCH get_org_id INTO l_orgid;
        CLOSE get_org_id; */

        l_orgid  := wf_engine.getitemattrnumber (
                            itemtype,
                            itemkey,
                            'ORGID'
                          );

        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Org Id is ' || l_orgid,
            1,
            'N'
          );
        END IF;
        -- Retreive the message name for that event

         x_return_status := fnd_api.g_ret_sts_success;

        ibe_wf_msg_mapping_pvt.retrieve_msg_mapping (
          p_org_id                     => l_orgid,
          p_msite_id                   => NULL,
          p_user_type                  => NULL,
          p_notif_name                 => l_notifname,
          x_enabled_flag               => l_msgenabled,
          x_wf_message_name            => l_message,
          x_return_status              => x_return_status,
          x_msg_data                   => x_msg_data,
          x_msg_count                  => x_msg_count
        );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Message Name: ' || l_message || ' Enabled: ' || l_msgenabled,
            1,
            'N'
          );
        END IF;

        -- bug 3295179
        IF ( (x_return_status <> fnd_api.g_ret_sts_success) OR (l_message IS NULL) )
	   --IF ((x_msg_count > 0)
        --    OR (l_message IS NULL)
        --   )
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Message count is :' || x_msg_count,
              1,
              'N'
            );
          END IF;
          RAISE get_message_error;
        END IF;

        IF l_msgenabled = 'Y'
        THEN
          -- Set the message name
          wf_engine.setitemattrtext (
            itemtype                     => itemtype,
            itemkey                      => itemkey,
            aname                        => 'MESSAGE',
            avalue                       => l_message
          );
        END IF;
      END IF;

      IF (l_msgenabled <> 'Y')
         OR (l_notifenabled <> 'Y')
      THEN
        -- if the event is not enabled or message is not enabled
        -- if the notification requires a response
        IF ((l_message LIKE 'REQUEST_APPROVAL%') OR (l_message LIKE 'OA_REQUEST_APPROVAL%'))
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Notification not enabled for REQUEST_APPROVAL',
              1,
              'N'
            );
          END IF;
          RAISE notif_not_enabled_error;
        ELSE
          -- if the notification is a FYI
          -- Check for FYI Message and if so make the attribute as Approval Message
          IF ((l_message LIKE 'FYI_TO_REQUESTER%') OR  (l_message LIKE 'OA_FYI_TO_REQUESTER%'))
          THEN
            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
              aso_debug_pub.ADD (
                'Setting the message name to OA_REQUEST_APPROVAL',
                1,
                'N'
              );
            END IF;
            wf_engine.setitemattrtext (
              itemtype                     => itemtype,
              itemkey                      => itemkey,
              aname                        => 'MESSAGE',
              avalue                       => 'OA_REQUEST_APPROVAL'
            );
          END IF;

          resultout  := 'COMPLETE';
          RETURN;
        END IF;
      END IF;

      l_message       := wf_engine.getitemattrtext (
                           itemtype,
                           itemkey,
                           'MESSAGE'
                         );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Message is ' || l_message,
          1,
          'N'
        );
      END IF;

      IF ((l_message LIKE 'REQUEST_APPROVAL_REMINDER%') OR (l_message LIKE 'OA_REQUEST_APPROVAL_REM%'))
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'As Message is REQUEST_APPROVAL_REMINDER will cancel original approval notif',
            1,
            'N'
          );
        END IF;
        l_notification_id  := wf_engine.getitemattrnumber (
                                itemtype,
                                itemkey,
                                'NOTIFICATION_ID'
                              );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Cancelling notification for notification ID :' || l_notification_id,
            1,
            'N'
          );
        END IF;
        wf_notification.CANCEL (
          nid                          => l_notification_id,
          cancel_comment               => 'TIMEOUT'
        );
      END IF;

      wf_standard.notify (
        itemtype,
        itemkey,
        actid,
        funcmode,
        resultout
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Calling the standard notify process for Itemtype :'
          || itemtype
          || ' and itemkey :'
          || itemkey,
          1,
          'N'
        );
      END IF;
      -- Store the Notification id for timeout

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Storing the notification id so as to be used in timeout case ',
          1,
          'N'
        );
      END IF;

      IF (resultout IS NOT NULL)
      THEN
        l_first_colon_pos   := INSTR (
                                 resultout,
                                 ':',
                                 1,
                                 1
                               );
        l_second_colon_pos  := INSTR (
                                 resultout,
                                 ':',
                                 1,
                                 2
                               );

        IF ((l_first_colon_pos <> 0)
            AND (l_second_colon_pos <> 0)
           )
        THEN
          l_notification_id  := TO_NUMBER (
                                  SUBSTR (
                                    resultout,
                                    l_first_colon_pos + 1,
                                    l_second_colon_pos - l_first_colon_pos - 1
                                  )
                                );
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Notification id is ' || l_notification_id,
              1,
              'N'
            );
          END IF;
          wf_engine.setitemattrnumber (
            itemtype                     => itemtype,
            itemkey                      => itemkey,
            aname                        => 'NOTIFICATION_ID',
            avalue                       => l_notification_id
          );
        END IF;
      END IF;

      -- Check for FYI Message and if so make the attribute as Approval Message
      IF ((l_message LIKE 'FYI_TO_REQUESTER%') or (l_message LIKE 'OA_FYI_TO_REQUESTER%'))
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting the message name to OA_REQUEST_APPROVAL',
            1,
            'N'
          );
        END IF;
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => itemkey,
          aname                        => 'MESSAGE',
          avalue                       => 'OA_REQUEST_APPROVAL'
        );
      ELSIF ((l_message LIKE 'REQUEST_APPROVAL%') or (l_message LIKE 'OA_REQUEST_APPROVAL%'))
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting the message name to OA_REQUEST_APPROVAL_REM',
            1,
            'N'
          );
        END IF;
        wf_engine.setitemattrtext (
          itemtype                     => itemtype,
          itemkey                      => itemkey,
          aname                        => 'MESSAGE',
          avalue                       => 'OA_REQUEST_APPROVAL_REM'
        );
      END IF;

      --   resultout := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of SEND NOTIFICATION Procedure ',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of SEND NOTIFICATION Procedure ',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of SEND NOTIFICATION Procedure ',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN notif_not_enabled_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in SEND_NOTIFICATION Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SEND_NOTIFICATION',
        'Mandatory Notification Name: ' || l_notifname || ' is not Enabled '
      );
      RAISE;
    WHEN get_message_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in SEND_NOTIFICATION Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SEND_NOTIFICATION',
        'Error in retreiving Notification Message',
        'Message Name: ' || l_message || ' Enabled: ' || l_msgenabled
      );
      RAISE;
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in SEND_NOTIFICATION Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SEND_NOTIFICATION',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END send_notification;

  PROCEDURE update_entity (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_contract_approval_level     VARCHAR2 (240);
    l_quote_header_rec            aso_quote_pub.qte_header_rec_type;
    l_control_rec                 aso_quote_pub.control_rec_type;
    x_qte_header_rec              aso_quote_pub.qte_header_rec_type;
    x_qte_line_tbl                aso_quote_pub.qte_line_tbl_type;
    x_qte_line_dtl_tbl            aso_quote_pub.qte_line_dtl_tbl_type;
    x_hd_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_hd_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_hd_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_hd_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_hd_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    x_line_attr_ext_tbl           aso_quote_pub.line_attribs_ext_tbl_type;
    x_line_rltship_tbl            aso_quote_pub.line_rltship_tbl_type;
    x_price_adjustment_tbl        aso_quote_pub.price_adj_tbl_type;
    x_price_adj_attr_tbl          aso_quote_pub.price_adj_attr_tbl_type;
    x_price_adj_rltship_tbl       aso_quote_pub.price_adj_rltship_tbl_type;
    x_ln_price_attributes_tbl     aso_quote_pub.price_attributes_tbl_type;
    x_ln_payment_tbl              aso_quote_pub.payment_tbl_type;
    x_ln_shipment_tbl             aso_quote_pub.shipment_tbl_type;
    x_ln_freight_charge_tbl       aso_quote_pub.freight_charge_tbl_type;
    x_ln_tax_detail_tbl           aso_quote_pub.tax_detail_tbl_type;
    x_return_status               VARCHAR2 (240);
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2 (240);
    l_user_id                     Number;
    l_person_id                   Number;
    l_object_approval_id          NUMBER;
    l_status                      varchar2(20);
    l_notifname                   varchar2(240);
    CURSOR get_quote_header_id (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT object_id
      FROM aso_apr_obj_approvals
      WHERE object_approval_id = c_object_approval_id;

    CURSOR check_contract_enabled (
      c_quote_header_id                    NUMBER
    ) IS
      SELECT contract_approval_level
      FROM aso_quote_headers_all
      WHERE quote_header_id = c_quote_header_id;

    CURSOR get_latest_date (
      c_quote_header_id                    NUMBER
    ) IS
      SELECT last_update_date,org_id
      FROM aso_quote_headers_all
      WHERE quote_header_id = c_quote_header_id;

    CURSOR get_quote_status_id (
      v_status                             VARCHAR2
    ) IS
      SELECT quote_status_id
      FROM aso_quote_statuses_b
      WHERE status_code = v_status;

    CURSOR get_last_approver (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT approver_person_id
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id
      AND approver_sequence = (select max(approver_sequence)
                              FROM aso_apr_approval_details
                              WHERE object_approval_id = c_object_approval_id);

    CURSOR get_user_id ( c_employee_id NUMBER)
    IS
    SELECT user_id
    FROM fnd_user
    WHERE employee_id = c_employee_id;



    CURSOR get_rejected_approver (c_object_approval_id NUMBER) IS
    SELECT  approver_person_id
    FROM aso_apr_approval_details
    WHERE object_approval_id = c_object_approval_id
    AND approver_status = 'REJ';

 BEGIN
    -- Initialize the quote header record

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin Update Entity  Procedure ',
        1,
        'N'
      );
   END IF;

   IF funcmode = 'RUN' THEN

     l_object_approval_id  := wf_engine.getitemattrnumber (
                          itemtype,
                          itemkey,
                          'APPROVALID'
                        );

      l_notifname     := wf_engine.getitemattrtext (
                           itemtype,
                           itemkey,
                           'MESSAGE'
                         );
     IF l_notifname = 'OA_REQUEST_REJECTED' then
       l_status := 'REJ';
     ELSIF l_notifname = 'OA_REQ_APPR_BY_ALL_APPR' THEN
       l_status := 'APPR';
     END IF;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Object approval ID :' || l_object_approval_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Status :' || l_status,
        1,
        'N'
      );
     END IF;
       --g_user_id                        := fnd_global.user_id;
    -- fix for bug 3929409
    IF l_status = 'APPR' THEN
         OPEN get_last_approver (
              l_object_approval_id
          );
         FETCH get_last_approver INTO l_person_id;
         CLOSE get_last_approver;

	    OPEN get_user_id(l_person_id);
	    FETCH get_user_id INTO l_user_id;
	    CLOSE get_user_id;

	    g_user_id  := l_user_id;
    ELSIF l_status = 'REJ' THEN
	    OPEN get_rejected_approver(l_object_approval_id);
	    FETCH get_rejected_approver into l_person_id;
	    CLOSE get_rejected_approver;

         OPEN get_user_id(l_person_id);
         FETCH get_user_id INTO l_user_id;
         CLOSE get_user_id;
         g_user_id                        := l_user_id;

    ELSE
        g_user_id                        := fnd_global.user_id;

    END IF;

       FND_GLOBAL.APPS_INITIALIZE(g_user_id,0,0,0);


    l_quote_header_rec               := aso_quote_pub.g_miss_qte_header_rec;

    OPEN get_quote_header_id (
      l_object_approval_id
    );
    FETCH get_quote_header_id INTO l_quote_header_rec.quote_header_id;
    CLOSE get_quote_header_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Quote Header ID :' || l_quote_header_rec.quote_header_id,
        1,
        'N'
      );
    END IF;
    -- Check if contract is enabled for the quote
    OPEN check_contract_enabled (
      l_quote_header_rec.quote_header_id
    );
    FETCH check_contract_enabled INTO l_contract_approval_level;
    CLOSE check_contract_enabled;

    -- setting the quote status id
    IF l_status = 'APPR'
    THEN
      -- if contract is enabled, set status to contract enables
      IF l_contract_approval_level IS NOT NULL
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting Quote Status to CONTRACT REQUIRED',
            1,
            'N'
          );
        END IF;
        OPEN get_quote_status_id (
          'CONTRACT REQUIRED'
        );
        FETCH get_quote_status_id INTO l_quote_header_rec.quote_status_id;
        CLOSE get_quote_status_id;
      ELSE
        -- otherwise set status to APPROVED
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting Quote Status to APPROVED',
            1,
            'N'
          );
        END IF;
        OPEN get_quote_status_id (
          'APPROVED'
        );
        FETCH get_quote_status_id INTO l_quote_header_rec.quote_status_id;
        CLOSE get_quote_status_id;
      END IF;
    ELSIF l_status = 'REJ'
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Setting Quote Status to REJECTED',
          1,
          'N'
        );
      END IF;
      OPEN get_quote_status_id (
        'APPROVAL REJECTED'
      );
      FETCH get_quote_status_id INTO l_quote_header_rec.quote_status_id;
      CLOSE get_quote_status_id;
    ELSIF l_status = 'CAN'
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Setting Quote Status to APPROVAL CANCELLED ',
          1,
          'N'
        );
      END IF;
      OPEN get_quote_status_id (
        'APPROVAL CANCELED'
      );
      FETCH get_quote_status_id INTO l_quote_header_rec.quote_status_id;
      CLOSE get_quote_status_id;
    ELSIF l_status = 'PEND'
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Setting Quote Status to APPROVAL PENDING',
          1,
          'N'
        );
      END IF;
      OPEN get_quote_status_id (
        'APPROVAL PENDING'
      );
      FETCH get_quote_status_id INTO l_quote_header_rec.quote_status_id;
      CLOSE get_quote_status_id;
    END IF;

    OPEN get_latest_date (
      l_quote_header_rec.quote_header_id
    );
    FETCH get_latest_date INTO l_quote_header_rec.last_update_date, l_quote_header_rec.org_id;
    CLOSE get_latest_date;
    --  Setting the auto version flag to true
    l_control_rec.auto_version_flag  := fnd_api.g_true;

    -- set the org context , see bug 4731684
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Before calling update quote: Setting the single org context to org_id:  '|| l_quote_header_rec.org_id,
        1,
        'N'
      );
    END IF;
    mo_global.set_policy_context('S', l_quote_header_rec.org_id);


    --  Update the quote status by calling the update_quote API

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling the update quote API in ASO_UPDATE_QUOTE_PUB package ',
        1,
        'N'
      );
    END IF;
    aso_quote_pub.update_quote (
      p_api_version_number         => 1.0,
      p_init_msg_list              => fnd_api.g_false,
      p_commit                     => fnd_api.g_false,
      p_control_rec                => l_control_rec,
      p_qte_header_rec             => l_quote_header_rec,
      p_hd_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_hd_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_hd_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_hd_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_hd_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      p_qte_line_tbl               => aso_quote_pub.g_miss_qte_line_tbl,
      p_qte_line_dtl_tbl           => aso_quote_pub.g_miss_qte_line_dtl_tbl,
      p_line_attr_ext_tbl          => aso_quote_pub.g_miss_line_attribs_ext_tbl,
      p_line_rltship_tbl           => aso_quote_pub.g_miss_line_rltship_tbl,
      p_price_adjustment_tbl       => aso_quote_pub.g_miss_price_adj_tbl,
      p_price_adj_attr_tbl         => aso_quote_pub.g_miss_price_adj_attr_tbl,
      p_price_adj_rltship_tbl      => aso_quote_pub.g_miss_price_adj_rltship_tbl,
      p_ln_price_attributes_tbl    => aso_quote_pub.g_miss_price_attributes_tbl,
      p_ln_payment_tbl             => aso_quote_pub.g_miss_payment_tbl,
      p_ln_shipment_tbl            => aso_quote_pub.g_miss_shipment_tbl,
      p_ln_freight_charge_tbl      => aso_quote_pub.g_miss_freight_charge_tbl,
      p_ln_tax_detail_tbl          => aso_quote_pub.g_miss_tax_detail_tbl,
      x_qte_header_rec             => x_qte_header_rec,
      x_qte_line_tbl               => x_qte_line_tbl,
      x_qte_line_dtl_tbl           => x_qte_line_dtl_tbl,
      x_hd_price_attributes_tbl    => x_hd_price_attributes_tbl,
      x_hd_payment_tbl             => x_hd_payment_tbl,
      x_hd_shipment_tbl            => x_hd_shipment_tbl,
      x_hd_freight_charge_tbl      => x_hd_freight_charge_tbl,
      x_hd_tax_detail_tbl          => x_hd_tax_detail_tbl,
      x_line_attr_ext_tbl          => x_line_attr_ext_tbl,
      x_line_rltship_tbl           => x_line_rltship_tbl,
      x_price_adjustment_tbl       => x_price_adjustment_tbl,
      x_price_adj_attr_tbl         => x_price_adj_attr_tbl,
      x_price_adj_rltship_tbl      => x_price_adj_rltship_tbl,
      x_ln_price_attributes_tbl    => x_ln_price_attributes_tbl,
      x_ln_payment_tbl             => x_ln_payment_tbl,
      x_ln_shipment_tbl            => x_ln_shipment_tbl,
      x_ln_freight_charge_tbl      => x_ln_freight_charge_tbl,
      x_ln_tax_detail_tbl          => x_ln_tax_detail_tbl,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );

    IF x_return_status <> fnd_api.g_ret_sts_success
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Return Status from update quote API is :' || x_return_status,
          1,
          'N'
        );
      END IF;


      /*bug 3500380 */
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
	 --RAISE update_quote_exception;


    END IF;

    -- set the org context , see bug 4731684
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'After calling update quote Setting the org context to multi-org  org_id:null',
        1,
        'N'
      );
    END IF;

     mo_global.set_policy_context('M',null);


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End update entity  procedure ',
        1,
        'N'
      );
    END IF;

    resultout  := 'COMPLETE:T';
  END IF;
  EXCEPTION

     /*bug 3500380 */
     WHEN FND_API.G_EXC_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in update entity    ',
          1,
          'N'
        );
      END IF;
         wf_core.CONTEXT (
        'ASOAPPRV',
        'update_entity',
        itemtype,
        itemkey,
        TO_CHAR(actid),
	   funcmode);
	 RAISE;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in update entity    ',
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'update_entity',
        itemtype,
        itemkey,
        TO_CHAR(actid),
        funcmode);
	RAISE;

     WHEN OTHERS THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in update entity    ',
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'update_entity',
        itemtype,
        itemkey,
        TO_CHAR(actid),
        funcmode);
      RAISE;

  END update_entity;

  PROCEDURE update_approver_list (
    p_object_approval_id        IN       NUMBER
  ) IS
    l_approvers_changed_flag      VARCHAR2 (1) := 'N';
    l_last_approved_approver      NUMBER := 0;
    x_approvers_list              aso_apr_pub.approvers_list_tbl_type;
    x_rules_list                  aso_apr_pub.rules_list_tbl_type;
    l_return_status               VARCHAR2 (20);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2 (2000);
    l_object_id                   NUMBER;
    l_object_type                 VARCHAR2 (240);
    l_application_id              NUMBER;
    l_approver_status             VARCHAR2 (30);
    l_approval_det_id             NUMBER;
    l_approver_person_id          NUMBER;
    l_approver_user_id            NUMBER;
    l_approver_count              NUMBER;
    j                             INTEGER;
    p_rule_id                     NUMBER;
    get_all_approvers_failed      EXCEPTION;
    l_oam_rule_id                 NUMBER;
    l_rule_count                  NUMBER;
    l_rules_changed_flag          VARCHAR2 (1) := 'N';

    TYPE existing_approvers_tbl_type IS TABLE OF aso_apr_approval_details%ROWTYPE
      INDEX BY BINARY_INTEGER;

    l_new_approvers_tbl           existing_approvers_tbl_type;
    l_employee_id                 NUMBER;

    CURSOR get_object_id (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT DISTINCT object_id, object_type, application_id
      FROM aso_apr_obj_approvals
      WHERE object_approval_id = c_object_approval_id;

    CURSOR get_existing_approvers (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT approval_det_id, approver_person_id, approver_user_id,
             approver_status
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id
      ORDER BY approver_sequence;

    CURSOR get_approver_count (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT COUNT (
               *
             )
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id;

    CURSOR get_old_approvers (
      c_object_approval_id                 NUMBER,
      c_approval_det_id                    NUMBER
    ) IS
      SELECT *
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id
            AND approval_det_id = c_approval_det_id;

    CURSOR get_existing_rules (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT oam_rule_id
      FROM aso_apr_rules
      WHERE object_approval_id = c_object_approval_id
      ORDER BY rule_id;

    CURSOR get_rule_count (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT COUNT (
               *
             )
      FROM aso_apr_rules
      WHERE object_approval_id = c_object_approval_id;

   cursor get_employee_id(l_user_id NUMBER) IS
   select employee_id
   from fnd_user
   where user_id = l_user_id;


  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin update approver list procedure   ',
        1,
        'N'
      );
    END IF;
    g_user_id  := fnd_global.user_id;
    -- get the latest list of approvers
    OPEN get_object_id (
      p_object_approval_id
    );
    FETCH get_object_id INTO l_object_id, l_object_type, l_application_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Object ID :' || l_object_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Type :' || l_object_type,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'application id :' || l_application_id,
        1,
        'N'
      );
    END IF;
    -- calling the get all approvers to get the latest list of approvers
    -- please note that we are passing the clear transaction flag as false
    -- this is to ensure that get all approvers does not clear transactions

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling get_all_approvers',
        1,
        'N'
      );
    END IF;
    aso_apr_int.get_all_approvers (
      1.0,
      fnd_api.g_false,
      fnd_api.g_false,
      l_object_id,
      l_object_type,
      l_application_id, ---p_application_id,
      fnd_api.g_false, --- p_clear_transaction_flag
      l_return_status,
      l_msg_count,
      l_msg_data,
      x_approvers_list,
      x_rules_list
    );
    CLOSE get_object_id;

    -- Checking to find OUT NOCOPY /* file.sql.39 change */ if call to get_all_approvers was successfull
    IF l_return_status <> fnd_api.g_ret_sts_success
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Status returned from get_all_approvers procedure :' || l_return_status,
          1,
          'N'
        );
      END IF;
      -- RAISE get_all_approvers_failed;
      RETURN;
    END IF;

  -- fix for bug 4590633

    for i in 1..x_approvers_list.count loop

        IF ((x_approvers_list(i).approver_person_id is null) or (x_approvers_list(i).approver_person_id = fnd_api.g_miss_num) and
            (x_approvers_list(i).approver_user_id is not null) and (x_approvers_list(i).approver_user_id <>  fnd_api.g_miss_num)) then

           IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.ADD ('Person_id is null from AME Hence deriving it from user_id',1,'N');
           END IF;

            open get_employee_id(x_approvers_list(i).approver_user_id);
            fetch get_employee_id into x_approvers_list(i).approver_person_id;
            close get_employee_id;

            IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
             aso_debug_pub.ADD ('Derived person_id is: '||to_char(x_approvers_list(i).approver_person_id),1,'N');
            END IF;

        END IF;
    end loop;

   -- end of fix for bug 4590633

    --- comparing the count between old and new list
    OPEN get_approver_count (
      p_object_approval_id
    );
    FETCH get_approver_count INTO l_approver_count;
    CLOSE get_approver_count;

    IF l_approver_count <> x_approvers_list.COUNT
    THEN
      l_approvers_changed_flag  := 'Y';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'The approvers list has changed   ',
          1,
          'N'
        );
      END IF;
    ELSE
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Comparing the old list from table and the latest list    ',
          1,
          'N'
        );
      END IF;
      -- first loop to find OUT NOCOPY /* file.sql.39 change */ if the data has changed
      OPEN get_existing_approvers (
        p_object_approval_id
      );

      FOR i IN 1 .. x_approvers_list.COUNT
      LOOP
        FETCH get_existing_approvers INTO l_approval_det_id,
                                          l_approver_person_id,
                                          l_approver_user_id,
                                          l_approver_status;
        EXIT WHEN get_existing_approvers%NOTFOUND;

        -- Make sure that if miss num is passed back from ame api, then it is
        -- converted into a null

        IF x_approvers_list (
             i
           ).approver_person_id = fnd_api.g_miss_num
        THEN
          x_approvers_list (
            i
          ).approver_person_id                     := NULL;
        END IF;

        IF x_approvers_list (
             i
           ).approver_user_id = fnd_api.g_miss_num
        THEN
          x_approvers_list (
            i
          ).approver_user_id                     := NULL;
        END IF;

        IF ((l_approver_person_id <> x_approvers_list (
                                       i
                                     ).approver_person_id
            )
            OR (l_approver_user_id <> x_approvers_list (
                                        i
                                      ).approver_user_id
               )
           )
        THEN
          l_approvers_changed_flag  := 'Y';
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The approvers list has changed   ',
              1,
              'N'
            );
          END IF;
          EXIT;
        ELSE
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The approvers list has not changed   ',
              1,
              'N'
            );
          END IF;
          l_approvers_changed_flag  := 'N';
        END IF;
      END LOOP;

      CLOSE get_existing_approvers;
    END IF;

    -- if the data has changed

    IF l_approvers_changed_flag = 'Y'
    THEN
      -- copying latest list into the new data structure ( x to y)

      FOR i IN 1 .. x_approvers_list.COUNT
      LOOP
        l_new_approvers_tbl (
          i
        ).approver_user_id                          :=
                                          x_approvers_list (
                                            i
                                          ).approver_user_id;
        l_new_approvers_tbl (
          i
        ).approver_person_id                        :=
                                        x_approvers_list (
                                          i
                                        ).approver_person_id;
        l_new_approvers_tbl (
          i
        ).approver_sequence                         := i;
        -- Initialize the manadatory columns
        l_new_approvers_tbl (
          i
        ).creation_date                             := SYSDATE;
        l_new_approvers_tbl (
          i
        ).last_update_date                          := SYSDATE;
        l_new_approvers_tbl (
          i
        ).object_approval_id                        := p_object_approval_id;
      END LOOP;

      -- comparing new data structure and existing approvers in database and if person or user id matches, copying
      --  existing approvers into the new data structure  ( comparing Y and E and copying E to Y )

      FOR i IN get_existing_approvers (
                 p_object_approval_id
               )
      LOOP
        FOR k IN 1 .. l_new_approvers_tbl.COUNT
        LOOP
          IF ((i.approver_person_id = l_new_approvers_tbl (
                                        k
                                      ).approver_person_id
              )
              OR (i.approver_user_id = l_new_approvers_tbl (
                                         k
                                       ).approver_user_id
                 )
             )
          THEN
            OPEN get_old_approvers (
              p_object_approval_id,
              i.approval_det_id
            );
            FETCH get_old_approvers INTO l_new_approvers_tbl (
                                           k
                                         );
            CLOSE get_old_approvers;
          END IF;
        END LOOP;
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Deleting approvers from detail table where object_approval_id :'
          || p_object_approval_id,
          1,
          'N'
        );
      END IF;

      DELETE FROM aso_apr_approval_details
      WHERE object_approval_id = p_object_approval_id;

      l_approver_status  := NULL;
      -- third loop to insert the data

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'New Approver count is ' || TO_CHAR (
                                        l_new_approvers_tbl.COUNT
                                      ),
          1,
          'N'
        );
      END IF;
      -- traversing the data structure from bottom up
      j                  := l_new_approvers_tbl.COUNT;

      WHILE j <> 0
      LOOP
        -- if new list has more records   than the old list , update the new approvers with pend status
        IF l_new_approvers_tbl (
             j
           ).approver_status IS NULL
        THEN
          l_new_approvers_tbl (
            j
          ).approver_status                        := 'NOSUBMIT';
        END IF;

        -- because of the new list if the last approver is skipped, make him pending
        IF ((l_new_approvers_tbl (
               j
             ).approver_status = 'SKIP'
            )
            AND (j = l_new_approvers_tbl.COUNT)
           )
        THEN
          l_new_approvers_tbl (
            j
          ).approver_status                        := 'NOSUBMIT';
        END IF;

        -- Mark the highest authority who approved in the old list

        IF ((l_new_approvers_tbl (
               j
             ).approver_status IN ('APPR', 'SKIP')
            )
            AND (l_last_approved_approver = 0)
           )
        THEN
          l_last_approved_approver  := j;
        END IF;

        --  Make the approvers who are below the old highest authority as skipped
        IF ((j < l_last_approved_approver)
            AND (l_new_approvers_tbl (
                   j
                 ).approver_status = 'NOSUBMIT'
                )
           )
        THEN
          l_new_approvers_tbl (
            j
          ).approver_status                        := 'SKIP';
        END IF;

        aso_apr_approvals_pkg.detail_insert_row (
          l_new_approvers_tbl (
            j
          ).approval_det_id,
          l_new_approvers_tbl (
            j
          ).object_approval_id,
          l_new_approvers_tbl (
            j
          ).approver_person_id ---p_APPROVER_PERSON_ID
          ,
          l_new_approvers_tbl (
            j
          ).approver_user_id ---p_APPROVER_USER_ID
          ,
          j -- P_APPROVER_SEQUENCE
          ,
          l_new_approvers_tbl (
            j
          ).approver_status --p_APPROVER_STATUS
          ,
          l_new_approvers_tbl (
            j
          ).approver_comments -- p_APPROVER_COMMENTS
          ,
          l_new_approvers_tbl (
            j
          ).date_sent --p_DATE_SENT
          ,
          l_new_approvers_tbl (
            j
          ).date_received -- p_DATE_RECEIVED
          ,
          l_new_approvers_tbl (
            j
          ).creation_date -- p_CREATION_DATE
          ,
          SYSDATE -- p_LAST_UPDATE_DATE
          ,
          l_new_approvers_tbl (
            j
          ).created_by -- P_CREATED_BY
          ,
          g_user_id -- P_UPDATED_BY
          ,
          fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
          ,
          l_new_approvers_tbl (
            j
          ).attribute1 -- p_ATTRIBUTE1
          ,
          l_new_approvers_tbl (
            j
          ).attribute2 -- p_ATTRIBUTE2
          ,
          l_new_approvers_tbl (
            j
          ).attribute3 -- p_ATTRIBUTE3
          ,
          l_new_approvers_tbl (
            j
          ).attribute4 -- p_ATTRIBUTE4
          ,
          l_new_approvers_tbl (
            j
          ).attribute5 -- p_ATTRIBUTE5
          ,
          l_new_approvers_tbl (
            j
          ).attribute6 -- p_ATTRIBUTE6
          ,
          l_new_approvers_tbl (
            j
          ).attribute7 -- p_ATTRIBUTE7
          ,
          l_new_approvers_tbl (
            j
          ).attribute8 -- p_ATTRIBUTE8
          ,
          l_new_approvers_tbl (
            j
          ).attribute9 -- p_ATTRIBUTE9
          ,
          l_new_approvers_tbl (
            j
          ).attribute10 -- p_ATTRIBUTE10
          ,
          l_new_approvers_tbl (
            j
          ).attribute11 --  p_ATTRIBUTE11
          ,
          l_new_approvers_tbl (
            j
          ).attribute12 -- p_ATTRIBUTE12
          ,
          l_new_approvers_tbl (
            j
          ).attribute13 -- p_ATTRIBUTE13
          ,
          l_new_approvers_tbl (
            j
          ).attribute14 -- p_ATTRIBUTE14
          ,
          l_new_approvers_tbl (
            j
          ).attribute15 -- p_ATTRIBUTE15
          ,
          l_new_approvers_tbl (
            j
          ).attribute16 -- p_ATTRIBUTE16
          ,
          l_new_approvers_tbl (
            j
          ).attribute17 -- p_ATTRIBUTE17
          ,
          l_new_approvers_tbl (
            j
          ).attribute18 -- p_ATTRIBUTE18
          ,
          l_new_approvers_tbl (
            j
          ).attribute19 -- p_ATTRIBUTE19
          ,
          l_new_approvers_tbl (
            j
          ).attribute20 -- p_ATTRIBUTE20
          ,
		l_new_approvers_tbl (
            j
          ).CONTEXT -- p_CONTEXT
          ,
          l_new_approvers_tbl (
            j
          ).security_group_id -- p_SECURITY_GROUP_ID
          ,
          l_new_approvers_tbl (
            j
          ).object_version_number -- p_OBJECT_VERSION_NUMBER
        );
        j  := j - 1;
      END LOOP;
    END IF;

    -- Loop to find OUT NOCOPY /* file.sql.39 change */ if the rules have changed

    OPEN get_rule_count (
      p_object_approval_id
    );
    FETCH get_rule_count INTO l_rule_count;
    CLOSE get_rule_count;

    IF l_rule_count <> x_rules_list.COUNT
    THEN
      l_rules_changed_flag  := 'Y';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'The rules have changed   ',
          1,
          'N'
        );
      END IF;
    ELSE
      OPEN get_existing_rules (
        p_object_approval_id
      );

      FOR i IN 1 .. x_rules_list.COUNT
      LOOP
        FETCH get_existing_rules INTO l_oam_rule_id;
        EXIT WHEN get_existing_rules%NOTFOUND;

        -- Make sure that if miss num is passed back from ame api, then it is
        -- converted into a null

        IF x_rules_list (
             i
           ).rule_id = fnd_api.g_miss_num
        THEN
          x_rules_list (
            i
          ).rule_id                 := NULL;
        END IF;

        IF (l_oam_rule_id <> x_rules_list (
                               i
                             ).rule_id
           )
        THEN
          l_rules_changed_flag  := 'Y';
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The rules have changed   ',
              1,
              'N'
            );
          END IF;
          EXIT;
        ELSE
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'The rules have not changed   ',
              1,
              'N'
            );
          END IF;
          l_rules_changed_flag  := 'N';
        END IF;
      END LOOP;

      CLOSE get_existing_rules;
    END IF;

    -- refresh the rules if they are changed

    IF l_rules_changed_flag = 'Y'
    THEN
      -- delete the existing rules
      DELETE FROM aso_apr_rules
      WHERE object_approval_id = p_object_approval_id;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Inserting rows into the rule table ',
          1,
          'N'
        );
      END IF;

      FOR i IN 1 .. x_rules_list.COUNT
      LOOP
        aso_apr_approvals_pkg.rule_insert_row (
          p_rule_id,
          x_rules_list (
            i
          ).rule_id,
          x_rules_list (
            i
          ).rule_action_id,
          SYSDATE --p_CREATION_DATE
          ,
          g_user_id -- P_CREATED_BY
          ,
          SYSDATE -- p_LAST_UPDATE_DATE
          ,
          g_user_id -- P_UPDATED_BY
          ,
          fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
          ,
          p_object_approval_id,
          NULL -- p_ATTRIBUTE1
          ,
          NULL -- p_ATTRIBUTE2
          ,
          NULL -- p_ATTRIBUTE3
          ,
          NULL -- p_ATTRIBUTE4
          ,
          NULL -- p_ATTRIBUTE5
          ,
          NULL -- p_ATTRIBUTE6
          ,
          NULL -- p_ATTRIBUTE7
          ,
          NULL -- p_ATTRIBUTE8
          ,
          NULL -- p_ATTRIBUTE9
          ,
          NULL -- p_ATTRIBUTE10
          ,
          NULL -- p_ATTRIBUTE11
          ,
          NULL -- p_ATTRIBUTE12
          ,
          NULL -- p_ATTRIBUTE13
          ,
          NULL -- p_ATTRIBUTE14
          ,
          NULL -- p_ATTRIBUTE15
          ,
          NULL -- p_Attribute16
          ,
          NULL -- p_Attribute17
          ,
          NULL  -- p_Attribute18
          ,
          NULL -- p_Attribute19
          ,
          NULL -- p_Attribute20
	     ,
		NULL -- p_CONTEXT
          ,
          NULL -- p_SECURITY_GROUP_ID
          ,
          NULL -- p_OBJECT_VERSION_NUMBER
        );
      END LOOP;
    END IF;
    -- commit the  work
    COMMIT WORK;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End update_approver_list procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN get_all_approvers_failed
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Call to get_all_approvers failed in update_approver_list ',
          1,
          'N'
        );
      END IF;
      fnd_msg_pub.count_and_get (
        p_encoded                    => 'F',
        p_count                      => l_msg_count,
        p_data                       => l_msg_data
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'no. of FND messages :' || l_msg_count,
          1,
          'N'
        );
      END IF;

      FOR k IN 1 .. l_msg_count
      LOOP
        l_msg_data  := fnd_msg_pub.get (
                         p_msg_index                  => k,
                         p_encoded                    => 'F'
                       );
      END LOOP;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Msg Data is' || l_msg_data,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'Update_approver_list',
        'msg data ' || l_msg_data
      );
      RAISE;
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'When others exception in update approver list procedure ',
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'Update_approver_list',
        SUBSTR (
          SQLERRM,
          1,
          250
        )
      );
      RAISE;
  END update_approver_list;

  PROCEDURE last_approver_timeout_check (
    p_object_approval_id        IN       NUMBER
  ) IS
    new_approver_record           ame_util.approverrecord;
    l_approver_sequence           NUMBER;
    l_approval_det_id             NUMBER;
    l_object_id                   NUMBER;
    l_object_type                 VARCHAR2 (240);
    l_application_id              NUMBER;

    CURSOR get_approvers (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT approval_det_id
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id;

    CURSOR get_approver_sequence (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT MAX (
               approver_sequence
             ) + 1
      FROM aso_apr_approval_details
      WHERE object_approval_id = c_object_approval_id;

    CURSOR get_application_id (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT DISTINCT object_id, object_type, application_id
      FROM aso_apr_obj_approvals aoa
      WHERE object_approval_id = c_object_approval_id;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin the last_approver_timeout_check prcoedure ',
        1,
        'N'
      );
    END IF;
    g_user_id  := fnd_global.user_id;
    OPEN get_application_id (
      p_object_approval_id
    );
    FETCH get_application_id INTO l_object_id, l_object_type, l_application_id;
    CLOSE get_application_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Object ID :' || l_object_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Type :' || l_object_type,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'application id :' || l_application_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Calling the AME clearall approvals API',
        1,
        'N'
      );
    END IF;
    ame_api.clearallapprovals (
      applicationidin              => l_application_id,
      transactionidin              => l_object_id,
      transactiontypein            => l_object_type
    );

    FOR i IN get_approvers (
               p_object_approval_id
             )
    LOOP
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'calling the AME  get next approver  API ',
          1,
          'N'
        );
      END IF;
      ame_api.getnextapprover (
        applicationidin              => l_application_id,
        transactionidin              => l_object_id,
        transactiontypein            => l_object_type,
        nextapproverout              => new_approver_record
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'New Approver Person ID :' || new_approver_record.person_id,
          1,
          'N'
        );
        aso_debug_pub.ADD (
          'Setting approval status to no response for previous approvers ',
          1,
          'N'
        );
      END IF;
      new_approver_record.approval_status  := ame_util.noresponsestatus;
      ame_api.updateapprovalstatus (
        applicationidin              => l_application_id,
        transactionidin              => l_object_id,
        transactiontypein            => l_object_type,
        approverin                   => new_approver_record
      );
    END LOOP;

    -- after getting all the approvers, try to get the next approver

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'calling the AME  get next approver  API ',
        1,
        'N'
      );
    END IF;
    ame_api.getnextapprover (
      applicationidin              => l_application_id,
      transactionidin              => l_object_id,
      transactiontypein            => l_object_type,
      nextapproverout              => new_approver_record
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'New Approver Person ID :' || new_approver_record.person_id,
        1,
        'N'
      );
    END IF;

    IF (((new_approver_record.person_id IS NOT NULL)
         AND (new_approver_record.person_id <> fnd_api.g_miss_num)
        )
        OR ((new_approver_record.user_id IS NOT NULL)
            AND (new_approver_record.user_id <> fnd_api.g_miss_num)
           )
       )
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Additional Approver found ',
          1,
          'N'
        );
      END IF;
      OPEN get_approver_sequence (
        p_object_approval_id
      );
      FETCH get_approver_sequence INTO l_approver_sequence;
      CLOSE get_approver_sequence;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Inserting the new approver  into the detail table   ',
          1,
          'N'
        );
      END IF;
      aso_apr_approvals_pkg.detail_insert_row (
        l_approval_det_id,
        p_object_approval_id,
        new_approver_record.person_id --p_APPROVER_PERSON_ID
        ,
        new_approver_record.user_id --p_APPROVER_USER_ID
        ,
        l_approver_sequence -- P_APPROVER_SEQUENCE
        ,
        'NOSUBMIT' --p_APPROVER_STATUS
        ,
        NULL -- p_APPROVER_COMMENTS
        ,
        NULL --p_DATE_SENT
        ,
        NULL -- p_DATE_RECEIVED
        ,
        SYSDATE -- p_CREATION_DATE
        ,
        SYSDATE -- p_LAST_UPDATE_DATE
        ,
        g_user_id -- P_CREATED_BY
        ,
        g_user_id -- P_UPDATED_BY
        ,
        fnd_global.conc_login_id -- p_LAST_UPDATE_LOGIN
        ,
        NULL -- p_ATTRIBUTE1
        ,
        NULL -- p_ATTRIBUTE2
        ,
        NULL -- p_ATTRIBUTE3
        ,
        NULL -- p_ATTRIBUTE4
        ,
        NULL -- p_ATTRIBUTE5
        ,
        NULL -- p_ATTRIBUTE6
        ,
        NULL -- p_ATTRIBUTE7
        ,
        NULL -- p_ATTRIBUTE8
        ,
        NULL -- p_ATTRIBUTE9
        ,
        NULL -- p_ATTRIBUTE10
        ,
        NULL --  p_ATTRIBUTE11
        ,
        NULL -- p_ATTRIBUTE12
        ,
        NULL -- p_ATTRIBUTE13
        ,
        NULL -- p_ATTRIBUTE14
        ,
        NULL -- p_ATTRIBUTE15
        ,
        NULL -- p_Attribute16
        ,
        NULL -- p_Attribute17
        ,
        NULL  -- p_Attribute18
        ,
        NULL -- p_Attribute19
        ,
        NULL -- p_Attribute20
        ,
        NULL -- p_CONTEXT
        ,
        NULL -- p_SECURITY_GROUP_ID
        ,
        NULL -- p_OBJECT_VERSION_NUMBER
      );
    ELSE
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'No Additional Approvers found ',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of last_approver_timeout_check procedure   ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Last_Approver_Timeout_Check  ',
          1,
          'N'
        );
      END IF;
      RETURN;
  END last_approver_timeout_check;

  PROCEDURE send_cancel_notification (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    l_message                     VARCHAR2 (240);
    l_notifenabled                VARCHAR2 (3) := 'Y';
    l_orgid                       NUMBER := NULL;
    l_approval_id                 NUMBER;
    x_return_status               VARCHAR2 (240);
    x_msg_count                   NUMBER;
    --x_msg_data                    VARCHAR2 (240);
    x_msg_data                    VARCHAR2 (2000); -- bug 13508417
    l_msgenabled                  VARCHAR2 (3) := 'Y';
    l_notifname                   VARCHAR2 (240);
    get_message_error             EXCEPTION;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin SEND_CANCEL_NOTIFICATION Procedure',
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'actid is ' || TO_CHAR (
                         actid
                       ),
        1,
        'N'
      );
    END IF;

    IF funcmode = 'RUN'
    THEN
      l_message       := wf_engine.getitemattrtext (
                           itemtype,
                           itemkey,
                           'MESSAGE'
                         );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Message is ' || l_message,
          1,
          'N'
        );
      END IF;

      -- Check for FYI  Cancel Message and if so make the attribute as Cancel Message to approver
      IF ((l_message LIKE 'REQUEST_CANCELLED_FYI%') or (l_message LIKE 'OA_REQUEST_CANCELLED_FYI%'))
      THEN
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting message to OA_REQUEST_CANCEL_FYI_TO_APPR',
            1,
            'N'
          );
        END IF;
        l_message  := 'OA_REQ_CANCEL_FYI_TO_APPR';
      ELSE
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Setting message to OA_REQUEST_CANCELLED_FYI',
            1,
            'N'
          );
        END IF;
        l_message  := 'OA_REQUEST_CANCELLED_FYI';
      END IF;

      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'MESSAGE',
        avalue                       => l_message
      );
      --  Please note that the notification event name is same as message name

      l_notifname     := wf_engine.getitemattrtext (
                           itemtype,
                           itemkey,
                           'MESSAGE'
                         );
      l_notifname     := 'ASO_' || l_notifname;
      l_notifenabled  := ibe_wf_notif_setup_pvt.check_notif_enabled (
                           l_notifname
                         );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Notification Name: ' || l_notifname || ' Enabled: ' || l_notifenabled,
          1,
          'N'
        );
      END IF;

      IF l_notifenabled = 'Y'
      THEN
        -- Get the approval id
        l_approval_id  := wf_engine.getitemattrnumber (
                            itemtype,
                            itemkey,
                            'APPROVALID'
                          );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Approval Id is ' || l_approval_id,
            1,
            'N'
          );
        END IF;
        -- get the org id
        /*OPEN get_org_id (
          l_approval_id
        );
        FETCH get_org_id INTO l_orgid;
        CLOSE get_org_id; */
        l_orgid  := wf_engine.getitemattrnumber (
                            itemtype,
                            itemkey,
                            'ORGID'
                          );

	   IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Org Id is ' || l_orgid,
            1,
            'N'
          );
        END IF;
        -- Retreive the message name for that event
         x_return_status := fnd_api.g_ret_sts_success;

        ibe_wf_msg_mapping_pvt.retrieve_msg_mapping (
          p_org_id                     => l_orgid,
          p_msite_id                   => NULL,
          p_user_type                  => 'ALL',
          p_notif_name                 => l_notifname,
          x_enabled_flag               => l_msgenabled,
          x_wf_message_name            => l_message,
          x_return_status              => x_return_status,
          x_msg_data                   => x_msg_data,
          x_msg_count                  => x_msg_count
        );

        -- Check if the call to MSG mapping API was succssfull
        -- bug 3295179
	   IF x_return_status <> fnd_api.g_ret_sts_success
	   --IF x_msg_count > 0
        THEN
          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.ADD (
              'Message count from MSG mapping API :' || x_msg_count,
              1,
              'N'
            );
          END IF;
          RAISE get_message_error;
        END IF;
      ELSE
        -- If the notification is not enabled
        resultout  := 'COMPLETE';
      END IF;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Calling the standard notify process ',
          1,
          'N'
        );
      END IF;
      wf_standard.notify (
        itemtype,
        itemkey,
        actid,
        funcmode,
        resultout
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End SEND_CANCEL_NOTIFICATION Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    IF (funcmode = 'CANCEL')
    THEN
      resultout  := 'COMPLETE';
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'End of SEND_CANCEL_NOTIFICATION Procedure',
          1,
          'N'
        );
      END IF;
      RETURN;
    END IF;

    resultout  := '';
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End of SEND_CANCEL_NOTIFICATION Procedure',
        1,
        'N'
      );
    END IF;
    RETURN;
  EXCEPTION
    WHEN get_message_error
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in SEND_NOTIFICATION Proc SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SEND_CANCEL_NOTIFICATION',
        'Error in retreiving Notification Message',
        'Message Name: ' || l_message || ' Enabled: ' || l_msgenabled
      );
      RAISE;
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in SEND_CANCEL_NOTIFICATION Process SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'SEND_CANCEL_NOTIFICATION',
        itemtype,
        itemkey,
        TO_CHAR (
          actid
        ),
        funcmode
      );
      RAISE;
  END send_cancel_notification;

  PROCEDURE approver_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_approval_id                 NUMBER;
    l_approver_user_name          VARCHAR2 (240);
    l_approver_display_name       VARCHAR2 (240);
    l_approver_status             VARCHAR2 (10);
    l_approver_comments           VARCHAR2 (4000);
    l_attribute_tbl               aso_attribute_label_tbl_type;

    CURSOR approver_details (
      c_object_approval_id                 NUMBER
    ) IS
      SELECT approver_user_id, approver_person_id, fl.meaning, approver_comments
      FROM aso_apr_approval_details apd, aso_lookups fl
      WHERE apd.approver_status = fl.lookup_code
            AND object_approval_id = c_object_approval_id
            AND fl.lookup_type = 'ASO_APPROVER_STATUS'
      ORDER BY approver_sequence;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin  APPROVER_DETAILS_DOC procedure ',
        1,
        'N'
      );
    END IF;
    itemtype       := NVL (
                        SUBSTR (
                          document_id,
                          1,
                          INSTR (
                            document_id,
                            ':'
                          ) - 1
                        ),
                        'ASOAPPRV'
                      );
    itemkey        := SUBSTR (
                        document_id,
                        INSTR (
                          document_id,
                          ':'
                        ) + 1
                      ) || 'HED';
    l_approval_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'APPROVALID'
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'ItemType is:' || itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemKey is :' || itemkey,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval ID :' || l_approval_id,
        1,
        'N'
      );
    END IF;
    -- get the attribute label
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling the get_attribute_label procedure',
        1,
        'N'
      );
    END IF;
    get_attribute_label (
      l_approval_id,
      l_attribute_tbl
    );

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/html',
          1,
          'N'
        );
      END IF;
      document       := document
                        || '<span class=sectionHeader1>'
                        || l_attribute_tbl (
                             11
                           )
                        || '</span>';
      document       :=
        document
        || '<table class=OraBGAccentDark width="75%" cellpadding="1", cellspacing="1" border="0">';
      document       :=
                      document
                      || '<tr> <td class="tableSmallHeaderCell" align="center">'
                      || l_attribute_tbl (
                           12
                         )
                      || '</td>';
      document       := document
                        || '<td class="tableSmallHeaderCell" align="center">'
                        || l_attribute_tbl (
                             13
                           )
                        || '</td>';
      document       := document || '</tr>';

      FOR i IN approver_details (
                 l_approval_id
               )
      LOOP
        l_approver_display_name  :=
                            aso_apr_int.get_approver_name (
                              i.approver_user_id,
                              i.approver_person_id
                            );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Approver Name is  ' || l_approver_display_name,
            1,
            'N'
          );
        END IF;
        document                 := document || '<tr>';
        document                 := document
                                    || '<td class="tableDataCell">'
                                    || l_approver_display_name
                                    || '</td>';
        document                 := document
                                    || '<td class="tableDataCell">'
                                    || i.meaning
                                    || '</td>';
        document                 := document || '</tr>';
      END LOOP;

      document       := document || '</table>';
      document_type  := 'text/html';
    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/plain',
          1,
          'N'
        );
      END IF;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      11
                                    );
      document       := document || fnd_global.local_chr (
                                      10
                                    );

      FOR i IN approver_details (
                 l_approval_id
               )
      LOOP
        -- get the approver name
        l_approver_display_name  :=
                            aso_apr_int.get_approver_name (
                              i.approver_user_id,
                              i.approver_person_id
                            );
        document                 := document || fnd_global.local_chr (
                                                  10
                                                );
        document                 := document || l_attribute_tbl (
                                                  12
                                                );
        document                 := document || ': ';
        document                 := document || l_approver_display_name;
        document                 := document || fnd_global.local_chr (
                                                  10
                                                );
        document                 := document || l_attribute_tbl (
                                                  13
                                                );
        document                 := document || ': ';
        document                 := document || i.meaning;
      END LOOP;

      document_type  := 'text/plain';
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End APPROVER_DETAILS_DOC procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in APPROVER_DETAILS_DOC SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'APPROVER_DETAILS_DOC',
        itemtype,
        itemkey
      );
      RAISE;
  END approver_details_doc;

  PROCEDURE quote_summary_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_approval_id                 NUMBER;
    l_quote_name                  VARCHAR2 (240);
    l_quote_version               VARCHAR2 (240);
    l_quote_number                VARCHAR2 (240);
    l_quote_price                 VARCHAR2 (240);
    l_customer_name               VARCHAR2 (240);
    l_account_number              VARCHAR2 (240);
    l_contact_name                VARCHAR2 (240);
    l_opportunity_name            VARCHAR2 (240);
    l_expiration_date             DATE;
    l_attribute_tbl               aso_attribute_label_tbl_type;
    -- hyang performance fix, bug 2860045
    l_quote_header_id             NUMBER;
   l_party_type                   VARCHAR2(240);
    CURSOR get_object_details (
      c_approval_id                        NUMBER
    ) IS
      SELECT quote_header_id, quote_name, quote_number, quote_expiration_date
      FROM aso_quote_headers_all qha, aso_apr_obj_approvals aoa
      WHERE qha.quote_header_id = aoa.object_id
            AND aoa.object_approval_id = c_approval_id;

    CURSOR get_customer_name (
      c_quote_header_id                        NUMBER
    ) IS
      SELECT hp.party_name
      FROM  aso_quote_headers_all qha,
            hz_parties hp
      WHERE qha.cust_party_id = hp.party_id
            AND qha.quote_header_id = c_quote_header_id;

 -- bug 3934660 (put outer join)
    CURSOR get_account_number (
      c_quote_header_id                        NUMBER
    ) IS
      SELECT hca.account_number
      FROM hz_cust_accounts hca,
           aso_quote_headers_all qha
      WHERE qha.cust_account_id = hca.cust_account_id(+)
            AND qha.quote_header_id = c_quote_header_id;

    CURSOR get_opportunity_name (
      c_approval_id                        NUMBER
    ) IS
      SELECT ala.description
      FROM as_leads_all ala,
           aso_quote_related_objects qro,
           aso_apr_obj_approvals aoa
      WHERE ala.lead_id = qro.object_id
            AND qro.relationship_type_code = 'OPP_QUOTE'
            AND qro.quote_object_id = aoa.object_id
            AND aoa.object_approval_id = c_approval_id;

 -- bug 3934660

   CURSOR get_party_type (c_approval_id NUMBER) IS
   SELECT P.PARTY_TYPE
   FROM hz_parties p, aso_quote_headers_all qh,aso_apr_obj_approvals aoa
   WHERE p.party_id = qh.party_id
    AND qh.quote_header_id = aoa.object_id
    AND aoa.object_approval_id = c_approval_id;

    -- note that UI shows both contact and employees in drop down list,hence
    -- query uses both contact and employee
    CURSOR get_contact_name (
      c_approval_id                        NUMBER
    ) IS
    SELECT party_name
    FROM hz_parties p, hz_relationships r, aso_quote_headers_all qh,aso_apr_obj_approvals aoa
    WHERE p.party_id = r.object_id
    AND r.party_id = qh.party_id
    AND r.subject_id = qh.cust_party_id
    AND r.object_type = 'PERSON'
    AND r.relationship_code IN ('CONTACT','EMPLOYER_OF')
    AND qh.quote_header_id = aoa.object_id
    AND aoa.object_approval_id = c_approval_id;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin QUOTE_SUMMARY_DOC procedure ',
        1,
        'N'
      );
    END IF;
    itemtype       := NVL (
                        SUBSTR (
                          document_id,
                          1,
                          INSTR (
                            document_id,
                            ':'
                          ) - 1
                        ),
                        'ASOAPPRV'
                      );
    itemkey        := SUBSTR (
                        document_id,
                        INSTR (
                          document_id,
                          ':'
                        ) + 1
                      ) || 'HED';
    l_approval_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'APPROVALID'
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'ItemType is:' || itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemKey is :' || itemkey,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval ID :' || l_approval_id,
        1,
        'N'
      );
    END IF;
    -- get the quote name, quote number and expiration date
    -- hyang performance fix bug 2860045, added l_quote_header_id
    OPEN get_object_details (
      l_approval_id
    );
    FETCH get_object_details INTO l_quote_header_id, l_quote_name, l_quote_number, l_expiration_date;
    CLOSE get_object_details;
    -- get the customer name and account number
    OPEN get_customer_name (
      l_quote_header_id
    );
    FETCH get_customer_name INTO l_customer_name;
    CLOSE get_customer_name;

    -- Start : Code change done for Bug 18288445
    If l_customer_name Is not null then
       EscapeString(l_customer_name);
    End If;
    -- End : Code change done for Bug 18288445

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Customer Name is ' || l_customer_name,
        1,
        'N'
      );
    END IF;
    OPEN get_account_number (
      l_quote_header_id
    );
    FETCH get_account_number INTO l_account_number;
    CLOSE get_account_number;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Customer Account Number is ' || l_account_number,
        1,
        'N'
      );
    END IF;

    -- get the opportunity name for the quote
    OPEN get_opportunity_name (
      l_approval_id
    );
    FETCH get_opportunity_name INTO l_opportunity_name;
    CLOSE get_opportunity_name;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Opportunity Name :' || l_opportunity_name,
        1,
        'N'
      );
    END IF;
    --  get the contact name for the quote

    OPEN get_party_type(l_approval_id);
    FETCH get_party_type INTO l_party_type;
    CLOSE get_party_type;

    IF l_party_type = 'PARTY_RELATIONSHIP' THEN
       OPEN get_contact_name (
        l_approval_id
        );
       FETCH get_contact_name INTO l_contact_name;
       CLOSE get_contact_name;
    END IF;

    -- Start : Code change done for Bug 18288445
    If l_contact_name is not null then
       EscapeString(l_contact_name);
    End If;
    -- End : Code change done for Bug 18288445

       IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
         aso_debug_pub.ADD (
        'Contact Name :' || l_contact_name,
        1,
        'N'
        );
       END IF;
    -- get the attribute labels

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling the get_attribute_label proceure ',
        1,
        'N'
      );
    END IF;
    get_attribute_label (
      l_approval_id,
      l_attribute_tbl
    );

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/html',
          1,
          'N'
        );
      END IF;
      document       := document
                        || '<span class=sectionHeader1>'
                        || l_attribute_tbl (
                             2
                           )
                        || '</span>';
      document       :=
                   document
                   || '<table cellspacing=1 cellpadding=1 width="75%" border=0>';
      document       := document
                        || '<tr> <td class="prompt" align="right" nowrap>';
      document       := document || l_attribute_tbl (
                                      3
                                    ) || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_quote_name
                        || '</td>';
      document       := document || '<td class="prompt" align="right" nowrap>';
      document       := document || l_attribute_tbl (
                                      4
                                    ) || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_quote_number
                        || '</td></tr>';
      document       := document || '<tr>';
      document       := document || '<td class="prompt" align="right" nowrap> ';
      document       := document || l_attribute_tbl (
                                      5
                                    ) || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_customer_name
                        || '</td>';
      document       := document
                        || '<td class="prompt" align="right" nowrap>'
                        || l_attribute_tbl (
                             6
                           )
                        || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_account_number
                        || ' </td></tr>';
      document       := document
                        || '<tr> <td class="prompt" align="right" nowrap>'
                        || l_attribute_tbl (
                             7
                           )
                        || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_contact_name
                        || '</td>';
      document       := document
                        || '<td class="prompt" align="right" nowrap>'
                        || l_attribute_tbl (
                             8
                           )
                        || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_opportunity_name
                        || '</td></tr>';
      document       := document
                        || '<tr><td class="prompt" align="right" nowrap> ';
      document       := document || l_attribute_tbl (
                                      9
                                    ) || '</td>';
      document       := document
                        || '<td class=datareadonly>'
                        || l_expiration_date
                        || '</td>';
      document       := document || '<td>' || fnd_global.local_chr (
                                                38
                                              ) || 'nbsp';
      document       := document
                        || '</td><td>'
                        || fnd_global.local_chr (
                             38
                           )
                        || 'nbsp;</td>';
      document       := document || '</tr> </table>';
      document_type  := 'text/html';
    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/plain',
          1,
          'N'
        );
      END IF;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      3
                                    );
      document       := document || ': ';
      document       := document || l_quote_name;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      4
                                    );
      document       := document || ': ';
      document       := document || l_quote_number;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      5
                                    );
      document       := document || ': ';
      document       := document || l_customer_name;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      6
                                    );
      document       := document || ': ';
      document       := document || l_account_number;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      7
                                    );
      document       := document || ': ';
      document       := document || l_contact_name;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      8
                                    );
      document       := document || ': ';
      document       := document || l_opportunity_name;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      9
                                    );
      document       := document || ': ';
      document       := document || l_expiration_date;
      document_type  := 'text/plain';
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End QUOTE_SUMMARY_DOC procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in QUOTE_SUMMARY_DOC SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'QUOTE_SUMMARY_DOC',
        itemtype,
        itemkey
      );
      RAISE;
  END quote_summary_doc;

  PROCEDURE requester_comments_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_approval_id                 NUMBER;
    l_requester_comments          VARCHAR2 (2000);
    l_requester_userid            NUMBER;
    l_attribute_tbl               aso_attribute_label_tbl_type;

    CURSOR get_requester_details (
      c_approval_id                        NUMBER
    ) IS
      SELECT requester_comments
      FROM aso_apr_obj_approvals
      WHERE object_approval_id = c_approval_id;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin REQUESTER_COMMENTS_DOC procedure ',
        1,
        'N'
      );
    END IF;
    itemtype       := NVL (
                        SUBSTR (
                          document_id,
                          1,
                          INSTR (
                            document_id,
                            ':'
                          ) - 1
                        ),
                        'ASOAPPRV'
                      );
    itemkey        := SUBSTR (
                        document_id,
                        INSTR (
                          document_id,
                          ':'
                        ) + 1
                      ) || 'HED';
    l_approval_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'APPROVALID'
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'ItemType is:' || itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemKey is :' || itemkey,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval ID :' || l_approval_id,
        1,
        'N'
      );
    END IF;
    -- get the attribute labels

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling the get_attribute_label procedure ',
        1,
        'N'
      );
    END IF;
    get_attribute_label (
      l_approval_id,
      l_attribute_tbl
    );

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/html',
          1,
          'N'
        );
      END IF;
      OPEN get_requester_details (
        l_approval_id
      );
      FETCH get_requester_details INTO l_requester_comments;
      CLOSE get_requester_details;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Creating a text/html document ',
          1,
          'N'
        );
      END IF;
      document       := document
                        || '<span class=sectionHeader1>'
                        || l_attribute_tbl (
                             10
                           )
                        || '</span>';
      document       :=
                   document
                   || '<table cellspacing=1 cellpadding=1 width="75%" border=0>';
      document       := document || '<tr>';
      document       := document || '<td>' || l_requester_comments || '</td>';
      document       := document || '</tr></table>';
      document_type  := 'text/html';
    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/plain',
          1,
          'N'
        );
      END IF;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      10
                                    );
      document       := document || fnd_global.local_chr (
                                      10
                                    );

      FOR i IN get_requester_details (
                 l_approval_id
               )
      LOOP
        document  := document || i.requester_comments;
      END LOOP;

      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document_type  := 'text/plain';
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End REQUESTER_COMMENTS_DOC  procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in REQUESTER_COMMENTS_DOC SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'REQUESTER_COMMENTS_DOC',
        itemtype,
        itemkey
      );
      RAISE;
  END requester_comments_doc;

  PROCEDURE rule_details_doc (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_approval_id                 NUMBER;
    l_rule_description            VARCHAR2 (240);
    l_approval_level              VARCHAR2 (240);
    l_attribute_tbl               aso_attribute_label_tbl_type;
    l_ruletypeout                 VARCHAR2 (240);
    l_conditionidsout             ame_util.idlist;
    l_approvaltypenameout         VARCHAR2 (240);
    l_approvaltypedescriptionout  VARCHAR2 (240);

    CURSOR get_rule_details (
      c_approval_id                        NUMBER
    ) IS
      SELECT oam_rule_id
      FROM aso_apr_rules
      WHERE object_approval_id = c_approval_id;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin RULE_DETAILS_DOC procedure ',
        1,
        'N'
      );
    END IF;
    itemtype       := NVL (
                        SUBSTR (
                          document_id,
                          1,
                          INSTR (
                            document_id,
                            ':'
                          ) - 1
                        ),
                        'ASOAPPRV'
                      );
    itemkey        := SUBSTR (
                        document_id,
                        INSTR (
                          document_id,
                          ':'
                        ) + 1
                      ) || 'HED';
    l_approval_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'APPROVALID'
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'ItemType is:' || itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemKey is :' || itemkey,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval ID :' || l_approval_id,
        1,
        'N'
      );
    END IF;
    -- get the attribute label

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Calling the get_attribute_label procedure ',
        1,
        'N'
      );
    END IF;
    get_attribute_label (
      l_approval_id,
      l_attribute_tbl
    );

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/html',
          1,
          'N'
        );
      END IF;
      document       := document
                        || '<span class=sectionHeader1>'
                        || l_attribute_tbl (
                             14
                           )
                        || '</span>';
      document       :=
        document
        || '<table class=OraBGAccentDark cellspacing=1 cellpadding=1 width="75%" border=0>';
      document       :=
                      document
                      || '<tr> <td class="tableSmallHeaderCell" align="center">'
                      || l_attribute_tbl (
                           15
                         )
                      || '</td>';
      document       := document
                        || '<td class="tableSmallHeaderCell" align="center">'
                        || l_attribute_tbl (
                             16
                           )
                        || '</td></tr>';

      FOR i IN get_rule_details (
                 l_approval_id
               )
      LOOP
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Calling AME get applicable rules procedure',
            1,
            'N'
          );
        END IF;
        ame_api.getruledetails1 (
          ruleidin                     => i.oam_rule_id,
          ruletypeout                  => l_ruletypeout,
          ruledescriptionout           => l_rule_description,
          conditionidsout              => l_conditionidsout,
          approvaltypenameout          => l_approvaltypenameout,
          approvaltypedescriptionout   => l_approvaltypedescriptionout,
          approvaldescriptionout       => l_approval_level
        );
        document  := document
                     || '<tr> <td class="tableDataCell">'
                     || l_rule_description
                     || '</td>';
        document  := document
                     || '<td class="tableDataCell">'
                     || l_approval_level
                     || '</td></tr>';
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Rule Description is ' || l_rule_description,
            1,
            'N'
          );
          aso_debug_pub.ADD (
            'Approval level is ' || l_approval_level,
            1,
            'N'
          );
        END IF;
      END LOOP;

      document       := document || '</table>';
      document_type  := 'text/html';
    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/plain',
          1,
          'N'
        );
      END IF;
      document       := document || fnd_global.local_chr (
                                      10
                                    );
      document       := document || l_attribute_tbl (
                                      14
                                    );
      document       := document || fnd_global.local_chr (
                                      10
                                    );

      FOR i IN get_rule_details (
                 l_approval_id
               )
      LOOP
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Calling AME get applicable rules procedure',
            1,
            'N'
          );
        END IF;
        ame_api.getruledetails1 (
          ruleidin                     => i.oam_rule_id,
          ruletypeout                  => l_ruletypeout,
          ruledescriptionout           => l_rule_description,
          conditionidsout              => l_conditionidsout,
          approvaltypenameout          => l_approvaltypenameout,
          approvaltypedescriptionout   => l_approvaltypedescriptionout,
          approvaldescriptionout       => l_approval_level
        );
        document  := document || l_attribute_tbl (
                                   15
                                 );
        document  := document || ': ';
        document  := document || l_rule_description;
        document  := document || fnd_global.local_chr (
                                   10
                                 );
        document  := document || l_attribute_tbl (
                                   16
                                 );
        document  := document || ': ';
        document  := document || l_approval_level;
      END LOOP;

      document_type  := 'text/plain';
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End RULE_DETAILS_DOC procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in RULE_DETAILS_DOC SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'RULE_DETAILS_DOC',
        itemtype,
        itemkey
      );
      RAISE;
  END rule_details_doc;

  PROCEDURE quote_detail_url (
    document_id                 IN       VARCHAR2,
    display_type                IN       VARCHAR2,
    document                    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
    document_type               IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS
    itemtype                      VARCHAR2 (30);
    itemkey                       VARCHAR2 (30);
    l_approval_id                 NUMBER;
    -- hyang performance fix bug 2860045
    l_quote_header_id             NUMBER;
    l_jsp_name                    VARCHAR2 (2000);
    l_url                         VARCHAR2 (2000);
    l_attribute_tbl               aso_attribute_label_tbl_type;
    l_quote_number                NUMBER;
    l_party_number                VARCHAR2(30);
    l_cust_account_id             NUMBER;
    l_party_type                  VARCHAR2 (50);
    l_org_id                      NUMBER;
    l_notification_id             NUMBER;

    -- hyang performance fix bug 2860045
    CURSOR get_object_details (
      c_approval_id                        NUMBER
    ) IS
      SELECT quote_header_id, quote_number,qha.org_id
      FROM aso_quote_headers_all qha, aso_apr_obj_approvals aoa
      WHERE qha.quote_header_id = aoa.object_id
            AND aoa.object_approval_id = c_approval_id;

    -- bug 3934660 replace qha.party_id with cust_party_id

    CURSOR get_quote_details (
      c_quote_header_id                        NUMBER
    ) IS
      SELECT hca.cust_account_id, hp.party_type
      FROM aso_quote_headers_all qha,
           hz_parties hp,
           hz_cust_accounts hca
      WHERE qha.quote_header_id = c_quote_header_id
            AND nvl(qha.cust_account_id,0 )  = hca.cust_account_id (+)
            AND qha.cust_party_id = hp.party_id;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin QUOTE_DETAIL_URL procedure ',
        1,
        'N'
      );
    END IF;
    itemtype       := NVL (
                        SUBSTR (
                          document_id,
                          1,
                          INSTR (
                            document_id,
                            ':'
                          ) - 1
                        ),
                        'ASOAPPRV'
                      );
    itemkey        := SUBSTR (
                        document_id,
                        INSTR (
                          document_id,
                          ':'
                        ) + 1
                      ) || 'HED';
    l_approval_id  := wf_engine.getitemattrnumber (
                        itemtype                     => itemtype,
                        itemkey                      => itemkey,
                        aname                        => 'APPROVALID'
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'ItemType is:' || itemtype,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'ItemKey is :' || itemkey,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval ID :' || l_approval_id,
        1,
        'N'
      );
    END IF;
    -- get the quote header id
    -- hyang performance fix, added l_quote_header_id, bug 2860045
    OPEN get_object_details (
      l_approval_id
    );
    FETCH get_object_details INTO l_quote_header_id, l_quote_number,l_org_id;
    CLOSE get_object_details;
    OPEN get_quote_details (
      l_quote_header_id
    );
    FETCH get_quote_details INTO l_cust_account_id,
                                 l_party_type;
    CLOSE get_quote_details;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Quote header ID is ' || l_quote_header_id,
        1,
        'N'
      );
    END IF;
    -- get the server address
    l_url          := fnd_web_config.jsp_agent (
                      );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'URL ID is ' || l_url,
        1,
        'N'
      );
    END IF;
    -- get the jsp name

    l_jsp_name     := 'qotSZzpAppsLink.jsp?';
    l_jsp_name     := l_jsp_name || 'qotFrmMainFile=qotSZzdContainer.jsp';
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotFrmDspFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotFrmRefFile=qotSCocOverview.jsp';
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotDetCode=QUOTE';
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotPtyType='
                      || l_party_type;
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotHdrId='
                      || l_quote_header_id;
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotHdrAcctId='
                      || l_cust_account_id;
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotHdrNbr='
                      || l_quote_number;
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotReqSetCookie=Y';
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotFromApvlLink=Y';

    -- bug 3178070
    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotApvOrgId='
                      || l_org_id;

    l_jsp_name     := l_jsp_name
                      || fnd_global.local_chr (
                           38
                         )
                      || 'qotApvNotifId=&#NID';




    -- get the attribute label
    get_attribute_label (
      l_approval_id,
      l_attribute_tbl
    );

    -- Create an html text buffer
    IF (display_type = 'text/html')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/html',
          1,
          'N'
        );
      END IF;
      document       := '<a href = "'
                        || l_url
                        || l_jsp_name
                        || '">'
                        || l_attribute_tbl (
                             1
                           )
                        || '</a>';
      document_type  := 'text/html';
    END IF;

    -- Create a plain text buffer

    IF (display_type = 'text/plain')
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Display type is text/plain',
          1,
          'N'
        );
      END IF;
      NULL;
      document_type  := 'text/plain';
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End QUOTE_DETAIL_URL procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in QUOTE_DETAIL_URL SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'QUOTE_DETAIL_URL',
        itemtype,
        itemkey
      );
      RAISE;
  END quote_detail_url;

  PROCEDURE get_attribute_label (
    p_approval_id               IN       NUMBER,
    p_attribute_tbl             OUT NOCOPY /* file.sql.39 change */       aso_attribute_label_tbl_type
  ) IS
    l_application_id              NUMBER;

    CURSOR get_application_id (
      c_approval_id                        NUMBER
    ) IS
      SELECT application_id
      FROM aso_apr_obj_approvals
      WHERE object_approval_id = c_approval_id;

    -- hyang, bug 2860045, performance fix.
    CURSOR get_label (
      c_application_id                     NUMBER
    ) IS
      SELECT attribute_label_long
      FROM ak_region_items ara, ak_attributes_tl aat
      WHERE region_code = 'ASO_APR_NOTIFICATION'
        and region_application_id = c_application_id
        AND AAT.ATTRIBUTE_APPLICATION_ID = ARA.ATTRIBUTE_APPLICATION_ID
        AND AAT.ATTRIBUTE_CODE = ARA.ATTRIBUTE_CODE
        AND AAT.LANGUAGE = USERENV('LANG')
        ORDER by display_sequence;
  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'begin GET_ATTRIBUTE_LABEL procedure ',
        1,
        'N'
      );
    END IF;
    -- get the application id
    OPEN get_application_id (
      p_approval_id
    );
    FETCH get_application_id INTO l_application_id;
    CLOSE get_application_id;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Application ID is ' || l_application_id,
        1,
        'N'
      );
    END IF;
    p_attribute_tbl  := aso_attribute_label_tbl_type (
                        );

    -- fetch the labels and populate the PL/SQL table

    FOR i IN get_label (
               697
             )
    LOOP
      p_attribute_tbl.EXTEND;
      p_attribute_tbl (
        p_attribute_tbl.COUNT
      )                                        := i.attribute_label_long;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Label is ' || p_attribute_tbl (
                           p_attribute_tbl.COUNT
                         ),
          1,
          'N'
        );
      END IF;
    END LOOP;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Count of labels is ' || p_attribute_tbl.COUNT,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'End GET_ATTRIBUTE_LABEL procedure ',
        1,
        'N'
      );
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in GET_ATTRIBUTE_LABEL SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'GET_ATTRIBUTE_LABEL',
        SQLERRM
      );
      RAISE;
  END get_attribute_label;


  FUNCTION GetRunFuncURL
  ( p_function_name     IN     VARCHAR2
, p_resp_appl_id      IN     NUMBER    DEFAULT NULL
, p_resp_id           IN     NUMBER    DEFAULT NULL
, p_security_group_id IN     NUMBER    DEFAULT NULL
, p_parameters        IN     VARCHAR2  DEFAULT NULL
) RETURN VARCHAR2
IS

  l_function_id       NUMBER ;
  l_resp_appl_id      NUMBER := p_resp_appl_id;
  l_resp_id           NUMBER := p_resp_id ;
  l_security_group_id NUMBER := p_security_group_id;

BEGIN

   l_function_id := fnd_function.get_function_id(p_function_name) ;


   IF p_resp_appl_id IS NULL THEN
       l_resp_appl_id := -1 ;
   END IF ;


   IF p_resp_id IS NULL THEN
       l_resp_id := -1 ;
   END IF ;

   IF p_security_group_id IS NULL THEN
       l_security_group_id := -1 ;
   END IF ;

   -- Call Fnd API
   RETURN fnd_run_function.get_run_function_url
                           ( p_function_id       => l_function_id
                           , p_resp_appl_id      => l_resp_appl_id
                           , p_resp_id           => l_resp_id
                           , p_security_group_id => l_security_group_id
                           , p_parameters        => p_parameters ) ;


END GetRunFuncURL ;


  PROCEDURE set_attributes (
    itemtype                    IN       VARCHAR2,
    itemkey                     IN       VARCHAR2,
    actid                       IN       NUMBER,
    funcmode                    IN       VARCHAR2,
    resultout                   IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ) IS

    l_approval_object             VARCHAR2 (4000);
    l_approval_id                 NUMBER;
    l_org_id                      NUMBER;
    l_ampsign                     VARCHAR2(1) := fnd_global.local_chr(38);
    l_url                         VARCHAR2(32000);

    -- bug 7657061
    l_resp_appl_id                NUMBER := 880;
    l_resp_id                     NUMBER;



    CURSOR OBJECT (
      c_approval_id                        NUMBER
    ) IS
      SELECT quote_name, quote_number,org_id,quote_header_id
      FROM aso_quote_headers_all qha, aso_apr_obj_approvals aoa
      WHERE qha.quote_header_id = aoa.object_id
            AND aoa.object_approval_id = c_approval_id;

  BEGIN
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Begin set attribute  Process',
        1,
        'N'
      );
    END IF;

  IF funcmode = 'RUN'
    THEN
      l_approval_id            := wf_engine.getitemattrnumber (
                                    itemtype,
                                    itemkey,
                                    'APPROVALID'
                                  );

     FOR i IN OBJECT (
               l_approval_id
             )
    LOOP
      l_approval_object  := i.quote_name;
      l_org_id := i.org_id;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Quote name :' || l_approval_object,
          1,
          'N'
        );
      END IF;
      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'APPROVAL_OBJECT',
        avalue                       => l_approval_object
      );

      wf_engine.setitemattrnumber (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'ORGID',
        avalue                       => l_org_id
      );

      wf_engine.setitemattrnumber (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'QTEHDRID',
        avalue                       => i.quote_header_id
      );

      wf_engine.setitemattrnumber (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'QTENUMBER',
        avalue                       => i.quote_number
      );


       select nvl(fnd_profile.value('ASO_QUOTE_APPROVER_RESP'),-1) into l_resp_id from dual;  -- bug 7657061

      -- bug 5350149
      l_url := aso_apr_wf_pvt.GetRunFuncURL(
                             p_function_name  => 'QOT_OAUI_QUOTE_DETAILS',
                             p_resp_appl_id   =>   l_resp_appl_id, -- bug 7657061
                             p_resp_id        =>   l_resp_id,      -- bug 7657061
                             p_parameters     => l_ampsign||l_ampsign||'QotIntgEvtSrc=ApvlNotif'||l_ampsign||'QotIntgEvt=Event.QuoteDet'||l_ampsign||'QotIntgEvtVal='
                                                    ||i.quote_header_id||l_ampsign||'QotIntgEvtVal1='||i.quote_number||l_ampsign||'addBreadCrumb=Y') ;


      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD ('RESP_APPL_ID: ' || l_resp_appl_id,1,'N');
        aso_debug_pub.ADD ('RESP_ID: ' || l_resp_id,1,'N');
        aso_debug_pub.ADD ('l_url: '||substr(l_url,1,240),1,'N');
      END IF;


      wf_engine.setitemattrtext (
        itemtype                     => itemtype,
        itemkey                      => itemkey,
        aname                        => 'OAQTEDETAILLNK',
        avalue                       => l_url
      );

    END LOOP;
    resultout  := 'COMPLETE';
   END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Exception in Set Attributes SqlCode :' || SQLERRM,
          1,
          'N'
        );
      END IF;
      wf_core.CONTEXT (
        'ASOAPPRV',
        'set_attributes',
        itemtype,
        itemkey
      );
      RAISE;

  END;

  PROCEDURE update_approval_status (
    p_update_header_or_detail_flag IN     VARCHAR2,
    p_object_approval_id           IN      NUMBER,
    p_approval_det_id              IN       NUMBER,
    p_status                       IN       VARCHAR2,
    note                           IN       VARCHAR2
  ) is
 begin
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Start  update_approval_status  procedure ',
        1,
        'N'
      );

      aso_debug_pub.ADD (
        'Flag  is :' || p_update_header_or_detail_flag,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Object Approval ID is :' || p_object_approval_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Approval Detail ID is :' || p_approval_det_id,
        1,
        'N'
      );
      aso_debug_pub.ADD (
        'Status is :' || p_status,
        1,
        'N'
      );

    END IF;

  IF p_update_header_or_detail_flag = 'HEADER' THEN
    IF (p_status = 'PEND')
    THEN
      UPDATE aso_apr_obj_approvals
      SET approval_status = p_status,
          last_update_date = SYSDATE,
          last_updated_by = g_user_id,
          last_update_login = g_user_id
      WHERE object_approval_id = p_object_approval_id;
    ELSE
      UPDATE aso_apr_obj_approvals
      SET approval_status = p_status,
          last_update_date = SYSDATE,
          end_date = SYSDATE,
          last_updated_by = g_user_id,
          last_update_login = g_user_id
      WHERE object_approval_id = p_object_approval_id;
    END IF;

  END IF;

  IF p_update_header_or_detail_flag = 'DETAIL' THEN
    UPDATE aso_apr_approval_details
    SET approver_status = p_status,
        date_received = SYSDATE,
        last_update_date = SYSDATE,
        approver_comments = note,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.user_id
    WHERE approval_det_id = p_approval_det_id;
  END IF;

     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'End  update_approval_status  procedure ',
        1,
        'N'
      );
    END IF;

 end;

-- Start : Code change done for Bug 18288445
-----------------------------------------------------------------------
PROCEDURE EscapeString(p_str IN OUT NOCOPY VARCHAR2) IS
-----------------------------------------------------------------------
     l_tmp   varchar2(6000);
     l_bad   varchar2(100) default '>%}\~];?&<#{|^[`/:=$+''"';
     l_char  char(1 char);  --  Bug 24580396
Begin
      aso_debug_pub.ADD (
        ' inside EscapeString procedure ',
        1,
        'N'
        );

       for i in 1 .. nvl(length(p_str),0)
       Loop
           l_char :=  substr(p_str,i,1);
           If ( instr( l_bad, l_char ) = 0 ) then
                l_tmp := l_tmp || l_char;
           End if;
       End Loop;

       aso_debug_pub.ADD (
         ' inside EscapeString procedure l_tmp - '||l_tmp,
          1,
         'N'
         );

       p_str := l_tmp;

End EscapeString;
-- End : Code change done for Bug 18288445
Function Get_Formatted_number (l_currency_code IN varchar2, l_number_to_format IN Number)
    Return varchar2
IS
    l_format_mask varchar2(30);
    p_user_id Number:= fnd_global.user_id;
    formatter     varchar2(10);
    l_formatted_value varchar2(1000);
     X_Formatted_Number varchar2(1000);
Begin
    l_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30);
    formatter := FND_PROFILE.VALUE_SPECIFIC('ICX_NUMERIC_CHARACTERS',p_user_id);

    l_formatted_value:=to_char(l_number_to_format, l_format_mask , 'NLS_NUMERIC_CHARACTERS = '''||formatter ||'''');
    X_Formatted_Number := l_formatted_value; --||' '||l_currency_code;
    X_Formatted_Number := replace(replace(X_Formatted_Number,'>',''),'<','');
    if l_number_to_format < 0 THEN
        X_Formatted_Number := '-'||X_Formatted_Number;
    END IF;
    return X_Formatted_Number;
End;

Function Show_Margin_Check return varchar2 is
    l_check_grant_flag boolean := TRUE;
    l_return varchar2(10) := 'NOMARGIN';

    cursor c_values is
    select fr.menu_id, fff.function_id
    from   fnd_responsibility fr, fnd_form_functions fff
    where  fr.responsibility_id = fnd_profile.value('ASO_QUOTE_APPROVER_RESP')
    and    fff.function_name = 'QOT_OAUI_VIEW_MARGIN';

  begin
    for cv in c_values loop
      if fnd_function.IS_FUNCTION_ON_MENU(cv.menu_id,cv.function_id,l_check_grant_flag) then
        l_return := 'MARGIN';
         end if;
    end loop;
    return l_return;

  end Show_Margin_Check;

  procedure get_quote_total(
               p_quote_header_id number,
	       p_user_id         number,
	       xquote_total      IN OUT NOCOPY /* file.sql.39 change */ varchar2)
as
l_qte_total number;
l_currency_code varchar2(15);
l_format_mask varchar2(30);
formatter     varchar2(10);
l_formatted_value varchar2(1000);
begin

    select nvl(total_quote_price,0),currency_code
      into  l_qte_total,l_currency_code
     from aso_Quote_headers_all
     where quote_header_id=p_quote_header_id;

     aso_debug_pub.ADD ('l_qte_total'||l_qte_total);
     aso_debug_pub.ADD ('l_currency_code'||l_currency_code);

     l_format_mask:=FND_CURRENCY.GET_FORMAT_MASK(l_currency_code,30);


     aso_debug_pub.ADD ('l_format_mask'||l_format_mask);
     formatter := FND_PROFILE.VALUE_SPECIFIC('ICX_NUMERIC_CHARACTERS',p_user_id);
     aso_debug_pub.ADD ('formatter'||formatter);
     if formatter is not null then -- bug 21028107
	l_formatted_value:=to_char(l_qte_total, l_format_mask , 'NLS_NUMERIC_CHARACTERS = '''||formatter ||'''');
     else
        l_formatted_value:=to_char(l_qte_total, l_format_mask);  -- bug 21028107
     end if;
     xquote_total:=l_formatted_value||' '||l_currency_code;
     aso_debug_pub.ADD ('xquote_total'||xquote_total);
end get_quote_total;

END aso_apr_wf_pvt;

/
