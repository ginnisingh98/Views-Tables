--------------------------------------------------------
--  DDL for Package Body XTR_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_WORKFLOW_PKG" AS
/* $Header: xtrwfpkb.pls 120.2 2005/06/29 07:23:13 rjose ship $*/
-- This procedure creates an ad hoc Treasury role
FUNCTION CREATE_XTR_ROLES(p_role_users IN VARCHAR2,
                          p_expiration_date IN DATE) RETURN VARCHAR2
IS
   l_wf_sequence NUMBER;
   l_role_name VARCHAR2(60);
   l_role_display_name VARCHAR2(60);

BEGIN
   select XTR_ROLES_S.nextval
   into   l_wf_sequence
   from   dual;

   l_role_name := 'XTR'||to_char(l_wf_sequence);
   l_role_display_name := 'XTR'||to_char(l_wf_sequence);

   wf_directory.CreateAdHocRole(l_role_name,
                                l_role_display_name,
                                null, -- defaults to user setting language
                                null, -- defaults to user setting territory
                                null,
                                'QUERY',
                                p_role_users,
                                null, -- no email
                                null, -- no fax
                                'ACTIVE',
                                p_expiration_date);
   return l_role_name;
END CREATE_XTR_ROLES;

PROCEDURE START_WORKFLOW(p_process     IN VARCHAR2,
                         p_owner       IN VARCHAR2,
                         p_deal_no     IN NUMBER,
                         p_trans_no    IN NUMBER,
                         p_deal_type   IN VARCHAR2,
                         p_log_id      IN NUMBER,
                         p_varnum_1    IN NUMBER,
                         p_varnum_2    IN NUMBER,
                         p_varchar_1   IN VARCHAR2,
                         p_varchar_2   IN VARCHAR2,
                         p_vardate_1   IN DATE,
                         p_vardate_2   IN DATE)
IS
   l_role_name VARCHAR2(60);
   l_user_list VARCHAR2(3000);
   l_user_name  FND_USER.USER_NAME%type;

   -- Cursor used for IG
   cursor cur_notify_users_ig is
      select fu.USER_NAME, xwf.AMOUNT,xle.EXCEEDED_BY_AMOUNT
      from XTR_WF_USER_ROLES xwf,
	   XTR_INTERGROUP_TRANSFERS_V xds,
           XTR_LIMIT_EXCESS_LOG_V xle,
           FND_USER fu
      where xwf.ROLE_NAME = 'XTR_LIMITS_NOTIFICATION'
      and xds.DEAL_NUMBER = p_deal_no
      and xds.TRANSACTION_NUMBER = p_trans_no
      and xle.LOG_ID = p_log_id
      and fu.USER_ID = xwf.USER_ID
      and fu.start_date <= trunc(sysdate)
      and nvl(fu.end_date, sysdate+1) >= trunc(sysdate)
      and nvl(xwf.COMPANY, xds.COMPANY_CODE) = xds.COMPANY_CODE
      and nvl(xwf.PORTFOLIO, xds.PORTFOLIO) =  xds.PORTFOLIO
      and nvl(xwf.DEAL_TYPE, xds.DEAL_TYPE) = xds.DEAL_TYPE
      and nvl(xwf.PRODUCT_TYPE, xds.PRODUCT_TYPE) = xds.PRODUCT_TYPE
      and nvl(xwf.CPARTY, xds.PARTY_CODE) = xds.PARTY_CODE
      and nvl(xwf.LIMIT_CHECK_TYPE, xle.LIMIT_CHECK_TYPE) = xle.LIMIT_CHECK_TYPE
      order by fu.USER_NAME, xwf.PRIORITY,nvl(xle.EXCEEDED_BY_AMOUNT,0) desc;


   -- Cursor used for ONC
   cursor cur_notify_users_onc is
      select fu.USER_NAME, xwf.AMOUNT,xle.EXCEEDED_BY_AMOUNT
      from XTR_WF_USER_ROLES xwf,
	   XTR_ROLLOVER_TRANSACTIONS_V xds,
           XTR_LIMIT_EXCESS_LOG_V xle,
           FND_USER fu
      where xwf.ROLE_NAME = 'XTR_LIMITS_NOTIFICATION'
      and xds.DEAL_NUMBER = p_deal_no
      and xds.TRANSACTION_NUMBER = p_trans_no
      and xle.LOG_ID = p_log_id
      and fu.USER_ID = xwf.USER_ID
      and fu.start_date <= trunc(sysdate)
      and nvl(fu.end_date, sysdate+1) >= trunc(sysdate)
      and nvl(xwf.COMPANY, xds.COMPANY_CODE) = xds.COMPANY_CODE
      and nvl(xwf.PORTFOLIO, xds.PORTFOLIO_CODE) =  xds.PORTFOLIO_CODE
      and nvl(xwf.DEAL_TYPE, xds.DEAL_TYPE) = xds.DEAL_TYPE
      and nvl(xwf.DEAL_SUBTYPE, xds.DEAL_SUBTYPE) = xds.DEAL_SUBTYPE
      and nvl(xwf.PRODUCT_TYPE, xds.PRODUCT_TYPE) = xds.PRODUCT_TYPE
      and nvl(xwf.CPARTY, xds.CPARTY_CODE) = xds.CPARTY_CODE
      and nvl(xwf.DEALER, xds.DEALER_CODE) = xds.DEALER_CODE
      and nvl(xwf.LIMIT_CHECK_TYPE, xle.LIMIT_CHECK_TYPE) = xle.LIMIT_CHECK_TYPE
      order by fu.USER_NAME, xwf.PRIORITY,nvl(xle.EXCEEDED_BY_AMOUNT,0) desc;


   -- Cursor used for other deal types
   cursor cur_notify_users_deal is
      select fu.USER_NAME, xwf.AMOUNT,xle.EXCEEDED_BY_AMOUNT
      from XTR_WF_USER_ROLES xwf,
           XTR_DEALS_V xds,
           XTR_LIMIT_EXCESS_LOG_V xle,
           FND_USER fu
      where xwf.ROLE_NAME = 'XTR_LIMITS_NOTIFICATION'
      and xds.DEAL_NO = p_deal_no
      and nvl(xds.TRANSACTION_NO,0) = nvl(p_trans_no,0)
      and xle.LOG_ID = p_log_id
      and fu.USER_ID = xwf.USER_ID
      and fu.start_date <= trunc(sysdate)
      and nvl(fu.end_date, sysdate+1) >= trunc(sysdate)
      and nvl(xwf.COMPANY, xds.COMPANY_CODE) = xds.COMPANY_CODE
      and nvl(xwf.PORTFOLIO, xds.PORTFOLIO_CODE) =  xds.PORTFOLIO_CODE
      and nvl(xwf.DEAL_TYPE, xds.DEAL_TYPE) = xds.DEAL_TYPE
      and nvl(xwf.DEAL_SUBTYPE, xds.DEAL_SUBTYPE) = xds.DEAL_SUBTYPE
      and nvl(xwf.PRODUCT_TYPE, xds.PRODUCT_TYPE) = xds.PRODUCT_TYPE
      and nvl(xwf.CPARTY, xds.CPARTY_CODE) = xds.CPARTY_CODE
      and nvl(xwf.DEALER, xds.DEALER_CODE) = xds.DEALER_CODE
      and nvl(xwf.LIMIT_CHECK_TYPE, xle.LIMIT_CHECK_TYPE) = xle.LIMIT_CHECK_TYPE
      order by fu.USER_NAME, xwf.PRIORITY,nvl(xle.EXCEEDED_BY_AMOUNT,0) desc;

BEGIN
   l_user_list := ' ';
   l_role_name := ' ';
   l_user_name := ' ';

   -- begin user selection for IG deal type
   if (p_deal_type = 'IG') then
      for limit_user in cur_notify_users_ig loop
        if limit_user.user_name <> l_user_name then
          l_user_name :=limit_user.user_name;
          if nvl(limit_user.EXCEEDED_BY_AMOUNT,0) >=nvl(limit_user.AMOUNT,0) then
           if (l_user_list = ' ') then
            l_user_list := limit_user.user_name;
           else
            l_user_list := l_user_list||','||limit_user.user_name;
           end if;
          end if;
        end if;
      end loop;

   -- begin user selection for ONC deal type
   elsif (p_deal_type = 'ONC') then
      for limit_user in cur_notify_users_onc loop
        if limit_user.user_name <> l_user_name then
          l_user_name :=limit_user.user_name;
          if nvl(limit_user.EXCEEDED_BY_AMOUNT,0) >=nvl(limit_user.AMOUNT,0) then
           if (l_user_list = ' ') then
            l_user_list := limit_user.user_name;
           else
            l_user_list := l_user_list||','||limit_user.user_name;
           end if;
          end if;
        end if;
      end loop;

   -- begin user selection for other deal types
   else
      for limit_user in cur_notify_users_deal loop
        if limit_user.user_name <> l_user_name then
          l_user_name :=limit_user.user_name;
          if nvl(limit_user.EXCEEDED_BY_AMOUNT,0) >=nvl(limit_user.AMOUNT,0) then
           if (l_user_list = ' ') then
            l_user_list := limit_user.user_name;
           else
            l_user_list := l_user_list||','||limit_user.user_name;
           end if;
          end if;
        end if;
      end loop;

   end if;
   -- only start WF if there are users matching the critieria
   if (l_user_list <> ' ') then
      l_role_name := CREATE_XTR_ROLES(ltrim(l_user_list),SYSDATE+2);
      -- begin limits notification
      if (p_process = 'XTR_LIMITS_NOTIFICATION') then
         START_LIMITS_NTF(p_process, p_owner, l_role_name, p_log_id);
      end if;
   end if;

END START_WORKFLOW;

PROCEDURE START_LIMITS_NTF(p_process  IN VARCHAR2,
                           p_owner    IN VARCHAR2,
                           p_receiver IN VARCHAR2,
                           p_log_id   IN NUMBER)
IS
   l_itemkey  VARCHAR2(40);
   l_itemtype VARCHAR2(40) := 'XTRWF';
   l_userkey  VARCHAR2(80);
   l_wf_sequence NUMBER;

BEGIN
   select XTR_WF_S.nextval
   into   l_wf_sequence
   from   dual;

   l_itemkey := to_char(l_wf_sequence);
   l_userkey := l_itemtype||l_itemkey;
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => p_process);
   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'XTR_NTF_RECEIVER',
                             avalue   => p_receiver);
   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'XTR_LIMITS_LOG_ID',
                             avalue   => p_log_id);
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey );
EXCEPTION
   when others then
   wf_core.context('XTR_WORKFLOW_PKG', 'START_LIMITS_NTF', l_itemtype, l_itemkey);
   raise;

END START_LIMITS_NTF;


PROCEDURE LIMITS_BREACHED_DOC(document_id IN VARCHAR2,
                              display_type IN VARCHAR2,
                              document IN OUT NOCOPY VARCHAR2,
                              document_type IN OUT NOCOPY VARCHAR2)
IS

   cursor cur_limits_breached(p_log_id IN NUMBER) is
   select xle.deal_number, xle.transaction_number, decode(xle.exception_type,
'EXCEEDED', FND_MESSAGE.GET_STRING('XTR','XTR_2242'), 'WARNING', FND_MESSAGE.GET_STRING('XTR','XTR_2241'), 'NO_AUTHO',
FND_MESSAGE.GET_STRING('XTR','XTR_2243'), 'NO_LIMIT', FND_MESSAGE.GET_STRING('XTR','XTR_2244')) as exception_type,
    decode(xle.exception_type, 'EXCEEDED', 'XTR_2245',
	'WARNING', 'XTR_2246', 'NO_AUTHO', 'XTR_2247',
	'NO_LIMIT','XTR_2248') as exception_desc,
   decode(xle.LIMIT_CHECK_TYPE,
	'GLOBAL',FND_MESSAGE.GET_STRING('XTR','XTR_2233'),
	'SOVRN', FND_MESSAGE.GET_STRING('XTR','XTR_2234'),
	'DLR_DEAL', FND_MESSAGE.GET_STRING('XTR','XTR_2235'),
	'CPARTY', FND_MESSAGE.GET_STRING('XTR','XTR_2237'),
	'SETTLE',  FND_MESSAGE.GET_STRING('XTR','XTR_2238'),
	'CCY', FND_MESSAGE.GET_STRING('XTR','XTR_2239'),
	'GROUP', FND_MESSAGE.GET_STRING('XTR','XTR_2250'),
	'TIME', FND_MESSAGE.GET_STRING('XTR','XTR_2240') ) as exception_token,
          xle.limit_code,
          xle.exceeded_by_amount exceeded_by_amount_dsp,
          xle.exceeded_on_date exceeded_on_date_dsp,
          xle.currency, xle.company_code, xle.limit_party,
          xle.amount_date amount_date_dsp,
          xle.limiting_amount limiting_amount_dsp,
          xle.authorised_by, xle.dealer_code, xle.log_id
   from XTR_LIMIT_EXCESS_LOG_V xle
   where xle.log_id = p_log_id
   order by xle.deal_number, xle.transaction_number;

   l_deal_no VARCHAR2(50);
   l_trans_no VARCHAR2(50);
   l_exc_type VARCHAR2(50);
   l_limit_code VARCHAR2(50);
   l_exc_amount VARCHAR2(50);
   l_exc_on VARCHAR2(50);
   l_ccy VARCHAR2(50);
   l_comp_code VARCHAR2(50);
   l_limit_party VARCHAR2(50);
   l_amount_date VARCHAR2(50);
   l_limit_amount VARCHAR2(50);
   l_auth_by VARCHAR2(50);
   l_dealer_code VARCHAR2(50);
   l_exc_desc_title VARCHAR2(50);
   l_ccy_code VARCHAR2(15);
   l_exc_desc VARCHAR2(100);

BEGIN
   l_deal_no := FND_MESSAGE.GET_STRING('XTR','XTR_WF_DEAL_NO');
   l_trans_no := FND_MESSAGE.GET_STRING('XTR','XTR_WF_TRANS_NO');
   l_exc_type := FND_MESSAGE.GET_STRING('XTR','XTR_WF_EXC_TYPE');
   l_limit_code := FND_MESSAGE.GET_STRING('XTR','XTR_WF_LIMIT_CODE');
   l_exc_amount := FND_MESSAGE.GET_STRING('XTR','XTR_WF_EXC_AMOUNT');
   l_exc_on := FND_MESSAGE.GET_STRING('XTR','XTR_WF_EXC_ON');
   l_ccy := FND_MESSAGE.GET_STRING('XTR','XTR_WF_CCY');
   l_comp_code := FND_MESSAGE.GET_STRING('XTR','XTR_WF_COMP_CODE');
   l_limit_party := FND_MESSAGE.GET_STRING('XTR','XTR_WF_LIMIT_PARTY');
   l_amount_date := FND_MESSAGE.GET_STRING('XTR','XTR_WF_AMOUNT_DATE');
   l_limit_amount := FND_MESSAGE.GET_STRING('XTR','XTR_WF_LIMIT_AMOUNT');
   l_auth_by := FND_MESSAGE.GET_STRING('XTR','XTR_WF_AUTH_BY');
   l_dealer_code := FND_MESSAGE.GET_STRING('XTR','XTR_WF_DEALER_CODE');
   l_exc_desc_title := FND_MESSAGE.GET_STRING('XTR', 'XTR_WF_EXC_DESC');


   SELECT nvl(param_value,'USD')
   INTO l_ccy_code
   FROM xtr_pro_param_v
   WHERE param_name = 'SYSTEM_FUNCTIONAL_CCY';

   if display_type = 'text/html' then
      document_type := 'text/html';
      document :=
         '<BR><BR><LEFT><TABLE BORDER=0 CELLPADDING=5 CELLSPACING=1 BGCOLOR=#FFFFFF>'||
         '<TR BGCOLOR=#CCCC99>'||
         '<TH ALIGN=RIGHT><FONT COLOR=#336699><B>'|| l_deal_no ||'</B></TH>'||
         '<TH ALIGN=RIGHT><FONT COLOR=#336699><B>'|| l_trans_no || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_exc_type || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_exc_desc_title || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_limit_code || '</B></TH>'||
         '<TH ALIGN=RIGHT><FONT COLOR=#336699><B>' || l_exc_amount || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_exc_on || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_ccy || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_comp_code || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_limit_party || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_amount_date || '</B></TH>'||
         '<TH ALIGN=RIGHT><FONT COLOR=#336699><B>' || l_limit_amount || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_auth_by || '</B></TH>'||
         '<TH ALIGN=LEFT><FONT COLOR=#336699><B>' || l_dealer_code || '</B></TH>'||
         '</TR>';
   else
      document_type := 'text/plain';
      document :=
         FND_GLOBAL.NEWLINE||rpad(l_deal_no,28)||
         rpad(l_trans_no,28)||
         rpad(l_exc_type,28)||
	 rpad(l_exc_desc_title,28)||
         rpad(l_limit_code,28)||
         rpad(l_exc_amount,28)||
         rpad(l_exc_on,28)||
         rpad(l_ccy,28)||
         rpad(l_comp_code,28)||
         rpad(l_limit_party,28)||
         rpad(l_amount_date,28)||
         rpad(l_limit_amount,28)||
         rpad(l_auth_by,28)||
         rpad(l_dealer_code,28)||FND_GLOBAL.NEWLINE;
   end if;
   for limit_rec in cur_limits_breached(to_number(document_id)) loop
       FND_MESSAGE.set_name('XTR', limit_rec.exception_desc);
       FND_MESSAGE.set_token('LIMIT',limit_rec.exception_token );
       l_exc_desc := FND_MESSAGE.get;
      if display_type = 'text/html' then
         document := document||
         '<TR BGCOLOR=#F7F7E7>'||
         '<TD ALIGN=RIGHT>'||limit_rec.deal_number||'</TD>'||
         '<TD ALIGN=RIGHT>'||limit_rec.transaction_number||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.exception_type||'</TD>'||
 	 '<TD ALIGN=LEFT>'||l_exc_desc||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.limit_code||'</TD>'||
         '<TD ALIGN=RIGHT>'||TO_CHAR(limit_rec.exceeded_by_amount_dsp,
	FND_CURRENCY.GET_FORMAT_MASK(l_ccy_code, 30))||'</TD>'||
         '<TD ALIGN=LEFT NOWRAP>'||FND_DATE.DATE_TO_CHARDATE(limit_rec.exceeded_on_date_dsp)||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.currency||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.company_code||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.limit_party||'</TD>'||
         '<TD ALIGN=LEFT NOWRAP>'||FND_DATE.DATE_TO_CHARDATE(limit_rec.amount_date_dsp)||'</TD>'||
         '<TD ALIGN=RIGHT>'||TO_CHAR(limit_rec.limiting_amount_dsp,
	FND_CURRENCY.GET_FORMAT_MASK(l_ccy_code, 30))||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.authorised_by||'</TD>'||
         '<TD ALIGN=LEFT>'||limit_rec.dealer_code||'</TD>'||'</TR>';
      else
         document := document||rpad(limit_rec.deal_number,28)||
         rpad(limit_rec.transaction_number,28)||
         rpad(limit_rec.exception_type,28)||
	 rpad(l_exc_desc,28)||
         rpad(limit_rec.limit_code,28)||
         rpad(TO_CHAR(limit_rec.exceeded_by_amount_dsp,
	FND_CURRENCY.GET_FORMAT_MASK(l_ccy_code, 30)),28)||
         rpad(FND_DATE.DATE_TO_CHARDATE(limit_rec.exceeded_on_date_dsp),28)||
         rpad(limit_rec.currency,28)||
         rpad(limit_rec.company_code,28)||
         rpad(limit_rec.limit_party,28)||
         rpad(FND_DATE.DATE_TO_CHARDATE(limit_rec.amount_date_dsp),28)||
         rpad(TO_CHAR(limit_rec.limiting_amount_dsp,
	FND_CURRENCY.GET_FORMAT_MASK(l_ccy_code, 30)),28)||
         rpad(limit_rec.authorised_by,28)||
         rpad(limit_rec.dealer_code,28)||FND_GLOBAL.NEWLINE;
      end if;
   end loop;
   if display_type = 'text/html' then
      document := document||'</TABLE></LEFT><BR>';
   end if;
EXCEPTION
   when others then
   wf_core.context('XTR_WORKFLOW_PKG', 'LIMITS_BREACHED_DOC', document_id, display_type);
   raise;
END LIMITS_BREACHED_DOC;


-- This procedure removes a Treasury User from WF_LOCAL_USERS
PROCEDURE DELETE_XTR_USERS(p_name IN VARCHAR2,
                           p_dsp_name IN VARCHAR2,
                           p_email IN VARCHAR2)
IS

BEGIN

   delete from WF_LOCAL_USERS
   where NAME = p_name
   and DISPLAY_NAME = p_dsp_name
   and EMAIL_ADDRESS = p_email;

   delete from WF_LOCAL_USER_ROLES
   where USER_NAME = p_name
   and ROLE_ORIG_SYSTEM = 'WF_LOCAL_ROLES';

END DELETE_XTR_USERS;

END XTR_WORKFLOW_PKG;


/
