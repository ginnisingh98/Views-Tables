--------------------------------------------------------
--  DDL for Package Body AP_WEB_CC_VALIDATION_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CC_VALIDATION_WF_PKG" as
/* $Header: apwfvalb.pls 120.4.12010000.3 2009/12/23 06:42:55 meesubra ship $ */

--
-- Raises the Workflow business event
--   oracle.apps.ap.oie.creditcard.transaction.error
function raise_validation_event(p_request_id in number default null,
                                p_card_program_id in number default null,
                                p_start_date in date default null,
                                p_end_date in date default null)
return number is
  l_parameter_list wf_parameter_list_t;
  l_event_key number;
  i number := 0;
  --Bug 6160290: Add cursor to handle scenario when p_card_program_id is null
  cursor fetch_card_program_id is
    SELECT distinct card_program_id FROM ap_credit_card_trxns_all
    WHERE  (p_start_date IS NULL OR transaction_date IS NULL OR transaction_date >= p_start_date)
    AND (p_end_date IS NULL OR transaction_date IS NULL OR transaction_date <= p_end_date)
    AND validate_code <> 'Y';

begin
 if (p_card_program_id is not null) then
  l_parameter_list := wf_parameter_list_t(
            wf_parameter_t('REQUEST_ID', to_char(p_request_id)),
            wf_parameter_t('CARD_PROGRAM_ID', to_char(p_card_program_id)),
            wf_parameter_t('START_DATE', to_char(p_start_date, 'YYYY/MM/DD')),
            wf_parameter_t('END_DATE', to_char(p_end_date, 'YYYY/MM/DD'))
                                        );

--  select ap_oie_workflow_s.nextval into l_event_key
  select ap_ccard_notification_id_s.nextval into l_event_key
  from dual;
  wf_event.raise(p_event_name => 'oracle.apps.ap.oie.creditcard.transaction.error',
                 p_event_key => to_char(l_event_key),
                 p_parameters => l_parameter_list);

  if ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  fnd_log.string(fnd_log.level_event,
                 'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.raise_validation_event',
                 'Raised validation event with key = '||to_char(l_event_key));
  end if;

 else

   for l_fetch_card_program_id  in fetch_card_program_id loop
     l_parameter_list := wf_parameter_list_t(
     wf_parameter_t('REQUEST_ID', to_char(p_request_id)),
     wf_parameter_t('CARD_PROGRAM_ID', to_char(l_fetch_card_program_id.card_program_id)),
     wf_parameter_t('START_DATE', to_char(p_start_date, 'YYYY/MM/DD')),
     wf_parameter_t('END_DATE', to_char(p_end_date, 'YYYY/MM/DD')));

     select ap_ccard_notification_id_s.nextval into l_event_key from dual;

     wf_event.raise(p_event_name => 'oracle.apps.ap.oie.creditcard.transaction.error',
                    p_event_key => to_char(l_event_key),
                    p_parameters => l_parameter_list);

     if ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        fnd_log.string(fnd_log.level_event,
                 'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.raise_validation_event',
                 'Raised validation event with key = '||to_char(l_event_key));
     end if;
   end loop;

 end if;
 return l_event_key;

end raise_validation_event;

/*
--
-- Counts the number of invalid credit card transactions
-- for the give Request ID, Card Program ID, and start/end dates
procedure count_invalid(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_card_program_id number;
  l_start_date date;
  l_end_date date;
  l_validate_code varchar2(30);
  l_total_count number;
  l_count number;

  stmt varchar2(2000);

  type gen_cursor is ref cursor;
  c gen_cursor;
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',true);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID',true);
    l_start_date := wf_engine.getitemattrdate(itemtype,itemkey,'START_DATE',true);
    l_end_date := wf_engine.getitemattrdate(itemtype,itemkey,'END_DATE',true);

    stmt := 'select validate_code, count(*) '||
            'from ap_credit_card_trxns_all '||
            'where validate_code not in (''Y'', ''N'', ''UNTESTED'') ';
    if l_request_id is null then
      stmt := stmt || 'and :reqId is null ';
    else
      stmt := stmt || 'and request_id = :reqId ';
    end if;
    if l_card_program_id is null then
      stmt := stmt || 'and :cardProgramId is null ';
    else
      stmt := stmt || 'and card_program_id = :card_program_id ';
    end if;
    if l_start_date is null then
      stmt := stmt || 'and :startDate is null ';
    else
      stmt := stmt || 'and transaction_date >= :startDate ';
    end if;
    if l_end_date is null then
      stmt := stmt || 'and :endDate is null ';
    else
      stmt := stmt || 'and transaction_date >= :endDate ';
    end if;
    stmt := stmt || 'group by validate_code ';

    begin
      l_total_count := 0;
      open c for stmt using l_request_id, l_card_program_id, l_start_date, l_end_date;
      loop
        fetch c into l_validate_code, l_count;
        exit when c%notfound;

        wf_engine.setitemattrnumber(itemtype,itemkey,l_validate_code,l_count);
        l_total_count := l_total_count + l_count;
      end loop;
      close c;

      wf_engine.setitemattrnumber(itemtype,itemkey,'INVALID_ALL',l_total_count);
    exception
      when others then
        if c%isopen then
          close c;
        end if;
        raise;
    end;


    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.count_invalid',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'COUNT_INVALID',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end count_invalid;
*/

--
-- Returns the URL for the Credit Card Transactions page
--
--
procedure get_search_page_url(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2) is

  l_request_id number;
  l_card_program_id number;
  l_start_date date;
  l_end_date date;

  url varchar2(2000);
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',true);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID',true);
    l_start_date := wf_engine.getitemattrdate(itemtype,itemkey,'START_DATE',true);
    l_end_date := wf_engine.getitemattrdate(itemtype,itemkey,'END_DATE',true);

    url := 'JSP:/OA_HTML/OA.jsp?OAFunc=OIE_CCTRX_SEARCH_FN'||
                '&'||'restrict=Y'||
                '&'||'pRequestId='||to_char(l_request_id)||
                '&'||'pCardProgramId='||to_char(l_card_program_id)||
                '&'||'pStartDate='||to_char(l_start_date, 'YYYY/MM/DD')||
                '&'||'pEndDate='||to_char(l_end_date, 'YYYY/MM/DD')||
                '&'||'pValidateCode=INVALID_ALL'||
                '&'||'NtfId=-&#NID-';

    wf_engine.setitemattrtext(itemtype,itemkey,'SEARCH_PAGE_URL',url);

    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.get_search_page_url',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_SEARCH_PAGE_URL',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_search_page_url;

--
-- Raises the Workflow business event
--   oracle.apps.ap.oie.creditcard.account.create
function raise_new_cc_event(p_request_id in number default null,
                            p_card_program_id in number default null,
                            p_start_date in date default null,
                            p_end_date in date default null)
return number is
  l_parameter_list wf_parameter_list_t;
  l_event_key number;
  i number := 0;
begin
  l_parameter_list := wf_parameter_list_t(
            wf_parameter_t('REQUEST_ID', to_char(p_request_id)),
            wf_parameter_t('CARD_PROGRAM_ID', to_char(p_card_program_id)),
            wf_parameter_t('START_DATE', to_char(p_start_date, 'YYYY/MM/DD')),
            wf_parameter_t('END_DATE', to_char(p_end_date, 'YYYY/MM/DD'))
                                        );

  select ap_ccard_notification_id_s.nextval into l_event_key
  from dual;

  wf_event.raise(p_event_name => 'oracle.apps.ap.oie.creditcard.account.create',
                 p_event_key => to_char(l_event_key),
                 p_parameters => l_parameter_list);
  if ( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  fnd_log.string(fnd_log.level_event,
                 'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.raise_new_cc_event',
                 'Raised new card event with key = '||to_char(l_event_key));
  end if;


  return l_event_key;
end raise_new_cc_event;


--
-- Find employee matches
procedure card_employee_match(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_card_program_id number;
  l_match_rule varchar2(30);
  l_stmt varchar2(200);

  cursor ccard is
    select det.card_id, card.card_program_id -- , det.name, det.employee_number, det.national_identifier
    from ap_card_details det, ap_cards_all card
    where det.card_id = card.card_id
    and card.request_id = l_request_id;
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID', true);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID', true);

    for crec in ccard LOOP
      select card_emp_matching_rule into l_match_rule
      from ap_card_programs_all
      where card_program_id = crec.card_program_id;

      if l_match_rule is not null then
        l_stmt := 'begin '||
                  l_match_rule||'.get_employee_matches(:cardId); '||
                'end;';
        execute immediate l_stmt using crec.card_id;
      end if;
    end loop;


    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.CARD_EMPLOYEE_MATCH',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'CARD_EMPLOYEE_MATCH',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end card_employee_match;


--
-- Assigns employees to credit cards if only one employee
-- candidate was found - thereby activating the credit card.
procedure assign_emp_if_unique(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_card_program_id number;

  cursor cemp is
    select c.card_id, max(emp.employee_id) as employee_id
    from ap_cards_all ca, ap_card_details c, ap_card_emp_candidates emp
    where c.card_id = emp.card_id
    and ca.card_id = c.card_id
    and ca.request_id = l_request_id
    group by c.card_id
    having count(*) = 1;

begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID', false);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID', true);

    for crec in cemp loop
       ap_web_cc_validations_pkg.assign_employee(crec.card_id, crec.employee_id);
    end loop;
    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.ASSIGN_EMP_IF_UNIQUE',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'ASSIGN_EMP_IF_UNIQUE',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end assign_emp_if_unique;

--
-- Checks to see if new credit cards were created by
-- a given request id
procedure new_cards_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_exist number;
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',false);
    select count(*) into l_exist from dual
    where exists (select 1 from ap_cards_all where request_id = l_request_id);

    if l_exist = 0 then
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';
    end if;
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.NEW_CARDS_EXIST',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'NEW_CARDS_EXIST',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end new_cards_exist;


--
-- Checks to see if inactive credit cards were created by
-- a given request id
procedure inactive_cards_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_exist number;
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',false);
    select count(*) into l_exist from dual
    where exists (select 1 from ap_cards_all where request_id = l_request_id and employee_id is null);

    if l_exist = 0 then
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';
    end if;
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.INACTIVE_CARDS_EXIST',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'INACTIVE_CARDS_EXIST',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end inactive_cards_exist;


--
-- Checks to see if invalid credit card trx were created by
-- a given request id
procedure invalid_cctrx_exist(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_card_program_id NUMBER;
  l_start_date DATE;
  l_end_date DATE;
  l_exist number;
  l_exist1 number;
  l_exist2 number;
begin
   WF_ENGINE.SetItemAttrText(itemtype,itemkey,'OIE_INVALID_TABLE','JSP:/OA_HTML/OA.jsp?akRegionCode=InvalidCCardRN'||'&'||'akRegionApplicationId=200'||'&'||'itemKey='||itemkey||'&'||'requestId=-&#HDR_REQUEST_ID-');  -- Bug 6829024(sodash)
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',false);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype, itemkey,'CARD_PROGRAM_ID',FALSE);
    l_start_date := wf_engine.getitemattrdate(itemtype, itemkey,'START_DATE',FALSE);
    l_end_date := wf_engine.getitemattrdate(itemtype, itemkey,'END_DATE',FALSE);
    select count(*) into l_exist1 from dual
    where exists (select 1 from ap_credit_card_trxns_all where request_id = l_request_id and validate_code <> 'Y');
    SELECT COUNT(*) INTO l_exist2 FROM dual
      WHERE exists (SELECT 1 FROM ap_credit_card_trxns_all
                    WHERE (l_card_program_id IS NULL OR card_program_id = l_card_program_id)   -- Bug 6829024(sodash)
                    AND (l_start_date IS NULL OR transaction_date IS NULL OR transaction_date >= l_start_date)
                    AND (l_end_date IS NULL OR transaction_date IS NULL OR transaction_date <= l_end_date)
                    AND validate_code <> 'Y'
                    );
    l_exist := l_exist1 + l_exist2;

    if l_exist = 0 then
      resultout := 'COMPLETE:F';
    else
      resultout := 'COMPLETE:T';
    end if;
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.INVALID_CCTRX_EXIST',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'INVALID_CCTRX_EXIST',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end invalid_cctrx_exist;

--
-- Counts the number of new credit cards that were created by
-- a given Request ID
procedure count_new_cards(itemtype in varchar2,
               itemkey in varchar2,
               actid in number,
               funcmode in varchar2,
               resultout out nocopy varchar2) is
  l_request_id number;
  l_count number;
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',false);
    select count(*) into l_count
    from ap_cards_all
    where request_id = l_request_id;

    wf_engine.setitemattrnumber(itemtype,itemkey,'NEW_CARD_COUNT',l_count);

    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.COUNT_NEW_CARDS',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'COUNT_NEW_CARDS',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end count_new_cards;


--
-- Returns the URL to the New Card Search page.
procedure get_new_card_page_url(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              funcmode in varchar2,
                              resultout out nocopy varchar2) is

  l_request_id number;
  l_card_program_id number;
  l_start_date date;
  l_end_date date;

  url varchar2(2000);
begin
  if ( funcmode = 'RUN' ) then
    l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',true);
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID',true);

    url := 'JSP:/OA_HTML/OA.jsp?OAFunc=OIE_NEW_CCARD_SEARCH_FN'||
                '&'||'restrict=Y'||
                '&'||'pRequestId='||to_char(l_request_id)||
                '&'||'pCardProgramId='||to_char(l_card_program_id)||
                '&'||'NtfId=-&#NID-';

    wf_engine.setitemattrtext(itemtype,itemkey,'NEW_CREDIT_CARD_URL',url);

    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.get_new_card_page_url',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_NEW_CARD_PAGE_URL',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_new_card_page_url;

--
-- Returns the name of the user who initiated the workflow.
-- If the workflow is initiated through by a concurrent program,
-- the current user would be the user who initiated the
-- concurrent program.
procedure whoami(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2) is
  attr_name varchar2(30);
  user_name varchar2(100);
  l_request_id number;  -- Bug 6971825
begin
  if ( funcmode = 'RUN' ) then

    begin
      l_request_id := wf_engine.getitemattrnumber(itemtype,itemkey,'REQUEST_ID',true); -- Bug 6971825

      select user_name into user_name
      from fnd_user
      where user_id in (select requested_by from FND_CONCURRENT_REQUESTS where
      request_id = nvl(l_request_id,fnd_global.user_id));

      attr_name := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'ATTRIBUTE_NAME', false);
      wf_engine.setitemattrtext(itemtype,itemkey,attr_name,user_name);
    exception
      when no_data_found then
        user_name := null;
    end;

    resultout := 'COMPLETE:';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.whoami',
                   sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'WHOAMI',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end whoami;

--
-- Returns the name of the system administrator role for
-- the card program.
procedure get_card_sysadmin(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2) is
  l_attr_name varchar2(30);
  l_card_program_id number;
  l_role_name varchar2(360);
  l_person_id number;
begin
  if ( funcmode = 'RUN' ) then
    l_card_program_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID',false);

    IF(l_card_program_id IS NOT NULL) THEN
       select sysadmin_role_name, admin_employee_id into l_role_name, l_person_id
       from ap_card_programs_all
       where card_program_id = l_card_program_id;
    ELSE
       l_role_name := NULL;
       l_person_id := NULL;
    END IF;

    if l_role_name is null and l_person_id is not null then
      begin
        select name into l_role_name
        from wf_roles
        where orig_system = 'PER'
          and orig_system_id = l_person_id;
      exception
        when no_data_found then
          l_role_name := null;
        when too_many_rows then
          l_role_name := null;
      end;
    end if;

    if l_role_name is null then
      whoami(itemtype, itemkey, actid, funcmode, resultout);
      return;
    else
      l_attr_name := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'ATTRIBUTE_NAME', false);
      wf_engine.setitemattrtext(itemtype,itemkey,l_attr_name,l_role_name);

      resultout := 'COMPLETE:';
      return;
    end if;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.GET_CARD_SYSADMIN', sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_CARD_SYSADMIN',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_card_sysadmin;



--
-- Returns the name of the card program
procedure get_card_program_name(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                              resultout out nocopy varchar2) is
  l_name varchar2(80);
  l_id number;
begin
  if ( funcmode = 'RUN' ) then
    l_id := wf_engine.getitemattrnumber(itemtype,itemkey,'CARD_PROGRAM_ID',false);
    -- Bug 6829024(sodash)
    if (l_id is null) then
              wf_engine.setitemattrtext(itemtype,itemkey,'CARD_PROGRAM_NAME',null);
              return;
    end if;

    select card_program_name into l_name
    from ap_card_programs_all
    where card_program_id = l_id;
    wf_engine.setitemattrtext(itemtype,itemkey,'CARD_PROGRAM_NAME',l_name);

    resultout := 'COMPLETE';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.GET_CARD_PROGRAM_NAME', sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_CARD_PROGRAM_NAME',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_card_program_name;

--
-- Returns the value of RETURN_ATTRIBUTE_NAME
procedure get_attribute_value(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2) is
  l_attrname VARCHAR2(100);
  l_attrval VARCHAR2(100);
begin
  if ( funcmode = 'RUN' ) then
    l_attrname := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'RETURN_ATTRIBUTE_NAME',false);
    l_attrval := wf_engine.getitemattrtext(itemtype,itemkey,l_attrname,false);
    resultout := 'COMPLETE:'||l_attrval;
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.GET_ATTRIBUUTE_VALUE', sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_ATTRIBUTE_VALUE',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_attribute_value;

--
-- Returns the activity value of RETURN_ATTRIBUTE_NAME
procedure get_act_attribute_value(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2) is
  l_attrname VARCHAR2(100);
  l_attrval VARCHAR2(100);
begin
  if ( funcmode = 'RUN' ) then
    l_attrval  := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'ATTRIBUTE_VALUE',FALSE);
    resultout := 'COMPLETE:'||l_attrval;
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.GET_ATTRIBUUTE_VALUE', sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_ATTRIBUTE_VALUE',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_act_attribute_value;

procedure get_instructions(itemtype in varchar2,
                 itemkey in varchar2,
                 actid in number,
                 funcmode in varchar2,
                 resultout out nocopy varchar2) is
  l_message_app VARCHAR2(30);
  l_message_name varchar2(30);
  l_message_text varchar2(240);
begin
  if ( funcmode = 'RUN' ) THEN
    l_message_app := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'MESSAGE_APP',false);
    l_message_name := wf_engine.getactivityattrtext(itemtype,itemkey,actid,'MESSAGE_NAME',false);
    fnd_message.set_name(l_message_app, l_message_name);
    l_message_text := fnd_message.get;
    wf_engine.setitemattrtext(itemtype,itemkey,'INSTRUCTIONS',l_message_text);
    resultout := 'COMPLETE';
    return;
  elsif ( funcmode in ('CANCEL', 'RESPOND', 'FORWARD', 'TRANSFER', 'TIMEOUT') ) then
    resultout := 'COMPLETE';
    return;
  else
    resultout := ' ';
    return;
  end if;
exception
  when others then
    if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
    fnd_log.string(fnd_log.level_unexpected,
                   'ap.pls.AP_WEB_CC_VALIDATION_WF_PKG.GET_INSTRUCTIONS', sqlerrm);
    end if;
    WF_CORE.CONTEXT ('AP_WEB_CC_VALIDATION_WF_PKG', 'GET_INSTRUCTIONS',
                     itemtype, itemkey, to_char(actid), funcmode);
    raise;
end get_instructions;




end ap_web_cc_validation_wf_pkg;

/
