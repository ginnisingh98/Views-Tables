--------------------------------------------------------
--  DDL for Package Body AP_WEB_CREDIT_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CREDIT_CARD_PKG" AS
/* $Header: apwccrdb.pls 120.7.12010000.2 2009/08/04 13:10:59 meesubra ship $ */

/* Function introduced in OIE.J
   It returns 'Y' if a transaction has level2 data
   and expense tpye as 'HOTEL'.  Ideally, we should
   have a column in ap_credit_card_trxns_all table which
   should get populated during loading the transaction if
   level2 transaction is present.
*/
FUNCTION HAS_DETAILED_TRXN (p_trx_id IN VARCHAR2)
 RETURN VARCHAR2
IS
       has_detailed_trxn VARCHAR2(1) := 'N';
   BEGIN
       select 'Y' into has_detailed_trxn
       from ap_credit_card_trxns_all
       where (HOTEL_TELEPHONE_AMOUNT > 0 OR
           HOTEL_BAR_AMOUNT > 0 OR
           HOTEL_MOVIE_AMOUNT > 0 OR
           HOTEL_GIFT_SHOP_AMOUNT > 0 OR
           HOTEL_LAUNDRY_AMOUNT > 0 OR
           HOTEL_HEALTH_AMOUNT > 0 OR
           HOTEL_RESTAURANT_AMOUNT > 0 OR
           HOTEL_BUSINESS_AMOUNT > 0 OR
           HOTEL_PARKING_AMOUNT > 0 OR
           HOTEL_ROOM_SERVICE_AMOUNT > 0 OR
           HOTEL_TIP_AMOUNT > 0 OR
           HOTEL_MISC_AMOUNT > 0)
       and trx_id = p_trx_id
       and folio_type = 'HOTEL';
       return has_detailed_trxn;

       exception when others then
           return 'N';
    END HAS_DETAILED_TRXN;

/*  This function to create card in oracle payments
    and return the instrument id.  In case of error creating
    instrument id it returns -1. Avoiding calls to
    diagnostic since these are used in bulk uploading
*/
function create_iby_card(p_card_number IN VARCHAR2,
                         p_party_id    IN NUMBER,
                         p_exp_date    IN Date DEFAULT NULL
                          ) return number IS
  x_return_status VARCHAR2(4000);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(4000);
  p_card_instrument APPS.IBY_FNDCPT_SETUP_PUB.CREDITCARD_REC_TYPE;
  x_instr_id NUMBER;
  x_response APPS.IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;

begin
      -- return instrument id if card already exists in oracle payments
      iby_fndcpt_setup_pub.card_exists(1.0,NULL,
           x_return_status, x_msg_count, x_msg_data,
           null , p_card_number, -- party id is null as we reference cards through ap_cards_all.employee_id
           p_card_instrument, x_response);
      if (x_return_status = 'S') then
           x_instr_id := p_card_instrument.card_id;
           -- Inserting an update_card to set the new expiration date if it is not null
           IF (p_exp_date IS NOT NULL) THEN
              p_card_instrument.Expiration_Date :=  p_exp_date;
              iby_fndcpt_setup_pub.update_card(1.0,NULL,'F',x_return_status,x_msg_count,x_msg_data, p_card_instrument,x_response);
           END IF;
           if (x_instr_id is not null) then
              return x_instr_id;
           end if;
      end if;
      p_card_instrument.Instrument_Type := 'CREDITCARD';
      p_card_instrument.card_number := p_card_number;
      p_card_instrument.Expiration_Date :=  p_exp_date;

      if (p_party_id is not null) then
           p_card_instrument.Owner_Id := p_party_id;
      else
           p_card_instrument.Owner_Id := null;
      end if;
      p_card_instrument.Info_Only_Flag := 'Y';
      -- to register the invalid cards in IBY. Always set to 'Y' PA-DSS Implementation
      p_card_instrument.Register_Invalid_Card := 'Y';
      iby_fndcpt_setup_pub.create_card(1.0,NULL,'F',x_return_status,x_msg_count,x_msg_data,
                         p_card_instrument,x_instr_id,x_response);
      if (x_return_status = 'S') then
           return x_instr_id;
      else
          return -1;
      end if;
exception
      when others then
      return -1;
--      raise;
end create_iby_card;

/*  This function returns card_id from ap_cards_all for a
    given credit card number.  If card numbers does not
    exist then it creates a card in oracle payments and
    in ap_cards_all with appropriate references. Avoiding
    calls to diagnostic since these are used in bulk uploading.
*/
function get_card_id(p_card_number IN VARCHAR2,
                     p_card_program_id IN VARCHAR2 DEFAULT NULL,
                     p_party_id IN NUMBER DEFAULT NULL,
                     p_request_id IN VARCHAR2 DEFAULT NULL
                     ) return number IS
l_card_id number ;
l_instr_id number;
l_user_id number;

begin
       -- check for cardnumber being done prior to call to this function
       -- that saves time for context switch from java to pl/sql
/*       if (p_card_number = null)  then
           return -1;
       end if; */

       l_instr_id := create_iby_card(p_card_number, p_party_id, null);
       begin
           if (l_instr_id > 0) then
               select card_id into l_card_id
               from ap_cards_all
               where card_reference_id = l_instr_id
               and card_program_id = p_card_program_id
               and rownum = 1;
               return l_card_id;
           else
               return -1;
           end if;
       exception when no_data_found then
               l_user_id := fnd_global.user_id;
               -- create a row in ap_cards_all and get card_id
                insert into ap_cards_all (card_id,
                card_program_id,
                org_id,
                card_reference_id,
                request_id,
                last_update_date,
                creation_date,
                created_by,
                last_updated_by
                )
                values( ap_cards_s.nextval,
                p_card_program_id,
                (select org_id
                from ap_card_programs_all apcp
                where apcp.card_program_id = p_card_program_id and rownum =1),
                l_instr_id,
                p_request_id,
                sysdate,
                sysdate,
                nvl(l_user_id, -1),
                nvl(l_user_id, -1)
                ) returning card_id into l_card_id ;
                insert into ap_card_details (card_id,
                request_id,
                last_update_date,
                creation_date,
                created_by,
                last_updated_by,
                last_update_login)
                 values (l_card_id,
                 p_request_id,
                 sysdate,
                 sysdate,
                 nvl(l_user_id, -1),
                 nvl(l_user_id, -1),
                 nvl(l_user_id, -1)
                );
                 return l_card_id;
       end;
exception  when others then
      raise;
end get_card_id;

/* Returns card_reference_id (IBY_CREDITCARD.instrid) */
FUNCTION get_card_reference_id(p_document_payable_id IN NUMBER)
RETURN NUMBER IS
 l_card_reference_id   ap_cards_all.card_reference_id%type;
BEGIN

  select crd.card_reference_id -- Instrument ID
  into   l_card_reference_id
  from   ap_invoices_all inv,
         iby_docs_payable_all iby,
         ap_expense_report_headers_all erh,
         ap_credit_card_trxns_all ctx,
         ap_cards_all crd
  where  iby.document_payable_id = p_document_payable_id
  and    iby.calling_app_doc_unique_ref2 = inv.invoice_id
  and    inv.invoice_id = erh.vouchno
  and    inv.invoice_type_lookup_code in ('EXPENSE REPORT', 'MIXED')
  and    inv.source in ('SelfService', 'Both Pay', 'CREDIT CARD')
  and    ctx.report_header_id = erh.bothpay_parent_id
  and    crd.card_id = ctx.card_id
  and    rownum = 1;

  return(l_card_reference_id);

EXCEPTION
  when NO_DATA_FOUND THEN
    return null;
  when OTHERS then
    AP_WEB_DB_UTIL_PKG.RaiseException('get_card_reference_id');
    APP_EXCEPTION.RAISE_EXCEPTION;
END get_card_reference_id;

END AP_WEB_CREDIT_CARD_PKG;

/
