--------------------------------------------------------
--  DDL for Package Body PQH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_WF" 
/* $Header: pqhwfpc.pkb 120.2.12010000.3 2009/04/24 10:31:48 brsinha ship $ */
AS
  g_package  VARCHAR2(31)  := 'PQH_WF.';
  --
  -- Gets itemkey and returns transaction id and transaction category id
  --
  PROCEDURE decode_itemkey(
      p_itemkey                  IN      VARCHAR2
    , p_transaction_category_id      OUT NOCOPY NUMBER
    , p_transaction_id               OUT NOCOPY NUMBER
    )
  IS
      l_hyphen_pos                 NUMBER;
      l_proc            VARCHAR2(61)  := g_package  || 'decode_itemkey';
  BEGIN
        hr_utility.set_location(l_proc || 'Entering',10);
        l_hyphen_pos              := INSTR(p_itemkey, '-');
        p_transaction_category_id := TO_NUMBER(SUBSTR(p_itemkey, 1, l_hyphen_pos - 1));
        p_transaction_id          := TO_NUMBER(SUBSTR(p_itemkey, l_hyphen_pos + 1));
        hr_utility.set_location(l_proc || 'txn_cat'||p_transaction_category_id,20);
        hr_utility.set_location(l_proc || 'txn_id'||p_transaction_id,30);
        hr_utility.set_location(l_proc || 'Exiting',100);
  exception when others then
     p_transaction_category_id := null;
     p_transaction_id := null;
     raise;
  END;

--
-- Create process log
--
  procedure create_process_log(p_log_text     varchar2
                             )
  IS
     l_process_log_id  NUMBER;
     l_proc            VARCHAR2(61)  := g_package  || 'create_process_log';
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
/*
    INSERT INTO ghr_process_log (
       PROCESS_LOG_ID
     , PROGRAM_NAME
     , LOG_TEXT
     , LOG_DATE
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
       )
      VALUES (
        ghr_process_log_s.nextval
      , 'PQH_WORKFLOW'
      , p_log_text
      , sysdate
      , sysdate
      , 1
      , sysdate
      , 1
      , 1
      )
      ;
*/
    hr_utility.set_location(l_proc || ' '|| p_log_text,90);
    hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  --
  -- Check wether the transaction was approved by override approver or not
  --
  Function check_approver(p_itemkey in varchar2) return boolean is
     l_transaction_id number;
     l_tran_cat_id    number;

  cursor c1 is
     select routing_history_id
     from pqh_routing_history
     where transaction_id = l_transaction_id
     and transaction_category_id = l_tran_cat_id
     and user_action_cd ='OVERRIDE'
     and nvl(approval_cd,'X') <> 'APPROVED'
     order by routing_history_id desc;
  cursor c2(p_routing_history_id number) is
     select approval_cd
     from pqh_routing_history
     where transaction_id = l_transaction_id
     and routing_history_id > p_routing_history_id
     and transaction_category_id = l_tran_cat_id
     order by routing_history_id desc;

     l_matchfound boolean := FALSE;
     l_approval_cd varchar2(30);
     l_proc            VARCHAR2(61)  := g_package  || 'check_approver ';
  begin
     hr_utility.set_location('entering '||l_proc,10);
     decode_itemkey( p_itemkey  => p_itemkey
                   , p_transaction_category_id => l_tran_cat_id
                   , p_transaction_id          => l_transaction_id);
     for i in c1 loop
        hr_utility.set_location('in loop for rh_id'||i.routing_history_id||l_proc,20);
        open c2(i.routing_history_id);
        fetch c2 into l_approval_cd;
        if c2%notfound then
           hr_utility.set_location('not routed after that'||l_proc,30);
           l_matchfound := FALSE;
           close c2;
        else
           hr_utility.set_location('routed after sending to ov '||l_proc,40);
           if l_approval_cd ='APPROVED' then
              hr_utility.set_location('Approved by OA'||l_proc,50);
              l_matchfound := TRUE;
              return l_matchfound;
           end if;
           close c2;
        end if;
        hr_utility.set_location('out loop for rh_id'||i.routing_history_id||l_proc,60);
     end loop;
     hr_utility.set_location('exiting'||l_proc,100);
     return l_matchfound;
  end check_approver;
  --
  -- Check if workflow process is running
  --
  FUNCTION wf_process_not_running (
      p_itemkey             IN VARCHAR2
    , p_itemtype            IN VARCHAR2)
    RETURN BOOLEAN
  IS
      l_running        BOOLEAN;
      l_temp_holder    VARCHAR2(1);
      l_proc            VARCHAR2(61)  := g_package  || 'wf_process_not_running ';
      CURSOR c_wf IS
          SELECT 'x'
          FROM wf_items wfi
          WHERE wfi.item_type = p_itemtype
          AND   wfi.item_key  = p_itemkey;
  BEGIN
      hr_utility.set_location(l_proc || 'Entering',10);
      OPEN c_wf;
      FETCH c_wf INTO l_temp_holder;
      l_running := c_wf%FOUND;
      CLOSE c_wf;
      if l_running THEN
            hr_utility.set_location(l_proc || 'WF Running - TRUE', 100);
      ELSE
            hr_utility.set_location(l_proc || 'WF Running - FALSE', 100);
      END IF;
      hr_utility.set_location(l_proc || 'Exiting',100);
      RETURN (NOT l_running);
  END;
  PROCEDURE fyi_notification( document_id   in     varchar2,
                              display_type  in     varchar2,
                              document      in out nocopy varchar2,
                              document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'fyi_notification';
     fyi_notification_not_defined EXCEPTION;
     pragma exception_init (fyi_notification_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_fyi_notification varchar2(200);

     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;

     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     document_type := 'text/plain';
     l_fyi_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.fyi_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_fyi_notification USING OUT document;
     EXCEPTION
        WHEN fyi_notification_not_defined THEN
             document := 'fyi notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
--     document := document || l_fyi_notification ;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE reject_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'reject_notification';
     reject_notice_not_defined EXCEPTION;
     pragma exception_init (reject_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_reject_notification varchar2(200);
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_reject_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.reject_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_reject_notification USING OUT document;
     EXCEPTION
        WHEN reject_notice_not_defined THEN
             document := 'reject notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE back_notification( document_id   in     varchar2,
                               display_type  in     varchar2,
                               document      in out nocopy varchar2,
                               document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'back_notification';
     back_notice_not_defined EXCEPTION;
     pragma exception_init (back_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_back_notification varchar2(200);
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_back_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.back_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_back_notification USING OUT document;
     EXCEPTION
        WHEN back_notice_not_defined THEN
             document := 'back notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE override_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'override_notification';
     override_notice_not_defined EXCEPTION;
     pragma exception_init (override_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_override_notification varchar2(2000);
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_override_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.override_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_override_notification USING OUT document;
     EXCEPTION
        WHEN override_notice_not_defined THEN
             document := 'override notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE apply_notification( document_id   in     varchar2,
                                display_type  in     varchar2,
                                document      in out nocopy varchar2,
                                document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'apply_notification';
     apply_notice_not_defined EXCEPTION;
     pragma exception_init (apply_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     l_apply_notification varchar2(200);
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_apply_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.apply_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_apply_notification USING OUT document;
     EXCEPTION
        WHEN apply_notice_not_defined THEN
             document := 'apply notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE warning_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'warning_notification';
     warning_notice_not_defined EXCEPTION;
     pragma exception_init (warning_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     l_hyphen_pos number;
     l_warning_notification varchar2(200);
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_warning_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.warning_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_warning_notification USING OUT document;
     EXCEPTION
        WHEN warning_notice_not_defined THEN
             document := 'warning notification not defined';
        WHEN OTHERS THEN
        document    := l_document;
     document_type  := l_document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

  PROCEDURE respond_notification( document_id   in     varchar2,
                                  display_type  in     varchar2,
                                  document      in out nocopy varchar2,
                                  document_type in out nocopy varchar2) is
     l_proc            VARCHAR2(61)  := g_package  || 'respond_notification';
     respond_notice_not_defined EXCEPTION;
     pragma exception_init (respond_notice_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_respond_notification varchar2(200);
     l_document varchar2(2000) := document;
     l_document_type varchar2(2000) := document_type;
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  begin
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'document id ' || document_id,20);
     document_type := 'text/plain';
     l_hyphen_pos     := INSTR(document_id, ':');
     l_transaction_id := TO_NUMBER(SUBSTR(document_id, 1, l_hyphen_pos - 1));
     l_tran_cat_id    := TO_NUMBER(SUBSTR(document_id, l_hyphen_pos + 1));
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     l_respond_notification := 'begin :l_status := ' || l_post_txn_function ||
                           '.respond_notification(p_transaction_id =>'||
                           to_char(l_transaction_id) || '); end; ';

     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_respond_notification USING OUT document;
     EXCEPTION
        WHEN respond_notice_not_defined THEN
             document := 'respond notification not defined';
        WHEN OTHERS THEN
             l_document := document;
     l_document_type := document_type;
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
     END;
--     document := document || l_respond_notification ;
--     document := 'Testing' || document_id;
     hr_utility.set_location(l_proc || 'Exiting',100);
  end;

--
--  Create routing history row
--
  PROCEDURE create_routing_history(
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    , p_routing_category_id            IN NUMBER
    , p_pos_structure_version_id       IN NUMBER
    , p_user_action_cd                 IN VARCHAR2
    , p_approval_cd                    IN VARCHAR2
    , p_notification_date              IN DATE
    , p_comments                       IN VARCHAR2
    , p_forwarded_to_user_id           IN NUMBER
    , p_forwarded_to_role_id           IN NUMBER
    , p_forwarded_to_position_id       IN NUMBER
    , p_forwarded_to_assignment_id     IN NUMBER
    , p_forwarded_to_member_id         IN NUMBER
    , p_forwarded_by_user_id           IN NUMBER
    , p_forwarded_by_role_id           IN NUMBER
    , p_forwarded_by_position_id       IN NUMBER
    , p_forwarded_by_assignment_id     IN NUMBER
    , p_forwarded_by_member_id         IN NUMBER
    , p_routing_history_id            OUT NOCOPY NUMBER
  )
  IS
      l_proc                     VARCHAR2(61)  := g_package  || 'create_routing_history';
      l_rha_tab                  pqh_routing_history_api.t_rha_tab;
      l_routing_history_id       pqh_routing_history.routing_history_id%type;
      l_object_version_number    pqh_routing_history.object_version_number%type;
      l_effective_date           date := trunc(sysdate);
      j binary_integer := 0;
  BEGIN
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'p_approval_cd is '||p_approval_cd,12);
     FOR i in NVL(pqh_workflow.g_routing_criterion.FIRST,0)..NVL(pqh_workflow.g_routing_criterion.LAST,-1) loop
         if pqh_workflow.g_routing_criterion.exists(i) then
            l_rha_tab(j).attribute_id   := pqh_workflow.g_routing_criterion(i).Attribute_id;
            l_rha_tab(j).from_char      := pqh_workflow.g_routing_criterion(i).from_char;
            l_rha_tab(j).from_date      := pqh_workflow.g_routing_criterion(i).from_date;
            l_rha_tab(j).from_number    := pqh_workflow.g_routing_criterion(i).from_num;
            l_rha_tab(j).to_char        := pqh_workflow.g_routing_criterion(i).to_char;
            l_rha_tab(j).to_date        := pqh_workflow.g_routing_criterion(i).to_date;
            l_rha_tab(j).to_number      := pqh_workflow.g_routing_criterion(i).to_num;
            l_rha_tab(j).range_type_cd  := pqh_workflow.g_routing_criterion(i).used_for;
            l_rha_tab(j).value_date     := pqh_workflow.g_routing_criterion(i).value_date;
            l_rha_tab(j).value_number   := pqh_workflow.g_routing_criterion(i).value_num;
            l_rha_tab(j).value_char     := pqh_workflow.g_routing_criterion(i).value_char;
            j := j + 1;
        end if;
     END LOOP;
     hr_utility.set_location(l_proc || 'out of xfer  ',14);

     pqh_routing_history_api.create_routing_history_bp (
         p_validate                       => false
        ,p_routing_history_id             => l_routing_history_id
        ,p_approval_cd                    => p_approval_cd
        ,p_comments                       => p_comments
        ,p_forwarded_by_assignment_id     => p_forwarded_by_assignment_id
        ,p_forwarded_by_member_id         => p_forwarded_by_member_id
        ,p_forwarded_by_position_id       => p_forwarded_by_position_id
        ,p_forwarded_by_user_id           => p_forwarded_by_user_id
        ,p_forwarded_by_role_id           => p_forwarded_by_role_id
        ,p_forwarded_to_assignment_id     => p_forwarded_to_assignment_id
        ,p_forwarded_to_member_id         => p_forwarded_to_member_id
        ,p_forwarded_to_position_id       => p_forwarded_to_position_id
        ,p_forwarded_to_role_id           => p_forwarded_to_role_id
        ,p_forwarded_to_user_id           => p_forwarded_to_user_id
        ,p_notification_date              => p_notification_date
        ,p_pos_structure_version_id       => p_pos_structure_version_id
        ,p_routing_category_id            => p_routing_category_id
        ,p_transaction_category_id        => p_transaction_category_id
        ,p_transaction_id                 => p_transaction_id
        ,p_user_action_cd                 => p_user_action_cd
        ,p_object_version_number          => l_object_version_number
        ,p_from_range_name                => pqh_workflow.g_current_member_range
        ,p_to_range_name                  => pqh_workflow.g_next_member_range
        ,p_list_range_name                => pqh_workflow.g_list_range
        ,p_effective_date                 => l_effective_date
        ,p_rha_tab                        => l_rha_tab
       );
      p_routing_history_id := l_routing_history_id;
      hr_utility.set_location(l_proc || 'Exiting',100);
  exception
     when others then
     p_routing_history_id := null;
        hr_utility.set_location(sqlerrm,110 );
        raise;
  END;
--
--  Update routing history row
--
  PROCEDURE update_routing_history(
      p_routing_history_id             IN NUMBER
    , p_user_action_cd                 IN VARCHAR2
  )
  IS
      l_proc            VARCHAR2(61)  := g_package  || 'update_routing_history';
  BEGIN
     hr_utility.set_location(l_proc || 'Entering',10);
     UPDATE pqh_routing_history
       set
          user_action_cd = p_user_action_cd
     WHERE routing_history_id = p_routing_history_id;
     hr_utility.set_location(l_proc || 'Exiting',100);
  END;

--
--  Get Last routing history row
--

  PROCEDURE get_last_rh_row (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    , p_routing_history_id            OUT NOCOPY NUMBER
    , p_user_name                     OUT NOCOPY VARCHAR2
    )
  IS
    l_proc            VARCHAR2(61)  := g_package  || 'get_last_rh_row';
--    l_user            VARCHAR2(100);
    CURSOR c_rht IS
       SELECT '1-USR-TO'                  order_by
             , rht.routing_history_id     routing_history_id
             , user_name                  user_name
       FROM   pqh_routing_history rht
            , fnd_user usr
       WHERE  usr.user_id             = rht.forwarded_by_user_id
         AND  transaction_category_id = p_transaction_category_id
         AND  transaction_id          = p_transaction_id
         AND  user_action_cd         <> 'TIMEOUT'
       UNION
       SELECT '2-POS'
             , rht.routing_history_id
             , wfr.name
       FROM   pqh_routing_history rht
            , wf_roles wfr
       WHERE  wfr.orig_system         = 'POS'
         AND  wfr.orig_system_id      = rht.forwarded_by_position_id
         AND  rht.forwarded_to_user_id IS NULL
         AND  transaction_category_id = p_transaction_category_id
         AND  transaction_id          = p_transaction_id
         AND  user_action_cd         <> 'TIMEOUT'
       UNION
       SELECT '3-RLS'
             , rht.routing_history_id
             , wfr.name
       FROM   pqh_routing_history      rht
            , wf_roles                 wfr
            , pqh_routing_list_members rlm
       WHERE  wfr.orig_system            = 'PQH_ROLE'
         AND  rlm.routing_list_member_id = rht.forwarded_by_member_id
         AND  wfr.orig_system_id         = rlm.role_id
         AND  rht.forwarded_to_user_id IS NULL
         AND  transaction_category_id    = p_transaction_category_id
         AND  transaction_id             = p_transaction_id
         AND  user_action_cd         <> 'TIMEOUT'
       UNION
       SELECT '4-USR-BY'
             , rht.routing_history_id
             , user_name
       FROM   pqh_routing_history rht
            , fnd_user usr
       WHERE  usr.user_id             = rht.forwarded_by_user_id
         AND  rht.forwarded_to_user_id IS NULL
         AND  transaction_category_id = p_transaction_category_id
         AND  transaction_id          = p_transaction_id
         AND  user_action_cd         <> 'TIMEOUT'
       ORDER BY 2 DESC, 1 ASC;
       r_rht    c_rht%ROWTYPE;
  BEGIN
     hr_utility.set_location(l_proc || 'Entering',10);
     OPEN c_rht;
     FETCH c_rht INTO r_rht;
     CLOSE c_rht;
     p_user_name          := r_rht.user_name;
     p_routing_history_id := r_rht.routing_history_id;
     hr_utility.set_location(l_proc || ' order by : ' || r_rht.order_by, 90);
     hr_utility.set_location(l_proc || ' Last User : ' || r_rht.user_name, 90);
     hr_utility.set_location(l_proc || 'Exiting',100);
exception when others then
     p_routing_history_id            := null;
     p_user_name                     := null;
     raise;
  END;

  FUNCTION get_last_rh_id (
      p_itemkey          IN VARCHAR2
    )
    RETURN NUMBER
  IS
    l_user_name                VARCHAR2(100);
    l_routing_history_id       NUMBER;
    l_transaction_category_id  NUMBER;
    l_transaction_id           NUMBER;
  BEGIN
       decode_itemkey(p_itemkey        => p_itemkey
         , p_transaction_category_id   => l_transaction_category_id
         , p_transaction_id            => l_transaction_id);
       get_last_rh_row (
           p_transaction_category_id   => l_transaction_category_id
         , p_transaction_id            => l_transaction_id
         , p_routing_history_id        => l_routing_history_id
         , p_user_name                 => l_user_name
        );
        RETURN l_routing_history_id;
  END;

  FUNCTION get_last_user (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    )
    RETURN VARCHAR2
  IS
    l_user_name            VARCHAR2(100);
    l_routing_history_id   NUMBER;
  BEGIN
       get_last_rh_row (
           p_transaction_category_id   => p_transaction_category_id
         , p_transaction_id            => p_transaction_id
         , p_routing_history_id        => l_routing_history_id
         , p_user_name                 => l_user_name
        );
        RETURN l_user_name;
  END;
  FUNCTION get_last_user (
      p_itemkey                        IN VARCHAR2
    )
    RETURN VARCHAR2
  IS
      l_transaction_category_id        NUMBER;
      l_transaction_id                 NUMBER;
      l_user                           VARCHAR2(100);
      l_proc                           VARCHAR2(61)  := g_package  || 'get_last_user';
  BEGIN
      hr_utility.set_location(l_proc || 'Entering',10);
      decode_itemkey(
          p_itemkey                  => p_itemkey
        , p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      l_user := get_last_user(
          p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      hr_utility.set_location(l_proc || ' Exiting',100);
      RETURN l_user;
  END;
--
--  Get Approver's user name
--

  FUNCTION get_approver (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    )
    RETURN VARCHAR2
  IS
    l_proc            VARCHAR2(61)  := g_package  || 'get_approver';
    l_user            VARCHAR2(100);
    CURSOR c_rht IS
       SELECT user_name
       FROM   pqh_routing_history rht
            , fnd_user usr
       WHERE  usr.user_id = rht.forwarded_by_user_id
         AND  transaction_category_id = p_transaction_category_id
         AND  transaction_id          = p_transaction_id
         AND  approval_cd             = 'APPROVED'
       ORDER BY routing_history_id DESC;
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     OPEN c_rht;
     FETCH c_rht INTO l_user;
     CLOSE c_rht;
     hr_utility.set_location(l_proc || ' Approver : ' || l_user, 90);
     hr_utility.set_location(l_proc || ' Exiting',100);
     RETURN l_user;
  END;

  FUNCTION get_approver (
      p_itemkey                        IN VARCHAR2
    )
    RETURN VARCHAR2
  IS
      l_transaction_category_id        NUMBER;
      l_transaction_id                 NUMBER;
      l_user                           VARCHAR2(100);
      l_proc                           VARCHAR2(61)  := g_package  || 'get_approver';
  BEGIN
      hr_utility.set_location(l_proc || ' Entering',10);
      decode_itemkey(
          p_itemkey                  => p_itemkey
        , p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      l_user := get_approver(
          p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      hr_utility.set_location(l_proc || ' Exiting',100);
      RETURN l_user;
  END;
--
--  Get Requestor's Routing History
--
  PROCEDURE get_requestor_history (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    , p_user_name                      OUT NOCOPY VARCHAR2
    , p_forwarded_by_assignment_id     OUT NOCOPY NUMBER
    , p_forwarded_by_member_id         OUT NOCOPY NUMBER
    , p_forwarded_by_position_id       OUT NOCOPY NUMBER
    , p_forwarded_by_user_id           OUT NOCOPY NUMBER
    , p_forwarded_by_role_id           OUT NOCOPY NUMBER
    )
  IS
    l_proc            VARCHAR2(61)  := g_package  || 'get_requestor_history';
    CURSOR c_rht IS
       SELECT user_name
            , forwarded_by_assignment_id
            , forwarded_by_member_id
            , forwarded_by_position_id
            , forwarded_by_user_id
            , forwarded_by_role_id
       FROM   pqh_routing_history rht
            , fnd_user usr
       WHERE  usr.user_id = rht.forwarded_by_user_id
       AND    routing_history_id = (
              SELECT MIN(routing_history_id)
              FROM pqh_routing_history
              WHERE  transaction_category_id = p_transaction_category_id
              AND    transaction_id = p_transaction_id
              );
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     OPEN c_rht;
     FETCH c_rht INTO
                 p_user_name
               , p_forwarded_by_assignment_id
               , p_forwarded_by_member_id
               , p_forwarded_by_position_id
               , p_forwarded_by_user_id
               , p_forwarded_by_role_id;
     CLOSE c_rht;
     hr_utility.set_location(l_proc || ' Exiting',100);
exception when others then
p_user_name                      := null;
p_forwarded_by_assignment_id     := null;
p_forwarded_by_member_id         := null;
p_forwarded_by_position_id       := null;
p_forwarded_by_user_id           := null;
p_forwarded_by_role_id           := null;
raise;
  END;

--  Get Requestor's user name
--
  FUNCTION get_requestor (
      p_transaction_category_id        IN NUMBER
    , p_transaction_id                 IN NUMBER
    )
    RETURN VARCHAR2
  IS
    l_proc                           VARCHAR2(61)  := g_package  || 'get_requestor';
    l_user                           VARCHAR2(100);
    l_forwarded_by_assignment_id     NUMBER;
    l_forwarded_by_member_id         NUMBER;
    l_forwarded_by_position_id       NUMBER;
    l_forwarded_by_user_id           NUMBER;
    l_forwarded_by_role_id           NUMBER;

  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     get_requestor_history(
          p_transaction_category_id        => p_transaction_category_id
        , p_transaction_id                 => p_transaction_id
        , p_user_name                      => l_user
        , p_forwarded_by_assignment_id     => l_forwarded_by_assignment_id
        , p_forwarded_by_member_id         => l_forwarded_by_member_id
        , p_forwarded_by_position_id       => l_forwarded_by_position_id
        , p_forwarded_by_user_id           => l_forwarded_by_user_id
        , p_forwarded_by_role_id           => l_forwarded_by_role_id
     );

     hr_utility.set_location(l_proc || ' Exiting',100);
     hr_utility.set_location(l_proc || ' Requestor : ' || l_user, 90);
     RETURN l_user;
  END;

  FUNCTION get_requestor (
      p_itemkey                        IN VARCHAR2
    )
    RETURN VARCHAR2
  IS
      l_transaction_category_id        NUMBER;
      l_transaction_id                 NUMBER;
      l_user                           VARCHAR2(100);
      l_proc                           VARCHAR2(61)  := g_package  || 'get_requestor';
  BEGIN
      hr_utility.set_location(l_proc || ' Entering',10);
      decode_itemkey(
          p_itemkey                  => p_itemkey
        , p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      l_user := get_requestor(
          p_transaction_category_id  => l_transaction_category_id
        , p_transaction_id           => l_transaction_id
      );
      hr_utility.set_location(l_proc || ' Exiting',100);
      RETURN l_user;
  END;
--
-- Get workflow information based on transaction category
--
  PROCEDURE get_workflow_info( p_transaction_category_id IN     NUMBER
                             , p_transaction_category_name  OUT NOCOPY VARCHAR2
                             , p_workflow_name              OUT NOCOPY VARCHAR2
                             , p_process_name               OUT NOCOPY VARCHAR2
                             , p_timeout_days               OUT NOCOPY NUMBER
                             , p_form_name                  OUT NOCOPY VARCHAR2
                             , p_post_txn_function          OUT NOCOPY VARCHAR2
                             , p_post_style_cd              OUT NOCOPY VARCHAR2
                             , p_future_action_cd           OUT NOCOPY VARCHAR2
                             , p_short_name                 OUT NOCOPY VARCHAR2
                             )
  IS
       l_proc            VARCHAR2(61)  := g_package  || 'get_workflow_info';
       CURSOR c_txn_cat (p_transaction_category_id NUMBER) IS
          SELECT name
               , custom_workflow_name
               , custom_wf_process_name
               , timeout_days
               , form_name
               , post_txn_function
               , post_style_cd
               , future_action_cd
               , short_name
          FROM   pqh_transaction_categories tct
          WHERE  transaction_category_id = p_transaction_category_id;
       r_txn_cat c_txn_cat%ROWTYPE;
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     IF p_transaction_category_id IS NULL then
        hr_utility.set_message(8302,'PQH_NULL_TRANSACTION_ID_OR_CAT');
        hr_utility.raise_error;
     END IF;
     OPEN c_txn_cat(p_transaction_category_id => p_transaction_category_id);
     FETCH c_txn_cat INTO r_txn_cat;
     CLOSE c_txn_cat;
     p_transaction_category_name  := r_txn_cat.name;
     p_workflow_name              := NVL(r_txn_cat.custom_workflow_name, 'PQHGEN');
     p_process_name               := NVL(r_txn_cat.custom_wf_process_name, 'PQH_ROUTING');
     p_timeout_days               := NVL(r_txn_cat.timeout_days, 0);
     p_form_name                  := r_txn_cat.form_name;
     p_post_txn_function          := r_txn_cat.post_txn_function;
     p_post_style_cd              := r_txn_cat.post_style_cd;
     p_future_action_cd           := r_txn_cat.future_action_cd;
     p_short_name                 := r_txn_cat.short_name;
     hr_utility.set_location(l_proc || 'Exiting',100);
exception when others then
p_transaction_category_name  := null;
p_workflow_name              := null;
p_process_name               := null;
p_timeout_days               := null;
p_form_name                  := null;
p_post_txn_function          := null;
p_post_style_cd              := null;
p_future_action_cd           := null;
p_short_name                 := null;
raise;
  END;
  FUNCTION get_workflow_name(p_transaction_category_id in number)
     return varchar2
  is
     l_transaction_category_name VARCHAR2(100);
     l_process_name              VARCHAR2(30);
     l_timeout_days              NUMBER;
     l_form_name                 VARCHAR2(30);
     l_post_txn_function         VARCHAR2(61);
     l_future_action_cd          VARCHAR2(30);
     l_post_style_cd             VARCHAR2(30);
     l_workflow_name             VARCHAR2(30);
     l_short_name                VARCHAR2(30);
  begin
     get_workflow_info(p_transaction_category_id   => p_transaction_category_id
                     , p_transaction_category_name => l_transaction_category_name
                     , p_workflow_name             => l_workflow_name
                     , p_process_name              => l_process_name
                     , p_timeout_days              => l_timeout_days
                     , p_form_name                 => l_form_name
                     , p_post_txn_function         => l_post_txn_function
                     , p_future_action_cd          => l_future_action_cd
                     , p_post_style_cd             => l_post_style_cd
                     , p_short_name                => l_short_name
                     );
    return l_workflow_name;
  end;
  --
  -- Set FYI User
  --
  PROCEDURE SET_FYI_USER (
        p_itemtype                       in varchar2
	  , p_itemkey                        in varchar2
      , p_fyi_user                       in varchar2
      )
  IS
      l_proc            VARCHAR2(61)  := g_package  || 'set_fyi_user';
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' p_fyi_user '|| p_fyi_user,20);
     wf_engine.SetItemAttrText(itemtype => p_itemtype,
                               itemkey  => p_ItemKey,
                               aname    => 'FYI_USER',
                               avalue   => p_fyi_user );
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  PROCEDURE SET_FYI_USER (
        p_transaction_category_id        in number
      , p_transaction_id                 in number
      , p_fyi_user                       in varchar2
      )
  IS
      l_itemkey                   VARCHAR2(30);
      l_workflow_name             VARCHAR2(30);
      l_transaction_category_name VARCHAR2(100);
      l_short_name                VARCHAR2(30);
      l_process_name              VARCHAR2(30);
      l_timeout_days              NUMBER;
      l_form_name                 VARCHAR2(30);
      l_post_txn_function         VARCHAR2(61);
      l_future_action_cd          VARCHAR2(30);
      l_post_style_cd             VARCHAR2(30);
      l_proc                      VARCHAR2(61)  := g_package  || 'set_fyi_user';
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;

     get_workflow_info(p_transaction_category_id   => p_transaction_category_id
                     , p_transaction_category_name => l_transaction_category_name
                     , p_workflow_name             => l_workflow_name
                     , p_process_name              => l_process_name
                     , p_timeout_days              => l_timeout_days
                     , p_form_name                 => l_form_name
                     , p_post_txn_function         => l_post_txn_function
                     , p_future_action_cd          => l_future_action_cd
                     , p_post_style_cd             => l_post_style_cd
                     , p_short_name                => l_short_name
                     );
     set_fyi_user (
        p_itemtype        => l_workflow_name
	, p_itemkey         => l_itemkey
      , p_fyi_user        => p_fyi_user
      );
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  --
  -- Set next user and status
  --
  PROCEDURE SET_NEXT_USER (
        p_itemtype                       in varchar2
      , p_itemkey                        in varchar2
      , p_route_to_user                  in varchar2
      , p_status                         in varchar2  DEFAULT NULL
      )
  IS
      l_proc            VARCHAR2(61)  := g_package  || 'set_next_user';
      l_status          VARCHAR2(30)  := p_status;
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' p_route_to_user '|| p_route_to_user,20);
     hr_utility.set_location(l_proc || 'p_status '|| p_status,30);
     IF  NOT wf_process_not_running (p_itemkey   => p_itemkey
                                  ,  p_itemtype  => p_itemtype) THEN
        IF p_route_to_user IS NOT NULL THEN
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'ROUTE_TO_USER',
                                      avalue   => p_route_to_user );
            IF l_status IS NULL AND p_route_to_user IS NOT NULL THEN
               l_status := 'FOUND';
            END IF;
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'NEXT_USER_STATUS',
                                      avalue   => l_status );
        ELSE
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'NEXT_USER_STATUS',
                                      avalue   => 'NOT_FOUND' );
        END IF;
     END IF;
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  PROCEDURE SET_NEXT_USER (
        p_transaction_category_id        in number
	  , p_transaction_id                         in number
      , p_route_to_user                  in varchar2
      , p_status                         in varchar2
      )
  IS
      l_itemkey            VARCHAR2(30);
      l_workflow_name      VARCHAR2(30);
      l_transaction_category_name VARCHAR2(100);
      l_process_name       VARCHAR2(30);
      l_short_name         VARCHAR2(30);
      l_timeout_days       NUMBER;
      l_form_name          VARCHAR2(30);
      l_post_txn_function  VARCHAR2(61);
      l_future_action_cd   VARCHAR2(30);
      l_post_style_cd      VARCHAR2(30);
      l_proc               VARCHAR2(61)  := g_package  || 'set_next_user';
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;

     get_workflow_info(p_transaction_category_id => p_transaction_category_id
                     , p_transaction_category_name => l_transaction_category_name
                     , p_workflow_name           => l_workflow_name
                     , p_process_name            => l_process_name
                     , p_timeout_days            => l_timeout_days
                     , p_form_name               => l_form_name
                     , p_post_txn_function       => l_post_txn_function
                     , p_future_action_cd        => l_future_action_cd
                     , p_post_style_cd           => l_post_style_cd
                     , p_short_name                => l_short_name
                     );
     set_next_user (
        p_itemtype        => l_workflow_name
	  , p_itemkey         => l_itemkey
      , p_route_to_user   => p_route_to_user
      , p_status          => p_status
      );
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  --
  -- Dummy Post Transaction Function
  --
  FUNCTION post_any_txn (p_transaction_id             IN NUMBER
                        )
  RETURN VARCHAR2 IS
  BEGIN
      IF TRUNC(p_transaction_id/2) = p_transaction_id / 2 THEN
          RETURN 'SUCCESS';
      ELSE
          RETURN 'FAILURE';
      END IF;
  END;
  --
  -- Start a workflow process
  --
  PROCEDURE StartProcess(
        p_itemkey                        in varchar2
      , p_itemtype                       in varchar2
      , p_process_name                   in varchar2
      , p_route_to_user                  in varchar2
      , p_user_status                    in varchar2
      , p_timeout_days                   in number
      , p_form_name                      in VARCHAR2
      , p_transaction_id                 in NUMBER
      , p_transaction_category_id        in NUMBER
      , p_post_txn_function              IN VARCHAR2
      , p_future_action_cd               IN VARCHAR2
      , p_post_style_cd                  IN VARCHAR2
      , p_user_action_cd                 IN VARCHAR2
      , p_effective_date                 IN DATE
      , p_transaction_name               IN varchar2
      , p_transaction_category_name      IN varchar2
      , p_routing_history_id             IN number
      , p_comments                       IN VARCHAR2
      , p_launch_url                     in varchar2
      , p_parameter1_name                in varchar2 default null
      , p_parameter1_value               in varchar2 default null
      , p_parameter2_name                in varchar2 default null
      , p_parameter2_value               in varchar2 default null
      , p_parameter3_name                in varchar2 default null
      , p_parameter3_value               in varchar2 default null
      , p_parameter4_name                in varchar2 default null
      , p_parameter4_value               in varchar2 default null
      , p_parameter5_name                in varchar2 default null
      , p_parameter5_value               in varchar2 default null
      , p_parameter6_name                in varchar2 default null
      , p_parameter6_value               in varchar2 default null
      , p_parameter7_name                in varchar2 default null
      , p_parameter7_value               in varchar2 default null
      , p_parameter8_name                in varchar2 default null
      , p_parameter8_value               in varchar2 default null
      , p_parameter9_name                in varchar2 default null
      , p_parameter9_value               in varchar2 default null
      , p_parameter10_name               in varchar2 default null
      , p_parameter10_value              in varchar2 default null
  )
  is
      l_proc                    VARCHAR2(61)  := g_package  || 'StartProcess';
      l_form_name               VARCHAR2(100) := p_form_name;
      l_timeout_days            number ;
  Begin
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' Params - p_itemkey '|| p_itemkey,15);
     hr_utility.set_location(l_proc || ' Params - p_itemtype '|| p_itemtype,15);
     hr_utility.set_location(l_proc || ' Params - p_process name '|| p_process_name,15);
     hr_utility.set_location(l_proc || ' Params - p_route_to_user '|| p_route_to_user,15);
     hr_utility.set_location(l_proc || ' Params - p_user_status '|| p_user_status,15);
     hr_utility.set_location(l_proc || ' Params - p_timeout_days '|| to_char(p_timeout_days),15);
     hr_utility.set_location(l_proc || ' Params - p_form_name '|| p_form_name,15);
     hr_utility.set_location(l_proc || ' Params - p_transaction_id '|| to_char(p_transaction_id) || ' '||l_proc,15);
     hr_utility.set_location(l_proc || ' Params - p_transaction_category_id '|| to_char(p_transaction_category_id),15);
     hr_utility.set_location(l_proc || ' Params - p_post_txn_function '|| p_post_txn_function,15);
     hr_utility.set_location(l_proc || ' Params - p_future_action_cd '|| p_future_action_cd,15);
     hr_utility.set_location(l_proc || ' Params - p_post_style_cd '|| p_post_style_cd,15);
-- as timeout is in days as per our transaction category form, while
-- workflow keeps the timeout in minutes making changes .
     l_timeout_days := nvl(p_timeout_days,0) * 24 * 60;
     wf_engine.createProcess(    ItemType => p_itemtype,
                                 ItemKey  => p_ItemKey,
                                 process  => p_process_name );
     hr_utility.set_location(l_proc || ' Set timeout',15);
     wf_engine.SetItemAttrNumber(itemtype => p_itemtype
                               , itemkey  => p_itemkey
                               , aname    => 'TIMEOUT_DAYS'
                               , avalue   => l_timeout_days);
--     wf_engine.SetItemAttrText(  itemtype => p_itemtype
--                               , itemkey  => p_itemkey
--                               , aname    => 'TRANSACTION_STATUS'
--                               , avalue   => 'PENDING');
     wf_engine.SetItemAttrNumber(  itemtype => p_itemtype
                               , itemkey  => p_itemkey
                               , aname    => 'TRANSACTION_ID'
                               , avalue   => p_transaction_id);
     wf_engine.SetItemAttrNumber(  itemtype => p_itemtype
                               , itemkey  => p_itemkey
                               , aname    => 'TRANSACTION_CATEGORY_ID'
                               , avalue   => p_transaction_category_id);
     wf_engine.SetItemAttrText(  itemtype => p_itemtype
                               , itemkey  => p_itemkey
                               , aname    => 'TRANSACTION_NAME'
                               , avalue   => p_transaction_name);
     hr_utility.set_location('launch url is being set',50);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'LAUNCH_URL',
                                avalue   => p_launch_url);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'TRAN_CAT_NAME',
                                avalue   => p_transaction_category_name);

     l_form_name := l_form_name || ':TRANSACTION_ID=' || to_char(p_transaction_id) || ' ROUTING_HISTORY_ID='||to_char(nvl(p_routing_history_id, 0));

     hr_utility.set_location(l_proc || ' Set form name ' || l_form_name,15);

     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'RHT_FORM_NAME'
                             , avalue   => 'PQHWSRHT:TRANSACTION_CATEGORY_ID='||to_char(p_transaction_category_id)
                                            || ' TRANSACTION_ID=' || to_char(p_transaction_id));
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'PROCESS_LOG_FORM_NAME'
                             , avalue   => 'PQHWSPLG:TRANSACTION_CATEGORY_ID='||to_char(p_transaction_category_id)
                                            || ' TRANSACTION_ID=' || to_char(p_transaction_id));
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'FORM_NAME'
                             , avalue   => l_form_name);
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'POST_TXN_FUNCTION'
                             , avalue   => p_post_txn_function);
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'POST_STYLE_CD'
                             , avalue   => p_post_style_cd);
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'FUTURE_ACTION_CD'
                             , avalue   => p_future_action_cd);
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'TRANSACTION_STATUS'
                             , avalue   => p_user_action_cd);
     wf_engine.SetItemAttrDate(itemtype => p_itemtype
                             , itemkey  => p_itemkey
                             , aname    => 'EFFECTIVE_DATE'
                             , avalue   => p_effective_date);
     wf_engine.SetItemAttrText(itemtype => p_itemtype
                             , itemkey  => p_ItemKey
                             , aname    => 'ROUTED_BY_USER'
                             , avalue   => nvl(fnd_profile.value('USERNAME'),p_route_to_user));
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'COMMENTS',
                                avalue   => p_comments);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER1_NAME',
                                avalue   => p_parameter1_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER1_VALUE',
                                avalue   => p_parameter1_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER2_NAME',
                                avalue   => p_parameter2_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER2_VALUE',
                                avalue   => p_parameter2_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER3_NAME',
                                avalue   => p_parameter3_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER3_VALUE',
                                avalue   => p_parameter3_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER4_NAME',
                                avalue   => p_parameter4_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER4_VALUE',
                                avalue   => p_parameter4_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER5_NAME',
                                avalue   => p_parameter5_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER5_VALUE',
                                avalue   => p_parameter5_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER6_NAME',
                                avalue   => p_parameter6_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER6_VALUE',
                                avalue   => p_parameter6_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER7_NAME',
                                avalue   => p_parameter7_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER7_VALUE',
                                avalue   => p_parameter7_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER8_NAME',
                                avalue   => p_parameter8_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER8_VALUE',
                                avalue   => p_parameter8_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER9_NAME',
                                avalue   => p_parameter9_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER9_VALUE',
                                avalue   => p_parameter9_value);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER10_NAME',
                                avalue   => p_parameter10_name);
     wf_engine.SetItemAttrText( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => 'PARAMETER10_VALUE',
                                avalue   => p_parameter10_value);
     hr_utility.set_location(l_proc || ' p_route_to_user' || p_route_to_user,15);
     hr_utility.set_location(l_proc || ' p_user_status ' || p_user_status,15);
     IF p_route_to_user IS NOT NULL THEN
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'ROUTE_TO_USER',
                                      avalue   => p_route_to_user );
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'NEXT_USER_STATUS',
                                      avalue   => p_user_status );
     ELSE
            wf_engine.SetItemAttrText(itemtype => p_itemtype,
                                      itemkey  => p_ItemKey,
                                      aname    => 'NEXT_USER_STATUS',
                                      avalue   => 'NOT_FOUND' );
     END IF;
     hr_utility.set_location(l_proc || ' Start Process',15);
     wf_engine.StartProcess (  ItemType => p_itemtype,
                               ItemKey  => p_ItemKey );
     hr_utility.set_location(l_proc || ' Exiting ',100);
  End;
  PROCEDURE get_apply_error(p_itemkey          IN  VARCHAR2,
			    p_workflow_name    IN  VARCHAR2,
			    p_apply_error_mesg OUT NOCOPY VARCHAR2,
			    p_apply_error_num  OUT NOCOPY VARCHAR2)
  IS
       l_proc varchar2(61) := g_package ||'get_error' ;
  BEGIN
   hr_utility.set_location(l_proc || ' Entering',10);
   p_apply_error_mesg := wf_engine.GetItemAttrText(
              itemtype => p_workflow_name,
              itemkey  => p_itemkey,
              aname    => 'APPLY_ERROR_MESG');
   hr_utility.set_location(l_proc || 'apply_msg'||substr(p_apply_error_mesg,1,26),20);
   hr_utility.set_location(l_proc || 'apply_msg'||substr(p_apply_error_mesg,27,26),21);
   p_apply_error_num := wf_engine.GetItemAttrText(
              itemtype => p_workflow_name,
              itemkey  => p_itemkey,
              aname    => 'APPLY_ERROR_NUM');
   hr_utility.set_location(l_proc || 'apply_code'||p_apply_error_num,30);
   hr_utility.set_location(l_proc || ' Exiting',100);
  END;

  PROCEDURE set_apply_error(p_itemkey          IN  VARCHAR2,
	                    p_workflow_name    IN  VARCHAR2,
                            p_apply_error_mesg IN  VARCHAR2,
                            p_apply_error_num  IN  VARCHAR2) IS
   l_proc varchar2(61) := g_package ||'set_error' ;
  BEGIN
   hr_utility.set_location(l_proc || ' Entering',10);
   hr_utility.set_location(l_proc || ' itemkey'||p_itemkey,20);
   hr_utility.set_location(l_proc || ' workflow_name'||p_workflow_name,30);
   hr_utility.set_location(l_proc || ' error_mesg'||substr(p_apply_error_mesg,1,26),31);
   hr_utility.set_location(l_proc || ' error_mesg'||substr(p_apply_error_mesg,27,26),32);
   hr_utility.set_location(l_proc || ' error_num'||p_apply_error_num,33);
   wf_engine.SetItemAttrText(
              itemtype => p_workflow_name,
              itemkey  => p_itemkey,
              aname    => 'APPLY_ERROR_MESG',
              avalue   => p_apply_error_mesg);
   hr_utility.set_location(l_proc || ' error_mesg'||substr(p_apply_error_mesg,1,26),35);
   hr_utility.set_location(l_proc || ' error_mesg'||substr(p_apply_error_mesg,27,26),35);
   wf_engine.SetItemAttrText(
              itemtype => p_workflow_name,
              itemkey  => p_itemkey,
              aname    => 'APPLY_ERROR_NUM',
              avalue   => p_apply_error_num);
   hr_utility.set_location(l_proc || ' error_num'||p_apply_error_num,38);
   hr_utility.set_location(l_proc || ' Exiting',100);
  END;

  function get_notification_detail(p_itemkey in varchar2,
                                   p_mode    in varchar2) return varchar2 is
     cursor c1 is
      SELECT A.NAME activity_name,
             wf_directory.getroledisplayname(IAS.ASSIGNED_USER) role_name ,IAS.ASSIGNED_USER owner
      from WF_ACTIVITIES_VL A, WF_PROCESS_ACTIVITIES PA,
           WF_ITEM_TYPES_VL IT, WF_ITEMS I, WF_ITEM_ACTIVITY_STATUSES IAS
      WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
      and IAS.ITEM_KEY = I.ITEM_KEY
      and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
      and I.ITEM_TYPE = IT.NAME
      and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
      and PA.ACTIVITY_NAME = A.NAME
      and PA.ACTIVITY_ITEM_TYPE = A.ITEM_TYPE
      and I.item_type ='PQHGEN'
      and PA.activity_name like 'NTF_%'
      and IAS.activity_status ='NOTIFIED'
      and I.item_key = p_itemkey;
      l_activity varchar2(100);
      l_user_name varchar2(240);
      l_role_name varchar2(240);
      l_user_name_display varchar2(240);
      l_role_prefix varchar2(80);
  begin
     open c1;
     fetch c1 into l_activity,l_role_name,l_user_name;
     close c1;
     if p_mode = 'ACT' then
        return l_activity;
     else
        if l_role_name is not null then
           if instr(l_user_name,'POS:') >0 then
              -- Position is the owner
              l_role_prefix := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                                        p_lookup_code => 'POSITION');
           elsif instr(l_user_name,'PQH_ROLE:') >0 then
              -- PQH role is the owner
              l_role_prefix := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                                        p_lookup_code => 'ROLE');
           else
              -- user is the owner
              l_role_prefix := hr_general.decode_lookup(p_lookup_type => 'PQH_BPR_ROUTING',
                                                        p_lookup_code => 'USER');
           end if;
           l_user_name_display := l_role_prefix||':'||l_role_name;
        end if;
        return l_user_name_display;
     end if;
  end get_notification_detail;

  function get_respond_activity(p_itemkey in varchar2) return varchar2 is
      l_activity varchar2(100);
  begin
     l_activity := get_notification_detail(p_itemkey => p_itemkey,
                                           p_mode    => 'ACT');
     return l_activity;
  end get_respond_activity;

  PROCEDURE process_user_action(
        p_transaction_category_id        IN NUMBER
      , p_transaction_id                 IN NUMBER
      , p_workflow_seq_no                IN NUMBER      DEFAULT null
      , p_routing_category_id            IN NUMBER      DEFAULT null
      , p_member_cd                      IN VARCHAR2    DEFAULT NULL
      , p_user_action_cd                 IN VARCHAR2    DEFAULT 'FORWARD'
      , p_route_to_user                  IN VARCHAR2
      , p_user_status                    IN VARCHAR2    DEFAULT 'FOUND'
      , p_approval_cd                    IN VARCHAR2    DEFAULT NULL
      , p_pos_structure_version_id       IN NUMBER      DEFAULT null
      , p_comments                       IN VARCHAR2    DEFAULT NULL
      , p_forwarded_to_user_id           IN NUMBER      DEFAULT null
      , p_forwarded_to_role_id           IN NUMBER      DEFAULT null
      , p_forwarded_to_position_id       IN NUMBER      DEFAULT null
      , p_forwarded_to_assignment_id     IN NUMBER      DEFAULT null
      , p_forwarded_to_member_id         IN NUMBER      DEFAULT null
      , p_forwarded_by_user_id           IN NUMBER      DEFAULT null
      , p_forwarded_by_role_id           IN NUMBER      DEFAULT null
      , p_forwarded_by_position_id       IN NUMBER      DEFAULT null
      , p_forwarded_by_assignment_id     IN NUMBER      DEFAULT null
      , p_forwarded_by_member_id         in NUMBER      DEFAULT null
      , p_effective_date                 IN DATE        DEFAULT NULL
      , p_parameter1_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter1_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter2_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter2_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter3_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter3_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter4_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter4_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter5_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter5_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter6_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter6_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter7_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter7_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter8_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter8_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter9_name                IN VARCHAR2    DEFAULT NULL
      , p_parameter9_value               IN VARCHAR2    DEFAULT NULL
      , p_parameter10_name               IN VARCHAR2    DEFAULT NULL
      , p_parameter10_value              IN VARCHAR2    DEFAULT NULL
      , p_transaction_name               IN VARCHAR2    DEFAULT NULL
      , p_apply_error_mesg               OUT NOCOPY VARCHAR2
      , p_apply_error_num                OUT NOCOPY VARCHAR2
      )
  IS
      l_itemkey                          VARCHAR2(30);
      l_del_itemkey                      VARCHAR2(30);
      l_workflow_name                    VARCHAR2(30);
      l_transaction_category_name        VARCHAR2(100);
      l_process_name                     VARCHAR2(30);
      l_proc                             VARCHAR2(61)  := g_package  || 'process_user_action';
      l_timeout_days                     NUMBER;
      l_form_name                        VARCHAR2(100);
      l_pos                              NUMBER;
      l_post_txn_function                VARCHAR2(61);
      l_future_action_cd                 VARCHAR2(30);
      l_post_style_cd                    VARCHAR2(30);
      l_short_name                       VARCHAR2(30);
      l_route_to_user                    FND_USER.USER_NAME%TYPE;
      l_wf_not_running                   BOOLEAN;
      l_apply_error_mesg                 VARCHAR2(200) := 'No_Error';
      l_apply_error_num                  VARCHAR2(30)  := '0' ;
      l_routing_history_id               NUMBER;
      l_user_action_cd                   VARCHAR2(50)  := p_user_action_cd;
      l_forwarded_to_assignment_id       NUMBER;
      l_forwarded_to_member_id           NUMBER;
      l_forwarded_to_position_id         NUMBER;
      l_forwarded_to_user_id             NUMBER;
      l_forwarded_to_role_id             NUMBER;
      l_url                              varchar2(2000);
      l_requestor                        VARCHAR2(100);
      l_rejector                         VARCHAR2(100);
      l_activity                         VARCHAR2(100);
      l_effective_date                   DATE;

  BEGIN
--
--  Print parameters for debugging
--
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' Parameter - p_transaction_category_id = ' || to_char(p_transaction_category_id), 15);
     hr_utility.set_location(l_proc || ' Parameter - p_transaction_id = '     || to_char(p_transaction_id), 20);
     hr_utility.set_location(l_proc || ' Parameter - p_routing_category_id = '|| to_char(p_routing_category_id), 25);
     hr_utility.set_location(l_proc || ' Parameter - p_user_action_cd = '  || p_user_action_cd, 30);
     hr_utility.set_location(l_proc || ' Parameter - p_route_to_user = '   || p_route_to_user, 35);
     hr_utility.set_location(l_proc || ' Parameter - to_role = '           || p_forwarded_to_role_id, 35);
     hr_utility.set_location(l_proc || ' Parameter - to_user = '           || p_forwarded_to_user_id, 35);
     hr_utility.set_location(l_proc || ' Parameter - to_position = '       || p_forwarded_to_position_id, 35);
     hr_utility.set_location(l_proc || ' Parameter - to_assignment = '     || p_forwarded_to_assignment_id, 35);
     hr_utility.set_location(l_proc || ' Parameter - p_user_status = '     || p_user_status, 40);
     hr_utility.set_location(l_proc || ' Parameter - p_pos_structure_version_id= ' || to_char(p_pos_structure_version_id), 45);
     hr_utility.set_location(l_proc || ' Parameter - p_comments =   ' || substr(p_comments,1,20), 50);
     hr_utility.set_location(l_proc || ' Parameter - p_member_cd =  ' || p_member_cd, 55);
     hr_utility.set_location(l_proc || ' Parameter - p_transaction_name =   ' || substr(p_transaction_name,1,20), 57);
--
--   Return if Save and Continue selected
--
     IF l_user_action_cd = 'SAVE' THEN
        RETURN;
     END IF;

     l_forwarded_to_assignment_id       := p_forwarded_to_assignment_id;
     l_forwarded_to_member_id           := p_forwarded_to_member_id;
     l_forwarded_to_position_id         := p_forwarded_to_position_id;
     l_forwarded_to_user_id             := p_forwarded_to_user_id;
     l_forwarded_to_role_id             := p_forwarded_to_role_id;

--
--   Check transaction category and transaction id before continueing
--
     IF     p_transaction_category_id IS NULL
        OR  p_transaction_id IS NULL THEN
          hr_utility.set_message(8302,'PQH_NULL_TRANSACTION_ID_OR_CAT');
          hr_utility.raise_error;
     END IF;
     l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;
--
-- Currently only for FYI Notifications.
--
     IF l_user_action_cd in ('FYI_NOT','PQH_BPR')THEN
        if p_workflow_seq_no = 0 THEN
           hr_utility.set_message(8302,'PQH_FYI_NOT_THEN_SEQ_NO_ZERO');
           hr_utility.raise_error;
        END IF;
     else
        if p_workflow_seq_no <> 0 THEN
           hr_utility.set_message(8302,'PQH_FYI_NOT_THEN_SEQ_NO_ZERO');
           hr_utility.raise_error;
        END IF;
     END IF;

     if nvl(p_workflow_seq_no, 0) <> 0 then
        l_itemkey := l_itemkey || '-' || to_char(p_workflow_seq_no);
     end if;
-- ----------------------------------------------------------------

     create_process_log('In Process User Action ' || l_itemkey || '-'
                        || p_route_to_user || '-' || l_user_action_cd);

     l_route_to_user := p_route_to_user;

     get_workflow_info(p_transaction_category_id => p_transaction_category_id
                     , p_transaction_category_name => l_transaction_category_name
                     , p_workflow_name           => l_workflow_name
                     , p_process_name            => l_process_name
                     , p_timeout_days            => l_timeout_days
                     , p_form_name               => l_form_name
                     , p_post_txn_function       => l_post_txn_function
                     , p_future_action_cd        => l_future_action_cd
                     , p_post_style_cd           => l_post_style_cd
                     , p_short_name              => l_short_name
                     );

     l_wf_not_running := wf_process_not_running (p_itemkey   => l_itemkey
                                              ,  p_itemtype  => l_workflow_name);
     if l_short_name ='PQH_BPR' then
        hr_utility.set_Location('build the url',25);
        l_url := pqh_bdgt_realloc_utility.url_builder(p_transaction_id => p_transaction_id);
        hr_utility.set_Location('url1 is'||substr(l_url,1,50),26);
        hr_utility.set_Location('url2 is'||substr(l_url,51,50),27);
        hr_utility.set_Location('url3 is'||substr(l_url,101,50),28);
        hr_utility.set_Location('url4 is'||substr(l_url,151,50),29);
     end if;
     IF l_user_action_cd = 'APPLY' THEN
          IF p_effective_date IS NULL THEN
                hr_utility.set_message(8302,'PQH_NULL_EFFECTIVE_DATE');
                hr_utility.raise_error;
          END IF;
          l_route_to_user := nvl(fnd_profile.value('USERNAME'),p_route_to_user);
          hr_utility.set_location('route_to user'||l_route_to_user, 281);
     ELSIF l_user_action_cd IN ('FORWARD') THEN
          IF   p_member_cd = 'R' AND p_forwarded_to_member_id IS NULL THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_MEMBER_ID', 30);
                hr_utility.set_message(8302,'PQH_NULL_MEMBER_ID');
                hr_utility.raise_error;
          ELSIF p_member_cd = 'S' AND p_forwarded_to_assignment_id IS NULL THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_ASSIGNMENT_ID', 30);
                hr_utility.set_message(8302, 'PQH_NULL_ASSIGNMENT_ID');
                hr_utility.raise_error;
          ELSIF p_member_cd = 'P' AND (p_forwarded_to_position_id IS NULL OR
                                       p_pos_structure_version_id IS NULL) THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_POS_OR_STRUCTURE_ID', 35);
                hr_utility.set_message(8302, 'PQH_NULL_POS_OR_STRUCTURE_ID');
                hr_utility.set_location(l_proc || ' PQH_NULL_POS_OR_STRUCTURE_ID', 38);
                hr_utility.raise_error;
          END IF;
          IF    l_route_to_user IS NULL
             OR p_user_status   IS NULL THEN
                hr_utility.set_message(8302,'PQH_NULL_DESTINATION');
                hr_utility.raise_error;
          END IF;
     ELSIF l_user_action_cd IN ( 'BACK', 'OVERRIDE') THEN
          IF   p_member_cd = 'R' AND p_forwarded_to_role_id IS NULL THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_ROLE_ID', 30);
                hr_utility.set_message(8302,'PQH_NULL_ROLE_ID');
                hr_utility.raise_error;
          ELSIF p_member_cd = 'S' AND p_forwarded_to_assignment_id IS NULL THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_ASSIGNMENT_ID', 30);
                hr_utility.set_message(8302, 'PQH_NULL_ASSIGNMENT_ID');
                hr_utility.raise_error;
          ELSIF p_member_cd = 'P' AND (p_forwarded_to_position_id IS NULL OR
                                       p_pos_structure_version_id IS NULL) THEN
                hr_utility.set_location(l_proc || ' PQH_NULL_POS_OR_STRUCTURE_ID', 35);
                hr_utility.set_message(8302, 'PQH_NULL_POS_OR_STRUCTURE_ID');
                hr_utility.set_location(l_proc || ' PQH_NULL_POS_OR_STRUCTURE_ID', 38);
                hr_utility.raise_error;
          END IF;
          IF    l_route_to_user IS NULL
             OR p_user_status   IS NULL THEN
                hr_utility.set_message(8302,'PQH_NULL_DESTINATION');
                hr_utility.raise_error;
          END IF;
     ELSIF l_user_action_cd in ('INBOX','DBERROR') THEN
        l_route_to_user := nvl(p_route_to_user, fnd_global.user_name );
        hr_utility.set_location(l_proc || ' inbox or dberror'||l_route_to_user, 40);
     ELSIF l_user_action_cd = 'REJECT' THEN
          get_requestor_history(
               p_transaction_category_id        => p_transaction_category_id
             , p_transaction_id                 => p_transaction_id
             , p_user_name                      => l_requestor
             , p_forwarded_by_assignment_id     => l_forwarded_to_assignment_id
             , p_forwarded_by_member_id         => l_forwarded_to_member_id
             , p_forwarded_by_position_id       => l_forwarded_to_position_id
             , p_forwarded_by_user_id           => l_forwarded_to_user_id
             , p_forwarded_by_role_id           => l_forwarded_to_role_id
          );
          hr_utility.set_location(l_proc || 'requestor is '||l_requestor,401);
          l_rejector := nvl(fnd_profile.value('USERNAME'),p_route_to_user);
          hr_utility.set_location(l_proc || 'rejected by is '||l_rejector,402);
          IF l_requestor is null or l_rejector is null then
             hr_utility.set_location('requestor or rejector null ', 403);
             l_forwarded_to_assignment_id       := p_forwarded_to_assignment_id;
             l_forwarded_to_member_id           := p_forwarded_to_member_id;
             l_forwarded_to_position_id         := p_forwarded_to_position_id;
             l_forwarded_to_user_id             := p_forwarded_to_user_id;
             l_forwarded_to_role_id             := p_forwarded_to_role_id;
          elsif l_requestor <> l_rejector then
              -- transaction is to be routed to initiator, but if initiator position is eliminated
              -- user should be asked for immediate rejection.
              hr_utility.set_location('requestor different than rejector ', 404);
              if l_forwarded_to_position_id is not null then
                 hr_utility.set_location('is sent to pos', 405);
                 l_effective_date := hr_general.get_position_date_end(p_position_id => l_forwarded_to_position_id);
                 hr_utility.set_location('pos effective date is'||to_char(l_effective_date,'ddmmRRRR'), 406);
                 if (l_effective_date is null or l_effective_date > trunc(sysdate)) then
                    hr_utility.set_location(l_proc || 'initiator position valid', 41);
                    l_route_to_user                  := l_requestor;
                    l_user_action_cd                 := 'FRWRD_RJCT';
                 else
                    hr_utility.set_location(l_proc || 'initiator position eliminated', 42);
                    hr_utility.set_location(l_proc || 'rejecting it right away ', 44);
                    l_forwarded_to_assignment_id       := p_forwarded_to_assignment_id;
                    l_forwarded_to_member_id           := p_forwarded_to_member_id;
                    l_forwarded_to_position_id         := p_forwarded_to_position_id;
                    l_forwarded_to_user_id             := p_forwarded_to_user_id;
                    l_forwarded_to_role_id             := p_forwarded_to_role_id;
                 end if;
              else
                 hr_utility.set_location('not being sent to pos', 404);
                 l_route_to_user                  := l_requestor;
                 l_user_action_cd                 := 'FRWRD_RJCT';
              end if;
          ELSE
              hr_utility.set_location('requestor same as rejector',405);
              l_forwarded_to_assignment_id       := p_forwarded_to_assignment_id;
              l_forwarded_to_member_id           := p_forwarded_to_member_id;
              l_forwarded_to_position_id         := p_forwarded_to_position_id;
              l_forwarded_to_user_id             := p_forwarded_to_user_id;
              l_forwarded_to_role_id             := p_forwarded_to_role_id;
          END IF;
        hr_utility.set_location('action_cd is'||l_user_action_cd, 405);
     ELSIF l_user_action_cd = 'DELEGATE' THEN
        -- check whether the notification already exists or not, if it exists in that case
        -- workflow is not to be started for the delegated worksheet but transaction is to be routed
	-- to the user recorded in the transaction
        l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;
        if not l_wf_not_running then
           set_next_user (
               p_itemtype        => l_workflow_name
             , p_itemkey         => l_itemkey
             , p_route_to_user   => l_route_to_user
             , p_status          => p_user_status
            );
         wf_engine.SetItemAttrText(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'TRANSACTION_NAME',
                avalue   => p_transaction_name);
         wf_engine.SetItemAttrText(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'TRAN_CAT_NAME',
                avalue   => l_transaction_category_name);
          l_activity := get_respond_activity(l_itemkey);
           wf_engine.CompleteActivity(
                     l_workflow_name
                   , l_itemkey
                   , l_activity
                   , l_user_action_cd);
           hr_utility.set_location(l_proc || 'Completed Activity '||l_activity,70);
        end if;
     END IF;
     hr_utility.set_location(l_proc || ' l_user_action_cd '|| l_user_action_cd,75);
     IF l_user_action_cd NOT IN ('INBOX','DBERROR','FYI_NOT', 'DELEGATE','PQH_BPR') THEN
        create_routing_history(
           p_transaction_category_id        => p_transaction_category_id
         , p_transaction_id                 => p_transaction_id
         , p_routing_category_id            => p_routing_category_id
         , p_pos_structure_version_id       => p_pos_structure_version_id
         , p_user_action_cd                 => l_user_action_cd
         , p_approval_cd                    => p_approval_cd
         , p_notification_date              => sysdate
         , p_comments                       => p_comments
         , p_forwarded_to_user_id           => l_forwarded_to_user_id
         , p_forwarded_to_role_id           => l_forwarded_to_role_id
         , p_forwarded_to_position_id       => l_forwarded_to_position_id
         , p_forwarded_to_assignment_id     => l_forwarded_to_assignment_id
         , p_forwarded_to_member_id         => l_forwarded_to_member_id
         , p_forwarded_by_user_id           => p_forwarded_by_user_id
         , p_forwarded_by_role_id           => p_forwarded_by_role_id
         , p_forwarded_by_position_id       => p_forwarded_by_position_id
         , p_forwarded_by_assignment_id     => p_forwarded_by_assignment_id
         , p_forwarded_by_member_id         => p_forwarded_by_member_id
         , p_routing_history_id             => l_routing_history_id
        );
        IF not l_wf_not_running THEN -- Create a new workflow process
           l_form_name := wf_engine.GetItemAttrText(itemtype => l_workflow_name
                                , itemkey  => l_itemkey
                                , aname    => 'FORM_NAME'
                             );
           l_pos := instr(l_form_name, ' ROUTIN');
           IF l_pos > 0 THEN
              l_form_name := substr(l_form_name, 1, l_pos - 1);
           end if;
           l_form_name := l_form_name || ' ROUTING_HISTORY_ID=' || to_char(nvl(l_routing_history_id, 0));

           hr_utility.set_location(l_proc || ' Set form name ' || l_form_name,15);
           wf_engine.SetItemAttrText(itemtype => l_workflow_name
                                   , itemkey  => l_itemkey
                                   , aname    => 'FORM_NAME'
                                   , avalue   => l_form_name);
        END IF;
      END IF;
      IF l_wf_not_running THEN -- Create a new workflow process
           hr_utility.set_location(l_proc || ' Before Start Process called', 35);
           hr_utility.set_location(l_proc || ' in - p_route_to_user = '   || p_route_to_user, 36);
           hr_utility.set_location(l_proc || ' out - l_route_to_user = '   || l_route_to_user, 37);
           StartProcess(
               p_itemkey                    => l_itemkey
             , p_itemtype                   => l_workflow_name
             , p_process_name               => l_process_name
             , p_route_to_user              => l_route_to_user
             , p_user_status                => p_user_status
             , p_timeout_days               => l_timeout_days
             , p_form_name                  => l_form_name
             , p_transaction_id             => p_transaction_id
             , p_transaction_category_id    => p_transaction_category_id
             , p_post_txn_function          => l_post_txn_function
             , p_future_action_cd           => l_future_action_cd
             , p_post_style_cd              => l_post_style_cd
             , p_user_action_cd             => l_user_action_cd
             , p_effective_date             => p_effective_date
             , p_transaction_name           => p_transaction_name
             , p_transaction_category_name  => l_transaction_category_name
             , p_routing_history_id         => l_routing_history_id
             , p_comments                   => p_comments
             , p_launch_url                 => l_url
             , p_parameter1_name            => p_parameter1_name
             , p_parameter1_value           => p_parameter1_value
             , p_parameter2_name            => p_parameter2_name
             , p_parameter2_value           => p_parameter2_value
             , p_parameter3_name            => p_parameter3_name
             , p_parameter3_value           => p_parameter3_value
             , p_parameter4_name            => p_parameter4_name
             , p_parameter4_value           => p_parameter4_value
             , p_parameter5_name            => p_parameter5_name
             , p_parameter5_value           => p_parameter5_value
             , p_parameter6_name            => p_parameter6_name
             , p_parameter6_value           => p_parameter6_value
             , p_parameter7_name            => p_parameter7_name
             , p_parameter7_value           => p_parameter7_value
             , p_parameter8_name            => p_parameter8_name
             , p_parameter8_value           => p_parameter8_value
             , p_parameter9_name            => p_parameter9_name
             , p_parameter9_value           => p_parameter9_value
             , p_parameter10_name            => p_parameter10_name
             , p_parameter10_value           => p_parameter10_value
           );
      END IF;
      hr_utility.set_location(l_proc || ' l_route_to_user '|| l_route_to_user,50);
      hr_utility.set_location(l_proc || ' l_user_action_cd '|| l_user_action_cd,50);

      wf_engine.SetItemAttrText( itemtype => l_workflow_name,
                                 itemkey  => l_itemkey,
                                 aname    => 'COMMENTS',
                                 avalue   => p_comments);
      IF NOT l_wf_not_running THEN  -- Move forward with the existing workflow process
         hr_utility.set_location(l_proc || ' Completing Activity '||l_activity,60);
         wf_engine.SetItemAttrText(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'TRAN_CAT_NAME',
                avalue   => l_transaction_category_name);
         hr_utility.set_location(l_proc || ' l_route_to_user '|| l_route_to_user,50);
         wf_engine.SetItemAttrDate(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'EFFECTIVE_DATE',
                avalue   => p_effective_date);
         wf_engine.SetItemAttrText(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'TRANSACTION_STATUS',
                avalue   => l_user_action_cd);
         wf_engine.SetItemAttrText(
                itemtype => l_workflow_name,
                itemkey  => l_itemkey,
                aname    => 'TRANSACTION_NAME',
                avalue   => p_transaction_name);
--added by kgowripe for fixing 2897321
         hr_utility.set_location('resetting launch url ',51);
         wf_engine.SetItemAttrText( itemtype => l_workflow_name,
                                    itemkey  => l_itemkey,
                                    aname    => 'LAUNCH_URL',
                                    avalue   => l_url);
--changes end here kgowripe
         set_apply_error(p_itemkey          => l_itemkey,
 		         p_workflow_name    => l_workflow_name,
		         p_apply_error_mesg => l_apply_error_mesg,
		         p_apply_error_num  => l_apply_error_num );
         hr_utility.set_location(l_proc || ' After setting attributes ',65);
         IF l_user_action_cd IN ('FORWARD', 'BACK', 'OVERRIDE', 'INBOX','DBERROR','DELEGATE', 'FRWRD_RJCT') THEN
              set_next_user (
                  p_itemtype        => l_workflow_name
                , p_itemkey         => l_itemkey
                , p_route_to_user   => l_route_to_user
                , p_status          => p_user_status
               );
         END IF;
         hr_utility.set_location(l_proc || ' After setting user ',67);
         l_activity := get_respond_activity(l_itemkey);
         hr_utility.set_location(l_proc || ' activity is '||l_activity,68);
         hr_utility.set_location(l_proc || ' action_cd is '||l_user_action_cd,69);
         begin
            wf_engine.CompleteActivity(
                   l_workflow_name
                 , l_itemkey
                 , l_activity
                 , l_user_action_cd);
         exception
            when others then
               hr_utility.set_location(l_proc || 'Completed Activity fail'||l_activity,690);
               hr_utility.set_location(l_proc || ':'||substr(sqlerrm,1,30),691);
               hr_utility.set_location(l_proc || ':'||substr(sqlerrm,31,30),692);
         end;
         hr_utility.set_location(l_proc || 'Completed Activity '||l_activity,70);
     END IF;
     get_apply_error(p_itemkey          => l_itemkey,
		     p_workflow_name    => l_workflow_name,
		     p_apply_error_mesg => p_apply_error_mesg,
		     p_apply_error_num  => p_apply_error_num );
     hr_utility.set_location(l_proc || 'apply_code'||p_apply_error_num,80);
     hr_utility.set_location(l_proc || 'apply_mesg'||substr(p_apply_error_mesg,1,20),90);

     hr_utility.set_location(l_proc || ' Exiting ',100);
  END;

  PROCEDURE REROUTE_FUTURE_ACTION (
      p_transaction_category_id      in NUMBER
    , p_transaction_id               in NUMBER
    , p_route_to_user                in VARCHAR2
    , p_user_status                  in VARCHAR2
    )
  IS
      l_itemkey            VARCHAR2(30);
      l_workflow_name      VARCHAR2(30);
      l_transaction_category_name VARCHAR2(100);
      l_process_name       VARCHAR2(30);
      l_proc               VARCHAR2(61)  := g_package  || 'reroute_future_action';
      l_timeout_days       NUMBER;
      l_form_name          VARCHAR2(30);
      l_short_name         VARCHAR2(30);
      l_post_txn_function  VARCHAR2(61);
      l_future_action_cd   VARCHAR2(30);
      l_post_style_cd      VARCHAR2(30);
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;

     get_workflow_info(p_transaction_category_id => p_transaction_category_id
                     , p_transaction_category_name => l_transaction_category_name
                     , p_workflow_name           => l_workflow_name
                     , p_process_name            => l_process_name
                     , p_timeout_days            => l_timeout_days
                     , p_form_name               => l_form_name
                     , p_post_txn_function       => l_post_txn_function
                     , p_future_action_cd        => l_future_action_cd
                     , p_post_style_cd           => l_post_style_cd
                     , p_short_name              => l_short_name
                     );
     set_next_user (
        p_itemtype        => l_workflow_name
	  , p_itemkey         => l_itemkey
      , p_route_to_user   => p_route_to_user
      , p_status          => p_user_status
      );
     wf_engine.CompleteActivity(
                l_workflow_name
              , l_itemkey
              , 'BLOCK'
              , 'REROUTE');
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;
--
-- get last user's response from routing history
--
  FUNCTION get_user_response (p_transaction_id          IN NUMBER
                           ,  p_transaction_category_id IN NUMBER)
  RETURN VARCHAR2
  IS
      CURSOR c_get_status  IS
                SELECT user_action_cd
                FROM   pqh_routing_history
                WHERE  transaction_id          = p_transaction_id
                  AND  transaction_category_id = p_transaction_category_id
                ORDER BY routing_history_id desc;
      r_get_status c_get_status%ROWTYPE;
      l_proc            VARCHAR2(61)  := g_package  || 'get_user_response';
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     OPEN c_get_status;
     FETCH c_get_status INTO r_get_status;
     CLOSE c_get_status;
     hr_utility.set_location(l_proc || ' Exiting',100);
     RETURN r_get_status.user_action_cd;
  END;
--
-- Mark notification as sent
--
  PROCEDURE mark_fyi_sent(p_fyi_notified_id  IN NUMBER
                        , p_status         IN VARCHAR2)
  IS
     l_proc            VARCHAR2(61)  := g_package  || 'mark_fyi_sent';
  BEGIN
       hr_utility.set_location(l_proc || ' Entering',10);
       UPDATE pqh_fyi_notify
          SET status            = p_status
            , notification_date = sysdate
       WHERE fyi_notified_id = p_fyi_notified_id;
       hr_utility.set_location(l_proc || ' Exiting',100);
  END;
  PROCEDURE CHECK_FYI  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_proc            VARCHAR2(61)  := g_package  || 'check_fyi';
      CURSOR c_get_fyi (p_transaction_id          NUMBER
                     ,  p_transaction_category_id NUMBER
                     ) IS
                 SELECT fyi_notified_id
                      , notified_name
                      , notification_event_cd
                      , notified_type_cd
                 FROM   pqh_fyi_notify
                 WHERE  transaction_id          = p_transaction_id
                   AND  transaction_category_id = p_transaction_category_id
                   AND  STATUS IS NULL;
--      r_get_fyi   c_get_fyi%ROWTYPE;
      l_user_action_cd           pqh_routing_history.user_action_cd%TYPE;
      l_transaction_id           pqh_routing_history.transaction_id%TYPE;
      l_transaction_category_id  pqh_routing_history.transaction_category_id%TYPE;
      l_user                     fnd_user.user_name%TYPE;
      l_transaction_status       VARCHAR2(30);
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
    IF (FUNCMODE  = 'RUN') THEN
      l_user_action_cd := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey  => ItemKey,
                                                    aname    => 'TRANSACTION_STATUS');
      hr_utility.set_location(l_proc || ' user action code ' || l_user_action_cd, 25);
      --ns:26-Jun-2006: Bug 5357676: Set routed_by_user for correct From to appear in fyi notification.
      wf_engine.SetItemAttrText(itemtype => itemtype
                             , itemkey  => itemKey
                             , aname    => 'ROUTED_BY_USER'
                             , avalue   => FND_GLOBAL.user_name );
      --ns: end fix for 5357676
      IF l_user_action_cd in ('FYI_NOT','PQH_BPR') THEN
           l_user := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => ItemKey,
                                               aname    => 'ROUTE_TO_USER');
           hr_utility.set_location(l_proc || ' user ' || l_user, 28);
           SET_FYI_USER (
                p_itemtype              => itemtype
              , p_itemkey               => itemkey
              , p_fyi_user              => l_user
                );
          result := 'COMPLETE:'||l_user_action_cd;
          RETURN;
      END IF;
      decode_itemkey(p_itemkey                 => itemkey
                   , p_transaction_category_id => l_transaction_category_id
                   , p_transaction_id          => l_transaction_id);
--      l_user_action_cd := get_user_response(p_transaction_category_id => l_transaction_category_id
--                                          , p_transaction_id          => l_transaction_id);
      hr_utility.set_location(l_proc || 'Item Key ' || itemkey, 29);
      FOR r_get_fyi IN c_get_fyi(p_transaction_category_id => l_transaction_category_id
                               , p_transaction_id          => l_transaction_id)
      LOOP
         IF r_get_fyi.notified_type_cd = 'APPROVER' THEN
               l_user := get_approver(p_transaction_category_id => l_transaction_category_id
                                    , p_transaction_id          => l_transaction_id);
         ELSIF r_get_fyi.notified_type_cd = 'REQUESTOR' THEN
               l_user := get_requestor(p_transaction_category_id => l_transaction_category_id
                                     , p_transaction_id          => l_transaction_id);
         ELSIF r_get_fyi.notified_type_cd = 'LAST_USER' THEN
               l_user := get_last_user(p_transaction_category_id => l_transaction_category_id
                                     , p_transaction_id          => l_transaction_id);
         ELSE
               l_user := r_get_fyi.notified_name;
         END IF;
         hr_utility.set_location(l_proc || 'for -'||r_get_fyi.fyi_notified_id||' l_user : ' || l_user, 90);
         IF   (r_get_fyi.notification_event_cd = 'APPROVAL'   AND l_user_action_cd IN ('APPLY', 'OVERRIDE','FORWARD','BACK'))
           OR (r_get_fyi.notification_event_cd = 'REJECTION'  AND l_user_action_cd = 'REJECT')
           OR (r_get_fyi.notification_event_cd = 'DBFAILURE'  AND l_user_action_cd = 'DBFAILURE')
           OR (r_get_fyi.notification_event_cd = 'DBSUCCESS'  AND l_user_action_cd = 'DBSUCCESS')
           OR (r_get_fyi.notification_event_cd = 'COMPLETION' AND l_user_action_cd IN ('DBSUCCESS', 'REJECT', 'ERROR'))
           OR (r_get_fyi.notification_event_cd = 'IMMEDIATE')
         THEN
               IF l_user IS NOT NULL THEN
                   SET_FYI_USER (
                      p_itemtype              => itemtype
                    , p_itemkey               => itemkey
                    , p_fyi_user              => l_user
                   );
                   mark_fyi_sent(p_fyi_notified_id  => r_get_fyi.fyi_notified_id
                               , p_status           => 'SENT');
                   result := 'COMPLETE:SUCCESS';
                   hr_utility.set_location(l_proc || ' Exiting',10);
                   RETURN;
               END IF;
         ELSIF (r_get_fyi.notification_event_cd = 'OVERRIDE'   AND l_user_action_cd IN ('APPLY', 'OVERRIDE','FORWARD','BACK'))
            THEN
               -- if approver was override approver then this should be invoked
               if check_approver(p_itemkey => itemkey) and l_user IS NOT NULL THEN
                   SET_FYI_USER (
                      p_itemtype              => itemtype
                    , p_itemkey               => itemkey
                    , p_fyi_user              => l_user
                   );
                   mark_fyi_sent(p_fyi_notified_id  => r_get_fyi.fyi_notified_id
                               , p_status           => 'SENT');
                   result := 'COMPLETE:SUCCESS';
                   hr_utility.set_location(l_proc || ' Exiting',10);
                   RETURN;
               END IF;
         END IF;
      END LOOP;
      result := 'COMPLETE:FAILURE';
      hr_utility.set_location(l_proc || ' Exiting',10);
      RETURN;
    END IF;
    hr_utility.set_location(l_proc || ' Exiting',10);
  END;

-- This procedure was added so that workflow definition can be used by Budget reallocation

  PROCEDURE WHICH_TXN_CAT  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_proc     VARCHAR2(61)  := g_package  || 'which_txn_cat';
      l_transaction_category_id number;
      l_transaction_id number;
      l_short_name pqh_transaction_categories.short_name%type;
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
    IF (FUNCMODE  = 'RUN') THEN
        create_process_log('which_txn_cat ' || itemkey);
        decode_itemkey(p_itemkey                 => itemkey
                      ,p_transaction_category_id => l_transaction_category_id
                      ,p_transaction_id          => l_transaction_id);
        select short_name into l_short_name
        from pqh_transaction_categories
        where transaction_category_id = l_transaction_category_id;
	result := 'COMPLETE:' || l_short_name;
        hr_utility.set_location(l_proc || ' short_name '||l_short_name,30);
        hr_utility.set_location(l_proc || ' Exiting ',100);
	return;
    ELSE
        hr_utility.set_location(l_proc || ' Exiting',100);
    END IF;
  exception when others then
     result := null;
     raise;
  END;

  PROCEDURE FIND_NOTICE_TYPE  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_status   varchar2(30);
      l_user     varchar2(30);
      l_user_action_cd     varchar2(30);
      l_proc     VARCHAR2(61)  := g_package  || 'find_notice_type';
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
    IF (FUNCMODE  = 'RUN') THEN
        create_process_log('Find Notice_type ' || itemkey);
        l_user_action_cd := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => ItemKey,
                                              aname    => 'TRANSACTION_STATUS');
        if l_user_action_cd = 'OVERRIDE' then
           l_status := 'OVERRIDE';
        elsif l_user_action_cd ='BACK' then
           l_status := 'SEND_BACK';
        elsif l_user_action_cd ='FRWRD_RJCT' then
           l_status := 'REJECT';
        elsif l_user_action_cd ='WARNING' then
           l_status := 'WARNING';
        elsif l_user_action_cd ='DBERROR' then
           l_status := 'ERROR';
        else
           hr_utility.set_location(l_proc || 'user_action_cd'||l_user_action_cd,30);
           l_status := 'APPROVE';
        end if;
	result := 'COMPLETE:' || l_status;
        hr_utility.set_location(l_proc || ' l_status '||l_status,30);
        hr_utility.set_location(l_proc || ' Exiting ',100);
	return;
    ELSE
        hr_utility.set_location(l_proc || ' Exiting',100);
    END IF;
exception when others then
result := null;
raise;
  END;
--
-- Procedure to be called from workflow
--

  PROCEDURE FIND_NEXT_USER  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_status   varchar2(30);
      l_user     varchar2(30);
      l_proc     VARCHAR2(61)  := g_package  || 'find_next_user';
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
	IF (FUNCMODE  = 'RUN') THEN
           create_process_log('Find Next User ' || itemkey);
           l_status := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                 itemkey  => ItemKey,
                                                 aname    => 'NEXT_USER_STATUS');
           l_user := get_last_user(p_itemkey => itemkey);
           IF l_user IS NOT NULL THEN
              wf_engine.SetItemAttrText(itemtype => itemtype
                                      , itemkey  => ItemKey
                                      , aname    => 'ROUTED_BY_USER'
                                      , avalue   => l_user);
           END IF;
           l_status := NVL(l_status, 'ERROR');
	   result := 'COMPLETE:' || l_status;
           hr_utility.set_location(l_proc || ' l_user '  ||l_user,20);
           hr_utility.set_location(l_proc || ' l_status '||l_status,30);
           hr_utility.set_location(l_proc || ' Exiting ',100);
	return;
    ELSE
        hr_utility.set_location(l_proc || ' Exiting',100);
	END IF;
exception when others then
result := null;
raise;
  END;
  PROCEDURE notify_requestor  (
      itemtype        in     varchar2,
	  itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_user                       VARCHAR2(30);
      l_transaction_id             NUMBER;
      l_transaction_category_id    NUMBER;
      l_proc                       VARCHAR2(61)  := g_package  || 'notify_requestor';
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
	IF (FUNCMODE  = 'RUN') THEN
        l_user   := get_requestor(itemkey);

        set_next_user (
          p_itemtype        => itemtype
        , p_itemkey         => itemkey
        , p_route_to_user   => l_user
        , p_status          => 'FOUND'
        );
		result := 'COMPLETE:FOUND';
        hr_utility.set_location(l_proc || ' Exiting',100);
		return;
    ELSE
      hr_utility.set_location(l_proc || ' Exiting',100);
	END IF;
	exception when others then
	result := null;
	raise;
  END;

  PROCEDURE APPROVE_TXN (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    )
  IS
      l_effective_date                    DATE;
      l_proc                              VARCHAR2(61)  := g_package  || 'approve_txn';
      l_future_action_cd                  pqh_transaction_categories.future_action_cd%TYPE;
      l_post_style_cd                     pqh_transaction_categories.post_style_cd%TYPE;
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
	IF (FUNCMODE  = 'RUN') THEN
      l_future_action_cd := wf_engine.GetItemAttrText(
                                                itemtype => itemtype,
                                                itemkey  => ItemKey,
                                                aname    => 'FUTURE_ACTION_CD');
      l_post_style_cd := wf_engine.GetItemAttrText(
                                                itemtype => itemtype,
                                                itemkey  => ItemKey,
                                                aname    => 'POST_STYLE_CD');
      l_effective_date := wf_engine.GetItemAttrDate(
                                                itemtype => itemtype,
                                                itemkey  => ItemKey,
                                                aname    => 'EFFECTIVE_DATE');
      create_process_log('APPROVE_TXN : l_effective_date = ' || TO_CHAR(l_effective_date) || ' - ');
      IF l_effective_date > TRUNC(SYSDATE) THEN  -- Future Actions
          IF NVL(l_future_action_cd, 'D') = 'D' THEN
              result := 'COMPLETE:FUTURE';
          ELSE
              result := 'COMPLETE:CURRENT';
          END IF;
      ELSIF l_effective_date < TRUNC(SYSDATE) THEN
         result := 'COMPLETE:RETROACTIVE';
      ELSE
           result := 'COMPLETE:CURRENT';
      END IF;
    END IF;
    hr_utility.set_location(l_proc || ' Exiting',100);
exception when others then
result := null;
raise;
  END;
  PROCEDURE POST_TXN (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    )
  IS
      l_proc                    VARCHAR2(61)  := g_package  || 'post_txn';
      l_dbupdate                VARCHAR2(30) := 'FAILURE';
      l_post_txn_function       VARCHAR2(2000);
      l_transaction_category_id NUMBER;
      l_transaction_id          NUMBER;
      post_txn_not_defined EXCEPTION;
      pragma exception_init (post_txn_not_defined, -6550);
      l_apply_error_mesg   VARCHAR2(200) := 'No Error';
      l_apply_error_num    VARCHAR2(30)  := '0' ;
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
	IF (FUNCMODE  = 'RUN') THEN
            set_apply_error(p_itemkey          => itemkey,
 		            p_workflow_name    => itemtype,
		            p_apply_error_mesg => l_apply_error_mesg,
		            p_apply_error_num  => l_apply_error_num );
      hr_utility.set_location(l_proc || ' After error setting ', 33);
      create_process_log('POST_TXN : itemkey = ' || itemkey);
      l_post_txn_function := wf_engine.GetItemAttrText(
                                                itemtype => itemtype,
                                                itemkey  => ItemKey,
                                                aname    => 'POST_TXN_FUNCTION');
      decode_itemkey(p_itemkey                 => itemkey
                   , p_transaction_category_id => l_transaction_category_id
                   , p_transaction_id          => l_transaction_id
                   );
-- l_status is a variable which will be replaced by dbupdate and there is no need to define
-- this variable

      l_post_txn_function := 'begin :l_status := ' || l_post_txn_function ||
                             '.apply_transaction(p_transaction_id =>'||
                             to_char(l_transaction_id) ||
			     ',p_validate_only =>''NO'' ); end;';
      hr_utility.set_location(l_proc ||substr(l_post_txn_function,1,40) , 22);
      hr_utility.set_location(l_proc ||substr(l_post_txn_function,41,40) , 22);
      hr_utility.set_location(l_proc ||substr(l_post_txn_function,81) , 22);
      savepoint before_apply_txn ;
      DECLARE
          l_sqlerrm   VARCHAR2(2000);
          l_sqlcode   NUMBER;
      BEGIN
          EXECUTE IMMEDIATE l_post_txn_function USING OUT l_dbupdate;
      EXCEPTION
      when post_txn_not_defined then
          hr_utility.set_location(l_proc || 'post_func not defined ' , 28);
          raise;
      WHEN OTHERS THEN
          l_sqlcode := sqlcode;
          l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
          hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
          hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 30);
          rollback to before_apply_txn ;
          set_apply_error(p_itemkey          => itemkey,
 		          p_workflow_name    => itemtype,
		          p_apply_error_mesg => l_sqlerrm,
		          p_apply_error_num  => l_sqlcode );
          hr_utility.set_location(l_proc || ' After error setting ', 33);
      END;
      IF l_dbupdate = 'SUCCESS' THEN
          wf_engine.SetItemAttrText(
               itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'TRANSACTION_STATUS',
               avalue   => 'DBSUCCESS');
          result := 'COMPLETE:SUCCESS';
      ELSIF l_dbupdate = 'FAILURE' THEN
          wf_engine.SetItemAttrText(
               itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'TRANSACTION_STATUS',
               avalue   => 'DBERROR');
          result := 'COMPLETE:ERROR';
      ELSE
          wf_engine.SetItemAttrText(
               itemtype => itemtype,
               itemkey  => itemkey,
               aname    => 'TRANSACTION_STATUS',
               avalue   => 'DBWARNING');
          result := 'COMPLETE:WARNING';
      END IF;
    END IF;
    hr_utility.set_location(l_proc || ' Exiting',100);
    exception when others then
    result := null;
    raise;
  END;

  PROCEDURE CHK_EFFECTIVE_DATE (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    )
  IS
      l_proc            VARCHAR2(61)  := g_package  || 'chk_effective_date';
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
	IF (FUNCMODE  = 'RUN') THEN
      create_process_log('CHK_EFFECTIVE_DATE : itemkey = ' || itemkey);
      result := 'COMPLETE:FUTURE';
    END IF;
    hr_utility.set_location(l_proc || ' Exiting',100);
    exception when others then
    result := null;
    raise;
  END;
  PROCEDURE PROCESS_NOTIFICATION  (
      itemtype        in     varchar2,
	  itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_proc                  VARCHAR2(61)  := g_package  || 'process_notification';
      l_form_name             VARCHAR2(100);
      l_routing_history_id    NUMBER;
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || 'Parameter - Funcmode = ' || funcmode,20);
    create_process_log('In ' || l_proc || ' ' || funcmode);
    l_form_name := wf_engine.GetItemAttrText(itemtype => itemtype,
                                             itemkey  => ItemKey,
                                             aname    => 'FORM_NAME');
    create_process_log('In ' || l_proc || ' Form Name ' || l_form_name);
    IF funcmode IN ('FORWARD', 'TRANSFER') THEN
       result := 'ERROR:USE_RESPOND_BUTTON';
    ELSIF funcmode = 'TIMEOUT' THEN
       l_routing_history_id := get_last_rh_id(p_itemkey => itemkey);
       IF l_routing_history_id IS NOT NULL THEN
           update_routing_history(p_routing_history_id => l_routing_history_id
                                , p_user_action_cd     => 'TIMEOUT');
       END IF;
       wf_engine.SetItemAttrText(itemtype => itemtype
                               , itemkey  => itemkey
                               , aname    => 'TRANSACTION_STATUS'
                               , avalue   => 'TIMEOUT');
      /* Code added for bug 7193557 */
      wf_engine.SetItemAttrText(itemtype => itemtype
                             , itemkey  => itemKey
                             , aname    => 'ROUTED_BY_USER'
                             , avalue   => FND_GLOBAL.user_name );
      /* Code added for bug 7193557 */
       result := 'COMPLETE:TIMEOUT';
    END IF;
    hr_utility.set_location(l_proc || ' Exiting',100);
    return;
    exception when others then
    result := null;
    raise;
  END;
  --
  -- Process response
  --
  PROCEDURE PROCESS_RESPONSE  (
      itemtype        in     varchar2,
      itemkey         in     varchar2,
      actid           in     number,
      funcmode        in     varchar2,
      result             out nocopy varchar2 )
  is
      l_proc                     VARCHAR2(61)  := g_package  || 'process_response';
      l_transaction_category_id  NUMBER;
      l_transaction_id           NUMBER;
      l_response                 VARCHAR2(30);
      l_user                     fnd_user.user_name%TYPE;
      l_user_action_cd           VARCHAR2(30);
      l_requestor                VARCHAR2(30);
      l_current_user             VARCHAR2(30);
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode' || funcmode, 20);
    IF (FUNCMODE  = 'RUN') THEN
      l_user_action_cd := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey  => ItemKey,
                                                    aname    => 'TRANSACTION_STATUS');
      hr_utility.set_location(l_proc || ' User Action '|| l_user_action_cd, 20);
      IF l_user_action_cd in ('FYI_NOT','PQH_BPR') THEN
          result := 'COMPLETE:'||l_user_action_cd;
          hr_utility.set_location(l_proc || ' Exiting',100);
          RETURN;
      END IF;
      decode_itemkey(p_transaction_category_id => l_transaction_category_id
                   , p_transaction_id          => l_transaction_id
                   , p_itemkey                 => itemkey);
      IF l_user_action_cd = 'DBFAILURE' THEN
         l_user_action_cd := 'FORWARD';
      END IF;
      if l_user_action_cd = 'TIMEOUT' then
         l_user := get_requestor(p_itemkey => itemkey);
         if l_user is not null then
            set_next_user (
                p_itemtype        => itemtype
              , p_itemkey         => itemkey
              , p_route_to_user   => l_user
              , p_status          => 'FOUND'
            );
         end if;
      elsif l_user_action_cd NOT IN ('REJECT','FRC_RJCT', 'APPLY','TIMEOUT') THEN
          l_user := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => ItemKey,
                                              aname    => 'ROUTE_TO_USER');
          set_next_user (
             p_itemtype        => itemtype
           , p_itemkey         => itemkey
           , p_route_to_user   => l_user
           , p_status          => 'FOUND'
         );
      END IF;
      result := 'COMPLETE:' || l_user_action_cd;
      hr_utility.set_location(l_proc || ' Exiting',100);
    END IF;
exception when others then
result := null;
raise;
  END;
  PROCEDURE CHK_FYI_RESULTS (
      itemtype                       in varchar2
    , itemkey                        in varchar2
    , actid                          in number
    , funcmode                       in varchar2
    , result                     out nocopy    varchar2
    )
  IS
      l_proc            VARCHAR2(61)  := g_package  || 'chk_fyi_results';
      l_user_action_cd  VARCHAR2(30);
  BEGIN
    hr_utility.set_location(l_proc || ' Entering',10);
    hr_utility.set_location(l_proc || ' FuncMode ' || funcmode, 20);
    IF (FUNCMODE  = 'RUN') THEN
        l_user_action_cd := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey  => ItemKey,
                                                    aname    => 'TRANSACTION_STATUS');
        result := 'COMPLETE:'||l_user_action_cd;
    END IF;
    hr_utility.set_location(l_proc || result, 50);
    hr_utility.set_location(l_proc || ' Exiting',100);
exception when others then
result := null;
raise;
  END;

-- This function was added to cater to the requirement of worksheet that a delegated worksheet
-- which is already approved can be started again
-- in other cases this function won't be there and is trapped in the exception handler.
  PROCEDURE chk_root_node (itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          result       out nocopy varchar2) is
       l_transaction_category_id number;
       l_transaction_id number;
       l_post_txn_function varchar2(4000);
       chk_root_not_defined EXCEPTION;
       pragma exception_init (chk_root_not_defined, -6550);
       l_proc            VARCHAR2(61)  := g_package  || 'chk_root_node';
       chk_root_not_defined1 EXCEPTION;
       pragma exception_init (chk_root_not_defined1, -900);
  BEGIN
      hr_utility.set_location(l_proc || ' Entering',10);
      if (funcmode='RUN') then
         l_post_txn_function := wf_engine.GetItemAttrText(
                                                   itemtype => itemtype,
                                                   itemkey  => ItemKey,
                                                   aname    => 'POST_TXN_FUNCTION');
         hr_utility.set_location(l_proc ||substr(l_post_txn_function,1,30),15);
         decode_itemkey(p_itemkey                 => itemkey
                      , p_transaction_category_id => l_transaction_category_id
                      , p_transaction_id          => l_transaction_id
                      );
         l_post_txn_function := 'begin :l_status := ' || l_post_txn_function ||
                                '.chk_root_node(p_transaction_id =>'||
                                to_char(l_transaction_id) || '); end;';

         hr_utility.set_location(l_proc ||substr(l_post_txn_function,1,30),15);
         DECLARE
             l_sqlerrm   VARCHAR2(2000);
             l_sqlcode   NUMBER;
             l_dbupdate  varchar2(2000);
         BEGIN
             EXECUTE IMMEDIATE l_post_txn_function USING OUT l_dbupdate;
             result := 'COMPLETE:'||l_dbupdate;
         EXCEPTION
         WHEN chk_root_not_defined1 THEN
             result := 'COMPLETE:ROOT';
         WHEN chk_root_not_defined THEN
             result := 'COMPLETE:ROOT';
         WHEN OTHERS THEN
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 31);
      END;
   end if;
exception when others then
result := null;
raise;
  END;

-- instead of this function, we use pqh_workflow.valid_user_opening procedure
-- which in turn builds the default role

  FUNCTION get_default_role (
    p_transaction_category_id   NUMBER
  , p_user_id                in NUMBER default FND_PROFILE.VALUE('USER_ID')
  )
  RETURN NUMBER
  IS

     l_role_id                 number(15);
     l_member_cd               pqh_transaction_categories.member_cd%type;
     l_position_id             number;
     l_assignment_id           number;
     l_workflow_enable_flag    pqh_transaction_categories.workflow_enable_flag%type;

     cursor c_get_txn_cat (p_transaction_category_id NUMBER) IS
       SELECT member_cd, workflow_enable_flag
       FROM   pqh_transaction_categories tct
       WHERE  transaction_category_id = p_transaction_category_id;

     cursor c_get_user_role (p_user_id NUMBER) is
       SELECT role_id
         FROM pqh_role_users_v
        WHERE user_id = p_user_id
          AND nvl(default_role,'X') = 'Y';

     cursor c_get_assignment (p_user_id NUMBER) IS
         SELECT asg.assignment_id,asg.position_id
         FROM per_all_assignments asg
            , fnd_user fu
         WHERE asg.person_id = fu.employee_id
           AND fu.user_id = p_user_id
           AND asg.primary_flag = 'Y'
	   AND asg.assignment_type = 'E';         --  added for bug 7708168

     cursor c_get_pos_role(p_assignment_id number) is
         SELECT rls.role_id
         FROM per_all_assignments asg
            , pqh_position_roles_v rls
         WHERE asg.position_id = rls.position_id;

  BEGIN
     hr_utility.set_location(' User ID '||p_user_id,9999);
     OPEN c_get_txn_cat(p_transaction_category_id => p_transaction_category_id);
     FETCH c_get_txn_cat INTO l_member_cd, l_workflow_enable_flag;
     CLOSE c_get_txn_cat;
      hr_utility.set_location('l_member_cd '||l_member_cd,9999);
     IF NVL(l_workflow_enable_flag, 'N') = 'Y' THEN
         IF l_member_cd = 'R'  THEN
           -- use the view pqh_role_users_v for selecting the default role of the user
             OPEN c_get_user_role(p_user_id => p_user_id);
             FETCH c_get_user_role INTO l_role_id;
             CLOSE c_get_user_role;
	     hr_utility.set_location('l_role_id '||l_role_id,9997);
        ELSIF l_member_cd in ('P','S') then
             OPEN c_get_assignment(p_user_id => p_user_id);
             FETCH c_get_assignment INTO l_assignment_id,l_position_id;
             CLOSE c_get_assignment;
	     hr_utility.set_location('l_assignment_id '||l_assignment_id,9998);
	     hr_utility.set_location('l_position_id '||l_position_id,9998);
             if l_position_id is not null then
                OPEN c_get_pos_role(p_assignment_id => l_assignment_id);
                FETCH c_get_pos_role INTO l_role_id;
                CLOSE c_get_pos_role;
		hr_utility.set_location('l_role_id '||l_role_id,9998);
             else
                OPEN c_get_user_role(p_user_id => p_user_id);
                FETCH c_get_user_role INTO l_role_id;
                CLOSE c_get_user_role;
		hr_utility.set_location('l_role_id '||l_role_id,9999);
             end if;
        END IF;
        IF l_role_id IS NULL THEN
            hr_utility.set_message(8302,'PQH_USER_HAS_NO_ROLE');
            hr_utility.raise_error;
        END IF;
    ELSE
        l_role_id := -1;
    END IF;
    hr_utility.set_location('Just before return, role_id '||l_role_id,10000);
    RETURN l_role_id;
  END;
procedure complete_delegate_workflow(
     p_itemkey                        in varchar2,
     p_workflow_name                  in varchar2 ) is
begin
     wf_engine.CompleteActivity(
                   p_workflow_name
                 , p_itemkey
                 , 'DELEGATE_BLOCK'
                 , 'COMPLETE');
end;
  procedure get_apply_error(p_transaction_id          in number,
			    p_transaction_category_id in number,
			    p_apply_error_mesg        out nocopy varchar2,
			    p_apply_error_num         out nocopy varchar2) is
     l_proc              varchar2(61) := g_package ||'get_apply_error' ;
     l_workflow_name     varchar2(30);
     l_itemkey           varchar2(30);
  begin
     hr_utility.set_location(l_proc || ' Entering',10);
     l_workflow_name := get_workflow_name(p_transaction_category_id => p_transaction_category_id);
     hr_utility.set_location(l_proc || 'workflow name is'||l_workflow_name,20);
     l_itemkey := to_char(p_transaction_category_id)  || '-' || to_char(p_transaction_id) ;
     hr_utility.set_location(l_proc || 'itemkey'||l_itemkey,25);
     get_apply_error(p_itemkey          => l_itemkey,
		     p_workflow_name    => l_workflow_name,
		     p_apply_error_mesg => p_apply_error_mesg,
		     p_apply_error_num  => p_apply_error_num );
     hr_utility.set_location(l_proc || 'apply_code'||p_apply_error_num,30);
     hr_utility.set_location(l_proc || 'apply_mesg'||substr(p_apply_error_mesg,1,20),40);
     hr_utility.set_location(l_proc || ' Exiting',100);
  end;

  PROCEDURE set_apply_error(p_transaction_id          IN NUMBER,
			    p_transaction_category_id IN NUMBER,
			    p_apply_error_mesg        IN  VARCHAR2,
			    p_apply_error_num         IN  VARCHAR2)
  IS
     l_proc              varchar2(61) := g_package ||'set_apply_error' ;
     l_workflow_name     varchar2(30);
     l_itemkey           varchar2(30);
  BEGIN
     hr_utility.set_location(l_proc || 'Entering',10);
     hr_utility.set_location(l_proc || 'txn_cat is' ||p_transaction_category_id,15);
     hr_utility.set_location(l_proc || 'txn_id is' ||p_transaction_id,16);

     IF     p_transaction_category_id IS NULL
        OR  p_transaction_id IS NULL THEN
          hr_utility.set_message(8302,'PQH_NULL_TRANSACTION_ID_OR_CAT');
          hr_utility.raise_error;
     END IF;

     l_workflow_name := get_workflow_name(p_transaction_category_id => p_transaction_category_id);
     hr_utility.set_location(l_proc || 'workflow name is' ||l_workflow_name,20);
     l_itemkey := to_char(p_transaction_category_id) || '-' || to_char(p_transaction_id) ;

     hr_utility.set_location(l_proc || 'txn_cat is' ||p_transaction_category_id,15);
     hr_utility.set_location(l_proc || 'itemkey' ||l_itemkey,25);

     set_apply_error(p_itemkey          => l_itemkey,
		     p_workflow_name    => l_workflow_name,
		     p_apply_error_mesg => p_apply_error_mesg,
		     p_apply_error_num  => p_apply_error_num );
     hr_utility.set_location(l_proc || ' Exiting',100);
  END;

  PROCEDURE set_status      ( p_workflow_name   IN     VARCHAR2,
                              p_item_id         IN     VARCHAR2,
                              p_status          IN     VARCHAR2,
                              p_result          OUT NOCOPY    VARCHAR2)
  IS
     l_proc            VARCHAR2(61)  := g_package  || 'set_status';
     set_status_not_defined EXCEPTION;
     pragma exception_init (set_status_not_defined, -6550);
     l_tran_cat_id number;
     l_transaction_id number;
     l_tran_cat_name varchar2(30);
     l_post_txn_function varchar2(61);
     l_hyphen_pos number;
     l_set_status       varchar2(200);
     cursor c1 is select post_txn_function,short_name
                  from pqh_transaction_categories
                  where transaction_category_id = l_tran_cat_id ;
  BEGIN
     hr_utility.set_location(l_proc || ' Entering',10);
     hr_utility.set_location(l_proc || ' workflow ' || p_workflow_name, 10);
     hr_utility.set_location(l_proc || ' item id ' || p_item_id,10);
     l_hyphen_pos     := INSTR(p_item_id, '-');
     l_tran_cat_id    := TO_NUMBER(SUBSTR(p_item_id, 1, l_hyphen_pos - 1));
     l_transaction_id := TO_NUMBER(SUBSTR(p_item_id, l_hyphen_pos + 1));
     hr_utility.set_location(l_proc || 'transaction id ' || l_transaction_id,20);
     hr_utility.set_location(l_proc || 'tran_cat_id  ' || l_tran_cat_id,20);
     open c1;
     fetch c1 into l_post_txn_function,l_tran_cat_name;
     close c1;
     hr_utility.set_location(l_proc || 'post funtion string  ' || l_post_txn_function,20);
     l_set_status       := 'begin :l_status := ' || l_post_txn_function ||
                           '.set_status( p_transaction_category_id  => ' || to_char(l_tran_cat_id) ||
                                       ',p_transaction_id           =>'|| to_char(l_transaction_id) ||
                                       ',p_status                   =>'''||p_status ||
                            '''); end; ';

     hr_utility.set_location(l_proc || 'dyn string  ' || substr(l_set_status, 1, 40),20);
     hr_utility.set_location(l_proc || 'dyn string  ' || substr(l_set_status, 41, 40),20);
     hr_utility.set_location(l_proc || 'dyn string  ' || substr(l_set_status, 81, 40),20);
     hr_utility.set_location(l_proc || 'dyn string  ' || substr(l_set_status, 121),20);
     DECLARE
        l_sqlerrm   VARCHAR2(2000);
        l_sqlcode   NUMBER;
     BEGIN
        EXECUTE IMMEDIATE l_set_status       USING OUT p_result;
     EXCEPTION
        WHEN set_status_not_defined THEN
             p_result := 'UNDEF';
             raise;
        WHEN OTHERS THEN
             l_sqlcode := sqlcode;
             l_sqlerrm := substr(sqlerrm(l_sqlcode), 1, 100);
             p_result  := l_sqlcode;
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,1,30), 30);
             hr_utility.set_location(l_proc || ' ' || substr(l_sqlerrm,31,30), 32);
             raise;
     END;
--     document := document || l_fyi_notification ;
     hr_utility.set_location(l_proc || 'Exiting',100);
exception when others then
p_result := null;
raise;
  end;
function get_current_owner(p_itemkey in varchar2) return varchar2 is
   l_user_name varchar2(100);
begin
   l_user_name := get_notification_detail(p_itemkey => p_itemkey,
                                          p_mode    => 'USER');
   return l_user_name;
end;
function get_current_owner(p_transaction_id          in number,
                           p_transaction_category_id in number,
                           p_status                  in varchar2) return varchar2 is
   l_itemkey varchar2(100);
   l_current_owner varchar2(100);
begin
   if nvl(p_status,'PENDING') not in ('APPLIED','TERMINATE','SUBMITTED','REJECT') then
      l_itemkey := p_transaction_category_id||'-'||p_transaction_id;
      l_current_owner := get_current_owner(p_itemkey => l_itemkey);
   else
      l_current_owner := '';
   end if;
   return l_current_owner;
end;
function get_current_owner(p_transaction_id in number,
                           p_transaction_category_id in number) return varchar2 is
   l_itemkey varchar2(100);
   l_current_owner varchar2(100);
begin
   l_itemkey := p_transaction_category_id||'-'||p_transaction_id;
   l_current_owner := get_current_owner(p_itemkey => l_itemkey);
   return l_current_owner;
end;
function get_person_name(p_user_id       in number default null,
                         p_assignment_id in number default null) return varchar2 is
   cursor c1 is select full_name
                from per_all_people_f per, fnd_user usr
                where per.person_id = usr.employee_id
                and usr.user_id = p_user_id;
   cursor c2 is select full_name
                from per_all_assignments_f asg, per_all_people_f per
                where asg.person_id = per.person_id
                and sysdate between asg.effective_start_date and asg.effective_end_date
                and sysdate between per.effective_start_date and per.effective_end_date
                and asg.assignment_id = p_assignment_id ;
   l_full_name varchar2(240);
begin
   if p_user_id is not null then
/* pick the first record of the person and show the name */
      open c1;
      fetch c1 into l_full_name;
      close c1;
   elsif p_assignment_id is not null then
      open c2;
      fetch c2 into l_full_name;
      close c2;
   end if;
   return l_full_name;
end;
END;

/
