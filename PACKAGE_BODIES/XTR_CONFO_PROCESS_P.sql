--------------------------------------------------------
--  DDL for Package Body XTR_CONFO_PROCESS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_CONFO_PROCESS_P" as
/* $Header: xtrconfb.pls 120.1 2005/06/29 12:42:47 badiredd ship $ */
---------------------------------------------------------------------------------------------------------------------------
PROCEDURE POST_CONFIRMATION_DETAILS(p_deal_no IN NUMBER,
                                    p_trans_no IN NUMBER,
                                    p_action IN VARCHAR2,
                                    p_cparty IN VARCHAR2,
                                    p_client IN VARCHAR2,
                                    p_company_code IN VARCHAR2,
                                    p_confo_party_code IN VARCHAR2,
                                    p_deal_type IN VARCHAR2,
                                    p_deal_subtype IN VARCHAR2,
                                    p_currency IN VARCHAR2,
                                    p_amount IN NUMBER,
                                    p_deal_status IN VARCHAR2) is
--
 l_party VARCHAR2(7);
 l_action NUMBER;
--
 cursor GET_CONFO_ACTIONS is
   select 1
     from XTR_CONFIRMATION_ACTIONS c,
          XTR_PARTIES_V p
     where p.PARTY_CODE = l_party
     and c.CONFO_ACTION_GROUP = p.CONFO_ACTION_CODE
     and c.DEAL_TYPE = p_deal_type
     and c.ACTION_TYPE = p_action;
--
begin
  null; -- ************ Check if this procedure is reqd any longer (replaced by trigger - refer John)
  /*
  -- ***** Post Confirmation row for COUNTERPARTY confirmation *****
  if p_cparty is NOT NULL then
   l_party := p_cparty;
   update XTR_CONFIRMATION_DETAILS
    set DEAL_SUBTYPE = p_deal_subtype,
        CURRENCY = p_currency,
        AMOUNT = p_amount,
        CONFO_PARTY_CODE = l_party
    where DEAL_NO = p_deal_no
    and TRANSACTION_NO = p_trans_no
    and CLIENT_OR_CPARTY =   'CP';
    --
    if SQL%NOTFOUND then
    open  GET_CONFO_ACTIONS;
     fetch GET_CONFO_ACTIONS into l_action;
      if GET_CONFO_ACTIONS%FOUND then
      -- Insert row into Confirmation_details so confo can be generated
      insert into XTR_CONFIRMATION_DETAILS
       (deal_no,transaction_no,action_type,client_or_cparty,date_created,
        company_code,confo_party_code,file_name,deal_type,
        deal_subtype,currency,amount,confirmation_validated_by,
        confirmation_validated_on,status_code)
      values
       (p_deal_no,p_trans_no,p_action,'CP',sysdate,p_company_code,
        l_party,NULL,p_deal_type,p_deal_subtype,p_currency,p_amount,
        NULL,NULL,p_deal_status);
     end if;
     close GET_CONFO_ACTIONS;
    end if;
   end if;
   --
   -- ***** Post Confirmation row for CLIENT confirmation *****
   if p_client is NOT NULL then
    l_party := p_client;
    update XTR_CONFIRMATION_DETAILS
      set DEAL_SUBTYPE = p_deal_subtype,
           STATUS_CODE = p_deal_status,
           CURRENCY = p_currency,
           AMOUNT = p_amount,
           CONFO_PARTY_CODE = l_party
       where DEAL_NO = p_deal_no
       and TRANSACTION_NO = p_trans_no
       and CLIENT_OR_CPARTY =   'CL';
     if SQL%NOTFOUND then
     open  GET_CONFO_ACTIONS;
      fetch GET_CONFO_ACTIONS into l_action;
      if GET_CONFO_ACTIONS%FOUND then
      -- Insert row into Confirmation_details so confo can be generated
      insert into XTR_CONFIRMATION_DETAILS
       (deal_no,transaction_no,action_type,client_or_cparty,date_created,
        company_code,confo_party_code,file_name,deal_type,
        deal_subtype,currency,amount,confirmation_validated_by,
        confirmation_validated_on,status_code)
      values
       (p_deal_no,p_trans_no,p_action,'CL',sysdate,p_company_code,
        l_party,NULL,p_deal_type,p_deal_subtype,p_currency,p_amount,
        NULL,NULL,p_deal_status);
      end if;
      close GET_CONFO_ACTIONS;
     end if;
   end if;
 */
end POST_CONFIRMATION_DETAILS;
---------------------------------------------------------------------------------------------------------------------------
PROCEDURE CANCEL_CONFO(p_deal_no IN NUMBER,
                       p_trans_no IN NUMBER) is
--
begin
 delete from XTR_CONFIRMATION_DETAILS
   where DEAL_NO = p_deal_no
   and TRANSACTION_NO = nvl(p_trans_no,p_deal_no)
   and FILE_NAME is NULL;
--
 update XTR_CONFIRMATION_DETAILS
   set STATUS_CODE = 'CANCELLED'
   where DEAL_NO = p_deal_no
   and TRANSACTION_NO = p_trans_no
   and FILE_NAME is NOT NULL;
--
end CANCEL_CONFO;

---------------------------------------------------------------------------------------------------------------------------

PROCEDURE CALL_XTRLTCFM (P_TEMPLATE_TYPE    IN VARCHAR2,
                         P_TEMPLATE_NAME    IN VARCHAR2,
                         P_CREATED_ON       IN DATE,
                         P_EFFECTIVE_DATE   IN DATE,
                         P_DEAL_NO          IN NUMBER,
                         P_PRODUCT_TYPE     IN VARCHAR2,
                         P_PAYMENT_SCHEDULE IN VARCHAR2,
                         P_TOTAL            OUT NOCOPY NUMBER,
                         P_SUCCESS          OUT NOCOPY NUMBER) is
--
  l_deal_no         XTR_DEALS_V.DEAL_NO%TYPE;
  l_deal_type       XTR_DEALS_V.DEAL_TYPE%TYPE;
  request_id        NUMBER;
--
 cursor GET_TERM_ACTION is
  select a.DEAL_NO,
         b.DEAL_TYPE
  from   XTR_TERM_ACTIONS a,
         XTR_DEALS_V b
  where ((a.DEAL_NO = P_DEAL_NO and P_DEAL_NO is not null) or (P_DEAL_NO is null))
  and     a.DEAL_NO = b.DEAL_NO
  and     a.CREATED_ON = P_CREATED_ON
  and   ((P_TEMPLATE_TYPE  = 'RETAIL TERM CPARTY PRIN ADJUST' and
             a.PRINCIPAL_ADJUST is not null and
             a.INCREASE_EFFECTIVE_FROM_DATE = p_effective_date and
             b.PAYMENT_SCHEDULE_CODE = nvl(P_PAYMENT_SCHEDULE,b.PAYMENT_SCHEDULE_CODE) and
             b.PRODUCT_TYPE          = nvl(P_PRODUCT_TYPE,b.PRODUCT_TYPE))
  or     (P_TEMPLATE_TYPE  = 'RETAIL TERM CPARTY SCHEDULE' and
             a.PAYMENT_SCHEDULE_CODE = nvl(P_PAYMENT_SCHEDULE,a.PAYMENT_SCHEDULE_CODE) and
             a.FROM_START_DATE       = p_effective_date and
             b.PRODUCT_TYPE          = nvl(P_PRODUCT_TYPE,b.PRODUCT_TYPE))
  or     (P_TEMPLATE_TYPE  = 'RETAIL TERM CPARTY INT RESET' and
             a.NEW_INTEREST_RATE is not null and
             a.EFFECTIVE_FROM_DATE   = p_effective_date and
             b.PAYMENT_SCHEDULE_CODE = nvl(P_PAYMENT_SCHEDULE,b.PAYMENT_SCHEDULE_CODE) and
             b.PRODUCT_TYPE          = nvl(P_PRODUCT_TYPE,b.PRODUCT_TYPE)))
  order by a.DEAL_NO;

--
begin
   --
   p_total   := 0;
   p_success := 0;
   --
   open GET_TERM_ACTION;
   fetch GET_TERM_ACTION into l_deal_no, l_deal_type;
   while GET_TERM_ACTION%FOUND loop
      p_total := p_total + 1;
      request_id := FND_REQUEST.SUBMIT_REQUEST(
                    'XTR', 'XTRLTCFM','','',FALSE,
                    'N',                    -- example
                    'N',                    -- SQL trace
                    'N',                    -- display debug
                    to_char(l_deal_no),
                    null,                   -- Name_In('C.transaction_no'),
                    l_deal_type,
                    null,                   -- Name_In('C.confo_party_code'),
                    null,                   -- Name_In('C.action_type'),
                    p_template_type,
                    to_char(p_created_on, 'YYYY/MM/DD HH24:MI:SS'),
                    chr(0),
                    '','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','',
                    '','','','','','','','','','');
      If (request_id <> 0) then
          p_success := p_success + 1;
      End If;
      fetch GET_TERM_ACTION into l_deal_no, l_deal_type;
   End Loop;
   if p_total = 1 then
      p_success := request_id;
   end if;
   close GET_TERM_ACTION;
   commit;
end CALL_XTRLTCFM;
---------------------------------------------------------------------------------------------------------------------------
end XTR_CONFO_PROCESS_P;

/
